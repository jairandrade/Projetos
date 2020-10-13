#Include "Protheus.ch"  
#Include "FwCommand.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "TBICONN.CH"
#Include "TOTVS.ch"

User Function FIS001()
Local oBrw	:= FWmBrowse():New()

oBrw:SetDescription("UFXUF")
oBrw:SetAlias( 'CFC')
aRotina := MenuDef()

ADD OPTION aRotina TITLE "Replicar" ACTION 'U_Replic' OPERATION 9 ACCESS 0

oBrw:Activate()

Return Nil

Static Function MenuDef()

Return FWLoadMenuDef( 'FISA080' )

User Function Replic()

Local oWizard 		:= FWWizardControl( ):New( )
Local cQryCFC		:= ""
Local oStep
Local oBrowUF
Local oBrowFil
Local oTmpUF
Local oTmpFil
Local cAliasRes 	:= ""
Local cEmpBkp		:= cEmpAnt
Local cFilBkp		:= cFilAnt
Local aArea			:= GetArea( )

Private cUfODe	:= Space( Len( CFC->CFC_UFORIG ) )
Private cUfOAte	:= Space( Len( CFC->CFC_UFORIG ) )
Private cUfDDe	:= Space( Len( CFC->CFC_UFDEST ) )
Private cUfDAte	:= Space( Len( CFC->CFC_UFDEST ) )
Private cPrdDe	:= Space( Len( CFC->CFC_CODPRD ) )
Private cPrdAte	:= Space( Len( CFC->CFC_CODPRD ) )
Private cFilDe	:= Space( Len( ADK->ADK_XFILI ) )
Private cNegDe	:= Space( Len( ADK->ADK_XNEGOC ) )
Private cSegDe	:= Space( Len( ADK->ADK_XSEGUI ) )

