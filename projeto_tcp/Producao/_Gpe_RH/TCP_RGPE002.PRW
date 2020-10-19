#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE CRLF CHR(13)+CHR(10)  

#define STR0001 If( cPaisLoc $ "ANG|PTG", "Espelho Do Ponto", "Espelho do Ponto" )
#define STR0002 If( cPaisLoc $ "ANG|PTG", "Será impresso de acordo com os parâmetros solicitados pelo", "Será impresso de acordo com os parametros solicitados pelo" )
#define STR0003 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usuario." )
#define STR0004 If( cPaisLoc $ "ANG|PTG", "Registo", "Matricula" )
#define STR0005 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
#define STR0006 "Nome"
#define STR0007 "Turno"
#define STR0008 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
#define STR0009 If( cPaisLoc $ "ANG|PTG", "Administração", "Administraçäo" )
#define STR0013 If( cPaisLoc $ "ANG|PTG", "Assinatura do Empregado", "Assinatura do Funcionario" )
#define STR0014 "T O T A I S"
#define STR0015 If( cPaisLoc $ "ANG|PTG", "Cód descrição                cálc.            cód descrição                cálc.          ", "Cod Descricao                Calc.            Cod Descricao                Calc.          " )
#define STR0016 If( cPaisLoc $ "ANG|PTG", "Cód Descrição                         Infor.  Cód Descrição                         Infor.", "Cod Descricao                         Infor.  Cod Descricao                         Infor." )
#define STR0017 If( cPaisLoc $ "ANG|PTG", "Cód Descrição                Cálc.    Infor.  Cód Descrição                Cálc.    Infor.", "Cod Descricao                Calc.    Infor.  Cod Descricao                Calc.    Infor." )
#define STR0018 If( cPaisLoc $ "ANG|PTG", "** excepção não trabalhada **", "** Excecao nao Trabalhada **" )
#define STR0019 If( cPaisLoc $ "ANG|PTG", "** feriado **", "** Feriado **" )
#define STR0020 If( cPaisLoc $ "ANG|PTG", "** ausente **", "** Ausente **" )
#define STR0021 If( cPaisLoc $ "ANG|PTG", "** d.s.r. **", "** D.S.R. **" )
#define STR0022 If( cPaisLoc $ "ANG|PTG", "** Compensado", "** Compensado **" )
#define STR0023 If( cPaisLoc $ "ANG|PTG", "** não trabalhado **", "** Nao Trabalhado **" )
#define STR0024 If( cPaisLoc $ "ANG|PTG", "Emp.:", "Emp...: " )
#define STR0025 If( cPaisLoc $ "ANG|PTG", "Reg.:", " Matr..: " )
#define STR0026 If( cPaisLoc $ "ANG|PTG", "  Cartão Reg.: ", "  Chapa : " )
#define STR0027 If( cPaisLoc $ "ANG|PTG", "Morada:", "End...: " )
#define STR0028 " Nome..: "
#define STR0029 If( cPaisLoc $ "ANG|PTG", "NIF", "CGC...: " )
#define STR0030 If( cPaisLoc $ "ANG|PTG", " função: ", " Funcao: " )
#define STR0031 If( cPaisLoc $ "ANG|PTG", "C.c.:", "C.C...: " )
#define STR0032 " Categ.: "
#define STR0033 If( cPaisLoc $ "ANG|PTG", "Turno:", "Turno.: " )
#define STR0034 "   DATA    DIA     "
#define STR0035 If( cPaisLoc $ "ANG|PTG", "A.e.", "a E. " )
#define STR0036 If( cPaisLoc $ "ANG|PTG", "A s. ", "a S. " )
#define STR0037 If( cPaisLoc $ "ANG|PTG", "Observação  Horas  Tipo Da Marcação", "Observacao                Horas  Tipo da Marcacao" )
#define STR0038 If( cPaisLoc $ "ANG|PTG", "C.custo + Nome", "C.Custo + Nome" )
#define STR0039 If( cPaisLoc $ "ANG|PTG", "Período De Apontamento Inválido.", "Periodo de Apontamento Invalido." )
#define STR0040 If( cPaisLoc $ "ANG|PTG", "Consultar Marcações", "Consultar Marca&ccedil;&otilde;es" )
#define STR0041 If( cPaisLoc $ "ANG|PTG", "Motivo De Autorização", "Motivo de Abono" )
#define STR0042 "Data"
#define STR0043 "Dia"
#define STR0044 If( cPaisLoc $ "ANG|PTG", "&#170;e.", "&#170;E." )
#define STR0045 If( cPaisLoc $ "ANG|PTG", "&#170;s.", "&#170;S." )
#define STR0046 If( cPaisLoc $ "ANG|PTG", "Observa&çõe&s", "Observa&ccedil;&otilde;es" )
#define STR0047 If( cPaisLoc $ "ANG|PTG", "Horas   Tipo Da Marca&çã&o", "Horas  Tipo da Marca&ccedil;&atilde;o" )
#define STR0048 If( cPaisLoc $ "ANG|PTG", "Turno", "Turno " )
#define STR0049 If( cPaisLoc $ "ANG|PTG", "Turnos:", "Turnos: " )
#define STR0050 If( cPaisLoc $ "ANG|PTG", "Processo + registo", "Processo + Matrícula" )
#define STR0051 "Depto.: "
#define STR0052 If( cPaisLoc $ "ANG|PTG", "Seleccionar a opção  de impressao: ", "Selecione a opção de impressão: " )
#define STR0053 "Por Período"
#define STR0054 "Por Datas"
#define STR0055 "Processo: "
#define STR0056 "Período: "
#define STR0057 If( cPaisLoc $ "ANG|PTG", "Mapa: ", "Roteiro: " )
#define STR0058 If( cPaisLoc $ "ANG|PTG", "Num.pgt: ", "Num.Pagto: " )
#define STR0059 "Informado                 Horas"
#DEFINE STR0060 "Departamento"
#DEFINE STR0061 "Departamento + Nome"
#DEFINE STR0062 "Abonos"
#DEFINE STR0063 "Observação"
#DEFINE STR0064 "Codigo"
#DEFINE STR0065 "Descrição"
#DEFINE STR0066 "Calculado"
#DEFINE STR0067 "Informado"
#DEFINE STR0068 "H.E."
#DEFINE STR0069 "Falt/Atra"
#DEFINE STR0070 "Ad. Not."
#DEFINE STR0071 "Empresa: "
#DEFINE STR0072 " Matr..: "
#DEFINE STR0073 "  Chapa : "
#DEFINE STR0074 " Nome..: "
#DEFINE STR0075 "CGC: "
#DEFINE STR0076 "Funcao: "
#DEFINE STR0077 "C.C...: "
#DEFINE STR0078 " Categ.: "
#define STR0079 "Periodo Anterior"
#DEFINE STR0080 "Para esse relatório o parametro MV_COLMARC deve ser menor ou igual à 5."
#DEFINE STR0081 "Banco de Horas"
#DEFINE STR0082 "Saldo Anterior"
#DEFINE STR0083 "Débito"
#DEFINE STR0084 "Crédito"
#DEFINE STR0085 "Saldo Atual"
#Define STR0088 "Sit...: "
#DEFINE STR0089 "Período: "
#DEFINE STR0090 "AFASTADO"
#DEFINE STR0091 "FERIAS"
#DEFINE STR0092 "TRANSFERIDO"
#DEFINE STR0093 "DEMITIDO"
#DEFINE STR0094 "NORMAL"
#DEFINE STR0095 "CEI: "
#DEFINE STR0096 "CPF: "

