#Include "Protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include "TopConn.ch"
#INCLUDE "TBICONN.CH" 
#Include "parmtype.ch"

/*---------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          ! 
+----------------------------------------------------------------------------+#
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! JOB                                                     ! 
+------------------+---------------------------------------------------------+
!Modulo            ! FAT - FATURAMENTO                                       !
+------------------+---------------------------------------------------------+
!Nome              ! MADERO_AFAT300	                                         !
+------------------+---------------------------------------------------------+
!Descricao         ! GERAÇÃO DE VENDAS       		    			         !
+------------------+---------------------------------------------------------+
!Atualizado por    ! ALAN LUNARDI                          			 		 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 15/05/2018                                              !
+------------------+--------------------------------------------------------*/   
User Function FAT300(aEmpresa)
Local cEmp      := aEmpresa[01] 
Local cFil      := aEmpresa[02] 
Local dDtStart  := IIF(aEmpresa[03]==Nil,CToD("  /  /  "),SToD(aEmpresa[03]))
Local nx        := 0
Local aParam    := {}
Local cAuxLog   := ""
Local aDados    := {}
Local dDataProc := CtoD("  /  /  ")
Local nIdThrMast:= ThreadId()
Local oEventLog
Local dDataAtu  :=CtoD(" / / ")
Local cKeyLock  := "TEK03"+aEmpresa[01]+aEmpresa[02]
Local nAux      := 0
Local lFoundOPs :=.F.
Private lMsErroAuto:= .F.
	
	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been started.")

	// -> Executa processo para todas as empresas
	Aadd(aParam,{cEmp,cFil})
	nx:=1

    // -> Carrega os dados da empresa
	RPcSetType(3)
	RpcSetEnv( aParam[nx,1],aParam[nx,2], , ,'FAT' , GetEnvServer() )
	OpenSm0(aParam[nx,1], .f.)  
		
		nModulo := 5
	   	SM0->(dbSetOrder(1))
    	If !SM0->(dbSeek(aParam[nx,1]+aParam[nx,2]))
			ConOut(StrZero(nIdThrMast,10)+": Erro nos parametros de empresa / filial. Verifique as configuracoes dos parametros 'Empresa' e 'Filiais' do arquivo appserve.ini")
		EndIf
	    
		cEmpAnt  := SM0->M0_CODIGO
	    cFilAnt  := SM0->M0_CODFIL
			
		// -> Inicia semáforo
		If LockByName(cKeyLock,.F.,.T.)
			ConOut("==>SEMAFORO: TEK03 em "+DtoC(Date()) + ": STARTED...")
		Else
			RpcClearEnv()
			ConOut("==>SEMAFORO: TEK03 em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
			KillApp(.T.)
			Return("")
		EndIf

		// -> Verifica data de integração
		dDataAtu :=StoD(u_F300LD2(cFilAnt,dDtStart))
		dDataProc:=dDataAtu

		If !Empty(dDataProc)
			// -> inicializa o Log do Processo
			oEventLog:=EventLog():start("Vendas - ERP", dDataProc, "Iniciando processo de integracao de vendas no ERP...","FAT", "SF2")
			nRecLog  :=oEventLog:GetRecno()
		Else
			// -> inicializa o Log do Processo
			oEventLog:=EventLog():start("Vendas - ERP", dDataProc, "Sem dados para integracao.","FAT", "SF2")
			nRecLog  :=oEventLog:GetRecno()
			cAuxLog  :=StrZero(nIdThrMast,10)+": Nao existem dados para integrar [Z01_ENTREG = "+DtoC(dDataProc)+"]"
			oEventLog:SetAddInfo(cAuxLog,"")
			Conout(cAuxLog)                
			oEventLog:finish()
			RpcClearEnv()
			ConOut("==>SEMAFORO: TEK03 em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
			KillApp(.T.)
			Return("")
		EndIf	

	   	aDados:={}
		aadd(aDados,aParam[nx,1]) 
		aadd(aDados,aParam[nx,2]) 
		aadd(aDados,nRecLog)
		aadd(aDados,nIdThrMast)
		aadd(aDados,dDtStart)
		aadd(aDados,dDataProc)
		aadd(aDados,lFoundOPs)
		startJob("U_F300PROC", GetEnvServer(), .T., aDados)
		
		oEventLog:finish()
		UnLockByName(cKeyLock,.F.,.T.)
		
		RpcClearEnv()	
		ConOut("==>SEMAFORO: TEK03 em "+DtoC(Date()) + ": FINISHED...")
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
	
Return()



/*
+------------------+---------------------------------------------------------+
!Nome              ! F300PROC                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! F300PROC - Processamento dos dados                      !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 27/07/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300PROC(paramixb) 
Local cEmp 		:= paramixb[1]
Local cFil      := paramixb[2]
Local oEventLog
Local lErro    	:= .F.
Local lFoundOP  := .F.
Local cAuxLog  	:= ""
Local dDataProc	:= paramixb[6]
Local cQuery   	:= ""
Local cAliasZ01 := GetNextAlias()
Local cAliasZ01a:= GetNextAlias()
Local cAliasZ01b:= GetNextAlias()
Local cAliasZ13	:= GetNextAlias()
Local cAliasSB2	:= GetNextAlias()
Local cxAliasSA1:= GetNextAlias()
Local cAliasZ04 := GetNextAlias()
Local cAliasZ03 := GetNextAlias()
Local cxAliasCTG:= GetNextAlias()
Local cAliasZ02B:= GetNextAlias()
Local cAliasSG1B:= GetNextAlias()
Local cAliasSC2 := ""
Local cAliasZ05 := ""
Local nVendaZ05 := 0
Local nVendaZ01 := 0
Local nAux  	:= 0
Local lFoundSA1	:=.F.
Local lFoundSB1	:=.F.
Local lFoundSF7	:=.F.
Local aSF7     	:= {}
Local _aPen	    := {} 
Local ny        := 0
Local nx        := 0
Local cCodEmp   := ""
Local cCodFil   := ""
Local aBcAgCo   := ""
Local cBcLoja	:= ""
Local cAgLoja	:= ""
Local cCCLoja	:= ""
Local aBcAgCoP  := ""
Local cBcLojaP	:= ""
Local cAgLojaP	:= ""
Local cCCLojaP	:= ""
Local nxThread  := 3
Local nRecLog   := paramixb[3]
Local nIdThrMast:= paramixb[4]
Local aParam    := {}
Local nInExec	:= 0 
Local aDadosSB2 := {}
Local cAuxLogD  := ""
Local lFoundZ04 := .F.
Local nTamZWVPK := 0
Local l300VP    := .T.
Local aRetOP	:= {}   // Log das OP
Local aRetEMP	:= {}   // Log dos empenhos
Local aRetApon  := {}   // Log dos apontamentos
Local aRetSD3   := {}   // Log baixas na sd3
Local aRetSB2   := {}   // Log de retorno dos saldos de estoque
Local cMvEstNeg := ""
Local nTamDecSD2:= 0
Local aRetF300At:= {}
Local aAux      := {}
Local aRetF3Aler:= {}   
Local nQtdeInt  := 0
Local nQtdeNInt := 0
Local nQtdeCan	:= 0
Private cMVXTPOPVD	:= ""
Private cMVCLIPAD 	:= ""
Private cMVLOJAPAD	:= "" 

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been started.")

	RpcClearEnv()
	RPcSetType(3)
    RpcSetEnv(cEmp,cFil, , ,'FAT' , GetEnvServer() )
    OpenSm0(cEmp, .f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmp+cFil))
	nModulo   :=5
	cEmpAnt   :=SM0->M0_CODIGO
	cFilAnt   :=SM0->M0_CODFIL
	nxThread  := GetMv("MV_XTRF300",,4) 

	// -> Posiciona nas eunidades de negócio
	DbSelectArea("ADK")
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(ADK->(DbSeek(Space(TamSX3("ADK_FILIAL")[1])+cFilAnt)))
	If !ADK->(Found())
		cAuxLog:=StrZero(nIdThrMast,10)+": Erro :Filial não encontrada da tabela ADK: "+cFilAnt
		Conout(cAuxLog)                
		RpcClearEnv()
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return(.F.)	
	EndIf   	

	dDataBase :=dDataProc
	nTamZWVPK := TamSX3("ZWV_PK")[1]
	cMvEstNeg := GetMV("MV_ESTNEG",,"N")
	nTamDecSD2:= TamSX3("D2_QUANT")[2] 


	// -> Reinicializa log do processamento
	oEventLog :=EventLog():restart(nRecLog)
	oEventLog:setDetail("BEGIN PROC", "", "", 0, "Iniciando processamento.",.F.,"",CtoD("  /  /  "), 0, "INICIO", "", "", .F., nIdThrMast)
	cFunNamAnt := FunName()
	
	// -> Verifica se exsite dados para integrar
	If Empty(dDataProc) 
		cAuxLog:=StrZero(nIdThrMast,10)+": Nao existem dados para integrar [Z01_ENTREG = "+DtoC(dDataProc)+"]"
		oEventLog:SetAddInfo(cAuxLog,"")
		Conout(cAuxLog)                
		oEventLog:finish()
		RpcClearEnv()		
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return(.F.)	
	EndIf

	// -> Antes de começar as validações, limpa a tabela ZWE
	cAuxLog:=StrZero(nIdThrMast,10)+": Excluindo logs retroativos [dDataBase = "+DtoS(dDataBase-5)+"]..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                
	cQuery := "DELETE FROM " + RetSqlName('ZWE') + " WHERE ZWE_FILIAL = '" + xFilial('ZWE') + "' AND ZWE_DATA = '" + DtoS(dDataBase-5) + "' AND ZWE_PROCES = 'Vendas - ERP' "
	nStatus := TCSqlExec(cQuery)
	
	cAuxLog:=StrZero(nIdThrMast,10)+": Validando parametros..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)             

	// -> Considera o tipo de saldo com base na tabela SB2
	If GetMv("MV_TPSALDO",,"") <> "S"
		cAuxLog:="O parametro MV_TPSALDO deve estar como 'S' (Controle de saldos pela SB2)."
		oEventLog:setDetail("MV_TPSALDO", "SX6", "E", 1,cAuxLog,.T.   ,"",dDataBase , 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Verifica parâmetros obrigatórios para execução da rotina
	If GetMv("MV_RASTRO",,"") <> "N"
		cAuxLog:="O parametro MV_RASTRO deve estar como 'N' (Sem controle de lote)."
		oEventLog:setDetail("MV_RASTRO", "SX6", "E", 1,cAuxLog,.T.   ,"",dDataBase , 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If GetMv("MV_LOCALIZ",,"") <> "N"
		cAuxLog:="O parametro MV_LOCALIZ deve estar como 'N' (Sem controle de localizacao)."
		oEventLog:setDetail("MV_LOCALIZ", "SX6", "E", 1,cAuxLog,.T.   ,"",dDataBase , 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If !GetMv("MV_GERAOPI",,.F.)
		cAuxLog:="O parametro MV_GERAOPI deve estar como true."
		oEventLog:setDetail("MV_GERAOPI", "SX6", "E", 1,cAuxLogD,.T.   ,"",dDataBase , 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If !GetMv("MV_GERAPI",,.F.)
		cAuxLog:="O parametro MV_GERAPI deve estar como true."
		oEventLog:setDetail("MV_GERAPI", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If GetMv("MV_PRODAUT",,.T.)
		cAuxLog:="O parametro MV_PRODAUT deve estar como false."
		oEventLog:setDetail("MV_PRODAUT", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If !GetMv("MV_PRODPR0",,1) == 1
		cAuxLog:="O parametro MV_PRODPR0 deve estar com conteúdo igual a 1."
		oEventLog:setDetail("MV_PRODPR0", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	If GetMv("MV_CONSEST",,"") <> "N"
		cAuxLog:="O parametro MV_CONSEST  deve estar com conteudo igual a 'N'."
		oEventLog:setDetail("MV_CONSEST ", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf	

	// -> Não deverá considerar os saldos previstos na SB2 para geração das OPs
	If GetMv("MV_QTDPREV",,"") <> "N"
		cAuxLog:="O parametro MV_QTDPREV  deve estar com conteudo igual a 'N'."
		oEventLog:setDetail("MV_QTDPREV ", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf	

    // -> Valida fechamento do estoque
	If GetMv("MV_ULMES",,.T.) > dDataBase
		cAuxLog:="A data da venda e maior que o ultimo fechamento de estoque. Verifique o processo de fechamento do estoque."
		oEventLog:setDetail("MV_ULMES", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de caixa da loja
	If Empty(GetMv("MV_CXLOJA",,""))
		cAuxLog:="O parametro MV_CXLOJA está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_CXLOJA", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro do banco, agencia e conta utilizados para operações com cartão MADERO
	If Empty(GetMv("MV_XBCCTP",,""))
		cAuxLog:="O parametro MV_XBCCTP está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_XBCCTP", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de cliente padrão 
	If Empty(GetMv("MV_CLIPAD",,""))
		cAuxLog:="O parametro MV_CLIPAD está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_CLIPAD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de loja do cliente padrão 
	If Empty(GetMv("MV_LOJAPAD",,""))
		cAuxLog:="O parametro MV_LOJAPAD está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_LOJAPAD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de código de operação de vendas
	If Empty(GetMv("MV_XTPOPVD",,"")) 
		cAuxLog:="O parametro MV_XTPOPVD está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_XTPOPVD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'tipo de movimentação para apontamento contra ordem de produção'
	If AllTrim(GetMv("MV_XTMAD",,"")) == ""
		cAuxLog:="O parametro MV_XTMAD está vazio. Informe o tipo de movimentacao para baixas contar OP"
		oEventLog:setDetail("MV_XTMAD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'tipo de movimentação para baixas por 'consumo adicional' na venda'
	If AllTrim(GetMv("MV_XTMBX",,"")) == ""
		cAuxLog:= "O parametro MV_XTMBX está vazio.  Informe o tipo de movimentação para baixas de 'adicionais nas vendas'"
		oEventLog:setDetail("MV_XTMBX", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de estado 
	If Empty(GetMv("MV_ESTADO",,""))
		cAuxLog:="O parametro MV_ESTADO está vazio ou não existe para a filial."
		oEventLog:setDetail("MV_ESTADO", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'estoque negativo'
	If Upper(GetMv("MV_ESTNEG",,"S")) <> "N"
		cAuxLog:= "O parametro MV_ESTNEG deverá estar preenchido com 'N'."
		oEventLog:setDetail("MV_ESTNEG", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'criação automática de saldos iniciais na tabela SB2'
	If !GetMv("MV_SB2AUTO",,.F.)
	    cAuxLog:="O parametro MV_SB2AUTO deverá estar preenchido com '.T.'."
		oEventLog:setDetail("MV_SB2AUTO", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'TM de producção'
	If AllTrim(GetMv("MV_TMPAD",,"")) <> "010"
		cAuxLog:= "O parametro MV_TMPAD deverá estar preenchido com '010'."
		oEventLog:setDetail("MV_TMPAD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'moeda do custo médio'
	If AllTrim(GetMv("MV_MOEDACM",,"")) <> "1"
	    cAuxLog:="O parametro MV_MOEDACM deverá estar preenchido com '1'."
		oEventLog:setDetail("MV_MOEDACM", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'tipo de custo utilizado'
	If AllTrim(GetMv("MV_CUSMED",,"")) <> "M"
		cAuxLog:="O parametro MV_CUSMED deverá estar preenchido com 'M'."
		oEventLog:setDetail("MV_CUSMED", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'tipo custo unificado'
	If AllTrim(GetMv("MV_CUSFIL",,"")) <> "F"
		cAuxLog:="O parametro MV_CUSFIL deverá estar preenchido com 'F'."
		oEventLog:setDetail("MV_CUSFIL", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'proporção de baixa da MP'
	If AllTrim(GetMv("MV_BXPROP",,"")) <> "S"
		cAuxLog:="O parametro MV_BXPROP deverá estar preenchido com 'S'."
		oEventLog:setDetail("MV_BXPROP", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'forma de tratamento dos indicadores fiscais e de estoque dos produtos'
	If AllTrim(GetMv("MV_ARQPROD",,"")) <> "SB1"
	    cAuxLog:="O parametro MV_ARQPROD deverá estar preenchido com 'SB1'."
		oEventLog:setDetail("MV_ARQPROD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'forma de edição do cadastro de produtos'
	If AllTrim(GetMv("MV_CADPROD",,"")) == ""
		cAuxLog:="O parametro MV_CADPROD deverá estar preenchido com '|SB5|SGI|'."
		oEventLog:setDetail("MV_CADPROD", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Valida parâmetro de 'simbolo da primeira moeda do sistema'
	If AllTrim(GetMv("MV_SIMB1",,"")) <> "R$"
	    cAuxLog:="O parametro MV_SIMB deverá estar preenchido com 'R$'."
		oEventLog:setDetail("MV_SIMB", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Moedas utilizadas no cálculo do custo (apenas moeda 1)
	If AllTrim(GetMv("MV_MOEDACM",,"")) <> "1"
		cAuxLog:="O parametro MV_MOEDACM deverá estar preenchido com conteudo '1'."
		oEventLog:setDetail("MV_MOEDACM", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf
 
 	// -> Reprocessa os valores do custo medio unitario (Sim)
	If GetMv("MV_330ATCM",,.T.)
		cAuxLog:="O parametro V_330ATCM deverá estar preenchido com conteudo .F."
		oEventLog:setDetail("V_330ATCM", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf
 
 	// -> Reprocessa os valores do custo medio unitario (Sim)
	// If AllTrim(GetMv("MV_M330JCM",,"1/3")) <> ""
	// 	cAuxLog:="O parametro MV_M330JCM deverá estar preenchido com conteudo vazio"
	// 	oEventLog:setDetail("MV_M330JCM", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
	// 	oEventLog:SetAddInfo(cAuxLog,"")
	// 	lErro := .T.
	// EndIf

 	// -> Reprocessa os valores do custo medio unitario (Sim)
	If !GetMv("MV_PRODMOD",,.f.)
	    cAuxLog:="O parametro MV_PRODMOD deverá estar preenchido com conteudo vazio"
		oEventLog:setDetail("MV_PRODMOD", "SX6", "E", 1, cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

 	// -> Nao ordena a sequencia do processamento do custo 
	If GetMv("MV_SEQ300",,.T.)
		cAuxLog:="O parametro MV_SEQ300 deverá estar preenchido com conteudo vazio"
		oEventLog:setDetail("MV_SEQ300", "SX6", "E", 1, cAuxLog,.F.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// -> Se não deu erro nas validações anteriores, prossegue
	cMVXTPOPVD:=GetMV("MV_XTPOPVD",,"")
	cMVCLIPAD :=GetMV("MV_CLIPAD" ,,"")
	cMVLOJAPAD:=GetMV("MV_LOJAPAD",,"")
	If !lErro
		cCodEmp :=IIF(AllTrim(xFilial("Z10"))=="",Space(TamSx3("Z03_CDEMP")[1]),xFilial("Z10"))
		cCodFil :=IIF(AllTrim(xFilial("Z10"))=="",Space(TamSx3("Z03_CDFIL")[1]),xFilial("Z10"))
		aBcAgCo :=StrToKarr(GetMV("MV_CXLOJA",,"/"), '/')
		cBcLoja	:=aBcAgCo[1]+Space(TamSX3("A6_COD")[1]    -Len(aBcAgCo[1]))
		cAgLoja	:=aBcAgCo[2]+Space(TamSX3("A6_AGENCIA")[1]-Len(aBcAgCo[2]))
		cCCLoja	:=aBcAgCo[3]+Space(TamSX3("A6_NUMCON")[1] -Len(aBcAgCo[3]))
		aBcAgCoP:=StrToKarr(GetMV("MV_XBCCTP",,""), '/')
		cBcLojaP:=aBcAgCoP[1]+Space(TamSX3("A6_COD")[1]    -Len(aBcAgCoP[1]))
		cAgLojaP:=aBcAgCoP[2]+Space(TamSX3("A6_AGENCIA")[1]-Len(aBcAgCoP[2]))
		cCCLojaP:=aBcAgCoP[3]+Space(TamSX3("A6_NUMCON")[1] -Len(aBcAgCoP[3]))
	EndIf	

	cQuery := "SELECT CTG_CALEND, CTG_EXERC, CTG_PERIOD "
	cQuery += "FROM " + RetSqlName("CTG") + " CTG INNER JOIN " + RetSqlName("CQD") + " CQD "
	cQuery += "ON CTG.CTG_FILIAL  = CQD.CQD_FILIAL  AND "
	cQuery += "   CTG.CTG_CALEND  = CQD.CQD_CALEND  AND "
	cQuery += "   CTG.CTG_EXERC   = CQD.CQD_EXERC   AND "
	cQuery += "   CTG.CTG_PERIOD  = CQD.CQD_PERIOD  AND "
	cQuery += "   CTG.D_E_L_E_T_ <> '*'                 "
	cQuery += "WHERE CQD.D_E_L_E_T_ <> '*'      AND 
	cQuery += "      CQD.CQD_FILIAL  = '" + xFilial("CQD")  + "' AND "
	cQuery += "      CTG.CTG_DTFIM  >= '" + Dtos(dDataBase) + "' AND "
	cQuery += "      CTG.CTG_DTINI  <= '" + Dtos(dDataBase) + "' AND " 
	cQuery += "      CQD.CQD_PROC   IN ('EST001','FIS001','FIN002') AND "
	cQuery += "      (CQD.CQD_STATUS >= '2' AND CQD.CQD_STATUS <= '4') OR (CQD.CQD_STATUS  = '5' AND CQD.CQD_DTFIM >= '" + Dtos(dDataBase) + "' AND CQD.CQD_DTINI <= '" + Dtos(dDataBase) + "')"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cxAliasCTG,.T.,.T.)
	
	(cxAliasCTG)->(dbGoTop())
	While !(cxAliasCTG)->(Eof())
		cAuxLog:="O calendário contabil encontra-se com boqueio para a data atual. Verifique o calendario "+(cxAliasCTG)->CTG_CALEND+", exercicio de "+(cxAliasCTG)->CTG_EXERC+" e periodo "+(cxAliasCTG)->CTG_PERIOD
		oEventLog:setDetail((cxAliasCTG)->CTG_CALEND+(cxAliasCTG)->CTG_EXERC+(cxAliasCTG)->CTG_PERIOD, "CTG", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
		Exit
		(cxAliasCTG)->(DbSkip())
	EndDo
	(cxAliasCTG)->(DbCloseArea())

	If GetMv("MV_DBLQMOV",,.T.) >= dDataBase
		cAuxLog:="A data da venda corresponde a um período de bloqueio dos movimento. Verifique o parâmetro MV_DBLQMOV e altere sua data."
		oEventLog:setDetail("MV_DBLQMOV", "SX6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	cAuxLog:=StrZero(nIdThrMast,10)+": Validando cadastro de produtos..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)             

	cQuery := "SELECT Z02_PROD,               "
	cQuery += "       Z02_CODARV,             "
	cQuery += "       Z02_DESCPR,             "
	cQuery += "       SUM(Z02_QTDE) Z02_QTDE  "
	cQuery += "FROM " + RetSqlName("Z02") + " Z02   " 
	cQuery += "WHERE Z02.D_E_L_E_T_      <> '*' AND                       " 
	cQuery += "      Z02.Z02_FILIAL       = '" + xFilial("Z02")  + "' AND "
	cQuery += "      Z02.Z02_ENTREG       = '" + DtoS(dDataBase) + "' AND "
	cQuery += "      Z02.Z02_PROD    NOT IN (SELECT Z13_XCODEX FROM " + RetSqlName("Z13") + " WHERE D_E_L_E_T_ <> '*' AND Z13_FILIAL = '" + xFilial("Z13") + "') "
	cQuery += "GROUP BY Z02_PROD, Z02_CODARV, Z02_DESCPR "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ13,.T.,.T.)
	
	(cAliasZ13)->(dbGoTop())
	While !(cAliasZ13)->(Eof())
	   // -> verficando se o produto possui codigo externo na B1
		SB1->(DbOrderNickName("B1XCODEXT"))  
		SB1->(DbSeek(xFilial("SB1")+(cAliasZ13)->Z02_PROD))
		lFoundSB1:=SB1->(Found()) .and. !Empty((cAliasZ13)->Z02_PROD)
		If !lFoundSB1
			cAuxLog:="Codigo do produto "+IIF(Empty((cAliasZ13)->Z02_CODARV),"",(cAliasZ13)->Z02_CODARV+"-"+AllTrim((cAliasZ13)->Z02_DESCPR))+" no Teknisa sem relacionamento com o Protheus. [Z02_PROD="+(cAliasZ13)->Z02_PROD+" e Z13_XCODEX=Vazio]"
			oEventLog:setDetail((cAliasZ13)->Z02_PROD, "Z02", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			lErro := .T.
		Else
			// -> Verifica se há vendas com quantidade igual a zero
			If (cAliasZ13)->Z02_QTDE <= 0
				cAuxLog  :="Produto " + AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" com quantidade vendida igual a zero para as vendas do dia "+DToC(dDataBase)+"."
				oEventLog:setDetail(SB1->B1_COD, "Z02", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
				oEventLog:SetAddInfo(cAuxLog,"")		
				lErro := .T.
			EndIf	
		EndIf
		(cAliasZ13)->(DbSkip())
	EndDo
	(cAliasZ13)->(DbCloseArea())
		
	cAuxLog:=StrZero(nIdThrMast,10)+": Validando estrutura de producao Teknisa (Z04)..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                

	// -> Verifica se há itens com quantidade zero na Z04 sem ocorrencias	
	cQuery := "SELECT DISTINCT Z04_PRDUTO, "
	cQuery += "		           Z04_CODARV, " 
	cQuery += "		           Z04_DESCPR  " 
	cQuery += "		FROM " + RetSqlName("Z04") + " Z04 INNER JOIN " + RetSqlName("Z01") + " Z01 " 
	cQuery += "ON Z01.Z01_FILIAL   = Z04.Z04_FILIAL AND "
	cQuery += "   Z01.Z01_SEQVDA   = Z04.Z04_SEQVDA AND "
	cQuery += "   Z01.Z01_CAIXA    = Z04.Z04_CAIXA  AND "
	cQuery += "   Z01.Z01_DATA     = Z04.Z04_DATA   AND "
	cQuery += "   Z01.Z01_XSTINT  <> 'I'            AND "
	cQuery += "   Z01.D_E_L_E_T_ <> '*'                 "
	cQuery += "WHERE Z04.Z04_FILIAL    = '" + xFilial("Z04") + "' AND "
	cQuery += "      Z04.Z04_ENTREG    = '" + DtoS(dDataBase)+ "' AND " 
	cQuery += "      Z04.Z04_PRDUTO <> ' '                        AND "
	cQuery += "      Z04.Z04_QTDE = 0                             AND "
	cQuery += "      Z04.Z04_OCORR = ' '                          AND "
	cQuery += "      Z04.D_E_L_E_T_   <> '*'                      	  "         

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ04,.T.,.T.)
	While !(cAliasZ04)->(Eof())
		cAuxLog:= "Produto com codigo externo "+AllTrim((cAliasZ04)->Z04_PRDUTO)+IIF(Empty((cAliasZ04)->Z04_CODARV),""," e de arvore "+(cAliasZ04)->Z04_CODARV+"-"+AllTrim((cAliasZ04)->Z04_DESCPR))+" do Teknisa, esta com quantidade produzida igual a zero e sem codigo de ocorrencia de 'adiciona/retira' no Teknisa."
		oEventLog:setDetail( (cAliasZ04)->Z04_PRDUTO, "Z04", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
		(cAliasZ04)->(DbSkip())
	EndDo
	(cAliasZ04)->(DbCloseArea())

 	// -> Verifica se há itens de venda do tipo tipo PA que que não estão na estrutura do KDS (tabela Z04)
	cQuery := "SELECT Z02.Z02_FILIAL, Z02.Z02_SEQVDA, Z02.Z02_CAIXA, Z02.Z02_DATA, Z02.Z02_PROD, SB1.B1_TIPO, Z02.Z02_SEQIT, SB1.B1_COD "
	cQuery += "FROM " + RetSqlName("Z02") + " Z02 INNER JOIN " + RetSqlName("Z01") + " Z01 "
	cQuery += "ON Z01.Z01_FILIAL   = Z02.Z02_FILIAL AND "
	cQuery += "   Z01.Z01_SEQVDA   = Z02.Z02_SEQVDA AND "
	cQuery += "   Z01.Z01_CAIXA    = Z02.Z02_CAIXA  AND "
	cQuery += "   Z01.Z01_DATA     = Z02.Z02_DATA   AND "
	cQuery += "   Z01.D_E_L_E_T_ <> '*'                 "
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1       "
	cQuery += "ON SB1.B1_FILIAL   = Z02.Z02_FILIAL AND  "
	cQuery += "   SB1.B1_XCODEXT  = Z02.Z02_PROD   AND  "
	cQuery += "   SB1.D_E_L_E_T_ <> '*'                 "
	cQuery += "WHERE Z02.Z02_FILIAL  = '" + xFilial("Z01") + "' AND "
	cQuery += "	     Z02.Z02_ENTREG  = '" + DtoS(dDataBase)+ "' AND "
	cQuery += " 	 Z02.D_E_L_E_T_ <> '*'  " 
 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ02B,.T.,.T.)
	
	// -> Verifica se o produto possui estrutura no Teknisa e Protheus
	aAux:={}
	While !(cAliasZ02B)->(Eof())
				
		If (cAliasZ02B)->B1_TIPO $ "PA"

			// -> Posiciona na estrutura de produção
			lFoundZ04:=.F.
			cQuery:="WITH ESTRUT( CODIGO, COD_PAI, COD_COMP, QTD, PERDA, DT_INI, DT_FIM, NIVEL ) AS "
			cQuery+="( " 
			cQuery+="SELECT G1_COD PAI, G1_COD, G1_COMP, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, 1 NIVEL "
			cQuery+="FROM "+RetSqlName("SG1")+" SG1 "
			cQuery+="WHERE SG1.D_E_L_E_T_ <> '*'                            AND "
			cQuery+="      SG1.G1_FILIAL   = '" + xFilial("SG1")       + "' AND "
			cQuery+="      SG1.G1_COD      = '" + (cAliasZ02B)->B1_COD + "'     "
			cQuery+="UNION ALL "
			cQuery+="SELECT CODIGO, G1_COD, G1_COMP, QTD * G1_QUANT, G1_PERDA, G1_INI, G1_FIM, NIVEL + 1 "
			cQuery+="FROM "+RetSqlName("SG1")+" SG1 INNER JOIN ESTRUT EST "
			cQuery+="ON  G1_COD = COD_COMP "
			cQuery+="WHERE SG1.D_E_L_E_T_ <> '*'                      AND "
      		cQuery+="      SG1.G1_FILIAL   = '" + xFilial("SG1") + "'     "
			cQuery+=") "
			cQuery+="SELECT CODIGO  , SB1_A.B1_DESC DESCRI   , SB1_A.B1_TIPO TIPO     , SB1_A.B1_GRUPO GRUPO    ,  "
			cQuery+="       COD_PAI , SB1_B.B1_DESC DESC_PAI , SB1_B.B1_TIPO TIPO_PAI , SB1_B.B1_GRUPO GRUPO_PAI,  " 
			cQuery+="       COD_COMP, SB1_C.B1_DESC DESC_COMP, SB1_C.B1_TIPO TIPO_COMP, SB1_C.B1_GRUPO GRUPO_COMP, "
			cQuery+="       QTD     , PERDA                  , SB1_C.B1_UM   UM_COMP  , DT_INI                   , "
			cQuery+="		DT_FIM  , NIVEL                                                                       "
			cQuery+="FROM ESTRUT INNER JOIN "+RetSqlName("SB1")+" SB1_A "
			cQuery+="ON SB1_A.D_E_L_E_T_ <> '*'                      AND "
			cQuery+="   SB1_A.B1_FILIAL   = '" + xFilial("SB1") + "' AND " 
			cQuery+="   SB1_A.B1_COD      = CODIGO                       "
			cQuery+="INNER JOIN "+RetSqlName("SB1")+" SB1_B "
			cQuery+="ON SB1_B.D_E_L_E_T_<> '*'                       AND "
			cQuery+="   SB1_B.B1_FILIAL  = '" + xFilial("SB1") + "'  AND "
			cQuery+="   SB1_B.B1_COD     = COD_PAI                       "
			cQuery+="INNER JOIN "+RetSqlName("SB1")+" SB1_C "
			cQuery+="ON SB1_C.D_E_L_E_T_ <> '*'                            AND "
			cQuery+="   SB1_C.B1_FILIAL   = '" + xFilial("SB1") + "'       AND "
			cQuery+="   SB1_C.B1_COD      =      COD_COMP                      "
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG1B,.T.,.T.)
			While !(cAliasSG1B)->(Eof()) 

				// -> Posiciona no produto e pega o código do Teknisa
			    lFoundZ04:=.T.
				SB1->(DbSetOrder(1))  
				SB1->(DbSeek(xFilial("SB1")+(cAliasSG1B)->COD_COMP))
				If SB1->(Found()) .and. !Empty(SB1->B1_XCODEXT) 
				
					// -> Valida PI
					If SB1->B1_TIPO == "PI"

						// -> Posiciona na SG1 e verifica se possui estrutura cadastrada para o PI
						If aScan(aAux,SB1->B1_COD) <= 0 
							aAdd(aAux,SB1->B1_COD)
							SG1->(DbSetOrder(1))
							If !SG1->(DbSeek(xFilial("SG1")+SB1->B1_COD))
								lErro  := .T.
								cAuxLog:="Produto " + AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC) + " tipo PI sem estrutura cadastrada."						
								oEventLog:setDetail(SB1->B1_COD, "SG1", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
								oEventLog:SetAddInfo(cAuxLog,"")
							EndIf
						Endif	

						// -> Valida PI como 'produto fantasma'
						If SB1->B1_FANTASM <> "S"
							lErro  := .T.
							cAuxLog:="Produto " + AllTrim(SB1->B1_COD) + " - " + AllTrim(SB1->B1_DESC) + " tipo PI deve ser cadastrado como fantasma. Informe no campo B1_FANTASM do cadastro de produtos com conteudo 'S'."						
							oEventLog:setDetail(SB1->B1_COD, "SG1", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
							oEventLog:SetAddInfo(cAuxLog,"")
						EndIf

					Endif

					// -> Verifica se o produto está integrado no Teknisa	
					Z13->(dbSetOrder(1))
					Z13->(DbSeek(xFilial("Z13")+SB1->B1_COD))
					If !Z13->(Found()) .or. Empty(Z13->Z13_XCODEX) 
						lErro := .T.
						cAuxLog:="Produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+" nao integrado com o Teknisa (tabela Z13)."
						oEventLog:setDetail(SB1->B1_COD, "Z13", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
						oEventLog:SetAddInfo(cAuxLog,"")
					EndIf

				EndIf

				(cAliasSG1B)->(DbSkip())

			EndDo	
				
			(cAliasSG1B)->(dbCloseArea())

			// -> Se não encontrou a estrutura no Protheus
			If !lFoundZ04 
			    SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+(cAliasZ02B)->B1_COD))
				lErro   := .T.				
			 	cAuxLog:="Nao encontrada estrutura do produto "+AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" no Protheus."
			 	oEventLog:setDetail((cAliasZ02B)->B1_COD, "SG1", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
 				oEventLog:SetAddInfo(cAuxLog,"")
			EndIf	
		
		EndIf	

		(cAliasZ02B)->(DbSkip())		

	EndDo	

	// -> Validando saldos iniciais na SB2...
	cAuxLog:=StrZero(nIdThrMast,10)+": Validando cadastro de saldos iniciais..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)             

	// -> Verifica ME
	cQuery := "SELECT DISTINCT B1_COD, B1_LOCPAD, B1_TIPO "
	cQuery += "FROM " + RetSqlName("Z02") + " Z02 INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.B1_FILIAL   = Z02.Z02_FILIAL   AND " 
   	cQuery += "   SB1.B1_XCODEXT  = Z02.Z02_PROD     AND "
   	cQuery += "   SB1.B1_TIPO    IN ('ME','MP','MC') AND "
    cQuery += "   SB1.D_E_L_E_T_ <> '*'                  "
	cQuery += "WHERE Z02.D_E_L_E_T_      <> '*' AND                       "                      
    cQuery += "      Z02.Z02_FILIAL       = '" + xFilial("Z02")  + "' AND "
    cQuery += "      Z02.Z02_ENTREG       = '" + DtoS(dDataBase) + "' AND "
    cQuery += "      SB1.B1_COD||SB1.B1_LOCPAD NOT IN (SELECT B2_COD||B2_LOCAL FROM " + RetSqlName("SB2") + " WHERE D_E_L_E_T_ <> '*' AND B2_FILIAL = '" + xFilial("SB2")  + "')"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2,.T.,.T.)

	(cAliasSB2)->(dbGoTop())
	While !(cAliasSB2)->(Eof())
		Aadd(aDadosSB2,{(cAliasSB2)->B1_COD,(cAliasSB2)->B1_LOCPAD,(cAliasSB2)->B1_TIPO})
		(cAliasSB2)->(DbSkip())
	EndDo
	(cAliasSB2)->(DbCloseArea())

	// -> Verifica MP 
	cAliasSB2:=GetNextAlias()
	cQuery := "SELECT DISTINCT B1_COD, B1_LOCPAD, B1_TIPO "
    cQuery += "FROM " + RetSqlName("Z04") + " Z04 INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.B1_FILIAL   = Z04.Z04_FILIAL   AND "
	cQuery += "   SB1.B1_XCODEXT  = Z04.Z04_PRDUTO   AND "
   	cQuery += "   SB1.B1_TIPO    IN ('ME','MP','MC','PA','PI')  AND "
    cQuery += "SB1.D_E_L_E_T_ <> '*'                                "
   	cQuery += "WHERE Z04.D_E_L_E_T_ <> '*'                      AND "                      
    cQuery += "     Z04.Z04_FILIAL  = '" + xFilial("Z04")  + "' AND "
    cQuery += "     Z04.Z04_ENTREG  = '" + DtoS(dDataBase) + "' AND "
    cQuery += "     Z04.Z04_PRDUTO != ' ' 		                AND "
    cQuery += "     SB1.B1_COD||SB1.B1_LOCPAD NOT IN (SELECT B2_COD||B2_LOCAL FROM " + RetSqlName("SB2") + " WHERE D_E_L_E_T_ <> '*' AND B2_FILIAL = '" + xFilial("SB2")  + "')"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB2,.T.,.T.)
	
	(cAliasSB2)->(dbGoTop())
	While !(cAliasSB2)->(Eof())
		Aadd(aDadosSB2,{(cAliasSB2)->B1_COD,(cAliasSB2)->B1_LOCPAD,(cAliasSB2)->B1_TIPO})
		(cAliasSB2)->(DbSkip())
	EndDo
	(cAliasSB2)->(DbCloseArea())

	// -> Incluindo saldos iniciais 
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	For ny:=1 to Len(aDadosSB2)

		// -> Inclui o saldo inicial
		lMsErroAuto:=.F.
		
		// -> Posiciona no cadastro do produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aDadosSB2[ny,01]))
		
		// -> Verifica se o registro existe na tabela SB2
		SB2->(DbSeek(xFilial("SB2")+aDadosSB2[ny,01]+aDadosSB2[ny,02]))
		If !SB2->(Found()) .and. !SB1->B1_TIPO $ "PI/PA/MC/MO"
			cAuxLog:="Nao encontrado saldo inicial para o produto " + aDadosSB2[ny,01] + " - " + AllTrim(SB1->B1_DESC) + ", tipo "+aDadosSB2[ny,03]+" e armazem " + aDadosSB2[ny,02] + ". Devem ser incluidos saldos iniciais com seu respectivo custo, para todos os produtos ja movimentados no Teknisa."
			oEventLog:setDetail(SB1->B1_COD+SB1->B1_LOCPAD, "SB2", "E",1 ,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			Conout(cAuxLog)             
			lErro   :=.T.   
		EndIf	
	Next ny

	// -> Verifica cadastro tributacao 
	cQuery := "SELECT DISTINCT        "
	cQuery += "       SA1.A1_COD,     "
	cQuery += "       SA1.A1_LOJA,    "
	cQuery += "       SA1.A1_NOME,    "
	cQuery += "       SA1.A1_GRPTRIB, "
	cQuery += "       SA1.A1_EST,     "
	cQuery += "       SB1.B1_COD,     "
	cQuery += "       SB1.B1_DESC,    "
	cQuery += "       SB1.B1_GRTRIB   "
	cQuery += "FROM " + RetSqlName("Z01") + " Z01 INNER JOIN " + RetSqlName("Z02") + " Z02 " 
	cQuery += "    ON Z01.Z01_FILIAL   = Z02.Z02_FILIAL  AND " 
	cQuery += "       Z01.Z01_SEQVDA   = Z02.Z02_SEQVDA  AND "
	cQuery += "       Z01.Z01_CAIXA    = Z02.Z02_CAIXA   AND "
	cQuery += "       Z01.Z01_DATA     = Z02.Z02_DATA    AND "
	cQuery += "       Z01.D_E_L_E_T_  <> '*'                 "
	cQuery += "JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "    ON SA1.A1_FILIAL    = '" + xFilial("SA1") + "' AND "  
	cQuery += "       SA1.A1_CGC       = Z01.Z01_CGC              AND " 
	cQuery += "       SA1.D_E_L_E_T_   <> '*'                         "
	cQuery += "JOIN " + RetSqlName("Z13") + " Z13 "          
	cQuery += "    ON Z13.Z13_FILIAL   = '" + xFilial("Z13") + "' AND "
	cQuery += "       Z13.Z13_XCODEX   = Z02.Z02_PROD             AND "
	cQuery += "       Z13.D_E_L_E_T_  <> '*'                          "
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "    ON SB1.B1_FILIAL    = '" + xFilial("SB1") + "' AND "
	cQuery += "       SB1.B1_COD       = Z13.Z13_COD              AND "
	cQuery += "       SB1.D_E_L_E_T_  <> '*'                          "
	cQuery += "WHERE Z02.Z02_FILIAL    = '" + xFilial("Z02") + "' AND "
	cQuery += "      Z02.Z02_ENTREG    = '" + DtoS(dDataBase)+ "' AND " 
	cQuery += "      Z02.D_E_L_E_T_   <> '*'                      AND "         
	cQuery += "      SA1.A1_CGC       <> ' '                          "
	cQuery += "UNION ALL "
	cQuery += "SELECT DISTINCT        "
	cQuery += "       SA1.A1_COD,     "
	cQuery += "       SA1.A1_LOJA,    "
	cQuery += "       SA1.A1_NOME,    "
	cQuery += "       SA1.A1_GRPTRIB, "
	cQuery += "       SA1.A1_EST,     "
	cQuery += "       SB1.B1_COD,     "
	cQuery += "       SB1.B1_DESC,    "
	cQuery += "       SB1.B1_GRTRIB   "
	cQuery += "FROM " + RetSqlName("Z01") + " Z01 INNER JOIN " + RetSqlName("Z02") + " Z02 " 
	cQuery += "    ON Z01.Z01_FILIAL   = Z02.Z02_FILIAL  AND " 
	cQuery += "       Z01.Z01_SEQVDA   = Z02.Z02_SEQVDA  AND "
	cQuery += "       Z01.Z01_CAIXA    = Z02.Z02_CAIXA   AND "
	cQuery += "       Z01.Z01_DATA     = Z02.Z02_DATA    AND "
	cQuery += "       Z01.D_E_L_E_T_  <> '*'                 "
	cQuery += "JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "    ON SA1.A1_FILIAL    = '" + xFilial("SA1") + "' AND "  
	cQuery += "       SA1.A1_COD       = '" + cMVCLIPAD      + "' AND " 
	cQuery += "       SA1.A1_LOJA      = '" + cMVLOJAPAD     + "' AND "
	cQuery += "       SA1.D_E_L_E_T_   <> '*'                         "
	cQuery += "JOIN " + RetSqlName("Z13") + " Z13 "          
	cQuery += "    ON Z13.Z13_FILIAL   = '" + xFilial("Z13") + "' AND "
	cQuery += "       Z13.Z13_XCODEX   = Z02.Z02_PROD             AND "
	cQuery += "       Z13.D_E_L_E_T_  <> '*'                          "
	cQuery += "JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "    ON SB1.B1_FILIAL    = '" + xFilial("SB1") + "' AND "
	cQuery += "       SB1.B1_COD       = Z13.Z13_COD              AND "
	cQuery += "       SB1.D_E_L_E_T_  <> '*'                          "
	cQuery += "WHERE Z02.Z02_FILIAL    = '" + xFilial("Z02") + "' AND "
	cQuery += "      Z02.Z02_ENTREG    = '" + DtoS(dDataBase)+ "' AND " 
	cQuery += "      Z02.D_E_L_E_T_   <> '*'                      AND "         
	cQuery += "      SA1.A1_CGC       <> ' '                          "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cxAliasSA1,.T.,.T.)
	
	(cxAliasSA1)->(dbGoTop())
	lFoundSA1:=.F.
	lFoundSB1:=.F.
	lFoundSF7:=.F.
	aSF7     :={}
	While !(cxAliasSA1)->(Eof())
		
		// -> Posiciona no cliente
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+(cxAliasSA1)->A1_COD+(cxAliasSA1)->A1_LOJA))
		lFoundSA1:=SA1->(Found())
		If lFoundSA1
			// -> Verifica grupo de tributação do cliente
			If AllTrim((cxAliasSA1)->A1_GRPTRIB) == ""
				cAuxLog:="Cliente "+SA1->A1_COD+" e loja " +SA1->A1_LOJA+ " sem grupo de tributacao no cliente. [A1_GRPTRIB = Vazio]"
				oEventLog:setDetail((cxAliasSA1)->A1_COD+(cxAliasSA1)->A1_LOJA, "SA1", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
				oEventLog:SetAddInfo(cAuxLog,"")
				lErro := .T.
			EndIf
			
			// -> Verifica uf do cliente
			If AllTrim((cxAliasSA1)->A1_EST) == ""
				cAuxLog:="Cliente "+SA1->A1_COD+" e loja " +SA1->A1_LOJA+ "sem UF cadastrada. [A1_EST = Vazio]"
				oEventLog:setDetail((cxAliasSA1)->A1_COD+(cxAliasSA1)->A1_LOJA, "SA1", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
				oEventLog:SetAddInfo(cAuxLog,"")
				lErro := .T.
			EndIf
		Else
			cAuxLog:="Cliente "+(cxAliasSA1)->A1_COD+" e loja " +(cxAliasSA1)->A1_LOJA+ " nao encontrado no Protheus. [Tabela SA1]"
			oEventLog:setDetail((cxAliasSA1)->A1_COD+(cxAliasSA1)->A1_LOJA, "SA1", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			lErro := .T.
		EndIf
			
		// -> Posiciona no produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cxAliasSA1)->B1_COD))
		lFoundSB1:=SB1->(Found())
		If lFoundSB1
			// -> Verifica grupo de tributação do produto
			If AllTrim((cxAliasSA1)->B1_GRTRIB) == ""
				cAuxLog:="Sem grupo de tributacao no cliente. [B1_GRTRIB = Vazio]"
				oEventLog:setDetail((cxAliasSA1)->B1_COD, "SB1", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
				oEventLog:SetAddInfo(cAuxLog,"")
				lErro := .T.
			Else
				// -> Verifica grupo de tributação para o estado e cliente
				SF7->(DbOrderNickName("SF7GRPEST"))  
				SF7->(DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB+SA1->A1_EST))
				lFoundSF7:=SF7->(Found())
				If !lFoundSF7
					cAuxLog:="Excecao fiscal nao cadastrada para o produto, cliente e UF. [B1_COD="+SB1->B1_COD+", B1_GRTRIB="+SB1->B1_GRTRIB+", A1_GRPTRIB="+SA1->A1_GRPTRIB+" e A1_EST="+SA1->A1_EST+"]"
					oEventLog:setDetail(SB1->B1_GRTRIB+SA1->A1_GRPTRIB+SA1->A1_EST, "SF7", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
					oEventLog:SetAddInfo(cAuxLog,"")
					lErro := .T.					
				EndIf
			EndIf	
		Else
			cAuxLog:="Produto "+(cxAliasSA1)->B1_COD+" - "+AllTrim((cxAliasSA1)->B1_DESC)+" nao encontrado no Protheus."
			oEventLog:setDetail((cxAliasSA1)->B1_COD, "SB1", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			lErro := .T.
		EndIf
		(cxAliasSA1)->(DbSkip())
	EndDo
	(cxAliasSA1)->(DbCloseArea())
	
	// - > Verifica o tipo de operação
	If AllTrim(cMVXTPOPVD) == ""
		cAuxLog:="Sem tipo de operacao para vendas nas unidades de negocio. [MV_XTPOPVD = Vazio]"
		oEventLog:setDetail("MV_XTPOPVD", "SX6", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	EndIf

	// - > Verifica cliente padrão 
	If AllTrim(cMVCLIPAD) == "" .or. AllTrim(cMVLOJAPAD) == ""	
		cAuxLog:="Cliente padrao nao informado nos parametros. [MV_CLIPAD = Vazio ou MV_LOJAPAD = Vazio]"
		oEventLog:setDetail("MV_CLIPAD+MV_LOJAPAD", "SX6", "E", 0,cAuxLog,.T.,"",dDataBase, 0, "PARAMETROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro := .T.
	Else
		// -> Verifica se o cliente padrão está cadastrado
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+cMVCLIPAD+cMVLOJAPAD))
			cAuxLog:="Cliente "+cMVCLIPAD+" e loja "+cMVLOJAPAD+" padrao nao cadastrado. [Tabela SA1]"
			oEventLog:setDetail(cMVCLIPAD+cMVLOJAPAD, "SA1", "E", 0,cAuxLogD,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			lErro := .T.
		EndIf	
	EndIf

	cAuxLog:=StrZero(nIdThrMast,10)+": Validando condicoes de pagamento (Z03) ..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                
	
	// -> Verifica condição de pagamento - Teknisa
	cQuery := "SELECT DISTINCT Z03_FILIAL, Z03_CDEMP, Z03_CDFIL, Z03_COND "
	cQuery += "FROM " + RetSqlName("Z03") + " Z03                     "  
	cQuery += "WHERE Z03.Z03_FILIAL    = '" + xFilial("Z03") + "' AND "
	cQuery += "      Z03.Z03_ENTREG    = '" + DtoS(dDataBase)+ "' AND "
	cQuery += "      Z03.D_E_L_E_T_   <> '*'                      	  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ03,.T.,.T.)
	While !(cAliasZ03)->(Eof())

		// -> Verifica condição de pagamento - Protheus
		SE4->(DbOrderNickName("E4CODEXT"))
		If !SE4->(DbSeek(xFilial("SE4")+(cAliasZ03)->Z03_COND))
			lErro   := .T.
			cAuxLog	:=StrZero(nIdThrMast,10)+": Condicao de pagamento nao vinculada ao Teknisa. (SE4) [Z03_COD = "+(cAliasZ03)->Z03_COND+"]" 
			oEventLog:setDetail((cAliasZ03)->Z03_COND, "SE4", "E", "E4CODEXT",cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			Conout(cAuxLog)
			(cAliasZ03)->(DbSkip())
			Loop
		ElseIf Empty(SE4->E4_XFORMA)
			// -> Verifica se existe a forma de pagamento cadastrada
			lErro   := .T.
			cAuxLog	:=StrZero(nIdThrMast,10)+": Forma de recebimento nao informada. [E4_XFORMA=Vazio, E4_CODIGO = "+SE4->E4_CODIGO+"]"
			oEventLog:setDetail((cAliasZ03)->Z03_COND, "SE4", "E","E4CODEXT ",cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
			oEventLog:SetAddInfo(cAuxLog,"")
			Conout(cAuxLog)
			(cAliasZ03)->(DbSkip())
			Loop
		Else
			// -> Verifica se existe a natureza cadastrada para a condicao de pagamento
			SED->(DbSetOrder(1))
			If !SED->(DbSeek(xFilial("SED")+SE4->E4_XNATVDA))
				lErro   := .T.
				cAuxLog	:=StrZero(nIdThrMast,10)+": Natureza financeira nao cadastrada para a condicao de recebiemento. [E4_XNATVDA="+SE4->E4_XNATVDA+"]"
				oEventLog:setDetail((cAliasZ03)->Z03_COND, "SE4", "E","E4CODEXT ",cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
				oEventLog:SetAddInfo(cAuxLog,"")
				Conout(cAuxLog)
				(cAliasZ03)->(DbSkip())
				Loop
			EndIf
		EndIf	

		(cAliasZ03)->(DbSkip())

	EndDo
	(cAliasZ03)->(DbCloseArea())
	
	// -> Pesquisa banco da 'unidade' 
	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6")+cBcLoja+cAgLoja+cCCLoja))
		cAuxLog	:= StrZero(nIdThrMast,10)+": Banco da unidade de negocio nao encontrado. [A6_COD="+IIF(Empty(cBcLoja),"Vazio",cBcLoja)+", A6_AGENCIA="+IIF(Empty(cAgLoja),"Vazio",cAgLoja)+" e A6_NUMCON="+IIF(Empty(cCCLoja),"Vazio",cCCLoja)+"]"
		oEventLog:setDetail(cBcLoja+cAgLoja+cCCLoja, "SA6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro   := .T.
		Conout(cAuxLog)
	EndIf
	
	// -> Pesquisa banco para condição "vale presente" 
	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6")+cBcLojaP+cAgLojaP+cCCLojaP))
		cAuxLog	:= StrZero(nIdThrMast,10)+": Banco da unidade de negocio nao encontrado. [A6_COD="+IIF(Empty(cBcLojaP),"Vazio",cBcLojaP)+", A6_AGENCIA="+IIF(Empty(cAgLojaP),"Vazio",cAgLojaP)+" e A6_NUMCON="+IIF(Empty(cCCLojaP),"Vazio",cCCLojaP)+"]"
		oEventLog:setDetail(cBcLojaP+cAgLojaP+cCCLojaP, "SA6", "E", 1,cAuxLog,.T.,"",dDataBase, 0, "CADASTROS", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
		lErro   := .T.
		Conout(cAuxLog)
	EndIf

	// -> Se Houve erro retorna os Erros e aborta o processo.
	If lErro
		cAuxLog:=StrZero(nIdThrMast,10)+": Processo abortado, corrija os cadastros para continuar."
		oEventLog:SetAddInfo(cAuxLog,"")
		oEventLog:broken(cAuxLog, "", .T., .T.)
		oEventLog:setDetail("END PROC", "", "", 0, "Finalizando processamento.",.F.,"",CtoD("  /  /  "), 0, "FIM", "", "", .F., nIdThrMast)
		Conout(cAuxLog)                
		oEventLog:finish()
		RpcClearEnv()
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return(.F.)	
	EndIf	
	
	// -> Carrega as sequencias de vendas para a data
	_aPen:=u_F300LD(cFilAnt,dDataBase,oEventLog,nIdThrMast) 
	
	ny    :=1
	lErro :=.F.	
	aadd(aParam,cEmpAnt)
	aadd(aParam,cFilAnt)
	aadd(aParam,cMVXTPOPVD)
	aadd(aParam,cMVCLIPAD)
	aadd(aParam,cMVLOJAPAD)
	aadd(aParam,"")
	aadd(aParam,"")
	aadd(aParam,"")
	aadd(aParam,nRecLog)
	aadd(aParam,dDataBase)
	aadd(aParam,0)
	aadd(aParam,0)
	aadd(aParam,"")
	aadd(aParam,nIdThrMast)

	/* 	 Array - _aPen
		Filial      -> Posicao 01
		cdempresa   -> Posicao 02
		cdfilial    -> Posicao 03
		caixa       -> Posicao 04
	    seqvenda    -> Posicao 05
		dataentrega -> Posicao 06
		tipodocum   -> Posicao 07
	    status      -> Posicao 08
		numero nfce -> Posicao 09
		prot canc   -> Posicao 10
		data venda  -> Posicao 11
	*/
	
	While !Empty(_aPen)

		aParam[06]:=_aPen[1,5]
		aParam[07]:=_aPen[1,4]
		aParam[08]:=DtoS(_aPen[1,11])
		aParam[13]:="F300"+aParam[1]+aParam[2]+StrZero(nInExec,2)
						
		startJob("u_F300VP", GetEnvServer(),.T., aParam)
			
		aDel(_aPen,1)
		aSize(_aPen,Len(_aPen)-1)

	EndDo
	
	// -> Reinicia o log
	oEventLog :=EventLog():restart(nRecLog)
	lAux:=.F.
	// -> verifica se todos os registros da Z01 foram integrados
	cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("Z01") + " WHERE D_E_L_E_T_ <> '*' AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_ENTREG = '"+DtoS(dDataBase)+"' AND Z01_XSTINT = 'P'"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01,.T.,.T.)
	nQtdeNInt:=(cAliasZ01)->TOTAL
	(cAliasZ01)->(DbCloseArea())

	//#TB20200826 Thiago Berna - Ajuste para desconsiderar cancelados
	// -> Verifica a quantidade de cupons cancelados
	cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("Z01") + " WHERE D_E_L_E_T_ <> '*' AND Z01_FILIAL = '"+xFilial("Z01")+"' AND Z01_ENTREG = '"+DtoS(dDataBase)+"' AND Z01_CUPOMC = 'S'"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01a,.T.,.T.)
	nQtdeCan:=(cAliasZ01a)->TOTAL
	(cAliasZ01a)->(DbCloseArea())

	// -> Verifica se há vendas já integradas para o período
	cAliasZ01 := GetNextAlias()
	cQuery :="SELECT COUNT(F2_EMISSAO) TOTAL "  
	cQuery += "FROM " + RetSqlName("SF2")    + "          "    
	cQuery += "WHERE D_E_L_E_T_ <> '*'                AND "
	cQuery += "      F2_FILIAL   = '" + xFilial("SF2") + "'     AND "
	cQuery += "      F2_XDTCAIX  = '" + DtoS(dDataBase)+ "'     AND "
    cQuery += "      F2_XSEQVDA <> ' '                    "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01,.T.,.T.)
	nQtdeInt:=(cAliasZ01)->TOTAL
	(cAliasZ01)->(DbCloseArea())

	// -> verifica se todos o caixa do dia foi fechado
	cAliasZ01:=GetNextAlias()
	cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("Z05") + " WHERE D_E_L_E_T_ <> '*' AND Z05_FILIAL = '"+xFilial("Z05")+"' AND Z05_DATA = '"+DtoS(dDataBase)+"'"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01,.T.,.T.)
	lAux:=IIF((cAliasZ01)->TOTAL<=0,.F.,.T.)	
	(cAliasZ01)->(DbCloseArea())
	If !lAux
		cAuxLog:=StrZero(nIdThrMast,10)+": Nao ha fechamento de caixa para o dia "+DtoS(dDataBase)+"."
		Conout(cAuxLog)
		If dDataBase == Date()
			oEventLog:setDetail(DtoS(dDataBase), "Z05", "W","ND",cAuxLog,.T.,"",dDataBase, 0, "FECHAMENTO DE CAIXA", "", "", .F., nIdThrMast)
		Else
			oEventLog:setDetail(DtoS(dDataBase), "Z05", "E","ND",cAuxLog,.T.,"",dDataBase, 0, "FECHAMENTO DE CAIXA", "", "", .F., nIdThrMast)
		EndIf
		oEventLog:SetAddInfo(cAuxLog,"")
	Endif
	
	If nQtdeNInt <=0 .and. dDataBase == Date()
		lErro:=.T.
		cAuxLog:=StrZero(nIdThrMast,10)+": Aguardando cupons fiscais para processamento no dia "+DtoS(dDataBase)+"."
		Conout(cAuxLog)
		oEventLog:setDetail(DtoS(dDataBase), "Z05", "W","ND",cAuxLog,.T.,"",dDataBase, 0, "FECHAMENTO DE CAIXA", "", "", .F., nIdThrMast)
		oEventLog:SetAddInfo(cAuxLog,"")
	EndIf	

	// -> Verifica se a quantidade de cupons retonada no fechamento condiz com o total de cupons integrados
	nVendaZ01:=nQtdeInt
	nVendaZ05:=0
	 If lAux
	     // -> Pesquisa a quantidade de vendas do fechamento 
	 	cAliasZ05:=GetNextAlias()
	 	cQuery := "SELECT Z05_NVENDA FROM " + RetSqlName("Z05") + " WHERE D_E_L_E_T_ <> '*' AND Z05_FILIAL = '"+xFilial("Z05")+"' AND Z05_DATA = '"+DtoS(dDataBase)+"' AND ROWNUM = 1 "
	 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ05,.T.,.T.)
	 	//#TB20200826 Thiago Berna - Ajuste para desconsiderar cancelados
		//nVendaZ05:=(cAliasZ05)->Z05_NVENDA
		nVendaZ05:=(cAliasZ05)->Z05_NVENDA - nQtdeCan
	 	(cAliasZ05)->(DbCloseArea())

	 	// -> Verifica se a quantidade de vendas integrada é igual a quantidade de vendas do fechamento
	 	If StrZero(nVendaZ01,12,0) <> StrZero(nVendaZ05,12,0)	 		
	 		If nVendaZ05-nVendaZ01 > 0
	 			cAuxLog:=StrZero(nIdThrMast,10)+": Falta(m) "+AllTrim(Str(nVendaZ05-nVendaZ01)) + " cupon(s) para integrar conforme fechamento do dia "+DtoS(dDataBase)+"."

				lErro:=.T.
	 		Elseif nVendaZ05-nVendaZ01 < 0
	 			cAuxLog:=StrZero(nIdThrMast,10)+": Foi(ram) integrado(s) "+AllTrim(Str(nVendaZ01-nVendaZ05)) + " cupon(s) a mais conforme fechamento do dia "+DtoS(dDataBase)+"."
				lErro:=.T. 
	 		EndIf				
	 		Conout(cAuxLog)
	 		oEventLog:setDetail(DtoS(dDataBase), "Z05", "E","ND",cAuxLog,.T.,"",dDataBase, 0, "FECHAMENTO DE CAIXA", "", "", .F., nIdThrMast)
	 		oEventLog:SetAddInfo(cAuxLog,"")
	 	EndIf
	 EndIf		
	
	// -> Verifica se as ordens de produção foram geradas e o estoque foi gerado
	If nQtdeNInt <= 0 .and. lAux .and. !lErro
	    ZWV->(DbSetOrder(1))
    	ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase),nTamZWVPK)+"Y"))
	    If ZWV->(Found()) .and. ZWV->ZWV_STATUS == "P"
			// -> Gera ordens de produção
            aRetOP	:={}
            cAuxLog	:="Gerando ordem de producao do dia..."
            aadd(aRetOP,{"","SC2","L",0,cAuxLog,.F.,"",dDataProc, 0, "GERACAO DE OP", "", "", nIdThrMast})
            Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)
        	l300VP:=u_GRAVAOP(@aRetOP,dDataProc,oEventLog,nIdThrMast)	
			// -> Processa atualização de empenhos
			If l300VP
                aRetEMP	:={}
                cAuxLog	:="Atualizando empenhos..."
                aadd(aRetEMP,{"","SD4","L",0,cAuxLog,.F.,"",dDataProc, 0, "ALTERACAO DE EMPENHOS", "", "", nIdThrMast})
                Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)
                l300VP:=u_AFAT300E(@aRetEMP,dDataProc,oEventLog,nIdThrMast)  		
	            // -> Processa apontamentos
				If l300VP
					aRetApon:={} 
					cAuxLog	:="Processando apontamentos..."
					aadd(aRetApon,{"","SD3","L",0,cAuxLog,.F.,"",dDataProc, 0, "APONTAMENTO PRODUCAO", "", "", nIdThrMast})
					Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)
					l300VP:=u_FAT3003(@aRetApon,dDataProc,oEventLog,@aRetSB2,@aRetSD3,nIdThrMast)
					// -> Verifica se todos os apontamentos foram realizados, atualiza o ponto de geração das OPs
					lFoundOP:=.F.
					If l300VP 
						// -> Consulta dados na SC2 e verifica se todas as OPs foram apontadas
						cAliasSC2 := GetNextAlias()
						cQuery    := "SELECT C2_FILIAL, C2_PRODUTO, C2_LOCAL, C2_NUM, C2_ITEM, C2_SEQUEN FROM " + RetSqlName("SC2") + " "
						cQuery    += "WHERE D_E_L_E_T_ <> '*' AND C2_FILIAL = '"+xFilial("SC2")+"' AND C2_EMISSAO = '"+DtoS(dDataProc)+"' AND C2_QUJE <= 0  AND C2_ITEM <> 'OS' "  
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC2,.T.,.T.)
						While !(cAliasSC2)->(Eof())
							lFoundOP:=.T.
							// -> Se a OP sem observação não está apontada e o processo foi marcado como apontado, atualiza	
							ZWV->(DbSetOrder(1))
							ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+(cAliasSC2)->C2_PRODUTO+":"+(cAliasSC2)->C2_LOCAL+":"+(cAliasSC2)->C2_NUM+(cAliasSC2)->C2_ITEM+(cAliasSC2)->C2_SEQUEN,nTamZWVPK)+"H"))
							If ZWV->(Found())
								RecLock("ZWV",.F.)
								ZWV->ZWV_STATUS := "P"
								ZWV->(MsUnlock())
							EndIf	
							// -> Se a OP com observação não está apontada e o processo foi marcado como apontado, atualiza	
							ZWV->(DbSetOrder(1))
							ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+(cAliasSC2)->C2_PRODUTO+":"+(cAliasSC2)->C2_LOCAL+":"+(cAliasSC2)->C2_NUM+(cAliasSC2)->C2_ITEM+(cAliasSC2)->C2_SEQUEN,nTamZWVPK)+"I"))
							If ZWV->(Found())
								RecLock("ZWV",.F.)
								ZWV->ZWV_STATUS := "P"
								ZWV->(MsUnlock())
							EndIf	
							// -> Registra log do processo de apontamento de OP
							cAuxLog  :="Ha pendencia de apontamento da orden de producao " + (cAliasSC2)->C2_NUM+(cAliasSC2)->C2_ITEM+(cAliasSC2)->C2_SEQUEN + "."
							aadd(aRetApon,{(cAliasSC2)->C2_NUM+(cAliasSC2)->C2_ITEM+(cAliasSC2)->C2_SEQUEN,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO", "", cAuxLog})
							ConOut(StrZero(nIdThrMast,10)+": "+cAuxLog)
							(cAliasSC2)->(DbSkip())
						EndDo	
						(cAliasSC2)->(DbCloseArea())
						// -> Se as OPs não estiverem pendentes, finaliza o porcesso de apontamento
						If !lFoundOP
							ZWV->(DbSetOrder(1))
							ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase),nTamZWVPK)+"Y"))
							RecLock("ZWV",.F.)
							ZWV->ZWV_DESCP	:= "OPS:"+DtoS(dDataBase)
							ZWV->ZWV_STATUS := "I"
							ZWV->(MsUnlock())
							cAuxLog	:="Apontamentos da producao finalizados."
							aadd(aRetOP,{"","SC2","L",0,cAuxLog,.F.,"",dDataProc, 0, "GERACAO DE OP", "", "", nIdThrMast})
							Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)						
						EndIf							
					EndIf
				EndIf
			EndIf			
		EndIf
		
		// -> Reinicia o log
		oEventLog :=EventLog():restart(nRecLog)

		SD2->(DbSetOrder(3))
		DbSelectArea("ZWV")

		lErro:=.F.

		// -> Atualiza os estoques das notas fiscais pendentes
		ZWV->(DbSetOrder(1))
    	ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase),nTamZWVPK)+"Y"))
		If ZWV->(Found()) .and. ZWV->ZWV_STATUS == "I"
			ZWV->(DbSetOrder(1))
    		ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase),nTamZWVPK)+"W")) 
			If ZWV->(Found()) .And. ZWV->ZWV_STATUS == "P"
				cAuxLog	:="Atualizando estoques..."
				aadd(aRetSB2,{"","SD2","L",0,cAuxLog,.F.,"",dDataProc, 0, "SALDO DE ESTOQUE", "", "", nIdThrMast})
				Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)
				
				// -> Seleciona todos os documentos pendentes para baixa do estoque no dia
				BeginSQL Alias "TMPZWV"
					SELECT R_E_C_N_O_ ZWVRECNO
					FROM %Table:ZWV% ZWV
					WHERE ZWV.%NotDel% AND
						ZWV.ZWV_FILIAL = %xFilial:ZWV% AND
						SUBSTRING(ZWV.ZWV_PK,1,8) = %Exp:DToS(dDataProc)% AND
						ZWV.ZWV_SEQ = 'Z' AND
						ZWV.ZWV_STATUS = 'P'				
				EndSQL
				
				While !TMPZWV->(EOF())
					// -> Posiciona no ponto de lançamento do etoque
					ZWV->(DbGoTo(TMPZWV->ZWVRECNO))
					
					// -> Posiciona no registro da SD2
					aAux :=StrToKarr(ZWV->ZWV_PK,":")
					lAux :=.T.
					SD2->(DbSeek(xFilial("SD2")+AllTrim(aAux[02])))
					While !SD2->(Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. AllTrim(SD2->D2_DOC+SD2->D2_SERIE) ==  AllTrim(aAux[02])

						cAuxLog	:="Produto "+AllTrim(SD2->D2_COD)+"."
						aadd(aRetSB2,{SD2->D2_COD+SD2->D2_LOCAL,"SD2","L",0,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA+DToS(SD2->D2_EMISSAO),dDataProc, 0, "SALDO DE ESTOQUE",SD2->D2_COD, "", nIdThrMast})
						Conout(StrZero(nIdThrMast,10)+": "+cAuxLog)
							
						// -> Faz transferência de estroque entre os produtos de vendas e alternativos
						aRetF3Aler:=F300AtuAlt(cMvEstNeg,nTamDecSD2,@aRetSD3,nIdThrMast,@aRetSB2,SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_TES,NoRound(SD2->D2_QUANT,TamSX3("D2_QUANT")[2]),SD2->D2_XSEQVDA,SD2->D2_XCAIXA,@aRetF300At,SD2->D2_DOC,SD2->D2_EMISSAO,SD2->D2_XSEQIT)
						If !aRetF3Aler[1]
								
							lErro:=.T.
							lAux :=.F.
								
						Else

							cxTime := Time()
							// -> Verifica se existe ponto de lançamento e se já foi realizada baixa dos saldos
							ZWV->(DbSetOrder(1))
							ZWV->(DbSeek(xFilial("ZWV")+PADR(SD2->D2_XSEQVDA+SD2->D2_XCAIXA+DtoS(SD2->D2_EMISSAO)+SD2->D2_XSEQIT,nTamZWVPK)+"L"))
							If !ZWV->(Found())
								RecLock("ZWV",.T.)					        	    
        						ZWV->ZWV_FILIAL := xFilial("ZWV")
								ZWV->ZWV_PK		:= SD2->D2_XSEQVDA+SD2->D2_XCAIXA+DtoS(SD2->D2_EMISSAO)+SD2->D2_XSEQIT
								ZWV->ZWV_DESCP	:= "BAIXA ESTOQUE DO ITEM:"+SD2->D2_XSEQIT
								ZWV->ZWV_SEQ	:= "L"
								ZWV->ZWV_STATUS := "P"
								ZWV->ZWV_ELTIME := ""
								ZWV->(MsUnlock())
							EndIf		

							// -> Verifica se já foi transferido, e se foi, retorna True
							If ZWV->ZWV_STATUS == "P"

								// -> Atualiza dados do documento fiscal
								RecLock("SD2",.F.)
								SD2->D2_ORIGLAN:="  "
								SD2->D2_ESTOQUE:="S"					
								SD2->(MsUnlock())

								// ->  Realiza atualização de custos e saldos										
								If !F300AtuSld(cMvEstNeg,nTamDecSD2,@aRetSB2,nIdThrMast,aRetF300At/*aRetF3Aler[2]*/)
									lErro:=.T.
									lAux :=.F.
								Else
									RecLock("ZWV",.F.)					        	    
									ZWV->ZWV_STATUS := "I"
									ZWV->ZWV_ELTIME := cxTime
									ZWV->(MsUnlock())	
								EndIf
							
							EndIf	
						
						EndIf

						SD2->(DbSkip())
						
					EndDo

					// -> Atualiza posiciona no ponto de lançamento do etoque
					ZWV->(DbGoTo(TMPZWV->ZWVRECNO))
					If lAux
						RecLock("ZWV",.F.)
						ZWV->ZWV_DESCP	:= "ESTOQUES:"+aAux[01]+aAux[02]
						ZWV->ZWV_STATUS := "I"
						ZWV->(MsUnlock())
					EndIf
										
					TMPZWV->(dbSkip())
				EndDo
				
				TMPZWV->(dbCloseArea())
		
				// -> Caso tenha processado todas as atualizações de estoque, encerra o processo
				If !lErro
					ZWV->(DbSetOrder(1))
					ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase),nTamZWVPK)+"W"))
					RecLock("ZWV",.F.)
					ZWV->ZWV_DESCP	:= "ESTOQUES:"+DtoS(dDataBase)
					ZWV->ZWV_STATUS := "I"
					ZWV->(MsUnlock())
					
					cAuxLog	:="Finalizado."
					aadd(aRetOP,{"","SC2","L",0,cAuxLog,.F.,"",dDataProc, 0, "SALDO DE ESTOQUE", "", "", nIdThrMast})
					Conout(StrZero(nIdThrMast,10)+": -> "+cAuxLog)
				EndIf
			EndIf	
		EndIf
	EndIf	

	// -> Reinicia o log
	oEventLog :=EventLog():restart(nRecLog)

	// -> Atualiza Logs
	For nx:=1 to Len(aRetOP)
	 	oEventLog:setDetail(aRetOP[nx,01],aRetOP[nx,02], aRetOP[nx,03], aRetOP[nx,04], aRetOP[nx,05], aRetOP[nx,06], aRetOP[nx,07], aRetOP[nx,08], aRetOP[nx,09],aRetOP[nx,10], aRetOP[nx,11], aRetOP[nx,012], .F., nIdThrMast)
	 	oEventLog:SetAddInfo(aRetOP[nx,05],"")
	Next nx

	For nx:=1 to Len(aRetEMP)
	 	oEventLog:setDetail(aRetEMP[nx,01],aRetEMP[nx,02], aRetEMP[nx,03], aRetEMP[nx,04], aRetEMP[nx,05], aRetEMP[nx,06], aRetEMP[nx,07], aRetEMP[nx,08], aRetEMP[nx,09], aRetEMP[nx,10], aRetEMP[nx,11], aRetEMP[nx,12], .F., nIdThrMast)
	 	oEventLog:SetAddInfo(aRetEMP[nx,05],"")
	Next nx

	For nx:=1 to Len(aRetSD3)
	 	oEventLog:setDetail(aRetSD3[nx,01],aRetSD3[nx,02], aRetSD3[nx,03], aRetSD3[nx,04], aRetSD3[nx,05], aRetSD3[nx,06], aRetSD3[nx,07], aRetSD3[nx,08], aRetSD3[nx,09], aRetSD3[nx,10], aRetSD3[nx,11], aRetSD3[nx,12], .F., nIdThrMast)
	 	oEventLog:SetAddInfo(aRetSD3[nx,05],"")
	Next nx

	For nx:=1 to Len(aRetApon)
	 	oEventLog:setDetail(aRetApon[nx,01],aRetApon[nx,02], aRetApon[nx,03], aRetApon[nx,04], aRetApon[nx,05], aRetApon[nx,06], aRetApon[nx,07], aRetApon[nx,08], aRetApon[nx,09], aRetApon[nx,10], aRetApon[nx,11], aRetApon[nx,12], .F., nIdThrMast)
	 	oEventLog:SetAddInfo(aRetApon[nx,05],"")
	Next nx

	For nx:=1 to Len(aRetSB2)
		oEventLog:setDetail(aRetSB2[nx,01],aRetSB2[nx,02], aRetSB2[nx,03], aRetSB2[nx,04], aRetSB2[nx,05], aRetSB2[nx,06], aRetSB2[nx,07], aRetSB2[nx,08], aRetSB2[nx,09], aRetSB2[nx,10], aRetSB2[nx,11], aRetSB2[nx,12], .F., nIdThrMast)
		oEventLog:SetAddInfo(aRetSB2[nx,05],"")
	Next nx

	oEventLog:setDetail("END PROC", "", "", 0, "Finalizando processamento.",.F.,"",CtoD("  /  /  "), 0, "FIM", "", "", .F., nIdThrMast)

	// -> Finaliza a conexão para iniciar o processamento em Threads
	RpcClearEnv()
	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
	KillApp(.T.)

