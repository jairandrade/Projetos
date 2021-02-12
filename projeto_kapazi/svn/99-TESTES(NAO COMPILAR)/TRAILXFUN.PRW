/**********************************************************************************************************************************/
/** RSAC TRAIL                                                                                                                   **/
/** Funcoes genericas                                                                                                           **/
/** Autor: Marcio Akira Sugahara                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 21/11/2017 |Marcio Akira Sugahara           | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
// teste brach
#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "protheus.ch"

/**********************************************************************************************************************************/
/** user function GetRetWms                                                                                                     **/
/** funcoes usada para o retorno padrao para o coletor                                                                          **/
/**********************************************************************************************************************************/
user function GetRetWms(lParamOk,cMsgRet,cDadosRetTipo,cDadosRet)
	local cParamOk   := "" 
	local cRet       := ""

	default lParamOk      := .F.
	default cMsgRet       := ""
	default cDadosRetTipo := "string"
	default cDadosRet     := ""


	if (lParamOk) 
		cParamOk := "OK" 
	else
		cParamOk := "NO"
	endif

	cRet := "<ParamOk>"+		cParamOk		+"</ParamOk> 
	cRet += "<MsgRet>"+			cMsgRet			+"</MsgRet>
	cRet += "<DadosRetTipo>"+	cDadosRetTipo	+"</DadosRetTipo>
	cRet += "<DadosRet>"+		cDadosRet		+"</DadosRet>
	
return cRet


/**********************************************************************************************************************************/
/** user function VarAmb                                                                                                     **/
/** carrega variaveis do ambiente do protheus.                                                                                  **/
/**********************************************************************************************************************************/
user function VarAmb(cUsrName,cCodEmp,cCodFil)                                              

	local lLoginOk := .F.  

	// variaveis utilizadas no login do protheus
	private cEmpAnt := cCodEmp
	private cFilAnt := cCodFil
	private dDatabase := MsDate()
	
	public cUserName := ""
	public __CUSERID := ""

	default cUsrName = ""

	//se nao foi informado sai do processo
	if !empty(cUsrName)

		// abre a tabela de empresas e parametros                                  
		OpenSm0( cCodEmp )

		//Ordem     Chave
		//1         ID
		//2         Nome                                 
		PswOrder(2)         
		lLoginOk := PswSeek(cUsrName, .T.)

		//se nao foi localizado pelo usuario, tenta localizar pelo codigo
		if (!lLoginOk)  
			//muda a ordem para o codigo                                                 
			PswOrder(1)
			//tenta localizar novamente 
			lLoginOk := PswSeek(cUsrName, .T.)
		endif                        


		// faz o login do usuário no protheus                                 
		if ( lLoginOk )  

			aPswReg := PswRet() 
			//recupera o username do usuario
			cUserName := aPswReg[1][2]  
			// recupera o código do usuário
			__CUSERID := PswId()
		endIf  
	endif  
return 


Static Function SqlCommand(cComando)
	Local cBDados 	:= TcGetDB()
	Local cRet		:= cComando

	iF cBDados == "MSSQL"

		If cComando == "TRIM"
			cRet := "RTRIM"
		ElseIf cComando == "NVL"
			cRet := "ISNULL"
		Endif

	ElseIf cDBDados == "ORACLE"

		If cComando == "RTRIM"
			cRet := "TRIM"
		ElseIf cComando == "ISNULL"
			cRet := "NVL"
		Endif

	Endif


Return cRet


Static Function SqlTableNa(cTable)
	Local 	cRet	:= ""
	Local 	cBDados	:= TcGetDB() 

	Default cTable 	:= ""

	iF cBDados == "MSSQL"

		cRet := "dbo."+cTable

	ElseIf cDBDados == "ORACLE"

		cRet := "TRAIL."+cTable

	Endif

Return cRet


Static Function criaSXBFn(_cF3,_cTitulo,_cTabela,_cFuncao,_aRetorno)
	Local aArea := GetArea()
	Local nX	:= 0

	SXB->( DbSetOrder(1) )
	If !SXB->( MsSeek(_cF3))
		RecLock("SXB",.T.)
		SXB->XB_ALIAS 	:= _cF3
		SXB->XB_TIPO	:= '1'
		SXB->XB_SEQ		:= '01'
		SXB->XB_COLUNA	:= "RE"
		SXB->XB_DESCRI	:= _cTitulo
		SXB->XB_DESCSPA	:= _cTitulo
		SXB->XB_DESCENG	:= _cTitulo
		SXB->XB_CONTEM	:= _cTabela 
		MsUnLock("SXB")
		RecLock("SXB",.T.)
		SXB->XB_ALIAS 	:= _cF3
		SXB->XB_TIPO	:= '2'
		SXB->XB_SEQ		:= '01'
		SXB->XB_COLUNA	:= "01"
		SXB->XB_CONTEM	:= _cFuncao 
		MsUnLock("SXB")

		For nX := 1 to Len(_aRetorno)
			RecLock("SXB",.T.)
			SXB->XB_ALIAS 	:= _cF3
			SXB->XB_TIPO	:= '5'
			SXB->XB_SEQ		:= StrZero(nX,2)
			SXB->XB_CONTEM	:= _aRetorno[nX] 
			MsUnLock("SXB")	
		Next

	Endif

	RestArea(aArea)
