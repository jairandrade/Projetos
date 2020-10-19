
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  GPEA080                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações de turno                                        |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function GPEA080()                 

Local aParam     := PARAMIXB
Local oManusis  

Local oManusis  
if  SUPERGETMV( 'TCP_MANUSI', .f., .F. )  
	oManusis  := ClassIntManusis():newIntManusis()              
	   //alert('tem q arrumar a inclusao')		
	oManusis:cFilZze    := xFilial('ZZE')  
	IF INCLUI .OR. ALTERA
		oManusis:cChave     := M->R6_FILIAL+M->R6_TURNO
		oManusis:cCodigoEnt		:= M->R6_TURNO            
		oManusis:cDescrEnt		:= M->R6_DESC
	ELSE
		oManusis:cChave     := SR6->R6_FILIAL+SR6->R6_TURNO
	ENDIF
	oManusis:cTipo	    := 'E'
	oManusis:cStatus    := 'P'
	oManusis:cErro      := ''
	oManusis:cEntidade  := 'SR6'
	oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
	oManusis:cRotina    :=  FunName()
	oManusis:cErroValid := ''
	
	IF oManusis:gravaLog()  
		U_MNSINT01(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF  
endif
Return .T.