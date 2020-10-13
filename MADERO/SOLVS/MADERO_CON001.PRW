#Include "Protheus.ch"  
#Include "FwCommand.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "TBICONN.CH"
#Include "TOTVS.ch"

#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE CRLF CHR(13)+CHR(10)

User Function CON001()

Local oWizard	:= FWWizardControl( ):New( )
Local oStep
Local cQryCN9	:= ""
Local oTmpReg
Local cAliasRes := ""
Local nCont 	:= 0

Private aContOK := {}
Private oBrowReg

Private cFilOri	:= cFilAnt//Space( Len( ADK->ADK_XFILI ) )
Private cFilDes	:= Space( Len( ADK->ADK_XFILI ) )
Private cEmpOri := "02"
Private cEmpDes := "01"

If cEmpAnt <> "02"
	MsgAlert("Processo deve ser feito na empresa 02")
	Return Nil
EndIf

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Parametros" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs(@cQryCN9) } )
oStep:SetPrevAction( { || Alert("Opção inválida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| oTmpReg := fStep02(oPanel,oBrowReg := FWBrowse():New(),cQryCN9) })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( { || Alert("Opção inválida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Log" )
oStep:SetConstruction( { |oPanel| oBrowReg:destroy(), fStep03( oPanel, oTmpReg, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( @cAliasRes ), .T. } )
oStep:SetPrevAction( { || Alert("Opção inválida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oWizard:Activate( )
oWizard:Destroy( )

If oTmpReg != Nil
	oTmpReg:Delete( )
EndIf

If !Empty(cAliasRes)
	(cAliasRes)->(dbCloseArea())
	TCDelFile(cAliasRes)
	TCRefresh(cAliasRes)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fStep01  ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela do primeiro passo.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fStep01( oPanel1, lFacilita )

Local nLinha 		:= 10
Local aGrupos		:= Separa( AllTrim( Posicione( "SX3", 2, PadR( "ADK_XGNEG", Len( SX3->X3_CAMPO ), " " ), "X3_CBOX" ) ), ":" )
Local cGrpNeg		:= fGetGrpNeg( )
Local oPanel

Default lFacilita	:= .F.

oPanel := TScrollBox():New(oPanel1,01,01, oPanel1:nHeight-10, oPanel1:nWidth-10)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT


//TGet():New(nLinha    ,20, bSetGet(cEmpAnt),oPanel, 10, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Empresa ',1,oPanel:oFont)
//TGet():New(nLinha+7.5,40, bSetGet(FWEmpName(cEmpAnt)),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

//nLinha += 25
//TGet():New(nLinha    ,20, bSetGet(cFilAnt),oPanel, (FWSizeFilial()*5), 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Filial',1,oPanel:oFont)
//TGet():New(nLinha+7.5,30+((FWSizeFilial()*5)), bSetGet(FWFilialName()),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

If lFacilita
	If !Empty( cGrpNeg )
		If Len( aGrupos ) < 2
			aGrupos := { "1=Industria", "2=Unidades de Negocio" }
		EndIf
		cGrpNeg := SubStr( aGrupos[AScan( aGrupos, {|x,y| Left( x, 1 ) == cGrpNeg } )], 3 )
	EndIf
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cGrpNeg),oPanel, 120, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Grupo Negoc.',1,oPanel:oFont)
Else	
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cFilOri),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADKRES",cFilOri,,,,,,,'Filial Origem',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cFilDes),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADKIND",cFilDes,,,,,,,'Filial Destino',1,oPanel:oFont)

EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetGrpNegºAutor  ³ Vinícius Moreira   º Data ³ 29/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca grupo da empresa atual.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetGrpNeg( )

Local xRet		:= "1"
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias( )

If ADK->( FieldPos( "ADK_XGEMP" ) ) > 0
	cQuery := "  SELECT " + CRLF 
	cQuery += "    ADK.ADK_XGNEG XGNEG " + CRLF
	cQuery += "   FROM " + RetSQLName( "ADK" ) + " ADK " + CRLF 
	cQuery += "  WHERE ADK.ADK_FILIAL =  '" + xFilial( "ADK" ) + "' " + CRLF
	cQuery += "    AND ADK.ADK_XGEMP  =  '" + cEmpAnt +  "' " + CRLF 
	cQuery += "    AND ADK.ADK_XFILI  =  '" + cFilAnt + "' " + CRLF
	cQuery += "    AND ADK.ADK_XGNEG  <> ' ' " + CRLF  
	cQuery += "    AND ADK.D_E_L_E_T_ =  ' ' " + CRLF
	cQuery += "  GROUP BY " + CRLF
	cQuery += "    ADK.ADK_XGNEG " + CRLF 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	
	If ( cAliasQry )->( !Eof( ) )
		xRet := ( cAliasQry )->XGNEG
	EndIf
	( cAliasQry )->( dbCloseArea( ) ) 
EndIf

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fGetRegs ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca registros que serão processados.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetRegs(cQuery)

Local lRet		:= .F.

cQuery := " SELECT 'F' MARCA, CN9.CN9_NUMERO CONTRATO, (CASE WHEN CN9_ESPCTR='1' THEN A2_NOME ELSE A1_NOME END) AS CLIFOR, "
cQuery += " CN9.CN9_DTINIC DTINI, CN9.CN9_DTFIM DTFIM, CN9.CN9_REVISA REVISA "
cQuery += " FROM " + RetSQLName( "CN9" ) + " CN9 "
cQuery += " JOIN " + RetSQLName( "CNC" ) + " CNC "
cQuery += " ON CNC.CNC_FILIAL  = CN9.CN9_FILIAL "
cQuery += " AND CNC.CNC_NUMERO  = CN9.CN9_NUMERO "
cQuery += " AND CNC.CNC_REVISA  = CN9.CN9_REVISA "
cQuery += " AND CNC.D_E_L_E_T_ = ' ' "
cQuery += " JOIN " + RetSQLName( "SA2" ) + " SA2 "
cQuery += " ON SA2.A2_FILIAL   = '" + xFilial( "SA2" ) + "' "
cQuery += " AND SA2.A2_COD     = CNC.CNC_CODIGO "
cQuery += " AND SA2.A2_LOJA    = CNC.CNC_LOJA "
cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSQLName( "SA1" ) + " SA1 "
cQuery += " ON SA1.A1_FILIAL   = '" + xFilial( "SA1" ) + "' "
cQuery += " AND SA1.A1_COD     = CNC.CNC_CLIENT "
cQuery += " AND SA1.A1_LOJA    = CNC.CNC_LOJACL "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CN9.CN9_FILIAL  = '" + cFilOri + "' "
//cQuery += " AND CN9.CN9_SALDO > 0 " //--Com Saldo
cQuery += " AND CN9.CN9_DTFIM >= '" + Dtos(dDataBase) + "' "
cQuery += " AND CN9.CN9_SITUAC = '05' " //--Vigente
cQuery += " AND CN9.D_E_L_E_T_ = ' ' "

cAliasQry := MPSysOpenQuery(cQuery,"CN9TMP")

If !(lRet := CN9TMP->(!Eof()))
	Alert("Não foram encontrados registros para processamento.")
EndIf

CN9TMP->(dbCloseArea())

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fStep02  ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela do segundo passo.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fStep02(oPanel,oBrowse,cQryCN9)

Local oMark 	:= FWTemporaryTable( ):New( )
Local cAliasAux	:= ""
Local cTabTemp	:= ""
Local cInsert	:= ""
Local aStruct 	:= {{"OK","L",1,0},;
					{"CONTRATO","C",TamSX3("CN9_NUMERO")[1],0},;
					{"CLIFOR","C",TamSX3("A2_NOME")[1],0},;
					{"DTINI","D",TamSX3("CN9_DTINIC")[1],0},;
					{"DTFIM","D",TamSX3("CN9_DTFIM")[1],0},;
					{"REVISA","C",TamSX3("CN9_REVISA")[1],0}}


//-- Inicio da montagem da tabela temporaria
oMark:SetFields(aStruct)
//-- Definindo indice
oMark:AddIndex("01",{"CONTRATO"})
oMark:Create()

cTabTemp := oMark:GetRealName()
//-- Copia dados da CN9 para tabela temporaria, a ser utilizada na mark
cInsert := "INSERT INTO " +cTabTemp +" (OK,CONTRATO,CLIFOR,DTINI,DTFIM,REVISA)"
cInsert += cQryCN9
TCSQLExec(cInsert)

//-- Obtem alias e nome fisico
cAliasAux := oMark:GetAlias()

//Final da montagem da tabela temporaria
//Inicio do browser de exibição dos registros
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable(.T.)
oBrowse:SetAlias(cAliasAux)

oBrowse:AddMarkColumns( ;
	{|| If( (cAliasAux)->OK , "LBOK", "LBNO" ) },;
	{||  (cAliasAux)->OK :=  ! (cAliasAux)->OK } ,;
	{|| MarkAll( oBrowse, cTabTemp ) } )

oBrowse:SetColumns({;
	AddColumn({ || ( cAliasAux )->CONTRATO 	},"Contrato"			, TamSX3("CN9_NUMERO")[1], , "C") ,;
	AddColumn({ || ( cAliasAux )->CLIFOR   	},"Fornecedor/Cliente"	, TamSX3("A2_NOME")[1]	 , , "C") ,;
	AddColumn({ || ( cAliasAux )->DTINI		},"Data Inicio"			, TamSX3("CN9_DTINIC")[1], , "D") ,;
	AddColumn({ || ( cAliasAux )->DTFIM		},"Data Fim"			, TamSX3("CN9_DTFIM")[1] , , "D")  ;
})

oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:Activate()

Return oMark

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MarkAll  ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para marcar/desmarcar todos os registros.           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function MarkAll(oBrowse,cTable)

cUpdate := ""

cUpdate := "UPDATE " +cTable +" SET OK = CASE OK WHEN 'T' THEN 'F' ELSE 'T' END"
TCSQLExec(cUpdate)

oBrowse:Refresh(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AddColumn ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criação das colunas.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddColumn(bData,cTitulo,nTamanho,nDecimal,cTipo,cPicture)

Local oColumn

oColumn := FWBrwColumn():New()
oColumn:SetData( bData )
oColumn:SetTitle(cTitulo)
oColumn:SetSize(nTamanho)
IF nDecimal != Nil
	oColumn:SetDecimal(nDecimal)
EndIF
oColumn:SetType(cTipo)
IF cPicture != Nil
	oColumn:SetPicture(cPicture)
EndIF

Return oColumn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fAllLog  ºAutor  ³ Vinícius Moreira   º Data ³ 07/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Auxilia na montagem do vetor do ExecAuto.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAllLog( aAliasRes )

Local cMsgLog := ""

If MsgYesNo( "Deseja visualizar todos os logs?", "Logs" )
	( aAliasRes )->( dbGoTop( ) )
	While ( aAliasRes )->( !Eof( ) )
		If !Empty( cMsgLog )
			cMsgLog += Replicate( "-", 20 ) + CRLF + CRLF 
		EndIf
		cMsgLog += "//** Filial : " + cFilDes + " **//" + CRLF + CRLF
		cMsgLog += ( aAliasRes )->MSGLOG
		( aAliasRes )->( dbSkip( ) )
	EndDo
	fShowErro( cMsgLog )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fShowErroºAutor  ³ Vinícius Moreira   º Data ³ 07/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe erro em tela.                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fShowErro( cMemo )

Local oDlg
Local cMemo
Local oFont 

DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

DEFINE MSDIALOG oDlg TITLE "Log" From 3,0 to 340,417 PIXEL

@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL 
oMemo:bRClicked := { | | AllwaysTrue( ) }
oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End( ) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fStep03  ºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta tela do quarto passo.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fStep03( oPanel, oTmpReg, cAliasRes)

Local cEmpDes := "01"

MsgRun("Selecionando registros...","Processando...",{|| cAliasRes := fGerTmpRes(oTmpReg)})

Processa({|oSelf| U_CON001PE( cAliasRes) }, "Processando registros..." ) 

//Inicio do browser de exibição dos registros
oBrowse:= FWBrowse( ):New( )
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasRes )
oBrowse:AddStatusColumns( { || If( ( cAliasRes )->SUCESSO == 1 , 'BR_VERDE', If( ( cAliasRes )->SUCESSO == 2, 'BR_VERMELHO', 'BR_AMARELO') ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasRes )->CONTRATO 	},"Contrato"			, Len( CN9->CN9_NUMERO )	, , "C") ,;
	AddColumn({|| ( cAliasRes )->CLIFOR 	},"ClienteFornecedor"	, Len( SA1->A1_NOME )		, , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"			, 150						, , "C")  ;
})
oBrowse:SetDoubleClick({|| fShowErro( ( cAliasRes )->MSGLOG ) })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGerTmpResºAutor  ³ Vinícius Moreira   º Data ³ 06/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta TMP de resultados.                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGerTmpRes(oTmpReg)

Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"CONTRATO"	, "C", TamSX3("CN9_NUMERO")[1]	, 0},;
						{"REVISA"	, "C", TamSX3("CN9_REVISA")[1]	, 0},;
						{"CLIFOR"	, "C", TamSX3("A2_NOME")[1]		, 0},;
						{"MSG"		, "C", 150						, 0},;
						{"SUCESSO"	, "N", 1						, 0},;
						{"MSGLOG"	, "M", 80						, 0}}

While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela temporária no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","CONTRATO+REVISA"))

//--Insere contratos a criar na filial de destino
cInsert := "INSERT INTO " +cAliasRes +" (CONTRATO,CLIFOR,SUCESSO,REVISA) "
cInsert += "SELECT REGS.CONTRATO, REGS.CLIFOR, 3, REGS.REVISA "
cInsert += "FROM " +oTmpReg:GetRealName() +" REGS "
cInsert += "WHERE REGS.OK = 'T'

If TCSQLExec(cInsert) < 0
	Conout(TCSQLError())
EndIf

Return cAliasRes

User Function CON001PE(cAliasReg)

Local cMsg		 	:= ""
Local cMsgLog 	 	:= ""
Local nSucesso	 	:= 3
Local oModel
Local aCN9Fields	:= {}
Local aCNAFields	:= {}
Local aCNBFields	:= {}
Local aCNNFields	:= {}
Local aCNFFields	:= {}
Local cAliasCN9 	:= ""
Local cAliasCNA 	:= ""
Local cAliasCNB 	:= ""
Local cAliasCNN 	:= ""
Local cAliasCNF 	:= ""
Local nCont 		:= 0
Local lShwMsg 		:= .T.
Local cEmpDes 		:= "01"
Local cCnpj 		:= ""
Local cCod 			:= ""
Local cLoj 			:= ""
Local cTpCli 		:= ""
Local cEmpBkp 		:= cEmpAnt 
Local cFilBkp 		:= cFilAnt
Local cProd 		:= ""
Local nItPlan 		:= 0
Local aAreaCN9 		:= {}
Local cMsg 			:= ""
Local nVlIni 		:= 0
Local nSaldo 		:= 0
Local nVlAtu 		:= 0

//#TB20190523 Thiago Berna
Local aErro			:= {}
Local nIt			:= 0
Local nItCNF		:= 0
Local cAliasITE		:= ''
Local cCNFAlias		:= ''
Local cEmpOri 		:= "02"

Private lMsErroAuto	:= .F.

RpcClearEnv()
RPcSetType(3)
RpcSetEnv(cEmpDes,cFilDes, , ,'GCT')

//--Reabre o alias na outra empresa
dbUseArea(.T.,"TOPCONN",cAliasReg,cAliasReg,.T.)

aCN9Fields := fGetFields( "CN9" )
aCNAFields := fGetFields( "CNA" )
aCNBFields := fGetFields( "CNB" )
aCNNFields := fGetFields( "CNN" )
aCNFFields := fGetFields( "CNF" )

BeginTran()

(cAliasReg)->(dbGoTop()) 
While (cAliasReg)->(!Eof())
	If lShwMsg
		IncProc( "Processando Contrato " + ( cAliasReg )->CONTRATO )
	EndIf
	
	cTpCli	:= ""
	cCnpj	:= ""	
	cMsg	:= ""
	cCod 	:= ""
	cLoj 	:= ""
	nSucesso:= 3	
	
	//--Checar se o contrato existe no destino
	aAreaCN9 := CN9->(GetArea())
	CN9->(dbSetOrder(1))
	If CN9->(dbSeek(xFilial("CN9")+(cAliasReg)->CONTRATO+(cAliasReg)->REVISA))
		nSucesso	:= 2	
		cMsg		:= "Contrato já existe na filial " + AllTrim( cEmpDes) + "/" + AllTrim( cFildes ) + "."
		cMsgLog		+= "Contrato " + (cAliasReg)->CONTRATO + CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF
	EndIf
	
	//--Checar produto no destino
	If !fChkPro(cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA,@cProd)
		nSucesso	:= 2	
		cMsg		:= "Produto nao existe na filial " + AllTrim( cEmpDes) + "/" + AllTrim( cFildes ) + "."
		cMsgLog		+= "Produto " + cProd + CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF 
	EndIf
	
	//--Checar a existencia do fornecedor/cliente
	If !fChkCNC(cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA, @cTpCli, @cCnpj)
		nSucesso	:= 2	
		cMsg	:= "Fornecedor nao existe na filial " + AllTrim( cEmpDes) + "/" + AllTrim( cFildes ) + "."
		cMsgLog	+= "Contrato " + (cAliasReg)->CONTRATO + " - Fornecedor " + ( cAliasReg )->CLIFOR + CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF
	EndIf	
	
	//--Checar Fornecedor/Cliente no destino
	If !fChkFC( cCnpj , cTpCli, cFilDes, cEmpDes, @cCod, @cLoj )
		nSucesso	:= 2
		If cTpCli == "F"
			cMsg	:= "Fornecedor nao existe na filial " + AllTrim( cEmpDes) + "/" + AllTrim( cFildes ) + "."
			cMsgLog	+= "Fornecedor " + cCnpj + " " + ( cAliasReg )->CLIFOR + CRLF
		ElseIf cTpCli == "C"
			cMsg	:= "Cliente nao existe na filial " + AllTrim( cEmpDes ) + "/" + AllTrim( cFilDes ) + "."
			cMsgLog	+=	"Cliente " + cCnpj + " " + ( cAliasReg )->CLIFOR + CRLF
		EndIf			
		cMsgLog 	+= "-->" + cMsg + CRLF 
	EndIf
	
	//--Tipos de Contrato
	cMsg := ""
	If !fChkVld("CN1",cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA, @cMsg)
		nSucesso	:= 2
		cMsgLog 	+= "Erro ao incluir a tabela de tipos de contrato no destino "+ CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF 
	EndIf	

	//--Tipos de Revisao
	cMsg := ""
	If !fChkVld("CN0",cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA, @cMsg)
		nSucesso	:= 2
		cMsgLog 	+= "Erro ao incluir a tabela de tipos de revisao no destino "+ CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF 
	EndIf


	//--Tipos de Indices
	cMsg := ""
	If !fChkVld("CN6",cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA, @cMsg)
		nSucesso	:= 2
		cMsgLog 	+= "Erro ao incluir a tabela de tipos de indices no destino "+ CRLF
		cMsgLog 	+= "-->" + cMsg + CRLF 
	EndIf
	
	
	//--Se tudo estiver OK, iniciar a replicacao
	RestArea(aAreaCN9)
	If Empty(cMsg)		
		fCarrAlias( cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA, @cAliasCN9, @cAliasCNA, @cAliasCNB, @cAliasCNN, @cAliasCNF )
		
		oModel  := FwLoadModel ("CNTA300")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()		

		For nCont := 1 To Len(aCN9Fields)		
			If aCN9Fields[nCont][01] == "CN9_SITUAC"
				oModel:SetValue("CN9MASTER",aCN9Fields[nCont][01],"02") //--Em Elaboracao			
			ElseIf aCN9Fields[nCont][01] == "CN9_CODOBJ"
				cMsg := CpoMemo(&((cAliasCN9)+"->"+aCN9Fields[nCont][01]))
				If !Empty(cMsg)
					oModel:SetValue("CN9MASTER","CN9_OBJCTO",cMsg)
				EndIf
			ElseIf aCN9Fields[nCont][01] == "CN9_CODCLA"
				cMsg := CpoMemo(&((cAliasCN9)+"->"+aCN9Fields[nCont][01]))
				If !Empty(cMsg)
					oModel:SetValue("CN9MASTER","CN9_ALTCLA",cMsg)
				EndIf
			ElseIf aCN9Fields[nCont][01] == "CN9_CODJUS"
				cMsg := CpoMemo(&((cAliasCN9)+"->"+aCN9Fields[nCont][01]))
				If !Empty(cMsg)
					oModel:SetValue("CN9MASTER","CN9_JUSTIF",cMsg)
				EndIf
			ElseIf AllTrim(aCN9Fields[nCont][01]) == "CN9_DTULST"
				oModel:SetValue("CN9MASTER",aCN9Fields[nCont][01],dDataBase)
			ElseIf AllTrim(aCN9Fields[nCont][01]) == "CN9_VLINI"
				nVlIni := &((cAliasCN9)+"->"+aCN9Fields[nCont][01])
			ElseIf AllTrim(aCN9Fields[nCont][01]) == "CN9_SALDO"
				nSaldo := &((cAliasCN9)+"->"+aCN9Fields[nCont][01])
			ElseIf AllTrim(aCN9Fields[nCont][01]) == "CN9_VLATU"			
				nVlAtu := &((cAliasCN9)+"->"+aCN9Fields[nCont][01])
			ElseIf aCN9Fields[nCont][02] == "D"
				oModel:SetValue("CN9MASTER",aCN9Fields[nCont][01],Stod(&((cAliasCN9)+"->"+aCN9Fields[nCont][01])))					
			Else
				oModel:SetValue("CN9MASTER",AllTrim(aCN9Fields[nCont][01]),&((cAliasCN9)+"->"+aCN9Fields[nCont][01]))
			EndIf
		Next nCont
		
		//Cliente/Fornecedor do Contrato
		If cTpCli == "F"
			oModel:SetValue( 'CNCDETAIL'    , 'CNC_CODIGO'  	, cCod  )
			oModel:SetValue( 'CNCDETAIL'    , 'CNC_LOJA'        , cLoj  )
		ElseIf cTpCli == "C"
			oModel:SetValue( 'CNCDETAIL'    , 'CNC_CLIENT'  	, cCod  )
			oModel:SetValue( 'CNCDETAIL'    , 'CNC_LOJACL'      , cLoj  )
		EndIf
		
		//--Planilhas do Contrato
		nItPlan := 0
		nIt		:= 0
		nItCNF  := 0
		
		(cAliasCNA)->(DbGoTop())
		While (cAliasCNA)->(!Eof())	

			nItPlan += 1			
			If nItPlan == 1
				oModel:GetModel('CNADETAIL'):SetNoInserLine(.F.)
				oModel:GetModel('CNADETAIL'):SetNoUpdateLine(.F.)
			EndIf
			If nItPlan > 1
				oModel:GetModel('CNADETAIL'):AddLine()
			EndIf
			For nCont := 1 To Len(aCNAFields)
				
				//#TB20190627 Thiago Berna - Para os tipos de planilha 001,002, 005 e 006 remarcar como 003 para incluir e posteriormente ajustar o campo
				If AllTrim(aCNAFields[nCont][01]) == "CNA_TIPPLA"
					If &((cAliasCNA)+"->"+aCNAFields[nCont][01]) $ '006|'
						oModel:SetValue("CNADETAIL",aCNAFields[nCont][01],'004')
					Else
						oModel:SetValue("CNADETAIL",aCNAFields[nCont][01],&((cAliasCNA)+"->"+aCNAFields[nCont][01]))
					EndIf
				ElseIf aCNAFields[nCont][02] == "D"
					oModel:SetValue("CNADETAIL",aCNAFields[nCont][01],Stod(&((cAliasCNA)+"->"+aCNAFields[nCont][01])))
				Else
					oModel:SetValue("CNADETAIL",aCNAFields[nCont][01],&((cAliasCNA)+"->"+aCNAFields[nCont][01]))
				EndIf
			Next nCont

			//#TB20190603 Thiago Berna - Ajuste para zerar os valores que serao calculados ao incluir a tabela CNB
			oModel:SetValue("CNADETAIL","CNA_SALDO",0)
			oModel:SetValue("CNADETAIL","CNA_VLTOT",0)
						
			//#TB20190530 Thiago Berna - Ajuste para incluir o item apos incluir a planilha
			cAliasITE := GetNextAlias()
			cQuery := "  SELECT " + CRLF 
			cQuery += "    * " + CRLF 
			cQuery += "   FROM CNB" + cEmpOri + "0 CNB " + CRLF 
			cQuery += "  WHERE CNB.CNB_FILIAL  = '" + (cAliasCNA)->(CNA_FILIAL) + "' " + CRLF 
			cQuery += "    AND CNB.CNB_CONTRA     = '" + (cAliasCNA)->(CNA_CONTRA) + "' " + CRLF
			cQuery += "    AND CNB.CNB_REVISA     = '" + (cAliasCNA)->(CNA_REVISA) + "' " + CRLF
			cQuery += "    AND CNB.CNB_NUMERO     = '" + (cAliasCNA)->(CNA_NUMERO) + "' " + CRLF
			cQuery += "    AND CNB.CNB_SLDMED     > 0 " + CRLF
			cQuery += "    AND CNB.D_E_L_E_T_ = ' ' " + CRLF
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasITE,.F.,.T.)
			
			//--Itens da Planilha do Contrato
			(cAliasITE)->(DbGoTop())
			nIt := 0
			While (cAliasITE)->(!Eof())		
				nIt += 1			
				If nIt == 1
					oModel:GetModel('CNBDETAIL'):SetNoInserLine(.F.)
					oModel:GetModel('CNBDETAIL'):SetNoUpdateLine(.F.)
				EndIf
				If nIt > 1
					oModel:GetModel('CNBDETAIL'):AddLine()
				EndIf
				For nCont := 1 To Len(aCNBFields)
					
					If AllTrim(aCNBFields[nCont][01]) == "CNB_REALI" 
					ElseIf AllTrim(aCNBFields[nCont][01]) == "CNB_VLTOTR" 
					
					ElseIf AllTrim(aCNBFields[nCont][01]) == "CNB_QUANT" //--Trazer apenas o saldo
						oModel:SetValue("CNBDETAIL",aCNBFields[nCont][01], (cAliasITE)->CNB_SLDMED )
					ElseIf aCNBFields[nCont][02] == "D"
						oModel:SetValue("CNBDETAIL",aCNBFields[nCont][01],Stod(&((cAliasITE)+"->"+aCNBFields[nCont][01])))
					Else
						oModel:SetValue("CNBDETAIL",aCNBFields[nCont][01],&((cAliasITE)+"->"+aCNBFields[nCont][01]))
					EndIf
				Next nCont
				(cAliasITE)->(dbSkip())
			EndDo
			DbCloseArea(cAliasITE)
			
			oModel:GetModel('CNADETAIL'):LoadValue("CNA_VLTOT",oModel:GetValue("CNBDETAIL","CNB_VLTOT"))
			oModel:GetModel('CNADETAIL'):LoadValue("CNA_SALDO",oModel:GetValue("CNBDETAIL","CNB_VLTOT"))
		
			//#TB20190603 Thiago Berna - Ajuste para incluir o cronograma financeiro
			cCNFAlias := GetNextAlias()
			cQuery := "  SELECT " + CRLF 
			cQuery += "    * " + CRLF 
			cQuery += "   FROM CNF" + cEmpOri + "0 CNF " + CRLF 
			cQuery += "  WHERE CNF.CNF_FILIAL  = '" + (cAliasCNA)->(CNA_FILIAL) + "' " + CRLF 
			cQuery += "    AND CNF.CNF_CONTRA  = '" + (cAliasCNA)->(CNA_CONTRA) + "' " + CRLF
			cQuery += "    AND CNF.CNF_REVISA     = '" + (cAliasCNA)->(CNA_REVISA) + "' " + CRLF
			cQuery += "    AND CNF.CNF_NUMERO     = '" + (cAliasCNA)->(CNA_CRONOG) + "' " + CRLF
			cQuery += "    AND CNF.CNF_SALDO   > 0 "+ CRLF
			cQuery += "    AND CNF.D_E_L_E_T_ = ' ' " + CRLF
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cCNFAlias,.F.,.T.)
			
			//--Cronograma Financeiro
			nItCNF := 0
			(cCNFAlias)->(DbGoTop())
			While (cCNFAlias)->(!Eof())			
				nItCNF += 1
				If nItCNF == 1
					oModel:GetModel('CNFDETAIL'):SetNoInserLine(.F.)
					oModel:GetModel('CNFDETAIL'):SetNoUpdateLine(.F.)
					//oModel:GetModel('CNFDETAIL'):GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
				EndIf
				If nItCNF > 1
					oModel:GetModel('CNFDETAIL'):AddLine()
				EndIf
				For nCont := 1 To Len(aCNFFields)
					
					
						If aCNFFields[nCont][02] == "D"
							oModel:SetValue("CNFDETAIL",aCNFFields[nCont][01],Stod(&((cCNFAlias)+"->"+aCNFFields[nCont][01])))
						Else
							oModel:SetValue("CNFDETAIL",aCNFFields[nCont][01],&((cCNFAlias)+"->"+aCNFFields[nCont][01]))
						EndIf

					
				Next nCont
				(cCNFAlias)->(dbSkip())
				
			EndDo

			(cAliasCNA)->(dbSkip())
		EndDo			

		//--Permissoes dos usuarios no contrato
		nItPlan := 0
		(cAliasCNN)->(DbGoTop())
		While (cAliasCNN)->(!Eof())
			nItPlan += 1
			If nItPlan == 1
				oModel:GetModel('CNNDETAIL'):SetNoInserLine(.F.)
				oModel:GetModel('CNNDETAIL'):SetNoUpdateLine(.F.)
			EndIf
			If nItPlan > 1
				oModel:GetModel('CNNDETAIL'):AddLine()
			EndIf
			For nCont := 1 To Len(aCNNFields)
				oModel:SetValue("CNNDETAIL",aCNNFields[nCont][01],&((cAliasCNN)+"->"+aCNNFields[nCont][01]))
			Next nCont
			(cAliasCNN)->(dbSkip())
		EndDo
		
		If oModel:VldData()
			oModel:CommitData()
			nSucesso	:= 1
			cMsg		:= "Gravado com sucesso."
			//--Se tudo der ok, armazena no aContOK para encerrar na empresa origem
			Aadd(aContOK, { cFilOri, (cAliasReg)->CONTRATO, (cAliasReg)->REVISA})
			
			//#TB20190627 Thiago Berna - Para os tipos de planilha 001,002, 005 e 006 remarcar como 003 para incluir e posteriormente ajustar o campo
			(cAliasCNA)->(DbGoTop())
			While (cAliasCNA)->(!EOF())

				If (cAliasCNA)->(CNA_TIPPLA) $ '006|'
					DbSelectArea('CNA')
					If CNA->(DbSeek(cFilDes + (cAliasCNA)->(CNA_CONTRA) + (cAliasCNA)->(CNA_REVISA) + (cAliasCNA)->(CNA_NUMERO)))
						RecLock('CNA',.F.)
							CNA->CNA_TIPPLA :=  (cAliasCNA)->(CNA_TIPPLA)
						CNA->(MsUnlock())
						
					EndIf
				EndIf

				(cAliasCNA)->(!DbSkip())
			EndDo

			//--Gravar o Saldo, porque no MVC existem uns valids que travam se feito antes da gravacao
			RecLock("CN9",.F.)
			CN9->CN9_VLINI := nSaldo//nVlIni 
			CN9->CN9_SALDO := nSaldo
			CN9->CN9_VLATU := nSaldo//nVlAtu
			CN9->(MsUnLock())

		Else
			nSucesso 	:= 2
		    
			//#TB20190523 Thiago Berna
			//cMsg := VarInfo("",oModel:GetErrorMessage())
			aErro := oModel:GetErrorMessage()
			If Len(aErro) > 0
				cMsg	+= IIF(Empty(cMsg),'',ENTER) + "Mensagem do Erro: " + ' [ ' + AllToChar( aErro[6] ) + ' ]' + ENTER
				//cMsgLog += "ID do Formulário de Origem:" + ' [ ' + AllToChar( aErro[1] ) + ' ]' + ENTER
				//cMsgLog += "ID do Campo de Origem: " + ' [ ' + AllToChar( aErro[2] ) + ' ]' + ENTER
				//cMsgLog += "ID do Formulário de Erro: " + ' [ ' + AllToChar( aErro[3] ) + ' ]' + ENTER
				//cMsgLog += "ID do Campo de Erro: " + ' [ ' + AllToChar( aErro[4] ) + ' ]' + ENTER
				//cMsgLog += "ID do Erro: " + ' [ ' + AllToChar( aErro[5] ) + ']' + ENTER
				cMsgLog += IIF(Empty(cMsgLog),'',ENTER) + "Mensagem do Erro: " + ' [ ' + AllToChar( aErro[6] ) + ' ]' + ENTER
				//cMsgLog += "Mensagem da Solução: " + ' [ ' + AllToChar( aErro[7] ) + ' ]' + ENTER
				//cMsgLog += "Valor Atribuído: " + ' [ ' + AllToChar( aErro[8] ) + ' ]' + ENTER
				//cMsgLog += "Valor Anterior: " + ' [ ' + AllToChar( aErro[9] ) + ' ]'
			EndIf
			
		EndIf       
		     
		oModel:DeActivate()
		oModel:Destroy()
		 
		oModel := NIL	
		
	EndIf
	
	//#TB20190523
	/*If Empty( cMsgLog )
		cMsgLog := cMsg
	EndIf*/

	RecLock( cAliasReg, .F. )
	( cAliasReg )->SUCESSO	:= nSucesso
	( cAliasReg )->MSG		:= cMsg
	( cAliasReg )->MSGLOG 	:= cMsgLog
	( cAliasReg )->( MsUnlock( ) )	

	( cAliasReg )->( dbSkip( ) )
