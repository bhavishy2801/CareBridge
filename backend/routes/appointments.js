const express = require("express");
const router = express.Router();

const auth = require("../middleware/auth");
const role = require("../middleware/role");
const Appointment = require("../models/appointment");
const Doctor = require("../models/doctor");
const Patient = require("../models/patient");

router.post("/", auth, role("patient"), async (req, res) => {
  const appointment = await Appointment.create({
    patientId: req.user.id,
    doctorId: req.body.doctorId,
    date: req.body.date,
    status: "upcoming",
  });
  res.status(201).json(appointment);
});

router.get("/doctor", auth, role("doctor"), async (req, res) => {
  const appointments = await Appointment.find({ doctorId: req.user.id });

  // Populate patient names
  const appointmentsWithNames = await Promise.all(
    appointments.map(async (apt) => {
      const patient = await Patient.findById(apt.patientId).select("name");
      return {
        ...apt.toObject(),
        patientName: patient?.name || "Unknown Patient",
      };
    })
  );

  res.json(appointmentsWithNames);
});

router.get("/patient", auth, role("patient"), async (req, res) => {
  const appointments = await Appointment.find({ patientId: req.user.id });

  // Populate doctor names
  const appointmentsWithNames = await Promise.all(
    appointments.map(async (apt) => {
      const doctor = await Doctor.findById(apt.doctorId).select("name");
      return {
        ...apt.toObject(),
        doctorName: doctor?.name || "Unknown Doctor",
      };
    })
  );

  res.json(appointmentsWithNames);
});

module.exports = router;
