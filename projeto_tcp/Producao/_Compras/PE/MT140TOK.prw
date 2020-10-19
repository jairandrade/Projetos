#include "protheus.ch"

/*/{Protheus.doc} MT140TOK
Este ponto é executado após verificar se existem itens a serem 
gravados e tem como objetivo validar todos os itens do pré-documento
@type User Function
@author Kaique Sousa
@since 05/09/2019
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function MT140TOK()

    Local _aArea        := GetArea()
    Local _lIntMdt   	:= GetMv('TCP_INTMST')
    Local _l
    Local _lInclui 		:= ParamIXB[1]
    Local _lRetorno		:= .T.
    Local cDComMdt		:= GetMv('TCP_COMMDT')
    
    If _lInclui
        
        If _lInclui .And. _lIntMdt .And. cDComMdt == "1"
            //Verifico se existe produto do tipo ES no doc. de entrada
            If (fExistPrdES())
                _lRetorno := ExecBlock("TCCO02KM",.F.,.F.)
            EndIf
        EndIf
        
        IF _lRetorno
        	_lRetorno := u_ACOM010(cNFiscal,cA100For,cLoja)
			if !_lRetorno
				cA100For := space(TamSx3("F1_FORNECE")[1])
				cLoja 	 := space(TamSx3("F1_LOJA")[1])
			endif
        ENDIF
    Endif

    RestArea(_aArea)

Return( _lRetorno )

Static Function fExistPrdES()

	Local lRetorno	:= .F.
	Local _nPOSCOD  := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
    Local nX

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	for nX := 1 to len(aCols)
		If SB1->(dbSeek(xFilial("SB1")+aCols[nX][_nPOSCOD]))
			If SB1->B1_TIPO == "ES"
				lRetorno := .T.
				Exit
			EndIf
		EndIf
	Next nX

Return( lRetorno )