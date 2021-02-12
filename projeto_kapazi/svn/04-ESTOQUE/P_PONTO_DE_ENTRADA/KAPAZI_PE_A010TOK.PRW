#INCLUDE "PROTHEUS.CH"
/**********************************************************************************************************************************/
/** Estoque                                                                                                                  **/
/** Cadastro de Produto - Confirmar                                                                                          **/
/** Ponto de entrada A010TOK                               																																		  **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 19/01/2017 | Marcos Sulivan									| validar se fator de conversao foi informado													           **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/ 

User Function A010TOK() 
Local aArea  	:= GetArea()
Local lRet		:=	.T.  
Public lAltNfPr	:= .T.

If (ALLTRIM(M->B1_SEGUM) <> "" .AND. M->B1_CONV = 0 )  .OR. (M->B1_CONV > 0 .AND. ALLTRIM(M->B1_SEGUM) = "")
	Aviso("ATENÇÃO","Informe o fator de conversao para contiuar",{"Ok"})
	lRet	:=	.F.
EndIF


RestArea(aArea)

Return lRet  

/* FUNCAO COMPILADA PARA SER EXECUTADA EM GATILHO.*********/
/**********************************************************************************************************************************/ 
User Function ALTFATO() 
Local aArea  	 := GetArea()
lRet	:=	.T.  

If (ALLTRIM(M->B1_SEGUM) <> "" .AND. M->B1_CONV = 0 )  .OR. (M->B1_CONV > 0 .AND. ALLTRIM(M->B1_SEGUM) = "") 
   
			Aviso("ATENÇÃO","Informe o fator de conversao para continuar",{"Ok"})
			lRet	:=	.F.

EndIF

RestArea(aArea)

Return lRet 

