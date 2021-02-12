#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
#include "TbiCode.ch" 
#INCLUDE "PROTHEUS.CH"
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: KP06R01	|	Autor: Luis Paulo								|	Data: 23/04/2018	//
//==================================================================================================//
//	Descrição: Funcão para gerar Excel com informações de impostos									//
//																									//
//
//==================================================================================================//
User Function KP06R01()
Local 		aParamBox 	:= {}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private		_cTimeF
Private 	aSelFil		:={}
Private 	cCRLF		:= CRLF

aAdd(aParamBox, { 1,"Vencimento De?"  		,Ctod(Space(8))	,"","","","",50,.F.}) // Tipo data
aAdd(aParamBox, { 1,"Vencimento Até?"  		,Ctod(Space(8))	,"","","","",50,.F.}) // Tipo data
//aAdd(aParamBox, { 6,"Buscar arquivo"		,Space(50)		,"","","",50,.F.,"Todos os arquivos (*.*) |*.*","C:\Temp\"})

If ParamBox(aParamBox,"PLANILHA DE IMPOSTOS - KAPAZI", @aRet,,,lCentered,,, , , .T., .T.)//@aRet Array com respostas - Par 11 salvar perguntas
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
				Return
			Else
				xGeraXml()
		EndIf 
   Else 

Endif
	
Return()

Static Function RetFilFP()
Local nX	:= 1
Local cRet	:= ""

For nX	:= 1 To Len(aSelFil)
	cRet	+=	"'" + aSelFil[nX] + "',"
Next

cRet	:= Substr(cRet,1,Len(cRet)-1)

Return(cRet)

Static Function xGeraXml()
Local 	oExcel
Local 	cDir    	:= "C:\TEMP\"
Local 	cArq    	:= ""
Local 	nLinha		:= 1
Local 	_cCad		:= "Gerar XML"
Local 	_cDirTmp 	//:= "C:\TEMP\"
Local 	_cDir 		:= GetSrvProfString("Startpath","")
Local 	_cHour		:= ""
Local 	_cMin		:= ""
Local 	_cSecs		:= ""
Local 	cValor
Local cDirectory	:= ""
Private cAliasIR
Private cAliasPC
Private cAliasIS
Private cAliasIN

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'c:\funpar\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs

If BuscarA()
	MsgAlert("Não existem dados de IR Retido!!")
EndIf


If BuscarB()
	MsgAlert("Não existem dados de ISS!!")
EndIf

If BuscarC()
	MsgAlert("Não existem dados de PCC!!")
EndIf

If BuscarD()
	MsgAlert("Não existem dados de INSS!!")
EndIf

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs
cArq    	:= "Rel de impostos "+_cTimeF+".xml"

oExcel := FWMsExcel():New()		//Instancia a classe
	
oExcel:AddworkSheet("IR RETIDO")							//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("IR RETIDO","TÍTULOS")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("IR RETIDO","TÍTULOS","NUMERO"			,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","PARCELA"		,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","NATUREZA"  		,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","FORNECEDOR"		,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","CNPJ"			,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","VALOR"			,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","HISTORICO"		,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","VENC TITULO"	,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","DT DIGITACAO"	,3,1)
oExcel:AddColumn("IR RETIDO","TÍTULOS","NF ORIGINAL"	,3,1)

oExcel:AddworkSheet("ISS RETIDO")							//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("ISS RETIDO","TÍTULOS")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("ISS RETIDO","TÍTULOS","NUMERO"		,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","PARCELA"		,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","NATUREZA"  	,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","FORNECEDOR"	,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","CNPJ"			,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","VALOR"			,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","HISTORICO"		,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","VENC TITULO"	,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","DT DIGITACAO"	,3,1)
oExcel:AddColumn("ISS RETIDO","TÍTULOS","NF ORIGINAL"	,3,1)

oExcel:AddworkSheet("PIS-COFINS-CSLL")							//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("PIS-COFINS-CSLL","TÍTULOS")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","NUMERO"		,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","PARCELA"		,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","NATUREZA" 	,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","FORNECEDOR"	,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","CNPJ"			,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","VALOR"		,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","HISTORICO"	,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","VENC TITULO"	,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","DT DIGITACAO"	,3,1)
oExcel:AddColumn("PIS-COFINS-CSLL","TÍTULOS","NF ORIGINAL"	,3,1)

