#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

// Relatório de Inconsistências no intervalo de HORA EXTRA.


User Function HELINTHE()
Local cPerg 	:= "RELINTHE"
Local cSql		:= ""
Local oReport	:= ""
Private _aRet	:= {}

//AjustaSX1(cPerg)

If !Pergunte(cPerg)
	Return
Endif

cSql := " SELECT PH_FILIAL, PH_MAT, PH_DATA, SUM(PH_QUANTC) PH_QUANTC,  PH_CC, RA_NOME  FROM " + RetSqlName("SPH") + " SPH  "
cSql += " INNER JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = '" + xFilial("SRA") + "' 	"
cSql += " AND RA_MAT = PH_MAT AND SRA.D_E_L_E_T_ = ' ' 										"
cSql += " WHERE 																			"
cSql += " PH_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'						"
cSql += " AND PH_MAT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' 						"
cSql += " AND PH_CC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' 						" 
cSql += " AND PH_DATA BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' 		"
cSql += " AND LTRIM(RTRIM(PH_PD)) IN ('106','107','109','113','210') 						"
cSql += " AND SPH.D_E_L_E_T_ = ' ' 															"
cSql += " GROUP BY PH_FILIAL, PH_MAT, PH_DATA, PH_CC, RA_NOME 								"

If Select("XSP8") > 0
	XSP8->(DbCloseArea())
Endif

TcQuery cSql new alias "XSP8"

If !XSP8->(Eof())
	Processa({|| Seleciona() },"Totvs","Aguarde selecionando registros")
	If Len(_aRet) > 0
		oReport := reportDef()
		oReport:printDialog()
	Else
		MsgInfo("Não foram encontradas inconsistências")
	Endif
Else
	Alert ("Não há regisros nos parâmetros selecionados")
Endif

Return

// Seleciona os registros para o relatório

Static Function Seleciona()
Local nCount 	:= Contar("XSP8","!EOF()")
Local nAp1		:= nAp2 := nAp3 := nAp4	:= 0
Local cSqlApt	:= ""
Local cIncon	:= ""
Local cDifTempo	:= ""

ProcRegua(nCount)
XSP8->(DbGoTop())

While !XSP8->(Eof())

	If XSP8->PH_QUANTC >= 2
		aAdd(_aRet,{;
				STOD(XSP8->PH_DATA),;
			  	XSP8->PH_MAT,; 
			  	XSP8->PH_CC,;	
			  	XSP8->RA_NOME,;
			  	XSP8->PH_QUANTC,;
			  	})
	Endif
	XSP8->(DbSkip())
	IncProc()
	
End

Return 

// Formata a horas numericas centesimais como 
// caracter sexagenal
Static Function TrataHora(nApt)
Local nHor	:= 0
Local nMin	:= 0
Local aApt	:= {}
Local cRet	:= ""

aApt := Separa(cValTochar(nApt),".")

If Len(aApt) >= 2
	nHor := Val(aApt[1])
	nMin := Val(aApt[2])
Endif
	
If nMin > 0
	nMin := ROUND(nMin * 60 / 100,0)
Endif

cRet := StrZero(nHor,2) + ":" + StrZero(nMin,2)

Return cRet
 
// Função para criação das perguntas