Private cAliasCFC := GetNextAlias()

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Origem" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs(@cQryCFC) } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "UFXUF" )
oStep:SetConstruction( { |oPanel| oTmpUF := fStep02(oPanel,oBrowUF := FWBrowse():New(),cQryCFC) })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Filiais" )
oStep:SetConstruction( { |oPanel| oTmpFil := fStep03( oPanel, oBrowFil := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "4" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| fStep04( oPanel, oTmpUF, oTmpFil, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( cAliasRes ), .T. } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida!"), .F.} )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oWizard:Activate( )
oWizard:Destroy( )

If oTmpUF != Nil
	oTmpUF:Delete( )
EndIf

If oTmpFil != Nil
	oTmpFil:Delete( )
EndIf

If Select( cAliasCFC ) > 0
	( cAliasCFC )->( dbCloseArea( ) )
EndIf

If !Empty(cAliasRes)
	(cAliasRes)->(dbCloseArea())
	TCDelFile(cAliasRes)
	TCRefresh(cAliasRes)
EndIf

cEmpAnt := cEmpBkp
cFilAnt := cFilBkp
RestArea( aArea )

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fStep01  บAutor  ณ Rodolfo Rosseto    บ Data ณ 26/02/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela do primeiro passo.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fStep01( oPanel1, lFacilita )

Local nLinha 		:= 10
Local aGrupos		:= Separa( AllTrim( Posicione( "SX3", 2, PadR( "ADK_XGNEG", Len( SX3->X3_CAMPO ), " " ), "X3_CBOX" ) ), ":" )
Local cGrpNeg		:= fGetGrpNeg( )
Local oPanel 

Default lFacilita	:= .F.

oPanel := TScrollBox():New(oPanel1,01,01, oPanel1:nHeight-10, oPanel1:nWidth-10)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT


TGet():New(nLinha    ,20, bSetGet(cEmpAnt),oPanel, 10, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Empresa ',1,oPanel:oFont)
TGet():New(nLinha+7.5,40, bSetGet(FWEmpName(cEmpAnt)),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFilAnt),oPanel, (FWSizeFilial()*5), 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Filial',1,oPanel:oFont)
TGet():New(nLinha+7.5,30+((FWSizeFilial()*5)), bSetGet(FWFilialName()),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

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
	nLinha += 40
	TGet():New(nLinha    ,20, bSetGet(cUfODe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12",cUfODe,,,,,,,'UF Origen De',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cUfOAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12",cUfOAte,,,,,,,'UF Origem Ate',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cUfDDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12",cUfDDe,,,,,,,'UF Destino De',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cUfDAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12",cUfDAte,,,,,,,'UF Destino Ate',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cPrdDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",cPrdDe,,,,,,,'Produto De',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cPrdAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",cPrdAte,,,,,,,'Produto Ate',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cFilDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADK2",cFilDe,,,,,,,'Filial',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cNegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZA",cNegDe,,,,,,,'Negocio',1,oPanel:oFont)
	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cSegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZB",cSegDe,,,,,,,'Segmento',1,oPanel:oFont)
EndIf

Return 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGetRegs บAutor  ณ Rodolfo Rosseto    บ Data ณ 26/02/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca registros que serใo processados.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGetRegs(cQuery)

Local lRet	:= .F.

cQuery := " SELECT 'F' MARCA, CFC_UFORIG UFORIG, CFC_UFDEST UFDEST, CFC_CODPRD CODPRO, CFC_DESCR1 AS DESCRICAO "
cQuery += " FROM " + RetSQLName( "CFC" ) + " CFC "
cQuery += " WHERE CFC.CFC_FILIAL  = '" + xFilial( "CFC" ) + "' "
cQuery += " AND CFC.CFC_UFORIG BETWEEN '" + cUfODe + "' AND '" + cUfOAte + "' "
cQuery += " AND CFC.CFC_UFDEST BETWEEN '" + cUfDDe + "' AND '" + cUfDAte + "' "
cQuery += " AND CFC.CFC_CODPRD BETWEEN '" + cPrdDe + "' AND '" + cPrdAte + "' "
cQuery += " AND CFC.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCFC)

If !(lRet := (cAliasCFC)->(!Eof()))
	Alert("Nใo foram encontrados registros para processamento.")
EndIf

(cAliasCFC)->(dbCloseArea())

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGetGrpNegบAutor  ณ Vinํcius Moreira   บ Data ณ 29/08/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca grupo da empresa atual.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fStep02  บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela do segundo passo.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fStep02(oPanel,oBrowse,cQryCFC)

Local oMark 	:= FWTemporaryTable( ):New( )
Local cAliasAux	:= ""
Local cTabTemp	:= ""
Local cInsert	:= ""
Local aStruct 	:= {{"OK","L",1,0},;
					{"UFORIG","C",TamSX3("CFC_UFORIG")[1],0},;
					{"UFDEST","C",TamSX3("CFC_UFDEST")[1],0},;
					{"CODPRO","C",TamSX3("CFC_CODPRD")[1],0},;
					{"DESCRI","C",TamSX3("CFC_DESCR1")[1],0}}


//-- Inicio da montagem da tabela temporaria
oMark:SetFields(aStruct)
//-- Definindo indice
oMark:AddIndex("01",{"UFORIG"})
oMark:Create()

cTabTemp := oMark:GetRealName()
//-- Copia dados da CFC para tabela temporaria, a ser utilizada na mark
cInsert := "INSERT INTO " +cTabTemp +" (OK,UFORIG,UFDEST,CODPRO,DESCRI)"
cInsert += cQryCFC
TCSQLExec(cInsert)

//-- Obtem alias e nome fisico
cAliasAux := oMark:GetAlias()

//Final da montagem da tabela temporaria
//Inicio do browser de exibi็ใo dos registros
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable(.T.)
oBrowse:SetAlias(cAliasAux)
oBrowse:AddMarkColumns( ;
	{|| If( (cAliasAux)->OK , "LBOK", "LBNO" ) },;
	{||  (cAliasAux)->OK :=  ! (cAliasAux)->OK } ,;
	{|| MarkAll( oBrowse, cTabTemp ) } )


oBrowse:SetColumns({;
	AddColumn({ || ( cAliasAux )->UFORIG 	},"UF Origem"		, TamSX3("CFC_UFORIG")[1], , "C") ,;
	AddColumn({ || ( cAliasAux )->UFDEST	},"UF Destino"		, TamSX3("CFC_UFDEST")[1], , "C") ,;
	AddColumn({ || ( cAliasAux )->CODPRO	},"Cod Prd"			, TamSX3("CFC_CODPRD")[1], , "C") ,;
	AddColumn({ || ( cAliasAux )->DESCRI	},"Desc Prd"		, TamSX3("CFC_DESCR1")[1], , "C")  ;
})

oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:Activate()

Return oMark

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fStep03  บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela do terceiro passo.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fStep03( oPanel, oBrowse )

Local oMark 	:= FWTemporaryTable( ):New( )
Local cAliasAux	:= ""

//--Inicio da montagem da tabela temporaria
oMark:SetFields({ ;
		{"OK"		, "L", 1				, 0},;
		{"EMPRESA"	, "C", Len( cEmpAnt )	, 0},;
		{"FILIAL"	, "C", FWSizeFilial()	, 0},;
		{"NOME"		, "C", 60				, 0};
	})
	
//Definindo indice
oMark:AddIndex("01", {"EMPRESA", "FILIAL"} )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

U_COM001A(@cAliasAux,,cNegDe,cFilDe,cSegDe)

//Final da montagem da tabela temporaria
//Inicio do browser de exibi็ใo das filiais
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse,oMark:GetRealName() ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasAux )->FILIAL 	},"Filial"		, FWSizeFilial( )	, , "C") ,;
	AddColumn({|| ( cAliasAux )->NOME 		},"Nome"		, 60				, , "C")  ;
})

oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })
oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:Activate()

