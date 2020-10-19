	#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MCOM016
Realiza envio de e-mail

@return 
@author Felipe Toazza Caldeira
@since 10/09/2015
/*/                                                                    
//-------------------------------------------------------------------------------
User Function MCOM016(cTo, cCC, cAssunto, cCorpo, cAnexo, lSleep )
Local aArea      := GetArea()
Local aRet       := {}	
local cSmtp      := SuperGetMV("TCP_SERVER", .F., Nil)
Local cEmail     := SuperGetMV("TCP_EMAIL" , .F., Nil)
Local cMailSenha := SuperGetMV("TCP_SENHA" , .F., Nil)
Local cMailUser  := iif( cEmail == Nil, cEmail, substr(cEmail, 1, RAT('@', cEmail) - 1))
Local lTsl       := SuperGetMV("TCP_TSL"   , .F., Nil)
Local nPorta     := SuperGetMV("TCP_PORT"  , .F., Nil)
Local nRet       := 0 
Local nNumMsg    := 0
Local nX         := 0
Local oMail      := Nil
Local oMessage   := Nil        
	if (cSmtp == Nil) .OR. (cEmail == Nil) .OR. (cMailSenha == Nil) ;
	   .OR. (cMailUser == Nil) .OR. (lTsl == Nil) .OR. (nPorta == Nil)
	   aAdd(aRet,{.F.,'Por favor, verifique os parâmetros TCP_SERVER, TCP_EMAIL, TCP_SENHA, TCP_TSL e TCP_PORT.'})
    	cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
		MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)

	else 
		oMail := TMailManager():New()
			oMail:SetUseTLS(lTsl)
			oMail:Init('', cSmtp, cMailUser, cMailSenha, 0, nPorta)	
	
			nret := oMail:SmtpConnect()
			If nRet == 0    	
    			nRet := oMail:SmtpAuth(cMailUser, cMailSenha)
				If nRet <> 0     
					cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
					MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
					aAdd(aRet, {oMail:GetErrorString(nRet)})
					IF FunName() == "RCOM009"
						U_ChecaEnv("2")
					Endif
    			else
   					    oMessage := TMailMessage():New()
						oMessage:Clear()
						oMessage:cFrom    := cEmail
						oMessage:cTo      := cTo
						oMessage:cCc      := cCC
						oMessage:cSubject := cAssunto
						oMessage:cBody    := cCorpo

						 //Adiciona um attach   
						
						  If oMessage:AttachFile(cAnexo) < 0  
							cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
							MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
						    //Conout( "Erro ao anexar o arquivo" )
							IF FunName() == "RCOM009"    
								U_ChecaEnv("2")
							EndIf
							Return .F.
						  Else
						    //adiciona uma tag informando que é um attach e o nome do arq
						    oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo)
						  EndIf
						   
						  //Envia o e-mail
						  If nRet := oMessage:Send( oMail ) != 0  
							cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
							MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
						    //Conout( "Erro ao enviar o e-mail" )
							IF FunName() == "RCOM009"
								U_ChecaEnv("2")
							EndIf
						    Return .F.          
    						aAdd(aRet, {.F., oMail:GetErrorString(nRet)})
						Else
							IF FunName() == "RCOM009"
								U_ChecaEnv("1")  
							EndIf
						EndIf						
						oMessage := FreeObj(oMessage)
				
				Endif    	
			Else
				aAdd(aRet, {"Conexão SMTP: " + oMail:GetErrorString(nRet)})
				IF FunName() == "RCOM009"
					U_ChecaEnv("2")
				EndIf	
			Endif
	
			oMail:SMTPDisconnect()
		oMail := FreeObj(oMail)
	endif
	If lSleep
		Sleep( 15000 )//para evitar travamento de envio de e-mail, envia 1 e-mail a cada 15 segundos               
    EndIf
RestArea(aArea)

return aClone(aRet)


//PGE - AFSOUZA: gravação do envio de email.
User Function ChecaEnv(_cStat)

ZZB->(DBSETORDER(1))
		RECLOCK("ZZB",.T.)
		ZZB->ZZB_FILIAL 	:= cFilAnt
		ZZB->ZZB_DATA		:= date()
		ZZB->ZZB_HORA		:= Time()
		ZZB->ZZB_FORNECE	:= SA2->A2_COD
		ZZB->ZZB_LOJA		:= SA2->A2_LOJA
		ZZB->ZZB_RAZAO		:= SA2->A2_NOME
		ZZB->ZZB_USR		:= ALLTRIM(USRRETNAME(RETCODUSR()))
		ZZB->ZZB_PONTUA		:= Posicione("Z08",1,xFilial("Z08")+SA2->A2_COD+SA2->A2_LOJA+MV_PAR05+MV_PAR06,"Z08_PONTOS")
		ZZB->ZZB_CLASSI 	:= Z08->Z08_CLASSI
		ZZB->ZZB_DISPARO	:= SA2->A2_EMAIL
		ZZB->ZZB_STATUS		:= iif(_cStat == "1","1","2")
		ZZB->(MSUNLOCK())  
		ZZB->(DBCLOSEAREA())

Return















