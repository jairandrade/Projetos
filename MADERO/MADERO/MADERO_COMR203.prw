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
!Módulo            ! Compras	                                             !
+------------------+---------------------------------------------------------+
!Nome              ! COMR202                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Solicitações / Pedidos / Nf                !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 21/01/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!											!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function COMR203()
Local oReport
Private cPerg := PadR("COMR203",10)

//Incluo/Altero as perguntas na tabela SX1
CriaPerg( cPerg )
//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSessao

oReport := TReport():New("COMR203", "Sc. X Ped.Compra X Nf.", cPerg, {|oReport| ReportPrint(oReport)}, "Sc. X Ped.Compra X Nf.")
oReport:SetLandScape(.T.)
oSessao := TRSection():New(oReport, "Sc. X Ped.Compra X Nf." )

// Colunas padrão
TRCell():New( oSessao, "FILIAL" 	, "", "Filial" 			, "", 15)
TRCell():New( oSessao, "NOME"  		, "", "Descrição" 		, "", 40)
TRCell():New( oSessao, "NUMERO" 	, "", "Numero"			, "", 20)
TRCell():New( oSessao, "TIPO" 		, "", "Tipo"			, "", 10)
TRCell():New( oSessao, "EMISSAO" 	, "", "Dt.Emissão"		, "", 15)
TRCell():New( oSessao, "STATUS" 	, "", "Status" 			, "", 20)
TRCell():New( oSessao, "APROVACAO" 	, "", "Dt.Aprovação"	, "", 15)
TRCell():New( oSessao, "AK_NOME" 	, "", "Aprovador"		, "", 30)
TRCell():New( oSessao, "CR_NIVEL" 	, "", "Nivel"			, "", 10)
TRCell():New( oSessao, "AL_TPLIBER"	, "", "Tipo Liberação"  , "", 15)
TRCell():New( oSessao, "CR_LIBAPRO" , "", "Aprovador Efetivo", "", 30)
TRCell():New( oSessao, "GRPAPROV" 	, "", "Grp.Aprovação"	, "", 18)
TRCell():New( oSessao, "DESCGRPA" 	, "", "Desc.Grupo" 		, "", 30)
TRCell():New( oSessao, "VLRTOTAL" 	, "", "Vlr.Total" 		, "", 15)
oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

Local oBreak
Local oSessao 	:= oReport:Section(1)
Local cAl 		:= GetNextAlias()
Local cWhere	:= '%%'
Local dDtInc
Local dDtAlt
Local cUserLGI 	:= ""
Local cStatus 	:= "" 
Local cTpLiberacao := ""

// Seleciona todas as ordens de carregamento e seus tickets associados de acordo com os parâmetros informados
oSessao:BeginQuery()
If mv_par05 ==1 //somente solicitação de compras
	BeginSQL alias cAl
		SELECT CR_EMISSAO AS EMISSAO,CR_DATALIB AS APROVACAO,CR_USER AS USUARIO,AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO,CR_TIPO as TIPO,CR_NUM AS NUMERO,CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS,CR_TOTAL AS TOTAL
		FROM %table:SCR% SCR
		JOIN %table:ADK% ADK ON ADK.ADK_XFILI = SCR.CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAK% SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' '
		WHERE  SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'SC'
		ORDER BY FILIAL,NUMERO
	EndSQL
ElseIf mv_par05 ==2 //somente pedido de compras
	BeginSQL alias cAl
		SELECT CR_EMISSAO as EMISSAO, CR_DATALIB AS APROVACAO, CR_USER AS USUARIO,AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO,CR_TIPO AS TIPO, CR_NUM AS NUMERO,CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS, CR_TOTAL AS TOTAL
		FROM %table:SCR% SCR
		JOIN %table:SAK%  SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:ADK%  ADK ON ADK_XFILI = CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' '
		WHERE SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'PC'
		ORDER BY FILIAL,NUMERO
	EndSQL
