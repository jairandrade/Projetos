#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include 'parmtype.ch'

//----------------------------------------------------------------------------
/*/{Protheus.doc} OMS103
Chamada da Função Principal
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/
User Function OMS103

	Private bLeg		:= {||ZA6Leg()}
	Private lSair	:= .T.

	Private cCadastro := "LOG Integração Transportadoras X Protheus"

	Private cString := "ZA6"
	Private cPerg:= padr("LOGZA6",10)

	dbSelectArea("ZA6")
	dbSetOrder(1)

	AjustaSX1()

	If(!Pergunte(cPerg,.t.))
		Return(.F.)
	EndIf

	ZA6Log()

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} ZA6Log
Visualização do Log
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/
Static Function ZA6Log
	Local aArea		:= GetArea()
	Local oDlg
	Private aPastaA	:= { 	{"Transportadoras"			, "001",""},;
		{"Recebimento TXT"	, "004","2"}}

	Private aPastaM	:= { 	{"Protheus"					, "007",""},;
		{"Geração TXT"		, "008","1"},;
		{"Envio TXT"		, "009","1"},;
		{"Recebimento TXT"	, "010","2"}}


	Private aData		:= {}
	Private aIDTrans	:= {}
	Private aTransa	:= {{"",ctod("//"),"::","","","","","",0}}
	Private oLed1		:= LoadBitmap(GetResources(),"BR_VERDE" )
	Private oLed2		:= LoadBitmap(GetResources(),"BR_VERMELHO" )
	Private oFont1		:= TFont():New( "Calibri",0,16,,.T.,0,,700,.T.,.F.,,,,,, )
	Private cAlias		:= CriaTrab(Nil, .F.)
	Private dDatIni		:= ctod("//")
	Private dDatFim		:= ctod("//")
	Private cNRTR		:= space(10)
	Private cTexto		:= ""
	Private oTree

	oDlg := MsDialog():New(000,000,490,1300,cCadastro,,,.F.,,,,,,.T.,,,.T.)

	oPanel1:= TPanel():New( 000,000,"",oDlg,,.F.,.F.,,RGB(232,232,232),1100,800,.F.,.F. )

	oTree := DbTree():New(005,005,240,280,oPanel1,{|| fGrHist(oTree:GetPrompt())},,.T.)   // Cria a Tree

	oBrw := TcBrowse():New( 015,295,350,140,,,, oPanel1,,,,,,,,,,,, .F.,, .T.,, .F.,,,, )

	oBrw:SetArray( aTransa )

	oBrw:AddColumn( TcColumn():New( ""  	          	, { || aTransa[oBrw:nAt,01] }, ""		,,, "CENTER"	, 005, .T., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "Data"            	, { || aTransa[oBrw:nAt,02] }, "@D"		,,, "CENTER"	, 035, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "Hora"		   		, { || aTransa[oBrw:nAt,03] }, "99:99"	,,, "CENTER"	, 035, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "NR Transação"   	, { || aTransa[oBrw:nAt,04] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "TP Transação"   	, { || aTransa[oBrw:nAt,05] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "TP Movimento"   	, { || aTransa[oBrw:nAt,06] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "Origem"			, { || aTransa[oBrw:nAt,07] }, "@!"		,,, "LEFT"		, 030, .F., .F.,,,, .F., ) )
	oBrw:AddColumn( TcColumn():New( "Usuario"			, { || aTransa[oBrw:nAt,08] }, "@!"		,,, "LEFT"		, 030, .F., .F.,,,, .F., ) )

	oBrw:nAt := 1

	oGrp1  := TGroup():New( 005,290,160,650,"[ Historico Transação ]"	,oPanel1,CLR_BLUE,CLR_WHITE,.T.,.F. )
	oGrp2  := TGroup():New( 165,290,240,650,"[ Pesquisa ]"	,oPanel1,CLR_BLUE,CLR_WHITE,.T.,.F. )

	oSayDIni := tSay():New(173,295,{||"Data Inicio" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
	oGetDini := TGet():New(181,295,{|u| If(PCount()>0,dDatIni:=u	,dDatIni)}	,oGrp2,050,008,'@D'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDatIni",,)

	oSayDFim := tSay():New(173,350,{||"Data Final" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
	oGetDFim := TGet():New(181,350,{|u| If(PCount()>0,dDatFim:=u	,dDatFim)}	,oGrp2,050,008,'@D'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDatFim",,)

	oSayNrTr := tSay():New(173,405,{||"Nr. Transação" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
	oGetNrTr := TGet():New(181,405,{|u| If(PCount()>0,cNRTR:=u	,cNRTR)}	,oGrp2,050,008,'@!'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNRTR",,)

	oBtnVis := tButton():New( 223,510,"Visualizar"	,oPanel1,{||fVisual(aTransa[oBrw:nAt,10])}	,040,012,,,,.T.,,"",,,,.F.)
	oBtnLeg := tButton():New( 223,555,"Legenda"		,oPanel1,{||ZA6LEG()}						,040,012,,,,.T.,,"",,,,.F.)
	oBtnSai := tButton():New( 223,600,"Sair"		,oPanel1,{||oDlg:End()}						,040,012,,,,.T.,,"",,,,.F.)

	fGrGrid() // gera a Base para alimentar a Treeview
	fMntTree() // Monta a Tree View

	oDlg:Activate(,,,.T.,{||lSair})

	RestArea(aArea)

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} fGrGrid
Gera o Grid de transação    
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/     
Static Function fGrGrid
	Local nId:=Len(aPastaA)+len(aPastaM)+1

	If Select( cAlias ) != 0
		(cAlias)->( dbCloseArea() )
	EndIf

	If !empty(MV_PAR01)
		If ValType(MV_PAR01) != "D"
			MV_PAR01:= dDataBase
		Endif
		dDatINI:= MV_PAR01
		MV_PAR01:= ctod("//")
	Endif

	If !empty(MV_PAR02)
		If ValType(MV_PAR02) != "D"
			MV_PAR02:= dDataBase
		Endif
		dDatFIM:= MV_PAR02
		MV_PAR02:= ctod("//")
	Endif

	aIDTrans:= {}

	cQry :=	" SELECT  * FROM " + RetSqlName("ZA6")
	cQry +=	" WHERE "
	cQry +=	" ZA6_FILIAL='" + xFilial("ZA6") +"' AND "
	If !empty(dDatIni)
		cQry += " ZA6_DATA >= '" + dtos(dDatIni) +" ' AND "
	Endif
	If !empty(dDatFim)
		cQry += " ZA6_DATA <= '" + dtos(dDatFim) +" ' AND "
	Endif
	cQry +=	" D_E_L_E_T_=' ' "
	cQry +=	" ORDER BY ZA6_DATA,ZA6_HORA,ZA6_CODIGO "


	TcQuery cQry New Alias (cAlias)
	TCSetField((cAlias),"ZA6_DATA","D",8,0)

	(cAlias)->(DbGoTop())
	While ! (cAlias)->(Eof())

		aAdd( aIDTrans , {	(cAlias)->ZA6_STATUS,;		//01
		(cAlias)->ZA6_DATA,;		//02
		(cAlias)->ZA6_HORA,;		//03
		(cAlias)->ZA6_CODIGO,;		//04
		(cAlias)->ZA6_TIPO,;		//05
		(cAlias)->ZA6_TOMOV,;		//06
		(cAlias)->ZA6_ORIGEM,;		//07
		(cAlias)->ZA6_USERTR,;		//08
		(cAlias)->R_E_C_N_O_} )		//09

		nId++

		(cAlias)->(DbSkip())

	End

	dDatIni	:= ctod("//")
	dDatFim	:= ctod("//")
	cNRTR		:= space(10)

	(cAlias)->( dbCloseArea() )

Return

//----------------------------------------------------------------------------
//________________________________________________________________________________________________________________//
// Função para efeito recursivo para lista de log                                         
// Pastas da TREE(fechada e aberta, respectivamente)
//			FOLDER5, FOLDER6 	 = amarelo
//			FOLDER7, FOLDER8 	 = vermelho
//			FOLDER9            = sem figura nenhuma
//			FOLDER10, FOLDER11 = verde
//			FOLDER12, FOLDER13 = azul
//			FOLDER14, FOLDER15 = preto
//________________________________________________________________________________________________________________//  
/*/{Protheus.doc} fMntTree
Gera a TreeView   
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/
Static Function fMntTree
	Local nX

	If ! oTree:isEmpty()
		oTree:Reset()
	Endif

	aData:= {}
	oTree:BeginUpdate()

