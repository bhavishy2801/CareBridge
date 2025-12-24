const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const Notification=require("../models/notification");

router.get("/",auth,async (req,res)=>{
  const notes=await Notification.find({ userId: req.user.id });
  res.json(notes);
});

module.exports=router;
