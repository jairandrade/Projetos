#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM007
Rotina para calculo mensal da avaliação do fornecedor

@return 
@author Felipe Toazza Caldeira
@since 14/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM007()
Private cCadastro := "Avaliação de Fornecedores"
Private aRotina := {}
Private cAlias := "Z08"
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  , "AxPesqui"   ,0,1})  
	AADD(aRotina,{"Visualizar" , "AxVisual" ,0,2})
	AADD(aRotina,{"Calcular"    , "U_ACOM007I" ,0,4})
	AADD(aRotina,{"Excluir"    , "AxDeleta" ,0,5})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,)
	

Return

User Function ACOM007I()
Local cPerg  := 'ACOM007'
Local cQuery := "" 

	CriaPerg(cPerg)
	              
	If !Pergunte(cPerg,.T.)
	   Return
	EndIf   
                
	cTMPZ08	:= "TMPZ08"+RetCodUsr()+Dtos(dDataBAse)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)   
	
	cQuery += " SELECT Z06_FILIAL, Z06_FORNEC, Z06_LOJA, A2_NOME, Z06_NOTA, Z06_SERIE, SUM(Z06_PTDIG) AS PONTOS "
	cQuery += " INTO "+cTMPZ08+" "             				                                       
	cQuery += " FROM "+RetSqlName('Z06')+" Z06, "+RetSqlName('SA2')+" SA2 "
	cQuery += " WHERE 
	cQuery += " Z06_FILIAL = '"+xFilial('Z06')+"' "
	cQuery += " AND Z06_FORNEC >= '"+alltrim(MV_PAR01)+"' AND Z06_FORNEC <= '"+alltrim(MV_PAR03)+"' " 
	cQuery += " AND Z06_LOJA >= '"+alltrim(MV_PAR02)+"' AND  Z06_LOJA <= '"+alltrim(MV_PAR04)+"' "
	cQuery += " AND Z06_DATA >= '"+alltrim(MV_PAR05)+alltrim(MV_PAR06)+"01' AND  Z06_DATA <= '"+alltrim(MV_PAR05)+alltrim(MV_PAR06)+"31' "
	cQuery += " AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' AND SA2.A2_COD = Z06.Z06_FORNEC AND SA2.A2_LOJA = Z06.Z06_LOJA "
	cQuery += " AND Z06.D_E_L_E_T_ != '*' "
	cQuery += " AND SA2.D_E_L_E_T_ != '*' " 
	cQuery += " GROUP BY  Z06_FILIAL, Z06_FORNEC, A2_NOME, Z06_LOJA, Z06_NOTA, Z06_SERIE "                  
			
	TcSqlExec(cQuery)	
                                       
Memowrit('c:\TEMP\ins2.txt',cQuery)

	cQuery := " SELECT TEMP.*, Z02_CLASSI
	cQuery += " FROM "+RetSqlName('Z02')+" Z02, "
	cQuery += "    (
	cQuery += " 	SELECT 
	cQuery += " 		Z06_FORNEC, Z06_LOJA, A2_NOME, SUM(PONTOS) AS PT_TOTAL, COUNT(Z06_NOTA) AS NT_TOTAL, SUM(PONTOS)/COUNT(Z06_NOTA) AS MEDIA  
	cQuery += " 	FROM "+cTMPZ08  
	cQuery += " 	GROUP BY  Z06_FORNEC, Z06_LOJA, A2_NOME
	cQuery += " 	) TEMP
	cQuery += " WHERE "
	cQuery += "      Z02_FILIAL = '"+xFilial('Z02')+"' AND Z02.D_E_L_E_T_ != '*' " 
	cQuery += "  AND MEDIA >= Z02_NTMIN AND MEDIA <= Z02_NTMAX "
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPSUM",.T., .F.)
	
	DbSelectArea("TMPSUM")
	TMPSUM->(DbGoTop())
			
                
    IF TMPSUM->(EOF())
    	Alert('Não existem resultados para os parametros informados!')
    	TMPSUM->(DbCloseArea())
    	Return
    EndIf 
     	
	GERADADOS()
    
	TMPSUM->(DbCloseArea())
	TcSqlExec('DROP TABLE '+cTMPZ08)
	
Return

Static Function Geradados()    
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aSizeAut  	:= MsAdvSize()             
Local aButtons := {}            
			
Private cCadastro 	:= 'Regras de Avaliação' 
Private oGet
		
