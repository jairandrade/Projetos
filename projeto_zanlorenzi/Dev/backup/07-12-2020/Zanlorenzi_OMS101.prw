#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} OM200MNU
//Rotina para cadastro de EDI das Transportadoras
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OMS101()
	Private aItems:= {'Envio','Retorno'}

	#IFNDEF WINDOWS
		ScreenDraw("SMT050", 3, 0, 0, 0)
	#ENDIF

	aRotina := {	{ "Pesquisar"    ,"AxPesqui" , 0, 1},;
		{ "Visualizar"   ,'ExecBlock("ZA0VIS",.F.,.F.)' , 0, 2},;
		{ "Incluir"      ,'ExecBlock("ZA0INC",.F.,.F.)' , 0, 3},;
		{ "Alterar"      ,'ExecBlock("ZA0ALT",.F.,.F.)' , 0, 4},;
		{ "Excluir"      ,'ExecBlock("ZA0EXC",.F.,.F.)' , 0, 5},;
		{ "Legenda"      ,'ExecBlock("ZA0LEG",.F.,.F.)' , 0, 6} }

	dbSelectArea("ZA0")
	dbSetOrder(1)

	mBrowse( 6,1,22,75,"ZA0")
Return

/*/{Protheus.doc} ZA0INC()
//Rotina de inclusЦo de EDI das Transportadoras
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0INC()

	Local nOpcx   := 3
	Local _nDesci := 0
	Local _nDescf := 0
	Local _nComis := 0
	Local _l      := 0
	Local _sAlias := Alias()
	Local _sRec   := Recno()
	Local _cCampos:= "ZA0_CODIGO,ZA0_ITEM,ZA0_CAMPO,ZA0_TIPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TPDADO,ZA0_CONTEU"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZA0")
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == "ZA0")
		If AllTrim(X3_CAMPO)=="ZA0_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZA0_CODIGO"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
			nUsado:=nUsado+1
			cNome := AllTrim(X3_CAMPO)
			AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
				x3_tamanho, x3_decimal, x3_vlduser, x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aCols                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aCols:=Array(1,nUsado+1)
	dbSelectArea("Sx3")
	dbSeek("ZA0")
	nUsado:=0

	While !Eof() .And. (x3_arquivo == "ZA0")
		If AllTrim(X3_CAMPO)=="ZA0_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZA0_CODIGO"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel.AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
			IF nOpcx == 3
				nUsado:=nUsado+1
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
					If Alltrim(x3_campo) == "ZA0_ITEM"
						aCOLS[1][nUsado]:=  StrZero(1,Len(aCOLS[1][nUsado]))
					Endif
				Elseif x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				Elseif x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				Elseif x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			Endif
		Endif
		dbSkip()

	End
	aCOLS[1][nUsado+1] := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Cabecalho do Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cCodigo  :=Space(6)
	cDescri  :=Space(30)
	cOcor    :=Space(6)
	cNome    :=Space(30)
	cDatde   :=dDataBase
	cDatAte  :=cTod(Space(8))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cTitulo:="Cadastro de EDI das Transportadoras"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

	AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
	AADD(aC,{"cDescri"  ,{030,010} ,"Descricao"   ,"@!",,,})
	AADD(aC,{"cOcor" ,{045,010} ,"OcorrЙncia"   ,"@!",,"SX5EDI",})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aR:={}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com coordenadas da GetDados no modelo2                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aCGD:={150,005,050,200}
	aCordW:= {0,0,500,660}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacoes na GetDados da Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinhaOk:="ExecBlock('ZA0LINOK',.f.,.f.)"
	cTudoOk:="ExecBlock('ZA0TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

	cCodigo := (GetSx8Num("ZA0","ZA0_CODIGO"))


	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,"+ZA0_ITEM",,aCordW,,.f.,,)

	_nDesci := aScan(aHeader,{|x| x[2]=="ZA0_CAMPO"})
	_nDescf := aScan(aHeader,{|x| x[2]=="ZA0_POSINI"})
	_nComis := aScan(aHeader,{|x| x[2]=="ZA0_POSFIM"})
	_cTpDad := aScan(aHeader,{|x| x[2]=="ZA0_TPDADO"})
	_cTipo :=  aScan(aHeader,{|x| x[2]=="ZA0_TIPO"})
	_cConte := aScan(aHeader,{|x| x[2]=="ZA0_CONTEU"})


	If lRetMod2 // Gravacao. . .
		For _l := 1 To Len(aCols)
			If !aCols[_l,Len(aHeader)+1]
				dbSelectArea("ZA0")
				RecLock("ZA0",.T.)
				ZA0->ZA0_FILIAL  := xFilial("ZA0")
				ZA0->ZA0_CODIGO  := cCodigo
				ZA0->ZA0_DESCRI  := cDescri
				ZA0->ZA0_OCOR    := cOcor

				ZA0->ZA0_ITEM   := StrZero(_l,TamSX3("ZA0_ITEM")[1])
				ZA0->ZA0_CAMPO  := aCols[_l,_nDesci]
				ZA0->ZA0_POSINI := aCols[_l,_nDescf]
				ZA0->ZA0_POSFIM := aCols[_l,_nComis]
				ZA0_TPDADO      := aCols[_l,_cTpDad]
				ZA0_TIPO        := aCols[_l,_cTipo]
				ZA0_CONTEU      := aCols[_l,_cConte]
				MsUnLock()
			EndIf
		Next _l
		ConfirmSx8()
	Endif

	dbSelectArea(_sAlias)
	dbGoto(_sRec)

Return
/*/{Protheus.doc} ZA0LINOK()
//Rotina de validaГЦo das linhas da grid
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0LINOK
	Local _idx :=0
	_nUlt := Len(aCols[n])
	If !aCols[n,_nUlt] // Trata somente itens nao deletados. . .
		_idx    := 1
		_nItem  := 0
		_nDesci := 0
		_nDescf := 0
		_nComis := 0

		For _idx:=1 to Len(aHeader)
			cCab := AllTrim(aHeader[_idx,2])
			Do Case
			Case cCab == "ZA0_ITEM"
				_nItem   := _idx
			EndCase

		Next _idx

	Endif

