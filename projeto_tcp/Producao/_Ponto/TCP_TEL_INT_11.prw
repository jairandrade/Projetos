#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

// Relat�rio de Inconsist�ncias no intervalo 11 horas.
// Elias 26/01/18

User Function RELINTACU()
Local cPerg 	:= "RELINT11AC"
Local cSql		:= ""
Local oReport	:= ""
Private _aRet	:= {}

//AjustaSX1(cPerg)

If !Pergunte(cPerg)
	Return
Endif

cSql := " SELECT PG_FILIAL, PG_MAT, PG_DATA, PG_HORA,  PG_CC, PG_ORDEM, RA_NOME  FROM " + RetSqlName("SPG") + " SPG  "
cSql += " INNER JOIN " + RetSqlName("SRA") + " SRA ON RA_FILIAL = '" + xFilial("SRA") + "' "
cSql += " AND RA_MAT = PG_MAT AND SRA.D_E_L_E_T_ = ' ' "
cSql += " WHERE "
cSql += " PG_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cSql += " AND PG_MAT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSql += " AND PG_CC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 
cSql += " AND PG_DATA BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
cSql += " AND LTRIM(RTRIM(PG_TPMARCA)) = '1E' "
cSql += " AND SPG.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY PG_DATA, PG_MAT "

Memowrite("c:\temp\RELINT11_SQL_1.SQL",cSql)

If Select("XSPG") > 0
	XSPG->(DbCloseArea())
Endif

TcQuery cSql new alias "XSPG"

If !XSPG->(Eof())
	Processa({|| Seleciona() },"Totvs","Aguarde selecionando registros")
	If Len(_aRet) > 0
		oReport := reportDef()
		oReport:printDialog()
	Else
		MsgInfo("N�o foram encontradas inconsist�ncias")
	Endif
Else
	Alert ("N�o h� regisros nos par�metros selecionados")
Endif

Return

// Seleciona os registros para o relat�rio
// Elias - 26/01/18
Static Function Seleciona()
Local nCount 	:= Contar("XSPG","!EOF()")
Local nAp1		:= nAp2 := 0
Local dAp1		:= dAp2	:= CTOD("  /  /  ")
Local cSqlApt	:= ""
Local cIncon	:= ""
Local nDifTempo	:= 0

ProcRegua(nCount)
XSPG->(DbGoTop())

