const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const role = require("../middleware/role");
const CarePlan = require("../models/careplan");
const Doctor = require("../models/doctor");
const Patient = require("../models/patient");
const User = require("../models/user"); // Fallback for old data

router.post("/", auth, role("doctor"), async (req, res) => {
  const plan = await CarePlan.create({
    appointmentId: req.body.appointmentId,
    patientId: req.body.patientId,
    doctorId: req.user.id,
    medications: req.body.medications,
    exercises: req.body.exercises,
    instructions: req.body.instructions,
    warningSigns: req.body.warningSigns,
    pdfUrl: req.body.pdfUrl,
  });
  res.status(201).json(plan);
});

router.get("/:patientId", auth, async (req, res) => {
  try {
    const plans = await CarePlan.find({ patientId: req.params.patientId });
    console.log(`Found ${plans.length} care plans for patient ${req.params.patientId}`);

    // Populate doctor and patient names
    const plansWithNames = await Promise.all(
      plans.map(async (plan) => {
        console.log(`Processing plan ${plan._id}, doctorId: ${plan.doctorId}`);
        
        // Try new Doctor model first
        let doctor = await Doctor.findById(plan.doctorId).select("name");
        
        // Fallback to old User model if not found
        if (!doctor) {
          console.log(`Doctor not found in Doctor model, checking User model...`);
          doctor = await User.findById(plan.doctorId).select("name");
        }
        
        // Try new Patient model first
        let patient = await Patient.findById(plan.patientId).select("name");
        
        // Fallback to old User model if not found
        if (!patient) {
          console.log(`Patient not found in Patient model, checking User model...`);
          patient = await User.findById(plan.patientId).select("name");
        }
        
        console.log(`Doctor found: ${doctor?.name}, Patient found: ${patient?.name}`);

        return {
          ...plan.toObject(),
          doctorName: doctor?.name || "Unknown Doctor",
          patientName: patient?.name || "Unknown Patient",
        };
      })
    );

    console.log(`Returning ${plansWithNames.length} plans with names`);
    res.json(plansWithNames);
  } catch (error) {
    console.error('Error in careplan GET route:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
