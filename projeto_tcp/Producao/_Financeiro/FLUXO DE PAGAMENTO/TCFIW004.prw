#include "protheus.ch"

/*/{Protheus.doc} TCFIW004
worflow de aprovação de pagamento manual
@type  User Function
@author Kaique Mathias
@since 01/04/2020
/*/

User Function TCFIW004(nOpc)
    
    Local cHttpServer   := "http://" + Alltrim(GetMV("MV_ENDWF")) + ":" + AllTrim(GetMv("TCP_PORTWF"))
    //Local cLocLogo      := "/ws/images/tcp-brand-cm-port.png"
    Local cHtmlMod      := ""
    Local _nDias  		:= 0
    Local aEmails       := {}
    Default nOpc        := 1
    
    If( nOpc == 1 ) //Inclusao
    
        cHtmlMod      := "\workflow\HTML\WFAPRPAGMANUAL_PT.html"
        _nDias  		:= GetMv("TCP_DIAVEN",.F.,13)

        //send approval workflow
        oProc := TWFProcess():New( "000001","Manual Payment Approval Workflow nº " + ZA0->ZA0_CODIGO )
        oProc:NewTask( "Criando WF de aprovação de Pagamento manual", cHtmlMod )
        oProc:cSubject := "Manual Payment Approval Workflow nº " + ZA0->ZA0_CODIGO

        oHtml := oProc:oHtml
    
    ElseIf( nOpc == 2 .Or. nOpc == 3 ) //Notificacao de rejeicao/aprovacao
        
        aEmails       := StrTokArr( AllTrim( GetMv("TCP_MAILPA") ), ";" )
        cHtmlMod      := "\workflow\HTML\WFRETMANUALPAYMENT.html"
        oMail := TCPMail():New()
        oHtml := TWFHtml():New( cHtmlMod )
    Else
        //Cancelamento
        aEmails       := StrTokArr( AllTrim( GetMv("TCP_MAILPA") ), ";" )
        cHtmlMod      := "\workflow\HTML\WFCANCMANUALPAYMENT.html"
        oMail := TCPMail():New()
        oHtml := TWFHtml():New( cHtmlMod )
    EndIf
        
    If ( valtype(oHtml) != "U" )

        If( nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4 )
            oHtml:ValByName("MSGRETURN",'Your request nº ' + ZA0->ZA0_CODIGO +  ' has been ' + If(nOpc==2, '<font color="green"><strong>APPROVED</strong></font>', If(nOpc==3, '<font color="red"><strong>REJECTED</strong></font>', '<font color="red"><strong>CANCELLED</strong></font>')) + ' on ' + DTOC(dDatabase) +  '.' )
        EndIf

        oHtml:ValByName("EMPRESA", FWArrFilAtu(cEmpAnt,cFilAnt)[SM0_NOMECOM] )
        oHtml:ValByName("CNPJ", Transform( Posicione("SA2",1,xFilial("SA2") + ZA0->ZA0_CLIFOR + ZA0->ZA0_LOJA,"A2_CGC" ) ,PesqPict("SA2","A2_CGC") ) )
        oHtml:ValByName("SOLICITACAO", ZA0->ZA0_CODIGO )
        oHtml:ValByName("DATA_SOLICITACAO", DTOC(ZA0->ZA0_DTSOLI) )
        oHtml:ValByName("FORNECEDOR", Posicione("SA2",1,xFilial("SA2") + ZA0->ZA0_CLIFOR + ZA0->ZA0_LOJA,"A2_NOME" ) + " (" + ZA0->ZA0_CLIFOR + ")" )
        oHtml:ValByName("TITULO", ZA0->ZA0_NUM )
        oHtml:ValByName("EMISSAO", DTOC(ZA0->ZA0_EMISSA) )
        oHtml:ValByName("VENCTO_SOLICITADO", DTOC(ZA0->ZA0_VENCTO) )
        oHtml:ValByName("VENCTO_REAL", Iif(_nDias > 0,"The Due Date will be adjusted to " + Alltrim(Str(_nDias)) + " days after the approval date. (Except for judicial payments)","") )
        oHtml:ValByName("TIPO_TITULO", ZA0->ZA0_TIPO + "-" + FWGetSX5("05" , ZA0->ZA0_TIPO )[1][4] )
        oHtml:ValByName("VALOR", "R$ " + Alltrim(Transform(ZA0->ZA0_VALOR, PesqPict("SE2","E2_VALOR") ) ) )
        oHtml:ValByName("TIPO_ORC", If(ZA0->ZA0_TPORC=="C","CAPEX","OPEX") )
        oHtml:ValByName("MULTA", "R$ " + Alltrim(Transform(ZA0->ZA0_MULTA, "@E 999,999.99" ) ) )
        oHtml:ValByName("JUROS", "R$ " + Alltrim(Transform(ZA0->ZA0_JUROS, "@E 999,999.99" ) ) )
        oHtml:ValByName("OBS_MULTA", Alltrim(ZA0->ZA0_JUSJUR) )
        oHtml:ValByName("OBSERVACAO", Alltrim(ZA0->ZA0_OBS) )

        dbSelectArea('ZA2')
        ZA2->( dbSetOrder(1) )
        ZA2->( dbGoTop() )

        dbSelectArea('ZA3')
        ZA3->( dbSetOrder(1) )
        ZA3->( dbGotop() )

        If ZA2->( MsSeek( xFilial('ZA2') + ZA0->ZA0_CODIGO ) )
            While   !ZA2->(Eof()) .And.;
                    ZA2->ZA2_FILIAL+ZA2->ZA2_CODIGO == xFilial('ZA2')+ZA0->ZA0_CODIGO
                If ZA3->( MsSeek( xFilial('ZA3') + ZA0->ZA0_CODIGO + ZA2->ZA2_NATURE ) )
                    While   !ZA3->(Eof()) .And.; 
                            ZA3->ZA3_FILIAL+ZA3->ZA3_CODIGO+ZA3->ZA3_NATURE == xFilial('ZA3')+ZA0->ZA0_CODIGO+ZA2->ZA2_NATURE
                        aAdd((oHtml:ValByName("it_natureza.1")), Alltrim( Posicione("SED",1,xFilial("SED")+ZA2->ZA2_NATURE,"ED_DESCRIC" ) ) + " (" + Alltrim(ZA2->ZA2_NATURE) + ") " + " / " +;  
                                                                Alltrim( Posicione("CTT",1,xFilial("CTT")+ZA3->ZA3_CC,"CTT_DESC01" ) ) + " (" + Alltrim(ZA3->ZA3_CC) + ")" +; 
                                                                Iif( !Empty( ZA3->ZA3_ITEMCT), " / " + Alltrim( Posicione("CTD",1,xFilial("CTD")+ZA3->ZA3_ITEMCT,"CTD_DESC01" ) ) + " (" + Alltrim(ZA3->ZA3_ITEMCT) + ")" + " " , " " ) +;
                                                                "R$ " + Alltrim(Transform(ZA3->ZA3_VLRRAT, PesqPict("SE2","E2_VALOR") ) ) )
                        ZA3->( dbSkip() )
                    EndDo
                Else
                    aAdd((oHtml:ValByName("it_natureza.1")), Alltrim( Posicione("SED",1,xFilial("SED")+ZA2->ZA2_NATURE,"ED_DESCRIC" ) ) + " (" + Alltrim(ZA2->ZA2_NATURE) + ") " + " / " +;  
                                                            "R$ " + Alltrim(Transform(ZA2->ZA2_VLRNAT, PesqPict("SE2","E2_VALOR") ) ) )
                EndIf
                ZA2->( dbSkip() )
            EndDo
        Else
            cNatCC := Alltrim(Posicione("SED",1,xFilial("SED")+ZA0->ZA0_NATURE,"ED_DESCRIC" ) ) + " (" + Alltrim(ZA0->ZA0_NATURE) + ") " 
            If !Empty(ZA0->ZA0_CC)
                cNatCC += " / " + Alltrim(Posicione("CTT",1,xFilial("CTT") + ZA0->ZA0_CC,"CTT_DESC01" ) ) + " (" + Alltrim(ZA0->ZA0_CC) + ")" 
            EndIf
            cNatCC  += " R$ " + Alltrim(Transform(ZA0->ZA0_VALOR, PesqPict("SE2","E2_VALOR") ) )
            aAdd( (oHtml:ValByName("it_natureza.1")) , cNatCC)
        EndIf
        
        oHtml:ValByName("TOTAL", "R$ " + Alltrim(Transform(ZA0->(ZA0_VALOR+ZA0_MULTA+ZA0_JUROS), PesqPict("SE2","E2_VALOR") ) ) )
        oHtml:ValByName("SOLICITANTE", ZA0->ZA0_NOMSOL )

        vfilial := xfilial('SCR')
        
        BeginSql Alias "QSCRX"
            SELECT SCR.*
            FROM %table:SCR% SCR
            WHERE SCR.CR_FILIAL = %Exp:vfilial%
            AND SCR.CR_NUM = %Exp:ZA0->ZA0_CODIGO%
            AND SCR.CR_TIPO = 'AP'
            AND SCR.%NotDel%
        EndSql
        
        while !QSCRX->(EOF())

            _vStatusW := QSCRX->CR_STATUS
            if _vStatusW == "01"
                _vStatusW := "Waiting for the others levels approvement"
            endif
            if _vStatusW == "02"
                _vStatusW := "Pending"
            endif
            if _vStatusW == "03"
                _vStatusW := "Approved"
            endif
            if _vStatusW == "04"
                _vStatusW := "Blocked"
            endif
            if _vStatusW == "05"
                _vStatusW := "Approved / Blocked by level"
            endif
            if _vStatusW == "06"
                _vStatusW := "Reject"
            endif
            
            AADD((oHtml:ValByName("ap.nivelalcada")),QSCRX->CR_NIVEL)
            AADD((oHtml:ValByName("ap.nomeaprovadorresp")),fGetUsrName(QSCRX->CR_USER))
            AADD((oHtml:ValByName("ap.statusalcada")),_vStatusW)
            AADD((oHtml:ValByName("ap.nomeaprovador")),u_xRetAprv(QSCRX->CR_USERLIB,STOD(QSCRX->CR_DATALIB)))
            AADD((oHtml:ValByName("ap.dataaprocacao")),STOD(QSCRX->CR_DATALIB))
            
            if( nOpc == 4 )
                If( !Empty( cMailAprv := UsrRetMail(QSCRX->CR_USER)) )
                    aAdd(aEmails,cMailAprv) 
                EndIf
            EndIf   

            QSCRX->(dbSkip())
        
        enddo
        
        QSCRX->(dbCloseArea())

        If( nOpc == 1 )

            cUrlAux    := 'ENCODE64( "funcName=u_TCFI02RET" + cHash )'

            cHash   := "&empresa=" + cEmpAnt + "&filial=" + cFilAnt + "&codigo=" + ZA0->ZA0_CODIGO + "&opc=4" + "&aprovador=" + SCR->CR_APROV + "&horas=" + Alltrim(SubS(SCR->CR_XHORAS,1,4))
            cUrl    := &(cUrlAux)

            oHtml:ValByName("proc_link1", cHttpServer + "/pp/u_tcpwfhttpret.apl?" + cUrl )

            cHash   := "&empresa=" + cEmpAnt + "&filial=" + cFilAnt + "&codigo=" + ZA0->ZA0_CODIGO + "&opc=7" + "&aprovador=" + SCR->CR_APROV + "&horas=" + Alltrim(SubS(SCR->CR_XHORAS,1,4))
            cUrl    := &(cUrlAux)
            
            oHtml:ValByName("proc_link3", cHttpServer + "/pp/u_tcpwfhttpret.apl?" + cUrl )

            attachFiles(@oProc)

            oProc:cTo := UsrRetMail(SCR->CR_USER)

            oProc:Start()
            oProc:Finish()
            WFSendMail()
            FreeObj(oProc)

        Else
            
            cErro := ""

            //Salvo o anexo na pasta do GED
            cFileName := ZA0->ZA0_FILIAL + ZA0->ZA0_CODIGO + ".htm"
            nPos 	  := RAt(If(IsSrvUnix(), "/", "\"), cFileName)
            cAnexoGrv := Upper(SubStr( cFileName , nPos+1 ))
            nCount    := 0
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Busca por um nome de arquivo nao utilizado, incrementando o arquivo        ³
            //³com um sequencial ao final do nome, exemplo: arquivo(1).txt, arquivo(2).txt³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            DbSelectArea("ACB")
            ACB->(DbSetOrder(2)) //ACB_FILIAL+ACB_OBJETO

            While DbSeek(xFilial("ACB") + AllTrim(SubStr( cAnexoGrv , nPos+1 )))
                nPos2		:= Rat(".",cAnexoGrv)
                cAnexoGrv	:= SubStr(cAnexoGrv,1,nPos2-1)+"("+cValToChar(nCount)+")"+SubStr(cAnexoGrv,nPos2,Len(cAnexoGrv))
                nCount++
            End
            
            oHtml:SaveFile(MsDocPath() + "\" + cAnexoGrv)

            cCodObj := StaticCall(TCCO04KM,proxAcb) //GetSxeNum("ACB","ACB_CODOBJ")
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Inclui registro no banco de conhecimento³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            RecLock("ACB",.T.)
            ACB->ACB_FILIAL := xFilial("ACB")
            ACB->ACB_CODOBJ := cCodObj
            ACB->ACB_OBJETO	:= Upper(cAnexoGrv)
            ACB->ACB_DESCRI	:= Upper(SubStr(cFileName,1,Rat(".",cAnexoGrv)-1))
            MsUnLock()

            ConfirmSx8()

            cEntidade := "ZA0"

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Inclui amarração entre registro do banco e entidade³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cUnico := Posicione('SX2',1,cEntidade,'X2_UNICO')
            
            RecLock("AC9",.T.)
            AC9->AC9_FILIAL	:= xFilial("AC9")
            AC9->AC9_FILENT	:= xFilial("SC7")
            AC9->AC9_ENTIDA	:= cEntidade
            AC9->AC9_CODENT	:= (cEntidade)->(&(cUnico))
            AC9->AC9_CODOBJ	:= ACB->ACB_CODOBJ
            MsUnLock()

            cUserID       := StaticCall(TCFIA002,fRetCodSol,ZA0->ZA0_CODSOL,2)

            If !Empty(cUserID)
               aAdd(aEmails,UsrRetMail(cUserID))
            Endif

            oMail:SendMail( aEmails ,;
            "Return Manual Payment Approval Workflow request nº " + ZA0->ZA0_CODIGO,;
            oHtml:HtmlCode(),;
            @cErro,;
            {})

        EndIf
    EndIf
    
    FreeObj(oHtml)

Return( Nil )

/*/{Protheus.doc} attachFiles
Função responsavel por buscar os arquivos anexados a solicitação no GED.
@type function
@version 1.0
@author Kaique Mathias
@since 6/23/2020
@param oProc, object, param_description
@return return_type, return_description
/*/

Static Function attachFiles(oProc)

    Local cAliasAx  := GetNextAlias()
    Local cChaveAne := "%'ZA0" + xFilial("ZA0")+ZA0->ZA0_CODIGO + "'%"
    Local cDirDoc   := MsDocPath()

    BeginSQL Alias cAliasAx
	 
    SELECT ACB_OBJETO
    FROM %TABLE:AC9% AC9
    INNER JOIN %TABLE:ACB% ACB ON ACB_FILIAL = AC9_FILIAL AND AC9_CODOBJ = ACB_CODOBJ AND ACB.%NotDel% 
    WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChaveAne%)

    EndSQL

    WHILE !(cAliasAx)->(Eof())
        cFile := cDirDoc + "\" + alltrim((cAliasAx)->ACB_OBJETO)
        oProc:AttachFile(cFile)
        (cAliasAx)->(dbSkip())
    EndDo

Return( Nil )

Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))
