#include 'totvs.ch'

/*/{Protheus.doc} TCAT03WK
    Função para envio WF Baixa Ativo Fixo - ATFA036
    @type  Function
    @author Willian Kaneta
    @since 25/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCAT03WK(nOperacao)
    Local aAreaFN6  := FN6->(GetArea())
    Local aAreaFN7  := FN7->(GetArea())
    Local aDados    := {}
    Local cDescAtivo:= POSICIONE("SN1",1,xFilial("SN1")+FN6->FN6_CBASE,"N1_DESCRIC")
    Local cMotivo   := Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"16"+FN6->FN6_MOTIVO,"X5_DESCENG"))
    
    aadd(aDados,{   xFilial("SN1"),;
                    FN6->FN6_CBASE,;
                    cDescAtivo,;
                    cValToChar(FN6->FN6_QTDBX),;
                    SN4->N4_VLROC1,;
                    cMotivo,;
                    fGetUsrName(RetCodUsr())  } )            

    If Len(aDados) > 0
        fSendMail(aDados,nOperacao) //Envio email de notificação
    EndIf
    
    RestArea(aAreaFN7)
    RestArea(aAreaFN6)
Return Nil

/*/{Protheus.doc} fGetUsrName
	Retorna Nome Usuário
/*/
Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))

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
Static Function fSendMail(aDados,nOperacao)
    Local cMailNotify   := SuperGetMV("TCP_MAILAF",.F.,"")
    Local oHtml         := HtmlTemplate()
    Local cErro         := ""
    Local cBody         := ""
    Local cAssunto      := IIF(nOperacao == 3,"Fixed Assets Write-off Report","Fixed Assets Write-off Canceled")
    Local lRet          := .F.
    Local nX            := 0
    Local cMailUsr      := UsrRetMail(RetCodUsr())

    If oHtml != Nil .AND. !Empty(cMailNotify)
        oMail := TCPMail():New()        
        cBody += '<table cellpadding="0" cellspacing="0" border="0"'
        cBody += '    style="text-align:left;background-color:#0d3178;width:915px;height:30px">'
        cBody += '    <tbody>'
        cBody += '        <tr>'
        cBody += '        <td'
        cBody += '            style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff">'
        cBody += '            <div style="margin:0 0 0 10px"><strong>'+Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM])+" - "+IIF(nOperacao == 3,cAssunto,'<font color="orange">'+cAssunto+'</font>')+" - Executed on "+DTOC(DATE())+'</strong></div>'
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
        cBody += '</style>'
        cBody += '<table class="tg" style="width:100%;max-width:915px" align="center" role="module" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout:fixed">'
        cBody += '<thead>'
        cBody += '<tr>'
        cBody += '    <th class="tg-2fsp">Branch</th>'
        cBody += '    <th class="tg-2fsp">Fixed Asset Code:</th>'
        cBody += '    <th class="tg-2fsp">Description</th>'
        cBody += '    <th class="tg-2fsp">Write-off Quantity</th>'
        cBody += '    <th class="tg-2fsp">Write-off Value</th>'
        cBody += '    <th class="tg-2fsp">Writie-off Reason</th>'
        cBody += '    <th class="tg-2fsp">Date</th>'
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
            cBody += '    <td class="tg-0pky">R$ '+Alltrim(Transform(aDados[nX][5],"@E 9,999,999,999,999.99"))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][6])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(DTOC(dDataBase))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][7])+'</td>'
            cBody += '</tr>'
        Next nX
        cBody += '</tbody>'
        cBody += '</table>'
            
        oHtml:ValByName("BODY",cBody)

        oMail:SendMail( cMailNotify+";"+cMailUsr,;
                        cAssunto,;
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
