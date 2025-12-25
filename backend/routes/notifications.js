const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const Notification = require("../models/notification");

// Get all notifications for authenticated user
router.get("/", auth, async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 });
    
    // Transform to match Flutter model expectations
    const transformed = notifications.map(n => ({
      _id: n._id,
      userId: n.userId,
      type: n.type,
      title: n.title,
      message: n.message,
      scheduledTime: n.scheduledAt || n.createdAt,
      createdAt: n.createdAt,
      isRead: n.read,
      data: n.data || (n.relatedEntity ? {
        entityType: n.relatedEntity.entityType,
        entityId: n.relatedEntity.entityId
      } : null)
    }));
    
    res.json(transformed);
  } catch (err) {
    console.error("Error fetching notifications:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Mark notification as read
router.patch("/:id/read", auth, async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { read: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    res.json({ 
      _id: notification._id,
      isRead: notification.read,
      message: "Notification marked as read" 
    });
  } catch (err) {
    console.error("Error marking notification as read:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Mark all notifications as read
router.patch("/read-all", auth, async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.user.id, read: false },
      { read: true }
    );

    res.json({ message: "All notifications marked as read" });
  } catch (err) {
    console.error("Error marking all notifications as read:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete a notification
router.delete("/:id", auth, async (req, res) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id
    });

    if (!notification) {
      return res.status(404).json({ message: "Notification not found" });
    }

    res.json({ message: "Notification deleted" });
  } catch (err) {
    console.error("Error deleting notification:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete all notifications for user
router.delete("/", auth, async (req, res) => {
  try {
    await Notification.deleteMany({ userId: req.user.id });
    res.json({ message: "All notifications deleted" });
  } catch (err) {
    console.error("Error deleting all notifications:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Create a notification (for internal use or admin)
router.post("/", auth, async (req, res) => {
  try {
    const { userId, type, title, message, data, scheduledAt, relatedEntity } = req.body;

    const notification = new Notification({
      userId: userId || req.user.id,
      type: type || "info",
      title,
      message,
      data,
      scheduledAt,
      relatedEntity
    });

    await notification.save();

    res.status(201).json({
      _id: notification._id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      scheduledTime: notification.scheduledAt || notification.createdAt,
      createdAt: notification.createdAt,
      isRead: notification.read,
      data: notification.data
    });
  } catch (err) {
    console.error("Error creating notification:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;