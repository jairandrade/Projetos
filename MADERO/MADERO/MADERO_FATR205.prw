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
!Nome              ! FATR205                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Integração de Vendas Sintético             !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 26/03/2019                                              !
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
User Function FATR205()

Local cTitle 	:= OemToAnsi("Relatorio de Integração de Vendas Sintético")
Local cHelp		:= OemToAnsi("Relatorio de Integração de Vendas Sintético")
Local cPerg 	:= PADR("FATR205",10)
Local oRel		:= Nil
Local oSection1	:= Nil 


//Verificar se tabela foi criada no grupo 01 DURSKI e 02 MADERO
If !U_VerTabela("Z02")//fonte MADERO_FUNX100.prw
MSGALERT("Relatório não será gerado para a empresa "+cEmpant+". As tabelas Z01,Z02 não foram criadas.","Informação")
	Return
EndIf
//Cria as perguntas se não existerem
CriaPerg(cPerg)
Pergunte(cPerg, .F.)

//Criacao do componente de impressao
oRel := tReport():New(cPerg,cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
//Seta a orientação do papel
oRel:setPortrait()

oSection1 := trSection():New(oRel,"Relatorio de Integração de Vendas Sintético",{})
trCell():New(oSection1,"Z02_FILIAL"   , "",RetTitle("Z02_FILIAL") ,PesqPict("Z02","Z02_FILIAL")  	,TamSx3("Z02_FILIAL")[1])
trCell():New(oSection1,"ADK_NOME"    , "",RetTitle("ADK_NOME")	,PesqPict("ADK","ADK_NOME") 	,TamSx3("ADK_NOME")[1])
trCell():New(oSection1,"Z02_DATA"    , "",RetTitle("Z02_DATA")  ,PesqPict("Z02","Z02_DATA") 	,TamSx3("Z02_DATA")[1]+5)
trCell():New(oSection1,"VLR_TECNISA" , "","Teknisa"  	  		,PesqPict("Z02","Z02_VRTOT") 	,TamSx3("Z02_VRTOT")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"VLR_PROTHEUS", "","Totvs"   	   	    ,PesqPict("Z02","Z02_VRTOT") 	,TamSx3("Z02_VRTOT")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"STATUS"		 , "","Status"  		    ,"@!"  							,10,,,"RIGHT",,"RIGHT")

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

oSection1:BeginQuery()

BeginSql  Alias cAliasTemp
	SELECT ADK_XFILI,ADK_NOME,Z02_DATA,SUM(Z02_VRTOT) AS TOTAL_TEKNISA 
	FROM %table:ADK% ADK
	LEFT JOIN %table:Z02% Z02 
	ON ADK_XFILI = Z02_FILIAL 
	AND Z02_DATA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%	
	AND Z02.%notDel%
	JOIN %table:Z01% Z01 ON Z01_FILIAL =Z02_FILIAL	AND Z01_CDEMP = ADK_XGEMP AND Z01_CDFIL = ADK_XFIL
    AND Z01_SEQVDA = Z02_SEQVDA AND Z01_CUPOMC <> 'S' AND Z01_DATA = Z02_DATA AND Z01.d_e_l_e_t_ <> '*'
	WHERE ADK_XFILI  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	AND ADK.%notDel%
	AND ADK_XGEMP = %Exp:cEmpant% 
	GROUP BY ADK_XFILI,ADK_NOME,Z02_DATA
	ORDER BY ADK_XFILI
EndSql
//_cResQry:= GETLastQuery()[2]
/*
--NOVA CONSULTA
SELECT Z02_FILIAL, Z02_ENTREG, SUM(Z02_VRTOT) AS TOTAL_TEKNISA 
FROM Z02010 
WHERE D_E_L_E_T_ <> '*'
and Z02_filial in('01MDST0053')
AND Z02_ENTREG = '20200116'
GROUP BY Z02_FILIAL, Z02_ENTREG
ORDER BY Z02_FILIAL, Z02_ENTREG
*/
//Memowrite("c:\temp\_FATR205.txt",_cResQry)
oSection1:EndQuery()

DbSelectArea(cAliasTemp)

(cAliasTemp)->(DbGoTop())

ProcRegua(Reccount())

oRel:SetMeter((cAliasTemp)->(RecCount()))
oSection1:Init()

While !(cAliasTemp)->(EOF())
	nVlrSF2 :=0
	If oRel:Cancel()
		Exit
	EndIf
	//Verifica na tabela SF2 se o faturamento foi efetivado. Caso sim, grava o valor.
	//Cria Funcao de Pesquisa
	nVlrSF2 := PesqSF2((cAliasTemp)->ADK_XFILI,(cAliasTemp)->Z02_DATA)
	If ((cAliasTemp)->TOTAL_TEKNISA> 0) .and. ((cAliasTemp)->TOTAL_TEKNISA = nVlrSF2)
		cStatus = "Integrado"
	Else
		cStatus = "Pendente"
	EndIf
	If MV_PAR05 == 1//Todos
		oSection1:Cell("Z02_FILIAL"):SetValue((cAliasTemp)->ADK_XFILI)
		oSection1:Cell("ADK_NOME"):SetValue((cAliasTemp)->ADK_NOME)
		oSection1:Cell("Z02_DATA"):SetValue((cAliasTemp)->Z02_DATA)
		oSection1:Cell("VLR_TECNISA"):SetValue((cAliasTemp)->TOTAL_TEKNISA)
		oSection1:Cell("VLR_PROTHEUS"):SetValue(nVlrSF2)
		oSection1:Cell("STATUS"):SetValue(cStatus)
		oSection1:PrintLine()
	ElseIf MV_PAR05 == 2 //Vendas Pendente
		If ((cAliasTemp)->TOTAL_TEKNISA <> nVlrSF2) .or. (cAliasTemp)->TOTAL_TEKNISA= 0
			oSection1:Cell("Z02_FILIAL"):SetValue((cAliasTemp)->ADK_XFILI)
			oSection1:Cell("ADK_NOME"):SetValue((cAliasTemp)->ADK_NOME)
			oSection1:Cell("Z02_DATA"):SetValue((cAliasTemp)->Z02_DATA)
			oSection1:Cell("VLR_TECNISA"):SetValue((cAliasTemp)->TOTAL_TEKNISA)
			oSection1:Cell("VLR_PROTHEUS"):SetValue(nVlrSF2)
			oSection1:Cell("STATUS"):SetValue(cStatus)
			oSection1:PrintLine()
		EndIf
	Elseif MV_PAR05 == 3 //Vendas Integrado
		If ((cAliasTemp)->TOTAL_TEKNISA == nVlrSF2) .and. (cAliasTemp)->TOTAL_TEKNISA> 0
			oSection1:Cell("Z02_FILIAL"):SetValue((cAliasTemp)->ADK_XFILI)
			oSection1:Cell("ADK_NOME"):SetValue((cAliasTemp)->ADK_NOME)
			oSection1:Cell("Z02_DATA"):SetValue((cAliasTemp)->Z02_DATA)
			oSection1:Cell("VLR_TECNISA"):SetValue((cAliasTemp)->TOTAL_TEKNISA)
			oSection1:Cell("VLR_PROTHEUS"):SetValue(nVlrSF2)
			oSection1:Cell("STATUS"):SetValue(cStatus)
			oSection1:PrintLine()
		EndIf
	EndIf
	
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
U_XPutSX1(cPerg, "03", "Data de?", 		    	"MV_PAR03", "MV_CH2", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
U_XPutSX1(cPerg, "04", "Data ate?",		    	"MV_PAR04", "MV_CH3", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data final a ser considerada")
U_XPutSX1(cPerg, "05", "Status?",    	        "MV_PAR05", "MV_CH4", "N", 01,  0, "C", cValid,       cF3,   cPicture,         "Todos",   "Pendente",         "Integrado",       cDef04,    cDef05, "Informe a situação do faturamento")
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} PesqSF2(cFilAt,dDataAt)
Pesquisa na tabela SF2

@author 	Jair Matos
@since 		27/03/2019
@version 	P12
@return nValor
/*/
//-------------------------------------------------------------------
Static Function PesqSF2(cFilAt,dDataAt)
Local cQuery := ""
Local nValor := 0
Local cAliaSF2 := GetNextAlias()        // da um nome pro arquivo temporario

cQuery := " SELECT SUM(F2_VALBRUT) AS TOTAL_PROTHEUS "
cQuery += " FROM "+RetSQLName("SF2") + " SF2 "
cQuery += " WHERE F2_FILIAL = '"+cFilAt+"' "
cQuery += " AND F2_EMISSAO 	= '"+dtos(dDataAt)+"' "
cQuery += " and F2_XSEQVDA <> ' '"
cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
//Memowrite("c:\temp\PesqSF2.txt",CQuery)
/*NOVA CONSULTA
SELECT SUM(F2_VALBRUT) FROM SF2010 SF2
JOIN Z01010 Z01 ON Z01_FILIAL = F2_FILIAL AND Z01_SEQVDA = F2_XSEQVDA AND Z01.D_E_L_E_T_ <> '*'
AND Z01_ENTREG = '20200116'
WHERE F2_FILIAL = '01MDST0053'
AND SF2.D_E_L_E_T_ <> '*'
*/

TCQUERY cQuery NEW ALIAS &cAliaSF2
If !Empty((cAliaSF2)->TOTAL_PROTHEUS)
	nValor := (cAliaSF2)->TOTAL_PROTHEUS
EndIf

(cAliaSF2)->(dbCloseArea())

Return nValor