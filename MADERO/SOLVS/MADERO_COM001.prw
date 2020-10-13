#Include "Protheus.ch"  
#Include "FwCommand.ch" 
#Include 'FWMVCDef.ch'
#INCLUDE "TBICONN.CH"

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM001                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri็ใo        ! Copia de produtos vs fornecedores para outras filiais                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinํcius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/ 
User Function COM001()

Local oWizard 		:= FWWizardControl( ):New( )
Local oStep
Local oBrowReg, oBrowFil
Local oTmpReg , oTmpFil
Local cAliasRes
Private cAliasQry	:= GetNextAlias( )
Private cProdDe		:= Space( Len( SA5->A5_PRODUTO ) )
Private cProdAte	:= Space( Len( SA5->A5_PRODUTO ) )
Private cFornDe		:= Space( Len( SA5->A5_FORNECE ) )
Private cFornAte	:= Space( Len( SA5->A5_FORNECE ) )

Private cFilDe	:= Space( Len( ADK->ADK_XFILI ) )
Private cNegDe	:= Space( Len( ADK->ADK_XNEGOC ) )
Private cSegDe	:= Space( Len( ADK->ADK_XSEGUI ) )

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Origem" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs( ) } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "Prod. X Forn." )
oStep:SetConstruction( { |oPanel| oTmpReg := fStep02( oPanel, oBrowReg := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpReg:GetAlias( ) ) } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Filiais" )
oStep:SetConstruction( { |oPanel| oTmpFil := fStep03( oPanel, oBrowFil := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpFil:GetAlias( ) ) } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oStep := oWizard:AddStep( "4" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| fStep04( oPanel, oTmpReg, oTmpFil, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( cAliasRes ), .T. } )
oStep:SetPrevAction( { || Alert("Op็ใo invแlida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan็ar" )

oWizard:Activate( )
oWizard:Destroy( )

If Select( cAliasQry ) > 0
	( cAliasQry )->( dbCloseArea( ) )
EndIf

If oTmpReg != Nil
	oTmpReg:Delete( )
EndIf

If oTmpFil != Nil
	oTmpFil:Delete( )
EndIf

If !Empty( cAliasRes )
	( cAliasRes )->( dbCloseArea( ) )
	TCDelFile( cAliasRes )
	TCRefresh( cAliasRes )
EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fStep01  บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tela do primeiro passo.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fStep01( oPanel1 )

Local nLinha := 10
Local oPanel

oPanel := TScrollBox():New(oPanel1,01,01, oPanel1:nHeight-10, oPanel1:nWidth-10)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

TGet():New(nLinha    ,20, bSetGet(cEmpAnt),oPanel, 10, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Empresa ',1,oPanel:oFont)
TGet():New(nLinha+7.5,40, bSetGet(FWEmpName(cEmpAnt)),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFilAnt),oPanel, (FWSizeFilial()*5), 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Filial',1,oPanel:oFont)
TGet():New(nLinha+7.5,30+((FWSizeFilial()*5)), bSetGet(FWFilialName()),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

nLinha += 40
TGet():New(nLinha    ,20, bSetGet(cProdDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",cProdDe,,,,,,,'Produto de',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cProdAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",cProdAte,,,,,,,'Produto ate',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFornDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2",cFornDe,,,,,,,'Fornecedor de',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFornAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2",cFornAte,,,,,,,'Fornecedor ate',1,oPanel:oFont)

nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFilDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADK2",cFilDe,,,,,,,'Filial',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cNegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZA",cNegDe,,,,,,,'Negocio',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cSegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZB",cSegDe,,,,,,,'Seguimento',1,oPanel:oFont)


Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGetRegs บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca registros que serใo processados.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGetRegs( )
Local cQuery	:= ""
Local lRet		:= .F.

cQuery += "  SELECT " + CRLF 
cQuery += "    SA5.A5_FORNECE FORNECE " + CRLF
cQuery += "   ,SA5.A5_LOJA    LOJA " + CRLF
cQuery += "   ,SA5.A5_NOMEFOR NOME " + CRLF
cQuery += "   ,SA5.A5_PRODUTO PRODUTO " + CRLF
cQuery += "   ,SA5.A5_NOMPROD DESCRICAO " + CRLF
cQuery += "   ,SA5.A5_CODPRF  CODPRF " + CRLF
cQuery += "   FROM " + RetSQLName( "SA5" ) + " SA5 " + CRLF
cQuery += "  WHERE SA5.A5_FILIAL  = '" + xFilial( "SA5" ) + "' " + CRLF
cQuery += "    AND SA5.A5_PRODUTO BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' " + CRLF
cQuery += "    AND SA5.A5_FORNECE BETWEEN '" + cFornDe + "' AND '" + cFornAte + "' " + CRLF
cQuery += "    AND SA5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  ORDER BY " + CRLF
cQuery += "    SA5.A5_FORNECE " + CRLF
cQuery += "   ,SA5.A5_LOJA " + CRLF
cQuery += "   ,SA5.A5_PRODUTO " + CRLF       
cQuery += "   ,SA5.A5_CODPRF " + CRLF       
cAliasQry := MPSysOpenQuery( cQuery )
lRet := ( cAliasQry )->( !Eof( ) )
If !lRet
	Alert( "Nใo foram encontrados registros para processamento" )
EndIf

Return lRet
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
Static Function fStep02( oPanel, oBrowse )

Local oMark 	:= FWTemporaryTable( ):New( )
Local cAliasAux	:= ""
Local aStruct 	:= ( cAliasQry )->( dbStruct( ) )

//--Inicio da montagem da tabela temporaria
//Acrescenta o campo de mark
AAdd( aStruct, { } )
AIns( aStruct, 1 )
aStruct[ 01 ] := { "OK", "L", 1, 0 }
oMark:SetFields( aStruct )

//Definindo indice
oMark:AddIndex( "01", { "FORNECE", "LOJA", "PRODUTO", "CODPRF" } )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

While ( cAliasQry )->( !Eof( ) )
	RecLock( cAliasAux, .T. )
		( cAliasAux )->OK 			:= .F.
		( cAliasAux )->FORNECE 		:= ( cAliasQry )->FORNECE
		( cAliasAux )->LOJA			:= ( cAliasQry )->LOJA
		( cAliasAux )->NOME			:= ( cAliasQry )->NOME
		( cAliasAux )->PRODUTO 		:= ( cAliasQry )->PRODUTO
		( cAliasAux )->DESCRICAO	:= ( cAliasQry )->DESCRICAO
		( cAliasAux )->CODPRF	    := ( cAliasQry )->CODPRF
	( cAliasAux )->( MsUnlock( ) )
	( cAliasQry )->( dbSkip( ) )
EndDo
( cAliasQry )->( dbCloseArea( ) )

//Final da montagem da tabela temporaria
//Inicio do browser de exibi็ใo dos registros
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasAux )->PRODUTO 	},"Produto"		, TamSX3("A5_PRODUTO")[1], , "C") ,;
	AddColumn({|| ( cAliasAux )->DESCRICAO 	},"Descricao"	, TamSX3("A5_NOMPROD")[1], , "C") ,;
	AddColumn({|| ( cAliasAux )->CODPRF 	},"Prod. Forn."	, TamSX3("A5_CODPRF" )[1], , "C") ,;
	AddColumn({|| ( cAliasAux )->FORNECE 	},"Codigo"		, TamSX3("A5_FORNECE")[1], , "C") ,;
	AddColumn({|| ( cAliasAux )->LOJA 		},"Loja"		, TamSX3("A5_LOJA"   )[1], , "C") ,;
	AddColumn({|| ( cAliasAux )->NOME 		},"Nome"		, TamSX3("A5_NOMEFOR")[1], , "C")  ;
})
oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibi็ใo dos registros

Return oMark



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fStep03( oPanel, oBrowse )
Local aSM0 		:= FWLoadSM0( )
Local oMark 	:= FWTemporaryTable( ):New( )
Local cAliasAux	:= ""
Local nI		:= 0

//--Inicio da montagem da tabela temporaria
oMark:SetFields({ ;
		{"OK"		, "L", 1, 0},;
		{"EMPRESA"	, "C", Len( cEmpAnt ), 0},;
		{"FILIAL"	, "C", FWSizeFilial(), 0},;
		{"NOME"		, "C", 60, 0};
	})

//Definindo indice
oMark:AddIndex("01", {"EMPRESA", "FILIAL"} )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

//U_COM001A( @cAliasAux )
U_COM001A(@cAliasAux,,cNegDe,cFilDe,cSegDe)

//Final da montagem da tabela temporaria
//Inicio do browser de exibi็ใo das filiais
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{|| ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse ) } )

