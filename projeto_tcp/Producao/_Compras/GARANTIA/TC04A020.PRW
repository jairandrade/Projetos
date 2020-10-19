#include 'protheus.ch'
#include "Totvs.ch"
#include "Rwmake.ch"
#Include "TopConn.ch"
#include "TC04A020.ch"

/*
Programa : TC04A020 
Autor    : ALMASGE
Data     : 30/08/2019                                                                                         U_                                                         
Desc.    : Consulta e Alteração do ORDER POINT
Uso      : TCP
*/
User Function TC04A020()
    Local aSize  := MsAdvSize()

    Private oGrid          := Nil
    Private cUsuario       := RetCodUsr()

    DbSelectArea("ZPB")
    DbSelectArea("ZPC")
    DbSelectArea("ZPD")
    DbSelectArea("ZPE")

    oGrid := FWMarkBrowse():New()
    oGrid:SetAlias('ZPB')

    oGrid:AddButton("Consultar Garantia", {||S0402CON()},,,, .F., 2 )
    oGrid:AddButton("Iniciar"    		, {||S0402INI()},,,, .F., 2 )
    oGrid:AddButton("Remessa"    		, {||S0402REM()},,,, .F., 2 )
    oGrid:AddButton("Visualizar"		, {||S0402VIS()},,,, .F., 2 )
    oGrid:AddButton("Orçamento Conserto", {||S0402ORC()},,,, .F., 2 )
    oGrid:AddButton("Incapacidade Técnica", {||S0402ITE()},,,, .F., 2 )
    oGrid:AddButton("Equipamento Sem Conserto", {||S0402ESC()},,,, .F., 2 )
    oGrid:AddButton("Retorno/Recebimento", {||S0402RET()},,,, .F., 2 )
    oGrid:AddButton("Encerramento"			, {||S0402ENC()},,,, .F., 2 )
    oGrid:AddButton("Workflow", {||S0402WF()},,,, .F., 2 )
    oGrid:AddButton("Legenda"			, {||S0402LEG()},,,, .F., 2 )
    oGrid:AddButton("Cancelamento"			, {||S0402CAN()},,,, .F., 2 )

    oGrid:SetDBFFilter(.T.)
    oGrid:SetUseFilter(.T.)

    sLegenda()
    oGrid:Activate()

Return

