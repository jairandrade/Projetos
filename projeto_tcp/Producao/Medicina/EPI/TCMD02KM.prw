#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCMD02KM
Função responsável pelo disparo do email para envio do workflow de 
liberação de EPI.
@author  Kaique Sousa
@since   21/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCMD02KM(cFornece,cLoja,cCODEPI,cNumCap,cData,cHora,cQtdEnt,cJustif)

    Local aArea         := GetArea()
    Local cHttpServer   := "http://" + Alltrim(GetMV("MV_ENDWF")) + ":" + AllTrim(GetMv("TCP_PORTWF"))
    //Local cLogo         := cHttpServer + "/ws/images/tcp-brand-cm-port.png"
    Local cRespMDT      := GetMV('TCP_RESMDT')
    Local cErro         := ""
    Local lRetorno      := .F.
    Local aEmails       := {}
    Local cCodApro      := ""
    Local i             := 0
    Local cUserFullName := UsrFullName(__cUserId)
    Private oMail,oHtml := Nil

    If !Empty(cRespMDT)
        aEmails := STRTOKARR( cRespMDT, ";" )
    EndIf

    If ( Len(aEmails) > 0 )

        For i := 1 to len(aEmails)

            If ( !Empty(aEmails[i]) )

                PswOrder(4) //E-mail
                If ( PswSeek(Alltrim(aEmails[i])) )
                    cCodApro := PswRet()[1][1]
                EndIf

                If !Empty(cCodApro)

                    oProc := TWFProcess():New("000001","Aprovação EPI de Funcionários")
                    oProc:NewTask("Criando WF de aprovação EPI", "\workflow\HTML\WFAPREPI01.html" )
                    oProc:cSubject := "Aprovação EPI de Funcionários"

                    oHtml := oProc:oHtml

                    If valtype(oHtml) != "U"

                        oHtml:ValByName("cRequisitante",cUserFullName)
                        oHtml:ValByName("cMatricula",SRA->RA_MAT + ' - ' + SRA->RA_NOME )
                        oHtml:ValByName("cData",DTOC(dDataBase))
                        oHtml:ValByName("cAdmissao",DTOC(SRA->RA_ADMISSA))
                        oHtml:ValByName("cCentroCusto",Posicione('CTT',1,xFilial('CTT')+SRA->RA_CC,"CTT_DESC01"))
                        oHtml:ValByName("cFuncao",Posicione('SRJ',1,xFilial('SRJ')+SRA->RA_CODFUNC,"RJ_DESC"))
                        oHtml:ValByName("cJustificativa",cJustif)

                        dbSelectArea('SB1')
                        SB1->(dbSetOrder(1))
                        SB1->(MSSeek(xFilial('SB1')+cCODEPI))

                        aAdd((oHtml:ValByName("it.codigo")), cCODEPI )
                        aAdd((oHtml:ValByName("it.descricao")),SB1->B1_DESC )
                        aAdd((oHtml:ValByName("it.dtultsol")), fGetUltSol(cCodEPI) )
                        aAdd((oHtml:ValByName("it.quantidade")),Alltrim(cQtdEnt))

                        cHash := Encode64( cEmpAnt + cFilAnt + cFornece + cLoja + cCodEPI + cNumCap + M->RA_MAT + DTOS(CTOD(cData)) + Alltrim(StrTran(cHora,":","")) + cCodApro )

                        oHtml:ValByName("clink", cHttpServer + '/pp/U_WMDT001A.apw?keyvalue='+cHash)
                        oHtml:ValByName("clink2",cHttpServer + '/pp/U_WMDT001R.apw?keyvalue='+cHash)
                        oProc:cTo := Alltrim(aEmails[i])

                        oProc:Start()
                        oProc:Finish()

                        WFSendMail()

                    EndIf

                    FreeObj(oProc)
                    FreeObj(oHtml)

                EndIf

            EndIf

        Next i

    EndIf

    RestArea(aArea)

Return( lRetorno )

/*/{Protheus.doc} TCMD01Lib
Função responsavel por realizar a liberação do EPI
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/7/2020
@param nRecTNF, numeric, param_description
@param cCodApr, character, param_description
@return return_type, return_description
/*/

