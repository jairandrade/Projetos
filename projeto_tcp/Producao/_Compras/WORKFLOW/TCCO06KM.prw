#include "totvs.ch"

/*/{Protheus.doc} TCCO06KM
Função responsavel por realizar o envio do email com a relação de produtos cadastrados no dia
@type  Function
@author user
@since 20/08/2020
@version version
/*/

User Function TCCO06KM( aPars )
    
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

    TCO06RUN()

    If lPrepare
        RpcClearEnv()
    EndIf

Return( Nil )

/*/{Protheus.doc} TCO06RUN
Função responsavel por processar o envio do email
@type  Function
@author user
@since 20/08/2020
@version version
/*/
Static Function TCO06RUN()

    Local cTipoPrd  := ""
    Local cErro     := ""
    Local aEmails   := StrTokArr( AllTrim( GetMV("TCP_ALCADP") ), ";" )
    Local oMail,oHtml

    BeginSql Alias "TMPSB1"
        SELECT  B1_COD,
                B1_DESC, 
                SUBSTRING(B1_USERLGI, 3, 1) + 
                SUBSTRING(B1_USERLGI, 7, 1) + 
                SUBSTRING(B1_USERLGI, 11,1) + 
                SUBSTRING(B1_USERLGI, 15,1) + 
                SUBSTRING(B1_USERLGI, 2, 1) + 
                SUBSTRING(B1_USERLGI, 6, 1) + 
                SUBSTRING(B1_USERLGI, 10,1) +
                SUBSTRING(B1_USERLGI, 14,1) + 
                SUBSTRING(B1_USERLGI, 1, 1) +
                SUBSTRING(B1_USERLGI, 5, 1) + 
                SUBSTRING(B1_USERLGI, 9, 1) +
                SUBSTRING(B1_USERLGI, 13,1) + 
                SUBSTRING(B1_USERLGI, 17,1) +
                SUBSTRING(B1_USERLGI, 4, 1) + 
                SUBSTRING(B1_USERLGI, 8, 1) AS USUARIO_CRIACAO,
                SA5.A5_FORNECE,
                SA5.A5_LOJA
        FROM %table:SB1% SB1
        INNER JOIN %table:SA5% SA5 ON SA5.A5_FILIAL = %xFilial:SA5% And
                                     SA5.A5_PRODUTO = SB1.B1_COD And
                                     SA5.%NotDel%
        WHERE   SB1.B1_FILIAL = %xFilial:SB1% And
                SB1.B1_XQUIMI = 'S' And
                SB1.%NotDel%
        ORDER BY SB1.B1_COD,SA5.A5_FORNECE,SA5.A5_LOJA
    EndSql

    //MemoWrite("C:\temp\prodquim.txt",getlastquery()[2])

    If !( TMPSB1->( Eof() ) )
        
        oMail := TCPMail():New()
        oHtml := TWFHtml():New("\WORKFLOW\HTML\TCCO05KM.html")
        lFornHml := .F.
        cCodPrd := ""
        cDescric := ""
        cUserInc := ""
        lSendMail := .F.
        If ( valtype(oHtml) != "U" )
            dbSelectArea("SA2")
            SA2->( dbSetOrder(1) )
            
            While !(TMPSB1->(Eof()))    
                
                SA2->( MSSeek( xFilial("SA2") + TMPSB1->A5_FORNECE + TMPSB1->A5_LOJA ) )    
                
                If( !Empty(cCodPrd) .And. cCodPrd <> TMPSB1->B1_COD .And. !lFornHml )
                    cTipoPrd := POSICIONE("SB1",1,xFilial("SB1")+cCodPrd,"B1_TIPO")
                    cTipoPrd := POSICIONE("SX5",1,xFilial("SX5")+"02"+cTipoPrd,"X5_DESCRI")

                    aAdd((oHtml:ValByName("it.item1")),cCodPrd)
                    aAdd((oHtml:ValByName("it.item2")),cDescric)
                    aAdd((oHtml:ValByName("it.item3")),cTipoPrd)
                    aAdd((oHtml:ValByName("it.item4")),cUserInc)
                    lFornHml := .F.
                    lSendMail := .T.
                EndIf
                
                cCodPrd := TMPSB1->B1_COD
                cDescric:= TMPSB1->B1_DESC
                cUserInc:= getUserName(TMPSB1->USUARIO_CRIACAO)
                
                If( SA2->A2_XVLDHOM > Date() .AND. !Empty(SA2->A2_XVLDHOM) )
                    lFornHml := .T.
                ElseIf Empty(SA2->A2_XVLDHOM)
                    lFornHml := .F.
                EndIf
                
                TMPSB1->( dbSkip() )
            EndDo
            If( !Empty(cCodPrd) .And. cCodPrd <> TMPSB1->B1_COD .And. !lFornHml )
                cTipoPrd := POSICIONE("SB1",1,xFilial("SB1")+cCodPrd,"B1_TIPO")
                cTipoPrd := POSICIONE("SX5",1,xFilial("SX5")+"02"+cTipoPrd,"X5_DESCRI")
                aAdd((oHtml:ValByName("it.item1")),cCodPrd)
                aAdd((oHtml:ValByName("it.item2")),cDescric)
                aAdd((oHtml:ValByName("it.item3")),cTipoPrd)
                aAdd((oHtml:ValByName("it.item4")),cUserInc)
                lFornHml := .F.
                lSendMail := .T.
            EndIf
            If( lSendMail )
                oMail:SendMail( aEmails ,;
                ":: Notificação de Produtos Químicos Homologação Vencida ou não Homologado",;
                oHtml:HtmlCode(),;
                @cErro,;
                {})
            Else
                MsgInfo('Não foram encontrados produtos aptos a serem enviados.')
            EndIf
        EndIf
        FreeObj(oMail)
        FreeObj(oHtml)
    EndIf

    TMPSB1->( dbCloseArea() )

Return( Nil )

/*/{Protheus.doc} getUserName
Retorna nome usuário
@type  Function
@author user
@since 20/08/2020
@version 1.0
/*/
Static Function getUserName(cUsrLgi)
    Local _cCodUsu := Subs( cUsrLgi, 3, 6)
return FwGetUserName(_cCodUsu)
