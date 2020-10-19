#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"                                                                                                   

/*                                                                                                                                                                               
Programa : TC06A010 
Autor    : ITUPSUL
Data     : 08/06/2019                                                                                                                                                  
Desc.    : Inclusão/Alteração de Motivo de Negociação
Uso      : TCP
*/
User Function TC06A010()  
             
    Local aSize  := MsAdvSize()
	Local aItensOrdenacao:= {"Cod Cli", "Nome", "Num Titulo", "Vencimento", "Valor"} 
	
    Private lMarcados      := .F.  
    Private oGrid          := Nil       
    Private aGrid          := {}
    Private _dEmiIni       := date()
    Private _dEmiFin       := date()
    Private _dVctoIni      := date()
    Private _dVctoFin      := date()  
    Private _cA1_XGREMPR   := space(TamSX3('A1_XGREMPR')[1])  
    Private _cA1_CLIENTE   := space(TamSX3('A1_COD')[1])
    
    Private cCadastro         := "Inclusão/Alteração de Motivo de Negociação"
    
    Private nQtdTitulos := 0    
    Private nVlrTitulos := 0   
    Private nQtdSelec := 0
    Private nVlrSelec := 0               
    
    DbSelectArea("ZZR")    
    
    // Variavel criada para controlar a segunda chamada desta função logo após a informação de motivos de negociação 
    Public bTC06A010
    
    if Valtype(bTC06A010) = "L" 
        if bTC06A010
           bTC06A010 := .F.
           return
        endif
    endif
    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,,oMainWnd,.T.)
    oDialog:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.

    aObjects := {}  
    AAdd( aObjects, {  0,       65, .T., .F. } )        
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )    
    
    if aSize[3] >= 750
        nColGru := 012
        nColCli := 102
        nColEIni := 190
        nColEFim := 265
        nColVIni := 340
        nColVFim := 425
        nColOrd  := 500
        nColFil  := 610
    else
        nColGru := 007
        nColCli := 092
        nColEIni := 160+72
        nColEFim := 232+72
        nColVIni := 290
        nColVFim := 370
        nColOrd  := 430
        nColFil  := 530
    endif
    
    TSay():New(015, nColGru,{|| "Grupo Empr." },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 013, nColGru + 33 MSGet _cA1_XGREMPR Of oDialog F3 "SX5GR" Valid sA1_XGREMPR() PIXEL SIZE 040, 009 
	                                                                             
    TSay():New(035, nColGru,{|| "Cliente" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 033, nColGru + 33 MSGet _cA1_CLIENTE  F3 "SA1"  Valid sA1_COD() Of oDialog PIXEL SIZE 040, 009 
	                                                                             
    TSay():New(015, nColEIni,{|| "Emissão de" },oDialog,,,.F.,.F.,.F.,.T.,,,40,008)
    @ 013, nColEIni + 35 MSGet _dEmiIni Picture "@D"  Valid sDEMIINI() Of oDialog PIXEL SIZE 040, 009
	                
    TSay():New(035, nColEIni,{|| "Emissão até" },oDialog,,,.F.,.F.,.F.,.T.,,,40,006)
    @ 033, nColEIni + 35 MSGet _dEmiFin  Picture "@D" Valid sDEMIFIN() Of oDialog PIXEL SIZE 040, 009 
	                                                                             
    TSay():New(055, nColEIni,{|| "Vencto de" },oDialog,,,.F.,.F.,.F.,.T.,,,40,008)
    @ 053, nColEIni + 35 MSGet _dVctoIni Picture "@D" Valid sDVCTOINI() Of oDialog PIXEL SIZE 040, 009
	                
    TSay():New(075, nColEIni,{|| "Vencto até" },oDialog,,,.F.,.F.,.F.,.T.,,,40,006)
    @ 073, nColEIni + 35 MSGet _dVctoFin  Picture "@D" Valid sDVCTOFIN() Of oDialog PIXEL SIZE 040, 009 
	
	TSay():New(055, nColGru, {|| "Ordenação" },oDialog,,,.F.,.F.,.F.,.T.,,,200,008)
    cCombo1:= aItensOrdenacao[1]
    oCombo1 := TComboBox():New(053,nColGru + 33,{|u|if(PCount()>0,cCombo1:=u,cCombo1)}, aItensOrdenacao,60,10,oDialog,,{ || Ordenacao()},,,,.T.,,,,,,,,,'cCombo1')
                         
    //Botões de processamento
    TButton():New(005, nColFil+50, OemToAnsi("&Filtrar"), oDialog,{|| S0601SE1("N")   },83, 020,,,,.T.,,,,{|| })
   
    TSay():New(005, nColOrd + 30,{|| "Qtd Títulos Cliente" },oDialog,,,.F.,.F.,.F.,.T.,,,070,006)
    @ 013, nColOrd + 30 MSGet nqtdTitulos    When .F. Picture "@E 999,999" PIXEL SIZE 060, 009 
    
    TSay():New(025, nColOrd + 30,{|| "Valor Títulos Cliente" },oDialog,,,.F.,.F.,.F.,.T.,,,060,006)
    @ 033, nColOrd + 30 MSGet nVlrTitulos    When .F. Picture "@E 999,999,999.99" PIXEL SIZE 060, 009  
    
    TSay():New(045, nColOrd + 30,{|| "Qtd Títulos Selec." },oDialog,,,.F.,.F.,.F.,.T.,,,070,006)
    @ 053, nColOrd + 30 MSGet nQtdSelec    When .F. Picture "@E 999,999" PIXEL SIZE 060, 009 
    
    TSay():New(065, nColOrd + 30,{|| "Valor Títulos Selec." },oDialog,,,.F.,.F.,.F.,.T.,,,070,006)
    @ 073, nColOrd + 30 MSGet nVlrSelec    When .F. Picture "@E 999,999,999.99" PIXEL SIZE 060, 009 
	
    TButton():New(28, nColFil+50, OemToAnsi("&Atualizar"), oDialog,{|| S0601ZZR()      },83, 020,,,,.T.,,,,{|| })
    
    obtnClose := TButton():New(62, nColFil+50, OemToAnsi("&Sair"), oDialog,{|| oDialog:End()     },83, 020,,,,.T.,,,,{|| })
    obtnClose:SetColor(CLR_HBLUE)

    aColHeader := {" ", " ", "Cod", "Loja", "Nome Cliente", "Num NF", "Prefixo", "Titulo", "Parcela", "Tipo", "Valor(R$)", "Saldo Rec", "Emissão", "Vcto Real", "Dias", "Motivo", "Contato", "Justificativa"}
    aColSize   := { 10,  10,    40,     20,            180,       40,        25,       40,        20,     20,          40,          40,        35,         35,      20,       25,       150,             250}

    oGrid := TWBrowse():New(90,005,aPosObj[2][4], aPosObj[2][3] - 85,,aColHeader,aColSize,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
        
    oCheck1 := TCheckBox():New(99, 15, ' ', {|| lMarcados} ,oDialog, 100, 210,, {|| S0601MARCA()},,,,,,.T.,,,)
       
    oGrid:bLDblClick := {|| aGrid[oGrid:nAt][1] := !aGrid[oGrid:nAt][1], S0601SOMAR(),oCheck1:setFocus(),oGrid:setFocus()}
    
    S0601SE1("S") 
 
    oDialog:Activate(,,,.T.)

    Return       

User Function NumeroNF (PE1_YNF1, PE1_YNF2, PE1_YNF3, PE1_YNF4, PE1_YNF5, PE1_YNF6)
    Local x
    local cRetorno := Alltrim(PE1_YNF1)
    
    if !empty (cRetorno) .AND. !empty (PE1_YNF2)
        cRetorno += "/" 
        cRetorno += Alltrim(PE1_YNF2)
    endif
    if !empty (cRetorno) .AND. !empty (PE1_YNF3)
        cRetorno += "/" 
        cRetorno += Alltrim(PE1_YNF3)
    endif
    if !empty (cRetorno) .AND. !empty (PE1_YNF4)
        cRetorno += "/" 
        cRetorno += Alltrim(PE1_YNF4)
    endif
    if !empty (cRetorno) .AND. !empty (PE1_YNF5)
        cRetorno += "/" 
        cRetorno += Alltrim(PE1_YNF5)
    endif
    if !empty (cRetorno) .AND. !empty (PE1_YNF6)
        cRetorno += "/" 
        cRetorno += Alltrim(PE1_YNF6)
    endif
    
    return cRetorno

Static Function Ordenacao
    
    local nCampo,x := 1 
    
    RETURN
    
    Do Case             
        Case cCombo1 = "Cod Cli" 
            nCampo := 02
        Case cCombo1 = "Nome" 
            nCampo := 04
        Case cCombo1 = "Num Titulo" 
            nCampo := 07
        Case cCombo1 = "Vencimento" 
            nCampo := 13
        Case cCombo1 = "Valor" 
            nCampo := 10
    end case   
    
    bordenado := .F.
    while !bordenado
        bordenado := .T.
        for x := 1 to len(aGrid) - 1      
            if (ncampo = 02 .or. ncampo = 04) .and. aGrid [x, nCampo] > aGrid [x + 1, nCampo]
                a := aGrid[x] 
                aGrid [x] := aGrid [x + 1]
                aGrid [x + 1] := a
                bOrdenado := .F.
            elseif aGrid [x, nCampo] < aGrid [x + 1, nCampo]
                a := aGrid[x] 
                aGrid [x] := aGrid [x + 1]
                aGrid [x + 1] := a
                bOrdenado := .F.
            end if
        next
    end do 
          
    oGrid:Refresh()
    return

Static Function SDEMIINI
    if empty(_dEMIINI)        
	     MSGALERT("Data de emissão inicial não informada.","Alerta")
	     return .F.
    elseif _dEMIINI > date()        
	     MSGALERT('Data de emissão inicial maior que a data do sistema.','Atencao!!!')
	     return .F.
	endif
    
    return .T.                                               

Static Function SDEMIFIN
    if empty(_DEMIFIN)        
	     MSGALERT("Data de emissão final não informada.","Alerta")
	     return .F.
    elseif _DEMIFIN > date()        
	     MSGALERT('Data de emissão final maior que a data do sistema.','Atencao!!!')
	     return .F.
	  endif
    
    return .T.                                               
Static Function SDVCTOFIN
    if empty(_DVCTOFIN)        
	     MSGALERT("Data de vencimento final não informada.","Alerta")
	     return .F.
    elseif _DVCTOFIN > date()        
	     MSGALERT('Data de vencimento final maior que a data do sistema.','Atencao!!!')
	     return .F.
	  endif
    
    return .T.                                               
Static Function SDVCTOINI
    if empty(_DVCTOINI)        
	     MSGALERT("Data de vencimento inicial não informada.","Alerta")
	     return .F.
    elseif _DVCTOINI > date()        
	     MSGALERT('Data de vencimento inicial maior que a data do sistema.','Atencao!!!')
	     return .F.
	  endif
    
    return .T.                                               

Static Function sA1_XGREMPR()   
    Local iSX5     	:= RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 

    if Empty(_cA1_XGREMPR)
        return .T.
    endif
    
    DbSelectArea("SX5")      
	SX5->(DbSetOrder(iSX5))
	If SX5->(DbSeek(xFilial("SX5")+"GR"+_cA1_XGREMPR))
        return .T.
    else
        Aviso("Grupo Empresarial Inválido","Atenção, Grupo Empresarial não cadastrado.",{"&Retornar"})       
        return .F. 
    endif
    
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

Static Function sA1_COD()   
    if Empty(_cA1_CLIENTE)
        return .T.
    endif
    
    DbSelectArea("SA1")      
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+_cA1_CLIENTE))
        return .T.
    else
        Aviso("Cliente Inválido","Atenção, Cliente não cadastrado.",{"&Retornar"})       
        return .F. 
    endif

Static Function S0601SOMAR ()    
    Local i := 0
    nQtdSelec := 0
    nVlrSelec := 0
    for i := 1 to len(aGrid)
        if aGrid[i][1] = .T.
            nQtdSelec += 1
            nVlrSelec += aGrid[i][11]
        endif
    next i

    // oGrid:Refresh()
    // oGrid:setFocus()

    // oDialog:Refresh() 
        
return 
    
Static Function S0601MARCA ()                            
    Local i   := 0
    lMarcados := !lMarcados
    
    for i := 1 to len(aGrid)
        if lMarcados 
            aGrid[i][1] := .T.
        else 
            aGrid[i][1] := .F.
        endif
    next i    

    S0601SOMAR()

    oGrid:SetArray(aGrid)
    
    oGrid:bLine := {||{,;
        Iif(aGrid[oGrid:nAt][1],LoadBitmap( GetResources(),"LBOK" ),LoadBitmap( GetResources(),"LBNO" )),;			
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
			    aGrid[oGrid:nAt][15],;
			    aGrid[oGrid:nAt][16],;
			    aGrid[oGrid:nAt][17]}}
  			
    oGrid:Refresh()
    oGrid:setFocus()

    oDialog:refresh()

return

Static Function S0601SE1(pPRIMEIRO) 
    MsAguarde({|| S0601SQL(pPRIMEIRO)}, "Aguarde ...") 
    
Return
    
Static Function S0601SQL(pPRIMEIRO)
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQuerySE1 := " Select E1_CLIENTE, "
    cQuerySE1 += "     E1_LOJA, "
    cQuerySE1 += "     A1_NOME, "
    cQuerySE1 += "     E1_XNUMOS, "
    cQuerySE1 += "     E1_NUM, "
    cQuerySE1 += "     E1_YNF1, "
    cQuerySE1 += "     E1_YNF2, "
    cQuerySE1 += "     E1_YNF3, "
    cQuerySE1 += "     E1_YNF4, "
    cQuerySE1 += "     E1_YNF5, "
    cQuerySE1 += "     E1_YNF6, "
    cQuerySE1 += "     E1_PREFIXO, "
    cQuerySE1 += "     E1_PARCELA, "
    cQuerySE1 += "     E1_TIPO, "
    cQuerySE1 += "     E1_EMISSAO, "
    cQuerySE1 += "     E1_VENCREA, "
    cQuerySE1 += "     E1_VALOR, "
    cQuerySE1 += "     E1_SALDO, "
    cQuerySE1 += "     SE1.R_E_C_N_O_ nRECNO " 
    cQuerySE1 += " FROM " + RetSqlName("SE1") + " SE1 with (nolock),"
    cQuerySE1 += "      " + RetSqlName("SA1") + " SA1 with (nolock)"
    cQuerySE1 += " WHERE SE1.D_E_L_E_T_ <> '*' "
	cQuerySE1 += "   AND SA1.D_E_L_E_T_ <> '*' "
	cQuerySE1 += "   AND A1_FILIAL = '" + xFILIAL("SA1") + "' "
	cQuerySE1 += "   AND E1_CLIENTE = A1_COD"
	cQuerySE1 += "   AND E1_LOJA = A1_LOJA"
    cQuerySE1 += "   AND E1_FILIAL = '" + xFILIAL("SE1") + "' "        
                                                                       
    if !Empty(_cA1_XGREMPR)
         cQuerySE1 += "   AND A1_XGREMPR = '" + _cA1_XGREMPR + "' "
    endif
    if !Empty(_cA1_CLIENTE)
         cQuerySE1 += "   AND E1_CLIENTE = '" + _cA1_CLIENTE + "' "        
    endif
    
    cQuerySE1 += "   AND E1_EMISSAO >= '" + DtoS(_dEmiIni) + "' " 
    cQuerySE1 += "   AND E1_EMISSAO <= '" + DtoS(_dEmiFin) + "' "       
    
    cQuerySE1 += "   AND E1_VENCREA >= '" + DtoS(_dVctoIni) + "' " 
    cQuerySE1 += "   AND E1_VENCREA <= '" + DtoS(_dVctoFin) + "' "       
    
    cQuerySE1 += "   AND E1_SALDO > 0 " 

    Do Case             
        Case cCombo1 = "Cod Cli" 
            cQuerySE1 += " ORDER BY E1_CLIENTE, E1_LOJA "
        Case cCombo1 = "Nome" 
            cQuerySE1 += " ORDER BY A1_NOME "
        Case cCombo1 = "Num Titulo" 
            cQuerySE1 += " ORDER BY E1_NUM, E1_PARCELA "
        Case cCombo1 = "Vencimento" 
            cQuerySE1 += " ORDER BY E1_VENCREA DESC "
        Case cCombo1 = "Valor" 
            cQuerySE1 += " ORDER BY E1_VALOR DESC "
    end case   
 

    cQuerySE1 := UPPER(cQuerySE1)
    
    If Select("QRY_SE1") > 0
        QRY_SE1->(dbCloseArea())
    EndIf
                
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuerySE1),"QRY_SE1",.F.,.T.)                                               
    dbSelectArea("QRY_SE1")
    QRY_SE1->(dbGoTop())        

    aGrid := {}   
    
    nQtdTitulos := 0      
    nVlrTitulos := 0     
    nQtdSelec := 0
    nVlrSelec := 0
    While QRY_SE1->(!Eof())         
        dE1_VENCREA := AllTrim(DTOC(STOD(QRY_SE1->E1_VENCREA)))
        dE1_EMISSAO := AllTrim(DTOC(STOD(QRY_SE1->E1_EMISSAO)))   
        nE1_DIAS := DateDiffDay(STOD(QRY_SE1->E1_EMISSAO), date())
                                                                               
        //cSA1_NOME := SA1_NOME(QRY_SE1->E1_CLIENTE, QRY_SE1->E1_LOJA)   
        
        // Recuperando ultimo motivo e Justificativa de negociação para o titulo
        cQuery := " Select ZZR_MOTIVO, "
        cQuery += "     ZZR_JUSTIF, "
        cQuery += "     ZZR_CONTAT, "
        cQuery += "     ZZR_DATA, "
        cQuery += "     ZZR_HORA, "
        cQuery += "     ZZR_USER " 
        cQuery += " FROM " + RetSqlName("ZZR") + " with (nolock) "
        cQuery += " WHERE D_E_L_E_T_ <> '*' "
        cQuery += "   AND ZZR_FILIAL = '" + xFILIAL("ZZR") + "' " 
        cQuery += "   AND ZZR_PREFIX = '" + QRY_SE1->E1_PREFIXO + "' " 
        cQuery += "   AND ZZR_NUM    = '" + QRY_SE1->E1_NUM + "' " 
        cQuery += "   AND ZZR_PARCEL = '" + QRY_SE1->E1_PARCELA + "' " 
        cQuery += "   AND ZZR_TIPO   = '" + QRY_SE1->E1_TIPO + "' "    
        cQuery += " ORDER BY ZZR_DATA DESC, ZZR_HORA DESC "     
        
        If Select("QRY_ZZR") > 0
            QRY_ZZR->(dbCloseArea())
        EndIf
                        
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_ZZR",.F.,.T.)                                               
        dbSelectArea("QRY_ZZR")
        QRY_ZZR->(dbGoTop())  
                            
        AAdd(aGrid,{ .F.,;
                  AllTrim(QRY_SE1->E1_CLIENTE),;
                  AllTrim(QRY_SE1->E1_LOJA),;
                  AllTrim(QRY_SE1->A1_NOME),;
                  AllTrim(U_NumeroNF(QRY_SE1->E1_YNF1, QRY_SE1->E1_YNF2, QRY_SE1->E1_YNF3, QRY_SE1->E1_YNF4, QRY_SE1->E1_YNF5, QRY_SE1->E1_YNF6 )),;
                  AllTrim(QRY_SE1->E1_PREFIXO),;
                  AllTrim(QRY_SE1->E1_NUM),;
                  AllTrim(QRY_SE1->E1_PARCELA),;
                  AllTrim(QRY_SE1->E1_TIPO),;
                  QRY_SE1->E1_VALOR,;
                  QRY_SE1->E1_SALDO,;
                  dE1_EMISSAO,; 
                  dE1_VENCREA,;           
                  nE1_DIAS,;                                 
                  sZZR_DscMotivo(QRY_ZZR->ZZR_MOTIVO),;
                  AllTrim(QRY_ZZR->ZZR_CONTAT),;
                  AllTrim(QRY_ZZR->ZZR_JUSTIF),;
                  QRY_SE1->nRECNO})       
                  
        nQtdTitulos += 1
        nVlrTitulos += QRY_SE1->E1_SALDO
        
        QRY_SE1->(dbSkip())
    EndDo                                        
    
    if len(aGrid) = 0
        aGrid := {{.F., "", "", "", "", "", "", "", "", 0, 0, "", "", 0, "", "", "", 0}} 
        if pPRIMEIRO = 'N'
             Aviso("Nenhum Título","Atenção, Nenhum Título foi encontrado com os filtros informados.",{"&Retornar"})       
        endif
    endif

    oGrid:SetArray(aGrid)                    
                            //   LoadBitmap(GetResources(), aGrid[oGrid:nAt][2]),;
    oGrid:bLine := {||{,;
        Iif(aGrid[oGrid:nAt][1],LoadBitmap( GetResources(),"LBOK" ),LoadBitmap( GetResources(),"LBNO" )),;
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
        aGrid[oGrid:nAt][15],;
        aGrid[oGrid:nAt][16],;
        aGrid[oGrid:nAt][17]}}
      
    oGrid:Refresh()
        
    oDialog:Refresh()     
        
    Ordenacao()

