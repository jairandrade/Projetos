#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: NWNFSEKP		|	Autor: Luis Paulo							|	Data: 01/01/2019	//
//==================================================================================================//
//	Descrição: Funcao para criar NF nfse por job entre filiais										//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function NWNFSEKP(cIdNFSE,cNumNfK)
Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Private lRet		:= .T.
Private cCondPGK	:= ""
Private lPedSpp		:= .F.
	
Conout("Criando NFSE na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"NFMISTA","kylix125","FAT")
	
xGeraNFSE(cIdNFSE,cNumNfK)		
xGerFKAP(cIdNFSE,cNumNfK) //Liquidacao-Fatura

Conout("NF na 0401..."+SF2->F2_DOC+"/"+cIdNFSE)
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)
	
Return(lRet)

Static Function xGeraNFSE(cIdNFSE,cNumNfK)
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

//Posiciona no pedido para liberação
DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5") + cIdNFSE + "2" )) //Posiciona no pedido de serviço
		
		If Alltrim(SC5->C5_XPVSPC) == 'S'
			lPedSpp	:= .T.
		EndIf
				
		cCondPGK	:= SC5->C5_CONDPAG
		
		// Liberacao de pedido
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		// Checa itens liberados
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
		//Grupo de pergunta de geracao de nota
		//Pergunte("MT460A",.F.)
		
		//For nx := 1 to 30
			//aParam460[nx] := &("mv_par" + StrZero(nx, 2) )
		//Next nx
		
		// Caso tenha itens liberados manda faturar
		If Empty(aBloqueio) .And. !Empty(aPvlNfs)
				cNumNFS := MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
				
				If !Empty(cNumNFS)
						cQr := " UPDATE SE1040
						cQr += " SET E1_XIDVNFK = '"+cIdNFSE+"'
						cQr += " WHERE D_E_L_E_T_ = ''
						cQr += " 	AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
						cQr += " 	AND E1_NUM = '"+SF2->F2_DOC+"'
						cQr += " 	AND E1_TIPO = 'NF'
						TcSqlExec(cQr)
						
						Conout("NFSE gerada com sucesso!!! NF: "+cNumNFS + " -- Serie: " + Alltrim(SF2->F2_SERIE) + " -- ID: "+cIdNFSE)
					Else
						//MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! ->"+ SC5->C5_NUM + "ID: "+cIdNFSE, "NFSE KAPAZI")
				EndIf
				
			Else
				//MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! -> "+ SC5->C5_NUM + " -- ID: "+cIdNFSE, "NFSE KAPAZI")
		EndIf
	Else
		//MsgInfo("NFSE - Não foi possível localizar o pedido de venda(serviço)!!! ID: "+cIdNFSE, "NFSE KAPAZI")
EndIf


If lPedSpp
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "2" //Servico
		SF2->F2_XPVSPP 	:= "S"
		MsUnlock()
	Else
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "2" //Servico
		SF2->(MsUnlock())
EndIf

DbSelectArea(cBkp)
RestArea(aArea)
SF2->(DbSetOrder(nIndSF2))
SF2->(DbGoTo(nRecSF2))
SD2->(DbSetOrder(nIndSD2))
SD2->(DbGoTo(nRecSD2))
Return()


Static Function xGerFKAP(cIdNFSE,cNumNfK)
Local cParceAt		:= ''
Local cParceNw		:= ''
Local cTipoTit		:= "FT"
Local nValor		:= 0 
Local nZ			:=1
Local cNumLiq
Local cFiltro		:= ""
Local aCab			:= {}
Local aParcelas		:= {}
Local aItens		:= {}
Local lCont			:= .T.
Private cFatura		:= ""
Private lMsErroAuto	:= .F.
 
If Select('FATKAPAZ')<>0
	FATKAPAZ->(DBCloseArea())
Endif

cQr := " SELECT E1_XIDVNFK,*
cQr += " FROM SE1040
cQr += " WHERE	D_E_L_E_T_ = ''
cQr += "		AND E1_XIDVNFK = '"+cIdNFSE+"'
cQr += "		AND E1_EMISSAO = '"+DTOS(dDatabase)+"'
cQr += " ORDER BY E1_VENCTO,E1_PREFIXO

TcQuery cQr new alias "FATKAPAZ"

DbSelectArea("FATKAPAZ")
FATKAPAZ->(DbGoTop())

While !FATKAPAZ->(EOF())

	nValor	+= FATKAPAZ->E1_VALOR
	FATKAPAZ->(DbSkip())
EndDo

DbSelectArea("FATKAPAZ")
FATKAPAZ->(DbGoTop())

//Filtro do Usuário
//cFiltro := " E1_FILIAL == '"+xFilial("SE1")+"' .And. "
cFiltro := " E1_CLIENTE == '" + FATKAPAZ->E1_CLIENTE + "' .And. E1_LOJA == '" + FATKAPAZ->E1_LOJA + "' .And. "
cFiltro += " E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. "
cFiltro += " DTOS(E1_EMISSAO) == '" + DTOS(dDataBase) + "' .And. "
cFiltro += " E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "' .And. "
cFiltro += " E1_XIDVNFK == '" + cIdNFSE + "'"

If !lPedSpp
		//Array do processo automatico (aAutoCab)
		aCab:={	{ "cCondicao"	, cCondPGK 					},;
				{ "cNatureza"	, FATKAPAZ->E1_NATUREZ	 	},;
				{ "E1_TIPO"		, cTipoTit 					},;
				{ "cCliente"	, FATKAPAZ->E1_CLIENTE 		},;
				{ "nMoeda"		, FATKAPAZ->E1_MOEDA		},;		
				{ "cLoja"		, FATKAPAZ->E1_LOJA 		} }
	Else
		//Array do processo automatico (aAutoCab)
		aCab:={	{ "cCondicao"	, cCondPGK 					},;
				{ "cNatureza"	, FATKAPAZ->E1_NATUREZ	 	},;
				{ "E1_TIPO"		, cTipoTit 					},;
				{ "cCliente"	, "999999" 					},;
				{ "nMoeda"		, FATKAPAZ->E1_MOEDA		},;		
				{ "cLoja"		, "01" 						} }
