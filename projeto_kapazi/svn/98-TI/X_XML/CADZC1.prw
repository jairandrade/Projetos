#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"  
/*
+------------------+---------------------------------------------------------+
!Nome              ! CADZC1                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Rotina para efetuar manutencao dos dados do CTe         !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio A.Sugahara                                       !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 12/08/2019                                              !
+------------------+---------------------------------------------------------+
*/
User Function CADZC1() 

	Private cCadastro:="Manuitencao Dados CT-e"
	Private aRotina:= {}

	//Montar o vetor aRotina, obrigatorio para utilização da função mBrowse()
	aAdd( aRotina, {"Excluir",   "u_MNTCTE", 0, 5 })
	aAdd( aRotina, {"Visualizar","u_MNTCTE", 0, 2 })
	//aAdd( aRotina, {"Pesquisar", "AxPesqui"   , 0, 1 })

	//Selecionar a tabela pai, ordenar e posicionar no primeiro registro da ordem
	ZC1->(dbsetorder(1))
	//Executar a função mBrowse para a tabela mencionada
	MBrowse(6, 1, 22, 75, "ZC1", nil, nil, nil, nil, nil,) 

return


/*
+--------------------------------------------------------------------------+
! Função    ! MNTCTE     ! Autor !Marcio A.Sugahara   ! Data ! 12/08/2019  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Rotina para Visualizar ou excluir.                           !
+-----------+--------------------------------------------------------------+
*/
User Function MNTCTE(cAlias,nRecno,nOpc)

	//Declaração de Variaveis
	Local i:=0
	Local cLinok   := "Allwaystrue"
	Local cTudook  := "Allwaystrue"
	Local nOpce    := nopc
	Local nOpcg    := nopc
	Local cFieldok := "allwaystrue"
	Local lVirtual := .T.
	Local nLinhas  := 99
	Local nFreeze  := 0
	Local lRet     := .T. 
	Local nTotOS   := 0
	Private aCols := {}
	Private aHeader := {}
	Private aCpoEnchoice := {}
	Private aAltEnchoice := {}
	Private aAlt := {}

	Regtomemory("ZC1",(nOpc==3))

	Regtomemory("ZC2",(nOpc==3))

	//Criar o vetor aHeader, que eh o vetor que tem as caracteristicas para os campos da Getdados
	CriaHeader()

	//Criar o vetor aCols, que eh o vetor que tem os dados preenchidos pelo usuario, relacionado com o vetor aHeader
	CriaCols(nOpc)

	lRet:=Modelo3(cCadastro,"ZC1","ZC2",aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,nLinhas,aAltenchoice,nFreeze,,,250)

	//Se confirmado
	if lRet	
		if nOpc == 1 //Se opção for exclusão 
			if MsgYesNo("Confirma exclusão dos dados ?", cCadastro)
				Processa({||Excluidados()},cCadastro,"Excluindo os dados, aguarde...")
			endif
		endif
	endif
return

/*
+--------------------------------------------------------------------------+
! Função    ! CriaHeader ! Autor !Marcio A.Sugahara   ! Data ! 12/08/2019  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Rotina para criar array aHeader                              !
+-----------+--------------------------------------------------------------+
*/
Static Function CriaHeader()

	aHeader:= {}
	aCpoEnchoice := {}
	aAltEnchoice :={}

	SX3->(dbsetorder(1))
	SX3->(dbseek("ZC2"))
	while ! SX3->(eof()) .and. SX3->x3_arquivo == "ZC2"
		if x3uso(SX3->x3_usado) .and. cnivel >= SX3->x3_nivel
			aAdd(aHeader,{trim(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture,SX3->x3_tamanho,SX3->x3_decimal,SX3->x3_valid,SX3->x3_usado,SX3->x3_tipo,SX3->x3_arquivo,SX3->x3_context})
		endif

		SX3->(dbskip())

	end

	SX3->(dbseek("ZC1"))
	while !SX3->(eof()) .and. SX3->x3_arquivo == "ZC1"
		if x3uso(SX3->x3_usado) .and. cnivel >= SX3->x3_nivel
			aAdd(aCpoEnchoice,SX3->x3_campo)
			aAdd(aAltEnchoice,SX3->x3_campo)

		endif

		SX3->(dbskip())

	end

return()

/*
+--------------------------------------------------------------------------+
! Função    ! CriaCols   ! Autor !Marcio A.Sugahara   ! Data ! 12/08/2019  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Rotina para criar array aCols                                !
+-----------+--------------------------------------------------------------+
*/
Static function CriaCols(nOpc)

	Local nQtdcpo := 0
	Local i:= 0
	Local nCols := 0
	Local nQtdcpo := len(aHeader)  //aHeader é a estrutura dos campos (sx3) nQtdcop é a quantidade de campos na tabela ze1
	Local cQuery := "" 
	aCols:= {}

	cQuery += " SELECT R_E_C_N_O_ ZC2_RECNO "
	cQuery += " FROM "+RetSqlName("ZC2")
	cQuery += " WHERE ZC2_FILIAL = '"+xFilial("ZC2")+"' AND "
	cQuery += "   ZC2_CTE = '"+ZC1->ZC1_CTE+"' AND "
	cQuery += "   D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery(cQuery)

	if Select("TRBZC2")<>0
		TRBZC2->(dbCloseArea())
	EndIF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBZC2",.T.,.T.)
	
	while !TRBZC2->(eof())
		DbSelectArea("ZC2")
		ZC2->(DbGoto(TRBZC2->ZC2_RECNO))
		aAdd(aCols,array(nQtdcpo+1))
		nCols++

		for i:= 1 to nQtdcpo
			if aHeader[i,10] <> "V"
				aCols[nCols,i] := Fieldget(Fieldpos(aHeader[i,2]))
			else
				aCols[nCols,i] := Criavar(aHeader[i,2],.T.)
			endif

		next i

		aCols[nCols,nQtdcpo+1] := .F.

		TRBZC2->(dbskip())
	end

return()

/*
+--------------------------------------------------------------------------+
! Função    ! Excluidados! Autor !Marcio A.Sugahara   ! Data ! 12/08/2019  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Rotina que exclui registros da ZC1, ZC2, ZC3                 !
+-----------+--------------------------------------------------------------+
*/
Static Function Excluidados()

	local cTipoT :=""
	PRIVATE lMsErroAuto := .F.

	procregua(len(aCols)+1)

	TRBZC2->(DbGotop())
	while !TRBZC2->(eof()) 
		ZC2->(DbGoto(TRBZC2->ZC2_RECNO))

		incproc()
		Reclock("ZC2",.F.)
		ZC2->(DbDelete())
		Msunlock()

		TRBZC2->(dbskip())
	end

	ZC3->(dbsetorder(1))
	ZC3->(dbseek(xfilial("ZC3")+ZC1->ZC1_CTE))

	while !ZC3->(eof()) .and. ZC3->ZC3_FILIAL == xfilial("ZC3") .and. ZC3->ZC3_CTE==ZC1->ZC1_CTE
		incproc()
		Reclock("ZC3",.F.)
		ZC3->(DbDelete())
		Msunlock()

		ZC3->(dbskip())
	end

	incproc()

	Reclock("ZC1",.F.)
	ZC1->(DbDelete())
	Msunlock()

return()