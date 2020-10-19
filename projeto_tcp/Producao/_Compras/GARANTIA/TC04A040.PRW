#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"    
#Include "TopConn.ch"           

/*
Programa : TC04A040 
Autor    : ALMASGE
Data     : 30/08/2019                                                                                         U_                                                         
Desc.    : Criação de lote e serie de produtos para uso no processo de garantia/reparo
Uso      : TCP
*/

User Function TC04A040()  
    Local aSize   := {}
    
    Local cTitulo := 'Inclusão de lote/serie para processo de Garantia/Reparo'         
    
    Private oDlg         := Nil
    Private cB1_DESC     := Space(TamSX3('B1_DESC')[1])
    Private cB8_PRODUTO  := Space(TamSX3('B8_PRODUTO')[1])
    Private cB8_LOTECTL  := Space(TamSX3('B8_LOTECTL')[1])
    Private cBF_NUMSERI  := Space(TamSX3('BF_NUMSERI')[1])
    Private cB8_DTVALID 
    Private lPedeData := .T.
    Private lTemLote := .F.
    
    aSize := MsAdvSize(.F.)

    oDlg := TDialog():New(000,000,220,700,OemToAnsi(cTitulo),,,,,,,,oMainWnd,.T.)
    
    aObjects := {}  
    
    AAdd( aObjects, { 100, 180, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }
                                                                                                      
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
            {{10,40,105,140,200,234,275,200,225,270,285,265},;
             {10,40,105,140,200,234, 63,200,225,270,285,265} } ) 
    
    @ aPosObj[1][1]+ 10,aPosGet[1,1]       Say "Produto"                            Of oDlg  Pixel Size 031, 010       
    @ aPosObj[1][1]+ 08,aPosGet[1,1] + 52  MsGet cB8_PRODUT                         When .T. Of oDlg F3 "SB1" VALID sPRODUTO() Pixel Size  50, 010 
    @ aPosObj[1][1]+ 08,aPosGet[1,1] + 102 MsGet cB1_DESC                           When .F. Of oDlg Pixel Size  250, 010     
    
    @ aPosObj[1][1]+ 25,aPosGet[1,1]       Say "Lote"                               Of oDlg   Pixel Size 031,010 
    @ aPosObj[1][1]+ 23,aPosGet[1,1] + 52  MsGet cB8_LOTECTL                        When .T. Of oDlg VALID sLOTECTL() Pixel Size 50,010     
    
    @ aPosObj[1][1]+ 40,aPosGet[1,1]       Say "Serie"                              Of oDlg   Pixel Size 031,010 
    @ aPosObj[1][1]+ 38,aPosGet[1,1] + 52  MsGet cBF_NUMSERI                        When .T. Of oDlg VALID sNUMSERI() Pixel Size 100,010     
    
    @ aPosObj[1][1]+ 55,aPosGet[1,1]       Say "Data Validade "                  	Of oDlg  Pixel Size 051, 010       
    @ aPosObj[1][1]+ 53,aPosGet[1,1] + 52  MsGet cB8_DTVALID                        When lPedeData Of oDlg Picture "@D"  Pixel Size  50, 010   
    
    TButton():New(aPosObj[1][1]+ 70,aPosGet[1,1], OemToAnsi("&Gravar") ,oDlg,{|| sGravar()},045, 010,,,,.T.,,,,{|| })
           
    oDlg:Activate(,,,.T.)
    
    return

