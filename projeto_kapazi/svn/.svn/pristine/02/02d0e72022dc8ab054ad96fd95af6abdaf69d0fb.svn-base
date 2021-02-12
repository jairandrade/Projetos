#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "rwmake.ch"

//WebService
wsservice WS_MATA415 description "WEBSERVICE ORCAMENTOS"

	// DECLARACAO DAS VARIVEIS GERAIS
	WSDATA LOGIN	as string
	WSDATA SENHA	as string
	WSDATA EMPRESA 	as string
	WSDATA FILIAL 	as string
	WSDATA ORCAMENTO as string
	WSDATA PEDIDO	as string
	WSDATA OPCAO	as string
	WSDATA MOTIVO	as string
	WSDATA NOTA		as string
	WSDATA NUMFLUIG AS string
	WSDATA SERIE	as string
	WSDATA CLIENTE	as string
	WSDATA LOJA	as string

	// VARIAVEIS DE RETORNO
	WSDATA sSTATUS   as string
	WSDATA oCab   	 as MATA415_CAB
	WSDATA oItens    as MATA415_ARRAY_ITENS
	WSDATA oItensOrc as array of MATA415_ITENS

	// DECLARACAO DOS METODOS
	wsmethod INCLUIR    	 		description "Inclui Orçamento"
	wsmethod CONSULTA_ITENS  		description "Consulta Itens de um Orçamento"
	wsmethod APROVAR		 		description "Aprova um Orçamento"
	wsmethod LIBERA_ESTOQUE	 		description "Libera Estoque"
	wsmethod CONSULTA_TRANSMISSAO	description "Consulta transmissao da NF de Saida no Protheus"
	wsmethod ANALISA_ESTOQUE		description "Consulta se estoque esta liberado"
	wsmethod PEDIDO_APROVAR			description "Altera o status do pedido."

endwsservice

