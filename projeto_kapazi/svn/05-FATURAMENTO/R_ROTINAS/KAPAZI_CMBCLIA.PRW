
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Fauramento                                                                                                                  **/     																																
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
//* Rotinas para retorno de combo para campos A1_K_SITCL e A1_K_CNDCL
/**********************************************************************************************************************************/ 
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 27/06/2017 | Marcos Sulivan									|          	**/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/ 
 
User Function CMBCLIA(nTpa)   

Local	cCombC	:=  ""	 
Local nTpa		:=	nTpa  
Local	cSITCL	:=	""
local cCNDCL	:=	""  
           
//chamada do fonte no A1_K_SITCL
If nTpa == 1         

	cCombC 	:=	alltrim(GetMV("MV_K_SITCL")) 

//chamada do fonte no A1_K_CNDCL
ElseIf nTpa	== 2   

	cCombC	:=	alltrim(GetMV("MV_K_CNDCL")) 

EndIf

Return cCombC    