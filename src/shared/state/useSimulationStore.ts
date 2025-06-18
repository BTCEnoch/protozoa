import create from 'zustand';
interface SimulationState{ running:boolean; formation:string|null; setRunning:(v:boolean)=>void; setFormation:(f:string|null)=>void }
export const useSimulationStore=create<SimulationState>(set=>({ running:false, formation:null, setRunning:v=>set({running:v}), setFormation:f=>set({formation:f}) }))
