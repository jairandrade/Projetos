#include 'protheus.ch'
#include 'parmtype.ch'

User Function FA740BRW()
    Local aBotao := {}
   
    aAdd(aBotao, {'Inserir Hist�rico',"U_TC06A010",   0 , 3    })
    aAdd(aBotao, {'Consultar Hist�rico',"U_TC06C010",   0 , 3    })
   
    Return(aBotao)
    