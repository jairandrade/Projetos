#include 'protheus.ch'
#include 'parmtype.ch'

//----------------------------------------------------------------------	
/*/{Protheus.doc} RMNT001
Relatório de Manutenções Preditivas

@author	Thiago Henrique dos Santos
@since	27/06/2016
@version P11

@return NIL	

/*/
//----------------------------------------------------------------------
User Function RMNT001()
Local oReport
Local cPerg := "RMNT001"

AjustaSX1(cPerg)

If !Pergunte(cPerg)
	
	Return
	
Endif

oReport := ReportDef()
oReport:PrintDialog()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Constrói o objeto instância da Classe TReport

@author Thiago Henrique dos Santos
@since 27/06/2016
@version P11
@return oReport  - Objeto instância da classe TReport
/*/
//---------------------------------------------------------------------

Static Function ReportDef(cPerg)
Local oReport
Local oSecCab   //secao de cabecalho
Local oSecLocal //secao de faturamento local



oReport := TReport():New("RMNT001","Relatório de Preditivas",cPERG,{|oReport| ReportPrint(oReport)},;
						"O relatório apresentará os resultados das manutenções preditivas")
//oReport:HideHeader()
//oReport:HideParamPage()
//oReport:SetLandScape()
						
oSecCab:= TRSection():New(oReport,"Bem",{"ST9"},/*aOrdem*/)
oSecCab:SetLineStyle()

TRCell():New(oSecCab,"T9_CODBEM",,"Bem" ,X3Picture("T9_CODBEM"),TamSx3("T9_CODBEM")[1],/*lPixel*/)
TRCell():New(oSecCab,"T9_NOME",,"Nome" ,X3Picture("T9_NOME"),TamSx3("T9_NOME")[1],/*lPixel*/)


oSecItens:= TRSection():New(oSecCab,"Faturamento Local",{"STJ","TPQ","TPC"},/*aOrdem*/)

oSecItens:SetHeaderBreak(.T.)
oSecItens:SetHeaderPage(.F.)

TRCell():New(oSecItens,"TPQ_ETAPA",,"Etapa" ,X3Picture("TPQ_ETAPA"),TamSx3("TPQ_ETAPA")[1],/*lPixel*/)
TRCell():New(oSecItens,"TPA_DESCRI",,"Descrição" ,X3Picture("TPA_DESCRI"),60,/*lPixel*/)
TRCell():New(oSecItens,"TJ_SERVICO",,"Serviço" ,X3Picture("TJ_SERVICO"),TamSx3("TJ_SERVICO")[1],/*lPixel*/)
TRCell():New(oSecItens,"TJ_ORDEM",,"O.S." ,X3Picture("TJ_ORDEM"),TamSx3("TJ_ORDEM")[1],/*lPixel*/)
TRCell():New(oSecItens,"TJ_DTMRINI",,"Data" ,X3Picture("TJ_DTMRINI"),TamSx3("TJ_DTMRINI")[1]+5,/*lPixel*/)
TRCell():New(oSecItens,"TPQ_OPCAO",,"Opção" ,X3Picture("TPQ_OPCAO"),TamSx3("TPQ_OPCAO")[1],/*lPixel*/)
TRCell():New(oSecItens,"TPQ_RESPOS",,"Resposta" ,X3Picture("E1_VALOR"),TamSx3("TPQ_RESPOS")[1],/*lPixel*/)
TRCell():New(oSecItens,"TPC_CONDOP",,"Operador" ,X3Picture("TPC_CONDOP"),TamSx3("TPC_CONDOP")[1],/*lPixel*/)
TRCell():New(oSecItens,"TPC_CONDIN",,"Limite" ,X3Picture("E1_VALOR"),TamSx3("TPC_CONDIN")[1],/*lPixel*/)
TRCell():New(oSecItens,"STATUS",,"Status" ,"",6,/*lPixel*/)
TRCell():New(oSecItens,"TPQ_ORDEMG",,"OS Gerada" ,X3Picture("TPQ_ORDEMG"),TamSx3("TPQ_ORDEMG")[1],/*lPixel*/)
TRCell():New(oSecItens,"T1_CODFUNC",,"Executante" ,X3Picture("T1_CODFUNC"),TamSx3("T1_CODFUNC")[1],/*lPixel*/)
TRCell():New(oSecItens,"T1_NOME",,"Nome" ,X3Picture("T1_NOME"),TamSx3("T1_NOME")[1],/*lPixel*/)
TRCell():New(oSecItens,"TPQ_OBSERV",,"Observação" ,X3Picture("TPQ_OBSERV"),TamSx3("TPQ_OBSERV")[1],/*lPixel*/)
	
