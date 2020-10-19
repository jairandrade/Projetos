#include "protheus.ch"
#include "rwmake.ch"
#include "apwizard.ch"  
#include "topconn.ch"

//itens
#define __PRODUTO 1
#define __DESC 	  2
#define __VALOR	  3

//-------------------------------------------------------------------
/*/{Protheus.doc} MCOM018
Importa tabela de preços de compras, atualizando a tabela já selecionada.

@author Felipe Toazza Caldeira
@since 19/04/2017               
@version P11
/*/
//-------------------------------------------------------------------

User Function MCOM018()

Local bProcess 
Local cPerg := Padr("MCOM018",10)
Local oProcess

bProcess := {|oSelf| Executa(oSelf) }    
//cria as peguntas se não existe
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oProcess := tNewProcess():New("MCOM018","Atualização de tabela de preços!",bProcess,"Rotina para atualização de tabela de preços expecifica para TCP.",cPerg,,.F.,,, .T. )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Executa
Executa leitura do arquivo CSV.

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------
Static Function Executa(oProcess)

	Local cItens := alltrim(mv_par01)

	Local aItens := {}

	Private __data := DtoS(Date()) + "-" + STRTran(Time(),":","")

	Private cDiretory := ""

	//Valida o diretório para gravação dos erros
	cDiretory := alltrim(mv_par03)
	cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
	//valida o diretório
	If !ExistDir( cDiretory )
		Aviso("Diretório","Diretório '" + cDiretory + "' invalido.",{"Ok"},2)
		Return
	Endif

	IF !File(cItens)
		Aviso("Cabeçalho","Arquivo de itens '" + cItems + "' invalido.",{"Ok"},2)
		Return
	EndIF

	//leitura dos arquivos
	MSGRun("Fazendo a leitura do arquivo de Itens.","Itens",{|| aItens := SptFile(cItens) })

	//Processamento
	ProcItens( aItens, oProcess)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcItens
Realiza processamento dos itens.

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function ProcItens(aItens, oProc)
Local nAux 		:= 1  
Local lConf		:= .F.	   
Local lRet		:= .T.
Local s1
Private	aConfItens	:= {}
Private aAuxConf	:= {}         
Private aRelatCab	:= {}
Private	aRelatItens	:= {}		

Private lAutoErrNoFile := .T.  


	//Regua
	oProc:SetRegua1( len(aItens) )
	DbSelectArea('SB1')
	SB1->( dbSetOrder(1) )
	DbSelectArea('AIB')
	AIB->( dbSetOrder(2) )

    
	Begin Transaction

	For s1 := 1 to len(aItens)

		//Regua 1
		oProc:IncRegua1(cValtoChar(s1)+"/"+cValToChar(len(aItens))+ " -> " + aItens[s1][__PRODUTO]+' - '+ aItens[s1][__DESC])
	
		//Localiza o produto
		SB1->(DbGoTop())
		
		If !SB1->( dbSeek( xFilial("SB1") + aItens[s1][__PRODUTO] ) )
		   	AADD(aConfItens,{aItens[s1][__PRODUTO],'PRODUTO INEXISTENTE','INEXISTENTE','',0.00,0.00})
			Loop //go For->s1           
		Else
			AIB->(DbGoTop())                            
			nVAlAux := STRTRAN(aItens[s1][__VALOR],'.','')
			nValAux := Val(STRTRAN(nVAlAux,',','.'))				
			If AIB->(DbSeek(xFilial('AIB')+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB+aItens[s1][__PRODUTO]))    
				AADD(aConfItens,{aItens[s1][__PRODUTO],aItens[s1][__DESC],'ATUALIZAR',aItens[s1][2],AIB->AIB_PRCCOM,nValAux})
				UpdAIB(aItens[s1][__VALOR])
			Else    
				AADD(aConfItens,{aItens[s1][__PRODUTO],aItens[s1][__DESC],'INLCUIR',aItens[s1][2],0.00,nValAux})                  
				IncAIB(aItens[s1][__PRODUTO],aItens[s1][__VALOR])
			EndIf
		EndIF

	Next s1  
	   
	lConf := Confirmar(aItens)
	
	If !lConf     
		Alert('Atualização de preços não realizada!')
		DisarmTransaction() 
		lRet := .F. 
		//Return
	EndIf         
	
	End Transaction       
	
	If lRet
		RFAT009()	
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Cria grupo de perguntas, caso não exista

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

/*Static Function CriaSX1(cPerg)

//arquivos
//PutSx1(cPerg,"01","Arquivo Importação   ","","","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o diretório onde está o arquivo","com os itens para atualização.","",""},{"","","",""},{"","",""},"")
//Diretorio
//PutSx1(cPerg,"02","Diretório para erros?","","","mv_ch2","C",99,0,0,"G","","HSSDIR","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o diretório destino dos erros","desta importação","",""},{"","","",""},{"","",""},"")

Return*/


