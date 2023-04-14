import config from './config.js';
import axios from 'axios';
import client from './redis.js';

export default async function handler(req, res) {
  const { token } = req.body;
  const resp = await axios.post(
    `https://www.google.com/recaptcha/api/siteverify?secret=${config.RECAPTCHA_SECRET_KEY}&response=${token}`,
  );
  if (!resp.data) {
    return res
      .status(200)
      .send({ status: 9, msg: `Request reCAPTCHA siteverify failed.` });
  }
  try {
    await client.connect();
  } catch (error) {
    return res
      .status(200)
      .send({ status: 80, msg: `Redis connection failed: ${error}` });
  }

  let shortToken = token.slice(0, 30);
  let data = resp.data;
  data.token = shortToken;
  await client.set(shortToken, '1');
  return res.status(200).json({ status: 200, data });
}
