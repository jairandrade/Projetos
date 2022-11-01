#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "font.ch"
#INCLUDE "colors.ch"
//#INCLUDE "inkey.ch"
#INCLUDE "topconn.ch"

//Marcos Teixeira. 14.03.2007
// 16.12.2009 - Adicionadas melhorias. Marcos Teixeira
// 17.12.2009 - Executa multi-linhas (separa�ao por ; ) e trata ou n�o erros. Marcos Teixeira
// 22.12.2009 - Trata o retorno do tipo U, exibindo "-". Marcos Teixeira
// 06.01.2010 - Inclido verifica��o de fontes .PRX. Eduardo Carvalho
// 14.01.2010 - Corre��o comando altrim para alltrim - Ricardo Rauber
// 20.08.2013 - Alterado nome do objeto odlg para oDlgAdvpl 
User Function AdvplExec()
local cFunc
local bFlag	:= .t.
local bRet	:= ""
Private aFunc:= {'','','','','','','','','','','','','','','','','','','',''}


DEFINE MSDIALOG oDlgAdvpl FROM 0,0 TO 400,380 PIXEL TITLE "A D V P L    E X E C"
DEFINE FONT oFnt NAME "Arial" Size 6,22

oSay:= tSay():New(10,10,{||"Fun��o | Fonte.PRW | INFO"},oDlgAdvpl,,oFnt,,,,.T.)
oMemo:= tMultiget():New(20,10,{|u|if(Pcount()>0,aFunc[pcount()+1]:=u,aFunc[1])},oDlgAdvpl,170,70,,,,,,.T.)
oMemo:appendText(MemoRead("c:\temp\advplexec.txt"))
oSay:= tSay():New(095,10,{||"Retorno"},oDlgAdvpl,,oFnt,,,,.T.)
@ 105,10 MSGET oSay VAR bRet SIZE 170,50 OF oDlgAdvpl PIXEL


@ 170,010 BUTTON oButton PROMPT "OK(S/Err)"  OF oDlgAdvpl PIXEL SIZE 40,15 ACTION {||bRet:=Exc("") 	 , bFlag:=.t., oDlgAdvpl:Refresh() }
@ 170,050 BUTTON oButton PROMPT "OK(C/Err)"  OF oDlgAdvpl PIXEL SIZE 40,15 ACTION {||bRet:=ExcErr("") , bFlag:=.t., oDlgAdvpl:Refresh() }
@ 170,130 BUTTON oButton PROMPT "SAIR"  OF oDlgAdvpl PIXEL ACTION {||oDlgAdvpl:End() , bFlag:=.f.     }

ACTIVATE MSDIALOG oDlgAdvpl CENTERED

Return

//---------------------------------------------------
// Executa e trata algum erro, sfc.
Static Function Exc(xPar01)
local n			:= 0
local cR1
local cResult
Local cInfoComp
Local cRes		:= ""
Local aData		:= {}
Local aInfoComp	:= {}
Local oError := ErrorBlock({|e| MsgAlert("Ocorreu um Erro: " +chr(10)+ e:Description)})
Local aFunc2	:= aClone(aFunc)
Local i
cGrv:= ""
for i:=1 to len(aFunc2)
	cGrv+= aFunc2[i]
Next
memowrite("c:\temp\advplexec.txt",cGrv)

//Separa as linhas que tiverem ";"
for n=1 to len(aFunc2)
	xPar01+=alltrim(aFunc2[n])
	aFunc2[n]:=""
next
if len(xPar01)>1
	xPar01+=";"
endif
//Remove as quebras de linha
xPar01 := strtran(xPar01,chr(13),"")
xPar01 := strtran(xPar01,chr(10),"")
n:=1

if ";" $ xPar01
	while (at(";",xPar01)>1)
		nPos:=at(";",xPar01)
		aFunc2[n]:=substr(xPar01,1,nPos-1)
		xPar01:=substr(xPar01,nPos+1,len(xPar01))
		n++
	enddo
endif

