#include "protheus.ch"
#include "report.ch" 

/*/{Protheus.doc} TCFIR001
Relatorio de 
@type function
@version 
@author kaiquesousa
@since 6/8/2020
@return return_type, return_description
/*/

user function TCFIR001()

    Local oReport

    oReport := ReportDef()
    oReport:PrintDialog()

return( nil )

/*/{Protheus.doc} ReportDef
description
@type function
@version 
@author kaiquesousa
@since 6/8/2020
@return return_type, return_description
/*/

static function ReportDef()
    
    Local oReport
    Local oSection1
    Local oSection2
    Local bValorLib  := {|| If(Empty(ZA0_DATALIB), 0, ZA0_VALOR) }
    Local bValorCan  := {|| If(Empty(ZA0_DATACAN), 0, ZA0_VALOR) }
    Local bStatus    := {|| fGetStatus(ZA0_STATUS) }
    Local bGetUser   := {|| UsrRetName(ZA0_USER) }
    Local bGetUsApr  := {|| UsrRetName(ZA0_APROVA) }
    Local cPerg      := "TCFIR001"
    
    CriaSX1(cPerg)
    Pergunte(cPerg,.F.)

    DEFINE REPORT oReport NAME "TCFIR001" TITLE "Liberação de Pagamentos manuais" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)}

    DEFINE SECTION oSection1 OF oReport TITLE "Dados do Titulo" TABLES "ZA0" //LEFT MARGIN 2 LINES BEFORE 0 PAGE BREAK //"Dados do Titulo"

    DEFINE CELL NAME "ZA0_FILIAL" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "FILIAL" //"FILIAL"
    DEFINE CELL NAME "ZA0_CODIGO" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "CODIGO" //"PREFIXO"
    DEFINE CELL NAME "ZA0_NUM" 		OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "NUMERO" //"NUMERO"
    DEFINE CELL NAME "ZA0_TIPO"	 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "TIPO" //"TIPO"
    DEFINE CELL NAME "ZA0_CLIFOR" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "FORNECEDOR" //"FORNECEDOR"
    DEFINE CELL NAME "ZA0_LOJA"	 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "LOJA" //"LOJA"
    DEFINE CELL NAME "A2_NOME"	 	OF oSection1 ALIAS "SA2" SIZE 20 TITLE "NOME" //"LOJA"
    DEFINE CELL NAME "A2_CGC"	 	OF oSection1 ALIAS "SA2" SIZE 20 TITLE "CGC" //"LOJA"
    DEFINE CELL NAME "ZA0_TIPO" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "TP. PAGTO" //"TP. PAGTO"
    DEFINE CELL NAME "ZA0_EMISSA" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "EMISSAO" //"EMISSAO"
    DEFINE CELL NAME "ZA0_DTSOLI" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "DT. INCLUSAO" //"VENCTO"
    DEFINE CELL NAME "ZA0_VENCRE" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "VENCTO REAL" //"VENCTO REAL"
    DEFINE CELL NAME "ZA0_VALOR" 	OF oSection1 ALIAS "ZA0" SIZE 10 TITLE "VALOR" //"VALOR"

    //DADOS AUTORIZACAO
    DEFINE SECTION oSection2 OF oSection1 TITLE "Dados da Autorização" TABLES "TEMP_LIB" //LEFT MARGIN 2 LINES BEFORE 2 //"Dados da Autorização"

    DEFINE CELL NAME "ZA0_DATALIB" 	OF oSection2 ALIAS "TEMP_LIB" SIZE 17 TITLE "DATA AUTORIZAÇÃO" 				 //"DATA AUTORIZAÇÃO"
    DEFINE CELL NAME "ZA0_VALOR" 	OF oSection2 ALIAS "TEMP_LIB" SIZE 17 TITLE "VALOR LIBERADO " BLOCK bValorLib  //"VALOR LIBERADO "
    DEFINE CELL NAME "ZA0_USER" 	OF oSection2 ALIAS "TEMP_LIB" SIZE 20 TITLE "USUÁRIO" BLOCK bGetUser				 //"USUÁRIO"
    DEFINE CELL NAME "ZA0_APROVA" 	OF oSection2 ALIAS "TEMP_LIB" SIZE 20 TITLE "APROVADOR" BLOCK bGetUsApr				 //"APROVADOR"
    DEFINE CELL NAME "ZA0_STATUS" 	OF oSection2 ALIAS "TEMP_LIB" SIZE 25 TITLE "STATUS" BLOCK bStatus				 //"STATUS"
    
