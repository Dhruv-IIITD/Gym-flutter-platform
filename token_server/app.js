require('dotenv').config();
const express = require('express');
const cors = require('cors');
const HMS = require('@100mslive/server-sdk');

const app = express();
app.use(cors());
app.use(express.json());

const hms = new HMS.SDK({
  accessKey: process.env.HMS_ACCESS_KEY,
  secret: process.env.HMS_SECRET,
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/token', async (req, res) => {
  try {
    const { userId, role, roomId } = req.query;
    if (!userId || !role || !roomId) {
      return res.status(400).json({ error: 'Missing userId, role, or roomId' });
    }
    const token = await hms.auth.getAuthToken({ roomId, role, userId });
    res.json({ token });
  } catch (error) {
    console.error('[TOKEN_SERVER] Error generating token:', error.message);
    res.status(500).json({ error: error.message });
  }
});

app.post('/create-room', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: 'Missing room name' });
    }
    const room = await hms.rooms.create({ name });
    res.json({
      roomId: room.id,
      name: room.name,
    });
  } catch (error) {
    console.error('[TOKEN_SERVER] Error creating room:', error.message);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`[TOKEN_SERVER] Running on http://localhost:${PORT}`);
});
