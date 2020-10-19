#include "PROTHEUS.CH" 
#include "TOPCONN.CH" 

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄr 
//³Autor - Edilson Marques                                    ³
//³Inclusao - 04/11/12                                        ³
//³                                                           ³
//³                                                           ³
//³Ponto de entrada na Nota Fiscal de Entrada, acionado quando³
//³o usuario seleciona o Pedido de Compras por item ou por    ³
//³fornecedor.                                                ³
//³                                                           ³
//³Funcao : Gravar a natureza na tabela SD1                   ³
//³(Itens da NFE) a partir  da tabela SC7 (Pedido de Compras) ³
//³                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄr 
ENDDOC*/           


User Function MT103IPC() 

Local _cAreaSC7 := SC7->(GetArea())
Local _cAreaSD1 := SD1->(GetArea())
Local _cAreaSF1 := SF1->(GetArea())
Local ExpN1     := PARAMIXB[1]	
                                                                  
Local	nNat	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_XNATURE'})
Local	nDesc	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_DESCRI'})
Local	npTot	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_TOTAL'})
Local	npQtde	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_QUANT'})
Local	npVu	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_VUNIT'})
Local nPosCod      := aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'})

Local	npcc	:= aScan(aHeader,{|x| alltrim(x[2]) == 'D1_CC'})


Private M->D1_COD 	:= aCols[ExpN1][nPosCod]

aCols[ExpN1][nNat]	:= SC7->C7_XNATURE
IF nDesc>0
	aCols[ExpN1][nDesc]	:= SC7->C7_DESCRI
EndIf
// INCLUIDO POR RODRIGO SLISINSKI 07/08/2017 PARA TRAZER A NATUREZA E O CC DO RATEIO NA MEDICAO
if aCols[ExpN1][npVu]*aCols[ExpN1][npQtde]<>aCols[ExpN1][npTot]
	aCols[ExpN1][npQtde]:=aCols[ExpN1][npTot]/aCols[ExpN1][npVu]
EndIF
if !Empty(SC7->C7_CONTRA) .and. !empty(SC7->C7_MEDICAO)
	
	cQueryZ21 := " SELECT TOP 1 Z21_CCUSTO,Z21_NATURE  FROM "+RetSqlName('Z21')+" Z21 "
	cQueryZ21 += " WHERE Z21.Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21.Z21_CONTRA = '"+SC7->C7_CONTRA+"'"
	cQueryZ21 += "   AND Z21.Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND Z21.D_E_L_E_T_ != '*' "
	cQueryZ21 += " ORDER BY Z21_VALOR DESC "
	If (Select("TMPZ21") <> 0)
		TMPZ21->(DbCloseArea())
	Endif
	TcQuery cQueryZ21 new alias 'TMPZ21'

	if !TMPZ21->(eof())
		aCols[ExpN1][npcc]	:= TMPZ21->Z21_CCUSTO
		aCols[ExpN1][nNat]	:= TMPZ21->Z21_NATURE
	EndIF


EndIF

__READVAR := M->D1_COD
If ExistTrigger("D1_COD") 
	RunTrigger(2,ExpN1,,,"D1_COD")
Endif

RestArea(_cAreaSC7)
RestArea(_cAreaSD1)
RestArea(_cAreaSF1)

Return()
