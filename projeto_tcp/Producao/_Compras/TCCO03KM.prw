#include "protheus.ch"
#include "totvs.ch"
#INCLUDE "RWMAKE.CH"

#DEFINE TOTPED	03	// Total do Pedido

/*/{Protheus.doc} TCCO03KM
Função responsavel por abrir dialog para informar 
@type  User Function
@author Kaique Sousa
@since 05/09/2019
@version 1.0
@return return, nil, nulo
@example
/*/

User Function TCCO03KM()

    Local _nPosPed      := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO"}) 
    Local _lRetorno     := .T.
    Local _lShowVenc    := .F.
    Local _lFin         := .T.
    Local nX			:= 1
    Private _aVenctos   := {}
    Private _cCondPC    := ""
    Private _nDias      := GetMv("TCP_DIAVEN",.F.,13)
    Private _nDiasCtr   := 0
    
    dbSelectArea("SC7")
    SC7->(dbSetOrder(1))

    dbSelectArea("SF4")
    SF4->(dbSetOrder(1))

    For nX := 1 to len(aCols)
        If !_lShowVenc //Se gerar financeiro
            If !Empty(aCols[nX][_nPosPed]) //Se tiver preenchido o pedido
                SC7->(MSSeek(xFilial("SC7")+aCols[nX][_nPosPed]))
                If .Not. Empty(SC7->C7_TES)
                    If SF4->(dbSeek(xFilial("SF4")+SC7->C7_TES))
                        _lFin := SF4->F4_DUPLIC == "S"
                    EndIf
                EndIf
                _cCondPC := SC7->C7_COND
                If !Empty(_cCondPC) .And. _lFin
                    _aVenctos := Condicao(a140Total[TOTPED],_cCondPC,,DDEMISSAO)
                    _nDiasCtr := datediffday(_aVenctos[01][01],DDEMISSAO)+1
                    
                    If  ( Empty(SC7->C7_CONTRA) .And. ( _aVenctos[01][01]-Date() ) < _nDias ) 
                        //_lRetorno := MontaTela()
                        MsgInfo("Documento lançado em atraso. O novo vencimento será calculado a partir da data de digitação. O novo vencimento será: " + DTOC( Date() + _nDias ) + "." )
                        _lShowVenc := .T. 
                    //ElseIf ( !Empty(SC7->C7_CONTRA) .And. ( ( _aVenctos[01][01]-DDEMISSAO  ) < 15 ) .Or. ( _aVenctos[01][01] < Date() ) )
                    ElseIf !Empty(SC7->C7_CONTRA)
                        If ( _aVenctos[01][01] < Date() ) .Or. ( ( _nDiasCtr > 15 ) .And. ( ( _aVenctos[01][01]-Date() ) < _nDias ) )
                            //_lRetorno := MontaTela()
                            If _nDiasCtr < 15
                                MsgInfo("Documento lançado em atraso. O novo vencimento será calculado a partir da data de digitação. O novo vencimento será: " + DTOC( Date() ) + "." )
                            Else
                                MsgInfo("Documento lançado em atraso. O novo vencimento será calculado a partir da data de digitação. O novo vencimento será: " + DTOC( Date() + _nDias ) + "." )
                            EndIf
                            _lShowVenc := .T.
                        EndIf
                    Endif
                EndIf
            EndIf
        EndIf
    Next nX
    
Return( _lRetorno )

/*/{Protheus.doc} TCCO03KM
Função responsavel por abrir dialog para informar 
@type  User Function
@author Kaique Sousa
@since 05/09/2019
@version 1.0
@return return, nil, nulo
@example
@see (links_or_references)
/*/

