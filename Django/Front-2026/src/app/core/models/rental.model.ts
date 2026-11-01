export interface RentalEvent {
  id: number;
  rental: number;
  eventType: string;
  description: string | null;
  eventAt: string;
  quantity: number | null;
  status: string;
}

export interface Rental {
  id: number;
  reservation: number | null;
  client: number;
  bicycle: number;
  rate: number;
  startStation: number | null;
  endStation: number | null;
  startedAt: string;
  endedAt: string | null;
  status: string;
  totalAmount: string;
  observations: string;
  events: RentalEvent[];
}

export type RentalRegistrationResult = Omit<Rental, 'events'>;

export interface RentalClientOption {
  id: number;
  firstName: string;
  lastName: string;
  isActive: boolean;
}

export interface RentalRateOption {
  id: number;
  name: string;
  price: string;
  billingUnit: string;
  validFrom: string | null;
  validUntil: string | null;
  isActive: boolean;
}

export interface RentalStationOption {
  id: number;
  name: string;
  status: string;
  isActive: boolean;
}

export interface RentalReservationOption {
  id: number;
  client: number;
  bicycle: number | null;
  station: number | null;
  expiresAt: string | null;
  status: string;
}

export type RentalRegistrationPayload =
  | { reservationId: number; rateId: number }
  | {
      clientId: number;
      bicycleId: number;
      rateId: number;
      startStationId: number;
    };
