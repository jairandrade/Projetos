
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Fauramento                                                                                                                   **/     																																
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/** Rotinas usadas para customizações de status                                                                                  **/ 
/**********************************************************************************************************************************/ 
/*
A - CADASTRADO	- BR_VERDE
P - LIBERADO	- BR_AZUL
F - FINANCEIRO	- R_AMARELO
T - ESTOQUE		- AVGARMAZEM
U - FATURAMENTO	- RPMCABEC
M - EMBARCADO	- OK
E - EXCLUIDO	- DISABLE
I - INATIVO 	- BR_PRETO
*/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 11/08/2015 | Marcos Sulivan					| Retorna Array contendo, Nome, Numero do usuário, Data, Hora, Fonte         	 **/
/**********************************************************************************************************************************/
User Function KPFATA04()  
	Local aArea		:=	GetArea()                             
	Local lRet		:=	.T.
	Local aStu		:= {0,0,0,0}
	Local aDsUsr	:= {}

	aStu[1]	:= __cUserId	//retorno de Id Usuário
	aStu[2] := cUserName    //posição com nome do usuário
	aStu[3] := DDATABASE    //data de movimento
	aStu[4] := TIME()       //hora de movimentação

	RestArea(aArea)
Return aStu 

/**********************************************************************************************************************************/
/** user function GRVZ6()                                                                                                      **/
/**Grava Registro na SZ6 - Controle de            																																							**/
/**********************************************************************************************************************************/ 
User Function GRVZ6(cPedid,cTpcli)  
	Local aArea		:= GetArea()
//	Local cAt		:= ""
	Local aDhu 		:= {}
	Local aCp		:= {"","",0} 
//	Local cPedid	:= cPedid

	/*  ARRAY USADO PARA GRAVAR NA TABELA SZ6
		aDhu[1]	//ID DE USUÁRIO
		aDhu[2]	//NOME DO USUARIO 
		aDhu[3] //DATA DO MOVIMENTO
		aDhu[4] //HORA DO MOVIMENTO
	*/

	//ABRE TABELA DE STATS
	SZ6->(dBselectArea('SZ6'))
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
	
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS
	If (SZ6->(dbSeek((xFilial("SZ6") + cPedid ))))
		While (SZ6->Z6_PEDIDO == cPedid)
			If (SZ6->Z6_CTRL $ "PFT" )
			
				Reclock("SZ6",.F.)
					SZ6->Z6_CTRL  :=  "I"
					SZ6->Z6_USALTP	:= aDhu[2]
					SZ6->Z6_DTALTP	:= aDhu[3]
					SZ6->Z6_HRALTP	:= aDhu[4]
					SZ6->Z6_CTRLEXC	:= 2    	
				SZ6->(MSUnLock())
				
			EndIf
			SZ6->(DbSkip())
		EndDo
	EndIf
	
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO A
	If !(SZ6->(dbSeek((xFilial("SZ6") + cPedid + "A")))) .AND. !(SZ6->(dbSeek((xFilial("SZ6") + cPedid + "E"))))
			
		Reclock("SZ6",.T.)
			SZ6->Z6_FILIAL  := xFilial("SZ6")     	
			SZ6->Z6_COD		:= GETSXENUM("SZ6","Z6_COD") 
			SZ6->Z6_PEDIDO 	:= cPedid
			SZ6->Z6_TPPED 	:= C5_K_TPCL
			SZ6->Z6_CTRL	:= "A"
			SZ6->Z6_TMLPED	:= Posicione("ACY",1,xFilial("ACY")+C5_K_TPCL,"ACY_TMLPED")
			SZ6->Z6_TMLFIN	:= Posicione("ACY",1,xFilial("ACY")+C5_K_TPCL,"ACY_TMLFIN")
			SZ6->Z6_TMLEST	:= Posicione("ACY",1,xFilial("ACY")+C5_K_TPCL,"ACY_TMLEST")
			SZ6->Z6_TMFATU	:= Posicione("ACY",1,xFilial("ACY")+C5_K_TPCL,"ACY_TMFATU")
			SZ6->Z6_TMEMBA	:= Posicione("ACY",1,xFilial("ACY")+C5_K_TPCL,"ACY_TMEMB")
			SZ6->Z6_USCAD 	:= aDhu[2]
			SZ6->Z6_USALTP	:= aDhu[2]
			SZ6->Z6_DTCAD 	:= aDhu[3]
			SZ6->Z6_DTALTP	:= aDhu[3]
			SZ6->Z6_HRCAD 	:= aDhu[4]
			SZ6->Z6_HRALTP	:= aDhu[4]
			aCp[1]			:= SZ6->Z6_COD
			aCp[2]			:= SZ6->Z6_PEDIDO
			aCp[3]			:= SZ6->Z6_TMLPED + SZ6->Z6_TMLFIN + SZ6->Z6_TMLEST + SZ6->Z6_TMFATU + SZ6->Z6_TMEMBA
		SZ6->(MSUnLock())
		
		ConfirmSx8()
		//ORDENA PELO NUMERO DO PEDIDO
		
		SZ6->(dbSetOrder(2))
		
		If (SZ6->(dbSeek((xFilial("SZ6") + aCp[1] + aCp[2]))))
			/*
			//EXECUTA GRAVAÇÃO DE DATAS DE VENCIMENTO
			U_UPD(aCp[1],aCp[2],cValToChar(aCp[3]))
			UPDDH(aCp[1],aCp[2],cValToChar(aCp[3])) 
	 
			Reclock("SZ6",.F.)
				SZ6->Z6_DTLIM 	:= CTOD(UPD->DATALIM)
				SZ6->Z6_HRLIMI 	:= SUBSTR(UPD->HRLIM,1,8)
				SZ6->Z6_DTVP	:= CTOD(UPDDH->DTLP)
				SZ6->Z6_HRVP	:= SUBSTR(UPDDH->HRLP,1,8)
			SZ6->(MSUnLock())

			//Fecha Query
			UPD->(DbCloseArea())
			UPDDH->(DbCloseArea()) 
			*/
		EndIf
			
		//VARRE PEDIDOS E VERIFICA SE EXISTE OUTRO ITEM
		SZ6->(dbSetOrder(6))
		If (SZ6->(dbSeek((xFilial("SZ6") + cPedid ))))
			WHILE (SZ6->Z6_PEDIDO == cPedid)
				If (SZ6->Z6_CTRLEXC > 1 )  
					If (SZ6->(dbSeek((xFilial("SZ6") + cPedid + "0" ))))
						Reclock("SZ6",.F.)
						SZ6->Z6_CTRLEXC	:= 4    	
						SZ6->(MSUnLock())
					EndIf 
				EndIf
				SZ6->(DbSkip())
			EndDo
		EndIf
	//GRAVA ULTIMA ALTERAÇAÕDO  PEDIDO 		
	Else
		Reclock("SZ6",.F.)
			SZ6->Z6_USALTP	:= aDhu[2]
			SZ6->Z6_DTALTP	:= aDhu[3]
			SZ6->Z6_HRALTP	:= aDhu[4]
		SZ6->(MSUnLock())
	EndIf 
		
	SZ6->(dbclosearea('SZ6'))
	RestArea(aArea)
