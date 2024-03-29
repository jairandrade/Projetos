#include "tbiconn.ch"
#include "topconn.ch"
#include "protheus.ch"
//---------------------------------------------------------------------------------
// Ponto de entrada apos a confirmacao do pedido de vendas
// Ricardo Luiz da Rocha
//---------------------------------------------------------------------------------
//TODO Analisar o tipo de bloqueio e movimentar atividade no Fluig.
//@since 13/04/2018
//@version 1.0

User Function MTA410T()
Local aArea		:= GetArea()
Local _cPedido	:= SC5->C5_NUM
Local cOrcM		:= xRetOrc(SC5->C5_NUM)

/* Processo Fluig */
IF Upper(FunName()) $ "MATA440" .And. Alltrim(cEmpAnt) == "04" .And. !Empty(cOrcM) //Adicionado tratamento para empresa 04 - Luis 21-05-18
	DBSelectArea('SCJ') //Or�amento
	SCJ->(DBSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
    SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,TamSX3('CJ_NUM')[1])))
    If !Empty(SCJ->CJ_XNUMFLU)
		Reclock('ZA1',.T.)
			ZA1->ZA1_FILIAL:=xFilial('ZA1')
			ZA1->ZA1_TIPO  :='BLOQUEIO'
			ZA1->ZA1_NUM   :=SC5->C5_NUM
			ZA1->ZA1_STATUS:='1' //Aguardando	
			ZA1->ZA1_DTCRIA:=Date()
			ZA1->ZA1_HRCRIA:=Time()		
			ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
		MsUnlock()
	
			//Inicia o JOB que ir� integrar com o Fluig
			//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
		StartJob('U_KAPJOB',GetEnvServer(),.F., 'BLOQUEIO', SCJ->CJ_NUM, CEMPANT, CFILANT)
	endif
EndIf
/* Processo Fluig */

If sc5->(reclock(alias(),.f.))  
   //16/07/2019 - DEVE SER RECOMPIADA PARA CORRETO FUNCIONAMENTO.
   sc5->c5_xtotmer:=u_MFAT01(xfilial('SC5'),_cPedido)
   //sc5->c5_xtotmer:=0
   sc5->(Msunlock())
EndIf   

RestArea(aArea)
Return .t.

Static Function xRetOrc(cPedido)
Local aArea		:= GetArea()
Local cSql		:= ""
Local cAliasOF	
Local cOrc		:= ""

If Select('cAliasOF')<>0
	cAliasOF->(DBSelectArea('cAliasOF'))
	cAliasOF->(DBCloseArea())
Endif

cSql	:= " SELECT C6_NUMORC
cSql	+= " FROM SC6040 WITH(NOLOCK)
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND C6_NUM = '"+cPedido+"'
cSql	+= " AND C6_NUMORC <> '' "

TcQuery cSql new Alias "cAliasOF"

DbSelectArea("cAliasOF")
cAliasOF->(DbGoTop())

If !cAliasOF->(EOF())
	cOrc	:= cAliasOF->C6_NUMORC
EndIf

cAliasOF->(DBCloseArea())
RestArea(aArea)
Return(cOrc)
