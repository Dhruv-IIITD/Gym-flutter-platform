# WTF Token Server

Node.js helper service for 100ms development flows.

## Setup

```bash
npm install
cp .env.example .env
npm run dev
```

Set `HMS_ACCESS_KEY` and `HMS_SECRET` before creating rooms.

## Endpoints

- `GET /health`
- `GET /token?userId={userId}&role={role}&roomId={roomId}`
- `POST /create-room` with `{ "name": "call-request-id" }`
