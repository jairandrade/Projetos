/*---------------------------------------------------------------------------+
!                             FICHA TÃ‰CNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Classe			                              			 !
+------------------+---------------------------------------------------------+
!MÃ³dulo            ! GenÃ©rico             		                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe para gerenciar Geração, Gravação e Exibição de   !
!	 		       ! Logs													 !
+------------------+---------------------------------------------------------+
!Nome              ! ClassIntManusis	                                             !
+------------------+---------------------------------------------------------+
!ParÃ¢metros        ! 												  		 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 01/11/2018										 !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo Vieira		                                     !
+------------------+--------------------------------------------------------*/
#Include "TOTVS.CH"
#Include "TOPCONN.CH"


/*/{Protheus.doc} ClassIntManusis
Classe para gerenciamento de Geração, Gravação e Exibição de Logs
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@type class
/*/
Class ClassIntManusis
	
	Data lDataHora
	Data cFilZze	 
	Data cCodigo  	 
	Data cChave                    
	Data cTipo	                    
	Data cStatus                   
	Data cErro                     
	Data cEntidade                 
	Data cOperacao                 
	Data cRotina                   
	Data cErroValid                
	Data cChaveZZE                
	Data nIdInteg                
	Data cSqlInsert            
	Data cCodigoEnt            
	Data cDescrEnt
	Data cChaveExc
	Data dDataDe
	Data dDataAte
	Data cErroCmp
	Data cStatOp
	Data cTxtStat
	Data nQtdBaixa
	
	Method newIntManusis() constructor
	Method gravaLog()
	Method setDataHora()
	Method validaLog()    
	Method GRAVACENTROCUSTO()
	Method INTEGRAMANUSIS()      
	Method atuZZE()
	Method trataCodigo()  
	Method buscaCodInt()  
	Method preencheCpos()
	Method retInsert()
	Method gravaIntegracao()
	Method atualizaHistorico()
	Method trataTxt()
	Method enviaMailEstoque()
	
EndClass
 

/*/{Protheus.doc} newLog
MÃ©todo construtor da Classe. Inicializa principais variÃ¡veis com valores padrÃµes.
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@return Self
@type function
/*/
Method newIntManusis() Class ClassIntManusis  
	
	::lDataHora					:= .F.
	::cFilZze                   := ''
	::cChave                    := ''
	::cTipo	                    := ''
	::cStatus                   := ''
	::cErro                     := ''
	::cEntidade                 := ''
	::cOperacao                 := ''
	::cRotina                   := ''
	::cErroValid                := ''
	::nIdInteg 					:= 0
	::cSqlInsert				:= ''
	::cCodigoEnt				:= ''            
	::cDescrEnt			    	:= ''
	::cChaveExc					:= ''
	::cChaveZZE					:= ''
	::cErroCmp					:= ''
	::dDataDe					:= CTOD('  /  /    ')
	::dDataAte					:= CTOD('  /  /    ')
	::cStatOp					:= ' '
	::cTxtStat					:=space(500)
	::nQtdBaixa					:= 0
Return Self




/*/{Protheus.doc} setDataHora
Define se deve Acrescentar Data e Hora no Log Console
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param lDtHora, logical, Define se deve acrescentar Data e Hora no //Conout(Console) - Default .F.
@type function
/*/
Method setDataHora(lDtHora) Class ClassIntManusis

	Default lDtHora := .F.
	
	::lDataHora := lDtHora
Return