Return oReport


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
Função para impressão do relatório
 
@param		oReport Objeto com as definições do tReport
@author		Thiago Henrique dos Santos
@since		25/11/2014
@version	P11
/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSecCab := oReport:Section(1)
Local oSecItens := oReport:Section(1):Section(1)
Local cAlias	:= GetNextAlias()
Local cCodBem := ""
Local cEtapa := ""
Local cCond := ""
LocaL cExp := ""
Local cStatus := ""

ExecQuery(cAlias)

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())
oReport:SetMeter((cAlias)->(LastRec()))

While (cAlias)->(!Eof())
	oReport:IncMeter()
	
	cCond := StrTran((cAlias)->TPC_CONDOP,"I","=")
	cStatus := calcStatus(cCond,(cAlias)->TPC_CONDIN,(cAlias)->TPQ_RESPOS)
	
	If MV_PAR11 == 1 .OR. MV_PAR11 == 2 .AND. cStatus == "OK" .OR. MV_PAR11 == 3 .AND. cStatus == "NÃO OK" .OR. MV_PAR11 == 4 .AND. cStatus == "N/A"

		If (cAlias)->T9_CODBEM <> cCodBem
	
			If !Empty(cCodBem)		
				oSecItens:Finish()
				oSecCab:Finish()
				oReport:FatLine()
				oReport:SkipLine()
				oReport:SkipLine()			
				cEtapa := ""		
			Endif
		
			cCodBem := (cAlias)->T9_CODBEM 
		
			oSecCab:Init()
			oSecCab:Cell("T9_CODBEM"):SetValue((cAlias)->T9_CODBEM)
			oSecCab:Cell("T9_NOME"):SetValue((cAlias)->T9_NOME)
			oSecCab:PrintLine()
			oSecItens:Init()
		Endif
	
		oSecItens:Cell("TPQ_ETAPA"):SetValue((cAlias)->TPQ_ETAPA)
		oSecItens:Cell("TPA_DESCRI"):SetValue(Alltrim((cAlias)->TPA_DESCRI))
		oSecItens:Cell("TJ_SERVICO"):SetValue((cAlias)->TJ_SERVICO)
		oSecItens:Cell("TJ_ORDEM"):SetValue((cAlias)->TJ_ORDEM)
		oSecItens:Cell("TJ_DTMRINI"):SetValue(StoD((cAlias)->TJ_DTMRINI))
		oSecItens:Cell("TPQ_OPCAO"):SetValue(Alltrim((cAlias)->TPQ_OPCAO))
		oSecItens:Cell("TPC_CONDOP"):SetValue(cCond)
		nValue := Val(StrTran((cAlias)->TPC_CONDIN,",","."))
		oSecItens:Cell("TPC_CONDIN"):SetValue(nValue)
		nValue2 := Val(StrTran((cAlias)->TPQ_RESPOS,",","."))
		oSecItens:Cell("TPQ_RESPOS"):SetValue(nValue2)
		oSecItens:Cell("STATUS"):SetValue(cStatus)
		oSecItens:Cell("TPQ_ORDEMG"):SetValue((cAlias)->TPQ_ORDEMG)	
		oSecItens:Cell("T1_CODFUNC"):SetValue((cAlias)->T1_CODFUNC)
		oSecItens:Cell("T1_NOME"):SetValue((cAlias)->T1_NOME)
		oSecItens:Cell("TPQ_OBSERV"):SetValue((cAlias)->TPQ_OBSERV)	
		oSecItens:PrintLine()	
		
	Endif
	(cAlias)->(DbSkip())
	
