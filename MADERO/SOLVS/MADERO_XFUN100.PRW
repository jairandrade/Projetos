#include 'totvs.ch'
#include "topconn.ch"
/*                                                      
+------------------+-------------------------------------------------------------------------------+
! Nome             ! XFUN100                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Funções customizadas utilizadas no projeto                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 14/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! xSB1SC7                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza os campos do pedido de acordo com gatilho e funções de validação dos !
!                  ! campos da tabela SC7                                                          !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function xSB1SC7(cFld,cTp)
Local aArea     :=GetArea()
Local axRet     :={}
Local lxCont    :=.F.
Local xAux      
Local nAux      :=0
Local nA5XCVUNF :=0
Local cA5XCVUNF :=""
Local cA5CODTAB :=""
Local nC7PRODUTO:=AScan(aHeader,{|x| AllTrim(x[2])=="C7_PRODUTO"})
Local nC7QUANT  :=AScan(aHeader,{|x| AllTrim(x[2])=="C7_QUANT"}  )
Local cC7PRODUTO:=aCols[n,nC7PRODUTO]
Local cQuery    := ""
Local cAliasQry	:= GetNextAlias( )

   Aadd(axRet,{"C7_PRODUTO","C7_CODTAB","C7_OPER","C7_XCODPRF","C7_PRECO","C7_CC","C7_XQTDPRF","C7_XUNPRF"})   
   Aadd(axRet,{.T.         ,.T.        ,.T.      ,.T.         ,.T.       ,.T.    ,.T.         ,.T.        })
   Aadd(axRet,{cC7PRODUTO  ,""         ,""       ,""          ,0.00      ,""     ,0.00        ,""         })
   	   	
   // -> Pesquisa item no cadastro de produtos x fornecedor
   cQuery :="SELECT A5_XCVUNF, A5_XTPCUNF, A5_PRODUTO, A5_FORNECE, A5_LOJA, A5_CODTAB, A5_XOPER, A5_CODPRF " + CRLF 
   cQuery +="FROM " + RetSQLName("SA5") + " SA5 "          + CRLF 
   cQuery +="WHERE A5_FILIAL  = '" + xFilial("SA5") + "' AND " + CRLF  
   cQuery +="      A5_FORNECE = '" + CA120FORN      + "' AND " + CRLF
   cQuery +="      A5_LOJA    = '" + CA120LOJ       + "' AND " + CRLF
   cQuery +="      A5_PRODUTO = '" + cC7PRODUTO     + "' AND " + CRLF
   cQuery +="      A5_XATIVO  = 'S'                          " + CRLF
   cQuery += "    AND SA5.D_E_L_E_T_ = ' ' "                   + CRLF
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	   
   (cAliasQry)->(DbGoTop())
   While !(cAliasQry)->(Eof())
	  nA5XCVUNF:=(cAliasQry)->A5_XCVUNF
	  cA5XCVUNF:=(cAliasQry)->A5_XTPCUNF
	  axRet[2,3]:=.T.
	  axRet[3,3]:=(cAliasQry)->A5_XOPER
	  axRet[2,4]:=.T.
	  axRet[3,4]:=(cAliasQry)->A5_CODPRF 
	  axRet[2,7]:=.T.
	  axRet[3,7]:=u_C104PRF(aCols[n,nC7QUANT],CA120FORN,CA120LOJ,cC7PRODUTO,.T.)[1]
	  axRet[2,8]:=.T.
	  axRet[3,8]:=u_C104PRF(aCols[n,nC7QUANT],CA120FORN,CA120LOJ,cC7PRODUTO,.T.)[3]
	  cA5CODTAB:=(cAliasQry)->A5_CODTAB
   	  lxCont:=.T.   
   	  Exit
   	  (cAliasQry)->(DbSkip())
   EndDo
   (cAliasQry)->(DbCloseArea())
   // ->  Se continua
   If lxCont
      // -> Verifica tabela de preço
      DbSelectArea("AIA")
      AIA->(DbSetOrder(1))
      If AIA->(DbSeek(xFilial("AIA")+CA120FORN+CA120LOJ+cA5CODTAB))
         // -> Verifica se a tabela é válida
         If AIA->AIA_DATDE <= dDataBase .and.  (AIA->AIA_DATATE >= dDataBase .or. Empty(AIA->AIA_DATATE)) 
            // -> Verifica a condição de Pagamento utilizada na tabela e no pedido. Se for igual ou vazia, continua
            If (AllTrim(CCONDICAO) == AllTrim(AIA->AIA_CONDPG)) .or. Empty(AIA->AIA_CONDPG)
               cA5CODTAB:=AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB
               // -> Pesquisa no item da tabela de preço
               DbSelectArea("AIB")
               AIB->(DbSetOrder(2))
               If AIB->(DbSeek(cA5CODTAB+cC7PRODUTO))
                  // -> Valida o item na tabela de preço
                  If AIB->AIB_DATVIG <= dDataBase
                     axRet[2,2]:=.F.
                     axRet[3,2]:=AIA->AIA_CODTAB
                     axRet[2,5]:=.F.
                     axRet[3,5]:=AIB->AIB_PRCCOM
                  EndIf
               EndIf         
            EndIf                        
         EndIf
      EndIf   
   EndIf
   // -> Pesquisa Centro de custo
   DbSelectArea("ZA0")
   ZA0->(DbSetOrder(1))
   If ZA0->(DbSeek(xFilial("ZA0")+cFilAnt))
      axRet[2,6]:=.T.
      axRet[3,6]:=ZA0->ZA0_CUSTO
   Else
      axRet[2,6]:=.F.
      axRet[3,6]:=""
   EndIf   
   RestArea(aArea)
   
   xAux:=IIF(cTp=="G",axRet[3,AScan(axRet[1],cFld)],IIF(cTp=="V",axRet[2,AScan(axRet[1],cFld)],""))
   
Return(xAux)                                



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! xSB1SC1                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza os campos da solicitação de compra de acordo com gatilho e funções de!
!                  ! validação dos campos da tabela SC1                                            !
+------------------+-------------------------------------------------------------------------------+
// Parametros
// cFld -> campo do SC1 a procurar (C1_XCODTAB, C1_FORNECE, C1_LOJA, C1_VUNIT, C1_CC) 
// cTp  -> 'G' -> Gatilho (retorno o valor do campo)
//      -> 'V' -> Visual  (retorna se é visual)
//      -> 'F' -> Se encontrou o campo (retorna se existe nas pesquisas)
// Variáveis privadas de outros fontes que esta função é dependente.
// 	aHeader --> array de header de browse
// 	aCols   --> array conteudo de browse
// 	n       --> linha do array de conteudo posicionada
*/                                                                                
User Function xSB1SC1(cFld,cTp)
Local aArea099  :=GetArea()
Local axRet     :={}
Local lxCont    :=.F.
Local xAux      
Local nAux      :=0
Local nA5XCVUNF :=0
Local cA5XCVUNF :=""
Local cA5CODTAB :=""
Local nC1PRODUTO:=AScan(aHeader,{|x| AllTrim(x[2])=="C1_PRODUTO"})
Local cC1PRODUTO:=aCols[n,nC1PRODUTO]
Local cQuery    :=""
Local cAliasQry	:= GetNextAlias()

   Aadd(axRet,{"C1_PRODUTO","C1_XCODTAB","C1_FORNECE","C1_LOJA","C1_VUNIT","C1_CC","C1_CODCOMP","C1_XGRUPO"})
   Aadd(axRet,{.T.         ,.T.        ,.T.      ,.T.          ,.T.       ,.T.    ,.T.         ,.T.        })
   Aadd(axRet,{cC1PRODUTO  ,""         ,""       ,""           ,0.00      ,""     ,""          ,""         })
   Aadd(axRet,{.F.         ,.F.        ,.F.      ,.F.          ,.F.       ,.F.    ,.F.         ,.F.        })
   	
   // -> Posiciona no Produto
   SB1->(DbSetOrder(1))
   SB1->(DbSeek(xFilial("SB1")+cC1PRODUTO))   
   
   axRet[2,8]:=.T.
   axRet[3,8]:=SB1->B1_GRUPO
   axRet[4,8]:=.T.  

   // -> Pesquisa item no cadastro de produtos x fornecedor
   cQuery :="SELECT R_E_C_N_O_ AS RECNO_SA5, A5_XCVUNF, A5_XTPCUNF, A5_PRODUTO, A5_FORNECE, A5_LOJA, A5_CODTAB " + CRLF 
   cQuery +="FROM " + RetSQLName("SA5") + " SA5 "          + CRLF 
   cQuery +="WHERE A5_FILIAL  = '" + xFilial("SA5") + "' AND " + CRLF  
   cQuery +="      A5_PRODUTO = '" + cC1PRODUTO     + "' AND " + CRLF
   cQuery +="      A5_XATIVO  = 'S'                          " + CRLF
   cQuery += "    AND SA5.D_E_L_E_T_ = ' ' "                   + CRLF
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	
   
   (cAliasQry)->(DbGoTop())
   While !(cAliasQry)->(Eof())
	  nA5XCVUNF:=(cAliasQry)->A5_XCVUNF
	  cA5XCVUNF:=(cAliasQry)->A5_XTPCUNF
	  axRet[2,1]:=.T.
	  axRet[3,1]:=(cAliasQry)->A5_PRODUTO
	  axRet[4,1]:=.T.	// Existe Produto
	  axRet[2,3]:=.T.
	  axRet[3,3]:=(cAliasQry)->A5_FORNECE
	  axRet[4,3]:=.T.	// Existe fornecedor
	  axRet[2,4]:=.T.
	  axRet[3,4]:=(cAliasQry)->A5_LOJA
	  axRet[4,4]:=.T.	// Existe loja
	  cA5CODTAB:=(cAliasQry)->A5_CODTAB
   	  
      	  // -> Posiciona na tabelas SA5
	  DbSelectArea('SA5')
          SA5->(dbGoTo((cAliasQry)->RECNO_SA5))  

	  lxCont:=.T.   
   	  Exit
   	  (cAliasQry)->(DbSkip())
   EndDo
   (cAliasQry)->(DbCloseArea())
   // ->  Se continua
   If lxCont
      // -> Verifica tabela de preço
      AIA->(DbSetOrder(1))
      If AIA->(DbSeek(xFilial("AIA")+axRet[3,3]+axRet[3,4]+cA5CODTAB))
         // -> Verifica se a tabela é válida
         If AIA->AIA_DATDE <= dDataBase .and.  (AIA->AIA_DATATE >= dDataBase .or. Empty(AIA->AIA_DATATE))
            // -> Pesquisa no item da tabela de preço
            AIB->(DbSetOrder(2))
            If AIB->(DbSeek(AIA->AIA_FILIAL+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB+cC1PRODUTO))
               // -> Valida o item na tabela de preço
               If AIB->AIB_DATVIG <= dDataBase
                  axRet[2,2]:=.F.
                  axRet[3,2]:=AIA->AIA_CODTAB
                  axRet[4,2]:=.t.   // Existe tabela
                  axRet[2,5]:=.F.
                  axRet[3,5]:=AIB->AIB_PRCCOM
                  axRet[4,5]:=.t.   // Existe preco
               EndIf         
            EndIf                        
         EndIf
      EndIf   
   EndIf

   // -> Pesquisa Centro de custo
   ZA0->(DbSetOrder(1))
   If ZA0->(DbSeek(xFilial("ZA0")+cFilAnt))
      axRet[2,6]:=.T.
      axRet[3,6]:=ZA0->ZA0_CUSTO
      axRet[4,6]:=.t.   // Existe centro de custo
   Else
      axRet[2,6]:=.F.
      axRet[3,6]:=""
   EndIf   

   // -> Pesquisa Comprador
   DbSelectArea("SAJ")
   SAJ->(DbSetOrder(1))
   If SAJ->(DbSeek(xFilial("SAJ")+SB1->B1_GRUPCOM))
      // -> Pesquisa comprador
      DbSelectArea("SY1")
      SY1->(DbSetOrder(3))
      If SY1->(DbSeek(xFilial("SY1")+SAJ->AJ_USER))
         axRet[2,7]:=.T.
         axRet[3,7]:=SY1->Y1_COD
         axRet[4,7]:=.T.
      Else
         axRet[2,7]:=.F.
         axRet[3,7]:=""
         axRet[4,7]:=.F.        
      EndIf     
   Else
      axRet[2,7]:=.F.
      axRet[3,7]:=""
      axRet[4,7]:=.F.  
   EndIf   

   RestArea(aArea099)
   If     cTp == "G"
      xAux:=axRet[3,AScan(axRet[1],cFld)]
   ElseIf cTp == "V"
      xAux:=axRet[2,AScan(axRet[1],cFld)]
   ElseIf cTp == "F"
   	  xAux:=axRet[4,AScan(axRet[1],cFld)]
   EndIf         
      
