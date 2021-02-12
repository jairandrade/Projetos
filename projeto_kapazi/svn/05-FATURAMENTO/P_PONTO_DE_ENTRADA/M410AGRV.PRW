#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Define ENTER CHR(13)+CHR(10)
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: U_M410AGRV														                        	**/
/** DESCRIÇÃO	  	: Gerencia as demais rotinas 																**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES      **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    	  **/
/**---------------------------------------------------------------------------------------------------------------**/
/** 05/02/2014 	| Velton Teixeira        | 	                   |   RSAC SOLUÇÕES			 					  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      **/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                    **/
/** FINALIDADE	: P. E. executado nas operaçãoe de incluir, alterar e excluir do pedido antes da gravação         **/
/**---------------------------------------------------------------------------------------------------------------**/

User Function M410AGRV()
Local aArea		:= GetArea()
Local nOpc 		:= ParamIxb[1]     //Grava a opção
Local _aAItens	:= {}

/*
Public _nValPVL	:= 0
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTOp())
If SA1->(DbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI))
	_nValPVL := SA1->A1_SALPEDL
EndIf
*/

If Alltrim(M->C5_XGERASV) == "S" .And. M->C5_XTIPONF == "1" .And. ( Type("_AItensA") == "A" .OR. Type("_AItensB") == "A" ) .And. nOpc == 2 .And. Type("l410Auto") == "L" //!(IsInCallStack("A410Deleta"))
	
	If l410Auto
		If Type("_AItensA") == "A" .And. !(IsInCallStack("U_ESTPVNFM")  .OR. IsInCallStack("U_SF2520E")) //Chamar somente quando NAO ORIGINAR do estorno do pedido de servico, ou do estorno da NF  
				If Len(_AItensA) > 0
					_aAItens	:= _AItensA
					AtCols(_aAItens)	//Solucao de contorno para o problema da largura
				EndIf
				_AItensA := {} //Zera o array
				
			ElseIf Type("_AItensB") == "A" .And. (IsInCallStack("U_ESTPVNFM")  .OR. IsInCallStack("U_SF2520E")) //Chamar somente quando ORIGINAR do estorno do pedido de servico, ou do estorno da NF
				If Len(_AItensB) > 0
					_aAItens	:= _AItensB
					AtCols(_aAItens)	//Solucao de contorno para o problema da largura
				EndIf
				_AItensB := {} //Zera o array
		EndIf
	EndIf

EndIf


If !IsInCallStack("MATA416") //Senão veio de orcamento
	
	If Type("l410Auto") == "L" 
		
		If (!l410Auto  .and. nOpc == 1) .or. (!l410Auto .and. nOpc == 2)
		
			//Verifica as opções
			Do Case
				//em 16/0714 - implementado tratamento da alteração do pedido
				//Inclusão / alteracao
				Case (nOpc == 1) .OR. (nOpc == 2)
					
					//Verifica se é o pedio original
					//If Empty(M->C5_K_PO) .and. M->C5_PVINTAN $ ' S' .And. Alltrim(M->C5_XGERASV) <> "S" //Diferente de serviço
					//Conforme alinha com o Aluisio, o pedido deve ser explicitamente Intangível como "S"
					If Empty(M->C5_K_PO) .and. M->C5_PVINTAN == 'S' .And. Alltrim(M->C5_XGERASV) <> "S" //Diferente de serviço
							//Altera o valor conforme o percentual de intangíveis
							AltVlrIntg()
						Else
							//Libera as quantidades
							//LibQtdPed() //Comentado em 20/04/18(conforme alinhando com Aluisio), pois estava sugestionando em PV padrões, a quantidade liberada nos pedidos de venda normail.
					EndIf
			EndCase
		EndIf
		
	EndIf
	
EndIf

If cEmpAnt == '04' .And. !(IsInCallStack("U_ESTPVNFM")  .OR. IsInCallStack("U_SF2520E") .OR. IsInCallStack("U_M410PVNF") ) .And. Type("l410Auto") == "L" 

	If !l410Auto
	
		If M->C5_XPVSPC == 'S' .And. nOpc == 1 
				xAltLim("A")//Acrescenta limite a supplier
			
			ElseIf  nOpc == 2 //Alteracao
				If M->C5_XPVSPC == 'S' .And. SC5->C5_XPVSPC == 'N'
						xAltLim("A") //Acrescenta limite a supplier
				
					ElseIf SC5->C5_XPVSPC == 'N' .And. M->C5_XPVSPC == 'S'
						xAltLim("R")	//Retira limite da supplier
				EndIf
				
			ElseIf nOpc == 3 .And. M->C5_XPVSPC == 'S' //Exclusao
				xAltLim("R")//Retira limite da supplier
					
		EndIf
	
	EndIf
EndIf