User Function ZPB_PRODSC ()
    cQuery := " Select B1_DESC "
    cQuery += " From " + RetSqlName("SB1") + " SB1 "
    cQuery += " Where B1_COD = '" + ZPB->ZPB_PRODUT + "'"
    cQuery += "   and B1_FILIAL =  '" + xFilial("SB1") + "' "
    cQuery += "   and D_E_L_E_T_ <> '*' "

    cQuery := ChangeQuery(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

return QRY->B1_DESC

User Function ZPB_FORDSC ()
    cQuery := " Select A2_NOME "
    cQuery += " From " + RetSqlName("SA2") + " SA2 "
    cQuery += " Where A2_COD = '" + ZPB->ZPB_FORNEC + "'"
    cQuery += "   and A2_LOJA = '" + ZPB->ZPB_LOJA + "'"
    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "
    cQuery += "   and D_E_L_E_T_ <> '*' "

    cQuery := ChangeQuery(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

return QRY->A2_NOME

User Function ZPB_TRADSC ()
    cQuery := " Select A2_NOME "
    cQuery += " From " + RetSqlName("SA2") + " SA2 "
    cQuery += " Where A2_COD = '" + ZPB->ZPB_TRANSP + "'"
    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "
    cQuery += "   and D_E_L_E_T_ <> '*' "

    cQuery := ChangeQuery(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

return QRY->A2_NOME


User Function ZPB_TIPDSC ()
    if ZPB->ZPB_TIPO == "R"
        return "Reparo"
    else
        return "Garantia"
    endif

User Function ZPB_STADSC ()
    local cZPB_STADSC := ""

    Do Case
    Case ZPB->ZPB_STATUS = "AAI"
        cZPB_STADSC := cTXT_AAI
    Case ZPB->ZPB_STATUS = "APF"
        cZPB_STADSC := cTXT_APF
    Case ZPB->ZPB_STATUS = "TRN"
        cZPB_STADSC := cTXT_TRN
    Case ZPB->ZPB_STATUS = "AOF"
        cZPB_STADSC := cTXT_AOF
    Case ZPB->ZPB_STATUS = "ITE"
        cZPB_STADSC := cTXT_ITE
    Case ZPB->ZPB_STATUS = "ESC"
        cZPB_STADSC := cTXT_ESC
    Case ZPB->ZPB_STATUS = "AAC"
        cZPB_STADSC := cTXT_AAC
    Case ZPB->ZPB_STATUS = "ORR"
        cZPB_STADSC := cTXT_ORR
    Case ZPB->ZPB_STATUS = "CAN"
        cZPB_STADSC := cTXT_CAN
    Case ZPB->ZPB_STATUS = "FIN"
        cZPB_STADSC := cTXT_FIN
    Case ZPB->ZPB_STATUS = "PFR"
        cZPB_STADSC := cTXT_PFR
    Case ZPB->ZPB_STATUS = "ARP"
        cZPB_STADSC := cTXT_ARP
    Case ZPB->ZPB_STATUS = "APC"
        cZPB_STADSC := cTXT_APC
    Case ZPB->ZPB_STATUS = "PCR"
        cZPB_STADSC := cTXT_PCR
    Case ZPB->ZPB_STATUS = "PRE"
        cZPB_STADSC := cTXT_PRE
    end case

return cZPB_STADSC

Static Function sLegenda()
    
    oGrid:AddLegend("ZPB_STATUS == 'AAI'", cCOR_AAI, cTXT_AAI)
    oGrid:AddLegend("ZPB_STATUS == 'APF'", cCOR_APF, cTXT_APF)
    oGrid:AddLegend("ZPB_STATUS == 'TRN'", cCOR_TRN, cTXT_TRN)
    oGrid:AddLegend("ZPB_STATUS == 'ITE'", cCOR_ITE, cTXT_ITE)
    oGrid:AddLegend("ZPB_STATUS == 'ESC'", cCOR_ESC, cTXT_ESC)
    oGrid:AddLegend("ZPB_STATUS == 'AOF'", cCOR_AOF, cTXT_AOF)
    oGrid:AddLegend("ZPB_STATUS == 'AAC'", cCOR_AAC, cTXT_AAC)
    oGrid:AddLegend("ZPB_STATUS == 'ORR'", cCOR_ORR, cTXT_ORR)
    oGrid:AddLegend("ZPB_STATUS == 'PFR'", cCOR_PFR, cTXT_PFR)
    oGrid:AddLegend("ZPB_STATUS == 'CAN'", cCOR_CAN, cTXT_CAN)
    oGrid:AddLegend("ZPB_STATUS == 'FIN'", cCOR_FIN, cTXT_FIN)
    oGrid:AddLegend("ZPB_STATUS == 'ARP'", cCOR_ARP, cTXT_ARP)
    oGrid:AddLegend("ZPB_STATUS == 'APC'", cCOR_APC, cTXT_APC)
    oGrid:AddLegend("ZPB_STATUS == 'PCR'", cCOR_PCR, cTXT_PCR)
    oGrid:AddLegend("ZPB_STATUS == 'PRE'", cCOR_PRE, cTXT_PRE)

return

Static Function s0402LEG ()

    Local oLegenda  :=  FWLegend():New()
    oLegenda:Add( '', cCOR_AAI, cTXT_AAI)
    oLegenda:Add( '', cCOR_APF, cTXT_APF)
    oLegenda:Add( '', cCOR_TRN, cTXT_TRN)
    oLegenda:Add( '', cCOR_AOF, cTXT_AOF)
    oLegenda:Add( '', cCOR_ITE, cTXT_ITE)
    oLegenda:Add( '', cCOR_ESC, cTXT_ESC)
    oLegenda:Add( '', cCOR_AAC, cTXT_AAC)
    oLegenda:Add( '', cCOR_ORR, cTXT_ORR)
    oLegenda:Add( '', cCOR_PFR, cTXT_PFR)
    oLegenda:Add( '', cCOR_CAN, cTXT_CAN)
    oLegenda:Add( '', cCOR_FIN, cTXT_FIN)
    oLegenda:Add( '', cCOR_ARP, cTXT_ARP)
    oLegenda:Add( '', cCOR_APC, cTXT_APC)
    oLegenda:Add( '', cCOR_PCR, cTXT_PCR)
    oLegenda:Add( '', cCOR_PRE, cTXT_PRE)

    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()

Static Function s0402CON ()
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0

    Local cTitulo := 'Consulta Garantia'

    Private oDlg      := Nil
    Private cZPB_PRODUT := Space(TamSX3('ZPB_PRODUT')[1])
    Private cZPB_LOTE := Space(TamSX3('ZPB_LOTE')[1])
    Private cZPB_SERIE := Space(TamSX3('ZPB_SERIE')[1])
    Private cB1_DESC
    Private cB8_DTVALID

    Private cANT_Pedido
    Private cANT_NF
    Private cANT_DATNF

    Private cDS_FORNEC
    Private cB8_DATA

    Private cZPB_DEFEIT := Space(TamSX3('ZPB_DEFEIT')[1])
    Private cZPB_OM     := Space(TamSX3('ZPB_OM')[1])
    Private cZPB_SOLICI := Space(TamSX3('ZPB_SOLICI')[1])
    Private cZPB_EQUIPA := Space(TamSX3('ZPB_EQUIPA')[1])
    Private cRA_NOME
    Private cZPE_DESCRI

    Private cOpcao := "X"

    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,550,820,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)

    aObjects := {}

    AAdd( aObjects, { 100, 450, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,270,285,265},;
        {10,40,105,140,200,234, 63,200,225,270,285,265} } )


    @ aPosObj[1][1]+ 10,aPosGet[1,1]       Say "Produto"                             Of oDlg  Pixel Size 031, 010
    @ aPosObj[1][1]+ 08,aPosGet[1,1] + 52  MsGet cZPB_PRODUT                         When .T. Of oDlg F3 "SB1" VALID sZPB_PRODUT() Pixel Size  50, 010

    @ aPosObj[1][1]+ 25,aPosGet[1,1]       Say "Lote"                                Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 23,aPosGet[1,1] + 52  MsGet cZPB_LOTE                           When .T. Of oDlg VALID sZPB_LOTE() Pixel Size 50,010

    @ aPosObj[1][1]+ 40,aPosGet[1,1]       Say "Serie"                               Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 38,aPosGet[1,1] + 52  MsGet cZPB_SERIE                          When .T. Of oDlg VALID sZPB_SERIE() Pixel Size 100,010

    TButton():New(aPosObj[1][1]+ 55,aPosGet[1,1], OemToAnsi("&Validar") ,oDlg,{|| sZPB_VALIDAR()}                 ,045, 010,,,,.T.,,,,{|| })


    @ aPosObj[1][1]+ 70,aPosGet[1,1]       Say "Defeito"                             Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 68,aPosGet[1,1] + 52  Get oMemo Var cZPB_DEFEIT Memo 		     Size 200, 30 Of oDlg Pixel

    @ aPosObj[1][1]+ 105,aPosGet[1,1]       Say "OM"                                 Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 103,aPosGet[1,1] + 52  MsGet cZPB_OM                            When .T.  Of oDlg  Pixel Size 50,010

    @ aPosObj[1][1]+ 120,aPosGet[1,1]       Say "Solicitante"                        Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 118,aPosGet[1,1] + 52  MsGet cZPB_SOLICI                        When .T. F3 "SRA" Valid sZPB_SOLICI() Of oDlg  Pixel Size 50,010
    @ aPosObj[1][1]+ 118,aPosGet[1,1] + 102 MsGet cRA_NOME                           When .F. Of oDlg  Pixel Size 198,010

    @ aPosObj[1][1]+ 135,aPosGet[1,1]       Say "Equipamento"                        Of oDlg   Pixel Size 051,010
    @ aPosObj[1][1]+ 133,aPosGet[1,1] + 52  MsGet cZPB_EQUIPA                        When .T. F3 "ZPE" Valid sZPB_EQUIPA() Of oDlg  Pixel Size 50,010
    @ aPosObj[1][1]+ 133,aPosGet[1,1] + 102 MsGet cZPE_DESCRI                        When .F. Of oDlg  Pixel Size 198,010

    @ aPosObj[1][1]+ 150,aPosGet[1,1]       Say "Descricao"                          Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 148,aPosGet[1,1] + 52  MsGet cB1_DESC                           When .F. Of oDlg  Pixel Size 250,010

    @ aPosObj[1][1]+ 165,aPosGet[1,1]       Say "Nr Pedido"                          Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 163,aPosGet[1,1] + 52  MsGet cANT_Pedido                         When .F. Of oDlg  Pixel Size 50,010

    @ aPosObj[1][1]+ 180,aPosGet[1,1]       Say "Nr Nota Fiscal"                     Of oDlg   Pixel Size 051,010
    @ aPosObj[1][1]+ 178,aPosGet[1,1] + 52  MsGet cANT_NF                             When .F. Of oDlg  Pixel Size 50,010

    @ aPosObj[1][1]+ 195,aPosGet[1,1]       Say "Fornecedor"                         Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 193,aPosGet[1,1] + 52  MsGet cDS_FORNEC                         When .F. Of oDlg  Pixel Size 200,010

    @ aPosObj[1][1]+ 210,aPosGet[1,1]       Say "Data de Entrada"                    Of oDlg   Pixel Size 051,010
    @ aPosObj[1][1]+ 208,aPosGet[1,1] + 52  MsGet cB8_DATA                            When .F. Of oDlg  Pixel Size 60,010

    @ aPosObj[1][1]+ 225,aPosGet[1,1]       Say "Data de Garantia"                    Of oDlg   Pixel Size 051,010
    @ aPosObj[1][1]+ 223,aPosGet[1,1] + 52  MsGet cB8_DTVALID                         When .F. Of oDlg  Pixel Size 60,010

    @ aPosObj[1][1]+ 240,aPosGet[1,1]       Say "Data Ultimo Reparo"                  Of oDlg   Pixel Size 051,010
    @ aPosObj[1][1]+ 238,aPosGet[1,1] + 52  MsGet cANT_DATNF                         When .F. Of oDlg  Pixel Size 60,010

    TButton():New(aPosObj[1][1]+ 255,aPosGet[1,1],OemToAnsi("&Garantia")              ,oDlg,{|| nClick := 1, iif(sZPB_GRCON("G"), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(aPosObj[1][1]+ 255,aPosGet[1,1] + 52,OemToAnsi("&Reparo")           ,oDlg,{|| nClick := 1, iif(sZPB_GRCON("R"), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })

    oDlg:Activate(,,,.T.)

    oGrid:Refresh(.T.)
    oGrid:Refresh(.F.)

return

Static Function sZPB_VALIDAR()
    cOpcao := "X"
    if empty(cZPB_PRODUT)
        MsgStop("Produto não informado.")
        return .F.
    elseif  empty(cZPB_LOTE)
        MsgStop("Lote não informado.")
        return .F.
    elseif  empty(cZPB_SERIE)
        MsgStop("Serie não informada.")
        return .F.
    endif

    if empty(cB8_DTVALID)
        cOpcao := "R"
    elseif cB8_DTVALID >= DATE()
        cOpcao := "G"
    else
        cOpcao := "R"
    endif

    // Verifica se o produto é de reparo ou garantia
    ultimaletra := Upper(Right(Alltrim(cZPB_PRODUT), 1))
    tamanho := len(Alltrim(cZPB_PRODUT))
    if ultimaletra <> 'R' .and. ultimaletra <> 'G'
        return
    endif

    // Buscar informações do ultimo reparo do produto
    cQuery := " Select max(R_E_C_N_O_) RECNO "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPB_PRODUT =  '" + cZPB_PRODUT + "' "
    cQuery += "   and ZPB_SERIE =  '" + cZPB_SERIE + "' "
    cQuery += "   and ZPB_LOTNEW =  '" + cZPB_LOTE + "' "

    If Select("QRECNO") > 0
        QRECNO->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRECNO",.F.,.T.)
    dbSelectArea("QRECNO")

    cQuery := " Select * "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where R_E_C_N_O_ =  " + cValToChar(QRECNO->RECNO) + " "

    If Select("QANT") > 0
        QANT->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QANT",.F.,.T.)
    dbSelectArea("QANT")

    cANT_Pedido := QANT->ZPB_SC7
    cANT_NF := QANT->ZPB_NF1

    cQuery := " Select F1_EMISSAO "
    cQuery += " from " + RetSqlName ("SF1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and F1_DOC =  '" + QANT->ZPB_NF1 + "' "
    cQuery += "   and F1_FORNECE =  '" + QANT->ZPB_FORNEC + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    cANT_DATNF := DTOC(STOD(QRY->F1_EMISSAO))

    MsgStop("Validação realizada com sucesso.")

return .T.

Static Function sZPB_LOTE()
				
	Local cLoteTmp := SuperGetMV("TCP_ARMTMP",.F.,"51")
    cQuery := " Select B8_DATA, B8_DTVALID "
    cQuery += " from " + RetSqlName ("SB8")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B8_FILIAL =  '" + xFilial("SB8") + "' "
    cQuery += "   and B8_PRODUTO =  '" + cZPB_PRODUT + "' "
    cQuery += "   and B8_LOTECTL =  '" + cZPB_LOTE + "' "
    cQuery += "   and B8_LOCAL =  '"+cLoteTmp+"' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->B8_DTVALID)
        MsgStop("Lote não cadastrado.")
        cB8_DATA := ""
        cB8_DTVALID := ""
        return .F.
    else
        cB8_DATA := STOD(QRY->B8_DATA)
        cB8_DTVALID := STOD(QRY->B8_DTVALID)
    endif

return .T.

Static Function sZPB_SERIE()
    cQuery := " Select BF_NUMSERI "
    cQuery += " from " + RetSqlName ("SBF")
    cQuery += " where BF_FILIAL =  '" + xFilial("SBF") + "' "
    cQuery += "   and BF_PRODUTO =  '" + cZPB_PRODUT + "' "
    cQuery += "   and BF_LOTECTL =  '" + cZPB_LOTE + "' "
    cQuery += "   and BF_NUMSERI =  '" + cZPB_SERIE + "' "
    // Retirado da consultado pois os movimentos gerados são sempre deletados após o uso e o objetivo e verificar que um dia existiu este produto/lote/serie
    // sugerido por Denni.
    // cQuery += "   and D_E_L_E_T_ <> '*' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->BF_NUMSERI)
        MsgStop("Numero de serie não encontrado.")
        return .F.
    endif

return .T.


Static Function sZPB_SOLICI()
    cQuery := " Select RA_NOME "
    cQuery += " from " + RetSqlName ("SRA")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and RA_FILIAL =  '" + xFilial("SRA") + "' "
    cQuery += "   and RA_MAT =  '" + cZPB_SOLICI + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->RA_NOME)
        MsgStop("Solicitante não encontrado.")
        cRA_NOME := ""
        return .F.
    else
        cRA_NOME := QRY->RA_NOME
        return .T.
    endif

Static Function sZPB_EQUIPA()
    cQuery := " Select ZPE_DESCRI "
    cQuery += " from " + RetSqlName ("ZPE")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPE_FILIAL =  '" + xFilial("ZPE") + "' "
    cQuery += "   and ZPE_CODIGO =  '" + cZPB_EQUIPA + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->ZPE_DESCRI)
        MsgStop("Solicitante não encontrado.")
        cZPE_DESCRI := ''
        return .F.
    else
        cZPE_DESCRI := QRY->ZPE_DESCRI
        return .T.
    endif

Static Function sZPB_PROC()
    cQuery := " Select max(ZPB_PROC) ZPB_PROC from " + retsqlname("ZPB")

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->ZPB_PROC)
        cZPB_PROC := '000001'
    else
        cZPB_PROC := Soma1(QRY->ZPB_PROC)
    endif

return cZPB_PROC

User Function SC7FRE(cC7_NUM, cC7_NUMSC, cC7_MEDICAO)

    if empty(cC7_NUMSC) .and. empty(cC7_MEDICAO)
        return
    endif

    cQuery := " Select ZPB_PROC "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPB_FILIAL =  '" + xFilial("ZPB") + "' "
    if !empty(cC7_NUMSC)
        cQuery += "    and ZPB_SC1FRE =  '" + cC7_NUMSC + "' "
    endif
    if !empty(cC7_MEDICAO)
        cQuery += "    and ZPB_MEDFRE =  '" + cC7_MEDICAO + "'"
    endif

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->ZPB_PROC)
        return
    else
        cZPB_PROC := QRY->ZPB_PROC
    endif

    // Atualizando dados da ZPB
    cZPB_STATUS := 'APF'

    cUpdate := " update " + retsqlname("ZPB") + " "
    cUpdate += " set ZPB_STATUS = '" + cZPB_STATUS + "', ZPB_PCFRE = '" + cC7_NUM + "' "
    cUpdate += " where D_E_L_E_T_ <> '*' "
    cUpdate += "   and ZPB_FILIAL = '" + xFilial("ZPB") + "'"
    cUpdate += "   and ZPB_PROC = '" + cZPB_PROC + "'"

    cUpdate := UPPER(cUpdate)

    nUpdate := TcSqlExec(cUpdate)
    if nUpdate < 0
        MsgInfo ("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError())
    endif

    // Recuperando Data e Hora do Servidor Sql Server
    cQuery := " Select CONVERT(varchar, getdate(), 103) DATA, convert(varchar, getdate(), 8) HORA"

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    cData := CTOD(QRY->DATA)
    cHora := QRY->HORA

    // Inserindo registros da tabela de MOTIVOS DE NEGOCIAÇÃO
    Reclock("ZPC", .T.)
    ZPC->ZPC_FILIAL := xFILIAL("ZPC")
    ZPC->ZPC_PROC   := cZPB_PROC
    ZPC->ZPC_DATA   := cData
    ZPC->ZPC_HORA   := cHora
    ZPC->ZPC_STATUS := cZPB_STATUS
    ZPC->ZPC_USER   := UsrRetName(RetCodUsr())
    ZPC->ZPC_OBSERV := "Gerado pedido de compra de frete [" + cC7_NUM + "]."

    ZPC->(MsUnLock())

return


User Function NF1FRE(cF1_DOC, cF1_SERIE, cD1_PEDIDO)
    if empty(cD1_PEDIDO)
        return
    endif

    cQuery := " Select ZPB_PROC "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPB_FILIAL =  '" + xFilial("ZPB") + "' "
    cQuery += "    and ZPB_PCFRE =  '" + cD1_PEDIDO + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->ZPB_PROC)
        return
    else
        cZPB_PROC := QRY->ZPB_PROC
    endif

    cUpdate := " update " + retsqlname("ZPB") + " "
    cUpdate += " set ZPB_NFFRE = '" + cF1_DOC + "' "
    cUpdate += " where D_E_L_E_T_ <> '*' "
    cUpdate += "   and ZPB_FILIAL = '" + xFilial("ZPB") + "'
    cUpdate += "   and ZPB_PROC = '" + cZPB_PROC + "'

    cUpdate := UPPER(cUpdate)

    nUpdate := TcSqlExec(cUpdate)
    if nUpdate < 0
        MsgInfo ("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError())
    endif

    // Recuperando Data e Hora do Servidor Sql Server
    cQuery := " Select CONVERT(varchar, getdate(), 103) DATA, convert(varchar, getdate(), 8) HORA"

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    cData := CTOD(QRY->DATA)
    cHora := QRY->HORA

    // Inserindo registros da tabela de MOTIVOS DE NEGOCIAÇÃO
    Reclock("ZPC", .T.)
    ZPC->ZPC_FILIAL := xFILIAL("ZPC")
    ZPC->ZPC_PROC   := cZPB_PROC
    ZPC->ZPC_DATA   := cData
    ZPC->ZPC_HORA   := cHora
    ZPC->ZPC_STATUS := ' '
    ZPC->ZPC_USER   := UsrRetName(RetCodUsr())
    ZPC->ZPC_OBSERV := "Gerada nota fiscal de frete [" + cF1_DOC + "/" + cF1_SERIE + "]."

    ZPC->(MsUnLock())

return


Static Function sZPC_GRAVAR(cStatus, cObservacao)
    // Recuperando Data e Hora do Servidor Sql Server
    cQuery := " Select CONVERT(varchar, getdate(), 103) DATA, convert(varchar, getdate(), 8) HORA"

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    cData := CTOD(QRY->DATA)
    cHora := QRY->HORA

    // Inserindo registros da tabela de MOTIVOS DE NEGOCIAÇÃO
    Reclock("ZPC", .T.)
    ZPC->ZPC_FILIAL := xFILIAL("ZPC")
    ZPC->ZPC_PROC   := ZPB->ZPB_PROC
    ZPC->ZPC_DATA   := cData
    ZPC->ZPC_HORA   := cHora
    ZPC->ZPC_STATUS := cStatus
    ZPC->ZPC_USER   := UsrRetName(cUsuario)
    ZPC->ZPC_OBSERV := cObservacao

    ZPC->(MsUnLock())

return .T.

Static Function sZPB_GRCON(cTipo)
    									
	
    Local cLoteTmp := SuperGetMV("TCP_ARMTMP",.F.,"51")												   
    
    Local cZPB_PROAUX   := cZPB_PRODUT
    Local lReturn       := .T.
    Private cZPB_LOCAL

    if cOpcao = "X"
        MsgStop("Os dados do produto não foram validados ou estão incorretos. Impossível iniciar processo de reparo/garantia! ")
        return .F.
    elseif cOpcao = "G" .and. cTipo = "R"
        if !MsgYesNo("Este produto possui garantia válida. Deseja iniciar processo de reparo? ", "Atenção")
            return .F.
        endif
    elseif cOpcao = "R" .and. cTipo = "G"
        if !MsgYesNo("Este produto não possui garantia válida. Deseja iniciar processo de garantia? ", "Atenção")
            return .F.
        endif
    endif

    if empty(cZPB_PRODUT)
        MsgStop("Produto não informado.")
        return .F.
    elseif  empty(cZPB_LOTE)
        MsgStop("Lote não informado.")
        return .F.
    elseif  empty(cZPB_SERIE)
        MsgStop("Serie não informada.")
        return .F.
    elseif  empty(cZPB_DEFEIT)
        MsgStop("Defeito não informado.")
        return .F.
    elseif  empty(cZPB_OM)
        MsgStop("OM não informada.")
        return .F.
    elseif  empty(cZPB_SOLICI)
        MsgStop("Solicitante não informado.")
        return .F.
    elseif  empty(cZPB_EQUIPA)
        MsgStop("Equipamento não informado.")
        return .F.
    endif

    // Testa se deve ou não adicionar o tipo do processo ao produto
    ultimaletra := Upper(Right(Alltrim(cZPB_PRODUT), 1))
    tamanho := len(Alltrim(cZPB_PRODUT))
    if ultimaletra = 'R' .or. ultimaletra = 'G'
        cZPB_PRODUT := substr(cZPB_PRODUT, 1, tamanho - 1)
        cZPB_PRODUT := Alltrim(cZPB_PRODUT) + cTipo
    else
        cZPB_PRODUT := Alltrim(cZPB_PRODUT) + cTipo
    endif

    if !sCRIASB1(cZPB_PROAUX, cZPB_PRODUT)
        return .F.
    endif

    cQuery := " Select ZPB_PROC "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPB_PRODUT =  '" + cZPB_PRODUT + "' "
    cQuery += "   and ZPB_LOTE =  '" + cZPB_LOTE + "' "
    cQuery += "   and ZPB_SERIE =  '" + cZPB_SERIE + "' "
    cQuery += "   and ZPB_STATUS NOT IN  ('CAN','FIN') "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if !empty(QRY->ZPB_PROC)
        MsgStop("Já existe o processo [" + QRY->ZPB_PROC + "] em andamento para este PRODUTO/LOTE/SERIE.")
        return .F.
    endif

    // Recuperando Data e Hora do Servidor Sql Server
    cQuery := " Select CONVERT(varchar, getdate(), 103) DATA, convert(varchar, getdate(), 8) HORA"

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    cData := CTOD(QRY->DATA)
    cHora := QRY->HORA

    Begin Transaction
        
        // Inserindo registros da tabela de MOTIVOS DE NEGOCIAÇÃO
        Reclock("ZPB", .T.)
        ZPB->ZPB_FILIAL := xFILIAL("ZPB")
        ZPB->ZPB_PROC   := sZPB_PROC()
        ZPB->ZPB_TIPO   := cTipo
        ZPB->ZPB_DTINC   := cData
        // ZPB->ZPB_HORA   := cHora
        ZPB->ZPB_PRODUT := cZPB_PRODUT
        ZPB->ZPB_LOTE   := UPPER(cZPB_LOTE)
        ZPB->ZPB_SERIE := UPPER(cZPB_SERIE)
        
        if Valtype(cB8_DTVALID) = 'D'
            ZPB->ZPB_DTVALI := cB8_DTVALID
        endif
        
        ZPB->ZPB_STATUS := "AAI"
        ZPB->ZPB_DEFEIT := cZPB_DEFEIT
        ZPB->ZPB_OM     := cZPB_OM
        ZPB->ZPB_SOLICI := cZPB_SOLICI
        ZPB->ZPB_EQUIPA := cZPB_EQUIPA

        sZPC_GRAVAR ('AAI', 'Inicio')

        // Somente executa a criação do movimento interno se a rotina MATA220 (verifica saldos iniciais) retornar .T.
        if !sMATA220INC()
            cZPB_PRODUT := cZPB_PROAUX
            Disarmtransaction()
            lReturn := .F.
        endif

        If lReturn

            cZPB_SD3ENT := sMATA241INC()
            
            if empty(cZPB_SD3ENT)
                cZPB_PRODUT := cZPB_PROAUX
                Disarmtransaction()
                lReturn := .F.
            endif

            ZPB->ZPB_SD3ENT := cZPB_SD3ENT
        				 
        
        EndIf
						   
        
        ZPB->(MsUnLock())
							
	   DbSelectArea('SBF')
       SBF->(DbSetOrder(2))
       
       if SBF->(DBSeek(xFilial('SBF')+ZPB->ZPB_PRODUT+cLoteTmp+ZPB->ZPB_LOTE)) 
       		 RecLock("SBF",.F.)
             //deleta o arquivo
             SBF->(DbDelete()) 
             //Fecha tabela
             SBF->(MsUnLock())
       endif					   
							   
						   
							  
			
    
    End Transaction
    
    If lReturn
        U_WFGARINI(ZPB->ZPB_PROC)

        cZPB_PRODUT := cZPB_PROAUX
    EndIf

    oGrid:Refresh(.T.)
    oGrid:Refresh(.F.)

return( lReturn )

Static Function sMATA220INC()
    
    Local aCabec := {}

    Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Private lMsErroAuto := .f. //necessario a criacao

    if ZPB->ZPB_TIPO = 'G'
        cZPB_LOCAL := GETMV('TCP_ARMGAR')
    else
        cZPB_LOCAL := GETMV('TCP_ARMREP')
    endif
    // Verifica se ja existe o produto cadastrado na SB2 para o armazem destino
    cQuery := " Select B2_COD "
    cQuery += " from " + RetSqlName ("SB2")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B2_COD =  '" + cZPB_PRODUT + "' "
    cQuery += "   and B2_LOCAL =  '" + cZPB_LOCAL + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if !empty(QRY->B2_COD)
        return .T.
    endif

    aCabec := {}
    aadd(aCabec,{"B9_COD", cZPB_PRODUT,})
    aadd(aCabec,{"B9_LOCAL", cZPB_LOCAL,})
    aadd(aCabec,{"B9_QINI",0,})
    MSExecAuto({|x,y| mata220(x,y)},aCabec,3)
    If lMsErroAuto
        Mostraerro()
        return .F.
    endif

return .T.

Static Function sMATA241INC()
    
    Local aCabec   := {}
    Local aLinha 	:= {}
    Local aItens	:={}
    Local cCodigoTM := GETMV("TCP_TPMOVE")

    Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Private lMsErroAuto := .f. //necessario a criacao

    Private _acod:={"1","MP1"}

    aAdd(aCabec, {"D3_TM",      cCodigoTM, NIL})
    aAdd(aCabec, {"D3_EMISSAO" ,ddatabase, NIL})

    if ZPB->ZPB_TIPO = 'G'
        cZPB_CONTA   := GETMV('TCP_GARCTA')
        cZPB_ITEMCTA := GETMV('TCP_GARIT')
        cZPB_ENDEREC := GETMV('TCP_GARLOC')
    else
        cZPB_CONTA   := GETMV('TCP_REPCTA')
        cZPB_ITEMCTA := GETMV('TCP_REPIT')
        cZPB_ENDEREC := GETMV('TCP_REPLOC')
    endif

    aAdd(aLinha, {"D3_COD"    , cZPB_PRODUT ,NIL})
    aAdd(aLinha, {"D3_UM"     , "UN",NIL})
    aAdd(aLinha, {"D3_QUANT"  , 1 ,NIL})
    aAdd(aLinha, {"D3_LOCAL"  , cZPB_LOCAL ,NIL})
    aAdd(aLinha, {"D3_LOCALIZ", cZPB_ENDEREC ,NIL})
    aAdd(aLinha, {"D3_LOTECTL", cZPB_LOTE,NIL})
    aAdd(aLinha, {"D3_NUMSERI", cZPB_SERIE,NIL})
    aAdd(aLinha, {"D3_CONTA"  , cZPB_CONTA,NIL})
    aAdd(aLinha, {"D3_REQUISI", ZPB->ZPB_SOLICI,NIL})
    aAdd(aLinha, {"D3_ITEMCTA", cZPB_ITEMCTA,NIL})
    aadd(aItens,aLinha)

    MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aItens,3)

    If lMsErroAuto
        Mostraerro()
    else
        cDOC := SD3->D3_DOC
        sZPC_GRAVAR ('AAI', 'Gerado Movimento Interno [' + cDOC + "].")
    EndIf

    cZPB_SBFENT := sMATA265INC(SD3->D3_NUMSEQ)

Return cDoc

Static Function sMATA265INC(cDA_NUMSEQ)
    Local aCabec := {}
    Local aItens := {}
    Private	lMsErroAuto := .F.

    if ZPB->ZPB_TIPO = 'G'
        cZPB_ENDEREC := GETMV('TCP_GARLOC')
    else
        cZPB_ENDEREC := GETMV('TCP_REPLOC')
    endif

    /*
  	// Verifica se ja existe o produto/lote/serie ja esta cadastrado na SDB
    cQuery := " Select DB_PRODUTO "
    cQuery += " from " + RetSqlName ("SDB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and DB_PRODUTO =  '" + cZPB_PRODUT + "' "
    cQuery += "   and DB_LOCAL = '" + cZPB_LOCAL + "' "                  
    cQuery += "   and DB_LOCALIZ = '" + cZPB_ENDEREC + "' "                   
    cQuery += "   and DB_LOTECTL = '" + cZPB_LOTE + "' "
    cQuery += "   and DB_NUMSERI = '" + cZPB_SERIE + "' "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY") 
    
    if !empty(QRY->DB_PRODUTO)
        return ""
    endif
    */

    //Cabeçalho com a informação do item e NumSeq que sera endereçado.
    aAdd(aCabec, {"DA_PRODUTO" , cZPB_PRODUT, Nil})
    aAdd(aCabec, {"DA_NUMSEQ"  , cDA_NUMSEQ,Nil})

    aLinha := {}
    aadd(aLinha, {"DB_ITEM"    ,"0001"	   ,Nil})
    aadd(aLinha, {"DB_ESTORNO" ," "	       ,Nil})
    aadd(aLinha, {"DB_LOCAL"   ,cZPB_LOCAL ,Nil})
    aadd(aLinha, {"DB_LOCALIZ" ,cZPB_ENDEREC,Nil})
    aadd(aLinha, {"DB_LOTECTL" ,cZPB_LOTE  ,Nil})
    aadd(aLinha, {"DB_NUMSERI" ,cZPB_SERIE ,Nil})
    aadd(aLinha, {"DB_DATA"	   ,dDataBase  ,Nil})
    aadd(aLinha, {"DB_QUANT"   ,1          ,Nil})
    aadd(aItens,aLinha)

    //Executa o endereçamento do item
    MATA265( aCabec, aItens, 3)
    If lMsErroAuto
        MostraErro()
        cDoc := ""
    Else
        cDoc := cDA_NUMSEQ
        sZPC_GRAVAR ('AAI', 'Gerado Endereçamento para o movimento SD3 [' + cDOC + "].")
    Endif

Return cDoc

Static Function sZPB_PRODUT()
    cQuery := " Select B1_DESC "
    cQuery += " from " + RetSqlName ("SB1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B1_FILIAL =  '" + xFilial("SB1") + "' "
    cQuery += "   and B1_COD =  '" + cZPB_PRODUT + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->B1_DESC)
        MsgStop("Produto não cadastrado.")
        return .F.
        cB1_DESC := ""
    else
        cB1_DESC := QRY->B1_DESC
    endif

return .T.

Static Function sCRIASB1(cZPB_PROORI, cZPB_PRODES)
    Local aArea     := GetArea()
    Local aEstru    := {}
    Local aConteu   := {}
    Local nPosCod   := 0
    Local nCampoCod := ""
    Local cQryAux   := ""
    Local nAtual    := 0
    Local cTabelaAux := "SB1"

    DbSelectArea(cTabelaAux)

    //Pega a estrutura da tabela
    aEstru := (cTabelaAux)->(DbStruct())

    //Encontra o campo filial
    nPosCod   := aScan(aEstru, {|x| "COD" $ AllTrim(Upper(x[1]))})
    nCampoCod := aEstru[nPosCod][1]

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
    //Faz uma consulta sql para verificar se o produto do processo (G/R) já existe
    cQryAux := " SELECT B1_COD  "
    cQryAux += " FROM " + RetSQLName(cTabelaAux) + " "
    cQryAux += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
    cQryAux += "   AND B1_COD = '" + cZPB_PRODES + "' "
    cQryAux += "   AND D_E_L_E_T_ = ' ' "

    TCQuery cQryAux New Alias "QRY"

    if !empty(QRY->B1_COD)
        return .T.
    endif

    QRY->(dbCloseArea())

    //Faz uma consulta sql trazendo o RECNO
    cQryAux := " SELECT R_E_C_N_O_ AS DADREC "
    cQryAux += " FROM " + RetSQLName(cTabelaAux) + " "
    cQryAux += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
    cQryAux += "   AND B1_COD = '" + cZPB_PROORI + "' "
    cQryAux += "   AND D_E_L_E_T_ = ' ' "

    TCQuery cQryAux New Alias "QRY"

    //Caso exista registro
    If ! QRY->(EoF())
        //Posiciona nesse recno
        (cTabelaAux)->(DbGoTo(QRY->DADREC))

        //Percorre a estrutura
        ProcRegua(Len(aEstru))
        For nAtual := 1 To Len(aEstru)
            IncProc("Adicionando valores ("+cValToChar(nAtual)+" de "+cValToChar(Len(aEstru))+")...")

            //Se for campo filial
            If Alltrim(aEstru[nAtual][1]) == Alltrim(nCampoCod)
                aAdd(aConteu, cZPB_PRODES)
            Else
                aAdd(aConteu, &(cTabelaAux+"->"+aEstru[nAtual][1]))
            EndIf
        Next

        IncProc("Criando o registro...")
        //Faz um RecLock
        RecLock(cTabelaAux, .T.)
        //Percorre a estrutura
        For nAtual := 1 To Len(aEstru)
            //Grava o novo valor
            &(aEstru[nAtual][1]) := aConteu[nAtual]
        Next
        (cTabelaAux)->(MsUnlock())

        MsgInfo("Criado produto [" + cZPB_PRODES+ "].", "Atenção")

        sZPC_GRAVAR("AAI", "Criação do produto[" + cZPB_PRODES+ "].")
    EndIf

    QRY->(DbCloseArea())

    RestArea(aArea)

Return .T.

Static Function S0402TRA ()
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Definição do Tipo de Frete'

    Local _nOpcao
    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,250,300,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)

    aObjects := {}

    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,270,285,265},;
        {10,40,105,140,200,234, 63,200,225,270,285,265} } )

    TSay():New(028, 025,{|| "Tipo de Frete" },oDlg,,,.F.,.F.,.F.,.T.,,,200,008)
    @ 041, 025 Radio oRadTpSol Var _nOpcao Items "CIF", "FOB - CONTRATO", "FOB - SOL COMPRA", "SEM FRETE"  Size 060, 050 PIXEL OF oDlg

    TButton():New(oDlg:nClientHeight/2-30, 003, OemToAnsi("&Ok")                      ,oDlg,{|| nClick := 1, oDlg:End()}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(oDlg:nClientHeight/2-30, 053, OemToAnsi("&Cancelar")                ,oDlg,{|| nClick := 0, oDlg:End()}    ,045, 010,,,,.T.,,,,{|| })

    oDlg:Activate(,,,.T.)

    If nClick == 1
        return _nOpcao
    else
        return 9
    EndIf

return

Static Function S0402INI ()
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Iniciar Processo de Reparo/Garantia'

    Private oDlg      := Nil
    Private cZPB_TRANSP := Space(TamSX3('ZPB_TRANSP')[1])
    Private cDSC_TRANSP
    Private cZPB_FORNEC := Space(TamSX3('ZPB_FORNEC')[1])
    Private cDSC_FORNEC
    Private cZPB_SERFRE := Space(TamSX3('ZPB_SERFRE')[1])
    Private cDSC_SERFRE
    Private cZPB_CC     := Space(TamSX3('CTT_CUSTO')[1])
    Private cDSC_CC
    Private dZPB_DTNECE := CTOD("  /  /    ")
    Private nZPB_TPFRE
    Private cDSC_FRETE

    // Variavel usada para controlar a troca de fornecedor e atualização da lista de contratos
    Private cTranspAux := ""

    Private nLinhaCON
    Private cComboContrato
    Private aCNC_CONTRATO := {}

    if ZPB->ZPB_STATUS <> 'AAI'
        MsgStop("Este processo de reparo/garantia não se encontra na situação: " + cTXT_AAI + ". Impossível iniciar processo de reparo/garantia! ")
        return
    endif

    // Chamar a tela para definir o tipo de transporte a ser utilizado na tela
    nZPB_TPFRE := s0402TRA()
    if nZPB_TPFRE = 9
        return
    elseif nZPB_TPFRE = xFRETE_CIF
        cDSC_FRETE:= "CIF"
    elseif nZPB_TPFRE = xFRETE_CON
        cDSC_FRETE:= "FOB - CONTRATO"
    elseif nZPB_TPFRE = xFRETE_FOB
        cDSC_FRETE:= "FOB - Solicitação de Compra"
        cZPB_SERFRE := GETMV('TCP_SERFRE')
    elseif nZPB_TPFRE = xFRETE_SEM
        cDSC_FRETE:= "Sem Frete"
    endif


    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,550,820,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)

    aObjects := {}

    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,270,285,265},;
        {10,40,105,140,200,234, 63,200,225,270,285,265} } )


    // Buscar informações do ultimo reparo do produto
    cQuery := " Select max(R_E_C_N_O_) RECNO "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and ZPB_PRODUT =  '" + ZPB->ZPB_PRODUT + "' "
    cQuery += "   and ZPB_SERIE =  '" + ZPB->ZPB_SERIE + "' "
    cQuery += "   and ZPB_LOTNEW =  '" + ZPB->ZPB_LOTE + "' "
    cQuery += "   and ZPB_PROC <>  '" + ZPB->ZPB_PROC + "' "

    If Select("QRECNO") > 0
        QRECNO->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRECNO",.F.,.T.)
    dbSelectArea("QRECNO")

    cQuery := " Select * "
    cQuery += " from " + RetSqlName ("ZPB")
    cQuery += " where R_E_C_N_O_ =  " + cValToChar(QRECNO->RECNO) + " "

    If Select("QANT") > 0
        QANT->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QANT",.F.,.T.)
    dbSelectArea("QANT")

    // Apresenta

    @ aPosObj[1][1]+ 10,aPosGet[1,1]       Say "Produto"                             Of oDlg  Pixel Size 031, 010
    @ aPosObj[1][1]+ 08,aPosGet[1,1] + 32  MsGet ZPB->ZPB_PRODUT                     When .F. Of oDlg Pixel Size  50, 010

    @ aPosObj[1][1]+ 30,aPosGet[1,1]       Say "Lote"                                Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 28,aPosGet[1,1] + 32  MsGet ZPB->ZPB_LOTE                       When .F. Of oDlg Pixel Size 50,010

    @ aPosObj[1][1]+ 50,aPosGet[1,1]       Say "Serie"                               Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 48,aPosGet[1,1] + 32  MsGet ZPB->ZPB_SERIE                      When .F. Of oDlg Pixel Size 50,010

    @ aPosObj[1][1]+ 70,aPosGet[1,1]       Say "Fornecedor"                          Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 68,aPosGet[1,1] + 32  MsGet QANT->ZPB_FORNEC                    When .F. Of oDlg Pixel Size 200,010

    @ aPosObj[1][1]+ 90,aPosGet[1,1]       Say "Numero OP"                           Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 88,aPosGet[1,1] + 32  MsGet QANT->ZPB_OP                        When .F. Of oDlg Pixel Size 200,010

    @ aPosObj[1][1]+ 110,aPosGet[1,1]       Say "Numero NF"                          Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 108,aPosGet[1,1] + 32  MsGet QANT->ZPB_NF1                      When .F. Of oDlg Pixel Size 200,010

    @ aPosObj[1][1]+ 130,aPosGet[1,1] + 122 Say "Valor (R$) "                        Of oDlg   Pixel Size 031,010
    //@ aPosObj[1][1]+ 148,aPosGet[1,1] + 32  MsGet QANT->ZPB_NF1                    When .F. Of oDlg Pixel Size 400,010

    @ aPosObj[1][1]+ 140,aPosGet[1,1]       Say cDSC_FRETE                           Of oDlg   Pixel Size 101,010

    nlinha := 140
    if nZPB_TPFRE = xFRETE_CON .or. nZPB_TPFRE = xFRETE_CIF
        nlinha += 20
        @ aPosObj[1][1] + nlinha + 0, aPosGet[1,1]       Say "Transportador"                      Of oDlg  Pixel Size 051, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 52  MsGet cZPB_TRANSP                        When .T. Of oDlg F3 "SA2" VALID sZPB_TRANSP() Pixel Size  50, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 105 MsGet cDSC_TRANSP                        When .F. Of oDlg Pixel Size  250, 010
    endif
    if nZPB_TPFRE = xFRETE_FOB
        nlinha += 20

        @ aPosObj[1][1] + nlinha + 0, aPosGet[1,1]       Say "Serviço"                            Of oDlg  Pixel Size 051, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 52  MsGet cZPB_SERFRE                        When .F. Of oDlg F3 "SB1" VALID sZPB_SERFRE() Pixel Size  50, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 105 MsGet cDSC_SERFRE                        When .F. Of oDlg Pixel Size  250, 010

        nlinha += 20
        @ aPosObj[1][1] + nlinha + 0, aPosGet[1,1]       Say "Centro Custo"                       Of oDlg  Pixel Size 051, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 52  MsGet cZPB_CC                            When .T. Of oDlg F3 "CTT" VALID sZPB_CC() Pixel Size  50, 010
        @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 105 MsGet cDSC_CC                            When .F. Of oDlg Pixel Size  250, 010
    endif

    if nZPB_TPFRE = xFRETE_CON
        nlinha += 20
        nLinhaCON := nlinha
        TSay():New(aPosObj[1][1] + nlinha + 0, aPosGet[1,1],{|| "Contrato/Revisão" },oDlg,,,.F.,.F.,.F.,.T.,,,51,008)
        oComboContrato := TComboBox():New(aPosObj[1][1] + nlinha + 0, aPosGet[1,1] + 52,{|u|if(PCount()>0,cComboContrato:=u,cComboContrato)}, aCNC_CONTRATO,100, 010,oDlg,,,,,,.T.,,,,,,,,,'cComboContrato')
    endif

    nlinha += 20
    @ aPosObj[1][1] + nlinha + 0, aPosGet[1,1]       Say "Fornecedor Reparo"                  Of oDlg  Pixel Size 051, 010
    @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 52  MsGet cZPB_FORNEC                        When .T. Of oDlg F3 "SA2" VALID sZPB_FORNEC() Pixel Size  50, 010
    @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 105 MsGet cDSC_FORNEC                        When .F. Of oDlg Pixel Size  250, 010

    nlinha += 20
    @ aPosObj[1][1] + nlinha + 0, aPosGet[1,1]       Say "Data Necessidade "                  Of oDlg  Pixel Size 051, 010
    @ aPosObj[1][1] + nlinha - 2, aPosGet[1,1] + 52  MsGet dZPB_DTNECE                        When .T. Of oDlg Picture "@D"  VALID sZPB_DTNECE() Pixel Size  50, 010

    nlinha += 20
    TButton():New(aPosObj[1][1] + nlinha, aPosGet[1,1],     OemToAnsi("&Ok")                      ,oDlg,{|| nClick := 1, iif(sZPB_GRINI(), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(aPosObj[1][1] + nlinha, aPosGet[1,1] + 52,OemToAnsi("&Cancelar")                ,oDlg,{|| nClick := 0, oDlg:End()}    ,045, 010,,,,.T.,,,,{|| })

    oDlg:Activate(,,,.T.)

    If nClick == 1
        oGrid:Refresh()
    EndIf

return

Static Function sCONTRATO
    if nZPB_TPFRE <> xFRETE_CON .or. cTranspAux = cZPB_TRANSP
        return
    endif

    cTranspAux := cZPB_TRANSP

    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQuery := " select CNC_NUMERO, CNC_REVISA "
    cQuery += " from " + RetSqlName("CNC")
    cQuery += " where CNC_CODIGO = '" + cZPB_TRANSP + "'"
    cQuery += " order by CNC_NUMERO, CNC_REVISA "

    cQuery := UPPER(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    QRY->(dbGoTop())

    aCNC_CONTRATO := {}

    While QRY->(!Eof())
        AAdd(aCNC_CONTRATO,QRY->CNC_NUMERO + '/' + QRY->CNC_REVISA)
        QRY->(dbSkip())
    enddo

    if len(aCNC_CONTRATO) = 0
        AAdd(aCNC_CONTRATO,"")
    endif

    cComboContrato:= aCNC_CONTRATO[1]
    oComboContrato := TComboBox():New(aPosObj[1][1] + nLinhaCON, aPosGet[1,1] + 52 ,{|u|if(PCount()>0,cComboContrato:=u,cComboContrato)}, aCNC_CONTRATO,100,010,oDlg,,,,,,.T.,,,,,,,,,'cComboContrato')

return


Static Function sZPB_TRANSP()
    cQuery := " Select A2_NOME, A2_MSBLQL"
    cQuery += " from " + RetSqlName ("SA2")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "
    cQuery += "   and A2_COD =  '" + cZPB_TRANSP + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->A2_NOME)
        MsgStop("Transportador(Fornecedor) não cadastrado.")
        cDSC_TRANSP := ""
        return .F.
    elseif QRY->A2_MSBLQL = '1'
        MsgStop("Transportador(Fornecedor) bloqueado.")
        cDSC_TRANSP := QRY->A2_NOME
        return .F.
    else
        cDSC_TRANSP := QRY->A2_NOME
    endif

    // Popula a lista de contratos do fornecedor
    sCONTRATO()

return .T.

Static Function sZPB_SERFRE()
    cQuery := " Select B1_DESC "
    cQuery += " from " + RetSqlName ("SB1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B1_FILIAL =  '" + xFilial("SB1") + "' "
    cQuery += "   and B1_COD =  '" + cZPB_SERFRE + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->B1_DESC)
        MsgStop("Serviço não cadastrado.")
        return .F.
        cDSC_SERFRE := ""
    else
        cDSC_SERFRE := QRY->B1_DESC
    endif

return .T.

Static Function sZPB_FORNEC()
    cQuery := " Select A2_NOME, A2_MSBLQL"
    cQuery += " from " + RetSqlName ("SA2")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "
    cQuery += "   and A2_COD =  '" + cZPB_FORNEC + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->A2_NOME)
        MsgStop("Fornecedor não cadastrado.")
        cDSC_FORNEC := ""
        return .F.
    elseif QRY->A2_MSBLQL = '1'
        MsgStop("Fornecedor bloqueado.")
        cDSC_FORNEC := QRY->A2_NOME
        return .F.
    else
        cDSC_FORNEC := QRY->A2_NOME
    endif

return .T.


Static Function sZPB_CC()
    cQuery := " Select CTT_CUSTO, CTT_DESC01, CTT_BLOQ "
    cQuery += " from " + RetSqlName ("CTT")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and CTT_FILIAL =  '" + xFilial("CTT") + "' "
    cQuery += "   and CTT_CUSTO =  '" + cZPB_CC + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->CTT_CUSTO)
        MsgStop("Centro de Custo não cadastrado.")
        cDSC_CC := ""
        return .F.
    elseif QRY->CTT_BLOQ = '1'
        MsgStop("Centro de Custo bloqueado.")
        cDSC_CC := QRY->CTT_DESC01
        return .F.
    else
        cDSC_CC := QRY->CTT_DESC01
    endif

return .T.

Static Function sZPB_DTNECE()
    if dZPB_DTNECE <= DATE() .and. !empty(dZPB_DTNECE)
        MsgStop("Data de necessidade deve ser maior que data atual do sistema.")
        return .F.
    endif

return .T.

Static Function sZPB_GRINI()
    Private cZPB_SC1FRE := ""
    Private cZPB_STATUS
    Private cCND_NUMMED := ""

    if  empty(cZPB_TRANSP) .and. nZPB_TPFRE = xFRETE_CON
        MsgStop("Transportador não informado.")
        return .F.
    endif
    if  empty(cZPB_FORNEC)
        MsgStop("Fornecedor reparo não informado.")
        return .F.
    endif
    if  empty(cZPB_SERFRE) .and. nZPB_TPFRE = xFRETE_FOB
        MsgStop("Serviço de frete não informado.")
        return .F.
    endif
    if  empty(cComboContrato) .and. nZPB_TPFRE = xFRETE_CON
        MsgStop("Contrato não informado.")
        return .F.
    endif

    if nZPB_TPFRE = xFRETE_CIF
        // envio de email para o transportador
        // envio de email para o setor de almoxarifado
        cZPB_STATUS := 'TRN'
    elseif nZPB_TPFRE = xFRETE_CON
        cCN9_CONTRA := substr(cComboContrato, 1, 15)
        cCN9_REVISA := substr(cComboContrato, 17, 3)

        cZPB_STATUS := 'APF'

        CNTA120()
        if empty(cCND_NUMMED )
            Msginfo ("Medição não foi finalizada. Favor revisar os dados.")
            return .F.
        endif

        // Incluida para garantir que não seja atualizado novamnete os dados da ZPB quando a medição foi encerrada.
        return .T.

    elseif nZPB_TPFRE = xFRETE_FOB
        cZPB_STATUS := 'APF'
        cZPB_SC1FRE := sSC1FRETE()
        if empty(cZPB_SC1FRE)
            return .F.
        endif
    else
        cZPB_STATUS := 'TRN'
    endif

    //cria o update para atualizar todos os registros processados em um unico comando
    cUpdate := " update " + retsqlname("ZPB") + " "
    cUpdate += " set ZPB_TRANSP = '" + cZPB_TRANSP + "', "
    cUpdate += "     ZPB_STATUS = '" + cZPB_STATUS + "', "
    cUpdate += "     ZPB_SC1FRE = '" + cZPB_SC1FRE + "', "
    cUpdate += "     ZPB_FORNEC = '" + cZPB_FORNEC + "', "
    cUpdate += "     ZPB_MEDFRE = '" + cCND_NUMMED + "', "
    if !empty(dZPB_DTNECE)
        cUpdate += "     ZPB_DTNECE = '" + DTOS(dZPB_DTNECE) + "', "
    endif
    cUpdate += "     ZPB_SERFRE = '" + cZPB_SERFRE + "', "
    cUpdate += "     ZPB_TPFRE  = '" + cValtoChar(nZPB_TPFRE) + "' "
    cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
    cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"

    cUpdate := UPPER(cUpdate)

    nUpdate := TcSqlExec(cUpdate)
    if nUpdate < 0
        MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
    endif

    sZPC_GRAVAR(cZPB_STATUS, "")

    if nZPB_TPFRE = xFRETE_CIF .or. nZPB_TPFRE = xFRETE_SEM
        U_WFGARCOL(ZPB->ZPB_PROC)
    endif

return .T.

Static Function sSC1FRETE()
    Local aCabec := {}
    Local aItens := {}
    Local aLinha := {}
    Local cDoc   := ""
    Local lOk    := .T.
    Private lMsHelpAuto := .T.
    PRIVATE lMsErroAuto := .F.

    cDoc := GetSXENum("SC1","C1_NUM")
    SC1->(dbSetOrder(1))
    While SC1->(dbSeek(xFilial("SC1")+cDoc))
        ConfirmSX8()
        cDoc := GetSXENum("SC1","C1_NUM")
    EndDo

    aadd(aCabec,{"C1_NUM"    , cDoc, Nil})
    aadd(aCabec,{"C1_SOLICIT", UsrFullName(AllTrim(cUsuario)), Nil})
    aadd(aCabec,{"C1_EMISSAO", dDataBase, Nil})

    aLinha := {}
    aadd(aLinha,{"C1_ITEM"     , StrZero(1, len(SC1->C1_ITEM), 0), Nil})
    aadd(aLinha,{"C1_PRODUTO"  , cZPB_SERFRE                     , Nil})
    aadd(aLinha,{"C1_QUANT"    , 1   	                         , Nil})
    aadd(aLinha,{"C1_REQUISI"  , UsrFullName(AllTrim(cUsuario))			 , Nil})
    aadd(aLinha,{"C1_CC"       , cZPB_CC             			 , Nil})

    aadd(aItens,aLinha)

    MSExecAuto({|X,Y,Z| Mata110(X,Y,Z)}, aCabec, aItens, 3)

    If !lMsErroAuto
        MsgInfo("Solicitação de Compra [" + cDoc + "] incluída com sucesso! ")
        ConfirmSX8()
    Else
        MostraErro()
        RollBackSX8()
        cDoc := ""
    EndIf

Return cDoc


Static Function S0402REM()

    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Remessa de Produto para Reparo/Garantia'
    Local cZPB_PRODUT
    Private oDlg  := Nil
    Private nZPB_VALOR
    Private cZPB_OP := ''

    if ZPB->ZPB_STATUS <> 'TRN'
        MsgStop("Este processo de reparo/garantia não se encontra na situação: [" + cTXT_TRN + "]. Impossível realizar a retirada do produto para reparo/garantia! ")
        return
    endif

    If (ZPB->ZPB_TIPO == "G")
        cZPB_PRODUT := SubStr(Alltrim(ZPB->ZPB_PRODUT),1,rAt("G",Alltrim(ZPB->ZPB_PRODUT))-1) //Replace(ZPB->ZPB_PRODUT, 'G', "")
    Else
        cZPB_PRODUT := SubStr(Alltrim(ZPB->ZPB_PRODUT),1,rAt("R",Alltrim(ZPB->ZPB_PRODUT))-1) //Replace(cZPB_PRODUT, 'R', "")
    EndIf
    
    // Buscar o valor da ultima movimentação da SD1 para o produto
    cQuery := " select TOP 1 D1_VUNIT "
    cQuery += " from " + RetSqlName ("SD1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and D1_COD = '" + cZPB_PRODUT + "' "
    cQuery += " order by D1_EMISSAO DESC"
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    nZPB_VALOR := round(QRY->D1_VUNIT, 2)

    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,200,350,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)

    aObjects := {}

    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,270,285,265},;
        {10,40,105,140,200,234, 63,200,225,270,285,265} } )

    @ aPosObj[1][1]+ 10,aPosGet[1,1]       Say "Produto"                             Of oDlg  Pixel Size 31, 010
    @ aPosObj[1][1]+ 08,aPosGet[1,1] + 32  MsGet ZPB->ZPB_PRODUT                     When .F. Of oDlg Pixel Size  100, 010

    @ aPosObj[1][1]+ 30,aPosGet[1,1]       Say "Valor (R$)"                          Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 28,aPosGet[1,1] + 32  MsGet nZPB_VALOR                          When .T.  Picture "@E 9,999,999.99" Of oDlg Pixel Size 50,010

    TButton():New(aPosObj[1][1] + 50, aPosGet[1,1],     OemToAnsi("&Ok")      ,oDlg,{|| nClick := 1, iif(sZPB_GRREM(), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(aPosObj[1][1] + 50, aPosGet[1,1] + 52,OemToAnsi("&Cancelar"),oDlg,{|| nClick := 0, oDlg:End()}    ,045, 010,,,,.T.,,,,{|| })

    oDlg:Activate(,,,.T.)

    If nClick == 1
        oGrid:Refresh()
    EndIf

return

Static Function sZPB_GRREM()
    
    Local lReturn := .T.

    if nZPB_VALOR <= 0
        MsgStop("Não informador valor para emissao do pedido de venda/nf de remessa", "Atenção")
        return .F.
    endif

    begin Transaction
        
        cZPB_PVREM := sSC5REM()

        if empty(cZPB_PVREM)
            DisarmTransaction()
            lReturn := .F.
        endif
        
        If lReturn
            // Gera nota fiscal a partir do pedido de venda
            cZPB_NFREM := fatPedido(cZPB_PVREM)
            
            if empty(cZPB_NFREM)
                DisarmTransaction()
                lReturn := .F.
            endif

            If lReturn
                //cria o update para atualizar todos os registros processados em um unico comando
                cUpdate := " update " + retsqlname("ZPB") + " "
                cUpdate += " set ZPB_STATUS = 'AOF', "
                cUpdate += "     ZPB_PVREM = '" + cZPB_PVREM + "', ZPB_NFREM = '" + cZPB_NFREM + "', ZPB_OP = '" + cZPB_OP + "', ZPB_REMVLR = " + cValtoChar(nZPB_VALOR)
                cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
                cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"

                cUpdate := UPPER(cUpdate)

                nUpdate := TcSqlExec(cUpdate)
                
                if nUpdate < 0
                    MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                endif

                // Somente vincula o pedido de compra a OP gerada caso a origem seja um processo de reparo
                if ZPB->ZPB_TIPO = 'R'
                    cUpdate := " update " + retsqlname("SC7") + " "
                    cUpdate += " set C7_OP = '" + Alltrim(cZPB_OP) + '01001' + "'"
                    cUpdate += " where C7_FILIAL = '" + xFilial("SC7") + "'"
                    cUpdate += "   and C7_NUM = '" + ZPB->ZPB_PCFRE + "'"
                    cUpdate += "   and D_E_L_E_T_ <> '*' "

                    cUpdate := UPPER(cUpdate)

                    nUpdate := TcSqlExec(cUpdate)
                    
                    if nUpdate < 0
                        MsgStop("Não foi possível atualizar o a tabela SC7 devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                    endif

                    sZPC_GRAVAR('AOF', "Vinculada OP [" + cZPB_OP + "] ao pedido de compra de frete [" + ZPB->ZPB_PCFRE + "]")
                endif
            EndIf
        EndIf
    
    end transaction

    oGrid:Refresh()

return .T.

Static Function sZPB_FORLOJA()
    cQuery := " Select A2_LOJA "
    cQuery += " from " + RetSqlName ("SA2")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "
    cQuery += "   and A2_COD =  '" + ZPB->ZPB_FORNEC + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

return QRY->A2_LOJA

Static Function SSC5REM()
    Local cDoc       := ""
    Local nOpcX      := 0

    Local aCabec     := {}
    Local aItens     := {}
    Local aLinha     := {}


    Local lOk        := .T.

    Private lMsErroAuto    := .F.

    cDoc := GetSXENum("SC5","C5_NUM")
    SC5->(dbSetOrder(1))
    While SC5->(dbSeek(xFilial("SC5")+cDoc))
        ConfirmSX8()
        cDoc := GetSXENum("SC5","C5_NUM")
    EndDo

    cTESREM := GETMV('TCP_TESREM')
    if ZPB->ZPB_TIPO = 'G'
        cZPB_LOCAL   := GETMV('TCP_ARMGAR')
        cZPB_ENDEREC := GETMV('TCP_GARLOC')
    else
        cZPB_LOCAL   := GETMV('TCP_ARMREP')
        cZPB_ENDEREC := GETMV('TCP_REPLOC')
    endif

    aCabec   := {}
    aItens   := {}
    aLinha   := {}
    aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
    aadd(aCabec, {"C5_TIPO",    "B",       Nil})
    aadd(aCabec, {"C5_CLIENTE", ZPB->ZPB_FORNEC,    Nil})
    aadd(aCabec, {"C5_LOJACLI", sZPB_FORLOJA(),   Nil})
    aadd(aCabec, {"C5_CONDPAG", '000', Nil})

    // Ajustar o valor a duas casas decimais
    nZPB_VALOR := round(nZPB_VALOR, 2)
    //--- Informando os dados do item do Pedido de Venda
    aLinha := {}
    aadd(aLinha,{"C6_ITEM",    StrZero(1,2)   , Nil})
    aadd(aLinha,{"C6_PRODUTO", ZPB->ZPB_PRODUT, Nil})
    aadd(aLinha,{"C6_QTDVEN",  1,             Nil})
    //aadd(aLinha,{"C6_QTDLIB",  1,             Nil})
    aadd(aLinha,{"C6_PRCVEN",  nZPB_VALOR,          Nil})
    aadd(aLinha,{"C6_PRUNIT",  nZPB_VALOR,          Nil})
    aadd(aLinha,{"C6_VALOR",   nZPB_VALOR,          Nil})
    aadd(aLinha,{"C6_LOCAL",   cZPB_LOCAL,          Nil})
    //aadd(aLinha,{"C6_LOCALIZ", cZPB_ENDEREC,        Nil})
    aadd(aLinha,{"C6_TES",     cTESREM,             Nil})
    aadd(aLinha,{"C6_LOTECTL", ZPB->ZPB_LOTE,       Nil})
    aadd(aLinha,{"C6_NUMSERI", ZPB->ZPB_SERIE,      Nil})
    aadd(aLinha,{"C6_GERAOP",  '1',        Nil})
    aadd(aItens, aLinha)

    nOpcX := 3
    MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
    If !lMsErroAuto
        MsgInfo("Pedido de Venda de Transporte [" + cDoc + "] incluido com sucesso! ")
        sZPC_GRAVAR('AOF', "Gerado Pedido de Venda de Transporte [" + cDoc + "]")
        sZPC_GRAVAR('AOF', "Gerada Ordem de Produção [" + cZPB_OP + "]")
    Else
        MostraErro()
        cDoc := ""
    EndIf

Return cDoc

static Function fatPedido(nNumPed)

    Local aPvlNfs:={}
    Local cNota  := ''
    Local cSerie := GETMV('TCP_SERREM')

    Private lMsErroAuto    := .F.

    dbSelectArea("SC5")
    SC5->(dbSetOrder(1))
    SC5->(DBSeek(xFilial('SC5')+nNumPed))

    dbSelectArea("SC6")
    SC6->(dbSetOrder(1))
    SC6->(DBSeek(xFilial('SC6')+nNumPed))

    While SC6->(!Eof()) .AND. SC6->C6_FILIAL = SC5->C5_FILIAL .AND. SC6->C6_NUM= SC5->C5_NUM

        dbSelectArea("SC5")
        SC5->(dbSetOrder(1))
        SC5->(DBSeek(xFilial('SC5')+nNumPed))
        RecLock("SC5")
        RecLock("SC6",.F.)

        MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.)

        SC5->(msUnlock())
        SC6->(msUnlock())

        SC6->(MaLiberOk({nNumPed},.F.))
        dbSelectArea("SC6")
        //Geracao da NF de Saida
        aadd(aPvlNfs,{SC9->C9_PEDIDO,;
            SC9->C9_ITEM,;
            SC9->C9_SEQUEN,;
            SC9->C9_QTDLIB,;
            SC9->C9_PRCVEN,;     //Informação indicando o Preço de Venda
        SC9->C9_PRODUTO,;
            SF4->F4_ISS=="S",;
            SC9->(RecNo()),;
            SC5->(RecNo()),;
            SC6->(RecNo()),;
            SE4->(RecNo()),;
            SB1->(RecNo()),;
            SB2->(RecNo()),;
            SF4->(RecNo()),;
            SC6->C6_LOCAL,;
            0,;
            SC9->C9_QTDLIB2})
		/*
					ExpA1: Array com os itens a serem gerados
					ExpC2: Serie da Nota Fiscal
					ExpL3: Mostra Lct.Contabil
					ExpL4: Aglutina Lct.Contabil
					ExpL5: Contabiliza On-Line
					ExpL6: Contabiliza Custo On-Line
					ExpL7: Reajuste de preco na nota fiscal
					ExpN8: Tipo de Acrescimo Financeiro
					ExpN9: Tipo de Arredondamento
					ExpLA: Atualiza Amarracao Cliente x Produto
					ExplB: Cupom Fiscal
					ExpCC: Numero do Embarque de Exportacao
					ExpBD: Code block para complemento de atualizacao dos titulos financeiros.*/
					
		SC6->(dbSkip())
    ENDDO
    IF(LEN(aPvlNfs) > 0)
		cNota := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .F., .F., .F., 0, 0, .F., .F.)		       
    ENDIF
	
    // Validar se a nota retornada foi efetivamente gerada com o numero de identificação da B6
    cQuerySD2 := " Select D2_IDENTB6, D2_DOC " 
    cQuerySD2 += " FROM " + RetSqlName("SD2") + " SD2 with (nolock)"
    cQuerySD2 += " WHERE D_E_L_E_T_ <> '*' "
    cQuerySD2 += "   AND D2_FILIAL = '" + xFILIAL("SD2") + "' "
    cQuerySD2 += "   AND D2_DOC = '" + cNota + "' "
    cQuerySD2 += "   AND D2_SERIE = '" + cSerie + "' "
    cQuerySD2 += "   AND D2_ITEM = '01' "
    cQuerySD2 := UPPER(cQuerySD2)
    
    If Select("QRYSD2") > 0
        QRYSD2->(dbCloseArea())
    EndIf
                
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuerySD2),"QRYSD2",.F.,.T.)                                               
    dbSelectArea("QRYSD2")
    QRYSD2->(dbGoTop())   

    IF Empty(QRYSD2->D2_DOC)
	    Msginfo('Não foi possível gerar a nota de remessa para conserto.')
        MostraErro()
	    return ""
    else
        MsgInfo("Nota Fiscal de remessa [" + cNota + "] gerada com sucesso! ")
	    sZPC_GRAVAR('AOF', "Gerada Nota Fiscal de remessa [" + cNota + "].")
    endif
	
	return cNota

