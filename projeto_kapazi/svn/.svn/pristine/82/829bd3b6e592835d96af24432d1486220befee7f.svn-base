#include 'protheus.ch'
#include 'parmtype.ch'

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| FISCAL                                                                                                                                 |
| relatorio do arquivo XML Ct-e para as tabelas ZC1 e ZC2                                                                        |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 24.05.2018                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//05.07.2018
user function REL_CTE()


	Local oReport
	Private cPerg := padr("RELCTE",10)
	Private nTotal	:= 0

	CriaSx1()
	if !Pergunte(cPerg,.T.)
		return .F.
	endif

	oReport := ReportDefB()

	oReport:PrintDialog()

Return 

/*
+------------+------------------------------------------------------------+
! Descricao  ! Rotina para criar a estrutura do relatorio                 !
+------------+------------------------------------------------------------+
! Sintaxe    ! ReportDefB()                                               !
+------------+------------------------------------------------------------+
! Parametros ! Nenhum                                                     !
+------------+------------------------------------------------------------+
*/

Static Function ReportDefB()

	Local cTitle	:= OemToAnsi ("Relação de CT-e")
	Local cHelp		:= OemToAnsi ("Permite gerar relatório do notas importadas CT-e")
	Local oReport
	Local oCTeCab
//	Local oCTeitens  
	Local oQcli
	Local cAlias  	:= getNextAlias()

	oReport	:= TReport():New("REL_CTE",cTitle,cPerg,{|oReport| ReportPrint(oReport,cAlias)},cHelp)

	oReport:setTotalInLine (.F.)


	oCTeCab := TRSection():New(oReport,"Ct-e","ZC1")
	trCell():new(oCTeCab,"ZC1_CTE"   	,"ZC1","Chave Ct-e"	   	  ,PesqPict("ZC1","ZC1_CTE")	,TamSx3("ZC1_CTE")[1]+15)
	trCell():new(oCTeCab,"ZC1_DTLANC"	,"ZC1","Data lancamento"  ,PesqPict("ZC1","ZC1_DTLANC")	,TamSx3("ZC1_DTLANC")[1]+15)
	trCell():new(oCTeCab,"ZC1_DTEMIS"	,"ZC1","Data Emissão"	  ,PesqPict("ZC1","ZC1_DTEMIS")	,TamSx3("ZC1_DTEMIS")[1]+15)
	trCell():new(oCTeCab,"ZC1_FORNEC"	,"ZC1","Fornecedor"	   	  ,PesqPict("ZC1","ZC1_FORNEC")	,TamSx3("ZC1_FORNEC")[1]+15)
	trCell():new(oCTeCab,"ZC1_CODCLI"	,"ZC1","Cliente"	   	  ,PesqPict("ZC1","ZC1_CODCLI")	,TamSx3("ZC1_CODCLI")[1]+15)
	trCell():new(oCTeCab,"ZC1_VLSERV"	,"ZC1","Vlr. Serviço" 	  ,PesqPict("ZC1","ZC1_VLSERV")	,TamSx3("ZC1_VLSERV")[1]+15)
	trCell():new(oCTeCab,"ZC1_FRETE"	,"ZC1","Vlr. Frete"	   	  ,PesqPict("ZC1","ZC1_FRETE")	,TamSx3("ZC1_FRETE")[1]+15)
	trCell():new(oCTeCab,"ZC1_PEDAGI"	,"ZC1","Vlr. Pedagio"	  ,PesqPict("ZC1","ZC1_PEDAGI")	,TamSx3("ZC1_PEDAGI")[1]+15)
	trCell():new(oCTeCab,"ZC1_OUTROS"	,"ZC1","Vlr. Outros"	  ,PesqPict("ZC1","ZC1_OUTROS")	,TamSx3("ZC1_OUTROS")[1]+15)	
	trCell():new(oCTeCab,"ZC2_NUMNFE"	,"ZC2","Numero NF-e"  		,PesqPict("ZC2","ZC2_NUMNFE")  	,TamSx3("ZC2_NUMNFE")[1]+10)
	trCell():new(oCTeCab,"ZC2_SERIE"	,"ZC2","Serie NF-e"  		,PesqPict("ZC2","ZC2_SERIE")  	,TamSx3("ZC2_SERIE")[1]+5)
	trCell():new(oCTeCab,"ZC2_CHAVE"	,"ZC2","Chave NF-e"		  	,PesqPict("ZC2","ZC2_CHAVE")	,TamSx3("ZC2_CHAVE")[1]+15)


	oCTeCab:SetHeaderBreak(.T.) 


	//oCTeitens := TRSection():New(oCTeCab,"Nota","ZC2")
	/*trCell():new(oCTeitens,"ZC2_NUMNFE"	,"ZC2","Numero NF-e"  		,PesqPict("ZC2","ZC2_NUMNFE")  	,TamSx3("ZC2_NUMNFE")[1]+10)
	trCell():new(oCTeitens,"ZC2_SERIE"	,"ZC2","Serie NF-e"  		,PesqPict("ZC2","ZC2_SERIE")  	,TamSx3("ZC2_SERIE")[1]+5)
	trCell():new(oCTeitens,"ZC2_CHAVE"	,"ZC2","Chave NF-e"		  	,PesqPict("ZC2","ZC2_CHAVE")	,TamSx3("ZC2_CHAVE")[1]+15)*/


	/*oCTeitens:SetLeftMargin(3) // margem a direta
	oCTeitens:SetHeaderBreak(.T.)  // cabeçalho da celula*/
 