oBrowse:SetColumns({;
	;//AddColumn({|| ( cAliasAux )->EMPRESA 	},"Empresa"		, Len( cEmpAnt )	, , "C") ,;
	AddColumn({|| ( cAliasAux )->FILIAL 	},"Filial"		, FWSizeFilial( )	, , "C") ,;
	AddColumn({|| ( cAliasAux )->NOME 		},"Nome"		, 60				, , "C")  ;
})
oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibi็ใo das filiais

Return oMark                              


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
Static Function fStep04( oPanel, oTmpReg, oTmpFil, cAliasRes )
Local nMeter	:= 0
Local nRegs		:= 0
Local oProcess
Local cAliasReg	:= oTmpReg:GetAlias( )
Local cAliasFil	:= oTmpFil:GetAlias( )
Local aFilDes	:= { }

( cAliasFil )->( dbGoTop( ) )
( cAliasFil )->( dbEval( { || If( ( cAliasFil )->OK, ( nRegs++, AAdd( aFilDes, { ( cAliasFil )->EMPRESA, ( cAliasFil )->FILIAL } ) ), ) } ) )
( cAliasFil )->( dbGoTop( ) )

( cAliasReg )->( dbGoTop( ) )
( cAliasReg )->( dbEval( { || If( ( cAliasReg )->OK, nRegs++, ) } ) )
( cAliasReg )->( dbGoTop( ) )