Static Function S0402ITE ()
    Local aSize   := {}
    Local _lRet   := .f.  
    Local nClick  := 0
    Local cTitulo := 'Retorno por Incapacidade Técnica'          
    
    Private oDlg      := Nil
    Private cZPC_OBSERV := "" + Chr(10)+Chr(13) //Space(TamSX3('ZPC_OBSERV')[1])

    if ZPB->ZPB_STATUS <> 'AOF'
        MsgStop("Este processo de reparo/garantia não se encontra na situação [ " + cTXT_AOF + "]. Impossível iniciar processo de reparo/garantia! ") 
        return
    endif
        
    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,250,520,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)
    
    aObjects := {}  
    
    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }
                                                                                                      
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
            {{10,40,105,140,200,234,275,200,225,270,285,265},;
             {10,40,105,140,200,234, 63,200,225,270,285,265} } ) 
             
    @ aPosObj[1][1]+ 10,aPosGet[1,1] Say "Observação"                             Of oDlg  Pixel Size 031, 010       
    @ aPosObj[1][1]+ 18,aPosGet[1,1] Get oMemo Var cZPC_Observ Memo 		      Size 200, 80 Of oDlg Pixel
    
    TButton():New(oDlg:nClientHeight/2-30,aPosGet[1,1],OemToAnsi("&Ok")         , oDlg,{|| nClick := 1, iif(sZPB_GRITE(), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(oDlg:nClientHeight/2-30,aPosGet[1,1]+52,OemToAnsi("&Cancelar"), oDlg,{||Dlg:End()}    ,045, 010,,,,.T.,,,,{|| })
    
    oDlg:Activate(,,,.T.)
 
    If nClick == 1
     	oGrid:Refresh()
    EndIf
       
    return


Static Function sZPB_GRITE()
    
    if empty(cZPC_Observ)
        MsgStop("Não foi informada observação. Impossível realizar atualização no processo de garantia/reparo.","Atenção")
        return .F.
    endif
    //cria o update para atualizar todos os registros processados em um unico comando
    cUpdate := " update " + retsqlname("ZPB") + " "   
    cUpdate += " set ZPB_STATUS = 'ITE' "
    cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
    cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"
    
    cUpdate := UPPER(cUpdate)
    
    nUpdate := TcSqlExec(cUpdate)
    if nUpdate < 0
         MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
         return .F.
    endif
    
    sZPC_GRAVAR('ITE', cZPC_OBSERV)
    
return .T.
 

Static Function S0402ESC ()
    Local aSize   := {}
    Local _lRet   := .f.  
    Local nClick  := 0
    Local cTitulo := 'Retorno por Equipamento Sem Conserto'          
    
    Private oDlg      := Nil
    Private cZPC_OBSERV := "" + Chr(10)+Chr(13) //Space(TamSX3('ZPC_OBSERV')[1])

    if ZPB->ZPB_STATUS <> 'AOF'
        MsgStop("Este processo de reparo/garantia não se encontra na situação [ " + cTXT_AOF + "]. Impossível iniciar processo de reparo/garantia! ") 
        return
    endif
        
    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,250,520,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)
    
    aObjects := {}  
    
    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }
                                                                                                      
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
            {{10,40,105,140,200,234,275,200,225,270,285,265},;
             {10,40,105,140,200,234, 63,200,225,270,285,265} } ) 
             
    @ aPosObj[1][1]+ 10,aPosGet[1,1] Say "Observação"                             Of oDlg  Pixel Size 031, 010       
    @ aPosObj[1][1]+ 18,aPosGet[1,1] Get oMemo Var cZPC_Observ Memo 		      Size 200, 80 Of oDlg Pixel
    
    TButton():New(oDlg:nClientHeight/2-30,aPosGet[1,1],OemToAnsi("&Ok")         , oDlg,{|| nClick := 1, iif(sZPB_GRESC(), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(oDlg:nClientHeight/2-30,aPosGet[1,1]+52,OemToAnsi("&Cancelar"), oDlg,{||Dlg:End()}    ,045, 010,,,,.T.,,,,{|| })
    
    oDlg:Activate(,,,.T.)
 
    If nClick == 1
     	oGrid:Refresh()
    EndIf
       
    return

Static Function sZPB_GRESC()
    if empty(cZPC_Observ)
        MsgStop("Não foi informada observação. Impossivel realizar atualização no processo de garantia/reparo.","Atenção")
        return .F.
    endif
    //cria o update para atualizar todos os registros processados em um unico comando
    cUpdate := " update " + retsqlname("ZPB") + " "   
    cUpdate += " set ZPB_STATUS = 'ESC' "
    cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
    cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"
    
    cUpdate := UPPER(cUpdate)
    
    nUpdate := TcSqlExec(cUpdate)
    if nUpdate < 0
         MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
         return .F.
    endif
    
    sZPC_GRAVAR('ESC', cZPC_OBSERV)
    
    return .T.
       

Static Function S0402ORC()
    
    Local aNoFields := {"ZPD_FILIAL","ZPD_PROC"}
    Local _nX
    Local lReturn   := .T.
    Private aCols   := {}
    Private aHeader := {}
    Private cZPB_SC1
    Private cZPB_SC7
    Private cZPB_CONDPG := Space(TamSX3('ZPB_CONDPG')[1])
    Private cZPB_PCOBS :=  "" + Chr(10)+Chr(13)
    Private cDSC_CONDPG 
    Private cC7_TPFRETE
    Private nC7_VALFRE := 0
    Private cComboFrete
    Private  lComItens := .F.
        
    if ZPB->ZPB_STATUS <> 'AOF'
        MsgStop("Este processo de reparo/garantia não se encontra na situação [ " + cTXT_AOF + "]. Impossível iniciar processo de reparo/garantia! ") 
        return( .F. )
    endif
    
    cQuery := " Select ZPD.*, ZPD.R_E_C_N_O_ ZPD_RECNO "
    cQuery += " From " + RetSqlName("ZPD") + " ZPD "
    cQuery += " Where ZPD.ZPD_FILIAL='" + xFilial("ZPD") + "'"
    cQuery += "   and ZPD.ZPD_PROC = '" + ZPB->ZPB_PROC + "'"
    cQuery += "   and ZPD.D_E_L_E_T_ <> '*' "
    cQuery += " Order By ZPD_PRODUT"
    
    cQuery := ChangeQuery(cQuery)

    dbSelectArea("ZPD")
    dbCloseArea()

    cSeek  := xFilial("ZPD") + ZPB->ZPB_PROC
    cWhile := "ZPD->ZPD_FILIAL + ZPB->ZPB_PROD"
    
    _lRet := sZPDTAB('N', aNoFields,cSeek,cWhile,"ZPD","ZPD_PRODUT", ,"Orçamento")

    If !_lRet
        return()
    endif
    
    Begin Transaction
        
        nZPD_PRODUT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_PRODUT"  })
        nZPD_QUANT    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_QUANT"  })
        nZPD_UNITAR   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_UNITAR"  })
        nZPD_TES      := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_TES"  })
        nZPD_XCAPEX   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_XCAPEX"  })
        nZPD_CC       := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CC"  })
        nZPD_NATURE   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_NATURE"  })
        nZPD_GARANT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_GARANT"  })
        nZPD_TMPGAR   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_TMPGAR"  })
        nZPD_DESCGA   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_DESCGA"  })
        nZPD_PRAZO    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_PRAZO"  })
        nZPD_CONTA    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CONTA"  })
        nZPD_ITEMCT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_ITEMCT"  })
        nZPD_CONTRA   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CONTRA"  })
        
        For _nX := 1 To Len(aCols)
        
          nUltimaColuna := len(aCols[1])
        
            Do Case
            Case !Empty(aCols[_nX][1]) .and. !Empty(aCols[_nX][nUltimaColuna - 1]) .And. !aCols[_nX][nUltimaColuna]   //Já existia e não foi deletado, altero os dados
              ZPD->(dbGoTo(aCols[_nX][nUltimaColuna - 1]))
              RecLock("ZPD",.f.)   
              ZPD->ZPD_FILIAL := xFilial("ZPD")
              ZPD->ZPD_PROC := ZPB->ZPB_PROC
              ZPD->ZPD_PRODUT := aCols[_nx][nZPD_PRODUT]
              ZPD->ZPD_QUANT  := aCols[_nx][nZPD_QUANT]
              ZPD->ZPD_UNITAR := aCols[_nx][nZPD_UNITAR]
              ZPD->ZPD_TES	  := aCols[_nx][nZPD_TES]
              ZPD->ZPD_XCAPEX := aCols[_nx][nZPD_XCAPEX]	
              ZPD->ZPD_CC	  := aCols[_nx][nZPD_CC]
              ZPD->ZPD_NATURE := aCols[_nx][nZPD_NATURE]
              ZPD->ZPD_GARANT := aCols[_nx][nZPD_GARANT]	
              ZPD->ZPD_TMPGAR := aCols[_nx][nZPD_TMPGAR]
              ZPD->ZPD_DESCGA := aCols[_nx][nZPD_DESCGA]	
              ZPD->ZPD_PRAZO  := aCols[_nx][nZPD_PRAZO]
              ZPD->ZPD_CONTA  := aCols[_nx][nZPD_CONTA]
              ZPD->ZPD_ITEMCT := aCols[_nx][nZPD_ITEMCT]
              ZPD->ZPD_CONTRA := aCols[_nx][nZPD_CONTRA]
              
              ZPD->(MsUnLock())
            Case !Empty(aCols[_nX][nUltimaColuna - 1]) .And. aCols[_nX][nUltimaColuna]    //Já existia e foi deletado, excluo o registro
              ZPD->(dbGoTo(aCols[_nX][nUltimaColuna - 1]))
              RecLock("ZPD",.f.)   
              ZPD->(dbDelete())
              ZPD->(MsUnLock())
            Case !Empty(aCols[_nX][1]) .and. Empty(aCols[_nX][nUltimaColuna - 1]) .And. !aCols[_nX][nUltimaColuna]    //Não existia e não está deletado, incluo o novo registro
              RecLock("ZPD",.t.)    
              ZPD->ZPD_FILIAL := xFilial("ZPD")
              ZPD->ZPD_PROC := ZPB->ZPB_PROC
              ZPD->ZPD_PRODUT := aCols[_nx][nZPD_PRODUT]
              ZPD->ZPD_QUANT  := aCols[_nx][nZPD_QUANT]
              ZPD->ZPD_UNITAR := aCols[_nx][nZPD_UNITAR]
              ZPD->ZPD_TES	  := aCols[_nx][nZPD_TES]
              ZPD->ZPD_XCAPEX := aCols[_nx][nZPD_XCAPEX]	
              ZPD->ZPD_CC	  := aCols[_nx][nZPD_CC]
              ZPD->ZPD_NATURE := aCols[_nx][nZPD_NATURE]
              ZPD->ZPD_GARANT := aCols[_nx][nZPD_GARANT]	
              ZPD->ZPD_TMPGAR := aCols[_nx][nZPD_TMPGAR]
              ZPD->ZPD_DESCGA := aCols[_nx][nZPD_DESCGA]	
              ZPD->ZPD_PRAZO  := aCols[_nx][nZPD_PRAZO]
              ZPD->ZPD_CONTA  := aCols[_nx][nZPD_CONTA]
              ZPD->ZPD_ITEMCT := aCols[_nx][nZPD_ITEMCT]
              ZPD->ZPD_CONTRA := aCols[_nx][nZPD_CONTRA]
              ZPD->(MsUnLock())
            EndCase
    
        Next _nX
    
    End Transaction
        
    if empty(cComboFrete)
        cC7_TPFRETE := "C" 
    else
        cC7_TPFRETE := substr(cComboFrete, 1, 1) 
    endif
    
    Begin Transaction
        
        if lComItens
	        cZPB_SC1 := sSC1ORCAM()
            if empty(cZPB_SC1)
	           DisarmTransaction()
	           lReturn := .F. 
            endif
            If lReturn
                cZPB_SC7 := sSC7ORCAM()
                if empty(cZPB_SC7)
                    DisarmTransaction()
                    lReturn := .F.  
                endif
            EndIf
        endif

	       
        If lReturn
            if !empty(cZPB_SC7) .or. !lComItens
                cUpdate := " update " + retsqlname("ZPB") + " "   
                if !lComItens
                    cUpdate += " set ZPB_STATUS = 'ARP', "
                else
                    cUpdate += " set ZPB_STATUS = 'APC', "
                    cUpdate += "     ZPB_SC1 = '" + cZPB_SC1 + "', "
                    cUpdate += "     ZPB_SC7 = '" + cZPB_SC7 + "', " 
                endif
                cUpdate += "      ZPB_CONDPG = '" + cZPB_CONDPG + "'"
                cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
                cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"
            
                cUpdate := UPPER(cUpdate)
                
                nUpdate := TcSqlExec(cUpdate)
                
                if nUpdate < 0
                    MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                    lReturn := .F.
                endif

                If lReturn
                    Reclock("ZPB", .F.)   
                    ZPB->ZPB_PCOBS := cZPB_PCOBS
                    ZPB->(MsUnLock()) 
                
                    sZPC_GRAVAR('APC', 'Orçamento do fornecedor encaminhado para aprovação através do pedido de compra.')
                EndIf
            endif
        EndIf
    
    End Transaction
    
    oGrid:Refresh()
        
Return( lReturn )

/*
Programa  : A9721TAB
Autor     : Elias Ricardo Kuchak
Data      : 07/08/16
Desc.     : Tela de manipulação dos requisitos do grupo
Uso       ³ CR97A210
*/
Static Function sZPDTAB(cVisualizacao, aNoFields,cSeek,cWhile,cAlias,cItem,cIncremental,cTitulo)
    Local aSize   := {}
    Local _lRet   := .f.
    Local bOk   :=   {|| _lRet := .T., iif(sZPD_TUDOOK(), oDlg:End(), "")}
    Local bCancel := {|| _lRet := .f., iIf(MsgYesNo("Deseja Sair sem gravar ?","Atenção!!!"),oDlg:End(),"")}
    Local i
    Local aC7_TPFRETE := {"CIF", "FOB"}

    // Sintaxe
    // FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
    FillGetDados(4,cAlias,1,cSeek,{|| &cWhile },,aNoFields,,,cQuery,,,,,,,,cAlias)

    aSize := MsAdvSize(.F.)

    Define MsDialog oDlg Title cTitulo Style DS_MODALFRAME From aSize[7], 0 To aSize[6], aSize[5] OF oMainWnd PIXEL

    aObjects := {}
    AAdd( aObjects, {  50, 120, .T., .F. } )
    AAdd( aObjects, { 120, 200, .T., .T. } )
    AAdd( aObjects, {   0,  50, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,260,285,265},;
        {10,40,105,140,200,234, 63,200,225,260,285,265} } )

    // Definicao dos MsGETS do Cabecalho ³

    @ aPosObj[1][1],aPosObj[1][2] To aPosObj[1][3],aPosObj[1][4] Label '' Of oDlg Pixel

    @ aPosObj[1][1]+30,aPosGet[1,1]      Say "Processo"                             Of oDlg   Pixel Size 031,006
    @ aPosObj[1][1]+29,aPosGet[1,1] + 45 MsGet ZPB->ZPB_PROC                        When .F. Of oDlg  Pixel Size 30,006

    @ aPosObj[1][1]+42,aPosGet[2,1]      Say "Condição Pgto"                        Of oDlg   Pixel Size 030,006
    @ aPosObj[1][1]+41,aPosGet[2,1] + 45 MsGet cZPB_CONDPG                          When .T. F3 "SE4" Valid sZPB_CONDPG() Size 35,006 Pixel  Of oDlg
    @ aPosObj[1][1]+41,aPosGet[2,1] + 82 MsGet cDSC_CONDPG                          When .F. Size 263, 006 Pixel  Of oDlg

    @ aPosObj[1][1]+54,aPosGet[1,1]      Say "Observação PC"                        Of oDlg  Pixel Size 040, 010
    @ aPosObj[1][1]+53,aPosGet[1,1] + 45 Get oMemo Var cZPB_PCOBS  Memo 		    Size 300, 40 Of oDlg Pixel

    TSay():New(aPosObj[1][1]+ 95, aPosGet[1,1], {|| "Tipo Frete" },oDlg,,,.F.,.F.,.F.,.T.,,,200,008)
    cComboFrete:= aC7_TPFRETE[1]
    TComboBox():New(aPosObj[1][1]+95, aPosGet[1,1] + 45,{|u|if(PCount()>0,cComboFrete:=u,cComboFrete)}, aC7_TPFRETE,50,10,oDlg,, ,,,,.T.,,,,,,,,,'cComboFrete')

    @ aPosObj[1][1]+ 107,aPosGet[1,1]       Say "Valor Frete (R$)"                    Of oDlg   Pixel Size 044,010
    @ aPosObj[1][1]+ 106,aPosGet[1,1] + 45  MsGet nC7_VALFRE                          When .T.  Picture "@E 9,999,999.99" Of oDlg Pixel Size 50,010

    // Criacao da Area da MsGetDados dos produtos


    //      MsNewGetDados():New ([ nTop]       , [ nLeft]    , [ nBottom]  , [ nRight ]  ,    [ nStyle]                         ,      [ cLinhaOk],        [ cTudoOk], [ cIniCpos], [ aAlter], [ nFreeze], [ nMax], [ cFieldOk], [ cSuperDel],[ cDelOk]        , [oWnd], [ aPartHeader], [ aParCols], [ uChange], [ cTela] )
    oGetd:= MsNewGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], GD_INSERT+GD_DELETE+GD_UPDATE,,  ,            ,          ,           ,     49, , , ,oDlg, aHeader, aCols)

    x := len(oGetd:aCols) + 1
    for i := x to 49
        oGetd:AddLine (.F.,.F.)
        oGetd:aCols[i, 1] := space(TamSx3("ZPD_PRODUT")[1])
        oGetd:aCols[i, 2] := space(TamSx3("ZPD_QUANT")[1])
        oGetd:aCols[i, 2] := space(TamSx3("ZPD_UNITAR")[1])
    next

    oGetd:lEditLine := .T.

    Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk , bCancel) Centered

    // Atualiza a aCols com os dados privados do objeto criado a partir da MsNewGetDados
    aCols:=oGetd:aCols
    aHeader:=oGetd:aHeader
