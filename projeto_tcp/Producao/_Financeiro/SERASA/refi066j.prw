//#INCLUDE "FINR650.CH"
#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"


//Variaveis para tratamento dos Sub-Totais por Ocorrencia
#DEFINE DESPESAS           3
#DEFINE DESCONTOS          4
#DEFINE ABATIMENTOS        5
#DEFINE VALORRECEBIDO      6
#DEFINE JUROS              7
#DEFINE VALORIOF           8
#DEFINE VALORCC            9
#DEFINE VALORORIG          10

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREFI066J  บAutor  ณ Kaique Sousa      บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณATUALIZA REGISTRO COM RETORNO DO PEFIN SERASA E GERA O RELA บฑฑ
ฑฑบ          ณTORIO DE OCORRENCIA.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function REFI066J(_cTipo)

Local oReport

Private _cType	:= ''
Private _cAto	:= ''

Default _cTipo	:= 'A'

//Publica a Variavel de Controle
_cType := _cTipo

oReport	:= ReportDef()

If ValType(oReport) <> 'U'
	oReport:PrintDialog()
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREPORTDEF บAutor  ณ Kaique Sousa      บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIMPRIME O RELATORIO E ATUALIZA STATUS DOS TITULOS PEFIN     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

Local oReport
Local _cExt				:= ''
Local _nExt				:= 0

Public nTamDet			:= 0
Public _cFilRet		:= ''
Public _cArqCfg		:= ''

If _cType = 'A'			//Processa arquivo (envio ou retorno)

	//Busca tamanho do detalhe na configuracao do convenio
	dbSelectArea("ZP6")
	If dbSeek(xFilial("ZP6") + MV_PAR01)
		nTamDet 	:= Iif(Empty (ZP6->ZP6_BYTES), 600, ZP6->ZP6_BYTES)
		ntamDet	+= 2  // Ajusta tamanho do detalhe para leitura do CR (fim de linha)
		_cArqCfg	:= ZP6->ZP6_ARQRET
	Else
		Set Device To Screen
		Set Printer To
		Help(" ",1,"X","Atencao","Nใo forma encontrados os parโmetros do conv๊nio" + AllTrim(MV_PAR01),1,1)
		Return( .F. )
	Endif
	
	//Arquivo de Configuracao do Retorno
	IF !FILE(_cArqCfg)
		Set Device To Screen
		Set Printer To
		Help(" ",1,"X","Atencao","Arquivo de configura็ใo " + AllTrim(_cArqCfg) + " nใo encontrado !",1,1)
		Return .F.
	EndIF
	
	//Obtem a extensao do arquivo de geracao.
	If (_nExt := Rat('.',ZP6->ZP6_ARQGER)) = 0
		_cExt := '.TXT'
	Else
		_cExt := Substr(ZP6->ZP6_ARQGER,_nExt+1,3)
	EndIf
	
	//_cFilRet := cGetFile("Retorno Serasa (*." + ZP6->ZP6_EXTRET + ") |*." + ZP6->ZP6_EXTRET + "|Envio Serasa (*." + _cExt + ") |*." + _cExt + "|Todos (*.*) " + "|*.*","Selecione o arquivo do Serasa Pefin",0,"",.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	_cFilRet := cGetFile("Todos (*.*) " + "|*.*","Selecione o arquivo do Serasa Pefin",0,"",.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
	If Empty(_cFilRet)
		Return( Nil )
	EndIf

	oReport := TReport():New("REFI066J","Arquivo Serasa Pefin","",{|oReport| ReportPrint(oReport)},"Este programa tem como objetivo emitir o relat๓rio baseado"+"no arquivo do Serasa Pefin selecionado, atualizando os registros"+"no cado de arquivo de retorno.")

Else

	oReport := TReport():New("REFI066J","Listagem Serasa Pefin","",{|oReport| ListagPrint(oReport)},"Este programa tem como objetivo listar os registros"+"filtrados no Browse para fins de status do Serasa Pefin")

EndIf

