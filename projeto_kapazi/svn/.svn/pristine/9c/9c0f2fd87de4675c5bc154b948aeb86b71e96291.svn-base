//Alterado Andre/Rsac -- Ajuste de lançamentos de DI DIN e DI CHQ -- 07/08/2016
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"
#Include "PROTHEUS.CH"
//05.07.2018
/*
@ programa para leitura de arquivo de
*/

User Function Afin001()

Local oDlg
Local oRelation
Local oFWLayer
Local nVai :=0
Local oPanelLeft
Local aCoors := MsAdvSize() //GetDialogSize(oMainWnd)
Local aLegenda  := {{ 'E5_RECPAG=="R" ', "BR_VERDE",    "RECEBER" },{ 'E5_RECPAG=="P"', "BR_VERMELHO", "PAGAR" }}

Private oMBrowseLeft
Private oMBrowseRight
Private oPanelRight
Private oPanelDIR
Private cBanco:=''
Private cAge:=''
Private cCont:=''
Private cMarca:=GetMark( )
Private dDt:=ctod('//')
Private nValconc:=0
Private nValINI:=0
Private oRelation1,oMBrowseLeft,oMBrowseRight ,oMBrowseDir
Private cMarca := GetMark()
private aStru		:= {}
Private lInv
Private nValorConc  := 0
Private nQtdTitConc := 0
Private nValorArq 	:= 0
Private nSaldoIni 	:= 0
Private nValorMov 	:= 0
Private nValDeb 		:= 0
Private nValCred 		:= 0

Private dDtaIni:=ctod('//')
Private cBcoIni:=""
Private cAgIni:=""
Private cCCini:=""
Private lValor:=.f.
Private oQtda
Private oValor
Private oMark
Private oValDeb
Private oValCred

Private oValorArq,oSaldoIni,oValorMov
Private aDtSaldo

Private cArqTrab
Private lIndice := .F.

DbSelectArea('SE5')
CTIPOTELA:=1
CSq:=" UPDATE "+RETSQLNAME('SE5')+" SET E5_SEL=''
CSq+=" WHERE E5_SEL<>'' "
CSq+=" AND D_E_L_E_T_<>'*'"
TCsQLeXEC(CSq)

CSq:=" UPDATE "+RETSQLNAME('SE1')+" SET E1_SEL=''
CSq+=" WHERE E1_SEL<>'' "
CSq+=" AND D_E_L_E_T_<>'*'"

TCsQLeXEC(CSq)
CSq:=" UPDATE "+RETSQLNAME('SE2')+" SET E2_SEL=''
CSq+=" WHERE E2_SEL<>'' "
CSq+=" AND D_E_L_E_T_<>'*'"

TCsQLeXEC(CSq)

aButtons:={}
CriaTemp1()
U_AFIN001A(.t.)

//TRBC->TIPO,TRBC->VALOR,TRBC->DATAC,TRBC->CATEGORIA,TRBC->BANCO,TRBC->Agencia,TRBC->Dva,TRBC->Conta,TRBC->Dvcon,TRBC->VALOR,TRBC->HIST
aCpoBro	:= {{ "OK"				,, ""         		,"@!"},;
			{ "TIPO"			,, "Tipo"         ,"@!"},;
			{ "VALOR"			,, "Valor"        ,"@E 999,999,999.99"},;
			{ "DATAC"			,, "Data"         ,"@!"},;
			{ "CATEGORIA"	,, "Categoria"    ,"@!"},;
			{ "BANCO"			,, "Banco"        ,"@!"},;
			{ "Agencia"		,, "Agencia"      ,"@!"},;
			{ "Dva"		    ,, "Dv.Ag"        ,"@!"},;
			{ "Conta"	    ,, "Conta"        ,"@!"},;
			{ "Dvcon"		  ,, "Dv.CC"        ,"@!"},;
			{ "HIST"		  ,, "Historico"    ,"@!"},;
			{ "IDENT"		  ,, "IdentIficao"    ,"@!"}} // Incluido para identIficação do movimento para geração de RA  -- Andre/Rsac -- 09.10.2017

aCpoe5	:= {{ "OK"				,, ""         		,"@!"},;
			{ "RECPAG"		,, "Tipo"         ,"@!"},;
			{ "VALOR"			,, "Valor"        ,"@E 999,999,999.99"},;
			{ "DATAC"			,, "Data"         ,"@!"},;
			{ "CATEGORIA"	,, "Categoria"    ,"@!"},;
			{ "BANCO"			,, "Banco"        ,"@!"},;
			{ "Agencia"		,, "Agencia"      ,"@!"},;
			{ "Dva"		    ,, "Dv.Ag"        ,"@!"},;
			{ "Conta"	    ,, "Conta"        ,"@!"},;
			{ "Dvcon"		  ,, "Dv.CC"        ,"@!"},;
			{ "HIST"		  ,, "Historico"    ,"@!"},;
			{ "IDENT"		  ,, "Historico3"    ,"@!"}}
//MONTATMPE5()
Aadd( aButtons, {"HISTORIC", {|| U_AFIN001A()}				, "Importar Extrato"	, "Importar Extrato"})
Aadd( aButtons, {"HISTORIC", {|| AbriBx()}					, "Baixa"				, "Baixas a Receber"})
Aadd( aButtons, {"HISTORIC", {|| AbrirMbx()}				, "Multiplas Baixas "	, "Multiplas Receber"})
Aadd( aButtons, {"HISTORIC", {|| Processa({||GeraRA()})}	, "Gerar RA "			, "Gerar RA"})
Aadd( aButtons, {"HISTORIC", {|| FAZTRANSF()}				, "Transf.Bancaria"		, "Transf.Bancaria"})
Aadd( aButtons, {"HISTORIC", {|| Processa({||GeraMt()})}	, "Mutuos "				, "Gerar Mutuos"})
Aadd( aButtons, {"HISTORIC", {|| Processa({||ProcConc()})}	, "Salvar Alteracoes "	, "Salvar Alteracoes"})
Aadd( aButtons, {"HISTORIC", {|| Processa({||PagCart()})}	, "Pagamento Cartoes "	, "Pagamento Cartoes"})

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 050, .t., .t. } )
AAdd( aObjects, { 100, 300, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
DEFINE MSDIALOG oDlg TITLE "Conciliacao Bancaria" FROM 000,000 TO aCoors[6],aCoors[5]  PIXEL

If CTIPOTELA == 1

		SETKEY(VK_F4,{||  TELAINFO()}) //F4 para gravar o historico

		@ 003 , 005 Say "Valor Credito"  PIXEL Of oDlg //"Valor Total:"
		@ 003 , 060 Say oValCred VAR nValCred Picture "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		@ 003 , 150 Say "Valor Debito:"  PIXEL Of oDlg //
		@ 003 , 200 Say oValDeb VAR nValDeb Picture "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		
		@ 010 , 005 Say "Valor Selecionado"  PIXEL Of oDlg //"Valor Total:"
		@ 010 , 060 Say oValor VAR nValorConc Picture "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		@ 010 , 150 Say "Quantidade:"  PIXEL Of oDlg //
		@ 010 , 200 Say oQtda VAR nQtdTitConc Picture "@E 99999" SIZE 50,8  PIXEL Of oDlg
		@ 010 , 240 Say "Sld Ini Arq.:"  PIXEL Of oDlg //nValorMov nSaldoIni
		@ 010 , 270 Say oSaldoIni VAR nSaldoIni Picture  "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		
		@ 010 , 320 Say "Movimentos:"  PIXEL Of oDlg //nValorMov nSaldoIni
		@ 010 , 350 Say oValorMov VAR nValorMov Picture  "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		@ 010 , 400 Say "Saldo Final.:"  PIXEL Of oDlg //nValorMov nSaldoIni
		@ 010 , 430 Say oValorArq VAR nValorArq Picture  "@E 999,999,999,999.99" SIZE 50,8  PIXEL Of oDlg
		//	0@ 005 , 500 BUTTON oButton1 PROMPT "Filtrar Valores" SIZE 037, 012 ACTION MONTATMPE5(.t.) OF oDlg PIXEL
		//@ 010, 485 CHECKBOX oCheckBo1 VAR lValor PROMPT "Filtra Valores" SIZE 048, 008  OF oDlg COLORS 0, 16777215 PIXEL
		MONTATMPE5(.t.)
		
		TRBC->(DbGoTop())
		oSel := MsSelect():New("TRBC"  ,"OK",, aCpoBro  ,@lInv,@cMarca,{aPosObj[1,1]+15,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,,oDlg,,)
		oSel:bAval	:= {|| marca() }
		oSel:oBrowse:bChange := {||MONTATMPE5(.t.),oMark:oBrowse:Refresh(.f.),oSel:oBrowse:Refresh(.F.)}
		
		oMark := MsSelect():New('SE5',"E5_SEL",,,@lInv,@cMarca,{aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]} , , ,,,aLegenda)
		oMark:bAval	:= {|| marcaE5() }
		//oMark:oBrowse:bChange := {||MONTATMPE5(.T.),oMark:oBrowse:Refresh(.F.),oSel:oBrowse:Refresh(.T.)}
		//oSel := MsSelect():New("ARQFAM","ZN_OK"   ,,_aBrwFam,@lInv,@cMarca,{013,004,098,238},,,_oDlg,,)

	Else
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		//-- Microsiga Browse da esquerda
		oFWLayer:addLine("DOWN",100,.F.)
		oFWLayer:AddCollumn("ALL",50,.T.,"DOWN")
		oFWLayer:AddWindow("ALL","oPanelLeft","Arquivo Bancário",100,.F.,.T.,,"DOWN",{ || })
		oPanelLeft := oFWLayer:GetWinPanel("ALL","oPanelLeft","DOWN")
		
		DEFINE FWMBROWSE oMBrowseLeft ALIAS "TRBC" MENUDEF "AFIN001" NO DETAILS PROFILEID "1" OF oPanelLeft
			ADD MARKCOLUMN oColumn DATA { || If(!Empty(TRBC->OK),'LBOK','LBNO') } DOUBLECLICK { |oMBrowseLeft| marca() } HEADERCLICK { |oMBrowseLeft| marcall(oMBrowseLeft) } OF oMBrowseLeft
			oMBrowseLeft:AddLegend('TRBC->TIPO=="C" .or. ("119" $ TRBC->CATEGORIA) ',"BR_VERDE"	, "CONTAS A RECEBER")
			oMBrowseLeft:AddLegend('TRBC->TIPO=="D" .AND. !("119" $ TRBC->CATEGORIA) ',"BR_VERMELHO"	, "CONTAS A PAGAR")
			oMBrowseLeft:AddColumn({"Valor",{ ||  TRBC->VALOR },'N',"@E 999,999,999.99",2,11})
			oMBrowseLeft:AddColumn({"Data",{ ||  TRBC->DATAC },'D',,0,10})
			ADD COLUMN oColumn DATA { ||  TRBC->CATEGORIA }	TITLE "Categoria"   SIZE 10 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->BANCO  } 		TITLE "Banco"    	SIZE 3 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->Agencia  } 	TITLE "Agencia"    	SIZE 6 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->Dva  } 			TITLE "Dv. Agencia" SIZE 2 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->Conta  } 		TITLE "Conta"    	SIZE 10 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->Dvcon  } 		TITLE "Dv.Conta"    SIZE 2 OF oMBrowseLeft
			//ADD COLUMN oColumn DATA { ||  TRBC->VALOR }		TITLE "Valor"   	SIZE 11 picture "@E 999,999,999.99"  OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->HIST }	TITLE "HISTORICO"   SIZE 10 OF oMBrowseLeft
			ADD COLUMN oColumn DATA { ||  TRBC->IDENT }	TITLE "IdentIficacao"   SIZE 10 OF oMBrowseLeft // Incluido para identIficação do movimento para geração de RA  -- Andre/Rsac -- 09.10.2017

			oMBrowseLeft:SetDoubleClick({|| TELAINFO()})
		ACTIVATE FWMBROWSE oMBrowseLeft
		
		oFWLayer:AddCollumn("RIGHT",50,.T.,"DOWN")
		oFWLayer:AddWindow("RIGHT","oPanelDIRU","Movimento Bancario",100,.F.,.T.,,"DOWN",{ || })
		oPanelDIR := oFWLayer:GetWinPanel("RIGHT"	,"oPanelDIRU","DOWN")
		
		DEFINE FWMBROWSE oMBrowseDirU ALIAS "SE5" NO DETAILS PROFILEID "1" OF oPanelDIR
			oMBrowseDirU:SetMenuDef( '' )
			ADD MARKCOLUMN oColumn DATA { || If(!Empty(SE5->E5_SEL),'LBOK','LBNO') } DOUBLECLICK { |oMBrowseDirU| marcaE5 () } HEADERCLICK { |oMBrowseDir| marcall(oMBrowseLeft) } OF oMBrowseDir
			oMBrowseDirU:AddLegend('E5_RECPAG=="R" .or. ("119" $ TRBC->CATEGORIA) ',"BR_VERDE"	, "CONTAS A RECEBER")
			oMBrowseDirU:AddLegend('E5_RECPAG=="P" .AND. !("119" $ TRBC->CATEGORIA) ',"BR_VERMELHO"	, "CONTAS A PAGAR")
			ADD COLUMN oColumn DATA { ||  E5_DATA } 		TITLE "Data Movimento"    	SIZE 3 OF oMBrowseDirU
			oMBrowseDirU:AddColumn({"Valor",{ ||  E5_VALOR },'N',"@E 999,999,999.99",2,11})
		ACTIVATE FWMBROWSE oMBrowseDirU
		
		oRelation := FWBrwRelation():New()
		oRelation:AddRelation(oMBrowseLeft,oMBrowseDir,{{"E5_BANCO","TRBC->BANCO","="},{"E5_TIPODOC","'BA'","<>"},{"E5_DATA","dtos(TRBC->DATAC)","="},{"E5_RECPAG","IIf(TRBC->TIPO=='C','R','P')","="},{"E5_CONTA","TRBC->Conta","="}})
		oRelation:Activate()
