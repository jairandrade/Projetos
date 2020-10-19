/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Financiero                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para enviar dados dos títulos a pagar!
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/07/2018                                              !
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

wsStruct StEstoque

	wsdata MATERIAL                as string 
	wsdata SaldoDisponivel        as float 
	wsdata Saldototal	          as float
	wsdata QtdPedidoCompra        as float
	wsdata PrevisaoEntrega        as date optional
	wsdata Status                 as string
	wsdata Erro                   as string
	
endWsStruct

wsStruct StOrdemProducao

	wsdata DataInicio	          as date 
	wsdata DataFim		          as date 
	wsdata CodigoBem        	  as string optional
	wsdata NomeBem        		  as string optional
	wsdata ItemConta        	  as string 
	wsdata Operacao	        	  as string 
	wsdata CentroCusto       	  as string 
	wsdata ContaContabil       	  as string optional
	wsdata NumOM	        	  as string 
	wsdata Usuario	        	  as string 
	wsdata Senha      	  	      as string 
    WSDATA MATERIAL			  	  As Array Of StMaterialOp
    WSDATA ExcluiOm				  as boolean 
    WSDATA Rotina				  as string  
	
endWsStruct


wsStruct StBaixaCombustivel

	wsdata Data        			  as date 
	wsdata ItemConta        	  as string 
	wsdata Operacao	        	  as string 
	wsdata CentroCusto       	  as string 
	wsdata ContaContabil       	  as string
	wsdata Usuario	        	  as string 
	wsdata Senha      	  	      as string 
    WSDATA MATERIAL			  	  As string 
    WSDATA MATRICULA		  	  As string
    WSDATA QUANTIDADE   	  	  As float
	
endWsStruct

wsStruct StMaterialOp

	wsdata Material               as string
	wsdata Quantidade             as float
	wsdata NumReserva      	  	  as string 
	
endWsStruct

wsStruct StRetornoOp

	wsdata Status                 as string
	wsdata Erro                   as string
	
endWsStruct

WSSTRUCT StMateriais
	wsdata DataProgramacao         as date 
	wsdata NumOM	        	  as string optional
	wsdata NumReserva      	  	  as string optional
	wsdata Usuario	        	  as string optional
	wsdata Senha      	  	      as string optional
    WSDATA MATERIAL			  	  As Array Of StMaterial
ENDWSSTRUCT

wsStruct StMaterial
	wsdata CODIGO           	  as string
	wsdata QuantidadeSolicitada	  as float         
endWsStruct


WSSERVICE WsManusis  description "WebService para Integração entre Protheus e Manusis."

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata Usuario 		 		 as string 	
	wsdata Senha 		 		 as string 
	
	wsdata Materiais          as  StMateriais
	wsdata StRetornoOp 	      as  StRetornoOp
	wsdata OrdemProducao      as  StOrdemProducao
	wsdata BaixasCombustivel  as  StBaixaCombustivel
	
	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oStEstoques  as Array of StEstoque
	
	// DELCARACAO DO METODOS
	WSMETHOD ESTOQUE   	      description "Retorna o saldo em estoque dos MATERIALs solicitasdos."
	WSMETHOD GRAVAOP   		  description "Recebe a OM do Manusis e grava a OP no Protheus."
endWSSERVICE

