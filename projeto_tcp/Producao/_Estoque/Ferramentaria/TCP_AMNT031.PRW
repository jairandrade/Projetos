#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT031
Solicitação de ferramentas

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function AMNT031()                    
Private cCadastro := "Emprestimo Ferramentas"
Private aRotina := {}
Private cAlias := "Z12"
Private aCores := {}                 
	
	aCORES := {{"Z12->Z12_STATUS == '1' " ,"BR_AMARELO" } ,;   
				{"Z12->Z12_STATUS == '2'  " ,"BR_VERDE"},;
				{"Z12->Z12_STATUS == '3'  " ,"BR_VERMELHO"}} 
	
	
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  	, "AxPesqui"   				,0,1})  
	AADD(aRotina,{"Visualizar" 	, "U_AMNT031I('Z12',,2)"	,0,2})
	AADD(aRotina,{"Incluir"    	, "U_AMNT031I('Z12',,3)" 	,0,3})
	AADD(aRotina,{"Excluir"    	, "U_AMNT031D()" 			,0,5})
	AADD(aRotina,{"Imprimir"   	, "U_RMNT032()" 			,0,6})
	AADD(aRotina,{"Legenda"   	, "U_AMNT031L()" 			,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,aCORES)//
	
Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT031I
Inclusão Emprestimos Ferramentas

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT031I( cAlias, nReg, nOpc )
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aCpo			:= {"Z12_NUM","Z12_MATRIC","Z12_NOME","Z12_DTEMP","Z12_HREMP"}
Local aSizeAut  	:= MsAdvSize()             
Local aButtons 		:= {}                       
Local aCpoAlt		:= {"Z12_MATRIC"}
Local nX
Private bCampo    	:= {|nField| FieldName(nField) }			
Private cCadastro 	:= 'Emprestimo de Ferramentas' 
Private oGet             
Private cMatricula	:= Space(6)
		
static oDlgI           	

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	dbSelectArea("Z12")
	Z12->(dbSetOrder(1))
	
	For nX := 1 To FCount()
		M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
	Next nX
		
	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
	Enchoice( cAlias, nReg, nOpc,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
	GridCrit(nOpc)// cabecalho                                          
	
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| IIF(nOpc==3,If(Gravadado(),oDlgI:end(),Nil),oDlgI:end()) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.


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
	local aFields 		:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER'}
	local aFieldFill	:= {}
	local aAlterFields	:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER'}
	Local cNum			:= ""
	Local aField 		:= {}
	Local bBlock :=  {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
												cField,;
												X3PICTURE(cField),; 
												TamSX3(cField)[1],;
												TamSX3(cField)[2],;
												GetSx3Cache(cField, "X3_VALID"),;
												GetSx3Cache(cField, "X3_USADO"),;
												FwSX3Util():GetFieldType(cField),;
												GetSx3Cache(cField, "X3_F3"),;
												GetSx3Cache(cField, "X3_CONTEXT"),;
												X3CBOX(cField),;
												GetSx3Cache(cField, "X3_RELACAO");
												})}
	
	aEval(aFields,bBlock)
	aHeader := aClone(aField)
	
	If nOpc == 3
		aEval(aHeader,{|aCampos| aAdd(aFieldFill,CriaVar(aCampos[2],.F.))})
		aAdd(aFieldFill, .f.)
		aAdd(aCols, aClone(aFieldFill))                                                   			
	Else
		DbSelectArea('Z13')
		Z13->(DbSetOrder(1))
		Z13->(DbGoTop())
		Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM))
		While !Z13->(Eof()) .AND. Z12->Z12_FILIAL+Z12->Z12_NUM == Z13->Z13_FILIAL+Z13->Z13_NUM
			aFieldFill := {}
			aAdd(aFieldFill, Z13->Z13_FERRAM)        
			aAdd(aFieldFill, Posicione('SB1',1,xFilial()+Z13->Z13_FERRAM,'B1_DESC'))        
			aAdd(aFieldFill, Z13->Z13_NUMSER)
			aAdd(aFieldFill, .f.)
			aAdd(aCols, aClone(aFieldFill))		     
			Z13->(DbSkip())
		EndDo
		
	EndIf
	
 	oGet := MsNewGetDados():New( 090, 010, 275, 500	, Iif(nOpc==3,GD_INSERT+GD_DELETE+GD_UPDATE,), 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)
 	//oGet := MsNewGetDados():New( 060, 010, 275, 500	, Iif(nOpc==3,GD_INSERT+GD_DELETE+GD_UPDATE,), 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	 
 	
