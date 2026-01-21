import React, { useState, useEffect } from 'react';
import {
  Page,
  Card,
  Layout,
  ResourceList,
  TextStyle,
  Thumbnail,
  Badge,
  Button,
  Select,
  FormLayout,
  Spinner,
} from '@shopify/polaris';
import axios from 'axios';

const ProductPicker = () => {
  const [stores, setStores] = useState([]);
  const [selectedStore, setSelectedStore] = useState('');
  const [products, setProducts] = useState([]);
  const [selectedProducts, setSelectedProducts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [syncing, setSyncing] = useState(false);

  useEffect(() => {
    fetchStores();
    fetchProducts();
  }, []);

  const fetchStores = async () => {
    try {
      const response = await axios.get('/stores');
      setStores(response.data);
    } catch (error) {
      console.error('Error fetching stores:', error);
    }
  };

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const response = await axios.get('/products');
      setProducts(response.data.products || []);
    } catch (error) {
      console.error('Error fetching products:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStoreSelect = (value) => {
    setSelectedStore(value);
    setSelectedProducts([]);
  };

  const handleProductSelect = (productId) => {
    setSelectedProducts(prev => {
      if (prev.includes(productId)) {
        return prev.filter(id => id !== productId);
      } else {
        return [...prev, productId];
      }
    });
  };

  const syncProducts = async () => {
    if (!selectedStore || selectedProducts.length === 0) return;

    setSyncing(true);
    try {
      await axios.post('/products/sync', {
        target_store_id: selectedStore,
        product_ids: selectedProducts
      });
      
      alert(`${selectedProducts.length} products synced successfully!`);
      setSelectedProducts([]);
    } catch (error) {
      console.error('Error syncing products:', error);
      alert('Error syncing products');
    } finally {
      setSyncing(false);
    }
  };

  const storeOptions = stores.map(store => ({
    label: store.name,
    value: store.id.toString()
  }));

  return (
    <Page
      title="Sync Products"
      primaryAction={{
        content: 'Sync Selected Products',
        onAction: syncProducts,
        disabled: !selectedStore || selectedProducts.length === 0 || syncing,
        loading: syncing,
      }}
    >
      <Layout>
        <Layout.Section>
          <Card>
            <Card.Section>
              <FormLayout>
                <Select
                  label="Select Target Store"
                  options={storeOptions}
                  value={selectedStore}
                  onChange={handleStoreSelect}
                  placeholder="Choose a store to sync to"
                />
                
                {selectedStore && (
                  <div style={{ marginTop: '16px' }}>
                    <TextStyle variation="subdued">
                      Selected: {storeOptions.find(s => s.value === selectedStore)?.label}
                    </TextStyle>
                  </div>
                )}
              </FormLayout>
            </Card.Section>
          </Card>
        </Layout.Section>

        <Layout.Section>
          <Card>
            <Card.Section>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <TextStyle variation="strong">Your Products</TextStyle>
                <Badge status="info">
                  {selectedProducts.length} selected
                </Badge>
              </div>
            </Card.Section>
            
            <Card.Section>
              {loading ? (
                <div style={{ textAlign: 'center', padding: '40px' }}>
                  <Spinner size="large" />
                </div>
              ) : (
                <ResourceList
                  resourceName={{ singular: 'product', plural: 'products' }}
                  items={products}
                  renderItem={(product) => {
                    const isSelected = selectedProducts.includes(product.id);
                    
                    return (
                      <ResourceList.Item
                        id={product.id}
                        onClick={() => handleProductSelect(product.id)}
                        selected={isSelected}
                        media={
                          <Thumbnail
                            source={product.images || 'https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png'}
                            alt={product.title}
                          />
                        }
                        accessibilityLabel={`Select ${product.title}`}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <div>
                            <TextStyle variation="strong">{product.title}</TextStyle>
                            <div style={{ marginTop: '4px' }}>
                              <TextStyle variation="subdued">
                                Type: {product.product_type || 'N/A'} | Vendor: {product.vendor || 'N/A'}
                              </TextStyle>
                            </div>
                          </div>
                          <Badge status={isSelected ? 'success' : 'new'}>
                            {isSelected ? 'Selected' : product.status}
                          </Badge>
                        </div>
                      </ResourceList.Item>
                    );
                  }}
                />
              )}
            </Card.Section>
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  );
};

export default ProductPicker;