#Include "Protheus.ch"  
#Include "FwCommand.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "TBICONN.CH"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST004                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para replicar as regras por tipo de movimentação                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST004()

Local oWizard := FWWizardControl():New( )
Local oStep
Local oBrowReg, oBrowFil
Local oTmpReg , oTmpFil
Local cAliasRes		:= ""                                              
Private cAliasAux	:= ""
Private cAliasQry	:= GetNextAlias( )
Private cProdDe		:= Space(TamSx3("Z30_PROD")[1])
Private cProdAte	:= Space(TamSx3("Z30_PROD")[1])
Private cGrpDe		:= Space(TamSx3("Z30_GRPPRO")[1])
Private cGrpAte		:= Space(TamSx3("Z30_GRPPRO")[1])

Private cFilDe	:= Space( Len( ADK->ADK_XFILI ) )
Private cNegDe	:= Space( Len( ADK->ADK_XNEGOC ) )
Private cSegDe	:= Space( Len( ADK->ADK_XSEGUI ) )

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps( )

oStep := oWizard:AddStep( "1" )
oStep:SetStepDescription( "Origem" )
oStep:SetConstruction( { |oPanel| fStep01( oPanel )  })
oStep:SetNextAction( { || fGetRegs( ) } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oStep := oWizard:AddStep( "2" )
oStep:SetStepDescription( "Regras por tipo de movimento" )
oStep:SetConstruction( { |oPanel| oTmpReg := fStep02( oPanel, oBrowReg := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpReg:GetAlias( ) ) } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oStep := oWizard:AddStep( "3" )
oStep:SetStepDescription( "Filiais" )
oStep:SetConstruction( { |oPanel| oTmpFil := fStep03( oPanel, oBrowFil := FWBrowse( ):New( ) )  })
oStep:SetNextAction( { || fChkMarca( oTmpFil:GetAlias( ) ) } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

oStep := oWizard:AddStep( "4" )
oStep:SetStepDescription( "Processamento" )
oStep:SetConstruction( { |oPanel| fStep04( oPanel, oTmpReg, oTmpFil, @cAliasRes )  })
oStep:SetNextAction( { || fAllLog( cAliasRes ), .T. } )
oStep:SetPrevAction( {|| .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Avançar" )

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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FSTEP01                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Tela do 'passo 01' do processo                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fStep01(oPanel1)
Local nLinha := 10
Local oPanel

oPanel := TScrollBox():New(oPanel1,01,01, oPanel1:nHeight-10, oPanel1:nWidth-10)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

TGet():New(nLinha    ,20, bSetGet(cProdDe)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cProdDe	,,,,,,,'Produto de'	,1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cProdAte)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cProdAte	,,,,,,,'Produto ate',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cGrpDe)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cGrpDe	,,,,,,,'Grupo de'	,1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cGrpAte)	,oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cGrpAte	,,,,,,,'Grupo ate'	,1,oPanel:oFont)

nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cFilDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ADK2",cFilDe,,,,,,,'Filial',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cNegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZA",cNegDe,,,,,,,'Negocio',1,oPanel:oFont)
nLinha += 25
TGet():New(nLinha    ,20, bSetGet(cSegDe),oPanel, 120, 12 , "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"ZB",cSegDe,,,,,,,'Seguimento',1,oPanel:oFont)

Return 


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fGetRegs                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Busca os registros que devem ser replicados                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fGetRegs()
Local cQuery	:= ""
Local lRet		:= .F.

cQuery += "  SELECT " + CRLF
cQuery += "    Z30.Z30_ROTINA ROTINA   " + CRLF
cQuery += "   ,Z30.Z30_REGRA  REGRA    " + CRLF
cQuery += "   ,Z30.Z30_ID     ID       " + CRLF
cQuery += "   ,Z30.Z30_PROD   PRODUTO  " + CRLF
cQuery += "   ,Z30.Z30_DESCP  DESCPROD " + CRLF
cQuery += "   ,Z30.Z30_GRPPRO GRPPRO   " + CRLF
cQuery += "   ,Z30.Z30_DESCGR DESCGR   " + CRLF
cQuery += "  FROM " + RetSQLName("Z30") + " Z30 " + CRLF
cQuery += " WHERE Z30.Z30_FILIAL  = '" + xFilial( "Z30" ) + "' " + CRLF
cQuery += "   AND Z30.Z30_PROD    BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' " + CRLF
cQuery += "   AND Z30.Z30_GRPPRO  BETWEEN '" + cGrpDe  + "' AND '" + cGrpAte  + "' " + CRLF
cQuery += "   AND Z30.D_E_L_E_T_  = ' '    " + CRLF
cQuery += "  ORDER BY " + CRLF
cQuery += "    Z30.Z30_ROTINA " + CRLF
cQuery += "   ,Z30.Z30_PROD   " + CRLF
cQuery += "   ,Z30.Z30_GRPPRO " + CRLF
cAliasQry := MPSysOpenQuery( cQuery )
lRet := ( cAliasQry )->( !Eof( ) )
If !lRet
	Alert( "Não foram encontrados registros para processamento." )
EndIf

Return lRet      


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fStep02                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Monta tela do segundo passo                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fStep02(oPanel,oBrowse)
Local oMark 	:= FWTemporaryTable( ):New( )
Local aStruct 	:= ( cAliasQry )->( dbStruct( ) )

//--Inicio da montagem da tabela temporaria
//Acrescenta o campo de mark
AAdd( aStruct, { } )
AIns( aStruct, 1 )
aStruct[ 01 ] := { "OK", "L", 1, 0 }
oMark:SetFields( aStruct )

//Definindo indice
oMark:AddIndex( "01", { "ROTINA", "REGRA", "PRODUTO", "GRPPRO", "ID" } )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

While ( cAliasQry )->( !Eof( ) )
	RecLock( cAliasAux, .T. )
		( cAliasAux )->OK 			:= .F.
		( cAliasAux )->ROTINA 		:= ( cAliasQry )->ROTINA
		( cAliasAux )->REGRA 		:= ( cAliasQry )->REGRA
		( cAliasAux )->PRODUTO 		:= ( cAliasQry )->PRODUTO
		( cAliasAux )->DESCPROD   	:= ( cAliasQry )->DESCPROD
		( cAliasAux )->GRPPRO		:= ( cAliasQry )->GRPPRO
		( cAliasAux )->DESCGR	    := ( cAliasQry )->DESCGR
		( cAliasAux )->ID	        := ( cAliasQry )->ID
	( cAliasAux )->( MsUnlock( ) )
	( cAliasQry )->( dbSkip( ) )
EndDo
( cAliasQry )->( dbCloseArea( ) )
//Final da montagem da tabela temporaria
                                            
//Inicio do browser de exibição dos registros
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasAux )
oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse ) } )
oBrowse:SetColumns({;
	AddColumn({|| ( cAliasAux )->ROTINA 	},"Rotina"		, Len( ( cAliasAux )->ROTINA	), , "C") ,;
	AddColumn({|| ( cAliasAux )->REGRA 	    },"Regra"		, Len( ( cAliasAux )->REGRA	    ), , "C") ,;
	AddColumn({|| ( cAliasAux )->ID 	    },"ID"		    , Len( ( cAliasAux )->ID        ), , "C") ,;
	AddColumn({|| ( cAliasAux )->PRODUTO 	},"Produto"		, Len( ( cAliasAux )->PRODUTO	), , "C") ,;
	AddColumn({|| ( cAliasAux )->DESCPROD	},"Desc. Prod."	, Len( ( cAliasAux )->DESCPROD	), , "C") ,;
	AddColumn({|| ( cAliasAux )->GRPPRO 	},"Gru.Prod."	, Len( ( cAliasAux )->GRPPRO	), , "C") ,;
	AddColumn({|| ( cAliasAux )->DESCGR 	},"Desc. Grupo"	, Len( ( cAliasAux )->DESCGR	), , "C")  ;
})

oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })
oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibição dos registros

Return oMark


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fStep03                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Monta tela do terceiro passo                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fStep03(oPanel,oBrowse)
Local aSM0 		:= FWLoadSM0( )
Local oMark 	:= FWTemporaryTable( ):New( )
Local nI		:= 0

//--Inicio da montagem da tabela temporaria
oMark:SetFields({ ;
		{"OK"		, "L", 1				, 0},;
		{"EMPRESA"	, "C", Len( cEmpAnt )	, 0},;
		{"FILIAL"	, "C", FWSizeFilial( )	, 0},;
		{"NOME"		, "C", 60				, 0};
})

//Definindo indice
oMark:AddIndex("01", {"EMPRESA", "FILIAL"} )
oMark:Create( )
cAliasAux := oMark:GetAlias( )

//U_COM001A( @cAliasAux )
U_COM001A(@cAliasAux,,cNegDe,cFilDe,cSegDe)

//Final da montagem da tabela temporaria
//Inicio do browser de exibição das filiais
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
//Final do browser de exibição das filiais

Return oMark
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fStep04                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Monta tela do quarto passo                                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
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
//Inicio do browser de exibição dos registros
oBrowse:= FWBrowse( ):New( )
oBrowse:SetDescription("")
oBrowse:SetOwner( oPanel )
oBrowse:SetDataTable( .T. )
oBrowse:SetAlias( cAliasRes )
oBrowse:AddStatusColumns( { || If( ( cAliasRes )->SUCESSO == 1 , 'BR_VERDE', If( ( cAliasRes )->SUCESSO == 2, 'BR_VERMELHO', 'BR_AMARELO') ) } )
oBrowse:SetColumns({;
	AddColumn({|| ( cAliasRes )->ROTINA 	},"Rotina"		, Len( ( cAliasRes )->ROTINA	), , "C") ,;
	AddColumn({|| ( cAliasRes )->REGRA    	},"Regra"		, Len( ( cAliasRes )->REGRA	    ), , "C") ,;
	AddColumn({|| ( cAliasRes )->ID 		},"ID"	        , Len( ( cAliasRes )->ID 		), , "C") ,;
	AddColumn({|| ( cAliasRes )->PRODUTO 	},"Produto"		, Len( ( cAliasRes )->PRODUTO	), , "C") ,;
	AddColumn({|| ( cAliasRes )->DESCPROD	},"Desc. Prod."	, Len( ( cAliasRes )->DESCPROD	), , "C") ,;
	AddColumn({|| ( cAliasRes )->GRPPRO 	},"Gru.Prod."	, Len( ( cAliasRes )->GRPPRO	), , "C") ,;
	AddColumn({|| ( cAliasRes )->DESCGR 	},"Desc.Grupo"	, Len( ( cAliasRes )->DESCGR	), , "C") ,;
	AddColumn({|| ( cAliasRes )->FILIAL 	},"Filial"		, FWSizeFilial( )				 , , "C") ,;
	AddColumn({|| ( cAliasRes )->MSG		},"Msg.Erro"	, 150							 , , "C")  ;
})
oBrowse:SetDoubleClick({|| fShowErro( ( cAliasRes )->MSGLOG ) })
oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:DisableFilter()
oBrowse:Activate()
//Final do browser de exibição dos registros

