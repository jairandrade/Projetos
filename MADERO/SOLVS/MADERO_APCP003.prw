#include 'protheus.ch'
#include 'parmtype.ch'

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! APCP03LG                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza dados de apontamentos para legenda na OP                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 27/04/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/   

User Function APCP03LG()
Local cQuery	:= ""
Local cAlEmp	:= ""
Local lRet		:= .T.
Local lTotAp	:= .T.
Local aArea     := GetArea()

	cQuery := "	SELECT " + CRLF
	cQuery += "		COALESCE(SUM(H6_QTDPROD + H6_QTDPERD),0) TOT_SH6, " + CRLF 
	cQuery += "		COALESCE(SUM(CASE WHEN H6_PT = 'T' THEN 1 ELSE 0 END),0) QTD_F " + CRLF 
	cQuery += "	FROM " + RetSqlname("SH6") + " SH6 " + CRLF 
	cQuery += "	WHERE " + CRLF
	cQuery += "	        H6_FILIAL  = '" + xFilial("SH6") + "' " + CRLF
	cQuery += "	    AND H6_OP      = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + "' " + CRLF
	cQuery += "	    AND H6_PRODUTO = '" + SC2->C2_PRODUTO + "' " + CRLF
	cQuery += "	    AND SH6.D_E_L_E_T_ = ' ' " + CRLF
	cQuery := ChangeQuery(cQuery)
	cAlEmp := MPSysOpenQuery(cQuery)

	If (cAlEmp)->QTD_F == 0
		If (cAlEmp)->TOT_SH6 >= SC2->C2_QUANT
			lTotAp := .T.
		Else
			lTotAp := .F.
		EndIf

	Else
		lTotAp := .F.
	EndIf
	
	(cAlEmp)->(dbCloseArea())
	
	If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. lTotAp
		lRet := .T.
	Else
	 	lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet














