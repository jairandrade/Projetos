#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004
Rotina para cadastro de regra de avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM004()       

	Private cCadastro := "Regras de avaliação de Fornecedores"
	Private aRotina := {}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias := "Z03"
	Private aCores := {}
	
	aCORES := {{"Z03_INICIO <= dDataBase .AND. (Z03_FIM >= dDataBase .OR. Z03_FIM = CTOD('  /  /  ')) " ,"BR_VERDE" } ,;   
				{"Z03_INICIO > dDataBase .OR. Z03_FIM < dDataBase  " ,"BR_VERMELHO"}} 
	
	
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  , "AxPesqui"   ,0,1})  
	AADD(aRotina,{"Visualizar" , "U_ACOM004I" ,0,2})
	AADD(aRotina,{"Incluir"    , "U_ACOM004I" ,0,3})
	AADD(aRotina,{"Alterar"    , "U_ACOM004I" ,0,4})
	AADD(aRotina,{"Excluir"    , "U_ACOM004I" ,0,5})
	AADD(aRotina,{"Lengenda"   , "U_ACOM004L" ,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,aCORES)
	

Return                                                                           


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004I
Rotina para inclusão/alteração/exclusão de regra de avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------              
User Function ACOM004I(cAlias,nReg,nOpc)
	
 	If nOpc == 3	

		Private cRegra 		:= Space(Len(Z03->Z03_CODIGO))
		Private cDesc 		:= Space(Len(Z03->Z03_DESC))
		Private dInicio 	:= dDataBase
		Private dFim		:= dDataBase
	Else
		Private cRegra 		:= Z03->Z03_CODIGO
		Private cDesc 		:= Z03->Z03_DESC
		Private dInicio		:= Z03->Z03_INICIO
		Private dFim		:= Z03->Z03_FIM
	EndIf        

	ACOM004INC(cAlias,nReg,nOpc)


Return .T.
		   

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004I
Rotina para inclusão/alteração/exclusão de regra de avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------	                           
Static Function ACOM004INC(cAlias,nReg,nOpc)			
	Local aObjects  	:= {} 
	Local aPosObj   	:= {} 
	Local aSizeAut  	:= MsAdvSize()             
	Local aButtons := {}            
			
	Private cCadastro 	:= 'Regras de Avaliação' 
	Private oGet
	Private oGet2
	Private oGet3
	Private nLen		:= 0    
	Private cTMPZ04		:= "" 
	Private cTMPZ05		:= ""
		
	static oDlgI           	

	DbSelectArea('Z03')
	DbSelectArea('Z04')
	DbSelectArea('Z05')

//***************************************************************//
//Criação de tab-ela temporária que irá receber os dados enquanto //
//orçamento é digitado											 //
//***************************************************************//                          
	cTMPZ05		:= "TMPZ05"+RetCodUsr()+Dtos(dDataBAse)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
    
	If nOpc == 3	
		cQuery2 := "SELECT "
		cQuery2 += " Z05_CRITER, Z05_SEQ   ,Z05_VALOR1, Z05_REGRA1, Z05_CAMPO , Z05_REGRA2, Z05_VALOR2, Z05_NOTA   "
		cQuery2 += " INTO "+cTMPZ05+" "             				                                       
		cQuery2 += " FROM "+RetSqlName('Z05')+" WHERE Z05_FILIAL = 'XX'"		

	Else 
		cQuery2 := "SELECT "
		cQuery2 += " Z05_CRITER, Z05_SEQ   ,Z05_VALOR1, Z05_REGRA1, Z05_CAMPO , Z05_REGRA2, Z05_VALOR2, Z05_NOTA   "  
		cQuery2 += " INTO "+cTMPZ05+" "        				                                       		
		cQuery2 += " FROM "+RetSqlName('Z05')+" WHERE Z05_FILIAL = '"+xFilial('Z05')+"' AND Z05_REGRA = '"+Z03->Z03_CODIGO+"' AND D_E_L_E_T_ != '*' "	

      
	EndIf
	TcSqlExec(cQuery2)

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
		@ 005, 005 group oGrpCabec to 030, 505 prompt ' Regra ' of oDlgI	color 0,16777215 pixel
		DADOSCC(nOpc)// cabecalho                                          
		
		@ 040, 005 group oGrpVisual to 155, 505 prompt ' Critério ' of oDlgI color 0,16777215 pixel		
		GRIDCRIT(nOpc) // Grid de Criterios  

		@ 165, 005 group oGrpImput to 270, 505 prompt ' Avaliação ' of oDlgI color 0,16777215 pixel		
		GRidAval(nOpc)	// Grid de Avaliacao

		ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(CONFIRMAR(nOpc),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DADOSCC
Rotina para montagem do cabeçalho 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function DADOSCC(nOpc)         			 

	@ 017, 010 say 'Regra	' 		size 020, 010 pixel
	@ 015, 040 get cRegra 			size 040, 010 when IIF(nOpc == 3,.T.,.F.) pixel  valid existchav('Z03',cRegra) PICTURE "@!"
	@ 017, 090 say 'Descrição' 		size 030, 010 pixel
	@ 015, 130 get cDesc 			size 150, 010 when .T. pixel  PICTURE "@!"
	@ 017, 300 say 'Vig. Inicial' 	size 032, 010 pixel
	@ 015, 340 get dInicio 			size 040, 010 when IIF(nOpc == 3,.T.,.F.) pixel
	@ 017, 400 say 'Vig. Final' 	size 030, 010 pixel
	@ 015, 440 get dFim		   		size 040, 010 when .T. pixel 

return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT(nOpc)
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'Z04_CRITER', 'Z04_DESC','Z04_PESO','Z04_ACAO'}
	local aFieldFill	:= {}
	local aAlterFields	:= {'Z04_DESC','Z04_PESO','Z04_ACAO'}
	Local aField		:= {}
	Local nX
	
	AEval(aFields, {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
											cField,;
											X3PICTURE(cField),; 
											TamSX3(cField)[1],;
											TamSX3(cField)[2],;
											GetSx3Cache(cField, "X3_VALID"),;
											GetSx3Cache(cField, "X3_USADO"),;
											FwSX3Util():GetFieldType(cField),;
											X3F3(cField),;
											GetSx3Cache(cField, "X3_CONTEXT"),;
											X3CBOX(cField),;
											GetSx3Cache(cField, "X3_RELACAO");
											})})
	aHeader := aClone(aField)
	
	for nX := 1 to len(aFields)
		If nX == 1
		 	aAdd(aFieldFill, StrZero(nX,aHeader[1][4]))
		Else
			aAdd(aFieldFill, criaVar(aHeader[nX][02], .F.))
		EndIf
	next
	
	aAdd(aFieldFill, .f.)

	If nOpc == 3	
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    
	Else                                   
	
			cQueryZ04 := " SELECT * FROM "+RetSqlName('Z04')+" Z04 "
			cQueryZ04 += " WHERE Z04.Z04_FILIAL = '"+xFilial('Z04')+"' AND Z04.Z04_REGRA = '"+Z03->Z03_CODIGO+"' AND Z04.D_E_L_E_T_ != '*' "

			If (Select("TMPZ04") <> 0)
		   		DbSelectArea("TMPZ04")
		   		TMPZ04->(DbCloseArea())
		    Endif
			
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryZ04), "TMPZ04",.T., .F.)
			
			DbSelectArea("TMPZ04")
			TMPZ04->(DbGoTop())
