#include "totvs.ch"
#include "protheus.ch"
#include 'topconn.ch'

User Function GERAROTEIRO()
  Local nCont2:=1	
  
	dbSelectArea("CT1")
	DbSelectArea("CTB")
	DbSelectArea("CTT")
	CT1->(dbSetOrder(1))
	CTB->(dbSetOrder(1))
	CTT->(dbSetOrder(1))
	While !(CT1->(EOF()))
		If CT1->CT1_CLASSE =="2" .AND. !CT1->(DELETED()) //Verifica se é conta analitica
			If SubStr(CT1->CT1_CONTA,1,1)>="1" .and. SubStr(CT1->CT1_CONTA,1,1)<="2" //se for conta do Ativo ou passivo não importar centros de custo
			  //u_GravaCTB(nCont2,cLinha,cFOrig,cEmpOrig,cConta,cCCusto)
				u_GravaCTB(nCont2,"001","01"   ,"02"    ,CT1->CT1_CONTA,"")
				u_GravaCTB(nCont2,"002","01"   ,"03"    ,CT1->CT1_CONTA,"")
				u_GravaCTB(nCont2,"003","02"   ,"03"    ,CT1->CT1_CONTA,"")
				u_GravaCTB(nCont2,"004","01"   ,"04"    ,CT1->CT1_CONTA,"")
	            nCONT2++
				CTT->(DbSkip())			
			Else
				If CT1->CT1_CONTA >="3201010101" .and. CT1->CT1_CONTA <="3301010116"   //não importar contas selecionadas pelo Joanir
					CT1->(DbSkip())
				Else
				  //u_GravaCTB(nCont2,cLinha,cFOrig,cEmpOrig,cConta,cCCusto)
					u_GravaCTB(nCont2,"001","01"   ,"02"    ,CT1->CT1_CONTA,"")
					u_GravaCTB(nCont2,"002","01"   ,"03"    ,CT1->CT1_CONTA,"")
					u_GravaCTB(nCont2,"003","02"   ,"03"    ,CT1->CT1_CONTA,"")
					u_GravaCTB(nCont2,"004","01"   ,"04"    ,CT1->CT1_CONTA,"")
		            nCONT2++
		            CTT->(DbGoTop())
					While !(CTT->(EOF()))
						u_GravaCTB(nCont2,"001","01"   ,"02"    ,CT1->CT1_CONTA,CTT->CTT_CUSTO)
						u_GravaCTB(nCont2,"002","01"   ,"03"    ,CT1->CT1_CONTA,CTT->CTT_CUSTO)
						u_GravaCTB(nCont2,"003","02"   ,"03"    ,CT1->CT1_CONTA,CTT->CTT_CUSTO)
						u_GravaCTB(nCont2,"004","01"   ,"04"    ,CT1->CT1_CONTA,CTT->CTT_CUSTO)
		            	nCONT2++
						CTT->(DbSkip())
					Enddo
				Endif
			Endif
		Endif
		CT1->(DbSkip())
	Enddo
Return 
User Function GravaCTB(nCont2,cLinha,cFOrig,cEmpOrig,cConta,cCCusto)
	CTB->(Reclock("CTB",.T.))
	CTB->CTB_FILIAL  :="01"
	CTB->CTB_EMPDES  :="90"
	CTB->CTB_FILDES  :="01"
	CTB->CTB_CODIGO  :="R01"
	CTB->CTB_ORDEM   :=StrZero(nCont2,10)
	CTB->CTB_CTADES  := cCONTA
	CTB->CTB_CCDES   := cCCUSTO
	CTB->CTB_TPSLDE  := "1"
	CTB->CTB_LINHA   := cLinha 
	CTB->CTB_EMPORI  := cEmpOrig
	CTB->CTB_FILORI  := cFOrig
	CTB->CTB_CT1INI  := cCONTA
	CTB->CTB_CT1FIM  := cCONTA
	CTB->CTB_CTTINI  := cCCUSTO
	CTB->CTB_CTTFIM  := cCCUSTO			
	CTB->CTB_TPSLDO  :="1"
	CTB->CTB_IDENT   :="1"               
	CTB->(MsUnlock())     
Return