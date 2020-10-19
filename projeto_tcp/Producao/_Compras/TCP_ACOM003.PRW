#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM003
Rotina para cadastro de classificação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM003()
 
AxCadastro("Z02", "Cadastro Classificação de Fornecedores", "U_ACOM003DEL()", ".T.")

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM003DEL
Rotina para validação de exclusão
@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------                                                              
User Function ACOM003DEL()
Local cQuery := ""
Local lRet := .T.             

	If (Select("TMPZ02") <> 0)
   		DbSelectArea("TMPZ02")
   		TMPZ02->(DbCloseArea())
    Endif
		
    cQuery += "  SELECT SA2.A2_NOTAFOR "
    cQuery += "    FROM "+RetSqlName("SA2")+" SA2 "
    cQuery += "   WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"' "
    cQuery += "     AND SA2.A2_NOTAFOR = '"+Z02->Z02_CLASSI+"' "
    cQuery += "     AND SA2.D_E_L_E_T_ <> '*' "
    
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPZ02",.T., .F.)
	
	DbSelectArea("TMPZ02")
	TMPZ02->(DbGoTop())
	
	If !TMPZ02->(EOF())
		Alert('Não é possível excluir este registro. O mesmo já foi utilizado no cadastro de fornecedores.')
		lRet := .F.
	EndIF
		      
	If (Select("TMPZ02") <> 0)
   		DbSelectArea("TMPZ02")
   		TMPZ02->(DbCloseArea())
    Endif
           
Return lRet