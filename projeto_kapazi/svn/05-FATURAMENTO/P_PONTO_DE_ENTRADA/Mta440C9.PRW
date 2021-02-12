#include "rwmake.ch"  
#include "TOPCONN.CH"
*----------------------------------------------------------------------------------------------------
* Ponto de entrada para gravacao de campos especificos na tabela SC9, chamado na gravacao 
* e/ou liberacao do pedido de venda, apos a atualizacao dos acumulados no SA1.
*
* Verificacao da liberacao de credito, e bloqueio de estoque caso tenha ocorrido atraves da OC
* Ricardo Luiz da Rocha 18/11/2011 GNSJC
*----------------------------------------------------------------------------------------------------
user function mta440c9
Local _cPedido	:=sc9->c9_pedido  
Local naux		:= 0   
Local aArea		:= GetArea()
Local aAreaC5	:= SC5->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local aAreaC9	:= SC9->(GetArea())


// mata455 liberacao de estoque
//If ExistBlock("KFATR15") .and. ( IsInCallStack("A455LibAut") .or. IsInCallStack("A455LibMan") .or. IsInCallStack("A455LibAlt") )
//	U_KFATR15("04",SC9->C9_PEDIDO,SC9->C9_ITEM)
//Endif

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
    sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
    
    _vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1] //DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
    
    sc5->(msunlock())
endif
//
//GRAVA DADOS DE LIBERACAO DO PEDIDO 
/* - COMENTADO DIA 16/11/2017 
//ABRE TABELA DE STATS
SZ6->(dBselectArea('SZ6'))
//ORDENA PELO NUMERO DO PEDIDO
SZ6->(dbSetOrder(5))

	//VERIFICA SE O PEDIDO JÁ EXISTE NA TABELA DE STATUS
		If (SZ6->(dbSeek((xFilial("SZ6") + SC9->C9_PEDIDO ))))
		
			U_GRVLIBP(SC9->C9_PEDIDO,1) 
			
		EndIf    
		
SZ6->(dbclosearea('SZ6'))   
*/ //- COMENTADO DIA 16/11/2017 
/*
cQuebra:=SC9->C9_PEDIDO
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+cQuebra)   

naux  :=  SC9->C9_QTDLIB*SC9->C9_PRCVEN + naux
      
reclock('SC5',.F.)
SC5->C5_VLIB := naux
msunlock()
*/
RestArea(aArea)
RestArea(aAreaC5)
RestArea(aAreaC6)
RestArea(aAreaC9)

Return()