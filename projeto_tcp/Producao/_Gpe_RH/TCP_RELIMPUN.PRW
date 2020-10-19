#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPrograma ³RELIMPUN  º Autor ³ Eduardo Vieira           º Data ³  27/09/18      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TRELATORIO de importação de co-participação da unimed   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


User function RELIMPUN(cCodImp)

local oReport
local cPerg  := "RELIMPUN"
local cAlias := getNextAlias()

private oSection1  

criaSx1(cPerg)
Pergunte(cPerg, .F.)
if(!empty(cCodImp))
	mv_par01 := ''
	mv_par02 := ''
	mv_par03 := ''
	mv_par04 := ''
	mv_par05 := STOD('        ')
	mv_par06 := STOD('        ')
	mv_par07 := cCodImp
	mv_par08 := ''
endif

oReport := reportDef(cAlias, cPerg)

oReport:PrintDialog()

return

//+-----------------------------------------------------------------------------------------------+
//! Funcao para criação da estrutura do relatorio                                                 !
//+-----------------------------------------------------------------------------------------------+ 

Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório de análise de estoque"
local cHelp   := "Permite gerar relatorio das movimentações e quantidades de estoque dos produtos de um determinado período."
local oBreak1
local oBreak2
local oReport

oReport	:= TReport():New("RELIMPUN",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//oReport:oPage:SetPaperSize(3) // seleciona Impressao papel A4  
//oReport:SetPortrait(.T.)
//oReport:SetTotalInLine(.F.)  

//Primeira seção
//TRCell():New(oSection1,"201908", "ZP9", "201908",X3PICTURE("ZP9_QTDSAI"),20,,,,,"")
oSection1 := TRSection():New(oReport,"Relatório de importação de coparticiação Unimed",{"ZZM"})
TRCell():New(oSection1,"ZZM_FILIAL","cAlias", "Filial",X3PICTURE("ZZM_FILIAL"),20,,,,,"")
TRCell():New(oSection1,"ZZM_CODIGO","cAlias", "Código Imp",X3PICTURE("ZZM_CODIGO"),20,,,,,"")
TRCell():New(oSection1,"ZZM_DATA"  ,"cAlias", "Data Imp",X3PICTURE("ZZM_DATA"  ),20,,,,,"")
TRCell():New(oSection1,"ZZM_HORA"  ,"cAlias", "Hora Imp",X3PICTURE("ZZM_HORA"  ),20,,,,,"")
TRCell():New(oSection1,"ZZM_PERIOD","cAlias", "Período",X3PICTURE("ZZM_PERIOD"),20,,,,,"")
TRCell():New(oSection1,"ZZM_ANO"   ,"cAlias", "Ano",X3PICTURE("ZZM_ANO"   ),20,,,,,"")
TRCell():New(oSection1,"ZZM_PREST" ,"cAlias", "Prestador",X3PICTURE("ZZM_PREST" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_ATEND" ,"cAlias", "Atendimento",X3PICTURE("ZZM_ATEND" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_DTATEN","cAlias", "Data Atendimento",X3PICTURE("ZZM_DTATEN"),20,,,,,"")
TRCell():New(oSection1,"ZZM_TITUL" ,"cAlias", "Titular",X3PICTURE("ZZM_TITUL" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_BENEF" ,"cAlias", "Beneficiário",X3PICTURE("ZZM_BENEF" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_MATRIC","cAlias", "Matrícula",X3PICTURE("ZZM_MATRIC"),20,,,,,"")
TRCell():New(oSection1,"ZZM_CODEXA","cAlias", "Cód Exame",X3PICTURE("ZZM_CODEXA"),20,,,,,"")
TRCell():New(oSection1,"ZZM_VALOR" ,"cAlias", "Valor",X3PICTURE("ZZM_VALOR" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_MAT"   ,"cAlias", "Matrícula Protheus",X3PICTURE("ZZM_MAT"   ),20,,,,,"")
TRCell():New(oSection1,"ZZM_IMP"   ,"cAlias", "Importado?",X3PICTURE("ZZM_IMP"   ),20,,,,,"")
TRCell():New(oSection1,"ZZM_ARQUIV","cAlias", "Arquivo",X3PICTURE("ZZM_ARQUIV"),20,,,,,"")
TRCell():New(oSection1,"ZZM_LINHA" ,"cAlias", "Linha",X3PICTURE("ZZM_LINHA" ),20,,,,,"")
TRCell():New(oSection1,"ZZM_USU"   ,"cAlias", "Usuário",X3PICTURE("ZZM_USU"   ),20,,,,,"")
TRCell():New(oSection1,"ZZM_ERRO"  ,"cAlias", "Erro",X3PICTURE("ZZM_ERRO"  ),20,,,,,"")
TRCell():New(oSection1,"ZZM_PARC"  ,"cAlias", "Qtd Parcelas",X3PICTURE("ZZM_PARC"  ),20,,,,,"")

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatorio.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

local oSecao1 := oReport:Section(1)
Local cWhere :=  '%'
Local cWhere2 :=  '%'


IF(!EMPTY(mv_par01))
	cWhere += " AND ZZM_FILIAL >= '"+mv_par01+"'"
ENDIF
IF(!EMPTY(mv_par02))
	cWhere += " AND ZZM_FILIAL <= '"+mv_par02+"'"
ENDIF

IF(!EMPTY(mv_par03))
	cWhere += " AND ZZM_MAT >= '"+mv_par03+"'"
ENDIF
IF(!EMPTY(mv_par04))
	cWhere += " AND ZZM_MAT <= '"+mv_par04+"'"
ENDIF

IF(!EMPTY(mv_par05))
	cWhere += " AND ZZM_DTATEN >= '"+DTOS(mv_par05)+"'"
ENDIF
IF(!EMPTY(mv_par06))
	cWhere += " AND ZZM_DTATEN <= '"+DTOS(mv_par06)+"'"
ENDIF

IF(!EMPTY(mv_par07))
	cWhere += " AND ZZM_CODIGO >= '"+mv_par07+"'"
ENDIF
IF(!EMPTY(mv_par08))
	cWhere += " AND ZZM_CODIGO <= '"+mv_par08+"'"
ENDIF


cWhere += '%'

oSection1:BeginQuery()

BeginSQL Alias cAlias	
 
 SELECT ZZM.*, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZZM_ERRO)) FROM %Table:ZZM% ZZM
 WHERE ZZM.%NotDel% AND 1=1 %EXP:cWhere%
	
EndSQL 

//conout(getlastquery()[2])

oSection1:EndQuery()

oReport:SetMeter((cAlias)->(RecCount()))

oSection1:Print()	

oSection1:Finish() 
	
return


//+-----------------------------------------------------------------------------------------------+
//! Funcao para criacao das perguntas (se nao existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
Static function criaSX1(cPerg)
Local aRegs := {}
	
	aAdd(aRegs,{cPerg, "01", "Filial de"  , "Filial de"  ,"Filial de"  , "mv_ch1", "C", 2, 0, 0, "G", "", "mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg, "02", "Filial ate" , "Filial ate" ,"Filial ate" , "mv_ch2", "C", 2, 0, 0, "G", "", "mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg, "03", "Matrícula de"  , "Matrícula de"  ,"Matrícula de"  , "mv_ch3", "C", 6, 0, 0, "G", "", "mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	aAdd(aRegs,{cPerg, "04", "Matrícula ate" , "Matrícula ate" ,"Matrícula" , "mv_ch4", "C", 6, 0, 0, "G", "", "mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	aAdd(aRegs,{cPerg, "05", "Data de"  , "Data de"  ,"Data de"  , "mv_ch5", "D", 8, 0, 0, "G", "", "mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "06", "Data ate" , "Data ate" ,"Data ate" , "mv_ch6", "D", 8, 0, 0, "G", "", "mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "07", "Codigo Imp de"  , "Codigo Imp de"  ,"Codigo Imp de"  , "mv_ch7", "C", 6, 0, 0, "G", "", "mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg, "08", "Codigo Imp ate" , "Codigo Imp ate" ,"Codigo Imp ate" , "mv_ch8", "C", 6, 0, 0, "G", "", "mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	
	
	U_BuscaPerg(aRegs)
return