EndDo

EndTran()

//--Aqui ja pode restaurar e gravar o encerramento do contrato
RpcClearEnv()
RPcSetType(3)
RpcSetEnv(cEmpBkp,cFilBkp, , ,'GCT')

//--Reabre o alias na outra empresa
dbUseArea(.T.,"TOPCONN",cAliasReg,cAliasReg,.T.)

//--Encerrar os contratos na filial de origem apos replicar
CN9->(dbSetOrder(1))
For nCont := 1 To Len(aContOK)
	If CN9->(dbSeek(aContOK[nCont][01]+aContOK[nCont][02]+aContOK[nCont][03]))
		RecLock("CN9", .F.)
		CN9->CN9_SITUAC := "08" //--Finalizado
		CN9->CN9_DTENCE := dDataBase
		CN9->CN9_DTULST := dDataBase
		CN9->(MsUnLock())
	EndIf
Next nCont

Return


Static Function CpoMemo(cCod)

Local cMsg 		:= ""
Local cQuery 	:= ""
Local cAliasSYP	:= ""
Local cEmpOri 	:= "02"
Local nPos 		:= 0
Local cLine 	:= ""
Local nPos 		:= 0
Local nPos2 	:= 0
Local nTam 		:= TamSX3("YP_TEXTO")[1]  

