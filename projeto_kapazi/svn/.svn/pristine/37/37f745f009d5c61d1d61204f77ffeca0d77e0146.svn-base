#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: NFMESTPV		|	Autor: Luis Paulo							|	Data: 02/04/2018	//
//==================================================================================================//
//	Descrição: Funcao para estornar o pedido da SC9													//
//																									//
//==================================================================================================//
User Function NFMESTPV(cPedido,cIdNfMi)
Local aAreaC5	:= SC5->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())
Local cAliasQry := GetNextAlias()
Local cQuery 	:= ""
Local lRet		:= .T.

cQuery := "SELECT R_E_C_N_O_ SC9RECNO FROM " + RetSqlName( "SC9" ) + " "
cQuery += "WHERE "
cQuery += "C9_FILIAL='" + SC9->( xFilial( "SC9" ) ) + "' AND "
cQuery += "C9_PEDIDO='" + cPedido      + "' AND "
//cQuery += "C9_ITEM='"   + SC6->C6_ITEM     + "' AND "
//cQuery += "C9_SEQUEN<>'" + cNoLib			+ "' AND "
//cQuery += "C9_BLEST<>'10' AND C9_BLCRED<>'10' AND C9_BLEST<>'  ' AND "
//cQuery += "C9_BLEST<>'ZZ' AND C9_BLCRED<>'ZZ' AND C9_BLEST<>'  ' AND "
cQuery += "D_E_L_E_T_=' '"

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcgenQry( ,,cQuery ), cAliasQry, .F., .T. )
TcSetField( cAliasQry, "SC9RECNO", "N", 10, 0 )	

While !(cAliasQry)->(Eof())
	dbSelectArea("SC9")
	SC9->(MsGoto((cAliasQry)->SC9RECNO))
	
	a460Estorna()
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
EndDo

RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)
	
Return(lRet)