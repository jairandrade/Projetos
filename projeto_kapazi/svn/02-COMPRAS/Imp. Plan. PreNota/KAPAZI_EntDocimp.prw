#include "PROTHEUS.CH"
#include "topconn.ch"
//29062018
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 06.02.2018                                                                                                                       |
| Descricao: Importação de planilha Excel, para entrada do documento na Pre-Nota                                                         |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//05.07.2018 --
User Function EntDocimp()

	// Local     aAreaOld     := GetArea()
	Private cForn        := Space(6)
	Private cLoja        := Space(2)
	Private dDatEmis     := CTOD(" / / ")
	Private lContinua    := .F.
	Private	cEspec	   := Space(6)
	Private cOrig 		:= Space(2)
	Private cDoc 		:= Space(9)
	Private cSerie      := Space(3)
	Private cPgto		:= Space(3)
	Private cNat		:= Space(10)
	Private cProcs      := space(10)
	Private cValMM      := Space(15)
	Private cNFiscal := ""
	private cNfSerie := ""
	Private cFormul := "S"
	Private cSeqAdic := ""
	Private cAdic := ""
	Private cA100for := ""
	Private aCols 		:= {}
	Private cPerg := 'IMPSD1'
	Private aPlanilha := {}
	Private AITENS :={}
	Private aSD1:={}
	private cDirTemp      := GetTempPath() //Pasta temporaria do usuario
	private cItemPED := ""
	private DDEMISSAO := CTOD(" / / ")
	private CESPECIE := "SPED"

	DEFINE FONT oFont3 NAME "Arial" SIZE 000,-016 BOLD

	CriaPerg(cPerg)
	//altura | largura
	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Importação!") From 000,000 to 280,300 of oMainWnd PIXEL


	@ 005,005 To 120,148 of oDlg1 Pixel

	@ 020,015 Say "Fornecedor: " of oDlg1 Pixel
	@ 022,075 Msget cForn Size 050,11 F3 "FOR" of oDlg1 Pixel VALID ExistCpo("SA2", cForn) PICTURE "@!"

	@ 035,015 Say "Loja: " of oDlg1 Pixel
	@ 037,075 Msget cLoja Size 40,11  of oDlg1 Pixel PICTURE "@!" VALID !Empty(M->cLoja)

	@ 050,015 Say "Data Emissão: " of oDlg1 Pixel
	@ 052,075 Msget DDEMISSAO Size 40,11 of oDlg1 Pixel PICTURE "@!"   VALID !Empty(M->DDEMISSAO)

	@ 066,015 Say "Numero do processo: " of oDlg1 Pixel
	@ 067,075 Msget cProcs Size 50,11 of oDlg1 Pixel  PICTURE "@!" VALID !Empty(M->cProcs)


	@ 125,030 BUTTON "&Confirma" of oDlg1 pixel SIZE 40,12 ACTION Processa( {|| ProcArq(), oDlg1:End() } )
	@ 125,080 BUTTON "&Cancela" of oDlg1 pixel SIZE 40,12 ACTION (oDlg1:End() )

	ACTIVATE MSDIALOG oDlg1 CENTERED

Return()


