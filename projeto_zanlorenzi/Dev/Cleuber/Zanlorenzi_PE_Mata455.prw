#Include 'Protheus.ch'
#include "topconn.CH"
#include "tbiconn.ch"
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata455 - Liberacao de Pedidos
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA455MNU
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 10/12/2020
@version 1.0
/*/
User Function MA455MNU

	Aadd( aRotina, { "CyberLog - Valida JSon WMS"		, "U_fVJsonPV()"	, 0 , 2,0 ,NIL} )
	AAdd( aRotina, { "CyberLog - Painel Integração"		, "U_fPnlWMS()"		, 0 , 2, 0, NIL})

	
Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA455E
Ponto de Entrada para Bloquear a Liberação Automatica 
@type function
@author Carlos CLeuber
@since 10/12/2020
@version 1.0
/*/
User Function MTA455E()  
Local nOpc:= 0        
    Alert("Rotina Bloqueada para uso!!!")          
    nOpc:= 2                 //  1= Libera    2=Mantêm o bloqueio 
Return(nOpc)

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA455P
Ponto de Entrada para Bloquear a Liberação Manual 
@type function
@author Carlos CLeuber
@since 10/12/2020
@version 1.0
/*/
User Function MTA455P()       
Local nOpc:= 0           
   Alert("Rotina Bloqueada para uso!!!")          
   nOpc:= 2                 //  1= Libera    2=Mantêm o bloqueio 
Return(nOpc)


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fExpItem
Função para exportar o Items do Pedido
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function fExpItem(pAcao)
Local aSC9		:= GetArea()
Local aRet		:= array(3)
Local lEDIOk	:= .T.
Local lIntegra	:= ''
Local cMsgPnl	:= ''
Local cRet 		:= ''
Local nX

Private cOpera	:= pAcao //Variavel do Tipo Private que sera usada no Layout do Envio do Pedido na Tabla ZA3, para definir se é uma inclusao ou exclusao

For nX:=1 to len(aItens)

	If aItens[nX,01]

		DbSelectArea("SC9")
		SC9->(DbGoto(aItens[nX,10]))

		cMsgPnl:= SC9->C9_XMSGWMS + CRLF
		cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
		cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

		lEDIOk	:= GetAdvFVal("ZA7","ZA7_STATUS",xFilial("ZA7")+SC9->C9_PEDIDO+SC9->C9_ITEM,3) == "7"
		lIntegra:= GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SC9->C9_PRODUTO,1) == "S"

		If Empty(cRet) .and. !lEDIOK
			cRet:= 'Item do Pedido não esta liberado pelo EDI Transportadora ou já foi processado. Favor verificar com a Logistica.' + CRLF
		Endif

		If Empty(cRet) .and. !lIntegra
			cRet:= 'Produto não esta configurado para fazer integração com WMS Cyberlog.' + CRLF
		Endif

		If Empty(cRet) .and. cOpera=="C" .and. SC9->C9_XSTAWMS != "E"
			cRet:= 'Item do Pedido não não pode ser cancelado. Item não foi enviado ou com status de retorno do WMS.' + CRLF
		Endif

		If Empty(cRet)
			aRet:= U_fConJson( GetMv('FZ_WSWMS5'), 'SC9', 1, 'C9_FILIAL+C9_PEDIDO+C9_ITEM', FWxFilial('SC9')+SC9->C9_PEDIDO+SC9->C9_ITEM ) 
		Else
			aRet[1]:= .F.
			aRet[3]:= cRet
		Endif

		RecLock("SC9",.F.)
		If cOpera !="C"
			If Empty(SC9->C9_XSTAWMS) .or. SC9->C9_XSTAWMS=="F"
				SC9->C9_XSTAWMS:= iIf(aRet[1],"E","F") //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
			Endif
		Else
			If aRet[1]
				SC9->C9_XSTAWMS:= "C" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
			Endif
		Endif
		SC9->C9_XDTIWMS:= dDataBase
		SC9->C9_XHRIWMS:= Time()
		SC9->C9_XMSGWMS:= cMsgPnl+aRet[3]		
		SC9->(MsUnlock())
	Endif

Next nX

fQryPed()

RestArea(aSC9)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonPV
Rtina para mostrar o Json do Pedido de Vendas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonPV
Local cJson:= U_fGrJson( GetMv('FZ_WSWMS5'), 'SC9', 1, 'C9_FILIAL+C9_PEDIDO', FWxFilial('SC9')+SC9->C9_PEDIDO )

EECVIEW( cJson )

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fPnlWMS
Painel Integração CyberLog WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
/*/
User Function fPnlWMS()