return( oReport )

/*/{Protheus.doc} PrintReport
Traz os dados do relatorio de liberação de documentos
@type function
@version 
@author kaiquesousa
@since 6/8/2020
@param oReport, object, param_description
@return return_type, return_description
/*/

static function PrintReport( oReport )
    
    Local cAlias    := GetNextAlias()
    Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)
	Local cSQL 		:= ""
	Local cStatus   := mv_par13 
	Local cFiliali  := Iif( mv_par14 == 1, mv_par15, xFilial("ZA0") )
	Local cFilialf  := Iif( mv_par14 == 1, mv_par16, xFilial("ZA0") )
    
    cSQL := "%"
    If( cStatus == 1 ) //aguardando liberacao
        cSQL += "ZA0_STATUS = '1' " 
    ElseIf ( cStatus == 2 ) //liberados
        cSQL += "ZA0_STATUS = '2' "
    ElseIf ( cStatus == 3 ) //Cancelados
        cSQL += "ZA0_STATUS = '3' "
    Else
        cSQL += "1=1"
    EndIf
    cSQL += "%"

    BeginSql alias cAlias
        Column ZA0_EMISSA as date
        Column ZA0_VENCTO as date
        Column ZA0_VENCRE as date
        Column ZA0_DATALIB as date
        Column ZA0_DTSOLI as date
        SELECT 
            ZA0.ZA0_FILIAL,		
            ZA0.ZA0_CODIGO,
            ZA0.ZA0_NUM  	,
            ZA0.ZA0_TIPO 	,
            ZA0.ZA0_CLIFOR  ,
            ZA0.ZA0_LOJA 	,
            ZA0.ZA0_TIPO  	,
            ZA0.ZA0_EMISSA  ,
            ZA0.ZA0_DTSOLI  ,
            ZA0.ZA0_VENCRE  ,
            ZA0.ZA0_VALOR  	,      
            SA2.A2_NOME , 
            SA2.A2_CGC,
            TEMP_LIB.CR_DATALIB  ZA0_DATALIB,
            TEMP_LIB.CR_USER      ZA0_USER,
            TEMP_LIB.CR_USERLIB   ZA0_APROVA,
            TEMP_LIB.CR_STATUS   ZA0_STATUS
        FROM %table:ZA0% ZA0
        INNER JOIN %table:SA2% SA2
            ON  SA2.A2_FILIAL = %xFilial:SA2%
            AND SA2.A2_COD = ZA0.ZA0_CLIFOR
            AND SA2.A2_LOJA  = ZA0.ZA0_LOJA
            AND SA2.%NotDel%
        INNER JOIN %table:SCR% TEMP_LIB
            ON  ZA0.ZA0_FILIAL	= TEMP_LIB.CR_FILIAL
            AND ZA0.ZA0_CODIGO  = TEMP_LIB.CR_NUM
            AND TEMP_LIB.CR_TIPO = 'AP'
            AND TEMP_LIB.%NotDel%
        WHERE 
                ZA0.ZA0_FILIAL  BETWEEN %Exp:cFiliali% AND %Exp:cFilialf%					
            AND ZA0.ZA0_CODIGO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
            AND ZA0.ZA0_CLIFOR BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
            AND ZA0.ZA0_EMISSA BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
            AND ZA0.ZA0_DTSOLI  BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
            AND ZA0.ZA0_VENCRE  BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
            AND ZA0.ZA0_CODSOL  BETWEEN %Exp:mv_par11% AND %Exp:mv_par12%
            AND ZA0.%NotDel%
            AND %exp:cSQL%
        ORDER BY ZA0.ZA0_CODIGO
    EndSql

    END REPORT QUERY oSection1

	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { |cParam| (cAlias)->( ZA0_FILIAL+ZA0_CODIGO ) == cParam },{|| (cAlias)->( ZA0_FILIAL+ZA0_CODIGO ) })			

	oSection1:Print()

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
description Cria perguntas no dicionario de dados
@author  Kaique Mathias
@since   06/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

