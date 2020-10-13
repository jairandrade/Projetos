#Include "Protheus.ch"
#Include "FwCommand.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "TbiConn.CH"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM003                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Copia das toler�ncias.                                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vin�cius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/ 

User Function COM003( )

Local cEmpBkp		:= cEmpAnt
Local cFilBkp		:= cFilAnt
Local oWizard 		:= FWWizardControl( ):New( )
Local oStep
Local oBrowReg, oBrowFil
Local oTmpReg , oTmpFil
Local cAliasRes		:= ""
Private cAliasQry	:= GetNextAlias( )
Private cFornDe		:= Space( TamSx3("AIC_FORNEC")[1])
Private cFornAte	:= Space( TamSx3("AIC_FORNEC")[1])
Private cLojaDe		:= Space( TamSx3("AIC_LOJA")[1])
Private cLojaAte	:= Space( TamSx3("AIC_LOJA")[1])

Private cFilDe	:= Space( Len( ADK->ADK_XFILI ) )
Private cNegDe	:= Space( Len( ADK->ADK_XNEGOC ) )
Private cSegDe	:= Space( Len( ADK->ADK_XSEGUI ) )

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Origem" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs( ) } )
oStep:SetPrevAction( { || Alert("Op��o inv�lida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "Toler�ncias" )
oStep:SetConstruction( { |oPanel| oTmpReg := fStep02( oPanel, oBrowReg := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpReg:GetAlias( ) ) } )
oStep:SetPrevAction( { || Alert("Op��o inv�lida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Filiais" )
oStep:SetConstruction( { |oPanel| oTmpFil := fStep03( oPanel, oBrowFil := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpFil:GetAlias( ) ) } )
oStep:SetPrevAction( { || Alert("Op��o inv�lida."), .F. } )
oStep:SetNextTitle( "Avan�ar" )

oStep := oWizard:AddStep( "4" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| fStep04( oPanel, oTmpReg, oTmpFil, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( cAliasRes ), .T. } )
oStep:SetPrevAction( { || Alert("Op��o inv�lida."), .F. } )
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

cEmpAnt	:= cEmpBkp
cFilAnt := cFilBkp
SM0->( dbSeek( cEmpAnt + cFilAnt ) )

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
TGet():New(nLinha    ,20, bSetGet(cFornDe)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2",cFornDe	,,,,,,,'Fornece.de'	,1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cLojaDe)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,""   ,cLojaDe	,,,,,,,'Loja de'	,1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFornAte)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2",cFornAte	,,,,,,,'Fornece.ate',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cLojaAte)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,""   ,cLojaAte	,,,,,,,'Loja ate'	,1,oPanel:oFont)

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
cQuery += "    AIC.AIC_CODIGO CODIGO " + CRLF 
cQuery += "   ,AIC.AIC_FORNEC CODFOR " + CRLF 
cQuery += "   ,AIC.AIC_LOJA   LOJFOR " + CRLF 
cQuery += "   ,SA2.A2_NOME    NOMFOR " + CRLF 
cQuery += "   FROM " + RetSQLName( "AIC" ) + " AIC " + CRLF 
cQuery += " LEFT OUTER JOIN " + RetSQLName( "SA2" ) + " SA2 ON " + CRLF 
cQuery += "        SA2.A2_FILIAL  = '" + xFilial( "SA2" ) + "' " + CRLF 
cQuery += "    AND SA2.A2_COD     = AIC.AIC_FORNEC " + CRLF 
cQuery += "    AND SA2.A2_LOJA    = AIC.AIC_LOJA " + CRLF 
cQuery += "    AND SA2.D_E_L_E_T_ = ' ' " + CRLF 
cQuery += "  WHERE AIC.AIC_FILIAL = '" + xFilial( "AIC" ) + "' " + CRLF 
cQuery += "    AND AIC.AIC_FORNEC BETWEEN '" + cFornDe + "' AND '" + cFornAte + "' " + CRLF 
cQuery += "    AND AIC.AIC_LOJA   BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "' " + CRLF 
cQuery += "    AND AIC.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  GROUP BY " + CRLF 
cQuery += "    AIC.AIC_CODIGO " + CRLF
cQuery += "   ,AIC.AIC_FORNEC " + CRLF 
cQuery += "   ,AIC.AIC_LOJA " + CRLF
cQuery += "   ,SA2.A2_NOME " + CRLF 
cQuery += "  ORDER BY " + CRLF 
cQuery += "    AIC.AIC_CODIGO " + CRLF
cQuery += "   ,AIC.AIC_FORNEC " + CRLF 
cQuery += "   ,AIC.AIC_LOJA " + CRLF
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
oMark:AddIndex( "01", { "CODIGO", "CODFOR", "LOJFOR" } )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

While ( cAliasQry )->( !Eof( ) )
	RecLock( cAliasAux, .T. )
		( cAliasAux )->OK 		:= .F.
		( cAliasAux )->CODIGO 	:= ( cAliasQry )->CODIGO
		( cAliasAux )->CODFOR 	:= ( cAliasQry )->CODFOR
		( cAliasAux )->LOJFOR	:= ( cAliasQry )->LOJFOR
		( cAliasAux )->NOMFOR	:= ( cAliasQry )->NOMFOR
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
	AddColumn({|| ( cAliasAux )->CODIGO 	},"Codigo"		, Len( ( cAliasAux )->CODIGO	), , "C") ,;
	AddColumn({|| ( cAliasAux )->CODFOR 	},"Cod.Forn."	, Len( ( cAliasAux )->CODFOR	), , "C") ,;
	AddColumn({|| ( cAliasAux )->LOJFOR		},"Loja"		, Len( ( cAliasAux )->LOJFOR	), , "C") ,;
	AddColumn({|| ( cAliasAux )->NOMFOR		},"Nome"		, Len( ( cAliasAux )->NOMFOR	), , "C")  ;
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
		{"OK", "L", 1, 0},;
		{"EMPRESA", "C", Len( cEmpAnt ), 0},;
		{"FILIAL", "C", FWSizeFilial(), 0},;
		{"NOME", "C", 60, 0};
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
	AddColumn({|| ( cAliasRes )->CODIGO 	},"Codigo"		, Len( ( cAliasRes )->CODIGO	), , "C") ,;
	AddColumn({|| ( cAliasRes )->CODFOR 	},"Cod.Forn."	, Len( ( cAliasRes )->CODFOR	), , "C") ,;
	AddColumn({|| ( cAliasRes )->LOJFOR		},"Loja"		, Len( ( cAliasRes )->LOJFOR	), , "C") ,;
	AddColumn({|| ( cAliasRes )->NOMFOR 	},"Nome"		, Len( ( cAliasRes )->NOMFOR	), , "C") ,;
	AddColumn({|| ( cAliasRes )->FILIAL 	},"Filial"		, FWSizeFilial( )				 , , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"	, 150							 , , "C")  ;
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
Static aAICFields := { }
Static Function fProcRegs( nRegs, cAliasReg, aFilDes )

Local cMsg			:= ""
Local cMsgLog 		:= ""
Local nSucesso		:= 3
Local aAllRegs		:= { }
Local nPosPrd		:= 0
Local nAux			:= 0
Local cEmpAtu		:= ""

ProcRegua( nRegs+1 )
IncProc( "Agrupando toler�ncias..." )
( cAliasReg )->( dbGoTop( ) )
While ( cAliasReg )->( !Eof( ) )
	IncProc( "Processando toler�ncia " + ( cAliasReg )->CODIGO )
	
	cEmpAtu := ( cAliasReg )->EMPRESA
	If ( cAliasReg )->EMPRESA == cEmpAnt
		cAux := fProcAll( ( cAliasReg )->CODIGO, ( cAliasReg )->FILIAL, ( cAliasReg )->EMPRESA, cEmpAnt, cFilAnt, cAliasReg )
	Else
		xAux := StartJob("U_COM003Job", GetEnvServer( ), .T., ( cAliasReg )->EMPRESA, ( cAliasReg )->FILIAL, cEmpAnt, cFilAnt, cAliasReg )
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
Static Function fProcAll( cCodigo, cFilDes, cEmpDes, cEmpAtu, cFilAtu, cAliasReg )

Local lRet		:= .T.
Local cEmpBkp	:= cEmpAnt	
Local cFilBkp 	:= cFilAnt
Local nModBkp	:= nModulo
Local nX 		:= 1
Local aDadAIC	:= { }
Local aRotAnt	:= If( Type( "aRotina" ) != "U", AClone( aRotina ), { } )
Local cCodPro	:= ""
Local cGrpPro	:= ""
Local cMsgLog	:= ""
Local cAliasAIC	:= GetNextAlias( )
Default cEmpAtu	:= cEmpAnt
Default cFilAtu	:= cFilAnt
Private aRotina	:= StaticCall( COMA020, MenuDef )

cMsgLog += "Processando toler�ncia " + cCodigo + CRLF

If Len( aAICFields ) == 0
	aAICFields := fGetFields( "AIC", , )
EndIf

//AIC->( dbSetOrder( 1 ) )	//AIC_FILIAL+AIC_CODIGO
fCarrAlias( cCodigo, @cAliasAIC, cEmpAtu, cFilAtu )
If (cAliasAIC)->(!Eof())
	cCodPro := (cAliasAIC)->AIC_PRODUT
	cGrpPro := (cAliasAIC)->AIC_GRUPO
	aDadAIC := fMntDados( cAliasAIC, aAICFields )
	nModulo := 2
	cFilAnt := cFilDes
	SM0->( dbSeek( cEmpAnt + cFilAnt ) )
	cMsgLog += "*Verificando cadastros auxiliares no destino "  + cFilDes + CRLF
	SB1->( dbSetOrder( 1 ) )	//B1_FILIAL+B1_COD
	
	If !Empty( cCodPro ) .And. !SB1->( dbSeek( xFilial( "SB1" ) + cCodPro ) )
		lRet := .F.
		cMsgLog += "Erro: Produto nao encontrado no destino " + cFilDes + CRLF
		//DisarmTransaction( )
	Else
		SBM->( dbSetOrder( 1 ) )	//BM_FILIAL+BM_GRUPO
		If !Empty( cGrpPro ) .And. !SBM->( dbSeek( xFilial( "SBM" ) + cGrpPro ) )
			lRet := .F.
			cMsgLog += "Erro: Grupo do produto n�o encontrado no destino " + cFilDes + CRLF
			//DisarmTransaction( )
		Else
			Begin Transaction
			AIC->( dbSetOrder( 1 ) )	//AIC_FILIAL+AIC_CODIGO
			If AIC->( dbSeek( xFilial( "AIC" ) + cCodigo ) )
				cMsgLog += "*Deletando toler�ncia existente na filial " + cFilDes + CRLF 
				RecLock( "AIC", .F. )
					AIC->( dbDelete( ) )
				AIC->( MsUnlock( ) )
				cMsgLog += "-->OK " + CRLF 
			EndIf
			
			If lRet .And. !fCpyEstru( cCodigo, aDadAIC, @cMsgLog )
				lRet := .F.
				DisarmTransaction( )
			EndIf
			End Transaction
		EndIf
	EndIf
EndIf
nModulo	:= nModBkp
aRotina := aRotAnt

RecLock( cAliasReg, .F. )
	If lRet
		( cAliasReg )->SUCESSO	:= 1
		( cAliasReg )->MSG		:= "Gravado com sucesso."
	Else
		( cAliasReg )->SUCESSO	:= 2
		( cAliasReg )->MSG		:= "Ocorreram erros durante o processamento."
	EndIf
	( cAliasReg )->MSGLOG 	:= cMsgLog
( cAliasReg )->( MsUnlock( ) )

cEmpAnt := cEmpBkp
cFilAnt := cFilBkp 
SM0->( dbSeek( cEmpAnt + cFilAnt ) )

Return cMsgLog
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
Static Function fGerTmpRes( oTmpReg, oTmpFil )
Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"CODIGO"	, "C", Len( AIC->AIC_CODIGO )	, 0},;
						{"CODFOR"	, "C", Len( AIC->AIC_FORNEC ) 	, 0},;
						{"LOJFOR"	, "C", Len( AIC->AIC_LOJA )		, 0},;
						{"NOMFOR"	, "C", Len( SA2->A2_NOME )		, 0},;
						{"EMPRESA"	, "C", Len( cEmpAnt )			, 0},;
						{"FILIAL"	, "C", FWSizeFilial()			, 0},;
						{"SUCESSO"	, "N", 1						, 0},;
						{"MSGLOG"	, "M", 80						, 0},;
						{"MSG"		, "C", 150						, 0}	}
	
While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela tempor�ria no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","EMPRESA+FILIAL+CODIGO+CODFOR+LOJFOR"))

//--Insere produtos a criar nas empresas/filiais
cInsert := "INSERT INTO " +cAliasRes +" (SUCESSO, EMPRESA, FILIAL, CODIGO, CODFOR, LOJFOR, NOMFOR) "
cInsert += "SELECT 3, FILS.EMPRESA, FILS.FILIAL, REGS.CODIGO, REGS.CODFOR, REGS.LOJFOR, REGS.NOMFOR "
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
Static Function fCpyEstru( cCodigo, aDadAIC, cMsgLog )

Local nX			:= 0
Local nOpcX			:= 3
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "COM003_i_" + AllTrim( cCodigo ) + "_" + AllTrim( cFilAnt ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Default cMsgLog		:= ""
Private lMsErroAuto	:= .T.
Private INCLUI 		:= nOpcX == 3
Private ALTERA 		:= nOpcX == 4
Private EXCLUI 		:= nOpcX == 5

cMsgLog += "*Criando toler�ncias na filial " + cFilAnt + CRLF
If RecLock( "AIC", .T. )
	AIC->AIC_FILIAL := xFilial( "AIC" )
	For nX := 1 to Len( aDadAIC )
		If AllTrim( aDadAIC[ nX, 1 ] ) != "AIC_FILIAL"
			AIC->&( aDadAIC[ nX, 1 ] ) := aDadAIC[ nX, 2 ]
		EndIf
	Next nX
	AIC->( MsUnlock( ) )
	cMsgLog += "-->OK" + CRLF
Else
	cMsgLog += "-->Problemas durante grava��o." + CRLF
	lMsErroAuto	:= .F.	
EndIf

Return lMsErroAuto
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
Static Function fGetFields( cAliasAtu, cNotShow, cYesShow )

Local aRet 			:= { }
Local cCampo		:= ""
Default cNotShow	:= ""
Default cYesShow	:= ""

dbSelectArea( "SX3" )
SX3->( dbSetOrder( 1 ) )//X3_ARQUIVO
If SX3->( dbSeek( cAliasAtu ) )
	While SX3->( !Eof( ) ) .And. SX3->X3_ARQUIVO == cAliasAtu
		cCampo := AllTrim( SX3->X3_CAMPO ) + "|"
		If !cCampo $ cNotShow 
			If ( !Empty( cYesShow ) .And. cCampo $ cYesShow ) .Or. ( Empty( cYesShow ) .And. /*X3Uso( SX3->X3_USADO ) .And.*/ SX3->X3_CONTEXT != "V" )  
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
���Programa  � fCriaDir �Autor  � Vin�cius Moreira   � Data � 29/07/2015  ���
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
���Programa  � fChkCpos �Autor  � Vin�cius Moreira   � Data � 26/03/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Checa ordem dos campos para execu��o do MsExecAuto.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � COM003Job�Autor  � Vin�cius Moreira   � Data � 29/08/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta ambiente pra execu��o do JOB.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function COM003Job( cEmpDes, cFilDes, cEmpAtu, cFilAtu, cTabelaReg )

Local xRet 		:= "FIM"
Local cAliasTmp	:= GetNextAlias( )

RpcSetType( 3 )
RpcSetEnv( cEmpDes, cFilDes, , , "EST" )

dbUseArea( .T., "TOPCONN", cTabelaReg, cAliasTmp, .T. )
dbSetIndex( cTabelaReg + "1" )
( cAliasTmp )->( dbSetOrder( 1 ) )
( cAliasTmp )->( dbSeek( cEmpDes ) )

While ( cAliasTmp )->( !Eof( ) )  .And. ( cAliasTmp )->EMPRESA == cEmpAnt
	fProcAll( ( cAliasTmp )->CODIGO, ( cAliasTmp )->FILIAL, ( cAliasTmp )->EMPRESA, cEmpAtu, cFilAtu, cAliasTmp )
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
���Programa  �fCarrAlias�Autor  � Vin�cius Moreira   � Data � 28/08/2018  ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega os alias das tabelas envolvidas buscando informa-  ���
���          � ��o nas outras empresas.                                   ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fCarrAlias( cCodigo, cAliasAIC, cEmpOri, cFilOri )

Local cQuery := ""

cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM AIC" + cEmpOri + "0 AIC " + CRLF 
cQuery += "  WHERE AIC.AIC_FILIAL  = '" + cFilOri + "' " + CRLF
cQuery += "    AND AIC.AIC_CODIGO  = '" + cCodigo + "' " + CRLF
cQuery += "    AND AIC.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  ORDER BY " + CRLF 
cQuery += "    AIC.R_E_C_N_O_ " + CRLF 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasAIC,.F.,.T.) 

Return 