/// Domain entity for Product. Plain immutable value object — no
/// framework dependencies.
export interface ProductEntity {
  readonly id: string;
  readonly name?: string;
  readonly description?: string;
  readonly createdAt?: Date;
  readonly updatedAt?: Date;
}

export class ProductEntityClass implements ProductEntity {
  readonly id: string;
  readonly name?: string;
  readonly description?: string;
  readonly createdAt?: Date;
  readonly updatedAt?: Date;

  constructor(data: ProductEntity) {
    this.id = data.id;
    this.name = data.name;
    this.description = data.description;
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  copyWith(partial: Partial<ProductEntity>): ProductEntity {
    return new ProductEntityClass({
      id: partial.id ?? this.id,
      name: partial.name ?? this.name,
      description: partial.description ?? this.description,
      createdAt: partial.createdAt ?? this.createdAt,
      updatedAt: partial.updatedAt ?? this.updatedAt,
    });
  }

  equals(other: ProductEntity): boolean {
    return (
      this.id === other.id &&
      this.name === other.name &&
      this.description === other.description &&
      this.createdAt?.getTime() === other.createdAt?.getTime() &&
      this.updatedAt?.getTime() === other.updatedAt?.getTime()
    );
  }

  toString(): string {
    return `ProductEntity(id: ${this.id}, name: ${this.name})`;
  }
}
