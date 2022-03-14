#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VCL030    ºAutor  ³Luiz Casagrande     º Data ³  18/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório Mapa de Carregamento (Grafico)                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VCL030

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CPERG,NHEIGHT,LBOLD,LUNDERLINE,OFONT")
SetPrvt("OPRINT,AIMP,ADRIVER,XCOLIMP")
SetPrvt("_NFOL")
SetPrvt("_LIN")
SetPrvt("CFILELOGO")
SetPrvt("CSTARTPATH")

Private oFont, cCode
nHeight   :=  8
lBold     := .F.
lUnderLine:= .F.
cPerg     := "VCL030    "
nomeprog  := "VCL030"

AjustaSX1()
pergunte(cPerg,.T.)

//define tamanho das fontes
oFont1 := TFont():New( "Courier New",,07,,.t.,,,,,.f. )
oFont2 := TFont():New( "Courier New",,07,,.f.,,,,,.f. )
oFont3 := TFont():New( "Courier New",,08,,.t.,,,,,.f. )
oFont4 := TFont():New( "Courier New",,08,,.f.,,,,,.f. )
oFont5 := TFont():New( "Courier New",,10,,.t.,,,,,.f. )
oFont6 := TFont():New( "Courier New",,10,,.f.,,,,,.f. )
oFont7 := TFont():New( "Courier New",,12,,.f.,,,,,.f. )
oFont8 := TFont():New( "Arial      ",,12,,.t.,,,,,.f. )
oFont9 := TFont():New( "Courier New",,18,,.t.,,,,,.f. )
oFont10:= TFont():New( "Courier New",,14,,.f.,,,,,.f. )

oPrint := TMSPrinter():New( )

aImp       := {}
aDriver    := LeDriver()
xColImp    := ""
_nFol 	   := 0
_lin       := 0

_nTipo  :=0
_aSC5   :=GetArea("SC5")
_aSD2   :=GetArea("SD2")
_aSA1   :=GetArea("SA1")
_aSB1   :=GetArea("SB1")
_aSBM   :=GetArea("SBM")
_aSC9   :=GetArea("SC9")
_aSC6   :=GetArea("SC6")
_aSA4   :=GetArea("SA4")

cSql    :=Space(01)

SC9->(DbSetOrder(2))

SC5->(DbSetOrder(1))
IF !SC5->(DbSeek(xFilial("SC5") + MV_PAR01))
	alert('O Pedido '+MV_PAR01+' nao existe!')
	RETURN
ENDIF

/*
If SC5->C5_TOP <> "03" .And. SM0->M0_CODIGO == "01"
	SA4->(DbSeek(xFilial("SA4") + SC5->C5_TRANSP))
	_cTransp:= SA4->A4_COD
	_cNome  := SA4->A4_NOME
	_cPlaca := SC5->C5_PLACA
	//Validacao de placa do caminhao
	If SC5->C5_PLACA == SPACE(08) .or. SC5->C5_TRANSP == SPACE(06)
		_lSaida    := .f.
		//_cPlaca    := SPACE(08)
		//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criacao da Interface                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 200,430 To 500,700 Dialog oDlg Title OemToAnsi("Vinícola Campo Largo")
		@ 7,25    Say OemToAnsi("< I N F O R M E   OS   D A D O S>") COLOR 255
		@ 20,8    Say OemToAnsi("T.R.A.N.S.P.") COLOR 100
		@ 20,50   Say OemToAnsi("N.O.M.E   T.R.A.N.S.P") COLOR 100
		@ 30,8    GET _cTransp F3 "SA4" valid  ((Vazio() .or. existcpo("SA4")) .and. VALIDNOME())
		@ 30,50   GET _cNome object onome valid _cNome == SA4->A4_NOME
		@ 45,8    Say OemToAnsi("P.L.A.C.A.") COLOR 100
		@ 55,8    GET _cPlaca //valid !Empty(_cPlaca)
		@ 120,53  BmpButton Type 1 Action (GrvPlac())
		Activate Dialog oDlg Center valid _lSaida
	Endif
	
Endif
*/

