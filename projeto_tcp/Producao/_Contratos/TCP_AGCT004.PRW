#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
#include "TOTVS.CH"

//---------------------------------------------------------------------
/*{Protheus.doc} AGCT004
Informações para medição

@author Felipe
@since 23/06/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
User Function AGCT004()                     
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aCpo			:= {"Z21_CONTRA","Z21_REVISA","Z21_NUMMED","Z21_VALTOT","Z21_VALRAT"}
Local aSizeAut  	:= MsAdvSize()             
Local aButtons 		:= {}                       
Local aCpoAlt		:= {""}
Local lRet			:=.f.
Local lHasButton := .T.
Local oFont 	:= TFont():New('Arial',,-12,.T.,.t.)
Local nX

Private cAlias		:= "Z21"
Private nReg		:= CND->(RECNO())
Private bCampo    	:= {|nField| FieldName(nField) }			
Private cCadastro 	:= 'Rateio Contrato' 
Private oGet,oGet5            
Private nVALRAT := 0 
Private cCONTRA := CND->CND_CONTRA
Private cRevisa := CND->CND_REVISA
Private cMedic	:= CND->CND_NUMMED
Private nVltTot	:= CND->CND_VLTOT
Private _nOpc
		
static oDlgI           	

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DbSelectArea('Z21')
	Z21->(dbSetOrder(1))
	For nX := 1 To FCount()
		M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
	Next nX
	
	nOpc := 3	
	nLin:=15   
	nCol:=55
	
	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
   
	
	oSay1 := TSay():New( nLin,05,{||'Contrato'},oDlgI,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet1 := TGet():New( nLin, nCol, { | u | If( PCount() == 0, cCONTRA, cCONTRA := u ) },oDlgI,060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F. ,,"cCONTRA",,,,lHasButton  )
		
	oSay2 := TSay():New( nLin,130,{||'Revisao'},oDlgI,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet2 := TGet():New( nLin,130+nCol, { | u | If( PCount() == 0, cRevisa, cRevisa := u ) },oDlgI,060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"cRevisa",,,,lHasButton  )
	
	nLin+=15
	oSay3 := TSay():New( nLin,05,{||'Medicao'},oDlgI,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oGet3 := TGet():New( nLin, nCol,    { | u | If( PCount() == 0, cMedic , cMedic  := u ) },oDlgI,060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.t. ,,"cMedic",,,,lHasButton  )
	 
	oSay4 := TSay():New( nLin,130,{||'Valor Total'},oDlgI,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet4 := TGet():New( nLin,130+nCol, { | u | If( PCount() == 0, nVltTot, nVltTot := u ) },oDlgI,060, 010, "@e 999,999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"nVltTot",,,,lHasButton  )

 	oSay5 := TSay():New( nLin,280,{||'Valor Rateio'},oDlgI,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oGet5 := TGet():New( nLin,280+nCol, { | u | If( PCount() == 0, nVALRAT, nVALRAT := u ) },oDlgI,060, 010, "@e 999,999,999,999.99",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"nVALRAT",,,,lHasButton  )


	//Enchoice( cAlias, nReg, 3,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
	
	GridCrit()// cabecalho                                          
	
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(lRet:=Gravadado(),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT()
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'Z21_NATURE','Z21_CCUSTO','Z21_ITEMCT','Z21_VALOR'}
	local aFieldFill	:= {}
	local aAlterFields	:= {'Z21_NATURE','Z21_CCUSTO','Z21_ITEMCT','Z21_VALOR'}
	Local cNum			:= ""
	Local nX
			
	Local aField 		:= {}
	Local bBlock 		:=  {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
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
	aEval(aHeader,{|aCampo| aAdd(aFieldFill,CriaVar(aCampo[02],.F.))})
	aAdd(aFieldFill, .f.)
	
	cQueryZ21 := " SELECT * FROM "+RetSqlName('Z21')+" Z21 "
	cQueryZ21 += " WHERE Z21.Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21.Z21_CONTRA = '"+CND->CND_CONTRA+"' "
	cQueryZ21 += "   AND Z21.Z21_NUMMED = '"+CND->CND_NUMMED+"' AND Z21.D_E_L_E_T_ != '*' "
	If (Select("TMPZ21") <> 0)
   		DbSelectArea("TMPZ21")
   		TMPZ21->(DbCloseArea())
    Endif
			
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryZ21), "TMPZ21",.T., .F.)
		
	DbSelectArea("TMPZ21")
	TMPZ21->(DbGoTop())		
	If TMPZ21->(EOF()) 	
		_nOpc := 3
		aAdd(aCols, aClone(aFieldFill))              
	Else      
	    _nOpc := 4                         
		While !TMPZ21->(EOF()) 					
			aFieldFill[1]  := TMPZ21->Z21_NATURE
			aFieldFill[2]  := TMPZ21->Z21_CCUSTO  		   
			aFieldFill[3]  := TMPZ21->Z21_ITEMCT
			aFieldFill[4]  := TMPZ21->Z21_VALOR                                                                                                   							
			aAdd(aCols, aClone(aFieldFill))
			TMPZ21->(DbSkip())
		EndDo	
		
	EndIf
	TMPZ21->(DbCloseArea())			
	
 	oGet := MsNewGetDados():New( 060, 010, 275, 500	, Iif(nOpc==3,GD_INSERT+GD_DELETE+GD_UPDATE,), 'U_agct004b()', 'AllwaysTrue', '', aAlterFields, 0, 99, 'U_agct004b()', '', 'U_agct004b()', oDlgI, aHeader, aCols)	 
 	
return
 
 
User function agct004b() 
local nPostot:= ascan(aHeader,{|x| alltrim(x[2])=='Z21_VALOR'}) 
Local ni
nVALRAT:=0
for ni:=1 to len(aCols)
	if !aCols[ni][len(aHeader)+1]
		if ni == n .and. _nOpc == 3
			nVALRAT+=m->Z21_VALOR
		Else	
			nVALRAT+=aCols[ni][nPostot]   
		EndIF
		
	EndIF
Next
oGet5:refresh()
return .t. 
 
                 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} Gravadado
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GravaDado                    
Local nAux := 0
Local nI

	For nI := 1 To len(oGet:aCols)    
		If !oGet:aCols[nI][5]            		                      
			nAux += oGet:aCols[nI][4] 						
		EndIf
	Next
	
	If nAux != CND->CND_VLTOT
		Alert('O valor do rateio diverge do valor da medição')
		Return .F.
	EndIf

	cQueryZ21 := " DELETE FROM "+RetSqlName('Z21')+"  "
	cQueryZ21 += " WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+CND->CND_CONTRA+"' "
	cQueryZ21 += "   AND Z21_NUMMED = '"+CND->CND_NUMMED+"' AND D_E_L_E_T_ != '*' "
	
	//Conout(cQueryZ21)
	
	nDelSql := TcSqlExec(cQueryZ21)
	If nDelSql < 0
		Alert('Problema ao gravar o rateio! Operação Abortada!')
		Return .F.	
	EndIf

	For nI := 1 To len(oGet:aCols)    
		If !oGet:aCols[nI][5]            		                      
			RecLock('Z21',.T.)
			Z21->Z21_FILIAL := xFilial('Z21')
			Z21->Z21_CONTRA	:= CND->CND_CONTRA
			Z21->Z21_REVISA	:= CND->CND_REVISA
			Z21->Z21_NUMMED := CND->CND_NUMMED 			
			Z21->Z21_NATURE	:= oGet:aCols[nI][1] 			
			Z21->Z21_CCUSTO := oGet:aCols[nI][2] 			
			Z21->Z21_ITEMCT := oGet:aCols[nI][3] 			
			Z21->Z21_VALOR 	:= oGet:aCols[nI][4] 			
			MsUnlock()
		EndIf 
	Next


Return .T.








