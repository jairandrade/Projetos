#INCLUDE 'protheus.ch'
#DEFINE	 CR Chr(13) + Chr(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � REFI055J �Autor  � Kaique Sousa      � Data �  06/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �BROWSE DA ROTINA DE GERACAO DO ARQUIVO SERASA CONVENIO PEFIN���
�������������������������������������������������������������������������͹��
���Desc.     �Geracao de PEFIN - Experian Serasa                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function REFI055J(_cTipoGer)

Local _aArea			:= GetArea()
Local aButtons   	:= {}

Private	bProcess  	:= { || U_P055JGE(_cArqTrb),;
							U_550JMOV() ,;
							oBrwMark:oBrowse:Refresh() ,;
							oBrwMark:oBrowse:setFocus() }
Private	cCadastro 	:= ''
Private  _aLogW		:= {}
Private _cAto			:= _cTipoGer

//Variaveis de Comportamento da Geracao
Private lPeInclui	:= _cAto = 'I' .Or. _cAto = 'A'
Private lPeExclui	:= _cAto = 'E' .Or. _cAto = 'A'
Private nTipo			:= If(_cAto='I',1,If(_cAto='E',2,3))

//Variaveis para FormBatch
Private aSays     	:= {}
Private aTipo			:= {'O arquivo ser� gerado com instru��es de......[ INCLUS�O ]','O arquivo ser� gerado com instru��es de......[ EXCLUS�O ]','O arquivo ser� gerado com instru��es de......[ AMBOS ]'}

//= A fun��o SomaAbat reabre o SE1 com outro nome pela ChkFile, pois =
//= o filtro do SE1, desconsidera os abatimentos
SomaAbat("","","","R")

Do Case
	Case _cAto = 'I'
		cCadastro := U_SetLogW(@_aLogw,'SERASA PEFIN - Gera��o de Arquivo - Inclus�o')
	Case _cAto = 'E'
		cCadastro := U_SetLogW(@_aLogw,'SERASA PEFIN - Gera��o de Arquivo - Exclus�o')		
	Case _cAto = 'A'
		cCadastro := U_SetLogW(@_aLogw,'SERASA PEFIN - Gera��o de Arquivo - Inclus�o e Exclus�o')		
EndCase

aAdd(aSays,OemToAnsi( "Aten��o" ) )
aAdd(aSays,OemToAnsi( "Essa rotina ir� gerar o arquivo de envio de informa��es para o SERASA-PEFIN") )
aAdd(aSays,OemToAnsi( " " ) )
aAdd(aSays,OemToAnsi( aTipo[nTipo] ) )
aAdd(aSays,OemToAnsi( " " ) )
aAdd(aSays,OemToAnsi( "Deseja Posseguir?" ) )
   
aAdd(aButtons, { 1,.T.,{ |o| o:oWnd:End(), Processa(bProcess,cCadastro,U_SetLogW(@_aLogw,'Aguarde, gerando arquivo...'),.F.) } } )
aAdd(aButtons, { 2,.T.,{ |o| o:oWnd:End() } } )

FormBatch( cCadastro, aSays, aButtons ,,270,480)



RestArea(_aArea)

Return( Nil )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � P055JGE  �Autor  �-Kaique Sousa-     � Data �  01/27/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �GERA ARQUIVO DO PEFIN PARA ENVIO SERASA                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function P055JGE(cAlias)

Private cBanco,cAgencia,xConteudo
Private cArqCfg			:= ''
Private cArqGer			:= ''
Private nHdlBco    		:= 0
Private nHdlSaida  		:= 0
Private nSeq       		:= 0
Private nSomaValor		:= 0
Private nSomaVlLote		:= 0
Private nQtdTotTit		:= 0
Private nQtdTitLote		:= 0
Private nSomaAcres		:= 0
Private nSomaDecre		:= 0
Private nBorderos		:= 0
Private xBuffer,nLidos 	:= 0
Private nTotCnab2		:= 0 // Contador de Lay-out nao deletar
Private nLinha			:= 0 // Contador de Linhas nao deletar
Private nQtdLinLote		:= 0
Private _cAcao			:= ''
Private cCampo			:= ''

U_P055JGR(cAlias)

nBorderos  	:= 0
nSeq	  			:= 0
nSomaValor 	:= 0
nSomaVlLote	:= 0
nQtdTotTit 	:= 0
nQtdTitLote	:= 0
nQtdLinLote	:= 0

FCLOSE(nHdlBco)
FCLOSE(nHdlSaida)

