#INCLUDE "PROTHEUS.CH"                                                                                                                                           
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"  
#include 'parmtype.ch'

//----------------------------------------------------------------------------
/*/{Protheus.doc} CadZA1
Chamada da Função Principal
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
User Function CadZA1

Private bLeg		:= {||ZA1Leg()}  
Private lSair	:= .T.

Private cCadastro := "LOG Integração CyberLog X Protheus"

Private cString := "ZA1" 
Private cPerg:= padr("LOGZA1",10)

dbSelectArea("ZA1")
dbSetOrder(1) 

AjustaSX1()

If(!Pergunte(cPerg,.t.))
 Return(.F.)
EndIf

ZA1Log()

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} ZA1Log
Visualização do Log
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function ZA1Log
Local aArea		:= GetArea()
Local cTkn 		:= ""
Local oDlg
Local aRet 		:= {}
Private aPastaC	:= { 	{"CYBERLOG"			, "001",""},;
						{"Inventario"		, "002","1"},;
						{"Pedidos"			, "005","5"},;
						{"Recebimentos"		, "006","6"},;
						{"Movto. Interna"	, "007","8"},; 
						{"Transferencias"	, "008","9"}}
							
Private aPastaP	:= { 	{"Protheus"			, "007",""},;
						{"Produto"			, "008","1"},;
						{"Fornecedor"		, "009","2"},;
						{"Cliente"			, "010","3"},;
						{"Pessoa"			, "011","4"},;
						{"Pedidos"			, "012","5"},;
						{"Recebimentos"		, "013","6"},;
						{"Manut.Lote"		, "014","7"},;
						{"Movto. Interna"	, "015","8"},;
						{"Transferencias"	, "016","9"}}


Private aData		:= {} 
Private aIDTrans	:= {} 
Private aTransa		:= {{"",ctod("//"),"::","","","","","","",0}}
Private oLed1		:= LoadBitmap(GetResources(),"BR_VERDE" )
Private oLed2		:= LoadBitmap(GetResources(),"BR_VERMELHO" )   
Private oFont1		:= TFont():New( "Calibri",0,16,,.T.,0,,700,.T.,.F.,,,,,, )  
Private cAlias		:= CriaTrab(Nil, .F.)  
Private dDatIni		:= ctod("//")
Private dDatFim		:= ctod("//")  
Private cNRTR		:= space(10)
Private cNrToken	:= "Token: "
Private MSDIALOG	:= ""
Private cTexto		:= ""  
Private cLog 		:= ""
Private oTree
Private oGLog
Private oGTkn

oDlg := MsDialog():New(000,000,490,1300,cCadastro,,,.F.,,,,,,.T.,,,.T.)

oPanel1:= TPanel():New( 000,000,"",oDlg,,.F.,.F.,,RGB(232,232,232),1100,800,.F.,.F. )  

oTree := DbTree():New(005,005,240,280,oPanel1,{|| fGrHist(oTree:GetPrompt())},,.T.)   // Cria a Tree

oBrw := TcBrowse():New( 015,295,350,060,,,, oPanel1,,,,,,,,,,,, .F.,, .T.,, .F.,,,, )                               

oBrw:SetArray( aTransa )                                                                                                             

oBrw:AddColumn( TcColumn():New( ""  	          	, { || aTransa[oBrw:nAt,01] }, ""		,,, "CENTER"	, 005, .T., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "Data"            	, { || aTransa[oBrw:nAt,02] }, "@D"		,,, "CENTER"	, 035, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "Hora"		   		, { || aTransa[oBrw:nAt,03] }, "99:99"	,,, "CENTER"	, 035, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "NR Transação"   	, { || aTransa[oBrw:nAt,04] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "TP Transação"   	, { || aTransa[oBrw:nAt,05] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "Usuário"	   		, { || aTransa[oBrw:nAt,06] }, "@!"		,,, "LEFT"		, 045, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "Origem"			, { || aTransa[oBrw:nAt,07] }, "@!"		,,, "LEFT"		, 030, .F., .F.,,,, .F., ) )
oBrw:AddColumn( TcColumn():New( "TP Movimento"		, { || aTransa[oBrw:nAt,08] }, "@!"		,,, "LEFT"		, 030, .F., .F.,,,, .F., ) )
oBrw:bChange 		:= { || (cLog:= aTransa[oBrw:nAt,09] , oGLog:Refresh()) }
oBrw:nAt := 1

oGrp1	:= TGroup():New( 005,290,160,650,"[ Historico Transação ]"	,oPanel1,CLR_BLUE,CLR_WHITE,.T.,.F. )  
oSLog	:= tSay():New(080,295,{||"Log da Transação" },oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oGLog	:= tMultiget():new(088,295,{| u | if( pCount() > 0, cLog := u, cLog )},oGrp1,350,63,,,,,,.T.,,,,,,.T.)

oGrp2	:= TGroup():New( 165,290,240,650,"[ Pesquisa ]"	,oPanel1,CLR_BLUE,CLR_WHITE,.T.,.F. )     
oSayDIni := tSay():New(173,295,{||"Data Inicio" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oGetDini := TGet():New(181,295,{|u| If(PCount()>0,dDatIni:=u	,dDatIni)}	,oGrp2,050,008,'@D'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDatIni",,) 

oSayDFim := tSay():New(173,350,{||"Data Final" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oGetDFim := TGet():New(181,350,{|u| If(PCount()>0,dDatFim:=u	,dDatFim)}	,oGrp2,050,008,'@D'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDatFim",,)

oSayNrTr := tSay():New(173,405,{||"Nr. Transação" },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oGetNrTr := TGet():New(181,405,{|u| If(PCount()>0,cNRTR:=u	,cNRTR)}	,oGrp2,050,008,'@!'	,,CLR_GRAY,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNRTR",,)

oSTkn := tSay():New(211,420,{|| cNrToken },oGrp2,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)

oBtnLgi := tButton():New( 208,375,"Testa Login"	,oPanel1,{|| ( aRet:=U_fLgInJson(), iIf(aRet[01], (cTkn:=aRet[03],cNrToken:="Token: "+aRet[03]), (cTkn:= "",cNrToken:="Token: ") ), oSTkn:Refresh() )}	,040,012,,,,.T.,,"",,,,.F.) 
oBtnLgo := tButton():New( 208,600,"Testa Logout",oPanel1,{|| (U_fLgOuJson(cTkn),cTkn:="",cNrToken:="Token: ",oSTkn:Refresh())}	,040,012,,,,.T.,,"",,,,.F.) 

oBtnPSq := tButton():New( 223,375,"Pesquisar"	,oPanel1,{||( fGrGrid(),fMntTree()) },040,012,,,,.T.,,"",,,,.F.) 
oBtnVis := tButton():New( 223,420,"Visualizar"	,oPanel1,{||fVisual(aTransa[oBrw:nAt,10])}	,040,012,,,,.T.,,"",,,,.F.) 
oBtnLog := tButton():New( 223,465,"Exporta Log"	,oPanel1,{||EECVIEW( cLog )}	,040,012,,,,.T.,,"",,,,.F.) 
oBtnCfg := tButton():New( 223,510,"Parametros"	,oPanel1,{||fCfgParam()}	,040,012,,,,.T.,,"",,,,.F.) 
oBtnLeg := tButton():New( 223,555,"Legenda"		,oPanel1,{||ZA1LEG()}		,040,012,,,,.T.,,"",,,,.F.) 
oBtnSai := tButton():New( 223,600,"Sair"		,oPanel1,{||oDlg:End()}		,040,012,,,,.T.,,"",,,,.F.) 

fGrGrid() // gera a Base para alimentar a Treeview  
fMntTree() // Monta a Tree View

oDlg:Activate(,,,.T.,{||lSair})

RestArea(aArea)

Return                                             

//----------------------------------------------------------------------------
/*/{Protheus.doc} fGrGrid
Gera o Grid de transação    
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/     
Static Function fGrGrid  
Local nId:=Len(aPastaC)+len(aPastaP)+1

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

