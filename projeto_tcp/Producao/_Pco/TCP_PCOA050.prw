#Include "Protheus.ch"
#Include "Topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
! Versão           ! Protheus 11                                             !
+------------------+---------------------------------------------------------+
! Tipo             ! Rotina                                                  !
+------------------+---------------------------------------------------------+
! Modulo           ! PCO                                                     !
+------------------+---------------------------------------------------------+
! Nome             ! PCOA050                                                 !
+------------------+---------------------------------------------------------+
! Descricao        ! Lançamentos do PCO                                      !
+------------------+---------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------+
! Data de Criacao  ! 08/07/2015                                              !
+------------------+---------------------------------------------------------+
*/

/*
+------------------+---------------------------------------------------------+
! Função           ! XVldLcto                                                !
+------------------+---------------------------------------------------------+
! Descrição        ! Valida geração de lançamentos                           !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
+------------------+---------------------------------------------------------+
*/

User Function xVldLcto()
Local aArea:=GetArea()
Local lRet :=.T.
Local cQry :=Space(0)
Local cTp  :=Space(0)
Local cCta :=Space(0)

   If Select("TMPX") > 0
      dbSelectArea("TMPX")
      dbCloseArea("TMPX")
   Endif

   cQry:="SELECT AK2_CO, AK2_CC, AK2_ITCTB, AK2_ORCAME "
   cQry+="FROM " + RetSqlName("AK2") + " AS AK2 WITH (NOLOCK)        " 
   cQry+="WHERE AK2.D_E_L_E_T_ <> '*'                            AND "  
   cQry+="	    AK2.AK2_FILIAL  = '" + xFilial("AK2")     + "'   AND "
   cQry+="	    AK2.AK2_CO      = '" + &(AKC->AKC_CO)     + "'   AND "
   cQry+="	    AK2.AK2_CC      = '" + &(AKC->AKC_CC)     + "'   AND "
   cQry+="	    AK2.AK2_ORCAME  = '" + &(AKC->AKC_CODPLA) + "'   AND "
   cQry+="	    AK2.AK2_VERSAO  = '" + &(AKC->AKC_VERSAO) + "'       "
   TcQuery cQry New Alias "TMPX"
   TMPX->(DbGoTop())
   cCta :=&(AKC->AKC_CO)

   If AllTrim(GetMv("MV_XPCAPEX")) == AllTrim(TMPX->AK2_ORCAME)
      cTp:="CAPEX"
   ElseIf AllTrim(GetMv("MV_XPOPEX")) == AllTrim(TMPX->AK2_ORCAME)   
      cTp:="OPEX"
   EndIf   

   If Empty(AllTrim(TMPX->AK2_CO))
      lRet:=.F.
   ElseIf !Empty(AllTrim(TMPX->AK2_CO)) .and.  Empty(AllTrim(TMPX->AK2_CC)) .and. cTp == "OPEX"
      lRet:=.T.
   ElseIf !Empty(AllTrim(TMPX->AK2_CO)) .and.  Empty(AllTrim(TMPX->AK2_CC)) .and. Empty(AllTrim(TMPX->AK2_ITCTB)) .and. cTp == "CAPEX"
      lRet:=.T.   
   ElseIf !Empty(AllTrim(TMPX->AK2_CO)) .and. !Empty(AllTrim(TMPX->AK2_CC)) .and. Empty(AllTrim(TMPX->AK2_ITCTB)) .and. cTp == "CAPEX"
      lRet:=.T.   
   EndIf

   If Empty(cTp)
      lRet:=.F.
   EndIf

   RestArea(aArea) 

Return(lRet)




/*
+------------------+---------------------------------------------------------+
! Função           ! XVldLcto                                                !
+------------------+---------------------------------------------------------+
! Descrição        ! Valida geração de lançamentos                           !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
+------------------+---------------------------------------------------------+
*/

