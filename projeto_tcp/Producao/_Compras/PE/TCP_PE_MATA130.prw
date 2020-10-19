/*
+----------------------------------------------------------------------------+ 
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_PE_MATA130                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da Rotina de Geração de Cotações      !
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/03/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES   !                                                         !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch" 

/*
+-----------------------------------------------------------------------------+
! Função     ! MTA130MNU    ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto é utilizado para Adicionar mais opções no aRotina   !
+------------+----------------------------------------------------------------+
*/

User Function MTA130MNU()
	
		AAdd( aRotina, { 'GED.TCP', "U_TCPGED", 0, 4 } )

		//Retira o conhecimento do Menu
		nPos := ASCAN(aRotina, { |x|   If(ValType(x[2])=="C",UPPER(x[2]) == "MSDOCUMENT",.F.) })
		If nPos > 0
			Adel(aRotina,nPos)
			Asize(aRotina,Len(aRotina)-1)
		EndIf

Return aRotina

/*----------------+------------------------------------------+---------------+
| Função: MT130WF | Autor: Lucas Chagas                      | Data:15/04/13 |
+-----------+-----+------------------------------------------+---------------+
| Parâmetros|                                                                |
+-----------+----------------------------------------------------------------+
| Descricao | Este ponto de entrada tem o objetivo de permitir a customização|
|           | de workflow baseado nas informações de cotações que estão      |
|           | sendo geradas pela rotina em execução.                         |
+-----------+---------------------------------------------------------------*/
User Function MT130WF()
Local _cNumCot := SC8->C8_NUM 
Local aArea := GetArea()

	integSales(_cNumCot )
	
	RestArea(aArea)
	
	atuNatureza(_cNumCot)
	
	RestArea(aArea)
	
	U_MCOM006( _cNumCot)
	
RestArea(aArea)

Return

User Function MT131WF()

Local aArea := GetArea()
Local _cNumCot := PARAMIXB[1]
	IF(!EMPTY(_cNumCot))
		integSales(_cNumCot)
		RestArea(aArea)
	
		atuNatureza(_cNumCot)
		RestArea(aArea)
	
		U_MCOM006( _cNumCot )
		
	ENDIF
RestArea(aArea)

Return

static function atuNatureza(_cNumCot)

dbSelectArea('SC8')
SC8->( dbSetOrder(1) )
IF SC8->( dbSeek( xFilial("SC8") + _cNumCot ) )
	 
	while !	SC8->(Eof()) .AND. C8_FILIAL == xFilial('SC8') .AND. C8_NUM == _cNumCot
		
		
		dbSelectArea('SC1')
		SC1->( dbSetOrder(1) )
		IF SC1->( dbSeek( SC8->C8_FILIAL+SC8->C8_NUMSC+SC8->C8_ITEMSC ) ) .AND. !EMPTY(SC1->C1_XNATURE) 
			RecLock("SC8",.F.)
			SC8->C8_XNATURE := SC1->C1_XNATURE
			SC8->(msUnlock())
		ENDIF
		SC8->(dbSkip())
	enddo
endif

return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MT130TOK
Função para validação dos campos de fornecedor        

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function MT130TOK
Local lRet   	:= .T.
Local lDelLinha := .F.
Local nPosFornec:= paramixb[1]
Local nPosLoja  := paramixb[2]
Local nI := 1

	For nI := 1 to Len(aCols)    
		If ValType(aCols[nI,Len(aCols[nI])]) == 'L'        
			lDelLinha := aCols[nI,Len(aCols[nI])]      // Se esta Deletado    
		EndIf    
		
		If !lDelLinha        
			If Posicione('SA2',1,xFilial('SF1')+AllTrim(aCols[nI][nPosFornec])+AllTrim(aCols[nI][nPosLoja]),"A2_BLQFOR") == '1'
				Alert('O  Fornecedor '+Alltrim(AllTrim(aCols[nI][nPosFornec]))+' / '+Alltrim(AllTrim(aCols[nI][nPosLoja]))+' está bloqueado devido a baixa classificação!')     
				lRet	:= .F.            
				Exit        
			EndIf    
		EndIf
	Next                     
Return lRet

static function integSales(_cNumCot)

	oCompras  := ClassIntCompras():new()    

	IF oCompras:registraIntegracao('1',xFilial("SC8")+_cNumCot,'I')  
		oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
		ALERT(oCompras:cErro)
	ENDIF  
	
return