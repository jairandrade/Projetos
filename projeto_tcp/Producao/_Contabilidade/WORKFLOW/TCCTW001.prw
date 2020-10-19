#include "totvs.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} TCCTW001
    Workflow de aprovação Pré-Lançamento contábil CT2
    @type  Function
    @author Willian Kaneta
    @since 17/06/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCCTW001(nOpc,aCabCT2,aLctoCt2,nRecnoCT2,cEmailUserAlt)
    Local cAliasTmp     := GetNextAlias()
    Local cHttpServer   := "http://" + Alltrim(GetMV("MV_ENDWF")) + ":" + AllTrim(GetMv("TCP_PORTWF"))
    Local cUrl          := cHttpServer + "/pp/u_tcwfctret.apl?"
	Local cPictVlr    	:= PesqPict("CT2","CT2_VALOR")
	Local cUsrAltLc     := ""
	Local cIndex		:= ""
	Local nX			:= 0
	Local vfilial 		:= ""
	Local cNumDocSCR	:= ""
	Local _vStatusW		:= ""
	Local lManual		:= IIF(CT2->CT2_MANUAL=="1",.T.,.F.)

	Default aCabCT2		:= {}
	Default aLctoCt2	:= {}
    
    BeginSql Alias cAliasTmp
        SELECT  *
		FROM %TABLE:CT2% CT2
		WHERE CT2.CT2_FILIAL     = %xFilial:CT2%
            AND CT2.CT2_DATA     = %EXP:DTOS(CT2->CT2_DATA)%
            AND CT2.CT2_LOTE     = %EXP:CT2->CT2_LOTE%
            AND CT2.CT2_SBLOTE   = %EXP:CT2->CT2_SBLOTE%
            AND CT2.CT2_DOC      = %EXP:CT2->CT2_DOC%
			AND CT2.CT2_TPSALD   = '9'
            AND CT2.%NOTDEL% 
    EndSql

	//MemoWrite("C:\Temp\tcp_LCO_CONTABIL.txt",getlastquery()[2])
    If !(cAliasTmp)->( Eof() ) .OR. (Len(aCabCT2) != 0 .AND. Len(aLctoCt2) != 0 )

        oMail := TCPMail():New()
        
		If nOpc == 1
			oHtml := TWFHtml():New("\WORKFLOW\HTML\WFAPRLCMAN.html")
			If CT2->CT2_MANUAL == "1"
				oHtml:ValByName("HEADER","MANUAL ACCOUNTING ENTRIES APPROVAL WORKFLOW")
			ElseIf CT2->CT2_MANUAL == "2"
				oHtml:ValByName("HEADER","RECLASSIFICATION ACCOUNTING ENTRIES APPROVAL WORKFLOW")
			EndIf
			oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
		ElseIf nOpc == 2 .OR. nOpc == 3
			DbSelectArea("CT2")
			CT2->(DbGoTo(nRecnoCT2))
			lManual	:= IIF(CT2->CT2_MANUAL=="1",.T.,.F.)
			oHtml := TWFHtml():New("\WORKFLOW\HTML\WFRETAPRLCMAN.html")
			If CT2->CT2_MANUAL == "1"
				oHtml:ValByName("HEADER","MANUAL ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Accounting pre entry has been ' + If(nOpc==2, '<font color="green"><strong>APPROVED</strong></font>' , '<font color="red"><strong>REJECTED</strong></font>') + ' on ' + DTOC(dDatabase) +  '.' )
			ElseIf CT2->CT2_MANUAL == "2"
				oHtml:ValByName("HEADER","RECLASSIFICATION ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Accounting entry has been ' + If(nOpc==2, '<font color="green"><strong>APPROVED</strong></font>' , '<font color="red"><strong>REJECTED</strong></font>') + ' on ' + DTOC(dDatabase) +  '.' )
			EndIf
		ElseIf nOpc == 4
			oHtml := TWFHtml():New("\WORKFLOW\HTML\WFRETAPRLCMAN.html")
			If CT2->CT2_MANUAL == "1"
				oHtml:ValByName("HEADER","MANUAL ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Accounting pre entry has been <font color="orange"><strong>DELETED</strong></font>' + ' on ' + DTOC(dDatabase) +  ' by <font color="orange"><strong>' + UsrFullName(RetCodUsr()) + '</strong></font>.' )
			ElseIf CT2->CT2_MANUAL == "2"
				oHtml:ValByName("HEADER","ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Accounting entry has been <font color="orange"><strong>DELETED</strong></font>' + ' on ' + DTOC(dDatabase) +  ' by <font color="orange"><strong>' + UsrFullName(RetCodUsr()) + '</strong></font>.' )
			EndIf
			AADD((oHtml:ValByName("ap.nivelalcada")),"")
			AADD((oHtml:ValByName("ap.nomeaprovadorresp")),"")
			AADD((oHtml:ValByName("ap.statusalcada")),"")
			AADD((oHtml:ValByName("ap.nomeaprovador")),"")
			AADD((oHtml:ValByName("ap.dataaprocacao")),"")
		ElseIf nOpc == 5
			oHtml := TWFHtml():New("\WORKFLOW\HTML\WFRETAPRLCMAN.html")
			If CT2->CT2_MANUAL == "1"
				oHtml:ValByName("HEADER","MANUAL ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Pre accounting entry has been <font color="black"><strong>INCLUDED</strong></font>' + ' on ' + DTOC(dDatabase) +  ' by <font color="black"><strong>' + UsrFullName(RetCodUsr()) + '</strong></font>.' )
			ElseIf CT2->CT2_MANUAL == "2"
				oHtml:ValByName("HEADER","RECLASSIFICATION ACCOUNTING ENTRIES APPROVAL WORKFLOW")
				oHtml:ValByName("EMPRESA", Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM]))
				oHtml:ValByName("MSGRETURN",'Accounting entry has been <font color="black"><strong>RECLASSIFIED</strong></font>' + ' on ' + DTOC(dDatabase) +  ' by <font color="black"><strong>' + UsrFullName(RetCodUsr()) + '</strong></font>.' )
			EndIf
		EndIf			

		If nOpc == 1 .OR. nOpc == 5
			cUsrAltLc     := FWLeUserlg("CT2_USERGA",1)
			dbSelectArea( cAliasTMP )
			(cAliasTMP)->( dbGotop() )
			//Indice 1 CT2
			//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, R_E_C_N_O_, D_E_L_E_T_            

			cIndex :=	(cAliasTMP)->CT2_DATA 		+;
						(cAliasTMP)->CT2_LOTE 		+;
						(cAliasTMP)->CT2_SBLOTE 	+;
						(cAliasTMP)->CT2_DOC
			vfilial 	:= (cAliasTMP)->CT2_FILIAL
			cNumDocSCR 	:= cIndex

			While !(cAliasTMP)->( Eof() )
				AADD( (oHtml:ValByName( "it.item1" )), (cAliasTMP)->CT2_LINHA             )          
				AADD( (oHtml:ValByName( "it.item2" )), (cAliasTMP)->CT2_FILIAL            )          
				AADD( (oHtml:ValByName( "it.item3" )), (cAliasTMP)->CT2_LOTE              )   
				AADD( (oHtml:ValByName( "it.item4" )), (cAliasTMP)->CT2_DOC               )   
				AADD( (oHtml:ValByName( "it.item5" )), DTOC(STOD((cAliasTMP)->CT2_DATA))  ) 
				AADD( (oHtml:ValByName( "it.item6" )), (cAliasTMP)->CT2_DEBITO            )    
				AADD( (oHtml:ValByName( "it.item7" )), (cAliasTMP)->CT2_CREDIT            )     
				AADD( (oHtml:ValByName( "it.item8" )), AllTrim(Transform((cAliasTMP)->CT2_VALOR,cPictVlr)))   
				AADD( (oHtml:ValByName( "it.item9" )), (cAliasTMP)->CT2_HIST              )     
				AADD( (oHtml:ValByName( "it.item10")), cUsrAltLc                          )

				(cAliasTMP)->( dbSkip() )
			EndDo
			
			If nOpc == 1
				//Aprovar
				cHash       := cUrl + Encode64("funcName=u_TCCT01RET"			+;
												"&empresa=" + cEmpAnt 			+;
												"&filial=" 	+ CT2->CT2_FILIAL	+;
												"&opc=4" 						+;
												"&aprv="	+ SCR->CR_APROV		+;
												"&cod="	 	+ cIndex)

				oHtml:ValByName("link_apr", cHash )
				
				//Rejeitar
				cHash       := cUrl + Encode64("funcName=u_TCCT01RET"			+;
												"&empresa=" + cEmpAnt 			+;
												"&filial=" 	+ CT2->CT2_FILIAL	+;
												"&opc=7" 						+;
												"&aprv="	+ SCR->CR_APROV		+;
												"&cod="	 	+ cIndex)
				
				oHtml:ValByName("link_rej", cHash )
			EndIf
		Else
			DbSelectArea("CT2")
			CT2->(DbGoTo(nRecnoCT2))
			
			vfilial 	:= CT2->CT2_FILIAL
			cNumDocSCR 	:= CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
			cUsrAltLc   := FWLeUserlg("CT2_USERGA",1)
			
			For nX := 1 To Len(aLctoCt2)
				AADD( (oHtml:ValByName( "it.item1" )), aLctoCt2[nX][1][3]		                        )          
				AADD( (oHtml:ValByName( "it.item2" )), aLctoCt2[nX][2][2]		                        )          
				AADD( (oHtml:ValByName( "it.item3" )), aCabCT2[2][2]			                        )   
				AADD( (oHtml:ValByName( "it.item4" )), aCabCT2[4][2]			                        )   
				AADD( (oHtml:ValByName( "it.item5" )), DTOC(aCabCT2[1][2])		                        ) 
				AADD( (oHtml:ValByName( "it.item6" )), aLctoCt2[nX][5][2]		                        )    
				AADD( (oHtml:ValByName( "it.item7" )), aLctoCt2[nX][6][2]		                        )     
				AADD( (oHtml:ValByName( "it.item8" )), AllTrim(Transform(aLctoCt2[nX][7][2],cPictVlr))	)   
				AADD( (oHtml:ValByName( "it.item9" )), aLctoCt2[nX][12][2])     
				AADD( (oHtml:ValByName( "it.item10")), cUsrAltLc)
			Next nX

		EndIf

		If nOpc != 1
					
			BeginSql Alias "QSCRX"
				SELECT SCR.*
				FROM %table:SCR% SCR
				WHERE SCR.CR_FILIAL = %Exp:vfilial%
				AND SCR.CR_NUM = %Exp:cNumDocSCR%
				AND SCR.CR_TIPO = 'LC'
				AND SCR.%NotDel%
			EndSql
			
			while !QSCRX->(EOF())

				_vStatusW := QSCRX->CR_STATUS
				if _vStatusW == "01"
					_vStatusW := "Waiting for the others levels approvement"
				endif
				if _vStatusW == "02"
					_vStatusW := "Pending"
				endif
				if _vStatusW == "03"
					_vStatusW := "Approved"
				endif
				if _vStatusW == "04"
					_vStatusW := "Blocked"
				endif
				if _vStatusW == "05"
					_vStatusW := "Approved / Blocked by level"
				endif
				if _vStatusW == "06" .OR. _vStatusW == "07"
					_vStatusW := "Reject"
				endif
				AADD((oHtml:ValByName("ap.nivelalcada")),STRZERO(VAL(QSCRX->CR_NIVEL),2))
				AADD((oHtml:ValByName("ap.nomeaprovadorresp")),AllTrim(fGetUsrName(QSCRX->CR_USER)))
				AADD((oHtml:ValByName("ap.statusalcada")),_vStatusW)
				AADD((oHtml:ValByName("ap.nomeaprovador")),u_xRetAprv(QSCRX->CR_USERLIB,STOD(QSCRX->CR_DATALIB)))
				AADD((oHtml:ValByName("ap.dataaprocacao")),STOD(QSCRX->CR_DATALIB))

				QSCRX->(dbSkip())
			
			enddo
			
			QSCRX->(dbCloseArea())
		EndIf
		
		If nOpc == 1 .OR. nOpc == 5
			SendMail(oHtml,oMail,SCR->CR_USER,nOpc,lManual)
		Else
			SendMail(oHtml,oMail,,nOpc,lManual,cEmailUserAlt)
		EndIf
        
        FreeObj(oMail)
    EndIf
    
    If Select(cAliasTmp) > 0
        (cAliasTmp)->( dbCloseArea() )
    EndIf

Return( Nil )

/*/{Protheus.doc} SendMail
description
@type function
@version 
@author kaiquesousa
@since 6/4/2020
@param oHtml, object, param_description
@param oMail, object, param_description
@param cUserID, character, param_description
@return return_type, return_description
/*/

Static Function SendMail( oHtml, oMail, cUserID, nOpc, lManual, cEmailUserAlt )
    
    Local cName := ""
    Local cMail := ""
    Local cErro := ""
	Local cSubj	:= ""
	
	If nOpc == 1
		cName := UsrFullName(cUserID) 
		cMail := UsrRetMail(cUserID)
		If lManual
			cSubj := "Manual Accounting Entries Approval on " + DTOC(DATE()) + ' - ' + cName  
		ElseIf !lManual
			cSubj := "Reclassification Accounting Entries Approval on " + DTOC(DATE()) + ' - ' + cName  
		EndIf
	Else
		cMail := RETEMAILS(nOpc,cEmailUserAlt)
		If lManual
			cSubj := "Manual Accounting Entries Approval on " + DTOC(DATE())
		ElseIf !lManual
			cSubj := "Reclassification Accounting Entries Approval on " + DTOC(DATE())
		EndIf

	EndIf

    oMail:SendMail( cMail,;
                    cSubj,;
                    oHtml:HtmlCode(),;
                    @cErro,;
                    {})
Return( Nil )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TCCT01RET
//Trata o retorno do workflow.
@author Kaique Mathias
@since 01/04/2020
@version undefined
@type user function
/*/
// -------------------------------------------------------------------------------------
User Function TCCT01RET(aParamVar)
	Local cTitle 	:= ""
	Local cReturn 	:= ""
	Local cBKPUserId:= ""
	Local cEmailAlt	:= ""
	Local aCab    	:= {}
	Local aItens  	:= {}
	Local aRecnosCT2:= {}
	Local aItensRej	:= {}
	Local lReturn 	:= .T.
	Local lRejeita	:= .F.
	Local lOk		:= .F.
	Local lJAprov	:= .F.
	Local nX		:= 0
	Local nRecnoCT2	:= 0
	Local oModel094	:= NIl
	Local nOpc      := VAL(aParamVar[3][2])
	Local nLenSCR 	:= TamSX3("CR_NUM")[1]
	Local cFil      := aParamVar[2][2]
	Local cAprov	:= aParamVar[4][2]
	Local cCodigo	:= aParamVar[5][2] //CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
	
	Private lMsErroAuto := .F.

	DbSelectArea("SCR")
    SCR->(dbSetOrder(3))

    If SCR->(MsSeek(cFil+"LC"+Padr(cCodigo,nLenSCR)+cAprov))
        While SCR->(!EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_APROV) == (cFil+"LC"+Padr(cCodigo,nLenSCR)+cAprov)
			If SCR->CR_STATUS == "02"
				lJAprov := .T.
				//Aprovar
				If ( nOpc == 4 )
					lLiberou := MaAlcDoc({  Padr(cCodigo,nLenSCR),;
						SCR->CR_TIPO,;
						SCR->CR_TOTAL,;
						SCR->CR_APROV,;
						,;
						SCR->CR_GRUPO,;
						,;
						,;
						,;
						,;
						""},;
						dDataBase,;
						nOpc)
					If lLiberou
						aCab    := {}
						aItens  := {}

						DbSelectArea("CT2")
						CT2->(DbSetOrder(1))
						//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
						If CT2->(MsSeek(cFil+cCodigo))
							nRecnoCT2 := CT2->(Recno())
							cEmailAlt := UsrRetMail(SubStr(Embaralha(CT2->CT2_USERGA,1),3,6))
							aAdd(aCab,  {'DDATALANC'    ,CT2->CT2_DATA	,NIL} )
							aAdd(aCab,  {'CLOTE'        ,CT2->CT2_LOTE  ,NIL} )
							aAdd(aCab,  {'CSUBLOTE'		,CT2->CT2_SBLOTE,NIL} )
							aAdd(aCab,  {'CDOC'         ,CT2->CT2_DOC   ,NIL} )
							
							While CT2->(!EOF()) .AND. CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)==cFil+cCodigo
								aAdd(aItens,{   {'LINPOS'         ,'CT2_LINHA'		,CT2->CT2_LINHA},;
												{'CT2_FILIAL'     ,CT2->CT2_FILIAL	, NIL},;
												{'CT2_MOEDLC'     ,CT2->CT2_MOEDLC  , NIL},;
												{'CT2_DC'         ,CT2->CT2_DC      , NIL},;
												{'CT2_DEBITO'     ,CT2->CT2_DEBITO  , NIL},;
												{'CT2_CREDIT'     ,CT2->CT2_CREDIT  , NIL},;
												{'CT2_VALOR'      ,CT2->CT2_VALOR   , NIL},;
												{'CT2_ORIGEM'     ,CT2->CT2_ORIGEM  , NIL},;
												{'CT2_HP'         ,CT2->CT2_HP      , NIL},;
												{'CT2_EMPORI'     ,CT2->CT2_EMPORI  , NIL},;
												{'CT2_FILORI'     ,CT2->CT2_FILORI  , NIL},;
												{'CT2_HIST'       ,CT2->CT2_HIST    , NIL},;
												{'CT2_TPSALD'     ,"1"    			, NIL}}) 
								CT2->(DbSkip()) 
							EndDo
							Begin Transaction
								cBKPUserId 	:= __CUSERID
								__CUSERID 	:= SCR->CR_USER
								MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 4)
								__CUSERID 	:= cBKPUserId
								If lMsErroAuto
									DisarmTransaction()
									cTitle  := "ERROR-1"
									cReturn := MostraErro("/dirdoc", "error.log")
									If At("Inconsistencia nos Itens",cReturn) > 0
										cReturn := "Debit and credit amounts do not match, accounting entries cannot be effectived!"
									EndIf
									lReturn := .F.															
								Else	
									cTitle  := "MESSAGE"
									cReturn := "Successfully approved."
									U_TCCTW001(2,aCab,aItens,nRecnoCT2,cEmailAlt)
								Endif
							End Transaction
						Else
							cTitle  := "WARNING"
							cReturn := "It was not possible to approve the pre-accounting entries. Check."
							lReturn := .F.
						Endif
					Else
						cTitle  := "MESSAGE"
						cReturn := "Successfully approved, sent to the next approval level."
					EndIf
				//Rejeitar
				ElseIf ( nOpc == 7 )
					cReturn := geraHtmlWF(cFil,cCodigo)
					lReturn := .T.
					lRejeita:= .T.
				//Grava Rejeição
				ElseIf ( nOpc == 6 )
					cUserBkp    := cUserName
					cUserName   := UsrRetName(SCR->CR_USER)

					A094SetOp('005')

					oModel094 := FWLoadModel('MATA094')
					oModel094:SetOperation( MODEL_OPERATION_UPDATE )

					If oModel094:Activate()
						
						oModel094:GetModel("FieldSCR"):SetValue( 'CR_OBS' , "Rejeitado" )

						lOk := oModel094:VldData()

						If lOk
						
							For nX := 1 To Len(aPostParams)
								If aPostParams[nX][1] == "IT.CT2RECNO"
									AADD( aRecnosCT2, VAL(aPostParams[nX][2]) )   				
								EndIf
							Next nX

							If CT2->(MsSeek(cFil+cCodigo))
								nRecnoCT2 := CT2->(Recno())
								cEmailAlt := UsrRetMail(SubStr(Embaralha(CT2->CT2_USERGA,1),3,6))
								aCab    	:= {}
								aItens  	:= {}
								aItensRej 	:= {}

								aAdd(aCab,  {'DDATALANC'    ,CT2->CT2_DATA	,NIL} )
								aAdd(aCab,  {'CLOTE'        ,CT2->CT2_LOTE  ,NIL} )
								aAdd(aCab,  {'CSUBLOTE'		,CT2->CT2_SBLOTE,NIL} )
								aAdd(aCab,  {'CDOC'         ,CT2->CT2_DOC   ,NIL} )

								While CT2->(!EOF()) .AND. CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)==cFil+cCodigo
									If !(aScan(aRecnosCT2,CT2->(Recno())))
										aAdd(aItens,{   {'LINPOS'         ,'CT2_LINHA'		,CT2->CT2_LINHA},;
														{'CT2_FILIAL'     ,CT2->CT2_FILIAL	, NIL},;
														{'CT2_MOEDLC'     ,CT2->CT2_MOEDLC  , NIL},;
														{'CT2_DC'         ,CT2->CT2_DC      , NIL},;
														{'CT2_DEBITO'     ,CT2->CT2_DEBITO  , NIL},;
														{'CT2_CREDIT'     ,CT2->CT2_CREDIT  , NIL},;
														{'CT2_VALOR'      ,CT2->CT2_VALOR   , NIL},;
														{'CT2_ORIGEM'     ,CT2->CT2_ORIGEM  , NIL},;
														{'CT2_HP'         ,CT2->CT2_HP      , NIL},;
														{'CT2_EMPORI'     ,CT2->CT2_EMPORI  , NIL},;
														{'CT2_FILORI'     ,CT2->CT2_FILORI  , NIL},;
														{'CT2_HIST'       ,CT2->CT2_HIST    , NIL},;
														{'CT2_TPSALD'     ,"1"    			, NIL}})
									Else
										aAdd(aItensRej,{   {'LINPOS'         ,'CT2_LINHA'		,CT2->CT2_LINHA},;
														{'CT2_FILIAL'     ,CT2->CT2_FILIAL	, NIL},;
														{'CT2_MOEDLC'     ,CT2->CT2_MOEDLC  , NIL},;
														{'CT2_DC'         ,CT2->CT2_DC      , NIL},;
														{'CT2_DEBITO'     ,CT2->CT2_DEBITO  , NIL},;
														{'CT2_CREDIT'     ,CT2->CT2_CREDIT  , NIL},;
														{'CT2_VALOR'      ,CT2->CT2_VALOR   , NIL},;
														{'CT2_ORIGEM'     ,CT2->CT2_ORIGEM  , NIL},;
														{'CT2_HP'         ,CT2->CT2_HP      , NIL},;
														{'CT2_EMPORI'     ,CT2->CT2_EMPORI  , NIL},;
														{'CT2_FILORI'     ,CT2->CT2_FILORI  , NIL},;
														{'CT2_HIST'       ,CT2->CT2_HIST    , NIL},;
														{'CT2_TPSALD'     ,"1"    			, NIL}})
									EndIf
									CT2->(DbSkip())
								EndDo
								If Len(aCab ) > 0 .AND. Len(aItens) > 0
									Begin Transaction
										cBKPUserId 	:= __CUSERID
										__CUSERID 	:= SCR->CR_USER
										MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 4)
										__CUSERID	:= cBKPUserId
										If lMsErroAuto
											DisarmTransaction()
											cTitle  := "ERROR-1"
											cReturn := MostraErro("/dirdoc", "error.log")
											If At("Inconsistencia nos Itens",cReturn) > 0
												cReturn := "Debit and credit amounts do not match, accounting entries cannot be effectived!"
											EndIf
											lReturn := .F.
											lOk := .F.
										Else	
											lOk := .T.
										Endif
									End Transaction	
								EndIf				
							EndIf

							If lOk
								oModel094:CommitData()											
								cTitle  := "WARNING"
								cReturn := "Rejected successfully."

								//Caso houver envia os pré lançamentos aprovados
								If Len(aCab) != 0 .AND. Len(aItens) != 0 
									U_TCCTW001(2,aCab,aItens,nRecnoCT2,cEmailAlt)
								EndIf
								//Envia os pré lançamentos rejeitados
								If Len(aCab) != 0 .AND. Len(aItensRej) != 0 
									U_TCCTW001(3,aCab,aItensRej,nRecnoCT2,cEmailAlt)
								EndIf
							ElseIf !lMsErroAuto
								cTitle  := "ERROR-4"
								cReturn := "An error occurred when approving the request. Contact your system administrator."
								lReturn := .F.
							EndIf                    
						Else
							aErro := oModel094:GetErrorMessage()

							AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
							AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
							AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
							AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
							AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
							AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
							AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
							AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
							AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')

							cTitle  := "ERROR"
							cReturn := "An error occurred when you failed the request. Contact your system administrator."
							lReturn := .F.
						EndIf

						oModel094:DeActivate()

					EndIf

					cUserName   := cUserBkp
					
				EndIf
			EndIf
			SCR->(DbSkip())
		EndDo

		If !lJAprov
			cTitle  := "ERROR"
			cReturn := "Request already answered before."
			lReturn := .F.
		EndIf
	Else
		cTitle  := "ERROR-3"
		cReturn := "Record not found in the Approval Levels (SCR) table, check if it has been deleted."
		lReturn := .F.
	EndIf
Return ( {cReturn,cTitle,lReturn,lRejeita} )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraHTMLWF
//Monta o HTML p/ rejeição lançamentos
@author Kaique Mathias
@since 01/04/2020
@version undefined
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function GeraHTMLWF(cFil,cCodigo)
	Local cPictVlr  := PesqPict("CT2","CT2_VALOR")
    Local cHTML 	:= ""
	Local cUsrAltLc := ""

	DbSelectArea("CT2")
	CT2->(DbSetOrder(1))
	//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
	If CT2->(MsSeek(cFil+cCodigo))
		cAction := Encode64("funcName=u_TCCT01RET"			+;
										"&empresa=" + cEmpAnt 			+;
										"&filial=" 	+ CT2->CT2_FILIAL	+;
										"&opc=6" 						+;
										"&aprv="	+ SCR->CR_APROV		+;
										"&cod="	 	+ cCodigo)

		cHTML += '<html>'
		cHTML += '<head>'
		cHTML += '	<meta charset="iso-8859-1">'
		cHTML += '	<title>Accounting Entries Manual WorkFlow</title>'
		cHTML += '	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">'
		cHTML += '	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>'
		cHTML += '	<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>'
		cHTML += '	<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>'
		cHTML += '	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>'
		cHTML += '	<script>'
		cHTML += '		$(document).ready(function() {'
		cHTML += '			var _   = this;'
		cHTML += '			$(document).on("change", "#table-title input.input-rows", function(e){'
		cHTML += '				e.preventDefault();'
		cHTML += '				'
		cHTML += '				if(!$(this).is('+"'"+":checked"+"'"+')) {'
		cHTML += '					$("input[name='+"'"+"checkall"+"'"+']").prop("checked", false);'
		cHTML += '				}'
		cHTML += '			});'
		cHTML += '			'
		cHTML += '			$(document).on('+"'"+"change"+"'"+', "input[name='+"'"+"checkall"+"'"+']", function(e){'
		cHTML += '				e.preventDefault();'
		cHTML += '				'
		cHTML += '				if($(this).val() == 1){'
		cHTML += '					$(document).find("#table-title input.input-rows").each(function( index, value ) {'
		cHTML += '					$(this).prop("checked", true);'
		cHTML += '				});			'
		cHTML += '				}else {'
		cHTML += '					$(document).find("#table-title input.input-rows").each(function( index, value ) {'
		cHTML += '					$(this).prop("checked", false);'
		cHTML += '				});'
		cHTML += '				}'
		cHTML += '			});	'
		cHTML += '		});'
		cHTML += '	</script>'
		cHTML += '</head>	'
		cHTML += '<center class="m_2530761332301381468wrapper"'
		cHTML += '<div>'
		cHTML += '<form id="form1" name="form1" method="post" action="u_tcwfctret.apl?' + cAction + ' "> '
		cHTML += '	<table cellpadding="0" cellspacing="0" border="0" width="100%" class="m_2530761332301381468wrapper"'
		cHTML += '	bgcolor="#ffffff">'
		cHTML += '	<tbody>'
		cHTML += '		<tr>'
		cHTML += '		<td valign="top" bgcolor="#ffffff" width="100%">'
		cHTML += '			<table width="100%" role="content-container" align="center" cellpadding="0" cellspacing="0" border="0">'
		cHTML += '			<tbody>'
		cHTML += '				<tr>'
		cHTML += '				<td width="100%">'
		cHTML += '					<table width="100%" cellpadding="0" cellspacing="0" border="0">'
		cHTML += '					<tbody>'
		cHTML += '						<tr>'
		cHTML += '						<td>'
		cHTML += '							<table width="100%" cellpadding="0" cellspacing="0" border="0"'
		cHTML += '							style="width:100%" align="center">'
		cHTML += '							<tbody>'
		cHTML += '								<tr>'
		cHTML += '								<td role="modules-container"'
		cHTML += '									style="padding:0px 0px 0px 0px;color:#000000;text-align:left" bgcolor="#f8f8f8"'
		cHTML += '									width="100%" align="left">'
		cHTML += '									<table class="m_2530761332301381468wrapper" role="module" border="0" cellpadding="0"'
		cHTML += '									cellspacing="0" width="100%" style="table-layout:fixed">'
		cHTML += '									<tbody>'
		cHTML += '										<tr>'
		cHTML += '										<td style="font-size:6px;line-height:10px;padding:20px 0px 0px 0px"'
		cHTML += '											valign="top" align="center">'
		cHTML += '											<a href="https://www.tcp.com.br/" target="_blank">'
		cHTML += '											<img border="0"'
		cHTML += '												src="https://www.tcp.com.br/wp-content/uploads/2019/12/tcp-cmport-color.png"'
		cHTML += '												alt="" width="200">'
		cHTML += '											</a>'
		cHTML += '										</td>'
		cHTML += '										</tr>'
		cHTML += '									</tbody>'
		cHTML += '									</table>'
		cHTML += '									<table border="0" cellpadding="2" width="100%" style="table-layout:fixed">'
		cHTML += '									<tbody>'
		cHTML += '										<tr>'
		cHTML += '										<td'
		cHTML += '											style="margin:0 0 5px 16px;">'
		cHTML += '											&nbsp;</td>'
		cHTML += '										</tr>'
		cHTML += '										<tr height=30>'
		cHTML += '										<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff">'
		cHTML += '											<div style="margin:0px 0px 0px 10px"><strong>MANUAL ACCOUNTING ENTRIES APPROVAL WORKFLOW</strong></div>'
		cHTML += '										</td>'
		cHTML += '										</tr>'
		cHTML += '                                      <tr>'
		cHTML += '											<td>'
		cHTML += '												<span style="color:#0d3178"><strong>Select the Accounting pre entry you want to reject:</strong></span>'
		cHTML += '											</td>'
		cHTML += '										</tr>'
		cHTML += '										<tr>'
		cHTML += '										<td'
		cHTML += '											style="margin:0 0 5px 16px;">'
		cHTML += '											&nbsp;</td>'
		cHTML += '										</tr>'
		cHTML += '										<table cellpadding="2" border="0" width="100%" id="table-title">'
		cHTML += '										<thead>'
		cHTML += '											<tr height=25>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Select</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Line</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Branch</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Lot Number</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Doc Number</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Include Date</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Debit Account</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Credit Account</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>Value</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>History</b></td>'
		cHTML += '											<td style="text-align:left;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff"><b>User</b></td>'
		cHTML += '											</tr>'
		cHTML += '										</thead>'
		cHTML += '										<tbody>'
		While CT2->(!EOF()) .AND. CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)==cFil+cCodigo
			If (CT2->CT2_TPSALD == "9")		
				cUsrAltLc     := FWLeUserlg("CT2_USERGA",1)
				cHTML += '											<tr  height=30>'
				cHTML += '											<td>'
				cHTML += '											<div class="custom-control custom-checkbox mr-sm-2">'
				cHTML += '										        <input type="checkbox" class="custom-control-input input-rows" id="field-'+cValToChar(CT2->(RECNO()))+'" name="IT.CT2RECNO" value="'+cValToChar(CT2->(RECNO()))+'">'
				cHTML += '										        <label class="custom-control-label" for="field-'+cValToChar(CT2->(RECNO()))+'"></label>'
				cHTML += '										    </div>'
				cHTML += '											</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_LINHA            +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_FILIAL           +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_LOTE             +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_DOC              +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+DTOC(CT2->CT2_DATA) 	   +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_DEBITO           +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_CREDIT           +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+AllTrim(Transform(CT2->CT2_VALOR,cPictVlr))+'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+CT2->CT2_HIST             +'</td>'
				cHTML += '											<td style="text-align:left;font-family:Arial,Helvetica,sans-serif;font-size:12px;">'+cUsrAltLc                 +'</td>                                              '
				cHTML += '											</tr>'
			EndIf
			CT2->(DbSkip())
		EndDo
		cHTML += '										</tbody>'
		cHTML += '										</table>'
		cHTML += '										<table border="0" cellpadding="2" width="100%" style="table-layout:fixed">'
		cHTML += '											<tbody>'
		cHTML += '										 		<thead>'
		cHTML += '													<tr height=25 width="100%">'
		cHTML += '											        	<td style="text-align:center;background-color:#0d3178;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff;width:100%"><b>Mark all?</b></td>'
		cHTML += '											       	</tr>'
		cHTML += '												</thead>'
		cHTML += '											</tbody>'
		cHTML += '											<tbody>'
		cHTML += '												<tr style="text-align:center">'
		cHTML += '													<th class="text-center" style="border:0;">'
		cHTML += '														<input type="radio" name="checkall" value="1"  id="checkall-1">'
		cHTML += '														<label for="checkall-1">YES</label>'
		cHTML += '														<input type="radio" name="checkall" value="2"  id="checkall-2"> '
		cHTML += '														<label for="checkall-2">NO</label>'
		cHTML += '													</th>'
		cHTML += '												</tr>'
		cHTML += '											</tbody>'
		cHTML += '										</table>'
		cHTML += '										<table class="mb-1" style="width: 100%;">	'
		cHTML += '										    <tr>                                                      '
		cHTML += '                                          	<div align="center" style="margin: 0px 0px;padding: 0px;"> '
		cHTML += '                                          		<input type="submit" name="B1" value="Send"> '
		cHTML += '                                          		<input type="reset" name="B2" value="Clear"> '
		cHTML += '                                          	</div> '
		cHTML += '										    </tr>'
		cHTML += '										</table>'	
		cHTML += '									</tbody>'
		cHTML += '									</table>'
		cHTML += '									<div role="module"'
		cHTML += '									style="background-color:#ffffff;color:#444444;font-size:12px;line-height:20px;padding:40px 16px 16px 16px;text-align:center">'
		cHTML += '									<div class="fm_copy">Copyright © Terminal de Contêineres de Paranaguá<br>'
		cHTML += '										All rights reserved</div>'
		cHTML += '									</div>'
		cHTML += '								</td>'
		cHTML += '								</tr>'
		cHTML += '							</tbody>'
		cHTML += '							</table>'
		cHTML += '						</td>'
		cHTML += '						</tr>'
		cHTML += '					</tbody>'
		cHTML += '					</table>'
		cHTML += '				</td>'
		cHTML += '				</tr>'
		cHTML += '			</tbody>'
		cHTML += '			</table>'
		cHTML += '		</td>'
		cHTML += '		</tr>'
		cHTML += '	</tbody>'
		cHTML += '	</table>'	
		cHTML += '</form> '
		cHTML += '</div>'
		cHTML += '</center>'
		cHTML += '</html>	'
	EndIf

Return( cHtml )

/*/{Protheus.doc} RETEMAILS
	Retorna email para envio da notificação do lançamento Aprovado/ Rejeitado
	@type  Static Function
	@author Willian Kaneta
	@since 25/06/2020
	@version 1.0
	@return cMail
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RETEMAILS(nOpc,cEmailUserAlt)
	Local cMail		:= ""
	Local cCCMail 	:= GetMv("TCP_MAILLC")
	Local cMailAlt	:= ""
	
	If nOpc == 2 .OR. nOpc == 3 
		cMailAlt := cEmailUserAlt
	Else
		cMailAlt := UsrRetMail(SubStr(Embaralha(CT2->CT2_USERGA,1),3,6))
	EndIf

	If nOpc == 5
		cMail := cMailAlt
	Else
		If !Empty(cCCMail) .AND. nOpc == 2
			cMail := cMailAlt + ";" + cCCMail
		Else
			cMail := cMailAlt
		EndIf
	EndIf
Return cMail

/*/{Protheus.doc} fGetUsrName
	Retorna Nome Usuário
/*/
Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))