Return

/**********************************************************************************************************************************/
/** user function GRVLIBP()                                                                                                      **/
/** GRAVA USUARIO,DATA HORA E VALIDA A NECESSIDADE DE JUSTIFICATIVA NA LIBERAÇAODO PEDIDO.           														**/
/**********************************************************************************************************************************/ 
User Function GRVLIBP(cNum,cRot)  
	Local 	aArea	:= GetArea()
	Local 	lRet	:= .T.
	Local 	aCp		:= {"",""}
	Local 	cNum	:= cNum
	Local 	cJust	:= ""
	Local	lJustifi:= .F.

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
   
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO P
	If (SZ6->(dbSeek((xFilial("SZ6") + cNum + "A"))))
		//INFORME A JUSTIFICATIVA
		If lJustifi
			SZ6JUST(cNum,"A")
			
			If(SZ6JUST->PEDIDO == cNum)
				cJust	:= aDhu[2] + "-" + U_InfJus(STOD(SZ6JUST->DT_VAL_LIB),SZ6JUST->HR_VAL_LIB,STOD(SZ6JUST->DTA),SZ6JUST->HRA)
			EndIf
			
			SZ6JUST->(DbCloseArea())
		Endif

		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL	:= "P"
			SZ6->Z6_USLIBP 	:= aDhu[2]
			SZ6->Z6_DTLIBP 	:= aDhu[3]                        
			SZ6->Z6_HRLIBP 	:= aDhu[4]
			SZ6->Z6_JSLIBP 	:= cJust
			aCp[1]			:= SZ6->Z6_COD
			aCp[2]			:= SZ6->Z6_PEDIDO
		SZ6->(MSUnLock())
			
		//ORDENA PELO NUMERO DO PEDIDO
		SZ6->(dbSetOrder(2))
		If (SZ6->(dbSeek((xFilial("SZ6") + aCp[1] + aCp[2]))))
			/*
			//EXECUTA GRAVAÇÃO DE DATAS DE VENCIMENTO
			UPDDH(aCp[1],aCp[2]) 
	
			 Reclock("SZ6",.F.)
				SZ6->Z6_DTVF		:= CTOD(UPDDH->DTLF)
				SZ6->Z6_HRVF		:= SUBSTR(UPDDH->HRLF,1,8)
			 SZ6->(MSUnLock())

			//Fecha Query
			UPDDH->(DbCloseArea())
			*/
		EndIf

	//VALIDA SITUACAO ONDE O PEDIDO NAO É MODIFICADO E É LIBERADO 
	ElseIf(SZ6->(dbSeek((xFilial("SZ6") + cNum + "I")))) .AND. !(SZ6->(dbSeek((xFilial("SZ6") + cNum + "P")))) .AND. !(SZ6->(dbSeek((xFilial("SZ6") + cNum + "A")))) .AND.!(SZ6->(dbSeek((xFilial("SZ6") + cNum + "F")))).AND.!(SZ6->(dbSeek((xFilial("SZ6") + cNum + "T")))) 
		//CRIA REGISTROS DE ABERTURA   
		U_GRVZ6(cNum,cRot)
		U_GRVLIBP(cNum,cRot)
	ElseIf 	!(SZ6->(dbSeek((xFilial("SZ6") + cNum)))) 
		//CRIA REGISTROS DE ABERTURA   
		U_GRVZ6(cNum,cRot)
		U_GRVLIBP(cNum,cRot)
	ElseIf (SZ6->(dbSeek((xFilial("SZ6") + cNum + "E")))) 
		//CRIA REGISTROS DE ABERTURA   
		U_GRVZ6(cNum,cRot)
		U_GRVLIBP(cNum,cRot)
	EndIf 

	RestArea(aArea)

	SZ6->(DbCloseArea())

