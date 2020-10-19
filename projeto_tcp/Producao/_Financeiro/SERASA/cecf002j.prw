#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CECF002J ºAutor  ³ Kaique Sousa      º Data ³  06/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCOES DIVERSAS COM ARQUIVO DE MOTIVOS DE BAIXA           º±±
±±º          ³         _NFUN         _APAR                                º±± 
±±º          ³ ENTRADA 1-EXISTCPO    {SIGLA A PESQUISAR}                  º±±
±±º          ³         2-POSICIONE   {SIGLA A PESQUISAR,COLUNA RETORNO}   º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³         _XRET                                              º±±
±±º          ³ SAIDA   VALOR LOCALIZADO                                   º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User FuncTion CECF002J(_nFun,_aPar)

Local _aArea	:= GetArea()
Local _xRet		:= .F.
Local aCampos 	:= {}
Local cArqTmp 	:= ""
Local cAlias	:= GetNextAlias()
Local cFile 	:= "SIGAADV.MOT"

aCampos:={ 	{"SIGLA"    , 	"C" 	, 03,0},;
			{"DESCR"    , 	"C" 	, 10,0},;
			{"CARTEIRA" , 	"C" 	, 01,0},;
			{"MOVBANC"	,	"C"		, 01,0},;
			{"COMIS"	,	"C"		, 01,0},;
			{"CHEQUE"	,	"C"		, 01,0} }

Do Case
	Case _nFun = 1
		If Empty(_aPar[1]	)
			Return( .T. )
		EndIf
	Case _nFun = 2
		If Empty(_aPar[1]	)
			Return( '' )
		EndIf
EndCase


//cArqTmp := CriaTrab( aCampos , .T.)
//dbUseArea( .T.,, cArqTmp, cAlias, Nil, .F. )

oTempTable := FwTemporaryTable():New( cArqTmp )
oTempTable:SetFields(aCampos)
oTempTable:Create()

dbSelectArea(cAlias)

If !FILE(cFile)
	
	MsgError('Arquivo de Motivos de Baixa SIGAADV.MOT n„o localizado !')
	Return( Nil )
	
Endif

APPEND FROM &cFile SDF

dbGoTop()

Do Case
	Case _nFun = 1
		While !Eof()
			If (cAlias)->SIGLA == _aPar[1]
				_xRet := .T.
				Exit
			EndIf
			DbSkip()
		EndDo
		If !_xRet
			MsgAlert('N„o existe registro relacionado ao código '+_aPar[1])
		EndIf
	Case _nFun = 2
		While !Eof()
			If (cAlias)->SIGLA == _aPar[1]
				_xRet := &(cAlias+'->'+_aPar[2])
				Exit
			Else
				_xRet := ''
			EndIf
			DbSkip()
		EndDo
EndCase

(cAlias)->(DbCloseArea())
//FErase(cArqTmp+GetDBExtension())
oTempTable:Delete()

RestArea(_aArea)

Return( _xRet )
