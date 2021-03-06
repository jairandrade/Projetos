#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI052J  �Autor  � -Kaique Sousa-    � Data �  08/21/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �TRANSFORMA STRING COM SEPARADORES EM INSTRUCAO SQL/ORACLE   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function REFI052J(_cTexto,nTam,cSep)

Local _cVlPar		:= (_cTexto)
Local	_cTmp			:= ''
Local _cPart		:= ''
Local _lSep			:= .F.
Local nI			:= 1

Default cSep		:= ' ,|-#/'
Default nTam		:= 0

While Right(_cVlPar,1) $ cSep
	_cVlPar := Left(_cVlPar,Len(_cVlPar)-1)
EndDo

//Vejo se tem algum separador na String;
For nI := 1 To Len(cSep)
	If (_lSep := Substr(cSep,nI,1) $ AllTrim(_cVlPar))
		Exit
	EndIf
Next nI

//Separo as Formas de Pagamento para montar o Filtro em sintaxe SQL
If _lSep
	For nI := 1 To Len(AllTrim(_cVlPar))
		If (Substr(_cVlPar,nI,1) $ cSep) .And. nI < Len(AllTrim(_cVlPar))
			If !Empty(_cPart)
				_cTmp += IIf(Empty(_cTmp),"'",",'") + PadR(_cPart,IIf(nTam=0,Len(_cPart),nTam)) + "'"
			EndIf
			_cPart := ''
		Else
			_cPart += Substr(_cVlPar,nI,1)
			If nI == Len(AllTrim(_cVlPar))
				If !Empty(_cPart)
					_cTmp += IIf(Empty(_cTmp),"'",",'") + PadR(_cPart,IIf(nTam=0,Len(_cPart),nTam)) + "'"
				EndIf
			EndIf
		EndIf
	Next nI
Else
	If !Empty(_cVlPar)
		_cTmp := "'"+_cVlPar+"'"
	EndIf
EndIf

Return( _cTmp )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PefinNat  �Autor �Kaique Sousa        � Data �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para retornar a natureza de acordo com a tabela     ���
���          � da Experian (serasa) e os dados do cheque caso seja Nat=DC ���
�������������������������������������������������������������������������͹��
���Uso       � Geracao de Arquivo PEFIN                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PefinNat(_nOpc)

Local _nPipe	:= 0
Local _cReturn 	:= ""
Local _cNatOper	:= ""
Local _cAlinea	:= ""
Local _aVal		:= {.F.,.F.,.F.}

Default	_nOpc 		:= 1  // 1=Retorna a Natureza, 2=Retorna (Banco, Agencia, Conta, Alinea), 3=Retorna o nosso numero

// Verifica a natureza da operacao
ZP7->(DbSetOrder(1))
ZP7->(DbGoTop())
While ZP7->(!Eof())

	If (ZP7->ZP7_STATUS <> 'A') .Or. (Empty(ZP7->ZP7_REGSA1) .And. Empty(ZP7->ZP7_REGSE1) .And. Empty(ZP7->ZP7_REGSEF))
		ZP7->(DbSkip())	
		Loop
	EndIf

	_aVal[1]	:= If(!Empty(ZP7->ZP7_REGSA1),&(ZP7->ZP7_REGSA1),.T.)
	_aVal[2]	:= If(!Empty(ZP7->ZP7_REGSE1),&(ZP7->ZP7_REGSE1),.T.)
	_aVal[3]	:= If(!Empty(ZP7->ZP7_REGSEF),&(ZP7->ZP7_REGSEF),.T.)

	If _aVal[1] .And. _aVal[2] .And. _aVal[3]
		_cNatOper := ZP7->ZP7_COD
		Exit
	EndIf

	ZP7->(DbSkip())
EndDo

//Protecao caso nenhuma regra seja atendida.
If Empty(_cNatOper)
	_cNatOper := 'DP'
EndIf

// Verfica o tipo do retorno
If	_nOpc == 1 // 1=Retorna a Natureza

	_cReturn := _cNatOper