cAliasSYP	:= GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM SYP" + cEmpOri + "0 SYP " + CRLF 
cQuery += "  WHERE SYP.YP_FILIAL  = '  ' " + CRLF 
cQuery += "    AND SYP.YP_CHAVE     = '" + cCod + "' " + CRLF
cQuery += "    AND SYP.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "    ORDER BY YP_SEQ " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasSYP,.F.,.T.)

While (cAliasSYP)->(!Eof())
	nPos := At("\13\10",Subs((cAliasSYP)->YP_TEXTO,1,nTam+6))
	If ( nPos == 0 )
		cLine := RTrim(Subs( (cAliasSYP)->YP_TEXTO ,1,nTam))
		If ( nPos2 := At("\14\10", cLine) ) > 0
			cMsg += StrTran( cLine, "\14\10", Space(6) )
		Else
			cMsg += cLine
		EndIf
	Else
		cMsg += Subs((cAliasSYP)->YP_TEXTO,1,nPos-1) + CRLF
	EndIf
	(cAliasSYP)->(DbSkip())
EndDo
(cAliasSYP)->(dbCloseArea())
DbSelectArea("SYP")

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fChkFC   ºAutor  ³ Rodolfo Rosseto    º Data ³ 06/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checa se o cliente/fornecedor existe na filial destino.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkFC( cCnpj, cTpCli, cFilDes, cEmpDes, cCod, cLoj )

