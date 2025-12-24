const mongoose=require("mongoose");

const UserSchema=new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    unique: true,
    required: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ["patient","doctor","caregiver","admin"],
    default: "patient"
  },
  language: {
    type: String,
    default: "en"
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports=mongoose.model("User",UserSchema);