oExcel:AddworkSheet("INSS RETIDO")							//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("INSS RETIDO","TÍTULOS")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("INSS RETIDO","TÍTULOS","NUMERO"			,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","PARCELA"			,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","NATUREZA"  		,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","FORNECEDOR"		,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","CNPJ"				,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","VALOR"			,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","HISTORICO"		,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","VENC TITULO"		,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","DT DIGITACAO"		,3,1)
oExcel:AddColumn("INSS RETIDO","TÍTULOS","NF ORIGINAL"		,3,1)

oExcel:SetFont('Arial')
oExcel:SetFontSize(10)
oExcel:SetTitleBold(.T.)
oExcel:SetTitleSizeFont(16)
oExcel:SetHeaderBold(.T.)
oExcel:SetHeaderSizeFont(14)
oExcel:SetBold(.T.)

ProcRegua(0)
While !cAliasIR->(EOF())
	IncProc()

	cValor		:= Alltrim(Transform(cAliasIR->E2_VALOR,'@E 999,999,999,999.99'))
	oExcel:AddRow("IR RETIDO","TÍTULOS"	,{Alltrim(cAliasIR->E2_NUM),Alltrim(cAliasIR->E2_PARCELA),Alltrim(cAliasIR->E2_NATUREZ),Alltrim(cAliasIR->FORPAI),Alltrim(cAliasIR->CNPJ),cValor,Alltrim(cAliasIR->E2_HIST),DTOC(STOD(cAliasIR->E2_VENCTO)),DTOC(STOD(cAliasIR->E2_EMISSAO)),Alltrim(cAliasIR->TITPAI)})
	cAliasIR->(DbSkip())

EndDo

While !cAliasIS->(EOF())
	IncProc()
	cValor		:= Alltrim(Transform(cAliasIS->E2_VALOR,'@E 999,999,999,999.99'))

	oExcel:AddRow("ISS RETIDO","TÍTULOS"	,{Alltrim(cAliasIS->E2_NUM),Alltrim(cAliasIS->E2_PARCELA),Alltrim(cAliasIS->E2_NATUREZ),Alltrim(cAliasIS->FORPAI),Alltrim(cAliasIS->CNPJ),cValor,Alltrim(cAliasIS->E2_HIST),DTOC(STOD(cAliasIS->E2_VENCTO)),DTOC(STOD(cAliasIS->E2_EMISSAO)),Alltrim(cAliasIS->TITPAI)})
	cAliasIS->(DbSkip())

EndDo

While !cAliasPC->(EOF())
	IncProc()
	cValor		:= Alltrim(Transform(cAliasPC->E2_VALOR,'@E 999,999,999,999.99'))

	oExcel:AddRow("PIS-COFINS-CSLL","TÍTULOS"	,{Alltrim(cAliasPC->E2_NUM),Alltrim(cAliasPC->E2_PARCELA),Alltrim(cAliasPC->E2_NATUREZ),Alltrim(cAliasPC->FORPAI),Alltrim(cAliasPC->CNPJ),cValor,Alltrim(cAliasPC->E2_HIST),DTOC(STOD(cAliasPC->E2_VENCTO)),DTOC(STOD(cAliasPC->E2_EMISSAO)),Alltrim(cAliasPC->TITPAI)})
	cAliasPC->(DbSkip())

EndDo

While !cAliasIN->(EOF())
	IncProc()
	cValor		:= Alltrim(Transform(cAliasIN->E2_VALOR,'@E 999,999,999,999.99'))

	oExcel:AddRow("INSS RETIDO","TÍTULOS"	,{Alltrim(cAliasIN->E2_NUM),Alltrim(cAliasIN->E2_PARCELA),Alltrim(cAliasIN->E2_NATUREZ),Alltrim(cAliasIN->FORPAI),Alltrim(cAliasIN->CNPJ),cValor,Alltrim(cAliasIN->E2_HIST),DTOC(STOD(cAliasIN->E2_VENCTO)),DTOC(STOD(cAliasIN->E2_EMISSAO)),Alltrim(cAliasIN->TITPAI)})
	cAliasIN->(DbSkip())

EndDo

oExcel:Activate() 				//Habilita o uso da classe, indicando que esta configurada e pronto para uso
	
LjMsgRun( "Gerando o arquivo, aguarde...", _cCad, {|| oExcel:GetXMLFile( cArq ) } )//Cria um arquivo no formato XML do MSExcel 2003 em diante 

