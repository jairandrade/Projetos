/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! 06 - Financeiro                                         !
+------------------+---------------------------------------------------------+
!Nome              ! GL_A0601                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Fonte para execução de JSON - Itaú - Boletos.           !
+------------------+---------------------------------------------------------+
!Autor             ! Leonardo França                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 27/05/2018                                              !
+------------------+---------------------------------------------------------+
*/

#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"
#include "fileio.ch"


user function A0602()

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SE1" MODULO "SIGAFIN"

	u_A0601('SCH',)
	
RESET ENVIRONMENT
return

User function A0603(_cEmp,_cFil,_nRecno)


PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil TABLES "SE1" MODULO "SIGAFIN"
		
	U_A0601('ROT',_nRecno)

RESET ENVIRONMENT
return
/*
+----------------------------------------------------------------------------+
! Função    ! A0601        ! Autor ! Leonardo França    ! Data !  27/05/2018 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Função para chamada.						                     !
+-----------+----------------------------------------------------------------+
*/
User Function A0601(_cOri,_cRec) 
Local _lRet := .T.
Local _cQry := ""
Local _cAli := GetNextAlias()

If (_cOri == 'ROT') //CHAMADA VIA ROTINA DE REGISTRO.
	U_A0601REG(_cRec,.T.)
ElseIf (_cOri == 'SCH') //CHAMADA VIA SCHEDULE.
	
	//BUSCA TODOS OS TÍTULOS REGISTRADOS QUE DERAM ERRO NO ENVIO OU NÃO COMPLETARAM O MESMO.
	_cQry := "SELECT SE1.R_E_C_N_O_ SE1REC "
	_cQry += "FROM "+RetSqlName("SE1")+" SE1 "
	_cQry += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
	_cQry += "AND E1_EMISSAO >'20190201' AND SE1.E1_NUMBCO <> '' "
	_cQry += "AND SE1.E1_SALDO > 0 "
	_cQry += "AND (SE1.E1_G_STARE <> '' AND  SE1.E1_G_STARE <> '200') "
	_cQry += "AND SE1.D_E_L_E_T_ <> '*' "
	
	If ( Select(_cAli) ) > 0
		DbSelectArea(_cAli)
		(_cAli)->(dbCloseArea())
	EndIf

	TCQUERY _cQry NEW ALIAS &_cAli
	
	DbSelectArea(_cAli)
	DbGoTop()
	While !Eof()
		//CHAMADA DA FUNÇÃO DE ENVIO.
		U_A0601REG((_cAli)->SE1REC,.F.)
		
		dbSelectArea(_cAli)
		(_cAli)->(dbSkip())
	EndDo
	
	(_cAli)->(dbCloseArea())
	
	
	//Faz a mesma consulta para enviar e-mail dos erros.
	
	TCQUERY _cQry NEW ALIAS &_cAli
	
	DbSelectArea(_cAli)
	(_cAli)->(DbGoTop())
	
	IF (_cAli)->(!Eof())
		//CHAMADA DA FUNÇÃO DE ENVIO de email.
		MAILERRO(_cAli)
	Endif
	
	(_cAli)->(dbCloseArea())
	
EndIf

Return(_lRet)

/*
+----------------------------------------------------------------------------+
! Função    ! A0601REG     ! Autor ! Leonardo França    ! Data !  27/05/2018 !
+-----------+--------------+-------+--------------------+------+-------------+
! Parâmetros! N/A                                                            !
+-----------+----------------------------------------------------------------+
! Descricao ! Fonte para geração.						                     !
+-----------+----------------------------------------------------------------+
*/
User Function A0601REG(_cRec,lEnvMal)
Local _lRet    := .T.
Local _cUrlAut := "https://oauth.itau.com.br/identity/connect/token"
Local _cUrlReg := "https://gerador-boletos.itau.com.br/router-gateway-app/public/codigo_barras/registro"
Local _cId     := "G-DxhjfpRlbL0"
Local _cSecr   := "4E2rSS6g7jHIewTE0BIEge-JFPKzrwbpDH0_Gzyb92ilUf1NXULSYZXKgv6yUyl7SINEjOeMZn0wr4luSuHlsQ2"
Local _cCnpj   := "12919786000124"
Local _nTime   := 1200
Local _cCart   := "109"
Local _nDvnn   := 0
Local _nDvCb   := 0
Local _cBar	   := ""
Local _nFatV   := 0

Local aHeadAut := {}
Local _cSenAut := ""
Local cAutRet  := ""
Local _cPostAu := ""