Local aArea:= GetArea()
Local oGroup1, oGroup2,  oBEnv
Local oFontCab := TFont():New( "Arial",, 15,,.F.,,,, .F., .F. )  
Local cPerg	:= PadR('WMSEXPSC9',10)

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
Private oLgBranco	:= LoadBitmap(GetResources(),'BR_BRANCO')	//C9_XSTAWMS==' ' - Não Enviado
Private oLgAzul		:= LoadBitmap(GetResources(),'BR_AZUL')		//C9_XSTAWMS=='E' - Enviado
Private oLgVermel	:= LoadBitmap(GetResources(),'BR_VERMELHO')	//C9_XSTAWMS=='F' - Falha no Envio
Private oLgPreto	:= LoadBitmap(GetResources(),'BR_PRETO')	//C9_XSTAWMS=='X' - Falha no Retorno
Private oLgVerde	:= LoadBitmap(GetResources(),'BR_VERDE')	//C9_XSTAWMS=='O' - Retorno com Sucesso
Private oLgCancel	:= LoadBitmap(GetResources(),'BR_CANCEL')	//C9_XSTAWMS=='C' - Retorno com Sucesso
Private oLgReenV	:= LoadBitmap(GetResources(),'BR_AZUL_CLARO')	//C9_XSTAWMS=='R' - Retorno com Sucesso

fSX1SC9(cPerg)
If ! Pergunte(cPerg,.T.)
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Painel Integração CyberLog X Protheus" FROM 000, 000 TO 680, 775 PIXEL
	   
oItens := TcBrowse():New( 015, 010, 370, 180,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,,, )
		
oItens:SetArray( aItens )

