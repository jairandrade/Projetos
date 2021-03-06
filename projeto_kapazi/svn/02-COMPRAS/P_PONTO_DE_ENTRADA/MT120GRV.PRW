/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Compras   																																									 		**/
/** NOME 				: MT120GRV.RPW																																										**/
/** FINALIDADE	: PE para valida��o do pedido de compras          										                            **/
/** SOLICITANTE	: Suellen              					                                                           				**/
/** DATA 				: 12/02/2014																																							 				**/
/** RESPONSAVEL	: RSAC SOLUCOES																																										**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARACAO DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINICAO DE PALAVRAS 	  			 								                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: U_MT120GRV()											  			                                                      **/
/** DESCRICAO	  	: Validacao do pedido de compras   	  																                					**/                        
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         | Descricao                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 12/02/2014 	| Velton Teixeira        | Su�llen Sora        |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	

User Function MT120GRV()

	Local nPosJus   := Ascan(aHeader, {|x| AllTrim(x[2]) == "C7_JUSTIF"}) 			//Posi��o da justificativa no acols
	Local lRet			:= .T.                                                      //Retorno da fun��o
	Local nX				:= 0																												//Contador
	
	
	//Loop no aCols
	For nX := 1 To Len(aCols)
	  	  			
		//Verifica se j� esxiste justificativa
		If (Empty(aCols[nX][nPosJus]))
    
  		//Valida
  		lRet := .F.

		EndIf
	
	//Pr�ximo registro 
	Next nX
	
	//Chama a tela de justificativa
	lRet := U_KCOMA001(lRet, "P")
		
Return lRet