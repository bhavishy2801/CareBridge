const Message = require("../models/message");
const Association = require("../models/association");
const Patient = require("../models/patient");
const Doctor = require("../models/doctor");
const Caretaker = require("../models/caretaker");

// Helper to get user info by ID and type
const getUserInfo = async (userId, userType) => {
  let user;
  switch (userType) {
    case "Patient":
      user = await Patient.findById(userId).select("name email phone");
      break;
    case "Doctor":
      user = await Doctor.findById(userId).select(
        "name email phone specialization"
      );
      break;
    case "Caretaker":
      user = await Caretaker.findById(userId).select("name email phone");
      break;
  }
  return user;
};

// ✅ GET CONVERSATION HISTORY
exports.getConversation = async (req, res) => {
  try {
    const { id: userId, userType } = req.user;
    const { partnerId, partnerType } = req.params;
    const { limit = 50, skip = 0 } = req.query;

    // Check if users can communicate
    const canChat = await Association.canCommunicate(
      userId,
      userType,
      partnerId,
      partnerType
    );

    if (!canChat) {
      return res.status(403).json({
        msg: "You can only chat with users you are associated with",
      });
    }

    // Get conversation
    const messages = await Message.getConversation(
      userId,
      partnerId,
      parseInt(limit),
      parseInt(skip)
    );

    // Mark messages as read
    const conversationId = Message.generateConversationId(userId, partnerId);
    await Message.markAsRead(conversationId, userId);

    // Get partner info
    const partner = await getUserInfo(partnerId, partnerType);

    res.json({
      messages: messages.reverse(), // Oldest first
      partner,
      conversationId,
    });
  } catch (err) {
    console.error("Get conversation error:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ SEND MESSAGE (REST fallback - WebSocket preferred)
exports.sendMessage = async (req, res) => {
  try {
    const { id: senderId, userType: senderType } = req.user;
    const {
      receiverId,
      receiverType,
      content,
      messageType = "text",
      attachmentUrl,
    } = req.body;

    if (!receiverId || !receiverType || !content) {
      return res.status(400).json({
        msg: "receiverId, receiverType, and content are required",
      });
    }

    // Check if users can communicate
    const canChat = await Association.canCommunicate(
      senderId,
      senderType,
      receiverId,
      receiverType
    );

    if (!canChat) {
      return res.status(403).json({
        msg: "You can only chat with users you are associated with",
      });
    }

    const conversationId = Message.generateConversationId(senderId, receiverId);

    const message = await Message.create({
      conversationId,
      senderId,
      senderType,
      receiverId,
      receiverType,
      content,
      messageType,
      attachmentUrl,
      status: "sent",
    });

    res.status(201).json({
      msg: "Message sent successfully",
      message,
    });
  } catch (err) {
    console.error("Send message error:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ GET ALL CONVERSATIONS
exports.getConversations = async (req, res) => {
  try {
    const { id: userId, userType } = req.user;

    const conversations = await Message.getUserConversations(userId);

    // Enrich with user details
    const enrichedConversations = await Promise.all(
      conversations.map(async (conv) => {
        const { lastMessage, unreadCount } = conv;

        // Determine the partner (the other person in conversation)
        const partnerId =
          lastMessage.senderId.toString() === userId.toString()
            ? lastMessage.receiverId
            : lastMessage.senderId;
        const partnerType =
          lastMessage.senderId.toString() === userId.toString()
            ? lastMessage.receiverType
            : lastMessage.senderType;

        const partner = await getUserInfo(partnerId, partnerType);

        return {
          conversationId: conv._id,
          partner: {
            id: partnerId,
            type: partnerType,
            ...partner?.toObject(),
          },
          lastMessage: {
            content: lastMessage.content,
            createdAt: lastMessage.createdAt,
            isFromMe: lastMessage.senderId.toString() === userId.toString(),
          },
          unreadCount,
        };
      })
    );

    res.json({ conversations: enrichedConversations });
  } catch (err) {
    console.error("Get conversations error:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ MARK MESSAGES AS READ
exports.markAsRead = async (req, res) => {
  try {
    const { id: userId } = req.user;
    const { conversationId } = req.params;

    await Message.markAsRead(conversationId, userId);

    res.json({ msg: "Messages marked as read" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ GET UNREAD COUNT
exports.getUnreadCount = async (req, res) => {
  try {
    const { id: userId } = req.user;

    const count = await Message.countDocuments({
      receiverId: userId,
      isRead: false,
    });

    res.json({ unreadCount: count });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ DELETE MESSAGE (soft delete or sender only)
exports.deleteMessage = async (req, res) => {
  try {
    const { id: userId } = req.user;
    const { messageId } = req.params;

    const message = await Message.findById(messageId);

    if (!message) {
      return res.status(404).json({ msg: "Message not found" });
    }

    // Only sender can delete
    if (message.senderId.toString() !== userId.toString()) {
      return res
        .status(403)
        .json({ msg: "You can only delete your own messages" });
    }

    await Message.findByIdAndDelete(messageId);

    res.json({ msg: "Message deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