User Function GetPlan(cCon)
Local aArea   :=GetArea()
Local aRet    :={}
Local cQry    :=Space(0)
Local cAuxTipo:=Space(0)
Local cConta  :=IIF(cCon==Nil,&(AKI->AKI_CO),cCon)
Local lOk     :=.F.
Local cCC	  := ""

   If Select("TMP") > 0
      dbSelectArea("TMP")
      dbCloseArea("TMP")
   Endif
                     
	cConta  := &(AKI->AKI_CO)
	If FunName()=="FINA050"
	    cCC		:= M->E2_CC
	Else	
		cCC		:= SED->ED_CCD	
	EndIf    

   	cQry:="SELECT TOP 1 AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_CC, AK2_ITCTB "
   	cQry+="FROM " + RetSqlName("AK2") + " AS AK2 WITH (NOLOCK)        " 
   	cQry+="WHERE AK2.D_E_L_E_T_ <> '*'                            AND "  
   	cQry+="	    AK2.AK2_FILIAL  = '" + xFilial("AK2")     	+ "'   AND "
   	cQry+="	    AK2.AK2_CO      = '" + cConta     			+ "'  AND    "
	cQry+="	    AK2.AK2_DATAI	<= '" + DtoS(dDatabase)     + "'  AND     "   
	cQry+="	    AK2.AK2_DATAF	>= '" + DtoS(dDatabase)     + "'       "	
   // alteração realizada por AFSOUZA em 13/05/2016
   If !Empty(Alltrim(cCC))
   		cQry+="	 AND AK2.AK2_CC      = '" + cCC   + "'       "
   EndIf    

   TcQuery cQry New Alias "TMP"
   TMP->(DbGoTop())

   aadd(aRet,AllTrim(TMP->AK2_ORCAME))
   aadd(aRet,AllTrim(TMP->AK2_VERSAO))
      
   If AllTrim(GetMv("MV_XPCAPEX")) == aRet[1]
      cAuxTipo:="CAPEX"
      lOk     :=.T.
   ElseIf AllTrim(GetMv("MV_XPOPEX")) == aRet[1]
      cAuxTipo:="OPEX"
      lOk     :=.T.
   EndIf   

   If Empty(TMP->AK2_CO) 
      aRet:={}
      aadd(aRet,"")
      aadd(aRet,"")
   ElseIf !Empty(AllTrim(TMP->AK2_CO)) .and.  Empty(AllTrim(TMP->AK2_CC)) .and. Empty(AllTrim(TMP->AK2_ITCTB)) .and. cAuxTipo == "CAPEX"
      aRet:={}
      aadd(aRet,"")
      aadd(aRet,"")
   ElseIf !Empty(AllTrim(TMP->AK2_CO)) .and. !Empty(AllTrim(TMP->AK2_CC)) .and. Empty(AllTrim(TMP->AK2_ITCTB)) .and. cAuxTipo == "CAPEX"
      aRet:={}
      aadd(aRet,"")
      aadd(aRet,"")
   EndIf
   
   
   If Select("TMP") > 0
      dbSelectArea("TMP")
      dbCloseArea("TMP")
   Endif                         
                        
   // -> Altera dados do bloqueio  
   If !Empty(cAuxTipo) .and. lOk 
   
      DbSelectArea("AKH")
      AKH->(DbOrderNickName("AKH_TIPO"))
      AKH->(DbSeek(xFilial("AKH")+AKI->AKI_PROCES)) 
      While !AKH->(Eof()) .and. xFilial("AKH") == AKH->AKH_FILIAL .and. AKH->AKH_PROCESS == AKI->AKI_PROCESS   
         RecLock("AKH",.F.)
         AKH_ATIVO:=IIF(AllTrim(AKH->AKH_XTIPO) == cAuxTipo,"LBOK","LBNO")                  
         MsUnlock("AKH")
         AKH->(DbSkip())
      EndDo    
   
   EndIf
   
   // -> Altera dados do bloqueio - contas não cadastradas (não bloqueia)
   If Empty(aRet[1])

      DbSelectArea("AKH")
      AKH->(DbOrderNickName("AKH_TIPO"))
      AKH->(DbSeek(xFilial("AKH")+AKI->AKI_PROCES)) 
      While !AKH->(Eof()) .and. xFilial("AKH") == AKH->AKH_FILIAL .and. AKH->AKH_PROCESS == AKI->AKI_PROCESS   
         RecLock("AKH",.F.)
         AKH_ATIVO:="LBNO"                  
         MsUnlock("AKH")
         AKH->(DbSkip())
      EndDo    
   
   EndIf
      
   
   RestArea(aArea)

Return(aRet)                                                





/*
+------------------+---------------------------------------------------------+
! Função           ! xGetCo                                                  !
+------------------+---------------------------------------------------------+
! Descrição        ! Busca a conta contábil\orçamentária                     !
!                  !                                                         !
!                  !                                                         !
!                  !                                                         !
+------------------+---------------------------------------------------------+
*/

User Function xGetCo(cNat)
Local aArea   :=GetArea()
Local cRet    :=Posicione("SED",1,xFilial("SED")+cNat,"ED_CONTA")

RestArea(aArea)

Return(cRet)                                                