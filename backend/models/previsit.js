const mongoose=require("mongoose");

const PreVisitSchema=new mongoose.Schema({
    clientId: {
        type: String,
        unique: true,
        sparse: true
    },

    patientId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },

    appointmentId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Appointment",
        required: true,
        unique: true
    },

    symptoms: [
        {
            name: {
                type: String,
                required: true
            },
            severity: {
                type: Number,
                min: 1,
                max: 10,
                required: true
            },
            duration: {
                type: String
            }
        }
    ],

    reports: [
        {
            fileName: String,
            fileUrl: String
        }
    ],

    notes: {
        type: String
    },

    submittedAt: {
        type: Date,
        default: Date.now
    },

    syncedAt: {
        type: Date,
        default: Date.now
    }
});

module.exports=mongoose.model("PreVisit",PreVisitSchema);