/*
			DbSelectArea('Z04')
			Z04->(DbSetOrder(3))
			Z04->(DbGoTop())
         	Z04->(DbSeek(xFilial('Z04')+Z03->Z03_CODIGO))

			While !Z04->(EOF()) .AND. xFilial('Z04')+Z04->Z04_REGRA == xFilial('Z04')+Z03->Z03_CODIGO
 */
 			While !TMPZ04->(EOF()) 				
				aFieldFill[1]  := TMPZ04->Z04_CRITER
				aFieldFill[2]  := TMPZ04->Z04_DESC  				
				aFieldFill[3]  := TMPZ04->Z04_PESO  	   
				aFieldFill[4]  := TMPZ04->Z04_ACAO  		
				aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
				
				TMPZ04->(DbSkip())
			EndDo	
	EndIf

	If (Select("TMPZ04") <> 0)
   		DbSelectArea("TMPZ04")
   		TMPZ04->(DbCloseArea())
    Endif


 	oGet := MsNewGetDados():New( 050, 010, 150, 500,GD_INSERT + GD_UPDATE + GD_DELETE, 'U_ACOM004A()', 'U_ACOM004B()', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	
  	oGet:bChange    := {|| U_ACOM0042(nOPC)}
 
 	
return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDAVAL
Rotina para montagem do grid item avaliação

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                   
static function GRIDAVAL(nOpc)
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'Z05_SEQ','Z05_VALOR1','Z05_REGRA1','Z05_CAMPO','Z05_REGRA2','Z05_VALOR2','Z05_NOTA'}
	local aFieldFill	:= {}
	local aAlterFields	:= {'Z05_VALOR1','Z05_REGRA1','Z05_CAMPO','Z05_REGRA2','Z05_VALOR2','Z05_NOTA'}
	Local aField		:= {}
	Local nX
	
	AEval(aFields, {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
											cField,;
											X3PICTURE(cField),; 
											TamSX3(cField)[1],;
											TamSX3(cField)[2],;
											GetSx3Cache(cField, "X3_VALID"),;
											GetSx3Cache(cField, "X3_USADO"),;
											FwSX3Util():GetFieldType(cField),;
											X3F3(cField),;
											GetSx3Cache(cField, "X3_CONTEXT"),;
											X3CBOX(cField),;
											GetSx3Cache(cField, "X3_RELACAO");
											})})
	
	aHeader := aClone(aField)
	
	for nX := 1 to len(aField)
		If nX == 1
		 	aAdd(aFieldFill, StrZero(nX,aHeader[1][4]))
		Else
			aAdd(aFieldFill, criaVar(aHeader[nX][02], .F.))
		EndIf
	next
	
	aAdd(aFieldFill, .f.)     
	
	If nOpc == 3
		aAdd(aCols, aClone(aFieldFill))		
	Else
		DbSelectArea('Z05')
		Z05->(DbSetOrder(1))
		Z05->(DbGoTop())
		Z05->(DbSeek(xFilial('Z05')+Z03->Z03_CODIGO+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})]))

		While !Z05->(EOF()) .AND. xFilial('Z05')+Z05->Z05_REGRA+Z05->Z05_CRITER == xFilial('Z03')+Z03->Z03_CODIGO+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})]
			       
			aFieldFill[1]  := Z05->Z05_SEQ
			aFieldFill[2]  := Z05->Z05_VALOR1  				
			aFieldFill[3]  := Z05->Z05_REGRA1 
			aFieldFill[4]  := Z05->Z05_CAMPO
			aFieldFill[5]  := Z05->Z05_REGRA2  				
			aFieldFill[6]  := Z05->Z05_VALOR2 
			aFieldFill[7]  := Z05->Z05_NOTA
			 			
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
			
			Z05->(DbSkip())
		EndDo	
	EndIf		
 	oGet2 := MsNewGetDados():New( 175, 010, 265, 500,GD_INSERT + GD_UPDATE + GD_DELETE, 'U_ACOM004C', 'AllwaysTrue', '', aAlterFields, , 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	
	oGet2:bChange    := {|| U_ACOM0043(nOPC)}
return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004A
Rotina para validação de código de critério 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM004A()
Local lRet  := .T.
Local nI                      
	For nI := 1 to Len(oGet:aCols)
		If oGet:nAt != nI
			If oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})] == oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]   
				MsgInfo('Não é possível ter critérios com código identico!')
				lRet := .F.  
				Return lRet
			EndIf
		EndIf	
		
	Next		                                        
                   

	cQryDel := " DELETE FROM "+cTMPZ05+" WHERE Z05_CRITER = '"+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]+"' " 	  
	TcSqlExec(cQryDel)	                      
	Memowrit('e:\TEMP\del.txt',cQryDel)
	
	For nI := 1 to Len(oGet2:aCols)
		If !oGet2:aCols[nI,Len(oGet2:aHeader)+1]
			cQryIns := " INSERT INTO "+cTMPZ05+" VALUES "
			cQryIns += "('"+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]+"', '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_SEQ'})]+"' , "
			cQryIns += " "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR1'})])+", '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA1'})]+"', "
			cQryIns += "'"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})]+"', '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA2'})]+"', "
			cQryIns += " "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR2'})])+",  "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})])+" )"		
			Memowrit('e:\TEMP\ins.txt',cQryIns)
			TcSqlExec(cQryIns)	
		EndIf
	Next		                                        
                                                                                            	