for n=1 to len(aFunc2)
	Begin Sequence
	if !empty(aFunc2[n])
		if (".PRW" $ upper(aFunc2[n])) .or. (".PRX" $ upper(aFunc2[n])) .and. (len(alltrim(aFunc2[n])) < 25)
			aData := GetAPOInfo(aFunc2[n])
			cMsg := "Nome do fonte: "+aData[1]
			cMsg += chr(13)+"Linguagem do fonte: "+aData[2]
			cMsg += chr(13)+"Modo de Compila��o: "+aData[3]
			cMsg += chr(13)+"Ultima compila��o do arquivo: "+dtoc(aData[4])
			cMsg += chr(13)+"Hora da compila��o no RPO: "+aData[5]
			MsgInfo(cMsg)
		elseif upper(alltrim(aFunc2[n])) = "INFO"
			aInfoComp := GetRmtInfo()
			cInfoComp:= 'Nome do Computador: ' + aInfoComp[1]+chr(13)+chr(10)+;
			'Sistema Operacional: ' + aInfoComp[2]+chr(13)+chr(10)+;
			'Informa��o adicional: ' + aInfoComp[3]+chr(13)+chr(10)+;
			'Mem�ria: ' + aInfoComp[4]+chr(13)+chr(10)+;
			'Nr. de Processadores: ' + aInfoComp[5]+chr(13)+chr(10)+;
			'MHZ Processador: ' + aInfoComp[6]+chr(13)+chr(10)+;
			'Descri��o Processador: ' + aInfoComp[7]+chr(13)+chr(10)+;
			'Linguagem: ' + aInfoComp[8]+chr(13)+chr(10)+;
			'IP: '+GetClientIP()+chr(13)+chr(10)+;
			'Build: '+GetBuild()+chr(13)+chr(10)+;
			'Environment: '+GetEnvServer()+chr(13)+chr(10)+;
			'Tema: '+PtGetTheme()
			MsgInfo(cInfoComp)
		else
			cR1:=&("{|| "+alltrim(aFunc2[n])+" }")
			cResult:=eval(cR1)
			if valtype(cResult)="L"
				if cResult
					cRes+=".T."+chr(13)
				else
					cRes+=".F."+chr(13)
				endif
			elseif valtype(cResult)="N"
				cRes+=alltrim(str(cResult))+chr(13)
			elseif valtype(cResult)="D"
				cRes+=dToc(cResult)+chr(13)
			elseif valtype(cResult)="U"
				cRes+="-"+chr(13)
			else
				cRes+=cResult+chr(13)
			endif
		endif
	endif
	End Sequence
Next

Errorblock(oError)

Return(cRes)

//---------------------------------------------------
//Executa por�m n�o trata erro
Static Function ExcErr(xPar01,xPar02)
local n			:= 0      
local cR1
local cResult
Local cInfoComp
Local cRes		:= ""
Local aData		:= {}
Local aInfoComp	:= {}
Local aFunc2	:= aClone(aFunc)        
Local i
cGrv:= ""
for i:=1 to len(aFunc2)
	cGrv+= aFunc2[i]
Next
memowrite("c:\temp\advplexec.txt",cGrv)

//Separa as linhas que tiverem ";"
for n=1 to len(aFunc2)
	xPar01+=alltrim(aFunc2[n])
	aFunc2[n]:=""
next
if len(xPar01)>1
	xPar01+=";"
endif
//Remove as quebras de linha
xPar01 := strtran(xPar01,chr(13),"")
xPar01 := strtran(xPar01,chr(10),"")
n:=1

if ";" $ xPar01
	while (at(";",xPar01)>1)
		nPos:=at(";",xPar01)
		aFunc2[n]:=substr(xPar01,1,nPos-1)
		xPar01:=substr(xPar01,nPos+1,len(xPar01))
		n++
	enddo
endif

for n=1 to len(aFunc2)
	Begin Sequence
	if !empty(aFunc2[n])
		if (".PRW" $ upper(aFunc2[n])) .or. (".PRX" $ upper(aFunc2[n])) .and. (len(alltrim(aFunc2[n])) < 25)
			aData := GetAPOInfo(aFunc[n])
			cMsg := "Nome do fonte: "+aData[1]
			cMsg += chr(13)+"Linguagem do fonte: "+aData[2]
			cMsg += chr(13)+"Modo de Compila��o: "+aData[3]
			cMsg += chr(13)+"Ultima compila��o do arquivo: "+dtoc(aData[4])
			cMsg += chr(13)+"Hora da compila��o no RPO: "+aData[5]
			MsgInfo(cMsg)
		elseif upper(alltrim(aFunc2[n])) = "INFO"
			aInfoComp := GetRmtInfo()
			cInfoComp:= 'Nome do Computador: ' + aInfoComp[1]+chr(13)+chr(10)+;
			'Sistema Operacional: ' + aInfoComp[2]+chr(13)+chr(10)+;
			'Informa��o adicional: ' + aInfoComp[3]+chr(13)+chr(10)+;
			'Mem�ria: ' + aInfoComp[4]+chr(13)+chr(10)+;
			'Nr. de Processadores: ' + aInfoComp[5]+chr(13)+chr(10)+;
			'MHZ Processador: ' + aInfoComp[6]+chr(13)+chr(10)+;
			'Descri��o Processador: ' + aInfoComp[7]+chr(13)+chr(10)+;
			'Linguagem: ' + aInfoComp[8]+chr(13)+chr(10)+;
			'IP: '+GetClientIP()+chr(13)+chr(10)+;
			'Build: '+GetBuild()+chr(13)+chr(10)+;
			'Environment: '+GetEnvServer()+chr(13)+chr(10)+;
			'Tema: '+PtGetTheme()
			MsgInfo(cInfoComp)
		else
			cR1:=&("{|| "+alltrim(aFunc2[n])+" }")
			cResult:=eval(cR1)
			if valtype(cResult)="L"
				if cResult
					cRes+=".T."+chr(13)
				else
					cRes+=".F."+chr(13)
				endif
			elseif valtype(cResult)="N"
				cRes+=alltrim(str(cResult))+chr(13)
			elseif valtype(cResult)="D"
				cRes+=dToc(cResult)+chr(13)
			elseif valtype(cResult)="U"
				cRes+="-"+chr(13)
			else
				cRes+=cResult+chr(13)
			endif
		endif
	endif
	End Sequence
Next

Return(cRes)
