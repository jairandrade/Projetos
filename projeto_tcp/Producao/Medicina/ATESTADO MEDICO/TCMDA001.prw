#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCMDA001
Funcao responsavel por montar a tela de justificativa
@author  Kaique Sousa
@since   07/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCMDA001()

    Local oDlg			:= Nil
    Local oObs			:= Nil
    Local oTButt		:= Nil
    Local cObs			:= Space( 254 )
    Local nAcao         := 0
    Local oModel        := FWModelActive() //Ativa modelo utilizado.
    Local oMldTNY       := oModel:GetModel( 'TNYMASTER1' )

    oDlg 	:= TDialog():New( 0, 0, 25, 455,"Justificativa de Lançamento em Atraso",,,,,CLR_BLACK,CLR_WHITE,,,.t.)
    oObs := TGet():New( 01, 01, { |u| If( PCount() > 0, cObs := u, cObs ) } , oDlg, 180, 010, "@!", { || Len( AllTrim( cObs ) ) > 10 }, CLR_RED, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., ,"cObs", , , , )
    oTButt 	:= TButton():New( 01, 185, "Confirma", oDlg, { || nAcao := 1, oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. )
    oDlg:Activate( , , , .t., { | | .t. }, , { || } )

    If( nAcao = 0 )
        Return( .F. )
    Else
        oMldTNY:SetValue("TNY_XJUSTI", cObs )
        fSendMail() //Envio email de notificação
    EndIf

Return( .T. )

/*/{Protheus.doc} fSendMail
Funcao responsavel pelo envio do email
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/2/2020
@return return_type, return_description
/*/

Static Function fSendMail()

    Local cMailNotify   := getMv("TCP_MAIAFP") 
    Local cLogo         := "http://" + Alltrim(GetMV("MV_ENDWF")) + ":" + AllTrim(GetMv("TCP_PORTWF")) + "/ws/images/tcp-brand-cm-port.png"
    Local oHtml         := HtmlTemplate()
    Local cErro         := ""
    
    dbSelectArea("TM0")
    TM0->(dbSetOrder(1))
    TM0->(dbSeek(xFilial("TM0")+FwFldGet("TNY_NUMFIC")))

    oMail := TCPMail():New()
    
    oHtml:ValByName("LOGO",cLogo)
    oHtml:ValByName("HEADER","ATESTADO INCLUIDO FORA DO PRAZO")
    
    cBody := BuildHtml()

    oHtml:ValByName("BODY",cBody)
    
    oMail:SendMail( cMailNotify,;
                    "Atestado Incluido Fora do Prazo" ,;
                    oHtml:HtmlCode(),;
                    @cErro,;
                    {})

    FreeObj(oMail)
    FreeObj(oHtml)

Return( Nil )

/*/{Protheus.doc} BuildHtml
Função responsavel por montar o html p/ envio do e-mail
@type user function
@version 12.1.25
@author Kaique Mathias
@since 6/2/2020
@return character, cBody
/*/

Static function BuildHtml()

    Local cBody     := ""
    Local nPrzLanc  := SuperGetMV("TCP_PRZATE",.F.,48)

    cBody := '<tr>'
    cBody += '    <td'
    cBody += '    style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '    &nbsp;</td>'
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '    <td style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold"> '
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Foi realizado o lançamento do atestado médico nº ' + FwFldGet("TNY_NATEST") + ' acima do prazo de ' + Alltrim(Str(nPrzLanc)) + ' horas. Segue abaixo informações detalhadas do lançamento: </td>'
    cBody += '        </p>
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '    <td style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '    &nbsp;</td>'
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '    <td style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Matricula:'
    cBody += '            <span style="color:#6d6f72">' + TM0->TM0_MAT + '</span>'
    cBody += '        </p>
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Nome:'
    cBody += '            <span style="color:#6d6f72">' + TM0->TM0_NOMFIC + '</span>'
    cBody += '        </p>'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Data de admissão:'
    cBody += '            <span style="color:#6d6f72">' + DTOC(TM0->TM0_DTIMPL) + '</span>'
    cBody += '        </p>'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Centro de custo:'
    cBody += '            <span style="color:#6d6f72">' + TM0->TM0_CC + " - " + Posicione('CTT',1,xFilial('CTT')+TM0->TM0_CC,"CTT_DESC01") + '</span>'
    cBody += '        </p>'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Data/Hora inicio: '
    cBody += '            <span style="color:#6d6f72">' + DTOC( FwFldGet('TNY_DTINIC') ) + " - " + FwFldGet('TNY_HRINIC') + '</span>'
    cBody += '        </p>'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Data/Hora Fim: '
    cBody += '            <span style="color:#6d6f72">' + DTOC( FwFldGet('TNY_DTFIM') ) + " - " + FwFldGet('TNY_HRFIM') + '</span>'
    cBody += '        </p>'
    cBody += '        <p style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '            Justificativa:'
    cBody += '            <span style="color:#6d6f72">' + FwFldGet('TNY_XJUSTI') + '</span>'
    cBody += '        </p></td>'
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '    <td style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '    &nbsp;</td>'
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '    <td style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#0d3178;margin:0 0 5px 16px;font-weight:bold">'
    cBody += '    &nbsp;</td>'
    cBody += '</tr>'

Return( cBody )

//-------------------------------------------------------------------
/*/{Protheus.doc} DateDiffTime
Calcula diferença de horas com base entre duas datas e horas
@author  Kaique Sousa
@since   07/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function DateDiffTime(dDataIni,cHrIni,dDataFim,cHrFim)
    
    local   n

    nStart := val( subs( cHrIni , 7 , 2 ) )     // second
    nStart += val( subs( cHrIni , 4 , 2 ) )*60  // minute * 60
    nStart += val( left( cHrIni ,2 ) )*(60*60)    // hour*60*60

    nEnd := val( subs( cHrFim , 7 , 2 ) )     // second
    nEnd += val( subs( cHrFim , 4 ,2 ) )*60   // minute*60
    nEnd += val( left( cHrFim , 2 ) )*(60*60)   // hour*60*60

    nEnd += (dDataFim - dDataIni)*(24*(60*60))       // days*24*60*60
    
    // nElapse is the elapse time in seconds
    nElapse := nEnd - nStart
    
    // how many hours
    n := int( nElapse/ (60*60) )
    

Return( n )

/*/{Protheus.doc} HtmlTemplate
Template Hml para mensagens de notificacao padrao TCP
@type function
@version 
@author Kaique Mathias
@since 6/2/2020
@return objetct, oHtml
/*/

Static Function HtmlTemplate()

    Local oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFICATION.html")

Return( oHTML )