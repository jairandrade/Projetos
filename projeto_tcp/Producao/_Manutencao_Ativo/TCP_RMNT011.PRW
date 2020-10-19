#include "protheus.ch"
#include "topconn.ch"


//------------------------------------------------------------------
/*/{Protheus.doc} RMNT011
Relatório de OSs planjeadas
	
@author Felipe Toazza Caldeira
@since 26/12/2016
@version 1.0

@return nil
/*/
//------------------------------------------------------------------   

User Function RMNT011()

Local oReport
Private	cTMPINF	:= "TMPINF"+Dtos(dDataBAse)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
Private cPerg := "RMNT011"
	
CriaPerg(cPerg)

If !Pergunte(cPerg,.T.)
	Return
EndIf 
	                            
oReport := ReportDef()
oReport:PrintDialog()

Return

//------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Cria o objeto instânica da classe TReport
	
@since 10/04/2015
@version 1.0

@return 
/*/
//------------------------------------------------------------------   

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
                                        
oReport := TReport():New("RMNT011","Relatório de Aderencia de OSs Planejadas",cPerg,{|oReport| PrintReport(oReport)},"Aderencia OSs Planejadas")
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)
oReport:ShowHeader()	     	

oSection1 := TRSection():New(oReport,"Turno",{"TRB"})
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderBrake(.T.)
//oSection1:SetLineStyle() 

TRCell():New(oSection1,"PERIODO"   ,"TRBMES", "Periodo"	 ,/**PICUTRE**/,15)
TRCell():New(oSection1,"TURNO"     ,"TRBMES", "Turno"	 ,/**PICUTRE**/,15)
TRCell():New(oSection1,"PLANJADO"  ,"TRBMES", "Planejado",/**PICUTRE**/,15)
TRCell():New(oSection1,"REALIZADO" ,"TRBMES", "Realizado",/**PICUTRE**/,15)
TRCell():New(oSection1,"Aderencia" ,"TRBMES", "Aderencia",/**PICUTRE**/,15)

oSection2 := TRSection():New(oSection1,"Líder",{"TRB"})
oSection2:SetTotalInLine(.F.) 
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderBrake(.T.)

TRCell():New(oSection2,"LIDER"   	,"TRB", "Lider",/**PICUTRE**/,45,/*lPixel*/,)
//TRCell():New(oSection2,"LTURNO"   	,"TRB", "Turno",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LPLADIA"   	,"TRB", "Plan. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LRELDIA"   	,"TRB", "Real. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LADEDIA"   	,"TRB", "Ader. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LPLASEM"   	,"TRB", "Plan. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LRELSEM"   	,"TRB", "Real. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LADESEM"   	,"TRB", "Ader. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LPLAMES"   	,"TRB", "Plan. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LRELMES"   	,"TRB", "Real. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection2,"LADEMES"   	,"TRB", "Ader. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)

//oSection2:Cell("Z16_FOLLOW"):SetLineBreak(.T.)

oSection3 := TRSection():New(oSection2,"Tecnico",{"TRB"})
oSection3:SetTotalInLine(.F.) 
oSection3:SetHeaderPage(.F.)
oSection3:SetHeaderBrake(.T.)

TRCell():New(oSection3,"TECNICO"   	,"TRB", "Tecnico",/**PICUTRE**/,45,/*lPixel*/,)
//TRCell():New(oSection3,"TTURNO"   	,"TRB", "Turno",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TPLADIA"   	,"TRB", "Plan. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TRELDIA"   	,"TRB", "Real. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TADEDIA"   	,"TRB", "Ader. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TPLASEM"   	,"TRB", "Plan. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TRELSEM"   	,"TRB", "Real. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TADESEM"   	,"TRB", "Ader. Sem.",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TPLAMES"   	,"TRB", "Plan. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TRELMES"   	,"TRB", "Real. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)
TRCell():New(oSection3,"TADEMES"   	,"TRB", "Ader. Mes",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)

oSection4 := TRSection():New(oSection3,"Líder",{"TRB"})
oSection4:SetTotalInLine(.F.) 
oSection4:SetHeaderPage(.F.)
oSection4:SetHeaderBrake(.T.)