Return(.T.)

/*/{Protheus.doc} ZA0LINOK()
//Rotina de validaГЦo de tudo ok 
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0TUDOK()
	Local lRet := .T.

	If Empty(cCodigo) .or. Empty(cDescri) .or. Empty(cOcor)
		MSGALERT( "Campos CСdigo, DescriГЦo e Ocorrencia sЦo obrigatorios. Estes campos devem estar preenchidos!", "Codigo EDI" )
		lRet := .F.
	Endif

	if Len(aCols) <=0 .and. lRet
		MSGALERT( "NЦo existem itens cadastrados neste EDI. favor cadastrar os itens!", "Itens EDI" )
		lRet := .F.
	ENDIF


Return Lret
/*/{Protheus.doc} ZA0ALT()
//Rotina de alteraГЦo do EDI das transportadoras
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0ALT()
	Local nOpcx   := 3
	Local _nItem  := 0
	Local _nDesci := 0
	Local _nDescf := 0
	Local _nComis := 0
	Local _cCampos:= "ZA0_CODIGO,ZA0_ITEM,ZA0_CAMPO,ZA0_TIPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TPDADO,ZA0_CONTEU"
	Local _l      := 0
	Local _sAlias := Alias()
	Local _sRec   := Recno()
	Local _aArea  := GetArea()
	Private _lRegra := .F.


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZA0")
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == "ZA0")
		If AllTrim(X3_CAMPO)=="ZA0_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZA0_CODIGO"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
				x3_tamanho, x3_decimal,x3_vlduser,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cCodigo  :=ZA0->ZA0_CODIGO
	dbSelectArea("ZA0")
	ZA0->(dbSetOrder(1))
	ZA0->(dbGoTop())
	ZA0->(dbSeek(xFilial("ZA0")+cCodigo))
	aCols := {}
	cCodigo  :=ZA0->ZA0_CODIGO
	cDescri  :=ZA0->ZA0_DESCRI
	cOcor    :=ZA0->ZA0_OCOR

	While !ZA0->(EOF()) .And. cCodigo==ZA0->ZA0_CODIGO
		aAdd(aCols,{ZA0_ITEM,ZA0_CAMPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TIPO,ZA0_TPDADO,ZA0_CONTEU,.F.})
		dbSkip()
	EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	cTitulo:="Cadastro de EDI das Transportadoras"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aC:={}

	AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
	AADD(aC,{"cDescri"  ,{030,010} ,"Descricao"   ,"@!",,,})
	AADD(aC,{"cOcor"    ,{045,010} ,"OcorrЙncia"   ,"@!",,"SX5EDI",})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aR:={}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com coordenadas da GetDados no modelo2                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aCGD:={150,005,050,200}
	aCordW:= {0,0,500,660}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacoes na GetDados da Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinhaOk:="ExecBlock('ZA0LINOK',.F.,.F.)"
	cTudoOk:="ExecBlock('ZA0TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,"+ZA0_ITEM",,aCordW,,.F.,,)

	_nDesci := aScan(aHeader,{|x| x[2]=="ZA0_CAMPO"})
	_nDescf := aScan(aHeader,{|x| x[2]=="ZA0_POSINI"})
	_nComis := aScan(aHeader,{|x| x[2]=="ZA0_POSFIM"})
	_cTpDad := aScan(aHeader,{|x| x[2]=="ZA0_TPDADO"})
	_cTipo := aScan(aHeader,{|x| x[2]=="ZA0_TIPO"})
	_cConte := aScan(aHeader,{|x| x[2]=="ZA0_CONTEU"})

	If lRetMod2 // Gravacao. . .
		For _l := 1 To Len(aCols)
			If !aCols[_l,Len(aHeader)+1]
				dbSelectArea("ZA0")
				dbSetOrder(2)
				If !dbSeek(xFilial("ZA0")+cCodigo+aCols[_l][1])
					RecLock("ZA0",.T.)
					ZA0->ZA0_FILIAL  := xFilial("ZA0")
					ZA0->ZA0_CODIGO  := cCodigo
					ZA0->ZA0_OCOR    := cOcor
				Else
					RecLock("ZA0",.F.)
				Endif

				ZA0->ZA0_DESCRI  := cDescri
				ZA0->ZA0_ITEM   := aCols[_l,_nItem]
				ZA0->ZA0_CAMPO  := aCols[_l,_nDesci]
				ZA0->ZA0_POSINI := aCols[_l,_nDescf]
				ZA0->ZA0_POSFIM := aCols[_l,_nComis]
				ZA0_TPDADO      := aCols[_l,_cTpDad]
				ZA0_TIPO        := aCols[_l,_cTipo]
				ZA0_CONTEU      := aCols[_l,_cConte]
				MsUnLock()
			Else
				dbSelectArea("ZA0")
				dbSetOrder(6)
				If dbSeek(xFilial("ZA0")+cCodigo+aCols[_l,_nItem])
					RecLock("ZA0",.F.)
					dbDelete()
					MsUnLock()
				Endif
			EndIf
		Next _l

	Endif

	dbSelectArea(_sAlias)
	dbGoto(_sRec)

	RestArea(_aArea)
	_lRegra := .f.

