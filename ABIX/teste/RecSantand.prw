#INCLUDE "PROTHEUS.CH"
#INCLUDE "RECSANT.CH"
#INCLUDE "RWMAKE.CH"

/*                                                                                                                             
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RecSant  � Autor � R.H. 			        � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao do Recibos de Pagamento Eletronico BCO Santander   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER030( void )                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� 		   �14/09/02�------� Inclusao das rotinas de geracao de arqui-���
���            �        �------� vo texto com lay-out definido Santander  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function RecSant()

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais ( Basicas )                            �
//����������������������������������������������������������������
Local cString:="SRA"        // alias do arquivo principal ( Base )

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais ( Programa )                           �
//����������������������������������������������������������������
Local nExtra, cIndCond, cIndRc
Local Baseaux := "S", cDemit := "N"

Local aOfusca		:= IIf(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local aFldRel		:= {"RA_NOME", 'RA_CIC'}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

PRIVATE cMesAnoRef

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt( "CSTRING, BASEAUX" )
SetPrvt( "CDEMIT, ARETURN, NOMEPROG, ALINHA, NLASTKEY, CPERG" )
SetPrvt( "CSEM_DE, CSEM_ATE, ALANCA, APROVE, ADESCO, ABASES" )
SetPrvt( "AINFO, ACODFOL, LI, TITULO, WNREL" )
SetPrvt( "DDATAREF, ESC, SEMANA, CFILDE, CFILATE" )
SetPrvt( "CCCDE, CCCATE, CMATDE, CMATATE, CNOMDE, CNOMATE" )
SetPrvt( "CHAPADE, CHAPAATE, MENSAG1, MENSAG2, MENSAG3, CSITUACAO" )
SetPrvt( "CCATEGORIA, CBASEAUX, CMESANOREF, TAMANHO, LIMITE, AORDBAG" )
SetPrvt( "CMESARQREF, CARQMOV, CALIASMOV, CACESSASR1, CACESSASRA, CACESSASRC" )
SetPrvt( "CACESSASRD, LATUAL, CARQNTX, CINDCOND, ADRIVER, CCOMPAC" )
SetPrvt( "CNORMAL, CINICIO, CFIM, TOTVENC, TOTDESC, FLAG" )
SetPrvt( "CHAVE, DESC_FIL, DESC_END, DESC_CC, DESC_FUNC, DESC_MSG1" )
SetPrvt( "DESC_MSG2, DESC_MSG3, CFILIALANT, CFUNCAOANT, CCCANT, VEZ" )
SetPrvt( "ORDEMZ, NATELIM, NBASEFGTS, NFGTS, NBASEIR, NBASEIRFE" )
SetPrvt( "ORDEM_REL, DESC_CGC, NCONTA, NCONTR, NCONTRT, NLINHAS" )
SetPrvt( "CDET, NCOL, NTERMINA, NCONT, NCONT1, NVALIDOS, NSEQ_, CREG, LCONTINUA" )
SetPrvt( "NVALSAL, DESC_BCO, CCHAVESEM, DESC_PAGA, NPOS, CARRAY, NHDL, CNOMEARQ, NSEQ_" )
SetPrvt( "CDEPTODE, CDEPTOATE", "CROTEIRO", "CPERIODO", "SEMANA", "CPROCESSO", "CTIPOROT", "DDATAPAG", "CCNPJ" )

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private( Basicas )                            �
//����������������������������������������������������������������
Private nomeprog :="RecSant"
Private aLinha   := { }, nLastKey := 0
Private cPerg    := "RecSant"
Private cSem_De  := "  /  /    "
Private cSem_Ate := "  /  /    "

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private( Programa )                           �
//����������������������������������������������������������������
Private aLanca 		:= {}
Private aProve 		:= {}
Private aDesco 		:= {}
Private aBases 		:= {}
Private aInfo  		:= {}
Private aCodFol		:= {}
Private li     		:= 0
Private nHdl   		:= 0
PRIVATE nSeq_  		:= 0
Private Titulo 		:= STR0001 //"GERA��O DE ARQUIVO SANTANDER P/RECIBOS DE PAGAMENTOS"
Private GERAOK
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private cMes 		:= ''
Private cAno 		:= ''
Private aIncons		:= {}
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
VerPerg()
pergunte( cPerg, .F. )

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������
@ 000,000 TO 250,500 DIALOG GERAOK TITLE OemToAnsi(STR0002) //"Gera��o Holerite Eletronico - Bco Santander"

@ 030,010 SAY OemtoAnsi(STR0003) //'Este programa fara a gera��o do arquivo magnetico para envio '
@ 040,010 SAY OemtoAnsi(STR0004) //'ao Banco Santander para disponibiliza��o do Holerite Eletronico '

@ 104,162 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.)
@ 104,190 BMPBUTTON TYPE 2 ACTION Close(GERAOK)
@ 104,218 BMPBUTTON TYPE 1 ACTION GERRImp1()

ACTIVATE DIALOG GERAOK CENTERED


Return


Static Function GERRImp1()

Local aTitulo:={}
//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
cProcesso  := mv_par01	//Processo
cRoteiro   := mv_par02 	//Emitir Recibos(Roteiro)
cPeriodo   := mv_par03 	//Periodo
Semana     := mv_par04 	//Numero da Semana

//Carregar os periodos abertos (aPerAberto) e/ou 
// os periodos fechados (aPerFechado), dependendo 
// do periodo (ou intervalo de periodos) selecionado
RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
				cRoteiro	,; // Roteiro selecionado na Pergunte.
				cPeriodo	,; // Periodo selecionado na Pergunte.
				Semana		,; // Numero de Pagamento selecionado na Pergunte.
				NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
				
// Retorna o mes e o ano do periodo selecionado na pergunte.
AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
			cRoteiro	,; // Roteiro selecionado na Pergunte.
			cPeriodo	,; // Periodo selecionado na Pergunte.
			@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
			@cAno		,; // Retorna o Ano do Processo + Roteiro + Periodo selecionado     
			Semana		 ) // Retorna a Semana do Processo + Roteiro + Periodo selecionado
			
dDataRef := CTOD("01/" + cMes + "/" + cAno)

cFilDe     := mv_par05
cFilAte    := mv_par06
cCcDe      := mv_par07
cCcAte     := mv_par08
cMatDe     := mv_par09
cMatAte    := mv_par10
cNomDe     := mv_par11
cNomAte    := mv_par12
cSituacao  := mv_par13
cCategoria := mv_par14
cNomeArq   := mv_par15
cNum       := ''
lEhIncBDN  := ( MV_PAR16 == 1 )
cMesAnoRef := StrZero( Month( dDataRef ), 2 ) + StrZero( Year( dDataRef ), 4 )
nLoteSubs  := mv_par17
cDeptoDe   := mv_par18
cDeptoAte  := mv_par19
cCNPJ	   := mv_par20
cBancoEmp  := padL(RTRIM(mv_par23),4,"0")
cAgencEmp  := padL(RTRIM(mv_par24),4,"0")
cConvenio  := padL(RTRIM(mv_par22),12,"0")
cContaEmp  := mv_par25
cNomeEmpr  := mv_par21
dDatLibera := mv_par26
cCodRec    := ''
/*
*TIPO PAGAMENTO 
A = 13� PRIMEIRA PARCELA 
B = 13� SEGUNDA PARCELA 
C = 14� SAL�RIO 
D = FOLHA NORMAL PARCIAL 
E = FOLHA NORMAL 
F = PR�MIO 
G = F�RIAS 
H = B�NUS 
I = COMPLEMENTO 
J = ADIANTAMENTO 
K = ANTECIPA��O 
L = COMPROVANTE 1  
M = COMPROVANTE 2 
N = COMPROVANTE 3 
O = COMPROVANTE 4 
P = PAGAMENTO 
Q = GRATIFICA��O 
R = PLR 
S = ABONO SALARIAL 
T = PAGAMENTO PARCIAL  
U = PAGAMENTO NORMAL
 */ 