return
                 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} Gravadado
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GravaDado                    
	Local aItens 	:= {}            
	Local aAuto 	:= {}
	Local cDocumento:= ""
	Local nI
	Local lRet		:= .T.	
	Local _FerEmp   := GetMv("TCP_FEREMP")
	Local _EstTrop  := GetMv("TCP_ESTROP")
	Z12->(ConfirmSX8())    
						
	cDocumento := GetSxENum("SD3","D3_DOC",1)
	Private cSenhaAtu	:= Space(10)
	Private lMsErroAuto := .F.                                    
	Private aCampos := {{"Z14_COMPON"	,"","Item","@!" },;
						{"Z14_COMSER"	,"","N. Serie","@!" },;
						{"Z14_FERRAM"	,"","Ferramenta","@!" },;
						{"Z14_NUMSER"	,"","N. Serie","@!" };					
						}
	Private aRotina := {}

	aRotina := {{"Continuar" 	,'CloseBrowse()',0,6}}

	If Empty(Alltrim(M->Z12_MATRIC))
		Alert('A matricula do funcionário deve ser informada!')
		Return .F.
	EndIf


	aTemp := {	{"Z14_OK" 		,"C",02,0},;
				{"Z14_COMPON"	,"C",15,0},;
				{"Z14_COMSER"	,"C",12,0},;
				{"Z14_FERRAM"	,"C",15,0},;
				{"Z14_NUMSER"	,"C",12,0};
				}
	//cArqTmp := CriaTrab(aTemp)
	//dbUseArea( .T.,, cArqTmp, "_TRB", .F., .F. )

	oTempTable := FWTemporaryTable():New( "_TRB" )
	oTemptable:SetFields( aTemp )
	oTempTable:Create()
	cArqTmp := oTempTable:GetRealName()

	For nI := 1 To len(oGet:aCols)    
		If !oGet:aCols[nI][4]		
			cQuery := " SELECT DB_DOC, DB_ORIGEM "
			cQuery += " FROM "+RetSqlName('SDB')+" SDB, "+RetSqlName('SDA')+" SDA "
			cQuery += " WHERE "
			cQuery += "     DB_FILIAL = '"+xFilial('SDB')+"' AND DB_PRODUTO = '"+oGet:aCols[nI][1]+"' AND SDB.D_E_L_E_T_ != '*' "
			cQuery += " AND DB_NUMSERI = '"+oGet:aCols[nI][3]+"' AND DB_TM = '499' "
			cQuery += " AND DA_FILIAL = '"+xFilial('SDA')+"' AND DA_PRODUTO = '"+oGet:aCols[nI][1]+"' AND SDA.D_E_L_E_T_ != '*' "
			cQuery += " AND DA_DOC = DB_DOC "		
			cQuery += " ORDER BY DB_IDOPERA DESC "		
			cQuery := ChangeQuery(cQuery)
	
			If Select("TRBSER")<>0
				DBSelectArea("TRBSER")
				TRBSER->(DBCloseArea())
			EndIf
			TCQuery cQuery New Alias "TRBSER"
			
			DbSelectArea('TRBSER')
			TRBSER->(DbGoTop())
			
			IF !TRBSER->(EOF())
				cOP := TRBSER->DB_DOC
			Else                   
				Reclock("_TRB",.T.)
				_TRB->Z14_COMPON  	:= oGet:aCols[nI][1]
				_TRB->Z14_COMSER  	:= oGet:aCols[nI][3]                   
				_TRB->Z14_FERRAM  	:= oGet:aCols[nI][1]
				_TRB->Z14_NUMSER  	:= oGet:aCols[nI][3]
				MsUnlock()
				AADD(aItens,{oGet:aCols[nI][1], oGet:aCols[nI][3],.F.})
				Loop
			EndIf                      
			TRBSER->(DBCloseArea())
	
			cQuery := " SELECT DISTINCT DB_PRODUTO, DB_NUMSERI "
			cQuery += " FROM "+RetSqlName('SDB')+" SDB "
			cQuery += " WHERE "
			cQuery += "     DB_FILIAL = '"+xFilial('SDB')+"' AND DB_DOC = '"+cOP+"' AND D_E_L_E_T_ != '*' AND (DB_ORIGEM = 'SC2' OR (DB_ORIGEM = 'SD3' AND DB_DOC = 'INVENT' AND DB_PRODUTO = '"+oGet:aCols[nI][1]+"'))"
			cQuery := ChangeQuery(cQuery)
	
			If Select("TRBSER")<>0
				DBSelectArea("TRBSER")
				TRBSER->(DBCloseArea())
			EndIf
			TCQuery cQuery New Alias "TRBSER"
			
			DbSelectArea('TRBSER')
			TRBSER->(DbGoTop())
	
			If TRBSER->(EOF())
				AADD(aItens,{oGet:aCols[nI][1], oGet:aCols[nI][3],.F.})

  				Reclock("_TRB",.T.)
				_TRB->Z14_COMPON  	:= oGet:aCols[nI][1]
				_TRB->Z14_COMSER  	:= oGet:aCols[nI][3]                  
				_TRB->Z14_FERRAM  	:= oGet:aCols[nI][1]
				_TRB->Z14_NUMSER  	:= oGet:aCols[nI][3]
				MsUnlock()	

			EndIf
			
			While !TRBSER->(EOF())       
				Reclock("_TRB",.T.)
				_TRB->Z14_COMPON  	:= TRBSER->DB_PRODUTO
				_TRB->Z14_COMSER  	:= TRBSER->DB_NUMSERI                     
				_TRB->Z14_FERRAM  	:= oGet:aCols[nI][1]
				_TRB->Z14_NUMSER  	:= oGet:aCols[nI][3]
				MsUnlock()	
				AADD(aItens,{TRBSER->DB_PRODUTO, TRBSER->DB_NUMSERI,.F.})
	        	TRBSER->(DBSkip())
			EndDo                      
			TRBSER->(DBCloseArea())				

		EndIf
	Next

	dbSelectArea("_TRB")
	DbGotop()
	MarkBrow("_TRB","Z14_OK",,aCampos)
	_TRB->(DbCloseArea())
	


	AMNT031S() 
    If Empty(Alltrim(cSenhaAtu))
		Alert('A senha não foi informada!')
		freeObj(oTempTable)
		oTemptable := nil
		Return .F.
	EndIf
	                                      
	DbSelectArea('Z11')
	Z11->(DbSetOrder(1))
	Z11->(DbGoTop())
	Z11->(DbSeek(xFilial('Z11')+M->Z12_MATRIC))
	If Alltrim(Z11->Z11_SENHA) != Alltrim(Embaralha(cSenhaAtu,0))
		Alert('A senha digitada é diferente da senha do funcionário!')
		freeObj(oTempTable)
		oTemptable := nil
		Return .F.
	EndIf
	
	Begin Transaction
	                              
	RecLock('Z12',.T.)
	Z12->Z12_FILIAL := xFilial('Z13')
	Z12->Z12_NUM    := M->Z12_NUM
	Z12->Z12_MATRIC	:= M->Z12_MATRIC
	Z12->Z12_DTEMP 	:= M->Z12_DTEMP 
	Z12->Z12_HREMP 	:= M->Z12_HREMP 
	Z12->Z12_STATUS := '1'
	MsUnlock()
                                  
	For nI := 1 To len(oGet:aCols)    
		If !oGet:aCols[nI][4]            		                      
			RecLock('Z13',.T.)
			Z13->Z13_FILIAL := xFilial('Z13')
			Z13->Z13_NUM    := M->Z12_NUM
			Z13->Z13_MATRIC	:= M->Z12_MATRIC
			Z13->Z13_FERRAM := oGet:aCols[nI][1] 			
			Z13->Z13_QTDE   := 1.00//oGet:aCols[nI][3] 			
			Z13->Z13_STATUS := '1'
			Z13->Z13_NUMSER := oGet:aCols[nI][3] 			
			Z13->Z13_DTEMPR	:= dDataBase
			Z13->Z13_DTPREV := dDataBase+Posicione('SB1',1,xFilial('SB1')+oGet:aCols[nI][1],"B1_XDIASDV")
			MsUnlock()
		EndIf 
		
		cQuery := " SELECT DB_DOC, DB_ORIGEM "
		cQuery += " FROM "+RetSqlName('SDB')+" SDB, "+RetSqlName('SDA')+" SDA "
		cQuery += " WHERE "
		cQuery += "     DB_FILIAL = '"+xFilial('SDB')+"' AND DB_PRODUTO = '"+oGet:aCols[nI][1]+"' AND SDB.D_E_L_E_T_ != '*' "
		cQuery += " AND DB_NUMSERI = '"+oGet:aCols[nI][3]+"' AND DB_TM = '499' "
		cQuery += " AND DA_FILIAL = '"+xFilial('SDA')+"' AND DA_PRODUTO = '"+oGet:aCols[nI][1]+"' AND SDA.D_E_L_E_T_ != '*' "
		cQuery += " AND DA_DOC = DB_DOC "		
		cQuery += " ORDER BY DB_IDOPERA DESC "		
		cQuery := ChangeQuery(cQuery)

		If Select("TRBSER")<>0
			DBSelectArea("TRBSER")
			TRBSER->(DBCloseArea())
		EndIf
		TCQuery cQuery New Alias "TRBSER"
		
		DbSelectArea('TRBSER')
		TRBSER->(DbGoTop())
		
		IF !TRBSER->(EOF())
			cOP := TRBSER->DB_DOC
		Else                
		
			DBSelectArea("TRBSER")
			TRBSER->(DBCloseArea())
		
			cQuery := " SELECT DB_DOC, DB_ORIGEM "
			cQuery += " FROM "+RetSqlName('SDB')+" SDB "
			cQuery += " WHERE "
			cQuery += "     DB_FILIAL = '"+xFilial('SDB')+"' AND DB_PRODUTO = '"+oGet:aCols[nI][1]+"' AND SDB.D_E_L_E_T_ != '*' "
			cQuery += " AND DB_NUMSERI = '"+oGet:aCols[nI][3]+"' AND DB_TM = '499' "
			cQuery += " AND DB_DOC = 'INVENT' "		
			cQuery += " ORDER BY DB_IDOPERA DESC "		
			cQuery := ChangeQuery(cQuery)
			
			TCQuery cQuery New Alias "TRBSER"
		
			DbSelectArea('TRBSER')
			TRBSER->(DbGoTop())
			
			IF !TRBSER->(EOF())
		    	cOP := TRBSER->DB_DOC
			Else
				Alert('Não foram achados itens para o KIT informado!')
				DisarmTransaction()
				Exit	
			EndIf
		EndIf                      
		TRBSER->(DBCloseArea())

		cQuery := " SELECT DISTINCT DB_PRODUTO, DB_NUMSERI "
		cQuery += " FROM "+RetSqlName('SDB')+" SDB "
		cQuery += " WHERE "
		cQuery += "     DB_FILIAL = '"+xFilial('SDB')+"' AND DB_DOC = '"+cOP+"' AND D_E_L_E_T_ != '*' AND DB_ORIGEM = 'SC2'"
		cQuery := ChangeQuery(cQuery)

		If Select("TRBSER")<>0
			DBSelectArea("TRBSER")
			TRBSER->(DBCloseArea())
		EndIf
		TCQuery cQuery New Alias "TRBSER"
		
		DbSelectArea('TRBSER')
		TRBSER->(DbGoTop())
		
		If TRBSER->(EOF())
			RecLock('Z14',.T.)
			Z14->Z14_FILIAL	:= xFilial('Z14') 
			Z14->Z14_NUM   	:= M->Z12_NUM 
			Z14->Z14_MATRIC	:= M->Z12_MATRIC 
			Z14->Z14_NOMFUN	:= Posicione('SRA',1,xFilial('SRA')+M->Z12_MATRIC,"RA_NOME")
			Z14->Z14_FERRAM	:= oGet:aCols[nI][1] 
			Z14->Z14_NUMSER	:= oGet:aCols[nI][3]
			Z14->Z14_COMPON	:= oGet:aCols[nI][1]
			Z14->Z14_COMSER	:= oGet:aCols[nI][3]
			Z14->Z14_STATUS	:= '1'                
			Z14->Z14_DTPREV := dDataBase+Posicione('SB1',1,xFilial('SB1')+oGet:aCols[nI][1],"B1_XDIASDV")    
			MsUnlock()
		Else				
			While !TRBSER->(EOF())
				RecLock('Z14',.T.)
				Z14->Z14_FILIAL	:= xFilial('Z14') 
				Z14->Z14_NUM   	:= M->Z12_NUM 
				Z14->Z14_MATRIC	:= M->Z12_MATRIC     
				Z14->Z14_NOMFUN	:= Posicione('SRA',1,xFilial('SRA')+M->Z12_MATRIC,"RA_NOME")
				Z14->Z14_FERRAM	:= oGet:aCols[nI][1] 
				Z14->Z14_NUMSER	:= oGet:aCols[nI][3]
				Z14->Z14_COMPON	:= TRBSER->DB_PRODUTO 
				Z14->Z14_COMSER	:= TRBSER->DB_NUMSERI
				Z14->Z14_DTPREV := dDataBase+Posicione('SB1',1,xFilial('SB1')+oGet:aCols[nI][1],"B1_XDIASDV")
				Z14->Z14_STATUS	:= '1'                      
				MsUnlock()
        		TRBSER->(DBSkip())
			EndDo                      
		EndIf
		TRBSER->(DBCloseArea())				
		aAuto := {}
		aAdd(aAuto,{cDocumento,ddatabase})
	                 
		cEnd := Posicione('SBF',4,xFilial('SBF')+oGet:aCols[nI][1]+Padr(oGet:aCols[nI][3],Len(SBF->BF_NUMSERI)),"BF_LOCALIZ")
		aAdd(aAuto, {oGet:aCols[nI][1] ,; //1 Prod.Orig.
		 			 Posicione('SB1',1,xFilial('SB1')+oGet:aCols[nI][1],"B1_DESC"),; //2 Desc.Orig.
					 SB1->B1_UM,; //3 UM Orig.        
					 SB1->B1_LOCPAD,; //4 Armazem Or
					 cEnd,; //5 Endereco O
					 oGet:aCols[nI][1],; //6 Prod.Desti
					 SB1->B1_DESC,; //7 Desc.Desti
					 SB1->B1_UM,; //8 UM Destino
					 IIF(SB1->B1_LOCPAD=='10',Alltrim(_FerEmp),Alltrim(_EstTrop)),; //9 Armazem De
		   			 cEnd,; //10 Endereco D
				 	 oGet:aCols[nI][3],; //11 Numero Ser
					 "",; //12 Lote
					 "",; //13 Sub-Lote
					 dDataBase,;	//14 Validade
					 000.00,; //15 Potencia
					 1,; //16 Quantidade
					 0,; //17 Qt 2aUM
					 "",; //18 Estornado
					 "",; //19 Sequencia
					 "",; //20 Lote Desti
					 dDataBase,;	//21 Validade D
					 "",; //22 Item Grade
					 ""}) //23 Observacao
		lMsErroAuto := .F.
		MSExecAuto({|x,y| mata261(x,y)},aAuto,3)//inclusão
		If lMsErroAuto
			//Conout("Erro na transferencia de armazém para o produto "+oGet:aCols[nI][1]+"!")
			MostraErro()                                	
			DisarmTransaction()
			lRet := .F.
			Exit
		EndIf
			
		
	Next
		
	End Transaction
	
	If lRet
		U_RMNT032()
	EndIf

	freeObj(oTempTable)
	oTemptable := nil
	
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT031D
Exclusão emprestimo ferramenta

