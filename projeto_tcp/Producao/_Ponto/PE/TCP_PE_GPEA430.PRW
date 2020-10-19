
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GPEA430                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações Dos motivos de ausencia                                        |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GPEA430()                 

Local aParam     := PARAMIXB
Local oManusis  

Local oManusis  
     
       
If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. )
		
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
	If cIdPonto == 'MODELCOMMITNTTS'   
		oManusis  := ClassIntManusis():newIntManusis()   
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := RCM->RCM_FILIAL+RCM->RCM_TIPO
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'RCM'
		oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
	
		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF  
	endif			
ENDIF

Return .T.