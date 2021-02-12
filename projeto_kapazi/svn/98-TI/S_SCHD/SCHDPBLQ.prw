#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: SCHDPBLQ 	|	Autor: Luis Paulo									|	Data: 14/03/2020//
//==================================================================================================//
//	Descrição: Funcao envio de email produto bloqueados		    		  							//
//																									//
//==================================================================================================//

User function SCHDPBLQ()

Prepare Environment Empresa "04" Filial "01"

U_SCHDBLQ()

Return Nil


User Function SCHDBLQ()
Local 	oError 			:= ErrorBlock({|e| cRet := GetErrorBlk(e:Description)})
Local 	nConWebshop := 0
Private cCRLF			:= CRLF

Conout("")
Conout("*** INICIANDO ENVIO DE EMAIL DE PRODUTOS BLOQUEADOS ***")
Conout("")

//Inicia a sequencia de erro
Begin Sequence

VerProdB(IsBlind())

//Finaliza a sequencia de erro
End Sequence

// captura de erro
ErrorBlock(oError)

Return()


/**********************************************************************************************************************************/
/** Executa a sincronização da tabela                                                                                            **/
/**********************************************************************************************************************************/
Static Function VerProdB(lBlind)
Local 	cUltSinc 		:= GetMv("KP_DTHSCHV")
Local 	cErrTo 			:= GetNewPar("KP_CNTERRK", "luis@rsacsolucoes.com.br")
Local	nRegs 			:= 0
Local 	cAtuSinc 		:= Dtos(Date()) + " " + Time()
Private cNomeRel		:= ""

//Mostra o console
Conout("[" + Dtoc(Date()) + " " + Time() + " Produtos bloqueadosss...")

// mostra a ultima sincronização
Conout("Ultima sincronizacao ocorreu: " + cUltSinc)
Conout("")

u_KP04RPBQ() //Gera o relatorio de produtos bloqueados

Sleep(5000)
BusProdBq(cUltSinc, lBlind, @nRegs)

PutMV("KP_DTHSCHV", cAtuSinc)

Return()

Static Function BusProdBq(cUltSinc, lBlind, nRegs)
//Controles
Private cServer 		:= GETMV("MV_WFSMTP")
//Private cAccount 		:= GETMV("MV_WFACC")
//Private cPassword		:= GETMV("MV_WFPASSW")
//Private cFrom			:= GETMV("MV_RELFROM")

Private cAccount 		:= Alltrim( SuperGetMV("KP_WFPBLQE"	,.F.,"bloqueiodeprodutos@kapazi.com.br")) //GETMV("KP_WFSPACC")
Private cPassword		:= Alltrim( SuperGetMV("KP_WFPBLQS"	,.F.,"Bl0qu310K@p@z1$2020")) //GETMV("KP_WFPASSP")
Private cFrom			:= GETMV("KP_SPCFROM")
Private cDest			:= Alltrim( SuperGetMV("KP_WFPBLQL"	,.F.,"vendas908@kapazi.com.br;aristeu@kapazi.com.br;cristian.piovezan@kapazi.com.br")) //"luis@rsacsolucoes.com.br"//GETMV("KP_MAILSUP") //"luis@rsacsolucoes.com.br;lpaulods@gmail.com"

Private lAuth  			:= .F.
Private lErro  			:= .T.
Private cError 			:= ""

//Corpo
Private cAssunto 		:= "Produtos bloqueados por filial"
Private cAviso
Private cItens
Private cCRLF			:= CRLF
Private cMsgMail		:= ""
Private cMail
Private cAnexo			:= ""

cAnexo := cNomeRel

CONNECT SMTP SERVER cServer	ACCOUNT cAccount PASSWORD cPassword Result lErro //conecta no servidor de e-mail

//Conout("Enviando emaoi")
If !lErro
	GET MAIL ERROR _cErro
	Conout('erro1'+_cErro)
	Conout("Nao conectou no servidor de email!!")
EndIf

lErro	:= MailAuth(cAccount,cPassword)	//Autentica no servidor de e-mail

If !lErro
	GET MAIL ERROR _cErro
	Conout("Nao autenticou no servidor de email!!")
	Conout('erro2'+_cErro)
EndIf

//MontaHtm() //Construção do HTML
cMsgMail := "Lista de produtos Bloqueados!!!"

SEND MAIL FROM 	cAccount TO cDest SUBJECT cAssunto BODY cMsgMail ATTACHMENT cAnexo RESULT lErro //BCC cCo

If !lErro
	GET MAIL ERROR _cErro
	Conout('erro3'+_cErro)
EndIf


DISCONNECT SMTP SERVER

Return()


