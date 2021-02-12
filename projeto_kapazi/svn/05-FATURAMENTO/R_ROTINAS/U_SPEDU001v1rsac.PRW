#INCLUDE "rwmake.ch"
/*
+---------------------------------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+---------------------------------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                             !
+------------------+-------------------------------------------------------------------------------+
!Tipo              ! Função                                              !
+------------------+-------------------------------------------------------------------------------+
!Módulo            !                                                                !
+------------------+-------------------------------------------------------------------------------+
!Nome              ! MESP001                                             !
+------------------+-------------------------------------------------------------------------------+
!Tabelas Utilizadas! SF1,SD1,SF2,SD2,SF3,SFT                                                               !
+------------------+------------------------------------------------------------------------------+
!Descrição         ! Processar itens das NF's - Calcular PIS e COFINS - Gravar Soma na tabela de   !
!                  ! Cabeçalho Correspondente                                                     !
+------------------+------------------------------------------------------------------------------+
!Autor             ! Anderson Franco                                                     !
+------------------+-------------------------------------------------------------------------------+
!Data de Criação   ! 26/05/11                                                            !
+------------------+-------------------------------------------------------------------------------+
!   ATUALIZACÕES                                                                         !
+---------------------------------------------------------------------------------------------------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da  !
!                                                            !Solicitante  ! Respons.!Atualiz.   !
+----------------------------------------------------------+----------------+--------------+------------+
!                                                            !                 !               !              !
!                                                            !                 !               !              !
+----------------------------------------------------------+---------------+--------------+------------+
Incluido gravação doa campos abaixo
//INCLUIDO EM 02/03/2012

SFT->FT_TNATREC := B1_TNATREC
SFT->FT_CNATREC := B1_CNATREC
SFT->FT_CSTCOF  := SF4->F4_CSTCOF
SFT->FT_CSTPIS  := SF4->F4_CSTPISF
SFT->FT_CODBCC  := SF4->F4_CODBCC
SFT->FT_INDNTFR := SF4->F4_INDNTFR
SFT->FT_SITTRIB := SF4->F4_SITTRIB

// gRAVAR UNIDADE DE MEDIDA CASO A MESMA ESTEJA EM BRANCO
If SD2->D2_UM == ""
SD2->D2_UM:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_UM")
EndIf

*/
User Function SPEDU001()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao das variaveis                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


@ 200,1 TO 380,380 DIALOG oProcNF TITLE OemToAnsi("Atualização de PIS e COFINS")
@ 02,10 TO 080,180
@ 10,018 Say " O objetivo desta rotina é recalcular as NF de entrada "
@ 18,018 Say " e saída para apuração dos impostos PIS e COFINS. "
@ 26,018 Say " Serão reprocessadas todas as Notas Fiscais de ENTRADA "
@ 34,018 Say " e SAIDA e recalculados as bases/alíquotas/valores dos "
@ 42,018 Say " referidos IMPOSTOS, conforme alíquotas contidas nos  "
@ 50,018 Say " PARÂMETROS MV_TXPIS e MV_TXCOFIN  "

@ 65,118 BMPBUTTON TYPE 01 ACTION MESP001A()
@ 65,148 BMPBUTTON TYPE 02 ACTION Close(oProcNF)

Activate Dialog oProcNF Centered

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MESP001A ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Processamento do Arquivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico CODAPAR                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MESP001A()

Private _cPerg := Padr("MESP001",10)

AjustaSX1()

If ! Pergunte(_cPerg,.T.)
	Return
EndIf

Processa({|| MESP001B()}," "+" Processando notas  ",,.F.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MESP001B                                                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Processamento do Arquivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico CODAPAR                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MESP001B()
Local _npCOF   := GetMv("MV_TXCOFIN")
Local _npPIS   := GetMv("MV_TXPIS")

//[AKIRA] - INCLUIDO EM 07/10/2013
Local _nB1PCOF := 0
Local _nB1PPIS := 0
//[AKIRA]


// Notas Fiscais de Saida
_cSQL := " SELECT R_E_C_N_O_ SF2_REC "
_cSQL += " FROM "  + RetSqlName('SF2')
_cSQL += " WHERE D_E_L_E_T_ = ' ' "
_cSQL += " AND F2_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
_cSQL += " AND F2_EMISSAO <= '" + DTOS(MV_PAR02) + "'"
_cSQL := ChangeQuery(_cSQL)
If (Select("TRBF2") <> 0)
	DbSelectArea("TRBF2")
	DbCloseArea()
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL),'TRBF2',.T.,.T.)

