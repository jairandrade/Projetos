#INCLUDE "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#include 'protheus.ch'
//==================================================================================================//
//	Programa: NWPVNFM		|	Autor: Luis Paulo							|	Data: 01/01/2019	//
//==================================================================================================//
//	Descrição: Funcao para criar pedido nfse por job entre filiais									//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function NWPVNFM(cFilKP, cNumKP,cXIDVNFK,cCliente)
Local cEmpNew 	:= "04"
Local cFilNew	:= "01"
Private lRet	:= .T.
Private cAliasPV	

Conout("Criando pedido na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"NFMISTA","kylix125","FAT")
	
If !xLValVZPV(cFilKP, cNumKP,cCliente)
		xPvNFSE(cFilKP, cNumKP,cXIDVNFK)
	Else
		lRet	:= .F.
EndIf

Conout("Pedido na 0401..."+SC5->C5_NUM+"/"+cXIDVNFK)
conout("cEmpNew = " + cFilKP)
conout("cFilNew = " + cFilNew)

(cAliasPV)->(DBCloseArea())	
Return(lRet)


//Valida se os produtos possuem vinculo
Static Function xLValVZPV(cFilKP, cNumKP,cCliente)
Local aArea		:= GetArea()
Local cSql		:= ""

cAliasPV	:= GetNextAlias()

cSql	+= " SELECT SC6.C6_QTDVEN,SC6.C6_NUM,
cSql	+= " 		SC6.C6_VALOR,SC6.C6_ITEM,
cSql	+= "		SC6.C6_VALOR -((ZPV.ZPV_PORCPR * SC6.C6_VALOR)/100) AS VPVPROD, 
cSql	+= "		((SC6.C6_VALOR -((ZPV.ZPV_PORCPR * SC6.C6_VALOR)/100))/C6_QTDVEN) AS VLRVEND,
cSql	+= "		(((ISNULL(ZPV_PORCPR,0)) * SC6.C6_VALOR)/100) AS VALOR,SC5.*
cSql	+= " FROM SC6040 SC6
cSql	+= " INNER JOIN ZPV040 ZPV ON SC6.C6_PRODUTO = ZPV.ZPV_PROD AND ZPV_CLIENT = '"+cCliente+"' AND ZPV.D_E_L_E_T_ = '' 
cSql	+= " INNER JOIN SC5040 SC5 ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND ZPV.D_E_L_E_T_ = ''  
cSql	+= " WHERE	SC6.D_E_L_E_T_ = ''
cSql	+= "		AND SC6.C6_FILIAL = '"+cFilKP+"'
cSql	+= "		AND SC6.C6_NUM = '"+cNumKP+"'
cSql	+= " ORDER BY C6_NUM,C6_ITEM

Conout("")
//Conout(cSql)
Conout("")

TCQuery cSql New Alias (cAliasPV)		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea((cAliasPV))
(cAliasPV)->(DBGoTop())

Return (cAliasPV)->(EOF())

//Gera o pedido para NFSE
Static Function xPvNFSE(cFilKP, cNumKP,cXIDVNFK)
Local	cDoc		:= ""
Local 	aCabec 		:= {}
Local	aItens 		:= {}
Local 	aLinha 		:= {}
Local 	cProd		:= Alltrim( SuperGetMV("KP_PRODPV"	,.F. ,"099999999999999"))
Local 	cTES		:= Alltrim( SuperGetMV("KP_TESPVNF"	,.F. ,"989"))
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVNF"	,.F. ,"52")) //PRESTACAO DE SERVICOS
Local 	nValTot		:= 0
Local 	aBloqueio	:= {}
Local 	aPvlNfs		:= {}
Local 	nCount		:= 0
Local 	dBkpDTEm	:= Stod((cAliasPV)->(C5_EMISSAO))
Local 	dBkpDTBS	:= dDataBase
Local `	cErro		:= ""
Local 	cPvSPP		:= (cAliasPV)->C5_XPVSPC
Local 	cCDSPP 		:= (cAliasPV)->C5_XCODPAU
Local 	cStSPP 		:= (cAliasPV)->C5_XSTSSPP
Private lMsErroAuto	:= .F.

//cDoc 	:=  GetSxeNum("SC5","C5_NUM")
//ConfirmSx8()

//aadd(aCabec,{"C5_NUM"   	,cDoc,Nil})
aadd(aCabec,{"C5_TIPO" 		,"N",Nil})
aadd(aCabec,{"C5_CLIENTE"	,(cAliasPV)->C5_CLIENTE,Nil})
aadd(aCabec,{"C5_LOJACLI"	,(cAliasPV)->C5_LOJACLI,Nil})
aadd(aCabec,{"C5_LOJAENT"	,(cAliasPV)->C5_LOJAENT,Nil})
aadd(aCabec,{"C5_CONDPAG"	,(cAliasPV)->C5_CONDPAG,Nil})
aadd(aCabec,{"C5_TPFRETE"	,(cAliasPV)->C5_TPFRETE,Nil})
aadd(aCabec,{"C5_K_TPCL"	,(cAliasPV)->C5_K_TPCL ,Nil})
aadd(aCabec,{"C5_TIPOCLI"	,(cAliasPV)->C5_TIPOCLI,Nil})
aadd(aCabec,{"C5_CONDPAG"	,(cAliasPV)->C5_CONDPAG,Nil})
aadd(aCabec,{"C5_VEND1"		,(cAliasPV)->C5_VEND1  ,Nil})
aadd(aCabec,{"C5_USER"		,(cAliasPV)->C5_USER  ,Nil})
aadd(aCabec,{"C5_K_OPER"	,cOP  			,Nil})
aadd(aCabec,{"C5_XIDVNFK"	,cXIDVNFK		,Nil})
aadd(aCabec,{"C5_XTIPONF"	,"2"			,Nil})
aadd(aCabec,{"C5_XSITLIB"	,"6"			,Nil})
aadd(aCabec,{"C5_XGERASV"	,"S"			,Nil})

If Alltrim((cAliasPV)->C5_XPVSPC) == "S" .And. !(Empty((cAliasPV)->C5_XCODPAU))
	aadd(aCabec,{"C5_XPVSPC"	,(cAliasPV)->C5_XPVSPC		,Nil})
	aadd(aCabec,{"C5_XCODPAU"	,(cAliasPV)->C5_XCODPAU	,Nil})
EndIf


DBSelectArea((cAliasPV))
(cAliasPV)->(DBGoTop())

While !(cAliasPV)->(EOF())
    
    nCount++
    aLinha := {}
	aadd(aLinha,{"C6_ITEM"		,StrZero(nCount,2),Nil})
	aadd(aLinha,{"C6_PRODUTO"	,cProd			,Nil})
	//aadd(aLinha,{"C6_XLARG	"	,1				,Nil})
	//aadd(aLinha,{"C6_XCOMPRI"	,1				,Nil})
	//aadd(aLinha,{"C6_XQTDPC"	,1				,Nil})
	
	aadd(aLinha,{"C6_QTDVEN"	,1				,Nil})
	aadd(aLinha,{"C6_OPER"		,cOP			,Nil})
	//aadd(aLinha,{"C6_TES"		,cTES			,Nil})
	aadd(aLinha,{"C6_PRCVEN"	,(cAliasPV)->VALOR,Nil})
	aadd(aLinha,{"C6_PRUNIT"	,(cAliasPV)->VALOR,Nil})
	aadd(aLinha,{"C6_XIDVNFK"	,cXIDVNFK + "-" + (cAliasPV)->C6_ITEM	,Nil})
	//aadd(aLinha,{"C6_VALOR"		,nValTot		,Nil})
	
	aadd(aItens,aLinha)
    
    (cAliasPV)->(DBSkip())
EndDo


dDataBase	:= dBkpDTEm

Begin Transaction
MATA410(aCabec,aItens,3)
If !lMsErroAuto
	    ConOut("Pedido de serviço incluido com sucesso!!! "+cDoc)
	    //MsgInfo("Pedido de serviço incluido com sucesso!!! "+cDoc, "NFSE KAPAZI")
	    lIncPNF	:= .T.
	Else
		cErro	:= MostraErro("\NFMistaErro\")
		Conout(cErro)
		Conout("Erro na inclusao do pedido de venda de serviço, informe o TI!")
	    ConOut("Erro na inclusao do pedido de venda de serviço, informe o TI!")
	    DisarmTransaction()
	    lRet	:= .F.
EndIf
End Transaction

dDataBase	:= dBkpDTBS

If lIncPNF
	// Liberacao de pedido
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	// Checa itens liberados
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	
	RECLOCK("SC5", .F.)  
	SC5->C5_XSITLIB := "7"
	SC5->C5_XIDVNFK	:= cXIDVNFK
	SC5->C5_XPVSPC	:= cPvSPP 
	SC5->C5_XCODPAU	:= cCDSPP 
	SC5->C5_XSTSSPP	:= cStSPP
	MSUNLOCK()
	
	LibBlCre(SC5->C5_NUM)	//Liberacao de crédito
	//LibBlEst(SC5->C5_NUM)	//Liberacao de Estoque Manual
	
EndIf
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! IndLF      ! Autor !Luis Paulo  ! Data ! 02/01/2018  		   !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Identifica a ordem do indice XIDNFSE		                   !
+-----------+--------------------------------------------------------------+
*/

Static Function IndLF()
Local aArea    := GetArea()
Local nOrdLF
Local nOrdSC5

DbSelectArea("SC5")
nOrdSC5 := IndexOrd()

SC5->(dbOrderNickName("XIDNFSE"))
nOrdLF := IndexOrd()
SC5->(DbSetorder(nOrdSC5))

RestArea(aArea)
Return(nOrdLF)

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