MsgRun("Selecionando registros...","Processando...",{|| cAliasRes := fGerTmpRes( oTmpReg, oTmpFil ) })

nRegs := Len( aFilDes ) * nRegs 
Processa({|oSelf| fProcRegs( nRegs, cAliasRes, aFilDes ) }, "Processando registros..." ) 

( cAliasReg )->( dbGoTop( ) )
//Inicio do browser de exibi็ใo dos registros
oBrowse:= FWBrowse( ):New( )
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasRes )
oBrowse:AddStatusColumns( { || If( ( cAliasRes )->SUCESSO == 1 , 'BR_VERDE', If( ( cAliasRes )->SUCESSO == 2, 'BR_VERMELHO', 'BR_AMARELO') ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasRes )->PRODUTO 	},"Produto"		, Len( SA5->A5_PRODUTO ), , "C") ,;
	AddColumn({|| ( cAliasRes )->DESCRICAO 	},"Descricao"	, Len( SA5->A5_NOMPROD ), , "C") ,;
	AddColumn({|| ( cAliasRes )->FORNECE 	},"Codigo"		, Len( SA5->A5_FORNECE ), , "C") ,;
	AddColumn({|| ( cAliasRes )->LOJA 		},"Loja"		, Len( SA5->A5_LOJA )	, , "C") ,;
	AddColumn({|| ( cAliasRes )->NOME 		},"Nome"		, Len( SA5->A5_NOMEFOR ), , "C") ,;
	AddColumn({|| ( cAliasRes )->EMPRESA 	},"Empresa"		, Len( cEmpAnt )		, , "C") ,;
	AddColumn({|| ( cAliasRes )->FILIAL 	},"Filial"		, FWSizeFilial( )		, , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"	, 150, , "C")  ;
})
oBrowse:SetDoubleClick({|| fShowErro( ( cAliasRes )->MSGLOG ) })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibi็ใo dos registros

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfProcRegs บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa grava็ใo dos registros.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcRegs( nRegs, cAliasReg, aFilDes )
Static aSA5Fields   := { }
Local cMsg			:= ""
Local cMsgLog 		:= ""
Local nSucesso		:= 3
Local aAllRegs		:= { }
Local nPosFor		:= 0
Local nPosPrd		:= 0
Local cAux			:= ""
Local xAux			:= Nil

ProcRegua( nRegs+1 )
IncProc( "Agrupando produtos dos fornecedores..." )
( cAliasReg )->( dbGoTop( ) )
While ( cAliasReg )->( !Eof( ) )
 		AAdd( aAllRegs, { 	( cAliasReg )->PRODUTO,;		//01
		 					( cAliasReg )->FILIAL,;			//02
	                        ( cAliasReg )->FORNECE,;		//03
				 			( cAliasReg )->LOJA,;			//04
				 			( cAliasReg )->NOME,;			//05
		 					( cAliasReg )->DESCRICAO,;		//06
		 					( cAliasReg )->( Recno( ) ),;	//07
		 					( cAliasReg )->CODPRF,;			//08 
		 					( cAliasReg )->EMPRESA } )		//09	
	( cAliasReg )->( dbSkip( ) )
