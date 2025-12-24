const express=require("express");
const router=express.Router();

const auth=require("../middleware/auth");
const DailyLog=require("../models/dailylog");

router.post("/dailylogs",auth,async (req,res)=>{
  const logs=req.body.logs; // array

  if (!Array.isArray(logs)) {
    return res.status(400).json({ msg: "Logs must be an array" });
  }

  let synced=0;

  for (const log of logs) {
    await DailyLog.updateOne(
      { clientId: log.clientId },
      {
        $setOnInsert: {
          ...log,
          patientId: req.user.id,
          syncedAt: new Date()
        }
      },
      { upsert: true }
    );
    synced++;
  }

  res.json({
    msg: "Sync successful",
    syncedCount: synced
  });
});

module.exports=router;
