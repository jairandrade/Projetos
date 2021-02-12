#include "protheus.ch"
#include "topconn.ch"

#Define ENTER chr(13)+chr(10)

User Function KFATR22()
    Local aArea := GetArea()
    Local lRet  := .T.
    Local cQuery:= ""
    Local cTemp := GetNextAlias()
    Local cPed  := M->C5_NUM
    Local lBlq  := !StaticCall(M521CART,TGetMv,"  ","KA_BLQTPPE","L",.T.,"KFATR22 - Bloqueiar alteracao c5_xtpped depois do pedido de venda liberado?" )
    
    If !lBlq
        Return lRet
    Endif

    cPed  := M->C5_NUM

    cQuery += "SELECT COUNT(*) CONTA "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" with(nolock) "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE C9_FILIAL='"+xFilial("SC9")+"' "+ENTER
    cQuery += "AND C9_PEDIDO='"+cPed+"' "+ENTER
    
    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif
      
    TcQuery cQuery New Alias (cTemp)

    If !(cTemp)->( EOF() )
        lRet := (cTemp)->CONTA == 0 
    Endif

    If Select(cTemp) > 0 
        (cTemp)->(DbCloseArea())
    Endif
      
    RestArea(aArea)
Return lRet