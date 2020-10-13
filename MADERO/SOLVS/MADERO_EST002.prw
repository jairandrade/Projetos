#Include "Protheus.ch"  
#include "FwCommand.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST002                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Copia de estruturas de produtos para outras filiais.                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vin�cius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/ 
User Function EST002( )

Local oWizard 		:= FWWizardControl( ):New( )
Local oStep
Local oBrowReg, oBrowFil
Local oTmpReg , oTmpFil
Local cAliasRes
Private cAliasQry	:= GetNextAlias( )
Private cProdDe		:= Space( Len( SG1->G1_COD ) )
Private cProdAte	:= Space( Len( SG1->G1_COD ) )
Private cGrupoDe	:= Space( Len( SB1->B1_GRUPO ) )
Private cGrupoAte	:= Space( Len( SB1->B1_GRUPO ) )

Private cFilDe		:= Space( Len( ADK->ADK_XFILI ) )
Private cNegDe		:= Space( Len( ADK->ADK_XNEGOC ) )
Private cSegDe		:= Space( Len( ADK->ADK_XSEGUI ) )

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Origem" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs( ) } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "Estruturas" )
oStep:SetConstruction( { |oPanel| oTmpReg := fStep02( oPanel, oBrowReg := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Filiais" )
oStep:SetConstruction( { |oPanel| oTmpFil := fStep03( oPanel, oBrowFil := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "4" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| fStep04( oPanel, oTmpReg, oTmpFil, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( cAliasRes ), .T. } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fStep01  �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tela do primeiro passo.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
TGet():New(nLinha    ,20, bSetGet(cGrupoDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SBM",cGrupoDe,,,,,,,'Grupo de',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cGrupoAte),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SBM",cGrupoAte,,,,,,,'Grupo ate',1,oPanel:oFont)

nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFilDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADK2",cFilDe,,,,,,,'Filial',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cNegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZA",cNegDe,,,,,,,'Negocio',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cSegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZB",cSegDe,,,,,,,'Seguimento',1,oPanel:oFont)

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fGetRegs �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca registros que ser�o processados.                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGetRegs( )

Local cQuery	:= ""
Local lRet		:= .F.

cQuery += "  SELECT " + CRLF 
cQuery += "    SG1.G1_COD  PRODUTO " + CRLF
cQuery += "   ,SB1.B1_DESC DESCRICAO " + CRLF
cQuery += "   FROM " + RetSQLName( "SG1" ) + " SG1 " + CRLF
cQuery += " INNER JOIN " + RetSQLName( "SB1" ) + " SB1 ON " + CRLF
cQuery += "        SB1.B1_FILIAL  = SG1.G1_FILIAL " + CRLF
cQuery += "    AND SB1.B1_COD     = SG1.G1_COD " + CRLF
cQuery += "    AND SB1.B1_GRUPO   BETWEEN '" + cGrupoDe + "' AND '" + cGrupoAte + "' " + CRLF
//cQuery += "    AND SB1.B1_TIPO  IN('PA','PI')  " + CRLF
cQuery += "    AND SB1.D_E_L_E_T_ = ' '    " + CRLF
cQuery += "  WHERE SG1.G1_FILIAL  =       '" + xFilial( "SB1" ) + "' " + CRLF
cQuery += "    AND SG1.G1_COD     BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' " + CRLF
cQuery += "    AND SG1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  GROUP BY " + CRLF 
cQuery += "    SG1.G1_COD " + CRLF
cQuery += "   ,SB1.B1_DESC " + CRLF
cQuery += "  ORDER BY " + CRLF
cQuery += "    SG1.G1_COD " + CRLF
cAliasQry := MPSysOpenQuery( cQuery )
lRet := ( cAliasQry )->( !Eof( ) )
If !lRet
	Alert( "N�o foram encontrados registros para processamento" )
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fStep02  �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tela do segundo passo.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
oMark:AddIndex( "01", { "PRODUTO" } )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

While ( cAliasQry )->( !Eof( ) )
	RecLock( cAliasAux, .T. )
		( cAliasAux )->OK 			:= .F.
		( cAliasAux )->PRODUTO 		:= ( cAliasQry )->PRODUTO
		( cAliasAux )->DESCRICAO	:= ( cAliasQry )->DESCRICAO
	( cAliasAux )->( MsUnlock( ) )
	( cAliasQry )->( dbSkip( ) )
EndDo
( cAliasQry )->( dbCloseArea( ) )
//Final da montagem da tabela temporaria
//Inicio do browser de exibi��o dos registros
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasAux )->PRODUTO 	},"Produto"		, Len( SG1->G1_COD ), , "C") ,;
	AddColumn({|| ( cAliasAux )->DESCRICAO 	},"Descricao"	, Len( SB1->B1_DESC ), , "C")  ;
})
oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibi��o dos registros

Return oMark
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fStep03  �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tela do terceiro passo.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//Inicio do browser de exibi��o das filiais
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
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
//Final do browser de exibi��o das filiais

Return oMark
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fStep04  �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta tela do quarto passo.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//Inicio do browser de exibi��o dos registros
oBrowse:= FWBrowse( ):New( )
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasRes )
oBrowse:AddStatusColumns( { || If( ( cAliasRes )->SUCESSO == 1 , 'BR_VERDE', If( ( cAliasRes )->SUCESSO == 2, 'BR_VERMELHO', 'BR_AMARELO') ) } )

oBrowse:SetColumns({;
	AddColumn({|| ( cAliasRes )->PRODUTO 	},"Produto"		, Len( SG1->G1_COD ), , "C") ,;
	AddColumn({|| ( cAliasRes )->DESCRICAO 	},"Descricao"	, Len( SB1->B1_DESC ), , "C") ,;
	AddColumn({|| ( cAliasRes )->FILIAL 	},"Filial"		, FWSizeFilial( ), , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"	, 150, , "C")  ;
})
oBrowse:SetDoubleClick({|| fShowErro( ( cAliasRes )->MSGLOG ) })

oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibi��o dos registros

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MarkAll  �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para marcar/desmarcar todos os registros.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function MarkAll(oBrowse)

(oBrowse:GetAlias())->( dbGotop() )
(oBrowse:GetAlias())->( dbEval({|| OK := !OK },, { || ! Eof() }))
(oBrowse:GetAlias())->( dbGotop() )

oBrowse:Refresh(.T.)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddColumn �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o das colunas.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fShowErro�Autor  � Vin�cius Moreira   � Data � 07/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Exibe erro em tela.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fMntDados�Autor  � Vin�cius Moreira   � Data � 07/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Auxilia na montagem do vetor do ExecAuto.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGerTmpRes�Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta TMP de resultados.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fGerTmpRes(oTmpReg,oTmpFil)
Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"PRODUTO"	, "C", Len( SB1->B1_COD )	, 0},;
						{"DESCRICAO", "C", Len( SB1->B1_DESC )	, 0},;
						{"EMPRESA"	, "C", Len( cEmpAnt )		, 0},;
						{"FILIAL"	, "C", FWSizeFilial( )		, 0},;
						{"MSG"		, "C", 150					, 0},;
						{"SUCESSO"	, "N", 1					, 0},;
						{"MSGLOG"	, "M", 80					, 0}	}
	