Enddo

oSecItens:Finish()
oSecCab:Finish()
(cAlias)->(DbCloseArea())

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery()
Função que cria o Alias temporário 
 
@param		cCond - Condicao Logica
@param		cLimite - Limite Cadastrado
@param 		cResposta - Resposta do usuário		 
 
@author		Thiago Henrique dos Santos
@since		27/06/2016
@version	P11

@return 	cRet - OK, NAO OK, N/A
/*/
//------------------------------------------------------------------------------------------
Static Function calcStatus(cCond,cLimite,cResposta)
Local cRet := "N/A"

cLimite := StrTran(cLimite,",",".")
cLimite := StrTran(cLimite,".","",2)
cResposta := StrTran(cResposta,",",".")
cResposta := StrTran(cResposta,".","",2)

If !Empty(cCond) .AND. !Empty(cLimite) .AND. !Empty(cResposta)

	If val(cResposta) <> 0
	
		cRet := If (&(cLimite+cCond+cResposta),"OK","NÃO OK")
	
	Endif

Endif


return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery()
Função que cria o Alias temporário 
 
@param		cAlias - Alias temporário a ser criado		 
 
@author		Thiago Henrique dos Santos
@since		27/06/2016
@version	P11
/*/
//------------------------------------------------------------------------------------------
Static Function ExecQuery(cAlias)
Local cDataIni := DtoS(MV_PAR01)
Local cDataFim := DtoS(MV_PAR02)

BeginSql Alias cAlias

	SELECT T9_NOME, T9_CODBEM, TPQ_ETAPA, TPA_DESCRI, TJ_SERVICO, TJ_ORDEM, TJ_DTMRINI, TPQ_OPCAO,
			TPC_CONDOP, TPC_CONDIN, TPQ_RESPOS, TPQ_ORDEMG, T1_CODFUNC, T1_NOME, TPQ_OBSERV
	FROM %table:TPQ% TPQ
	INNER JOIN %table:STJ% STJ
		ON TJ_FILIAL = %xFilial:STJ% AND
			TJ_ORDEM = TPQ_ORDEM AND
			TJ_PLANO = TPQ_PLANO AND
			TJ_DTMRINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim% AND
			TJ_CODBEM BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
			TJ_SERVICO BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10% AND
			STJ.%NotDel%
	INNER JOIN %table:ST9% ST9
		ON T9_FILIAL = %xFilial:ST9% AND
			T9_CODBEM = TJ_CODBEM AND
			ST9.%NotDel%			
	INNER JOIN %table:TPA% TPA
		ON TPA_FILIAL = %xFilial:TPA% AND
			TPA_ETAPA = TPQ_ETAPA AND
			TPA.%NotDel%
	INNER JOIN %table:TPC% TPC
		ON TPC_FILIAL = %xFilial:TPC% AND
			TPC_ETAPA = TPQ_ETAPA AND
			TPC_OPCAO = TPQ_OPCAO AND
			TPC.%NotDel%
	LEFT JOIN  %table:STQ% STQ
		ON	TQ_FILIAL = %xFilial:STQ% AND
			TQ_PLANO = TPQ_PLANO AND
			TQ_ORDEM = TPQ_ORDEM AND
			TQ_ETAPA = TPQ_ETAPA AND
			TQ_TAREFA = TPQ_TAREFA AND
			STQ.%NotDel% 
	LEFT JOIN %table:ST1% ST1
		ON	T1_FILIAL = %xFilial:ST1% AND
			T1_CODFUNC = TQ_CODFUNC AND
			ST1.%NotDel%
			
	WHERE TPQ_FILIAL = %xFilial:TPQ% AND
		TPQ_ETAPA BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
		TJ_ORDEM BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08% AND
		TPQ.%NotDel%
		
	ORDER BY T9_CODBEM ASC, TPQ_ETAPA ASC
	


