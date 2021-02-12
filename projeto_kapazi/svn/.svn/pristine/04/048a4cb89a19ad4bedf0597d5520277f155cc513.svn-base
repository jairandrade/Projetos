#Include "RwMake.ch"
#include "Topconn.ch"
#include "protheus.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Faturamento                                                                                                                            |
| Filtro no browse do Pedido de Venda                                                                                                    |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04/02/2016                                                                                                                       |
| Descricao: Restringir a visualização de pedidos de venda apenas ao vendedor logado                                                     |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Ajustar P12 - Luis
User Function M410FSQL()
	Local aArea			:= GetArea()
	Local cCodUser		:= RetCodUsr() //Retorno do cod do usuario
	Local cAlias1		:= GetNextAlias()
	Local cQuery1		:= ""
	Local cRet			:= ""
	Local cVnd1			:= ""
	// Local cParaKP1		:= GetMv("KP_VENINTE")
	// Local cParaKP2		:= SuperGetMV("KP_VENINT2"	,.F. ,"000000")
	// Local cParaKP		:= cParaKP1 + "," + cParaKP2 + ',000000' //Adicionado o administrador

	// Selecione os pedidos do vendedor que esta logado
	// If !(__CUserId $ cParaKP)
	If !StaticCall(M415FSQL,PodeVerTodosPedidos)

		cQuery1 += " SELECT DISTINCT C5_VEND1 "
		cQuery1 += "   FROM "+RetSqlName("SC5")+" SC5 "
		cQuery1 += " INNER JOIN "+RetSqlName("SA3")+" SA3 "
		cQuery1 += "     ON SC5.C5_VEND1 = SA3.A3_COD "
		cQuery1 += " WHERE SA3.A3_CODUSR = '"+ cCodUser +"' "
		cQuery1 += "    AND SC5.C5_FILIAL = '" + xFilial("SC5") +"' "
		cQuery1 += "    AND SC5.D_E_L_E_T_ <> '*' "
		cQuery1 += "    AND SA3.D_E_L_E_T_ <> '*' "
		
		cQuery1 := ChangeQuery( cQuery1 )
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAlias1,.T.,.T.)
		dbSelectArea(cAlias1)
		
		nTotReg := Contar(CALIAS1,"!Eof()")
		(CALIAS1)->(DbGoTop())
		
		If nTotReg > 0 //Caso o usuário não seja um vendedor, mostrará todos os pedidos
			
			While !(CALIAS1)->(eof())
				
				If Empty(cVnd1)
						cVnd1	:= "'" + (cAlias1)->C5_VEND1 + "'"
					Else
						cVnd1	+= ",'" + (cAlias1)->C5_VEND1 + "'"
				EndIf
				(CALIAS1)->(DbSkip())
				
			EndDo
			
			cRet := "@(C5_VEND1 IN (" + cVnd1 + ") )"
			
		EndIf
		
		(cAlias1)->(DbCloseArea())
	EndIf

	RestArea(aArea)
Return(cRet)
