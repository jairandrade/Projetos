#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"
#include "Protheus.ch"

/*/{Protheus.doc} OMS100T
Rotina para geração e exportação de dados para arquivo TXT.
@author Jair Andrade
@since 08/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS100T()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")

	If Empty(cCodEDI)
		HELP(' ',1,'Atenção!',,"O código de EDI não está preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI no cadastro da Transportadora"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'3,4' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi enviada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi enviada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma geração de arquivo de EDI para a transportadora "+cCodTransp+" ?","Geração de Arquivo de EDI","YESNO")
			Aviso("Geração de Arquivo de EDI", "Operação Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("1")},"Geração de arquivo de EDI das transportadoras")
	EndIf

Return



Static Function GeraArquivo(cOpc)
	Local cTexto 		:= ""
	Local cConteudo 	:= ""
	Local cCodReg 		:= ""
	Local cAliasZA7 	:= GetNextAlias()        // da um nome pro arquivo temporario
	Local cQryZA7 		:= ""
	Local targetDir 	:= "\data\EDI\"
	Local cArqCPag 		:= "EDI-"+cCodTransp+Substr(dtoc(date()),1,2)+Substr(dtoc(date()),4,2)+Substr(dtoc(date()),7,2)+".TXT"

	If File(cArqCPag)
		FErase(cArqCPag)
	Endif

	If (nHdlArq := FCreate(targetDir+cArqCPag,0)) == -1
		HELP(' ',1,'Atenção!',,"Arquivo Texto não pode ser criado!",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		Return
	Else
		IncProc("Gerando arquivo "+cArqCPag)
	Endif

	cQryZA7 := " SELECT * FROM  "+RetSQLName("ZA7")+" ZA7 "
	cQryZA7 += " JOIN "+RetSQLName("SC5")+" SC5 ON  C5_FILIAL=ZA7_FILIAL AND C5_NUM=ZA7_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
	cQryZA7 += " JOIN "+RetSQLName("SC9")+" SC9 ON  C9_FILIAL=ZA7_FILIAL AND C9_PEDIDO=ZA7_PEDIDO AND C9_ITEM = ZA7_ITEMPD AND SC9.D_E_L_E_T_ = ' ' "
	cQryZA7 += " WHERE ZA7.D_E_L_E_T_ = ' ' "
	cQryZA7 += " AND ZA7_CODIGO = '"+cCodZA7+"' "
	cQryZA7 += " AND ZA7_FILIAL = '"+FWxFilial('ZA7')+"' "
	cQryZA7 += " ORDER BY C9_PEDIDO "
	If Select(cAliasZA7) > 0
		dbSelectArea(cAliasZA7)
		dbCloseArea()
	EndIf

	//Memowrite("c:\temp\oms100t.txt",cQuery)
	//Verifica qual EDI está sendo utilizado de acordo com o campo A4_EDIENV
	dbSelectArea("ZA0")
	ZA0->(dbSetOrder(1))

	TCQUERY cQryZA7 NEW ALIAS &cAliasZA7
	While !(cAliasZA7)->(EOF())
		If Empty(cCodReg)
			ZA0->(dbGotop())
			ZA0->(DbSeek(xFilial("ZA0")+cCodEDI))	//ZA0_FILIAL+ZA0_CODIGO
			cCodReg := ZA0->ZA0_CODREG
		Else
			//grava o ultimo codigo de registro
			If !Empty(cTexto)
				FWrite(nHdlArq,cTexto+CHR(13)+Chr(10))
			EndIf
			cTexto := ""
			ZA0->(dbSetOrder(3))
			ZA0->(dbGotop())
			ZA0->(DbSeek(xFilial("ZA0")+cCodEDI+cCodReg))	//ZA0_FILIAL+ZA0_CODIGO
		Endif

		While !ZA0->(EOF()) //.AND. ZA0->ZA0_CODREG == cCodReg
			cConteudo := ""
			If 	cCodReg  <> ZA0->ZA0_CODREG
				FWrite(nHdlArq,cTexto+CHR(13)+CHR(10))
				cCodReg := ZA0->ZA0_CODREG
				cTexto := ""
			EndIf

			If ZA0->ZA0_TPDADO=="1"//Caracter
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo :=STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					If cConteudo == "TPENV"
						If cOpc =="1"
							cConteudo :="ENV"
						Else
							cConteudo :="CAN"
						EndIf
					Endif
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasZA7)+"->"+cMacro)
				EndIf
			Else//Numerico
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasZA7)+"->"+cMacro)
					cConteudo := Alltrim(Str(cConteudo))
				EndIf
			EndIf
			cConteudo := AllTrim(cConteudo)
			//Calcula o tamanho do campo para a configuracao do texto
			_nTamCpo :=(Val(OMS100R(ZA0->ZA0_POSFIM)) - Val(OMS100R(ZA0->ZA0_POSINI))) + 1
			_cContTemp := _nTamCpo - Len((cConteudo))
			If _cContTemp > 0
				_cCompText := cConteudo+Padr("",_cContTemp)
			Else
				_cCompText :=Substr(cConteudo, 1,_nTamCpo)
			EndIf
			cTexto +=_cCompText
			nContad++
			ZA0->(DbSkip())
		Enddo
		(cAliasZA7)->(dbSKip())
	EndDo

	(cAliasZA7)->(DbCloseArea())

//grava o ultimo codigo de registro
	FWrite(nHdlArq,cTexto+CHR(13)+CHR(10))
	FClose(nHdlArq)

	If nContad = 0
		MsgBox("Não há dados. Favor vertificar os Parâmetros.","Atenção","ALERT")
		FErase(cArqCPag)
	Else
		//Grava na tabela de log os dados
		RecLock('ZA6', .T.)
		ZA6_FILIAL   := xFilial("ZA6")
		ZA6_CODIGO   := cCodZA7//CODIGO DA MONTAGEM DA CARGA
		ZA6_TIPO   := "1" //1=ENVIO - 2=RECEBIMENTO
		ZA6_ORIGEM    := Funname()
		ZA6_DATA    := DATE()
		ZA6_HRTRA    := TIME()
		ZA6_USERTR   := UsrFullName(__cUserId)
		ZA6_STATUS   := "1"
		ZA6_TOMOV   := "1"//1=GERACAO TXT; 2=ENVIO TXT
		ZA6->(MsUnlock())
		Aviso("Geração de Arquivo de EDI", "Arquivo gerado: "+cArqCPag+CHR(13)+CHR(10)+"Pasta: "+targetDir, {"Ok"}, 1)

		//Altera o STATUS da tabela ZA7 para Envio transportadora.
		//Neste caso o campo ZA7_STATUS deve ser preenchido com valor='3'
		dbSelectArea("ZA7")
		ZA7->(dbSetOrder(1))
		If ZA7->(DbSeek(xFilial("ZA7")+cCodZA7))
			While !ZA7->(Eof()) .and. ZA7_CODIGO==cCodZA7
				RecLock('ZA7', .F.)
				ZA7_STATUS := Iif(cOpc=="1",'3','5')
				ZA7->(MsUnlock())
				ZA7->(dbSkip())
			Enddo

		EndIf
	Endif
Return
/*/{Protheus.doc} OMS100R
Função que tira zeros a esquerda de uma variável caracter
@author Jair Andrade	
@since 08/12/2020
@version undefined
@param cTexto, characters, Texto que terá zeros a esquerda retirados
@type function
@example Exemplos abaixo:
    u_OMS100R("00000090") //Retorna "90"