ElseIf	_nOpc == 2 // 2=Retorna (Banco, Agencia, Conta, Alinea)

	//Verificar se o Titulo eh um registro importado do IB com dados de Serasa (Campo E1_NRDOC)
	If !Empty(SE1->E1_NRDOC) .And. !Empty(_nPipe := At('|',AllTrim(SE1->E1_NRDOC)))

		//Correcao realizada para exclusao de titulos do Serasa e que foram importados do IB. 
		//_cReturn := PadL(Substr(AllTrim(SE1->E1_NRDOC),1,_nPipe-1),16,'0')
		_cReturn := PadR(Substr(AllTrim(SE1->E1_NRDOC),1,_nPipe-1),16,' ')

	Else

		// Apenas para cheques
		If	_cNatOper == "DC"
			If	AllTrim(SE1->E1_BCOCHQ) <> "" .and. AllTrim(SE1->E1_AGECHQ) <> ""
				_cReturn += PadL(SE1->E1_BCOCHQ,4,"0")
				_cReturn += PadL(SE1->E1_AGECHQ,4,"0")
				_cReturn += PadL(SubStr(SE1->E1_NUM,1,6),6,"0")
				DbSelectArea("SEF")
				SEF->(DbSetOrder(3))
				If	SEF->(DbSeek(xFilial("SEF")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
					If	! Empty(SEF->EF_ALINEA2)
						_cAlinea := PadL(AllTrim(SEF->EF_ALINEA2),2,"0")
					Else
						_cAlinea := PadL(AllTrim(SEF->EF_ALINEA1),2,"0")
					EndIf
				EndIf

				// Apenas essas alineas permitidas.
				If	AllTrim(_cAlinea) $ "12/13/14" 
					_cReturn += _cAlinea
				Else
					_cReturn += "12"
				EndIf

			Endif

		EndIf

	EndIf

	//Protecao e retorno padrao
	If	Empty(_cReturn)
		//           0      PPP                                       999999999                           NNN 
		//_cReturn += "0" + PadR(AllTrim(SE1->E1_PREFIXO),3,"0") + PadL(AllTrim(SE1->E1_NUM),9,"0") + PadR(AllTrim(SE1->E1_PARCELA),3,"0")
		_cReturn += "0" + PadR(AllTrim(SE1->E1_PREFIXO),3,"0") + PadL(AllTrim(&cCampo),9,"0") + PadR(AllTrim(SE1->E1_PARCELA),3,"0")
	EndIf

ElseIf _nOpc == 3 // 3=Retorna o nosso numero

	//Verificar se o Titulo eh um registro importado do IB com dados de Serasa (Campo E1_NRDOC)
	If !Empty(SE1->E1_NRDOC) .And. !Empty(_nPipe := At('|',AllTrim(SE1->E1_NRDOC)))

		_cReturn := PadL(Substr(AllTrim(SE1->E1_NRDOC),_nPipe+1),9,'0')

	Else

		// Apenas para cheques (Retorna o numero da Conta Corrente do Devedor
		If	_cNatOper == "DC"
			_cReturn := If( SA1->(FieldPos(ZP6->ZP6_CPCORR))>0 , &("SA1->"+ZP6->ZP6_CPCORR) , SPACE(9) )
		EndIf

	EndIf

	//Protecao e retorno padrao
	If	Empty(_cReturn)
		//_cReturn += PadL(AllTrim(SE1->E1_NUM),9,"0")
		_cReturn += PadL(AllTrim(&cCampo),9,"0")
	EndIf

EndIf

Return( _cReturn )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PefinMot  �Autor �Kaique Sousa        � Data �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para determinar o codigo da baixa do titulo         ���
���          � ( Codigo de Baixa conforme tabela da Serasa )              ���
�������������������������������������������������������������������������͹��
���Uso       � Exclusao de Titulos do PEFIN (Experian Serasa)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PefinMot()

Local	_cQryBx	:= ""
Local	_cCodBx	:= ""

//���������������������������������������������������������Ŀ
//�MOTIIVOS DE BAIXA (PADRAO) CODIGO DA SERASA:             �
//�01 - pagamento da d�vida                                 �
//�02 - renegocia��o da duvida                              �
//�03 - por solicita��o do cliente                          �
//�04 - ordem judicial                                      �
//�05 - corre��o de endereco                                �
//�06 - atualizacao do valor - valorizacao                  �
//�07 - atualizacao do valor-pagamento parcial              �
//�08 - atualizacao de data                                 �
//�09 - correcao do nome                                    �
//�10 - correcao do n�mero do contrato                      �
//�11 - correcao de varios dados (valor+datas+etc)          �
//�12 - baixa por perda de controle de base                 �
//�13 - motivo nao identificado                             �
//�14 - pontualiza��o da d�vida                             �
//�15 - baixa por concess�o de credito                      �
//�16 - incorporacao / mudanca de titularidade              �
//�17 - comunicado devolvido dos correios                   �
//�18 - correcao de dados do coobrigado / avalista.         �
//�19 - renegociacao da divida por acordo.                  �
//�20 - pagamento da divida por pagamento bancario.         �
//�21 - analise de documentos.                              �
//�22 - correcao de dados pela loja / filial.               �
//�23 - pagamento da divida por emiss�o de Nota Promissoria.�
//�24 - analise de documento por seguro.                    �
//�25 - devolu��o ou troca de bem financiado.               �
//�����������������������������������������������������������

//���������������������������������������������������������Ŀ
//�PRINCIPAIS MOTIVOS DE BAIXA USADOS:                      �
//�01 - pagamento da divida                                 �
//�02 - renegociacao da duvida                              �
//�13 - motivo nao identificado                             �
//�����������������������������������������������������������

If !Empty(SE1->E1_MOPEFIN)

	//Codigo Informado pela Positivacao Manual do Titulo.
	_cCodBx := SE1->E1_MOPEFIN

Else

	// Verifica como foi feita a ultima baixa do titulo para determinar o codigo de baixa.
	_cQryBx	:= " SELECT E5_MOTBX "
	_cQryBx	+= " FROM " + RetSqlName('SE5')
	_cQryBx	+= " WHERE E5_FILORIG =  '" + SE1->E1_FILIAL + "' "
	_cQryBx	+= " AND E5_PREFIXO  =  '" + SE1->E1_PREFIXO + "' "
	_cQryBx	+= " AND E5_NUMERO   =  '" + SE1->E1_NUM + "' "
	_cQryBx	+= " AND E5_PARCELA  =  '" + SE1->E1_PARCELA + "' "
	_cQryBx	+= " AND E5_TIPO     =  '" + SE1->E1_TIPO + "' "
	_cQryBx	+= " AND E5_CLIFOR   =  '" + SE1->E1_CLIENTE + "' "
	_cQryBx	+= " AND E5_LOJA     =  '" + SE1->E1_LOJA + "' "
	_cQryBx	+= " AND E5_SITUACA <> 'C' "
	_cQryBx	+= " AND E5_RECPAG = 'R' "
	_cQryBx	+= " AND D_E_L_E_T_ =  ' ' "
	_cQryBx	+= " ORDER BY E5_FILIAL, E5_SEQ DESC "
	
	If Select('TRA') > 0
		 TRA->(DbCloseArea())
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQryBx),'TRA',.F.,.T.)
	
	If	TRA->(!Eof() )
		_cCodBx := Posicione('ZP2',2,xFilial('ZP2')+'A'+AllTrim(TRA->E5_MOTBX),'ZP2_COD')
		If Empty(_cCodBx)
				_cCodBx	:= "13" 	// Motivo nao identificado
		Endif
	Else
		_cCodBx	:= "12" 	  		// Motivo n�o encontrado - problema em base de dados.
	EndIf

	TRA->(DbCloseArea())

EndIf

Return( _cCodBx )