EndDo

For nPosPrd := 1 to Len( aAllRegs )
	IncProc( "Processando produto " + aAllRegs[nPosPrd,1] + " na filial " + aAllRegs[nPosPrd,9] + "/" + aAllRegs[nPosPrd,2] )
	cMsgLog += "Processando produto " + aAllRegs[nPosPrd,1] + " na filial " + aAllRegs[nPosPrd,9] + "/" + aAllRegs[nPosPrd,2] + CRLF

	If aAllRegs[nPosPrd,9] == cEmpAnt
		cAux := fProcAll( aAllRegs[nPosPrd,1], aAllRegs[nPosPrd,6], aAllRegs[nPosPrd,2], aAllRegs[nPosPrd,8], aAllRegs[nPosPrd,3], aAllRegs[nPosPrd,4], , , , aAllRegs[nPosPrd,7], cAliasReg )
	Else
		xAux := StartJob("U_COM001Job", GetEnvServer( ), .T., AllTrim( aAllRegs[nPosPrd,9] ), aAllRegs[nPosPrd,2], cEmpAnt, cFilAnt, cAliasReg, aAllRegs, nPosPrd)
		If ValType( xAux ) != "N" .Or. xAux == 0
			Alert( "Problemas durante gravacao dos dados na empresa " + aAllRegs[nPosPrd,9] + "." )
			Exit
		Else
			nPosPrd := xAux -1
		EndIf
	EndIf
Next nPosPrd

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fProcAll บAutor  ณ Vinํcius Moreira   บ Data ณ 06/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa os produtos conforme ordena็ใo.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcAll( cCodPro, cDesc, cFilDes, cCodPrf, cFornec, cLoja, cEmpDes, cEmpAtu, cFilAtu, nRecReg, cAliasReg )
Local cEmpBkp		:= cEmpAnt
Local cFilBkp 		:= cFilAnt
Local nModBkp		:= nModulo
Local lRet			:= .T.
Local lRetProc  	:= .T.
Local lExistDado	:= .F.
Local nX 			:= 1
Local aDadSA5		:= { }
Local aDadSA5It		:= { }
Local cChvSA5		:= ""
Local aRotAnt		:= If( Type( "aRotina" ) != "U", AClone( aRotina ), { } )
Local cQuery		:= ""
Local cAliasSA5		:= "" 
Local cEmpSB1		:= xFilial("SB1")
Local cMsgLog		:= ""
Default cEmpDes		:= cEmpAnt
Default cEmpAtu		:= cEmpAnt
Default cFilAtu		:= cFilAnt	
Private aRotina		:= StaticCall( MATA061, MenuDef )

If Len( aSA5Fields ) == 0
	aSA5Fields := fGetFields( "SA5", "A5_FILIAL|A5_FABR|A5_FALOJA|" )
EndIf

Begin Transaction
cMsgLog += "*Verificando cadastros relacionados na filial de destino " + cEmpDes + "/" + cFilDes + CRLF 

// -> Verifica cadastro de produtos no destino
SB1->(DbSetOrder(1))
If !SB1->(DbSeek(IIF(AllTrim(cEmpSB1)=="",cEmpSB1,cFilDes)+cCodPro))
	cMsgLog += "--> Erro: Produto(" + cCodPro + ") nao encontrado no destino." + CRLF
	lRetProc:=.F.
	DisarmTransaction( )
