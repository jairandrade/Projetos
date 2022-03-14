#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: SCHVTCD 	|	Autor: Luis Paulo							|	Data: 23/01/2018		//
//==================================================================================================//
//	Descrição: Funcao de integração de chaves NF para SPED050    									//
//																									//
//==================================================================================================//

User function SCHVTCD()

Prepare Environment Empresa "04" Filial "01"

U__SCHVTCD()

Return Nil


User Function _SCHVTCD()
Local 	oError 		:= ErrorBlock({|e| cRet := GetErrorBlk(e:Description)})
Local 	nConWebshop := 0
Private cCRLF		:= CRLF

Private cCliCD01	:=  Alltrim( SuperGetMV("KP_CLICD01"	,.F. ,"092693")) //0401 A1_CGC = '80051824000987' Cliente que será o CD que será usado na filial 0401 para tranf para a 0408(CD)
Private cCliLJ01	:=  Alltrim( SuperGetMV("KP_CLILJ01"	,.F. ,"01"))

Private cFORCD01	:=  Alltrim( SuperGetMV("KP_FORCD01"	,.F. ,"000018")) //0401 A2_CGC = '80051824000120' Fornecedor que será a KI que será usado para dar entrada na NF de entrada no CD 0408
Private cFORLJ01	:=  Alltrim( SuperGetMV("KP_FORLJ01"	,.F. ,"20"))

Private cCliCD08	:=  Alltrim( SuperGetMV("KP_CLICD08"	,.F. ,"007484")) //0408 A1_CGC = '80051824000120' Cliente KI que será usado no pedido de saida na 0408 para depois da entrada na 0401
Private cCliLJ08	:=  Alltrim( SuperGetMV("KP_CLILJ08"	,.F. ,"20"))

Private cFORCD08	:=  Alltrim( SuperGetMV("KP_FORCD08"	,.F. ,"338616")) //0408 A2_CGC = '80051824000987' Fornecedor que será o CD que será usado para dar entrada na NF de entrada no CD 0401  
Private cFORLJ08	:=  Alltrim( SuperGetMV("KP_FORLJ08"	,.F. ,"09"))	

Conout("")
Conout("*** SINCRONIZANDO CHAVES DA 0401 ---> 0408 ***")
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
Local 	cErrTo 			:= GetNewPar("KP_CNTERR", "luis@rsacsolucoes.com.br")
Local	nRegs 			:= 0
Local 	cAtuSinc 		:= Dtos(Date()) + " " + Time()

//Mostra o console
Conout("[" + Dtoc(Date()) + " " + Time() + " Sincronizacao do chv nf CENTRO DE DISTRIBUICAO...")

// mostra a ultima sincronização
Conout("")

//Funcao que atualiza a chave na 0408 de acordo com a 0401
VCHV0108(lBlind, @nRegs)

//Funcao que atualiza a chave na 0401 de acordo com a 0408
VCHV0801(lBlind, @nRegs)


Return()



/**********************************************************************************************************************************/
/** Grava as chaves na empresa 04-01							 					                                                                     **/
/**********************************************************************************************************************************/
Static Function VCHV0108(lBlind, nRegs)
Local aArea 		:= GetArea()
Local cAliasCH		:= GetNextAlias()
Local aLastQuery    := {}
Local cLastQuery    := ""

BeginSql Alias cAliasCH

    SELECT *
		FROM 
			(
			SELECT	SF2.F2_CHVNFE,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,(REPLICATE('0',3-LEN(SF2.F2_SERIE)) + SF2.F2_SERIE) AS SERIE,SF2.F2_XIDTRFP,
					ISNULL(SF1.F1_CHVNFE,'')F1_CHVNFE,ISNULL(SF1.F1_DOC,'')F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_XIDTRFP,SF1.R_E_C_N_O_ AS SF1RECO
			FROM SF2040 SF2 (NOLOCK)
			LEFT JOIN SF1040 SF1 (NOLOCK) ON SF1.F1_FILIAL = '08' AND SF2.F2_DOC = SF1.F1_DOC AND SF2.F2_SERIE  = SF1.F1_SERIE AND SF2.F2_XIDTRFP = SF1.F1_XIDTRFP AND SF1.F1_FORNECE = %EXP:cFORCD01%  AND SF1.F1_LOJA = %EXP:cFORLJ01%  AND SF1.D_E_L_E_T_ = ''
			WHERE SF2.D_E_L_E_T_ = ''
			AND SF2.F2_FILIAL = '01'
			AND SF2.F2_CLIENTE = %EXP:cCliCD01% 
			AND SF2.F2_LOJA = %EXP:cCliLJ01%
			AND SF2.F2_XIDTRFP <> '' 
			)CHAVE
	WHERE F1_CHVNFE = ''
	AND F1_DOC <> ''