TRCell():New(oSection4,"4LIDER"   	,"TRB", "Lider",/**PICUTRE**/,40,/*lPixel*/,)
TRCell():New(oSection4,"4DATAOS"   	,"TRB", "Data",/**PICUTRE**/,12,/*lPixel*/,)
TRCell():New(oSection4,"4LTURNO"   	,"TRB", "Turno",/**PICUTRE**/,4,/*lPixel*/,)
TRCell():New(oSection4,"4LORDEM"   	,"TRB", "Ordem",/**PICUTRE**/,10,/*lPixel*/,)
TRCell():New(oSection4,"4LFLUIG"   	,"TRB", "N. Fluig" ,/**PICUTRE**/,10,/*lPixel*/,)
TRCell():New(oSection4,"4LBEM"   	,"TRB", "Bem",/**PICUTRE**/,15,/*lPixel*/,)
TRCell():New(oSection4,"4LPLADIA"  	,"TRB", "Real. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)

oSection5 := TRSection():New(oSection4,"Tecnico",{"TRB"})
oSection5:SetTotalInLine(.F.) 
oSection5:SetHeaderPage(.F.)
oSection5:SetHeaderBrake(.T.)

TRCell():New(oSection5,"5LIDER"   	,"TRB", "Tecnico",/**PICUTRE**/,40,/*lPixel*/,)
TRCell():New(oSection5,"5DATAOS"   	,"TRB", "Data",/**PICUTRE**/,12,/*lPixel*/,)
TRCell():New(oSection5,"5TTURNO"   	,"TRB", "Turno",/**PICUTRE**/,4,/*lPixel*/,)
TRCell():New(oSection5,"5TORDEM"   	,"TRB", "Ordem",/**PICUTRE**/,10,/*lPixel*/,)
TRCell():New(oSection5,"5TFLUIG"   	,"TRB", "N. Fluig",/**PICUTRE**/,10,/*lPixel*/,)
TRCell():New(oSection5,"5TBEM"   	,"TRB", "Bem",/**PICUTRE**/,15,/*lPixel*/,)
TRCell():New(oSection5,"5TPLADIA"  	,"TRB", "Real. Dia",/**PICUTRE**/,/*TAMANHO*/,/*lPixel*/,)


oSection1:SetLeftMargin(5)
oSection2:SetLeftMargin(10)
oSection3:SetLeftMargin(10)
oSection4:SetLeftMargin(10)
oSection5:SetLeftMargin(10)

Return oReport


//------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Executa a impressão 
	
@author Gislaine Sabino
@since 10/04/2015
@version 1.0

@return 
/*/
//------------------------------------------------------------------   

Static Function PrintReport(oReport)

Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(1):Section(1)
Private oSection3 := oReport:Section(1):Section(1):Section(1)
Private oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Private oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

Private aFluigUsers := {}               
FluigUsers("lider_turno_manutencao")


If MV_PAR02 == 1
	ExecQuery()
	
	sessao1()
	
	sessao2()
	
	sessao3()
Else
	AnalitQry()
	
	sessao1()
	
	AnSessao2()
	
	AnSessao3()
EndIf

dbSelectArea("TRBMES")
Ncount:= 0
count to  ncount
oReport:setmeter(ncount)
TRBMES->(dbGoTop())


cQuery := "DROP TABLE "+cTMPINF+" "
TcSqlExec(cQuery)                             
TcSqlExec('ALTER TABLE '+cTMPINF+' ALTER COLUMN TL_ORDEM VARCHAR(6) NOT NULL')
TcSqlExec('ALTER TABLE '+cTMPINF+' ALTER COLUMN TL_CODIGO VARCHAR(15) NOT NULL')


TRBMES->(DbCloseArea())
TRBDIA->(DbCloseArea())
TRBSEM->(DbCloseArea())
TRBTEC->(DbCloseArea())
TRBLIDER->(DbCloseArea())

Return


//------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery
Executa a query e cria o arquivo temporário para impressão do relatório 
	
@author Gislaine Sabino
@since 10/04/2015
@version 1.0

@return nil
/*/
//------------------------------------------------------------------   
Static Function ExecQuery()

If Select("TRB") <> 0
 DBSelectArea("TRB")
 DBCloseArea()
EndIf
   	                                                           
nSemana := Dow(MV_PAR01)   	
 
dIniSem := MV_PAR01+1-nSemana //
dFimSem := MV_PAR01+6-nSemana

cQuery := "DROP TABLE "+cTMPINF+" "
TcSqlExec(cQuery)
   	            
cQuery:="  	SELECT TL_DTINICI AS DT , TJ_ZTURNO, TL_ORDEM, TJ_ZLIDER, TJ_XNEGLID, TL_TAREFA, TL_CODIGO, TL_XCONFIR, STL.R_E_C_N_O_ "  

cQuery+="   INTO "+cTMPINF

cQuery+="   FROM " + RetSQLName("STJ") + " STJ  "
cQuery+="        INNER JOIN " + RetSQLName("STL") +" STL ON "
cQuery+="            STL.TL_FILIAL 	 = STJ.TJ_FILIAL "
cQuery+="            AND STL.TL_ORDEM = STJ.TJ_ORDEM "
cQuery+="            AND STL.TL_PLANO = STJ.TJ_PLANO "
cQuery+="            AND STL.TL_TIPOREG = 'M' "   
cQuery+="            AND STL.TL_QUANTID > 0 "   
cQuery+="            AND STL.D_E_L_E_T_ != '*' "
cQuery+="	WHERE 
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND SUBSTRING(STL.TL_DTINICI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"' "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001088] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL)  AND tecnico_matricula != ' ' "
cQuery+="	            AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001088] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada')"
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN , '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001088] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_matricula != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001089] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL) AND (tecnico_matricula != ' ' or tecnico_matricula is NULL) "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "                                                 
cQuery+="	         AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001089] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada')"
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001089] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_matricula != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_executor COLLATE Latin1_General_BIN, '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001062] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL) AND tecnico_executor != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "                                                                                       
cQuery+="	         AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001062] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada') "
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_executor COLLATE Latin1_General_BIN, '2', 0  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001062] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_executor != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )



TcSqlExec(cQuery) 
TcSqlExec("UPDATE "+cTMPINF+" SET TL_CODIGO = '               ' WHERE TL_CODIGO IS NULL")
TcSqlExec('ALTER TABLE '+cTMPINF+' ALTER COLUMN TL_ORDEM VARCHAR(6) NOT NULL')
TcSqlExec('ALTER TABLE '+cTMPINF+' ALTER COLUMN TL_CODIGO VARCHAR(15) NOT NULL')

cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT " 
cQuery += " FROM "+cTMPINF
cQuery += " GROUP BY"
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBMES"

cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT"
cQuery += " FROM "+cTMPINF
cQuery += " WHERE DT = '"+DtoS(MV_PAR01)+"' "
cQuery += " GROUP BY"
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBDIA"

cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT "
cQuery += " FROM "+cTMPINF
cQuery += " WHERE DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"' "
cQuery += " GROUP BY "
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBSEM"


//cQuery := " SELECT TJ_ZLIDER , TJ_ZTURNO, SUM(MR) AS MR, SUM(MP) AS MP, SUM(SR) AS SR, SUM(SP) AS SP, SUM(DR) AS DR, SUM(DP) AS DP
cQuery := " SELECT TJ_ZLIDER , SUM(MR) AS MR, SUM(MP) AS MP, SUM(SR) AS SR, SUM(SP) AS SP, SUM(DR) AS DR, SUM(DP) AS DP
cQuery += " FROM ("

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 1 MR,0 MP,0 SR,0 SP,0 DR,0 DP " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR = '1' AND TJ_XNEGLID != '1' "

cQuery += " UNION "

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 0,1,0,0,0,0  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR != '1'  OR TJ_XNEGLID = '1' "

cQuery += " UNION "

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 0,0,1,0,0,0 " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR = '1' AND  DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"'  AND TJ_XNEGLID != '1' "

cQuery += " UNION "

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 0,0,0,1,0,0  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	(TL_XCONFIR != '1'  OR TJ_XNEGLID = '1' ) AND DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"' "
cQuery += " UNION "

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 0,0,0,0,1,0  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR = '1' AND DT = '"+DtoS(MV_PAR01)+"'  AND TJ_XNEGLID != '1' "
cQuery += " UNION "

cQuery += " SELECT DISTINCT TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, 0,0,0,0,0,1  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	(TL_XCONFIR != '1'  OR TJ_XNEGLID = '1' ) AND  DT = '"+DtoS(MV_PAR01)+"' "
cQuery += " ) T "
cQuery += " GROUP BY TJ_ZLIDER "//, TJ_ZTURNO  "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBLIDER"                                 

//right(replicate('0',2) + convert(VARCHAR,mes),2) as mes

//cQuery := " SELECT RTRIM(TL_CODIGO)+' - '+RTRIM(RA_NOME) AS TL_CODIGO ,  TJ_ZTURNO, SUM(MR) AS MR, SUM(MP) AS MP, SUM(SR) AS SR, SUM(SP) AS SP, SUM(DR) AS DR, SUM(DP) AS DP
cQuery := " SELECT RTRIM(TL_CODIGO)+' - '+RTRIM(RA_NOME) AS TL_CODIGO ,  SUM(MR) AS MR, SUM(MP) AS MP, SUM(SR) AS SR, SUM(SP) AS SP, SUM(DR) AS DR, SUM(DP) AS DP
cQuery += " FROM ("

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM, TM.R_E_C_N_O_, 1 MR,0 MP,0 SR,0 SP,0 DR,0 DP " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR = '1' "

cQuery += " UNION "

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM,TM.R_E_C_N_O_, 0,1,0,0,0,0  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR != '1' "

cQuery += " UNION "

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM,TM.R_E_C_N_O_, 0,0,1,0,0,0 " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR = '1' AND  DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"' "

cQuery += " UNION "

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM, TM.R_E_C_N_O_, 0,0,0,1,0,0  " 
cQuery += " FROM "+cTMPINF +" TM "
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR != '1' AND DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"' "
cQuery += " UNION "

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM, TM.R_E_C_N_O_,  0,0,0,0,1,0  " 
cQuery += " FROM "+cTMPINF+" TM " 
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR != '1' AND DT = '"+DtoS(MV_PAR01)+"' "
cQuery += " UNION "