@return 
@author Felipe Toazza Caldeira
@since 31/05/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT031D() 
                               
	If !MsgYesNo('Deseja realmente excluir este emprestimo?')
		Return
	EndIf
	
	If Z12->Z12_STATUS != '1'
		Alert('Este emprestimo ja teve movimentação de devolução. Ele não pode ser excluído!')
		Return
	EndIf      	

	DbSelectArea('Z14')			
	Z14->(DbSetOrder(3))
	Z14->(DbGoTop())                                
	Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM))
	While xFilial('Z14')+Z12->Z12_NUM == Z14->Z14_FILIAL+Z14->Z14_NUM .AND. !Z14->(EOF())
		RecLock('Z14',.F.)
		DbDelete()
		MsUnlock()
		Z14->(DbSkip())
	Enddo 
	
	DbSelectArea('Z13')			
	Z13->(DbSetOrder(1))
	Z13->(DbGoTop())                                
	Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM))
	While xFilial('Z13')+Z12->Z12_NUM == Z13->Z13_FILIAL+Z13->Z13_NUM .AND. !Z13->(EOF())
		RecLock('Z13',.F.)
		DbDelete()
		MsUnlock()
		Z13->(DbSkip())
	Enddo  

	RecLock('Z12',.F.)
	DbDelete()
	MsUnlock()
      
