#include "protheus.ch"

#Define ENTER chr(13)+chr(10)

/*/{Protheus.doc} KESTR26
Função de pesquisa de endereços com saldo do produto posicionado, precisa da variavel private cEndF3
@type function
@version 
@author luizh
@since 23/07/2020
@return bool.
/*/
User Function KESTR26()
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local aRet		:= {}
	Local _cTitulo	:= "Endereços com saldo do produto "
	Local _cCampos	:= ""
	Local _cSelect	:= ""
	Local _cFrom	:= ""
	Local lHasMark	:= .T.
	Local aDados	:= nil
	Local _aCampos	:= nil
	Local cLDblClick:= nil
	Local lMax		:= .F.
	Local _lHasOk	:= .T.

	If Type("cLocalF3") == "U"
		MsgStop("Informe o 'Endereço' de pesquisa.")
	Endif

	If Type("cProdF3") == "U"
		MsgStop("Informe o 'Produto' de pesquisa.")
	Endif

	If Type("cEndF3") == "U"
		cEndF3 := Space( TamSx3("D3_LOCALIZ")[1] )
	Endif

	_cTitulo += AllTrim(cProdF3)

	_cSelect+= "SELECT "
	_cCampos+= "BF_LOCALIZ,BF_LOCAL,BF_QUANT,BF_EMPENHO"
	_cFrom+= " FROM "+RetSqlName("SBF")+" "+ENTER
	_cFrom+= " "+ENTER
	_cFrom+= "WHERE "+ENTER
	_cFrom+= "	D_E_L_E_T_	<>'*' "+ENTER
	_cFrom+= "AND BF_FILIAL	= '"+xFilial("SBF")	+"' "+ENTER
	_cFrom+= "AND BF_LOCAL	= '"+cLocalF3		+"' "+ENTER
	_cFrom+= "AND BF_PRODUTO= '"+cProdF3		+"' "+ENTER
	_cFrom+= "AND BF_QUANT 	> 0 "+ENTER
	_cFrom+= "ORDER BY BF_LOCALIZ "+ENTER
	_cFrom+= " "+ENTER

	aRet := StaticCall(LISTBOX,dialogListBox,_cTitulo,_cCampos,_cSelect,_cFrom,lHasMark,aDados,_aCampos,cLDblClick,lMax,_lHasOk)

	If !Empty(aRet)
		lRet 	:= .T.
		cEndF3 	:= aRet[1][2]
	Endif

	RestArea(aArea)
Return lRet