//Secao 0 - Sub Cabecalho do Relatorio
oSection0 := TRSection():New(oReport)
TRCell():New(oSection0,"SEC0_OPER"		,,"Opera็ใo"		,,12,,)
TRCell():New(oSection0,"SEC0_FILE"		,,"Arquivo"			,,70,,)

//Secao 1 - Titulos a Receber
oSection1 := TRSection():New(oReport)
TRCell():New(oSection1,"SEC1_TIT"		,,"No. Titulo"		,,25,,)
TRCell():New(oSection1,"SEC1_CLI"		,,"Cli/For"			,,30,,)
TRCell():New(oSection1,"SEC1_DTOCOR"	,,"Dt.Ocor"			,,10,,)
TRCell():New(oSection1,"SEC1_ACAO"		,,"Acao"				,,22,,)
TRCell():New(oSection1,"SEC1_VORIG"		,,"Vlr Saldo","@E 99,999,999.99",12,,)
TRCell():New(oSection1,"SEC1_NNUM"		,,"Nosso Numero"	,,22,,)
TRCell():New(oSection1,"SEC1_OCOR"		,,"Ocorrencia"		,,45,,)
oSection1:SetHeaderSection(.T.)

//Secao 2 - Subtotais
oSection2 := TRSection():New(oReport)
TRCell():New(oSection2,"STOT_TIT"		,,"Registros",,48,,)
TRCell():New(oSection2,"STOT_VORIG"		,,"Vlr Original","@E 99999,999.99",10,,)
oSection2:SetHeaderSection(.T.)

Return( oReport )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREPORTPRINบAutor  ณ Kaique Sousa      บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIMPRIME O RELATORIO DE RETORNO DO PEFIN SERASA.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportPrint(oReport)

Local oSection0 := oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local oSection2 := oReport:Section(3)

Local nLidos					:= 0
Local lAtu						:= .T.
Local _aOco						:= {}
Local cData						:= ''
Local nTamArq					:= 0
Local nValIof              := 0
Local nHdlBco  	  	  		:= 0
Local nHdlConf 	  			:= 0
Local lRej 						:= .f.

Local lHeader 					:= .f.
Local lTrailler				:= .F.
Local _l1stRead				:= .T.
Local _nI					:= 0
//PRIVATE m_pag , cbtxt , cbcont , li

//Essas variaveis tem que ser private para serem manipuladas
//nos pontos de entrada, assim como eh feito no FINA200
Private nValOrig           := 0
Private nVOrig					:= 0
Private nTit					:= 0
Private cNumTit				:= ''
Private cCliFor				:= ''
Private _nRecno				:= 0
Private dBaixa					:= CtoD('')
Private cNossoNum				:= ''
Private cOcorr					:= ''
Private cDescr					:= ''
Private cOperacao				:= ''
Private cAcao					:= ''

//Arquivo de Retorno propriamente Dito
IF !FILE(_cFilRet)
	Set Device To Screen
	Set Printer To
	Help(" ",1,"X","Atencao","Arquivo de retorno " + AllTrim(_cFilRet) + " nใo encontrado !",1,1)
	Help(" ",1,"NOARQENT")
	Return .F.
Else
	nHdlBco	:= FOPEN(_cFilRet,0+64)
EndIF

//Le arquivo enviado pelo banco =
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

oSection0:Cell("SEC0_OPER"):SetBlock({|| cOperacao})
oSection0:Cell("SEC0_FILE"):SetBlock({|| _cFilRet})

oSection1:Cell("SEC1_TIT"):SetBlock({|| cNumTit})
oSection1:Cell("SEC1_CLI"):SetBlock({|| cCliFor})
oSection1:Cell("SEC1_DTOCOR"):SetBlock({|| dBaixa})
oSection1:Cell("SEC1_ACAO"):SetBlock({|| cAcao})
oSection1:Cell("SEC1_VORIG"):SetBlock({|| nValOrig})
oSection1:Cell("SEC1_NNUM"):SetBlock({|| cNossoNum})
oSection1:Cell("SEC1_OCOR"):SetBlock({|| cDescr})