Return lRet

/**********************************************************************************************************************************/
/** user function GRVLIBF()                                                                                                      **/
/** GRAVA USUÁRIO,DATA HORA E VALIDA A NECESSIDADE DE JUSTIFICATIVA NA LIBERAÇÃODO PEDIDO.           														**/
/**********************************************************************************************************************************/ 
User Function GRVLIBF(lFi,cPd)  
	Local 	aArea	:= GetArea()
	Local 	lRet	:= .T. 
	Local 	aCp		:= {"",""}
	Local	cJust	:= ""
	Local	lJustifi:= .F.
	
	//ABRE TABELA DE STATS
	dBselectArea('SZ6')
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()

	If alltrim(SC9->C9_PEDIDO) == "" 
		cPd := cPd
	Else
		cPd :=	SC9->C9_PEDIDO
	EndIf
                           	
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO P
	If (SZ6->(dbSeek((xFilial("SZ6") + cPd + "P")))) 
		
		//INFORME A JUSTIFICATIVA
		if lJustifi
			SZ6JUST(SC9->C9_PEDIDO,"P")
			
			If(SZ6JUST->PEDIDO == SC9->C9_PEDIDO)
				If!(lFi)
					cJust	:= aDhu[2] + " - CLIENTE SEM LIBERACAO FINANCEIRO "
				ElseIf(lFi)
					cJust	:= aDhu[2] + " - " + U_InfJus(STOD(SZ6JUST->DT_VAL_FIN),SZ6JUST->HR_VAL_FIN,STOD(SZ6JUST->DTA),SZ6JUST->HRA)
				EndIf
			EndIf
			
			SZ6JUST->(DbCloseArea())
		Endif

		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL	 	:= "F"
			SZ6->Z6_USLIBF 	:= aDhu[2]
			SZ6->Z6_DTLIBF 	:= aDhu[3]
			SZ6->Z6_HRLIBF 	:= aDhu[4]
			SZ6->Z6_JSLIBF 	:= cJust
			aCp[1]			:= SZ6->Z6_COD
			aCp[2]			:= SZ6->Z6_PEDIDO
		SZ6->(MSUnLock())
			
			//ORDENA PELO NUMERO DO PEDIDO
		SZ6->(dbSetOrder(2))
		If (SZ6->(dbSeek((xFilial("SZ6") + aCp[1] + aCp[2]))))
			//EXECUTA GRAVAÇÃO DE DATAS DE VENCIMENTO
			UPDDH(aCp[1],aCp[2]) 
	
			Reclock("SZ6",.F.)
				SZ6->Z6_DTVE		:= CTOD(UPDDH->DTLE)
				SZ6->Z6_HRVE		:= SUBSTR(UPDDH->HRLE,1,8)
			SZ6->(MSUnLock())

			//Fecha Query
			UPDDH->(DbCloseArea())
		EndIf
	
	EndIf 

	RestArea(aArea)

Return lRet

/**********************************************************************************************************************************/
/** user function GRVLIBE()                                                                                                      **/
/** GRAVA USUÁRIO,DATA HORA E VALIDA A NECESSIDADE DE JUSTIFICATIVA NA LIBERAÇÃODO PEDIDO.           														**/
/**********************************************************************************************************************************/ 
User Function GRVLIBE()  
	Local 	aArea	:= GetArea()
	Local 	lRet	:= .T. 
	Local 	aCp		:= {"",""}
	Local 	cJust	:= ""
	Local	lJustifi:= .F.

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
   
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO P
	If (SZ6->(dbSeek((xFilial("SZ6") + SC9->C9_PEDIDO + "F")))) 
		
		//INFORME A JUSTIFICATIVA
		If lJustifi 
			SZ6JUST(SC9->C9_PEDIDO,"F")
			
			If(SZ6JUST->PEDIDO == SC9->C9_PEDIDO)
				cJust	:= aDhu[2] + " - " + U_InfJus(STOD(SZ6JUST->DT_VAL_EST),SZ6JUST->HR_VAL_EST,STOD(SZ6JUST->DTA),SZ6JUST->HRA)
			EndIf
			
			SZ6JUST->(DbCloseArea())
		Endif

		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL	:= "T"
			SZ6->Z6_USLIBE 	:= aDhu[2]
			SZ6->Z6_DTLIBE 	:= aDhu[3]
			SZ6->Z6_HRLIBE 	:= aDhu[4]
			SZ6->Z6_JSLIBE 	:= cJust
			aCp[1]			:= SZ6->Z6_COD
			aCp[2]			:= SZ6->Z6_PEDIDO
		SZ6->(MSUnLock())
				
		//ORDENA PELO NUMERO DO PEDIDO
		SZ6->(dbSetOrder(2))
		If (SZ6->(dbSeek((xFilial("SZ6") + aCp[1] + aCp[2]))))
			/*
			//EXECUTA GRAVAÇÃO DE DATAS DE VENCIMENTO
			UPDDH(aCp[1],aCp[2]) 
	
			 Reclock("SZ6",.F.)
				SZ6->Z6_DTVFATU		:= CTOD(UPDDH->DTLFA)
				SZ6->Z6_HRVFATU		:= SUBSTR(UPDDH->HRLFA,1,8)
			 SZ6->(MSUnLock())

			//Fecha Query
			UPDDH->(DbCloseArea())
			*/
		EndIf

	EndIf
		
	RestArea(aArea)
