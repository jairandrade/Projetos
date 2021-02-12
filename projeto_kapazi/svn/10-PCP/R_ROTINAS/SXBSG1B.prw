#INCLUDE "protheus.ch"
#INCLUDE 'FWMVCDEF.CH'

User Function SXBSG1B()
Local lRet       := .F.
Local nRetorno   := 0
Local aSearch    := {"G1_COMP","B1_DESC"}
Local cQuery     := ""

cQuery := " SELECT DISTINCT TOP 10000 (G1_COMP) G1_COMP,B1_DESC AS B1_DESC,(SELECT TOP 1 R_E_C_N_O_ FROM SG1040  WHERE D_E_L_E_T_ = '' AND G1_COMP = SG1.G1_COMP)  AS RECNO 
cQuery += " FROM "+RetSqlName("SG1")+" SG1 " 
cQuery += " INNER JOIN SB1010 SB1 ON SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' AND SB1.B1_MSBLQL <> '1' 
cQuery += " WHERE SG1.D_E_L_E_T_ = '' AND SG1.G1_COD = '"+ M->ZB2_COD+"' "

If F3SG1PASS( cQuery, "TMPG1B", "RECNO"    , @nRetorno,, aSearch, "SG1" )
     SG1->(dbGoto(nRetorno))
     lRet := .T.
EndIf

Return(lRet)


Static Function F3SG1PASS( cQuery, cCodCon, cCpoRecno, nRetorno, aCoord, aSearch, cAlias )
Local aArea       := GetArea()
Local aCampos     := {}
Local aProdF3     := {}
Local aStru       := {}
Local aSeek	  	  := {}
Local aIndex      := {}
Local cIdBrowse   := ''
Local cIdRodape   := ''
Local cTrab       := GetNextAlias()
Local lRet        := .F.
Local nAt         := 0
Local nI          := 0
Local oBrowse, oColumn, oDlg, oBtnOk, oBtnCan, oTela, oPnlBrw, oPnlRoda
Local aCamposFilt := {}
Local cTitCpo     :=  ''
Local cPicCpo     :=  ''
Local cNomeTab	  := ""
Local aCoors := MsAdvSize()

DEFAULT cQuery    := ""
DEFAULT cCodCon   := ""
DEFAULT cCpoRecno := ""
DEFAULT nRetorno  := 0
DEFAULT aCoord    := { 0, 0, 390,815 }
DEFAULT aSearch   := {}
DEFAULT cAlias	  := ""
//aCoord    := aCoors
//Verifica se o alias existe no dicionário de dados
If !Empty(cAlias)
    dbSelectArea("SX2")
    dbSetOrder(1)
	If !dbSeek(cAlias)
		cAlias := ""
	Else
		cNomeTab := X2Nome()
	EndIf
EndIf

//-------------------------------------------------------------------
// Indica as chaves de Pesquisa
//-------------------------------------------------------------------
//[1] - Nome do Campo
//[2] - Titulo do Campo
//[3] - Tipo do Campo
//[4] - Tamanho do Campo
//[5] - Casas decimais
//-------------------------------------------------------------------
If !Empty (aSearch)
	For nI:= 1 to Len(aSearch)
		aAdd( aIndex, aSearch[nI] )
		aAdd( aSeek, { AvSX3(aSearch[nI],5), {{"",AvSX3(aSearch[nI],2),AvSX3(aSearch[nI],3),AvSX3(aSearch[nI],4),AvSX3(aSearch[nI],5),,}} } )

		If nI == 1
			//cQuery += " ORDER BY "+aSearch[nI]
		EndIf
	Next
EndIf

Define MsDialog oDlg FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Title "Consulta Padrão" + " - " + cNomeTab Pixel Of oMainWnd		//"Consulta Padrão"
nAt := aScan( aProdF3, { | aX | aX[1] == PadR( cCodCon, 10 ) } )

oTela     := FWFormContainer():New( oDlg )
cIdBrowse := oTela:CreateHorizontalBox( 85 )
cIdRodape := oTela:CreateHorizontalBox( 15 )
oTela:Activate( oDlg, .F. )

oPnlBrw   := oTela:GeTPanel( cIdBrowse )
oPnlRoda  := oTela:GeTPanel( cIdRodape )

