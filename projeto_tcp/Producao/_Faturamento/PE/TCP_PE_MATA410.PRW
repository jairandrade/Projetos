User Function M410STTS()                                  
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local cCcRepar := GetMV('TCP_CCREPAR')

    Local lGeraOP := .F.
	If SC5->C5_TIPO == 'B'        
	    // Adicionado para gerar a OP automaticamente (sem perguntar) quando trata-se de chamada a partir do MONITOR de Processo de REPARO/GARANTIA 
	    if Alltrim(FUNNAME()) ==  'TC04A020' 
	        lGeraOP := .T.          
	    else
	        If MsgYesNo('Deseja gerar a ordem de produção automaticamente?', "Confirme")
	            lGeraOP := .T.          
	        endif
	    endif
	endif
    
    if lGeraOP
		DbSelectArea('SC6')
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())  
		SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
		While !SC6->(EOF()) .AND. SC5->C5_FILIAL == SC6->C6_FILIAL .AND.SC5->C5_NUM == SC6->C6_NUM

			cQuery := " SELECT MAX(C2_NUM) AS C2_NUM FROM "+RetSqlName('SC2')
			cQuery += "	WHERE C2_FILIAL = '"+XfILIAL('SC2')+"' AND C2_ITEM = '01' AND C2_SEQUEN = '001' AND D_E_L_E_T_ != '*' "	
			If (Select("NUMOP") <> 0)
	  			DbSelectArea("NUMOP")
	   			NUMOP->(DbCloseArea())
		 	Endif
			                                                                       	
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "NUMOP",.T., .F.)
			
			DbSelectArea("NUMOP")
			NUMOP->(DbGoTop()) 
			IF !NUMOP->(EOF())
				cNumOp := Soma1(NUMOP->C2_NUM)
			Else
				cNumOp := "000001"
			EndIf                     
			NUMOP->(DbCloseArea())	

			lMsErroAuto := .F.
   			If SC6->C6_GERAOP == 'X'
   				Alert('OP já gerada para este pedido!')				
				RestArea(aAreaSC5)
				RestArea(aAreaSC6)	   
   				Return
   			EndIf                    
   
		 	If SC6->C6_GERAOP == '1'		    
				cProdOp := SC6->C6_PRODUTO 
				aMata650  := {  {'C2_FILIAL'   ,xFilial('SC2')  ,NIL},;
				                {'C2_PRODUTO'  ,cProdOp     	,NIL},;          
				                {'C2_NUM'      ,cNumOp          ,NIL},;          
				                {'C2_ITEM'     ,"01"            ,NIL},;          
				                {'C2_SEQUEN'   ,"001"           ,NIL},; 
				                {'C2_DATPRI'   ,dDataBase       ,NIL},;
				                {'C2_DATPRF'   ,dDataBase+7     ,NIL},;
				                {'C2_QUANT'    ,SC6->C6_QTDVEN  ,NIL},;
				                {'C2_CC'       ,cCcRepar  		,NIL} ;
				                }             
				                 		      
				msExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
				If lMsErroAuto
				    Alert("Não foi possível gerar a OP")
				    MostraErro() 
				Else
					RecLock('SC6',.F.)
			   		SC6->C6_GERAOP := 'X'		
					SC6->(msUnlock())
				    // Atualizar a variavel de contrato caso a OP esteja vinculada a um processo de garantia/reparo.
				    if Alltrim(FUNNAME()) ==  'TC04A020' 
				        cZPB_OP := cNumOp
				    endif
				EndIf    
			/*	
            else
		
				aMata380:={   	{"D4_COD"     ,SC6->C6_PRODUTO		,Nil},; //COM O TAMANHO EXATO DO CAMPO
		            			{"D4_LOCAL"   ,SC6->C6_LOCAL        ,Nil},;
		            			{"D4_OP"      ,cNumOp+"01"+"001"  	,Nil},;
		            			{"D4_DATA"    ,dDatabase        	,Nil},;
		            			{"D4_QTDEORI" ,SC6->C6_QTDVEN        	,Nil},;
		            			{"D4_QUANT"   ,SC6->C6_QTDVEN       	,Nil},;
		            			{"D4_TRT"     ,Alltrim(STR(VAL(SC6->C6_ITEM)))   	,Nil}}
		             
		 
				MSExecAuto({|x,y,z| mata380(x,y,z)},aMata380,3) 
				 
				If lMsErroAuto
				    Alert("Não foi possível gerar os empenhos para a OP")
				    MostraErro() 
				Else
					RecLock('SC6',.F.)
			   		SC6->C6_GERAOP := 'X'		
					SC6->(msUnlock())
				EndIf
			*/
			EndIf
			SC6->(DbSkip())		                
		EndDo
	EndIf           
	                
RestArea(aAreaSC5)
RestArea(aAreaSC6)	

Return