Return _lRet

Static Function sZPB_CONDPG()
    cQuery := " Select E4_DESCRI "
    cQuery += " from " + RetSqlName ("SE4")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and E4_CODIGO =  '" + cZPB_CONDPG + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->E4_DESCRI) .and. !empty(cZPB_CONDPG)
        MsgStop("Condição de Pagamento não cadastrada.")
        return .F.
        cDSC_CONDPG := ""
    else
        cDSC_CONDPG := QRY->E4_DESCRI
    endif

return .T.

User Function ZPD_PRODUT()
    cQuery := " Select B1_DESC "
    cQuery += " from " + RetSqlName ("SB1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B1_COD =  '" + M->ZPB_PRODUT + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if empty(QRY->B1_DESC)
        MsgStop("Produto/Serviço não cadastrado.")
        return .F.
    endif

return .T.

User Function ZPD_PDSC()
    cQuery := " Select B1_DESC "
    cQuery += " from " + RetSqlName ("SB1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B1_COD =  '" + M->ZPD_PRODUT + "' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

return QRY->B1_DESC

Static function sZPD_TUDOOK()
    Local cRetorno := ""
    Local _nX
    lComItens := .F.

    nZPD_PRODUT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_PRODUT"  })
    nZPD_QUANT    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_QUANT"  })
    nZPD_UNITAR   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_UNITAR"  })
    nZPD_TES      := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_TES"  })
    nZPD_XCAPEX   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_XCAPEX"  })
    nZPD_CC       := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CC"  })
    nZPD_NATURE   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_NATURE"  })
    nZPD_GARANT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_GARANT"  })
    nZPD_TMPGAR   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_TMPGAR"  })
    nZPD_DESCGA   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_DESCGA"  })
    nZPD_PRAZO    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_PRAZO"  })
    nZPD_CONTA    := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CONTA"  })
    nZPD_ITEMCT   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_ITEMCT"  })
    nZPD_CONTRA   := aScan(aHeader,{|x| AllTrim(x[2]) == "ZPD_CONTRA"  })

    aCols:=oGetd:aCols

    For _nX := 1 To Len(aCols)
        nUltimaColuna := len(aCols[1])
        if  !aCols[_nX][nUltimaColuna] // Verifica se linha não está deletada
            if !Empty(aCols[_nX][nZPD_PRODUT]) .or. !empty(aCols [_nx][nZPD_QUANT]) .or. !empty(aCols [_nx][nZPD_UNITAR])
                lComItens := .T.
                if empty(aCols[_nX][nZPD_PRODUT]) .or. empty(aCols [_nx][nZPD_QUANT]) .or. empty(aCols [_nx][nZPD_UNITAR])
                    cRetorno += "Dados inconsistentes na linha: " + cvaltochar(_nx) + Chr(13) + Chr(10)
                endif
            endif
        endif
    next _nx

    For _nX := 1 To Len(aCols)
        nUltimaColuna := len(aCols[1])
        if  !aCols[_nX][nUltimaColuna] // Verifica se linha não está deletada
            if aCols[_nX][nZPD_GARANT] = '1' .and. (empty(aCols [_nx][nZPD_TMPGAR]) .or. empty(aCols [_nx][nZPD_DESCGA]))
                cRetorno += "Dados de garantia inconsistentes na linha: " + cvaltochar(_nx) + Chr(13) + Chr(10)
            endif
            if aCols[_nX][nZPD_GARANT] <> '1' .and. (!empty(aCols [_nx][nZPD_TMPGAR]) .or. !empty(aCols [_nx][nZPD_DESCGA]))
                cRetorno += "Dados de garantia inconsistentes na linha: " + cvaltochar(_nx) + Chr(13) + Chr(10)
            endif
        endif
    next _nx

    if !lComItens .and. ZPB->ZPB_TIPO = 'R'
        cRetorno += "Não informado serviço/produto no orçamento de reparo" + Chr(13) + Chr(10)
    endif

    if Empty(cZPB_CONDPG) .and. lComItens
        cRetorno += "Favor informar a Forma de Pagamento" + Chr(13) + Chr(10)
    endif

    if !lComItens .and. ZPB->ZPB_TIPO = 'G'
        if !MsgYesNo("Este processo de garantia não possui itens orçados. Deseja continuar com o processo de garantia? ", "Atenção")
            return .F.
        endif
    endif

    if empty(cRetorno)
        return .T.
    else
        MsgInfo(cRetorno,"Retorno")
        return .F.
    endif


Static Function sSC1ORCAM()
    Local aCabec := {}
    Local aItens := {}
    Local aLinha := {}
    Local cDoc   := ""
    Local lOk    := .T.
    Private lMsHelpAuto := .T.
    PRIVATE lMsErroAuto := .F.

    cDoc := GetSXENum("SC1","C1_NUM")
    SC1->(dbSetOrder(1))
    While SC1->(dbSeek(xFilial("SC1")+cDoc))
        ConfirmSX8()
        cDoc := GetSXENum("SC1","C1_NUM")
    EndDo

    aadd(aCabec,{"C1_NUM"    , cDoc, Nil})
    aadd(aCabec,{"C1_SOLICIT", UsrFullName(AllTrim(cUsuario)), Nil})
    aadd(aCabec,{"C1_EMISSAO", dDataBase, Nil})


    cQuery := " Select * "
    cQuery += " FROM " + RetSqlName("ZPD") + " ZPD with (nolock)"
    cQuery += " WHERE ZPD.D_E_L_E_T_ <> '*' "
    cQuery += "   AND ZPD_FILIAL = '" + xFILIAL("ZPD") + "' "
    cQuery += "   AND ZPD_PROC = '" + ZPB->ZPB_PROC + "' "
    cQuery += " ORDER BY ZPD_PRODUT "

    cQuery := UPPER(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    nItem := 0
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    QRY->(dbGoTop())
    While QRY->(!Eof())
        aLinha := {}
        nItem++
        aadd(aLinha,{"C1_ITEM"     , StrZero(nItem, len(SC1->C1_ITEM), 0), Nil})
        aadd(aLinha,{"C1_PRODUTO"  , QRY->ZPD_PRODUT                     , Nil})
        aadd(aLinha,{"C1_QUANT"    , QRY->ZPD_QUANT                      , Nil})
        aadd(aLinha,{"C1_REQUISI"  , UsrRetName(cUsuario)    			 , Nil})
        aadd(aLinha,{"C1_FORNECE"  , ZPB->ZPB_FORNEC                     , Nil})
        aadd(aLinha,{"C1_LOJA"     , sZPB_FORLOJA()                      , Nil})
        if ZPB->ZPB_TIPO = 'R'
            aadd(aLinha,{"C1_OP"       , AllTrim(ZPB->ZPB_OP)+'01001'        , Nil})
        endif

        aadd(aItens,aLinha)
        QRY->(dbSkip())
    EndDo

    MSExecAuto({|X,Y,Z| Mata110(X,Y,Z)}, aCabec, aItens, 3)

    If !lMsErroAuto
        MsgInfo("Solicitação de Compra [" + cDoc + "] incluída com sucesso! ")
        sZPC_GRAVAR('APC', "Gerada Solicitação de Compra [" + cDoc + "].")
        ConfirmSX8()
    Else
        MostraErro()
        RollBackSX8()
        cDoc := ""
    EndIf

Return cDoc

Static Function sSC7ORCAM()
    Local aCabec := {}
    Local aItens := {}
    Local aLinha := {}
    Local cDoc := ""
    Local lOk := .T.
    Local _xi := 0

    PRIVATE lMsErroAuto := .F.

    dbSelectArea("SC7")
    dbSetOrder(1)
    MsSeek(xFilial("SC7")+"zzzzzz",.T.)
    dbSkip(-1)

    cDoc := SC7->C7_NUM

    If Empty(cDoc)
        cDoc := StrZero(1,Len(SC7->C7_NUM))
    Else
        cDoc := Soma1(cDoc)
    EndIf

    aadd(aCabec,{"C7_NUM" ,cDoc})
    aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
    aadd(aCabec,{"C7_FORNECE" ,ZPB->ZPB_FORNEC})
    aadd(aCabec,{"C7_LOJA" ,sZPB_FORLOJA()})
    aadd(aCabec,{"C7_COND" ,cZPB_CONDPG})
    aadd(aCabec,{"C7_TPFRETE" , cC7_TPFRETE})
    aadd(aCabec,{"C7_VALFRE" ,nC7_VALFRE})
    aadd(aCabec,{"C7_FRETE" ,nC7_VALFRE})

    cQuery := " Select * "
    cQuery += " FROM " + RetSqlName("ZPD") + " ZPD with (nolock)"
    cQuery += " WHERE ZPD.D_E_L_E_T_ <> '*' "
    cQuery += "   AND ZPD_FILIAL = '" + xFILIAL("ZPD") + "' "
    cQuery += "   AND ZPD_PROC = '" + ZPB->ZPB_PROC + "' "
    cQuery += " ORDER BY ZPD_PRODUT "

    cQuery := UPPER(cQuery)

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf

    nItem := 0
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    QRY->(dbGoTop())
    While QRY->(!Eof())
        aLinha := {}
        nItem++
        aadd(aLinha,{"C7_ITEM"    , StrZero(nItem, len(SC7->C7_ITEM), 0), Nil})
        aadd(aLinha,{"C7_PRODUTO" , QRY->ZPD_PRODUT,Nil})
        aadd(aLinha,{"C7_QUANT"   , QRY->ZPD_QUANT ,Nil})
        aadd(aLinha,{"C7_PRECO"   , QRY->ZPD_UNITAR ,Nil})
        aadd(aLinha,{"C7_TOTAL"   , Round(QRY->ZPD_QUANT * QRY->ZPD_UNITAR, 2),Nil})
        if ZPB->ZPB_TIPO = 'R'
            aadd(aLinha,{"C7_OP"      , Alltrim(ZPB->ZPB_OP)+'01001',Nil})
        endif
        aadd(aLinha,{"C7_NUMSC"   , cZPB_SC1 ,Nil})
        aadd(aLinha,{"C7_ITEMSC"  , StrZero(nItem, len(SC1->C1_ITEM), 0), Nil})
        aadd(aLinha,{"C7_QTDSOL"  , QRY->ZPD_QUANT ,Nil})
        xZPB_PCOBS := ""
        for _xi := 1 to 10
            xZPB_PCOBS += memoline(cZPB_PCOBS, 250, _xi)
        next _xi
        xZPB_PCOBS := Alltrim(xZPB_PCOBS)

        aadd(aLinha,{"C7_OBS"     , xZPB_PCOBS, Nil})
        // Novos campos na SC7
        aadd(aLinha,{"C7_TES"     , QRY->ZPD_TES ,Nil})
        aadd(aLinha,{"C7_XCAPEX"  , QRY->ZPD_XCAPEX ,Nil})
        aadd(aLinha,{"C7_CC"      , QRY->ZPD_CC ,Nil})
        aadd(aLinha,{"C7_XNATURE" , QRY->ZPD_NATURE ,Nil})
        aadd(aLinha,{"C7_XGARANT" , QRY->ZPD_GARANT ,Nil})
        aadd(aLinha,{"C7_XTMPGAR" , QRY->ZPD_TMPGAR ,Nil})
        aadd(aLinha,{"C7_XDESCGA" , QRY->ZPD_DESCGA ,Nil})
        aadd(aLinha,{"C7_PRAZO"   , QRY->ZPD_PRAZO  ,Nil})
        aadd(aLinha,{"C7_CONTA"   , QRY->ZPD_CONTA  ,Nil})
        aadd(aLinha,{"C7_ITEMCTA" , QRY->ZPD_ITEMCT ,Nil})
        aadd(aLinha,{"C7_CONTRAT" , QRY->ZPD_CONTRA ,Nil})

        aadd(aItens,aLinha)
        QRY->(dbSkip())
    EndDo

    MATA120(1,aCabec,aItens,3)

    //MSExecAuto({|v,x,y,z,w| MATA120(v,x,y,z,w)},2,aCabec,aItens,3,.F.)

    If !lMsErroAuto
        MsgInfo("Pedido de Compra [" + cDoc + "] incluído com sucesso! ")
        sZPC_GRAVAR('APC',"Gerado Pedido de Compra [" + cDoc + "].")
    Else
        MostraErro()
        cDoc := ""
    EndIf

return cDoc

Static Function s0402RET()
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Recebimento do produto/emissão de NF de retorno/Geração Pré Nota de Entrada'

    Private oDlg  := Nil
    Private cF1_DOC :=  Space(TamSX3('F1_DOC')[1])
    Private cF1_SERIE :=  Space(TamSX3('F1_SERIE')[1])
    Private dF1_EMISSAO := date()
    Private cF1_DOCRET :=  Space(TamSX3('F1_DOC')[1])
    Private cF1_SERRET :=  Space(TamSX3('F1_SERIE')[1])
    Private dF1_EMIRET := date()
    Private lNotaGar := .F.

    if ZPB->ZPB_STATUS <> 'ARP'
        MsgStop("Este processo de reparo/garantia não se encontra na situação [ " + cTXT_ARP + "]. Impossível iniciar processo de reparo/garantia! ")
        return
    endif

    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,250,550,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)

    aObjects := {}

    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
        {{10,40,105,140,200,234,275,200,225,270,285,265},;
        {10,40,105,140,200,234, 63,200,225,270,285,265} } )

    if ZPB->ZPB_TIPO = 'G'
        cQuery := " Select count(*) ZPD_COUNT "
        cQuery += " FROM " + RetSqlName("ZPD") + " ZPD with (nolock)"
        cQuery += " WHERE ZPD.D_E_L_E_T_ <> '*' "
        cQuery += "   AND ZPD_FILIAL = '" + xFILIAL("ZPD") + "' "
        cQuery += "   AND ZPD_PROC = '" + ZPB->ZPB_PROC + "' "

        cQuery := UPPER(cQuery)

        If Select("QRY") > 0
            QRY->(dbCloseArea())
        EndIf

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
        dbSelectArea("QRY")
        QRY->(dbGoTop())

        if QRY->ZPD_COUNT > 0
            lNotaGar := .T.
        endif
    endif

    if lNotaGar
        @ aPosObj[1][1]+ 05,aPosGet[1,1]   Say "Dados do Serviço/Peças"                    Of oDlg  Pixel Size 101, 010
    endif
    @ aPosObj[1][1]+ 20,aPosGet[1,1]       Say "Nota Fiscal"                        Of oDlg  Pixel Size 31, 010
    @ aPosObj[1][1]+ 18,aPosGet[1,1] + 52  MsGet cF1_DOC                            When .T. Of oDlg Pixel Size  40, 010

    @ aPosObj[1][1]+ 40,aPosGet[1,1]       Say "Serie"                              Of oDlg   Pixel Size 031,010
    @ aPosObj[1][1]+ 38,aPosGet[1,1] + 52  MsGet cF1_SERIE                          When .T.  Of oDlg Pixel Size 20,010

    @ aPosObj[1][1]+ 60, aPosGet[1,1]       Say "Data Emissao "                  	Of oDlg  Pixel Size 051, 010
    @ aPosObj[1][1]+ 58, aPosGet[1,1] + 52  MsGet dF1_EMISSAO                        When .T. Of oDlg Picture "@D"  Pixel Size  50, 010


    if lNotaGar
        @ aPosObj[1][1]+ 05,aPosGet[1,1] + 110  Say "Dados da Devolução"                    Of oDlg  Pixel Size 101, 010
        @ aPosObj[1][1]+ 20,aPosGet[1,1] + 110  Say "Nota Fiscal"                        Of oDlg  Pixel Size 48, 010
        @ aPosObj[1][1]+ 18,aPosGet[1,1] + 162  MsGet cF1_DOCRET                         When .T. Of oDlg Pixel Size  40, 010

        @ aPosObj[1][1]+ 40,aPosGet[1,1] + 110  Say "Serie"                              Of oDlg   Pixel Size 031,010
        @ aPosObj[1][1]+ 38,aPosGet[1,1] + 162  MsGet cF1_SERRET                         When .T.  Of oDlg Pixel Size 20,010

        @ aPosObj[1][1]+ 60, aPosGet[1,1] + 110  Say "Data Emissao "                  	Of oDlg  Pixel Size 051, 010
        @ aPosObj[1][1]+ 58, aPosGet[1,1] + 162  MsGet dF1_EMIRET                        When .T. Of oDlg Picture "@D"  Pixel Size  50, 010
    endif

    TButton():New(aPosObj[1][1] + 80, aPosGet[1,1],     OemToAnsi("&Ok")      ,oDlg,{|| nClick := 1, iif(sZPB_GRRET(), oDlg:End(),"")}    ,045, 010,,,,.T.,,,,{|| })
    TButton():New(aPosObj[1][1] + 80, aPosGet[1,1] + 52,OemToAnsi("&Cancelar"),oDlg,{|| nClick := 0, oDlg:End()}    ,045, 010,,,,.T.,,,,{|| })

    oDlg:Activate(,,,.T.)

    If nClick == 1
        oGrid:Refresh()
    EndIf

return

Static Function sZPB_GRRET()
    
    Local lReturn := .T.

    if empty(cF1_DOC) .or. empty(cF1_SERIE) .or. empty(dF1_EMISSAO)
        MsgInfo("Dados para geração da pre nota incompletos.")
        return .F.
    endif

    if lNotaGar
        if empty(cF1_DOCRET) .or. empty(cF1_SERRET) .or. empty(dF1_EMIRET)
            MsgInfo("Dados para geração da nota de devolução incompletos.")
            return .F.
        endif
    endif

    Begin Transaction
        
        if !sNOTARET()
            DisarmTransaction()
            lReturn := .F.
        endif
        
        If lReturn
            if lNotaGar .or. ZPB->ZPB_TIPO = 'R'
                if !sPreNota()
                    DisarmTransaction()
                    lReturn := .F.
                endif
            endif
        EndIf
        
        If lReturn
         
            if empty(cF1_DOCRET)
                cF1_DOCRET := ZPB->ZPB_NFREM
            endif
            
            // Tramento adicionando zeros ao numero da nota fiscal
            cF1_DOC :=    xF1_DOC := Padl(AllTrim(cF1_DOC), len(ZPB->ZPB_NF1), '0')

            cUpdate := " update " + retsqlname("ZPB") + " "
            cUpdate += " set ZPB_STATUS = 'PRE', ZPB_NFRET = '" + cF1_DOCRET + "', ZPB_NF1 = '" + cF1_DOC + "'"
            cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
            cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"

            cUpdate := UPPER(cUpdate)

            nUpdate := TcSqlExec(cUpdate)
            
            if nUpdate < 0
                MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                lReturn := .F.
            endif

            If lReturn
                sZPC_GRAVAR('PRE', 'Emitida NF de Devolução e Pré Nota de entrada do serviço/peças.')
            EndIf
    
        EndIf
    
    End Transaction

    Mata103()

return( lReturn )

Static Function sPreNota()

    Local nOpc := 3

    Private aCabec      := {}
    Private aItens      := {}
    Private aLinha      := {}
    Private lMsErroAuto := .F.

    cF1_DOC := Padl(AllTrim(cF1_DOC), len(ZPB->ZPB_NF1), '0')
    cF1_EST := Posicione("SA2",1,xFilial("SA2")+ZPB->ZPB_FORNEC+sZPB_FORLOJA(),"A2_EST")

    aAdd(aCabec,{'F1_FORNECE',ZPB->ZPB_FORNEC,NIL})
    aAdd(aCabec,{'F1_LOJA'   ,sZPB_FORLOJA(),NIL})
    aAdd(aCabec,{'F1_TIPO'   ,'N',NIL})
    aAdd(aCabec,{'F1_FORMUL' ,'N',NIL})
    aAdd(aCabec,{'F1_DOC'    ,cF1_DOC,NIL})
    aAdd(aCabec,{"F1_SERIE"  ,cF1_SERIE,NIL})
    aAdd(aCabec,{"F1_EMISSAO",dF1_EMISSAO,NIL})
    aAdd(aCabec,{"F1_ESPECIE","NF",NIL})
    aAdd(aCabec,{"F1_COND"   ,ZPB->ZPB_CONDPG,NIL})
    aAdd(aCabec,{"F1_EST"    ,cF1_EST,NIL})


    cQuery := " Select C7_ITEM ITEM, * "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 with (nolock)"
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND C7_FILIAL = '" + xFILIAL("SC7") + "' "
    cQuery += "   AND C7_NUM = '" + ZPB->ZPB_SC7 + "' "
    cQuery += " ORDER BY C7_ITEM "

    cQuery := UPPER(cQuery)

    If Select("QSC7") > 0
        QSC7->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QSC7",.F.,.T.)
    dbSelectArea("QSC7")
    QSC7->(dbGoTop())
    While QSC7->(!Eof())
        aLinha := {}
        aadd(aLinha,{"D1_ITEM",QSC7->ITEM,Nil})
        aadd(aLinha,{"D1_COD" ,QSC7->C7_PRODUTO,Nil})
        aadd(aLinha,{"D1_UM" ,QSC7->C7_UM ,Nil})
        aadd(aLinha,{"D1_QUANT" ,QSC7->C7_QUANT ,Nil})
        aadd(aLinha,{"D1_VUNIT" ,QSC7->C7_PRECO,Nil})
        aadd(aLinha,{"D1_TOTAL" ,QSC7->C7_TOTAL,Nil})
        aadd(aLinha,{"D1_PEDIDO",QSC7->C7_NUM ,Nil})
        aadd(aLinha,{"D1_ITEMPC",QSC7->ITEM,Nil})
        aadd(aLinha,{"D1_LOCAL",'01',Nil})
        if ZPB->ZPB_TIPO = 'R'
            aadd(aLinha,{"D1_OP"    ,AllTrim(ZPB->ZPB_OP) + '01001',Nil})
        else
            aadd(aLinha,{"D1_OP"    ,'',Nil})
        endif
        aadd(aLinha,{"D1_TES"     , QSC7->C7_TES ,Nil})
        aadd(aLinha,{"D1_CC"      , QSC7->C7_CC ,Nil})
        aadd(aLinha,{"D1_CONTA"   , QSC7->C7_CONTA  ,Nil})
        aadd(aLinha,{"D1_ITEMCTA" , QSC7->C7_ITEMCTA ,Nil})
        aadd(aLinha,{"D1_XNATURE" , QSC7->C7_XNATURE ,Nil})
        aadd(aItens,aLinha)
        QSC7->(dbSkip())
    EndDo

    // Inclui pre-nota
    If MaFisFound()
        MaFisEnd()
    Endif

    //MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aItens, nOpc,,)
    If GeraPreNF2(aCabec, aItens)
        MsgInfo("Pre Nota de Entrada [" + cF1_DOC + "] incluída com sucesso! ")
        sZPC_GRAVAR('PRE',"Gerada pré nota de entrada [" + cF1_DOC + "].")
    Else
        MostraErro()
        return .F.
    EndIf

return .T.

Static Function GeraPreNF2(xaCabec, xaItem)

    Local _aArea    := GetArea()
    Local _npTIPO   := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_TIPO"  })
    Local _npFORMUL := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_FORMUL"  })
    Local _npDOC    := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_DOC"     })
    Local _npSERIE  := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_SERIE"     })
    Local _npEMISSAO:= aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_EMISSAO"   })
    Local _npFORNECE:= aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"   })
    Local _npLOJA   := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_LOJA"    })
    Local _npESPECIE:= aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_ESPECIE"   })
    Local _npEST    := aScan(xaCabec,{|x| AllTrim(x[1]) == "F1_EST"     })

    Local _npITEM   := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_ITEM"  })
    Local _npCOD    := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_COD"    })
    Local _npUM     := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_UM"     })
    Local _npQUANT  := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_QUANT"  })
    Local _npVUNIT  := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_VUNIT"  })
    Local _npTOTAL  := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_TOTAL"  })
    Local _npLOCAL  := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_LOCAL"  })
    Local _npOP     := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_OP"  })
    Local _npPEDIDO := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_PEDIDO"  })
    Local _npITEMPC := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_ITEMPC"  })


    Local _npTES := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_TES"  })
    Local _npCC := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_CC"  })
    Local _npCONTA := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_CONTA"  })
    Local _npITEMCTA := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_ITEMCTA"  })
    Local _npXNATURE := aScan(xaItem[1],{|x| AllTrim(x[1]) == "D1_XNATURE"  })

    Local _lRet := .T.
    Local i
    dbSelectArea("SF1")
    dbSetOrder(1)
    If !dbSeek(xFilial("SF1")+xaCabec[_npDOC][2]+xaCabec[_npSERIE][2]+xaCabec[_npFORNECE][2]+xaCabec[_npLOJA][2]+xaCabec[_npTIPO][2])
        RecLock("SF1", .T. )
        SF1->F1_FILIAL    := xFilial("SF1")
        SF1->F1_DOC     := xaCabec[_npDOC][2]
        SF1->F1_SERIE   := xaCabec[_npSERIE][2]
        SF1->F1_FORNECE := xaCabec[_npFORNECE][2]
        SF1->F1_LOJA    := xaCabec[_npLOJA][2]
        SF1->F1_TIPO    := xaCabec[_npTIPO][2]
        SF1->F1_EMISSAO := xaCabec[_npEMISSAO][2]
        SF1->F1_ESPECIE := xaCabec[_npESPECIE][2]
        SF1->F1_FORMUL  := xaCabec[_npFORMUL][2]
        SF1->F1_EST     := aCabec[_npEST][2]
        SF1->F1_DTDIGIT := dDatabase
        SF1->F1_RECBMTO := dDatabase
        MsUnlock()

        for i:=1 to len(xaItem)
            dbSelectArea("SD1")
            RecLock("SD1", .T.)
            SD1->D1_FILIAL  := SF1->F1_FILIAL
            SD1->D1_DOC     := SF1->F1_DOC
            SD1->D1_SERIE   := SF1->F1_SERIE
            SD1->D1_FORNECE := SF1->F1_FORNECE
            SD1->D1_LOJA    := SF1->F1_LOJA
            SD1->D1_TIPO    := SF1->F1_TIPO
            SD1->D1_EMISSAO := SF1->F1_EMISSAO
            SD1->D1_DTDIGIT := SF1->F1_DTDIGIT
            SD1->D1_ITEM    := xaItem[i][_npITEM][2]
            SD1->D1_COD     := xaItem[i][_npCOD][2]
            SD1->D1_LOCAL   := xaItem[i][_npLOCAL][2]
            SD1->D1_UM      := xaItem[i][_npUM][2]
            SD1->D1_QUANT   := xaItem[i][_npQUANT][2]
            SD1->D1_VUNIT   := xaItem[i][_npVUNIT][2]
            SD1->D1_TOTAL   := xaItem[i][_npTOTAL][2]
            SD1->D1_TP      := Posicione("SB1",1,xFilial("SB1")+xaItem[i][_npCOD][2],"B1_TIPO")
            SD1->D1_OP      := xaItem[i][_npOP][2]
            SD1->D1_PEDIDO  := xaItem[i][_npPEDIDO][2]
            SD1->D1_ITEMPC  := xaItem[i][_npITEMPC][2]


            SD1->D1_TES  := xaItem[i][_npTES][2]
            SD1->D1_XNATURE  := xaItem[i][_npXNATURE][2]
            SD1->D1_CC  := xaItem[i][_npCC][2]
            SD1->D1_CONTA  := xaItem[i][_npCONTA][2]
            SD1->D1_ITEMCTA  := xaItem[i][_npITEMCTA][2]

            MsUnlock()
        next i
    Else
        _lRet := .F.
    EndIf

    RestArea(_aArea)

Return(_lRet)

Static Function sNOTARET()
    Local nOpc := 3
    Local cDoc := ZPB->ZPB_NFREM

    Private aCabec      := {}
    Private aItens      := {}
    Private aLinha      := {}
    Private lMsErroAuto := .F.

    cTESRET := GETMV('TCP_TESRET')
    cSERRET := GETMV('TCP_SERREM')
    cSERREM := GETMV('TCP_SERREM')

    if ZPB->ZPB_TIPO = 'G'
        cZPB_LOCAL   := GETMV('TCP_ARMGAR')
        cZPB_ENDEREC := GETMV('TCP_GARLOC')
    else
        cZPB_LOCAL   := GETMV('TCP_ARMREP')
        cZPB_ENDEREC := GETMV('TCP_REPLOC')
    endif


    aAdd(aCabec,{'F1_FORNECE',ZPB->ZPB_FORNEC,NIL})
    aAdd(aCabec,{'F1_LOJA'   ,sZPB_FORLOJA(),NIL})
    aAdd(aCabec,{'F1_TIPO'   ,'N',NIL})
    aAdd(aCabec,{'F1_FORMUL' ,'N',NIL})

    cF1_EST := Posicione("SA2",1,xFilial("SA2")+ZPB->ZPB_FORNEC+sZPB_FORLOJA(),"A2_EST")

    if lNotaGar
        cF1_DOCRET := Padl(AllTrim(cF1_DOCRET), len(ZPB->ZPB_NF1), '0')
        aAdd(aCabec,{'F1_DOC'    ,cF1_DOCRET, NIL})
        cDoc := cF1_DOCRET
        aAdd(aCabec,{"F1_SERIE"  ,cF1_SERRET,NIL})
        aAdd(aCabec,{"F1_EMISSAO",dF1_EMIRET,NIL})
    elseif ZPB->ZPB_TIPO = 'G'
        aAdd(aCabec,{'F1_DOC'    ,cF1_DOC, NIL})
        aAdd(aCabec,{"F1_SERIE"  ,cF1_SERIE,NIL})
        aAdd(aCabec,{"F1_EMISSAO",dF1_EMISSAO,NIL})
        cDoc := cF1_DOC
    else
        aAdd(aCabec,{'F1_DOC'    ,cDoc, NIL})
        aAdd(aCabec,{"F1_SERIE"  ,cSERRET,NIL})
        aAdd(aCabec,{"F1_EMISSAO",ddatabase,NIL})
    endif
    aAdd(aCabec,{"F1_ESPECIE","NF",NIL})
    aAdd(aCabec,{"F1_EST"    ,cF1_EST,NIL})

    aLinha := {}
    aadd(aLinha,{"D1_ITEM",'0001',Nil})
    aadd(aLinha,{"D1_COD" ,ZPB->ZPB_PRODUT,Nil})
    aadd(aLinha,{"D1_UM", 'UN' ,Nil})
    aadd(aLinha,{"D1_QUANT" , 1,Nil})
    aadd(aLinha,{"D1_VUNIT" , ZPB->ZPB_REMVLR,Nil})
    aadd(aLinha,{"D1_TOTAL" ,ZPB->ZPB_REMVLR,Nil})
    aadd(aLinha,{"D1_NFORI" ,ZPB->ZPB_NFREM,Nil}) // nota de origem
    aadd(aLinha,{"D1_SERIORI",cSERREM ,Nil})
    aadd(aLinha,{"D1_ITEMORI","01" ,Nil})
    aadd(aLinha,{"D1_LOCAL",cZPB_LOCAL,Nil})
    aAdd(aLinha,{"D1_TES"    ,cTESRET,NIL})
    aAdd(aLinha,{"D1_LOTECTL",ZPB->ZPB_LOTE,NIL})
    aAdd(aLinha,{"D1_NUMSERI",ZPB->ZPB_SERIE,NIL})

    //Cria a query para buscar o numero do IDENTB6
    cQuerySD2 := " Select D2_IDENTB6 "
    cQuerySD2 += " FROM " + RetSqlName("SD2") + " SD2 with (nolock)"
    cQuerySD2 += " WHERE D_E_L_E_T_ <> '*' "
    cQuerySD2 += "   AND D2_FILIAL = '" + xFILIAL("SD2") + "' "
    cQuerySD2 += "   AND D2_DOC = '" + ZPB->ZPB_NFREM + "' "
    cQuerySD2 += "   AND D2_SERIE = '" + cSERREM + "' "
    cQuerySD2 += "   AND D2_ITEM = '01' "

    cQuerySD2 := UPPER(cQuerySD2)

    If Select("QRYSD2") > 0
        QRYSD2->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuerySD2),"QRYSD2",.F.,.T.)
    dbSelectArea("QRYSD2")
    QRYSD2->(dbGoTop())
    aAdd(aLinha,{"D1_IDENTB6",QRYSD2->D2_IDENTB6,NIL})

    aadd(aItens,aLinha)

    MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3)

    If !lMsErroAuto
        MsgInfo("Nota Fiscal de retorno [" + cDoc + "] gerada com sucesso! ")
        sZPC_GRAVAR('PRE',"Gerada Nota Fiscal de Retorno [" + cDoc + "].")
    Else
        MostraErro()
        return .F.
    EndIf