/*
**************************************************

Processa Arquivo

**************************************************
*/
Static Function ProcArq()

	If (Pergunte(cPerg,.T.))

		cArqEnt  := mv_par01
		nPos1    := RAt("\", cArqEnt)
		nPos2    := Len(cArqEnt) - nPos1
		cArqE    := Substr(cArqEnt,nPos1+1, nPos2)
		nPos3    := RAt(".", cArqE)
		cArqE    := Substr(cArqE,1, nPos3-1)
		cOrigemE := substr(cArqEnt,1, nPos1)


		//utiliza user function que le planilha excel
		aPlanilha := U_CargaXLS(cArqE,cOrigemE,0,.F.)

		Processa( {|| Importa(aPlanilha) } ,  "Aguarde, importando registros...")
	EndIf
Return()


/*
**************************************************

Efetua validacao e importacao

**************************************************
*/
Static Function Importa(aPlanilha)

	// Local nContS := 0
	// Local nContF := 0
	// Local ni
	Local nx
	local nz


	Private cQuebra := CHR(13) + CHR(10)
	Private lMsErroAuto:=.F.
	Private cValor := 0


	lInicio     := .F.

	ProcRegua(Len(aPlanilha))
	//For ni := 1 To Len(aPlanilha)

	lMsErroAuto:=.F.


	IncProc("Processando linha: " )  //+ StrZero(ni,5)
	If !lInicio
		IF Alltrim(aPlanilha[2,1]) == "0001" //identifica a linha do cabecalho.
			lInicio := .T.
			//	ni += 2
		EndIf
		//	Loop

	EndIf

	aCabPC := {}
	aItemPC:= {}
	aItem  := {}

	//Busca o sequencial da nota fiscal + serie
	NfeNextDoc(@cNFiscal,@cNfSerie,.t.,@CESPECIE,@DDEMISSAO)
	cSerie := alltrim(cNfSerie)
	For nz := 1 To 1
		aCabPC := {}
		AADD(aCabPC,{"F1_TIPO"   	 ,"N"       ,NIL})
		AADD(aCabPC,{"F1_FORMUL" 	 ,"S"       ,NIL})
		AADD(aCabPC,{"F1_DOC"        ,cNFiscal  ,NIL})
		AADD(aCabPC,{"F1_SERIE"      ,cSerie  ,NIL})
		AADD(aCabPC,{"F1_FORNECE"    ,cForn     ,NIL})
		AADD(aCabPC,{"F1_LOJA"       ,cLoja	 	,NIL})
		AADD(aCabPC,{"F1_EMISSAO"    ,DDEMISSAO	,NIL})
		AADD(aCabPC,{"F1_EST"        ,"EX"   	,NIL})
		AADD(aCabPC,{"F1_ESPECIE"    ,"SPED"	,NIL})
		AADD(aCabPC,{"F1_PROCES"     ,cProcs	,NIL})
	next nz


	For nx := 2 to len(aPlanilha)
		aItemPC := {}

		If Select("TRB")<>0
			DbSelectArea("TRB")
			dbCloseArea()
		Endif

		cQuery := " SELECT  *"
		cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND B1_COD  = '"+aPlanilha[nx,2]+"' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)

		if TRB->B1_MSBLQL = '1'
			msgStop("Produto "+TRB->B1_COD+" se encontra bloqueado!")
		endif
		//Validado 22/08/2017 - baixa de pedido ok.
		cPedPla:= STRZERO(val(Strtran(aPlanilha[nx,12],' ','')),6)

		//busca do D1_PEDIDO e   -- 06/07/2017 -- Andre/Rsac
		If Select("TRBC7")<>0
			DbSelectArea("TRBC7")
			dbCloseArea()
		Endif

		cQuery := " SELECT C7_NUM, C7_ITEM, C7_FORNECE, C7_LOJA
		cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
		cQuery += "	AND C7_FORNECE = '"+ cForn +"'
		cQuery += " AND C7_LOJA = '"+ cloja +"'
		cQuery += " AND C7_PRODUTO = '"+aPlanilha[nx,2]+"' "
		cQuery += " AND C7_NUM like '%"+cPedPla+"%'
		cQuery += " AND C7_RESIDUO <> 'S'
		cQuery += " AND D_E_L_E_T_ <> '*'

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBC7", .F., .T.)


		cItemPED := TRBC7->C7_ITEM

		// adicionado 06/05/2020 - em primeiro pois tem algum gatilho que zera o codigo do produto
		AADD(aItemPC,{"D1_PEDIDO"  ,cPedPla              	,nil} )  
		AADD(aItemPC,{"D1_ITEM"    ,STRZERO(VAL(aPlanilha[nx,1]),4) ,NIL} ) 
		AADD(aItemPC,{"D1_COD"     ,aPlanilha[nx,2] ,NIL} )

		// adicionado 06/05/2020 - puxar os dados do pedido
		AADD(aItemPC,{"D1_ITEMPC"  ,ALLTRIM(cItemPED)     ,nil} )  

		AADD(aItemPC,{"D1_QUANT"   ,Val(StrTran(aPlanilha[nx,3],",","."))		,NIL} ) //aPlanilha[4,6]
		AADD(aItemPC,{"D1_UM"      ,TRB->B1_UM ,NIL} )
		//AADD(aItemPC,{"D1_SEGUM"   ,TRB->B1_SEGUM ,NIL} )
		AADD(aItemPC,{"D1_VUNIT"   ,Val(StrTran(aPlanilha[nx,4],",","."))		,NIL} ) //aPlanilha[4,7]
		AADD(aItemPC,{"D1_TOTAL"   ,Val(StrTran(aPlanilha[nx,5],",","."))	    ,NIL} ) //aPlanilha[4,8]
		AADD(aItemPC,{"D1_DOC"     ,cNFiscal	,NIL} )
		AADD(aItemPC,{"D1_EMISSAO" ,DDEMISSAO		,NIL} )
		AADD(aItemPC,{"D1_DTDIGIT" ,DDEMISSAO     	,NIL} )
		AADD(aItemPC,{"D1_TIPO"    ,"N"         	,NIL} )
		AADD(aItemPC,{"D1_LOCAL"   ,"01"         	,NIL} )
		AADD(aItemPC,{"D1_SERIE"   ,cSerie          ,NIL} )
		AADD(aItemPC,{"D1_GARANTI" ,"N"            	,NIL} )
		AADD(aItemPC,{"D1_FORMUL"  ,"S"            	,NIL} )
		AADD(aItemPC,{"D1_FORNEC"  ,cForn           ,NIL} )
		AADD(aItemPC,{"D1_LOJA"    ,cLoja           ,NIL} )
		AADD(aItemPC,{"D1_II"      ,Val(StrTran(aPlanilha[nx,9],",","."))          	,NIL} )
		AADD(aItemPC,{"D1_NADIC"   ,aPlanilha[nx,10]     	,NIL} )
		AADD(aItemPC,{"D1_SQADIC"  ,aPlanilha[nx,11]       	,NIL} )
		AADD(aItem,aItemPC)

	next nx

	MSExecAuto({|x,y,z|MATA140(x,y,z)},aCabPC,aItem,3)

	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()
		msgstop("Erro na importação! Não foi gerado Pre-Nota.")
	ELSE
		msginfo("Registros importados com sucesso! Foi gerada a Nota fiscal: "+cNFiscal )

		//atualização do campos de valores -- 08.11.2017 -- Andre/Rsac
		If Select("TRF")<>0
			DbSelectArea("TRF")
			dbCloseArea()
		Endif

		cQuery := " SELECT *
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
		cQuery += "	AND D1_FORNECE = '"+ cForn +"'
		cQuery += " AND D1_LOJA = '"+ cloja +"'
		cQuery += " AND D1_DOC = '"+cNFiscal+"'
		cQuery += " AND D_E_L_E_T_ <> '*'
		cQuery += " ORDER BY D1_ITEM

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRF", .F., .T.)

		//		TRF->(DbGoTop())

		//	For nG := 2 to len(aPlanilha)

		/*	DBSelectArea('SD1')
		DBSetORder(1)
		DBSeek(xFIlial('SD1')+cNFiscal+cNfSerie+cForn+cloja+TRF->D1_COD+ALLTRIM(TRF->D1_ITEM)) */



	/*	While !TRF->(Eof()) //.AND. TRF->D1_DOC = cNFiscal .AND. TRF->D1_FORNECE = cForn .AND. TRF->D1_LOJA =  cloja  //.and.  STRZERO(VAL(aPlanilha[nG,1]),3) == TRF->D1_ITEM
			reclock('SD1',.F.)                  	
			//SD1->D1_PEDIDO  := cPedPla
			//SD1->D1_ITEMPC  := TRF->D1_ITEM
			SD1->D1_SERIE := cSerie
			MSUnlock()
			
			TRF->(DBSKIP())


	enddo
		//next nG
		//fim -- 08.11.2017 */
