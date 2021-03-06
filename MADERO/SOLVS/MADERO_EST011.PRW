#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} EST010
Cadastro de regras de acesso dos usu�rios as movimenta��es internas

@type function
@author Cleverson Funaki
@since 16/04/2018
@version 1.0
/*/
User Function EST010()
	Private cCadastro := "Permiss�es - Movimentos Internos"
	Private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						  {"Visualizar","U_EST010A",0,2},;
						  {"Incluir","U_EST010A",0,3},;
						  {"Alterar","U_EST010A",0,4},;
						  {"Excluir","U_EST010A",0,5},;
						  {"Copia Permiss�es","U_EST010C",0,4}}
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	
	dbSelectArea("Z30")
	Z30->(dbSetOrder(1))
	Z30->(dbGoTop())
	
	mBrowse( 6,1,22,75,"Z30")
Return

User Function EST010A(cAlias, nReg, nOpc)
Local _lAcesso := .T.

	If nOpc == 2
		AxVisual("Z30",Z30->(RecNo()),2)
	ElseIf nOpc == 3
		AxInclui("Z30",Z30->(RecNo()),3)
	ElseIf nOpc == 4
		AxAltera("Z30", Z30->(Recno()), 4)
	ElseIf nOpc == 5
		AxDeleta("Z30", Z30->(Recno()), 5)
	Endif

Return

Static Function fVerADK(_pFilial)
	Local _aArea := GetArea()
	Local _lRet := .F.
	Local _cAlias := GetNextAlias()
	
	BeginSql Alias _cAlias
		SELECT COUNT(*) NREGS
		  FROM %table:ADK% ADK
		 WHERE ADK.ADK_FILIAL = %xFilial:ADK%
		   AND ADK.ADK_XFILI = %Exp:_pFilial%
		   AND ADK.%NotDel%
	EndSql
	
	If !(_cAlias)->(EOF())
		If (_cAlias)->NREGS > 0
			_lRet := .T.
		Endif
	Endif
	(_cAlias)->(dbCloseArea())
	
	RestArea(_aArea)
Return(_lRet)


/*/{Protheus.doc} EST010B
Fun��o de valida��o do campo Z30_REGRA
@type function
@author Cleverson Funaki
@since 16/04/2018
@version 1.0
@return ${.T./.F.}, ${Retorna se o conte�do � valido ou n�o}
/*/
User Function EST010B()
	// O conte�do "R" � permitido somente para grupos de produtos e usu�rios
	If &(ReadVar()) == "R"
		If !Empty(M->Z30_PROD) .Or. !Empty(M->Z30_USUAR)
			ApMsgAlert("A op��o de Regra � permitida somente para grupos de produtos e/ou usu�rios.","[EST010] - Regras Movimento Interno")
			Return(.F.)
		Endif
	Else
		// O conte�do "E" n�o � permitido para grupos
		If Empty(M->Z30_PROD) .And. Empty(M->Z30_USUAR)
			ApMsgAlert("A op��o de Exce��o � permitida somente quando informado o c�digo de produto e/ou usu�rio.","[EST010] - Regras Movimento Interno")
			Return(.F.)
		Endif
	Endif
Return(.T.)


/*/{Protheus.doc} EST010C
Fun��o para c�pia de regras entre filiais
@type function
@author Funaki
@since 23/04/2018
@version 1.0
/*/
User Function EST010C()
	Local _aSizeAut := MsAdvSize(,.F.,400)
	Local _aObjects := {}
	Local _aInfo := {}
	Local _aButtons := {}
	Local _aCpoFil := {}
	Local _aBrwFil := {}
	Local _aFilial := FWAllFilial()
	Private _lInvTit
	Private _cMarca := GetMark()
	Private _cAlFil := nil
	Private _cCodFil := SPACE(10)
	Private _cDesFil := SPACE(50)
	
	// Se encontrou notas, cria arquivo tempor�rio
	AADD(_aCpoFil,{"TOK","C",2,0})
	AADD(_aCpoFil,{"FILIAL","C",44,0})
	AADD(_aCpoFil,{"NOME","C",18,0})
		
	AADD(_aBrwFil,{"TOK","","","@!"})
	AADD(_aBrwFil,{"FILIAL","","C�digo","@!"})
	AADD(_aBrwFil,{"NOME","","Filial","@!"})
		
	_cAlFil := GetNextAlias()
		
	_cArqTit := CriaTrab(_aCpoFil,.T.)
	dbUseArea(.T.,__LocalDriver,_cArqTit,_cAlFil,.F.,.F.)
	INDEX ON (_cAlFil)->FILIAL TO &_cArqTit
	
	//Memowrite("D:\maderofil.html",varinfo("_aFilial",_aFilial))
	
	// Replica o SM0 para n�o desposicionar
	MsOpenDbf(.T.,"DBFCDX","SIGAMAT.EMP","NEWSM0",.T.,.F.)
	DbSetIndex("SIGAMAT.IND")
	SET(_SET_DELETED,.T.)
	dbSelectArea("NEWSM0")
	NEWSM0->(dbSetOrder(1))
	NEWSM0->(dbGoTop())
	NEWSM0->(dbSeek(cEmpAnt))
	
	While !NEWSM0->(EOF()) .And. Alltrim(NEWSM0->M0_CODIGO)==Alltrim(cEmpAnt)
		RecLock(_cAlFil,.T.)
		(_cAlFil)->TOK := SPACE(2)
		(_cAlFil)->FILIAL := NEWSM0->M0_CODFIL
		(_cAlFil)->NOME := NEWSM0->M0_FILIAL
		MsUnlock(_cAlFil)
		
		NEWSM0->(dbSkip())
	Enddo
	NEWSM0->(dbCloseArea())
	
	(_cAlFil)->(dbGoTop())
	
	// Inicia a constru��o da tela
	DEFINE MSDIALOG oDlgFil FROM 000,000 TO 450,880 TITLE "Copiar Permiss�es" Of oMainWnd PIXEL
	@ 005, 003 TO 032,440 PROMPT "[ Filial Origem ]" OF oDlgFil PIXEL
	@ 015, 010 SAY "C�digo:" SIZE 70,010 OF oDlgFil PIXEL
	@ 014, 040 MSGET _cCodFil VALID fValFil() SIZE 52,010 F3 "SM0" OF oDlgFil PIXEL
	@ 014, 092 MSGET _cDesFil SIZE 180,010 WHEN .F. OF oDlgFil PIXEL
	
	@037,002 TO 200,440 LABEL "[ Filial Destino ]" OF oDlgFil PIXEL
	oSelNota := MsSelect():New(_cAlFil,"TOK",,_aBrwFil,@_lInvTit,@_cMarca,{047,007,190,435},,,oDlgFil,,)
	
	TButton():New(205,330, "Confirmar", oDlgFil,{|| fConfFil() }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(205,385, "Cancelar", oDlgFil,{|| oDlgFil:End() }, 50,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	ACTIVATE MSDIALOG oDlgFil CENTERED
Return

Static Function fValFil()
	// Verifica se a filial est� cadastrada para possuir regras
	If !fVerADK(_cCodFil)
		ApMsgAlert("Esta filial n�o est� autorizada para cadastro de regras.","[EST010] - Copia Permiss�es")
		Return(.F.)
	Endif
	
	// Estando ok, preenche com o nome da filial
	_cDesFil := FWFilName(cEmpAnt, _cCodFil)
Return(.T.)

Static Function fConfFil()
	Local _lOk := .T.
	Local _cMsg := "Confirma a replica��o das regras da filial origem para as filiais selecionadas?" + CHR(13)+CHR(10)+CHR(13)+CHR(10)
	_cMsg += "ATEN��O: As regras ser�o replicadas somente para as filiais autorizadas"
	
	If !ApMSgYesNo(_cMsg,"[EST010] - Copia Permiss�es")
		Return
	Endif
	
	// Faz a c�pia das regras
	Processa({|| fCopia(@_lOk),"[EST010] - Copia Permiss�es"})
	
	If _lOk
		ApMsgInfo("C�pia conclu�da com sucesso!","[EST010] - Copia Permiss�es")
		oDlgFil:End()
	Endif
Return

Static Function fCopia(_pOk)
	Local _aArea := GetArea()
	Local _cAlAux := GetNextAlias()
	
	ProcRegua(0)
	IncProc("Selecionando registros...")
	
	BeginSql Alias _cAlAux
		SELECT Z30.Z30_ROTINA, Z30.Z30_PROD, Z30.Z30_DESCP, Z30.Z30_GRPPRO, Z30.Z30_DESCGR,
			   Z30.Z30_USUAR, Z30.Z30_DESCUS, Z30.Z30_GRUSU, Z30.Z30_DESCGU, Z30.Z30_ID, Z30.Z30_REGRA
		  FROM %table:Z30% Z30
		 WHERE Z30.Z30_FILIAL = %Exp:_cCodFil%
		   AND Z30.%NotDel%
	EndSql
	
	(_cAlAux)->(dbGoTop())
	Count To _nRegs
	(_cAlAux)->(dbGoTop())
	
	If _nRegs == 0
		(_cAlAux)->(dbCloseArea())
		ApMsgAlert("N�o foram encontradas regras cadastradas na filial origem informada.","[EST010] - Copia Permiss�es")
		_pOk := .F.
		Return
	Endif
	
	(_cAlFil)->(dbGoTop())
	ProcRegua((_cAlFil)->(RecCount()))
	
	(_cAlFil)->(dbGoTop())
	While !(_cAlFil)->(EOF())
		IncProc("Copiando regras..")
		If (_cAlFil)->(MARKED("TOK"))
			// Ignora a filial origem se for selecionada
			If Alltrim((_cAlFil)->FILIAL) == Alltrim(_cCodFil)
				(_cAlFil)->(dbSkip())
				Loop
			Endif
			
			If !fVerADK((_cAlFil)->FILIAL)
				(_cAlFil)->(dbSkip())
				Loop
			Endif
			
			// Apaga as regras existentes
			_cQry := "DELETE FROM " + RetSqlName("Z30") + " "
			_cQry += " WHERE Z30_FILIAL = '" + (_cAlFil)->FILIAL + "' "
			TCSQLExec(_cQry)
			
			// Inclui as novas regras
			(_cAlAux)->(dbGoTop())
			While !(_cAlAux)->(EOF())
				RecLock("Z30",.T.)
				Z30->Z30_FILIAL := (_cAlFil)->FILIAL
				Z30->Z30_ROTINA := (_cAlAux)->Z30_ROTINA
				Z30->Z30_PROD := (_cAlAux)->Z30_PROD
				Z30->Z30_DESCP := (_cAlAux)->Z30_DESCP
				Z30->Z30_GRPPRO := (_cAlAux)->Z30_GRPPRO
				Z30->Z30_DESCGR := (_cAlAux)->Z30_DESCGR
				Z30->Z30_USUAR := (_cAlAux)->Z30_USUAR
				Z30->Z30_DESCUS := (_cAlAux)->Z30_DESCUS
				Z30->Z30_GRUSU := (_cAlAux)->Z30_GRUSU
				Z30->Z30_DESCGU := (_cAlAux)->Z30_DESCGU
				Z30->Z30_ID := (_cAlAux)->Z30_ID
				Z30->Z30_REGRA := (_cAlAux)->Z30_REGRA
				MsUnlock("Z30")
				
				(_cAlAux)->(dbSkip())
			Enddo
		Endif
		
		(_cAlFil)->(dbSkip())
	Enddo
	
	(_cAlAux)->(dbCloseArea())
Return

/*/{Protheus.doc} EST010D
Fun��o para valida��o das regras cadastradas
@type function
@author Funaki
@since 18/04/2018
@version 1.0
@param _pProd, ${String}, C�digo do produto
@param _pTM, ${String}, Tipo de movimento
@return ${.T./.F.}, ${Retorna se autoriza ou n�o a movimenta��o do estoque}
/*/
User Function EST010D(_pProd, _pTM)
	Local _aArea := GetArea()
	Local _lRet := .F.
	Local _aGrpUsr := UsrRetGrp(cUserName)
	Local _nI
	
	// Movimentos internos m�ltiplos
	If Alltrim(FUNNAME()) == "MATA241"
		// Se for a rotina MATA241, o campo TM vem de uma vari�vel
		_pTM := CTM
	Endif
	
	If Empty(_pProd) .Or. Empty(_pTM)
		Return(.T.)
	Endif
	
	// Verifica se a filial � um restaurante
	If !fVerADK(xFilial("Z30"))
		// Se n�o for restaurante, n�o precisa realizar as outras valida��es
		Return(.T.)
	Endif
	
	// Se for o usu�rio administrador, inclui o grupo Administradores no array
	If Alltrim(RetCodUsr()) == "000000"
		AADD(_aGrpUsr,"000000")
	Endif
	
	// Verifica se existe alguma regra cadastrada para a rotina
	dbSelectArea("Z30")
	Z30->(dbSetOrder(1))
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	
	If Alltrim(FUNNAME()) $ "MATA240|MATA241"
		Z30->(dbGoTop())
		If !Z30->(dbSeek(xFilial("Z30")+Alltrim(FUNNAME())))
			// Se n�o encontrou nenhuma regra para a rotina, n�o precisa realizar as outras valida��es
			Return(.T.)
		Else
			// Verifica as regras da rotina
			While !Z30->(EOF()) .And. Alltrim(xFilial("Z30")+Z30->Z30_ROTINA)==Alltrim(xFilial("Z30")+Alltrim(FUNNAME())) .And. !_lRet
				// Verifica se � uma regra
				If Z30->Z30_REGRA == "R"
					// Verifica se o grupo do produto est� na regra
					SB1->(dbGoTop())
					SB1->(dbSeek(xFilial("SB1")+_pProd))
					
					If Alltrim(Z30->Z30_GRPPRO) == Alltrim(SB1->B1_GRUPO)
						// Verifica se o TM est� na regra
						If Alltrim(Z30->Z30_ID) == Alltrim(_pTM)
							// Verifica se algum dos grupos do usu�rio est�o na regra
							For _nI := 1 To Len(_aGrpUsr)
								If Alltrim(Z30->Z30_GRUSU) == Alltrim(_aGrpUsr[_nI])
									_lRet := .T.
									Exit
								Endif
							Next _nI
						Endif
					Endif
				Endif
				
				Z30->(dbSkip())
			Enddo
			
			// Caso encontre uma regra v�lida, verifica se n�o existe nenhum exce��o
			If _lRet
				Z30->(dbGoTop())
				Z30->(dbSeek(xFilial("Z30")+Alltrim(FUNNAME())))
				While !Z30->(EOF()) .And. Alltrim(xFilial("Z30")+Z30->Z30_ROTINA)==Alltrim(xFilial("Z30")+Alltrim(FUNNAME()))
					// Verifica se � uma exce��o
					If Z30->Z30_REGRA == "E"
						// Verifica se o produto est� na exce��o
						If Alltrim(Z30->Z30_PROD) == Alltrim(_pProd)
							// Verifica se o usu�rio est� na exce��o
							If Alltrim(Z30->Z30_USUAR) == Alltrim(RetCodUsr())
								// Verifica se o ID est� na exce��o
								If Alltrim(Z30->Z30_ID) == Alltrim(_pTM)
									// Se encontrar, retorna .F.
									_lRet := .F.
									Exit
								Endif
							Endif
						Endif
					Endif
					
					Z30->(dbSkip())
				Enddo
			Endif
		Endif
	Endif
	
	If !_lRet
		ApMsgInfo("Usu�rio sem permiss�o para movimentar o produto.","[EST010] - Regras Movimento Interno")
	Endif
	
	RestArea(_aArea)
Return(_lRet)