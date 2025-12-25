const mongoose = require("mongoose");

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  type: {
    type: String,
    enum: ["reminder", "alert", "info", "medication", "appointment", "message", "care_plan", "vitals", "exercise", "missed_task", "general"],
    default: "info"
  },

  title: {
    type: String,
    required: true
  },

  message: {
    type: String,
    required: true
  },

  relatedEntity: {
    entityType: {
      type: String,
      enum: ["careplan", "appointment", "dailylog", "patient", "doctor", "caregiver"],
    },
    entityId: {
      type: mongoose.Schema.Types.ObjectId
    }
  },

  data: {
    type: mongoose.Schema.Types.Mixed,
    default: null
  },

  scheduledAt: {
    type: Date
  },

  read: {
    type: Boolean,
    default: false
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Notification", NotificationSchema);