/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna o saldo em estoque dos MATERIALs solicitasdos!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
WSMETHOD ESTOQUE WSRECEIVE Materiais WSSEND oStEstoques WSSERVICE WsManusis
	lOCAL cAlias
	Local cAliasFunc
	Local aMateriais := ::Materiais
	Local aLog       := {}
	Local nSldB2     := 0
	Local nSldTot    := 0
	Local nInd
	cErro := validaPar(aMateriais)

	
	if !empty(cErro)
		AAdd(oStEstoques, WsClassNew("StEstoque"))
		oStEstoques[len(oStEstoques)]:MATERIAL 			   := ''
		//Inicia os saldos em 0, pois se encontrar substitui, se não segue 0
		oStEstoques[len(oStEstoques)]:SaldoDisponivel      := 0
		oStEstoques[len(oStEstoques)]:Saldototal      	   := 0
		oStEstoques[len(oStEstoques)]:QtdPedidoCompra      := 0
		oStEstoques[len(oStEstoques)]:Status               := '0'
		oStEstoques[len(oStEstoques)]:Erro                 := cErro
	ELSE
	
		FOR nInd := 1 to LEN(aMateriais:Material)	
			nSldB2    := 0
			nSldTot   := 0
			nSldPc    := 0
			dDtCompr  := CTOD('  /  /    ')
	
			AAdd(oStEstoques, WsClassNew("StEstoque"))
			oStEstoques[len(oStEstoques)]:MATERIAL 			   := aMateriais:MATERIAL[nInd]:CODIGO
			//Inicia os saldos em 0, pois se encontrar substitui, se não segue 0
			oStEstoques[len(oStEstoques)]:SaldoDisponivel      := 0
			oStEstoques[len(oStEstoques)]:Saldototal      	   := 0
			oStEstoques[len(oStEstoques)]:QtdPedidoCompra      := 0
			oStEstoques[len(oStEstoques)]:Status               := '1'
			oStEstoques[len(oStEstoques)]:Erro                 := ''
			
			dDatabase := aMateriais:DataProgramacao
			
			dbSelectArea('SB1')
			DbsetOrder(1)
			IF SB1->(DBSeek(xFilial('SB1')+ALLTRIM(aMateriais:MATERIAL[nInd]:CODIGO)))
			
				IF VALTYPE(aMateriais:MATERIAL[nInd]:QUANTIDADESOLICITADA) != 'F' .AND.  VALTYPE(aMateriais:MATERIAL[nInd]:QUANTIDADESOLICITADA) != 'N'
					oStEstoques[len(oStEstoques)]:Status               := '0'
					oStEstoques[len(oStEstoques)]:Erro                 := 'Quantidade solicitada deve ser numérico.'
				elseIF aMateriais:MATERIAL[nInd]:QUANTIDADESOLICITADA <= 0
					oStEstoques[len(oStEstoques)]:Status               := '0'
					oStEstoques[len(oStEstoques)]:Erro                 := 'Quantidade solicitada deve ser maior que 0.'
				ENDIF
				IF oStEstoques[len(oStEstoques)]:Status == '1'
					dbSelectArea('SB2')
					DbsetOrder(1)
					
					IF SB2->(DBSeek(xFilial('SB2')+SB1->B1_COD+SB1->B1_LOCPAD))		
					    nSldB2 := saldoSb2()
						nSldTot := SB2->B2_QATU
			
						oStEstoques[len(oStEstoques)]:SaldoDisponivel  := nSldB2
						oStEstoques[len(oStEstoques)]:Saldototal       := nSldTot
					
					ENDIF	
					
					cAlias := getNextAlias()

					BeginSQL Alias cAlias

						SELECT SUM(C7_QUANT) AS TOTALC7, MIN(C7_DATPRF) AS PRIMDATA
						FROM %TABLE:SC7% SC7
						LEFT JOIN SD1020 SD1 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND D1_FORNECE = C7_FORNECE 
						AND D1_LOJA = C7_LOJA  AND C7_PRODUTO = D1_COD AND SD1.%NotDel%  
						WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:xFilial('SC7')%  AND C7_PRODUTO = %EXP:SB1->B1_COD% 
						AND D1_DOC IS NULL AND C7_DATPRF >= %EXP:DTOS(dDataBase)% 
					
					EndSQL
					
					//Não encontrou
					IF !(cAlias)->(Eof()) .AND. VALTYPE((cAlias)->TOTALC7) == 'N' .AND. (cAlias)->TOTALC7 > 0
						nSldPc    := (cAlias)->TOTALC7
						dDtCompr  := STOD((cAlias)->PRIMDATA)
						oStEstoques[len(oStEstoques)]:QtdPedidoCompra := nSldPc	
						oStEstoques[len(oStEstoques)]:PrevisaoEntrega := dDtCompr
					ENDIF
					
					(cAlias)->(dbCloseArea())
				ENDIF
			ELSE	
				oStEstoques[len(oStEstoques)]:Status               := '0'
				oStEstoques[len(oStEstoques)]:Erro                 := 'Código de MATERIAL inválido. Código: '+aMateriais:MATERIAL[nInd]:CODIGO
			ENDIF
			
			aadd(aLog,{aMateriais:MATERIAL[nInd]:CODIGO,aMateriais:NumOM,aMateriais:NumReserva,aMateriais:DataProgramacao,;
			aMateriais:MATERIAL[nInd]:QUANTIDADESOLICITADA,nSldB2,nSldTot,nSldPc,dDtCompr,oStEstoques[len(oStEstoques)]:Erro,DATE(),TIME(),0 })
			
		NEXT
	ENDIF
	
	IF LEN(aLog) > 0
		GRAVALOGEST(aLog)
	ENDIF
	
return .T. /* fim do metodo  */

STATIC FUNCTION GRAVALOGEST(aLogs)
Local cCodigo := GETSX8NUM("ZZH","ZZH_NUMERO")
Local aSemEst := {}
Local nInd
	FOR nInd := 1 to LEN(aLogs)	
	
		RecLock("ZZH",.T.)
		
		ZZH->ZZH_FILIAL := xFilial('ZZH')
		ZZH->ZZH_NUMERO := cCodigo
		ZZH->ZZH_DATA   := aLogs[nInd][11]
		ZZH->ZZH_HORA   := aLogs[nInd][12]
		ZZH->ZZH_PRODUT := aLogs[nInd][1]
		ZZH->ZZH_DESC   := POSICIONE('SB1',1,xFilial('SB1')+RTRIM(aLogs[nInd][1]),'B1_DESC')
		ZZH->ZZH_QTDSOL := aLogs[nInd][5]
		ZZH->ZZH_QTDPED := aLogs[nInd][8]
		ZZH->ZZH_QTDDIS := aLogs[nInd][6]
		ZZH->ZZH_QTDTOT := aLogs[nInd][7]
		ZZH->ZZH_DTPRG  := aLogs[nInd][4]
		ZZH->ZZH_DTCOMP := aLogs[nInd][9]
		ZZH->ZZH_ERRO   := aLogs[nInd][10]
		ZZH->ZZH_RESERV := aLogs[nInd][3]
		ZZH->ZZH_OM  	:= aLogs[nInd][2]
		ZZH->ZZH_MAIL   := '2'
		ZZH->(msUnlock())
		aLogs[nInd][13] := ZZH->(RECNO())
		//Se a quantidade solicitada for maior que a disponível
		if aLogs[nInd][5] > aLogs[nInd][6]
			aadd(aSemEst,aLogs[nInd])
		endif
		
	NEXT
	ConfirmSX8() 
	
	//Envia o e-mail em outra conexão para não deixar lenta a consulta de estoque
	if len(aSemEst) > 0
		STARTJOB("U_MNSEMES1", GetEnvServer(), .F., cEmpAnt, cFilAnt,aSemEst)	
	endif
	
return cCodigo

/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Grava a OP apartir de uma OM
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/

