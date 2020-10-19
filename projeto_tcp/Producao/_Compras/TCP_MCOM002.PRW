#include "totvs.ch"

/*/{Protheus.doc} MCOM002
    Funcao utilizada para enviar e-mail 
    @type  Function
    @author Lucas Jose Correa Chagas
    @since 16/05/2013
    @version 1.0
	@param aEmail: Array contendo os e-mails que serao enviados
    @return aRet: Contendo o retorno da rotina informando se houveram erros ou nao
    @example
    (examples)
    @see (links_or_references)
/*/
User Function MCOM002( aEmail )            	
	Local aArea      := GetArea()
	Local aRet       := {}
	local cSmtp      := SuperGetMV("TCP_SERVER", .F., Nil)
	Local cEmail     := SuperGetMV("TCP_EMAIL" , .F., Nil)
	Local cMailSenha := SuperGetMV("TCP_SENHA" , .F., Nil)
	Local cMailUser  := iif( cEmail == Nil, cEmail, substr(cEmail, 1, RAT('@', cEmail) - 1))  
	Local lTsl       := SuperGetMV("TCP_TSL"   , .F., Nil)
	Local nPorta     := SuperGetMV("TCP_PORT"  , .F., Nil)
	Local nRet       := 0
	Local nX         := 0
	Local oMail      := Nil
	Local oMessage   := Nil

	/*----------------------------------------------------------------------------+
	| Estrutura de entrada de aEmail                                              |
	+-----------------------------------------------------------------------------+
	| Array multi-dimensional onde cada linha representa os dados abaixo:         |
	|                                                                             |
	| aEmail[?,1]: Email de destino                                               |
	| aEmail[?,2]: Email de copia                                                 |
	| aEmail[?,3]: Assunto do email                                               |
	| aEmail[?,4]: HTML do corpo do email                                         |
	| aEmail[?,5]: A2_COD e A2_LOJA --> uso interno da rotina                     |
	+----------------------------------------------------------------------------*/

	/*----------------------------------------------------------------------------+
	| Estrutura de retorno de dados aRet                                          |
	+-----------------------------------------------------------------------------+
	| aRet vazio --> nenhum erro encontrado;                                      |
	| aRet preenchido --> cada linha um apontamento de erro.                      |
	+----------------------------------------------------------------------------*/
	If (aEmail == Nil) .OR. ((aEmail != Nil) .AND. (Len(aEmail) == 0))
		aAdd(aRet,{.F.,'Dados para envio não informados.'})
	Else
		If (cSmtp == Nil) .OR. (cEmail == Nil) .OR. (cMailSenha == Nil) ;
		.OR. (cMailUser == Nil) .OR. (lTsl == Nil) .OR. (nPorta == Nil)
		aAdd(aRet,{.F.,'Por favor, verifique os parâmetros TCP_SERVER, TCP_EMAIL, TCP_SENHA, TCP_TSL e TCP_PORT.'})
		Else
			oMail := TMailManager():New()
				oMail:SetUseTLS(lTsl)
				oMail:Init('', cSmtp, cMailUser, cMailSenha, 0, nPorta)

				nret := oMail:SmtpConnect()
				If nRet == 0
						nRet := oMail:SmtpAuth(cMailUser, cMailSenha)
					If nRet <> 0
						aAdd(aRet, {.F.,'', oMail:GetErrorString(nRet)})
					else
						for nX := 1 to len(aEmail)
							oMessage := TMailMessage():New()
								oMessage:Clear()
								oMessage:cFrom    := cEmail
								oMessage:cTo      := aEmail[nX,1]
								oMessage:cCc      := aEmail[nX,2]
								oMessage:cSubject := aEmail[nX,3]
								oMessage:cBody    := aEmail[nX,4]
								nRet := oMessage:Send( oMail )

								if nRet <> 0
									aAdd(aRet, {.F., aEmail[nX,5],oMail:GetErrorString(nRet)})
								else
									aAdd(aRet, {.T., aEmail[nX,5], /*aEmail[nX,6]*/"Enviado com sucesso"})
								Endif
							oMessage := FreeObj(oMessage)
						next nX
					Endif
				Else
					aAdd(aRet, {.F., "Conexão SMTP: " + oMail:GetErrorString(nRet)})
				Endif

				oMail:SMTPDisconnect()
			oMail := FreeObj(oMail)
		EndIf
	EndIf

RestArea(aArea)

Return aClone(aRet)