//oExcel:GetXMLFile("TESTE.xml")	//Arquivo teste.xml gerado com sucesso no \system\

If __CopyFile( cArq, _cDirTmp + cArq )

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
	oExcelApp:SetVisible(.T.)

	ELSE
	
	MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + _cDir )
	MsgInfo( "Arquivo não copiado para temporário do usuário." )

Endif
	
cAliasIR->(DbCloseArea())
cAliasIS->(DbCloseArea())
cAliasPC->(DbCloseArea())
cAliasIN->(DbCloseArea())	
Return()

//Titulos com IR
Static Function BuscarA()
Local cSql 	:= " "
Local _aExc
Local cRetF	:= ""

/* Cria Query */
If Select("cAliasIR") <> 0
	DBSelectArea("cAliasIR")
	cAliasIR->(DBCloseArea())
Endif

cRetF	:= RetFilFP()

cAliasIR := GetNexTAlias()

cSql :=" SELECT	E2_TITPAI,E2_DIRF,E2_CODRET,E2_CODREC, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,1,3) AS PREFPAI,SUBSTRING(E2_TITPAI,4,9) AS TITPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,13,2) AS PARCPAI,SUBSTRING(E2_TITPAI,15,3) AS TIPOPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,18,6) AS FORPAI,SUBSTRING(E2_TITPAI,24,2) AS LOJAPAI, "+cCRLF
cSql +="		ISNULL((SELECT A2_CGC FROM SA2010 WHERE A2_COD = SUBSTRING(E2_TITPAI,18,6) AND A2_LOJA = SUBSTRING(E2_TITPAI,24,2) AND D_E_L_E_T_ = '' ),'') AS CNPJ,*"+cCRLF
cSql +=" FROM "+RetSqlName("SE2")+" SE2"+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF

If !Empty(cRetF)
	cSql	+= " AND SE2.E2_FILIAL IN ("+cRetF+") "+cCRLF
EndIf

cSql +=" AND E2_TITPAI <> ''	"+cCRLF
cSql +=" AND E2_TIPO = 'TX'		"+cCRLF
cSql +=" AND E2_DIRF = '1'		"+cCRLF
cSql +=" AND E2_FORNECE = 'I00001' "+cCRLF
cSql +=" AND E2_EMISSAO >= '"+ DTOS(aRet[1]) +"' "+cCRLF
cSql +=" AND E2_EMISSAO <= '"+ DTOS(aRet[2]) +"' "+cCRLF
cSql +=" AND E2_NATUREZ = '30102' "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS 'cAliasIR'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea("cAliasIR")
cAliasIR->(DBGoTop())

Return cAliasIR->(EOF())


//Titulos com ISS
Static Function BuscarB()
Local cSql 	:= " "
Local _aExc
Local cRetF	:= ""

/* Cria Query */
If Select("cAliasIS") <> 0
	DBSelectArea("cAliasIS")
	cAliasIS->(DBCloseArea())
Endif

cAliasIS := GetNexTAlias()

cRetF	:= RetFilFP()

cSql :=" SELECT	E2_TITPAI,E2_DIRF,E2_CODRET,E2_CODREC, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,1,3) AS PREFPAI,SUBSTRING(E2_TITPAI,4,9) AS TITPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,13,2) AS PARCPAI,SUBSTRING(E2_TITPAI,15,3) AS TIPOPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,18,6) AS FORPAI,SUBSTRING(E2_TITPAI,24,2) AS LOJAPAI, "+cCRLF
cSql +="		ISNULL((SELECT A2_CGC FROM SA2010 WHERE A2_COD = SUBSTRING(E2_TITPAI,18,6) AND A2_LOJA = SUBSTRING(E2_TITPAI,24,2) AND D_E_L_E_T_ = '' ),'') AS CNPJ,*"+cCRLF
cSql +=" FROM "+RetSqlName("SE2")+" SE2"+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF

If !Empty(cRetF)
	cSql	+= " AND SE2.E2_FILIAL IN ("+cRetF+") "+cCRLF
EndIf

cSql +=" AND E2_TITPAI <> ''	"+cCRLF
cSql +=" AND E2_TIPO = 'ISS'	"+cCRLF
cSql +=" AND E2_EMISSAO >= '"+ DTOS(aRet[1]) +"' "+cCRLF
cSql +=" AND E2_EMISSAO <= '"+ DTOS(aRet[2]) +"' "+cCRLF
cSql +=" AND E2_NATUREZ = '30104' "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS 'cAliasIS'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea("cAliasIS")
cAliasIS->(DBGoTop())

