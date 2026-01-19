// frontend/components/StoreSelector.jsx
import React from 'react';
import { Select } from '@shopify/polaris';

const StoreSelector = ({ stores, selectedStore, onStoreSelect }) => {
  const storeOptions = stores.map(store => ({
    label: store.domain,
    value: store.id.toString()
  }));

  return (
    <Select
      label="Select Target Store"
      options={[
        { label: 'Choose a store...', value: '' },
        ...storeOptions
      ]}
      onChange={onStoreSelect}
      value={selectedStore}
      disabled={stores.length === 0}
    />
  );
};

export default StoreSelector;