cQuery += " SELECT TL_CODIGO,  TJ_ZTURNO, TL_ORDEM, TM.R_E_C_N_O_,  0,0,0,0,0,1  " 
cQuery += " FROM "+cTMPINF+" TM " 
cQuery += " WHERE "
cQuery += " 	TL_XCONFIR != '1' AND  DT = '"+DtoS(MV_PAR01)+"' "
cQuery += " ) T, "+RetSqlName('SRA')+" SRA "
cQuery += " WHERE RA_FILIAL = '"+xFilial('SRA')+"' AND RTRIM(TL_CODIGO) = RA_MAT AND SRA.D_E_L_E_T_ != '*' "
cQuery += " GROUP BY TL_CODIGO, RA_NOME "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBTEC"                                 




Return

//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function CriaPerg(cPerg)
 	
	//PutSx1(cPerg,"01","Data Base","Data Base","Data Base"	,"MV_CH1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
   	//PutSx1(cPerg,"02","Sintetico","Sintetico","Sintetico"	,"MV_CH2","C",1,0,0,"C","","","","","MV_PAR02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")

Return
                                  
//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function sessao1()
 	
oSection1:Init()
nNotRel := 0  
nRel  	:= 0
While (!TRBMES->(EOF()))
	
	IF TRBMES->TL_XCONFIR == '1'
		nRel += TRBMES->TOT
	Else
		nNotRel += TRBMES->TOT
	EndIf
		TRBMES->(dbSkip())

End

oSection1:Cell("PERIODO"  	):SetValue(SubStr(DtoC(MV_PAR01),4,7))
oSection1:Cell("PLANJADO"  	):SetValue(Round(nNotRel+nRel,2))	
oSection1:Cell("REALIZADO"  ):SetValue(Round(nRel,2))	
oSection1:Cell("Aderencia"  ):SetValue(Alltrim(Str(Round((nRel/(nNotRel+nRel))*100,2)))+"%")	
oSection1:PrintLine()

TRBSEM->(dbGoTop())

oSection1:Init()
nNotRel := 0  
nRel  	:= 0
While (!TRBSEM->(EOF()))
	
	IF TRBSEM->TL_XCONFIR == '1'
		nRel += TRBSEM->TOT
	Else
		nNotRel += TRBSEM->TOT                                    
		
	EndIf
	TRBSEM->(dbSkip())

End

oSection1:Cell("PERIODO"  	):SetValue("SEMANA")
oSection1:Cell("PLANJADO"  	):SetValue(Round(nNotRel+nRel,2))	
oSection1:Cell("REALIZADO"  ):SetValue(Round(nRel,2))	
oSection1:Cell("Aderencia"  ):SetValue(Alltrim(Str(Round((nRel/(nNotRel+nRel))*100,2)))+"%")	
oSection1:PrintLine()

TRBDIA->(dbGoTop())

oSection1:Init()
nNotRel := 0  
nRel  	:= 0
While (!TRBDIA->(EOF()))
	
	IF TRBDIA->TL_XCONFIR == '1'
		nRel += TRBDIA->TOT
	Else
		nNotRel += TRBDIA->TOT
	EndIf
	TRBDIA->(dbSkip())

End

oSection1:Cell("PERIODO"  	):SetValue(DtoC(MV_PAR01))
oSection1:Cell("PLANJADO"  	):SetValue(Round(nNotRel+nRel,2))	
oSection1:Cell("REALIZADO"  ):SetValue(Round(nRel,2))	
oSection1:Cell("Aderencia"  ):SetValue(Alltrim(Str(Round((nRel/(nNotRel+nRel))*100,2)))+"%")	
oSection1:PrintLine()

oSection1:Finish()


Return

//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function sessao2()

oSection2:Init()
TRBLIDER->(dbGoTop())

oSection1:Init()
While (!TRBLIDER->(EOF()))                         
	nPos := Ascan(aFluigUsers,{|x|x[1]==StrZero(TRBLIDER->TJ_ZLIDER,6)})
	If nPos > 0
		cLider := StrZero(TRBLIDER->TJ_ZLIDER,6)+" - "+aFluigUsers[nPos][2]
	Else
		cLider := StrZero(TRBLIDER->TJ_ZLIDER,6)+" - "	
	Endif
	oSection2:Cell("LIDER"  	):SetValue(cLider)   
//	oSection2:Cell("LTURNO"  	):SetValue(TRBLIDER->TJ_ZTURNO)   	
	oSection2:Cell("LPLADIA"  	):SetValue(Round(TRBLIDER->DR+TRBLIDER->DP,2))	
	oSection2:Cell("LRELDIA" 	):SetValue(Round(TRBLIDER->DR,2))	
	oSection2:Cell("LADEDIA"  	):SetValue(Alltrim(Str(Round(TRBLIDER->DR/(TRBLIDER->DR+TRBLIDER->DP)*100,2)))+"%")	
	oSection2:Cell("LPLASEM"  	):SetValue(Round(TRBLIDER->SR+TRBLIDER->SP,2))	
	oSection2:Cell("LRELSEM" 	):SetValue(Round(TRBLIDER->SR,2))	
	oSection2:Cell("LADESEM"  	):SetValue(Alltrim(Str(Round(TRBLIDER->SR/(TRBLIDER->SR+TRBLIDER->SP)*100,2)))+"%")	
	oSection2:Cell("LPLAMES"  	):SetValue(Round(TRBLIDER->MR+TRBLIDER->MP,2))	
	oSection2:Cell("LRELMES" 	):SetValue(Round(TRBLIDER->MR,2))	
	oSection2:Cell("LADEMES"  	):SetValue(Alltrim(Str(Round(TRBLIDER->MR/(TRBLIDER->MR+TRBLIDER->MP)*100,2)))+"%")			
	oSection2:PrintLine()
	
	TRBLIDER->(dbSkip())

