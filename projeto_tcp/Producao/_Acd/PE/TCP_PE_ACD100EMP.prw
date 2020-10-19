
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD100EMP ºAutor  ³Deosdete P. Silva   º Data ³  12/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar o empenho do endereço na     º±±
±±º          ³ geraçao da Ord Sep                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACD100EMP() 
Local lRet    := .T. 
Local aArea   := getArea()
Local nSldSep := 0
Local aAreaSDC := SDC->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se a soma do empenho nos endereços do saldo ³
//³a atender esta correto                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSldSep := SD4->D4_QUANT

DbSelectArea("SDC") 
DbSetOrder(2)   //DC_FILIAL, DC_PRODUTO, DC_LOCAL, DC_OP, DC_TRT, DC_LOTECTL, DC_NUMLOTE, DC_LOCALIZ, DC_NUMSERI, R_E_C_N_O_, D_E_L_E_T_
SDC->(DbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP)))   

While !SDC->(Eof()) .AND. SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP) == xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP)

    nSldSep -= SDC->DC_QUANT
	SDC->(DbSkip())

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamar rotina de empenho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSldSep > 0
	Aviso(ProcName() + "-Sem empenho no endereço!!!","Op/Produto "+SD4->D4_OP+"/"+SD4->D4_COD + ". Falta empenho de endereço para o saldo de " + AllTrim(Str(nSldSep)) + ". Faça o endereçamento do empenho ",{"Ok"})
    lRet := .F.
EndIf

RestArea(aArea)
RestArea(aAreaSDC)

Return lRet

