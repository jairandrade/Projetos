#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                		 **/
/** Ponto de entrada MTA455E                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/
//TODO Liberacao de estoque Automatico.
//@since 13/04/2018
//@version 1.0

User Function MTA455E()
	Local aArea 	:= GetArea() 
	Local nRet		:= 1
	Local lGeraOp	:= .F.
	
	if nRet == 1
		lGeraOp :=  ExistBlock("KFATA13") .and. StaticCall(M521CART,TGetMv,"  ","KA_PERSALL","L",.F.,"M440STTS - Ativar a geração de ordem de produção de pedidos de personalizado (grupo KA_PERSGRP)?" )

		// se nao gera a ordem
		If !lGeraOp
			// se existe a funcao e a geracao esta ativada no parametro e o pedido do fluig
			lGeraOp := ExistBlock("KFATA13") .and. GetMv("KA_PERSATV",,.F.) .and. StaticCall(KFATA13,fromFluig,SC9->C9_PEDIDO)
		Endif

		// se deve gerar a ordem de producao
		If lGeraOp
			// apontar ordem de producao de pedido personalizado
			Processa( { || nRet := U_KFATA13A() },"Processando...","Aguarde..." )
		Endif
	Endif
		
	RestArea(aArea)   		
Return(nRet)// 1= Libera    2=Mantêm o bloqueio  	 