cQry2 := " SELECT C5_TIPO,C5_NUM,A1_COD,A1_LOJA,A1_DOCS "
cQry2 += " FROM "+RetSqlName("SC5") + " SC5,"+RetSqlName("SA1") + " SA1 "
cQry2 += " WHERE C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND "
cQry2 += " C5_TIPO NOT IN ('D','B') AND A1_DOCS = 'S' AND "
cQry2 += " C5_NUM = '"+MV_PAR01+"' AND "
cQry2 += " C5_FILIAL =  '"+xfilial("SC5")+"' AND A1_FILIAL =  '"+xfilial("SA1")+"' AND "
cQry2 += " SC5.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "

TCQUERY cQry2 NEW ALIAS "TRC"

IF !Empty(TRC->C5_NUM)
	ExecBlock("VCL084B")
Endif

dbSelectArea("TRC")
DbCloseArea("TRC")

IMPPED()

Return

Static Function GrvPlac()
Close(oDlg)      
RecLock("SC5",.F.)
SC5->C5_PLACA := _cPlaca
SC5->C5_TRANSP:= _cTransp
SC5->C5_NOMETRA:=_cNome
MsUnLock("SC5")   
_lSaida:= .t.

Return


Static Function IMPPED()

if SC5->C5_NOTA <> SPACE(06)
	
	_nTipo:=1
	
	cSql := "SELECT D2_DOC, D2_PEDIDO, D2_CLIENTE, D2_LOJA, A1_NOME, A1_MUN,A1_BAIRRO,A1_EST ,C5_PLACA, D2_COD, B1_DESC, D2_QUANT, D2_GRUPO, D2_TOTAL, D2_DESC, BM_DESC,A1_EST, B1_PESO, B1_PESBRU,A1_INSCR, A1_CGC, C5_DESPREC, C5_CONPAG  "
	
	cSql += "FROM " +RetSqlName("SBM") + " SBM, "+ RetSqlName("SD2") + " SD2, " + RetSqlName("SA1") + " SA1,  " + RetSqlName("SC5") + " SC5,  " + RetSqlName("SB1") + " SB1  "
	
	cSql += "WHERE D2_FILIAL           = '"+xfilial("SD2")       +"'    "
	cSql += "AND A1_FILIAL             = '"+xfilial("SA1")       +"'    "
	cSql += "AND C5_FILIAL             = '"+xfilial("SC5")       +"'    "
	cSql += "AND B1_FILIAL             = '"+xfilial("SB1")       +"'    "
	cSql += "AND BM_FILIAL             = '"+xfilial("SBM")       +"'    "
	
	
	cSql += "AND C5_NUM                = '"+MV_PAR01             +"' "
	cSql += "AND C5_NOTA               = D2_DOC     "
	cSql += "AND C5_SERIE              = D2_SERIE   "
	cSql += "AND C5_CLIENTE            = D2_CLIENTE "
	cSql += "AND C5_LOJACLI            = D2_LOJA    "
	cSql += "AND D2_TIPO               = 'N'    "
	cSql += "AND A1_COD                = D2_CLIENTE "
	cSql += "AND A1_LOJA               = D2_LOJA    "
	cSql += "AND B1_COD                = D2_COD     "
	cSql += "AND BM_GRUPO              = D2_GRUPO   "
	
	
	cSql += "AND SD2.D_E_L_E_T_ = ' ' "
	cSql += "AND SA1.D_E_L_E_T_ = ' ' "
	cSql += "AND SC5.D_E_L_E_T_ = ' ' "
	cSql += "AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "AND SBM.D_E_L_E_T_ = ' ' "
	
	cSql += "ORDER BY  D2_GRUPO ASC  "
