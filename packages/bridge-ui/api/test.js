export default async function handler(req, res) {
  return res.status(200).send({ status: 200, data: `Hello world` });
}