Return oMark

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarkAll  บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para marcar/desmarcar todos os registros.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function MarkAll(oBrowse,cTable)

cUpdate := ""

cUpdate := "UPDATE " +cTable +" SET OK = CASE OK WHEN 'T' THEN 'F' ELSE 'T' END"
TCSQLExec(cUpdate)

oBrowse:Refresh(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddColumn บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo das colunas.                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fStep04  บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela do quarto passo.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fStep04( oPanel, oTmpUF, oTmpFil, cAliasRes )

Local nRegs		:= 0
Local cTableReg := "%"+oTmpUF:GetRealName()+"%"
Local cTableFil := "%"+oTmpFil:GetRealName()+"%"

//-- Conta registros a processar
BeginSQL Alias "FILS"
	SELECT COUNT(OK) QTDFILS
	FROM %Exp:cTableFil%
	WHERE OK = 'T'
EndSQL
nRegs := FILS->QTDFILS
FILS->(dbCloseArea())

BeginSQL Alias "REGS"
	SELECT COUNT(OK) QTDREGS
	FROM %Exp:cTableReg%
	WHERE OK = 'T'
EndSQL
nRegs := nRegs * REGS->QTDREGS
REGS->(dbCloseArea())

MsgRun("Selecionando registros...","Processando...",{|| cAliasRes := fGerTmpRes(oTmpUF,oTmpFil)})

Processa({|oSelf| U_FIS001Prep( nRegs, cAliasRes ) }, "Processando registros..." ) 

//Inicio do browser de exibi็ใo dos registros
oBrowse:= FWBrowse( ):New( )
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasRes )
oBrowse:AddStatusColumns( { || If( ( cAliasRes )->SUCESSO == 1 , 'BR_VERDE', If( ( cAliasRes )->SUCESSO == 2, 'BR_VERMELHO', 'BR_AMARELO') ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasRes )->UFORIG 	},"UF Origem"	, Len( CFC->CFC_UFORIG ), , "C") ,;
	AddColumn({|| ( cAliasRes )->UFDEST 	},"UF Destino"	, Len( CFC->CFC_UFDEST ), , "C") ,;
	AddColumn({|| ( cAliasRes )->PRODUTO 	},"Produto"		, Len( SB1->B1_COD )	, , "C") ,;
	AddColumn({|| ( cAliasRes )->FILIAL 	},"Filial"		, FWSizeFilial( )		, , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"	, 150					, , "C")  ;
})
oBrowse:SetDoubleClick({|| fShowErro( ( cAliasRes )->MSGLOG ) })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGerTmpResบAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta TMP de resultados.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGerTmpRes(oTmpUF,oTmpFil)
Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"UFORIG"	, "C", Len( CFC->CFC_UFORIG )	, 0},;
						{"UFDEST"	, "C", Len( CFC->CFC_UFDEST )	, 0},;
						{"PRODUTO"	, "C", Len( CFC->CFC_CODPRD )	, 0},;
						{"EMPRESA"	, "C", Len( cEmpAnt )			, 0},;
						{"FILIAL"	, "C", FWSizeFilial( )			, 0},;
						{"MSG"		, "C", 150						, 0},;
						{"SUCESSO"	, "N", 1						, 0},;
						{"MSGLOG"	, "M", 80						, 0}}
	
