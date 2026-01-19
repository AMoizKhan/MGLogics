// frontend/components/ProductList.jsx
import React from 'react';
import { ResourceList, Checkbox, Thumbnail } from '@shopify/polaris';

const ProductList = ({ products, selectedProducts, onProductToggle }) => {
  return (
    <ResourceList
      resourceName={{ singular: 'product', plural: 'products' }}
      items={products}
      renderItem={(product) => {
        const { id, title, price, image } = product;
        const isSelected = selectedProducts.includes(id);
        
        return (
          <ResourceList.Item
            id={id.toString()}
            media={
              image ? (
                <Thumbnail
                  source={image}
                  alt={title}
                />
              ) : null
            }
            accessibilityLabel={`Select ${title}`}
          >
            <div style={{ display: 'flex', alignItems: 'center', width: '100%' }}>
              <Checkbox
                label=""
                checked={isSelected}
                onChange={() => onProductToggle(id)}
              />
              <div style={{ marginLeft: '12px', flex: 1 }}>
                <h3>{title}</h3>
                <p>${price}</p>
              </div>
            </div>
          </ResourceList.Item>
        );
      }}
    />
  );
};

export default ProductList;