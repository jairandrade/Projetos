
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Valida nº da nota, para não digitar repetida.
!				     ! 														 !
/*-----------------+---------------------------------------------------------+
!Nome              ! ACOM010                                                   !			                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/09/2015 
                                             !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/
user function ACOM010(_cNumNf,_cNumfor,_cNumLoj)
    LOCAL cRet
	local cAliasAx  := getNextAlias() 
    
	BeginSQL Alias cAliasAx
		SELECT *
		FROM %Table:SF1% SF1 
		WHERE SF1.%NotDel% AND F1_FILIAL = %Exp:xFilial("SF1")% AND SF1.F1_DOC = %Exp:_cNumNf% AND F1_FORNECE = %Exp:_cNumfor%
	EndSQL    

	nTotReg := Contar(cAliasAx,"!Eof()")
	(cAliasAx)->(DbGoTop())
	
	if nTotReg > 0
		cRet := Aviso("Confirma a inclusão da nota?","Já existe uma nota com este número. Número "+(cAliasAx)->F1_DOC+" Série "+(cAliasAx)->F1_SERIE+" Fornecedor "+(cAliasAx)->F1_FORNECE+" Loja "+(cAliasAx)->F1_LOJA+' Emissão '+DTOC(STOD((cAliasAx)->F1_EMISSAO)),{"Confirmar", "Cancelar"})
		IF(cRet == 1)
		   RETURN .T.//valApr()  
		else
			RETURN .F.
		endif
	ENDIF  
	
		
return .T.  

user function ACOM010W()
    LOCAL cRet
	local cAliasAx  := getNextAlias() 
    lOCAL _cMailAcmp :=  SUPERGETMV("TCP_NFDUPL", .T., 'EXT_EDUARDO.VIEIRA@TCP.COM.BR;EXT_DENNI.MARTINS@TCP.COM.BR')
    Local oMail,oHtml   := Nil
    Local cMat          := ""
    Local cLibCli       := ''
    
	BeginSQL Alias cAliasAx
		
		SELECT *
		FROM %Table:SF1% SF1 
		INNER JOIN %Table:SA2% SA2 ON A2_COD= F1_FORNECE AND A2_LOJA = F1_LOJA AND  SA2.%NotDel%
		WHERE SF1.%NotDel% AND F1_FILIAL = %Exp:xFilial("SF1")% AND SF1.F1_DOC = %Exp:SF1->F1_DOC% AND F1_FORNECE = %Exp:SF1->F1_FORNECE%
	EndSQL    

	nTotReg := Contar(cAliasAx,"!Eof()")
	(cAliasAx)->(DbGoTop())
	
	if nTotReg > 1
		
		oProc := TWFProcess():New("MAILCOM04","Duplicate Invoice")
		oProc:NewTask("Duplicate Invoice", "\WORKFLOW\HTML\MAILCOM04.HTML" )
		oProc:cSubject := "Duplicate Invoice"
		oHtml := oProc:oHtml
			
		 _cHtml := ''    
		 WHILE !(cAliasAx)->(Eof())
		    _cHtml += "<tr>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += (cAliasAx)->F1_DOC +'/'+(cAliasAx)->F1_SERIE
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += (cAliasAx)->F1_ESPECIE
			_cHtml += "</td>"
			_cHtml += "<td  class='class_fornece'>"
			_cHtml += (cAliasAx)->F1_FORNECE+(cAliasAx)->F1_LOJA+' - '+(cAliasAx)->A2_NREDUZ
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += IF(LEN(ALLTRIM((cAliasAx)->A2_CGC))> 11,Transform( (cAliasAx)->A2_CGC, "@R 99.999.999/9999-99" ),Transform( (cAliasAx)->A2_CGC, "@R 999.999.999-99 " )) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_data'>"
			_cHtml += DTOC(STOD((cAliasAx)->F1_EMISSAO))
			_cHtml += "</td>"
			_cHtml += "<td class='class_data'>"
			_cHtml += DTOC(STOD((cAliasAx)->F1_DTDIGIT))
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += buscaUsu((cAliasAx)->F1_USERLGI)
			_cHtml += "</td>"
		
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAliasAx)->F1_VALBRUT,"@E 9,999,999,999,999.99")),15)
			_cHtml += "</td>"
			
			_cHtml += "</tr>"
		       
		 	
		 	(cAliasAx)->(DbSkip())
	    enddo
	     
		oHtml:ValByName("cNomEmp",FWFilialName()) 
	    oHtml:ValByName("cItens",_cHtml) 
		
		oProc:cTo := _cMailAcmp
		oProc:Start()
		oProc:Finish()

		WFSendMail()

	ENDIF  
	
		
return .T.  


static function buscaUsu(cUsrLgi)
	Local _cCodUsu := Subs( Embaralha( cUsrLgi, 1), 3, 6)
return FwGetUserName(_cCodUsu)