Local aHeadReg := {}
Local cRegRet  := ""
Local _cTit	   := ""

//ADICIONA HEADER DA CHAMADA POST - AUTENTICAÇÃO.
aadd(aHeadAut,'Content-Type: application/x-www-form-urlencoded')

//ADICIONA PROCESSO DE ENVIO - AUTENTICAÇÃO.
_cSenAut := 'scope=readonly&grant_type=client_credentials'
_cSenAut += '&client_id='+Escape(Alltrim(_cId))
_cSenAut += '&client_secret='+Escape(Alltrim(_cSecr))

//EXECUTA A CHAMADA DA FUNÇÃO - AUTENTICAÇÃO.
_cPostAu := HttpPost(_cUrlAut,"",_cSenAut,_nTime,aHeadAut,@cAutRet)

//POSICIONA A TABELA SE1 PARA PREENCHIMENTO DAS INFORMAÇÕES DE ENVIO.
DbSelectArea("SE1")
SE1->(DbGoTo(_cRec))

//Conout('INTEG NUMERO TIT: '+SE1->E1_NUM)
//Conout('CABEC: '+_cSenAut)

//POSICIONA CLIENTE PARA PREENCHIMENTO DO PAGADOR.
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTop())
SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

//SE AUTENTICOU COM SUCESSO.
If !Empty(_cPostAu) 
	if  SE1->E1_G_STARE != '200' .AND. SA1->A1_EST != 'EX' .AND. SE1->(RECNO()) == _cRec .AND. SE1->E1_SALDO > 0
	//	//Conout("Autenticação efetuada com sucesso Itaú - HttpPost.")
		
		//ADICIONA HEADER DA FUNÇÃO DE ENVIO DO REGISTRO.
		aadd(aHeadReg,"Accept: application/vnd.itau")
		aadd(aHeadReg,"access_token:" + SubStr(_cPostAu,At(":",_cPostAu) + 2, ((At(",",_cPostAu) - 3) - At(":",_cPostAu))))
		aadd(aHeadReg,"itau-chave:" + _cSecr)
		aadd(aHeadReg,"identificador:" + _cCnpj)
			
		//CALCULA DIGITO VERIFICADOR NOSSO NUMERO
		_cS := AllTrim(SE1->E1_AGEDEP) + Substr(Alltrim(SE1->E1_CONTA),1,5) + _cCart + Alltrim(SE1->E1_NUMBCO)
		_nDvnn := Modulo10(_cS)
		
		//CALCULA FATOR VENCIMENTO
		_nFatV := (SE1->E1_VENCTO - CTOD("07/10/1997"))
		
		//CALCULA DIGITO VERIFICADOR CODIGO DE BARRAS
		_cBar := "341" + "9" + Alltrim(Str(_nFatV)) + StrZero((SE1->E1_VALOR*100),10) + _cCart 
		_cBar += Alltrim(SE1->E1_NUMBCO) + _nDvnn + AllTrim(SE1->E1_AGEDEP) + Substr(Alltrim(SE1->E1_CONTA),1,5)
		_cBar += Substr(Alltrim(SE1->E1_CONTA),7,1) + "000"
		
		_nDvCb := Modulo11(_cBar)
		
		//MONTA DÓDIGO DE BARRAS
		_cBar := "341" + "9" + _nDvCb + Alltrim(Str(_nFatV)) + StrZero((SE1->E1_VALOR*100),10) + _cCart 
		_cBar += Alltrim(SE1->E1_NUMBCO) + _nDvnn + AllTrim(SE1->E1_AGEDEP) + Substr(Alltrim(SE1->E1_CONTA),1,5)
		_cBar += Substr(Alltrim(SE1->E1_CONTA),7,1) + "000"
		
		//INICIA MONTAGEM DO TÍTULO
		_cTit := '{'
		_cTit += ' "tipo_ambiente": '+GetNewPar("TCP_BOLAMB", "1")+', ' //1 - TESTE // 2 - PRODUÇÃO
		_cTit += ' "tipo_registro": 1, '
		_cTit += ' "tipo_cobranca": 1, '
		_cTit += ' "tipo_produto": "00006", '
		_cTit += ' "subproduto": "00008", '
		
		_cTit += ' "beneficiario": { '
		_cTit += '                  "cpf_cnpj_beneficiario": "'+_cCnpj+'", '
		_cTit += '                  "agencia_beneficiario": "'+Alltrim(SE1->E1_AGEDEP)+'", '
		_cTit += '                  "conta_beneficiario": "'+Alltrim(StrZero(Val(SubStr(SE1->E1_CONTA,1,5)),7))+'", '
		_cTit += '                  "digito_verificador_conta_beneficiario": "'+Alltrim(SubStr(SE1->E1_CONTA,7,1))+'" '
		_cTit += '                 }, '
		
		_cTit += ' "identificador_titulo_empresa": "'+SE1->E1_PREFIXO+SE1->E1_NUM+'", '
		_cTit += ' "uso_banco": "", '
		_cTit += ' "titulo_aceite": "S", '
		
			
		_cTit += '"pagador": {'
		_cTit += '              "cpf_cnpj_pagador": "'+ALLTRIM(SA1->A1_CGC)+'", '
		_cTit += '              "nome_pagador": "'+Alltrim(SA1->A1_NREDUZ)+'", '
		_cTit += '              "logradouro_pagador": "'+Alltrim(SA1->A1_END)+'", '
	//	_cTit += '              "bairro_pagador": "'+Alltrim(SA1->A1_BAIRRO)+'", '
		_cTit += '              "cidade_pagador": "'+Alltrim(SA1->A1_MUN)+'", '
		_cTit += '              "uf_pagador": "'+Alltrim(SA1->A1_EST)+'", '
		_cTit += '              "cep_pagador": "'+Alltrim(SA1->A1_CEP)+'" '
		_cTit += '            }, '
		
		_cTit += ' "tipo_carteira_titulo": "109", '
		
		_cTit += ' "moeda": { '
		_cTit += '          "codigo_moeda_cnab": "09" '
		_cTit += '          }, '
		
		_cTit += ' "nosso_numero": "'+Alltrim(SE1->E1_NUMBCO)+'", '
		_cTit += ' "digito_verificador_nosso_numero": "'+_nDvnn+'", '
	//	_cTit += ' "codigo_barras": "'+_cBar+'", '
		_cTit += ' "data_vencimento": "'+SubStr(DTOS(SE1->E1_VENCTO),1,4) + "-" + SubStr(DTOS(SE1->E1_VENCTO),5,2) + "-" + SubStr(DTOS(SE1->E1_VENCTO),7,2)+'", '
		_cTit += ' "valor_cobrado": "'+StrZero((SE1->E1_VALOR*100),17)+'", '
		_cTit += ' "seu_numero": "'+SE1->E1_NUM+'", '
		_cTit += ' "especie": "01", '
		_cTit += ' "data_emissao": "'+SubStr(DTOS(SE1->E1_EMISSAO),1,4) + '-' + SubStr(DTOS(SE1->E1_EMISSAO),5,2) + '-' + SubStr(DTOS(SE1->E1_EMISSAO),7,2)+'", '
