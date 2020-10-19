#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ REFI045J ºAutor  ³ Kaique Sousa      º Data ³  06/24/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ TELA GENERICA PARA MOSTRAR INFORMACOES NUM LISTBOX.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function REFI045J(aDetalhes,cCaption)

Local _nI			:= 0
Local _nJ			:= 0
Local _cBloco1		:= ''

Private _aHList   := {}
Private _aListBox	:= {}
Private _oListBox
Private _oDlgDet

Default aDetalhes = {}

If Empty(aDetalhes)
	MsgInfo('Não há detalhes a serem exibidos...')
	Return( Nil )
EndIf

//Primeira posicao sempre sera o Titulo das Colunas
For _nI := 1 To Len(aDetalhes[1])
	AAdd( _aHList, aDetalhes[1][_nI] )
	_cBloco1 += If(!Empty(_cBloco1),',','') + '_aListBox[_oListBox:nAt,' + cValToChar(_nI) + ']'
Next _nI
_cBloco1 := '{|| {' + _cBloco1 + '}}'

//Adiciona os valores a partir da Segunda Posicao
For _nI := 2 To Len(aDetalhes)
	AADD(_aListBox,aDetalhes[_nI])
Next _nI

If Len(_aListBox) > 0                                  // height - Width
	
	Define MsDialog _oDlgDet Title cCaption From  000,000 TO 350,740 PIXEL OF oMainWnd  
	
	_oListBox := TWBrowse():New(001,002,Int(_oDlgDet:nWidth * 0.49),Int(_oDlgDet:nheight * 0.4),,_aHList,,_oDlgDet,Nil,,,,,,,,,CLR_HBLUE,,,,.T.,,,,.T.,)
	_oListBox:SetArray( _aListBox )
	_oListBox:bLine := MontaBlock(_cBloco1)
	
	_oBut := SButton():New(Int(_oDlgDet:nheight * 0.43),Int(_oDlgDet:nWidth * 0.45),1,{|| _oDlgDet:End()},_oDlgDet,.T.,,{|| .T.})
	
	Activate MsDialog _oDlgDet Center 
	
EndIf

Return( Nil ) 