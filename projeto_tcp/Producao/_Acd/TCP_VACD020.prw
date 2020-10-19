#include "protheus.ch"
#include "apvt100.ch"

#define CAB 1
#define ITN 2

Static __nSem := 0
Static __PulaItem := .F.

User Function vAcd020()

	Local aTela
	Local nOpc

	aTela := VtSave()
	VTClear()

	@ 0,0 VTSAY "Separacao"
	@ 1,0 VTSay "Selecione:"
	nOpc := VTaChoice(3,0,6,VTMaxCol(),{"Ordem de Separacao","Ordem Producao"})

	VtRestore(,,,,aTela)

	// por ordem de separacao
	IF nOpc == 1
		vAcd020x(1)
	// por Ordem de producao
	ElseIF nOpc == 2
		vAcd020x(4)
	EndIF

Return



/*
 Separacao
*/
Static Function vAcd020x(nOpc)

	Private cCodOpe     := CBRetOpe()

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .t.

	Private lForcaQtd   := GetMV("MV_CBFCQTD",,"2") =="1"
	Private cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
	Private cPictQtdExp := PesqPict("CB8","CB8_QTDORI")

	Private nSaldoCB8   := 0
	Private cVolume     := Space(10)
	Private cCodSep     := Space(6)

	IF Type("cOrdSep")=="U"
		Private cOrdSep := Space(6)
	EndIF

	// variavel static do fonte para controle de semaforo
	__nSem := 0

	//Validacoes
	IF Empty(cCodOpe)
		VTAlert("Operador nao cadastrado","Aviso",.T.,4000,3)
		Return
	EndIF

	VTClear()
	@ 0,0 VtSay "Separacao"

	IF ! CBSolCB7(nOpc,{|| VldCodSep()})
		Return MSCBASem()
	EndIF

	IF Empty(cOrdSep)
		cCodSep := CB7->CB7_ORDSEP
	Else
		cCodSep := cOrdSep
	EndIF        
	
	IF CB7->CB7_LIBOK != 'L'
		VTAlert("Ordem de separacao não liberada.","Atencao",.t.,6000,3)
		MSCBASem()
		Return
	EndIf

	VTSetKey(24,{|| Estorna() },"Estorna")

	While .T.       

		IF Separou()
			VTAlert("Ordem de separacao entregue completamente.","Atencao",.t.,6000,3)
			EncerraEntrega(.T.)
			Exit
		EndIF

		//fluxo da separacao
		IF !EtiProduto()

			IF VTYesNo("Deseja entregar o que foi separado agora, requisitando contra a OS?","Entrega",.t.)
				EncerraEntrega(.F.)
			EndIF
			Exit
		EndIF
	EndDO

	//liberar o semaforo
	MSCBASem()

Return


