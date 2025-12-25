const mongoose = require("mongoose");
const { v4: uuidv4 } = require("uuid");

const PatientSchema = new mongoose.Schema({
  // Unique QR Code ID for patient identification
  qrCodeId: {
    type: String,
    unique: true,
    default: () => uuidv4(),
  },

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

  phone: {
    type: String,
  },

  gender: {
    type: String,
    enum: ["male", "female", "other"],
    required: true,
  },

  age: {
    type: Number,
    required: true,
  },

  bloodGroup: {
    type: String,
    enum: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"],
    required: true,
  },

  address: {
    type: String,
  },

  emergencyContact: {
    name: String,
    phone: String,
    relation: String,
  },

  medicalHistory: {
    allergies: [String],
    chronicConditions: [String],
    medications: [String],
  },

  // Associated doctors with their specializations
  associatedDoctors: [
    {
      doctorId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Doctor",
      },
      specialization: String,
      associatedAt: {
        type: Date,
        default: Date.now,
      },
      isActive: {
        type: Boolean,
        default: true,
      },
    },
  ],

  // Associated caretakers
  associatedCaretakers: [
    {
      caretakerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Caretaker",
      },
      relation: String,
      associatedAt: {
        type: Date,
        default: Date.now,
      },
      isActive: {
        type: Boolean,
        default: true,
      },
    },
  ],

  createdAt: {
    type: Date,
    default: Date.now,
  },

  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Update timestamp on save
PatientSchema.pre("save", function () {
  this.updatedAt = Date.now();
});

// Method to check if associated with a specific doctor
PatientSchema.methods.isAssociatedWithDoctor = function (doctorId) {
  return this.associatedDoctors.some(
    (assoc) =>
      assoc.doctorId.toString() === doctorId.toString() && assoc.isActive
  );
};

// Method to check if associated with a specific caretaker
PatientSchema.methods.isAssociatedWithCaretaker = function (caretakerId) {
  return this.associatedCaretakers.some(
    (assoc) =>
      assoc.caretakerId.toString() === caretakerId.toString() && assoc.isActive
  );
};

module.exports = mongoose.model("Patient", PatientSchema);
