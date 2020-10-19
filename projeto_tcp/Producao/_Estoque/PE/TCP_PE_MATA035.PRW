
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MATA035                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações DO grupo de PRODUTO                                         |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function MATA035()                 

Local aParam     := PARAMIXB
Local oManusis  

Local oManusis  
If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. SBM->BM_XMANUSI = '1'
			 
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
		   
	If cIdPonto == 'MODELCOMMITNTTS'   
		oManusis  := ClassIntManusis():newIntManusis()      
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := SBM->BM_FILIAL+SBM->BM_GRUPO
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'SBM'
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

