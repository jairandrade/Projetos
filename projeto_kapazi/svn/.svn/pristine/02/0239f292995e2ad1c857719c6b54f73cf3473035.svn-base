#include "PROTHEUS.CH"
#include "topconn.ch"

User function KFATR18()
    Local lRet := .T.

    While lRet
        lRet := TelaAlt()
    Enddo

Return

Static Function TelaAlt()
    Local oEndereco
    Local cEndereco := Space(TamSx3("D3_LOCALIZ")[1]) 
    Local oProduto
    Local cProduto  := Space(TamSx3("B1_COD")[1])
    Local nLin      := 35
    Local lRet      := .F.
   	// funcao botao ok
	Local bOkb	 	:= {|| lRet := .T.,oDlgPick:End()}
	// funcao cancelar
	Local bCancel 	:= {|| oDlgPick:End() }
	// msg ao deletar
	Local lMsgDel	:= .F.
	// botoes
	Local aButtons	:= {}
	// registro
	Local nRecno 	:= Nil
	// alias
	Local cAlias	:= Nil
	// exibe mashups
	Local lMashups	:= .F.
	// imprime padrao
	Local lImpCad	:= .F.
	// botoes padra
	Local lPadrao	:= .F.
	// exibe botao ok
	Local lHasOk	:= .T.
	// exibe walk
	Local lWalkThru	:= .F.

    Static oDlgPick

    DEFINE MSDIALOG oDlgPick TITLE "Alterar endereço Picking" FROM 000, 000  TO 200, 250 of oDlgPick PIXEL

        @ nLin, 008 TO 092, 116 OF oDlgPick PIXEL

        nLin += 08
        @ nLin      , 013 SAY "Produto" OF oDlgPick PIXEL
        @ nLin - 1  , 048 MSGET oProduto VAR cProduto SIZE 060, 010 OF oDlgPick PIXEL Valid IIF(VldProd(cProduto),cEndereco := GetEnd(cProduto),.F.) F3 "SB1"

        nLin += 15
        @ nLin      , 013 SAY "Endereço" OF oDlgPick PIXEL
        @ nLin -  1 , 048 MSGET oEndereco VAR cEndereco SIZE 060, 010 OF oDlgPick PIXEL Valid VldEnd(cEndereco) F3 "SBE"

    ACTIVATE MSDIALOG oDlgPick CENTERED on init EnchoiceBar(oDlgPick,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

    If lRet .and. !Empty(AllTrim(cProduto))
        GrvEnd(cProduto,cEndereco)
    Endif

Return lRet

Static Function VldProd(cProduto)
    Local aArea:= GetArea()
    Local lRet := .T.

    If Empty(AllTrim(cProduto))
        Return lRet
    Endif

    SB1->( DbSetOrder(1) )
    If !SB1->( MsSeek(xFilial("SB1")+cProduto))
        MsgStop("Produto não localizado.")
        lRet := .F.
    Endif

    RestArea(aArea)
Return lRet

Static Function GetEnd(cProduto)
    Local aArea     := GetArea()
    Local cEndereco := Space(TamSX3("D3_LOCALIZ")[1])

    If Empty(AllTrim(cProduto))
        Return cEndereco
    Endif

    SBZ->( DbSetOrder(1) )
    If SBZ->( MsSeek(xFilial("SBZ")+cProduto))
        If !Empty(AllTrim(SBZ->BZ_XPICKIN))
            cEndereco := SBZ->BZ_XPICKIN
        Endif
    Endif

    RestArea(aArea)
Return cEndereco

Static Function GrvEnd(cProduto,cEndereco)
    Local aArea     := GetArea()

    SBZ->( DbSetOrder(1) )
    If SBZ->( MsSeek(xFilial("SBZ")+cProduto))
        If AllTrim(SBZ->BZ_XPICKIN) <> AllTrim(cEndereco)
            RecLock("SBZ",.F.)
                SBZ->BZ_XPICKIN := cEndereco
            MsUnLock("SBZ")
        Endif
    Else
        RecLock("SBZ",.T.)
            SBZ->BZ_FILIAL  := xFilial("SBZ")
            SBZ->BZ_COD     := cProduto
            SBZ->BZ_XPICKIN := cEndereco
        MsUnLock("SBZ")
    Endif

    RestArea(aArea)
Return

Static Function VldEnd(cEndereco)
    Local aArea := GetArea()
    Local lRet  := .T.

    If Empty(AllTrim(cEndereco))
        Return lRet
    Endif

    SBE->( DbSetOrder(9) )
    If !SBE->( MsSeek(xFilial("SBE")+cEndereco))
        MsgStop("Endereço não localizado.")
        lRet := .F.
    Endif

    RestArea(aArea)
Return lRet