Return
        
Static Function SA1_NOME (cA1_COD, cA1_LOJA)
    cQuery := " Select A1_NOME "
    cQuery += " From " + RetSqlName("SA1") + " SA2 with (nolock) "
    cQuery += " Where A1_COD = '" + cA1_COD + "'"      
    cQuery += "   and A1_LOJA = '" + cA1_LOJA + "'"      
    cQuery += "   and D_E_L_E_T_ <> '*' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)
    dbSelectArea("QRY")
                         
return QRY->A1_NOME

Static Function SMARCADOS
    Local nLinha    := 0
    nMarcado        := 0
    for nlinha := 1 to len(aGrid)
	     if aGrid[nLinha][1]
	         nMarcado += 1 
	     endif
    next 
    
    if nMarcado = 0
        MSGALERT("Favor Selecionar Título(s).","Alerta")
    endif
return nMarcado    

Static Function s0601ZZR ()  
    Local aSize   := {}
    Local _lRet   := .f.  
    
    Local bOk     := {|| _lRet := .T., iif(sINCGRAVA(), oDlg:End(),"")}
    Local bCancel := {|| _lRet := .F., oDlg:End()}  
    Local cTitulo := 'Inclusão de Motivos de Negociação'         
    
    Private oDlg      := Nil
    Private cZZR_MOTIVO     := space(6) //Space(TamSX3('ZZR_MOTIVO')[1])
    Private cZZR_DESCMOT    := ""
    Private cZZR_JUSTIF     := Space(TamSX3('ZZR_JUSTIF')[1])
    Private cZZR_CONTAT     := Space(TamSX3('ZZR_CONTAT')[1])
                                                           
    if sMARCADOS() = 0 
        return
    endif
    
    aSize := MsAdvSize(.F.)

    Define MsDialog oDlg Title cTitulo Style DS_MODALFRAME From aSize[7], 0 To 275, aSize[5] / 2 OF oMainWnd PIXEL
    
    //aSize[6] / 3.3
    
    aObjects := {}  
    
    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }
                                                                                                      
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
            {{10,40,105,140,200,234,275,200,225,270,285,265},;
             {10,40,105,140,200,234, 63,200,225,270,285,265} } ) 
    
    @ aPosObj[1][1]+ 50,aPosGet[1,1] + 12  Say "Motivo"                              Of oDlg  Pixel Size 031, 010       
    @ aPosObj[1][1]+ 48,aPosGet[1,1] + 32  MsGet cZZR_MOTIVO                         When .T. Of oDlg F3 "SX5XM" VALID sZZR_MOTIVO() Pixel Size  50, 010     
    @ aPosObj[1][1]+ 50,aPosGet[1,1] + 92  Say   cZZR_DESCMOT                        Of oDlg  Pixel Size 200, 010
    
    @ aPosObj[1][1]+ 70,aPosGet[1,1]       Say "Justificativa"                       Of oDlg   Pixel Size 031,010 
    @ aPosObj[1][1]+ 68,aPosGet[1,1] + 32  MsGet cZZR_JUSTIF                         When .T. Of oDlg VALID sZZR_JUSTIF() PICTURE "@!" Pixel Size 400,010     
    
    @ aPosObj[1][1]+ 90,aPosGet[1,1]       Say "Contato"                             Of oDlg   Pixel Size 031,010 
    @ aPosObj[1][1]+ 88,aPosGet[1,1] + 32  MsGet cZZR_CONTAT                         When .T. Of oDlg VALID sZZR_CONTAT() PICTURE "@!" Pixel Size 400,010     
    
    Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk , bCancel) Centered                                                                            
    