Return (oReport)

/*
+------------+--------------------------------------------------------------+
! Descricao  ! Rotina para impressão do relatorio                         	!
+------------+--------------------------------------------------------------+
! Sintaxe    ! ReportPrint(oReport,cAlias)                                 	!
+------------+--------------------------------------------------------------+
! Parametros ! oReport: Estrutura do relatório                            	!
!            ! cAlias: Alias temporário                                     !
+------------+--------------------------------------------------------------+
*/

static function ReportPrint(oReport,cAlias)
	Local oCTeCab 		:= oReport:Section(1)
	//Local oCTeitens 	:= oReport:Section(1):Section(1)
	Local cVarAux 	:= ""
	Local nQtdReg 	:= 0
	Local cVarAux	:= ""
	Local cCte		:= ""
	Local dDTLanc	:= CTOD("  /  /    ")  
	Local dDTemis	:= CTOD("  /  /    ")  
	Local cFornec 	:= "" 
	Local cClient 	:= ""
	Local nVlserv 	:= 0
	Local nVlFret 	:= 0
	Local nVlPeda 	:= 0
	Local nVlOutr 	:= 0
	local cNumNFe   := "" 
	local cSerie    := "" 
	local cChaveNfe := ""

 

	oCTeCab:BeginQuery()
	//oCTeitens:BeginQuery()
	BeginSql Alias cAlias
		SELECT * FROM %table:ZC1%  ZC1

		INNER JOIN %table:ZC2% ZC2 ON 
			ZC1_FILIAL = ZC2_FILIAL
		AND ZC1_CTE = ZC2_CTE
		AND ZC2.D_E_L_E_T_ <> '*'

		WHERE 
			ZC1.D_E_L_E_T_ <> '*'
		AND ZC1.ZC1_DTEMIS between  %Exp:DTOS(mv_par01)% and  %Exp:DTOS(mv_par02)%   //  "' + mv_par01 + "' AND "' + mv_par02 + "' " 
		AND ZC2.ZC2_NUMNFE between %Exp:mv_par03% and %Exp:mv_par04% 
		AND ZC1.ZC1_CODCLI between %Exp:mv_par05% and %Exp:mv_par06% 

		ORDER BY ZC1_DTEMIS

	EndSql
	oCTeCab:endQuery()
	//oCTeitens:endQuery()


	(cAlias)->(dbGoTop())
	nQtdReg := 0
	Count to nQtdReg
	(cAlias)->(dbGoTop())
	oReport:SetMeter(nQtdReg)

	oCTeCab:init()
 
	while !(cAlias)->(Eof()) .And. !oReport:Cancel()

		oCTeCab:PrintLine()
		cCte	  := (cAlias)->ZC1_CTE
		dDTLanc   := (cAlias)->ZC1_DTLANC  
		dDTemis   := (cAlias)->ZC1_DTEMIS  
		cFornec   := (cAlias)->ZC1_FORNEC  
		cClient   := (cAlias)->ZC1_CODCLI 
		nVlserv   := (cAlias)->ZC1_VLSERV   
		nVlFret   := (cAlias)->ZC1_FRETE 
		nVlPeda   := (cAlias)->ZC1_PEDAGI
		nVlOutr   := (cAlias)->ZC1_OUTROS
		cNumNFe   := (cAlias)->ZC2_NUMNFE  
		cSerie    := (cAlias)->ZC2_SERIE  
		cChaveNfe := (cAlias)->ZC2_CHAVE 


		/*oCTeitens:init()

		while !(cAlias)->(Eof()) .And. cCte == (cAlias)->ZC2_CTE .And. !oReport:Cancel()
			oCTeitens:PrintLine()
			(cAlias)->(dbSkip())
			oReport:IncMeter()
		enddo
		oCTeitens:Finish()*/
		(cAlias)->(dbSkip())
		
		//oReport:SkipLine()
	enddo
	oCTeCab:Finish()


