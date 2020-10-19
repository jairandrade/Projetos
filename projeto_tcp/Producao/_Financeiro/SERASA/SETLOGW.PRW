#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE CR Chr(13) + Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SETLOGW  ºAutor  ³ Kaique Sousa      º Data ³  06/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PARA CRIACAO DO LOG DA ROTINA                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SetLogW(_aLogW,_cTexto,_cFile)

Local _cDtHr	:= DtoC(dDataBase) + ' ' + Time() + '   '
Local _nI		:= 0
Local _cTxt		:= ''

Default _aLogW	:= {}
Default _cFile	:= ''

If Empty(_cFile)
	//Insere o texto
	aAdd( _aLogW , _cDtHr + _cTexto )
Else
	//Insere o texto caso seja passado
	If !Empty(_cTexto)
		aAdd( _aLogW , _cDtHr + _cTexto )
	EndIf
	//Padroniza o nome do arquivo como Log
	If (_nI := At('.',_cFile)) > 0
		_cFile := Substr(_cFile,1,_nI) + 'Log'
	Else
		_cFile := _cFile + '.Log'
	EndIf
	//Gera o Txt do conteudo
	For _nI := 1 To Len(_aLogW)
		_cTxt += _aLogW[_nI] + CR
	Next _nI
	//Grava o Log
	//If GetNewPar("MV_WLOGPFI",.T.)
		//MemoWrite(_cFile,_cTxt)
	//EndIF
EndIf

Return( _cTexto )