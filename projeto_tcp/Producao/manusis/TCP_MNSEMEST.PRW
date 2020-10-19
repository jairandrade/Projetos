#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            !                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! ENVIA MAIL QUE NÃO TEM ESTOQUE
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSEMEST                                                 !			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/
user function MNSEMES1(_cEmp,_cFil,_aSemEst)

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil TABLES "ZZH" MODULO "SIGAPCP"

	u_MNSEMEST(_aSemEst)

RESET ENVIRONMENT

return 

user function MNSEMEST(aItens)   
	Local nInd
	oProc := TWFProcess():New("MAILACD03","OM "+aItens[1][2]+" não programada por falta de estoque")
	                                                             
	oProc:NewTask("Ordem Separação", "\WORKFLOW\HTML\MAILACD03.HTML" )
	cEmail :=  GETMV( 'TCP_MAILES')
	oProc:cSubject := "OM "+aItens[1][2]+" não programada por falta de estoque"	

	oHtml := oProc:oHtml

	IF valtype(oHtml) != "U"
		
		FOR nInd := 1 to LEN(aItens)	
			
			IF nInd == 1      
				oHtml:ValByName("cOm",aItens[nInd][2])           
				oHtml:ValByName("cData",DtoS(aItens[nInd][11]))    
				oHtml:ValByName("cHora",aItens[nInd][12])      
			endif
			
			aAdd((oHtml:ValByName("it.codigo")),aItens[nInd][1])
			aAdd((oHtml:ValByName("it.descricao")), POSICIONE('SB1',1,xFilial('SB1')+aItens[nInd][1],'B1_DESC'))
			aAdd((oHtml:ValByName("it.quantidade")),TransForm(aItens[nInd][5],'@E 999,999.99'))
			aAdd((oHtml:ValByName("it.qtdDisp")),TransForm(aItens[nInd][6],'@E 999,999.99'))
			aAdd((oHtml:ValByName("it.qtdTotal")),TransForm(aItens[nInd][7],'@E 999,999.99'))
			aAdd((oHtml:ValByName("it.qtdPCompra")),TransForm(aItens[nInd][8],'@E 999,999.99'))
			/*
			DbSelectArea('ZZH')
			ZZH->(DbGoto(aItens[nInd][13]))
			RecLock("ZZH",.F.)
			ZZH->ZZH_MAIL   := '1'
			ZZH->(msUnlock())
			*/
		NEXT

		oProc:cTo := cEmail
		oProc:Start()

		WFSendMail()
		
	endif
return
	
