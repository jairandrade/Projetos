#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: RELPRODE		|	Autor: Luis Paulo							|	Data: 09/05/2020	//
//==================================================================================================//
//	Descricao: Rel Produtos e custos																//
//																									//
//==================================================================================================//
User Function RELPRODE()
Local 		_cHour
Local 		_cMin
Local 		_cSecs
Local 		aParamBox 	:= {}
Local 		aSimNao		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private		_cTimeF
Private 	aSelFil		:={}
Private 	cCRLF		:= CRLF
Private 	cAlias2
Private 	_cPerg1
Private 	_cPerg2
Private 	_cPerg3
Private 	_cPerg4
Private 	_cPerg5
Private 	nRegs		:= 0
Private		nCount		:= 0
Private 	cCodigo		:= ""
Private 	oPrn
Private 	lDiaUt		:= .t.	
Private 	nFator		:= 1

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs

	AAdd(aParamBox, { 1,"Produto de?"	,Space(15),"","","SB1","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Produto At�?"	,Space(15),"","","SB1","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Grupo de?"	    ,Space(04),"","","SBM","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Grupo At�?"	,Space(04),"","","SBM","",0,.F.}) // Tipo caractere
    AAdd(aParamBox, { 1,"Data?"         ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
    //AAdd(aParamBox, { 6,"Buscar arquivo",Space(50),"","","",50,.F.,"Todos os arquivos (*.*) |*.*"})

If ParamBox(aParamBox,"RELATORIO - PRODUTOS", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
	TrataPer()
Endif

Return()

//Pode ser trazendo os custos da �ltima nf que est� no kardex e ficando f�cil a consulta
Static Function TrataPer()
Local cQr 			:= ""
Local lRet			:= .T.
Local nRegs			:= 0
Local cLinha		:= ""
Local nCount		:= 0
Private nHdlLog
Private cAlias2		:= GetNextAlias()
Private cNmArq

//cDirProc := aRet[6]

If Select((cAlias2))<>0
	DbSelectArea((cAlias2))
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,
cQr += " (SELECT TOP 1 B2_CM1 FROM SB2010 WHERE D_E_L_E_T_ = '' AND B2_COD = B1_COD ORDER BY B2_CM1 DESC) CMATU,
cQr += " (SELECT TOP 1 D1_CUSTO/D1_QUANT FROM SD1010 WHERE D_E_L_E_T_ = '' AND D1_COD = B1_COD AND D1_EMISSAO <= '"+ dtos(aRet[5]) +"' ORDER BY R_E_C_N_O_ DESC ) AS CUSTOENT,
cQr += " * "
cQr += " FROM "+ RetSqlName("SB1") +" SB1 "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += " AND B1_COD >= '"+aRet[1]+"'"
cQr += " AND B1_COD <= '"+aRet[2]+"'"
cQr += " AND B1_GRUPO >= '"+aRet[3]+"'"
cQr += " AND B1_GRUPO <= '"+aRet[4]+"'"

// abre a query
TcQuery cQr new Alias (cAlias2)

DbSelectArea((cAlias2))
(cAlias2)->(DbGoTop())

If (cAlias2)->(EOF())
		MsgInfo("Nao existem ESTRUTURA!!","KAPAZI")
	Else
		REPRRBL() 			//Cria o arquivo XML
		xGeraXml()
		//If FM_Direct( cDirProc, .F., .F. )	//Caso nao tenha o diretorio Supplier, criaa
			
		//EndIf
		
EndIf

(cAlias2)->(DbCloseArea())
Return()


//Senao existe cria o diretorio
Static Function FM_Direct( cPath, lDrive, lMSg )
Local aDir
Local lRet:=.T.
Default lMSg := .T.

If Empty(cPath)
	Return lRet
EndIf

lDrive := If(lDrive == Nil, .T., lDrive)
cPath := Alltrim(cPath)

If Subst(cPath,2,1) <> ":" .AND. lDrive
	MsgInfo("Unidade de drive nao especificada") //Unidade de drive n?o especificada
	lRet:=.F.
	Else
		cPath := If(Right(cPath,1) == "", Left(cPath,Len(cPath)-1), cPath)
	aDir  := Directory(cPath,"D")
	If Len(aDir) = 0
		If lMSg
			If MsgYesNo("Diretorio - "+cPath+" - nao encontrado, deseja cria-lo" ) //Diretorio  -  nao encontrado, deseja cria-lo
				If MakeDir(cPath) <> 0
					Help(" ",1,"NOMAKEDIR")
					lRet := .F.
				EndIf
			EndIf
		
		Else
			If MakeDir(cPath) <> 0
				Help(" ",1,"NOMAKEDIR")
				lRet := .F.
			EndIf
			
		EndIF
	EndIf
EndIf
Return lRet

/*
+--------------------------------------------------------------------------+
! Func�o    ! REPRRBL   ! Autor !Luis                ! Data ! 09/05/2020  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Cria arquivo.  		                                       !
+-----------+--------------------------------------------------------------+
*/
Static Function REPRRBL()
//cria arquivo de log
cDir := "\RelProd"
if !ExistDir(cDir)
	//cria diretorio
	MakeDir(cDir)
endif

//cNmArq := "PED-VENDA" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt + ".csv"
cNmArq := "RelProd" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt+".xml"
//nHdlLog := msFCreate( Alltrim(cDir+cNmArq) ) //Vai ser gerado XML
Return()


/*
+--------------------------------------------------------------------------+
! Func�o    ! KP97ABAR   ! Autor !Luis   			  ! Data ! 02/07/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Exibe arquivo de importacao.                                 !
+-----------+--------------------------------------------------------------+
*/
Static Function KP97ABAR(cAArq, cDir)

If CPYS2T(cDir+cAArq, cDirTemp,.F.,.F.)
		//FErase(cDir+cAArq)
		ShellExecute( "open", cDirTemp+Alltrim(cAArq) , "" , "" ,  1 )
	
	Else
		MsgInfo("Nao foi possivel copiar o arquivo do servidor! -> " + Str(FError()))
		Conout(FError())
EndIf

Return()


Static Function xGeraXml()
Local 	cDir    	:= "C:\TEMP\"
Local 	cArq    	:= ""
Local 	nLinha		:= 1
Local 	_cCad		:= "Gerar XML"
Local 	_cDirTmp 	:= ""	//:= "C:\TEMP\"
Local 	_cDir 		:= "\RelProd\" //GetSrvProfString("Startpath","")
Local 	_cHour		:= ""
Local 	_cMin		:= ""
Local 	_cSecs		:= ""
Local 	cValor
Local cDirectory	:= ""
Private cValorNF    
Private cValorCM
Private cQtdEst
Private oExcel
Private cFechEst	:= DTOS(GetMv("MV_ULMES"))

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'c:\Temp\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs

cArq    	:= cNmArq

oExcel := FWMsExcel():New()		//Instancia a classe

//Codigo + Tipo + Grupo + Descricao + Und Med + Ult NF + Custo Medio(atual)

//Alinhamento da coluna ( 1-Left,2-Center,3-Right )
//Codigo de formata��o ( 1-General,2-Number,3-Monet�rio,4-DateTime )	

oExcel:AddworkSheet("PLANILHA")							    //Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable("PLANILHA","ESTRUTURA")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("PLANILHA","ESTRUTURA","NIVEL"		,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","CODIGO"	,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","TIPO"		,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","GRUPO"		,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","DESCRICAO"	,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","QTD EST"	,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","UNDMED"	,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","ULTNF"	    ,2,1)
oExcel:AddColumn("PLANILHA","ESTRUTURA","CM"	    ,2,1)

//Alinhamento da coluna ( 1-Left,2-Center,3-Right )
//Codigo de formata��o ( 1-General,2-Number,3-Monet�rio,4-DateTime )
/*
oExcel:SetFont('Arial')
oExcel:SetFontSize(10)
oExcel:SetTitleBold(.T.)
oExcel:SetTitleSizeFont(16)
oExcel:SetHeaderBold(.T.)
oExcel:SetHeaderSizeFont(14)
oExcel:SetBold(.T.)
*/
ProcRegua(0)
While !(cAlias2)->(EOF())
	IncProc()
	
    //Codigo + Tipo + Grupo + Descricao + Und Med + Ult NF + Custo Medio(atual)

    //oExcel:AddRow("Teste - 1","Titulo de teste 1",{41,42,43,44})

	DbSelectArea( "SB1" )
    SB1->( DbSetOrder(1) ) 
    SB1->( DbSeek(xFilial("SB1") + (cAlias2)->B1_COD) )

	DbSelectArea( "SG1" )
	SG1->( DbSetOrder(1) ) 
	SG1->( DbSeek(xFilial("SG1") + (cAlias2)->B1_COD) )

	DbSelectArea( "SBZ" )
    SBZ->( DbSetOrder(1) ) 
    SBZ->( DbSeek(xFilial("SBZ") + (cAlias2)->B1_COD) )

	cValorNF		:= Alltrim(Transform((cAlias2)->CUSTOENT,"@E 999,999,999.99"))
    cValorCM		:= Alltrim(Transform((cAlias2)->CMATU,"@E 999,999,999.99"))
	
    oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {	"000000"					,;
													Alltrim((cAlias2)->B1_COD)  ,;
                                                    Alltrim((cAlias2)->B1_TIPO) ,;
                                                    Alltrim((cAlias2)->B1_GRUPO),;
                                                    Alltrim((cAlias2)->B1_DESC) ,;
													RetFldProd(SB1->B1_COD,"B1_QB"),;
                                                    Alltrim((cAlias2)->B1_UM)   ,;
                                                    cValorNF,;
                                                    cValorCM})
    
	
   

    BusEstru((cAlias2)->B1_COD,RetFldProd(SB1->B1_COD,"B1_QB"),aRet[5]) //Busca a estrutura

    oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {"","","","","","","","",""}) 
	oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {"","","","","","","","",""})

    (cAlias2)->(DbSkip())

