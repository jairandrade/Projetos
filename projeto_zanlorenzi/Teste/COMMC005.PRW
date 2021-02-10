#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"  
#include "Protheus.ch"                                                                                                                                   

#DEFINE __TAMLINHA 120

/*                                                                                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOMMC005  บAutor  ณCarlos Cleuber      บ Data ณ  28/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta arquivo para Confer๊ncia de EDI - ocorrencias       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function COMMC005()      
Private bVisual	:= {||fVisual()}
Private bImpConh	:= {||fImpCon()}
Private bImpOco	:= {||fImpOco()}  
Private bVisNFC	:=	{||fVisNFC()}
Private bLegenda	:= {||fLegend()}
Private bGerConh	:= {||U_fGrConh()}

Private cCadastro := "Ocorrencias de Conhecimento de Fretes"

Private aLegenda	:={	{"br_verde","Nใo Integrado com Financeiro"},;
								{"br_vermelho" ,"Integrado com Financeiro"},;
								{"br_preto"   ,"Recusado"}}					 

Private aCores		:= {	{"GXG->GXG_EDISIT == '1' ","br_verde"},; 		//Nao Integrado
								{"GXG->GXG_EDISIT == '2' ","br_vermelho"},;	//Integrado								
					 			{"GXG->GXG_EDISIT == '3'","br_preto"}}			//Recusado
					 			
Private aRotina2	:= {	{"Conhecimento"	,"eval(bImpConh)"	,0,3} ,;			             
								{"Ocorrencias"		,"eval(bImpOco)"	,0,3} }					 			

Private aRotina	:= {	{"Pesquisar"			,"AxPesqui"			,0,1} ,;
								{"Visualizar"			,"eval(bVisual)"	,0,2} ,;
								{"Importacao"			,aRotina2			,0,3},;
								{"Gera Conhec."		,"eval(bGerConh)"	,0,4},;
								{"Visual NF.Conhec"	,"eval(bVisNFC)"	,0,3},;
								{"Legenda"				,"eval(bLegenda)"	,0,3}}
								
Private cString := "GXG"

dbSelectArea("GXG")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return 


//-----------------------------------------------------------------------------------------------------------------
//Fun็ao Consulta NF
//Data: 25/06/2012
//Carlos Cleuber - CallSystem 		
Static Function fVisNFC() 
Local aTMP:= GetArea()
Local aSF1:= SF1->(GetArea())
Local aSD1:= SD1->(GetArea())  
Local aRotAnt:= aRotina

Private aRotina    := {{ ,"A103NFiscal", 0, 2}}
Private l103Auto   := .F.
Private aAutoCab   := {}
Private aAutoItens := {}   

If GXG->GXG_EDISIT == "1" .or. GXG->GXG_EDISIT == "3" // 1=Nใo Integrado 3=Rejeitado
	
	Alert("Conhecimento nao integrado !!!")

Else

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	SF1->(DbSeek(GXG->GXG_CHVSF1))
	
	DbSelectArea("SD1")
	SD1->( DbSetOrder( 1 ) )
	cSeekSd1:=SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	If SD1->( dbSeek( cSeekSD1 ) )
		A103NFiscal( "SF1", SF1->( Recno() ), 1 )
	Endif  
Endif


aRotina:= aRotAnt
RestArea(aSD1)
RestArea(aSF1)
RestArea(aTMP)

Return                 

//-----------------------------------------------------------------------------------------------------------------
User Function fShowCTE() // Funcao utilizada no RdMake FATCT011 - Painel Transportadoras
	fVisual()
Return

//-----------------------------------------------------------------------------------------------------------------
Static Function fVisual

Local nOpcx		:= 2
Local nOpca		:= 0
Local bOk    	:= {||nOpca:=1,oDlg:End()}
Local bCancel	:= {||nOpca:=2,oDlg:End()}
Local aExibe	:= {}
Local cAlias	:= "GXG"
Local nRecno	:= GXG->(recno())
Local nTipoOper:= 0

Private oDlg
Private oFolder
Private oGDNotas
Private oGDOco

Private aObjects  := {}
Private aInfo     := {}
Private aPosGet   := {}
Private aPosObj   := {}

Private aFolder	:=  {}
Private nFldNotas	:= 0

Private oNotas
Private cNotas	:= ""
Private aNotas	:= {}

Private cNRDC		:= space(08)
Private cSerDC		:= space(03)

RegToMemory("GXG")
RegToMemory("GXH")
RegToMemory("GXL")

nTipoOper:= 2
aExibe	:= fInitVarX3(cAlias," ",.F.)

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บMaximizacao da area de trabalho                                          บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
aSizeAut 	 := MsAdvSize()
//             100%(larg) , 145px(alt), %?  ,  %? 
//aAdd(aObjects,{100 		  , 059       ,.T.  , .F. })   // QUADRO DE CIMA
aAdd(aObjects,{100 		  , 145       ,.T.  , .F. })   // QUADRO DE CIMA
aAdd(aObjects,{100		  , 100       ,.T.  , .T. })   // QUADRO DE BAIXO

aInfo 	:= {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj := MsObjSize(aInfo,aObjects)
aPosGet := MsObjGetPos((aSizeAut[3]-aSizeAut[1]),315,{{004,024,260,270}} )


//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บCarrega o array contento o nome das guias (folder)                       บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
aAdd(aFolder	,"Notas Fiscais"					); nFldTorre := Len(aFolder)
aAdd(aFolder	,"Ocorrencias"						); nFldOcorre := Len(aFolder)

Define MsDialog oDlg From aSizeAut[7],aSizeAut[1] TO aSizeAut[6],aSizeAut[5] Title OemToAnsi('Conhecimentos de Transportes') Of oMainWnd Pixel

EnChoice(cAlias,nRecno,nTipoOper, , , ,aExibe,aPosObj[1],,3,,,,oDlg)
oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,{"HEADER"},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
oFolder:bSetOption:={|nIndo|fMudaGuia(nIndo,oFolder:nOption)}

// carrega getdados com os tipos de unidade
fNotas(nTipoOper, nFldTorre )
fOcorre(nTipoOper, nFldOcorre )

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

Return

//-----------------------------------------------------------------------------------------------------------------
Static Function fNotas(modo,nFolder)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nSuperior    	:= 002										// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 003										// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= aPosObj[2,3]-(aPosObj[2,1]+15)	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= aPosObj[2,4]-(aPosObj[2,2]+04)	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local nOpc         	:= 0		// GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinhaOk     	:= .T.										// Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= Nil										// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= "GXH_SEQ"								// Nome dos campos do tipo caracter que utilizarao incremento automatico.Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do segundo campo>+..."                                                               
Local nFreeze      	:= Nil										// Campos estaticos na GetDados.                                                               
Local nMax         	:= 999										// Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk     	:= Nil										// Funcao executada na validacao do campo                                           
Local cSuperApagar 	:= Nil										// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk			:= .T.										// Funcao executada para validar a exclusao de uma linha do aCols                   
Local aCpoItem			:= {}											// Array com os campos que deverใo ser tratados quando rotina de inclusใo
Local aHead        	:= {}											// Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}											// Array a ser tratado internamente na MsNewGetDados como aCols                      

cVrAlias := "GXH"
cOpcaoUt := modo
cOrdSeek := 1
cCndSeek := "xFilial('GXH')+M->GXG_NRIMP"
cCpoSeek := "GXH->GXH_FILIAL+GXH->GXH_NRIMP"
nQtdLnhs := 1

//Cria varias linhas em branco caso necessario
For x:=1 To nQtdLnhs
    aAdd(aCpoItem,{"GXH_SEQ"		,StrZero(x,4)	,.F.})
    aAdd(aCpoItem,{"GXH_SERDC"	,space(TamSX3("F1_SERIE")[1])	,.F.})
    aAdd(aCpoItem,{"GXH_NRDC"		,space(TamSX3("F1_DOC")[1])	,.F.})
Next x

aHead := faHead(cVrAlias)
aCols := faCols(aHead,cVrAlias,aCpoItem,nQtdLnhs,cOpcaoUt,cOrdSeek,cCndSeek,cCpoSeek)
oGDNotas := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oFolder:aDialogs[nFolder],aHead,aCols)                                   
oGDNotas:oBrowse:bChange:={||M101BPer()}  
oGDNotas:nAt:=1

Return  

Static FUNCTION M101BPer()  //Muda o Browse
Local nPos,lRet := .T.  

cNRDC		:= oGDNotas:aCols[oGDNotas:nAt][aScan(oGDNotas:aHeader,{|x|Alltrim(x[2])=="GXH_NRDC"   })]
cSerDC	:= oGDNotas:aCols[oGDNotas:nAt][aScan(oGDNotas:aHeader,{|x|Alltrim(x[2])=="GXH_SERDC"  })]

If ValType( oGDOco ) == "O"
	oGDOco:Refresh()                                                   	
Endif

Return lRet

//-----------------------------------------------------------------------------------------------------------------
Static Function fOcorre(modo,nFolder)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nSuperior    	:= 002										// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 003										// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= aPosObj[2,3]-(aPosObj[2,1]+15)	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= aPosObj[2,4]-(aPosObj[2,2]+04)	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local nOpc         	:= 0		// GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinhaOk     	:= .T.										// Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= Nil										// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""											// Nome dos campos do tipo caracter que utilizarao incremento automatico.Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do segundo campo>+..."                                                               
Local nFreeze      	:= Nil										// Campos estaticos na GetDados.                                                               
Local nMax         	:= 999										// Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk     	:= Nil										// Funcao executada na validacao do campo                                           
Local cSuperApagar 	:= Nil										// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk			:= .T.										// Funcao executada para validar a exclusao de uma linha do aCols                   
Local aCpoItem			:= {}											// Array com os campos que deverใo ser tratados quando rotina de inclusใo
Local aHead        	:= {}											// Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}											// Array a ser tratado internamente na MsNewGetDados como aCols                      

cNRDC		:= oGDNotas:aCols[oGDNotas:nAt][aScan(oGDNotas:aHeader,{|x|Alltrim(x[2])=="GXH_NRDC"   })]
cSerDC	:= oGDNotas:aCols[oGDNotas:nAt][aScan(oGDNotas:aHeader,{|x|Alltrim(x[2])=="GXH_SERDC"  })]
cVrAlias := "GXL"
cOpcaoUt := modo
cOrdSeek := 6 //GXL_FILIAL+GXL_NRDC+GXL_SERDC
cCndSeek := "xFilial('GXL')+'" + cNRDC + "'+'" + cSerDc +"'"
cCpoSeek := "GXL->GXL_FILIAL+GXL->GXL_NRDC+GXL->GXL_SERDC"
nQtdLnhs := 1

//Cria varias linhas em branco caso necessario
For x:=1 To nQtdLnhs
	aAdd(aCpoItem,{"GXL_FILIAL"	,space(05)		,.f.})
	aAdd(aCpoItem,{"GXL_NRIMP"		,space(16)		,.f.})
	aAdd(aCpoItem,{"GXL_CDTRP"		,space(14)		,.f.})
	aAdd(aCpoItem,{"GXL_DTOCOR"	,ctod("//")		,.f.})
	aAdd(aCpoItem,{"GXL_HROCOR"	,space(05)		,.f.})
	aAdd(aCpoItem,{"GXL_EMISDC"	,space(14)		,.f.})
	aAdd(aCpoItem,{"GXL_SERDC"		,space(03)		,.f.})
	aAdd(aCpoItem,{"GXL_NRDC"		,space(08)		,.f.})
	aAdd(aCpoItem,{"GXL_CODOCO"	,space(02)		,.f.})
	aAdd(aCpoItem,{"GXL_OBS"		,space(70)		,.f.})
	aAdd(aCpoItem,{"GXL_EDISIT"	,space(01)		,.f.})
	aAdd(aCpoItem,{"GXL_EDIMSG"	,space(10)		,.f.})
	aAdd(aCpoItem,{"GXL_EDINRL"	,0					,.f.})
	aAdd(aCpoItem,{"GXL_EDILIN"	,space(10)		,.f.})
	aAdd(aCpoItem,{"GXL_EDIARQ"	,space(200)		,.f.})
	aAdd(aCpoItem,{"GXL_DTIMP"		,ctod("//")		,.f.})
	aAdd(aCpoItem,{"GXL_CODOBS"	,space(02)		,.f.})
Next x

aHead := faHead(cVrAlias)
aCols := faCols(aHead,cVrAlias,aCpoItem,nQtdLnhs,cOpcaoUt,cOrdSeek,cCndSeek,cCpoSeek)
if ValType(oGDOco) != "O"
	oGDOco := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oFolder:aDialogs[nFolder],aHead,aCols)                                   
Else 
	oGDOco:= Nil
	oGDOco := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oFolder:aDialogs[nFolder],aHead,aCols)                                   	
	oGDOco:Refresh()
Endif

Return  

//-----------------------------------------------------------------------------------------------------------------
Static Function faHead(hcAlias)

Local haHead := {}

// Montagem do aHeader
SX3->(dbSetOrder(1))
SX3->(dbSeek(hcAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == hcAlias
		If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL)
			aAdd(haHead, {	AllTrim(X3Titulo())	,;
							SX3->X3_CAMPO		,;
							SX3->X3_PICTURE		,;
							SX3->X3_TAMANHO		,;
							SX3->X3_DECIMAL		,;
							SX3->X3_VALID		,;
							SX3->X3_USADO		,;
							SX3->X3_TIPO		,;
							SX3->X3_F3			,;
							SX3->X3_CONTEXT		,;
							SX3->X3_CBOX		,;
							SX3->X3_RELACAO		,;
							SX3->X3_WHEN		,;
							SX3->X3_VISUAL		,;
							SX3->X3_VLDUSER		,;
							SX3->X3_PICTVAR		,;
							SX3->X3_OBRIGAT		})
		EndIf	
		SX3->(DbSkip())
End

Return haHead 

//-----------------------------------------------------------------------------------------------------------------
Static Function faCols(haHead,hcAlias,haCampo,hnQtdLin,hcOpc,hcOrdSeek,hcCndSeek,hcCpoSeek)

Local haCol := {}

// Montagem do aCols com registros caso tenha
DbSelectArea(hcAlias)
DbSetOrder(hcOrdSeek)
If DbSeek(&(hcCndSeek))
	While !EOF() .And. &(hcCndSeek) == &(hcCpoSeek)
		
		AADD(haCol,Array(Len(haHead)+1))
		nLin	:= Len(haCol)
		
		x := 1
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(hcAlias))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == hcAlias
			If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
				haCol[nLin,x] := &(SX3->X3_CAMPO)
				x += 1
			EndIf
			SX3->(DbSkip())
		End
		
		haCol[nLin,Len(haHead)+1] := .F.
		DbSkip()
	End
EndIf

//Montagem de um acols em branco quando nenhum registro encontrado
If Len(haCol) == 0
   // Montagem do aCols em Branco
   For y := 1 To hnQtdLin
       
       AADD(haCol,Array(Len(haHead)+1))
       nLin	:= Len(haCol)
       x	:= 1
       
       SX3->(DbSetOrder(1))
       SX3->(DbSeek(hcAlias))
       While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == hcAlias
             If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
                lFoiTratado := .F.
                For k := 1 To Len(haCampo)
                    If haCampo[k,1] $ SX3->X3_CAMPO .And. !haCampo[k,3]
                       haCol[nLin,x] := haCampo[k,2]
                       haCampo[k,3]  := .T.
                       lFoiTratado   := .T.
                       k := Len(haCampo)
                    EndIf
                Next k
                If !lFoiTratado
                   If Empty(SX3->X3_RELACAO)
                      haCol[nLin,x] := CriaVar(SX3->X3_CAMPO)
                   Else
                      haCol[nLin,x] := &(SX3->X3_RELACAO)
                   EndIf
                EndIf
                x += 1
             EndIf
             SX3->(DbSkip())
       End
       
       haCol[nLin,Len(haHead)+1] := .F.
       
   Next y
EndIf

Return haCol


//-----------------------------------------------------------------------------------------------------------------
Static Function fInitVarX3(hcAlias,hcFolder,hlInitVarX3)

Local aXExibe := {}

SX3->(DbSetOrder(1))
SX3->(DbSeek(hcAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == hcAlias
      If SX3->X3_FOLDER $ hcFolder .And. X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
         If hlInitVarX3
            _SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
         Else
            If SX3->X3_CONTEXT != "V"
               _SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_CAMPO))
            Else
               _SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_RELACAO))
            EndIf
         EndIf
         AADD(aXExibe,SX3->X3_CAMPO)
      EndIf
      SX3->(DbSkip())
End

Return aXExibe 

//-----------------------------------------------------------------------------------------------------------------
Static Function fMudaGuia(nIndo,nEstou)
Local lRet:= .T.

Do Case

   Case nEstou == nFldTorre

   Case nEstou == nFldOcorre
		fOcorre(2,2)

EndCase

Do Case
   Case nIndo == nFldTorre

   Case nIndo == nFldOcorre
		fOcorre(2,2)

EndCase

Return lRet

//-----------------------------------------------------------------------------------------------------------------
Static Function fLegend()
brwlegenda("Status do Conhecimentos de Frete","Legenda",aLegenda)
return               

//-----------------------------------------------------------------------------------------------------------------
Static Function fImpCon()

U_COMMC002()

Return

//-----------------------------------------------------------------------------------------------------------------
User Function ImpConBA()

	U_COMMC002("04","01") 

Return

//-----------------------------------------------------------------------------------------------------------------
Static Function fImpOco( pEmpresa, pFilial )

Private cArq
Private nHandle
Private cBuffer
Private nBytesLidos
Private lError := .F.
Private oDlg,oList1,oConfirma,oImprime,oCancela
Private aConfere := {}
Private aOcorre	:= {}
Private aPerguntas := {}
Private cPerg    := "EDIRET" 

If Select("SX2") > 0

	cArq := cGetFile( '*.TXT |*.TXT | *.OCO |*.OCO',;
							"Selecione o arquivo a ser importado.", 1, "", .T.,;
							GETF_LOCALFLOPPY+;
							GETF_LOCALHARD+;
							GETF_NETWORKDRIVE )
	
	Processa({|| ImpArq(.F.)},"Lendo Arquivo")
	
	If ! lError 
		If len(aConfere) = 0
			aAdd(aConfere, {"","","","","Nใo Existem ocorrencias informadas","",""})
		Endif
		oDlg := MSDIALOG():Create()
		oDlg:cName := "oDlg"
		oDlg:cCaption := "Verifica็ใo das Ocorrencias EDI Retorno - Proceda - Ocoren"
		oDlg:nLeft := 0
		oDlg:nTop := 0
		oDlg:nWidth := 910 // 501
		oDlg:nHeight := 391 // 391
		oDlg:lShowHint := .F.
		oDlg:lCentered := .T.
	
	   oList1 := RDListBox(0.66,0.65,883,53,aConfere,{"N.Fiscal","Serie","Nome do Cliente","Ocorrencia","Descri็ใo"})
		oList1:lColDrag := .F.
		oList1:lJustific := .T.
		oList1:lAdjustColSize := .T.
		oList1:lVisibleControl := .T.
		oList1:aArray := aConfere
		oList1:nAt := 1
		oList1:nLeft := 2
		oList1:nTop  := 3
		oList1:nWidth  := 899 //489
		oList1:nHeight := 331
		
		oImprime := SBUTTON():Create(oDlg)
		oImprime:cName := "oImprime"
		oImprime:cCaption := "oSBtn3"
		oImprime:nLeft := 7 //220
		oImprime:nTop := 338  //337
		oImprime:nWidth := 52
		oImprime:nHeight := 22
		oImprime:lShowHint := .F.
		oImprime:lReadOnly := .F.
		oImprime:Align := 0
		oImprime:lVisibleControl := .T.
		oImprime:nType := 6
		oImprime:bAction := {|| Imprime() }
		
		oCancela := SBUTTON():Create(oDlg)
		oCancela:cName := "oCancela"
		oCancela:cCaption := "oSBtn4"
		oCancela:nLeft := 438
		oCancela:nTop := 339
		oCancela:nWidth := 52
		oCancela:nHeight := 22
		oCancela:lShowHint := .F.
		oCancela:lReadOnly := .F.
		oCancela:Align := 0
		oCancela:lVisibleControl := .T.
		oCancela:nType := 2
		oCancela:bAction := {|| Cancela() }
		
		oDlg:Activate()
		
	EndIf
Else 

	PREPARE ENVIRONMENT EMPRESA pEmpresa FILIAL pFilial //Tables  "SD2", "SB1", "SF2", "SA3", "SA1", "SF4", "SC6", "SC5" 
	
	cPasta := "C:\EDI\Recepcao\MBA\PATRUS\"
	aFiles := Directory(cPasta+"*.TXT")
	
	If Len(aFiles) > 0
	
		ProcRegua(Len(aFiles))
		
		For nI := 1 to Len(aFiles)
		
			cArq    := cPasta+alltrim(aFiles[nI][1])
			ImpArq(.T.)
			
			IncProc()
		
		Next nI
	Else 
		Return
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpArq    บAutor  ณRodrigo dos Santos  บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImpArq(pSrv) 

Local nLinha := 0


Private cCod		:= space(06)
Private cLoja		:= space(02)
Private cNomeCli	:= Space(40)
Private cDesOcor	:= Space(60)

ProcRegua(1000)

For nX:=len(cArq) to 1 step -1
	
	If substr(cArq,nX,1) == "\"
		cPath:= substr(cArq,1,nX)
		cNomeArq:= substr(cArq,Nx+1,Len(cArq))
		If len(cNomeArq) > 20
			cNomeAlt:= substr(cNomeArq,1,20)
		Else
			cNomeAlt:= cNomeArq
		Endif
		exit
	Endif
	
Next

If File(cArq)
	nHandle := FOpen(cArq)
	If nHandle > 0

		cBuffer := Space(__TAMLINHA+2)
		nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
		lOK:= .T.

		While (__TAMLINHA+2) == nBytesLidos

			IncProc("Leitura...")           
			nLinha++
			                                             
			If Substr(cBuffer,1,3) == "341"			
				
				cCGCTrans      := SubStr( cBuffer, 4, 14)
				DbSelectArea("SA4")
				SA4->(DbsetOrder(3))
				If !SA4->( DbSeek( xFilial("SA4") + cCGCTrans ) )  
					cMsg:="Cadastro da Transportadora nใo encontrado: " + CRLF + ;
							"CNPJ: " + Transform( cCGCTrans, "@R 99.999.999/9999-99" ) + CRLF +;
							"Transportadora: " + SA4->A4_NOME + CRLF + ;
							"Favor cadastrar."
					
					If pSrv
						Conout(cMsg)
					Else
						MsgBox( cMsg )
					Endif
					
					Return
				Else
					cTransp	:= SA4->A4_COD
				Endif
			
         ElseIf Substr(cBuffer,1,3) == "342"
            
				cCGCArq:= Substr(cBuffer,4,14)
            	
            If cCGCArq == SM0->M0_CGC
					
					cNrImp	:= GetSXENum("GXL","GXL_NRIMP")
					cNRDC		:= substr(cBuffer,21,8)
	           	cSERDC	:= strzero(val(substr(cBuffer,18,3)),03)
	           	cOcorre	:= substr(cBuffer,29,2) 
					dDatOco	:= ctod( substr(cBuffer,31,02)+"/"+substr(cBuffer,33,02)+"/"+substr(cBuffer,35,04) )
					cHorOco	:= substr(cBuffer,39,02) + ":" + substr(cBuffer,41,2)							           	
					
					cNrNf		:= substr(cBuffer,23,6)
   	        	cSerie	:= strzero(val(substr(cBuffer,18,3)),3)	           	
		   	        	
	           	If cSerie == "000"
	           		cSerie:= space(3)
	           	Endif					
	           	
	           	DbSelectArea("GXH")
	           	GXH->(DbSetOrder(2)) // GXH_FILIAL+GXH_NRDC+GXH_SERDC
	           	If ! GXH->(DbSeek(xFilial("GXH")+cNRDC+cSERDC, .T.))                                                                     
	           		If pSrv
	           			Conout(cNrNf+"/"+cSerie+"- Nota Fiscal nao exite na base de Conhecimentos Importados")
	           		Else
		           		aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Nota Fiscal nao exite na base de Conhecimentos Importados"} )   
		           	Endif
						lOK:= .F.
	           	Endif
	           	
					DbSelectArea("GXL")
					GXL->(DbSetOrder(5)) //GXL_FILIAL+DTOS(GXL_DTOCOR)+GXL_HROCOR+GXL_NRDC+GXL_SERDC+GXL_CODOCO
					If GXL->(DbSeek(xFilial("GXL")+dtos(dDatOco)+cHorOco+cNRDC+cSERDC+cOcorre, .T.))             
						If pSrv 
							Conout(cNrNf+"/"+cSerie+"- Ocorrencia ja existe no Arquivo")
						Else
							aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Ocorrencia ja existe no Arquivo"} )   
						Endif
					Else
					  
						If lOK
						
							cCod		:= GetAdvFVal("SF2","F2_CLIENTE",xFilial("SF2")+cNrNf+cSerie,1)
							cLoja		:= GetAdvFVal("SF2","F2_LOJA",xFilial("SF2")+cNrNf+cSerie,1)
							cNomeCli	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+cCod+cLoja,1)
							cDesOcor := GetAdvFVal("DT2","DT2_DESCRI",xFilial("DT2")+cOcorre,1)  
							If empty(cDesOcor)
								cDesOcor:= "Ocorrencia nao existe na Tabela DT2"
							Endif
						
							RecLock("GXL",.T.)
							GXL->GXL_FILIAL	:= xFilial("GXL")
							GXL->GXL_NRIMP		:= cNrImp
							GXL->GXL_CDTRP		:= cTransp
							GXL->GXL_DTOCOR	:= dDatOco
							GXL->GXL_HROCOR	:= cHorOco
							GXL->GXL_EMISDC	:= cCGCTrans
							GXL->GXL_SERDC		:= cSERDC
							GXL->GXL_NRDC		:= cNRDC
							GXL->GXL_CODOCO	:= cOcorre
							GXL->GXL_OBS		:= substr(cBuffer,45,70)
							GXL->GXL_EDISIT	:= "1" //1=Importado 2=Processado 3=Rejeitado 4= Alterado
							GXL->GXL_EDIMSG	:= ""
							GXL->GXL_EDINRL	:= nLinha
							GXL->GXL_EDILIN	:= cBuffer
							GXL->GXL_EDIARQ	:= cArq
							GXL->GXL_DTIMP		:= dDataBase
							GXL->GXL_CODOBS	:= substr(cBuffer,43,02)
							MsUnlock()					    
							
					  	   AAdd(aConfere,{cNrNF,cSerie,cNomeCli,cOcorre,cDesOcor,cCod,cLoja})
			  	      Endif
			  	      
					Endif
									  	   
			  	Endif   
				
			Endif	
			
		  	cBuffer := Space(__TAMLINHA+2)
		   nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
		   If Len(cBuffer) == (__TAMLINHA-2)
		   	cBuffer += Space(2)
			EndIf			
			
		End
		
		FClose(nHandle)
		
		cFileDest := "PROC_"+cNomeArq      
		MakeDir(cPath+"PROCESSADO")
		__CopyFIle(cArq,cPath+'PROCESSADO\' + cFileDest)
		FERASE(cArq)				
			
		aConfere:= aSort( aConfere,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )		
			
		If Len(aConfere) =  0 
			If len(aOcorre)= 0                     
				cMsg:= "O arquivo nใo cont้m dados para essa empresa CGC: "+ transform( SM0->M0_CGC, "@R 99.999.999/9999-99")
				If pSrv
					Conout(cMsg)
				Else
					MsgBox(cMsg)
				Endif
				lError := .T.
			Endif
		EndIf
			
	Else              
		cMsg:= 'Erro ao tentar abrir o arquivo!  ' + cArq
		If pSrv
			Conout(cMsg)
		Else
			MsgBox(cMsg)
		Endif
		lError := .T.
	EndIf 
		
Else
	cMsg:= 'Arquivo '+AllTrim(cArq)+' nใo encontrado!'
	If pSrv
		Cnout(cMsg)
	Else
		MsgBox()
	Endif
	lError := .T.
EndIf  

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcancela   บAutor  ณRodrigo dos Santos  บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cancela()
oDlg:End()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimprime   บAutor  ณRodrigo dos Santos  บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Imprime()
Local cDesc1         	:= "Este programa tem como objetivo imprimir as ocorrencias "
Local cDesc2         	:= "no arquivo de retorno EDI - Proceda. "
Local cDesc3         	:= ""
Local cPict          	:= ""
Local Imprime      		:= .T.
Local cPerg		      := ""

Private Titulo       		:= "Composicao do Arquivo de Retorno"
Private Cabec1       		:= " "
Private Cabec2       		:= " "

Private nLin 			:= 80
Private nPos 			:= 0
Private aOrd            := {}
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private CbTxt        	:= ""
Private Limite          := 132
Private Tamanho         := "G"
Private NomeProg        := "COMMC005" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo           := 18
Private aReturn         := { "A4", 1, "Logistica", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cPerg         	:= ""
Private cbTxt      		:= Space(10)
Private cbCont     		:= 00
Private ContFl     		:= 01
Private M_Pag      		:= 01
Private wNRel      		:= "RETORNO" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString		    := ""

wNRel := SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrunreport บAutor  ณMicrosiga           บ Data ณ  01/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function RunReport(Cabec1,Cabec2,Titulo)

If Len(aOcorre) > 0

	Cabec1       		:= "Ocorrencias Nao Importadas "
	Cabec2       		:= "Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia"
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9                           
	
	For nAux := 1 To Len(aOcorre)
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		EndIf
		
		/*                                                                                                                                          
		         1         2         3         4         5         6         7         8         9         0         1         2         3
		1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia 
		9999999999999999   99/99/99  99:99     99999999  999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*/	
		
		@ nLin,01 PSay aOcorre[nAux,01]
		@ nLin,20 PSay aOcorre[nAux,02]
		@ nLin,30 PSay aOcorre[nAux,03]
	   @ nLin,40 PSay aOcorre[nAux,04]
	   @ nLin,50 PSay aOcorre[nAux,05]
		@ nLin,55 PSay aOcorre[nAux,06]   
		nLin++
		
	Next
	
Endif 

Cabec1       		:= "Ocorrencias Importadas "
Cabec2       		:= "Serie         Numero           Cod.        Loja       Cliente                                                   Data Proc.             Cod.         Ocorrencia                                                              "
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 9                           

For nAux := 1 To Len(aConfere)
	
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	EndIf
	
	@ nLin,000 PSay aConfere[nAux][2]
	@ nLin,014 PSay aConfere[nAux][1]
	@ nLin,054 PSay substr(alltrim(aConfere[nAux][3]),1,40) 
   @ nLin,031 Psay aConfere[nAux][6] 
   @ nLin,044 Psay aConfere[nAux][7] 
   @ nLin,113 PSay Dtoc(DDatabase)
   @ nLin,135 PSay aConfere[nAux][4]
   @ nLin,148 Psay aConfere[nAux][5] 
	nLin++
	
Next

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณNUMNF     ณ Autor ณ  Carlos Cleuber       ณ Data ณ 14/05/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณ Retorno o Tamanho correto da NF Formatado                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Diversos programas especificos                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function NumNF( cNF )
Local nTamNf:= TamSX3("D1_DOC")[1]

Local cRet := StrZero( Val( cNF ), nTamNf )

Return cRet