Return(xAux)                                
                     
                     
                     

/*
+------------------+---------------------------------------------------------+
!Nome              ! C104PRF                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Calcula quantidade do pedido conforme unidade de compra !
!                  ! cadastrada na tabela de produto x fornecedores          !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function C104PRF(nQUNSB1,cForn,cLoj,cProd,lGatilho,lPC,cFilOrig,cProdRes)
Local a104PRF	:=GetArea()
Local nAux   	:=nQUNSB1
Local nAux1  	:=0
Local cAux   	:=""
Local cAux1  	:=""
Local cAux2  	:=""	
Local nFator 	:= 0 
Local cFator 	:= ""
Local nLoteM 	:= 0
Local cUnidF 	:= ""
Local cAliasQry	:= GetNextAlias( )
Local nMaxQtde  := 0
Default lPC     :=.F.
Default lGatilho:=.F.	
Default cFilOrig	:=''
Default cProdRes	:= ''	

	// -> Pesquisa item no cadastro de produtos x fornecedor
	cQuery :="SELECT A5_XTPCUNF, A5_LOTEMUL, A5_XCVUNF, A5_LOTEMIN, A5_UNID, A5_CODTAB, A5_FORNECE, A5_LOJA, A5_PRODUTO " + CRLF 
	cQuery +="FROM " + RetSQLName("SA5") + " SA5 "          + CRLF 
	If !Empty(cFilOrig)
		cQuery +="WHERE SA5.A5_FILIAL  = '" + cFilOrig + "' AND " + CRLF 
	Else
		cQuery +="WHERE SA5.A5_FILIAL  = '" + xFilial("SA5") + "' AND " + CRLF 
	EndIf 
	cQuery +="      SA5.A5_FORNECE = '" + cForn     + "' AND " + CRLF
	cQuery +="      SA5.A5_LOJA    = '" + cLoj      + "' AND " + CRLF
	
	//#TB20200323 Thiago Berna - Ajuste query de conversão
	/*If !Empty(cFilOrig)
		cQuery +="      SA5.A5_PRODUTO = '" + cProd     + "' AND " + CRLF
 	Else
		cQuery +="      SA5.A5_PRODUTO = '" + cProd     + "' AND " + CRLF
	EndIf
	If !Empty(cProdRes)
		cQuery +="      SA5.A5_PRODUTO = '" + cProdRes     + "' AND " + CRLF
	EndIf*/
	If !Empty(cProdRes)
		cQuery +="      SA5.A5_PRODUTO = '" + cProdRes     + "' AND " + CRLF
	Else
		cQuery +="      SA5.A5_PRODUTO = '" + cProd     + "' AND " + CRLF
	EndIf

	cQuery +="      SA5.A5_XATIVO  = 'S'                 AND " + CRLF
    cQuery += "     SA5.D_E_L_E_T_ = ' ' " + CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	
	(cAliasQry)->(DbGoTop())
	While !(cAliasQry)->(Eof())
	    cFator:=(cAliasQry)->A5_XTPCUNF
		nFator:=IIF((cAliasQry)->A5_LOTEMUL>0,(cAliasQry)->A5_LOTEMUL,(cAliasQry)->A5_XCVUNF)
		nLoteM := (cAliasQry)->A5_LOTEMIN
 		cUnidF := (cAliasQry)->A5_UNID		
		// -> Pesquisa na tabela de preço para verificar a quantidade máxima da tabela
		AIB->(DbSetOrder(2))
		AIB->(DbSeek(xFilial("AIB")+(cAliasQry)->A5_FORNECE+(cAliasQry)->A5_LOJA+(cAliasQry)->A5_CODTAB+(cAliasQry)->A5_PRODUTO))
		If !AIB->(Eof())
			nMaxQtde:=AIB->AIB_QTDLOT
		EndIf	
	   	Exit
   		(cAliasQry)->(DbSkip())
   	EndDo
    (cAliasQry)->(DbCloseArea())

	// -> Se possuir lote múltiplo cadastrado 
	If nFator > 0		
		// -> Aplica fator de conversão do lote do fornecedor
		nAux  :=0
		If cFator == "M"
			nAux :=nQUNSB1/nFator
		ElseIf cFator == "D"
			nAux :=nQUNSB1*nFator						
		EndIf	

	EndIf	

	// -> Verifica se não é pedido de compras
	If !lPC

		// -> Se possuir lote múltiplo cadastrado 
		If nFator > 0		
			// -> Aplica fator de conversão do lote do fornecedor
			nAux  :=0
			If cFator == "M"
				nAux :=nQUNSB1/nFator
			ElseIf cFator == "D"
				nAux :=nQUNSB1*nFator						
			EndIf	
			
			//#TB20200324 Thiago Berna - Ajuste para nao executar o arredondamento quando estiver operando pela tela de pedido
			//#TB20200520 Thiago Berna - Ajuste para entrar quando for U_COM105 e nao tiver lote minimo
			//If IsInCallStack("U_AEST102")//l120Auto
			If IsInCallStack("U_AEST102") .Or. (IsInCallStack("U_COM105") .And. nLoteM == 0)
				// -> Arredonda apenas se for executado pela rotina de MRP
				cAux :=StrZero(nAux,16,4)
				cAux1:=StrTokArr(cAux,".")[1]
				cAux2:=StrTokArr(cAux,".")[2]
				nAux:=IIF(Val(cAux2)>0,Val(cAux1)+1,Val(cAux))	
			EndIf	
			
			// -> Aplica Fator de conversao na unidade de medida do restaurante
			If cFator == "M"
				nAux1:=nAux*nFator
			ElseIf cFator == "D"
				nAux1:=nAux/nFator						
			EndIf			
			
		EndIf	
						
		// -> Verifica o lote mínimo	
		//#TB20200306 Thiago Berna - Ajuste para correção de calculo
		//If nAux < nLoteM .And. nLoteM > 0 .and. nFator > 0
		If nLoteM > 0 .and. nFator > 0
			
			//#TB20200306 Thiago Berna - Ajuste para correção de calculo
			If nAux < nLoteM
				nAux :=nLoteM
			Endif

			// -> Aplica fator de conversão do lote do fornecedor
			If cFator == "M"
				nAux1 :=nAux1*nFator
			ElseIf cFator == "D"
				nAux1 :=nAux1/nFator							
			EndIf
			
			//#TB20200306 Thiago Berna - Ajuste para correção de calculo para que seja multiplo do lote minimo - Somente pelo Execauto do MRP
			//#TB20200520 Thiago Berna - Ajuste de formula conforme solicitado pelo fernando
			//If IsInCallStack("U_AEST102")//l120Auto
			If IsInCallStack("U_COM105")
				//nAux1 := Mod(nAux1,nLoteM) * nLoteM
				nAux1 := Ceiling(nAux1/nLoteM) * nLoteM
			EndIf

		EndIf	

		// -> Ajusta quantidade máxima para pedidos de compra conforme tabela
		If nAux1 > nMaxQtde .and. nMaxQtde > 0 // 03.02.2020
		nAux1:=NoRound(nMaxQtde,0)
			If cFator == "M"
				nAux :=NoRound(nAux1/nFator,0)
			ElseIf cFator == "D"
				nAux :=NoRound(nAux1/nFator,0)							
			EndIf
		EndIf

	EndIf	

	RestArea(a104PRF)

