/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 07/07/2016 | Marcos Sulivan                 | Criação da rotina/procedimento.                                                **/
/** 22/03/2018 | Luiz Jacinto                   | Melhora no processo para reducao no tempo de processamento.                    **/
/**********************************************************************************************************************************/
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "PROTHEUS.CH" 

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KAP_WF03()                							                                                         **/
/** funcao usada para atualizar o cadastro de clientes                                                                           **/
/**********************************************************************************************************************************/
user function KAP_WF03() 
	// empresa
	Local _cEmp	:= "01"
	// filial
	Local _cFil	:= "01"
	// modulo
	Local _cMod	:= "05"
	// usuario
	Local _cUs	:= Nil
	// senha
	Local _cPas	:= Nil
	// tabelas
	Local _aTab	:= {"SA1"}
	// se criou o ambiente
	Local lEnv	:= .F.
	// inicio
	Local nStart:= Seconds()
	//fim
	Local nElap	:= 0
	
	// exibe no log
	Conout( cValToChar( Date() )+"-"+Time()+" KAP_WF03 - INICIO " )
	
	//prepare Environment Empresa cEmp Filial cFil Tables 'SA1'
	lEnv := environmentActions(1,_cEmp,_cFil,_cUs,_cPas,_cMod,_aTab)
	
	// inicia o processamento
	iniciarProc()
	
	nElap := Round(Seconds() - nStart,0)
	
	Conout( cValToChar( Date() )+"-"+Time()+" KAP_WF03 - TEMPO DECORRIDO "+cValToChar(nElap)+" segundos." )
	Conout( cValToChar( Date() )+"-"+Time()+" KAP_WF03 - FIM " )
	
	// se criou o ambiente
 	If lEnv
		// fecha o ambiente
		environmentActions(2)
	Endif

Return

/**********************************************************************************************************************************/
/** user function iniciarProc()                							                                                         **/
/** inicio do processamento.                                                                                                     **/
/**********************************************************************************************************************************/
static function iniciarProc()
	// area aberta
	Local aArea  	:= GetArea()
	// alias temporario
	Local cTemp		:= GetNextAlias()    
	//qtd de dias para se tornar inativo
	Local nQtdin	:= VAL( Alltrim( GetMV("MV_K_QTDIN") ) )
	//Observado que nestes casos o cliente deixa de ser representante e passar a ser da Kapazi  
	//Local cVdsit	:= Alltrim( GetMV("MV_K_VDSIT") )             
	// recno
	Local nRegno	:= 0

	// abre a tabela 
	SA1->( DBSetOrder(1) )
	// vai pro inicio 
	SA1->( DbGoTop() )

	// executa a query
	QryDados(cTemp)

	// vai pro inicio da query
	(cTemp)->(DbGoTop())
		
	// faz loop nos dados
	While !(cTemp)->( EOF() )
		
		// registro a ser alterado
		nRegno := (cTemp)->SA1RECNO
		
		// posiciona no registro
		SA1->( DbGoTo(nRegno))
		// valida se posicionou corretamente
		If SA1->( Recno()) == nRegno
		
			// trava o registro
			Reclock("SA1",.F.)
				
				// atualiza a data da ultima compra
				SA1->A1_K_ULTCO	:= STOD((cTemp)->ULTCOM)
		
				// se dias foi calculado
				If( (cTemp)->DIAS <> 99999999)
					// atualiza os dias da ultima compra
					SA1->A1_K_DIAIN := cValToChar( (cTemp)->DIAS )	
				EndIf
				
				// se faz mais dias pra bloquear
				If( (cTemp)->DIAS > nQtdin )
					// bloqueia o registro
					SA1->A1_K_SITCL :=	'B' 

					/*
					If !Empty (AllTrim ( (cTemp)->ULTCOM ) )
						SA1->A1_VEND :=	cVdsit 
					EndIf
					*/
				// se nao faz mais dias
				Else
					// desbloqueia o registro
					SA1->A1_K_SITCL :=	'A' 
				EndIf
			
			// desbtrava o registro
			MsUnLock("SA1")
		Endif
		// proximo registro
		(cTemp)->( DbSkip() )
	EndDo
	
	// fecha a area
	MyClose(cTemp)
	// fecha a area
	MyClose("SA1")

	// restaura a area
	RestArea(aArea)
	// sai da funcao
Return 