oItens:AddColumn( TcColumn():New( ""			, { || If(aItens[oItens:nAt,01], oOK,oNO) 	}, 	 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )		
oItens:AddColumn( TcColumn():New( "Status"		, { || aItens[oItens:nAt,02]				},"" 				,,, "CENTER", 010, .T., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Pedido"		, { || aItens[oItens:nAt,03]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Item"		, { || aItens[oItens:nAt,04]				}, "@!"				,,, "LEFT"  , 020, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Produto"		, { || aItens[oItens:nAt,05]				}, "@!"				,,, "LEFT"  , 100, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Qtd"			, { || aItens[oItens:nAt,06]				}, "@E 999,999.99"	,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:AddColumn( TcColumn():New( "Cliente"		, { || aItens[oItens:nAt,08]				}, "@!"				,,, "LEFT"  , 030, .F., .F.,,,, .F., ) )
oItens:nAt := 1

oItens:bLDblClick:= {|| fMarca() }
oItens:bChange := { || ( cObs:= aItens[oItens:nAt,09], oObs:refresh())  }	

@ 005, 005 GROUP oGroup1 TO 220, 385 PROMPT "[ Itens ]" OF oDlg COLOR 128, 16777215 PIXEL

@ 220, 005 GROUP oGroup2 TO 325, 385 PROMPT "[ Mensagem Integração ]" OF oDlg COLOR 128, 16777215 PIXEL
@ 230, 010 GET oObs VAR cObs OF oDlg MULTILINE READONLY SIZE 370, 090 COLORS 0, 16777215 HSCROLL PIXEL

oBLeg	:= tButton():New(202,010  ,"Legenda"		,oDlg,{ || fLegenda()}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBRee	:= tButton():New(202,090  ,"Filtro"			,oDlg,{ || iIf(Pergunte(cPerg,.T.), fQryPed(),.F.)}		,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBEnv	:= tButton():New(202,170  ,"Solicitar WMS"	,oDlg,{ || processa( {|| U_fExpItem("E") }, 'Aguarde', 'Enviando Reserva do Item...' )}	,070,012,,oFontCab,,.T.,,"",,,,.F.)
oBCan	:= tButton():New(202,250  ,"Cancelar  WMS"	,oDlg,{ || processa( {|| U_fExpItem("C") }, 'Aguarde', 'Cancelando Reserva do Item...' )}		,070,012,,oFontCab,,.T.,,"",,,,.F.)

oCheck  := TCheckBox():New( 205,330,"Marcar Todos",{|u| If(PCount()>0,lCheck:=u,lCheck)},oDlg,100,008,,{|| fMTodos() },,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

//DEFINE SBUTTON oSButton1 FROM 325, 360 TYPE 20 OF oDlg ENABLE ACTION oDlg:End()

fQryPed()

oTimer := TTimer():New(2000*60 , {|| fQryPed() }, oDlg )
oTimer:Activate()

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return	

//-----------------------------------------------------------------------------------------------------------------------------------------------
// Rotina : Carrega o array de itens
Static Function fQryPed()
Local aArea:= GetArea()
Local cNome	:= ""
Local cQry	:= ""
Local cAlias:= ""

aItens  := {}

cQry := " SELECT SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SB1.B1_DESC,SC9.C9_QTDLIB,SC9.C9_XSTAWMS,SC9.C9_XDTIWMS,SC9.C9_XHRIWMS, " 
cQry += " ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047), SC9.C9_XMSGWMS)),'') MSGINT, SC9.R_E_C_N_O_ ,SC5.C5_TIPO " 
cQry +=	" FROM " + RetSqlName("SC9") + " AS SC9 WITH (NOLOCK) " 
cQry +=	" INNER JOIN " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) ON SC5.C5_FILIAL='" + xFilial("SC5") + "' AND SC5.C5_NUM=SC9.C9_PEDIDO AND SC5.D_E_L_E_T_ = '' " 
If !Empty(MV_PAR01)
	cQry += " AND SC5.C5_EMISSAO >= '"+ dtos(MV_PAR01) + "' "
Endif
If !Empty(MV_PAR02)
	cQry += " AND SC5.C5_EMISSAO <= '"+ dtos(MV_PAR02) + "' "
Endif
cQry += " INNER JOIN " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) ON SC6.C6_FILIAL='" + xFilial("SC6") + "' AND SC6.C6_NUM=SC9.C9_PEDIDO AND SC6.C6_ITEM=SC9.C9_ITEM AND SC6.D_E_L_E_T_='' "
If !Empty(MV_PAR03)
	cQry += " AND SC6.C6_ENTREG >= '"+ dtos(MV_PAR03) + "' "
Endif
If !Empty(MV_PAR04)
	cQry += " AND SC6.C6_ENTREG <= '"+ dtos(MV_PAR04) + "' "
Endif

cQry +=	" INNER JOIN " + RetSqlName("ZA7") + " ZA7 WITH (NOLOCK) ON ZA7.ZA7_FILIAL='" + xFilial("ZA7") + "' AND ZA7.ZA7_PEDIDO=SC9.C9_PEDIDO AND ZA7.ZA7_ITEMPD=SC9.C9_ITEM AND " 
cQry +=	" ZA7.ZA7_STATUS='7' AND ZA7.D_E_L_E_T_ = '' " 
cQry +=	" INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON SB1.B1_FILIAL='" + xFilial("SB1") + "' AND SB1.B1_COD=SC9.C9_PRODUTO AND SB1.D_E_L_E_T_ = '' " 
cQry +=	" WHERE " 
cQry +=	" SC9.C9_FILIAL = '" + xFilial("SC9") + "' " 
If !Empty(MV_PAR05)
	cQry += " AND SC9.C9_PEDIDO >= '"+ MV_PAR05 + "' "
Endif
If !Empty(MV_PAR06)
	cQry += " AND SC9.C9_PEDIDO <= '"+ MV_PAR06 + "' "
Endif
If !Empty(MV_PAR07)
	cQry += " AND SC9.C9_PRODUTO >= '"+ MV_PAR07 + "' "
Endif
If !Empty(MV_PAR08)
	cQry += " AND SC9.C9_PRODUTO <= '"+ MV_PAR08 + "' "
Endif
cQry +=	" AND SC9.C9_NFISCAL = '' " 
cQry +=	" AND SC9.C9_BLEST <> '' " 
cQry +=	" AND SC9.D_E_L_E_T_='' " 
If MV_PAR09 == 2
	cQry+= " AND SC9.C9_XSTAWMS=' '" //Nao enviado
ElseIf MV_PAR09 == 3
	cQry+= " AND SC9.C9_XSTAWMS='E'" //Enviado
ElseIf MV_PAR09 == 4
	cQry+= " AND SC9.C9_XSTAWMS='F'" //Falha no Envio
ElseIf MV_PAR09 == 5
	cQry+= " AND SC9.C9_XSTAWMS='X'" //Falha no retorno
Endif
cQry +=	" ORDER BY SC9.C9_PEDIDO, SC9.C9_ITEM " 
	
cAlias := GetNextAlias()	
   
If Select( cAlias ) <> 0
  (cAlias)->( dbCloseArea() )
EndIf			
	
TcQuery cQry New Alias (cAlias)
		
(cAlias)->( dbGoTop() )

While ! (cAlias)->( EOF() )

	If (cAlias)->C5_TIPO $ "DB"
		cNome:= GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+(cAlias)->C9_CLIENTE+(cAlias)->C9_LOJA,1) 
	Else
		cNome:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+(cAlias)->C9_CLIENTE+(cAlias)->C9_LOJA,1) 
	EndIf
	If Empty((cAlias)->C9_XSTAWMS)
		oLeg:= oLgBranco
	ElseIf (cAlias)->C9_XSTAWMS=='E'
		oLeg:= oLgAzul
	ElseIf (cAlias)->C9_XSTAWMS=='F'
			oLeg:= oLgVermel
	ElseIf (cAlias)->C9_XSTAWMS=='X'
			oLeg:= oLgPreto
	ElseIf (cAlias)->C9_XSTAWMS=='O'
			oLeg:= oLgVerde
	ElseIf (cAlias)->C9_XSTAWMS=='C'
			oLeg:= oLgCancel
	ElseIf (cAlias)->C9_XSTAWMS=='R'
			oLeg:= oLgReenv		
	Endif
		
	aAdd( aItens, {	.F.,;
					oLeg,;
					(cAlias)->C9_PEDIDO,;
        	        (cAlias)->C9_ITEM,;
					(cAlias)->C9_PRODUTO+"-"+(cAlias)->B1_DESC,;
					(cAlias)->C9_QTDLIB,;
			        (cAlias)->C9_XSTAWMS,;
			        (cAlias)->C9_CLIENTE+"/"+(cAlias)->C9_LOJA +"-"+cNome,;
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
		If MsgYesNo("Esse item do pedido ja foi enviado ao WMS. Confirma o reenvio do Item ?")
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

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
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
/*/{Protheus.doc} fLegenda
Legenda Painel Integracao WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
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


/*/{Protheus.doc} fSX1ExpPro
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1SC9(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Dt Emissao De?"	, "Dt Emissao De?"		, "Dt Emissao De?"		, "mv_ch1"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Dt Emissao Ate?"	, "Dt Emissao Ate?"		, "Dt Emissao Ate?"		, "mv_ch2"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "03", "Dt Entrega De?"	, "Dt Entrega De?"		, "Dt Entrega De?"		, "mv_ch3"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "04", "Dt Entrega Ate?"	, "Dt Entrega Ate?"		, "Dt Entrega Ate?"		, "mv_ch4"		, "D", TamSX3("C5_EMISSAO")[1]	, 0, 0, "G", "", ""		,"","","MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "05", "Pedido De?"		, "Pedido De?"			, "Pedido De?"			, "mv_ch5"		, "C", TamSX3("C5_NUM")[1]		, 0, 0, "G", "", "SC5"	,"","","MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "06", "Pedido Ate?"		, "Pedido Ate?"			, "Pedido Ate?"			, "mv_ch6"		, "C", TamSX3("C5_NUM")[1]		, 0, 0, "G", "", "SC5"	,"","","MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "07", "Produto De?"		, "Produto De?"			, "Produto De?"			, "mv_ch7"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "08", "Produto Ate?"	, "Produto Ate?"		, "Produto Ate?"		, "mv_ch8"		, "C", TamSX3("B1_COD")[1]		, 0, 0, "G", "", "SB1"	,"","","MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "09", "Status?"			, "Status?"				, "Status?"				, "mv_ch9"		, "N", 01						, 0, 0, "C", "",""		,"","","MV_PAR09", "Todos", "", "", "", "Nao Integrado", "", "", "", "Enviado", "", "", "", "Falha no Envio", "", "", "", "Falha no retorno", "", "", "", "",{},{},{})

Return()