return .T.

Static Function sVALIDANF()
    if ZPB->ZPB_TPFRE = cValtoChar(xFRETE_CON) .or. ZPB->ZPB_TPFRE = cValtoChar(xFRETE_FOB)
        if empty(ZPB->ZPB_NFFRE)
            MsgStop("Este processo de reparo/garantia não teve sua nota de frete lançada. ")
            return .F.
        endif
    endif

    xF1_DOC := Padl(AllTrim(ZPB->ZPB_NFFRE), len(ZPB->ZPB_NFFRE), '0')
    // Validando a NF de Frete
    if !empty(ZPB->ZPB_NFFRE)
        cQuery := " Select F1_TIPO, F1_STATUS "
        cQuery += " FROM " + RetSqlName("SF1") + " SF1 with (nolock),"
        cQuery += "      " + RetSqlName("SC7") + " SC7 with (nolock)"
        cQuery += " WHERE SF1.D_E_L_E_T_ <> '*' "
        cQuery += "   AND F1_FILIAL = '" + xFILIAL("SD2") + "' "
        cQuery += "   AND F1_DOC = '" + xF1_DOC + "' "
        cQuery += "   AND SC7.D_E_L_E_T_ <> '*' "
        cQuery += "   AND C7_FILIAL = '" + xFILIAL("SD2") + "' "
        cQuery += "   AND C7_NUM = '" + ZPB->ZPB_PCFRE + "' "
        cQuery += "   AND F1_FORNECE = C7_FORNECE "
        cQuery += "   AND F1_LOJA = C7_LOJA "

        cQuery := UPPER(cQuery)

        If Select("QRy") > 0
            QRy->(dbCloseArea())
        EndIf

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
        dbSelectArea("QRY")

        if QRY->F1_TIPO <> 'N' .or. QRY->F1_STATUS = ' '
            MsgStop("A nota fiscal de frete não está concluída. ")
            return .F.
        endif
    endif

    xF1_DOC := Padl(AllTrim(ZPB->ZPB_NF1), len(ZPB->ZPB_NF1), '0')

    cQuery := " Select F1_TIPO, F1_STATUS "
    cQuery += " FROM " + RetSqlName("SF1") + " SF1 with (nolock)"
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND F1_FILIAL = '" + xFILIAL("SD2") + "' "
    cQuery += "   AND F1_DOC = '" + xF1_DOC + "' "
    cQuery += "   AND F1_FORNECE = '" + ZPB->ZPB_FORNEC + "' "

    cQuery := UPPER(cQuery)

    If Select("QRy") > 0
        QRy->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")

    if QRY->F1_TIPO <> 'N'  .or. QRY->F1_STATUS = ' '
        MsgStop("A nota fiscal de serviço/peças não está concluída. ")
        return .F.
    endif