Return( .T. )




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � P055JGR  �Autor  �-Kaique Sousa-     � Data �  01/27/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �ROTINA DE PROCESSAMENTO DA CRIACAO DO PEFIN                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function P055JGR(cAlias)

Local nTamArq			:= 0
Local lResp			:=.t.
Local lHeader			:=.F.
Local lFirst			:=.F.
Local lFirst2			:=.F.
LOCAL nTam				:= 0
Local nDec				:= 0
Local nUltDisco		:= 0
Local nGrava			:= 0
LOCAL nSavRecno 	:= (cAlias)->(Recno())
Local cDbf
LOCAL oDlg,oBmp
Local nReg				:= 0
Local nSeqInc			:= 0
LOCAL nRegEmp 		:= SM0->(RecNo())
LOCAL cFilDe			:= ''
LOCAL cFilAte			:= ''
Local cArqGerado 	:= ""
Local lAtuDsk 		:= .F.
Local lCnabEmail 	:= .F.
Local cQuery
Local lHeadMod2 	:= .F.
Local bWhile
Local nQtdReg			:= 0 
Local cTitul			:= "'[' + (_cArqTrb)->E1_FILIAL + '] ' + (_cArqTrb)->E1_PREFIXO + '/' + (_cArqTrb)->E1_NUM + '/' + (_cArqTrb)->E1_PARCELA + '/' + (_cArqTrb)->E1_TIPO + ' Cli: ' + (_cArqTrb)->E1_CLIENTE + '/' + (_cArqTrb)->E1_LOJA"
Local nNfs				:= 6
Local nI				:= 0

Private nValor		:= 0

ZP6->(DbSetOrder(1))
ZP6->(DbGoTop())

If !ZP6->(DbSeek(xFilial("ZP6")+MV_PAR01))
	U_P055JAPA(@cArqGerado,.T.)	
	Help(" ",1,"X","Atencao",U_SetLogW(@_aLogw,'Par�metros do conv�nio'+AllTrim(MV_PAR01)+' n�o localizados!',cArqGerado),1,1)
	Return( .F. )
Else
	cArqCfg := AllTrim(ZP6->ZP6_ARQCFG)
	cArqGer	:= AllTrim(ZP6->ZP6_ARQGER)
Endif

// Setas variaveis de Filial
cFilDe := MV_PAR02
cFilAte:= MV_PAR03

nTotCnab2 	:= 0
nSeqInt 		:= 0

dbSelectArea("SE1")
dbSelectArea("SEF")
dbSelectArea("SA1")
dbSelectArea(_cArqTrb)

(_cArqTrb)->(DbGoTop())

If (_cArqTrb)->(Eof()) .And. (_cArqTrb)->(Bof())
	U_P055JAPA(@cArqGerado,.T.)	
	MsgAlert(U_SetLogW(@_aLogW,'N�o h� registros a gerar com base nos par�metros informados !',cArqGerado),'Sem Registros')
	Return( .T. )
Else
	nQtdReg := 0
	IncProc('Verificando a quantidade de registros, aguarde...')
	CursorWait()
	(_cArqTrb)->(dbEval({|| nQtdReg++ }))
	CursorArrow()
	U_SetLogW(@_aLogW,'Verificando a Quantidade de Registros, Total ' + cValToChar(nQtdReg) )	
	(_cArqTrb)->(DbGoTop())
	ProcRegua(nQtdReg)
EndIf

bWhile 	:= { || (_cArqTrb)->(!Eof()) }
nReg		:= 0

