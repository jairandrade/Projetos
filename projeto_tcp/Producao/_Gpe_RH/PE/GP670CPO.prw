#include "protheus.ch"

User Function GP670CPO()

	Local cHist 	:= ""

	Reclock ("SE2",.F.)
	SE2->E2_PARCELA	:= RC1->RC1_PARC
	
	If !Empty( cHist := getHist() )
		SE2->E2_HIST := cHist
	EndIf

	If RC1->RC1_CODTIT $ "001|002|003"
		SE2->E2_MULTNAT := "1"
	EndIf

	SE2->(MsUnlock())

	If RC1->RC1_CODTIT $ "001|002|003"
		RecLock("SEV",.t.)
		SEV->EV_FILIAL	:= RC1->RC1_FILTIT
		SEV->EV_PREFIXO	:= RC1->RC1_PREFIX
		SEV->EV_NUM		:= RC1->RC1_NUMTIT
		SEV->EV_PARCELA	:= RC1->RC1_PARC
		SEV->EV_CLIFOR	:= RC1->RC1_FORNEC
		SEV->EV_LOJA	:= RC1->RC1_LOJA
		SEV->EV_TIPO	:= RC1->RC1_TIPO
		SEV->EV_VALOR	:= RC1->RC1_VALOR
		SEV->EV_NATUREZ := RC1->RC1_NATURE
		SEV->EV_RECPAG	:= "P"
		SEV->EV_PERC	:= 1
		SEV->EV_RATEICC	:= "1"
		SEV->EV_IDENT	:= "1"
		SEV->(MsUnLock())
		DbSelectArea("ZZG")
		DbSetOrder(1)
		DbGoTop()
		DbSeek(RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC,.f.)
		While !Eof() .and. ZZG->ZZG_FILIAL+ZZG->ZZG_PREFIX+ZZG->ZZG_NUMTIT+ZZG->ZZG_PARC==RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC
			RecLock("SEZ",.t.)
			SEZ->EZ_FILIAL	:= RC1->RC1_FILTIT
			SEZ->EZ_PREFIXO	:= RC1->RC1_PREFIX
			SEZ->EZ_NUM		:= RC1->RC1_NUMTIT
			SEZ->EZ_PARCELA	:= RC1->RC1_PARC
			SEZ->EZ_CLIFOR	:= RC1->RC1_FORNEC
			SEZ->EZ_LOJA	:= RC1->RC1_LOJA
			SEZ->EZ_TIPO	:= RC1->RC1_TIPO
			SEZ->EZ_VALOR	:= ZZG->ZZG_VALOR
			SEZ->EZ_NATUREZ	:= RC1->RC1_NATURE
			SEZ->EZ_CCUSTO	:= ZZG->ZZG_CC
			SEZ->EZ_RECPAG	:= "P"
			SEZ->EZ_PERC	:= (ZZG->ZZG_VALOR / RC1->RC1_VALOR) * 100
			SEZ->EZ_IDENT	:= "1"
			MsUnLock()
			DbSelectArea("ZZG")
			DbSkip()
		End
	EndIf

Return

Static function getHist()
	
	Local cHist		:= Alltrim( RC1->RC1_DESCRI )
	Local cMesAno	:= Substr(RC1->RC1_COMPET,1,2)+"/"+Substr(RC1->RC1_COMPET,3,4)
	
	If RC1->RC1_CODTIT == "001"
		cHist := Alltrim(RC1->RC1_ARELIN)+" FERIAS - HOLIDAY PAY"
	Else
		If RC1->RC1_CODTIT == "002"
			cHist := Alltrim(RC1->RC1_ARELIN)+" RESCISAO -TERMINATION OF EMPLOYMENT CONTRACT"
		Else
			If RC1->RC1_CODTIT == "003"
				cHist := "FGTS S/ '"+Alltrim(RC1->RC1_ARELIN)+"' RESCISAO - FGTS TERMINATION COLLECTION GUIDE"
			Else
				If RC1->RC1_CODTIT == "004"
					cHist := "FOPAG '"+Alltrim(RC1->RC1_ARELIN)+"' COLABORADORES "+cMesAno+" - PAYROLL TCP "
				Else
					If RC1->RC1_CODTIT == "005"
						cHist := "INSS S/ FOPAG "+cMesAno+" - INSS PAYROLL "
					Else
						If RC1->RC1_CODTIT == "006"
							cHist := "FGTS S/ FOPAG "+cMesAno+" - FGTS PAYROLL"
						Else
							If RC1->RC1_CODTIT == "007"
								cHist := "IR FOPAG "+cMesAno+" - IRF TCP PAYROLL "
							Else
								If RC1->RC1_CODTIT == "008"
									cHist := "PENSAO ALIMENTICIA "+cMesAno+" - FOOD PENSION"
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return( cHist )
