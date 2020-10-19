User Function MT235AIR
Local cAlias := ParamIXB[1]
Local cTpAlias := ParamIXB[2]
Local aSaveArea := SaveArea1({"SC1","SC7"})

IF(cTpAlias == 1) 

	dbSelectArea("SC7")
	SC7->(dbGoto((cAlias)->(SC7RECNO)))
	IF !EMPTY(SC7->C7_XSALES)
	
		u_ctrSales( SC7->C7_FILIAL,SC7->C7_NUM, .F., .F.,.F.,.T.)
	
		oCompras  := ClassIntCompras():new()    
			
		IF oCompras:registraIntegracao('2',SC7->C7_FILIAL+SC7->C7_NUM,'A')  
			oCompras:enviaSales()
		elseif !empty(oCompras:cErro)
			ALERT(oCompras:cErro)
		ENDIF  
	ENDIF

ELSEIF (cTpAlias == 3) 
	
	dbSelectArea("SC1")
	SC1->(dbGoto((cAlias)->(SC1RECNO)))
	IF !EMPTY(SC1->C1_XSALES)
		oCompras  := ClassIntCompras():new()    
			
		IF oCompras:registraIntegracao('5',SC1->C1_FILIAL+SC1->C1_NUM,'A')  
			oCompras:enviaSales()
		elseif !empty(oCompras:cErro)
			ALERT(oCompras:cErro)
		ENDIF  
	ENDIF
ENDIF


RestArea1(aSaveArea)

return