While	Eval(bWhile)

	nReg++
	
	If	(_cArqTrb)->E1_TIPO $ MVRECANT+"/"+MVTAXA+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVPROVIS
		U_SetLogW(@_aLogW,'Titulo ' + &(cTitul) + ' ignorado...')
		(_cArqTrb)->( DbSkip() )
		IncProc('Gerando arquivo, aguarde...    '+ cValToChar(nReg))
		Loop
	Else
		//Posiciona no Registro Real
		SE1->(DbGoTo((_cArqTrb)->E1_RECNO))
	EndIF

	Do Case
		//titulo Negativado/Enviado que foi pago mas ainda nao foi excluido - Excluir do Serasa
		Case SE1->E1_ACPEFIN = 'O' .And. SE1->E1_SALDO <= 0 .And. SE1->E1_STPEFIN = '2'
			_cAcao := 'E'
			_lCont := (_cAcao == _cAto) .Or. (_cAto = 'A')
		//Titulo marcado para positivacao mas que ainda nao foi excluido - Excluir do Serasa			
		Case SE1->E1_ACPEFIN = 'I' .And. SE1->E1_STPEFIN = '2'
			_cAcao := 'E'
			_lCont := (_cAcao == _cAto) .Or. (_cAto = 'A')
		//Titulo Marcado para Negativacao - Incluir no Serasa
		Case SE1->E1_ACPEFIN = 'N' .And. SE1->E1_SALDO >  0 .And. SE1->E1_STPEFIN = ' '
			_cAcao := 'I'
			_lCont := (_cAcao == _cAto) .Or. (_cAto = 'A')
		//Titulo Negativacao - Ja Excluido Anteriormente
		Case SE1->E1_ACPEFIN = 'N' .And. SE1->E1_SALDO >  0 .And. SE1->E1_STPEFIN $ '34'
			_cAcao := 'I'
			_lCont := (_cAcao == _cAto) .Or. (_cAto = 'A')
		//Titulo Positivado/Enviado - Excluir do Serasa.
		Case SE1->E1_SALDO <= 0 .And. SE1->E1_STPEFIN $ '34'
			_cAcao := 'E'
			_lCont := ((_cAcao == _cAto) .Or. (_cAto = 'A'))

		OtherWise
			_lCont := .F.
	EndCase

	If !_lCont
		(_cArqTrb)->( dbSkip())
		IncProc('Gerando arquivo, aguarde...    '+ cValToChar(nReg))
		Loop
	EndIf
	
	//Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	SA1->(DbSeek(xFilial('SA1')+SE1->(E1_CLIENTE+E1_LOJA)))

	//Posicione no Cheque
	//(SEF.EF_FILIAL = SE1.E1_FILIAL AND SEF.EF_NUM = SE1.E1_NUM AND SEF.EF_BANCO = SE1.E1_BCOCHQ AND SEF.EF_AGENCIA = SE1.E1_AGECHQ AND SEF.EF_CONTA = SE1.E1_CTACHQ AND ( SEF.EF_ALINEA2 IN ('12','13','14') OR SEF.EF_ALINEA1 IN ('12','13','14') ) AND SEF.D_E_L_E_T_ = ' ' )
	SEF->(DbSetOrder(1))
	SEF->(DbGoTop())
	SEF->(DbSeek(xFilial('SEF')+SE1->(E1_NUM+E1_BCOCHQ+E1_AGECHQ+E1_CTACHQ)))
	
	// Se o Header do arquivo nao foi criado, cria.
	If !lHeadMod2  //Modelo 2
		
		//Faz o tratamento do diferencial por dia
		If dDataBase > ZP6->ZP6_DTUENV
			RecLock('ZP6',.F.)
			ZP6->ZP6_DTUENV := dDataBase
			//ZP6->ZP6_DIFERE := '0000'
			ZP6->(MsUnlock())
		Else
			RecLock('ZP6',.F.)
			//ZP6->ZP6_DIFERE := Soma1(ZP6->ZP6_DIFERE)
			ZP6->(MsUnlock())
		EndIf
		// Obs: ZP6_DIFERE, sempre manter o que foi informado no ZP6, nao alterar a cada envio
		// Este campo foi criado na serasa apenas para diferenciar areas da empresa, quando mais de uma area tem que enviar o arquivo.
		
		lHeadMod2 	:= U_P055JAPA(@cArqGerado)	//Abertura Arquivo ASC II
		// Se houve erro na criacao do arquivo, abandona o processo
		If !lHeadMod2
			U_SetLogW(@_aLogW,'erro na criacao do arquivo, ' + cArqGerado + ' abandonando o processo...')
			Exit
		Endif
	Endif
	
	If !Empty(SE1->E1_YNF1)
		For nI := 1 to nNfs
			cCampo := "SE1->E1_YNF"+Alltrim(Str(nI))
			If .Not. Empty(&(cCampo+"OK"))
				nSeq++
				nQtdTitLote++
				nQtdTotTit++
				
				dbSelectArea("SF2")
				SF2->(dbSetOrder(8))
				SF2->(MsSeek( xFilial("SF2") + &(cCampo)))

				nValor		:= SF2->F2_VALBRUT
				nSomaValor	+= SF2->F2_VALBRUT //SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE
				nSomaVlLote += SF2->F2_VALBRUT //SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE
				nSomaAcres 	+= 0 //SE1->E1_SDACRES
				nSomaDecre 	+= 0 //SE1->E1_SDDECRE
				
				nGrava := S055JGRAVA(,,,)
				
				If nGrava > 1
					nSeq -= 1
				EndIf
				
				Do Case
					Case nGrava == 1		//Pelo menos um t�tulo gerado no arquivo - vou atualizar o n�mero do disco
						//Contador de registros incluidos no arquivo.
						nSeqInc++
						lAtuDsk := .T.
						U_SetLogW(@_aLogW,'T�tulo ' + &(cTitul) + ' inclu�do no arquivo...')
					Case nGrava == 2		//Falha da gravacao do status de um titulo - abandona a rotina.
						U_SetLogW(@_aLogW,"Problema na gravacao do status do titulo ! A rotina ser� encerrada !",cArqGerado)
						Help(" ",1,"X","Atencao","Problema na gravacao do status do titulo ! A rotina ser� encerrada !",1,1)
						Return( .T. )
				EndCase
			EndIf
		Next nI
	Else
		cCampo := "SE1->E1_NUM"
		nSeq++
		nQtdTitLote++
		nQtdTotTit++
		
		nValor		:= SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE
		nSomaValor	+= SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE
		nSomaVlLote += SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE
		nSomaAcres 	+= SE1->E1_SDACRES
		nSomaDecre 	+= SE1->E1_SDDECRE
		
		nGrava := S055JGRAVA(,,,)
		
		If nGrava > 1
			nSeq -= 1
		EndIf
		
		Do Case
			Case nGrava == 1		//Pelo menos um t�tulo gerado no arquivo - vou atualizar o n�mero do disco
				//Contador de registros incluidos no arquivo.
				nSeqInc++
				lAtuDsk := .T.
				U_SetLogW(@_aLogW,'T�tulo ' + &(cTitul) + ' inclu�do no arquivo...')
			Case nGrava == 2		//Falha da gravacao do status de um titulo - abandona a rotina.
				U_SetLogW(@_aLogW,"Problema na gravacao do status do titulo ! A rotina ser� encerrada !",cArqGerado)
				Help(" ",1,"X","Atencao","Problema na gravacao do status do titulo ! A rotina ser� encerrada !",1,1)
				Return( .T. )
		EndCase
	EndIf
	(_cArqTrb)->( dbSkip())
	IncProc('Gerando arquivo, aguarde...    ' + cValToChar(nReg))

