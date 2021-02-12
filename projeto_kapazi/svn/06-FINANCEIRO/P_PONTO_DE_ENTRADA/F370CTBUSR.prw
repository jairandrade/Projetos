#include 'protheus.ch'
#include 'parmtype.ch'
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Contabilizações adicionais do CTBAFIN/FINA370                                                                                          |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 26/09/2019                                                                                                                       |
| Descricao: Executar contabilizações não disponiveis na rotina CTBAFIN/FINA370                                                          |
|            Rotinas: Contabilização entre Carterias                                                                                     |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function F370CTBUSR

U_CTBCEC()
U_CTBCHCNC()
	
	//Contabilização Compensação entre Carteiras
	User Function CTBCEC

	Private lAbortPrint := .F.
	processa({||ProcCEC()},"Processando baixas do tipo CEC","Buscando Compensações entre Carteiras... "+cFilAnt,.T.)
	
		Static Function ProcCEC()
		
		Local aSM0CEC	:= AdmAbreSM0()
		Local nContFilC	:= 0
		Local cFilDe	:= cFilAnt
		Local cFilAte	:= cFilAnt
		Local _dDataIni	:= mv_par04
		Local _dDataFim	:= mv_par05
		Local _lMostra	:= (mv_par01==1)
		Local _FilPar	:= cFilAnt
		
		Private nHdlPrv	:= 0,cPadrao:="594",lPadrao:=VerPadrao(cPadrao),cLote,cArquivo,;
		lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/),;
		aFlagCTB	:= {}
		
		LoteCont("FIN") // Verifica o lote contábil, alimenta cLote
		_cPerg:='CtbM01'
		
		If mv_par08 == 1	//Considera filiais abaixo? 1- Sim / 2 - Nao 
			If mv_par14 == 1	// Considera Filial Original?  1- Sim, 2 - N?
				cFilDe := MV_PAR15
				cFilAte:= MV_PAR16
			Else
				cFilDe := mv_par09
				cFilAte:= mv_par10
			EndIf
		Endif
		
	
		
		For nContFil := 1 to Len(aSM0CEC)
			If aSM0CEC[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0CEC[nContFil][SM0_CODFIL] > cFilAte
				Loop
			EndIf
			_FilPar := aSM0CEC[nContFil][SM0_CODFIL]
		
			SM0->(dbseek(cEmpAnt+_FilPar))
			Do While SM0->(!eof() .AND. M0_CODIGO + ALLTRIM(M0_CODFIL) == cEmpAnt+_FilPar)
				cFilAnt := SM0->M0_CODFIL
		
			_cSql		:=	"select * from "+retsqlname('SE5')+" SE5 where D_E_L_E_T_=' ' and E5_FILIAL='"+cFilAnt+"' and E5_DATA between '"+dtos(_dDataIni)+"' and '"+dtos(_dDataFim)+"' and E5_MOTBX='CEC' and E5_SITUACA=' ' and E5_LA<>'S'"
			
			_cSql1	:=	'select count(1) as total from ('+_cSql+') tmp'
			_cSql		+=	' order by E5_FILIAL,E5_DATA,E5_IDENTEE'
			
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql1),"_CtbM01",.F.,.T.)
		
			Procregua(_CtbM01->total)
		
			_CtbM01->(dbclosearea())
		
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql),"_CtbM01",.F.,.T.)
			TcSetField("_CtbM01","E5_DATA","D")
		
			_lContabilizou:=.F.
		
			Begin Transaction
		
			_dBkDtBase:=dDataBase
		
				Do While _CtbM01->(!Eof())
					_cChave:=_CtbM01->(E5_FILIAL+DtoS(E5_DATA)+E5_IDENTEE)
					_nTotal:=0
			
					Do While _CtbM01->(!Eof().AND.E5_FILIAL+DtoS(E5_DATA)+E5_IDENTEE==_cChave)
						dDataBase:=_CtbM01->E5_DATA
						SE5->(DBGoto(_CtbM01->R_E_C_N_O_))
						Valor:=SE5->e5_valor
						
						SA1->(DBSetorder(1))
						SA1->(DBSeek(xFilial()+SE5->(E5_CLIENTE+E5_LOJA),.F.))
						
						SA2->(DBSetorder(1))
						SA2->(DBSeek(xFilial()+SE5->(E5_FORNECE+E5_LOJA),.F.))
						
						_CtbM01->(IncProc(DtoC(E5_DATA)+' '+E5_IDENTEE))
						
						If lPadrao
							If nHdlPrv <= 0
								nHdlPrv:=HeadProva(cLote,"FINA450",SubStr(cUsuario,7,6),@cArquivo)
							EndIf
							
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
							Else
								Do While SE5->(!RecLock(alias(),.F.))
								EndDo
								SE5->E5_LA := "S"
								SE5->(MsUnlock())
							EndIf
							_nTotal += DetProva( nHdlPrv, cPadrao, "FINA450", cLote, /*nLinha*/, /*lExecuta*/,;
							/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
							/*lPosiciona*/, @aFlagCTB, {"SE5",_CtbM01->R_E_C_N_O_} /*aTabRecOri*/, /*aDadosProva*/ )
						EndIf
						
						_CtbM01->(DBSkip(1))
						
					EndDo
			
					_lContabilizou:=.T.
			
					RodaProva(nHdlPrv,_nTotal)
					cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, _lMostra /*lDigita*/, .F. /*lAglut*/,;
					/*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )
					
					aFlagCTB := {}  // Limpa o conteudo apos a efetivacao do lancamento
					
				EndDo
				
				dDataBase:=_dBkDtBase
				_CtbM01->(dbclosearea())
				
				_lFecha := .T.
						
				End Transaction
			
				SM0->(DBSkip(1))
			
			EndDo
		
		Next nContFil
		
		//Return ProcCEC
		Return

	//Return CTBCEC
	Return

	//Contabilização offline de cancelamentos de baixas do contas a receber
	User Function CTBCHCNC()
	
	Private lAbortPrint := .F.
	processa({||ProcCNC()},"Processando cancelamentos de baixas a receber (Cheques)","Buscando cheques cancelados... "+cFilAnt,.T.)
	
		Static Function ProcCNC()
		
		Local aSM0CNC	:= AdmAbreSM0()
		Local nContFilC	:= 0
		Local cFilDe	:= cFilAnt
		Local cFilAte	:= cFilAnt
		Local _dDataIni	:= mv_par04
		Local _dDataFim	:= mv_par05
		Local _lMostra	:= (mv_par01==1)
		Local _FilPar	:= cFilAnt
		Local _DtCanBx	:= dDataBase
	
		Local nRecAnt		:= " "
	
		Public nReconNW		:= 0
		Public nLoopCTB		:= 0
	
		Private nTotal		:= 0
		Private nHdlPrv		:= 0
		Private cPadrao
		Private lPadrao		
		Private cLote
		Private cArquivo	:= ' '
		Private lUsaFlag 	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
		Private aFlagCTB	:= {}
	
		If mv_par08 == 1	//Considera filiais abaixo? 1- Sim / 2 - Nao 
			If mv_par14 == 1	// Considera Filial Original?  1- Sim, 2 - N?
				cFilDe := MV_PAR15
				cFilAte:= MV_PAR16
			Else
				cFilDe := mv_par09
				cFilAte:= mv_par10
			EndIf
		Endif
	
		For nContFil := 1 to Len(aSM0CNC)
			If aSM0CNC[nContFil][2] < cFilDe .Or. aSM0CNC[nContFil][2] > cFilAte
				Loop
			EndIf
			_FilPar := aSM0CNC[nContFil][2]
	
			SM0->(dbseek(cEmpAnt+_FilPar))
			Do While SM0->(!eof() .AND. M0_CODIGO + ALLTRIM(M0_CODFIL) == cEmpAnt+_FilPar)
				cFilAnt := SM0->M0_CODFIL
				
				//Localizar os cancelamentos de baixas com cheques
				_cSql		:=	"SELECT * FROM "+retsqlname('SE5')+" SE5 "
				_cSql		+=  "WHERE D_E_L_E_T_ = ' ' "
				_cSql		+=  "AND E5_FILIAL = '"+cFilAnt+"' "
				//_cSql		+=  "AND E5_DTDISPO BETWEEN '"+dtos(_dDataIni)+"' AND '"+dtos(_dDataFim)+"' "
				_cSql		+=  "AND E5_DTDISPO <= '"+dtos(_dDataFim)+"' "
				_cSql		+=  "AND E5_MOTBX = 'NOR' "
				_cSql		+=  "AND E5_SITUACA = 'C' "
				_cSql		+=  "AND E5_TIPODOC = 'BA' "
				_cSql		+=  "AND E5_LA = 'S ' "
				
				_cSql1		:=	'SELECT Count(1) as total FROM ('+_cSql+') tmp'
				
				_cSql		+=	" ORDER BY E5_FILIAL,E5_DTDISPO,E5_NUMCHEQ"
	
				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql1),"_CtbM02",.F.,.T.)
	
				Procregua(_CtbM02->total)
	
				_CtbM02->(dbclosearea())
	
				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSql),"_CtbM02",.F.,.T.)
				TcSetField("_CtbM02","E5_DTDISPO","D")
		
				_lContabilizou := .F.
				
				Begin Transaction
	
					_dBkDtBase := dDataBase
	
					Do While _CtbM02->(!Eof())

						nTotal	:= 0

						SA1->(DBSetorder(1))
						SA1->(DBSeek(xFilial("SA1") + _CtbM02-> (E5_CLIENTE+E5_LOJA),.F.))

						SA6->(DBSetorder(1))
						SA6->(DBSeek(_CtbM02-> (E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA),.F.))
						
						LoteCont("FIN") // Verifica o lote contábil, alimenta cLote

						cPadrao		:= "527" //utilizar essa regra para contabilizar a conciliação do cheque considerando a data para contabilização o campo E5_DTDISPO
						lPadrao		:= VerPadrao(cPadrao) 			
						
						SE5->(DBGoto(_CtbM02->R_E_C_N_O_))
						dDataBase := LocDtCBx()

						If lPadrao
							If nHdlPrv <= 0
								nHdlPrv	:= HeadProva(cLote,"CTBCHCNC",CUSERNAME,@cArquivo)
							EndIf
								If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
									aAdd( aFlagCTB, {"E5_LA", "SS", "SE5", SE5->( Recno() ), 0, 0, 0} )
									//aAdd( aFlagCTB, {"E5_LA", "S", "SE5", _CtbM02->R_E_C_N_O_, 0, 0, 0} )
								Else
									While SE5->(!RecLock(Alias(),.F.))
									
									EndDo
									SE5->E5_LA := "SS"
									SE5->(MsUnlock())
								EndIf
							nTotal	+= DetProva( nHdlPrv, cPadrao, "CTBCHCNC", cLote, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,/*lPosiciona*/, @aFlagCTB, {"SE5",_CtbM02->R_E_C_N_O_}/*aTabRecOri*/, /*aDadosProva*/ )
						EndIf
						RodaProva(nHdlPrv,nTotal)
						cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, _lMostra /*lDigita*/, .F. /*lAglut*/,/*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, /*aDiario*/ )

					_CtbM02->(DBSkip(1))
					
					EndDo
	
					dDataBase	:= _dBkDtBase
	
					_CtbM02->(dbclosearea())
	
					_lFecha := .T.
	
				End Transaction
	
				SM0->(DBSkip(1))
	
			EndDo
		Next nContFil
		//Return Static ProcCNC
		Return
		
		Static Function LocDtCBx
			Local cIDDOCa	:= " "
			Local dDtCanBx	:= dDataBase

				//Localizar IDDOC e SEQ na FK1
				_cSqla		:=	"SELECT * FROM "+retsqlname('FK1')+" FK1 "
				_cSqla		+=  "WHERE D_E_L_E_T_ = ' ' "
				_cSqla		+=  "AND FK1_IDFK1 = '"+SE5->E5_IDORIG+"' "

				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSqla),"_CtbM02a",.F.,.T.)
				
				cIDDOCa := _CtbM02a->FK1_IDDOC
				cIDSEQa := _CtbM02a->FK1_SEQ

				//Localizar data de cancelamento
				_cSqlb		:=	"SELECT * FROM "+retsqlname('FK1')+" FK1 "
				_cSqlb		+=  "WHERE D_E_L_E_T_ = ' ' "
				_cSqlb		+=  "AND FK1_IDDOC = '"+cIDDOCa+"' "
				_cSqlb		+=  "AND FK1_SEQ = '"+cIDSEQa+"' "
				_cSqlb		+=  "AND FK1_TPDOC = 'ES' "

				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSqlb),"_CtbM02b",.F.,.T.)
				TcSetField("_CtbM02b","FK1_DATA","D")

				dDtCanBx := _CtbM02b->FK1_DATA

				_CtbM02a->(dbclosearea())
				_CtbM02b->(dbclosearea())
		
		//Return Static LocDtCBx
		Return(dDtCanBx)
		
	//Return CTBCHCNC
	Return

//Return F370CTBUSR
Return