//		_cTit += ' "data_limite_pagamento": "'+SubStr(DTOS(SE1->E1_VENCTO),1,4) + '-' + SubStr(DTOS(SE1->E1_VENCTO),5,2) + '-' + SubStr(DTOS(SE1->E1_VENCTO),7,2)+'", '
		_cTit += ' "tipo_pagamento": 3, '
		_cTit += ' "indicador_pagamento_parcial": "false", '
		
		_cTit += ' "juros": { '
		_cTit += '          "tipo_juros": 5 '
		_cTit += '          }, '
		
		_cTit += ' "multa": { '
		_cTit += '          "tipo_multa": 3 '
		_cTit += '          }, '
		
		_cTit += ' "grupo_desconto": [{ '
		_cTit += '          "tipo_desconto": 0 '
		_cTit += '          }], '
		
		_cTit += ' "recebimento_divergente": { '
		_cTit += '           "tipo_autorizacao_recebimento": "1" '
		_cTit += '           } '
		
		_cTit += '}'
		
		_cCodLog := U_A0601LOG('Enviar Titulo',SE1->E1_FILIAL,SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PORTADO,SE1->E1_AGEDEP,SE1->E1_CONTA,SE1->E1_CLIENTE+SE1->E1_LOJA,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_XNUMOS,SE1->E1_XIDNAVI,'I',_cTit,'')
	  
		//SERIALIZA A INFORMAÇÃO PARA ENCAMINHAR.
	//	_cReg := FWJsonSerialize(_cTit,.F.,.T.)
		
