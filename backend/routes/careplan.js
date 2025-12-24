const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const role=require("../middleware/role");
const CarePlan=require("../models/careplan");

router.post("/",auth,role("doctor"),async (req,res)=>{
  const plan=await CarePlan.create({
    appointmentId: req.body.appointmentId,
    patientId: req.body.patientId,
    doctorId: req.user.id,
    medications: req.body.medications,
    exercises: req.body.exercises,
    instructions: req.body.instructions,
    warningSigns: req.body.warningSigns,
    pdfUrl: req.body.pdfUrl
  });
  res.status(201).json(plan);
});

router.get("/:patientId",auth,async (req,res)=>{
  const plans=await CarePlan.find({ patientId: req.params.patientId });
  res.json(plans);
});

module.exports=router;