Return({nAux,nAux1,cUnidF,nFator,cFator,nLoteM})

                                            

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! xGetUn                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Busca unidades de negócio                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function xGetUn( cGrpNeg,cNegDe,cFilDe,cSegDe )
Local lRet		   := .F.
Local cQuery	   := ""
Local cAliasQry	:= GetNextAlias( )
Default cGrpNeg	:= ""
Default cNegDe	   := ''
Default cFilDe	   := ''
Default cSegDe	   := ''

cQuery += "  SELECT " + CRLF 
cQuery += "    ADK.ADK_XGEMP XGEMP " + CRLF
cQuery += "   ,ADK.ADK_XFILI CODFIL " + CRLF 
cQuery += "   ,ADK.ADK_NOME  NOME " + CRLF 
cQuery += "   FROM " + RetSQLName( "ADK" ) + " ADK " + CRLF 
cQuery += "  WHERE ADK.ADK_FILIAL = '" + xFilial( "ADK" ) + "' " + CRLF 
cQuery += "    AND ADK.ADK_XFILI <> ' ' " + CRLF
cQuery += "    AND ADK.ADK_XFILI <> '" + cFilAnt + "' " + CRLF  
If !Empty( cGrpNeg )
	If ADK->( FieldPos( "ADK_XGNEG" ) ) > 0
		cQuery += "    AND ADK.ADK_XGNEG  = '" + cGrpNeg + "' " + CRLF
	EndIf
	If ADK->( FieldPos( "ADK_XGEMP" ) ) > 0
		cQuery += "    AND ADK.ADK_XGEMP <> ' ' " + CRLF
	EndIf