// Insere itens
	cTexto:= "Transacoes Transportadoras " + space(70)
	oTree:AddItem( cTexto, aPastaA[01,02], "FOLDER5" ,"FOLDER6",,,1)

	if oTree:treeSeek(aPastaA[01,02])

		For nX:=2 to len(aPastaA)
			cTexto:= aPastaA[nX,01]+ space(100)
			oTree:AddItem( cTexto, aPastaA[nX,02], "FOLDER5" ,"FOLDER6",,,2)
		Next

	Endif

	cTexto:= "Transações Protheus" + space(069)
	oTree:AddItem( cTexto	, aPastaM[01,02], "FOLDER5" ,"FOLDER6",,,1)

	If oTree:TreeSeek( aPastaM[01,02] )

		For nX:=2 to len(aPastaM)
			cTexto:= aPastaM[nX,01]+ space(100)
			oTree:AddItem( cTexto	, aPastaM[nX,02], "FOLDER5" ,"FOLDER6",,,2)
		Next

	endif

	For nX:=1 to len(aIDTrans)

		cImg	:= If(aIDTrans[nX,01] == "1", "PMSDOC","EXCLUIR")
		cTexto:= aIDTrans[nX,04]
		cId	:= aIDTrans[nX,01]

		If aIDTrans[nX,05] == "2"

			nPos := aScan( aPastaA, { |x| x[1] == "Transportadoras" } ) 															//Procura a Pasta Transportadoras
			If oTree:TreeSeek( aPastaA[nPos,02] )

				//nPos := aScan( aPastaA, { |x| x[3] == aIDTrans[nX,09] } ) 											//Procura a Pasta do Movimento
				//	If oTree:TreeSeek( aPastaA[nPos,02] ) 																			//Posiciona na Pasta do Movimento

				nPos := aScan( aData, { |x| x[1] == dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"A" } ) 							//Verifica se ja existe a Data no DbTree
				If nPos <= 0
					aAdd(aData, {dtos(aIDTrans[nX,02])+Str(aIDTrans[nX,09])+"A", cId} )
					aAdd(aData, {dtos(aIDTrans[nX,02])+Str(aIDTrans[nX,09])+"M", cId} )									//Adiciona a Data
					oTree:AddItem( dtoc(aIDTrans[nX,02]) , cId, "FOLDER5" ,"FOLDER6",,,3) 	//Adiciona a Data no TreeView
					If oTree:TreeSeek(cId)																		//Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 										//Adiciona o Texto
						oTree:PtCollApSe()
					Endif
				Else
					If oTree:TreeSeek( aData[nPos,02] ) 																	//Encontrou a Data e Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 										//Adiciona o texto
						oTree:PtCollApSe()
					Endif
				Endif

				oTree:PtCollApSe()
				//Endif

				oTree:PtCollApSe()
			Endif

			oTree:PtCollApSe()
		Endif

		If aIDTrans[nX,05] == "1"

			nPos := aScan( aPastaM, { |x| x[1] == "Protheus" } ) 														//Procura a Pasta Protheus
			If oTree:TreeSeek( aPastaM[nPos,02] )

			//	nPos := aScan( aPastaM, { |x| x[3] == aIDTrans[nX,09] } ) 											//Procura a Pasta do Movimento
			//	If oTree:TreeSeek( aPastaM[nPos,02] ) 																			//Posiciona na Pasta do Movimento

					nPos := aScan( aData, { |x| x[1] == dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"M" } ) 							//Verifica se ja existe a Data no DbTree
					If nPos <= 0
						aAdd(aData, {dtos(aIDTrans[nX,02])+Str(aIDTrans[nX,09])+"M", cId} )									//Adiciona a Data
						oTree:AddItem( dtoc(aIDTrans[nX,02]) , cId, "FOLDER5" ,"FOLDER6",,,3) 	//Adiciona a Data no TreeView
						If oTree:TreeSeek( cId )																		//Posiciona na Pasta
							oTree:AddItem( cTexto, cId, cImg,,,,4) 										//Adiciona o Texto
							oTree:PtCollApSe()
						Endif
					Else
						If oTree:TreeSeek( aData[nPos,02] )													//Encontrou a Data e Posiciona na Pasta
							oTree:AddItem( cTexto, cId, cImg,,,,4) 										//Adiciona o texto
							oTree:PtCollApSe()
						Endif
					Endif

					oTree:PtCollApSe()
				Endif

				oTree:PtCollApSe()
			//Endif

			oTree:PtCollApSe()
		Endif

	Next

	For nX:= len(aPastaA) to 1 step -1
		oTree:TreeSeek(aPastaA[nX,02])
		oTree:PtCollApSe()
	Next

	For nX:= len(aPastaM) to 1 step -1
		oTree:TreeSeek(aPastaM[nX,02])
		oTree:PtCollApSe()
	Next