End

oSection2:Finish()

Return


//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function sessao3()

oSection3:Init()
TRBTEC->(dbGoTop())

While !TRBTEC->(EOF())
	oSection3:Cell("TECNICO"  	):SetValue(TRBTEC->TL_CODIGO)
//	oSection3:Cell("TTURNO"  	):SetValue(TRBLIDER->TJ_ZTURNO)   
	oSection3:Cell("TPLADIA"  	):SetValue(Round(TRBTEC->DR+TRBTEC->DP,2))	
	oSection3:Cell("TRELDIA" 	):SetValue(Round(TRBTEC->DR,2))	
	oSection3:Cell("TADEDIA"  	):SetValue(Alltrim(Str(Round(TRBTEC->DR/(TRBTEC->DR+TRBTEC->DP)*100,2)))+"%")	
	oSection3:Cell("TPLASEM"  	):SetValue(Round(TRBTEC->SR+TRBTEC->SP,2))	
	oSection3:Cell("TRELSEM" 	):SetValue(Round(TRBTEC->SR,2))	
	oSection3:Cell("TADESEM"  	):SetValue(Alltrim(Str(Round(TRBTEC->SR/(TRBTEC->SR+TRBTEC->SP)*100,2)))+"%")	
	oSection3:Cell("TPLAMES"  	):SetValue(Round(TRBTEC->MR+TRBTEC->MP,2))	
	oSection3:Cell("TRELMES" 	):SetValue(Round(TRBTEC->MR,2))	
	oSection3:Cell("TADEMES"  	):SetValue(Alltrim(Str(Round(TRBTEC->MR/(TRBTEC->MR+TRBTEC->MP)*100,2)))+"%")			
	oSection3:PrintLine()
	
	TRBTEC->(dbSkip())

End

oSection3:Finish()

Return

//------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery
Executa a query e cria o arquivo temporário para impressão do relatório 
	
@author Gislaine Sabino
@since 10/04/2015
@version 1.0

