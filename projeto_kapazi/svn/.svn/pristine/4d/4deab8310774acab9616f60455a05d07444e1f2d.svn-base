#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: VALIDGTN 	|	Autor: Luis Paulo									|	Data: 26/03/2020//
//==================================================================================================//
//	Descrição: Validacao       		  							                                    //
//																									//
//==================================================================================================//
//Trim(M->B1_CODGTIN)+EANDigito(Trim(M->B1_CODGTIN))                                                  
User function VALIDGTN()
Local lRet  := .T.

if upper(Alltrim(M->B1_CODGTIN)) == "SEM GETIN"
    lRet  := .f.    
endif

Return(lRet)

//Gatilho B1_CODGTIN
User function GATIDGTN()
Local lRet          := .T.
Local oModelB1	    := FWModelActive()
Local oSB1		    := oModelB1:GetModel('SB1MASTER')
Local lInclui		:= oSB1:GetOperation() == 3
Local lAltera		:= oSB1:GetOperation() == 4

if upper(Alltrim(M->B1_CODGTIN)) == "SEM GETIN"
        //M->B1_CODBAR :=  "SEM GETIN"
    Else 
        //M->B1_CODBAR := trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR))
       oSB1:LoadValue("B1_CODGTIN",trim(M->B1_CODGTIN)+eandigito(trim(M->B1_CODGTIN)))
endif

Return(lRet)

//Gatilho B1_CODGTIN
//trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR))
User function GATGTNCB()
Local lRet          := .T.
Local oModelB1	    := FWModelActive()
Local oSB1		    := oModelB1:GetModel('SB1MASTER')
Local lInclui		:= oSB1:GetOperation() == 3
Local lAltera		:= oSB1:GetOperation() == 4

if upper(Alltrim(M->B1_CODBAR)) == "SEM GETIN"
        //M->B1_CODBAR :=  "SEM GETIN"
    Else 
        //M->B1_CODBAR := trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR))
       oSB1:LoadValue("B1_CODBAR",trim(M->B1_CODBAR)+eandigito(trim(M->B1_CODBAR)))
endif

Return(lRet)