Return(lRet)                               


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004B
Rotina para validação de pesos

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                   
User Function ACOM004B()
Local nPeso := 0                                
Local lRet  := .T.
Local nI                      
	For nI := 1 to Len(oGet:aCols)
		nPeso += oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})]	
	Next		                                        
                                                                                            
	If nPeso != 100
		Alert('O somatório dos pesos está incorreto!')	 
		lRet  := .F.
	EndIf	

	
Return(lRet)
                  

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004C
Rotina para validação de NOTAS

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                  
User Function ACOM004C()
	Local nI
	Local lRet  	:= .T.
	//Local nTamSeek  := 0 

	For nI := 1 to Len(oGet2:aCols)
		If oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})] < oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})]   
			MsgInfo('Não é possível ter nota maior que Peso!')
			lRet := .F.  
			Return lRet
		EndIf		
	Next        
	
	//If !TMPSX3->( dbSeek( PadR( oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})] , nTamSeek ) ) )
    If FieldPos(oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})]) == 0
	   	Alert('O campo informado não existe!')
       	Return .F.
	EndIf	
                                                                                                               	
Return(lRet)      


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004B
Rotina para atualização do grid

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                                              
user Function ACOM0042(nOpc)
Local cQuery := ""      
Local nAux       
Local nAuxF            
    //fazer o autoincremento do campo Z04_CRITER
    IF Empty(Alltrim(oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})]))
    	oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})] := Strzero(oGet:nAt,Len(oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})]))
    EndIf                 
                      
                      
	cQuery := "SELECT * FROM "+cTMPZ05+" WHERE Z05_CRITER = '"+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=="Z04_CRITER"})]+"' "
	TCQuery cQuery New Alias "PROTOR"
	PROTOR->(dbGoTop())
                 
    nAux := 1  
    
    If PROTOR->(EOF()) 
		For nAux := 1 to Len(oGet2:aCols) 
			If nAux != 1 //limpar o array, deixando somente a primeira linha                            		
				aDel(oGet2:aCols,nAux) 
				aSize(oGet2:aCols,Len(oGet2:aCols)-1)
			Else 
				oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_SEQ'})] 		:= StrZero(nAux,Len(Z05->Z05_SEQ))   
				oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR1'})] 	:= 0
			   	oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA1'})] 	:= Space(Len(Z05->Z05_REGRA1))
			   	oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})] 		:= Space(Len(Z05->Z05_CAMPO))
				oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA2'})] 	:= Space(Len(Z05->Z05_REGRA2))	 
				oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR2'})] 	:= 0
			   	oGet2:aCols[nAux,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})] 		:= 0 
			EndIf
		Next	    

    Else              
    	aAuxVet := {}
	   	aAuxVet := aClone(oGet2:aCols)//manter o mesmo poscionamento do aheader		

		For nAuxF := 1 to Len(oGet2:aCols)
			aDel(oGet2:aCols,nAux) 
			aSize(oGet2:aCols,Len(oGet2:aCols)-1)
 		Next	    
 		oGet2:aCols := {}
	
		While !PROTOR->(EOF())    
			aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_SEQ'})] 		:= PROTOR->Z05_SEQ        
			aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR1'})] 	:= PROTOR->Z05_VALOR1
		   	aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA1'})] 	:= PROTOR->Z05_REGRA1
		   	aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})] 		:= PROTOR->Z05_CAMPO
			aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA2'})] 	:= PROTOR->Z05_REGRA2	 
			aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR2'})] 	:= PROTOR->Z05_VALOR2
		   	aAuxVet[1,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})] 		:= PROTOR->Z05_NOTA 
		 	aAuxVet[1,Len(oGet2:aHeader)+1]                              		:= .F.   
		 	aAuxVet2 := aClone(aAuxVet[1])
		 	aadd(oGet2:aCols,aAuxVet2)										
			PROTOR->(dbSkip())
		EndDo	
	EndIf	
    PROTOR->(DbCloseArea())

	oGet:Refresh()	
 	oGet2:Refresh()	   
 	
