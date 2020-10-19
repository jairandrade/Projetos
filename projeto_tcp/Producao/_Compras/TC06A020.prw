#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"                                                                                                   

/*                                                                                                                                                                               
Programa : TC06A020 
Autor    : ITUPSUL
Data     : 08/06/2019                                                                                                                                                  
Desc.    : Monitor SERASA
Uso      : TCP
*/
User Function TC06A020()  
    Local aSize  := MsAdvSize()
	Local aItensOrdenacao:= {"Cod Cli", "Nome", "Num Titulo", "Vencimento", "Valor"}
	Local aItensSituacao := {"Enviado", "Envio Pendente", "Não Enviado", "Baixa Pendente"} 
	
	Local cpermissao := SuperGetMv("TCP_BXSERA")
	   
    Private lMarcados      := .F.  
    Private oGrid          := Nil       
    Private aGrid          := {}
    Private _dVctoIni      := date() -1 
    Private _dVctoFin      := date() -1 
    Private _cA1_XGREMPR   := space(TamSX3('A1_XGREMPR')[1])  
    Private _cA1_CLIENTE   := space(TamSX3('A1_COD')[1])
    
    Private cCadastro         := "Monitor SERASA"
    Private cE1_SITUACA
    Private lENVIAR         := .F.
    Private lXENVIAR        := .F.
    Private lEXCLUIR        := .F.
    Private lXEXCLUIR       := .F.        
    
    if !__cUserId $ cpermissao
        Aviso("Sem permissão","Atenção, Seu usuário não tem permissão para acessar o monitor SERASA.",{"&Retornar"})       
        return .F. 
    endif
    
    // Variavel criada para controlar a segunda chamada desta função logo após a informação de motivos de negociação 
    Public bTC06A020
    
    if Valtype(bTC06A020) = "L" 
        if bTC06A020
           bTC06A020 := .F.
           return
        endif
    endif
    
    DBSelectArea("ZZS")
    DBSelectArea("ZZT")
    
    oDialog := TDialog():New(aSize[7],000,aSize[6],aSize[5],OemToAnsi(cCadastro),,,,,,,,oMainWnd,.T.)
    
    aObjects := {}  
    AAdd( aObjects, {  0,       65, .T., .F. } )        
    AAdd( aObjects, { 65, aSize[4], .T., .T. } )
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

    aPosObj := MsObjSize( aInfo, aObjects )    
    
    TSay():New(013, 022,{|| "Grupo Empr." },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 010, 060 MSGet _cA1_XGREMPR Of oDialog F3 "SX5GR" Valid sA1_XGREMPR() PIXEL SIZE 040, 009 
	                                                                             
    TSay():New(013, 122,{|| "Cliente" },oDialog,,,.F.,.F.,.F.,.T.,,,040,006)
    @ 010, 150 MSGet _cA1_CLIENTE  F3 "SA1"  Valid sA1_COD() Of oDialog PIXEL SIZE 040, 009 
	                                                                             
    TSay():New(013, 207,{|| "Vencimento de" },oDialog,,,.F.,.F.,.F.,.T.,,,40,008)
    @ 010, 253 MSGet _dVctoIni Picture "@D" Valid sDVCTOINI() Of oDialog PIXEL SIZE 040, 009
	                
    TSay():New(013, 298,{|| "até" },oDialog,,,.F.,.F.,.F.,.T.,,,20,006)
    @ 010, 310 MSGet _dVctoFin  Picture "@D" Valid sDVCTOFIN() Of oDialog PIXEL SIZE 040, 009 
	
	TSay():New(013, 402, {|| "Situação" },oDialog,,,.F.,.F.,.F.,.T.,,,200,008)
    cCBSituacao := aItensSituacao[1]
    oCBSituacao := TComboBox():New(008,437,{|u|if(PCount()>0,cCBSituacao:=u,cCBSituacao)}, aItensSituacao,58,17,oDialog,,{ || },,,,.T.,,,,,,,,,'cCBSituacao')
    
	TSay():New(013, 532, {|| "Ordenação" },oDialog,,,.F.,.F.,.F.,.T.,,,200,008)
    cCombo1:= aItensOrdenacao[1]
    oCombo1 := TComboBox():New(008,567,{|u|if(PCount()>0,cCombo1:=u,cCombo1)}, aItensOrdenacao,58,17,oDialog,,{ || },,,,.T.,,,,,,,,,'cCombo1')
                         
    //Botão de consulta
    TButton():New(010, 740, OemToAnsi("&Exibir"), oDialog,{|| S0602SE1("N")   },103, 010,,,,.T.,,,,{|| })
   
    aColHeader := {" ", " ", "Cod", "Loja", "Nome Cliente", "Num NF", "Prefixo", "Titulo", "Parcela", "Tipo", "Valor(R$)", "Saldo Rec", "Emissão", "Vcto Real", "Dias"}
    aColSize   := { 10,  10,    40,     20,            180,       40,        25,       40,        20,     20,          40,          40,        35,         35,      20}

    oGrid := TWBrowse():New(30,005,aPosObj[2][4] - 5, aPosObj[2][3] - 85,,aColHeader,aColSize,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)    
        
    oCheck1 := TCheckBox():New(34, 15, ' ', {|| lMarcados} ,oDialog, 100, 210,, {|| S0602MARCA()},,,,,,.T.,,,)
       
    oGrid:bLDblClick := {|| aGrid[oGrid:nAt][1] := !aGrid[oGrid:nAt][1], , oDialog:Refresh() }

    //Botões de processamento
    @ aPosObj[2][3] - 55, 120 BUTTON "Enviar SERASA" SIZE 100, 015 PIXEL OF oDialog ACTION (S0602INC()) WHEN lENVIAR
    @ aPosObj[2][3] - 55, 240 BUTTON "Cancelar Envio" SIZE 100, 015 PIXEL OF oDialog ACTION (S0602XINC()) WHEN lXENVIAR
    @ aPosObj[2][3] - 55, 360 BUTTON "Excluir SERASA" SIZE 100, 015 PIXEL OF oDialog ACTION (S0602EXC()) WHEN lEXCLUIR
    @ aPosObj[2][3] - 55, 480 BUTTON "Cancelar Exclusão" SIZE 100, 015 PIXEL OF oDialog ACTION (S0602XEXC()) WHEN lXEXCLUIR
    @ aPosObj[2][3] - 55, 600 BUTTON "Imprimir" SIZE 100, 015 PIXEL OF oDialog ACTION (S0602SE1("N")) WHEN .T.
        
    S0602SE1("S") 
 
    oDialog:Activate(,,,.T.)

    Return    

Static Function sE1_SITUACA
    // Setando para false o controle dos botões
    lENVIAR         := .F.
    lXENVIAR        := .F.
    lEXCLUIR        := .F.
    lXEXCLUIR       := .F.
    
    // Definindo a situação selecionada pelo usuario
    Do Case
        Case cCBSituacao = "Enviado"
            cE1_SITUACA := '1'
		    lEXCLUIR     := .T.
	    Case cCBSituacao = "Envio Pendente"
            cE1_SITUACA := '2'
    	    lXENVIAR        := .T.
        Case cCBSituacao = "Não Enviado"
            cE1_SITUACA := '3'
		    lENVIAR    := .T.
	    Case cCBSituacao = "Baixa Pendente"
            cE1_SITUACA := '4'
    	    lXEXCLUIR   := .T.
    End Case
    
    return
                                             
Static Function SDVCTOINI
    if empty(_DVCTOINI)        
	     MSGALERT("Data de vencimento inicial não informada.","Alerta")
	     return .F.
    elseif _DVCTOINI >= date()        
	     MSGALERT('Data de vencimento inicial maior ou igual a data do sistema.','Atencao!!!')
	     return .F.
	  endif
    
    return .T.                                               

                                                   
Static Function SDVCTOFIN
    if empty(_DVCTOFIN)        
	     MSGALERT("Data de vencimento final não informada.","Alerta")
	     return .F.
    elseif _DVCTOFIN >= date()        
	     MSGALERT('Data de vencimento final maior ou igual a data do sistema.','Atencao!!!')
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
    return 
    
Static Function S0602MARCA () 
    Local i
    lMarcados := !lMarcados
    
    for i := 1 to len(aGrid)
        if lMarcados 
            aGrid[i][1] := .T.
        else 
            aGrid[i][1] := .F.
        endif
    next i
    
                            
    oGrid:SetArray(aGrid)
             //LoadBitmap(GetResources(), aGrid[oGrid:nAt][2]),;			
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
			    aGrid[oGrid:nAt][14]}}
  			
    oGrid:Refresh()
    
    oDialog:refresh()
    
    return

