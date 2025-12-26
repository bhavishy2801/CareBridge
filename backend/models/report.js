const mongoose = require("mongoose");

const symptomSchema = new mongoose.Schema({
  name: { type: String, required: true },
  severity: { type: Number, required: true, min: 0, max: 10 },
});

const reportSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Patient",
    required: true,
  },
  symptoms: [symptomSchema],
  customMessage: { type: String },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Report", reportSchema);