return
                               
//-------------------------------------------------------------------------------
/*/{Protheus.doc} CONFIRMAR
Rotina para inserção das ações

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                  
Static Function CONFIRMAR(nOpc)
	Local nI
	cQryDel := " DELETE FROM "+cTMPZ05+" WHERE Z05_CRITER = '"+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]+"' " 	  
	TcSqlExec(cQryDel)	                      
	Memowrit('e:\TEMP\del.txt',cQryDel)
	
	For nI := 1 to Len(oGet2:aCols)
		If !oGet2:aCols[nI,Len(oGet2:aHeader)+1]
			cQryIns := " INSERT INTO "+cTMPZ05+" VALUES "
			cQryIns += "('"+oGet:aCols[oGet:nAt,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]+"', '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_SEQ'})]+"' , "
			cQryIns += " "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR1'})])+", '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA1'})]+"', "
			cQryIns += "'"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_CAMPO'})]+"', '"+oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_REGRA2'})]+"', "
			cQryIns += " "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_VALOR2'})])+",  "+STR(oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})])+" )"		
			Memowrit('e:\TEMP\ins.txt',cQryIns)
			TcSqlExec(cQryIns)	
		EndIf
	Next		                                        


	If nOpc == 2
		Return .T.
	EndIf              

	If nOpc != 5 	
		nPeso := 0
		For nI := 1 to Len(oGet:aCols)
			nPeso += oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})]	                 
			If !oGet:aCols[nI,len(oGet:aCols[nI])] .AND.  oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})] == 0
				Alert('O peso deve estar preenchido para todos os critérios') 
				Return .F.
			EndIf
		Next
	                                                                                           
		If nPeso != 100
			Alert('O somatório dos pesos está incorreto!')	 
			Return .F.
		EndIf	
	

		For nI := 1 to Len(oGet2:aCols)                 
			If !oGet2:aCols[nI,len(oGet2:aCols[nI])] .AND. oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z05_NOTA'})] == 0
				Alert('A nota deve estar preenchida para todas as avaliações')   
				Return .F.
			EndIf
		Next
		                     	
		cQuery := "SELECT * FROM "+cTMPZ05  
		TCQuery cQuery New Alias "TMPZ05"
		TMPZ05->(dbGoTop())
	EndIf
		
	If nOpc == 3

	    RecLock("Z03",.T.)
	    Z03->Z03_FILIAL		:= xFilial('Z03')	
	    Z03->Z03_CODIGO  	:= cRegra
	    Z03->Z03_DESC    	:= cDesc
	    Z03->Z03_INICIO		:= dInicio
	    Z03->Z03_FIM        := dFim
		MsUnlock()

		For nI := 1 to Len(oGet:aCols)
			If !oGet:aCols[nI,len(oGet:aHeader)+1]                 
		   		RecLock("Z04",.T.)
			    Z04->Z04_FILIAL		:= xFilial('Z04')	
			    Z04->Z04_REGRA  	:= cRegra
			    Z04->Z04_CRITER    	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]
			    Z04->Z04_DESC  		:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_DESC'})] 
			    Z04->Z04_PESO       := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})] 
			    Z04->Z04_ACAO  		:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_ACAO'})] 
				MsUnlock()
			EndIf
		Next

		While !TMPZ05->(EOF()) 
		    RecLock("Z05",.T.) 
		    Z05->Z05_FILIAL		:= xFilial('Z05')	
		    Z05->Z05_REGRA  	:= cRegra
		    Z05->Z05_CRITER    	:= TMPZ05->Z05_CRITER
		    Z05->Z05_SEQ  		:= TMPZ05->Z05_SEQ 
		    Z05->Z05_VALOR1		:= TMPZ05->Z05_VALOR1
		    Z05->Z05_REGRA1		:= TMPZ05->Z05_REGRA1
		    Z05->Z05_CAMPO		:= TMPZ05->Z05_CAMPO
		    Z05->Z05_REGRA2		:= TMPZ05->Z05_REGRA2
		    Z05->Z05_VALOR2		:= TMPZ05->Z05_VALOR2
		    Z05->Z05_NOTA		:= TMPZ05->Z05_NOTA
			MsUnlock()
			TMPZ05->(DbSkip())                          
		EndDo
		TMPZ05->(dbCloseArea())
       
	ElseIf nOpc == 4
		              
	    RecLock("Z03",.F.)
	    Z03->Z03_DESC    	:= cDesc
	    Z03->Z03_INICIO 		:= dInicio
	    Z03->Z03_FIM        := dFim
		MsUnlock()
		
		DbSelectArea('Z04')
		Z04->(DbSetOrder(1))
		Z04->(DbGoTop())
		If Z04->(DbSeek(xFilial('Z04')+cRegra))                
			While !Z04->(EOF()) .AND. xFilial('Z04')+cRegra == Z04->Z04_FILIAL+Z04->Z04_REGRA    
			    RecLock("Z04",.F.)
			    DbDelete()            
				MsUnlock()                                                          
            	Z04->(DbSkip())
			EndDo    
		EndIF

		For nI := 1 to Len(oGet:aCols)     
			If !oGet:aCols[nI,len(oGet:aHeader)+1]            
			    RecLock("Z04",.T.)
			    Z04->Z04_FILIAL		:= xFilial('Z04')	
			    Z04->Z04_REGRA  	:= cRegra
			    Z04->Z04_CRITER    	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_CRITER'})]
			    Z04->Z04_DESC  		:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_DESC'})] 
			    Z04->Z04_PESO       := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_PESO'})] 
			    Z04->Z04_ACAO  		:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z04_ACAO'})] 
				MsUnlock()
			EndIf
		Next

		DbSelectArea('Z05')
		Z05->(DbSetOrder(1))
		Z05->(DbGoTop())
		If Z05->(DbSeek(xFilial('Z05')+cRegra))                
			While !Z05->(EOF()) .AND. xFilial('Z05')+cRegra == Z05->Z05_FILIAL+Z05->Z05_REGRA    
			    RecLock("Z05",.F.)
			    DbDelete()            
				MsUnlock()                                                          
            	Z05->(DbSkip())
			EndDo    
		EndIF
		
		While !TMPZ05->(EOF())   
		    RecLock("Z05",.T.) 
		    Z05->Z05_FILIAL		:= xFilial('Z05')	
		    Z05->Z05_REGRA  	:= cRegra
		    Z05->Z05_CRITER    	:= TMPZ05->Z05_CRITER
		    Z05->Z05_SEQ  		:= TMPZ05->Z05_SEQ 
		    Z05->Z05_VALOR1		:= TMPZ05->Z05_VALOR1
		    Z05->Z05_REGRA1		:= TMPZ05->Z05_REGRA1
		    Z05->Z05_CAMPO		:= TMPZ05->Z05_CAMPO
		    Z05->Z05_REGRA2		:= TMPZ05->Z05_REGRA2
		    Z05->Z05_VALOR2		:= TMPZ05->Z05_VALOR2
		    Z05->Z05_NOTA		:= TMPZ05->Z05_NOTA
			MsUnlock()
			TMPZ05->(DbSkip())                          
		EndDo
		TMPZ05->(dbCloseArea())

	ElseIf nOpc ==5 
	   
		If MsgYesNo('Deseja realmente excluir a regra atual?')
		    RecLock("Z03",.F.)
		    DbDelete()
			MsUnlock()
			
			DbSelectArea('Z04')
			Z04->(DbSetOrder(1))
			Z04->(DbGoTop())
			If Z04->(DbSeek(xFilial('Z04')+cRegra))                
				While !Z04->(EOF()) .AND. xFilial('Z04')+cRegra == Z04->Z04_FILIAL+Z04->Z04_REGRA    
				    RecLock("Z04",.F.)
				    DbDelete()            
					MsUnlock()                                                          
	            	Z04->(DbSkip())
				EndDo    
			EndIF
	
			DbSelectArea('Z05')
			Z05->(DbSetOrder(1))
			Z05->(DbGoTop())
			If Z05->(DbSeek(xFilial('Z05')+cRegra))                
				While !Z05->(EOF()) .AND. xFilial('Z05')+cRegra == Z05->Z05_FILIAL+Z05->Z05_REGRA    
				    RecLock("Z05",.F.)
				    DbDelete()            
					MsUnlock()                                                          
	            	Z05->(DbSkip())
				EndDo    
			EndIF
	
		    RecLock("Z03",.F.)
		    DbDelete()            
			MsUnlock()                                                          
		EndIf
	    
	Endif
               
return .T.
                       
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM004L
Rotina para montagem de legenda

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM004L()
Private cCadastro := "Regras de avaliação de Fornecedores"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_VERDE"		,"Regra Vigente"	},;
										{"BR_VERMELHO"	,"Regra Encerrada"}})

Return .T.

                                     


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM0043
Rotina para atualização do grid

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                                              
user Function ACOM0043(nOpc)
Local cQuery := ""      
                      
    //fazer o autoincremento do campo Z04_CRITER
    IF Empty(Alltrim(oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=="Z05_SEQ"})]))
    	oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=="Z05_SEQ"})] := Strzero(oGet2:nAt,Len(oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=="Z05_SEQ"})]))
    EndIf                 
                      
 	oGet2:Refresh()	   
 	
return