While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela temporแria no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","EMPRESA+FILIAL+UFORIG+UFDEST"))

//--Insere uf a criar nas empresas/filiais
cInsert := "INSERT INTO " +cAliasRes +" (UFORIG,UFDEST,PRODUTO,SUCESSO,EMPRESA,FILIAL) "
cInsert += "SELECT REGS.UFORIG, REGS.UFDEST, REGS.CODPRO, 3, FILS.EMPRESA, FILS.FILIAL "
cInsert += "FROM " +oTmpUF:GetRealName() +" REGS, " +oTmpFil:GetRealName() +" FILS "
cInsert += "WHERE REGS.OK = 'T' AND FILS.OK = 'T'"

If TCSQLExec(cInsert) < 0
	Conout(TCSQLError())
EndIf

Return cAliasRes


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFIS001PrepบAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa grava็ใo dos registros.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FIS001Prep( nRegs, cAliasReg, lShwMsg )

Default lShwMsg	:= .T.

Private lTrtExt	:= IsInCallStack( "U_FIS001" )

If lShwMsg
	ProcRegua( nRegs )
EndIf
( cAliasReg )->( dbGoTop( ) ) 
While ( cAliasReg )->( !Eof( ) )
	If cEmpAnt == (cAliasReg)->EMPRESA
		cChaveStop := U_FIS001PE(cAliasReg,lShwMsg)
	Else
		cChaveStop := StartJob("U_FIS001Job",GetEnvServer( ),.T.,AllTrim((cAliasReg)->EMPRESA),AllTrim((cAliasReg)->FILIAL),cEmpAnt,cFilAnt,cAliasReg,lShwMsg)
	EndIf
	
	//-- Posiciona no registro que parou
	If Empty(cChaveStop)
		Exit
	Else
		//( cAliasReg )->(dbSkip())
	EndIf
EndDo

Return 


User Function FIS001PE(cAliasReg,lShwMsg,cEmpAtu,cFilAtu)

Local cMsg		 	:= ""
Local cMsgLog 	 	:= ""
Local nSucesso	 	:= 3
Local cChaveStop 	:= ""
Local oModel
Local aCFCFields	:= {}
Local cAliasTab 	:= ""
Local nCont 		:= 0
Local aDelFil 		:= {}
Local nPosFil 		:= 0

Default lShwMsg 	:= .T.
Default cEmpAtu		:= cEmpAnt
Default cFilAtu		:= cFilAnt

Private lMsErroAuto	:= .F.

