#include 'protheus.ch'
#include 'parmtype.ch'

user function FISVALNFE()
	// area atual
	Local aArea    	:= GetArea()
	// retorno
	Local lRet    	:= .T.
	// nota entrada / saida
	Local cTipo 	:= PARAMIXB[1]
	// filial
	// Local cFil    	:= PARAMIXB[2]
	// data emissao
	// Local cEmissao	:= PARAMIXB[3]
	// numero da nota
	Local cNota    	:= PARAMIXB[4]
	// serie
	Local cSerie   	:= PARAMIXB[5]
	// cliente
	Local cClieFor 	:= PARAMIXB[6]
	// loja
	Local cLoja    	:= PARAMIXB[7]
	// especie
	// Local cEspec   	:= PARAMIXB[8]
	// formulario proprio
	// Local cFormul  	:= PARAMIXB[9]
    Local lNaoTrans	:= StaticCall(M521CART,TGetMv,"  ","KA_NFENTRA","L",.T.,"FISVALNFE - Não retransmitir notas fiscais autorizadas ou denegadas? Rejeicao 656." )

	if type("_lFiltraNF") == "U" 
		_lFiltraNF := .f.
	Endif

	// _lFiltraNF := .T.

	if substr(cTipo,1,1) = 'S'
		SF2->(DbSetOrder(1))
		If SF2->(DbSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja))
		
			// nao retransmite notas S=autorizadas ou D=Denegadas
			if SF2->F2_FIMP $ "S/D" .and. lNaoTrans
				lRet := .F.
			Endif

			If lRet .and. _lFiltraNF 
				// valida se o campo existe
				IF SF2->( FieldPos("F2_K_USRCO") ) > 0 .and. SF2->F2_K_USRCO <> RetCodUsr() 
					lRet := .F.
				EndIf
			EndIf
		EndIF
	EndIf
	
	// restaura a area
	RestArea(aArea)
	// retorna
Return lRet