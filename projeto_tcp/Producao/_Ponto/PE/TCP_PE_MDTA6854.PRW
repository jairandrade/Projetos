User Function MDTA6854()

Local nOpcao := PARAMIXB[1] //Selecionar o primeiro par�metro

If nOpcao == 3  //Caso seja Inclus�o. 
	_oAtestado  := ClassLancAtestado():newLancAtestado()    
	_oAtestado:cMat           := POSICIONE("TM0",1,XFILIAL("TM0")+TNY->TNY_NUMFIC,"TM0_MAT")  
	_oAtestado:cNome          := TM0->TM0_NOMFIC                                   
	if(VAL(ALLTRIM(TNY->TNY_QTDTRA)) > 0)                                    
		_oAtestado:dDtAtestado    := DTOC(TNY->TNY_DTINIC)
		_oAtestado:nQtdDias	      := ALLTRIM(TNY->TNY_QTDTRA)
	ELSE
		_oAtestado:dDtAcomp	      := IF(EMPTY(TNY->TNY_QTDTRA) .OR. TNY->TNY_QTDTRA == '0',DTOC(TNY->TNY_DTINIC)+' Hor�rio: ' + TNY->TNY_HRINIC+ ' �s ' +TNY->TNY_HRFIM, '')         
	
	ENDIF
	_oAtestado:dDtOutros  	  := ''
	_oAtestado:nQtdDiasOutros := ''                   
	_oAtestado:dDiasAcomp     := ''            
	_oAtestado:dDtHoje        := DTOC(DATE())  

	_oAtestado:enviaMail()  
   	
EndIf

Return .T.