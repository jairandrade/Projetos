//**Ponto de entrada compras solicitação de compras**//
//Analista: Alessandro Bueno                       **//
//Data: 16/11/2016                                 **//
//***********DESCRIÇÃO*******************************//
// Impede que usuários alterem a solicitação de com-*//
// pras que não foi feita por ele mesmo.           **//
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
		MsgInfo("Atenção, somente o usuário que incluiu a solicitação pode alterá-la.")
	EndIf
EndIf	  

return log