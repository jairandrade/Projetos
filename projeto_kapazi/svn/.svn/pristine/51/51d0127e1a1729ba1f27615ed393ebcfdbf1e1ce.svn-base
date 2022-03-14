#include "PROTHEUS.CH"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Jair Andrade                                                                                                                    |
| Empresa: ALMA                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04.03.2021                                                                                                                       |
| Descricao: rotina que irá carregar o codigo do armazem para todas as linhas                                                            |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Alteração --inclua aqui a alteração efetuada nesta rotina.
User Function CargaARM()
	Local _nI
	local nPosLocal
	Local cArmazem

	nPosLocal := aScan(aHeader,{ |x| ALLTRIM(x[2]) == "D1_LOCAL" })
	cArmazem := aCols[1,nPosLocal]

	if !Empty(cArmazem)
		if(msgyesno('Replicar Armazem '+cArmazem+' para as demais linhas?','Replicação de armazém.'))
			For _nI := 1 to len(acols)
				aCols[_nI,nPosLocal] := cArmazem
			Next
		EndIf
	EndIf

RETURN

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Jair Andrade                                                                                                                    |
| Empresa: ALMA                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04.03.2021                                                                                                                       |
| Descricao: rotina que irá carregar o CENTRO DE CUSTO para todas as linhas                                                            |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Alteração --inclua aqui a alteração efetuada nesta rotina.
User Function CargaCC()
	Local _nI
	local nPosCcusto
	Local cCcusto

	nPosCcusto := aScan(aHeader,{ |x| ALLTRIM(x[2]) == "D1_CC" })
	cCcusto := aCols[1,nPosCcusto]

	if !Empty(cCcusto)
		if(msgyesno('Replicar Centro de Custo '+cCcusto+' para as demais linhas?','Replicação de C.Custo'))
			For _nI := 1 to len(acols)
				aCols[_nI,nPosCcusto] := cCcusto
			Next
		EndIf
	EndIf

RETURN




