const { DataTypes } = require('sequelize');

const BasketItemModel = (sequelize) => {
  const BasketItem = sequelize.define('BasketItem', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    basketId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    productId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1
    }
  }, {
    tableName: 'basket_items',
    timestamps: true
  });

  return BasketItem;
};

module.exports = BasketItemModel;
