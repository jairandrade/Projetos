#include "PROTHEUS.CH"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 06.02.2018                                                                                                                       |
| Descricao: Gatilho para atualização da TES conforme operação                                                                           |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Alteração 25.07.2018 -- Andre/Rsac  -- Vaidado em produção.
User Function GATil()
Local i 

nPosOper  := aScan(aHeader,{ |x| ALLTRIM(x[2]) == "D1_X_OPER" })
nPosOper2 := aScan(aHeader,{ |x| ALLTRIM(x[2]) == "D1_OPER" })
nPosTes   := aScan(aHeader,{ |x| ALLTRIM(x[2]) == "D1_TES" })

For i := 1 to len(acols)
	aCols[i,nPosTes] := aCols[1,nPosTes]
	MaFisLoad("IT_TES","",i)
	MaFisAlt("IT_TES",aCols[i][nPosTes],i)
	MaFisToCols(aHeader,aCols,i,"MT100")
	If ExistTrigger("D1_X_OPER")
		RunTrigger(2,i,,"D1_X_OPER")
	EndIf
	If ExistTrigger("D1_OPER")
		RunTrigger(2,i,,"D1_OPER")
	EndIf 
 	If ExistTrigger("D1_COD")
		RunTrigger(2,i,,"D1_COD")
	EndIf 
	
	
Next

msginfo("TES atualizadas com sucesso!")

Return()




RETURN






