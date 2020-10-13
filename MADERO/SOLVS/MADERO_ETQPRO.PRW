#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODUÇÃO                                          !
+------------------+---------------------------------------------------------+
!Nome              ! ETQPRO                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão Etiqueta Apontamento de Produção         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQPRO(_cOP,_nQtPro)
Local aArea := GetArea()
Local _cFuncao:="U_ETQ"
Local aEtqAuto := {}
Local _cImp :=SPACE(TamSX3("CB5_CODIGO")[1])
Local _cPROD:=SPACE(TamSX3("B1_COD")[1])
Local  _lRimp:=.f.
Local _cAliasZIB:= GetNextAlias()
//
Default _cOP :=SPACE(TamSX3("D3_OP")[1])
Default _nQtPro:=0
//
//
If !empty(_cOP) .and. _nQtPro>0
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	SC2->(dbGoTop())
	If SC2->(dbSeek(xFilial("SC2")+_cOP))
		_cProd := SC2->C2_PRODUTO
		_cLote := SC2->C2_XLOTE
		//_nQtde :=aEtqAuto[1][4]
		//_nImp  :=aEtqAuto[1][5]
		//
		DBSELECTAREA("ZIB")
		DBSETORDER(1)
		ZIB->(DBSEEK(XFILIAL("ZIB")+_CPROD))
		WHILE !ZIB->(EOF()) .AND. ZIB->ZIB_PRODUT=_CPROD
			IF ZIB->ZIB_APONTA<>"S"
				ZIB->(DBSKIP())
				LOOP
			ENDIF
			DBSELECTAREA("ZIA")
			DBSETORDER(1)
			IF ZIA->(DBSEEK(XFILIAL("ZIA")+ZIB->ZIB_TPETQ))
				//_NQTDE:=(_NQTDE*ZIB->ZIB_QTDE)
				_CIMP:=ZIA->ZIA_IMPPAD
				_cfuncao:="U_ETQ"+ZIB->ZIB_TPETQ
				//
				_aetqauto:={}
				aadd(_aEtqAuto,{_cOP,_cPROD,_cLote,_nQtPro,_cImp,.F.})
				&_cFUNCAO.(_aETQAuto)
			EndIf
			//
			ZIB->(dbskip())
		End
	EndIf
EndIf

RestArea(aArea)

Return
//
