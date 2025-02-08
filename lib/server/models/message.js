// const mongoose = require('mongoose');

// const messageSchema = new mongoose.Schema({
//     messageId: {
//         type: String,
//         required: true,
//         unique: true,  // This creates an index automatically
//         default: () => new mongoose.Types.ObjectId().toString()
//     },
//     chatId: {
//         type: String,
//         required: true
//     },
//     senderId: {
//         type: String,
//         required: true
//     },
//     type: {
//         type: String,
//         required: true,
//         enum: ['text', 'image', 'video', 'audio', 'document']
//     },
//     content: {
//         text: String,
//         mediaUrl: String,
//         thumbnail: String,
//         fileName: String,
//         fileSize: Number,
//         duration: Number,
//         contactInfo: {
//             name: String,
//             phoneNumber: String
//         }
//     },
//     replyTo: {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'Message'
//     },
//     forwardedFrom: {
//         type: mongoose.Schema.Types.ObjectId,
//         ref: 'Message'
//     },
//     readBy: [{
//         userId: String,
//         readAt: {
//             type: Date,
//             default: Date.now
//         }
//     }],
//     deliveredTo: [{
//         userId: String,
//         deliveredAt: {
//             type: Date,
//             default: Date.now
//         }
//     }],
//     status: {
//         type: String,
//         enum: ['sending', 'sent', 'delivered', 'read', 'failed'],
//         default: 'sent'
//     },
//     createdAt: {
//         type: Date,
//         default: Date.now
//     },
//     reactions: [{
//         user: String,
//         emoji: String,
//         addedAt: {
//             type: Date,
//             default: Date.now
//         }
//     }],
//     isDeleted: {
//         type: Boolean,
//         default: false
//     },
//     deletedFor: [{
//         userId: String,
//         deletedAt: {
//             type: Date,
//             default: Date.now
//         }
//     }]
// });

// // Only add the compound index, since unique: true on messageId already creates its index
// messageSchema.index({ chatId: 1, createdAt: -1 });

// module.exports = mongoose.model('Message', messageSchema);





const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    messageId: {
        type: String,
        required: true,
        unique: true, 
    },
    chatId: {
        type: String,
        required: true
    },
    senderId: {
        type: String,
        required: true
    },
    type: {
        type: String,
        required: true,
        enum: ['text', 'image', 'video', 'audio', 'document']
    },
    content: {
        text: String,
        mediaUrl: String,
        thumbnail: String,
        fileName: String,
        fileSize: Number,
        duration: Number,
        contactInfo: {
            name: String,
            phoneNumber: String
        }
    },
    replyTo: {
        type: String,
        ref: 'Message'
    },
    forwardedFrom: {
        type: String,
        ref: 'Message'
    },
    readBy: [{
        userId: String,
        readAt: {
            type: Date,
            default: Date.now
        }
    }],
    deliveredTo: [{
        userId: String,
        deliveredAt: {
            type: Date,
            default: Date.now
        }
    }],
    status: {
        type: String,
        enum: ['sending', 'sent', 'delivered', 'read', 'failed'],
        default: 'sent'
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    reactions: [{
        user: String,
        emoji: String,
        addedAt: {
            type: Date,
            default: Date.now
        }
    }],
    isDeleted: {
        type: Boolean,
        default: false
    },
    deletedFor: [{
        userId: String,
        deletedAt: {
            type: Date,
            default: Date.now
        }
    }]
});

// Only add the compound index, since unique: true on messageId already creates its index
messageSchema.index({ chatId: 1, createdAt: -1 });

module.exports = mongoose.model('Message', messageSchema);