EndIf

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nVai:=1 ,oDlg:End()},{||  nVai:=0,oDlg:End()},,@aButtons )

//Apaga o arquivo fisicamente 
FErase( cArqTrab + GetDbExtension())
//Apaga os arquivos de índices fisicamente
FErase( "TRBC" + OrdBagExt())

Return


Static Function ProcConc()

ProcRegua(0)
DbSelectArea('TRBC')
DbGoTop()

While !TRBC->(EOF())
	IncProc("Processando")
	If !Empty(TRBC->OK)
		lTrava:=.F.
		cSql:=" SELECT R_E_C_N_O_ AS REC,* FROM "+RETSqlName('SE5')+" "
		cSql+=" WHERE E5_BANCO ='"+TRBC->BANCO +"'
		cSql+=" AND E5_AGENCIA='"+TRBC->Agencia+"'
		cSql+=" AND E5_CONTA='"+TRBC->Conta+"'
		cSql+=" AND E5_DATA='"+DTOS(TRBC->DATAC)+"'
		cSql+=" AND E5_VALOR ="+cValtoChar(TRBC->VALOR)+""
		cSql+=" AND E5_CONTEXT ='"+Alltrim(TRBC->CONTEXT)+"'"
		cSql+=" AND D_E_L_E_T_<>'*'
		
		If Select('TEME5')<>0
			TEME5->(DBCloseArea())
		EndIf
		TCQuery cSql New Alias "TEME5"
		
		If !TEME5->(EOF())
			lTrava := .T.
		EndIf
		
		If !Empty(TRBC->RECOR)  .or. lTrava
			//	Alert(CVALTOCHAR(TRBC->VALOR))
			
			DbSelectArea('SE5')
			If lTrava
				DbGoTo(TEME5->REC)
			Else
				DbGoTo(TRBC->RECOR)
			EndIf
			RecLock("SE5",.f.)
			SE5->E5_RECONC := "x"
			SE5->E5_CONTEXT= TRBC->CONTEXT
			MsUnlock()
		Else
			If '106' $ TRBC->CATEGORIA .or. '206' $ TRBC->CATEGORIA .or. '000' $ TRBC->CATEGORIA .or. '005' $ TRBC->CATEGORIA .or. '006' $ TRBC->CATEGORIA  .or. '007' $ TRBC->CATEGORIA //aplicacoes
				_cNat:=padr("21206",TamSX3('ED_CODIGO')[1])
				
				cSql:=" SELECT * FROM "+RETSqlName('SE5')+" "
				cSql+=" WHERE  E5_NATUREZ='"+_cNat+"'
				//cSql+=" 			AND E5_DOCUMEN='"+Dtoc(TRBC->DATAC)+"' "
				cSql+=" 			AND E5_BANCO ='"+TRBC->BANCO +"'
				cSql+=" 			AND E5_AGENCIA='"+TRBC->Agencia+"'
				cSql+=" 			AND E5_CONTA='"+TRBC->Conta+"'
				cSql+=" 			AND E5_DATA='"+DTOS(TRBC->DATAC)+"'
				cSql+=" 			AND E5_VALOR ="+cValtoChar(TRBC->VALOR)+""
				cSql+=" 			AND D_E_L_E_T_<>'*'
				
				If Select('TEME5')<>0
					TEME5->(DBCloseArea())
				EndIf
				TCQuery cSql New Alias "TEME5"
				If TEME5->(EOF())
					//Movimento bancario
					
					
					cSql:=" SELECT A6_COD,A6_AGENCIA,A6_NUMCON FROM "+RETSqlName('SA6')+" "
					cSql+=" WHERE   A6_COD ='"+TRBC->BANCO +"'
					cSql+=" AND A6_NOME  LIKE '%APLICACAO%'"
					cSql+=" 			AND A6_AGENCIA like '%"+Substr(Alltrim(TRBC->Agencia),1,len(Alltrim(TRBC->Agencia))-1)+"%'
					cSql+=" 			AND A6_NUMCON like '"+Substr(Alltrim(TRBC->Conta ),1,len(Alltrim(TRBC->Conta))-1)+"%'
					cSql+="       AND A6_BLOCKED <> '1'  "
					cSql+=" 			AND D_E_L_E_T_<>'*'
					If Select('APL')<>0
						APL->(DBCloseArea())
					EndIf
					TCQuery cSql New Alias "APL"
					If !APL->(EOF())
						cBcoApl			:= APL->A6_COD
						cAgApl      := APL->A6_AGENCIA
						cCCApl      := APL->A6_NUMCON
					Else
						cSql:=" SELECT A6_COD,A6_AGENCIA,A6_NUMCON FROM "+RETSqlName('SA6')+" "
						cSql+=" WHERE   A6_COD ='"+TRBC->BANCO +"'
						cSql+=" AND A6_NOME  LIKE '%APLICACAO%'"
						cSql+=" 			AND A6_AGENCIA like '%"+Substr(Alltrim(TRBC->Agencia),1,len(Alltrim(TRBC->Agencia))-1)+"%'
						cSql+=" 			AND A6_NUMCON like '%APLIC%'
						cSql+="       AND A6_BLOCKED <> '1'  " 
						cSql+=" 			AND D_E_L_E_T_<>'*'
						If Select('APL')<>0
							APL->(DBCloseArea())
						EndIf
						TCQuery cSql New Alias "APL"
						If !APL->(EOF())
							cBcoApl			:= APL->A6_COD
							cAgApl      := APL->A6_AGENCIA
							cCCApl      := APL->A6_NUMCON
						Else
							cBcoApl			:= ""
							cAgApl      := ""
							cCCApl    := ""
						EndIf
					EndIf
					DDATAAUX:=DDATABASE
					If '106' $ TRBC->CATEGORIA
						
						
						DDATABASE:=TRBC->DATAC
						aFINA100 := {    {"CBCOORIG"        ,TRBC->BANCO                     ,Nil},;
						{"CAGENORIG"        ,TRBC->Agencia                   ,Nil},;
						{"CCTAORIG"         ,TRBC->Conta                    ,Nil},;
						{"CNATURORI"        ,_cNat                           ,Nil},;
						{"CBCODEST"         ,cBcoApl                           ,Nil},;
						{"CAGENDEST"        ,cAgApl                          ,Nil},;
						{"CCTADEST"         ,cCCApl                          ,Nil},;
						{"CNATURDES"        ,_cNat                           ,Nil},;
						{"CTIPOTRAN"        ,"TB"                            ,Nil},;
						{"CDOCTRAN"         ,DTOS(TRBC->DATAC)               ,Nil},;
						{"NVALORTRAN"       ,TRBC->VALOR                     ,Nil},;
						{"CHIST100"         ,	TRBC->HIST            				 ,Nil},;
						{"CBENEF100"        ," "                             ,Nil},;
						{"E5_CONTEXT"    		,TRBC->CONTEXT									,Nil}}
					Else
						DDATABASE:=TRBC->DATAC
						aFINA100 := {    {"CBCOORIG"        ,cBcoApl                     		,Nil},;
						{"CAGENORIG"        ,cAgApl                   			,Nil},;
						{"CCTAORIG"         ,cCCApl                   		 	,Nil},;
						{"CNATURORI"        ,_cNat                          ,Nil},;
						{"CBCODEST"         ,TRBC->BANCO                    ,Nil},;
						{"CAGENDEST"        ,TRBC->Agencia                  ,Nil},;
						{"CCTADEST"         ,TRBC->Conta                    ,Nil},;
						{"CNATURDES"        ,_cNat                          ,Nil},;
						{"CTIPOTRAN"        ,"TB"                           ,Nil},;
						{"CDOCTRAN"         ,DTOS(TRBC->DATAC)              ,Nil},;
						{"NVALORTRAN"       ,TRBC->VALOR                    ,Nil},;
						{"CHIST100"         ,	TRBC->HIST            				,Nil},;
						{"CBENEF100"        ," "                            ,Nil},;
						{"E5_CONTEXT"    		,TRBC->CONTEXT									,Nil}}
					EndIf
					lMsErroAuto:=.f.
					MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)
					If lMsErroAuto
						Mostraerro()
					Else
						
						
						
						cUpd:=" update "+retSqlName('SE5')
						cUpd+=" set E5_RECONC = 'x' "
						cUpd+=" ,E5_CONTEXT='"+TRBC->CONTEXT+"'"
						cUpd+=" WHERE E5_PROCTRA ='"+SE5->E5_PROCTRA+"'"
						TCSQLexec(cUpd)
						
					EndIf
					DDATABASE:=DDATAAUX
					
				EndIf
				
			EndIf
			
			
			
			//incluido Andre/Rsac 07/08/2016
			If ('205' $ TRBC->CATEGORIA .AND. ('900' $ TRBC->MOVIMENTO .or. '732' $ TRBC->MOVIMENTO .or. '0093' $ TRBC->MOVIMENTO .or. '0612' $ TRBC->MOVIMENTO )) .or. ('209' $ TRBC->CATEGORIA .AND. '0976' $ TRBC->MOVIMENTO  .or. '0623' $ TRBC->MOVIMENTO  ) // Andre/Rsac 05/09/2016
				
				_cNat:=padr("40101",TamSX3('ED_CODIGO')[1])
				
				cSql:=" SELECT * FROM "+RETSqlName('SE5')+" "
				cSql+=" WHERE  E5_NATUREZ='"+_cNat+"'
				//cSql+=" 			AND E5_DOCUMEN='"+Dtoc(TRBC->DATAC)+"' "
				cSql+=" 			AND E5_BANCO ='"+TRBC->BANCO +"'
				cSql+=" 			AND E5_AGENCIA='"+TRBC->Agencia+"'
				cSql+=" 			AND E5_CONTA='"+TRBC->Conta+"'
				cSql+=" 			AND E5_DATA='"+DTOS(TRBC->DATAC)+"'
				cSql+=" 			AND E5_VALOR ="+cvaltochar(TRBC->VALOR)
				cSql+=" 			AND D_E_L_E_T_<>'*'
				
				If Select('TEME5')<>0
					TEME5->(DBCloseArea())
				EndIf
				TCQuery cSql New Alias "TEME5"
				If TEME5->(EOF())
					
					cSql:=" SELECT A6_COD,A6_AGENCIA,A6_NUMCON FROM "+RETSqlName('SA6')+" "
					cSql+=" WHERE A6_COD  = 'CRT'"
					cSql+="       AND A6_BLOCKED <> '1' " //10/10/2016 -- ANDRE/RSAC
					cSql+=" 			AND D_E_L_E_T_<>'*'
					
					If Select('APL')<>0
						APL->(DBCloseArea())
					EndIf
					TCQuery cSql New Alias "APL"
					If !APL->(EOF())
						cBcoApl			:= APL->A6_COD
						cAgApl      := APL->A6_AGENCIA
						cCCApl      := APL->A6_NUMCON
					Else
						cBcoApl			:= ""
						cAgApl      := ""
						cCCApl    := ""
					EndIf
					
					DDATABASE:=TRBC->DATAC
					aFINA100 := {   {"CBCOORIG"         , cBcoApl                     		,Nil},;
					{"CAGENORIG"        , cAgApl                   			,Nil},;
					{"CCTAORIG"         , cCCApl                   		 	,Nil},;
					{"CNATURORI"        , _cNat                          ,Nil},;
					{"CBCODEST"         , TRBC->BANCO                    ,Nil},;
					{"CAGENDEST"        , TRBC->Agencia                  ,Nil},;
					{"CCTADEST"         , TRBC->Conta                    ,Nil},;
					{"CNATURDES"        , _cNat                          ,Nil},;
					{"CTIPOTRAN"        , "TB"                           ,Nil},;
					{"CDOCTRAN"         , DTOS(TRBC->DATAC)              ,Nil},;
					{"NVALORTRAN"       , TRBC->VALOR                    ,Nil},;
					{"CHIST100"         , TRBC->HIST    			        	,Nil},;
					{"CBENEF100"        , SM0->M0_NOMECOM                ,Nil},;
					{"E5_CONTEXT"    		, TRBC->CONTEXT									,Nil}}
					lMsErroAuto:=.f.
					MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)
					If lMsErroAuto
						Mostraerro()
					Else
						
						cUpd:=" update "+retSqlName('SE5')
						cUpd+=" set E5_RECONC = 'x' "
						cUpd+=" ,E5_CONTEXT='"+TRBC->CONTEXT+"'"
						cUpd+=" WHERE E5_PROCTRA ='"+SE5->E5_PROCTRA+"'"
						TCSQLexec(cUpd)
						
						
					EndIf
				EndIf
			EndIf
			
			
			If '105' $ TRBC->CATEGORIA   .or.('104' $ TRBC->CATEGORIA .AND. '124' $ TRBC->MOVIMENTO) .or. ('110' $ TRBC->CATEGORIA)//tarIfas
				lJaFez:=.F.
				cSql:=" SELECT * FROM "+RETSqlName('SE5')+" "
				cSql+=" WHERE  E5_NATUREZ='21201'"
				//	cSql+=" 			AND E5_DOCUMEN='"+Dtoc(TRBC->DATAC)+"' "
				cSql+=" 			AND E5_BANCO ='"+TRBC->BANCO +"'
				cSql+=" 			AND E5_AGENCIA='"+TRBC->Agencia+"'
				cSql+=" 			AND E5_CONTA='"+TRBC->Conta+"'
				cSql+=" 			AND E5_DATA='"+DTOS(TRBC->DATAC)+"'
				cSql+=" 			AND E5_VALOR ="+CVALTOCHAR(TRBC->VALOR)+""
				cSql+=" 			AND D_E_L_E_T_<>'*'
				
				If Select('TEME5')<>0
					TEME5->(DBCloseArea())
				EndIf
				TCQuery cSql New Alias "TEME5"
				
				If !TEME5->(EOF())
					cSql:=" SELECT * FROM "+RETSqlName('SE5')+" "
					If !('110' $ TRBC->CATEGORIA)
						cSql+=" WHERE  E5_NATUREZ='21201'"
					Else
						cSql+=" WHERE  E5_NATUREZ='21202'"
					EndIf
					//	cSql+=" 			AND E5_DOCUMEN='"+Dtoc(TRBC->DATAC)+"' "
					cSql+=" 			AND E5_BANCO ='"+TRBC->BANCO +"'
					cSql+=" 			AND E5_AGENCIA='"+TRBC->Agencia+"'
					cSql+=" 			AND E5_CONTA='"+TRBC->Conta+"'
					cSql+=" 			AND E5_DATA='"+DTOS(TRBC->DATAC)+"'
					cSql+=" 			AND E5_VALOR ="+CVALTOCHAR(TRBC->VALOR)+""
					cSql+=" 			AND D_E_L_E_T_<>'*'
					cSql+=" 			AND E5_CONTEXT='"+TRBC->CONTEXT+"'"
					
					If Select('TEME5')<>0
						TEME5->(DBCloseArea())
					EndIf
					TCQuery cSql New Alias "TEME5"
					If !TEME5->(EOF())
						lJaFez:=.t.
					EndIf
					
				EndIf
				If !lJaFez
					aFINA100 := {    {"E5_DATA"        		,TRBC->DATAC                  ,Nil},;
					{"E5_MOEDA"        	,"M1"                           ,Nil},;
					{"E5_VALOR"         ,TRBC->VALOR                    ,Nil},;
					{"E5_NATUREZ"    		,'21201'                       	,Nil},;
					{"E5_BANCO"        	,TRBC->BANCO                  	,Nil},;
					{"E5_AGENCIA"    		,TRBC->Agencia                	,Nil},;
					{"E5_CONTA"        	,TRBC->Conta                   	,Nil},;
					{"E5_ORIGEM"       	,'AFIN001'    	               	,Nil},;
					{"E5_HISTOR"    		,TRBC->HIST        							,Nil},;
					{"E5_CONTEXT"    		,TRBC->CONTEXT									,Nil}}
					lMsErroAuto:=.f.
					ddtbaux:=ddatabase
					ddatabase:=TRBC->DATAC
					MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
					If lMsErroAuto
						Mostraerro()
					Else
						RecLock("SE5",.f.)
						SE5->E5_RECONC := "x"
						SE5->E5_CONTEXT= TRBC->CONTEXT
						MsUnlock()
					EndIf
					ddatabase:=ddtbaux
				EndIf
			EndIf
			
			
		EndIf
		
	EndIf
	TRBC->(dbSkip())
