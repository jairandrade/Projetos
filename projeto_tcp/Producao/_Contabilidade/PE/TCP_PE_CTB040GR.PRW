
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  CTB040GR                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações nos itens contabeis                                      |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                     |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function CTB040GR()                 

Local oManusis  := ClassIntManusis():newIntManusis()       
IF SUPERGETMV( 'TCP_MANUSI', .f., .F. )
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := CTD->CTD_FILIAL+CTD->CTD_ITEM
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'CTD'
	oManusis:cOperacao  := IF(INCLUI,'I','A')
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''
	
	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF			
ENDIF

Return