/*/

Static Function OMS100R(cTexto)
	Local aArea     := GetArea()
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

	//Pegando o texto atual
	cRetorno := Alltrim(cTexto)

	//Enquanto existir zeros a esquerda
	While lContinua
		//Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
		If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
			lContinua := .f.
		EndIf

		//Se for continuar o processo, pega da próxima posição até o fim
		If lContinua
			cRetorno := Substr(cRetorno, 2, Len(cRetorno))
		EndIf
	EndDo

	RestArea(aArea)
Return cRetorno
/*/{Protheus.doc} OMS100C
Rotina para cancelamento de EDI . Deverá ser enviado um TXT para a transportadora.
@author Jair Andrade
@since 15/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS100C()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")

	If Empty(cCodEDI)
		HELP(' ',1,'Atenção!',,"O código de EDI não está preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI"})
		lRet := .F.
	EndIf

	If Empty(ZA7->ZA7_STATUS)  .and. lRet
		HELP(' ',1,'Atenção!',,"A EDI ainda não foi gerada para a carga "+cCodZA7,1,0, NIL, NIL, NIL, NIL, NIL, {"Cancelar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'1,2' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI nao pode ser efetuado porque ainda não foi enviado para a transportadora. "+cCodTransp+ ".",1,0, NIL, NIL, NIL, NIL, NIL, {"Enviar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI para a transportadora "+cCodTransp+ " já foi enviado.",1,0, NIL, NIL, NIL, NIL, NIL, {"Aguardando retorno da transportadora."})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma o cancelamento do EDI ? Este cancelamento será enviado para a transportadora "+cCodTransp+".","Geração de Arquivo de cancelamento do EDI","YESNO")
			Aviso("Geração de Arquivo de EDI", "Operação Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("2")},"Geração de arquivo de cancelamento do EDI")
	EndIf

Return

Return