Static Function S0602SE1(pPRIMEIRO) 
    MsAguarde({|| S0602SQL(pPRIMEIRO)}, "Aguarde ...") 
    
    Return
    
Static Function S0602SQL(pPRIMEIRO)
    // Tratando a situação selecionada pelo usuario
    sE1_SITUACA()
    
    //Cria a query para buscar apontamentos registrados em conformidade com os parametros de filtro informados
    cQuerySE1 := " Select E1_CLIENTE, "
    cQuerySE1 += "     E1_LOJA, "
    cQuerySE1 += "     A1_NOME, "
    cQuerySE1 += "     E1_XNUMOS, "
    cQuerySE1 += "     E1_NUM, "
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
    cQuerySE1 += "   AND E1_FILIAL = '" + xFILIAL("SE1") + "' "   
    cQuerySE1 += "   AND A1_FILIAL = '" + xFILIAL("SA1") + "' "        
    cQuerySE1 += "   AND E1_CLIENTE = A1_COD"
    cQuerySE1 += "   AND E1_LOJA = A1_LOJA"
    if !Empty(_cA1_XGREMPR)
         cQuerySE1 += "   AND A1_XGREMPR = '" + _cA1_XGREMPR + "' "
    endif
    if !Empty(_cA1_CLIENTE)
         cQuerySE1 += "   AND E1_CLIENTE = '" + _cA1_CLIENTE + "' "        
    endif
    
    cQuerySE1 += "   AND E1_VENCREA >= '" + DtoS(_dVctoIni) + "' " 
    cQuerySE1 += "   AND E1_VENCREA <= '" + DtoS(_dVctoFin) + "' "      
    cQuerySE1 += "   AND E1_SALDO > 0 " 
   
    if cE1_SITUACA = '1'
        cQuerySE1 += "   AND E1_SITUACA = 'S ' "
        cQuerySE1 += "   AND not exists (SELECT null"
        cQuerySE1 += "                  FROM " + RetSqlName("ZZS") + " ZZS with (nolock)"
    	cQuerySE1 += "                  WHERE ZZS.D_E_L_E_T_ <> '*' "
        cQuerySE1 += "                    AND ZZS_FILIAL = E1_FILIAL "
        cQuerySE1 += "                    AND ZZS_PREFIX = E1_PREFIXO "
        cQuerySE1 += "                    AND ZZS_NUM = E1_NUM "
        cQuerySE1 += "                    AND ZZS_PARCEL = E1_PARCELA " 
        cQuerySE1 += "                    AND ZZS_TIPO = E1_TIPO
        cQuerySE1 += "                    AND ZZS_MOVIME = 'E' " 
        cQuerySE1 += "                    AND ZZS_SITUAC = 'P') "
   elseif cE1_SITUACA = '2'
        cQuerySE1 += "   AND E1_SITUACA <> 'S ' "
        cQuerySE1 += "   AND exists (SELECT null"
        cQuerySE1 += "              FROM " + RetSqlName("ZZS") + " ZZS with (nolock)"
    	cQuerySE1 += "              WHERE ZZS.D_E_L_E_T_ <> '*' "
        cQuerySE1 += "                AND ZZS_FILIAL = E1_FILIAL "
        cQuerySE1 += "                AND ZZS_PREFIX = E1_PREFIXO "
        cQuerySE1 += "                AND ZZS_NUM = E1_NUM "
        cQuerySE1 += "                AND ZZS_PARCEL = E1_PARCELA " 
        cQuerySE1 += "                AND ZZS_TIPO = E1_TIPO
        cQuerySE1 += "                AND ZZS_MOVIME = 'I' " 
        cQuerySE1 += "                AND ZZS_SITUAC = 'P') "
   elseif cE1_SITUACA = '3'
        cQuerySE1 += "   AND E1_SITUACA <> 'S ' "
        cQuerySE1 += "   AND not exists (SELECT null"
        cQuerySE1 += "                  FROM " + RetSqlName("ZZS") + " ZZS with (nolock)"
    	cQuerySE1 += "                  WHERE ZZS.D_E_L_E_T_ <> '*' "
        cQuerySE1 += "                    AND ZZS_FILIAL = E1_FILIAL "
        cQuerySE1 += "                    AND ZZS_PREFIX = E1_PREFIXO "
        cQuerySE1 += "                    AND ZZS_NUM = E1_NUM "
        cQuerySE1 += "                    AND ZZS_PARCEL = E1_PARCELA " 
        cQuerySE1 += "                    AND ZZS_TIPO = E1_TIPO
        cQuerySE1 += "                    AND ZZS_MOVIME = 'I' " 
        cQuerySE1 += "                    AND ZZS_SITUAC = 'P') "
    elseif cE1_SITUACA = '4'
        cQuerySE1 += "   AND E1_SITUACA = 'S ' "
        cQuerySE1 += "   AND exists (SELECT null"
        cQuerySE1 += "               FROM " + RetSqlName("ZZS") + " ZZS with (nolock)"
    	cQuerySE1 += "               WHERE ZZS.D_E_L_E_T_ <> '*' "
        cQuerySE1 += "                 AND ZZS_FILIAL = E1_FILIAL "
        cQuerySE1 += "                 AND ZZS_PREFIX = E1_PREFIXO "
        cQuerySE1 += "                 AND ZZS_NUM = E1_NUM "
        cQuerySE1 += "                 AND ZZS_PARCEL = E1_PARCELA " 
        cQuerySE1 += "                 AND ZZS_TIPO = E1_TIPO
        cQuerySE1 += "                 AND ZZS_MOVIME = 'E' " 
        cQuerySE1 += "                 AND ZZS_SITUAC = 'P') "
    endif                                 
 
    Do Case             
        Case cCombo1 = "Cod Cli" 
            cQuerySE1 += " ORDER BY E1_CLIENTE, E1_LOJA "
        Case cCombo1 = "Nome" 
            cQuerySE1 += " ORDER BY A1_NOME "
        Case cCombo1 = "Num Titulo" 
            cQuerySE1 += " ORDER BY E1_NUM "
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
                                                                               
        // Recuperando ultimo motivo e Justificativa de negociação para o titulo
        /*
        cQuery := " Select ZZS_MOTIVO, "
        cQuery += "     ZZS_JUSTIF, "
        cQuery += "     ZZS_CONTAT, "
        cQuery += "     ZZS_DATA, "
        cQuery += "     ZZS_HORA, "
        cQuery += "     ZZS_USER " 
        cQuery += " FROM " + RetSqlName("ZZS")
        cQuery += " WHERE D_E_L_E_T_ <> '*' "
        cQuery += "   AND ZZS_FILIAL = '" + xFILIAL("ZZS") + "' " 
        cQuery += "   AND ZZS_PREFIX = '" + QRY_SE1->E1_PREFIXO + "' " 
        cQuery += "   AND ZZS_NUM    = '" + QRY_SE1->E1_NUM + "' " 
        cQuery += "   AND ZZS_PARCEL = '" + QRY_SE1->E1_PARCELA + "' " 
        cQuery += "   AND ZZS_TIPO   = '" + QRY_SE1->E1_TIPO + "' "    
        cQuery += " ORDER BY ZZS_DATA DESC, ZZS_HORA DESC "     
        
        If Select("QRY_ZZS") > 0
            QRY_ZZS->(dbCloseArea())
        EndIf
                        
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY_ZZS",.F.,.T.)                                               
        dbSelectArea("QRY_ZZS")
        QRY_ZZS->(dbGoTop())  
        */                    
        AAdd(aGrid,{ .F.,;
                  AllTrim(QRY_SE1->E1_CLIENTE),;
                  AllTrim(QRY_SE1->E1_LOJA),;
                  AllTrim(QRY_SE1->A1_NOME),;
                  AllTrim(QRY_SE1->E1_XNUMOS),;
                  AllTrim(QRY_SE1->E1_PREFIXO),;
                  AllTrim(QRY_SE1->E1_NUM),;
                  AllTrim(QRY_SE1->E1_PARCELA),;
                  AllTrim(QRY_SE1->E1_TIPO),;
                  QRY_SE1->E1_VALOR,;
                  QRY_SE1->E1_SALDO,;
                  dE1_EMISSAO,; 
                  dE1_VENCREA,;           
                  nE1_DIAS,;                   
                  QRY_SE1->nRECNO})       
                  
        nQtdTitulos += 1
        nVlrTitulos += QRY_SE1->E1_SALDO
        
        QRY_SE1->(dbSkip())
    EndDo                                        
    
    if len(aGrid) = 0
        aGrid := {{.F., "", "", "", "", "", "", "", "", 0, 0, "", "", 0, 0}} 
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
        aGrid[oGrid:nAt][14]}}
      
    oGrid:Refresh()
        
    oDialog:Refresh()     
        
    Return

