#include "protheus.ch"
#include "topconn.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  Ё  WFATA02 Ё Autor ЁRodolfo Cesar                 Ё 16/06/14 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Rotina para cadastro de regras de c?omissao                 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function WFATA02()

#IFNDEF WINDOWS
	ScreenDraw("SMT050", 3, 0, 0, 0)
#ENDIF

Local cCadastro := "Regras Comerciais"
Local aCampBrow:= {}
Local aCores   := {}
aRotina := {	{ "Pesquisar"    ,"AxPesqui" , 0, 1},;
{ "Visualizar"   ,'ExecBlock("C7VIS",.F.,.F.)' , 0, 2},;
{ "Incluir"      ,'ExecBlock("C7INC",.F.,.F.)' , 0, 3},;
{ "Alterar"      ,'ExecBlock("C7ALT",.F.,.F.)' , 0, 4},;
{ "Excluir"      ,'ExecBlock("C7EXC",.F.,.F.)' , 0, 5} }

AADD(aCores,{"Empty(C7_EMISSAO).OR. C7_EMISSAO >= dDataBase " ,"BR_VERDE" })
AADD(aCores,{"C7_EMISSAO < dDataBase "                    ,"BR_VERMELHO" })

dbSelectArea("SC7")
dbSetOrder(1)

AADD(aCampBrow,{'Codigo'   ,'C7_PRODUTO' ,'C', 4,0,x3Picture("C7_PRODUTO" )})
AADD(aCampBrow,{'Descricao','C7_DESCRI' ,'C',40,0,x3Picture("C7_DESCRI" )})
AADD(aCampBrow,{'Data de?' ,'C7_EMISSAO'  ,'D', 8,0,x3Picture("C7_EMISSAO"  )})
AADD(aCampBrow,{'Data Ate?','C7_EMISSAO' ,'D', 8,0,x3Picture("C7_EMISSAO" )})
AADD(aCampBrow,{'Item'     ,'C7_ITEM'   ,'C', 3,0,x3Picture("C7_ITEM"   )})

mBrowse( 6,1,22,75,"SC7",aCampBrow,,,,,aCores)
Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Opcao de acesso para o Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza

User Function C7INC()

Local nOpcx   := 3
Local _nItem  := '01'
Local _nDesci := 0
Local _nDescf := 0
Local _nComis := 0

Local _l      := 0

Local _sAlias := Alias()
Local _sRec   := Recno()
Local _cCampos:= "C7_ITEM,C7_UM,C7_NUMSC,C7_QUANT"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("Sx3")
dbSetOrder(1)
dbSeek("SC7")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SC7")
	If AllTrim(X3_CAMPO)=="C7_FILIAL" .Or. AllTrim(X3_CAMPO)=="C7_PRODUTO"
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
dbSeek("SC7")
nUsado:=0

While !Eof() .And. (x3_arquivo == "SC7")
	If AllTrim(X3_CAMPO)=="C7_FILIAL" .Or. AllTrim(X3_CAMPO)=="C7_PRODUTO"
		dbSkip()
		Loop
	Endif
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel.AND. Alltrim(X3_CAMPO)$ Alltrim(_cCampos)
		IF nOpcx == 3
			nUsado:=nUsado+1
			IF x3_tipo == "C"
				aCOLS[1][nUsado] := SPACE(x3_tamanho)
				If Alltrim(x3_campo) == "C7_ITEM"
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
cVend    :=Space(6)
cNome    :=Space(30)
cDatde   :=dDataBase
cDatAte  :=cTod(Space(8))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTitulo:="Cadastro de Regras de ComissУes"
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
AADD(aC,{"cDescri"  ,{015,120} ,"Descricao"   ,"@!",,,})
AADD(aC,{"cVend"    ,{030,010} ,"Vendedor "   ,"@!",,"SA3",})
AADD(aC,{"cNome"    ,{030,120} ,"Nome       " ,"@!",,,})
AADD(aC,{"cDatDe"   ,{045,010} ,"Data De?  "  ,"@!",,,})
AADD(aC,{"cDatAte"  ,{045,120} ,"Data Ate?"   ,"@!",,,})




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
cLinhaOk:="ExecBlock('C7LINOK',.f.,.f.)"
cTudoOk:="ExecBlock('C7TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

cCodigo := (GetSx8Num("SC7","C7_PRODUTO"))


lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,aCordW,,.f.,,)