EndIf
If !Empty( cFilDe )
   cQuery += "    AND ADK.ADK_XFILI   = '" + cFilDe + "' " + CRLF
EndIf
If !Empty( cSegDe )
   cQuery += "    AND ADK.ADK_XSEGUI  = '" + cSegDe + "' " + CRLF
EndIf
If !Empty( cNegDe )
   cQuery += "    AND ADK.ADK_XNEGOC  = '" + cNegDe + "' " + CRLF
EndIf
cQuery += "    AND ADK.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  GROUP BY " + CRLF
cQuery += "    ADK.ADK_XGEMP " + CRLF 
cQuery += "   ,ADK.ADK_XFILI " + CRLF 
cQuery += "   ,ADK.ADK_NOME " + CRLF 
cQuery += "  ORDER BY " + CRLF 
cQuery += "    ADK.ADK_XGEMP " + CRLF
cQuery += "   ,ADK.ADK_XFILI " + CRLF 
cQuery += "   ,ADK.ADK_NOME " + CRLF 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	

Return(cAliasQry)




/*
+----------------------------------------------------------------------------+
|Função            | GetDirIni                                               |
+------------------+---------------------------------------------------------+
|Descricao         | Pega diretório de execução do Smartclient               |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 17/09/2016                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/
User Function GetDirIni()
Local cIniName:=GetRemoteIniName() 
Local lUnix   :=IsSrvUnix()
Local nPos    :=Rat(IIF(lUnix,"/","\"),cIniName)
Local cPathRmt
   
  If !( nPos == 0 )
    cPathRmt := SubStr( cIniName, 1, nPos - 1 )
  Else
    cPathRmt := ""
  Endif
   
Return(cPathRmt)



/*
+----------------------------------------------------------------------------+
|Função            | IsBusiness                                              |
+------------------+---------------------------------------------------------+
|Descricao         | Verifica se a unidade corrente é um restaurante         |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 24/06/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/                                                    
User Function IsBusiness()
Local lRet    := .F. 
Local aAreaADK:= GetArea()
Local cFilADK := Space(TamSx3("ADK_FILIAL")[1])
	
	DbSelectArea("ADK")
	ADK->( dbOrderNickName("ADKXFILI") )
	ADK->(dbseek(cFilADK+cFilAnt)) 
  If ADK->(Found()) .and. ADK->ADK_XGNEG == "2"
		lRet := .T.
	EndIf	
	                      
	RestArea(aAreaADK)	
	
Return(lRet)                  


/*
+----------------------------------------------------------------------------+
|Função            | xGetUser                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna o nome do usuário conforme código do usuário    |
|                  | passado como parâmetro                                  |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/06/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/                                                    
User Function xGetUser(cXCod)
Local cRet:=" "
	If AllTrim(cxCod) <> "" 
		cRet:=IIF(AllTrim(cXCod)=="*","TODOS",UsrRetName(cXCod))
	EndIf	
Return(cRet)  


/*
+----------------------------------------------------------------------------+
|Função            | xGetUsrG                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a descrição do grupo de usuário conforme código |
|                  | passado como parâmetro                                  |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/06/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/                                                    
User Function xGetUsrG(cXCod)
Local cRet:=" "
	If AllTrim(cxCod) <> "" 
		cRet:=IIF(AllTrim(cXCod)=="*","TODOS",GrpRetName(cXCod))
	EndIf	
Return(cRet)  


/*
+----------------------------------------------------------------------------+
|Função            | xGImpACD                                                |
+------------------+---------------------------------------------------------+
|Descricao         | Retorna a impressora de etiquetas considerndo a linha de|
|                  | produção informada no cadastro de operações do PCP      |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 02/02/2020                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/                                                    
User Function xGImpACD(cCpdProduto)
Local cRet :=""
Local aArea:=GetArea()

	// -> Pesquisa produto no roteiro de operações
	DbSelectArea("SG2")
	SG2->(DbStOrder(1))
	
	If AllTrim(cxCod) <> "" 
		cRet:=IIF(AllTrim(cXCod)=="*","TODOS",GrpRetName(cXCod))
	EndIf	

RestArea(aArea())
Return(cRet)  



/*
+----------------------------------------------------------------------------+
|Função            |                                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Exemplo de MSExecAuto da rotina de desmontagem          |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/06/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/                                                    
User Function TMATA242()
Private lMsErroAuto := .F.
    	aAutoCab := {	{"cProduto"   ,"20603568000200 "	 		, Nil},;   			
						{"cLocOrig"   , "01"					    , Nil},;			
						{"nQtdOrig"   , 0.350                 		, Nil},;			
						{"nQtdOrigSe" , CriaVar("D3_QTSEGUM")		, Nil},;			
						{"cDocumento" , "123456789"					, Nil},;			
						{"cNumLote"   , CriaVar("D3_NUMLOTE")		, Nil},;			
						{"cLoteDigi"  , CriaVar("D3_LOTECTL")		, Nil},;			
						{"dDtValid"   , CriaVar("D3_DTVALID")		, Nil},;			
						{"nPotencia"  , CriaVar("D3_POTENCI")		, Nil},;			
						{"cLocaliza"  , CriaVar("D3_LOCALIZ")		, Nil},;			
						{"cNumSerie"  , CriaVar("D3_NUMSERI")		, Nil}}
	
		aAutoItens := {{	{"D3_COD"    , "20603924000800 "	                    , Nil}, ;			
											{"D3_LOCAL"  , "01"	          			, Nil}, ;			
											{"D3_QUANT"  , 1            			, Nil}, ;			
											{"D3_QTSEGUM", CriaVar("D3_QTSEGUM")	, Nil}, ;			
											{"D3_RATEIO" , 100 						, Nil}} }
							
	  MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.) 					
    If lMsErroAuto
        mostraerro()
    EndIf    
Return()






/*
+----------------------------------------------------------------------------+
|Função            |                                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Update do processo de integração de produtos - Teknisa  |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Márcio Zaguetti                                         |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/06/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/         
User Function UPDSB1TK()
Local cEmpresa := cEmpAnt
Local cEmpAux  := cFilAnt
Local aEmp     := {}
Local na       := 0
Local aParam   := {}

    // -> Carrega ambiente
    aParam := {{cEmpresa,cEmpAux}}
    RpcClearEnv()
    RPcSetType(3)
	RpcSetEnv( aParam[1,1],aParam[1,2], , ,'EST' , GetEnvServer() )
    OpenSm0(aParam[1,1], .f.)
	nModulo := 4

    SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[1,1]+aParam[1,2]))
	cEmpAnt := SM0->M0_CODIGO
    cFilAnt := SM0->M0_CODFIL

    // -> Busca todas as unidades de negócio
    DbSelectArea("ADK")
    ADK->(DbGoTop())
    aParam:={}
    While !ADK->(Eof())
      If !Empty(ADK->ADK_XFILI) .and. !Empty(ADK->ADK_XGEMP)
          Aadd(aParam,{ ADK->ADK_XGEMP,ADK->ADK_XFILI})
      EndIf
	  ADK->(DbSkip())
    EndDo
    RpcClearEnv()     
       
	// -> Executa processo para todas as empresas
	For na:=1 to Len(aParam)

		RPcSetType(3) 
		RpcSetEnv( aParam[na,1],aParam[na,2], , ,'EST' , GetEnvServer() )
    	OpenSm0(aParam[na,1], .f.)
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(aParam[na,1]+aParam[na,2]))
		nModulo := 4
		cEmpAnt := SM0->M0_CODIGO
		cFilAnt := SM0->M0_CODFIL
	    		   	
	   	ConOut(": -> Atualizando filial " + cFilAnt)
		// -> Posiciona nas eunidades de negócio : Unidade de negócio
	   	DbSelectArea("ADK")
	   	ADK->(DbOrderNickName("ADKXFILI"))
	   	If ADK->(ADK->(DbSeek(xFilial("ADK")+cFilAnt)))

    		// -> Posiciona no cadastro de produtos
      		DbSelectArea("SB1")
      		SB1->(DbSetOrder(1))
      		SB1->(DbSeek(xFilial("SB1")))
      		While !SB1->(Eof()) .and. SB1->B1_FILIAL == xFilial("SB1")

        		IntTek()  

        		SB1->(DbSkip())

      		EndDo

		EndIf	  
		
	   	ConOut(": -> Fim da atualizacao da filial " + cFilAnt)

		RpcClearEnv()
	
  Next na

Return("")



/*
+----------------------------------------------------------------------------+
|Função            |  IntTek                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Update para atualização da integração do Teknisa        |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Thiago Berna                                            |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 25/09/2019                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/         
Static Function IntTek()
Local lOpcao	  := .T.
Local lRet      := .T.
Local lAtivo    := IIF(SB1->B1_MSBLQL<>"1",.T.,.F.)        
Local lAtivar   := .F.
Local cGrpClie  := PadR(GetMv("MV_XGRCLIU",,""),TamSx3("F7_GRPCLI")[1])
Local cUFFil    := PadR(GetMV("MV_ESTADO",,""),TamSx3("F7_EST")[1])
Local cTpPdImp  := SUPERGETMV("MV_XTPDIMP",.F.,"PA/MP/ME/PI")
Local cTpIpImp  := SUPERGETMV("MV_XTIPIMP",.F.,"PA/PI/ME" )
Local cAliasQry	:= GetNextAlias( )
	
	
	// ->>>>>>>>>>>>>>>>>>>>>>>>> Gera dados para integração com o Teknisa <<<<<<<<<<<<<<<<<<<<<<<<<<<<<-
  		
	// -> Apenas marcar o cadastro de produto para integração, se o mesmo nao está pendente (item 124 da lista dependências)		
	If SB1->B1_TIPO $ cTpPdImp
		
		// -> Posiciona na tabela de integração de produtos
		ConOut("Produto "+SB1->B1_COD+" - "+SB1->B1_DESC)
    	dbSelectArea("Z13")
		Z13->(dbSetOrder(1))
		Z13->(dbSeek(xFilial("Z13")+SB1->B1_COD))
		If !Z13->(Found()) 
			Reclock("Z13",.T.)
			Z13->Z13_FILIAL	:= xFilial("Z13")
			Z13->Z13_XFILI	:= xFilial("SB1")
			Z13->Z13_COD	:= SB1->B1_COD  
			Z13->Z13_DESC   := SB1->B1_DESC
			Z13->Z13_XSTINT	:= IIF(Empty(SB1->B1_XCODEXT),"P","I")
			Z13->Z13_XEXC	:= "N"
			Z13->Z13_XCDARV := SB1->B1_XN1+SB1->B1_XN2+SB1->B1_XN3+SB1->B1_XN4
			Z13->Z13_XDINT	:= IIF(Empty(SB1->B1_XCODEXT),cTod("  /  /  "),Date())
			Z13->Z13_XHINT	:= IIF(Empty(SB1->B1_XCODEXT),""              ,Time())
			Z13->Z13_XCODEX	:= SB1->B1_XCODEXT
			Z13->Z13_XDTMOV := Date()
			Z13->Z13_XHRMOV := Time()
			Z13->Z13_XUSER  := "Compatiblizador"
			Z13->Z13_XLOG   := IIF(Empty(SB1->B1_XCODEXT),"Produto Incluido por compatibilizador","Produto integrado por compatibilizador")+" na " + cFilAnt 
			Z13->(MsUnlock())
		EndIf
			
		// -> Posiciona na tabela de integração de produtos e verifica se o item foi excluído
		dbSelectArea("Z13")
		Z13->(dbSetOrder(1))
		Z13->(dbSeek(xFilial("Z13")+SB1->B1_COD))
		lAtivar:=Z13->(Found()) .and. Z13->Z13_XEXC == "N" .and. Z13->Z13_XSTINT == "I" .and. lAtivo

		// -> Analisa se gera registro de ativação do porduto 
		If !Empty(Z13->Z13_XCODEX)
			
			// -> Atualiza status do produto no Teknisa
			DbSelectArea("Z17")
			Z17->(dbSetOrder(1))
			Z17->(dbSeek(xFilial("Z17")+SB1->B1_COD))	
			If !Z17->(found()) 
				RecLock("Z17",.T.)
				Z17->Z17_FILIAL	:= xFilial("Z17")
				Z17->Z17_COD	:= Z13->Z13_COD
				Z17->Z17_DESC   := Z13->Z13_DESC
				Z17->Z17_XCODEX := Z13->Z13_XCODEX
				Z17->Z17_XSTINT	:= IIF(Empty(SB1->B1_XCODEXT),"P","I")
				Z17->Z17_XCDARV	:= Z13->Z13_XCDARV
				Z17->Z17_XATIVO	:= IIF(lAtivar,"S","N")
				Z17->Z17_XDINT  := IIF(Empty(SB1->B1_XCODEXT),cTod("  /  /  "),Date())
				Z17->Z17_XHINT  := IIF(Empty(SB1->B1_XCODEXT),""              ,Time())
				Z17->Z17_XDTMOV := Date()
				Z17->Z17_XHRMOV := Time()
				Z17->Z17_XUSER  := "Compatiblizador"
				Z17->Z17_XLOG   := IIF(Empty(SB1->B1_XCODEXT),"Ativacao de produto Incluida por compatibilizador","Ativacao do produto integrada por compatibilizador")+" na " + cFilAnt 
				Z17->(msUnLock())
			EndIf

		EndIf
		
	EndIf	
		
Return("")




/*
+----------------------------------------------------------------------------+
|Função            |                                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Função para atualizar dados no dicionários de dados SC2 |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Thiago Berna                                            |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 25/09/2019                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/         
User Function XVALSC2(cCampo)
Local lRet      := .T.
Default cCampo  := ''

If !Inclui
    If cCampo == 'C2_XLOTE' .Or. cCampo == 'C2_XDTVAL'
        lRet := IIF(SC2->C2_QUJE == 0 .And. !U_ISBUSINESS() , .T. , .F.)     
    ElseIf cCampo == 'C2_QUANT'
        lRet := IIF(SC2->C2_TPOP == 'P' .And. !U_ISBUSINESS() , .T. , .F.)      
    EndIf
EndIf

Return lRet





User Function xDelZ16()
Local cFil :=""
Local cCod :=""
Local cGrup:=""
Local nx   :=0
	DbSelectArea("Z16")
	Z16->(DbSetOrder(1))
	Z16->(DbGoTop())
	While !Z16->(Eof())
		cFil :=Z16->Z16_FILIAL
		cCod :=Z16->Z16_COD
		cGrup:=Z16->Z16_GRPTRI
		nx   :=1
		While !Z16->(Eof()) .and. Z16->Z16_FILIAL == cFil .and. Z16->Z16_COD == cCod .and. Z16->Z16_GRPTRI == cGrup
			If nx > 1
				RecLock("Z16",.F.)
				Z16->(DbDelete())
				Z16->(MsUnlock())
			EndIf	
			nx:=nx+1
			Z16->(DbSkip())
		EndDo
		//Z16->(DbSkip()) 
	EndDo
Return("")



/*
+----------------------------------------------------------------------------+
|Função            |  CharToVal                                              |
+------------------+---------------------------------------------------------+
|Descricao         | Função para comverter Cracater em Valor com casas deci- |
|                  | mais do protheus                                        |
+------------------+---------------------------------------------------------+
|Autor             | Mario L. B. Faria                                       |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 16/05/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/         
User Function xCharToVal(cVal,cCpo)
Local nRet:=Round(Val(StrTran(cVal,",",".")),TamSx3(cCpo)[02])
Return nRet


/*
+----------------------------------------------------------------------------+
|Função            |  DHtoD                                                  |
+------------------+---------------------------------------------------------+
|Descricao         | função para retornar a data de um campo Date Time       |
|                  |                                                         |
+------------------+---------------------------------------------------------+
|Autor             | Mario L. B. Faria                                       |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 16/05/2018                                              |
+------------------+---------------------------------------------------------+
|  Informações     |                                                         |
|   Adicionais     |                                                         |
+----------------------------------------------------------------------------+
*/         
User Function xDHtoD(cDH)
Local cRet	:= ""
	
	If !Empty(cDH)
		cRet := CtoD(SubStr(cDH,1,10))
	Else
		cRet := CtoD("  /  /    ")
	EndIf
	
