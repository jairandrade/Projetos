#INCLUDE "rwmake.ch"
*----------------------------------------------------------------------------------------
User Function _atuStatus()
* Ricardo Luiz da Rocha 18/11/2011 GNSJC
* Retorna a situação de liberação de determinado pedido de vendas
*----------------------------------------------------------------------------------------
local _cSit 
LOCAL _cPedido := SC5->C5_NUM

/* Hipóteses de _cSit:
1=Lib inexistente (item);
2=Quant invalida (item);
3=Bloq credito;
4=Bloq estoque;
5=Bloq cred e estoque;
6=Liberado;
7=Faturado
*/

_cSql:="select isnull(MAX(C9_BLEST),'XY') as C9_BLEST,isnull(MAX(C9_BLCRED),'XY') as C9_BLCRED,isnull(max(QTDIGUAL),'XY') as QTDIGUAL from ("
_cSql+=" select C6_NUM,C6_ITEM,max(C6_QTDVEN) as C6_QTDVEN, isnull(sum(C9_QTDLIB),0) as C9_QTDLIB,isnull(max(C9_BLEST),'XX') as C9_BLEST,isnull(max(C9_BLCRED),'XX') as C9_BLCRED,"
_cSql+=" case when max(C6_QTDVEN)=max(C9_QTDLIB) THEN ' ' else 'D' end as QTDIGUAL "
_cSql+=" from "+RetSqlName("SC6")+" SC6"
_cSql+=" left join "+RetSqlName("SC9")+" SC9 on (C9_FILIAL=C6_FILIAL and C9_PEDIDO=C6_NUM and C9_ITEM=C6_ITEM and C6_PRODUTO=C9_PRODUTO and SC9.D_E_L_E_T_=SC6.D_E_L_E_T_)"
_cSql+=" where C6_FILIAL='"+xfilial("SC6")+"' and SC6.D_E_L_E_T_=' ' and C6_NUM='"+_cPedido+"'"
_cSql+=" group by C6_FILIAL,C6_NUM,C6_ITEM ) Tmp1"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"KPFATC01",.T.,.F.)

_cSit:=''
if "X"$kpfatc01->(c9_blest+c9_blcred)
   _cSit:='1' // Ao menos um item do pedido não está liberado
elseif kpfatc01->C9_BLEST=='10'
   _cSit:='7' // Faturado
elseif 'D'$ kpfatc01->QTDIGUAL
   _cSit:='2' // ao menos um item do pedido tem C6_QTDVEN <> C9_QTDLIB
elseif !empty(C9_BLCRED).and.!empty(C9_BLEST)
   _cSit:='5' // há bloqueios de credito E estoque considerando-se todos os itens
elseif !empty(C9_BLCRED)
   _cSit:='3' // ha bloqueio apenas de credito em ao menos um dos itens
elseif !empty(C9_BLEST)
   _cSit:='4' // ha bloqueio apenas de credito em ao menos um dos itens
elseif empty(kpfatc01->(c9_blest+c9_blcred+qtdigual))
   _cSit:='6'
endif


kpfatc01->(DbClosearea())

Return _cSit