//----------------------
//METODO INCLUIR
//----------------------
wsmethod INCLUIR wsreceive LOGIN,SENHA,EMPRESA,FILIAL,oCab,oItens wssend sSTATUS wsservice WS_MATA415

	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha 	:= {}
	Local cDoc   	:= ""
	Local lRpc 	 	:= (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local nX     	:= 0
	Local nY     	:= 0
	Local lOk    	:= .T.
	Local lAbriu 	:= .F.
	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais
	Local lContinua := .F.
	Local cRefere 	:= Alltrim(::oCab:CJ_XREFERE) //Incluido Reinaldo 01/10/2018
	PRIVATE lMsErroAuto    := .F.
	PRIVATE lMsHelpAuto    := .T.
	PRIVATE lAutoErrNoFile := .T.
	PRIVATE msgErroFluig   := ""

	//Incluido Reinaldo 01/10/2018
	dbSelectArea("SCJ")
	SCJ->(DbSetOrder(6)) //FILIAL+CHAVE referencia customizada
	If SCJ->(DbSeek(xFilial("SCJ")+ cRefere))
		::sSTATUS := SCJ->CJ_NUM
		return .T.
	EndIf
	//Incluido Reinaldo 01/10/2018

	SCJ->(DbSetOrder(1))

	Conout("Metodo INCLUIR")

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)

			aArea := Getarea()

			ConOut(Repl("-",80))
			ConOut("Inicio: "+Time())

			cDoc := GetSxeNum("SCJ","CJ_NUM")
			RollBAckSx8()

			aadd(aCabec,{"CJ_NUM"    	,cDoc,Nil})
			aadd(aCabec,{"CJ_CLIENTE"	,AllTrim(::oCab:CJ_CLIENTE),Nil})
			aadd(aCabec,{"CJ_LOJA"		,AllTrim(::oCab:CJ_LOJA),Nil})//SA1
			aadd(aCabec,{"CJ_CLIENT"	,AllTrim(::oCab:CJ_CLIENT),Nil})//SA1
			aadd(aCabec,{"CJ_LOJAENT"	,AllTrim(::oCab:CJ_LOJAENT),Nil})//SA1
			aadd(aCabec,{"CJ_CONDPAG"	,AllTrim(::oCab:CJ_CONDPAG),Nil})//SE4
			aadd(aCabec,{"CJ_TXMOEDA"	,1,Nil})//::oCab:CJ_TXMOEDA,Nil})//SA1 //N,
			aadd(aCabec,{"CJ_XREFERE"	,AllTrim(::oCab:CJ_XREFERE),Nil})
			aadd(aCabec,{"CJ_XPERSON"	,AllTrim(::oCab:CJ_XPERSON),Nil})
			aadd(aCabec,{"CJ_XUSRFLU"	,AllTrim(::oCab:CJ_XUSRFLU),Nil})

			lContinua := .F.

			if SCJ->(FIELDPOS("CJ_REFEREN")) >0
				If valtype(::oCab:CJ_REFEREN) <> "U"
					aadd(aCabec,{"CJ_REFEREN"	,AllTrim(::oCab:CJ_REFEREN),Nil})
					If Alltrim(::oCab:CJ_REFEREN) <> ""
						DbSelectArea("SCJ")
						SCJ->(DBORDERNICKNAME("CJ_REFEREN "))
						If SCJ->(DbSeek(xFilial("SCJ")+Alltrim(::oCab:CJ_REFEREN) ))
							lContinua := .F.
							Conout(dtoc(Date())+" "+Time()+" Metodo INCLUIR ABORTADO, REFENCIA JA INCLUIDO: "+Alltrim(::oCab:CJ_REFEREN))
						else
							lContinua := .T.
						EndIf
					else
						lContinua := .T.
					EndIf
				else
					lContinua := .T.
				EndIf
			else
				lContinua := .T.
			EndIf

			if lContinua
				Conout(dtoc(Date())+" "+Time()+" Metodo INCLUIR ITENS:")
				varinfo("::oItens",::oItens)

				For nX := 1 To LEN(::oItens:Item) //aScan(aLinha[nX],{|x| x[1]
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbGoTop())
					SB1->(DbSeek(xFilial("SB1")+AllTrim(::oItens:Item[nX]:CK_PRODUTO)))
					aLinha := {}
					aadd(aLinha,{"CK_ITEM"		,StrZero(nX,2),Nil})
					aadd(aLinha,{"CK_PRODUTO"	,AllTrim(::oItens:Item[nX]:CK_PRODUTO),Nil})
					if valtype(::oItens:Item[nX]:CK_XLARG)<> "U"
						aadd(aLinha,{"CK_XLARG"		,val(::oItens:Item[nX]:CK_XLARG),Nil})
					EndIf
					if valtype(::oItens:Item[nX]:CK_XCOMPRI)<> "U"
						aadd(aLinha,{"CK_XCOMPRI"		,val(::oItens:Item[nX]:CK_XCOMPRI),Nil})
					EndIf
					if valtype(::oItens:Item[nX]:CK_XQTDPC)<> "U"
						aadd(aLinha,{"CK_XQTDPC"		,val(::oItens:Item[nX]:CK_XQTDPC),Nil})
					EndIF
					aadd(aLinha,{"CK_UM"		,AllTrim(::oItens:Item[nX]:CK_UM),Nil})
					aadd(aLinha,{"CK_OPER"		,AllTrim(::oItens:Item[nX]:CK_OPER),Nil})
					aadd(aLinha,{"CK_TES"		,AllTrim(::oItens:Item[nX]:CK_TES),Nil})
					aadd(aLinha,{"CK_QTDVEN"	,VAL(::oItens:Item[nX]:CK_QTDVEN),Nil}) //N
					aadd(aLinha,{"CK_PRCVEN"	,VAL(::oItens:Item[nX]:CK_PRCVEN),Nil}) //N
					aadd(aLinha,{"CK_PRUNIT"	,VAL(::oItens:Item[nX]:CK_PRUNIT),Nil}) //N
					//aadd(aLinha,{"CK_VALOR"		,VAL(::oItens:Item[nX]:CK_VALOR),Nil})//N
					aadd(aLinha,{"CK_LOCAL"		,AllTrim(::oItens:Item[nX]:CK_LOCAL),Nil})
					aadd(aLinha,{"CK_CLASFIS"	,AllTrim(::oItens:Item[nX]:CK_CLASFIS),Nil})
					aadd(aLinha,{"CK_XTIPO"		,AllTrim(::oItens:Item[nX]:CK_XTIPO),Nil})
					aadd(aLinha,{"CK_XLINK"		,AllTrim(::oItens:Item[nX]:CK_XLINK),Nil})

					aadd(aItens,aLinha)
				Next nX

				//Teste de Inclusao
				MATA415(aCabec,aItens,3)

				If !lMsErroAuto
					ConOut("Incluido com sucesso! "+cDoc)
					::sSTATUS := cDoc
				Else
					ConOut("Erro na inclusao!")

					If msgErroFluig <> ""
						::sSTATUS := "ERRO FLUIG| " + msgErroFluig
					Else
						cErro := ""
						aLog := GetAutoGRLog()
						For nX := 1 To Len(aLog)
							cErro += aLog[nX] + "    " + CRLF
						Next nX

						::sSTATUS := "ERRO| " + cErro + msgErroFluig
					EndIf
				EndIf

			else
				::sSTATUS := "ERRO| REFENCIA JA EXISTE COMO ORCAMENTO "+SCJ->CJ_NUM
			EndIf

			ConOut("Fim  : "+Time())
			ConOut(Repl("-",80))

			restArea(aArea)
		Else
			::sSTATUS := "Usuario e/ou senha invalidos!"
		EndIf
	Else
		::sSTATUS := "Usuario e/ou senha invalidos!"
	EndIf

