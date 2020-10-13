#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} EST005
Tela de exibicao de documentos fiscais com base no lote gerado pela rotina de inspecao
@type function
@version 
@author Thiago Berna
@since 10/08/2020
@return return_type, return_description
/*/
User Function EST005

    Local oDlgMens  As Object
    Local oMsg      As Object
    Local oFntTxt   As Object
    Local oBtnOk    As Object
    Local cTitulo   As Character
    Local cTxtConf  As Character
    Local cQuery    As Character
    Local cAlias    As Character
    Local cDoc      As Character
    Local cEnter    As Character
    Local cPerg     As Character

    oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    cTxtConf:='&Ok'
    cTitulo := "Documentos de Entrada"
    cQuery  := ""
    cAlias  := GetNextAlias()
    cDoc    := ""
    cEnter  := Chr(13) + Chr(10)
    cPerg   := "XEST005"

    If Pergunte(cPerg)

        cQuery := "SELECT SD1.D1_SERIE,SD1.D1_DOC " 
        cQuery += "FROM " + RetSqlName("SD1") + " SD1 "

        cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3A "
        cQuery += "ON SD3A.D3_FILIAL = SD1.D1_FILIAL "
        cQuery += "AND SD3A.D3_COD = SD1.D1_COD "
        cQuery += "AND SD3A.D3_LOTECTL = '" + MV_PAR02 + "' "
        cQuery += "AND SD3A.D3_CF = 'DE4' "
        cQuery += "AND SD3A.D_E_L_E_T_ = ' ' "

        cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3B "
        cQuery += "ON SD3B.D3_FILIAL = SD1.D1_FILIAL "
        cQuery += "AND SD3B.D3_COD = SD1.D1_COD "
        cQuery += "AND SD3B.D3_CF = 'RE4' "
        cQuery += "AND SD3B.D3_NUMSEQ = SD3A.D3_NUMSEQ "
        cQuery += "AND SD3B.D_E_L_E_T_ = ' ' "

        cQuery += "INNER JOIN " + RetSqlName("SD3") + " SD3C "
        cQuery += "ON SD3C.D3_FILIAL = SD1.D1_FILIAL "
        cQuery += "AND SD3C.D3_COD = SD1.D1_COD "
        cQuery += "AND SD3C.D3_LOTECTL =  SD3B.D3_LOTECTL "
        cQuery += "AND SD3C.D3_CF = 'RE6' "
        cQuery += "AND SD3C.D_E_L_E_T_ = ' ' "

        cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
        cQuery += "AND SD1.D1_COD = '" + MV_PAR01 + "' "
        cQuery += "AND SD1.D1_NUMSEQ = SD3C.D3_IDENT "
        cQuery += "AND SD1.D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

        While !(cAlias)->(Eof())
            cDoc += (cAlias)->(D1_DOC) + "/" + (cAlias)->(D1_SERIE) + cEnter
            (cAlias)->(DbSkip())
        EndDo

        If !Empty(cDoc)
            
            DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL                        
            @ 002, 004 GET oMsg VAR cDoc OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
            oMsg:lReadOnly := .T.
            
            @ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (oDlgMens:End()) OF oDlgMens PIXEL

            ACTIVATE MSDIALOG oDlgMens CENTERED

        Else

            MsgInfo("Nenhum documento encontrado.",cTitulo)

        EndIf

    EndIf

Return