Return 


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fProcRegs                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa gravação dos registros                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fProcRegs(nRegs,cAliasReg)
Local cMsg		:= ""
Local cMsgLog	:= ""
Local nSucesso	:= 3
Local aFields	:= {}
Local aData		:= {}                            
Local cChavZ30	:= ""
Local lRet		:= .T.
Local cAux		:= ""
Local nPos		:= 0
Local nAux		:= 0
Local xAux		:= Nil

DbSelectArea("Z30")
aFields:={"Z30_FILIAL","Z30_ROTINA","Z30_PROD","Z30_DESCP","Z30_GRPPRO","Z30_DESCGR","Z30_USUAR","Z30_DESCUS","Z30_GRUSU","Z30_DESCGU","Z30_ID","Z30_REGRA"}

IncProc("Incluindo regras por produto..." )
(cAliasReg)->(dbGoTop())   
While ( cAliasReg )->( !Eof( ) )
	If ( nPos := AScan( aData, {|x,y| x[1] == ( cAliasReg )->EMPRESA .And. x[2] == ( cAliasReg )->FILIAL } ) ) == 0
		AAdd( aData, {	( cAliasReg )->EMPRESA,;
						( cAliasReg )->FILIAL,;
						{ } } )
		nPos := Len( aData )
	EndIf
	
	AAdd( aData[nPos,3], {	( cAliasReg )->ROTINA,;
							( cAliasReg )->REGRA,;
							( cAliasReg )->PRODUTO,;
							( cAliasReg )->GRPPRO,;
							( cAliasReg )->ID,;
							( cAliasReg )->( Recno( ) ) } )
	
	( cAliasReg )->( dbSkip( ) )
