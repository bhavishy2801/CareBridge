const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const role=require("../middleware/role");
const Appointment=require("../models/appointment");

router.post("/",auth,role("patient"),async (req,res)=>{
  const appointment=await Appointment.create({
    patientId: req.user.id,
    doctorId: req.body.doctorId,
    date: req.body.date,
    status: "upcoming"
  });
  res.status(201).json(appointment);
});

router.get("/doctor",auth,role("doctor"),async (req,res)=>{
  const appointments=await Appointment.find({ doctorId: req.user.id });
  res.json(appointments);
});

router.get("/patient",auth,role("patient"),async (req,res)=>{
  const appointments=await Appointment.find({ patientId: req.user.id });
  res.json(appointments);
});

module.exports=router;