#include 'totvs.ch'

/*/{Protheus.doc} TCAT04WK
    Função para envio WF Transferência Ativo Fixo - ATFA036
    @type  Function
    @author Willian Kaneta
    @since 25/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCAT04WK()
    Local aDados    := {}
    Local cDescAtivo:= ""
    Local cIdMovFNR := FNR->FNR_IDMOV

    DbSelectArea("FNR")
    FNR->(DbSetOrder(1))

    If FNR->(MsSeek(xFilial("FNR")+cIdMovFNR))
        While FNR->(!EOF()) .AND. xFilial("FNR")+FNR->FNR_IDMOV == xFilial("FNR")+cIdMovFNR
            cDescAtivo  := POSICIONE("SN1",1,xFilial("SN1")+FNR->FNR_CBADES,"N1_DESCRIC")
            nVlrBem     := RETVALBM(FNR->FNR_CBADES)

            aadd(aDados,{   DTOC(FNR->FNR_DATA),;
                            FNR->FNR_CBADES,;
                            cDescAtivo,;
                            FNR->FNR_FILORI,;
                            FNR->FNR_GRPORI,;
                            FNR->FNR_GRPDES,;
                            cValToChar(FNR->FNR_QTDDES),;
                            nVlrBem,;
                            fGetUsrName()  } )
            FNR->(DbSkip())
        EndDo
    EndIf           

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
    Local cAssunto      := "Fixed Assets Transfer Report"
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
        cBody += '</style>'
        cBody += '<table class="tg" style="width:100%;max-width:915px" align="center" role="module" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout:fixed">'
        cBody += '<thead>'
        cBody += '<tr>'       
        cBody += '    <th class="tg-2fsp">Branch</th>'
        cBody += '    <th class="tg-2fsp">Transaction Date</th>'
        cBody += '    <th class="tg-2fsp">Fixed Asset Code</th>'
        cBody += '    <th class="tg-2fsp">Description</th>'
        cBody += '    <th class="tg-2fsp">Target Branch</th>
        cBody += '    <th class="tg-2fsp">Source Asset Group</th>'
        cBody += '    <th class="tg-2fsp">Target Group</th>'
        cBody += '    <th class="tg-2fsp">Amount in Destination</th>'
        cBody += '    <th class="tg-2fsp">Transaction Value</th>'
        cBody += '    <th class="tg-2fsp">User</th>'
        cBody += '</tr>'
        cBody += '</thead>'
        cBody += '<tbody>'
        For nX := 1 To Len(aDados)
            cBody += '<tr>'
            cBody += '    <td class="tg-0pky">'+cFilAnt+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][1])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][2])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][3])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][4])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][5])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][6])+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][7])+'</td>'
            cBody += '    <td class="tg-0pky">R$ '+Alltrim(Transform(aDados[nX][8],"@E 9,999,999,999,999.99"))+'</td>'
            cBody += '    <td class="tg-0pky">'+Alltrim(aDados[nX][9])+'</td>'
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

/*/{Protheus.doc} RETVALBM
    Função retorno Valor Bem tabela SN4
    @type  Function
    @author Willian Kaneta
    @since 02/09/2020
    @version 1.0
    @param cCodAtF
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETVALBM(cCodAtF)
    Local nValor    := 0
    Local cAliasSN4 := GetNextAlias()

    BeginSql alias cAliasSN4
        SELECT TOP 1 SN4.N4_VLROC1 VALOR
        FROM %TABLE:SN1% SN1
        INNER JOIN %TABLE:SN4% SN4
            ON SN4.N4_CBASE     = SN1.N1_CBASE
            AND SN4.N4_FILIAL   = SN1.N1_FILIAL
            AND SN4.D_E_L_E_T_  = ''
            AND SN4.N4_OCORR    = '04'
            AND SN4.N4_TIPOCNT  = '1'
            AND SN4.N4_VLROC1   <> 0
        WHERE SN1.D_E_L_E_T_    = ''
            AND SN1.N1_FILIAL   = %EXP:xFilial("SN1")%
            AND SN1.N1_CBASE    = %EXP:cCodAtF%
        ORDER BY    SN1.N1_FILIAL,
                    SN1.N1_GRUPO
    EndSql
    
    While !(cAliasSN4)->(EOF())
        nValor := (cAliasSN4)->VALOR
        (cAliasSN4)->(DbSkip())
    EndDo
    (cAliasSN4)->(DbCloseArea())
Return nValor