Return(.T.)


/*
+------------------+---------------------------------------------------------+
!Nome              ! F300LD                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! F300LD - Função usada para carregar os dados pendentes  !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 15/05/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300LD(_Fil, _dDat, oEventLog, nIdThrMast)
Local aVendasP 	:= {}
Local _cAlias 	:= GetNextAlias()
Local cAuxLog 	:= ""
Local nCont     := 0
Local cxNumNF   := ""
		
	/* 	 Array - aVendasP
		Filial      -> Posicao 01
		cdempresa   -> Posicao 02
	    cdfilial    -> Posicao 03
	    caixa       -> Posicao 04
	    seqvenda    -> Posicao 05
	    dataentrega -> Posicao 06
	    tipodocum   -> Posicao 07
	    status      -> Posicao 08
		numero nfce -> Posicao 09
		prot canc   -> Posicao 10
		data venda  -> Posicao 11
	*/

	cAuxLog:=StrZero(nIdThrMast,10)+": Selecionando vendas..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                
	
	_cQuery := "SELECT * "
	_cQuery += "  FROM " + RetSqlName("Z01") + "         "
	_cQuery += " WHERE Z01_XSTINT  = 'P'             AND "
	_cQuery += "	   Z01_FILIAL  = '" + _Fil + "'  AND "
	_cQuery += "	   Z01_ENTREG  = '" + DtoS(_dDat) + "' AND " 
	//_cQuery += "	   Z01_SEQVDA  = '0000094300'          AND "    // Ponto de Debug
	//_cQuery += "     Z01_CAIXA   = '010'                 AND "    // Caixa da venda
	//_cQuery += "	   Z01_SEQVDA  = '0000122607'          AND "    // Ponto de Debug
	_cQuery += "       D_E_L_E_T_ <> '*'                       "
	_cQuery += "ORDER BY Z01_ENTREG                            "
	_cQuery := ChangeQuery(_cQuery)

	If ( Select(_cAlias) ) > 0
		DbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	EndIf
	TCQUERY _cQuery NEW ALIAS &_cAlias
	
	// -> Carregando vendas
	While !(_cAlias)->(EOF())

			// -> Carrega tipos e dados fiscaisi por tipo de documentos
		If SubStr((_cAlias)->Z01_CHVNFCE,21,2) $ "59" // -> SAT
			cxNumNF  :=SubStr((_cAlias)->Z01_CHVNFCE,32,6)
		ElseIf SubStr((_cAlias)->Z01_CHVNFCE,21,2) $ "65" // -> CFE
			cxNumNF:=SubStr((_cAlias)->Z01_CHVNFCE,26,9)
		Else
			cxNumNF:=PadR((_cAlias)->Z01_CUPOM,TamSx3("F2_DOC")[1])
		EndIf

		Aadd(aVendasP,{(_cAlias)->Z01_FILIAL, (_cAlias)->Z01_CDEMP, (_cAlias)->Z01_CDFIL, (_cAlias)->Z01_CAIXA, (_cAlias)->Z01_SEQVDA,StoD((_cAlias)->Z01_ENTREG), (_cAlias)->Z01_TIPO,(_cAlias)->Z01_CUPOMC, cxNumNF, (_cAlias)->Z01_PROCAN, StoD((_cAlias)->Z01_DATA) })	
	
		nCont := nCont + 1
		(_cAlias)->(DBSkip())
		
	Enddo
	
	(_cAlias)->(dbCloseArea())
	

	cAuxLog:=StrZero(nIdThrMast,10)+": " + AllTrim(Str(nCont)) + " vendas selecionadas..."
	oEventLog:setCountTot(nCont)
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                
	 