Return 


static Function criaSX6(_cFil,_cPar,_cTipo,xValor,cDescr)
	Local aArea 	:= GetArea()
	Local cDesc1	:= ""
	Local cDesc2	:= ""
	Local cDesc3	:= ""

	cDesc1	:= Substr(cDescr,001,50)
	If Len(cDescr) > 50
		cDesc2	:= Substr(cDescr,051,50)
	Endif

	If Len(cDescr) > 100 
		cDesc3	:= Substr(cDescr,101,50)
	Endif

	SX6->( DbSetOrder(1) )
	If !SX6->( MsSeek(_cFil+_cPar,.T.))
		RecLock("SX6",.T.)
		SX6->X6_FIL 	:= _cFil
		SX6->X6_VAR		:= _cPar
		SX6->X6_TIPO	:= _cTipo
		SX6->X6_CONTEUD	:= cValToChar(xValor)
		SX6->X6_CONTSPA	:= cValToChar(xValor)
		SX6->X6_CONTENG	:= cValToChar(xValor)
		SX6->X6_PROPRI	:= "U"
		SX6->X6_PYME	:= ""
		SX6->X6_DESCRIC	:= cDesc1
		SX6->X6_DESC1	:= cDesc2
		SX6->X6_DESC2	:= cDesc3
		SX6->X6_DSCSPA	:= cDesc1
		SX6->X6_DSCSPA1	:= cDesc2
		SX6->X6_DSCSPA2	:= cDesc3
		SX6->X6_DSCENG	:= cDesc1
		SX6->X6_DSCENG1	:= cDesc2
		SX6->X6_DSCENG2	:= cDesc3
		MsUnLock("SX6")
	Endif

	RestArea(aArea)
Return


Static Function TGetMv(_cFil,_cPar,_cTipo,xValor,cDescr)

	criaSX6(_cFil,_cPar,_cTipo,xValor,cDescr)

Return GetMv(_cPar,,xValor)

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: newEnvir												                                        **/
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
Static Function newEnvir(nOpc,_cEmp,_cFil,_cUs,_cPas,_cMod,_aTables)
	Local 	lRet 		:= .F.
	// Código da empresa.
	Local	cRpcEmp		:= ""
	//Código da filial
	Local	cRpcFil		:= ""
	// Nome do usuário.
	Local	cEnvUser	:= ""
	// Senha do usuário.
	Local	cEnvPass	:= ""
	// Código do módulo.
	Local	cEnvMod		:= ""
	// Nome da rotina que será setada para retorno da função FunName().
	Local	cFunName	:= "RPC"
	// Array contendo as tabelas a serem abertas.
	Local 	aTables		:= {}
	// Alimenta a variável publica lMsFinalAuto.
	Local	lShowFinal	:= .F.
	// gera mensagem de erro ao ocorrer erro ao checar a licença para a estação.
	Local	lAbend		:= .T.
	// pega a primeira filial do arquivo SM0 quando não passar a filial e realiza a abertura dos SXs
	Local	lOpenSX		:= .T.
	// Faz a abertura da conexao com servidor SQL Server
	Local	lConnect	:= .T.
	
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
	
	// empresa
	cRpcEmp		:= _cEmp
	// filial
	cRpcFil		:= _cFil
	// Nome do usuário.
	cEnvUser	:= _cUs
	// Senha do usuário.
	cEnvPass	:= _cPas
	// Código do módulo.
	cEnvMod		:= _cMod
	// tabelas
	aTables		:= _aTables
	
	// se inicia o ambiente
	If nOpc == 1
		// se ambiente nao esta criado
		If Select("SX2") <= 0  
			
			// se nao informou o usuario
			If Empty(AllTrim(cEnvUser))
				// nao consome licença
				RpcSetType( 3 )
			Endif
			// exibe no log
			conout(dtoc(date())+'|'+time()+" | Utilizando empresa " + cRpcEmp + " filial " + cRpcFil)
			// cria o ambiente
			RpcSetEnv( cRpcEmp, cRpcFil,cEnvUser,cEnvPass,cEnvMod,cFunName,aTables,lShowFinal,lAbend,lOpenSX,lConnect )
			
			// atualiza o retorno
			lRet := .T.
			
		Endif/
		
	// se fecha o ambiente
	Elseif nOpc == 2
		
		// limpa o ambiente
		RpcClearEnv()
		
	Endif
	
	// retorna se criou
Return lRet





