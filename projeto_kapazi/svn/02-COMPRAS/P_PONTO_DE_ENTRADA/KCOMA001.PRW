/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIET�RIO: KAPAZI                    																	  **/
/** MODULO		: Compras   																					  **/
/** NOME 		: KCOMA001.RPW																					  **/
/** FINALIDADE	: Tela de justificativa																			  **/
/** SOLICITANTE	: Suell�n              					                                                          **/
/** DATA 		: 12/02/2014																					  **/
/** RESPONS�VEL	: RSAC SOLU��ES																					  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARA��O DAS BIBLIOTECAS                                           **/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINI��O DE PALAVRAS 	  			 							  **/
/**---------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10)
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUN��O: U_KCOMA001()														                          **/
/** DESCRI��O	  	: Tela de justificativa 																	  **/
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

User Function KCOMA001(lOpc, cTp)
	Local 	nX				:= 0			//Contador
	Private	lRet			:= lOpc			//Retorno da fun��o
	Private cCham			:= cTp			//Chamada
	Private oGetJust		:= Nil     		//Campo da justificativa
	Private cGetJust		:= ""			//Conte�do
	Private oTela			:= Nil			//Tela principal
	Private nPosJus			:= 0  			//Posi��o da justificativa no acols
	Private cCampo			:= ""           //Nome do campo
	Private cPcSc			:= ""			//Campo Pedido/Solicita��o
	Private cIte			:= ""			//Campo item
	Private cAlias			:= ""			//Tabela

	//Verifica qual fun��o est� chamando a rotina
	Do Case
		
		//Solicita��o de compra
		Case (cCham == "S")
			//Adiciona o campo
			cCampo := "C1_JUSTIF"
			
			//Pedido de compra
		Case (cCham == "P")
			//Adiciona o campo
			cCampo 	:= "C7_JUSTIF"
			cPcSc 	:= "C7_NUMSC"
			cIte	:= "C7_ITEMSC"
			cAlias	:= "SC1"
	
			//Nota Fiscal de entrada
		Case (cCham $ "N|G")
			//Adiciona o campo
			cCampo 	:= "D1_JUSTIF"
			cPcSc  	:= "D1_PEDIDO"
			cIte	:= "D1_ITEMPC"
			cAlias	:= "SC7"
			
	EndCase

	//Grava a posi��o do array
	nPosJus := Ascan(aHeader, {|x| AllTrim(x[2]) == cCampo})

	//Verifica a op��o
	If ((Inclui .OR. Altera) .AND. cCham != "S")
		
		//Loop no aCols
		For nX := 1 To Len(aCols)
			//Verifica se a justificativa do item est� vazia
			If Empty(aCols[nX][nPosJus])
				
				//Verifica se tem n�mero da SC
				If (!Empty(aCols[nX][Ascan(aHeader, {|x| AllTrim(x[2]) == cPcSc})]))
					
					//Ordena o PC/SC
					&(cAlias)->(DbSetOrder(1))
					//Posiciona no registro
					If &(cAlias)->(DbSeek(xFilial(cAlias)+aCols[nX][Ascan(aHeader, {|x| AllTrim(x[2]) == cPcSc})]+aCols[nX][Ascan(aHeader, {|x| AllTrim(x[2]) == cIte})]))
						//Verifica a tabela
						If (cAlias == "SC1")
							//Traz a justificativa da SC
							aCols[nX][nPosJus] := SC1->C1_JUSTIF
							
						Else
							//Traz a justificativa do PC
							aCols[nX][nPosJus] := SC7->C7_JUSTIF
						
						EndIf
					EndIf
				EndIf
			EndIf
			//Pr�ximo registro
		Next nX
	EndIf

	If(cCham == "S")
		//Atualiza a justificativa
		cGetJust := Alltrim(aCols[1][nPosJus])
	Else
		//Loop no acols
		For nX := 1 To Len(aCols)
			//Verifica se j� esxiste a justificativa
			If (!(Alltrim(aCols[nX][nPosJus]) $ cGetJust) .AND. !Empty(aCols[nX][nPosJus]))
				
				//Adiciona o conte�do
				cGetJust += Alltrim(aCols[nX][nPosJus]) + ENTER
				
			EndIf
			//Pr�ximo
		Next nX
	EndIf

	//Verifica se � grava��o
	If (cCham == "G")
		//Grava as justificativas
		//	GrvJust()
		
		//Retorna a justificativa
		Return cGetJust
		
	Else
		//Tela principal
		@ 000, 000 To 200, 500 Dialog oTela Title "Justificativa"
		
		//Grupo: Valida��o do Operador
		@ 003, 005 To 079, 244 Title "  Justificativa "
		
		//Campo
		@ 011, 010 Get oGetJust Var cGetJust Memo Size 228, 062 Of oTela Pixel
		
		//Bot�o de Parar
		@ 084, 163 Button "Confirmar" Size 037, 011 Pixel Of oTela Action GrvJust()
		
		//Bot�o de Atualizar
		@ 084, 203 Button "Fechar" Size 037, 011 Pixel Of oTela Action Close(oTela)
		
		//Ativa a tela
		Activate Dialog oTela Centered
		
		//Retorna a valida��o
		Return lRet
	
	EndIf

Return lRet

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUN��O: GrvJust()   														                                                      **/
/** DESCRI��O	  	: Grava a justificativa 																							                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIA��O /ALTERA��ES / MANUTEN��ES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicita��o         | Descri��o                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 12/02/2014 	| Velton Teixeira        | Su�llen Sora        |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function GrvJust()
Local nX			:= 0																								 			//Contador

//Verifica se � inclus�o ou altera��o
If (Inclui .OR. Altera)
	//Verifica se o campo tem conte�do
	If (Empty(cGetJust))
		//Alerta o usu�rio
		MsgAlert("O campo de justificativa n�o pode ser vazio.")
		//Invalida a fun��o
		lRet := .F.
		//Sai da rotina
		Return Nil
		
	EndIf
	
	//Loop no acols
	For nX := 1 To Len(aCols)
		//Grava o acols
		aCols[nX][nPosJus] := cGetJust
		//Pr�ximo registro
	Next nX
	
	//Valida a opera��o
	lRet := .T.
EndIf

//Fecha a tela
Close(oTela)

Return Nil