Return
                                            

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005L
Rotina para montagem de legenda

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function AMNT031L()
Private cCadastro := "Solicitação de EPIs"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_VERDE"		,"Ferramenta Devolvida"	},;
										{"BR_AMARELO"	,"Ferramenta Emprestada"},;
										{"BR_VERMELHO"	,"Ferramenta Com Pendencia"}})

Return .T.
                                                
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT031S
Pergunte para informação da senha

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function AMNT031S() 
Private aTela[0][0],aGets[0][0]
Private cCadastro := "Cadastro de Senha"

	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 

	//DEFINE MSDIALOG oDlgM TITLE cCadastro FROM 000, 000  TO 100, 300  OF oMainWnd PIXEL #24/08/2018 @Eliseu Arndt Alves
	//@ 013, 010 Say oSay prompt "Senha Confirmação " SIZE 175, 007 OF oDlgM PIXEL FONT oFont
	//@ 010, 070 MSGET cSenhaAtu when .T. SIZE 060, 011 Password OF oDlgM PIXEL FONT oFont
	DEFINE MSDIALOG oDlgM TITLE cCadastro FROM 000, 000  TO 120, 300  OF oMainWnd PIXEL
	@ 043, 010 Say oSay prompt "Senha Confirmação " SIZE 175, 007 OF oDlgM PIXEL FONT oFont
	@ 040, 070 MSGET cSenhaAtu when .T. SIZE 060, 011 Password OF oDlgM PIXEL FONT oFont
			
	ACTIVATE MSDIALOG oDlgM ON INIT EnchoiceBar(oDlgM,{|| oDlgM:End()},{||oDlgM:End()},,)//EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,)
             	     
