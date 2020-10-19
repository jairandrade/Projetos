
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GPEA050                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações de afastamentos                                           |
 | Desc:  Utilizado para enviar as informações para o Manusis  |
 | Link: http://tdn.totvs.com/pages/releaseview.action?pageId=6068587                                          |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GPEA050()                 
Local aParam     := PARAMIXB
Local oManusis   := ClassIntManusis():newIntManusis()       

If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. (ALLTRIM(SRA->RA_CC) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' )  ))
   
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
	 
	If cIdPonto == 'MODELCOMMITNTTS'   
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := SRF->RF_FILIAL+SRF->RF_MAT+DTOS(SRF->RF_DATABAS)+SRF->RF_PD
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'SRF'
		oManusis:cOperacao  := IF(SRF->(Deleted()),'E','I')
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
	
		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF			
	ENDIF
ENDIF

Return .T.
