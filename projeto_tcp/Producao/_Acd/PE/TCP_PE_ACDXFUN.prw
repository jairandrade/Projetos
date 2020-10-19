#include 'protheus.ch'


/*/{Protheus.doc} CBRETEAN
Ponto de Entrada utilizado para informar os dados pertinentes a etiquetas, quando utilizadas etiquetas de c�digo natural.

@author Rafael Ricardo Vieceli
@since 14/07/2015
@version 1.0
@return aReturn, aArray, ${return_description}
@see http://tdn.totvs.com/display/public/mp/CBRETEAN+-+Informa+Dados+das+Etiquetas+--+24663
/*/
User Function CBRETEAN()

	//C�digo da etiqueta lida
	Local cId  := ParamIXB[1]
	//Valida��es do usu�rio
	//Estrutura do vetor: {"C�digo do Produto","Quantidade","Lote","Data de Validade","N�mero de S�rie"}
	Local aReturn := {}

	Local nQuantidade := 0
	Local cLote       := Space(10)
	Local dValid      := CtoD('')
	Local cNumSerie   := Space(20)

	Local aSaveArea := SaveArea1({"SB1","SB5"})

	//busca pelo codigo de barras
	SB1->( dbSetOrder(5) )
	SB1->( dbSeek(xFilial("SB1")+cId))

	//se encontrar
	IF SB1->( Found() )

		SB5->( dbSetOrder(1) )
		SB5->( dbSeek( xFilial("SB5") + SB1->B1_COD ) )

		//produtos com controle unitario
		IF SB5->( Found() ) .And. SB5->B5_TIPUNIT != '0'
			nQuantidade   := CBQEmb()
		Else
			nQuantidade   := 1
		EndIf
		aReturn := { SB1->B1_COD, nQuantidade, cLote, dValid,  cNumSerie }
	EndIF

	RestArea1(aSaveArea)

Return aReturn


User Function AcdTextoToHtml(cTexto)

	Local aISO_8859_1 := {}
	/*
	fonte: http://www.w3schools.com/charsets/ref_html_8859.asp
	aISO_8859_1[1] Character
	aISO_8859_1[1] Entity Number
	aISO_8859_1[1] Entity Name
	aISO_8859_1[1] Description
	*/
	aAdd( aISO_8859_1, { "&", "&#38;", "&amp;", "ampersand"})
	aAdd( aISO_8859_1, { "<", "&#60;" , "&lt;", "less-than sign"})
	aAdd( aISO_8859_1, { ">", "&#62;" , "&gt;", "greater-than sign"})
	aAdd( aISO_8859_1, { '"', "&#34;", "&quot;", "quotation mark"})
	aAdd( aISO_8859_1, { CRLF, "&lt;br&gt;", "&lt;br&gt;", "capital a, grave accent"})

	aAdd( aISO_8859_1, { "�", "&#192;", "&Agrave;", "capital a, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#193;", "&Aacute;", "capital a, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#194;", "&Acirc;", "capital a, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#195;", "&Atilde;", "capital a, tilde"})
	aAdd( aISO_8859_1, { "�", "&#196;", "&Auml;", "capital a, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#197;", "&Aring;", "capital a, ring"})
	aAdd( aISO_8859_1, { "�", "&#198;", "&AElig;", "capital ae"})
	aAdd( aISO_8859_1, { "�", "&#199;", "&Ccedil;", "capital c, cedilla"})
	aAdd( aISO_8859_1, { "�", "&#200;", "&Egrave;", "capital e, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#201;", "&Eacute;", "capital e, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#202;", "&Ecirc;", "capital e, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#203;", "&Euml;", "capital e, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#204;", "&Igrave;", "capital i, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#205;", "&Iacute;", "capital i, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#206;", "&Icirc;", "capital i, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#207;", "&Iuml;", "capital i, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#208;", "&ETH;", "capital eth, Icelandic"})
	aAdd( aISO_8859_1, { "�", "&#209;", "&Ntilde;", "capital n, tilde"})
	aAdd( aISO_8859_1, { "�", "&#210;", "&Ograve;", "capital o, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#211;", "&Oacute;", "capital o, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#212;", "&Ocirc;", "capital o, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#213;", "&Otilde;", "capital o, tilde"})
	aAdd( aISO_8859_1, { "�", "&#214;", "&Ouml;", "capital o, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#215;", "&times;", "multiplication"})
	aAdd( aISO_8859_1, { "�", "&#216;", "&Oslash;", "capital o, slash"})
	aAdd( aISO_8859_1, { "�", "&#217;", "&Ugrave;", "capital u, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#218;", "&Uacute;", "capital u, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#219;", "&Ucirc;", "capital u, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#220;", "&Uuml;", "capital u, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#221;", "&Yacute;", "capital y, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#222;", "&THORN;", "capital THORN, Icelandic"})
	aAdd( aISO_8859_1, { "�", "&#223;", "&szlig;", "small sharp s, German"})
	aAdd( aISO_8859_1, { "�", "&#224;", "&agrave;", "small a, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#225;", "&aacute;", "small a, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#226;", "&acirc;", "small a, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#227;", "&atilde;", "small a, tilde"})
	aAdd( aISO_8859_1, { "�", "&#228;", "&auml;", "small a, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#229;", "&aring;", "small a, ring"})
	aAdd( aISO_8859_1, { "�", "&#230;", "&aelig;", "small ae"})
	aAdd( aISO_8859_1, { "�", "&#231;", "&ccedil;", "small c, cedilla"})
	aAdd( aISO_8859_1, { "�", "&#232;", "&egrave;", "small e, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#233;", "&eacute;", "small e, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#234;", "&ecirc;", "small e, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#235;", "&euml;", "small e, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#236;", "&igrave;", "small i, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#237;", "&iacute;", "small i, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#238;", "&icirc;", "small i, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#239;", "&iuml;", "small i, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#240;", "&eth;", "small eth, Icelandic"})
	aAdd( aISO_8859_1, { "�", "&#241;", "&ntilde;", "small n, tilde"})
	aAdd( aISO_8859_1, { "�", "&#242;", "&ograve;", "small o, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#243;", "&oacute;", "small o, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#244;", "&ocirc;", "small o, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#245;", "&otilde;", "small o, tilde"})
	aAdd( aISO_8859_1, { "�", "&#246;", "&ouml;", "small o, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#247;", "&divide;	division"})
	aAdd( aISO_8859_1, { "�", "&#248;", "&oslash;", "small o, slash"})
	aAdd( aISO_8859_1, { "�", "&#249;", "&ugrave;", "small u, grave accent"})
	aAdd( aISO_8859_1, { "�", "&#250;", "&uacute;", "small u, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#251;", "&ucirc;", "small u, circumflex accent"})
	aAdd( aISO_8859_1, { "�", "&#252;", "&uuml;", "small u, umlaut mark"})
	aAdd( aISO_8859_1, { "�", "&#253;", "&yacute;", "small y, acute accent"})
	aAdd( aISO_8859_1, { "�", "&#254;", "&thorn;", "small thorn, Icelandic"})
	aAdd( aISO_8859_1, { "�", "&#255;", "&yuml;", "small y, umlaut mark"})

	aEval(aISO_8859_1, { |x| cTexto := StrTran(cTexto, x[1], x[3]) })

Return cTexto