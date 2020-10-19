#INCLUDE "PROTHEUS.CH"                             
#INCLUDE "RWMAKE.CH"  


User Function BuscaPerg(aRegsOri)

	Local cGrupo	:= ''
	Local cOrdem	:= ''
	Local aRegAux   := {}
	Local aEstrut   := {}
	Local nCount    := 0
	Local nLenGrupo := 0
	Local nLenOrdem := 0
	Local nX	 	:= 0
	Local nY		:= 0    
	Local aRegs		:= aClone(aRegsOri)
	
	If ValType('aRegs') <> 'C'
		Return
	Endif      
	
	If Len(aRegs) <= 0
		Return
	Endif
	
	// Buscar Estrutura da tabela SX1
	dbSelectArea('SX1');dbSetOrder(1)
	aEstrut   := SX1->(dbStruct())
	nCount	  := Len(aEstrut)
	
	// Definir o Tamanho dos Campos de Pesquisa
	nLenGrupo := aEstrut[1][3] // Tamanho do campo X1_GRUPO
	nLenOrdem := aEstrut[2][3] // Tamanho do campo X1_ORDEM
	                   
	// Compatibilizando o Array de Perguntas
	For nX := 1 To Len(aRegs)
		aAdd(aRegAux,Array(nCount))
		For nY := 1 To nCount
			aRegAux[Len(aRegAux)][nY]:=Space(aEstrut[nY][3])
		Next nY
		For nY := 1 To nCount
			If nY <= Len(aRegs[nX])
				aRegAux[Len(aRegAux)][nY]:= aRegs[nX,nY]
			Endif	
		Next nY
	Next nX
	
	// Recarregando o Array de Peguntas compatibilizado
	aRegs := {}   
	aRegs := aClone(aRegAux)
	
	// Testando se ele nao ficou vazio
	If Len(aRegs) <= 0
		Return
	Endif
	
	// Buscando no SX1 e incluindo caso nao exista
	dbSelectArea('SX1')
	For nX := 1 to Len(aRegs)
		cGrupo := Padr(aRegs[nX,1],nLenGrupo)
		cOrdem := Padr(aRegs[nX,2],nLenOrdem)
		If !dbSeek(cGrupo+cOrdem,.F.)
			RecLock('SX1',.T.)
			For nY := 1 to nCount
				If nY <= Len(aRegs[nX])
					FieldPut(nY,aRegs[nX,nY])
				Endif	
			Next nY
			MsUnlock()
		Endif
	Next nX
	
Return