cTipoRot  :=  PosAlias("SRY",cRoteiro,SRA->RA_FILIAL,"RY_TIPO")
dDataPag  :=  PosAlias("RCH",(cProcesso+cPeriodo+Semana+cRoteiro),SRA->RA_FILIAL,"RCH_DTPAGO")


If cTipoRot == '1'
	cCodRec := 'E'
ElseIf cTipoRot == '2'
	cCodRec := 'J'
ElseIf cTipoRot == '3'
	cCodRec := 'G'
ElseIf cTipoRot == '5' 
	cCodRec := 'A'
ElseIf cTipoRot == '6' 
	cCodRec := 'B'
ElseIf cTipoRot == 'F'
	cCodRec := 'R'
Else
	cCodRec := 'P'
EndIf

Processa({|| GERRImp() },STR0021) //"Processando..."

//Gerar Arquivo
If nHdl > 0
	If fClose( nHdl )
		
		If nSeq_ <> 0 
			
			Aviso( STR0014, STR0005 + AllTrim( AllTrim( cNomeArq ) ) + CRLF + CRLF + ; 
			STR0006 + iif(lEhIncBDN,cNum,nLoteSubs) , {STR0017}, 3 )  // 'AVISO'#'Gerado o arquivo '#'Guarde o n�mero do lote deste arquivo para eventual substitui��o: '# 'OK'
			
			If Len(aIncons) > 0 
				aadd(aTitulo, STR0007 + Titulo) //INCONSIST�NCIAS NA 
				
				Aadd(aIncons,{STR0008			+ CRLF	+; //'Favor analisar as tabelas de composi��o do recibo, pois pode existir inconsist�ncias nas mesmas.'
							  STR0009		   	+ CRLF	+; //SRA - Funcion�rios
							  STR0010 	  		+ CRLF	+; //RCH - Per�odo de Calculos
							  STR0011 			+ CRLF	+; //SRD - Hist�rico de Movimentos
							  STR0012			+ CRLF	+; //SRC - Movimento do Per�odo   
							  STR0013 ,""})  //SRV - Verbas   
				
				fMakeLog(aIncons,aTitulo, Nil,Nil,FunName(),Titulo)
				
			endIf
			
						
		Else
			If fErase( cNomeArq ) == 0
				MsgAlert( STR0015 + AllTrim( AllTrim( cNomeArq ) ) + STR0016) //'N�o existem registros a serem gravados. A gera��o do arquivo '#' foi abortada.'
			Else
				MsgAlert( STR0018 + AllTrim( cNomeArq )+'.' ) //'Ocorreram problemas na tentativa de dele��o do arquivo '
			EndIf
		EndIf
	Else
		MsgAlert( STR0019 + AllTrim( cNomeArq )+'.' ) //'Ocorreram problemas no fechamento do arquivo '
	EndIf
EndIf

Close(GERAOK)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GERRIMP  � Autor � R.H. - Ze Maria       � Data � 14.03.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento Para emissao do Recibo                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R030IMP( lEnd, Wnrel, cString )                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GERRImp()//( lEnd, WnRel, cString, cMesAnoRef )
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais ( Basicas )                            �
//����������������������������������������������������������������
Local lIgual                 //Vari�vel de retorno na compara�ao do SRC
Local cArqNew                //Vari�vel de retorno caso SRC # SX3
Local aOrdBag    	:= {}
Local cArqMov     	:= ""
Local aCodBenef   	:= {}
Local aTInss	  	:= {}
Private alinhaFunc	:= {}
Private nQtdComp   	:= 0
Private nTotRLote  	:= 0
Private lAbortFunc 	:= .F.
Private cQuebraLin 	:= Chr( 13 ) + Chr( 10 )  // Caracteres de Salto de Linha
Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe, nTotVenEmp, nTotDesEmp, nTotLiqEmp


nTotVenEmp := nTotDesEmp := nTotLiqEmp := 0

cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
cAcessaSRD  := &("{ || " + ChkRH("GPER030","SRD","2") + "}")

// Registro Header da Empresa - TIPO 0

aTipo0 := {}
//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
aAdd( aTipo0, { 'TIPO DE REGISTRO                     ', 001, 001,   'N',   1,  0, .F. ,'"0"' } )
aAdd( aTipo0, { 'TIPO TRANSMISS�O                     ', 002, 002,   'C',   1,  0, .T. ,'"E"' } )//ENVIO 
aAdd( aTipo0, { 'NUMERO CONVENIO EMPRESA X BANCO      ', 003, 022,   'C',  20,  0, .T. ,'cBancoEmp + cAgencEmp + cConvenio' } ) //Composto por: Banco+Ag�ncia+conv�nio
aAdd( aTipo0, { 'TIPO ARQUIVO                         ', 023, 023,   'C',   1,  0, .T. ,'iif(lEhIncBDN,"T","S")' } ) // T - CARGA, C - COMPLEMENTO, S - SUBSTITUI��O, A - ALTERA��O, X - EXCLUS�O LOTE, E - EXCLUS�O INDIVIDUAL, D - DISPENSA
aAdd( aTipo0, { 'N�MERO VERS�O                        ', 024, 029,   'N',   6,  0, .T. ,'cNum' } ) // CONTROLE DE SEQUENCIA DO ARQUIVO
aAdd( aTipo0, { 'N�MERO LOTE                          ', 030, 035,   'N',   6,  0, .T. ,'iif(lEhIncBDN,cNum,nLoteSubs)' } ) //TIPO : T e D = NUMERO VERS�O, OUTROS TIPOS: INFORMAR O NUMERO DE VERS�O DO ARQUIVO QUE SER� ALTERADO
aAdd( aTipo0, { 'NOME DA EMPRESA                      ', 036, 082,   'C',  47,  0, .T. ,'Upper(cNomeEmpr)' } )//OBRIGATORIO MAIUSCULAS E SEM ACENTUA��O
aAdd( aTipo0, { 'N�MERO DO CNPJ DA EMPRESA            ', 083, 096,   'N',  14,  0, .T. ,'cCNPJ' } )
aAdd( aTipo0, { 'DATA DE REFERENCIA DO PGTO (AAAAMM)  ', 097, 102,   'N',   6,  0, .T. ,'AnoMes(dDataRef)' } )
aAdd( aTipo0, { 'DATA DE CREDITO ( AAAAMMDD )         ', 103, 110,   'N',   8,  0, .T. ,'Dtos(dDataPag)' } )
aAdd( aTipo0, { 'DATA DE DISPONIBILIZA��O ( AAAAMMDD )', 111, 118,   'N',   8,  0, .T. ,'Dtos(dDatLibera)' } )//DATA DE DISPONIBILIZA��O DOS HOLERITES PARA CONSULTA 
aAdd( aTipo0, { 'DATA DE GERA��O  ( AAAAMMDD )        ', 119, 126,   'N',   8,  0, .T. ,'Dtos(DATE())' } )
aAdd( aTipo0, { 'HORA DE GERA��O  ( HHMMSS )          ', 127, 132,   'N',   6,  0, .T. ,'StrTran(TIME(),":","")' } )
aAdd( aTipo0, { 'CODIGO DO BANCO                      ', 133, 136,   'C',   4,  0, .T. ,'cBancoEmp' } )//DEVE SER 0008, 0033 OU  0353
aAdd( aTipo0, { 'CODIGO DA AGENCIA DA EMPRESA         ', 137, 140,   'C',   4,  0, .T. ,'cAgencEmp' } )//
aAdd( aTipo0, { 'CONTA CORRENTE DA EMPRESA            ', 141, 152,   'C',  12,  0, .T. ,'cContaEmp' } )//
aAdd( aTipo0, { 'TIPO PAGAMENTO                       ', 153, 153,   'C',   1,  0, .T. ,'cCodRec' } ) 
aAdd( aTipo0, { 'FILLER                               ', 154, 400,   'C', 247,  0, .F. ,'Space(247)' } )

