#include "rwmake.ch"
#include "protheus.ch"

//Inicializador padrão do campo E5_HISTOR.
//Inicia o campo de histórico da baixa com o cliente/fornecedor do título.

User Function BXHIST()

Local cFunName := FUNNAME()
Local cHist    := ""

If cFunName $ "FINA070 FINA200 FINA740"
	cHist := "RC "+Substr(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME"),1,35)
Elseif cFunName $ "FINA080 FINA430 FINA750"
	cHist := "PG "+Substr(Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,35)
Endif

Return(cHist)

//////////////////////

User Function FA090SE5()
Local cHistor := ""

cHistor := "PG "+Substr(Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,Len(SE5->E5_HISTOR))

Return(cHistor)

///////////////////////

User Function FA110SE5()

//Variáveis
Local c110Hist := ""

//Condições
c110Hist := "RC "+Substr(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME"),1,35)

//Grava histórico
SE5->E5_HISTOR := c110Hist

Return

////////////////////////

User Function F050COF() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->E2_DIRF	:= "1"
SE2->E2_CODRET	:= IIf (Empty(SE2->E2_CODRET),"5952",SE2->E2_CODRET)
SE2->(MsUnlock())
Return

////////////////////////

User Function F050CSL() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->E2_DIRF	:= "1"
SE2->E2_CODRET	:= IIf (Empty(SE2->E2_CODRET),"5952",SE2->E2_CODRET)
SE2->(MsUnlock())
Return

/////////////////////////

User Function F050INS() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->(MsUnlock())
Return

/////////////////////////

User Function F050IRF() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->E2_DIRF	:= "1"
SE2->E2_CODRET	:= IIf (Empty(SE2->E2_CODRET),"1708",SE2->E2_CODRET)
SE2->(MsUnlock())
Return

/////////////////////////

User Function F050ISS() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->(MsUnlock())
Return

/////////////////////////

User Function F050PIS() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->E2_DIRF	:= "1"
SE2->E2_CODRET	:= IIf (Empty(SE2->E2_CODRET),"5952",SE2->E2_CODRET)
SE2->(MsUnlock())
Return

/////////////////////////

User Function F050SES() //gravar no campo historico qual é o fornecedor que originou o imposto

Reclock ("SE2",.F.)
SE2->E2_HIST	:= SUBSTR(SE2->E2_TITPAI,15,3)+" "+SUBSTR(SE2->E2_TITPAI,4,9)+" "+POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(E2_TITPAI,18,6)+SUBSTR(E2_TITPAI,24,2),"A2_NOME")
SE2->(MsUnlock())
Return

/////////////////////////
