#include "rwmake.ch"
*----------------------------------------------------------------------------------------*
User Function KpFatR02()
* Relatorio de Acompanhamento de liberação de pedidos
* Ricardo Luiz da Rocha 14/12/2011 GNSJC
*----------------------------------------------------------------------------------------*
cPerg    := "KpFatR02"
aLinha  := {}
aOrd    := {}
cbcont  := 0
cbtxt   := space(10)

cabec1  :="Pedido  Situacao da liberacao      Cliente (Código / Loja - Nome)                        Valor total  Emissão   |--------Liberações----------| Faturamento Nota  Serie"
cabec2  :="                                                                                                                | Pedido    Financ   Estoques|"
cabec3  :=""
li      := 99
m_pag   :=1
cString :="SC5"
titulo  :="Acompanhamento de liberação e faturamento de pedidos de venda"
cDesc1  := ''
cDesc2  := ''
cDesc3  := OemToAnsi("Especifico"+trim(sm0->m0_nome)+".")
tamanho := "G"
limite  :=220
aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog:= wnrel :="KpFatR02"
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
_cPediIni:=mv_par01
_cPediFim:=mv_par02
_cClieIni:=mv_par03
_cClieFim:=mv_par04
_dEmisIni:=mv_par05
_dEmisFim:=mv_par06
_dLibPIni:=mv_par07
_dLibPFim:=mv_par08
_dLibFIni:=mv_par09
_dLibFFim:=mv_par10
_dLibEIni:=mv_par11
_dLibEFim:=mv_par12

_cPictVal:="@E 999,999,999.99"                               

_cQuery:="select C5_NUM,C5_XSITLIB,C5_CLIENTE,C5_LOJACLI,A1_NOME, C5_XTOTMER,C5_EMISSAO,C5_XDTLIBP,C5_XDTLIBF,C5_XDTLIBE,ISNULL(D2_EMISSAO,'') as D2_EMISSAO,C5_NOTA,C5_SERIE"
_cQuery+=" from "+RetSqlName("SC5")+" SC5 "
_cQuery+=" inner join "+RetSqlName("SA1")+" SA1 on(A1_FILIAL='"+xFilial("SA1")+"' and A1_COD=C5_CLIENTE and A1_LOJA=C5_LOJACLI and SA1.D_E_L_E_T_=' ')"
_cQuery+=" left join "+RetSqlName("SD2")+" SD2 on(D2_FILIAL='"+xfilial("SD2")+"' and D2_DOC=C5_NOTA and D2_SERIE=C5_SERIE and D2_CLIENTE=C5_CLIENTE and D2_LOJA=C5_LOJACLI and SD2.D_E_L_E_T_=' ')"
_cQuery+=" where SC5.D_E_L_E_T_=' '"
_cQuery+=" and C5_NUM between '"+_cPediIni+"' and '"+_cPediFim+"'"
_cQuery+=" and C5_CLIENTE between '"+_cClieIni+"' and '"+_cClieFim+"'"
_cQuery+=" and C5_EMISSAO between '"+dtos(_dEmisIni)+"' and '"+dtos(_dEmisFim)+"'"
_cQuery+=" and C5_XDTLIBP between '"+dtos(_dLibPIni)+"' and '"+dtos(_dLibPFim)+"'"
_cQuery+=" and C5_XDTLIBF between '"+dtos(_dLibFIni)+"' and '"+dtos(_dLibFFim)+"'"
_cQuery+=" and C5_XDTLIBE between '"+dtos(_dLibEIni)+"' and '"+dtos(_dLibEFim)+"'"
_cQuery+=" order by C5_FILIAL,C5_NUM"

DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"KpFatR02",.F.,.T.)
TcSetField('KpFatR02','C5_EMISSAO','D')
TcSetField('KpFatR02','D2_EMISSAO','D')
TcSetField('KpFatR02','C5_XDTLIBP','D')
TcSetField('KpFatR02','C5_XDTLIBF','D')
TcSetField('KpFatR02','C5_XDTLIBE','D')

setregua(lastrec())
dbgotop()
_lImprimiu:=.f.
_nTotPed:=0
do while KpfatR02->(!eof())
   _lImprimiu:=.t.

	_cSit:=KpFatR02->c5_xsitlib
	_cSit+="-"+u_fX3CBox("C5_XSITLIB",_cSit)
	_cSit:=padr(_cSit,25)
   @ _fIncrLin(),0 psay KpFatR02->(c5_num+'  '+_cSit+"  "+padr(c5_cliente+'/'+c5_lojacli+' - '+a1_nome,50)+' '+;
   								tran(c5_xtotmer,_cPictVal)+"   "+dtoc(c5_emissao)+"   "+;
   								dtoc(c5_xdtlibp)+"   "+dtoc(c5_xdtlibf)+"   "+dtoc(c5_xdtlibe)+"   "+;
   								dtoc(d2_emissao)+"   "+c5_nota+" "+c5_serie)
   _nTotPed+=KpFatR02->c5_xtotmer
   KpFatR02->(dbskip(1))
enddo

@ _fIncrLin(2),0 psay space(73)+"Valor total: "+tran(_nTotPed,_cPictVal)

if _lImprimiu
	roda(0,"",tamanho)
endif
	
u__fCloseDb("KpFatR02")

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
AADD(aRegs,{cPerg,"01","Pedido de                    :","mv_ch1","C",06,0,0,"G","","mv_par01",""    ,"","",""      ,"","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Pedido ate                   :","mv_ch2","C",06,0,0,"G","","mv_par02",""    ,"","",""      ,"","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Cliente de                   :","mv_ch1","C",06,0,0,"G","","mv_par03",""    ,"","",""      ,"","","","","","","","","","","CLI"})
AADD(aRegs,{cPerg,"04","Cliente ate                  :","mv_ch2","C",06,0,0,"G","","mv_par04",""    ,"","",""      ,"","","","","","","","","","","CLI"})
AADD(aRegs,{cPerg,"05","Data de emissao de           :","mv_ch3","D",08,0,0,"G","","mv_par05",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"06","Data de emissao ate          :","mv_ch4","D",08,0,0,"G","","mv_par06",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"07","Data liberacao principal de  :","mv_ch5","D",08,0,0,"G","","mv_par07",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"08","Data liberacao principal ate :","mv_ch6","D",08,0,0,"G","","mv_par08",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"09","Data liberacao financeiro de :","mv_ch7","D",08,0,0,"G","","mv_par09",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"10","Data liberacao financeiro ate:","mv_ch8","D",08,0,0,"G","","mv_par10",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"11","Data liberacao estoques de   :","mv_ch9","D",08,0,0,"G","","mv_par11",""    ,"","",""      ,"","","","","","","","","","",""})           
AADD(aRegs,{cPerg,"12","Data liberacao estoques ate  :","mv_chA","D",08,0,0,"G","","mv_par12",""    ,"","",""      ,"","","","","","","","","","",""})           

u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)
Return(.T.)