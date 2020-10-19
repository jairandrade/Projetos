#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'FILEIO.CH'
/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Atualização                                             |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_WSCOTACOES.PRW                                      |
+------------------+---------------------------------------------------------+
|Descricao         | WebServices Portal Confirmação de Cotações              |
+------------------+---------------------------------------------------------+
|Autor             | Lucas jose Correa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/04/2013                                              |
+------------------+--------------------------------------------------------*/

/*---------------------------------------------------------------------------+
|                         DECLARAÇÃO DE ESTRUTURAS                           |
+---------------------------------------------------------------------------*/

WSSTRUCT COTStruct
	WSDATA Numero     as String
	WSDATA DtValidade as Date
	WSDATA Proposta   as String
ENDWSSTRUCT

WSSTRUCT EMPStruct
	WSDATA Nome      as String
	WSDATA NomeCom   as String
	WSDATA Endereco  as String
	WSDATA Cidade    as String
	WSDATA Estado    as String
	WSDATA CEP       as String
	WSDATA CGC       as String
	WSDATA InscEst   as String
	WSDATA Tel       as String
ENDWSSTRUCT

WSSTRUCT FORNStruct
	WSDATA Codigo as String
	WSDATA Loja   as String
	WSDATA Nome   as String
	WSDATA Email  as String
	WSDATA Estado as String
	WSDATA Cnpj   as String
ENDWSSTRUCT

WSSTRUCT VALIDAStruct
	WSDATA Cotacao    as COTStruct
	WSDATA Empresa    as EMPStruct
	WSDATA Fornecedor as FORNStruct
	WSDATA Itens      as Array Of ProCodStruct Optional
	WSDATA ItensCod   as Array Of PagStruct    Optional
ENDWSSTRUCT

WSSTRUCT ProCodStruct
	WSDATA C8PRODUTO as String
	WSDATA C8ITEM    as String
	WSDATA B1DESC    as String OPTIONAL
	WSDATA C8PRECO   as String
	WSDATA C8QUANT   as String OPTIONAL
	WSDATA C8PRAZO   as String OPTIONAL
	WSDATA C8ALIIPI  as String OPTIONAL
	WSDATA C8PICM    as String OPTIONAL
	WSDATA C8XOBSWEB as String OPTIONAL
	WSDATA C8FRETE   as String OPTIONAL
	WSDATA C8DECLI   as String OPTIONAL
ENDWSSTRUCT

WSSTRUCT LISTAPROStruct
	WSDATA Itens AS Array Of ProCodStruct Optional
ENDWSSTRUCT

WSSTRUCT RETStruct
	WSDATA EMPRESA   as String
	WSDATA FILIAL    as String
	WSDATA Id        as String
	WSDATA Itens     as Array Of ProCodStruct
	WSDATA NumOrc    as String
	WSDATA Proposta  as String
	WSDATA TipoFrete as String
	WSDATA ValFrete  as String
	WSDATA TipoPgto  as String
ENDWSSTRUCT

WSSTRUCT EnvStruct
	WSDATA EMPRESA   as String
	WSDATA FILIAL    as String
	WSDATA CHAVE     as String
ENDWSSTRUCT

WSSTRUCT PagStruct
	WSDATA CODIGO    as String
	WSDATA DESCRICAO as String
ENDWSSTRUCT

WSSTRUCT LISTAPAGStruct
	WSDATA Itens AS Array Of PagStruct Optional
ENDWSSTRUCT

WSSTRUCT DECLINARStruct
	WSDATA EMPRESA  as String
	WSDATA FILIAL   as String
	WSDATA Id       as String
	WSDATA Motivo   as String
	WSDATA Proposta as String
ENDWSSTRUCT

WSSTRUCT LOGWSStruct
	WSDATA Ip       as String
	WSDATA Endereco as String
	WSDATA EMPRESA  as String
	WSDATA FILIAL   as String
	WSDATA Id       as String
	WSDATA Browse   as String
	WSDATA Versao   as String
ENDWSSTRUCT

