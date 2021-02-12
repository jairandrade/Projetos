//MA030TOK

/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETÁRIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Faturamento																																									 		**/
/** NOME 				: MA030TOK.RPW																																										**/
/** FINALIDADE	: Ponto de Ebtrada                                                      **/
/** SOLICITANTE	:                     					                                                           				**/
/** DATA 				: 18/09/2017																																							 				**/
/** RESPONSÁVEL	: RSAC SOLUÇÕES																																										**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARAÇÃO DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: U_MA030TOK													                                                        **/
/** DESCRIÇÃO	  	: VALIDAR CADASTRO DE CLIENTE   																																**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 18/09/2017 	| Marcos Sulivan         | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/ 


User Function MA030TOK() 
Local aArea		:= GetArea()                
Local cGrpCn	:=	""  
Local lRet		:=	.T.
Public lAltNf	:= .F.	/***NF MISTA***/


If INCLUI /***NF MISTA***/

		If Empty(M->A1_XPERSV) .And. M->A1_XGERASV == 'S' //Validacao do percentual de serviço
				lRet	:=	.F.
				MsgStop("Se o cliente gerar serviço para NF Mista, não é permitido que o percentual de Servico da NF seja zero!!!","NF MISTA")
			
			ElseIf !Empty(M->A1_XPERSV) .And. M->A1_XGERASV == 'S' //Vai para ZPV
				lAltNf	:= .T.
		EndIf

	ElseIf ALTERA
		If Empty(M->A1_XPERSV) .And. M->A1_XGERASV == 'S' //Validacao do percentual de serviço
			lRet	:=	.F.
			MsgStop("Se o cliente gerar serviço para NF Mista, não é permitido que o percentual de Servico da NF seja zero!!!","NF MISTA")
		EndIf
	
		If M->A1_XPERSV != SA1->A1_XPERSV
				lAltNf	:= .T.
				/*
				Reclock("SB1",.F.)
				SB1->B1_XFLAGSV	:= "X"
				SB1->B1_XDATASV	:= Date()
				SB1->B1_XHRSV	:= time()
				SB1->B1_XQUEMSV	:= UsrFullName(__cUserID) 
				MSUnlock()
				*/
			ElseIf M->A1_XGERASV != SA1->A1_XGERASV
				lAltNf	:= .T.
		EndIf

EndIf /***NF MISTA***/

/*//REMOVIDO A PEDIDO DO LUIZ FERNANDO 08/11/2017  - MARCOS SULIVAN
cGrpcn :=	posicione("ACY",1,xFilial("ACY")+M->A1_GRPVEN,"ACY_K_CANA")

		If ( M->A1_K_CANAL <> cGrpcn )
		    
		    Aviso("ATENÇÃO","Confira o Canal e o Grupo",{"Ok"})
				lRet	:=	.F.                         
		
		EndIf
*/

if ALTERA
	/*
	if M->A1_TIPO <> SA1->A1_TIPO
		//Se mudaram o tipo de cliente, verifica se tem pedidos em aberto, caso tenha deve-se muda-los
		if !ValPedKP()
			lRet := .f.
		endif	
	endif
	*/
endif


RestArea(aArea)
Return(lRet)

//valida se tem pedidos na KI
Static Function ValPedKP()
Local cQry 		:= ""
Local cALiaskP	:= GetNextAlias()
Local lRet 		:= .t.

cQry += " SELECT * 
cQry += " FROM SC5040 SFM 
cQry += " WHERE  SFM.D_E_L_E_T_=' '
cQry += " AND SFM.C5_CLIENT = '"+SA1->A1_COD+"'
cQry += " AND SFM.C5_LOJACLI = '"+SA1->A1_LOJA+"'
cQry += " AND SFM.C5_TIPOCLI = '"+SA1->A1_TIPO+"'
cQry += " AND SFM.C5_NOTA = ''

TcQuery cQry Alias (cALiaskP)

DbSelectArea((cALiaskP))
(cALiaskP)->(DbGoTop())

if !(cALiaskP)->(EOF())
	MsgInfo("Existem PEDIDO DE VENDA vinculados a este CLIENTE que estão com TIPO DE CLIENTE diferente do informado nesta tela, ajuste os PEDIDOS DE VENDA PRIMEIRO, para depois ajustar o cliente!!")
	lRet := .f.
endif

(cALiaskP)->(DbCloseArea())
Return(lRet)