#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "TOPCONN.CH"

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para cadastrar as regras para produtos usu�rios e c�ddigos de movimen- !
!                  ! ta��es                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! M�rcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200()
Local   aArea   :=GetArea()
Private cTab    :="Z30"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
Private bOK     :={|| U_EST200OK()}     
Private bTTS
Private bNoTTS             
Private cCadTit :="Regras de movimentos por tipo"

	If !u_IsBusiness()  
	    RestArea(aArea)                   
		ApMsgInfo("A filial n�o � uma unidade de neg�cio. [ADK_XFILI = Vazio ].","[NOBUSINESS] - Valida��o da unidade de neg�cio")
		Return
	Endif

   Aadd(aRotAdic,{"Replicar","u_EST004()",0 ,2}) 
   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
   RestArea(aArea)

Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200OK                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para validar se  regra j� existe no cadastro                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! M�rcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200OK()    
Local cFilZ30:=xFilial("Z30")    
Local aRetZ30:=GetArea()

	// -> Valida se j� existe regra cadastrada para produtos e/ou usuarios
    If Inclui .or. Altera    
	    // -> Verifica regra de produto x usu�rio
	    If AllTrim(M->Z30_USUAR) <> "" .and. AllTrim(M->Z30_PROD) <> ""
		    Z30->(DbSetOrder(1)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_PROD+M->Z30_USUAR+M->Z30_ID))                                                   
	    		RestArea(aRetZ30)
	    		ApMsgInfo("J� existe regra cadastrada para o produto, usu�rio e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Valida��o do cadastro")
	    	    Return(.F.)
    		EndIf    
    	EndIf	

	    // -> Verifica regra de grupo de produto x grupo de usu�rio
	    If AllTrim(M->Z30_GRUSU) <> "" .and. AllTrim(M->Z30_GRPPRO) <> ""
		    Z30->(DbSetOrder(2)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_GRPPRO+M->Z30_GRUSU+M->Z30_ID))                                                   
	    		RestArea(aRetZ30)
	    		ApMsgInfo("J� existe regra cadastrada para o grupo de produto, grupo de usu�rio e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Valida��o do cadastro")
	    	    Return(.F.)
    		EndIf                      
    	EndIf	

	    // -> Verifica regra de produto x grupo de usu�rio
	    If AllTrim(M->Z30_GRUSU) <> "" .and. AllTrim(M->Z30_PROD) <> ""	    
		    Z30->(DbSetOrder(3)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_PROD+M->Z30_GRUSU+M->Z30_ID))                                                   
    		    RestArea(aRetZ30)
	    		ApMsgInfo("J� existe regra cadastrada para o produto, grupo de usu�rio e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Valida��o do cadastro")
	    	    Return(.F.)                  
    		EndIf    
    	EndIf
    	    
	    // -> Verifica regra de grupo de produto x usu�rio
	    If AllTrim(M->Z30_USUAR) <> "" .and. AllTrim(M->Z30_GRPPRO) <> ""
	    	Z30->(DbSetOrder(4)) 
	    	If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_GRPPRO+M->Z30_USUAR+M->Z30_ID))                                                   
    		   RestArea(aRetZ30)
	    		ApMsgInfo("J� existe regra cadastrada para o grupo do produto, usu�rio e ID"+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Valida��o do cadastro")
    	    	Return(.F.)
	    	EndIf    
    	EndIf	

		// -> Verifica se os campos obrigat�rios foram preenchidos - Rotina
		If (AllTrim(M->Z30_ROTINA) == "") .or. (AllTrim(M->Z30_ROTINA) <> "MTA240")
			RestArea(aRetZ30)
			ApMsgInfo("Rotina inv�lida."+Chr(13)+Chr(10)+"Favor informar na rotina o conte�do 'MTA4240'.","[EXISTREGRA] - Valida��o do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigat�rios foram preenchidos - Produto e grupo de produto
		If AllTrim(M->Z30_PROD) == "" .and. AllTrim(M->Z30_GRPPRO) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Dados do produto inv�lidos."+Chr(13)+Chr(10)+"Favor informar o c�digo ou o grupo do produtono cadastro.","[EXISTREGRA] - Valida��o do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigat�rios foram preenchidos - Usu�rio e grupo de usuario
		If AllTrim(M->Z30_USUAR) == "" .and. AllTrim(M->Z30_GRUSU) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Dados do usu�rio inv�lidos."+Chr(13)+Chr(10)+"Favor informar o c�digo ou o grupo do usu�rio cadastro.","[EXISTREGRA] - Valida��o do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigat�rios foram preenchidos - ID
		If AllTrim(M->Z30_ID) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Tipo de movimenta��o inv�lida."+Chr(13)+Chr(10)+"Favor informar um c�digo de movimenta��o no cadastro.","[EXISTREGRA] - Valida��o do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos de usu�rio e/ou grupo estao preenchidos para exce��es
		If AllTrim(M->Z30_REGRA) == "E" .and. (AllTrim(M->Z30_USUAR) == "*" .or. AllTrim(M->Z30_GRUSU) == "*") 
			RestArea(aRetZ30)
			ApMsgInfo("Usu�rio e/ou Grupo de Usu�rio inv�lido(s)."+Chr(13)+Chr(10)+"N�o � permitido informar 'todos' os usu�rios e/ou grupos de usu�rios para uma exce��o.","[EXISTREGRA] - Valida��o do cadastro")
   			Return(.F.)
		EndIf

		//garante que usu�rio e/ou grupo de usu�rio sejam v�lidos ou apenas '*'
		if ! naoValido(M->Z30_USUAR, .F.) .Or. ! naoValido(M->Z30_GRUSU, .T.)
			return .F.
		endIf

    EndIf	           

    RestArea(aRetZ30)
    
Return(.T.)




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200VL                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para validar a permiss�o do usu�rio para acesso as rotinas, utilizando !
!                  ! as regras cadastradas na tabela Z30                                           !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! M�rcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200VL(lID,lPE)
Local aAreaVLD := GetArea()
Local nx       := 0 
Local nD3COD   := 0 
Local lRet     := .F.
Local cProdA   := " "
Local cxGrupoA := " "
Local cUserA   := RetCodUsr()
Local aGrpUser := UsrRetGrp(cUserName)
Local cIDA     := "" 
Local cRotina  := ""         
Default lID    := .F.
Default lPE    := .F.

	// -> Verifica se o grupo est� vazio e, se tiver habilita todos
	If Len(aGrpUser) <= 0
		aadd(aGrpUser,"*")
	EndIf	

    // -> Verifica se � unidade de neg�cio
	If !u_IsBusiness()  
	    RestArea(aAreaVLD)                   
		Return(.T.)
	Endif

	// -> Verifica se o usu�rio � administrador
	If !cUserA == "000000" .And. !FunName() == 'MATA242'
		// -> Valida��o para rotina MATA140 e MATA141
    	If SubStr(AllTrim(FunName()),1,6) $ "MATA24" 
    	   cRotina := "MTA240"
    	   cRotina := cRotina + Space(TamSX3("Z30_ROTINA")[1]-Len(cRotina))
		   // -> Valida��o para Movimento interno - Simples  
		   If AllTrim(FunName()) == "MATA240"
			  // -> Psociona no produto              
			  SB1->(DbSetOrder(1))
			  SB1->(DbSeek(xFilial("SB1")+M->D3_COD))			  
			  cProdA   := SB1->B1_COD
	          cxGrupoA := SB1->B1_GRUPO
		      cIDA     := M->D3_TM
	    	  lRet     := IIF(lID .and. AllTrim(cProdA) == "",.T.,u_EST200RL(cRotina,cProdA,cxGrupoA,cUserA,aGrpUser,cIDA,lID))	      
		   EndIf 
	   
		   // -> Valida��o para Movimento interno - Multiplo  
		   If AllTrim(FunName()) == "MATA241"
		      nD3COD:=GDFieldPos("D3_COD")
	    	  cIDA  :=cTM
		      // -> Valida apenas o produto no aCols em rela��o ao ID
	    	  If !lID
		      	 // -> Psociona no produto             
			     SB1->(DbSetOrder(1))
			     SB1->(DbSeek(xFilial("SB1")+IIF(lPE.and.!Empty(aCols[N,nD3COD]),aCols[N,nD3COD],M->D3_COD)))			  
			     cProdA   := SB1->B1_COD
	             cxGrupoA := SB1->B1_GRUPO
		         lRet    :=u_EST200RL(cRotina,cProdA,cxGrupoA,cUserA,aGrpUser,cIDA)	      
	    	  EndIf 
	      
		      // -> Valida apenas o ID e todos os produtos j� inclu�dos no aCols
		      If lID
	    	     For nx:=1 to Len(aCols)     
	  		         // -> Psociona no produto              
			         If AllTrim(IIF(!Empty(aCols[nx,nD3COD]),aCols[nx,nD3COD],M->D3_COD)) <> "" .and. !aCols[nx][Len(aCols[nx])]
				         SB1->(DbSetOrder(1))			         
				         SB1->(DbSeek(xFilial("SB1")+IIF(!Empty(aCols[nx,nD3COD]),aCols[nx,nD3COD],M->D3_COD)))			  
				         cProdA   := SB1->B1_COD
	        	         cxGrupoA := SB1->B1_GRUPO
		        	     lRet    :=u_EST200RL(cRotina,cProdA,cxGrupoA,cUserA,aGrpUser,cIDA,lID)	      
	    	        	 If !lRet
	        	            Exit
		            	 EndIf   
		             Else
		             	 lRet := .T.    
		             EndIf	 
		         Next nx    	         
		      EndIf 
		   EndIf	
    	Else
    	   lRet:=.T.
    	EndIf
     Else
    	lRet:=.T.
    EndIf	 
    
    RestArea(aAreaVLD)
    
    If !lRet
	   ApMsgInfo("Produto bloqueao para o tipo de movimenta��o selecionado."+Chr(13)+Chr(10)+"Favor solicitar libera��o de regra de movimenta��es.","[NOACCESS] - Valida��o do acesso")    
    EndIf

Return(lRet)






/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200RL                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para validar as regras para os produtos conforme usu�rios e opera��es  !
!                  ! cadastradas na tabela Z30                                                     !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! M�rcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200RL(cRot,cxProd,cxGrupoP,cxUser,axGrupoU,cxID,lxID)
Local lAcesso  := .F.
Local nx       := 0      
Local lRegraOK := .F.
Default lxID   :=.F.

    // -> Verifica se � unidade de neg�cio
	If !u_IsBusiness()  
		Return(.T.)
	Endif

	// -> Analisa a regras por produto
	Z30->(DbSetOrder(1))
	Z30->(DbSeek(xFilial("Z30")+cRot+cxProd))   
	While !Z30->(Eof()) .and. Z30->Z30_FILIAL == xFilial("Z30") .and. Z30->Z30_ROTINA == cRot .and. Z30->Z30_PROD == cxProd .and. AllTrim(cxProd) <> ""
   	      // -> Verifica se a regra atende as condi��es do usu�rio e ID
	      If AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(cxUser) <> ""
	         If ( AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser) ) .and. ( AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID) )     
	            lRegraOK := .T.
	            // -> Analisa regra
	            If Z30->Z30_REGRA == "R"
  	               lAcesso := .T.
	            EndIf                 
	            // -> Analisa exce��o
	            If Z30->Z30_REGRA == "E"
  	               lAcesso := .F.
	            EndIf                 	            			   
	         ElseIf Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_USUAR) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
	         	lAcesso := .T.
	         EndIf                 	
	   EndIf   
	   // -> Verifica se a regra atende as condi��es do grupo de usu�rio e ID
	   If AllTrim(Z30->Z30_GRUSU) <> ""
	   	     // -> Analiza regra
	   	     For nx:=1 to Len(axGrupoU) 
		         If ( (AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser)) .or. (AllTrim(Z30->Z30_GRUSU) <> "" .and. AllTrim(Z30->Z30_GRUSU) == AllTrim(axGrupoU[nx])) ) .and. (AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID))      
	                lRegraOK := .T.
	                // -> Analisa regra
	                If Z30->Z30_REGRA == "R"
  	                   lAcesso := .T.
  	                   Exit
	                EndIf                 
	                // -> Analisa exce��o
	                If Z30->Z30_REGRA == "E"
  	                   lAcesso := .F.
  	                   Exit
	                EndIf                 	            			   	             
	             Elseif Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_GRUSU) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
			   	     lAcesso := .T.
			   	     Exit
	             EndIf                 	
	         Next nx 
	   EndIf
	   
	   If lRegraOK .and. !lAcesso
	      Return(.F.)
	   EndIf

	   Z30->(DbSkip())
	EndDo
   
	// -> Analisa a regras por grupo de produto
	Z30->(DbSetOrder(2))
	Z30->(DbSeek(xFilial("Z30")+cRot+cxGrupoP))   
	While !Z30->(Eof()) .and. Z30->Z30_FILIAL == xFilial("Z30") .and. Z30->Z30_ROTINA == cRot .AND. Z30->Z30_GRPPRO == cxGrupoP .and. AllTrim(cxGrupoP) <> ""
	      // -> Verifica se a regra atende as condi��es do usu�rio e ID           
	      If AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(cxUser) <> ""
	         If ( AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser) ) .and. ( AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID) )     
	            lRegraOK := .T.
	            // -> Analisa regra
	            If Z30->Z30_REGRA == "R"
  	               lAcesso := .T.
	            EndIf                 
	            // -> Analisa exce��o
	            If Z30->Z30_REGRA == "E"
  	               lAcesso := .F.
	            EndIf                 	            			   
	         ElseIf Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_USUAR) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
			    lAcesso := .T.
	         EndIf
	      EndIf                    	
	   // -> Verifica se a regra atende as condi��es do grupo de usu�rio e ID
	   If AllTrim(Z30->Z30_GRUSU) <> ""
	   	     // -> Analiza regra
	   	     For nx:=1 to Len(axGrupoU) 
	            If ( (AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser)) .or.(AllTrim(Z30->Z30_GRUSU) <> "" .and. AllTrim(Z30->Z30_GRUSU) == AllTrim(axGrupoU[nx])) ) .and. (AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID))     
		           lRegraOK := .T.
	               // -> Analisa regra
	               If Z30->Z30_REGRA == "R"
  	                  lAcesso := .T.
  	                  Exit
	               EndIf                 
	               // -> Analisa exce��o
	               If Z30->Z30_REGRA == "E"
  	                  lAcesso := .F.
  	                  Exit
	               EndIf                 	            			   
	            ElseIf Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_GRUSU) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
	   	           lAcesso := .T.
	   	           Exit	            
	            EndIf                 	
	         Next nx 
	   EndIf

	   If lRegraOK .and. !lAcesso
	       Return(.F.)
	   EndIf

	   Z30->(DbSkip())

	EndDo
Return(lAcesso)                    

/*/{Protheus.doc} naoValido
Valida se o usu�rio/grupo � v�lido
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/09/2020
@param cUsrGrp, character, C�digo do usu�rio ou grupo
@param lGrupo, logical, Indica se � um grupo
@return logical, Indica se o conte�do � v�lido
/*/
static function naoValido(cUsrGrp, lGrupo)

	local nOrder := IIF(lGrupo, 1, 2) //1=Grupo;2=Usu�rio

	//vazio � um valor v�lido
	if Empty(cUsrGrp)
		return .T.
	endIf

	//considerar todos os usu�rios e/ou grupos � v�lido
	if AllTrim(cUsrGrp) == "*"
		return .T.
	endIf

	//verifica se o usu�rio ou grupo � v�lido
	PswOrder(nOrder)
	if ! PswSeek(cUsrGrp, ! lGrupo)
		ApMsgInfo(IIF(lGrupo, "Grupo de ", "") + "Usu�rio inv�lido."+Chr(13)+Chr(10)+"Voc� deve informar '*=todos' ou um " + IIF(lGrupo, "grupo de ", "") + " usu�rios v�lido.","[EXISTREGRA] - Valida��o do cadastro")		
		return .F.
	endIf

return .T.
