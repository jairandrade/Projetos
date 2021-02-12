#include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} AFAT100
Função que gera o complemento do produto (SB5) através do produto (SB1)
Criar rotina automatizada para gravar na tabela SB5 – Dados adicionais do produto os produtos com 
Tipo de produtos = PA e ME que ainda não estejam na tabela SB5.
@author Jair Andrade
@since 08/02/2021
@version 1.0
@type function
/*/

User Function AFAT100()
	Local aSays 		:={}
	Local aButtons		:={}
	Local nOpca 		:= 0
	Local cPerg       	:= padr("AFAT100",10)
	Private cDeProduto 	:= ""
	Private cAteProduto := ""

	If SuperGetMV("KP_GERASB5", ,"N") == "N"
		MsgAlert("Necessário habilitar o parametro KP_GERASB5 = S para utilizar a rotina","Atenção")
		Return
	EndIf

	AjustaSX1(cPerg)

	Pergunte(cPerg , .F.)

// Inicializa o log de processamento
	//ProcLogIni( aButtons )
	AADD(aSays, 'Este programa tem como objetivo gerar os dados adicionais dos produtos na tabela SB5.')
	AADD(aSays, 'Este processo será automatico e não devera ter interferencias manuais.')
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	FormBatch( 'Geração de Nf´s', aSays, aButtons,, 220, 560 )
	If nOpca == 1
		cDeProduto   := Iif(Empty(MV_PAR01),PADR(,TamSX3("B1_COD")[1],"0"),MV_PAR01)
		cAteProduto  := Iif(Empty(MV_PAR02),PADR(,TamSX3("B1_COD")[1],"9"),MV_PAR02)
		MsAguarde()
		Processa( {|| fProcessa()}, "Aguarde...", "Gravando dados...",.F.)
	EndIf

Return

/*----------------------------------------------------------* 
| Func.: fProcessa                                         |
| Desc.: Função de processamento para gravar o complemento |
*----------------------------------------------------------*/

Static Function fProcessa()
Local aArea  := GetArea()
Local nAtual := 0
Local nTotal := 0
Local nOk    := 0
Local cOk    := ""
Local cMsg   := ""
Local cQuery := ""
Local cAliasSB1 := GetNextAlias()        // da um nome pro arquivo temporario
Private aErros 	:= {}
    
//Posiciona no topo e percorre os registros
cQuery := " SELECT B1_COD,B1_DESC,B1_CODGTIN  "
cQuery += " FROM " + RetSqlName("SB1") + " SB1 (NOLOCK) "
cQuery += " WHERE "
cQuery += " B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += " AND B1_TIPO IN('ME','PA') "
cQuery += " AND B1_CODGTIN <>'' "
cQuery += " AND B1_MSBLQL = '2' "
cQuery += " AND B1_COD >= '" + cDeProduto  + "' AND B1_COD <= '" + cAteProduto + "' "
cQuery += " AND SB1.D_E_L_E_T_ = '' "
cQuery += " AND NOT EXISTS "
cQuery += " (SELECT * FROM " + RetSqlName("SB5") + " SB5 "
cQuery += " WHERE B5_COD = B1_COD AND SB5.D_E_L_E_T_ <> '*') "

TCQUERY cQuery NEW ALIAS &cAliasSB1
(cAliasSB1)->(DbGoTop())
Count To nTotal
(cAliasSB1)->(DbGoTop())
	While !(cAliasSB1)->(Eof())
        nAtual++
        IncProc("Processando "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+" ("+AllTrim(SB1->B1_COD)+")...")
        RecLock('SB5', .T.)
        B5_FILIAL    := FWxFilial('SB5')
        B5_COD       := (cAliasSB1)->B1_COD
        B5_CEME      := (cAliasSB1)->B1_DESC
        B5_2CODBAR   := (cAliasSB1)->B1_CODGTIN
        B5_UMIND     := '1'
        SB5->(MsUnlock())        

        nOk++
		If Empty(cOk)
            cOk := Alltrim((cAliasSB1)->B1_COD)
		Else
            cOk += " - "+Alltrim((cAliasSB1)->B1_COD)
		EndIf
		If len(cOk)> 240
            aAdd(aErros, cOk)
            cOk := ""
		EndIf
        (cAliasSB1)->(dbSKip())
	Enddo
	(cAliasSB1)->(dbCloseArea())
	If !Empty(cOk)
        aAdd(aErros, cOk)
	EndIf
//Se tiver erros ou inclusões, mostra mensagem
	If nOk != 0
        cMsg := "Foram analisados e criados "+cValToChar(nTotal)+" produto(s) na SB5..." + CRLF + CRLF
        cMsg += "Crie o arquivo e salve para conferencia dos produtos incluidos na SB5."+CRLF

        Aviso("Atenção", cMsg, {"Ok"}, 2)

        fSalvArq()
	Else
        cMsg := "Foram analisados e criados "+cValToChar(nTotal)+" produto(s) na SB5..." + CRLF + CRLF

        Aviso("Atenção", cMsg, {"Ok"}, 2)
	EndIf

RestArea(aArea)
Return
//----------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Gera pergunta na SX1
@type function
@version 
@author Jair Andrade
@since 08/02/2021
@return return_type, return_description
/*/
Static Function AjustaSX1(cPerg)
	Local aHelpPor01 := {"Informe o Produto inicial a ser   ",    "considerado na selecao."}
	Local aHelpEng01 := {"",""}
	Local aHelpSpa01 := {"",""}
	Local aHelpPor02 := {"Informe o Produto final  a ser    ",    "considerado na selecao."}
	Local aHelpEng02 := {"",""}
	Local aHelpSpa02 := {"",""}


	CheckSX1(cPerg,"01","Produto  De ? " , "Produto  De ? " , "Produto  De ? " ,"mv_ch1","C", TamSX3("B1_COD")[1] ,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor01,aHelpEng01,aHelpSpa01)
	CheckSX1(cPerg,"02","Produto Ate ? " , "Produto Ate ? " , "Produto Ate ? " ,"mv_ch2","C", TamSX3("B1_COD")[1] ,0,0,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor02,aHelpEng02,aHelpSpa02)
Return()
/*-----------------------------------------------*
| Função: fSalvArq                              |
| Descr.: Função para gerar um arquivo texto    |
*-----------------------------------------------*/

Static Function fSalvArq()
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".TXT"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	Local nX := 0

	//Pegando o caminho do arquivo
	cFileNom:= cGetFile( '*.txt|*.txt' , 'Selecione a pasta para gerar o arquivo', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
		cArqCPag := cFileNom+"Log_SB5.txt"
		//Montando a mensagem
		cTexto := "Função:"+ FunName()
		cTexto += " Usuário:"+ cUserName
		cTexto += " Data:"+ dToC(dDataBase)
		cTexto += " Hora:"+ Time() + cQuebra  + "Log de Erros: Verifique os codigos de produtos criados na SB5" + cQuebra
		For nX := 1 To Len(aErros)
			cTexto +=aErros[nX]+ CRLF
		Next nX

		//Testando se o arquivo já existe
		If File(cArqCPag)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cArqCPag, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cArqCPag,"Atenção")
		EndIf
	EndIf
Return