RestArea(aArea)
Return Nil

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: AltVlrIntg()														                                                      **/
/** DESCRIÇÃO	  	: Altera o valor dos itens dos pedidos de venda conforme o percentual de intangíveis						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 05/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function AltVlrIntg()

Local nX 			:= 0																										//Contador
Local nPosPrc	 := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRCVEN"})		//Posição do preço unitário no aCols
Local nPosTot   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR"})  	//Posição do valor total do item no aCols
Local nPosPru   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRUNIT"})  	//Posição do preço de tabela do item no aCols
Local nPosPr2   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_XPRECPC"})  //Posição de preço unitário customizado
Local nPosPr3   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_X_PRCVE"})  //Posição de preço unitário customizado

//em 16/07/14
Local nPosINTAN := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_K_INTAN"})  //Posição de C6_K_INTAN

//em 14/10/14
Local nPositPV := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})   //Posição de C6_ITEM
Local nPosCod  := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})  //Posição de C6_PRODUTO

//Verifica se é pedido normal de venda
If (M->C5_TIPO == "N")
	
	//Ordena a tabela de clientes
	SA1->(DbSetOrder(1))
	
	//Posiciona no cliente
	If SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		
		//Verifica se o cliente tem percentual de intangiveis
		If (SA1->A1_K_INTAN > 0)
			
			//Alerta o usuário
//			MsgAlert("O cliente possui um percentual de intangíveis de " + Alltrim(cValToChar(SA1->A1_K_INTAN)) + "%. O valor do pedido será alterado.")
			
			//Faz loop no aCols
			For nX := 1 To Len(aCols)

				//EM 07/11/14
				//verifica se o produto gera intangivel
				CGeraInt := Posicione("SB1",1,xFilial("SB1")+aCols[nX][nPosCod],"B1_INTANG")
				
				If CGeraInt ='S'
					//EM 14/10/14
					//verifica se trata do mesmo produto
					lMesmo := V_cod(M->C5_NUM,aCols[nX][nPositPV],aCols[nX][nPosCod])
					
					//em 16/07/14 - trata novos itens incluidos via alteração
					//em 14/10/14 - verifica se a foi alterado o produto
					If aCols[nX][nPosINTAN] == 0   .OR. !lMesmo
					
						//Altera os valores
						aCols[nX][nPosPrc] := (aCols[nX][nPosPrc] * SA1->A1_K_INTAN / 100)
						aCols[nX][nPosTot] := (aCols[nX][nPosTot] * SA1->A1_K_INTAN / 100)
						aCols[nX][nPosPru] := (aCols[nX][nPosPru] * SA1->A1_K_INTAN / 100)
						aCols[nX][nPosPr2] := (aCols[nX][nPosPr2] * SA1->A1_K_INTAN / 100)
						aCols[nX][nPosPr3] := (aCols[nX][nPosPr3] * SA1->A1_K_INTAN / 100)
						
						//em 16/07/14 - grava o percentual intangivel
						aCols[nX][nPosINTAN] := SA1->A1_K_INTAN
				 	EndIf	
			 	EndIf	
			Next nX
			
			//Grava o percentual utilizado no pedido
			M->C5_K_INTAN := SA1->A1_K_INTAN
			
		EndIf
		
	EndIf
	
EndIf


Return Nil


/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: LibQtdPed()														                                              	        **/
/** DESCRIÇÃO	  	: Libera as quantidades para pedidos intangíveis																								**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 05/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
/*
Static Function LibQtdPed()

Local nX 			:= 0																										//Contador
Local nPosQ1	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})		//Posição do preço unitário no aCols
Local nPosQ2 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDLIB"})  	//Posição do valor total do item no aCols


//Faz loop no aCols
For nX := 1 To Len(aCols)
	
	//Altera os valores
	aCols[nX][nPosQ2] := aCols[nX][nPosQ1]
	
	//Próximo registro
Next nX

Return Nil
*///

//EM 14/10/14
//verifica se código do produto é o memso do que já está gravado.
Static Function V_cod(CNumPv,cItemPv,cCod)
Local cQuery

cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery += " AND C6_NUM   = '"+CNumPv+"' "
cQuery += " AND C6_ITEM  = '"+cItemPv+"' "
cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
	
If Select("TRBSC6")<>0
	DbSelectArea("TRBSC6")
	DbCloseArea()
Endif
	
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSC6", .F., .T.)

lRet := .T.	
If !TRBSC6->(eof())
	If TRBSC6->C6_PRODUTO <> cCod
		lRet := .F.	
	EndIf
Endif
Return(lRet)



//EM 14/10/14
//verifica se código do produto pode gerar pedido intangivel
Static Function V_Intang(cCod)
Local cQuery

cQuery := " SELECT B1_INTANG "
cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND B1_COD   = '"+cCod+"' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	
If Select("TRBSB1")<>0
	DbSelectArea("TRBSB1")
	DbCloseArea()