ElseIf mv_par05 ==3 //somente Nf.
	BeginSQL alias cAl
		SELECT CR_EMISSAO AS EMISSAO,CR_DATALIB AS APROVACAO,CR_USER AS USUARIO, AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO, CR_TIPO AS TIPO,CR_NUM AS NUMERO, CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS,CR_TOTAL AS TOTAL
		FROM  %table:SCR% SCR
		JOIN %table:SAK% SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:ADK%  ADK ON ADK.ADK_XFILI = SCR.CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' ' AND SAL.AL_USER = SCR.CR_USER
		WHERE SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'NF'
		ORDER BY FILIAL, NUMERO
	EndSQL
Else
	BeginSQL alias cAl
		SELECT CR_EMISSAO AS EMISSAO,CR_DATALIB AS APROVACAO,CR_USER AS USUARIO,AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO,CR_TIPO as TIPO,CR_NUM AS NUMERO,CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS,CR_TOTAL AS TOTAL, 1 AS SEQ
		FROM %table:SCR% SCR
		JOIN %table:ADK% ADK ON ADK.ADK_XFILI = SCR.CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAK% SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' '
		WHERE  SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'SC'
		UNION
		SELECT CR_EMISSAO as EMISSAO, CR_DATALIB AS APROVACAO, CR_USER AS USUARIO,AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO,CR_TIPO AS TIPO, CR_NUM AS NUMERO,CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS, CR_TOTAL AS TOTAL, 2 AS SEQ
		FROM %table:SCR% SCR
		JOIN %table:SAK%  SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:ADK%  ADK ON ADK_XFILI = CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' '
		WHERE SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'PC'
		UNION
		SELECT CR_EMISSAO AS EMISSAO,CR_DATALIB AS APROVACAO,CR_USER AS USUARIO, AK_NOME AS NOME,AL_TPLIBER,CR_NIVEL,
		(SELECT AK_NOME from %table:SAK% SAK1 WHERE CR_USERLIB = SAK1.AK_USER AND SAK1.D_E_L_E_T_=' ')AS CR_LIBAPRO,
		CR_FILIAL AS FILIAL,ADK_NOME AS DESCRICAO, CR_TIPO AS TIPO,CR_NUM AS NUMERO, CR_GRUPO AS GRUPO,AL_DESC AS DESCGRP,CR_STATUS,CR_TOTAL AS TOTAL,3 AS SEQ
		FROM  %table:SCR% SCR
		JOIN %table:SAK% SAK ON CR_USER = AK_USER AND SAK.D_E_L_E_T_=' '
		JOIN %table:ADK%  ADK ON ADK.ADK_XFILI = SCR.CR_FILIAL AND ADK.D_E_L_E_T_=' '
		JOIN %table:SAL%  SAL ON AL_COD = CR_GRUPO AND SAL.D_E_L_E_T_=' ' AND SAL.AL_USER = SCR.CR_USER
		WHERE SCR.D_E_L_E_T_=' '
		AND CR_FILIAL >= %Exp:MV_PAR01%
		AND CR_FILIAL <= %Exp:MV_PAR02%
		AND CR_EMISSAO BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
		AND CR_TIPO = 'NF'
		ORDER BY FILIAL, SEQ, NUMERO
	EndSQL
EndIf

//Memowrite("c:\temp\COMR203.TXT",getLastQuery()[2])
oSessao:EndQuery()

DbSelectArea(cAl)

(cAl)->(DbGoTop())

ProcRegua(Reccount())

oReport:SetMeter((cAl)->(RecCount()))