WSMETHOD GRAVAOP WSRECEIVE OrdemProducao WSSEND StRetornoOp WSSERVICE WsManusis
		
	Local aMata650    := {}
	Local aOrdemManut := ::OrdemProducao
	Local cOperacao   
	Local cErro       := ''
	Local aNumOp      := {}
	Local cCodLog     := ''
	Local _cNumOm	  := ''
	Local nIndOp
	Local oManusis 
	Private aLog        := {}
	//variaveis para o ExecAuto
	Private lMsErroAuto := .F.
	
	Private aRenoOp    := {}
	public aLotesEmp := {}//itens para empenho
	PUBLIC cEnderecoFail := ''
	
	self:StRetornoOp:Status    := '1'
	self:StRetornoOp:Erro      := ''
	
	if aOrdemManut:OPERACAO == 'E'
		cOperacao := 5
	elseif aOrdemManut:OPERACAO == 'I'
		cOperacao := 3
	ELSE
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      := 'Operação inválida.'
	ENDIF
		
	BEGIN TRANSACTION
	
	IF(!EMPTY(aOrdemManut:NUMOM))
		_cNumOm := aOrdemManut:NUMOM
	Else
		_cNumOm := 'OM VAZIA'
	ENDIF
	
	oManusis  := ClassIntManusis():newIntManusis()      
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := _cNumOm
	oManusis:cTipo	    := 'I' 
	oManusis:cStatus    := 'P'
	oManusis:cEntidade  := 'SC2'
	oManusis:cOperacao  := aOrdemManut:OPERACAO
	oManusis:cRotina    := 'WsManusis.PRW'
	oManusis:cErroValid := self:StRetornoOp:Erro 
	oManusis:cErroCmp	:= self:StRetornoOp:Erro 
		
	//Guarda o log de integração
	IF !oManusis:gravaLog()
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      += ' Erro ao gravar log: '+oManusis:cErroValid 
	ENDIF
	
	cErro := validaOM(aOrdemManut,cOperacao)
//	If aOrdemManut:OPERACAO == 'I'
		//Armazena o espelho da OM enviada
		cCodLog := gravaLogOm(aOrdemManut)
//	ENDIF
	
	END TRANSACTION
	//FINALIZA  a transação do log e começa a transação da OP
	BEGIN TRANSACTION

	if !empty(cErro)
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      += ' Não foi possível '+IF(aOrdemManut:OPERACAO=='I','gravar','excluir')+' a OP: '+cErro
	EndIf
	
	IF self:StRetornoOp:Status == '1'
				
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + 'MANUTENCAO' ) )
		
		//Está criando a conexão com dDataBase vazio. Isto gera erro no execauto
		dDataBase := DATE()
		
		aAdd( aMata650, {'C2_FILIAL', xFilial('SC2')    , nil })
		aAdd( aMata650, {'C2_PRODUTO', SB1->B1_COD    , nil })
		aAdd( aMata650, {'C2_LOCAL'  , SB1->B1_LOCPAD , nil })
		aAdd( aMata650, {'C2_QUANT'  , 1 , nil })
		aAdd( aMata650, {'C2_EMISSAO', DATE()      , nil })
		aAdd( aMata650, {'C2_DATPRI' , OrdemProducao:DataInicio, nil })
		aAdd( aMata650, {'C2_DATPRF' , OrdemProducao:DataFim, nil })
		aAdd( aMata650, {'C2_ITEMCTA', ALLTRIM(OrdemProducao:ItemConta), nil })
		aAdd( aMata650, {'C2_CC'	 , ALLTRIM(OrdemProducao:CentroCusto), nil })
		aAdd( aMata650, {'C2_XNUMOM' , ALLTRIM(OrdemProducao:NUMOM), nil })
		aAdd( aMata650, {'C2_XCONTA' , ALLTRIM(OrdemProducao:ContaContabil), nil })
		//aAdd( aMata650, {'C2_XNUMREQ', OrdemProducao:NumReserva, nil })
			 
		aAdd( aMata650, {'AUTEXPLODE', 'S' , Nil })
		
		dbSelectArea("SC2")
		if cOperacao == 3
			msExecAuto({|x,Y| Mata650(x,Y)}, aMata650, cOperacao)

			//se ouve erro na rotina automatica
			IF lMsErroAuto.OR. !EMPTY(cEnderecoFail)
				IF !EMPTY(cEnderecoFail)
					_cTxtErro := cEnderecoFail
				ELSEIf (!IsBlind())
					_cTxtErro := MostraErro()
				Else
					_cTxtErro := MostraErro("/dirdoc", "error.log")
				EndIf
				self:StRetornoOp:Status    := '0'
				self:StRetornoOp:Erro      += ' Não foi possível gravar a OP. Erro: '+_cTxtErro
			ElseIF ! Empty(cEnderecoFail)
				DisarmTransaction()
				self:StRetornoOp:Status    := '0'
				self:StRetornoOp:Erro      += cEnderecoFail
			ELSE
					
				atuLog(cCodLog)	
				
			EndIF
		elseif cOperacao == 5
			
			FOR nIndOp := 1 to LEN(aRenoOp)
				lMsErroAuto := .F.
				SC2->(DBGoto(aRenoOp[nIndOp]))
				
				_cNumOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
				msExecAuto({|x,Y| Mata650(x,Y)}, aMata650, cOperacao)

				//se ouve erro na rotina automatica
				IF lMsErroAuto
					If (!IsBlind())
						_cTxtErro := MostraErro()
					Else
						_cTxtErro := MostraErro("/dirdoc", "error.log")
					EndIf
					self:StRetornoOp:Status    := '0'
					self:StRetornoOp:Erro      += ' Não foi possível excluir a OP. Erro: '+_cTxtErro
				ELSE
						
					excluiOm(_cNumOp)	
					
				EndIF
				
			next
		endif
	ENDIF
	
	if self:StRetornoOp:Status != '1'
		DisarmTransaction()
	endif
	
	END TRANSACTION
	
	BEGIN TRANSACTION
	oManusis:cStatus    := IF(EMPTY(self:StRetornoOp:Erro ),'S','O')
	oManusis:cErroValid := self:StRetornoOp:Erro 
	oManusis:cErroCmp	:= self:StRetornoOp:Erro 
	
	oManusis:atuZZE()  
	
	END TRANSACTION
	
	IF LEN(aLog) > 0
		GRAVALOGEST(aLog)
	ENDIF
	
	
