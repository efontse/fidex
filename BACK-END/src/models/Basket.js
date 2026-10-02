const { DataTypes } = require('sequelize');

const BasketModel = (sequelize) => {
  const Basket = sequelize.define('Basket', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    consumerId: {
      type: DataTypes.INTEGER,
      allowNull: false
    }
  }, {
    tableName: 'baskets',
    timestamps: true
  });

  return Basket;
};

module.exports = BasketModel;