Local cQuery	:= ""
Local lRet		:= .F.
Local cTabela	:= ""

Default cTpCli := ""

If cTpCli == "F"
	cTabela	:= "%SA2"+cEmpDes+"0%"
ElseIf cTpCli == "C"
	cTabela	:= "%SA1"+cEmpDes+"0%"
EndIf

If cTpCli == "F"
	BeginSQL Alias "REGEXIST"
		SELECT COUNT(A2_COD) AS REGS,
		MAX(A2_COD) AS COD,
		MAX(A2_LOJA) AS LOJA
		FROM %Exp:cTabela%
		WHERE %NotDel% AND
			A2_FILIAL = %Exp:xFilial("SA2",cFilDes)% AND
			A2_CGC = %Exp:cCnpj%
	EndSQL
ElseIf cTpCli == "C"
	BeginSQL Alias "REGEXIST"
		SELECT COUNT(A1_COD) AS REGS
		MAX(A1_COD) AS COD,
		MAX(A1_LOJA) AS LOJA
		FROM %Exp:cTabela%
		WHERE %NotDel% AND
			A1_FILIAL = %Exp:xFilial("SA1",cFilDes)% AND
			A1_CGC = %Exp:cCnpj%
	EndSQL
EndIf

lRet := REGEXIST->REGS > 0
If lRet
	cCod := REGEXIST->COD
	cLoj := REGEXIST->LOJA
