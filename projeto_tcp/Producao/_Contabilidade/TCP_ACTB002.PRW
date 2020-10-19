#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "fileio.ch"

/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Customização                                            |
+------------------+---------------------------------------------------------+
|Modulo            | Contabilidade Gerencial                                 |
+------------------+---------------------------------------------------------+
|Nome              | ACTB002                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Rotina para aplicação de dados na Empresa consolidadora |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                   			 |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 20/06/2013                                              |
+------------------+----------------------------------+-------------+--------+
| Alterações                                          | Responsavel | Data   |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+-------*/
User Function ACTB002( cAlias, aDados )

Local aArea := GetArea()

do case
	case cAlias == 'CT8'
		StartJob("U_ACTB0020",GetEnvServer(),.T.,aDados,'90')
	case cAlias == 'CTR'                                 
		StartJob("U_ACTB0021",GetEnvServer(),.T.,aDados,'90')
	case cAlias == 'CT1'                                 	
		StartJob("U_ACTB0022",GetEnvServer(),.T.,aDados,'90')
endcase

RestArea(aArea)

Return

/*--------------------------+---------------------------+----------------------+
| Rotina: ACTB0020          | Autor: Lucas J. C. Chagas | Data: 20/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Rotina de processamento dos registros.                            |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
User Function ACTB0020( aDados, cEmpDest )

Local aArea    := GetArea()
Local bError   := Nil
Local bSeek    := Nil
Local cChave   := ''
Local cComando := ''
Local nI       := 0
Local nPos     := 0

RpcSetEnv( cEmpDest, "01",,, "CTB", "ACTB0020",,,,,)

bSeek := { |x| x[1] == 'CT8_FILIAL' }
nPos := ASCANX ( aDados, bSeek ) 
if nPos != 0
	cChave += aDados[nPos,2]
endif

bSeek := { |x| x[1] == 'CT8_HIST' }
nPos := ASCANX ( aDados, bSeek ) 
if nPos != 0
	cChave += aDados[nPos,2]
endif

dbSelectArea('CT8')
CT8->(dbSetOrder(1))
RecLock(CT8,!CT8->(dbSeek(cChave)))

	for nI := 1 to len(aDados)
		cComando := 'CT8->' + aDados[nI,1]
		&(cComando) := aDados[nI,2]
	next nI

CT8->(dbUnlock())

Return

/*--------------------------+---------------------------+----------------------+
| Rotina: ACTB0021          | Autor: Lucas J. C. Chagas | Data: 20/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Rotina de processamento dos registros.                            |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
User Function ACTB0021( aDados, cEmpDest )

Local aArea    := GetArea()
Local bError   := Nil
Local bSeek    := Nil
Local cChave   := ''
Local cComando := ''
Local nI       := 0
Local nPos     := 0

RpcSetEnv( cEmpDest, "01",,, "CTB", "ACTB0021",,,,,)                                                                                                                                                                                                                 

bSeek := { |x| x[1] == 'CTR_FILIAL' }
nPos := ASCANX ( aDados, bSeek ) 
if nPos != 0
	cChave += aDados[nPos,2]
endif

bSeek := { |x| x[1] == 'CTR_GRUPO' }
nPos := ASCANX ( aDados, bSeek ) 
if nPos != 0
	cChave += aDados[nPos,2]
endif

dbSelectArea('CTR')
CTR->(dbSetOrder(1))
RecLock(CTR,!CTR->(dbSeek(cChave)))

	for nI := 1 to len(aDados)
		cComando := 'CTR->' + aDados[nI,1]
		&(cComando) := aDados[nI,2]
	next nI

CTR->(dbUnlock())

Return

/*--------------------------+---------------------------+----------------------+
| Rotina: ACTB0022          | Autor: Lucas J. C. Chagas | Data: 20/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Rotina de processamento dos registros.                            |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
User Function ACTB0022( aDados, cEmpDest )

Local aArea    := GetArea()
Local aCabec   := aClone(aDados[1])
Local aItens   := aClone(aDados[2])
Local aRecSX7  := {}
Local bError   := Nil
Local bSeek    := Nil
Local cChave   := ''
Local cComando := ''
Local cHora    := ''
Local cData    := ''
Local cArquivo := ''
Local lAchou   := .F.
Local nI       := 0
Local nPos     := 0
Local nX       := 0

Private lMsErroAuto := .F.

RpcSetEnv( cEmpDest, "01",,, "CTB", "ACTB0022",,,,,)                                                                                                                                                                                                                 

dbSelectArea('CT1')
CT1->(dbSetOrder(1))

bSeek := { |x| x[1] == 'CT1_FILIAL' }
nPos := ASCANX ( aCabec, bSeek ) 
if nPos != 0
	cChave += aCabec[nPos,2]
endif

bSeek := { |x| x[1] == 'CT1_CONTA' }
nPos := ASCANX ( aCabec, bSeek ) 
if nPos != 0
	cChave += aCabec[nPos,2]
endif

lAchou := iif(Empty(cChave), .F., iif(CT1->(dbSeek(cChave)), .T., .F.))

if !lAchou
	msExecAuto( { |x,y,z| CTBA020(x,y,z) }, aCabec, iif(lAchou,4,3), aItens )
	If lMsErroAuto <> Nil 	
		if lMsErroAuto		
			cHora := Time()
			cData := DtoC(Date())
			cArquivo := 'planocontas_' + DtoS(Date()) + StrTran(cHora, ':', '') + '.txt'
		
			//Adiciona informações da nota ao arquivo
			AutoGrLog( "Data..........: " + cData)
			AutoGrLog( "Hora..........: " + cHora)
		
			MostraErro( '\logs\', cArquivo )  
		
		EndIf
	EndIf
endif

Return