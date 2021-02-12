#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Itens Contábeis                                                                                                                        |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 23/03/2016                                                                                                                       |
| Descricao: rotina para Buscar/Exclusao Itens Itens Contabeis - Tipo Cliente/Fornecedor/Grupo de Produtos                               |
| Carregado pelas funções P.Entrada U_M030INC(nTipo="C"), U_M020INC(nTipo="F") e  U_MA035INC(nTipo="E")                                 |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function GeraCTD(cTipo)
Local _LastArea := GetArea()
Local aCampos  := {}
Local aCampos1 := {}
Local nAux

If cTipo="C"
	//Prepara Clientes
	AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")			})
	AADD(aCampos, {"CTD_ITEM"	, "C"+A1_COD + A1_LOJA		})
	AADD(aCampos, {"CTD_CLASSE"	, "2"						})
	AADD(aCampos, {"CTD_NORMAL"	, "2"						})
	AADD(aCampos, {"CTD_DESC01"	, A1_NOME					})
	AADD(aCampos, {"CTD_BLOQ"	, "2"						})
	AADD(aCampos, {"CTD_ITSUP"	, "C"						})
	AADD(aCampos, {"CTD_DTEXIS"	, CTOD("01/01/80")			})
	
	cAuxBusca := "C"+SA1->A1_COD + SA1->A1_LOJA
	
ElseIf cTipo="F"
	//Prepara Fornecedores
	AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")			})
	AADD(aCampos, {"CTD_ITEM"	, "F"+A2_COD + A2_LOJA		})
	AADD(aCampos, {"CTD_CLASSE"	, "2"						})
	AADD(aCampos, {"CTD_NORMAL"	, "1"						})
	AADD(aCampos, {"CTD_DESC01"	, A2_NOME					})
	AADD(aCampos, {"CTD_BLOQ"	, "2"						})
	AADD(aCampos, {"CTD_ITSUP"	, "F"						})
	AADD(aCampos, {"CTD_DTEXIS"	, CTOD("01/01/80")			})
	
	cAuxBusca := "F"+SA2->A2_COD + SA2->A2_LOJA

ElseIf cTipo="E"
	//Prepara Grupo de produtos
	AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")			})
	AADD(aCampos, {"CTD_ITEM"	, "E"+BM_GRUPO		})
	AADD(aCampos, {"CTD_CLASSE"	, "2"						})
	AADD(aCampos, {"CTD_NORMAL"	, "2"						})
	AADD(aCampos, {"CTD_DESC01"	, BM_DESC					})
	AADD(aCampos, {"CTD_BLOQ"	, "2"						})
	AADD(aCampos, {"CTD_ITSUP"	, "E"						})
	AADD(aCampos, {"CTD_DTEXIS"	, CTOD("01/01/80")			})
	
	cAuxBusca := "E"+SBM->BM_GRUPO     
	
ElseIf cTipo="A"
	//Prepara Grupo de Ativos 
	AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")			})
	AADD(aCampos, {"CTD_ITEM"	, "A"+NG_GRUPO 		})
	AADD(aCampos, {"CTD_CLASSE"	, "2"						})
	AADD(aCampos, {"CTD_NORMAL"	, "1"						})
	AADD(aCampos, {"CTD_DESC01"	, NG_DESCRIC					})
	AADD(aCampos, {"CTD_BLOQ"	, "2"						})
	AADD(aCampos, {"CTD_ITSUP"	, "A"						})
	AADD(aCampos, {"CTD_DTEXIS"	, CTOD("01/01/80")			})
	
	cAuxBusca := "A"+SNG->NG_GRUPO
		
EndIf

//Grava o novo registro ao cadastro de Item Contábil
DbSelectArea("CTD")
CTD->(DbGoTop())
If !CTD->(DbSeek(xFilial("CTD")+cAuxBusca))
	If RecLock("CTD", .T.)
		For nAux := 1 to Len(aCampos)
			&(aCampos[nAux][1]) := aCampos[nAux][2]
		Next nAux
		CTD->(MsUnlock())
	Endif
Endif

RestArea(_LastArea)

Return Nil

