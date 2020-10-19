#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} User Function TCCT001
    Função para envio Workflow de lançamento contábeis manuais executado via schedule.
    @type  Function
    @author Willian Kaneta
    @since 27/05/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCCT001()
    Local cGrEmpExe  := "02"
    Local _aAreaSM0  := {}
    Local nX         := 0
    Local aDadosCT2  := {}
    Local lRet       := .F.

    Private aEmpresas:= {}

    OpenSM0()
    RPCSETENV('02', '01',)
    
    cGrEmpExe  := SuperGetMV("TCP_GREMCT",.F.,'02') // Grupos de empresas para execução da rotina

    DbSelectArea("SM0")
    _aAreaSM0 := SM0->(GetArea())
    SM0->(DbGoTop())

    While SM0->(!EOF())
        IF SM0->M0_CODIGO $ cGrEmpExe
            nPos := aScan( aEmpresas , { |x| x[1] == SM0->M0_CODIGO } )
            IF nPos == 0
                Aadd( aEmpresas , { SM0->M0_CODIGO,SM0->M0_CODFIL,Alltrim(SM0->M0_NOME), } )
            EndIF
        EndIF
        SM0->(DbSkip())
    EndDo

    asort(aEmpresas,,,{|x,y| x[1] < y[1]})

	For nX := 1 To Len(aEmpresas)
        //troco de empresa
		dbCloseAll() //Fecho todos os arquivos abertos
		OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)  
        SM0->(MsSeek(aEmpresas[nX][1] + aEmpresas[nX][2],.T.))      
        cEmpAnt     := SM0->M0_CODIGO
        cFilAnt     := SM0->M0_CODFIL
        OpenFile(cEmpAnt + cFilAnt)
        aDadosCT2   := {}
        aDadosCT2   := RETLANCM()
        If  Len(aDadosCT2) > 0
            aEmpresas[nX][4] := aDadosCT2
        EndIf
    Next nX

    lRet := fSendMail() //Envio email de notificação
    
    dbCloseAll() //Fecho todos os arquivos abertos
	OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
	dbSelectArea("SM0")
	SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
	cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
	cEmpAnt := SM0->M0_CODIGO
	
	OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
Return Nil

