const mongoose = require("mongoose");

const CaretakerSchema = new mongoose.Schema({
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

  // Professional caretaker details
  qualification: {
    type: String,
  },

  experience: {
    type: Number, // years of experience
    default: 0,
  },

  specializations: [
    {
      type: String,
      enum: [
        "elderly_care",
        "pediatric_care",
        "post_surgery_care",
        "chronic_illness_care",
        "mental_health_care",
        "disability_care",
        "palliative_care",
        "general",
      ],
    },
  ],

  availability: {
    type: String,
    enum: ["full_time", "part_time", "on_call"],
    default: "full_time",
  },

  // Associated patients
  associatedPatients: [
    {
      patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Patient",
      },
      patientQrCodeId: String,
      relation: {
        type: String,
        enum: ["family", "professional", "other"],
        default: "professional",
      },
      responsibilities: [String],
      notes: String,
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
CaretakerSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

// Method to check if associated with a specific patient
CaretakerSchema.methods.isAssociatedWithPatient = function (patientId) {
  return this.associatedPatients.some(
    (assoc) =>
      assoc.patientId.toString() === patientId.toString() && assoc.isActive
  );
};

// Method to add a patient via QR code scan
CaretakerSchema.methods.addPatientByQr = async function (
  patient,
  relation = "professional",
  notes = ""
) {
  const existingAssoc = this.associatedPatients.find(
    (assoc) => assoc.patientId.toString() === patient._id.toString()
  );

  if (existingAssoc) {
    // Reactivate if was previously deactivated
    existingAssoc.isActive = true;
    if (notes) existingAssoc.notes = notes;
    if (relation) existingAssoc.relation = relation;
  } else {
    this.associatedPatients.push({
      patientId: patient._id,
      patientQrCodeId: patient.qrCodeId,
      relation,
      notes,
      associatedAt: Date.now(),
      isActive: true,
    });
  }

  return this.save();
};

module.exports = mongoose.model("Caretaker", CaretakerSchema);