Return lRet 
		
/**********************************************************************************************************************************/
/** user function GRVFATU()                                                                                                      **/
/** GRAVA USUÁRIO,DATA HORA E VALIDA A NECESSIDADE DE JUSTIFICATIVA NA LIBERAÇÃODO PEDIDO.           														**/
/**********************************************************************************************************************************/ 
User Function GRVFATU()  
	Local 	aArea	:= GetArea()
	Local 	lRet	:= .T. 
	Local 	aCp		:= {"",""}
	Local 	cJust	:= ""
	Local	lJustifi:= .F.

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
   
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO E
	If (SZ6->(dbSeek((xFilial("SZ6") + SC9->C9_PEDIDO + "T")))) 
		
		//INFORME A JUSTIFICATIVA
		If lJustifi
			SZ6JUST(SC9->C9_PEDIDO,"T")
			
			If(SZ6JUST->PEDIDO == SC9->C9_PEDIDO)
				cJust	:= aDhu[2] + " - " + U_InfJus(STOD(SZ6JUST->DT_VAL_FAT),SZ6JUST->HR_VAL_FAT,STOD(SZ6JUST->DTA),SZ6JUST->HRA)
			EndIf
		SZ6JUST->(DbCloseArea())
		Endif

		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL	:= "U"
			SZ6->Z6_USFATU 	:= aDhu[2]
			SZ6->Z6_DTFATU 	:= aDhu[3]
			SZ6->Z6_HRFATU 	:= aDhu[4]
			SZ6->Z6_JSFATU 	:= cJust
			SZ6->Z6_SERIE 	:= SF2->F2_SERIE
			SZ6->Z6_NF 		:= SF2->F2_DOC
			aCp[1]			:= SZ6->Z6_COD
			aCp[2]			:= SZ6->Z6_PEDIDO
		SZ6->(MSUnLock())
				
		//ORDENA PELO NUMERO DO PEDIDO
		SZ6->(dbSetOrder(2))
		If (SZ6->(dbSeek((xFilial("SZ6") + aCp[1] + aCp[2]))))
			
			//EXECUTA GRAVAÇÃO DE DATAS DE VENCIMENTO
			UPDDH(aCp[1],aCp[2]) 
	
			 Reclock("SZ6",.F.)
//				SZ6->Z6_DTVEMBA		:= CTOD(UPDDH->DTLEM)
//				SZ6->Z6_HRVEMBA		:= SUBSTR(UPDDH->HRLEM,1,8)
			
				//VALIDA A SERIE DA NOTA
				If (SM0->M0_CODIGO $ "0103040506" )
				
					If(UPDDH->SERIE <> '1')
						SZ6->Z6_CTRL	:= "M"				
						SZ6->Z6_USEMBA 	:= 'AUTO'
						SZ6->Z6_DTEMBA 	:= CTOD(UPDDH->DTLEM)
						SZ6->Z6_HREMBA 	:= SUBSTR(UPDDH->HRLEM,1,8)
					ElseIf(UPDDH->SERIE == '1' .AND. (SM0->M0_CODFIL $'020304050607') )	 
						SZ6->Z6_CTRL	:= "M"				
						SZ6->Z6_USEMBA 	:= 'AUTO'
						SZ6->Z6_DTEMBA 	:= CTOD(UPDDH->DTLEM)
						SZ6->Z6_HREMBA 	:= SUBSTR(UPDDH->HRLEM,1,8)			
					EndIf   
						
				ElseIf((SM0->M0_CODIGO $ "02" ))  
					If(UPDDH->SERIE <> '2')
						SZ6->Z6_CTRL	:= "M"
						SZ6->Z6_USEMBA 	:= 'AUTO'
						SZ6->Z6_DTEMBA 	:= CTOD(UPDDH->DTLEM)
						SZ6->Z6_HREMBA 	:= SUBSTR(UPDDH->HRLEM,1,8)
					EndIf
				EndIf
			SZ6->(MSUnLock())
			
			//Fecha Query
			UPDDH->(DbCloseArea())
		EndIf
	EndIf 

	RestArea(aArea)