EndDo

For nPos := 1 to Len( aData )
	IncProc("Processando regras para empresa " + aData[nPos,1] + "/" + aData[nPos,2])
	
	If aData[nPos,1] == cEmpAnt
		cAux := fProcAll( aData[nPos,3], aData[nPos,1], aData[nPos,2], cEmpAnt, cFilAnt, cAliasReg )
	Else
		xAux := StartJob("U_EST004Job", GetEnvServer( ), .T., aData[nPos,3], aData[nPos,1], aData[nPos,2], cEmpAnt, cFilAnt, cAliasReg )
		If ValType( xAux ) != "L" .Or. !xAux
			Alert( "Problemas durante gravacao dos dados na empresa " + aData[nPos,1] + "/" + aData[nPos,2] + "." )
			Exit
		EndIf
	EndIf 
	
Next nPos

/*
	IncProc("Incluindo regras por produto..." )
	(cAliasReg)->(dbGoTop())   
	While (cAliasReg)->(!Eof())
	
		IncProc("Processando regras para o processo " + AllTrim((cAliasReg)->ROTINA) + " na filial " + AllTrim((cAliasReg)->FILIAL))
		ProcRegua(nRegs+1)
		
		If (cAliasReg)->EMPRESA == cEmpAnt
			cAux := fProcAll( (cAliasReg)->ROTINA, (cAliasReg)->REGRA, (cAliasReg)->PRODUTO, (cAliasReg)->GRPPRO, (cAliasReg)->ID, (cAliasReg)->EMPRESA, (cAliasReg)->FILIAL, cEmpAnt, cFilAnt )
		Else
			cAux := StartJob("U_EST004Job", GetEnvServer( ), .T., (cAliasReg)->ROTINA, (cAliasReg)->REGRA, (cAliasReg)->PRODUTO, (cAliasReg)->GRPPRO, (cAliasReg)->ID, (cAliasReg)->EMPRESA, (cAliasReg)->FILIAL, cEmpAnt, cFilAnt )
		EndIf 
		cMsgLog += SubStr( cAux, 3 )
		cAux	:= SubStr( cAux, 1, 2 ) 
                                                  
		If cAux == "OK"
			nSucesso 	:= 1 
			cMsg		:= "Gravado com sucesso."
		Else
			nSucesso 	:= 2
			cMsg		:= "Ocorreram erros durante o processamento."
		EndIf            
					
		RecLock(cAliasReg,.F.)
		(cAliasReg)->SUCESSO:= nSucesso
		(cAliasReg)->MSG	:= cMsg
		(cAliasReg)->MSGLOG := cMsgLog
		(cAliasReg)->(MsUnlock())
		
		cMsgLog	:= ""
		cMsg	:= ""
		nSucesso:= 3

		(cAliasReg)->(dbSkip())

	EndDo
*/

Return 



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AddColumn                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Criação das colunas                                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fGerTmpRes                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Monta TMP de resultados                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function fGerTmpRes(oTmpReg,oTmpFil)
Local cAliasRes	:= GetNextAlias()
Local cInsert	:= ""
Local aCampos	:= {	{"ROTINA"	, "C", TamSx3("Z30_ROTINA")[1]  , 0},;
						{"ID"		, "C", TamSx3("Z30_ID")[1]	    , 0},;
						{"REGRA"	, "C", TamSx3("Z30_REGRA")[1]	, 0},;
						{"PRODUTO"	, "C", TamSx3("Z30_PROD")[1]    , 0},;
						{"DESCPROD" , "C", TamSx3("Z30_DESCP")[1]   , 0},;
						{"GRPPRO"	, "C", TamSx3("Z30_GRPPRO")[1]  , 0},;
						{"DESCGR"	, "C", TamSx3("Z30_DESCGR")[1]  , 0},;
						{"EMPRESA"	, "C", Len( cEmpAnt )			, 0},;
						{"FILIAL"	, "C", FWSizeFilial()			, 0},;
						{"SUCESSO"	, "N", 1						, 0},;
						{"MSGLOG"	, "M", 80						, 0},;
						{"MSG"		, "C", 150                      , 0}	}
	
While MsFile(cAliasRes,,"TOPCONN")
	cAliasRes := GetNextAlias()
End