/*/{Protheus.doc} RETLANCM
    Função para retornar lançamentos contábeis
    @type  Static Function
    @author Willian Kaneta
    @since 27/05/2020
    @version 1.0
    @return aDadosCT2
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETLANCM()
    Local cAliasCT2 := GetNextAlias()
    Local cUsrIncLc := ""
    Local cNomFil   := ""
    Local aDadosRet := {}
    
    Private nDiasEnv  := SuperGetMV("TCP_DIASGL",.F.,0)
    Private dDataAte := dDataBase
    Private dDataDe  := dDataBase - nDiasEnv 
    
    BeginSql alias cAliasCT2	
		SELECT  CT2.CT2_FILIAL,
                CT2.CT2_DATA,
                CT2.CT2_LOTE,
                CT2.CT2_SBLOTE,
                CT2.CT2_DOC,
                CT2.CT2_LINHA,
                CT2.CT2_DEBITO,
                CT2.CT2_CREDIT,
                CT2.CT2_VALOR,
                CT2.CT2_HIST,
                CT2.CT2_USERGI
		FROM %table:CT2% CT2
		WHERE	CT2.CT2_MANUAL = '1'
                AND CT2.CT2_DATA >= %EXP:DtoS(dDataDe)%
                AND CT2.CT2_DATA <= %EXP:DtoS(dDataAte)%
                AND CT2.D_E_L_E_T_ = ''
        ORDER BY CT2.CT2_FILIAL,
                 CT2.CT2_DATA,
                 CT2.CT2_LOTE,
                 CT2.CT2_SBLOTE,
                 CT2.CT2_DOC,
                 CT2.CT2_LINHA
	    					
	EndSql
    
    //MemoWrite("C:\Temp\tcp_ct2.txt",getlastquery()[2])

    DbSelectArea("CT2")
    CT2->(DbSetOrder(1))
    While (cAliasCT2)->(!EOF())
        If MsSeek((cAliasCT2)->(CT2_FILIAL+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA))
            cUsrIncLc := FWLeUserlg("CT2_USERGI",1)
        EndIf
        cNomFil := ALLTRIM(FWFilialName(cEmpAnt ,(cAliasCT2)->CT2_FILIAL ))
        aadd(aDadosRet,{(cAliasCT2)->CT2_FILIAL+"-"+Alltrim(cNomFil),;
                        (cAliasCT2)->CT2_LOTE,;
                        (cAliasCT2)->CT2_DOC,;
                        (cAliasCT2)->CT2_DATA,;
                        (cAliasCT2)->CT2_DEBITO,;
                        (cAliasCT2)->CT2_CREDIT,;
                        (cAliasCT2)->CT2_VALOR,;
                        (cAliasCT2)->CT2_HIST,;
                        cUsrIncLc})
        (cAliasCT2)->(DbSkip())
    EndDo

Return aDadosRet

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
Static Function fSendMail()

    Local cMailNotify   := SuperGetMV("TCP_MAILCT",.F.,"")
    Local oHtml         := HtmlTemplate()
    Local cErro         := ""
    Local cBody         := ""
    Local nX            := 0
    Local nY            := 0
    Local lRet          := .F.

    If oHtml != Nil .AND. !Empty(cMailNotify)
        oMail := TCPMail():New()
        For nX := 1 To Len(aEmpresas)
            If VALTYPE(aEmpresas[nX][4]) != "U"
                cBody += '<table cellpadding="0" cellspacing="0" border="0"'
                cBody += '    style="text-align:left;background-color:#0d3178;width:915px;height:30px">'
                cBody += '    <tbody>'
                cBody += '        <tr>'
                cBody += '        <td'
                cBody += '            style="font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#ffffff">'
                cBody += '            <div style="margin:0 0 0 10px"><strong>'+aEmpresas[nX][3]+" - Manual Accounting Entries Report"+'</strong></div>'
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
                cBody += '    <th class="tg-2fsp">Lot Number</th>'
                cBody += '    <th class="tg-2fsp">Doc Number</th>'
                cBody += '    <th class="tg-2fsp">Include Date</th>'
                cBody += '    <th class="tg-2fsp">Debit Account</th>'
                cBody += '    <th class="tg-2fsp">Credit Account</th>'
                cBody += '    <th class="tg-2fsp">Value</th>'
                cBody += '    <th class="tg-2fsp">History</th>'
                cBody += '    <th class="tg-2fsp">User</th>'
                cBody += '</tr>'
                cBody += '</thead>'
                cBody += '<tbody>'
                For nY := 1 To Len(aEmpresas[nX][4])
                    cBody += '<tr>'
                    cBody += '    <td class="tg-0pky">'+Alltrim(aEmpresas[nX][4][nY][1])+'</td>'
                    cBody += '    <td class="tg-0pky">'+Alltrim(aEmpresas[nX][4][nY][2])+'</td>'
                    cBody += '    <td class="tg-0pky">'+Alltrim(aEmpresas[nX][4][nY][3])+'</td>'
                    cBody += '    <td class="tg-0pky">'+DTOC(STOD(aEmpresas[nX][4][nY][4]))+'</td>'
                    cBody += '    <td class="tg-0pky">'+aEmpresas[nX][4][nY][5]+'</td>'
                    cBody += '    <td class="tg-0pky">'+aEmpresas[nX][4][nY][6]+'</td>'
                    cBody += '    <td class="tg-0pky">R$ '+Alltrim(Transform(aEmpresas[nX][4][nY][7],"@E 9,999,999,999,999.99"))+'</td>'
                    cBody += '    <td class="tg-0pky">'+aEmpresas[nX][4][nY][8]+'</td>'
                    cBody += '    <td class="tg-0pky">'+aEmpresas[nX][4][nY][9]+'</td>'
                    cBody += '</tr>'
                Next nY
                cBody += '</tbody>'
                cBody += '</table>'
                lRet := .T. 
            EndIf        
        Next nX

        If  lRet
            
            oHtml:ValByName("BODY",cBody)
            oMail:SendMail( cMailNotify,;
                            "Manual Accounting Entries Report " + DTOC(dDataBase),;
                            oHtml:HtmlCode(),;
                            @cErro,;
                            {})

                FreeObj(oMail)
                FreeObj(oHtml)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} RETLANCM
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