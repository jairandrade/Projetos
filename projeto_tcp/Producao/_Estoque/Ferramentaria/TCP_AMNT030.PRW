#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT030
Cadastro solicitante de ferramentas

@return 
@author Felipe Toazza Caldeira
@since 18/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function AMNT030()                    
        
Private cCadastro := "Solicitantes Ferramentas"
Private aRotina := {}
Private cAlias := "Z11"
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  	, "AxPesqui"   	,0,1})  
	AADD(aRotina,{"Visualizar" 	, "AxVisual"   	,0,2})
	AADD(aRotina,{"Incluir" 	, "AxInclui" 	,0,3})	
	AADD(aRotina,{"Excluir"    	, "AxDeleta" 	,0,5})
	AADD(aRotina,{"Alt. Senha" 	, "U_AMNT030S" 	,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,)
	
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT030S
Alteração de senha

@return 
@author Felipe Toazza Caldeira
@since 18/07/2016
/*/
//-------------------------------------------------------------------------------     

User Function AMNT030S() 
Private cSenhaN1	:= Space(10)
Private cSenhaN2	:= Space(10)
Private cSenhaAtu	:= Space(10)
Private aTela[0][0],aGets[0][0]
Private cCadastro := "Cadastro de Senha"

	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 

	DEFINE MSDIALOG oDlgM TITLE cCadastro FROM 000, 000  TO 150, 300  OF oMainWnd PIXEL
	@ 013, 010 Say oSay prompt "Senha Atual " SIZE 175, 007 OF oDlgM PIXEL FONT oFont
	@ 010, 055 MSGET cSenhaAtu when .T. SIZE 060, 011 Password OF oDlgM PIXEL FONT oFont
	
	@ 028, 010 SAY oSay prompt "Nova Senha" SIZE 175, 007 OF oDlgM PIXEL FONT oFont
	@ 025, 055 MSGET cSenhaN1 when .T. SIZE 060, 011 Password OF oDlgM PIXEL FONT oFont

	@ 043, 010 SAY oSay prompt "Nova Senha" SIZE 175, 007 OF oDlgM PIXEL FONT oFont
	@ 040, 055 MSGET cSenhaN2 when .T. SIZE 060, 011 Password  OF oDlgM PIXEL FONT oFont
		
	ACTIVATE MSDIALOG oDlgM ON INIT EnchoiceBar(oDlgM,{|| If(GRAVAS(),oDlgM:End(),nil)},{||oDlgM:End()},,)//EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,)
             	     
Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRAVAS
Alteração de senha

@return 
@author Felipe Toazza Caldeira
@since 18/07/2016
/*/
//-------------------------------------------------------------------------------     
Static Function GravaS()
Local lRet := .T.                           

	If cSenhaN1 != cSenhaN2
		Alert('As senhas digitadas estão diferentes!')
		Return .F.
	ElseIf Empty(Alltrim(cSenhaN1)) 
		Alert('A nova senha não pode estar em branco!')
		Return .F.	                                
	ElseIF Len(Alltrim(cSenhaN1)) < 5
		Alert('A nova senha deve possuir ao menos 5 caracteres!')
		Return .F.	                                	
	EndIF

	If Empty(Alltrim(Z11->Z11_SENHA))
		cSenhaAnt := Z11->Z11_SENHA
		RecLock('Z11',.F.)
		Z11->Z11_SENHA 	:= Embaralha(cSenhaN1,0)	
		Z11->Z11_SENANT := cSenhaAnt
		Z11->(MsUnlock())	        
	Else         
		If Embaralha(cSenhaAtu,0) != Z11->Z11_SENHA .AND. !RetCodUsr() $ GetMv('TCP_USRFERR')
			Alert('A senha atual digitada não confere com a senha gravada!')
			Return .F.					
		EndIf	
		cSenhaAnt := Z11->Z11_SENHA
		RecLock('Z11',.F.)
		Z11->Z11_SENHA 	:= Embaralha(cSenhaN1,0)	
		Z11->Z11_SENANT := cSenhaAnt
		Z11->(MsUnlock())	        	
	EndIf
	             	     
Return lRet

