const mongoose = require("mongoose");

const DoctorSchema = new mongoose.Schema({
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
      "cardiologist",
      "neurologist",
      "oncologist",
      "urologist",
      "nephrologist",
      "pulmonologist",
      "gastroenterologist",
      "endocrinologist",
      "rheumatologist",
    ],
    required: true,
  },

  qualifications: [
    {
      degree: String,
      institution: String,
      year: Number,
    },
  ],

  experience: {
    type: Number, // years of experience
    default: 0,
  },

  clinicAddress: {
    type: String,
  },

  consultationFee: {
    type: Number,
  },

  availableSlots: [
    {
      day: {
        type: String,
        enum: [
          "monday",
          "tuesday",
          "wednesday",
          "thursday",
          "friday",
          "saturday",
          "sunday",
        ],
      },
      startTime: String,
      endTime: String,
    },
  ],

  // Associated patients
  associatedPatients: [
    {
      patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Patient",
      },
      patientQrCodeId: String,
      diagnosis: String,
      notes: String,
      associatedAt: {
        type: Date,
        default: Date.now,
      },
      lastVisit: Date,
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
DoctorSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

// Method to check if associated with a specific patient
DoctorSchema.methods.isAssociatedWithPatient = function (patientId) {
  return this.associatedPatients.some(
    (assoc) =>
      assoc.patientId.toString() === patientId.toString() && assoc.isActive
  );
};

// Method to add a patient via QR code scan
DoctorSchema.methods.addPatientByQr = async function (patient, notes = "") {
  const existingAssoc = this.associatedPatients.find(
    (assoc) => assoc.patientId.toString() === patient._id.toString()
  );

  if (existingAssoc) {
    // Reactivate if was previously deactivated
    existingAssoc.isActive = true;
    existingAssoc.lastVisit = Date.now();
    if (notes) existingAssoc.notes = notes;
  } else {
    this.associatedPatients.push({
      patientId: patient._id,
      patientQrCodeId: patient.qrCodeId,
      notes,
      associatedAt: Date.now(),
      lastVisit: Date.now(),
      isActive: true,
    });
  }

  return this.save();
};

module.exports = mongoose.model("Doctor", DoctorSchema);