Static Function SMARCADOS
	Local nlinha
    nMarcado := 0
    for nlinha := 1 to len(aGrid)
	     if aGrid[nLinha][1]
	         nMarcado += 1 
	     endif
    next 
    
    if nMarcado = 0
        MSGALERT("Favor Selecionar Título(s).","Alerta")
    endif
    return nMarcado    


Static Function s0602INC()   
	Local nlinha
    if sMARCADOS() = 0 
        return
    endif

    If !MsgYesNo("Confirma o envio dos títulos selecionados para inclusão no SERASA ?", "Atencao!")   
        return
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
    for nlinha := 1 to len(aGrid)
	     if aGrid[nLinha][1]
            Reclock("ZZS", .T.)   
            ZZS->ZZS_FILIAL := cFILANT 
            ZZS->ZZS_PREFIX := aGrid[nlinha][6]
            ZZS->ZZS_NUM    := aGrid[nlinha][7]
            ZZS->ZZS_PARCEL := aGrid[nlinha][8]
            ZZS->ZZS_TIPO   := aGrid[nlinha][9]
            ZZS->ZZS_DATA   := cData
            ZZS->ZZS_HORA   := cHora
            ZZS->ZZS_MOVIME := 'I'
            ZZS->ZZS_SITUAC := 'E'
            ZZS->ZZS_MOTIVO := 'NF'
            ZZS->ZZS_USER   := __cUserId
            ZZS->(MsUnLock())  
            
           /* 
            // Colocado para permitir manipular os outros botões (Retirar antes de entregar)
            //cria o update para atualizar todos os registros processados em um unico comando
            cUpdate := " update " + retsqlname("SE1") + " "   
            cUpdate += " set E1_SITUACA = 'S' "
            cUpdate += " where E1_FILIAL = '" + cFILANT + "' " 
            cUpdate += "   and E1_PREFIXO = '" + aGrid[nlinha][6] + "' " 
            cUpdate += "   and E1_NUM    = '" + aGrid[nlinha][7] + "' " 
            cUpdate += "   and E1_PARCELA = '" + aGrid[nlinha][8] + "' " 
            cUpdate += "   and E1_TIPO   = '" + aGrid[nlinha][9] + "' " 
            cUpdate += "   and D_E_L_E_T_ <> '*' "
             
            cUpdate := UPPER(cUpdate)
            
            nUpdate := TcSqlExec(cUpdate)
            
            if nUpdate < 0
                 MsgStop("Não foi possível cancelar o movimento de envio para inclusão no SERASA devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
            endif
            */      
	     endif
    next 
    
    S0602SE1("S")
                
    bTC06A020 := .T.
    
    return .T.
    