/*/{Protheus.doc} gravaLog
Grava registro de log de integração. ZZE
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method gravaLog() Class ClassIntManusis
	
	Local lRet := .T.
	
	dbSelectArea('ZZE')
	
	IF ::validaLog()
	
		cCodigo := GETSX8NUM("ZZE","ZZE_CODIGO")
		//Valida se o código está sendo usado.
		dbSelectArea('ZZE')
		ZZE->( dbSetOrder(1) )
		IF ZZE->( dbSeek( xFilial("ZZE") + cCodigo ) )
			//Enquanto encontrar código, pega um novo. Até q encontre 1 q não existe
			while ZZE->( dbSeek( xFilial("ZZE") + cCodigo ) )
				cCodigo := GETSX8NUM("ZZE","ZZE_CODIGO")
			enddo
		endif
		
		RecLock("ZZE",.T.)
	
		ZZE->ZZE_FILIAL :=  xFilial('ZZE')
		ZZE->ZZE_CODIGO :=  cCodigo
		ZZE->ZZE_TIPO   :=  ::cTipo
		ZZE->ZZE_STATUS :=  ::cStatus
		ZZE->ZZE_CHAVE  :=  ::cChave
		ZZE->ZZE_ENTIDA :=  ::cEntidade
		ZZE->ZZE_OPER   :=  ::cOperacao
		ZZE->ZZE_ROTINA :=  ::cRotina
		ZZE->ZZE_DTINC  :=  DATE()
		ZZE->ZZE_HRINC  :=  TIME()
	    ZZE->ZZE_USUARI :=  __CUSERID
		ZZE->ZZE_STATOP :=  ::cStatOp	
	    ZZE->ZZE_TXTSTA :=  ::cTxtStat	
		ZZE->ZZE_QTDBX  :=  ::nQtdBaixa
		
		ZZE->ZZE_ERRO   :=  ::cErroValid
		ZZE->ZZE_ERROCM :=  ::cErroCmp
		
		ZZE->(msUnlock())
		ConfirmSX8()
		
		::cChaveZZE := ZZE->ZZE_FILIAL+ZZE->ZZE_CODIGO
		
	ELSE
		lRet := .F.
	END
	
	
Return lRet


/*/{Protheus.doc} validaLog
Valida todos os campos, para permitir ou não a inclusão do Log de integração.
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method validaLog() Class ClassIntManusis
	Local lRet := .T.
	
	::cErroValid := ''
	
	IF EMPTY(::cChave )
		::cErroValid += 'Chave VAZIA.'	
	ENDIF
	
	IF EMPTY(::cTipo )
		::cErroValid += 'Tipo VAZIO.'	
	ENDIF
	
	IF EMPTY(::cStatus )
		::cErroValid += 'Status VAZIO.'	
	ENDIF
	
	IF EMPTY(::cEntidade )
		::cErroValid += 'Entidade VAZIA.'	
	ENDIF
	
	IF EMPTY(::cOperacao )
		::cErroValid += 'Operação VAZIA.'	
	ENDIF

	IF !EMPTY(::cErroValid)
		lRet := .F.
	ENDIF
	
Return lRet

/*/{Protheus.doc} INTEGRAMANUSIS
Gerencia a integração, e faz a gravação na tabela de integração
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method INTEGRAMANUSIS(cChaveInt) Class ClassIntManusis
	
	Local lRet := .T.
	
	::cStatus := 'P' 
	
	IF EMPTY(cChaveInt)
		::cErroValid := 'Chave de integração vazia.'
		RETURN .F.
	ENDIF
	
	::cChaveZZE := cChaveInt
	BEGIN TRANSACTION
	dbSelectArea('ZZE')
	ZZE->(DbsetOrder(1))
	IF ZZE->(DBSeek(::cChaveZZE ))    
	
		::preencheCpos(ZZE->(RECNO()))  
				
		if ::buscaCodInt()
				
			if( ::retInsert())
				if ::gravaIntegracao()
					::cStatus    := 'E'
				ELSE
					::cStatus    := 'R'
				endif
			endif
		else
			 ::cErroValid := 'Não foi possível buscar o código da integração'
			 ::cStatus    := 'R'
			 lRet := .F.
		endif
		::atuZZE()
	ELSE
		::cStatus := 'R'
		::cErroValid := 'Não foi encontrado o registro de integração (ZZE). Chave: '+::cChaveZZE
	ENDIF          
	
	END TRANSACTION
	
Return lRet

/*/{Protheus.doc} atuZZE
ATUALIZA DADOS DA ZZE
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method atuZZE() Class ClassIntManusis
	
	Local lRet := .T.
	
	dbSelectArea('ZZE')
	ZZE->( dbSetOrder(1) )
	IF ZZE->( dbSeek( ::cChaveZZE ) )
		RecLock("ZZE",.F.)
		
			ZZE->ZZE_ERRO   :=  ::cErroValid
			ZZE->ZZE_ERROCM :=  ::cErroCmp
			ZZE->ZZE_STATUS :=  ::cStatus
			if !empty(::cSqlInsert)
				ZZE->ZZE_SQLINS :=  ::cSqlInsert
			endif
			ZZE->ZZE_DTALT  :=  DATE()
			ZZE->ZZE_HRALT  :=  TIME()
			IF(!EMPTY(	::nIdInteg))
				ZZE->ZZE_IDINT  :=  ::nIdInteg
			ENDIF
		
		ZZE->(msUnlock())
	ENDIF
Return lRet       

