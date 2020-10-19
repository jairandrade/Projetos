
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  M020EXC                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações DOfornecedor                                       |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function M020EXC()                 

Local aParam     := PARAMIXB
Local oManusis  

Local oManusis  
if(!ALTERA .AND. !INCLUI) .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) 
	oManusis  := ClassIntManusis():newIntManusis()              
	   	
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SA2->A2_FILIAL+SA2->A2_COD+SA2->A2_LOJA
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SA2'
	oManusis:cOperacao  := 'E'
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''
	
	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF  
ENDIF

Return .T.
