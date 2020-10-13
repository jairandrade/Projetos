#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "TOPCONN.CH"

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para cadastrar as regras para produtos usuários e códdigos de movimen- !
!                  ! tações                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
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
		ApMsgInfo("A filial não é uma unidade de negócio. [ADK_XFILI = Vazio ].","[NOBUSINESS] - Validação da unidade de negócio")
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
! Descrição        ! Função para validar se  regra já existe no cadastro                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200OK()    
Local cFilZ30:=xFilial("Z30")    
Local aRetZ30:=GetArea()

	// -> Valida se já existe regra cadastrada para produtos e/ou usuarios
    If Inclui .or. Altera    
	    // -> Verifica regra de produto x usuário
	    If AllTrim(M->Z30_USUAR) <> "" .and. AllTrim(M->Z30_PROD) <> ""
		    Z30->(DbSetOrder(1)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_PROD+M->Z30_USUAR+M->Z30_ID))                                                   
	    		RestArea(aRetZ30)
	    		ApMsgInfo("Já existe regra cadastrada para o produto, usuário e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Validação do cadastro")
	    	    Return(.F.)
    		EndIf    
    	EndIf	

	    // -> Verifica regra de grupo de produto x grupo de usuário
	    If AllTrim(M->Z30_GRUSU) <> "" .and. AllTrim(M->Z30_GRPPRO) <> ""
		    Z30->(DbSetOrder(2)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_GRPPRO+M->Z30_GRUSU+M->Z30_ID))                                                   
	    		RestArea(aRetZ30)
	    		ApMsgInfo("Já existe regra cadastrada para o grupo de produto, grupo de usuário e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Validação do cadastro")
	    	    Return(.F.)
    		EndIf                      
    	EndIf	

	    // -> Verifica regra de produto x grupo de usuário
	    If AllTrim(M->Z30_GRUSU) <> "" .and. AllTrim(M->Z30_PROD) <> ""	    
		    Z30->(DbSetOrder(3)) 
    		If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_PROD+M->Z30_GRUSU+M->Z30_ID))                                                   
    		    RestArea(aRetZ30)
	    		ApMsgInfo("Já existe regra cadastrada para o produto, grupo de usuário e ID."+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Validação do cadastro")
	    	    Return(.F.)                  
    		EndIf    
    	EndIf
    	    
	    // -> Verifica regra de grupo de produto x usuário
	    If AllTrim(M->Z30_USUAR) <> "" .and. AllTrim(M->Z30_GRPPRO) <> ""
	    	Z30->(DbSetOrder(4)) 
	    	If Z30->(DbSeek(cFilZ30+M->Z30_ROTINA+M->Z30_GRPPRO+M->Z30_USUAR+M->Z30_ID))                                                   
    		   RestArea(aRetZ30)
	    		ApMsgInfo("Já existe regra cadastrada para o grupo do produto, usuário e ID"+Chr(13)+Chr(10)+"Para incluir a nova regra, favor excluir a regra atual.","[EXISTREGRA] - Validação do cadastro")
    	    	Return(.F.)
	    	EndIf    
    	EndIf	

		// -> Verifica se os campos obrigatórios foram preenchidos - Rotina
		If (AllTrim(M->Z30_ROTINA) == "") .or. (AllTrim(M->Z30_ROTINA) <> "MTA240")
			RestArea(aRetZ30)
			ApMsgInfo("Rotina inválida."+Chr(13)+Chr(10)+"Favor informar na rotina o conteúdo 'MTA4240'.","[EXISTREGRA] - Validação do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigatórios foram preenchidos - Produto e grupo de produto
		If AllTrim(M->Z30_PROD) == "" .and. AllTrim(M->Z30_GRPPRO) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Dados do produto inválidos."+Chr(13)+Chr(10)+"Favor informar o código ou o grupo do produtono cadastro.","[EXISTREGRA] - Validação do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigatórios foram preenchidos - Usuário e grupo de usuario
		If AllTrim(M->Z30_USUAR) == "" .and. AllTrim(M->Z30_GRUSU) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Dados do usuário inválidos."+Chr(13)+Chr(10)+"Favor informar o código ou o grupo do usuário cadastro.","[EXISTREGRA] - Validação do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos obrigatórios foram preenchidos - ID
		If AllTrim(M->Z30_ID) == ""
			RestArea(aRetZ30)
			ApMsgInfo("Tipo de movimentação inválida."+Chr(13)+Chr(10)+"Favor informar um código de movimentação no cadastro.","[EXISTREGRA] - Validação do cadastro")
   			Return(.F.)
		EndIf

		// -> Verifica se os campos de usuário e/ou grupo estao preenchidos para exceções
		If AllTrim(M->Z30_REGRA) == "E" .and. (AllTrim(M->Z30_USUAR) == "*" .or. AllTrim(M->Z30_GRUSU) == "*") 
			RestArea(aRetZ30)
			ApMsgInfo("Usuário e/ou Grupo de Usuário inválido(s)."+Chr(13)+Chr(10)+"Não é permitido informar 'todos' os usuários e/ou grupos de usuários para uma exceção.","[EXISTREGRA] - Validação do cadastro")
   			Return(.F.)
		EndIf

		//garante que usuário e/ou grupo de usuário sejam válidos ou apenas '*'
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
! Descrição        ! Função para validar a permissão do usuário para acesso as rotinas, utilizando !
!                  ! as regras cadastradas na tabela Z30                                           !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
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

	// -> Verifica se o grupo está vazio e, se tiver habilita todos
	If Len(aGrpUser) <= 0
		aadd(aGrpUser,"*")
	EndIf	

    // -> Verifica se é unidade de negócio
	If !u_IsBusiness()  
	    RestArea(aAreaVLD)                   
		Return(.T.)
	Endif

	// -> Verifica se o usuário é administrador
	If !cUserA == "000000" .And. !FunName() == 'MATA242'
		// -> Validação para rotina MATA140 e MATA141
    	If SubStr(AllTrim(FunName()),1,6) $ "MATA24" 
    	   cRotina := "MTA240"
    	   cRotina := cRotina + Space(TamSX3("Z30_ROTINA")[1]-Len(cRotina))
		   // -> Validação para Movimento interno - Simples  
		   If AllTrim(FunName()) == "MATA240"
			  // -> Psociona no produto              
			  SB1->(DbSetOrder(1))
			  SB1->(DbSeek(xFilial("SB1")+M->D3_COD))			  
			  cProdA   := SB1->B1_COD
	          cxGrupoA := SB1->B1_GRUPO
		      cIDA     := M->D3_TM
	    	  lRet     := IIF(lID .and. AllTrim(cProdA) == "",.T.,u_EST200RL(cRotina,cProdA,cxGrupoA,cUserA,aGrpUser,cIDA,lID))	      
		   EndIf 
	   
		   // -> Validação para Movimento interno - Multiplo  
		   If AllTrim(FunName()) == "MATA241"
		      nD3COD:=GDFieldPos("D3_COD")
	    	  cIDA  :=cTM
		      // -> Valida apenas o produto no aCols em relação ao ID
	    	  If !lID
		      	 // -> Psociona no produto             
			     SB1->(DbSetOrder(1))
			     SB1->(DbSeek(xFilial("SB1")+IIF(lPE.and.!Empty(aCols[N,nD3COD]),aCols[N,nD3COD],M->D3_COD)))			  
			     cProdA   := SB1->B1_COD
	             cxGrupoA := SB1->B1_GRUPO
		         lRet    :=u_EST200RL(cRotina,cProdA,cxGrupoA,cUserA,aGrpUser,cIDA)	      
	    	  EndIf 
	      
		      // -> Valida apenas o ID e todos os produtos já incluídos no aCols
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
	   ApMsgInfo("Produto bloqueao para o tipo de movimentação selecionado."+Chr(13)+Chr(10)+"Favor solicitar liberação de regra de movimentações.","[NOACCESS] - Validação do acesso")    
    EndIf

Return(lRet)






/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST200RL                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar as regras para os produtos conforme usuários e operações  !
!                  ! cadastradas na tabela Z30                                                     !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function EST200RL(cRot,cxProd,cxGrupoP,cxUser,axGrupoU,cxID,lxID)
Local lAcesso  := .F.
Local nx       := 0      
Local lRegraOK := .F.
Default lxID   :=.F.

    // -> Verifica se é unidade de negócio
	If !u_IsBusiness()  
		Return(.T.)
	Endif

	// -> Analisa a regras por produto
	Z30->(DbSetOrder(1))
	Z30->(DbSeek(xFilial("Z30")+cRot+cxProd))   
	While !Z30->(Eof()) .and. Z30->Z30_FILIAL == xFilial("Z30") .and. Z30->Z30_ROTINA == cRot .and. Z30->Z30_PROD == cxProd .and. AllTrim(cxProd) <> ""
   	      // -> Verifica se a regra atende as condições do usuário e ID
	      If AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(cxUser) <> ""
	         If ( AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser) ) .and. ( AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID) )     
	            lRegraOK := .T.
	            // -> Analisa regra
	            If Z30->Z30_REGRA == "R"
  	               lAcesso := .T.
	            EndIf                 
	            // -> Analisa exceção
	            If Z30->Z30_REGRA == "E"
  	               lAcesso := .F.
	            EndIf                 	            			   
	         ElseIf Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_USUAR) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
	         	lAcesso := .T.
	         EndIf                 	
	   EndIf   
	   // -> Verifica se a regra atende as condições do grupo de usuário e ID
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
	                // -> Analisa exceção
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
	      // -> Verifica se a regra atende as condições do usuário e ID           
	      If AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(cxUser) <> ""
	         If ( AllTrim(Z30->Z30_USUAR) <> "" .and. AllTrim(Z30->Z30_USUAR) == AllTrim(cxUser) ) .and. ( AllTrim(Z30->Z30_ID) <> "" .and. AllTrim(Z30->Z30_ID) == AllTrim(cxID) )     
	            lRegraOK := .T.
	            // -> Analisa regra
	            If Z30->Z30_REGRA == "R"
  	               lAcesso := .T.
	            EndIf                 
	            // -> Analisa exceção
	            If Z30->Z30_REGRA == "E"
  	               lAcesso := .F.
	            EndIf                 	            			   
	         ElseIf Z30->Z30_REGRA == "R" .and. AllTrim(Z30->Z30_USUAR) == "*" .and.  AllTrim(Z30->Z30_ID) == AllTrim(cxID) 
			    lAcesso := .T.
	         EndIf
	      EndIf                    	
	   // -> Verifica se a regra atende as condições do grupo de usuário e ID
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
	               // -> Analisa exceção
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
Valida se o usuário/grupo é válido
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/09/2020
@param cUsrGrp, character, Código do usuário ou grupo
@param lGrupo, logical, Indica se é um grupo
@return logical, Indica se o conteúdo é válido
/*/
static function naoValido(cUsrGrp, lGrupo)

	local nOrder := IIF(lGrupo, 1, 2) //1=Grupo;2=Usuário

	//vazio é um valor válido
	if Empty(cUsrGrp)
		return .T.
	endIf

	//considerar todos os usuários e/ou grupos é válido
	if AllTrim(cUsrGrp) == "*"
		return .T.
	endIf

	//verifica se o usuário ou grupo é válido
	PswOrder(nOrder)
	if ! PswSeek(cUsrGrp, ! lGrupo)
		ApMsgInfo(IIF(lGrupo, "Grupo de ", "") + "Usuário inválido."+Chr(13)+Chr(10)+"Você deve informar '*=todos' ou um " + IIF(lGrupo, "grupo de ", "") + " usuários válido.","[EXISTREGRA] - Validação do cadastro")		
		return .F.
	endIf

return .T.