static function CriaSX1( cPerg )
  
    u_xPutSx1(cPerg,"01","De Codigo ?"             	,"De Codigo ?"       			,"De Codigo ?"          		,"mv_ch1"  ,"C" ,6,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"02","Até Codigo ?"            	,"Até Codigo ?"      			,"Até Codigo ?"         		,"mv_ch2"  ,"C" ,6,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"03","De Fornecedor ?"          ,"De Fornecedor ?"       		,"De Fornecedor ?"          	,"mv_ch3"  ,"C" ,6,0,0,"G","","SA2","","","mv_par03","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"04","Até Fornecedor ?"         ,"Até Fornecedor ?"      		,"Até Fornecedor ?"         	,"mv_ch4"  ,"C" ,6,0,0,"G","","SA2","","","mv_par04","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"05","De Emissão ?"       	    ,"De Emissão ?"    			    ,"De Emissão ?"       		    ,"mv_ch5"  ,"D" ,8,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"06","Até Emissão ?"      	    ,"Até Emissão ?"   			    ,"Até Emissão ?"      		    ,"mv_ch6"  ,"D" ,8,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"07","De Inclusão ?"            ,"De Inclusão ?"    			,"De Inclusão ?"       		    ,"mv_ch7"  ,"D" ,8,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"08","Até Inclusão ?"           ,"Até Inclusão ?"   			,"Até Inclusão ?"      		    ,"mv_ch8"  ,"D" ,8,0,0,"G","","   ","","","mv_par08","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"09","De Vencto Real ?"        	,"De Vencto Real ?"   			,"De Vencto Real ?"      		,"mv_ch9"  ,"D" ,8,0,0,"C","","   ","","","mv_par09","","","","","","","","","","","","","","","","",{""   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"10","Até Vencto Real ?"        ,"Até Vencto Real ?"         	,"Até Vencto Real ?"            ,"mv_cha"  ,"D" ,8,0,0,"G","","   ","","","mv_par10","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"11","De Solicitante ?"         ,"De Solicitante ?"        		,"De Solicitante ?"           	,"mv_chb"  ,"C" ,6,0,0,"G","","   ","","","mv_par11","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"12","Até Solicitante ?"	    ,"Até Solicitante ?"   	        ,"Até Solicitante ?"            ,"mv_chc"  ,"C" ,6,0,0,"G","","   ","","","mv_par12","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"13","Status ?"         		,"Status ?"   			        ,"Status ?"      		        ,"mv_chd"  ,"N" ,1,0,0,"C","","   ","","","mv_par13","Aguardando","","","","Liberado","","","Cancelado","","","Todos","","","","","",{""   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"14","Seleciona Filiais ?"      ,"Seleciona Filiais ?"   		,"Seleciona Filiais ?"      	,"mv_che"  ,"N" ,1,0,0,"C","","   ","","","mv_par14","Sim","","","","Não","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"15","Filial de ?"         		,"Filial de ?"   			    ,"Filial de ?"      		    ,"mv_chf"  ,"C" ,2,0,0,"G","","XM0","","","mv_par15","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"16","Filial ate ?"         	,"Filial ate ?"   			    ,"Filial ate ?"      		    ,"mv_chg"  ,"C" ,2,0,0,"G","","XM0","","","mv_par16","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")

return( nil )

/*/{Protheus.doc} fGetStatus
Retorna a descrição do status
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/8/2020
@param cStatus, character, param_description
@return return_type, return_description
/*/

static function fGetStatus( cStatus )

    Local cSituaca := " "

    Do Case
    Case cStatus == "01"
        cSituaca := OemToAnsi("Pendente em níveis anteriores")
    Case cStatus == "02"
        cSituaca := OemToAnsi("Pendente")
    Case cStatus == "03"
        cSituaca := OemToAnsi("Aprovado")
    Case cStatus == "04"
        cSituaca := OemToAnsi("Bloqueado")
    Case cStatus == "05"
        cSituaca := OemToAnsi("Aprovado/rejeitado pelo nível")
    Case cStatus == "06"
        cSituaca := "Rejeitado"
    EndCase

Return( cSituaca )