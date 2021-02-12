#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: RELCUSTM		|	Autor: Luis Paulo							|	Data: 12/08/2020	//
//==================================================================================================//
//	Descricao: Rel Custo médio dos Produtos															//
//																									//
//==================================================================================================//
User Function RELCUSTM()
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

	AAdd(aParamBox, { 1,"Filial de?"	,Space(02),"","","SM0","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Filial Até?"	,Space(02),"","","SM0","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Produto de?"	,Space(15),"","","SB1","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Produto Até?"	,Space(15),"","","SB1","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Grupo de?"	    ,Space(04),"","","SBM","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Grupo Até?"	,Space(04),"","","SBM","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Amz De?"		,Space(02),"","","NNR","",0,.F.}) // Tipo caractere
	AAdd(aParamBox, { 1,"Amz Até?"		,Space(02),"","","NNR","",0,.F.}) // Tipo caractere
   	AAdd(aParamBox,	{ 2,"Prod Bloq?" 	,1		  ,aSimNao	,50,"",.T.})

If ParamBox(aParamBox,"RELATORIO DE CUSTO MÉDIO- PRODUTOS", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
	TrataPer()
Endif

Return()

//Pode ser trazendo os custos da ï¿½ltima nf que estï¿½ no kardex e ficando fï¿½cil a consulta
Static Function TrataPer()
Local cQr 			:= ""
Local lRet			:= .T.
Local nRegs			:= 0
Local cLinha		:= ""
Local nCount		:= 0
Local _cPerg9		:= aRet[9]
Private nHdlLog
Private cAlias2		:= GetNextAlias()
Private cNmArq

If !ValType(_cPerg9) == "N"
	
	If _cPerg9 == "NAO"
			_cPerg9 := 1
		ElseIf	_cPerg9 == "SIM"
			_cPerg9 := 2
	EndiF

EndIf

If Select((cAlias2))<>0
	DbSelectArea((cAlias2))
	DbCloseArea()
Endif

cQr += " SELECT B1_DESC,B1_GRUPO,ISNULL(BM_DESC,'') BM_DESC ,SB2.*, "+cCRLF

cQr += " (SELECT SUM(B2_CM1) AS SOMA FROM "+ RetSqlName("SB2") +" WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '"+aRet[1]+"' AND B2_FILIAL <= '"+aRet[2]+"' AND B2_COD = SB1.B1_COD  ) AS VLTOT, "+cCRLF
cQr += " (SELECT COUNT(*) AS QTD FROM "+ RetSqlName("SB2") +" WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '"+aRet[1]+"' AND B2_FILIAL <= '"+aRet[2]+"' AND B2_COD = SB1.B1_COD  ) AS QTDTOT "+cCRLF

cQr += " FROM "+ RetSqlName("SB1") +" SB1 "+cCRLF
cQr += " INNER JOIN "+ RetSqlName("SB2") +" SB2 ON SB2.B2_FILIAL >= '"+aRet[1]+"' AND SB2.B2_FILIAL <= '"+aRet[2]+"' AND SB2.B2_LOCAL >= '"+aRet[7]+"' AND SB2.B2_LOCAL <= '"+aRet[8]+"' "+cCRLF
cQr += " AND SB1.B1_COD = SB2.B2_COD AND  SB2.D_E_L_E_T_ = '' AND B2_QATU > 0 "+cCRLF

cQr += " LEFT JOIN "+ RetSqlName("SBM") +" SBM ON SB1.B1_GRUPO = SBM.BM_GRUPO AND SBM.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SB1.D_E_L_E_T_ = '' "+cCRLF
cQr += " AND SB1.B1_COD >= '"+aRet[3]+"'"+cCRLF
cQr += " AND SB1.B1_COD <= '"+aRet[4]+"'" +cCRLF
cQr += " AND SB1.B1_GRUPO >= '"+aRet[5]+"'" +cCRLF
cQr += " AND SB1.B1_GRUPO <= '"+aRet[6]+"'" +cCRLF

If _cPerg9 == 1 //lista produto bloqueado?
	cQr += " AND SB1.B1_MSBLQL <> '1'
EndIf

cQr += " ORDER BY B2_COD + B2_FILIAL " +cCRLF

Conout("")
Conout(cQr)
Conout("")
// abre a query
TcQuery cQr new Alias (cAlias2)

DbSelectArea((cAlias2))
(cAlias2)->(DbGoTop())

If (cAlias2)->(EOF())
		MsgInfo("Nao existem PRODUTO!!","KAPAZI")
	Else
		REPRRBL() 			//Cria o arquivo XML
		xGeraXml()
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
! Funcï¿½o    ! REPRRBL   ! Autor !Luis                ! Data ! 09/05/2020  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Cria arquivo.  		                                       !
+-----------+--------------------------------------------------------------+
*/
Static Function REPRRBL()
//cria arquivo de log
cDir := "\RelCustoM"
if !ExistDir(cDir)
	//cria diretorio
	MakeDir(cDir)
endif

//cNmArq := "PED-VENDA" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt + ".csv"
cNmArq := "RelCustoMedio" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt+".xml"
//nHdlLog := msFCreate( Alltrim(cDir+cNmArq) ) //Vai ser gerado XML
Return()


/*
+--------------------------------------------------------------------------+
! Funcï¿½o    ! KP97ABAR   ! Autor !Luis   			  ! Data ! 02/07/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Exibe arquivo de importacao.                                 !
+-----------+--------------------------------------------------------------+
*/
Static Function KP97ABAR(cAArq, cDir)

If CPYS2T(cDir+cAArq, cDirTemp,.F.,.F.)
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
Local 	_cDir 		:= "\RelCustoM\" //GetSrvProfString("Startpath","")
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
oExcel:AddworkSheet("PLANILHA")							    //Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable("PLANILHA","PRODUTO")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("PLANILHA","PRODUTO","FILIAL"		,2,1)
oExcel:AddColumn("PLANILHA","PRODUTO","CODIGO"		,1,1)
oExcel:AddColumn("PLANILHA","PRODUTO","DESCRI"		,1,1)
oExcel:AddColumn("PLANILHA","PRODUTO","GRUPO"		,1,1)
oExcel:AddColumn("PLANILHA","PRODUTO","DESCRICAO"	,1,1)
oExcel:AddColumn("PLANILHA","PRODUTO","AMZ"			,2,1)
oExcel:AddColumn("PLANILHA","PRODUTO","QTD EST"		,2,1)
oExcel:AddColumn("PLANILHA","PRODUTO","CUSTOMEDIO"	,2,1)

ProcRegua(0)
While !(cAlias2)->(EOF())
	IncProc()
	
    //Filial + Codigo + Descri + Grupo + Descricao + Und Med + Ult NF + Custo Medio(atual)
	DbSelectArea( "SB1" )
    SB1->( DbSetOrder(1) ) 
    SB1->( DbSeek(xFilial("SB1") + (cAlias2)->B2_COD) )

	DbSelectArea( "SBZ" )
    SBZ->( DbSetOrder(1) ) 
    SBZ->( DbSeek(xFilial("SBZ") + (cAlias2)->B2_COD) )

    //cValorCM		:= Alltrim(Transform( ((cAlias2)->VLTOT / (cAlias2)->QTDTOT)  ,"@E 999,999,999.99"))

	cValorCM		:= Alltrim(Transform( (cAlias2)->B2_CM1  ,"@E 999,999,999.99"))
	cQtdEst			:= Alltrim(Transform((cAlias2)->B2_QATU,"@E 999,999,999.99"))

    oExcel:AddRow("PLANILHA","PRODUTO"	,   	{	Alltrim((cAlias2)->B2_FILIAL)	,;
													Alltrim((cAlias2)->B2_COD)  	,;
													Alltrim((cAlias2)->B1_DESC)  	,;
                                                    Alltrim((cAlias2)->B1_GRUPO) 	,;
                                                    Alltrim((cAlias2)->BM_DESC)		,;
													Alltrim((cAlias2)->B2_LOCAL)	,;
                                                    cQtdEst 						,;
													cValorCM})
    
	
   
	//oExcel:AddRow("PLANILHA","PRODUTO"	,   {"","","","","","","","",""}) 

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
	
		MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretorio " + _cDir , "KAPAZI")
		MsgInfo( "Arquivo não copiado para temporario do usuario!!!","KAPAZI" )

Endif
	
Return()
