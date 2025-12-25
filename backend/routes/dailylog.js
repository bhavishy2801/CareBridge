const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const role = require("../middleware/role");
const DailyLog = require("../models/dailylog");
const Patient = require("../models/patient");
const User = require("../models/user"); // Fallback for old data

router.post("/", auth, role("patient"), async (req, res) => {
  const log = await DailyLog.create({
    patientId: req.user.id,
    carePlanId: req.body.carePlanId,
    date: req.body.date,
    medicationTaken: req.body.medicationTaken,
    exerciseDone: req.body.exerciseDone,
    symptomRating: req.body.symptomRating,
  });
  res.status(201).json(log);
});

router.get("/:patientId", auth, role("doctor"), async (req, res) => {
  const logs = await DailyLog.find({ patientId: req.params.patientId });

  // Populate patient name
  let patient = await Patient.findById(req.params.patientId).select("name");
  if (!patient) {
    patient = await User.findById(req.params.patientId).select("name");
  }
  const logsWithName = logs.map((log) => ({
    ...log.toObject(),
    patientName: patient?.name || "Unknown Patient",
  }));

  res.json(logsWithName);
});

module.exports = router;