While !XSPG->(Eof())

	If Select("XAPT1") > 0
		XAPT1->(DbCloseArea())
	Endif

	If Select("XAPT2") > 0
		XAPT2->(DbCloseArea())
	Endif
	
	nAp1		:= nAp2 :=  0
	dAp1		:= dAp2	:= CTOD("  /  /  ")
	cIncon		:= ""
	nDifTempo	:= 0
	
	// Ultima Saida do dia
	cSqlApt := " SELECT TOP 1 PG_MAT, PG_DATA, PG_HORA, PG_TPMARCA 	"
	cSqlApt += " FROM " + RetSqlName("SPG") + " SPG 				"
	cSqlApt += " WHERE												"
	cSqlApt	+= " PG_FILIAL = '" + XSPG->PG_FILIAL + "'				" 
	cSqlApt += " AND PG_MAT = '" + XSPG->PG_MAT 	+ "'			"
	cSqlApt	+= " AND PG_DATA >= '" + XSPG->PG_DATA 	+ "'			"
	cSqlApt += " AND PG_DATA <= '" + DTOS(MV_PAR08) + "'			"
	cSqlApt += " AND PG_ORDEM = '" + XSPG->PG_ORDEM +"'				"	
	cSqlApt	+= " AND SUBSTRING(PG_TPMARCA,2,1) = 'S'				"
	cSqlApt += " AND SPG.D_E_L_E_T_ = ' ' 							"
	cSqlApt += " ORDER BY PG_TPMARCA DESC							"		
	
	Memowrite("c:\temp\RELINT11_SQL_2.SQL",cSqlApt) 
	
	TcQuery cSqlApt new Alias "XAPT1"
	
	If !XAPT1->(Eof())
	
		nAp1 	:= XAPT1->PG_HORA
		dAp1	:= STOD(XAPT1->PG_DATA)

		// Primeira Entrada do dia seguinte
		cSqlApt := " SELECT TOP 1 PG_MAT, PG_DATA, PG_HORA, PG_TPMARCA 			"
		cSqlApt += " FROM " + RetSqlName("SPG") + " SPG 						"
		cSqlApt += " WHERE														"
		cSqlApt	+= " PG_FILIAL = '" + XSPG->PG_FILIAL 		+ "'				" 
		cSqlApt += " AND PG_MAT = '" + XSPG->PG_MAT 		+ "'				"
		cSqlApt	+= " AND PG_DATA >= '" + XSPG->PG_DATA 		+ "'				"
		cSqlApt += " AND PG_DATA <= '" + DTOS(MV_PAR08) 	+ "'				"		
		cSqlApt	+= " AND PG_ORDEM <> '" + XSPG->PG_ORDEM 	+ "'				"	
		cSqlApt += " AND LTRIM(RTRIM(PG_TPMARCA)) = '1E'						"	
		cSqlApt += " AND SPG.D_E_L_E_T_ = ' ' 									"
		
		Memowrite("c:\temp\RELINT11_SQL_3.SQL",cSqlApt)								 
	
		TcQuery cSqlApt new Alias "XAPT2"
	
		If !XAPT2->(Eof())
			nAp2 	:= XAPT2->PG_HORA
			dAp2	:= STOD(XAPT2->PG_DATA)
	
			nDifTempo	:= InTempo(dAp1, TraTaHora(nAp1), dAp2, TrataHora(nAp2))
			
			If nDifTempo  < 11
				cIncon := "Intervalo inferior a 11 horaS"
			Endif
			
			
			If !Empty(cIncon) .and. !(nAp1 == 0 .and. nAp2 == 0)
				aAdd(_aRet,{;
						STOD(XSPG->PG_DATA),;
					  	XSPG->PG_MAT,; 
					  	XSPG->PG_CC,;	
					  	XSPG->RA_NOME,;
					  	dAp1,;
					  	TrataHora(nAp1),;
					  	dAp2,;
					  	TrataHora(nAp2),;
					  	cIncon})
			Endif
	
		Endif


	Endif
	

	XAPT1->(DbCloseArea())
	
	If Select("XAPT2") > 0
		XAPT2->(DbCloseArea())
	Endif
	
	XSPG->(DbSkip())
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
Else
	nHor := nApt
Endif
	
/*If nMin > 0
	nMin := ROUND(nMin * 60 / 100,0)
Endif*/

cRet := StrZero(nHor,2) + ":" + StrZero(nMin,2)

Return cRet

 // Fun��o para cria��o das perguntas
// Elias 30/01/2018
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
	SX1->X1_TAMANHO	:= TamSx3("PG_CC")[1]
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
	SX1->X1_TAMANHO	:= TamSx3("PG_CC")[1]
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
//! Fun��o para cria��o da estrutura do relat�rio.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef()

local cTitle  := "Relat�rio de Intervalo de 11 Horas"
local cHelp   := "Gera o Relat�rio de Intervalo de 11 Horas."

local oReport
local oSection1
local oBreak1

oReport	:= TReport():New('RELINT11',cTitle,,{|oReport|ReportPrint(oReport)},cHelp)
oReport:SetLandScape()

// Primeira se��o
oSection1:= TRSection():New(oReport,cTitle,{"SPG"})
oSection1:SetLeftMargin(2)  
/*
AADD(aCabExcel, {"Data" 				,"D", 8, 0})
AADD(aCabExcel, {"Matricula" 			,"C", TamSx3("PG_MAT")[1]	, 0})
AADD(aCabExcel, {"Centro de Custo" 		,"C", TamSx3("PG_CC")[1]	, 0})
AADD(aCabExcel, {"Nome" 				,"C", TamSx3("RA_NOME")[1]	, 0})
AADD(aCabExcel, {"1 Entrada" 			,"C", 8, 0})
AADD(aCabExcel, {"1 Saida" 				,"C", 8, 0})
AADD(aCabExcel, {"2 Entrada" 			,"C", 8, 0})
AADD(aCabExcel, {"2 Saida" 				,"C", 8, 0})
AADD(aCabExcel, {"Inconsistencia"      , "C", 40, 0})
*/