//--Cria tabela temporária no banco de dados
FWDBCreate(cAliasRes,aCampos,"TOPCONN",.T.)
dbUseArea(.T.,"TOPCONN",cAliasRes,cAliasRes,.T.)
(cAliasRes)->(DBCreateIndex(cAliasRes+"1","EMPRESA+FILIAL+ROTINA+REGRA+PRODUTO+GRPPRO+ID"))

//--Insere produtos a criar nas empresas/filiais
cInsert := "INSERT INTO " +cAliasRes +" (SUCESSO, EMPRESA, FILIAL, ROTINA, ID, REGRA, PRODUTO, DESCPROD, GRPPRO, DESCGR) "
cInsert += "SELECT 3, FILS.EMPRESA, FILS.FILIAL, REGS.ROTINA, REGS.ID, REGS.REGRA, REGS.PRODUTO, REGS.DESCPROD, REGS.GRPPRO, REGS.DESCGR "
cInsert += "FROM " +oTmpReg:GetRealName() +" REGS, " +oTmpFil:GetRealName() +" FILS "
cInsert += "WHERE REGS.OK = 'T' AND FILS.OK = 'T'"

If TCSQLExec(cInsert) < 0
	Conout(TCSQLError())
EndIf

Return cAliasRes
/*                                                                                
Static Function fGerTmpRes( cAliasReg, aFilDes )
Local oTmpRes	:= FWTemporaryTable( ):New( )
Local nX		:= 0 

//--Inicio da montagem da tabela temporaria
//Acrescenta o campo de mark
oTmpRes:SetFields({ ;
		{"ROTINA"	, "C", TamSx3("Z30_ROTINA")[1]  , 0},;
		{"ID"		, "C", TamSx3("Z30_ID")[1]	    , 0},;
		{"REGRA"	, "C", TamSx3("Z30_REGRA")[1]	, 0},;
		{"PRODUTO"	, "C", TamSx3("Z30_PROD")[1]    , 0},;
		{"DESCPROD" , "C", TamSx3("Z30_DESCP")[1]   , 0},;
		{"GRPPRO"	, "C", TamSx3("Z30_GRPPRO")[1]  , 0},;
		{"DESCGR"	, "C", TamSx3("Z30_DESCGR")[1]  , 0},;
		{"EMPRESA"	, "C", Len( cEmpAnt )			, 0},;
		{"FILIAL"	, "C", FWSizeFilial()			, 0},;
		{"SUCESSO"	, "N", 1						, 0},;
		{"MSGLOG"	, "M", 80						, 0},;
		{"MSG"		, "C", 150                      , 0};
	})
	
//Definindo indice
oTmpRes:AddIndex( "01", { "FILIAL", "ROTINA", "REGRA", "PRODUTO", "GRPPRO", "ID" } )
oTmpRes:Create( )
cAliasRes := oTmpRes:GetAlias( )
While ( cAliasReg )->( !Eof( ) )
	If ( cAliasReg )->OK
		For nX := 1 to Len( aFilDes )
			RecLock( cAliasRes, .T. )
				( cAliasRes )->ROTINA 		:= ( cAliasReg )->ROTINA
				( cAliasRes )->ID    		:= ( cAliasReg )->ID
				( cAliasRes )->REGRA 		:= ( cAliasReg )->REGRA
				( cAliasRes )->PRODUTO 		:= ( cAliasReg )->PRODUTO
				( cAliasRes )->DESCPROD 	:= ( cAliasReg )->DESCPROD
				( cAliasRes )->GRPPRO	    := ( cAliasReg )->GRPPRO
				( cAliasRes )->DESCGR 		:= ( cAliasReg )->DESCGR
				( cAliasRes )->SUCESSO 		:= 3
				( cAliasRes )->EMPRESA		:= aFilDes[ nX, 1 ]
				( cAliasRes )->FILIAL		:= aFilDes[ nX, 2 ]
			( cAliasRes )->( MsUnlock( ) )
		Next nX
	EndIf
	( cAliasReg )->( dbSkip( ) )
EndDo
( cAliasReg )->( dbGoTop( ) )

Return oTmpRes



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fExclEstru                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica necessidade de exclusão dos registros do destino                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fExclEstru(cChvZ30, cEmpDes, cFilDes,cMsgLog)
Local aDados		:= { }
Local aDadSDW		:= { }
Local nOpcX			:= 5
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "EST004_e_" + AllTrim(cChvZ30) + "_" + AllTrim(cFilDes) + "_" + __cUserId + "_" + DToS(Date()) + "_" + StrTran(Time(), ":", "" ) + "_.txt"
Local cAliasZ30		:= GetNextAlias()
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.

// -> Posiciona no registro a ser excluído
//Z30->(DbSetOrder(5))
//If Z30->(DbSeek(cFilDes+cChvZ30))
fCarrAlias( , , , , , @cAliasZ30, cEmpDes, cFilDes, cChvZ30 )
If (cAliasZ30)->(!Eof())
	Z30->( dbGoTo( (cAliasZ30)->R_E_C_N_O_ ) )
	// -> Exclui o cadastro no destino
	cMsgLog += "*Excluindo registro no destino. " + CRLF
	If RecLock("Z30",.F.)
		Z30->(DbDelete())	    
		Z30->(MsUnlock()) 
		lMsErroAuto	:= .F.
	Else
		lMsErroAuto	:= .T.   
	EndIf
 
	// -> Registra o log 
	If lMsErroAuto
		//fCriaDir(cPathTmp)
		//MostraErro(cPathTmp,cArqTmp)
		cMsgLog += "Erro: Problemas durante exclusao do registro"
		cMsgLog += "Erro: " + MemoRead( cPathTmp + cArqTmp )
		cMsgLog += CRLF + CRLF
		FErase( cPathTmp + cArqTmp )
	Else
		cMsgLog += "-->OK" + CRLF
	EndIf                        
EndIf
(cAliasZ30)->(dbCloseArea())	 	

Return !lMsErroAuto     


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fCpyEstru                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Copia registros                                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fCpyEstru(cChvZ30,aFields,aData,cFilDes,cMsgLog)
Local cPathTmp		:= "\Copia_Filiais\"
Local cArqTmp 		:= "est004_i_" + AllTrim( cChvZ30 ) + "_" + AllTrim( cFilDes ) + "_" + __cUserId + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Local cAuxFil       := cFilAnt
Local nx            := 0
Default cMsgLog		:= ""
Private lMsErroAuto	:= .F.

// -> Inclui o cadastro no destino
cMsgLog += "*Incluindo registro no destino. " + CRLF
nModulo := 4
cFilAnt := cFilDes
SM0->( dbSeek( cEmpAnt + cFilDes ) )
DbSelectArea("Z30")                                           
Z30->(DbGotop())
If RecLock("Z30",.T.)
	For nx:=1 to Len(aFields)         
		If AllTrim(aFields[nx]) == "Z30_FILIAL"
			Z30->Z30_FILIAL := xFilial("Z30")
		Else
		    Z30->&(aFields[nx]):=aData[nx]
		EndIf
	Next nx
 	Z30->(MsUnlock()) 
	lMsErroAuto	:= .F.
Else
	lMsErroAuto	:= .T.   
EndIf
 
// -> Registra o log 
If lMsErroAuto
	//fCriaDir(cPathTmp)
	//MostraErro(cPathTmp,cArqTmp)
	//cMsgLog += "Erro: " + MemoRead( cPathTmp + cArqTmp )
	cMsgLog += "Erro: Problemas durante gravacao do registro"
	cMsgLog += CRLF + CRLF
	FErase( cPathTmp + cArqTmp )
Else
	cMsgLog += "-->OK" + CRLF
EndIf                        

nModulo := 4
cFilAnt := cAuxFil
SM0->( dbSeek( cEmpAnt + cAuxFil ) )

Return !lMsErroAuto


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fCriaDir                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cria diretorios utilizados pelo programa                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Static Function fCriaDir(cPatch, cBarra)	
Local lRet   := .T.
Local aDirs  := {}
Local nPasta := 1
Local cPasta := ""
Default cBarra	:= "\"                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando diretório de configurações de usuários.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fAllLog                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Auxilia na montagem do vetor do ExecAuto                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fShowErro                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Exibe erro em tela                                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fShowErro( cMemo )
Local oDlg
Local cMemo
Local cFile :=""
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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fChkMarca                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Checa se algum registro foi selecionado                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
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
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MarkAll                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para marcar/desmarcar todos os registros                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static function MarkAll(oBrowse)

(oBrowse:GetAlias())->( dbGotop() )
(oBrowse:GetAlias())->( dbEval({|| OK := !OK },, { || ! Eof() }))
(oBrowse:GetAlias())->( dbGotop() )

oBrowse:Refresh(.T.)

Return
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fProcAll                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa gravacao dos registros.                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 31/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/             
Static Function fProcAll( aDados, cEmpDes, cFilDes, cEmpAtu, cFilAtu, cAliasReg )

Local cEmpBkp	:= cEmpAnt
Local cFilBkp	:= cFilAnt
Local cMsgLog	:= ""
Local nSucesso	:= 3
Local aFields	:= {"Z30_FILIAL","Z30_ROTINA","Z30_PROD","Z30_DESCP","Z30_GRPPRO","Z30_DESCGR","Z30_USUAR","Z30_DESCUS","Z30_GRUSU","Z30_DESCGU","Z30_ID","Z30_REGRA"}
Local aData		:= {}
Local cAliasZ30	:= GetNextAlias( )                            
Local cChavZ30	:= ""
Local lRet		:= .T.
Local nPos		:= 0
Default cEmpAtu	:= cEmpAnt
Default cFilAtu	:= cFilAnt

cMsgLog += "Processando dados da filial " + cEmpDes + "/" + cFilDes + CRLF
Begin Transaction
cFilAnt := cFilDes
Z30->( dbSetOrder( 1 ) )//Z30_FILIAL+Z30_ROTINA+Z30_PROD+Z30_USUAR+Z30_ID
If Z30->( dbSeek( xFilial( "Z30" ) ) )
	cMsgLog += "Excluindo regras atuais da filial " + cEmpDes + "/" + cFilDes + CRLF
	While Z30->( !Eof( ) ) .And. Z30->Z30_FILIAL == xFilial( "Z30" )
		RecLock( "Z30", .F. )
			Z30->( dbDelete( ) )
		Z30->( MsUnlock( ) )
		Z30->( dbSkip( ) )
	EndDo
EndIf

For nPos := 1 to Len( aDados )
	cRotina	:= aDados[ nPos, 01 ]
	cRegra	:= aDados[ nPos, 02 ]
	cProduto:= aDados[ nPos, 03 ]
	cGrupo 	:= aDados[ nPos, 04 ]
	cId 	:= aDados[ nPos, 05 ]
	
	cMsgLog += " - Processando criacao da regra/produto/grupo/id (" + cRegra + "/" + cProduto + "/" + cGrupo + "/" + cId + ")" + CRLF
	fCarrAlias( cRotina, cRegra, cProduto, cGrupo, cId, @cAliasZ30, cEmpAtu, cFilAtu )
	If ( cAliasZ30 )->( !Eof( ) )
	
		aData:={(cAliasZ30)->Z30_FILIAL,;  //01
				(cAliasZ30)->Z30_ROTINA,;  //02
				(cAliasZ30)->Z30_PROD,  ;  //03
				(cAliasZ30)->Z30_DESCP, ;  //04
				(cAliasZ30)->Z30_GRPPRO,;  //05
				(cAliasZ30)->Z30_DESCGR,;  //06
				(cAliasZ30)->Z30_USUAR, ;  //07
				(cAliasZ30)->Z30_DESCUS,;  //08
				(cAliasZ30)->Z30_GRUSU, ;  //09
				(cAliasZ30)->Z30_DESCGU,;  //10
				(cAliasZ30)->Z30_ID,    ;  //11
				(cAliasZ30)->Z30_REGRA  ;  //12
		}	                                         
	    
	    cChavZ30 := (cAliasZ30)->( Z30_ROTINA + Z30_REGRA + Z30_PROD + Z30_GRPPRO + Z30_ID )
		cMsgLog += " * Verificando existencia do produto no destino." + CRLF 
		SB1->( dbSetOrder( 1 ) )	
		If !SB1->(dbSeek(xFilial("SB1")+(cAliasZ30)->Z30_PROD)) .And. AllTrim((cAliasZ30)->Z30_PROD) <> ""
			lRet := .F.
			cMsgLog += " * Produto não encontrado na filial " + cFilDes
			DisarmTransaction( )
			Exit
		/*
		ElseIf !fExclEstru(cChavZ30, cEmpDes, cFilDes,@cMsgLog)
			lRet := .F.
			DisarmTransaction()
			Exit
		*/
		ElseIf !fCpyEstru( cChavZ30, aFields, aData, cFilDes, @cMsgLog)
			lRet := .F.     
			DisarmTransaction()
			Exit
		EndIf
	EndIf
	( cAliasZ30 )->( dbCloseArea( ) )