Return lRet 

/**********************************************************************************************************************************/
/** user function GRVEMB()                                                                                                       **/
/** GRAVA USUÁRIO,DATA HORA NO EMBARQUES      														                             **/
/**********************************************************************************************************************************/ 
User Function GREMB(cNump,cDoc,cSerie,dDtEmis,cHrEmis,cUsFat)  
	Local 	aArea	:= GetArea()
	Local 	lRet	:= .T. 
	Local 	aCp		:= {"",""}
	Local 	cJust	:= ""
	Local	lJustifi:= .F.
	
	Default cDoc 	:= ""
	Default cSerie 	:= ""
	Default dDtEmis	:= Stod("")
	Default cUsFat	:= ""

	if Empty(AllTrim(cNump))
		Return lRet
	Endif

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()

	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS COM CONTROLE TIPO E 
	If (SZ6->(dbSeek((xFilial("SZ6") + cNump )))) 
		
		if lJustifi
			//INFORME A JUSTIFICATIVA
			SZ6JUST(cNump,"U")
			
			If(SZ6JUST->PEDIDO == cNump)
				cJust	:= aDhu[2] + " - " + U_InfJus(STOD(SZ6JUST->DT_VAL_FAT),SZ6JUST->HR_VAL_FAT,STOD(SZ6JUST->DTA),SZ6JUST->HRA)
			EndIf
			
			SZ6JUST->(DbCloseArea())
		Endif
		
		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL	:= "M"
			SZ6->Z6_USEMBA 	:= aDhu[2]
			SZ6->Z6_DTEMBA 	:= aDhu[3]
			SZ6->Z6_HREMBA 	:= aDhu[4]
			SZ6->Z6_JSEMBA 	:= cJust
			
			If Empty(AllTrim(SZ6->Z6_NF))
				SZ6->Z6_NF 		:= cDoc
			Endif
			
			if Empty(AllTrim(SZ6->Z6_SERIE))
				SZ6->Z6_SERIE 	:= cSerie 
			Endif
			
			If Empty(SZ6->Z6_DTFATU)
				SZ6->Z6_DTFATU 	:= dDtEmis
			Endif
			
			If Empty(AllTrim(SZ6->Z6_USFATU))
				SZ6->Z6_USFATU 	:= cUsFat
			Endif
			
			If Empty(AllTrim(SZ6->Z6_HRFATU))
				SZ6->Z6_HRFATU 	:= cHrEmis
			Endif

		SZ6->(MSUnLock())
	EndIf
	
	RestArea(aArea)
Return lRet 

/**********************************************************************************************************************************/
/** user function DELSTS()                                                                                                       **/
/** MARCA COMO DELETADO.           																																															 **/
/**********************************************************************************************************************************/ 
User Function DELSTS()  
	Local aArea	:= GetArea()
	Local lRet	:= .T.
	Local aDhu	:= {}

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')                                                                                                	
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
	   
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS
	If (SZ6->(dbSeek((xFilial("SZ6") + C5_NUM ))))
		While (SZ6->Z6_PEDIDO == C5_NUM)
			If (SZ6->Z6_CTRL $ "AFT" )

				Reclock("SZ6",.F.)
					SZ6->Z6_CTRL  :=  "E"
					SZ6->Z6_USALTP	:= aDhu[2]
					SZ6->Z6_DTALTP	:= aDhu[3]
					SZ6->Z6_HRALTP	:= aDhu[4] 
					SZ6->Z6_CTRLEXC	:= 3   	
				SZ6->(MSUnLock())

			EndIf
			SZ6->(DbSkip())
		EndDo
	EndIf 

	SZ6->(dbclosearea())
	RestArea(aArea)
Return	nil 

/**********************************************************************************************************************************/
/** user function DELSTU()                                                                                                      **/
/** GRAVA USUÁRIO,DATA HORA E VALIDA A NECESSIDADE DE JUSTIFICATIVA NA LIBERAÇÃODO PEDIDO.           														**/
/**********************************************************************************************************************************/ 
User Function DELSTU()  
	Local aArea	:= GetArea()
	Local lRet	:= .T. 
	Local aDhu	:= {}

	//ABRE TABELA DE STATS
	dBselectArea('SZ6')                                                                                                	
	//ORDENA PELO NUMERO DO PEDIDO
	SZ6->(dbSetOrder(5))

	aDhu	:= U_KPFATA04()
   
	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS
	If (SZ6->(dbSeek((xFilial("SZ6") + SC9->C9_PEDIDO + "U"))))
			
		Reclock("SZ6",.F.)
			SZ6->Z6_CTRL  :=  "I"
			SZ6->Z6_USALTP	:= aDhu[2]
			SZ6->Z6_DTALTP	:= aDhu[3]
			SZ6->Z6_HRALTP	:= aDhu[4]
			SZ6->Z6_CTRLEXC	:= 2    	
		SZ6->(MSUnLock())
																								  
	EndIf 

	SZ6->(dbclosearea('SZ6'))
	RestArea(aArea)
