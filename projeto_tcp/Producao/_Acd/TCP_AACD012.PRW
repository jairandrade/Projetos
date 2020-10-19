#include "apwebex.ch"
#include 'protheus.ch'
 
#define CAB 1
#define ITN 2


User Function AACD012()

Private cCadastro 	:= "Checkout de Material"
Private aRotina 	:= {}
Private cAlias 		:= "CB7"
	
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  , "AxPesqui"   	,0,1})  
	AADD(aRotina,{"Visualizar" , "AxVisual" 	,0,2})
	AADD(aRotina,{"Checkout"   , "U_AACD012I" 	,0,4})
	AADD(aRotina,{"Excluir"    , "U_AACD011" 	,0,5})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,)
	

Return   
              
User Function AACD012I(cAlias,nReg,nOpc)			
	Local aObjects  	:= {} 
	Local aPosObj   	:= {} 
	Local aSizeAut  	:= MsAdvSize()             
	Local aButtons 		:= {}            

	Private cOrdSep		:= CB7->CB7_ORDSEP			
	Private cOP			:= CB7->CB7_OP

	Private cCadastro 	:= 'Checkout' 
	Private oGet
		
	static oDlgI           	

	IF !VldCodSep()
		Alert('Ordem de sepação não apta a operar!')
		Return .F.
	EndIF
	
	IF CB7->CB7_LIBOK != 'L'
		Alert("Ordem de separacao não liberada.")
		Return
	EndIf


	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
	@ 005, 005 group oGrpCabec to 030, 505 prompt ' Ordem de Separação ' of oDlgI	color 0,16777215 pixel
	@ 017, 010 say 'Ordem de Separação	' 	size 053, 010 pixel  
	@ 015, 065 get cOrdSep 					size 040, 010 when .F. pixel 	
	@ 017, 120 say 'Ordem de Serviço	' 	size 053, 010 pixel  
	@ 015, 175 get cOP 					size 040, 010 when .F. pixel 	

	
	@ 040, 005 group oGrpVisual to 325, 505 prompt ' Itens ' of oDlgI color 0,16777215 pixel		
		GRIDCRIT(nOpc) // Grid de Itens  

	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(CONFIRMAR(nOpc),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.


Static Function Confirmar(nOpc)
	Local nI
	Local lRet			:= .T.
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .t.

	Private cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))

	Private nSaldoCB8   := 0                    	
	Private cVolume     := Space(10)
	Private cCodSep     := Space(6)

	Begin transaction

	For nI := 1 to len(oGet:aCols)             
		cProduto 	:= oGet:aCols[nI][1]
		cLote		:= oGet:aCols[nI][4]
		cNumSer 	:= "" 
//		cLocal		:= oGet:aCols[nI][4] 
//		cLocaliz	:= oGet:aCols[nI][5] 
		nQuantidade	:= oGet:aCols[nI][3] 	                 
		
		If Empty(Alltrim(Posicione('SB1',1,xFilial('SB1')+cProduto,"B1_DESC")))
			Alert('O código de produto '+cProduto+' é invalido!')
			DisarmTransaction()
			lRet := .F.
			Exit
		EndIf
		
		If oGet:aCols[nI][3] <= 0 
			Alert('As quantidades devem ser maiores que zero!')
			DisarmTransaction()
			lRet := .F.
			Exit		
		EndIf
 
/*
		If Empty(Alltrim(Posicione('SB2',1,xFilial('SB2')+cProduto+cLocal,"B2_LOCAL"))) .AND. SB2->B2_QATU <= 0.00
			Alert('Não existe quantidade do produto '+cProduto+' para o armazém informado!')
			DisarmTransaction()
			Return	.F.		
		EndIf
*/
/*
		If !Empty(cLocaliz) .AND. Empty(Alltrim(Posicione('SBF',1,xFilial('SBF')+cLocal+cLocaliz+cProduto+cLote,"BF_LOCALIZ"))) .AND. SBF->BF_QUANT - SBF->BF_EMPENHO <= 0
			Alert('Não existe quantidade do produto '+cProduto+' para o endereço/lote informado!')
			DisarmTransaction()
			Return	.F.		
		EndIf
*/
		
		If !ExisteNaOrdem(cProduto,cLote,cNumSer)    
			Alert('Não existe quantidade do produto '+cProduto+' para o endereço/lote informado nesta ordem!')
			DisarmTransaction()
			lRet := .F.
			Exit			
		EndIf
				
		IF !GravaEntrega(cProduto, cLote, cNumSer, nQuantidade)
			Alert('Quantidade informada inválida!')
			DisarmTransaction()
			lRet := .F.
			Exit
		EndIF

	Next
	
	If lRet
		lRet := EncerraEntrega(.T.)
	EndIf
	
	If !lRet 
		DisarmTransaction()
		lRet := .F.
	EndIf

	End Transaction


