// const Message = require('../models/message');
// const { producer } = require('../kafka_config/kafka');


// class MessageService {
//   static async saveMessage(messageData) {
//     try {
//       const message = new Message({
//         messageId: messageData.messageId,
//         senderId: messageData.sourceId,
//         receiverId: messageData.targetId,
//         content: messageData.message,
//         mediaPath: messageData.path || '',
//         messageType: messageData.messageType || 'text',
//         callDuration: messageData.duration || null,
//       });

//       await message.save();

//       // Produce Kafka event for message creation
//       await producer.send({
//         topic: 'new-messages',
//         messages: [
//           {
//             key: message.messageId,
//             value: JSON.stringify(messageData),
//           },
//         ],
//       });

//       return message;
//     } catch (error) {
//       console.error('Error saving message:', error);
//       throw error;
//     }
//   }

//   static async markAsRead(messageId, readAt = new Date()) {
//     try {
//       const message = await Message.findOneAndUpdate(
//         { messageId },
//         { 
//           isRead: true, 
//           readAt 
//         },
//         { new: true }
//       );

//       if (message) {
//         // Produce Kafka event for read receipt
//         await producer.send({
//           topic: 'read-receipts',
//           messages: [
//             {
//               key: messageId,
//               value: JSON.stringify({
//                 messageId,
//                 readAt,
//                 senderId: message.senderId,
//                 receiverId: message.receiverId,
//               }),
//             },
//           ],
//         });
//       }

//       return message;
//     } catch (error) {
//       console.error('Error marking message as read:', error);
//       throw error;
//     }
//   }

//   static async getConversationMessages(senderId, receiverId, page = 1, limit = 50) {
//     try {
//       const messages = await Message.find({
//         $or: [
//           { senderId, receiverId },
//           { senderId: receiverId, receiverId: senderId }
//         ]
//       })
//         .sort({ createdAt: -1 })
//         .skip((page - 1) * limit)
//         .limit(limit)
//         .lean();

//       return messages.reverse();
//     } catch (error) {
//       console.error('Error fetching conversation:', error);
//       throw error;
//     }
//   }

//   static async getUnreadMessagesCount(userId) {
//     try {
//       return await Message.countDocuments({
//         receiverId: userId,
//         isRead: false
//       });
//     } catch (error) {
//       console.error('Error counting unread messages:', error);
//       throw error;
//     }
//   }
// }

// module.exports = MessageService;