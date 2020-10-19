
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  CT030GRI                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações no centro de custo                                           |
 | Desc:  Utilizado para enviar as informações para o Manusis  |
 | Link: http://tdn.totvs.com/pages/releaseview.action?pageId=6068587                                          |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function CT030GRI()                 

Local oManusis  := ClassIntManusis():newIntManusis()       

IF INCLUI .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. )
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := CTT->CTT_FILIAL+CTT->CTT_CUSTO
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'CTT'
	oManusis:cOperacao  := 'I'
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''

	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF			
ENDIF

Return