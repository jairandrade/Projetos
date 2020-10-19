#include "protheus.ch"

User Function PONCALD()

    Local aInfo         := fCarrEvt()
    Local cAliasSPB		:= "SPB"
    Local cAliasQry     := GetNextAlias()
    Local aSpbFields	:= SPB->( dbStruct() )
    Local nSpbFields	:= Len( aSpbFields	)
    Local nHE65         := 0
    Local nHE85         := 0
    Local nHE100        := 0
    Local nX            := 0

    dDataIni   := mv_par16
    dDataFim   := mv_par17
	
	cIniData	:= Dtos( dDataIni )
	cFimData	:= Dtos( dDataFim )

    dbSelectArea('SPB')
    dbSetOrder(1)

    cAliasQSPB	:= ( "__Q" + cAliasSPB + "QRY" )
    cSPBQuery := "SELECT "
    /*
    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³ Carregando os Campos do SPC na Query						   ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    For nX := 1 To nSpbFields
        cSPBQuery += aSpbFields[ nX , 01 ] + ", "
    Next nX
    cSPBQuery += "R_E_C_N_O_ RECNO "
    cSPBQuery += " FROM " + RetSqlName( cAliasSPB ) + " " + cAliasSPB
    /*
    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³ Montando a Condicao										   ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    cSPBQuery += " WHERE "
    cSPBQuery += cAliasSPB + "."
    cSPBQuery += "PB_FILIAL='"+xFilial('SPB')+"'"
    cSPBQuery += " AND "				
    cSPBQuery += cAliasSPB + "."
    cSPBQuery += "PB_MAT='"+SRA->RA_MAT+"'"
    cSPBQuery += " AND "				
    //cSPBQuery += cAliasSPB + "."				
    //cSPBQuery += "PB_PROCES = '"+mv_par01+"'"
    //cSPBQuery += " AND "
    //cSPBQuery += cAliasSPB + "."				
    //cSPBQuery += "PB_PERIODO = '"+mv_par02+"'" 
    //cSPBQuery += " AND "
    //cSPBQuery += cAliasSPB + "."				
    //cSPBQuery += "PB_ROTEIR = '"+"PON"+"'"
    //cSPBQuery += " AND "				
    cSPBQuery += " ( "
    cSPBQuery += 		cAliasSPB + "."
    cSPBQuery += 		"PB_DATA>='"+cIniData+"'"
    cSPBQuery += 		" AND "
    cSPBQuery += 		cAliasSPB + "."
    cSPBQuery += 		"PB_DATA<='"+cFimData+"'"
    cSPBQuery += " ) "
    cSPBQuery += " AND "
    cSPBQuery += cAliasSPB + ".D_E_L_E_T_=' ' "
    cSPBQuery += "ORDER BY " + SqlOrder( (cAliasSPB)->( IndexKey() ) )

    /*
    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    ³ Utiliza ChangeQuery() para Remontar a Query                  ³
    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    cSPBQuery := ChangeQuery( cSPBQuery )
    dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSPBQuery),cAliasQry, .F., .T.)

    nEventos := Len(aInfo)
    
    While ( (cAliasQry)->( !Eof() ) ) 
        nPos := aScan(aInfo, {|x| x[1] == (cAliasQry)->PB_PD })
        If ( nPos > 0 )
            SPB->(dbGoTo((cAliasQry)->RECNO))
            nHrExDe := aInfo[nPos][02]
            nHrExAte:= aInfo[nPos][03]
            If aInfo[nPos][01] == "107" //HE 65%
                If ( (cAliasQry)->PB_HORAS > nHrExAte )
                    nHE65 := ( nHrExAte - (cAliasQry)->PB_HORAS )*-1
                    If RecLock('SPB',.F.)
                        SPB->PB_HORAS := nHrExAte
                        SPB->(MsUnlock())
                    EndIf
                    (cAliasQry)->( dbSkip() )
                    Loop            
                EndIf
            EndIf
            If aInfo[nPos][01] == "108" //HE 85%
                If ( (cAliasQry)->PB_HORAS + nHE65 > nHrExAte )    
                    nHE85 := ( nHrExAte - ( (cAliasQry)->PB_HORAS + nHE65 ) )*-1 
                    SPB->PB_HORAS := nHrExAte
                    SPB->(MsUnlock())
                    (cAliasQry)->( dbSkip() )
                    Loop
                EndIf    
            EndIf
            If aInfo[nPos][01] == "113" //HE 100%
                If ( nHE65 > 0 .Or. nHE85 > 0 )
                    nHE100 := If(nHE85>0,nHE85,nHE65)
                    If RecLock('SPB',.F.)
                        SPB->PB_HORAS := SPB->PB_HORAS + nHE100
                        SPB->(MsUnlock())
                    EndIf
                    (cAliasQry)->( dbSkip() )
                    Loop                
                EndIf
            EndIf
        EndIf
        (cAliasQry)->( dbSkip() )
    EndDo

    (cAliasQry)->(dbCloseArea())

Return( Nil )

Static function fCarrEvt()

    Local aEvFaixa := {;
                    {"107",0,20},;
                    {"108",20.01,40},;
                    {"113",40.01,999.99};
                }

Return( aEvFaixa )