While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela tempor�ria no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","EMPRESA+FILIAL+PRODUTO"))

//--Insere produtos a criar nas empresas/filiais
cInsert := "INSERT INTO " +cAliasRes +" (PRODUTO,DESCRICAO,SUCESSO,EMPRESA,FILIAL) "
cInsert += "SELECT REGS.PRODUTO, REGS.DESCRICAO, 3, FILS.EMPRESA, FILS.FILIAL "
cInsert += "FROM " +oTmpReg:GetRealName() +" REGS, " +oTmpFil:GetRealName() +" FILS "
cInsert += "WHERE REGS.OK = 'T' AND FILS.OK = 'T'"

If TCSQLExec(cInsert) < 0
	Conout(TCSQLError())
EndIf

Return cAliasRes
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGetFields�Autor  � Vin�cius Moreira   � Data � 29/07/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca campos em uso para o alias.                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		If !cCampo $ cNotShow .And. SX3->X3_CONTEXT != "V"
			If X3Uso( SX3->X3_USADO )
				AAdd( aRet, { SX3->X3_CAMPO, SX3->X3_TIPO, Nil } )
			EndIf
		EndIf
		SX3->( dbSkip( ) )
	EndDo
EndIf

Return aRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fAllLog  �Autor  � Vin�cius Moreira   � Data � 07/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Auxilia na montagem do vetor do ExecAuto.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fProcRegs �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa grava��o dos registros.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static aSG1Fields := { }
Static Function fProcRegs( nRegs, cAliasReg, aFilDes )

