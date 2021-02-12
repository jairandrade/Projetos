#include "rwmake.ch"
*----------------------------------------------------------------------------------------*
User Function KpFatR03()
* Relatorio de Clientes por vendedor
* Ricardo Luiz da Rocha 15/12/2011 GNSJC
*----------------------------------------------------------------------------------------*
cPerg    := "KpFatR03"
aLinha  := {}
aOrd    := {}
cbcont  := 0
cbtxt   := space(10)
            
cabec1  :="Vendedor (código - Nome)                           Cliente (Código/Loja - Nome)"
cabec2  :=""
cabec3  :=""
li      := 99
m_pag   :=1
cString :="SA3"
titulo  :="Clientes por vendedor"
cDesc1  := ''
cDesc2  := ''
cDesc3  := OemToAnsi("Especifico"+trim(sm0->m0_nome)+".")
tamanho := "M"
limite  :=132
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:= wnrel :="KpFatR03"
nLastKey:= 0
cCancel := "*** CANCELADO PELO OPERADOR ***"
lAbortPrint := .F.

validperg(cPerg)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lAbortPrint|_ImpRel()},titulo)

*--------------------------------------------------------------------------------------------------------*
Static Function _ImpRel()
*--------------------------------------------------------------------------------------------------------*
pergunte(cPerg,.f.)
_cVendIni:=mv_par01 
_cVendFim:=mv_par02 
_cClieIni:=mv_par03
_cClieFim:=mv_par04
_nBase   :=mv_par05 // 1=Cadastro de clientes;2=Pedidos de venda
_dEmisIni:=mv_par06
_dEmisfim:=mv_par07

_cPictQuant:="@E 999,999,999"

if _nBase==1
    titulo:=alltrim(titulo)+" - Base cadastro de clientes"
	_cQuery:="select A3_COD as VENDCOD,A3_NOME,A1_COD as CLICOD,A1_LOJA as CLILOJA,A1_NOME"
	_cQuery+=" from "+RetSqlName("SA1")+" SA1 "
	_cQuery+=" inner join "+RetSqlName("SA3")+" SA3 on(A3_FILIAL='"+xfilial("SA3")+"' and A3_COD=A1_VEND and SA3.D_E_L_E_T_=' ')"
	_cQuery+=" where SA1.D_E_L_E_T_=' ' and A3_COD between '"+_cVendIni+"' and '"+_cVendFim+"'"
	_cQuery+=" and A1_COD between '"+_cClieIni+"' and '"+_cClieFim+"'"
	_cQuery+="order by A3_FILIAL,A3_COD,A1_COD"
elseif _nBase==2
    titulo:=alltrim(titulo)+" - Base pedidos de venda emitidos entre "+dtoc(_dEmisIni)+" e "+dtoc(_dEmisfim)
    _cQuery:="select C5_VEND1 as VENDCOD,A3_NOME ,C5_CLIENTE as CLICOD,C5_LOJACLI as CLILOJA,A1_NOME"
	_cQuery+=" from "+RetSqlName("SC5")+" SC5"
	_cQuery+=" inner join "+RetSqlName("SA3")+" SA3 on(A3_FILIAL='"+xfilial("SA3")+"' and A3_COD=C5_VEND1 and SA3.D_E_L_E_T_=' ')"
	_cQuery+=" inner join "+RetSqlName("SA1")+" SA1 on(A1_FILIAL='"+xfilial("SA1")+"' and A1_COD=C5_CLIENTE and A1_LOJA=C5_LOJACLI and SA1.D_E_L_E_T_=' ')"
	_cQuery+=" where SC5.D_E_L_E_T_=' '"
	_cQuery+=" and C5_VEND1 between '"+_cVendIni+"' and '"+_cVendFim+"'"
	_cQuery+=" and C5_CLIENTE between '"+_cClieIni+"' and '"+_cClieFim+"'"
	_cQuery+=" and C5_EMISSAO between '"+dtos(_dEmisIni)+"' and '"+dtos(_dEmisFim)+"'"
	_cQuery+=" group by C5_VEND1,A3_NOME,C5_CLIENTE,C5_LOJACLI,A1_NOME"
	_cQuery+=" order by C5_VEND1,A3_NOME,C5_CLIENTE,C5_LOJACLI,A1_NOME"