return

/*
+------------+------------------------------------------------------------+
! Descricao  ! Rotina para criação das perguntas do relatorio             !
+------------+------------------------------------------------------------+
! Sintaxe    ! CriaSx1()                                                  !
+------------+------------------------------------------------------------+
! Parametros ! Nenhum                                                     !
+------------+------------------------------------------------------------+
*/
static function CriaSx1()
	//_PutSx1(cPerg,"01","Da Filial?" 	   ,"Da Filial?" 	 ,"Da Filial?" 	    ,"mv_ch1","C",02,0,0,"G","" ,""	,"","","mv_par01","","","","","","","","","","","","","","","","",{"Data inicial"})
	//_PutSx1(cPerg,"02","Até Filial?"	   ,"Até Filial?"	 ,"Até Filial?"	    ,"mv_ch2","C",02,0,0,"G","" ,""	,"","","mv_par02","","","","","","","","","","","","","","","","",{"Data Final"})
	_PutSx1(cPerg,"01","Emissao de?"    ,"Emissao de?" 	 ,"Emissao de?" 	,"mv_ch1","D",08,0,0,"G","" ,""	,"","","mv_par01","","","","","","","","","","","","","","","","",{"Emissao de..."})
	_PutSx1(cPerg,"02","Emissao até?"   ,"Emissao até?"	 ,"Emissao até?"	,"mv_ch2","D",08,0,0,"G","" ,""	,"","","mv_par02","","","","","","","","","","","","","","","","",{"Emissao até..."})
	//_PutSx1(cPerg,"05","Da transp.?"    ,"Da transp.?" 	 ,"Da transp.?" 	,"mv_ch5","C",06,0,0,"G","" ,"SA4"	,"","","mv_par05","","","","","","","","","","","","","","","","",{"Da transposttadora..."})
	//_PutSx1(cPerg,"06","Até transp.?"   ,"Até transp.?"	 ,"Até transp.?"	,"mv_ch6","C",06,0,0,"G","" ,"SA4"	,"","","mv_par06","","","","","","","","","","","","","","","","",{"Até transportadora..."})
	_PutSx1(cPerg,"03","Num. NF-E de?"  ,"Num. NF-E de?"  ,"Num. NF-E de"	,"mv_ch3","C",06,0,0,"G","" ,""	,"","","mv_par03","","","","","","","","","","","","","","","","",{"Numero NF-e de..."})
	_PutSx1(cPerg,"04","Num. NF-E até"  ,"Num. NF-E até?" ,"Num. NF-E até?"	,"mv_ch4","C",06,0,0,"G","" ,""	,"","","mv_par04","","","","","","","","","","","","","","","","",{"Numero NF-e até..."})
	_PutSx1(cPerg,"05","Do Cliente?"    ,"Do Cliente?"	 ,"Do Cliente?"	    ,"mv_ch5","C",06,0,0,"G","" ,"SA1"	,"","","mv_par05","","","","","","","","","","","","","","","","",{"Do cliente..."})
	_PutSx1(cPerg,"06","Até Cliente.?"  ,"Até Cliente.?" ,"Até Cliente.?"	,"mv_ch6","C",06,0,0,"G","" ,"SA1"	,"","","mv_par06","","","","","","","","","","","","","","","","",{"Até cliente..."})
return


Static Function _PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)
	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f.
	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	cPyme    := Iif( cPyme   == Nil, " ", cPyme  )
	cF3      := Iif( cF3   == NIl, " ", cF3  )
	cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg )
	cCnt01   := Iif( cCnt01  == Nil, "" , cCnt01  )
	cHelp  := Iif( cHelp  == Nil, "" , cHelp  )
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	If !( DbSeek( cGrupo + cOrdem ))
		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		Reclock( "SX1" , .T. )
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
		Replace X1_VAR01   With cVar01
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
		Replace X1_HELP  With cHelp
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		MsUnlock()
	Else
		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	RestArea( aArea )
Return   





