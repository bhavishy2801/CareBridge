const mongoose=require("mongoose");

const CarePlanSchema=new mongoose.Schema({
  patientId: mongoose.Schema.Types.ObjectId,
  doctorId: mongoose.Schema.Types.ObjectId,
  medications: Array,
  exercises: Array,
  instructions: String,
  warningSigns: String,
  pdfUrl: String,
  createdAt: { type: Date,default: Date.now }
});

module.exports=mongoose.model("CarePlan",CarePlanSchema);