dbSelectArea("TRBF2")
TRBF2->(DbGoTop())
_nTotReg 	:= Reccount()
_nReg 		:= 0

ProcRegua(_nTotReg)
dbGotop()
While !(TRBF2->(Eof()))
	dbSelectArea("SF2")
	SF2->(DbGoTo(TRBF2->SF2_REC))
	_nReg++
	
	IncProc("Processando NF SAÍDA - "+DTOC(SF2->F2_EMISSAO)+"-"+ StrZero(_nReg,8))
	
	SD2->(DbSelectArea("SD2"))
	SD2->(DbSetOrder(3))
	SD2->(DbGotop())
	//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
	IF SD2->(DbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
		
		_nBD2TI5:=0
		_nVD2TI5:=0
		_nBD2TI6:=0
		_nVD2TI6:=0
		_lalter:=.F.
		DO WHILE SD2->(!EOF()) .AND. SD2->D2_FILIAL == SF2->F2_FILIAL .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE
		
			//[AKIRA] - INCLUIDO EM 07/10/2013
			_npCOF   := GetMv("MV_TXCOFIN")
			_npPIS   := GetMv("MV_TXPIS")	
			_nB1PCOF := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PCOFINS")
			If _nB1PCOF > 0
			   _npCOF   := _nB1PCOF
			EndIf
			
			_nB1PPIS := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PPIS")
			If _nB1PPIS > 0
			   _npPIS   := _nB1PPIS
			Endif

			//[AKIRA]
		
			_cPISCOF:=POSICIONE("SF4",1,XFILIAL("SF4")+SD2->D2_TES,"F4_PISCOF")
			_SitPis :=POSICIONE("SF4",1,XFILIAL("SF4")+SD2->D2_TES,"F4_CSTPIS")
			_SitCof :=POSICIONE("SF4",1,XFILIAL("SF4")+SD2->D2_TES,"F4_CSTCOF")

			IF 	_cPISCOF < '4'
				Reclock("SD2",.f.)
				//				campo F4_PISCOF for igual a 2 ou 3.
				If _cPISCOF=='2' .or. _cPISCOF=='3'
					SD2->D2_BASIMP5 := SD2->D2_TOTAL
					IF (_SitPis <> '04') .and. (_SitPis <> '05') .and. (_SitPis <> '06') .and. (_SitPis <> '07') .and. (_SitPis <> '08') .and. (_SitPis <> '09') 
						SD2->D2_ALQIMP5 := _npCOF
						SD2->D2_VALIMP5 :=SD2->D2_TOTAL*(_npCOF/100)
					ELSE 
						SD2->D2_ALQIMP5 := 0.0
						SD2->D2_VALIMP5 := 0.0
					ENDIF
					_nBD2TI5+=SD2->D2_BASIMP5
					_nVD2TI5+=SD2->D2_VALIMP5
				EndIf
				//				campo F4_PISCOF for igual a 1 ou 3.
				If _cPISCOF=='1' .or._cPISCOF=='3'
					SD2->D2_BASIMP6 := SD2->D2_TOTAL
					IF (_SitCof <> '04') .and. (_SitCof <> '05') .and. (_SitCof <> '06') .and. (_SitCof <> '07') .and. (_SitCof <> '08') .and. (_SitCof <> '09') 
						SD2->D2_ALQIMP6 := _npPIS
						SD2->D2_VALIMP6 :=SD2->D2_TOTAL*(_npPIS/100)
					ELSE  
						SD2->D2_ALQIMP6 := 0.0
						SD2->D2_VALIMP6 := 0.0
					ENDIF
					_nBD2TI6+=SD2->D2_BASIMP6
					_nVD2TI6+=SD2->D2_VALIMP6
				EndIf
				
				// gRAVAR UNIDADE DE MEDIDA CASO A MESMA ESTEJA EM BRANCO
				If SD2->D2_UM == ""
					SD2->D2_UM:= Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_UM")
				EndIf
				
				SD2->(MSUnLock())
				_lalter:=.T.
				// POSICIONA NO PRODUTO
				SB1->(DbSelectArea("SB1"))
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
				
				
				// POSICIONA NA TES
				SF4->(DbSelectArea("SF4"))
				SF4->(DbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES))
				
				
				//cHAVE DE busca Itens Livros Fiscais=	FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
				SFT->(DbSelectArea("SFT"))
				SFT->(DbSetOrder(1))
				
				//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
				If SFT->(DbSeek(SD2->D2_FILIAL+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+"  "+SD2->D2_COD))
					
					Reclock("SFT",.f.)
					If _cPISCOF=='2' .or._cPISCOF=='3'
						SFT->FT_BASECOF := SD2->D2_TOTAL
						IF (_SitCof <> '04') .and. (_SitCof <> '05') .and. (_SitCof <> '06') .and. (_SitCof <> '07') .and. (_SitCof <> '08') .and. (_SitCof <> '09') 
							SFT->FT_ALIQCOF := _npCOF
							SFT->FT_VALCOF  := SD2->D2_TOTAL*(_npCOF/100)
						ELSE 
							SFT->FT_ALIQCOF := 0.0
							SFT->FT_VALCOF  := 0.0
						ENDIF
					EndIf
					If _cPISCOF=='1' .or._cPISCOF=='3'
						SFT->FT_BASEPIS := SD2->D2_TOTAL
						IF (_SitPis <> '04') .and. (_SitPis <> '05') .and. (_SitPis <> '06') .and. (_SitPis <> '07') .and. (_SitPis <> '08') .and. (_SitPis <> '09') 
							SFT->FT_ALIQPIS := _npPIS
							SFT->FT_VALPIS :=SD2->D2_TOTAL*(_npPIS/100)
						ELSE                                           
							SFT->FT_ALIQPIS := 0.0
							SFT->FT_VALPIS  := 0.0
						ENDIF
					EndIf
					//INCLUIDO EM 02/03/2012 
				   /*	IF EMPTY(SB1->B1_TNATREC)
						SFT->FT_TNATREC := MV_PAR03
					ELSE
						SFT->FT_TNATREC := SB1->B1_TNATREC
					ENDIF
					IF EMPTY(SB1->B1_CNATREC)
						SFT->FT_CNATREC := MV_PAR04
					ELSE
						SFT->FT_CNATREC := SB1->B1_CNATREC
					ENDIF*/
					//SFT->FT_CSTCOF  := SF4->F4_CSTCOF
					//SFT->FT_CSTPIS  := SF4->F4_CSTPIS
					//SFT->FT_CODBCC  := SF4->F4_CODBCC
					//SFT->FT_INDNTFR := SF4->F4_INDNTFR
					//SFT->FT_CLASFIS := SF4->F4_SITTRIB
					//SFT->FT_CTIPI   := SF4->F4_CTIPI
					SFT->(MSUnLock())
				EndIf
			ENDIF
			SD2->(DbSkip())
		ENDDO
		If _lalter
			Reclock("SF2",.f.)
			SF2->F2_BASIMP5 := _nBD2TI5
			SF2->F2_VALIMP5 := _nVD2TI5
			SF2->F2_BASIMP6 := _nBD2TI6
			SF2->F2_VALIMP6 := _nVD2TI6
			SF2->(MSUnLock())
			//cHAVE DE busca Itens Livros Fiscais=	FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
			SF3->(DbSelectArea("SF3"))
			SF3->(DbSetOrder(5))
			
			//F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
			
			IF SF3->(DbSeek(SF2->F2_FILIAL+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
				
				Reclock("SF3",.f.)
				
				SF3->F3_BASIMP5 := _nBD2TI5
				SF3->F3_ALQIMP5 := _npCOF
				SF3->F3_VALIMP5 := _nVD2TI5
				
				SF3->F3_ALQIMP6 := _npPIS
				SF3->F3_BASIMP6 := _nBD2TI6
				SF3->F3_VALIMP6 := _nVD2TI6
				SF3->(MSUnLock())
			EndIf
		EndIf
	EndIf
	TRBF2->(DbSkip())
EndDo
DbCloseArea("TRBF2")
DbCloseArea("SF2")
DbCloseArea("SD2")
IncProc("Processando NF de ENTRADA "+space(20))
// Notas Fiscais de ENTRADA
_cSQL := " SELECT R_E_C_N_O_ SF1_REC "
_cSQL += " FROM "  + RetSqlName('SF1')
_cSQL += " WHERE D_E_L_E_T_ = ' ' "
_cSQL += " AND F1_EMISSAO >= '" + DTOS(MV_PAR01) + "'"
_cSQL += " AND F1_EMISSAO <= '" + DTOS(MV_PAR02) + "'"
_cSQL := ChangeQuery(_cSQL)
Memowrite("MESP001_SF1.SQL",_cSQL)
If (Select("TRBF1") <> 0)
	DbSelectArea("TRBF1")
	DbCloseArea()
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL),'TRBF1',.T.,.T.)

