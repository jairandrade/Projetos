#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

//==================================================================================================//
//	Programa: KP04RPBQ		|	Autor: Luis Paulo							|	Data: 16/03/2020	//
//==================================================================================================//
//	Descrição: Relatório produtos bloqueados														//
//																									//
//==================================================================================================//
User function KP04RPBQ()
Local 	aRet 		:= {}
Local 	_cTimeF
Local 	_cHour
Local 	_cMin
Local 	_cSecs

Local 	cNomeArq
Local 	lRecCoo
Local 	cDirSalv
Local 	lSetup
Local	lReport
Local 	lSrV
Local	lPDFPNG
Local 	lViePdf
Private oPrn


_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs


/*
cFilePrintert		Caracter	Nome do arquivo de relatório a ser criado.	X	 
nDevice				Numérico	Tipos de Saída aceitos:IMP_SPOOL Envia para impressora.IMP_PDF Gera arquivo PDF à partir do relatório.Default é IMP_SPOOL	 	 
lAdjustToLegacy		Lógico		Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter. Default é .T.IMPORTANTE: Este cálculos não funcionam corretamente quando houver retângulos do tipo BOX e FILLRECT no relatório, podendo haver distorções de algumas pixels o que acarretará no encavalamento dos retângulos no momento da impressão.	 	 
cPathInServer		Caracter	Diretório onde o arquivo de relatório será salvo	 	 
lDisabeSetup		Lógico		Se .T. não exibe a tela de Setup, ficando à cargo do programador definir quando e se será feita sua chamada. Default é .F.	 	 
lTReport			Lógico		Indica que a classe foi chamada pelo TReport. Default é .F.	 	 
oPrintSetup			Objeto		Objeto FWPrintSetup instanciado pelo usuário.	 	X
cPrinter			Caracter	Impressora destino "forçada" pelo usuário. Default é ""	 	 
lServer				Lógico		Indica impressão via Server (.REL Não será copiado para o Client). Default é .F.	 	 
lPDFAsPNG			Lógico		.T. Indica que será gerado o PDF no formato PNG. O Default é .T.	 	 
lRaw				Lógico		.T. indica impressão RAW/PCL, enviando para o dispositivo de impressão caracteres binários(RAW) ou caracteres programáveis específicos da impressora(PCL)	 	 
lViewPDF			Lógico		Quando o tipo de impressão for PDF, define se arquivo será exibido após a impressão. O default é .T.	 	 
nQtdCopy			Numérico	Define a quantidade de cópias a serem impressas quando utilizado o metodo de impressão igual a SPOOL. Recomendavel em casos aonde a utilização da classe FwMsPrinter se da por meio de eventos sem a intervenção do usuario (JOBs / Schedule por exemplo)Obs: Aplica-se apenas a ambientes que possuam o fonte FwMsPrinter.prw com data igual ou superior a 03/05/2012.	 	 
*/

cNomeArq	:= "Prod_bloq_"+ DTOS(Date()) +_cTimeF+".pdf" //'(cAlias)_'+ DTOS(DATE()) + _cTimeF +'.rel'
lRecCoo		:= .F. 							//Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter. Default é .T.IMPORTANTE: Este cálculos não funcionam corretamente quando houver retângulos do tipo BOX e FILLRECT no relatório, podendo haver distorções de algumas pixels o que acarretará no encavalamento dos retângulos no momento da impressão.
cDirSalv   	:= "dirdoc\Prod_bloq\"
//cDirSalv	:= 'dirdoc\passagens\memo\' 	//Diretório onde o arquivo de relatório será salvo
lSetup		:= .T.							//Se .T. não exibe a tela de Setup, ficando à cargo do programador definir quando e se será feita sua chamada. Default é .F.	
lReport		:= .F.							//Indica que a classe foi chamada pelo TReport. Default é .F.
lSrV		:= .T.							//Indica impressão via Server (.REL Não será copiado para o Client). Default é .F.
lPDFPNG		:= .F.							//.T. Indica que será gerado o PDF no formato PNG. O Default é .T.
lViePdf		:= .F.							//Quando o tipo de impressão for PDF, define se arquivo será exibido após a impressão. O default é .T.	

cNomeRel := cDirSalv+cNomeArq

