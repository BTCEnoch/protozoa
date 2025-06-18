'use client'
import { SimulationCanvas } from '@/components/SimulationCanvas'
import { initServices } from '@/compositionRoot'
import { useEffect } from 'react'

export default function App(){
 useEffect(()=>{initServices()},[])
 return (
  <div className="w-full h-screen">
    <SimulationCanvas />
  </div>
 )
}
