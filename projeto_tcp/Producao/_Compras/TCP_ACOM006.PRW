#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM006
Rotina para avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM006()       

	Private cCadastro := "Avaliação de Fornecedores"
	Private aRotina := {}
	Private cAlias := "SF1" 
	Private aCores := {}
	
	aCORES := {{"SF1->F1_AVALFOR == '1' " ,"BR_VERDE" } ,;   
				{"SF1->F1_AVALFOR != '1'  " ,"BR_VERMELHO"}} 
	
	
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  , "AxPesqui"   ,0,1})  
	AADD(aRotina,{"Visualizar" , "U_ACOM006I" ,0,2})
	AADD(aRotina,{"Avaliar"    , "U_ACOM006I" ,0,3})
	AADD(aRotina,{"Alterar"    , "U_ACOM006I" ,0,4})
	AADD(aRotina,{"Excluir"    , "U_ACOM006I" ,0,5})
	AADD(aRotina,{"Lengenda"   , "U_ACOM006L" ,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,aCORES)
	

Return   
              
                       
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM006L
Rotina para montagem de legenda

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM006L()
Private cCadastro := "Avaliação de Fornecedores"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_VERDE"		,"Avaliação realizada"	},;
										{"BR_VERMELHO"	,"Avaliação não realizada"}})

Return .T.

                                                               

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM006I
Rotina para inclusão/alteração/exclusão de avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------              
User Function ACOM006I(cAlias,nReg,nOpc)
	
Private cFornece 		:= SF1->F1_FORNECE
Private cLoja 			:= SF1->F1_LOJA
Private cNome 			:= IF(!SF1->F1_TIPO$'BD',Posicione('SA2',1,xFilial('SA2')+cFornece+cLoja,"A2_NOME"),Posicione('SA1',1,xFilial('SA1')+cFornece+cLoja,"A1_NOME"))
Private cNF				:= SF1->F1_DOC
Private cSerie			:= SF1->F1_SERIE
Private cCondPgt		:= Posicione('SE4',1,xFilial('SE4')+SF1->F1_COND,"E4_COND")
Private cRegra			:= ""
Private nPontos			:= 0
Private cClassif		:= " "  
Private aNotas			:= {}
Private nLaco			:= 0

If nOpc == 3

	If SF1->F1_AVALFOR == '1'
		Alert('Nota fiscal avaliadada!')  
		Return .F.
	EndIf


	cQry := " SELECT * FROM "+RetSqlName('Z03')+" WHERE "
	cQry += "      Z03_FILIAL = '"+xFilial('Z03')+"' AND Z03_INICIO <= '"+DtoS(dDataBase)+"' "
	cQry += " AND (Z03_FIM >= '"+DtoS(dDataBase)+"' OR Z03_FIM = ' ')AND D_E_L_E_T_ != '*'  "

	If (Select("Z03REG") <> 0)
  		DbSelectArea("Z03REG")
   		Z03REG->(DbCloseArea())
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), "Z03REG",.T., .F.)
	
	DbSelectArea("Z03REG")
	Z03REG->(DbGoTop())	     
	If !Z03REG->(EOF())  
		cRegra := Z03REG->Z03_CODIGO
	Else
		Alert('Não existem regras vigentes!!!')
		Return .F.
	EndIf    
	Z03REG->(DbCloseArea())
Else
	If SF1->F1_AVALFOR != '1'
		Alert('Essa nota ainda não foi avaliada! Unica opção viável para utilização é Avaliar!')
		Return
	EndIf
EndIf

	ACOM006INC(cAlias,nReg,nOpc)


Return .T.
		   

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM006INC
Rotina para inclusão/alteração/exclusão de avaliação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------	                           
Static Function ACOM006INC(cAlias,nReg,nOpc)			
	Local aObjects  	:= {} 
	Local aPosObj   	:= {} 
	Local aSizeAut  	:= MsAdvSize()             
	Local aButtons 		:= {}            
			
	Private cCadastro 	:= 'Avaliação de Fornecedor' 
	Private oGet
	Private oGet2
	Private oGet3
	Private nLen		:= 0    
	Private cTMPZ07		:= "" 
		
	static oDlgI           	