dbSelectArea("TRBF1")
TRBF1->(DbGoTop())
_nTotReg 	:= Reccount()
_nReg 		:= 0

ProcRegua(_nTotReg)
dbGotop()
While !(TRBF1->(Eof()))
	dbSelectArea("SF1")
	SF1->(DbGoTo(TRBF1->SF1_REC))
	_nReg++
	IncProc("Processando NF ENTRADA - "+DTOC(SF1->F1_EMISSAO)+"-"+ StrZero(_nReg,8))
	
	SD1->(DbSelectArea("SD1"))
	SD1->(DbSetOrder(1))
	SD1->(DbGotop())
	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	IF SD1->(DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		
		_nBD2TI5:=0
		_nVD2TI5:=0
		_nBD2TI6:=0
		_nVD2TI6:=0
		_lalter:=.F.
		DO WHILE SD1->(!EOF()) .AND. SD1->D1_FILIAL == SF1->F1_FILIAL .AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_FORNECE+SD1->D1_LOJA==SF1->F1_FORNECE+SF1->F1_LOJA
		
		
			//[AKIRA] - INCLUIDO EM 07/10/2013
			_npCOF   := GetMv("MV_TXCOFIN")
			_npPIS   := GetMv("MV_TXPIS")	
			_nB1PCOF := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PCOFINS")
			If _nB1PCOF > 0
			   _npCOF   := _nB1PCOF
			EndIf
			
			_nB1PPIS := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_PPIS")
			If _nB1PPIS > 0
			   _npPIS   := _nB1PPIS
			Endif

			//[AKIRA]
		
		
			_cPISCOF:=POSICIONE("SF4",1,XFILIAL("SF4")+SD1->D1_TES,"F4_PISCOF")
			IF 	_cPISCOF < '4'
				Reclock("SD1",.f.)
				//				campo F4_PISCOF for igual a 2 ou 3.
				If _cPISCOF=='2' .or._cPISCOF=='3'
					SD1->D1_BASIMP5 := SD1->D1_TOTAL
					SD1->D1_ALQIMP5 := _npCOF
					SD1->D1_VALIMP5 := SD1->D1_TOTAL*(_npCOF/100)
					_nBD2TI5+=SD1->D1_BASIMP5
					_nVD2TI5+=SD1->D1_VALIMP5
				EndIf
				//				campo F4_PISCOF for igual a 1 ou 3.
				If _cPISCOF=='1' .or._cPISCOF=='3'
					SD1->D1_BASIMP6 := SD1->D1_TOTAL
					SD1->D1_ALQIMP6 := _npPIS
					SD1->D1_VALIMP6 :=SD1->D1_TOTAL*(_npPIS/100)
					_nBD2TI6+=SD1->D1_BASIMP6
					_nVD2TI6+=SD1->D1_VALIMP6
				EndIf
				
				
				SD1->(MSUnLock())
				_lalter:=.T.
				
				// POSICIONA NO PRODUTO
				SB1->(DbSelectArea("SB1"))
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
				
				
				// POSICIONA NA TES
				SF4->(DbSelectArea("SF4"))
				SF4->(DbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+SD1->D1_TES))
				
				
				//cHAVE DE busca Itens Livros Fiscais=	FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
				SFT->(DbSelectArea("SFT"))
				SFT->(DbSetOrder(1))
				
				//F1_FILIAL+F1_CLIENTE+F1_LOJA+F1_DOC+F1_SERIE
				
				IF SFT->(DbSeek(SD1->D1_FILIAL+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+SD1->D1_COD))
					
					Reclock("SFT",.f.)
					If _cPISCOF=='2' .or._cPISCOF=='3'
						SFT->FT_BASECOF := SD1->D1_TOTAL
						SFT->FT_ALIQCOF := _npCOF
						SFT->FT_VALCOF  := SD1->D1_TOTAL*(_npCOF/100)
					EndIf
					If _cPISCOF=='1' .or._cPISCOF=='3'
						SFT->FT_BASEPIS := SD1->D1_TOTAL
						SFT->FT_ALIQPIS := _npPIS
						SFT->FT_VALPIS  := SD1->D1_TOTAL*(_npPIS/100)
					EndIf
					//INCLUIDO EM 02/03/2012
					IF EMPTY(SB1->B1_TNATREC)
						SFT->FT_TNATREC := MV_PAR03
					ELSE
						SFT->FT_TNATREC := SB1->B1_TNATREC
					ENDIF
					IF EMPTY(SB1->B1_CNATREC)
						SFT->FT_CNATREC := MV_PAR04
					ELSE
						SFT->FT_CNATREC := SB1->B1_CNATREC
					ENDIF