static oDlgI           	

	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
		@ 005, 005 group oGrpCabec to 270, 505 prompt 'Avaliação de Fornecedores' of oDlgI	color 0,16777215 pixel
		GRidAval()	// Grid de Avaliacao

		ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(CONFIRMAR(),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.
                                                                                
//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRidAval
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRidAval()
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'Z08_FORNEC', 'Z08_LOJA','Z08_NOME', 'Z08_ANO', 'Z08_MES', 'Z08_PONTOS', 'Z08_CLASSI'}
	local aFieldFill	:= {}
	local aAlterFields	:= {}
	Local aField		:= {}
	Local nX
	Local bBlock		:=  {|cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
													})}
	
	
	AEval(aFields, bBlock)
	aHeader := aClone(aField)
	
	for nX := 1 to len(aHeader)
		If nX == 1
		 	aAdd(aFieldFill, StrZero(nX,aHeader[1][4]))
		Else
			aAdd(aFieldFill, criaVar(aHeader[nX][02], .F.))
		EndIf
	next
	
	aAdd(aFieldFill, .f.)
	
	DbSelectArea("TMPSUM")
	TMPSUM->(DbGoTop())
	While !TMPSUM->(EOF()) 				
		aFieldFill[1]  := TMPSUM->Z06_FORNEC
		aFieldFill[2]  := TMPSUM->Z06_LOJA  				
		aFieldFill[3]  := TMPSUM->A2_NOME  			
		aFieldFill[4]  := MV_PAR05
		aFieldFill[5]  := MV_PAR06  				
		aFieldFill[6]  := ROUND(TMPSUM->MEDIA,0)
		aFieldFill[7]  := TMPSUM->Z02_CLASSI
		  			 
		aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
		
		TMPSUM->(DbSkip())
	EndDo	

 	oGet := MsNewGetDados():New( 015, 010, 260, 500,, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	
 	
return


Static Function CONFIRMAR()

If MsgYesNo('Você irá atualizar as avaliações dos fornecedores, conforme parametros. Deseja continuar?')
	 
	Begin Transaction       
	
		Z08->(DbSetOrder(1))
	               
		DbSelectArea("TMPSUM")
		TMPSUM->(DbGoTop())
		While !TMPSUM->(EOF())
			Z08->(DbGoTop())
			If Z08->(DbSeek(xFilial('Z08')+TMPSUM->Z06_FORNEC+TMPSUM->Z06_LOJA+MV_PAR05+MV_PAR06))
				RecLock('Z08',.F.)	
				Z08->(DbDelete())
				MsUnlock()
			EndIf	
		 					       
		    RecLock('Z08',.T.)
			Z08->Z08_FILIAL := xFilial('Z08')
			Z08->Z08_FORNEC := TMPSUM->Z06_FORNEC
			Z08->Z08_LOJA 	:= TMPSUM->Z06_LOJA 
			Z08->Z08_ANO 	:= MV_PAR05 
			Z08->Z08_MES 	:= MV_PAR06 
			Z08->Z08_PONTOS := ROUND(TMPSUM->MEDIA,0) 
			Z08->Z08_CLASSI := TMPSUM->Z02_CLASSI 
		    MsUnlock()
	
			SA2->(DbGoTop())
			If SA2->(DbSeek(xFilial('SA2')+TMPSUM->Z06_FORNEC+TMPSUM->Z06_LOJA))   
				cNotaAnt := SA2->A2_NOTAFOR  
				If SA2->A2_FECHAVA <= MV_PAR05+MV_PAR06 
					RecLock('SA2',.F.)
					SA2->A2_NOTAFOR := TMPSUM->Z02_CLASSI
					SA2->A2_NOTAANT := cNotaAnt
					SA2->A2_FECHAVA := MV_PAR05+MV_PAR06     
					If TMPSUM->Z02_CLASSI == 'C'
						SA2->A2_BLQFOR := '2'					
					EndIf
					MsUnlock()                          
				EndIf
			EndIf	
			TMPSUM->(DbSkip())	
	
		EndDo
		     
		Msginfo('Fornecedores atualizados com sucesso!')
	
	End Transaction
EndIf

Return .T.                                                                                                               


/*----------------------------------------------	totvs.felipe-----------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+------------------+---------------------------------------------------------+
|Descricao         | Cria Grupo de perguntas para o relatorio                |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas                                |
+------------------+----------------------------+-----------------+----------+
| Atualizacoes                                  | Analista        | Data     |
+-----------------------------------------------+-----------------+----------+
|                                               |                 |          |
+-----------------------------------------------+-----------------+---------*/
Static Function CriaPerg(cPerg)	

//PutSX1(cPerg, "01", "Fornecedor de" , "Fornecedor de" , "Fornecedor de" , "mv_ch1", "C", TamSx3('A2_COD' )[1], TamSx3('A2_COD' )[2], 1, "G", "", "SA2", "", "", "MV_PAR01", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe o Fornecedor inicial."}, {"Informe o Fornecedor inicial."}, {"Informe o Fornecedor inicial."})
//PutSX1(cPerg, "02", "Loja de"       , "Loja de"       , "Loja de"       , "mv_ch2", "C", TamSx3('A2_LOJA')[1], TamSx3('A2_LOJA')[2], 1, "G", "", ""   , "", "", "MV_PAR02", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."})
//PutSX1(cPerg, "03", "Fornecedor até", "Fornecedor até", "Fornecedor até", "mv_ch3", "C", TamSx3('A2_COD' )[1], TamSx3('A2_COD' )[2], 0, "G", "", "SA2", "", "", "MV_PAR03", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe o Fornecedor final."  }, {"Informe o Fornecedor final."  }, {"Informe o Fornecedor final."  })
//PutSX1(cPerg, "04", "Loja Até"      , "Loja Ate"      , "Loja até"      , "mv_ch4", "C", TamSx3('A2_LOJA')[1], TamSx3('A2_LOJA')[2], 1, "G", "", ""   , "", "", "MV_PAR04", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."})
//PutSX1(cPerg, "05", "Ano"    	    , "Ano"        	  , "Ano"           , "mv_ch5", "C", 4                   , 0                   , 1, "C", "", ""   , "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   })
//PutSX1(cPerg, "06", "Mes"       	, "Mes"           , "Mes"           , "mv_ch6", "C", 2                   , 0                   , 1, "C", "", ""   , "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   })

Return
