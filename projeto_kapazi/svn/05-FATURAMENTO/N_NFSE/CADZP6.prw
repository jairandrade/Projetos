#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
//==================================================================================================//
//	Programa: CADZP6	|	Autor:Tonhao									|	Data: 02/01/2018	//
//==================================================================================================//
//	Descrição: Rotina monitor de NFSE																//
//																									//
//==================================================================================================//
User Function CADZP6()
	Local cExprFilTop := "" 
	Local 		aParamBox 	:= {}
	local lFiltra := .T.
	Private 	aRet 		:= {}

	public _lFiltraNF := .T.

	Private cCadastro := "NFSe"
	Private aRotina := Menudef()
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cString := "ZP6"

	aCores :=   {{'!Empty(ZP6_CANC)','DISABLE'},; //cancelada
	{'EMPTY(ZP6->ZP6_NOTA).and.EMPTY(ZP6->ZP6_ERRO)', 'BR_BRANCO'},;        // Aguardando retorno
	{'!Empty(ZP6->ZP6_ERRO)'  , 'BR_PRETO' },;        // Erro
	{'!Empty(ZP6->ZP6_NOTA)' , 'ENABLE'      }}        // OK

	// valida se o campo existe
	IF ZP6->( FieldPos("ZP6_USRCO") ) > 0

		AAdd(aParamBox, { 2, "Filtra somente suas notas"		,"2-Não      ",{"1-Sim","2-Não"},120,".T.",.T.,".T."})

		If ParamBox(aParamBox,"Notas por usuário", @aRet,,,.T.,,,,,.T.,.T.)
			If SubStr(aRet[1],1,1) == "2"
				lFiltra := .F.
				_lFiltraNF := .F.
			EndIf
		Endif

		if  lFiltra
			cExprFilTop += "@ZP6_USRCO = '"+RetCodUsr()+"'"
		EndIf		

	EndIf


	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString, NIL , NIL , NIL , NIL , NIL , aCores, NIL , NIL , NIL , NIL , NIL , NIL , NIL , cExprFilTop )
Return()


