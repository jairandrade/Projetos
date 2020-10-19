#INCLUDE 'TOPCONN.CH'
#Include 'Protheus.ch'                                                                                                                 

// Ponto de entrada  - recalcula apontamentos de acordo com regras definidas. 
                                                                    
User Function PonaPo4()      

    Local __aMarcacoes  := aClone( ParamIxb[1] )
    Local __aTabCalend  := aClone( ParamIxb[2] )
    Local __aCodigos    := aClone( ParamIxb[3] )
    Local __aEvesIds    := aClone( ParamIxb[4] )
    Local __aResult	    := aClone( aEventos )
    Local __aResAux := {}

    Local cTpMarc 	  := Space( GetSx3Cache( "PC_TPMARCA"	, "X3_TAMANHO" ) )
    Local cPeriodo	  := ""
    Local nTole   	  := 0
    Local cArred	  := ""

    Local nPosData    := 1   // data
    Local nPosPD      := 2   // pd
    Local nPosQt      := 3   // quantidade
    Local nPosCC      := 5   // centro de custo
    Local dDt
    Local cPD
    Local nPOs
    Local nFor
    Local nDifHE
    Local nHE

    //--------------------------------------------------------------------------------------
    // VARIÁVEIS PARA CALCULO DE BH
    
    Local nHoras 		:= 0
    Local cCusto 		:= SRA->RA_CC
    Local cTpMarc 		:= Space( GetSx3Cache( "PC_TPMARCA"	, "X3_TAMANHO" ) )
    Local lSoma		:= .F.
    Local cPeriodo		:= ""
    Local nTole   		:= 0
    Local cArred		:= ""
    Local lSubstitui	:= .T.
    Local n,i,nJ,nDel
    Local dDiaAnt		:= Ctod("")
    Local nHorasAnt		:= 0     
    Local nTipoAnt		:= "  "    
    Local cCodEve		:= "   "  
    Local nTam			:= Len(__aResult)            
    Local lCalc			:= .f.
    Local nHE65 		:= 0
    Local nHE85			:= 0
    Local nHE100		:= 0
    Local cHE65			:= GetMv('TCP_HE65') // 107;350
    Local cBH			:= GetMv('TCP_BH') // 106
    Local nTotBH		:= GetMv('TCP_TOTBH') // 1
    Local nHE 			:= 0
    Local aDelRec		:= {}
    Local lAchouBH		:= .f.
    Local lAchouD		:= .f.
    Local lAchouH65     := .f.
    Local cCcJ6H        := GetMv('TCP_CCJ6H')  //Centro de custos autorizados p/ jornada de trabalho de 6 horas 
    Local cEvJ6H        := GetMv('TCP_EVJ6H')
    Local nHrsJorn      := 6
    Local nHrCalc       := 0
    //--------------------------------------------------------------------------------------

    Private cPF_REGRAPA := ""
                                                
    //--------------------------------------------------------------------------------------
    // CALCULO DE BH

    //MsgStop("ponto de entrada ativo")

    cQuery := "SELECT RA_ACUMBH FROM "+RetSqlName('SRA')+" WHERE RA_FILIAL = '"+xFIlial('SRA')+"' and RA_MAT = '"+SRA->RA_MAT+"' AND D_E_L_E_T_ != '*' "

    If Select("TRBSPA") > 0
        TRBspa->(DbCloseArea())
    EndIf

    cQuery := ChangeQuery( cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TRBSPA", .F., .T. )
    dbSelectArea("TRBSPA")
 
	If Len(__aResult) == 0
		Return
	EndIF

    //Elimino os elementos repetidos com o mesmo evento no mesmo dia
	aSort(__aResult,,,{|x,y| DTOS(x[1])+x[2] < DTOS(y[1])+y[2] }) 

    nTam			:= Len(__aResult)

    For nJ := 1 to nTam
        If (nJ+1) <= (nTam)
            If  __aResult[nJ][1] == __aResult[nJ+1][1] .And. __aResult[nJ][2] == __aResult[nJ+1][2] //Se mesmo codigo e mesma data
                __aResult[nJ+1][3] := SomaHoras(__aResult[nJ][3],__aResult[nJ+1][3])
                AADD(aDelRec,nJ)
            EndIf
        EndIf
    Next nJ

    For nDel := len(aDelRec) to 1 STEP -1
		ADel(__aResult,aDelRec[nDel]) 
	Next
	
    ASize(__aResult,Len(__aResult) - len(aDelRec)) 
		
	aDelRec		:= {} 	
	
    aSort(__aResult,,,{|x,y| DTOS(x[1])+x[2] < DTOS(y[1])+y[2] })

	nTam			:= Len(__aResult) 
	//Fim da Customização

	For n:= 1 to nTam            
	
		If AllTrim(__aResult[n][2]) = "350"  //SE H. E. 65% NORM NOT AUT
			dDia 		:= __aResult[n][1]     
			lAchouD		:= .F. //Variavel de controle se achou 107 - diurna
			For nJ := 1 to Len(__aResult)
				If AllTrim(__aResult[nJ][2]) = "107" .AND. __aResult[nJ][1] == dDia // se tiver envento de 107 para o dia
					/*Kaique Sousa - 15/07/2019
					Descontinuado pois dessa forma não estava calculando adicional de hora extra noturno.*/	
					/*
					__aResult[nJ][3] := SomaHoras(__aResult[nJ][3] , __aResult[n][3])//Soma 350 com 107
					AADD(aDelRec,n) // será apagado o registro da HE
					*/
					__aResult[n][2] := "107"
					__aResult[n][3] := SomaHoras(__aResult[nJ][3] , __aResult[n][3])//Soma 350 com 107
					
					//Deleto a posição do 110 do dia p/ nao haver duplicidade
					AADD(aDelRec,nJ) 
					lAchouD	:= .t.
					exit
				EndIf
			Next      
			If !lAchouD   
				__aResult[n][2] := "107"				
			EndIf 
			
		EndIf
		
		If AllTrim(__aResult[n][2]) = "353"
			dDia 		:= __aResult[n][1]     
			lAchouD		:= .F. //Variavel de controle se achou 110 - diurna
			For nJ := 1 to Len(__aResult)
				If AllTrim(__aResult[nJ][2]) = "110" .AND. __aResult[nJ][1] == dDia // se tiver envento de 110 para o dia
					
					/*Kaique Sousa - 15/07/2019
					Descontinuado pois dessa forma não estava calculando adicional de hora extra noturno.*/	
					/*
					__aResult[nJ][3] := SomaHoras(__aResult[nJ][3] , __aResult[n][3])//Soma 353 com 110
					AADD(aDelRec,n) // será apagado o registro da HE
					*/
					
					//Altero de 353 p/ 110 e somo as horas do 110 com a 353
					__aResult[n][2] := "110"
					__aResult[n][3] := SomaHoras(__aResult[nJ][3] , __aResult[n][3])//Soma 353 com 110
					
					//Deleto a posição do 110 do dia p/ nao haver duplicidade
					AADD(aDelRec,nJ)
					lAchouD	:= .t.
					exit
				EndIf
			Next    
			If !lAchouD
				__aResult[n][2] := "110"
			EndIf
			
		EndIf    
	Next       

	For nDel := len(aDelRec) to 1 STEP -1
		ADel(__aResult,aDelRec[nDel])
	Next
	
    ASize(__aResult,Len(__aResult) - len(aDelRec)) 
		
	aDelRec		:= {} 	 
	
    aSort(__aResult,,,{|x,y| DTOS(x[1])+x[2] < DTOS(y[1])+y[2] }) 

    nTam			:= Len(__aResult)  

    //Elimino os elementos repetidos com o mesmo evento no mesmo dia
    For nJ := 1 to nTam
        If (nJ+1) <= (nTam)
            If  __aResult[nJ][1] == __aResult[nJ+1][1] .And. __aResult[nJ][2] == __aResult[nJ+1][2] //Se mesmo codigo e mesma data
                __aResult[nJ+1][3] := SomaHoras(__aResult[nJ][3],__aResult[nJ+1][3])
                AADD(aDelRec,nJ) 
            EndIf
        EndIf
    Next nJ

    For nDel := len(aDelRec) to 1 STEP -1
		ADel(__aResult,aDelRec[nDel]) 
	Next
	
    ASize(__aResult,Len(__aResult) - len(aDelRec)) 
		
	aDelRec		:= {} 	
	
    aSort(__aResult,,,{|x,y| DTOS(x[1])+x[2] < DTOS(y[1])+y[2] })

    nTam			:= Len(__aResult)      

    If TRBSPA->RA_ACUMBH == "S"

        lCalc := .f.      
        
        If Len(__aResult) == 0
            Return
        EndIF

        dDiaAnt := __aResult[1][1] 
        
        For n:= 1 to nTam            

            dDia 		:= __aResult[n][1]

            If AllTrim(__aResult[n][2]) = "107"
                
                lAchouH65   := .T.
                lAchouBh 	:= .F. //Variavel de controle se achou BH
                nTot340     := 0
                
                For nJ := 1 to Len(__aResult)
                    
                    //Procuro se teve intervalo p/ o dia pq intervalo vai para o BH
                    If AllTrim(__aResult[nJ][2]) == "340" .AND. __aResult[nJ][1] == dDia 
                        nTot340 := __aResult[nJ][3]
                        If nTot340 > nTotBH //Se for maior que o valor permitido para o BH
                            __aResult[nJ][3] := nTotBH          
                        EndIf
                    EndIf
                    //Procuro se teve evento 106 p/ o dia pq é banco de hrs
                    If AllTrim(__aResult[nJ][2]) $ cBH .AND. __aResult[nJ][1] == dDia // se tiver envento de BH para o dia
                        lAchouBh 	:= .T.
                        If __aResult[nJ][3] < nTotBH
                            nSaldo := SubHoras(nTotBH,__aResult[nJ][3]) //calcula o saldo restante para BH no dia
                            If nSaldo > __aResult[n][3] // se o saldo for maior que o volume de HE 65
                                __aResult[nJ][3] := SomaHoras(__aResult[nJ][3] , __aResult[n][3]) //Soma BH com HE
                                AADD(aDelRec,n) // será apagado o registro da HE
                            Else
                                __aResult[nJ][3] := nTotBH // Banco de horas recebe total de BH
                                __aResult[n][3] := SubHoras(__aResult[n][3],nSaldo)// HE recebe o valor atual reduzido do saldo de BH transferido
                            EndIf
                        EndIf				 
                    EndIf
                
                Next
                
                 // se não achou nenhum evendo de BH para aquele dia
                If !lAchouBh .Or. nTot340 > 0
                    //se as horas de HE forem menores que as horas permitidas para BH
                    If SomaHoras( __aResult[n][3], nTot340 ) < nTotBH
                        AADD(aDelRec,n)
                        fGeraRes(	@__aResult, __aResult[n][1], __aResult[n][3], SubSTr(cBH,1,3), cCusto, cTpMarc, .T., cPeriodo, nTole, cArred, .F.	)//Cria movimento para BH
                    Else
                        If nTot340 > 0
                            nSaldoBH := SubHoras(nTotBH,nTot340)
                        Else
                            nSaldoBH := nTotBH
                        EndIf

                        If SubHoras(__aResult[n][3] , nSaldoBH) > 0
                            __aResult[n][3] := SubHoras(__aResult[n][3] , nSaldoBH) //reduz valor da hora de HE
                        Else
                            __aResult[n][3] := SubHoras( nSaldoBH, __aResult[n][3]) 
                        EndIf
                        
                        fGeraRes(	@__aResult, __aResult[n][1], nSaldoBH, SubSTr(cBH,1,3), cCusto, cTpMarc, .T., cPeriodo, nTole, cArred, .F.	)//Cria movimento para BH
                    EndIf
                EndIf	

            EndIf

            //Se não achou o 107 entra na condição
            If !lAchouH65 .And. Alltrim(__aResult[n][2]) = "340"
                    
                //Procuro se teve intervalo p/ o dia pq intervalo vai para o BH e se é maior que o BH
                nSaldo := SubHoras(__aResult[n][3],nTotBH) 
                
                If __aResult[n][3] > nTotBH //Se for maior que o valor permitido para o BH
                    __aResult[n][3] := nTotBH          
                EndIf
                
                //Se for saldo maior que 0 entendo que excedeu 1 hora
                if nSaldo > 0
                    fGeraRes(	@__aResult, __aResult[n][1], nSaldo, "107", cCusto, cTpMarc, .T., cPeriodo, nTole, cArred, .F.	)//Cria movimento para BH
                endif

            EndIf
            
        Next               

        For nDel := len(aDelRec) to 1 STEP -1
            ADel(__aResult,aDelRec[nDel])
        Next
        
        ASize(__aResult,Len(__aResult) - len(aDelRec))

    Endif	

    /*  Kaique Mathias - 26/11/2019 - Alteração para atendimento do GMUD041 - Automatização jornada de 
        trabalho de 6 horas Previsto em Acordo Coletivo que algumas funções tem sua jornada de trabalho 
        de 6 horas diáriraas e que estes quando chamados para trabalhar podem cumprir seu horário normal ou 
        serem dispensados do trabalho antecipadamente devido a demanda do dia, porém obrigatoriamente 
        a empresa deverá pagar a estes colabodores 6 horas/dia no mínimo, nunca menos do que estipulado no 
        contrato de trabalho.
    */

	if ( Alltrim(cCusto) $ cCcJ6H ) //'009001|001039|001040|001041|001042'

		nTam			:= Len(__aResult)

		For n:= 1 to nTam
            //Cenario 1 - Se saiu antecipadamente, coloco como saida antecipada abonada
			If AllTrim(__aResult[n][2]) = "428"
				__aResult[n][2] := "007"
			Else
                If ( AllTrim(__aResult[n][2]) $ cEvJ6H ) //107~113~023
                    If ( __aResult[n][3] > 1 ) 
                        //Busco o evento de Hora extra Noturna p/ o dia
                        nHoras  := 0
                        dData   := __aResult[n][1]
                        
                        fBuscaEven("357",__aResult,dData,@nHoras)
                        
                        nCont   := 0
                        nHrCalc := __aResult[n][3]

                        //Se hora extra calculada pelo sistema for menor que 6 e maior que 1
                        If ( __aResult[n][3] < nHrsJorn ) .And. ( __aResult[n][3] > 1 )
                            nHrCalc := nHrsJorn
                        ElseIf ( __aResult[n][3] > nHrsJorn ) .And. ( SubHoras(nHrsJorn,__aResult[n][3]) > 1  )
                            nHrCalc := ( nHrsJorn * 2 ) //Hrs dobradas
                        EndIf
                        
                        If ( nHoras > 0 )
                            nHoras := SubHoras(nHrCalc,nHoras)
                        Else
                            nHoras := nHrCalc
                        EndIf
                        
                        __aResult[n][3]  := nHoras
                    
                    EndIf
                EndIf
            Endif
		next n
	endif

    aEventos := aClone( __aResult )

//--------------------------------------------------------------------------------------

Return( NIL )


//--------------------------------------------------------------------------------------
// Verifica se o funcionario está num turno multifuncional      

Static Function MultiFunc(dDt,cTnoMF)

If Select("TRBMF") > 0
	TRBMF->(DbCloseArea())
EndIf

//busca enventos de horas normais
//cQuery := " SELECT COUNT(*) NCONT "
cQuery := " SELECT * "
cQuery += " FROM " + RetSQLName("SPF")+" SPF  "
cQuery += " where SPF.PF_FILIAL = '" + XFilial("SPF") + "' "
cQuery += "       AND SPF.PF_MAT = '" + SRA->RA_MAT + "' "
cQuery += "       AND SPF.PF_DATA <= '" + DTOS(dDt) + "' "
//cQuery += "       AND SPF.PF_TURNOPA IN " + FORMATIN(cTnoMF,"/")
cQuery += "       AND SPF.D_E_L_E_T_ <> '*' "  
cQuery += " order by PF_DATA DESC "

cQuery := ChangeQuery( cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TRBMF", .F., .T. )
dbSelectArea("TRBMF")
	
lRet := .F.
//If TRBMF->NCONT > 0
//	lRet:= .T.
//EndIf

If TRBMF->PF_TURNOPA $ cTnoMF
	lRet:= .T.
EndIf

cPF_REGRAPA := TRBMF->PF_REGRAPA

Return(lRet)

//--------------------------------------------------------------------------------------
// Busca no cadastro de regras a tolerancia de hora extra por periodo 

Static Function TOLHEPE(cPF_REGRAPA)

If Select("TRBSPA") > 0
	TRBspa->(DbCloseArea())
EndIf

//busca regras
cQuery := " SELECT * "
cQuery += " FROM " + RetSQLName("SPA")+" SPA  "
cQuery += " where SPA.PA_FILIAL = '" + XFilial("SPA") + "' "
cQuery += "       AND SPA.PA_CODIGO = '" + cPF_REGRAPA + "' "
cQuery += "       AND SPA.D_E_L_E_T_ <> '*' "  

cQuery := ChangeQuery( cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TRBSPA", .F., .T. )
dbSelectArea("TRBSPA")

Return(TRBSPA->PA_TOLHEPE)

//--------------------------------------------------------------------------------------
// CONVERTE HORAS EM VALOR

Static Function HTON(nHoras)   

Local nValor

nValor := Int(nHoras) + ((nHoras - Int(nHoras)) / 60 * 100)

Return(nValor)

//--------------------------------------------------------------------------------------
// CONVERTE VALOR EM HORAS

Static Function NTOH(nValor)

Local nHoras

nHoras := Int(nValor) + ((nValor - Int(nValor))	 * 60 / 100)

Return(nHoras)

Static Function fBuscaEven(cEvento,__aResult,dData,nHENot)
    
    Local nJ
    Default nHENot := 0

    For nJ := 1 to len(__aResult) 
        If __aResult[nJ][1] == dData
            If __aResult[nJ][2] == cEvento
                nHENot := __aResult[nJ][3]
                Exit
            EndIf
        EndIf
    Next n

Return( Nil )