Return lRet



Static Function VldCodSep()

	Local lRet := .T.


	If CB7->CB7_STATUS == "3"
		Alert("Ordem de separacao em processo de embalagem")
		Return .F.
	EndIf

	If !(!Empty(CB7->CB7_OP) .Or. CBUltExp(CB7->CB7_TIPEXP) $ "00*01*") .And. CB7->CB7_STATUS == "9"
		Alert("Ordem de separacao ja Embarcada")
		Return .F.
	EndIf

Return lRet


Static Function GravaEntrega(cProduto, cLote, cNumSer, nQuantidade)
	Local n1
	Local aItens := {}
	Local nQtdEnt := nQuantidade

	CB8->( dbSetOrder(7) )
	CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

	While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)

		//produto tem que ser o mesmo
		IF Alltrim(CB8->(CB8_PROD+CB8_LOTECT+CB8_NUMSER)) == Alltrim(cProduto + cLote + cNumSer)

			//se já foi separado (quantidade a separar - saldo a separar)
			IF CB8->(CB8_QTDORI-CB8_QTDENT) > 0
				//se já foi entregue (quantidade a separar - saldo a separar - quantidade entregue)
				IF CB8->(CB8_SALDOS) - nQuantidade >= 0
					aAdd(aItens, { CB8->(Recno()), nQuantidade })
					nQtdEnt -= nQuantidade
				EndIF
			EndIF
		EndIF

		CB8->( dbSkip() )
	EndDO

	IF nQtdEnt > 0
		Return .F.
	Else
		For n1 := 1 to len(aItens)
			CB8->( dbGoTo( aItens[n1][1] ) )

			//grava quantidade separada
			RecLock("CB8",.F.)
			CB8->CB8_QTDENT += aItens[n1][2]  
			CB8->CB8_SALDOS -= aItens[n1][2]  			
			CB8->( MsUnLock())

			RecLock("ZD3",.T.)
			ZD3->ZD3_FILIAL := xFilial("ZD3")
			ZD3->ZD3_ORDEM  := ""
			ZD3->ZD3_ORDSEP := CB7->CB7_ORDSEP
			ZD3->ZD3_CODOPE := '000009' //////////////////////////// precisa ver de onde pega o operador
			ZD3->ZD3_ITEM   := CB8->CB8_ITEM
			ZD3->ZD3_PROD   := CB8->CB8_PROD
			ZD3->ZD3_LOCAL  := CB8->CB8_LOCAL
			ZD3->ZD3_LOTECT := CB8->CB8_LOTECT
			ZD3->ZD3_LOCALI := CB8->CB8_LCALIZ
			ZD3->ZD3_NUMSER := CB8->CB8_NUMSER
			ZD3->ZD3_QTESEP := aItens[n1][2]
			ZD3->( MsUnLock())
		Next
	EndIF

Return .T.

Static Function EncerraEntrega(lAuto)

	Local cNumEntrega := NextNumero("ZD3",2,"ZD3_ORDEM",.T.)
	Local lEntregou := .F.

	ZD3->( dbSetOrder(1) )
	ZD3->( dbSeek( xFilial("ZD3") + cOrdSep ) )


	While !ZD3->( Eof() ) .And. ZD3->(ZD3_FILIAL+ZD3_ORDSEP) == xFilial("ZD3")+cOrdSep

		IF Empty(ZD3->ZD3_ORDEM)
			RecLock("ZD3",.F.)
			ZD3->ZD3_ORDEM := cNumEntrega
			ZD3->( MsUnLock())

			lEntregou := .T.
		EndIF

		ZD3->( dbSkip() )
	EndDO


	IF lEntregou
		MsgInfo("Ordem de Entrega " + cNumEntrega + " gerada com sucesso.")
		RequisitOP(cNumEntrega, .F.)
	ElseIF !lAuto
		Alert("Não existe itens separados para entregar.")
	EndIF

Return lEntregou