cQry :=	" SELECT ZA1_STATUS, ZA1_NRTRAN, ZA1_TIPOTR, ZA1_TPMOV, ZA1_ORIGEM, ZA1_DATATR, ZA1_HORATR, ZA1_USERTR, "
cQry += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047),ZA1_JSON)),'') 'ZA1_JSON', ZA1.R_E_C_N_O_ "
cQry += " FROM " + RetSqlName("ZA1") + " ZA1 "
cQry +=	" WHERE " 
cQry +=	" ZA1_FILIAL='" + xFilial("ZA1") +"' AND "
If !empty(dDatIni)
	cQry += " ZA1_DATATR >= '" + dtos(dDatIni) +" ' AND "
Endif  
If !empty(dDatFim)
	cQry += " ZA1_DATATR <= '" + dtos(dDatFim) +" ' AND "
Endif                                     
cQry +=	" ZA1_TIPOTR<>' ' AND  "
cQry +=	" D_E_L_E_T_=' ' "
cQry +=	" ORDER BY ZA1_DATATR,ZA1_HORATR,ZA1_NRTRAN " 
		

TcQuery cQry New Alias (cAlias)
TCSetField((cAlias),"ZA1_DATATR","D",8,0)         

(cAlias)->(DbGoTop())
While ! (cAlias)->(Eof())

	aAdd( aIDTrans , {	strzero(nId,03),;			//01
						(cAlias)->ZA1_DATATR,;		//02
						(cAlias)->ZA1_HORATR,;		//03
						(cAlias)->ZA1_NRTRAN,;		//04
						(cAlias)->ZA1_STATUS,;		//05						
						(cAlias)->ZA1_TIPOTR,;		//06
						(cAlias)->ZA1_USERTR,;		//07
						(cAlias)->ZA1_ORIGEM,;		//08
						(cAlias)->ZA1_TPMOV,;		//09
						(cAlias)->ZA1_JSON,;		//10
						(cAlias)->R_E_C_N_O_} )		//11  
								
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
@version 12.1.27
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function fMntTree 
Local nX

