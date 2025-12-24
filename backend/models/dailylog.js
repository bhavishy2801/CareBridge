const mongoose=require("mongoose");

const DailyLogSchema=new mongoose.Schema({
  clientId: {
    type: String,
    required: true,
    unique: true
  },

  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  carePlanId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "CarePlan"
  },

  date: Date,

  medicationTaken: Boolean,
  exerciseDone: Boolean,
  symptomRating: Number,

  syncedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports=mongoose.model("DailyLog",DailyLogSchema);
