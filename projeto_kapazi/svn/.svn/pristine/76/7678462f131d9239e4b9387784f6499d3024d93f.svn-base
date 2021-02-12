#include "protheus.ch"
#include "TOPCONN.CH"

/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                	   **/
/** Ponto de entrada M440STTS                               																	                                   **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/
User Function M440STTS()
  Local aArea   :=	GetArea() 
  Local lGeraOp := .F.
  Local cSitLib
  Local lLibFinAut := .F.

  Conout("")
  Conout("------------------------------------------")
  Conout("Ponto de entrada M440STTS - Liberacao de pedidos")
  Conout("------------------------------------------")
  Conout("")

  // executa a liberação automática do pedido
  Ka410Alt(@lLibFinAut)  

  //executa rotina de atualizacao da situacao de liberacao 
  cSitLib := u_KpFatC01(SC5->C5_NUM)
  RECLOCK("SC5", .F.)  
    SC5->C5_XSITLIB := cSitLib
  MSUNLOCK()   

  // se existe a funcao e a geracao de ordem de producao de produtos personalizados esta ativada
  lGeraOp :=  ExistBlock("KFATA13") .and. StaticCall(M521CART,TGetMv,"  ","KA_PERSALL","L",.T.,"M440STTS - Ativar a geração de ordem de produção de pedidos de personalizado (grupo KA_PERSGRP)?" )

  // se nao gera a ordem
  If !lGeraOp
    // se existe a funcao e a geracao esta ativada no parametro e o pedido do fluig
    lGeraOp := ExistBlock("KFATA13") .and. GetMv("KA_PERSATV",,.F.) .and. StaticCall(KFATA13,fromFluig,SC5->C5_NUM) 
  Endif

  // se deve gerar a ordem de producao
  If lGeraOp
    // chama a funcao
    Processa( { || U_KFATA13(SC5->C5_NUM) },"Processando...","Aguarde..." )
  Endif

  // mata440 liberacao comercial
  If ExistBlock("KFATR15") .and. IsInCallStack( "a440libera" ) .and.;
  	!( IsInCallStack("A455LibAut") .or. IsInCallStack("A455LibMan") .or. IsInCallStack("A455LibAlt") ) .And.;
  	!lLibFinAut
    U_KFATR15("02",SC5->C5_NUM)
  Endif

  RestArea(aArea)
Return nil   




/**********************************************************************************************************************************/
/** static function Ka410Alt()                                                                                                   **/
/** Ponto de entrada após liberacao do crédito                                                                          **/
/**********************************************************************************************************************************/
Static Function Ka410Alt(lLibFinAut)                                                                                                            
Local aArea      := GetArea()
Local lEnd       := .F.
Local nValLib    := 0
Local nValPed    := 0
Local cCodStatus := ""

//Recupera o valor liberado do limite de credito deste pedido
nValLib := GetVlLibPe(SC5->C5_NUM)
    
//Recupera o valor total deste pedido
nValPed := GetValPed(SC5->C5_NUM)
    
//Verifica se o pedido ja foi liberado anteriormente
If nValLib > 0
	// pedido ja liberado, faz a avaliação de credito/estoque do pedido
	//AvalPed()

	//Verifica se o valor ja liberado é maior que o valor total do pedido
	If nValLib >= nValPed

		//Verifica se o pedido está bloqueado para crédito
		If IsBlqCred(SC5->C5_NUM)
			//Faz a liberação de crédito do pedido
			LibCred(SC5->C5_NUM)
			If ExistBlock("KFATR15")
				lLibFinAut := .T.
				cCodStatus := "13" //LIBERACAO FINANCEIRO AUTOMATICA, ATUAL <= ANTERIOR
			Endif
			MsgInfo("Liberacao de crédito efetuada no pedido, pois o valor total é MENOR OU IGUAL que a antiga liberação!!!")
		Else
			lLibFinAut := .T.
			cCodStatus := "23" //LIBERAÇÃO FINANCEIRO AUTOMÁTICA, CRÉDITO/RISCO OK
		EndIf
    
	Elseif !IsBlqCred(SC5->C5_NUM)
		lLibFinAut := .T.
		cCodStatus := "23" //LIBERAÇÃO FINANCEIRO AUTOMÁTICA, CRÉDITO/RISCO OK
	EndIf  