_nItem  := aScan(aHeader,{|x| x[2]=="C7_ITEM"})
_nDesci := aScan(aHeader,{|x| x[2]=="C7_UM"})
_nDescf := aScan(aHeader,{|x| x[2]=="C7_NUMSC"})
_nComis := aScan(aHeader,{|x| x[2]=="C7_QUANT"})


If lRetMod2 // Gravacao. . .
	For _l := 1 To Len(aCols)
		If !aCols[_l,Len(aHeader)+1]
			dbSelectArea("SC7")
			RecLock("SC7",.T.)
			SC7->C7_FILIAL  := xFilial("SC7")
			SC7->C7_PRODUTO  := cCodigo
			SC7->C7_DESCRI  := cDescri
			SC7->C7_FORNECE    := cVend
			SC7->C7_DESCRI    := cNome
			SC7->C7_EMISSAO   := cDatDe
			SC7->C7_EMISSAO  := cDatAte
			
			SC7->C7_ITEM    := aCols[_l,_nItem]
			SC7->C7_UM := aCols[_l,_nDesci]
			SC7->C7_NUMSC := aCols[_l,_nDescf]
			SC7->C7_QUANT  := aCols[_l,_nComis]
			MsUnLock()
		EndIf
	Next _l
	ConfirmSx8()
Endif

dbSelectArea(_sAlias)
dbGoto(_sRec)

Return

User Function C7Nome(nCpo)

Local nCampo := nCpo
Local lRet   := .T.

If !Empty(cVend)
	If nCampo == 6
		
		If lRet
			dbSelectArea("SA3")
			dbSetOrder(1)
			dbSeek(xFilial() + cVend)
			If Found()
				cNome := SA3->A3_NOME
			EndIf
		EndIf
	Endif
Endif

Return( lRet )


User Function C7LINOK

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
			Case cCab == "C7_ITEM"
				_nItem   := _idx
			Case cCab == "C7_UM"
				_nDesci := _idx
			Case cCab == "C7_NUMSC"
				_nDescf := _idx
			Case cCab == "C7_QUANT"
				_nComis := _idx
		EndCase
		
	Next _idx
	
	If _nDescf==0 .Or. Empty(aCols[n,_nDescf])
		MsgStop("Informar o percentual maximo de desconto")
		Return(.F.)
	Endif
	
	
Endif

Return(.T.)


User Function C7TUDOK()

If Empty(cCodigo)
	Return(.F.)
Else
	Return(.T.)
Endif

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  Ё  C7ALT   Ё Autor Ё Walter Caetano da Silva Data Ё 30/08/00 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Rotina de atualizacao de espeficicacoes Modelo 2           Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function C7ALT()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Opcao de acesso para o Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza

Local nOpcx   := 3
Local _nItem  := 0
Local _nDesci := 0
Local _nDescf := 0
Local _nComis := 0
Local _cCampos:= "C7_ITEM,C7_UM,C7_NUMSC,C7_NUMSC,C7_QUANT"
Local _l      := 0
Local _sAlias := Alias()
Local _sRec   := Recno()
Local _aArea  := GetArea()
Private _lRegra := .F.

DbSelectArea("SC6")
DbSetOrder(1)
While SC6->(!Eof())
	If SC6->C6_REGRA $ SC7->C7_PRODUTO .And. !lRegra
		MsgInfo("Essa regra jА foi utilizada e sС poderА ter a data de validade alterada!")
		_lRegra := .t.
	Endif
	DbSkip()
Enddo



//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("Sx3")
dbSetOrder(1)
dbSeek("SC7")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SC7")
	If AllTrim(X3_CAMPO)=="C7_FILIAL" .Or. AllTrim(X3_CAMPO)=="C7_PRODUTO"
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
//Ё Montando aCols                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//dbSelectArea("SC7")
//dbSetOrder(1)
cCodigo := SC7->C7_PRODUTO
dbSeek(xFilial("SC7")+cCodigo)


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Cabecalho do Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cCodigo  :=SC7->C7_PRODUTO
cDescri  :=SC7->C7_DESCRI
cVend    :=SC7->C7_FORNECE
cNome    :=SC7->C7_DESCRI
cDatde   :=SC7->C7_EMISSAO
cDatAte  :=SC7->C7_EMISSAO


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

dbSelectArea("SC7")
aCols := {}

While !EOF() .And. cCodigo==SC7->C7_PRODUTO
	aAdd(aCols,{SC7->C7_ITEM,SC7->C7_UM,SC7->C7_NUMSC,SC7->C7_QUANT,.F.})
	dbSkip()
EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cTitulo:="Alteracao de Regras Comerciais"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aC:={}

AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
AADD(aC,{"cDescri"  ,{015,120} ,"Descricao"   ,"@!",,     ,Iif(_lRegra,.f.,.t.)})
AADD(aC,{"cVend"    ,{030,010} ,"Vendedor "   ,"@!",,"SA3",Iif(_lRegra,.f.,.t.)})
AADD(aC,{"cNome"    ,{030,120} ,"Nome       " ,"@!",,,.F.})
AADD(aC,{"cDatDe"   ,{045,010} ,"Data De?  "  ,"@!",,     ,Iif(_lRegra,.f.,.t.)})
AADD(aC,{"cDatAte"  ,{045,120} ,"Data Ate?"   ,"@!",,     ,})


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
cLinhaOk:="ExecBlock('C7LINOK',.F.,.F.)"
cTudoOk:="ExecBlock('C7TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,aCordW,,.f.,,)

_nItem  := aScan(aHeader,{|x| x[2]=="C7_ITEM"})
_nDesci := aScan(aHeader,{|x| x[2]=="C7_UM"})
_nDescf := aScan(aHeader,{|x| x[2]=="C7_NUMSC"})
_nComis := aScan(aHeader,{|x| x[2]=="C7_QUANT"})

If lRetMod2 // Gravacao. . .
	For _l := 1 To Len(aCols)
		If !aCols[_l,Len(aHeader)+1]
			dbSelectArea("SC7")
			dbSetOrder(6)
			If !dbSeek(xFilial("SC7")+cCodigo+aCols[_l,_nItem])
				RecLock("SC7",.T.)
			Else
				RecLock("SC7",.F.)
			Endif
			SC7->C7_FILIAL  := xFilial("SC7")
			SC7->C7_PRODUTO  := cCodigo
			SC7->C7_DESCRI    := cNome
			SC7->C7_FORNECE    := cVend
			SC7->C7_CONDPAG := cCond
			SC7->C7_EMISSAO   := cDatDe
			SC7->C7_EMISSAO  := cDatAte
			SC7->C7_PZMEDIO := cMedia
			
			SC7->C7_ITEM    := aCols[_l,_nItem]
			SC7->C7_UM := aCols[_l,_nDesci]
			SC7->C7_NUMSC := aCols[_l,_nDescf]
			SC7->C7_QUANT  := aCols[_l,_nComis]
			
			MsUnLock()
		Else
			dbSelectArea("SC7")
			dbSetOrder(6)
			If dbSeek(xFilial("SC7")+cCodigo+aCols[_l,_nItem])
				RecLock("SC7",.F.)
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

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  Ё  C7VIS   Ё Autor Ё Luiz Carlos Vieira    Ё Data Ё 20/05/97 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Rotina de visualizacao de espeficicacoes Modelo 2          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function C7VIS()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Opcao de acesso para o Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
Local  nOpcx  := 1
Local _nItem  := 0
Local _nDesci := 0
Local _nDescf := 0
Local _nComis := 0
Local _cCampos:= "C7_ITEM,C7_UM,C7_NUMSC,C7_NUMSC,C7_QUANT"
Local _l      := 0

Local _sAlias := Alias()
Local _sRec   := Recno()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montando aHeader                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("Sx3")
dbSetOrder(1)
dbSeek("SC7")
nUsado:=0
aHeader:={}
While !Eof() .And. (x3_arquivo == "SC7")
	If AllTrim(X3_CAMPO)=="C7_FILIAL" .Or. AllTrim(X3_CAMPO)=="C7_PRODUTO"
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
//Ё Montando aCols                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodigo := SC7->C7_PRODUTO
dbSeek(xFilial("SC7")+cCodigo)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Cabecalho do Modelo 2                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodigo  :=SC7->C7_PRODUTO
cDescri  :=SC7->C7_DESCRI
cNome    :=SC7->C7_DESCRI
cVend    :=SC7->C7_FORNECE
cDatde   :=SC7->C7_EMISSAO
cDatAte  :=SC7->C7_EMISSAO


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis do Rodape do Modelo 2                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("SC7")
aCols := {}

While !EOF() .And. cCodigo==SC7->C7_PRODUTO
	aAdd(aCols,{SC7->C7_ITEM,SC7->C7_UM,SC7->C7_NUMSC,SC7->C7_QUANT,.F.})
	dbSkip()