Static Function ExisteNaOrdem(cProduto,cLote,cNumSerie)

	Local lExist := .F.

	CB8->( dbSetOrder(7) )
	CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

	While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP) .And. !lExist

		//produto tem que ser o mesmo
		IF CB8->CB8_PROD == cProduto
			//se tem lote
			IF !Empty(cLote)
				//compara se é o mesmo lote
				IF CB8->CB8_LOTECT == cLote
					//se tiver numero de serie
					IF !Empty(cNumSerie)
						//compra se é o mesmo numero de serie
						IF CB8->CB8_NUMSER == cNumSerie
							lExist := .T.
							Loop
						EndIF
					Else
						lExist := .T.
						Loop
					EndIF
				EndIF
			//se apenas numero de serie
			ElseIF !Empty(cNumSerie)
				//compra se é o mesmo numero de serie
				IF CB8->CB8_NUMSER == cNumSerie
					lExist := .T.
					Loop
				EndIF
			Else
				lExist := .T.
				Loop
			EndIF

		EndIF

		CB8->( dbSkip() )
	EndDO

Return lExist

/*
	Executa rotina automatica de requisicao - MATA240
*/
Static Function RequisitOP(cNumEntrega)

	Local aMata241 		:= {{/*cabeçalho*/},{/*itens*/}}
	Local nModuloOld 	:= nModulo
	Local aCB8       	:= CB8->( GetArea("CB8") )
	Local aSTJ			:= STJ->( GetArea("STJ") )
	Local cTrt       	:= ""
	Local n1         	:= 0

	Local cScript 		:= ""
	Local cDocumento 	:= ""	

	Local cCtaCtb		:= Space(TamSx3("D3_CONTA")[01])
	Local cIteCtb		:= Space(TamSx3("D3_ITEMCTA")[01])
	Local cRequis		:= Space(TamSx3("D3_REQUISI")[01])
	Local cCCusto		:= Space(TamSx3("D3_CC")[01])
	
	Local aRetUsrs := AllUsers()


	Private cTM     	:= GetMV("MV_CBREQD3")
	Private nModulo  	:= 4

		ZD3->( dbSetOrder(2) )
		ZD3->( dbSeek( xFilial("ZD3") + cNumEntrega + cOrdSep ) )
		
		dbSelectArea("STJ")
		STJ->(dbSetOrder(1))

		cDocumento := NextDoc()

		//cabeçalho da requisição
	 	aAdd( aMata241[CAB], {"D3_DOC"    , cDocumento, Nil})
	 	aAdd( aMata241[CAB], {"D3_TM"     , cTM       , Nil})
	 	aAdd( aMata241[CAB], {"D3_EMISSAO", dDataBase , Nil})

		While !ZD3->( Eof() ) .And. ZD3->(ZD3_FILIAL+ZD3_ORDEM+ZD3_ORDSEP) == xFilial("ZD3") + cNumEntrega + cOrdSep

			CB8->( dbSetOrder(4) )
			CB8->( dbSeek( xFilial("CB8") + ZD3->(ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCAL+ZD3_LOCALI+ZD3_LOTECT+Space(6)+ZD3_NUMSER) ) )

			SB1->( dbSetOrder(1) )
			SB1->( dbSeek( xFilial("SB1") + ZD3->ZD3_PROD ) )
			
			STJ->( dbGoTop() )
			cCtaCtb := GTRIGGER(Posicione("ST9",1,xFilial('ST9')+STJ->TJ_CODBEM,"T9_ZITEMCT"),SB1->B1_GRUPO)
			

			aAdd(aMata241[ITN],{})
			aAdd( aTail(aMata241[ITN]), {"D3_COD"    	,ZD3->ZD3_PROD    	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_UM"     	,SB1->B1_UM       	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_QUANT"  	,ZD3->ZD3_QTESEP  	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_LOCAL"  	,ZD3->ZD3_LOCAL   	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_LOCALIZ"	,ZD3->ZD3_LOCALI  	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_NUMSERI"	,ZD3->ZD3_NUMSER  	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_LOTECTL"	,ZD3->ZD3_LOTECT  	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_OP"     	,CB8->CB8_OP      	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_EMISSAO"	,dDataBase        	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_TRT"    	,CB8->CB8_TRT     	,nil})

			aAdd( aTail(aMata241[ITN]), {"D3_CONTA"    	,cCtaCtb/*cCtaCtb*/	    	,nil})
			aAdd( aTail(aMata241[ITN]), {"D3_ITEMCTA"   ,Posicione("ST9",1,xFilial('ST9')+STJ->TJ_CODBEM,"T9_ZITEMCT")		,nil})
	          
	  		nPosUsr := aScanx ( aRetUsrs, {|x| x[1,2] == Alltrim(Posicione('STJ',1,xFilial('STJ')+SubStr(CB7->CB7_OP,1,Len(STJ->TJ_ORDEM)),"TJ_USUAINI"))}) // aqui procuro pelo e-mail do usuario
	        If nPosUsr > 0
	        	cUsrReq := aRetUsrs[nPosUsr][1][1] 
	        Else
	        	cUsrReq := ""
	        EndIf	
	
			aAdd( aTail(aMata241[ITN]), {"D3_REQUISI"   ,   cUsrReq ,nil})

			If !Empty(Alltrim(STJ->TJ_XCC))
				aAdd( aTail(aMata241[ITN]), {"D3_CC"   		,STJ->TJ_XCC 		,nil})
			Else
				aAdd( aTail(aMata241[ITN]), {"D3_CC"   		,STJ->TJ_CCUSTO 	,nil})
			EndIf
			aAdd( aTail(aMata241[ITN]), {"D3_ORDEM"   	,STJ->TJ_ORDEM 		,nil})

			ZD3->( dbSkip() )
		EndDO


		lMSErroAuto := .F.
		lMSHelpAuto := .T.

		SD3->(DbSetOrder(1))

		MSExecAuto({|x,y|MATA241(x,y)},aMata241[CAB],aMata241[ITN],3)

		lMSHelpAuto := .F.
		IF	lMSErroAuto

			Alert("Falha na gravacao movimentacao TM "+cTM) //
			MostraErro()
			DisarmTransaction()
			Break
		Else


			cScript := " UPDATE " + RetSqlName("ZD3")
			cScript += " SET ZD3_DOC = '" + cDocumento + "'"
			cScript += " WHERE"
			cScript += "     ZD3_FILIAL = '" + xFilial("ZD3") + "' "
			cScript += " AND ZD3_ORDSEP = '" + cOrdSep + "' "
			cScript += " AND ZD3_ORDEM  = '" + cNumEntrega + "' "
			cScript += " AND D_E_L_E_T_ = ' ' "

			TCSQLExec(cScript)
		EndIF

		nModulo := nModuloOld


	CB8->(RestArea(aCB8))
	STJ->(RestArea(aSTJ))

Return !lMSErroAuto

Static Function GTRIGGER(cItem,cGrupo)

	Local aAreaSD3 	:= SD3->(GetArea())
	Local cRet		:= ""

	Private M->D3_ITEMCTA 	:= cItem
	Private M->D3_GRUPO		:= cGrupo
	Private M->D3_CONTA 	:= Criavar("D3_CONTA")

	If ExistTrigger("D3_ITEMCTA") 
		RunTrigger(1,,,,"D3_ITEMCTA")
	Endif

	cRet := M->D3_CONTA

	RestArea(aAreaSD3)

Return cRet

Static Function NextDoc()
	Local aSvAlias:=GetArea()
	Local aSvAliasD3:=GetArea("SD3")
	Local cDoc := Space(TamSx3("D3_DOC")[1])

	SD3->(DbSetOrder(2))
	cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	While SD3->(DbSeek(xFilial("SD3")+cDoc))
		cDoc := Soma1(cDoc,Len(SD3->D3_DOC))
	Enddo

	RestArea(aSvAliasD3)
	RestArea(aSvAlias)
Return cDoc

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT(nOpc)
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'D3_COD', 'D3_DESC' ,'D3_QUANT', 'D3_LOTE' }
	local aFieldFill	:= {}
	local aAlterFields	:= {'D3_COD', 'D3_QUANT', 'D3_LOTE' }
	Local aField := {}
	Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																			cField,;
																			X3PICTURE(cField),; 
																			TamSX3(cField)[1],;
																			TamSX3(cField)[2],;
																			GetSx3Cache(cField, "X3_VALID"),;
																			GetSx3Cache(cField, "X3_USADO"),;
																			FwSX3Util():GetFieldType(cField),;
																			X3F3(cField),;
																			GetSx3Cache(cField, "X3_CONTEXT"),;
																			X3CBOX(cField),;
																			GetSx3Cache(cField, "X3_RELACAO");
																			}))}
	aEval(aFields,bBlock)
	aHeader := aClone(aField)

	aEval(aHeader,{|aCampo,nI| aAdd(aFieldFill,If(FieldPos(aCampo[nI,2])>0,CriaVar(aCampo[nI,2],.F.),nil))})
	aAdd(aFieldFill, .f.)
	
	aAdd(aCols, aClone(aFieldFill))		                                                                                                    				
	
 	oGet := MsNewGetDados():New( 050, 010, 265, 500, GD_INSERT+GD_UPDATE, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	 
 	
return