EndDo

oExcel:Activate() 				//Habilita o uso da classe, indicando que esta configurada e pronto para uso
oExcel:GetXMLFile(_cDir+cNmArq)	//Arquivo teste.xml gerado com sucesso no \system\

Sleep(2000)

If __CopyFile( _cDir + cArq, _cDirTmp + cArq )

		//oExcelApp := MsExcel():New()
		//oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
		//oExcelApp:SetVisible(.T.)
		MsgInfo( "Finalizado com sucesso!!!","KAPAZI" )
	ELSE
	
		MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diret�rio " + _cDir , "KAPAZI")
		MsgInfo( "Arquivo n�o copiado para tempor�rio do usu�rio!!!","KAPAZI" )

Endif
	
Return()


Static Function BusEstru(cProduto,nQuant,dDataEnt)
Local aAreaSB1	 := SB1->(GetArea())
Local aAreaSG1	 := SG1->(GetArea())
Local nTotPrazo  := 0  // Prazo de Entrega total do produto
Local nPrazoNiv  := 0  // Prazo de Entrega deste Nivel
Local cNivel     := "" // Nivel da Estrutura em que esta sendo feito o calculo
Local oTempTable := NIL
Local cAliasE1	 :=  GetNextAlias()	 
Local aRet2      := {}
Private nEstru   := 0