EndIf
//------------------------------------------------------------
//Monta as parcelas de acordo com a condição de pagamento
//------------------------------------------------------------
aParcelas:=Condicao(nValor,cCondPGK,,dDataBase)

//--------------------------------------------------------------
//Não é possivel mandar Acrescimo e Decrescimo junto.
//Se mandar os dois valores maiores que zero considera Acrescimo
//--------------------------------------------------------------

While lCont
	cNumLiq 	:= cNumNfK
	lCont		:= ValidNuLi(cNumLiq,lCont)
	
	If lCont
		cNumLiq		:= GetMv("MV_NUMLIQ")
		cNumLiq		:= Soma1(cNumLiq,Len(Alltrim(cNumLiq)))  
		lCont		:= ValidNuLi(cNumLiq,lCont)
		
		If lCont
				PutMv("MV_NUMLIQ",cNumLiq)
			Else
				PutMv("MV_NUMLIQ",cNumLiq)
		EndIf
		
	EndIf
	
EndDo


For nZ:=1 to Len(aParcelas)
	//Dados das parcelas a serem geradas                         
	Aadd(aItens,{	{"E1_PREFIXO"	,"FAT"  		},;//Prefixo
					{"E1_BCOCHQ" 	,""  			},;//Banco
					{"E1_AGECHQ" 	,""  			},;//Agencia
					{"E1_CTACHQ" 	,""  			},;//Conta
					{"E1_NUM"  		,cNumLiq   		},;//Nro. cheque (dará origem ao numero do titulo)
					{"E1_PARCELA"  	,StrZero(nZ,2)   },;//Parcela
					{"E1_VENCTO" 	,aParcelas[nZ,1]},;//Data boa 
					{"E1_VLCRUZ" 	,aParcelas[nZ,2]},;//Valor do cheque/titulo
					{"E1_ACRESC" 	,0    			},;//Acrescimo
					{"E1_DECRESC" 	,0    			}})//Acrescimo
					//{"E1_EMITCHQ" 	,"ZELAO"  },;//Emitente do cheque
//cNumLiq	:=	Soma1(cNumLiq,Len(Alltrim(cNumLiq)))
//PutMv("MV_NUMLIQ",cNumLiq)	
Next nZ

pergunte("AFI460",.F.)
MV_PAR08	:= "FAT"
If Len(aParcelas) > 0
	//Liquidacao e reliquidacao   
	//FINA460(nPosArotina,aAutoCab,aAutoItens,nOpcAuto,cAutoFil,cNumLiqCan)
	//FINA460(,aCab,aItens,3,cFiltro)
//	pergunte("AFI460",.F.)
//	MV_PAR01	:= 2
	Begin Transaction
	MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},,aCab,aItens,3,cFiltro)
	If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Conout("Erro na geracao de faturas!")
		Else
			Conout("Faturas geradas com sucesso!!! -> " + cNumNfK )
	EndIf
	End Transaction
	xAtualLiq(cIdNFSE,cNumLiq)
	// Este aviso funciona apenas para teste monousuario
	//Alert("Liquidacao Incluida -> "+GetMv("MV_NUMLIQ")) 
Endif

FATKAPAZ->(DbCloseArea())
Return()

Static Function xAtualLiq(cIdNFSE,cNumLiq)
Local cSql	:= ""

cSql	:= " UPDATE SE1040 "
cSql	+= " SET E1_XIDVNFK = '"+cIdNFSE+"' "
cSql	+= " WHERE E1_PREFIXO = 'FAT' "
cSql	+= " AND E1_NUM = '"+ StrZero((Val(cNumLiq)),9)+"'"
cSql	+= " AND E1_TIPO = 'FT' "

If !lPedSpp
		cSql	+= " AND E1_CLIENTE = '"+FATKAPAZ->E1_CLIENTE+"' "
		cSql	+= " AND E1_LOJA = '"+FATKAPAZ->E1_LOJA+"'	"
	Else
		cSql	+= " AND E1_CLIENTE = '999999' "
		cSql	+= " AND E1_LOJA = '01'	"
EndIf
cSql	+= " AND E1_EMISSAO = '"+ DTOS(dDataBase) +"' "
cSql	+= " AND E1_XIDVNFK = '' "
cSql	+= " AND D_E_L_E_T_ = '' "

//Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif
Return()

//Valida se tem um numero de fatura na base
Static Function ValidNuLi(cNumLiq,lCont)
Local lRet		:= lCont
Local cSql		:= ""
Local cAliasFT	
Local nRegs		:= 0

If Select('cAliasFT')<>0
	cAliasFT->(DBSelectArea('cAliasFT'))
	cAliasFT->(DBCloseArea())
Endif

cSql	:= " SELECT E1_NUMLIQ,*
cSql	+= " FROM SE1040
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= "		AND E1_PREFIXO = 'FAT'
cSql	+= "		AND E1_TIPO = 'FT'
cSql	+= "		AND E1_NUM = '"+ (StrZero((Val(cNumLiq)),9)) +"'
cSql	+= "		AND E1_FILIAL = '"+xFilial("SE1")+"'

TcQuery cSql new Alias "cAliasFT"
Count To nRegs

If nRegs = 0 //Caso nao tenha registros, esta Ok e retorna falso
	lRet := .F.
EndIf

cAliasFT->(DbCloseArea())
Return(lRet)