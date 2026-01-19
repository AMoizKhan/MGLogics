// frontend/components/Dashboard.jsx
import React, { useState, useEffect } from 'react';
import { 
  Page, 
  Card, 
  Select, 
  List, 
  Button, 
  Spinner,
  Banner 
} from '@shopify/polaris';
import StoreSelector from './StoreSelector';
import ProductList from './ProductList';

const Dashboard = () => {
  const [stores, setStores] = useState([]);
  const [selectedStore, setSelectedStore] = useState('');
  const [products, setProducts] = useState([]);
  const [selectedProducts, setSelectedProducts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [syncStatus, setSyncStatus] = useState(null);

  useEffect(() => {
    fetchStores();
    fetchProducts();
  }, []);

  const fetchStores = async () => {
    try {
      const response = await fetch('/api/stores');
      const data = await response.json();
      setStores(data.stores);
    } catch (error) {
      console.error('Error fetching stores:', error);
    }
  };

  const fetchProducts = async () => {
    setIsLoading(true);
    try {
      const response = await fetch('/api/products');
      const data = await response.json();
      setProducts(data.products);
    } catch (error) {
      console.error('Error fetching products:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSync = async () => {
    setSyncStatus({ type: 'info', message: 'Starting sync...' });
    
    try {
      const response = await fetch('/api/sync', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          target_store_id: selectedStore,
          product_ids: selectedProducts
        })
      });

      const data = await response.json();
      
      if (data.success) {
        setSyncStatus({ 
          type: 'success', 
          message: data.message 
        });
        setSelectedProducts([]);
      } else {
        setSyncStatus({ 
          type: 'error', 
          message: data.error || 'Sync failed' 
        });
      }
    } catch (error) {
      setSyncStatus({ 
        type: 'error', 
        message: 'Network error occurred' 
      });
    }
  };

  return (
    <Page title="Product Sync Dashboard">
      {syncStatus && (
        <Banner
          title={syncStatus.message}
          status={syncStatus.type}
          onDismiss={() => setSyncStatus(null)}
        />
      )}

      <Card sectioned>
        <StoreSelector
          stores={stores}
          selectedStore={selectedStore}
          onStoreSelect={setSelectedStore}
        />
      </Card>

      {selectedStore && (
        <Card sectioned title="Select Products to Sync">
          {isLoading ? (
            <Spinner accessibilityLabel="Loading products" />
          ) : (
            <>
              <ProductList
                products={products}
                selectedProducts={selectedProducts}
                onProductToggle={(productId) => {
                  setSelectedProducts(prev => 
                    prev.includes(productId)
                      ? prev.filter(id => id !== productId)
                      : [...prev, productId]
                  );
                }}
              />
              
              <div style={{ marginTop: '20px' }}>
                <Button
                  primary
                  onClick={handleSync}
                  disabled={selectedProducts.length === 0}
                  loading={syncStatus?.type === 'info'}
                >
                  Sync {selectedProducts.length} Products
                </Button>
              </div>
            </>
          )}
        </Card>
      )}
    </Page>
  );
};

export default Dashboard;