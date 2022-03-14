#Include 'Protheus.ch'
#include "topconn.CH"
#include "tbiconn.ch"
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata010 - Cadastro de Produtos
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA010MNU
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MTA140MNU

	AAdd( aRotina, { "CyberLog - Painel Integração"		, "U_fPnlWMSNF()"		, 0 , 2, 0, NIL})

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonNF
Rotina para mostrar o Json do Produto
@version 12.1.27
@type function
@author Carlos CLeuber
@since 01/02/2021
/*/
Static Function fVJsonNF
Local aArea:= GetArea()
Local aSD1:= SD1->(GetArea())
Local cJson:= ''

If aItens[oItens:nAt,01]

	DbSelectArea("SD1")
	SD1->(DbGoto(aItens[oItens:nAt,10]))
	cJson:= U_fGrJson( GetMv('FZ_WSWMS6'), 'SD1', 1, 'D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM', FWxFilial('SD1')+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) ) 

	EECVIEW( cJson )

Endif

RestArea(aSD1)
RestArea(aArea)
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPnlWMSNF
Painel Integração CyberLog WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 01/02/2021
/*/
User Function fPnlWMSNF()

Local aArea:= GetArea()
Local oGroup1, oGroup2,  oBEnv
Local oFontCab := TFont():New( "Arial",, 15,,.F.,,,, .F., .F. )  

Local  cPerg	:= PadR('WMSEXPSD1',10)

Private oDlg
Private aItens  := {}
Private oItens
Private oObs, oDescri
Private cObs		:= ""
Private cDescri		:= ""
Private lCheck		:= .F.	

Private oOK	:= LoadBitmap(GetResources(), "LBOK" )
Private oNO	:= LoadBitmap(GetResources(), "LBNO" )

Private oLeg
Private oLgBranco	:= LoadBitmap(GetResources(),'BR_BRANCO')	//D1_XSTAWMS==' ' - Não Enviado
Private oLgAzul		:= LoadBitmap(GetResources(),'BR_AZUL')		//D1_XSTAWMS=='E' - Enviado
Private oLgVermel	:= LoadBitmap(GetResources(),'BR_VERMELHO')	//D1_XSTAWMS=='F' - Falha no Envio
Private oLgPreto	:= LoadBitmap(GetResources(),'BR_PRETO')	//D1_XSTAWMS=='X' - Falha no Retorno
Private oLgVerde	:= LoadBitmap(GetResources(),'BR_VERDE')	//D1_XSTAWMS=='O' - Retorno com Sucesso
Private oLgCancel	:= LoadBitmap(GetResources(),'BR_CANCEL')	//D1_XSTAWMS=='C' - Retorno com Sucesso
Private oLgReenV	:= LoadBitmap(GetResources(),'BR_AZUL_CLARO')	//D1_XSTAWMS=='R' - Retorno com Sucesso

fSX1SD1(cPerg)
If ! Pergunte(cPerg,.T.)
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Painel Integração CyberLog X Protheus" FROM 000, 000 TO 680, 775 PIXEL
	   
oItens := TcBrowse():New( 015, 010, 370, 180,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,,, )
		
oItens:SetArray( aItens )