Return cRet

User Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
	/*
	+------------------+------------------------------------------------------------+
	!Modulo            ! Diversos                                                   !
	+------------------+------------------------------------------------------------+
	!Nome              ! FiltroF3                                                   !
	+------------------+------------------------------------------------------------+
	!Descricao         ! Função usada para criar uma Consulta Padrão  com SQL       !
	!			       !                                                            !
	!			       !                                                            !
	+------------------+------------------------------------------------------------+
	!Autor             ! Rodrigo OverFail - BlackTDN                                !
	+------------------+------------------------------------------------------------+
	!Data de Criacao   ! 19/12/2019                                                 !
	+------------------+-----------+------------------------------------------------+
	!Campo             ! Tipo	   ! Obrigatorio                                    !
	+------------------+-----------+------------------------------------------------+
	!cTitulo           ! Caracter  !                                                !
	!cQuery            ! Caracter  ! X                                              !
	!nTamCpo           ! Numerico  !                                                !
	!cAlias            ! Caracter  ! X                                              !
	!cCodigo           ! Caracter  !                                                !
	!cCpoChave         ! Caracter  ! X                                              !
	!cTitCampo         ! Caracter  ! X                                              !
	!cMascara          ! Caracter  !                                                !
	!cRetCpo           ! Caracter  ! X                                              !
	!nColuna           ! Numerico  !                                                !
	+------------------+-----------+------------------------------------------------+
	!Parametros:                                                                    !
	!==========		                                                                !
	!          								        							    !
	!cTitulo = Titulo da janela da consulta                                         !
	!cQuery  = A consulta SQL que vem do parametro cQuery não pode retornar um outro!
	!nome para o campo pesquisado, pois a rotina valida o nome do campo real        !
	!          												   					    !
	!Exemplo Incorreto                                                              !
	!cQuery := "SELECT A1_NOME 'NOME', A1_CGC 'CGC' FROM SA1010 WHERE D_E_L_E_T_='' !
	!          																		!
	!Exemplo Certo                                                                  !
	!cQuery := "SELECT A1_NOME, A1_CGC FROM SA1010 WHERE D_E_L_E_T_=''              !
	!          																		!
	!Deve-se manter o nome do campo apenas.                                         !
	!          																		!
	!nTamCpo   = Tamanho do campo de pesquisar,se não informado assume 30 caracteres!
	!cAlias    = Alias da tabela, ex: SA1                                           !
	!cCodigo   = Conteudo do campo que chama o filtro                               !
	!cCpoChave = Nome do campo que será utilizado para pesquisa, ex: A1_CODIGO      ! 
	!cTitCampo = Titulo do label do campo                                           !
	!cMascara  = Mascara do campo, ex: "@!"                                         !
	!cRetCpo   = Campo que receberá o retorno do filtro                             !
	!nColuna   = Coluna que será retornada na pesquisa, padrão coluna 1             !
	+--------------------------------------------------------------------------------
	*/

	Local nLista  
	Local nCont			:= 0
	Local nX
	
	Local cCampos 		:= ""
	Local cTabela 
	Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	Local cCSSButF3		:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
	
	Local bCampo		:= {}
	Local bTitulos		:= {}
	
	Local aCampos 		:= {}

	Private _oLista		:= NIL
	Private _oDlg 		:= NIL
	Private _oCodigo
	Private _cCodigo 	
	Private _aDados 	:= {}
	Private _nColuna	:= 0
	
	Default cTitulo 	:= ""
	Default cCodigo 	:= ""
	Default cTitCampo	:= RetTitle(cCpoChave)
	Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)
	Default nTamCpo 	:= 30
	Default _nColuna 	:= 1
	

	_nColuna	:= nColuna
	_aDados		:= {}

	IF Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	EndIF

	_cCodigo := Space(nTamCpo)
	_cCodigo := cCodigo

	cTabela:= CriaTrab(NIL,.F.)
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),cTabela, .F., .T.)
     
	(cTabela)->(dbGoTop())
	IF (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		bRet := .F.
	EndIF
   
	Do While (cTabela)->(.NOT. Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 To FCount()
			bCampo := {|nX| Field(nX) }
			IF ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				IF ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
				ELSEIF ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				ELSE
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				EndIF
					
				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			EndIF
		Next
     
     	IF .NOT. Empty(cCampos) 
     		cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
     		aAdd( _aDados,&("{"+cCampos+"}"))
     	EndIF
     	
		(cTabela)->(DbSkip())     
	EndDo
   
	dbCloseArea(cTabela)
	
	IF Len(_aDados) == 0
		MsgInfo("Não há dados para exibir!","Aviso")
		bRet := .F.
	EndIF
   
	nLista := aScan(_aDados, {|x| AllTrim(x[1]) == AllTrim(_cCodigo)})
     
	IIF(nLista = 0,nLista := 1,nLista)
     
	DEFINE MSDIALOG _oDlg TITLE "Consulta Padrão" + IIF( .NOT. Empty(cTitulo)," - " + cTitulo,"") FROM 0,0 TO 280, 500 OF oMainWnd PIXEL
	
	oCodigo:= TGet():New( 003, 005,{|u| IF(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)	
	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)	
	    
	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
        //Para ficar dinÃ¢mico a criaÃ§Ã£o das colunas, eu uso macro substituiÃ§Ã£o "&"
	For nX := 1 To Len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		:= { || Len(_aDados) > 0 }
	_oLista:bLDblClick	:= { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	ACTIVATE MSDIALOG _oDlg CENTERED	

Return(bRet)

Static Function FiltroF3P(cBusca)
	Local i := 0

	IF .NOT. Empty(cBusca)
		For i := 1 To Len(_aDados)
			//Aqui busco o texto exato, mas pode utilizar a funÃ§Ã£o AT() para pegar parte do texto
			IF UPPER(AllTrim(_aDados[i,_nColuna]))==UPPER(AllTrim(cBusca))
				//Se encontrar me posiciono no grid e saio do "For"			
				_oLista:GoPosition(i)
				_oLista:Setfocus()
				Exit
			EndIF
		Next
	EndIF
Return

Static Function FiltroF3R(nLinha,aDados,cRetCpo)
	cCodigo := aDados[nLinha,_nColuna]
	&(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
	//aCpoRet[1] := cCodigo //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno
	bRet := .T.
	
	//#TB20200420 Thiago Berna - Ajuste para posicionar corretamente no registro da tabela SBE
	//quando o campo for o CENDENTRADA
	If cRetCpo == "CENDENTRADA"
		SBE->(DbSetOrder(1))	//BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
		IF !SBE->(DbSeek(xFilial("SBE")+aDados[nLinha,1]+aDados[nLinha,2]))
			bRet	:= .F.
		EndIF
	Else
		dbSelectArea("SB1")
		dbSetOrder(1)
		IF .NOT. dbSeek(xFilial("SB1")+cCodigo )
			bRet	:= .F.
		EndIF
	EndIf
	_oDlg:End()    
Return

/*
Consulta padrão do campo BC_PRODUTO
*/
User Function SBCF3001()
	Local cTitulo		:= "Produto Origem x SD4"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SBC"							//obrigatorio
	Local cCpoChave		:= "BC_PRODUTO" 					//obrigatorio
	Local cTitCampo		:= RetTitle(cCpoChave)				//obrigatorio
	Local cMascara		:= PesqPict(cAlias,cCpoChave)		//obrigatorio
	Local cRetCpo		:= ReadVar()						//obrigatorio
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão	
	Local cDB			:= TCGetDB()
	
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local nColuna		:= 1		
	
 	Private bRet 		:= .F.

   	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que nÃ£o posso utilizar um alias para o nome do campo, deixar o nome real.
   	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.

	cQuery := " SELECT	B1.B1_COD, "
	cQuery += "			B1.B1_DESC "
	cQuery += " FROM " + RetSqlName("SB1") + " B1 "
	cQuery += " WHERE B1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND B1.B1_APROPRI = 'D' "
	cQuery += " AND B1.B1_COD = '" + cProduto + "'"
	cQuery += " AND B1.D_E_L_E_T_ = ' ' "
	cQuery += " UNION ALL "
	cQuery += " SELECT	D4.D4_COD, "
	cQuery += "			B1.B1_DESC "
	cQuery += " FROM " + RetSqlName("SD4") + " D4 "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 "
	cQuery += " ON D4.D4_COD = B1.B1_COD "
	cQuery += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND B1.B1_APROPRI = 'D' "
	cQuery += " AND B1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE D4.D4_FILIAL = '" + xFilial("SD4") + "'"
	cQuery += " AND D4.D4_OP = '" + cOrdemP + "'"
	cQuery += " AND D4.D_E_L_E_T_ = ' ' "

 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
Return(bRet)

/*
Consulta padrão do campo BC_CODDEST
*/
User Function SBCF3002()
	Local cTitulo		:= "Produto Destino x Z59"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "SBC"							//obrigatorio
	Local cCpoChave		:= "BC_CODDEST" 					//obrigatorio
	Local cTitCampo		:= RetTitle(cCpoChave)				//obrigatorio
	Local cMascara		:= PesqPict(cAlias,cCpoChave)		//obrigatorio
	Local cRetCpo		:= ReadVar()						//obrigatorio
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrÃ£o	
	
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local nColuna		:= 1		
 	
	Private bRet 		:= .F.

	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que nÃ£o posso utilizar um alias para o nome do campo, deixar o nome real.
   	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
	cQuery := " SELECT	Z59.Z59_CODREC, " 
	cQuery += "			B1.B1_DESC "
	cQuery += " FROM " + RetSqlName("Z59") + " Z59 " 
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 " 
	cQuery += "	ON Z59.Z59_CODREC = B1.B1_COD "
	cQuery += "	AND B1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += " AND B1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
	cQuery += " Z59.Z59_FILIAL = '" + xFilial("Z59") + "'"
	cQuery += " AND "
	cQuery += " Z59.Z59_PRDPAI = '" + aCols[n,nPosCod] + "'"
	cQuery += " AND "
	cQuery += "	Z59.D_E_L_E_T_ = ' ' " 
	
	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
Return(bRet)

/*
Consulta padrão do campo ZI3_ZI3_ENDENT
*/
User Function ZI3F3001()
	Local cTitulo		:= "Endereços de Entrega"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "ZI3"							//obrigatorio
	Local cCpoChave		:= "ZI3_ENDENT" 					//obrigatorio
	Local cTitCampo		:= RetTitle(cCpoChave)				//obrigatorio
	Local cMascara		:= PesqPict(cAlias,cCpoChave)		//obrigatorio
	Local cRetCpo		:= ReadVar()						//obrigatorio
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão	
	
	Local nTamCpo		:= TamSx3(cCpoChave)[1]		
	Local nColuna		:= 2		
	Local xLocal		:= AllTrim(Posicione("SB1",1,xFilial("SB1")+ZI2->ZI2_PROD,"B1_LOCPAD"))
 	
	Private bRet 		:= .F.	

	//Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que nÃ£o posso utilizar um alias para o nome do campo, deixar o nome real.
   	//Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
	cQuery := " SELECT	BE.BE_LOCAL, " 
	cQuery += "			BE.BE_LOCALIZ, "
	cQuery += "			BE.BE_DESCRIC "
	cQuery += " FROM " + RetSqlName("SBE") + " BE " 
	cQuery += " WHERE "
	cQuery += " BE.BE_FILIAL = '" + xFilial("SBE") + "'"
	cQuery += " AND "
	cQuery += " BE.BE_LOCAL = '" + xLocal + "'"
	cQuery += " AND "
	cQuery += "	BE.D_E_L_E_T_ = ' ' " 
	
	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
Return(bRet)