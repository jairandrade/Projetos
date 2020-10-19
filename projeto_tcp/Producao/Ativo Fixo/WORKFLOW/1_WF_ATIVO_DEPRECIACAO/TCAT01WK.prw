#include 'totvs.ch'

/*/{Protheus.doc} TCAT01WK
    Função para envio WF Resumo de depreciação executado no PE AF050FIM
    @type  Function
    @author Willian Kaneta
    @since 25/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCAT01WK()
    Local cAliasSN4 := GetNextAlias()
    Local cGrupAnt  := ""
    Local cDescGrp  := ""
    Local cCCDepr   := ""
    Local cTXDepr   := ""
    Local nVlrTotItm:= 0
    Local nVlrDprGrp:= 0
    Local nQtdBens  := 0
    Local aDados    := {}

    BeginSql alias cAliasSN4
        SELECT  SN1.N1_CBASE,
                SN1.N1_GRUPO,
                SN3.N3_VORIG1 AS VLRITEM,
                SN4.N4_VLROC1 AS VLRGRUPO
        FROM %TABLE:SN1% SN1
        INNER JOIN %TABLE:SN3% SN3
            ON SN3.N3_CBASE     = SN1.N1_CBASE
            AND SN3.N3_FILIAL   = SN1.N1_FILIAL
            AND SN3.N3_ITEM     = SN1.N1_ITEM
            AND SN3.N3_TIPO		= '01'
            AND SN3.N3_BAIXA    = '0'
            AND SN3.D_E_L_E_T_  = ''
        INNER JOIN %TABLE:SN4% SN4
            ON SN4.N4_CBASE     = SN1.N1_CBASE
            AND SN4.N4_FILIAL   = SN1.N1_FILIAL
            AND SN4.D_E_L_E_T_  = ''
            AND SN4.N4_DATA     = %EXP:DtoS(dDataBase)%
            AND SN4.N4_OCORR    = '06'
            AND SN4.N4_TIPOCNT  = '4'
        WHERE SN1.D_E_L_E_T_    = ''
        ORDER BY    SN1.N1_FILIAL,
                    SN1.N1_GRUPO
    EndSql

    While !(cAliasSN4)->(EOF())
        nVlrDprGrp  +=(cAliasSN4)->VLRGRUPO
        nVlrTotItm  +=(cAliasSN4)->VLRITEM
        cGrupAnt := (cAliasSN4)->N1_GRUPO 
        
        (cAliasSN4)->(DbSkip())

        If (cGrupAnt != (cAliasSN4)->N1_GRUPO .AND. !Empty(cGrupAnt)) .OR. (cAliasSN4)->(EOF())
            cDescGrp := POSICIONE("SNG",1,xFilial("SNG")+cGrupAnt,"NG_DESCRIC")
            cCCDepr  := POSICIONE("SNG",1,xFilial("SNG")+cGrupAnt,"NG_CCDEPR")
            cTXDepr  := cValToChar(POSICIONE("SNG",1,xFilial("SNG")+cGrupAnt,"NG_TXDEPR1"))
            aadd(aDados,{   xFilial("SN1"),;
                            cGrupAnt,;
                            cCCDepr,;
                            cDescGrp,;
                            cTXDepr,;
                            nVlrTotItm,;
                            STRZERO(nQtdBens,4),; 
                            nVlrDprGrp,;
                            fGetUsrName()  } )
            cGrupAnt := (cAliasSN4)->N1_GRUPO
            nQtdBens := 1
            nVlrDprGrp  := 0
            nVlrTotItm  := 0
        Else
            nQtdBens++ 
        EndIf 
              
    EndDo

    If Len(aDados) > 0
        fSendMail(aDados) //Envio email de notificação
    EndIf
Return Nil

/*/{Protheus.doc} fGetUsrName
	Retorna Nome Usuário
