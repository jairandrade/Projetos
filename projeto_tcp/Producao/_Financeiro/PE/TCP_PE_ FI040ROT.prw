#include 'protheus.ch'
#include 'parmtype.ch'

User Function FI040ROT()

    Local aRotina := AClone(PARAMIXB)
    
    aAdd(aRotina, {'Inserir Histórico',"U_TC06A010",   0 , 3    })
    aAdd(aRotina, {'Consultar Histórico',"U_TC06C010",   0 , 3    })
   
    Return (aRotina)
    