//		//Conout('DETAIL: '+_cTit)
		//EXECUTA FUNÇÃO DE REGISTO.
		_cPostRe := HttpPost(_cUrlReg,"",_cTit,_nTime,aHeadReg,@cRegRet)
			
		_cSta := ""
		_cDes := ''
		
		If ("200 OK" $ cRegRet)
			_cSta := "200"
			_cDes := "Boleto Registrado"
		elseIf ("400" $ cRegRet)
			_cSta := "400"
			_cDes := _cPostRe //retDesc(Alltrim(_cPostRe))
		ElseIf ("422" $ cRegRet)
			_cSta := "422"
			_cDes := _cPostRe //retDesc(Alltrim(_cPostRe))
		Else
			_cSta := "400"
			_cDes := _cPostRe //retDesc(Alltrim(_cPostRe))
		EndIf
	//	//Conout('vai gravar')
		RecLock("SE1",.F.)
			SE1->E1_G_STARE := _cSta
			SE1->E1_G_DESRE := _cDes
			SE1->E1_G_DTENV := DATE()
			SE1->E1_G_HRENV := TIME()
		SE1->(MsUnlock())
		
		_nRecTit := SE1->(RECNO())
		
		U_A0601ATU(SE1->E1_FILIAL,_cCodLog,'',_cPostRe,SE1->E1_NUM,ALLTRIM(cRegRet),_cSta)
		
		IF _cSta != '200' .and. lEnvMal
			envMailTit(_nRectit)
		endif
		
	//	//Conout('RETORNO: '+_cSta+_cDes
	endif
Else
	//Conout("Erro ao executar autenticação Itaú - HttpPost. Favor verificar!")
	_lRet := .F.
Endif

Return(_lRet)

static function retDesc(_cDescPar)
Local cErro
Local _aNomes
Local nInd
lOCAL cRetDesc := _cDescPar
//Conout('decode utf: '+_cDesc)
_cDesc := DecodeUtf8( _cDescPar,  "cp1252")

//Conout('json: '+_cDesc)
wrk := JsonObject():new()

//Conout('from json: '+_cDesc)
cErro := wrk:fromJson(_cDesc)

//Conout('oka: '+_cDesc)

IF(TYPE("cErro") == 'C')
	
	//Conout('erro: '+cErro)
	cRetDesc := cErro
ELSE

	//Conout('getnames : ')
	_aNomes := wrk:GetNames( )
	
	if VALTYPE(_aNomes) == 'A' 
		cRetDesc := ''
		For nInd := 1 To LEN(_aNomes) 
			cRetDesc += if(!EMPTY(cRetDesc),' - ','')
			cRetDesc += _aNomes[nInd] +': '+ wrk:GetJsonText(_aNomes[nInd])
		Next
	ELSE
		cRetDesc := tiraCaracter(_cDesc)
	ENDIF
	//Conout('fecho names')
ENDIF

if EMPTY(cRetDesc)
	cRetDesc := _cDescPar
ENDIF

return cRetDesc

STATIC function tiraCaracter(_cTxt)    

   _cTxt := StrTran (_cTxt, '"', "")
   _cTxt := StrTran (_cTxt, "'", " ")
   _cTxt := StrTran (_cTxt, ",", " ")
   _cTxt := StrTran (_cTxt, "{", " ")
   _cTxt := StrTran (_cTxt, "}", " ")
   _cTxt := StrTran (_cTxt, chr (9), " ") // TAB
   //_cTxt := StrTran (_cTxt, chr (32), "") // TAB
   
                                                                                                                                                                          
return _cTxt

STATIC function MAILERRO(_cAlias)

Local cEmail := GetNewPar("TCP_BOLFIN", "eduardo.vieira@ewave.com.br;eduardo.francisco@tcp.com.br")
Local nInd   := 1

oProc := TWFProcess():New("MAILFIN03","Boletos não registrados")
                                                             
oProc:NewTask("Registro de boleto", "\WORKFLOW\HTML\MAILFIN03.HTML" )
oProc:cSubject := "Boletos não registrados	

oHtml := oProc:oHtml