/*/{Protheus.doc} buscaCodInt
Busca código inserido na integração
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method buscaCodInt() Class ClassIntManusis
	local lRet := .f.
	cSQL := "exec registrarIntegracaoManutencao '"+::cChaveZZE+"', '"+IF(ZZE->ZZE_OPER=='E','D','A')+"';"
                                               
	TCQUERY cSQL NEW Alias (cAlias:=GetNextAlias())
	dbselectarea(cAlias)
	(cAlias)->(dbGoTop())
	If (cAlias)->(!Eof()) .AND. (cAlias)->IdIntegracao  > 0        
		::nIdInteg := (cAlias)->IdIntegracao   
		lRet := .T.
	endif
	(cAlias)->(dbCloseArea())
Return lRet


/*/{Protheus.doc} trataCodigo
Trata o jeito de inserir o código na tabela de integração
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param 
@type function
/*/
Method trataCodigo(cValor) Class ClassIntManusis

	IF EMPTY(cValor)
		cValor := NIL
	ENDIF

return cValor  
      
/*/{Protheus.doc} preencheCpos
Trata o jeito de inserir o código na tabela de integração
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@param nRecno - Recno da ZZE
@type function
/*/
Method preencheCpos(nRecno) Class ClassIntManusis
	    
	dbSelectArea('ZZE')
	ZZE->(DBGoTo(nRecno))    

	::cFilZze 	:= ZZE->ZZE_FILIAL 
	::cCodigo	:= ZZE->ZZE_CODIGO 
	::cTipo		:= ZZE->ZZE_TIPO   
	::cStatus	:= ZZE->ZZE_STATUS 
	::cChave	:= ZZE->ZZE_CHAVE  
	::cEntidade	:= ZZE->ZZE_ENTIDA 
	::cOperacao	:= ZZE->ZZE_OPER   
	::cRotina	:= ZZE->ZZE_ROTINA 
	::cChaveExc	:= ALLTRIM(substr(ZZE->ZZE_CHAVE,3,LEN(ZZE->ZZE_CHAVE)))
	::cStatOp   := ZZE->ZZE_STATOP
	::cTxtStat  := ZZE->ZZE_TXTSTA
	::nQtdBaixa := ZZE->ZZE_QTDBX
	    
return


/*/{Protheus.doc} retInsert
Monta a SQL de insert na tabela de integração
@author Eduardo vieira
@since 12/11/2018
@version 1.0
@param 
@type function
/*/
Method retInsert() Class ClassIntManusis
	Local lRet 		  := .T.
	Local _cSup       := ''
	Local _cDescComp  := ''
	Local _cAplicacao := ''
	
	DO CASE
	  CASE ZZE->ZZE_ENTIDA =='CTT'
			dbSelectArea('CTT')
			DbsetOrder(1)
			IF CTT->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO CENTROCUSTOINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ CTT->CTT_CUSTO +"', '"+ ::trataTxt( ALLTRIM(CTT->CTT_DESC01)) +"' "
			    ::cSqlInsert += IF(!EMPTY(ALLTRIM(CTT->CTT_CCSUP)), ",'"+ CTT->CTT_CCSUP +"'); ",",NULL); ")
			
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO CENTROCUSTOINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ' "
			    ::cSqlInsert += ",NULL); "
			ELSE	
				::cErroValid := 'Centro de custo inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  CASE ZZE->ZZE_ENTIDA =='CT1'
		 dbSelectArea('CT1')
			DbsetOrder(1)
			IF CT1->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO CONTACONTABILINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ CT1->CT1_CONTA +"', '"+ ALLTRIM(CT1->CT1_CONTA) +'-'+ ::trataTxt( ALLTRIM(CT1->CT1_DESC01)) +"' "
			    ::cSqlInsert += IF(!EMPTY(CT1->CT1_CTASUP), ",'"+ CT1->CT1_CTASUP +"'); ",",NULL); ")
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO CONTACONTABILINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ,NULL);"
			ELSE		
				::cErroValid := 'Conta Contábil inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  CASE ZZE->ZZE_ENTIDA =='CTD'
		 dbSelectArea('CTD')
			DbsetOrder(1)
			IF CTD->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO ITEMCONTAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ CTD->CTD_ITEM +"', '"+ ALLTRIM(CTD->CTD_ITEM)+'-'+::trataTxt(ALLTRIM(CTD->CTD_DESC01)) +"' ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO ITEMCONTAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ); "
			ELSE		
				::cErroValid := 'Item Contábil inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF    
	  CASE ZZE->ZZE_ENTIDA =='SB1'
		 	dbSelectArea('SB1')
			DbsetOrder(1)
			IF SB1->(DBSeek(::cChave))  
				
			 	dbSelectArea('SB5')
				DbsetOrder(1)
				IF SB5->(DBSeek(xFilial('SB5')+SB1->B1_COD))  
					_cDescComp  := SUBSTR(SB5->B5_DCOMPR,1,255)
					_cAplicacao := SB5->B5_APLESP
					
					IF EMPTY(_cDescComp)
						_cDescComp  := SUBSTR(SB5->B5_CEME,1,255)
					ENDIF
					
				endif			
				
				if empty(_cDescComp)
					_cDescComp := SB1->B1_DESC
				endif
				
				::cSqlInsert := "INSERT  INTO MATERIALINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoFamiliaMaterial,DescricaoComplementar,AplicacaoEspecifica,CodigoBarras,CodigoUnidadeMedida) "
				//::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SB1->B1_COD +"', '"+ ::trataTxt(ALLTRIM(SB1->B1_DESC)) +"', '"+ ALLTRIM(SB1->B1_GRUPO) +"', '"+ ::trataTxt(ALLTRIM(_cDescComp)) +"' " 
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SB1->B1_COD +"', '"+ ::trataTxt(ALLTRIM(_cDescComp)) +"', '"+ ALLTRIM(SB1->B1_GRUPO) +"', '"+ ::trataTxt(ALLTRIM(SB1->B1_DESC)) +"' " 
				::cSqlInsert += ", '"+ ::trataTxt(ALLTRIM(_cAplicacao)) +"', '"+ ALLTRIM(SB1->B1_COD) +"', '"+ ALLTRIM(SB1->B1_UM) +"' );  "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO MATERIALINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoFamiliaMaterial,DescricaoComplementar,AplicacaoEspecifica,CodigoBarras,CodigoUnidadeMedida) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ', ' ', ' ', ' ', ' ', ' ' );  " 
					
			ELSE	
				::cErroValid := 'Produto inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF 
	  CASE ZZE->ZZE_ENTIDA =='SAH'
		 dbSelectArea('SAH')
			DbsetOrder(1)
			IF SAH->(DBSeek(::cChave))   
							
				::cSqlInsert := "INSERT  INTO UNIDADEMEDIDAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SAH->AH_UNIMED +"', '"+ SAH->AH_UNIMED + '-'+IF(!EMPTY(ALLTRIM(SAH->AH_DESCPO)),::trataTxt(ALLTRIM(SAH->AH_DESCPO)),::trataTxt(ALLTRIM(SAH->AH_UMRES))) +"' ); "
			        
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO UNIDADEMEDIDAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ); "	
			ELSE	
				::cErroValid := 'Unidade de medida inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  CASE ZZE->ZZE_ENTIDA =='SBM'
		 	dbSelectArea('SBM')
			DbsetOrder(1)
			IF SBM->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO FAMILIAMATERIALINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SBM->BM_GRUPO +"', '"+ ::trataTxt(ALLTRIM(SBM->BM_DESC)) +"' ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO FAMILIAMATERIALINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ' ); "
			ELSE		
				::cErroValid := 'Grupo de Produto inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF    
	  CASE ZZE->ZZE_ENTIDA =='SR6'
		 	dbSelectArea('SR6')
			DbsetOrder(1)
			IF !EMPTY(::cCodigoEnt) .AND. !EMPTY(::cDescrEnt)
				::cSqlInsert := "INSERT  INTO TURNOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cCodigoEnt +"', '"+ SR6->R6_TURNO + ::trataTxt(ALLTRIM(::cDescrEnt)) +"' ); "
				
			ELSEIF SR6->(DBSeek(::cChave))  
			         
				::cSqlInsert := "INSERT  INTO TURNOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SR6->R6_TURNO +"', '"+ SR6->R6_TURNO + ::trataTxt(ALLTRIM(SR6->R6_DESC)) +"' ); "
			   	
			ELSEIF ZZE->ZZE_OPER == 'E'	
			 	::cSqlInsert := "INSERT  INTO TURNOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ); "
			   
			ELSE	
				::cErroValid := 'Turno inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF   
	  CASE ZZE->ZZE_ENTIDA =='RCM'
		 	dbSelectArea('RCM')
			DbsetOrder(1)
			IF RCM->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO RAZAOAUSENCIAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ RCM->RCM_TIPO +"', '"+ ::trataTxt(ALLTRIM(RCM->RCM_DESCRI)) +"' ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO RAZAOAUSENCIAINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ); "
			   
			ELSE	
				::cErroValid := 'Razao de ausencia inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF    
	  CASE ZZE->ZZE_ENTIDA =='SR8'
		 	dbSelectArea('SR8')
			DbsetOrder(5)
			IF SR8->(DBSeek(::cChave)) 
							
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SR8->R8_NUMID +"' , '"+ SR8->R8_MAT +"', '"+ SR8->R8_TIPOAFA +"', CONVERT(DATETIME,'"+ DTOS(SR8->R8_DATAINI) +"',112) "
				::cSqlInsert += IF (EMPTY(SR8->R8_DATAFIM)," , CONVERT(DATETIME,'"+ DTOS(YearSum( DATE() , 5 )) +"',112)   ", " , CONVERT(DATETIME,'"+ DTOS(SR8->R8_DATAFIM) +"',112)   ")
				::cSqlInsert += ")"
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ', ' ', NULL , NULL);"
			ELSE		
				::cErroValid := 'Ausencia inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='SRH'
		 	dbSelectArea('SRH')
			DbsetOrder(1)
			IF SRH->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ALLTRIM(::cChave) +"' , '"+ SRH->RH_MAT +"', '001', CONVERT(DATETIME,'"+ DTOS(SRH->RH_DATAINI) +"',112) "
				::cSqlInsert += IF (EMPTY(SRH->RH_DATAFIM),',NULL', " , CONVERT(DATETIME,'"+ DTOS(SRH->RH_DATAFIM) +"',112)   ")
				::cSqlInsert += ")"
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ', ' ', NULL , NULL);"
			ELSE		
				::cErroValid := 'Ausencia inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='SRF'
		 	dbSelectArea('SRF')
			DbsetOrder(1)
			IF SRF->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ALLTRIM(::cChave) +"' , '"+ SRF->RF_MAT +"', '001', CONVERT(DATETIME,'"+ DTOS(SRF->RF_DATAINI) +"',112) "
				::cSqlInsert += IF (SRF->RF_DFEPRO1 <= 0,',NULL', " , CONVERT(DATETIME,'"+ DTOS( DaySum( SRF->RF_DATAINI , SRF->RF_DFEPRO1 )) +"',112)   ")
				::cSqlInsert += ")"
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO AUSENCIAINTEGRACAO (IdIntegracao,Codigo,Matricula,CodigoRazaoAusencia,DataInicio,DataFim) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ', ' ', NULL , NULL);"
			ELSE		
				::cErroValid := 'Ausencia inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='SA2'
		 	dbSelectArea('SA2')
			DbsetOrder(1)
			IF SA2->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO FORNECEDORINTEGRACAO (IdIntegracao,Codigo,RazaoSocial,NomeFantasia,CNPJ,InscricaoEstadual,Email"  
				::cSqlInsert += " ,DDD_Telefone,Site,Endereco,CodigoMunicipio,CEP,Ativo) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SA2->A2_COD+SA2->A2_LOJA +"', '"+ ::trataTxt(ALLTRIM(SA2->A2_NOME)) +"', '"+ ::trataTxt(ALLTRIM(SA2->A2_NREDUZ)) +"' "
				::cSqlInsert += ", '"+ ALLTRIM(SA2->A2_CGC) +"', '"+ ALLTRIM(SA2->A2_INSCR) +"', '"+ ::trataTxt(ALLTRIM(SA2->A2_EMAIL)) +"', '"+ ALLTRIM(SA2->A2_DDI + SA2->A2_DDD + SA2->A2_TEL) +"' "
				::cSqlInsert += ", '"+ ::trataTxt(ALLTRIM(SA2->A2_HPAGE)) +"', '"+ ::trataTxt(ALLTRIM(SA2->A2_END)) +"', '"+ ALLTRIM(SA2->A2_COD_MUN) +"', '"+ ALLTRIM(SA2->A2_CEP) +"' , "+ IF(SA2->A2_MSBLQL =='1','0','1' ) +" ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO FORNECEDORINTEGRACAO (IdIntegracao,Codigo,RazaoSocial,NomeFantasia,CNPJ,InscricaoEstadual,Email"  
				::cSqlInsert += " ,DDD_Telefone,Site,Endereco,CodigoMunicipio,CEP,Ativo) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ', ' ', ' ', ' ', ' ', ' ' , ' ', ' ', ' ', ' ' , ' ' );  "
			   
			ELSE		
				::cErroValid := 'Fornecedor inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='SRA'
		 	dbSelectArea('SRA')
			DbsetOrder(1)
			IF SRA->(DBSeek(RTRIM(::cChave)))  
							
				::cSqlInsert := "INSERT  INTO FUNCIONARIOINTEGRACAO (IdIntegracao,Matricula,NomeCompleto,CodigoTurno,DataAdmissao,DataDemissao,CodigoCentroCusto"  
				::cSqlInsert += " ,Email, DDD_Telefone,CPF,ValorHora,CodigoFuncao,RG,DataNascimento,EnderecoCompleto,CEP,Bairro, Ativo) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SRA->RA_MAT +"', "
				::cSqlInsert += "'"+::trataTxt( ALLTRIM(IF(!EMPTY(ALLTRIM(SRA->RA_NOMECMP)),SRA->RA_NOMECMP,SRA->RA_NOME)) )+"', '"+ ALLTRIM(SRA->RA_TNOTRAB) +"' "
				::cSqlInsert += ", CONVERT(DATETIME,'"+ DTOS(SRA->RA_ADMISSA) +"',112) "
				::cSqlInsert += IF (EMPTY(SRA->RA_DEMISSA),',NULL', " , CONVERT(DATETIME,'"+ DTOS(SRA->RA_DEMISSA) +"',112)   ")
				::cSqlInsert +=	", '"+ ALLTRIM(SRA->RA_CC)+"','"+ ALLTRIM(SRA->RA_EMAIL) +"', '"+ ALLTRIM(SRA->RA_DDDCELU + SRA->RA_NUMCELU)+"' "	
				::cSqlInsert += ", '"+ ALLTRIM(SRA->RA_CIC )+"', "+ ALLTRIM(STR(SRA->RA_SALARIO / SRA->RA_HRSMES)) +", '"+ ALLTRIM(SRA->RA_CODFUNC )+"', '"+ ALLTRIM(SRA->RA_RG )+"'   "
				::cSqlInsert += ", CONVERT(DATETIME,'"+ DTOS(SRA->RA_NASC) +"',112) "
				::cSqlInsert += " , '"+ ::trataTxt(ALLTRIM(SRA->RA_ENDEREC))+ " , " +IF(!EMPTY(ALLTRIM(SRA->RA_NUMENDE)),ALLTRIM(SRA->RA_NUMENDE),ALLTRIM(SRA->RA_LOGRNUM))+" - " +ALLTRIM(SRA->RA_COMPLEM )
				
				::cSqlInsert += " ' , '"+ ALLTRIM(SRA->RA_CEP) +"', '"+ ::trataTxt(ALLTRIM(SRA->RA_BAIRRO)) +"' "
				::cSqlInsert += ", "+IF(ALLTRIM(SRA->RA_CC) $ ALLTRIM(SUPERGETMV( 'TCP_MANCC', .f., '001032' ) ),IF (EMPTY(SRA->RA_DEMISSA),'1', "0"),'0') +"); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
			    ::cSqlInsert := "INSERT  INTO FUNCIONARIOINTEGRACAO (IdIntegracao,Matricula,NomeCompleto,CodigoTurno,DataAdmissao,DataDemissao,CodigoCentroDeCusto"  
				::cSqlInsert += " ,Email, DDD_Telefone,CPF,ValorHora,CodigoFuncao,RG,DataNascimento,EnderecoCompleto,CEP,Bairro,Ativo) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ', ' ' "
				::cSqlInsert += ", ' ', ' ', ' ',' ', ' ' , ' ', 0, ' ', ' '  , ' ' , ' ', ' ', ' ',0);"
			   
			ELSE	
				::cErroValid := 'Funcionário inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  CASE ZZE->ZZE_ENTIDA =='SB9'
		 	dbSelectArea('SB1')
			DbsetOrder(1)
			
			_nValor := 0
			
			IF SB1->(DBSeek(::cChave))  
				
				
				_cAlias   := GetNextAlias()
				BeginSql alias _cAlias
					SELECT *
					FROM %table:SB9% SB9
					WHERE SB9.%notDel% AND B9_COD = %EXP:SB1->B1_COD% 
					ORDER BY B9_DATA DESC
				EndSql
				
				IF (_cAlias)->(!Eof())
					_nValor := (_cAlias)->B9_CM1
				EndIf
				
				(_cAlias)->(dbclosearea())
				
				::cSqlInsert := "INSERT  INTO ITENSESTOQUEINTEGRACAO (IdIntegracao,Codigo,CodigoAlmoxarifado,EstoqueMinimo,EstoqueMaximo,CustoUnitario"
				::cSqlInsert += " ,Localizacao, Criticidade,LoteEconomico) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SB1->B1_COD +"', '"+ SB1->B1_LOCPAD  +"', "+ ALLTRIM(STR(SB1->B1_EMIN)) +""
				::cSqlInsert += ", "+ALLTRIM(STR(IF(SB1->B1_EMAX > 0,SB1->B1_EMAX,9999999999))) +", "+ALLTRIM(STR(_nValor)) +", '"+ SB1->B1_ZLOCALI +"', ' ',"+  ALLTRIM(STR(SB1->B1_LM))+"); "
			   
			ELSE	
				::cErroValid := 'Item Estoque inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  CASE ZZE->ZZE_ENTIDA =='NNR'
		 dbSelectArea('NNR')
			DbsetOrder(1)
			IF NNR->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO ALMOXARIFADOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ NNR->NNR_CODIGO +"', '"+ ::trataTxt(NNR->NNR_DESCRI) +"' ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
							
				::cSqlInsert := "INSERT  INTO ALMOXARIFADOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ); "
			   
			ELSE		
				::cErroValid := 'Almoxarifado inválido. Chave: '+::cChave
				lRet := .F.
			ENDIF   
	  CASE ZZE->ZZE_ENTIDA =='SRJ'
		 	dbSelectArea('SRJ')
			DbsetOrder(1)
			IF SRJ->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO FUNCAOINTEGRACAO (IdIntegracao,Codigo,Descricao) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SRJ->RJ_FUNCAO +"', '"+ ALLTRIM(SRJ->RJ_FUNCAO) +'-'+ ::trataTxt(ALLTRIM(SRJ->RJ_DESC)) +"' ); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO FUNCAOINTEGRACAO (IdIntegracao,Codigo,Descricao)"
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ');"
			ELSE		
				::cErroValid := 'Função inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='AWF'
		 	dbSelectArea('SC2')
			DbsetOrder(1)
			IF SC2->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO ALTERACAOSTATUSWORKFLOWINTEGRACAO (IdIntegracao,OrdemManutencao,TextoTimeline) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ SC2->C2_XNUMOM +"', '"+ ALLTRIM(::cTxtStat) +"' ); "
	
			ELSE		
				::cErroValid := 'OP inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='SOP'
		 	dbSelectArea('ZZF')
			//op+reserva
			//DbsetOrder(2)
			
			ZZF->(DBOrderNickname( 'NUMEROOP'))
			IF ZZF->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO ALTERACAOSTATUSRESERVAINTEGRACAO (IdIntegracao,NumeroReserva,Status) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ALLTRIM(ZZF->ZZF_RESERV) +"','"+ ::cStatOp +"' ); "
			   
			/*ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO ALTERACAOSTATUSRESERVAINTEGRACAO (IdIntegracao,Codigo,Descricao)"
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ');"
			*/
			ELSE		
				::cErroValid := 'Função inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF  	
	  CASE ZZE->ZZE_ENTIDA =='BXP'
		 	dbSelectArea('CB9')
			DbsetOrder(6)
			IF CB9->(DBSeek(::cChave))  
				
				dbSelectArea('CB8')
				DbsetOrder(4)
				IF CB8->(DBSeek(::cChave)) 	
					
					DbSelectArea('ZZF')
					
					ZZF->(DbSetOrder(2))
					
					IF ZZF->(DbSeek(xFilial('ZZF')+CB8->CB8_OP ))	
						::cSqlInsert := "INSERT  INTO MATERIAISUTILIZADOSINTEGRACAO (IdIntegracao,OrdemManutencao,Material,Quantidade,CodigoAlmoxarifado,ValorUnitario) "
						::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ZZF->ZZF_OM +"', '"+ CB8->CB8_PROD +"',"+ ALLTRIM(STR(ZZE->ZZE_QTDBX))+", '"+CB9->CB9_LOCAL+"',"+ ALLTRIM(STR(CB8->CB8_CUSTOL))+"); "
					endif
				ENDIF
				
			/*ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO FUNCAOINTEGRACAO (IdIntegracao,Codigo,Descricao)"
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ');"
			*/	
			ELSE		
				::cErroValid := 'Leitura inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  CASE ZZE->ZZE_ENTIDA =='EXP'
		 	dbSelectArea('SD3')
			_nRecno := VAL(::cChave)
			SD3->(DbGoto(_nRecno))
			
			//Garante que encontrou o registro
			IF SD3->(RECNO()) ==  _nRecno
				
				::cSqlInsert := "INSERT  INTO ESTORNOMATERIAISUTILIZADOSINTEGRACAO (IdIntegracao,OrdemManutencao,Material,Quantidade,CodigoAlmoxarifado) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ALLTRIM(Posicione('SC2',1,SD3->D3_FILIAL+Alltrim(SD3->D3_OP),"C2_XNUMOM")) +"', '"+ SD3->D3_COD +"',"+ ALLTRIM(STR(SD3->D3_QUANT))+", '"+SD3->D3_LOCAL+"'); "
					
				
			/*ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO FUNCAOINTEGRACAO (IdIntegracao,Codigo,Descricao)"
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc +"', ' ');"
			*/	
			ELSE		
				::cErroValid := 'Leitura inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF  
	  //Utlizado para a primeira carga de contas contábeis
      CASE ZZE->ZZE_ENTIDA =='ZZZ'
		 dbSelectArea('CT1')
			DbsetOrder(1)
			IF CT1->(DBSeek(::cChave))  
							
				::cSqlInsert := "INSERT  INTO CONTACONTABILINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ CT1->CT1_CONTA +"', '"+ ALLTRIM(CT1->CT1_CONTA) +'-'+ ::trataTxt( ALLTRIM(CT1->CT1_DESC01)) +"' "
			    ::cSqlInsert += ",NULL); "
			   
			ELSEIF ZZE->ZZE_OPER == 'E'	
				::cSqlInsert := "INSERT  INTO CONTACONTABILINTEGRACAO (IdIntegracao,Codigo,Descricao,CodigoPai) "
				::cSqlInsert += "VALUES ("+ALLTRIM(STR(::nIdInteg))+" , '"+ ::cChaveExc  +"', ' ' ,NULL);"
			ELSE		
				::cErroValid := 'Conta Contábil inválida. Chave: '+::cChave
				lRet := .F.
			ENDIF
	  OTHERWISE
		 ::cErroValid := 'Entidade inválida. Entidade: ' +ZZE->ZZE_ENTIDA
		 ::cStatus    := 'R'
		 lRet := .F.
	ENDCASE 
	
