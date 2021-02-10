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
	SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

	If .Not. MsgBox("Confirma geração de arquivo de EDI ?","Geração de Arquivo de EDI","YESNO")
		Aviso("Geração de Arquivo de EDI", "Operação Cancelada", {"Ok"}, 1)
		Return
	Endif

	Processa({|lEnd| GeraArquivo()},"Geração de arquivo de EDI das transportadoras")

Return



Static Function GeraArquivo()
	Local cTexto 		:= ""
	Local cConteudo 	:= ""
	Local cCodReg 		:= ""
	Local cAliasDAK 	:= GetNextAlias()        // da um nome pro arquivo temporario
	Local cQryDAK 		:= ""
	Local targetDir 	:= "\data\EDI\"
	Local cCodDAK 		:= DAK->DAK_COD
	Local cCodTransp 	:= DAK->DAK_TRANSP
	Local cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")
	Local cArqCPag 		:= "EDI-"+cCodTransp+Substr(dtoc(date()),1,2)+Substr(dtoc(date()),4,2)+Substr(dtoc(date()),7,2)+".TXT"

	If File(cArqCPag)
		FErase(cArqCPag)
	Endif

	If (nHdlArq := FCreate(targetDir+cArqCPag,0)) == -1
		MsgBox("Arquivo Texto não pode ser criado!","ATENÇÃO","ALERT")
		Return
	Else
		IncProc("Gerando arquivo "+cArqCPag)
	Endif

	cQryDAK := " SELECT * FROM  "+RetSQLName("DAK")+" DAK "
	cQryDAK += " JOIN "+RetSQLName("DAI")+" DAI ON  DAI_FILIAL=DAK_FILIAL AND DAI_COD=DAK_COD AND DAI.D_E_L_E_T_ = ' ' "
	cQryDAK += " JOIN "+RetSQLName("SC5")+" SC5 ON  C5_FILIAL=DAI_FILIAL AND C5_NUM=DAI_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
	cQryDAK += " JOIN "+RetSQLName("SC6")+" SC6 ON  C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM AND SC6.D_E_L_E_T_ = ' ' "
	cQryDAK += " WHERE DAK.D_E_L_E_T_ = ' ' "
	cQryDAK += " AND DAK_COD = '"+cCodDAK+"' "
	cQryDAK += " ORDER BY C6_NUM "
	If Select(cAliasDAK) > 0
		dbSelectArea(cAliasDAK)
		dbCloseArea()
	EndIf

	//Memowrite("c:\temp\oms100t.txt",cQuery)
	//Verifica qual EDI está sendo utilizado de acordo com o campo A4_EDIENV
	dbSelectArea("ZA0")
	ZA0->(dbSetOrder(1))

	TCQUERY cQryDAK NEW ALIAS &cAliasDAK
	While !(cAliasDAK)->(EOF())
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
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasDAK)+"->"+cMacro)
				EndIf
			Else//Numerico
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasDAK)+"->"+cMacro)
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
		(cAliasDAK)->(dbSKip())
	EndDo

	(cAliasDAK)->(DbCloseArea())

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
				ZA6_CODIGO   := cCodDAK//CODIGO DA MONTAGEM DA CARGA
				ZA6_TIPO   := "2" //1=ENVIO - 2=RECEBIMENTO
				ZA6_ORIGEM    := Funname()
				ZA6_DATA    := DATE()
                ZA6_HORA    := DATE()
				ZA6_USERTR   := UsrFullName(__cUserId)
				ZA6_STATUS   := "1"
				ZA6->(MsUnlock())
		Aviso("Geração de Arquivo de EDI", "Arquivo gerado: "+cArqCPag+CHR(13)+CHR(10)+"Pasta: "+targetDir, {"Ok"}, 1)
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