//					SFT->FT_CSTCOF  := SF4->F4_CSTCOF
//					SFT->FT_CSTPIS  := SF4->F4_CSTPIS
//					SFT->FT_CODBCC  := SF4->F4_CODBCC
//					SFT->FT_INDNTFR := SF4->F4_INDNTFR
//					SFT->FT_CLASFIS := SF4->F4_SITTRIB
//					SFT->FT_CTIPI   := SF4->F4_CTIPI
//					SFT->(MSUnLock())
					
					SFT->(MSUnLock())
				EndIf
			ENDIF
			SD1->(DbSkip())
		ENDDO
		If _lalter
			Reclock("SF1",.f.)
			SF1->F1_BASIMP5 := _nBD2TI5
			SF1->F1_VALIMP5 := _nVD2TI5
			SF1->F1_BASIMP6 := _nBD2TI6
			SF1->F1_VALIMP6 := _nVD2TI6
			SF1->(MSUnLock())
			//cHAVE DE busca Itens Livros Fiscais=	FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
			SF3->(DbSelectArea("SF3"))
			SF3->(DbSetOrder(5))
			
			//F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
			
			IF SF3->(DbSeek(SF1->F1_FILIAL+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA))
				
				Reclock("SF3",.f.)
				SF3->F3_BASIMP5 := _nBD2TI5
				SF3->F3_ALQIMP5 := _npCOF
				SF3->F3_VALIMP5 := _nVD2TI5
				
				SF3->F3_BASIMP6 := _nBD2TI6
				SF3->F3_ALQIMP6 := _npPIS
				SF3->F3_VALIMP6 := _nVD2TI6
				
				SF3->(MSUnLock())
			EndIf
		EndIf
	EndIf
	TRBF1->(DbSkip())