return .T. /* fim do metodo  */



/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Grava a OP apartir de uma OM
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+


WSMETHOD BAIXACOMBUSTIVEL WSRECEIVE BaixasCombustivel WSSEND StRetornoOp WSSERVICE WsManusis
		
	Local aMata650    := {}
	Local aBaixaComb := ::BaixasCombustivel
	Local cOperacao   
	Local cErro       := ''
	Local aNumOp      := {}
	Local cCodLog     := ''
	Local _aCab1 := {}
	Local _aItem := {}
	Local _atotitem:={}
	
	Local cCodigoTM := GetNewPar("TCP_TMCOMB",'501')
	Local cCodigoETM:= GetNewPar("TCP_ETMCOMB",'101')
	Local cCodTm    := ''

	//variaveis para o ExecAuto
	Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. //necessario a criacao

	Private aRenoOp    	 := {}
	
	self:StRetornoOp:Status    := '1'
	self:StRetornoOp:Erro      := ''
	
	if(aBaixaComb:OPERACAO == 'I')
		cCodTm := cCodigoTM
	ELSEif(aBaixaComb:OPERACAO == 'E')
		cCodTm := cCodigoETM
	ELSE
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      := 'Operação inválida. Operação: '+aBaixaComb:OPERACAO
	ENDIF
	oManusis  := ClassIntManusis():newIntManusis()      
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := 'teste'
	oManusis:cTipo	    := 'I' 
	oManusis:cStatus    := 'P'
	oManusis:cEntidade  := 'BXC'
	oManusis:cOperacao  := aBaixaComb:OPERACAO
	oManusis:cRotina    := 'WsManusis.PRW'
	oManusis:cErroValid := self:StRetornoOp:Erro 
	oManusis:cErroCmp	:= self:StRetornoOp:Erro 
		
	//Guarda o log de integração
	IF !oManusis:gravaLog()
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      += ' Erro ao gravar log: '+oManusis:cErroValid 
	ENDIF
	
	cErro := validaBaixa(aBaixaComb)
	
	if !empty(cErro)
		self:StRetornoOp:Status    := '0'
		self:StRetornoOp:Erro      += ' Não foi possível gravar a baixa de combustível: '+cErro
	else
		
		dbSelectArea('SB1')
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + alltrim(aBaixaComb:MATERIAL) ) )
	
		_aCab1 := { {"D3_TM"  ,cCodTm , NIL},;
				 {"D3_CC" 	  ,aBaixaComb:CentroCusto ,NIL},;
				 {"D3_EMISSAO",aBaixaComb:Data, NIL}} 
		_aItem:={ {"D3_COD"   ,SB1->B1_COD ,NIL},;
				{"D3_UM"      ,SB1->B1_UM ,NIL},; 
				{"D3_QUANT"   ,aBaixaComb:Quantidade ,NIL},;
				{"D3_LOCAL"   ,SB1->B1_LOCPAD ,NIL},;
				{"D3_REQUISI"   ,aBaixaComb:Matricula ,NIL},;
				{"D3_CONTA"   ,aBaixaComb:ContaContabil ,NIL},;
				{"D3_ITEMCTA" ,aBaixaComb:ItemConta ,NIL}}

		aadd(_atotitem,_aitem) 
		MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)

		If lMsErroAuto 
			_cTxtErro:= MOSTRAERRO()
			self:StRetornoOp:Status    := '0'
			self:StRetornoOp:Erro      += ' Não foi possível gravar a baixa de combustível. Erro: '+_cTxtErro
		
		EndIf
	
	endif
	oManusis:cStatus    := IF(EMPTY(self:StRetornoOp:Erro ),'S','O')
	oManusis:cErroValid := self:StRetornoOp:Erro 
	oManusis:cErroCmp	:= self:StRetornoOp:Erro 
	
	oManusis:atuZZE()  
	
	
