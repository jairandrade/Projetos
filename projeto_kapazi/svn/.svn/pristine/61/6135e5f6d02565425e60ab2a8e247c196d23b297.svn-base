#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH" 

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+          
!Descricao         ! Análisa Crédito/Status do Cliente, conforme Valor       !
!                  ! solicitado.                                             !  
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 10/06/2020                                              !
+------------------+--------------------------------------------------------*/
User Function GetCredCli(cCliente, cLoja, nVlrCred)
Local aArea      := GetArea()
Local aAreaSA1   := SA1->(GetArea())
Local aRet       := {"",""} 
Local cBlqCred   := ""
Local nX         := 0
Local aBkpMvPar  := {}
Local aValDet    := {}
Default nVlrCred := 100

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
	If !SA1->A1_MSBLQL == "1"
		//Faz backup das variáveis Private
		For nX := 1 To 60
			Aadd(aBkpMvPar, &("MV_PAR" + StrZero(nX,2,0)))
		Next nX
		
		//Reprocessa arquivos do Cliente antes da análise
		Pergunte("AFI410", .F.)
		MV_PAR01 := 2
		MV_PAR02 := 1
		MV_PAR03 := SA1->A1_COD
		MV_PAR04 := SA1->A1_COD
		MV_PAR05 := ""
		MV_PAR06 := "ZZZZZZ"
		fa410Processa(.T.)
		
		If MaAvalCred(SA1->A1_COD,SA1->A1_LOJA,nVlrCred,SA1->A1_MOEDALC,.T.,@cBlqCred, Nil, Nil, Nil, @aValDet)
			aRet[1] := "OK"
			aRet[2] := "VALOR AUTORIZADO"
		Else
			aRet[1] := "ERRO"
			
			If Len(aValDet) > 0 
				If aValDet[1][1] == "01"
					aRet[2] := "BLOQUEIO DE CRÉDITO "
					
					If aValDet[1][2][1]
						aRet[2] += "POR VALOR/RISCO"
					ElseIf aValDet[1][2][2]
						aRet[2] += "POR INADIMPLÊNCIA"
					Else
						aRet[2] += "MOT.NÃO IDENTIFICADO"
					EndIf
				Else
					aRet[2] := "LIMITE DE CRÉDITO VENCIDO"
				EndIf
			Else  
				aRet[2] := cBlqCred + " - ERRO NÃO IDENTIFICADO"
			Endif
		EndIf
		//Restaura Bkp
		For nX := 1 To Len(aBkpMvPar)
			&("MV_PAR" + StrZero(nX,2,0)) := aBkpMvPar[nX]
		Next nX
	Else
		aRet[1] := "ERRO"
		aRet[2] := "CLIENTE BLOQUEADO"				
	EndIf
Else
	aRet[1] := "ERRO"
	aRet[2] := "CLIENTE NÃO CADASTRADO"
EndIf

RestArea(aAreaSA1)
RestArea(aArea)
Return aRet



//SOMENTE PARA TESTE
User Function MA030ROT
Local aRet := {}

If RetCodUsr() == "000000"
	Aadd(aRotina,{"Análise de Crédito","U_KPCreCli()", 0, 4, 0, NIL})
EndIf
Return aRet
User Function KPCreCli()
Local nVlrCred := Val(FWInputBox("Informe o Valor para Análise de Crédito", ""))
Local aCredito := U_GetCredCli(SA1->A1_COD, SA1->A1_LOJA, nVlrCred)

MsgInfo("<html>Análise Cliente " + SA1->A1_NOME +;
	    "<br>" + aCredito[1] +;
	    "<br>" + aCredito[2] + "</html>")
Return Nil