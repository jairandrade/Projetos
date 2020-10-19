#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AFIN010

@return 
@author Felipe Toazza Caldeira
@since 22/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function AFIN010()            
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aCpo			:= {"E2_PREFIXO","E2_NUM","E2_TIPO","E2_BARRA","E2_HIST"}
Local aSizeAut  	:= MsAdvSize()             
Local aButtons 		:= {}          
Local nX             
Local aCpoAlt		:= {"E2_BARRA","E2_HIST"}
Private bCampo    	:= {|nField| FieldName(nField) }			
Private cCadastro 	:= 'Contas a Pagar' 
Private oGet             
		
static oDlgI           	

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	
	For nX := 1 To FCount()
		M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
	Next nX

	M->E2_PREFIXO	:= SE2->E2_PREFIXO 
	M->E2_NUM		:= SE2->E2_NUM
	M->E2_TIPO		:= SE2->E2_TIPO
	M->E2_BARRA		:= SE2->E2_BARRA
	M->E2_HIST		:= SE2->E2_HIST
	nReg := SE2->(Recno())
	
	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
	Enchoice( "SE2", nReg, 4,,,,aCpo,aPosObj[1],aCpoAlt,, , , , , ,.F. )  
		
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(Gravadado(),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.


                 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GravaDado                    

	RecLock('SE2',.F.)
	SE2->E2_BARRA		:= M->E2_BARRA
	SE2->E2_HIST		:= M->E2_HIST
	MsUnlock()			
                                  	
return .T.
                                     

