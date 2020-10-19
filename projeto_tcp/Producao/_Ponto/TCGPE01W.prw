/*/{Protheus.doc} TCGPE01W
    Fun��o utilizada para realizar a valida��o campo ZP3_MOTIVO
    @type  Function
    @author Willian Kaneta
    @since 05/08/2020
    @version 1,0
    @return lRet .F./ .T.
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCGPE01W()
    Local lRet  := .T.
    Local cBloq := POSICIONE("ZP1",1,xFilial("ZP1")+M->ZP3_MOTIVO,"ZP1_BLOQUE")

    If cBloq == "S" .OR. cBloq == ""
        Help(NIL, NIL, "TCGPE01W", NIL, "Motivo inv�lido", 1,0, NIL, NIL, NIL, NIL, NIL,;
            {"Verificar no cadastro de Motivos se o campo Bloqueio est� preenchido com N-N�o"})
        lRet := .F.
    EndIf 

Return lRet