EndSql

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria a pergunta SX1 do programa
	
@author Thiago Henrique dos Santos
@since 27/06/2016
@version P11	
@param cPerg - Código da Pergunta	

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1(cPerg)

	Local aHelpPerg  := {}
	
	aAdd(aHelpPerg,{"Informe a data inicial."})
	aAdd(aHelpPerg,{"Informe a data final."})
	aAdd(aHelpPerg,{"Informe o bem inicial."})
	aAdd(aHelpPerg,{"Informe o bem final."})
	aAdd(aHelpPerg,{"Informe a etapa inicial."})
	aAdd(aHelpPerg,{"Informe a etapa final."})
	aAdd(aHelpPerg,{"Informe a Ordem de Serviço inicial."})
	aAdd(aHelpPerg,{"Informe a Ordem de Serviço final."})
	aAdd(aHelpPerg,{"Informe o serviço inicial."})
	aAdd(aHelpPerg,{"Informe o serviço final."})
	aAdd(aHelpPerg,{"Informe o status da resposta."})
	
	//PutSX1(cPerg,"01","De Data?"      	  ,"" ,"" ,"MV_CH1" ,"D",8,0,0,"G","","" ,"" ,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	//PutSX1(cPerg,"02","Até Data?"      	  ,"" ,"" ,"MV_CH2" ,"D",8,0,0,"G","","" ,"" ,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
	//PutSX1(cPerg,"03","De Bem?"      	  ,"" ,"" ,"MV_CH3" ,"C",TamSx3("T9_CODBEM")[1],0,0,"G","","ST9" ,"" ,"S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	//PutSX1(cPerg,"04","Até Bem?"      	  ,"" ,"" ,"MV_CH4" ,"C",TamSx3("T9_CODBEM")[1],0,0,"G","","ST9" ,"" ,"S","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})
	//PutSX1(cPerg,"05","De Etapa?"      	  ,"" ,"" ,"MV_CH5" ,"C",TamSx3("TPA_ETAPA")[1],0,0,"G","","TPA" ,"" ,"S","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPerg[5] ,{},{})
	//PutSX1(cPerg,"06","Até Etapa?"        ,"" ,"" ,"MV_CH6" ,"C",TamSx3("TPA_ETAPA")[1],0,0,"G","","TPA" ,"" ,"S","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})
	//PutSX1(cPerg,"07","De OS?"      	  ,"" ,"" ,"MV_CH7" ,"C",TamSx3("TJ_ORDEM")[1],0,0,"G","","STJ" ,"" ,"S","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPerg[7] ,{},{})
	//PutSX1(cPerg,"08","Até OS?"      	  ,"" ,"" ,"MV_CH8" ,"C",TamSx3("TJ_ORDEM")[1],0,0,"G","","STJ" ,"" ,"S","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPerg[8] ,{},{})
	//PutSX1(cPerg,"09","De Serviço?"    	  ,"" ,"" ,"MV_CH9" ,"C",TamSx3("T4_SERVICO")[1],0,0,"G","","ST4" ,"" ,"S","MV_PAR09","","","","","","","","","","","","","","","","",aHelpPerg[9] ,{},{})
	//PutSX1(cPerg,"10","Até Serviço?"      ,"" ,"" ,"MV_CHA" ,"C",TamSx3("T4_SERVICO")[1],0,0,"G","","ST4" ,"" ,"S","MV_PAR10","","","","","","","","","","","","","","","","",aHelpPerg[10] ,{},{})
	//PutSx1(cPerg,"11","Status?" 		  ,"",""  ,"MV_CHB" ,"N",01					    ,0,1,"C","",""    ,"" ,"" ,"MV_PAR11","Todos",;
//		"","","","OK"   ,"","","Não OK","","","N/A","","","","","",aHelpPerg[11] ,{},{})
	
	
	
Return  