If ! oTree:isEmpty()
	oTree:Reset()
Endif

aData:= {}
oTree:BeginUpdate()

// Insere itens
cTexto:= "Transacoes Recebidas - CYBERLOG " + space(70)
oTree:AddItem( cTexto, aPastaC[01,02], "FOLDER5" ,"FOLDER6",,,1)
  
if oTree:treeSeek(aPastaC[01,02])

	For nX:=2 to len(aPastaC)
		cTexto:= aPastaC[nX,01]+ space(100)
		oTree:AddItem( cTexto, aPastaC[nX,02], "FOLDER5" ,"FOLDER6",,,2)
	Next
	
Endif

cTexto:= "Transações Enviadas - Protheus" + space(069)
oTree:AddItem( cTexto	, aPastaP[01,02], "FOLDER5" ,"FOLDER6",,,1)
  
If oTree:TreeSeek( aPastaP[01,02] ) 

	For nX:=2 to len(aPastaP)
		cTexto:= aPastaP[nX,01]+ space(100)
		oTree:AddItem( cTexto	, aPastaP[nX,02], "FOLDER5" ,"FOLDER6",,,2)
	Next
	
endif  

For nX:=1 to len(aIDTrans) 

	cImg	:= If(aIDTrans[nX,05] == "1", "PMSDOC","EXCLUIR")
	cTexto	:= iIf(upper(aIDTrans[nX,06])=="R","C","P")+aIDTrans[nX,04] + " - " + aIDTrans[nX,06] + " - " + aIDTrans[nX,07] 
	cId		:= aIDTrans[nX,01]
	
	If upper( aIDTrans[nX,06] ) == "R"
	
		nPos := aScan( aPastaC, { |x| x[1] == "CYBERLOG" } ) 													//Procura a Pasta CYBERLOG
		If oTree:TreeSeek( aPastaC[nPos,02] )                  
		
			nPos := aScan( aPastaC, { |x| x[3] == aIDTrans[nX,09] } ) 											//Procura a Pasta do Movimento
			If oTree:TreeSeek( aPastaC[nPos,02] ) 																//Posiciona na Pasta do Movimento 
		
				nPos := aScan( aData, { |x| x[1] == dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"C" } ) 				//Verifica se ja existe a Data no DbTree
				If nPos <= 0
					aAdd(aData, {dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"C", cId} )								//Adiciona a Data
					oTree:AddItem( dtoc(aIDTrans[nX,02]) , cId, "FOLDER5" ,"FOLDER6",,,3) 						//Adiciona a Data no TreeView
					If oTree:TreeSeek(cId)																		//Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 													//Adiciona o Texto
						oTree:PtCollApSe()
					Endif
				Else                                                           
					If oTree:TreeSeek( aData[nPos,02] ) 														//Encontrou a Data e Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 													//Adiciona o texto
						oTree:PtCollApSe()
					Endif
				Endif
				
				oTree:PtCollApSe()
     		Endif
     		
     		oTree:PtCollApSe()
		Endif
		
		oTree:PtCollApSe()
	Endif
									
	If upper(aIDTrans[nX,06]) == "E"

		nPos := aScan( aPastaP, { |x| x[1] == "Protheus" } ) 													//Procura a Pasta Protheus
		If oTree:TreeSeek( aPastaP[nPos,02] )

			nPos := aScan( aPastaP, { |x| x[3] == aIDTrans[nX,09] } ) 											//Procura a Pasta do Movimento
			If oTree:TreeSeek( aPastaP[nPos,02] ) 																//Posiciona na Pasta do Movimento 

				nPos := aScan( aData, { |x| x[1] == dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"P" } ) 				//Verifica se ja existe a Data no DbTree
				If nPos <= 0
					aAdd(aData, {dtos(aIDTrans[nX,02])+aIDTrans[nX,09]+"P", cId} )								//Adiciona a Data
					oTree:AddItem( dtoc(aIDTrans[nX,02]) , cId, "FOLDER5" ,"FOLDER6",,,3) 						//Adiciona a Data no TreeView
					If oTree:TreeSeek( cId )																	//Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 													//Adiciona o Texto
						oTree:PtCollApSe()
					Endif
				Else                                                           
					If oTree:TreeSeek( aData[nPos,02] )															//Encontrou a Data e Posiciona na Pasta
						oTree:AddItem( cTexto, cId, cImg,,,,4) 													//Adiciona o texto
						oTree:PtCollApSe()
					Endif
				Endif
				
				oTree:PtCollApSe()
			Endif
			
			oTree:PtCollApSe()
		Endif
		
		oTree:PtCollApSe()
    Endif
			
