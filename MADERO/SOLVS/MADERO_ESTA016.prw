//--------------------------
//Importação Produtos Adicionais
//--------------------------
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

#define pos_fil  1
#define pos_cod	 2
#define pos_desc 3

#define CRLF chr(13)+CHR(10)

User Function ESTA016()

Local bProcess
Local oProcess
Local cPerg := Padr("IMPZ32",10)

bProcess := {|oSelf| Executa(oSelf) }

//Cria as perguntas se não existirem
CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oProcess := tNewProcess():New("IMPZ32","Importação de Produtos adicionais",bProcess,"Rotina para importação de Produtos adicionais. Na opção parâmetros, informe o nome do arquivo .CSV para importação",cPerg,,.F.,,,.T.,.T.)

Return

//----------------------------
Static Function Executa(oProc)
/***********************************************/
/* mv_par01 -> Arquivo                         */
/*                                             */
/***********************************************/

Local cArq      := Alltrim(mv_par01)
Local cQuery    := ""
Local cCodigo   := ""
Local cInicial  := "1"
Local cLinha    := ""
Local aLinha    := {}
//Local nMostra   := mv_par02
Local aMata220  := {}
Local nCont     := 0
Local cDiretory   
Local cLocaliz          

Private lMsErroAuto	:= .F.
/*
If ( nMostra == 2 )
	cDiretory := Alltrim(mv_par03)
	cDiretory += IIF( Right( cDiretory, 1 ) == "\", "", "\" )

	If !ExistDir( cDiretory )
		Aviso("Diretório","Diretório " + cDiretory + " não encontrado",{"Ok"},2)
		Return
	Endif
Endif
*/
If Upper(Right(cArq,4)) != ".CSV"
	Aviso("Atençao","A extensão do arquivo deve ser obrigatoriamente .CSV",{"Ok"},2)
	Return
Endif

If !File(cArq)
	Aviso("Atenção","O arquivo " +cArq + " não foi encontrado",{"Ok"},2)
	Return

Endif

//Inicia o processamento
FT_FUSE(cArq)

oProc:SetRegua1(FT_FLastRec())

While !FT_FEOF()
	lMsErroAuto	:= .F.
	cLinha := FT_FReadLn()
	If Empty(cLinha)
		Exit
	Endif
	aLinha := Split(cLinha, ";")

	dbSelectArea("Z32")
	Z32->(dbSetOrder(1)) 
	If dbSeek(xFilial("Z32")+ALLTRIM(aLinha[1]),.T.)
		While Z32->Z32_DATA == ALLTRIM(aLinha[1])
			RecLock("Z32",.F.)
			Z32->( dbDelete() )
			Z32->( MsUnLock() )
			Z32->( dbSkip() )
		Enddo
	EndIf

	dbSelectArea("Z32")
	Z32->(dbSetOrder(1))
	If !dbSeek(xFilial("Z32")+ALLTRIM(aLinha[1])+ALLTRIM(aLinha[2])+ALLTRIM(aLinha[3]),.T.)
			//cProduto := U_ESTA1099(ALLTRIM(aLinha[1]),ALLTRIM(aLinha[2]),ALLTRIM(aLinha[3]))
			RecLock("Z32",.T.)
			Z32->Z32_FILIAL  := xFilial("SB1")
			Z32->Z32_DATA    := CTOD(ALLTRIM(aLinha[1])) 
			Z32->Z32_COD     := ALLTRIM(aLinha[2])  
			Z32->Z32_DESC    := Posicione("SB1",1,xFilial("SB1")+ALLTRIM(aLinha[2]),"B1_DESC")    
			Z32->Z32_COMP    := ALLTRIM(aLinha[3])  
			Z32->Z32_DESCC   := Posicione("SB1",1,xFilial("SB1")+ALLTRIM(aLinha[3]),"B1_DESC")    
			Z32->Z32_QTDE    := VAL(aLinha[4])        
			MsUnlock("Z32")
	Endif

	oProc:IncRegua1("Produto: "+aLinha[2]+ "-" + aLinha[3])
	FT_FSKIP()
Enddo                                     

FT_FUSE()
fRename(cArq,cArq+".processado")

Aviso("Atenção","Importação Concluída",{"Ok"},2)

Return

//-----------------------
Static Function Num(cNum)
cNum := StrTran(cNum,",",".")

Return(Val(cNum))

//------------------------------
Static Function Split(cPar,cSep)

Local aPar := {}
Local nPos := ""

While AT(cSep, cPar) != 0
	nPos := AT(cSep, cPar)

	aAdd(aPar, Alltrim( Subs( cPar, 1, nPos-1)))
	cPar := Subs( cPar, nPos+1, len(cPar) )
Enddo

If !Empty(cPar)
	aAdd(aPar, Alltrim(Subs(cPar, 1, Len(cPar))))
Endif

Return aPar


//----------------------------
Static Function CriaSX1(cPerg)

PutSX1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
//PutSX1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","Não Mostra","Não Mostra","Não Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
//PutSX1(cPerg,"03","Diretório?","Diretório?","Diretório?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para grava em disco.",""},{"","","",""},{"","",""},"")

Return
