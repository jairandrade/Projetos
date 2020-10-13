// ---------------------------------------------------------------------------------------------------------------
//   Função para retornar o preço de custo do produto para operações entre filiais
// ---------------------------------------------------------------------------------------------------------------
User Function xCusProd(xcTp)
Local nPosProd:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"}) //u_xPaHeader(aHeader,"C6_PRODUTO")
Local nPosLoca:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"}) //u_xPaHeader(aHeader,"C6_LOCAL")
Local nPosPTab:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRUNIT"}) //u_xPaHeader(aHeader,"C6_PRUNIT") 
Local nPosPUni:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"}) //u_xPaHeader(aHeader,"C6_PRCVEN") 
Local nPosVtot:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"}) //u_xPaHeader(aHeader,"C6_VALOR")
Local nPosQtde:=aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})  //u_xPaHeader(aHeader,"C6_QTDVEN")
Local nVrRet  :=aCols[n,nPosPUni]
Local aAreax  :=GetArea()
Local cXVal   :=Space(0)
Local cCGC    :=Space(0)                                              
Local cCGCEmp :=SubStr(SM0->M0_CGC,1,8)                                              
Local lxRet   :=.F.
Local aRet    :={}
Local lxRetVa :=.T.          
Local xCtipo  :=xcTp  
Local cQuery  :=Space(0)
Local nLasrPrc:=0
Local cLPV    :=Space(0)                   
Local DFecha  :=GetMv("MV_ULMES")

   If ValType(l410auto) <> "U"
      If l410auto
         Aadd(aRet,aCols[n,nPosPUni])
         Aadd(aRet,aCols[n,nPosQtde])
         Aadd(aRet,aCols[n,nPosProd])
         Aadd(aRet,lxRet)
         If xCtipo == "C" 
            Return(.T.)    
         Else
            Return(aRet)
         EndIf
      EndIf    
   EndIf   

   // -> Busca validação da SX3 para a quantidade unitária
   DbSelectArea("SX3")
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("C6_QTDVEN"))
   cXVal:=AllTrim(SX3->X3_VALID)
                                                  
   // -> Busca cliente/fornecedor no pedido de venda
   If AllTrim(M->C5_TIPO) <> "B"
      DbSelectArea("SA1")
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
      cCGC:=IIF(Len(AllTrim(SA1->A1_CGC)) > 11,SubStr(SA1->A1_CGC,1,8),"")
   Else
      DbSelectArea("SA2")
      SA2->(DbSetOrder(1))
      SA2->(DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
      cCGC:=IIF(Len(AllTrim(SA2->A2_CGC)) > 11,SubStr(SA2->A2_CGC,1,8),"")
   EndIf

   If ( cCGC == cCGCEmp .and. !Empty(AllTrim(cCGCEmp)) ) .or. ( AllTrim(M->C5_TIPO) == "B" )
   
      // -> Busca custo do produto do último fechamento
      nVrRet:=0
      nAuxValor:=0
      nAuxQuant:=0
      DbSelectArea("SB9")
      SB9->(DbSetOrder(1))
      If SB9->(DbSeek(xFilial("SB9")+aCols[n,nPosProd]+aCols[n,nPosLoca]+DtoS(dFecha)))
         If SB9->B9_CM1 > 0 
            nAuxValor:=SB9->B9_CM1
         Else                     
            nAuxValor:=SB9->B9_CUSTD
         EndIf
      EndIf
                                
      nVrRet:=nAuxValor
      
      // -> Busca custo Standard do Produto
      If nVrRet <= 0
         DbSelectArea("SB2")
         SB2->(DbSetOrder(1))
         SB2->(DbSeek(xFilial("SB2")+aCols[n,nPosProd]))
         nVrRet:=SB2->B2_CM1
      EndIf

      // -> Executa função para validação do campo C6_PRCVEN
      If xCtipo == "C"     
      
         If Round(nVrRet,2) < Round(M->C6_PRCVEN,2)
            lxRetVa :=.F.
            RestArea(aAreax)   
            Aviso("Custo Medio","O valor infomado para a operação entre filiais está incorreto." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Custo Médio: "+Transform(nVrRet,"@E 999,999,999.99") + Chr(13) + Chr(10) + "Valor informado: "+Transform(M->C6_PRCVEN,"@E 999,999,999.99") , {"Ok"}, 2)
            Return(.F.)
         
         Else

            If (Select("TMP001") <> 0)
      	        dbSelectArea("TMP001")
	           dbCloseArea()
            Endif                               
       
            cQuery:="SELECT TOP 2 C5.R_E_C_N_O_, C5.C5_EMISSAO, C6_PRCVEN, C6_PRUNIT, C5_NUM "
            cQuery+="FROM " + RetSqlName("SC5") + " AS C5 INNER JOIN " + RetSqlName("SC6") + " AS C6 "
            cQuery+="ON C5.C5_FILIAL = C6.C6_FILIAL AND "
            cQuery+="   C5.C5_NUM    = C6.C6_NUM        "
            cQuery+="JOIN " + RetSqlName("SA1") + " AS A1 "
            cQuery+="ON C5.C5_CLIENT    = A1.A1_COD AND   "
            cQuery+="   C5.C5_LOJACLI   = A1.A1_LOJA      "
            cQuery+="WHERE C5.D_E_L_E_T_ <> '*'                         AND "
            cQuery+="      C6.D_E_L_E_T_ <> '*'                         AND "
            cQuery+="      C5_TIPO        = 'N'                         AND "
            cQuery+="      C6_PRODUTO     = '" + aCols[n,nPosProd] + "' AND "
            cQuery+="      C5_FILIAL      = '" + cFilAnt           + "' AND "
            cQuery+="      SUBSTRING(A1.A1_CGC,1,8) <> '" + SubStr(SM0->M0_CGC,1,8) + "' "                     
            cQuery+="ORDER BY C5.R_E_C_N_O_ DESC  "
            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP001", .F., .T.)
      
            DbSelectArea("TMP001")
            DbGoTop()
            While !Eof() 
               If Round(C6_PRCVEN,2) < Round(nVrRet,2)
                  lxRetVa :=.F.
                  nLasrPrc:=C6_PRCVEN
                  cLPV    :=C5_NUM
               Else
                  lxRetVa :=.T.
                  nLasrPrc:=C6_PRCVEN
                  cLPV    :=C5_NUM
               EndIf   
               DbSkip()
            EndDo
      
            If lxRetVa
               aCols[n,nPosPUni]:=A410Arred(M->C6_PRCVEN,"C6_PRCVEN") 
               aCols[n,nPosPTab]:=M->C6_PRCVEN
               aCols[n,nPosVtot]:=A410Arred(aCols[n,nPosQtde]*aCols[n,nPosPUni],"C6_VALOR")			
               M->C6_PRCVEN     :=aCols[n,nPosPUni]
               M->C6_PRCVEN     :=aCols[n,nPosPTab]
               M->C6_VALOR      :=aCols[n,nPosVtot]
            EndIf
         
         EndIf                
      
      Else      
      
         aCols[n,nPosPUni]:=A410Arred(nVrRet,"C6_PRCVEN") 
         aCols[n,nPosPTab]:=aCols[n,nPosPUni]
         aCols[n,nPosVtot]:=A410Arred(aCols[n,nPosQtde]*aCols[n,nPosPUni],"C6_VALOR")			
      
      EndIf
      
   EndIf
   
   // -> Executa função para validação do campo C6_PRCVEN
   If xCtipo == "C"            
      If lxRetVa      
         lxRet:=&(cXVal)   
         RestArea(aAreax)   
         Return(.T.)
      else
         RestArea(aAreax)   
         Aviso("Custo Medio","O valor infomado para a operação entre filiais está incorreto." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Custo Médio: "+Transform(nVrRet,"@E 999,999,999.99") + Chr(13) + Chr(10) + "Ultimo Preço venda (Pedido "+cLPV+"): "+Transform(nLasrPrc,"@E 999,999,999.99") + "Valor Informado: "+Transform(M->C6_PRCVEN,"@E 999,999,999.99"), {"Ok"}, 2)
         Return(.F.)
      EndIf   
   Else
      lxRet:=&(cXVal)   
      Aadd(aRet,aCols[n,nPosPUni])                     
      Aadd(aRet,aCols[n,nPosQtde])
      Aadd(aRet,aCols[n,nPosProd])
      Aadd(aRet,lxRet)
      RestArea(aAreax)   
   EndIf   		
   		
Return(aRet)


 /*                              
   If ValType(l410auto) <> "U"
      If l410auto
         Aadd(aRet,aCols[n,nPosPUni])
         Aadd(aRet,aCols[n,nPosQtde])
         Aadd(aRet,aCols[n,nPosProd])
         Aadd(aRet,lxRet)
         If xCtipo == "C" 
            Return(.T.)    
         Else
            Return(aRet)
         EndIf
      EndIf    
   EndIf   

   // -> Busca validação da SX3 para a quantidade unitária
   DbSelectArea("SX3")
   SX3->(DbSetOrder(2))
   SX3->(DbSeek("C6_QTDVEN"))
   cXVal:=AllTrim(SX3->X3_VALID)
                                                  
   // -> Busca cliente/fornecedor no pedido de venda
   If AllTrim(M->C5_TIPO) <> "B"
      DbSelectArea("SA1")
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
      cCGC:=IIF(Len(AllTrim(SA1->A1_CGC)) > 11,SubStr(SA1->A1_CGC,1,8),"")
   Else
      DbSelectArea("SA2")
      SA2->(DbSetOrder(1))
      SA2->(DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
      cCGC:=IIF(Len(AllTrim(SA2->A2_CGC)) > 11,SubStr(SA2->A2_CGC,1,8),"")
   EndIf

   If ( cCGC == cCGCEmp .and. !Empty(AllTrim(cCGCEmp)) ) .or. ( AllTrim(M->C5_TIPO) == "B" )
   
      // -> Busca custo do produto do último fechamento
      nVrRet:=0
      nAuxValor:=0
      nAuxQuant:=0
      DbSelectArea("SB9")
      SB9->(DbSetOrder(1))
      If SB9->(DbSeek(xFilial("SB9")+aCols[n,nPosProd]+aCols[n,nPosLoca]+DtoS(dFecha)))
         If SB9->B9_CM1 > 0 
            nAuxValor:=SB9->B9_CM1
         Else                     
            nAuxValor:=SB9->B9_CUSTD
         EndIf
      EndIf
                                
      nVrRet:=nAuxValor
      
      // -> Busca custo Standard do Produto
      If nVrRet <= 0
         DbSelectArea("SB2")
         SB2->(DbSetOrder(1))
         SB2->(DbSeek(xFilial("SB2")+aCols[n,nPosProd]))
         nVrRet:=SB2->B2_CM1
      EndIf

      // -> Executa função para validação do campo C6_PRCVEN
      //If xCtipo == "C"     
      
      If  cCGC == cCGCEmp .and. Round(nVrRet,2) <= 0 // Round(M->C6_PRCVEN,2)
          lxRetVa :=.F.
          RestArea(aAreax)   
          Aviso("Custo Medio","O valor infomado para a operação entre filiais está incorreto." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Custo Médio: "+Transform(nVrRet,"@E 999,999,999.99") + Chr(13) + Chr(10) + "Valor informado: "+Transform(M->C6_PRCVEN,"@E 999,999,999.99") , {"Ok"}, 2)
          Return(.F.)
      ElseiF cCGC == cCGCEmp      
      
         aCols[n,nPosPUni]:=A410Arred(nVrRet,"C6_PRCVEN") 
         aCols[n,nPosPTab]:=aCols[n,nPosPUni]
         aCols[n,nPosVtot]:=A410Arred(aCols[n,nPosQtde]*aCols[n,nPosPUni],"C6_VALOR")			
      
      EndIf
      
   EndIf
   
   // -> Executa função para validação do campo C6_PRCVEN
   If cCGC == cCGCEmp .and. Round(nVrRet,2) > 0
      lxRet:=&(cXVal)   
      Aadd(aRet,aCols[n,nPosPUni])                     
      Aadd(aRet,aCols[n,nPosQtde])
      Aadd(aRet,aCols[n,nPosProd])
      Aadd(aRet,lxRet)
      RestArea(aAreax)   
   Elseif cCGC == cCGCEmp  .and. Round(nVrRet,2) > 0
      RestArea(aAreax)   
      Aviso("Custo Medio","O valor infomado para a operação entre filiais está incorreto." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Custo Médio: "+Transform(nVrRet,"@E 999,999,999.99") + Chr(13) + Chr(10) + "Ultimo Preço venda (Pedido "+cLPV+"): "+Transform(nLasrPrc,"@E 999,999,999.99") + "Valor Informado: "+Transform(M->C6_PRCVEN,"@E 999,999,999.99"), {"Ok"}, 2)
      Return(.F.)
   EndIf   		
   		
    Return(aRet)
*/