/*---------------------------------------------------------------------------+
|                         DECLARAÇÃO DE SERVIÇO E MÉTODOS                    |
+---------------------------------------------------------------------------*/
WSSERVICE PORTALCOTACOES Description "Serviço Destinado a Confirmação da cotação por parte do fornecedor"

	// variaveis
	WSDATA CHAVE       as String          // CHAVE DA URL PARA VALIDAÇÃO
	WSDATA RETORNO     as String          // CHAVE DA URL PARA VALIDAÇÃO
	WSDATA VALIDARET   as VALIDAStruct    // retorna dados da validação da ID
	WSDATA COTENTRADA  as RETStruct       // dados de confirmação da cotação
	WSDATA EMP         as EnvStruct       // CHAVE DA URL PARA VALIDAÇÃO
	WSDATA DECLINA     as DECLINARStruct  // dados para declinar uma cotação inteira.
	WSDATA LOGWS       as LOGWSStruct     // dados para declinar uma cotação inteira.

	// métodos
	WSMETHOD GETCOM001 description "Valida chave disparada pela URL"
	WSMETHOD GETCOM002 description "Confirmacao de dados da Cotacao"
	WSMETHOD GETCOM003 description "Declina a cotacao, informando o motivo"
	WSMETHOD GETCOM004 description "Cria um log de acessos do registro do workflow"

ENDWSSERVICE

/*----------+-----------+-------+--------------------+------+----------------+
| Método    |GETCOM001  | Autor | Lucas J. C. Chagas | Data |  04/06/2012    |
+-----------+-----------+-------+--------------------+------+----------------+
| Descricao | Metodo que valida e retorna informacoes de cabecalho           |
+-----------+-------------------------------------------+------+-------------+
| Atualização                                           | Data | Analista    |
+-------------------------------------------------------+------+-------------+
|                                                       |      |             |
|                                                       |      |             |
|                                                       |      |             |
+-------------------------------------------------------+------+------------*/
WSMETHOD GETCOM001 WSRECEIVE EMP WSSEND VALIDARET WSSERVICE PORTALCOTACOES

Local aArea  := GetArea()
Local lRet   := .T.
Local aRet   := {}
Local aCond  := {}
Local oEmp   := Nil
Local oForn  := Nil
Local oCot   := Nil
Local oItem  := Nil
Local oItemC := Nil
Local nI     := 0

OpenSM0()
RPCSetType(3)
RpcSetEnv( ::EMP:EMPRESA, ::EMP:FILIAL,,, "COM", "MATA020",,,,,)
	if (empty(::EMP:CHAVE))
		SetSoapFault( "ERR001", 'A chave para a identificação da cotação não foi transmitida. / The key to identifying the quotation was not transmitted.' )
		lRet := .F.
	else
		aRet := U_WS001(::EMP:CHAVE)
		if aRet[1]
			oEmp := WsClassNew("EMPStruct")
			oEmp:Nome     := aRet[2,1]
			oEmp:NomeCom  := aRet[2,2]
			oEmp:Endereco := aRet[2,3]
			oEmp:Cidade   := aRet[2,4]
			oEmp:Estado   := aRet[2,5]
			oEmp:CEP      := aRet[2,6]
			oEmp:CGC      := aRet[2,7]
			oEmp:InscEst  := aRet[2,8]
			oEmp:Tel      := aRet[2,9]

			oForn := WsClassNew("FORNStruct")
			oForn:Codigo := aRet[4,1]
			oForn:Loja   := aRet[4,2]
			oForn:Nome   := aRet[4,3]
			oForn:Email  := aRet[4,4]
			oForn:Estado := aRet[4,5]
			oForn:Cnpj   := aRet[4,6]

			oCot := WsClassNew("COTStruct")
			oCot:Numero     := aRet[3,1]
			oCot:DtValidade := aRet[3,2]
			oCot:Proposta   := aRet[3,3]

			::VALIDARET:Cotacao    := oCot
			::VALIDARET:Empresa    := oEmp
			::VALIDARET:Fornecedor := oForn

			// condições de pagamento
			aCond := aClone(aRet[5])
			for nI := 1 to len(aCond)
				oItemC := WsClassNew("PagStruct")
				oItemC:CODIGO    := aCond[nI,1]
				oItemC:DESCRICAO := aCond[nI,2]

				AADD(::VALIDARET:ITENSCOD,oItemC)
			next nI

			aRet := U_WS002(::EMP:CHAVE)
			if aRet[1]
				aItem := aClone(aRet[2])
				for nI := 1 to len(aItem)
					oItem := WsClassNew("ProCodStruct")
					oItem:C8ITEM    := aItem[nI][1]
					oItem:C8PRODUTO := aItem[nI][2]
					oItem:B1DESC    := aItem[nI][3]
					oItem:C8QUANT   := aItem[nI][4]
					oItem:C8PRAZO   := '0'
					oItem:C8ALIIPI  := '0,00'
					oItem:C8PICM    := '0,00'
					oItem:C8PRECO   := '0,00'
					oItem:C8XOBSWEB := space(10)

					AADD(::VALIDARET:ITENS,oItem)
				next nI
			else
				SetSoapFault( aRet[2], aRet[3] )
				lRet := .F.
			endif
		else
			SetSoapFault( aRet[2], aRet[3] )
			lRet := .F.
		endif
	endif


