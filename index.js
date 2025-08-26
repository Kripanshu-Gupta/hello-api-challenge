import express from 'express';

const app = express();

// Main API route
app.get('/sayHello', (req, res) => {
  res.json({ message: 'Hello User.' });
});

// Health check route (for monitoring / deploy checks)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    time: new Date().toISOString()
  });
});

const PORT = 80; // requirement: must run on port 80

// Start server
const server = app.listen(PORT, () => {
  console.log(`[hello-api] listening on port ${PORT}`);
});

// Improve keepalive for graceful reloads
server.keepAliveTimeout = 5000;
server.headersTimeout = 60000;

// Graceful shutdown
function gracefulShutdown(signal) {
  console.log(`[hello-api] ${signal} received. Closing server gracefully...`);
  server.close(() => {
    console.log('[hello-api] Server closed.');
    process.exit(0);
  });

  // Force exit if not closing within 30s
  setTimeout(() => {
    console.error('[hello-api] Forced shutdown after 30s');
    process.exit(1);
  }, 30000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
