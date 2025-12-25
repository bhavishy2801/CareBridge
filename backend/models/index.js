/**
 * CareBridge Models Index
 * v2.0 - Separate user models with associations
 */

const Patient = require("./patient");
const Doctor = require("./doctor");
const Caretaker = require("./caretaker");
const Association = require("./association");
const Message = require("./message");

// Legacy model (deprecated)
const User = require("./user");

// Other models
const Appointment = require("./appointment");
const CarePlan = require("./careplan");
const DailyLog = require("./dailylog");
const Notification = require("./notification");
const PreVisit = require("./previsit");

module.exports = {
  // v2.0 User Models
  Patient,
  Doctor,
  Caretaker,

  // v2.0 New Models
  Association,
  Message,

  // Legacy (deprecated)
  User,

  // Existing Models
  Appointment,
  CarePlan,
  DailyLog,
  Notification,
  PreVisit,
};