Endif
	
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSB1", .F., .T.)

lRet := .T.	
If !TRBSB1->(eof())
	If TRBSB1->B1_PRODUTO <> cCod
		lRet := .F.	
	EndIf
Endif
Return(lRet)


Static Function AtCols(_aAItens)
Local nX		:= 1
Local nPosQ1	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_XLARG"})		//Posição do preço unitário no aCols
Local nPosQ2 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_XCOMPRI"})  	//Posição do valor total do item no aCols
Local nPosQ3	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_XQTDPC"})		//Posição do preço unitário no aCols
Local nPosQ4 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})  		//Posição do valor total do item no aCols
Local nPosQ5 	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_UM"})  			//Posição do valor total do item no aCols
Local nPosQ6	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_ITEM"})  			//Posição do valor total do item no aCols

For nX := 1 To Len(Acols)
	
	If	aCols[nX][nPosQ5] == "M2" 
		//Altera os valores
		If aCols[nX][nPosQ6] == _aAItens[nX][1]
			
			//aAdd(_AItensB,{SC6->C6_ITEM,SC6->C6_XLARG,SC6->C6_XCOMPRI,SC6->C6_XQTDPC,SC6->C6_QTDVEN})
			//aAdd(_AItensA,{SC6->C6_ITEM,SC6->C6_XLARG,SC6->C6_XCOMPRI,SC6->C6_XQTDPC,SC6->C6_QTDVEN})
			
			aCols[nX][nPosQ1] := _aAItens[nX][2]
			aCols[nX][nPosQ2] := _aAItens[nX][3]
			aCols[nX][nPosQ3] := _aAItens[nX][4]
			aCols[nX][nPosQ4] := _aAItens[nX][5]
		
		EndIf
		
	EndIf
Next

Return()

//Acrescenta limite
Static Function xAltLim(cOpcao)
Local aArea		:= GetArea()
Local nPosTot   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR"})
Local nX 		:= 0
Local nTotal 	:= 0
Local lRet		:= .T.
Local cQr 		:= ""
Local nUtiliz	:= 0
Local nRest		:= 0
Local nRegs		:= 0
Local cClient	:= M->C5_CLIENTE
Local cLojaC	:= M->C5_LOJACLI

For nX := 1 To Len(aCols)
	
	//Soma os valores
	nTotal += aCols[nX][nPosTot]
	
	//Próximo registro
Next nX

If Select("cAliaLim")<>0
	DbSelectArea("cAliaLim")
	cAliaLim->(DbCloseArea())
Endif

cQr += " SELECT SA1.A1_CGC,SA1.A1_LC,ZSL.ZSL_RAIZCN,ZSL.ZSL_LIMTOT,ZSL.ZSL_LIMUTI,ZSL.ZSL_LIMRES,ZSL.R_E_C_N_O_ AS RECOZSL,ZSL.*
cQr += " FROM "+RetSqlName("SA1")+" SA1
cQr += " INNER JOIN "+RetSqlName("ZSL")+" ZSL ON SUBSTRING(SA1.A1_CGC,1,8) = ZSL.ZSL_RAIZCN AND ZSL.D_E_L_E_T_ = ''
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += " AND SA1.A1_COD = '"+cClient+"'"
cQr += " AND SA1.A1_LOJA = '"+cLojaC+"'"

// abre a query
TcQuery cQr new alias "cAliaLim"
Count to nRegs

DbSelectArea("cAliaLim")
cAliaLim->(DbGoTop())

If cAliaLim->(EOF()) 
		MsgInfo("O cliente não possui limite com a Supplier, FAVOR VERIFICAR!!","KAPAZICRED")
		//lRet := .F.
	Else
		
		If	cOpcao == "A" //Adiciona
				nUtiliz	:= cAliaLim->ZSL_LIMUTI + nTotal
				nRest 	:= cAliaLim->ZSL_LIMTOT - (cAliaLim->ZSL_LIMUTI + nTotal) 
			Else
				nUtiliz	:= cAliaLim->ZSL_LIMUTI - nTotal
				nRest 	:= cAliaLim->ZSL_LIMTOT - (cAliaLim->ZSL_LIMUTI - nTotal) 
		EndIf
		
		
		DBSelectArea("ZSL")
		ZSL->(DbSetOrder(1))
		ZSL->(DbGoTop())
		ZSL->(DbGoTo(cAliaLim->RECOZSL))
		RecLock("ZSL",.F.)
		ZSL->ZSL_LIMUTI	:= nUtiliz
		ZSL->ZSL_LIMRES	:= nRest
		ZSL->(MsUnLock())
		
EndIf

cAliaLim->(DbCloseArea())
RestArea(aArea)
Return(lRet)

