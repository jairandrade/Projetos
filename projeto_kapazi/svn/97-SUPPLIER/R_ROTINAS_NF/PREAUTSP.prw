#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: PREAUTSP		|	Autor: Luis Paulo							|	Data: 16/09/2018	//
//==================================================================================================//
//	Descrição: Funcao para digitar o codigo da autorizacao											//
//																									//
//==================================================================================================//
User Function PREAUTSP()
Local nQtd	 		:= 0
Local cCRLF			:= CRLF
Local nBtoOk		:= 0
Local lConti		:= .T.
Private _cPerg1
Private _cPerg2
Private aFiltros 	:= {}

aAdd(aFiltros,SC5->C5_XCODPAU) 			//Estava Val("0.0")
aAdd(aFiltros,SC5->C5_XDTPAUT) 

oFont12 := TFont():New('Arial',,-12,,.F.)

While lConti 

	//DEFINE MSDIALOG oDlg TITLE "[Sincronizacao de pedidos]" From 001,001 to 220,500 Pixel
	Define MsDialog oDlg TITLE "Codigo Pré-Autorização"  From 001,001 to 220,400 Pixel							
	
	oGrpFil := TGroup():New(040,005,100,140,"Supplier",oDlg,CLR_HBLUE,,.T.)
	
	oSayAtr := tSay():New(050,010,{|| "Pré-Autorização"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
	oGetAtr := tGet():New(060,025,{|u| if(PCount()>0,aFiltros[1]:=u,aFiltros[1])}, oGrpFil,060,9,'@!',,,,,,,.T.,,,,,,,.F.,,'','aFiltros[1]')
	
	oSayAtr := tSay():New(075,010,{|| "Data"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
	oGetAtr := tGet():New(082,025,{|u|if(PCount()>0,aFiltros[2]:=u,aFiltros[2])},oDlg,050,009,"@D",,CLR_BLACK,CLR_WHITE,oFont12,,,.T.,,,{||},,,{||},.F.,.F.,,'aFiltros[2]',,,,.T.,,,, 1, oFont12, CLR_BLACK)

	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )
	
	If (Empty(aFiltros[1]) .OR. Empty(aFiltros[2])) .And. nBtoOk == 1
			MsgInfo("Informe todos os campos da pré-autorização","KAPAZICRED")
		
		//ElseIf Len(Alltrim(aFiltros[1])) < 14 .And. nBtoOk == 1
		//	MsgInfo("Pré-Autorização incorreta!!","KAPAZICRED")
			
		//ElseIf (aFiltros[2] - Date()) > 6 .OR.  (Date() - aFiltros[2]) > 6 .And. nBtoOk == 1
		//	MsgInfo("Verifique a data da pré-autorização!!","KAPAZICRED")	
			
		Else
			lConti	:= .F.
	EndIf
	
EndDo

If nBtoOk == 0
		MsgAlert("Cancelado pelo usuário")
		Return .T.
	Else
		If VerPerAu() //Verifica se tem pre-autorizacao
			_cPerg1 := aFiltros[1]
			_cPerg2 := aFiltros[2]
			AtuaPAut() //Atualiza a pré-autorizacao
			If !Empty(_cPerg1)
					AtuaPAut() //Atualiza a pré-autorizacao
				Else
					MsgAlert("Informe o código!","KAPAZICRED")
			EndIf
		EndIf
EndIf	
Return()


Static Function VerPerAu()
Local lRet	:= .T.
Local cQr 	:= ""

cQr := " SELECT *
cQr += " FROM ZS4040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZS4_RECSC5 = " + cValToChar(SC5->(RECNO()))

TcQuery cQr new alias "KAPCREAT"

DbSelectArea("KAPCREAT")
KAPCREAT->(DbGoTop())

If KAPCREAT->(EOF())
	lRet	:= .F.
	MsgAlert("Pré-Autorização não enviada para supplier!!!","KAPAZICRED")
EndIf

KAPCREAT->(DbCloseArea())

Return(lRet)


//Código da pré-autorizacao
Static Function AtuaPAut()

RecLock("SC5",.F.)
SC5->C5_XCODPAU := _cPerg1
SC5->C5_XDTPAUT	:= _cPerg2
MsUnlock()

Return()