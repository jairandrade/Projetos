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
!Nome              ! FATR200                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório Venda Sintético com impostos	                 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 11/12/2018                                              !
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
User Function FATR200()

Local cTitle 	:= OemToAnsi("Relatorio de Vendas Sintético")
Local cHelp		:= OemToAnsi("Relatorio de Vendas Sintético")
Local cPerg 	:= padr("FATR200",10)
Local oRel		:= Nil
Local oSection1	:= Nil
Local cLogo := "SYSTEM\LGRL01.BMP"
Private rs 		:= 0  

//Cria as perguntas se não existerem
CriaPerg(cPerg)
Pergunte(cPerg, .F.)

//Criacao do componente de impressao
oRel := tReport():New(cPerg,cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
//Seta a orientação do papel
oRel:setLandscape()

oSection1 := trSection():New(oRel,"Relatorio de Vendas Sintético - Data",{})
trCell():New(oSection1,"D2_FILIAL",	"",RetTitle("D2_FILIAL")  ,PesqPict("SD2","D2_FILIAL")  	,TamSx3("D2_FILIAL")[1])
trCell():New(oSection1,"ADK_NOME",	"",RetTitle("ADK_NOME")	  ,PesqPict("ADK","ADK_NOME") 		,TamSx3("ADK_NOME")[1])
trCell():New(oSection1,"D2_EMISSAO","",	RetTitle("D2_EMISSAO"),PesqPict("SD2","D2_EMISSAO") 	,TamSx3("D2_EMISSAO")[1]+5)
trCell():New(oSection1,"D2_TOTAL", 	"","Valor Mercadoria"  	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"DESCONTO", 	"","Desconto(-)"   	   	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"ACRESCIMO", "","Acréscimo(+)"  		  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")   
trCell():New(oSection1,"GORJETA",	"","Gorjeta(+)"  	  	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")  
trCell():New(oSection1,"D2_VALFRE", "","Valor Frete(+)"    	  ,PesqPict("SD2","D2_VALFRE") 		,TamSx3("D2_VALFRE")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"VLRTOTAL",  "","Valor Total"  	   	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")  
trCell():New(oSection1,"D2_BASEICM","","Base Icms"  	   	  ,PesqPict("SD2","D2_BASEICM") 	,TamSx3("D2_BASEICM")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_VALICM", "","Valor Icms"  	   	  ,PesqPict("SD2","D2_VALICM") 		,TamSx3("D2_VALICM")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_BASIMP6","","Base Pis"  	   	  	  ,PesqPict("SD2","D2_BASIMP6") 	,TamSx3("D2_BASIMP6")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_BASIMP5","","Base Cofins"  	   	  ,PesqPict("SD2","D2_BASIMP5") 	,TamSx3("D2_BASIMP5")[1],,,"RIGHT",,"RIGHT")  
trCell():New(oSection1,"D2_VALIMP6", "","Valor Pis"  	   	  ,PesqPict("SD2","D2_VALIMP6") 	,TamSx3("D2_VALIMP6")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_VALIMP5", "","Valor Cofins"  	  ,PesqPict("SD2","D2_VALIMP5") 	,TamSx3("D2_VALIMP5")[1],,,"RIGHT",,"RIGHT")  
trCell():New(oSection1,"D2_VALIPI",  "","Valor IPI"  	   	  ,PesqPict("SD2","D2_VALIPI") 		,TamSx3("D2_VALIPI")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_VALISS",  "","Valor ISS"  	   	  ,PesqPict("SD2","D2_VALISS") 	    ,TamSx3("D2_VALISS")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection1,"D2_ICMSRET", "","Valor ICMS-ST"  	  ,PesqPict("SD2","D2_ICMSRET") 	,TamSx3("D2_ICMSRET")[1],,,"RIGHT",,"RIGHT") 


//	Totalizacao
oBreak := TRBreak():New(oSection1,oSection1:Cell("D2_FILIAL"),	"Totais:",	.F.)
TRFunction():New(oSection1:Cell("D2_FILIAL"),,"COUNT",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_TOTAL"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("DESCONTO"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("ACRESCIMO"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("GORJETA"),,"SUM",oBreak,,,,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALFRE"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("VLRTOTAL"),,"SUM",oBreak,,,,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_BASEICM"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_VALICM"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_BASIMP6"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_BASIMP5"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_VALIMP6"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_VALIMP5"),,"SUM",oBreak,,,,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALIPI"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_VALISS"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection1:Cell("D2_ICMSRET"),,"SUM",oBreak,,,,.F.,.F.)

oSection2 := TRSection():New(oRel,"Relatorio de Vendas Sintético",{})
trCell():New(oSection2,"D2_FILIAL",	"",RetTitle("D2_FILIAL")  ,PesqPict("SD2","D2_FILIAL")  	,TamSx3("D2_FILIAL")[1])
trCell():New(oSection2,"ADK_NOME",	"",RetTitle("ADK_NOME")	  ,PesqPict("ADK","ADK_NOME") 		,TamSx3("ADK_NOME")[1])
trCell():New(oSection2,"D2_TOTAL", 	"","Valor Mercadoria"     ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1])
trCell():New(oSection2,"DESCONTO",  "","Desconto(-)" 	   	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"ACRESCIMO", "","Acréscimo(+)"  		  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"GORJETA",	 "","Gorjeta(+)"  		  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT") 
trCell():New(oSection2,"D2_VALFRE", "","Valor Frete(+)"	   	  ,PesqPict("SD2","D2_VALFRE") 		,TamSx3("D2_VALFRE")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"VLRTOTAL",  "","Valor Total"  	   	  ,PesqPict("SD2","D2_TOTAL") 		,TamSx3("D2_TOTAL")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_BASEICM","","Base Icms"  	   	  ,PesqPict("SD2","D2_BASEICM") 	,TamSx3("D2_BASEICM")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_VALICM", "","Valor Icms"  	   	  ,PesqPict("SD2","D2_VALICM") 		,TamSx3("D2_VALICM")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_BASIMP6","","Base Pis"  	   	  	  ,PesqPict("SD2","D2_BASIMP6") 	,TamSx3("D2_BASIMP6")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_BASIMP5","","Base Cofins"  	   	  ,PesqPict("SD2","D2_BASIMP5") 	,TamSx3("D2_BASIMP5")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_VALIMP6", "","Valor Pis"  	   	  ,PesqPict("SD2","D2_VALIMP6") 	,TamSx3("D2_VALIMP6")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_VALIMP5", "","Valor Cofins"  	  ,PesqPict("SD2","D2_VALIMP5") 	,TamSx3("D2_VALIMP5")[1],,,"RIGHT",,"RIGHT") 
trCell():New(oSection2,"D2_VALIPI",  "","Valor IPI"  	   	  ,PesqPict("SD2","D2_VALIPI") 		,TamSx3("D2_VALIPI")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_VALISS",  "","Valor ISS"  	   	  ,PesqPict("SD2","D2_VALISS") 	    ,TamSx3("D2_VALISS")[1],,,"RIGHT",,"RIGHT")
trCell():New(oSection2,"D2_ICMSRET", "","Valor ICMS-ST"  	  ,PesqPict("SD2","D2_ICMSRET") 	,TamSx3("D2_ICMSRET")[1],,,"RIGHT",,"RIGHT") 

//	Totalizacao
oBreak1 := TRBreak():New(oSection2,	{|| .F.},	"Totais:",	.F.)
TRFunction():New(oSection2:Cell("D2_FILIAL"),,"COUNT",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_TOTAL"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("DESCONTO"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("ACRESCIMO"),,"SUM",oBreak1,,,,.F.,.F.) 
TRFunction():New(oSection2:Cell("GORJETA"),,"SUM",oBreak1,,,,.F.,.F.) 
TRFunction():New(oSection1:Cell("D2_VALFRE"),,"SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("VLRTOTAL"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_BASEICM"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_VALICM"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_BASIMP6"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_BASIMP5"),,"SUM",oBreak1,,,,.F.,.F.) 
TRFunction():New(oSection2:Cell("D2_VALIMP6"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_VALIMP5"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_VALIPI"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_VALISS"),,"SUM",oBreak1,,,,.F.,.F.)
TRFunction():New(oSection2:Cell("D2_ICMSRET"),,"SUM",oBreak1,,,,.F.,.F.)

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
Local oSection2	:= oRel:Section(2)
Local cAliasTemp:= GetNextAlias()
Local nAchou	:= 0
Local rs		:= 0
Local cStatus 	:= mv_par06
Local aNfes		:= {}
Local cMotivo	:= ''
Local cWhere	:= '%%'
Local cQuery 	:= ""
Local nVlrRet 	:= 0
Local nVlrRet1 	:= 0
Local cTipoInf  := ""
Local cDoc		:= ""
Local dData

//oRel:SetCustomText(FATR200C(oRel))

//Sintetico com Data
If mv_par05 == 1
	
	oSection1:BeginQuery()
	
	BeginSql  Alias cAliasTemp
		SELECT D2_FILIAL ,D2_EMISSAO, SUM(D2_TOTAL+D2_DESCON) AS TOTAL ,SUM(D2_DESCON) AS DESCONTO, SUM(D2_DESPESA)  AS ACRESCIMO,
		SUM(D2_VALBRUT) AS VLRTOTAL, SUM(D2_BASEICM) AS BASEICMS, SUM(D2_VALICM) AS VALORICMS,SUM(D2_BASIMP6) AS BASEPIS, SUM(D2_VALIMP6) AS VALORPIS,
		SUM(D2_BASIMP5) AS BASECOF,SUM(D2_VALIMP5) AS VALORCOF,SUM(D2_VALFRE) AS D2_VALFRE,SUM(D2_VALIPI) AS D2_VALIPI,SUM(D2_VALISS) AS D2_VALISS,
		SUM(D2_ICMSRET) AS D2_ICMSRET,
		(SELECT  SUM(D2_TOTAL) FROM %table:SD2% SD21
  		WHERE SD21.D2_COD = '20403921002300'//GORJETA 
  		AND SD21.D2_FILIAL  = SD2.D2_FILIAL
  		AND SD21.D2_EMISSAO = SD2.D2_EMISSAO 
  		AND SD21.D_E_L_E_T_ <> '*' ) AS GORJETA
		FROM %table:SD2% SD2 
	   //	JOIN %table:SF2% SF2 ON F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA 
	  //	AND SF2.D_E_L_E_T_ <> '*'   
		JOIN %table:SF4% SF4 ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S'  AND SF4.D_E_L_E_T_ <> '*' 
		WHERE D2_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND  D2_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	   	AND D2_COD <> '20403921002300'//GORJETA  
		AND D2_TIPO = 'N'//SOMENTE NF DE TIPO N=NORMAL
		AND SD2.%notDel%
		%Exp:cWhere%
		GROUP BY D2_FILIAL,D2_EMISSAO
		ORDER BY D2_FILIAL,D2_EMISSAO
	EndSql
	_cResQry:= GETLastQuery()[2]
	//Memowrite("c:\temp\_FATR200D.txt",_cResQry)
	oSection1:EndQuery()
	
	DbSelectArea(cAliasTemp)
	
	(cAliasTemp)->(DbGoTop())
	
	ProcRegua(Reccount())
	
	oRel:SetMeter((cAliasTemp)->(RecCount()))
	oSection1:Init()
	Do While (!(cAliasTemp)->(Eof()))
		
		If oRel:Cancel()
			Exit
		EndIf
		
		oSection1:Cell("D2_FILIAL"):SetValue((cAliasTemp)->D2_FILIAL)
		oSection1:Cell("ADK_NOME"):SetValue(FWFilialName (cEmpAnt,(cAliasTemp)->D2_FILIAL))
		oSection1:Cell("D2_EMISSAO"):SetValue((cAliasTemp)->D2_EMISSAO)
		oSection1:Cell("D2_TOTAL"):SetValue((cAliasTemp)->TOTAL)
		oSection1:Cell("DESCONTO"):SetValue((cAliasTemp)->DESCONTO)
		oSection1:Cell("ACRESCIMO"):SetValue((cAliasTemp)->ACRESCIMO) 
		oSection1:Cell("GORJETA"):SetValue((cAliasTemp)->GORJETA) 
		oSection1:Cell("D2_VALFRE"):SetValue((cAliasTemp)->D2_VALFRE)
		oSection1:Cell("VLRTOTAL"):SetValue((cAliasTemp)->VLRTOTAL+(cAliasTemp)->GORJETA) 
		oSection1:Cell("D2_BASEICM"):SetValue((cAliasTemp)->BASEICMS)
		oSection1:Cell("D2_VALICM"):SetValue((cAliasTemp)->VALORICMS)
		oSection1:Cell("D2_BASIMP6"):SetValue((cAliasTemp)->BASEPIS)
		oSection1:Cell("D2_BASIMP5"):SetValue((cAliasTemp)->BASECOF)  
		oSection1:Cell("D2_VALIMP6"):SetValue((cAliasTemp)->VALORPIS)
		oSection1:Cell("D2_VALIMP5"):SetValue((cAliasTemp)->VALORCOF)  
		oSection1:Cell("D2_VALIPI"):SetValue((cAliasTemp)->D2_VALIPI)
		oSection1:Cell("D2_VALISS"):SetValue((cAliasTemp)->D2_VALISS)
		oSection1:Cell("D2_ICMSRET"):SetValue((cAliasTemp)->D2_ICMSRET)
		oSection1:PrintLine()
		(cAliasTemp)->(dbSkip())
	Enddo
	oSection1:Finish()
	//Sintético sem Data
Else
	
	oSection2:BeginQuery()
	
	BeginSql  Alias cAliasTemp
		SELECT D2_FILIAL ,SUM(D2_TOTAL+D2_DESCON) AS TOTAL ,SUM(D2_DESCON) AS DESCONTO, SUM(D2_DESPESA)  AS ACRESCIMO,
		SUM(D2_VALBRUT) AS VLRTOTAL,SUM(D2_BASEICM) AS BASEICMS, SUM(D2_VALICM) AS VALORICMS,SUM(D2_BASIMP6) AS BASEPIS, SUM(D2_VALIMP6) AS VALORPIS,
		SUM(D2_BASIMP5) AS BASECOF,SUM(D2_VALIMP5) AS VALORCOF,SUM(D2_VALFRE) AS D2_VALFRE,SUM(D2_VALIPI) AS D2_VALIPI,SUM(D2_VALISS) AS D2_VALISS,
		SUM(D2_ICMSRET) AS D2_ICMSRET,
		(SELECT  SUM(D2_TOTAL)  FROM %table:SD2% SD21
  		WHERE SD21.D2_COD = '20403921002300'//GORJETA 
  		AND SD21.D2_FILIAL = SD2.D2_FILIAL
  		AND SD21.D2_EMISSAO BETWEEN  %Exp:mv_par03% AND %Exp:mv_par04%
  		AND SD21.D_E_L_E_T_ <> '*' ) AS GORJETA
		FROM %table:SD2% SD2 
	   //	JOIN %table:SF2% SF2 ON F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND SF2.D_E_L_E_T_ <> '*'
		JOIN %table:SF4% SF4 ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S'  AND SF4.D_E_L_E_T_ <> '*' 
		WHERE D2_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		AND  D2_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% 
	   	AND D2_COD <> '20403921002300'//GORJETA
		AND D2_TIPO = 'N'//SOMENTE NF DE TIPO N=NORMAL
		AND SD2.%notDel%
		%Exp:cWhere%
		GROUP BY D2_FILIAL'
		ORDER BY D2_FILIAL
	EndSql
	
	_cResQry:= GETLastQuery()[2]
	//Memowrite("c:\temp\_FATR200.txt",_cResQry)
	
	oSection1:EndQuery()
	
	DbSelectArea(cAliasTemp)
	
	(cAliasTemp)->(DbGoTop())
	
	ProcRegua(Reccount())
	
	oRel:SetMeter((cAliasTemp)->(RecCount()))
	oSection2:Init()
	Do While (!(cAliasTemp)->(Eof()))
		
		If oRel:Cancel()
			Exit
		EndIf
		
		oSection2:Cell("D2_FILIAL"):SetValue((cAliasTemp)->D2_FILIAL)
		oSection2:Cell("ADK_NOME"):SetValue(FWFilialName (cEmpAnt,(cAliasTemp)->D2_FILIAL))
		oSection2:Cell("D2_TOTAL"):SetValue((cAliasTemp)->TOTAL)
		oSection2:Cell("DESCONTO"):SetValue((cAliasTemp)->DESCONTO)
		oSection2:Cell("ACRESCIMO"):SetValue((cAliasTemp)->ACRESCIMO)
		oSection2:Cell("GORJETA"):SetValue((cAliasTemp)->GORJETA) 
		oSection2:Cell("D2_VALFRE"):SetValue((cAliasTemp)->D2_VALFRE)
		oSection2:Cell("VLRTOTAL"):SetValue((cAliasTemp)->VLRTOTAL+(cAliasTemp)->GORJETA) 
		oSection2:Cell("D2_BASEICM"):SetValue((cAliasTemp)->BASEICMS)
		oSection2:Cell("D2_VALICM"):SetValue((cAliasTemp)->VALORICMS)
		oSection2:Cell("D2_BASIMP6"):SetValue((cAliasTemp)->BASEPIS)
		oSection2:Cell("D2_BASIMP5"):SetValue((cAliasTemp)->BASECOF) 
		oSection2:Cell("D2_VALIMP6"):SetValue((cAliasTemp)->VALORPIS)
		oSection2:Cell("D2_VALIMP5"):SetValue((cAliasTemp)->VALORCOF)
		oSection2:Cell("D2_VALIPI"):SetValue((cAliasTemp)->D2_VALIPI)
		oSection2:Cell("D2_VALISS"):SetValue((cAliasTemp)->D2_VALISS)
		oSection2:Cell("D2_ICMSRET"):SetValue((cAliasTemp)->D2_ICMSRET)
		oSection2:PrintLine()
		
		(cAliasTemp)->(dbSkip())
	Enddo
	
	oSection2:Finish()
	oRel:SetTotalInLine(.F.)
EndIf
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
U_XPutSX1(cPerg, "03", "Data De?",  		    "MV_PAR03", "MV_CH2", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
U_XPutSX1(cPerg, "04", "Data Até?",  			"MV_PAR04", "MV_CH3", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data final a ser considerada")
U_XPutSX1(cPerg, "05", "Com Data?"		,    	"MV_PAR05", "MV_CH5", "N", 01,  0, "C", cValid,       cF3,   cPicture,         "Sim",   "Não",         cDef03,       cDef04,    cDef05, "Informe Sim / Não para Data")
Return Nil