/* Cria Objeto de Impressao */
oPrn := FWMSPrinter():New(cNomeArq, IMP_PDF ,lRecCoo,cDirSalv,lSetup,lReport,,,lSrV,lPDFPNG,,lViePdf,1) 
//oPrn:= FWMSPrinter():New(cNomeArq,6,,,.T.)
/*
Propriedades
aImages			Lista de imagens do relatório.											Vetor
cFileName		Nome do arquivo a ser gerado.											Caracter
cFilePrint		Arquivo que conterá o binário do relatório.								Caracter
cPathPDF		Path do arquivo PDF.													Caracter
cPathPrint		Nome do diretório onde o relatório será gerado.							Caracter
cPrinter		Nome da impressora para impressão do relatório.							Caracter
cSession		Informações de configuração da impressora.								Caracter
IsFirstPage		Determina se é a primeira página do relatório.							Array of Record
lCanceled		Define se o relatório foi cancelado.									Lógico
lInJob			Determina se o relatório está sendo executado via Job.					Lógico
lServer			Indica impressão via Server (.REL Não será copiado para o Client).		Lógico
lTReport		Indica que o relatório foi chamado pelo TReport.						Lógico
lViewPDF		Indica se o arquivo será exibido após a impressão em PDF.				Lógico
nDevice			Dispositivo de impressão.												Numérico
nModalResult	Retorna o ModalResult do Setup, para que o usuário trate a informação	Numérico
nPageCount		Quantidade de páginas do relatório.										Numérico
nPageHeight		Altura da página.														Numérico
nPageWidth		Largura da página.														Numérico
nPaperSize		Tamanho da folha do relatório.											Numérico
oFontAtu		Fonte do relatório.														Objeto
oPrint			Objeto de impressão.													Objeto
SetPortrait		Define a orientação do relatório como retrato (Portrait).
*/

/*
oPrn:nDevice 			:= IMP_PDF
oPrn:lServer 			:= .T.
oPrn:lInJob 			:= .T.
oPrn:cPathPDF 			:= cDirSalv
oPrn:cPathPrint			:= cDirSalv
oPrn:lViewPDF 			:= .T.
oPrn:lAdjustTolegacy 	:= .F.
oPrn:LPDFASPNG 			:= .F.
oPrn:SetResolution(72)
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(60,60,60,60)
*/

oPrn:SetPortrait()				//Define o relatorio como retrato
oPrn:SetPaperSize(9)			//programado para folha A4
oPrn:SetMargin(10,10,10,10)		//Margem do relatorio
oPrn:cPathPDF 	:= cDirSalv		//Path do arquivo PDF
oPrn:cPathPrint	:= cDirSalv
oPrn:lInJob 			:= .T.

ImpAlias()

Return

Static Function ImpAlias()
//variaveis retangulo
Local aColuna		:= {}		
Local cBloq			:= ""

Private	nLin1		:= 0020
Private	nLin2		:= 0020
Private	nLin3		:= 0720
Private	nLin4		:= 0572

/*fontes*/
Private	oFont05
Private oFont05n
Private oFont06
Private oFont06n
Private oFont07
Private oFont07n
Private oFont08
Private oFont06
Private oFont09
Private oFont09n
Private oFont10
Private oFont10n
Private oFont11
Private oFont11n
Private oFont08n
Private oFont08nn
Private oFont13
Private oFont13n
Private oFont08n
Private oFont08nn
Private oFont15
Private oFont15n
Private oFont16
Private oFont16n
Private oFont17
Private oFont17n
Private oFont18
Private oFont18n

Private cAlias		:= GetNextAlias()	//Para nunca deixar alias fixo para evitar conflito
Private	_nF			:= 1				//Tipo de fonte

Private nLinha		:= 0020
Private nLinha2		:= 0020
Private nLinha3		:= 0020
Private nPag		:= 0

NFonte(_nF)			//carrega as fontes

If Buscar()
	Conout("Não existem dados!")
	(cAlias)->(DBCloseArea())
	Return .T.
EndIf

//lPrint 		:= .T.
oPrn:StartPage()		//Inicia a outra pagina

oPrn:Box(nLin1,nLin2,nLin3,nLin4, "-4" ) //Box pagina
aColuna := Cabec()									//Cabecalho	