return .T.

//----------------------
//METODO CONSULTA_ITENS
//----------------------
wsmethod CONSULTA_ITENS wsreceive LOGIN,SENHA,EMPRESA,FILIAL,ORCAMENTO wssend oItensOrc wsservice WS_MATA415

	Local cAlias := GetNextAlias()
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local lAbriu := .F.

	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais

	Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS LOGIN:"+LOGIN)
	Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS SENHA:"+SENHA)
	Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS EMPRESA:"+EMPRESA)
	Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS FILIAL:"+FILIAL)
	Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS ORCAMENTO:"+ORCAMENTO)

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)

			BeginSQL alias cAlias
				%noparser%

				SELECT
				CK_ITEM,
				CK_PRODUTO,
				CK_DESCRI,
				CK_UM,
				CK_TES,
				CK_QTDVEN,
				CK_PRCVEN,
				CK_PRUNIT,
				CK_VALOR,
				CK_LOCAL,
				CK_CLASFIS,
				CK_XTIPO,
				CK_XLARG,
				CK_XCOMPRI,
				CK_XQTDPC,
				ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),SCK.CK_XLINK)),'') AS CK_XLINK
				FROM
				%table:SCK% SCK
				WHERE
				SCK.CK_FILIAL = %Exp:xFilial("SCK")%
				AND SCK.%notdel%
				AND SCK.CK_NUM = %Exp:ORCAMENTO%
			EndSql

			Conout("")
			Conout(GetLastQuery()[2])
			Conout("")

			while (cAlias)->(!Eof())

				aAdd(::oItensOrc, WSClassNew("MATA415_ITENS") )
				nX := Len(::oItensOrc)
				Conout("")
				Conout(" Metodo CONSULTA_ITENS Item:"+cValtoChar(nX))
				Conout("")

				::oItensOrc[nX]:CK_ITEM 	:= ALLTRIM((cAlias)->CK_ITEM)
				::oItensOrc[nX]:CK_PRODUTO	:= ALLTRIM((cAlias)->CK_PRODUTO)
				::oItensOrc[nX]:CK_DESCRI	:= ALLTRIM((cAlias)->CK_DESCRI)
				::oItensOrc[nX]:CK_UM 		:= ALLTRIM((cAlias)->CK_UM)
				::oItensOrc[nX]:CK_OPER		:= '01'
				::oItensOrc[nX]:CK_TES 		:= ALLTRIM((cAlias)->CK_TES)
				::oItensOrc[nX]:CK_QTDVEN 	:= cvaltochar((cAlias)->CK_QTDVEN)
				::oItensOrc[nX]:CK_PRCVEN 	:= cvaltochar((cAlias)->CK_PRCVEN)
				::oItensOrc[nX]:CK_PRUNIT 	:= cvaltochar((cAlias)->CK_PRUNIT)
				::oItensOrc[nX]:CK_VALOR 	:= cvaltochar((cAlias)->CK_VALOR)
				::oItensOrc[nX]:CK_LOCAL 	:= ALLTRIM((cAlias)->CK_LOCAL)
				::oItensOrc[nX]:CK_CLASFIS 	:= ALLTRIM((cAlias)->CK_CLASFIS)
				::oItensOrc[nX]:CK_XTIPO	:= ALLTRIM((cAlias)->CK_XTIPO)
				::oItensOrc[nX]:CK_XLINK	:= ALLTRIM((cAlias)->CK_XLINK)
				/*::oItensOrc[nX]:CK_XLARG := cValtochar((cAlias)->CK_XLARG)
				::oItensOrc[nX]:CK_XCOMPRI :=cValtochar((cAlias)->CK_XCOMPRI)
				::oItensOrc[nX]:CK_XQTDPC := cValtochar((cAlias)->CK_XQTDPC)*/

				(cAlias)->(DBSkip())
			enddo

			(cAlias)->(DBCloseArea())

		Else
			Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS ERRO 1")
			aAdd(::oItensOrc, WSClassNew("MATA415_ITENS") )
			nX := Len(::oItensOrc)
			::oItensOrc[nX]:CK_ITEM 	:= "Usuario e/ou senha invalidos!"
			::oItensOrc[nX]:CK_PRODUTO	:= ""
			::oItensOrc[nX]:CK_DESCRI	:= ""
			::oItensOrc[nX]:CK_UM 		:= ""
			::oItensOrc[nX]:CK_OPER		:= ""
			::oItensOrc[nX]:CK_TES 		:= ""
			::oItensOrc[nX]:CK_QTDVEN 	:= ""
			::oItensOrc[nX]:CK_PRCVEN 	:= ""
			::oItensOrc[nX]:CK_PRUNIT 	:= ""
			::oItensOrc[nX]:CK_VALOR 	:= ""
			::oItensOrc[nX]:CK_LOCAL 	:= ""
			::oItensOrc[nX]:CK_CLASFIS 	:= ""
			::oItensOrc[nX]:CK_XTIPO	:= ""
			::oItensOrc[nX]:CK_XLINK	:= ""
			/*::oItensOrc[nX]:CK_XLARG := ""
			::oItensOrc[nX]:CK_XCOMPRI :=""
			::oItensOrc[nX]:CK_XQTDPC := ""*/
		EndIf
	Else
		Conout(dtoc(Date())+" "+Time()+" Metodo CONSULTA_ITENS ERRO 2")
		aAdd(::oItensOrc, WSClassNew("MATA415_ITENS") )
		nX := Len(::oItensOrc)
		::oItensOrc[nX]:CK_ITEM 	:= "Usuario e/ou senha invalidos!"
		::oItensOrc[nX]:CK_PRODUTO	:= ""
		::oItensOrc[nX]:CK_DESCRI	:= ""
		::oItensOrc[nX]:CK_UM 		:= ""
		::oItensOrc[nX]:CK_OPER		:= ""
		::oItensOrc[nX]:CK_TES 		:= ""
		::oItensOrc[nX]:CK_QTDVEN 	:= ""
		::oItensOrc[nX]:CK_PRCVEN 	:= ""
		::oItensOrc[nX]:CK_PRUNIT 	:= ""
		::oItensOrc[nX]:CK_VALOR 	:= ""
		::oItensOrc[nX]:CK_LOCAL 	:= ""
		::oItensOrc[nX]:CK_CLASFIS 	:= ""
		::oItensOrc[nX]:CK_XTIPO	:= ""
		::oItensOrc[nX]:CK_XLINK	:= ""
		/*::oItensOrc[nX]:CK_XLARG := ""
		::oItensOrc[nX]:CK_XCOMPRI :=""
		::oItensOrc[nX]:CK_XQTDPC := ""*/
	EndIf