// Registro Header do funcion�rio - TIPO 1
aTipo1 := {}
//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
aAdd( aTipo1, { 'TIPO DE REGISTRO                     ', 001, 001,   'N',   1,  0, .T. , '"1"' } )
aAdd( aTipo1, { 'N�MERO CONV�NIO EMPRESA X BANCO      ', 002, 021,   'C',  20,  0, .T. , 'cBancoEmp + cAgencEmp + cConvenio' } )//BANCO + AG�NCIA + CONV�NIO 
aAdd( aTipo1, { 'N�MERO DE MATR�CULA DO FUNCION�RIO   ', 022, 041,   'C',  20,  0, .T. , 'PadL(SRA->RA_MAT,20,"0")' } )
aAdd( aTipo1, { 'N�MERO DO CPF DO FUNCION�RIO         ', 042, 052,   'N',  11,  0, .T. , 'SRA->RA_CIC' } )
aAdd( aTipo1, { 'NOME DO FUNCION�RIO                  ', 053, 099,   'C',  47,  0, .T. , 'UPPER(SRA->RA_NOME)' } )
aAdd( aTipo1, { 'BANCO DO FUNCIONARIO                 ', 100, 103,   'N',   4,  0, .T. , '"0" + Substr( SRA->RA_BCDEPSA, 1, 3 )' } )//DEVE SER 0008, 0033 OU  0353 
aAdd( aTipo1, { 'N�MERO DA AG�NCIA DO FUNCION�RIO     ', 104, 107,   'N',   4,  0, .T. , 'Substr( SRA->RA_BCDEPSA, 4, 4 )' } )
aAdd( aTipo1, { 'N�MERO DA CONTA DO FUNCION�RIO       ', 108, 119,   'N',  12,  0, .T. , 'cCtaFunc+cDgCtaFunc' } )
aAdd( aTipo1, { 'CABE�ALHO D�BITO                     ', 120, 154,   'C',  35,  0, .T. , '"DESCONTOS"' } )// 
aAdd( aTipo1, { 'CABE�ALHO CR�DITO                    ', 155, 189,   'C',  35,  0, .T. , '"PROVENTOS"' } )// 
aAdd( aTipo1, { 'CABE�ALHO L�QUIDO                    ', 190, 224,   'C',  35,  0, .T. , '"LIQUIDO A RECEBER"' } )//
aAdd( aTipo1, { 'BLOQUEIO DE VISUALIZA��O L�QUIDO     ', 225, 225,   'C',   1,  0, .F. , '" "' } )// VAZIO - N�O BLOQUEIA, S -  SOMENTE ESSE, D - TODOS, A - DEFAZ   
aAdd( aTipo1, { 'FILLER                               ', 226, 240,   'C',  15,  0, .F. , '  ' } )
aAdd( aTipo1, { 'FILLER                               ', 241, 252,   'N',  12,  0, .F. , '  ' } )
aAdd( aTipo1, { 'CARGO DO FUNCION�RIO                 ', 253, 267,   'C',  15,  0, .F. , 'GetAdvFVal( "SRJ", "RJ_DESC", xFilial( "SRJ" )+SRA->RA_CODFUNC, 1, "" )' } )
aAdd( aTipo1, { 'INDICADOR DE MATR�CULA               ', 268, 268,   'C',   1,  0, .T. , '"N"' } ) // S - FUNCION�RIO POSSUI MAIS DE UMA MATRICULA, N OU VAZIO - POSSUI SOMENTE UMA MATRICULA
aAdd( aTipo1, { 'FILLER                               ', 269, 400,   'C', 132,  0, .F. , 'Space(132)' } )

// Registro Detalhes do Comprovante - TIPO 2
aTipo2 := {}
//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
aAdd( aTipo2, { 'TIPO DE REGISTRO                     ', 001, 001,   'N',   1,  0, .T. , '"2"' } )
aAdd( aTipo2, { 'N�MERO DE MATR�CULA DO FUNCION�RIO   ', 002, 021,   'C',  20,  0, .T. , 'padL(SRA->RA_MAT,20,"0")' } )
aAdd( aTipo2, { 'SEQUENCIA DO LAN�AMENTO              ', 022, 024,   'N',   3,  0, .T. , 'nSeqLanc' } )
aAdd( aTipo2, { 'C�DIGO DE LAN�AMENTO                 ', 025, 031,   'C',   7,  0, .T. , 'StrZero(Val(cCodLan),7)' } )
aAdd( aTipo2, { 'DESCRI��O DE LAN�AMENTO              ', 032, 054,   'C',  23,  0, .T. , 'UPPER(cDescLan)' } )
aAdd( aTipo2, { 'FILLER                               ', 055, 057,   'C',   3,  0, .F. , '  ' } )
aAdd( aTipo2, { 'VALOR DO LAN�AMENTO                  ', 058, 066,   'N',   9,  2, .T. , 'nValLan' } )
aAdd( aTipo2, { 'LAN�AMENTO (INTERNET BANKING)        ', 067, 146,   'C',  80,  0, .T. , 'cDescLan' } )
aAdd( aTipo2, { 'TIPO DE LAN�AMENTO                   ', 147, 147,   'C',   1,  0, .T. , 'cIdLan' } ) // D - D�BITO, C - CR�DITO 
aAdd( aTipo2, { 'UNIDADE DE TRABALHO                  ', 148, 156,   'C',   9,  0, .F. , 'cTipoLan' } ) // HORAS, DIAS OU VALOR
aAdd( aTipo2, { 'QUANTIDADE DA UNIDADE DE TRABALHO    ', 157, 161,   'N',   5,  0, .F. , 'nQtdLan' } ) // 
aAdd( aTipo2, { 'FILLER                               ', 162, 162,   'C',   1,  0, .F. , '  ' } )
aAdd( aTipo2, { 'PRIVADO BANCO                        ', 163, 170,   'C',   8,  0, .T. , '"00010101"' } )
aAdd( aTipo2, { 'PRIVADO BANCO                        ', 171, 178,   'C',   8,  0, .T. , '"00010101"' } )
aAdd( aTipo2, { 'FILLER                               ', 179, 400,   'C', 222,  0, .F. ,'Space(222)' } )