EndSql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasCH))
(cAliasCH)->(DbGoTop())

//Verifica a qtd de registros
If (cAliasCH)->(EOF())
		ConOut("Nenhuma chave para sincronizar 0401 --> 0408")
		ConOut("")
	else
		ConOut("Chaves localizadas para sincronizar 0401 --> 0408")
		ConOut("")
EndIf


While !(cAliasCH)->(EOF())
	
	
	If !Empty((cAliasCH)->F1_DOC) .AND. !Empty((cAliasCH)->F2_CHVNFE)
		
		cUpd := " UPDATE SF1040 SET F1_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE F1_FILIAL = '08'			"+cCRLF
		cUpd += " AND F1_TIPO = 'N'					"+cCRLF
		cUpd += " AND F1_FORNECE = '"+cFORCD01+"'	"+cCRLF
		cUpd += " AND F1_LOJA = '"+cFORLJ01+"'		"+cCRLF
		cUpd += " AND F1_SERIE = '2'				"+cCRLF	
		cUpd += " AND F1_DOC = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND F1_CHVNFE = ''		"+cCRLF
		cUpd += " AND F1_XIDTRFP <> ''		"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0408")
		EndIf
		
		cUpd := " UPDATE SFT040 SET FT_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE FT_FILIAL = '08'			"+cCRLF
		cUpd += " AND FT_CLIEFOR = '"+cFORCD01+"'	"+cCRLF
		cUpd += " AND FT_LOJA = '"+cFORLJ01+"'		"+cCRLF
		cUpd += " AND FT_SERIE = '2'				"+cCRLF	
		cUpd += " AND FT_NFISCAL = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND FT_CHVNFE = ''		"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0408")
		EndIf

		cUpd := " UPDATE SF3040 SET F3_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE F3_FILIAL = '08'			"+cCRLF
		cUpd += " AND F3_CLIEFOR = '"+cFORCD01+"'	"+cCRLF
		cUpd += " AND F3_LOJA = '"+cFORLJ01+"'		"+cCRLF
		cUpd += " AND F3_SERIE = '2'				"+cCRLF	
		cUpd += " AND F3_NFISCAL = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND F3_CHVNFE = ''				"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0408")
		EndIf
		
		ConOut("Update realizado -->>>"+ (cAliasCH)->F2_DOC)
	EndIf
	
	ConOut((cAliasCH)->F2_DOC)
	
	(cAliasCH)->(DbSkip())
EndDo


(cAliasCH)->(DbCloseArea())
RestArea(aArea)
Return


/**********************************************************************************************************************************/
/** Grava as chaves na empresa 01-01							 					                                                                     **/
/**********************************************************************************************************************************/
Static Function VCHV0801(lBlind, nRegs)
Local aArea 		:= GetArea()
Local cAliasCH		:= GetNextAlias()
Local aLastQuery    := {}
Local cLastQuery    := ""