@return nil
/*/
//------------------------------------------------------------------   
Static Function AnalitQry()

If Select("TRB") <> 0
 DBSelectArea("TRB")
 DBCloseArea()
EndIf
   	                                                           
nSemana := Dow(MV_PAR01)   	
 
dIniSem := MV_PAR01+1-nSemana //
dFimSem := MV_PAR01+6-nSemana                           
If SubSTr(MV_PAR06,1,1) == 'Z'
	nLiderAte := 999999
Else
	nLiderAte := Val(MV_PAR06)
EndIf

cQuery := "DROP TABLE "+cTMPINF+" "
TcSqlExec(cQuery)
   	            
cQuery:="  	SELECT TL_DTINICI AS DT , TJ_DTMPINI, TJ_ZTURNO, TL_ORDEM, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, TL_TAREFA, TL_CODIGO, TL_XCONFIR, TJ_CODBEM "  

cQuery+="   INTO "+cTMPINF

cQuery+="   FROM " + RetSQLName("STJ") + " STJ  "
cQuery+="        INNER JOIN " + RetSQLName("STL") +" STL ON "
cQuery+="            STL.TL_FILIAL 	 = STJ.TJ_FILIAL "
cQuery+="            AND STL.TL_ORDEM = STJ.TJ_ORDEM "
cQuery+="            AND STL.TL_PLANO = STJ.TJ_PLANO "
cQuery+="            AND STL.TL_TIPOREG = 'M' "   
cQuery+="            AND STL.TL_CODIGO >= '"+MV_PAR03+"' "
cQuery+="            AND STL.TL_CODIGO <= '"+MV_PAR04+"' "
cQuery+="            AND STL.TL_QUANTID > 0 "   
cQuery+="            AND STL.D_E_L_E_T_ != '*' "
cQuery+="	WHERE 
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND SUBSTRING(STL.TL_DTINICI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"' "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="            and TJ_ZLIDER >= "+STR(Val(MV_PAR05))+" "
cQuery+="            AND TJ_ZLIDER <= "+STR(nLiderAte)+" "
cQuery+="	UNION "
cQuery+="   ( "
//busca as ordens que não tem apontamento de MO
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, TJ_ORDEM, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID,' ', ' ', '2', TJ_CODBEM "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"' "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "         
cQuery+="            and TJ_ZLIDER >= "+STR(Val(MV_PAR05))+" "
cQuery+="            AND TJ_ZLIDER <= "+STR(nLiderAte)+" "
cQuery+="	    EXCEPT "
cQuery+="    	SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, TL_ORDEM, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID,' ', ' ', '2', TJ_CODBEM "
cQuery+="       FROM " + RetSQLName("STJ") +" STJ  "
cQuery+="        	INNER JOIN " + RetSQLName("STL") +" STL ON "
cQuery+="            	STL.TL_FILIAL 	 = STJ.TJ_FILIAL "
cQuery+="           AND STL.TL_ORDEM = STJ.TJ_ORDEM "
cQuery+="           AND STL.TL_PLANO = STJ.TJ_PLANO  "
cQuery+="           AND STL.TL_TIPOREG = 'M'    "
cQuery+="            AND STL.TL_QUANTID > 0 "   
cQuery+="           AND STL.D_E_L_E_T_ != '*' "          
cQuery+="       WHERE "
cQuery+="           	STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="        	AND SUBSTRING(STL.TL_DTINICI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"' "
cQuery+="           AND STJ.D_E_L_E_T_ != '*'            
cQuery+="            and TJ_ZLIDER >= "+STR(Val(MV_PAR05))+" "
cQuery+="            AND TJ_ZLIDER <= "+STR(nLiderAte)+" "

cQuery+="	    )
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG,  TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula  COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001088] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL) AND (tecnico_matricula != ' ' OR  tecnico_matricula IS NULL)"
cQuery+="             AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001088] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada') 
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"' OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"') "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001088] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_matricula != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"') "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001089] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL ) AND (tecnico_matricula != ' ' OR  tecnico_matricula IS NULL)"
cQuery+="            AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001089] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada') "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT ,TJ_DTMPINI,  TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_matricula COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001089] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_matricula != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )
cQuery+="	UNION "
cQuery+="   ( "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_executor COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001062] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            (OS_STATUS != 'finalizada' OR OS_STATUS is NULL) AND tecnico_executor != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"') "
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "                                                                                       
cQuery+="            AND os_nos not in (select distinct os_nos from [FLUIG].[dbo].[ML001062] TAB where STL.os_nos = TAB.os_nos AND OS_STATUS = 'finalizada') "
cQuery+="	    EXCEPT "
cQuery+="	    SELECT TJ_DTPRINI AS DT , TJ_DTMPINI, TJ_ZTURNO, os_nos COLLATE Latin1_General_BIN, TJ_XNUMFLG, TJ_ZLIDER, TJ_XNEGLID, ' ', tecnico_executor COLLATE Latin1_General_BIN, '2', TJ_CODBEM  "
cQuery+="	    FROM " + RetSQLName("STJ") +" STJ  " 
cQuery+="	      	INNER JOIN [FLUIG].[dbo].[ML001062] STL ON "
cQuery+="	            STJ.TJ_ORDEM COLLATE Latin1_General_CI_AS = os_nos COLLATE Latin1_General_CI_AS AND "
cQuery+="	            OS_STATUS = 'finalizada' AND tecnico_executor != ' ' "
cQuery+="       WHERE "
cQuery+="            STJ.TJ_FILIAL = '"+xFilial('STJ')+"' AND STJ.TJ_XPLANEJ = '1' "
cQuery+="            AND (SUBSTRING(STJ.TJ_DTPRINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"'  OR SUBSTRING(STJ.TJ_DTMPINI,1,6) = '"+SubStr(DtoS(MV_PAR01),1,6)+"')"
cQuery+="            AND STJ.D_E_L_E_T_ != '*' "
cQuery+="	    )


TcSqlExec(cQuery)


cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT " 
cQuery += " FROM "+cTMPINF
cQuery += " GROUP BY"
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBMES"

cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT"
cQuery += " FROM "+cTMPINF
cQuery += " WHERE DT = '"+DtoS(MV_PAR01)+"' "
cQuery += " GROUP BY"
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBDIA"

cQuery := " SELECT TJ_ZTURNO, TL_XCONFIR, COUNT(*) AS TOT "
cQuery += " FROM "+cTMPINF
cQuery += " WHERE DT >= '"+DtoS(dIniSem)+"' AND DT <= '"+DtoS(dFimSem)+"' "
cQuery += " GROUP BY "
cQuery += "   TJ_ZTURNO, TL_XCONFIR "

cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBSEM"


cQuery := " SELECT DT, TJ_DTMPINI, TJ_ZLIDER,  TJ_ZTURNO, CAST(TL_ORDEM as varchar(10)) AS TJ_ORDEM, TJ_XNUMFLG, TJ_CODBEM,  TL_XCONFIR FROM (
cQuery += " SELECT DISTINCT DT, TJ_DTMPINI, TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, TJ_XNUMFLG, TJ_CODBEM, CASE TL_XCONFIR WHEN '1' THEN 'SIM' ELSE 'NAO' END AS TL_XCONFIR " 
cQuery += " FROM "+cTMPINF 
cQuery += " WHERE "
cQuery += "                TJ_ZLIDER >= "+Str(Val(MV_PAR05))+" "
cQuery += "            AND TJ_ZLIDER <= "+STR(nLiderAte)+" AND TJ_XNEGLID != '1' " 
cQuery += " UNION "  
cQuery += " SELECT DISTINCT DT, TJ_DTMPINI, TJ_ZLIDER,  TJ_ZTURNO, TL_ORDEM, TJ_XNUMFLG, TJ_CODBEM, 'NAO'  " 
cQuery += " FROM "+cTMPINF 
cQuery += " WHERE "
cQuery += "                TJ_ZLIDER >= "+Str(Val(MV_PAR05))+" "
cQuery += "            AND TJ_ZLIDER <= "+STR(nLiderAte)+" AND TJ_XNEGLID = '1' " 
cQuery += " ) T "
cQuery += " ORDER BY TJ_ZLIDER, DT "
        
TCQuery cQuery NEW ALIAS "TRBLIDER"                                 

cQuery := " SELECT DT, TJ_DTMPINI, RTRIM(CAST(TL_CODIGO as varchar(15))) +' - '+RA_NOME AS TL_CODIGO,  TJ_ZTURNO, CAST(TL_ORDEM as varchar(10)) AS TL_ORDEM, TJ_XNUMFLG, TJ_CODBEM AS TJ_CODBEM,CASE TL_XCONFIR WHEN '1' THEN 'SIM' ELSE 'NAO' END AS TL_XCONFIR " 
cQuery += " FROM "+cTMPINF 
cQuery += " LEFT OUTER JOIN "+RetSqlName('SRA')+" SRA ON "
cQuery += " 	 RA_FILIAL = '"+xFilial('SRA')+"' AND RTRIM(RA_MAT) = RTRIM(TL_CODIGO) AND SRA.D_E_L_E_T_ != '*' "
cQuery += " WHERE "
cQuery+="                TL_CODIGO >= '"+MV_PAR03+"' "
cQuery+="            AND TL_CODIGO <= '"+MV_PAR04+"' "
cQuery+="            and TJ_ZLIDER >= "+STR(Val(MV_PAR05))+" "
cQuery+="            AND TJ_ZLIDER <= "+STR(nLiderAte)+" "
cQuery+=" ORDER BY TL_CODIGO, DT "

//cQuery := changequery(cQuery)
        
TCQuery cQuery NEW ALIAS "TRBTEC"                                 


//select * from [FLUIG].[dbo][ML001089] WHERE os_processo = '19150'
//ML001088
//ML001062



Return
                              
//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function AnSessao2()

oSection4:Init()   
DbSelectArea("TRBLIDER")
TRBLIDER->(dbGoTop())
oSection1:Init()
While (!TRBLIDER->(EOF()))

	nPos := Ascan(aFluigUsers,{|x|x[1]==StrZero(TRBLIDER->TJ_ZLIDER,6)})
	If nPos > 0
		cLider := StrZero(TRBLIDER->TJ_ZLIDER,6)+" - "+aFluigUsers[nPos][2]
	Else
		cLider := StrZero(TRBLIDER->TJ_ZLIDER,6)+" - "	
	Endif

	oSection4:Cell("4LIDER"  	):SetValue(cLider)   
	If !Empty(Alltrim(TRBLIDER->DT))
		oSection4:Cell("4DATAOS"  	):SetValue(StoD(TRBLIDER->DT))	   
	Else
		oSection4:Cell("4DATAOS"  	):SetValue(StoD(TRBLIDER->TJ_DTMPINI))	   
	EndIf
	oSection4:Cell("4LTURNO"  	):SetValue(TRBLIDER->TJ_ZTURNO)   	
	oSection4:Cell("4LORDEM"  	):SetValue(TRBLIDER->TJ_ORDEM)   
	oSection4:Cell("4LFLUIG"  	):SetValue(TRBLIDER->TJ_XNUMFLG)   
	oSection4:Cell("4LBEM"  	):SetValue(TRBLIDER->TJ_CODBEM)   
	oSection4:Cell("4LPLADIA"  	):SetValue(TRBLIDER->TL_XCONFIR)	

	oSection4:PrintLine()
	
	TRBLIDER->(dbSkip())

End

oSection4:Finish()

Return


//------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Perguntas do relatório
	
@since 26/10/2016
@version 1.0

@return 
/*/
//------------------------------------------------------------------   
Static function AnSessao3()

