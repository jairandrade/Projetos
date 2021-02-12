#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

//==================================================================================================//
//	Programa: SPROCZPV 	|	Autor: Luis Paulo									|	Data: 08/04/2018//
//==================================================================================================//
//	Descrição: Funcao de integração da NF Mista - ZPV				  								//
//																									//
//==================================================================================================//
User Function SPROCZPV()
	
Prepare Environment Empresa "04" Filial "01"
U_ATUALZPV() 

Return()


User Function ATUALZPV()
Local	cData		:= DTOS((Date()))
Local	cHora		:= Time()
Private	oError 		:= ErrorBlock({|e| cRet := GetErrorBlk(e:Description)})
Private cUDTSinc 	:= GetMv("KP_DTSZPV")
Private cUHRSinc 	:= GetMv("KP_HRSZPV")
Private cErrTo 		:= GetNewPar("KP_CNTERR", "luis@rsacsolucoes.com.br")
Private cCRLF		:= CRLF

Conout("")
ConOut("[" + Dtoc(Date()) + " " + Time() + "Sincronizacao de Dados da ZPV...")
ConOut("Ultima sincronizacao: " + cUDTSinc + " - " +cUHRSinc)
Conout("")

PutMV("KP_DTSZPV", cData)
PutMV("KP_HRSZPV", cHora)

Begin Sequence
	AExcProd(IsBlind())
	AExcCli(IsBlind())
End Sequence
Conout("Terminou!!")
//Captura de erro
ErrorBlock(oError)

Return()


/**********************************************************************************************************************************/
/** Static Function AExcCli(IsBlind())                                                                      			 		 **/
/** Funcao para processamento dos CLIENTES					                                                                     **/
/**********************************************************************************************************************************/
Static Function AExcCli(lBlind)
Private cAliasA1 		
Private nRegsA1	:= 0

Conout("")
Conout("Iniciando o processamento de clientes!!!")

If QryCli(lBlind) //recupera os dados dos Clientes desde a ultima integração, buscando os dados do MySql
		Conout("")
		Conout("Nao existem clientes para sincronizar no momento!!!")
		cAliasA1->(DbCloseArea())
		
	Else
		Conout("")
		Conout("Sincronizando clientes( "+ cValTochar(nRegsA1) +" )!!! Aguarde...")
		cAliasA1->(DbGoTop())
		
		While !cAliasA1->(EOF())
			
			If cAliasA1->A1_XGERASV != 'S' //Inclui relacionamento
				//Exclui o relacionamento
				xLimpaCli(cAliasA1->A1_COD,cAliasA1->A1_XDATASV,cAliasA1->A1_XHORASV,cAliasA1->A1_XQUEMSV) //Limpa qualquer relacionamento do cliente(Assim trata as alteracoes)
			EndIf
			cAliasA1->(DbSkip())	
		EndDo
		
		cAliasA1->(DbCloseArea())	
EndIf

Return()

/**********************************************************************************************************************************/
/** static function QryCli()                                                                       								 **/
/** Recupera os Clientes 					                                                                                	 **/
/**********************************************************************************************************************************/
Static Function QryCli()
Local cQr := ""

If Select("cAliasA1") <> 0
	DBSelectArea("cAliasA1")
	cAliasA1->(DBCloseArea())
Endif

cAliasA1 	:= GetNextAlias()

// define a query de Clientes atualizados
cQr += " SELECT A1_COD,A1_LOJA,A1_XGERASV,A1_XPERSV,A1_XFLAGSV,A1_XDATASV,A1_XHORASV,A1_XQUEMSV
cQr += " FROM SA1010
cQr += " WHERE A1_XFLAGSV = 'X'
cQr += " AND A1_XDATASV + ' ' +  A1_XHORASV >= '"+cUDTSinc+" "+cUHRSinc+"'
cQr += " AND D_E_L_E_T_ = ''

//Conout("")
//Conout(cQr)
//Conout("")

TcQuery cQr new alias "cAliasA1"
Count to nRegsA1

cAliasA1->(DbGoTop())
Return(cAliasA1->(EOF()))

/**********************************************************************************************************************************/
/** static function AExcProd()                                           	                                           			 **/
/** função para limpar os relacionamentos de produtos deletados`		                                                         **/
/**********************************************************************************************************************************/
Static Function AExcProd()
Local cQr 		:= ""
Local cCodZPV	:= ""
Local cAliasB1
Private nRegsB1	:= 0

If Select("cAliasB1") <> 0
	DBSelectArea("cAliasB1")
	cAliasB1->(DBCloseArea())
Endif

cAliasB1 	:= GetNextAlias()