While (cAliasReg)->(!Eof()) .And. (cAliasReg)->EMPRESA == cEmpAnt
	If lShwMsg
		IncProc( "Processando UF " + ( cAliasReg )->UFORIG + " / " + (cAliasReg)->UFDEST )
	EndIf
	
	//--Produto nao e obrigatorio no cadastro de UF, so validar se existir
	If !Empty(( cAliasReg )->PRODUTO)
		If !fChkPro( ( cAliasReg )->PRODUTO, ( cAliasReg )->FILIAL, ( cAliasReg )->EMPRESA )
			nSucesso	:= 2
			cMsg		:= "Produto nao existe na filial " + AllTrim( ( cAliasReg )->EMPRESA ) + "/" + AllTrim( ( cAliasReg )->FILIAL ) + "."
			cMsgLog 	+= "Produto " + ( cAliasReg )->PRODUTO + CRLF
			cMsgLog 	+= "-->" + cMsg + CRLF 
		EndIf
	EndIf	
	
	//--Verifica se existe o registro da tabela CFC e exclui
	If Empty(cMsg)
		nPosFil := aScan(aDelFil,{|x|  x[1]+x[2] == (cAliasReg)->FILIAL + (cAliasReg)->EMPRESA})
		If nPosFil == 0
			//--Deleta os registros da Empresa+Filial de Destino antes de comecar a replicacao
			If fChkCfc(  ( cAliasReg )->FILIAL, ( cAliasReg )->EMPRESA )
				Aadd(aDelFil, { ( cAliasReg )->FILIAL, ( cAliasReg )->EMPRESA } )
			Else
				nSucesso	:= 2
				cMsg := "Erro ao excluir os registros na tabela de UF do destino"
				cMsgLog 	+= "-->" + cMsg + CRLF 
			EndIf
		EndIf		
		
		If Empty(cMsg)
			aCFCFields := fGetFields( "CFC" )		
			fCarrAlias( ( cAliasReg )->PRODUTO, @cAliasTab, cEmpAtu, cFilAtu, ( cAliasReg )->UFORIG, ( cAliasReg )->UFDEST )		
			
			//--Busca o CFC da unidade atual para posteriormente replicar
			cEmpAnt := ( cAliasReg )->EMPRESA
			cFilAnt := ( cAliasReg )->FILIAL
			SM0->( dbSeek( ( cAliasReg )->EMPRESA + ( cAliasReg )->FILIAL ) )
			
			oModel  := FwLoadModel ("FISA080")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()
			
			For nCont := 1 To Len(aCFCFields)
				oModel:SetValue("MODEL_CFC",aCFCFields[nCont][01],&((cAliasTab)+"->"+aCFCFields[nCont][01]))
			Next nCont			
			 
			If oModel:VldData()
			    oModel:CommitData()
			     nSucesso	:= 1
			     cMsg		:= "Gravado com sucesso."
			Else
				nSucesso 	:= 2
			    cMsg := VarInfo("",oModel:GetErrorMessage())
			EndIf       
			     
			oModel:DeActivate()
			oModel:Destroy()
			 
			oModel := NIL
		
		EndIf
	EndIf
	
	If Empty( cMsgLog )
		cMsgLog := cMsg
	EndIf
	
	RecLock( cAliasReg, .F. )
	( cAliasReg )->SUCESSO	:= nSucesso
	( cAliasReg )->MSG		:= cMsg
	( cAliasReg )->MSGLOG 	:= cMsgLog
	( cAliasReg )->( MsUnlock( ) )
	
	cMsgLog	:= ""
	cMsg	:= ""
	nSucesso:= 3
	cChaveStop := ( cAliasReg )->(EMPRESA+FILIAL+UFORIG+UFDEST+PRODUTO)

	( cAliasReg )->( dbSkip( ) )
	If (cAliasReg)->(Eof())
		cChaveStop := ""
	EndIf
EndDo

Return cChaveStop

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fChkPro  บAutor  ณ Vinํcius Moreira   บ Data ณ 07/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa se o produto existe na filial destino.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkPro( cCodPro, cFilDes, cEmpDes )

Local cQuery	:= ""
Local lRet		:= .F.
Local cTabelaB1	:= "%"+RetSQLName("SB1")+"%"
Default cEmpDes	:= cEmpAnt

If cEmpDes != cEmpAnt
	cTabelaB1	:= "%SB1"+cEmpDes+"0%"
EndIf

BeginSQL Alias "B1EXIST"
	SELECT COUNT(B1_COD) AS REGS
	FROM %Exp:cTabelaB1%
	WHERE %NotDel% AND
		B1_FILIAL = %Exp:xFilial("SB1",cFilDes)% AND
		B1_COD = %Exp:cCodPro%
EndSQL
lRet := B1EXIST->REGS > 0
B1EXIST->(dbCloseArea())

