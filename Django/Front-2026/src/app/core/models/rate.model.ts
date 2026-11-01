export interface Rate {
  id: number;
  name: string;
  price: string;
  billing_unit: string;
  valid_from: string | null;
  valid_until: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export type RatePayload = Omit<Rate, 'id' | 'created_at' | 'updated_at'>;