EndIf
REGEXIST->(dbCloseArea())

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fChkVld  ºAutor  ³ Rodolfo Rosseto    º Data ³ 08/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica ausencia de cadastros e inclui.				      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkVld(cTabela, cFilOri, cContra, cRevisa, cMsg )

Local cQuery		:= ""
Local cTabCN9		:= "%CN9"+cEmpOri+"0%"
Local cTabCN0 		:= "CN0"
Local cTabCN6 		:= "CN6"
Local cTpRev 		:= ""
Local cTpCon 		:= ""
Local oModel
Local cAliasCN1 	:= ""
Local aCN1Fields 	:= {}
Local cAliasCN0 	:= ""
Local cAliasCN6 	:= ""
Local aCN0Fields 	:= {}
Local aCN6Fields 	:= {}
Local nCont 		:= 0
Local lRet 			:= .T.

//--Tipos de Contrato
If cTabela == "CN1"
	BeginSQL Alias "REGEXIST"
		SELECT 	CN9.CN9_TPCTO AS CN9TPCTO,
				CN9.CN9_ESPCTR AS CN9ESPCTR
		FROM %Exp:cTabCN9% CN9
		
		WHERE CN9.%NotDel%
			AND CN9.CN9_FILIAL = %Exp:xFilial("CN9",cFilOri)%
			AND CN9.CN9_NUMERO = %Exp:cContra%
			AND CN9.CN9_REVISA = %Exp:cRevisa%
	EndSQL

	If !Empty(REGEXIST->CN9TPCTO)
		CN1->(dbSetOrder(1))
		If !CN1->(dbSeek(xFilial("CN1")+REGEXIST->CN9TPCTO+REGEXIST->CN9ESPCTR))
			aCN1Fields := fGetFields( "CN1" )
			fLoadCN1(REGEXIST->CN9TPCTO,REGEXIST->CN9ESPCTR,@cAliasCN1)
			
			oModel  := FwLoadModel ("CNTA021")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()		

			For nCont := 1 To Len(aCN1Fields)
				If aCN1Fields[nCont][01] <> "CN1_INTEGR"				
					If aCN1Fields[nCont][02] == "D"
						oModel:SetValue("CN1MASTER",aCN1Fields[nCont][01],Stod(&((cAliasCN1)+"->"+aCN1Fields[nCont][01])))
					Else
						oModel:SetValue("CN1MASTER",aCN1Fields[nCont][01],&((cAliasCN1)+"->"+aCN1Fields[nCont][01]))
					EndIf
				EndIf
			Next nCont

			If oModel:VldData()
				oModel:CommitData()
			Else
				lRet := .F.
				cMsg := VarInfo("",oModel:GetErrorMessage())
			EndIf
				 
			oModel:DeActivate()
			oModel:Destroy()
			 
			oModel := NIL
		
		EndIf
	EndIf

	REGEXIST->(dbCloseArea())
