const jwt = require("jsonwebtoken");
const Message = require("../models/message");
const Association = require("../models/association");

// Store connected users: { odId: { odketId, userType } }
const connectedUsers = new Map();

// Authenticate socket connection
const authenticateSocket = (socket, next) => {
  const token = socket.handshake.auth.token || socket.handshake.query.token;

  if (!token) {
    return next(new Error("Authentication error: Token required"));
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.user = {
      id: decoded.id,
      role: decoded.role,
      userType: decoded.userType,
    };
    next();
  } catch (err) {
    return next(new Error("Authentication error: Invalid token"));
  }
};

// Initialize WebSocket server
const initializeSocket = (io) => {
  // Apply authentication middleware
  io.use(authenticateSocket);

  io.on("connection", (socket) => {
    const userId = socket.user.id;
    const userType = socket.user.userType;

    console.log(`User connected: ${userId} (${userType})`);

    // Store connected user
    connectedUsers.set(userId, {
      socketId: socket.id,
      userType,
    });

    // Join user's personal room for direct messages
    socket.join(userId);

    // ✅ Handle joining a conversation room
    socket.on("join_conversation", async ({ partnerId, partnerType }) => {
      try {
        // Verify association before allowing to join
        const canChat = await Association.canCommunicate(
          userId,
          userType,
          partnerId,
          partnerType
        );

        if (!canChat) {
          socket.emit("error", {
            message: "You are not associated with this user",
          });
          return;
        }

        const conversationId = Message.generateConversationId(
          userId,
          partnerId
        );
        socket.join(conversationId);

        // Mark existing messages as delivered
        await Message.updateMany(
          {
            conversationId,
            receiverId: userId,
            status: "sent",
          },
          { status: "delivered" }
        );

        socket.emit("conversation_joined", { conversationId });
        console.log(`User ${userId} joined conversation ${conversationId}`);
      } catch (err) {
        console.error("Join conversation error:", err);
        socket.emit("error", { message: "Failed to join conversation" });
      }
    });

    // ✅ Handle leaving a conversation room
    socket.on("leave_conversation", ({ partnerId }) => {
      const conversationId = Message.generateConversationId(userId, partnerId);
      socket.leave(conversationId);
      console.log(`User ${userId} left conversation ${conversationId}`);
    });

    // ✅ Handle sending a message
    socket.on("send_message", async (data) => {
      try {
        const {
          receiverId,
          receiverType,
          content,
          messageType = "text",
          attachmentUrl,
        } = data;

        // Validate required fields
        if (!receiverId || !receiverType || !content) {
          socket.emit("error", {
            message: "receiverId, receiverType, and content are required",
          });
          return;
        }

        // Verify association
        const canChat = await Association.canCommunicate(
          userId,
          userType,
          receiverId,
          receiverType
        );

        if (!canChat) {
          socket.emit("error", {
            message: "You can only message users you are associated with",
          });
          return;
        }

        const conversationId = Message.generateConversationId(
          userId,
          receiverId
        );

        // Check if receiver is online
        const receiverConnection = connectedUsers.get(receiverId);
        const initialStatus = receiverConnection ? "delivered" : "sent";

        // Save message to database
        const message = await Message.create({
          conversationId,
          senderId: userId,
          senderType: userType,
          receiverId,
          receiverType,
          content,
          messageType,
          attachmentUrl,
          status: initialStatus,
        });

        // Emit to sender (confirmation)
        socket.emit("message_sent", {
          tempId: data.tempId, // Client-side temp ID for matching
          message: message.toObject(),
        });

        // Emit to receiver
        io.to(receiverId).emit("new_message", {
          message: message.toObject(),
        });

        // Also emit to conversation room (if both are in it)
        socket.to(conversationId).emit("new_message", {
          message: message.toObject(),
        });

        console.log(`Message sent from ${userId} to ${receiverId}`);
      } catch (err) {
        console.error("Send message error:", err);
        socket.emit("error", { message: "Failed to send message" });
      }
    });

    // ✅ Handle typing indicator
    socket.on("typing_start", ({ partnerId }) => {
      const conversationId = Message.generateConversationId(userId, partnerId);
      socket.to(conversationId).emit("user_typing", {
        userId,
        userType,
      });
    });

    socket.on("typing_stop", ({ partnerId }) => {
      const conversationId = Message.generateConversationId(userId, partnerId);
      socket.to(conversationId).emit("user_stopped_typing", {
        userId,
      });
    });

    // ✅ Handle message read receipts
    socket.on("messages_read", async ({ conversationId, partnerId }) => {
      try {
        await Message.markAsRead(conversationId, userId);

        // Notify partner that messages were read
        io.to(partnerId).emit("messages_marked_read", {
          conversationId,
          readBy: userId,
        });
      } catch (err) {
        console.error("Mark read error:", err);
      }
    });

    // ✅ Handle user online status check
    socket.on("check_online", ({ userIds }) => {
      const onlineStatus = {};
      userIds.forEach((id) => {
        onlineStatus[id] = connectedUsers.has(id);
      });
      socket.emit("online_status", onlineStatus);
    });

    // ✅ Handle disconnect
    socket.on("disconnect", () => {
      console.log(`User disconnected: ${userId}`);
      connectedUsers.delete(userId);

      // Broadcast offline status to potential chat partners
      // This could be optimized to only notify associated users
      socket.broadcast.emit("user_offline", { userId });
    });

    // ✅ Error handling
    socket.on("error", (err) => {
      console.error("Socket error:", err);
    });
  });

  return io;
};

// Helper to emit to specific user
const emitToUser = (io, userId, event, data) => {
  const userConnection = connectedUsers.get(userId);
  if (userConnection) {
    io.to(userConnection.socketId).emit(event, data);
    return true;
  }
  return false;
};

// Helper to check if user is online
const isUserOnline = (userId) => {
  return connectedUsers.has(userId);
};

module.exports = {
  initializeSocket,
  emitToUser,
  isUserOnline,
  connectedUsers,
};