// Registro Trailer do funcion�rio TIPO 3
aTipo3 := {}
//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
aAdd( aTipo3, { 'TIPO DE REGISTRO                     ', 001, 001,   'N',   1,  0, .T. , '"3"' } )
aAdd( aTipo3, { 'N�MERO DE MATR�CULA DO FUNCION�RIO   ', 002, 021,   'C',  20,  0, .T. , 'PadL(SRA->RA_MAT,20,"0")' } )
aAdd( aTipo3, { 'TOTAL D�BITO FUNCION�RIO             ', 022, 036,   'N',  15,  2, .F. , 'TOTDESC' } )
aAdd( aTipo3, { 'TOTAL CR�DITO FUNCION�RIO            ', 037, 051,   'N',  15,  2, .F. , 'TOTVENC' } )
aAdd( aTipo3, { 'TOTAL L�QUIDO FUNCION�RIO            ', 052, 066,   'N',  15,  2, .F. , 'TOTVENC-TOTDESC' } )
aAdd( aTipo3, { 'QUANTIDADE DE LAN�AMENTOS FUNCION�RIO', 067, 076,   'N',  10,  0, .T. , 'nQtdComp' } )
aAdd( aTipo3, { 'BASE IRRF                            ', 077, 085,   'C',   9,  0, .T. , '"BASE IRRF"' } )
aAdd( aTipo3, { 'VALOR BASE IRRF                      ', 086, 095,   'X',  10,  0, .T. , 'TRANSFORM(nBaseIr, "@E 999,999.99")' } )//Dever� conter (exemplo �999.999,99�) Alinhar � direita, com preenchimento de espa�os n�o utilizados com brancos a esquerda.
aAdd( aTipo3, { 'FILLER                               ', 096, 104,   'C',   9,  0, .F. , '  ' } )
aAdd( aTipo3, { 'BASE INSS                            ', 105, 113,   'C',   9,  0, .T. , '"BASE INSS"' } )
aAdd( aTipo3, { 'VALOR BASE INSS                      ', 114, 123,   'X',  10,  0, .T. , 'TRANSFORM(nAteLim, "@E 999,999.99")' } )//Dever� conter (exemplo �999.999,99�) Alinhar � direita, com preenchimento de espa�os n�o utilizados com brancos a esquerda.
aAdd( aTipo3, { 'BASE FGTS                            ', 124, 132,   'C',   9,  0, .T. , '"BASE FGTS"' } )
aAdd( aTipo3, { 'VALOR BASE FGTS                      ', 133, 142,   'X',  10,  0, .T. , 'TRANSFORM(nBaseFgts, "@E 999,999.99")' } )//Dever� conter (exemplo �999.999,99�) Alinhar � direita, com preenchimento de espa�os n�o utilizados com brancos a esquerda. 
aAdd( aTipo3, { 'FILLER                               ', 143, 151,   'C',   9,  0, .F. , 'Space(9)' } )
aAdd( aTipo3, { 'FGTS M�S                             ', 152, 160,   'C',   9,  0, .T. , '"FGTS MES "' } )
aAdd( aTipo3, { 'VALOR FGTS M�S                       ', 161, 170,   'X',  10,  0, .T. , 'TRANSFORM(nFgts, "@E 999,999.99")' } )//Dever� conter (exemplo �999.999,99�) Alinhar � direita, com preenchimento de espa�os n�o utilizados com brancos a esquerda. 
aAdd( aTipo3, { 'FILLER                               ', 171, 400,   'C', 230,  0, .F. , 'Space(230)' } )

// Registro Trailer da Empresa - TIPO 9
aTipo9 := {}
//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
aAdd( aTipo9, { 'TIPO DE REGISTRO                     ', 001, 001,   'N',   1,  0, .T. , '"9"' } )
aAdd( aTipo9, { 'N�MERO CONV�NIO EMPRESA X BANCO      ', 002, 021,   'C',  20,  0, .T. , 'cBancoEmp + cAgencEmp + cConvenio' } )//BANCO + AG�NCIA + CONV�NIO 
aAdd( aTipo9, { 'N�MERO DO CNPJ DA EMPRESA            ', 022, 035,   'N',  14,  0, .T. , 'cCNPJ' } )
aAdd( aTipo9, { 'TOTAL D�BITO EMPRESA                 ', 036, 050,   'N',  15,  2, .T. , 'nTotDesEmp' } )
aAdd( aTipo9, { 'TOTAL CR�DITO EMPRESA                ', 051, 065,   'N',  15,  2, .T. , 'nTotVenEmp' } )
aAdd( aTipo9, { 'TOTAL L�QUIDO EMPRESA                ', 066, 080,   'N',  15,  2, .T. , 'nTotLiqEmp' } )
aAdd( aTipo9, { 'TOTAL DE REGISTROS DO ARQUIVO        ', 081, 090,   'N',  10,  0, .T. , 'nTotRLote' } )
aAdd( aTipo9, { 'FILLER                               ', 091, 400,   'C', 310,  0, .F. , '  ' } )

//���������������������������������������������������������������������Ŀ
//� Cria o arquivo texto                                                �
//�����������������������������������������������������������������������

begin sequence

//Verifica se Arquivo Existe
If File( cNomeArq )
	If ( nAviso := Aviso( STR0014 ,STR0022 + AllTrim( cNomeArq ) + STR0023, {'Sim', 'N�o'} ) ) == 1 // 'AVISO'#'Deseja substituir o ' # ' existente ?'
		//Deleta Arquivo
		If fErase( cNomeArq ) <> 0
			MsgAlert( STR0020 + AllTrim( cNomeArq )+'.' ) //'Ocorreram problemas na tentativa de dele��o do arquivo '
			Return NIL
		EndIf
	Else
		Return NIL
	EndIf
EndIf

//Verifica se Nome de Arquivo em Branco
If Empty( cNomeArq )
	MsgAlert( STR0024, STR0025 ) //'Nome do Arquivo nos Parametros em Branco.'#'Aten��o!'
	Return NIL
