#include 'protheus.ch'


/*/{Protheus.doc} CBRETEAN
Ponto de Entrada utilizado para informar os dados pertinentes a etiquetas, quando utilizadas etiquetas de código natural.

@author Rafael Ricardo Vieceli
@since 14/07/2015
@version 1.0
@return aReturn, aArray, ${return_description}
@see http://tdn.totvs.com/display/public/mp/CBRETEAN+-+Informa+Dados+das+Etiquetas+--+24663
/*/
User Function CBRETEAN()

	//Código da etiqueta lida
	Local cId  := ParamIXB[1]
	//Validações do usuário
	//Estrutura do vetor: {"Código do Produto","Quantidade","Lote","Data de Validade","Número de Série"}
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

	aAdd( aISO_8859_1, { "À", "&#192;", "&Agrave;", "capital a, grave accent"})
	aAdd( aISO_8859_1, { "Á", "&#193;", "&Aacute;", "capital a, acute accent"})
	aAdd( aISO_8859_1, { "Â", "&#194;", "&Acirc;", "capital a, circumflex accent"})
	aAdd( aISO_8859_1, { "Ã", "&#195;", "&Atilde;", "capital a, tilde"})
	aAdd( aISO_8859_1, { "Ä", "&#196;", "&Auml;", "capital a, umlaut mark"})
	aAdd( aISO_8859_1, { "Å", "&#197;", "&Aring;", "capital a, ring"})
	aAdd( aISO_8859_1, { "Æ", "&#198;", "&AElig;", "capital ae"})
	aAdd( aISO_8859_1, { "Ç", "&#199;", "&Ccedil;", "capital c, cedilla"})
	aAdd( aISO_8859_1, { "È", "&#200;", "&Egrave;", "capital e, grave accent"})
	aAdd( aISO_8859_1, { "É", "&#201;", "&Eacute;", "capital e, acute accent"})
	aAdd( aISO_8859_1, { "Ê", "&#202;", "&Ecirc;", "capital e, circumflex accent"})
	aAdd( aISO_8859_1, { "Ë", "&#203;", "&Euml;", "capital e, umlaut mark"})
	aAdd( aISO_8859_1, { "Ì", "&#204;", "&Igrave;", "capital i, grave accent"})
	aAdd( aISO_8859_1, { "Í", "&#205;", "&Iacute;", "capital i, acute accent"})
	aAdd( aISO_8859_1, { "Î", "&#206;", "&Icirc;", "capital i, circumflex accent"})
	aAdd( aISO_8859_1, { "Ï", "&#207;", "&Iuml;", "capital i, umlaut mark"})
	aAdd( aISO_8859_1, { "Ð", "&#208;", "&ETH;", "capital eth, Icelandic"})
	aAdd( aISO_8859_1, { "Ñ", "&#209;", "&Ntilde;", "capital n, tilde"})
	aAdd( aISO_8859_1, { "Ò", "&#210;", "&Ograve;", "capital o, grave accent"})
	aAdd( aISO_8859_1, { "Ó", "&#211;", "&Oacute;", "capital o, acute accent"})
	aAdd( aISO_8859_1, { "Ô", "&#212;", "&Ocirc;", "capital o, circumflex accent"})
	aAdd( aISO_8859_1, { "Õ", "&#213;", "&Otilde;", "capital o, tilde"})
	aAdd( aISO_8859_1, { "Ö", "&#214;", "&Ouml;", "capital o, umlaut mark"})
	aAdd( aISO_8859_1, { "×", "&#215;", "&times;", "multiplication"})
	aAdd( aISO_8859_1, { "Ø", "&#216;", "&Oslash;", "capital o, slash"})
	aAdd( aISO_8859_1, { "Ù", "&#217;", "&Ugrave;", "capital u, grave accent"})
	aAdd( aISO_8859_1, { "Ú", "&#218;", "&Uacute;", "capital u, acute accent"})
	aAdd( aISO_8859_1, { "Û", "&#219;", "&Ucirc;", "capital u, circumflex accent"})
	aAdd( aISO_8859_1, { "Ü", "&#220;", "&Uuml;", "capital u, umlaut mark"})
	aAdd( aISO_8859_1, { "Ý", "&#221;", "&Yacute;", "capital y, acute accent"})
	aAdd( aISO_8859_1, { "Þ", "&#222;", "&THORN;", "capital THORN, Icelandic"})
	aAdd( aISO_8859_1, { "ß", "&#223;", "&szlig;", "small sharp s, German"})
	aAdd( aISO_8859_1, { "à", "&#224;", "&agrave;", "small a, grave accent"})
	aAdd( aISO_8859_1, { "á", "&#225;", "&aacute;", "small a, acute accent"})
	aAdd( aISO_8859_1, { "â", "&#226;", "&acirc;", "small a, circumflex accent"})
	aAdd( aISO_8859_1, { "ã", "&#227;", "&atilde;", "small a, tilde"})
	aAdd( aISO_8859_1, { "ä", "&#228;", "&auml;", "small a, umlaut mark"})
	aAdd( aISO_8859_1, { "å", "&#229;", "&aring;", "small a, ring"})
	aAdd( aISO_8859_1, { "æ", "&#230;", "&aelig;", "small ae"})
	aAdd( aISO_8859_1, { "ç", "&#231;", "&ccedil;", "small c, cedilla"})
	aAdd( aISO_8859_1, { "è", "&#232;", "&egrave;", "small e, grave accent"})
	aAdd( aISO_8859_1, { "é", "&#233;", "&eacute;", "small e, acute accent"})
	aAdd( aISO_8859_1, { "ê", "&#234;", "&ecirc;", "small e, circumflex accent"})
	aAdd( aISO_8859_1, { "ë", "&#235;", "&euml;", "small e, umlaut mark"})
	aAdd( aISO_8859_1, { "ì", "&#236;", "&igrave;", "small i, grave accent"})
	aAdd( aISO_8859_1, { "í", "&#237;", "&iacute;", "small i, acute accent"})
	aAdd( aISO_8859_1, { "î", "&#238;", "&icirc;", "small i, circumflex accent"})
	aAdd( aISO_8859_1, { "ï", "&#239;", "&iuml;", "small i, umlaut mark"})
	aAdd( aISO_8859_1, { "ð", "&#240;", "&eth;", "small eth, Icelandic"})
	aAdd( aISO_8859_1, { "ñ", "&#241;", "&ntilde;", "small n, tilde"})
	aAdd( aISO_8859_1, { "ò", "&#242;", "&ograve;", "small o, grave accent"})
	aAdd( aISO_8859_1, { "ó", "&#243;", "&oacute;", "small o, acute accent"})
	aAdd( aISO_8859_1, { "ô", "&#244;", "&ocirc;", "small o, circumflex accent"})
	aAdd( aISO_8859_1, { "õ", "&#245;", "&otilde;", "small o, tilde"})
	aAdd( aISO_8859_1, { "ö", "&#246;", "&ouml;", "small o, umlaut mark"})
	aAdd( aISO_8859_1, { "÷", "&#247;", "&divide;	division"})
	aAdd( aISO_8859_1, { "ø", "&#248;", "&oslash;", "small o, slash"})
	aAdd( aISO_8859_1, { "ù", "&#249;", "&ugrave;", "small u, grave accent"})
	aAdd( aISO_8859_1, { "ú", "&#250;", "&uacute;", "small u, acute accent"})
	aAdd( aISO_8859_1, { "û", "&#251;", "&ucirc;", "small u, circumflex accent"})
	aAdd( aISO_8859_1, { "ü", "&#252;", "&uuml;", "small u, umlaut mark"})
	aAdd( aISO_8859_1, { "ý", "&#253;", "&yacute;", "small y, acute accent"})
	aAdd( aISO_8859_1, { "þ", "&#254;", "&thorn;", "small thorn, Icelandic"})
	aAdd( aISO_8859_1, { "ÿ", "&#255;", "&yuml;", "small y, umlaut mark"})

	aEval(aISO_8859_1, { |x| cTexto := StrTran(cTexto, x[1], x[3]) })

Return cTexto