Static Function Menudef
	Private aRotina := { 	{"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"PDF","U_CADZP6PDF",0,2},; 
	{"IMP RANGE","StaticCall(CADZP6,PDFRANGE)",0,2} ,;
	{"Retransmitir","U_ZP6Retr()",0,4},;
	{"Legenda","U_ZP6LEG()",0,2}}

Return(aRotina)

User Function CADZP6PDF()

	If !Empty(ZP6->ZP6_NOTA) .and. !Empty(ZP6->ZP6_MEMO)
		ShellExecute( "Open", alltrim(ZP6->ZP6_MEMO), "", "C:\", 1 )
	Else
		Msginfo("Nota não autorizada")
	EndIf

Return()


//Imprime um range de notas
Static Function PDFRANGE()
	Local 		aParamBox 	:= {}
	Private 	aRet 		:= {}	
	Private 	lCentered	:= .T.
	Private 	cCRLF		:= CRLF
	Private 	cAliasT1
	Private 	_cPerg1
	Private 	_cPerg2
	Private 	nRegs		:= 0
	Private		nCount		:= 0
	Private 	cCodigo		:= ""


	AAdd(aParamBox, { 1, "Nota De?"		,Space(9),"","","","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1, "Nota Até?"	,Space(9),"","","","",0,.F.}) // Tipo caractere

	If ParamBox(aParamBox,"IMPRESSAO DE NOTAS", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
		TrataPer()
		//MsgAlert("Em Testes, aguarde a finalizaçao do desenvolvimento!!")
	Else 

	Endif


Return()

//Trata as perguntas
Static Function TrataPer()
	Local aArea	:= GetArea()
	Private cAliasP6

	_cPerg1	:= MV_PAR01
	_cPerg2	:= MV_PAR02

	If BuscaNF()
		cAliasP6->(DbCloseArea())
		MsgInfo("Informe as notas corretamente!!!")
		Return
	EndIf

	While !cAliasP6->(EOF())

		DbSelectArea("ZP6")
		ZP6->(DbSetOrder(1))
		ZP6->(DbGoTop())
		If ZP6->(DbSeek(cAliasP6->ZP6_FILIAL + cAliasP6->ZP6_ID))

			If !Empty(ZP6->ZP6_MEMO)
				ShellExecute( "Open", Alltrim(ZP6->ZP6_MEMO), "", "C:\", 1 )
			Else
				Msginfo("Nota não autorizada")
			EndIf
			Sleep( 500 )
		EndIf

		cAliasP6->(DbSkip())
	EndDo

	cAliasP6->(DbCloseArea())
	RestArea(aArea)
Return()

//Busca as NF`s
Static Function BuscaNF()
	Local cSql		:= ""

	If Select('cAliasP6')<>0
		cAliasP6->(DBSelectArea('cAliasP6'))
		cAliasP6->(DBCloseArea())
	Endif



	cSql += " SELECT *
	cSql += " FROM "+RetSqlName("ZP6")
	cSql += " WHERE D_E_L_E_T_ = ''
	cSql += " AND ZP6_ERRO <> 'S'
	cSql += " AND ZP6_CANC = ''
	cSql += " AND ZP6_NOTA <> ''
	cSql += " AND SUBSTRING(ZP6_ID,4,9) >= '"+_cPerg1+"'
	cSql += " AND SUBSTRING(ZP6_ID,4,9) <= '"+_cPerg2+"'

	If type("_lFiltraNF") <> "U" .and. _lFiltraNF 
		// valida se o campo existe
		IF ZP6->( FieldPos("ZP6_USRCO") ) > 0
			cSql += " AND ZP6_USRCO = '"+RETCODUSR()+"'
		EndIf
	EndIF

	cSql += " ORDER BY ZP6_ID
	TcQuery cSql new Alias "cAliasP6"

	DbSelectArea("cAliasP6")
	cAliasP6->(DbGoTop())

Return(cAliasP6->(EOF()))



User Function ZP6LEG()
	Local aLegenda := {}

	//Monta as legendas (Cor, Legenda)
	aAdd(aLegenda,{"DISABLE",      "Cancelada"})
	aAdd(aLegenda,{"BR_BRANCO",         "Aguardando retorno"})
	aAdd(aLegenda,{"BR_PRETO",   "Erro"})
	aAdd(aLegenda,{"ENABLE",       "Nota autorizada"})

	//Chama a função que monta a tela de legenda
	BrwLegenda("NFSe", "Legendas", aLegenda)
Return

User Function ZP6Retr

	DbSelectArea("SF2")
	If SF2->(DbSeek(xFilial("SF2")+substr(ZP6->ZP6_ID,tamsx3("F2_SERIE")[1]+1,tamsx3("F2_DOC")[1] ) + substr(ZP6->ZP6_ID,1,tamsx3("F2_SERIE")[1] ) ) )
		If alltrim(ZP6->ZP6_ERRO) <> ''
			cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
			Reclock("ZP6",.F.)
			ZP6->ZP6_ERRO   := "" 
			ZP6->ZP6_MSGERR := ""		
			ZP6->(Msunlock())
			U_nfseXMLUni( cCodMun, "1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, "", {} )
		else
			Msginfo("Nota não pode ser retransmitida pois não possui erro!")
		EndIf
	else
		If ZP6->ZP6_CANC = ' ' .and. MsgYesNo("Nota fiscal não encontrada. Deseja transmitir o cancelamento?")
			cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
			U_nfseXMLUni( cCodMun, "1", ZP6->ZP6_EMISSA, substr(ZP6->ZP6_ID,1,3) , substr(ZP6->ZP6_ID,4,9), ZP6->ZP6_CLIENT, ZP6->ZP6_LOJA, "1", {} )
		EndIf
	EndIf

return