Else
	//Cria Arquivo
	nHdl := fCreate( cNomeArq )
	nSeq_ := 0
	lContinua := .T.
	
	//Verifica Criacao do Arquivo
	If nHdl == -1
		MsgAlert( STR0027 + AllTrim( cNomeArq )+ STR0026, STR0025 ) //'O arquivo '#' n�o pode ser criado! Verifique os parametros.'#'Aten��o!' 
		Return NIL
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Selecionando a Ordem de impressao escolhida no parametro.    �
//����������������������������������������������������������������
dbSelectArea( "SRA" )
dbSetOrder( 1 )
dbGoTop()

//��������������������������������������������������������������Ŀ
//� Selecionando o Primeiro Registro e montando Filtro.          �
//����������������������������������������������������������������
dbSeek( cFilDe + cMatDe, .T. )
cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
cFim    := cFilAte + cMatAte

//��������������������������������������������������������������Ŀ
//� Carrega Regua Processamento                                  �
//����������������������������������������������������������������
cAliasTMP := "QNRO"
BeginSql alias cAliasTMP
	SELECT COUNT(*) as NROREG
	FROM %table:SRA% SRA
	WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe%   AND %exp:cFilAte% 
		   AND SRA.RA_MAT    BETWEEN %exp:cMatDe%   AND %exp:cMatAte%
		   AND SRA.RA_CC     BETWEEN %exp:cCCDe%    AND %exp:cCCAte% 
		   AND SRA.RA_DEPTO  BETWEEN %exp:cDeptoDe% AND %exp:cDeptoAte% 
		   AND SRA.%notDel%
EndSql                
	
nRegProc := (cAliasTMP)->(NROREG)

( cAliasTMP )->( dbCloseArea() )	

ProcRegua(nRegProc)	// Total de elementos da regua

dbSelectArea("SRA")

TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0

Desc_Fil := Desc_End := DESC_CC:= DESC_FUNC:= ""
DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space( 01 )
cFilialAnt := space(FWGETTAMFILIAL)
cFuncaoAnt := "    "
cCcAnt     := Space( 9 )
Vez        := 0
OrdemZ     := 0

GeraBDN0()
If lEhIncBDN .And. cNum == 'NAOEXISTE'
	MsgAlert( 'Par�metro ES_SEQBDN n�o encontrado. Gentiliza cri�-lo no configurador com o tipo caracter. Descri��o: "Ultimo Sequencial do Arquivo BDN referente ao recibo de pagamento eletr�nico." Valor padr�o: 000000000')
	lContinua := .F.
	BREAK
EndIf

dbSelectArea( "SRA" )
While SRA->(!EOF()) .AND. &cInicio <= cFim
	
	alinhaFunc	:= {}
	lAbortFunc  := .F. 
	nTotLotAux  := nTotRLote
	
	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua Processamento                                �
	//����������������������������������������������������������������

	  IncProc() // Anda a regua
	
	//��������������������������������������������������������������Ŀ
	//� Consiste Parametrizacao do Intervalo de Impressao            �
	//����������������������������������������������������������������
	
	IF	( SRA->RA_NOME < cNomDe )  .OR. ( SRA->Ra_NOME > cNomAte )    .OR. ;
		( SRA->RA_MAT < cMatDe )   .OR. ( SRA->Ra_MAT > cMatAte )     .OR. ;
		( SRA->RA_CC < cCcDe )     .OR. ( SRA->RA_CC > cCcAte )      .Or. ;
		( SRA->RA_DEPTO < cDeptoDe ) .OR. ( SRA->RA_DEPTO > cDeptoAte )
		SRA->( dbSkip( 1 ) )
		Loop
	EndIf
	
	// Se o funcionario nao tiver conta no Santander nao envia
	If !(Subs( SRA->RA_BCDEPSA, 1, 3 ) $ '008/033/353')
		SRA->( dbSkip() )
		Loop
	EndIf
	
	aLanca:={}         // Zera Lancamentos
	aProve:={}         // Zera Lancamentos
	aDesco:={}         // Zera Lancamentos
	aBases:={}         // Zera Lancamentos
	//aVerbHrs:={}
	nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
	
	Ordem_rel := 1     // Ordem dos Recibos
	
	//��������������������������������Ŀ
	//� Verifica Data Demissao         �
	//����������������������������������
	cSitFunc := SRA->RA_SITFOLH
	dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
	If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
		cSitFunc := " "
	Endif	

	//��������������������������������������������������������������Ŀ
	//� Consiste situacao e categoria dos funcionarios			     |
	//����������������������������������������������������������������
		If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
			SRA->(dbSkip())
			Loop
		Endif
		If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
			SRA->(dbSkip())
			Loop
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Consiste controle de acessos e filiais validas				 |
		//����������������������������������������������������������������
	    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			SRA->(dbSkip())
	       Loop
    	EndIf
	
	If SRA->RA_CODFUNC #cFuncaoAnt           // Descricao da Funcao
		DescFun( Sra->Ra_Codfunc, Sra->Ra_Filial )
		cFuncaoAnt:= Sra->Ra_CodFunc
	EndIf
	
	If SRA->RA_CC #cCcAnt                   // Centro de Custo
		DescCC( Sra->Ra_Cc, Sra->Ra_Filial )
		cCcAnt:=SRA->RA_CC
	EndIf
	
	//-Busca o Salario Base do Funcionario
	nSalario := fBuscaSal(dDataRef,,,.F.)
	dbSelectArea( "SRA" )
	If nSalario == 0
		nSalario := SRA->RA_SALARIO
	EndIf

	If SRA->RA_Filial #cFilialAnt
		If ! Fp_CodFol( @aCodFol, Sra->Ra_Filial ) .OR. ! fInfo( @aInfo, Sra->Ra_Filial )
			Exit
		EndIf
		Desc_Fil := aInfo[3]
		Desc_End := aInfo[4]                // Dados da Filial
		Desc_CGC := aInfo[8]
	
		dbSelectArea( "SRA" )
				
		cFilialAnt := SRA->RA_FILIAL
		
	EndIf
	
	Totvenc := Totdesc := 0
	
	//Retorna as verbas do funcionario, de acordo com os periodos selecionados
	aVerbasFunc	:= RetornaVerbasFunc(	SRA->RA_FILIAL					,; // Filial do funcionario corrente
										SRA->RA_MAT	  					,; // Matricula do funcionario corrente
										NIL								,; // 
										cRoteiro	  					,; // Roteiro selecionado na pergunte
										NIL			  					,; // Array com as verbas que dever�o ser listadas. Se NIL retorna todas as verbas.
										aPerAberto	  					,; // Array com os Periodos e Numero de pagamento abertos
										aPerFechado	 	 				 ) // Array com os Periodos e Numero de pagamento fechados
	
	If Len(aVerbasFunc) <= 0
		SRA->( DbSkip() )
		Loop
	EndIf

	//Ordena��o por tipo de verba
	aSort( aVerbasFunc ,,, { |x,y| x[1] + x[2] + Posicione( "SRV", 1, xFilial("SRV",x[1]) + x[3], "RV_TIPOCOD" ) + x[3] < y[1] + y[2] + Posicione( "SRV", 1, xFilial("SRV",y[1]) + y[3], "RV_TIPOCOD" ) + y[3] } )

	DbSelectArea( "SRA" )
		
	GeraBDN1()
	GeraBDN2()
	GeraBDN3()	
	
	if !lAbortFunc
		AEval( alinhaFunc, { | clinhaFunc | FWrite( nHdl, clinhaFunc) } )
	else
		nTotRLote := nTotLotAux
	endIf
	
	dbSelectArea("SRA")
	SRA->( dbSkip() )
	TOTDESC := TOTVENC := 0