//oTree:TreeSeek("001") 
//oTree:PtCollApSe()

	oTree:EndUpdate()
// Indica o término da contrução da Tree
	oTree:EndTree()

/*    
// Cria botões com métodos básicos
TButton():New( 160, 002, "Seek Item 4", oDlg,{|| oTree:TreeSeek("004")},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 160, 052, "Enable"    , oDlg,{|| oTree:SetEnable() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 160, 102, "Disable"    , oDlg,{|| oTree:SetDisable() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 160, 152, "Novo Item", oDlg,{|| TreeNewIt() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172,02,"Dados do item", oDlg,{|| Alert("Cargo: "+oTree:GetCargo()+chr(13)+"Texto: "+oTree:GetPrompt(.T.)) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172, 052, "Muda Texto", oDlg,{|| oTree:ChangePrompt("Novo Texto Item 001","001") },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172, 102, "Muda Imagem", oDlg,{|| oTree:ChangeBmp("LBNO","LBTIK",,,"001") }, 40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 172, 152, "Apaga Item", oDlg,{|| if(oTree:TreeSeek("006"),oTree:DelItem(),) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
*/

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} fGrHist
Gera o Grid de Historico da transação 
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@param pLinha, param_type, param_description
@return return_type, return_description
/*/
Static Function fGrHist(pLinha)
	Local nX:= 0

	aTransa:= {}

	//If substr(pLinha,1,1)  $ "C#P"

		For nX:=1 to len(aIDTrans)

			If aIDTrans[nX,04] == alltrim(pLinha)
				aAdd( aTransa , {		Iif(aIDTrans[nX,01]=="1",oLed1,oLed2),;
					aIDTrans[nX,02],;
					aIDTrans[nX,03],;
					aIDTrans[nX,04],;
					aIDTrans[nX,05],;
					aIDTrans[nX,06],;
					aIDTrans[nX,04],;
					aIDTrans[nX,07],;
					Iif(aIDTrans[nX,05]=="1","Protheus","Transportadoras"),;
					aIDTrans[nX,09] })  //Recno da Tabela
			Endif

		Next
	//Endif

	If Len(aTransa) == 0
		aTransa	:= {{"",ctod("//"),"::","","","","","","",0}}
	Endif

	oBrw:SetArray( aTransa )
	oBrw:Refresh()

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} ZA6Leg
Legenda do MBrowse
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/
Static Function ZA6Leg()
	Local cCadastro:= "Controle de Transacao"

	Local aLegenda := {	{"BR_VERDE"		, "Enviado / Recebido com Sucesso"	},;
		{"BR_VERMELHO"	, "Enviado / Recebido com Erro"	}}

	BrwLegenda(cCadastro,"Legendas",aLegenda)

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fVisual
Visualiza a Transação
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@param pRecno, param_type, param_description
@return return_type, return_description
/*/
Static Function fVisual(pRecno)
	Local aZA6:= GetArea()
	Local nOpca:= 0

	If pRecno > 0
		DbSelectArea("ZA6")
		ZA6->(DbSetOrder(1))
		ZA6->(DbGoto(pRecno))

		nOpca := AxVisual("ZA6",ZA6->(Recno()),2)

	Endif

	RestArea(aZA6)

Return

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Verifica o Grupo de PErguntas na Tabela SX1
@type function
@version 
@author Jair Andrade
@since 11/12/2020
@return return_type, return_description
/*/
Static Function AjustaSX1()

	CheckSX1(cPerg, "01", "Data De?"	, "Data De?"	, "Data De?"	, "mv_ch1"		, "D", 08, 0, 0, "G", "", ""	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	CheckSX1(cPerg, "02", "Data Ate?"	, "Data Ate?"	, "Data Ate?"	, "mv_ch2"		, "D", 08, 0, 0, "G", "", ""	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return
