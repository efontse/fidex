const { DataTypes } = require('sequelize');

const ValueChainEventModel = (sequelize) => {
  const ValueChainEvent = sequelize.define('ValueChainEvent', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    farmerId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    status: {
      type: DataTypes.STRING(64),
      allowNull: false
      // e.g. "Planted", "Harvested", "Graded & Sorted", "Quality Checked", "Packaged", "Cold Storage", "Ready for Pickup"
    },
    timestamp: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'value_chain_events',
    timestamps: true
  });

  return ValueChainEvent;
};

module.exports = ValueChainEventModel;