Static Function Estorna()

	Local cKey24  := VTDescKey(24)
	Local bkey24  := VTSetKey(24)
	Local n1
	Local aOrdens := {}

	Local cAlias := GetNextAlias()

	Local aTela := {}

	Local nOpcao := 0

	Local aDocs := {}
	Local aMata241 := {}

	VTSetKey(24,nil)


	BeginSQL Alias cAlias
		%noparser%

		select distinct ZD3_ORDEM
		from %table:ZD3%
		where
		    ZD3_FILIAL  = %xFilial:ZD3%
		and ZD3_ORDSEP  = %Exp: cOrdSep %
		and D_E_L_E_T_  = ' '

	EndSQL

	While !(cAlias)->( Eof() )

		aAdd(aOrdens, IIF(!Empty((cAlias)->ZD3_ORDEM),(cAlias)->ZD3_ORDEM,".ATUAL") )

		(cAlias)->( dbSkip() )
	EndDO

	IF len(aOrdens) != 0

		aTela := VtSave()
		VTClear()

		@ 0,0 VTSAY "Estorno"
		@ 1,0 VTSay 'Selecione:'
		nOpcao := VTaChoice(2,0,6,VTMaxCol(),aOrdens)

		VtRestore(,,,,aTela)

		IF nOpcao > 0

			IF aOrdens[nOpcao] == ".ATUAL"
				aOrdens[nOpcao] := Space(len(ZD3->ZD3_ORDEM))
			EndIF

			ZD3->( dbSetOrder( 2 ) )
			ZD3->( dbSeek( xFilial("ZD3") + aOrdens[nOpcao] + cOrdSep ) )

			Begin Transaction

			While !ZD3->( Eof() ) .And. ZD3->( ZD3_FILIAL+ZD3_ORDEM+ZD3_ORDSEP ) == xFilial("ZD3") + aOrdens[nOpcao] + cOrdSep

				CB8->( dbSetOrder(4) )
				CB8->( dbSeek( xFilial("CB8") + ZD3->(ZD3_ORDSEP+ZD3_ITEM+ZD3_PROD+ZD3_LOCAL+ZD3_LOCALI+ZD3_LOTECT+Space(6)+ZD3_NUMSER) ) )

				IF CB8->( Found() )
					//grava quantidade separada
					RecLock("CB8",.F.)
					CB8->CB8_QTDENT -= ZD3->ZD3_QTESEP
					CB8->( MsUnLock())
				EndIF

				IF aScan(aDocs,{|x| x == ZD3->ZD3_DOC }) == 0
					aAdd(aDocs,ZD3->ZD3_DOC)
				EndIF

				RecLock("ZD3",.F.)
				ZD3->( dbDelete() )
				ZD3->( MsUnLock())

				ZD3->( dbSkip() )
			EndDO

			lMSErroAuto := .F.

			For n1 := 1 to len(aDocs)
				lMSErroAuto := .F.

				SD3->( dbSetOrder(2) )
				SD3->( dbSeek( xFilial("SD3") + aDocs[n1] ) )

				IF SD3->( Found() )
					aMata241 := {}
					aAdd( aMata241, {"D3_DOC"    , SD3->D3_DOC    , Nil})
				 	aAdd( aMata241, {"D3_TM"     , SD3->D3_TM     , Nil})
				 	aAdd( aMata241, {"D3_CC"     , SD3->D3_CC     , Nil})
				 	aAdd( aMata241, {"D3_EMISSAO", SD3->D3_EMISSAO, Nil})

					//tem que fazer o dbSelectArea, senão da erro
					dbSelectArea("SD3")
					//volta pra ordem original
					SD3->( dbSetOrder(1) )
					MSExecAuto({|x,y,z| MATA241(x,y,z)},aMata241,,6)

					lMSHelpAuto := .F.
					IF lMSErroAuto
						VTBeep(2)
						VTAlert("Falha no estorno da movimentacao","Aviso",.T.,6000) //
						DisarmTransaction()
					EndIF
				EndIF
			Next n1

			End Transaction

			IF ! lMSErroAuto
				VTAlert( "Separacao de entrega excluida com sucesso.", "Exclusao", .T., , 3)
			EndIF
		EndIF

	Else
		VTAlert( "Nao existe entregas da ordem de separacao "+cOrdSep+" para estorno", "Atencao", .T., 4000, 3)
	EndIF

	VTSetKey(24,bkey24,ckey24)

Return

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
		VTAlert("Ordem de Entrega " + cNumEntrega + " gerada com sucesso.","Sucesso",.t.,4000,3)

		//IF VTYesNo( "Deseja requisitar o material entregue contra a ordem de serviço?", "Atencao", .T.)
			RequisitOP(cNumEntrega, .F.)
		//EndIF

	ElseIF !lAuto
		VTAlert("Não existe itens separados para entregar.","Atencao",.t.,4000,3)
	EndIF

Return lEntregou








