User Function MT170FIM( )
Local aScs := PARAMIXB[1]
Local _nX := 0
Local _cNatu := superGETMV( 'TCP_NATEST', .T.,'3065' )
Local _cMat  := ''

PswOrder(1)
		
If  PswSeek(__cUserId ,.T.) //Se usuário encontrado
	aGrupos := Pswret(1)  
	_cMat   := SUBSTR(aGrupos[1][22],5,6)
endif

For _nX:= 1 To Len(aScs) 
   
	dbSelectArea('SC1')
	If SC1->(dbSeek(xFilial('SC1')+aScs[_nX,2]))  
	    
		while !SC1->(EOF())  .AND. SC1->C1_FILIAL+SC1->C1_NUM == xFilial('SC1')+aScs[_nX,2]
			Reclock('SC1',.F.)       
			SC1->C1_OBS := 'MINIMUM STOCK REPLENSHIMENT' 
			SC1->C1_XNATURE := _cNatu
			SC1->C1_REQUISI := _cMat
			SC1->(MsUnlock())     
			SC1->(DBSKIP())
		ENDDO
	Endif
Next

Return Nil