RestArea(aArea)

//Desconecta a empresa
RpcClearEnv()

Return (lRet)

/*----------+-----------+-------+--------------------+------+----------------+
| Método    |GETCOM002  | Autor | Lucas J. C. Chagas | Data |  22/05/2013    |
+-----------+-----------+-------+--------------------+------+----------------+
| Descricao | Método WS para Manutenção de Dados de Clientes                 |
+-----------+-------------------------------------------+------+-------------+
| Atualização                                           | Data | Analista    |
+-------------------------------------------------------+------+-------------+
|                                                       |      |             |
|                                                       |      |             |
|                                                       |      |             |
+-------------------------------------------------------+------+------------*/
WSMETHOD GETCOM002 WSRECEIVE COTENTRADA WSSEND RETORNO WSSERVICE PORTALCOTACOES

Local aArea     := GetArea()
Local aEnvio    := {}
Local aItens    := {}
Local aLinha    := {}
Local aTeste    := {}
Local lRet      := .T.
Local nI        := 1
Local oProduto  := Nil

OpenSM0()
RPCSetType(3)
RpcSetEnv( ::COTENTRADA:EMPRESA, ::COTENTRADA:FILIAL,,, "COM", "MATA150",,,,,)
	if (empty(::COTENTRADA:Id))
		SetSoapFault( "ERR001", 'A chave para a identificação da cotação não foi transmitida. / The key to identifying the quotation was not transmitted.' )
		lRet := .F.
	else
		if (empty(::COTENTRADA:NumOrc))
			SetSoapFault( "ERR004", 'Numero do orçamento não informado! / Number of the budget not informed!' )
			lRet := .F.
		else
			if (empty(::COTENTRADA:TipoFrete))
				SetSoapFault( "ERR006", 'Tipo de Frete não informado! / Shipping Type Not Set!' )
				lRet := .F.
			else
				aAdd(aEnvio,::COTENTRADA:Id)
				aAdd(aEnvio,::COTENTRADA:NumOrc)
				aAdd(aEnvio,::COTENTRADA:TipoFrete)
				aAdd(aEnvio,::COTENTRADA:Proposta)

				while nI <= len(::COTENTRADA:Itens)
					oProduto := ::COTENTRADA:Itens[nI]
					aLinha := {}
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8PRODUTO)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8ITEM)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8PRECO)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8QUANT)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8PRAZO)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8ALIIPI)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8PICM)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8XOBSWEB)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8FRETE)
					aAdd(aLinha,::COTENTRADA:Itens[nI]:C8DECLI)

					aAdd(aItens, aClone(aLinha))
					ni++
				enddo

				aAdd(aEnvio, aClone(aItens))
				aAdd(aEnvio,::COTENTRADA:ValFrete)
				aAdd(aEnvio,::COTENTRADA:TipoPgto)

				aEnvio := U_WS003(aEnvio)
				if aEnvio[1]
					::RETORNO := aEnvio[2]
				else
					SetSoapFault( aEnvio[2], aEnvio[3] )
					lRet := .F.
				endif
			endif
		endif
	endif

RestArea(aArea)

Return (lRet)

/*----------+-----------+-------+--------------------+------+----------------+
| Método    | GETCOM003 | Autor | Lucas J. C. Chagas | Data |  12/06/2014    |
+-----------+-----------+-------+--------------------+------+----------------+
| Descricao | Método WS para declinar dados da cotação.                      |
+-----------+-------------------------------------------+------+-------------+
| Atualização                                           | Data | Analista    |
+-------------------------------------------------------+------+-------------+
|                                                       |      |             |
|                                                       |      |             |
|                                                       |      |             |
+-------------------------------------------------------+------+------------*/
WSMETHOD GETCOM003 WSRECEIVE DECLINA WSSEND RETORNO WSSERVICE PORTALCOTACOES

Local aArea  := GetArea()
Local aEnvio := {}
Local lRet   := .T.
Local nI     := 1
Local nTamFilial 	 := 0
Local nTamCotacao 	 := 0
Local nTamFornecedor := 0
Local nTamLoja 		 := 0

Private ParamIxb := {}

OpenSM0()
RPCSetType(3)
RpcSetEnv( ::DECLINA:EMPRESA, ::DECLINA:FILIAL,"000000",, "COM", "MATA150",,,,,)