Return	nil  

/**********************************************************************************************************************************/
/** user function UDTV()                                                                                                      **/
/** GRAVA DATA E HORA DO LIMITE DE LIBERACAO.           														**/
/**********************************************************************************************************************************/  

Static Function UDTV(cCod,cPedi,cToh)  
	Local aArea	:= GetArea()
	Local cQuery  := ""  

	cQuery := " SELECT		 CONVERT(VARCHAR,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME),103) DATALIM

	cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME))DTINT

	cQuery += "		,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME)) HRLIM

			
	cQuery += " FROM "+RetSqlName("SZ6")+" SZ6 "

	cQuery += " WHERE	SZ6.D_E_L_E_T_ =	''
	cQuery += "	AND SZ6.Z6_COD = '"+cCod+"'
	cQuery += "	AND SZ6.Z6_PEDIDO = '"+cPedi+"' 
	cQuery += "	AND SZ6.Z6_FILIAL= '"+xFilial("SZ6")+"' " 

	//Define o alias da query
	TcQuery cQuery New Alias "UDTV"

	RestArea(aArea)

Return 


/**********************************************************************************************************************************/
/** user function DELSTU()                                                                                                      **/
/** GRAVA DATA E HORA DO LIMITE DE LIBERACAO.           																																				**/
/**********************************************************************************************************************************/  
Static Function UPDDH(cCod,cPedi,cToh)  

	Local aArea	:= GetArea()
	Local cQuery  := ""  

					
	cQuery := " SELECT CONVERT(VARCHAR,CONVERT(DATETIME,SZ6.Z6_DTCAD)+CONVERT(DATETIME,SZ6.Z6_HRCAD)+CAST(DATEADD(HH,SZ6.Z6_TMLPED,'00:00:00') AS DATETIME),103) DTLP		
	cQuery += "	,SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTCAD)+CONVERT(DATETIME,GETDATE())+CAST(DATEADD(HH,SZ6.Z6_TMLPED,'00:00:00') AS DATETIME))),1,8) HRLP 

	cQuery += "	,CONVERT(VARCHAR,GETDATE()+CAST(DATEADD(HH,SZ6.Z6_TMLFIN,'00:00:00') AS DATETIME),103) DTLF
	cQuery += "	,SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTVP)+CONVERT(DATETIME,GETDATE())+CAST(DATEADD(HH,SZ6.Z6_TMLFIN,'00:00:00') AS DATETIME))),1,8) HRLF  

	cQuery += "	,CONVERT(VARCHAR,GETDATE()+CAST(DATEADD(HH,SZ6.Z6_TMLEST,'00:00:00') AS DATETIME),103) DTLE
	cQuery += "	,SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTVF)+CONVERT(DATETIME,GETDATE())+CAST(DATEADD(HH,SZ6.Z6_TMLEST,'00:00:00') AS DATETIME))),1,8) HRLE 

	cQuery += "	,CONVERT(VARCHAR,GETDATE()+CAST(DATEADD(HH,SZ6.Z6_TMFATU,'00:00:00') AS DATETIME),103) DTLFA
	cQuery += "	,SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTVE)+CONVERT(DATETIME,GETDATE())+CAST(DATEADD(HH,SZ6.Z6_TMFATU,'00:00:00') AS DATETIME))),1,8) HRLFA

	cQuery += "	,CONVERT(VARCHAR,GETDATE()+CAST(DATEADD(HH,SZ6.Z6_TMEMBA,'00:00:00') AS DATETIME),103) DTLEM
	cQuery += "	,SUBSTRING(CONVERT(VARCHAR,CONVERT(TIME,CONVERT(DATETIME,SZ6.Z6_DTVFATU)+CONVERT(DATETIME,GETDATE())+CAST(DATEADD(HH,SZ6.Z6_TMEMBA,'00:00:00') AS DATETIME))),1,8) HRLEM

	cQuery += "       ,SZ6.Z6_NF NOTA
	cQuery += "       ,SZ6.Z6_SERIE SERIE

	cQuery += " FROM "+RetSqlName("SZ6")+" SZ6 "

	cQuery += " WHERE	SZ6.D_E_L_E_T_ =	''
	cQuery += "	AND SZ6.Z6_COD = '"+cCod+"'
	cQuery += "	AND SZ6.Z6_PEDIDO = '"+cPedi+"' 
	cQuery += " AND SZ6.Z6_FILIAL= '"+xFilial("SZ6")+"' " 


	//Define o alias da query
	TcQuery cQuery New Alias "UPDDH"

	RestArea(aArea)

Return 

/**********************************************************************************************************************************/
/** user function SZ6JUST()                                                                                                     **/
/**********************************************************************************************************************************/
/******************************************************************************************'****************************************/ 

