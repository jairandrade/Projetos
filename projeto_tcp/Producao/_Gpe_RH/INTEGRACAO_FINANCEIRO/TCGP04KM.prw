#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} TCGP04KM
Funcao responsavel por realizar a gravação na rotina de solicitação de pagamentos.
@type function
@version 1.0
@author Kaique Mathias
@since 7/9/2020
@return return_type, return_description
/*/

User Function TCGP04KM()
    
    Local lReturn   := .T.
    Local cLoja     := If(Empty( RC1->RC1_LOJA) , "00", RC1->RC1_LOJA  )
    Local cCodSol   := ""
    Local nQtdRat   := 1

    If( Type("__cChaveAnexo") == "U" )
        Public __cChaveAnexo
    EndIf

    oMdlZA0 := FWLoadModel('TCFIA002')

    oMdlZA0:SetOperation(3)

    If( oMdlZA0:Activate() )

        aArea := GetArea()
        DbSelectArea("SE2")
        DbSetOrder(6) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM...
        cNumTit := RC1->RC1_NUMTIT

        While SE2->( MsSeek( xFilial( "SE2" ) + RC1->RC1_FORNEC + cLoja + "GPE" + cNumTit ) )
            cFilBkp := cFilAnt
            cFilAnt := RC1->RC1_FILTIT
            cNumTit := GetSx8Num("RC1","RC1_NUMTIT",,RetOrdem( "RC1" , "RC1_FILIAL+RC1_NUMTIT" ))
            cFilAnt := cFilBkp
        EndDo

        RestArea(aArea)

        cCodSol := GETSXENUM("ZA0","ZA0_CODIGO")

        oMdlZA0:SetValue("ZA0MASTER","ZA0_CODIGO",cCodSol)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_PREFIX",RC1->RC1_PREFIX)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_NUM",cNumTit)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_PARCEL",RC1->RC1_PARC)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_TIPO",RC1->RC1_TIPO)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_CLIFOR",RC1->RC1_FORNEC)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_LOJA",cLoja)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_EMISSA",RC1->RC1_EMISSA)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_VENCTO",RC1->RC1_VENCTO)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_VENCRE",RC1->RC1_VENREA)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_NATURE",RC1->RC1_NATURE)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_TPORC","C")
        oMdlZA0:SetValue("ZA0MASTER","ZA0_VALOR",RC1->RC1_VALOR)
        oMdlZA0:SetValue("ZA0MASTER","ZA0_OBS","GERADO AUTOMATICAMENTE PELA ROTINA GESTÃO DE PESSOAL")
        oMdlZA0:SetValue("ZA0MASTER","ZA0_HIST",STATICCALL(GP670CPO,GETHIST))
        oMdlZA0:SetValue("ZA0MASTER","ZA0_ORIGEM","GPEM670")

        If( !Empty( RC1->RC1_CODRET ) )
            oMdlZA0:SetValue("ZA0MASTER","ZA0_CODREC",If(Empty( RC1->RC1_CODRET) , "", RC1->RC1_CODRET  ))
        EndIf

        If( RC1->RC1_CODTIT $ "001|002|003" )
            oMdlZA0:LoadValue("ZA2DETAIL","ZA2_CODIGO",cCodSol)
            oMdlZA0:SetValue("ZA2DETAIL","ZA2_NATURE",RC1->RC1_NATURE)
            oMdlZA0:LoadValue("ZA2DETAIL","ZA2_PERC",100)
            oMdlZA0:LoadValue("ZA2DETAIL","ZA2_VLRNAT",RC1->RC1_VALOR)
            DbSelectArea("ZZG")
            ZZG->( DbSetOrder(1) )
            ZZG->( DbGoTop() )
            ZZG->( DbSeek(RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC,.f.) )
            While !Eof() .and. ZZG->ZZG_FILIAL+ZZG->ZZG_PREFIX+ZZG->ZZG_NUMTIT+ZZG->ZZG_PARC==RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC
                If(nQtdRat > 1 )
                    oMdlZA0:GetModel('ZA3DETAIL'):AddLine()
                EndIf
                oMdlZA0:LoadValue("ZA3DETAIL","ZA3_CODIGO",cCodSol)
                oMdlZA0:SetValue("ZA3DETAIL","ZA3_NATURE",RC1->RC1_NATURE)
                oMdlZA0:SetValue("ZA3DETAIL","ZA3_CC",ZZG->ZZG_CC)
                oMdlZA0:LoadValue("ZA3DETAIL","ZA3_PERC",((ZZG->ZZG_VALOR / RC1->RC1_VALOR) * 100))
                oMdlZA0:LoadValue("ZA3DETAIL","ZA3_VLRRAT",ZZG->ZZG_VALOR)
                nQtdRat++
                ZZG->( dbSkip() )
            EndDo*/
        EndIf

        If( oMdlZA0:VldData() )
            oMdlZA0:CommitData()
            ConfirmSX8()
        Else
            lReturn := .F.
            RollbackSX8()
            aErro := oMdlZA0:GetErrorMessage()
            AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
            AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
            AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
            AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
            MostraErro()
        EndIf
    Else
        lReturn := .F.
        aErro := oMdlZA0:GetErrorMessage()
        AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
        AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
        AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
        AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
        MostraErro()
    EndIf

    If( lReturn )
        lReturn := .F.
        dbSelectArea( "RC1" )
        If RecLock("RC1",.F.,.F.)
            RC1->RC1_INTEGR := "1"
            MsUnlock()
        EndIf
    Else
        dbSelectArea( "RC1" )
        If RecLock("RC1",.F.,.F.)
            RC1->RC1_INTEGR := "0"
            MsUnlock()
        EndIf
    EndIf

Return( lReturn )