Return(aVendasP) 
                      


/*
+------------------+---------------------------------------------------------+
!Nome              ! F300VP                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! F300VP - Processo de gravação de vendas                 !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 16/05/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300VP(axParamIbx)
Local nx		:= 0
Local aRetSD3   := {}   // Log dos apontamentos diretos
Local aRetSF2   := {}   // Retorno do processamento dos documentos de saida
Local aRetM300  := {}   // Retorno do processamento do recálculo dos saldos de estoque
Local aRetM930  := {}   // Retorno do processamento do documento de saida
Local aRet3009  := {}   // Retorno do processamento financeiro
Local l300VP    := .T.
Local cAuxLog   := ""
Local cZWVPK    := ""
Local cxTimeProc:= Time()
Local nTamZWVPK := 0
Local nxIDThread:= 0 
Local nTamDoc   := 0
Local oEventLog 
Private cMVXTPOPVD:=axParamIbx[03]
Private cMVCLIPAD :=axParamIbx[04]
Private cMVLOJAPAD:=axParamIbx[05]
Private nIdThrMast:=axParamIbx[14]
Private cxDocSF2  := ""
Private cTipoDoc  := ""
Private cxSerSAT  := ""
Private cxSerie   := ""
Private cCRetSEFAZ:= ""

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been started.")

	// -> Inicializa ambiente da Thread
	RPcSetType(3)
    RpcSetEnv(axParamIbx[1],axParamIbx[2], , ,'FAT' , GetEnvServer() )
    OpenSm0(axParamIbx[01], .f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(axParamIbx[01]+axParamIbx[02]))
	nModulo  :=5
	cEmpAnt  :=SM0->M0_CODIGO
	cFilAnt  :=SM0->M0_CODFIL
	dDataBase:=axParamIbx[10]
	
	DbSelectArea("ZWV")
	
	nTamDoc  :=TamSX3('F2_DOC')[1]
	nTamZWVPK:=TamSx3("ZWV_PK")[1] 
	// -> inicializa o Log do Processo
	oEventLog :=EventLog():restart(axParamIbx[9])
	nxIDThread:=ThreadId()

	cAuxLog:=StrZero(nxIDThread,10)+": -> Gerando documento fiscal "+axParamIbx[06]+"-"+axParamIbx[07]+"..."
	oEventLog:SetAddInfo(cAuxLog,"")
	Conout(cAuxLog)                
	
	// -> Poiciona e reserva registro da venda
	DbSelectArea("Z01")
	Z01->(DbSetOrder(3))
	If Z01->(DbSeek(xFilial("Z01")+axParamIbx[06]+axParamIbx[07]+axParamIbx[08]))
		
		// -> Carrega tipos e dados fiscaisi por tipo de documentos
		If SubStr(Z01->Z01_CHVNFCE,21,2) $ "59" // -> SAT
			cTipoDoc  :="SATCE"
			cxDocSF2  :=SubStr(Z01->Z01_CHVNFCE,32,6)
			cxDocSF2  := cxDocSF2+Space(nTamDoc-Len(cxDocSF2))
			cxSerSAT  :=SubStr(Z01->Z01_CHVNFCE,23,9) 
			cxSerie   :=Z01->Z01_CAIXA 
			cCRetSEFAZ:=IIF(Val(SubStr(Z01->Z01_OBSNFC,1,TamSx3("F3_CODRSEF")[1]))>0,SubStr(Z01->Z01_OBSNFC,1,TamSx3("F3_CODRSEF")[1]),"")
		ElseIf SubStr(Z01->Z01_CHVNFCE,21,2) $ "65" // -> CFE
			cTipoDoc:="NFCE"
			cxDocSF2:=SubStr(Z01->Z01_CHVNFCE,26,9)
			cxSerSAT:=""
			cxSerie :=SubStr(Z01->Z01_CHVNFCE,23,3) 
			cCRetSEFAZ:=IIF(Val(SubStr(Z01->Z01_OBSNFC,1,TamSx3("F3_CODRSEF")[1]))>0,SubStr(Z01->Z01_OBSNFC,1,TamSx3("F3_CODRSEF")[1]),"")
		Else
			cTipoDoc:="CF"
			cxDocSF2:=PadR(Z01->Z01_CUPOM,TamSx3("F2_DOC")[1])
			cxDocSF2:=cxDocSF2+Space(nTamDoc-Len(cxDocSF2))
			cxSerSAT:=""
			cxSerie :=Z01->Z01_CAIXA 
			cCRetSEFAZ:=""
		EndIf

		cZWVPK :=Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG)
		cZWVPK :=xFilial("ZWV")+cZWVPK+Space(TamSx3("ZWV_PK")[1]-Len(cZWVPK))

		DbSelectArea("SF2")
		SF2->(DbOrderNickName("SEQVDA"))
		SF2->(DbSeek(xFilial("SF2")+Z01->Z01_SEQVDA+Z01->Z01_CAIXA))
		If (!SF2->(Found())) .or. (SF2->(Found()) .and. Upper(Z01->Z01_CUPOMC) <> "S")			
			
			cxTimeProc:=Time()

			// -> Se  ok, continua o processo
			If l300VP
		    	aRetSF2 :={}
				l300VP:=u_F300DS(@aRetSF2,oEventLog,nxIDThread,@aRetSD3,cxDocSF2,cTipoDoc,cxSerSAT,cxSerie,cCRetSEFAZ)
			EndIf

			// -> Se a NF não foi cancelada, gera títulos a receber e atualiza o registro como integrado
			If Upper(Z01->Z01_CUPOMC) <> "S"
				// -> Processa títulos a receber
				If l300VP
					aRet3009:={}
					cAuxLog	:="Gerando titulos a receber..."
					aadd(aRet3009,{"","SE1","L",0,cAuxLog,.F.,"",CtoD("  /  /  "), 0, "FINANCEIRO", "", "", nxIDThread})
					Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)
					l300VP:= u_FAT3009(@aRet3009,oEventLog,nxIDThread)
				EndIf	

				// -> Se tudo foi ok, então grava a data da integração                
				If l300VP

					// -> Atualiza a sequencia de venda como integrada
					RecLock("Z01",.F.)
					Z01->Z01_XDTERP := Date()
					Z01->Z01_XHRERP := Time() 
					Z01->Z01_XSTINT := "I"
					Z01->(MsUnlock())
				Else
					cAuxLog:=StrZero(nxIDThread,10)+": Houveram erros no processamento (Z01_SEQVDA=" + Z01->Z01_SEQVDA + "), verifique o log com os erros."
					oEventLog:broken(cAuxLog, "", .T., .T.)
					Conout(cAuxLog) 	
				EndIf    
			EndIf
		EndIf

		//-> Verifica cancelamentos 
		If Z01->(Found()) .and. Upper(Z01->Z01_CUPOMC) == "S" .and. l300VP
            // -> Verifica se a venda já foi gerada e está ok.
            ZWV->(DbSetOrder(1))
			ZWV->(DbSeek(xFilial("ZWV")+PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWVPK)+"K"))
            If ZWV->(Found()) 
                cAuxLog	:="Efetundo cancelamento da venda..."
                aadd(aRetSF2,{"","SF2","L",0,cAuxLog,.F.,"",CtoD("  /  /  "), 0, "CANC DOCUMENTO FISCAL", "", "", nxIDThread})
                Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)				
                l300VP:=.F.
                l300VP := u_FAT3010(@aRetSF2,oEventLog,nxIDThread,cCRetSEFAZ)
                If l300VP
                    RecLock("Z01",.F.)
                    Z01->Z01_XDTERP := Date()
                    Z01->Z01_XHRERP := Time() 
                    Z01->Z01_XSTINT := "I"
                    Z01->(MsUnlock())
                    l300VP:=.T.
                EndIf
            Else
                l300VP:=.F.
                cAuxLog:=StrZero(nxIDThread,10)+" : Houve erro no cancelamento da venda. [ZWV_PK="+PADR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWVPK)+" e ZWV_STATUS<>'I']. Venda não encontrado na tabela ZWV ou nao foi concluida."                
				aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", cAuxLog})
                oEventLog:broken(cAuxLog, "", .T., .T.)
                Conout(cAuxLog) 	
            EndIf   
			
		ElseIf l300VP
			
			l300VP:=.T.

		EndIf

		// -> Atualiza registros processados
		If l300VP
			oEventLog:setCountInc()
		EndIf

		cAuxLog:=StrZero(nxIDThread,10)+": -> Gravando log do processamento fiscal..."
		oEventLog:SetAddInfo(cAuxLog,"")
		Conout(cAuxLog)

		For nx:=1 to Len(aRetSF2)
			oEventLog:setDetail(aRetSF2[nx,01],aRetSF2[nx,02], aRetSF2[nx,03], aRetSF2[nx,04], aRetSF2[nx,05], aRetSF2[nx,06], aRetSF2[nx,07], aRetSF2[nx,08], aRetSF2[nx,09], aRetSF2[nx,10], aRetSF2[nx,11], aRetSF2[nx,12], .F., nxIDThread)
			oEventLog:SetAddInfo(aRetSF2[nx,05],"")
		Next nx

		For nx:=1 to Len(aRetM300)
			oEventLog:setDetail(aRetM300[nx,01],aRetM300[nx,02], aRetM300[nx,03], aRetM300[nx,04], aRetM300[nx,05], aRetM300[nx,06], aRetM300[nx,07], aRetM300[nx,08], aRetM300[nx,09], aRetM300[nx,10], aRetM300[nx,11], aRetM300[nx,12], .F., nxIDThread)
			oEventLog:SetAddInfo(aRetM300[nx,05],"")
		Next nx

		For nx:=1 to Len(aRetM930)
			oEventLog:setDetail(aRetM930[nx,01],aRetM930[nx,02], aRetM930[nx,03], aRetM930[nx,04], aRetM930[nx,05], aRetM930[nx,06], aRetM930[nx,07], aRetM930[nx,08], aRetM930[nx,09], aRetM930[nx,10], aRetM930[nx,11], aRetM930[nx,12], .F., nxIDThread)
			oEventLog:SetAddInfo(aRetM930[nx,05],"")
		Next nx

		For nx:=1 to Len(aRet3009)
			oEventLog:setDetail(aRet3009[nx,01],aRet3009[nx,02], aRet3009[nx,03], aRet3009[nx,04], aRet3009[nx,05], aRet3009[nx,06], aRet3009[nx,07], aRet3009[nx,08], aRet3009[nx,09], aRet3009[nx,10], aRet3009[nx,11], aRet3009[nx,12], .F., nxIDThread)
			oEventLog:SetAddInfo(aRet3009[nx,05],"")
		Next nx

		cAuxLog:=StrZero(nxIDThread,10)+": Log ok."
		oEventLog:SetAddInfo(cAuxLog,"")
		Conout(cAuxLog)

	EndIf

	RpcClearEnv()
	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
	KillApp(.T.)

Return(l300VP)   


/*
+------------------+---------------------------------------------------------+
!Nome              ! GRAVAOP                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! GRAVAOP - Gera ordens de produção                       !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 16/05/2018                                              !
+------------------+---------------------------------------------------------+
!Alterações        ! Márcio A. Zaguetti em 05/01/1020                        !
!                  !                                                         !
+------------------+---------------------------------------------------------+
*/    
User Function GRAVAOP(aRetOP,dDataProc,oEventLog,nxIDThread)
Local cPathTmp   	:= "\temp\"
Local cFileErr      := ""
Local cErrorLog     := ""
Local aMATA650 		:= {}                          
Local cAliasSG1     := ""
Local cAliasZ02 	:= ""
Local cQuery        := ""
Local cAuxLog		:= ""
Local cAuxLogD		:= ""
Local lErro         := .F.
Local nAuxMod       := nModulo
Local cNumSC2       := ""
Local cSeqIt  		:= ""
Local cSeqOP  		:= ""
Local cProdOrigem   := ""
local cArmOrigem    := ""
Local cProdTeknisa  := ""
Local cDescTeknisa  := "" 
Local lOPOk         := .F.
Local nTamZWVPK     := TamSx3("ZWV_PK")[1] 
Local cxTime        := ""
Local nAux          := 0
Local cProdVda      := ""
Local cProdAdc      := ""
Local cLocPAdic     := ""
Local nx            := 0
Local nTamD4_OP     := TamSx3("D4_OP")[1]
Local nQuantSD2     := 0
Local cAuxOP        := ""
Local cAliasOP      := ""
Private lMsErroAuto	:= .F.
	
	nAuxMod		:= nModulo
	nModulo		:= 4
	cAliasZ02 	:= u_F300QZ02(dDataProc)
	cAliasObs	:= U_Z04OBSPRD(dDataProc) 
	cNumSC2		:= ""

	(cAliasZ02)->(dbGoTop())
	While !(cAliasZ02)->(Eof())

		cxTime      :=Time()
		lOPOk       :=.T.
		cProdOrigem :=""
		cArmOrigem  :=""
		cProdTeknisa:=""
		cDescTeknisa:=""
		nQuantSD2   :=(cAliasZ02)->Z02_QTDE

		// -> Posiciona no Produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cAliasZ02)->B1_COD))
		cProdOrigem :=SB1->B1_COD
		cArmOrigem  :=SB1->B1_LOCPAD
		cProdTeknisa:=SB1->B1_XCODEXT
		cDescTeknisa:=SB1->B1_DESC

		cAuxLog	:="Produto "+AllTrim(cProdOrigem)+"."
		aadd(aRetOP,{DToS(dDataProc)+cProdTeknisa,"Z04","L","ND",cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", cProdOrigem, cAuxLog})
		ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)

		// -> Verifica se o produto for diferente de PA
		If AllTrim(SB1->B1_TIPO) <> "PA"
			cAuxLog	:="Produto "+AllTrim((cAliasZ02)->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" com tipo " + SB1->B1_TIPO + " nao sera produzido."
			aadd(aRetOP,{(cAliasZ02)->B1_COD,"SB1","W",1,cAuxLog,.F.,"ALL",dDataProc, 0, "CADASTROS", (cAliasZ02)->B1_COD, cAuxLog})
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
			(cAliasZ02)->(DbSkip())
			Loop
		EndIf

		// -> Posiciona na estrutura de produção
		SG1->(DbSetOrder(1))
		SG1->(DbSeek(xFilial("SG1")+(cAliasZ02)->B1_COD))
		If !SG1->(Found())
			lErro	:=.T.
			lOPOk   :=.F.
			cAuxLog	:="Produto "+(cAliasZ02)->B1_COD+" - "+AllTrim(SB1->B1_DESC)+" sem estrutura de producao."
			aadd(aRetOP,{(cAliasZ02)->B1_COD,"SG1","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "CADASTROS", (cAliasZ02)->B1_COD, cAuxLog})
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
			(cAliasZ02)->(DbSkip())
			Loop
		EndIf

        // -> Verifica se existe OP já gerada e se a mesma foi concluida a geração da op
        ZWV->(DbSetOrder(1))
        ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+cProdOrigem+":"+cArmOrigem,nTamZWVPK)+"A"))
        If !ZWV->(Found())
            RecLock("ZWV",.T.)
            ZWV->ZWV_FILIAL := xFilial("ZWV")
			ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+cProdOrigem+":"+cArmOrigem
			ZWV->ZWV_DESCP	:= "OP:"
			ZWV->ZWV_SEQ	:= "A"
			ZWV->ZWV_STATUS := "P"
			ZWV->(MsUnlock())
		EndIf

        // -> Se a OP foi criada, vai para o próximo registro
        If ZWV->ZWV_STATUS == "I"
			(cAliasZ02)->(DbSkip())
            Loop
        EndIf    

		// -> Verifica se continua o processo
		If lOPOk
			
			BeginTran()
		
			// -> Cria ordem de produção
			DbSelectArea("SC2")		
			cNumSC2	:=GetNumSC2()
			cSeqIt  :=StrZero(1,TamSx3("C2_ITEM")[1])			
			cSeqOP	:= "001" 
			cFilInt := xFilial("Z04")
		
			// -> Se gerou numero da OP, continua
			If AllTrim(cNumSC2) <> ""

				Pergunte("MTA650",.F.)			
				aMATA650:={	{'C2_FILIAL'   	,cFilInt			,NIL},;
							{'C2_PRODUTO'  	,SB1->B1_COD		,NIL},;
							{'C2_NUM'  	   	,cNumSC2			,NIL},;          
							{'C2_ITEM'     	,cSeqIt				,NIL},;          
							{'C2_SEQUEN'   	,cSeqOP				,NIL},;
							{'C2_QUANT'		,nQuantSD2   		,NIL},;
							{'C2_DATPRI'    ,dDataBase			,NIL},;
							{'C2_DATPRF'    ,dDataBase			,NIL},;
							{'C2_EMISSAO'   ,dDataBase			,NIL},;
							{'C2_TPOP'      ,'F'				,NIL},;
							{'C2_XSEQVDA'   ,'ALL'				,NIL},;
							{'C2_XCAIXA'    ,'ALL'				,NIL},;
							{'C2_XSEQIT'    ,'ALL'				,NIL},;
							{'AUTEXPLODE'   ,'S'				,NIL} ;
						}
				lMsErroAuto:=.F.
				msExecAuto({|x,Y| Mata650(x,Y)},aMATA650,3)
				// -> Se ocorreu erro, registra log
				lOPOk:= .F.
				If lMsErroAuto
					lErro    := .T.
					cFileErr := "sc2_"+cFilAnt+"_"+cNumSC2+cSeqIt+cSeqOP+"_"+strtran(time(),":","")
					MostraErro(cPathTmp, cFileErr)
					cErrorLog:=memoread(cPathTmp+cFileErr)
					cAuxLog  :="Erro na inclusao OP, verifique o detalhamento da ocorrencia."
					cAuxLogD :=cErrorLog
					fErase(cPathTmp+cFileErr)
					aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, nQuantSD2, "GERACAO DE OP", SB1->B1_COD, cAuxLogD})
					ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
					DisarmTransaction()
				Else
					// -> Reposiciona na ordem de produção e atualiza OPs intermediárias
					SC2->(DbSetOrder(1))
					SC2->(DbSeek(cFilInt+cNumSC2))
					If SC2->(Found())				
						While !SC2->(Eof()) .and. SC2->C2_FILIAL == cFilInt .and. SC2->C2_NUM == cNumSC2 
							// -> Posiciona no produto da OP
							SB1->(DbSetOrder(1))
							SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
							If RecLock("SC2",.F.)
								SC2->C2_XSEQVDA:="ALL"
								SC2->C2_XCAIXA :="ALL"
								SC2->C2_XSEQIT :="ALL"
								SC2->C2_XDESCP :=SB1->B1_DESC
								SC2->(MsUnlock())
								lOPOk:= .T.
								// -> Atualiza empenhos com os dados da venda
								SD4->(DbOrderNickName("D4PRODUTO"))
								SD4->(DbSeek(SC2->C2_FILIAL+SC2->C2_PRODUTO+PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD4_OP)))			
								While !SD4->(Eof()) .and. SD4->D4_FILIAL+SD4->D4_PRODUTO+SD4->D4_OP == SC2->C2_FILIAL+SC2->C2_PRODUTO+PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD4_OP)
									If RecLock("SD4",.F.)
										SD4->D4_XSEQVDA:="ALL"
										SD4->D4_XCAIXA :="ALL"
										SD4->D4_XSEQIT :="ALL"
										SD4->(MSUnlock())
									Else
										lErro :=.T.
										lOPOk :=.F.
										cAuxLogD:="Ocorreu erro na altercao dos campos de sequencia da venda, caixa e sequencia do item (Campos: D4_XSEQVDA, D4_XCAIXA e D4_XSEQIT)."
									EndIf   										
									SD4->(DbSkip())
								EndDo												
								// -> Confirma OP
								If RecLock("ZWV",.F.)
									ZWV->ZWV_DESCP	:= "OP:"+cNumSC2+cSeqIt+cSeqOP
									ZWV->ZWV_STATUS := "I"
									ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
									ZWV->(MsUnlock())
								Else
									lErro   :=.T.
									lOPOk   :=.F.
									cAuxLogD:="Ocorreu erro na altercao dos campos da tabela ZWV (Campos: ZWV_DESCP e ZWV_STATUS)."
								EndIf
							Else
								lErro :=.T.
								lOPOk :=.F.
								cAuxLogD:="Ocorreu erro na altercao dos campos de sequencia da venda, caixa e sequencia do item (Campos: C2_XSEQVDA, C2_XCAIXA, C2_XSEQIT e C2_XDESCP)."
							EndIf
							SC2->(DbSkip())
						EndDo
						// -> Atualiza log das OPs intermediárias
						If lOPOk
							// -> Seleciona ordens de produção intermediarias e inclui no controle de OPs
							SC2->(DbSetOrder(1))
							SC2->(DbGoTop())
							SC2->(DbSeek(cFilInt+cNumSC2))
							While !SC2->(Eof()) .and. SC2->C2_FILIAL == cFilInt .and. SC2->C2_NUM == cNumSC2 
								cxTime:=Time()
								If !Empty(SC2->C2_SEQPAI) 
					    	        RecLock("ZWV",.T.)					        	    
            						ZWV->ZWV_FILIAL := xFilial("ZWV")
									ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL
									ZWV->ZWV_DESCP	:= "OP:"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
									ZWV->ZWV_SEQ	:= "A"
									ZWV->ZWV_STATUS := "I"
									ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
									ZWV->(MsUnlock())
								EndIf	
								SC2->(DbSkip())
    						EndDo
							// -> Atualiza log do processo
							cAuxLog :="OP numero " + cNumSC2 + ", item " + cSeqIt + " e " + cSeqOP + " incluida com sucesso."
							aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", SB1->B1_COD, cAuxLog})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						Else	
							cAuxLog  :="Erro na inclusao da OP. [C2_NUM="+cNumSC2+", C2_ITEM="+cSeqIt+" e C2_SEQUEN="+cSeqOP+"]"						
							aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", SB1->B1_COD, cAuxLog})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
							DisarmTransaction()
						EndIf	
						// -> Reposiciona no produto original da OP
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+cProdOrigem))
					Else
						lErro    :=.T.
						cAuxLog :="OP numero " + cNumSC2 + " nao encontrada na SC2."
						aadd(aRetOP,{cNumSC2,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", SB1->B1_COD, cAuxLog})
						ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						DisarmTransaction()
					EndIf
				EndIf
			
			Else

				lErro    :=.T.
				cAuxLog  :="Erro na inclusao da OP."
				cAuxLogD :="Nao foi possivel gerar o numero da proxima OP pela funcao GetNumSC2()."
				aadd(aRetOP,{"","SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", SB1->B1_COD, cAuxLogD})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
				DisarmTransaction()
		
			EndIf

			EndTran()	

		EndIf	
				
		(cAliasZ02)->(DbSkip())
	
	EndDo
	(cAliasZ02)->(DbCloseArea())

	// -> Gera OP / baixas das observacoes 
	(cAliasObs)->(dbGoTop())
	While !(cAliasObs)->(Eof())

		lOPOk      :=.T.
		cProdOrigem:=""

		// -> Pesquisa o produto de venda
		SB1->(DbOrderNickName("B1XCODEXT"))  
		SB1->(DbSeek(xFilial("SB1")+(cAliasObs)->PRODUTO))
		cProdVda:=SB1->B1_COD

		// -> Pesquisa produto adicional
		SB1->(DbOrderNickName("B1XCODEXT"))  
		SB1->(DbSeek(xFilial("SB1")+(cAliasObs)->CODMP))
		cProdAdc :=SB1->B1_COD
		cLocPAdic:=SB1->B1_LOCPAD

		BeginTran()
		
			cxTime  :=Time()
			cAuxLog	:="Produto "+AllTrim(cProdVda)+" e adicional " + AllTrim(cProdAdc) + "..."
			aadd(aRetOP,{DtoS(dDataProc)+cProdVda+cProdAdc,"Z04","L","ND",cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP (OBSERVACAO)", cProdAdc, cAuxLog})
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)

			// -> Se o produto pertence a uma estrutura de produção, gera as ordens de produção
			If SB1->B1_TIPO $ "PA/PI" .and. SB1->B1_FANTASM <> "S"	
				// -> Verifica se existe OP já gerada e se a mesma foi concluida a geração da op
				ZWV->(DbSetOrder(1))
				ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+cProdVda+":"+cProdAdc+":"+cLocPAdic,nTamZWVPK)+"B"))
				If !ZWV->(Found())
					RecLock("ZWV",.T.)
					ZWV->ZWV_FILIAL := xFilial("ZWV")
					ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+cProdVda+":"+cProdAdc+":"+cLocPAdic
					ZWV->ZWV_DESCP	:= "OP OBS:"
					ZWV->ZWV_SEQ	:= "B"
					ZWV->ZWV_STATUS := "P"
					ZWV->(MsUnlock())
				EndIf

				// -> Se a OP não foi criada, executa o processo
				If ZWV->ZWV_STATUS <> "I"

					// -> Cria ordem de produção
					DbSelectArea("SC2")		
					cNumSC2	:=GetNumSC2()
					cSeqIt  :=StrZero(1,TamSx3("C2_ITEM")[1])			
					cSeqOP	:= '001' 
					cFilInt := xFilial("Z04")
					lOPOk   := .T.
				
					// -> Se gerou numero da OP, continua
					If AllTrim(cNumSC2) <> ""

						SB1->(DbSetOrder(1))  
						SB1->(DbSeek(xFilial("SB1")+cProdAdc))

						Pergunte("MTA650",.F.)			
						aMATA650:={	{'C2_FILIAL'   	,cFilInt				,NIL},;
									{'C2_PRODUTO'  	,SB1->B1_COD		    ,NIL},;
									{'C2_NUM'  	   	,cNumSC2				,NIL},;          
									{'C2_ITEM'     	,cSeqIt					,NIL},;          
									{'C2_SEQUEN'   	,cSeqOP					,NIL},;
									{'C2_QUANT'		,(cAliasObs)->Z04_QTDE	,NIL},;
									{'C2_DATPRI'    ,dDataBase				,NIL},;
									{'C2_DATPRF'    ,dDataBase				,NIL},;
									{'C2_EMISSAO'   ,dDataBase				,NIL},;
									{'C2_TPOP'      ,'F'					,NIL},;
									{'C2_XSEQVDA'   ,"ALL"					,NIL},;
									{'C2_XCAIXA'    ,"ALL"					,NIL},;
									{'C2_XSEQIT'    ,"ALL"					,NIL},;
									{'AUTEXPLODE'   ,'S'					,Nil} ;
								}

						lMsErroAuto:=.F.
						msExecAuto({|x,Y| Mata650(x,Y)},aMATA650,3)
						// -> Se ocorreu erro, registra log				
						If lMsErroAuto
							lErro    := .T.
							cFileErr := "sc2_"+cFilAnt+"_"+cNumSC2+cSeqIt+cSeqOP+"_"+strtran(time(),":","")
							lOPOk    :=.F.
							MostraErro(cPathTmp, cFileErr)
							cErrorLog:=memoread(cPathTmp+cFileErr)
							cAuxLog  :="Erro na inclusao OP de observacao, verifique o detalhamento da ocorrencia."
							cAuxLogD :=cErrorLog
							fErase(cPathTmp+cFileErr)
							aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, (cAliasObs)->Z04_QTDE, "GERACAO DE OP (OBSERVACAO)", cProdAdc, cAuxLogD})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
							DisarmTransaction()
						Else
							// -> Reposiciona na ordem de produção e atualiza OPs intermediárias
							SC2->(DbSetOrder(1))
							SC2->(DbGotop())
							SC2->(DbSeek(cFilInt+cNumSC2))
							If SC2->(Found())				
								While !SC2->(Eof()) .and. SC2->C2_FILIAL == cFilInt .and. SC2->C2_NUM == cNumSC2 
									// -> Posiciona no produto da OP
									SB1->(DbSetOrder(1))
									SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
									If RecLock("SC2",.F.)
										SC2->C2_XSEQVDA:="ALL"
										SC2->C2_XCAIXA :="ALL"
										SC2->C2_XSEQIT :="ALL"
										SC2->C2_XDESCP :=SB1->B1_DESC
										SC2->(MsUnlock())
										lOPOk:= .T.
										// -> Atualiza empenhos com os dados da venda
										SD4->(DbOrderNickName("D4PRODUTO"))
										SD4->(DbSeek(SC2->C2_FILIAL+SC2->C2_PRODUTO+PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD4_OP)))			
										While !SD4->(Eof()) .and. SD4->D4_FILIAL+SD4->D4_PRODUTO+SD4->D4_OP == SC2->C2_FILIAL+SC2->C2_PRODUTO+PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD4_OP)
											If RecLock("SD4",.F.)
												SD4->D4_XSEQVDA:="ALL"
												SD4->D4_XCAIXA :="ALL"
												SD4->D4_XSEQIT :="ALL"
												SD4->(MSUnlock())
											Else
												lErro :=.T.
												lOPOk :=.F.
												cAuxLogD:="Ocorreu erro na altercao dos campos de sequencia da venda, caixa e sequencia do item (Campos: D4_XSEQVDA, D4_XCAIXA e D4_XSEQIT)."
											EndIf   										
											SD4->(DbSkip())
										EndDo												
										// -> Confirma OP
										If RecLock("ZWV",.F.)
											ZWV->ZWV_DESCP	:= "OP OBS:"+cNumSC2+cSeqIt+cSeqOP
											ZWV->ZWV_STATUS := "I"
											ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
											ZWV->(MsUnlock())
										Else
											lErro   :=.T.
											lOPOk   :=.F.
											cAuxLogD:="Ocorreu erro na altercao dos campos da tabela ZWV (Campos: ZWV_DESCP e ZWV_STATUS)."
										EndIf
									Else
										lErro :=.T.
										lOPOk :=.F.
										cAuxLogD:="Ocorreu erro na altercao dos campos de sequencia da venda, caixa e sequencia do item (Campos: C2_XSEQVDA, C2_XCAIXA, C2_XSEQIT e C2_XDESCP)."
									EndIf
									SC2->(DbSkip())
								EndDo
								// -> Atualiza log das OPs intermediárias
								If lOPOk
									// -> Seleciona ordens de produção intermediarias e inclui no controle de OPs
									SC2->(DbSetOrder(1))
									SC2->(DbGoTop())
									SC2->(DbSeek(cFilInt+cNumSC2))
									While !SC2->(Eof()) .and. SC2->C2_FILIAL == cFilInt .and. SC2->C2_NUM == cNumSC2 
										cxTime:=Time()
										If !Empty(SC2->C2_SEQPAI) 
										RecLock("ZWV",.T.)					        	    
											ZWV->ZWV_FILIAL := xFilial("ZWV")
											ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL
											ZWV->ZWV_DESCP	:= "OP OBS:"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
											ZWV->ZWV_SEQ	:= "B"
											ZWV->ZWV_STATUS := "I"
											ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
											ZWV->(MsUnlock())
										EndIf	
										SC2->(DbSkip())
									EndDo
									// -> Atualiza log do processo
									cAuxLog :="OP numero " + cNumSC2 + ", item " + cSeqIt + " e " + cSeqOP + " incluida com sucesso."
									aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP (OBSERVACAO)", SB1->B1_COD, cAuxLog})
									ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
								Else	
									cAuxLog  :="Erro na inclusao da OP. [C2_NUM="+cNumSC2+", C2_ITEM="+cSeqIt+" e C2_SEQUEN="+cSeqOP+"]"						
									aadd(aRetOP,{cNumSC2+cSeqIt+cSeqOP,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP (OBSERVACAO)", SB1->B1_COD, cAuxLog})
									ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
									DisarmTransaction()
								EndIf	
								// -> Reposiciona no produto original da OP
								SB1->(DbSetOrder(1))
								SB1->(DbSeek(xFilial("SB1")+cProdOrigem))
							Else
								lErro    :=.T.
								lOPOk    :=.F.
								cAuxLog  :="OP numero " + cNumSC2 + " nao encontrada na SC2."
								aadd(aRetOP,{cNumSC2,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, (cAliasObs)->Z04_QTDE, "GERACAO DE OP (OBSERVACAO)", cProdAdc, cAuxLog})
								ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
								DisarmTransaction()
							EndIf
						EndIf
					Else				
						lErro    :=.T.
						lOPOk    :=.F.
						cAuxLog  :="Erro na inclusao da OP de observacao."
						cAuxLogD :="Nao foi possivel gerar o numero da proxima OP pela funcao GetNumSC2()."
						aadd(aRetOP,{"","SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, (cAliasObs)->Z04_QTDE, "GERACAO DE OP (OBSERVACAO)", cProdAdc, cAuxLogD})
						ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						DisarmTransaction()
					EndIf
				EndIf	
			ElseIf !(SB1->B1_TIPO $ "PA/PI") .and. SB1->B1_FANTASM <> "S"
				// -> Posiciona no cadastro do produto
				SB1->(DbSetOrder(1))  
				SB1->(DbSeek(xFilial("SB1")+cProdAdc))

				// -> Pesquisa ordem de produção com o produto vendenda
				cAliasOP:=GetNextAlias()
				cQuery := "SELECT  DISTINCT C2_NUM||C2_ITEM||C2_SEQUEN OP     "
				cQuery += "FROM " + RetSqlName("SC2") + "                     "
				cQuery += "WHERE D_E_L_E_T_ <> '*'                        AND "
				cQuery += "      C2_FILIAL   = '" + xFilial("SC2")  + "'  AND "
				cQuery += "      C2_EMISSAO  = '" + DtoS(dDataBase) + "'  AND "
				cQuery += "      C2_PRODUTO  = '" + cProdVda        + "'      "
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOP,.T.,.T.)
	 
				cAuxOP:=""
				(cAliasOP)->(dbGoTop())
				While !(cAliasOP)->(Eof())
					cAuxOP:=(cAliasOP)->OP
				 	(cAliasOP)->(DbSkip())
	 			EndDo
				(cAliasOP)->(DbCloseArea())
				
				// -> Gera registro para outros itens sem ordem de produção
				ZWV->(dbSetOrder(1))
				ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+cProdVda+":"+SB1->B1_COD+":"+SB1->B1_LOCPAD+":"+cAuxOP,nTamZWVPK)+"J"))
				If !ZWV->(Found())
					RecLock("ZWV",.T.)
					ZWV->ZWV_FILIAL := xFilial("ZWV")
					ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+cProdVda+":"+SB1->B1_COD+":"+SB1->B1_LOCPAD+":"+cAuxOP
					ZWV->ZWV_DESCP	:= "PRODUTO OBS:"+SB1->B1_COD+":"+StrZero((cAliasObs)->Z04_QTDE,14,6)
					ZWV->ZWV_SEQ	:= "J"
					ZWV->ZWV_STATUS := "P"
					ZWV->(MsUnlock())
				EndIf
				
				// -> Atualiza log do processo
				cAuxLog :="Ok."
				aadd(aRetOP,{SB1->B1_COD+SB1->B1_LOCPAD,"SD3","L",3,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP (OBSERVACAO)", SB1->B1_COD, cAuxLog})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
			
			EndIf	

		EndTran()	

		(cAliasObs)->(DbSkip())
	
	EndDo
	
	(cAliasObs)->(DbCloseArea())

	// -> Verifica se existem OPs pendentes. Caso existam, exibe erro
    nAux:=Len(DtoS(dDataProc))
	ZWV->(DbSetOrder(1))
    ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
    While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)
		If ZWV->ZWV_SEQ $ "A/B" .and. ZWV->ZWV_STATUS = "P" 
			lErro  :=.T.
			aAuxOP :=StrToKarr(ZWV->ZWV_PK,":")
			cAuxLog:="Ha OPs pendentes para gerar a producao para o produto " + aAuxOP[02]
			aadd(aRetOP,{aAuxOP[02],"SC2","E",2,cAuxLog,.F.,"ALL",dDataProc, 0, "GERACAO DE OP", "", cAuxLog})
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
		EndIf	
		ZWV->(DbSkip())
	EndDo	

	nModulo:=nAuxMod
	lErro  :=IIF(lErro,.F.,.T.)

Return(lErro)


/*
+------------------+---------------------------------------------------------+
!Nome              ! F300DS                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Geração das vendas                                      !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 21/05/2018                                              !
+------------------+---------------------------------------------------------+
*/       

User Function F300DS(aRetSF2,oEventLog,nxIDThread,aRetSD3,cxDocSF2,cTipoDoc,cxSerSAT,cxSerie,cCRetSEFAZ)
Local cPathTmp  := "\temp\"
Local cFileErr  := ""
Local cFileName := ""
Local lErro		:= .F.
Local cAuxLog	:= ""
Local cAuxLogD	:= ""
Local cOpVda	:= GetMV("MV_XTPOPVD",,"01")
Local aSF2		:= {}
Local aSD2		:= {}
Local aItens	:= {}
Local cTes		:= ""
Local cItem     := CriaVar("D2_ITEM", .T.)
Local nTamDoc   := TamSx3("F2_DOC")[1]
Local aCabec    := {}
Local aLinha    := {}
Local nVrItemV  := 0
Local lErroProd := .F.
Local nVrDescSD2:= 0
Local nVrAcreSD2:= 0
Local nCoutItens:= 0
Local nVrTabela := 0
Local cFunNamAnt:= FunName()
Local nAux      := 0
Local nTamDecSD2:= TamSX3("D2_QUANT")[2]
Local aAuxSD2   := {}
Local nTamZWV_PK:= TamSX3("ZWV_PK")[1]
Local aAuxProc  := {}
Local nRecProc  := 0
Local cxTime    := Time()
Local nx        := 0
Local aAreaSA1  := {}
Local lLancPad20:=VerPadrao("620")
Local lLancPad10:=VerPadrao("610")
Local cLoteFat	:= "FAT "
Local cArqProva	:= ""
Local nTotLan 	:= 0
Local nHdlPrv	:= 0
Local dDataAnt  := dDataBase
Local lProcInt  := .F.
Private lMsErroAuto := .F.
	
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(cFilial+"09FAT"))
		cLoteFat := Trim(SX5->(X5Descri()))
	EndIf

	// -> Verifica os tipos de documentos (SAT e NFC) e a validação dos codigos da SEFAZ
	If AllTrim(cTipoDoc) <> "CF" .and. !(cCRetSEFAZ $ "100/101/102/110/150/151")
		cAuxLog :="Codigo de autorizacao da SEFAZ invalido para a sequencia de venda "+Z01->Z01_SEQVDA+" no caixa "+Z01->Z01_CAIXA+" em "+DtoC(Z01->Z01_DATA)+": "+Z01->Z01_OBSNFC
		lErro :=.T.
		aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLog})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
	Else
		// -> Registra log com o código de retono da SEFAZ
		cAuxLog:="Sera utilizado autorizacao da SEFAZ " + AllTrim(Z01->Z01_OBSNFC) + " para venda com sequencia " + Z01->Z01_SEQVDA + " no caixa "+Z01->Z01_CAIXA+" em "+DtoC(Z01->Z01_DATA)
		aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","W",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLog})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
	EndIf
	
	// -> Se não ocorrer erro, continua
	If !lErro
		// -> Verifica documento de entrada em aberto
		ZWV->(DbSetOrder(1))
		ZWV->(DbSeek(xFilial("ZWV")+PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)+"K"))
		If !ZWV->(Found())
			RecLock("ZWV",.T.)
			ZWV->ZWV_FILIAL := xFilial("ZWV")
			ZWV->ZWV_PK		:= PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)
			ZWV->ZWV_DESCP	:= "DOCUMENTO DE SAIDA"
			ZWV->ZWV_SEQ	:= "K"
			ZWV->ZWV_STATUS := "P"
			ZWV->(MsUnlock())
		EndIf	

		// -> Verifica se o documento fiscal já foi processado
		If ZWV->ZWV_STATUS == "I"
			cAuxLog	:="Ok."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Return(.T.)
		EndIf
		
		nRecProc:=ZWV->(Recno())

		// -> Cria ponto de lançamento do estoque para o documento fiscal, caso não exista
		DbSelectArea("ZWV")
		ZWV->(DbSetOrder(1))
		ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(Z01->Z01_ENTREG)+":"+cxDocSF2+cxSerie,nTamZWV_PK)+"Z"))
		If !ZWV->(Found())
			RecLock("ZWV",.T.)
			ZWV->ZWV_FILIAL := xFilial("ZWV")
			ZWV->ZWV_PK		:= DtoS(Z01->Z01_ENTREG)+":"+cxDocSF2+cxSerie
			ZWV->ZWV_DESCP	:= "ESTOQUES:"
			ZWV->ZWV_SEQ	:= "Z"
			ZWV->ZWV_STATUS := "P"
			ZWV->(MsUnlock())
		EndIf

		// -> Pesquisa cliente e, caso nao exista pega o cliente padrão		 
		SA1->(DbSetOrder(3))
		SA1->(DbSeek(xFilial("SA1")+Z01->Z01_CGC))		
		If !SA1->(Found()) .or. Empty(Z01->Z01_CGC)
			// -> Verifica se o cliente padrão está cadastrado
			SA1->(DbSetOrder(1))
			If !SA1->(DbSeek(xFilial("SA1")+cMVCLIPAD+cMVLOJAPAD))
				lErro 	:= .T.
				cAuxLog	:="Cliente "+cMVCLIPAD+" e loja " + cMVLOJAPAD + " nao encontrado."
				cAuxLogD:="Nao encontrado cliente "+cMVCLIPAD+" e loja " + cMVLOJAPAD + " na tabela SA1. Verifique os parametros MV_CLIPAD e MV_LOJAPAD."
				aadd(aRetSF2,{Z01->Z01_CGC,"SA1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLogD})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf	
		EndIf		

		// -> Pesquisa o documento fiscal
		lProcInt:=.F.
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))
		If SF2->(DbSeek(xFilial("SF2")+cxDocSF2+cxSerie+SA1->A1_COD+SA1->A1_LOJA))
			// -> Verifica se o documento de entrada e o financeiro já foi integrado
			ZWV->(DbSetOrder(1))
			ZWV->(DbSeek(xFilial("ZWV")+PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)+"K"))
			lProcInt:=ZWV->(Found()) .and. ZWV->ZWV_STATUS == "P"
			If lProcInt
				RecLock("ZWV",.F.)
				ZWV->ZWV_STATUS:="I"
				ZWV->ZWV_ELTIME:=ELAPTIME(cxTime,Time())
				ZWV->(MsUnlock())
			EndIf
			cAuxLog :="Documento fiscal " + cxDocSF2 + " com serie " + cxSerie + " ja incluido."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","W",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Return(.T.)
		EndIf
	EndIf

	// -> Se tudo ok, prossegue com a inclusão da NF
	If !lErro

		aSF2    := {}
		aSD2    := {}
		aadd(aSF2,{"F2_TIPO"   ,"N"														,Nil})
		aadd(aSF2,{"F2_DOC"    ,cxDocSF2												,Nil})
		aadd(aSF2,{"F2_SERIE"  ,cxSerie					    						    ,Nil})
		aadd(aSF2,{"F2_EMISSAO",Z01->Z01_DATA											,Nil})
		aadd(aSF2,{"F2_DTDIGIT",Z01->Z01_DATA											,Nil})
		aadd(aSF2,{"F2_HORA"   ,Z01->Z01_HORA											,Nil})
		aadd(aSF2,{"F2_CLIENTE",SA1->A1_COD												,Nil})
		aadd(aSF2,{"F2_LOJA"   ,SA1->A1_LOJA											,Nil})
		aadd(aSF2,{"F2_ESPECIE",cTipoDoc												,Nil})
		aadd(aSF2,{"F2_DESCONT",0														,Nil})
		aadd(aSF2,{"F2_DESPESA",0														,Nil})		
		aadd(aSF2,{"F2_FIMP"   ,"S"														,Nil})
		aadd(aSF2,{"F2_CHVNFE" ,Z01->Z01_CHVNFCE										,Nil})
		aadd(aSF2,{"F2_XSEQVDA",Z01->Z01_SEQVDA											,Nil}) 
		aadd(aSF2,{"F2_XCAIXA" ,Z01->Z01_CAIXA											,Nil})     
		aadd(aSF2,{"F2_XDTCAIX",Z01->Z01_ENTREG											,Nil})     
 		
		// -> Grava itens do documento
		aAuxSD2   :={}
		nVrDescSD2:=0
		nVrAcreSD2:=IIF(FieldPos("Z01_ACRESC")>0,Z01->Z01_ACRESC,0)
		nVrTabela :=0
		Z02->(DbSetOrder(3)) 
		Z02->(DbSeek(Z01->Z01_FILIAL+Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA)))
		While !Z02->(Eof()) .and. Z01->Z01_FILIAL == Z02->Z02_FILIAL .and. Z01->Z01_SEQVDA == Z02->Z02_SEQVDA .and. Z01->Z01_CAIXA == Z02->Z02_CAIXA .and. DtoS(Z01->Z01_DATA) == DtoS(Z02->Z02_DATA)
			nCoutItens:=nCoutItens+1
						
			// -> Posiciona produto			
			lErroProd:=.F.
			SB1->(DbOrderNickName("B1XCODEXT"))
			If !SB1->(DbSeek(xFilial("SB1")+Z02->Z02_PROD)) .or. Empty(Z02->Z02_PROD)
				lErro 	 := .T.
				lErroProd:=.T.
				cAuxLog	:="Produto com codigo externo " + AllTrim(Z02->Z02_PROD) + IIF(Empty(Z02->Z02_CODARV),""," e codigo de arvore "+Z02->Z02_CODARV+"-"+AllTrim(Z02->Z02_DESCPR))+" nao encontrado no Protheus [B1_XCODEXT="+Z02->Z02_PROD+"]."
				aadd(aRetSF2,{Z02->Z02_PROD,"SB1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf
					
			// -> Pega TES				
			If !lErroProd
				cTes:=MaTESInt(2,cOpVda,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
				If AllTrim(cTes) == ""
					lErro 	:= .T.
					cAuxLog	:="TES nao encontrada para o cliente e produto. [A1_COD="+SA1->A1_COD+", A1_LOJA="+SA1->A1_LOJA+" e B1_COD="+SB1->B1_COD+" - "+AllTrim(SB1->B1_DESC)+"]"
					aadd(aRetSF2,{"","SF4","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
				Else
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(xFilial("SF4")+cTes))
					If !SF4->(Found())
						lErro 	:= .T.
						cAuxLog	:="TES nao encontrada na tabela SF4. [F4_FILIAL="+xFilial("SF4")+" e F4_CODIGO="+cTes+"]"
						aadd(aRetSF2,{cTes,"SF4","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
						Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
					EndIf
				EndIf
			EndIf		

			// -> Se não ocorreu erro, continua o porcesso
			If !lErro
				
				cItem := Soma1(cItem)					
				aItens:= {}

				nVrItemV := Z02->Z02_VRITEM
				nVrTabela:= IIF(nVrItemV<=0,0,Z02->Z02_PRCTAB)
				aadd(aItens,{"D2_ITEM" 		,cItem															,Nil})
				aadd(aItens,{"D2_COD"  		,SB1->B1_COD													,Nil})
				aadd(aItens,{"D2_LOCAL"  	,SB1->B1_LOCPAD													,Nil})
				aadd(aItens,{"D2_QUANT"		,NoRound(Z02->Z02_QTDE,TamSX3("Z02_QTDE")[2])					,Nil})
				If nVrItemV > 0
					aadd(aItens,{"D2_PRCVEN"	,NoRound(nVrItemV ,TamSX3("D2_PRCVEN")[2])				    ,Nil})
				EndIf
				aadd(aItens,{"D2_PRUNIT"	,NoRound(nVrTabela,TamSX3("D2_PRUNIT")[2])			        	,Nil})
				aadd(aItens,{"D2_DESC"		,Z02->Z02_PERDESC												,Nil})
				aadd(aItens,{"D2_DESCON"	,Z02->Z02_VRDESC												,Nil})
				aadd(aItens,{"D2_TOTAL"		,NoRound(Z02->Z02_QTDE*nVrItemV,TamSX3("D2_PRCVEN")[2])	        ,Nil})
				aadd(aItens,{"D2_TES"		,SF4->F4_CODIGO													,Nil})
				aadd(aItens,{"D2_CF"		,SF4->F4_CF													    ,Nil})
				aadd(aItens,{"D2_BASEICM"	,Z02->Z02_BASCAL												,Nil})
				aadd(aItens,{"D2_PICMS"		,Z02->Z02_ALIQIC												,Nil})
				aadd(aItens,{"D2_VALICM"	,Z02->Z02_VRIMP													,Nil})
				aadd(aItens,{"D2_BASEIMP5"	,Z02->Z02_BASCOF												,Nil})
				aadd(aItens,{"D2_ALIQIMP5"	,Z02->Z02_PCOFIN												,Nil})
				aadd(aItens,{"D2_VALIMP5"	,Z02->Z02_VRCOFI												,Nil})
				aadd(aItens,{"D2_BASEIMP6"	,Z02->Z02_BASPIS												,Nil})
				aadd(aItens,{"D2_ALIQIMP6"	,Z02->Z02_PPIS													,Nil})
				aadd(aItens,{"D2_VALIMP6"	,Z02->Z02_VRPIS													,Nil})
				aadd(aItens,{"D2_XSEQVDA"	,Z02->Z02_SEQVDA												,Nil})
				aadd(aItens,{"D2_XCAIXA"	,Z02->Z02_CAIXA													,Nil})
				aadd(aItens,{"D2_XSEQIT"	,Z02->Z02_SEQIT													,Nil})

				Aadd(aAuxSD2,{cItem,Z02->Z02_SEQVDA,Z02->Z02_CAIXA,Z02->Z02_SEQIT})
				
				aadd(aSD2,aItens)			  		
				
				nVrDescSD2+=Z02->Z02_VRDESC
				nVrAcreSD2+=Z02->Z02_VRACRE 
				
				// -> Valida dados de despesas / valor unitário dos itens
				If nVrItemV <= 0 .and. !lErro
					// -> Verifica configuração da TES
					If SF4->F4_VLRZERO <> "1" .or. SF4->F4_QTDZERO <> "1"
						lErro 	:= .T.
						cAuxLog	:=SF4->F4_CODIGO+" - Tes nao configurada para aceitar valor unitario zerado."
						cAuxLogD:="TES " + AllTrim(SF4->F4_CODIGO) + " invalida. Devera ser verificada a configuracao dos campos F4_VLRZERO e F4_QTDZERO para que aceitem o vaor unitário do item zerado."
						aadd(aRetSF2,{"","SF4","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLogD})
						Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
					EndIf
				EndIf
				
			EndIf
				
			Z02->(DbSkip())

		EndDo
		
		// -> Se não ocorreu erro, continua...
		If !lErro

			dDataBase  := Z01->Z01_DATA 
				
			BeginTran()
												
				// -> Se não ocorreu erro, continua...
				If !lErro

					// -> Atualiza compo de desconto no cabeçalho do documento discal
					nAux:=aScan(aSF2,{|xz| AllTrim(xz[1]) == "F2_DESCONT"})
					If nAux > 0
						aSF2[nAux,2]:=nVrDescSD2
					EndIf
				
					// -> Atualiza compo de despesas no cabeçalho do documento discal
					nAux:=aScan(aSF2,{|xz| AllTrim(xz[1]) == "F2_DESPESA"})
					If nAux > 0
						aSF2[nAux,2]:=nVrAcreSD2
					EndIf

					SB1->(DbSetOrder(1))	/* há um bug na MATA920 em que ela só acha o produto, se a B1 já estiver ordenada no primeiro indice */
				
					lMsErroAuto:= .F.
					aAreaSA1   :=SA1->(GetArea())
					SetFunName("MATA920")
					SF2->(DbSetOrder(1))
					MATA920(aSF2,aSD2,3)
					SF2->(DbOrderNickName("SEQVDA"))
					RestArea(aAreaSA1)
					SetFunName(cFunNamAnt)
					If lMsErroAuto
						dDataBase:=dDataAnt
						lErro	 := .T.
						cFileName:= "sf2_"+cFilAnt+"_"+AllTrim(cxDocSF2)+Z01->Z01_CAIXA+SA1->A1_COD+SA1->A1_LOJA+"_"+strtran(time(),":","")
						MostraErro(cPathTmp, cFileName)
						cFileErr :=memoread(cPathTmp+cFileName)
						cAuxLog  :="Erro na geracao do documento fiscal. Verifique o detalhe da ocorrencia."
						cAuxLogD :=cFileErr
						fErase(cPathTmp+cFileName)
						aadd(aRetSF2,{cxDocSF2+cxSerie+SA1->A1_COD+SA1->A1_LOJA,"SF2","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLogD})
						ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						DisarmTransaction()
					Else
						// -> faz o ajuste para gravar campos adicionais na SF2 (não estão sendo gravados no execauto)
						DbSelectArea("SF2")
						SF2->(DbSetOrder(1))
						cChave := xFilial('SF2') + cxDocSF2 + cxSerie + SA1->A1_COD + SA1->A1_LOJA //+ ' ' + cTipoDoc			
						If !SF2->(DbSeek(cChave))
							lErro	 := .T.
							dDataBase:=dDataAnt
							cAuxLog  := "Erro na alteracao do documento fiscal."
							cAuxLogD := "Documento fiscal " + cxDocSF2 + " para o caixa " + Z01->Z01_CAIXA + " nao encontrado na tabela SF2." 
							aadd(aRetSF2,{cxDocSF2+cxSerie+SA1->A1_COD+SA1->A1_LOJA,"SF2","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLogD})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)		
							DisarmTransaction()			
						Else
							// -> Reposiciona no cliente
							DbSelectArea("SA1")
							SA1->(DbSetOrder(1))
							SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))		

							// -> Prepara contabilização
							nTotLan := 0
							If (lLancPad10 .Or. lLancPad20) .And. (nHdlPrv :=HeadProva(cLoteFat,"MATA460",cUserName,@cArqProva)) <= 0
								dDataBase:=dDataAnt
								cAuxLog	 :="Erro na contabilização do documento fiscal."
								aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", ""})
								Conout(StrZero(nxIDThread,10)+": "+cAuxLog)								
							EndIf
							
							// -> Atualiza dados complementares da NF
							RecLock('SF2',.F.)
							SF2->F2_XSEQVDA := Z01->Z01_SEQVDA
							SF2->F2_XCAIXA  := Z01->Z01_CAIXA
							SF2->F2_XDTCAIX :=Z01->Z01_ENTREG
							SF2->F2_SERSAT  := cxSerSAT
							SF2->F2_ECF     := IIF(cTipoDoc=="CF","S","N")
							SF2->F2_PDV     := IIF(cTipoDoc=="CF","Z01->Z01_CAIXA","")
							SF2->(MsUnlock())
								
							If lLancPad20
								nTotLan+=DetProva(nHdlPrv,"620","MATA460",cLoteFat)
							Endif
								
							// -> Atualiza os dados adicionais dos itns para movimentação de estoque 
							DbSelectArea("SD2")
							SD2->(DbGoTop())
							SD2->(DbSetOrder(3))
							SD2->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
							While !SD2->(Eof()) .and. SF2->F2_FILIAL == SD2->D2_FILIAL .and. SF2->F2_DOC == SD2->D2_DOC .and. SF2->F2_SERIE == SD2->D2_SERIE .and. SF2->F2_CLIENTE == SD2->D2_CLIENTE .and. SF2->F2_LOJA == SD2->D2_LOJA
										
								// -> Pesquisa posicao dos campos no array vendas no Array
								nAux:=aScan(aAuxSD2,{|xz| AllTrim(xz[1]) == SD2->D2_ITEM})
								RecLock("SD2",.F.)
								SD2->D2_PDV    :=IIF(cTipoDoc=="CF","Z01->Z01_CAIXA","")					
								SD2->D2_XSEQVDA:=aAuxSD2[nAux,02]
								SD2->D2_XCAIXA :=aAuxSD2[nAux,03]
								SD2->D2_XSEQIT :=aAuxSD2[nAux,04]
								SD2->(MsUnlock())

								// -> Posiciona no cadastro de TES
								DbSelectArea("SF4")
								SF4->(DbSetOrder(1))
								SF4->(xFilial("SF4")+SD2->D2_TES)
									
								// -> Posiciona no cadastro de produto
								DbSelectArea("SB1")
								SB1->(DbSetOrder(1))
								SB1->(xFilial("SB1")+SD2->D2_COD)

								// -> Gera Lancamento Contabeis a nivel de itens
								If lLancPad10
									nTotLan+=DetProva(nHdlPrv,"610","MATA460",cLoteFat)
								Endif
							
								SD2->(DbSkip())
							EndDo
	
							cAuxLog  := "Ok. "+AllTrim(Str(nCoutItens))+ " registros processados."
							cAuxLogD := "Documento fiscal " + cxDocSF2 + " para o caixa " + Z01->Z01_CAIXA + " incluido com sucesso." 
							aadd(aRetSF2,{cxDocSF2+cxSerie+SA1->A1_COD+SA1->A1_LOJA,"SF2","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", cAuxLogD})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)	
								
							// -> Envia para Lancamento Contabil, se gerado arquivo
							If (lLancPad10 .Or. lLancPad20)
								RodaProva(nHdlPrv,nTotLan)
								cA100Incl(cArqProva,nHdlPrv,3,cLoteFat,.F.,.T.)
								// -> Atualiza flag de contabilização
								RecLock('SF2',.F.)
								SF2->F2_DTLANC:=dDataBase
								SF2->(MsUnlock())
							Endif
							
							// -> Atualiza a SFT
							cAuxLog	:="Atualizando complementos fiscais - SFT."
							aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", ""})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

							SFT->(DbSetOrder(1))
							SFT->(DbSeek(SF2->F2_FILIAL+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))	
							If SFT->(Found())
								While !SFT->(eOF()) .and. SFT->FT_FILIAL == SF2->F2_FILIAL .and. SFT->FT_TIPOMOV == "S" .and. SFT->FT_SERIE == SF2->F2_SERIE .and. SFT->FT_NFISCAL == SF2->F2_DOC .and. SFT->FT_CLIEFOR == SF2->F2_CLIENTE .and. SFT->FT_LOJA == SF2->F2_LOJA 
									If RecLock("SFT",.F.)
										SFT->FT_PDV    :=SF2->F2_PDV
										SFT->FT_SERSAT :=SF2->F2_SERSAT
										SFT->(MsUnlock())						
									EndIf
									SFT->(DbSkip())
								EndDo	
							EndIf	
						
							// -> Atualiza log de complementos fiscais - SFT
							cAuxLog	:="Ok."
							aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", ""})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

							// -> Atualiza a SF3
							cAuxLog	:="Atualizando complementos fiscais - SF3."
							aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", ""})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

							SF3->(DbSetOrder(1))
							SF3->(DbSeek(SF2->F2_FILIAL+DtoS(SF2->F2_EMISSAO)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))	
							If SF3->(Found())
								While !SF3->(Eof()) .and. SF3->F3_FILIAL == SF2->F2_FILIAL .and. DtoS(SF3->F3_ENTRADA) == DtoS(SF2->F2_EMISSAO) .and. SF3->F3_NFISCAL == SF2->F2_DOC .and. SF3->F3_SERIE == SF2->F2_SERIE .and. SF3->F3_CLIEFOR == SF2->F2_CLIENTE .and. SF3->F3_LOJA == SF2->F2_LOJA 
									If RecLock("SF3",.F.)
										SF3->F3_PDV    :=SF2->F2_PDV
										SF3->F3_ECF    :=SF2->F2_ECF
										SF3->F3_SERSAT :=SF2->F2_SERSAT
										SF3->F3_CODRSEF:=cCRetSEFAZ
										SF3->(MsUnlock())						
									EndIf
									SF3->(DbSkip())
								EndDo	

								// -> Atualiza log de complementos fiscais - SF3
								cAuxLog	:="Ok."
								aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "DOCUMENTO FISCAL", "", ""})
								Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
							EndIf								
						EndIf
					EndIf
				
					// -> Se não ocorreu erro, finaliza o processo
					If !lErro
						ZWV->(DbGoTo(nRecProc))
						RecLock("ZWV",.F.)
						ZWV->ZWV_STATUS:="I"
						ZWV->ZWV_ELTIME:=ELAPTIME(cxTime,Time())
						ZWV->(MsUnlock())
					EndIf	

				EndIf	
			
			EndTran()
		
		    dDataBase:=dDataAnt

		EndIf
			
	EndIf
	
	// -> Verifica se o documento de entrada está pendente para inclusão e, caso esteja, retorna false
	If !lErro
		ZWV->(DbSetOrder(1))
		ZWV->(DbSeek(xFilial("ZWV")+PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)+"K"))
		If !ZWV->(Found()) .or. ZWV->ZWV_STATUS == "P"
			lErro:=.T.
		EndIf		
	EndIf

	lErro:=IIF(lErro,.F.,.T.)

Return(lErro)


/*
+------------------+---------------------------------------------------------+
!Nome              ! F300LD2                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! F300LD2 - Verifica para quais dias existe item          !
!                  ! pendente de integração									 !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/06/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300LD2(_Fil,dDtStart)
Local cRet     := "" 
Local _cAlias  := GetNextAlias()
Local nxInt    := 0
Local nxNInt   := 0
Local dAux     := CtoD("  /  /  ")
Local nDias    := 1
Local dAnt     := CtoD("  /  /  ")
Local _cQuery  := ""
Local nTamZWVPK:= TamSX3("ZWV_PK")[01]

	_cQuery := "SELECT MAX(F2_XDTCAIX) F2_EMISSAO "  
	_cQuery += "FROM " + RetSqlName("SF2")    + "          "    
	_cQuery += "WHERE D_E_L_E_T_ <> '*'                AND "
	_cQuery += "      F2_FILIAL   = '" + _Fil + "'     AND "
    _cQuery += "      F2_XSEQVDA <> ' '                    "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
	(_cAlias)->(DbGoTop())
	While !(_cAlias)->(Eof())
		cRet    :=(_cAlias)->F2_EMISSAO
		(_cAlias)->(DbSkip())	
	EndDo	
	(_cAlias)->(dbCloseArea())

	// -> Verifica se há uma data de início do processo; caso haja, inicia o processo apartir desta data
	If dDtStart > StoD(cRet)
		cRet    :=DToS(dDtStart)
	EndIf	
	
	// -> Verifica se todos os itens foram integrados, caso tenha itens faltando, retorna como última data de integração
	If !Empty(cRet)
		_cQuery := "SELECT COUNT(*) INTEG, 0        NINTEG "
		_cQuery += "FROM " + RetSqlName("Z01")    + "      " 
		_cQuery += "WHERE D_E_L_E_T_ <> '*'            AND "
      	_cQuery += "Z01_FILIAL        = '" + _Fil + "' AND "
      	_cQuery += "Z01_ENTREG        = '" + cRet + "'     "
		_cQuery += "UNION ALL                              "
		_cQuery += "SELECT 0        INTEG, COUNT(*) NINTEG "
		_cQuery += "FROM " + RetSqlName("Z01")    + "      " 
		_cQuery += "WHERE D_E_L_E_T_ <> '*'            AND "
      	_cQuery += "Z01_FILIAL        = '" + _Fil + "' AND "
      	_cQuery += "Z01_ENTREG        = '" + cRet + "' AND "
      	_cQuery += "Z01_XSTINT        = 'P'                " 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
		
		(_cAlias)->(DbGoTop())
		While !(_cAlias)->(Eof())
			nxInt +=(_cAlias)->INTEG
			nxNInt+=(_cAlias)->NINTEG		
			(_cAlias)->(DbSkip())
		EndDo
		(_cAlias)->(dbCloseArea())
		
		// -> Busca a próxima data para integrar
		dAux :=StoD(cRet)
		nAux :=IIF(Date()-dAux<=0,1,Date()-dAux)+1
		nDias:=1
		While nDias <= nAux
			    
			// -> Verifica se as Ordens de produção das vendas do dia anterior foram apontada; 
			//    caso não foram, retorna a database para o dia anterior; 
			//    e, se foram apontadas, passa para o próximo dia.
		    DbSelectArea("ZWV")
    	    ZWV->(DbSetOrder(1))
    	    ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dAux),nTamZWVPK)+"W"))
    		If ZWV->(Found()) .and. ZWV->ZWV_STATUS == "P" 
		        
				dAnt:=dAux
				cRet:=DtoS(dAnt)
				Exit
    	        
			ElseIf !ZWV->(Found())
								
				// -> Cria ponto de lançamento das OPs, caso não exista
				DbSelectArea("ZWV")
				ZWV->(DbSetOrder(1))
				ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dAux),nTamZWVPK)+"Y"))
				If !ZWV->(Found())
					RecLock("ZWV",.T.)
					ZWV->ZWV_FILIAL := xFilial("ZWV")
					ZWV->ZWV_PK		:= DtoS(dAux)
					ZWV->ZWV_DESCP	:= "OPS:"
					ZWV->ZWV_SEQ	:= "Y"
					ZWV->ZWV_STATUS := "P"
					ZWV->(MsUnlock())
				EndIf
				
				// -> Cria ponto de lançamento dos estoques
				DbSelectArea("ZWV")
				ZWV->(DbSetOrder(1))
				ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dAux),nTamZWVPK)+"W"))
				If !ZWV->(Found())
					RecLock("ZWV",.T.)
					ZWV->ZWV_FILIAL := xFilial("ZWV")
					ZWV->ZWV_PK		:= DtoS(dAux)
					ZWV->ZWV_DESCP	:= "ESTOQUES:"
					ZWV->ZWV_SEQ	:= "W"
					ZWV->ZWV_STATUS := "P"
					ZWV->(MsUnlock())
				EndIf
				
				dAnt:=dAux
				cRet:=DtoS(dAnt)
				Exit

			EndIf

			// -> Vai para o próximo dia
			dAnt:=dAux
			dAux:=dAux+1					
			nDias:=nDias+1

		EndDo

	Else

	 	// -> Se não integrou nenhuma venda, dusaca a primeira data da venda a integrar
		_cQuery := " SELECT MIN(Z01_ENTREG) AS Z01_DATA       "
		_cQuery += " FROM " + RetSqlName("Z01")    + "      "
		_cQuery += " WHERE Z01_FILIAL  = '" + _Fil + "' AND "    
	    _cQuery += "       Z01_XSTINT <> 'I'            AND "
		_cQuery += "       D_E_L_E_T_ <> '*'                " 
		_cQuery += " ORDER BY Z01_ENTREG                      " 
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
		(_cAlias)->(DbGoTop())
		cRet := (_cAlias)->Z01_DATA
		(_cAlias)->(dbCloseArea()) 

		dAux := StoD(cRet)

		// -> Cria ponto de lançamento das OPs, caso não exista, caso existam vendas a integrar
		If !Empty(dAux)
			DbSelectArea("ZWV")
			ZWV->(DbSetOrder(1))
			ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dAux),nTamZWVPK)+"Y"))
			If !ZWV->(Found())
				RecLock("ZWV",.T.)
				ZWV->ZWV_FILIAL := xFilial("ZWV")
				ZWV->ZWV_PK		:= DtoS(dAux)
				ZWV->ZWV_DESCP	:= "OPS:"
				ZWV->ZWV_SEQ	:= "Y"
				ZWV->ZWV_STATUS := "P"
				ZWV->(MsUnlock())
			EndIf
					
			// -> Cria ponto de lançamento dos estoques
			DbSelectArea("ZWV")
			ZWV->(DbSetOrder(1))
			ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dAux),nTamZWVPK)+"W"))
			If !ZWV->(Found())
				RecLock("ZWV",.T.)
				ZWV->ZWV_FILIAL := xFilial("ZWV")
				ZWV->ZWV_PK		:= DtoS(dAux)
				ZWV->ZWV_DESCP	:= "ESTOQUES:"
				ZWV->ZWV_SEQ	:= "W"
				ZWV->ZWV_STATUS := "P"
				ZWV->(MsUnlock())
			EndIf

		EndIf	

	EndIf

Return(cRet)


/*
+------------------+---------------------------------------------------------+
!Nome              ! AFAT300E                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Ajusta empenhos                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/06/2018                                              !
+------------------+---------------------------------------------------------+
!Alterações        ! Márcio A. Zaguetti em 05/01/1020                        !
!                  !                                                         !
+------------------+---------------------------------------------------------+
*/
User Function AFAT300E(aRetEMP,dDataProc,oEventLog,nxIDThread) 
Local cPathTmp  := "\temp\"
Local cFileErr  := ""
Local cFileName := ""
Local lErro     := .F.
Local nAuxMod   := 0
Local nAux      := 0
Local aAuxOP    := {}
Local cAuxLog	:= ""
Local cAuxLogD  := ""
Local cAliasZ04 := ""
Local cAliasSD4 := ""
Local cAliasZ04O:= ""
Local aZ04POBS  := {}
Local aMata380  := {}
Local nx		:= 0
Local cxTime    := Time()
Local lOkEmpenho:= .T.
Local nTamZWVPK := TamSx3("ZWV_PK")[1]
Local lAlterou  := .F.
Local cQuery    := ""
Local nQtdeSald := 0
Local cCodProdVd:= ""
Local cCodProdMP:= ""

	nAuxMod	   :=nModulo
	nModulo	   :=4
	SetFunName("MATA380")

	// -> Pesquisa nos itens de venda e pega o código do produto de venda
	cAliasZ04:=GetNextAlias()
	cQuery   := "SELECT DISTINCT Z04.Z04_FILIAL, Z04.Z04_SEQVDA, Z04.Z04_CAIXA, Z04.Z04_DATA, Z04.Z04_SEQIT, Z04.Z04_CODMP, Z04.Z04_PRDUTO "             
	cQuery   += "FROM " + RetSqlName("Z04") + " Z04 INNER JOIN " + RetSqlName("SF2") + " SF2 "                     
	cQuery   += "    ON SF2.F2_FILIAL    = Z04.Z04_FILIAL AND "
	cQuery   += "       SF2.F2_XSEQVDA   = Z04.Z04_SEQVDA AND "
	cQuery   += "       SF2.F2_XCAIXA    = Z04.Z04_CAIXA  AND "
	cQuery   += "       SF2.F2_XDTCAIX   = Z04.Z04_ENTREG AND "
	cQuery   += "       SF2.D_E_L_E_T_  <> '*'                "         
	cQuery   += "WHERE Z04.Z04_FILIAL   = '" + xFilial("Z04")  + "'         AND "
	cQuery   += "      Z04.Z04_ENTREG   = '" + DtoS(dDataProc) + "'         AND "
	cQuery   += "	   Z04.Z04_IDCOBS   = ' '                               AND "
	cQuery   += "	   Z04.D_E_L_E_T_  <> '*'                                   "              
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ04,.T.,.T.)

	(cAliasZ04)->(dbGoTop())
	While !(cAliasZ04)->(Eof())			

		// -> Pesquisa quantidade a ser retirada para o produto e componente
		cAliasZ04O:=GetNextAlias()
		cQuery  := "SELECT Z04.Z04_CODMP, SUM(Z04.Z04_QTDE) Z04_QTDE "             
		cQuery  += "FROM " + RetSqlName("Z04") + " Z04 INNER JOIN " + RetSqlName("SF2") + " SF2 "                     
		cQuery  += "    ON SF2.F2_FILIAL    = Z04.Z04_FILIAL AND "
		cQuery  += "       SF2.F2_XSEQVDA   = Z04.Z04_SEQVDA AND "
		cQuery  += "       SF2.F2_XCAIXA    = Z04.Z04_CAIXA  AND "
		cQuery  += "       SF2.F2_XDTCAIX   = Z04.Z04_ENTREG AND "
		cQuery  += "       SF2.D_E_L_E_T_  <> '*'                "
		cQuery  += "WHERE Z04.Z04_FILIAL   = '" + xFilial("Z04")          + "'  AND "
        cQuery  += "      Z04.Z04_SEQVDA   = '" + (cAliasZ04)->Z04_SEQVDA + "'  AND " 
		cQuery  += "      Z04.Z04_CAIXA    = '" + (cAliasZ04)->Z04_CAIXA  + "'  AND "
		cQuery  += "      Z04.Z04_ENTREG   = '" + DtoS(dDataProc)         + "'  AND "
		cQuery  += "      Z04.Z04_SEQIT    = '" + (cAliasZ04)->Z04_SEQIT  + "'  AND "
		cQuery  += "      Z04.Z04_CODMP    = '" + (cAliasZ04)->Z04_CODMP  + "'  AND "
		cQuery  += "	  Z04.Z04_IDCOBS   = 'R'                                AND "
	    cQuery  += "	  Z04.Z04_PRDUTO  <> ' '         		                AND "
		cQuery  += "	  Z04.D_E_L_E_T_  <> '*'                                    "              
		cQuery  += "GROUP BY Z04.Z04_CODMP "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ04O,.T.,.T.)

		(cAliasZ04O)->(dbGoTop())
		While !(cAliasZ04O)->(Eof())	

			// -> Pesquisa componente da estrutura
			SB1->(DbOrderNickName("B1XCODEXT"))
			SB1->(DbSeek(xFilial("SB1")+(cAliasZ04)->Z04_CODMP))
			If !SB1->(Found()) .or. Empty((cAliasZ04)->Z04_CODMP)
				(cAliasZ04O)->(DbSkip())
				Loop
			EndIf	
			cCodProdMP:=SB1->B1_COD

			// -> Pesquisa produto de venda
			SB1->(DbOrderNickName("B1XCODEXT"))
			SB1->(DbSeek(xFilial("SB1")+(cAliasZ04)->Z04_PRDUTO))
			If !SB1->(Found()) .or. Empty((cAliasZ04)->Z04_PRDUTO)
				(cAliasZ04O)->(DbSkip())
				Loop
			EndIf	
			cCodProdVd:=SB1->B1_COD

			nAux:=aScan(aZ04POBS,{|kb| kb[01]==cCodProdVd+cCodProdMP})
			If nAux <= 0
		   		aAdd(aZ04POBS,{cCodProdVd+cCodProdMP,cCodProdVd,cCodProdMP,(cAliasZ04O)->Z04_QTDE,0})
			Else
				aZ04POBS[nAux,04]:=aZ04POBS[nAux,04]+(cAliasZ04O)->Z04_QTDE
			EndIf   

			(cAliasZ04O)->(dbSkip())

		Enddo
		(cAliasZ04O)->(DbCloseArea())

		(cAliasZ04)->(DbSkip())

	Enddo
	(cAliasZ04)->(DbCloseArea())


	// -> Faz o ajuste dos empenhos dos "itens retira"
	For nx:=1 to Len(aZ04POBS)

		// -> Pesquisa empenhos de OPs geradas para a "matéria prima retirada"
		cAliasSD4:=GetNextAlias()
		cQuery  := " SELECT R_E_C_N_O_ REC, D4_QTDEORI "
		cQuery  += " FROM " + RetSqlName("SD4")        "
		cQuery  += " WHERE D4_FILIAL  = '" + xFilial("SD4")  + "' AND "
		cQuery  += "      D4_DATA     = '" + DtoS(dDataProc)  + "' AND "
		cQuery  += "      D4_COD      = '" + aZ04POBS[nx,03]  + "' AND "
		cQuery  += "      D4_PRODUTO  = '" + aZ04POBS[nx,02]  + "' AND "
		cQuery  += "      D_E_L_E_T_ <> '*'                            "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.T.,.T.)
		
		If (cAliasSD4)->(Eof())
			Loop
		EndIf

		// -> Posiciona no empenho
		SD4->(DbGoTo((cAliasSD4)->REC))
		aZ04POBS[nx,05]:=SD4->D4_QTDEORI

		// -> Posiciona na ordem de produção
		SC2->(DbSetOrder(1))
		SC2->(DbSeek(xFilial("SC2")+SD4->D4_OP))

		// -> Posiciona no Produto de venda
		SB1->(dbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD))

		// -> Inclui processo de alteração de empenho
		ZWV->(DbSetOrder(1))
        ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase)+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":"+SD4->D4_COD+":"+SD4->D4_OP,nTamZWVPK)+"E"))
		If !ZWV->(Found())
    		RecLock("ZWV",.T.)
		    ZWV->ZWV_FILIAL := xFilial("ZWV")
			ZWV->ZWV_PK		:= DtoS(dDataBase)+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":"+SD4->D4_COD+":"+SD4->D4_OP
			ZWV->ZWV_DESCP	:= "EMPENHO OP:"+StrZero(aZ04POBS[nx,04],TamSx3("D4_QUANT")[1],TamSx3("D4_QUANT")[2])
			ZWV->ZWV_SEQ	:= "E"
			ZWV->ZWV_STATUS := "P"
			ZWV->(MsUnlock())
		EndIf

		// -> Se já integrado, vai para o proximo registro
		If ZWV->ZWV_STATUS == "I"
			Loop
		EndIf	

		lAlterou  := .F.
		nQtdeSald := NoRound(aZ04POBS[nx,05],TamSx3("D4_QUANT")[2])-NoRound(aZ04POBS[nx,04],TamSx3("D4_QUANT")[2])
		SD4->(DbSetOrder(1))
		// -> Se a quantidade empenhada menos o valor "do retira" for maior que zero, ajusta o empenho da OP
		If nQtdeSald > 0 
			
			lAlterou  :=.T.
			lOkEmpenho:=.T.
			
			BeginTran()

				cAuxLog:="OP "+SD4->D4_OP+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":"+SD4->D4_COD
				cAuxLogD:="Atualizando empenhos da OP no "+SC2->C2_NUM+", item "+SC2->C2_ITEM+", sequencia "+SC2->C2_SEQUEN+" e materia prima "+SB1->B1_COD
				aadd(aRetEMP,{SB1->B1_COD+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SD4","L",1,cAuxLog,.F.,"ALL",dDataProc, 0, "ALTERACAO DE EMPENHOS", SB1->B1_COD, cAuxLogD})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)

				aMata380 :={}
				aEmpenI	 :={}									
				aadd(aMata380,{"D4_COD"     ,SD4->D4_COD      	,Nil}) 
				aadd(aMata380,{"D4_LOCAL"   ,SD4->D4_LOCAL    	,Nil})
				aadd(aMata380,{"D4_OP"      ,SD4->D4_OP       	,Nil})
				aadd(aMata380,{"D4_DATA"    ,SD4->D4_DATA     	,Nil})
				aadd(aMata380,{"D4_QUANT"   ,nQtdeSald          ,Nil})
				aadd(aMata380,{"D4_QTDEORI" ,nQtdeSald          ,Nil})
				aadd(aMata380,{"D4_TRT"     ,SD4->D4_TRT      	,Nil})
				aadd(aMata380,{"D4_QTSEGUM" ,SD4->D4_QTSEGUM  	,Nil})

				// -> Atualiza os empenhos
				lMsErroAuto:=.F.
				Pergunte("MTA380")
				mata380(aMata380,4,aEmpenI)
				If lMsErroAuto
					lErro     := .T.
					lOkEmpenho:= .F.
					cFileName := "SD4_"+cFilAnt+"_"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"_"+strtran(time(),":","")
					MostraErro(cPathTmp, cFileName)
					cFileErr  :=memoread(cPathTmp+cFileName)
					fErase(cPathTmp+cFileName)
					cAuxLog   :="Erro na alteracao do empenho do produto. Verifique o detalhamento da ocorrencia."
					cAuxLogD  :="Erro na atualização do empenho do produto "+SB1->B1_COD+" para OP "+SC2->C2_NUM+", item " + SC2->C2_ITEM + " e sequencia " + SC2->C2_SEQUEN+Chr(13)+Chr(10)+Chr(13)+Chr(10)+cFileErr
					aadd(aRetEMP,{SB1->B1_COD+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SD4","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "ALTERACAO DE EMPENHOS", SB1->B1_COD, cAuxLogD})
					ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
					DisarmTransaction()
				EndIf
			
			EndTran()

		// -> Se o valor do retira for menor ou igual a zero, exclui o empenho
		ElseIf nQtdeSald <= 0 
			
			lAlterou  :=.T.
			lOkEmpenho:=.T.

			BeginTran()
								
				cAuxLog:="OP "+SD4->D4_OP+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":"+SD4->D4_COD
				cAuxLogD:="Excluindo empenhos da OP no "+SC2->C2_NUM+", item "+SC2->C2_ITEM+", sequencia "+SC2->C2_SEQUEN+" e materia prima "+SB1->B1_COD
				aadd(aRetEMP,{SB1->B1_COD+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SD4","L",1,cAuxLog,.F.,"ALL",dDataProc, 0, "ALTERACAO DE EMPENHOS", SB1->B1_COD, cAuxLogD})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
							
				aMata380 :={}
				aEmpenI	 :={}									
				aadd(aMata380,{"D4_COD"     ,SD4->D4_COD      	,Nil}) 
				aadd(aMata380,{"D4_LOCAL"   ,SD4->D4_LOCAL    	,Nil})
				aadd(aMata380,{"D4_OP"      ,SD4->D4_OP       	,Nil})
				aadd(aMata380,{"D4_DATA"    ,SD4->D4_DATA     	,Nil})
				aadd(aMata380,{"D4_QTDEORI" ,SD4->D4_QTDEORI	,Nil})
				aadd(aMata380,{"D4_QUANT"   ,SD4->D4_QUANT		,Nil})
				aadd(aMata380,{"D4_TRT"     ,SD4->D4_TRT      	,Nil})
				aadd(aMata380,{"D4_QTSEGUM" ,SD4->D4_QTSEGUM  	,Nil})

				// -> Atualiza os empenhos
				lMsErroAuto:=.F.
				Pergunte("MTA380")
				mata380(aMata380,5,aEmpenI) 
				If lMsErroAuto
					lErro     := .T.
					lOkEmpenho:= .F.
					cFileName := "SD4_"+cFilAnt+"_"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"_"+strtran(time(),":","")
					MostraErro(cPathTmp, cFileName)
					cFileErr :=memoread(cPathTmp+cFileName)
					fErase(cPathTmp+cFileName)
					cAuxLog  :="Erro na exclusao do empenho da OP. Verifique o detalhamento da ocorrencia."
					cAuxLogD :="Erro na exclusao do empenho do produto "+SB1->B1_COD+" para OP "+SC2->C2_NUM+", item " + SC2->C2_ITEM + " e sequencia " + SC2->C2_SEQUEN+Chr(13)+Chr(10)+Chr(13)+Chr(10)+cFileErr
					aadd(aRetEMP,{SB1->B1_COD+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SD4","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "ALTERACAO DE EMPENHOS", SB1->B1_COD, cAuxLogD})
					ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
					DisarmTransaction()									
				EndIf
								
			EndTran()
							
		EndIf
					
		// -> Se ok, atualiza o log
		If lOkEmpenho										
			// -> Atualiza os dados do processo de alteração do empenho
			RecLock("ZWV",.F.)
			ZWV->ZWV_STATUS := "I"
			ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
			ZWV->(MsUnlock())
		EndIf								
		Encontrou:=.F.
						
	Next nx

	// -> Verifica se existem empenhos pendentes. Caso existam, exibe erro
    aAux:={}
	nAux:=Len(DtoS(dDataProc))
	ZWV->(DbSetOrder(1))
    ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
    While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)
    	aAuxOP:=StrToKarr(ZWV->ZWV_PK,":")
		// -> Se for Empenho
		If ZWV->ZWV_SEQ $ "E" .and. ZWV->ZWV_STATUS == "P" 
			lErro:=.T.
			cAuxLog  :="Ha pendencia de atualizacao de empenho para o produto " + aAuxOP[02]
			aadd(aRetEMP,{aAuxOP[02],"SC2","E",2,cAuxLog,.F.,"ALL",dDataProc, 0, "ALTERACAO DE EMPENHO OBS", "", cAuxLog})
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
		EndIf	
		ZWV->(DbSkip())
	EndDo	

	lErro:=IIF(lErro,.F.,.T.)

Return(lErro)
                       



/*
+------------------+---------------------------------------------------------+
!Nome              ! FAT3003                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Apotamento das ordens de produção                       !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/06/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function FAT3003(aRetApon,dDataProc,oEventLog,aRetSB2,aRetSD3,nxIDThread)
Local aMata250	:= {}
Local lEncerra	:=.T.
Local nx   		:= 0
Local nRecProc  := 0
Local ny        := 0
Local lErro     := .F.
Local cPathTmp  := "\temp\"
Local cFileErr  := ""
Local cFileName := ""
Local aOPsAuxPI := {}
Local aOPsAuxPA := {}
Local lEncontrou:= .F.
Local cAuxLog	:= "" 
Local cAuxLogD  := ""
Local aAuxOP    := {}
Local aAuxItem  := {}
Local aAuxProc  := {}
Local aAuxProcOB:= {}
Local aAuxProcBX:= {}
Local nTamD3OP  := TamSx3("D3_OP")[1]
Local nTamC2NUM := TamSx3("C2_NUM")[1]
Local nTamZ01Seq:= TamSx3("Z01_SEQVDA")[1]
Local nTamZ01Cx := TamSx3("Z01_CAIXA")[1]
Local nTamZ01Dat:= 8
Local nTamZWVPK := TamSx3("ZWV_PK")[1]
Local nTamZ02It := TamSx3("Z02_SEQIT")[1]
Local cCodProdVd:= ""
Local cTipProdVd:= ""
Local cCodProdOP:= ""
Local cTipProdOP:= ""
Local cCodLocOP := ""
Local axOPs     := {}
Local cAuxOP    := ""
PRIVATE lMsErroAuto := .F.

	// -> Processa ordens de produção com observações
	cAuxLog	:="Apontamentando OPs de 'observacoes'..."
    aadd(aRetApon,{"","SD3","L",0,cAuxLog,.F.,"",dDataProc, 0, "APONTAMENTO PRODUCAO (OBS)", "", "", nxIDThread})
    Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)

	aAuxProcOB:={}
	aOPsAuxPI :={}
	aOPsAuxPA :={}
	axOPs     :={}
	nAux      :=Len(DtoS(dDataProc))   
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
	While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)			
	 	If ZWV->ZWV_SEQ $ "B" .and. ZWV->ZWV_STATUS == "I"			
	 		aadd(aAuxProcOB,ZWV->(Recno()))
	 	EndIf
	 	ZWV->(DbSkip())
	EndDo

	// -> Gera processo de apontamentos
	For nx:=1 to Len(aAuxProcOB)
		
		// -> Posiciona no processo
		ZWV->(DbGoTo(aAuxProcOB[nx]))			
		
		// -> Pega informações da OP
		aAuxOP  :=StrToKarr(ZWV->ZWV_DESCP,":")
		aAuxItem:=StrToKarr(AllTrim(ZWV->ZWV_PK),":")
		If Len(aAuxOP) == 2
		
	 		// -> Inclui processo de apontamento das OPs de Observação
	 		ZWV->(DbSetOrder(1))
         	ZWV->(DbSeek(xFilial("ZWV")+PADR(aAuxItem[01]+":"+aAuxItem[02]+":"+aAuxItem[03]+":"+aAuxOP[02],nTamZWVPK)+"I"))
	         If !ZWV->(Found())
     	        RecLock("ZWV",.T.)
	 	        ZWV->ZWV_FILIAL := xFilial("ZWV")
	 			ZWV->ZWV_PK		:= aAuxItem[01]+":"+aAuxItem[02]+":"+aAuxItem[03]+":"+aAuxOP[02]
	 			ZWV->ZWV_DESCP	:= "APONTAMENTO OP OBS"
	 			ZWV->ZWV_SEQ	:= "I"
	 			ZWV->ZWV_STATUS := "P"
	 			ZWV->(MsUnlock())
	 		EndIf	

			// -> Verifica se a opestá pendente de paontamento	
			If ZWV->ZWV_STATUS == "P"
				lEncontrou:=.T.
				aadd(axOPs,{aAuxOP[02],.F.,ZWV->(Recno())})
			EndIf

		Else
			
			lErro   :=.T.
			cAuxLog	:="Erro ao carregar os dados para apontamento da OP de 'observacoes'. Verifique o conteudo do campo ZWV_PK da tabela de processos de vendas."
			cAuxLogD:="Verifique o conteudo do campo ZWV_PK da tabela de processos de vendas. [ZWV_FILIAL="+ZWV->ZWV_FILIAL+", ZWV_PK=" + AllTrim(ZWV->ZWV_PK) + " e ZWV->ZWV_STATUS=" + ZWV->ZWV_STATUS + "]" 
			aadd(aRetApon,{ZWV->ZWV_PK+ZWV->ZWV_STATUS,"ZWV","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO (OBS)", "", cAuxLogD})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)				
		
		EndIf	
		
	Next nx

	// -> Ordena ordens de produção para fazer primeiro o apontamento do tipo PI das orderns de producao 'observacao'
	For nx:=1 to Len(axOPs)

		// -> Posiciona na ordem de produção		
		SC2->(DbSetOrder(1))
		If SC2->(DbSeek(xFilial("SC2")+axOPs[nx,01]))

			// -> Posiciona no cadastro do produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)) 

			// -> Armazena dados do PI / PA
			If SB1->B1_TIPO $ "PI" .and. SB1->B1_FANTASM <> "S"
				AADD(aOPsAuxPI,{axOPs[nx,01],axOPs[nx,02],SB1->B1_TIPO,axOPs[nx,03]})
			Else
				AADD(aOPsAuxPA,{axOPs[nx,01],axOPs[nx,02],SB1->B1_TIPO,axOPs[nx,03]})
			Endif

		EndIf

	Next nx

	// -> Atualiza ordens de producao priorizando os apontamentos de produtos PI das orderns de producao 'observacao'
	axOPs:={}
	For nx:=1 to Len(aOPsAuxPI)
		AADD(axOPs,{aOPsAuxPI[nx,01],aOPsAuxPI[nx,02],aOPsAuxPI[nx,03],aOPsAuxPI[nx,04],.F.})
	Next nx

	// -> Atualiza ordens de producao de producao 'observacao'
	For nx:=1 to Len(aOPsAuxPA)
		AADD(axOPs,{aOPsAuxPA[nx,01],aOPsAuxPA[nx,02],aOPsAuxPA[nx,03],aOPsAuxPA[nx,04],.F.})
	Next nx

	// -> Gera processo de apontamentos das ordens de producao 'observacao'
	For nx:=1 to Len(axOPs)
		 
		// -> Posiciona no processo
	 	ZWV->(DbGoTo(axOPs[nx,04]))	
		nRecProc:=ZWV->(Recno())

	 	// -> Pega informações da OP
	 	aAuxOP    :=StrToKarr(ZWV->ZWV_DESCP,":")
	 	aAuxItem  :=StrToKarr(AllTrim(ZWV->ZWV_PK),":")
		cxTime    := Time()
		cCodProdVd:= ""
		cTipProdVd:= ""
		cCodProdOP:= ""
		cTipProdOP:= ""

		// -> Posiciona na ordem de produção
		SC2->(DbSetOrder(1))
		If !SC2->(DbSeek(xFilial("SC2")+aAuxItem[04]))			
			lErro   :=.T.
			cAuxLog	:="OP nao encontrada no Protheus [C2_NUM+C2_ITEM+C2_SEQUEN="+aAuxItem[04]+"]" 
			aadd(aRetApon,{aAuxItem[04],"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO (OBS)", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Loop
		EndIf

		// -> Verifica se a OP já foi apontada, caso sim, apenas atualiza o ponto de lançamento na ZWV
		If SC2->C2_QUJE > 0
			RecLock("ZWV",.F.)
			ZWV->ZWV_DESCP	:= "APONTAMENTO OP OBS:"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+":"+SC2->C2_PRODUTO+":"+StrZero(SC2->C2_QUANT,12,6)
			ZWV->ZWV_STATUS := "I"
			ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
			ZWV->(MsUnlock())
			cAuxLog	:="Apontamento Ok." 
			aadd(aRetApon,{axOPs[nx,01],"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO (OBS)", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Loop
		EndIf

		// -> Posiciona do porduto da venda no Protheus
		SB1->(DbSetOrder(1))
	 	SB1->(DbSeek(xFilial("SB1")+aAuxItem[02])) 
		cCodProdVd:=SB1->B1_COD
		cTipProdVd:=SB1->B1_TIPO

		// -> Posiciona do porduto da OP
	 	SB1->(DbSetOrder(1))
	 	SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)) 
		cCodProdOP:=SB1->B1_COD
		cTipProdOP:=SB1->B1_TIPO
		cCodLocOP :=SC2->C2_LOCAL

		// -> Inicia a transação para apontamento da OP
		//BeginTran()
		cAuxLog	:="OP de observacao: " + SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN 
		cAuxLogD:="Apontando OP de observacao no. " + SC2->C2_NUM + ", item " + SC2->C2_ITEM + " e sequencia " + SC2->C2_SEQUEN
		aadd(aRetApon,{SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, SC2->C2_QUANT, "APONTAMENTO PRODUCAO (OBS)", SC2->C2_PRODUTO, cAuxLogD})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		aMata250:={ {"D3_OP" 		,SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN	,NIL},;
					{"D3_TM" 		,GetMV("MV_TMPAD" ,,"010")						,NIL},;
					{"D3_COD" 		,SC2->C2_PRODUTO 								,NIL},;
					{"D3_QUANT" 	,SC2->C2_QUANT 									,NIL},;
					{"D3_XSEQVDA" 	,SC2->C2_XSEQVDA 								,NIL},;
					{"D3_XCAIXA" 	,SC2->C2_XCAIXA 								,NIL},;
					{"D3_XSEQIT" 	,SC2->C2_XSEQIT									,NIL},;
					{"D3_EMISSAO" 	,SC2->C2_EMISSAO 								,NIL},;
					{"D3_PARCTOT"	,"T"  											,NIL} ;
				  }                                                     
		lMsErroAuto := .F.
		MSExecAuto({|x, y| mata250(x, y)},aMata250,3) 
		If lMsErroAuto
			lErro       := .T.
			cFileName   := "SD3OP"+cFilAnt+"_"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+AllTrim(SC2->C2_PRODUTO)+SC2->C2_LOCAL+"_"+strtran(time(),":","")
			MostraErro(cPathTmp, cFileName)
			cFileErr :=memoread(cPathTmp+cFileName)
			// -> Processa arquivo de retorno do erro do apontamento e verifica e gera logs de falta de saldos
			aAux   :=GetSB2Log(cPathTmp+cFileName,Nil,Nil,Nil,.T.)
			If Len(aAux) > 0
				For ny:=1 to Len(aAux)
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+aAux[ny,1]))
					If SB1->(Found()) .and. SB1->B1_TIPO <> "PI"						
						cAuxLog:="Falta saldo de estoque para o produto " + aAux[ny,01] + " - " + AllTrim(SB1->B1_DESC) + " e local "+aAux[ny,02]
						aadd(aRetSB2, {aAux[ny,1]+aAux[ny,2],"SB2","E",1,cAuxLog,.F.,"ALL",dDataProc,Val(aAux[ny,3]), "SALDO DE ESTOQUE", SC2->C2_PRODUTO, "", .T.})
						ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
					EndIf	
				Next ny
			EndIf					
			// -> Caso o erro seja de estoque não exibe a mensagem da rotina	
			If Len(aAux) <= 0
				cAuxLog	 :="Erro no apontamento da OP. Verifique o detalhe da ocorrencia." 
				cAuxLogD :=cFileErr			
				aadd(aRetApon,{SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc,SC2->C2_QUANT, "APONTAMENTO PRODUCAO (OBS)", SC2->C2_PRODUTO, cAuxLogD})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf
			fErase(cPathTmp+cFileName)
			//DisarmTransaction()
		Else
			// -> Atualiza dados de todos os movimentos da SD3
			SD3->(DbSetOrder(1))
			SD3->(DbGoTop())
			SD3->(DbSeek(SC2->C2_FILIAL+PADR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD3OP)))
			While !SD3->(Eof()) .and. SD3->D3_FILIAL+SD3->D3_OP == SC2->C2_FILIAL+PADR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD3OP) 
				If Empty(SD3->D3_XSEQVDA) .and. SC2->C2_PRODUTO == SC2->C2_PRODUTO
					RecLock("SD3",.F.)
					SD3->D3_XSEQVDA:="ALL"
					SD3->D3_XCAIXA :="ALL"
					SD3->D3_XSEQIT :="ALL"
					SD3->(MsUnlock())
				EndIf
				SD3->(DbSkip())
			EndDo			
				
			// -> Atualiza processo da OP
			ZWV->(DbGoTo(nRecProc))
			RecLock("ZWV",.F.)
			ZWV->ZWV_DESCP	:= "APONTAMENTO OP OBS:"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+":"+SC2->C2_PRODUTO+":"+StrZero(SC2->C2_QUANT,12,6)
			ZWV->ZWV_STATUS := "I"
			ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
			ZWV->(MsUnlock())
	
			// -> Posiciona no cadastro do produto
			SB1->(DbSetOrder(1))  
			SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))

			// -> Gera registro para baixa do PA/PI gerado pela Observação
			ZWV->(dbSetOrder(1))
			ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataProc)+":"+cCodProdVd+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":",nTamZWVPK)+"J"))
			If !ZWV->(Found())
				RecLock("ZWV",.T.)
				ZWV->ZWV_FILIAL := xFilial("ZWV")
				ZWV->ZWV_PK		:= DtoS(dDataProc)+":"+cCodProdVd+":"+SC2->C2_PRODUTO+":"+SC2->C2_LOCAL+":"
				ZWV->ZWV_DESCP	:= "PRODUTO OBS:"+SC2->C2_PRODUTO+":"+StrZero(SC2->C2_QUANT,14,6)
				ZWV->ZWV_SEQ	:= "J"
				ZWV->ZWV_STATUS := "P"
				ZWV->(MsUnlock())
			EndIf

			// -> Atualiza log
			cAuxLog	    :="Ok." 
			cAuxLogD    :="Apontamento da OP de observacao no. " + SC2->C2_NUM + ", item " + SC2->C2_ITEM + " e sequencia " + SC2->C2_SEQUEN + " finalizado com sucesso."
			aadd(aRetApon,{SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, SC2->C2_QUANT, "APONTAMENTO PRODUCAO (OBS)", SC2->C2_PRODUTO, cAuxLogD})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		EndIf
		//EndTran()	

	Next nx

	// -> Executa processo de baixas de produtos sem ordens de produção das observações
    cAuxLog	:="Baixando produtos por 'observacao'..."
    aadd(aRetApon,{"","SD3","L",0,cAuxLog,.F.,"",dDataProc, 0, "BAIXAS ESTOQUE", "", cAuxLog})
    Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)
	aAuxProcBX:={}
	nAux      :=Len(DtoS(dDataProc))   
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
	While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)			
	 	If ZWV->ZWV_SEQ $ "J" .and. ZWV->ZWV_STATUS == "P"			
	 		aadd(aAuxProcBX,ZWV->(Recno()))
	 	EndIf
	 	ZWV->(DbSkip())
	EndDo

	// -> Gera processo de baxas de produtos sem OP.
	For nx:=1 to Len(aAuxProcBX)

	 	// -> Posiciona no processo
	 	ZWV->(DbGoTo(aAuxProcBX[nx]))	

	 	// -> Pega informações da OP
	 	aAuxOP    :=StrToKarr(ZWV->ZWV_DESCP,":")
	 	cAuxItem  :=AllTrim(ZWV->ZWV_PK)
		aAuxItem  :=StrToKarr(cAuxItem,":")
		cxTime    := Time()
		cSeqVda   := "ALL"
		cCaixaVda := "ALL"
		cDataVda  := DtoS(dDataProc)
		cItemVda  := "ALL"
		cAuxOP    := IIF(Len(aAuxItem)>=5,aAuxItem[05],"")

	    cAuxLog	:="Produto " + AllTrim(aAuxOP[02]) + "."
    	aadd(aRetApon,{Space(nTamD3OP)+GetMV("MV_XTMBX",,"XXX")+cSeqVda+cCaixaVda+cDataVda+cItemVda,"SD3","L","SEQVDA",cAuxLog,.F.,"ALL",dDataProc, 0, "BAIXAS ESTOQUE", "", cAuxLog})
    	Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)

		// -> Verifica o centro de custo do restaurante
		DbSelectArea("ZA0")
		ZA0->(DbSetOrder(1))
		ZA0->(DbSeek(xFilial("ZA0")+cFilAnt))
		If ZA0->(Found())

			lMsErroAuto:=.F.
			aMata240   :={}
			// -> Verifica a quantidade
			If Val(aAuxOP[03]) > 0
				
				// -> Posiciona no Produto
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aAuxOP[02]))

				// -> Posiciona na odem de produção
				SC2->(DbSetOrder(1))
				SC2->(DbSeek(xFilial("SC2")+cAuxOP))
				If !SC2->(Found())
					cAuxOP:=""
				EndIf

				// -> Posiciona na TM
				DbSelectArea("SF5")
				SF5->(DbSetOrder(1))
				SF5->(DbSeek(xFilial("SF5")+GetMV("MV_XTMBX",,"XXX")))
				If SF5->(Found())													

					//BeginTran()
						
					aAdd( aMata240, { "D3_TM"     , SF5->F5_CODIGO ,Nil})
					aAdd( aMata240, { "D3_COD"    , SB1->B1_COD    ,Nil})
					aAdd( aMata240, { "D3_LOCAL"  , SB1->B1_LOCPAD ,Nil})
					If Empty(cAuxOP)
						aAdd( aMata240, { "D3_CC"     , ZA0->ZA0_CUSTO ,Nil})
					Else
						aAdd( aMata240, { "D3_OP"     , SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN ,Nil})
					EndIf	
					aAdd( aMata240, { "D3_QUANT"  , Val(aAuxOP[03]),Nil})
					aAdd( aMata240, { "D3_EMISSAO", StoD(cDataVda) ,Nil})
					Pergunte("MTA240")
					MSExecAuto({|x,y| mata240(x,y)},aMata240,3)		
						
					// -> Se deu erro gera os logs
					If lMsErroAuto
						lErro       := .T.
						cFileName   := "SD3BX"+cFilAnt+"_"+cSeqVda+cCaixaVda+cDataVda+cItemVda+AllTrim(SB1->B1_COD)+SB1->B1_LOCPAD+"_"+strtran(time(),":","")
						MostraErro(cPathTmp, cFileName)
						cFileErr :=memoread(cPathTmp+cFileName)
						// -> Processa arquivo de retorno do erro do apontamento e verifica e gera logs de falta de saldos
						aAux   :=GetSB2Log(cPathTmp+cFileName,SB1->B1_COD,SB1->B1_LOCPAD,aAuxOP[03],.F.)
						cAuxLog:=""
						If Len(aAux) > 0
							cAuxLog:="Falta saldo de estoque para o produto " + SB1->B1_COD + " - " + AllTrim(SB1->B1_DESC) + ", local " + SB1->B1_LOCPAD + " e quantidade "+AllTrim(Str(Val(aAuxOP[03])))+": "+aAux[01,04]
							aadd(aRetApon,{SB1->B1_COD+SB1->B1_LOCPAD,"SB2","E",1,cAuxLog,.F.,"ALL",dDataProc,Val(aAuxOP[03]), "SALDO DE ESTOQUE", SB1->B1_COD,""})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf	
						// -> Exibe og do processo, apenas se não houver erro de estoque
						If Len(aAux) <= 0
							cAuxLog	 :="Erro na baixa do estoque. Verifique o detalhe da ocorrencia." 
							cAuxLogD :=cFileErr			
						   	aadd(aRetApon,{Space(nTamD3OP)+GetMV("MV_XTMBX",,"XXX")+cSeqVda+cCaixaVda+cDataVda+cItemVda,"SD3","E","SEQVDA",cAuxLog,.F.,"ALL",dDataProc, Val(aAuxOP[03]), "BAIXAS ESTOQUE", SB1->B1_COD, cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf
						fErase(cPathTmp+cFileName)
						//DisarmTransaction()
					Else
						// -> Atualiza dados de todos os movimentos da SD3
						RecLock("SD3",.F.)
						SD3->D3_XSEQVDA:=cSeqVda
						SD3->D3_XCAIXA :=cCaixaVda
						SD3->D3_XSEQIT :=cItemVda
						SD3->(MsUnlock())
					EndIf

					// -> Atualiza processo da OP
					RecLock("ZWV",.F.)
					ZWV->ZWV_STATUS := "I"
					ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
					ZWV->(MsUnlock())

					//EndTran()

				Else
					
					lErro   :=.T.
	 				cAuxLog	:="Tipo de movimentacao nao encontrado no Protheus. [F5_CODIGO="+GetMV("MV_XTMBX",,"XXX")+"]"
					aadd(aRetApon,{GetMV("MV_XTMBX",,"XXX"),"SF5","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "CADASTROS", "", cAuxLog})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)				

				EndIf					

			Else
					
				lErro   :=.T.
	 			cAuxLog	:="Quantidade a ser baixada e invalida. [D3_QUANT="+aAuxOP[03]+"]"
				aadd(aRetApon,{Space(nTamD3OP)+GetMV("MV_XTMBX",,"XXX")+cSeqVda+cCaixaVda+cDataVda+cItemVda,"SD3","E","SEQVDA",cAuxLog,.F.,"ALL",dDataProc, 0, "BAIXAS ESTOQUE", "", cAuxLog})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)				

			EndIf					
					
		Else
					
			lErro   :=.T.
	 		cAuxLog	:="Centro de cuso nao encontrado no Protheus. [ZA0_FILCC="+cFilAnt+"]"
			aadd(aRetApon,{cFilAnt,"ZA0","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "CADASTROS", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)				

		EndIf					
									
	Next nx

	// -> Processa ordens de produção sem observações
	cAuxLog	:="Apontando OPs sem 'observacoes'..."
    aadd(aRetApon,{"","SD3","L",0,cAuxLog,.F.,"",dDataProc, 0, "APONTAMENTO PRODUCAO", "", ""})
    Conout(StrZero(nxIDThread,10)+": -> "+cAuxLog)

	axOPs     :={}
	aAuxProc  :={}
	aOPsAuxPI :={}
	aOPsAuxPA :={}
	nAux      :=Len(DtoS(dDataProc))   
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
	While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)			
		If ZWV->ZWV_SEQ $ "A" .and. ZWV->ZWV_STATUS == "I"			
			aadd(aAuxProc,ZWV->(Recno()))
		EndIf
		ZWV->(DbSkip())
	EndDo

	// -> Gera processo de apontamentos
	For nx:=1 to Len(aAuxProc)
		
		// -> Posiciona no processo
		ZWV->(DbGoTo(aAuxProc[nx]))			
		
		// -> Pega informações da OP
		aAuxOP  :=StrToKarr(ZWV->ZWV_DESCP,":")
		aAuxItem:=StrToKarr(AllTrim(ZWV->ZWV_PK),":")
		If Len(aAuxOP) == 2
		
			// -> Inclui processo de alteração de empenho
			ZWV->(DbSetOrder(1))
        	ZWV->(DbSeek(xFilial("ZWV")+PADR(aAuxItem[01]+":"+aAuxItem[02]+":"+aAuxItem[03]+":"+aAuxOP[02],nTamZWVPK)+"H"))
	        If !ZWV->(Found())
    	        RecLock("ZWV",.T.)
		        ZWV->ZWV_FILIAL := xFilial("ZWV")
				ZWV->ZWV_PK		:= aAuxItem[01]+":"+aAuxItem[02]+":"+aAuxItem[03]+":"+aAuxOP[02]
				ZWV->ZWV_DESCP	:= "APONTAMENTO OP"
				ZWV->ZWV_SEQ	:= "H"
				ZWV->ZWV_STATUS := "P"
				ZWV->(MsUnlock())
			EndIf	
			
			// -> Verifica se a opestá pendente de paontamento	
			If ZWV->ZWV_STATUS == "P"
				lEncontrou:=.T.
				aadd(axOPs,{AllTrim(aAuxOP[02]),.F.,ZWV->(Recno())})				
			EndIf
		
		Else
			
			lErro   :=.T.
			cAuxLog	:="Erro ao carregar os dados para apontamento da OP. Verifique o conteudo do campo ZWV_PK da tabela de processos de vendas."
			cAuxLogD:="Verifique o conteudo do campo ZWV_PK da tabela de processos de vendas. [ZWV_FILIAL="+ZWV->ZWV_FILIAL+", ZWV_PK=" + AllTrim(ZWV->ZWV_PK) + " e ZWV->ZWV_STATUS=" + ZWV->ZWV_STATUS + "]" 
			aadd(aRetApon,{ZWV->ZWV_PK+ZWV->ZWV_STATUS,"ZWV","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO", "", cAuxLogD})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)				
		
		EndIf	
			
	Next nx

	//-> Ordena ordens de produção para fazer primeiro o apontamento do tipo PI
	For nx:=1 to Len(axOPs)

		// -> Posiciona na ordem de produção		
		SC2->(DbSetOrder(1))
		If SC2->(DbSeek(xFilial("SC2")+axOPs[nx,01]))

			// -> Posiciona no cadastro do produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)) 

			// -> Armazena dados do PI / PA
			If SB1->B1_TIPO $ "PI" .and. SB1->B1_FANTASM <> "S"
				AADD(aOPsAuxPI,{axOPs[nx,01],axOPs[nx,02],SB1->B1_TIPO,axOPs[nx,03]})
			Else
				AADD(aOPsAuxPA,{axOPs[nx,01],axOPs[nx,02],SB1->B1_TIPO,axOPs[nx,03]})
			Endif

		EndIf

	Next nx
	

	// -> Atualiza ordens de producao priorizando os apontamentos de produtos PI
	axOPs:={}
	For nx:=1 to Len(aOPsAuxPI)
		AADD(axOPs,{aOPsAuxPI[nx,01],aOPsAuxPI[nx,02],aOPsAuxPI[nx,03],aOPsAuxPI[nx,04],.F.})
	Next nx

	// -> Atualiza ordens de producao dos demais apontamentos
	For nx:=1 to Len(aOPsAuxPA)
		AADD(axOPs,{aOPsAuxPA[nx,01],aOPsAuxPA[nx,02],aOPsAuxPA[nx,03],aOPsAuxPA[nx,04],.F.})
	Next nx

	nAuxMod		:=nModulo
	nModulo		:=4
	lEncontrou  :=.F.
	lErro       :=.F.
	For nx:=1 to Len(axOPs)

		lMsErroAuto := .F.
		lEncontrou  := .T.
		cxTime      := Time()

		ZWV->(DbGoTo(axOPs[nx,04]))

		// -> Posiciona na ordem de produção
		SC2->(DbSetOrder(1))
		If !SC2->(DbSeek(xFilial("SC2")+axOPs[nx,01]))			
			lErro   :=.T.
			cAuxLogD:="OP no. " + axOPs[nx,01] + " nao encontrada."
			aadd(aRetApon,{axOPs[nx,01],"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Loop
		EndIf

		// -> Verifica se a ordem de produção já foi apontada, se foi atualiza como integrada
		If SC2->C2_QUJE > 0		
			RecLock("ZWV",.F.)
			ZWV->ZWV_DESCP	:= "APONTAMENTO OP"
			ZWV->ZWV_STATUS := "I"
			ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
			ZWV->(MsUnlock())
			cAuxLog	:="Ok." 
			aadd(aRetApon,{axOPs[nx,01],"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, SC2->C2_QUANT, "APONTAMENTO PRODUCAO", SC2->C2_PRODUTO, cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog) 
			Loop
		EndIf	

		//BeginTran()
		
		cAuxLog	:="OP " + SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN 
		cAuxLogD:="Apontando OP no. " + SC2->C2_NUM + ", item " + SC2->C2_ITEM + " e sequencia " + SC2->C2_SEQUEN
		aadd(aRetApon,{axOPs[nx,01],"SC2","L",1,cAuxLog,.F.,"ALL",dDataProc, SC2->C2_QUANT, "APONTAMENTO PRODUCAO", SC2->C2_PRODUTO, cAuxLogD})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog) 

		// -> Marca OP para encerramento (fechamento total)
		lEncerra	:=.T.
		axOPs[nx,02]:=lEncerra			
			
		aMata250	:={;               
						{"D3_OP" 		,PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD3OP)	,NIL},;
						{"D3_TM" 		,GetMV("MV_TMPAD" ,,"010")								,NIL},;
						{"D3_COD" 		,SC2->C2_PRODUTO 										,NIL},;
						{"D3_QUANT" 	,SC2->C2_QUANT 											,NIL},;
						{"D3_XSEQVDA" 	,SC2->C2_XSEQVDA 										,NIL},;
						{"D3_XCAIXA" 	,SC2->C2_XCAIXA 										,NIL},;
						{"D3_XSEQIT" 	,SC2->C2_XSEQIT											,NIL},;
						{"D3_EMISSAO" 	,SC2->C2_EMISSAO 										,NIL},;
						{"D3_PARCTOT"	,IIF(lEncerra,"T","P")	 								,NIL} ;
					}                                                     
		lMsErroAuto := .F.
		MSExecAuto({|x, y| mata250(x, y)},aMata250,3) 
		If lMsErroAuto
			lErro       := .T.
			axOPs[nx,05]:= .T.   
			cFileName   := "SD3OP"+cFilAnt+"_"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+AllTrim(SC2->C2_PRODUTO)+SC2->C2_LOCAL+"_"+strtran(time(),":","")
			MostraErro(cPathTmp, cFileName)
			cFileErr :=memoread(cPathTmp+cFileName)
			// -> Processa arquivo de retorno do erro do apontamento e verifica e gera logs de falta de saldos
			aAux   :=GetSB2Log(cPathTmp+cFileName,Nil,Nil,Nil,.T.)
			cAuxLog:=""
			If Len(aAux) > 0					
				For ny:=1 to Len(aAux)
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+aAux[ny,1]))
					If SB1->(Found()) .and. SB1->B1_TIPO <> "PI"						
						cAuxLog:="Falta saldo de estoque para o produto " + aAux[ny,01] + " - " + AllTrim(SB1->B1_DESC) + " local "+aAux[ny,02]
						aadd(aRetSB2,{aAux[ny,1]+aAux[ny,2],"SB2","E",1,cAuxLog,.F.,"ALL",dDataProc,Val(aAux[ny,3]), "SALDO DE ESTOQUE", SC2->C2_PRODUTO, "", .T.})
						ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
					EndIf	
				Next ny
			EndIf	
			// -> Se hover erro de estoque, não exibe o log
			If Len(aAux)
				cAuxLog	 :="Erro no apontamento da OP. Verifique o detalhe da ocorrencia." 
				cAuxLogD :=cFileErr			
				aadd(aRetApon,{SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SC2","E",1,cAuxLog,.F.,"ALL",dDataProc, SC2->C2_QUANT, "APONTAMENTO PRODUCAO", SC2->C2_PRODUTO, cAuxLogD})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf
			fErase(cPathTmp+cFileName)
			//DisarmTransaction()
		Else
			// -> Atualiza dados de todos os movimentos da SD3
			SD3->(DbSetOrder(1))
			SD3->(DbGoTop())
			SD3->(DbSeek(SC2->C2_FILIAL+PADR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD3OP)))
			While !SD3->(Eof()) .and. SD3->D3_FILIAL+SD3->D3_OP == SC2->C2_FILIAL+PADR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,nTamD3OP) 
				If Empty(SD3->D3_XSEQVDA) .and. SC2->C2_PRODUTO == SC2->C2_PRODUTO
					RecLock("SD3",.F.)
					SD3->D3_XSEQVDA:=SC2->C2_XSEQVDA
					SD3->D3_XCAIXA :=SC2->C2_XCAIXA
					SD3->D3_XSEQIT :=SC2->C2_XSEQIT
					SD3->(MsUnlock())
				EndIf
				SD3->(DbSkip())
			EndDo			
			// -> Atualiza processo da OP
			RecLock("ZWV",.F.)
			ZWV->ZWV_DESCP	:= "APONTAMENTO OP"
			ZWV->ZWV_STATUS := "I"
			ZWV->ZWV_ELTIME := ELAPTIME(cxTime,Time())
			ZWV->(MsUnlock())
			// -> Atualiza log
			axOPs[nx,05]:= .T.   
		EndIf

		//EndTran()	
 
 	Next nx

	// -> Verifica se existem empenhos pendentes. Caso existam, exibe erro
    aAux:={}
	nAux:=Len(DtoS(dDataProc))
	ZWV->(DbSetOrder(1))
    ZWV->(DbSeek(xFilial("ZWV")+DtoS(dDataProc)))
    While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. SubStr(ZWV->ZWV_PK,1,nAux) == DtoS(dDataProc)
		aAuxOP  :=StrToKarr(ZWV->ZWV_PK,":")
		// -> Se for apontamento
		If ZWV->ZWV_SEQ $ "H/I/J" .and. ZWV->ZWV_STATUS == "P" 
	 		lErro:=.T.
			cAuxLog  :="Ha pendencia de apontamento da orden de producao: ZWV_PK =  " + AllTrim(ZWV->ZWV_PK) + "."
			aadd(aRetApon,{AllTrim(ZWV->ZWV_PK),"ZWV","E",1,cAuxLog,.F.,"ALL",dDataProc, 0, "APONTAMENTO PRODUCAO", "", cAuxLog})
	 		ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
		EndIf	
		ZWV->(DbSkip())
	EndDo	

	lErro:=IIF(lErro,.F.,.T.)
	
Return(lErro)  



/*
+------------------+---------------------------------------------------------+
!Nome              ! FAT3009                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Gera titulos a receber                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Alan Lunardi                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/06/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function FAT3009(aRet3009,oEventLog,nxIDThread)
Local cPathTmp  := "\temp\"
Local cFileName := ""
Local lErro	   	:= .F. 
Local nAux	   	:= 0
Local nModAnt  	:= nModulo
Local cAuxLog  	:= ""
Local cAuxLogD  := ""
Local dEmisSE1 	:= Z01->Z01_DATA
Local aVctoSE1 	:= {}
Local aDadosSE1	:= {}
Local aBaixa	:= {}
Local nl       	:= 0 
Local nTamParc  := TamSX3("E1_PARCELA")[1]
Local aBcAgCo   := StrToKarr(GetMV("MV_CXLOJA",,""), '/')
Local cBcLoja	:= aBcAgCo[1]+Space(TamSX3("A6_COD")[1]    -Len(aBcAgCo[1]))
Local cAgLoja	:= aBcAgCo[2]+Space(TamSX3("A6_AGENCIA")[1]-Len(aBcAgCo[2]))
Local cCCLoja	:= aBcAgCo[3]+Space(TamSX3("A6_NUMCON")[1] -Len(aBcAgCo[3]))
Local aBcAgCoP  := StrToKarr(GetMV("MV_XBCCTP",,""), '/')
Local cBcLojaP	:= aBcAgCoP[1]+Space(TamSX3("A6_COD")[1]    -Len(aBcAgCoP[1]))
Local cAgLojaP	:= aBcAgCoP[2]+Space(TamSX3("A6_AGENCIA")[1]-Len(aBcAgCoP[2]))
Local cCCLojaP	:= aBcAgCoP[3]+Space(TamSX3("A6_NUMCON")[1] -Len(aBcAgCoP[3]))
Local cTipoSE1  := ""
Local nTamTipo  := TamSX3("E1_TIPO")[1]
Local cAux		:= ""
Local cCodCli   := ""
Local cCodLCli  := ""
Local cNomCli   := ""
Local cCodAdm   := ""
Local cCodLAdm  := ""
Local cNomAdm   := ""
Local nTaxaAdm	:= 0
Local cNatTxAdm := ""
Local cNatSE1	:= ""
Local cEmpZ10   := ""
Local cFilZ10   := ""
Local nTamDoc   := TamSX3('E1_NUM')[1]
Local nParc     := 0
Local cFunNamAnt:= FunName()
Local cXVNDTP	:= ""
Local nTamZWV_PK:= TamSx3("ZWV_PK")[1]
Local nRecProc  := 0
Local cxTime    := Time()
Local nRecSE1   := 0
Local cTipoCart := "CA/CM/CC/CD"
Local dDataAnt  := dDataBase
Private lMsErroAuto	:= .F.
   	
	SetFunName("FINA040")
	   			
	// -> Seleciona as tabelas utilizadas no processo
	DbSelectArea("SA1")
	DbSelectArea("SA6")
	DbSelectArea("SAE")
	DbSelectArea("SE4")
	DbSelectArea("SED")
	DbSelectArea("Z10")
	DbSelectArea("Z03")
	DbSelectArea("SE1")
	DbSelectArea("SE5")
	DbSelectArea("FKF")

	cCodCli   := ""
	cCodLCli  := ""
	cNomCli   := ""
	cCodAdm   := ""
	cCodLAdm  := ""
	cNomAdm   := ""
	cNatSE1	  := ""

	// -> Pesquisa cliente e, caso nao exista pega o cliente padrão		
	SA1->(DbSetOrder(3))
	SA1->(DbSeek(xFilial("SA1")+Z01->Z01_CGC))		
	If !SA1->(Found()) .or. Empty(Z01->Z01_CGC)
		// -> Verifica se o cliente padrão está cadastrado
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+cMVCLIPAD+cMVLOJAPAD))
		If !SA1->(Found())
			lErro   :=.T.
			cAuxLog	:="Cliente "+cMVCLIPAD+" e loja "+cMVLOJAPAD+" nao encontrado na tabela SA1"
			cAuxLogD:="Cliente "+cMVCLIPAD+" e loja "+cMVLOJAPAD+" nao encontrado na tabela SA1. Verifique os parametros MV_CLIPAD e MV_LOJAPAD."
			aadd(aRet3009,{cMVCLIPAD+cMVLOJAPAD,"SA1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLogD})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		Else
			cCodCli   := SA1->A1_COD
			cCodLCli  := SA1->A1_LOJA
			cNomCli   := SA1->A1_NOME
			cCodAdm   := ""
			cCodLAdm  := ""
			cNomAdm   := ""	
		EndIf	
	Else
		cCodCli   := SA1->A1_COD
		cCodLCli  := SA1->A1_LOJA
		cNomCli   := SA1->A1_NOME
		cCodAdm   := ""
		cCodLAdm  := ""
		cNomAdm   := ""	
	EndIf
	
	// -> Pesquisa banco da 'unidade' 
	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6")+cBcLoja+cAgLoja+cCCLoja))
		lErro   :=.T.
		cAuxLog	:="Banco da unidade de negocio: A6_COD="+IIF(Empty(cBcLoja),"Vazio",cBcLoja)+", A6_AGENCIA="+IIF(Empty(cAgLoja),"Vazio",cAgLoja)+" e A6_NUMCON="+IIF(Empty(cCCLoja),"Vazio",cCCLoja)
		cAuxLogD:="Banco da unidade de negocio nao encontrado na tabela SA6. Verifique os dados de banco, agencia e conta: A6_COD="+IIF(Empty(cBcLoja),"Vazio",cBcLoja)+", A6_AGENCIA="+IIF(Empty(cAgLoja),"Vazio",cAgLoja)+" e A6_NUMCON="+IIF(Empty(cCCLoja),"Vazio",cCCLoja)
		aadd(aRet3009,{cBcLoja+cAgLoja+cCCLoja   ,"SA6","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,dDataBase, 0, "CADASTROS", "", cAuxLogD})		
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
	Else
		cBcLoja:=SA6->A6_COD
		cAgLoja:=SA6->A6_AGENCIA
		cCCLoja:=SA6->A6_NUMCON	
	EndIf
	
	// -> Pesquisa banco para condição "vale presente" 
	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6")+cBcLojaP+cAgLojaP+cCCLojaP))
		lErro   :=.T.
		cAuxLog	:="Banco 'cartao vale presente' nao encontrado: A6_COD="+IIF(Empty(cBcLojaP),"Vazio",cBcLojaP)+", A6_AGENCIA="+IIF(Empty(cAgLojaP),"Vazio",cAgLojaP)+" e A6_NUMCON="+IIF(Empty(cCCLojaP),"Vazio",cCCLojaP)
		cAuxLogD:="Banco 'cartao vale presente' nao encontrado na tabela SA6. Verifique os dados de banco, agencia e conta: A6_COD="+IIF(Empty(cBcLojaP),"Vazio",cBcLojaP)+", A6_AGENCIA="+IIF(Empty(cAgLojaP),"Vazio",cAgLojaP)+" e A6_NUMCON="+IIF(Empty(cCCLojaP),"Vazio",cCCLojaP)
		aadd(aRet3009,{cBcLojaP+cAgLojaP+cCCLojaP,"SA6","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,dDataBase, 0, "CADASTROS", "", cAuxLogD})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
	Else
		cBcLojaP:=SA6->A6_COD
		cAgLojaP:=SA6->A6_AGENCIA
		cCCLojaP:=SA6->A6_NUMCON
	EndIf

	// -> Se o retorno for falso, sai da função
	If lErro
		nModulo :=nModAnt
		cAuxLog	:="Erro nos dados financeiros. Verifique as ocorrencias registradas no log."
		cAuxLogD:="Houve erros no processamento dos recebimentos para a venda con sequencia " + Z01->Z01_SEQVDA + " e caixa " + Z01->Z01_CAIXA
		aadd(aRet3009,{Z01->Z01_CAIXA+cxDocSF2,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		Return(.F.) 
	EndIf
	
	// -> Verifica se há títulos pendentes para o processo 
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)+"O"))
	If !ZWV->(Found())
        RecLock("ZWV",.T.)
	    ZWV->ZWV_FILIAL := xFilial("ZWV")
		ZWV->ZWV_PK		:= PadR(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG),nTamZWV_PK)
		ZWV->ZWV_DESCP	:= "TITULOS FINANCEIROS"
		ZWV->ZWV_SEQ	:= "O"
		ZWV->ZWV_STATUS := "P"
		ZWV->(MsUnlock())
	EndIf	

	// -> Verifica se o documento fiscal já foi processado
	If ZWV->ZWV_STATUS == "I"
		cAuxLog	:="Ok."
		aadd(aRet3009,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z03","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLog})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		Return(.T.) 
	EndIf	
	nRecProc:=ZWV->(Recno())

	nModulo:=6
	// -> Posiciona na condição de recebimento da venda
	Z03->(DbSetOrder(3))
	Z03->(DbSeek(Z01->Z01_FILIAL+Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA)))
	While !Z03->(Eof()) .and. Z03->Z03_FILIAL == Z01->Z01_FILIAL .and. Z03->Z03_SEQVDA == Z01->Z01_SEQVDA .and. Z03->Z03_CAIXA == Z01->Z01_CAIXA .and. DtoS(Z03->Z03_DATA) == DtoS(Z01->Z01_DATA)

		nTaxaAdm  :=0
		cNatTxAdm :=""
		cEmpZ10   := IIF(Empty(xFilial("Z10")),Space(TamSx3("Z03_CDEMP")[1]),Z03->Z03_CDEMP)
		cFilZ10   := IIF(Empty(xFilial("Z10")),Space(TamSx3("Z03_CDFIL")[1]) ,Z03->Z03_CDFIL)

		// -> Verifica condição de pagamento - Protheus
		SE4->(DbOrderNickName("E4CODEXT"))
		If !SE4->(DbSeek(xFilial("SE4")+Z03->Z03_COND))			
			lErro   := .T.
			cAuxLog :="A Condicao de pagamento "+Z03->Z03_COND+" nao está vinculada ao Teknisa. (SE4)"			
			aadd(aRet3009,{cBcLojaP+cAgLojaP+cCCLojaP,"SA6","E","E4CODEXT",cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Z03->(DbSkip())
			Loop
		ElseIf Empty(SE4->E4_XFORMA)
			// -> Verifica se existe a forma de pagamento cadastrada
			lErro   :=.T.
			cAuxLog :="A forma de recebimento "+SE4->E4_CODIGO+" nao foi informada no campo E4_XFORMA."			
			aadd(aRet3009,{SE4->E4_CODIGO,"SE4","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Z03->(DbSkip())
			Loop
		Else
			// -> Verifica se existe a natureza cadastrada para a condicao de pagamento
			SED->(DbSetOrder(1))
			If !SED->(DbSeek(xFilial("SED")+SE4->E4_XNATVDA))
				lErro   := .T.
				cAuxLog :="A natureza financeira "+SE4->E4_XNATVDA+" cadastrada na condicao de recebimento nao foi encontrada na tabela SED."			
				aadd(aRet3009,{SE4->E4_XNATVDA,"SED","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLog})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
				Z03->(DbSkip())
				Loop
			Else
				cNatSE1:=SED->ED_CODIGO
			EndIf
			// -> Verifica administradora de cartao
			If UPPER(SE4->E4_XFORMA) $ cTipoCart	
				// -> Pesquisa administradora
				SAE->(DbOrderNickName("AEXCOD"))
				If !SAE->(DbSeek(xFilial("SE4")+SE4->E4_CODIGO))
					lErro   := .T.
					cAuxLog	:="Condicao de recebimento "+SE4->E4_CODIGO+" nao relacionada a administradora financeira."
					cAuxLogD:="Nao ha condicao de recebimento relacionada na administradora financeira: AE_XCOD="+SE4->E4_CODIGO
					aadd(aRet3009,{SE4->E4_XNATVDA,"SAE","E","AEXCOD",cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CADASTROS", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
					Z03->(DbSkip())
					Loop
				Else
					// -> Posiciona no cliente da administradora
					cAux:="01"
					SA1->(DbSetOrder(1))					
					SA1->(DbSeek(xFilial("SA1")+SAE->AE_CODCLI))
					If !SA1->(Found())
						lErro   := .T.
						cAuxLog	:="Cliente "+SAE->AE_CODCLI+" relacionado a administradora nao cadastrada."
						cAuxLogD:="O cliente "+SAE->AE_CODCLI+" e loja "+cAux+" relacionado a administradora financeira nao foi encontrado na tabela SA1."
						aadd(aRet3009,{SAE->AE_CODCLI+cAux,"SA1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
						Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
						Z03->(DbSkip())
						Loop
					Else
						cCodAdm   := SA1->A1_COD
						cCodLAdm  := SA1->A1_LOJA
						cNomAdm   := SA1->A1_NOME
						nTaxaAdm  := SAE->AE_TAXA
						cNatTxAdm := SAE->AE_XNTXADM						
						// -> Verifica se ataxa de administracao estiver zerada, gera aviso
						If nTaxaAdm <= 0
							cAuxLog	:="Taxa da aministradora zerada."
							cAuxLogD:="A taxa de administracao está zerada para a administradora financeira: AE_COD="+SAE->AE_COD
							aadd(aRet3009,{SAE->AE_CODCLI,"SAE","W",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
						Else
							// -> Verifica se existe a natureza cadastrada para a taxa de administracao
							SED->(DbSetOrder(1))
							If !SED->(DbSeek(xFilial("SED")+cNatTxAdm))
								lErro   := .T.
								cAuxLog	:="Natureza da taxa da aministradora invalida."
								cAuxLogD:="A natureza da taxa de administracao para a administradora financeira é invalida: AE_XNTXADM="+SAE->AE_XNTXADM
								aadd(aRet3009,{SAE->AE_XNTXADM,"SAE","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})								
								Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
								Z03->(DbSkip())
								Loop
							EndIf	
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf	
				
	    aVctoSE1:={}
		dEmisSE1:=IIF(Z03->Z03_DATA < dEmisSE1,dEmisSE1,Z03->Z03_DATA) 
	    
		// -> Valida parametros de contabilização dos títulos a receber
		Pergunte("FIN040",.F.)
		If MV_PAR02 <> 1  .or. MV_PAR03 <> 1
			lErro   := .T.
			cAuxLog	:="Parametros de contabilizacao on-line invalidos. Favor verificar os parametros MV_PAR02 e MV_PAR03 no grupo de perguntas FIN040 na tabela SX1."
			cAuxLogD:="Os parametros MV_PAR02 e MV_PAR03 nao estao configurados para contabilizacao on-line dos titulos financeiros. Favor verificar no grupo de pergundas FIN040 no configurador ou na rotina FINA040 em parametros (F12)." 
			aadd(aRet3009,{Z01->Z01_CAIXA+cxDocSF2,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			Z03->(DbSkip())
			Loop
		EndIf

		// -> Calcula vencimento e valores da condicao de pagamento    
		If !lErro
			aVctoSE1 := CONDICAO(Z03->Z03_VRREC,SE4->E4_CODIGO,,dEmisSE1)
		EndIf	
	    
		nParcs := Len(aVctoSE1)
		nValParc := 0
		nValAux  := 0
		
		//Begin Transaction 
	    	
			// -> Atualiza consicao de pagamento
	    	For nl:=1 to Len(aVctoSE1) 
	    	
				nParc :=nParc+1 
				aVenc := {}	
			
				If nl == Len(aVctoSE1)
					nValParc := Z03->Z03_VRREC - nValAux 
				Else	
					nValParc := Z03->Z03_VRREC / nParcs
					nValAux += nValParc
				EndIf 
				
				aadd(aVenc,{nValParc,aVctoSE1[nl,1]}) 	    	
						
				// -> Gera títulos a receber - Recebimento a vista
	    		If UPPER(SE4->E4_XFORMA) $ "AV"
	    			nRecSE1 :=-1
	    			cTipoSE1:="R$"
		    		cTipoSE1:=PadR(cTipoSE1,nTamTipo)
					cAuxLog	:="Incluindo titulo "+Z01->Z01_CAIXA+":"+cxDocSF2+":"+StrZero(nParc,nTamParc)+":"+cTipoSE1"
					cAuxLogD:="Incluindo titulo "+cxDocSF2+", prefixo " + Z01->Z01_CAIXA + " e parcela "+StrZero(nParc,nTamParc)
					aadd(aRet3009,{Z01->Z01_CAIXA+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

			    	aDadosSE1 :={ 	{ "E1_PREFIXO"  , cxSerie        													, NIL },;
		    						{ "E1_NUM"      , cxDocSF2												           	, NIL },;
		    						{ "E1_PARCELA"  , StrZero(nParc,nTamParc)              								, NIL },;
		    						{ "E1_TIPO"     , cTipoSE1              											, NIL },;
		    						{ "E1_NATUREZ"  , cNatSE1			   												, NIL },;
		    						{ "E1_CLIENTE"  , cCodCli	         											   	, NIL },;
		    						{ "E1_LOJA"     , cCodLCli          												, NIL },;
			    					{ "E1_XCLIENT"  , cCodCli       	   											   	, NIL },;
			    					{ "E1_XLOJA"    , cCodLCli		          											, NIL },;
			    					{ "E1_XNOME"    , cNomCli  		        											, NIL },;
		    						{ "E1_EMISSAO"  , dEmisSE1															, NIL },;
		    						{ "E1_VENCTO"   , aVenc[nl,2]														, NIL },;
		    						{ "E1_VENCREA"  , aVenc[nl,2]														, NIL },;
									{ "E1_XDTCAIX"  , Z03->Z03_DTABER													, NIL },;
			    					{ "E1_VALOR"    , aVenc[nl,1]  		  												, NIL },;
			    					{ "E1_HIST"     , "Venda a vista"													, NIL },;
		    						{ "E1_NUMNOTA"  , cxDocSF2															, NIL },;
		    						{ "E1_SERIE"    , cxSerie       													, NIL },;
		    						{ "E1_ORIGEM"   , "MATA920"															, NIL },;
		    						{ "E1_XSEQVDA"  , Z03->Z03_SEQVDA													, NIL },;
		    						{ "E1_XCAIXA"   , Z03->Z03_CAIXA   													, NIL },;
			    					{ "E1_XCODEXT"  , Z03->Z03_COND   											        , NIL },;
                                    { "E1_XDESCAD"  , SE4->E4_DESCRI												    , NIL },;
			    					{ "E1_XHORAV"   , Z03->Z03_HRVDA													, NIL },;
			    					{ "E1_XCDCLI"   , Z01->Z01_CDCLI													, NIL },;
			    					{ "E1_XCDCONS"  , Z01->Z01_CDCONS													, NIL },;
			    					{ "E1_XCONC"    , "N"																, NIL } ;
		    					}

			    	// -> Verifica se o título já foi incluído, se não foi inclui
					SE1->(DbSetOrder(1))
					SE1->(DbSeek(xFilial("SE1")+cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1))
					If !SE1->(Found())
						// -> Inclui recebiemnto a 'vista'
				    	lMsErroAuto:=.F.
						dDataBase  :=Z01->Z01_DATA
				    	MsExecAuto({|x,y| FINA040(x,y)},aDadosSE1,3)
						dDataBase  :=dDataAnt
		    			If lMsErroAuto
		    				lErro	 :=.T.
							cFileName:= "se1_"+cFilAnt+"_"+cxSerie+"_"+AllTrim(cxDocSF2)+"_"+strtran(time(),":","")
							MostraErro(cPathTmp, cFileName)
							cFileErr:=memoread(cPathTmp+cFileName)
							cAuxLog	:="Erro na inclusao do titulo. Verifique o detalhamento da ocorrencia."
							cAuxLogD:=cFileErr		
							fErase(cPathTmp+cFileName)			
							aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf
					EndIf	
			
				// -> Vendas com cartao 	
		    	ElseIf UPPER(SE4->E4_XFORMA) $ cTipoCart
		    		cTipoSE1:=PadR(SAE->AE_TIPO,nTamTipo)
					nRecSE1:=-1
					
					If ALLTRIM(SAE->AE_XTEFPO) == "POS"
						cXVNDTP := "P"
					EndIf 	

					cAuxLog	:="Incluindo titulo "+cxSerie+":"+cxDocSF2+":"+StrZero(nParc,nTamParc)+":"+cTipoSE1"
					cAuxLogD:="Incluindo titulo "+cxDocSF2+", prefixo " + cxSerie + " e parcela "+StrZero(nParc,nTamParc)
					aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

					aDadosSE1 :={ 	{ "E1_PREFIXO"  , cxSerie       													, NIL },;
			    					{ "E1_NUM"      , cxDocSF2												           	, NIL },;
		    						{ "E1_PARCELA"  , StrZero(nParc,nTamParc)              								, NIL },;
		    						{ "E1_TIPO"     , cTipoSE1              											, NIL },;
		    						{ "E1_NATUREZ"  , cNatSE1			   												, NIL },;
		    						{ "E1_CLIENTE"  , cCodAdm	         											   	, NIL },;
		    						{ "E1_LOJA"     , cCodLAdm          												, NIL },;
		    						{ "E1_XCLIENT"  , cCodCli       	   											   	, NIL },;
			    					{ "E1_XLOJA"    , cCodLCli		          											, NIL },;
			    					{ "E1_XNOME"    , cNomCli  		        											, NIL },;
			    					{ "E1_EMISSAO"  , dEmisSE1															, NIL },;
		    						{ "E1_VENCTO"   , aVenc[nl,2]														, NIL },;
		    						{ "E1_VENCREA"  , aVenc[nl,2]														, NIL },;
									{ "E1_XDTCAIX"  , Z03->Z03_DTABER													, NIL },;
		    						{ "E1_VALOR"    , aVenc[nl,1]  		  												, NIL },;
		    						{ "E1_HIST"     , "Venda cartao :" + SAE->AE_TIPO 									, NIL },;
		    						{ "E1_NUMNOTA"  , cxDocSF2															, NIL },;
			    					{ "E1_SERIE"    , cxSerie       													, NIL },;
			    					{ "E1_ORIGEM"   , "MATA920"															, NIL },;
			    					{ "E1_XSEQVDA"  , Z03->Z03_SEQVDA													, NIL },;
		    						{ "E1_XCAIXA"   , Z03->Z03_CAIXA   													, NIL },;
		    						{ "E1_XCODEXT"  , Z03->Z03_COND   											        , NIL },;
									{ "E1_XADMIN"   , SAE->AE_COD														, NIL },;
									{ "E1_XDESCAD"  , SAE->AE_DESC														, NIL },;
		    						{ "E1_DOCTEF"   , Z03->Z03_NSU														, NIL },;
									{ "E1_NSUTEF"   , IIF(!Empty(Z03->Z03_NSU),STRZERO(Val(Z03->Z03_NSU),12),'')		, NIL },;
			    					{ "E1_XNUMCAR"  , Z03->Z03_NCART													, NIL },;
			    					{ "E1_XHORAV"   , Z03->Z03_HRVDA													, NIL },;
									{ "E1_XVNDTP"   , cXVNDTP															, NIL },;
			    					{ "E1_XCDCLI"   , Z01->Z01_CDCLI													, NIL },;
			    					{ "E1_XCDCONS"  , Z01->Z01_CDCONS													, NIL },;
		    						{ "E1_XCONC"    , "N"																, NIL } ;
		    					}
		    				
			    	// -> Verifica se o título já foi incluído, se não foi inclui
					SE1->(DbSetOrder(1))
					SE1->(DbSeek(xFilial("SE1")+cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1))
					If !SE1->(Found())
				    	// -> Inclui recebiemnto com cartao
				    	dDataBase  :=Z01->Z01_DATA
						lMsErroAuto:=.F.
				    	MsExecAuto({|x,y| FINA040(x,y)},aDadosSE1,3)
						dDataBase  :=dDataAnt
		    			If lMsErroAuto
		    				lErro	 :=.T.
							cFileName:= "se1_"+cFilAnt+"_"+cxSerie+"_"+AllTrim(cxDocSF2)+"_"+strtran(time(),":","")
							MostraErro(cPathTmp, cFileName)
							cFileErr:=memoread(cPathTmp+cFileName)
							cAuxLog	:="Erro na inclusao do titulo. Verifique o detalhamento da ocorrencia."
							cAuxLogD:=cFileErr
							fErase(cPathTmp+cFileName)
							aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
							//DisarmTransaction()
						Else
							nRecSE1:=SE1->(Recno())
						EndIf
					Else
						nRecSE1:=SE1->(Recno())
					EndIf

					cXVNDTP := ""		
			
				// -> Vendas para "eventos", "consumidor" e "vale presente" 	
		    	ElseIf UPPER(SE4->E4_XFORMA) $ "EV/VC/VP"
	    			cTipoSE1:="DP"
	    			cTipoSE1:=PadR(cTipoSE1,nTamTipo)
					nRecSE1 := -1

					cAuxLog	:="Incluindo titulo "+cxSerie+":"+cxDocSF2+":"+StrZero(nParc,nTamParc)+":"+cTipoSE1"
					cAuxLogD:="Incluindo titulo "+cxDocSF2+", prefixo " + cxSerie + " e parcela "+StrZero(nParc,nTamParc)
					aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

			    	aDadosSE1 :={ 	{ "E1_PREFIXO"  , cxSerie															, NIL },;
			    					{ "E1_NUM"      , cxDocSF2												           	, NIL },;
			    					{ "E1_PARCELA"  , StrZero(nParc,nTamParc)              								, NIL },;
		    						{ "E1_TIPO"     , cTipoSE1              											, NIL },;
		    						{ "E1_NATUREZ"  , cNatSE1			   												, NIL },;
		    						{ "E1_CLIENTE"  , cCodCli	         											   	, NIL },;
		    						{ "E1_LOJA"     , cCodLCli          												, NIL },;
		    						{ "E1_XCLIENT"  , cCodCli       	   											   	, NIL },;
			    					{ "E1_XLOJA"    , cCodLCli		          											, NIL },;
			    					{ "E1_XNOME"    , cNomCli  		        											, NIL },;
			    					{ "E1_EMISSAO"  , dEmisSE1															, NIL },;
		    						{ "E1_VENCTO"   , aVenc[nl,2]														, NIL },;
		    						{ "E1_VENCREA"  , aVenc[nl,2]														, NIL },;
									{ "E1_XDTCAIX"  , Z03->Z03_DTABER													, NIL },;
		    						{ "E1_VALOR"    , aVenc[nl,1]  		  												, NIL },;
		    						{ "E1_HIST"     , "Venda a prazo :" + SE4->E4_XFORMA 								, NIL },;
		    						{ "E1_NUMNOTA"  , cxDocSF2															, NIL },;
			    					{ "E1_SERIE"    , cxSerie															, NIL },;
			    					{ "E1_ORIGEM"   , "MATA920"															, NIL },;
			    					{ "E1_XSEQVDA"  , Z03->Z03_SEQVDA													, NIL },;
		    						{ "E1_XCAIXA"   , Z03->Z03_CAIXA   													, NIL },;
		    						{ "E1_XCODEXT"  , Z03->Z03_COND   											        , NIL },;
		    						{ "E1_XADMIN"   , ""																, NIL },;
                                    { "E1_XDESCAD"  , SE4->E4_DESCRI												    , NIL },;
		    						{ "E1_DOCTEF"   , ""																, NIL },;
			    					{ "E1_XNUMCAR"  , ""																, NIL },;
			    					{ "E1_XHORAV"   , Z03->Z03_HRVDA													, NIL },;
			    					{ "E1_XNUMVP"   , IIF(SE4->E4_XFORMA $ "VP",Z03->Z03_NUMVP,"")						, NIL },;
			    					{ "E1_XCDCLI"   , Z01->Z01_CDCLI													, NIL },;
			    					{ "E1_XCDCONS"  , Z01->Z01_CDCONS													, NIL },;
		    						{ "E1_XCONC"    , "N"																, NIL } ;
		    					}

			    	// -> Verifica se o título já foi incluído, se não foi inclui
					SE1->(DbSetOrder(1))
					SE1->(DbSeek(xFilial("SE1")+cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1))
					If !SE1->(Found())
				    	// -> Inclui recebiemnto com cartao
				    	lMsErroAuto:=.F.
						dDataBase  :=Z01->Z01_DATA
				    	MsExecAuto({|x,y| FINA040(x,y)},aDadosSE1,3)
		    			dDataBase  :=dDataAnt
						If lMsErroAuto
		    				lErro	 :=.T.
							cFileName:= "se1_"+cFilAnt+"_"+cxSerie+"_"+AllTrim(cxDocSF2)+"_"+strtran(time(),":","")
							MostraErro(cPathTmp, cFileName)
							cFileErr :=memoread(cPathTmp+cFileName)					
							cAuxLog  :="Erro na inclusao do titulo. Verifique o detalhamento da ocorrencia."	
							cAuxLogD :=cFileErr		
							fErase(cPathTmp+cFileName)		
							aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
							//DisarmTransaction()
						Else
							nRecSE1:=SE1->(Recno())
						EndIf
					Else
						nRecSE1:=SE1->(Recno())
					EndIf	
					// -> Verifica se incluiu o título anterior para continuar o processo	
					If nRecSE1 >= 0
						// -> Verifica se o título é do tipo VP (vale presente). Caso seja, procura pelo RA e faz a compensação
						If UPPER(SE4->E4_XFORMA) $ "VP" .and. !Empty(Z03->Z03_NUMVP)
							// -> Baixa o titulo no banco do vale presente.
							aBaixa :={	{"E1_PREFIXO"  ,cxSerie			                  							,Nil    },;
										{"E1_NUM"      ,cxDocSF2														,Nil    },;
										{"E1_PARCELA"  ,StrZero(nParc,nTamParc)										,NIL    },;
										{"E1_TIPO"     ,cTipoSE1               										,Nil    },;
										{"AUTMOTBX"    ,"NOR"                  										,Nil    },;
										{"AUTBANCO"    ,cBcLojaP                  									,Nil    },;
										{"AUTAGENCIA"  ,cAgLojaP   		            								,Nil    },;
										{"AUTCONTA"    ,cCCLojaP      												,Nil    },;
										{"AUTDTBAIXA"  ,dEmisSE1              										,Nil    },;
										{"AUTDTCREDITO",dEmisSE1              										,Nil    },;
										{"AUTHIST"     ,"Recebto vale presente:"+Z03->Z03_NUMVP          			,Nil    },;
										{"AUTJUROS"    ,0                      										,Nil,.T.},;
										{"AUTVALREC"   ,aVenc[nl,1]                    								,Nil    }}
							// -> Executa a baixa do titulo
							lMsErroAuto:=.F.
							dDataBase  :=Z01->Z01_DATA
							MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
							dDataBase  :=dDataAnt
							If lMsErroAuto
								lErro    :=.T.
								cFileName:="se1_"+cFilAnt+"_"+cxSerie+"_"+AllTrim(cxDocSF2)+"_"+strtran(time(),":","")
								MostraErro(cPathTmp, cFileName)
								cFileErr :=memoread(cPathTmp+cFileName)
								cAuxLog  :="Erro na baixa do titulo relacionado ao 'cartao presente'. Verifique o detalhamento da ocorrencia."					
								cAuxLogD :=cFileErr
								fErase(cPathTmp+cFileName)											
								aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE5","E",7,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
								Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
								//DisarmTransaction()
							EndIf	 
						EndIf
					EndIf			
			
				// -> Vendas para "eventos", "consumidor" e "vale presente" 	
		    	Else
	    			cTipoSE1:="DP"
	    			cTipoSE1:=PadR(cTipoSE1,nTamTipo)	    	
					nRecSE1 :=-1

					cAuxLog	:="Incluindo titulo "+cxSerie+":"+cxDocSF2+":"+StrZero(nParc,nTamParc)+":"+cTipoSE1"
					cAuxLogD:="Incluindo titulo "+cxDocSF2+", prefixo " + cxSerie + " e parcela "+StrZero(nParc,nTamParc)
					aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

		    		aDadosSE1 :={ 	{ "E1_PREFIXO"  , cxSerie															, NIL },;
		    						{ "E1_NUM"      , cxDocSF2												           	, NIL },;
		    						{ "E1_PARCELA"  , StrZero(nParc,nTamParc)              								, NIL },;
		    						{ "E1_TIPO"     , cTipoSE1              											, NIL },;
		    						{ "E1_NATUREZ"  , cNatSE1			   												, NIL },;
			    					{ "E1_CLIENTE"  , cCodCli	         											   	, NIL },;
			    					{ "E1_LOJA"     , cCodLCli          												, NIL },;
			    					{ "E1_XCLIENT"  , cCodCli       	   											   	, NIL },;
		    						{ "E1_XLOJA"    , cCodLCli		          											, NIL },;
		    						{ "E1_XNOME"    , cNomCli  		        											, NIL },;
		    						{ "E1_EMISSAO"  , dEmisSE1															, NIL },;
		    						{ "E1_VENCTO"   , aVenc[nl,2]														, NIL },;
		    						{ "E1_VENCREA"  , aVenc[nl,2]														, NIL },;
									{ "E1_XDTCAIX"  , Z03->Z03_DTABER													, NIL },;
			    					{ "E1_VALOR"    , aVenc[nl,1]  		  												, NIL },;
			    					{ "E1_HIST"     , "Venda a prazo :" + SE4->E4_XFORMA 								, NIL },;
			    					{ "E1_NUMNOTA"  , cxDocSF2															, NIL },;
		    						{ "E1_SERIE"    , cxSerie															, NIL },;
		    						{ "E1_ORIGEM"   , "MATA920"															, NIL },;
		    						{ "E1_XSEQVDA"  , Z03->Z03_SEQVDA													, NIL },;
		    						{ "E1_XCAIXA"   , Z03->Z03_CAIXA   													, NIL },;
		    						{ "E1_XCODEXT"  , Z03->Z03_COND   											        , NIL },;
		    						{ "E1_XADMIN"   , ""																, NIL },;
                                    { "E1_XDESCAD"  , SE4->E4_DESCRI												    , NIL },;
			    					{ "E1_DOCTEF"   , ""																, NIL },;
			    					{ "E1_XNUMCAR"  , ""																, NIL },;
		    						{ "E1_XHORAV"   , Z03->Z03_HRVDA													, NIL },;
		    						{ "E1_XNUMVP"   , ""																, NIL },;
			    					{ "E1_XCDCLI"   , Z01->Z01_CDCLI													, NIL },;
			    					{ "E1_XCDCONS"  , Z01->Z01_CDCONS													, NIL },;
		    						{ "E1_XCONC"    , "N"																, NIL } ;
		    					}
			    	// -> Verifica se o título já foi incluído, se não foi inclui
					SE1->(DbSetOrder(1))
					SE1->(DbSeek(xFilial("SE1")+cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1))
					If !SE1->(Found())
				    	// -> Inclui recebimento
				    	lMsErroAuto:=.F.
						dDataBase  :=Z01->Z01_DATA
				    	MsExecAuto({|x,y| FINA040(x,y)},aDadosSE1,3)
						dDataBase  :=dDataAnt
		    			If lMsErroAuto
		    				lErro	 :=.T.					
							cFileName:= "se1_"+cFilAnt+"_"+cxSerie+"_"+AllTrim(cxDocSF2)+"_"+strtran(time(),":","")
							MostraErro(cPathTmp, cFileName)
							cFileErr :=memoread(cPathTmp+cFileName)
							cAuxLog  :="Erro na inclusao do titulo. Verifique detalhamento da ocorrencia."					
							cAuxLogD :=cFileErr
							fErase(cPathTmp+cFileName)
							aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","E",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
							Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
							//DisarmTransaction()
						Else
							nRecSE1:=SE1->(Recno())
						EndIf	
					Else
						nRecSE1:=SE1->(Recno())
					EndIf	
				EndIf	    
	    
				// -> Atualiza o log
				If !lErro
					cAuxLog	:="Ok."
					cAuxLogD:="Incluido titulo "+cxDocSF2+", prefixo " + cxSerie + " e parcela "+StrZero(nParc,nTamParc) + " com sucesso."
					aadd(aRet3009,{cxSerie+cxDocSF2+StrZero(nParc,nTamParc)+cTipoSE1,"SE1","L",1,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLogD})
					Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
				EndIf			

	    	Next nl

	    //End Transaction

		Z03->(DbSkip())
	
	EndDo    

	SetFunName(cFunNamAnt)

	// -> Se não ocorreu nenhum erro, atualiza o processo de inclusão dos títulos
	If !lErro	
		// -> Atualiza o registro do processo
		ZWV->(DbGoTo(nRecProc))
    	RecLock("ZWV",.F.)
		ZWV->ZWV_STATUS:="I"
		ZWV->ZWV_ELTIME:=ELAPTIME(cxTime,Time())
		ZWV->(MsUnlock())
	EndIf	

	// -> Verifica se os títulos a receber foram gerados corretamente
	lAux:=.F.
	nAux:=Len(Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG))
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG)))
	While !ZWV->(Eof()) .and. ZWV->ZWV_FILIAL == xFilial("ZWV") .and. Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_ENTREG) == SubStr(ZWV->ZWV_PK,1,nAux)
		If ZWV->ZWV_STATUS == "P" .and. ZWV->ZWV_SEQ == "O"
			lErro:=.T.
			// -> Exibe nmensagem de erro
			If !lAux	
				cAuxLog:="Nao foi concluida a inclusao dos titulos da venda.
				aadd(aRet3009,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+Dtos(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "FINANCEIRO", "", cAuxLog})
				Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
				lAux:=.T.
			EndIf
		EndIf
		ZWV->(DbSkip())
	EndDo	
	lErro:=IIF(lErro,.F.,.T.)

Return(lErro)





/*
+------------------+---------------------------------------------------------+
!Nome              ! FAT3010                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina de cancelamento das notas fiscais                !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Gabriel                                           !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 23/11/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function FAT3010(aRetSF2,oEventLog,nxIDThread,cCRetSEFAZ)
Local aArea		:= {}
Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local lErro    	:= .F.
Local cPathTmp  := "\temp\"
Local cAuxLog	:= ""
Local cFileErr	:= ""
Local cFileName := ""
Local cF2FILIAL := ""
Local cF2SERIE  := ""
Local cF2DOC    := ""
Local cF2CLIENTE:= ""
Local cF2LOJA   := ""
Local lLancPad30:=VerPadrao("630")
Local lLancPad35:=VerPadrao("635")
Local cLoteFat	:= "FAT "
Local cArqProva	:= ""
Local nTotLan 	:= 0
Local nHdlPrv	:= 0
Local dDataAnt  := dDataBase
Private lMsErroAuto := .F.

	aEval({'SF4','SA1','SB1'},{|alias| AAdd(aArea, GetArea(alias))})

	dDataBase:=Z01->Z01_DATA
	SX5->(dbSetOrder(1))
	If SX5->(dbSeek(cFilial+"09FAT"))
		cLoteFat := Trim(SX5->(X5Descri()))
	EndIf
	
	DbSelectArea("SF2")  
	SF2->(DbOrderNickName("SEQVDA"))	
	SF2->(DbSeek(xFilial("SF2")+Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA)))
	If SF2->(Found())

		//#TB20200827 - Posiciona na Tabela SA1 para ser utilizado no LP630
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial('SA1')+SF2->(F2_CLIENTE+F2_LOJA)))
		
		// -> Registra log com o código de retono da SEFAZ
		cAuxLog:="Sera utilizado autorizacao da SEFAZ " + AllTrim(Z01->Z01_OBSNFC) + " para cancelar a venda com sequencia " + Z01->Z01_SEQVDA + " no caixa "+Z01->Z01_CAIXA+" em "+DtoC(Z01->Z01_DATA)
		aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","W",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", cAuxLog})
		Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

		cF2FILIAL := SF2->F2_FILIAL
		cF2SERIE  := SF2->F2_SERIE
		cF2DOC    := SF2->F2_DOC
		cF2CLIENTE:= SF2->F2_CLIENTE
		cF2LOJA   := SF2->F2_LOJA
		cF2EMISSAO:= DtoS(SF2->F2_EMISSAO)

		aadd(aCabec,{"F2_TIPO"   	,"N"				})
		aadd(aCabec,{"F2_DOC"    	,SF2->F2_DOC		})
		aadd(aCabec,{"F2_SERIE"  	,SF2->F2_SERIE		})
		aadd(aCabec,{"F2_EMISSAO"	,SF2->F2_EMISSAO	})
		aadd(aCabec,{"F2_CLIENTE"	,SF2->F2_CLIENTE	})
		aadd(aCabec,{"F2_LOJA"   	,SF2->F2_LOJA		})
		aadd(aCabec,{"F2_CHVNFE"	,SF2->F2_CHVNFE	    })
		aadd(aCabec,{"F2_HORA"		,SF2->F2_HORA		})

		// -> Prepara contabilização
		nTotLan := 0
		If (lLancPad30 .or. lLancPad35) .And. (nHdlPrv :=HeadProva(cLoteFat,"MATA460",cUserName,@cArqProva)) <= 0
			cAuxLog	:="Erro na contabilização do documento fiscal."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", ""})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
			lErro := .T.
		EndIf

		SD2->(dbSetOrder(3))
		SD2->(dbGoTop())
		If SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
			
			//#TB20200828 - Posiciona na Tabela SF4 referente ao primeiro item da SD2 para ser utilizado no LP635
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial('SF4')+SD2->D2_TES))

		EndIf
							
		// -> Inicia o LP de exclusão - Documento
		If lLancPad35 .and. !lErro
			nTotLan+=DetProva(nHdlPrv,"635","MATA460",cLoteFat)
		Endif

		aLinha := {}
		DbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		SD2->(dbGoTop())
		SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		While !SD2->( Eof() ) .And. (SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE) == (xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE+ SF2->F2_CLIENTE))

			aadd(aLinha,{"D2_COD"  	,SD2->D2_COD	,Nil})
			aadd(aLinha,{"D2_ITEM" 	,SD2->D2_ITEM	,Nil})
			aadd(aLinha,{"D2_QUANT"	,SD2->D2_QUANT	,Nil})
			aadd(aLinha,{"D2_PRCVEN",SD2->D2_PRCVEN	,Nil})
			aadd(aLinha,{"D2_TOTAL"	,SD2->D2_TOTAL	,Nil})
			aadd(aItens,aLinha)

			// -> Atualiza os dados do Cupom
			RecLock("SD2",.F.)
			SD2->D2_ORIGLAN:="  "
			SD2->D2_ESTOQUE:="S"					
			SD2->(MsUnlock())

			//#TB20200827 - Posiciona na Tabela SF4 para ser utilizado no LP630
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial('SF4')+SD2->D2_TES))

			//#TB20200827 - Posiciona na Tabela SB1 para ser utilizado no LP630
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1')+SD2->D2_COD))

			// -> Gera Lancamento Contabeis a nivel de itens - Exclusão
			If lLancPad30
				nTotLan+=DetProva(nHdlPrv,"630","MATA460",cLoteFat)
			Endif

			SD2->(DbSkip())
			
		EndDo

		// -> Envia para Lancamento Contabil, se gerado arquivo
		If (lLancPad35 .Or. lLancPad30)
			RodaProva(nHdlPrv,nTotLan)
			cA100Incl(cArqProva,nHdlPrv,3,cLoteFat,.F.,.T.)
			// -> Atualiza flag de contabilização
			RecLock('SF2',.F.)
			SF2->F2_DTLANC:=dDataBase
			SF2->(MsUnlock())
		Endif

		// -> Retorna o status do cupom para o fiscal, para fazer o cancelamento
		DbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		SD2->(dbGoTop())
		SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		While !SD2->( Eof() ) .And. (SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE) == (xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE+ SF2->F2_CLIENTE))

			// -> Atualiza os dados do Cupom
			RecLock("SD2",.F.)
			SD2->D2_ORIGLAN:="LF"
			SD2->D2_ESTOQUE:=" "					
			SD2->(MsUnlock())
			SD2->(DbSkip())
			
		EndDo

		// -> Excita o processo de exclusão do documento fiscal.
		lErro:=.F.
		MATA920(aCabec,aItens,5)		
		If !lMsErroAuto
			cAuxLog	:="Ok."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", ""})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		Else
			lErro	 := .T.
			cFileName:= "SF2_"+cFilAnt+"_"+AllTrim(cF2DOC)+cF2SERIE+cF2CLIENTE+cF2LOJA+"_"+strtran(time(),":","")
			MostraErro(cPathTmp, cFileName)
			cFileErr :=memoread(cPathTmp+cFileName)
			fErase(cPathTmp+cFileName)
			cAuxLog  :="Erro no cancelamento documento fiscal. Verifique o detalhe da ocorrencia."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","E",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", ""})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)
		EndIf
	
		// -> Atualiza a SF3
		If !lErro
			cAuxLog	:="Atualizando complementos fiscais - SF3."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", ""})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)

			SF3->(DbSetOrder(1))
			SF3->(DbSeek(cF2FILIAL+cF2EMISSAO+cF2DOC+cF2SERIE+cF2CLIENTE+cF2LOJA))	
			If SF3->(Found())
				While !SF3->(Eof()) .and. SF3->F3_FILIAL == cF2FILIAL .and. DtoS(SF3->F3_ENTRADA) == cF2EMISSAO .and. SF3->F3_NFISCAL == cF2DOC .and. SF3->F3_SERIE == cF2SERIE .and. SF3->F3_CLIEFOR == cF2CLIENTE .and. SF3->F3_LOJA == cF2LOJA
					RecLock("SF3",.F.)
					SF3->F3_CODRSEF:=cCRetSEFAZ
					SF3->(MsUnlock())						
				
					SF3->(DbSkip())
				EndDo	
			EndIf	
			cAuxLog	:="Ok."
			aadd(aRetSF2,{Z01->Z01_SEQVDA+Z01->Z01_CAIXA+DtoS(Z01->Z01_DATA),"Z01","L",3,cAuxLog,.F.,Z01->Z01_SEQVDA+Z01->Z01_CAIXA,Z01->Z01_DATA, 0, "CANC DOCUMENTO FISCAL", "", ""})
			Conout(StrZero(nxIDThread,10)+": "+cAuxLog)	
		EndIf

	EndIf	

	dDataBase:=dDataAnt

	aEval(aArea,{|area| RestArea(area)} )

Return(!lErro)




/*
+------------------+---------------------------------------------------------+
!Nome              ! F300QZ02                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Consulta dados de produção da venda importaos do Teknisa!
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/07/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300QZ02(dDataProc) 
Local cAliasZ04 := GetNextAlias()
Local cQuery    := ""

	cQuery := "SELECT SB1.B1_COD,                "
	cQuery += "       SB1.B1_DESC,               "
	cQuery += "       SB1.B1_TIPO,               "
	cQuery += "       SUM(Z02.Z02_QTDE) Z02_QTDE "
	cQuery += "FROM " + RetSqlName("Z02") + " Z02 INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "    ON SB1.B1_FILIAL    = '" + xFilial("SB1") + "' AND        "
	cQuery += "       SB1.B1_XCODEXT   = Z02.Z02_PROD             AND        "
	cQuery += "       SB1.D_E_L_E_T_  <> '*'                                 "
	cQuery += "JOIN " + RetSqlName("SF2") + " SF2                            "
	cQuery += "    ON SF2.F2_FILIAL    = Z02.Z02_FILIAL AND                  "
	cQuery += "       SF2.F2_XSEQVDA   = Z02.Z02_SEQVDA AND                  "
	cQuery += "       SF2.F2_XCAIXA    = Z02.Z02_CAIXA  AND                  "
	cQuery += "       SF2.F2_XDTCAIX   = Z02.Z02_ENTREG AND                  "
	cQuery += "       SF2.D_E_L_E_T_  <> '*'                                 "
	cQuery += "WHERE Z02.Z02_FILIAL   = '" + xFilial("Z02")         + "' AND " 
	cQuery += "      Z02.Z02_ENTREG   = '" + DtoS(dDataProc)        + "' AND "
	cQuery += "      Z02.Z02_PROD    <> ' '                              AND "
	cQuery += "      Z02.Z02_QTDE     > 0		                         AND "            
	cQuery += "      Z02.D_E_L_E_T_  <> '*'                                  "            
	cQuery += "GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO                 "
	cQuery += "ORDER BY SB1.B1_COD                                           "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ04,.T.,.T.)

Return(cAliasZ04)

/*
+------------------+---------------------------------------------------------+
!Nome              ! Z04OBSPRD                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Consulta dados de produção da venda importaos do Teknisa!
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/07/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function Z04OBSPRD(dDataProc) 
Local cAliasZ04 := GetNextAlias()
Local cQuery    := ""

	cQuery := "SELECT Z04.Z04_CODMP  AS CODMP,      							"
	cQuery += "       Z02.Z02_PROD   AS PRODUTO, 								"
    cQuery += "       SUM(Z04.Z04_QTDE) AS Z04_QTDE,      					    "
    cQuery += "       SUM(Z02.Z02_QTDE) AS QUANTADC 							"
    cQuery += "FROM " + RetSqlName("Z04") + " Z04								"
    cQuery += "INNER JOIN " + RetSqlName("Z13") + " Z13 ON 						"
    cQuery += "    Z13.Z13_FILIAL   = '" + xFilial("Z13") + "'					"
    cQuery += "    AND Z13.Z13_XCODEX   = Z04.Z04_PRDUTO						"
    cQuery += "    AND Z13.D_E_L_E_T_  <> '*'									"
    cQuery += "JOIN " + RetSqlName("SB1") + " SB1 ON 					        "
    cQuery += "    SB1.B1_FILIAL    = '" + xFilial("SB1") + "'					"
    cQuery += "    AND SB1.B1_COD       = Z13.Z13_COD							"
    cQuery += "    AND SB1.D_E_L_E_T_  <> '*'									"
    cQuery += "JOIN " + RetSqlName("Z02") + " Z02 ON 							"
    cQuery += "    Z02.Z02_FILIAL   = Z04.Z04_FILIAL							"
    cQuery += "    AND Z02.Z02_SEQVDA   = Z04.Z04_SEQVDA						"
    cQuery += "    AND Z02.Z02_CAIXA    = Z04.Z04_CAIXA							"
    cQuery += "    AND Z02.Z02_DATA     = Z04.Z04_DATA							"
    cQuery += "    AND Z02.Z02_SEQIT    = Z04.Z04_SEQIT							"
    cQuery += "    AND Z02.D_E_L_E_T_  <> '*'									"
    cQuery += "JOIN " + RetSqlName("SF2") + " SF2                               "
    cQuery += "    ON SF2.F2_FILIAL    = Z02.Z02_FILIAL AND                     "
    cQuery += "       SF2.F2_XSEQVDA   = Z02.Z02_SEQVDA AND                     "
    cQuery += "       SF2.F2_XCAIXA    = Z02.Z02_CAIXA  AND                     "
    cQuery += "       SF2.F2_XDTCAIX   = Z02.Z02_ENTREG AND                     "
    cQuery += "       SF2.D_E_L_E_T_  <> '*'                                    "
    cQuery += "JOIN " + RetSqlName("SB1") + " SB12 ON 							"
    cQuery += "    SB12.B1_FILIAL    = '" + xFilial("SB1") + "'					"
    cQuery += "    AND SB12.B1_XCODEXT = Z02.Z02_PROD						    "
    cQuery += "    AND SB12.D_E_L_E_T_  <> '*'									"
    cQuery += "WHERE 															"
    cQuery += "    Z04.Z04_FILIAL       = '" + xFilial("Z04")         + "'		"
    cQuery += "    AND Z04.Z04_ENTREG   = '" + DtoS(dDataProc)        + "'		"
    cQuery += "    AND Z04.Z04_IDCOBS   = 'A'  								    "
    cQuery += "    AND Z04.D_E_L_E_T_  <> '*'									"
    cQuery += "    GROUP BY Z04.Z04_CODMP, Z02.Z02_PROD                         "
    cQuery += "    ORDER BY Z04.Z04_CODMP, Z02.Z02_PROD                         "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ04,.T.,.T.)

Return(cAliasZ04)


/*
+------------------+---------------------------------------------------------+
!Nome              ! F300AtuSld                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Função criada para processar a atualização de custo no  !
!                  ! movimento da SD2 gerado pela integração com Tecknisa    !
!                  ! (originalmente sem atualização de estoque)  e consequen-!
!                  ! te atualização de saldos.te atualização de saldos.      !
+------------------+---------------------------------------------------------+
!Autor             ! André Oliveira                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/07/2018                                              !
+------------------+---------------------------------------------------------+
*/

Static Function F300AtuSld(cEstNegat,nTamDecSD2,aRetSB2,nxIDThread,aRetF300At)
Local aCM 		:= {}
Local aCusto	:= {} 
Local lRet      := .T.
Local nSaldoSB2 := 0
Local cAuxLog   := ""
Local nAux      := aScan(aRetF300At,{|xz| xz[1] == SD2->D2_DOC+SD2->D2_COD})
Local lAtuLogSB2:= aRetF300At[nAux,02]

	// -> Verifica se a TES movimenta estoque
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
	If SF4->F4_ESTOQUE = "S"

		// -> Verifica se existe saldo, controle de lote e localização para o produto e, caso não existir saldo ou existir controle de endereço ou localização, retorna erro
		// -> Posiciona no cadastro de produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
		If SB1->B1_RASTRO <> "S" .and. SB1->B1_LOCALIZ <> "S"

			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SD2->D2_COD+SD2->D2_LOCAL))
			nSaldoSB2:=SaldoSb2()

			// -> Verifica se o saldo é maior ou igual a quantidade do documento, caso contrário, retorna erro.
			If (NoRound(nSaldoSB2,nTamDecSD2) >= NoRound(SD2->D2_QUANT,nTamDecSD2)) .or. (Upper(cEstNegat) == "S")
				// -> Obtém custo médio do produto
				aCM	:= PegaCMAtu(SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_TIPO)
				// -> Atualiza valores de custo no movimento da SD2
				aCusto := GravaCusD2(aCM,SD2->D2_TIPO)
				// -> Atualiza saldos nas tabelas SB2, SB8 e SBF
				B2AtuComD2(aCusto)
			Else
				lRet   :=.F.
				If !lAtuLogSB2
					cAuxLog:="Falta saldo de estoque para o produto "+AllTrim(SD2->D2_COD) + " - " + AllTrim(SB1->B1_DESC) +"."
					aadd(aRetSB2,{SD2->D2_COD+SD2->D2_LOCAL,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO,SD2->D2_QUANT, "SALDO DE ESTOQUE", SD2->D2_COD, "", .T.})
					ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
				EndIf	
			EndIf
		Else
			lRet   :=.F.
			// -> Se o lote está ativado
			If SB1->B1_RASTRO <> "N"
				cAuxLog:="Produto "+AllTrim(SD2->D2_COD)+" - "+AllTrim(SB1->B1_DESC)+" com lote habilitado no cadastro de produtos. Favor retirar o controle."
				aadd(aRetSB2,{SD2->D2_COD+SD2->D2_LOCAL,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO, SD2->D2_QUANT, "CADASTROS", SD2->D2_COD, "", .F.})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf
			// -> Se o controle de colalização está ativado
			If SB1->B1_LOCPAD <> "N"
				cAuxLog:="Produto "+AllTrim(SD2->D2_COD)+" - "+AllTrim(SB1->B1_DESC)+" com controle de localizcao habilitado no cadastro de produtos. Favor retirar o controle."
				aadd(aRetSB2,{SD2->D2_COD+SD2->D2_LOCAL,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO, SD2->D2_QUANT, "SALDO DE ESTOQUE", SD2->D2_COD, "", .F.})
				ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
			EndIf
		EndIf
	
	EndIf	

Return(lRet)



/*
+------------------+---------------------------------------------------------+
!Nome              ! F300AtuAlt                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcao de controle de necessidade de transferencia de   !
!                  ! Produtos Alternativos                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 15/02/2019                                              !
+------------------+---------------------------------------------------------+
*/

Static Function F300AtuAlt(cEstNegat,nTamDecSD2,aRetSD3 ,nxIDThread,aRetSB2 ,cCodProd,cCodLocal,cTes,nQuant,cxSeqVda,cxCaixa,aRetF300At,cxDocSF2,dDatEmis,cSeqIt)
Local lRet      	:= .F.
Local nSaldoSB2 	:= 0
Local nSldSB2Alt	:= 0
Local nSldConvAlt   := 0
Local cAuxLog   	:= ""
Local aAutoItens	:= {}
Local aAutoCab		:= {}
Local aArea			:= GetArea()
Local cPathTmp  	:= "\temp\"
Local cFileErr  	:= ""
Local cFileName 	:= ""
Local lErro			:= .F.
Local cAuxLogD		:= ""
Local cQuerySD3     := ""
Local cAliasSD3     := ""
Local aPOrig        := {}
Local aPDest        := {}
Local nItenSG1      := 0
Local ny            := 0
Local cFunNamAnt    := FunName()
Local nTamZWVPK     := TamSX3("ZWV_PK")[1]
Local cxTime        := Time()
Private lMsErroAuto	:= .F.


	SetFunName("MATA242")
	aAdd(aRetF300At,{cxDocSF2+cCodProd,.F.})

	// -> Verifica se existe ponto de lançamento e se já foi realizado a transferência
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+PADR(cxSeqVda+cxCaixa+DtoS(dDatEmis)+cSeqIt,nTamZWVPK)+"U"))
	If !ZWV->(Found())
		RecLock("ZWV",.T.)					        	    
        ZWV->ZWV_FILIAL := xFilial("ZWV")
		ZWV->ZWV_PK		:= cxSeqVda+cxCaixa+DtoS(dDatEmis)+cSeqIt
		ZWV->ZWV_DESCP	:= "TRANSF. ESTOQUE DO ITEM:"+cSeqIt
		ZWV->ZWV_SEQ	:= "U"
		ZWV->ZWV_STATUS := "P"
		ZWV->ZWV_ELTIME := ""
		ZWV->(MsUnlock())
	EndIf		

	// -> Verifica se já foi transferido, e se foi, retorna True
	If ZWV->ZWV_STATUS == "I"
		Return({.T.,.T.})
	EndIf
	
	// -> Verifica se a TES movimenta estoque
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4")+cTes))
	If SF4->F4_ESTOQUE == "S"

		// -> Verifica se existe saldo, controle de lote e localização para o produto e, caso não existir saldo ou existir controle de endereço ou localização, retorna erro
		
		// -> Posiciona no cadastro de produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+cCodProd))
		
		// -> Verifica o saldo do produto principal
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial("SB2")+cCodProd+cCodLocal))
		
		nSaldoSB2:=SaldoSb2()
				
		// -> Verifica se o produto principal e do tipo ME e se o saldo e menor ou igual a 0
		If SB1->B1_TIPO == 'ME' .And. nSaldoSB2 < nQuant
		
			// -> Posiciona no cadastro de produtos alternativos
			SGI->(DbSetOrder(1))
			SGI->(DbSeek(xFilial("SGI")+cCodProd))
			If SGI->(Found())

				// -> Verifica a quantidade de itens alternativos para o produto
				nItenSG1:=0
				While SGI->(!Eof()) .And. xFilial("SGI") == SB2->B2_FILIAL .And. cCodProd == SGI->GI_PRODORI .And. lRet == .F.
					nItenSG1:=nItenSG1+1
					SGI->(DbSkip())
				EndDo	

				// -> Reposiciona no produto
				SGI->(DbSetOrder(1))
				SGI->(DbSeek(xFilial("SGI")+cCodProd))
				While SGI->(!Eof()) .And. xFilial("SGI") == SB2->B2_FILIAL .And. cCodProd == SGI->GI_PRODORI .And. lRet == .F.

					aPOrig  :={}
					aPDest  :={}
					nItenSG1:=nItenSG1-1
					
					cAuxLog:="Transferindo saldo do produto "+AllTrim(cCodProd)+" para o produto "+AllTrim(SGI->GI_PRODALT)+"..."
					aadd(aRetSD3,{cxDocSF2+DtoS(dDataBase),"SD3","L",0,cAuxLog,.F.,cxSeqVda+cxCaixa,dDatEmis, 0, "TRANSFERENCIA", "",""})
					ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)

					// -> Posiciona o produto alternativo no cadastro de produto
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+SGI->GI_PRODALT))
					
					Aadd(aPOrig,{SB1->B1_COD,SB1->B1_LOCPAD,0})
					Aadd(aPDest,{cCodProd,cCodLocal,nQuant-nSaldoSB2})
					
					If SB1->B1_RASTRO <> "S" .and. SB1->B1_LOCALIZ <> "S"
			
						// -> Saldo Produto alternativo
						SB2->(DbSetOrder(1))
						SB2->(DbSeek(xFilial("SB2")+aPOrig[1,1]+aPOrig[1,2]))
						If SB2->(Found())
							nSldSB2Alt :=SaldoSb2()
						Else
							nSldSB2Alt :=0
						EndIf	
						nSldConvAlt:=NoRound(IIF(SGI->GI_TIPOCON == 'M',SGI->GI_FATOR * (nQuant-nSaldoSB2),(nQuant-nSaldoSB2)/SGI->GI_FATOR),nTamDecSD2)
			
						// -> Verifica se o saldo é maior ou igual a quantidade do documento, caso contrário, retorna erro.
						If (NoRound(nSldSB2Alt,nTamDecSD2) >= nSldConvAlt) .or. (Upper(cEstNegat) == "S")

							//Verificar transferencia, verificar as 2 operacoes e incluir manualmente no SD3 considerando a saida de ex: 300ml e entrada de 1 copo no estoque
							DbSelectArea("SB1")
							lMsErroAuto:=.F.
							aAutoCab   := {	{"cProduto"   , aPOrig[1,1]	 					, Nil},;   			
											{"cLocOrig"   , aPOrig[1,2]					    , Nil},;			
											{"nQtdOrig"   , nSldConvAlt                 	, Nil},;			
											{"nQtdOrigSe" , CriaVar("D3_QTSEGUM")			, Nil},;			
											{"cDocumento" , cxDocSF2					    , Nil},;			
											{"cNumLote"   , CriaVar("D3_NUMLOTE")		 	, Nil},;			
											{"cLoteDigi"  , CriaVar("D3_LOTECTL")		 	, Nil},;			
											{"dDtValid"   , CriaVar("D3_DTVALID")		 	, Nil},;			
											{"nPotencia"  , CriaVar("D3_POTENCI")		 	, Nil},;			
											{"cLocaliza"  , CriaVar("D3_LOCALIZ")		 	, Nil},;			
											{"cNumSerie"  , CriaVar("D3_NUMSERI")		 	, Nil}}
	
							aAutoItens  := { { {"D3_COD"    , aPDest[1,1]					, Nil},;			
											   {"D3_LOCAL"  , aPDest[1,2]					, Nil},;			
											   {"D3_QUANT"  , aPDest[1,3]					, Nil},;			
											   {"D3_QTSEGUM", CriaVar("D3_QTSEGUM")			, Nil},;			
											   {"D3_RATEIO" , 100 							, Nil}}}
							
							MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.) 					
							If lMsErroAuto							
								lErro	 := .T.
								cFileName:= "sd3_"+cFilAnt+"_"+AllTrim(cxDocSF2)+Z01->Z01_CAIXA+SA1->A1_COD+SA1->A1_LOJA+"_"+strtran(time(),":","")
								MostraErro(cPathTmp, cFileName)
								cFileErr :=memoread(cPathTmp+cFileName)
								cAuxLog  :="Erro na geracao da transferencia. Verifique o detalhe da ocorrencia."
								cAuxLogD :=cFileErr
								// -> Processa arquivo de retorno do erro do apontamento e verifica e gera logs de falta de saldos
								aAux   :=GetSB2Log(cPathTmp+cFileName,aPOrig[01,01],aPOrig[01,02],.F.)
								cAuxLog:=""
								If Len(aAux) > 0
									For ny:=1 to Len(aAux)
										SB1->(DbSetOrder(1))
										SB1->(DbSeek(xFilial("SB1")+aAux[ny,1]))
										If SB1->(Found()) .and. SB1->B1_TIPO <> "PI"						
											cAuxLog:="Falta saldo de estoque para o produto " + aAux[ny,01]+" - "+AllTrim(SB1->B1_DESC) + ", local "+Str(Val(aAux[ny,02])) + ": Produto alternativo " + aPDest[ny,01]
											cAuxLog:=aAux[ny,04]
											aadd(aRetSB2,{aAux[ny,1]+aAux[ny,2],"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO,Val(aAux[ny,3]), "SALDO DE ESTOQUE", aPOrig[01,01], "", .T.})
									    	ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
										EndIf	
									Next ny
								EndIf
								aadd(aRetSD3,{cxDocSF2+DtoS(dDataBase),"SD3","E","D3DOC",cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO, 0, "TRANSFERENCIA", "", cAuxLogD})								
								fErase(cPathTmp+cFileName)
							Else
								// -> Busca na base de dados os registros alterados
								cAliasSD3 := GetNextAlias()
								cQuerySD3 := "SELECT R_E_C_N_O_ REC                   " 
								cQuerySD3 += "FROM " + ReTsqlnAME("SD3") + "          " 
								cQuerySD3 += "WHERE D_E_L_E_T_ <> '*'             AND "
								cQuerySD3 += "D3_FILIAL   = '"+xFilial("SF2") +"' AND "
								cQuerySD3 += "D3_DOC      = '"+cxDocSF2       +"' AND "
								cQuerySD3 += "D3_EMISSAO  = '"+DtoS(dDataBase)+"' AND "
								cQuerySD3 += "D3_CF      IN ('RE7','DE7')         AND "
								cQuerySD3 += "D3_XSEQVDA  = ' '                       "

								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySD3),cAliasSD3,.T.,.T.)
								
								(cAliasSD3)->(DbGoTop())								
								If (cAliasSD3)->(!Eof())								
									While (cAliasSD3)->(!Eof())
										SD3->(DbGoTo((cAliasSD3)->REC))
										RecLock('SD3',.F.)
										SD3->D3_XSEQVDA	:= cxSeqVda
										SD3->D3_XCAIXA	:= cxCaixa
										SD3->D3_XSEQIT	:= cSeqIt
										SD3->(MsUnlock())
										(cAliasSD3)->(DbSkip())
									EndDo			
									(cAliasSD3)->(DbCloseArea())						
									lRet:=.T.									
								Else
									lRet 	:= .F.
									cAuxLog	:="Movimento de transferencia não localizado para o documento [D3_DOC="+cxDocSF2+"]"
									aadd(aRetSD3,{cxDocSF2+DtoS(dDataBase),"SD3","E","D3DOC",cAuxLog,.F.,cxSeqVda+cxCaixa,dDatEmis, 0, "TRANSFERENCIA", "", cAuxLogD})
									ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
								EndIf
							EndIf
						ElseIf nItenSG1 <= 0
							// -> Verifica se é o último produto alternantivo
							aRetF300At[Len(aRetF300At),02]:=.T.
							lRet          := .F.
							cAuxLog       :="Falta saldo de estoque para o produto "+AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+"."
							aadd(aRetSB2,{aPOrig[1,1]+aPOrig[1,2],"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO,nSldConvAlt, "SALDO DE ESTOQUE", SB1->B1_COD, "", .T.})				
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf
					ElseIf nItenSG1 <= 0
						lRet   := .F.
						// -> Se o lote está ativado
						If SB1->B1_RASTRO <> "N"
							cAuxLog:="Produto "+AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)+" com lote habilitado no cadastro de produtos. Favor retirar o controle."
							aadd(aRetSB2,{SB1->B1_COD+SB1->B1_LOCPAD,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO, nQuant, "CADASTROS", SB1->B1_COD, "", .F.})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf
						// -> Se o controle de colalização está ativado
						If SB1->B1_LOCPAD <> "N"
							cAuxLog:="Produto "+SB1->B1_COD+" - "+AllTrim(SB1->B1_DESC)+" com controle de localizcao habilitado no cadastro de produtos. Favor retirar o controle."
							aadd(aRetSB2,{SB1->B1_COD+SB1->B1_LOCPAD,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO, nQuant, "CADASTROS", SB1->B1_COD, "", .F.})
							ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)
						EndIf
					EndIf
					
					SGI->(DbSkip())
					
				EndDo
			
			Else
			
				aRetF300At[Len(aRetF300At),02]:=.F.
				lRet := .T.
			
			EndIf
		
		ElseIf SB1->B1_TIPO == 'ME' .And. nSaldoSB2 < 0
		
			// -> Retorna erro de produto com saldo negativo
			aRetF300At[Len(aRetF300At),02]:=.T.
			lRet          := .F.
			cAuxLog       :="Produto de revenda " + AllTrim(SB2->B2_COD)+" - "+AllTrim(SB1->B1_DESC) + " no local " + SB2->B2_LOCAL + " esta com saldo negativo."
			aadd(aRetSB2,{SB2->B2_COD+SB2->B2_LOCAL,"SB2","E",1,cAuxLog,.F.,SD2->D2_XSEQVDA+SD2->D2_XCAIXA,SD2->D2_EMISSAO,nSaldoSB2, "SALDO DE ESTOQUE",SB2->B2_COD,"",.F.})				
			ConOut(StrZero(nxIDThread,10)+": "+cAuxLog)

		Else

			lRet := .T.
		
		EndIf
	Else
	
		lRet := .T.
	
	EndIf	

	SetFunName(cFunNamAnt)

	// -> Atualiza o processo de transferênci
	If lRet
		RecLock("ZWV",.F.)					        	    
		ZWV->ZWV_STATUS := "I"
		ZWV->ZWV_ELTIME := cxTime
		ZWV->(MsUnlock())
	EndIf	