EndDo

// Se conseguiu criar o Header do arquivo, entao cria o Trailler
If	lHeadMod2
	
	//Cria o Trailler do arquivo e encerra !
	RodaCnab2(nHdlSaida,cArqCfg)
	
	//= Atualiza Numero do ultimo Disco
	dbSelectArea("ZP6")
	IF !Eof() .and. lAtuDsk
		Reclock("ZP6")
		nUltDisco := VAL(ZP6_ULTDSK) + 1
		Replace ZP6_ULTDSK With StrZero(nUltDisco,TamSx3("ZP6_ULTDSK")[1])
		MsUnlock()
	EndIF
	
	dbSelectArea( cAlias )
	dbGoTo( nSavRecno )
	
	FCLOSE(nHdlBco)
	FCLOSE(nHdlSaida)
	
Endif

DbSelectArea( cAlias )
DbGoTo( nSavRecno )

If nSeqInc = 0
	If Empty(cArqGerado)
		U_P055JAPA(@cArqGerado,.T.)
	EndIf
	MsgInfo(OemToAnsi(U_SetLogW(@_aLogW,"Arquivo n�o gerado, nenhum t�tulo em situa��o de gera��o !",cArqGerado)))	
Else
	MsgInfo(OemToAnsi(U_SetLogW(@_aLogW,"Arquivo gerado, "+cValToChar(nSeqInc)+" registros inclu�dos !",cArqGerado)))
EndIf

Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � P055JAPA �Autor  � Kaique Sousa      � Data �  05/27/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � ABRE ARQUIVO DE PARAMETROS                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function P055JAPA(cArqGerado,_lSoNome)

Local cArqSaida	:= ''
Local _nI			:= 0
Local _nZ			:= 0
Local cLibCli		:= ""
Private lMacOS     	:= (GetRemoteType(@cLibCli),('MAC' $ cLibCli))
Default _lSoNome	:= .F.

