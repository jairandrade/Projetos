#include "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} MDTA6954
Ponto de entrada chamado na validação da tela de Funcionário x EPI, 
após validar as linhas de EPI’s, como última validação a ser realizada. 
Através desse ponto de entrada é possível realizar validações e gravações específicas.
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/7/2020
@return logical, lret
/*/

User Function MDTA6954()

	Local aArea 			:= GetArea()
	Local i,_nX,_nInd,_nY,nY:= 0
	Local nPOSEpi
	Local nPosDtEn
	Local nPosQtdEnt
	Local ncTNF_QTDEVO
	Local nPosNumSA
	Local nPosLocal
	Local nPosQtdEnt
	Local nPosDesc
	Local lRet 			:= .T.
	Local aReqExc		:= {}
	Local cRespMDT      := GetMV('TCP_RESMDT')
	Local cNumReq		:= ""
	Local aItensLib		:= {}
	Local cFunc			:= ""

	//Valido preenchimento do parâmetro
	If Empty(cRespMDT)
		Alert("Favor informar o(s) e-mail(s) de aprovação no parâmetro TCP_RESMDT.")
		Return( .f. )
	EndIf

	nPOSEpi		:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_CODEPI" })
	nPosInDe   	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_INDDEV" })
	nPosDtEn   	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_DTENTR" })
	nPosNumSeq	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_NUMSEQ" })
	nPosNumSA	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_NUMSA"  })
	nPosForn	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_FORNEC" })
	nPosLoja	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_LOJA" 	 })
	nPosNumCap	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_NUMCAP" })
	nPosHrEntr	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_HRENTR" })
	nPosNumReq	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_YNUMRE" })
	nPosDesc	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_DESC" 	 })
	nPosQtdEnt	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_QTDENT" })
	nPosLocal	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_LOCAL"  })
	nPosStatus	:= aScan(aHeader,{ |x| Alltrim(x[2]) == "TNF_XSTATU" })

	//Trecho p/ validações
	for _nInd := 1 to len(oGetTNF695:aCols)
		cCodEPI 	:= oGetTNF695:aCols[ _nInd , nPOSEpi ]
		cItem		:= StrZero(_nInd,2)
		If( Empty( cCodEPI ))
			lRet := .F.
			Help("",1,"EPIOBRIGAT",,'Existem campos obrigatorios que não foram preenchidos. Campo: Cod.EPI. Linha: ' + Alltrim(Str(_nInd)),4,1,NIL, NIL, NIL, NIL, NIL, {"Preencha o campo Cod.EPI."})
			Exit
		EndIf
		If( ;
				!oGetTNF695:aCols[_nInd][len(aHeader)+1]  .And.;
				oGetTNF695:aCols[_nInd][nPosInDe] <> "2"  .And.;
				Empty(oGetTNF695:aCols[_nInd][nPosNumReq]) .And.; 
				Empty(oGetTNF695:aCols[_nInd][nPosStatus]);
				)
			
			cCodEPI 	:= oGetTNF695:aCols[ _nInd , nPOSEpi ]
			//Se EPI ja foi entregue chamo a tela de justificativa
			If fValidEPI(M->RA_MAT,cCodEPI,M->RA_CODFUNC)
				Aviso('Aviso',"Atenção, o Item/Produto " + cItem + '/' + Alltrim(cCodEPI) + " será enviada para a liberação.",{'OK'})
				cJustific := fInfMotivo(cItem,cCodEPI)
				If !Empty(cJustific)
					aAdd(aItensLib,{ oGetTNF695:aCols[_nInd][nPosForn],;
						oGetTNF695:aCols[_nInd][nPosLoja],;
						oGetTNF695:aCols[_nInd][nPOSEpi],;
						oGetTNF695:aCols[_nInd][nPosNumCap],;
						oGetTNF695:aCols[_nInd][nPosDtEn],;
						oGetTNF695:aCols[_nInd][nPosHrEntr],;
						oGetTNF695:aCols[_nInd][nPosQtdEnt],;
						Alltrim(cJustific),;
						_nInd})
				Else
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	next _nInd

	If( lRet )

		//Persistencia dos dados
		Begin Transaction

			for _nInd := 1 to len(oGetTNF695:aCols)

				cItem		:= StrZero(_nInd,2)
				cCodEPI 	:= oGetTNF695:aCols[ _nInd , nPOSEpi ]

				If( !oGetTNF695:aCols[_nInd][len(aHeader)+1] )

					If (;
							oGetTNF695:aCols[_nInd][nPosInDe] <> "2" .And.;
							Empty(oGetTNF695:aCols[_nInd][nPosNumReq]);
							)
						_lIncReceb := .T.

						//Valido se EPI ja foi entregue ou nao esta relacionado com a funcao
						_lIncReceb := !fValidEPI(M->RA_MAT,cCodEPI,M->RA_CODFUNC)

						// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						// ³ So incluo RM se o EPI nao tiver sido entegue, pois se³
						// ³ tiver sera enviado para a aprovacao	 			  ³
						// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ( _lIncReceb )
							if ( Empty(oGetTNF695:aCols[_nInd][nPosNumReq]) )
								MsgRun( "Criando requisição de material Item/Produto: " + cItem + '/' + cCodEPI, "Aguarde", { || ;
									cNumReq := U_TCMD03KM(	oGetTNF695:aCols[_nInd][nPosDtEn],;
									cCodEPI,;
									oGetTNF695:aCols[_nInd][nPosLocal],;
									,;
									oGetTNF695:aCols[_nInd][nPosQtdEnt],;
									3,;
									M->RA_MAT) })
								If !Empty(cNumReq)
									aCols[_nInd][nPosNumReq] := cNumReq
								Else
									DisarmTransaction()
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				else
					If (;
							oGetTNF695:aCols[_nInd][nPosInDe] <> "2" .And.;
							!Empty(oGetTNF695:aCols[_nInd][nPosNumReq]);
							)
						MsgRun( "Excluindo requisição de material Item/Produto: " + cItem + '/' + cCodEPI, "Aguarde", { || ;
							cNumReq := U_TCMD03KM(	oGetTNF695:aCols[_nInd][nPosDtEn],;
							cCodEPI,;
							oGetTNF695:aCols[_nInd][nPosLocal],;
							oGetTNF695:aCols[_nInd][nPosNumReq],;
							oGetTNF695:aCols[_nInd][nPosQtdEnt],;
							5,;
							M->RA_MAT) })
						If !Empty(cNumReq)
							DisarmTransaction()
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf

			next _nInd

		End Transaction

		If( lret )
			If( Len(aItensLib) > 0 )
				for nY := 1 to len(aItensLib)
					//Disparo o email de aprovação
					cFunc := "U_TCMD02KM("
					aEval(aItensLib[nY],{|x| cFunc += "'" + convertType(x) + "',"}) 
					cFunc := SubString(cFunc,1,len(cFunc)-1) + ")"
					&cFunc
					//Atualizo o status p/ aguardando
					aCols[aItensLib[nY][9]][nPosStatus] := "02"
				next nY
			EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return( lret )

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA6955
O ponto de entrada MDTA6955 pode ser utilizado para execuções especí
ficas após gravação das solicitações de EPI ao armazém.
@author  Kaique Sousa
@since   21/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fValidEPI(cMatricula,cCODEPI,cCodFunc)

	Local aArea         := TNF->(GetArea())
	Local nSavOrd		:= TNF->(IndexOrd())
	Local nSavRec       := TNF->(Recno())
	Local lRet          := .F.
	Local cCliMDTPs     := ""
	Local cJustific     := ""

	//Valida se o EPI ja foi entregue ao funcionario
	dbSelectArea("TNF")
	TNF->(dbSetOrder(3))
	TNF->(Dbgotop())

	If TNF->(dbSeek(xFilial("TNF")+cMatricula+cCodEPI))
		While !TNF->(Eof()) .And. TNF->TNF_FILIAL   == xFilial("TNF") .And.;
				TNF->TNF_MAT      == cMatricula .And.;
				TNF->TNF_CODEPI   == cCodEPI
			If ( TNF->TNF_INDDEV <> "1" ) .And. ( TNF->(Recno()) <>  nSavRec ) //.And. ( Empty(TNF->TNF_NUMSA) )
				lRet := .T.
				Exit
			EndIf
			TNF->(dbSkip())
		EndDo
	EndIf

	If !lRet
		Dbselectarea("TNB")
		TNB->(Dbsetorder(1))
		If !TNB->(Dbseek( xFilial( "TNB" )+ cCodFunc + cCODEPI ))
			_cQryFil := GetNextAlias()
			BeginSQL Alias _cQryFil
                SELECT TL0.TL0_EPIGEN,TL0.TL0_FORNEC,TL0.TL0_LOJA,TL0.TL0_EPIFIL FROM %table:TL0% TL0
                    JOIN %table:TN3% TN3 ON	TN3.TN3_CODEPI	= TL0.TL0_EPIGEN AND
                                            TN3.TN3_FORNEC	= TL0.TL0_FORNEC AND
                                            TN3.TN3_LOJA	= TL0.TL0_LOJA AND
                                            TN3.%notDel%
                    JOIN %table:TNB% TNB ON	TNB.TNB_CODFUN	= %exp:cCodFunc% AND
                                            TNB.TNB_CODEPI	= TL0.TL0_EPIGEN AND
                                            TNB.%notDel%
                    WHERE TL0.TL0_EPIFIL = %exp:cCODEPI% AND TL0.%notDel%
			EndSQL
			If ( _cQryFil )->( EoF() )
				lRet := .T.
			Endif
		EndIf
	Endif

	RestArea(aArea)

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Retorna ao registro e alias original                 ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea( "TNF" )
	TNF->(dbSetOrder( nSavOrd ))
	TNF->(dbGoTo( nSavRec ))

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fInfMotivo
Funcao responsavel por montar a tela de motivo de solicitacao do EPI
@author  Kaique Sousa
@since   21/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fInfMotivo(cItem,cCODEPI)

	Local oButton1
	Local oButton2
	Local oGetJust
	Local oSay1
	Local lRet		:= .F.
	Local nOpcA		:= 0
	Local _oDlg
	Local cGetJust  := Space(200)

	DEFINE MSDIALOG _oDlg TITLE "Informe a Justificativa" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

	@ 006, 006 SAY oSay1 PROMPT "EPI:" + cItem + "/" + Alltrim(cCODEPI) + "-" + Posicione('SB1',1,xFilial('SB1')+cCODEPI,'B1_DESC')  SIZE 200, 007 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 016, 006 MSGET oGetJust VAR cGetJust SIZE 236, 010 OF _oDlg COLORS 0, 16777215 PIXEL
	@ 032, 204 BUTTON oButton1 PROMPT "Confirmar" ACTION ( If(!Empty(cGetJust), (nOpcA := 1,_oDlg:End()),Alert("Favor inserir a justificativa")) )SIZE 037, 012 OF _oDlg PIXEL
	@ 033, 161 BUTTON oButton2 PROMPT "Cancelar" ACTION (nOpcA := 0,_oDlg:End()) SIZE 037, 012 OF _oDlg PIXEL

	ACTIVATE MSDIALOG _oDlg CENTERED

Return( cGetJust )

Static function convertType(xParam)
	If( ValType(xParam) == "N" )	
		xParam := Alltrim(cValToChar(xParam))
	ElseIf( ValType(xParam) == "D" )
		xParam := DTOC(xParam)
	EndIf
Return( xParam )