Default dDataEnt := dDataBase

Estrut2(cProduto,nQuant,(cAliasE1),@oTempTable,.T.)
(cAliasE1)->(dbGoTop())
While !(cAliasE1)->(EOF())
	
    /*
    AADD(aCampos,{"NIVEL","C",6,0})
	AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
	AADD(aCampos,{"COMP","C",aTamSX3[1],0})
	AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
	AADD(aCampos,{"TRT","C",aTamSX3[1],0})
	AADD(aCampos,{"GROPC","C",aTamSX3[1],0})
	AADD(aCampos,{"OPC","C",aTamSX3[1],0})
	AADD(aCampos,{"REGISTRO","N",14,0})
    */
	If Alltrim((cAliasE1)->NIVEL) == "000001"

		DbSelectArea( "SB1" )
		SB1->( DbSetOrder(1) ) 
		SB1->( DbSeek(xFilial("SB1") + (cAliasE1)->COMP ))

		aRet2 := BuscaCus((cAliasE1)->COMP)
		cValorNF  		:= Alltrim(Transform(aRet2[1],"@E 999,999,999.99"))
    	cValorCM		:= Alltrim(Transform(aRet2[2],"@E 999,999,999.99"))
		cQtdEst			:= Alltrim(Transform((cAliasE1)->QUANT,"@E 999,999,999.99"))

		oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {	Alltrim((cAliasE1)->NIVEL),;
														Alltrim((cAliasE1)->COMP),;
														Alltrim(SB1->B1_TIPO),;
														Alltrim(SB1->B1_GRUPO),;
														Alltrim(SB1->B1_DESC),;
														cQtdEst,;
														Alltrim(SB1->B1_UM),;
														cValorNF,;
														cValorCM})

		BuscaNKP((cAliasE1)->COMP,.T.,(cAliasE1)->CODIGO)

		oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {"","","","","","","","",""})
	EndIf	
	
	(cAliasE1)->(dbSkip())