return .T. /* fim do metodo  */
*/
static function validaPar(_oMaterial)
	Local cErro := ''
	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')

	If Empty(_oMaterial:USUARIO)
		cErro := "Informe o usuário."	
	EndIf

	If Empty(_oMaterial:SENHA)
		cErro := "Informe a senha."
	EndIf

	If ALLTRIM(_oMaterial:USUARIO) != cUsuario
		cErro := "Usuário inválido."
	EndIf

	If ALLTRIM(_oMaterial:SENHA) != cSenha
		cErro :="Senha inválida."
	EndIf
	
	
	/*
	FOR nInd := 1 to LEN(_oMaterial:Material)	

		IF EMPTY(_oMaterial:MATERIAL[nInd]:CODIGO)
			cErro :="Material vazio."
		ENDIF
		
		dbSelectArea('SB1')
		DbsetOrder(1)
		IF SB1->(DBSeek(xFilial('SB1')+ALLTRIM(_oMaterial:MATERIAL[nInd]:CODIGO)))
			IF VALTYPE(_oMaterial:MATERIAL[nInd]:QUANTIDADESOLICITADA) != 'F' .AND.  VALTYPE(_oMaterial:MATERIAL[nInd]:QUANTIDADESOLICITADA) != 'N'
				cErro  := 'Quantidade solicitada deve ser numérico. Material: '+ALLTRIM(_oMaterial:MATERIAL[nInd]:CODIGO)
			elseIF _oMaterial:MATERIAL[nInd]:QUANTIDADESOLICITADA <= 0
				cErro  := 'Quantidade solicitada deve ser maior que 0. Material: '+ALLTRIM(_oMaterial:MATERIAL[nInd]:CODIGO)
			ENDIF
		ELSE	
			cErro  := 'Código de MATERIAL inválido. Código: '+_oMaterial:MATERIAL[nInd]:CODIGO
		ENDIF
		
	next
	*/
return cErro



static function validaOM(oOm,cOper)
	Local cErro := ''
	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')
	Local cWhere    := '%%'
	Local cRotExc   := GetNewPar("TCP_ROTMNT",'RQ')
	Local nInd
	
	If Empty(oOm:USUARIO)
		cErro := "Informe o usuário."	
	EndIf

	If Empty(oOm:SENHA)
		cErro := "Informe a senha."
	EndIf

	If ALLTRIM(oOm:USUARIO) != cUsuario
		cErro := "Usuário inválido."
	EndIf

	If ALLTRIM(oOm:SENHA) != cSenha
		cErro :="Senha inválida."
	EndIf
	
	
	IF cOper == 5 //.OR. cOper == 4
		
		If EMPTY(oOm:Rotina) 
			cErro :="Informe a rotina."
		EndIf
		
		cAlias := getNextAlias()
	
		//Se a exclusão for da OM inteira, não filtra reserva. Se for apenas da reserva, filtra ela para pegar apenas a OM correta.
		if UPPER(oOm:Rotina) $ UPPER(cRotExc)
			_cNumReserv := ''
			FOR nInd := 1 to LEN(oOm:Material)
			
				IF !EMPTY(_cNumReserv)
					_cNumReserv += ","
				ENDIF
				
				_cNumReserv += " '"+oOm:MATERIAL[nInd]:NumReserva+"' "
			NEXT
			cWhere := "% AND ZZF_RESERV IN ("+_cNumReserv+") %"
		endif
	
		BeginSQL Alias cAlias

			SELECT SC2.R_E_C_N_O_ AS C2RECNO, C2_NUM, C2_FILIAL,C2_ITEM,C2_SEQUEN 
			FROM %TABLE:SC2% SC2
			INNER JOIN %TABLE:ZZF% ZZF ON ZZF_FILIAL = C2_FILIAL AND ZZF_OP =  C2_NUM+C2_ITEM+C2_SEQUEN  
			WHERE SC2.%NotDel% AND C2_FILIAL = %EXP:xFilial('SC2')% AND C2_XNUMOM = %EXP:oOm:NUMOM% AND ZZF.%NotDel% 
			AND 1=1 %EXP:cWhere%
		
		EndSQL
		
		//Não encontrou
		IF (cAlias)->(Eof())
			//Se for alteração ou inclusão, e não encontrou registro, é inclusão
			if(cOper == 5)
				cErro +=  ' Esta manutenção não existe no Protheus: '+oOm:NUMOM //+ ' Reserva: '+aOrdemManut:NumReserva		
			ENDIF
		Else	
			while !(cAlias)->(Eof())
				dbSelectArea('CB7')
				CB7->( dbSetOrder(5) )
				IF !CB7->( dbSeek( (cAlias)->C2_FILIAL + (cAlias)->C2_NUM+ (cAlias)->C2_ITEM+ (cAlias)->C2_SEQUEN ))  
					aadd(aRenoOp,(cAlias)->C2RECNO)
				ELSE
					IF (UPPER(oOm:Rotina) $ UPPER(cRotExc) .OR. CB7->CB7_STATUS != '9') .AND. EMPTY(cErro) 
						cErro +=  ' Não é possível excluir a OM, pois existe uma serapação não finalizada. OP: '+(cAlias)->C2_NUM 
					ENDIF
				ENDIF
				(cAlias)->(dbSkip())
			enddo
		ENDIF
		
		if LEN(aRenoOp) == 0
			cErro +=  ' Não foi possível excluir nenhuma OP. Verifique o status delas no Protheus.'
		ENDIF
		
		(cAlias)->(dbCloseArea())
		
	ELSEIF cOper != 5
	
		FOR nInd := 1 to LEN(oOm:Material)	
			lMsErroAuto := .F.	
					
			dbSelectArea('SB1')
			SB1->( dbSetOrder(1) )
			IF SB1->( dbSeek( xFilial("SB1") + Rtrim(oOm:MATERIAL[nInd]:MATERIAL) ) )
			
				IF(SB1->B1_MSBLQL == '1')
					 cErro += ' Material encontra-se bloqueado para uso. Código: '+oOm:MATERIAL[nInd]:MATERIAL
				ENDIF
			ELSE
				cErro +=  ' Código de MATERIAL inválido. Código: '+oOm:MATERIAL[nInd]:MATERIAL
			ENDIF
			
			nQuant := oOm:MATERIAL[nInd]:Quantidade
			
