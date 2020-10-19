#include "protheus.ch"

/*/{Protheus.doc} MDT685
Ponto de entrada MVC
@type  User Function
@author Kaique Sousa
@since 29/08/2019
@version 1.0
@param PARAMIXB, Array
1- Objeto
2-Id Ponto Entrada
3-Id Modelo
@return xRet, logical, xx
/*/
User Function MDT685()

    Local aParam    := PARAMIXB
    Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''

    If aParam <> NIL
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
        If cIdPonto == "BUTTONBAR"
            xRet := { {'Imprimir', 'IMPRIMIR', { || fImprimir() }, 'Imprimir Atestado' } }
        EndIf
    EndIf

Return( xRet ) 

/*/{Protheus.doc} fImprimir
Função responsavel por imprimir o atestado dos dados informados em tela
@type  Static Function
@author Kaique Sousa
@since date
@version version
@return return, nil, nil
/*/

Static Function fImprimir()
    
    Local oMail,oHtml   := Nil
    Local cMat          := ""
    Local cFileHTML     := FwFldGet("TNY_NUMFIC") + ".htm"
    Local cLibCli       := ''
    Local lMacOs        := (GetRemoteType(@cLibCli),('MAC' $ cLibCli))
	
    dbSelectArea("TM0")
    TM0->(dbSetOrder(1))
    TM0->(dbSeek(xFilial("TM0")+FwFldGet("TNY_NUMFIC")))
    
    cMat    := TM0->TM0_MAT
    cNome   := TM0->TM0_NOMFICH
    
    oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILRH01.HTML")
    
    oHtml:ValByName("cMat",cMat) 
    oHtml:ValByName("cNome",cNome)    
    
    if(VAL(ALLTRIM(FwFldGet("TNY_QTDTRA"))) > 0)                                    
		oHtml:ValByName("cDtAtestado",FwFldGet("TNY_DTINIC"))
		oHtml:ValByName("cQtdDias",FwFldGet("TNY_QTDTRA"))
	ELSE
		oHtml:ValByName("cDtAcomp",IF(EMPTY(FwFldGet("TNY_QTDTRA")) .OR. FwFldGet("TNY_QTDTRA") == '0',DTOC(FwFldGet("TNY_DTINIC"))+' Horário: ' + FwFldGet("TNY_HRINIC") + ' às ' +FwFldGet("TNY_HRFIM"), '')         )
	ENDIF

    oHtml:ValByName("cDtOutros","")          
    oHtml:ValByName("cQtdDiasOutros","")          
    oHtml:ValByName("cDtHoje",DTOC(DATE()))

    oHtml:SaveFile( GetTempPath(.T.) + cFileHTML)

    If lMacOs
        shellExecute("Browser", "/usr/bin/safari", GetTempPath(.T.) + cFileHTML, "/", 1 )
    Else    
        shellExecute("Open", GetTempPath(.T.) + cFileHTML, "", "C:\", 1 )
    EndIf

Return( Nil )