const mongoose = require("mongoose");

const MessageSchema = new mongoose.Schema({
  // Conversation identifier (sorted combination of user IDs)
  conversationId: {
    type: String,
    required: true,
    index: true,
  },

  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },

  senderType: {
    type: String,
    enum: ["Patient", "Doctor", "Caretaker"],
    required: true,
  },

  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },

  receiverType: {
    type: String,
    enum: ["Patient", "Doctor", "Caretaker"],
    required: true,
  },

  content: {
    type: String,
    required: true,
  },

  messageType: {
    type: String,
    enum: ["text", "image", "file", "prescription", "report"],
    default: "text",
  },

  // For file/image messages
  attachmentUrl: {
    type: String,
  },

  // Read status
  isRead: {
    type: Boolean,
    default: false,
  },

  readAt: {
    type: Date,
  },

  // Delivery status
  status: {
    type: String,
    enum: ["sent", "delivered", "read"],
    default: "sent",
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for efficient message retrieval
MessageSchema.index({ conversationId: 1, createdAt: -1 });
MessageSchema.index({ senderId: 1, receiverId: 1 });

// Static method to generate conversation ID
MessageSchema.statics.generateConversationId = function (userId1, userId2) {
  // Sort IDs to ensure consistent conversation ID regardless of who sends
  const sortedIds = [userId1.toString(), userId2.toString()].sort();
  return `${sortedIds[0]}_${sortedIds[1]}`;
};

// Static method to get conversation history
MessageSchema.statics.getConversation = async function (
  userId1,
  userId2,
  limit = 50,
  skip = 0
) {
  const conversationId = this.generateConversationId(userId1, userId2);

  return this.find({ conversationId })
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .lean();
};

// Static method to get all conversations for a user
MessageSchema.statics.getUserConversations = async function (userId) {
  const messages = await this.aggregate([
    {
      $match: {
        $or: [
          { senderId: new mongoose.Types.ObjectId(userId) },
          { receiverId: new mongoose.Types.ObjectId(userId) },
        ],
      },
    },
    {
      $sort: { createdAt: -1 },
    },
    {
      $group: {
        _id: "$conversationId",
        lastMessage: { $first: "$$ROOT" },
        unreadCount: {
          $sum: {
            $cond: [
              {
                $and: [
                  { $eq: ["$receiverId", new mongoose.Types.ObjectId(userId)] },
                  { $eq: ["$isRead", false] },
                ],
              },
              1,
              0,
            ],
          },
        },
      },
    },
    {
      $sort: { "lastMessage.createdAt": -1 },
    },
  ]);

  return messages;
};

// Mark messages as read
MessageSchema.statics.markAsRead = async function (conversationId, readerId) {
  return this.updateMany(
    {
      conversationId,
      receiverId: readerId,
      isRead: false,
    },
    {
      $set: {
        isRead: true,
        readAt: new Date(),
        status: "read",
      },
    }
  );
};

module.exports = mongoose.model("Message", MessageSchema);
