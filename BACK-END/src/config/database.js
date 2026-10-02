const { Sequelize } = require('sequelize');
const mysql = require('mysql2/promise');
const config = require('./config');

/**
 * Ensures the target MySQL database exists in MySQL server before Sequelize connects
 */
const ensureDatabaseExists = async () => {
  try {
    const connection = await mysql.createConnection({
      host: config.db.host,
      port: config.db.port,
      user: config.db.user,
      password: config.db.password
    });

    await connection.query(
      `CREATE DATABASE IF NOT EXISTS \`${config.db.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
    );
    console.log(`[Database] MySQL database '${config.db.database}' verified/created.`);
    await connection.end();
  } catch (err) {
    console.warn(`[Database Warning] Could not auto-create MySQL database '${config.db.database}':`, err.message);
    console.warn(`[Database Hint] Please ensure MySQL is running on port ${config.db.port}.`);
  }
};

const sequelize = new Sequelize(
  config.db.database,
  config.db.user,
  config.db.password,
  {
    host: config.db.host,
    port: config.db.port,
    dialect: 'mysql',
    logging: false,
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    define: {
      charset: 'utf8mb4',
      collate: 'utf8mb4_unicode_ci'
    }
  }
);

/**
 * Connect to MySQL database
 */
const connectDatabase = async () => {
  try {
    await ensureDatabaseExists();
    await sequelize.authenticate();
    console.log(`[Database] Connected successfully via MySQL on ${config.db.host}:${config.db.port} (database: ${config.db.database})`);
    return sequelize;
  } catch (error) {
    console.error(`[Database] Connection error:`, error.message);
    console.error(`[Database Hint] MySQL server is unreachable on ${config.db.host}:${config.db.port}. Please ensure your MySQL service (e.g., XAMPP, WAMP, or Windows MySQL service) is started.`);
    throw error;
  }
};

module.exports = {
  sequelize,
  connectDatabase,
  ensureDatabaseExists
};