Static Function sGravar()
    Local cLoteTmp := SuperGetMV("TCP_ARMTMP",.F.,"51")

    if empty(cB8_PRODUT)
        MsgStop("Produto não informado.")
        return .F.
    elseif  empty(cB8_LOTECTL)
        MsgStop("Lote não informado.")
        return .F.
    elseif  empty(cBF_NUMSERI)
        MsgStop("Serie não informada.")
        return .F. 
    elseif empty(cB8_DTVALID) 
        MsgStop("Data de validade não informada.")
        return .F. 
    endif
    
    // Validar se o lote ja existe na SB8
    cQuery := " Select 	B8_PRODUTO, B8_DATA, B8_DTVALID "
    cQuery += " from " + RetSqlName ("SB8")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B8_FILIAL =  '" + xFilial("SB8") + "' "
    cQuery += "   and B8_PRODUTO =  '" + cB8_PRODUTO + "' "
    cQuery += "   and B8_LOCAL =  '"+cLoteTmp+"' "
    cQuery += "   and B8_LOTECTL =  '" + cB8_LOTECTL + "' "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    
    if empty(QRY->B8_PRODUTO)
        lPedeData := .T.
        lTemLote := .F.
    else
        lPedeData := .F.
        lTemLote := .T.
    endif
      
    if !lTemLote
	    Reclock("SB8", .T.)   
	    SB8->B8_FILIAL := xFILIAL("SB8") 
	    SB8->B8_QTDORI := 0
		SB8->B8_PRODUTO := cB8_PRODUTO
		SB8->B8_LOCAL := cLoteTmp
		SB8->B8_DATA := date()
		SB8->B8_DTVALID := cB8_DTVALID
		SB8->B8_SALDO := 0
		SB8->B8_LOTECTL := cB8_LOTECTL
        SB8->(MsUnLock())  
    endif

	Reclock("SBF", .T.)   
    SBF->BF_FILIAL :=  xFILIAL("SB8")
    SBF->BF_PRODUTO := cB8_PRODUTO
    SBF->BF_LOCAL := cLoteTmp
    // SBF->BF_LOCALIZ	
    SBF->BF_NUMSERI	:= cBF_NUMSERI
    SBF->BF_LOTECTL := cB8_LOTECTL
    SBF->BF_QUANT   := 0
    SBF->(MsUnLock())  
    
    cBF_NUMSERI := Space(TamSX3('BF_NUMSERI')[1])
    
    MsgInfo("Informações de lote/serie gravadas com sucesso.")
        
    return .T.

Static Function sPRODUTO()
    cQuery := " Select B1_DESC, B1_RASTRO "
    cQuery += " from " + RetSqlName ("SB1")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B1_FILIAL =  '" + xFilial("SB1") + "' "
    cQuery += "   and B1_COD =  '" + cB8_PRODUT + "' "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    
    if empty(QRY->B1_DESC)
        MsgStop("Produto não cadastrado.")
        cB1_DESC := ""    
        return .F.
    elseif QRY->B1_RASTRO <> 'L'
        MsgStop("Produto não esta com o RASTRO habilitado.")
        cB1_DESC := QRY->B1_DESC
        return .F.
    else
        cB1_DESC := QRY->B1_DESC
    endif
    
    return .T.
    
Static Function sLOTECTL()    
    if empty(cB8_LOTECTL)
        cB8_LOTECTL := NextLote(cB8_PRODUTO,"L")
    endif
    
    cQuery := " Select 	B8_PRODUTO, B8_DATA, B8_DTVALID "
    cQuery += " from " + RetSqlName ("SB8")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and B8_FILIAL =  '" + xFilial("SB8") + "' "
    cQuery += "   and B8_PRODUTO =  '" + cB8_PRODUTO + "' "
    cQuery += "   and B8_LOTECTL =  '" + cB8_LOTECTL + "' "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    
    if empty(QRY->B8_PRODUTO)
        lPedeData := .T.
        lTemLote := .F.
    else
        lPedeData := .F.
        lTemLote := .T.
    endif
    
    cB8_DTVALID := STOD(QRY->B8_DTVALID)
    
    return .T.
    
Static Function sNUMSERI()
    cQuery := " Select BF_NUMSERI "
    cQuery += " from " + RetSqlName ("SBF")
    cQuery += " where D_E_L_E_T_ <> '*' "
    cQuery += "   and BF_FILIAL =  '" + xFilial("SBF") + "' "
    cQuery += "   and BF_PRODUTO =  '" + cB8_PRODUTO + "' "
    cQuery += "   and BF_LOTECTL =  '" + cB8_LOTECTL + "' "
    cQuery += "   and BF_NUMSERI =  '" + cBF_NUMSERI + "' "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
    
    if !empty(QRY->BF_NUMSERI)
        MsgStop("Numero de serie já informado.")
        return .F.
    endif
    
    return .T.