Else
	_nTipo:=2
	cSql := "SELECT C6_NUM, C6_CLI, C6_LOJA, A1_NOME,A1_MUN,A1_BAIRRO,A1_EST, C5_PLACA, C5_NOTA, C5_DESPREC, C5_CONPAG, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_VALOR, C6_DESCONT, B1_SUBGR1,BM_DESC,A1_EST, C6_ITEM, B1_PESO, B1_PESBRU,A1_INSCR, A1_CGC   "
	
	cSql += "FROM " +RetSqlName("SBM") + " SBM, "+ RetSqlName("SC6") + " SC6, " + RetSqlName("SA1") + " SA1,  " + RetSqlName("SC5") + " SC5,  " + RetSqlName("SB1") + " SB1  "
	
	cSql += "WHERE C6_FILIAL           = '"+xfilial("SC6")       +"'    "
	cSql += "AND A1_FILIAL             = '"+xfilial("SA1")       +"'    "
	cSql += "AND C5_FILIAL             = '"+xfilial("SC5")       +"'    "
	cSql += "AND B1_FILIAL             = '"+xfilial("SB1")       +"'    "
	cSql += "AND BM_FILIAL             = '"+xfilial("SBM")       +"'    "
	
	cSql += "AND C6_NUM                = '"+MV_PAR01             +"' "
	
	cSql += "AND A1_COD                = C6_CLI "
	cSql += "AND A1_LOJA               = C6_LOJA    "
	cSql += "AND C5_NUM                = C6_NUM  "
	cSql += "AND C5_CLIENTE            = C6_CLI "
	cSql += "AND C5_LOJACLI            = C6_LOJA    "
	cSql += "AND B1_COD                = C6_PRODUTO "
	cSql += "AND BM_GRUPO              = B1_SUBGR1   "
	
	
	cSql += "AND SC6.D_E_L_E_T_ = ' ' "
	cSql += "AND SA1.D_E_L_E_T_ = ' ' "
	cSql += "AND SC5.D_E_L_E_T_ = ' ' "
	cSql += "AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "AND SBM.D_E_L_E_T_ = ' ' "
	
	cSql += "ORDER BY  B1_SUBGR1 ASC  "
Endif


If Select ("TRB") > 0
   DbSelectArea("TRB")
	TRB->(DbCloseArea())
Endif	

DbUseArea( .T., "TOPCONN", TCGenQry(,,cSQL), "TRB",.T., .F.)

TRB->(DbGoTop())

oPrint:StartPage()   // Inicia uma nova página
oPrint:say(120  ,1650,dtoc(Date())                                                                   ,oFont8)
oPrint:say(170  ,1650,Time()                                                                         ,oFont8)
oPrint:say(070  ,50  ,"Pedido: " + IIF(_nTipo==1,TRB->D2_PEDIDO ,TRB->C6_NUM )                       ,oFont9)
oPrint:say(170  ,50  ,"Nota Fiscal   : " + IIF(_nTipo==1,TRB->D2_DOC    ,TRB->C5_NOTA)               ,oFont8)
oPrint:say(220  ,50  ,"Clinte        : " + IIF(_nTipo==1,TRB->D2_CLIENTE,TRB->C6_CLI)                ,oFont8)
oPrint:say(220  ,550 ,"IE: "                                                                         ,oFont8)
oPrint:say(220  ,700 ,ALLTRIM(Transform(TRB->A1_INSCR,"@R 999.999.999-9"))                                                                  ,oFont8)
oPrint:say(270  ,50  ,"Loja          : " + IIF(_nTipo==1,TRB->D2_LOJA   ,TRB->C6_LOJA)               ,oFont8)
oPrint:say(270  ,550 ,"CNPJ: "                                                                        ,oFont8)
oPrint:say(270  ,700 ,ALLTRIM(Transform(TRB->A1_CGC,"@R 99.999.999.9999-99"))                                                                    ,oFont8)
oPrint:say(320  ,50  ,"Nome Cliente  : " + substr(TRB->A1_NOME,1,34)                                 ,oFont8)
oPrint:say(370  ,50  ,"Municipio/Bairro  : " + alltrim(TRB->A1_MUN)+"-"+TRB->A1_EST+"/"+alltrim(TRB->A1_BAIRRO),oFont8)
oPrint:say(420  ,50  ,"Placa Caminhão: " + TRB->C5_PLACA     ,oFont8)

oPrint:Line (470,50,470,2000)

