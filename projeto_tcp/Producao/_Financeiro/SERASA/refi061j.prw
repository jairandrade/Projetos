#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE   CR   Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REFI061J  ºAutor  ³ Kaique Sousa      º Data ³  06/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PROCESSA A MARCACAO DO TITULO PARA NEGATIVAR.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function REFI061J(_cMarca)

Local _aArea		:= GetArea()
Local _nAviso		:= 1
Local _aDet			:= {}

If Aviso('Atenção','.',{'Não','Sim'},,'Confirma Negativação ?') = 2

	Processa({|| S061JPROC(@_aDet)},'Negativar Titulos','Marcando registros...',.F.)

	While _nAviso = 1
		_nAviso := 0
		_nAviso := Aviso('Atenção','Operação realizada com sucesso !',{'Log','OK'},,'Negativação Realizada')
  		If _nAviso = 1
			U_REFI045J(_aDet,"Log da Negativação")
		EndIf
	EndDo

EndIf

RestArea(_aArea)

Return( Nil )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³061JPROC  ºAutor  ³ Kaique Sousa      º Data ³  06/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PROCESSA OS REGISTROS MARCANDO PARA NEGATIVACAO.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function S061JPROC(_aDet)

Local _cMsgi		:= '' 
Local _nReg		:= 0
Local _nProc		:= 0
Local _lNegat		:= .F.

Default _aDet		:= {}

DbSelectArea(_cArqTrb)
DbGoTop()

ProcRegua(0)

_aDet  := {{'Título','Status','Ação'}}

While !Eof()
	If IsMark('E1_OK',_cMarca,.F.)

		SE1->(DbGoTo((_cArqTrb)->E1_RECNO))
		_nProc++
		_lNegat := U_REFI063J((_cArqTrb)->E1_RECNO,'I',@_aDet)

		If _lNegat
			Begin Transaction
				U_REFI060J((_cArqTrb)->E1_RECNO,'I!')
			End Transaction 		
			If lMsErroAuto
				DisarmTransaction()
			EndIf
		EndIf

	EndIf

	_nReg++
	IncProc('Negativando... [Processados/Marcados]  ' + cValToChar(_nReg)+'/'+cValToChar(_nProc) )
	DbSkip()

EndDo

If Len(_aDet) = 1
	_aDet := {}
EndIf

Return( Nil )      


