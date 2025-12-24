const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const role=require("../middleware/role");

router.get("/doctor",auth,role("doctor"),(req,res)=>{
  res.json({
    role: "doctor",
    msg: "Doctor dashboard data",
    userId: req.user.id
  });
});

router.get("/patient",auth,role("patient"),(req,res)=>{
  res.json({
    role: "patient",
    msg: "Patient dashboard data",
    userId: req.user.id
  });
});

router.get("/caregiver",auth,role("caregiver"),(req,res)=>{
  res.json({
    role: "caregiver",
    msg: "Caregiver dashboard data",
    userId: req.user.id
  });
});

module.exports=router;