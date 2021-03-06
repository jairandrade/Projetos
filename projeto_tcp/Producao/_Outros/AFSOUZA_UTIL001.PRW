#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"


#define pos_campo  	 1

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AUTIL001
Rotina para altera��o de casas decimais

@return 
@author Felipe Toazza Caldeira
@since 26/05/2016
/*/
//-------------------------------------------------------------------------------
User Function AUTIL001()

Local bProcess
Local cPerg := Padr("AUTIL001",10)
Local oProcess

bProcess := {|oSelf| Executa(oSelf) }

//cria as peguntas se n�o existe
Pergunte(cPerg,.F.)

oProcess := tNewProcess():New("AUTIL001","Altera��o de casas decimais",bProcess,"Rotina para altera��o de casas decimais de campos num�ricos. Na op��o parametros, favor informar o arquivo .CSV com os campos que dever�o ser alterados",cPerg,,.F.,,,.T.,.T.)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Executa
Rotina para altera��o de casas decimais

@return 
@author Felipe Toazza Caldeira
@since 26/05/2016
/*/
//-------------------------------------------------------------------------------
static Function Executa(oProc)

Local cArq     := alltrim(mv_par01)
Local cLinha   := ""
Local aLinha   := {}
Local cDiretory
Local nCasas  := mv_par02
Local i
Local aCampos := {}
Private aErro := {}
Private aMudou:= {}

//valida o diret�rio se for pra gravar em disco	
cDiretory := alltrim(mv_par03)
cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )

//valida o diret�rio
If !ExistDir( cDiretory )
	Aviso("Diret�rio","Diret�rio " + cDiretory + " invalido.",{"Ok"},2)
	Return
	
Endif

//verifica se a exten��o � csv
If Upper(Right(cArq,4)) != ".CSV"	
	Aviso("Arquivo","A Extens�o do arquivo deve obrigatoriamente ser CSV.",{"Ok"},2)
	Return
Endif

//verifica se o arquivo existe
If !File(cArq)
	Aviso("Arquivo","O arquivo " +cArq + " n�o foi encontrado.",{"Ok"},2)
	Return
EndIf
	
//Abre o arquivo
FT_FUSE(cArq)

//Regua
oProc:SetRegua1( FT_FLastRec() )

While !FT_FEof()
	
	//Leitura da linha do arquivo
	cLinha := FT_FReadLn()
	
	//se vazio, sai fora
	If Empty(cLinha)
		Exit
	Endif
	
	//quebra a linhas conforme o separador
	aLinha := Split( cLinha, ";" )
	
	aAdd(aCampos,{aLinha[pos_campo]})
	
	//Regua
	oProc:IncRegua1("Campo: "+aLinha[pos_campo])
	
	//pula linha
	FT_FSkip()
	
Enddo

oProc:SetRegua1( Len(aCampos) )
//
//For nI := 1 to Len(aCampos)
//	
//	DbSelectArea("SX3")
//	DbSetOrder(2)     
//	DbGoTop()
//	If DbSeek(aCampos[nI,pos_campo])   
//		nDimTam := SX3->X3_DECIMAL
//		nAdTam	:= SX3->X3_TAMANHO
//		If Reclock('SX3',.F.)
//			SX3->X3_TAMANHO := nAdTam-nDimTam+nCasas
//			SX3->X3_DECIMAL := nCasas
//			SX3->X3_PICTURE := Substr(SX3->X3_PICTURE,1,AT(".",SX3->X3_PICTURE))+Replicate('9',nCasas) //altera para a nova mascara decimal
//			MsUnlock()
//			aADD(aMudou, aCampos[nI,pos_campo])
//		Else
//			aADD(aErro, {aCampos[nI,pos_campo],"N�o foi possivel acesso exclusivo"})
//		EndIf				
//	Else
//		aADD(aErro, {aCampos[nI,pos_campo],"Campo n�o encontrado"})
//	Endif
//
//	oProc:IncRegua1("Campo: "+aCampos[nI,pos_campo])
//	
//		
//Next nI

//+------------------+---------------------------------------------------------+
//!Verifica se houve erro, se tiver grava no diret�rio informado por par�metro !
//+------------------+---------------------------------------------------------+
	
	cAlterados := "ALTERADOS PARA "+Alltrim(Str(nCasas))+" DECIMAIS!"+chr(13)+chr(10)
	For i:=1 to Len(aMudou)
		cAlterados += aMudou[i]+chr(13)+chr(10)
	Next i             

	cAlterados := "PROBLEMAS QUE N�O PERMITIRAM ALTERA��O "+chr(13)+chr(10)
	For i:=1 to Len(aErro)
		cAlterados += aErro[i,1]+" - "+aErro[i,2]+chr(13)+chr(10)
	Next i             	

	
cDiretory := cDiretory + "Logcasasdecimais.txt"
		
MemoWrite(cDiretory,cAlterados)
		
Aviso("Concluido","Altera��o de casas decimais foi conclu�da! Arquivo de log gravado no diret�rio "+cDiretory,{"Ok"},2)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Num

@return 
@author Felipe Toazza Caldeira
@since 26/05/2016
/*/
//-------------------------------------------------------------------------------
Static Function Num(cNum)
cNum := StrTran(cNum,",",".")
Return( val(cNum) )

static Function Split(cPar,cSep)

Local aPar := {}
Local nPos := ""

	While At( cSep, cPar ) != 0
		nPos := At( cSep, cPar )
		
		aAdd( aPar, alltrim( Subs( cPar, 1, nPos-1 ) ) )
		cPar := Subs( cPar, nPos+1, len(cPar) )
		
	End
	
	If !Empty(cPar)
		aAdd( aPar, alltrim( Subs( cPar, 1, len(cPar) ) ) )
		
	EndIf

Return aPar

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1

@return 
@author Felipe Toazza Caldeira
@since 26/05/2016
/*/
//-------------------------------------------------------------------------------
//static Function CriaSX1(cPerg)
//
////Arquivo
//PutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importa��o,","obrigat�riamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
////Mostra erros?
//PutSx1(cPerg,"02","Casas Decimais?","Casas Decimais?","Casas Decimais?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","","","","","","","","","","","","","","","","",{"Numero de casas decimais","","",""},{"","","",""},{"","",""},"")
////Diretorio
//PutSx1(cPerg,"03","Diret�rio?","Diret�rio?","Diret�rio?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diret�rio para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")
//
//Return