return .T.

Static Function s0402ENC()
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Encerramento do processo de garantia/retorno'
    Local lReturn := .T.
    Private oDlg  := Nil
    Private cF1_DOC :=  Space(TamSX3('F1_DOC')[1])
    Private cF1_SERIE :=  Space(TamSX3('F1_SERIE')[1])
    Private dF1_EMISSAO := date()
    Private cZPB_LOTNEW := ""

    if ZPB->ZPB_STATUS <> 'PRE'
        MsgStop("Este processo de reparo/garantia não se encontra na situação [ " + cTXT_PRE + "]. Impossível iniciar processo de reparo/garantia! ")
        return
    endif

    if ZPB->ZPB_TIPO = 'R'
        if !sVALIDANF()
            return
        endif
    endif

    if !MsgYesNo("Confirma o encerramento do processo de Garantia/Reparo " + ZPB->ZPB_PROC + "? ","Finalização")
        return
    endif

    Begin Transaction
        
        if !sMata250()
            DisarmTransaction()
            lReturn := .F.
        endif

        If lReturn    
            cUpdate := " update " + retsqlname("ZPB") + " "
            cUpdate += " set ZPB_STATUS = 'FIN', ZPB_LOTNEW = '" + cZPB_LOTNEW + "'"
            cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
            cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"

            cUpdate := UPPER(cUpdate)

            nUpdate := TcSqlExec(cUpdate)
            
            if nUpdate < 0
                MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                lReturn := .F.
            endif
            
            If lReturn
                sZPC_GRAVAR('FIN', 'Processo de Garantia/Reparo Finalizado.')
            EndIf
        EndIf

    End Transaction

    oGrid:Refresh()

