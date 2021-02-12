/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETÁRIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Faturamento																																									 		**/
/** NOME 				: KFATA001.RPW																																										**/
/** FINALIDADE	: Inclusão de Pedido na empresa licenciadora                                                      **/
/** SOLICITANTE	:                     					                                                           				**/
/** DATA 				: 10/02/2014																																							 				**/
/** RESPONSÁVEL	: RSAC SOLUÇÕES																																										**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARAÇÃO DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: U_KFATA001														                                                        **/
/** DESCRIÇÃO	  	: Execução da rotina fia Job 																																		**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 10/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
User Function KFATA001(aSC5, aItens, cEmpNew, cFilNew)

Local cNum	:= ""			//Número do pedido
Local nX    := 0			//Contador
Local nY	:= 0			//Contador
Local cMV_TesInt  //em 01/09/2016
Local cMsgErro


//Default dDtAtu	:= dDataBase

CONOUT("INICIA TRANSFERENCIA de inclusão...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"Transferencia","transf@2014","FAT")

//Grava o número do pedido
//cNum := GetSxeNum("SC5","C5_NUM")


cMV_TesInt := alltrim(GetMv("MV_TESINT"))//EM 01/09/2016

//faz um loop nos cabeçalho do pedido
For nX := 1 To Len(aSC5)
	
	//Substitui a filial
	If (Alltrim(aSC5[nX][1]) == "C5_FILIAL")
		
		//Grava a nova filial
		aSC5[nX][2] := xFilial("SC5")	
	EndIf
	
	//Substitui o numero do pedido
//	If (Alltrim(aSC5[nX][1]) == "C5_NUM")
		
		//Grava o novo numero do pedido
//		aSC5[nX][2] := cNum	
//	EndIf
	
Next nX

//Loop nos ítens do pedido
For nX := 1 To Len(aItens)
		
	//Faz Loop nos itens
	For nY := 1 To Len(aItens[1])
		
		//Substitui a filial
		If (Alltrim(aItens[nX][nY][1]) == "C6_FILIAL")
			
			//Grava a nova filial
			aItens[nX][nY][2] := xFilial("SC6")		
		EndIf
		
		//em 01/09/2016
		//Substitui a filial
		If (Alltrim(aItens[nX][nY][1]) == "C6_TES")
				aItens[nX][nY][2] := 	cMV_TesInt
		EndIf
		//ate aqui -01/09/2016	
	
			
		//Substitui a filial
//		If (Alltrim(aItens[nX][nY][1]) == "C6_NUM")
			
			//Grava a nova filial
//			aItens[nX][nY][2] := cNum		
//		EndIf		
	Next nY	
Next nX                                   		

conout(varinfo("aSC5",aSC5))
conout(varinfo("aItens",aItens))

//dDataBase 	:= dDtAtu

//Inicia transacao
Begin Transaction

//Executa a rotina automatica

lMsErroAuto := .F.
MSExecAuto({|x,y,z| Mata410(x,y,z)}, aSC5, aItens, 3)

//Verifica se ocorreu erro
If lMsErroAuto
	
	cMsgErro	:= MostraErro()
	
	CONOUT("ERRO: " + cMsgErro)
//	RollBackSX8()
	//Nao executa a rotina
	DisarmTransactions()
	
	// envia e-mail de erro
	//U_MailTo("aluisio@kapazi.com.br", "Erro na integracao de pedidos de venda intangiveis!!", cMsgErro, "", "")
	
Else
//	ConfirmSx8()
	//Ordena o pedido de venda
	//U_AvalPed()//libera
	AvalPed()//libera
	SC9->(DbSetOrder(1))
	
	//Posiciona no registro
	If (DbSeek(xFilial("SC9")+SC5->C5_NUM))
		
		//Posiciona no pedido de vendas
		While (!SC9->(Eof()) .AND. SC5->C5_NUM == SC9->C9_PEDIDO)
			
			//Trava a tabela
			RecLock("SC9", .F.)
			
			//Libera o pedido
			SC9->C9_BLEST 	:= ""
			SC9->C9_BLCRED  := ""
			
			//Libera o registro
			MsUnlock()
			
			//Próximo registro
			SC9->(DbSkip())	
		EndDo	
		Conout("Pedido gerado com sucesso + "+SC5->C5_NUM)
			
	EndIf	
EndIf

//Finaliza transacao
End Transaction
Return Nil                

/**********************************************************************************************************************************/
/** static function AvalPed()                                                                                                    **/
/** Executa a liberação do pedido de venda posicionado na SC5                                                                    **/
/**********************************************************************************************************************************/
static function AvalPed()

// variaveis auxiliares
local aArea := GetArea()
Local lEnd	:= .F.
private lTransf := .F.
private lLiber := .F.
private lSugere := .F.

// ajusta os parametros iniciais
Pergunte("MTA440",.F.)  
lTransf := mv_par01 == 1
lLiber := mv_par02 == 1
lSugere := mv_par03 == 1

// ajusta os parametros da rotina
Pergunte("MTALIB", .F.)
mv_par01 := 1
mv_par02 := SC5->C5_NUM
mv_par03 := SC5->C5_NUM
mv_par04 := SC5->C5_CLIENTE
mv_par05 := SC5->C5_CLIENTE
mv_par06 := Stod("")
mv_par07 := Stod("20491231")
mv_par08 := 1
mv_par09 := SC5->C5_LOJACLI
mv_par10 := SC5->C5_LOJACLI

// executa a liberação automática
A440Proces("SC5", SC5->(RecNo()), 4, @lEnd)

// restaura a area
RestArea(aArea)

return Nil