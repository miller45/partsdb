export interface Part {
  batch: number;
  artnr: string;
  description: string;
  stock: number | null;
  class?: string;
  value1?: string;
  value2?: string;
  mark?: string;
}

export interface PartsResponse {
  parts: Part[];
}

