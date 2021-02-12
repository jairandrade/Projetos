/**--------------------------------------------------------------------------------------------------------------- **/
/** PROPRIETARIO: KAPAZI                                                                                           **/
/** MODULO      : Estoque                                                                                          **/
/** NOME        : KPESTR13.RPW                                                                                     **/
/** FINALIDADE  : Executa ajustes de saldo em estoque após o fechamento                                            **/
/** SOLICITANTE : Laertes                                                                                          **/
/** DATA        : 26/03/2019                                                                                       **/
/** RESPONSAVEL : RSAC SOLUCOES                                                                                    **/
/**--------------------------------------------------------------------------------------------------------------- **/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH

#Define ENTER chr(13)+chr(10)

// quantidade zero custo negativo
// quantidade zero custo positivo
// quantidade e custo negativo
// quantidade negativo e custo positivo

User function KESTR13()
	Local aArea 	:= GetArea()
	Local dFecha	:= GetMv("MV_ULMES")
//	Local cCampos	:= "C9_OK,B9_DATA,D3_EMISSAO,B9_LOCAL,B9_COD,B1_DESC,B9_QINI,D3_QUANT,B9_VINI1,D3_CUSTO1,D3_TM,F5_TEXTO,REGNO"
	Local aCampos	:= GetCab()
	Local cTitulo	:= "Ajustes de estoque"
	Local lHasMark	:= .T.
	Local lMax		:= .T.
	Local aRet		:= {}
	local _aDados	:= {}

	// quantidade zero custo negativo
	_aDados := QZeroCNeg(dFecha,_aDados)
	// quantidade zero custo positivo
	_aDados := QZeroCPos(dFecha,_aDados)
	// quantidade negativa custo zero
	_aDados := QNegCNeg(dFecha,_aDados)
	// quantidade negativa custo positivo
	_aDados := QNegCPos(dFecha,_aDados)
	// quantidade positiva custo zero
	_aDados := QPosCZero(dFecha,_aDados)
	// quantidade positiva custo negativo
//	_aDados := QPosCNeg(dFecha,_aDados)
	
	if !Empty(_aDados)
		aRet := StaticCall(LISTBOX,dialogListBox,cTitulo,nil,"","",lHasMark,_aDados,aCampos,nil,lMax)

		If !Empty(aRet)
			Processa( {|| SD3Pro(aRet)},"Processando...","Aguarde...")
			MsgInfo("Processo finalizado.")
		Endif
	Else
		MsgInfo("Não foram encontrados dados para correção automática.")
	Endif

	RestArea(aArea)
Return

// só custo
// 320 - adicionar custo
// quantidade positiva custo zero
Static Function QPosCZero(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      > '0'   "+ENTER
	cQuery += "	AND B9_VINI1     =  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI 		"+ENTER
	cQuery += "				AND D3_CUSTO1  = B9_QINI * 0.01	"+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.												) // 1 data
				aadd(aItem,SB9->B9_DATA										) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 								) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL									) // 3 armazem
				aadd(aItem,SB9->B9_COD										) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)							) // 5 descricao
				aadd(aItem,SB9->B9_QINI										) // 6 quantidade inicial do proximo mes
				aadd(aItem,0			 									) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1									) // 8 valor inicial do proximo mes
				aadd(aItem,Round(SB9->B9_QINI * 0.01,TamSX3("D3_CUSTO1")[2])) // 9 valor que vai ser lançado
				aadd(aItem,"320"											) // 10 TM
				aadd(aItem,"ADICIONAR CUSTO"								) // 11 Descricao
				aadd(aItem,SB9->( Recno() )									) // 12 recno
				aadd(aDados,aItem)
			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados

// só custo
// 320 - adicionar custo
// quantidade positiva custo negativo
Static Function QPosCNeg(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      > '0'   "+ENTER
	cQuery += "	AND B9_VINI1     <  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI 		"+ENTER
	cQuery += "				AND D3_CUSTO1  = ( B9_QINI * 0.01 ) + B9_VINI1 "+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.																) // 1 data
				aadd(aItem,SB9->B9_DATA														) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 												) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL													) // 3 armazem
				aadd(aItem,SB9->B9_COD														) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)											) // 5 descricao
				aadd(aItem,SB9->B9_QINI														) // 6 quantidade inicial do proximo mes
				aadd(aItem,0					 											) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1													) // 8 valor inicial do proximo mes
				aadd(aItem,Round(( B9_QINI * 0.01 ) + B9_VINI1 * -1	,TamSX3("D3_CUSTO1")[2])) // 9 valor que vai ser lançado
				aadd(aItem,"320"															) // 10 TM
				aadd(aItem,"ADICIONAR CUSTO"												) // 11 Descricao
				aadd(aItem,SB9->( Recno() )													) // 12 recno
				aadd(aDados,aItem)
			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados

// só custo
// 320 - adicionar custo
// quantidade zero custo negativo
Static Function QZeroCNeg(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      = '0'   "+ENTER
	cQuery += "	AND B9_VINI1     <  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI 		"+ENTER
	cQuery += "				AND D3_CUSTO1  = B9_VINI1 * -1 	"+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.					) // 1 data
				aadd(aItem,SB9->B9_DATA			) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 	) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL		) // 3 armazem
				aadd(aItem,SB9->B9_COD			) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)) // 5 descricao
				aadd(aItem,SB9->B9_QINI			) // 6 quantidade inicial do proximo mes
				aadd(aItem,SB9->B9_QINI 		) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1		) // 8 valor inicial do proximo mes
				aadd(aItem,SB9->B9_VINI1 * -1	) // 9 valor que vai ser lançado
				aadd(aItem,"320"				) // 10 TM
				aadd(aItem,"ADICIONAR CUSTO"	) // 11 Descricao
				aadd(aItem,SB9->( Recno() )		) // 12 recno
				aadd(aDados,aItem)
			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados

// só custo
// 620 - remover custo
// qtde zero custo positivo
Static Function QZeroCPos(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      = '0'   "+ENTER
	cQuery += "	AND B9_VINI1     >  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI 	"+ENTER
	cQuery += "				AND D3_CUSTO1  = B9_VINI1	"+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.					) // 1 data
				aadd(aItem,SB9->B9_DATA			) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 	) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL		) // 3 armazem
				aadd(aItem,SB9->B9_COD			) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)) // 5 descricao
				aadd(aItem,SB9->B9_QINI			) // 6 quantidade inicial do proximo mes
				aadd(aItem,SB9->B9_QINI 		) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1		) // 8 valor inicial do proximo mes
				aadd(aItem,SB9->B9_VINI1 		) // 9 valor que vai ser lançado
				aadd(aItem,"620"				) // 10 TM
				aadd(aItem,"REMOVER CUSTO"		) // 11 Descricao
				aadd(aItem,SB9->( Recno() )		) // 12 recno
				aadd(aDados,aItem)
			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados

// movimento ambos
// 300 - adicionar quantidade e custo
// 600 - remover quantidade e custo
// quantidade e custo negativo
Static Function QNegCNeg(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      < '0'   "+ENTER
	cQuery += "	AND B9_VINI1     <  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI * -1 "+ENTER
	cQuery += "				AND D3_CUSTO1  = B9_VINI1 * -1 "+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.						) // 1 data
				aadd(aItem,SB9->B9_DATA				) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 		) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL			) // 3 armazem
				aadd(aItem,SB9->B9_COD				) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)	) // 5 descricao
				aadd(aItem,SB9->B9_QINI				) // 6 quantidade inicial do proximo mes
				aadd(aItem,SB9->B9_QINI * -1		) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1			) // 8 valor inicial do proximo mes
				aadd(aItem,SB9->B9_VINI1 * -1		) // 9 valor que vai ser lançado
				aadd(aItem,"300"					) // 10 TM
				aadd(aItem,"ADICIONAR CUSTO E QTDE"	) // 11 Descricao
				aadd(aItem,SB9->( Recno() )			) // 12 recno
				aadd(aDados,aItem)
			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados


