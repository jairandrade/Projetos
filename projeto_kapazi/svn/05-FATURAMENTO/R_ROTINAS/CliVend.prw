#Include "RwMake.ch"
#include "Topconn.ch"
#include "protheus.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Faturamento                                                                                                                            |
| Filtro na consulta do cliente para o Pedido de Venda                                                                                   |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 31/03/2017                                                                                                                       |
| Descricao: Restringir a visualização de Clientes na digitação dos pedidos de venda á apenas ao vendedor logado                         |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function CliVend()

Local cCodUser	:= RetCodUsr() //Retorno do cod do usuario
Local aArea			:= GetArea()
Local cAlias1		:= GetNextAlias()
Local cQuery1		:= " "
Local cRet			:= " "
Local cVnd1			:= " "

If AllTrim(FunName()) == "MATA410"
	
	// If !cCodUser $ GetMV("KP_VENINTE") .OR. cCodUser $ GetMV("KP_VENINT2")
	If !StaticCall(M415FSQL,PodeVerTodosPedidos)
		
		// Selecione os pedidos do vendedor que esta logado
		cQuery1 += " SELECT DISTINCT A1_VEND "
		cQuery1 += "   FROM "+RetSqlName("SA1")+" SA1 "
		cQuery1 += " INNER JOIN "+RetSqlName("SA3")+" SA3 "
		cQuery1 += "     ON SA1.A1_VEND = SA3.A3_COD "
		cQuery1 += " WHERE SA3.A3_CODUSR = '"+ cCodUser +"' "
		cQuery1 += "    AND SA1.A1_FILIAL = '" + xFilial("SA1") +"' "
		cQuery1 += "    AND SA1.D_E_L_E_T_ <> '*' "
		cQuery1 += "    AND SA3.D_E_L_E_T_ <> '*' "
		
		cQuery1 := ChangeQuery( cQuery1 )
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAlias1,.T.,.T.)
		dbSelectArea(cAlias1)
		
		nTotReg := Contar(CALIAS1,"!Eof()")
		(CALIAS1)->(DbGoTop())
		
		If !cCodUser $ GetMV("KP_CLIVEND") //verifica se o usuario está cadatrado ao parametro para não se enquadrar no bloqueio de vendedor
			If nTotReg > 0 //Caso o usuário não seja um vendedor, mostrará todos os pedidos
				
				While !(CALIAS1)->(eof())
					If Empty(cVnd1)
						cVnd1	:= "'" + (cAlias1)->A1_VEND + "'"
					Else
						cVnd1	+= ",'" + (cAlias1)->A1_VEND + "'"
					EndIf
					(CALIAS1)->(DbSkip())
				End
				
				cRet := "@A1_VEND IN (" + cVnd1 + ") "
				
			EndIf
		EndIf
		
		(cAlias1)->(DbCloseArea())
		
	EndIf
EndIf

RestArea(aArea)

Return(cRet)
