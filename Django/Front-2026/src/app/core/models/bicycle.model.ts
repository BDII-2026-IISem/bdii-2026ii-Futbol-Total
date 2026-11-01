export interface Bicycle {
  id: number;
  serialNumber: string;
  name: string;
  description: string;
  bicycleType: string;
  status: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export type BicycleCreatePayload = Pick<
  Bicycle,
  'serialNumber' | 'name' | 'description' | 'bicycleType'
>;

export type BicycleUpdatePayload = Partial<BicycleCreatePayload>;
