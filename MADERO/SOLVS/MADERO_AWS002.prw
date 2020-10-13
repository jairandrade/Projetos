#include 'protheus.ch'
#include 'parmtype.ch'

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AWS002                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Rotina para visualizar Log de processos gerados por job                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Alterador por Márcio A. Zaguetti em 16/11/2019 para contemplar todos os prcessos de log das roti-!
! nas de integração do MADERO e para ajustar os log do processo de integração que não form tratados!
! no processo, conforme MIT044                                                                     !
+--------------------------------------------------------------------------------------------------+
*/     
User Function AWS002()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZWS")
	oBrowse:SetDescription("Log de Processos")
	oBrowse:SetMenuDef("MADERO_AWS002")
	oBrowse:Activate()

Return


Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	    ,'VIEWDEF.MADERO_AWS002',0,2,0,NIL})
	aAdd(aRotina,{'Historico de Log','U_AWS002HL'	        ,0,9,0,NIL}) 

Return( aRotina )




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ModelDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Definição do modelo de Dados                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/  

Static Function ModelDef()
Local oModel 
Local oStr1:= FWFormStruct(1,'ZWS')
	
	oModel := MPFormModel():New('MAIN_AWS002')
	oModel:SetDescription('Log de Processos')
	oModel:addFields('MODEL_ZWS',,oStr1)
	oModel:SetPrimaryKey({ 'ZWS_FILIAL', 'ZWS_PROCES', 'ZWS_DATA' })

Return oModel



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ModelDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Definição do interface                                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/  

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZWS')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZWS' , oStr1,'MODEL_ZWS' ) 
	oView:CreateHorizontalBox( 'BOX_ZWS', 100)
	oView:SetOwnerView('VIEW_ZWS','BOX_ZWS')

Return oView




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AWS002HL                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Exibe log anterior                                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/  
User Function AWS002HL()
Local oDlg
Local oFont 
Local cMemo   :="Sem detalhamento do log para o processo."+Chr(13)+Chr(10)+"Aguarde a execução do processo."
Local cQuery  :=""
Local cAliTmp0:=GetNextAlias()
Local nRecno  :=-1
Local nCount  :=0
Local aArea   := GetArea()
Local cDataAux:=""

	DbSelectArea("ZWL")	

	// -> Posiciona no detalhamento do log
	cQuery:="SELECT R_E_C_N_O_ REC, ZWL_DTPROC "
	cQuery+="FROM " + RetSQLName("ZWL") + " ZWL "
	cQuery+="WHERE ZWL.ZWL_FILIAL    = '" + ZWS->ZWS_FILIAL        + "' AND "   
	cQuery+="	   ZWL.ZWL_XFILIA    = '" + ZWS->ZWS_XFILIA        + "' AND "
	cQuery+="	   ZWL.ZWL_PROCES    = '" + ZWS->ZWS_PROCES        + "' AND "
	cQuery+="	   ZWL.ZWL_DTPROC   <= '" + DtoS(ZWS->ZWS_DTPROC)  + "' AND " 
	cQuery+="      ZWL.D_E_L_E_T_ <> '*'                                    "
	cQuery+="ORDER BY R_E_C_N_O_ DESC"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp0,.T.,.T.)
	
	// -> Pega o penúltimo registro processado
	(cAliTmp0)->(dbGoTop())
	cDataAux:=ZWL->ZWL_DTPROC
	nRecno:=(cAliTmp0)->REC
	// While !(cAliTmp0)->(eof())
	// 	nCount:=nCount+1
	// 	If nCount == 2
	// 		nRecno:=(cAliTmp0)->REC
	// 		Exit
	// 	Else
	// 		(cAliTmp0)->(DbSkip())
	// 		If cDataAux <> ZWL->ZWL_DTPROC
	// 			(cAliTmp0)->(DbSkip(-1))
	// 			nRecno:=(cAliTmp0)->REC
	// 			Exit
	// 		EndIf
	// 	EndIf	
	// EndDo
	(cAliTmp0)->(DbCloseArea())

	// -> Posiciona no detalhamnto do log
	//If nRecno > -1 .and. nCount == 2
	ZWL->(DbGoTo(nRecno))
	cMemo:=ZWL->ZWL_DETAL	
	//EndIf

	// -> Monta janela para exibição do log

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15

	DEFINE MSDIALOG oDlg TITLE "Log detail" From 3,0 to 340,600 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 290,140 OF oDlg PIXEL 
	oMemo:bRClicked := { | | AllwaysTrue( ) }
	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,155 TYPE 1 ACTION oDlg:End( ) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER
	
	RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fMntDadosºAutor  ³ Vinícius Moreira   º Data ³ 07/05/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Auxilia na montagem do vetor do ExecAuto.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMntDados( cAliasAtu, aFields )

Local aRet	:= { }
Local nC	:= 0

For nC := 1 to Len( aFields )
	If ( cAliasAtu )->( FieldPos( aFields[ nC, 1 ] ) ) > 0 .And. !Empty( ( cAliasAtu )->&( aFields[ nC, 1 ] ) )
		If aFields[ nC, 2 ] == "D"
			AAdd( aRet, { aFields[ nC, 1 ], SToD( ( cAliasAtu )->&( aFields[ nC, 1 ] ) ), Nil } )
		ElseIf aFields[ nC, 2 ] == "L"
			AAdd( aRet, { aFields[ nC, 1 ], "T" $ ( cAliasAtu )->&( aFields[ nC, 1 ] ), Nil } )
		Else
			AAdd( aRet, { aFields[ nC, 1 ], ( cAliasAtu )->&( aFields[ nC, 1 ] ), Nil } )
			If AllTrim(aFields[ nC, 1 ]) == "B1_CODBAR" //-- Retira o dígito verificador (será adicionado pelo gatilho do MATA010
				aTail(aRet)[2] := PadR(aTail(aRet)[2],Len(AllTrim(aTail(aRet)[2]))-1)
			EndIf
		EndIf
	EndIf
Next nC

Return aRet