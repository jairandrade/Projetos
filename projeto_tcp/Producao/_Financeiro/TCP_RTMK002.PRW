//-------------------------------------------------------------------
/*/{Protheus.doc} RTMK001
Relatório de análise de telecobranças      

A TABELA Z17 É ALIMENTADA VIA TRIGGER, COM NOME ATUALIZA_Z17

@author Felipe Toazza CAldeira
@since 12/11/2015
@version P11
/*/
//-------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"                                                                      
#INCLUDE "topconn.ch"
                 
User Function RTMK002()                      
cPerg := 'RTMK002'             

AjustaSX1(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte(cPerg,.T.) 
 	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Configura o objeto TReport. 

@sample	ReportDef() 

@author Felipe Toazza Caldeira
@since	12/11/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------   
Static Function ReportDef() 

Local cTituRel	:= "Relatório Geral de Atendimento por Operador"
Local cDescRel 	:= "Este programa ira emitir o relatório "+cTituRel
Local aOrdem   	:= {} 
Local oReport  
Local oSection1
Local oSection11
Local oSection2
Local oSection3
Local oSection4
Local oBreak1
Local oBreak2

oReport := TReport():New(cPerg,cTituRel,cPerg, {|oReport| ReportPrint(oReport)},cDescRel)   

oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 
oReport:HideParamPage()
oReport:DisableOrientation()
 
oSection1 := TRSection():New(oReport,"Mês Referencia: "+STRZERO(MV_PAR05,2)+"/"+Alltrim(Str(MV_PAR06))+Space(20)+"Periodo da seleção: "+DtoC(MV_PAR01)+" - "+DtoC(MV_PAR02),{}) 
TRCell():new(oSection1,"OPERADOR"		,"QRY1"		,"Operador"		,"@!"						,15)
TRCell():new(oSection1,"NOME"			,"QRY1"		,"Nome"	   		,"@!"						,40)
 
oSection11 := TRSection():New(oSection1,"Atendimentos",{})          
TRCell():New(oSection11, "Z18_DATA"		, "QRY1","Data",					"@!",	10)			
TRCell():New(oSection11, "Z18_HORA"		, "QRY1","Hora",					"@!",	5)				
TRCell():New(oSection11, "Z18_CODIGO"	, "QRY1","N° Atend.",				"@!",	TAMSX3("Z18_CODIGO")[1] )
TRCell():New(oSection11, "Z18_FILIAL"	, "QRY1","Filial",					"@!",	TAMSX3("Z18_FILIAL")[1]+2)
TRCell():New(oSection11, "A1_NOME"		, "QRY1","Nome Cliente",			"@!",	TAMSX3("A1_NOME")[1]-10)
TRCell():New(oSection11, "U5_CONTAT"	, "QRY1","Contato",					"@!",	20)
TRCell():New(oSection11, "Z18_TIPOOP"	, "QRY1","Tipo Lig.",				"@!",	14)//004,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection11, "AGEND"		, "QRY1","Agendado",				"@!",	7)//004,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection11, "Z18_OBS"		, "QRY1","Descição Atendimento",	"@!",	140)
oSection11:SetLeftMargin(5)
oSection11:SetHeaderBreak(.T.)  


oSection2 := TRSection():New(oReport,"Resumo Dia",{}) 
         
TRCell():New(oSection2, "Z18_DATA"		, "QRY2","Data",					"@!",						10)			
TRCell():New(oSection2, "U7_NOME"		, "QRY2","Operador",				"@!",						40)
TRCell():New(oSection2, "TOTAL_LIG"		, "QRY2","Tot. Ligaçoes",			"@E 999",					5,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection2, "VALOR_LIG"		, "QRY2","Tot. R$ Negociado",		"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection2, "TOTAL_ATIV"	, "QRY2","Lig. Ativa",				"@E 99",					5,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection2, "VALOR_ATIV"	, "QRY2","Valor R$ Ativa",			"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT")//004,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection2, "TOTAL_RECP"	, "QRY2","Lig. Recpetivo",			"@E 99",					5,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection2, "VALOR_RECEP"	, "QRY2","Valor R$ Receptivo",		"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT") //004,,,"RIGHT",,"RIGHT") 
oSection2:Cell("TOTAL_LIG"):nHeaderAlign := 3
oSection2:Cell("VALOR_LIG"):nHeaderAlign := 3 
oSection2:Cell("TOTAL_ATIV"):nHeaderAlign := 3 
oSection2:Cell("VALOR_ATIV"):nHeaderAlign := 3
oSection2:Cell("TOTAL_RECP"):nHeaderAlign := 3 
oSection2:Cell("VALOR_RECEP"):nHeaderAlign := 3 

     
oSection3 := TRSection():New(oReport,"Resumo Mes",{}) 
         
TRCell():New(oSection3, "MES_ANO"		, "QRY3","Mes/Ano",					"@!",						10)			
TRCell():New(oSection3, "U7_NOME"		, "QRY3","Operador",				"@!",						40)
TRCell():New(oSection3, "TOTAL_LIG"		, "QRY3","Tot. Ligaçoes",			"@E 9999",					6,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection3, "VALOR_LIG"		, "QRY3","Tot. R$ Negociado",		"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection3, "TOTAL_ATIV"	, "QRY3","Lig. Ativa",				"@E 9999",					6,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection3, "VALOR_ATIV"	, "QRY3","Valor R$ Ativa",			"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT")//004,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection3, "TOTAL_RECP"	, "QRY3","Lig. Recpetivo",			"@E 9999",					6,,,"RIGHT",,"RIGHT") 
TRCell():New(oSection3, "VALOR_RECEP"	, "QRY3","Valor R$ Receptivo",		"@@E 9,999,999,999,999.99",	22,,,"RIGHT",,"RIGHT") //004,,,"RIGHT",,"RIGHT") 
oSection3:Cell("TOTAL_LIG"):nHeaderAlign := 3
oSection3:Cell("VALOR_LIG"):nHeaderAlign := 3 
oSection3:Cell("TOTAL_ATIV"):nHeaderAlign := 3 
oSection3:Cell("VALOR_ATIV"):nHeaderAlign := 3
oSection3:Cell("TOTAL_RECP"):nHeaderAlign := 3 
oSection3:Cell("VALOR_RECEP"):nHeaderAlign := 3 


Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de impressão do relatório.

@sample	ReportPrint(oReport)

@param	oReport - Objeto do tReport para impressão

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function ReportPrint(oReport)
    
    Local cTextPrt	 := ""                                                                            
	Local nTotTit	 := 0
	Local nValPerc	 := 0
	Local oSection1  := oReport:Section(1)				// Define a secao 1 do relatorio
	Local oSection11 := oReport:Section(1):Section(1)
	Local oSection2  := oReport:Section(2)				// Define a secao 2 do relatorio 
	Local oSection3  := oReport:Section(3)				// Define a secao 3 do relatorio 
    Local nValTot	 := 0   
    Local cOperador  := ""
              
    fMontaQry( )
    
    oReport:SetMeter(0)
            
    oReport:SetTitle( oReport:Title() )     
      
   	DbSelectArea("QRY1")
   
	QRY1->(DbGoTop()) 


	While !oReport:Cancel() .AND. !QRY1->(Eof())
			
		oReport:IncMeter() 
			
		If oReport:Cancel()
			Exit
		EndIf  

		IF Alltrim(QRY1->Z18_OPERAD) != cOperador
			If cOperador != ''
				oSection11:Finish()
				oSection1:Finish()
				oReport:SkipLine()
			Else
				oReport:PrintText(oSection1:cTitle)
			EndIf 

			cOperador := QRY1->Z18_OPERAD
		  	
			oSection1:Init()

			oSection1:Cell("OPERADOR"):SetValue(cOperador)
			oSection1:Cell("NOME"):SetValue(Posicione('SU7',1,xFilial('SU7')+cOperador,"U7_NOME"))			 
			oSection1:PrintLine()
			
			oSection11:Init()
	
		
		EndIf
							    	    	 

		oSection11:Cell("Z18_DATA"):SetValue(QRY1->Z18_DATA)
		oSection11:Cell("Z18_HORA"):SetValue(QRY1->Z18_HORA)			 
		oSection11:Cell("Z18_CODIGO"):SetValue(QRY1->Z18_CODIGO)  
		oSection11:Cell("Z18_FILIAL"):SetValue(QRY1->Z18_FILIAL)
		oSection11:Cell("A1_NOME"):SetValue(QRY1->A1_NOME)
		oSection11:Cell("U5_CONTAT"):SetValue(QRY1->U5_CONTAT)			 

		If QRY1->Z18_TIPOOP == '1'
			cDescTp := 'Receptivo'
		ElseIf QRY1->Z18_TIPOOP == '2'  
			cDescTp := 'Ativo'
		Else
			If Posicione('ACF',1,QRY1->Z18_FILIAL+QRY1->Z18_CODIGO,"ACF_OPERA") == '1'
		    	cDescTp := 'Receptivo'
		 	Else
		 		cDescTp := 'Ativo'
		 	EndIf
		EndIf
		oSection11:Cell("Z18_TIPOOP"):SetValue(cDescTp)  
		
		cAgenda := ""
		If !Empty(Alltrim(QRY1->Z17_ATEND))
			cAgenda := 'AGENDADO'
		EndIf 
		oSection11:Cell("AGEND"):SetValue(cAgenda)
		oSection11:Cell("Z18_OBS"):SetValue(QRY1->Z18_OBS)
				     			
		oSection11:PrintLine()
				
  		QRY1->(DbSkip())
				
	EndDo 
	QRY1->(DbCloseArea())		
	oSection1:Finish() 
	oReport:SkipLine(4)

   	DbSelectArea("QRY2")
   
	QRY2->(DbGoTop()) 

	oReport:PrintText(oSection2:cTitle)
	oReport:SkipLine()

	oSection2:Init()
	
	While !oReport:Cancel() .AND. !QRY2->(Eof())
			
		oReport:IncMeter() 
			
		If oReport:Cancel()
			Exit
		EndIf                     
		
		//******************************************************************
		//Busca na query os valores duplicados e retira a quantidade 
		//***************************************************************                                                                         
		nValDuplTP1 := 0
		nValDuplTP2 := 0		
		DbSelectArea('QRY22')
		QRY22->(DbGoTop())
		While !QRY22->(EOF()) 
			IF QRY22->Z18_DATA == QRY2->Z18_DATA .AND. QRY22->U7_NOME == QRY2->U7_NOME		     
				nValDupl1 := QRY22->VAL_TIPO1DUPL
				nValDupl2 := QRY22->VAL_TIPO2DUPL				     
				Exit
			EndIf
		 	QRY22->(DbSkip())		
		EndDO                                                                                           
		
		oSection2:Cell("Z18_DATA"):SetValue(QRY2->Z18_DATA)
		oSection2:Cell("U7_NOME"):SetValue(QRY2->U7_NOME)			 
		oSection2:Cell("TOTAL_LIG"):SetValue(QRY2->TOT_TIPO1+QRY2->TOT_TIPO2)  
		oSection2:Cell("VALOR_LIG"):SetValue(QRY2->VAL_TIPO1+QRY2->VAL_TIPO2-nValDupl2-nValDupl1)
		oSection2:Cell("TOTAL_ATIV"):SetValue(QRY2->TOT_TIPO2)
		oSection2:Cell("VALOR_ATIV"):SetValue(QRY2->VAL_TIPO2-nValDupl2)			 
		oSection2:Cell("TOTAL_RECP"):SetValue(QRY2->TOT_TIPO1)
		oSection2:Cell("VALOR_RECEP"):SetValue(QRY2->VAL_TIPO1-nValDupl1)			 

		oSection2:PrintLine()
				
  		QRY2->(DbSkip())
				
	EndDo 
	QRY2->(DbCloseArea())		
	oSection2:Finish() 
	oReport:SkipLine(4)


   	DbSelectArea("QRY3")
   
	QRY3->(DbGoTop()) 

	oReport:PrintText(oSection3:cTitle)
	oReport:SkipLine()

	oSection3:Init()
	
	While !oReport:Cancel() .AND. !QRY3->(Eof())
			
		oReport:IncMeter() 
			
		If oReport:Cancel()
			Exit
		EndIf  


		//******************************************************************
		//Busca na query os valores duplicados e retira a quantidade 
		//***************************************************************                                                                         
		nValDuplTP1 := 0
		nValDuplTP2 := 0		
		DbSelectArea('QRY32')
		QRY32->(DbGoTop())
		While !QRY32->(EOF()) 
			IF QRY32->MES_ANO == QRY3->MES_ANO .AND. QRY32->U7_NOME == QRY3->U7_NOME		     
				nValDupl1 := QRY32->VAL_TIPO1DUPL
				nValDupl2 := QRY32->VAL_TIPO2DUPL				     
				Exit
			EndIf
		 	QRY32->(DbSkip())		
		EndDO                                                                                           
		
		oSection3:Cell("MES_ANO"):SetValue(QRY3->MES_ANO)
		oSection3:Cell("U7_NOME"):SetValue(QRY3->U7_NOME)			 
		oSection3:Cell("TOTAL_LIG"):SetValue(QRY3->TOT_TIPO1+QRY3->TOT_TIPO2)  
		oSection3:Cell("VALOR_LIG"):SetValue(QRY3->VAL_TIPO1+QRY3->VAL_TIPO2-nValDupl2-nValDupl1)
		oSection3:Cell("TOTAL_ATIV"):SetValue(QRY3->TOT_TIPO2)
		oSection3:Cell("VALOR_ATIV"):SetValue(QRY3->VAL_TIPO2-nValDupl2)			 
		oSection3:Cell("TOTAL_RECP"):SetValue(QRY3->TOT_TIPO1)
		oSection3:Cell("VALOR_RECEP"):SetValue(QRY3->VAL_TIPO1-nValDupl1)			 

		oSection3:PrintLine()
				
  		QRY3->(DbSkip())
				
	EndDo 
	QRY3->(DbCloseArea())		
	oSection3:Finish() 
	oReport:SkipLine(4)
						
Return        

        
//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaQry
Montagem das Querys  

@param	
		
@author	Felipe Toazza Caldeira
@since	12/11/2015
@return	NIL
/*/
//-------------------------------------------------------------------
Static Function fMontaQry(  )  

	Local cQuery 
	 
	oReport:IncMeter(1)
	
	//***********************************************************************************
	//atendimentos -Detalhes
	//***********************************************************************************	
	cQuery := " SELECT * FROM ( "
	cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
	cQuery += " 	   Z18_HORA, Z18_FILIAL, Z18_CODIGO, A1_NOME, U5_CONTAT, Z18_TIPOOP, Z18_OBS, Z18_OPERAD, Z17_ATEND  " 	 
	cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " AS SA1 "
    cQuery += " ON SA1.A1_FILIAL  = '"+xFilial('SA1')+"'  	AND "
    cQuery += "    SA1.A1_COD  = Z18.Z18_CLIENT    			AND "
    cQuery += "    SA1.A1_LOJA = Z18.Z18_LOJA 				AND " 
    cQuery += "    SA1.D_E_L_E_T_ != '*' "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("SU5") + " AS SU5 "
    cQuery += " ON SU5.U5_FILIAL  = '"+xFilial('SU5')+"'  	AND "
    cQuery += "    SU5.U5_CODCONT  = Z18.Z18_CODCON    		AND "
    cQuery += "    SU5.D_E_L_E_T_ != '*' "		 
	cQuery += " LEFT OUTER JOIN " + RetSqlName("Z17") + " AS Z17 "
    cQuery += " ON Z17.Z17_FILIAL  =  SUBSTRING(Z18_FILIAL,1,4)+'  '  	AND "
    cQuery += "    Z17.Z17_ATEND   =  Z18.Z18_CODIGO    					AND "
    cQuery += "    Z17.Z17_OPER    =  Z18.Z18_OPERAD    					AND "    
    cQuery += "    Z17.Z17_DATA    =  Z18.Z18_DATA    					AND "    
    cQuery += "    Z17.D_E_L_E_T_  != '*' "		 
	cQuery += " WHERE
    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' "
    cQuery += " AND Z18.D_E_L_E_T_ != '*' "
    	 
    cQuery += " UNION ( "
    
		cQuery += " SELECT SUBSTRING(Z17_DATA,7,2)+'/'+SUBSTRING(Z17_DATA,5,2)+'/'+SUBSTRING(Z17_DATA,1,4) AS Z17_DATA, "
		cQuery += " 	   '', Z17_FILIAL, Z17_ATEND, '', '', '', '**** CONTATO NÃO EFETIVADO', Z17_OPER, Z17_ATEND  " 	 
		cQuery += " FROM "+RETSQLNAME("Z17")+" AS Z17 "
		cQuery += " WHERE
	    cQuery += "     Z17.Z17_FILIAL >= '"+Substr(MV_PAR13,1,4)+"  ' AND Z17.Z17_FILIAL <= '"+Substr(MV_PAR14,1,4)+"  ' "
	    cQuery += " AND Z17.Z17_ATEND >= '"+MV_PAR07+"' AND Z17.Z17_ATEND <= '"+MV_PAR08+"' "
	    cQuery += " AND Z17.Z17_OPER >= '"+MV_PAR03+"' AND Z17.Z17_OPER <= '"+MV_PAR04+"' "
	    cQuery += " AND Z17.Z17_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z17.Z17_DATA <= '"+DTOS(MV_PAR02)+"' "
	    cQuery += " AND Z17.D_E_L_E_T_ != '*' "
		
		cQuery += " EXCEPT "

		cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
		cQuery += " 	   '', SUBSTRING(Z18_FILIAL,1,4), Z18_CODIGO, '', '', '', '**** CONTATO NÃO EFETIVADO', Z18_OPERAD, Z18_CODIGO  " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "
				
    
    cQuery += " ) ) TZ "

    cQuery += " ORDER BY Z18_OPERAD, Z18_DATA, Z18_HORA  "
	

	cQuery := ChangeQuery(cQuery)  
	  	   
	If ( Select("QRY1") ) > 0
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY1"      
	              
	oReport:IncMeter(1)	     



	//***********************************************************************************
	//atendimentos - agrupador por dia
	//***********************************************************************************	            
	cQuery := " SELECT Z18_DATA, U7_NOME, SUM(TOT_TIPO1) AS TOT_TIPO1, SUM(VAL_TIPO1) AS VAL_TIPO1,SUM(TOT_TIPO2) AS TOT_TIPO2, SUM(VAL_TIPO2) AS VAL_TIPO2 "     	     	     
	cQuery += " FROM ( "
		cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, 0 AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          
	
		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0 AS TOT_TIPO1, SUM(ACG_RECEBE) AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          
	
		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO, 0 AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, 0, SUM(ACG_RECEBE) AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

    cQuery += ") as T                                   
    
    cQuery += " GROUP  BY Z18_DATA, U7_NOME " 
    cQuery += " ORDER BY U7_NOME, Z18_DATA  "
		 

	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE(CqUERY, "C:\Temp\SQL.TXT")  	   
	If ( Select("QRY2") ) > 0
		DbSelectArea("QRY2")
		QRY2->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY2"      


	//***********************************************************************************
	//atendimentos - acumulado dia (informação para retirar valor acumulado de um mesmo atendimento)
	//***********************************************************************************	              
	cQuery := " SELECT SUBSTRING(Z18_DATA,7,2)+'/'+SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS Z18_DATA, "
	cQuery += "        U7_NOME, SUM((TOT_TIPO1-1)*VAL_TIPO1) AS VAL_TIPO1DUPL, SUM((TOT_TIPO2-1)*VAL_TIPO2) AS VAL_TIPO2DUPL "     	     	     
	cQuery += " FROM ( "
		cQuery += " SELECT Z18_DATA, U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, ACG_RECEBE AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP, Z18_CODIGO,ACG_RECEBE "                          
	
		cQuery += " UNION "
	
		cQuery += " SELECT Z18_DATA, U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO, ACG_RECEBE AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP, Z18_CODIGO, ACG_RECEBE "                          
    cQuery += ") as T   "                                
    
    cQuery += " GROUP  BY Z18_DATA, U7_NOME " 
    cQuery += " ORDER BY U7_NOME, Z18_DATA  "
		 

	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE(CqUERY, "C:\Temp\SQL3.TXT")  	   
	If ( Select("QRY22") ) > 0
		DbSelectArea("QRY22")
		QRY22->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY22"      
	              
	//***********************************************************************************
	//atendimentos - agrupador por mes +  mes de referencia
	//***********************************************************************************	            
	              
	cQuery := " SELECT MES_ANO, U7_NOME, SUM(TOT_TIPO1) AS TOT_TIPO1, SUM(VAL_TIPO1) AS VAL_TIPO1,SUM(TOT_TIPO2) AS TOT_TIPO2, SUM(VAL_TIPO2) AS VAL_TIPO2 "     	     	     
	cQuery += " FROM ( "
		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, 0 AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          
	
		cQuery += " UNION "
	

		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0 AS TOT_TIPO1, SUM(ACG_RECEBE) AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          
	
		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO, 0 AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, 0 AS TOT_TIPO, SUM(ACG_RECEBE) AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

	    
	    // INCLUSÃO MES REFERENCIA, CASO O PARAMETRO SENHA SIDO INFORMADO
        If MV_PAR05 > 0 .AND. MV_PAR06 > 0
			cQuery += " UNION " 
	
			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, 0 AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

			cQuery += " UNION " 
	
			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_TIPOOP, 0 AS TOT_TIPO1, SUM(ACG_RECEBE) AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
		    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
		    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
		    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          

		
			cQuery += " UNION "
		
			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO,0 AS VAL_TIPO " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          	    

			cQuery += " UNION "
		
			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_TIPOOP, 0, 0, 0 AS TOT_TIPO, SUM(ACG_RECEBE) AS VAL_TIPO " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
		    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
		    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
		    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_TIPOOP "                          	    		    
		    
		EndIf
    cQuery += ") as T                                   
    
    cQuery += " GROUP  BY MES_ANO, U7_NOME " 
    cQuery += " ORDER BY U7_NOME, MES_ANO  "
		 

	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE(CqUERY, "C:\Temp\SQL.TXT")  	   
	If ( Select("QRY3") ) > 0
		DbSelectArea("QRY3")
		QRY3->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY3"      
	              
	oReport:IncMeter(3)	     
		         
	//***********************************************************************************
	//atendimentos - Retirar acumulados agrupador por mes +  mes de referencia
	//***********************************************************************************	            

	cQuery := " SELECT MES_ANO, U7_NOME, SUM((TOT_TIPO1-1)*VAL_TIPO1) AS VAL_TIPO1DUPL, SUM((TOT_TIPO2-1)*VAL_TIPO2) AS VAL_TIPO2DUPL "     	     	     
	cQuery += " FROM ( "
		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, ACG_RECEBE AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '1' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_CODIGO, Z18_TIPOOP, ACG_RECEBE "                          
	
		cQuery += " UNION "

		cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
		cQuery += " 	  U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO, ACG_RECEBE AS VAL_TIPO " 	 
		cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
		cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
	    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
	    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
	    cQuery += "    SU7.D_E_L_E_T_ != '*' "
		cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
	    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
	    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
	    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
		cQuery += " WHERE
	    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
	    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
	    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
	    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
	    cQuery += " AND Z18.Z18_DATA   >= '"+DTOS(MV_PAR01)+"' AND Z18.Z18_DATA <= '"+DTOS(MV_PAR02)+"' AND Z18_TIPOOP = '2' "
	    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
	    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_CODIGO, Z18_TIPOOP, ACG_RECEBE "                          
	    
	    // INCLUSÃO MES REFERENCIA, CASO O PARAMETRO SENHA SIDO INFORMADO
        If MV_PAR05 > 0 .AND. MV_PAR06 > 0
			cQuery += " UNION " 

			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, COUNT(Z18_TIPOOP) AS TOT_TIPO1, ACG_RECEBE AS VAL_TIPO1, 0 AS TOT_TIPO2, 0 AS VAL_TIPO2 " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
		    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
		    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
		    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_CODIGO, Z18_TIPOOP, ACG_RECEBE "                          
		
			cQuery += " UNION "
		
			cQuery += " SELECT SUBSTRING(Z18_DATA,5,2)+'/'+SUBSTRING(Z18_DATA,1,4) AS MES_ANO, "
			cQuery += " 	  U7_NOME, Z18_CODIGO, COUNT(Z18_CODIGO) AS TOT_CODIGO, Z18_TIPOOP, 0, 0, COUNT(Z18_TIPOOP) AS TOT_TIPO, ACG_RECEBE AS VAL_TIPO " 	 
			cQuery += " FROM "+RETSQLNAME("Z18")+" AS Z18 "
			cQuery += " INNER JOIN " + RetSqlName("SU7") + " AS SU7 "
		    cQuery += " ON SU7.U7_FILIAL  = '"+xFilial('SU7')+"'  	AND "
		    cQuery += "    SU7.U7_COD  = Z18.Z18_OPERAD    			AND "
		    cQuery += "    SU7.D_E_L_E_T_ != '*' "
			cQuery += " LEFT OUTER JOIN " + RetSqlName("ACG") + " AS ACG "
		    cQuery += " ON ACG.ACG_FILIAL  = Z18.Z18_FILIAL  	AND "
		    cQuery += "    ACG.ACG_CODIGO  = Z18.Z18_CODIGO 		AND "
		    cQuery += "    ACG.D_E_L_E_T_ != '*' "		 
			cQuery += " WHERE
		    cQuery += "     Z18.Z18_FILIAL >= '"+MV_PAR13+"' AND Z18.Z18_FILIAL <= '"+MV_PAR14+"' "
		    cQuery += " AND Z18.Z18_CODIGO >= '"+MV_PAR07+"' AND Z18.Z18_CODIGO <= '"+MV_PAR08+"' "
		    cQuery += " AND Z18.Z18_CLIENT >= '"+MV_PAR09+"' AND Z18.Z18_CLIENT <= '"+MV_PAR10+"'  AND Z18.Z18_LOJA >= '"+MV_PAR11+"' AND Z18.Z18_LOJA <= '"+MV_PAR12+"' "
		    cQuery += " AND Z18.Z18_OPERAD >= '"+MV_PAR03+"' AND Z18.Z18_OPERAD <= '"+MV_PAR04+"' "
		    cQuery += " AND Z18.Z18_DATA   >= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'01'+"' AND Z18.Z18_DATA <= '"+Alltrim(str(MV_PAR06))+STRZERO(MV_PAR05,2)+'31'+"' AND Z18_TIPOOP = '1' "
		    cQuery += " AND Z18.D_E_L_E_T_ != '*' "                      
		    cQuery += " GROUP  BY Z18_DATA, U7_NOME, Z18_CODIGO, Z18_TIPOOP, ACG_RECEBE "                          	    
		EndIf
    cQuery += ") as T                                   
    
    cQuery += " GROUP  BY MES_ANO, U7_NOME " 
    cQuery += " ORDER BY U7_NOME, MES_ANO  "
		 

	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE(CqUERY, "C:\Temp\SQL.TXT")  	   
	If ( Select("QRY32") ) > 0
		DbSelectArea("QRY32")
		QRY32->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY32"      
	             		
		
		
Return      

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria os parametros de perguntas      

@author Felipe Toazza CAldeira
@since 12/11/2015
@version P11
/*/
//-------------------------------------------------------------------     

Static function AjustaSX1(cPerg)

//PutSx1(cPerg,"01","Data De","Data De","Data De"					,"MV_CH1"	,"D",8,0,1,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"02","Data Ate","Data Ate","Data Ate"				,"MV_CH2"	,"D",8,0,1,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"03","Operador de","Operador de","Operador de"		,"MV_CH3"	,"C",6,0,1,"G","","SU7","","","MV_PAR03","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"04","Operador Ate","Operador Ate","Operador Ate"	,"MV_CH4"	,"C",6,0,1,"G","","SU7","","","MV_PAR04","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"05","Mes Referencia","Mes Referencia","Mes Ref."	,"MV_CH5"	,"N",2,0,1,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"06","Ano Referencia","Ano Referencia","Ano Ref."	,"MV_CH6"	,"N",4,0,1,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"07","Atendimento De","Atendimento De","Atend. De"	,"MV_CH7"	,"C",6,0,1,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"08","Atendimento Ate","Atendimento Ate","Aten. A"	,"MV_CH8"	,"C",6,0,1,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"09","Cliente De","Cliente De","Cliente De"		,"MV_CH9"	,"C",6,0,1,"G","","CLT","","","MV_PAR09","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"10","Cliente Ate","Cliente Ate","Cliente A"		,"MV_CHA"	,"C",6,0,1,"G","","CLT","","","MV_PAR10","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"11","Loja De","Loja De","Loja De"					,"MV_CHB"	,"C",2,0,1,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"12","Loja Ate","Loja Ate","Loja A"				,"MV_CHC"	,"C",2,0,1,"G","","","","","MV_PAR12","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"13","Filial De","Filial De","Filial De"			,"MV_CHD"	,"C",6,0,1,"G","","SM0","","","MV_PAR13","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"14","Filial Ate","Filial Ate","Filial Ate"		,"MV_CHE"	,"C",6,0,1,"G","","SM0","","","MV_PAR14","","","","","","","","","","","","","","","","","",{})

Return