Local cMsg			:= ""
Local cMsgLog 		:= ""
Local nSucesso		:= 3
Local cAux			:= ""
Local xAux			:= Nil
Local cEmpAtu		:= ""

ProcRegua( nRegs )
( cAliasReg )->( dbGoTop( ) ) 
While ( cAliasReg )->( !Eof( ) )
	IncProc( "Processando produto " + ( cAliasReg )->PRODUTO )
	cEmpAtu := ( cAliasReg )->EMPRESA
	If cEmpAtu == cEmpAnt
		cAux 	:= fProcAll( ( cAliasReg )->PRODUTO, ( cAliasReg )->EMPRESA, ( cAliasReg )->FILIAL, , , cAliasReg )
	Else
		xAux := StartJob("U_EST002Job", GetEnvServer( ), .T., AllTrim( ( cAliasReg )->EMPRESA ), AllTrim( ( cAliasReg )->FILIAL ), cEmpAnt, cFilAnt, cAliasReg, ( cAliasReg )->( Recno( ) ) )
		If ValType( xAux ) == "C" 
			If xAux != "FIM"
				Alert( "Problemas durante gravacao dos dados na empresa " + cEmpAtu + "." )
				Exit
			EndIf
		ElseIf xAux > 0
			( cAliasReg )->( dbGoTo( xAux ) )
			Loop
		EndIf
	EndIf
	( cAliasReg )->( dbSkip( ) )
EndDo

Return 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fProcAll �Autor  � Vin�cius Moreira   � Data � 06/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa os produtos conforme ordena��o.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fProcAll( cCodPro, cEmpDes, cFilDes, cEmpAtu, cFilAtu, cAliasReg )

Local cFilBkp 	:= cFilAnt
Local nModBkp	:= nModulo
Local lRet		:= .T.
Local nX 		:= 1
Local aDadSG1	:= { }
Local aDadSG1It	:= { }
Local aPrdAnt	:= { }
Local cChvSG1	:= ""
Local cMsgLog	:= ""
Local cAliasSG1	:= GetNextAlias( )
Local aAllEstru		:= { }
Default cEmpAtu	:= cEmpAnt
Default cFilAtu	:= cFilAnt
Private nOrdPrd	:= 1

If Len( aSG1Fields ) == 0
	aSG1Fields := fGetFields( "SG1" )
EndIf

cMsgLog += "*Verificando estrutura do produto " + cCodPro + CRLF
If !fPrepPro( cCodPro, cEmpAtu, cFilAtu, @aAllEstru )
	lRet := .F.
	cMsgLog += "Estrutura(" + cCodPro + ") n�o encontrada na filial " + cEmpAnt + "\" + cFilAnt + CRLF
EndIf

ASort(aAllEstru,,,{|x,y| x[3] > y[3] .Or. ( x[3] == y[3] .And. x[2] > y[2] ) })
Begin Transaction
If lRet
	cMsgLog += "*Verificando do cadastro de produtos no destino: " + cFilDes + CRLF 
	// -> Verifica se os produtos est�o cadastrados no destino
	For nX:=1 to Len(aAllEstru)
	   SB1->(DbSetOrder(1))
	   If !SB1->(DbSeek(cFilDes+aAllEstru[nX,1]))
	      cMsgLog += "Erro: Produto " + aAllEstru[nX,1] + " nao encontrado no destino." + CRLF       
	      lRet := .F.
	   EndIf
	Next nX