BeginSql Alias cAliasCH

    SELECT *
		FROM 
			(
			SELECT	SF2.F2_CHVNFE,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,(REPLICATE('0',3-LEN(SF2.F2_SERIE)) + SF2.F2_SERIE) AS SERIE,SF2.F2_XIDTRFP,
					ISNULL(SF1.F1_CHVNFE,'')F1_CHVNFE,ISNULL(SF1.F1_DOC,'')F1_DOC,SF1.F1_SERIE,SF1.F1_FORNECE,SF1.F1_LOJA,SF1.F1_XIDTRFP,SF1.R_E_C_N_O_ AS SF1RECO
			FROM SF2040 SF2 (NOLOCK)
			LEFT JOIN SF1040 SF1 (NOLOCK) ON SF1.F1_FILIAL = '01' AND SF2.F2_DOC = SF1.F1_DOC AND SF2.F2_SERIE  = SF1.F1_SERIE AND SF2.F2_XIDTRFP = SF1.F1_XIDTRFP AND SF1.F1_FORNECE = %EXP:cFORCD08%  AND SF1.F1_LOJA = %EXP:cFORLJ08% AND SF1.D_E_L_E_T_ = ''
			WHERE SF2.D_E_L_E_T_ = ''
			AND SF2.F2_FILIAL = '08'
			AND SF2.F2_CLIENTE = %EXP:cCliCD08% 
			AND SF2.F2_LOJA = %EXP:cCliLJ08%
			AND SF2.F2_XIDTRFP <> ''
			)CHAVE
	WHERE F1_CHVNFE = ''
	AND F1_DOC <> ''

EndSql

aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]

DbSelectArea((cAliasCH))
(cAliasCH)->(DbGoTop())

//Verifica a qtd de registros
If (cAliasCH)->(EOF())
  	ConOut("Nenhuma chave para sincronizar 0408 --> 0401.")
  	ConOut("")
EndIf


While !(cAliasCH)->(EOF())
	
	
	If !Empty((cAliasCH)->F1_DOC) .AND. !Empty((cAliasCH)->F2_CHVNFE)

		cUpd := " UPDATE SF1040 SET F1_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE F1_FILIAL = '01'	"+cCRLF
		cUpd += " AND F1_TIPO = 'N'			"+cCRLF
		cUpd += " AND F1_FORNECE = '"+cFORCD08+"'	"+cCRLF 
		cUpd += " AND F1_LOJA = '"+cFORLJ08+"'		"+cCRLF 
		cUpd += " AND F1_SERIE = '2'		"+cCRLF	
		cUpd += " AND F1_DOC = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND F1_CHVNFE = ''		"+cCRLF
		cUpd += " AND F1_XIDTRFP <> ''		"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0401")
			lErro	:= .T.
		EndIf
		
		cUpd := " UPDATE SFT040 SET FT_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE FT_FILIAL = '01'	"+cCRLF
		cUpd += " AND FT_CLIEFOR = '"+cFORCD08+"'	"+cCRLF
		cUpd += " AND FT_LOJA = '"+cFORLJ08+"'		"+cCRLF
		cUpd += " AND FT_SERIE = '2'				"+cCRLF	
		cUpd += " AND FT_NFISCAL = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND FT_CHVNFE = ''		"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0401")
			lErro	:= .T.
		EndIf

		cUpd := " UPDATE SF3040 SET F3_CHVNFE = '"+(cAliasCH)->F2_CHVNFE+"' "+cCRLF
		cUpd += " WHERE F3_FILIAL = '01'			"+cCRLF
		cUpd += " AND F3_CLIEFOR = '"+cFORCD08+"'	"+cCRLF
		cUpd += " AND F3_LOJA = '"+cFORLJ08+"'		"+cCRLF
		cUpd += " AND F3_SERIE = '2'				"+cCRLF	
		cUpd += " AND F3_NFISCAL = '"+(cAliasCH)->F2_DOC+"'	"+cCRLF
		cUpd += " AND F3_CHVNFE = ''		"+cCRLF
		
		//Conout(cUpd)
		If TcSqlExec(cUpd) < 0
			Conout("Erro na Query da chv 0401")
			lErro	:= .T.
		EndIf
		
		
		ConOut("Update realizado -->>>"+ (cAliasCH)->F2_DOC)
	EndIf
	
	ConOut((cAliasCH)->F2_DOC)
	
	(cAliasCH)->(DbSkip())
EndDo


(cAliasCH)->(DbCloseArea())
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