If !Empty( cCodCon )

	If nAt == 0
		aAdd( aProdF3, { PadR( cCodCon, 10 ) , cQuery, {} } )
	Else
		cQuery  := aProdF3[nAt][2]
	EndIf

EndIf

//-------------------------------------------------------------------
// Define o Browse
//-------------------------------------------------------------------
  Define FWBrowse oBrowse DATA QUERY ALIAS cTrab DOUBLECLICK { || lRet := .T., nRetorno := (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), oDlg:End() }  QUERY cQuery FILTER SEEK ORDER aSeek INDEXQUERY aIndex Of oPnlBrw
  //DOUBLECLICK { || lRet := .T., nRetorno := (cTrab)->( FieldGet( FieldPos( cCpoRecno ) ) ), oDlg:End() } ;

//DEFINE FWBROWSE oBrowse DATA QUERY ALIAS "TRBX" QUERY cQry   FILTER SEEK ORDER aSeek INDEXQUERY aIndex OF oDlg

//-----------------------------------------------------------------
// Monta Estrutura de campos
//-------------------------------------------------------------------
If !Empty( cCodCon )

	If nAt == 0

		aStru := ( cTrab )->( dbStruct() )

		For nI := 1 To Len( aStru )

			//-------------------------------------------------------------------
			// Campos
			//-------------------------------------------------------------------
			// Estrutura do aFields
			//				[n][1] Campo
			//				[n][2] Título
			//				[n][3] Tipo
			//				[n][4] Tamanho
			//				[n][5] Decimal
			//				[n][6] Picture
			//-------------------------------------------------------------------

			cTitCpo := aStru[nI][1]
			cPicCpo := ''

			If AvSX3( aStru[nI][1],, cTrab, .T. )
				cTitCpo := RetTitle( aStru[nI][1] )
				cPicCpo := AvSX3( aStru[nI][1], 6, cTrab )

				If cPicCpo $ '@!'
					cPicCpo := ''
				EndIf
			EndIf

			If !PadR( cCpoRecno, 15 ) == PadR( aStru[nI][1], 15 )
				aAdd( aCampos, { aStru[nI][1], cTitCpo,  aStru[nI][2], aStru[nI][3], aStru[nI][4], cPicCpo } )
			EndIf

		Next

		If !Empty( cCodCon )
			aProdF3[Len( aProdF3 )][3] := aCampos
		EndIf

	Else
		aCampos := aClone( aProdF3[nAt][3] )
	EndIf

EndIf

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
For nI := 1 To Len( aCampos )
	ADD COLUMN oColumn DATA &( '{ || ' + aCampos[nI][1] + ' }' ) Title aCampos[nI][2]  PICTURE aCampos[nI][6] Of oBrowse
Next

//-------------------------------------------------------------------
// Adiciona as colunas do Filtro
//-------------------------------------------------------------------
oBrowse:SetFieldFilter( aCampos )
oBrowse:SetUseFilter()

//-------------------------------------------------------------------
// Ativação do Browse
//-------------------------------------------------------------------
Activate FWBrowse oBrowse

@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 003 Button oBtnOk  Prompt "Ok" Size 25, 12 Of oPnlRoda Pixel Action ( lRet := .T., nRetorno := ( cTrab )->( FieldGet( FieldPos( cCpoRecno ) ) ) , oDlg:End() )	//"Ok"
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 033 Button oBtnCan Prompt "Cancelar"  Size 25, 12 Of oPnlRoda Pixel Action ( lRet := .F., oDlg:End() )		//"Cancelar"
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 063 Button oBtnCan Prompt "Visualizar" Size 25, 12 Of oPnlRoda Pixel Action ( IIf( !Empty(cAlias) .And. ((cTrab)->(FieldGet(FieldPos(cCpoRecno))) > 0), Tk510VisCad( cAlias, (cTrab)->(FieldGet(FieldPos(cCpoRecno)))), .T. ) )	//"Visualizar"

//-------------------------------------------------------------------
// Ativação do janela
//-------------------------------------------------------------------
Activate MsDialog oDlg Centered

RestArea( aArea )

Return lRet

