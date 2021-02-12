/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Compras   																																									 		**/
/** NOME 				: MT100TOK.RPW																																										**/
/** FINALIDADE	: PE para validação da nota fiscal de entrada													                            **/
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
/** NOME DA FUNCAO: U_MT100TOK()														                                                      **/
/** DESCRICAO	  	: Validacao da nota fiscal de compras 																                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         | Descricao                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 12/02/2014 	| Velton Teixeira        | Suéllen Sora        |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

User Function MT100TOK()

Local nPosJus   := Ascan(aHeader, {|x| AllTrim(x[2]) == "D1_JUSTIF"}) 			//Posição da justificativa no acols
Local lRet			:= .T.                                                      //Retorno da função
Local nX				:= 0																												//Contador

If FUNNAME() $ "MATA103"

//Loop no aCols
For nX := 1 To Len(aCols)
	
	//Verifica se já esxiste justificativa
	If (Empty(aCols[nX][nPosJus]))
		
		//Valida
		lRet := .F.
		
	EndIf
	
	//Próximo registro
Next nX

//Chama a tela de justificativa
lRet := U_KCOMA001(lRet, "N")

EndIF

Return lRet