Else
    cQuery := "  SELECT * " + CRLF 
	cQuery += "   FROM SA5" + cEmpAtu + "0 "               + CRLF
	cQuery += "  WHERE A5_FILIAL  = '" + cFilAtu	+ "' AND " + CRLF
	cQuery += "        A5_PRODUTO = '" + cCodPro	+ "' AND " + CRLF
	cQuery += "        A5_CODPRF  = '" + cCodPrf	+ "' AND " + CRLF
	cQuery += "        A5_FORNECE = '" + cFornec	+ "' AND " + CRLF
	cQuery += "        A5_LOJA    = '" + cLoja		+ "' AND " + CRLF
	cQuery += "        D_E_L_E_T_ = ' '                          " + CRLF
	cQuery += "  ORDER BY "     + CRLF
	cQuery += "    A5_FORNECE " + CRLF
	cQuery += "   ,A5_LOJA "    + CRLF
	cQuery += "   ,A5_PRODUTO " + CRLF       
	cQuery += "   ,A5_CODPRF "  + CRLF       
	cAliasSA5 := MPSysOpenQuery(cQuery)
	
	(cAliasSA5)->(DbGotop())
    While !(cAliasSA5)->(Eof())
    	
    	// -> Valida cadastros auxiliares no destino
    	//lExistDado:= .F.
    	cFilAnt:=cFilDes   	
    	AIA->(DbSetOrder(1))
    	If AIA->(DbSeek(xFilial("AIA")+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_CODTAB))
    		// -> Verifica se a tabela ้ vแlida
    	   	If AIA->AIA_DATDE <= dDataBase .and.  (AIA->AIA_DATATE >= dDataBase .or. Empty(AIA->AIA_DATATE)) 
    	   		// -> Verifica condi็ใo de pagamento da tabela de pre็o
    	   		SE4->(DbSetOrder(1))
				If !Empty(AIA->AIA_CONDPG) .And. !SE4->(DbSeek(xFilial("SE4")+AIA->AIA_CONDPG))
					cMsgLog += "--> Erro: Condicao de pagamento(" + AIA->AIA_CONDPG + ") cadastrada na tabela de preco " + (cAliasSA5)->A5_CODTAB + " nao cadastrada." + CRLF
					lRet    := .F.
				EndIf	                  
				// -> Pesquisa no item da tabela de pre็o
				DbSelectArea("AIB")
				AIB->(DbSetOrder(2))
				If !AIB->(DbSeek(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB+(cAliasSA5)->A5_PRODUTO))
					cMsgLog += "--> Erro: Produto(" + (cAliasSA5)->A5_PRODUTO + ") nao encontrado para tabela de preco " + (cAliasSA5)->A5_CODTAB + "." + CRLF
					lRet    := .F.
				EndIf         
			EndIf                        
		ElseIf !(Empty((cAliasSA5)->A5_CODTAB))
			cMsgLog += "--> Erro: Tabela de preco " + (cAliasSA5)->A5_CODTAB + " nao encontrada para o fornecedor(" + (cAliasSA5)->A5_FORNECE+"/"+(cAliasSA5)->A5_LOJA + ")." +  CRLF 
			lRet    := .F.                  
		EndIf
		
		// -> Se ok, prossegue com a c๓pia
		If lRet
			// --> Se tudo ok, inclui dados para replica
			//AAdd( aDadSA5It, fMntDados( "SA5", aSA5Fields ) ) 
			aDadSA5It:=fMntDados(cAliasSA5,aSA5Fields)
			nModulo := 2
			cFilAnt := cFilDes
			SM0->( dbSeek( cEmpAnt + cFilAnt ) )
			If !fExclEstru( cCodPro, cCodPrf, cFornec, cLoja, @cMsgLog, (cAliasSA5)->A5_FABR, (cAliasSA5)->A5_FALOJA )
				lRetProc := .F.
				DisarmTransaction( )
				Exit
			ElseIf !fCpyEstru( cCodPro, aDadSA5, aDadSA5It, @cMsgLog )
				lRetProc := .F.
				cMsgLog  += "--> Produto x fornecedor nao foi replicado para o destino." +  CRLF
				DisarmTransaction( )
				Exit
			EndIf
		EndIf
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		SM0->( dbSeek( cEmpAnt + cFilAnt ) )	
		(cAliasSA5)->(dbSkip())
	EndDo
	
	DbSelectArea(cAliasSA5)
	(cAliasSA5)->(DbCloseArea())
EndIf
End Transaction

cEmpAnt := cEmpBkp
cFilAnt := cFilBkp
nModulo	:= nModBkp
aRotina := aRotAnt

( cAliasReg )->( dbGoTo( nRecReg ) )
RecLock( cAliasReg, .F. )
	If lRetProc .And. lRet 
		( cAliasReg )->SUCESSO	:= 1
		( cAliasReg )->MSG		:= "Gravado com sucesso."
	Else
		( cAliasReg )->SUCESSO	:= 2
		cMsg		:= "Ocorreram erros durante o processamento."
	EndIf
	( cAliasReg )->MSGLOG 	:= cMsgLog
( cAliasReg )->( MsUnlock( ) )

Return cMsgLog

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
Static function MarkAll(oBrowse)

