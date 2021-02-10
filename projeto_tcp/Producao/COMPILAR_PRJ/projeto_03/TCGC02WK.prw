#include 'totvs.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function TCGC02WK
    Função para preencher o campo CXN_XDESPL - Descrição Planilha - Nova Medição - CNTA121
    @type  Function
    @author Willian Kaneta
    @since 22/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCGC02WK()
	Local aAreaCNA  := CNA->(GetArea())
	Local aArea     := GetArea()
	Local oModel 	:= FWModelActive()
	Local oView     := FwViewActive()
	Local oModelCnd := oModel:GetModel("CNDMASTER")
	Local oModelCXN := oModel:GetModel("CXNDETAIL")
	Local _cCodCont := oModelCnd:GetValue("CND_CONTRA")
	Local _cRevisa  := oModelCnd:GetValue("CND_REVISA")
	Local _cNumPla  := oModelCXN:GetValue("CXN_NUMPLA")
	Local _cDescPla := ''
	Local _dData    := ''
	Local _lRefres  := .F.
	Local _nI

	For _nI:= 1 To oModelCXN:Length()
		oModelCXN:GoLine(_nI)
		_cNumPla := oModelCXN:GetValue("CXN_NUMPLA")
		_cDescPla := POSICIONE("CNA",1,xFilial("CNA")+_cCodCont+_cRevisa+_cNumPla,"CNA_DESCPL")

		if _cDescPla != oModelCXN:GetValue("CXN_XDESPL")
			_lRefres := .T.
			oModelCXN:LoadValue("CXN_XDESPL"  , _cDescPla )
		endif

	Next _nI

	IF _lRefres
		oView := FWViewActive()
		If (ValType(oView) == "O" .And. oView:IsActive())
			oModelCXN:GoLine(1)
			oView:Refresh('VIEW_CXN')
		EndIf
	ENDIF

	RestArea(aArea)
	RestArea(aAreaCNA)
Return Nil
