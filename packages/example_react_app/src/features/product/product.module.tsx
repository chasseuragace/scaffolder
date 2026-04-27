/// Module exports for Product.
export * from './domain/entities/product.entity';
export * from './domain/repositories/product.repository';
export * from './domain/usecases/product.usecases';
export * from './data/models/product.model';
export * from './data/repositories/product.repository-impl';
export * from './data/repositories/product.repository-fake';
export * from './presentation/hooks/product.hooks';
export * from './presentation/product.repository-context';
export * from './presentation/pages/product-list-page';
export * from './presentation/pages/product-details-page';
export * from './presentation/components/product-item-row';
export * from './presentation/components/product-form-dialog';
export * from './presentation/components/product-search-bar';

import { ProductListPage } from './presentation/pages/product-list-page';
import { ProductDetailsPage } from './presentation/pages/product-details-page';

export const ProductDescriptor = {
  id: 'product',
  title: 'Products',
  path: '/product',
};

export const ProductRoutes = [
  {
    path: '/product',
    element: <ProductListPage />,
  },
  {
    path: '/product/:id',
    element: <ProductDetailsPage />,
  },
];
