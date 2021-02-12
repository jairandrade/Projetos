#include "rwmake.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Itens Contabil                                                                                                                         |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 17/03/2016                                                                                                                       |
| Descricao: Criação de itens contábeis não cadastrados                                                                                   |
| Empresa: Kapazi                                                                                                                     |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/


User Function ACTB002(cTipo)

Local _LastArea := GetArea()
Local aCampos := {}
Local nAux       
Local cTipo := "C"
Local lAux := If(cTipo == "C",.T., .F.)


//Cria os itens contabeis para o cadastro de clientes existentes
//////////////////////////////////////////////////////////////////////////
cTipo := "C"
lAux := If(cTipo == "C",.T., .F.)

If MsgYesNo("Deseja criar Itens Contabeis para os Clientes já cadastrados ?")
	dbSelectArea("SA1") 
	dbSetOrder(1)
	dbGoTop()                
    Incproc('Aguarde, processando Informação solicitada...')	
	While !eof()
   	       Incproc('Aguarde, processando Informação solicitada...')	       
	       dbSelectArea("CTD")
	       dbSetOrder(1)
	       dbGoTop()
	       If !dbSeek(xfilial("CTD")+"C"+SA1->A1_COD+SA1->A1_LOJA,.T.)
				AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")})
				AADD(aCampos, {"CTD_ITEM"		, If(lAux, 	"C"+SA1->A1_COD + SA1->A1_LOJA, 	"F"+SA2->A2_COD + A2->A2_LOJA	)})
				AADD(aCampos, {"CTD_CLASSE"	, If(lAux, 	"2"    												, 	"2"		 												)})
				AADD(aCampos, {"CTD_NORMAL"	, If(lAux, 	"2"    							 		 			, 	"1"														)})
				AADD(aCampos, {"CTD_DESC01"	, If(lAux, 	SA1->A1_NOME									, 	A2_NOME												)})
				AADD(aCampos, {"CTD_BLOQ"	  , If(lAux, 	"2"								 		 				, 	"2" 											   	)})
				AADD(aCampos, {"CTD_ITSUP"  , If(lAux, 	"C"														, 	"F" 											   	)})
				AADD(aCampos, {"CTD_DTEXIS"	, If(lAux, 	CTOD("01/01/80")							, 	CTOD("01/01/80")							)})
				
				If RecLock("CTD", .T.)
					For nAux := 1 to Len(aCampos)
						&(aCampos[nAux][1]) := aCampos[nAux][2]
					Next nAux
					CTD->(MsUnlock())
				Endif
	       EndIf
	       dbSelectArea("SA1")
	       dbSkip()
	       Loop
	End
EndIf
  

//Cria os itens contabeis para o cadastro de clientes existentes
//////////////////////////////////////////////////////////////////////////
cTipo := "F"
lAux := If(cTipo == "C",.T., .F.)

If MsgYesNo("Deseja criar Itens Contabeis para os Fornecedores já cadastrados ?")
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbGoTop()                
	While !eof()
   	       Incproc('Aguarde, processando Informação solicitada...')
	       dbSelectArea("CTD")
	       dbSetOrder(1)
	       dbGoTop()
	       If !dbSeek(xfilial("CTD")+"F"+SA2->A2_COD+SA2->A2_LOJA,.T.)
				AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")})
				AADD(aCampos, {"CTD_ITEM"		, If(lAux, 	"C"+SA1->A1_COD + SA1->A1_LOJA, 	"F"+SA2->A2_COD + SA2->A2_LOJA	)})
				AADD(aCampos, {"CTD_CLASSE"	, If(lAux, 	"2"    								 				, 	"2"									 						)})
				AADD(aCampos, {"CTD_NORMAL"	, If(lAux, 	"2"    							 					, 	"1"															)})
				AADD(aCampos, {"CTD_DESC01"	, If(lAux, 	SA1->A1_NOME									, 	SA2->A2_NOME										)})
				AADD(aCampos, {"CTD_BLOQ"	  , If(lAux, 	"2"								 						, 	"2" 												   	)})
				AADD(aCampos, {"CTD_ITSUP"	, If(lAux, 	"C"														, 	"F" 									 			  	)})
				AADD(aCampos, {"CTD_DTEXIS"	, If(lAux, 	CTOD("01/01/80")							, 	CTOD("01/01/80")			 					)})

				If RecLock("CTD", .T.)
					For nAux := 1 to Len(aCampos)
						&(aCampos[nAux][1]) := aCampos[nAux][2]
					Next nAux
					CTD->(MsUnlock())
				Endif
	       EndIf
	       dbSelectArea("SA2")
	       dbSkip()
	       Loop
	End
