#include 'totvs.ch'
/*/{Protheus.doc} User Function nomeFunction
    Este ponto de entrada pertence à rotina de manutenção de documentos de entrada, MATA103. É executada em A103NFISCAL, na inclusão de um documento de entrada. Ela permite ao usuário decidir se a inclusão será executada ou não.
    @type  Function
    @author user
    @since 18/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT103PN()
Local nOp := PARAMIXB
Local lRet := .t.

If Type("lAtualPr") == "U" 
		Public lAtualPr	:= .f.
	ElseIf Type("lAtualPr") == "L"
		lAtualPr	:= .f.
EndIf

Return(lRet)
