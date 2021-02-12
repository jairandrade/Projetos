#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: GerNFSv		|	Autor: Luis Paulo							|	Data: 11/06/2018	//
//==================================================================================================//
//	Descrição: Funcao para gerar NF de Serviço														//
//																									//
//==================================================================================================//
User Function GerNFSv()
Local aAreaC5		:= SC5->(GetArea())
Local aAreaC6		:= SC6->(GetArea())
Local aAreaC9		:= SC9->(GetArea())
Local lAtvNFM		:= GetMv("KP_ATVNFM",,.F.) //Verifica se a NF mista esta ativa
Local aBloqueio		:= {}
Local aPvlNfs		:= {}
Local lIntan		:= !( (SC5->C5_K_INTAN > 0) .and. SC5->C5_PVINTAN $ ' S')
Local lServ			:= 	(SC5->C5_XGERASV == "S" .And. SC5->C5_XTIPONF == "1")
Local lValProd		:= ValProd()
Local aArea			:= {}
Local cSaveFil		:= ""
Local lLiber		:= (!Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ))
Private lMsErroAuto	:= .F.

If cEmpAnt == "04" .And. cFilAnt == "01" .And. SC5->C5_K_OPER == "52" .And. SC5->C5_TIPO == "N"  .And. lIntan .And. lServ .And. lValProd 
	
		If lAtvNFM //Verifica esta ativa a geracao de servicos
				
				If lLiber //Valida se o pedido esta liberado
				
						If xValLFin ()  //Valida bloqueio de financeiro
						
								If cFilant != SC5->C5_FILIAL
									cSaveFil	:= 	cFilant 					//Bkp Filial
									cFilant		:= 	SC5->C5_FILIAL				//Seta a filial correta
									aArea 		:= 	SM0->(GetArea())			//Ajusta SM0
									
									SM0->(DbSeek( cEmpAnt + SC5->C5_FILIAL ) )//Seta SM0 correta
									If !RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
										MsgAlert("Empresa nao localizada")
									EndIf
								EndIf
								
								xGeraNFSE()
								RECLOCK("SC5", .F.)  
								SC5->C5_XSITLIB := "6"
								SC5->C5_XTIPONF	:= "2"
								MSUNLOCK()
								
								If Len(aArea) > 0
									RestArea( aArea )
									RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
									cFilant := cSaveFil
								EndIf 
							Else
								MsgAlert("Favor executar as liberação de crédito primeiro!")
						EndIf
						
					Else
						MsgAlert("Status inválido para geração de NFSE")
				EndIf
				
			Else
				MsgAlert("NF Mista Desativada!")
		EndIf
		
	Else
		If !lValProd
				MsgAlert("Este pedido não pode gerar NFSE! Verifique os produtos deste pedido! ")
			Else
				MsgAlert("Este pedido não pode gerar NFSE! ")
		EndIf
EndIf

cAliasVL->(DBCloseArea())

RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
Return()

/*/{Protheus.doc} LibBlCre
//Função para Liberacao de Credito - pedido de venda
@author Luis Paulo
@since 02/09/2016
@version undefined
@param cNumPed, characters, descricao
@type function
/*/
Static Function LibBlCre( cPedido )
Local aAreaAtu 	:= GetArea()
Local aAreaSC5 	:= SC5->( GetArea() )
Local aAreaSC6 	:= SC6->( GetArea() )
Local aAreaSC9 	:= SC9->( GetArea() )

dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
SC9->( dbSeek(FwxFilial('SC9')+ cPedido ) )
While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == FwxFilial("SC9") + cPedido
//-- Libera de Credito para o item da liberacao do Pedido de Venda ( SC9 )   --             
	a450Grava(1,.T.,.F.)
	SC9->(dbSkip() )
EndDO


RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAtu)

Return()

/*/{Protheus.doc} LibBlEst
//Função para Liberacao de Estoque Manual - pedido de venda
@author Luis Paulo
@since 02/09/2016
@version undefined
@param cNumPed, characters, descricao
@type function
/*/
Static Function LibBlEst ( cPedido )
Local aAreaAtu 	:= GetArea()
Local aAreaSC5 	:= SC5->( GetArea() )
Local aAreaSC6 	:= SC6->( GetArea() )
Local aAreaSC9 	:= SC9->( GetArea() )

dbSelectArea("SC9")
SC9->( dbSetOrder(1) )
SC9->( dbSeek(FwxFilial('SC9')+ cPedido ) )
While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == FwxFilial("SC9") + cPedido
//-- Libera de Estoque para o item da liberacao do Pedido de Venda ( SC9 )   --             
	a450Grava(1,.F.,.T.)
	SC9->(dbSkip() )
EndDO


RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAtu)

Return()


Static Function xGeraNFSE()
Local aPvlNfs		:= {}
Local cSerieNFS		:= 'NFS'
Local lMostraCtb	:= .F.
Local lAglutCtb		:= .F.
Local lCtbOnLine	:= .F.
Local lCtbCusto		:= .F.
Local lReajuste		:= .F.
Local nCalAcrs		:= 1
Local nArredPrcLis	:= 1
Local lAtuSA7		:= .F.
Local lECF			:= .F.
Local cEmbExp		:= nil
Local bAtuFin		:= {|| .T.}
Local bAtuPGerNF	:= {||}
Local bAtuPvl		:= {||}
Local bFatSE1		:= {|| .T. }
Local dDataMoe		:= dDatabase