//***************************************************************//
//Criação de tab-ela temporária que irá receber os dados enquanto //
//orçamento é digitado											 //
//***************************************************************//                          
	cTMPZ07		:= "TMPZ07"+RetCodUsr()+Dtos(dDataBAse)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
    
	If nOpc == 3
		cQuery2 := "SELECT "                                             
		cQuery2 += " *   "
		cQuery2 += " INTO "+cTMPZ07+" "             				                                       
		cQuery2 += " FROM "+RetSqlName('SD1')+" "
		cQuery2 += "     WHERE D1_FILIAL = '"+xFilial('SD1')+"' AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"' "          
		cQuery2 += " AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' "                                                       
		cQuery2 += " AND D_E_L_E_T_ != '*' "	      
	
	Else	
		cQuery2 := "SELECT "
		cQuery2 += " *   "
		cQuery2 += " INTO "+cTMPZ07+" "             				                                       
		cQuery2 += " FROM "+RetSqlName('Z07')+" "
		cQuery2 += "     WHERE Z07_FILIAL = '"+xFilial('Z07')+"' AND Z07_FORNEC = '"+SF1->F1_FORNECE+"' AND Z07_LOJA = '"+SF1->F1_LOJA+"' "          
		cQuery2 += " AND Z07_DOC = '"+SF1->F1_DOC+"' AND Z07_SERIE = '"+SF1->F1_SERIE+"' "                                                       
		cQuery2 += " AND D_E_L_E_T_ != '*' "	           
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
					
		@ 005, 005 group oGrpCabec to 060, 505 prompt ' Nota Fiscal ' of oDlgI	color 0,16777215 pixel
		DADOSCC(nOpc)// cabecalho                                          
		
		@ 070, 005 group oGrpVisual to 175, 505 prompt ' Itens ' of oDlgI color 0,16777215 pixel		
		GRIDCRIT(nOpc) // Grid de Itens  

		@ 185, 005 group oGrpImput to 270, 505 prompt ' Avaliação ' of oDlgI color 0,16777215 pixel		
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
Local cNomClass := Space(40)                   
                                                                                             
	If nOpc != 3	
		cQryCab := " SELECT Z06_REGRA, SUM(Z06_PTDIG) AS Z06_PTDIG FROM "+RetSqlName('Z06')
		cQryCab += " WHERE  "
		cQryCab += "	  Z06_FILIAL = '"+xFilial("Z06")+"' AND Z06_FORNEC = '"+SF1->F1_FORNECE+"' AND Z06_LOJA = '"+SF1->F1_LOJA+"' "
		cQryCab += " AND  Z06_NOTA = '"+SF1->F1_DOC+"' AND Z06_SERIE = '"+SF1->F1_SERIE+"' AND D_E_L_E_T_ != '*' 
		cQryCab += " GROUP BY  Z06_REGRA " 
	 
		If (Select("TMPCAB") <> 0)
	  		DbSelectArea('TMPCAB')
	   		TMPCAB->(DbCloseArea())
	    Endif
			                                                                       	
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryCab), "TMPCAB",.T., .F.)
		
		DbSelectArea("TMPCAB")
		TMPCAB->(DbGoTop())	     
		If !TMPCAB->(EOF())
		
			cQueryC := " SELECT Z02_CLASSI, Z02_SITUAC "
			cQueryC += " FROM "+RetSqlName('Z02')+" Z02 "
			cQueryC += " WHERE "
			cQueryC += "      Z02_FILIAL = '"+xFilial('Z02')+"' AND Z02.D_E_L_E_T_ != '*' " 
			cQueryC += "  AND "+Str(TMPCAB->Z06_PTDIG)+" >= Z02_NTMIN AND "+Str(TMPCAB->Z06_PTDIG)+" <= Z02_NTMAX "
			
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryC), "TMPSUM",.T., .F.)
			
			DbSelectArea("TMPSUM")
			TMPSUM->(DbGoTop())
	   	 	cClassif	:= TMPSUM->Z02_CLASSI 
	   	 	cNomClass   := TMPSUM->Z02_SITUAC  
			TMPSUM->(DbCloseArea())	
		  				
			cRegra 		:= TMPCAB->Z06_REGRA 
	   	 	nPontos 	:= TMPCAB->Z06_PTDIG  
	   	 	
		EndIf                       
		TMPCAB->(DbCloseArea()) 
	 
	EndIf	
		           
	//*********************************************************************************
	
	@ 017, 010 say 'Fornecedor	' 		size 033, 010 pixel
	@ 015, 045 get cFornece 			size 040, 010 when .F. pixel 
	@ 017, 095 say 'Loja' 				size 030, 010 pixel
	@ 015, 135 get cLoja 				size 040, 010 when .F. pixel 
	@ 017, 185 say 'Nome' 				size 030, 010 pixel
	@ 015, 225 get cNome 				size 170, 010 when .F. pixel 

	@ 032, 010 say 'Nota' 				size 020, 010 pixel
	@ 030, 045 get cNF		 			size 040, 010 when .F. pixel 
	@ 032, 095 say 'Serie' 				size 030, 010 pixel
	@ 030, 135 get cSerie 				size 040, 010 when .F. pixel 
	@ 032, 185 say 'Cond. Pgto'			size 030, 010 pixel
	@ 030, 225 get cCondPgt				size 170, 010 when .F. pixel 

	@ 047, 010 say 'Regra' 				size 020, 010 pixel
	@ 045, 045 get cRegra	 			size 040, 010 when .F. pixel 
	@ 047, 095 say 'Pontos' 			size 030, 010 pixel
	@ 045, 135 get nPontos 				size 040, 010 when .F. pixel 
	@ 047, 185 say 'Classificação'		size 033, 010 pixel
	@ 045, 225 get cClassif				size 040, 010 when .F. pixel 
	@ 045, 270 get cNomClass			size 125, 010 when .F. pixel 



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
	local aFields 		:= {'Z07_PEDIDO', 'Z07_ITEMPC' ,'Z07_ITEMNF','Z07_PRODUT','Z07_DESC','Z07_QTDNF','Z07_QTDPED','Z07_TOTAL','Z07_DTPREV','Z07_DTREAL' }
	local aFieldFill	:= {}
	local aAlterFields	:= {}
	local cQryHdr		:= ""        
	Local aRegra		:= {}
	Local aField		:= {}
	Local nX	
	Local nCrit
	
	DBSelectArea('Z07')

	AEval(aFields, { |cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
	
	// *******************************************************************
	//Busca o campo base para critério de notas, vinculando as avaliações por itens
	//********************************************************************
	
	cQryHdr := " SELECT SUBSTRING(Z04_DESC,1,10) AS TITULO, * FROM "+RetSqlName('Z04')+" WHERE "
	cQryHdr += "      Z04_FILIAL = '"+xFilial('Z04')+"' AND Z04_REGRA = '"+cRegra+"' AND Z04_ACAO = '1' AND D_E_L_E_T_ != '*' ORDER BY Z04_CRITER "

	If (Select("Z04HDR") <> 0)
  		DbSelectArea("Z04HDR")
   		Z04HDR->(DbCloseArea())
    Endif
		
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryHdr), "Z04HDR",.T., .F.)
	
	DbSelectArea("Z04HDR")
	Z04HDR->(DbGoTop())	     
	aField := {}
	While !Z04HDR->(EOF())           
		aADD(aFields,Z04HDR->TITULO)
		aAdd(aHeader,{	Z04HDR->TITULO,;
						"Z04_PESO",;
						X3PICTURE("Z04_PESO"),;
						TamSX3("Z04_PESO")[1],;
						TamSX3("Z04_PESO")[2],;
						GetSx3Cache("Z04_PESO", "X3_VALID"),;
						GetSx3Cache("Z04_PESO", "X3_USADO"),;
						FwSX3Util():GetFieldType("Z04_PESO"),;
						X3F3("Z04_PESO"),;
						GetSx3Cache("Z04_PESO", "X3_CONTEXT"),;
						X3CBOX("Z04_PESO"),;
						GetSx3Cache("Z04_PESO", "X3_RELACAO");
						})
		aADD(aAlterFields,Z04HDR->TITULO)
		AADD(aRegra,Z04HDR->Z04_CRITER)
		AADD(aNotas,0)
		Z04HDR->(DbSkip())
	EndDo              
	//*********************************************************************************

	for nX := 1 to len(aFields)
		if FieldPos(aFields[nX]) > 0
			aAdd(aFieldFill, criaVar(aFields[nX], .F.))
		Else
			aAdd(aFieldFill, criaVar('Z04_PESO', .F.))
		endIf
	next
	
	aAdd(aFieldFill, .f.)


	If nOpc == 3
                     
		If Alltrim(SF1->F1_ESPECIE) == 'CTR' .OR. Alltrim(SF1->F1_ESPECIE) == 'CTE'
			cQueryGrd := " SELECT SD1.* FROM "+RetSqlName('SD1')+" SD1 "
			cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
			cQueryGrd += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND  SD1.D_E_L_E_T_ != '*' "    
		    cTipAux := 'CTR'
		Else
			cQueryGrd := " SELECT SD1.*, SC7.* FROM "+RetSqlName('SD1')+" SD1, "+RetSqlName('SC7')+" SC7 "
			cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
			cQueryGrd += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND  SD1.D_E_L_E_T_ != '*' "   
			cQueryGrd += "   AND SD1.D1_FILIAL = SC7.C7_FILIAL AND SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM   "
			cQueryGrd += "   AND SD1.D1_COD = SC7.C7_PRODUTO AND SC7.D_E_L_E_T_ != '*' "   
			cTipAux	:= 'NFE'
		EndIf

		If (Select("TMPGRD") <> 0)
	   		DbSelectArea("TMPGRD")
	   		TMPGRD->(DbCloseArea())
	    Endif
		
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryGRD), "TMPGRD",.T., .F.)
		
		DbSelectArea("TMPGRD")
		TMPGRD->(DbGoTop())
		
		If TMPGRD->(EOF())
			Alert('Essa nota não poderá ser avaliada pois a mesma não está vinculada a Pedidos de Compras!')     
		EndIf 

        nLaco := 0
		While !TMPGRD->(EOF())
			If cTipAux == 'CTR'
				aFieldFill[1]  := TMPGRD->D1_PEDIDO 
				aFieldFill[2]  := TMPGRD->D1_ITEMPC
				aFieldFill[3]  := TMPGRD->D1_ITEM 				
				aFieldFill[4]  := TMPGRD->D1_COD  			
				aFieldFill[5]  := TMPGRD->D1_DESCRI  			
				aFieldFill[6]  := TMPGRD->D1_QUANT  			
				aFieldFill[7]  := TMPGRD->D1_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)     			
				aFieldFill[8]  := TMPGRD->D1_TOTAL  			
				aFieldFill[9]  := SF1->F1_RECBMTO   			
				aFieldFill[10]  := SF1->F1_RECBMTO
				For nCrit := 1 to Len(aRegra)   
					aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
					aNotas[nCrit] += aFieldFill[10+nCrit]	
				Next
			Else 				
				aFieldFill[1]  := TMPGRD->D1_PEDIDO
				aFieldFill[2]  := TMPGRD->D1_ITEMPC
				aFieldFill[3]  := TMPGRD->D1_ITEM 				
				aFieldFill[4]  := TMPGRD->D1_COD  			
				aFieldFill[5]  := TMPGRD->D1_DESCRI  			
				aFieldFill[6]  := TMPGRD->D1_QUANT  			
				aFieldFill[7]  := TMPGRD->C7_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)     			
				aFieldFill[8]  := TMPGRD->D1_TOTAL  			
				aFieldFill[9]  := StoD(TMPGRD->C7_DATPRF)   			
				aFieldFill[10]  := SF1->F1_RECBMTO
				For nCrit := 1 to Len(aRegra)   
					aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
					aNotas[nCrit] += aFieldFill[10+nCrit]	
				Next
			EndIf		
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
			nLaco++
			TMPGRD->(DbSkip()) 
		EndDo	                                                                                                    	
	Else		
		cQueryGrd := " SELECT * FROM "+cTMPZ07

		If (Select("TMPGRD") <> 0)
	   		DbSelectArea("TMPGRD")
	   		TMPGRD->(DbCloseArea())
	    Endif
		
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryGRD), "TMPGRD",.T., .F.)
		
		DbSelectArea("TMPGRD")
		TMPGRD->(DbGoTop())

		While !TMPGRD->(EOF()) 				
			aFieldFill[1]  := TMPGRD->Z07_PEDIDO
			aFieldFill[2]  := Posicione('SD1',1,SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+TMPGRD->Z07_PRODUT+TMPGRD->Z07_ITEMNF,"D1_ITEMPC")
			aFieldFill[3]  := TMPGRD->Z07_ITEMNF  				
			aFieldFill[4]  := TMPGRD->Z07_PRODUT  			
			aFieldFill[5]  := Posicione('SB1',1,xFilial('SB1')+TMPGRD->Z07_PRODUT,'B1_DESC')    			
			aFieldFill[6]  := TMPGRD->Z07_QTDNF   			
			aFieldFill[7]  := TMPGRD->Z07_QTDPED  			
			aFieldFill[8]  := TMPGRD->Z07_TOTAL   			
			aFieldFill[9]  := StoD(TMPGRD->Z07_DTPREV)  			
			aFieldFill[10]  := StoD(TMPGRD->Z07_DTREAL) 			

			DbSelectArea('Z06')
			Z06->(DbSetOrder(1))
		  
			For nCrit := 1 to Len(aRegra)
				Z06->(DbGoTop())
				Z06->(DbSeek(xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+aRegra[nCrit]))   
			   	aFieldFill[10+nCrit]  :=   Z06->Z06_PTDIG
				//aNotas[nCrit] += aFieldFill[9+nCrit]	
			Next		
		
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
			
			TMPGRD->(DbSkip())
		EndDo
	EndIf   
	
	If (Select("TMPGRD") <> 0)
   		DbSelectArea("TMPGRD")
   		TMPGRD->(DbCloseArea())
    Endif
	
 	oGet := MsNewGetDados():New( 080, 010, 165, 500, GD_UPDATE, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	 
 	
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
	local aFields 		:= {'Z06_CRITER','Z06_DCRITE','Z06_PESO','Z06_PONTOS','Z06_PTDIG','Z06_OBS'}
	local aFieldFill	:= {}
	Local nX
	local aAlterFields	:= {'Z06_PTDIG','Z06_OBS'}
	Local aField		:= {}
	
	AEval(aFields,  {|cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
		 	aAdd(aFieldFill, StrZero(nX,TamSX3('Z06_CRITER')[1]))
		Else
			aAdd(aFieldFill, criaVar(aFields[nX], .F.))
		EndIf
	next
	
	aAdd(aFieldFill, .f.)     
	        
	If nOpc == 3
		nPontos := 0

		DbSelectArea('Z04')
		Z04->(DbSetOrder(1))
		Z04->(DbGoTop())
		Z04->(DbSeek(xFilial('Z04')+cRegra))
                     
		nAux := 1  
		While !Z04->(EOF()) .AND. xFilial('Z04')+Z04->Z04_REGRA == xFilial('Z04')+cRegra
			aFieldFill[1]  := Z04->Z04_CRITER
			aFieldFill[2]  := Z04->Z04_DESC  				
			aFieldFill[3]  := Z04->Z04_PESO 
			aFieldFill[4]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))  
			aFieldFill[5]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))  			
			aFieldFill[6]  := Space(len(Z06->Z06_OBS))  				
			 	
			nPontos += aFieldFill[5] 	
			 			
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
			nAux++
			Z04->(DbSkip())
		EndDo	

	Else
		DbSelectArea('Z06')
		Z06->(DbSetOrder(1))
		Z06->(DbGoTop())
		Z06->(DbSeek(xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))

		While !Z06->(EOF()) .AND. xFilial('Z06')+Z06->Z06_FORNEC+Z06->Z06_LOJA+Z06->Z06_NOTA+Z06->Z06_SERIE == xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE
			aFieldFill[1]  := Z06->Z06_CRITER
			aFieldFill[2]  := Z06->Z06_DCRITER  				
			aFieldFill[3]  := Z06->Z06_PESO 
			aFieldFill[4]  := Z06->Z06_PONTOS   
			aFieldFill[5]  := Z06->Z06_PTDIG
			aFieldFill[6]  := Z06->Z06_OBS  				
			 			
			aAdd(aCols, aClone(aFieldFill))		                                                                                                    			
			       
			Z06->(DbSkip())
		EndDo	
	EndIf		

 	oGet2 := MsNewGetDados():New( 195, 010, 265, 500,GD_UPDATE, 'U_ACOM006C', 'AllwaysTrue', '', aAlterFields, , 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	

return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM006C
Rotina para validação de NOTAS

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                  
User Function ACOM006C()
Local lRet  := .T.
Local nI
	If oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PONTOS'})] != oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PTDIG'})]   .AND. ;
		Empty(Alltrim(oGet2:aCols[oGet2:nAt,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_OBS'})]))		  
		MsgInfo('É obrigatória a digitação da observação quando uma pontuação for alterada!')
		lRet := .F.  
	EndIf			
                      
	For nI := 1 to Len(oGet2:aCols) 
		nPontos := oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PTDIG'})]
	Next		                                        
		
	cQueryC := " SELECT Z02_CLASSI, Z02_SITUAC "
	cQueryC += " FROM "+RetSqlName('Z02')+" Z02 "
	cQueryC += " WHERE "
	cQueryC += "      Z02_FILIAL = '"+xFilial('Z02')+"' AND Z02.D_E_L_E_T_ != '*' " 
	cQueryC += "  AND "+Str(nPontos)+" >= Z02_NTMIN AND "+Str(nPontos)+" <= Z02_NTMAX "
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryC), "TMPSUM",.T., .F.)
			
	DbSelectArea("TMPSUM")
	TMPSUM->(DbGoTop())
 	cClassif	:= TMPSUM->Z02_CLASSI 
 	cNomClass   := TMPSUM->Z02_SITUAC  
	TMPSUM->(DbCloseArea())	

oDlgI:Refresh()		  	
		  				                                                                                                               	
Return(lRet)      

                               
//-------------------------------------------------------------------------------
/*/{Protheus.doc} CONFIRMAR
Rotina para inserção das ações

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
                  
Static Function CONFIRMAR(nOpc)
	Local cAnoFech 	:= ''
	Local cMesFech 	:= ''
	Local lRet		:= .T.
	Local nI
	If nOpc == 2
		Return .T.
	EndIf              
        
	Begin Transaction

	If nOpc == 3

		For nI := 1 to Len(oGet:aCols)
			If !oGet:aCols[nI,len(oGet:aHeader)+1]                 
		   		RecLock("Z07",.T.)
			    Z07->Z07_FILIAL		:= xFilial('Z07')	
			    Z07->Z07_FORNECE  	:= SF1->F1_FORNECE
			    Z07->Z07_LOJA    	:= SF1->F1_LOJA
			    Z07->Z07_DOC  		:= SF1->F1_DOC
			    Z07->Z07_SERIE     	:= SF1->F1_SERIE         
			    Z07->Z07_REGRA      := cRegra
			    Z07->Z07_PEDIDO     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_PEDIDO'})]
			    Z07->Z07_ITEMNF     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_ITEMNF'})]
			    Z07->Z07_PRODUT     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_PRODUT'})]
			    Z07->Z07_QTDNF      := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_QTDNF'})]
			    Z07->Z07_QTDPED     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_QTDPED'})]
			    Z07->Z07_TOTAL      := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_TOTAL'})]
			    Z07->Z07_DTPREV     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_DTPREV'})]
			    Z07->Z07_DTREAL     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_DTREAL'})] 
 //			    xAux := 
			    If LEN(oGet:aCols[nI]) >= 11 .AND. VALTYPE(oGet:aCols[nI,11]) == 'N'
					Z07->Z07_AVAL01		:= oGet:aCols[nI,11]     
				EndIf         
			    If LEN(oGet:aCols[nI]) >= 12 .AND. VALTYPE(oGet:aCols[nI,12]) == 'N' 
					Z07->Z07_AVAL02		:= oGet:aCols[nI,12]     
				EndIf
			    If LEN(oGet:aCols[nI]) >= 13 .AND. VALTYPE(oGet:aCols[nI,13]) == 'N'
					Z07->Z07_AVAL03		:= oGet:aCols[nI,13]     
				EndIf
			    If LEN(oGet:aCols[nI]) >= 14 .AND. VALTYPE(oGet:aCols[nI,14]) == 'N'
					Z07->Z07_AVAL04		:= oGet:aCols[nI,14]
				Else
					Z07->Z07_AVAL04		:= oGet2:aCols[Len(oGet2:aCols),aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PTDIG'})]      
				EndIf
			    If LEN(oGet:aCols[nI]) >= 15 .AND. VALTYPE(oGet:aCols[nI,15]) == 'N' 
					Z07->Z07_AVAL05		:= oGet:aCols[nI,15]     
				EndIf
				Z07->Z07_COMPRA			:= SF1->F1_IDCOMPR
				MsUnlock()
			EndIf
		Next

		For nI := 1 to Len(oGet2:aCols)
			If !oGet2:aCols[nI,len(oGet2:aHeader)+1]                 
		   		RecLock("Z06",.T.)  
			    Z06->Z06_FILIAL		:= xFilial('Z06')	
			    Z06->Z06_FORNEC  	:= SF1->F1_FORNECE
			    Z06->Z06_LOJA    	:= SF1->F1_LOJA
			    Z06->Z06_NOTA  		:= SF1->F1_DOC
			    Z06->Z06_SERIE     	:= SF1->F1_SERIE         
			    Z06->Z06_REGRA  	:= cRegra
			    Z06->Z06_CRITER    	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_CRITER'})]
			    Z06->Z06_DCRITE    	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_DCRITE'})]
			    Z06->Z06_PESO  		:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PESO'})] 
			    Z06->Z06_PONTOS     := oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PONTOS'})] 
			    Z06->Z06_PTDIG 		:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PTDIG'})] 
			    Z06->Z06_OBS     	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_OBS'})]      
			    Z06->Z06_DATA		:= SF1->F1_RECBMTO   
			    Z06->Z06_COMPRA		:= SF1->F1_IDCOMPR
				MsUnlock()
			EndIf
		Next  
		            
		RecLock("SF1",.F.)
		SF1->F1_AVALFOR := '1'
		MsUnlock()
		
	ElseIf nOpc == 4
        
		DbSelectArea('Z08')
		Z08->(DbSetOrder(1))
		Z08->(DbGoTop())
		If Z08->(DbSeek(xFilial('Z08')+SF1->F1_FORNECE+SF1->F1_LOJA))
			cAnoFech := Z08->Z08_ANO
			cMesFech := Z08->Z08_MES						                                                           
		EndIf

		DbSelectArea('Z06')
		Z06->(DbSetOrder(1))
		Z06->(DbGoTop())
		If Z06->(DbSeek(xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
			If Substr(DtoS(Z06->Z06_DATA),1,4) <= cAnoFech .AND. Substr(DtoS(Z06->Z06_DATA),4,2) <= cMesFech
				Alert('Não é possível alterar classificação de nota que tenha mês fechado!')			     
				lRet := .F.
			EndIf
			If lRet                
				While !Z06->(EOF()) .AND. xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE == Z06->Z06_FILIAL+Z06->Z06_FORNEC+Z06->Z06_LOJA+Z06->Z06_NOTA+Z06->Z06_SERIE    
					RecLock("Z06",.F.)
					DbDelete()            
					MsUnlock()                                                          
					Z06->(DbSkip())
				EndDo    
			EndIf
		EndIF
		If lRet
			For nI := 1 to Len(oGet2:aCols)
				If !oGet2:aCols[nI,len(oGet2:aHeader)+1]                 
					RecLock("Z06",.T.)  
					Z06->Z06_FILIAL		:= xFilial('Z06')	
					Z06->Z06_FORNEC  	:= SF1->F1_FORNECE
					Z06->Z06_LOJA    	:= SF1->F1_LOJA
					Z06->Z06_NOTA  		:= SF1->F1_DOC
					Z06->Z06_SERIE     	:= SF1->F1_SERIE         
					Z06->Z06_REGRA  	:= cRegra
					Z06->Z06_CRITER    	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_CRITER'})]
					Z06->Z06_DCRITE    	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_DCRITE'})]
					Z06->Z06_PESO  		:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PESO'})] 
					Z06->Z06_PONTOS     := oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PONTOS'})] 
					Z06->Z06_PTDIG 		:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_PTDIG'})] 
					Z06->Z06_OBS     	:= oGet2:aCols[nI,aScan(oGet2:aHeader,{|x|allTrim(x[2])=='Z06_OBS'})] 
					Z06->Z06_DATA		:= SF1->F1_RECBMTO   
					Z06->Z06_COMPRA		:= SF1->F1_IDCOMPR
					MsUnlock()
				EndIf
			Next

			DbSelectArea('Z07')
			Z07->(DbSetOrder(1))
			Z07->(DbGoTop())
			If Z07->(DbSeek(xFilial('Z07')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))                
				While !Z07->(EOF()) .AND. xFilial('Z07')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE == Z07->Z07_FILIAL+Z07->Z07_FORNECE+Z07->Z07_LOJA+Z07->Z07_DOC+Z07->Z07_SERIE    
					RecLock("Z07",.F.)
					DbDelete()            
					MsUnlock()                                                          
					Z07->(DbSkip())
				EndDo    
			EndIF

			For nI := 1 to Len(oGet:aCols)
				If !oGet:aCols[nI,len(oGet:aHeader)+1]                 
					RecLock("Z07",.T.)
					Z07->Z07_FILIAL		:= xFilial('Z07')	
					Z07->Z07_FORNECE  	:= SF1->F1_FORNECE
					Z07->Z07_LOJA    	:= SF1->F1_LOJA
					Z07->Z07_DOC  		:= SF1->F1_DOC
					Z07->Z07_SERIE     	:= SF1->F1_SERIE         
					Z07->Z07_REGRA      := cRegra
					Z07->Z07_PEDIDO     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_PEDIDO'})]
					Z07->Z07_ITEMNF     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_ITEMNF'})]
					Z07->Z07_PRODUT     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_PRODUT'})]
					Z07->Z07_QTDNF      := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_QTDNF'})]
					Z07->Z07_QTDPED     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_QTDPED'})]
					Z07->Z07_TOTAL      := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_TOTAL'})]
					Z07->Z07_DTPREV     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_DTPREV'})]
					Z07->Z07_DTREAL     := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='Z07_DTREAL'})]
					MsUnlock()
				EndIf
			Next
		EndIf
                   
	ElseIf nOpc == 5    

		If MsgYesNo('Deseja Realmente excluir a avaliação?')
	
			DbSelectArea('Z08')
			Z08->(DbSetOrder(1))
			Z08->(DbGoTop())
			If Z08->(DbSeek(xFilial('Z08')+SF1->F1_FORNECE+SF1->F1_LOJA))
				cAnoFech := Z08->Z08_ANO
				cMesFech := Z08->Z08_MES						                                                           
			EndIf
	
			DbSelectArea('Z06')
			Z06->(DbSetOrder(1))
			Z06->(DbGoTop())
			If Z06->(DbSeek(xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
				If Substr(DtoS(Z06->Z06_DATA),1,4) <= cAnoFech .AND. Substr(DtoS(Z06->Z06_DATA),4,2) <= cMesFech
					Alert('Não é possível excluir classificação de uma nota que tenha mes fechado!')			     
					lRet := .F.
				EndIf                
				If lRet
					While !Z06->(EOF()) .AND. xFilial('Z06')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE == Z06->Z06_FILIAL+Z06->Z06_FORNEC+Z06->Z06_LOJA+Z06->Z06_NOTA+Z06->Z06_SERIE    
						RecLock("Z06",.F.)
						DbDelete()            
						MsUnlock()                                                          
						Z06->(DbSkip())
					EndDo   
				EndIf 
			EndIF
			If lRet
				DbSelectArea('Z07')
				Z07->(DbSetOrder(1))
				Z07->(DbGoTop())
				If Z07->(DbSeek(xFilial('Z07')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))                
					While !Z07->(EOF()) .AND. xFilial('Z07')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE == Z07->Z07_FILIAL+Z07->Z07_FORNECE+Z07->Z07_LOJA+Z07->Z07_DOC+Z07->Z07_SERIE    
						RecLock("Z07",.F.)
						DbDelete()            
						MsUnlock()                                                          
						Z07->(DbSkip())
					EndDo    
				EndIF
		
				RecLock("SF1",.F.)
				SF1->F1_AVALFOR := ' '
				MsUnlock()
			EndIf
		EndIF
			
	Endif
         
 	End Transaction 

	If lRet             
		// artificio para não abrir a tela novamente. Alterando o nOpc no arotina não houve efeito.  
		IF nOpc == 3
			nOpc := 4
		EndIf       
	EndIf
           
return lRet
                       
                                                       
Static Function CalcRegra(cRegra,cCritic)
Local nPt 		:= 0      
Local cCampoUt 	:= ""
Local cTabela	:= ""        
Local cQryReg 	:= ""		            
Local cQryPt	:= ""              

Private xComp

          
DbSelectArea('Z05')
Z05->(DbSetOrder(1))
Z05->(DbGotop())
If Z05->(DbSeek(xFilial('Z05')+cRegra+cCritic)) 				//PROCURA REGRA QUE ESTÁ SENDO UTILIZADA
	cCampoUt := Z05->Z05_CAMPO 									// VERIFICA QUAL O CAMPO DE COMPARAÇÃO    
	cTabAux := SubStr(Z05->Z05_CAMPO,1,AT("_",Z05->Z05_CAMPO)-1) 	// BUSCA NOME DA TABELA  
	If Len(Alltrim(cTabAux)) == 2 								// verificar se é uma tabela iniciada com S ou não 
		cTabela := "S"+cTabAux  
	Else 
		cTabela := cTabAux
	EndIf             
       
    // ==============================================
    // BUSCA INFORMAÇÕES PARA COMPARAÇÃO
    //===============================================
	If cTabela == 'SD1'
		cQryReg := " SELECT D1_PEDIDO, D1_ITEMPC, SUM("+cCampoUt+") AS "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     D1_FILIAL = '"+xFilial(cTabela)+"' AND D1_DOC = '"+TMPGRD->D1_DOC+"' AND D1_SERIE = '"+TMPGRD->D1_SERIE+"' 
		cQryReg += " AND D1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND D1_LOJA = '"+TMPGRD->D1_LOJA+"' AND D1_COD = '"+TMPGRD->D1_COD+"' "
		cQryReg += " AND D1_PEDIDO = '"+TMPGRD->D1_PEDIDO+"' AND D1_ITEMPC = '"+TMPGRD->D1_ITEMPC+"' AND D_E_L_E_T_ != '*' "                                                                                                       
		cQryReg += " GROUP BY D1_PEDIDO, D1_ITEMPC "
	ElseIf cTabela == 'SF1'
		cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOC = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERIE = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND "+cTabAux+"_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		
	ElseIf cTabela == 'QI2'
		cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOCNF = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERNF = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND "+cTabAux+"_CODFOR = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJFOR = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		

	EndIf			

	If (Select("CALCREG") <> 0)
  		DbSelectArea("CALCREG")
   		CALCREG->(DbCloseArea())                
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCREG",.T., .F.)
	
	DbSelectArea("CALCREG")
	CALCREG->(DbGoTop())	     
    // ==============================================

	If cTabela == 'SD1'
		xComp := IIF(cTipAux!='CTR',CALCREG->&cCAmpoUt/TMPGRD->C7_QUANT,1) //IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)   // MONTA PERCENTUAL DA REGRA              
	ElseIf cTabela == 'SF1'
		xComp := StoD(CALCREG->&cCAmpoUt)-IIF(cTipAux!='CTR',StoD(TMPGRD->C7_DATPRF),StoD(CALCREG->&cCAmpoUt))   // MONTA PERCENTUAL DA REGRA              
	ElseIf cTabela == 'QI2'
		xComp := IIF(!Empty(Alltrim(CALCREG->&cCAmpoUt)),1,0) 
	EndIf			    

    // ===========================================================
    // NOVA REGRA PARA PEDIDOS PARCIAIS ENTREGUES DENTRO DO PRAZO
    //============================================================	                                                                                                                    
	If cTabela == 'SD1' .AND. xComp < 1

		cQryReg := " SELECT F1_RECBMTO   FROM "+RetSqlName('SF1')
		cQryReg += " WHERE "
		cQryReg += "     F1_FILIAL = '"+xFilial('SF1')+"' AND F1_DOC = '"+TMPGRD->D1_DOC+"' AND F1_SERIE = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND F1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND F1_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCALT",.T., .F.)

		DbSelectArea("CALCALT")
		CALCALT->(DbGoTop())	     
		If StoD(TMPGRD->C7_DATPRF)-StoD(CALCALT->F1_RECBMTO) > 0 
			xComp := 1	
		EndIF	        
		CALCALT->(DbCloseArea())	     		
	EndIf	    
    // ==============================================
    // BUSCA INFORMAÇÕES DA REGRA PARA CALCULO
    //===============================================	                                                                                                                    
	cQryPt := " SELECT * FROM "+RetSqlName('Z05')
	cQryPt += " WHERE "
	cQryPt += "      Z05_FILIAL = '"+xFilial('Z05')+"' AND Z05_REGRA = '"+cRegra+"' AND Z05_CRITER = '"+cCritic+"' AND D_E_L_E_T_ != '*' "
	
	If (Select("CALCPT") <> 0)
  		DbSelectArea("CALCPT")
   		CALCPT->(DbCloseArea())
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryPt), "CALCPT",.T., .F.)
	
	DbSelectArea("CALCPT")
	CALCPT->(DbGoTop())	   
	
	While !CALCPT->(EOF())    
	    // ==============================================
	    // ANALISA REGRA DE COMPARAÇÃO
   	 	//===============================================
        
        If Empty(Alltrim(CALCPT->Z05_REGRA2)) 		// SE TIVER COMPARAÇÃO COM 1 REGRA
        
			If CALCPT->Z05_REGRA1 == '1'
				cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
			ElseIf CALCPT->Z05_REGRA1 == '2'
				cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '3'
				cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
			ElseIf CALCPT->Z05_REGRA1 == '4'
				cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '5'
				cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
			EndIF		
	
	        // ==============================================
		    // VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
   			//===============================================
	        If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp    
	       		nPt := CALCPT->Z05_NOTA  
	            Exit
	        EndIf
	   	
		Else
			If CALCPT->Z05_REGRA1 == '1'
				cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
			ElseIf CALCPT->Z05_REGRA1 == '2'
				cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '3'
				cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
			ElseIf CALCPT->Z05_REGRA1 == '4'
				cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '5'
				cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
			EndIF		

                   // regra invertida para compreender a necessidade
			If CALCPT->Z05_REGRA2 == '1'
				cRegra1 += ' .AND. xComp < CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '2'
				cRegra1 += ' .AND. xComp <= CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '3'
				cRegra1 += ' .AND. xComp = CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '4'
				cRegra1 += ' .AND. xComp >= CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '5'                             
				cRegra1 += ' .AND. xComp > CALCPT->Z05_VALOR2/100 '
			EndIF
		                        
	        // ==============================================
		    // VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
   			//===============================================
	        If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp    
	       		nPt := CALCPT->Z05_NOTA
	       		Exit
	        EndIf	    
	    EndIf
	      
		CALCPT->(DbSkip())
	EndDo  

	CALCPT->(DbCloseArea())
	CALCREG->(DbCloseArea())
 
Else
	Alert('Problemas ao encontrar forma de cálculo para a Regra '+cRegra+'/'+cCritic)
EndIf  

Z05->(DbCLoseArea())

Return nPt

	