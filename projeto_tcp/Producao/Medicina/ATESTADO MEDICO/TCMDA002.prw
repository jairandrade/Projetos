#include "protheus.ch"
#include "fwMvcDef.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} TCMDA002
Verifica atestados do mesmo CID. 
@author Kaique Mathias
@since 15/04/2020
@return lRet Boolean Indica se há informação atestado com o mesmo grupo de CID no período.
/*/
//-------------------------------------------------------------------------------
User Function TCMDA002()

	Local lRet		:= .T.
	Local lExistAte := .F.
	Local cIndPro	:= '2'
	Local nQntDias  := 60
	Local nY 		:= 0
	Local aArea		:= GetArea()
	Local aAreaTNY	:= TNY->( GetArea() )
	Local nDiasAt	:= 0
	//Utilização do Modelo e Grid.
	Local oModel 	:= FWModelActive() //Ativa modelo utilizado.
	Local oGrid
	Local nLenGrid 	:= 0

	If AliasInDic("TYZ")
		oGrid 	:= oModel:GetModel( 'TYZDETAIL' ) //Posiciona no Model da Grid
		nLenGrid:= oGrid:Length()
	EndIf

	If ( cIndPro <> "1" .And. !Empty( oModel:GetValue( 'TNYMASTER1', 'TNY_CID' ) ) ) 

		dbSelectArea( "TNY" )
		dbSetOrder( 9 ) //TNY_FILIAL+TNY_CID+TNY_NUMFIC
		TNY->(dbSeek( xFilial( "TNY" ) + SubS(oModel:GetValue( 'TNYMASTER1', 'TNY_CID' ),1,3) + oModel:GetValue( 'TNYMASTER1', 'TNY_NUMFIC' ) ))
		While TNY->( !Eof() ) .And. xFilial( "TNY" ) == TNY->TNY_FILIAL 	.And. ;
			  SubS(oModel:GetValue( 'TNYMASTER1', 'TNY_CID' ),1,3) == SubS(TNY->TNY_CID,1,3) 	.And. ;
			  oModel:GetValue( 'TNYMASTER1', 'TNY_NUMFIC' ) == TNY->TNY_NUMFIC

			If ( oModel:GetValue( 'TNYMASTER1', 'TNY_NATEST' ) <> TNY->TNY_NATEST ) //.And. oModel:GetValue( 'TNYMASTER1', 'TNY_EMITEN' ) == TNY->TNY_EMITEN //Verifica se o numero do atestado é diferente, caso contrário deixa preencher por causa da Continuação.
				If ( TNY->TNY_DTINIC + nQntDias ) >= oModel:GetValue( 'TNYMASTER1', 'TNY_DTINIC' )
					nDiasAt += Val(TNY->TNY_QTDTRA)
				EndIf
			EndIf
			TNY->( dbSkip() )
		End

		If ( nDiasAt >= 15 )
			If ( cIndPro == "2" ) //Questiona
				lRet := MsgYesNo( "Este funcionário possui atestado(s) maior ou igual a 15 dias nos ultimos 60 dias para o grupo de CID " + AllTrim( SubS(TNY->TNY_CID,1,3) ) + "." + " Deseja incluir um novo atestado mesmo assim?" )
			ElseIf ( cIndPro == "3" ) //Bloqueia
				ShowHelpDlg( "ATENÇÃO" ,	{"Este funcionário possui atestado(s) maior ou igual a 15 dias nos ultimos 60 dias para o grupo de CID " + AllTrim( SubS(TNY->TNY_CID,1,3) ) + "."} , 2 ,;
				{ "Favor alterar o atestado e informar novo período de afastamento." } ,2 ) 
				lRet := .F.
			EndIf
		EndIf

	EndIf

	RestArea( aArea )
	RestArea( aAreaTNY )

Return( lRet )