EndDo
DbCloseArea("TRBF1")
DbCloseArea("SF1")
DbCloseArea("SD1")
DbCloseArea("SF3")
DbCloseArea("SFT")
Aviso("Finalizado!","Fim da Atualizacao do Arquivo ",{"Ok"})

Return



/*
+-------------------------------------------------------------------------+
! Função    ! AjustaSX1 ! Autor ! Anderson Franco    ! Data !  26/05/11   !
+-----------+-----------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                         !
+-----------+-------------------------------------------------------------+
! Descricao ! Ajusta as perguntas do SX1                                 !
+-----------+-------------------------------------------------------------+
*/
Static Function AjustaSx1

PutSx1(_cPerg,"01","Da data","Da data","Da data","MV_CH1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",{"Data Inicial","","",""},{"Data Inicial","","",""},{"Data Inicial","",""},"")
PutSx1(_cPerg,"02","Até data","Até data","Até data","MV_CH2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",{"Data Final","","",""},{"Data Final","","",""},{"Data Final","",""},"")
PutSx1(_cPerg,"03","Tip.Nat.Rec.","Tip.Nat.Rec.","Tip.Nat.Rec.","MV_CH3","C",4,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",{"Tip.Nat.Rec.","","",""},{"Tip.Nat.Rec.","","",""},{"Tip.Nat.Rec.","",""},"")
PutSx1(_cPerg,"04","Cod.Nat.Rec.","Cod.Nat.Rec.","Cod.Nat.Rec.","MV_CH4","C",4,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",{"Cod.Nat.Rec.","","",""},{"Cod.Nat.Rec.","","",""},{"Cod.Nat.Rec.","",""},"")
Return
