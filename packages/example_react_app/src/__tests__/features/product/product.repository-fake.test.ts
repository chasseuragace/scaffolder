/// Tests for ProductRepositoryFake.
import { describe, it, expect, beforeEach } from 'vitest';
import { ProductRepositoryFake } from '../../../features/product/data/repositories/product.repository-fake';
import type { ProductEntity } from '../../../features/product/domain/entities/product.entity';
import { isRight, isLeft } from '../../../core/usecase/usecase';

describe('ProductRepositoryFake', () => {
  let repository: ProductRepositoryFake;

  beforeEach(() => {
    repository = new ProductRepositoryFake();
  });

  it('should return empty list initially', async () => {
    const result = await repository.getAll();
    if (isRight(result)) {
      expect(result.right).toEqual([]);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should add an entity', async () => {
    const entity: ProductEntity = {
      id: '1',
      name: 'Test Product',
      description: 'Test description',
    };

    const result = await repository.add(entity);
    if (isRight(result)) {
      expect(result.right.id).toBe('1');
      expect(result.right.name).toBe('Test Product');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should get all entities', async () => {
    const entity1: ProductEntity = { id: '1', name: 'Test 1' };
    const entity2: ProductEntity = { id: '2', name: 'Test 2' };

    await repository.add(entity1);
    await repository.add(entity2);

    const result = await repository.getAll();
    if (isRight(result)) {
      expect(result.right.length).toBe(2);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should get entity by id', async () => {
    const entity: ProductEntity = { id: '1', name: 'Test Product' };
    await repository.add(entity);

    const result = await repository.getById('1');
    if (isRight(result)) {
      expect(result.right.id).toBe('1');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should return NotFoundFailure for non-existent id', async () => {
    const result = await repository.getById('999');
    if (isLeft(result)) {
      expect(result.left._tag).toBe('NotFoundFailure');
    } else {
      throw new Error('Expected left');
    }
  });

  it('should update an entity', async () => {
    const entity: ProductEntity = { id: '1', name: 'Original' };
    await repository.add(entity);

    const updated: ProductEntity = { id: '1', name: 'Updated' };
    const result = await repository.update(updated);

    if (isRight(result)) {
      expect(result.right.name).toBe('Updated');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should delete an entity', async () => {
    const entity: ProductEntity = { id: '1', name: 'Test Product' };
    await repository.add(entity);

    const result = await repository.delete('1');
    if (isRight(result)) {
      // Success
    } else {
      throw new Error('Expected right');
    }

    const all = await repository.getAll();
    if (isRight(all)) {
      expect(all.right.length).toBe(0);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should search entities by name', async () => {
    const entity1: ProductEntity = { id: '1', name: 'Apple' };
    const entity2: ProductEntity = { id: '2', name: 'Banana' };
    const entity3: ProductEntity = { id: '3', name: 'Apricot' };

    await repository.add(entity1);
    await repository.add(entity2);
    await repository.add(entity3);

    const result = await repository.search('ap');
    if (isRight(result)) {
      expect(result.right.length).toBe(2);
      expect(result.right.map((e: ProductEntity) => e.name)).toEqual(['Apple', 'Apricot']);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should return paginated results', async () => {
    for (let i = 1; i <= 25; i++) {
      await repository.add({ id: String(i), name: `Item ${i}` });
    }

    const result = await repository.getAllPaginated({ offset: 0, limit: 10 });
    if (isRight(result)) {
      expect(result.right.items.length).toBe(10);
      expect(result.right.total).toBe(25);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should handle offset correctly', async () => {
    for (let i = 1; i <= 25; i++) {
      await repository.add({ id: String(i), name: `Item ${i}` });
    }

    const result = await repository.getAllPaginated({ offset: 10, limit: 10 });
    if (isRight(result)) {
      expect(result.right.items.length).toBe(10);
      expect(result.right.items[0].id).toBe('11');
    } else {
      throw new Error('Expected right');
    }
  });
});