EndDO
If CTIPOTELA<>1
	oMBrowseLeft:REFRESH()
Else
	MONTATMPE5()
	oMark:oBrowse:Refresh(.f.)
	oSel:oBrowse:Refresh(.F.)
EndIf
Return


User Function AFIN001A(lPRimeiro)
Local cPerg		:= "AFIN001a"
Private lAbort

Default lPRimeiro := .f.

lVai := .f.
While !lVai
	
	If !(Pergunte(cPerg,.t.))
		Return
	EndIf

	If file(mv_par01)
			lVai 		:= .T.
			CTIPOTELA	:= mv_par02
		Else
			Alert("Verifique o arquivo!")
	EndIf
	
Enddo

Processa({||AFIN001B(lPRimeiro)} ,"Arquivo extrato","Aguarde...",lAbort)

Return()

//Processa o extrato
Static Function AFIN001B(lPRimeiro)
Local nCount	:= 0
Local nSaldo	:= 0
Local cPerg		:= "AFIN001a"

Pergunte(cPerg,.F.)

CriaTemp1() //funcao que monta uma tabela temporaria com os itens do arquivo de conciliacao.

aArqDir := DIRECTORY(mv_par01)
cNomeAr	:= aArqDir[1][1]

cArqImpor	:= mv_par01
cArqTxt 	:= mv_par01

//+---------------------------------------------------------------------+
//| Abertura do arquivo texto                                           |
//+---------------------------------------------------------------------+
nHdl := fOpen(cArqTxt)
//+---------------------------------------------------------------------+
//| Posiciona no Inicio do Arquivo                                      |
//+---------------------------------------------------------------------+
FSEEK(nHdl,0,0)
//+---------------------------------------------------------------------+
//| Traz o Tamanho do Arquivo TXT                                       |
//+---------------------------------------------------------------------+
nTamArq:=FSEEK(nHdl,0,2)
//+---------------------------------------------------------------------+
//| Posicona novamemte no Inicio                                        |
//+---------------------------------------------------------------------+
FSEEK(nHdl,0,0)

//+---------------------------------------------------------------------+
//| Fecha o Arquivo                                                     |
//+---------------------------------------------------------------------+
fClose(nHdl)
FT_FUse(cArqImpor)  //abre o arquivo
FT_FGOTOP()         //posiciona na primeira linha do arquivo
nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
FT_FGOTOP()
//+---------------------------------------------------------------------+
//| VerIfica quantas linhas tem o arquivo                               |
//+---------------------------------------------------------------------+
cErros		:= ""
lJaleu		:= .f.
DDATAORIGI	:=	DDATABASE
nLinhas 	:= nTamArq/nTamLinha
ProcRegua(nLinhas)

aJatem	:={}
aTemArq	:={}
aDtSaldo:={}