/*Static Function AjustaSx1(cPerg)
Local aAreaSx1	:= SX1->(GetArea())
SX1->(DbSetOrder(1))
cPerg := PADR(UPPER(cPerg),10)

If !SX1->(DbSeek(cPerg))

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"01"
	SX1->X1_PERGUNT	:= "Filial de"
	SX1->X1_PERSPA	:= "Filial de"
	SX1->X1_PERENG	:= "Filial de"
	SX1->X1_VARIAVL	:= "MV_CH1"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= Len(xFilial())
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR01"
	SX1->X1_F3		:= "SM0" 
	SX1->(MsUnlock())

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"02"
	SX1->X1_PERGUNT	:= "Filial ate"
	SX1->X1_PERSPA	:= "Filial ate"
	SX1->X1_PERENG	:= "Filial ate"
	SX1->X1_VARIAVL	:= "MV_CH2"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= Len(xFilial())
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR02"
	SX1->X1_F3		:= "SM0" 
	SX1->(MsUnlock())


	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"03"
	SX1->X1_PERGUNT	:= "Mat de"
	SX1->X1_PERSPA	:= "Mat de"
	SX1->X1_PERENG	:= "Mat de"
	SX1->X1_VARIAVL	:= "MV_CH3"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("RA_MAT")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR03"
	SX1->X1_F3		:= "SRA" 
	SX1->(MsUnlock())

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"04"
	SX1->X1_PERGUNT	:= "Mat ate"
	SX1->X1_PERSPA	:= "Mat ate"
	SX1->X1_PERENG	:= "Mat ate"
	SX1->X1_VARIAVL	:= "MV_CH4"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("RA_MAT")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR04"
	SX1->X1_F3		:= "SRA" 
	SX1->(MsUnlock())


	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"05"
	SX1->X1_PERGUNT	:= "C.C de"
	SX1->X1_PERSPA	:= "C.C de"
	SX1->X1_PERENG	:= "C.C de"
	SX1->X1_VARIAVL	:= "MV_CH5"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("P8_CC")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR05"
	SX1->X1_F3		:= "CTT" 
	SX1->(MsUnlock())

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"06"
	SX1->X1_PERGUNT	:= "C.C ate"
	SX1->X1_PERSPA	:= "C.C ate"
	SX1->X1_PERENG	:= "C.C ate"
	SX1->X1_VARIAVL	:= "MV_CH6"
	SX1->X1_TIPO	:= "C"
	SX1->X1_TAMANHO	:= TamSx3("P8_CC")[1]
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR06"
	SX1->X1_F3		:= "CTT"
	SX1->(MsUnlock())

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"07"
	SX1->X1_PERGUNT	:= "Data de"
	SX1->X1_PERSPA	:= "Data de"
	SX1->X1_PERENG	:= "Data de"
	SX1->X1_VARIAVL	:= "MV_CH7"
	SX1->X1_TIPO	:= "D"
	SX1->X1_TAMANHO	:= 8
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR07"
	SX1->(MsUnlock())

	RecLock("SX1",.T.)
	SX1->X1_GRUPO 	:= 	cPerg
	SX1->X1_ORDEM	:=	"08"
	SX1->X1_PERGUNT	:= "Data ate"
	SX1->X1_PERSPA	:= "Data ate"
	SX1->X1_PERENG	:= "Data ate"
	SX1->X1_VARIAVL	:= "MV_CH8"
	SX1->X1_TIPO	:= "D"
	SX1->X1_TAMANHO	:= 8
	SX1->X1_DECIMAL	:= 0
	SX1->X1_PRESEL	:= 0
	SX1->X1_GSC		:= "G"
	SX1->X1_VALID	:= ""
	SX1->X1_VAR01	:= "MV_PAR08"
	SX1->(MsUnlock())


Endif

RestArea(aAreaSX1)


Return*/


//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef()

local cTitle  := "Relatório de Intervalo de H.Extras"
local cHelp   := "Gera o Relatório de Intervalo de H.Extras."

local oReport
local oSection1
local oBreak1

oReport	:= TReport():New('RELINTHE',cTitle,,{|oReport|ReportPrint(oReport)},cHelp)
oReport:SetLandScape()

// Primeira seção
oSection1:= TRSection():New(oReport,cTitle,{"SPH"})
oSection1:SetLeftMargin(2)  
/*
AADD(aCabExcel, {"Data" 				,"D", 8, 0})
AADD(aCabExcel, {"Matricula" 			,"C", TamSx3("P8_MAT")[1]	, 0})
AADD(aCabExcel, {"Centro de Custo" 		,"C", TamSx3("P8_CC")[1]	, 0})
AADD(aCabExcel, {"Nome" 				,"C", TamSx3("RA_NOME")[1]	, 0})
AADD(aCabExcel, {"1 Entrada" 			,"C", 8, 0})
AADD(aCabExcel, {"1 Saida" 				,"C", 8, 0})
AADD(aCabExcel, {"2 Entrada" 			,"C", 8, 0})
AADD(aCabExcel, {"2 Saida" 				,"C", 8, 0})
AADD(aCabExcel, {"Inconsistencia"      , "C", 40, 0})
*/

TRCell():New(oSection1,"PH_DATA"		, "SPH" , "Data")
TRCell():New(oSection1,"PH_MAT"			, "SPH" , "Matrícula")
TRCell():New(oSection1,"PH_CC"			, "SPH" , "C.Custo")
TRCell():New(oSection1,"RA_NOME"		, "SRA" , "Nome")
TRCell():New(oSection1,"PH_QUANTC"		, "SPH", "Hora Extra"	)

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  				  !
//+-----------------------------------------------------------------------------------------------+

Static Function ReportPrint(oReport)

local oSection1b 	:= oReport:Section(1)
Local nX			:= 0
oReport:SetMeter(Len(_aRet))	

oSection1b:Init() 

For nX := 1 To Len(_aRet)
	oSection1b:Cell("PH_DATA"):SetBlock({|| _aRet[nX][1]}) 
	oSection1b:Cell("PH_MAT"):SetBlock({|| _aRet[nX][2]}) 
	oSection1b:Cell("PH_CC"):SetBlock({|| _aRet[nX][3]}) 
	oSection1b:Cell("RA_NOME"):SetBlock({|| _aRet[nX][4]}) 
	oSection1b:Cell("PH_QUANTC"):SetBlock({|| _aRet[nX][5]}) 
	oSection1b:PrintLine()
	oReport:IncMeter()
Next nX

oSection1b:Finish() 

Return