endif

DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"KpFatR03",.F.,.T.)
//TcSetField('KpFatR02','C5_XDTLIBE','D')

setregua(lastrec())
dbgotop()

_nTotCliD:=_nTotCliG:=_nTotVen:=0
do while KpfatR03->(!eof())
   _cVend:=KpFatR03->VENDCOD
   _nTotCliD:=0
   _nTotVen++
   do while KpFatR03->(!eof().and.vendcod==_cVend)
       _cVendDet1:=_cVendDet:=KpFatR03->(vendcod+" - "+a3_nome)
       if _nTotCliD>0
          _cVendDet:=space(len(_cVendDet))
       endif
	   @ _fIncrLin(),0 psay _cVendDet+"  "+KpFatR03->(padr(CliCod+'/'+CliLoja+' - '+a1_nome,50))
	   _nTotCliD++
	   _nTotCliG++

	   KpFatR03->(dbskip(1))
	enddo   
	@ _fIncrLin(2),0 psay "Clientes listados para o vendedor "+alltrim(_cVendDet1)+": "+alltrim(tran(_nTotCliD,_cPictQuant)) 
	@ _fIncrLin(),0 psay repl("-",limite)
	_fIncrLin(2)
enddo
if _nTotCliG>0
	@ _fIncrLin(2),0 psay "Total de vendedores listados: "+alltrim(str(_nTotVen))+"  Clientes: "+alltrim(tran(_nTotCliG,_cPictQuant))+"  Media clientes / vendedor: "+alltrim(tran(_nTotCliG/_nTotVen,"@er 999,999,999.9"))

	roda(0,"",tamanho)
endif
	
u__fCloseDb("KpFatR03")

If ( aReturn[5]==1 )
	Set Print to
	dbCommitall()
	ourspool(wnrel)
EndIf

MS_Flush()

Return(.t.)

*--------------------------------------------------------------------------------
Static Function _fIncrLin(_nIncrementa)
*--------------------------------------------------------------------------------
if _nIncrementa=nil
   _nIncrementa:=1
endif   
if li>61
   Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
else
   li+=_nIncrementa
endif
return li

*-------------------------------------------------------------*
Static Function VALIDPERG()
*-------------------------------------------------------------*
ssAlias  := Alias()
aRegs   := {}
dbSelectArea("SX1")
dbSetOrder(1)
*   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
*+---------------------------------------------------------------------------------------------------------------------------------+
*¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
*¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
*¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
*¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
*¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦

AADD(aRegs,{cPerg,"01","Vendedor de                  :","mv_ch1","C",06,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","","SA3"})
AADD(aRegs,{cPerg,"02","Vendedor ate                 :","mv_ch2","C",06,0,0,"G","","mv_par02",""    ,"","",""      ,"","","","","","","","","","","SA3"})
AADD(aRegs,{cPerg,"03","Cliente de                   :","mv_ch3","C",06,0,0,"G","","mv_par03",""    ,"","",""      ,"","","","","","","","","","","CLI"})
AADD(aRegs,{cPerg,"04","Cliente ate                  :","mv_ch4","C",06,0,0,"G","","mv_par04",""    ,"","",""      ,"","","","","","","","","","","CLI"})
AADD(aRegs,{cPerg,"05","Base para levantamento       :","mv_ch5","N",01,0,0,"C","","mv_par05","Cad clientes","","","Pedidos venda"," ","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Dt Emissao do pedido de      :","mv_ch6","D",08,0,0,"G","","mv_par06",""    ,"","",""      ,"","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Dt Emissao do pedido ate     :","mv_ch7","D",08,0,0,"G","","mv_par07",""    ,"","",""      ,"","","","","","","","","","",""})

u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)
Return(.T.)