// quantidade negativo e custo positivo
Static Function QNegCPos(dFecha,_aDados)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local aDados	:= aClone(_aDados)
	Local aItem		:= {}
	Local aRegs		:= {}
	Local nX		:= 0

	cQuery += "SELECT R_E_C_N_O_ SB9REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SB9")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*'                  "+ENTER
	cQuery += "	AND B9_FILIAL    = '"+xFilial("SB9")+"' "+ENTER
	cQuery += "	AND B9_DATA      = '"+DtoS(dFecha)	+"' "+ENTER
	cQuery += "	AND B9_QINI      < '0'   "+ENTER
	cQuery += "	AND B9_VINI1     >  0    "+ENTER
	cQuery += "	AND 0 = (SELECT COUNT(*) "+ENTER
	cQuery += "			 FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += "			 WHERE  "+ENTER
	cQuery += "					D_E_L_E_T_<>'*'        "+ENTER
	cQuery += "				AND D3_FILIAL  = B9_FILIAL "+ENTER
	cQuery += "				AND D3_COD     = B9_COD    "+ENTER
	cQuery += "				AND D3_LOCAL   = B9_LOCAL  "+ENTER
	cQuery += "				AND D3_EMISSAO = convert(char(8),DATEADD(d,1,B9_DATA),112) "+ENTER
	cQuery += "				AND D3_QUANT   = B9_QINI * -1 "+ENTER
//	cQuery += "				AND D3_CUSTO1  = B9_VINI1 * -1 "+ENTER
	cQuery += "				) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY   "+ENTER
	cQuery += "	B9_COD    "+ENTER
	cQuery += "	,B9_LOCAL "+ENTER
	cQuery += "	,B9_VINI1 "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	(cTemp)->( DbEval( {|| aadd(aRegs,(cTemp)->SB9REGNO) } ) )

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	For nX := 1 to Len(aRegs)
		SB9->( DbGoTo( aRegs[nX] ) )
		If SB9->( Recno() ) == aRegs[nX]
			SB1->( DbSetOrder(1) )
			if SB1->( MsSeek(xFilial("SB1") + SB9->B9_COD ) )
				aItem := {}
				aadd(aItem,.F.						) // 1 data
				aadd(aItem,SB9->B9_DATA				) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 		) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL			) // 3 armazem
				aadd(aItem,SB9->B9_COD				) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)	) // 5 descricao
				aadd(aItem,SB9->B9_QINI				) // 6 quantidade inicial do proximo mes
				aadd(aItem,SB9->B9_QINI * -1		) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1			) // 8 valor inicial do proximo mes
				aadd(aItem,SB9->B9_VINI1 * -1		) // 9 valor que vai ser lançado
				aadd(aItem,"300"					) // 10 TM
				aadd(aItem,"ADICIONAR "	) // 11 Descricao
				aadd(aItem,SB9->( Recno() )			) // 12 recno
				aadd(aDados,aItem)

				aItem := {}
				aadd(aItem,.F.						) // 1 data
				aadd(aItem,SB9->B9_DATA				) // 1 data
				aadd(aItem,SB9->B9_DATA + 1 		) // 2 data q vai ser lancada
				aadd(aItem,SB9->B9_LOCAL			) // 3 armazem
				aadd(aItem,SB9->B9_COD				) // 4 produto
				aadd(aItem,AllTrim(SB1->B1_DESC)	) // 5 descricao
				aadd(aItem,SB9->B9_QINI				) // 6 quantidade inicial do proximo mes
				aadd(aItem,SB9->B9_QINI * -1		) // 7 quantidade que vai ser lançado
				aadd(aItem,SB9->B9_VINI1			) // 8 valor inicial do proximo mes
				aadd(aItem,SB9->B9_VINI1 * -1		) // 9 valor que vai ser lançado
				aadd(aItem,"620"					) // 10 TM
				aadd(aItem,"REMOVER CUSTO"			) // 11 Descricao
				aadd(aItem,SB9->( Recno() )			) // 12 recno
				aadd(aDados,aItem)

			Endif
		Endif
	Next

	RestArea(aArea)
Return aDados

Static Function SD3Pro(_aDados)
	Local	aArea		:= GetArea()
	Local 	aRet	 	:= {}
	local 	cDoc		:= ""
	Local 	aAuto		:= ""
	Local 	dDtBkp		:= dDataBase
	Local	nX			:= 0
	Private lMsErroAuto := .F.
	
	ProcRegua(0)
	IncProc()
	IncProc()
	
	ProcRegua(Len(_aDados))
	
	For nX := 1 to Len(_aDados)
		IncProc()
		aAuto	:= {}
		cDoc	:= GetSxENum("SD3","D3_DOC",1)