Static Function s0602XINC()   
	Local nlinha
    if sMARCADOS() = 0 
        return
    endif

    If !MsgYesNo("Confirma cancelamento do envio dos títulos selecionados para inclusão no SERASA ?", "Atencao!")   
        return
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
    for nlinha := 1 to len(aGrid)
	    if aGrid[nLinha][1]
            //cria o update para atualizar todos os registros processados em um unico comando
            cUpdate := " update " + retsqlname("ZZS") + " "   
            cUpdate += " set ZZS_SITUAC = 'X' "
            cUpdate += " where ZZS_FILIAL = '" + cFILANT + "' " 
            cUpdate += "   and ZZS_PREFIX = '" + aGrid[nlinha][6] + "' " 
            cUpdate += "   and ZZS_NUM    = '" + aGrid[nlinha][7] + "' " 
            cUpdate += "   and ZZS_PARCEL = '" + aGrid[nlinha][8] + "' " 
            cUpdate += "   and ZZS_TIPO   = '" + aGrid[nlinha][9] + "' " 
            cUpdate += "   and ZZS_SITUAC = 'P' "
            cUpdate += "   and D_E_L_E_T_ <> '*' "
             
            cUpdate := UPPER(cUpdate)
            
            nUpdate := TcSqlExec(cUpdate)
            
            if nUpdate < 0
                 MsgStop("Não foi possível cancelar o movimento de envio para inclusão no SERASA devido ao erro :" + Chr(13) + Chr(13) + TcSqlError(),"Atenção")
            endif
         endif
    next 
    
    S0602SE1("S")
                
    bTC06A020 := .T.
    
    return .T.
    
