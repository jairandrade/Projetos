#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE   CR   Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REFI062J  ºAutor  ³ Kaique Sousa      º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MARCA O REGISTRO PARA EXCLUSAO (POSITIVACAO).               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function REFI062J(_cMarca)

Local _aArea		:= GetArea()
Local _lSele		:= .F.
Local _nSele		:= 0
Local _nAviso		:= 1
Local _aDet			:= {}
Local _cMotivo		:= ''

While !_lSele
	
	If ConPad1(,,,'ZP2',,,.F.)
		
		_cMotivo 	:= ZP2->ZP2_COD
		_nSele 		:= Aviso('Atenção','Motivo '+ _cMotivo + '-' + Posicione('ZP2',1,xFilial('ZP2')+_cMotivo+'001','ZP2_DESCRI'),{'Mot.','Não','Sim'},,'Confirma Positivação ?')
		
		If _nSele = 3
			Processa({|| S062JPROC(_cMotivo,@_aDet)},'Positivar Titulos','Marcando registros...',.F.)
			While _nAviso = 1
				_nAviso := 0
				_nAviso := Aviso('Atenção','Operação realizada com sucesso !',{'Log','OK'},,'Positivação Realizada')
				If _nAviso = 1
					U_REFI045J(_aDet,"Log da Positivação")
				EndIf
			EndDo
			_lSele := .T.
		ElseIf _nSele = 2
			_lSele := .T.
		EndIf
	Else
		_lSele := .T.
	EndIf
	
EndDo

RestArea(_aArea)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³062JPROC  ºAutor  ³ Kaique Sousa      º Data ³  06/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PROCESSA OS REGISTROS MARCANDO PARA POSITIVACAO.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function S062JPROC(_cMotivo,_aDet)

Local _cMsgi		:= ''
Local _nReg			:= 0
Local _nProc		:= 0
Local _lPosit		:= .F.

Default _aDet		:= {}

DbSelectArea(_cArqTrb)
DbGoTop()

ProcRegua(0)

_aDet  := {{'Título','Status','Ação'}}

While !Eof()
	If IsMark('E1_OK',_cMarca,.F.)
		
		SE1->(DbGoTo((_cArqTrb)->E1_RECNO))
		_nProc++
		_lPosit	:= U_REFI063J((_cArqTrb)->E1_RECNO,'E',@_aDet)
		
		If _lPosit
			Begin Transaction
			U_REFI060J((_cArqTrb)->E1_RECNO,'E!',,,,,_cMotivo)
			End Transaction
			If lMsErroAuto
				DisarmTransaction()
			EndIf
		EndIf
		
	EndIf
	
	_nReg++
	IncProc('Positivando... [Processados/Marcados]  ' + cValToChar(_nReg)+'/'+cValToChar(_nProc) )
	DbSkip()
	
EndDo

If Len(_aDet) = 1
	_aDet := {}
EndIf

Return( Nil )  