Next nPos
End Transaction

For nPos := 1 to Len( aDados )
	( cAliasReg )->( dbGoTo( aDados[ nPos, 6 ] ) )
	RecLock(cAliasReg,.F.)
	If lRet
		(cAliasReg)->SUCESSO:= 1
		(cAliasReg)->MSG	:= "Gravado com suscesso."
	Else
		(cAliasReg)->SUCESSO:= 2
		(cAliasReg)->MSG	:= "Ocorreram erros durante o processamento."
	EndIf
	(cAliasReg)->MSGLOG := cMsgLog
	(cAliasReg)->(MsUnlock())
Next nPos

cEmpAnt	:= cEmpBkp
cFilAnt	:= cFilBkp

Return cMsgLog
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EST004JobºAutor  ³ Vinícius Moreira   º Data ³ 29/08/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta ambiente pra execução do JOB.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EST004Job( aData, cEmpDes, cFilDes, cEmpAtu, cFilAtu, cTabelaReg )

Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias( )

RpcSetType( 3 )
RpcSetEnv( cEmpDes, cFilDes, , , "EST" )

dbUseArea( .T., "TOPCONN", cTabelaReg, cAliasTmp, .T. )

fProcAll( aData, cEmpDes, cFilDes, cEmpAtu, cFilAtu, cAliasTmp )

