const express=require("express");
const cors=require("cors");

const app=express();

app.use(cors());
app.use(express.json());

app.use("/api/auth",require("./routes/auth"));
app.use("/api/dashboard",require("./routes/dashboard"));
app.use("/api/appointments",require("./routes/appointments"));
app.use("/api/previsit",require("./routes/previsit"));
app.use("/api/careplan",require("./routes/careplan"));
app.use("/api/dailylog",require("./routes/dailylog"));
app.use("/api/notifications",require("./routes/notifications"));
app.use("/api/sync",require("./routes/sync"));

app.get("/",(req,res)=>{
  res.send("CareBridge API Running");
});

module.exports=app;
