const { DataTypes } = require('sequelize');

const UserModel = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    fullName: {
      type: DataTypes.STRING(128),
      allowNull: false
    },
    email: {
      type: DataTypes.STRING(128),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING(128),
      allowNull: false
    },
    phoneNumber: {
      type: DataTypes.STRING(32),
      allowNull: true
    },
    role: {
      type: DataTypes.ENUM('visitor', 'farmer', 'consumer', 'logistician', 'admin'),
      allowNull: false,
      defaultValue: 'consumer'
    },
    farmingField: {
      type: DataTypes.STRING(64),
      allowNull: true // For farmers: Pisciculture, Horticulture, Apiculture, Dairy Farming, Poultry Farm
    },
    companyName: {
      type: DataTypes.STRING(128),
      allowNull: true // For logisticians: company where they work
    },
    address: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true
    }
  }, {
    tableName: 'users',
    timestamps: true
  });

  return User;
};

module.exports = UserModel;