( cAliasTmp )->( dbCloseArea( ) )
RpcClearEnv()

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
Static Function fCarrAlias( cRotina, cRegra, cProduto, cGrupo, cId, cAliasZ30, cEmpOri, cFilOri, cChavZ30, cFilDes )

Local cQuery		:= ""
Local cFilAux		:= xFilial( "Z30" )
Default cChavZ30 	:= ""
Default cFilDes		:= ""

If !Empty( cFilAux )
	cFilAux := SubStr( cFilOri, 1, Len( AllTrim( cFilAux ) ) )
EndIf

If !Empty( cChavZ30 )
	cRotina 	:= SubStr( cChavZ30, 1, Len( Z30->Z30_ROTINA ) )
	cChavZ30	:= SubStr( cChavZ30, Len( Z30->Z30_ROTINA )+1 )
	
	cRegra 		:= SubStr( cChavZ30, 1, Len( Z30->Z30_REGRA ) )
	cChavZ30	:= SubStr( cChavZ30, Len( Z30->Z30_REGRA )+1 )
	
	cProduto 	:= SubStr( cChavZ30, 1, Len( Z30->Z30_PROD ) )
	cChavZ30	:= SubStr( cChavZ30, Len( Z30->Z30_PROD )+1 )
	
	cGrupo 		:= SubStr( cChavZ30, 1, Len( Z30->Z30_GRPPRO ) )
	cChavZ30	:= SubStr( cChavZ30, Len( Z30->Z30_GRPPRO )+1 )
	
	cId 		:= SubStr( cChavZ30, 1, Len( Z30->Z30_ID ) )
	cChavZ30	:= SubStr( cChavZ30, Len( Z30->Z30_ID )+1 )
EndIf

cQuery := "  SELECT " + CRLF 
cQuery += "    * " + CRLF 
cQuery += "   FROM Z30" + cEmpOri + "0 Z30 " + CRLF 
cQuery += "  WHERE Z30.Z30_FILIAL = '" + cFilAux + "' " + CRLF 
cQuery += "    AND Z30.Z30_ROTINA = '" + cRotina 	+ "' " + CRLF
cQuery += "    AND Z30.Z30_REGRA  = '" + cRegra 	+ "' " + CRLF
cQuery += "    AND Z30.Z30_PROD   = '" + cProduto 	+ "' " + CRLF
cQuery += "    AND Z30.Z30_GRPPRO = '" + cGrupo 	+ "' " + CRLF
cQuery += "    AND Z30.Z30_ID     = '" + cId 		+ "' " + CRLF 
cQuery += "    AND Z30.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  ORDER BY " + CRLF 
cQuery += "    Z30.R_E_C_N_O_ " + CRLF 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery), cAliasZ30,.F.,.T.)

Return ( cAliasZ30 )->( !Eof( ) )