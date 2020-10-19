/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! COM - Compras   	                                     !
+------------------+---------------------------------------------------------+
!Nome              ! MT120APV                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. para manipular o grupo de aprovação no C. Alcadas  !
+------------------+---------------------------------------------------------+
!Autor             ! PAULO AFONSO ERZINGER JUNIOR                            !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/10/2012                                              !
+------------------+---------------------------------------------------------+
*/

#include "protheus.ch"
#include "topconn.ch"


User Function MT120APV()

	Local cAlias   := GetNextAlias()
	Local aGrupo   := {}
	Local cGrupo   := SPACE(TAMSX3("C7_APROV")[1])
	Local cTpAprov := ""
	Local _aArea := GetArea()


	// Retorna conteúdo tipo de aprovadores que deve aparecer para o SIGACOM
	// A = Busca todos os grupos de aprovação
	// B = Busca somente os grupos de aprovacao de compras   (AL_XGRPCTR ="N")
	Local cApvCOM := Alltrim(GetMV("TCP_APVCOM",,""))

	// Retorna conteúdo tipo de aprovadores que deve aparecer para o SIGACGT
	// A = Busca todos os grupos de aprovação
	// B = Busca somente os grupos de aprovacao de contratos (AL_XGRPCTR ="S")
	Local cApvCGT := Alltrim(GetMV("TCP_APVCGT",,""))

Local _lIntSal := GETMV( 'TCP_PCSFOR' ) 

Private cAlDoc :=  "SC7"
Private nRegDoc := SC7->(Recno())
Private cChaveAne := ''
Private nTotal  := 0

//Valida se existe anexo, e se não existir abre a tela de inclusão. Após a confirmação, valida denovo. Só para quando tiver anexo.
	do while !validaAnexo()
	enddo

	RestArea(_aArea)

If !_lIntSal 

	BeginSql alias cAlias
		SELECT DISTINCT AL_COD, AL_DESC, AL_XGRPCTR
		FROM %table:SAL% SAL
		WHERE SAL.%notDel% AND AL_MSBLQL != '1'
	EndSql
	
	If IsInCallStack("CNTA120") .OR. IsInCallStack("CNTA121") // Pedido gerado pelo módulo de Gestão de Contratos
		
		dbSelectArea(cAlias)
		dbGoTop()
		While !Eof()
			
			// Variavel que define se aprovador é de contrato ou não.
			cTpAprov := (cAlias)->AL_XGRPCTR
			
			If cApvCGT =="B" // somente grupos de aprovadores de contratos
				If cTpAprov =="S" // filtra somente os aprovadores tipo contrato
					AADD(aGrupo,{(cAlias)->AL_COD,(cAlias)->AL_DESC})
				EndIf
			Else
				AADD(aGrupo,{(cAlias)->AL_COD,(cAlias)->AL_DESC})
			EndIf
			
			dbSelectArea(cAlias)
			(cAlias)->(dbSkip())
		EndDo
		
	Else
		
		dbSelectArea(cAlias)
		dbGoTop()
		While !Eof()
			
			// Variavel que define se aprovador é de contrato ou não.
			cTpAprov := (cAlias)->AL_XGRPCTR
			
			If cApvCOM =="B"   // somente grupos de aprovadores de compras
				If cTpAprov =="N"  // filtra somente os aprovadores tipo compras
					AADD(aGrupo,{(cAlias)->AL_COD,(cAlias)->AL_DESC})
				EndIf
			Else
				AADD(aGrupo,{(cAlias)->AL_COD,(cAlias)->AL_DESC})
			EndIf
			
			dbSelectArea(cAlias)
			(cAlias)->(dbSkip())
		EndDo
		
	EndIf
endif