nTamFilial 	:= TamSx3('C8_FILIAL')[1]
nTamCotacao 	:= TamSx3('C8_NUM')[1]
nTamFornecedor 	:= TamSx3('C8_FORNECE')[1]
nTamLoja 		:= TamSx3('C8_LOJA')[1]

	if (empty(::DECLINA:ID))
		SetSoapFault( "ERR001", 'A chave para a identificação da cotação não foi transmitida. / The key to identifying the quotation was not transmitted.' )
		lRet := .F.
	else

		// verifica se ja foi realizado o envio da cotação pelo fornecedor. Se ja foi enviado, bloqueia 
		cFilialP     := substr(::DECLINA:ID, 1, nTamFilial)
		cNumCotacao  := substr(::DECLINA:ID, nTamFilial + 1, nTamCotacao)
		cFornecedor  := substr(::DECLINA:ID, nTamFilial + nTamCotacao + 1, nTamFornecedor)
		cLoja        := substr(::DECLINA:ID, nTamFilial + nTamCotacao + nTamFornecedor + 1, nTamLoja)
		cNumProposta := substr(::DECLINA:ID, nTamFilial + nTamCotacao + nTamFornecedor + nTamLoja + 1)			
		
		DbSelectArea('SC8')	
		SC8->( dbSetOrder(1) ) 
		SC8->( DbSeek( cFilialP  + cNumCotacao  + cFornecedor + cLoja ) )  		
//		IF SC8->C8_QUANT > 0
//			SetSoapFault( "ERR001", 'A cotação já foi transmitida. Para declinar uma cotação ja enviada favor entrar em contato com o comprador responsável!' )
//			lRet := .F.
//			RestArea(aArea)
//			Return lRet
//		EndIf


		aAdd(aEnvio, ::DECLINA:ID)
		aAdd(aEnvio, ::DECLINA:Motivo)
		aAdd(aEnvio, Time())
		aAdd(aEnvio, dDatabase)
		aAdd(aEnvio, ::DECLINA:Proposta)

		aEnvio := U_WS004(aEnvio)
		if aEnvio[1]
			::RETORNO := aEnvio[2]

			aAdd(ParamIxb, '')
			aAdd(ParamIxb, '')
			aAdd(ParamIxb, ::DECLINA:ID)
			aAdd(ParamIxb, 'Workflow declinado pelo fornecedor.')
			aAdd(ParamIxb, '3')

			U_ACOM0020( 'SZ0', -1, 3 )
		else
			SetSoapFault( aEnvio[2], aEnvio[3] )
			lRet := .F.
		endif
	endif

RestArea(aArea)

Return (lRet)

/*----------+-----------+-------+--------------------+------+----------------+
| Método    | GETCOM004 | Autor | Lucas J. C. Chagas | Data |  13/06/2014    |
+-----------+-----------+-------+--------------------+------+----------------+
| Descricao | Método WS para log de acessos do workflow.                     |
+-----------+-------------------------------------------+------+-------------+
| Atualização                                           | Data | Analista    |
+-------------------------------------------------------+------+-------------+
|                                                       |      |             |
|                                                       |      |             |
|                                                       |      |             |
+-------------------------------------------------------+------+------------*/
WSMETHOD GETCOM004 WSRECEIVE LOGWS WSSEND RETORNO WSSERVICE PORTALCOTACOES

Local aArea  := GetArea()
Local lRet   := .T.
Local nI     := 1

Private ParamIxb := {}

OpenSM0()
RPCSetType(3)
RpcSetEnv( ::LOGWS:EMPRESA, ::LOGWS:FILIAL,,, "COM", "ACOM002",,,,,)
	if (empty(::LOGWS:ID))
		SetSoapFault( "ERR001", 'A chave para a identificação da cotação não foi transmitida. / The key to identifying the quotation was not transmitted.' )
		lRet := .F.
	else
		aAdd(ParamIxb, ::LOGWS:Ip)
		aAdd(ParamIxb, ::LOGWS:Endereco)
		aAdd(ParamIxb, ::LOGWS:Id)
		aAdd(ParamIxb, 'Workflow ' +::LOGWS:Id+ ' acessado via Web.')
		aAdd(ParamIxb, '1')
		aAdd(ParamIxb, ::LOGWS:Browse)
		aAdd(ParamIxb, ::LOGWS:Versao)

		U_ACOM0020( 'SZ0', -1, 3 )

		if !ParamIxb[1]
			SetSoapFault( ParamIxb[2], ParamIxb[3] )
			lRet := .F.
		endif
	endif

RestArea(aArea)

Return (lRet)