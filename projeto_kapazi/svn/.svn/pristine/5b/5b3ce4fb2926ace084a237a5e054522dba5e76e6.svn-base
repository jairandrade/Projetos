#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

#Define ENTER chr(13)+chr(10)

*----------------------------------------------------------------------------------------
User Function KpFatC01(_cPedido)
* Ricardo Luiz da Rocha 18/11/2011 GNSJC
* Retorna a situação de liberação de determinado pedido de vendas
*----------------------------------------------------------------------------------------
   local _cSit
   Local lReserva 	:= GetMv("KA_RESATV",,.F.)
   /* Hipóteses de _cSit:
   1=Lib inexistente (item);
   2=Quant invalida (item);
   3=Bloq credito;
   4=Bloq estoque;
   5=Bloq cred e estoque;
   6=Liberado;
   7=Faturado;
   8=Embarcado (kpfata06)
   */

   If Type("INCLUI") == "U"
      INCLUI := .F.
   Endif

   If INCLUI .and. IsInCallStack("A410Inclui")
      if !lReserva
         _cSit := "1"
      Else
         _cSit := "00"
      Endif
      Return _cSit
   Endif

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

   _cSql := ""
   If SF2->( FieldPos("F2_XEMBDT") ) > 0

      _cSql += "SELECT DISTINCT "
      _cSql += "	F2_XEMBDT "
      _cSql += "	,F2_XEMBHR "
      _cSql += "	,F2_XEMBUSR "
      _cSql += "FROM "+RetSqlName("SD2")+" SD2 "
      _cSql += "	INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_<>'*' "
      _cSql += "		AND D2_FILIAL = F2_FILIAL "
      _cSql += "		AND D2_DOC = F2_DOC "
      _cSql += "		AND D2_SERIE = F2_SERIE "
      _cSql += "	WHERE SD2.D_E_L_E_T_<>'*' "
      _cSql += "	AND D2_FILIAL='"+xFilial("SD2")+"' "
      _cSql += "	AND D2_PEDIDO='"+_cPedido+"' "

      If Select("kpfatc01") > 0
         kpfatc01->( DbCloseArea() )
      Endif

      TcQuery _cSql New Alias "kpfatc01"

      If !kpfatc01->( EOF() ) .and. !Empty( AllTrim( kpfatc01->F2_XEMBDT ) )
         _cSit := '8'
      Endif

      If Select("kpfatc01") > 0
         kpfatc01->( DbCloseArea() )
      Endif

   Endif


Return _cSit

/*
------------------------------------------------------------------------------------------
 Retorna array com as datas de liberação principal, financeiro e estoques respectivamente
------------------------------------------------------------------------------------------
*/
user function Sc5Libs(_cPFil,_cPNumPed,_cPSit,_dPDataP,_dPDataF,_dPDataE)

   local _vDatas:={ctod(''),ctod(''),ctod('')}//,_vAmbAtu:=getarea()

/*
1=Lib inexistente (item);
2=Quant invalida (item);
3=Bloq credito;
4=Bloq estoque;
5=Bloq cred e estoque;
6=Liberado;
7=Faturado
*/  
   if _cPSit=='1'
      _vDatas[1]:= ctod('')
      _vDatas[2]:= ctod('')
      _vDatas[3]:= ctod('')
   elseif _cPSit$'2/5/7'
      _vDatas[1]:= if(empty(_dPDataP),dDataBase,_dPDataP)
      _vDatas[2]:= ctod('')
      _vDatas[3]:= ctod('')
   elseif _cPSit=='3'
      _vDatas[1]:= if(empty(_dPDataP),dDataBase,_dPDataP)
      _vDatas[2]:= _dPDataF
      _vDatas[3]:= dDataBase
   elseif _cPSit=='4'
      _vDatas[1]:= if(empty(_dPDataP),dDataBase,_dPDataP)
      _vDatas[2]:= dDataBase
      _vDatas[3]:=_dPDataE
   elseif _cPSit=='6'
      _vDatas[1]:=if(empty(_dPDataP),dDataBase,_dPDataP)
      _vDatas[2]:=if(empty(_dPDataF),dDataBase,_dPDataF)
      _vDatas[3]:=if(empty(_dPDataE),dDataBase,_dPDataE)
   endif

//DbSelectarea(_vAmbAtu[1])
//RestArea(_vAmbAtu)

Return _vDatas

*-------------------------------------------------------------------
user function sitsc5()
*-------------------------------------------------------------------
   sc5->(dbgotop())
   do while sc5->(!eof())
      if sc5->(reclock(alias(),.f.))
         cFilant:=sc5->c5_filial
         _cPedido:=sc5->c5_num
         sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
         sc5->(msunlock())
      endif
      sc5->(dbskip(1))
   enddo

   alert("Concluido")
return


*-------------------------------------------------------------------
user function Totsc5()
*-------------------------------------------------------------------
   sc5->(dbgotop())
   do while sc5->(!eof())
      if sc5->(reclock(alias(),.f.))
         cFilant:=sc5->c5_filial
         _cPedido:=sc5->c5_num
         sc5->c5_xTotMer:=u_MFAT01(cFilAnt,_cPedido)
         sc5->(msunlock())
      endif
      sc5->(dbskip(1))
   enddo

   alert("Concluido")
return