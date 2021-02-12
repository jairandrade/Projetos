#INCLUDE "rwmake.ch"

*----------------------------------------------------------------------------------------
User Function KpFatA01()
* Ricardo Luiz da Rocha 01/11/2011 GNSJC
*----------------------------------------------------------------------------------------
Private cCadastro := "Etiquetas por nota de saída"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","AxVisual",0,2} ,;
             {"Quant Etiquetas","u_KpFatA1a",0,4}}

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString := "SF2"
dbSelectArea(cString)
dbSetOrder(1)

mBrowse( 6,1,22,75,cString)

Return

*----------------------------------------------------------------------------------------
User Function KpFatA1a()
* Ricardo Luiz da Rocha 01/11/2011 GNSJC
*----------------------------------------------------------------------------------------
@ 0,0 to 110,300 dialog _oDlgEtq title "Etiquetas por nota fiscal"
_nEtiq:=sf2->f2_xetiq
@ 10,010 say 'Quantidade desejada:'
@ 10,080 get _nEtiq size 30,15 valid _nEtiq>=0

@ 30,080 bmpbutton type 1 action sf2->(reclock(alias(),.f.),f2_xetiq:=_nEtiq,msunlock(),close(_oDlgEtq))
@ 30,120 bmpbutton type 2 action close(_oDlgEtq)

activate dialog _oDlgEtq Centered
Return