oSection5:Init()
TRBTEC->(dbGoTop())

While !TRBTEC->(EOF())
	oSection5:Cell("5LIDER"  	):SetValue(TRBTEC->TL_CODIGO)
	If !Empty(Alltrim(TRBTEC->DT))
		oSection5:Cell("5DATAOS"  	):SetValue(StoD(TRBTEC->DT))	 
	Else
		oSection5:Cell("5DATAOS"  	):SetValue(StoD(TRBTEC->TJ_DTMPINI))	
	EndIf
	oSection5:Cell("5TTURNO"  	):SetValue(TRBTEC->TJ_ZTURNO) 	   
	oSection5:Cell("5TORDEM"  	):SetValue(TRBTEC->TL_ORDEM)   	  	
	oSection5:Cell("5TFLUIG"  	):SetValue(TRBLIDER->TJ_XNUMFLG)	
	oSection5:Cell("5TBEM"  	):SetValue(TRBTEC->TJ_CODBEM)	
	oSection5:Cell("5TPLADIA"  	):SetValue(TRBTEC->TL_XCONFIR)	

	oSection5:PrintLine()
	
	TRBTEC->(dbSkip())

End

oSection5:Finish()

Return

                                               
#include 'protheus.ch'


/*/{Protheus.doc} cpFluigUsers
Consulta padrão para usuarios do fluig

@author Rafael Ricardo Vieceli
@since 13/07/2015
@version 1.0
@param cPapel, character, ID do papel para filtrar apenas usuario que estão no papel
@return lRet, lógico, Se confirmar ou cancelou a consulta
@example

	FluigUsers("lider_turno_manutencao") -> filtra usuarios do papel lider_turno_manutencao
/*/
Static Function FluigUsers(cPapel)

	aFluigUsers := {}

	IF !u_FluigTstConn()
		Return
	EndIF

	//busca os usuarios
	aFluigUsers := GetFluigUsers(cPapel)

	
