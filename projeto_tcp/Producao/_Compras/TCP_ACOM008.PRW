#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM008
Rotina para reenvio de e-mail de pedido aprovado

@return 
@author Felipe Toazza Caldeira
@since 14/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM008()
Private cPerg := "ACOM008"
                                
CriaPerg(cPerg)	

If !Pergunte(cPerg,.t.)
   Return
Endif

DbSelectArea('SC7')
SC7->(DbSetOrder(1))
SC7->(DbGoTop())
If SC7->(DbSeek(xFilial('SC7')+MV_PAR01))
	If SC7->C7_CONAPRO  != 'L'
		Alert('Pedido não liberado!')
		Return
	EndIf
	DbSelectArea('SA2')
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())
	If SA2->(DbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA))	
		if MsgNoYes( "Confirma o reenvio da confirmação do pedido para o Fornecedor?", 'Reenvio de confirmação de pedido.' )
			U_RCOM008(SC7->C7_FILIAL,SC7->C7_NUM)  
			Msginfo('Pedido reenviado!')
		endif
	Else
		Alert('Fornecedor não localizado!')
	EndIf
Else
	Alert('Pedido não localizado!')
EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM008P
Rotina para reenvio de e-mail de pedido aprovado

@return 
@author Felipe Toazza Caldeira
@since 14/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM008P()

	If SC7->C7_CONAPRO  != 'L'
		Alert('Pedido não liberado!')  
		Return
	EndIf

	DbSelectArea('SA2')
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())
	If SA2->(DbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA))
		if MsgNoYes( "Confirma o reenvio da confirmação do pedido para o Fornecedor ?", 'Reenvio de confirmação de pedido.' )
			U_RCOM008(SC7->C7_FILIAL,SC7->C7_NUM)  
			Msginfo('Pedido reenviado!')
		endif
	Else
		Alert('Fornecedor não localizado!')
	EndIf

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Acerto do dicionário de dados

@return 
@author Felipe Toazza Caldeira
@since 14/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function CriaPerg(cPerg)	

//PutSx1(cPerg,"01","Pedido","Pedido","Pedido","mv_ch1","C",6,0,0,"G","","SC7","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o pedido de compras","",""},{"","","",""},{"","",""},"")

Return