#include "PROTHEUS.CH"
#include "topconn.ch"
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 06.02.2018                                                                                                                       |
| Descricao: P.E na entrada da nota fiscal para gravação dos complementos (CD5)                                                          |
| Empresa: Kapazi                                                                                                                 |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Alteração 25.07.2018 -- Andre/Rsac  -- Vaidado em produção.
User Function MT100AGR()

Local     aAreaOld     := GetArea()
Local     nVlrIOF      := nVlrII := nBcDesp := nBcII := 0
Local     cCodFab      := cCodExp := SF1->F1_FORNECE
Local     dDatDesemb   := dDatDI := dDataCof := dDataPis := CTOD(" / / ")
Local     cNumDI       := Space(12)
Local     cUfDesemb    := Space(2)
Local     cDescLocal   := Space(30)
Local     lContinua    := .F.
Local     lXmlImp      := .F.
local     cNumEdi 	   := Space(10)
local     cSeqEdi      := Space(10)
Local     nVlrMM       := 0
LOCAL     cVTRANS      := ""
Local     cUfTerc    := Space(2)
Local     cCNPJ := Space(14)

//IF INCLUI = .T.
// Se for Formulário Proprio e fornecedor Exterior (Importação)
If  SF1->F1_EST == "EX"  // validar estorno
	
	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Informações sobre a DI de Importação!") From 000,000 to 420,500 of oMainWnd PIXEL
	
	
	@ 005,005 To 195,248 of oDlg1 Pixel
	
			@ 017,015 Say "Número da DI" of oDlg1 Pixel
			@ 018,075 Msget cNumDI Size 050,11 Picture X3Picture("CD5_NDI") of oDlg1 Pixel VALID !Empty(M->cNumDI)
			
			@ 035,015 Say "Data Registro DI" of oDlg1 Pixel
			@ 036,075 Msget dDatDI Size 40,11 of oDlg1 Pixel VALID !Empty(M->dDatDI)
			
			@ 053,015 Say "Descrição Local" of oDlg1 Pixel
			@ 054,075 Msget cDescLocal Size 70,11 Picture X3Picture("CD5_LOCDES") of oDlg1 Pixel  VALID !Empty(M->cDescLocal)
			
			@ 071,015 Say "UF Desembaraço" of oDlg1 Pixel
			@ 072,075 Msget cUfDesemb Size 20,11 of oDlg1 Pixel PICTURE "@!" VALID !Empty(M->cUfDesemb)
			
			@ 089,015 Say "Data Desembaraço" of oDlg1 Pixel
			@ 090,075 Msget dDatDesemb Size 40,11 of oDlg1 Pixel PICTURE "@!" VALID !Empty(M->dDatDesemb)
			
			@ 107,015 Say "Cód.Exportador" of oDlg1 Pixel
			@ 108,075 Msget cCodExp Size 50,11 F3 "SA2" of oDlg1 Pixel PICTURE "@!"  VALID !Empty(M->cCodExp)
			
			@ 125,015 Say "Cód.Fabricante" of oDlg1 Pixel
			@ 126,075 Msget cCodFab Size 50,11 F3 "SA2" of oDlg1 Pixel PICTURE "@!" VALID !Empty(M->cCodFab)
				
			@ 143,015 Say "CNPJ Adquirente" of oDlg1 Pixel
			@ 144,075 MSGET cCNPJ SIZE 55,11 OF oDlg1 PIXEL PICTURE "@R 99.999.999/9999-99" VALID !Empty(M->cCNPJ)
			
			@ 161,015 Say "UF terceiro" of oDlg1 Pixel
			@ 162,075 Msget cUfterc Size 20,11 of oDlg1 Pixel PICTURE "@!" VALID !Empty(M->cUfterc)
			
	@ 197,050 BUTTON "&Confirma" of oDlg1 pixel SIZE 60,12 ACTION (lContinua := .T.,oDlg1:End() )
	@ 197,120 BUTTON "&Cancela" of oDlg1 pixel SIZE 60,12 ACTION (oDlg1:End() )
	
	ACTIVATE MSDIALOG oDlg1 CENTERED
	
	If lContinua
		
		If Select("QSD1")<>0
			DbSelectArea("QSD1")
			dbCloseArea()
		Endif
		
		
		cQry := "SELECT *"
		cQry += " FROM "+RetSqlName("SD1") + " D1 "
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += "   AND D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQry += "   AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQry += "   AND D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQry += "   AND D1_DOC = '"+SF1->F1_DOC+"' "
		cQry += "   AND D1_FILIAL = '"+xFilial("SD1")+"' "
		
		TCQUERY cQry NEW ALIAS "QSD1"
	
	
		
		While !Eof()
			
			DbSelectArea("CD5")
			DbSetOrder(4) //CD5_FILIAL, CD5_DOC, CD5_SERIE, CD5_FORNEC, CD5_LOJA, CD5_ITEM
			If DbSeek(xFilial("CD5")+QSD1->D1_DOC+QSD1->D1_SERIE+QSD1->D1_FORNECE+QSD1->D1_LOJA+QSD1->D1_ITEM)
				RecLock("CD5",.F.)
			Else
				RecLock("CD5",.T.)
			Endif
			
			CD5->CD5_FILIAL  	:= QSD1->D1_FILIAL
			CD5->CD5_DOC 		:= QSD1->D1_DOC
			CD5->CD5_SERIE		:= QSD1->D1_SERIE
			CD5->CD5_ESPEC 		:= "SPED"
			CD5->CD5_FORNEC 	:= QSD1->D1_FORNECE
			CD5->CD5_LOJA 		:= QSD1->D1_LOJA
			CD5->CD5_TPIMP 		:= "0"
			CD5->CD5_DOCIMP 	:= cNumDI   
			CD5->CD5_BSPIS 		:= QSD1->D1_BASIMP6
			CD5->CD5_ALPIS 		:= QSD1->D1_ALQIMP6
			CD5->CD5_VLPIS 		:= QSD1->D1_VALIMP6
			CD5->CD5_BSCOF 		:= QSD1->D1_BASIMP5
			CD5->CD5_ALCOF 		:= QSD1->D1_ALQIMP5
			CD5->CD5_VLCOF 		:= QSD1->D1_VALIMP5
			CD5->CD5_LOCAL 		:= '0'
			CD5->CD5_NDI 		:= cNumDI
			CD5->CD5_DTDI 		:= dDatDI
			CD5->CD5_LOCDES 	:= cDescLocal
			CD5->CD5_UFDES 		:= cUfDesemb
			CD5->CD5_DTDES 		:= dDatDesemb
			CD5->CD5_CODEXP 	:= QSD1->D1_FORNECE
			CD5->CD5_NADIC 		:= "1" 
			CD5->CD5_SQADIC 	:= "1"  
			CD5->CD5_CODFAB 	:= QSD1->D1_FORNECE
			CD5->CD5_LOJFAB 	:= QSD1->D1_LOJA
			CD5->CD5_LOJEXP 	:= QSD1->D1_LOJA
			CD5->CD5_ITEM 		:= QSD1->D1_ITEM
			CD5->CD5_VTRANS 	:= "1"
			CD5->CD5_VAFRMM 	:= 0
			CD5->CD5_INTERM 	:= "1"
			CD5->CD5_CNPJAE		:= cCNPJ
			CD5->CD5_UFTERC		:= cUfterc
			
			MsUnlock()
			
			DbSelectArea("QSD1")
			DbSkip()
			
		Enddo
		msginfo("Registros foram preenchido com sucesso na tabela CD5! DI : "+cNumDI)
		
	
		
		
	Endif
Endif

//ENDIF


RestArea(aAreaOld)

Return