While !FT_FEOF()// .AND. ncont < 16
	nCount++
	IncProc('Importando Linha ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nLinhas))) )
	If lAbort
		Return
	EndIf
	clinha := FT_FREADLN()
	If Substr(clinha,8,1)=='0'
		nValINI:=	val(Substr(clinha,151,16))/100
		FT_FSKIP()
		loop
	EndIf
	
	If Substr(clinha,8,1)=='5'
		nValorArq:=	(val(Substr(clinha,151,18))/100)
		
		nValorMov :=nSaldoIni-nValorArq
		
		FT_FSKIP()
		loop
	EndIf
	
	If Substr(clinha,9,1)=='E'
		nSaldoIni	:=	Val(Substr(clinha,151,18))/100
		/*
		DTDS:=STOD(Substr(clinha,147,4)+ Substr(clinha,145,2)+ Substr(clinha,143,2))
		nPos:=aScan(aDtSaldo,{|x| x[1]==DTDS} )
		If nPos == 0
		AADD(aDtSaldo,{DTDS,val(Substr(clinha,151,16))/100,0})
		Else
		aDtSaldo[npos][2]:=nValINI
		EndIf
		*/
		FT_FSKIP()
		loop
	EndIf
	
	If Substr(clinha,170,3) =='119'
		FT_FSKIP()
		loop
	EndIf

	If Substr(clinha,1,3)=='001'
		If 	Substr(clinha,9,1)=='E' .or. Substr(clinha,8,1)=='5' .or. Substr(clinha,169,1)==' '
			FT_FSKIP()
			loop
		EndIf
	EndIf
	
	//fazer aki validacao cnpj
	
	If Substr(clinha,19,14)<>SM0->M0_CGC .AND. !lJaleu
			Alert('Arquivo pertence a outra empresa!')
			Return
		Else
			lJaleu := .T.
	EndIf
	
	cBco	:= Substr(clinha,001,3)
	cAg		:= Substr(clinha,054,4)
	ccc		:= cValtochar(val(Substr(clinha,066,5)))
	cgc		:= Substr(clinha,019,15)
	
	If cBco == "001" //Banco do Brasil
			cSql:=" SELECT TOP 1 A6_FILIAL,R_E_C_N_O_ REC 
			cSql+=" FROM "+RetSqlName('SA6')
			cSql+=" WHERE A6_COD='"+cBco+"'"
			//cSql+=" AND A6_AGENCIA ='"+CVALTOCHAR(VAL(cAg))+"'"
			//cSql+=" AND '"+STRTRAN(Substr(clinha,066,7),' ','')+"' LIKE ('%'+ltrim(rtrim(A6_NUMCON))+ltrim(rtrim(A6_DVCTA))) "
			cSql+=" AND A6_NUMCON = '"+ Substr(clinha,067,5) +"'"
			cSql+=" AND A6_AGENCIA = '"+ Substr(clinha,054,5) +"'"
			cSql+=" AND A6_BLOCKED <> '1' " //10/10/2016 -- ANDRE/RSAC
			cSql+=" AND D_E_L_E_T_<>'*' " 
			cSql+=" AND A6_X_TPCON = '3' "// 1= APL1CAÇÃO - 20/06/2018 -- ANDRE/RSAC 
		
		Else //Outros bancos
			cSql:=" SELECT TOP 1 A6_FILIAL,R_E_C_N_O_ REC 
			cSql+=" FROM "+RetSqlName('SA6')
			cSql+=" WHERE A6_COD='"+cBco+"'"
			cSql+=" AND A6_AGENCIA ='"+CVALTOCHAR(VAL(cAg))+"'"
			cSql+=" AND '"+STRTRAN(Substr(clinha,066,7),' ','')+"' LIKE ('%'+ltrim(rtrim(A6_NUMCON))+ltrim(rtrim(A6_DVCTA))) "
			cSql+=" AND A6_BLOCKED <> '1' " //10/10/2016 -- ANDRE/RSAC
			cSql+=" AND D_E_L_E_T_<>'*' " 
	EndIf

	If Select('TRA6')<>0
		TRA6->(DBCloseArea())
	EndIf
	TcQuery cSql New Alias 'TRA6'
	
	If !TRA6->(EOF())
		DbSelectArea('SA6')
		DbGoTo(TRA6->REC)
	EndIf
	
	If Substr(clinha,8,1)=='9'
		FT_FSKIP()
		loop
	EndIf
	
	DDATABASE	:=TRBC->DATAC
	RecLock('TRBC',.t.)
	
	If Substr(clinha,001,3) == '341'
		TRBC->OK		:= " "
		TRBC->BANCO		:= SA6->A6_COD
		TRBC->Agencia   := SA6->A6_AGENCIA
		TRBC->Dva		:= SA6->A6_DVAGE
		TRBC->Conta     := SA6->A6_NUMCON
		TRBC->Dvcon    	:= SA6->A6_DVCTA
		TRBC->CATEGORIA := Substr(clinha,170,3)
		TRBC->VALOR		:= round(VAL(Substr(clinha,151,18))/100,2)
		TRBC->TIPO     	:= Substr(clinha,169,1)
		TRBC->HIST		:= Substr(clinha,177,25)
		TRBC->DATAC     := STOD(Substr(clinha,147,4)+ Substr(clinha,145,2)+ Substr(clinha,143,2))
		TRBC->CONTEXT	:= cNomeAr+strzero(nCount,5)
		TRBC->MOVIMENTO	:= Substr(clinha,173,4)
		DDATABASE		:=TRBC->DATAC

	ElseIf Substr(clinha,001,3)=='001'
		TRBC->OK		:= " "
		TRBC->BANCO		:= SA6->A6_COD
		TRBC->Agencia   := SA6->A6_AGENCIA
		TRBC->Dva		:= SA6->A6_DVAGE
		TRBC->Conta     := SA6->A6_NUMCON
		TRBC->Dvcon    	:= SA6->A6_DVCTA
		TRBC->CATEGORIA := Substr(clinha,170,3)
		TRBC->VALOR		:= round(VAL(Substr(clinha,151,18))/100,2)
		TRBC->TIPO     	:= Substr(clinha,169,1)
		TRBC->HIST		:= Substr(clinha,177,25)
		TRBC->DATAC     := STOD(Substr(clinha,147,4)+ Substr(clinha,145,2)+ Substr(clinha,143,2))
		TRBC->CONTEXT	:= cNomeAr+strzero(nCount,5)
		TRBC->MOVIMENTO	:= Substr(clinha,173,4)
		TRBC->TIPO     	:= Substr(clinha,169,1)
	    TRBC->IDENT     := Substr(clinha,203,14)// Incluido para identIficação do movimento para geração de RA  -- Andre/Rsac -- 09.10.2017

		DDATABASE		:=TRBC->DATAC
		nValconc		:=	Substr(clinha,151,16)

	EndIf
	
	If empty(dDtaIni)
		dDtaIni	:= TRBC->DATAC
		cBcoIni	:= TRBC->BANCO
		cAgIni	:= TRBC->Agencia
		cCCini	:= TRBC->Conta
	EndIf
	
	
	If Alltrim(TRBC->CATEGORIA) =='101'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Cheques"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='102'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Encargos"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='103'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Estornos"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='104'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Lançamento Avisado"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='105'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " TarIfas"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='106'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Aplicação"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='107'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Empréstimo / Financiamento"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='108'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Câmbio"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='109'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " CPMF"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='110'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " IOF"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='111'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Imposto de Renda"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='112'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Pagamento Fornecedores"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='113'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Pagamento Funcionários"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='114'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Saque Eletrônico"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='115'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Ações"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='117'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Transferência entre Contas"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='118'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Devolução da Compensação"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='119'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Devolução de Cheque Depositado"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='120'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Transferência Interbancária (DOC, TED)"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='121'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Antecipação a Fornecedores"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='201'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Depósitos"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='202'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Líquido de Cobrança"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='203'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Devolução de Cheques"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='204'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Estornos"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='205'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Lançamento Avisado"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='206'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Resgate de Aplicação"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='207'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Empréstimo / Financiamento"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='208'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Câmbio"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='209'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Transferência Interbancária (DOC, TED)"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='210'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Ações"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='211'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Dividendos"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='212'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Seguro"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='213'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Transferência entre Contas"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='214'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Depósitos Especiais"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='215'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " Devolução da Compensação"
	EndIf
	
	If Alltrim(TRBC->CATEGORIA) =='216'
		TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " OCT"
	EndIf
	
	If Substr(clinha,001,3)=='341'
		
		If Alltrim(TRBC->CATEGORIA) =='001'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " APLICACAO "
			TRBC->TIPO  :="C"
		EndIf
		If Alltrim(TRBC->CATEGORIA) =='003'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " VALOR PRINCIPAL RESGATE  "
			TRBC->TIPO  :="D"
		EndIf
		If Alltrim(TRBC->CATEGORIA) =='005'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " RENDIMENTO BRUTO PAGO "
			TRBC->TIPO  :="C"
		EndIf
		If Alltrim(TRBC->CATEGORIA) =='006'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " IOF "
			TRBC->TIPO  :="D"
		EndIf
		
		If Alltrim(TRBC->CATEGORIA) =='007'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " IR "
			TRBC->TIPO  :="D"
		EndIf
		
		If Alltrim(TRBC->CATEGORIA) =='000'
			TRBC->CATEGORIA := Alltrim(TRBC->CATEGORIA)+ " RENDIMENTO LIQUIDO PAGO "
			TRBC->TIPO  :="D"
		EndIf
		
	EndIf
	
	cSql:=" SELECT A6_COD,A6_AGENCIA,A6_NUMCON 
	cSql+=" FROM "+RETSqlName('SA6')+" "
	cSql+=" WHERE   A6_COD ='"+TRBC->BANCO +"'
	cSql+=" AND A6_NOME NOT LIKE '%APLICACAO%' 
	cSql+=" AND A6_NOME NOT LIKE '%CDB%' "  //INCLUIDO 03/08/2016 -- Andre/Rsac -- Tratativa para não buscar conta do CDB
	cSql+=" AND A6_AGENCIA like '%"+Alltrim(str(val(TRBC->Agencia)))+"%'
	cSql+=" AND A6_NUMCON like '"+Alltrim(TRBC->Conta)+"%'
	cSql+=" AND D_E_L_E_T_<>'*'

	If Select('TEME5')<>0
		TEME5->(DBCloseArea())
	EndIf
	TCQuery cSql New Alias "TEME5"

	If !TEME5->(EOF())
		TRBC->BANCO		:= TEME5->A6_COD
		TRBC->Agencia   := TEME5->A6_AGENCIA
		TRBC->Conta     := TEME5->A6_NUMCON
	EndIf
	
	cSql:=" SELECT R_E_C_N_O_ REC,* 
	cSql+=" FROM "+RETSqlName('SE5')+" "
	cSql+=" WHERE   E5_BANCO ='"+TRBC->BANCO +"'
	cSql+=" AND E5_AGENCIA like '%"+Alltrim(str(val(TRBC->Agencia)))+"%'
	cSql+=" AND E5_CONTA like '"+Alltrim(TRBC->Conta)+"%'
	cSql+=" AND E5_DATA='"+DTOS(TRBC->DATAC)+"'  "
	//	cSql+=" AND E5_TIPO<>'RA'"
	cSql+=" AND E5_TIPO <> 'CH' "//INCLUIDO -- 03/08/2016 -- ANDRE/RSAC -- TRATAR APENAS RA  -- ESTAVA BUSCANDO MOVIMENTOS DE CHEQUES INCLUIDOS MANUALMENTE NO SISTEMA.
	cSql+=" AND E5_VALOR='"+cvaltochar(TRBC->VALOR)+"'
	cSql+=" AND D_E_L_E_T_<>'*'
	If Select('TEME5')<>0
		TEME5->(DBCloseArea())
	EndIf

	TCQuery cSql New Alias "TEME5"
	
	nCont := 1
	/*	While !TEME5->(EOF())
	nCont++
	TEME5->(dbSkip())
	EnDDo
	*/
	If nCont == 1
		If aScan(aTemArq,TRBC->CONTEXT) == 0
			aadd(aTemArq,TRBC->CONTEXT)
			TEME5->(DbGoTop())
			While !TEME5->(EOF())
				
				If aScan(aJatem,TEME5->REC) == 0
					TRBC->OK	:= cMarca
					TRBC->RECOR	:=TEME5->REC
					
					DbSelectArea('SE5')
					DbGoTo(TEME5->REC )
					RecLock('SE5',.F.)
					SE5->E5_SEL:=GETMARK()
					
					MsUnlock()
					aadd(aJatem,TEME5->REC)
					exit
				EndIf

				TEME5->(dbSkip())
			EnDDo
		EndIf
	EndIf
	
	
	cSql:=" SELECT R_E_C_N_O_ REC,* 
	cSql+=" FROM "+RETSqlName('SE5')+" "
	cSql+=" WHERE  E5_CONTEXT ='"+TRBC->CONTEXT+"'"
	cSql+=" AND E5_VALOR ="+CVALTOCHAR(TRBC->VALOR)+""
	cSql+=" AND D_E_L_E_T_<>'*'
	If Select('TEMARQ')<>0
		TEMARQ->(DBCloseArea())
	EndIf

	TCQuery cSql New Alias "TEMARQ"
	
	If !TEMARQ->(EOF())
		RecLock('TRBC',.F.)
		TRBC->OK:=cMarca
		MsUnlock()
	EndIf
	
	FT_FSKIP()
EndDO

If !lPRimeiro
	If CTIPOTELA <> 1
		oMBrowseLeft:REFRESH()
	Else
		MONTATMPE5()
		oMark:oBrowse:Refresh(.f.)
		oSel:oBrowse:Refresh(.F.)
	EndIf
	
EndIf

DDATABASE:=DDATAORIGI

Return()


//funcao que monta uma tabela temporaria com os itens do arquivo de conciliacao.
Static Function CriaTemp1()

//cQyr := buscaDados(cFltro)
aStru:={}
Aadd(aStru, {"OK","C",2,0})
CCAMPO:='A6_COD'
Aadd(aStru, {"Banco","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_AGENCIA'
Aadd(aStru, {"Agencia","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_DVAGE'
Aadd(aStru, {"Dva","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_NUMCON'
Aadd(aStru, {"Conta","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_DVCTA'
Aadd(aStru, {"Dvcon","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='TPLAN'
Aadd(aStru, {"Tipo","C",1,0})

CCAMPO:='NATLAN'
Aadd(aStru, {"NATLAN","C",4,0})

CCAMPO:='TPCOMP'
Aadd(aStru, {"TPCOMP","C",4,0})

CCAMPO:='A6_COD'
Aadd(aStru, {"BancoOri","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_AGENCIA'
Aadd(aStru, {"AgeOri","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='A6_NUMCON'
Aadd(aStru, {"ContaOri","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_DATA'
Aadd(aStru, {"Datac","D",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_DATA'
Aadd(aStru, {"DataLAN","D",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_NUMERO'
Aadd(aStru, {"Documento","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_HISTOR'
Aadd(aStru, {"HISTORICO","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='EJ_OCORBCO'
Aadd(aStru, {"CATEGORIA","C",50,TamSX3(CCAMPO)[2]})

CCAMPO:='E5_VALOR'
Aadd(aStru, {"VALOR","N",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_HISTOR'
Aadd(aStru, {"HIST","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})
Aadd(aStru, {"ID","C",6,0})

CCAMPO:='RECOR'
Aadd(aStru, {"RECOR","N",10,0})

CCAMPO:='E1_XINFO'
Aadd(aStru, {"INFO","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

CCAMPO:='E5_CONTEXT'
Aadd(aStru, {"CONTEXT","C",TamSX3(CCAMPO)[1],TamSX3(CCAMPO)[2]})

Aadd(aStru, {"MOVIMENTO","C",4,0})

Aadd(aStru, {"IDENT","C",14,0})// Incluido para identIficação do movimento para geração de RA  -- Andre/Rsac -- 09.10.2017



If Select('TRBC')<>0
	TRBC->(dbCloseArea())
EndIf
cArqTrab := CriaTrab(aStru,.T.) // Nome do arquivo temporario
dbUseArea(.T.,__LocalDriver,cArqTrab,'TRBC',.F.)

//SqlToTrb(cQyr, aStru, "TRBC")

IndRegua ('TRBC',cArqTrab,"ID",,,"Selecionando Registros...")

DbClearIndex()
OrdListAdd(cArqTrab)

//DbSetOrder(1) //FICA NA ORDEM DA QUERY

Return

//funcao que gera a ra
User Function AFIN001c

lTem:=.f.
TRBC->(DbGoTop())
While !TRBC->(EOF())
	If !EMPTY(TRBC->OK)
		lTem:=.t.
		If TRBC->TIPO=='C'
			lMsErroAuto:=.F.
			cNum:=GETSXENUM('SE1','E1_NUM')
			
			
			aVetor := {  {"E1_FILIAL"   , xFilial('SE1')        ,Nil, Nil},;
			{"E1_PREFIXO"   , 'CFN'              	,Nil, Nil},;
			{"E1_NUM"      ,  cNum        	     	,Nil, Nil},;
			{"E1_PARCELA"  ,  ''        			,Nil, Nil},;
			{"E1_TIPO"     , 'RA'          			,Nil, Nil},;
			{"E1_NATUREZ"  , '10302'        		,Nil, Nil},;
			{"E1_CLIENTE"  , '000001'          		,Nil, Nil},;
			{"E1_LOJA"     , '0001'           		,Nil, Nil},;
			{"E1_EMISSAO"  , TRBC->DATAC        	,Nil, Nil},;
			{"E1_VENCTO"   , TRBC->DATAC        	,Nil, Nil},;
			{"E1_PORTADO"  , SA6->A6_COD         	,Nil, Nil},;
			{"E1_AGEDEP"   , SA6->A6_AGENCIA        ,Nil, Nil},;
			{"E1_CONTA"    , SA6->A6_NUMCON        	,Nil, Nil},;
			{"E1_VALOR"    , TRBC->VALOR        ,Nil, Nil }}
			lMsErroAuto:=.f.
			MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao
			
			If lMsErroAuto
					DisarmTransaction()
					//Mostraerro()
				Else
					ConfirmSX8()
					Alert('Titulo numero:'+cNum+ " Gerado com sucesso!")
					oMBrowseRight:refresh()
			EndIf
			
		EndIf
		
		
	EndIf
	
	TRBC->(dbSkip())
EndDo

TRBC->(DbGoTop())

If !ltem
	Alert("Obrigatorio selectionar pelo menos um registro!")
EndIf

Return


Static Function marcall(oMBrowseLeft)

TRBC->(DbGoTop())
While !TRBC->(EOF())
	RecLock('TRBC',.F.)
	TRBC->OK:= cMarca
	TRBC->(MsUnlock())
	
	TRBC->(dbSkip())
EndDo
oMBrowseLeft:Refresh(.t.)
TRBC->(DbGoTop())
Return

Static Function marca()

If !EMPTY(TRBC->OK)
	TRBC->OK:= ''
	If TRBC->TIPO=="C"
		If !Empty(TRBC->RECOR)
			DbSelectArea('SE5')
			DbGoTo(TRBC->RECOR)
			RecLock('SE5',.F.)
			SE5->E5_SEL=''
			MsUnlock()
		ElseIf TRBC->TIPO=="D"
			DbSelectArea('SE5')
			DbGoTo(TRBC->RECOR)
			RecLock('SE5',.F.)
			SE5->E5_SEL=''
			MsUnlock()
		EndIf
	EndIf
Else
	TRBC->OK:=cMarca
EndIf
TRBC->(MsUnlock())


Return

User Function AFIN001e
Private lAbort
Processa({||AFIN001f()} ,"Arquivo Conciliacao","Aguarde...",lAbort)

Return


Static Function marcaE1()

If Empty(SE5->E5_SEL)
	RecLock('SE5',.F.)
	SE5->E5_SEL :=GetMark()
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= cMarca
	TRBC->RECOR	:=SE5->(RECNO())
	TRBC->(MsUnlock())
eLSE
	RecLock('SE5',.F.)
	SE5->E5_SEL :=''
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= ''
	TRBC->RECOR	:=0
	TRBC->(MsUnlock())
EndIf

nposi:=oMBrowseLeft:at()
oMBrowseLeft:refresh(.t.)
oMBrowseLeft:goto(nposi)
MsUnlock()



Return


Static Function marcaE2()

If Empty(SE5->E5_SEL)
	RecLock('SE5',.F.)
	SE5->E5_SEL :=GetMark()
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= cMarca
	TRBC->RECOR	:=SE5->(RECNO())
	TRBC->(MsUnlock())
eLSE
	RecLock('SE5',.F.)
	SE5->E5_SEL :=''
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= ''
	TRBC->RECOR	:=0
	TRBC->(MsUnlock())
EndIf

nposi:=oMBrowseLeft:at()
oMBrowseLeft:refresh(.t.)
oMBrowseLeft:goto(nposi)
MsUnlock()


Return



Static Function marcaE5()

If Empty(SE5->E5_SEL)
	RecLock('SE5',.F.)
	SE5->E5_SEL :=cMarca
	SE5->E5_CONTEXT:=TRBC->CONTEXT
	SE5->E5_RECONC :='x'
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= cMarca
	TRBC->RECOR	:=SE5->(RECNO())
	TRBC->(MsUnlock())
eLSE
	RecLock('SE5',.F.)
	SE5->E5_SEL :=''
	SE5->E5_CONTEXT:=''
	SE5->E5_RECONC :=''
	MsUnlock()
	RecLock('TRBC',.F.)
	TRBC->OK		:= ''
	TRBC->RECOR	:=0
	TRBC->(MsUnlock())
	
EndIf
MsUnlock()

If CTIPOTELA<>1
	nposi:=oMBrowseLeft:at()
	oMBrowseLeft:refresh(.t.)
	oMBrowseLeft:goto(nposi)
Else
	oMark:oBrowse:Refresh(.F.)
	
	MONTATMPE5()
	oMark:oBrowse:Refresh(.f.)
	oSel:oBrowse:Refresh(.F.)
	
EndIf
Return

//Grava o historico do movimento
Static Function TELAINFO()
Local cInform 	:= PADR(Alltrim(TRBC->HIST),TamSX3('E1_XINFO')[1])
Local oButton1
Local oButton2
Local oGet1
Local nGet1 	:= 0.00
Local oSay1
Static oDlg3
lOk				:= .f.

DEFINE MSDIALOG oDlg3 TITLE "Informacao RA" FROM 000, 000  TO 200, 350 COLORS 0, 16777215 PIXEL

@ 004, 004 GROUP Juros TO 094, 169 PROMPT "HISTÓRICO" OF oDlg3 COLOR 0, 16777215 PIXEL
@ 031, 005 SAY 	oSay1 PROMPT "Informacao" SIZE 041, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 029, 035 MSGET oGet1 VAR cInform SIZE 100, 010 OF oDlg3 PICTURE "@!" COLORS 0, 16777215 PIXEL
@ 070, 039 BUTTON oButton1 PROMPT "GRAVAR" 	action GravaInf(oDlg3,cInform) SIZE 037, 012 OF oDlg3 PIXEL
@ 071, 086 BUTTON oButton2 PROMPT "Sair"    action oDlg3:end()   SIZE 037, 012 OF oDlg3 PIXEL

ACTIVATE MSDIALOG oDlg3 CENTERED

Return()

//Grava o historico do movimento no arquivo temporario
Static Function GravaInf(oDlg3,cInform)
	TRBC->INFO := cInform
	TRBC->HIST := cInform
	oDlg3:end()
Return()

//Abre a rotina de baixas a receber
Static Function AbriBx()
	Fina070()
Return()


Static Function AbrirMbx()
Local _stru		:= {}
Local aCpoBro 	:= {}
Local oDlg
Local aCores 	:= {}
Private lInverte:= .F.
Private cMark   := GetMark()
Private oMark
Private lOk:=.T.
cPerg2:="AFIN001_"


If !Pergunte(cPerg2,.t.)
	Return
EndIf

//Cria um arquivo de Apoio
AADD(_stru,{"OK"         ,"C"	,2		,0		})
AADD(_stru,{"Prefixo"    ,"C"	,TamSX3('E1_PREFIXO')[1],0		})
AADD(_stru,{"Titulo"     ,"C"	,TamSX3('E1_NUM')[1]	,0		})
AADD(_stru,{"Parcela"    ,"C"	,TamSX3('E1_PARCELA')[1],0		})
AADD(_stru,{"Tipo"       ,"C"	,TamSX3('E1_TIPO')[1]   ,0		})
AADD(_stru,{"Saldo"      ,"N"	,TamSX3('E1_SALDO')[1]  ,TamSX3('E1_SALDO')[2]		})
AADD(_stru,{"Cliente"    ,"C"	,TamSX3('E1_CLIENTE')[1],0})
AADD(_stru,{"Loja"       ,"C"	,TamSX3('E1_LOJA')[1] 	,0})
AADD(_stru,{"Nome"       ,"C"	,TamSX3('A1_NOME')[1] 	,0})
AADD(_stru,{"Rec"      ,"N"	,10 	,0})

cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.t.,,carq,"TTRB")
//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)

cSql:=" SELECT SE1.R_E_C_N_O_ AS REC,* FROM "+RetSqlName('SE1')+" SE1"
cSql+=" INNER JOIN "+RETSQLNAME('SA1')+" SA1"
cSql+=" ON E1_CLIENTE = A1_COD "
cSql+=" AND E1_LOJA = A1_LOJA "
cSql+=" WHERE E1_VENCREA>='"+dtos(MV_PAR01)+"'"
cSql+=" AND E1_VENCREA<='"+dtos(MV_PAR02)+"'"
cSql+=" AND E1_CLIENTE>='"+MV_PAR03+"'"
cSql+=" AND E1_CLIENTE<='"+MV_PAR04+"'"
cSql+=" AND SE1.D_E_L_E_T_<>'*'"
cSql+=" AND E1_SALDO>0"
cSql+=" AND SA1.D_E_L_E_T_<>'*'"

If Select('TRE1')<>0
	TRE1->(DBCloseArea())
EndIf
TCQuery cSql New Alias "TRE1"

While !TRE1->(EOF())
	DbSelectArea("TTRB")
	RecLock("TTRB",.T.)
	TTRB->OK			:= " "
	TTRB->Prefixo	:= TRE1->E1_PREFIXO
	TTRB->Titulo	:= TRE1->E1_NUM
	TTRB->Parcela	:= TRE1->E1_PARCELA
	TTRB->Tipo   	:= TRE1->E1_TIPO
	TTRB->Saldo   := TRE1->E1_SALDO
	TTRB->Cliente := TRE1->E1_CLIENTE
	TTRB->Loja    := TRE1->E1_LOJA
	TTRB->Nome    := TRE1->A1_NOME
	TTRB->Rec     := TRE1->REC
	MsUnlock()
	TRE1->(dbSkip())
EndDo

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, " "       	,"@!"},;
{ "Prefixo"		,, "Prefixo"           	,"@!"},;
{ "Titulo"		,, "Titulo"           	,"@!"},;
{ "Parcela"		,, "Parcela"          	,"@!"},;
{ "Tipo"			,, "Tipo"   		      	,"@!"},;
{ "Saldo"			,, "Saldo"              ,"@E 999,999,999.99"},;
{ "Cliente"		,, "Cliente"           	,"@!"},;
{ "Loja"			,, "Loja"           	  ,"@!"},;
{ "Nome"			,, "Nome"           	  ,"@!"},;
{ "Rec"		    ,, "Recno"             	,"@!"}}


//Cria uma Dialog

nValor:=TRBC->VALOR
NQTDTIT:=0.00

aSize := MSADVSIZE()

DEFINE MSDIALOG oDlg1 TITLE "Baixas " From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Baixa em Lote"
oDlg1:lMaximized := .T.
oPanel := TPanel():New(0,0,'',oDlg1,, .T., .T.,, ,15,15,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

@003,005 Say "Valor" PIXEL Of oPanel // "Valor Total:"
@003,060 Say oValor VAR nValor Picture PesqPict("SE1","E1_VALOR") PIXEL Of oPanel
@003,120 Say "Valor Selecionado" PIXEL Of oPanel// "Quantidade:"
@003,180 Say oQtda VAR nQtdTit Picture PesqPict("SE1","E1_VALOR")	 SIZE 50,10 PIXEL of oPanel

DbSelectArea("TTRB")
DbGoTop()
//Cria a MsSelect
oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{35,oDlg1:nLeft,aSize[6]-310,aSize[6]+70},,,,,aCores)
oMark:bMark := {| | Disp()}
//Exibe a Dialog
ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1 ,{||lOk:=.t., oDlg1:End()},{|| oDlg1:End()})

If lOk
	lBaixa:=.f.
	nValAgl:=0
	cLoteFin:=GETSXENUM( 'SE5', 'E5_LOTE')
	TTRB->(DbSelectArea('TTRB'))
	TTRB->(DbGoTop())
	While !TTRB->(EOF())
		If !Empty(TTRB->OK)
			DbSelectArea('SE1')
			DbGoTo(TTRB->REC)
			
			nOpca:=0
			nValBaixa:=SE1->E1_SALDO
			nValDesc:=SE1->E1_DECRESC
			nValAcre :=SE1->E1_ACRESC
			DEFINE MSDIALOG oDlg FROM	38,16 TO 347,550 TITLE  "Baixa" PIXEL   //"Dados do cheque"
			
			@ 005,004 SAY "Prefixo" 	SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 005,027 MSGET oPrefixo VAR SE1->E1_PREFIXO when .f. SIZE 30,08 OF oDlg PIXEL HASBUTTON
			
			@ 005,063 SAY "Titulo" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 005,080 MSGET oTitulo VAR SE1->E1_NUM  when .f. SIZE 50,08 OF oDlg PIXEL HASBUTTON
			
			@ 005,140 SAY "Parcela" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 005,167 MSGET oParcela VAR SE1->E1_PARCELA when .f.  SIZE 30,08 OF oDlg PIXEL HASBUTTON
			
			@ 005,200 SAY "Tipo" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 005,227 MSGET oTipo VAR SE1->E1_TIPO  when .f. SIZE 30,08 OF oDlg PIXEL HASBUTTON
			
			
			@ 020,004 SAY "Natureza" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 020+2,027 MSGET oNaturez VAR SE1->E1_NATUREZ	F3 "SED" SIZE 70,08 OF oDlg PIXEL HASBUTTON
			
			@ 035,004 SAY "Valor" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 035,027 MSGET oValBaixa VAR nValBaixa SIZE 70,08 Picture PesqPict("SE1","E1_VALOR") OF oDlg PIXEL HASBUTTON
			
			@ 050,004 SAY "Acrecimo" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 050,027 MSGET oValAcre VAR nValAcre SIZE 70,08 Picture PesqPict("SE1","E1_VALOR") OF oDlg PIXEL HASBUTTON
			
			@ 065,004 SAY "Decrecimo" 				SIZE 31,07 OF oDlg PIXEL //"Natureza"
			@ 065,027 MSGET oValDesc VAR nValDesc SIZE 70,08 Picture PesqPict("SE1","E1_VALOR") OF oDlg PIXEL HASBUTTON
			
			
			DEFINE SBUTTON FROM 130, 175 TYPE 1 ACTION (nOpca:=1,oDlg:End())ENABLE OF oDlg PIXEL
			DEFINE SBUTTON FROM 130, 205 TYPE 2 ACTION (nOpca:=2,oDlg:End())ENABLE OF oDlg PIXEL
			
			
			ACTIVATE MSDIALOG oDlg CENTERED
			
			If nOpca == 1
				lBaixa:=.t.
				nValAgl+=nValBaixa+nValAcre-nValDesc
				ddatabase:=TRBC->DATAC
				aSe1Bx:={}
				//oRelation1:DeActivate()
				DbSelectArea('SE1')
				DbGoTo(TTRB->REC)
				
				
				cNaturLote:=SE1->E1_NATUREZ
				cFilant := SE1->E1_FILIAL
				cPref:=SE1->E1_PREFIXO
				cNum:=SE1->E1_NUM
				cParc:=SE1->E1_PARCELA
				cTipo:=SE1->E1_TIPO
				SE1->(DBCLOSEAREA())
				SE1->(DbSelectArea('SE1'))
				SE1->(DbGoTop())
				SE1->(DBSEEK(XfILIAL('SE1')+cPref +cNum+cParc+cTipo))
				aAdd(aSe1Bx, { "E1_PREFIXO"  , cPref 	            					 ,nil } )
				aAdd(aSe1Bx, { "E1_NUM"      , cNum      	        					 ,nil } )
				aAdd(aSe1Bx, { "E1_PARCELA"  , cParc               					 ,nil } )
				aAdd(aSe1Bx, { "E1_TIPO"     , cTipo    	        					 ,nil } )
				aAdd(aSe1Bx, { "AUTMOTBX"    , 'NOR'          							 ,nil } )
				aAdd(aSe1Bx, { "AUTDTBAIXA"  , ddatabase 										 ,nil } )
				aAdd(aSe1Bx, { "AUTDTCREDITO", ddatabase  									 ,nil } )
				aAdd(aSe1Bx, { "AUTHIST", "" , 'BAIXA CONCILIACAO' 					 ,nil } )
				aAdd(aSe1Bx, { "AUTVALREC"   , nValBaixa+nValAcre- nValDesc  ,nil } )
				aAdd(aSe1Bx, { "AUTMULTA"    , 0       						           ,nil } )
				aAdd(aSe1Bx, { "AUTJUROS"    , 0       						           ,nil } )
				aAdd(aSe1Bx, { "AUTACRESC"   , nValAcre   				           ,nil } )
				aAdd(aSe1Bx, { "AUTDESCONT"  , nValDesc   	  	             ,nil } )
				aAdd(aSe1Bx, { "AUTBANCO"    , TRBC->BANCO 				           ,nil } )
				aAdd(aSe1Bx, { "AUTAGENCIA"  , TRBC->Agencia	               ,nil } )
				aAdd(aSe1Bx, { "AUTCONTA"    , TRBC->Conta 		               ,nil } )
				
				/*	Pergunte("FIN070",.F.)
				DbSelectArea("SE5")
				mv_par08:=2   */
				lMSHelpAuto := .T.
				lMSErroAuto := .F.
				
				MSExecAuto({|v,x| FINA070(v,x) },aSe1Bx,3)
				
				If lMSErroAuto
					Mostraerro()
				Else
					confirmsx8()
					RecLock('SE5',.F.)
					SE5->E5_LOTE:=cLoteFin
					MsUnlock()
				EndIf
				
				
				
				dDtAux:=ddatabase
				
			EndIf
			
		EndIf
		
		
		TTRB->(dbSkip())
	EndDO
	
	If lBaixa
		
		RecLock( "SE5" , .T. )
		SE5->E5_FILIAL		:= xFilial()
		SE5->E5_BANCO 		:= TRBC->BANCO
		SE5->E5_AGENCIA		:= TRBC->Agencia
		SE5->E5_CONTA		:= TRBC->Conta
		SE5->E5_VALOR		:= nValAgl
		SE5->E5_RECPAG		:= "R"
		SE5->E5_HISTOR		:= "BAIXA DE TITULOS P/LOTE "+cLoteFin //BAIXA DE TITULOS P/LOTE 9999
		SE5->E5_DTDIGIT		:= TRBC->DATAC
		SE5->E5_DATA		:= TRBC->DATAC
		SE5->E5_NATUREZ		:= cNaturLote
		SE5->E5_TIPODOC		:= "BL"        // Baixa por Lote
		SE5->E5_LOTE		:= cLoteFin
		SE5->E5_MOEDA		:= '01'
		SE5->E5_DTDISPO 	:= TRBC->DATAC
		SE5->E5_RECONC		:='x'
		SE5->E5_CONTEXT   	:= TRBC->CONTEXT
		SE5->(MsUnlock())
		
		AtuSalBco( TRBC->BANCO , TRBC->Agencia, TRBC->Conta, TRBC->DATAC, nValAgl, "+" )
		
		
	EndIf
EndIf



//Fecha a Area e elimina os arquivos de apoio criados em disco.
TTRB->(DbCloseArea())
IIf(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
//oRelation1:Activate()

Return

Static Function Disp()
RecLock("TTRB",.F.)
If Marked("OK")
	TTRB->OK := cMarca
	NQTDTIT+=TTRB->Saldo
Else
	TTRB->OK := ""
	NQTDTIT-=TTRB->Saldo
EndIf
MsUnlock()
oQtda:Refresh()

oMark:oBrowse:Refresh()
Return

//Gera RA
Static Function GeraRA()
Private lAbort

ProcRegua(0)
DbSelectArea('TRBC')
DbGoTop()

While !TRBC->(EOF())
	
	IncProc("Processando RA")
	If !Empty(TRBC->OK)
		If Empty(TRBC->RECOR)
			If TRBC->TIPO=="C"
				//0632 -- andre/rsac 07/08
				If '117' $ Alltrim(TRBC->CATEGORIA) .OR. '120' $ Alltrim(TRBC->CATEGORIA).OR. '201' $ Alltrim(TRBC->CATEGORIA) .OR. ('209'$ Alltrim(TRBC->CATEGORIA)) .OR. '213'$ Alltrim(TRBC->CATEGORIA) .or. ('214' $ TRBC->CATEGORIA .AND. ('0027' $ TRBC->MOVIMENTO .or. '0632' $ TRBC->MOVIMENTO )) .or. ('205' $ TRBC->CATEGORIA .AND. !('900' $ TRBC->MOVIMENTO .or. '732' $ TRBC->MOVIMENTO .or. '0093' $ TRBC->MOVIMENTO.or. '0976' $ TRBC->MOVIMENTO .or. '0623' $ TRBC->MOVIMENTO )) // Andre/rsac 05/09/016
					lMsErroAuto:=.F.
					
					//	cNum:=GETSXENUM('SE1','E1_NUM')
					cSql:=" SELECT R_E_C_N_O_ REC,* 
					cSql+=" FROM "+RETSqlName('SE5')+" "
					cSql+=" WHERE   E5_CONTEXT ='"+TRBC->CONTEXT+"'"
					cSql+=" AND E5_VALOR ="+CVALTOCHAR(TRBC->VALOR)+""
					cSql+=" AND D_E_L_E_T_<>'*' "
					cSql+=" AND E5_RECPAG='R'"
					cSql+=" AND E5_TIPO <> 'CH' "//INCLUIDO -- 03/08/2016 -- ANDRE/RSAC -- TRATAR APENAS RA  -- ESTAVA BUSCANDO MOVIMENTOS DE CHEQUES INCLUIDOS MANUALMENTE NO SISTEMA.
					
					If Select('TEMARQ')<>0
						TEMARQ->(DBCloseArea())
					EndIf

					TCQuery cSql New Alias "TEMARQ"
					
					If TEMARQ->(EOF())
						cSql:= " SELECT TOP 1 E1_NUM 
						cSql+= " FROM "+RetSqlName('SE1')
						//Incluido Tipo RA --
						cSql+= " WHERE E1_TIPO = 'RA'
						cSql+= " ORDER BY E1_NUM DESC"
						
						If Select('TRN')<>0
							TRN->(DBCloseArea())
						EndIf
						
						Tcquery cSql New Alias 'TRN'
						If !TRN->(EOF())
							cNum:=SOMA1(TRN->E1_NUM)
						EndIf
						
						aVetor := { {"E1_FILIAL"   , xFilial('SE1'),Nil, Nil},;
									{"E1_PREFIXO"   , '   '            			,Nil, Nil},;
									{"E1_NUM"      ,  cNum        	    		,Nil, Nil},;
									{"E1_PARCELA"  ,  ''        				,Nil, Nil},;
									{"E1_TIPO"     , 'RA'          		 		,Nil, Nil},;
									{"E1_NATUREZ"  , '10301'        		 	,Nil, Nil},;
									{"E1_CLIENTE"  , '000063'           		,Nil, Nil},;
									{"E1_LOJA"     , '00'           		 	,Nil, Nil},;
									{"E1_EMISSAO"  , TRBC->DATAC        		,Nil, Nil},;
									{"E1_VENCTO"   , TRBC->DATAC        		,Nil, Nil},;
									{"CBCOAUTO"  , TRBC->BANCO        		,Nil, Nil},; //Andre/Rsac - 14.11.2018 - alterado variavel para geração de RA  conforme documentação (http://tdn.totvs.com/display/public/PROT/FIN0088_CREC_FINA040_ExecAuto_Inclusao_de_RA_por_rotina_automatica)
									{"CAGEAUTO"   , TRBC->Agencia      		,Nil, Nil},; //Andre/Rsac - 14.11.2018 - alterado variavel para geração de RA  conforme documentação (http://tdn.totvs.com/display/public/PROT/FIN0088_CREC_FINA040_ExecAuto_Inclusao_de_RA_por_rotina_automatica)
									{"CCTAAUTO"    , TRBC->Conta        		,Nil, Nil},; //Andre/Rsac - 14.11.2018 - alterado variavel para geração de RA  conforme documentação (http://tdn.totvs.com/display/public/PROT/FIN0088_CREC_FINA040_ExecAuto_Inclusao_de_RA_por_rotina_automatica)
									{"E1_HIST"     , TRBC->HIST       	 		,Nil, Nil},;
									{"E1_XINFO"    , Substr(TRBC->HIST,1,255)  	,Nil, Nil},;
									{"E1_XINFOKA"  , TRBC->HIST				    ,Nil, Nil},;
									{"E1_VALOR"    , TRBC->VALOR        		,Nil, Nil }}
						lMsErroAuto:=.f.
						MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao
						
						If lMsErroAuto
							DisarmTransaction()
							Mostraerro()
						Else
							ConfirmSX8()
							DbSelectArea('SE5')
							DbSetOrder(7)
							//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA+E5_SEQ
							If dbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
								RecLock("SE5",.f.)
								SE5->E5_RECONC := "x"
								SE5->E5_CONTEXT   := TRBC->CONTEXT
								MsUnlock()
								
								RecLock('TRBC',.F.)
								TRBC->RECOR	:= SE5->(RECNO())
								TRBC->(MsUnlock())

							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	TRBC->(dbSkip())
EndDo

AFIN001B() //Processa o extrato
Return


Static Function PagCart()
Local CPERG		:="AFIN001CAR"
Private lAbort

If !Pergunte(cPerg,.t.)
	Return
EndIf

ProcRegua(0)
DbSelectArea('TRBC')
DbGoTop()

While !TRBC->(EOF())
	IncProc("Processando")
	If !Empty(TRBC->OK)
		
		If "CARTAO"$TRBC->HIST .AND. "COMPRA"$TRBC->HIST
			
			cSql:=" Select Count(*) cont from "+RETSQLNAME('SE5')
			cSql+=" WHERE E5_CONTEXT ='"+TRBC->CONTEXT+"'"
			cSql+=" and E5_VALOR ='"+cvaltochar(TRBC->VALOR)+"'"
			cSql+=" AND D_E_L_E_T_<>'*'"
			If Select('TEME5')<>0
				TEME5->(DBCloseArea())
			EndIf
			TcQuery cSql New ALias "TEME5"
			
			If TEME5->cont >0
				TRBC->(DBSkip())
				loop
			EndIf
			
			/*GERAR CONTAS A PAGAR E BAIXAR*/
			
			//ROTINA AUTOMATICA CONTAS A PAGAR
			
			DDATAAUX:=DDATABASE
			DDATABASE:=TRBC->DATAC
			cNum:=GETSXENUM('SE1','E1_NUM')
			aTitulo:= {{"E2_FILIAL"     , '01'          ,   Nil},;
			{"E2_PREFIXO" 	, 'MAN'         ,   Nil},;
			{"E2_NUM"       , cNum   ,   Nil},;
			{"E2_PARCELA"   , ''            ,   Nil},;
			{"E2_TIPO"      , 'TF'          ,   Nil},;
			{"E2_FORNECE"   , mv_par01      ,   Nil},;
			{"E2_LOJA"      , mv_par02      ,   Nil},;
			{"E2_NATUREZ"   , '21301'       ,   Nil},;
			{"E2_EMISSAO"   , DDATABASE     ,   NIL},;
			{"E2_VENCTO" 		, DDATABASE     ,   NIL},;
			{"E2_VENCREA"   , DDATABASE     ,   NIL},;
			{"E2_VALOR"     , TRBC->VALOR   ,   Nil},;
			{"E2_HIST"      , TRBC->HIST    ,   Nil}};
			
			nOpc        := 3    // Inclusao
			lMsErroAuto := .F.
			lOnline:=.T.
			MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,nOpc)
			
			If lMsErroAuto
				Mostraerro()
				
			Else
				aTitulo := {}
				
				aAdd(aTitulo, {"E2_PREFIXO"  , SE2->E2_PREFIXO		, Nil})
				aAdd(aTitulo, {"E2_NUM"      , SE2->E2_NUM 			, Nil})
				aAdd(aTitulo, {"E2_PARCELA"  , SE2->E2_PARCELA		, Nil})
				aAdd(aTitulo, {"E2_TIPO"     , SE2->E2_TIPO   		, Nil})
				aAdd(aTitulo, {"E2_FORNECE"  , SE2->E2_FORNECE		, Nil})
				aAdd(aTitulo, {"E2_LOJA"     , SE2->E2_LOJA   		, Nil})
				aAdd(aTitulo, {"AUTMOTBX"    , 'DEB'        			, Nil})
				aAdd(aTitulo, {'AUTBANCO'    , TRBC->BANCO       	, Nil})
				aAdd(aTitulo, {'AUTAGENCIA'  , TRBC->Agencia  	  , Nil})
				aAdd(aTitulo, {'AUTCONTA'    , TRBC->Conta       	, Nil})
				aAdd(aTitulo, {"AUTDTBAIXA"  , DDATABASE         	, Nil})
				aAdd(aTitulo, {"AUTDTCREDITO", DDATABASE         	, Nil})
				aAdd(aTitulo, {"AUTHIST"     , 'BAIXA CONCILIACAO ' , Nil})
				aAdd(aTitulo, {"AUTJUROS"    , 0               	    , Nil})
				aAdd(aTitulo, {"AUTVLRPG"    , TRBC->VALOR          , Nil})
				lMsErroAuto:=.f.
				//	lNoMbrowse := .T.
				MSExecAuto({|x,y| Fina080(x,y)}, aTitulo, 3)
				If lMsErroAuto
					Mostraerro()
				Else
					DbSelectArea('SE5')
					DBSetOrder(7)
					If DBSeek(xFIlial('SE5')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
						RecLock('SE5',.f.)
						SE5->E5_RECONC:='S'
						SE5->E5_CONTEXT   := TRBC->CONTEXT
						MsUnlock()
					EndIf
				EndIf
				DDATABASE:=	DDATAAUX
			EndIf
		EndIf
	EndIf
	
	
	
	
	TRBC->(dbSkip())
EndDo
oMBrowseLeft:REFRESH()

cPerg		:= "AFIN001a"


If !Pergunte(cPerg,.F.)
	Return
EndIf

AFIN001B() //Extrato

Return()

//Processa RA/PA e extrato
Static Function GeraMt()
Private lAbort

ProcRegua(0)
DbSelectArea('TRBC')
TRBC->(DbGoTop())

While !TRBC->(EOF())
	
	IncProc("Processando Mutuos")
	
	If !Empty(TRBC->OK) //Se marcado

		If Empty(TRBC->RECOR)  //Senao foi gerado movimento bancario, caso contrario o sistema marca o recno da SE5

			If TRBC->TIPO == "C" //Se for um credito

				lMsErroAuto := .F.

				cSql:= " SELECT TOP 1 E1_NUM 
				cSql+= " FROM "+RetSqlName('SE1')
				cSql+= " ORDER BY E1_NUM DESC"
				If Select('TRN') <> 0
					TRN->(DBCloseArea())
				EndIf
				Tcquery cSql New Alias 'TRN'
				
				If !TRN->(EOF())
					cNum := SOMA1(TRN->E1_NUM)
				EndIf
				
				_lOk := .F.
				
				_Cliente := Space(TamSX3('A1_COD')[1])
				_Loja	 := Space(TamSX3('A1_LOJA')[1])
				_nome	 := Space(TamSX3('A1_NOME')[1])
				
				
				_cHistr := Alltrim("Valor do movimento: "+ Transform(TRBC->VALOR,"@E 999,999,999.99") + " - "+ TRBC->HIST)
				
				DEFINE MSDIALOG oDlgFundo TITLE "[Geracao de Mutuos]" From 001,001 to 200,700 Pixel
				
				@ 05, 005 SAY  	"Cliente"  SIZE 050, 007 OF  oDlgFundo  PIXEL
				@ 04, 030 MSGET _oCliente 	VAR _Cliente SIZE  40, 010 f3 'SA1' WHEN .T. VALID VECLI(_Cliente,_Loja)   OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				@ 05, 070 SAY  "Loja"  		SIZE 050, 007 OF  oDlgFundo  PIXEL
				@ 04, 090 MSGET _oLoja 		VAR _Loja SIZE 40, 010 WHEN .t. VALID VECLI(_Cliente,_Loja) OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				@ 04, 150 MSGET _oNome 		VAR _nome SIZE 150, 010 WHEN .F. OF  oDlgFundo COLORS 0, 16777215 PIXEL
				@ 19, 005 SAY  "Descricao"  SIZE 050, 007 OF  oDlgFundo  PIXEL
				
				@ 20, 030 MSGET _oHist 		VAR _cHistr SIZE 250, 010 WHEN .F. OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				ACTIVATE MSDIALOG  oDlgFundo CENTERED ON INIT (EnchoiceBar(oDlgFundo,{||_lOk:=.t.,  oDlgFundo:End()},{||_lOk:=.F.,oDlgFundo:End()}))
				
				If _lOk
					aVetor := { {"E1_FILIAL"   , xFilial('SE1')     ,Nil, Nil},;
								{"E1_PREFIXO"  , 'MT'             	,Nil, Nil},;
								{"E1_NUM"      ,  cNum        	    ,Nil, Nil},;
								{"E1_PARCELA"  ,  ''        		,Nil, Nil},;
								{"E1_TIPO"     , 'RA'          		,Nil, Nil},;
								{"E1_NATUREZ"  , '10601'        	,Nil, Nil},;
								{"E1_CLIENTE"  , _Cliente           ,Nil, Nil},;
								{"E1_LOJA"     , _Loja          	,Nil, Nil},;
								{"E1_EMISSAO"  , TRBC->DATAC        ,Nil, Nil},;
								{"E1_VENCTO"   , TRBC->DATAC        ,Nil, Nil},;
								{"E1_PORTADO"  , TRBC->BANCO        ,Nil, Nil},;
								{"E1_AGEDEP"   , TRBC->Agencia      ,Nil, Nil},;
								{"E1_CONTA"    , TRBC->Conta        ,Nil, Nil},;
								{"E1_HIST"     , TRBC->INFO       	,Nil, Nil},;
								{"E1_VALOR"    , TRBC->VALOR        ,Nil, Nil }}
					lMsErroAuto:=.f.
					MSExecAuto({|x,y| Fina040(x,y)},aVetor,3) //Inclusao de RA
					
					If lMsErroAuto
						DisarmTransaction()
						Mostraerro()
					Else
						ConfirmSX8()
						DbSelectArea('SE5')
						DbSetOrder(7)
						//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA+E5_SEQ
						If dbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
							RecLock("SE5",.f.)
							SE5->E5_RECONC 	:= "x"
							SE5->E5_CONTEXT := TRBC->CONTEXT
							MsUnlock()
						EndIf
					EndIf
				EndIf
				
			Else //Se for Débito...

				lMsErroAuto :=.F.
				cSql := " SELECT TOP 1 E2_NUM 
				cSql += " FROM "+RetSqlName('SE2')
				cSql += " ORDER BY E2_NUM DESC"
				If Select('TRN')<>0
					TRN->(DBCloseArea())
				EndIf

				Tcquery cSql New Alias 'TRN'
				
				If !TRN->(EOF())
					cNum :=SOMA1(TRN->E2_NUM)
				EndIf
				
				_lOk := .F.
				
				_Cliente:= Space(TamSX3('A1_COD')[1])
				_Loja	:= Space(TamSX3('A1_LOJA')[1])
				_nome	:= Space(TamSX3('A1_NOME')[1])
				
				
				_cHistr := Alltrim("Valor do movimento: "+transform(TRBC->VALOR,"@E 999,999,999.99")+ " - "+TRBC->HIST)

				DEFINE MSDIALOG oDlgFundo TITLE "[Geracao de Mutuos]" From 001,001 to 200,700 Pixel
				
				@ 05, 005 SAY  "Fornece"  	SIZE 050, 007 OF  oDlgFundo  PIXEL
				@ 04, 030 MSGET _oCliente 	VAR _Cliente SIZE  40, 010 f3 'SA2' WHEN .T. VALID VEFor(_Cliente,_Loja) OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				@ 05, 070 SAY  "Loja"  		SIZE 050, 007 OF  oDlgFundo  PIXEL
				@ 04, 090 MSGET _oLoja 		VAR _Loja SIZE 40, 010 WHEN .t. VALID VEFor(_Cliente,_Loja) OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				@ 04, 150 MSGET _oNome 		VAR _nome SIZE 150, 010 WHEN .F. OF  oDlgFundo COLORS 0, 16777215 PIXEL
				@ 19, 005 SAY  "Descricao"  SIZE 050, 007 OF  oDlgFundo  PIXEL
				
				@ 20, 030 MSGET _oHist 		VAR _cHistr SIZE 250, 010 WHEN .F. OF  oDlgFundo COLORS 0, 16777215 PIXEL
				
				ACTIVATE MSDIALOG  oDlgFundo CENTERED ON INIT (EnchoiceBar(oDlgFundo,{||_lOk:=.t.,  oDlgFundo:End()},{||_lOk:=.F.,oDlgFundo:End()}))
				
				If _lOk
					aVetor := { {"E2_FILIAL"   , xFilial('SE2')     ,Nil, Nil},;
								{"E2_PREFIXO"   , 'MT'              ,Nil, Nil},;
								{"E2_NUM"      ,  cNum        	    ,Nil, Nil},;
								{"E2_PARCELA"  ,  ''        		,Nil, Nil},;
								{"E2_TIPO"     , 'PA'          		,Nil, Nil},;
								{"E2_NATUREZ"  , '10601'        	,Nil, Nil},;
								{"E2_CLIENTE"  , _Cliente           ,Nil, Nil},;
								{"E2_LOJA"     , _Loja          	,Nil, Nil},;
								{"E2_EMISSAO"  , TRBC->DATAC        ,Nil, Nil},;
								{"E2_VENCTO"   , TRBC->DATAC        ,Nil, Nil},;
								{ "AUTBANCO"   , TRBC->BANCO   		,Nil, Nil},;
								{ "AUTAGENCIA" , TRBC->Agencia      ,Nil, Nil},;
								{ "AUTCONTA"   , TRBC->Conta   		,Nil, Nil},;
								{"E2_HIST"     , TRBC->INFO       	,Nil, Nil},;
								{"E2_VALOR"    , TRBC->VALOR        ,Nil, Nil}}
					lMsErroAuto:=.f.
					MSExecAuto({|x,y| FINA050(x,y)},aVetor,3) //Inclusao de PA
					
					If lMsErroAuto
						DisarmTransaction()
						Mostraerro()
					Else
						ConfirmSX8()
						DbSelectArea('SE5')
						DbSetOrder(7)
						//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIfOR+E5_LOJA+E5_SEQ
						If DbSeek(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
							RecLock("SE5",.f.)
							SE5->E5_RECONC := "x"
							SE5->E5_CONTEXT   := TRBC->CONTEXT
							MsUnlock()
						EndIf
					EndIf
				EndIf
				
			EndIf
		EndIf
	EndIf
	TRBC->(dbSkip())
EndDo

AFIN001B()
Return()


Static Function VECLI(_cli,_loja)

If Empty(_cli+_loja)
	Alert('Campo obrigatorio')
	Return .f.
EndIf
_nome:=posicione('SA1',1,xFilial('SA1')+_cli+_loja,'A1_NOME')

Return .t.

Static Function VEfor(_cli,_loja)

If Empty(_cli+_loja)
	Alert('Campo obrigatorio')
	Return .f.
EndIf
_nome:=posicione('SA2',1,xFilial('SA2')+_cli+_loja,'A2_NOME')

Return .t.



Static Function MONTATMPE5(lAtu)
Default lAtu :=.f.
DbSelectArea( 'SE5' )

//If !lIndice
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra o arquivo por tipo e vencimento							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndex	:= CriaTrab(nil,.f.)
	cChave	:= IndexKey()
	cCond	:= ""
	cCond += " DTOS(E5_DATA) == '"+ DTOS(TRBC->DATAC) +"'"
	cCond += " .AND. E5_BANCO =='"+ Alltrim(TRBC->BANCO) +"'"
	cCond += " .AND. Alltrim(E5_AGENCIA) == '"+Alltrim(TRBC->Agencia)+"'"
	cCond += " .AND. Alltrim(E5_CONTA) == '"+Alltrim(TRBC->Conta)+ "'"
	//cCond += '.AND.	( Alltrim(E5_CONTEXT)=="'+Alltrim(TRBC->CONTEXT)+'" .OR. EMPTY(E5_CONTEXT) ) '
	cCond += ".AND.	!E5_TIPODOC $ 'BA/MT'"
	If lValor
		cCond +=  ".AND. E5_VALOR>="+str(TRBC->VALOR-10)
		cCond +=  ".AND. E5_VALOR<="+str(TRBC->VALOR+10) 
	EndIf

	IndRegua("SE5",cIndex,cChave,,cCond,"Selecionando Registros...")
	lIndice := .t.
//EndIf

nIndex := RetIndex("SE5")
DbSelectArea("SE5")
#IfNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#EndIf
dbSetOrder(nIndex+1)
DbGoTop()
nrec := SE5->(RECNO())

nValDeb		:=0
nValCred	:=0
nValorConc	:=0
nQtdTitConc	:=0

DbGoTop()
While !EOF()
	If !Empty(E5_SEL) .or. !Empty(E5_RECONC)
		RecLock("SE5")
		REPLACE E5_SEL with cMarca
		If E5_RECPAG=='R'
				nValorConc += SE5->E5_VALOR
				nValDeb 	 += SE5->E5_VALOR
			Else
				nValorConc -= SE5->E5_VALOR
				nValCred   += SE5->E5_VALOR
		EndIf
		nQtdTitConc ++
	EndIf
	dbSkip()
Enddo
//If lAtu
DbGoTop()
/*
If aScan(aDtSaldo,{|x|x[1]==TRBC->DATAC})<>0
nSaldoIni:=aDtSaldo[aScan(aDtSaldo,{|x|x[1]==TRBC->DATAC})][2]
nValorArq:=aDtSaldo[aScan(aDtSaldo,{|x|x[1]==TRBC->DATAC})][3]

nValorMov :=nSaldoIni-nValorArq
Else
nSaldoIni:=0
nValorArq:=0
nValorMov :=nSaldoIni-nValorArq
EndIf
*/
oSaldoIni:refresh()
oValorMov:refresh()
oValorArq:refresh()
oValDeb:refresh()
oValCred:refresh()
oQtda:refresh()
oValor:refresh()
DbGoTo(nRec)

//EndIf

Return

//Funcao para fazer a transferencia 
Static Function FAZTRANSF()
dDTAUX		:= DDATABASE
DDATABASE	:= TRBC->DATAC

Pergunte("AFI100",.F.)
FA100TRAN('SE5',0,7) //Transferencia entre bancos/agencias

DDATABASE := dDTAUX

cPerg		:= "AFIN001a"
Pergunte(cPerg,.F.)

Return()
