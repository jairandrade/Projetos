#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

User Function DADOSTIT()

Local aNewNum	:= {}
Local cNwNum	:= TamSx3('E2_NUM')[1]+TamSx3('E2_PREFIXO')[1]
Local cOrigem	:= FUNNAME()
//Local cOrigem 	:= PARAMIXB[1] //não retorna o FunName correto
Local lAchouKA	:= .F.

If AllTrim(cOrigem) == "MATA952" //Apuração IPI
		cNwNum	:= "IPI"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
		lAchouKA	:= .T.
		
	ElseIf AllTrim(cOrigem) == "MATA953" //Apuração ICMS
		If NSF6(cNewNum)
			cNwNum	:= "IC2"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
		Else
			cNwNum	:= "ICM"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
		EndIf
		lAchouKA	:= .T.
		
	ElseIf AllTrim(cOrigem) == "MATA954" //Apuração ISS
		If FunName() == "MATA103"
				If NSF6(cNewNum)
					cNwNum	:= "IC2"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
				Else
					cNwNum	:= "ICM"+StrZero(val(SF1->F1_DOC),TamSx3('E2_NUM')[1])
				EndIf
				lAchouKA	:= .T.
				
			ElseIf AllTrim(cOrigem) == "MATA953" //Apuração ICMS
				If NSF6(cNewNum)
					cNwNum	:= "IC2"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
				Else
					cNwNum	:= "ICM"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
				EndIf
				lAchouKA	:= .T.
			Else
				cNwNum	:= "ISS"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
				lAchouKA	:= .T.
		EndIf
	
	ElseIf AllTrim(cOrigem) == "MATA996" //Apuração PIS
		cNwNum	:= "PIS"+StrZero(val(cNewNum),TamSx3('E2_NUM')[1])
		lAchouKA	:= .T.
		
	ElseIf AllTrim(cOrigem) == "MATA103" //Inclusao Doc Entrada
		If NSF6(cNewNum)
			cNwNum	:= "IC2"+StrZero(val(SF1->F1_DOC),TamSx3('E2_NUM')[1])
		Else
			cNwNum	:= "ICM"+StrZero(val(SF1->F1_DOC),TamSx3('E2_NUM')[1])
		EndIf
		lAchouKA	:= .T.
	
	ElseIf AllTrim(cOrigem) $ "MATA460|MATA461|MATA460A" //Inclusão Doc Saída
		If NSF6(CNUMERO)
			cNwNum	:= "IC2"+StrZero(val(CNUMERO),TamSx3('E2_NUM')[1])
		Else
			cNwNum	:= "ICM"+CNUMERO
		EndIf
		lAchouKA	:= .T.

EndIf

If lAchouKA
		aNewNum	:=	{cNwNum,DataValida(dDataBase,.T.)}
	Else
		aNewNum	:= Nil
EndIf

Return(aNewNum)



/*
User Function DADOSTIT()  
Local	aTeste		:= {}
Local	cOrigem		:=	PARAMIXB[1]

If AllTrim(cOrigem)=="MATA954"	//Apuracao de ISS			
	aTeste	:=	{"9999999999", DataValida(dDataBase+30,.T.)}
EndIf 

Return (aTeste)
*/

Static Function NSF6(NUMF6)
Local cSql		:= " "
Local lNumF6	:= .F. 

cSql := " Select MAX(F6_NUMERO) F6_NUMERO "
cSql += " from "+RETSQLNAME('SF6')
cSql += " WHERE D_E_L_E_T_<>'*' "
cSql += " AND F6_FILIAL ='" + xFilial('SF6') + "'"
cSql += " AND F6_NUMERO LIKE '%" + NUMF6 +"'"
IF Select('TRF6')<>0
	TRF6->(dbCloseArea())
EndIF
TcQuery cSql New Alias 'TRF6'
If !TRF6->(EOF())
	If !EMPTY(TRF6->F6_NUMERO)
		lNumF6	:= .T.
	EndIf
EndIf

Return( lNumF6 )