Static Function SZ6JUST(cPedJust,cCtrlp)

	Local aArea 	:= GetArea()
	Local cQuery  := ""         
											  
	cQuery := " 	SELECT		 SZ6.Z6_CTRL	CONTROLE
	cQuery += "			,SZ6.Z6_COD		CODIGO
	cQuery += "			,SZ6.Z6_PEDIDO	PEDIDO
	cQuery += "     ,SZ6.Z6_HRCAD HR_CADASTRO
	cQuery += "     ,SZ6.Z6_DTCAD DT_CADASTRO
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD))	VC
	cQuery += "     ,SZ6.Z6_DTLIM		DTLIM
	cQuery += "     ,SZ6.Z6_HRLIMI	HRLIM
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTLIM) + CONVERT(DATETIME,SZ6.Z6_HRLIMI))LIM
	cQuery += "     ,SZ6.Z6_DTVP	DT_VAL_LIB
	cQuery += "     ,SZ6.Z6_HRVP	HR_VAL_LIB
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVP) + CONVERT(DATETIME,SZ6.Z6_HRVP))	VP
	cQuery += "     ,SZ6.Z6_DTVF	DT_VAL_FIN
	cQuery += "     ,SZ6.Z6_HRVF	HR_VAL_FIN
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVF) + CONVERT(DATETIME,SZ6.Z6_HRVF))	VF
	cQuery += "     ,SZ6.Z6_DTVE	DT_VAL_EST
	cQuery += "     ,SZ6.Z6_HRVE	HR_VAL_EST
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVE) + CONVERT(DATETIME,SZ6.Z6_HRVE))VE
	cQuery += "     ,SZ6.Z6_DTVFATU	DT_VAL_FAT
	cQuery += "     ,SZ6.Z6_HRVFATU	HR_VAL_FAT
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU))VFATU
	cQuery += "     ,SZ6.Z6_DTVEMBA	DT_VAL_EMB
	cQuery += "     ,SZ6.Z6_HRVEMBA	HR_VAL_EMB
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVEMBA) + CONVERT(DATETIME,SZ6.Z6_HRVEMBA))VEMBA
	cQuery += "     ,CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))DATAAT 
	cQuery += "     ,CONVERT(VARCHAR,CONVERT(DATETIME,GETDATE()),112)DTA
	cQuery += "     ,SUBSTRING(CONVERT(VARCHAR,(CONVERT(TIME,CONVERT(DATETIME,GETDATE())))),1,8)HRA
				
			
	cQuery += "		FROM		"+RetSqlName("SZ6")+" SZ6, "
	cQuery += "						"+RetSqlName("ACY")+" ACY, "
	cQuery += "						"+RetSqlName("SC5")+" SC5 "

	cQuery += " 	WHERE		SZ6.D_E_L_E_T_	= ''
	cQuery += "		AND SC5.D_E_L_E_T_	= ''
	cQuery += "		AND ACY.D_E_L_E_T_	= ''
	cQuery += "		AND SZ6.Z6_FILIAL= '" + xFilial("SZ6") + "' " 
	cQuery += "		AND SZ6.Z6_PEDIDO	= SC5.C5_NUM
	cQuery += "		AND SZ6.Z6_TPPED	= ACY.ACY_GRPVEN
	cQuery += "		AND SZ6.Z6_FILIAL	= SC5.C5_FILIAL
	cQuery += "		AND SZ6.Z6_PEDIDO	= '"+cPedJust+"'
	cQuery += "		AND	SZ6.Z6_CTRL = '"+cCtrlp+"'

	If (cCtrlp = 'A')

			cQuery += "   AND CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVP) + CONVERT(DATETIME,SZ6.Z6_HRVP)) <  CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))
			
	ElseIf(cCtrlp = 'P') 

		  cQuery += "   AND CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVF) + CONVERT(DATETIME,SZ6.Z6_HRVF)) <  CONVERT(FLOAT,CONVERT(DATETIME,GETDATE())) 
		  
	ElseIf(cCtrlp = 'F') 

		  cQuery += "   AND CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVE) + CONVERT(DATETIME,SZ6.Z6_HRVE)) <  CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))
		  
	ElseIf(cCtrlp = 'T') 

		  cQuery += "   AND CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVFATU) + CONVERT(DATETIME,SZ6.Z6_HRVFATU)) <  CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))   
		  
	ElseIf(cCtrlp = 'U') 

		  cQuery += "   AND CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTVEMBA) + CONVERT(DATETIME,SZ6.Z6_HRVEMBA)) <  CONVERT(FLOAT,CONVERT(DATETIME,GETDATE()))

	EndIf
	cQuery += "	ORDER BY	SZ6.Z6_PEDIDO, SZ6.Z6_COD		
	 
	//Define o alias da query
	TcQuery cQuery New Alias "SZ6JUST"

	RestArea(aArea) 

	/*
	A - CADASTRADO	- BR_VERDE
	P - LIBERADO	- BR_AZUL
	F - FINANCEIRO	- R_AMARELO
	T - ESTOQUE	- AVGARMAZEM
	U - FATURAMENTO	- RPMCABEC
	M - EMBARCADO	- OK
	E - EXCLUIDO	- DISABLE
	I - INATIVO 	- BR_PRETO
	*/

return Nil   

