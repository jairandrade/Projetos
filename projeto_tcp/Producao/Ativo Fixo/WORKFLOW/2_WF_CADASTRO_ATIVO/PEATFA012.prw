#include 'totvs.ch'

/*/{Protheus.doc} ATFA012
    Ponto de entrada MVC rotina cadastro de Ativo Fixo - ATFA012
    @type  Function
    @author Willian Kaneta
    @since 26/08/2020
    @version 1.0
    @return xRet
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ATFA012()
    Local oModel    := Nil
	Local cIdPonto 	:= ""
	Local _cIdModel	:= ""
    Local nOper	    := 0
    Local xRet 		:= .T.

    //Variável para tratar o envio do WF apena 1 vez
    //Na cópia executa o FORMCOMMITTTSPOS 2 vezes duplicando o WF
    Public lXEnvia

    If PARAMIXB <> Nil
        oModel    := PARAMIXB[1]
        cIdPonto  := PARAMIXB[2]
        _cIdModel := PARAMIXB[3]

        If cIdPonto == 'MODELVLDACTIVE'
            lXEnvia   := .T.
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS' .and. _cIdModel == "SN3DETAIL"
            nOper := oModel:GetOperation()
            If Type('lXEnvia') == "L"
                If (nOper == 3 .OR. nOper == 5) .AND. lXEnvia
                    U_TCAT02WK(nOper)
                    lXEnvia := .F.
                EndIf
            EndIf
        EndIf
    EndIf

Return xRet
