const { DataTypes } = require('sequelize');

const DeliveryModel = (sequelize) => {
  const Delivery = sequelize.define('Delivery', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    orderId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true
    },
    logisticianId: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    pickupPoint: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    dropoffPoint: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    pickupCoordinates: {
      type: DataTypes.STRING(64),
      allowNull: true // e.g. "6.5244,3.3792"
    },
    dropoffCoordinates: {
      type: DataTypes.STRING(64),
      allowNull: true
    },
    estimatedDistanceKm: {
      type: DataTypes.FLOAT,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('pending', 'assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'),
      allowNull: false,
      defaultValue: 'pending'
    },
    deliveredAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'deliveries',
    timestamps: true
  });

  return Delivery;
};

module.exports = DeliveryModel;
