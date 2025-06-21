/** Generic utility fix helpers (Template) */
export const clamp = (val:number, min:number, max:number)=>Math.max(min,Math.min(max,val))
export const lerp = (a:number,b:number,t:number)=>a+(b-a)*t