Next

For nX:= len(aPastaC) to 1 step -1
	oTree:TreeSeek(aPastaC[nX,02])
	oTree:PtCollApSe()
Next

For nX:= len(aPastaP) to 1 step -1
	oTree:TreeSeek(aPastaP[nX,02])
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
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function fGrHist(pLinha)
Local nX:= 0     

aTransa:= {} 

If substr(pLinha,1,1)  $ "C|P" 

	For nX:=1 to len(aIDTrans)                   

		If alltrim(aIDTrans[nX,04]) == alltrim(Substr(pLinha,02,09))
			aAdd( aTransa , {	iIf(aIDTrans[nX,05]=="1",oLed1,oLed2),; //Status
								aIDTrans[nX,02],; //Data
								aIDTrans[nX,03],; //Hora
								aIDTrans[nX,04],; //Nr. Transação
								Iif(alltrim(aIDTrans[nX,06])=="R","Recebimento","Envio"),; //Tipo da Transação
								aIDTrans[nX,07],; //Usuario da Transação  
								aIDTrans[nX,08],; //Origem da Transação
								aIDTrans[nX,09],; //Tipo Movimento 
								aIDTrans[nX,10],;  //Log JSon 
								aIDTrans[nX,11]}) //Recno
		Endif
	
	Next
Endif
	
If Len(aTransa) == 0 
	aTransa	:= {{"",ctod("//"),"::","","","","","","",0}}
Endif  

oBrw:SetArray( aTransa ) 
oBrw:Refresh()
oBrw:nAt:= 1

