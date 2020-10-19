
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GP010AGRV                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações do funcionário                                    |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GP180TRA()                 

Local oManusis       
       
oManusis  := ClassIntManusis():newIntManusis()              
if SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. (ALLTRIM(SRE->RE_CCP) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ) .OR. ALLTRIM(SRE->RE_CCD) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ))
	oManusis:cFilZze    := xFilial('ZZE')
	oManusis:cChave     := SRA->RA_FILIAL+SRA->RA_MAT
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SRA'
	oManusis:cOperacao  := 'A'
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''
	
	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF  
endif	

Return .T.                      