return( lReturn )


Static Function sD3_DTVALID(cD1_EMISSAO)
    
    local dD1_EMISSAO := STOD(cD1_EMISSAO)

    cQuery := " Select C7_XTMPGAR, C7_XDESCGA "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 with (nolock)"
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND C7_FILIAL = '" + xFILIAL("SC7") + "' "
    cQuery += "   AND C7_NUM = '" + ZPB->ZPB_SC7 + "' "
    cQuery += " ORDER BY C7_ITEM "

    cQuery := UPPER(cQuery)

    If Select("QSC7") > 0
        QSC7->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QSC7",.F.,.T.)
    dbSelectArea("QSC7")
    QSC7->(dbGoTop())

    if QSC7->C7_XDESCGA = '1'
        dVALIDA := daysum(dD1_EMISSAO, QSC7->C7_XTMPGAR)
    elseif QSC7->C7_XDESCGA = '2'
        dVALIDA := Monthsum(dD1_EMISSAO, QSC7->C7_XTMPGAR)
    elseif QSC7->C7_XDESCGA = '3'
        dVALIDA := yearsum(dD1_EMISSAO, QSC7->C7_XTMPGAR)
    else
        dVALIDA := dD1_EMISSAO
    endif

return (dVALIDA)

Static Function sMATA250()
    Local aCabec := {}
    Local dData
    Local nOpc   := 3 //-Opção de execução da rotina, informado nos parametros quais as opções possiveis
    Local cTCP_TMOP := GETMV('TCP_TMOP')

    lMsErroAuto := .F.

    xF1_DOC := Padl(AllTrim(ZPB->ZPB_NF1), len(ZPB->ZPB_NF1), '0')

    // Buscando Conta item e centro de custo a ser usado no apontamento da OP
    cQuery := " Select TOP 1 * "
    cQuery += " FROM " + RetSqlName("SD1") + " SD1 with (nolock)"
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND D1_FILIAL = '" + xFILIAL("SD1") + "' "
    cQuery += "   AND D1_DOC = '" + xF1_DOC + "' "
    cQuery += "   AND D1_FORNECE = '" + ZPB->ZPB_FORNEC + "' "
    cQuery += " ORDER BY D1_ITEM "

    cQuery := UPPER(cQuery)

    If Select("QSD1") > 0
        QSD1->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QSD1",.F.,.T.)
    dbSelectArea("QSD1")
    QSD1->(dbGoTop())

    aAdd(aCabec, {"D3_DOC"    , Nextnumero("SD3",2,"D3_DOC",.T.), NIL })
    aAdd(aCabec, {"D3_OP"     , Alltrim(ZPB->ZPB_OP) + "01001" , NIL})
    aAdd(aCabec, {"D3_TM"     , cTCP_TMOP        , NIL})
    aAdd(aCabec, {"D3_COD"    , ZPB->ZPB_PRODUT  , NIL})
    aAdd(aCabec, {"D3_LOCAL"  , '01'             , NIL})
    if ZPB->ZPB_TIPO = 'G'
        cLOTECTL := ZPB->ZPB_LOTE
        dDTVALID := ZPB->ZPB_DTVALI
    else
        cLOTECTL := NextLote(ZPB->ZPB_PRODUT,"L")
        dDTVALID := sD3_DTVALID(QSD1->D1_EMISSAO)
    endif

    aAdd(aCabec, {"D3_LOTECTL", cLOTECTL, NIL})
    aAdd(aCabec, {"D3_DTVALID", dDTVALID, NIL})

    aAdd(aCabec, {"D3_UM"     , Posicione("SB1",1,xFilial("SB1")+ZPB->ZPB_PRODUTO,"B1_UM"), Nil})

    aAdd(aCabec, {"D3_QUANT"  , 1                , NIL})
    aAdd(aCabec, {"D3_PERDA"  , 0                , NIL})
    aAdd(aCabec, {"D3_PARCTOT", "T"              , NIL})
    aAdd(aCabec, {"D3_CC"     , QSD1->D1_CC      , NIL})
    aAdd(aCabec, {"D3_CONTA"  , QSD1->D1_CONTA   , NIL})

    if empty(QSD1->D1_ITEMCTA)
        aAdd(aCabec, {"D3_ITEMCTA", '000'        , NIL})
    else
        aAdd(aCabec, {"D3_ITEMCTA", QSD1->D1_ITEMCTA , NIL})
    endif

    aAdd(aCabec, {"D3_REQUISI", ZPB->ZPB_SOLICI  , NIL})
    aAdd(aCabec, {"D3_EMISSAO", ddatabase        , NIL})
    aAdd(aCabec, {"ATUEMP"    , "T"              , NIL})
    aAdd(aCabec, {"AUTPRTOTAL", "S" 			 , NIL})

    MSExecAuto({|x, y| mata250(x, y)},aCabec, nOpc )

    If lMsErroAuto
        Mostraerro()
        return .F.
    else
        MsgInfo("Apontamento da OP [" + ZPB->ZPB_OP + "] realizado com sucesso.")
        if ZPB->ZPB_TIPO = 'R'
            sZPC_GRAVAR('FIN', "Gerado lote [" + cLOTECTL + "] e validade [" + DTOC(dDTVALID) + "]. ")
        endif
        sZPC_GRAVAR('FIN', "Realizado apontamento da OP [" + ZPB->ZPB_OP + "].")
    Endif

    cZPB_LOTNEW := cLOTECTL

