const { DataTypes } = require('sequelize');

const ProductModel = (sequelize) => {
  const Product = sequelize.define('Product', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING(128),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0
    },
    category: {
      type: DataTypes.STRING(64),
      allowNull: false
    },
    harvestDate: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    farmerId: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    unit: {
      type: DataTypes.STRING(32),
      allowNull: false,
      defaultValue: 'kg'
    },
    imageUrl: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    isModerated: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    }
  }, {
    tableName: 'products',
    timestamps: true
  });

  return Product;
};

module.exports = ProductModel;