//-------------------------------------------------------------------
/*/{Protheus.doc} SptFile
Função para leitura e separação do arquivo

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function SptFile(cFile,lUltimaColuna)

	Local aRet   := {}
	Local aLinha := {}

	Default lUltimaColuna := .T.

	//Abre o arquivo
	FT_FUse(cFile)

	While !FT_FEof()

		//Leitura da linha do arquivo
		aLinha := Split( FT_FReadLn(), ";", lUltimaColuna )

		IF len(aLinha) != 0 
			If !Empty(Alltrim(aLinha[1]))
				aAdd( aRet, aClone(aLinha) ) 
			EndIf
		EndIF

		//pula linha
		FT_FSkip()

	EndDO

	//fecha arquivo texto
	FT_FUse()

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} Split
Função para realizar separação da string dom arquivo

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function Split(cLin,cSep,lUltimaColuna)

Local aPar := {}
Local nPos := ""

While At( cSep, cLin ) != 0
	nPos := At( cSep, cLin )
	aAdd( aPar, alltrim( Subs( cLin, 1, nPos-1 ) ) )
	cLin := Subs( cLin, nPos+len(cSep), len(cLin) )
EndDO

IF lUltimaColuna
	aAdd( aPar, alltrim( cLin ) )
EndIF

Return(aPar)         

//-------------------------------------------------------------------
/*/{Protheus.doc} IncDA1
Função para realizar inclusão do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function IncAIB(cCodPro,nValor)

	DbSelectArea('AIB')
	AIB->(DbSetOrder(2))
	AIB->(DbGoTop())
	If AIB->(DbSeek(xFilial('AIB')+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB+cCodPro))
		RecLock('AIB',.F.)
		AIB->AIB_PRCCOM := Val(STRTRAN(STRTRAN(nValor,'.',''),',','.'))
		AIB->(MsUnlock())						
	Else
		RecLock('AIB',.T.)
		AIB->AIB_FILIAL := xFilial('AIB')
		AIB->AIB_CODFOR := AIA->AIA_CODFOR
		AIB->AIB_LOJFOR := AIA->AIA_LOJFOR
		AIB->AIB_ITEM   := maxitem(AIA->AIA_CODTAB)  		
		AIB->AIB_CODTAB := AIA->AIA_CODTAB
		AIB->AIB_CODPRO := cCodPro
		AIB->AIB_PRCCOM := Val(STRTRAN(STRTRAN(nValor,'.',''),',','.'))
		AIB->AIB_QTDLOT := 999999.99
		AIB->AIB_INDLOT	:= '000000000999999.99'
		AIB->AIB_MOEDA	:= 1
		AIB->AIB_DATVIG := dDataBase 
		AIB->(MsUnlock())					
	EndIf
Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} maxitem
Função para realizar busca do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function maxitem(cTab)
Local cItem 	:= ""
Local cQuery 	:= ""

	cQuery := " SELECT MAX(AIB_ITEM) AS ITEM "
	cQuery += " FROM "+RetSqlName('AIB')
	cQuery += " WHERE "
	cQuery += " 	AIB_FILIAL = '"+xFilial('AIB')+"' AND AIB_CODTAB = '"+cTab+"' AND D_E_L_E_T_ != '*' "

	If (Select("QRYITEM") <> 0)
		DbSelectArea("QRYITEM")
		QRYITEM->(DbCloseArea())
	Endif
		
	TCQuery cQuery new Alias "QRYITEM"
    If !QRYITEM->(EOF())
		cItem := StrZero(Val(QRYITEM->ITEM)+1,4)
	Else
		cItem := '0001'
	EndIf 	

	QRYITEM->(DbCloseArea())

Return cItem     

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdDA1
Função para realizar alteração do item na tabela de preços

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function UpdAIB(nValor)

	RecLock('AIB',.F.)
	AIB->AIB_PRCCOM := Val(STRTRAN(STRTRAN(nValor,'.',''),',','.'))
	AIB->(MsUnlock())
                                           
Return                          

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirmar
Função para apresentar as alterações que serão feitas