Return .T.

Static Function s0402CAN()
    
    Local aSize   := {}
    Local _lRet   := .f.
    Local nClick  := 0
    Local cTitulo := 'Cancelamento do processo de garantia/reparo'
    Private oDlg  := Nil
    Private cF1_DOC :=  Space(TamSX3('F1_DOC')[1])
    Private cF1_SERIE :=  Space(TamSX3('F1_SERIE')[1])
    Private dF1_EMISSAO := date()
    Private lNotaGar := .F.

    if ZPB->ZPB_STATUS = 'FIN'
        MsgStop("Este processo de reparo/garantia se encontra na situação [ " + cTXT_FIN + "]." + chr(13) + chr(13) + "Impossível cancelar este processo de reparo/garantia! ")
        return
    endif

    if !MsgYesNo("Confirma o CANCELAMENTO do processo de Garantia/Reparo " + ZPB->ZPB_PROC + "? " + chr(13) + chr(13) + "Atenção: Este processo não poderá ser desfeito","Cancelamento")
        return
    endif

    Begin Transaction
        
        if !empty(ZPB->ZPB_NFREM) .and. empty(ZPB->ZPB_NFRET)
            if !sNOTARET()
                DisarmTransaction()
                _lRet := .F.
            endif
        endif

        If _lRet
            cUpdate := " update " + retsqlname("ZPB") + " "
            cUpdate += " set ZPB_STATUS = 'CAN'"
            cUpdate += " where ZPB_FILIAL = '" + xFilial("ZPB") + "'"
            cUpdate += "   and ZPB_PROC = '" + ZPB->ZPB_PROC + "'"

            cUpdate := UPPER(cUpdate)

            nUpdate := TcSqlExec(cUpdate)
            if nUpdate < 0
                MsgStop("Não foi possível atualizar o a tabela ZPB devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
                _lRet := .F.
            endif
            If _lRet
                sZPC_GRAVAR('CAN', 'Processo de Garantia/Reparo Cancelado.')
            EndIf
        EndIf

    End Transaction

    oGrid:Refresh()

return( _lRet )


Static Function S0402VIS()
    Local aSize  := MsAdvSize()

    Private oGridZPC          := Nil
    Private aGridZPC          := {}

    Private cCadastro         := "Log Reparo/Garantia"

    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,, ,.T.)

    aObjects := {}
    AAdd( aObjects, {  0,       65, .T., .F. } )
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )

    TButton():New(040, 360, OemToAnsi("&Planilha") , oDialog,{|| S0402EXCEL()   },83, 010,,,,.T.,,,,{|| })

    aColHeader := {"Data", "Hora", "Status", "Usuario", "Observação"}
    aColSize   := {    50,     50,       50,        70,          250}

    oGridZPC := TCBrowse():New(70,005,aPosObj[2][4] - 5, aPosObj[2][3] - 85,,aColHeader,aColSize ,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

    S0402SQL()

    oDialog:Activate(,,,.T.)

Return
Static Function s0402WF()
    if ZPB->ZPB_STATUS = 'AAI'
        if MsgYesNo("Confirma o reenvio do email de NOTIFICAÇÃO de item para Reparo/Garantia do processo " + ZPB->ZPB_PROC + "? ","WorkFlow")
            U_WFGARINI(ZPB->ZPB_PROC)
        endif
    elseif ZPB->ZPB_STATUS = 'TRN'
        if MsgYesNo("Confirma o reenvio do email de COLETA de item para Reparo/Garantia do processo " + ZPB->ZPB_PROC + "? ","WorkFlow")
            U_WFGARCOL(ZPB->ZPB_PROC)
        endif
    else
        MsgStop("Este processo de reparo/garantia se encontra na situação [ " + U_ZPB_STADSC() + "]." + chr(13) + chr(13) + "Não existe workflow para esta etapa. ")
        return
    endif

    MsgInfo("Reenvio do workflow para esta etapa realizado com sucesso. ")

return


Static Function S0402SQL()
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQueryZPC := " Select ZPC_DATA, ZPC_HORA, ZPC_STATUS, ZPC_USER, ISNULL(CAST(CAST(ZPC_OBSERV AS VARBINARY(8000)) AS VARCHAR(8000)),'') ZPC_OBSERV "
    cQueryZPC += " FROM " + RetSqlName("ZPC") + " ZPC with (nolock)"
    cQueryZPC += " WHERE ZPC.D_E_L_E_T_ <> '*' "
    cQueryZPC += "   AND ZPC_FILIAL = '" + xFILIAL("ZPB") + "' "
    cQueryZPC += "   AND ZPC_PROC = '" + ZPB->ZPB_PROC + "' "
    cQueryZPC += " ORDER BY ZPC_DATA, ZPC_HORA "

    cQueryZPC := UPPER(cQueryZPC)

    If Select("QRYZPC") > 0
        QRYZPC->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryZPC),"QRYZPC",.F.,.T.)
    dbSelectArea("QRYZPC")
    QRYZPC->(dbGoTop())

    aGridZPC := {}

    While QRYZPC->(!Eof())
        AAdd(aGridZPC,{QRYZPC->ZPC_DATA,;
            QRYZPC->ZPC_HORA,;
            QRYZPC->ZPC_STATUS,;
            QRYZPC->ZPC_USER,;
            QRYZPC->ZPC_OBSERV})
        QRYZPC->(dbSkip())
    EndDo

    if len(aGridZPC) = 0
        aGridZPC := {{"", "", "", "", "", ""}}
    endif

    oGridZPC:SetArray(aGridZPC)
    oGridZPC:bLine := {||{aGridZPC[oGridZPC:nAt][1],;
        aGridZPC[oGridZPC:nAt][2],;
        aGridZPC[oGridZPC:nAt][3],;
        aGridZPC[oGridZPC:nAt][4],;
        aGridZPC[oGridZPC:nAt][5]}}

    oGridZPC:Refresh()
    oDialog:Refresh()

Return

Static Function S0402EXCEL()
    Processa({ || S0402XLS()}, "Gerando arquivo EXCEL ...." )

Static Function S0402XLS()
    Local oFwMsEx    := Nil
    Local cArq       := ""
    Local cWorkSheet := ""
    Local cTable     := ""
    Local cDirTmp    := GetTempPath()
    Local nLinha,i

    if len(aGridZPC) = 0
        MsgStop("Não existem dados para exportar!", "Atenção")
        Return ()
    endif

    If !ApOleClient("MSExcel")
        MsgStop("MSExcel não está instalado!", "Atenção")
        Return ()
    EndIf

    cWorkSheet := "LOG Garantia-Reparo"
    cTable := "Log de Processo Garantia-Reparo"

    oFwMsEx := FWMsExcel():New()

    oFwMsEx:AddWorkSheet( cWorkSheet )
    oFwMsEx:AddTable( cWorkSheet, cTable )

    for i := 1 to len(aColHeader)
        if Valtype(aGridZPC[1][i]) = 'N'
            oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 3, 2)
        elseif Valtype(aGridZPC[1][i]) = 'D'
            oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 1, 4)
        else
            oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 1, 1)
        endif
    next

    For nLinha := 1 to Len(aGridZPC)
        oFwMsEx:AddRow( cWorkSheet, cTable,  {aGridZPC[nLinha,01],;
            aGridZPC[nLinha,02],;
            aGridZPC[nLinha,03],;
            aGridZPC[nLinha,04],;
            aGridZPC[nLinha,05]})
    Next nLinha

    oFwMsEx:Activate()

    cArq := CriaTrab( NIL, .F. ) + ".xmls"
    oFwMsEx:GetXMLFile(cArq)
    If __CopyFile( cArq, cDirTmp + cArq )
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open( cDirTmp + cArq )
        oExcelApp:SetVisible(.T.)
    EndIf

Return