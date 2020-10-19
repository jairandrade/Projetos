#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"                                                                                           
#include "TC04A020.ch"

User function WFGARINI(cZPB_PROC)
	Local _cEmaPar := ""
	
	_cEmaPar		:= Lower(AllTrim(GetMv("TCP_NOTCOM")))
	
	cSql := " SELECT ZPB.*, B1_DESC ZPB_PRODSC, ISNULL(CAST(CAST(ZPB_DEFEIT AS VARBINARY(8000)) AS VARCHAR(8000)),'') DEFEITO "
	cSql += " FROM " + RetSqlName ("ZPB") + " ZPB, " 
	cSql += "      " + RetSqlName ("SB1") + " SB1 "
	cSql += " WHERE ZPB.D_E_L_E_T_ <> '*' ""
	cSql += "   AND ZPB_FILIAL = '" + xFilial("ZPB") + "' "
	cSql += "   AND ZPB_PROC = '" + cZPB_PROC + "' "
	cSql += "   AND SB1.D_E_L_E_T_ <> '*' ""
	cSql += "   AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cSql += "   AND B1_COD = ZPB_PRODUT "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    TcQuery cSql new Alias "QRY" 
	
	QRY->(DbGoTop())
	IF QRY->(!Eof())       
		oProc := TWFProcess():New("MAILGARINI","Notificação de Item para Reparo/Garantia")
		oProc:NewTask("Notificação de Item para Reparo/Garantia", "\WORKFLOW\HTML\MAILGARINI.HTML" )
		oProc:cSubject := "Notificação de Item para Reparo/Garantia"	
	
		oHtml := oProc:oHtml
	
	    cRA_NOME := Posicione("SRA", 1, xFilial("SRA")+QRY->ZPB_SOLICI,"RA_NOME")
	    cZPE_DESCRI := Posicione("ZPE", 1, xFilial("ZPE")+QRY->ZPB_EQUIPA,"ZPE_DESCRI")
	    
		IF valtype(oHtml) != "U"
	        oHtml:ValByName("cNomEmp",FWFilialName()) 
			oHtml:ValByName("cZPB_PROC",cZPB_PROC)
			oHtml:ValByName("cZPB_PRODUT",QRY->ZPB_PRODUT)
			oHtml:ValByName("cZPB_PRODSC",QRY->ZPB_PRODSC)
			oHtml:ValByName("cZPB_DTVALI",DTOC(STOD(QRY->ZPB_DTVALI)))
			oHtml:ValByName("cZPB_LOTE",QRY->ZPB_LOTE)
			oHtml:ValByName("cZPB_SERIE",QRY->ZPB_SERIE)
			oHtml:ValByName("cZPB_DEFEITO", QRY->DEFEITO) 
			oHtml:ValByName("cZPB_OM", QRY->ZPB_OM) 
			oHtml:ValByName("cZPB_SOLICI", QRY->ZPB_SOLICI + ' - ' + cRA_NOME) 
			oHtml:ValByName("cZPB_EQUIPA", QRY->ZPB_EQUIPA + ' - ' + cZPE_DESCRI) 
			oHtml:ValByName("cData", DTOC(ddatabase)) 
			
			oProc:cTo := _cEmaPar
			oProc:Start()
			oProc:Finish()
	
			WFSendMail()
		endif	
	ENDIF
	
	QRY->(dbclosearea()) 
	
	return
	