EndDo

GeraBDN9()
end sequence

//��������������������������������������������������������������Ŀ
//� Termino do relatorio                                         �
//����������������������������������������������������������������
dbSelectArea( "SRA" )
SET FILTER TO
RetIndex( "SRA" )

If !( Type( "cArqNtx" ) == "U" )
	fErase( cArqNtx + OrdBagExt() )
EndIf

Set Device To Screen

MS_FLUSH()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �  GravaReg    � Autor � Jose Carlos       � Data � 15.09.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Registro                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GravaReg                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraRec                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function GravaReg

If fWrite( nHdl, cReg, Len( cReg ) ) <> Len( cReg )
	If !MsgYesNo( STR0028 + AllTrim( cNomeArq )+ STR0029, STR0025 ) //'Ocorreu um erro na grava��o do arquivo '#'.   Continua?'#'Aten��o!' 
		lContinua := .F.
		Return NIL
	EndIf
EndIf

Return NIL



//Fim do Programa


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � GeraBDN0 �Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de Registro Tipo 0 para hollerith eletronico BDN   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraBDN0()
cNum := GetMV( 'ES_SEQBDN',, 'NAOEXISTE' )

If cNum <> 'NAOEXISTE'
	cNum  := Soma1( cNum )
EndIf

If (cNum <> 'NAOEXISTE' .And. !Empty(cNum)) .Or. !lEhIncBDN
	nSeq_++

	FWrite( nHdl, GeraLinhas( aTipo0 ) )
	nTotRLote++	
EndIf

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � GeraBDN1 �Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de Registro Tipo 1 para hollerith eletronico BDN   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraBDN1()
Local   cAux       := ''
Private cCtaFunc   := ''
Private cDgCtaFunc := ''
Private cNumCP     := ''

cAux       := AllTrim( SRA->RA_CTDEPSA )
cCtaFunc   := SubStr( cAux, 1, Len( cAux  ) - 1 )
cDgCtaFunc := SubStr( cAux, Len( cAux ), 1 )
cNumCP     := StrZero( Val( SRA->RA_NUMCP ), 6 ) + IIF(!Empty(SRA->RA_UFCP), "-" + SRA->RA_UFCP, "" )

nSeq_++
nTotRLote++
Aadd(alinhaFunc,GeraLinhas( aTipo1 ))

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � GeraBDN2 �Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de Registro Tipo 2 para hollerith eletronico BDN   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �    		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraBDN2()
Local   nI       := 1
Local   aVerbas  := {}
Local   nPos     := 0
Local   nLiquido := 0
Local   lGravou  := .F.
Local   nJ       := 0
Local   nReg


Private cCodLan  := ''
Private cDescLan := ''
Private nValLan  := 0
Private cIdLan   := ''
Private nQtdLan  := 0
Private cTipoLan := ''
Private nSeqLanc := 0

nQtdComp         := 0


if lAbortFunc
	return
endIf
	