oItens:AddColumn( TcColumn():New( ""			, { || If(aItens[oItens:nAt,01], oOK,oNO) 	}, 	 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )		
oItens:AddColumn( TcColumn():New( "Status"		, { || aItens[oItens:nAt,02]				},"" 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Nota Fiscal"	, { || aItens[oItens:nAt,03]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Item"		, { || aItens[oItens:nAt,04]				}, "@!"				,,, "LEFT"  , 020, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Produto"		, { || aItens[oItens:nAt,05]				}, "@!"				,,, "LEFT"  , 100, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Qtd"			, { || aItens[oItens:nAt,06]				}, "@E 999,999.99"	,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Fornecedor"	, { || aItens[oItens:nAt,08]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:nAt := 1

oItens:bLDblClick:= {|| fMarca() }
oItens:bChange := { || ( cObs:= aItens[oItens:nAt,09], oObs:refresh())  }	

@ 005, 005 GROUP oGroup1 TO 220, 385 PROMPT "[ Itens ]" OF oDlg COLOR 128, 16777215 PIXEL

@ 220, 005 GROUP oGroup2 TO 325, 385 PROMPT "[ Mensagem Integração ]" OF oDlg COLOR 128, 16777215 PIXEL
@ 230, 010 GET oObs VAR cObs OF oDlg MULTILINE READONLY SIZE 370, 090 COLORS 0, 16777215 HSCROLL PIXEL

//oBLeg	:= tButton():New(202,010  ,"Legenda"		,oDlg,{ || fLegenda()}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBLeg	:= tButton():New(202,010  ,"Vld JSon"		,oDlg,{ || fVJsonNF()}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBRee	:= tButton():New(202,090  ,"Filtro"			,oDlg,{ || iIf(Pergunte(cPerg,.T.), fQrySD1(),.F.)}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBEnv	:= tButton():New(202,170  ,"Enviar WMS"		,oDlg,{ || processa( {|| fExpItSD1("E") }, 'Aguarde', 'Enviando Item WMS...' )}	,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBCan	:= tButton():New(202,250  ,"Cancelar  WMS"	,oDlg,{ || processa( {|| fExpItSD1("C") }, 'Aguarde', 'Cancelando Item WMS...' )}		,070,012,,oFontCab,,.T.,,"",,,,.F.)

oCheck  := TCheckBox():New( 205,330,"Marcar Todos",{|u| If(PCount()>0,lCheck:=u,lCheck)},oDlg,100,008,,{|| fMTodos() },,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

//DEFINE SBUTTON oSButton1 FROM 325, 360 TYPE 20 OF oDlg ENABLE ACTION oDlg:End()

fQrySD1()

oTimer := TTimer():New(2000*60 , {|| fQrySD1() }, oDlg )
oTimer:Activate()

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return	

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Carrega o array de itens
Static Function fQrySD1()
Local aArea:= GetArea()
Local cNome	:= ""
Local cQry	:= ""
Local cAlias:= ""

aItens  := {}

cQry:= " SELECT D1_DTDIGIT, D1_FORNECE,D1_LOJA,D1_DOC,D1_ITEM,D1_COD,B1_DESC,D1_QUANT,D1_XSTAWMS, D1_TIPO,"
cQry += " ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047), SD1.D1_XMSGWMS)),'') MSGINT, SD1.R_E_C_N_O_ 
cQry +=	" FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) " 
cQry +=	" INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON SB1.B1_FILIAL='" + xFilial("SB1") + "' AND SB1.B1_COD=SD1.D1_COD AND SB1.D_E_L_E_T_ = '' " 
cQry +=	" WHERE " 
cQry +=	" SD1.D1_FILIAL = '" + xFilial("SD1") + "' " 
If !Empty(MV_PAR01)
	cQry += " AND SD1.D1_EMISSAO >= '"+ dtos(MV_PAR01) + "' "
Endif
If !Empty(MV_PAR02)
	cQry += " AND SD1.D1_EMISSAO <= '"+ dtos(MV_PAR02) + "' "
Endif
If !Empty(MV_PAR03)
	cQry += " AND SD1.D1_DTDIGIT >= '"+ dtos(MV_PAR03) + "' "
Endif
If !Empty(MV_PAR04)
	cQry += " AND SD1.D1_DTDIGIT <= '"+ dtos(MV_PAR04) + "' "
Endif
If !Empty(MV_PAR05)
	cQry += " AND SD1.D1_FORNECE >= '"+ MV_PAR05 + "' "
Endif
If !Empty(MV_PAR06)
	cQry += " AND SD1.D1_FORNECE <= '"+ MV_PAR06 + "' "
Endif
If !Empty(MV_PAR07)
	cQry += " AND SD1.D1_DOC >= '"+ MV_PAR07 + "' "
Endif
If !Empty(MV_PAR08)
	cQry += " AND SD1.D1_DOC <= '"+ MV_PAR08 + "' "
Endif
If !Empty(MV_PAR09)
	cQry += " AND SD1.D1_DOC >= '"+ MV_PAR09 + "' "
Endif
If !Empty(MV_PAR10)
	cQry += " AND SD1.D1_COD <= '"+ MV_PAR10 + "' "
Endif

If MV_PAR11 == 2
	cQry+= " AND SD1.D1_XSTAWMS=' '" //Nao enviado
ElseIf MV_PAR11 == 3
	cQry+= " AND SD1.D1_XSTAWMS='E'" //Enviado
ElseIf MV_PAR11 == 4
	cQry+= " AND V.D1_XSTAWMS='F'" //Falha no Envio
ElseIf MV_PAR11 == 5
	cQry+= " AND SD1.D1_XSTAWMS='X'" //Falha no retorno
Endif
cQry +=	" AND SD1.D_E_L_E_T_='' " 
cQry += " AND SD1.D1_TIPO IN ('N','D')  "
cQry +=	" ORDER BY SD1.D1_DOC, SD1.D1_ITEM " 
	
cAlias := GetNextAlias()	
   
If Select( cAlias ) <> 0
  (cAlias)->( dbCloseArea() )
EndIf			
	
TcQuery cQry New Alias (cAlias)
		
(cAlias)->( dbGoTop() )

While ! (cAlias)->( EOF() )

	If (cAlias)->D1_TIPO == "N"
		cNome:= GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA,1) 
	Else
		cNome:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+(cAlias)->D1_FORNECE+(cAlias)->D1_FORNECE,1) 
	EndIf
	If Empty((cAlias)->D1_XSTAWMS)
		oLeg:= oLgBranco
	ElseIf (cAlias)->D1_XSTAWMS=='E'
		oLeg:= oLgAzul
	ElseIf (cAlias)->D1_XSTAWMS=='F'
			oLeg:= oLgVermel
	ElseIf (cAlias)->D1_XSTAWMS=='X'
			oLeg:= oLgPreto
	ElseIf (cAlias)->D1_XSTAWMS=='O'
			oLeg:= oLgVerde
	ElseIf (cAlias)->D1_XSTAWMS=='C'
			oLeg:= oLgCancel
	ElseIf (cAlias)->D1_XSTAWMS=='R'
			oLeg:= oLgReenv		
	Endif
		
	aAdd( aItens, {	.F.,;
					oLeg,;
					(cAlias)->D1_DOC,;
        	        (cAlias)->D1_ITEM,;
					(cAlias)->D1_COD+"-"+(cAlias)->B1_DESC,;
					(cAlias)->D1_QUANT,;
			        (cAlias)->D1_XSTAWMS,;
			        (cAlias)->D1_FORNECE+"/"+(cAlias)->D1_LOJA +"-"+cNome,;
					(cAlias)->MSGINT,;
					(cAlias)->R_E_C_N_O_} )
		            
	(cAlias)->( DbSkip() )
	
End

(cAlias)->( DbCloseArea() )

If Empty(aItens)
	aItens:= {{	.F.,"","","","","",0,"","",0}}
Else
Endif

fAtuBrw()

RestArea(aArea)

Return

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Atualiza o browse de itens

Static Function fAtuBrw()

oItens:SetArray(aItens)
oItens:nAt := 1
oItens:refresh()
oItens:setfocus()

oObs:refresh()
cObs:= aItens[oItens:nAt,09]

Return

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Atualiza o browse de itens

Static Function fMarca()

//' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorerto 
If Empty(aItens[oItens:nAt,07]) .or. alltrim(aItens[oItens:nAt,07]) == 'F'
	aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]

ElseIf alltrim(aItens[oItens:nAt,07]) $ ' |E|F|C|R'

	If alltrim(aItens[oItens:nAt,07]) == 'E'
		If MsgYesNo("Esse item da Nota ja foi enviado ao WMS. Confirma o reenvio do Item ?")
			aItens[oItens:nAt,01]:= .T.
		Else
			aItens[oItens:nAt,01]:= .F.
		Endif
	Else
		aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]
	Endif