oSection2:Cell("STOT_TIT"):SetBlock({|| nTit})
oSection2:Cell("STOT_VORIG"):SetBlock({|| nVOrig})

//Totalizador
TRFunction():New (oSection2:Cell("STOT_VORIG"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)

oReport:SetTotalText("TOTAIS DO RELATORIO")
oReport:SetTotalinLine(.F.)

oReport:SetMeter(nTamArq/nTamDet)

While nTamArq-nLidos >= nTamDet
	//Variaveis de Controle das Ocorrencias.
	cDescr		:= ''
	_aOco			:= {}

	If oReport:Cancel() .AND. oReport:Cancel()
		Exit
	EndIf
	
	//Para Modelo 2 - Passo o Handle do arquivo de retorno aberto e o nome do arquivo de configuracao.
	aLeitura := U_XRCNAB2(nHdlBco,_cArqCfg,nTamDet)
	
	If ( Empty(aLeitura[4]) )
		nLidos += nTamDet
		oReport:IncMeter()
		Loop
	Endif
	
	//Definicao das variaveis utilizadas no relatorio
	If _l1stRead
		cData       := aLeitura[01]
		If !Empty(cData)
			cData    := ChangDate(cData,Val(ZP6->ZP6_TIPODT))
			dBaixa   := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y", Len(Substr(cData,5))))
		Else
			dBaixa   := dDataBase
		EndIf
		cOperacao	:= If(aLeitura[5]="E","Envio","Retorno")

		//Sub Cabecalho do Relatorio
		oSection0:Init()
		oSection0:PrintLine()		
		oSection0:Finish()

		oSection1:Init()
		_l1stRead := .F.
	EndIf

	cOco        := aLeitura[02]
	cNossoNum   := aLeitura[03]
	_nRecno		:= aLeitura[04]
	_cAto			:= aLeitura[06]
	cAcao			:= If(aLeitura[06]="I","Inclusใo","Exclusใo")

	// Posiciona no Titulo em Questao retornado pela variavel TITULO (cNumTit)
	SE1->(DbGoTo(_nRecno))

	If SE1->(Recno()) = _nRecno
		cNumTit     := '['+SE1->E1_FILIAL+'] '+SE1->E1_PREFIXO+'/'+cNossoNum+'/'+SE1->E1_PARCELA+'/'+SE1->E1_TIPO
		cCliFor		:= SE1->E1_CLIENTE + '-' + SE1->E1_LOJA + '-' + Substr(Posicione('SA1',1,xFILIAL('SA1')+SE1->(E1_CLIENTE+E1_LOJA),'A1_NOME'),1,20)
		//nValOrig 	:= SE1->E1_VLCRUZ --alterado por marcelo em 20/07/11
		//nValOrig 	:= SE1->E1_SALDO
		If !Empty(SE1->E1_YNF1) 
			dbSelectArea("SF2")
			SF2->(dbSetOrder(8))
			SF2->(DbSeek( xFilial("SF2") + PadR(SubStr(cNossoNum,4,6),TamSX3("F2_NFELETR")[1],'')))
			nValOrig 	:= SF2->F2_VALBRUT
		Else
			nValOrig 	:= SE1->E1_SALDO 
		EndIf
 
		lAtu			:= .T.
		nTit++
		nVOrig  		+= nValOrig
	Else
		lAtu			:= .F.
		cNumTit		:= '* ?? *'
		cCliFor		:= '* ?? *'
		nValOrig		:= 0.00
	Endif

	//Tratamento das Ocorrencias	
	If !Empty(cOco)
		For _nI := 1 To Len(AllTrim(cOco)) Step 3

			cOcorr := Substr(cOco,_nI,3)
		
			If ZP4->(DbSeek(xFilial('ZP4') + cOcorr ))
				cDescr := cOcorr + "-" + ZP4->ZP4_DESCRI
				aAdd( _aOco , cDescr )
			Else
				cDescr := cOcorr + "-Ocorrencia Nใo Identificada"
				aAdd( _aOco , cDescr )
			EndIf

			//Imprime a Linha
			PrintLine(oReport,_nI=1)
		Next _nI
	Else
		If Left(cOperacao,1) = 'R'
			cDescr := cAcao + ' realizada com sucesso !'
		Else
			cDescr := cAcao + ' * Somente enviada (s/retorno) ! *
		EndIf
		PrintLine(oReport,.T.)
	EndIf

	//Atualiza o Status do Registros (soh se for retorno)
	If (Left(cOperacao,1) = 'R') .And. lAtu
		U_REFI060J(SE1->(Recno()),_cAto+If(Empty(_aOco),'Y','N'),{},_cFilRet,_aOco,dBaixa)
	EndIf

	nLidos += nTamDet
	oReport:IncMeter()

EndDo

oSection1:Finish()

//Imprime Subtotais
oSection2:Init()
oSection2:PrintLine()
oSection2:Finish()

//Fecha os Arquivos ASCII =
fClose(nHdlBco)
fClose(nHdlConf)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREPORTPRINบAutor  ณ Kaique Sousa      บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIMPRIME O RELATORIO DE RETORNO DO PEFIN SERASA.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ListagPrint(oReport)

Local oSection0 := oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local oSection2 := oReport:Section(3)

Local nTamArq					:= 0

Local nLidos					:= 0
Local lAtu						:= .T.
Local _aOco						:= {}
Local cData						:= ''
Local nValIof              := 0
Local nHdlBco  	  	  		:= 0
Local nHdlConf 	  			:= 0
Local lRej 						:= .f.

Local lHeader 					:= .f.
Local lTrailler				:= .F.
Local _l1stRead				:= .T.

//Essas variaveis tem que ser private para serem manipuladas
//nos pontos de entrada, assim como eh feito no FINA200
Private nValOrig           := 0
Private nVOrig					:= 0
Private nTit					:= 0
Private cNumTit				:= ''
Private cCliFor				:= ''
Private _nRecno				:= 0
Private dBaixa					:= CtoD('')
Private cNossoNum				:= ''
Private cOcorr					:= ''
Private cDescr					:= ''
Private cOperacao				:= ''
Private cAcao					:= ''

//Define o tamnho do gauge do relatorio
(_cArqTrb)->(DbGoTop())
(_cArqTrb)->(DbEval({|| nTamArq++  }))
(_cArqTrb)->(DbGoTop())

//oSection0:Cell("SEC0_OPER"):SetBlock({|| cOperacao})
//oSection0:Cell("SEC0_FILE"):SetBlock({|| _cFilRet})

oSection1:Cell("SEC1_TIT"):SetBlock({|| cNumTit})
oSection1:Cell("SEC1_CLI"):SetBlock({|| cCliFor})
oSection1:Cell("SEC1_DTOCOR"):SetBlock({|| dBaixa})
oSection1:Cell("SEC1_ACAO"):SetBlock({|| cAcao})
oSection1:Cell("SEC1_VORIG"):SetBlock({|| nValOrig})
oSection1:Cell("SEC1_NNUM"):SetBlock({|| cNossoNum})
oSection1:Cell("SEC1_OCOR"):SetBlock({|| cDescr})

oSection2:Cell("STOT_TIT"):SetBlock({|| nTit})
oSection2:Cell("STOT_VORIG"):SetBlock({|| nVOrig})

//Totalizador
TRFunction():New (oSection2:Cell("STOT_VORIG"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)

oReport:SetTotalText("TOTAIS DO RELATORIO")
oReport:SetTotalinLine(.F.)

oReport:SetMeter(nTamArq)

While (_cArqTrb)->(!Eof())
	
	//Posiciona no Registro Real.
	SE1->(DbGoTo((_cArqTrb)->E1_RECNO))

	//Variaveis de Controle das Ocorrencias.
	cDescr		:= ''
	_aOco			:= {}
	_l1StRead	:= .T.

	If oReport:Cancel() .AND. oReport:Cancel()
		Exit
	EndIf
	
	//If Empty(SE1->E1_STPEFIN) .And. SE1->E1_ACPEFIN <> 'N'		//Nao tem qq informacao de Serasa Pefin
	//	oReport:IncMeter()
	//	SE1->(DbSkip())
	//	Loop
	//Endif
	
	oSection1:Init()

	dBaixa       := If(!Empty(SE1->E1_ODPEFIN),SE1->E1_ODPEFIN,If(!Empty(SE1->E1_DTPEFIN),SE1->E1_DTPEFIN,dDataBase))
	cOco        := AllTrim(SE1->E1_OCPEFIN)
	cNossoNum   := U_PEFINNAT(3)
	
	cAcao := U_S550JMCOR(5,'SE1',3)

	cNumTit     := '['+SE1->E1_FILIAL+'] '+SE1->E1_PREFIXO+'/'+SE1->E1_NUM+'/'+SE1->E1_PARCELA+'/'+SE1->E1_TIPO
	cCliFor		:= SE1->E1_CLIENTE + '-' + SE1->E1_LOJA + '-' + Substr(Posicione('SA1',1,xFILIAL('SA1')+SE1->(E1_CLIENTE+E1_LOJA),'A1_NOME'),1,20)
	//nValOrig 	:= SE1->E1_VLCRUZ --alterado por marcelo em 20/07/11
	nValOrig 	:= SE1->E1_SALDO

	nTit++
	nVOrig  		+= nValOrig

	//Tratamento das Ocorrencias	
	If !Empty(cOco)
		While !Empty(cOco)
			cOcorr := Left(cOco,3)
			
			If (_nI := At('|',cOco)) > 0
				cOco := Substr(cOco,++_nI)
			EndIf
		
			If ZP4->(DbSeek(xFilial('ZP4') + cOcorr ))
				cDescr := cOcorr + "-" + ZP4->ZP4_DESCRI
			Else
				cDescr := cOcorr + "-Ocorrencia Nใo Identificada"
			EndIf

			//Imprime a Linha
			If _l1StRead
				PrintLine(oReport,_l1StRead)
				_l1StRead := .F.
			Else
				PrintLine(oReport,_l1StRead)			
			EndIf
		EndDo
	Else
		If !Empty(SE1->E1_ODPEFIN)
			cDescr := cAcao + ' realizada com sucesso !'
		ElseIf !Empty(SE1->E1_STPEFIN)
			cDescr := cAcao + ' * Somente enviada (s/retorno) ! *
		Else
			cDescr := cAcao
		EndIf
		PrintLine(oReport,.T.)
	EndIf

	oReport:IncMeter()
	(_cArqTrb)->(DbSkip())   

EndDo

oSection1:Finish()

//Imprime Subtotais
oSection2:Init()
oSection2:PrintLine()
oSection2:Finish()

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRINTLINE บAutor  ณ Kaique Sousa      บ Data ณ  06/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFAZ A IMPRESSAO DO DETALHE DO RELATORIO                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PRINTLINE(oReport,lPrint)

Local oSection1 := oReport:Section(2)

If lPrint
	oSection1:Cell("SEC1_TIT"):Show()
	oSection1:Cell("SEC1_CLI"):Show()
	oSection1:Cell("SEC1_OCOR"):Show()
	oSection1:Cell("SEC1_ACAO"):Show()
	oSection1:Cell("SEC1_DTOCOR"):Show()
	oSection1:Cell("SEC1_VORIG"):Show()
	oSection1:Cell("SEC1_NNUM"):Show()
	oSection1:PrintLine()
Else
	oSection1:Cell("SEC1_TIT"):Hide()
	oSection1:Cell("SEC1_CLI"):Hide()
	oSection1:Cell("SEC1_OCOR"):Show()
	oSection1:Cell("SEC1_ACAO"):Hide()
	oSection1:Cell("SEC1_DTOCOR"):Hide()
	oSection1:Cell("SEC1_VORIG"):Hide()
	oSection1:Cell("SEC1_NNUM"):Hide()
	oSection1:PrintLine()
EndIf

Return( .F. )