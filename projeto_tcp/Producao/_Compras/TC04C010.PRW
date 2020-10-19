#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"                                                                                                   

/*                                                                                                                                                                               
Programa : TC04C010 
Autor    : ALMASGE
Data     : 30/08/2019                                                                                                                                                  
Desc.    : Consulta e Alteração do ORDER POINT
Uso      : TCP
*/
User Function TC04C010()  
             
     
    Local aSize  := MsAdvSize()
	//Local aOrdenacao:= {"Cod", "Desc"} 
	   
    Private aZPA_USER := {}
	Private oGrid          := Nil       
    Private aGrid          := {}
    Private _dDatINI       := STOD("        ") 
    Private _dDatFIM       := STOD("        ") 
    Private _cB1_GRUPOINI  := space(TamSX3('B1_GRUPO')[1])  
    Private _cB1_GRUPOFIM  := space(TamSX3('B1_GRUPO')[1])  
    Private _cB1_CODINI    := space(TamSX3('B1_COD')[1])
    Private _cB1_CODFIM    := space(TamSX3('B1_COD')[1])
    
    Private cCadastro         := "Consulta Order Point"

    DbSelectArea("ZP9")
    DbSelectArea("ZPA")    
    
    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,, ,.T.) //oMainWnd
    
    aObjects := {}  
    AAdd( aObjects, {  0,       65, .T., .F. } )        
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )    
    
    if aSize[3] >= 750
        nColPERI := 012
        nColPERF := 072
        nColPIni := 142
        nColPfim := 232
        nColGIni := 322
        nColGFim := 402
        nColUser := 482
        nColFilt := 562
        nColExce := 642
    else
        nColPERI := 012
        nColPERF := 072
        nColPIni := 142
        nColPfim := 232
        nColGIni := 322
        nColGFim := 402
        nColUser := 482
        nColFilt := 562
        nColExce := 642
    endif
    
    TSay():New(012, nColPeri,{|| "Data Inicial" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColPeri  MSGet _dDatINI Of oDialog              PIXEL SIZE 040, 009 Picture "@D"

    TSay():New(012, nColPerf,{|| "Data Final" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColPerf  MSGet _dDatFIM Of oDialog              PIXEL SIZE 040, 009 Picture "@D"
     	
    TSay():New(012, nColPIni,{|| "Produto de" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColPIni MSGet _cB1_CODINI Of oDialog   F3 "SB1"  PIXEL SIZE 070, 009 
	
	TSay():New(012, nColPFim,{|| "Produto ate" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColPFim MSGet _cB1_CODFIM Of oDialog   F3 "SB1"  PIXEL SIZE 070, 009 

    TSay():New(012, nColGIni,{|| "Grupo de" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColGIni MSGet _cB1_GRUPOINI Of oDialog F3 "SBM"  PIXEL SIZE 060, 009 
	                                                                             
    TSay():New(012, nColGFim,{|| "Grupo até" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 025, nColGFim MSGet _cB1_GRUPOFIM Of oDialog F3 "SBM"  PIXEL SIZE 060, 009 

    sSelUser()
    TSay():New(012, nColUser, {|| "Usuario" },oDialog,,,.F.,.F.,.F.,.T.,,,70,008)
    cComboUser:= aZPA_USER[1]
    TComboBox():New(025,nColUser,{|u|if(PCount()>0,cComboUser:=u,cComboUser)}, aZPA_USER,60,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboUser')
	                                                                                                     
    //Botões de processamento
    TButton():New(025, nColFilt, OemToAnsi("&Filtrar")  , oDialog,{|| S0401SB1("N")   },73, 010,,,,.T.,,,,{|| })

    //Botões de processamento
    TButton():New(025, nColExce, OemToAnsi("&Exportar")  , oDialog,{|| S0401EXCEL()   },73, 010,,,,.T.,,,,{|| })
   
    aColHeader := {}
    aColSize := {}
    aAdd(aColHeader, "Codigo")
    aAdd(aColSize, 50)
    aAdd(aColHeader, "Descrição")
    aAdd(aColSize, 200)
    aAdd(aColHeader, "Data")
    aAdd(aColSize, 40)
    aAdd(aColHeader, "Hora")
    aAdd(aColSize, 40)
    aAdd(aColHeader, "Est Minimo Anterior")
    aAdd(aColSize, 80)
    aAdd(aColHeader, "Est Minimo Atual")
    aAdd(aColSize, 80)
    aAdd(aColHeader, "Ponto Pedido Anterior")
    aAdd(aColSize, 80)
    aAdd(aColHeader, "Ponto Pedido Atual")
    aAdd(aColSize, 80)
    aAdd(aColHeader, "Usuário")
    aAdd(aColSize, 200)
    
    oGrid := TWBrowse():New(50,005,aPosObj[2][4] - 5, aPosObj[2][3] - 85,,aColHeader, aColSize ,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
      
    S0401SB1("S") 
 
    oDialog:Activate(,,,.T.)

    Return       
 
Static Function sSelUser()
    aZPA_USER := {}
    aAdd(aZPA_USER, "Todos")
    
    cQuery := " Select distinct ZPA_USER ZPA_USER"
    cQuery += " from " + RetSqlName("ZPA")
    cQuery += " where D_E_L_E_T_ <> '*'"
    cQuery += " order by ZPA_USER " 
    cQuery := UPPER(cQuery)
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
                
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)                                               
    dbSelectArea("QRY")
    QRY->(dbGoTop())        

    aGrid := {}   
    
    While QRY->(!Eof()) 
        aAdd(aZPA_USER, QRY->ZPA_USER)  
    
        QRY->(dbSkip())
    EndDo  
        
    return
    
Static Function S0401SB1(pPRIMEIRO) 
    MsAguarde({|| S0401SQL(pPRIMEIRO)}, "Aguarde ...") 
    
    Return
    
Static Function S0401SQL(pPRIMEIRO)
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQuerySB1 := " Select B1_COD, "
    cQuerySB1 += "     B1_DESC, "
    cQuerySB1 += "     ZPA_DATA, "
    cQuerySB1 += "     ZPA_HORA, "
    cQuerySB1 += "     ZPA_USER, "
    cQuerySB1 += "     ZPA_PPEANT, "
    cQuerySB1 += "     ZPA_PPEATU, "
    cQuerySB1 += "     ZPA_MINANT, "
    cQuerySB1 += "     ZPA_MINATU " 
    cQuerySB1 += " FROM " + RetSqlName("ZPA") + " ZPA with (nolock),"
    cQuerySB1 += "      " + RetSqlName("SB1") + " SB1 with (nolock)"
    cQuerySB1 += " WHERE SB1.D_E_L_E_T_ <> '*' "
	cQuerySB1 += "   AND ZPA.D_E_L_E_T_ <> '*' "
	cQuerySB1 += "   AND B1_FILIAL = '" + xFILIAL("SB1") + "' "
	cQuerySB1 += "   AND B1_COD = ZPA_PRODUT"
	cQuerySB1 += "   AND ZPA_FILIAL = '" + xFILIAL("ZPA") + "' "
	
    if pPRIMEIRO = "S"
         cQuerySB1 += "   AND 1 = 0"
    endif       
    
    if !Empty(_dDatINI)     
         cQuerySB1 += "   AND ZPA_DATA >= '" + DTOS(_dDatINI) + "' "
    endif                                                     
    if !Empty(_dDatFIM)     
         cQuerySB1 += "   AND ZPA_DATA <= '" + DTOS(_dDatFIM) + "' "
    endif                                                     
    if !Empty(_cB1_GRUPOINI)
         cQuerySB1 += "   AND B1_GRUPO >= '" + _cB1_GRUPOINI + "' "
    endif
    if !Empty(_cB1_GRUPOFIM)
         cQuerySB1 += "   AND B1_GRUPO <= '" + _cB1_GRUPOFIM + "' "
    endif
    if !Empty(_cB1_CODINI)
         cQuerySB1 += "   AND B1_COD >= '" + _cB1_CODINI + "' "        
    endif
    if !Empty(_cB1_CODFIM)
         cQuerySB1 += "   AND B1_COD <= '" + _cB1_CODFIM + "' "        
    endif
    if cComboUser <> "Todos"
        cQuerySB1 += "    AND ZPA_USER = '" + AllTrim(cComboUser) + "' "
    endif

    If Select("QRYSB1") > 0
        QRYSB1->(dbCloseArea())
    EndIf
                
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuerySB1),"QRYSB1",.F.,.T.)                                               
    dbSelectArea("QRYSB1")
    QRYSB1->(dbGoTop())        

    aGrid := {}   
    
    While QRYSB1->(!Eof())
        dZPA_DATA := STOD(QRYSB1->ZPA_DATA)        
        AAdd(aGrid,{QRYSB1->B1_COD,;
                    QRYSB1->B1_DESC,;
                    dZPA_DATA,;
                    QRYSB1->ZPA_HORA,;
		            QRYSB1->ZPA_MINANT,;
		            QRYSB1->ZPA_MINATU,;
                    QRYSB1->ZPA_PPEANT,;
		            QRYSB1->ZPA_PPEATU,;
		            QRYSB1->ZPA_USER})       
        QRYSB1->(dbSkip())
    EndDo                                        
    
    if len(aGrid) = 0
        aGrid := {{"", "", "", "", 0, 0, 0, 0, ""}} 
    endif

    oGrid:SetArray(aGrid)                    
    oGrid:bLine := {||{aGrid[oGrid:nAt][1],;
	         		   aGrid[oGrid:nAt][2],;
				       aGrid[oGrid:nAt][3],;
				       aGrid[oGrid:nAt][4],;
				       aGrid[oGrid:nAt][5],;
				       aGrid[oGrid:nAt][6],;
				       aGrid[oGrid:nAt][7],;
				       aGrid[oGrid:nAt][8],;
				       aGrid[oGrid:nAt][9]}}
      
    oGrid:Refresh()
    oDialog:Refresh()     
    
    Return
    
 
Static Function S0401EXCEL()
    Processa({ || S0401XLS()}, "Gerando arquivo EXCEL ...." )

return

Static Function S0401XLS()
    Local oFwMsEx    := Nil
    Local cArq       := ""
    Local cWorkSheet := ""
    Local cTable     := ""
    Local cDirTmp    := GetTempPath()
    Local i
    Local nLinha
    if len(aGrid) = 0
        MsgStop("Não existem dados para exportar!", "Atenção")      
        Return ()
    endif	
    
    If !ApOleClient("MSExcel")
        MsgStop("MSExcel não está instalado!", "Atenção")      
        Return ()
    EndIf

    cWorkSheet := "Order Point"
	cTable := "Consulta Order Point"
        
    oFwMsEx := FWMsExcel():New()        

    oFwMsEx:AddWorkSheet( cWorkSheet )
    oFwMsEx:AddTable( cWorkSheet, cTable )          

    for i := 1 to len(aColHeader)
         if Valtype(aGrid[1][i]) = 'N'
             oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 3, 2)
         elseif Valtype(aGrid[1][i]) = 'D'
             oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 1, 4)
         else
             oFwMsEx:AddColumn( cWorkSheet, cTable, aColHeader[i], 1, 1)
         endif     
    next       
     
    For nLinha := 1 to Len(aGrid)
         oFwMsEx:AddRow( cWorkSheet, cTable,  {aGrid[nLinha,01],;
                                               aGrid[nLinha,02],;
		                                       aGrid[nLinha,03],;
		                                       aGrid[nLinha,04],;
		                                       aGrid[nLinha,05],;
		                                       aGrid[nLinha,06],;
		                                       aGrid[nLinha,07],;
		                                       aGrid[nLinha,08],;
		                                       aGrid[nLinha,09]})  
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