ElseIf !IsBlqCred(SC5->C5_NUM)
	lLibFinAut := .T.
	cCodStatus := "23" //LIBERAÇÃO FINANCEIRO AUTOMÁTICA, CRÉDITO/RISCO OK	  
EndIf

If lLibFinAut
	U_KFATR15("02",SC5->C5_NUM) //Liberação comercial deve anteceder a Liberação Financeiro Automática
	U_KFATR15(cCodStatus,SC5->C5_NUM)
EndIf

RestArea(aArea)
return Nil


/**********************************************************************************************************************************/
/** static function IsBlqEstq(cNumPed)                                                                                           **/
/** Verifica se o pedido de venda esta bloqueado para estoque                                                                    **/
/**********************************************************************************************************************************/
static function IsBlqEstq(cNumPed)

	// variaveis auxiliares
  local aArea := GetArea()
	local cQr := ""
  local lRet := .F.


  // verifica se o pedido está bloqueado para crédito
  cQr := " select count(*) C9_TOTAL
  cQr += "   from " + RetSqlName("SC9") + " SC9 
  cQr += "  where SC9.D_E_L_E_T_ = ' '
  cQr += "    and SC9.C9_FILIAL = '" + XFilial("SC9") + "'
  cQr += " 	  and SC9.C9_PEDIDO = '" + cNumPed + "'
  cQr += " 	  and SC9.C9_BLEST != ''			         
    
  // abre a query
  TcQuery cQr new alias "QSC9"
  RestArea(aArea)
  
	// retorna o resultado e fecha a query
	lRet := QSC9->C9_TOTAL > 0
	QSC9->(DbCloseArea())

return lRet

/**********************************************************************************************************************************/
/** static function LibCred(cNumPed)                                                                                             **/
/** Executa a liberação de crédito do pedido de vendas                                                                           **/
/**********************************************************************************************************************************/
static function LibCred(cNumPed)

  // variaveis auxiliares
  local aArea := GetArea()
  local cQr := ""
  
  // monta a instrução SQL para liberar o crédito do pedido
  cQr := " update " + RetSqlName("SC9")
  cQr += "    set C9_BLCRED = '" + Space(TamSx3("C9_BLCRED")[1]) + "'
  cQr += "  where D_E_L_E_T_ = ' '
  cQr += "    and C9_FILIAL = '" + XFilial("SC9") + "'
  cQr += " 	  and C9_PEDIDO = '" + cNumPed + "'
  cQr += " 	  and C9_BLCRED != ''
  TcSqlExec(cQr)

	// restaura a area
  RestArea(aArea)
return Nil

/**********************************************************************************************************************************/
/** static function IsBLqCred(cNumPed)                                                                                           **/
/** Verifica se o pedido de venda esta bloqueado para credito                                                                    **/
/**********************************************************************************************************************************/
static function IsBlqCred(cNumPed)

  // variaveis auxiliares
  local aArea := GetArea()
  local cQr := ""
  local lRet := .F.


  // verifica se o pedido está bloqueado para crédito
  cQr := " select count(*) C9_TOTAL
  cQr += "   from " + RetSqlName("SC9") + " SC9 
  cQr += "  where SC9.D_E_L_E_T_ = ' '
  cQr += "    and SC9.C9_FILIAL = '" + XFilial("SC9") + "'
  cQr += " 	  and SC9.C9_PEDIDO = '" + cNumPed + "'
  cQr += " 	  and SC9.C9_BLCRED != ''			         
  
  // abre a query
  TcQuery cQr new alias "QSC9"
  RestArea(aArea)
  
	// retorna o resultado e fecha a query
	lRet := QSC9->C9_TOTAL > 0
	QSC9->(DbCloseArea())

