// // config/kafka.js
// const { Kafka, Partitioners } = require('kafkajs');  // Add Partitioners here

// const kafka = new Kafka({
//   clientId: 'chat-app',
//   brokers: ['localhost:9092'],
//   retry: {
//     initialRetryTime: 100,
//     retries: 8
//   }
// });

// // Create producer with legacy partitioner
// const producer = kafka.producer({
//   createPartitioner: Partitioners.LegacyPartitioner
// });
// const consumer = kafka.consumer({ groupId: 'chat-group' });

// module.exports = { kafka, producer, consumer };



// config/kafka.js
const { Kafka, Partitioners } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'chat-app',
  brokers: ['localhost:9092'],
  retry: {
    initialRetryTime: 300,
    retries: 10
  },
  connectionTimeout: 3000,
  authenticationTimeout: 3000,
});

const initializeKafka = async () => {
  try {
    // Create producer
    const producer = kafka.producer({
      createPartitioner: Partitioners.LegacyPartitioner,
      allowAutoTopicCreation: true
    });

    // Create consumer
    const consumer = kafka.consumer({ 
      groupId: 'chat-group',
      retry: {
        initialRetryTime: 300,
        retries: 10
      }
    });

    // Connect both
    await producer.connect();
    await consumer.connect();

    console.log('Kafka producer and consumer connected successfully');
    return { producer, consumer };
  } catch (error) {
    console.error('Failed to initialize Kafka:', error);
    return { producer: null, consumer: null };
  }
};

module.exports = { initializeKafka };