(oBrowse:GetAlias())->( dbGotop() )
(oBrowse:GetAlias())->( dbEval({|| OK := !OK },, { || ! Eof() }))
(oBrowse:GetAlias())->( dbGotop() )

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
Static Function fGerTmpRes(oTmpReg,oTmpFil)
Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"FORNECE"	, "C", TamSx3("A5_FORNECE")[1]	, 0},;
						{"LOJA"		, "C", TamSx3("A5_LOJA"   )[1] 	, 0},;
						{"NOME"		, "C", TamSx3("A5_NOMEFOR")[1]	, 0},;
						{"PRODUTO"	, "C", TamSx3("A5_PRODUTO")[1]	, 0},;
						{"DESCRICAO", "C", TamSx3("A5_NOMPROD")[1]	, 0},;
						{"CODPRF"   , "C", TamSx3("A5_CODPRF" )[1]	, 0},;
						{"EMPRESA"	, "C", Len( cEmpAnt )			, 0},;
						{"FILIAL"	, "C", FWSizeFilial()			, 0},;
						{"SUCESSO"	, "N", 1						, 0},;
						{"MSGLOG"	, "M", 80						, 0},;
						{"MSG"		, "C", 150, 0}						}
	
While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela temporแria no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","EMPRESA+FILIAL+FORNECE+LOJA+PRODUTO+CODPRF"))

//--Insere produtos a criar nas empresas/filiais
cInsert := "INSERT INTO " +cAliasRes +" (SUCESSO,EMPRESA,FILIAL,FORNECE,LOJA,PRODUTO,CODPRF) "
cInsert += "SELECT 3, FILS.EMPRESA, FILS.FILIAL, REGS.FORNECE, REGS.LOJA, REGS.PRODUTO, REGS.CODPRF "
cInsert += "FROM " +oTmpReg:GetRealName() +" REGS, " +oTmpFil:GetRealName() +" FILS "
cInsert += "WHERE REGS.OK = 'T' AND FILS.OK = 'T'"

If TCSQLExec(cInsert) < 0
	ConOut(TCSQLError())
EndIf