/**********************************************************************************************************************************/
/** Compras                                                                                                                      **/                                                                                                       
/** Tela Justificativa.                             **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                   **/ 
/**********************************************************************************************************************************/
User Function InfJus(cTxdp,cTxhp,cTxda,cTxha)
	Local 	aArea	:= GetArea()
	Private oTelaj 	:= Nil
	Private oGetJus	:= Nil
	Private cGetJus	:= ""
	Private oDlg	:= nil
	Private oTxdp	:= Nil
	Private oTxhp	:= Nil
	Private oTxdi	:= Nil
	Private oTxhi	:= Nil  
   
	//Tela
	DEFINE MSDIALOG oTelaj Title "" Pixel Style 128 From 145,000 To 360,400

		//Bloqueia a tecla ESC
		oTelaj:lEscClose := .F.

		//Grupo1
		@ 003, 005 To 90, 200 Title "Data Prevista Exedida - Informe o Motivo"

		//Caixa de Texto 1
		//@ 006, 015 Say oSayGrp Prompt "Justificativa Do: "  Size 090, 030 Of oTela Pixel
		@ 016, 015 GET oGetJus VAR cGetJus OF oDlg MULTILINE SIZE 171, 034 COLORS 0, 16777215 HSCROLL PIXEL

		oTxdi:= tSay():New(52,015,{||'Data Atual: '+DTOC(cTxda)+'' 			},oTelaj,,,,,,.T.,CLR_BLACK	,CLR_WHITE,100,20)
		oTxhi:= tSay():New(60,015,{||'Hora Atual: '+SUBSTR(cTxha,1,8)+'' 	},oTelaj,,,,,,.T.,CLR_BLACK	,CLR_WHITE,100,20)
		oTxdp:= tSay():New(70,015,{||'Data Prevista: '+DTOC(cTxdp)+'' 		},oTelaj,,,,,,.T.,CLR_RED	,CLR_WHITE,100,20)
		oTxhp:= tSay():New(78,015,{||'Hora Prevista: '+cTxhp+'' 			},oTelaj,,,,,,.T.,CLR_RED	,CLR_WHITE,100,20)

		//Botão para gravar justificativa
		@ 072, 146 Button "Confirmar" Size 040, 015 Pixel Of oTelaj Action U_ValMot(cGetJus) 

	//Inicia a tela
	Activate MsDialog oTelaj Centered

	RestArea(aArea) 

Return cGetJus

/**********************************************************************************************************************************/
/** Compras                                                                                                                      **/                                                                                                        
/** Retorna falso para cancelar.                                                                                                 **/
/**********************************************************************************************************************************/
user function CanAct()
	Local aArea	:= GetArea()
	Local lRet	:= .F.

	Close(oTelaj)
  
	RestArea(aArea)
Return lRet 

/**********************************************************************************************************************************/
/** user function ValMot()                                                                                                       **/
/**********************************************************************************************************************************/
user function ValMot(cMot)
	Local aArea 	:= GetArea()
 	Local lRet 		:=	.F.     
 	
	if 	AllTrim(cMot) <> "" .AND. (Len(AllTrim(cMot)) > 10)
		lRet :=	.T.
		U_CanAct()
		RestArea(aArea)
		Return lRet
	Else
		MSGBOX("Obrigatório - Informe o Motivo")
	EndIf

	RestArea(aArea)
  
Return lRet         

/**********************************************************************************************************************************/
/** user function UDTV()                                                                                                         **/
/** GRAVA DATA E HORA DO LIMITE DE LIBERACAO.           														                 **/
/**********************************************************************************************************************************/  
User Function UPD(cCod,cPedi,cToh)  

	Local aArea	:= GetArea()
	Local cQuery  := ""

	cQuery := "	SELECT 
	cQuery += "	*
	cQuery += "	FROM
	cQuery += "	(
	cQuery += " SELECT		 CONVERT(VARCHAR,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME),103) DATALIM
	cQuery += "		,convert(varchar,convert(TIME,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME))) HRLIM
	cQuery += "		,CONVERT(FLOAT,CONVERT(DATETIME,SZ6.Z6_DTCAD) + CONVERT(DATETIME,SZ6.Z6_HRCAD) + CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME))DTINT
	cQuery += "   ,CONVERT(DATETIME,SZ6.Z6_DTCAD)  AS COL2
	cQuery += "   ,CONVERT(DATETIME,SZ6.Z6_HRCAD) AS COL1     
	cQuery += "   ,CAST(DATEADD(HH,CONVERT(INT,'" + cToh + "'), '00:00:00') AS DATETIME) AS COL3
	cQuery += " FROM "+RetSqlName("SZ6")+" SZ6 "

	cQuery += " WHERE	SZ6.D_E_L_E_T_ 	=	''
	cQuery += "	AND SZ6.Z6_COD 				= '"+cCod+"'
	cQuery += "	AND SZ6.Z6_PEDIDO 		= '"+cPedi+"'   
	cQuery += "	AND SZ6.Z6_FILIAL			= '"+xFilial("SZ6")+"' "   
	cQuery += "	) AS TAB1

	//Define o alias da query
	TcQuery cQuery New Alias "UPD"

	RestArea(aArea)

Return nil 