ElseIf cTabela == "CN0" //--Tipos de Revisao

	BeginSQL Alias "REGEXIST"
		SELECT 	CN9.CN9_TIPREV AS CN9TIPREV
		FROM %Exp:cTabCN9% CN9
		
		WHERE CN9.%NotDel%
			AND CN9.CN9_FILIAL = %Exp:xFilial("CN9",cFilOri)%
			AND CN9.CN9_NUMERO = %Exp:cContra%
			AND CN9.CN9_REVISA = %Exp:cRevisa%
	EndSQL

	If !Empty(REGEXIST->CN9TIPREV)
		CN0->(dbSetOrder(1))
		If !CN0->(dbSeek(xFilial("CN0")+REGEXIST->CN9TIPREV))
			aCN0Fields := fGetFields( "CN0" )
			fLoadCN0(REGEXIST->CN9TIPREV,@cAliasCN0)

			RecLock("CN0",.T.)
			For nCont := 1 To Len(aCN0Fields)
				If aCN0Fields[nCont][02] == "D"
					&(cTabCN0+"->("+aCN0Fields[nCont][01]+")") := Stod(&((cAliasCN0)+"->"+aCN0Fields[nCont][01]))
				Else
					&(cTabCN0+"->("+aCN0Fields[nCont][01]+")") := &((cAliasCN0)+"->"+aCN0Fields[nCont][01])
				EndIf
			Next nCont
			CN0->(MsUnLock())
		
		EndIf
	EndIf
	REGEXIST->(dbCloseArea())