User Function TCMD01Lib(cFornece,cLoja,cCodEPI,cNumCap,cMatric,cData,cHora,cCodApr)

    Local lRet      := .F.
    Local cMessage  := ""
    Local nTamCap   := TamSX3("TNF_NUMCAP")[1]

    dbSelectArea("TNF")
    TNF->( dbSetOrder(1) )

    If TNF->( DBSeek( xFilial("TNF") + cFornece + cLoja + cCODEPI + PadR(cNumCap,nTamCap,"") + cMatric + cData + Transform(cHora,"@R 99:99") ) )
        If Empty(TNF->TNF_YNUMRE)
            //Valido saldo do produto antes de prosseguir
            If QtdComp(SaldoSBF(TNF->TNF_LOCAL,TNF->TNF_ENDLOC,TNF->TNF_CODEPI)) < TNF->TNF_QTDENT
                cMessage := "O produto não tem saldo Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente. "
                fDelSA() //Excluo a requisicao
            Else
                cNumReq := U_TCMD03KM(TNF->TNF_DTENTR,TNF->TNF_CODEPI,TNF->TNF_LOCAL,,TNF->TNF_QTDENT,3,TNF->TNF_MAT)
                If !Empty(cNumReq)
                    lRet := .T.
                    If RecLock('TNF',.F.)
                        TNF->TNF_YNUMRE := cNumReq
                        TNF->TNF_XUSLIB := UsrRetName(cCodApr)
                        TNF->TNF_XDTLIB := dDataBase
                        TNF->TNF_XSTATU := '03'
                        TNF->(MsUnlock())
                    EndIf
                    cMessage := "Aprovação realizada com sucesso."
                EndIf
            EndIf
        Else
            cMessage := "Aprovação ja realizada anteriormente."
        EndIf
    else
        cMessage := "EPI x Func. não encontrado."
    EndIf

Return({lRet,cMessage})

/*/{Protheus.doc} TCMD01Rej
Função responsavel por realizar a rejeição do EPI
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/7/2020
@param nRecTNF, numeric, param_description
@param cCodApr, character, param_description
@return return_type, return_description
/*/

User Function TCMD01Rej(cFornece,cLoja,cCodEPI,cNumCap,cMatric,cData,cHora,cCodApr)

    Local lRet      := .F.
    Local cMessage  := ""
    Local nTamCap   := TamSX3("TNF_NUMCAP")[1]

    dbSelectArea("TNF")
    TNF->( dbSetOrder(1) )

    If TNF->( DBSeek( xFilial("TNF") + cFornece + cLoja + cCODEPI + PadR(cNumCap,nTamCap,"") + cMatric + cData + Transform(cHora,"@R 99:99") ) )
        If Empty(TNF->TNF_YNUMRE)
            If RecLock('TNF',.F.)
                TNF->TNF_XUSLIB := UsrRetName(cCodApr)
                TNF->TNF_XDTLIB := dDataBase
                TNF->TNF_XSTATU := '06'
                TNF->(MsUnlock())
            EndIf
            lRet := fDelSA()
            cMessage := "Rejeição realizada com sucesso."
        else
            cMessage := "Aprovação ja realizada anteriormente."
        endif
    Else
        cMessage := "EPI x Func. não encontrado."
    EndIf

Return({lRet,cMessage})

/*/{Protheus.doc} fDelSA
Função responsavel por realizar a exclusão da solicitação ao armazem
@type function
@version 12.1.25
@author kaiquesousa
@since 5/7/2020
@param cMessage, character, param_description
@return return_type, return_description
/*/

