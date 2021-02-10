//User Function ContPag()
User Function RFINA22()
//

SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

If .Not. MsgBox("Confirma gera��o de arquivo para Minist�rio da Previdencia Social?","Gera��o de Arquivo para Minist�rio da Previdencia Social","YESNO")
   @ 050,000 To 150,300 Dialog oDlg1 Title "Gera��o de Arquivos para Minist�rio da Previdencia Social"
   @ 015,010 Say "Operacao Cancelada."
   @ 035,060 BUTTON "_Ok" SIZE 30,10 ACTION CLOSE(oDlg1)
   ACTIVATE DIALOG oDlg1 CENTER
   Return
Endif

//+--------------------------------------+
//| Variaveis utilizadas para par�metros |
//| mv_par01             // Da Emissao   |
//| mv_par02             // At� Emissao |
//+--------------------------------------+

If .Not. Pergunte("FINA22",.T.) // For�a o recebimento dos par�metros
   Return
EndIf

Processa({|lEnd| GeraArquivo()},"Gera��o de arquivos para o Minist�rio da Previdencia Social")

Return


//
Static Function GeraArquivo()
//

cArqCPag := "RE"+Substr(DtoC(mv_par01),1,2)+Substr(DtoC(mv_par01),4,2)+Substr(DtoC(mv_par01),7,2)+".TXT"

If File(cArqCPag)
   FErase(cArqCPag)
Endif

If (nHdlArq := FCreate(cArqCPag,0)) == -1
   MsgBox("Arquivo Texto n�o pode ser criado!","ATEN��O","ALERT")
   Return
Else
   IncProc("Gerando arquivo "+cArqCPag)
Endif

PRIVATE cQuery
cQuery := " SELECT A2_NOME AS NOMEFOR, A2_CGC AS CNPJFOR, D1_DOC AS NUMDOC, D1_DTDIGIT AS EMISSAO, "
cQuery += " D1_TOTAL AS VALTIT, D1_VALINS AS VALINSS, D1_VALIRR AS VALIRRF "
cQuery += " FROM " +RetSqlName("SD1")+" SD1, "+RetSqlName("SA2")+" SA2 "
cQuery += " WHERE "
cQuery += " SD1.D_E_L_E_T_ <> '*' AND "
cQuery += " SA2.D_E_L_E_T_ <> '*' AND "
cQuery += " D1_FORNECE NOT IN ('WSE1SQ','WSE1SG','I8I9BA') AND " // Uniao / Receita Federal / Servi�os Diversos
cQuery += " D1_FORNECE = A2_COD    AND "
cQuery += " D1_LOJA    = A2_LOJA   AND "
cQuery += " D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
cQuery += " (SUBSTR(D1_CF,2,3) = '949') AND "
cQuery += " (A2_TIPO = 'F' OR A2_TIPO = 'J') "

cQuery += " UNION "

cQuery += " SELECT A2_NOME AS NOMEFOR, A2_CGC AS CNPJFOR, E2_NUM AS NUMDOC, E2_EMISSAO AS EMISSAO, "
cQuery += " E2_VALOR AS VALTIT, E2_INSS AS VALINSS, E2_IRRF AS VALIRRF "
cQuery += " FROM " +RetSqlName("SE2")+" SE2, "+RetSqlName("SA2")+" SA2 "
cQuery += " WHERE "
cQuery += " SE2.D_E_L_E_T_ <> '*' AND "
cQuery += " SA2.D_E_L_E_T_ <> '*' AND "
cQuery += " E2_ORIGEM <> 'MATA100' AND "
cQuery += " E2_TIPO NOT IN ('TX','INS','ISS','FT','DP','PA','AB-') AND " // Tit.de Taxas/Tit.INSS/Tit.de ISS/Fatura/Duplicata
cQuery += " E2_FORNECE NOT IN ('WSE1SQ','WSE1SG','I8I9BA') AND " // Uniao / Receita Federal / Servi�os Diversos
cQuery += " E2_FORNECE = A2_COD    AND "
cQuery += " E2_LOJA    = A2_LOJA   AND "
cQuery += " (A2_TIPO = 'F' OR (A2_TIPO = 'J' AND E2_TIPO NOT IN ('REC'))) AND "
cQuery += " E2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
cQuery += " ORDER BY NOMEFOR, EMISSAO "
TCQUERY cQuery NEW ALIAS T01

nContad := 0

While !Eof()

   cTexto := Substr(T01->EMISSAO,7,2)+"/"+;
             Substr(T01->EMISSAO,5,2)+"/"+;
             Substr(T01->EMISSAO,1,4)     // Data de Emiss�o        (10 Caracteres)
   cTexto += T01->NUMDOC                  // N�mero do Documento     (06 Caracteres)
   cTexto += T01->NOMEFOR                 // Raz�o Social Fornecedor (40 Caracteres)
   cTexto += T01->CNPJFOR                 // CNPJ do Fornecedor      (17 Caracteres)
   cTexto += StrZero(T01->VALTIT ,13,02) // Valor Bruto             (13 Caracteres)
   cTexto += StrZero(T01->VALINSS,13,02) // Valor Retido do ISS     (13 Caracteres)
   cTexto += StrZero(T01->VALIRRF,13,02) // Valor Retido do IRR     (13 Caracteres)
   /*/
   Para n�o gravar o ponto decimal multiplicar por 100 e desprezar os centavos
   cTexto += StrZero(T01->VALTIT *100,13) // Valor Bruto             (13 Caracteres)
   cTexto += StrZero(T01->VALINSS*100,13) // Valor Retido do ISS     (13 Caracteres)
   cTexto += StrZero(T01->VALIRRF*100,13) // Valor Retido do IRR     (13 Caracteres)
   /*/
   FWrite(nHdlArq,cTexto+Chr(10))
   nContad++
   DbSkip()

Enddo

dbCloseArea("T01")
FClose(nHdlArq)

If nContad = 0
   MsgBox("N�o h� dados. Favor vertificar os Par�metros.","Aten��o","ALERT")
   FErase(cArqCPag)
Else
   @ 050,000 To 150,300 Dialog oDlg1 Title "Gera��o de Arquivo para Minist�rio da Previdencia Social"
   @ 010,010 Say "             Opera��o realizada com sucesso."
   @ 020,010 Say "               Arquivo gerado: "+cArqCPag
   @ 035,060 Button "_Ok" Size 30,10 Action Close(oDlg1)
   Activate Dialog oDlg1 Center
Endif

Return


SUBSTR("INSS CP: "+ALLTRIM(SE2->E2_NUM)+" - "+ALLTRIM(SA2->A2_NOME),1,40)                                                                                                                               
