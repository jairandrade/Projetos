
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GP240EXC                                                                                              |
 | Desc:  Ponto de Entrada para EXCLUIR informações de afastamentos                                           |
 | Desc:  Utilizado para enviar as informações para o Manusis  |
 | Link: http://tdn.totvs.com/pages/releaseview.action?pageId=6068587                                          |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GP240EXC()                 

Local oManusis  := ClassIntManusis():newIntManusis()       

IF !INCLUI .AND. !ALTERA .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. (ALLTRIM(SRA->RA_CC) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ))
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SR8->R8_FILIAL+SR8->R8_NUMID
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SR8'
	oManusis:cOperacao  := 'E'
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''

	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF			
ENDIF

Return