Static Function MontaTela()

    Local _oBtnCanc
    Local _oBtnValid
    Local _oFont1       := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
    Local oGetCond
    Local oGroup1
    Local _lRet         := .F.
    Local oSayCond         
    Local cDescCond     := Space(200)
    Local _bRefresh     := {|| oGetCond:Refresh(),;
                               oWBrowse1:Refresh()}
    Local _bValid       := {||  cDescCond := Posicione('SE4',1,xFilial('SE4')+_cCondPC,"E4_DESCRI"),;
                                fCarrCondPag(_cCondPC),;
                                eval(_bRefresh),;
                                .T.}
    Private oWBrowse1
    Private aWBrowAux   := {}
    Private aWBrowse1   := {}
    Private oOk         := LoadBitmap( GetResources(), 'BR_VERDE' )
    Private oNo         := LoadBitmap( GetResources(), 'BR_VERMELHO' )

    Static _oDlg

    DEFINE MSDIALOG _oDlg TITLE "Nova Condição de Pagamento" FROM 000, 000  TO 350, 400 COLORS 0, 16777215 PIXEL

    @ 001, 003 GROUP oGroup1 TO 031, 195 PROMPT "Informe a nova condição de Pagamento" OF _oDlg COLOR 0, 16777215 PIXEL
    @ 013, 044 SAY oSayCond PROMPT cDescCond SIZE 138, 010 OF _oDlg FONT _oFont1 COLORS 0, 16777215 PIXEL
    @ 009, 007 MSGET oGetCond VAR _cCondPC SIZE 027, 012 OF _oDlg COLORS 0, 16777215 VALID Eval(_bValid) FONT _oFont1 F3 "SE4" PIXEL
    @ 156, 106 BUTTON _oBtnCanc PROMPT "Cancelar" SIZE 037, 012 ACTION (_oDlg:End()) OF _oDlg PIXEL
    @ 156, 151 BUTTON _oBtnValid PROMPT "Ok" SIZE 037, 012 ACTION (If(_lRet := fValida(),(fGrava(),_oDlg:End()),MsgInfo('Não é permitido lançar NF com Data de vencimento inferior a ' + Alltrim(Str(_nDias)) + ' dias.' ))) OF _oDlg PIXEL
    
    @ 036,004 LISTBOX oWBrowse1 FIELDS HEADER " ","Vencimento" SIZE 191, 110 FIELDSIZES 020,080 OF _oDlg PIXEL  //ColSizes 50,50
    
    Eval(_bValid)

    ACTIVATE MSDIALOG _oDlg CENTERED

Return( _lRet )

/*/{Protheus.doc} TCCO03KM
Função responsavel por abrir dialog para informar 
@type  User Function
@author Kaique Sousa
@since 05/09/2019
@version 1.0
@return return, nil, nulo
@example
/*/

Static Function fCarrCondPag(cCondicao)     
    
    Local oLegend 	:= oOk
    Local i			:= 1	

    aWBrowse1 := {}
    aWBrowAux := Condicao(a140Total[TOTPED],cCondicao,,DDEMISSAO)
    
    For i := 1 to len(aWBrowAux)
        
        If( Empty(SC7->C7_CONTRA) .And. (aWBrowAux[i,01]-Date()) < _nDias )
            oLegend := oNo
        ElseIf !Empty(SC7->C7_CONTRA) 
            If ( aWBrowAux[i][01] < Date() ) .Or. ( ( _nDiasCtr > 15 ) .And. ( ( aWBrowAux[i][01]-Date() ) < _nDias ) )
                oLegend := oNo 
            EndIf
        EndIf
        
        Aadd(   aWBrowse1,{oLegend,;  
                aWBrowAux[i,01]})
    
    Next i

    oWBrowse1:SetArray(aWBrowse1)
    oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt][01],;
                            aWBrowse1[oWBrowse1:nAt][02]}}

Return( Nil )
 
/*/{Protheus.doc} TCCO03KM
Função responsavel por abrir dialog para informar 
@type  User Function
@author Kaique Sousa
@since 05/09/2019
@version 1.0
@return return, nil, nulo
@example
@see (links_or_references)
/*/

Static function fValida()

    Local lRetorno 	:= .T.
	Local i			:= 1
		
    For i := 1 to len(aWBrowse1)
        If  ( Empty(SC7->C7_CONTRA) .And. ( aWBrowAux[i][01]-Date() ) < _nDias )
            lRetorno := .F.
        ElseIf !Empty(SC7->C7_CONTRA) 
            If ( aWBrowAux[i][01] < Date() ) .Or. ( ( _nDiasCtr > 15 ) .And. ( ( aWBrowAux[i][01]-Date() ) < _nDias ) ) 
                lRetorno := .F.
            Endif
        EndIf
    Next i 

Return( lRetorno )

Static Function fGrava() 
    _CondNf := _cCondPC
Return( NIL )