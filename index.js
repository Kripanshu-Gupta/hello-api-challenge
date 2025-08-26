import express from 'express';

const app = express();

app.get('/sayHello', (req, res) => {
  res.json({ message: 'Hello User.' });
});

const PORT = 80; // requirement: must run on port 80
app.listen(PORT, () => {
  console.log(`[hello-api] listening on port ${PORT}`);
});