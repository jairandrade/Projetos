#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Módulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! ESTR206                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Estrutura de Produtos			             !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 30/04/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!PUTSX1 customizado							!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function ESTR206()

	Local cTitle 	:= OemToAnsi("Relatorio de Estrutura de Produtos.")
	Local cHelp		:= OemToAnsi("Relatorio de Estrutura de Produtos.")
	Local cPerg 	:= PADR("ESTR206",10)
	Local oRel		:= Nil
	Local oSection1	:= Nil 

	//Cria as perguntas se não existerem
	CriaPerg(cPerg)
	Pergunte(cPerg, .F.)

	//Criacao do componente de impressao
	oRel := tReport():New(cPerg,cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
	//Seta a orientação do papel
	oRel:setLandscape()

	oSection1 := trSection():New(oRel,"Relatorio de Estrutura de Produtos.",{})
	trCell():New(oSection1,"G1_FILIAL", "",RetTitle("G1_FILIAL"),PesqPict("SG1","G1_FILIAL"),TamSx3("G1_FILIAL")[1])
	trCell():New(oSection1,"ADK_NOME" , "",RetTitle("ADK_NOME")	,PesqPict("ADK","ADK_NOME") ,TamSx3("ADK_NOME")[1])
	trCell():New(oSection1,"G1_COD"   , "","Cod.Produto"		,PesqPict("SG1","G1_COD") 	,TamSx3("G1_COD")[1])
	trCell():New(oSection1,"B1_DESC"   , "","Descrição"  		,PesqPict("SB1","B1_DESC") 	,TamSx3("B1_DESC")[1])
	trCell():New(oSection1,"G1_COMP1"  , "","Cod.Componente 1"	,PesqPict("SG1","G1_COMP") 	,TamSx3("G1_COMP")[1])
	trCell():New(oSection1,"B1_DESC1"   , "","Descrição"  		,PesqPict("SB1","B1_DESC") 	,TamSx3("B1_DESC")[1])
	trCell():New(oSection1,"G1_COMP2"  , "","Cod.Componente 2"  ,PesqPict("SG1","G1_COMP") 	,TamSx3("G1_COMP")[1])
	trCell():New(oSection1,"B1_DESC2"   , "","Descrição"  		,PesqPict("SB1","B1_DESC") 	,TamSx3("B1_DESC")[1])
	trCell():New(oSection1,"G1_QUANT" , "",RetTitle("G1_QUANT") ,PesqPict("SG1","G1_QUANT") ,TamSx3("G1_QUANT")[1])
	trCell():New(oSection1,"G1_INI" , "",RetTitle("G1_INI") ,PesqPict("SG1","G1_INI") ,TamSx3("G1_INI")[1])
	trCell():New(oSection1,"G1_FIM" , "",RetTitle("G1_FIM") ,PesqPict("SG1","G1_FIM") ,TamSx3("G1_FIM")[1])


	oRel:SetTotalInLine(.F.)

	//Executa o relatório
	oRel:PrintDialog()
	Return
	//-------------------------------------------------------------------
	/*/{Protheus.doc} ReportPrint()
	Impressao do formulario grafico conforme laytout no formato retrato

	@author 	Jair Matos
	@since 		24/02/2017
	@version 	P11
	/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oRel)
	Local oSection1	:= oRel:Section(1)
	Local cAliasTemp:= GetNextAlias()
	Local cStatus 	:= ""
	Local nVlrSF2 := 0
	Local cWhere	:= ""
	Local nI := 0
	Private nEstru 	   	:= 0

	cWhere := "%"
	If !Empty(mv_par05)
		cWhere += " AND ADK_XNEGOC = '" +  mv_par05 + "'"
	EndIf 
	If !Empty(mv_par06)
		cWhere += " AND ADK_XSEGUI = '" +  mv_par06 + "'"
	EndIf
	cWhere += "%" 

	oSection1:BeginQuery()
	BeginSql  Alias cAliasTemp
		SELECT  G1_FILIAL,ADK_NOME,G1_COD, G1_COMP , G1_QUANT,G1_INI,G1_FIM
		FROM %table:SG1% SG1
		JOIN %table:ADK% ADK ON ADK_XFILI = G1_FILIAL AND ADK.%notDel% 	
		%Exp:cWhere%
		WHERE G1_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND SG1.%notDel%
		AND G1_COD BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
		ORDER BY G1_FILIAL,G1_COD
	EndSql
	//_cResQry:= GETLastQuery()[2]
	//Memowrite("c:\temp\_ESTR206.txt",_cResQry)
	oSection1:EndQuery()

	DbSelectArea(cAliasTemp)

	(cAliasTemp)->(DbGoTop())

	ProcRegua(Reccount())

	oRel:SetMeter((cAliasTemp)->(RecCount()))
	oSection1:Init()
	While !(cAliasTemp)->(EOF())//nivel 0

		If oRel:Cancel()
			Exit
		EndIf

		//Faz a explosão da estrutura basedo na Quantidade que vai ser produzida
		_aQuemUsa := _QuemUsa((cAliasTemp)->G1_FILIAL,(cAliasTemp)->G1_COMP) // Os demais parâmetros são de uso interno da função para chamadas recursivas.
		For nI := 1 To Len(_aQuemUsa)
			If  Len(_aQuemUsa) == 1
				oSection1:Cell("G1_FILIAL"):SetValue((cAliasTemp)->G1_FILIAL)
				oSection1:Cell("ADK_NOME"):SetValue((cAliasTemp)->ADK_NOME)
				oSection1:Cell("G1_COD"):SetValue((cAliasTemp)->G1_COD)
				oSection1:Cell("B1_DESC"):SetValue(Posicione("SB1", 01, (cAliasTemp)->G1_FILIAL + (cAliasTemp)->G1_COD, "B1_DESC"))
				oSection1:Cell("G1_COMP1"):SetValue(SubStr(_aQuemUsa[nI][2], 1, TamSX3("B1_COD")[1]))
				oSection1:Cell("B1_DESC1"):SetValue(Posicione("SB1", 01, (cAliasTemp)->G1_FILIAL + _aQuemUsa[nI][2], "B1_DESC"))
				oSection1:Cell("G1_COMP2"):SetValue("")
				oSection1:Cell("B1_DESC2"):SetValue("")
				oSection1:Cell("G1_QUANT"):SetValue((cAliasTemp)->G1_QUANT)
				oSection1:PrintLine()
			ElseIf Len(_aQuemUsa) > 1 .AND. _aQuemUsa[nI][1] <> 1
				oSection1:Cell("G1_FILIAL"):SetValue((cAliasTemp)->G1_FILIAL)
				oSection1:Cell("ADK_NOME"):SetValue((cAliasTemp)->ADK_NOME)
				oSection1:Cell("G1_COD"):SetValue((cAliasTemp)->G1_COD)
				oSection1:Cell("B1_DESC"):SetValue(Posicione("SB1", 01, (cAliasTemp)->G1_FILIAL + (cAliasTemp)->G1_COD, "B1_DESC"))
				oSection1:Cell("G1_COMP1"):SetValue(SubStr(_aQuemUsa[nI][3], 1, TamSX3("B1_COD")[1]))
				oSection1:Cell("B1_DESC1"):SetValue(Posicione("SB1", 01, (cAliasTemp)->G1_FILIAL + _aQuemUsa[nI][3], "B1_DESC"))
				oSection1:Cell("G1_COMP2"):SetValue(SubStr(_aQuemUsa[nI][2], 1, TamSX3("B1_COD")[1]))
				oSection1:Cell("B1_DESC2"):SetValue(Posicione("SB1", 01, (cAliasTemp)->G1_FILIAL + _aQuemUsa[nI][2], "B1_DESC"))
				oSection1:Cell("G1_QUANT"):SetValue((cAliasTemp)->G1_QUANT* _aQuemUsa[nI][4])
				oSection1:PrintLine()
			EndIf
		Next nI


		(cAliasTemp)->(dbSkip())
	Enddo
	oSection1:Finish()
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Função para criação das perguntas na SX1

@author Jair  Matos
@since 11/12/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaPerg( cPerg )

	/*/{Protheus.doc} CriaPerg
	Função para criar Grupo de Perguntas
	@author Jair Matos
	@since 11/12/2018
	@version P12
	@type function
	@param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
	@param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
	@param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto Até, Data De, ...)
	@param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
	@param cVariavel, characters, Variável da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
	@param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = Numérico, D = Data)
	@param nTamanho,  numeric,    Tamanho da Pergunta      (Máximo de 60)
	@param nDecimal,  numeric,    Tamanho de Decimais      (Máximo de 9)
	@param cTipoPar,  characters, Tipo do Parâmetro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
	@param cValid,    characters, Validação da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
	@param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
	@param cPicture,  characters, Máscara do Parâmetro     (ex.: @!, @E 999.99, ...)
	@param cDef01,    characters, Primeira opção do combo
	@param cDef02,    characters, Segunda opção do combo
	@param cDef03,    characters, Terceira opção do combo
	@param cDef04,    characters, Quarta opção do combo
	@param cDef05,    characters, Quinta opção do combo
	@param cHelp,     characters, Texto de Help do parâmetro
	@obs Função foi criada, pois a partir de algumas versões do Protheus 12, a função padrão PutSX1 não funciona (por medidas de segurança)
	@example Abaixo um exemplo de como criar um grupo de perguntas
	/*/

	cValid   := ""
	cF3      := ""
	cPicture := ""
	cDef01   := ""
	cDef02   := ""
	cDef03   := ""
	cDef04   := ""
	cDef05   := ""

	U_XPutSX1(cPerg, "01", "Filial De?",       		"MV_PAR01", "MV_CH0", "C", 10, 	0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial inicial")
	U_XPutSX1(cPerg, "02", "Filial Até?",      		"MV_PAR02", "MV_CH1", "C", 10,  0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial final")
	U_XPutSX1(cPerg, "03", "Produto de?",  		   	"MV_PAR03", "MV_CH2", "C", 15,  0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto ")
	U_XPutSX1(cPerg, "04", "Produto ate",    	    "MV_PAR04", "MV_CH4", "C", 15,  0, "G", cValid,     "SB1",   cPicture,         cDef01,   cDef02,         cDef03,       cDef04,    cDef05, "Informe o produto")
	U_XPutSX1(cPerg, "05", "Negocio",    	    	"MV_PAR05", "MV_CH5", "C", 02,  0, "G", cValid,     "ZA ",   cPicture,         cDef01,   cDef02,         cDef03,       cDef04,    cDef05, "Informe o negocio")
	U_XPutSX1(cPerg, "06", "Segmento",    	    	"MV_PAR06", "MV_CH6", "C", 02,  0, "G", cValid,     "ZB ",   cPicture,         cDef01,   cDef02,         cDef03,       cDef04,    cDef05, "Informe o segmento")
Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} _QuemUsa
Função para gerar os codigos PAI / FILHO utilizando RECURSIVIDADE

@author Jair  Matos
@since 07/05/2019
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function _QuemUsa (cFiliAtu ,_sItem, _aLista, _nNivel, _sCaminho,nQuant)

	Local _nRegSG1 := 0 // Por que a chamada recursiva desposiciona o SG1
	If _aLista == NIL
		_aLista = {}
		_nNivel = 1
		_sCaminho = ""
		nQuant := 0
	EndIf

	aadd (_aLista, {_nNivel, ;              // Nivel na estrutura.
	_sItem, ;        						// Pai
	_sCaminho,;								// Caminho de itens percorridos para chegar ao atual, em formato string.
	nQuant})       						    // quantidade por produto

	// Acrescenta os filhos encontrados, mas antes verifica a estrutura de cada um.
	// Se nao tem mais filhos, retorna a lista como estah.
	SG1->(dbsetorder (1)) // G1_FILIAL+G1_COMP+G1_COD
	SG1->(dbseek(cFiliAtu +_sItem, .T.))
	Do While !SG1->(eof()) .and. SG1-> G1_FILIAL==cFiliAtu .and. SG1->G1_COD==_sItem
		_nRegSG1 = SG1->(RECNO()) // Preciso guardar, pois a chamada recursiva desposiciona
		_aLista := _QuemUsa (cFiliAtu,SG1->G1_COMP, _aLista, _nNivel + 1, _sItem + "," + _sCaminho,SG1->G1_QUANT)
		SG1->(DBGOTO(_nRegSG1))
		SG1->(dbskip ())
	enddo
return _aLista