User function WFGARCOL(cZPB_PROC)
    Local nZPB_TPFRE
    Local cZPB_TPFRE
	Local _cEmaPar := ""
	
	_cEmaPar := Lower(AllTrim(GetMv("TCP_NOTALM")))
    
	cSql := " SELECT ZPB.*, B1_DESC ZPB_PRODSC, ISNULL(CAST(CAST(ZPB_DEFEIT AS VARBINARY(8000)) AS VARCHAR(8000)),'') DEFEITO "
	cSql += " FROM " + RetSqlName ("ZPB") + " ZPB, " 
	cSql += "      " + RetSqlName ("SB1") + " SB1 "
	cSql += " WHERE ZPB.D_E_L_E_T_ <> '*' ""
	cSql += "   AND ZPB_FILIAL = '" + xFilial("ZPB") + "' "
	cSql += "   AND ZPB_PROC = '" + cZPB_PROC + "' "
	cSql += "   AND SB1.D_E_L_E_T_ <> '*' ""
	cSql += "   AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cSql += "   AND B1_COD = ZPB_PRODUT "
    
    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
        
    TcQuery cSql new Alias "QRY" 
	
	QRY->(DbGoTop())
	IF QRY->(!Eof())       
		oProc := TWFProcess():New("MAILGARCOL","Notificação de Item para Coleta")
		oProc:NewTask("Notificação de Item para Coleta", "\WORKFLOW\HTML\MAILGARCOL.HTML" )
		oProc:cSubject := "Notificação de Item para Coleta"	
	
		oHtml := oProc:oHtml
	    
	    nZPB_TPFRE := val(QRY->ZPB_TPFRE)
	    if nZPB_TPFRE = xFRETE_CIF
	        cZPB_TPFRE:= "CIF"
	    elseif nZPB_TPFRE = xFRETE_CON
	        cZPB_TPFRE:= "FOB - CONTRATO"
	    elseif nZPB_TPFRE = xFRETE_FOB
	        cZPB_TPFRE:= "FOB - Solicitação de Compra"
	    elseif nZPB_TPFRE = xFRETE_SEM
	        cZPB_TPFRE:= "Sem Frete"
	    endif
	
	    // Buscar dados do fornecedor
        cQuery := " Select A2_NOME, A2_EMAIL "
	    cQuery += " From " + RetSqlName("SA2") + " SA2 "
	    cQuery += " Where A2_COD = '" + QRY->ZPB_TRANSP + "'"  
	    cQuery += "   and A2_FILIAL =  '" + xFilial("SA2") + "' "  
	    cQuery += "   and D_E_L_E_T_ <> '*' "
	    cQuery := ChangeQuery(cQuery)     
	    
	    If Select("QSA2") > 0
	        QSA2->(dbCloseArea())
	    EndIf
	        
	    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QSA2",.F.,.T.)
	    dbSelectArea("QSA2")
	    
	    if empty(QSA2->A2_NOME)
	        cZPB_TRANSP = QRY->ZPB_TRANSP
	    else
	        cZPB_TRANSP = QRY->ZPB_TRANSP + ' - ' + QSA2->A2_NOME
	    endif
	    
	    // Buscar dados do fornecedor
        cQuery := " Select SUM(C7_TOTAL) C7_TOTAL "
	    cQuery += " From " + RetSqlName("SC7") + " SC7 "
	    cQuery += " Where C7_NUM = '" + QRY->ZPB_PCFRE + "'"  
	    cQuery += "   and C7_FILIAL =  '" + xFilial("SC7") + "' "  
	    cQuery += "   and D_E_L_E_T_ <> '*' "
	    cQuery := ChangeQuery(cQuery)     
	    
	    If Select("QSC7") > 0
	        QSC7->(dbCloseArea())
	    EndIf
	        
	    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QSC7",.F.,.T.)
	    dbSelectArea("QSC7")
	    
	    IF valtype(oHtml) != "U"
            oHtml:ValByName("cNomEmp",FWFilialName()) 
			oHtml:ValByName("cZPB_PROC",cZPB_PROC)
			oHtml:ValByName("cZPB_TRANSP",cZPB_TRANSP)
			oHtml:ValByName("cZPB_PCFRE",QRY->ZPB_PCFRE)
			oHtml:ValByName("cZPB_TPFRE", cZPB_TPFRE)
			oHtml:ValByName("cZPB_VLFRE", QSC7->C7_TOTAL)
			
			oHtml:ValByName("cZPB_PRODUT",QRY->ZPB_PRODUT)
			oHtml:ValByName("cZPB_PRODSC",QRY->ZPB_PRODSC)
			oHtml:ValByName("cZPB_DTVALI",DTOC(STOD(QRY->ZPB_DTVALI)))
			oHtml:ValByName("cZPB_LOTE",QRY->ZPB_LOTE)
			oHtml:ValByName("cZPB_SERIE",QRY->ZPB_SERIE)
			oHtml:ValByName("cZPB_DEFEITO", QRY->DEFEITO)
			oHtml:ValByName("cData", DTOC(ddatabase))  
			
			if empty(QSA2->A2_EMAIL)
			    oProc:cTo := _cEmaPar 
			else
			    oProc:cTo := _cEmaPar + ";" + QSA2->A2_EMAIL
			endif
			oProc:Start()
			oProc:Finish()
	
			WFSendMail()
		endif	
	ENDIF
	
	QRY->(dbclosearea()) 
	
	return