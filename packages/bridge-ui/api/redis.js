import Redis from 'redis';
import * as dotenv from 'dotenv';
const config = dotenv.config().parsed;

const redisClient = Redis.createClient({
  host: config.REDIS_HOST,
  port: config.REDIS_PORT,
  password: config.REDIS_PASSWORD,
  username: config.REDIS_USERNAME,
});

export default redisClient;
