const mongoose = require('mongoose');
const { ObjectId } = mongoose.Schema.Types;

const blockedUserSchema = new mongoose.Schema({
  userId: {
    type: ObjectId,
    ref: 'User',
    required: true
  },
  blockedAt: {
    type: Date,
    default: Date.now
  }
});

const chatSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['individual', 'group'],
    required: true
  },
  hide:{
    type: Boolean,
    required: true,
    default: false,
  },

  hidePass: {
    type: String,
    default: ''
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
    password:{
      type: String,
      required: true,
      default: '###**###'
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
    },
    blockedUsers: [blockedUserSchema]
  }
  
});




chatSchema.methods.isUserBlocked = function(userId) {
  return this.settings.blockedUsers.some(user => 
    user.userId.toString() === userId.toString()
  );
};

chatSchema.methods.blockUser = function(userId) {
  if (!this.isUserBlocked(userId)) {
    this.settings.blockedUsers.push({
      userId,
      blockedAt: new Date()
    });
  }
  return this;
};

chatSchema.methods.unblockUser = function(userId) {
  this.settings.blockedUsers = this.settings.blockedUsers.filter(
    user => user.userId.toString() !== userId.toString()
  );
  return this;
};

const Chat = mongoose.model('Chat', chatSchema);

module.exports = Chat;