Static Function S0602EXC ()  
    Local aSize   := {}
    Local _lRet   := .f.  
    
    Local bOk     := {|| _lRet := .T., iif(sEXCGRAVA(), oDlg:End(),"")}
    Local bCancel := {|| _lRet := .F., oDlg:End()}  
    Local cTitulo := 'Exclusão de Registro no SERASA'         
    
    Private oDlg      := Nil
    
    Private cZZS_MOTIVO := Space(TamSX3('ZZS_MOTIVO')[1])
                                                           
    if sMARCADOS() = 0 
        return
    endif
    
    aSize := MsAdvSize(.F.)

    Define MsDialog oDlg Title cTitulo Style DS_MODALFRAME From aSize[7], 0 To aSize[6] / 3.3, aSize[5] / 2 OF oMainWnd PIXEL
    
    aObjects := {}  
    
    AAdd( aObjects, { 100, 350, .T., .T. } )
    AAdd( aObjects, {   0,  30, .T., .F. } )
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 6 ] / 2 - 5, aSize[ 4 ] / 2 - 5, 3, 3 }
                                                                                                      
    aPosObj := MsObjSize( aInfo, aObjects )
    aPosGet := MsObjGetPos(aSize[3]-aSize[1],305,;
            {{10,40,105,140,200,234,275,200,225,270,285,265},;
             {10,40,105,140,200,234, 63,200,225,270,285,265} } ) 
    
    @ aPosObj[1][1]+ 50,aPosGet[1,1] + 12  Say "Motivo"                              Of oDlg  Pixel Size 031, 010       
    @ aPosObj[1][1]+ 48,aPosGet[1,1] + 32  MsGet cZZS_MOTIVO                         When .T. Of oDlg F3 "SX5XM" VALID sZZS_MOTIVO() Pixel Size  50, 010 
    
    Activate MsDialog oDlg On Init EnchoiceBar(oDlg, bOk , bCancel) Centered                                                                            
    
    return
           
 
