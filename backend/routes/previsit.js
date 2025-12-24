const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const role=require("../middleware/role");
const PreVisit=require("../models/previsit");

router.post("/",auth,role("patient"),async (req,res)=>{
  const form=await PreVisit.create({
    patientId: req.user.id,
    appointmentId: req.body.appointmentId,
    symptoms: req.body.symptoms,
    reports: req.body.reports
  });
  res.status(201).json(form);
});

router.get("/:appointmentId",auth,role("doctor"),async (req,res)=>{
  const form=await PreVisit.findOne({
    appointmentId: req.params.appointmentId
  });
  res.json(form);
});

module.exports=router;
