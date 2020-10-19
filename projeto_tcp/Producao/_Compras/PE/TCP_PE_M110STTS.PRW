User Function M110STTS()
 
Local cNumSol   := Paramixb[1]
Local nOpt      := Paramixb[2]
Local lCopia    := Paramixb[3]
 
if nOpt == 3     
	oCompras  := ClassIntCompras():new()    
			
	IF oCompras:registraIntegracao('6',xFilial('SC1')+cNumSol,'E')  
		oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
		ALERT(oCompras:cErro)
	ENDIF  
endif
   
Return Nil