//			cAlias := getNextAlias()
//			
//			//Busca a ultima inserção/atualizacao da OM com sucesso, para saber qual a diferença de quantidade
//			BeginSQL Alias cAlias
//
//				SELECT ZZF_OM  
//				FROM %TABLE:ZZF% ZZF
//				INNER JOIN %TABLE:SC2% SC2 ON C2_FILIAL = %EXP:xFilial('ZZF')% AND ZZF_OP =  C2_NUM+C2_ITEM+C2_SEQUEN  AND SC2.%NotDel% 
//				WHERE ZZF.%NotDel% AND ZZF_FILIAL = %EXP:xFilial('ZZF')% 
//				AND ZZF_OP != ' '   AND ZZF_RESERV = %EXP:ALLTRIM(oOm:MATERIAL[nInd]:NumReserva)% 
//				ORDER BY ZZF.R_E_C_N_O_ DESC
//			
//			EndSQL
//			
//			IF !(cAlias)->(Eof())// .AND. EMPTY(cErro)
//				cErro +=  ' Reserva já vinculada a uma OM. Reserva: '+ALLTRIM(oOm:MATERIAL[nInd]:NumReserva)+' OM: '+(cAlias)->ZZF_OM
//			ENDIF
//			
//			(cAlias)->(dbCloseArea())
			
			
			cAlias := getNextAlias()
			
			//Busca a ultima inserção/atualizacao da OM com sucesso, para saber qual a diferença de quantidade
			BeginSQL Alias cAlias

				SELECT ZZF_QTDE  
				FROM %TABLE:ZZF% ZZF
				INNER JOIN %TABLE:SC2% SC2 ON C2_FILIAL = %EXP:xFilial('ZZF')% AND ZZF_OP =  C2_NUM+C2_ITEM+C2_SEQUEN  AND SC2.%NotDel% 
				WHERE ZZF.%NotDel% AND ZZF_FILIAL = %EXP:xFilial('ZZF')% AND ZZF_OM = %EXP:oOm:NUMOM%  
				AND ZZF_OP != ' ' AND ZZF_PRODUT = %EXP:ALLTRIM(oOm:MATERIAL[nInd]:MATERIAL)%  AND ZZF_RESERV = %EXP:ALLTRIM(oOm:MATERIAL[nInd]:NumReserva)% 
				ORDER BY ZZF.R_E_C_N_O_ DESC
			
			EndSQL
			
			
			IF (cAlias)->(Eof())// .AND. EMPTY(cErro)
				nSldPc   := 0
				dDtCompr := CTOD('  /  /    ')
				dbSelectArea('SB2')
				DbsetOrder(1)
				IF SB2->(DBSeek(xFilial('SB2')+SB1->B1_COD+SB1->B1_LOCPAD)) 
					//busca o saldo
					nQtdEst := SaldoSB2()
					IF nQuant> 0 .AND. QtdComp(nQtdEst) < QtdComp(nQuant)
					
						cErro += "Não existe quantidade suficiente em estoque para atender esta requisição. Material: "+RTRIM(oOm:MATERIAL[nInd]:MATERIAL)
						cErro += ". Quantidade Disponível: "+ALLTRIM(STR(nQtdEst))
						cAliasAux := getNextAlias()

						BeginSQL Alias cAliasAux

							SELECT SUM(C7_QUANT) AS TOTALC7, MIN(C7_DATPRF) AS PRIMDATA
							FROM %TABLE:SC7% SC7
							LEFT JOIN SD1020 SD1 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND D1_FORNECE = C7_FORNECE 
							AND D1_LOJA = C7_LOJA  AND C7_PRODUTO = D1_COD AND SD1.%NotDel%  
							WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:xFilial('SC7')%  AND C7_PRODUTO = %EXP:SB1->B1_COD% 
							AND D1_DOC IS NULL AND C7_DATPRF >= %EXP:DTOS(dDataBase)% 
						
						EndSQL
						
						
						//Não encontrou
						IF !(cAliasAux)->(Eof()) .AND. VALTYPE((cAliasAux)->TOTALC7) == 'N' .AND. (cAliasAux)->TOTALC7 > 0
							nSldPc    := (cAliasAux)->TOTALC7
							dDtCompr  := STOD((cAliasAux)->PRIMDATA)
						ENDIF
						
						(cAliasAux)->(dbCloseArea())
						
						aadd(aLog,{SB1->B1_COD,oOm:NUMOM,oOm:MATERIAL[nInd]:NumReserva,oOm:DataInicio,nQuant,nQtdEst,SB2->B2_QATU,;
						nSldPc,dDtCompr,cErro,DATE(),TIME() ,0})
						
					ElseIF !EMPTY(SB2->B2_DTINV)
						cErro +=   "Material bloqueado para inventário. Material: "+RTRIM(oOm:MATERIAL[nInd]:MATERIAL)
					ELSE
						aAdd( aLotesEmp, { ;
						SB1->B1_COD,;
						oOm:MATERIAL[nInd]:Quantidade ,;
						ConvUM(SB1->B1_COD,oOm:MATERIAL[nInd]:Quantidade ,0,2),;
						SB1->B1_LOCPAD,;
						NIL,0,oOm:MATERIAL[nInd]:NumReserva})
					EndIF
				else
					cErro +=   "Não existe saldo em estoque para o produto. "+RTRIM(oOm:MATERIAL[nInd]:MATERIAL)
				ENDIF
				IF oOm:MATERIAL[nInd]:Quantidade <= 0 
					cErro +=   "Quantidade inválida."
				EndIF
			ENDIF
			
			(cAlias)->(dbCloseArea())
				
			
		NEXT
	
		If Empty(alltrim(oOm:ItemConta))
			cErro := "Informe o item contábil."
		EndIf
		
		dbSelectArea('CTD')
		CTD->( dbSetOrder(1) )
		IF CTD->( dbSeek( xFilial("CTD") + alltrim(oOm:ItemConta) ) )
		
			IF(CTD->CTD_BLOQ == '1')
				 cErro += ' Item contábil encontra-se bloqueado para uso. Código: '+ oOm:ItemConta
			ENDIF
		ELSE
			cErro +=  ' Item contábil inválido. Código: '+ oOm:ItemConta
		ENDIF
		
		If Empty(alltrim(oOm:CentroCusto))
			cErro := "Informe o centro de custo."
		EndIf
		
		
		dbSelectArea('CTT')
		CTT->( dbSetOrder(1) )
		IF !Empty(oOm:CentroCusto) .AND.  CTT->( dbSeek( xFilial("CTT") + alltrim(oOm:CentroCusto) ) )
		
			IF(CTT->CTT_BLOQ   == '1')
				 cErro += ' Centro de Custo encontra-se bloqueado para uso. Código: '+ oOm:CentroCusto
			ENDIF
		ELSE
			cErro +=  ' Centro de Custo inválido. Código: '+ oOm:CentroCusto
		ENDIF
		
		
		IF  !Empty(ALLTRIM(oOm:ContaContabil))
			dbSelectArea('CT1')
			CT1->( dbSetOrder(1) )
			IF CT1->( dbSeek( xFilial("CT1") + alltrim(oOm:ContaContabil) ) )
			
				IF(CT1->CT1_BLOQ  == '1')
					 cErro += ' Conta Contabil encontra-se bloqueada para uso. Código: '+ oOm:ContaContabil
				ENDIF
			ELSE
				cErro +=  ' Conta Contabil  inválido. Código: '+ oOm:ContaContabil
			ENDIF
		ENDIF
		
		IF cOper == 3
			if (LEN(aLotesEmp) == 0) .AND. EMPTY(cErro)
				cErro += ' Nenhuma reserva nova para incluir. '
			ENDIF
		
			IF(oOm:DataInicio < date())
				cErro += ' Não é possível cadastrar uma OP com data retroativa. Data início: '+ DTOC(oOm:DataInicio)
			endif
			IF(oOm:DataFim < date())
				cErro += ' Não é possível cadastrar uma OP com data retroativa. Data fim: '+ DTOC(oOm:DataFim)
			endif
		ENDIF
		IF(oOm:DataFim < oOm:DataInicio)
			cErro += ' Não é possível cadastrar uma OP com data início maior que a data fim. Data início: '+ DTOC(oOm:DataInicio)+' Data fim: '+ DTOC(oOm:DataFim)
		endif
				
		
	ENDIF