Static Function MontaHtm()
Local cAliasHT	
Local cCRLF		:= CRLF
Local nTot		:= 0
Local nPremio	:= 0
Local _nVlrIPI	:= 0
Local cDesc		:= ""
Local cValTot	:= 0

If Select("cAliasHT") <> 0
	DBSelectArea("cAliasHT")
	cAliasHT->(DBCloseArea())
Endif

cAliasHT	:= GetNextAlias()

cAviso    := ""
cItens    := "Produto         Desc                             Status            0401 0403 0404 0405 0406 0407"+ CRLF
            //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXX   XXXX XXXX XXXX XXXX XXXX XXXX
cItens    += "--------------- ------------------------------   ---------------   ---- ---- ---- ---- ---- ----"+ CRLF

cSql1 := " SELECT SUBSTRING(DESCRICAO,1,30) AS DESCRI,ENTRADPREV AS ENTPREV,QTD_PV_KI AS QTDPVKI,* "+cCRLF
cSql1 += " FROM VBLOQPROD "+cCRLF
cSql1 += " ORDER BY CODIGO "+cCRLF

TCQuery cSql1 NEW ALIAS 'cAliasHT'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasHT")
cAliasHT->(DBGoTop())

While !cAliasHT->(EOF())
	
	cItens += Alltrim(cAliasHT->CODIGO) + ( Space( ((15 - (Len(Alltrim(cAliasHT->CODIGO))) ) + 1) ) )
	cItens += Alltrim(cAliasHT->DESCRI) + ( Space( ((30 - (Len(Alltrim(cAliasHT->DESCRI))) ) + 3) ) )
	cItens += Alltrim(cAliasHT->STATUS) + ( Space( ((15 - (Len(Alltrim(cAliasHT->STATUS))) ) + 3) ) )
	
	//cItens += Alltrim(cAliasHT->DESCRI) + ( Space( Len(Alltrim(cAliasHT->DESCRI)) + 1 ))
	//cItens += Alltrim(cAliasHT->STATUS) + ( Space( Len(Alltrim(cAliasHT->STATUS)) + 1 ) )
	
	//cValTot	:= Alltrim((Transform(cAliasHT->TOTAL, "@E 999,999,999.99")))
	//cItens 	+= Space((18-(Len(cValTot)))) + cValTot  + " "+CRLF
	
	cDesc := Substr(cAliasHT->K0401,1,4)
	cItens += cDesc + Space(1)

	cDesc := Substr(cAliasHT->K0403,1,4)
	cItens += cDesc + Space(1)

	cDesc := Substr(cAliasHT->K0404,1,4)
	cItens += cDesc + Space(1)

	cDesc := Substr(cAliasHT->K0405,1,4)
	cItens += cDesc + Space(1)

	cDesc := Substr(cAliasHT->K0406,1,4)
	cItens += cDesc + Space(1)

	cDesc := Substr(cAliasHT->K0407,1,4) 
	cItens += cDesc + Space(1) + " "+CRLF

	cAliasHT->(DbSkip())
EndDo

cItens += CRLF

//cItens += " Valor total do pedido = "+ Alltrim((Transform((nTot+_nVlrIPI), "@E 999,999,999.99")))  + "." +CRLF

cItens += CRLF

//Aviso rodapé e-mail
cAviso += "<PRE>

cAviso += "----------------------------------------------------------------------------------"+ CRLF
cAviso += " Este e-mail foi gerado pelo ERP Protheus.                                        "+ CRLF
cAviso += "----------------------------------------------------------------------------------"
cAviso += "</PRE>"+ CRLF

DBSelectArea("cAliasHT")
cAliasHT->(DBGoTop())

cMsgMail += "<PRE>
cMsgMail += "Lista de produtos bloqueados!"+ CRLF
cMsgMail += CRLF
cMsgMail += "Emissao......: "+ DTOC(Date()) + " - "+ Time() + CRLF
cMsgMail += CRLF
cMsgMail += cItens
cMsgMail += "</PRE>" + CRLF
cMsgMail += cAviso

cAliasHT->(DBCloseArea())

Return()

/**********************************************************************************************************************************/
/** static function GetErrorBlk(cErrorDesc)                                                                                      **/
/** função para contenção de erros durante o processamento de macros                                                             **/
/**********************************************************************************************************************************/
Static Function GetErrorBlk(cErrorDesc)
Local cMsgErro 	:= cErrorDesc
Local cErroMail := ""
Local cErrTo 		:= GetNewPar("KP_CNTERRK", "luis@rsacolucoes.com.br")
Local lErro 		:= .F.

// mostra o erro de sincronização
Conout("Erro na sincronização: " + cMsgErro)

// envia e-mail de erro
//U_MailTo(cErrTo, "Sincronização de Agendas", cMsgErro, "", cErroMail)

// sai do procedimento
Break

Return Nil

