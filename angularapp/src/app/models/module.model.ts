export interface Module {
  artnr: string;
  description: string;
  stock: number;
}

export interface ModulesResponse {
  modules: Module[];
}