ENDIF

	FT_FUSE()

Return()

/*
**************************************************

Cria perguntas SX1

**************************************************
*/
Static Function CriaPerg(cPerg)

	_PutSx1(	cPerg,"01","Arq.de entrada:","Arq.de entrada:","Arq.de entrada:","mv_ch1",;
		"C",60,0,0,"F","U_PROCARQ1", "", "","",;
		"mv_par01","","","","",;
		"","","",;
		" "," "," ",;
		" "," "," ",;
		" "," "," ",;
		{ "Informe o caminho do arquivo que será ","importado.","","","" },;
		{ "Informe o caminho do arquivo que será ","importado.","","","" },;
		{ "Informe o caminho do arquivo que será ","importado.","","","" }, "")

Return


/*
**************************************************

Validacao SX1

**************************************************
*/
User function PROCARQ1()
	Local carq := ""
	While Empty(alltrim(carq))
		carq := cGetFile("Planilha Excel ( *.XLS ) |*.XLS|  " ,"Escolha arquivo de entrada.",0,,.T.,GETF_LOCALHARD)

		If !file(carq)
			Aviso("Arquivo","Arquivo não seleciona ou invalido.",{"Sair"},1)
			Return(.F.)
		endif

		mvRet      := Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
		&MvRet     := alltrim(cArq)	// Devolve Resultado
	End
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PutSx1    ³ Autor ³Wagner                 ³ Data ³ 14/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma pergunta usando rotina padrao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
		cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
		cF3, cGrpSxg,cPyme,;
		cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
		cDef02,cDefSpa2,cDefEng2,;
		cDef03,cDefSpa3,cDefEng3,;
		cDef04,cDefSpa4,cDefEng4,;
		cDef05,cDefSpa5,cDefEng5,;
		aHelpPor,aHelpEng,aHelpSpa,cHelp)
	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f.
	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	cPyme    := Iif( cPyme   == Nil, " ", cPyme  )
	cF3      := Iif( cF3   == NIl, " ", cF3  )
	cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg )
	cCnt01   := Iif( cCnt01  == Nil, "" , cCnt01  )
	cHelp  := Iif( cHelp  == Nil, "" , cHelp  )
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	If !( DbSeek( cGrupo + cOrdem ))
		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		Reclock( "SX1" , .T. )
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
		Replace X1_VAR01   With cVar01
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
		Replace X1_HELP  With cHelp
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		MsUnlock()
	Else
		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	RestArea( aArea )
Return