Else
	If alltrim(aItens[oItens:nAt,07]) $ 'O|X' 
		Alert('Item do Pedido já foi enviado ao WMS.')
	Endif 
	aItens[oItens:nAt,01]:= .F.
Endif

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo
@version 12.1.27
@type function
@author Carlos CLeuber
@since 01/01/2021
/*/
//--------------------------------------------------------------------
Static Function fMTodos
Local  nI := 0

For nI := 1 To Len( aItens )

	If Empty(aItens[oItens:nAt,07]) .or. alltrim(aItens[oItens:nAt,07]) == 'F'
		aItens[oItens:nAt,01]:= !aItens[oItens:nAt,01]
	Else
		aItens[oItens:nAt,01]:= .F.	
	Endif	
	
Next nI

oItens:Refresh()

Return NIL

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fExpItem
Função para exportar o Items do Pedido
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
Static Function fExpItSD1(pAcao)
Local aSD1		:= GetArea()
Local aRet		:= array(3)
Local lIntegra	:= ''
Local cMsgPnl	:= ''
Local cRet 		:= ''
Local nX

Private cOpera	:= pAcao //Variavel do Tipo Private que sera usada no Layout do Envio do Pedido na Tabla ZA3, para definir se é uma inclusao ou exclusao

For nX:=1 to len(aItens)

	If aItens[nX,01]

		DbSelectArea("SD1")
		SD1->(DbGoto(aItens[nX,10]))

		cMsgPnl:= SD1->D1_XMSGWMS + CRLF
		cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
		cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

		lIntegra:= GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SD1->D1_COD,1) == "S"

		If Empty(cRet) .and. !lIntegra
			cRet:= 'Produto não esta configurado para fazer integração com WMS Cyberlog.' + CRLF
		Endif

		If Empty(cRet) .and. cOpera=="C" .and. SD1->D1_XSTAWMS != "E"
			cRet:= 'Item do Pedido não não pode ser cancelado. Item não foi enviado ou com status de retorno do WMS.' + CRLF
		Endif

		If Empty(cRet)
			aRet:= U_fConJson( GetMv('FZ_WSWMS6'), 'SD1', 1, 'D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM', FWxFilial('SD1')+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) ) 
		Else
			aRet[1]:= .F.
			aRet[3]:= cRet
		Endif

		RecLock("SD1",.F.)
		If cOpera !="C"
			If Empty(SD1->D1_XSTAWMS) .or. SD1->D1_XSTAWMS=="F"
				SD1->D1_XSTAWMS:= iIf(aRet[1],"E","F") //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
			Endif
		Else
			If aRet[1]
				SD1->D1_XSTAWMS:= "C" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
			Endif
		Endif
		SD1->D1_XDTIWMS:= dDataBase
		SD1->D1_ZHRIWMS:= Time()
		SD1->D1_XMSGWMS:= cMsgPnl+aRet[3]		
		SD1->(MsUnlock())
	Endif

Next nX

fQrySD1()

RestArea(aSD1)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLegenda
Legenda Painel Integracao WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 01/01/2021
/*/
Static Function fLegenda()

