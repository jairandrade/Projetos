//**Ponto de entrada compras solicita��o de compras**//
//Analista: Alessandro Bueno                       **//
//Data: 16/11/2016                                 **//
//***********DESCRI��O*******************************//
// Impede que usu�rios alterem a solicita��o de com-*//
// pras que n�o foi feita por ele mesmo.           **//
//***************************************************//
 
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "totvs.ch"                 
#include "rwmake.ch"

user function MT110VLD 

Local log := .T.
local USR := SC1->C1_USER
Local Par := GetMV("MV_ALTSOCO")    

IF ALTERA

	If (!(AllTrim(__cUserID) == AllTrim(USR)) .AND. !(__cUserID $ Par))
	
		log := .F.          
		MsgInfo("Aten��o, somente o usu�rio que incluiu a solicita��o pode alter�-la.")
	EndIf
EndIf	  

return log