#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financerio                                                                                                                             |
| Devido antecipação do boleto o nosso número será gerado no momento da inclusão dos títulos no borderô                                  |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04.08.2017                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Realizado validação no ambiente compilar -- 09.08.2017 -- Andre/Rsac
User Function FA60BDE

LOCAL nNum     := ""
LOCAL aAreaSE1 := SE1->(GetArea())
LOCAL aAreaSEE := SEE->(GetArea())
LOCAL cPortado := SE1->E1_PORTADOR
LOCAL cAgencia := SE1->E1_AGEDEP
LOCAL cConta   := SE1->E1_CONTA
LOCAL cSubCta  := ""

/*IF !Empty(SE1->E1_NUMBCO)
	nNum:=StrZero(Val(TRBEE->EE_FAXATU)+1,8)
Else*/
	
	//-----------------------------------------------------------------------------

if !empty(cPortado)
	
	//Encontra a subconta
	cQry:=" SELECT  A6_SUBENV FROM "+retSqlName('SA6')
	cQry+=" WHERE A6_FILIAL= '" + xFilial("SA6") + "' 
	cQry+=" AND A6_COD ='"+cPortado+"'"
	cQry+=" AND A6_AGENCIA='"+cAgencia+"'"
	cQry+=" AND A6_NUMCON ='"+cConta+"'"
	cQry+=" AND D_E_L_E_T_<>'*'"
	
	
	IF Select('TRBA6') <> 0
		TRBA6->(DBCloseArea())
	EndIF
	
	TcQuery cQry new Alias "TRBA6"
	cSubCta:= TRBA6->A6_SUBENV
	
//-----------------------------------------------------------------------------	
	// Encontrar o nosso numero
	cQry:=" SELECT EE_FAXATU FROM "+retSqlName('SEE')
	cQry+=" WHERE EE_FILIAL = '" + xFilial("SEE") + "'
	cQry+=" AND EE_CODIGO = '"+cPortado+"'"
	cQry+=" AND EE_AGENCIA = '"+cAgencia+"'"
	cQry+=" AND EE_CONTA = '"+cConta+"'"
	cQry+=" AND EE_SUBCTA = '"+cSubCta+"'
	cQry+=" AND D_E_L_E_T_ <> '*'"
	
	IF Select('TRBEE') <> 0
		TRBEE->(DBCloseArea())
	EndIF
	
	TcQuery cQry new Alias "TRBEE"
	nNum := StrZero(Val(TRBEE->EE_FAXATU)+1,8)

	
//-----------------------------------------------------------------------------		
	Begin Transaction
	cQuery:= "UPDATE  "+retSqlName('SEE')+" SET EE_FAXATU ='"+StrZero(Val(TRBEE->EE_FAXATU)+1,8)+"'"
	cQuery+=" WHERE EE_FILIAL = '" + xFilial("SEE") + "'
	cQuery+=" AND EE_CODIGO = '"+cPortado+"'"
	cQuery+=" AND EE_AGENCIA = '"+cAgencia+"'"
	cQuery+=" AND EE_CONTA = '"+cConta+"'"
	cQuery+=" AND EE_SUBCTA ='"+cSubCta+"'
	cQuery+=" AND D_E_L_E_T_ <> '*'"
	
	TcSqlExec(cQuery)
	End Transaction
	
//-----------------------------------------------------------------------------
	
	RECLOCK("SE1",.F.)
	SE1->E1_NUMBCO:= nNum
	SE1->(msUnlock())
	
//EndIf

endif

RestArea(aAreaSE1)
RestArea(aAreaSEE)

Return .T.



