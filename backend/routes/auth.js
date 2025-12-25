const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const {
  signup,
  login,
  getProfile,
  updateProfile,
  changePassword,
} = require("../controllers/authcontroller");

// Public routes
router.post("/signup", signup);
router.post("/login", login);

// Protected routes
router.get("/profile", auth, getProfile);
router.put("/profile", auth, updateProfile);
router.post("/change-password", auth, changePassword);

module.exports = router;
