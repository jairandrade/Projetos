#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCMD05KM
description Tela de historico de atestados
@author  Kaique Mathias
@since   10/12/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCMD05KM()

    Local aSavArea := GetArea()
    Local aFields   := {    FwSX3Util():GetDescription("TM0_CC"),;
                            FwSX3Util():GetDescription("TNY_DTINIC"),;
                            FwSX3Util():GetDescription("TNY_QTDTRA"),;
                            FwSX3Util():GetDescription("TNY_CID");
                            }
    Local aStruTRB  := {}
    Local cAlias    := GetNextAlias()
    Local aSize     := MsAdvSize( .F. )
    Local dDataAt   := DDATABASE-60
    Local aObjects  := {}
    Local cMatric   := FwFldGet('TNY_NUMFIC')
    Local aDados    := {} 
    Local nQtdAfast := 0
    Local oModel 	:= FwModelActive()
    Local cCID      := oModel:GetModel('TNYMASTER1'):GetValue("TNY_CID")
    
    BeginSql Alias cAlias 

        SELECT  TM0.TM0_NOMFIC,
                TM0.TM0_CC,
                TNY_DTINIC,
                TNY_QTDTRA,
                TNY_CID
        FROM %table:TNY% TNY
        INNER JOIN %table:TM0% TM0 ON    TM0.TM0_FILIAL=TNY.TNY_FILIAL AND
                                    TM0.TM0_NUMFIC=TNY.TNY_NUMFIC AND
                                    TM0.%NotDel%
        INNER JOIN %table:SRA% SRA ON    SRA.RA_FILIAL=TNY.TNY_FILIAL AND
                                    SRA.RA_MAT=TM0.TM0_MAT AND
                                    SRA.%NotDel%
        WHERE   TNY.TNY_NUMFIC = %Exp:cMatric% AND
                TNY.TNY_DTINIC >= %Exp:dDataAt% AND
                SUBSTRING(TNY.TNY_CID,1,3) = %Exp:SubS(cCID,1,3)% AND
                TNY.%NotDel%
    EndSql

    dbSelectArea( cAlias )
    (cAlias)->(dbGotop())

    //Preenche arquivo temporario
    While !(cAlias)->(Eof())
        aAdd(aDados,{   (cAlias)->TM0_CC,;
                        DTOC(STOD((cAlias)->TNY_DTINIC)),;
                        Alltrim((cAlias)->TNY_QTDTRA),;
                        (cAlias)->TNY_CID;
                        })
        nQtdAfast := nQtdAfast + Val((cAlias)->TNY_QTDTRA)
        (cAlias)->(dbSkip())
    EndDo

    dbSelectArea( cAlias )
    (cAlias)->(dbGotop())

    If Len(aDados) > 0

        //Calcula dimensoes da tela
        aSize[1] /= 1.5
        aSize[2] /= 1.5 
        aSize[3] /= 1.5
        aSize[4] /= 1.3
        aSize[5] /= 1.5
        aSize[6] /= 1.3
        aSize[7] /= 1.5
        
        AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
        AAdd( aObjects, { 100, 060,.T.,.T.} )
        AAdd( aObjects, { 100, 020,.T.,.F.} ) 

        aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
        aPosObj := MsObjSize( aInfo, aObjects,.T.)
        
        DEFINE MSDIALOG oDlg TITLE "Historico de Atestados - Ult. 60 dias" FROM 000,000 TO 340,600 OF oMainWnd PIXEL 

        cTexto1 := AllTrim(RetTitle("RA_NOME")) + ": "+ (cAlias)->TM0_NOMFIC
        @ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oDlg PIXEL

        oListBox := TWBrowse():New( 020,005,298,130,,aFields,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
        oListBox:SetArray(aDados)
		oListBox:bLine := { || aDados[oListBox:nAT]}

        @ 153,005 SAY "Total Dias Afastados :" + Alltrim(Str(nQtdAfast)) SIZE aPosObj[1,3],008 OF oDlg PIXEL

        ACTIVATE MSDIALOG oDlg CENTERED

    EndIf

    (cAlias)->(DbCloseArea()) 
    
    RestArea(aSavArea)

Return( .T. )