//TRCell():New(oSection1,"PG_DATA"		, "SPG" , "Data"							)
TRCell():New(oSection1,"PG_MAT"			, "SPG" , "Matr�cula"						)
TRCell():New(oSection1,"PG_CC"			, "SPG" , "C.Custo"							)
TRCell():New(oSection1,"RA_NOME"		, "SRA" , "Nome"							)
TRCell():New(oSection1,"DAP1"			,  		, "Data 1 Entrada"		,"@!"	,10	)
TRCell():New(oSection1,"AP1"			, 		, "1 Saida"				,"@!"	,8	)
TRCell():New(oSection1,"DAP2"			, 		, "Data 2 Entrada"		,"@!"	,10	)
TRCell():New(oSection1,"AP2"			, 		, "2 Entrada"			,"@!"	,8	)
TRCell():New(oSection1,"INCON"			, 		, "Inconsist�ncia"		,"@!"	,40	)

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relat�rio.                                  				  !
//+-----------------------------------------------------------------------------------------------+

Static Function ReportPrint(oReport)

local oSection1b 	:= oReport:Section(1)
Local nX			:= 0
oReport:SetMeter(Len(_aRet))	

oSection1b:Init() 

For nX := 1 To Len(_aRet)
	//oSection1b:Cell("PG_DATA"):SetBlock({|| _aRet[nX][1]}) 
	oSection1b:Cell("PG_MAT"):SetBlock({|| _aRet[nX][2]}) 
	oSection1b:Cell("PG_CC"):SetBlock({|| _aRet[nX][3]}) 
	oSection1b:Cell("RA_NOME"):SetBlock({|| _aRet[nX][4]}) 
	oSection1b:Cell("DAP1"):SetBlock({|| _aRet[nX][5]}) 
	oSection1b:Cell("AP1"):SetBlock({|| _aRet[nX][6]}) 
	oSection1b:Cell("DAP2"):SetBlock({|| _aRet[nX][7]}) 
	oSection1b:Cell("AP2"):SetBlock({|| _aRet[nX][8]}) 
	oSection1b:Cell("INCON"):SetBlock({|| _aRet[nX][9]}) 
	oSection1b:PrintLine()
	oReport:IncMeter()
Next nX

oSection1b:Finish() 

Return


Static Function InTempo(dDataIni, cHoraIni, dDataFim, cHoraFim)
Local nDias 	:= 0 //dDataFim - dDataIni
Local cTime 	:= "" //ElapTime(cHoraIni + ":00", cHoraFim + ":00")
Local nHora 	:= 0 //Val(Left(cTime, 2))
Local nRet		:= 0
Local lContinua := .T.

If Empty(dDataFim) .Or. Empty(dDataIni)
	lContinua := .F.
Else
	nDias := dDataFim - dDataIni
EndIf

If lContinua
	If Empty(cHoraIni) .Or. Empty(cHoraFim)
		lContinua := .F.
	Else
		cTime := ElapTime(cHoraIni + ":00", cHoraFim + ":00")
		nHora := Val(Left(cTime, 2))
	EndIf
EndIf

If lContinua
	If Empty(StrTran(cHoraIni, ":", "")) .Or. Empty(StrTran(cHoraFim, ":", "")) .Or. Empty(dDataIni) .Or. Empty(dDataFim)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If nDias > 0 .And. Secs(cHoraFim) < Secs(cHoraIni)
		nDias --
	EndIf
	If nDias > 0
		nHora := nHora + (nDias * 24)
	EndIf
	nRet := (nHora + Val(Substr(cTime, 4, 2)) / 60)
EndIf
Return nRet
