#include "totvs.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} TCFIA005
Rotina responsavel por realizar a inclusao na solicitacao de pagamentos
@type user function
@version 1.0
@author Kaique Mathias
@since 7/29/2020
@return return_type, return_description
/*/

User Function TCFIA005()

	Local aArea      := SE2->(GetArea())
	Local oMdlZA0    := FWLoadModel('TCFIA002')
	Local aErro      := {}
	Local lError     := .F.
	Local aRegsImpAux:= {}
	Local aTitsImpAux:= {}
	Local cNaturez   := SE2->E2_NATUREZ
	Local cHist      := ""

	oMdlZA0:SetOperation( 3 )

	If( oMdlZA0:Activate() )

		If( Alltrim(FunName()) == "FINA378" .Or. Alltrim(FunName()) == "FINA376" )

			If( Alltrim(FunName()) == "FINA376" )
				If( Type("__nRecSE2_") # "U" )
					If( __nRecSE2_ > 0 )
						dbSelectArea("SE2")
						SE2->( dbgoto( __nRecSE2_ ) )
					EndIf
				EndIf
			EndIf

			If( Select("TMPSE2") > 0 )
				TMPSE2->( dbCloseArea() )
			EndIf
			BeginSql Alias "TMPSE2"
                SELECT SE2.R_E_C_N_O_ RECNO
                FROM %Table:SE2% SE2
                WHERE SE2.E2_AGLIMP = %exp:SE2->E2_NUM% AND
                      SE2.%NotDel%
			EndSql

			While !TMPSE2->(Eof())

				SE2->(dbgoto(TMPSE2->RECNO))

				If( Alltrim(FunName()) == "FINA378" )

					BeginSql Alias "TMP"
                        SELECT SE2.R_E_C_N_O_ RECSE2
                        FROM %Table:SE2% SE2
                        WHERE SE2.E2_NUM = %exp:SE2->E2_NUM% AND
                            SE2.E2_TIPO = 'TX ' AND
                            SE2.E2_FORNECE = %exp:SE2->E2_FORNECE% AND
                            SE2.E2_LOJA = %exp:SE2->E2_LOJA% AND
                            SE2.E2_EMISSAO >= %exp:DTOS(MV_PAR01)% AND
                            SE2.E2_EMISSAO <= %exp:DTOS(MV_PAR02)% AND
                            SE2.E2_NATUREZ = %exp:cNaturez% AND
                            SE2.%NotDel%
					EndSql

					While !TMP->( Eof() )
						SE2->(dbgoto(TMP->RECSE2))
						aAdd(aRegsImpAux,{TMP->RECSE2,SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA)})
						TMP->( dbSkip() )
					EndDo

					TMP->( dbCloseArea() )

				ElseIf( Alltrim(FunName()) == "FINA376" )
					aAdd(aRegsImpAux,{TMPSE2->RECNO,SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA)})
				EndIf

				TMPSE2->(dbSkip())

			EndDo

			TMPSE2->(dbCloseArea())

			RestArea(aArea)

			If( Alltrim(FunName()) == "FINA376" )
				If( Type("__nRecSE2_") # "U" )
					If( __nRecSE2_ > 0 )
						dbSelectArea("SE2")
						SE2->( dbgoto( __nRecSE2_ ) )
					EndIf
				EndIf
			EndIf

			aAdd(aTitsImpAux,SE2->(Recno()))

			If( Len(aRegsImpAux)Fr376Rel>(GetArea())

				If( Alltrim(FunName()) == "FINA378" )
					If !Empty("mv_par05")
						dbSelectArea("SM0")
						dbSeek(cEmpAnt+mv_par05,.T.)
					Endif
				ElseIf ( Alltrim(FunName()) == "FINA376" )
					If !Empty("mv_par10")
						dbSelectArea("SM0")
						dbSeek(cEmpAnt+mv_par10,.T.)
					Endif
				EndIf
				Fr376Rel(aRegsImpAux,aTitsImpAux,SE2->E2_NUM,.F.)
				SM0->(RestArea(aAreaSM0))
			EndIf
		EndIf

		cHist := RetHistorico()

		oMdlZA0:SetValue("ZA0MASTER","ZA0_PREFIX",SE2->E2_PREFIXO)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_NUM",SE2->E2_NUM)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_PARCEL",SE2->E2_PARCELA)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_TIPO",SE2->E2_TIPO)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_CLIFOR",SE2->E2_FORNECE)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_LOJA",SE2->E2_LOJA)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_EMISSA",SE2->E2_EMISSAO)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_VENCTO",SE2->E2_VENCTO)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_VENCRE",SE2->E2_VENCREA)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_NATURE",SE2->E2_NATUREZ)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_TPORC","C")
		oMdlZA0:SetValue("ZA0MASTER","ZA0_VALOR",SE2->E2_VALOR)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_OBS",cHist)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_HIST",cHist)
		oMdlZA0:SetValue("ZA0MASTER","ZA0_ORIGEM",Alltrim(FunName()))
		oMdlZA0:SetValue("ZA0MASTER","ZA0_CODREC",If(Empty( SE2->E2_CODRET) , "", SE2->E2_CODRET  ))

		Begin Transaction

			If( oMdlZA0:VldData() )
				oMdlZA0:CommitData()
				RecLock("SE2",.F.)
				SE2->E2_STATLIB := "01"
				SE2->E2_USUALIB := ""
				SE2->E2_DATALIB := CTOD("//")
				SE2->E2_XCODPGM := ZA0->ZA0_CODIGO
				SE2->E2_XORIGEM := "SP"
				SE2->E2_HIST    := cHist
				MSUnlock()
			Else
				DisarmTransaction()
				lError := .T.
				aErro := oMdlZA0:GetErrorMessage()
				AutoGrLog( "Erro"	+ ' [' + AllToChar( aErro[6] )	+ ']' )
				AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
				AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
				MostraErro()
			EndIf

			If( Type("__nRecSE2_") # "U" )
				If( __nRecSE2_ > 0 )
					__nRecSE2_ := Nil
				EndIf
			EndIf

		End Transaction
	Else
		aErro := oMdlZA0:GetErrorMessage()
		lError := .T.
		AutoGrLog( "Erro"	+ ' [' + AllToChar( aErro[6] )	+ ']' )
		AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
		AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
		MostraErro()
	EndIf

	RestArea(aArea)

Return( !lError )

/*/{Protheus.doc} RetHistorico
Função responsavel por retornar o historico
@type function
@version 1.0
@author Kaique Mathias
@since 8/11/2020
@return character, cHist
/*/

Static Function RetHistorico()

	Local cHist := ""

	If( Alltrim(FunName() ) == "FINA378" )
		cHist := "PIS/COFINS/CSLL - 3RD PARTY RENDERED SERVICES - TCP TERMINAL " + SUBSTR(DTOS(MV_PAR02),5,2) + '/' + SUBSTR(DTOS(MV_PAR02),1,4)
	ElseIf ( Alltrim(FunName() ) == "FINA870" )
		cHist := "INSS " + SE2->E2_RETINS + " - 3RD PARTY RENDERED SERVICES TCP TERMINAL " + SUBSTR(DTOS(SE2->E2_EMISSAO),5,2) + '/' + SUBSTR(DTOS(SE2->E2_EMISSAO),1,4)
	ElseIf ( Alltrim(FunName() ) == "FINA376" )
		cHist := "IRF- 3RD PARTY RENDERED SERVICES " + SE2->E2_CODRET
	ElseIf ( Alltrim(FunName() ) == "FINA290" )
		cHist := "ISS- 3RD PARTY RENDERED SERVICES - TCP TERMINAL " + SUBSTR(DTOS(dDataAte),5,2) + '/' + SUBSTR(DTOS(dDataAte),1,4)
	EndIf

Return( cHist )
