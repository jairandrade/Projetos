
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GPEA030                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações Das funcoes                                        |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GPEA030()

	Local aParam    := PARAMIXB
	Local cErro     := ""
	Local oManusis  
	Local cRespMDT  := GetMV('TCP_RESMDT') //kayo.zaiats@tcp.com.br;felipe.formiga@tcp.com.br'
       
	If ( aParam <> NIL )

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3] 
	
		If cIdPonto == 'MODELCOMMITNTTS'
			
			If ( SUPERGETMV( 'TCP_MANUSI', .f., .F. ) )
				
				oManusis  := ClassIntManusis():newIntManusis()  
				oManusis:cFilZze    := xFilial('ZZE')
				oManusis:cChave     := SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO
				oManusis:cTipo	    := 'E'
				oManusis:cStatus    := 'P'
				oManusis:cErro      := ''
				oManusis:cEntidade  := 'SRJ'
				oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
				oManusis:cRotina    :=  FunName()
				oManusis:cErroValid := ''
	
				IF oManusis:gravaLog()
					U_MNSINT03(oManusis:cChaveZZE)              
				ELSE
					ALERT(oManusis:cErroValid)
				ENDIF
			
			EndIf
		
			If( INCLUI )
				oMail := TCPMail():New()
				oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILAVISO.HTML")
				oHtml:ValByName("CHEADER","Notificação de inclusão de nova função")
				oHtml:ValByName("CBODY","Foi realizado a inclusão de uma nova função pelo usuário <b>" + UsrFullName(RetCodUsr()) + "<b>" +;
											". <br><br> <b>Função:</b> <br><br> <b>" + SRJ->RJ_FUNCAO + " - " + SRJ->RJ_DESC + "</b>")
				oMail:SendMail( cRespMDT ,"Notificação de inclusão de nova função", oHtml:HtmlCode(),@cErro,{})
				FreeObj(oMail)
				FreeObj(oHtml)
			EndIf
		EndIf
	endif

Return( .T. )