#include 'protheus.ch'
#include "Totvs.ch"  
#include "Rwmake.ch"    
#Include "TopConn.ch"                                                                                              
#include "TC04A020.ch"

user function CN130PGRV()
    
	// Caso a chamada venha do processo de garantia atualiza o processo com o numero da medição gerada
    if AllTrim(FUNNAME()) = 'TC04A020'
        cCND_NUMMED := CND->CND_NUMMED
	        
	 	//cria o update para atualizar todos os registros processados em um unico comando
	    cUpdate := " update " + retsqlname("ZPB") + " "   
	    cUpdate += " set ZPB_TRANSP = '" + cZPB_TRANSP + "', "  
	    cUpdate += "     ZPB_STATUS = 'APF', "  
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
	    
	    nUpdate := TcSqlExec(cUpdate)

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
	    ZPC->ZPC_STATUS := 'APF'
	    ZPC->ZPC_USER   := UsrRetName(RetCodUsr())
	    ZPC->ZPC_OBSERV := "Gerada medicao de frete [" + cCND_NUMMED + "]."
	    
	    ZPC->(MsUnLock())   
    endif
    
    return .T.
