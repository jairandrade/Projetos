#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: SCHDCHVM 	|	Autor: Luis Paulo																				|	Data: 23/01/2018//
//==================================================================================================//
//	Descrição: Funcao de integração de chaves NF para SPED050    		  															//
//																																																	//
//==================================================================================================//

User function SCHDCHVM()

Prepare Environment Empresa "01" Filial "01"

U_SCHDCHVA()

Return Nil


User Function SCHDCHVA()
Local 	oError 			:= ErrorBlock({|e| cRet := GetErrorBlk(e:Description)})
Local 	nConWebshop := 0
Private cCRLF			:= CRLF

Conout("")
Conout("*** INICIANDO SINC DE CHAVES DE NF KAPAZI X SPE050 (MADEIRA MADEIRA) ***")
Conout("")

//Inicia a sequencia de erro
Begin Sequence

SinChaves(IsBlind())

//Finaliza a sequencia de erro
End Sequence

// captura de erro
ErrorBlock(oError)

Return()


/**********************************************************************************************************************************/
/** Executa a sincronização da tabela                                                                                            **/
/**********************************************************************************************************************************/
Static Function SinChaves(lBlind)
Local 	cUltSinc 		:= GetMv("KP_DTHSCHV")
Local 	cErrTo 			:= GetNewPar("KP_CNTERR", "luis@rsacsolucoes.com.br")
Local		nRegs 			:= 0
Local 	nConWebshop := 0
Local 	cAtuSinc 		:= Dtos(Date()) + " " + Time()

//Mostra o console
Conout("[" + Dtoc(Date()) + " " + Time() + " Sincronizacao do chv nf madeira madeira...")

// mostra a ultima sincronização
Conout("Ultima sincronizacao ocorreu: " + cUltSinc)
Conout("")

//Funcao que atualiza no protheus, qualquer mudança realizada na Web
AFil0401(cUltSinc, lBlind, @nRegs)

//Funcão que atualiza no CRM qualquer mudança realizada no protheus.
AFil0101(cUltSinc, lBlind, @nRegs)

PutMV("KP_DTHSCHV", cAtuSinc)

Return()



/**********************************************************************************************************************************/
/** Grava as chaves na empresa 04-01							 					                                                                     **/
/**********************************************************************************************************************************/
Static Function AFil0401(cUltSinc, lBlind, nRegs)
Local cQr 				:= ""
Local aArea 			:= GetArea()
Local cDataMy 		:= ""
Local _cNumA
Local nConWebshop := 0
Local lErro 			:= .F.

If Select("cAliasSI") <> 0
	DBSelectArea("cAliasSI")
	cAliasSI->(DBCloseArea())
Endif

cAliasSI		:= GetNextAlias()


//Define a query
cQr += " SELECT SF2.R_E_C_N_O_ AS RECOSF2,S050.R_E_C_N_O_ AS RECO050, SUBSTRING(NFE_ID,1,3) AS SERIE,RTRIM(SUBSTRING(NFE_ID,4,40)) AS NUMNF,SF2.F2_FILIAL, SF2.F2_DOC,SF2.F2_SERIE,S050.DOC_CHV,SF2.F2_CHVNFE,* "+cCRLF
cQr += " FROM NFE0401.dbo.SPED050 AS S050 "+cCRLF
cQr += " INNER JOIN P12_PROD.dbo.SF2040 AS SF2 ON SUBSTRING(NFE_ID,1,3) = SF2.F2_SERIE AND RTRIM(SUBSTRING(NFE_ID,4,40)) = SF2.F2_DOC AND SF2.F2_FILIAL = '01' AND SF2.D_E_L_E_T_ = '' AND SF2.F2_SINCCHV = ''"+cCRLF
cQr += " WHERE S050.DATE_NFE > '20180122' "+cCRLF
cQr += "	AND S050.AMBIENTE = '1'					"+cCRLF
cQr += "	AND S050.MODALIDADE = '1'				"+cCRLF
cQr += "	AND S050.STATUS = '6'						"+cCRLF
cQr += "	AND S050.STATUSCANC = '0'				"+cCRLF
cQr += "	AND S050.DOC_ID = ''						"+cCRLF
cQr += "	AND S050.DOC_SERIE = ''					"+cCRLF
cQr += "	AND S050.DOC_CHV = ''						"+cCRLF
cQr += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC,SF2.F2_SERIE "+cCRLF



//Abre a query
TcQuery cQr new alias "cAliasSI"
Count to nRegs
cAliasSI->(DbGoTop())

//Inicia a barra de progresso
If !lBlind
   ProcRegua(nRegs)
   ProcessMessages()
EndIf

//Verifica a qtd de registros
If nRegs == 0
  	ConOut("Nenhuma chave para sincronizar 04/01.")
  	ConOut("")
EndIf


While !cAliasSI->(EOF())
	
	
	If !Empty(cAliasSI->RECO050) .AND. !Empty(cAliasSI->RECOSF2)
		
		cUpd := " UPDATE NFE0401.dbo.SPED050 "+cCRLF
		cUpd += " SET DOC_CHV = '" + cAliasSI->F2_CHVNFE + "' 					"+cCRLF
		cUpd += " WHERE R_E_C_N_O_ = "+ cValToChar(cAliasSI->RECO050) +"	"+cCRLF
		cUpd += " AND DOC_CHV = '' "+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da SPED050")
			lErro	:= .T.
		EndIf
		
		If !lErro
			
			cUpd := " UPDATE SF2040					"+cCRLF
			cUpd += " SET F2_SINCCHV = 'S'	"+cCRLF	
			cUpd += " WHERE R_E_C_N_O_ = "+ cValToChar(cAliasSI->RECOSF2) +"	"+cCRLF
			cUpd += "				AND F2_FILIAL = '01'	"+cCRLF
			
			//Conout(cUpd)
			If TcSqlExec(cUpd) < 0
				Conout("Erro na Query da SF2")
			EndIf
			
		EndIf
		
		If !lErro 
			Conout("Chave da NF atualizada com sucesso!! -> NF: " + cAliasSI->F2_DOC + " -- SERIE: " + cAliasSI->F2_SERIE )
		EndIf
		
		lErro	:= .F.
		
	EndIf
	
	cAliasSI->(DbSkip())