IF valtype(oHtml) != "U"
	
	While (_cAlias)->(!Eof())
		
		DbSelectArea("SE1")
			
		SE1->(DbGoTo((_cAlias)->SE1REC))
		_cDescErro := retDesc(SE1->E1_G_DESRE)
		
		RecLock("SE1",.F.)
			SE1->E1_G_DESRE := _cDescErro//_cDes
		SE1->(MsUnlock())
		
		IF nInd == 1      
			oHtml:ValByName("cData",Dtoc(date()))    
			oHtml:ValByName("cHora",time())      
		endif
		
		aAdd((oHtml:ValByName("it.numero")),SE1->E1_NUM)
		aAdd((oHtml:ValByName("it.prefixo")), SE1->E1_PREFIXO)
		aAdd((oHtml:ValByName("it.tipo")),SE1->E1_TIPO)
		aAdd((oHtml:ValByName("it.cliente")),SE1->E1_CLIENTE + '/' + SE1->E1_LOJA + ' - ' + SE1->E1_NOMCLI )
		aAdd((oHtml:ValByName("it.emissao")),DTOC(SE1->E1_EMISSAO))
		aAdd((oHtml:ValByName("it.valor")),TransForm(SE1->E1_VALOR,'@E 999,999.99'))
		aAdd((oHtml:ValByName("it.codErro")),SE1->E1_G_STARE)
		aAdd((oHtml:ValByName("it.erro")),SE1->E1_G_DESRE)
				
		(_cAlias)->(dbSkip())
	EndDo
	
	oProc:cTo := cEmail
	oProc:Start()

	WFSendMail()
endif
	
return


User Function A0601LOG(_cRotina,_cFil,_cNum,_cPref,_cPort,_cAge,_cConta,_cCliente,_dVenc,_nValor,_cNumOs,_cIdNavi,_cOper,_XmlEnv,_XmlRet)
	Local _cCodigo := GETSX8NUM("ZZJ","ZZJ_CODIGO")

	RecLock("ZZJ",.T.)
	ZZJ->ZZJ_FILIAL  := _cFil
	ZZJ->ZZJ_CODIGO  := _cCodigo
	ZZJ->ZZJ_NUM     := _cNum
	ZZJ->ZZJ_PREFIX  := _cPref
	ZZJ->ZZJ_PORT    := _cPort
	ZZJ->ZZJ_AGENCI  := _cAge
	ZZJ->ZZJ_CONTA   := _cConta
	ZZJ->ZZJ_CLIENT  := _cCliente
	ZZJ->ZZJ_VENC    := _dVenc
	ZZJ->ZZJ_VALOR   := _nValor
	ZZJ->ZZJ_NUMOS   := _cNumOs
	ZZJ->ZZJ_IDNAVI  := _cIdNavi
	ZZJ->ZZJ_OPER    := _cOper
	ZZJ->ZZJ_ROTINA  := _cRotina
	ZZJ->ZZJ_XMLENV  := _XmlEnv
	ZZJ->ZZJ_XMLRET  := _XmlRet
	ZZJ->ZZJ_DTINIC  := DATE()
	ZZJ->ZZJ_HRINIC  := TIME()

	ZZJ->(msUnlock())
	
	ConfirmSX8() 
	
RETURN _cCodigo

User Function A0601ATU(_cFil,_cCodigo,cErro,_XmlRet,_cNumTit,_cCodRet,cStatus)
	dbSelectArea('ZZJ')
	ZZJ->(DBSETOrder(1))
	IF ZZJ->( dbSeek( _cFil + _cCodigo ) )
	
		RecLock("ZZJ",.F.)
		IF !EMPTY(_XmlRet)
			ZZJ->ZZJ_XMLRET   := _XmlRet
		ENDIF
		IF !EMPTY(_cNumTit)
			ZZJ->ZZJ_NUM   := _cNumTit
		ENDIF
		ZZJ->ZZJ_CODRET := _cCodRet
		ZZJ->ZZJ_ERRO   := cErro
		ZZJ->ZZJ_DTFIM  := DATE()
		ZZJ->ZZJ_HRFIM  := TIME()
		ZZJ->ZZJ_STATUS := cStatus
		ZZJ->(msUnlock())
	ENDIF
return

static function envMailTit(_nRecTit)

	Local _cAli2 := GetNextAlias()
	//BUSCA TODOS OS TÍTULOS REGISTRADOS QUE DERAM ERRO NO ENVIO OU NÃO COMPLETARAM O MESMO.
	_cQry := "SELECT SE1.R_E_C_N_O_ SE1REC "
	_cQry += "FROM "+RetSqlName("SE1")+" SE1 "
	_cQry += "WHERE R_E_C_N_O_ = " +ALLTRIM(STR(_nRecTit))
	
	If ( Select(_cAli2) ) > 0
		DbSelectArea(_cAli2)
		(_cAli2)->(dbCloseArea())
	EndIf

	TCQUERY _cQry NEW ALIAS &_cAli2
	
	DbSelectArea(_cAli2)
	DbGoTop()
	IF (_cAli2)->(!Eof())
		//CHAMADA DA FUNÇÃO DE ENVIO de email.
		MAILERRO(_cAli2)
	Endif
	
	(_cAli2)->(dbCloseArea())

return