return cErro

static function gravaLogOm(aOrdemManut)
	Local cCodigo := GETSX8NUM("ZZF","ZZF_NUMERO")
	Local nInd
	//Valida se o código está sendo usado.
	dbSelectArea('ZZF')
	ZZF->( dbSetOrder(3) )
	IF ZZF->( dbSeek( xFilial("ZZF") + cCodigo ) )
		//Enquanto encontrar código, pega um novo. Até q encontre 1 q não existe
		while ZZF->( dbSeek( xFilial("ZZF") + cCodigo ) )
			cCodigo := GETSX8NUM("ZZF","ZZF_NUMERO")
		enddo
	endif
	
	FOR nInd := 1 to LEN(aOrdemManut:Material)	
	
		RecLock("ZZF",.T.)
		ZZF->ZZF_FILIAL := xFilial('ZZE')
		ZZF->ZZF_NUMERO := cCodigo
		//ZZF->ZZF_DATA   := dDataBase
		ZZF->ZZF_PRODUT := aOrdemManut:MATERIAL[nInd]:MATERIAL//aLotesEmp[nInd][1]
		ZZF->ZZF_QTDE   := aOrdemManut:MATERIAL[nInd]:Quantidade
		//ZZF->ZZF_OP     := aOrdemManut:
		ZZF->ZZF_DTINIC := aOrdemManut:DataInicio
		ZZF->ZZF_DTFIM  := aOrdemManut:DataFim
		ZZF->ZZF_ITEMC  := aOrdemManut:ItemConta
		ZZF->ZZF_CC     := aOrdemManut:CentroCusto
		ZZF->ZZF_CONTA  := aOrdemManut:ContaContabil
		ZZF->ZZF_OM     := aOrdemManut:NUMOM
		ZZF->ZZF_CODBEM := aOrdemManut:CODIGOBEM
		ZZF->ZZF_BEM    := aOrdemManut:NOMEBEM
		ZZF->ZZF_ROTINA := aOrdemManut:ROTINA
		ZZF->ZZF_RESERV := aOrdemManut:MATERIAL[nInd]:NumReserva
		ZZF->ZZF_OPERAC := aOrdemManut:OPERACAO
		ZZF->ZZF_DATA   :=  DATE()
		ZZF->ZZF_HORA   :=  TIME()
		
		ZZF->(msUnlock())
	NEXT
	ConfirmSX8() 
return cCodigo

static function atuLog(cCodLog)

	dbSelectArea('ZZF')
	ZZF->( dbSetOrder(3) )
	IF ZZF->( dbSeek( xFilial("ZZF") + cCodLog ) )
		while !	ZZF->(Eof()) .AND. ALLTRIM(ZZF->ZZF_NUMERO) == ALLTRIM(cCodLog)
			RecLock("ZZF",.F.)
			ZZF->ZZF_OP     := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
			ZZF->(msUnlock())
			ZZF->(dbSkip())
		enddo
	endif