Local aBloqueio		:= {}
Local aParam460		:= Array(30)
Local nIndSF2 		:= SF2->(IndexOrd())
Local nRecSF2 		:= SF2->(Recno())
Local nIndSD2 		:= SD2->(IndexOrd())
Local nRecSD2 		:= SD2->(Recno())
Local aArea 		:= GetArea()
Local cBkp  		:= Alias()

/*
Parametros³ExpA1: Array com os itens a serem gerados                   
          ³ExpC2: Serie da Nota Fiscal                                 
          ³ExpL3: Mostra Lct.Contabil                                  
          ³ExpL4: Aglutina Lct.Contabil                                
          ³ExpL5: Contabiliza On-Line                                  
          ³ExpL6: Contabiliza Custo On-Line                            
          ³ExpL7: Reajuste de preco na nota fiscal                     
          ³ExpN8: Tipo de Acrescimo Financeiro                         
          ³ExpN9: Tipo de Arredondamento                               
          ³ExpLA: Atualiza Amarracao Cliente x Produto                 
          ³ExplB: Cupom Fiscal                                         
          ³ExpCC: Numero do Embarque de Exportacao                     
          ³ExpBD: Code block para complemento de atualizacao dos titulos financeiros.                                     
          ³ExpBE: Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal.                       
          ³ExpBF: Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal                            
*/

		
// Liberacao de pedido
Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
// Checa itens liberados
Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

LibBlCre(SC5->C5_NUM)	//Liberacao de crédito
//LibBlEst(SC5->C5_NUM)	//Liberacao de Estoque Manual		


If Empty(aBloqueio) .And. !Empty(aPvlNfs)
		cNumNFS := MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
		
		If !Empty(cNumNFS)
				MsgInfo("NFSE gerada com sucesso!!! ->> Serie: " + Alltrim(SF2->F2_SERIE) + "->> NF: "+ cNumNFS  , "NFSE KAPAZI")
			Else
				//MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! ->"+ SC5->C5_NUM + "ID: "+cIdNFSE, "NFSE KAPAZI")
		EndIf
		
	Else
		//MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! -> "+ SC5->C5_NUM + " -- ID: "+cIdNFSE, "NFSE KAPAZI")
EndIf

Reclock("SF2",.F.)
SF2->F2_XTIPONF	:= "2" //Servico
MsUnlock()

DbSelectArea(cBkp)
RestArea(aArea)
SF2->(DbSetOrder(nIndSF2))
SF2->(DbGoTo(nRecSF2))
SD2->(DbSetOrder(nIndSD2))
SD2->(DbGoTo(nRecSD2))
Return()

//Valida se tem produto diferente de NF Mista
Static Function ValProd()
Local aArea		:= GetArea()
Local cSql		:= ""
Local cAliasTT
Local nValTotNF	:= 0
Local cProd		:= Alltrim( SuperGetMV("KP_PRODPV"	,.F. ,"099999999999999"))

If Select("cAliasVL") <> 0
	DBSelectArea("cAliasVL")
	cAliasVL->(DBCloseArea())
Endif

cAliasVL	:= GetNextAlias()

cSql	+= " SELECT *
cSql	+= " FROM SC6040
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= "		AND C6_FILIAL = '"+SC5->C5_FILIAL+"'
cSql	+= "		AND C6_NUM = '"+SC5->C5_NUM+"'
cSql	+= "		AND C6_PRODUTO <> '"+cProd+"'

//Conout("")
//Conout(cSql)
//Conout("")

TCQuery cSql NEW ALIAS 'cAliasVL'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasVL")
cAliasVL->(DbGoTop())

RestArea(aArea)
Return(cAliasVL->(EOF()))


//Valida bloqueio de estoque
Static Function xValLFin()
Local aArea		:= GetArea()
Local cSql		:= ""
Local cAliasC9
Local nValTotNF	:= 0
Local nRegs		:= 0
Local lRet		:= .T.
	
If Select("cAliasC9") <> 0
	DBSelectArea("cAliasC9")
	cAliasC9->(DBCloseArea())
Endif

cAliasC9	:= GetNextAlias()

/*
C9_BLCRED:
"" – Liberado
01 – Bloqueio de Credito por Valor
02 – Por Estoque – MV_BLQCRED = T
04 – Vencto do Limite de Credito
05 – Bloqueio de Credito por Estorno
06 – Bloqueio de Credito por Risco
09 – Rejeicao de Credito
10 – Faturado

C9_BLEST:
"" – Liberado
02 – Bloqueio de Estoque
03 – Bloqueio Manual de Estoque
10 – Faturado

C9_BLWMS:
01 – Bloqueio de Enderecamento do WMS/Somente SB2
02 – Bloqueio de Enderecamento do WMS
03 – Bloqueio de WMS – Externo
05 – Liberacao para Bloqueio 01
06 – Liberacao para Bloqueio 02
07 – Liberacao para Bloqueio 03
*/

cSql	+= " SELECT C9_BLEST,D_E_L_E_T_,*
cSql	+= " FROM SC9040
cSql	+= " WHERE C9_PEDIDO = '"+SC5->C5_NUM+"'
cSql	+= " AND C9_FILIAL = '"+SC5->C5_FILIAL+"'
cSql	+= " AND D_E_L_E_T_ = ''
cSql	+= " AND C9_BLCRED <> '' " //Valida o bloqueio Financeiro

//Conout("")
//Conout(cSql)
//Conout("")

TCQuery cSql NEW ALIAS 'cAliasC9'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasC9")
Count To nRegs

If nRegs > 0
	lRet	:= .F.
EndIf
cAliasC9->(DBCloseArea())

RestArea(aArea)
Return(lRet)