//Trata substituicao de caracteres coringa
For _nZ := 1 To 10
	Do Case
		Case (_nI := At('DD',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'DD',Day2Str(dDataBase))
		Case (_nI := At('MM',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'MM',Month2Str(dDataBase))		
		Case (_nI := At('YY',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'YY',Right(Year2Str(dDataBase),2))				
		Case (_nI := At('YYYY',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'YYYY',Year2Str(dDataBase))				
		Case (_nI := At('HH',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'HH',Left(Time(),2))				
		Case (_nI := At('MI',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'MI',Left(Right(Time(),5),2))				
		Case (_nI := At('SS',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'SS',Right(Time(),2))
		Case (_nI := At('OO',cArqGer)) <> 0
			cArqGer := StrTran(cArqGer,'OO',If(_cAto='I','INC',If(_cAto='E','EXC','ALL')))
	EndCase
Next _nZ

If lMacOS
	cArqGer := GetTempPath() + SubStr(cArqGer,Rat("\",cArqGer),len(cArqGer))
EndIf

cDir := SubStr(cArqGer,1,Rat("\",cArqGer)-1)

If !ExistDir(cDir)
	If MsgYesNo("Diretorio informado no Par�metros PEFIN n�o existe. Deseja criar ?")
		MakeDir(cDir)
	Endif
EndIf

IF At(".",cArqGer) = 0
	cArqSaida := Trim(cArqGer) + "." + "TXT"
Else
	cArqSaida := Trim(cArqGer)
EndIF

IF !_lSoNome .And. !FILE(cArqCfg)
	Help(" ",1,"NOARQPAR")
	U_SetLogW(@_aLogW,'Arquivo de Par�metros ' + cArqCfg + ' n�o encontrado !')
	Return( .F. )
EndIF

If !_lSoNome
	nHdlSaida 	:= HeadCnab2(cArqSaida,cArqCfg)
EndIf

//Somente para atualizar a variavel recebida por parametro.
cArqGerado 	:= cArqSaida

Return( .T. )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �S055JGRAVA�Autor  � Kaique Sousa      � Data �  05/27/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � ROTINA DE GERACAO DO ARQUIVO DE REMESSA DE COMUNICACAO     ���
���          � BANCARIA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function S055JGRAVA

Local nRetorno 	:= 1			// 1 = Gravou OK   |   2 = Falhou na atualizacao do Status do Titulo    |  3 = Pulou o Registro (nao e erro !)
Local aGetArea 	:= GetArea()
Local cNomArq		:= ''
Local cArquivo		:= cArqGer
Local nI				:= cB := ''
Local _aVals		:= {}

nTotCnab2++
aEval( Array(Len(cArquivo)) , {|x| nI:=Len(cArquivo),if(cB='\',Nil,(cB:=Substr(cArquivo,nI,1))),cArquivo:=Substr(cArquivo,1,nI-1),If(cB='\',Nil,cNomArq:=AllTrim(cB+cNomArq))} )

If S055JCNAB(nHdlSaida,cArqCfg,.F.,"SE1")

	//Faz a Anotacao de Envio do Titulo
	Begin Transaction
		U_REFI060J(SE1->(Recno()),_cAcao+'-',@_aLogW,cNomArq)
	End Transaction

	If lMsErroAuto
		DisarmTransaction()
		nRetorno := 2			//Problema na Gravacao do Status.
	Else
		nRetorno := 1
	EndIf

Else
	nRetorno := 3			//Pulou o registro por condi��es do arquivo do CNAB - N�o eh erro !
EndIf

RestArea(aGetArea)

Return( nRetorno )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �S055JCNAB �Autor  � - Kaique Sousa -  � Data �  08/21/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �GERA A LINHA DETALHE DO CNAB E FAZ OUTROS TRATAMENTO.       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function S055JCNAB(nHandle,cLayOut,lIdCnab,cAlias)

Local _lGravou		:= .F.
Local nHdlLay	 	:= 0
Local lContinua 	:= .T.
Local cBuffer	 	:= ""
Local aLayOut	 	:= {}
Local aDetalhe  	:= {}
Local nCntFor	 	:= 0
Local nCntFor2  	:= 0
Local lFormula  	:= ""
Local nPosIni	 	:= 0
Local nPosFim	 	:= 0
Local nTamanho  	:= 0
Local nDecimal  	:= 0
Local bBlock	 	:= ErrorBlock()
Local bErro 	 	:= ErrorBlock( { |e| ChecErr260(e,xConteudo) } )
Local aGetArea  	:= GetArea()
Local cIdCnab
Local aArea
Local nOrdem

DEFAULT cAlias 	:= ""
DEFAULT lIdCnab 	:= .F.
Private xConteudo := ""

nQtdLinLote := If(Type("nQtdLinLote") != "N",0,nQtdLinLote)

If ( File(cLayOut) )
	nHdlLay := FOpen(cLayOut,64)
	While ( lContinua )
		cBuffer := FreadStr(nHdlLay,502)
		If ( !Empty(cBuffer) )
			If ( SubStr(cBuffer,1,1)=="1" )
				If ( SubStr(cBuffer,3,1) == "D" )
					aadd(aLayOut,{ SubStr(cBuffer,02,03),;
					SubStr(cBuffer,05,30),;
					SubStr(cBuffer,35,255)})
				EndIf
			Else
				If ( SubStr(cBuffer,3,1) == "D" )
					aadd(aDetalhe,{SubStr(cBuffer,02,03),;
					SubStr(cBuffer,05,15),;
					SubStr(cBuffer,20,03),;
					SubStr(cBuffer,23,03),;
					SubStr(cBuffer,26,01),;
					SubStr(cBuffer,27,255)})
				EndIf
			EndIf
		Else
			lContinua := .F.
		EndIf
	End
	FClose(nHdlLay)
EndIf

If nHandle > 0
	For nCntFor := 1 To Len(aLayOut)
		Begin Sequence
		lFormula := &(AllTrim(aLayOut[nCntFor,3]))
		If ( lFormula .And. SubStr(aLayOut[nCntFor,1],2,1)=="D" )
			cBuffer := ""
			// So gera outro identificador, caso o titulo ainda nao o tenha, pois pode ser um re-envio do arquivo
			If !Empty(cAlias) .And. lIdCnab .And. Empty((cAlias)->&(Right(cAlias,2)+"_IDCNAB"))
				// Gera identificador do registro CNAB no titulo enviado
				nOrdem := If(Alltrim(Upper(cAlias))=="SE1",16,11)
				cIdCnab := GetSxENum(cAlias, Right(cAlias,2)+"_IDCNAB",Right(cAlias,2)+"_IDCNAB"+cEmpAnt,nOrdem)
				// Garante que o identificador gerado nao existe na base
				dbSelectArea(cAlias)
				aArea := (cAlias)->(GetArea())
				dbSetOrder(nOrdem)
				While (cAlias)->(MsSeek(xFilial(cAlias)+cIdCnab))
					U_SetLogW(@_aLogW,"Id CNAB " + cIdCnab + " j� existe para o arquivo " + cAlias + ". Gerando novo n?mero ")
					//Conout("Id CNAB " + cIdCnab + " j� existe para o arquivo " + cAlias + ". Gerando novo n?mero ")
					If ( __lSx8 )
						ConfirmSX8()
					EndIf
					cIdCnab := GetSxENum(cAlias, Right(cAlias,2)+"_IDCNAB",Right(cAlias,2)+"_IDCNAB"+cEmpAnt,nOrdem)
				EndDo
				(cAlias)->(RestArea(aArea))
				Reclock(cAlias)
				(cAlias)->&(Right(cAlias,2)+"_IDCNAB") := cIdCnab
				MsUnlock()
				ConfirmSx8()
				lIdCnab := .F. // Gera o identificacao do registro CNAB apenas uma vez no
				// titulo enviado
			Endif
			For nCntFor2 := 1 To Len(aDetalhe)
				If ( aDetalhe[nCntFor2,1] == aLayOut[nCntFor,1] )
					xConteudo := aDetalhe[nCntFor2,6]
					If ( Empty(xConteudo) )
						xConteudo := ""
					Else
						xConteudo := &(AllTrim(xConteudo))
					EndIf
					nPosIni   := Val(aDetalhe[nCntFor2,3])
					nPosFim   := Val(aDetalhe[nCntFor2,4])
					nDecimal  := Val(aDetalhe[nCntFor2,5])
					nTamanho  := nPosFim-nPosIni+1
					Do Case
						Case ValType(xConteudo) == "D"
							xConteudo := GravaData(xConteudo,.F.)
						Case ValType(xConteudo) == "N"
							xConteudo := StrZero(xConteudo,nTamanho,nDecimal)
					EndCase
					xConteudo := SubStr(xConteudo,1,nTamanho)
					xConteudo := PadR(xConteudo,nTamanho)
					cBuffer += xConteudo
				EndIf
			Next nCntFor2
			cBuffer += Chr(13)+Chr(10)
			Fwrite(nHandle,cBuffer,Len(cBuffer))
			nQtdLinLote++
			_lGravou := .T.
		EndIf
		End Sequence
	Next nCntFor
	ErrorBlock(bBlock)
Endif

RestArea(aGetArea)

Return( _lGravou )