EndDo

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Titulo da Janela                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cTitulo:="Cadastro de Regras de ComissУes"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aC:={}

AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
AADD(aC,{"cDescri"  ,{015,120} ,"Descricao"   ,"@!",,,})
AADD(aC,{"cVend"    ,{030,010} ,"Vendedor "   ,"@!",,"SA3",})
AADD(aC,{"cNome"    ,{030,120} ,"Nome       " ,"@!",,,.F.})
AADD(aC,{"cDatDe"   ,{045,010} ,"Data De?  "  ,"@!",,,})
AADD(aC,{"cDatAte"  ,{045,120} ,"Data Ate?"   ,"@!",,,})


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
cLinhaOk:="ExecBlock('C7LINOK',.f.,.f.)"
cTudoOk:="ExecBlock('C7TUDOK',.f.,.f.)"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada da Modelo2                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

dbSelectArea(_sAlias)
dbGoto(_sRec)

Return


User Function C7EXC() // ExclusЦo
If !( Eof() .And. Bof() )
	
	
	nOpcx  := 5
	_nItem  := 0
	_nDesci := 0
	_nDescf := 0
	_nComis := 0
	_cCampos:= "C7_ITEM,C7_UM,C7_NUMSC,C7_NUMSC,C7_QUANT"
	_l      := 0
	
	_sAlias := Alias()
	_sRec   := Recno()
	
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Montando aHeader                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("SC7")
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == "SC7")
		If AllTrim(X3_CAMPO)=="C7_FILIAL" .Or. AllTrim(X3_CAMPO)=="C7_PRODUTO"
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
	
	dbSelectArea("SC7")
	dbSetOrder(6)
	cCodigo := SC7->C7_PRODUTO
	dbSeek(xFilial("SC7")+cCodigo)
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis do Cabecalho do Modelo 2                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	cCodigo  :=SC7->C7_PRODUTO
	cDescri  :=SC7->C7_DESCRI
	cNome    :=SC7->C7_DESCRI
	cVend    :=SC7->C7_FORNECE
	cDatde   :=SC7->C7_EMISSAO
	cDatAte  :=SC7->C7_EMISSAO
	
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis do Rodape do Modelo 2                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	
	dbSelectArea("SC7")
	aCols := {}
	
	While !EOF() .And. cCodigo==SC7->C7_PRODUTO
		aAdd(aCols,{SC7->C7_ITEM,SC7->C7_UM,SC7->C7_NUMSC,SC7->C7_QUANT,.F.})
		dbSkip()
	EndDo
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Titulo da Janela                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	cTitulo:="Cadastro de Regras de ComissУes"
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Array com descricao dos campos do Cabecalho do Modelo 2      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aC:={}
	
	AADD(aC,{"cCodigo"  ,{015,010} ,"C╒d.Regra"   ,"@!",,,.F.})
	AADD(aC,{"cDescri"  ,{015,120} ,"Descricao"   ,"@!",,,})
	AADD(aC,{"cVend"    ,{030,010} ,"Vendedor "   ,"@!",,"SA3",})
	AADD(aC,{"cNome"    ,{030,120} ,"Nome       " ,"@!",,,.F.})
	AADD(aC,{"cDatDe"   ,{045,010} ,"Data De?  "  ,"@!",,,})
	AADD(aC,{"cDatAte"  ,{045,120} ,"Data Ate?"   ,"@!",,,})
	
	
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
	cLinhaOk:="ExecBlock('C7LINOK',.f.,.f.)"
	cTudoOk:="ExecBlock('C7TUDOK',.f.,.f.)"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Chamada da Modelo2                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	
	_nItem := aScan(aHeader,{|x| x[2]=="C7_ITEM"})
	
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
	
	If lRetMod2 // Exclusao. . .
		For _l := 1 To Len(aCols)
			dbSelectArea("SC7")
			dbSetOrder(6)
			If dbSeek(xFilial("SC7")+cCodigo+aCols[_l,_nItem])
				RecLock("SC7",.F.)
				dbDelete()
				MsUnLock()
			Endif
		Next _l
	Endif
	
	dbGoTop()
	
Endif

Return

User Function ValidAlt()

If Altera .and. _lRegra = .t.
	MsgInfo("Essa informaГЦo nЦo pode ser alterada porque a regra jА foi utilizada!!")
	Return .f.
Else
	Return .t.
Endif

Return