/*/
Static Function fGetUsrName()
Return(AllTrim(UsrFullName(RetCodUsr())))

/*/{Protheus.doc} fSendMail
    Função para enviar email
    @type  Static Function
    @since 27/05/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fSendMail(aDados)
    Local cMailNotify   := SuperGetMV("TCP_MAILAF",.F.,"")
    Local oHtml         := HtmlTemplate()
    Local cErro         := ""
    Local cBody         := ""
    Local nX            := 0
    Local lRet          := .F.
    Local cMailUsr      := UsrRetMail(RetCodUsr())

    If oHtml != Nil .AND. !Empty(cMailNotify)
        oMail := TCPMail():New()
        cBody += '<table cellpadding="0" cellspacing="0" border="0"'
        cBody += '    style="text-align:left;background-color:#0d3178;width:915px;height:30px">'
        cBody += '    <tbody>'
        cBody += '        <tr>'
        cBody += '        <td'
        cBody += '            style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff">'
        cBody += '            <div style="margin:0 0 0 10px"><strong>'+Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM])+" - Depreciation Fixed Assets Report - Executed on "+DTOC(DATE())+'</strong></div>'
        cBody += '        </td>'
        cBody += '        </tr>'
        cBody += '    </tbody>'
        cBody += '</table>'
        cBody += '<style type="text/css">'
        cBody += '.tg  {border-collapse:collapse;border-spacing:0;}'
        cBody += '.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:12px;'
        cBody += 'overflow:hidden;padding:10px 5px;word-break:normal;}'
        cBody += '.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:12px;'
        cBody += 'font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}'
        cBody += '.tg .tg-2fsp{background-color:#0d3178;border-color:inherit;color:#ffffff;font-weight:bold;text-align:center;vertical-align:top}'
        cBody += '.tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}'
        cBody += '.tg .tg-1pky{border-color:inherit;text-align:center;vertical-align:top}'
        cBody += '</style>'
        cBody += '<table class="tg" style="width:100%;max-width:915px" align="center" role="module" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout:fixed">'
        cBody += '<thead>'
        cBody += '<tr>'
        cBody += '    <th class="tg-2fsp">Branch</th>'
        cBody += '    <th class="tg-2fsp">Group assets</th>'
        cBody += '    <th class="tg-2fsp">Accounting Dep Accum</th>'
        cBody += '    <th class="tg-2fsp">Description</th>'
        cBody += '    <th class="tg-2fsp">Tx. An. Depr.1</th>'
        cBody += '    <th class="tg-2fsp">Current Value</th>'
        cBody += '    <th class="tg-2fsp">Qtd. assets</th>'
        cBody += '    <th class="tg-2fsp">Group Depreciation Value</th>'
        cBody += '    <th class="tg-2fsp">Reference Date</th>'
        cBody += '    <th class="tg-2fsp">User</th>'
        cBody += '</tr>'
        cBody += '</thead>'
        cBody += '<tbody>'
        For nX := 1 To Len(aDados)
            cBody += '<tr>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][1])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][2])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][3])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][4])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][5])+'</td>'
            cBody += '    <td class="tg-0pky">R$ '+Alltrim(Transform(aDados[nX][6],"@E 9,999,999,999,999.99"))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][7])+'</td>'
            cBody += '    <td class="tg-0pky">R$ '+Alltrim(Transform(aDados[nX][8],"@E 9,999,999,999,999.99"))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(DTOC(dDataBase))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][9])+'</td>'
            cBody += '</tr>'         
        Next nX
        cBody += '</tbody>'
        cBody += '</table>'
            
        oHtml:ValByName("BODY",cBody)
        oMail:SendMail( cMailNotify+";"+cMailUsr,;
                        "Depreciation Fixed Assets Report",;
                        oHtml:HtmlCode(),;
                        @cErro,;
                        {})

        FreeObj(oMail)
        FreeObj(oHtml)
    EndIf

Return lRet

/*/{Protheus.doc} HtmlTemplate
    Retorna o layout HTML
    @type  Static Function
    @author Willian Kaneta
    @since 27/05/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function HtmlTemplate()
    Local cHTMLSrc  := "workflow\HTML\MAILNOTCT2.html"
    Local oHtml     := Nil
    
    If File(cHTMLSrc)
        oHtml := TWFHtml():New(cHTMLSrc)
    Endif

Return( oHTML )
