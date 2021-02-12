#INCLUDE "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include 'protheus.ch'
/*
* Ponto de entrada apos a confirmacao do pedido de vendas
* Ricardo Luiz da Rocha
*---------------------------------------------------------------------------------
*/
User Function Mta410()
Local aArea		:= GetArea()
Local _cPedido	:= m->c5_num
Local lRet		:= .T.
Local aParcelas	:= {}
Local cPessoas  := SuperGetMV('KP_ACVLPV',.F., '000470/000287/000062/000304/000167/000309/000045/000199/000373/000195/000494/000404/')

If Type("l410Auto") == "U"
	Private l410Auto := .F.
Endif

m->c5_xsitlib	:=	u_KpFatC01(_cPedido)

_vDatas			:=	m->(u_Sc5Libs(_cPFil := c5_filial,_cPNumPed := c5_num, _cPSit := c5_xsitlib,_dPDataP := C5_xDtLibP,_dPDataF := C5_xDtLibF,_dPDataE := C5_xDtLibe))
m->c5_xdtlibp	:=_vDatas[1]
m->c5_xdtlibf	:=_vDatas[2]
m->c5_xdtlibe	:=_vDatas[3]

//m->c5_xtotmer:=u_MFAT01(xfilial('SC5'),_cPedido)

If cEmpAnt == '04'
	
	If !l410Auto
		If M->C5_XPVSPC == 'S' //Se o pedido é supplier
				VerLimD(M->C5_CLIENTE,M->C5_LOJACLI) //Verifica se tem limites com a supplier
				
				aParcelas := Condicao(1000,M->C5_CONDPAG,,dDataBase)
				If Len(aParcelas) > 6
						lRet := .F.
						MsgInfo("Esse pedido é supplier, porém a quantidade de parcelas é superior ao contrato(6), favor verificar a condicao de pagamento!","KAPAZICRED")
					Else
						VerConPg(M->C5_CONDPAG) //Vali se a condicao de pagamento é supplier e se a condicao de pagamento de prazo médio esta vinculada
				EndIf
			
			Else //Valida se o pedido deixou de ser supplier e continua com a condicao supplier
				If !ValConSP(M->C5_CONDPAG) 
					lRet := .F.
					MsgInfo("Esse pedido não é mais supplier, escolha uma condicao de pagamento que não seja supplier!","KAPAZICRED")
				EndIf
		EndIf
	EndIf
	
EndIf

If !(__cUserID $ Alltrim(cPessoas))
    If (IsInCallStack("A410Inclui")) .OR. (IsInCallStack("A410PCopia")) .OR. (IsInCallStack("A410Altera"))
		lRet :=	U_VALPRBL() //Valida os produtos
	EndIf
EndIf

RestArea(aArea)
Return(lRet)

Static Function VerLimD(cCliente,cLoja)
Local nPosTot   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_VALOR"})
Local nX 		:= 0
Local nTotal 	:= 0
Local lRet		:= .T.
Local cQr 	:= ""

If Empty(cCliente) .OR. Empty(cLoja)
	MsgInfo("Cliente ou loja vazio")
EndIf

For nX := 1 To Len(aCols)
	
	//Soma os valores
	nTotal += aCols[nX][nPosTot]
	
	//Próximo registro
Next nX

If Select("cAliaLim")<>0
	DbSelectArea("cAliaLim")
	cAliaLim->(DbCloseArea())
Endif

cQr += " SELECT ZSL.ZSL_RAIZCN,SA1.A1_CGC,ZSL.ZSL_LIMTOT,SA1.A1_LC,(ZSL.ZSL_LIMTOT-ZSL.ZSL_LIMUTI)AS LSUPPLI,(SA1.A1_LC - SA1.A1_SALPEDL - SA1.A1_SALDUP)AS LPROTHEU
cQr += " FROM "+RetSqlName("SA1")+" SA1
cQr += " INNER JOIN "+RetSqlName("ZSL")+" ZSL ON SUBSTRING(SA1.A1_CGC,1,8) = ZSL.ZSL_RAIZCN AND ZSL.D_E_L_E_T_ = ''
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += " AND SA1.A1_COD = '"+cCliente+"'"
cQr += " AND SA1.A1_LOJA = '"+cLoja+"'"

// abre a query
TcQuery cQr new alias "cAliaLim"
Count to nRegs

DbSelectArea("cAliaLim")
cAliaLim->(DbGoTop())

If cAliaLim->(EOF()) 
		MsgInfo("O cliente não possui limite com a Supplier, FAVOR VERIFICAR!!","KAPAZICRED")
		//lRet := .F.
	Else
		If nTotal > cAliaLim->LSUPPLI //limite inferior ao disponivel
			MsgInfo("O cliente não possui limite suficiente com a Supplier, FAVOR VERIFICAR!!","KAPAZICRED")
			//lRet := .F.
		EndIF
		
EndIf

Return(lRet)

//Valida se o pedido deixou de ser supplier
Static Function ValConSP(cCondPg)
Local aArea	:= GetArea()
Local lRet	:= .T.

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondPg))
	If SE4->E4_XCONDSP == 'S' //Se a condicao é a condicao suppler
		lRet	:= .F.
	EndIf

EndIf

RestArea(aArea)
Return(lRet)

//Validacoes da condicao de pagamento supplier
Static Function VerConPg(cCondPg)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local lAchou		:= .T.
Local cCondOri		:= cCondPg
Private cCondSPP	:= ""
Private cCondPM		:= ""

//TODO deixar dinamico a qtd de parcelas e os dias de vencimento (21 ou 28 por exemplo)

//Posiciona na condicao 
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondOri))
		If SE4->E4_XCONDSP == 'S' //Se a condicao é a condicao suppler
			cCondSPP	:= SE4->E4_CODIGO	 //Pega o codigo da condicao
		EndIf
		
		If !Empty(SE4->E4_XCONDPM) .And. SE4->E4_XCONDSP == 'S' //Processo de tratativa supplier ja feito na base, entao pode sair da rotina
			RestArea(aArea)
			Return
		EndIf
		
		If !Empty(SE4->E4_XCODSPP)
			M->C5_CONDPAG := SE4->E4_XCODSPP //Muda a condicao para supplier
			Return
		EndIf
		
	Else
		lAchou	:= .F.
		MsgInfo("Condicao de pgto kapazi inexistente","KAPAZICRED")
EndIf

If !Empty(cCondSPP) .And. lAchou
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		SE4->(DbGoTOP())
		If SE4->(DbSeek(xFilial("SE4") + cCondSPP))
			cCondPM	:= SE4->E4_XCONDPM
		EndIf
	Else
		MsgInfo("Condicao de pgto supplier inexistente, sera criada uma nova condicao e vinculada ao pedido","KAPAZICRED")
		U_CriaCPSP(cCondOri) 	//Cria a condicao de pagamento supplier
		U_CriaCPPM(cCondOri)	//cria a condicao de pagamento prazo médio supplier, que sera usada na liquidacao no financeiro
		
		M->C5_CONDPAG := cCondSPP //Condicao de pagamento supplier
		MsgInfo("Condicoes criadas com sucesso!!!","KAPAZICRED")
EndIf

If Empty(cCondPM) .And. lAchou
	MsgInfo("Condicao de pgto prazo medio supplier inexistente, sera criada uma nova condicao e vinculada ao pedido","KAPAZICRED")
	u_CriaCPPM(cCondOri)	//cria a condicao de pagamento prazo médio supplier, que sera usada na liquidacao no financeiro
EndIf

RestArea(aArea)
Return(lRet)
