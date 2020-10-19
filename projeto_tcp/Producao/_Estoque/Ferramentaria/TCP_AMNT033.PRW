#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT033
Devolução de Ferramentas
@return 
@author Felipe Toazza Caldeira
@since 22/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function AMNT033()            
//Local cFiltro := "Z14_STATUS == '3'" //Expressao do Filtro                                                
//Local aIndex := {}

Private cAlias := "Z14"
//Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro         
Private cCadastro := "Devolução Ferramentas"
Private aRotina := {}
Private aCores := {}                 
	
	aCORES := {	{"Z14->Z14_STATUS == '1' " ,"BR_AMARELO" } 	,;   
				{"Z14->Z14_STATUS == '2' " ,"BR_VERDE" } 	,;   
				{"Z14->Z14_STATUS == '3' " ,"BR_VERMELHO"}	,;
				{"Z14->Z14_STATUS == '4' " ,"BR_PRETO" }	} 
 	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  	, "AxPesqui"   		,0,1})  
	AADD(aRotina,{"Visualizar" 	, "AxVisual"		,0,2})
	AADD(aRotina,{"Devolução"  	, "U_AMNT033D()" 	,0,4})
	AADD(aRotina,{"Baixas"  	, "U_AMNT033B()" 	,0,4})
	AADD(aRotina,{"Imprimir"   	, "U_RMNT033()" 	,0,6})
	AADD(aRotina,{"Legendas"   	, "U_AMNT033L()" 	,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())
                                   
//	Eval( bFiltraBrw ) //Efetiva o Filtro antes da Chamada a mBrowse 
	
 	mBrowse(006,001,022,075,cAlias,,,,,,aCores)
 	
//	EndFilBrw( cAlias , @aIndex ) //Finaliza o Filtro 
	
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT033D
Inclusão Emprestimos Ferramentas

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT033D( cAlias, nReg, nOpc )
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aCpo			:= {}
Local aSizeAut  	:= MsAdvSize()             
Local aButtons 		:= {}                       
Local aCpoAlt		:= {"Z14_OBS"}
Local nX
Private bCampo    	:= {|nField| FieldName(nField) }			
Private cCadastro 	:= 'Devolução de Ferramentas' 
Private oGet             
Private cMatricula	:= Space(6)
		
static oDlgI           	
  
If Z14->Z14_STATUS != '3'
	Alert('Somente é possivel realizar alterações em itens com pendencia!')
	Return
EndIf

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	dbSelectArea("Z14")
	Z14->(dbSetOrder(1))
	
	For nX := 1 To FCount()
		M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
	Next nX

	M->Z14_NUM		:= Z14->Z14_NUM 
	M->Z14_MATRIC	:= Z14->Z14_MATRIC
	M->Z14_FERRAM	:= Z14->Z14_FERRAM
	M->Z14_NUMSER	:= Z14->Z14_NUMSER
	M->Z14_COMPON	:= Z14->Z14_COMPON
	M->Z14_COMSER	:= Z14->Z14_COMSER
	M->Z14_DTENTR	:= Z14->Z14_DTENTR
	M->Z14_DTPEND	:= Z14->Z14_DTPEND
	M->Z14_DTPREV	:= Z14->Z14_DTENTR
	M->Z14_OBS		:= Z14->Z14_OBS
	
	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
	Enchoice( cAlias, nReg, 4,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
		
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(Gravadado('2'),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT033B

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT033B( cAlias, nReg, nOpc )
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aCpo			:= {}
Local aSizeAut  	:= MsAdvSize()             
Local aButtons 		:= {}                       
Local aCpoAlt		:= {"Z14_OBS"}
Local nX
Private bCampo    	:= {|nField| FieldName(nField) }			
Private cCadastro 	:= 'Devolução de Ferramentas' 
Private oGet             
Private cMatricula	:= Space(6)
		
static oDlgI           	

If Z14->Z14_STATUS != '3'
	Alert('Somente é possivel realizar alterações em itens com pendencia!')
	Return
EndIf


//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	dbSelectArea("Z14")
	Z14->(dbSetOrder(1))
	
	For nX := 1 To FCount()
		M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
	Next nX

	M->Z14_NUM		:= Z14->Z14_NUM 
	M->Z14_MATRIC	:= Z14->Z14_MATRIC
	M->Z14_FERRAM	:= Z14->Z14_FERRAM
	M->Z14_NUMSER	:= Z14->Z14_NUMSER
	M->Z14_COMPON	:= Z14->Z14_COMPON
	M->Z14_COMSER	:= Z14->Z14_COMSER
	M->Z14_DTENTR	:= Z14->Z14_DTENTR
	M->Z14_DTPEND	:= Z14->Z14_DTPEND
	M->Z14_DTPREV	:= Z14->Z14_DTENTR
	M->Z14_OBS		:= Z14->Z14_OBS
	
	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
	Enchoice( cAlias, nReg, 4,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
		
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(Gravadado('4'),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.
                 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GravaDado(cTpBaixa)                    

	RecLock("Z14",.F.)
	Z14->Z14_STATUS	:= cTpBaixa          
	Z14->Z14_DTENTR	:= dDataBase
	Z14->Z14_OBS	:= M->Z14_OBS
	Msunlock()

	DbSelectArea('Z13')
	Z13->(DbSetOrder(3))
	Z13->(DbGoTop())
	Z13->(DbSeek(xFilial('Z13')+Z14->Z14_NUM))
	While !Z13->(EOF()) .AND. Z14->Z14_NUM != Z13->Z13_NUM
		RecLock("Z13",.F.)
		Z13->Z13_STATUS	:= cTpBaixa          
		Msunlock()
		Z13->(DbSkip())
	Enddo	
		
Return .T. 


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005L
Rotina para montagem de legenda

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function AMNT033L()
Private cCadastro := "Devolução Ferramentras"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_AMARELO"		,"Ferramenta Emprestada"	},;
										{"BR_VERDE"			,"Ferramenta Devolvida"		},;
										{"BR_VERMELHO"		,"Ferramenta com Pendencia"	},;
										{"BR_PRETO"			,"Ferramenta Baixada com Pendencia"	}})

Return .T.
                                                