return
                                                   
Static Function sZZR_MOTIVO()
    Local iSX5 := RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 

    DbSelectArea("SX5")      
	SX5->(DbSetOrder(iSX5))
	If SX5->(DbSeek(xFilial("SX5")+"XM"+cZZR_MOTIVO))
        cZZR_DESCMOT := sZZR_DscMotivo(cZZR_MOTIVO)
        return .T.
    else
        Aviso("Motivo Inválido","Atenção, Motivo de Negociação não cadastrado.",{"&Retornar"})       
        return .F. 
    endif
    
Static Function sZZR_JUSTIF()
    if empty(cZZR_JUSTIF)
        Aviso("Justificativa não informada","Atenção, Justificativa não informada.",{"&Retornar"})       
        return .F. 
    else
        return .T.
    endif                              

Static Function sZZR_CONTAT()
    if empty(cZZR_CONTAT)
        Aviso("Contato não informado","Atenção, Contato não informado.",{"&Retornar"})       
        return .F. 
    else
        return .T.
    endif                              

Static Function sINCGRAVA()   
    
    Local nLinha    := 0
    Local cUserID   := RetCodUsr()
    
    DBSelectArea("ZZR")                      
    
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
	     if aGrid[nLinha][1]
            Reclock("ZZR", .T.)   
            ZZR->ZZR_FILIAL := cFILANT 
            ZZR->ZZR_PREFIX := aGrid[nlinha][6]
            ZZR->ZZR_NUM    := aGrid[nlinha][7]
            ZZR->ZZR_PARCEL := aGrid[nlinha][8]
            ZZR->ZZR_TIPO   := aGrid[nlinha][9]
            ZZR->ZZR_DATA   := cData
            ZZR->ZZR_HORA   := cHora
            ZZR->ZZR_MOTIVO := cZZR_MOTIVO
            ZZR->ZZR_JUSTIF := UPPER(cZZR_JUSTIF)
            ZZR->ZZR_CONTAT := UPPER(cZZR_CONTAT)
            ZZR->ZZR_USER   := cUserID
            ZZR->(MsUnLock())        
	     endif
    next 
    
    S0601SE1("N")
                
    bTC06A010 := .T.
    
    return .T.