//============================================================================================
// FUNCOES REVISADAS
//============================================================================================
/*
 Verifica se todos os itens da Ordem de Separacao foram separados
*/
Static Function Separou()

	Local lRet:= .T.
	Local aCB8	:= CB8->(GetArea('CB8'))

	CB8->( dBSetOrder(1) )
	CB8->( dbSeek( xFilial("CB8") + cOrdSep ) )

	While CB8->( !Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == xFilial("CB8")+cOrdSep
		IF CB8->(CB8_QTDORI-CB8_QTDENT) > 0
			lRet := .F.
		EndIF

		CB8->(DbSkip())
	EndDO

	CB8->(RestArea(aCB8))

Return lRet



/*
 Leitura da etiqueta
*/
Static Function EtiProduto()

	Local cEtiProd := Space(48)
	Local nQtde    := 1

	While .t.

		@ 5,0 VTSay "Qtde " VtGet nQtde pict cPictQtdExp valid nQtde > 0 when (lForcaQtd .or. VtLastkey()==5)
		@ 6,0 VTSay "Leia o produto"
		@ 7,0 VTGet cEtiProd pict "@!" VALID VTLastkey() == 5 .Or. VldProduto(cEtiProd,nQtde)

		VTRead

		// tratamento de ocorrencia pular o item
		IF VTLastkey() == 27
			IF VTYesNo("Confirma a saida?","Atencao",.T.)
				Return .F.
			Else
				Loop
			EndIF
		EndIF
		Exit
	EndDO

Return .T.



//======================================================================================================
// Funcoes de validacoes de gets
//======================================================================================================
/*
 Validacao da Ordem de Separacao
*/
Static Function VldCodSep()

	Local lRet := .T.

	IF Empty(cOrdSep)
		VtKeyBoard(chr(23))
		Return .f.
	EndIF

	CB7->(DbSetOrder(1))
	IF !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
		VtAlert("Ordem de separacao nao encontrada.","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIF
	If "09*" $ CB7->CB7_TIPEXP
		VtAlert("Ordem de Pre-Separacao ","Codigo Invalido",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATUS == "3"
		VtAlert("Ordem de separacao em processo de embalagem","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATUS == "4"
		VtAlert("Ordem de separacao com embalagem finalizada","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATUS  == "5" .OR.  CB7->CB7_STATUS  == "6"
		VtAlert("Ordem de separacao possui Nota gerada","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATUS  == "7"
		VtAlert("Ordem de separacao possui etiquetas oficiais de volumes","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATUS  == "8"
		VtAlert("Ordem de separacao em processo de embarque","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If !(!Empty(CB7->CB7_OP) .Or. CBUltExp(CB7->CB7_TIPEXP) $ "00*01*") .And. CB7->CB7_STATUS == "9"
		VtAlert("Ordem de separacao ja Embarcada","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

	If CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E" O MESMO
		VtBeep(3)
		If ! VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf

	//fecha o semaforo, somente um separador por ordem de separacao
	If lRet .And. !MSCBFSem()
		VtAlert("Ordem Separacao ja esta em andamento...!","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf

Return lRet



/*
 VldProduto
*/
Static Function VldProduto(cEtiProd,nQtde)

	Local cLote       := Space(10)
	Local cSLote      := Space(6)
	Local cNumSer	  := Space(20)
	Local cV166VLD    := If(UsaCB0("01"),Space(TamSx3("CB0_CODET2")[1]),Space(48))
	Local nP          := 0
	Local nQtdTot     := 0
	Local cEtiqueta
	Local aEtiqueta   := {}


	Local cMsg        := ""
	Local nSaldo      := 0
	Local nSaldoLote  := 0
	Local aAux        := {}
	Local lErrQTD     := .F.
	Local lACD166BEmp := .T.

	DEFAULT nQtde     := 1


	//validacao
	Begin Sequence

		cEtiqueta:= cEtiProd

		aEtiqueta := CBRetEtiEan(cEtiqueta)
		IF len(aEtiqueta) == 0
			cMsg := "Etiqueta invalida"
			Break
		EndIF
		cLote  := aEtiqueta[3]

		IF !ExisteNaOrdem(aEtiqueta[1])
			cMsg := "Produto Invalido"
			Break
		EndIF

		//se controla lote
		IF Rastro(aEtiqueta[1])
			//solicita confirmação do lote
			IF CBRastro(aEtiqueta[1],@cLote,@cSLote)
				//verifica se o lote existe na ordem
				IF !ExisteNaOrdem(aEtiqueta[1], cLote)
					cMsg := "Lote invalido"
					Break
				EndIF
			Else
				cMsg:=""
				Break
			EndIF
		EndIF

		//vai ficar prosicionado no CB8 do produto
		//se tiver um produto com numero de serie, todos tem que ter
		IF !Empty(CB8->CB8_NUMSER)
		 	IF CBNumSer(@cNumSer,,aEtiqueta,.F.)
				//verifica se o lote existe na ordem
				IF !ExisteNaOrdem(aEtiqueta[1], cLote, cNumSer)
					cMsg := "Numero de serie invalido para Ordem"
					Break
				EndIF
			Else
				cMsg := "Numero de serie invalido"
				Break
			EndIF
		EndIF

		IF !Empty(CB8->CB8_NUMSER)
			// Valida se o numero de serie pertece ao lote informado pelo operador
			SBF->(dbSetOrder(4))
			If SBF->(dbSeek(xFilial("SBF")+(CB8->CB8_PROD+cNumSer)))
				If cLote+cSlote # SBF->(BF_LOTECTL+BF_NUMLOTE)
					cMsg := "O número de série não pertence ao lote informado"
					Break
				EndIf
			Else
				cMsg := "O número de série não foi localizado na tabela de saldos"
				Break
			EndIf
		EndIF

		//grava entrega
		IF !GravaEntrega(aEtiqueta[1], cLote, cNumSer, aEtiqueta[2]*nQtde)
			cMsg := "Quantidade invalida"
			Break
		EndIF

	Recover
		If ! Empty(cMsg)
			VtAlert(cMsg,"Aviso",.t.,4000,4)
		EndIf
		VtClearGet("cEtiProd")
		VtGetSetFocus("cEtiProd")
		Return .f.
	End Sequence


Return .t.


Static Function GravaEntrega(cProduto, cLote, cNumSer, nQuantidade )
	Local n1
	Local aItens := {}
	Local nQtdEnt := nQuantidade

	CB8->( dbSetOrder(7) )
	CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

	While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)

		//produto tem que ser o mesmo
		IF CB8->(CB8_PROD+CB8_LOTECT+CB8_NUMSER) == cProduto + cLote + cNumSer

			//se já foi separado (quantidade a separar - saldo a separar)
			IF CB8->(CB8_QTDORI-CB8_SALDOS) > 0
				//se já foi entregue (quantidade a separar - saldo a separar - quantidade entregue)
				IF CB8->(CB8_QTDORI-CB8_SALDOS-CB8_QTDENT) > 0
					aAdd(aItens, { CB8->(Recno()), Min(CB8->(CB8_QTDORI-CB8_SALDOS-CB8_QTDENT),nQtdEnt) })
					nQtdEnt -= Min(CB8->(CB8_QTDORI-CB8_SALDOS-CB8_QTDENT),nQtdEnt)
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
			CB8->( MsUnLock())

			RecLock("ZD3",.T.)
			ZD3->ZD3_FILIAL := xFilial("ZD3")
			ZD3->ZD3_ORDEM  := ""
			ZD3->ZD3_ORDSEP := CB7->CB7_ORDSEP
			ZD3->ZD3_CODOPE := cCodOpe
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


Static Function MSCBFSem()
	Local nC:= 0
	__nSem := -1
	While __nSem  < 0
		__nSem  := MSFCreate("UV020"+cOrdSep+".sem")
		IF  __nSem  < 0
			SLeep(50)
			nC++
			If nC == 3
				Return .f.
			EndIf
		EndIf
	EndDo
	FWrite(__nSem,"Operador: "+cCodOpe+" Ordem de Separacao: "+cOrdSep) //
Return .t.



Static Function MSCBASem()
	IF __nSem > 0
		Fclose(__nSem)
		FErase("UV020"+cOrdSep+".sem")
	EndIF
Return 10




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
/*
	VTClear()
	@ 01,00 VTSay 'C Contabil:'	VTGet cCtaCtb PICTURE '@!' VALID Ctb105Cta() F3 'CT1'
	@ 02,00 VTSay 'Item Conta:'	VTGet cIteCtb PICTURE '@!' VALID Ctb105Item() F3 'CTD'
	@ 03,00 VTSay 'Requisit.:'	VTGet cRequis PICTURE '@!' F3 'SRA'
	@ 04,00 VTSay 'C Custo:'	VTGet cCCusto PICTURE '@!' VALID Ctb105CC() F3 'CTT'
	VTRead
*/
	VTMSG("Processando") //

	Begin Transaction

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
			If !STJ->( dbSeek( xFilial("STJ") + SubStr(CB8->CB8_OP,1,6) ) )
				VTClear()
				@ 01,00 VTSay 'C Contabil:'	VTGet cCtaCtb PICTURE '@!' VALID Vazio() .Or. Ctb105Cta() F3 'CT1'
				@ 02,00 VTSay 'Item Conta:'	VTGet cIteCtb PICTURE '@!' VALID Vazio() .Or. Ctb105Item() F3 'CTD'
				@ 03,00 VTSay 'Requisit.:'	VTGet cRequis PICTURE '@!' F3 'SRA'
				@ 04,00 VTSay 'C Custo:'	VTGet cCCusto PICTURE '@!' VALID Vazio() .Or. Ctb105CC() F3 'CTT'
				VTRead
			Else
				cCtaCtb := GTRIGGER(Posicione("ST9",1,xFilial('ST9')+STJ->TJ_CODBEM,"T9_ZITEMCT"),SB1->B1_GRUPO)
				If Empty(cCtaCtb)
					VTClear()
					@ 01,00 VTSay 'C Contabil:'	VTGet cCtaCtb PICTURE '@!' VALID Vazio() .Or. Ctb105Cta() F3 'CT1'
					VTRead
				EndIf			
			EndIf

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

//VTAlert("01")

		MSExecAuto({|x,y|MATA241(x,y)},aMata241[CAB],aMata241[ITN],3)

		lMSHelpAuto := .F.
		IF	lMSErroAuto

//VTAlert("NOk")

			VTBeep(2)
			VTAlert("Falha na gravacao movimentacao TM "+cTM,"Aviso",.T.,6000) //
			DisarmTransaction()
			Break
		Else

//VTAlert("Ok")

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

	End Transaction

	IF lMSErroAuto
		VTDispFile(NomeAutoLog(),.t.)
	EndIF

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