oPrint:say(490  ,50  ,"CÓDIGO"                                                                      ,oFont8)
oPrint:say(490  ,350 ,"DESCRIÇÃO"                                                                   ,oFont8)
oPrint:say(490  ,1600,"QUANTIDADE"                                                                  ,oFont8)

_nPLiq := 0
_nPBru := 0
_nVLiq := 0
_nVBru := 0
_lBloq := 0
_Total := 0
_nLin  := 490
While !TRB->(Eof())
	_nLin := _nLin + 50
	_Grupo := IIF(_nTipo==1,TRB->D2_GRUPO   ,TRB->B1_SUBGR1)
	_TotGr := 0
	While IIF(_nTipo == 1,TRB->D2_GRUPO,TRB->B1_SUBGR1) == _Grupo
		_nLin := _nLin + 50
		oPrint:say(_nLin,50  ,IIF(_nTipo == 1,TRB->D2_COD ,TRB->C6_PRODUTO)                            ,oFont7)
		oPrint:say(_nLin,350 ,TRB->B1_DESC                                                             ,oFont7)
		oPrint:say(_nLin,1535,IIF(_nTipo == 1,Transform(TRB->D2_QUANT,"@E 99,999,999"),Transform(TRB->C6_QTDVEN,"@E 99,999,999")),oFont7)
		_TotGr:= _TotGr + IIF(_nTipo == 1,TRB->D2_QUANT,TRB->C6_QTDVEN)
		_cdesc:= TRB->BM_DESC
		_nPLiq:= _nPLiq + TRB->B1_PESO   * IIF(_nTipo == 1,TRB->D2_QUANT ,TRB->C6_QTDVEN)
		_nPBru:= _nPBru + TRB->B1_PESBRU * IIF(_nTipo == 1,TRB->D2_QUANT ,TRB->C6_QTDVEN)
		_nVLiq:= _nVLiq + IIF(_nTipo == 1,(TRB->D2_TOTAL-TRB->D2_DESC),(TRB->C6_VALOR-TRB->C6_DESCONT))
		_nVBru:= _nVBru + IIF(_nTipo == 1,(TRB->D2_TOTAL),(TRB->C6_VALOR))
		If _nTipo == 2 .and. _lBloq == 0
			//            SC9->(DbSeek(xFilial("SC9") + TRB->C6_CLI + TRB->C6_LOJA + TRB->C6_NUM + TRB->C6_ITEM))
			//            If !Empty(SC9->C9_BLEST) .OR. !Empty(SC9->C9_BLCRED)
			//               _lBloq:=1
			//            Endif
			_cQry := " SELECT * FROM SC9010 WHERE D_E_L_E_T_ <> '*' AND "
			_cQry += " C9_FILIAL = '"+xfilial("SC5")+"' AND C9_PEDIDO = '"+TRB->C6_NUM+"' AND "
			_cQry += " (C9_BLEST <> '' OR C9_BLEST <> '') "
			
			TCQUERY _cQry NEW ALIAS "TRC"
			TRC->(dbGoTop())
			
			
			If !Empty(TRC->C9_PEDIDO)
				_lBloq := 1
			EndIf
			
			dbSelectArea("TRC")
			DbCloseArea("TRC")
			
			
		Endif
		TRB->(DbSkip())
		
		if _nLin > 3000
			oPrint:EndPage() 		// Finaliza a pagina
			oPrint:StartPage()   // Inicia uma nova página
			oPrint:say(50,50,"Continuação do Pedido: " + IIF(_nTipo==1,TRB->D2_PEDIDO ,TRB->C6_NUM ),oFont9)
			_nLin := 100
		endif	

	End
	
	_nLin := _nLin + 50
	_Total:= _Total + _TotGr
	oPrint:say(_nLin,50,"SUB-TOTAL DO GRUPO : "                                                        ,oFont8)
	//oPrint:say(_nLin,350,_cdesc                                                                       ,oFont8)
	oPrint:say(_nLin,1650,Transform(_TotGr,"@E 99,999,999")                                           ,oFont8)
End

