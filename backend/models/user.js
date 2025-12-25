/**
 * @deprecated This unified User model is deprecated in v2.0
 * Please use the separate models instead:
 * - Patient: ./patient.js
 * - Doctor: ./doctor.js
 * - Caretaker: ./caretaker.js
 *
 * This file is kept for backward compatibility with existing data.
 * New registrations should use the role-specific models.
 */

const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },

  email: {
    type: String,
    unique: true,
    required: true,
  },

  password: {
    type: String,
    required: true,
  },

  role: {
    type: String,
    enum: ["patient", "doctor", "caregiver", "admin"],
    required: true,
  },

  gender: {
    type: String,
    enum: ["male", "female", "other"],
    required: true,
  },

  age: {
    type: Number,
  },

  bloodGroup: {
    type: String,
    enum: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
  },

  specialization: {
    type: String,
    enum: [
      "ophthalmologist",
      "gynaecologist",
      "paediatrician",
      "general_surgeon",
      "physician",
      "orthopaedic",
      "dermatologist",
      "psychiatrist",
      "ent",
    ],
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("User", UserSchema);
