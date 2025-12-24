const mongoose=require("mongoose");

const NotificationSchema=new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  type: {
    type: String,
    enum: ["reminder","alert","info"],
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
      enum: ["careplan","appointment","dailylog"],
    },
    entityId: {
      type: mongoose.Schema.Types.ObjectId
    }
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

module.exports=mongoose.model("Notification",NotificationSchema);