cLog:= aTransa[oBrw:nAt,09] 
oGLog:Refresh()

Return
                                         
//----------------------------------------------------------------------------
/*/{Protheus.doc} ZA1Leg
Legenda do MBrowse
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function ZA1Leg()
Local cCadastro:= "Controle de Transacao"

Local aLegenda := {	{"BR_VERDE"		, "Enviado / Recebido com Sucesso"	},;
					{"BR_VERMELHO"	, "Enviado / Recebido com Erro"	}}             

BrwLegenda(cCadastro,"Legendas",aLegenda) 

Return .T.           

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fVisual
Visualiza a Transação
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function fVisual(pRecno)
Local aZA1:= GetArea()
Local nOpca:= 0

If pRecno > 0
	DbSelectArea("ZA1")
	ZA1->(DbSetOrder(1))
	ZA1->(DbGoto(pRecno))
	
	nOpca := AxVisual("ZA1",ZA1->(Recno()),2)  
	
Endif

RestArea(aZA1)            

Return
//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Verifica o Grupo de PErguntas na Tabela SX1
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 04/12/2020
/*/
Static Function AjustaSX1()

CheckSX1(cPerg, "01", "Data De?"	, "Data De?"	, "Data De?"	, "mv_ch1"		, "D", 08, 0, 0, "G", "", ""	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Data Ate?"	, "Data Ate?"	, "Data Ate?"	, "mv_ch2"		, "D", 08, 0, 0, "G", "", ""	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return


/*/{Protheus.doc} fCfgParam
	Edita o Parametro FZ_WSWMS
	@type function
	@author Carlos Cleuber Pereira	
	@since 09/12/2020
	@version 1.0
/*/
Static Function fCfgParam
Local aArea	:= GetArea()
Local aSX6:= SX6->(GetArea())
Local oDlg
Local aParamCT	:= {}
Local lGrava	:= .F.
Local nX

/*01*/aAdd( aParamCT , { GetMv("FZ_WSWMS1")	, "[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		, .F. , 30 })
/*02*/aAdd( aParamCT , { GetMv("FZ_WSWMS2")	, "[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		, .F. , 30 })
/*03*/aAdd( aParamCT , { GetMv("FZ_WSWMS3")	, "[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		, .F. , 30 })
/*04*/aAdd( aParamCT , { GetMv("FZ_WSWMS4")	, "[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		, .F. , 30 })
/*05*/aAdd( aParamCT , { GetMv("FZ_WSWMS5")	, "[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		, .F. , 30 })
/*06*/aAdd( aParamCT , { GetMv("FZ_WSWMS6")	, "[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	, .F. , 30 })
/*07*/aAdd( aParamCT , { GetMv("FZ_WSWMS7")	, "[FZ_WSWMS7] - Código do Layout de Integração do WS CyberLog WMS - [Manutencao Lotes]"		, .F. , 30 })
/*08*/aAdd( aParamCT , { GetMv("FZ_WSWMS8")	, "[FZ_WSWMS8] - Código do Layout de Integração do WS CyberLog WMS - [Movimentos Internos]"		, .F. , 30 })
/*08*/aAdd( aParamCT , { GetMv("FZ_WSWMS9")	, "[FZ_WSWMS9] - Código do Layout de Integração do WS CyberLog WMS - [Transferencias]"			, .F. , 30 })

DEFINE MSDIALOG oDlg TITLE "Parametros Configuração WS CyberLog WMS" FROM 0,0 TO 345,655 OF oMainWnd Pixel

For nX:= 1 to len(aParamCT)
	SetPrvt("cCT_PAR"+AllTrim(STRZERO(nx,2,0)))
	&("cCT_PAR"+AllTrim(STRZERO(nx,2,0))) := padr(aParamCT[nX,01],aParamCT[nX,04])
Next nX

oS01:= TSay():New( 013,010 ,{|| aParamCT[01,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS02:= TSay():New( 028,010 ,{|| aParamCT[02,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS03:= TSay():New( 043,010 ,{|| aParamCT[03,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS04:= TSay():New( 058,010 ,{|| aParamCT[04,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS05:= TSay():New( 073,010 ,{|| aParamCT[05,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS06:= TSay():New( 088,010 ,{|| aParamCT[06,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS07:= TSay():New( 103,010 ,{|| aParamCT[07,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS08:= TSay():New( 118,010 ,{|| aParamCT[08,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)
oS09:= TSay():New( 133,010 ,{|| aParamCT[09,02] }, oDlg ,,,,,,.T.,CLR_BLACK,,250,,,,,,)

oG01:= TGet():New( 010,265,{ | u | If( PCount() == 0, cCT_PAR01, cCT_PAR01:= u ) },oDlg,aParamCT[01,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[01,03],.F.,"ZA2WMS","cCT_PAR01",,)
oG02:= TGet():New( 025,265,{ | u | If( PCount() == 0, cCT_PAR02, cCT_PAR02:= u ) },oDlg,aParamCT[02,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[02,03],.F.,"ZA2WMS","cCT_PAR02",,)
oG03:= TGet():New( 040,265,{ | u | If( PCount() == 0, cCT_PAR03, cCT_PAR03:= u ) },oDlg,aParamCT[03,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[03,03],.F.,"ZA2WMS","cCT_PAR03",,)
oG04:= TGet():New( 055,265,{ | u | If( PCount() == 0, cCT_PAR04, cCT_PAR04:= u ) },oDlg,aParamCT[04,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[04,03],.F.,"ZA2WMS","cCT_PAR04",,)
oG05:= TGet():New( 070,265,{ | u | If( PCount() == 0, cCT_PAR05, cCT_PAR05:= u ) },oDlg,aParamCT[05,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[05,03],.F.,"ZA2WMS","cCT_PAR05",,)
oG06:= TGet():New( 085,265,{ | u | If( PCount() == 0, cCT_PAR06, cCT_PAR06:= u ) },oDlg,aParamCT[06,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[06,03],.F.,"ZA2WMS","cCT_PAR06",,)
oG07:= TGet():New( 100,265,{ | u | If( PCount() == 0, cCT_PAR07, cCT_PAR07:= u ) },oDlg,aParamCT[07,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[07,03],.F.,"ZA2WMS","cCT_PAR07",,)
oG08:= TGet():New( 115,265,{ | u | If( PCount() == 0, cCT_PAR08, cCT_PAR08:= u ) },oDlg,aParamCT[08,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[08,03],.F.,"ZA2WMS","cCT_PAR08",,)
oG09:= TGet():New( 130,265,{ | u | If( PCount() == 0, cCT_PAR09, cCT_PAR09:= u ) },oDlg,aParamCT[09,04],010,'@!',{||Vazio() .OR. ExistCpo("ZA2")},,,,,,.T.,"",,,.F.,.F.,,aParamCT[09,03],.F.,"ZA2WMS","cCT_PAR09",,)

oBtn1:= tButton():New(155,100,"Cancelar", oDlg	, {|| oDlg:end() }					,050,010,,,,.T.,,"",,,,.F.)
oBtn2:= tButton():New(155,165,"Gravar"	, oDlg	, {|| (lGrava:= .T.,oDlg:end()) }	,050,010,,,,.T.,,"",,,,.F.)

ACTIVATE MSDIALOG oDlg CENTERED

If lGrava

	SX6->(DbSetOrder(1))
	RecLock("SX6")

	PutMV("FZ_WSWMS1"	, cCT_PAR01 )
	PutMV("FZ_WSWMS2"	, cCT_PAR02 )
	PutMV("FZ_WSWMS3"	, cCT_PAR03 )
	PutMV("FZ_WSWMS4"	, cCT_PAR04 )
	PutMV("FZ_WSWMS5"	, cCT_PAR05 )
	PutMV("FZ_WSWMS6"	, cCT_PAR06 )
	PutMV("FZ_WSWMS7"	, cCT_PAR07 )
	PutMV("FZ_WSWMS8"	, cCT_PAR08 )
	PutMV("FZ_WSWMS9"	, cCT_PAR09 )
	
	SX6->(MsUnLock())

Endif

RestArea(aSX6)
RestArea(aArea)

Return