While !(cAlias)->(Eof())

	If nLinha > 680
		nPag++					//Caso o numero de linha maior que 690 pula para próxima pagina
		oPrn:EndPage()			//Fecha a pagina
		oPrn:StartPage()		//Inicia a outra pagina
		nLinha	:= 0020
		oPrn:Box(nLin1,nLin2,nLin3,nLin4, "-4" ) //Box pagina
		aColuna	:= Cabec() 		//Imprime o cabeçalho Auxiliar
	EndIf
	
	oPrn:SayAlign (nLinha +=10	, aColuna[1]			, (cAlias)->CODIGO  					, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha   	, aColuna[2]			, SUBSTR((cAlias)->DESCRI,1,28)  	, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[3]			, (cAlias)->STATUS  				, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[4]			, Substr((cAlias)->K0401,1,4)  		, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[5]			, Substr((cAlias)->K0403,1,4)  		, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[6]			, Substr((cAlias)->K0404,1,4)  		, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[7]			, Substr((cAlias)->K0405,1,4)  		, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[8]			, Substr((cAlias)->K0406,1,4)  		, oFont06,0552,,,0,)
	oPrn:SayAlign (nLinha 		, aColuna[9]			, Substr((cAlias)->K0407,1,4)  		, oFont06,0552,,,0,)
	
	IF Alltrim((cAlias)->B1_MSBLQL) == '1'
			cBloq := "BLOQUEADO"
		Else
			cBloq := "DESBLOQUEADO"
	EndIf
	
	oPrn:SayAlign (nLinha 		, aColuna[10]			, cBloq 	, oFont06,0552,,,0,)
	(cAlias)->(DbSkip())
EndDo

oPrn:EndPage()			//Fecha a pagina
oPrn:Print()
(cAlias)->(DBCloseArea())

Return()


Static Function Buscar()
Local cSql 	:= " "
Local cCRLF	:= CRLF
Local _aEx1
Local _aEx2

/* Cria Query */
If Select((cAlias)) <> 0
	DBSelectArea((cAlias))
	(cAlias)->(DBCloseArea())
Endif

cSql := " SELECT SUBSTRING(DESCRICAO,1,30) AS DESCRI,ENTRADPREV AS ENTPREV,QTD_PV_KI AS QTDPVKI,* "+cCRLF
cSql += " FROM VBLOQPROD "+cCRLF
cSql += " WHERE STATUS IN( 'SAINDO DE LINHA','ATIVO') "+cCRLF
cSql += " ORDER BY CODIGO "+cCRLF

//CONOUT(cSql)

TCQuery cSql NEW ALIAS (cAlias)		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea((cAlias))
(cAlias)->(DBGoTop())

Return (cAlias)->(EOF())


Static Function NFonte(_nF)
Private	_nFonte	:= _nF

