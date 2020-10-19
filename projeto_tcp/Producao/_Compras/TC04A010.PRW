#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"                                                                                                   

/*                                                                                                                                                                               
Programa : TC04A010 
Autor    : ALMASGE
Data     : 30/08/2019                                                                                                                                                  
Desc.    : Consulta e Alteração do ORDER POINT
Uso      : TCP
*/
User Function TC04A010()  
    Local aSize  := MsAdvSize()
	Local aSaldo := {"Sim", "Não"} 
	Local aOrdenacao := {"Cod", "Desc"} 
	Local aB1_MSBLQL := {"Todos", "Sim", "Nao"}
	Local aDivergencia := {"Todos", "Com Divergência", "Sem Divergência"}
	Local aB1_ZITEMZ := {"Todos", "X", "Y", "Z", "Em Branco"}
	   
    Private oGrid          := Nil       
    Private aGrid          := {}
    Private _cDTREFINI     := space(07)
    Private _cB1_GRUPOINI  := space(TamSX3('B1_GRUPO')[1])  
    Private _cB1_GRUPOFIM  := space(TamSX3('B1_GRUPO')[1])  
    Private _cB1_CODINI    := space(TamSX3('B1_COD')[1])
    Private _cB1_CODFIM    := space(TamSX3('B1_COD')[1])
    
    Private cCadastro         := "Order Point"

    DbSelectArea("ZP9")
    DbSelectArea("ZPA")    
    
    // Variavel criada para controlar a segunda chamada desta função logo após a informação de motivos de negociação 
    Public bTC04A010
    
    if Valtype(bTC04A010) = "L" 
        if bTC04A010
           bTC04A010 := .F.
           return
        endif
    endif
    
    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,, ,.T.)
    
    aObjects := {}  
    AAdd( aObjects, {  0,       65, .T., .F. } )        
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )    
    
    if aSize[3] >= 750
        nColPer  := 012
        nColBloq := 072
        nColPIni := 142
        nColPfim := 232
        nColGIni := 322
        nColGFim := 402
        nColCrit := 482
        nColDive := 552
        nColOrde := 012
        nColSld := 082
    else
        nColPer  := 012
        nColBloq := 072
        nColPIni := 142
        nColPfim := 232
        nColGIni := 322
        nColGFim := 402
        nColCrit := 482
        nColDive := 552
        nColOrde := 012
        nColSld := 082
    endif
    
    TSay():New(010, nColPer,{|| "Período Inicial" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 021, nColPer  MSGet _cDTREFINI Of oDialog              PIXEL SIZE 040, 009 Picture "@R 99/9999"

    TSay():New(010, nColBloq, {|| "Considera Itens Bloq." },oDialog,,,.F.,.F.,.F.,.T.,,,200,008)
    cComboBloq:= aB1_MSBLQL[1]
    TComboBox():New(021,nColBloq,{|u|if(PCount()>0,cComboBloq:=u,cComboBloq)}, aB1_MSBLQL,50,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboBloq')
     	
    TSay():New(010, nColPIni,{|| "Produto de" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 021, nColPIni MSGet _cB1_CODINI Of oDialog   F3 "SB1"  PIXEL SIZE 070, 009 
	
	TSay():New(010, nColPFim,{|| "Produto ate" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 021, nColPFim MSGet _cB1_CODFIM Of oDialog   F3 "SB1"  PIXEL SIZE 070, 009 

    TSay():New(010, nColGIni,{|| "Grupo de" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 021, nColGIni MSGet _cB1_GRUPOINI Of oDialog F3 "SBM"  PIXEL SIZE 060, 009 
	                                                                             
    TSay():New(010, nColGFim,{|| "Grupo até" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 021, nColGFim MSGet _cB1_GRUPOFIM Of oDialog F3 "SBM"  PIXEL SIZE 060, 009 

    TSay():New(010, nColCrit, {|| "Criticidade" },oDialog,,,.F.,.F.,.F.,.T.,,,70,008)
    cComboCrit:= aB1_ZITEMZ[1]
    TComboBox():New(021,nColCrit,{|u|if(PCount()>0,cComboCrit:=u,cComboCrit)}, aB1_ZITEMZ,60,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboCrit')
	                                                                             
    TSay():New(010, nColDive, {|| "Exibição" },oDialog,,,.F.,.F.,.F.,.T.,,,70,008)
    cComboDive:= aDivergencia[1]
    TComboBox():New(021,nColDive,{|u|if(PCount()>0,cComboDive:=u,cComboDive)}, aDivergencia,80,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboDive')
	                                                                             
    TSay():New(034, nColOrde, {|| "Ordenação" },oDialog,,,.F.,.F.,.F.,.T.,,,70,008)
    cComboOrde:= aOrdenacao[1]
    TComboBox():New(045,nColOrde,{|u|if(PCount()>0,cComboOrde:=u,cComboOrde)}, aOrdenacao,60,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboOrde')
      
    TSay():New(034, nColSld, {|| "Apenas c/ Saldo?" },oDialog,,,.F.,.F.,.F.,.T.,,,70,008)
    cComboSaldo:= aSaldo[1]
    TComboBox():New(045,nColSld,{|u|if(PCount()>0,cComboSaldo:=u,cComboSaldo)}, aSaldo,60,10,oDialog,, ,,,,.T.,,,,,,,,,'cComboSaldo')
                          
    //Botões de processamento
    TButton():New(045, 232, OemToAnsi("&Filtrar")  , oDialog,{|| S0401SB1("N")   },83, 010,,,,.T.,,,,{|| })
    TButton():New(045, 352, OemToAnsi("&Atualizar"), oDialog,{|| S0401ATU()   },83, 010,,,,.T.,,,,{|| })
    TButton():New(045, 472, OemToAnsi("&Planilha") , oDialog,{|| S0401EXCEL()   },83, 010,,,,.T.,,,,{|| })
   
    aColHeader := {"Codigo", "Descrição", "Classificação XYZ", "Saldo Atual", "Custo Total", "Consumo Período", "EM Atual", "EM Sugerido", "PP Atual", "PP Sugerido", "EM Ajustado", "PP Ajustado"}
    aColSize   := { 50     ,         200,                  80,            70,            70,                60,         40,            40,         40,            40,            40,            40}
    
    oGrid := TCBrowse():New(70,005,aPosObj[2][4] - 5, aPosObj[2][3] - 85,,aColHeader, aColSize ,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    

	oGrid:bLDblClick   := {||sEDCAMPO(),oGrid:ColPos := 1,oGrid:SetFocus()}	
      
    S0401SB1("S") 
 
    oDialog:Activate(,,,.T.)

    Return       
    
Static Function sEDCAMPO()
	if oGrid:ColPos = 11
	    lEditCell(@aGrid,oGrid,PesqPict("SE2","E2_VALOR",TamSX3("E2_VALOR")[1]), 11)
	    if empty(aGrid[oGrid:nat][11])
            if MsgYesNo("Foi informado 0 (ZERO) para o ESTOQUE MÍNIMO deste produto. Confirma a alteração?", "Atencao!")   
	            aGrid[oGrid:nat][13] := .T.
	        else
	            aGrid[oGrid:nat][13] := .F.
	        endif
	    else
	        aGrid[oGrid:nat][13] := .T.
	    endif
	elseif oGrid:ColPos = 12
	    lEditCell(@aGrid,oGrid,PesqPict("SE2","E2_VALOR",TamSX3("E2_VALOR")[1]), 12)
	    if empty(aGrid[oGrid:nat][12])
            if MsgYesNo("Foi informado 0 (ZERO) para o PONTO DE PEDIDO deste produto. Confirma a alteração?", "Atencao!")   
	            aGrid[oGrid:nat][14] := .T.
	        else
	            aGrid[oGrid:nat][14] := .F.
	        endif
	    else
	        aGrid[oGrid:nat][14] := .T.
	    endif
	else
	    return
    endif
    oGrid:Refresh()
    oDialog:refresh()
    
  	Return

Static Function S0401SB1(pPRIMEIRO) 
    if sAlterados() <> 0 
       if !MsgYesNo("Existem registros com PONTO DE PEDIDO/ESTOQUE MÍNIMO informados. " + chr(13) + "Filtrar registros irá causar a sua perda. " + chr(13) + chr(13) + "Deseja continuar ?", "Atencao!")   
           return
       endif 
    endif
    MsAguarde({|| S0401SQL(pPRIMEIRO)}, "Aguarde ...") 
    
    Return
    
Static Function S0401SQL(pPRIMEIRO)
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQuerySB1 := " Select B1_COD, "
    cQuerySB1 += "     B1_DESC, "
    cQuerySB1 += "     B1_ZITEMZ, "
    cQuerySB1 += "     B2_QATU, "
    cQuerySB1 += "     B2_VATU1, "
    cQuerySB1 += "     B1_EMIN   B1_PPEATU, "
    cQuerySB1 += "     B1_ESTSEG B1_EMIATU, " 
    cQuerySB1 += "     B1_UM " 
    cQuerySB1 += " FROM " + RetSqlName("SB2") + " SB2 with (nolock),"
    cQuerySB1 += "      " + RetSqlName("SB1") + " SB1 with (nolock)"
    cQuerySB1 += " WHERE SB1.D_E_L_E_T_ <> '*' "
	cQuerySB1 += "   AND SB2.D_E_L_E_T_ <> '*' "
	cQuerySB1 += "   AND B1_FILIAL = '" + xFILIAL("SB1") + "' "
	cQuerySB1 += "   AND B1_COD = B2_COD"
	cQuerySB1 += "   AND B2_FILIAL = '" + xFILIAL("SB2") + "' "
	cQuerySB1 += "  "
	cQuerySB1 += "   AND B2_LOCAL = '01'"
	
    if pPRIMEIRO = "S"
         cQuerySB1 += "   AND 1 = 0"
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
    if cComboBloq = "Nao"
         cQuerySB1 += "   AND B1_MSBLQL  = '2' "        
    elseif cComboBloq = "Sim"
         cQuerySB1 += "   AND B1_MSBLQL  = '1' "        
    endif
    
    if cComboCrit = "Em Branco"
         cQuerySB1 += "   AND B1_ZITEMZ  = ' ' "        
    elseif cComboCrit = 'Todos'
        cQuerySB1 += ""
    else
         cQuerySB1 += "   AND B1_ZITEMZ  = '" + AllTrim(cComboCrit) + "' "        
    endif
    
    Do Case             
        Case cComboSaldo = "Sim" 
            cQuerySB1 += "  AND B2_QATU > 0 "
    end case   
    
    Do Case             
        Case cComboOrde = "Cod" 
            cQuerySB1 += " ORDER BY B1_COD "
        Case cComboOrde = "Desc" 
            cQuerySB1 += " ORDER BY B1_DESC "
    end case   
    

    cQuerySB1 := UPPER(cQuerySB1)
    
    If Select("QRYSB1") > 0
        QRYSB1->(dbCloseArea())
    EndIf
                
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuerySB1),"QRYSB1",.F.,.T.)                                               
    dbSelectArea("QRYSB1")
    QRYSB1->(dbGoTop())        

    aGrid := {}   
    
    // Recuperando ultimo motivo e Justificativa de negociação para o titulo
    cQuery := " Select MAX(ZP9_DTREF) ZP9_DTREF"
    cQuery += " FROM " + RetSqlName("ZP9") + " with (nolock) "
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND ZP9_FILIAL = '" + xFILIAL("ZP9") + "' "
    
    If Select("QRYZP9") > 0
        QRYZP9->(dbCloseArea())
    EndIf
                    
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYZP9",.F.,.T.)                                               
    dbSelectArea("QRYZP9")
    QRYZP9->(dbGoTop())  
    
//    dDataFim := LastDay(STOD(QRYZP9->ZP9_DTREF + '01')) + 1

    cZP9_DTREF := Substr(_cDTREFINI, 3, 4) + Substr(_cDTREFINI, 1, 2)
//    dDataIni := STOD(cZP9_DTREF + '01')
    
    While QRYSB1->(!Eof())         
        // Recuperando os dados da ZP9 para calculo dos valores sugeridos
        cQuery := " Select MIN(ZP9_DTREF) ZP9_DTREF, "
        cQuery += "     SUM(ZP9_QTDSAI) ZP9_QTDSAI, "
        cQuery += "     sum(CASE ZP9_QTDSAI WHEN 0 THEN 0 ELSE 1 END) ZP9_SAIMES, "
        cQuery += "     SUM(ZP9_MEDRES) ZP9_MEDRES, "
        cQuery += "     sum(CASE ZP9_MEDRES WHEN 0 THEN 0 ELSE 1 END) ZP9_ENTMES"
        cQuery += " FROM " + RetSqlName("ZP9") + " with (nolock) "
        cQuery += " WHERE D_E_L_E_T_ <> '*' "
        cQuery += "   AND ZP9_FILIAL = '" + xFILIAL("ZP9") + "' " 
        cQuery += "   AND ZP9_PRODUT = '" + QRYSB1->B1_COD + "' " 
        cQuery += "   AND ZP9_DTREF >= '" + cZP9_DTREF + "' "
        
        If Select("QRYZP9") > 0
            QRYZP9->(dbCloseArea())
        EndIf
                        
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYZP9",.F.,.T.)                                               
        dbSelectArea("QRYZP9")
        QRYZP9->(dbGoTop())  
       
        if empty(QRYZP9->ZP9_MEDRES)
            nEM_Sugerido := 0
            nPP_Sugerido := 0
        else
            //xDataIni := STOD(sDataINI() + '01')
            
            //if xDataIni > dDataIni
            //    nMeses := DateDiffMonth (xDataINI, dDataFim)
            //else
            //    nMeses := DateDiffMonth (dDataINI, dDataFim)
            //endif
            	
            nMeses := QRYZP9->ZP9_SAIMES
            
            nEM_Sugerido := (QRYZP9->ZP9_QTDSAI / nMeses) * ((4 + (QRYZP9->ZP9_MEDRES / QRYZP9->ZP9_ENTMES)) / 30)
            nEM_Sugerido := round(nEM_Sugerido, 2)
            nPP_Sugerido := QRYZP9->ZP9_QTDSAI / nMeses
            nPP_Sugerido := nPP_Sugerido * ((4 + (QRYZP9->ZP9_MEDRES / QRYZP9->ZP9_ENTMES)) / 30)
            nPP_Sugerido := nPP_Sugerido * 2 * 1.15
            
            if QRYSB1->B1_UM = 'UN'
                nPP_Aux := nPP_Sugerido
                nPP_Sugerido := round(nPP_Sugerido, 0)
                if nPP_Aux > nPP_Sugerido
                    nPP_Sugerido += 1
                endif
            else
                nPP_Sugerido := round(nPP_Sugerido, 2)
            endif
        endif
        
        bInserir := .F.
        if cComboDive = "Com Divergência" .and. (QRYSB1->B1_EMIATU <> nEM_Sugerido .or.  QRYSB1->B1_PPEATU = nPP_Sugerido)
            bInserir := .T.
        elseif cComboDive = "Sem Divergência" .and. QRYSB1->B1_EMIATU = nEM_Sugerido .and.  QRYSB1->B1_PPEATU = nPP_Sugerido
            bInserir := .T.
        elseif cComboDive = "Todos"
            bInserir := .T.
        endif
        
        if bInserir 
              AAdd(aGrid,{QRYSB1->B1_COD,;
                QRYSB1->B1_DESC,;
                QRYSB1->B1_ZITEMZ,;
                QRYSB1->B2_QATU,;
                QRYSB1->B2_VATU1,;
                QRYZP9->ZP9_QTDSAI,;
                QRYSB1->B1_EMIATU,;
                nEM_Sugerido,;
                QRYSB1->B1_PPEATU,;
                nPP_Sugerido,;
                0,;
                0,;
                .F.,;
                .F.})       
        endif
        QRYSB1->(dbSkip())
    EndDo                                        
    
    if len(aGrid) = 0
        aGrid := {{"", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, .F., .F.}} 
        if pPRIMEIRO = 'N'
             Aviso("Nenhum Produto","Atenção, Nenhum Produto foi encontrado com os filtros informados.",{"&Retornar"})       
        endif
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
				       aGrid[oGrid:nAt][9],;
				       aGrid[oGrid:nAt][10],;
				       aGrid[oGrid:nAt][11],;
				       aGrid[oGrid:nAt][12]}}
      
    oGrid:Refresh()
    oDialog:Refresh()     
    
    Return
    
Static Function sAlterados
	Local nLinha
    nAlterado := 0
    for nLinha := 1 to len(aGrid)
	     if aGrid[nLinha][13] .or. aGrid[nLinha][14]
	         nAlterado += 1 
	     endif
    next 
    
    return nAlterado  

/*
Static Function sDataIni()
   // Recuperando os dados da ZP9 para calculo dos valores sugeridos
    cQuery := " Select MIN(ZP9_DTREF) ZP9_DTREF"
    cQuery += " FROM " + RetSqlName("ZP9") + " with (nolock) "
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += "   AND ZP9_FILIAL = '" + xFILIAL("ZP9") + "' " 
    cQuery += "   AND ZP9_PRODUT = '" + QRYSB1->B1_COD + "' " 
    cQuery += "   AND ZP9_DTREF >= '" + cZP9_DTREF + "' "
    cQuery += "   AND ZP9_QTDSAI > 0 " 
    If Select("QRYMIN") > 0
        QRYMIN->(dbCloseArea())
    EndIf
                    
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYMIN",.F.,.T.)                                               
    dbSelectArea("QRYMIN")
    QRYMIN->(dbGoTop())  

    return QRYMIN->ZP9_DTREF
*/

Static Function S0401ATU()
    Local cUserNome := UsrRetName(RetCodUsr())
    Local nlinha
    if sAlterados() = 0
       return
    endif
    
    if !MsgYesNo("Confirma atualização do PONTO DE PEDIDO/ESTOQUE MÍNIMO informados?", "Atencao!")   
       return
    endif 
   
    DBSelectArea("ZPA")
    DBSelectArea("SB1")                      
    
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
    for nlinha := 1 to len(aGrid)
	    if aGrid[nLinha][13] .or. aGrid[nLinha][14]
            Reclock("ZPA", .T.)   
            ZPA->ZPA_FILIAL := xFilial("ZPA") 
            ZPA->ZPA_PRODUT := aGrid[nlinha][1]
            ZPA->ZPA_DATA   := cData
            ZPA->ZPA_HORA   := cHora
            ZPA->ZPA_PPEANT := aGrid[nlinha][9]
            if aGrid[nLinha][14]
                ZPA->ZPA_PPEATU := aGrid[nlinha][12]
            endif
            ZPA->ZPA_MINANT := aGrid[nlinha][7]
            if aGrid[nLinha][13]
                 ZPA->ZPA_MINATU := aGrid[nlinha][11]
            endif
            ZPA->ZPA_USER   := cUserNome
            ZPA->(MsUnLock())        
        endif
	
        If SB1->(DbSeek(xFilial("SB1") + aGrid[nlinha][1]))
		     Reclock("SB1",.F.)
		     if aGrid[nLinha][14]
                SB1->B1_EMIN := aGrid[nlinha][12]
            endif
            if aGrid[nLinha][13]
                SB1->B1_ESTSEG := aGrid[nlinha][11]
            endif  
            SB1->B1_EMAX := SB1->B1_EMIN + SB1->B1_LE
            SB1->(MsUnLock())       
        endif
        aGrid[nLinha][13] := .F.
        aGrid[nLinha][14] := .F.
    next 
    
    S0401SB1("N")
                
    bTC04A010 := .T.
    
    return .T.

Static Function S0401EXCEL()
    Processa({ || S0401XLS()}, "Gerando arquivo EXCEL ...." )

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
	cTable := "Validação Order Point"
        
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
	    if aGrid[nLinha][13] .or. aGrid[nLinha][14]
	        oFwMsEx:AddRow( cWorkSheet, cTable,  {aGrid[nLinha,01],;
                                                  aGrid[nLinha,02],;
		                                          aGrid[nLinha,03],;
		                                          aGrid[nLinha,04],;
			                                      aGrid[nLinha,05],;
			                                      aGrid[nLinha,06],;
			                                      aGrid[nLinha,07],;
			                                      aGrid[nLinha,08],;
			                                      aGrid[nLinha,09],;
			                                      aGrid[nLinha,10],;
			                                      aGrid[nLinha,11],;
			                                      aGrid[nLinha,12]})  
        endif
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
