const { DataTypes } = require('sequelize');

const SessionModel = (sequelize) => {
  const Session = sequelize.define('Session', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    otpCode: {
      type: DataTypes.STRING(16),
      allowNull: true
    },
    deviceId: {
      type: DataTypes.STRING(128),
      allowNull: true
    },
    failedAttempts: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    }
  }, {
    tableName: 'sessions',
    timestamps: true
  });

  return Session;
};

module.exports = SessionModel;
