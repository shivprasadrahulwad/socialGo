const mongoose = require('mongoose');
const { ObjectId } = mongoose.Schema.Types;

const chatSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['individual', 'group'],
    required: true
  },
  participants: [{
    userId: {
      type: ObjectId,  // Changed from String to ObjectId
      ref: 'User',
      required: true
    },
    role: {
      type: String,
      enum: ['admin', 'member'],
      default: 'member'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    }
  }],
  // Group specific fields
  name: String,
  description: String,
  groupPicture: String,
  createdBy: {
    type: ObjectId,  // Changed from String to ObjectId
    ref: 'User'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  settings: {
    onlyAdminsCanMessage: {
      type: Boolean,
      default: false
    },
    onlyAdminsCanEditInfo: {
      type: Boolean,
      default: true
    }
  }
});

const Chat = mongoose.model('Chat', chatSchema);

module.exports = Chat;