Conout("")
Conout("Iniciando o processamento de produtos!!!")

If QryPExc() 
		Conout("")
		Conout("Nao existem produtos para excluir sincronizar no momento!!!")
		cAliasB1->(DbCloseArea())
		
	Else
		Conout("")
		Conout("Sincronizando produtos: ("+ cValTochar(nRegsB1) +")!!! Aguarde...")
		While !cAliasB1->(EOF())
			
			If cAliasB1->B1_XGERASV != 'S' 		//Inclui relacionamento
				//Exclui o relacionamento
				xLimpaPro(cAliasB1->B1_COD,cAliasB1->B1_XDATASV,cAliasB1->B1_XHRSV,cAliasB1->B1_XQUEMSV) //Limpa qualquer relacionamento do produto(Assim trata as alteracoes)
			EndIf
			
			cAliasB1->(DbSkip())	
		EndDo
		cAliasB1->(DBCloseArea())
EndIf

Return()

/**********************************************************************************************************************************/
/** static function QryPExc()                                                                       								 **/
/** Recupera os Produtos 					                                                                                	 **/
/**********************************************************************************************************************************/
Static Function QryPExc()
Local cQr := ""

If Select("cAliasB1") <> 0
	DBSelectArea("cAliasB1")
	cAliasB1->(DBCloseArea())
Endif

cAliasB1 	:= GetNextAlias()

cQr += " SELECT B1_COD,B1_XGERASV,B1_XFLAGSV,B1_XDATASV,B1_XHRSV,B1_XQUEMSV
cQr += " FROM SB1010
cQr += " WHERE B1_XFLAGSV = 'X'
cQr += " AND B1_XDATASV + ' ' + B1_XHRSV >= '"+cUDTSinc+" "+cUHRSinc+"'
cQr += " AND D_E_L_E_T_ = ''

//Conout("")
//Conout(cQr)
//Conout("")

TcQuery cQr new alias "cAliasB1"
Count to nRegsB1

cAliasB1->(DbGoTop())
Return(cAliasB1->(EOF()))



/**********************************************************************************************************************************/
/** static function xLimpaPro()                                                                                      			 **/
/** função para limpar os relacionamentos de produtos					                                                         **/
/**********************************************************************************************************************************/
Static Function xLimpaPro(cB1COD,cDataOri,cHoraOri,cQuem)
Local	cQr	:= ""

cQr += " UPDATE ZPV040
cQr += " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_ = R_E_C_N_O_,ZPV_QUEMEX = '"+cQuem+"',ZPV_DATAEX = '"+cDataOri+"', ZPV_HORAEX = '"+cHoraOri+"', ZPV_ORIEXC = 'SB1'
cQr += " WHERE D_E_L_E_T_ = '' 
cQr += " AND ZPV_PROD = '"+cB1COD+"'

If TcSqlExec(cQr)
	Conout("Erro Qry linha 339")
EndIf


Return()

/**********************************************************************************************************************************/
/** static function xLimpaCli()                                                                                      			 **/
/** função para limpar os relacionamentos de produtos					                                                         **/
/**********************************************************************************************************************************/
Static Function xLimpaCli(cA1COD,cDataOri,cHoraOri,cQuem)
Local	cQr	:= ""

cQr += " UPDATE ZPV040
cQr += " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_ = R_E_C_N_O_,ZPV_QUEMEX = '"+cQuem+"',ZPV_DATAEX = '"+cDataOri+"', ZPV_HORAEX = '"+cHoraOri+"', ZPV_ORIEXC = 'SA1'
cQr += " WHERE D_E_L_E_T_ = '' 
cQr += " AND ZPV_CLIENT = '"+cA1COD+"'

If TcSqlExec(cQr)
	Conout("Erro Qry linha 359")
EndIf

Return()

/**********************************************************************************************************************************/
/** static function GetErrorBlk(cErrorDesc)                                                                                      **/
/** função para contenção de erros durante o processamento de macros                                                             **/
/**********************************************************************************************************************************/
Static Function GetErrorBlk(cErrorDesc)
// variaveis auxiliares
Local cMsgErro 		:= cErrorDesc
Local cErroMail 	:= "Teste"
Local cErrTo 		:= GetNewPar("KP_CNTERR", "luis@rsacsolucoes.com.br")
Local lErro 		:= .F.

// mostra o erro de sincronização
Conout("Erro na sincronização: " + cMsgErro)

// envia e-mail de erro
//U_MailTo(cErrTo, "Erro na sincronizacao da ZPV - Kapazi!!!", cMsgErro, "", cErroMail)

// sai do procedimento
Break

Return Nil