return .T.

//----------------------
//METODO APROVAR
//----------------------
wsmethod APROVAR wsreceive LOGIN,SENHA,EMPRESA,FILIAL,ORCAMENTO,OPCAO,MOTIVO wssend sSTATUS wsservice WS_MATA415

	//Local cAlias := GetNextAlias()
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local lAbriu := .F.

	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais

	Conout("Metodo APROVAR")

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)

			aArea	 := Getarea()

			DbSelectArea("SCJ")
			SCJ->(DBSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

			//Posicionando no registro
			if SCJ->(DbSeek(xFilial("SCJ") + ALLTRIM(ORCAMENTO),.T. ))

				Begin Transaction

					Do Case
						Case OPCAO == "1" //APROVAÇÃO 1 = CANCELADO PELO FINANCEIRO
						If RecLock("SCJ")
							SCJ->CJ_XAPROVA := "3" //CANCELADO
							SCJ->CJ_XMOTIVO := MOTIVO
							MaAvalOrc("SCJ",14)//Cancela orçamento
							::sSTATUS := "Cancelado pelo Financeiro!"
							MsUnlock()
						EndIf
						Case OPCAO == "2" //APROVAÇÃO 2 = APROVADO PELO FRANQUEADO, PRONTO PARA EFETIVAR
						If RecLock("SCJ")
							SCJ->CJ_XAPROVA := "2"//APROVADO
							SCJ->CJ_XSTATUS := "2"//PRODUÇÃO
							SCJ->CJ_XMOTIVO := MOTIVO
							::sSTATUS := "Orçamento Aprovado com sucesso!"
							MsUnlock()
						EndIf
						Case OPCAO == "3" //APROVAÇÃO 2 = CANCELADO PELO FRANQUEADO, EFETIVA PEDIDO BAIXO VALOR
						If RecLock("SCJ")
							SCJ->CJ_XAPROVA := "3" //CANCELADO
							SCJ->CJ_XMOTIVO := MOTIVO
							::sSTATUS := "Orçamento Cancelado com sucesso!"
							MsUnlock()
						EndIf
					EndCase

				End Transaction

			Else
				::sSTATUS := "Orçamento não encontrada no Protheus!"
			EndIf

			restArea(aArea)

		Else
			::sSTATUS := "Usuario e/ou senha invalidos!"
		EndIf
	Else
		::sSTATUS := "Usuario e/ou senha invalidos!"
	EndIf

	//(cAlias)->(DbCloseArea())

return .T.

//----------------------
//METODO LIBERA ESTOQUE
//----------------------
wsmethod LIBERA_ESTOQUE wsreceive LOGIN,SENHA,EMPRESA,FILIAL,PEDIDO,OPCAO wssend sSTATUS wsservice WS_MATA415

	Local cAlias := GetNextAlias()
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local lAbriu := .F.

	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais

	Conout("Metodo LIBERA_ESTOQUE")

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)

			aArea	 := Getarea()

			DbSelectArea("SC9")
			SC9->(DBSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

			//Posicionando no registro
			if SC9->(DbSeek(xFilial("SC9") + ALLTRIM(PEDIDO),.T. ))

				Begin Transaction
					While SC9->(!EOF()) .and. SC9->C9_FILIAL == xFilial("SC9") .and. Alltrim(SC9->C9_PEDIDO) == ALLTRIM(PEDIDO)
						RecLock("SC9",.f.)
						SC9->C9_XBLQFLU :=  OPCAO
						SC9->(MSUnLock())
						SC9->(DbSkip())
					EndDo
				End Transaction

				::sSTATUS := "Atualizado com Sucesso!"

			Else
				::sSTATUS := "Pedido não encontrado no Protheus!"
			EndIf

			restArea(aArea)

		Else
			::sSTATUS := "Usuario e/ou senha invalidos!"
		EndIf
	Else
		::sSTATUS := "Usuario e/ou senha invalidos!"
	EndIf

	(cAlias)->(DbCloseArea())

return .T.

//----------------------------
//METODO CONSULTA TRANSMISSAO
//----------------------------
wsmethod CONSULTA_TRANSMISSAO wsreceive EMPRESA, FILIAL, NOTA, SERIE, CLIENTE, LOJA wssend sSTATUS wsservice WS_MATA415

	Local cAlias 	:= GetNextAlias()
	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais

	Conout("Metodo CONSULTA_TRANSMISSAO")

	BeginSQL alias cAlias
		%noparser%

		SELECT
		F2_FILIAL,
		F2_DOC,
		F2_SERIE,
		F2_CLIENTE,
		F2_LOJA,
		F2_DAUTNFE,
		F2_HAUTNFE
		FROM
		%table:SF2% SF2
		WHERE
		SF2.F2_FILIAL = %Exp:xFilial("SF2")%
		AND SF2.%notdel%
		AND SF2.F2_DOC = %Exp:NOTA%
		AND SF2.F2_SERIE = %Exp:SERIE%
		AND SF2.F2_CLIENTE = %Exp:CLIENTE%
		AND SF2.F2_LOJA    = %Exp:LOJA%
		AND SF2.F2_DAUTNFE <> ''
	EndSql

	//Conout(GetLastQuery()[2])

	If !Empty((cAlias)->F2_DAUTNFE)
		::sSTATUS := (cAlias)->F2_DAUTNFE + " - " + (cAlias)->F2_HAUTNFE

	Else
		::sSTATUS := ""
	EndIf

	(cAlias)->(DbCloseArea())

return .T.

//----------------------------
//METODO CONSULTA TRANSMISSAO
//----------------------------
wsmethod ANALISA_ESTOQUE wsreceive EMPRESA, FILIAL, PEDIDO wssend sSTATUS wsservice WS_MATA415

	Local cAlias 	:= GetNextAlias()
	Local lBlk		:= .F.

	Conout("Metodo ANALISA_ESTOQUE")

	BeginSQL alias cAlias
		%noparser%

		SELECT
		C9_FILIAL,
		C9_PEDIDO,
		C9_BLEST,
		C9_BLCRED
		FROM
		%table:SC9% SC9
		WHERE
		SC9.C9_FILIAL = %Exp:xFilial("SC9")%
		AND SC9.%notdel%
		AND SC9.C9_PEDIDO = %Exp:PEDIDO%
	EndSql

	while (cAlias)->(!Eof())

		If (cAlias)->C9_BLEST == "02" .OR. (cAlias)->C9_BLEST == "03"
			lBlk := .T.
			Exit
		EndIF

		(cAlias)->(DBSkip())
	enddo

	If lBlk
		::sSTATUS := "BLOQUEADO"
	Else
		::sSTATUS := "LIBERADO"
	EndIf

	(cAlias)->(DbCloseArea())

return .T.

//----------------------------------
// Estrutura de um item da solicitacao
wsstruct MATA415_CAB

	//WSDATA CJ_NUM 		AS STRING
	WSDATA CJ_CLIENTE 	AS STRING
	WSDATA CJ_LOJA 		AS STRING
	WSDATA CJ_CLIENT 	AS STRING
	WSDATA CJ_LOJAENT 	AS STRING
	WSDATA CJ_CONDPAG 	AS STRING
	WSDATA CJ_TXMOEDA 	AS STRING
	WSDATA CJ_XREFERE	AS STRING
	WSDATA CJ_XPERSON	AS STRING
	WSDATA CJ_XUSRFLU   AS STRING
	WSDATA CJ_REFEREN   AS STRING OPTIONAL

endwsstruct

//----------------------------------
//Estrutura de retorno de um array que pode ter N itens
wsstruct MATA415_ARRAY_ITENS
	WSDATA Item as array of MATA415_ITENS
endwsstruct

//----------------------------------
// Estrutura de um item da solicitacao
wsstruct MATA415_ITENS

	WSDATA CK_ITEM	 	AS STRING OPTIONAL
	WSDATA CK_PRODUTO 	AS STRING
	WSDATA CK_DESCRI	AS STRING OPTIONAL
	WSDATA CK_UM 		AS STRING
	WSDATA CK_QTDVEN 	AS STRING
	WSDATA CK_VALOR 	AS STRING
	WSDATA CK_OPER		AS STRING
	WSDATA CK_TES 		AS STRING
	WSDATA CK_PRCVEN 	AS STRING
	WSDATA CK_PRUNIT	AS STRING OPTIONAL
	WSDATA CK_LOCAL 	AS STRING
	WSDATA CK_CLASFIS 	AS STRING OPTIONAL
	WSDATA CK_XTIPO		AS STRING OPTIONAL
	WSDATA CK_XLINK		AS STRING
	WSDATA CK_XLARG as STRING OPTIONAL
	WSDATA CK_XCOMPRI as STRING OPTIONAL
	WSDATA CK_XQTDPC as STRING OPTIONAL

endwsstruct

//----------------------
//METODO STSPEDIDO - ALTERA STATUS DO PEDIDO
//----------------------
wsmethod PEDIDO_APROVAR wsreceive LOGIN,SENHA,EMPRESA,FILIAL,PEDIDO,OPCAO,NUMFLUIG wssend sSTATUS wsservice WS_MATA415

	Local aArea

	Local oJson
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local lAbriu := .F.

	LOCAL lProcessa := .F.
	LocAL nLiberado := 0

	Local _aAreaSM0 := {}
	Local _oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)
			u_ProcLog('BLOQUEIO', PEDIDO, '1', NUMFLUIG)
			::sSTATUS := '{"status": "true", "message": "Pedido liberado com sucesso. Aguardado analise de crédito e estoque."}'
		Else
			::sSTATUS := '{"status": "false", "message": "Usuario e/ou senha invalidos!"}'
		EndIf
	Else
		::sSTATUS := '{"status": "false", "message": "Usuario e/ou senha invalidos!"}'
	EndIf

return .T.
