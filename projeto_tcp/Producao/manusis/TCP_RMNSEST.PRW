/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                       		 !
+------------------+---------------------------------------------------------+
!Módulo            ! estoque!
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de requisições vindas do manusis, que não teve saldo
!				   ! 														 !
/*-----------------+---------------------------------------------------------+
!Nome              ! RMNSEST                                                 !			                                         
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 
                                             !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'  
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE "TBICONN.CH"

User Function RMNSEST 

	Local oReport
	Local cPerg  := 'RMNSEST'
	Local cAlias := getNextAlias()
	
	criaSx1(cPerg)
	Pergunte(cPerg, .F.)
	
	oReport := reportDef(cAlias, cPerg)
	oReport:printDialog()
	
return


//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

	Local cTitle  := "Relatório de Produtos sem Saldo para abrir OM"
	Local cHelp   := "Permite visualizar todos os erros por falta de saldo nas programações de OM no Manusis."
	Local oReport
	Local oSection1
	
	oReport := TReport():New(cPerg,cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
	
	//Primeira seção
	oSection1 := TRSection():New(oReport,"Relatório de Produtos sem Saldo para abrir OM",{"ZZH"}) 

		
	TRCell():New(oSection1,"ZZH_OM"	   , "ZZH", "OM"                  , X3PICTURE("ZZH_OM"),  15)
	TRCell():New(oSection1,"ZZH_RESERV", "ZZH", "Reserva"             , X3PICTURE("ZZH_RESERV"),  15)
	TRCell():New(oSection1,"ZZH_DTPRG" , "ZZH", "Data Programação"    , X3PICTURE("ZZH_DTPRG"),  8)
	TRCell():New(oSection1,"ZZH_PRODUT", "ZZH", "Produto"             , X3PICTURE("ZZH_PRODUT"),  15)
	TRCell():New(oSection1,"ZZH_DESC"  , "ZZH", "Descrição"           , X3PICTURE("ZZH_DESC"),  40)
	TRCell():New(oSection1,"ZZH_DATA"  , "ZZH", "Data"                , X3PICTURE("ZZH_DATA"),  8)
	TRCell():New(oSection1,"ZZH_HORA"  , "ZZH", "hora"                , X3PICTURE("ZZH_HORA")  ,  8)
	TRCell():New(oSection1,"ZZH_QTDSOL", "ZZH", "Qtde Solicitada"     , X3PICTURE("ZZH_QTDSOL")  , 16  )
	TRCell():New(oSection1,"ZZH_QTDDIS", "ZZH", "Qtde Disponível"     , X3PICTURE("ZZH_QTDDIS")  , 16) 
	TRCell():New(oSection1,"ZZH_QTDTOT", "ZZH", "Qtde Total"          , X3PICTURE("ZZH_QTDTOT")  ,  16) 
	TRCell():New(oSection1,"ZZH_QTDPED", "ZZH", "Qtde Pc"             , X3PICTURE("ZZH_QTDPED")  ,  16) 
	TRCell():New(oSection1,"ZZH_DTCOMP", "ZZH", "Previsão Entrega"    , X3PICTURE("ZZH_DTCOMP"), 8) 


Return(oReport)


//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
	Local oSecao1 	:= oReport:Section(1)   
	Local cWhere  	:= "% "

	If !Empty(MV_PAR01)
		cWhere  += " AND ZZH_DATA >= '"+DTOS(MV_PAR01)+"' "
	EndIf        
	
	If !Empty(MV_PAR02)
		cWhere += " AND ZZH_DATA <= '" + DTOS(MV_PAR02) + "' "
	EndIf
	 
	If !Empty(MV_PAR03)
		cWhere  += " AND ZZH_PRODUT >= '" + MV_PAR03 + "' "
	EndIf
	
	If !Empty(MV_PAR03)
		cWhere  += " AND ZZH_PRODUT <= '" + MV_PAR04 + "' "
	EndIf
	
	cWhere += "%"
	
	oSecao1:BeginQuery()
	
		BeginSql alias cAlias
			column ZZH_DATA as Date
			SELECT *
			FROM %Table:ZZH% ZZH
			WHERE ZZH.%NotDel%  AND 1=1  %EXP:cWhere%
			ORDER BY ZZH_DATA
		EndSql   
	
	oSecao1:EndQuery()
	
	oReport:SetMeter((cAlias)->(RecCount()))    
	
	oSecao1:Init()
	
	While (cAlias)->(!Eof())  
		
		oSecao1:PrintLine()
		   
		(cAlias)->(dbSkip())
	
	EndDo 
	
	(cAlias)->(dbCloseArea()) 
	
	oSecao1:Finish() 

Return 


//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
Static Function criaSX1(cPerg)

	Local aRegs:= {}
	
	aAdd(aRegs,{cPerg, "01", "Data de"	   , "Data de"     ,"Data de"	  , "mv_ch1", "D", 8, 0, 0, "G", "", "mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "02", "Data ate"	   , "Data ate"    ,"Data ate"    , "mv_ch2", "D", 8, 0, 0, "G", "", "mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "03", "Produto de"  , "Produto de"  ,"Produto de"  , "mv_ch3", "C", 15, 0, 0, "G", "", "mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SB1","","",""})
	aAdd(aRegs,{cPerg, "04", "Produto ate" , "Produto ate" ,"Produto ate" , "mv_ch4", "C", 15, 0, 0, "G", "", "mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SB1","","",""})
	
	U_BuscaPerg(aRegs)

Return  