RestArea(aArea)

Return({lRet,aRetF300At})

/*
+------------------+---------------------------------------------------------+
!Nome              ! GetSB2Log                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Pega saldo de estoque no momento do apontamento da OP.  !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/07/2018                                              !
+------------------+---------------------------------------------------------+
!Observações       ! Registrado em documento que o processo executado por    !
!                  ! atende a versao atual da rotina MATA240 que registra a  !
!                  ! falta de estoque 'em texo'. Caso a rotina mude, deverá  !
!                  ! ser atualizado esta função                              !
+------------------+---------------------------------------------------------+

 Layout atual do retorno da função MATA240 por falta de estoque:

AJUDA:MA240NEGAT
Não existe quantidade suficiente em estoque para atender esta requisição.

Itens Sem Sld / Bloqs. / Empenhos Pendentes
Produto              Armazem                       Saldo Ocorrencia
20103570012500       01                          -0,0500 Sem Saldo em Estoque
*/

Static Function GetSB2Log(cxFile,cProd,cLocal,cQuant,lApont)
Local aRet    :={}
Local cLinha  := ""
Local lErro   :=.F.
Local nPosIQtd:=30
Local nPosFQtd:=28
Local nPosIPro:=1
Local nPosIArm:=22
Local nTamProd:=TamSx3("B1_COD")[1]
Local nTamArm :=TamSx3("B1_LOCPAD")[1]
Default lApont  :=.F.
Default cProd :=""  
Default cLocal:=""
Default cQuant:="0.00"

	// -> Abre o arquivo em que o log foi registrado
	FT_FUSE(cxFile)
  
  	// -> Verifica se o arquivo possui dados
	lErro:=FT_FEOF()
    cLinha:=alltrim(FT_FREADLN())
	
	// -> Tratamento de erro de estoque genérico
	If !lErro .and. "AJUDA:MVESTNEG" $ cLinha

		FT_FSKIP()
		cLinha := ""
  		While !FT_FEOF()
			cLinha := cLinha + FT_FREADLN()
			FT_FSKIP()
		EndDo
		aadd(aRet,{cProd,cLocal,"0",cLinha})
		
	EndIf

	// -> Tratamento de erro de estoque para MATA240
	If !lErro .and. "AJUDA:MA240NEGAT" $ cLinha
		FT_FSKIP()
  		While !FT_FEOF()
			cLinha := FT_FREADLN()
			// -> Verifica se a mensagem do texto se refere a 'falta de estoque' (posição 58 a 77). Se ok, armazenda as informações do log em array
			If "quantidade suficiente" $ cLinha
				If !Empty(cProd)				
				   aadd(aRet,{cProd,cLocal,"0",cLinha})
				EndIf   
			EndIf
			If lApont
				If Val(SubStr(cLinha,nPosIArm,nTamArm)) > 0
					aadd(aRet,{SubStr(cLinha,nPosIPro,nTamProd),SubStr(cLinha,nPosIArm,nTamArm),SubStr(cLinha,nPosIQtd,nPosFQtd),cLinha})
				EndIf	
			EndIf
			FT_FSKIP()
		EndDo
	EndIf
	FT_FUSE()