@author Felipe Toazza Caldeira
@since 05/10/2015
@version P11
/*/
//-------------------------------------------------------------------

Static Function Confirmar(aItens)

Local lRet := .F.
Local aObjects  	:= {} 
Local aPosObj   	:= {} 
Local aSizeAut  	:= MsAdvSize()             
Local aButtons := {}            
			
Private cCadastro 	:= "Importação Tabela de Preços" 
Private oGet
Private nLen		:= 0    
		
static oDlgI           	



//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//                          
	aObjects := {} 
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects, .T. ) 

	DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL  
					
		@ 005, 005 group oGrpCabec to 270, 505 prompt 'Preços' of oDlgI	color 0,16777215 pixel
		GRIDCRIT(aItens)// cabecalho                                          
		

		ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| lRet := .T., oDlgI:end()}, {|| oDlgI:end()},,@aButtons))
	
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item 

@return 
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT(aItens)
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'B1_COD','B1_DESC','AIB_PRCCOM'}
	local aFieldFill	:= {}
	local aAlterFields	:= {}
	Local aField 		:= {}
	Local ni
	Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																			cField,;
																			X3PICTURE(cField),; 
																			TamSX3(cField)[1],;
																			TamSX3(cField)[2],;
																			GetSx3Cache(cField, "X3_VALID"),;
																			GetSx3Cache(cField, "X3_USADO"),;
																			FwSX3Util():GetFieldType(cField),;
																			X3F3(cField),;
																			GetSx3Cache(cField, "X3_CONTEXT"),;
																			X3CBOX(cField),;
																			GetSx3Cache(cField, "X3_RELACAO");
																			}))}


	aAdd(aFieldFill, "")
	aAdd(aFieldFill, "")
	aAdd(aFieldFill, 0.00)		

	 nAuxPos := 0
	
	aEval(aFields,bBlock)
	aHeader := aClone(aField)
	
	aAdd(aFieldFill, .f.)

	For ni :=  1 to Len(aConfItens)      
		aFieldFill[1] := aConfItens[nI][1]
		aFieldFill[2] := aConfItens[nI][2]
		aFieldFill[3] := aConfItens[nI][6]
		aFieldFill[Len(aHeader)+1] := .F. 	
   		aAdd(aCols,aClone(aFieldFill))		
	Next	
                         
	aRelatCab 	:= aClone(aHeader)
	aRelatItens	:= aClone(aCols)

 	oGet := MsNewGetDados():New( 020, 010, 265, 500,, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)	
                                           
Return                           

//-------------------------------------------------------------------
/*/{Protheus.doc} RFAT009
Relatório contendo o resultado da importação

@sample	ReportDef() 

@author	Felipe Toazza Caldeira
@since	28/09/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------       
Static Function RFAT009() 
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Configura o objeto TReport. 

@sample	ReportDef() 

@author	Felipe Toazza Caldeira
@since	28/09/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------   
Static Function ReportDef() 

Local cTituRel	:= "TCP - Importação de tabela de preços"
Local cDescRel 	:= "Este programa ira emitir o relatório "+cTituRel
Local aOrdem   	:= {} 
Local cPerg		:= "RFAT009"
Local oReport  
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oBreak1
Local oBreak2  
Local nI

oReport := TReport():New(cPerg,cTituRel,cPerg, {|oReport| ReportPrint(oReport)},cDescRel)   

oReport:SetPortrait()
oReport:SetTotalInLine(.F.) 
oReport:HideParamPage()
oReport:DisableOrientation()


oSection1 := TRSection():New(oReport,"Importação tabela de preços",{}) 

TRCell():New(oSection1, "PRODUTO"	,"SB1","Produto"	,"@!",TAMSX3("B1_COD")[1])	
TRCell():New(oSection1, "DESCRI"	,"SB1","Descrição"	,"@!",TAMSX3("B1_DESC")[1])	
TRCell():New(oSection1, "STATUS"	,"SB1","Status"		,"@!",TAMSX3("B1_CONTA")[1])				


For nI := 4 to Len(aRelatCab)
	TRCell():New(oSection1, Alltrim(STR(nI))	,"SB1",aRelatCab[nI][1]	,"@E 999,999.9999",14)				                                                            
	oSection1:Cell(Alltrim(STR(nI))):nHeaderAlign := 3	// Alinhamento da célula. 1-Esquerda, 2-Center ou 3-Direita.  
Next

Return oReport
                                

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de impressão do relatório.

@sample	ReportPrint(oReport)

@param	oReport - Objeto do tReport para impressão

@author Felipe Toazza Caldeira
@since	28/09/2015
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function ReportPrint(oReport)
    
	Local oSection1 := oReport:Section(1)				// Define a secao 1 do relatorio
    Local nK
    Local nJ                                     
    oReport:SetMeter(0)
  	oSection1:Init()
      
    oReport:SetTitle( oReport:Title()  )     
                  
	// Busca o total para impressão da primeira linha
	For nK := 1 to Len(aRelatitens)
		
		oReport:IncMeter() 
		
		If oReport:Cancel()
			Exit
		EndIf  
		
		oSection1:Cell("PRODUTO"):SetValue(aRelatitens[nK][1])
		oSection1:Cell("DESCRI"):SetValue(aRelatitens[nK][2])
		oSection1:Cell("STATUS"):SetValue(aRelatitens[nK][3])			 

		For nJ := 4 to len(aRelatCab)
			oSection1:Cell(Alltrim(STR(nJ))):SetValue(aRelatitens[nK][nJ])	
		Next		
		oSection1:PrintLine()

	Next	
	oSection1:Finish() 
	oReport:SkipLine(1)
				
Return        