oSessao:Init()
Do While (!(cAl)->(Eof()))
	
	If oReport:Cancel()
		Exit
	EndIf
	
	If !VerStatus((cAl)->FILIAL,(cAl)->NUMERO)
		If (cAl)->CR_STATUS == "01"
			cStatus := "Aguard.NivelAnterior"
		ElseIf (cAl)->CR_STATUS == "02"
			cStatus := "Pendente"
		ElseIf (cAl)->CR_STATUS == "03"
			cStatus := "Aprovado"
		ElseIf  (cAl)->CR_STATUS == "04"
			cStatus := "Bloqueado"
		Else
			cStatus := "Lib.OutroUsuario"
		EndIf
	Else
		cStatus := "Doc.Aprovado"
	EndIf
	
	If (cAl)->AL_TPLIBER == "U"
		cTpLiberacao := "Usuário" //Liberaçao Individual
	ElseIf (cAl)->AL_TPLIBER == "N"
		cTpLiberacao := "Nível"//Libera todo o nivel de aprovaçao
	ElseIf (cAl)->AL_TPLIBER == "P"
		cTpLiberacao := "Documento" //Libera todo o documento
	EndIf
	oSessao:Cell("FILIAL"):SetValue((cAl)->FILIAL)
	oSessao:Cell("NOME"):SetValue((cAl)->DESCRICAO)
	oSessao:Cell("NUMERO"):SetValue(Substr((cAl)->NUMERO,1,9))
	oSessao:Cell("TIPO"):SetValue((cAl)->TIPO)
	oSessao:Cell("EMISSAO"):SetValue(dtoc(Stod((cAl)->EMISSAO)))
	oSessao:Cell("STATUS"):SetValue(cStatus)
	oSessao:Cell("APROVACAO"):SetValue(dtoc(Stod((cAl)->APROVACAO)))
	oSessao:Cell("AK_NOME"):SetValue((cAl)->NOME)
	oSessao:Cell("CR_NIVEL"):SetValue((cAl)->CR_NIVEL)
	oSessao:Cell("AL_TPLIBER"):SetValue(cTpLiberacao)
	oSessao:Cell("CR_LIBAPRO"):SetValue((cAl)->CR_LIBAPRO)
	oSessao:Cell("GRPAPROV"):SetValue((cAl)->GRUPO)
	oSessao:Cell("DESCGRPA"):SetValue((cAl)->DESCGRP)
	oSessao:Cell("VLRTOTAL"):SetValue((cAl)->TOTAL)
	oSessao:PrintLine()
	(cAl)->(dbSkip())
	
Enddo

oSessao:Finish()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Função para criação das perguntas na SX1

@author Jair  Matos
@since 24/02/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaPerg( cPerg )

/*/{Protheus.doc} CriaPerg
Função para criar Grupo de Perguntas
@author Jair Matos
@since 01/02/2018
@version 1.0
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
U_XPutSX1(cPerg, "03", "Da data?",    		    "MV_PAR03", "MV_CH2", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial")
U_XPutSX1(cPerg, "04", "Até data?",    	        "MV_PAR04", "MV_CH3", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data final")
U_XPutSX1(cPerg, "05", "Tipo"	,        	    "MV_PAR05", "MV_CH4", "N", 01,  0, "C", cValid,       cF3,   cPicture,        "Solicitação",   "Pedido","N.Fiscal",     "Ambos",    cDef05, "Selecione solicitação de compras / pedido de compras / Nf / ambos")

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} VerStatus()
Função que retorna o status da SCR

@author Jair  Matos
@since 30/01/2019
@version P12
@return
/*/
//---------------------------------------------------------------------
Static Function VerStatus(cFili,cNumero)
Local cQuery 	:= ""
Local lRet := .T.

//Calcula valor
If (Select("SCRP") <> 0)
	DbSelectArea("SCRP")
	SCRP->(DbCloseArea())
Endif

cQuery := " SELECT CR_STATUS, CR_APROV "
cQuery += " FROM " + RetSQLName("SCR") + "  "
cQuery += " WHERE D_E_L_E_T_ <> '*'
cQuery += " AND CR_FILIAL = '"+cFili+"' "
cQuery += " AND CR_NUM = '"+cNumero+"' "
cQuery += " AND CR_USERLIB =' ' "

//Memowrite("c:\temp\PesqScr.txt",CQuery)
TCQuery cQuery new Alias "SCRP"
SCRP->(DbGoTop())

If SCRP->(!Eof())
	lRet := .F.
EndIf

Return lRet




