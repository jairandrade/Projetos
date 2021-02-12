#Include "RwMake.ch"
#include "Topconn.ch"
#include "protheus.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Faturamento                                                                                                                            |
| Filtro na consulta do Vendedor para o Pedido de Venda                                                                                  |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 31/03/2017                                                                                                                       |
| Descricao: Restringir a visualização de Vendedores na digitação dos pedidos de venda á apenas ao vendedor logado                       |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function UsrVen()

Local cCodUser	:= RetCodUsr() //Retorno do cod do usuario
Local aArea			:= GetArea()
Local cAlias1		:= GetNextAlias()
Local cQuery1		:= " "
Local cRet			:= " "
Local cVnd1			:= " "
Local cVndCli		:= " "
Local cVndCGC		:= " "

If AllTrim(FunName()) == "MATA410"
	
	// If cCodUser $ GetMV("KP_VENINTE") .OR. cCodUser $ GetMV("KP_VENINT2")
	If StaticCall(M415FSQL,PodeVerTodosPedidos)
		
		cVndCli := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,"A1_VEND")
		cVndCGC	:= POSICIONE("SA3",1,XFILIAL("SA3") + cVndCli,"A3_CGC")
		
		If !Empty(cVndCGC)
			
			cQuery1 += " SELECT DISTINCT A3_COD "
			cQuery1 += "   FROM "+RetSqlName("SA3")+" SA3 "
			cQuery1 += " WHERE SA3.A3_CGC = '"+ cVndCGC +"' "
			cQuery1 += "    AND SA3.A3_FILIAL = '" + xFilial("SA3") +"' "
			cQuery1 += "    AND SA3.D_E_L_E_T_ <> '*' "
			
			cQuery1 := ChangeQuery( cQuery1 )
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAlias1,.T.,.T.)
			dbSelectArea(cAlias1)
			
			nTotReg := Contar(CALIAS1,"!Eof()")
			(CALIAS1)->(DbGoTop())
			
			While !(CALIAS1)->(eof())
				If Empty(cVnd1)
					cVnd1	:= "'" + (cAlias1)->A3_COD + "'"
				Else
					cVnd1	+= ",'" + (cAlias1)->A3_COD + "'"
				EndIf
				(CALIAS1)->(DbSkip())
			End
			
			cRet := "@A3_COD IN (" + cVnd1 + ") "

		(cAlias1)->(DbCloseArea())			
		EndIf
		
	Else
		// Selecione os Vendedores conforme o código do usuário logado
		cQuery1 += " SELECT DISTINCT A3_COD "
		cQuery1 += "   FROM "+RetSqlName("SA3")+" SA3 "
		cQuery1 += " WHERE SA3.A3_CODUSR = '"+ cCodUser +"' "
		cQuery1 += "    AND SA3.A3_FILIAL = '" + xFilial("SA3") +"' "
		cQuery1 += "    AND SA3.D_E_L_E_T_ <> '*' "
		
		cQuery1 := ChangeQuery( cQuery1 )
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAlias1,.T.,.T.)
		dbSelectArea(cAlias1)
		
		nTotReg := Contar(CALIAS1,"!Eof()")
		(CALIAS1)->(DbGoTop())
		
		If !cCodUser $ GetMV("KP_USRVEN") //verifica se o usuario está cadatrado ao parametro para não se enquadrar no bloqueio de vendedor
			If nTotReg > 0 //Caso o usuário não seja um vendedor, mostrará todos os pedidos
				
				While !(CALIAS1)->(eof())
					If Empty(cVnd1)
						cVnd1	:= "'" + (cAlias1)->A3_COD + "'"
					Else
						cVnd1	+= ",'" + (cAlias1)->A3_COD + "'"
					EndIf
					(CALIAS1)->(DbSkip())
				End
				
				cRet := "@A3_COD IN (" + cVnd1 + ") "
				
			EndIf
		EndIf
		
		(cAlias1)->(DbCloseArea())
		
	EndIf
EndIf

RestArea(aArea)

Return(cRet)