Return cAliasRes
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCpyEstru บAutor  ณ Vinํcius Moreira   บ Data ณ 09/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Copia registros                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCpyEstru( cCodPro, aDadSA5, aDadSA5It, cMsgLog )
//Local aDados		:= { }
Local nOpcX			:= 3
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "com001_i_" + AllTrim( cCodPro ) + "_" + AllTrim( cFilAnt ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.
Private INCLUI		:= .T.
Private ALTERA		:= .F.
Private EXCLUI		:= .F.

cMsgLog += "*Criando produto vs fornecedor do produto " + cCodPro + CRLF 

aDadSA5It := fChkCpos( aDadSA5It )
MSExecAuto( { | x, y | u_amata060( x, y ) }, aDadSA5It, nOpcX )		
If lMsErroAuto
	fCriaDir( cPathTmp )
	MostraErro( cPathTmp, cArqTmp )
	cMsgLog += "Erro: " + MemoRead( cPathTmp + cArqTmp )
	cMsgLog += CRLF + CRLF
	FErase( cPathTmp + cArqTmp )
Else
	cMsgLog += "-->OK" + CRLF
EndIf

Return !lMsErroAuto
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
		If Empty( cNotShow ) .Or. !cCampo $ cNotShow 
			//If X3Uso( SX3->X3_USADO ) .And. SX3->X3_CONTEXT != "V"
			If SX3->X3_CONTEXT != "V"
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
ฑฑบPrograma  ณ fMntDadosบAutor  ณ Vinํcius Moreira   บ Data ณ 07/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Auxilia na montagem do vetor do ExecAuto.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMntDados( cAliasAtu, aFields )

Local nC	:= 0
Local aRet	:= { }

For nC := 1 to Len( aFields )
	If ( cAliasAtu )->( FieldPos( aFields[ nC, 1 ] ) ) > 0 .And. !Empty( ( cAliasAtu )->&( aFields[ nC, 1 ] ) )
		If aFields[ nC, 2 ] == "D"
			AAdd( aRet, { aFields[ nC, 1 ], SToD( ( cAliasAtu )->&( aFields[ nC, 1 ] ) ), Nil } )
		ElseIf aFields[ nC, 2 ] == "L"
			AAdd( aRet, { aFields[ nC, 1 ], "T" $ ( cAliasAtu )->&( aFields[ nC, 1 ] ), Nil } )
		Else
			AAdd( aRet, { aFields[ nC, 1 ], ( cAliasAtu )->&( aFields[ nC, 1 ] ), Nil } )
		EndIf
	EndIf
Next nC

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fCriaDir บAutor  ณ Vinํcius Moreira   บ Data ณ 29/07/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria diretorios utilizados pelo programa.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCriaDir(cPatch, cBarra)
	
Local lRet   := .T.
Local aDirs  := {}
Local nPasta := 1
Local cPasta := ""
Default cBarra	:= "\"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriando diret๓rio de configura็๕es de usuแrios.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aDirs := Separa(cPatch, cBarra)
For nPasta := 1 to Len(aDirs)
	If !Empty (aDirs[nPasta])
		cPasta += cBarra + aDirs[nPasta]
		If !ExistDir (cPasta) .And. MakeDir(cPasta) != 0
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nPasta
	
Return lRet
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
Local cFile    :=""
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
ฑฑบPrograma  ณ fChkMarcaบAutor  ณ Vinํcius Moreira   บ Data ณ 09/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa se algum registro foi selecionado.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkMarca( cAliasAtu )

Local lRet := .F.
Local aArea	:= ( cAliasAtu )->( GetArea( ) )

( cAliasAtu )->( dbGoTop( ) )
While ( cAliasAtu )->( !Eof( ) )
	If ( cAliasAtu )->OK
		lRet := .T.
		Exit
	EndIf
	( cAliasAtu )->( dbSkip( ) )
EndDo 

If !lRet
	Alert( "Nenhum registro foi selecionado." )
EndIf

RestArea( aArea )

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COM001A  บAutor  ณ Vinํcius Moreira   บ Data ณ 13/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca filial para exibia็ใo na lista de processamento.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COM001A(cAliasAux,cGrpNeg,cNegDe,cFilDe,cSegDe)
Local lRet		:= .F.
Local cQuery	:= ""
Local cAliasQry	:= ""
Default cGrpNeg	:= fGetGrpNeg( )
Default cFilDe	:= ''
Default cNegDe	:= ''
Default cSegDe	:= ''

cAliasQry := u_xGetUn( cGrpNeg,cNegDe,cFilDe,cSegDe )

If ( cAliasQry )->( !Eof( ) )
	lRet := .T.
	While ( cAliasQry )->( !Eof( ) )
		Reclock( cAliasAux,.T.)
			( cAliasAux )->OK      := .F.
			( cAliasAux )->EMPRESA := ( cAliasQry )->XGEMP
			( cAliasAux )->FILIAL  := ( cAliasQry )->CODFIL
			( cAliasAux )->NOME    := ( cAliasQry )->NOME
		( cAliasAux )->( MsUnlock() )
		( cAliasQry )->( dbSkip( ) )
	EndDo
EndIf
( cAliasQry )->( dbCloseArea( ) )
	
Return 	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COM001JobบAutor  ณ Vinํcius Moreira   บ Data ณ 29/08/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ambiente pra execu็ใo do JOB.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COM001Job( cEmpDes, cFilDes, cEmpAtu, cFilAtu, cTabelaReg, aDados, nPosAtu )

Local cAliasTmp	:= GetNextAlias( )
Local nPosPrd		:= 0

RpcSetType( 3 )
RpcSetEnv( cEmpDes, cFilDes, , , "EST" )

dbUseArea( .T., "TOPCONN", cTabelaReg, cAliasTmp, .T. )

For nPosPrd := nPosAtu to Len( aDados )
	If aDados[nPosPrd, 9] == cEmpAnt
		fProcAll( aDados[nPosPrd,1], aDados[nPosPrd,6], aDados[nPosPrd,2], aDados[nPosPrd,8], aDados[nPosPrd,3], aDados[nPosPrd,4], cEmpDes, cEmpAtu, cFilAtu, aDados[nPosPrd,7], cAliasTmp )
	Else
		Exit
	EndIf
Next nPosPrd

( cAliasTmp )->( dbCloseArea( ) )
RpcClearEnv()

Return nPosPrd 
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
Static Function fCarrAlias( cCodPro, cAliasSG1, cEmpOri, cFilOri )

Local cQuery := ""

cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM SG1" + cEmpOri + "0 SG1 " + CRLF 
cQuery += "  WHERE SG1.G1_FILIAL  = '" + cFilOri + "' " + CRLF 
cQuery += "    AND SG1.G1_COD     = '" + cCodPro + "' " + CRLF 
cQuery += "    AND SG1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  ORDER BY " + CRLF 
cQuery += "    SG1.R_E_C_N_O_ " + CRLF 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasSG1,.F.,.T.)