Return lRet        

/*/{Protheus.doc} gravaIntegracao
Roda o insert na tabela de integração
@author Eduardo vieira
@since 01/11/2018
@version 1.0  teste
@param 
@type function
/*/
Method gravaIntegracao() Class ClassIntManusis
	
	Local lRet := .T.
	    
	If (TCSQLExec(::cSqlInsert) < 0)
		::cErroValid := 'Erro ao gravar na tabela de integração.'
		::cErroCmp   := 'Erro ao gravar na tabela de integração. Erro '+ TCSQLError()+' - SQL: ' + ::cSqlInsert
		lRet := .F.
	EndIf

Return lRet   


/*/{Protheus.doc} atualizaHistorico
consulta integrações ainda não finalizadas e atualiza o status
@author Eduardo vieira
@since 01/11/2018
@version 1.0  teste
@param 
@type function
/*/
Method atualizaHistorico() Class ClassIntManusis
	
	
local cAlias := getNextAlias()
local cSQL := ''
Local nRecZze := 0
Local cWhere := '%'

IF !empty(::cChaveZZE)
	cWhere += " AND ZZE_FILIAL+ZZE_CODIGO = '"+::cChaveZZE+"'" 
endif

IF !empty(::cEntidade)
	cWhere += " AND ZZE_ENTIDA = '"+::cEntidade+"'" 