ElseIf cTabela == "CN6" //--Tipos de Indices

	BeginSQL Alias "REGEXIST"
		SELECT 	CN9.CN9_INDICE AS CN9INDICE
		FROM %Exp:cTabCN9% CN9
		
		WHERE CN9.%NotDel%
			AND CN9.CN9_FILIAL = %Exp:xFilial("CN9",cFilOri)%
			AND CN9.CN9_NUMERO = %Exp:cContra%
			AND CN9.CN9_REVISA = %Exp:cRevisa%
	EndSQL

	If !Empty(REGEXIST->CN9INDICE)
		CN6->(dbSetOrder(1))
		If !CN6->(dbSeek(xFilial("CN6")+REGEXIST->CN9INDICE))
			aCN6Fields := fGetFields( "CN6" )
			fLoadCN6(REGEXIST->CN9INDICE,@cAliasCN6,cFilOri)

			RecLock("CN6",.T.)
			For nCont := 1 To Len(aCN6Fields)
				If aCN6Fields[nCont][02] == "D"
					&(cTabCN6+"->("+aCN6Fields[nCont][01]+")") := Stod(&((cAliasCN6)+"->"+aCN6Fields[nCont][01]))
				Else
					&(cTabCN6+"->("+aCN6Fields[nCont][01]+")") := &((cAliasCN6)+"->"+aCN6Fields[nCont][01])
				EndIf
			Next nCont
			CN6->CN6_FILIAL := cFilDes
			CN6->(MsUnLock())
		
		EndIf
	EndIf
	REGEXIST->(dbCloseArea())
EndIf

Return lRet


Static Function fLoadCN1(cTpCto,cEspCtr,cAliasCN1)

Local cQuery := ""
Local cEmpOri := "02"

cAliasCN1 := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CN1" + cEmpOri + "0 CN1 " + CRLF 
cQuery += "  WHERE CN1.CN1_FILIAL  = '" + xFilial("CN1") + "' " + CRLF 
cQuery += "    AND CN1.CN1_CODIGO     = '" + cTpCto + "' " + CRLF
cQuery += "    AND CN1.CN1_ESPCTR     = '" + cEspCtr + "' " + CRLF
cQuery += "    AND CN1.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCN1,.F.,.T.)


Return Nil


Static Function fLoadCN0(cTpRev,cAliasCN0)

Local cQuery := ""
Local cEmpOri := "02"

cAliasCN0 := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CN0" + cEmpOri + "0 CN0 " + CRLF 
cQuery += "  WHERE CN0.CN0_FILIAL  = '" + xFilial("CN0") + "' " + CRLF 
cQuery += "    AND CN0.CN0_CODIGO     = '" + cTpRev + "' " + CRLF
cQuery += "    AND CN0.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCN0,.F.,.T.)

Return Nil


Static Function fLoadCN6(cTpInd,cAliasCN6,cFilOri)

Local cQuery := ""
Local cEmpDes := "02"

cAliasCN6 := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CN6" + cEmpOri + "0 CN6 " + CRLF 
cQuery += "  WHERE CN6.CN6_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CN6.CN6_CODIGO     = '" + cTpInd + "' " + CRLF
cQuery += "    AND CN6.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCN6,.F.,.T.)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fChkFC   ºAutor  ³ Rodolfo Rosseto    º Data ³ 06/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checa se o cliente/fornecedor existe na filial destino.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkCNC( cFilOri, cContr, cRevisa, cTpCli, cCnpj)

Local cQuery	:= ""
Local lRet		:= .F.
Local cEmpOri 	:= "02"
Local cEmpDes 	:= "01"
Local cTabela	:= "%CNC"+cEmpOri+"0%"
Local cTabPsq 	:= ""
Local cCod 		:= ""
Local cLoja 	:= ""

BeginSQL Alias "REGEXIST"
	SELECT COUNT(CNC_NUMERO) AS REGS,
	MAX(CNC_CODIGO) AS CODIGO,
	MAX(CNC_LOJA) AS LOJA,
	MAX(CNC_CLIENT) AS CLIENT,
	MAX(CNC_LOJACL) AS LOJACL
	FROM %Exp:cTabela%
	WHERE %NotDel%
		AND CNC_FILIAL = %Exp:xFilial("CNC",cFilOri)%
		AND CNC_NUMERO = %Exp:cContr%
		AND CNC_REVISA = %Exp:cRevisa%
EndSQL


lRet := REGEXIST->REGS > 0
If lRet
	If !Empty(REGEXIST->CODIGO)
		cTpCli	:= "F"
		cCod 	:= REGEXIST->CODIGO 
		cLoja 	:= REGEXIST->LOJA
	ElseIf !Empty(REGEXIST->CLIENT)
		cTpCli	:= "C"
		cCod 	:= REGEXIST->CLIENT
		cLoja 	:= REGEXIST->LOJACL
	EndIf
EndIf
REGEXIST->(dbCloseArea())

If cTpCli == "F"
	cTabPsq	:= "%SA2"+cEmpDes+"0%"