Return 

Static Function fGetGrpNeg( )

Local xRet
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias( )

cQuery += "  SELECT " + CRLF 
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

Return xRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fChkCpos บAutor  ณ Vinํcius Moreira   บ Data ณ 26/03/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa ordem dos campos para execu็ใo do MsExecAuto.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkCpos(aCpos)

Local aCposAux := {}
Local aRet     := {}
Local nCpo     := 0
Local nTamCpo  := Len(SX3->X3_CAMPO)

dbSelectArea("SX3")
SX3->(dbSetOrder(2))//X3_CAMPO

For nCpo := 1 to Len(aCpos)
	If SX3->(dbSeek(PadR(aCpos[nCpo, 1], nTamCpo, " ")))
		aAdd(aCposAux, {SX3->X3_ORDEM, aCpos[nCpo]})
	Else
		aAdd(aCposAux, {"999", aCpos[nCpo]})
	EndIf
Next nCpo
ASort(aCposAux,,,{|x,y| x[1] < y[1] })
For nCpo := 1 to Len(aCposAux)
	aAdd(aRet, aCposAux[nCpo,2])
Next nCpo

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfExclEstruบAutor  ณ Vinํcius Moreira   บ Data ณ 08/05/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica necessidade de exclusใo dos registros do destino. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExclEstru( cCodPro, cCodPrf, cFornec, cLoja, cMsgLog, cFaBr, cFaLoja )

Local aDados		:= { }
Local aDadSA5		:= { }
Local nOpcX			:= 5
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "com001_e_" + AllTrim( cCodPro ) + "_" + AllTrim( cFilAnt ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.

//SA5->( dbSetOrder( 2 ) )	//A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
//If SA5->( dbSeek( xFilial( "SA5" ) + PadR( cCodPro, Len( SA5->A5_PRODUTO ), " " ) + cFornec + cLoja ) )

//SA5->( dbSetOrder( 1 ) )	//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA
SA5->( dbSetOrder( 17 ) )	//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_CODPRF
//If SA5->( dbSeek( xFilial( "SA5" ) + cFornec + cLoja + PadR( cCodPro, Len( SA5->A5_PRODUTO ), " " ) + cFaBr + cFaLoja ) )
If SA5->( dbSeek( xFilial( "SA5" ) + cFornec + cLoja + PadR( cCodPro, Len( SA5->A5_PRODUTO ), " " ) + PadR( cCodPrf, Len( SA5->A5_CODPRF ), " " ) ) )
	cMsgLog += "*Excluindo produto vs fornecedores existente do produto " + cCodPro + CRLF 
	AAdd( aDadSA5, { "A5_PRODUTO"	, SA5->A5_PRODUTO	, Nil } )
	AAdd( aDadSA5, { "A5_CODPRF"	, SA5->A5_CODPRF	, Nil } )
	AAdd( aDadSA5, { "A5_NOMPROD"	, SA5->A5_NOMPROD	, Nil } )
	If !Empty( SA5->A5_REFGRD )
		AAdd( aDadSA5, { "A5_REFGRD"	, SA5->A5_REFGRD	, Nil } )
	EndIf
	If !Empty( SA5->A5_DESREF )
		AAdd( aDadSA5, { "A5_DESREF"	, SA5->A5_DESREF	, Nil } )
	EndIf
	AAdd( aDadSA5, { "A5_FORNECE"		, SA5->A5_FORNECE	, Nil } )
	AAdd( aDadSA5, { "A5_LOJA"			, SA5->A5_LOJA	, Nil } )
	//AAdd( aDados, {"MdFieldSA5", aDadSA5} )

		aDadSA5 := fChkCpos(aDadSA5)
	//FWMVCRotAuto( FwLoadModel ("MATA061"),"SA5",MODEL_OPERATION_DELETE, aDados )
	MSExecAuto({|x,y| u_amata060(x,y)},aDadSA5,nOpcX)		
	If lMsErroAuto
		fCriaDir( cPathTmp )
		MostraErro( cPathTmp, cArqTmp )
		cMsgLog += "Erro: " + MemoRead( cPathTmp + cArqTmp )
		cMsgLog += CRLF + CRLF
		FErase( cPathTmp + cArqTmp )
	Else
		cMsgLog += "-->OK" + CRLF
	EndIf
EndIf

Return !lMsErroAuto