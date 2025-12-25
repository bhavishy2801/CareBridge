const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const {
  getConversation,
  sendMessage,
  getConversations,
  markAsRead,
  getUnreadCount,
  deleteMessage,
} = require("../controllers/chatController");

// Get all conversations for current user (GET /api/chat/conversations)
router.get("/conversations", auth, getConversations);

// Get unread message count (GET /api/chat/unread)
router.get("/unread", auth, getUnreadCount);

// Get conversation with specific user (GET /api/chat/:partnerId/:partnerType)
router.get("/:partnerId/:partnerType", auth, getConversation);

// Send message via REST (POST /api/chat/send)
// Note: WebSocket is preferred for real-time messaging
router.post("/send", auth, sendMessage);

// Mark conversation as read (PATCH /api/chat/:conversationId/read)
router.patch("/:conversationId/read", auth, markAsRead);

// Delete a message (DELETE /api/chat/message/:messageId)
router.delete("/message/:messageId", auth, deleteMessage);

module.exports = router;
