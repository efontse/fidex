const app = require('./app');
const config = require('./config/config');
const { connectDatabase, sequelize } = require('./models');

const startServer = async () => {
  try {
    // 1. Establish database connection
    await connectDatabase();

    // 2. Synchronize Sequelize models with schema
    await sequelize.sync({ alter: false });
    console.log('[Database] All models synchronized successfully.');

    // 3. Start Express server
    const server = app.listen(config.port, '0.0.0.0', () => {
      console.log(`====================================================`);
      console.log(`  🌾 Farmora Agricultural Platform Backend Online!  `);
      console.log(`  🚀 Port: ${config.port} | Mode: ${config.nodeEnv} `);
      console.log(`  🔗 Health Check: http://localhost:${config.port}/api/health`);
      console.log(`====================================================`);
    });

    return server;
  } catch (error) {
    console.error('[Server] Fatal startup error:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  startServer();
}

module.exports = { startServer };
