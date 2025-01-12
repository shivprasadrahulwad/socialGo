// models/Media.js
const mongoose = require('mongoose');

const MediaSchema = new mongoose.Schema({
  messageId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message',
    required: true
  },
  chatId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat',
    required: true
  },
  type: {
    type: String,
    enum: ['image', 'video', 'audio', 'document'],
    required: true
  },
  url: {
    type: String,
    required: true
  },
  fileName: String,
  fileSize: Number,
  duration: Number,
  dimensions: {
    width: Number,
    height: Number
  },
  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create indexes for better query performance
MediaSchema.index({ messageId: 1 });
MediaSchema.index({ chatId: 1, type: 1 });

module.exports = mongoose.model('Media', MediaSchema);