_nLin := _nLin + 50
oPrint:say(_nLin,50,"TOTAL VOLUMES: "                                                                ,oFont8)
oPrint:say(_nLin,1650,Transform(_Total,"@E 99,999,999")                                              ,oFont8)
_nLin := _nLin + 100

If _lBloq == 1
	oPrint:say(_nLin,50,"PEDIDO ENCONTRA-SE BLOQUEADO "                                               ,oFont8)
Endif
_nLin := _nLin + 100


//Alteração p/ carimbo -- Rafael
if _nLin < 3000
	oPrint:say(_nLin,50  ,"PESO LIQ   = "                                                                ,oFont8)
	oPrint:say(_nLin,1200 ,"PESO BRUTO = "                                                                ,oFont8)
	oPrint:say(_nLin,400 ,Alltrim(Transform(_nPLiq,"@E 99,999,999.99"))                                  ,oFont8)
	oPrint:say(_nLin,1700,Alltrim(Transform(_nPBru,"@E 99,999,999.99"))                                  ,oFont8)

	_nLin  = _nLin + 50

	oPrint:say(_nLin,50  ,"VALOR C/DESC = "                                                                ,oFont8)
	oPrint:say(_nLin,1200 ,"VALOR S/DESC = "                                                                ,oFont8)
	oPrint:say(_nLin,400 ,Alltrim(Transform(_nVLiq,"@E 99,999,999.99"))                                  ,oFont8)
	oPrint:say(_nLin,1700,Alltrim(Transform(_nVBru,"@E 99,999,999.99"))                                  ,oFont8)

	_nLin  = _nLin + 1000
	_nCol := 50	
else                                        
	oPrint:EndPage() 		// Finaliza a pagina
	oPrint:StartPage()   // Inicia uma nova página
	_nLin = 400
	oPrint:say(_nLin-100,50  ,"PESO LIQ   = "                                                                ,oFont8)
	oPrint:say(_nLin-100,1200 ,"PESO BRUTO = "                                                                ,oFont8)
	oPrint:say(_nLin-100,400 ,Alltrim(Transform(_nPLiq,"@E 99,999,999.99"))                                  ,oFont8)
	oPrint:say(_nLin-100,1750,Alltrim(Transform(_nPBru,"@E 99,999,999.99"))                                  ,oFont8)

	_nLin  = _nLin + 50

	oPrint:say(_nLin,50  ,"VALOR C/DESC = "                                                                ,oFont8)
	oPrint:say(_nLin,1200 ,"VALOR S/DESC = "                                                                ,oFont8)
	oPrint:say(_nLin,400 ,Alltrim(Transform(_nVLiq,"@E 99,999,999.99"))                                  ,oFont8)
	oPrint:say(_nLin,1700,Alltrim(Transform(_nVBru,"@E 99,999,999.99"))                                  ,oFont8)

End if
                                                  
TRB->(DbGoTop())                     

oPrint:say(_nLin +20 ,50,Replicate("-",140)+">8--"                                                               ,oFont8)
oPrint:say(_nLin + 140  ,1650,dtoc(Date())                                                                  ,oFont8)
oPrint:say(_nLin + 190  ,1650,Time()                                                                        ,oFont8)
oPrint:say(_nLin + 090  ,50 ,"PEDIDO: " + IIF(_nTipo==1,TRB->D2_PEDIDO ,TRB->C6_NUM )                       ,oFont9)
oPrint:say(_nLin + 190  ,50 ,"NOTA FISCAL      : " + IIF(_nTipo==1,TRB->D2_DOC    ,TRB->C5_NOTA)            ,oFont8)
oPrint:say(_nLin + 240  ,50 ,"CLIENTE          : " + IIF(_nTipo==1,TRB->D2_CLIENTE,TRB->C6_CLI)             ,oFont8)
oPrint:say(_nLin + 290  ,50 ,"LOJA             : " + IIF(_nTipo==1,TRB->D2_LOJA   ,TRB->C6_LOJA)            ,oFont8)
oPrint:say(_nLin + 340  ,50 ,"NOME CLIENTE     : " + substr(TRB->A1_NOME,1,34)                              ,oFont8)
oPrint:say(_nLin + 390  ,50 ,"COND. PAGAMENTO  : " + substr(TRB->C5_DESPREC,1,34)                           ,oFont8)
oPrint:say(_nLin + 440  ,50 ,"FORMA PAGAMENTO  : " + substr(TRB->C5_CONPAG,1,34)                            ,oFont8)
oPrint:say(_nLin + 490  ,50 ,"PLACA CAMINHÃO: " + TRB->C5_PLACA + " " + "UF DO CLIENTE: " + TRB->A1_EST     ,oFont8)