Static Function fDelSA()

    Local lRet          := .F.
    Local cFornece      := TNF->TNF_FORNEC
    Local cLoja         := TNF->TNF_LOJA
    Local cNumCAP       := TNF->TNF_NUMCAP
    Local cMatric       := TNF->TNF_MAT
    Local cData         := DTOS(TNF->TNF_DTENTR)
    Local cHora         := TNF->TNF_HRENTR
    Local cNumSA        := TNF->TNF_NUMSA
    Local cItemSA       := TNF->TNF_ITEMSA
    Local cCODEPI       := TNF->TNF_CODEPI
    Local nTamCap       := TamSX3("TNF_NUMCAP")[1]
    Private lMSHelpAuto := .F.
    Private lMsErroAuto := .F.

    dbSelectArea("SCP")
    SCP->(dbSetOrder(1))

    If SCP->( dbSeek(xFilial("SCP") + cNumSA + cItemSA ) )

        If( SCP->CP_PRODUTO == cCODEPI )

            //Zera array para excluir um registro por vez
            aEpiSA := {}

            //Adiciona EPI's no array
            aAdd( aEpiSA, { cCODEPI, , TNF->TNF_QTDENT, , , SCP->CP_EMISSAO, , , , , cNumSA, cItemSA } )

            // Função de Execução automatica
            lRet := MDT695AUTO( aEpiSA, 5 )

            //Verifico se de fato foi excluido
            If( lRet )
                dbSelectArea( "SCP" )
                dbSetOrder( 1 )
                lRet := ( dbSeek( xFilial( "SCP" ) + cNumSA + cItemSA ) )
                //Se tiver sido excluido verifico na TNF
                If( !lRet )
                    dbSelectArea("TNF")
                    TNF->( dbSetOrder(1) )

                    If TNF->( DBSeek( xFilial("TNF") + cFornece + cLoja + cCODEPI + PadR(cNumCap,nTamCap,"") + cMatric + cData + Transform(cHora,"@R 99:99") ) )
                        If RecLock( "TNF" , .F. , .T. )
                            TNF->(dbDelete())
                            TNF->( MsUnLock() )
                        EndIf
                    EndIf
                    lRet := .T.
                Else
                    If RecLock( "SCP" , .F. , .T. )
                        SCP->(dbDelete())
                        SCP->( MsUnLock() )
                    EndIf
                    //Se tiver excluido vejo na TNF
                    dbSelectArea("TNF")
                    TNF->( dbSetOrder(1) )

                    If TNF->( DBSeek( xFilial("TNF") + cFornece + cLoja + cCODEPI + PadR(cNumCap,nTamCap,"") + cMatric + cData + Transform(cHora,"@R 99:99") ) )
                        If RecLock( "TNF" , .F. , .T. )
                            TNF->(dbDelete())
                            TNF->( MsUnLock() )
                        EndIf
                    EndIf
                    lRet := .T.
                EndIf
            Else
                dbSelectArea( "SCP" )
                SCP->( dbSetOrder( 1 ) )

                If SCP->( dbSeek( xFilial( "SCP" ) + cNumSA + cItemSA ) )
                    If RecLock( "SCP" , .F. , .T. )
                        SCP->(dbDelete())
                        SCP->( MsUnLock() )
                    EndIf
                EndIf

                //se nao for Excluido vejo so na TNF
                dbSelectArea("TNF")
                TNF->( dbSetOrder(1) )

                If TNF->( DBSeek( xFilial("TNF") + cFornece + cLoja + cCODEPI + PadR(cNumCap,nTamCap,"") + cMatric + cData + Transform(cHora,"@R 99:99") ) )
                    If RecLock( "TNF" , .F. , .T. )
                        TNF->(dbDelete())
                        TNF->( MsUnLock() )
                    EndIf
                EndIf
                lRet := .T.
            EndIf
        EndIf
    EndIf

Return( lRet )

/*/{Protheus.doc} fGetUltSol
Retorna a data da ultima vez que foi entregue o EPI
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/3/2020
@return character, cUltSol
/*/

Static Function fGetUltSol(cCODEPI)

    Local cUltSol   := ""
    Local cAliasZDW := GetNextAlias()

    //Busco os Epi's ja entregue
    BeginSql Alias cAliasZDW
        SELECT TOP 1 SC2.C2_DATRF
        FROM %Table:ZDW% ZDW,%Table:SC2% SC2
        WHERE   ZDW.ZDW_FILIAL = %xFilial:ZDW% AND
                ZDW.ZDW_REQUIS = %exp:SRA->RA_MAT% AND
                ZDW.ZDW_EPI = %exp:cCODEPI% AND
                SC2.C2_FILIAL = ZDW.ZDW_FILIAL AND
                SC2.C2_NUM = SUBSTRING(ZDW.ZDW_OP,1,6) AND
                SC2.C2_DATRF <> ' ' AND
                ZDW.%NotDel%
        ORDER BY C2_DATRF DESC
    EndSql

    If( (cAliasZDW)->( !Eof() ) )
        cUltSol := DTOC( STOD( (cAliasZDW)->C2_DATRF ) )
    EndIf

    (cAliasZDW)->(dbCloseArea())

Return( cUltSol )


