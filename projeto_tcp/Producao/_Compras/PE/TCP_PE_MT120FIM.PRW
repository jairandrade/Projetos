//************************************************************************************//
//***Ponto de entrada envocado ao fim do processo de alteração do pedido de compra ***//
//***altera o wf customizado para enviar e-mail aos novos aprovadores              ***//
//***Analista: Alessandro Bueno                                                    ***//
//***Data: 15/08/2016                                                              ***//
//***Revisões:                                                                     ***//
//************************************************************************************//

User function MT120FIM()      
	//Local flg := 0
	Local nOpcx     := PARAMIXB[1]
	Local nOpca     := PARAMIXB[3]
	Local _lInc     := INCLUI
	Local _lExc     := .F.
    Local aArea     := GetArea()
    Local _cFil     := SC7->C7_FILIAL
    Local _cNumPc   := SC7->C7_NUM
    // Atualizar processo de reparo/garantias
    If Inclui
	    U_SC7FRE(SC7->C7_NUM, SC7->C7_NUMSC, SC7->C7_MEDICAO)
	endif
    
   
    IF nOpca == 1 
    
    	IF !_lInc .AND. !Altera
    	
	    	IF IsInCallStack("A120Copia")
	    		_lInc := .T.
	    	elseif aRotina[nOpcx,4] == 5
	    		_lExc := .T.
	    	ENDIF
    	endif
    	
    	IF (Altera .OR. _lInc .OR.  (_lExc .AND. !EMPTY(SC7->C7_XSALES) )) 
    		oRetPed := u_ctrSales( _cFil,_cNumPc, _lInc, Altera,_lExc)
    	ENDIF
    	
    	_nOper := ''
    	
    	if _lExc
    		_nOper := 'E'
		else
    		_nOper := 'I'
		endif
		
		oCompras  := ClassIntCompras():new()    
		
		IF oCompras:registraIntegracao('2',_cFil+_cNumPc,_nOper)  
			oCompras:enviaSales()
		elseif !empty(oCompras:cErro)
			ALERT(oCompras:cErro)
		ENDIF  
		
    ENDIF
    
    RestArea(aArea)
    
Return
