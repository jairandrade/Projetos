#INCLUDE "totvs.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"


User Function KAP001()

Local nOpca     := 0
Local aSays     := {}
Local aButtons  := {}
Local cCadastro := "Alteração Natureza fornecedores"
Local cType     := OemToAnsi( "Arquivo Texto" ) + "(*.CSV) |*.CSV|"

Local cTXTFile  := Space( 40 )


AADD( aSays, OemToAnsi( "Esta rotina importa o Arquivo de Texto com as Informações de Plantão" ) )
AADD( aSays, OemToAnsi( "de funcionários" ) )

AADD(aButtons, {14,.T.,{| | cTXTFile := cGetFile( cType, OemToAnsi( "Selecione o Arquivo Texto para Importação" ), 0,, .T. )  } } )
AADD(aButtons, { 1,.T.,{| | ( FechaBatch(), nOpca := 1 ) } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons,,200,425 )

If !Empty( cTXTFile )
	Processa( { || IArqPlan( cTXTFile ) }, OemToAnsi( "Aguarde, processando a Importação dos Resultados..." ) )
Else
	MsgStop( "Selecione o arquivo texto!" )
EndIf

Return()

Static Function IArqPlan(cArqImpor)

Local cLinha := ""
Local nLinha := 0
Local aDados := {}
Local nTamLinha := 0
Local nTamArq:= 0
Local cEmp
Local cTpFun
Local cMat
Local cDtCom
Local cQtdPlan
Local cStFun
Local i
Local lGrava := .T.
Local nFeito	:= 0

//+---------------------------------------------------------------------+
//| Abertura do arquivo texto                                           |
//+---------------------------------------------------------------------+
nHdl := fOpen(cArqImpor)
If nHdl == -1
	IF FERROR()== 516
		ALERT("Feche a planilha que gerou o arquivo.")
	EndIF
EndIf
//+---------------------------------------------------------------------+
//| Verifica se foi possível abrir o arquivo                            |
//+---------------------------------------------------------------------+
If nHdl == -1
	cMsg := "O arquivo "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
	MsgAlert(cMsg,"Atencao!")
	Return
Endif
//+---------------------------------------------------------------------+
//| Posiciona no Inicio do Arquivo                                      |
//+---------------------------------------------------------------------+
FSEEK(nHdl,0,0)
//+---------------------------------------------------------------------+
//| Traz o Tamanho do Arquivo TXT                                       |
//+---------------------------------------------------------------------+
nTamArq:=FSEEK(nHdl,0,2)
//+---------------------------------------------------------------------+
//| Posicona novamemte no Inicio                                        |
//+---------------------------------------------------------------------+
FSEEK(nHdl,0,0)
//+---------------------------------------------------------------------+
//| Fecha o Arquivo                                                     |
//+---------------------------------------------------------------------+
//	fClose(nHdl)
FT_FUse(cArqImpor)  //abre o arquivo
FT_FGOTOP()         //posiciona na primeira linha do arquivo
nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
FT_FGOTOP()
nLinhas := nTamArq/nTamLinha
ProcRegua(nLinhas)
i := 1
aDados:={}
While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele
	clinha := FT_FREADLN()
	aadd(aDados,Separa(cLinha,";",.T.))
	
	if Valida(AllTrim(aDados[i][1]),AllTrim(aDados[i][2]),AllTrim(aDados[i][3]))
		nFeito++
	endIf
	IncProc("Alterando cadastros, Aguarde...")
	FT_FSKIP()
	i := i + 1
EndDo
FT_FUse()

Aviso("Atenção","Alterados: "+Str(nFeito)+" Fornecedores",{"Ok"},1)
return Nil

Static Function Valida(cForn,cLoja,cNaturez)

Local lRet := .F.
Local cQuery := ""


cQuery += " SELECT R_E_C_N_O_ NRECNO FROM "+RetSqlName("SE5")
cQuery += " WHERE E5_CLIFOR = '"+cForn+"' AND E5_LOJA = '"+cLoja+"'
cQuery += " AND E5_TIPO = 'NF' AND E5_RECPAG = 'P' AND D_E_L_E_T_ = ''
tcQuery cQuery New Alias "TSE5"

dbSelectArea("SE5")
While TSE5->(!Eof())
	SE5->(dbGoTo(TSE5->NRECNO))
	RecLock("SE5",.F.)
	SE5->E5_NATUREZ := cNaturez
	SE5->(msUnlock())
	TSE5->(dbSkip())
	lRet := .T.
EndDo

cQuery := " SELECT R_E_C_N_O_ NRECNO FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_FORNECE = '"+cForn+"' AND E2_LOJA = '"+cLoja+"'
cQuery += " AND E2_TIPO = 'NF' AND D_E_L_E_T_ = ''
tcQuery cQuery New Alias "TSE2"

dbSelectArea("SE2")
While TSE2->(!Eof())
	SE2->(dbGoTo(TSE2->NRECNO))
	RecLock("SE2",.F.)
	SE2->E2_NATUREZ := cNaturez
	SE2->(msUnlock())
	TSE2->(dbSkip())
EndDo

cQuery := " UPDATE "+RetSqlName("SA2")+" SET A2_NATUREZ = '"+cNaturez+"' "
cQuery += " WHERE A2_COD = '"+cForn+"' AND A2_LOJA = '"+cLoja+"' "
cQuery += " AND D_E_L_E_T_ = ''
tcSqlExec(cQuery)

TSE2->(dbCloseArea())
TSE5->(dbCloseArea())
lRet := .T.

Return lRet