Return
                                         

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT031I
Inclusão Emprestimos Ferramentas

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
Static Function AMNT031A(aItens)
	
	Local aObjects  	:= {} 
	Local aPosObj   	:= {} 
	Local aSizeAut  	:= MsAdvSize()             
	local aHeader2		:= {}
	local aFields2 		:= {'Z13_FERRAM','Z13_NUMSER'}
	local aFieldFill2	:= {}
	local aAlterFields2	:= {}      
	local aCols2			:= {}
	Local aField 		:= {}
	Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
																			}))}
	Private cCadastro2 	:= 'Emprestimo de Ferramentas' 
	Private oGet2             
			
	static oDlg2
	
	
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 
	
	DEFINE MSDIALOG oDlg2 TITLE cCadastro2 From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
			
	aEval(aFields2,bBlock)
	aHeader2 := aClone(aField)
	aCols2 := aClone(aItens)
	
 	oGet2 := MsNewGetDados():New( 060, 010, 010, 500	, , 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields2, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlg2, aHeader2, aCols2)	 
		
	ACTIVATE MSDIALOG oDlg2 CENTER On INIT (enchoiceBar(oDlg2, {|| lConf := .T.,oDlg2:end() }, {|| lConf := .F.,oDlg2:end()},,))
	
Return .T.