For nReg := 1 to Len(aVerbasFunc)
	
	If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD)) .Or.;
	( aVerbasFunc[nReg,7] <= 0 )
		dbSkip()
		Loop
	EndIf
	
	
	cCodLan    := aVerbasFunc[nReg][3]
	cDescLan   := DescPd(aVerbasFunc[nReg][3],Sra->Ra_Filial)
	nQtdLan	   := aVerbasFunc[nReg][6]
	nValLan    := aVerbasFunc[nReg][7]
	nValLan    := aVerbasFunc[nReg][7]
			
	If aVerbasFunc[nReg][4] == 'V'
		cTipoLan = 'VALOR'
	ElseIf  aVerbasFunc[nReg][4] == 'D' 
		cTipoLan = 'DIAS'
	ElseIf  aVerbasFunc[nReg][4] == 'H'
		cTipoLan = 'HORAS'
	EndIf 
		
	//lGravou := .T.
	
	If (aVerbasFunc[nReg,3] $ aCodFol[10,1]+'*'+aCodFol[15,1]+'*'+aCodFol[27,1])
		nBaseIr += aVerbasFunc[nReg,7]
	ElseIf (aVerbasFunc[nReg,3] $ aCodFol[13,1]+'*'+aCodFol[19,1])
		nAteLim += aVerbasFunc[nReg,7]
    // BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
	Elseif aVerbasFunc[nReg,3] $ aCodFol[108,1]+'*'+aCodFol[17,1]+'*'+ aCodFol[337,1]+'*'+aCodFol[398,1]
		nBaseFgts += aVerbasFunc[nReg,7]
	// VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
	Elseif aVerbasFunc[nReg,3] $ aCodFol[109,1]+'*'+aCodFol[18,1]+'*'+aCodFol[339,1]+'*'+aCodFol[400,1]
		nFgts += aVerbasFunc[nReg,7]
	Elseif (aVerbasFunc[nReg,3] == aCodFol[16,1])
		nBaseIrFe += aVerbasFunc[nReg,7]
	Endif	
	
	If PosSrv( cCodLan , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
		cIdLan  := "C"
		TOTVENC += nValLan
	Elseif SRV->RV_TIPOCOD == "2"
		cIdLan  := "D"
		TOTDESC += nValLan
	Else
		Loop
	Endif
	
	nSeqLanc++
	Aadd(alinhaFunc,GeraLinhas( aTipo2 ))
	nQtdComp++
	nTotRLote++
Next nReg

nTotVenEmp += TOTVENC
nTotDesEmp += TOTDESC
nTotLiqEmp += (TOTVENC - TOTDESC)

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � GeraBDN3 �Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de Registro Tipo 3 para hollerith eletronico BDN   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraBDN3()

if lAbortFunc
	return
endIf

nSeq_++
Aadd(alinhaFunc,GeraLinhas( aTipo3 ))
nQtdComp++
nTotRLote++

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � GeraBDN9 �Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de Registro Tipo 9 para hollerith eletronico BDN   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraBDN9()
nSeq_++
nTotRLote++
FWrite( nHdl, GeraLinhas( aTipo9 ,.T. ))

PutMV( 'ES_SEQBDN', cNum  )

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Geralinhas�Autor  � Ernani Forastieri  � Data �  25/08/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Geracao de linhas de texto                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �			                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraLinhas( aTipo, lTot )
Local cLinha     	:= ''
Local nTamMaxLin 	:= 250
Local nI         	:= 0
local cNomCampo		:= ""
Default lTot		:= .F. 
For nI := 1 To Len( aTipo )

	bAux      := &( '{ || ' + aTipo[nI][8] + ' } ' )
	
	cTipo     := aTipo[nI][4]
	nTamanho  := aTipo[nI][5]
	nDecimal  := aTipo[nI][6]
	lObrigat  := aTipo[nI][7]
	cNomCampo := aTipo[nI][1]
	
	uConteudo := EVal( bAux )
	uConteudo := IIf( ValType( uConteudo ) == 'U' , '', EverChar( uConteudo ) )
	
	If     cTipo == 'C' .AND. (!lObrigat .OR. !empty(uConteudo))
			uConteudo := PADR( FwNoAccent(SubStr( AllTrim( uConteudo ), 1, nTamanho )), nTamanho )
	ElseIf cTipo == 'N' .AND. (!lObrigat .OR. Val(uConteudo) >= 0)
			uConteudo := StrZero( Val( uConteudo ) * (10^nDecimal) , nTamanho )
	ElseIf cTipo == 'X' .AND. (!lObrigat .OR. !empty(uConteudo))
			uConteudo := PADL( SubStr( AllTrim( uConteudo ), 1, nTamanho ), nTamanho )
	Else
		If lTot
			Aadd(aIncons,{STR0031 + cNomCampo + STR0030 ,""}) //'O Campo '#'� obrigatorio por�m esta vazio ou menor que zero.'
		Else
			Aadd(aIncons,{STR0031 + cNomCampo + STR0032 + SRA->RA_FILIAL + ' - ' + SRA->RA_MAT   + STR0030,""}) //'O Campo '#' do funcion�rio '#' � obrigatorio por�m esta vazio ou menor que zero.'
		EndIf
		lAbortFunc := .T.
		return cLinha
	EndIf
	
	cLinha += uConteudo
	
Next

cLinha += Replicate( ' ', nTamMaxLin - Len( cLinha ) ) + cQuebraLin

Return cLinha                                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � EVERCHAR �Autor  � Ernani Forastieri  � Data �  13/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao auxiliar para transformar um campo de qualquer tipo ���
���          � em caracter                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EverChar( uCpoConver )

Local cRet  := NIL
Local cTipo := ''

cTipo := ValType( uCpoConver )

If     cTipo == 'C'                    // Tipo Caracter
	cRet := uCpoConver
	
ElseIf cTipo == 'N'                    // Tipo Numerico
	cRet := AllTrim( Str( uCpoConver ) )
	
ElseIf cTipo == 'L'                    // Tipo Logico
	cRet := IIf( uCpoConver, '.T.', '.F.' )
	
ElseIf cTipo == 'D'                    // Tipo Data
	cRet := DToC( uCpoConver )
	
ElseIf cTipo == 'M'                    // Tipo Memo
	cRet := 'MEMO'
	
ElseIf cTipo == 'A'                    // Tipo Array
	cRet := 'ARRAY[' + AllTrim( Str( Len( uCpoConver ) ) ) + ']'
	
ElseIf cTipo == 'U'                    // Indefinido
	cRet := 'NIL'
	
EndIf

Return(cRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VerPerg      � Autor �                   � Data � 15.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica as perguntas, Incluindo-as caso n�o existam       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VerPerg()

LOCAL aArea    	:= GetArea()
LOCAL aAreaDic 	:= SX1->( GetArea() )
LOCAL aEstrut  	:= {}
LOCAL aStruDic 	:= SX1->( dbStruct() )
LOCAL aDados	:= {}
LOCAL nXa       := 0
LOCAL nXb       := 0
LOCAL nXc		:= 0
LOCAL nTam1    	:= Len( SX1->X1_GRUPO )
LOCAL nTam2    	:= Len( SX1->X1_ORDEM )
LOCAL lAtuHelp 	:= .F.            
LOCAL aHelp		:= {}	
lOCAL lNaoAchou := .T.

aEstrut := { 'X1_GRUPO'  , 'X1_ORDEM'  , 'X1_PERGUNT', 'X1_PERSPA' , 'X1_PERENG' , 'X1_VARIAVL', 'X1_TIPO'   , ;
             'X1_TAMANHO', 'X1_DECIMAL', 'X1_PRESEL' , 'X1_GSC'    , 'X1_VALID'  , 'X1_VAR01'  , 'X1_DEF01'  , ;
             'X1_DEFSPA1', 'X1_DEFENG1', 'X1_CNT01'  , 'X1_VAR02'  , 'X1_DEF02'  , 'X1_DEFSPA2', 'X1_DEFENG2', ;
             'X1_CNT02'  , 'X1_VAR03'  , 'X1_DEF03'  , 'X1_DEFSPA3', 'X1_DEFENG3', 'X1_CNT03'  , 'X1_VAR04'  , ;
             'X1_DEF04'  , 'X1_DEFSPA4', 'X1_DEFENG4', 'X1_CNT04'  , 'X1_VAR05'  , 'X1_DEF05'  , 'X1_DEFSPA5', ;
             'X1_DEFENG5', 'X1_CNT05'  , 'X1_F3'     , 'X1_PYME'   , 'X1_GRPSXG' , 'X1_HELP'   , 'X1_PICTURE', ;
             'X1_IDFIL'   }

aAdd( aDados, {cPerg, "01", "Processo ?"			 , "�Proceso ?"			 , "Process ?"			 , "mv_ch1", "C", 5						, 0, 0, "G", "Gpr040Valid(mv_par01)"									, "mv_par01", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "RCJ"		, "", ""	, ".RECSANT01."} )
aAdd( aDados, {cPerg, "02", "Roteiro ?"				 , "�Procedimiento ?"	 , "Script ?"			 , "mv_ch2", "C", 3						, 0, 0, "G", "f030Roteiro() .and. Gpr040Roteiro()"						, "mv_par02", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT02."} )
aAdd( aDados, {cPerg, "03", "Periodo ?"				 , "�Periodo ?"			 , "Period ?"			 , "mv_ch3", "C", 6						, 0, 0, "G", "Gpr040Valid(mv_par01 + mv_par02 + mv_par03)"				, "mv_par03", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "RCH"		, "", ""	, ".RECSANT03."} )
aAdd( aDados, {cPerg, "04", "Numero de Pagamento ?"	 , "�Numero de pago ?"	 , "Payment Number ?"	 , "mv_ch4", "C", 2						, 0, 0, "G", "Gpr040Valid(mv_par01 + mv_par02 + mv_par03 + mv_par04)"	, "mv_par04", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT04."} )
aAdd( aDados, {cPerg, "05", "Filial De ?"			 , "�De Filial?"		 , "From Branch ?"		 , "mv_ch5", "C", TamSx3("RA_FILIAL")[1], 0, 0, "G", ""															, "mv_par05", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"		, "", "033"	, ".RECSANT05."} )
aAdd( aDados, {cPerg, "06", "Filial At� ?"			 , "�A Filial?"			 , "To Branch ?"		 , "mv_ch6", "C", TamSx3("RA_FILIAL")[1], 0, 0, "G", "naovazio"													, "mv_par06", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "XM0"		, "", "033"	, ".RECSANT06."} )
aAdd( aDados, {cPerg, "07", "Centro de Custo De ?"	 , "�De Centro de Costo?", "From Cost Center ?"	 , "mv_ch7", "C", TamSx3("CTT_CUSTO")[1], 0, 0, "G", ""															, "mv_par07", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "CTT"		, "", "004"	, ".RECSANT07."} )
aAdd( aDados, {cPerg, "08", "Centro de Custo At� ?"	 , "�A  Centro de Costo?", "To Cost Center ?"	 , "mv_ch8", "C", TamSx3("CTT_CUSTO")[1], 0, 0, "G", "naovazio"													, "mv_par08", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "CTT"		, "", "004"	, ".RECSANT08."} )
aAdd( aDados, {cPerg, "09", "Matricula De ?"		 , "�De Matricula?"		 , "From Registration ?" , "mv_ch9", "C", 6						, 0, 0, "G", ""															, "mv_par09", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"		, "", ""	, ".RECSANT09."} )
aAdd( aDados, {cPerg, "10", "Matricula At� ?"		 , "�A  Matricula?"		 , "To Registration ?"	 , "mv_cha", "C", 6						, 0, 0, "G", "naovazio"													, "mv_par10", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SRA"		, "", ""	, ".RECSANT10."} )
aAdd( aDados, {cPerg, "11", "Nome De ?"				 , "�De Nombre?"		 , "From Name ?"		 , "mv_chb", "C", 30					, 0, 0, "G", ""															, "mv_par11", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT11."} )
aAdd( aDados, {cPerg, "12", "Nome At� ?"			 , "�A  Nombre?"		 , "To Name ?"			 , "mv_chc", "C", 30					, 0, 0, "G", "naovazio"													, "mv_par12", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT12."} )
aAdd( aDados, {cPerg, "13", "Situa��es a Imp. ?"	 , "�Situaciones a Imp.?", "Situations to Print?", "mv_chd", "C", 5						, 0, 0, "G", "fSituacao"												, "mv_par13", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT13."} )
aAdd( aDados, {cPerg, "14", "Categorias a Imp. ?"	 , "�Categorias a Imp.?" , "Categories to Print?", "mv_che", "C", 15					, 0, 0, "G", "fCategoria"												, "mv_par14", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT14."} )
aAdd( aDados, {cPerg, "15", "Arquivo de Saida ?"	 , "Arquivo de Saida ?"	 , "Arquivo de Saida?"	 , "mv_chf", "C", 60					, 0, 0, "G", ""															, "mv_par15", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT15."} )
aAdd( aDados, {cPerg, "16", "Operacao p/ BDN?"		 , "�Operacion p/ BDN?"	 , "BDN Operation ?"	 , "mv_chg", "C", 1						, 0, 0, "C", ""															, "mv_par16", "Inclusao", "Inclusao", "Inclusao", "", "", "Substituicao", "Substituicao", "Substituicao", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT16."} )
aAdd( aDados, {cPerg, "17", "Num.Lote Orig.p/Subs.?" , "Num.Lote Orig.p/Sub?", "Num.Lote Orig.p/Sub?", "mv_chh", "C", 6						, 0, 0, "G", ""															, "mv_par17", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT17."} )
aAdd( aDados, {cPerg, "18", "Depto De ?"			 , "Depto De ?"			 , "Depto De ?"			 , "mv_chi", "C", TamSx3("RA_DEPTO")[1]	, 0, 0, "G", ""															, "mv_par18", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SQB"		, "", "025"	, ".RECSANT18."} )
aAdd( aDados, {cPerg, "19", "Depto Ate ?"			 , "Depto Ate ?"		 , "Depto Ate ?"		 , "mv_chj", "C", TamSx3("RA_DEPTO")[1]	, 0, 0, "G", "naovazio"													, "mv_par19", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SQB"		, "", "025"	, ".RECSANT19."} )
aAdd( aDados, {cPerg, "20", "CNPJ da Empresa ?"      , "CNPJ na Empresa ?"   , "CNPJ na Empresa ?"   , "mv_chk", "N", 14					, 0, 0, "G", "naovazio"													, "mv_par20", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT20."} )
aAdd( aDados, {cPerg, "21", "Nome da Empresa?"       , "Nome na Empresa ?"   , "Nome na Empresa ?"   , "mv_chm", "C", 47					, 0, 0, "G", "naovazio"													, "mv_par21", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT21."} )
aAdd( aDados, {cPerg, "22", "Conv�nio ?" 			 , "Conv�nio ?"			 , "Conv�nio ? "    	 , "mv_chn", "C", 12					, 0, 0, "G", ""															, "mv_par22", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT22."} )
aAdd( aDados, {cPerg, "23", "Banco empresa ?  "		 , "Banco empresa ?"	 , "Banco empresa?"		 , "mv_cho", "C", 4						, 0, 0, "G", "(RTRIM(mv_par23)  $ '0008/0033/0353')"									, "mv_par23", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""	, ".RECSANT23.", ""	, ""} )
aAdd( aDados, {cPerg, "24", "Ag�ncia Empresa?" 		 , "Ag�ncia Empresa ?"	 , "Ag�ncia Empresa ?"	 , "mv_chp", "C", 4						, 0, 0, "G", ""															, "mv_par24", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT24."} )
aAdd( aDados, {cPerg, "25", "Conta Empresa ?" 		 , "Conta Empresa ?"	 , "Conta Empresa ?"	 , "mv_chq", "C", 12					, 0, 0, "G", ""															, "mv_par25", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT25."} )
aAdd( aDados, {cPerg, "26", "Data Libera��o ?" 		 , "Data Libera��o ?"	 , "Data Libera��o ?"	 , "mv_chr", "D", 8						, 0, 0, "G", ""															, "mv_par26", ""		, ""		, ""		, "", "", ""			, ""			, ""			, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""		, "", ""	, ".RECSANT26."} )
// Atualizando dicion�rio
//
dbSelectArea( 'SX1' )
SX1->( dbSetOrder( 1 ) )


For nXa := 1 To Len( aDados )
	lNaoAchou :=  !SX1->( dbSeek( PadR( aDados[nXa][1], nTam1 ) + PadR( aDados[nXa][2], nTam2 ) ) )
	lAtuHelp:= .T.
	If lNaoAchou .OR. (!lNaoAchou .and. Empty(SX1->X1_HELP))
		RecLock( 'SX1', lNaoAchou )
		For nXb := 1 To Len( aDados[nXa] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nXb], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nXb] ), aDados[nXa][nXb] ) )
			EndIf
		Next nXb
		MsUnLock()
	EndIf
Next nXa

// Atualiza Helps
/*
IF lAtuHelp        
		
	For nXc:=1 to Len(aHelp)
		PutHelp( 'P.'+cPerg+aHelp[nXc][1]+'.', aHelp[nXc][2], aHelp[nXc][3], aHelp[nXc][4], .T. )
	Next nXc 	
EndIf	
*/
RestArea( aAreaDic )
RestArea( aArea )   

Return




