/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIET�RIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Compras   																																									 		**/
/** NOME 				: MA120BUT.RPW																																										**/
/** FINALIDADE	: P. E. Adiciona bot�es na Enchoice Bar do pedido de compras                                      **/
/** SOLICITANTE	: Suell�n              					                                                           				**/
/** DATA 				: 12/02/2014																																							 				**/
/** RESPONS�VEL	: RSAC SOLU��ES																																										**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARA��O DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINI��O DE PALAVRAS 	  			 								                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUN��O: U_MA120BUT()														                                                      **/
/** DESCRI��O	  	: Adiciona bot�o																											                					**/                        
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIA��O /ALTERA��ES / MANUTEN��ES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicita��o         | Descri��o                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 10/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	


User Function MA120BUT() 

	Local aRet	:= {} 	//Retorno da fun��o
	
	//Adiciona o bot�o
  Aadd(aRet, {"NOTE", {||U_KCOMA001(.T., "P")}, "Justificativa"})

Return aRet