//		"C9_OK,B9_DATA,D3_EMISSAO,B9_LOCAL,B9_COD,B1_DESC,B9_QINI,D3_QUANT,B9_VINI1,D3_CUSTO1,D3_TM,REGNO"

		dDataBase := _aDados[nX][03]

		aadd(aAuto,{"D3_FILIAL"	,xFilial("SD3")				,Nil})
		aadd(aAuto,{"D3_TM"		,_aDados[nX][11]			,Nil})
		aadd(aAuto,{"D3_COD"	,_aDados[nX][05]			,Nil})
		aadd(aAuto,{"D3_DOC"	,cDoc						,Nil})
		aadd(aAuto,{"D3_QUANT"	,_aDados[nX][08]			,Nil})
		aadd(aAuto,{"D3_LOCAL"	,_aDados[nX][04]			,Nil})
		aadd(aAuto,{"D3_CUSTO1"	,_aDados[nX][10]			,Nil})
		aadd(aAuto,{"D3_EMISSAO",dDataBase					,Nil})
		aadd(aAuto,{"D3_OBSERVA","KESTR13 AJUSTE SALDOS"	,Nil})

		Begin Transaction
			
			lMsErroAuto := .F.
			
			MsExecAuto({|x, y| mata240(x, y)}, aAuto, 3)

			If lMsErroAuto
				DisarmTransactions()
				MostraErro()
			EndIf

		End Transaction
	Next

	dDataBase := dDtBkp

	RestArea(aArea)
Return

Static Function GetCab()
	Local aRet	:= {}
	Local aItem	:= {}

	aItem := {}
	aadd(aItem,"Marcador"	)
	aadd(aItem,""			)
	aadd(aItem,1			)
	aadd(aItem,0			)
	aadd(aItem,"L"			)
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B9_DATA")
	aadd(aItem,"B9_DATA"				) // 1 campo
	aadd(aItem,"Data SB9"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("D3_EMISSAO")
	aadd(aItem,"D3_EMISSAO"				) // 1 campo
	aadd(aItem,"Data será lançada"		) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B9_LOCAL")
	aadd(aItem,"B9_LOCAL"				) // 1 campo
	aadd(aItem,"Armazém"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B9_COD")
	aadd(aItem,"B9_COD"					) // 1 campo
	aadd(aItem,"Produto"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B1_DESC")
	aadd(aItem,"B1_DESC"				) // 1 campo
	aadd(aItem,"Descrição"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B9_QINI")
	aadd(aItem,"B9_QINI"				) // 1 campo
	aadd(aItem,"Qtde SB9"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("D3_QUANT")
	aadd(aItem,"D3_QUANT"				) // 1 campo
	aadd(aItem,"Qtde Será Lançado"		) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("B9_VINI1")
	aadd(aItem,"B9_VINI1"				) // 1 campo
	aadd(aItem,"Custo SB9"				) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("D3_CUSTO1")
	aadd(aItem,"D3_CUSTO1"				) // 1 campo
	aadd(aItem,"Custo Será Lançado"		) // 2 titulo
	aadd(aItem,fieldSize("D3_CUSTO1")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("D3_TM")
	aadd(aItem,"D3_TM"				) // 1 campo
	aadd(aItem,"Tipo Mov"			) // 2 titulo
	aadd(aItem,fieldSize("D3_TM")	) // 3 tamanho
	aadd(aItem,aTam[2]				) // 4 decimal
	aadd(aItem,aTam[3]				) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	aTam 	:= TamSx3("F5_TEXTO")
	aadd(aItem,"F5_TEXTO"			) // 1 campo
	aadd(aItem,"AÇÃO"				) // 2 titulo
	aadd(aItem,fieldSize("F5_TEXTO")) // 3 tamanho
	aadd(aItem,aTam[2]				) // 4 decimal
	aadd(aItem,aTam[3]				) // 5 tipo
	aadd(aRet,aItem)

	aItem := {}
	aadd(aItem,"REGNO"	) // 1 campo
	aadd(aItem,"Recno"	) // 2 titulo
	aadd(aItem,30		) // 3 tamanho
	aadd(aItem,0		) // 4 decimal
	aadd(aItem,"N"		) // 5 tipo
	aadd(aRet,aItem)

Return aRet

Static Function fieldSize(cCampo)
Return StaticCall(LISTBOX,fieldSize,cCampo)