Return lRet
 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fChkCfc  บAutor  ณ Vinํcius Moreira   บ Data ณ 07/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta os registros na filial destino.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function fChkCfc( cFilDes, cEmpDes )

Local cQuery	:= ""
Local lRet		:= .T.

cQuery := " UPDATE CFC" + cEmpDes + "0 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE CFC_FILIAL = '" + cFilDes + "' "
If TCSQLExec(cQuery) < 0
	lRet := .F.
	Conout(TCSQLError())
EndIf

Return lRet
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCarrAliasบAutor  ณ Vinํcius Moreira   บ Data ณ 28/08/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega os alias das tabelas envolvidas buscando informa-  บฑฑ
ฑฑบ          ณ ็ใo nas outras empresas.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCarrAlias( cCodPro, cAliasTAB, cEmpOri, cFilOri, cUfOrig, cUfDest )

Local cQuery := ""
cAliasTAB := GetNextAlias()

cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM CFC" + cEmpOri + "0 CFC " + CRLF 
cQuery += "  WHERE CFC.CFC_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND CFC.CFC_CODPRD     = '" + cCodPro + "' " + CRLF
cQuery += "    AND CFC.CFC_UFORIG     = '" + cUfOrig + "' " + CRLF
cQuery += "    AND CFC.CFC_UFDEST     = '" + cUfDest + "' " + CRLF
cQuery += "    AND CFC.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  ORDER BY " + CRLF 
cQuery += "    CFC.R_E_C_N_O_ " + CRLF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasTAB,.F.,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGetFieldsบAutor  ณ Vinํcius Moreira   บ Data ณ 29/07/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca campos em uso para o alias.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
			If X3Uso( SX3->X3_USADO ) .And. SX3->X3_CONTEXT != "V"
				AAdd( aRet, { SX3->X3_CAMPO, SX3->X3_TIPO, Nil } )
			EndIf
		EndIf
		SX3->( dbSkip( ) )
	EndDo
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAllLog  บAutor  ณ Vinํcius Moreira   บ Data ณ 07/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Auxilia na montagem do vetor do ExecAuto.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAllLog( aAliasRes )

Local cMsgLog := ""
Local cFilAtu := ""

If MsgYesNo( "Deseja visualizar todos os logs?", "Logs" )
	( aAliasRes )->( dbGoTop( ) )
	While ( aAliasRes )->( !Eof( ) )
		If cFilAtu != ( aAliasRes )->FILIAL
			cFilAtu := ( aAliasRes )->FILIAL
			If !Empty( cMsgLog )
				cMsgLog += Replicate( "-", 20 ) + CRLF + CRLF 
			EndIf
			cMsgLog += "//** Filial : " + ( aAliasRes )->FILIAL + " **//" + CRLF + CRLF 
		EndIf
		cMsgLog += ( aAliasRes )->MSGLOG
		( aAliasRes )->( dbSkip( ) )
	EndDo
	fShowErro( cMsgLog )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fShowErroบAutor  ณ Vinํcius Moreira   บ Data ณ 07/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibe erro em tela.                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FIS001JobบAutor  ณ Vinํcius Moreira   บ Data ณ 29/08/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ambiente pra execu็ใo do JOB.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FIS001Job( cEmpDes, cFilDes, cEmpAtu, cFilAtu, cTabelaReg, lShwMsg )

Local cRet 		:= ""
Local cAliasJob := GetNextAlias()

Private lTrtExt	:= .T.

RpcSetType( 3 )
RpcSetEnv( cEmpDes, cFilDes, , , "FIS" )

dbUseArea(.T.,"TOPCONN",cTabelaReg,cAliasJob,.T.)
dbSetIndex(cTabelaReg+"1")
(cAliasJob)->(dbSetOrder(1))
(cAliasJob)->(dbSeek(cEmpDes))

cRet := U_FIS001PE(cAliasJob,lShwMsg,cEmpAtu,cFilAtu)

(cAliasJob)->(dbCloseArea())
RpcClearEnv()

Return cRet 