lCOnt:=.f.
cGrupo := ''
IF LEN(aGrupo) > 0
	While !lCOnt
		DEFINE MSDIALOG oDlgAprov TITLE "[MT120APV] - Definir grupo de aprovação" From 001,001 to 380,615 Pixel Style DS_MODALFRAME
		//========================// Browse com os títulos //========================//
		oDlgAprov:lEscClose     := .F.
		oBrwGrp := TCBrowse():New(010,005,300,150,,,,oDlgAprov,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		
		oBrwGrp:AddColumn(TCColumn():New("Grupo"      , {|| aGrupo[oBrwGrp:nAt,01]},,,,, ,.F.,.F.,,,,.F., ) )
		oBrwGrp:AddColumn(TCColumn():New("Descrição"  , {|| aGrupo[oBrwGrp:nAt,02]},,,,, ,.F.,.F.,,,,.F., ) )
		oBrwGrp:SetArray(aGrupo)
		
		oBrwGrp:bLDblClick   := { || cGrupo := aGrupo[oBrwGrp:nAt,01], oDlgAprov:End()}
		
		ACTIVATE MSDIALOG oDlgAprov CENTERED
		if !Empty(alltrim(cGrupo))
			lCOnt:= .T.
		Else
			aviso("Atencao", "Obrigatorio informar o grupo ",{"OK"})
		EndIF
	EndDo
ENDIF

Return cGrupo


static function validaAnexo()

	Local lTemMSErr := IF(TYPE('lMSErroAuto') != 'U',.T.,.F.)
	lOCAL _lMsErroAx := IF(lTemMSErr,lMSErroAuto,.F.)
	Local lRet 	  := .F.
	Local nValMin :=  GetNewPar("TCP_VALMIN",10000)
	Local _cMoeda := SC7->C7_MOEDA
	Local _dEmissao := SC7->C7_EMISSAO
	
	//Valida se está vazio, para enrtar apenas na primeira vez e evitar consultas desnecessaárias
	if EMPTY(cChaveAne)
		cAliasAx   := GetNextAlias()
		nTotal     := 0
		//Valida se o pedido possui anexos, e se em nenhum item existir, chama a rotina de anexos.,

		BeginSQL Alias cAliasAx
		 
		SELECT C7_FILIAL,C7_NUM,C7_ITEM,C7_CONTRA,C7_CONTREV,C7_MEDICAO,C7_NUMSC,C7_PLANILH,C7_ITEMSC, C7_TOTAL, C7_EMISSAO, C7_MOEDA
		FROM %TABLE:SC7% SC7
		WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:SC7->C7_FILIAL% AND C7_NUM = %EXP:SC7->C7_NUM%

		EndSQL
		
		//cChaveAne := "%'SC7" + SC7->C7_FILIAL+ SC7->C7_NUM+SC7->C7_ITEM + "'"
		cChaveAne := "%" + fBuildKey( "SC7" )

		WHILE !(cAliasAx)->(Eof())

			nTotal += (cAliasAx)->C7_TOTAL
			_dEmissao := CTOD( (cAliasAx)->C7_EMISSAO)
			_cMoeda := (cAliasAx)->C7_MOEDA

			If IsInCallStack("CNTA120")
				
				/*cChaveAne += ",'CND"+ALLTRIM(CND->CND_FILIAL)+ALLTRIM(CND->CND_CONTRA)+ALLTRIM(CND->CND_REVISA) +ALLTRIM(CND->CND_NUMMED)+ "'"
				cChaveAne += ",'CND"+CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA +CND->CND_NUMMED+ "'"
				cChaveAne += ",'CND"+CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_NUMMED+ "'"*/

				cChaveAne += "," + fBuildKey( "CND" )

				cAlDoc :=  "CND"
				nRegDoc := CND->(Recno())

			ENDIF

			IF !EMPTY((cAliasAx)->C7_NUMSC)
				//cChaveAne += ",'SC1"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_NUMSC+(cAliasAx)->C7_ITEMSC + "'"
				cChaveAne += "," + fBuildKey( "SC1" )
				DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
				If SC1->(DbSeek((cAliasAx)->C7_FILIAL+(cAliasAx)->C7_NUMSC+(cAliasAx)->C7_ITEMSC))
					cAlDoc :=  "SC1"
					nRegDoc := SC1->(Recno())
				ENDIF
			endif

			(cAliasAx)->(DbSkip())

		ENDDO

		cChaveAne += "%"

		IF (_cMoeda != 1)
			nTotal := XMOEDA(nTotal,_cMoeda,1,_dEmissao)
		ENDIF
		
		(cAliasAx)->(dbCloseArea())
	
	EndIF

	cAliasAx   := GetNextAlias()

	BeginSQL Alias cAliasAx
	 
	SELECT *
	FROM %TABLE:AC9% AC9
	INNER JOIN %TABLE:ACB% ACB ON ACB_FILIAL = AC9_FILIAL AND 
								  AC9_CODOBJ = ACB_CODOBJ  AND 
								  ACB.%NotDel% 
	WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChaveAne%)

	EndSQL

	lPtoPed := .F.
	dbSelectArea('SC1')
	SC1->(dbSetOrder(1))
	if !empty(SC7->C7_NUMSC) .AND. SC1->(dbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
		if ALLTRIM(SC1->C1_ORIGEM) == 'MATA170'
			lPtoPed := .T.
		endif
	ENDIF

	//Só vai obrigar anexo Se:     for pedido sob contrato e valor maior q 10000       ou não for sob contrato, não for ponto de pedido e se tiver cotação só se o valor for maior que 10000

	dbSelectArea(cAliasAx)
	(cAliasAx)->(dbGoTop())

	IF (cAliasAx)->(Eof()) .AND. (((SC7->C7_CONTRAT == 'S' .AND. nTotal > nValMin ) .OR. SC7->C7_CONTRAT != 'S' ) .AND. !lPtoPed .AND. ;
			(EMPTY(SC7->C7_NUMCOT) .OR. (!EMPTY(SC7->C7_NUMCOT) .AND. nTotal > nValMin ) ) .OR. MsgNoYes( "Anexos não são obrigatório para este pedido! Deseja adicionar mesmo assim ?", 'Adicionar Anexo.' ))

		lRet := .F.

		//alert('É obrigatório adicionar ao menos 1 arquivo.')
		if IsInCallStack("MATA161")
			U_TCPGED(cAlDoc,nRegDoc, 2)
		ELSE
			U_TCPGED(cAlDoc,nRegDoc, 4)
		ENDIF
	else
		lRet := .T.
	endif

	IF(lTemMSErr)
		//Volta o valor dessa variável, pois quando o anexo gerava erro de anexo duplicado, o sistema marcava lMSErroAuto como erro, mesmo o usuário já tendo alterado o nome.
		lMSErroAuto:= _lMsErroAx
	ENDIF
	
	(cAliasAx)->(dbCloseArea())

return lRet

/*/{Protheus.doc} fBuildKey
Busca a chave da entidade 
@type function
@version 1.0
@author Kaique Mathias
@since 06/07/2020
@param cEntidade, character, param_description
@return character, cChave
/*/

Static Function fBuildKey( cEntidade )

	Local cChaveEnt := U_TCPGEDENT( cEntidade )[1]
	Local cChaveAne := "'" + cEntidade + cChaveEnt + "'"

Return( cChaveAne )