Return 


/*/{Protheus.doc} GetFluigUsers
Busca os usuarios do Fluig, e caso necessario filtro por papel

@author Rafael Ricardo Vieceli
@since 13/07/2015
@version 1.0
@param cPapel, character, (Descrição do parâmetro)
@return aFluigUsers, array, Lista com os usuarios do Fluig
/*/
Static Function GetFluigUsers(cPapel)

	local cUsrProtheus := 'protheus'
	local cPwdProtheus := 'protheus'

	Local nCompanyId := 1
	Local aFluigUsers := {}

	Local n1
	Local cPapeis := ""

	Private oWs

	//se vier papel
	IF !Empty(cPapel)

		//serviço de datasets
		oWs := uWSECMDatasetServiceService():New()

		//traz apenas a coluna com codigo do usuario
		aAdd(oWs:oWSgetDatasetFields:cItem, "colleagueId")

		//filtros
		//empresa
		aAdd(oWs:oWSgetDatasetConstraints:oWSitem, uECMDatasetServiceService_searchConstraintDto():New())
		oWs:oWSgetDatasetConstraints:oWSitem[1]:cContraintType := "MUST"
		oWs:oWSgetDatasetConstraints:oWSitem[1]:cFieldName     := "companyId"
		oWs:oWSgetDatasetConstraints:oWSitem[1]:cInitialValue  := cValToChar(nCompanyId)
		oWs:oWSgetDatasetConstraints:oWSitem[1]:cFinalValue    := cValToChar(nCompanyId)
		//papel
		aAdd(oWs:oWSgetDatasetConstraints:oWSitem, uECMDatasetServiceService_searchConstraintDto():New())
		oWs:oWSgetDatasetConstraints:oWSitem[2]:cContraintType := "MUST"
		oWs:oWSgetDatasetConstraints:oWSitem[2]:cFieldName     := "roleId"
		oWs:oWSgetDatasetConstraints:oWSitem[2]:cInitialValue  := cPapel
		oWs:oWSgetDatasetConstraints:oWSitem[2]:cFinalValue    := cPapel

		//ordena pelo codigo do usuario
		aAdd(oWs:oWSgetDatasetOrder:cItem, "colleagueId")

		//consulta o dataset via webservice
		oWs:getDataset(nCompanyId, cUsrProtheus, cPwdProtheus, "workflowColleagueRole")
		//percore todos
		For n1 := 1 to len(oWs:oWSgetDatasetDataset:oWsValues)
			//pegando o codigo dos usuarios
			cPapeis += "#"+oWs:oWSgetDatasetDataset:oWsValues[n1]:oWsValue[1]:TEXT+"#"
		Next n1
	EndIF

	oWs := uWSECMColleagueServiceService():New()
	oWs:getSummaryColleagues(nCompanyId)

	For n1 := 1 to len(oWs:oWsGetSummaryColleaguesResult:oWsItem)

		//se o usuario estiver ativo
		IF oWs:oWsGetSummaryColleaguesResult:oWsItem[n1]:lActive
			//se filtrar papel, pula os usuarios que não estão no papel
			IF !Empty(cPapel) .And. !oWs:oWsGetSummaryColleaguesResult:oWsItem[n1]:cColleagueId $ cPapeis
				Loop
			EndIF

			//adiciona na lista
			aAdd( aFluigUsers, {;
				oWs:oWsGetSummaryColleaguesResult:oWsItem[n1]:cColleagueId ,;
				oWs:oWsGetSummaryColleaguesResult:oWsItem[n1]:cColleagueName })
		EndIF
	Next n1

	//ordena por codigo de usuario
	aSort(aFluigUsers,,,{|x,y|x[1]<y[1]})

Return aFluigUsers