EndDo


cAliasSI->(DbCloseArea())
RestArea(aArea)
Return


/**********************************************************************************************************************************/
/** Grava as chaves na empresa 01-01							 					                                                                     **/
/**********************************************************************************************************************************/
Static Function AFil0101(cUltSinc, lBlind, nRegs)
Local cQr 				:= ""
Local aArea 			:= GetArea()
Local cDataMy 		:= ""
Local _cNumA
Local nConWebshop := 0
Local lErro 			:= .F.
Local cUpd 				:= ""

If Select("cAliasSI") <> 0
	DBSelectArea("cAliasSI")
	cAliasSI->(DBCloseArea())
Endif

cAliasSI		:= GetNextAlias()


//Define a query
cQr += " SELECT SF2.R_E_C_N_O_ AS RECOSF2,S050.R_E_C_N_O_ AS RECO050, SUBSTRING(NFE_ID,1,3) AS SERIE,RTRIM(SUBSTRING(NFE_ID,4,40)) AS NUMNF,SF2.F2_FILIAL, SF2.F2_DOC,SF2.F2_SERIE,S050.DOC_CHV,SF2.F2_CHVNFE,* "+cCRLF
cQr += " FROM NFE0101.dbo.SPED050 AS S050 "+cCRLF
cQr += " INNER JOIN P12_PROD.dbo.SF2010 AS SF2 ON SUBSTRING(NFE_ID,1,3) = SF2.F2_SERIE AND RTRIM(SUBSTRING(NFE_ID,4,40)) = SF2.F2_DOC AND SF2.F2_FILIAL = '01' AND SF2.D_E_L_E_T_ = '' AND SF2.F2_SINCCHV = '' "+cCRLF
cQr += " WHERE S050.DATE_NFE > '20180122' "+cCRLF
cQr += "	AND S050.AMBIENTE = '1'					"+cCRLF
cQr += "	AND S050.MODALIDADE = '1'				"+cCRLF
cQr += "	AND S050.STATUS = '6'						"+cCRLF
cQr += "	AND S050.STATUSCANC = '0'				"+cCRLF
cQr += "	AND S050.DOC_ID = ''						"+cCRLF
cQr += "	AND S050.DOC_SERIE = ''					"+cCRLF
cQr += "	AND S050.DOC_CHV = ''						"+cCRLF
cQr += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC,SF2.F2_SERIE "+cCRLF

//Conout(cQr)
//Abre a query
TcQuery cQr new alias "cAliasSI"
Count to nRegs
cAliasSI->(DbGoTop())

//Inicia a barra de progresso
If !lBlind
   ProcRegua(nRegs)
   ProcessMessages()
EndIf

//Verifica a qtd de registros
If nRegs == 0
  	ConOut("Nenhuma chave para sincronizar 01/01.")
  	ConOut("")
EndIf


//A cada registro de cabecalho, grava n registros de itens
While !cAliasSI->(EOF())
	
	If !Empty(cAliasSI->RECO050) .AND. !Empty(cAliasSI->RECOSF2)
	
		cUpd := " UPDATE NFE0101.dbo.SPED050 "+cCRLF
		cUpd += " SET DOC_CHV = '" + cAliasSI->F2_CHVNFE + "' 					"+cCRLF
		cUpd += " WHERE R_E_C_N_O_ = "+ cValToChar(cAliasSI->RECO050) +"	"+cCRLF
		cUpd += " AND DOC_CHV = '' "+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query")
			lErro	:= .T.
		EndIf
		
		If !lErro
			
			cUpd := " UPDATE SF2010					"+cCRLF
			cUpd += " SET F2_SINCCHV = 'S'	"+cCRLF	
			cUpd += " WHERE R_E_C_N_O_ = "+ cValToChar(cAliasSI->RECOSF2) +"	"+cCRLF
			cUpd += "				AND F2_FILIAL = '01'	"+cCRLF
			
			//Conout(cUpd)
			If TcSqlExec(cUpd) < 0
				Conout("Erro na Query da SF2")
			EndIf
			
		EndIf
		
		If !lErro 
			Conout("Chave da NF atualizada com sucesso!! -> NF: " + cAliasSI->F2_DOC + " -- SERIE: " + cAliasSI->F2_SERIE )
		EndIf
		
		lErro	:= .F.
		
	EndIf
	cAliasSI->(DbSkip())
	
EndDo

cAliasSI->(DbCloseArea())
RestArea(aArea)
Return




/**********************************************************************************************************************************/
/** static function GetErrorBlk(cErrorDesc)                                                                                      **/
/** função para contenção de erros durante o processamento de macros                                                             **/
/**********************************************************************************************************************************/
Static Function GetErrorBlk(cErrorDesc)
Local cMsgErro 	:= cErrorDesc
Local cErroMail := ""
Local cErrTo 		:= GetNewPar("KP_CNTERR", "luis@rsacolucoes.com.br")
Local lErro 		:= .F.

// mostra o erro de sincronização
Conout("Erro na sincronização: " + cMsgErro)

// envia e-mail de erro
//U_MailTo(cErrTo, "Sincronização de Agendas", cMsgErro, "", cErroMail)

// sai do procedimento
Break

Return Nil

