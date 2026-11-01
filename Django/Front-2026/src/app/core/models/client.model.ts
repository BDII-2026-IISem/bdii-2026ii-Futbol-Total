export interface Client {
  id: number;
  user: number | null;
  document_type: string;
  first_name: string;
  last_name: string;
  document_number: string;
  phone: string | null;
  email: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export type ClientPayload = Pick<
  Client,
  'document_type' | 'first_name' | 'last_name' | 'document_number' | 'phone' | 'email'
> & {
  user?: number | null;
  is_active?: boolean;
};
