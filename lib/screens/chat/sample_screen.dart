// // 1. User Model - Stores user information
// import 'package:flutter/material.dart';

// const UserSchema = new mongoose.Schema({
//   phoneNumber: {
//     type: String,
//     required: true,
//     unique: true
//   },
//   name: {
//     type: String,
//     required: true
//   },
//   profilePicture: String,
//   about: String,
//   lastSeen: Date,
//   isOnline: Boolean,
//   settings: {
//     privacy: {
//       lastSeen: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       },
//       profilePhoto: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       },
//       status: {
//         type: String,
//         enum: ['everyone', 'contacts', 'nobody'],
//         default: 'everyone'
//       }
//     },
//     notifications: {
//       messagePreview: Boolean,
//       messageSound: Boolean,
//       groupSound: Boolean
//     }
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // 2. Chat Model - Stores chat metadata between two users
// const ChatSchema = new mongoose.Schema({
//   participants: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true
//   }],
//   chatType: {
//     type: String,
//     enum: ['individual', 'group'],
//     default: 'individual'
//   },
//   lastMessage: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Message'
//   },
//   unreadCounts: {
//     type: Map,
//     of: Number,
//     default: {}  // Stores unread counts for each participant
//   },
//   meta: {
//     type: Map,
//     of: {
//       archived: Boolean,
//       muted: Boolean,
//       pinnedAt: Date,
//       customNotification: String,
//       wallpaper: String
//     },
//     default: {}  // Stores per-user chat settings
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   },
//   updatedAt: {
//     type: Date,
//     default: Date.now
//   }
// }, {
//   timestamps: true
// });

// // 3. Message Model - Stores actual messages
// const MessageSchema = new mongoose.Schema({
//   chatId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Chat',
//     required: true,
//     index: true  // For faster queries
//   },
//   sender: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User',
//     required: true
//   },
//   messageType: {
//     type: String,
//     enum: ['text', 'image', 'video', 'audio', 'document', 'location', 'contact', 'sticker'],
//     default: 'text'
//   },
//   content: {
//     text: String,
//     caption: String,
//     mediaUrl: String,
//     thumbnail: String,
//     mimeType: String,
//     fileName: String,
//     fileSize: Number,
//     duration: Number,  // For audio/video
//     location: {
//       latitude: Number,
//       longitude: Number,
//       address: String
//     },
//     contact: {
//       name: String,
//       phoneNumbers: [String],
//       email: String
//     }
//   },
//   quotedMessage: {
//     messageId: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'Message'
//     },
//     content: String,
//     type: String
//   },
//   readBy: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     readAt: Date
//   }],
//   deliveredTo: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     deliveredAt: Date
//   }],
//   status: {
//     type: String,
//     enum: ['sent', 'delivered', 'read'],
//     default: 'sent'
//   },
//   deletedFor: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   }],
//   starredBy: [{
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   }],
//   forwarded: {
//     type: Boolean,
//     default: false
//   },
//   forwardCount: {
//     type: Number,
//     default: 0
//   },
//   reactions: [{
//     user: {
//       type: mongoose.Schema.Types.ObjectId,
//       ref: 'User'
//     },
//     emoji: String,
//     addedAt: {
//       type: Date,
//       default: Date.now
//     }
//   }],
//   createdAt: {
//     type: Date,
//     default: Date.now,
//     index: true  // For faster queries
//   }
// }, {
//   timestamps: true
// });

// // 4. Media Model - Stores media file references
// const MediaSchema = new mongoose.Schema({
//   messageId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Message',
//     required: true
//   },
//   chatId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Chat',
//     required: true
//   },
//   type: {
//     type: String,
//     enum: ['image', 'video', 'audio', 'document'],
//     required: true
//   },
//   url: {
//     type: String,
//     required: true
//   },
//   thumbnail: String,
//   mimeType: String,
//   fileName: String,
//   fileSize: Number,
//   duration: Number,  // For audio/video
//   dimensions: {
//     width: Number,
//     height: Number
//   },
//   uploadedBy: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'User'
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now
//   }
// });

// // Create indexes for better query performance
// ChatSchema.index({ participants: 1 });
// ChatSchema.index({ updatedAt: -1 });
// MessageSchema.index({ chatId: 1, createdAt: -1 });
// MessageSchema.index({ sender: 1 });
// MediaSchema.index({ messageId: 1 });
// MediaSchema.index({ chatId: 1, type: 1 });






// // Socket.IO handlers
// io.on('connection', (socket) => {
//     socket.on('init', async (userId) => {
//         clients[userId] = socket;
        
//         // Update user online status
//         await User.findByIdAndUpdate(userId, {
//             isOnline: true,
//             lastSeen: new Date()
//         });

//         // Notify user's contacts
//         const userChats = await Chat.find({ participants: userId });
//         userChats.forEach(chat => {
//             const otherParticipant = chat.participants.find(p => p.toString() !== userId.toString());
//             if (clients[otherParticipant]) {
//                 clients[otherParticipant].emit('user_online', userId);
//             }
//         });
//     });

//     socket.on('typing', async (data) => {
//         const { chatId, userId } = data;
//         const chat = await Chat.findById(chatId);
//         if (chat) {
//             chat.participants.forEach(participantId => {
//                 if (participantId.toString() !== userId.toString() && clients[participantId]) {
//                     clients[participantId].emit('typing_status', {
//                         chatId,
//                         userId,
//                         isTyping: true
//                     });
//                 }
//             });
//         }
//     });

//     socket.on('disconnect', async () => {
//         const userId = Object.keys(clients).find(key => clients[key] === socket);
//         if (userId) {
//             delete clients[userId];
            
//             // Update user status
//             await User.findByIdAndUpdate(userId, {
//                 isOnline: false,
//                 lastSeen: new Date()
//             });

//             // Notify user's contacts
//             const userChats = await Chat.find({ participants: userId });
//             userChats.forEach(chat => {
//                 const otherParticipant = chat.participants.find(p => p.toString() !== userId.toString());
//                 if (clients[otherParticipant]) {
//                     clients[otherParticipant].emit('user_offline', {
//                         userId,
//                         lastSeen: new Date()
//                     });
//                 }
//             });
//         }
//     });
// });