EndDo

oTempTable:Delete()

SG1->(RestArea(aAreaSG1))
SB1->(RestArea(aAreaSB1))

Return()



Static Function BuscaNKP(cComponente,lPriNv,cCodPro)
Local aAreaSB1	 := SB1->(GetArea())
Local aAreaSG1	 := SG1->(GetArea())
Local aRet2		 := {}
Local nRecoG1	 := 0
Default dDataEnt := dDataBase
Default cCodPro  := ""

DbSelectArea('SG1')
SG1->(DbSetOrder(1))
SG1->(DbGoTop())
If SG1->(DBSeek(xFilial('SG1') + cComponente))

		If !lPriNv
			DbSelectArea( "SB1" )
			SB1->( DbSetOrder(1) ) 
			SB1->( DbSeek(xFilial("SB1") + SG1->G1_COD ))

			nRecoG1 := SG1->(RECNO())

			DbSelectArea('SG1')
			SG1->(DbSetOrder(1))
			SG1->(DbGoTop())
			SG1->(DBSeek(xFilial('SG1') + cCodPro + cComponente))

			aRet2 := BuscaCus(cComponente)
			cValorNF  		:= Alltrim(Transform(aRet2[1],"@E 999,999,999.99"))
			cValorCM		:= Alltrim(Transform(aRet2[2],"@E 999,999,999.99"))

			cQtdEst			:= Alltrim(Transform(SG1->G1_QUANT,"@E 999,999,999.99"))

			oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {"","","","","","","","",""})

			oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {	"",;
															Alltrim(cComponente),;
															Alltrim(SB1->B1_TIPO),;
															Alltrim(SB1->B1_GRUPO),;
															Alltrim(SB1->B1_DESC),;
															cQtdEst,;
															Alltrim(SB1->B1_UM),;
															cValorNF,;
															cValorCM})
			DbSelectArea('SG1')
			SG1->(DbGoTo(nRecoG1))

		EndIf 

		While !(SG1->(Eof())) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial('SG1') + cComponente

			BuscaNKP(SG1->G1_COMP,.f.,SG1->G1_COD)

			SG1->(DbSkip())
		EndDo

	Else
		If !lPriNv
			DbSelectArea( "SB1" )
			SB1->( DbSetOrder(1) ) 
			SB1->( DbSeek(xFilial("SB1") + cComponente ))

			DbSelectArea('SG1')
			SG1->(DbSetOrder(1))
			SG1->(DbGoTop())
			SG1->(DBSeek(xFilial('SG1') + cCodPro + cComponente))

			aRet2 := BuscaCus(cComponente)
			cValorNF  		:= Alltrim(Transform(aRet2[1],"@E 999,999,999.99"))
			cValorCM		:= Alltrim(Transform(aRet2[2],"@E 999,999,999.99"))
			cQtdEst			:= Alltrim(Transform(SG1->G1_QUANT,"@E 999,999,999.99"))

			oExcel:AddRow("PLANILHA","ESTRUTURA"	,   {	"",;
															Alltrim(cComponente),;
															Alltrim(SB1->B1_TIPO),;
															Alltrim(SB1->B1_GRUPO),;
															Alltrim(SB1->B1_DESC),;
															cQtdEst,;
															Alltrim(SB1->B1_UM),;
															cValorNF,;
															cValorCM})
		EndIf
		Conout("nao tem componente")
