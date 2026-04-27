/// Feature registry for React Router.
/// Generated features register their routes here.
import type { RouteObject } from 'react-router-dom';

// GENERATED:imports BEGIN
import { ProductRoutes, ProductDescriptor } from '../../features/product/product.module';
// GENERATED:imports END

export interface FeatureDescriptor {
  id: string;
  title: string;
  path: string;
  icon?: string;
}

export const FeatureRegistry = {
  descriptors: [] as FeatureDescriptor[],

  register(descriptor: FeatureDescriptor) {
    this.descriptors.push(descriptor);
  },

  get all(): FeatureDescriptor[] {
    return this.descriptors;
  },
};

// GENERATED:registrations BEGIN
FeatureRegistry.register(ProductDescriptor);
// GENERATED:registrations END

export const routes: RouteObject[] = [
  // GENERATED:entries BEGIN
    ...ProductRoutes,
  // GENERATED:entries END
];
