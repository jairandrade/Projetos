#Include 'Protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} TCP_MFIN001
Workflow para enviar o Status dos títulos em aberto para integracao.
Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
@type function
@author luizf
@since 24/05/2016/*/
User Function MFIN001()

LOCAL cQuery  :=""
LOCAL cStatus :=""
OpenSM0()
RPCSETENV('02', '01',)

//+---------------------------------------------------------------------+
//| Localiza os dados de titulos em aberto integrados...                |
//+---------------------------------------------------------------------+
cQuery := "SELECT E1_XNUMOS, E1_NUM, E1_SITUACA, E1_VALOR, E1_SALDO FROM "+RetSQLName("SE1")
cQuery += " WHERE "
cQuery += " E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND E1_XNUMOS != '' "
cQuery += " AND E1_SALDO > 0 "
cQuery += " AND E1_TIPO != 'RA' "
cQuery += " AND D_E_L_E_T_ != '*' "
If Select("TRBSE1") <> 0
	DBSelectArea("TRBSE1")
	DBCloseArea()
EndIf
TCQuery cQuery New Alias "TRBSE1"

Do While !TRBSE1->(Eof())
	cStatus:= ""
/*
Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0'													, aLegenda[3][1]				} ) //"Titulo Baixado" 
Aadd(uRetorno, { '!Empty(E1_NUMBOR) .and.(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))'			, aLegenda[6][1]				} ) //"Titulo baixado parcialmente e em bordero"
Aadd(uRetorno, { 'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0 .And. !FXAtuTitCo()'	, aLegenda[5][1]				} ) //"Adiantamento com saldo"
Aadd(uRetorno, { '!Empty(E1_NUMBOR)'														, aLegenda[4][1]				} ) //"Titulo em Bordero"
Aadd(uRetorno, { 'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2) .And. !FXAtuTitCo()'				, aLegenda[2][1]				} ) //"Baixado parcialmente"
Aadd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. E1_SITUACA == "F"'			, aLegenda[Len(aLegenda)][1]	} ) //"Titulo Protestado"
*/
//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4

	cStatus	:= 	"1"//TRBSE1->(E1_SALDO==E1_VALOR)//Aberto
	If TRBSE1->E1_SALDO >0 .And. (ROUND(TRBSE1->E1_SALDO,2) # ROUND(TRBSE1->E1_VALOR,2)) //Baixa Parcial
		cStatus	:= 	"3"
	EndIf
	If ROUND(TRBSE1->E1_SALDO,2) = 0//Baixado
		cStatus	:= 	"2"
	EndIf
	If ROUND(TRBSE1->E1_SALDO,2) == ROUND(TRBSE1->E1_VALOR,2) .and. TRBSE1->E1_SITUACA == "F"//Protestdo
		cStatus	:= 	"4"	
	EndIf

	U_WGENFIN1(TRBSE1->E1_NUM,cStatus,TRBSE1->E1_SALDO,"MFIN001-JOB")//cNumTit,cStatus,nSaldo,cRotina

	TRBSE1->(DBSkip())
EndDo
If Select("TRBSE1") <> 0
	DBSelectArea("TRBSE1")
	DBCloseArea()
EndIf

Return

