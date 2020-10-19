#INCLUDE 'PROTHEUS.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREFI059J  บAutor  ณKaique Sousa           บ Data ณ  05/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CONVERTE UMA STRING TEXTO EM ARRAY                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function REFI059J(_cTexto)

Local _cVlPar		:= _cTexto
Local	_cTmp			:= ''
Local _aRet			:= {}
Local nI			:= 1

If Empty(_cVlPar)
	Return( {} )
EndIf

While Right(_cVlPar,1) $ ' ,-|#/'
	_cVlPar := Left(_cVlPar,Len(_cVlPar)-1)
EndDo

//Separo as Formas de Pagamento para montar o Filtro em sintaxe SQL
If (' ' $ AllTrim(_cVlPar)) .OR. (',' $ AllTrim(_cVlPar)) .OR. ('-' $ AllTrim(_cVlPar)) .OR. ('|' $ AllTrim(_cVlPar)) .OR. ('#' $ AllTrim(_cVlPar)) .OR. ('/' $ AllTrim(_cVlPar))
	For nI := 1 To Len(AllTrim(_cVlPar))
		If !(Substr(_cVlPar,nI,1) $ ' ,-|#/') .And. nI <= Len(AllTrim(_cVlPar))
			_cTmp += Substr(_cVlPar,nI,1)
		Else
			aAdd( _aRet, _cTmp )
			_cTmp := ''
		EndIf
	Next nI
	If !Empty(_cTmp)
		aAdd( _aRet, _cTmp )
	EndIf
Else
	aAdd( _aRet, _cVlPar )
EndIf

Return( _aRet )