/**********************************************************************************************************************************/
/** Static Function QryDados                                                                                                     **/
/** executa a query                                                                                                              **/
/**********************************************************************************************************************************/  
Static Function QryDados(_cAlias)
	// query
	Local cQuery  := ""  

	// monta a query
	cQuery += "SELECT "+ENTER
	cQuery += "	( "+ENTER
	cQuery += "		SELECT	 "+ENTER
	cQuery += "			ISNULL(MIN(CONVERT(INT,DATEDIFF(DAY,CONVERT(DATE,SD21.D2_EMISSAO),GETDATE()))),'99999999') "+ENTER
	cQuery += "		FROM SD2STU SD21 WITH(NOLOCK) "+ENTER
	cQuery += "		WHERE	 "+ENTER
	cQuery += "			SD21.D2_CLIENTE = SA1.A1_COD "+ENTER
	cQuery += "			AND SD21.D2_LOJA = SA1.A1_LOJA "+ENTER
	cQuery += "	) DIAS "+ENTER
	cQuery += "	,( "+ENTER
	cQuery += "		SELECT MAX(SD24.D2_EMISSAO)	 "+ENTER
	cQuery += "		FROM SD2STU	SD24 "+ENTER
	cQuery += "		WHERE SD24.D2_CLIENTE = SA1.A1_COD "+ENTER
	cQuery += "			AND SD24.D2_LOJA = SA1.A1_LOJA "+ENTER
	cQuery += "	) ULTCOM "+ENTER
	cQuery += "	,SA1.A1_COD CLIENTE "+ENTER
	cQuery += "	,SA1.A1_LOJA LOJA "+ENTER
	cQuery += "	,SA1.R_E_C_N_O_ SA1RECNO "+ENTER
	cQuery += "FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE "+ENTER
	cQuery += "	SA1.D_E_L_E_T_ = '' "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY SA1RECNO "+ENTER
	
	// fecha a area
	MyClose(_cAlias)

	// executa a query              
	TcQuery cQuery New Alias (_cAlias)

	//retorna
Return


/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: environmentActions												                            **/
/** DESCRICAO		: cria o ambiente para uso                                                                 		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                      CRIACAO / ALTERACOES / MANUTENCOES                       	   				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	  | Descricao                             			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 19/03/2018 	| Luiz Henrique Jacinto  |                        |   												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** nOpc    	| opcao 1= cria,2=fecha                                                                            	**/
/** _cEmp    	| empresa a ser aberta                                                                             	**/
/** _cFil    	| filial a ser aberta                                                                              	**/
/** _cUs    	| usuario                                                                                          	**/
/** _cPas    	| senha                                                                                            	**/
/** _cMod    	| modulo                                                                                           	**/
/** _aTables   	| tabelas                                                                                          	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function environmentActions(nOpc,_cEmp,_cFil,_cUs,_cPas,_cMod,_aTables)
	Local 	lRet 		:= .F.
	// Nome da rotina que será setada para retorno da função FunName().
	Local	cFunName	:= "RPC"
	// Alimenta a variável publica lMsFinalAuto.
	Local	lShowFinal	:= .F.
	// gera mensagem de erro ao ocorrer erro ao checar a licença para a estação.
	Local	lAbend		:= .T.
	// pega a primeira filial do arquivo SM0 quando não passar a filial e realiza a abertura dos SXs
	Local	lOpenSX		:= .T.
	// Faz a abertura da conexao com servidor SQL Server
	Local	lConnect	:= .T.
	Local	cMsg		:= ""
	
	// valor inicial da operacao
	Default  nOpc	:= 1
	// valor inicial da empresa
	Default _cEmp	:= "01"
	// valor inicial da filial
	Default _cFil	:= "01"
	// valor inicial usuario
	Default _cUs	:= ""
	// valor inicial senha
	Default _cPas	:= ""
	// valor inicial modulo
	Default	_cMod	:= "FIS"
	// tabelas a serem abertas
	Default _aTables:= {"SM2"}
	
	// se inicia o ambiente
	If nOpc == 1
		// se ambiente nao esta criado
		If Select("SX2") <= 0  
			
			// se nao informou o usuario
			If Empty(AllTrim(_cUs))
				// nao consome licença
				RpcSetType( 3 )
			Endif
			
			conout(DtoC(Date())+" - "+Time()+" criando ambiente "+_cEmp+"/"+_cFil)

			// cria o ambiente
			RpcSetEnv( _cEmp, _cFil,_cUs,_cPas,_cMod,cFunName,_aTables,lShowFinal,lAbend,lOpenSX,lConnect )
			
			// atualiza o retorno
			lRet := .T.
			
		Else
			cMsg := (DtoC(Date())+" - "+Time()+" Ambiente ja criado "+cEmpAnt+"/"+cFilAnt+", solicitado "+_cEmp+"/"+_cFil)
			cMsg := (DtoC(Date())+" - "+Time()+" Ambiente ja criado "+cEmpAnt+"/"+cFilAnt+", solicitado "+_cEmp+"/"+_cFil)
			conout(cMsg)
		Endif
		
	// se fecha o ambiente
	Elseif nOpc == 2
		
		// limpa o ambiente
		RpcClearEnv()
		
	Endif
	
	// retorna se criou
Return lRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: myClose  															                            **/
/** DESCRICAO		: valida se a area esta aberta e fecha                                                   		**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function MyClose(_cAlias)
	// se area aberta	
	If Select(_cAlias) > 0
		//fecha a area
		(_cAlias)->( DbCloseArea() )
	Endif

	//retorna
Return