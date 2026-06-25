/// Tests for CustomerRepositoryFake.
import { describe, it, expect, beforeEach } from 'vitest';
import { CustomerRepositoryFake } from '../../../features/customer/data/repositories/customer.repository-fake';
import type { CustomerEntity } from '../../../features/customer/domain/entities/customer.entity';

describe('CustomerRepositoryFake', () => {
  let repository: CustomerRepositoryFake;

  beforeEach(() => {
    repository = new CustomerRepositoryFake();
  });

  it('should return empty list initially', async () => {
    const result = await repository.getAll();
    if ('right' in result) {
      expect(result.right).toEqual([]);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should add an entity', async () => {
    const entity: CustomerEntity = {
      id: '1',
      name: 'Test Customer',
      description: 'Test description',
    };

    const result = await repository.add(entity);
    if ('right' in result) {
      expect(result.right.id).toBe('1');
      expect(result.right.name).toBe('Test Customer');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should get all entities', async () => {
    const entity1: CustomerEntity = { id: '1', name: 'Test 1' };
    const entity2: CustomerEntity = { id: '2', name: 'Test 2' };

    await repository.add(entity1);
    await repository.add(entity2);

    const result = await repository.getAll();
    if ('right' in result) {
      expect(result.right.length).toBe(2);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should get entity by id', async () => {
    const entity: CustomerEntity = { id: '1', name: 'Test Customer' };
    await repository.add(entity);

    const result = await repository.getById('1');
    if ('right' in result) {
      expect(result.right.id).toBe('1');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should return NotFoundFailure for non-existent id', async () => {
    const result = await repository.getById('999');
    if ('left' in result) {
      expect(result.left._tag).toBe('NotFoundFailure');
    } else {
      throw new Error('Expected left');
    }
  });

  it('should update an entity', async () => {
    const entity: CustomerEntity = { id: '1', name: 'Original' };
    await repository.add(entity);

    const updated: CustomerEntity = { id: '1', name: 'Updated' };
    const result = await repository.update(updated);

    if ('right' in result) {
      expect(result.right.name).toBe('Updated');
    } else {
      throw new Error('Expected right');
    }
  });

  it('should delete an entity', async () => {
    const entity: CustomerEntity = { id: '1', name: 'Test Customer' };
    await repository.add(entity);

    const result = await repository.delete('1');
    if ('right' in result) {
      // Success
    } else {
      throw new Error('Expected right');
    }

    const all = await repository.getAll();
    if ('right' in all) {
      expect(all.right.length).toBe(0);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should search entities by name', async () => {
    const entity1: CustomerEntity = { id: '1', name: 'Apple' };
    const entity2: CustomerEntity = { id: '2', name: 'Banana' };
    const entity3: CustomerEntity = { id: '3', name: 'Apricot' };

    await repository.add(entity1);
    await repository.add(entity2);
    await repository.add(entity3);

    const result = await repository.search('ap');
    if ('right' in result) {
      expect(result.right.length).toBe(2);
      expect(result.right.map((e: CustomerEntity) => e.name)).toEqual(['Apple', 'Apricot']);
    } else {
      throw new Error('Expected right');
    }
  });

  it('should return paginated results', async () => {
    for (let i = 1; i <= 25; i++) {
      await repository.add({ id: String(i), name: `Item ${i}` });
    }

    const result = await repository.getAllPaginated({ offset: 0, limit: 10 });
    if ('right' in result) {
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
    if ('right' in result) {
      expect(result.right.items.length).toBe(10);
      expect(result.right.items[0].id).toBe('11');
    } else {
      throw new Error('Expected right');
    }
  });
});