return

static function excluiOm(cNumOp)
	Local _oManusis
	dbSelectArea('ZZF')
	ZZF->( dbSetOrder(2) )
	IF ZZF->( dbSeek( xFilial("ZZF") + cNumOp ) )
		 
		while !	ZZF->(Eof()) .AND. ALLTRIM(ZZF->ZZF_OP) == ALLTRIM(cNumOp)
			
			nRecZzf := ZZF->(RECNO())
			
			_oManusis  := ClassIntManusis():newIntManusis()    
			_oManusis:cFilZze    := xFilial('ZZE')
			_oManusis:cChave     := ZZF->ZZF_FILIAL+ZZF->ZZF_OP+ZZF->ZZF_RESERV
			_oManusis:cTipo	    := 'E'
			_oManusis:cStatus    := 'P'
			_oManusis:cErro      := ''
			_oManusis:cEntidade  := 'SOP'
			_oManusis:cOperacao  := 'I'
			_oManusis:cRotina    :=  FunName()
			//
			_oManusis:cStatOp 	:= '4'
		
			IF _oManusis:gravaLog()  
				U_MNSINT03(_oManusis:cChaveZZE)              
			ENDIF 
			
			ZZF->(DbSetOrder(2))
			ZZF->(dbGoTo(nRecZzf))
			
			RecLock("ZZF",.F.)
			ZZF->(dbDelete())   
			ZZF->(msUnlock())
			ZZF->(dbSkip())
		enddo
	endif
return

/*
static function validaBaixa(oBaixa)
	Local cErro := ''
	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')

	If Empty(oBaixa:USUARIO)
		cErro := "Informe o usuário."	
	EndIf

	If Empty(oBaixa:SENHA)
		cErro := "Informe a senha."
	EndIf

	If ALLTRIM(oBaixa:USUARIO) != cUsuario
		cErro := "Usuário inválido."
	EndIf

	If ALLTRIM(oBaixa:SENHA) != cSenha
		cErro :="Senha inválida."
	EndIf
	
	If Empty(alltrim(oBaixa:ItemConta))
		cErro := "Informe o item contábil."
	EndIf
	
	dbSelectArea('CTD')
	CTD->( dbSetOrder(1) )
	IF CTD->( dbSeek( xFilial("CTD") + alltrim(oBaixa:ItemConta) ) )
	
		IF(CTD->CTD_BLOQ == '1')
			 cErro += ' Item contábil encontra-se bloqueado para uso. Código: '+ oBaixa:ItemConta
		ENDIF
	ELSE
		cErro +=  ' Item contábil inválido. Código: '+ oBaixa:ItemConta
	ENDIF
	
	If Empty(alltrim(oBaixa:CentroCusto))
		cErro := "Informe o centro de custo."
	EndIf
	
	If Empty(alltrim(oBaixa:ContaContabil))
		cErro := "Informe a conta contábil."
	EndIf
	
	dbSelectArea('CTT')
	CTT->( dbSetOrder(1) )
	IF !Empty(oBaixa:CentroCusto) .AND.  CTT->( dbSeek( xFilial("CTT") + alltrim(oBaixa:CentroCusto) ) )
	
		IF(CTT->CTT_BLOQ   == '1')
			 cErro += ' Centro de Custo encontra-se bloqueado para uso. Código: '+ oBaixa:CentroCusto
		ENDIF
	ELSE
		cErro +=  ' Centro de Custo inválido. Código: '+ oBaixa:CentroCusto
	ENDIF
	
	IF  !Empty(ALLTRIM(oBaixa:ContaContabil))
		dbSelectArea('CT1')
		CT1->( dbSetOrder(1) )
		IF CT1->( dbSeek( xFilial("CT1") + alltrim(oBaixa:ContaContabil) ) )
		
			IF(CT1->CT1_BLOQ  == '1')
				 cErro += ' Conta Contabil encontra-se bloqueada para uso. Código: '+ oBaixa:ContaContabil
			ENDIF
		ELSE
			cErro +=  ' Conta Contabil  inválido. Código: '+ oBaixa:ContaContabil
		ENDIF
	ENDIF
	
		
	dbSelectArea('SB1')
	SB1->( dbSetOrder(1) )
	IF SB1->( dbSeek( xFilial("SB1") + Rtrim(oBaixa:MATERIAL) ) )
	
		IF(SB1->B1_MSBLQL == '1')
			 cErro += ' Material encontra-se bloqueado para uso. Código: '+oBaixa:MATERIAL
		ENDIF
	ELSE
		cErro +=  ' Código de MATERIAL inválido. Código: '+oBaixa:MATERIAL
	ENDIF
	
	dbSelectArea('SB2')
	DbsetOrder(1)
	IF SB2->(DBSeek(xFilial('SB2')+SB1->B1_COD+SB1->B1_LOCPAD))
		//busca o saldo
		nQtdEst := SaldoSB2()
		IF oBaixa:Quantidade> 0 .AND. QtdComp(nQtdEst) < QtdComp(oBaixa:Quantidade)
			cErro +=   "Não existe quantidade suficiente em estoque para atender esta requisição. "+oBaixa:MATERIAL
			//Conout('QUANTO TEM:')
			//Conout(nQtdEst)
			//Conout('QUANTO PEDUI:')
			//Conout(nQuant)
		
		EndIF
	else
		cErro +=   "Não existe saldo em estoque para o produto. "+oBaixa:MATERIAL
	ENDIF
	
	IF oBaixa:Quantidade <= 0 
		cErro +=   "Quantidade inválida."
	EndIF
	
	
return cErro
*/
