#INCLUDE "PROTHEUS.CH"                                                                                                                                               
#include 'parmtype.ch'
#include 'FWMVCDef.CH'

/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata650 - Geração de Ordem de Produção
-------------------------------------------------------------------------------
*/

/*/{Protheus.doc} MTA650I
Ponto de Entrada apos a gravação para atualizar campos
@type function
@version  12.1.27
@author Carlos Cleuber
@since 25/01/2021
/*/
User Function MTA650I()
Local aSC2		:= GetArea()
Local cAlias	:= ''
Local cQry		:= ''
Local cLoteOP	:= ''
Local cAno		:= substr(dtos(dDataBase),3,2)
Local cMes 		:= substr(dtos(dDataBase),5,2)
Local nRegSC2	:= SC2->(Recno())
Local lGrLote	:= .F.

If SC2->C2_TPOP == "F" 

	//Verifico se ja existe um Numero de Lote para OP Criada
	cQry:=	" SELECT DISTINCT C2_XLOTECT LOTEOP FROM " + RetSqlName("SC2") +;
			" SC2 WITH (NOLOCK) " +;
			" WHERE "+;
			" C2_FILIAL='" + xFilial("SC2") + "' AND "+;
			" C2_NUM='" + SC2->C2_NUM + "' AND "+;
			" SC2.D_E_L_E_T_=' ' "

	cAlias:= MPSysOpenQuery(cQry)

	If ! (cAlias)->(Eof()) .and. !Empty((cAlias)->LOTEOP)
		cLoteOP:= (cAlias)->LOTEOP
	Else
		lGrLote:= .T.
	Endif

	(cAlias)->( DbCloseArea() )

	If lGrLote

		//Verifico qual sera o proximo numero de lote a ser usado, pois a query anterior não foi retornado nenhum valor valido
		cQry:=	" SELECT MAX(C2_XLOTECT) LOTEOP FROM " + RetSqlName("SC2") +;
				" SC2 WITH (NOLOCK) " +;
				" WHERE "+;
				" C2_FILIAL='" + xFilial("SC2") + "' AND "+;
				" SUBSTRING(C2_XLOTECT,1,2)='" + cAno + "' AND" +;
				" SUBSTRING(C2_XLOTECT,3,2)='" + cMes + "' AND" +;
				" SC2.D_E_L_E_T_=' ' "

		cAlias:= MPSysOpenQuery(cQry)

		If ! (cAlias)->(Eof()) .and. !Empty((cAlias)->LOTEOP)
			cLoteOP:= soma1((cAlias)->LOTEOP)
		Else
			cLoteOP:= substr(dtos(dDataBase),3,4)+'0001'
		Endif

		(cAlias)->( DbCloseArea() )

	Endif

	RestArea(aSC2)
	SC2->(DbGoTo(nRegSC2))

	RecLock("SC2",.F.)
	SC2->C2_XLOTECT:= cLoteOP
	SC2->(MsUnlock())

Endif

RestArea(aSC2)
Return