Local	aLegenda  := {	{'BR_BRANCO'	,'Item não Integrado ao WMS'}		,;
						{'BR_AZUL'		,'Item enviado ao WMS'}				,;
						{'BR_AZUL_CLARO','Item Renviado ao WMS'}			,;
						{'BR_VERMELHO'	,'Item com falha no envio do WMS'}	,;
						{'BR_PRETO'		,'Item com falha no retorno do WMS'},;
						{'BR_VERDE'		,'Item com sucesso no retorno'}		,;
						{'BR_CANCEL'	,'Item cancelado'}}

BrwLegenda("Painel de Integração",'Legenda',aLegenda)

Return .T.


/*/{Protheus.doc} fSX1ExpNF
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 01/02/2021
/*/
Static Function fSX1SD1(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Dt Emissao De?"		, "Dt Emissao De?"		, "Dt Emissao De?"		, "mv_ch1"		, "D", TamSX3("D1_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Dt Emissao Ate?"		, "Dt Emissao Ate?"		, "Dt Emissao Ate?"		, "mv_ch2"		, "D", TamSX3("D1_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "03", "Dt Digitacao De?"	, "Dt Digitacao De?"	, "Dt Digitacao De?"	, "mv_ch3"		, "D", TamSX3("D1_DTDIGIT")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "04", "Dt Digitacao Ate?"	, "Dt Digitacao Ate?"	, "Dt Digitacao Ate?"	, "mv_ch4"		, "D", TamSX3("D1_DTDIGIT")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "05", "Fornecedor De?"		, "Fornecedor De?"		, "Fornecedor De?"		, "mv_ch5"		, "C", TamSX3("D1_FORNECE")[1]	, 0, 0, "G", "", "SA2"	,"","","MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "06", "Fornecedor Ate?"		, "Fornecedor Ate?"		, "Fornecedor Ate?"		, "mv_ch6"		, "C", TamSX3("D1_FORNECE")[1]	, 0, 0, "G", "", "SA2"	,"","","MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "07", "Nota Fiscal De?"		, "Nota Fiscal De?"		, "Nota Fiscal De?"		, "mv_ch7"		, "C", TamSX3("D1_DOC")[1]		, 0, 0, "G", "", "SD1"	,"","","MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "08", "Nota Fiscal Ate?"	, "Nota Fiscal Ate?"	, "Nota Fiscal Ate?"	, "mv_ch8"		, "C", TamSX3("D1_DOC")[1]		, 0, 0, "G", "", "SD1"	,"","","MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "09", "Produto De?"			, "Produto De?"			, "Produto De?"			, "mv_ch9"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "10", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"		, "mv_chA"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "11", "Status?"				, "Status?"				, "Status?"				, "mv_chB"		, "N", 01						, 0, 0, "C", "",""		,"","","MV_PAR11", "Todos", "", "", "", "Nao Integrado", "", "", "", "Enviado", "", "", "", "Falha no Envio", "", "", "", "Falha no retorno", "", "", "", "",{},{},{})

Return()