EndIf

If lRet
	For nX := 1 to Len( aAllEstru )
		cCodPro := aAllEstru[ nX, 1 ]
		//Evita que produtos j� gravados sejam reprocessados
		If AScan( aPrdAnt, {|x,y| x == cCodPro } ) > 0
			Loop
		EndIf
		AAdd( aPrdAnt, cCodPro )
		
		fCarrSG1( cCodPro, @cAliasSG1, cEmpAtu, cFilAtu )
		
		If (cAliasSG1)->(!Eof())
			AAdd( aDadSG1, { "G1_COD"	, (cAliasSG1)->G1_COD	, Nil } )
			//AAdd( aDadSG1, { "G1_QUANT"	, (cAliasSG1)->G1_QUANT	, Nil } )
			AAdd( aDadSG1, { "NIVALT"	, "S"					, Nil } )
			
			While ( cAliasSG1 )->( !Eof( ) )
				AAdd( aDadSG1It, fMntDados( cAliasSG1, aSG1Fields ) )
				(cAliasSG1)->( dbSkip( ) )
			EndDo
		EndIf
		
		If Len( aDadSG1 ) > 0
			nModulo := 4
			cFilAnt := cFilDes
			SM0->( dbSeek( cEmpAnt + cFilAnt ) )
			If !fExclEstru( cCodPro, @cMsgLog )
				DisarmTransaction( )
			ElseIf !fCpyEstru( cCodPro, aDadSG1, aDadSG1It, @cMsgLog )
				lRet := .F.
				DisarmTransaction( )
			EndIf
			cFilAnt := cFilBkp
			SM0->( dbSeek( cEmpAnt + cFilAnt ) )
			aDadSG1 	:= { }
			aDadSG1It	:= { }
		EndIf
		
		(cAliasSG1)->(dbCloseArea())
	Next nX
Else
	DisarmTransaction( )
EndIf
End Transaction

nModulo	:= nModBkp

RecLock( cAliasReg, .F. )
	If lRet
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fPrepPro �Autor  � Vin�cius Moreira   � Data � 07/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca todas as dependencias de produtos para inclus�o.     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fPrepPro( cCodPro, cEmpOri, cFilOri, aProdutos, nNivPro )

Local aArea		:= GetArea( )
Local aAreaSB1	:= SB1->( GetArea( ) )
Local aAreaSG1	:= SG1->( GetArea( ) )
Local lRet 		:= .T.
Local nNivAtu	:= 0
Local cAliasSB1	:= GetNextAlias( )
Local cAliasSG1	:= ""
Default nNivPro	:= 1

If ( lRet := fCarrSB1( cCodPro, cAliasSB1, cEmpOri, cFilOri ) )
	AAdd( aProdutos, { ( cAliasSB1 )->B1_COD, nOrdPrd, nNivPro } )
	nOrdPrd++
	cAliasSG1 := GetNextAlias( )
	If fCarrSG1( ( cAliasSB1 )->B1_COD, cAliasSG1, cEmpOri, cFilOri )
		nNivPro++
		nNivAtu := nNivPro 
		While ( cAliasSG1 )->( !Eof( ) ) .And. ( cAliasSG1 )->( G1_FILIAL + G1_COD ) == ( cAliasSB1 )->( B1_FILIAL + B1_COD )
			fPrepPro( ( cAliasSG1 )->G1_COMP, cEmpOri, cFilOri, @aProdutos, @nNivPro )
			nNivPro := nNivAtu
			( cAliasSG1 )->( dbSkip( ) )
		EndDo
	EndIf
	( cAliasSG1 )->( dbCloseArea( ) )
EndIf 
( cAliasSB1 )->( dbCloseArea( ) )

RestArea( aAreaSG1 )
RestArea( aAreaSB1 )
RestArea( aArea )

