#include "protheus.ch"

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TCCOA01
//Monta a tela de log de aprovação
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type User function
/*/
// -------------------------------------------------------------------------------------
              
User Function TCCOA01(cNumDoc,cTipoDoc,cCodUser,cFuncWf)

    Local aArea			:= GetArea()
    Local cHelpApv		:= OemToAnsi("Este documento nao possui controle de aprovacao ou deve ser aprovado pelo controle de alçadas.")
    Local cComprador	:= ""
    Local cSituaca  	:= ""
    Local cStatus		:= "Documento aprovado"
    Local cTitle		:= ""
    Local cTitDoc		:= ""
    Local cAddHeader	:= ""
    Local nX   			:= 0
    Local oDlg			:= NIL
    Local oGet			:= NIL
    Local oBold			:= NIL
    Local cQuery   		:= ""
    Local aStruSCR 		:= SCR->(dbStruct())
    Local cFilSCR 		:= ""
    Local nI            := 0
    Local aFields       := FWSX3Util():GetAllFields("SCR",.T.)
    Default cFuncWf     := ""             
    cFilSCR := xFilial("SCR")

    Private aCols := {}
    Private aHeader := {}
    Private N := 1
    Private cAliasSCR	:= GetNextAlias()

    Default nOpcx       := 2

    dbSelectArea("SCR")
    
    //Willian Kaneta - Tratamento titulos Objetos conforme tipo Documento
    If cTipoDoc == "AP"
        cTitle  	:= OemToAnsi("Aprovacao da Solicitação de Pagamento")
        cTitDoc 	:= OemToAnsi("Solicitação")
        cHelpApv	:= OemToAnsi("Este pedido nao possui controle de aprovacao.")
        cComprador	:= UsrRetName(cCodUser)
    ElseIf cTipoDoc == "LC"
        cTitle  	:= OemToAnsi("Aprovacao Pré-Lançamento Contábil")
        cTitDoc 	:= OemToAnsi("Documento")
        cHelpApv	:= OemToAnsi("Este lancamento nao possui controle de aprovacao.")
        cComprador	:= cCodUser
    ELSEIf cTipoDoc == "PC"
        cTitle  	:= OemToAnsi("Aprovacao de Pedido de Compra")
        cTitDoc 	:= OemToAnsi("Pedido")
        cHelpApv	:= OemToAnsi("Este pedido nao possui controle de aprovacao.")
        cComprador	:= UsrRetName(cCodUser)
    EndIf

    If !Empty(cNumDoc)
        
        aHeader:= {}
        aCols  := {}
        
        For nI := 1 to len(aFields)
            IF AllTrim(aFields[nI])$"CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
                AAdd(aHeader, {FwSX3Util():GetDescription(aFields[nI]),;
                                        aFields[nI],;
                                        X3PICTURE(aFields[nI]),; 
                                        TamSX3(aFields[nI])[1],;
                                        TamSX3(aFields[nI])[2],;
                                        GetSx3Cache(aFields[nI], "X3_VALID"),;
                                        GetSx3Cache(aFields[nI], "X3_USADO"),;
                                        FwSX3Util():GetFieldType(aFields[nI]),;
                                        X3F3(aFields[nI]),;
                                        GetSx3Cache(aFields[nI], "X3_CONTEXT"),;
                                        X3CBOX(aFields[nI]),;
                                        GetSx3Cache(aFields[nI], "X3_RELACAO")})    

                If AllTrim(aFields[nI]) == "CR_NIVEL"
                    AADD(aHeader,{ OemToAnsi("Aprovador Responsável"),"bCR_NOME",   "",15,0,"","","C","",""} )
                    AADD(aHeader,{ OemToAnsi("Situação"),"bCR_SITUACA","",20,0,"","","C","",""} )
                    AADD(aHeader,{ OemToAnsi("Avaliado por"),"bCR_NOMELIB","",15,0,"","","C","",""} )
                EndIf

                If AllTrim(aFields[nI]) == "CR_DATALIB"
                    AADD(aHeader,{ OemToAnsi("Grupo"),"bCR_GRUPO","",6,0,"","","C","",""} )
                EndIf

            Endif

        Next nI

        ADHeadRec("SCR",aHeader)

        cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
        cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
        cQuery    += "SCR.CR_NUM = '"+Padr(cNumDoc,Len(SCR->CR_NUM))+"' AND "
        cQuery    += "SCR.CR_TIPO = "+"'"+cTipoDoc+"'"
        cQuery    += " AND SCR.D_E_L_E_T_=' ' "
        cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))
        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

        For nX := 1 To Len(aStruSCR)
            If aStruSCR[nX][2]<>"C"
                TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
            EndIf
        Next nX

        While !(cAliasSCR)->(Eof())
            aAdd(aCols,Array(Len(aHeader)+1))

            For nX := 1 to Len(aHeader)
                If IsHeadRec(aHeader[nX][2])
                    aTail(aCols)[nX] := (cAliasSCR)->SCRRECNO
                ElseIf IsHeadAlias(aHeader[nX][2])
                    aTail(aCols)[nX] := "SCR"
                ElseIf aHeader[nX][02] == "bCR_NOME"
                    aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USER)
                ElseIf aHeader[nX][02] == "bCR_GRUPO"
                    aTail(aCols)[nX] := (cAliasSCR)->CR_GRUPO
                ElseIf aHeader[nX][02] == "bCR_SITUACA"
                    Do Case
                    Case (cAliasSCR)->CR_STATUS == "01"
                        cSituaca := OemToAnsi("Pendente em níveis anteriores")
                        If cStatus == "Documento aprovado"
                            cStatus := "Aguardando liberação(ões)"
                        EndIf
                    Case (cAliasSCR)->CR_STATUS == "02"
                        cSituaca := OemToAnsi("Pendente")
                        If cStatus == "Documento aprovado"
                            cStatus := "Aguardando liberação(ões)"
                        EndIf
                    Case (cAliasSCR)->CR_STATUS == "03"
                        cSituaca := OemToAnsi("Aprovado")
                    Case (cAliasSCR)->CR_STATUS == "04"
                        cSituaca := OemToAnsi("Bloqueado")
                        If cStatus # "Documento aprovado"
                            cStatus := "Documento bloqueado"
                        EndIf
                    Case (cAliasSCR)->CR_STATUS == "05"
                        cSituaca := OemToAnsi("Aprovado/rejeitado pelo nível")
                    Case (cAliasSCR)->CR_STATUS == "06"
                        cSituaca := "Rejeitado"
                        If cStatus # "Documento rejeitado"
                            cStatus := "Documento rejeitado"
                        EndIf
                    EndCase
                    aTail(aCols)[nX] := cSituaca
                ElseIf aHeader[nX][02] == "bCR_NOMELIB"
                    aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
                ElseIf Alltrim(aHeader[nX][02]) == "CR_OBS"
                    SCR->(dbGoto((cAliasSCR)->SCRRECNO))
                    aTail(aCols)[nX] := SCR->CR_OBS
                ElseIf ( aHeader[nX][10] != "V")
                    aTail(aCols)[nX] := FieldGet(FieldPos(aHeader[nX][2]))
                EndIf
            Next nX
            aTail(aCols)[Len(aHeader)+1] := .F.

            (cAliasSCR)->(dbSkip())
        EndDo
        //Willian Kaneta
        If cTipoDoc == "LC"
            cNumDoc := SUBSTR(cNumDoc,18,6)    
        EndIf

        If !Empty(aCols)
            n:=	 IIF(n > Len(aCols), Len(aCols), n)
            DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
            DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL
            @ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
            @ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009
            @ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 150,009 OF oDlg FONT oBold
            @ 015,095 SAY OemToAnsi("Solicitante") OF oDlg PIXEL SIZE 045,009 FONT oBold
            @ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
            @ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
            @ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
            
            If !Empty(cFuncWf)
                @ 132,165 BUTTON 'Reenviar p/ Aprov.' SIZE 035 ,010  FONT oDlg:oFont ACTION (&cFuncWf,oDlg:End()) OF oDlg PIXEL
            EndIf
            
            @ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL
            oGet:= MSGetDados():New(038,003,120,250,2,,,"")
            oGet:Refresh()
            @ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
            ACTIVATE MSDIALOG oDlg CENTERED
        Else
            Aviso("Atencao",cHelpApv,{"Voltar"}) 
        EndIf

        (cAliasSCR)->(dbCloseArea())

    Else
        Aviso("Atencao",cHelpApv,{"Voltar"})
    EndIf

    RestArea(aArea)
Return( NIL )