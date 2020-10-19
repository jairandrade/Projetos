#include 'totvs.ch'

/*/{Protheus.doc} TCAT02WK
    Função para envio WF Cadastro Ativo Fixo:
    Inclusão/Exclusão/classificação (ATFA012/ATFA240)
    @type  Function
    @author Willian Kaneta
    @since 25/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCAT02WK(nOper)
    Local aAreaSN1  := SN1->(GetArea())
    Local aAreaSN3  := SN3->(GetArea())
    Local aDados    := {}
    Local cTxDeprec := cValToChar(SN3->N3_TXDEPR1)
    Local nValorAtF := IIF(INCLUI,SN3->N3_VORIG1,RETVALOR())
    
    If nValorAtF != 0
        If Alltrim(cTxDeprec) == "0"
             cTxDeprec := cValToChar(POSICIONE("SN3",1,xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM,"N3_TXDEPR1"))
        EndIf
        aadd(aDados,{   xFilial("SN1"),;
                        SN1->N1_GRUPO,;
                        SN1->N1_CBASE,;
                        SN1->N1_DESCRIC,;
                        cValToChar(SN1->N1_QUANTD),;
                        cTxDeprec,;
                        nValorAtF,;
                        fGetUsrName(RetCodUsr())  } )            

        If Len(aDados) > 0
            fSendMail(aDados,nOper) //Envio email de notificação
        EndIf
    EndIf
    
    RestArea(aAreaSN3)
    RestArea(aAreaSN1)
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
Static Function fSendMail(aDados,nOper)
    Local cMailNotify   := SuperGetMV("TCP_MAILAF",.F.,"")
    Local oHtml         := HtmlTemplate()
    Local cErro         := ""
    Local cAssunto      := ""
    Local cBody         := ""
    Local lRet          := .F.
    Local nX            := 0
    Local cMailUsr      := UsrRetMail(RetCodUsr())

    If oHtml != Nil .AND. !Empty(cMailNotify)
        If nOper == 3
            cAssunto  := "Fixed Assets Inclusion Report"
        ElseIf nOper == 5
            cAssunto  := "Fixed Assets Exclusion Report"
        ElseIf nOper == 6
            cAssunto  := "Fixed Assets Classification Report"
        EndIf

        oMail := TCPMail():New()        
        cBody += '<table cellpadding="0" cellspacing="0" border="0"'
        cBody += '    style="text-align:left;background-color:#0d3178;width:915px;height:30px">'
        cBody += '    <tbody>'
        cBody += '        <tr>'
        cBody += '        <td'
        cBody += '            style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#ffffff">'
        cBody += '            <div style="margin:0 0 0 10px"><strong>'+Alltrim(FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM])+" - "+cAssunto+" - Executed on "+DTOC(DATE())+'</strong></div>'
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
        cBody += '    <th class="tg-2fsp">Fixed Asset Code</th>'
        cBody += '    <th class="tg-2fsp">Description</th>'
        cBody += '    <th class="tg-2fsp">Qtd. assets</th>'
        cBody += '    <th class="tg-2fsp">Deprec Annual Rate</th>'
        cBody += '    <th class="tg-2fsp">Value</th>'
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
            cBody += '    <td class="tg-1pky">'+Alltrim(aDados[nX][5])+'</td>'
            cBody += '    <td class="tg-1pky">'+Alltrim(aDados[nX][6])+'</td>'
            cBody += '    <td class="tg-1pky">R$ '+Alltrim(Transform(aDados[nX][7],"@E 9,999,999,999,999.99"))+'</td>'
            cBody += '    <td class="tg-1pky">'+Alltrim(DTOC(dDataBase))+'</td>'
            cBody += '    <td class="tg-1pky">'+Alltrim(aDados[nX][8])+'</td>'
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

/*/{Protheus.doc} RETVALOR
    Função para retornar o valor do bem SN3->N3_VORIG1
    @type  Static Function
    @author Willian Kaneta
    @since 27/08/2020
    @version 1.0
    @return nValor
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETVALOR()
    Local nValor    := 0
    Local aAreaSN1  := SN1->(GetArea())
    Local aAreaSN3  := SN3->(GetArea())
    Local cAliasTmp := GetNextAlias()

    BeginSql Alias cAliasTmp
        SELECT  *
		FROM %TABLE:SN3% SN3
		WHERE SN3.N3_FILIAL  = %xFilial:SN3%
            AND SN3.N3_CBASE  = %EXP:SN1->N1_CBASE%
            AND SN3.N3_ITEM   = %EXP:SN1->N1_ITEM%
            AND SN3.N3_TIPO   = '01'
            AND SN3.N3_BAIXA  = '0'
            AND SN3.%NOTDEL% 
    EndSql

    If !(cAliasTmp)->( Eof() )
        nValor := (cAliasTmp)->N3_VORIG1       
    EndIf

    RestArea(aAreaSN3)
    RestArea(aAreaSN1)
Return nValor