oPrint:EndPage() 		// Finaliza a pagina
TRB->(DbCloseArea())

RestArea(_aSD2)
RestArea(_aSA1)
RestArea(_aSC5)
RestArea(_aSB1)
RestArea(_aSBM)
RestArea(_aSC9)
RestArea(_aSC6)

oPrint:Preview()

Set Device to Screen
//+------------------------------------------------------------------+
//¦ Se impressao em Disco, chama Spool.                              ¦
//+------------------------------------------------------------------+

MS_FLUSH()


Return()
TRB->(DbCloseArea())

Static Function VALIDNOME
SA4->(DbSeek(xFilial("SA4") + _cTransp))
_cNome:=SA4->A4_NOME
onome:Refresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1   ³ Autor ³ Luiz Casagrande    ³ Data ³ 25.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajustar as perguntas no SX1.					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaSX1		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RGPR01, Localizacoes...                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1()
LOCAL aRegs := {}
LOCAL cPerg := "VCL030    "
LOCAL aAreaOld := GetArea()
AADD(aRegs,{"Pedido            ?","Pedido             ?","Pedido             ?","mv_ch1","C", 6,0,0,"G",""          ,"mv_par01",""		         ,""		   ,""			  ,""    						    ,"",""				  ,""				,""			   ,"","",""	   ,""	   ,""	  ,""   ,"",""     ,""			   ,"","",""	   ,""	   ,""	  ,""   ,"",""     })
dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aRegs)
	If !(dbSeek(cPerg+StrZero(nx,2)))
		RecLock("SX1",.T.)
		Replace X1_GRUPO    	with cPerg
		Replace X1_ORDEM   	    with StrZero(nx,2)
		Replace x1_pergunte	    with aRegs[nx][01]
		Replace x1_perspa   	with aRegs[nx][02]
		Replace x1_pereng   	with aRegs[nx][03]
		Replace x1_variavl	    with aRegs[nx][04]
		Replace x1_tipo		    with aRegs[nx][05]
		Replace x1_tamanho	    with aRegs[nx][06]
		Replace x1_decimal	    with aRegs[nx][07]
		Replace x1_presel   	with aRegs[nx][08]
		Replace x1_gsc      	with aRegs[nx][09]
		Replace x1_valid    	with aRegs[nx][10]
		Replace x1_var01    	with aRegs[nx][11]
		Replace x1_def01    	with aRegs[nx][12]
		Replace x1_defspa1	    with aRegs[nx][13]
		Replace x1_defeng1	    with aRegs[nx][14]
		Replace x1_cnt01    	with aRegs[nx][15]
		Replace x1_var02    	with aRegs[nx][16]
		Replace x1_def02    	with aRegs[nx][17]
		Replace x1_defspa2   	with aRegs[nx][18]
		Replace x1_defeng2	    with aRegs[nx][19]
		Replace x1_cnt02    	with aRegs[nx][20]
		Replace x1_var03    	with aRegs[nx][21]
		Replace x1_def03    	with aRegs[nx][22]
		Replace x1_defspa3   	with aRegs[nx][23]
		Replace x1_defeng3	    with aRegs[nx][24]
		Replace x1_f3     	    with aRegs[nx][25]
		Replace x1_grpsxg   	with aRegs[nx][26]
		Replace x1_def04    	with aRegs[nx][27]
		Replace x1_F3       	with aRegs[nx][36]
		MsUnlock()
	Endif
Next
RestArea( aAreaOld )
Return