ElseIf cTpCli == "C"
	cTabPsq	:= "%SA1"+cEmpDes+"0%"
EndIf

If cTpCli == "F"
	BeginSQL Alias "REGEXIST1"
		SELECT COUNT(A2_COD) AS REGS,
		MAX(A2_CGC) AS CNPJ
		FROM %Exp:cTabPsq%
		WHERE %NotDel%
			AND A2_FILIAL = %Exp:xFilial("SA2",cFilOri)%
			AND A2_COD = %Exp:cCod%
			AND A2_LOJA = %Exp:cLoja%
	EndSQL	
ElseIf cTpCli == "C"
	BeginSQL Alias "REGEXIST1"
		SELECT COUNT(A1_COD) AS REGS,
		MAX(A1_CGC) AS CNPJ
		FROM %Exp:cTabPsq%
		WHERE %NotDel%
			AND A1_FILIAL = %Exp:xFilial("SA1",cFilOri)%
			AND A1_COD = %Exp:cCod%
			AND A1_LOJA = %Exp:cLoja%
	EndSQL	
EndIf

lRet := REGEXIST1->REGS > 0
If lRet
	cCnpj := REGEXIST1->CNPJ
EndIf
REGEXIST1->(dbCloseArea())

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fChkPro   ºAutor  ³ Rodolfo Rosseto    º Data ³ 06/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Checa se o cliente/fornecedor existe na filial destino.    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkPro( cFilOri, cContr, cRevisa,cProd)

Local cQuery	:= ""
Local lRet		:= .T.
Local cEmpOri 	:= "02"
Local cTabCNB	:= "%CNB"+cEmpOri+"0%"
Local aAreaSB1 := SB1->(GetArea())

BeginSQL Alias "REGEXIST"
	SELECT CNB_PRODUT	
	FROM %Exp:cTabCNB%
	WHERE %NotDel%
		AND CNB_FILIAL = %Exp:xFilial("CNB",cFilOri)%
		AND CNB_CONTRA = %Exp:cContr%
		AND CNB_REVISA = %Exp:cRevisa%
EndSQL

SB1->(dbSetOrder(1))
While REGEXIST->(!Eof())
	If !SB1->(dbSeek(xFilial("SB1")+REGEXIST->CNB_PRODUT))
		cProd := REGEXIST->CNB_PRODUT 
		lRet := .F.
	EndIf
	REGEXIST->(dbSkip())
EndDo
REGEXIST->(dbCloseArea())
RestArea(aAreaSB1)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarrAliasºAutor  ³ Vinícius Moreira   º Data ³ 28/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega os alias das tabelas envolvidas buscando informa-  º±±
±±º          ³ ção nas outras empresas.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCarrAlias( cFilOri, cContr, cRevis, cAliasCN9, cAliasCNA, cAliasCNB, cAliasCNN, cAliasCNF, cAliasCND, cAliasCNE )

Local cQuery := ""
Local cEmpOri := "02"

cAliasCN9 := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CN9" + cEmpOri + "0 CN9 " + CRLF 
cQuery += "  WHERE CN9.CN9_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CN9.CN9_NUMERO     = '" + cContr + "' " + CRLF
cQuery += "    AND CN9.CN9_REVISA     = '" + cRevis + "' " + CRLF
cQuery += "    AND CN9.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCN9,.F.,.T.)

cAliasCNA := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CNA" + cEmpOri + "0 CNA " + CRLF 
cQuery += "  WHERE CNA.CNA_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CNA.CNA_CONTRA     = '" + cContr + "' " + CRLF
cQuery += "    AND CNA.CNA_REVISA     = '" + cRevis + "' " + CRLF
//#TB20190627 Thiago Berna - Ajuste para considerar somente os que tenham saldo maior que 0
cQuery += "    AND CNA.CNA_SALDO      > 0  " + CRLF
cQuery += "    AND CNA.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCNA,.F.,.T.)

cAliasCNB := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CNB" + cEmpOri + "0 CNB " + CRLF 
cQuery += "  WHERE CNB.CNB_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CNB.CNB_CONTRA     = '" + cContr + "' " + CRLF
cQuery += "    AND CNB.CNB_REVISA     = '" + cRevis + "' " + CRLF
cQuery += "    AND CNB.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCNB,.F.,.T.)

cAliasCNN := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CNN" + cEmpOri + "0 CNN " + CRLF 
cQuery += "  WHERE CNN.CNN_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CNN.CNN_CONTRA     = '" + cContr + "' " + CRLF
cQuery += "    AND CNN.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCNN,.F.,.T.)

cAliasCNF := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CNF" + cEmpOri + "0 CNF " + CRLF 
cQuery += "  WHERE CNF.CNF_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CNF.CNF_CONTRA  = '" + cContr + "' " + CRLF

//#TB20190603 Thiago Berna - Ajuste para inclusao da tabela CNF
cQuery += "    AND CNF.CNF_REVISA     = '" + cRevis + "' " + CRLF
cQuery += "    AND CNF.CNF_SALDO   > 0 "+ CRLF

cQuery += "    AND CNF.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCNF,.F.,.T.)

cAliasCND := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CND" + cEmpOri + "0 CND " + CRLF 
cQuery += "  WHERE CND.CND_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CND.CND_CONTRA     = '" + cContr + "' " + CRLF
cQuery += "    AND CND.CND_REVISA     = '" + cRevis + "' " + CRLF
cQuery += "    AND CND.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCND,.F.,.T.)

cAliasCNE := GetNextAlias()
cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CNE" + cEmpOri + "0 CNE " + CRLF 
cQuery += "  WHERE CNE.CNE_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CNE.CNE_CONTRA     = '" + cContr + "' " + CRLF
cQuery += "    AND CNE.CNE_REVISA     = '" + cRevis + "' " + CRLF
cQuery += "    AND CNE.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasCNE,.F.,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetFieldsºAutor  ³ Vinícius Moreira   º Data ³ 29/07/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca campos em uso para o alias.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetFields( cAliasAtu, cNotShow )

Local aRet 			:= { }
Local cCampo		:= ""
Default cNotShow	:= ""

dbSelectArea( "SX3" )
SX3->( dbSetOrder( 1 ) )//X3_ARQUIVO
If SX3->( dbSeek( cAliasAtu ) )
	While SX3->( !Eof( ) ) .And. SX3->X3_ARQUIVO == cAliasAtu
		cCampo := AllTrim( SX3->X3_CAMPO ) + "|"
		If !cCampo $ cNotShow 
			If X3Uso( SX3->X3_USADO ) .And. (SX3->X3_CONTEXT != "V" .And. SX3->X3_TIPO != "M")
				AAdd( aRet, { SX3->X3_CAMPO, SX3->X3_TIPO, Nil } )
			EndIf
		EndIf
		SX3->( dbSkip( ) )
	EndDo
EndIf

Return aRet