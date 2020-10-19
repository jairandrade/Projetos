#include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} MFAT003
Rotina para alterar numero de nfs-e e autorizacao da prefeitura
@author  FELIPE CALDEIRA
@since   05/12/2016
/*/

User Function MFAT003()

Private cCadastro 	:= "Alteracao Numero NFS-e e Autorizacao"
Private aRotina 	:= {}
Private cAlias 		:= "SF2"
	
	AADD(aRotina,{"Pesquisar"  , "AxPesqui"   	,0,1})  
	AADD(aRotina,{"Visualizar" , "AxVisual" 	,0,2})
	AADD(aRotina,{"Alterar"   , "U_MFAT003A" 	,0,4})
		
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,)
	

Return   
              
User Function MFAT003A(cAlias,nReg,nOpc)			
	Local aObjects  	:= {} 
	Local aPosObj   	:= {} 
	Local aSizeAut  	:= MsAdvSize()             
	Local aButtons 		:= {}            

	Private cCadastro 	:= 'Alteração NFS-e' 
	Private oGet
	Private cCodAtu  	:= SF2->F2_CODNFE
	Private cNfeleAtu 	:= SF2->F2_NFELETR
	Private cDoc   		:= SF2->F2_DOC
	Private cSerie 		:= SF2->F2_SERIE
	static oDlgI           	

	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
	@ 005, 005 group oGrpCabec to 055, 505 prompt ' Alteração Numero NFS-e ' of oDlgI	color 0,16777215 pixel
	@ 017, 010 say 'Fatura	' 				size 053, 010 pixel  
	@ 015, 065 get cDoc		 				size 040, 010 when .F. pixel 	
	@ 017, 120 say 'Serie	' 				size 053, 010 pixel  
	@ 015, 175 get cSerie 					size 040, 010 when .F. pixel 	
	@ 032, 010 say 'Numero NFS-e	' 		size 053, 010 pixel  
	@ 030, 065 get cNfeleAtu 				size 040, 010 when .T. pixel 	
	@ 032, 120 say 'Num. Autorizacao	' 	size 053, 010 pixel  
	@ 030, 175 get cCodAtu 					size 100, 010 when .T. pixel 	
	
	ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(CONFIRMAR(nOpc),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))
	
Return .T.


Static Function Confirmar(nOpc)
Local cQuerySF2 := ""
Local cQuerySF3 := ""
Local cQuerySFT := ""

	cCodNfe  := SF2->F2_CODNFE
	cNfeletr := SF2->F2_NFELETR

	cQuerySF2  := "UPDATE "+RetSqlName("SF2")+" SET F2_NFELETR = '"+Alltrim(cNfeleAtu)+"', F2_CODNFE = '"+Alltrim(cCodAtu)+"' WHERE F2_FILIAL = '"+SF2->F2_FILIAL+"' AND F2_DOC = '"+SF2->F2_DOC+"' AND F2_SERIE = '"+SF2->F2_SERIE+"' AND D_E_L_E_T_ != '*' ""
	cQuerySF3  := "UPDATE "+RetSqlName("SF3")+" SET F3_NFELETR = '"+Alltrim(cNfeleAtu)+"', F3_CODNFE = '"+Alltrim(cCodAtu)+"' WHERE F3_FILIAL = '"+SF2->F2_FILIAL+"' AND F3_NFISCAL = '"+SF2->F2_DOC+"' AND F3_SERIE = '"+SF2->F2_SERIE+"' AND D_E_L_E_T_ != '*' "
	cQuerySFT  := "UPDATE "+RetSqlName("SFT")+" SET FT_NFELETR = '"+Alltrim(cNfeleAtu)+"', FT_CODNFE = '"+Alltrim(cCodAtu)+"' WHERE FT_FILIAL = '"+SF2->F2_FILIAL+"' AND FT_NFISCAL = '"+SF2->F2_DOC+"' AND FT_SERIE = '"+SF2->F2_SERIE+"' AND FT_NFELETR = '"+Alltrim(cNfeletr)+"' AND FT_CODNFE = '"+Alltrim(cCodNfe)+"' AND D_E_L_E_T_ != '*' "
	cQueryS051 := "UPDATE [TOTVS_TSS_NFSE].[dbo].[SPED051] SET NFSE = '"+Alltrim(cNfeleAtu)+"', NFSE_PROT = '"+Alltrim(cCodAtu)+"' WHERE RPS_TSS = '"+SF2->F2_DOC+"' AND SRPS_TSS = '"+SF2->F2_SERIE+"' "
	
	TcSqlExec(cQuerySF2)
	TcSqlExec(cQuerySF3)
	TcSqlExec(cQuerySFT)
	TcSqlExec(cQueryS051)

Return .T.