Static Function sEXCGRAVA()   
    Local nlinha
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
            Reclock("ZZS", .T.)   
            ZZS->ZZS_FILIAL := cFILANT 
            ZZS->ZZS_PREFIX := aGrid[nlinha][6]
            ZZS->ZZS_NUM    := aGrid[nlinha][7]
            ZZS->ZZS_PARCEL := aGrid[nlinha][8]
            ZZS->ZZS_TIPO   := aGrid[nlinha][9]
            ZZS->ZZS_DATA   := cData
            ZZS->ZZS_HORA   := cHora
            ZZS->ZZS_MOVIME := 'E'
            ZZS->ZZS_SITUAC := 'P'
            ZZS->ZZS_MOTIVO := cZZS_MOTIVO
            ZZS->ZZS_USER   := __cUserId
            ZZS->(MsUnLock())        
	     endif
    next 
    
    S0602SE1("N")
                
    bTC06A020 := .T.
    
    return .T.
                                            
Static Function sZZS_MOTIVO()
    Local iSX5 := RETORDEM("SX5","X5_FILIAL+X5_TABELA+X5_CHAVE") 

    DbSelectArea("SX5")      
	SX5->(DbSetOrder(iSX5))
	If SX5->(DbSeek(xFilial("SX5")+"GR"+cZZS_MOTIVO))
        return .T.
    else
        Aviso("Motivo Inválido","Atenção, Motivo de Negociação não cadastrado.",{"&Retornar"})       
        return .F. 
    endif
                   
