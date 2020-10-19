#include 'protheus.ch'
#include "Totvs.ch"
#include "Rwmake.ch"

/*                                                                                                                                                                               
Programa : TC06C010 
Autor    : ITUPSUL
Data     : 08/06/2019                                                                                                                                                  
Desc.    : Consulta de Motivo de Negociação
Uso      : TCP
*/
User Function TC06C010()
    Local aSize  := MsAdvSize()
    Private oGrid          := Nil
    Private aGrid          := {}

    Private cCadastro         := "Consulta Histórico de Negociação"

    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,,oMainWnd,.T.)

    aObjects := {}
    AAdd( aObjects, {  0,       65, .T., .F. } )
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    DbSelectArea("ZZR")

    aPosObj := MsObjSize( aInfo, aObjects )

    aColHeader := {" ", "Data", "Num NF", "Prefixo", "Titulo", "Parcela", "Tipo", "Valor(R$)", "Saldo Rec", "Emissão", "Vcto Real", "Contato", "Usuário", "Motivo", "Justificativa"}

    aColSize   := { 10,     20,       40,        20,       40,       25,      25,        40,            20,        40,          40,        100,       100,      50,             200}

    oGrid := TWBrowse():New(005,005,aPosObj[2][4] - 5, aPosObj[2][3] - 035,,aColHeader,aColSize,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

    S0601ZZR("S")

    TButton():New(aPosObj[2][4] / 2 - 20, aPosObj[2][3] - 035, OemToAnsi("&Sair"), oDialog,{|| oDialog:End()      },103, 010,,,,.T.,,,,{|| })

    oDialog:Activate(,,,.T.)

Return

Static Function sZZR_DscMotivo(pMotivo)
    Local aSX5      := FWGetSX5( "XM", Alltrim(pMotivo) )
    Local _cMotivo  := ""
    //Local iSX5     	:= RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE")

    //DbSelectArea("SX5")
    //SX5->(DbSetOrder(iSX5))
    //If SX5->(DbSeek(xFilial("SX5")+"XM"+pMOTIVO))

    If Len(aSX5) > 0
        _cMotivo := aSX5[1,4]
    endif

Return( _cMotivo )

Static Function S0601ZZR(pPRIMEIRO)
    MsAguarde({|| S0601SQL(pPRIMEIRO)}, "Aguarde ...")

Return

Static Function S0601SQL(pPRIMEIRO)
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQueryZZR := " Select E1_CLIENTE, "
    cQueryZZR += "     E1_LOJA, "
    cQueryZZR += "     E1_YNF1, "
    cQueryZZR += "     E1_YNF2, "
    cQueryZZR += "     E1_YNF3, "
    cQueryZZR += "     E1_YNF4, "
    cQueryZZR += "     E1_YNF5, "
    cQueryZZR += "     E1_YNF6, "
    cQueryZZR += "     E1_NUM, "
    cQueryZZR += "     E1_PREFIXO, "
    cQueryZZR += "     E1_PARCELA, "
    cQueryZZR += "     E1_TIPO, "
    cQueryZZR += "     E1_EMISSAO, "
    cQueryZZR += "     E1_VENCREA, "
    cQueryZZR += "     E1_VALOR, "
    cQueryZZR += "     E1_SALDO,
    cQueryZZR += "     ZZR_MOTIVO, "
    cQueryZZR += "     ZZR_JUSTIF, "
    cQueryZZR += "     ZZR_CONTAT, "
    cQueryZZR += "     ZZR_DATA, "
    cQueryZZR += "     ZZR_HORA, "
    cQueryZZR += "     ZZR_USER "
    cQueryZZR += " FROM " + RetSqlName("SE1") + " SE1 with (nolock),"
    cQueryZZR += "      " + RetSqlName("ZZR") + " ZZR with (nolock)"
    cQueryZZR += " WHERE SE1.D_E_L_E_T_ <> '*' "
    cQueryZZR += "   AND ZZR.D_E_L_E_T_ <> '*' "
    cQueryZZR += "   AND ZZR_FILIAL = '" + xFILIAL("ZZR") + "' "
    cQueryZZR += "   AND ZZR_PREFIX = '" + SE1->E1_PREFIXO + "' "
    cQueryZZR += "   AND ZZR_NUM    = '" + SE1->E1_NUM + "' "
    cQueryZZR += "   AND ZZR_PARCEL = '" + SE1->E1_PARCELA + "' "
    cQueryZZR += "   AND ZZR_TIPO   = '" + SE1->E1_TIPO + "' "
    cQueryZZR += "   AND ZZR_FILIAL = E1_FILIAL "
    cQueryZZR += "   AND ZZR_PREFIX = E1_PREFIXO "
    cQueryZZR += "   AND ZZR_NUM    = E1_NUM "
    cQueryZZR += "   AND ZZR_PARCEL = E1_PARCELA "
    cQueryZZR += "   AND ZZR_TIPO   = E1_TIPO "
    cQueryZZR += " ORDER BY ZZR_DATA DESC, ZZR_HORA DESC "

    cQueryZZR := UPPER(cQueryZZR)

    If Select("QRYZZR") > 0
        QRYZZR->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryZZR),"QRYZZR",.F.,.T.)
    dbSelectArea("QRYZZR")
    QRYZZR->(dbGoTop())

    aGrid := {}
    cNUMERONF := ""

    While QRYZZR->(!Eof())
        dE1_VENCREA := AllTrim(DTOC(STOD(QRYZZR->E1_VENCREA)))
        dE1_EMISSAO := AllTrim(DTOC(STOD(QRYZZR->E1_EMISSAO)))
        dZZR_DATA := DTOC(STOD(QRYZZR->ZZR_DATA))

        cNUMERONF := U_NumeroNF(QRYZZR->E1_YNF1, QRYZZR->E1_YNF2, QRYZZR->E1_YNF3, QRYZZR->E1_YNF4, QRYZZR->E1_YNF5, QRYZZR->E1_YNF6)
        _cUserName:= fGetUsrName(QRYZZR->ZZR_USER)
        
        AAdd(aGrid,{dZZR_DATA,;
            cNUMERONF,;
            AllTrim(QRYZZR->E1_PREFIXO),;
            AllTrim(QRYZZR->E1_NUM),;
            AllTrim(QRYZZR->E1_PARCELA),;
            AllTrim(QRYZZR->E1_TIPO),;
            TRANSFORM(QRYZZR->E1_VALOR, "@E 999,999.99"),;
            TRANSFORM(QRYZZR->E1_SALDO, "@E 999,999.99"),;
            dE1_EMISSAO,;
            dE1_VENCREA,;
            AllTrim(QRYZZR->ZZR_CONTAT),;
            _cUserName,;
            sZZR_DscMotivo(QRYZZR->ZZR_MOTIVO),;
            AllTrim(QRYZZR->ZZR_JUSTIF),;
            0})
        QRYZZR->(dbSkip())
    EndDo

    if len(aGrid) = 0
        aGrid := {{"", "", "", "", "", "", "", 0, 0, "", "", "", "", "", "", 0}}
        //    Aviso("Nenhum Título","Atenção, Nenhum Título foi encontrado com os filtros informados.",{"&Retornar"})
    endif

    oGrid:SetArray(aGrid)
    oGrid:bLine := {||{,;
        aGrid[oGrid:nAt][1],;
        aGrid[oGrid:nAt][2],;
        aGrid[oGrid:nAt][3],;
        aGrid[oGrid:nAt][4],;
        aGrid[oGrid:nAt][5],;
        aGrid[oGrid:nAt][6],;
        aGrid[oGrid:nAt][7],;
        aGrid[oGrid:nAt][8],;
        aGrid[oGrid:nAt][9],;
        aGrid[oGrid:nAt][10],;
        aGrid[oGrid:nAt][11],;
        aGrid[oGrid:nAt][12],;
        aGrid[oGrid:nAt][13],;
        aGrid[oGrid:nAt][14],;
        aGrid[oGrid:nAt][15]}}

    oGrid:Refresh()

    oDialog:Refresh()

Return

Static Function fGetUsrName(cUserID)

Return(AllTrim(UsrFullName(cUserID)))