Return(aRet)



/*
+------------------+---------------------------------------------------------+
!Nome              ! F300FECH                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Verifica fechamento de caixa do restaurante             !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/05/2019                                              !
+------------------+---------------------------------------------------------+
*/
User Function F300FECH(cFilMov,dDataMov,dDataProc)
Local aRet     :={.T.,"Fechamento de caixa do dia " + DtoC(dDataMov) + " ok.",0,0}
Local cQuery   :=""
Local cAliasZ05:=""
Local cAliasSE1:=""
Local cAliasZ01:=""

	// -> Pesquisa dados das vendas
	cQuery   := "SELECT COUNT(*) QTDVENDAS "
	cQuery   += "FROM " + RetSqlName("Z01") + " " 
	cQuery   += "WHERE Z01_FILIAL  = '" + cFilMov +  "' AND D_E_L_E_T_ <> '*' "
	cQuery   := ChangeQuery(cQuery)
	cAliasZ01:= MPSysOpenQuery(cQuery)
	
	// -> Se não tem nenhuma venda no sistema, retorna o fechamento de caixa como true
	If (cAliasZ01)->(Eof())
		aRet[01]:=.T.
		Return(aRet[01])
	EndIf


	// -> Pesquisa dados do fechamento
	cQuery   := "SELECT SUM(Z05_VALOR) Z05_VALOR " 
	cQuery   += "FROM " + RetSqlName("Z05") + " Z05 " 
	cQuery   += "WHERE Z05_FILIAL      = '" + cFilMov        +  "' "
	cQuery   += "	   AND Z05_DATA    = '" + DtoS(dDataMov) +  "' " 
	cQuery   += "	   AND Z05_TIPO    = 'R'                       " 
	cQuery   += "	   AND D_E_L_E_T_ <> '*'                       " 	
	cQuery   := ChangeQuery(cQuery)
	cAliasZ05:= MPSysOpenQuery(cQuery)
	aRet[01]:=!(cAliasZ05)->(Eof())


	// Se tudo nao encontrou o fechamento, retorna false
	If !aRet[01]
		aRet[02]:="Nao encontrado fechamento de caixa para a filial " + cFilMov + " no dia " + Dtoc(dDataMov)
		(cAliasZ05)->(DbCloseArea())
		Return(aRet[01])
	Else
		aRet[03] :=(cAliasZ05)->Z05_VALOR
		cQuery   := "SELECT SUM(E1_VALOR) E1_VALOR      " 
		cQuery   += "FROM " + RetSqlName("SE1") + " SE1 " 
		cQuery   += "WHERE     E1_FILIAL   = '" + cFilMov        +  "' "
		cQuery   += "	   AND E1_EMISSAO  = '" + DtoS(dDataMov) +  "' " 
		cQuery   += "	   AND E1_ORIGEM   = 'MATA920'                 " 
		cQuery   += "	   AND E1_XSEQVDA <> ' '                       "
		cQuery   += "	   AND D_E_L_E_T_ <> '*'                       " 	
		cQuery   := ChangeQuery(cQuery)
		cAliasSE1:= MPSysOpenQuery(cQuery)		
		aRet[04] := IIF((cAliasSE1)->(Eof()),0,(cAliasSE1)->E1_VALOR)

		If aRet[01] 
			If NoRound(aRet[03],TamSX3("E1_VALOR")[2]) <>  NoRound(aRet[04],TamSX3("E1_VALOR")[2])
				aRet[02]:="Diferenca no fechamento de caixa de "+DtoC(dDataMov)+": [Titulos (SE1)="+AllTrim(Transform(aRet[04],"@E 999,999,999.99"))+" x Fechamento (Z05)="+AllTrim(Transform(aRet[03],"@E 999,999,999.99"))+"]"  
				aRet[01]:=.F.
			EndIf	
		EndIf
	Endif

	(cAliasZ05)->(DbCloseArea())
	(cAliasSE1)->(DbCloseArea())

Retur(aRet)