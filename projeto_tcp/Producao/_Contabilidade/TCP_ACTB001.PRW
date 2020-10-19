#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"

/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Customização                                            |
+------------------+---------------------------------------------------------+
|Modulo            | Contabilidade Gerencial                                 |
+------------------+---------------------------------------------------------+
|Nome              | ACTB001                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Rotina para alteração de planos de contas na empresa    |
|                  | consolidadora                                           |
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
User Function ACTB001( cChave )
                                                 
Local aArea := GetArea()

Local aCabec    := {}
Local aItens    := {}
Local aItem     := {}
Local aCTR      := {}
Local aCT8      := {}
Local bSeek     := Nil
Local cComando  := ''
Local nI        := 0
Local nPos      := 0
Local nX
dbSelectArea('CT1')
CT1->(dbSetOrder(1))
if CT1->(dbSeek(cChave))
	aAux := FwSX3Util():GetAllFields("CT1")
	//if (TMPSX3->(dbSeek('CT1')))
		//while !TMPSX3->(EOF()) .and. TMPSX3->X3_ARQUIVO == 'CT1'
			//if X3Uso(TMPSX3->X3_USADO)
				For nX := 1 to len(aAux)
					if X3Uso(aAux[nX])
						cComando := 'CT1->' + aAux[nX]
						aAdd(aCabec, {aAux[nX], &(cComando), NIL})
					EndIf
				Next nX
			//endif
			//TMPSX3->(dbSkip())
		//enddo
	//endif
	
	dbSelectArea('CVD')
	CVD->(dbSetOrder(1))
	if CVD->(dbSeek(xFilial('CVD') + CT1->CT1_CONTA))
		while !CDV->(EOF()) .AND. (CVD->(CVD_FILIAL + CVD_CONTA ) == (xFilial('CVD') + CT1->CT1_CONTA))
			aAux := FwSX3Util():GetAllFields("CDV")
			//TMPSX3->(dbGoTop())
			//if (TMPSX3->(dbSeek('CVD')))
				//while !TMPSX3->(EOF()) .and. TMPSX3->X3_ARQUIVO == 'CVD'
				For nX := 1 to len(aAux)
					if X3Uso(aAux[nX])
						cComando := 'CDV->' + aAux[nX]
						aAdd(aItem, {aAux[nX], &(cComando), NIL})
					endif
					//TMPSX3->(dbSkip())
				Next nX
				//enddo
			//endif
			
			CDV->(dbSkip())
			
			aAdd(aItens, aClone(aItem))
			aItem := {}
		enddo
	endif
	
	// vai verificar relacionamento dos campos com outros registros
	bSeek := { |x| AllTrim(x[1]) == 'CT1_HP' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			dbSelectArea('CT8')
			CT8->(dbSetOrder(1))
			if (CT8->(dbSeek(xFilial('CT8') + aCabec[nPos,2])))
				aAux := FwSX3Util():GetAllFields("CT8")
				//TMPSX3->(dbGoTop())
				//if (TMPSX3->(dbSeek('CT8')))
					//while !TMPSX3->(EOF()) .and. TMPSX3->X3_ARQUIVO == 'CT8'
					For nX := 1 to len(aAux)
						if X3Uso(aAux[nX])
							cComando := 'CT8->' + aAux[nX]
							aAdd(aCT8, {aAux[nX], &(cComando)})
						endif
						//TMPSX3->(dbSkip())
					Next nX
					//enddo
				//endif
				
				U_ACTB002('CT8', aCT8)
			endif
		endif
	endif	
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_GRUPO' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			dbSelectArea('CTR')
			CTR->(dbSetOrder(1))
			if (CTR->(dbSeek(xFilial('CTR') + aCabec[nPos,2])))
				aAux := FwSX3Util():GetAllFields("CTR")
				//TMPSX3->(dbGoTop())
				//if (TMPSX3->(dbSeek('CTR')))
					//while !TMPSX3->(EOF()) .and. TMPSX3->X3_ARQUIVO == 'CTR'
					For nX := 1 to len(aAux)
						if X3Uso(aAux[nX])
							cComando := 'CTR->' + aAux[nX]
							aAdd(aCTR,  {aAux[nX], &(cComando)})
						endif
					Next nX
						//TMPSX3->(dbSkip())
					//enddo
				//endif
				
				U_ACTB002('CTR', aCTR)
			endif
		endif
	endif
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_CTASUP' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			U_ACTB001(xFilial('CT1') + aCabec[nPos,2])
		endif
	endif
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_CTAVM' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			U_ACTB001(xFilial('CT1') + aCabec[nPos,2])
		endif
	endif
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_CTARED' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			U_ACTB001(xFilial('CT1') + aCabec[nPos,2])
		endif
	endif
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_CTALP' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			U_ACTB001(xFilial('CT1') + aCabec[nPos,2])
		endif
	endif
	
	bSeek := { |x| AllTrim(x[1]) == 'CT1_CTAPON' }
	nPos := ASCANX ( aCabec, bSeek ) 
	if nPos != 0
		if !Empty(aCabec[nPos,2])
			U_ACTB001(xFilial('CT1') + aCabec[nPos,2])
		endif
	endif
	
	U_ACTB002('CT1', {aCabec, aItens})
endif

RestArea(aArea)

Return