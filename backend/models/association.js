const mongoose = require("mongoose");

// This model maintains a centralized record of all associations
// for easier querying and management
const AssociationSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Patient",
    required: true,
  },

  patientQrCodeId: {
    type: String,
    required: true,
  },

  // The associated user (doctor or caretaker)
  associatedUserId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    refPath: "associatedUserType",
  },

  associatedUserType: {
    type: String,
    enum: ["Doctor", "Caretaker"],
    required: true,
  },

  // Association metadata
  status: {
    type: String,
    enum: ["pending", "active", "inactive", "rejected"],
    default: "active",
  },

  // How the association was created
  createdVia: {
    type: String,
    enum: ["qr_scan", "manual", "referral"],
    default: "qr_scan",
  },

  notes: {
    type: String,
  },

  // For doctors: specialization context
  specializationContext: {
    type: String,
  },

  // For caretakers: relation type
  relation: {
    type: String,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },

  updatedAt: {
    type: Date,
    default: Date.now,
  },

  deactivatedAt: {
    type: Date,
  },
});

// Compound index for unique active associations
AssociationSchema.index(
  { patientId: 1, associatedUserId: 1 },
  { unique: true }
);

// Index for quick lookups
AssociationSchema.index({ patientQrCodeId: 1 });
AssociationSchema.index({ associatedUserId: 1, associatedUserType: 1 });

// Update timestamp on save
AssociationSchema.pre("save", function (next) {
  this.updatedAt = Date.now();
  next();
});

// Static method to check if two users can communicate
AssociationSchema.statics.canCommunicate = async function (
  userId1,
  userType1,
  userId2,
  userType2
) {
  // One must be a patient, the other must be doctor or caretaker
  let patientId, associatedUserId, associatedUserType;

  if (userType1 === "Patient") {
    patientId = userId1;
    associatedUserId = userId2;
    associatedUserType = userType2;
  } else if (userType2 === "Patient") {
    patientId = userId2;
    associatedUserId = userId1;
    associatedUserType = userType1;
  } else {
    // Neither is a patient - they cannot chat
    return false;
  }

  // Check for active association
  const association = await this.findOne({
    patientId,
    associatedUserId,
    associatedUserType,
    status: "active",
  });

  return !!association;
};

// Static method to create association via QR scan
AssociationSchema.statics.createFromQrScan = async function (
  qrCodeId,
  scannerId,
  scannerType,
  notes = ""
) {
  const Patient = require("./patient");
  const Doctor = require("./doctor");
  const Caretaker = require("./caretaker");

  // Find patient by QR code
  const patient = await Patient.findOne({ qrCodeId });
  if (!patient) {
    throw new Error("Invalid QR code - Patient not found");
  }

  // Check if association already exists
  const existingAssoc = await this.findOne({
    patientId: patient._id,
    associatedUserId: scannerId,
    associatedUserType: scannerType,
  });

  if (existingAssoc) {
    if (existingAssoc.status === "active") {
      return {
        association: existingAssoc,
        isNew: false,
        message: "Association already exists",
      };
    }
    // Reactivate
    existingAssoc.status = "active";
    existingAssoc.updatedAt = Date.now();
    existingAssoc.deactivatedAt = null;
    await existingAssoc.save();
    return {
      association: existingAssoc,
      isNew: false,
      message: "Association reactivated",
    };
  }

  // Create new association
  const association = await this.create({
    patientId: patient._id,
    patientQrCodeId: qrCodeId,
    associatedUserId: scannerId,
    associatedUserType: scannerType,
    status: "active",
    createdVia: "qr_scan",
    notes,
  });

  // Update the respective models
  if (scannerType === "Doctor") {
    const doctor = await Doctor.findById(scannerId);
    if (doctor) {
      await doctor.addPatientByQr(patient, notes);
    }
    // Add doctor to patient's associated doctors
    patient.associatedDoctors.push({
      doctorId: scannerId,
      specialization: doctor?.specialization,
      associatedAt: Date.now(),
      isActive: true,
    });
    await patient.save();
  } else if (scannerType === "Caretaker") {
    const caretaker = await Caretaker.findById(scannerId);
    if (caretaker) {
      await caretaker.addPatientByQr(patient, "professional", notes);
    }
    // Add caretaker to patient's associated caretakers
    patient.associatedCaretakers.push({
      caretakerId: scannerId,
      relation: "professional",
      associatedAt: Date.now(),
      isActive: true,
    });
    await patient.save();
  }

  return {
    association,
    isNew: true,
    message: "Association created successfully",
  };
};

module.exports = mongoose.model("Association", AssociationSchema);