Return lRet
/*
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fExclEstru�Autor  � Vin�cius Moreira   � Data � 08/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica necessidade de exclus�o da estrutura da tabela    ���
���          � de destino.                                                ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fExclEstru( cCodPro, cMsgLog )
Local aDadSG1 		:= { }
Local nOpcX			:= 5
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "est002_e_" + AllTrim( cCodPro ) + "_" + AllTrim( cFilAnt ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.

SG1->( dbSetOrder( 1 ) )//G1_FILIAL+G1_COD+G1_COMP+G1_TRT
If SG1->( dbSeek( xFilial( "SG1" ) + cCodPro ) )
	cMsgLog += "*Excluindo estrutura existente " + cCodPro + CRLF 
	AAdd( aDadSG1,	{ "G1_COD"		, SG1->G1_COD	, Nil } )
	AAdd( aDadSG1,	{ "NIVALT"		, "S"			, Nil } )
	MSExecAuto( { | x, y, z | MATA200( x, y, z ) }, aDadSG1, Nil, nOpcX )
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
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fCriaDir �Autor  � Vin�cius Moreira   � Data � 09/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria diretorios utilizados pelo programa.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCriaDir(cPatch, cBarra)
	
Local lRet   := .T.
Local aDirs  := {}
Local nPasta := 1
Local cPasta := ""
Default cBarra	:= "\"
//�����������������������������������������������Ŀ
//�Criando diret�rio de configura��es de usu�rios.�
//�������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCpyEstru �Autor  � Vin�cius Moreira   � Data � 09/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Copia registros                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCpyEstru( cCodPro, aDadSG1, aDadSG1It, cMsgLog )

Local nOpcX			:= 3
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "est002_i_" + AllTrim( cCodPro ) + "_" + AllTrim( cFilAnt ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.

MSExecAuto( { | x, y, z | MATA200( x, y, z ) }, aDadSG1, aDadSG1It, nOpcX )
cMsgLog += "*Criando estrutura do produto " + cCodPro + CRLF 
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fChkMarca�Autor  � Vin�cius Moreira   � Data � 09/05/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Checa se algum registro foi selecionado.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EST002Job�Autor  � Vin�cius Moreira   � Data � 29/08/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta ambiente pra execu��o do JOB.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EST002Job( cEmpDes, cFilDes, cEmpAtu, cFilAtu, cTabelaReg )

Local xRet 		:= "FIM"
Local cAliasTmp	:= GetNextAlias( )

RpcSetType( 3 )
RpcSetEnv( cEmpDes, cFilDes, , , "EST" )

dbUseArea( .T., "TOPCONN", cTabelaReg, cAliasTmp, .T. )
dbSetIndex( cTabelaReg + "1" )
( cAliasTmp )->( dbSetOrder( 1 ) )
( cAliasTmp )->( dbSeek( cEmpDes ) )

While ( cAliasTmp )->( !Eof( ) )  .And. ( cAliasTmp )->EMPRESA == cEmpAnt
	fProcAll( ( cAliasTmp )->PRODUTO, ( cAliasTmp )->EMPRESA, ( cAliasTmp )->FILIAL, cEmpAtu, cFilAtu, cAliasTmp )
	( cAliasTmp )->( dbSkip( ) )
	xRet := ( cAliasTmp )->( Recno( ) )
EndDo

( cAliasTmp )->( dbCloseArea( ) )
RpcClearEnv()

Return xRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fCarrSG1 �Autor  � Vin�cius Moreira   � Data � 28/08/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega os alias das tabelas envolvidas buscando informa-  ���
���          � ��o nas outras empresas.                                   ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCarrSG1( cCodPro, cAliasSG1, cEmpOri, cFilOri )

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

Return ( cAliasSG1 )->( !Eof( ) ) 
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fCarrSB1                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Carrega dados do produto da outra filial.                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vin�cius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 28/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function fCarrSB1( cCodPro, cAliasSB1, cEmpOri, cFilOri )

Local cQuery := ""

cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM SB1" + cEmpOri + "0 SB1 " + CRLF 
cQuery += "  WHERE SB1.B1_FILIAL  = '" + cFilOri + "' " + CRLF
cQuery += "    AND SB1.B1_COD     = '" + cCodPro + "' " + CRLF 
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' " + CRLF 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasSB1,.F.,.T.)

Return ( cAliasSB1 )->( !Eof( ) ) 