Return

/*/{Protheus.doc} ZA0LINOK()
//Rotina de visualizacao dos EDI das transportadoras
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0VIS()
	Local  nOpcx  := 1
	Local _cCampos:= "ZA0_CODIGO,ZA0_ITEM,ZA0_CAMPO,ZA0_TIPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TPDADO,ZA0_CONTEU"
	Local _sAlias := Alias()
	Local _sRec   := Recno()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("ZA0")
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == "ZA0")
		If AllTrim(X3_CAMPO)=="ZA0_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZA0_CODIGO"
			dbSkip()
			Loop
		Endif
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
				x3_tamanho, x3_decimal,x3_vlduser,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cCodigo  :=ZA0->ZA0_CODIGO
	cDescri  :=ZA0->ZA0_DESCRI
	cOcor    :=ZA0->ZA0_OCOR
	dbSelectArea("ZA0")
	ZA0->(dbSetOrder(1))
	ZA0->(dbGoTop())
	ZA0->(dbSeek(xFilial("ZA0")+cCodigo))
	dbSelectArea("ZA0")
	aCols := {}

	While !EOF() .And. cCodigo==ZA0->ZA0_CODIGO
		aAdd(aCols,{ZA0_ITEM,ZA0_CAMPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TIPO,ZA0_TPDADO,ZA0_CONTEU,.F.})
		dbSkip()
	EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	cTitulo:="Cadastro de EDI das Transportadoras"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aC:={}

	AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
	AADD(aC,{"cDescri"  ,{030,010} ,"Descricao"   ,"@!",,,})
	AADD(aC,{"cOcor"    ,{045,010} ,"OcorrЙncia"   ,"@!",,"SX5EDI",})


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aR:={}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com coordenadas da GetDados no modelo2                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	aCGD:={150,005,050,200}
	aCordW:= {0,0,500,660}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacoes na GetDados da Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cLinhaOk:="ExecBlock('ZA0LINOK',.f.,.f.)"
	cTudoOk:="ExecBlock('ZA0TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

//lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,aCordW,.T.)
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,"ZA0_ITEM",,aCordW,,.F.,,)

	dbSelectArea(_sAlias)
	dbGoto(_sRec)

Return

/*/{Protheus.doc} ZA0EXC()
//Rotina de exclusЦo dos EDI das transportadoras
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function ZA0EXC() // ExclusЦo
	Local _l := 0
	If !( Eof() .And. Bof() )


		nOpcx  := 5
		_nItem  := 0
		_nDesci := 0
		_nDescf := 0
		_nComis := 0
		_cCampos:= "ZA0_CODIGO,ZA0_ITEM,ZA0_CAMPO,ZA0_TIPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TPDADO,ZA0_CONTEU"
		_l      := 0

		_sAlias := Alias()
		_sRec   := Recno()



		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Montando aHeader                                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("Sx3")
		dbSetOrder(1)
		dbSeek("ZA0")
		nUsado:=0
		aHeader:={}
		While !Eof() .And. (x3_arquivo == "ZA0")
			If AllTrim(X3_CAMPO)=="ZA0_FILIAL" .Or. AllTrim(X3_CAMPO)=="ZA0_CODIGO"
				dbSkip()
				Loop
			Endif
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel.AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
				nUsado:=nUsado+1
				AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,,;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
			Endif
			dbSkip()
		End

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Montando aCols                                               Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		dbSelectArea("ZA0")
		dbSetOrder(1)
		cCodigo := ZA0->ZA0_CODIGO
		dbSeek(xFilial("ZA0")+cCodigo)


		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Variaveis do Cabecalho do Modelo 2                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		cCodigo  :=ZA0->ZA0_CODIGO
		cDescri  :=ZA0->ZA0_DESCRI
		cOcor    :=ZA0->ZA0_OCOR


		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Variaveis do Rodape do Modelo 2                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


		dbSelectArea("ZA0")
		aCols := {}

		While !EOF() .And. cCodigo==ZA0->ZA0_CODIGO
			aAdd(aCols,{ZA0_ITEM,ZA0_CAMPO,ZA0_TIPO,ZA0_POSINI,ZA0_POSFIM,ZA0_TPDADO,ZA0_CONTEU,.F.})
			dbSkip()
		EndDo

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Titulo da Janela                                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		cTitulo:="Cadastro de EDI das Transportadoras"

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aC:={}

		AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
		AADD(aC,{"cDescri"  ,{015,120} ,"Descricao"   ,"@!",,,})
		AADD(aC,{"cOcor"    ,{030,010} ,"Vendedor "   ,"@!",,"SA3",})


		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Array com descricao dos campos do Rodape do Modelo 2         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		aR:={}

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Array com coordenadas da GetDados no modelo2                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		aCGD:={150,005,050,200}
		aCordW:= {0,0,500,660}

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Validacoes na GetDados da Modelo 2                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cLinhaOk:="ExecBlock('ZA0LINOK',.f.,.f.)"
		cTudoOk:="ExecBlock('ZA0TUDOK',.f.,.f.)"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Chamada da Modelo2                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		// lRetMod2 = .t. se confirmou
		// lRetMod2 = .f. se cancelou

		_nItem := aScan(aHeader,{|x| x[2]=="ZA0_ITEM"})

		lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,"+ZA0_ITEM",,aCordW,,.f.,,)

		If lRetMod2 // Exclusao. . .
			For _l := 1 To Len(aCols)
				dbSelectArea("ZA0")
				dbSetOrder(1)
				If dbSeek(xFilial("ZA0")+cCodigo)
					RecLock("ZA0",.F.)
					dbDelete()
					MsUnLock()
				Endif
			Next _l
		Endif

		dbGoTop()

	Endif

Return
