import config from './config.js';
import axios from 'axios';
import { Redis } from '@upstash/redis';

const redis = new Redis({
  url: config.upstash_redis_rest_url,
  token: config.upstash_redis_rest_token,
});

export default async function handler(req, res) {
  const { token } = req.body;
  const resp = await axios.post(
    `https://www.google.com/recaptcha/api/siteverify?secret=${config.recaptcha_secret_key}&response=${token}`,
  );
  if (!resp.data) {
    return res
      .status(200)
      .send({ status: 9, msg: `Request reCAPTCHA siteverify failed.` });
  }

  let shortToken = token.slice(0, 30);
  let data = resp.data;
  data.token = shortToken;
  // await redis.set(shortToken, '1');
  await redis.hset('token', {
    [shortToken]: '1',
  });

  return res.status(200).json({ status: 200, data });
}