endif

IF !empty(::dDataDe)
	cWhere += " AND ZZE_DTINC  >= '"+DTOS(::dDataDe)+"'" 
endif

IF !empty(::dDataAte)
	cWhere += " AND ZZE_DTINC  <= '"+DTOS(::dDataAte)+"'" 
endif


cWhere += '%'

BeginSQL Alias cAlias
	 
	 SELECT ZZE.R_E_C_N_O_ AS RECZZE
	 FROM %Table:ZZE% ZZE
	 WHERE   ZZE.%NotDel% AND ZZE.ZZE_STATUS IN ('E','I','P','X') %EXP:cWhere%
	 
EndSQL  

dbSelectArea('ZZE')
//Se não encontrou nenhuma solicitação pendente, cadastra
while (cAlias)->(!Eof())
	
	ZZE->(DbGoto((cAlias)->RECZZE))
	
	IF ZZE->ZZE_STATUS == 'P'
		::cErroValid := ''
		::cErroCmp  := ''
		::cSqlInsert:= ''
		::INTEGRAMANUSIS(ZZE->ZZE_FILIAL+ZZE->ZZE_CODIGO)
	ELSE
		cSQL := " SELECT e.Codigo as CodigoEtapa,e.Descricao as DescEtapa, CAST(lei.Descricao AS VARCHAR(4000))as DescIntegracao  from INTEGRACAO i "
		cSQL += " JOIN LOGETAPAINTEGRACAO lei on lei.IdLogEtapaIntegracao = i.IdLogEtapaIntegracao"
		cSQL += " JOIN ETAPAINTEGRACAO e on lei.IdEtapaIntegracao = e.IdEtapaIntegracao"
		cSQL += " WHERE i.IdCodigoIntegracaoProtheus='"+ZZE->ZZE_FILIAL+ZZE->ZZE_CODIGO+"'"
		//cSQL += " AND (IntegradoManusis=1  ;"
	       
		TCQUERY cSQL NEW Alias (cAliasInt:=GetNextAlias())
		
		dbselectarea(cAliasInt)
		
		(cAliasInt)->(dbGoTop())
		If (cAliasInt)->(!Eof())       
			RecLock("ZZE",.F.)
			
			IF(ALLTRIM((cAliasInt)->CodigoEtapa) == 'INT' )  
				ZZE->ZZE_ERRO   :=  ''
				ZZE->ZZE_STATUS :=  'S'
				ZZE->ZZE_DTALT  :=  DATE()
				ZZE->ZZE_HRALT  :=  TIME()
			ELSEIF(ALLTRIM((cAliasInt)->CodigoEtapa) == 'RCE' )  
				ZZE->ZZE_ERRO   := ALLTRIM((cAliasInt)->DescEtapa) + ' - '+ ALLTRIM((cAliasInt)->DescIntegracao)
				ZZE->ZZE_STATUS := 'O'
				ZZE->ZZE_DTALT  :=  DATE()
				ZZE->ZZE_HRALT  :=  TIME()
			ELSE
				ZZE->ZZE_ERRO   := ALLTRIM((cAliasInt)->DescEtapa) + ' - '+ ALLTRIM((cAliasInt)->DescIntegracao)
				ZZE->ZZE_STATUS := 'X'
				ZZE->ZZE_DTALT  :=  DATE()
				ZZE->ZZE_HRALT  :=  TIME()
			
			endif
			
			ZZE->(msUnlock())
			
		endif
		(cAliasInt)->(dbCloseArea())
	ENDIF
	
	(cAlias)->(DbSkip())
enddo

(cAlias)->(dbclosearea())

Return .T.   


/*/{Protheus.doc} trataTxt
trata texto para montar a SQL
@author Eduardo vieira
@since 22/11/2018
@version 1.0  teste
@param 
@type function
/*/
Method trataTxt(cTxt) Class ClassIntManusis
RETURN StrTran (cTxt, "'", "''")
