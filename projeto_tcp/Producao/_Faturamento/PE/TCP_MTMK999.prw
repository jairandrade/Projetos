//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTMK999
Atualização de classificação de clientes

@return 
@author Felipe Toazza Caldeira
@since 06/12/2015

/*/
//-------------------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"               
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
                                    
#define pos_cnpj	4
#define pos_class	5

User Function MTMK999(cUso,cEmp,cFil)    
Private lAbort := .T.         
	 
	Processa ( {|lEnd| Importa(@lEnd,cUso) }, "Atualizando clientes..."," Aguarde...",lAbort)

Return
                                   

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Importa
Rotina para leitura do arquivo e importação

@return 
@author Felipe Toazza Caldeira
@since 06/12/2015

/*/
//-------------------------------------------------------------------------------
Static Function Importa(lEnd,cUso)

Local aFiles := {}
Local _nLinha := 0    
Local _nOpcao := 3  
Local nCnt
Private aDados := {}
Private cArq       := ""
Private cArqOld    := ""
Private cLinha     := ""
Private lPrim      := .T.
Private cBckFil   := cFilAnt
Private aErro := {}
Private aLog := {}

    
If Empty(Alltrim(cUso))
	//Solicita a escolha do arquivo CSV a ser importado.
	cArq := cGetFile(" *.csv | *.CSV  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
	If !Empty(Alltrim(cArq))
		AADD(aFiles, cArq)
		cArqOld := SUBSTR(cArq,1,Len(cArq)-3)+"#tx"
	EndIf               
Else        

	cPath := GetMV('TM_FILCTE') 
	cTpArq	:= "*.CSV"
	aFiles  := Directory(cPath+cTpArq)		  
	    
	If Len(aFiles) == 0
		return
	EndIf
	cArq := cPath + aFiles[1][1]
	
EndIf
	
If Len(aFiles) == 0

	cMsg := "Nao existem arquivos para importar. Processo Encerrado"
	Return(cMsg)
Else

	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := cArq
	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	nHdl := fOpen(cArqTxt)
	If nHdl == -1
		IF FERROR()== 516
			ALERT("Feche a planilha que gerou o arquivo.")
		EndIF
		cMsg := "O arquivo de nome "+cArqTxt+" não pode ser aberto! Verifique os parâmetros."
		MsgAlert(cMsg,"Atenção!")
		Return (cMsg)
	Endif
Endif
fClose(nHdl)

If !File(cArq)
	MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[AEST905] - ATENCAO")
	cMsg := "Arquivo nao encontrado"
	Return (cMsg)
EndIf
         
FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
	
	IncProc("Lendo arquivo texto...")
	 
	//Tratamento do Botão Cancelar do Processamento
	If lEnd
		Alert("Processo Interrompido pelo Usuário!")
		Return
	EndIf		
	
	cLinha := FT_FREADLN()
	cLinha := ALLTRIM(cLinha)
	
	_nLinha++
	
	//se vazio, sai fora
	If Empty(cLinha)
		Exit
	Endif    

	If _nLinha > 3
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf	
	FT_FSKIP()
EndDo

FT_FUSE()
 
ProcRegua(Len(aDados))		
For nCnt := 1 To Len(aDados)

	If Len(aDados[nCnt][4]) > 11
		cCNPJ := STRZERO(VAL(aDados[nCnt][4]),14)
	Else
		cCNPJ := STRZERO(VAL(aDados[nCnt][4]),11)
	EndIf
	/*
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	SA1->(DbGoTop())
	IF SA1->(DbSeek(xFilial('SA1')+cCNPJ))  
		RecLock('SA1',.F.)
		SA1->
		MsUnlock()
	EndIf      
      */
	TcSqlExec("UPDATE "+RetSqlname('SA1')+" SET A1_TIPOCR = '"+aDados[nCnt][5]+"' WHERE A1_CGC = '"+cCNPJ+"' AND D_E_L_E_T_ != '*' ")                           
Next

Return                                                                       

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Split
Funcao para retornar um array quebrando uma strig com o delimitador padrão

@return 
@author Felipe Toazza Caldeira
@since 24/10/2015

/*/
//-------------------------------------------------------------------------------
static Function Split( cPar, cSep)

Local aPar := {}
Local nPos := ""

While At( cSep, cPar ) != 0
	nPos := At( cSep, cPar )
	
	aAdd( aPar, alltrim( Subs( cPar, 1, nPos-1 ) ) )
	cPar := Subs( cPar, nPos+1, len(cPar) )
	
End

aAdd( aPar, alltrim( Subs( cPar, 1, len(cPar) ) ) )

Return( aPar )

//----------------------------------------------------------
// Funcao Auxiliar para retirar a máscara do campo CNPJ/CPF*
//----------------------------------------------------------
Static Function NewCGCCPF(cCGCCPF)

Local aInvChar := {"/",".","-"}
Local nI

For nI:=1 to Len(aInvChar)
	cCGCCPF := StrTran(cCGCCPF,aInvChar[nI])
Next

Return cCGCCPF