return lRet

/**********************************************************************************************************************************/
/** static function AvalPed()                                                                                                    **/
/** Executa a liberação do pedido de venda posicionado na SC5                                                                    **/
/**********************************************************************************************************************************/
static function AvalPed()

	// variaveis auxiliares
  local aArea := GetArea()
  private lTransf := .F.
  private lLiber := .F.
  private lSugere := .F.

  
  // ajusta os parametros iniciais
  Pergunte("MTA440",.F.)  
  lTransf := mv_par01 == 1
  lLiber := mv_par02 == 1
  lSugere := mv_par03 == 1

  // ajusta os parametros da rotina
  Pergunte("MTALIB", .F.)
  mv_par01 := 1
  mv_par02 := SC5->C5_NUM
  mv_par03 := SC5->C5_NUM
  mv_par04 := SC5->C5_CLIENTE
  mv_par05 := SC5->C5_CLIENTE
  mv_par06 := Stod("")
  mv_par07 := Stod("20491231")
  mv_par08 := 1
  mv_par09 := SC5->C5_LOJACLI
  mv_par10 := SC5->C5_LOJACLI

  // executa a liberação automática
  A440Proces("SC5", SC5->(RecNo()), 4, @lEnd)

  // restaura a area
	RestArea(aArea)

return Nil


/**********************************************************************************************************************************/
/** static function GetValPed(cNumPed)                                                                                           **/
/** recupera o valor total do pedido                                                                                             **/
/**********************************************************************************************************************************/
static function GetValPed(cNumPed)

  // variaveis auxiliares
  local nRet := 0
  local cQr := ""
  local aArea := GetArea()


  // define a query para recuperar o maior valor do limite de credito liberado
  cQr := " select ( sum(SC6.C6_VALOR)) + (SELECT C5_FRETE FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = '" + XFilial("SC5") + "' AND C5_NUM = '" + cNumPed + "') C6_VALOR
  cQr += "   from " + RetSqlName("SC6") + " SC6
  cQr += "  where SC6.D_E_L_E_T_ = ' '
  cQr += "    and SC6.C6_FILIAL = '" + XFilial("SC6") + "'
  cQr += " 	  and SC6.C6_NUM = '" + cNumPed + "'

  // abre a query
  TcQuery cQr new alias "QSC6"
  RestArea(aArea)

  // retorna o resultado e fecha a query
  nRet := QSC6->C6_VALOR
  QSC6->(DbCloseArea())

return nRet

/**********************************************************************************************************************************/
/** static function GetVlLibPe(cNumPed)                                                                                          **/
/** recupera o valor liberado do limite de credito deste pedido                                                                  **/
/**********************************************************************************************************************************/
static function GetVlLibPe(cNumPed)

  // variaveis auxiliares
  local nRet := 0
  local cQr := ""
  local aArea := GetArea()


  // define a query para recuperar o maior valor do limite de credito liberado
  cQr := " select ISNULL((max(SZB.ZB_VALOR)),0) + (SELECT C5_FRETE FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = '' AND C5_FILIAL = '" + XFilial("SC5") + "' AND C5_NUM = '" + cNumPed + "' )ZB_VALOR
  cQr += "   from " + RetSqlName("SZB") + " SZB
  cQr += "  where SZB.D_E_L_E_T_ = ' '
  cQr += "    and SZB.ZB_FILIAL = '" + XFilial("SZB") + "'
  cQr += " 	  and SZB.ZB_PEDIDO = '" + cNumPed + "'

  // abre a query
  TcQuery cQr new alias "QSZB"
  RestArea(aArea)

	// retorna o resultado e fecha a query
	nRet := QSZB->ZB_VALOR
	QSZB->(DbCloseArea())

return nRet
