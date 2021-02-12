#INCLUDE "protheus.ch"

/*
+ -----------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                   |
| Geracao da Dirf ao financeiro                                                                                                |
| Autor: Willian Duda                                                                                                          |
| RSAC Solucoes                                                                                                                |
|----------------------------------------------------------------------------------------------------------------------------- |
| Data: 20/01/2017                                                                                                             |
| Descricao: Inclusao do codigo da dirf no combo do MV_AUTOISS conforme cadastrado no Fornecedor.                              |
| Empresa: Fertipar                                                                                                            |
+------------------------------------------------------------------------------------------------------------------------------+
*/

User Function MT103DRF()

Local nCombo  := PARAMIXB[1]
Local cCodRet := PARAMIXB[2]
Local aImpRet := {}
Local cCodDrf	:= Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_CODRET")
Local cCodPIS	:= Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_CDRTPIS")
Local cCodCOF	:= Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_CDRTCOF")
Local cCodCSL	:= Posicione("SA2",1,xFilial("SA2")+CA100FOR+CLOJA,"A2_CDRTCSL")

nCombo  := 1
cCodRet := Iif(Empty(cCodDrf),"1708",cCodDrf)
cCodPIS := Iif(Empty(cCodPIS),"5952",cCodPIS)
cCodCOF := Iif(Empty(cCodCOF),"5952",cCodCOF)
cCodCSL := Iif(Empty(cCodCSL),"5952",cCodCSL)
aadd(aImpRet,{"IRR",nCombo,cCodRet})
aadd(aImpRet,{"PIS",nCombo,cCodPIS})
aadd(aImpRet,{"COF",nCombo,cCodCOF})
aadd(aImpRet,{"CSL",nCombo,cCodCSL})
nCombo  := 2
aadd(aImpRet,{"ISS",nCombo,"    "})
aadd(aImpRet,{"INS",nCombo,"    "})
aadd(aImpRet,{"SES",nCombo,"    "})

Return aImpRet