EndIf 

SG1->(RestArea(aAreaSG1))
SB1->(RestArea(aAreaSB1))

Return()

Static Function BuscaCus(cProdCto)
Local aArea     := GetArea()
Local cAlias3	:= GetNextAlias()
Local cQr       := ""
Local aRetFim    := {}

If Select((cAlias3))<>0
	DbSelectArea((cAlias3))
	(cAlias3)->(DbCloseArea())
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,
cQr += " (SELECT TOP 1 B2_CM1 FROM "+ RetSqlName("SB2") +" WHERE D_E_L_E_T_ = '' AND B2_COD = B1_COD ORDER BY B2_CM1 DESC) CMATU,
//cQr += " (SELECT TOP 1 B9_CM1 AS CMFECH FROM "+ RetSqlName("SB9") +" WHERE B9_FILIAL = '"+xFilial("SB9")+"' AND B9_COD = B1_COD AND B9_DATA = '"+cFechEst+"' ORDER BY B9_CM1 DESC) CMATU,
cQr += " (SELECT TOP 1 (ISNULL(D1_CUSTO,0)) FROM "+ RetSqlName("SD1") +"  WHERE D_E_L_E_T_ = '' AND D1_COD = B1_COD AND D1_EMISSAO <= '"+ dtos(aRet[5]) +"' AND D1_QUANT > 0 ORDER BY D1_EMISSAO,R_E_C_N_O_ DESC ) AS D1_CUSTO,
cQr += " (SELECT TOP 1 (ISNULL(D1_QUANT,0)) FROM "+ RetSqlName("SD1") +"  WHERE D_E_L_E_T_ = '' AND D1_COD = B1_COD AND D1_EMISSAO <= '"+ dtos(aRet[5]) +"' AND D1_QUANT > 0 ORDER BY D1_EMISSAO,R_E_C_N_O_ DESC ) AS D1_QUANT,
cQr += " * "
cQr += " FROM "+ RetSqlName("SB1") +" SB1 "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += " AND B1_COD = '"+ cProdCto +"'"

// abre a query
TcQuery cQr new Alias (cAlias3)

DbSelectArea((cAlias3))
(cAlias3)->(DbGoTop())

If !(cAlias3)->(EOF())
        aAdd(aRetFim, (cAlias3)->D1_CUSTO / ( iif( Empty( (cAlias3)->D1_QUANT) ,1, (cAlias3)->D1_QUANT)) )
        aAdd(aRetFim,(cAlias3)->CMATU)       
    else
        aAdd(aRetFim,0)
        aAdd(aRetFim,0)
EndIf

(cAlias3)->(DbCloseArea())
RestArea(aArea)

Return(aRetFim)