//******************************
/*/{Protheus.doc} RGPE002
Rotina congelada a partir do relatório padrão PONR010 do Protheus 12.1.17

@author Lucas
@since 12/04/2018
@version 1.0

@return Caracter, Retorna um html formado

@type function
/*/
//******************************
User Function RGPE002( lTerminal , cFilTerminal , cMatTerminal , cPerAponta, lPortal, aRetPortal )

	Local aArea		 := GetArea()
	Local aOrdem     := {STR0004 , STR0005 , STR0006 , STR0007, STR0038, STR0060, STR0061  } // 'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo + Nome'###'Departamento'###'Departamento + Nome'
	Local cHtml		 := ""
	Local cAviso
	Local aFilesOpen := {"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
	Local bCloseFiles:= {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }
	Local oPrinter
	Local oSetup
	Local cSession	 := GetPrinterSession()
	Local cDevice    := fwGetProfString(cSession,"PRINTTYPE","PDF",.T.)
	Local cDestino	 := fwGetProfString(cSession,"DEFAULT","c:\",.T.)
	Local nFlags   	 := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION

	// Define Variaveis Private(Basicas)
	Private nomeprog := 'PONR010'
	Private nLastKey := 0
	Private cPerg    := 'RGPE002'

	// Define variaveis Private utilizadas no programa RDMAKE ImpEsp
	Private aImp      := {}
	Private aTotais   := {}
	Private aAbonados := {}
	Private aAfast    := {}
	Private nImpHrs   := 0

	// Variaveis Utilizadas na funcao IMPR
	Private Titulo   := OemToAnsi( 'Espelho do Ponto' )

	// Define Variaveis Private(Programa)
	Private dPerIni  := Ctod("//")
	Private dPerFim  := Ctod("//")
	Private cMenPad1 := Space(30)
	Private cMenPad2 := Space(19)
	Private cFilSPA	 := xFilial("SPA", SRA->RA_FILIAL)
	Private nOrdem   := 1
	Private aInfo    := {}
	Private aTurnos  := {}
	Private aPrtTurn := {}
	Private nColunas := 0
	Private aNaES	 := {}
	Private nCol	 := 0
	Private nColTot	 := 0
	Private nLinTot	 := 0
	Private aMargRel := {}
	Private nLin	 := 0
	Private nPxData	 :=	0
	Private nPxSemana:= 0
	Private nPxAbonos:= 0
	Private nPxHe	 := 0
	Private nPxFalta := 0
	Private nPxAdnNot:= 0
	Private nPxObser := 0
	Private lImpMarc := .T.
	Private lCodeBar := .F.
	Private lBigLine := .T.

	DEFAULT lTerminal := .F.

	#DEFINE Imp_Spool      	2
	#DEFINE ALIGN_H_LEFT   	0
	#DEFINE ALIGN_H_RIGHT  	1
	#DEFINE ALIGN_H_CENTER 	2
	#DEFINE ALIGN_V_CENTER 	0
	#DEFINE ALIGN_V_TOP	   	1
	#DEFINE ALIGN_V_BOTTON 	2
	#DEFINE oFontT 			TFont():New( "Verdana", 09, 09, , .T., , , , .T., .F. )//Titulo
	#DEFINE oFontP 			TFont():New( "Verdana", 09, 09, , .T., , , , .T., .F. )//Linhas
	#DEFINE oFontM 			TFont():New( "Verdana", 07, 07, , .F., , , , .T., .F. )//Marcacoes
	#DEFINE oFontO 			TFont():New( "Verdana", 04, 04, , .F., , , , .T., .F. )//Marcacoes
	#DEFINE oFont06 		TFont():New( "Verdana", 06, 06, , .T., , , , .T., .F. )//CodeBar

	lPortal   := IF( lPortal == NIL , .F. , lPortal )

	// Parƒmetro MV_COLMARC
	IF lPortal .OR. RGPE0020()
		nColunas := SuperGetmv("MV_COLMARC")
	Else
		Help("", 1,OemToAnsi( STR0080 ),,OemToAnsi( STR0080 ),1,0)//"Para esse relatório o parametro MV_COLMARC deve ser menor ou igual à 5."
		Return( .F. )
	ENDIF

	If ( nColunas == NIL )
		Help("", 1, "MVCOLNCAD")
		Return( .F. )
	EndIf

	// O numero de colunas eh sempre aos pares
	nColunas *= 2

	// Envia controle para a funcao SETPRINT
	If !( lTerminal )
		aDevice := {}		
		
		// Define os Tipos de Impressao validos		
		AADD(aDevice,"DISCO")
		AADD(aDevice,"SPOOL")
		AADD(aDevice,"EMAIL")
		AADD(aDevice,"EXCEL")
		AADD(aDevice,"HTML" )
		AADD(aDevice,"PDF"  )

		// Realiza as configuracoes necessarias para a impressao
		nPrintType := aScan(aDevice,{|x| x == cDevice })
		nLocal     := If( fWGetProfString( cSession, "LOCAL", "SERVER", .T. ) == "SERVER", 1, 2 )

		oSetup := FWPrintSetup():New(nFlags, Titulo)
		oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } )
		oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
		oSetup:SetPropert(PD_ORIENTATION , 2)
		oSetup:SetPropert(PD_DESTINATION , nLocal)
		oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
		oSetup:SetPropert(PD_PAPERSIZE   , 2)
		oSetup:SetPropert(PD_PREVIEW,.T.)
		oSetup:SetOrderParms(aOrdem,@nOrdem)

		If cDevice == "PDF"
			oSetup:aOptions[PD_VALUETYPE] := cDestino
		EndIf

		oPrinter := FWMSPrinter():New( 'PONR010', IMP_PDF , .F., , .T., , oSetup )

		If !(oSetup:Activate() == PD_OK)
			oPrinter:Deactivate()
			Return
		EndIf

		oPrinter:lServer := oSetup:GetProperty( PD_DESTINATION ) == AMB_SERVER
		oPrinter:SetResolution( 75 )

		If oSetup:GetProperty( PD_ORIENTATION ) == 2
			oPrinter:SetLandscape()
		Else
			oPrinter:SetPortrait()
		EndIf

		oPrinter:SetPaperSize( oSetup:GetProperty( PD_PAPERSIZE ) )
		oPrinter:SetMargin(oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4])
		aMargRel := {oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4]}

		fwWriteProfString(cSession,"LOCAL", If(oSetup:GetProperty(PD_DESTINATION)==1,"SERVER","LOCAL"), .T.)
		fwWriteProfString(cSession,"PRINTTYPE", aDevice[oSetup:GetProperty( PD_PRINTTYPE )], .T.)

		If oSetup:GetProperty( PD_PRINTTYPE ) == Imp_Spool

			oPrinter:nDevice := Imp_Spool
			fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]

		ElseIf oSetup:GetProperty( PD_PRINTTYPE ) == IMP_PDF

			oPrinter:nDevice := IMP_PDF
			fwWriteProfString(cSession,"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]

		EndIf
	EndIf

	// Verifica as perguntas selecionadas
	Pergunte( cPerg , .F. )

	// Carregando variaveis MV_PAR?? para Variaveis do Sistema.
	FilialDe	:= IF( !lTerminal , MV_PAR01, cFilTerminal )			//Filial  De
	FilialAte	:= IF( !lTerminal , MV_PAR02, cFilTerminal )			//Filial  Ate
	CcDe		:= IF( !lTerminal , MV_PAR03, SRA->RA_CC   )			//Centro de Custo De
	CcAte		:= IF( !lTerminal , MV_PAR04, SRA->RA_CC   )			//Centro de Custo Ate
	TurDe		:= IF( !lTerminal , MV_PAR05, SRA->RA_TNOTRAB)			//Turno De
	TurAte		:= IF( !lTerminal , MV_PAR06, SRA->RA_TNOTRAB)			//Turno Ate
	MatDe		:= IF( !lTerminal , MV_PAR07, cMatTerminal)				//Matricula De
	MatAte		:= IF( !lTerminal , MV_PAR08, cMatTerminal)				//Matricula Ate
	NomDe		:= IF( !lTerminal , MV_PAR09, SRA->RA_NOME)				//Nome De
	NomAte		:= IF( !lTerminal , MV_PAR10, SRA->RA_NOME)				//Nome Ate
	cSit		:= IF( !lTerminal , MV_PAR11, fSituacao( NIL , .F. ))	//Situacao
	cCat		:= IF( !lTerminal , MV_PAR12, fCategoria( NIL , .F. ))	//Categoria
	nImpHrs		:= IF( !lTerminal , MV_PAR13, 3 )						//Imprimir horas Calculadas/Inform/Ambas/NA
	nImpAut		:= IF( !lTerminal , MV_PAR14, 1 )						//Demonstrar horas Autoriz/Nao Autorizadas
	nCopias		:= IF( !lTerminal , If(MV_PAR15>0,MV_PAR15,1),1)		//N£mero de C¢pias
	lSemMarc	:= IF( !lTerminal , (MV_PAR16==1)	, .F. )				//Imprime para Funcion rios sem Marca‡oes
	cMenPad1	:= IF( !lTerminal , MV_PAR17, "" )						//Mensagem padr„o anterior a Assinatura
	cMenPad2	:= IF( !lTerminal , MV_PAR18, "" )						//Mens. padr„o anterior a Assinatura(Cont.)
	dPerIni     := IF( !lTerminal ,;
	MV_PAR19,Stod( Subst( cPerAponta , 1 , 8 ) ))	//Data Contendo o Inicio do Periodo de Apontamento
	dPerFim     := IF( !lTerminal ,;
	MV_PAR20,Stod( Subst( cPerAponta , 9 , 8 ) ))	//Data Contendo o Fim  do Periodo de Apontamento
	lSexagenal	:= IF( !lTerminal , (MV_PAR21==1), .T.  )				//Horas em  (Sexagenal/Centesimal)
	lImpRes		:= IF( !lTerminal , (MV_PAR22==1), .F.	)				//Imprime eventos a partir do resultado ?
	lImpTroca   := IF( !lTerminal , (MV_PAR23==1), .F.	)				//Imprime Descricao Troca de Turnos ou o Atual
	lImpExcecao := IF( !lTerminal , (MV_PAR24==1), .F.	)				//Imprime Descricao da Excecao no Lugar da do Afastamento
	DeptoDe		:= IF( !lTerminal , MV_PAR25, SRA->RA_DEPTO   )			//Departamento De
	DeptoAte	:= IF( !lTerminal , MV_PAR26, SRA->RA_DEPTO   )			//Departamento Ate
	lImpMarc 	:= IF( !lTerminal , MV_PAR27==1, .T.   )		 		//Imprime marcações? .T.
	lCodeBar 	:= IF( !lTerminal , MV_PAR28==1, .F.   ) 				//Imprime código de barras? .F.
	lBigLine 	:= IF( !lTerminal , MV_PAR29==1, .T.   ) 				//Destaca linhas? .T.
	lImpBh 		:= IF( !lTerminal , MV_PAR30==1, .F.   ) 				//Imprime banco de horas

	// Redefine o Tamanho das Mensagens Padroes
	cMenpad1 := IF(Empty( cMenPad1 ) , Space( 30 ) , cMenPad1 )
	cMenpad2 := IF(Empty( cMenPad2 ) , Space( 19 ) , cMenPad2 )

	Begin Sequence

		If ( lTerminal )
			//-- Verifica se foi possivel abrir os arquivos sem exclusividade
			If Pn090Open(@cHtml, @cAviso)
				cHtml := ""
				cHtml := Pnr010Imp( NIL , lTerminal, lPortal, aRetPortal  )
				// Apos a obtencao da consulta solicitada fecha os arquivos
				// utilizados no fechamento mensal para abertura exclusiva				
				Aeval(aFilesOpen, bCloseFiles)
			Else
				cHtml := HtmlDefault( cAviso , cHtml )
			Endif
		ElseIf !( nLastKey == 27 )

			If Pn090Open(@cHtml, @cAviso)
				If Empty( dPerIni ) .or. Empty( dPerFim )
					Help(" ",1,"PONFORAPER" , , OemToAnsi( STR0039 ) , 5 , 0  )	//'Periodo de Apontamento Invalido.'
					Break
				EndIf

				If !( nLastKey == 27 )
					RptStatus( { |lEnd| Pnr010Imp(@lEnd, lTerminal, ,,oPrinter ) } , Titulo )
				EndIf
			Else
				MsgStop( cHtml, cAviso )
				cHtml := ""
			EndIf
		EndIf

	End Sequence

	If !lTerminal
		oPrinter:Preview()
	EndIf

Return( cHtml )

//******************************
/*/{Protheus.doc} Pnr010Imp
Espelho do Ponto - rotina para impressão do relatório

@author Lucas
@since 12/04/2018
@version 1.0

@return Caracter, Retorna um html formado

@type function
/*/
//******************************
Static Function Pnr010Imp( lEnd , lTerminal, lPortal, aRetPortal, oPrinter )

	Local aAbonosPer	:= {}
	Local cOrdem		:= ""
	Local cWhere		:= ""
	Local cSituacao		:= ""
	Local cCategoria	:= ""
	Local cLastFil		:= "__cLastFil__"
	Local cAcessaSRA	:= &("{ || " + ChkRH("PONR010","SRA","2") + "}")
	Local cSeq			:= ""
	Local cTurno		:= ""
	Local cHtml			:= ""
	Local cAliasSRA		:= GetNextAlias()
	Local cAliasQTD		:= GetNextAlias()
	Local lSPJExclu		:= !Empty( xFilial("SPJ") )
	Local lSP9Exclu		:= !Empty( xFilial("SP9") )
	Local nCount		:= 0.00
	Local nX			:= 0.00
	Local lMvAbosEve	:= .F.
	Local lMvSubAbAp	:= .F.
	
	Private aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
	Private aMarcacoes := {}
	Private aTabPadrao := {}
	Private aTabCalend := {}
	Private aPeriodos  := {}
	Private aId		   := {}
	Private aResult	   := {}
	Private aBoxSPC	   := LoadX3Box("PC_TPMARCA")
	Private aBoxSPH	   := LoadX3Box("PH_TPMARCA")
	Private cCodeBar   := ""
	Private dIniCale   := Ctod("//")	//-- Data Inicial a considerar para o Calendario
	Private dFimCale   := Ctod("//")	//-- Data Final a considerar para o calendario
	Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
	Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
	Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto
	Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto
	Private lImpAcum   := .F.

	// ajuste para customização
	private CR6TNOOPC := ''
	
	lMvAbosEve	:= ( Upper(AllTrim(SuperGetMv("MV_ABOSEVE",NIL,"N"))) == "S" )	//--Verifica se Deduz as horas abonadas das horas do evento Sem a necessidade de informa o Codigo do Evento no motivo de abono que abona horas
	lMvSubAbAp	:= ( Upper(AllTrim(SuperGetMv("MV_SUBABAP",NIL,"N"))) == "S" )
	
	/*Como a Cada Periodo Lido reinicializamos as Datas Inicial e Final 
	preservamos-as nas variaveis: dCaleIni e dCaleFim.*/
	dIniCale   := dPerIni   //-- Data Inicial a considerar para o Calendario
	dFimCale   := dPerFim   //-- Data Final a considerar para o calendario

	For nX:=1 to Len(cSit)
		If Subs(cSit,nX,1) <> "*"
			cSituacao += "'"+Subs(cSit,nX,1)+"'"
			If ( nX+1 ) <= Len(cSit)
				cSituacao += ","
			EndIf
		EndIf
	Next nX

	If !Empty(cSituacao) .and. Subs(cSituacao,Len(cSituacao),1) == ","
		cSituacao := Subs(cSituacao,1,Len(cSituacao)-1)
	EndIf

	For nX:=1 to Len(cCat)
		If Subs(cCat,nX,1) <> "*"
			cCategoria += "'"+Subs(cCat,nX,1)+"'"
			If ( nX+1 ) <= Len(cCat)
				cCategoria += ","
			EndIf
		EndIf
	Next nX

	If !Empty(cCategoria) .and. Subs(cCategoria,Len(cCategoria),1) == ","
		cCategoria := Subs(cCategoria,1,Len(cCategoria)-1)
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Inicializa Variaveis Static								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	( CarExtAut() , RstGetTabExtra() )

	//--Seleciona funcionários de acordo com filtros
	cWhere += "%"
	cWhere += "SRA.RA_FILIAL >= '" + FilialDe + "' AND "
	cWhere += "SRA.RA_FILIAL <= '" + FilialAte + "' AND "
	cWhere += "SRA.RA_CC >= '" + CCDe + "' AND "
	cWhere += "SRA.RA_CC <= '" + CCAte + "' AND "
	cWhere += "SRA.RA_TNOTRAB >= '" + TurDe + "' AND "
	cWhere += "SRA.RA_TNOTRAB <= '" + TurAte + "' AND "
	cWhere += "SRA.RA_MAT >= '" + MatDe + "' AND "
	cWhere += "SRA.RA_MAT <= '" + MatAte + "' AND "
	cWhere += "SRA.RA_NOME >= '" + NomDe + "' AND "
	cWhere += "SRA.RA_NOME <= '" + NomAte + "' AND "
	cWhere += "SRA.RA_DEPTO >= '" + DeptoDe + "' AND "
	cWhere += "SRA.RA_DEPTO <= '" + DeptoAte + "'"
	If !Empty( cSituacao )
		cWhere += " AND SRA.RA_SITFOLH IN ( " + cSituacao + ") "
	EndIf
	If !Empty(cCategoria)
		cWhere += " AND SRA.RA_CATFUNC IN ( " + cCategoria + ") "
	EndIf
	cWhere += " AND SRA.D_E_L_E_T_ = ' ' "
	cWhere += "%"

	//'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo + Nome'###'Departamento'###'Departamento + Nome'
	If ( ( nOrdem == 1 ) .or. ( lTerminal ) )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_MAT%"
	ElseIf ( nOrdem == 2 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_CC%"
	ElseIf ( nOrdem == 3 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_NOME, SRA.RA_MAT%"
	ElseIf ( nOrdem == 4 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_TNOTRAB%"
	ElseIf ( nOrdem == 5 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_CC, SRA.RA_NOME%"
	ElseIf ( nOrdem == 6 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_DEPTO, SRA.RA_MAT%"
	ElseIf ( nOrdem == 7 )
		cOrdem := "%SRA.RA_FILIAL, SRA.RA_DEPTO, SRA.RA_NOME%"
	EndIf

	BeginSql Alias cAliasSRA
		SELECT 
			SRA.RA_FILIAL, SRA.RA_MAT
		FROM
			%Table:SRA% SRA
		WHERE 
			%Exp:cWhere%
		ORDER BY 
			%Exp:cOrdem%
	EndSql

	// Inicializa R‚gua de Impress„o
	If !( lTerminal )
		BeginSql Alias cAliasQTD
			SELECT 
				Count(*) AS QTDREG
			FROM
				%Table:SRA% SRA
			WHERE 
				%Exp:cWhere%
		EndSql

		SetRegua( (cAliasQTD)->QTDREG )
		(cAliasQTD)->(DbCloseArea())
	EndIf

	If lCodeBar
		DbSelectArea("RS4")
		DbSetOrder(1)
	EndIf

	dbSelectArea('SRA')
	SRA->( dbSetOrder( 1 ) )

	// Processa o Cadastro de Funcionarios
	While (cAliasSRA)->( !Eof() )

		//Posiciona no funcionário atual
		SRA->(DbSeek((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT))

		// So Faz Validacoes Quando nao for Terminal
		If !( lTerminal )			
			// Incrementa a R‚gua de Impress„o
			IncRegua()

			// Cancela a Impress„o
			If ( lEnd )
				Exit
			EndIf

			// Consiste controle de acessos e filiais validas
			If SRA->( !( RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA ) )
				(cAliasSRA)->( dbSkip() )
				Loop
			EndIf

			/* Consiste a data de Demiss„o								   
			Se o Funcionario Foi Demitido Anteriormente ao Inicio do Perio
			do Solicitado Desconsidera-o */   
			If !Empty(SRA->RA_DEMISSA) .and. ( SRA->RA_DEMISSA < dIniCale )
				(cAliasSRA)->( dbSkip() )
				Loop
			EndIf
		EndIf

		// Verifica a Troca de Filial
		If !( SRA->RA_FILIAL == cLastFil )

			// Atualiza a Filial Corrente
			cLastFil := SRA->RA_FILIAL

			// Carrega periodo de Apontamento Aberto
			If !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cLastFil )
				Exit
			EndIf

			// Obtem datas do Periodo em Aberto
			GetPonMesDat( @dIniPonMes , @dFimPonMes , cLastFil )

			// Atualiza o Array de Informa‡”es sobre a Empresa.
			aInfo := {}
			fInfo( @aInfo , cLastFil )

			// Carrega as Tabelas de Horario Padrao
			If ( lSPJExclu .or. Empty( aTabPadrao ) )
				aTabPadrao := {}
				fTabTurno( @aTabPadrao , If( lSPJExclu , cLastFil , NIL ) )
			EndIf

			// Carrega TODOS os Eventos da Filial
			If ( Empty( aId ) .or. ( lSP9Exclu ) )
				aId := {}
				CarId( fFilFunc("SP9") , @aId , "*" )
			EndIf

		EndIf

		// Retorna Periodos de Apontamentos Selecionados
		If ( lTerminal )
			dPerIni	:= dIniCale
			dPerFim := dFimCale
		EndIf

		aPeriodos := Monta_per( dIniCale , dFimCale , cLastFil , SRA->RA_MAT , dPerIni , dPerFim )

		// Corre Todos os Periodos
		naPeriodos := Len( aPeriodos )
		For nX := 1 To naPeriodos

			/* Reinicializa as Datas Inicial e Final a cada Periodo Lido.	  
			Os Valores de dPerIni e dPerFim foram preservados nas   varia
			veis: dCaleIni e dCaleFim.*/
			dPerIni		:= aPeriodos[ nX , 1 ]
			dPerFim		:= aPeriodos[ nX , 2 ]

			// Obtem as Datas para Recuperacao das Marcacoes
			dMarcIni	:= aPeriodos[ nX , 3 ]
			dMarcFim	:= aPeriodos[ nX , 4 ]

			// Verifica se Impressao eh de Acumulado
			lImpAcum := ( dPerFim < dIniPonMes )

			// Retorna Turno/Sequencia das Marca‡”es Acumuladas
			If ( lImpAcum )
				If SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + Dtos( dPerIni) ) ) .and. !Empty(SPF->PF_SEQUEPA)
					cTurno	:= SPF->PF_TURNOPA
					cSeq	:= SPF->PF_SEQUEPA
				Else
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Tenta Achar a Sequencia Inicial utilizando RetSeq()³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					If !RetSeq(cSeq,@cTurno,dPerIni,dPerFim,dDataBase,aTabPadrao,@cSeq) .or. Empty( cSeq )
						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Tenta Achar a Sequencia Inicial utilizando fQualSeq()		  ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						cSeq := fQualSeq( NIL , aTabPadrao , dPerIni , @cTurno )
					EndIf
				EndIf

				If ( Empty(cTurno) )
					SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) ) )
					Do While	( !EOF() ) .AND.;
					( SRA->RA_FILIAL + SRA->RA_MAT == SPF->PF_FILIAL + SPF->PF_MAT )
						If ( SPF->PF_DATA >= dPerIni .AND. SPF->PF_DATA <= dPerFim )
							cTurno	:= SPF->PF_TURNOPA
							cSeq	:= SPF->PF_SEQUEPA
							Exit
						Else
							SPF->( dbSkip() )
						EndIf
					EndDo
				EndIf

			Else
				// Considera a Sequencia e Turno do Cadastro
				cTurno	:= SRA->RA_TNOTRAB
				cSeq	:= SRA->RA_SEQTURN
			EndIf

			// Obtem Codigo e Descricao da Funcao do Trabalhador na Epoca
			//Limpa array a cada funcionario processado
			aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
			fBuscaCC(dMarcFim, @aFuncFunc[1], @aFuncFunc[2], Nil, .F. , .T.  )
			aFuncFunc[2]:= Substr(aFuncFunc[2], 1, 25)
			fBuscaFunc(dMarcFim, @aFuncFunc[3], @aFuncFunc[4],20, @aFuncFunc[5], @aFuncFunc[6],25, .F. )
			If Empty(aFuncFunc[6])
				aFuncFunc[6] := DescCateg(SRA->RA_CATFUNC , 25)
			EndIf

			/* Carrega Arrays com as Marca‡”es do Periodo (aMarcacoes), com
			o Calendario de Marca‡”es do Periodo (aTabCalend) e com as
			Trocas de Turno do Funcionario (aTurnos)*/
			( aMarcacoes := {} , aTabCalend := {} , aTurnos := {} )

			If lImpMarc
				/* Importante: 												 
				 O periodo fornecido abaixo para recuperar as marcacoes cor
				 respondente ao periodo de apontamentoo Calendario de Marca
				 ‡”es do Periodo ( aTabCalend ) e com  as Trocas de Turno  do
				 Funcionario ( aTurnos ) integral afim de criar o  calendario
				 com as ordens correspondentes as gravadas nas marcacoes */
				If !GetMarcacoes(;	
					@aMarcacoes				,;	//Marcacoes dos Funcionarios
					@aTabCalend				,;	//Calendario de Marcacoes
					@aTabPadrao				,;	//Tabela Padrao
					@aTurnos				,;	//Turnos de Trabalho
					dPerIni 				,;	//Periodo Inicial
					dPerFim					,;	//Periodo Final
					SRA->RA_FILIAL			,;	//Filial
					SRA->RA_MAT				,;	//Matricula
					cTurno					,;	//Turno
					cSeq					,;	//Sequencia de Turno
					SRA->RA_CC				,;	//Centro de Custo
					If(lImpAcum,"SPG","SP8"),;	//Alias para Carga das Marcacoes
					NIL						,;	//Se carrega Recno em aMarcacoes
					.T.						,;	//Se considera Apenas Ordenadas
					.T.    					,;	//Se Verifica as Folgas Automaticas
					.F.    			 		 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
				)
					Loop
				EndIf
			EndIf

			aPrtTurn := {}
			Aeval(aTurnos, {|x| If( x[2] >= dPerIni .AND. x[2]<= dPerFim, Aadd(aPrtTurn, x),Nil )} )

			// Reinicializa os Arrays aToais e aAbonados
			( aTotais := {} , aAbonados := {} )

			//Reinicializa array
			aAfast := {}

			// Carrega os Abonos Conforme Periodo
			If 	lImpMarc
				fAbonosPer( @aAbonosPer , dPerIni , dPerFim , cLastFil , SRA->RA_MAT )
			EndIf

			// Carrega os Totais de Horas e Abonos.
			If 	lImpMarc
				CarAboTot( @aTotais , @aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )
			EndIf

			/*Carrega o Array a ser utilizado na Impress„o.				  
			aPeriodos[nX,3] --> Inicio do Periodo para considerar as  mar
			                    cacoes e tabela						  
			aPeriodos[nX,4] --> Fim do Periodo para considerar as   marca
			                    coes e tabela*/
			If ( !fMontaAimp( aTabCalend, aMarcacoes, @aImp,dMarcIni,dMarcFim, lTerminal, lImpAcum) .and. !( lSemMarc ) )
				Loop
			EndIf

			// Carrega a situacao e os Afastamentos.
			Pnr010Afas( dMarcIni, dMarcFim, @aAfast )

			// Imprime o Espelho para um Funcionario.
			For nCount := 1 To nCopias
				If !( lTerminal )
					oPrinter:StartPage()
					If lCodeBar
						cCodeBar := cEmpAnt + SRA->RA_FILIAL + SRA->RA_MAT + DtoS(dPerIni) + DtoS(dPerFim) + DtoS(dDataBase) + StrTran(Time(),":","")
					EndIf
					fImpFun( aImp , nColunas, ,oPrinter )
					If lCodeBar //Grava o código de barras gerado na tabela RS4
						RecLock("RS4",.T.)
							RS4->RS4_FILIAL := SRA->RA_FILIAL
							RS4->RS4_MAT	:= SRA->RA_MAT
							RS4->RS4_PER	:= DtoS(dPerIni) + DtoS(dPerFim)
							RS4->RS4_DATAI	:= dPerIni
							RS4->RS4_DATAF	:= dPerFim
							RS4->RS4_CODEBA	:= cCodeBar
							RS4->RS4_STATUS	:= "2" //Pendente
						MsUnLock()
					EndIf
					oPrinter:EndPage()
				Else
					If lPortal
						aRetPortal  := aClone(aImp)
					Else
						cHtml := fImpFun( aImp , nColunas , lTerminal )
					EndIf
				EndIf
			Next nCount

			// Reinicializa Variaveis
			aImp      := {}
			aTotais   := {}
			aAbonados := {}

		Next nX

		(cAliasSRA)->( dbSkip() )

	End While

	(cAliasSRA)->(DbCloseArea())

Return( cHtml )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FImpFun   ³ Autor ³ J.Ricardo             ³ Data ³ 09/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o espelho do ponto do funcionario                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpFun( aImp , nColunas , lTerminal, oPrinter )

	Local cHtml			:= ""
	Local cOcorr		:= ""
	Local cAbHora		:= ""
	Local lZebrado		:= .F.
	Local nX        	:= 0.00
	Local nY        	:= 0.00
	Local nColMarc  	:= 0.00
	Local nTamLin   	:= 0.00
	Local nMin			:= 0.00
	Local nLenImp		:= 0.00
	Local nLenImpnX		:= 0.00
	Local nTamAuxlin	:= 0.00
	Local nSaldoAnt		:= 0.00
	Local nSaldoAtu		:= 0.00
	Local nCredito		:= 0.00
	Local nDebito		:= 0.00
	Local nAbHora		:= 0
	Local nPosES		:= 0
	Local nValAux		:= 0
	Local nContEve		:= 0
	Local oBrushC	    := TBrush():New( ,  RGB(228, 228, 228)  )
	Local oBrushI	    := TBrush():New( ,  RGB(242, 242, 242)  )
	local lBrush		:= .F.
	Local nValAux2      :=""

	//-- Define o tamanho da linha com base no MV_ColMarc.
	aEval(aImp, { |x| nColMarc := If(Len(x)-3>nColMarc, Len(x)-3, nColMarc) } )
	nColMarc += If(nColMarc%2 == 0, 0, 1)

	//-- Calcula a Maior das Qtdes de Colunas existentes
	nColunas := Max(nColunas, nColMarc)

	//-- Define configura‡”es da impress„o
	nTamAuxLin	:= 19+(nColunas*6)+50
	nTamLin    	:= If(nTamAuxLin <= 80,80,If(nTamAuxLin<=132,132,220))

	If ( lTerminal )
		// Inicio da Estrutura do Codigo HTML
		cHtml += HtmlProcId() + CRLF
		cHtml += '<html>'  + CRLF
		cHtml += 	'<head>'  + CRLF
		cHtml += 		'<title>RH Online</title>'  + CRLF
		cHtml +=		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'  + CRLF
		cHtml +=		'<link rel="stylesheet" href="css/rhonline.css" type="text/css">'  + CRLF
		cHtml +=	'</head>'  + CRLF
		cHtml +=	'<body bgcolor="#FFFFFF" text="#000000">' + CRLF
		cHtml +=		'<table width="515" border="0" cellspacing="0" cellpadding="0">'  + CRLF
		cHtml +=			'<tr>'  + CRLF
		cHtml +=				'<td class="titulo">'  + CRLF
		cHtml +=					'<p>' + CRLF
		cHtml +=						'<img src="'+TcfRetDirImg()+'/icone_titulo.gif" width="7" height="9">' + CRLF
		cHtml +=							'<span class="titulo_opcao">' + CRLF
		cHtml +=								STR0040 + CRLF	//'Consultar Marca&ccedil;&otilde;es'
		cHtml +=							'</span>' + CRLF
		cHtml +=							'<br><br>' + CRLF
		cHtml +=					'</p>' + CRLF
		cHtml +=				'</td>' + CRLF
		cHtml +=			'</tr>' + CRLF
		cHtml +=			'<tr>' + CRLF
		cHtml +=				'<td>' + CRLF
		cHtml +=					'<table width="515" border="0" cellspacing="0" cellpadding="0">' + CRLF
		cHtml +=						'<tr>' + CRLF
		cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_1.gif" width="10">&nbsp;</td>' + CRLF
		cHtml +=							'<td class="titulo" width="498">' + CRLF
		cHtml +=								'<table width="498" border="0" cellspacing="2" cellpadding="1">' + CRLF
		cHtml += Imp_Cabec( nTamLin , nColunas , lTerminal )
	Else
		//-- Imprime Cabecalho Especifico.
		Imp_Cabec( nTamLin , nColunas ,  lTerminal, 1, oPrinter )
	EndIf

	//-- Imprime Marcações
	nLenImp := Len(aImp)
	For nX := 1 To nLenImp
		If !( lTerminal )
			nLin += 12

			If nLin > nLinTot - 40
				fImpSign(oPrinter)
				oPrinter:EndPage()
				oPrinter:StartPage()
				Imp_Cabec( nTamLin , nColunas ,  lTerminal, 1, oPrinter )
			EndIf

			oPrinter:Box( nLin, nCol	, nLin+13, nColTot, "-6" )			// Caixa da linha total

			If lBigLine .and. nX%2 == 0 //Pinta somente as linhas pares
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:Line( nLin, nPxData	, nLin+13, nPxData	, 0 , "-6") 	// Linha Pos Data

			oPrinter:SayAlign(nLin,nCol+2,DtoC(aImp[nX,1]),oFontM,500,100,,ALIGN_H_LEFT)
			oPrinter:SayAlign(nLin,nPxData+2,DiaSemana(aImp[nX,1],8),oFontM,nPxSemana-nPxData,100,,ALIGN_H_LEFT)

			nMin := Len(aImp[nX])

			If Len(aImp[nX]) >= 4 .or. !lImpMarc

				For nPosES := 1 to Len(aNaES)
					oPrinter:Line( nLin, aNaES[nPosES]-6, nLin+13, aNaES[nPosES]-6, 0 , "-6")
					nY := nPosES + 3
					If lImpMarc .and. nY <= nMin
						oPrinter:SayAlign(nLin,aNaES[nPosES]+2,aImp[nX,nY],oFontM,500,100,,ALIGN_H_LEFT)
					EndIf
				Next nPosES
			Else
				oPrinter:Line( nLin, aNaES[1]-6, nLin+13, aNaES[1]-6, 0 , "-6")
				oPrinter:SayAlign(nLin,aNaES[1],aImp[nX,2],oFontM,Len(aNaES)*40,100,,ALIGN_H_CENTER)
			EndIf

			oPrinter:Line( nLin, nPxAbonos-6, nLin+13	, nPxAbonos-6, 0 , "-6")
			oPrinter:Line( nLin, nPxHE-6	, nLin+13	, nPxHE-6, 0 , "-6")
			oPrinter:Line( nLin, nPxFalta-6	, nLin+13	, nPxFalta-6, 0 , "-6")
			oPrinter:Line( nLin, nPxAdnNot-6, nLin+13	, nPxAdnNot-6, 0 , "-6")
			oPrinter:Line( nLin, nPxObser	, nLin+13	, nPxObser, 0 , "-6")

			If lImpMarc //Imprime abonos,He,Faltas,adicionais apenas se for para imprimir marcações.
				If ValType(aImp[nX,3]) == "A"
					oPrinter:SayAlign(nLin,nPxAbonos+2,aImp[nX,3,2],oFontM,500,100,,ALIGN_H_LEFT)
					If Len(aImp[nX,3,1]) > 50
						oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3,1],oFontO,500,100,,ALIGN_H_LEFT)
					Else
						oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3,1],oFontM,500,100,,ALIGN_H_LEFT)
					EndIf
				Else
					If Len(aImp[nX,3]) > 50
						oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3],oFontO,500,100,,ALIGN_H_LEFT)
					Else
						oPrinter:SayAlign(nLin,nPxObser+2,aImp[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
					EndIf
				EndIf

				If Len(aResult) > 0
					nValAux := 0
					nValAux2 := ""
					Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "1", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
					If nValAux > 0
						oPrinter:SayAlign(nLin,nPxHE+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
						nValAux := 0
					EndIf
					//Apenas gero as horas de Absenteismo na ultima linha do Dia.
					If nX == Len(aImp) .Or. aScan(aImp,{|x| x[1] == aImp[nX,1]},nX + 1) == 0
						Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] =="2", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
						If nValAux > 0
							oPrinter:SayAlign(nLin,nPxFalta+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
							Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] =="2", nValAux2 := x[4],Nil )} )
							If Empty(nValAux2)
								oPrinter:SayAlign(nLin,nPxObser+2,"FALTA",oFontM,500,100,,ALIGN_H_LEFT)
								else
								oPrinter:SayAlign(nLin,nPxObser+2,"BANCO DE HORAS",oFontM,500,100,,ALIGN_H_LEFT)								
							EndIf
							nValAux := 0
							nValAux2 := ""
						EndIf
					EndIf
					Aeval(aResult, {|x| If( x[1] == DtoS(aImp[nX,1]) .and. x[2] == "3", nValAux := __TimeSum(nValAux,x[3]),Nil )} )
					If nValAux > 0
						oPrinter:SayAlign(nLin,nPxAdnNot+2,StrTran(StrZero(nValAux,5,2),'.',':'),oFontM,500,100,,ALIGN_H_LEFT)
						nValAux := 0
					EndIf
				EndIf
			EndIf
		Else
			// Detalhes do Codigo HTML
			IF ( lZebrado := ( nX%2 == 0.00 ) )
				cHtml += '<tr bgcolor="#FAFBFC">' + CRLF
				cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
				cHtml += 		Dtoc(aImp[nX,1]) + CRLF
				cHtml += 	'</td>' + CRLF
				cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
				cHtml +=		DiaSemana(aImp[nX,1]) + CRLF
				cHtml += 	'</td>' + CRLF
			Else
				cHtml += '<tr>' + CRLF
				cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
				cHtml += 		Dtoc(aImp[nX,1]) + CRLF
				cHtml += 	'</td>' + CRLF
				cHtml += 	'<td class="dados_2" nowrap><div align="left">' + CRLF
				cHtml +=		DiaSemana(aImp[nX,1]) + CRLF
				cHtml += 	'</td>' + CRLF
			EndIF
			If ( nLenImpnX := Len(aImp[nX]) ) < ( ( nColunas + nLenImpnX ) - 1 )
				For nY := Len(aImp[nX]) To ( ( nColunas + 3 ) - 1 )
					aAdd(aImp[nX] , Space(05) )
				Next nY
			EndIf
			nLenImpnX := Len(aImp[nX])
			For nY := 4 To nLenImpnX
				IF ( lZebrado )
					cHtml += 	'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
					cHtml += 		aImp[nX,nY] + CRLF
					cHtml += 	'</td>' + CRLF
				Else
					cHtml += 	'<td class="dados_2" nowrap><div align="center">' + CRLF
					cHtml += 		aImp[nX,nY] + CRLF
					cHtml += 	'</td>' + CRLF
				EndIF
			Next nY

			//-- Trata Abonos e Excecoes
			If ValType(aImp[nX,3]) == "A"
				nAbHora:=  At( ":" , aImp[nX,3,2] )
			Else
				nAbHora:=  At( ":" , aImp[nX,3] )
			EndIf

			If nAbHora > 0
				cOcorr :=	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,1],SubStr( aImp[nX,3] , 1 , nAbHora - 3 )) )
				cAbHora:= 	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,2],SubStr( aImp[nX,3] , nAbHora - 2 ) ) )
			Else
				cOcorr :=	Capital( If (ValType(aImp[nX,3]) == "A",aImp[nX,3,1],AllTrim( aImp[nX,3] ) ))
				cAbHora:= 	'&nbsp;'
			EndIf

			If ( lZebrado )
				cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="center">' + CRLF
				cHtml +=			Capital( AllTrim( aImp[nX,2] ) )
				cHtml += 		'</td>' + CRLF
				cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
				cHtml +=	 		cOcorr
				cHtml += 		'</td>' + CRLF
				cHtml += 		'<td class="dados_2" bgcolor="#FAFBFC" nowrap><div align="left">' + CRLF
				cHtml +=	 		cAbHora
				cHtml += 		'</td>' + CRLF
			Else
				cHtml += 		'<td class="dados_2" nowrap><div align="center">' + CRLF
				cHtml +=			Capital( AllTrim( aImp[nX,2] ) )
				cHtml += 		'</td>' + CRLF
				cHtml += 		'<td class="dados_2" nowrap><div align="left">' + CRLF
				cHtml +=	 		cOcorr
				cHtml += 		'</td>' + CRLF
				cHtml += 		'<td class="dados_2" nowrap><div align="left">' + CRLF
				cHtml +=			cAbHora
				cHtml += 		'</td>' + CRLF
			EndIf
		EndIf
	Next nX

	If !( lTerminal )

		nLin += 35

		If lImpBH
			If Pnr010ImpBh(@nSaldoAnt, @nSaldoAtu, @nCredito, @nDebito)

				If nLin > nLinTot - 40
					fImpSign(oPrinter)
					oPrinter:EndPage()
					oPrinter:StartPage()
					Imp_Cabec( nTamLin , nColunas ,  lTerminal, 0, oPrinter )
				EndIf

				oPrinter:Box( nLin, nCol , nLin+13, nColTot, "-6" )		// Caixa da linha total

				nTamCol	 := (nColTot - nCol) / 6
				nColCod1 := nCol + nTamCol * 2
				nColCod2 := nColCod1 + nTamCol
				nColCod3 := nColCod2 + nTamCol
				nColCod4 := nColCod3 + nTamCol

				If lBigLine
					oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
				EndIf

				oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
				oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
				oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
				oPrinter:Line( nLin, nColCod4	, nLin+13, nColCod4		, 0 , "-6")

				oPrinter:SayAlign(nLin,nCol+2,STR0081,oFontP,500,100,,ALIGN_H_LEFT)		//Banco de Horas
				oPrinter:SayAlign(nLin,nColCod1+2,STR0082,oFontP,500,100,,ALIGN_H_LEFT)	//Saldo Anterior
				oPrinter:SayAlign(nLin,nColCod2+2,STR0083,oFontP,500,100,,ALIGN_H_LEFT)	//Débito
				oPrinter:SayAlign(nLin,nColCod3+2,STR0084,oFontP,500,100,,ALIGN_H_LEFT)	//Crédito
				oPrinter:SayAlign(nLin,nColCod4+2,STR0085,oFontP,500,100,,ALIGN_H_LEFT)	//Saldo Atual

				nLin+=12

				oPrinter:Box(  nLin, nCol	, nLin+13, nColTot	, "-6" )

				oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
				oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
				oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
				oPrinter:Line( nLin, nColCod4	, nLin+13, nColCod4		, 0 , "-6")

				oPrinter:SayAlign(nLin,nColCod1+2, Transform(nSaldoAnt,'@E 99,999.99'),oFontM,500,100,,ALIGN_H_LEFT)		//Saldo Anterior
				oPrinter:SayAlign(nLin,nColCod2+2, Transform(nDebito,'@E 99,999.99'),oFontM,500,100,,ALIGN_H_LEFT)			//Débito
				oPrinter:SayAlign(nLin,nColCod3+2, Transform(nCredito,'@E 99,999.99'),oFontM,500,100,,ALIGN_H_LEFT)			//Crédito
				oPrinter:SayAlign(nLin,nColCod4+2, Transform(nSaldoAtu,'@E 99,999.99'),oFontM,500,100,,ALIGN_H_LEFT)		//Saldo Atual

				nLin += 25
			EndIf
		EndIf

		//-- Se existirem totais, e se for selecionada sua impress„o, ser„o impressos.
		If lImpMarc .and. Len(aTotais) > 0 .and. nImpHrs # 4
			If nLin > nLinTot - 40
				fImpSign(oPrinter)
				oPrinter:EndPage()
				oPrinter:StartPage()
				Imp_Cabec( nTamLin , nColunas ,  lTerminal, 0, oPrinter )
				nLin+=20
			EndIf

			oPrinter:Box( nLin, nCol , nLin+13, nColTot, "-6" )			// Caixa da linha total

			nTamCol	 := (nColTot - nCol) / 21
			nColCod1 := nCol + nTamCol
			nColDesc1:= nColCod1 + (nTamCol*4)
			nColCalc1:= nColDesc1 + nTamCol
			nColInf1 := nColCalc1 + nTamCol
			nColCod2 := nColInf1 + nTamCol
			nColDesc2:= nColCod2 + (nTamCol*4)
			nColCalc2:= nColDesc2 + nTamCol
			nColInf2 := nColCalc2 + nTamCol
			nColCod3 := nColInf2 + nTamCol
			nColDesc3:= nColCod3 + (nTamCol*4)
			nColCalc3:= nColDesc3 + nTamCol

			If lBigLine
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrushC, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc1	, nLin+13, nColDesc1	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc1	, nLin+13, nColCalc1	, 0 , "-6")
			oPrinter:Line( nLin, nColInf1	, nLin+13, nColInf1		, 0 , "-6")
			oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc2	, nLin+13, nColDesc2	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc2	, nLin+13, nColCalc2	, 0 , "-6")
			oPrinter:Line( nLin, nColInf2	, nLin+13, nColInf2		, 0 , "-6")
			oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc3	, nLin+13, nColDesc3	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc3	, nLin+13, nColCalc3	, 0 , "-6")

			oPrinter:SayAlign(nLin,nCol+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)				//Codigo
			oPrinter:SayAlign(nLin,nColCod1+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descrição

			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:SayAlign(nLin,nColDesc1+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
			EndIf

			oPrinter:SayAlign(nLin,nColCalc1+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)		//Informado

			oPrinter:SayAlign(nLin,nColInf1+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)			//Codigo
			oPrinter:SayAlign(nLin,nColCod2+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descrição

			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:SayAlign(nLin,nColDesc2+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
			EndIf
			oPrinter:SayAlign(nLin,nColCalc2+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)		//Informado

			oPrinter:SayAlign(nLin,nColInf2+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT)			//Codigo
			oPrinter:SayAlign(nLin,nColCod3+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT)			//Descrição

			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:SayAlign(nLin,nColDesc3+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)	//Calculado
			EndIf
			oPrinter:SayAlign(nLin,nColCalc3+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)

			nMetade := nLin
			nContEve:= 1
			For nX := 1 To Len(aTotais)
				If nContEve == 1
					nMetade+=12
					If nMetade > nLinTot - 40
						fImpSign(oPrinter)
						oPrinter:EndPage()
						oPrinter:StartPage()
						Imp_Cabec( nTamLin , nColunas ,  lTerminal, 2, oPrinter )
						nLin+=12
						nMetade := nLin
					EndIf
					oPrinter:Box(  nMetade, nCol	, nMetade+13, nColTot	, "-6" )
					If lBigLine .and. lBrush
						oPrinter:Fillrect( {nMetade+1, nCol+1, nMetade+12, nColTot-1 }, oBrushI, "-2") // Quadro na Cor Cinza
						lBrush := .F.
					Else
						lBrush := .T.
					EndIf
					oPrinter:Line( nMetade, nColCod1	, nMetade+13, nColCod1	, 0 , "-6")
					oPrinter:Line( nMetade, nColDesc1	, nMetade+13, nColDesc1	, 0 , "-6")
					oPrinter:Line( nMetade, nColCalc1	, nMetade+13, nColCalc1	, 0 , "-6")
					oPrinter:Line( nMetade, nColInf1	, nMetade+13, nColInf1	, 0 , "-6")
					oPrinter:Line( nMetade, nColCod2	, nMetade+13, nColCod2	, 0 , "-6")
					oPrinter:Line( nMetade, nColDesc2	, nMetade+13, nColDesc2	, 0 , "-6")
					oPrinter:Line( nMetade, nColCalc2	, nMetade+13, nColCalc2	, 0 , "-6")
					oPrinter:Line( nMetade, nColInf2	, nMetade+13, nColInf2	, 0 , "-6")
					oPrinter:Line( nMetade, nColCod3	, nMetade+13, nColCod3	, 0 , "-6")
					oPrinter:Line( nMetade, nColDesc3	, nMetade+13, nColDesc3	, 0 , "-6")
					oPrinter:Line( nMetade, nColCalc3	, nMetade+13, nColCalc3	, 0 , "-6")

					oPrinter:SayAlign(nMetade,nCol+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCod1+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColDesc1,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCalc1,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
					nContEve++
				ElseIf nContEve == 2
					oPrinter:SayAlign(nMetade,nColInf1+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCod2+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColDesc2,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCalc2,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
					nContEve++
				ElseIf nContEve == 3
					oPrinter:SayAlign(nMetade,nColInf2+2,aTotais[nX,1],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCod3+2,aTotais[nX,2],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColDesc3,aTotais[nX,3],oFontM,500,100,,ALIGN_H_LEFT)
					oPrinter:SayAlign(nMetade,nColCalc3,aTotais[nX,4],oFontM,500,100,,ALIGN_H_LEFT)
					nContEve++
				EndIf
				If nContEve > 3
					nContEve := 1
				EndIf
				nLin := nMetade
			Next nX
		EndIf

		fImpSign(oPrinter)
	Else
		// Final da Estrutura do Codigo HTML
		cHtml +=									'<tr>' + CRLF
		cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
		cHtml +=									'</tr>' + CRLF
		cHtml +=								'</table>' + CRLF
		cHtml +=							'</td>' + CRLF
		cHtml +=							'<td background="'+TcfRetDirImg()+'/tabela_conteudo_2.gif" width="7">&nbsp;</td>' + CRLF
		cHtml +=						'</tr>' + CRLF
		cHtml +=					'</table>' + CRLF
		cHtml +=				'</td>' + CRLF
		cHtml +=			'</tr>' + CRLF
		cHtml +=		'</table>' + CRLF
		cHtml +=		'<p align="right"><a href="javascript:self.print()"><img src="'+TcfRetDirImg()+'/imprimir.gif" width="90" height="28" hspace="20" border="0"></a></p>' + CRLF
		cHtml +=	'</body>' + CRLF
		cHtml += '</html>' + CRLF
	EndIf

Return( cHtml )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FMontaaIMP³ aUTOR ³ EQUIPE DE RH          ³ dATA ³ 09/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o Vetor aImp , utilizado na impressao do espelho     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FMontaAimp(aTabCalend, aMarcacoes, aImp,dInicio,dFim, lTerminal, lImpAcum)

	Local aDescAbono := {}
	Local aCodigos	 := {}
	Local cTipAfas   := ""
	Local cDescAfas  := ""
	Local cOcorr     := ""
	Local cOrdem     := ""
	Local cTipDia    := ""
	Local dData      := Ctod("//")
	Local dDtBase    := dFim
	Local lRet       := .T.
	Local lFeriado   := .T.
	Local lTrabaFer  := .F.
	Local lAfasta    := .T.
	Local nX         := 0
	Local nDia       := 0
	Local nMarc      := 0
	Local nLenMarc	 := Len( aMarcacoes )
	Local nLenDescAb := Len( aDescAbono )
	Local nTab       := 0
	Local nContMarc  := 0
	Local nDias		 := 0

	//-- Variaveis ja inicializadas.
	aImp := {}

	nDias := ( dDtBase - dInicio )
	For nDia := 0 To nDias

		//-- Reinicializa Variaveis.
		dData      := dInicio + nDia
		aDescAbono := {}
		cOcorr     := ""
		cTipAfas   := ""
		cDescAfas  := ""
		cOcorr	   := ""

		If !lImpMarc
			//-- Adiciona Nova Data a ser impressa.
			aAdd(aImp,{})
			aAdd(aImp[Len(aImp)], dData)
			aAdd(aImp[Len(aImp)], Space(1))
			nContMarc++
			Loop
		EndIf

		//-- o Array aTabcalend ‚ setado para a 1a Entrada do dia em quest„o.
		If ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) == 0.00
			Loop
		EndIf

		//-- o Array aMarcacoes ‚ setado para a 1a Marca‡„o do dia em quest„o.
		nMarc := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })

		//-- Consiste Afastamentos, Demissoes ou Transferencias.
		If ( ( lAfasta := aTabCalend[ nTab , 24 ] ) .or. SRA->( RA_SITFOLH $ 'DúT' .and. dData > RA_DEMISSA ) )
			lAfasta		:= .T.
			cTipAfas	:= IF(!Empty(aTabCalend[ nTab , 25 ]),aTabCalend[ nTab , 25 ],fDemissao(SRA->RA_SITFOLH, SRA->RA_RESCRAI) )
			cDescAfas	:= Alltrim(fDescAfast( cTipAfas, TamSx3("RCM_DESCRI")[1], Nil, SRA->( RA_SITFOLH == 'D' .and. dData > RA_DEMISSA ), aTabCalend[ nTab , 47 ], SRA->RA_FILIAL ))
		EndIf

		//Verifica Regra de Apontamento ( Trabalha Feriado ? )
		lTrabaFer := ( PosSPA( aTabCalend[ nTab , 23 ] , cFilSPA , "PA_FERIADO" , 01 ) == "S" )

		//-- Consiste Feriados.
		If ( lFeriado := aTabCalend[ nTab , 19 ] )  .AND. !lTrabaFer
			cOcorr := aTabCalend[ nTab , 22 ]
		EndIf

		//-- Carrega Array aDescAbono com os Abonos ocorridos no Dia
		nLenDescAb := Len(aAbonados)
		For nX := 1 To nLenDescAb
			If aAbonados[nX,1] == dData
				aAdd(aDescAbono, { aAbonados[nX,2] , aAbonados[nX,3] , aAbonados[nX,4] })
			EndIf
		Next nX

		//-- Ordem e Tipo do dia em quest„o.
		cOrdem  := aTabCalend[nTab,2]
		cTipDia := aTabCalend[nTab,6]

		//-- Se a Data da marcacao for Posterior a Admissao
		If dData >= SRA->RA_ADMISSA
			//-- Se Afastado
			If ( lAfasta  .AND. aTabCalend[nTab,10] <> 'E' ) .OR. ( lAfasta  .AND. aTabCalend[nTab,10] == 'E' .AND. ( !lImpExcecao .OR. !aTabCalend[nTab,32] ) )
				cOcorr := cDescAfas
				//-- Se nao for Afastado
			Else

				//-- Se tiver EXCECAO para o Dia  ------------------------------------------------
				If aTabCalend[nTab,10] == 'E'
					//-- Se excecao trabalhada
					If cTipDia == 'S'
						//-- Se nao fez Marcacao
						If Empty(nMarc)
							cOcorr := STR0020  // '** Ausente **'
							//-- Se fez marcacao
						Else
							//-- Motivo da Marcacao
							If !Empty(aTabCalend[nTab,11])
								cOcorr := AllTrim(aTabCalend[nTab,11])
							Else
								cOcorr := STR0018  // '** Excecao nao Trabalhada **'
							EndIf
						EndIf
						//-- Se excecao outros dias (DSR/Compensado/Nao Trabalhado)
					Else
						//-- Motivo da Marcacao
						If !Empty(aTabCalend[nTab,11])
							cOcorr := AllTrim(aTabCalend[nTab,11])
						Else
							cOcorr := STR0018  // '** Excecao nao Trabalhada **'
						EndIf
					EndIf

					//-- Se nao Tiver Excecao  no Dia ---------------------------------------------------
				Else
					//-- Se feriado
					If lFeriado
						//-- Se nao trabalha no Feriado
						If !lTrabaFer
							cOcorr := If(!Empty(cOcorr),cOcorr,STR0019 ) // '** Feriado **'
							//-- Se trabalha no Feriado
						Else
							//-- Se Dia Trabalhado e Nao fez Marcacao
							If cTipDia == 'S' .and. Empty(nMarc)
								cOcorr := STR0020  // '** Ausente **'
							ElseIf cTipDia == 'D'
								cOcorr := STR0021  // '** D.S.R. **'
							ElseIf cTipDia == 'C'
								cOcorr := STR0022  // '** Compensado **'
							ElseIf cTipDia == 'N'
								cOcorr := STR0023  // '** Nao Trabalhado **'
							EndIf
						EndIf
					Else
						//-- Se Dia Trabalhado e Nao fez Marcacao
						If cTipDia == 'S' .and. Empty(nMarc)
							cOcorr := STR0020  // '** Ausente **'
						ElseIf cTipDia == 'D'
							cOcorr := STR0021  // '** D.S.R. **'
						ElseIf cTipDia == 'C'
							cOcorr := STR0022  // '** Compensado **'
						ElseIf cTipDia == 'N'
							cOcorr := STR0023  // '** Nao Trabalhado **' 
												
						EndIf

					EndIf
				EndIf
			EndIf
		EndIf

		nLenDescAb := Len(aDescAbono)

		//-- Adiciona Nova Data a ser impressa.
		aAdd(aImp,{})
		aAdd(aImp[Len(aImp)], aTabCalend[nTab,1])

		//-- Ocorrencia na Data.
		If (lTerminal)
			aAdd( aImp[Len(aImp)], cOcorr)
		EndIf

		//-- Abono na Data.
		If ( nLenDescAb  > 0 )
			If !( lTerminal)
				If cOcorr == STR0020  // '** Ausente **'
					aAdd( aImp[Len(aImp)], cOcorr ) // '** Ausente **'
				Else
					If !empty(cOcorr)
						aAdd( aImp[Len(aImp)],	Space(01))
						aAdd( aImp[Len(aImp)], cOcorr )
						aAdd( aImp,{})
						aAdd( aImp[Len(aImp)], aTabCalend[nTab,1])
						aAdd( aImp[Len(aImp)],	Space(01) )
					Else
						aAdd( aImp[Len(aImp)],	Space(01))
					EndIf
				EndIf
			EndIf
			For nX := 1 To nLenDescAb
				If nX == 1
					aAdd( aImp[Len(aImp)], aDescAbono[nX])
				Else
					aAdd(aImp, {})
					aAdd(aImp[Len(aImp)], aTabCalend[nTab,1]		)
					aAdd(aImp[Len(aImp)], Space(01)			 	)
					aAdd(aImp[Len(aImp)], aDescAbono[nX]			)
				EndIf
			Next nX
		Else
			If ( lTerminal )
				aAdd( aImp[Len(aImp)], '' )
			Else
				If cOcorr == STR0020  // '** Ausente **'
					aAdd( aImp[Len(aImp)], cOcorr)
					aAdd( aImp[Len(aImp)], Space(01))
				Else
					aAdd( aImp[Len(aImp)], Space(01))
					aAdd( aImp[Len(aImp)], cOcorr )
				EndIf
			EndIf
		EndIf

		//-- Marca‡oes ocorridas na data.
		If nMarc > 0
			While nMarc <= nLenMarc .and. cOrdem == aMarcacoes[nMarc,3]
				nContMarc ++
				aAdd( aImp[Len(aImp)], StrTran(StrZero(aMarcacoes[nMarc,2],5,2),'.',':') + If(aMarcacoes[nMarc,28]<>"O","*","") ) //Se nao for original, inclui asterisco na frente da marcacao
				nMarc ++
			End While
		EndIf

	Next nDia

	If lImpMarc .and. !lTerminal //Carrega o array aResult para exibicao das HE, faltas e adc. noturno.
		aResult := {}
		fGetApo(@aResult, dInicio, dFim, lImpAcum)
	EndIf

	lRet := If(nContMarc>=1,.T.,.F.)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Imp_Cabec ³ Autor ³ EQUIPE DE RH          ³ Data ³ 09/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do espelho do ponto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Imp_Cabec(nTamLin ,nColunas, lTerminal, nTipoCab, oPrinter )

	Local cDet			:= ""
	Local cHtml			:= ""
	Local lImpTurnos	:=.F.
	Local nVezes		:= ( nColunas / 2 )
	Local nQtdeTurno	:= 0.00
	Local nX			:= 0.00
	Local nTamTno		:= ( Min(TamSx3("R6_DESC")[1], nTamLin) ) - 1
	Local nSizePage		:= 0
	Local nColCab12		:= 0
	Local nColCab13		:= 0
	Local nVarAux		:= 0
	Local nESAux		:= 0
	Local oBrush		:= TBrush():New( ,  RGB(228, 228, 228)  )

	DEFAULT lTerminal := .F.
	DEFAULT nTipoCab  := 3 // 1 - Cab para as Marcacoes / 2 - Totais / 3 - Sem Cab Auxiliar

	lImpTurnos := nTipoCab <> 2

	If !( lTerminal )

		nSizePage	:= oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
		nLin		:= aMargRel[2] + 10
		nCol		:= aMargRel[1] + 10
		nPxData	 	:= nCol+50
		nPxSemana	:= nPxData+50
		nVarAux		:= nPxSemana
		nColTot		:= nSizePage-(aMargRel[1]+aMargRel[3])
		nLinTot		:= (oPrinter:nPageHeight / oPrinter:nFactorVert) - (aMargRel[2]+aMargRel[4])
		nColCab12	:= nColTot / 3
		nColCab13	:= ( nColTot / 3 ) * 2
		aNaES		:= Array(nColunas)

		For nX := 1 to Len(aNaES)
			aNaES[nX] := nVarAux
			nVarAux += 40
		Next nX

		nPxAbonos 	:= nVarAux
		nPxHe	 	:= nPxAbonos + 40
		nPxFalta 	:= nPxHe + 40
		nPxAdnNot	:= nPxFalta + 40
		nPxObser  	:= nPxAdnNot + 40

		If lCodeBar
			If lBigLine
				oPrinter:Fillrect( {nLin, nCol, nLin+17, nColTot-210 }, oBrush, "-2") 	// Quadro na Cor Cinza
			EndIf
			oPrinter:SayAlign(nLin+2,nCol,STR0001,oFontT,nColTot-210,100,,ALIGN_H_CENTER)  	// 'Espelho do Ponto'

			oPrinter:Box( nLin+3, nColTot-200	, nLin+38, nColTot-5, "-6" )				// Caixa da linha total
			oPrinter:Code128c(nLin+30, nColTot-176, cCodeBar, 20)
			oPrinter:SayAlign(nLin+30,nColTot-200,cCodeBar,oFont06,(nColTot-(nColTot-200)),100,,ALIGN_H_CENTER)
		Else
			If lBigLine
				oPrinter:Fillrect( {nLin, nCol, nLin+17, nColTot }, oBrush, "-2") 	// Quadro na Cor Cinza
			EndIf
			oPrinter:SayAlign(nLin+2,nCol,STR0001,oFontT,nColTot,100,,ALIGN_H_CENTER)  	// 'Espelho do Ponto'
		EndIf

		nLin += 18

		cDet := STR0071  + PADR( If(Len(aInfo)>0,aInfo[03],SM0->M0_NomeCom) , 50)  // 'Empresa: '
		oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		If ( Len(aInfo) > 0 ) .And. ( aInfo[28] == 1 )
			cDet := STR0095  + PADR(Transform( If(!Empty(aInfo[27]), aInfo[27], SM0->M0_CEI),'@R ##.###.#####/##'),50)   // 'CEI: '
		ElseIf ( Len(aInfo) > 0 ) .And. ( aInfo[28] == 3 )
			cDet := STR0096  + PADR(Transform( If((aInfo[08]#""), aInfo[08], SM0->M0_CGC),'@R ###.###.###-##'),50)   // 'CPF: '
		Else
			cDet := STR0075  + PADR(Transform( If(Len(aInfo)>0,aInfo[08],SM0->M0_CGC),'@R ##.###.###/####-##'),50)   // 'CGC: '
		EndIf
		oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_CENTER)

		nLin += 13
		cDet := PADR( If(Len(aInfo)>0,aInfo[04],SM0->M0_EndCob) , 50)
		oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		nLin += 13

		oPrinter:Line(nLin,nCol,nLin,nColTot)

		nLin += 5
		cDet := STR0072  + AllTrim(SRA->RA_FILIAL) + ' - ' + SRA->RA_MAT  // ' Matr..: '
		oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		cDet := STR0074  + SRA->RA_Nome  // ' Nome..: '
		oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		cDet := STR0073  + SRA->RA_Chapa // '  Chapa : '
		oPrinter:SayAlign(nLin,nColCab13,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		nLin += 13
		cDet := STR0078  + aFuncFunc[6] // ' Categ.: '
		oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		cDet := STR0077  + PADR(AllTrim(aFuncFunc[1]) + ' - ' + aFuncFunc[2] , 50) // 'C.C...: '
		oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		cDet := STR0076  + AllTrim(aFuncFunc[3]) + ' - ' + aFuncFunc[4]  // 'Funcao: '
		oPrinter:SayAlign(nLin,nColCab13,cDet,oFontP,500,100,,ALIGN_H_LEFT)

		nLin += 13
		oPrinter:Line(nLin,nCol,nLin,nColTot)

		nLin += 5

		//-- Imprime Trocas de turnos
		nQtdeTurno := Len(aPrtTurn)

		If !lImpTroca .OR. nQtdeTurno<2   //-- Imprime Somente a descricao do turno atual
			If !lImpTroca .OR. nQtdeTurno == 0 //-- Periodo Atual ou Superior
				cDet := STR0079  + AllTrim(SRA->RA_TnoTrab) + ' ' + fDescTno(SRA->RA_FILIAL,SRA->RA_TnoTrab, nTamTno)
			Else	 //Periodo Anterior
				cDet := STR0079  + AllTrim(Alltrim(aPrtTurn[1,1])) + ' ' + fDescTno(SRA->RA_FILIAL,aPrtTurn[1,1], nTamTno)
			EndIf
			oPrinter:SayAlign(nLin,nColCab12,cDet,oFontP,500,100,,ALIGN_H_CENTER)
			cDet := STR0060 + ": " + AllTrim(SRA->RA_DEPTO) + " - " + fDesc("SQB",SRA->RA_DEPTO,"QB_DESCRIC")
			oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)
		Else
			If lImpTurnos // Se for o mesmo funcionario nao imprime trocas de turnos a partir da 2 pagina
				//-- Imprime Trocas de Turnos no Periodo
				For nX := 1 To nQtdeTurno
					cDet:= If(nX==1,STR0049,SPACE(Len(STR0049)))
					cDet:= cDet+DTOC(aPrtTurn[nX,2])+" "+STR0048+Alltrim(aPrtTurn[nX,1])+": "+fDescTno( SRA->RA_FILIAL, aPrtTurn[nX,1], nTamTno)
					oPrinter:SayAlign(nLin,nColCab12+12,cDet,oFontP,500,100,,ALIGN_H_LEFT)
					If nX == 1
						cDet := ' ' + STR0060 + ": " + AllTrim(SRA->RA_DEPTO)  + " - " + fDesc("SQB",SRA->RA_DEPTO,"QB_DESCRIC") // 'Departamento: '
						oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)
					EndIf
					If nX <> nQtdeTurno
						nLin += 13
					EndIf
				Next nX
			EndIf
		EndIf

		//-- Imprime a Situação: XXXXXXXXXXXXXXXX - Período: 99/99/9999 a 99/99/9999
		If Len( aAfast ) > 0
			For nX := 1 To Len( aAfast )
				nLin += 13
				cDet := aAfast[nX][1]
				oPrinter:SayAlign(nLin,nCol,cDet,oFontP,500,100,,ALIGN_H_LEFT)
			Next nX
		EndIf

		If nTipoCab==1 //Monta e Imprime Cabecalho das Marcacoes

			// Desenho do cabecalho //
			oPrinter:Box( nLin+=18, nCol	, nLin+20, nColTot, "-6" )				// Caixa da linha total

			If lBigLine
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+17, nColTot-1 }, oBrush, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:Line( nLin, nPxData	, nLin+20, nPxData	, 0 , "-6") 		// Linha Pos Data

			For nX := 1 to Len(aNaES)
				oPrinter:Line( nLin, aNaES[nX]-6	, nLin+20	, aNaES[nX]-6, 0 , "-6")			// Linha Pos Na. Entrada/Saída
			Next nX

			oPrinter:Line( nLin, nPxAbonos-6	, nLin+20	, nPxAbonos-6, 0 , "-6")
			oPrinter:Line( nLin, nPxHe-6		, nLin+20	, nPxHe-6, 0 , "-6")
			oPrinter:Line( nLin, nPxFalta-6		, nLin+20	, nPxFalta-6, 0 , "-6")
			oPrinter:Line( nLin, nPxAdnNot-6	, nLin+20	, nPxAdnNot-6, 0 , "-6")

			oPrinter:Line( nLin, nPxObser	, nLin+20	, nPxObser, 0 , "-6")

			oPrinter:SayAlign( nLin+=3 , nCol+5		, STR0042	, oFontP, nPxData, 150 , , ALIGN_H_LEFT ) //Data
			oPrinter:SayAlign( nLin, nPxData+6	, STR0043		, oFontP, nPxSemana, 150 , , ALIGN_H_LEFT ) //Semana

			nESAux := 1
			For nX := 1 to Len(aNaES)
				If nX%2 == 0
					oPrinter:SayAlign( nLin, aNaES[nX], AllTrim(Str(nESAux)) + STR0036, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Saida
					nESAux++
				Else
					oPrinter:SayAlign( nLin, aNaES[nX], AllTrim(Str(nESAux)) + STR0035, oFontP, aNaES[nX]+40, 150 , , ALIGN_H_LEFT ) //Entrada
				EndIf
			Next nX

			oPrinter:SayAlign( nLin, nPxAbonos	, STR0062		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Abonos
			oPrinter:SayAlign( nLin, nPxHe		, STR0068		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //H.E.
			oPrinter:SayAlign( nLin, nPxFalta	, STR0069		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Falt/Atra
			oPrinter:SayAlign( nLin, nPxAdnNot	, STR0070		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Ad. Not.
			oPrinter:SayAlign( nLin, nPxObser+6	, STR0063		, oFontP, 500, 150 , , ALIGN_H_LEFT ) //Observação
		ElseIf nTipoCab == 2
			nLin += 18
			oPrinter:Box( nLin, nCol , nLin+13, nColTot, "-6" )			// Caixa da linha total

			nTamCol	 := (nColTot - nCol) / 21
			nColCod1 := nCol + nTamCol
			nColDesc1:= nColCod1 + (nTamCol*4)
			nColCalc1:= nColDesc1 + nTamCol
			nColInf1 := nColCalc1 + nTamCol
			nColCod2 := nColInf1 + nTamCol
			nColDesc2:= nColCod2 + (nTamCol*4)
			nColCalc2:= nColDesc2 + nTamCol
			nColInf2 := nColCalc2 + nTamCol
			nColCod3 := nColInf2 + nTamCol
			nColDesc3:= nColCod3 + (nTamCol*4)
			nColCalc3:= nColDesc3 + nTamCol

			If lBigLine
				oPrinter:Fillrect( {nLin+1, nCol+1, nLin+13, nColTot-1 }, oBrush, "-2") // Quadro na Cor Cinza
			EndIf

			oPrinter:Line( nLin, nColCod1	, nLin+13, nColCod1		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc1	, nLin+13, nColDesc1	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc1	, nLin+13, nColCalc1	, 0 , "-6")
			oPrinter:Line( nLin, nColInf1	, nLin+13, nColInf1		, 0 , "-6")
			oPrinter:Line( nLin, nColCod2	, nLin+13, nColCod2		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc2	, nLin+13, nColDesc2	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc2	, nLin+13, nColCalc2	, 0 , "-6")
			oPrinter:Line( nLin, nColInf2	, nLin+13, nColInf2		, 0 , "-6")
			oPrinter:Line( nLin, nColCod3	, nLin+13, nColCod3		, 0 , "-6")
			If nImpHrs == 1 .or. nImpHrs == 3
				oPrinter:Line( nLin, nColDesc3	, nLin+13, nColDesc3	, 0 , "-6")
			EndIf
			oPrinter:Line( nLin, nColCalc3	, nLin+13, nColCalc3	, 0 , "-6")

			oPrinter:SayAlign(nLin,nCol+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
			oPrinter:SayAlign(nLin,nColCod1+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao

			If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
				oPrinter:SayAlign(nLin,nColDesc1+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
			EndIf

			oPrinter:SayAlign(nLin,nColCalc1+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT) //Informado

			oPrinter:SayAlign(nLin,nColInf1+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
			oPrinter:SayAlign(nLin,nColCod2+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao

			If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
				oPrinter:SayAlign(nLin,nColDesc2+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
			EndIf
			oPrinter:SayAlign(nLin,nColCalc2+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT) //Informado
			oPrinter:SayAlign(nLin,nColInf2+2,STR0064,oFontP,500,100,,ALIGN_H_LEFT) //Codigo
			oPrinter:SayAlign(nLin,nColCod3+2,STR0065,oFontP,500,100,,ALIGN_H_LEFT) //Descricao
			If nImpHrs == 1 .or. nImpHrs == 3 //Calculado
				oPrinter:SayAlign(nLin,nColDesc3+2,STR0066,oFontP,500,100,,ALIGN_H_LEFT)
			EndIf
			oPrinter:SayAlign(nLin,nColCalc3+2,STR0067,oFontP,500,100,,ALIGN_H_LEFT)//Informado
		EndIf
	Else
		// Monta o Cabecalho das Marcacoes
		cHtml +=									'<tr>' + CRLF
		cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
		cHtml +=									'</tr>' + CRLF
		cHtml +=									'<tr>' + CRLF
		cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
		cHtml +=												'<div align="left">' + CRLF
		cHtml +=													STR0042 + CRLF	//'Data'
		cHtml +=												'</div>' + CRLF
		cHtml +=											'</td>' + CRLF
		cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
		cHtml +=												'<div align="left">' + CRLF
		cHtml +=													STR0043 + CRLF	//'Dia'
		cHtml +=												'</div>' + CRLF
		cHtml +=											'</td>' + CRLF
		For nX := 1 To nVezes
			cHtml +=										'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
			cHtml +=											'<div align="center">' + CRLF
			cHtml +=												StrZero(nX,If(nX<10,1,2)) + STR0044 + CRLF	// '&#170;E.'
			cHtml +=											'</div>' + CRLF
			cHtml +=										'</td>' + CRLF
			cHtml +=										'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
			cHtml +=											'<div align="center">' + CRLF
			cHtml +=												StrZero(nX,If(nX<10,1,2)) + STR0045 + CRLF	//'&#170;S.'
			cHtml +=											'</div>' + CRLF
			cHtml +=										'</td>' + CRLF
		Next nX
		cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
		cHtml +=												'<div align="left">' + CRLF
		cHtml +=													STR0046 + CRLF //'Observa&ccedil;&otilde;s
		cHtml +=												'</div>' + CRLF
		cHtml +=											'</td>' + CRLF
		cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
		cHtml +=												'<div align="left">' + CRLF
		cHtml +=													STR0041 + CRLF	//'Motivo de Abono           Horas  Tipo da Marca&ccedil;&atilde;o'
		cHtml +=												'</div>' + CRLF
		cHtml +=											'</td>' + CRLF
		cHtml +=											'<td class="etiquetas_1" bgcolor="#FAFBFC" nowrap>' + CRLF
		cHtml +=												'<div align="left">' + CRLF
		cHtml +=													STR0047 + CRLF	//'Horas  Tipo da Marca&ccedil;&atilde;o'
		cHtml +=												'</div>' + CRLF
		cHtml +=											'</td>' + CRLF
		cHtml +=									'</tr>' + CRLF
		cHtml +=									'<tr>' + CRLF
		cHtml +=										'<td colspan="' + AllTrim( Str( nColunas + 5 ) ) + '" class="etiquetas_1" bgcolor="#FAFBFC"><hr size="1"></td>' + CRLF
		cHtml +=									'</tr>' + CRLF
	EndIF

Return( cHtml )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CarAboTot ³ Autor ³ EQUIPE DE RH          ³ Data ³ 08/08/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os totais do SPC e os abonos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarAboTot( aTotais , aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )

	Local aTotSpc		:= {} //-- 1-SPC->PC_PD/2-SPC->PC_QUANTC/3-SPC->PC_QUANTI/4-SPC->PC_QTABONO
	Local aCodAbono		:= {}
	Local cFilSP9   	:= xFilial( "SP9" , SRA->RA_FILIAL )
	Local cFilSRV		:= xFilial( "SRV" , SRA->RA_FILIAL )
	Local cImpHoras 	:= If(nImpHrs==1,"C",If(nImpHrs==2,"I","*")) //-- Calc/Info/Ambas
	Local cAutoriza 	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*")) //-- Aut./N.Aut./Ambas
	Local cAliasRes		:= IF( lImpAcum , "SPL" , "SPB" )
	Local cAliasApo		:= IF( lImpAcum , "SPH" , "SPC" )
	Local bAcessaSPC 	:= &("{ || " + ChkRH("PONR010","SPC","2") + "}")
	Local bAcessaSPH 	:= &("{ || " + ChkRH("PONR010","SPH","2") + "}")
	Local bAcessaSPB 	:= &("{ || " + ChkRH("PONR010","SPB","2") + "}")
	Local bAcessaSPL 	:= &("{ || " + ChkRH("PONR010","SPL","2") + "}")
	Local bAcessRes		:= IF( lImpAcum , bAcessaSPH , bAcessaSPC )
	Local bAcessApo		:= IF( lImpAcum , bAcessaSPL , bAcessaSPB )
	Local nColSpc   	:= 0.00
	Local nCtSpc    	:= 0.00
	Local nPass     	:= 0.00
	Local nHorasCal 	:= 0.00
	Local nHorasInf 	:= 0.00
	Local nX        	:= 0.00

	If ( lImpRes )
		//Totaliza Codigos a partir do Resultado
		fTotalSPB(;
		@aTotSpc		,;
		SRA->RA_FILIAL	,;
		SRA->RA_Mat		,;
		dMarcIni		,;
		dMarcFim		,;
		bAcessRes		,;
		cAliasRes		,;
		cAutoriza		 ;
		)
		//-- Converte as horas para sexagenal quando impressao for a partir do resultado
		If ( lSexagenal )	// Sexagenal
			For nCtSpc := 1 To Len(aTotSpc)
				For nColSpc := 2 To 4
					aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'H')
				Next nColSpc
			Next nCtSpc
		EndIf
	EndIf

	//Totaliza Codigos a partir do Movimento
	fTotaliza(;
	@aTotSpc,;
	SRA->RA_FILIAL,;
	SRA->RA_MAT,;
	bAcessApo,;
	cAliasApo,;
	cAutoriza,;
	@aCodAbono,;
	aAbonosPer,;
	lMvAbosEve,;
	lMvSubAbAp;
	)
	//-- Converte as horas para Centesimal quando impressao for a partir do apontamento
	If !( lImpRes ) .and. !( lSexagenal ) // Centesimal
		For nCtSpc :=1 To Len(aTotSpc)
			For nColSpc :=2 To 4
				aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'D')
			Next nColSpc
		Next nCtSpc
	EndIf

	//-- Monta Array com Totais de Horas
	If nImpHrs # 4  //-- Se solicitado para Listar Totais de Horas
		For nPass := 1 To Len(aTotSpc)
			If ( lImpRes ) //Impressao dos Resultados
				//-- Se encontrar o Codigo da Verba ou For um codigo de hora extra valido de acordo com o solicitado
				If PosSrv( aTotSpc[nPass,1] , cFilSRV , NIL , 01 )
					nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
					nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
					If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
						cHorCal := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 999.99'),Space(9)) + Space(1)
						cHorInf := If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 999.99'),Space(9))
						aAdd(aTotais, { aTotSpc[nPass,1], SRV->RV_DESC , cHorCal, cHorInf } )
					EndIf
				EndIf
			ElseIf PosSP9( aTotSpc[nPass,1] , cFilSP9 , NIL , 01 )
				//-- Impressao a Partir do Movimento
				nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
				nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
				If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
					cHorCal := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 999.99'),Space(9)) + Space(1)
					cHorInf := If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 999.99'),Space(9))
					aAdd(aTotais, { aTotSpc[nPass,1] , DescPDPon(aTotSpc[nPass,1], cFilSP9 ) , cHorCal, cHorInf } )
				EndIf
			EndIf
		Next nPass

		//-- Acrescenta as informacoes referentes aos eventos associados aos motivos de abono
		//-- Condicoes: Se nao For Impressao de Resultados
		//-- 			e Se For para Imprimir Horas Calculadas ou Ambas
		If !( lImpRes ) .and. (nImpHrs == 1 .or. nImpHrs == 3)
			For nX := 1 To Len(aCodAbono)
				// Converte as horas para Centesimal
				If !( lSexagenal ) // Centesimal
					aCodAbono[nX,2]:=fConvHr(aCodAbono[nX,2],'D')
				EndIf
				aAdd(aTotais, { aCodAbono[nX,1] , DescPDPon(aCodAbono[nX,1], cFilSP9) , '  0,00'  , Transform(aCodAbono[nX,2],'@E 999.99') } )
			Next nX
		EndIf
	EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fTotaliza ³ Autor ³ Mauricio MR           ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totalizar as Verbas do SPC (Apontamentos) /SPH (Acumulado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotaliza(aTotais,cFil,cMat,bAcessa,cAlias,cAutoriza,aCodAbono,aAbonosPer,lMvAbosEve,lMvSubAbAp)

	Local aJustifica	:= {}
	Local cCodigo		:= ""
	Local cPrefix		:= SubStr(cAlias,-2)
	Local cTno			:= ""
	Local cCodExtras	:= ""
	Local cEvento		:= ""
	Local cPD			:= ""
	Local cPDI			:= ""
	Local cCC			:= ""
	Local cTPMARCA		:= ""
	Local lExtra		:= .T.
	Local lAbHoras		:= .T.
	Local nQuaSpc		:= 0.00
	Local nX			:= 0.00
	Local nEfetAbono	:= 0.00
	Local nQUANTC		:= 0.00
	Local nQuanti		:= 0.00
	Local nQTABONO		:= 0.00
	Local cAliasSP6		:= "SP6"
	Local lRemonta		:= .F.
	Local lContinua		:= .F.

	If ( cAlias )->(dbSeek( cFil + cMat ) )
		While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

			dData	:= (cAlias)->(&(cPrefix+"_DATA"))  	//-- Data do Apontamento
			cPD		:= (cAlias)->(&(cPrefix+"_PD"))    	//-- Codigo do Evento
			cPDI	:= (cAlias)->(&(cPrefix+"_PDI"))     	//-- Codigo do Evento Informado
			nQUANTC	:= (cAlias)->(&(cPrefix+"_QUANTC"))  	//-- Quantidade Calculada pelo Apontamento
			nQuanti	:= (cAlias)->(&(cPrefix+"_QUANTI"))  	//-- Quantidade Informada
			nQTABONO:= (cAlias)->(&(cPrefix+"_QTABONO")) 	//-- Quantidade Abonada
			cTPMARCA:= (cAlias)->(&(cPrefix+"_TPMARCA")) 	//-- Tipo da Marcacao
			cCC		:= (cAlias)->(&(cPrefix+"_CC")) 		//-- Centro de Custos

			If (cAlias)->( !Eval(bAcessa) )
				(cAlias)->( dbSkip() )
				Loop
			EndIf

			If dData < dMarcIni .or. dDATA > dMarcFim
				(cAlias)->( dbSkip() )
				Loop
			EndIf

			// Obtem TODOS os ABONOS do Evento
			//-- Trata a Qtde de Abonos
			aJustifica 	:= {} //-- Reinicializa aJustifica
			nEfetAbono	:=	0.00
			If nQuanti == 0 .and. fAbonos( dData , cPD , NIL , @aJustifica , cTPMARCA , cCC , aAbonosPer ) > 0

				//-- Corre Todos os Abonos
				For nX := 1 To Len(aJustifica)

					// Cria Array Analitico de Abonos com horas Convertidas.
					//-- Obtem a Quantidade de Horas Abonadas
					nQuaSpc := aJustifica[nX,2] //_QtAbono

					//-- Converte as horas Abonadas para Centesimal
					If !( lSexagenal ) // Centesimal
						nQuaSpc:= fConvHr(nQuaSpc,'D')
					EndIf

					//-- Cria Novo Elemento no array ANALITICO de Abonos
					aAdd( aAbonados, {} )
					aAdd( aAbonados[Len(aAbonados)], dData )
					aAdd( aAbonados[Len(aAbonados)], DescAbono(aJustifica[nX,1],'C' , NIL , SRA->RA_FILIAL) )

					aAdd( aAbonados[Len(aAbonados)], StrTran(StrZero(nQuaSpc,5,2),'.',':') )
					aAdd( aAbonados[Len(aAbonados)], DescTpMarca(aBoxSPC,cTPMARCA))

					If !( lImpres )
						// Trata das Informacoes sobre o Evento Associado ao Motivo corrente
						//-- Obtem Evento Associado
						cEvento := PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_EVENTO" , 01 )
						If ( lAbHoras := ( PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_ABHORAS" , 01 ) $ " S" ) )
							//-- Se o motivo abona Horas
							If ( lAbHoras )
								If !Empty( cEvento )
									If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
										aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
									Else
										aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
									EndIf
								Else
									/*A T E N C A O: Neste Ponto deveriamos tratar o paramentro MV_ABOSEVE  
									                no entanto, como ja havia a deducao abaixo e caso al-  
									                guem migra-se da versao 609 com o cadastro de motivo   
									                de abonos abonando horas mas sem o codigo, deixariamos 
									                de tratar como antes e o cliente argumentaria alteracao
									                de conceito.*/									
									//-- Se o motivo  nao possui abono associado
									//-- Calcula o total de horas a abonar efetivamente
									nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
								EndIf
							EndIf
						Else
							/*Se Motivo de Abono Nao Abona Horas e o Codigo do Evento Relaci
							onado ao Abono nao Estiver Vazio, Eh como se fosse uma  altera
							racao do Codigo de Evento. Ou seja, Vai para os Totais      as
							oras do Abono que serao subtraidas das Horas Calculadas (  Po
							deriamos Chamar esta operacao de "Informados via Abono" ).	   
							Para que esse processo seja feito o Parametro MV_SUBABAP  deve
							ra ter o Conteudo igual a "S"*/
							
							If ( ( lMvSubAbAp ) .and. !Empty( cEvento ) )
								//-- Se o motivo  nao possui abono associado
								//-- Calcula o total de horas a abonar efetivamente
								If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
									aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
								Else
									aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
								EndIf
								//-- O total de horas acumulado em nEfetAbono sera deduzido do
								//-- total de horas apontadas.
								nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf

			If !( lImpres )
				//-- Obtem o Codigo do Evento  (Informado ou Calculado)
				cCodigo:= If(!Empty(cPDI), cPDI, cPD )

				//-- Obtem a posicao no Calendario para a Data

				If ( nPos 	:= aScan(aTabCalend, {|x| x[1] ==dDATA .and. x[4] == '1E' }) ) > 0
					//-- Obtem o Turno vigente na Data
					cTno	:=	aTabCalend[nPos,14]
					//-- Carrega ou recupera os codigos correspondentes a horas extras na Data
					cCodExtras	:= ''
					lRemonta	:= .F.
					If ( cAutoriza $ "A|N" .AND. !Empty(ALLTRIM(cPdi) ) )
						lRemonta	:= .T.
					EndIf
					CarExtAut( @cCodExtras , cTno , cAutoriza , lRemonta )
					lExtra:=.F.
					If cCodigo$cCodExtras
						lExtra:=.T.
					EndIf
				EndIf

				//-- Se o Evento for Alguma HE Solicitada (Autorizada ou Nao Autorizada)
				//-- Ou  Valido Qquer Evento (Autorizado e Nao Autorizado)
				//-- OU  Evento possui um identificador correspondente a Evento Autorizado ou Nao Autorizado.
				//-- Ou  Evento e' referente a banco de horas
				lContinua	:= .F.
				If ( cAutoriza == "A" )
					If ( lExtra )
						lContinua	:= .T.
					EndIf
				Else
					If ( lExtra .or. cAutoriza == '*' .or. (aScan(aId,{|aEvento| ( aEvento[1] == cCodigo .and. Right(aEvento[2],1) == cAutoriza ) .Or. ( aEvento[1] == cCodigo .And. cAutoriza == 'A' .And. Empty(aEvento[2]) .And. aEvento[4] == "S" ) }  ) > 0.00))
						lContinua	:= .T.
					EndIf
				EndIf

				If ( lContinua )

					//-- Procura em aTotais pelo acumulado do Evento Lido
					If ( nPos := aScan(aTotais,{|x| x[1] = cCodigo  }) ) > 0
						//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
						aTotais[nPos,2] := __TimeSum(aTotais[nPos,2],If(nQuanti>0, 0, __TimeSub(nQUANTC,nEfetAbono)))
						aTotais[nPos,3] := __TimeSum(aTotais[nPos,3],nQuanti)
						aTotais[nPos,4] := __TimeSum(aTotais[nPos,4],nQTABONO)

					Else
						//-- Adiciona Evento em Acumulados
						//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
						aAdd(aTotais,{cCodigo,If(nQuanti > 0, 0, __TimeSub(nQUANTC,nEfetAbono)), nQuanti,nQTABONO,lExtra })
					EndIf
				EndIf
			EndIf
			(cAlias)->( dbSkip() )
		End While
	EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fTotalSPB ³ Autor ³ EQUIPE DE RH		    ³ Data ³ 05/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totaliza eventos a partir do SPB.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotalSPB(aTotais,cFil,cMat,dDataIni,dDataFim,bAcessa,cAlias)

	Local cPrefix := ""

	cPrefix		:= SubStr(cAlias,-2)

	If ( cAlias )->( dbSeek( cFil + cMat ) )
		While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

			If (cAlias)->( &(cPrefix+"_DATA") < dDataIni .or. &(cPrefix+"_DATA") > dDataFim )
				(cAlias)->( dbSkip() )
				Loop
			EndIf

			If (cAlias)->( !Eval(bAcessa) )
				(cAlias)->( dbSkip() )
				Loop
			EndIf

			If ( nPos := aScan(aTotais,{|x| x[1] == (cAlias)->( &(cPrefix+"_PD") ) }) ) > 0
				aTotais[nPos,2] := aTotais[nPos,2] + (cAlias)->( &(cPrefix+"_HORAS") )
			Else
				aAdd(aTotais,{(cAlias)->( &(cPrefix+"_PD") ),(cAlias)->( &(cPrefix+"_HORAS") ),0,0 })
			EndIf
			(cAlias)->( dbSkip() )
		End While
	EndIf

Return( NIL )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LoadX3Box ³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array da ComboBox                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Nome do Campo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function LoadX3Box(cCampo)

	Local aRet:={},nCont,nIgual
	Local cCbox,cString
	
	cCbox := GetSx3Cache(cCampo,"X3_CBOX")
	//-- Opcao 1   |Opcao 2 |Opcao 3|Opcao 4
	//-- 01=Amarelo;02=Preto;03=Azul;04=Vermelho
	//   | À->nIgual        À->nCont
	//   À->cString: 01=Amarelo
	//aRet:={{01,Amarelo},{02.Preto},...}

	While !Empty(cCbox)
		nCont:=AT(";",cCbox)
		nIgual:=AT("=",cCbox)
		cString:=AllTrim(SubStr(cCbox,1,nCont-1)) //Opcao
		IF nCont == 0
			aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
			Exit
		Else
			aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
		Endif
		cCbox:=SubStr(cCbox,nCont+1)
	Enddo

Return( aRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DescTPMarc³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Descricao do Tipo da Marcacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aBox     - Array Contendo as Opcoes do Combox Ja Carregadas³±±
±±³          ³ cTpMarca - Tipo da Marcacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function DescTpMarca(aBox,cTpMarca)

	Local aTpMarca:={},cRet:='',nTpMarca:=0
	//-- SE Existirem Opcoes Realiza a Busca da Marcacao
	If Len(aBox)>0
		nTpmarca:=aScan(aBox,{|xtp| xTp[1] == cTpMarca})
		cRet:=If(nTpMarca>0,aBox[nTpmarca,2],"")
	EndIf

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Monta_Per³ Autor ³Equipe Advanced RH     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Monta_Per( dDataIni , dDataFim , cFil , cMat , dIniAtu , dFimAtu )

	Local aPeriodos := {}
	Local cFilSPO	:= xFilial( "SPO" , cFil )
	Local dAdmissa	:= SRA->RA_ADMISSA
	Local dPerIni   := Ctod("//")
	Local dPerFim   := Ctod("//")

	SPO->( dbSetOrder( 1 ) )
	SPO->( dbSeek( cFilSPO , .F. ) )
	While SPO->( !Eof() .and. PO_FILIAL == cFilSPO )

		dPerIni := SPO->PO_DATAINI
		dPerFim := SPO->PO_DATAFIM

		//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
		If dPerFim < dDataIni .OR. dPerIni > dDataFim
			SPO->( dbSkip() )
			Loop
		EndIf

		//-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
		If ( dPerFim >= dAdmissa )
			aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
		Else
			Exit
		EndIf

		SPO->( dbSkip() )

	End While

	If ( aScan( aPeriodos , { |x| x[1] == dIniAtu .and. x[2] == dFimAtu } ) == 0.00 )
		dPerIni := dIniAtu
		dPerFim	:= dFimAtu
		If !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
			If ( dPerFim >= dAdmissa )
				aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
			EndIf
		EndIf
	EndIf

Return( aPeriodos )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CarExtAut³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Relacao de Horas Extras por Filial/Turno           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodExtras --> String que Contem ou Contera os Codigos     ³±±
±±³          ³ cTnoCad    --> Turno conforme o Dia                        ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarExtAut( cCodExtras , cTnoCad , cAutoriza , lRemonta )

	Local aTabExtra		:= {}
	Local cFilSP4		:= fFilFunc("SP4")
	Local cTno			:= ""
	Local lFound		:= .F.
	Local lRet			:= .T.
	Local nX			:= 0
	Local naTabExtra	:= 0
	Local ncTurno	    := 0.00

	Static aExtrasTno

	If ( PCount() == 0.00 )
		aExtrasTno	:= NIL
	Else

		DEFAULT aExtrasTno	:= {}

		//-- Procura Tabela (Filial + Turno corrente)
		If ( lFound	:= ( SP4->( dbSeek( cFilSP4 + cTnoCad , .F. ) ) ) )
			cTno		:=	cTnoCad
			lFound	:=	.T.
		Else
			//-- Procura Tabela (Filial)
			cTno	:= Space(Len(SP4->P4_TURNO))
			lFound	:= SP4->( dbSeek(  cFilSP4 + cTno , .F.) )
		EndIf

		//-- Se Existe Tabela de HE
		If ( lFound )
			//-- Verifica se a Tabela de HE para o Turno ainda nao foi carregada
			If (lRemonta) .OR. (ncTurno:=aScan(aExtrasTno,{|aTurno| aTurno[1]  == cFilSP4 .and. aTurno[2] == cTno} )) == 0.00
				//-- Se nao Encontrou Carrega Tabela para Filial e Turno especificos
				GetTabExtra( @aTabExtra , cFilSP4 , cTno , .F. , .F. )
				//-- Posiciona no inicio da Tabela de HE da Filial Solicitada
				If !Empty(aTabExtra)
					naTabExtra:=	Len(aTabExtra)
					//-- Corre C¢digos de Hora Extra da Filial
					For nX:=1 To naTabExtra
						//-- Se Ambos os Tipos de Eventos ou Autorizados
						If cAutoriza == '*' .or. (cAutoriza == 'A' .and. !Empty(aTabExtra[nX,4]))
							cCodExtras += aTabExtra[nX,4]+'A' //-- Cod Autorizado
						EndIf
						//-- Se Ambos os Tipos de Eventos ou Nao Autorizados
						If cAutoriza == '*' .or. (cAutoriza == 'N' .and. !Empty(aTabExtra[nX,5]))
							cCodExtras += aTabExtra[nX,5]+'N' //-- Cod Nao Autorizado
						EndIf
					Next nX
				EndIf
				//-- Cria Nova Relacao de Codigos Extras para o Turno Lido
				aAdd(aExtrasTno,{cFilSP4,cTno,cCodExtras})
			Else
				//-- Recupera Tabela Anteriormente Lida
				cCodExtras:=aExtrasTno[ncTurno,3]
			EndIf

		EndIf

	EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CarId    ³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Relacao de Eventos da Filial						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil       --> Codigo da Filial desejada					  ³±±
±±³          ³ aId    	  --> Array com a Relacao	                      ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarId( cFil , aId , cAutoriza )

	Local nPos	:= 0.00

	//-- Preenche o Array aCodAut com os Eventos (Menos DSR Mes Ant.)
	SP9->( dbSeek( cFil , .T. ) )
	While SP9->( !Eof() .and. cFil == P9_FILIAL )
		If ( ( Right(SP9->P9_IDPON,1) == cAutoriza ) .or. ( cAutoriza == "*" ) )
			aAdd( aId , Array( 04 ) )
			nPos := Len( aId )
			aId[ nPos , 01 ] := SP9->P9_CODIGO	//-- Codigo do Evento
			aId[ nPos , 02 ] := SP9->P9_IDPON 	//-- Identificador do Ponto
			aId[ nPos , 03 ] := SP9->P9_CODFOL	//-- Codigo do da Verba Folha
			aId[ nPos , 04 ] := SP9->P9_BHORAS	//-- Evento para B.Horas
		EndIf
		SP9->( dbSkip() )
	EndDo

Return( NIL )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGetApo   ³ Autor ³ Leandro Dr.           ³ Data ³ 23.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Apontamentos do funcionario.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGetApo(aResult,dInicio,dFim,lImpAcum)
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cWhere	:= ""
	Local cAliasAux := If(lImpAcum,"SPH","SPC")
	Local cPrefixo	:= If(lImpAcum,"PH_","PC_")
	Local cJoinFil	:= ""
	Local aCodAut	:= {}
	Local cAutoriza 	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*"))

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Carrega tabela de Eventos do Tipo de Hora Extra									   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fTabSP4(@aCodAut)

	cWhere += "%"
	cWhere += cPrefixo + "FILIAL = '" + SRA->RA_FILIAL + "' AND "
	cWhere += cPrefixo + "MAT = '" + SRA->RA_MAT + "' AND "
	cWhere += cPrefixo + "DATA >= '" + DtoS(dInicio) + "' AND "
	cWhere += cPrefixo + "DATA <= '" + DtoS(dFim) + "' "
	cWhere += "%"

	If lImpAcum
		cJoinFil:= "%" + FWJoinFilial("SPH", "SP9") + "%"

		BeginSql Alias cAliasQry

			SELECT
				SPH.PH_DATA, SPH.PH_PD, SPH.PH_QUANTC, SPH.PH_QUANTI, SP9.P9_CLASEV, SP9.P9_IDPON, SPH.PH_PDI
			FROM
				%Table:SPH% SPH
			INNER JOIN %Table:SP9% SP9 ON 
				%exp:cJoinFil% 
				AND SP9.%NotDel% 
				AND SPH.PH_PD = SP9.P9_CODIGO
			WHERE
				%Exp:cWhere% 
				AND SPH.%NotDel%
			ORDER BY 
				SPH.PH_DATA, SPH.PH_PD

		EndSql
	Else
		cJoinFil:= "%" + FWJoinFilial("SPC", "SP9") + "%"

		BeginSql Alias cAliasQry

			SELECT
				SPC.PC_DATA, SPC.PC_PD, SPC.PC_QUANTC, SPC.PC_QUANTI, SP9.P9_CLASEV, SP9.P9_IDPON, SPC.PC_PDI
			FROM
				%Table:SPC% SPC
			INNER JOIN %Table:SP9% SP9 ON 
				%exp:cJoinFil% 
				AND SP9.%NotDel% 
				AND SPC.PC_PD = SP9.P9_CODIGO
			WHERE
				%Exp:cWhere%  
				AND SPC.%NotDel%
			ORDER BY 
				SPC.PC_DATA, SPC.PC_PD
		EndSql
	EndIf

	While !(cAliasQry)->(Eof())

		//Hora Extra
		If (cAliasQry)->P9_CLASEV == "01"
			// Filtra hora extra de acordo com tipo selecionado no parâmetro MV_PAR14 (Autorizada/ Não autorizada)
			If cAutoriza == '*'
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC"))}))
			Elseif Ascan(aCodAut, { |x| x[3] == (cAliasQry)->(&(cPrefixo+"PD")) .AND. x[4] == cAutoriza } ) > 0
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"1",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC"))}))
			Endif

			//Faltas/Atrasos/Saida antecipada
		ElseIf (cAliasQry)->P9_CLASEV $ "02*03*04*05"
			(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"2",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC")),&(cPrefixo+"PDI")}))

			//Adicional Noturno
		ElseIf (cAliasQry)->P9_IDPON $ "003N*004A*027N*028A"
			// Filtra adicional noturno de acordo com tipo selecionado no parâmetro MV_PAR14 (Autorizada/ Não autorizada)
			If cAutoriza == '*'
				(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC"))}))
			Elseif cAutoriza == 'A'
				If (cAliasQry)->P9_IDPON $ "004A*028A"
					(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC"))}))
				Endif
			Else
				If (cAliasQry)->P9_IDPON $ "003N*027N"
					(cAliasQry)->(aAdd(aResult,{&(cPrefixo+"DATA"),"3",If(&(cPrefixo+"QUANTI")>0,&(cPrefixo+"QUANTI"),&(cPrefixo+"QUANTC"))}))
				Endif
			Endif
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpSign  ³ Autor ³ Leandro Dr.           ³ Data ³ 23.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime espaço para assinatura do funcionario.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fImpSign(oPrinter)

	//Mensagem antes da assinatura
	If !Empty(cMenPad1) .or. !Empty(cMenPad2)
		oPrinter:SayAlign(nLinTot-15,nCol+2,cMenPad1 + cMenPad2,oFontM,500,100,,ALIGN_H_LEFT)
	EndIf

	oPrinter:SayAlign(nLinTot-20,nCol,Replicate("_",50),oFontP,nColTot,100,,ALIGN_H_CENTER)

	oPrinter:SayAlign(nLinTot-10,nCol,STR0013,oFontP,nColTot,100,,ALIGN_H_CENTER) // 'Assinatura do Funcionario'
Return Nil

//******************************
/*/{Protheus.doc} RGEP0010
Valida o Numero maximo de Entrada e Saida (MV_COLMARC).

@author Lucas
@since 12/04/2018
@version 1.0

@return Boolean, Verdadeiro ou falso

@type function
/*/
//******************************
Static Function RGPE0020()
	Local lRet := .F.

	IF SuperGetmv("MV_COLMARC") <= 5 .And. SuperGetmv("MV_COLMARC") >= 1
		lRet := .T.
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Imp_Cabec ³ Autor ³ EQUIPE DE RH          ³ Data ³ 09/04/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do espelho do ponto                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Pnr010ImpBh(nSaldoAnt, nSaldoAtu, nCredito, nDebito)
	Local aArea 	:= GetArea()
	Local nValor 	:= 0
	Local lRet		:= .F.

	nSaldoAnt	:= 0
	nDebito		:= 0
	nCredito	:= 0
	nSaldoAtu	:= 0

	dbSelectArea( "SPI" )
	dbSetOrder(2)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While SPI->( !Eof() .and. PI_FILIAL+PI_MAT == SRA->( RA_FILIAL+RA_MAT ) )

		PosSP9(SPI->PI_PD,SRA->RA_FILIAL,"P9_TIPOCOD")
		// Totaliza Saldo Anterior
		If SPI->PI_DATA < dPerIni
			If !(SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX < dPerIni)
				If (SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX <= dPerFim)
					If SP9->P9_TIPOCOD $  "1*3"
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)
							nSaldoAtu := __TimeSub(nSaldoAtu,nValor)
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D")
							nSaldoAtu := nSaldoAtu - fConvhR(nValor,"D")
						EndIf
					Else
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
							nSaldoAtu := __TimeSum(nSaldoAtu,nValor)
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D")
							nSaldoAtu := nSaldoAtu + fConvhR(nValor,"D")
						EndIf
					EndIf
				Else
					If SP9->P9_TIPOCOD $  "1*3"
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D")
						EndIf
					Else
						nValor := SPI->PI_QUANT
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D")
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf SPI->PI_DATA <= dPerFim
			If !(SPI->PI_STATUS == 'B' .AND. SPI->PI_DTBAIX <= dPerFim)
				If SP9->P9_TIPOCOD $  "1*3"
					nValor := SPI->PI_QUANT
					If lSexagenal
						nCredito := __TimeSum(nCredito,nValor)
					Else
						nCredito := nCredito + fConvhR(nValor,"D")
					EndIf
				Else
					nValor := SPI->PI_QUANT
					If lSexagenal
						nDebito := __TimeSum(nDebito,nValor)
					Else
						nDebito := nDebito + fConvhR(nValor,"D")
					EndIf
				EndIf
			EndIf
		Else
			Exit
		Endif

		dbSelectArea( "SPI" )
		dbSkip()

	Enddo

	If nSaldoAnt <> 0 .or. nCredito > 0 .or. nDebito > 0
		lRet := .T.
		If lSexagenal
			nSaldoAtu := __TimeSum(nSaldoAtu, __TimeSub( __TimeSum( nSaldoAnt , nCredito ) , nDebito ))
		Else
			nSaldoAtu := ( nSaldoAtu + nSaldoAnt + nCredito ) - nDebito
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pnr010Afas³ Autor ³ M. Silveira           ³ Data ³ 09/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca a situacao e afastamentos do funcionario.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Pnr010Afas( dDtIniP, dDtFimP, aAfast )

	Local nX		:= 0
	Local nReg		:= 0
	Local cSitu		:= ""
	Local aAux  	:= {}
	Local aArea 	:= GetArea()
	Local aSitFunc  := RetSituacao( SRA->RA_FILIAL, SRA->RA_MAT, .F., dDtIniP  )

	If Len(aSitFunc) > 0

		Do Case
			Case aSitFunc[1] == "A"
				cSitu := STR0090 //"AFASTADO"
			Case aSitFunc[1] == "F"
				cSitu := STR0091 //"FERIAS"
			Case aSitFunc[1] == "T"
				cSitu := STR0092 //"TRANSFERIDO"
			Case aSitFunc[1] == "D"
				cSitu := STR0093 //"DEMITIDO"
			OtherWise
				cSitu := STR0094 //"NORMAL"
		EndCase

		If aSitFunc[1] $ "A/F"

			aAfast	:= {}
			fRetAfas( dDtIniP, dDtFimP,,,,@aAux, )
			nReg := Len(aAux)

			If nReg > 0
				For nX := 1 To nReg

					//Considera somente os afastamentos compreendidos no periodo de apontamento
					If ( aAux[nX][3] >= dDtIniP .And. aAux[nX][3] <= dDtFimP ) .Or.;
					( aAux[nX][4] >= dDtIniP .And. aAux[nX][4] <= dDtFimP ) .Or.;
					( aAux[nX][4] >= dDtIniP .And. aAux[nX][3] >= dDtFimP ) .Or.;
					( Empty(aAux[nX][4])     .And. aAux[nX][3] <= dDtFimP )

						//Se tiver mais de um registro a situacao sai apenas na primeira linha e nas demais apenas o periodo
						If Empty( aAfast )
							aAdd( aAfast, { STR0088 + cSitu + " - " + STR0089 + dToC(aAux[nX][3]) + " a " + dToC(aAux[nX][4]) } ) //"Sit...: "#"Período: "
						Else
							aAdd( aAfast, { Space( Len(STR0088)+Len(cSitu)+3 ) + STR0089 + dToC(aAux[nX][3]) + " a " + dToC(aAux[nX][4]) } ) //"Período: "
						EndIf
					EndIf

				Next nX

				If Empty( aAfast )
					cSitu := STR0094 //"NORMAL"
					aAdd( aAfast, { STR0088 + cSitu } )
				EndIf

			EndIf
		Else
			aAdd( aAfast, { STR0088 + cSitu } )			
		EndIf

	EndIf

	RestArea( aArea )
Return()