If 	_nFonte == 1
		oFont05 	:= TFont():New("Arial"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Arial"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Arial"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Arial"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Arial"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Arial"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Arial"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Arial"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Arial"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Arial"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Arial"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Arial"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Arial"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Arial"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Arial"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Arial"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Arial"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Arial"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Arial"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Arial"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Arial"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Arial"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Arial"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Arial"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Arial"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Arial"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 2
		oFont05 	:= TFont():New("Times New Roman"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Times New Roman"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Times New Roman"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Times New Roman"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Times New Roman"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Times New Roman"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Times New Roman"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Times New Roman"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Times New Roman"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Times New Roman"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Times New Roman"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Times New Roman"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Times New Roman"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Times New Roman"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Times New Roman"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Times New Roman"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Times New Roman"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Times New Roman"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Times New Roman"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Times New Roman"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Times New Roman"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Times New Roman"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Times New Roman"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Times New Roman"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Times New Roman"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Times New Roman"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 3
		oFont05 	:= TFont():New("Calibri"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Calibri"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Calibri"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Calibri"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Calibri"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Calibri"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Calibri"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Calibri"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Calibri"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Calibri"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Calibri"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Calibri"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Calibri"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Calibri"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Calibri"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Calibri"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Calibri"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Calibri"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Calibri"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Calibri"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Calibri"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Calibri"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Calibri"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Calibri"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Calibri"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Calibri"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 4
		oFont05 	:= TFont():New("Verdana"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Verdana"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Verdana"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Verdana"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Verdana"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Verdana"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Verdana"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Verdana"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Verdana"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Verdana"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Verdana"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Verdana"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Verdana"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Verdana"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Verdana"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Verdana"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Verdana"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Verdana"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Verdana"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Verdana"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Verdana"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Verdana"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Verdana"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Verdana"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Verdana"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Verdana"			,18,18,,.T.,,,,.T.,.F.)

	ElseIf _nFonte == 5
		oFont05 	:= TFont():New("Tahoma"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Tahoma"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Tahoma"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Tahoma"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Tahoma"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Tahoma"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Tahoma"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Tahoma"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Tahoma"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Tahoma"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Tahoma"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Tahoma"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Tahoma"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Tahoma"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Tahoma"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Tahoma"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Tahoma"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Tahoma"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Tahoma"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Tahoma"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Tahoma"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Tahoma"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Tahoma"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Tahoma"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Tahoma"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Tahoma"			,18,18,,.T.,,,,.T.,.F.)

	Else
		oFont05 	:= TFont():New("Courier New"			,05,05,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont05n	:= TFont():New("Courier New"			,05,05,,.T.,,,,.T.,.F.)
		oFont06 	:= TFont():New("Courier New"			,06,06,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06n	:= TFont():New("Courier New"			,06,06,,.T.,,,,.T.,.F.)
		oFont07 	:= TFont():New("Courier New"			,07,07,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont07n	:= TFont():New("Courier New"			,07,07,,.T.,,,,.T.,.F.)
		oFont08 	:= TFont():New("Courier New"			,08,08,,.F.,,,,.T.,.F.)		//Configura as fontes
		oFont06	:= TFont():New("Courier New"			,08,08,,.T.,,,,.T.,.F.)
		oFont10 	:= TFont():New("Courier New"			,10,10,,.F.,,,,.T.,.F.)
		oFont10n	:= TFont():New("Courier New"			,10,10,,.T.,,,,.T.,.F.)
		oFont11 	:= TFont():New("Courier New"			,11,11,,.F.,,,,.T.,.F.)
		oFont11n	:= TFont():New("Courier New"			,11,11,,.T.,,,,.T.,.F.)
		oFont08n 	:= TFont():New("Courier New"			,12,12,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Courier New"			,12,12,,.T.,,,,.T.,.F.)
		oFont13 	:= TFont():New("Courier New"			,13,13,,.F.,,,,.T.,.F.)
		oFont13n	:= TFont():New("Courier New"			,13,13,,.T.,,,,.T.,.F.)
		oFont08n		:= TFont():New("Courier New"			,14,14,,.F.,,,,.T.,.F.)
		oFont08nn	:= TFont():New("Courier New"			,14,14,,.T.,,,,.T.,.F.)
		oFont15		:= TFont():New("Courier New"			,15,15,,.F.,,,,.T.,.F.)
		oFont15n	:= TFont():New("Courier New"			,15,15,,.T.,,,,.T.,.F.)
		oFont16		:= TFont():New("Courier New"			,16,16,,.F.,,,,.T.,.F.)
		oFont16n	:= TFont():New("Courier New"			,16,16,,.T.,,,,.T.,.F.)
		oFont17		:= TFont():New("Courier New"			,17,17,,.F.,,,,.T.,.F.)
		oFont17n	:= TFont():New("Courier New"			,17,17,,.T.,,,,.T.,.F.)
		oFont18		:= TFont():New("Courier New"			,18,18,,.F.,,,,.T.,.F.)
		oFont18n	:= TFont():New("Courier New"			,18,18,,.T.,,,,.T.,.F.)

EndIf

Return()


//IMPRIME O CABEÇALHO PRINCIPAL
Static Function Cabec()
Local nLinFim	:= 0550
Local cLogotipo := "lgrl01.bmp"
Local nColuna	:= 0025
Local aRetC		:= {}

oPrn:SayBitMap( nLinha += 10, 0030, cLogotipo, 104, 40)

oPrn:say( nLinha += 15	, nLinFim -= 060	, "Produtos bloqueados" 									, oFont10,1400,CLR_HBLUE,		)//-33

oPrn:Line(nLinha += 30, 0020, nLinha, nLin4 )

oPrn:SayAlign (nLinha += 05, nColuna	, "Código" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 80	, "Descri" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 135	, "Status" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 70	, "0401" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 30	, "0403" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 30	, "0404" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 30	, "0405" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 30	, "0406" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 30	, "0407" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)
oPrn:SayAlign (nLinha , nColuna += 35	, "Bloq Geral" , oFont08n,0552,,,0,)
aAdd(aRetC,nColuna)

oPrn:Line(nLinha += 15, 0020, nLinha, nLin4 )

Return(aRetC)