EndIf
//Cria os itens contabeis para o cadastro de grupos de produtos existentes
//////////////////////////////////////////////////////////////////////////
cTipo := "E"
lAux := If(cTipo == "E",.T., .F.)

If MsgYesNo("Deseja criar Itens Contabeis para os Grupos de Produtos já cadastrados ?")
	dbSelectArea("SBM")
	dbSetOrder(1)
	dbGoTop()                
	While !eof()
   	       Incproc('Aguarde, processando Informação solicitada...')
	       dbSelectArea("CTD")
	       dbSetOrder(1)
	       dbGoTop()
	       If !dbSeek(xfilial("CTD")+"E"+SBM->BM_GRUPO,.T.)
				AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")})
				AADD(aCampos, {"CTD_ITEM"		, If(lAux, 	"E"+SBM->BM_GRUPO							, 	"E"+SBM->BM_GRUPO								)})
				AADD(aCampos, {"CTD_CLASSE"	, If(lAux, 	"2"    								 				, 	"2"									 						)})
				AADD(aCampos, {"CTD_NORMAL"	, If(lAux, 	"2"    							 					, 	"2"															)})
				AADD(aCampos, {"CTD_DESC01"	, If(lAux, 	SBM->BM_DESC									, 	SBM->BM_DESC										)})
				AADD(aCampos, {"CTD_BLOQ"	  , If(lAux, 	"2"								 						, 	"2" 												   	)})
				AADD(aCampos, {"CTD_ITSUP"	, If(lAux, 	"E"														, 	"E" 									 			  	)})
				AADD(aCampos, {"CTD_DTEXIS"	, If(lAux, 	CTOD("01/01/80")							, 	CTOD("01/01/80")			 					)})

				If RecLock("CTD", .T.)
					For nAux := 1 to Len(aCampos)
						&(aCampos[nAux][1]) := aCampos[nAux][2]
					Next nAux
					CTD->(MsUnlock())
				Endif
	       EndIf
	       dbSelectArea("SBM")
	       dbSkip()
	       Loop
	End
EndIf
//Cria os itens contabeis para o cadastro de Ativo Imobilizado
//////////////////////////////////////////////////////////////////////////
cTipo := "A"
lAux := If(cTipo == "A",.T., .F.)

If MsgYesNo("Deseja criar Itens Contabeis para os Ativos já cadastrados ?")
	dbSelectArea("SNG")
	dbSetOrder(1)
	dbGoTop()                
	While !eof()
   	       Incproc('Aguarde, processando Informação solicitada...')
	       dbSelectArea("CTD")
	       dbSetOrder(1)
	       dbGoTop()
	       If !dbSeek(xfilial("CTD")+"A"+SNG->NG_GRUPO,.T.)
				AADD(aCampos, {"CTD_FILIAL"	, xFilial("CTD")})
				AADD(aCampos, {"CTD_ITEM"		, If(lAux, 	"A"+SNG->NG_GRUPO             , 	"A"+SNG->NG_GRUPO             	)})
				AADD(aCampos, {"CTD_CLASSE"	, If(lAux, 	"2"    								 				, 	"2"									 						)})
				AADD(aCampos, {"CTD_NORMAL"	, If(lAux, 	"2"    							 					, 	"1"															)})
				AADD(aCampos, {"CTD_DESC01"	, If(lAux, 	SNG->NG_DESCRIC								, 	SNG->NG_DESCRIC									)})
				AADD(aCampos, {"CTD_BLOQ"	  , If(lAux, 	"2"								 						, 	"2" 												   	)})
				AADD(aCampos, {"CTD_ITSUP"	, If(lAux, 	"A"														, 	"A" 									 			  	)})
				AADD(aCampos, {"CTD_DTEXIS"	, If(lAux, 	CTOD("01/01/80")							, 	CTOD("01/01/80")			 					)})

				If RecLock("CTD", .T.)
					For nAux := 1 to Len(aCampos)
						&(aCampos[nAux][1]) := aCampos[nAux][2]
					Next nAux
					CTD->(MsUnlock())
				Endif
	       EndIf
	       dbSelectArea("SNG")
	       dbSkip()
	       Loop
	End
EndIf           

MsgInfo("Processo finalizado com sucesso !!!")

RestArea(_LastArea)

Return Nil
