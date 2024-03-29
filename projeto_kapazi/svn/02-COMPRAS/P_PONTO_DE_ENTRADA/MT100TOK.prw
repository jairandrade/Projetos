/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Compras   																																									 		**/
/** NOME 				: MT100TOK.RPW																																										**/
/** FINALIDADE	: PE para valida��o da nota fiscal de entrada													                            **/
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
/** 12/02/2014 	| Velton Teixeira        | Su�llen Sora        |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

User Function MT100TOK()

Local nPosJus   := Ascan(aHeader, {|x| AllTrim(x[2]) == "D1_JUSTIF"}) 			//Posi��o da justificativa no acols
Local lRet			:= .T.                                                      //Retorno da fun��o
Local nX				:= 0																												//Contador
Local nPosLocal   := Ascan(aHeader, {|x| AllTrim(x[2]) == "D1_LOCAL"}) 			//Posi��o da justificativa no acols

If FUNNAME() $ "MATA103"

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
	lRet := U_KCOMA001(lRet, "N")

	IF(CEMPANT='04' .AND. CFILANT='08' .AND. !ISBLIND() .AND. cA100For='000018')
		//Loop no aCols
		lRetAMZ := .T.
		For nX := 1 To Len(aCols)
			
			//
			If (aCols[nX][nPosLocal]<>'04')
				
				//Valida
				lRetAMZ := .F.
				
			EndIf
			
			//Pr�ximo registro
		Next nX
		IF(!lRetAMZ)
			MsgInfo("Existe Armazem fora do padr�o - Necess�rio informar 04","Aten��o - MT100TOK - AMZ")
			lRet := .F.
		EndIF
	EndIF
EndIF

Return lRet