Return cAliasIS->(EOF())


//Titulos com PCC
Static Function BuscarC()
Local cSql 	:= " "
Local _aExc
Local cRetF	:= ""

/* Cria Query */
If Select("cAliasPC") <> 0
	DBSelectArea("cAliasPC")
	cAliasPC->(DBCloseArea())
Endif

cAliasPC := GetNexTAlias()

cRetF	:= RetFilFP()

cSql :=" SELECT	E2_TITPAI,E2_DIRF,E2_CODRET,E2_CODREC, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,1,3) AS PREFPAI,SUBSTRING(E2_TITPAI,4,9) AS TITPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,13,2) AS PARCPAI,SUBSTRING(E2_TITPAI,15,3) AS TIPOPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,18,6) AS FORPAI,SUBSTRING(E2_TITPAI,24,2) AS LOJAPAI, "+cCRLF
cSql +="		ISNULL((SELECT A2_CGC FROM SA2010 WHERE A2_COD = SUBSTRING(E2_TITPAI,18,6) AND A2_LOJA = SUBSTRING(E2_TITPAI,24,2) AND D_E_L_E_T_ = '' ),'') AS CNPJ,*"+cCRLF
cSql +=" FROM "+RetSqlName("SE2")+" SE2"+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF

If !Empty(cRetF)
	cSql	+= " AND SE2.E2_FILIAL IN ("+cRetF+") "+cCRLF
EndIf

cSql +=" AND E2_TITPAI <> ''	"+cCRLF
cSql +=" AND E2_TIPO = 'TX'	"+cCRLF
cSql +=" AND E2_NATUREZ = '30101'	"+cCRLF
cSql +=" AND E2_EMISSAO >= '"+ DTOS(aRet[1]) +"' "+cCRLF
cSql +=" AND E2_EMISSAO <= '"+ DTOS(aRet[2]) +"' "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS 'cAliasPC'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea("cAliasPC")
cAliasPC->(DBGoTop())

Return cAliasPC->(EOF())



//Titulos com INSS
Static Function BuscarD()
Local cSql 	:= " "
Local _aExc
Local cRetF	:= ""

/* Cria Query */
If Select("cAliasIN") <> 0
	DBSelectArea("cAliasIN")
	cAliasIN->(DBCloseArea())
Endif

cAliasIN := GetNexTAlias()

cRetF	:= RetFilFP()

cSql :=" SELECT	E2_TITPAI,E2_DIRF,E2_CODRET,E2_CODREC, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,1,3) AS PREFPAI,SUBSTRING(E2_TITPAI,4,9) AS TITPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,13,2) AS PARCPAI,SUBSTRING(E2_TITPAI,15,3) AS TIPOPAI, "+cCRLF
cSql +="		SUBSTRING(E2_TITPAI,18,6) AS FORPAI,SUBSTRING(E2_TITPAI,24,2) AS LOJAPAI, "+cCRLF
cSql +="		ISNULL((SELECT A2_CGC FROM SA2010 WHERE A2_COD = SUBSTRING(E2_TITPAI,18,6) AND A2_LOJA = SUBSTRING(E2_TITPAI,24,2) AND D_E_L_E_T_ = '' ),'') AS CNPJ,*"+cCRLF
cSql +=" FROM "+RetSqlName("SE2")+" SE2"+cCRLF
cSql +=" WHERE D_E_L_E_T_ = '' "+cCRLF

If !Empty(cRetF)
	cSql	+= " AND SE2.E2_FILIAL IN ("+cRetF+") "+cCRLF
EndIf

cSql +=" AND E2_TITPAI <> ''	"+cCRLF
cSql +=" AND E2_TIPO = 'INS'	"+cCRLF
cSql +=" AND E2_NATUREZ = '30103'	"+cCRLF
cSql +=" AND E2_EMISSAO >= '"+ DTOS(aRet[1]) +"' "+cCRLF
cSql +=" AND E2_EMISSAO <= '"+ DTOS(aRet[2]) +"' "+cCRLF

CONOUT(cSql)

TCQuery cSql NEW ALIAS 'cAliasIN'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.
DBSelectArea("cAliasIN")
cAliasIN->(DBGoTop())

Return cAliasIN->(EOF())