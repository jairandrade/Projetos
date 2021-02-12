#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

User Function TITICMST //Alterar o numero do titulo e a data de vencimento no financeiro

Local	cOrigem		:=	PARAMIXB[1]
Local	cTipoImp	:=  PARAMIXB[2] // Ver F6_TIPOIMP
//Local lDifal		:=  PARAMIXB[3] //não está funcionando essa condição - em 16.06.2016
Local dVcrea		:=	DataValida(dDataBase,.T.)
Local nNwNum		:=	StrZero(mv_par01,2) //iniciar com o mes de apuração
Local cNwEst		:=	Space(TamSx3('A2_EST')[1])
Local cNatIcmss :=	Space(TamSx3('E2_NATUREZ')[1])
Local cPrefix		:= "   "
Local lPassou		:= .F.

If Type('cNewNum') == "U"
	Public cNewNum	:= Space(TamSx3("E2_NUM")[1])
Else
	lPassou := .T.
EndIf

If AllTrim(cTipoImp)='3' // Icms ST
	cNatIcmss	:= ALLTRIM(GETMV("MV_NATST"))
	cPrefix := SE2->E2_PREFIXO
ElseIf AllTrim(cTipoImp)='B' //Difal
	cNatIcmss	:= ALLTRIM(GETMV("MV_APICMP"))
	cPrefix := SE2->E2_PREFIXO
ElseIf cOrigem $ "MATA953" .AND. AllTrim(cTipoImp)=='1' // se for via rotina de apuração e o tipo do imposto for ICMS normal
	cNatIcmss	:= ALLTRIM(GETMV("MV_ICMS"))
ElseIf cOrigem $ "MATA953" .AND. AllTrim(cTipoImp)=='3' // se for via rotina de apuração e o tipo do imposto for ICMS ST
	cNatIcmss	:= ALLTRIM(GETMV("MV_NATST"))
ElseIf cOrigem $ "MATA953" .AND. AllTrim(cTipoImp)='B'	// se for via rotina de apuração e o tipo do imposto for DIFAL
	cNatIcmss	:= ALLTRIM(GETMV("MV_APICMP"))
EndIf

If AllTrim(cOrigem)$'MATA952|MATA953|MATA954|MATA996'	//Apuracao de IPI, Apuracao de ICMS, Apuracao de ISS e Apuracao de Pis/Cofins
	
	nNwNum	+= ALLTRIM(STR(MV_PAR02)) //complementa com o ano de apuração
	
	If lPassou
		nNwNum	:= Soma1(cNewNum)
		cNewNum	:= nNwNum //disponibilizar o número para a SF6
	Else
		cSql:=" Select MAX(F6_NUMERO) F6_NUMERO "
		cSql+=" from "+RETSQLNAME('SF6')
		cSql+=" WHERE D_E_L_E_T_<>'*' "
		cSql+=" AND F6_FILIAL ='"+xFilial('SF6')+"'"
		cSql+=" AND F6_NUMERO LIKE '"+nNwNum+"%'"
		IF Select('TRF6')<>0
			TRF6->(dbCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRF6'
		IF !TRF6->(EOF())
			If !EMPTY(TRF6->F6_NUMERO)
				nNwNum	:= SubStr(nNwNum,1,6)+Strzero(Val(Substr(nNwNum,7,TamSx3('E2_NUM')[1]-6))+1,TamSx3('E2_NUM')[1]-6)
			EndIf
		ENDIF
	EndIf
	
	If cOrigem $ "MATA953"
		SE2->E2_NATUREZ := cNatIcmss
		SE2->E2_VENCTO	:= dDataBase
		SE2->E2_VENCREA	:= dVcrea
		SE2->E2_NUM		:= StrZero(val(nNwNum),TamSx3('E2_NUM')[1])
		
		xcParc:=strzero(val('01'),tamsx3('E2_PARCELA')[1])
		
		cSql:=" Select MAX(E2_PARCELA) PARCELA "
		cSql+=" from "+RETSQLNAME('SE2')
		cSql+=" WHERE E2_NUM='"+nNwNum+"'"
		cSql+=" AND E2_FILIAL ='"+xFilial('SE2')+"'"
		cSql+=" AND D_E_L_E_T_<>'*'"
		IF Select('TRE2')<>0
			TRE2->(dbCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRE2'
		IF !TRE2->(EOF())
			xcParc:=strzero(val(SOMA1(TRE2->PARCELA)),tamsx3('E2_PARCELA')[1])
		ENDIF
		
		SE2->E2_PARCELA := xcParc
		
	EndIf
	
	cNewNum	:= nNwNum //disponibilizar o número para a SF6
	
	Return {nNwNum,dVcrea}
Else
	If cOrigem $ "MATA103"
		nNwNum		:=	SF1->F1_DOC
		cNwEst		:=	SF1->F1_EST
	Else
		nNwNum		:=	CNUMERO
		cNwEst		:=	SF2->F2_EST
	EndIf
	
	If AllTrim(cTipoImp)$'3|B'
		xcParc:=strzero(val('01'),tamsx3('E2_PARCELA')[1])
		
		cSql:=" Select MAX(E2_PARCELA) PARCELA "
		cSql+=" from "+RETSQLNAME('SE2')
		cSql+=" WHERE E2_NUM='"+nNwNum+"'"
		cSql+=" AND E2_FILIAL ='"+xFilial('SE2')+"'"
		cSql+=" AND D_E_L_E_T_<>'*'"
		IF Select('TRE2')<>0
			TRE2->(dbCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRE2'
		IF !TRE2->(EOF())
			xcParc:=strzero(val(SOMA1(TRE2->PARCELA)),tamsx3('E2_PARCELA')[1])
		ENDIF
		
		cSql2:=" Select MAX(F6_NUMERO) F6_NUMERO "
		cSql2+=" from "+RETSQLNAME('SF6')
		cSql2+=" WHERE D_E_L_E_T_<>'*' "
		cSql2+=" AND F6_FILIAL ='"+xFilial('SF6')+"'"
		cSql2+=" AND F6_NUMERO LIKE '%"+nNwNum+"'"
		IF Select('TRF6')<>0
			TRF6->(dbCloseArea())
		EndIF
		TcQuery cSql2 New Alias 'TRF6'
		IF !TRF6->(EOF())
			If !EMPTY(TRF6->F6_NUMERO)
				cPrefix	:= IIF(cPrefix=="ICM","IC2",IIF(cPrefix=="IC2","IC3","IC4"))
				SE2->E2_PREFIXO	:= cPrefix
			EndIf
		ENDIF

		SE2->E2_NUM		:= nNwNum
		SE2->E2_PARCELA := xcParc
		SE2->E2_NATUREZ := cNatIcmss
		SE2->E2_VENCTO	:= dDataBase
		SE2->E2_VENCREA	:= dVcrea
		SE2->E2_HIST    := "GNRE SOBRE NF. ESTADO "+cNwEst
	EndIf
Endif

Return {nNwNum,dVcrea}
