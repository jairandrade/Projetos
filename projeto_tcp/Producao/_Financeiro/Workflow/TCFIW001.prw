#include "protheus.ch"

/*/{Protheus.doc} TCFIW001
Workflow de Pagamentos manuais pendentes de aprovações
@type function
@version 
@author kaiquesousa
@since 6/4/2020
@return return_type, return_description
/*/
User Function TCFIW001( aPars )
    
    Local lPrepare  := Type("cEmpAnt")=="U" 
    Default aPars   := {"02","01",.T.}
    
    If( len( aPars ) >= 3 )
        lAll := aPars[3]
    Else
        lAll := .T.
    EndIf

    If lPrepare
        RpcSetType( 3 )
        RpcSetEnv( aPars[1], aPars[2] )
    EndIf

    TFIW01RUN(lAll)

    If lPrepare
        RpcClearEnv()
    EndIf

Return( Nil )

/*/{Protheus.doc} TFIW01RUN
Função para processamento e envio do e-mail
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/4/2020
@param aPars, array, param_description
@return return_type, return_description
/*/

Static Function TFIW01RUN(lAll)
    
    Local cAliasTmp     := GetNextAlias()
    Local cHttpServer   := "http://" + Alltrim(GetMV("MV_ENDWF")) + ":" + AllTrim(GetMv("TCP_PORTWF"))
    Local cUrl          := cHttpServer + "/pp/u_tcpwfhttpret.apl?"
    Local cNaturAgr     := "%" + FormatIn(GetNatAgr(),"|") + "%"
    Local cSubject      := ""
    Local cNatuAux      := ""
    
    If( lAll )

        BeginSql Alias cAliasTmp
            SELECT  SCR.*,
                    ZA0.*,
                    ISNULL(CAST(CAST(ZA0_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS
            FROM %table:SCR% SCR
            INNER JOIN %table:ZA0% ZA0 ON   ZA0.ZA0_FILIAL = %xFilial:ZA0% AND
                                            ZA0.ZA0_CODIGO = SCR.CR_NUM AND
                                            ZA0.%NotDel%
            WHERE SCR.CR_FILIAL = %xFilial:SCR% AND
                SCR.CR_STATUS = '02' AND
                SCR.CR_TIPO = 'AP' AND
                SCR.%NotDel% AND
                ZA0.ZA0_NATURE NOT IN %exp:cNaturAgr%
            ORDER BY SCR.CR_USER,SCR.CR_NUM
        EndSql

    Else

        BeginSql Alias cAliasTmp
            SELECT  SCR.*,
                    ZA0.*,
                    ISNULL(CAST(CAST(ZA0_OBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS
            FROM %table:SCR% SCR
            INNER JOIN %table:ZA0% ZA0 ON   ZA0.ZA0_FILIAL = %xFilial:ZA0% AND
                                            ZA0.ZA0_CODIGO = SCR.CR_NUM AND
                                            ZA0.%NotDel%
            WHERE SCR.CR_FILIAL = %xFilial:SCR% AND
                SCR.CR_STATUS = '02' AND
                SCR.CR_TIPO = 'AP' AND
                SCR.%NotDel% AND
                ZA0.ZA0_NATURE IN %exp:cNaturAgr% 
            ORDER BY ZA0.ZA0_NATURE,SCR.CR_USER,SCR.CR_NUM
        EndSql

    EndIf

    If !(cAliasTmp)->( Eof() ) 

        cUserAux := ""
        cNatuAux := ""

        oMail := TCPMail():New()
        oHtml := TWFHtml():New("\WORKFLOW\HTML\TCFIW001.html")
        
        dbSelectArea( cAliasTMP )
        (cAliasTMP)->( dbGotop() )

        If( lAll )
            oHtml:ValByName("HEADER","MANUAL PAYMENT PENDING APPROVAL WORKFLOW")
        Else
            dbSelectArea("SED")
            SED->(DBSetOrder(1))
            SED->( MSSeek( FWxfilial("SED") + (cAliasTMP)->ZA0_NATURE ) )
            cSubject := Alltrim( SED->ED_DESCRIC )
            oHtml:ValByName("HEADER","MANUAL PAYMENT PENDING APPROVAL WORKFLOW - " + cSubject )
        EndIf

        While !(cAliasTMP)->( Eof() )
            If( lAll )
                If ( !Empty( cUserAux ) .And. cUserAux # (cAliasTMP)->CR_USER )
                    SendMail(oHtml,oMail,cUserAux)
                    FreeObj(oHtml)
                    oHtml := TWFHtml():New("\WORKFLOW\HTML\TCFIW001.html")
                    oHtml:ValByName("HEADER","MANUAL PAYMENT PENDING APPROVAL WORKFLOW")
                EndIf
            Else
                If (; 
                        (;
                            !Empty(cNatuAux) .And.; 
                            cNatuAux # (cAliasTMP)->ZA0_NATURE; 
                        ) .Or.;
                        (;
                            !Empty( cUserAux ) .And.; 
                            cUserAux # (cAliasTMP)->CR_USER;
                        );
                    )
                    
                    cSubject := Alltrim( SED->ED_DESCRIC ) 
                    SendMail(oHtml,oMail,cUserAux,cSubject)
                    FreeObj(oHtml)
                    oHtml := TWFHtml():New("\WORKFLOW\HTML\TCFIW001.html")
                    SED->( MSSeek( FWxfilial("SED") + (cAliasTMP)->ZA0_NATURE ) )
                    cSubject := Alltrim( SED->ED_DESCRIC )
                    oHtml:ValByName("HEADER","MANUAL PAYMENT PENDING APPROVAL WORKFLOW - " + cSubject )
                
                EndIf
            
            EndIf

            aAdd((oHtml:ValByName("it.item9")),(cAliasTMP)->ZA0_CODIGO)
            aAdd((oHtml:ValByName("it.item3")),DTOC(STOD((cAliasTMP)->ZA0_DTSOLI)))
            aAdd((oHtml:ValByName("it.item1")),(cAliasTMP)->ZA0_NUM)
            aAdd((oHtml:ValByName("it.item2")),(cAliasTMP)->ZA0_TIPO)
            aAdd((oHtml:ValByName("it.item10")),DTOC(STOD((cAliasTMP)->ZA0_EMISSA)))
            aAdd((oHtml:ValByName("it.item11")),DTOC(STOD((cAliasTMP)->ZA0_VENCTO)))
            aAdd((oHtml:ValByName("it.item4")),DTOC(STOD((cAliasTMP)->CR_EMISSAO)))
            aAdd((oHtml:ValByName("it.item5")),(cAliasTMP)->ZA0_CLIFOR + " - " + Posicione("SA2",1,xFilial("SA2")+(cAliasTMP)->ZA0_CLIFOR,"A2_NREDUZ"))
            aAdd((oHtml:ValByName("it.item6")),"R$" + TransForm((cAliasTMP)->CR_TOTAL,PesqPict("ZA0","ZA0_VALOR")))
            aAdd((oHtml:ValByName("it.item7")),Alltrim((cAliasTMP)->OBS))
            
            cHash       := cUrl + Encode64("funcName=u_TCFI02RET&empresa=" + cEmpAnt + "&filial=" + cFilAnt + "&codigo=" + (cAliasTMP)->ZA0_CODIGO + "&opc=4" + "&aprovador=" + (cAliasTMP)->CR_APROV + "&horas=" + Alltrim(SubS((cAliasTMP)->CR_XHORAS,1,4)))
            aAdd((oHtml:ValByName("it.link_apr")), cHash )
            
            cHash       := cUrl + Encode64("funcName=u_TCFI02RET&empresa=" + cEmpAnt + "&filial=" + cFilAnt + "&codigo=" + (cAliasTMP)->ZA0_CODIGO + "&opc=7" + "&aprovador=" + (cAliasTMP)->CR_APROV + "&horas=" + Alltrim(SubS((cAliasTMP)->CR_XHORAS,1,4)))
            aAdd((oHtml:ValByName("it.link_rej")), cHash )
            
            cUserAux := (cAliasTMP)->CR_USER
            cNatuAux := (cAliasTMP)->ZA0_NATURE
            
            (cAliasTMP)->( dbSkip() )
        EndDo

        SendMail(oHtml,oMail,cUserAux,cSubject)
        
        FreeObj(oMail)
    EndIf
    
    If Select(cAliasTmp) > 0
        (cAliasTmp)->( dbCloseArea() )
    EndIf

    If( Select("SED") > 0 )
        SED->( dbCloseArea() )
    EndIf

Return( Nil )

/*/{Protheus.doc} SendMail
description
@type function
@version 
@author kaiquesousa
@since 6/4/2020
@param oHtml, object, param_description
@param oMail, object, param_description
@param cUserID, character, param_description
@return return_type, return_description
/*/

Static Function SendMail( oHtml, oMail, cUserID, cSubject )
    
    Local cName := UsrFullName(cUserID)
    Local cMail := UsrRetMail(cUserID)
    Local cErro := ""
    
    Default cSubject := ""

    oMail:SendMail( cMail,;
                    "Manual Payment Pending Approval " + cSubject + " on " + DTOC(DATE()) + ' - ' + cName  ,;
                    oHtml:HtmlCode(),;
                    @cErro,;
                    {})
Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNatAgr
Funcao responsavel por retornar as naturezas que deverao ser enviadas
em um wf agrupado
@author  Kaique Mathias
@since   16/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GetNatAgr()
    Local cNaturAgr := SuperGetMV("TCP_NATWFA",.F.,"3039|3038")
Return( cNaturAgr )

