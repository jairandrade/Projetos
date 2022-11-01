#INCLUDE "Protheus.CH"
#INCLUDE "IMPRCAN.CH"
#INCLUDE "MSOLE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IMPRCAN  � Autor � Desenvolvimento R.H.  � Data � 21.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao Ficha do Candidato                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Imprcan(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Rwmake                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
���C�cero Alves�04/11/16|TWKETY�Ajuste para imprimir a descri��o do curso ���
���            �        |	   �corretamente							  ���
���Isabel N.   �24/05/17�DRHPONTP-479�Ajuste para imprimir agenda conforme���
���            �        �            �filial logada e tabela SQD.         ���
���Oswaldo L   �25/05/17�DRHPONTP-479�Ajuste para imprimir agenda SQD     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function IMPRCAN(aCand)
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais 		                             �
//����������������������������������������������������������������
Local nOpca			:= 	0
Local aSays			:= {}
Local aButtons		:= {}
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"QG_NOME", "QG_DTNASC", "QG_ENDEREC", "QG_COMPLEM", "QG_BITMAP", "QG_CEP", "QG_BAIRRO", "QG_MUNICIP", "QG_ESTADO", "QG_DESCFUN", "QG_PRETSAL", "QG_ULTSAL",;
						"QG_FONE", "QG_FONECEL", "QG_EMAIL", "QG_INDICAD", "QL_DTADMIS", "QL_DTDEMIS"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Default aCand		:= {}

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVATE		                             �
//����������������������������������������������������������������
PRIVATE aReturn := { STR0007, 1,STR0008, 2, 2, 1, "",1 }  //"Zebrado"###"Administra��o"
PRIVATE nomeprog:= "IMPRCAN"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "IMPCAN"
PRIVATE oPrint
PRIVATE lFirst 	:= .F.

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
PRIVATE Titulo  := STR0009 //"FICHA DO CANDIDATO"
PRIVATE cCabec  := ""
PRIVATE AT_PRG  := "IMPRCAN"
PRIVATE wCabec0 := 0       					//NUMERO DE CABECALHOS QUE O PROGRAMA POSSUI. EX.:2//
PRIVATE wCabec1 := ""
PRIVATE CONTFL	:= 1						//CONTA PAGINA
PRIVATE LI		:= 0
PRIVATE nTamanho:= "P" 		                //TAMANHO DO RELATORIO

//����������������������������������������������������������Ŀ
//�Define Variaveis PRIVATE utilizadas para Impressao Grafica�
//������������������������������������������������������������
//VISUALIZACAO DA VARIAVEL NPOS ALTERADO, DEVIDO REINICIALIZACAO DO CONTEUDO AO EXECUTAR UM DBSELECTAREA() OU FIELDPOS().
//HA ALGUMA VARIAVEL NPOS (PUBLICA OU PRIVADA) QUE ESTA REINICIALIZANDO O CONTEUDO, INFLUENCIANDO NA EXIBICAO INCORRETA DA FICHA.
STATIC  nPos	:= 0						//LINHA DE IMPRESSAO DO RELATORIO GRAFICO
PRIVATE cVar    := ""
PRIVATE nLinha	:= 0
PRIVATE cLine	:= ""
Private cFont	:= ""						//FONTES UTILIZADAS NO RELATORIO
Private aFotos	:= {}						//armazena nome  foto

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVATE(Programa)                           �
//����������������������������������������������������������������
PRIVATE cIndCond:= ""
PRIVATE cFor	:= ""
PRIVATE nOrdem  := 0
PRIVATE aInfo 	:= {}
PRIVATE lAchou 	:= .F.

//������������������������������������������������������������������Ŀ
//�Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.�
//��������������������������������������������������������������������
Private oFont07,oFont09, oFont10, oFont10n, oFont11,oFont15, oFont16,oFont18

//<oFont> := TFont():New( <cName>, <nWidth>, <nHeight>, <.from.>,[<.bold.>],<nEscapement>,,<nWeight>,;
// 						  [<.italic.>],[<.underline.>],,,,,, [<oDevice>] )

//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.F.,.F.)
oFont09	:= TFont():New("Tahoma",09,09,,.F.,,,,.F.,.F.)
oFont10	:= TFont():New("Tahoma",10,10,,.F.,,,,.F.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.F.,.F.)
oFont11	:= TFont():New("Tahoma",11,11,,.T.,,,,.F.,.F.)		//Normal s/negrito
oFont15	:= TFont():New("Courier New",15,15,,.T.,,,,.F.,.F.)
oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
oFont18	:= TFont():New("Arial",18,18,,.T.,,,,.F.,.T.)

// Correcao de SX1
ImpAcertSX1()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("IMPCAN",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Filial  De                               �
//� mv_par02        //  Filial  Ate                              �
//� mv_par03        //  Curriculo De                             �
//� mv_par04        //  Curriculo Ate                            �
//� mv_par05        //  Area De                                  �
//� mv_par06        //  Area  Ate                                �
//� mv_par07        //  Nome De                                  �
//� mv_par08        //  Nome Ate                                 �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "IMPRCAN"            //Nome Default do relatorio em Disco


If Len(aCand) == 0	//Pelo menu

	AADD(aSays,OemToAnsi(STR0002) )  //"Ser� impresso de acordo com os parametros solicitados pelo"
	AADD(aSays,OemToAnsi(STR0003) )  //"usuario."

	AADD(aButtons, { 5,.T.,{|| Pergunte("IMPCAN",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}} )
	AADD(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )

	FormBatch( STR0001, aSays, aButtons )	//"Ficha do Candidato"

	If nOpca == 0
		Return Nil
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Ordem do Relatorio                                           �
//����������������������������������������������������������������
nOrdem   := aReturn[8]

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
FilialDe	:= mv_par01
FilialAte	:= mv_par02
CcurriDe 	:= mv_par03
CcurriAte	:= mv_par04
cAreaDe   	:= mv_par05
cAreaAte   	:= mv_par06
NomDe    	:= Upper(mv_par07)
NomAte   	:= Upper(mv_par08)

If nLastKey = 27
	Return
Endif

Titulo := STR0009 	//"FICHA DO CANDIDATO"

RptStatus({|lEnd| ResuImp(@lEnd,aCand)},Titulo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ResuImp  � Autor � Desenvolvimento R.H.  � Data � 21.12.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Folha de Pagamanto                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ResuImp(lEnd,aCand) 			                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        	- A��o do Codelock                            ���
���          � aCand		- Array com codigo dos curriculos.            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RWMAKE                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ResuImp(lEnd,aCand)
Local cAcessaSQG  := &("{ || " + ChkRH("IMPRCAN","SQG","2") + "}")
Local cFilSQG	:= ""

Local nx := 0

//������������������������������������������������������Ŀ
//�Definicao das Ordens de Impressao, onde sera definido �
//�o Inicio e Fim da impressao do Arquivo                �
//��������������������������������������������������������

dbSelectArea( "SQG" )       		//SQG - CADASTRO DE CURRICULO

If Len(aCand) == 0
	If nOrdem == 1
		dbSetOrder(1)
		dbSeek(XFILIAL("SQG",FilialDe) + cCurriDe,.T.)

		cInicio  := "SQG->QG_FILIAL + SQG->QG_CURRIC"	//Ordem de Codigo do Curriculo
		cFim     := FilialAte + cCurriAte

	ElseIf nOrdem == 2
		dbSetOrder(5)
		dbSeek(XFILIAL("SQG",FilialDe) + NomDe,.T.)

		cInicio  := "SQG->QG_FILIAL + SQG->QG_NOME"   	//Ordem de Nome
		cFim     := FilialAte + NomAte

	Endif
EndIf

SetRegua(SQG->(RecCount()))

cFilAnterior := Replicate("!", FWGETTAMFILIAL)
cCcAnt       := "!!!!!!!!!"

//��������������������������������������������������������������Ŀ
//� Se receber parametros (Chamada pela Pesquisa de Candiatos)   �
//����������������������������������������������������������������
If Len(aCand) > 0
	dbSelectArea("SQG")
	dbSetOrder(1)
	For nx := 1 To Len(aCand)
		If dbSeek(xFilial("SQG")+aCand[nx])

			//��������������������������������������������������������������Ŀ
			//� Movimenta Regua de Processamento                             �
			//����������������������������������������������������������������
			IncRegua(STR0011+SQG->QG_FILIAL + " "+STR0017+SQG->QG_CURRIC) //"Filial: "###"Curriculo: "

			If lEnd
				@Prow()+1,0 PSAY cCancel
				Exit
			Endif

			lAchou:= .T.

			wCabec1 :=Titulo //"FICHA DO CANDIDATO"

			CabecGraf()
			ImpGraf()

		EndIf
	Next nx


//��������������������������������������������������������������Ŀ
//� Se nao receber parametros (Chamada pelo menu)		         �
//����������������������������������������������������������������
Else
	dbSelectArea("SQG")
	While !EOF() .And. &cInicio <= cFim

		//��������������������������������������������������������������Ŀ
		//� Movimenta Regua de Processamento                             �
		//����������������������������������������������������������������
		IncProc(STR0011+SQG->QG_FILIAL + " "+STR0017+SQG->QG_CURRIC) //"Filial: "###"Curriculo: "

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		Endif

		//��������������������������������������������������������������Ŀ
		//� Consiste Parametrizacao do Intervalo de Impressao            �
		//����������������������������������������������������������������
		If  ( SQG->QG_CURRIC < CCurriDe )  	.Or. ( SQG->QG_CURRIC > CCurriAte )		.Or. ;
			( SQG->QG_AREA < cAreaDe )     	.Or. ( SQG->QG_AREA > cAreaAte )   		.Or. ;
			( Upper(SQG->QG_NOME) < NomDe )	.Or. ( Upper(SQG->QG_NOME) > NomAte )

			dbSelectArea( "SQG" )
			dbSkip()
			Loop
		Endif

		//��������������������������������������������������������������Ŀ
		//� Consiste controle de acessos e filiais validas               �
		//����������������������������������������������������������������
		If ( !EMPTY(SQG->QG_FILIAL) )
			cFilSQG	:= ALLTRIM(SQG->QG_FILIAL)
		Else
			cFilSQG	:= SQG->QG_FILIAL
		EndIf
		If !(cFilSQG $ fValidFil()) .Or. !Eval(cAcessaSQG)
			dbSelectArea( "SQG" )
			dbSkip()
			Loop
		EndIf

		lAchou:= .T.
		wCabec1 :=Titulo //"FICHA DO CANDIDATO"

		CabecGraf()
		ImpGraf()

		dbSelectarea("SQG")
		dbSkip()

	Enddo

EndIf
Impr(" ","F")

dbSelectArea("SQG")
dbSetOrder(1)
dbGoTop()

If lAchou
	oPrint:Preview()        // Visualiza impressao grafica antes de imprimir
	MS_FLUSH()

	//-- Apaga BMP Foto do Diretorio
	For nx := 1 to Len(aFotos)
		IF File(aFotos[nx])
			fErase( aFotos[nx])
		Endif
	next nx

Else
	Aviso(STR0064, STR0065, {'Ok'})
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CabecGraf � Autor � Desenvolvimento R.H.	� Data � 03.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do CABECALHO Modo Grafico                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
STATIC FUNCTION CabecGraf()

If !lFirst
	lFirst		:= .T.
	oPrint 		:= TMSPrinter():New("FICHA DO CANDIDATO")
	oPrint:SetPortrait()            //Define que a impressao deve ser RETRATO//
Endif

oPrint:StartPage() 			// Inicia uma nova pagina
cFont:=oFont09

//Box Itens
oPrint:Box(035 ,035 ,3000,2350)        //DESENHA O CONTORNO DA FOLHA

oPrint:say (045 ,040 ,(SM0->M0_NOME),cFont)
oPrint:say (045 ,2085,(RPTFOLHA+" "+TRANSFORM(ContFl,'999999')),cFont)
oPrint:say (080 ,040 ,"SIGA / "+nomeprog+"/V."+cVersao+"    ",cFont)
oPrint:say (120 ,800 ,(TRIM(TITULO)),oFont18)
oPrint:say (215 ,040 ,(RPTHORA+" "+TIME()),cFont)
oPrint:say (215 ,2060,(RPTEMISS+" "+DTOC(MSDATE())),cFont)

//������������������������������������������������������������Ŀ
//�Dados Pessoais                                              �
//��������������������������������������������������������������
nPos   := 260

fFoto()

oPrint:line(nPos ,035 ,260 ,2350)					//Linha Horizontal
nPos+=05
oPrint:say (265 ,040 ,STR0023,cFont) 				//Dados Pessoais

nPos+=40
oPrint:line(310 ,035 ,310 ,2350)					//Linha Horizontal

nPos+=50
oPrint:say (nPos ,0500 ,STR0017,cFont) 				//CURRICULO
oPrint:say (nPos ,0750 ,SQG->QG_CURRIC,cFont)
If SQG->(ColumnPos("QG_ACEITE")) > 0
	oPrint:say (nPos, 1500, STR0075, cFont) 		//STR0075 STATUS ACEITE
	oPrint:say (nPos, 1700, STR0076 + If( SQG->QG_ACEITE == "2", STR0078, STR0079), cFont)	//Consentimento
	If !Empty(SQG->QG_ACTRSP)
		oPrint:say (nPos, 2000, STR0077 + If( SQG->QG_ACTRSP == "2", STR0078, STR0079), cFont)	//Responsavel
	EndIf
EndIf

nPos+=50
oPrint:say (nPos ,0500 ,STR0014,cFont)  			//NOME
oPrint:say (nPos ,0750 ,SQG->QG_NOME,cFont)

oPrint:say (nPos ,1500,STR0020,cFont) 				//DATA DE NASCIMENTO
oPrint:say (nPos ,1700,(DtoC(SQG->QG_DTNASC)),cFont)

nPos+=50
oPrint:say (nPos ,0500 ,STR0012,cFont)				//ENDERECO
oPrint:say (nPos ,0750 ,SQG->QG_ENDEREC,oFont09)

oPrint:say (nPos ,1500,STR0015,cFont)				//COMPLEMENTO
oPrint:say (nPos ,1700,SQG->QG_COMPLEM,oFont09)

nPos+=50

IF Empty( cBmpPict := Upper( AllTrim( SQG->QG_BITMAP ) ) )
	oPrint:say (nPos ,0200,STR0071,cFont)			//FOTO
EndIf

oPrint:say (nPos ,0500,STR0019,cFont)				//CEP
oPrint:say (nPos ,0750 ,SQG->QG_CEP,cFont)

oPrint:say (nPos ,1500 ,STR0038,cFont)  			//BAIRRO
oPrint:say (nPos ,1700 ,SQG->QG_BAIRRO,cFont)

nPos+=50
oPrint:say (nPos ,0500,STR0029,cFont)				//MUNICIPIO
oPrint:say (nPos ,0750,(ALLTRIM(SQG->QG_MUNICIP)),cFont)

oPrint:say (nPos ,1500,STR0018,cFont)  				//ESTADO
oPrint:say (nPos ,1700,(ALLTRIM(SQG->QG_ESTADO)),cFont)

nPos+=50
oPrint:say (nPos ,0500 ,STR0039, cFont)	 			//CARGO PRETENDIDO
oPrint:say (nPos ,0750 ,SQG->QG_DESCFUN,cFont)

oPrint:say (nPos ,1500 ,STR0022,cFont)				//PRET.SALARIAL
oPrint:say (nPos ,1700,(Alltrim(TRANSFORM(SQG->QG_PRETSAL,"@E 999,999,999.99"))),cFont)

nPos+=50
oPrint:say (nPos ,0500,STR0040,cFont)				//ULTIMO SALARIO
oPrint:say (nPos ,0750,(Alltrim(TRANSFORM(SQG->QG_ULTSAL,"@E 999,999,999.99"))),cFont)

oPrint:say (nPos ,1500 ,STR0016,cFont)				//Fone
oPrint:say (nPos ,1700 ,ALLTRIM(SQG->QG_FONE),cFont)

If SQG->(FieldPos("QG_FONECEL")) > 0 .And. SQG->(FieldPos("QG_EMAIL")) > 0
	nPos+=50
	oPrint:say (nPos ,0500 	,STR0067,cFont)				//Celular
	oPrint:say (nPos ,0750	,(Alltrim(SQG->QG_FONECEL)),cFont)

	oPrint:say (nPos ,1500	,STR0068,cFont)  			//e-mail
	oPrint:say (nPos ,1700	,(ALLTRIM(SQG->QG_EMAIL)),cFont)
EndIf

If SQG->(FieldPos("QG_FONTE")) > 0 .And. SQG->(FieldPos("QG_INDICAD")) > 0
	nPos+=50
	oPrint:say (nPos ,0500	,STR0069,cFont)  			//Fonte Recrutam.
	oPrint:say (nPos ,0750	,ALLTRIM(SQG->QG_FONTE)+"-"+fDesc("SX5","RT"+SQG->QG_FONTE,"X5DESCRI()",30,,),cFont)

	oPrint:say (nPos ,1500	,OemToAnsi(STR0070),cFont)  			//Indicacao
	oPrint:say (nPos ,1700	,ALLTRIM(SQG->QG_INDICAD),cFont)
EndIf

nPos+=50
oPrint:line(nPos ,035,nPos,2350)
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpGraf  � Autor � Desenvolvimento R.H.	� Data � 03.01.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao Modo Grafico FICHA DO CANDIDATO                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RdMake                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function  ImpGraf()

Local aVagas	:= {}
Local aAux		:= {}
Local i			:= 0
Local nX		:= 0
Local nLi   	:= 0
Local nQuest	:= 0
Local aSaveArea := GetArea()
Local lVaga		:= ( SQR->(FieldPos("QR_VAGA")) > 0 ) .And. ( SQR->(FieldPos("QR_DATA")) > 0 )

Local cVaga		:= ""
Local cVar      := ""
Local cLine     := ""
Local nLinha    := 0
Local nLinhaAux := 0
Local dData     := Ctod("")
Local cQDAlias  := GetNextAlias()
Local cQuery    := ''
//���������������������������������������������������������������������Ŀ
//�EXPERIENCIA PROFISSIONAL                                             �
//�����������������������������������������������������������������������
nLi := Imprcanlin("SQG",1)
If nPos+nLi < 2790 .And. nLi < 2770
	cFont:=oFont09
	nPos+=05
	oPrint:say (nPos ,040 ,STR0041,cFont)	//EXPERIENCIA
	nPos+=40
	oPrint:line(nPos ,035 ,nPos,2350)		//Linha Horizontal
	nPos+=35
Else
	oPrint:EndPage()
	oPrint:StartPage()		// Inicia uma nova pagina
	ContFl++

	CabecGraf()
	cFont:=oFont09
	nPos+=05
	oPrint:say (nPos ,040 ,STR0041,cFont)	//EXPERIENCIA
	nPos+=40
	oPrint:line(nPos ,035 ,nPos,2350)		//Linha Horizontal
	nPos+=35
EndIf

cVar   := MSMM(SQG->QG_EXPER,,,,3)    			//Campo MEMO
nLinha := MlCount(cVar,110)

For i:=1 to nLinha

	cLine := Space(05)+Memoline(cVar,110,i,,.T.)
	If nPos>=2700 .And. Len(cline) >= nPos
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()
	Endif

	nLi := Imprcanlin("SQG",1)
	If nPos+nLi < 2790 .And. nLi < 2770
		oPrint:say (nPos,040 ,cLine,cFont)
		nPos+=50
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()

		cFont:=oFont09
		nPos+=05
		oPrint:say (nPos ,040 ,STR0041,cFont)	//EXPERIENCIA
		nPos+=40
		oPrint:line(nPos ,035 ,nPos,2350)		//Linha Horizontal
		nPos+=35

		oPrint:say (nPos,040 ,cLine,cFont)
		nPos+=50
	EndIf
Next i

//��������������������������������������������������������������Ŀ
//�ANALISE DO CANDIDATO                                          �
//����������������������������������������������������������������
nLi := Imprcanlin("SQG",2)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0026,cFont)	//ANALISE
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
Else
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0026,cFont)				//ANALISE
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=35
EndIf

cVar   := MSMM(SQG->QG_ANALISE,,,,3)      			//Campo MEMO
nLinha := MlCount(cVar,110)

For i := 1 to nLinha
	cLine:= Space(05)+Memoline(cVar,110,i,,.T.)

	nLi := Imprcanlin("SQG",1)
	If nPos+nLi < 2790 .And. nLi < 2770
		oPrint:say(nPos,040 ,cLine,cFont)
	    nPos+=50
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()

		oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
		nPos+=05
		oPrint:say (nPos,040 ,STR0026,cFont)	//ANALISE
		nPos+=40
		oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
		nPos+=35

		oPrint:say (nPos,040 ,cLine,cFont)
		nPos+=50
	EndIf

	If 	nPos>=2800
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()
	Endif
Next i

//������������������������������������������������������������������
//�HISTORICO PROFISSIONAL                                          �
//������������������������������������������������������������������
nLi := Imprcanlin("SQL",3)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0028,cFont)	//HISTORICO PROFISSIONAL
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
Else
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0028,cFont)	//HISTORICO PROFISSIONAL
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
EndIf

dbSelectArea("SQL")							//SQL - HISTORICO PROFISSIONAL
dbSetOrder(1)
dbSeek(xFilial("SQL")+SQG->QG_CURRIC)
While !Eof() .And. xFilial("SQL")+SQL->QL_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC

	nLi := Imprcanlin("SQL",3)
	If nPos+nLi < 2790 .And. nLi < 2770
		oPrint:say(nPos,040,SPACE(05)+STR0010+(SQL->QL_EMPRESA),oFont10)			//"EMPRESA"
   		oPrint:say(nPos,040,SPACE(85)+STR0046+(SQL->QL_FUNCAO),oFont10)			//"FUNCAO"
		oPrint:say(nPos,040,SPACE(155)+STR0044+(Dtoc(SQL->QL_DTADMIS))+" / "+STR0045+(Dtoc(SQL->QL_DTDEMIS)),oFont10)	//"DT.ADM"###"DT.DEMISSA"
		nPos+=50
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()

		oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
		nPos+=05
		oPrint:say (nPos,040 ,STR0028,cFont)	//HISTORICO PROFISSIONAL
		nPos+=40
		oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
		nPos+=35

		oPrint:say(nPos,040,SPACE(05)+STR0010+(SQL->QL_EMPRESA),oFont10)			//"EMPRESA"
		oPrint:say(nPos,040,SPACE(85)+STR0046+(SQL->QL_FUNCAO),oFont10)			//"FUNCAO"
		oPrint:say(nPos,040,SPACE(155)+STR0044+(Dtoc(SQL->QL_DTADMIS))+" / "+STR0045+(Dtoc(SQL->QL_DTDEMIS)),oFont10)	//"DT.ADM"###"DT.DEMISSA"
		nPos+=50
	EndIf

	cVar   := MSMM(SQL->QL_ATIVIDA,,,,3)		//Campo MEMO
	nLinha := MlCount(cVar,110)

	For  i:=1 to nLinha

		If i=1
			nLi := Imprcanlin("SQL",3)
			If nPos+nLi < 2790 .And. nLi < 2770
				cLine:= Space(03)+Memoline(cVar,110,i,,.T.)
				oPrint:say(nPos,040 ,SPACE(05)+STR0030+cLine,cFont)
				nPos+=50
			Else
				oPrint:EndPage()
				oPrint:StartPage() 			// Inicia uma nova pagina
				ContFl++

				CabecGraf()
				cLine:= Space(03)+Memoline(cVar,110,i,,.T.)
				oPrint:say(nPos,040 ,SPACE(05)+STR0030+cLine,cFont)
				nPos+=50
			EndIf
		Else
			nLi := Imprcanlin("SQL",3)
			If nPos+nLi < 2790 .And. nLi < 2770
				cLine:= Space(05)+Memoline(cVar,110,i,,.T.)
				oPrint:say(nPos,200 ,cLine,cFont)
				nPos+=50
			Else
				oPrint:EndPage()
				oPrint:StartPage() 			// Inicia uma nova pagina
				ContFl++
				CabecGraf()

				cLine:= Space(05)+Memoline(cVar,110,i,,.T.)
				oPrint:say(nPos,200 ,cLine,cFont)
		   		nPos+=50
			EndIf
		Endif

		If 	nPos>=2800
			oPrint:EndPage()
			oPrint:StartPage() 			// Inicia uma nova pagina
			ContFl++
			CabecGraf()
		Endif

	Next i

	dbSelectArea("SQL")
	dbSetOrder(1)
	dbSkip()

Enddo

//����������������������������������������������������������������Ŀ
//�CURSOS EXTRACURRICULARES                                        �
//������������������������������������������������������������������
nLi := Imprcanlin("SQM",4)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0034,cFont)	//CURSOS EXTRACURRICULARES
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
Else
	oPrint:EndPage()
	oPrint:StartPage()			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0034,cFont)	//CURSOS EXTRACURRICULARES
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
EndIf

dbSelectArea("SQM")							//SQM - CURSOS DO CURRICULO
dbSetOrder(1)
dbSeek(xFilial("SQM")+SQG->QG_CURRIC)
While !Eof() .And. xFilial("SQM")+SQM->QM_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC

	nLi := Imprcanlin("SQM",4)
	If nPos+nLi < 2790 .And. nLi < 2770
		oPrint:say(nPos,040 ,SPACE(05)+STR0035+(SQM->QM_ENTIDAD),cFont)
		oPrint:say(nPos,040, SPACE(90)+STR0047+": "+(DTOC(SQM->QM_DATA)),cFont)
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()

		oPrint:line(nPos,035 ,nPos,2350) 				//Linha Horizontal
		nPos+=05
		oPrint:say (nPos,040 ,STR0034,cFont)			//CURSOS EXTRACURRICULARES
		nPos+=40
		oPrint:line(nPos,035 ,nPos,2350) 				//Linha Horizontal
		nPos+=35

		oPrint:say(nPos,040 ,SPACE(05)+STR0035+(SQM->QM_ENTIDAD),cFont)
		oPrint:say(nPos,040, SPACE(90)+STR0047+": "+(DTOC(SQM->QM_DATA)),cFont)
	EndIf

	dbSelectArea("SQT")			//SQT - CADASTRO DE CURSOS
	dbSetOrder(1)
	dbSeek(xFilial("SQT")+SQM->QM_CURSO)

	nLi := Imprcanlin("SQM",4)
	If nPos+nLi < 2790 .And. nLi < 2770
		oPrint:say(nPos, 040, SPACE(140) + STR0048 + SQM->QM_CURSO + " - " + SQM->QM_DCURSO, cFont)
		nPos+=50
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()
		oPrint:say(nPos, 040, SPACE(140) + STR0048 + SQM->QM_CURSO + " - " + SQM->QM_DCURSO, cFont)
		nPos+=50
	EndIf

	dbSelectArea("SQM")
	dbSetOrder(1)
	dbSkip()

Enddo
If 	nPos>=2800
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()
EndIf

//���������������������������������������������������������������������������������Ŀ
//�QUALIFICACOES                                                                    �
//�����������������������������������������������������������������������������������
nLi := Imprcanlin("SQI",5)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0024,cFont)	//QUALIFICACOES
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
	oPrint:say (nPos,040 ,SPACE(05)+OemtoAnsi(STR0049),cFont)		//"Grupo"
	oPrint:say (nPos,040 ,SPACE(55)+OemToAnsi(STR0066),cFont)		//"Fator"
	oPrint:say (nPos,040 ,SPACE(125)+OemToAnsi(STR0050),cFont)		//"Grau"
	oPrint:say (nPos,040 ,SPACE(195)+OemToAnsi(STR0047),cFont)		//"Dt. Formacao"
Else
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0024,cFont)	//QUALIFICACOES
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
	oPrint:say (nPos,040 ,SPACE(05)+OemtoAnsi(STR0049),cFont)		//"Grupo"
	oPrint:say (nPos,040 ,SPACE(55)+OemToAnsi(STR0066),cFont)		//"Fator"
	oPrint:say (nPos,040 ,SPACE(125)+OemToAnsi(STR0050),cFont)		//"Grau"
	oPrint:say (nPos,040 ,SPACE(195)+OemToAnsi(STR0047),cFont)		//"Dt. Formacao"
EndIf

dbSelectArea("SQI")	 	//SQI - QUALIFICACAO DO CURRICULO
dbSetOrder(1)
dbSeek(xFilial("SQI")+SQG->QG_CURRIC)
While !Eof() .And. xFilial("SQI")+SQI->QI_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC
	nLi := Imprcanlin("SQI",5)
	If nPos+nLi < 2790 .And. nLi < 2770
		nPos+=50
		oPrint:say(nPos,040,SPACE(05)+SQI->QI_GRUPO+"-"+fDesc("SQ0", SQI->QI_GRUPO , "Q0_DESCRIC", 30),cFont) //Imprime Grupo
		oPrint:say(nPos,040,SPACE(55)+SQI->QI_FATOR+"-")

		cVar     := fDesc("SQ1", SQI->QI_GRUPO+SQI->QI_FATOR , "Q1_DESCSUM")
        nLinha := MlCount(cVar,30)
        For i := 1 to nLinha
        	cLine:= Space(4)+Memoline(cVar,30,i,,.T.)
            oPrint:say(nPos+((i-1)*50),040,SPACE(55)+ cLine,cFont) //Imprime Fator
        Next i
		nLinhaAux := nLinha

		oPrint:say(nPos,040,SPACE(125)+SQI->QI_GRAU+"-")

		cVar := fDesc("SQ2", SQI->QI_GRUPO+SQI->QI_FATOR+SQI->QI_GRAU , "Q2_DESC")
        nLinha := MlCount(cVar,30)
        For i := 1 to nLinha
        	cLine:= Space(4)+Memoline(cVar,30,i,,.T.)
            oPrint:say(nPos+((i-1)*50),040,SPACE(125)+ cLine,cFont) //Imprime Fator
        Next i

		oPrint:say(nPos,040,SPACE(195)+(ALLTRIM(DTOC(SQI->QI_DATA))),cFont)//Imprime Dt. formacao

		nLinha := Max(nLinha,nLinhaAux) - 1

		If nLinha > 0
			nPos+=50*nLinha
		EndIf
	Else
		oPrint:EndPage()
		oPrint:StartPage() 			// Inicia uma nova pagina
		ContFl++
		CabecGraf()

		oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
		nPos+=05
		oPrint:say (nPos,040 ,STR0024,cFont)	//QUALIFICACOES
		nPos+=40
		oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
		nPos+=35
		oPrint:say (nPos,040 ,SPACE(05)+OemtoAnsi(STR0049),cFont)		//"Grupo"
		oPrint:say (nPos,040 ,SPACE(55)+OemToAnsi(STR0066),cFont)		//"Fator"
		oPrint:say (nPos,040 ,SPACE(125)+OemToAnsi(STR0050),cFont)		//"Grau"
		oPrint:say (nPos,040 ,SPACE(195)+OemToAnsi(STR0047),cFont)		//"Dt. Formacao"

		oPrint:say(nPos,040,SPACE(05)+SQI->QI_GRUPO+"-"+fDesc("SQ0", SQI->QI_GRUPO , "Q0_DESCRIC", 30),cFont) //Imprime Grupo
		oPrint:say(nPos,040,SPACE(55)+SQI->QI_FATOR+"-")

		cVar     := fDesc("SQ1", SQI->QI_GRUPO+SQI->QI_FATOR , "Q1_DESCSUM")
        nLinha := MlCount(cVar,30)
        For i := 1 to nLinha
        	cLine:= Space(4)+Memoline(cVar,30,i,,.T.)
            oPrint:say(nPos+((i-1)*50),040,SPACE(55)+ cLine,cFont) //Imprime Fator
        Next i
		nLinhaAux := nLinha

		oPrint:say(nPos,040,SPACE(125)+SQI->QI_GRAU+"-")

		cVar := fDesc("SQ2", SQI->QI_GRUPO+SQI->QI_FATOR+SQI->QI_GRAU , "Q2_DESC")
        nLinha := MlCount(cVar,30)
        For i := 1 to nLinha
        	cLine:= Space(4)+Memoline(cVar,30,i,,.T.)
            oPrint:say(nPos+((i-1)*50),040,SPACE(125)+ cLine,cFont) //Imprime Fator
        Next i

		oPrint:say(nPos,040,SPACE(195)+(ALLTRIM(DTOC(SQI->QI_DATA))),cFont)//Imprime Dt. formacao

		nLinha := Max(nLinha,nLinhaAux) - 1

		If nLinha > 0
			nPos+=50*nLinha
		EndIf
	EndIf

	dbSelectArea("SQI")
	dbSetOrder(1)
	dbSkip()
Enddo

If 	nPos>=2800
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()
EndIf
nPos+=50

//������������������������������������������������������������������������
//�AVALIACAO DO CURRICULO                                                �
//������������������������������������������������������������������������
If 	nPos>=2500
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()
EndIf

nLi := Imprcanlin("SQR",6)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0042,cFont)				//AVALIACAO
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=30

	oPrint:say (nPos,040 ,SPACE(05)+STR0054,cFont)		//TESTE REALIZADO
	oPrint:say (nPos,040 ,SPACE(70)+STR0055,cFont)		//NR.QUESTOES
	oPrint:say (nPos,040 ,SPACE(100)+STR0056,cFont)	//TOTAL PONTOS
	oPrint:say (nPos,040 ,SPACE(130)+STR0057,cFont)	//PONTOS OBTIDOS
	oPrint:say (nPos,040 ,SPACE(160)+STR0058,cFont)	//%ACERTO
	If lVaga
		oPrint:say (nPos,040 ,SPACE(190)+STR0072,cFont)	//VAGA
		oPrint:say (nPos,040 ,SPACE(220)+STR0062,cFont)	//DATA
	EndIf
Else
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0042,cFont)				//AVALIACAO
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
	nPos+=30

	oPrint:say (nPos,040 ,SPACE(05)+STR0054,cFont)		//TESTE REALIZADO
	oPrint:say (nPos,040 ,SPACE(70)+STR0055,cFont)		//NR.QUESTOES
	oPrint:say (nPos,040 ,SPACE(100)+STR0056,cFont)	//TOTAL PONTOS
	oPrint:say (nPos,040 ,SPACE(130)+STR0057,cFont)	//PONTOS OBTIDOS
	oPrint:say (nPos,040 ,SPACE(160)+STR0058,cFont)	//%ACERTO
	If lVaga
		oPrint:say (nPos,040 ,SPACE(190)+STR0072,cFont)	//VAGA
		oPrint:say (nPos,040 ,SPACE(220)+STR0062,cFont)	//DATA
	EndIf
EndIf

dbSelectArea("SQR")				//SQR - AVALIACAO DO CURRICULO
If dbSeek(SQG->QG_FILIAL+SQG->QG_CURRIC)
	cChaveSQR := SQR->QR_FILIAL+SQR->QR_CURRIC
	aTestes := {}
	While !Eof() .And. SQR->QR_FILIAL+SQR->QR_CURRIC == cChaveSQR
		If !lVaga
			If Ascan(aTestes, {|x| x[1]+x[2]+x[3] == ;
			 				SQR->QR_FILIAL+SQR->QR_CURRIC+SQR->QR_TESTE }) == 0
				Aadd(aTestes,{SQR->QR_FILIAL,SQR->QR_CURRIC,SQR->QR_TESTE})
			EndIf
		Else
			If Ascan(aTestes, {|x| x[1]+x[2]+x[3]+X[4]+X[5] == ;
							SQR->QR_FILIAL+SQR->QR_CURRIC+SQR->QR_TESTE+SQR->QR_VAGA+Dtoc(SQR->QR_DATA) }) == 0
				Aadd(aTestes,{SQR->QR_FILIAL,SQR->QR_CURRIC,SQR->QR_TESTE,SQR->QR_VAGA,Dtoc(SQR->QR_DATA)})
			EndIf
		EndIf
		dbSkip()
	EndDo

	If !lVaga
		aTestes := Asort( aTestes,,,{ |x,y| ( x[1]+x[2]+x[3] ) < ( y[1]+y[2]+y[3] ) } )
	Else
		aTestes := Asort( aTestes,,,{ |x,y| ( x[1]+x[2]+x[3]+x[4]+x[5] ) < ( y[1]+y[2]+y[3]+y[4]+y[5] ) } )
	EndIf

	cChave 	:= "SQR->QR_FILIAL+SQR->QR_CURRIC+SQR->QR_TESTE"

	For nx := 1 To Len(aTestes)

		dbSelectArea("SQQ")			//SQQ - TESTE
		dbSetOrder(1)

		nQuest 		:= 0
		cChaveAtu 	:= aTestes[nx][1]+aTestes[nx][2]+aTestes[nx][3]

		dbSelectArea("SQR")
		dbSeek(cChaveAtu)

		nQuest 	:= 0
		While !Eof() .And. &cChave == cChaveAtu
			If lVaga
				If ( (aTestes[nx][4] != SQR->QR_VAGA) .Or. (Ctod(aTestes[nx][5]) != SQR->QR_DATA) )
					dbSkip()
					Loop
				EndIf
			EndIf

			nQuest++
			dbSkip()
		EndDo

		nNrPontos 	:= 0
		nNrPonObt 	:= 0
		nAcerto	  	:= 0

		dbSeek(cChaveAtu)
		While !Eof() .And. &cChave == cChaveAtu
			If lVaga
				If aTestes[nx][4] != SQR->QR_VAGA .Or. Ctod(aTestes[nx][5]) != SQR->QR_DATA
					SQR->( dbSkip() )
					Loop
				EndIf
				cVaga	:= SQR->QR_VAGA
				dData   := SQR->QR_DATA
			EndIf

			dbSelectArea("SQO")				//SQO - CADASTRO DE QUESTOES
			dbSeek(SQR->QR_FILIAL+SQR->QR_QUESTAO)
			nNrPontos+= SQO->QO_PONTOS
			nNrPonObt+= SQO->QO_PONTOS * (SQR->QR_RESULTA/100)

			nAcerto =(nNrPonObt/nNrPontos*100)

			dbSelectArea("SQR")
			dbSkip()
		EndDo

		// Imprime o teste realizado
		nLi := Imprcanlin("SQR",6)
		If nPos+nLi < 2790 .And. nLi < 2770
			nPos+=50

			oPrint:say (nPos,040 ,SPACE(05)+aTestes[nx][3]+"-"+fDesc("SQQ", aTestes[nx][3] ,"QQ_DESCRIC", 30),cFont)//IMPRIME TESTE DO CURRICULO
			oPrint:say (nPos,040 ,SPACE(73)+(STR(nQuest,3)),cFont)    				//NUMERO DE QUESTOES
			oPrint:say (nPos,040 ,SPACE(103)+STR(nNrPontos,7,2),cFont)   			//TOTAL DE PONTOS
			oPrint:say (nPos,040 ,SPACE(133)+STR(nNrPonObt,7,2),cFont)   			//PONTOS OBTIDOS
			oPrint:say (nPos,040 ,SPACE(161)+STR(nAcerto,7,2),cFont)     			//%ACERTO
			If lVaga
				oPrint:say (nPos,040 ,SPACE(191)+cVaga,cFont)     					//VAGA
				oPrint:say (nPos,040 ,SPACE(221)+Dtoc(dData),cFont)    			//DATA
			EndIf
		Else
			oPrint:EndPage()
			oPrint:StartPage() 			// Inicia uma nova pagina
			ContFl++
			CabecGraf()

			oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
			nPos+=05
			oPrint:say (nPos,040 ,STR0042,cFont)				//AVALIACAO
			nPos+=40
			oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
			nPos+=30

			oPrint:say (nPos,040 ,SPACE(05)+STR0054,cFont)		//TESTE REALIZADO
			oPrint:say (nPos,040 ,SPACE(70)+STR0055,cFont)		//NR.QUESTOES
			oPrint:say (nPos,040 ,SPACE(100)+STR0056,cFont)	//TOTAL PONTOS
			oPrint:say (nPos,040 ,SPACE(130)+STR0057,cFont)	//PONTOS OBTIDOS
			oPrint:say (nPos,040 ,SPACE(160)+STR0058,cFont)	//%ACERTO
			If lVaga
				oPrint:say (nPos,040 ,SPACE(190)+STR0072,cFont)	//VAGA
				oPrint:say (nPos,040 ,SPACE(220)+STR0062,cFont)	//DATA
			EndIf


			nPos+=50
			oPrint:say (nPos,040 ,SPACE(05)+SQQ->QQ_TESTE+"-"+SQQ->QQ_DESCRIC,cFont)	//IMPRIME TESTE DO CURRICULO
			oPrint:say (nPos,040 ,SPACE(73)+(STR(nQuest,3)),cFont)    					//NUMERO DE QUESTOES
			oPrint:say (nPos,040 ,SPACE(103)+STR(nNrPontos,7,2),cFont)   				//TOTAL DE PONTOS
			oPrint:say (nPos,040 ,SPACE(133)+STR(nNrPonObt,7,2),cFont)   				//PONTOS OBTIDOS
			oPrint:say (nPos,040 ,SPACE(161)+STR(nAcerto,7,2),cFont)     				//PERCENTUAL DE ACERTO
			If lVaga
				oPrint:say (nPos,040 ,SPACE(191)+cVaga,cFont)     						//VAGA
				oPrint:say (nPos,040 ,SPACE(221)+Dtoc(dData),cFont)    				//DATA
			EndIf
		EndIf

		dbSelectArea("SQR")
	Next nx
EndIf

nPos+=50

//����������������������������������������������������������������Ŀ
//�PERFIL DO CANDIDATO                                             �
//������������������������������������������������������������������
nLi := Imprcanlin("SM6",7)
If nPos+nLi < 2790 .And. nLi < 2770
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0073,cFont)	//CARACTER�STICAS
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
Else
	oPrint:EndPage()
	oPrint:StartPage()			// Inicia uma nova pagina
	ContFl++
	CabecGraf()

	oPrint:line(nPos,035 ,nPos,2350)		//Linha Horizontal
	nPos+=05
	oPrint:say (nPos,040 ,STR0073,cFont)	//CARACTER�STICAS
	nPos+=40
	oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
	nPos+=35
EndIf

DbSelectArea("RS6")

dbSelectArea("SM6")							//SQM - CURSOS DO CURRICULO
dbSetOrder(1)
dbSeek(xFilial("SM6")+SQG->QG_CURRIC)

While SM6->(!Eof() .And. SM6->M6_FILIAL + SM6->M6_CURRIC == xFilial("SM6")+SQG->QG_CURRIC)

	RS6->(DbSeek(xFilial("RS6") + SM6->M6_TIPO))

	If RS6->RS6_INTERN <> "1"
		SM6->(DbSkip())
		Loop
	EndIf

	If RS6->RS6_RESP == "3"
		aAux := QuebraR(Alltrim(SM6->M6_RESP))
		For nX := 1 to Len(aAux)
			If nX == 1
				oPrint:say(nPos,040 ,SPACE(05)+Padr(RS6->RS6_DESC,30)+Space(20)+aAux[nx],cFont)
			Else
				oPrint:say(nPos,040 ,SPACE(60)+aAux[nx],cFont)
			EndIf
			nPos+=50
		Next nX
	ElseIf RS6->RS6_RESP == "1"
		oPrint:say(nPos,040 ,SPACE(05)+Padr(RS6->RS6_DESC,30)+Space(20)+AllTrim(SM6->M6_ALTERNA) + " - " + PosAlias( "RS7" , RS6->RS6_CODIGO + AllTrim(SM6->M6_ALTERNA) , cFilAnt, "RS7_DESC" ),cFont)
		nPos+=50
	Else
		aAux := StrToArray( SM6->M6_ALTERNA , "*")
		oPrint:say(nPos,040 ,SPACE(05)+Padr(RS6->RS6_DESC,30)+Space(20)+STR0074,cFont)//"Caracter�sticas Selecionadas"
		nPos+=50
		For nX := 1 to Len(aAux)
			oPrint:say(nPos,040 ,SPACE(85)+aAux[nX]  + " - " + PosAlias( "RS7" , RS6->RS6_CODIGO + aAux[nX] , cFilAnt, "RS7_DESC" ),cFont)
			nPos+=50
		Next nX
	EndIf

	SM6->(dbSkip())

Enddo
If 	nPos>=2800
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()
EndIf

nPos+=50

//��������������������������������������������������������������������������Ŀ
//�PROCESSO SELETIVO                                                         �
//����������������������������������������������������������������������������
If 	nPos>=2800
	oPrint:EndPage()
	oPrint:StartPage() 			// Inicia uma nova pagina
	ContFl++
	CabecGraf()
EndIf

oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal
nPos+=05
oPrint:say (nPos,040 ,STR0043,cFont)	//PROCESSO SELETIVO
nPos+=40
oPrint:line(nPos,035 ,nPos,2350) 		//Linha Horizontal

cQuery := "SELECT QD.QD_VAGA, QD.QD_FILIAL, QD.QD_CURRIC "
cQuery += "FROM " + RetSqlname('SQD') + " QD "
cQuery += "WHERE QD.QD_CURRIC = '" + SQG->QG_CURRIC + "' "
cQuery += "AND (QD.QD_FILIAL >= '" + FilialDe + "' AND QD.QD_FILIAL <= '" + FilialAte + "' OR QD.QD_FILIAL LIKE '" + AllTrim(SQG->QG_FILIAL) + "%') "
cQuery += "AND QD.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQDAlias,.T.,.T.)

While (cQDAlias)->(!Eof())
	If Ascan(aVagas, {|x| x[1] == (cQDAlias)->(QD_VAGA) .And. x[2] == (cQDAlias)->(QD_FILIAL) }) == 0
		Aadd(aVagas, {(cQDAlias)->(QD_VAGA),(cQDAlias)->(QD_FILIAL)})
	EndIf

	(cQDAlias)->(DbSkip())
End

(cQDAlias)->(DbCloseArea())

For nX := 1 To Len(aVagas)

	dbSelectArea("SQD")
	dbSetOrder(3)
	If dbSeek(aVagas[nx][2]+aVagas[nx][1]+SQG->QG_CURRIC)

		dbSelectArea("SQS")			//SQS - VAGAS
		dbSetOrder(1)
		If dbSeek(SQD->QD_FILIAL+SQD->QD_VAGA)

			//IMPRIME A VAGA
			If nX > 1
				nPos+=40
				oPrint:line(nPos,035 ,nPos,2350) 					//Linha Horizontal
			EndIf
			nPos+=35
			oPrint:say (nPos,040,SPACE(05)+STR0059,cFont)		//Vaga
			oPrint:say (nPos,040 ,SPACE(15)+SQD->QD_VAGA+"-"+SQS->QS_DESCRIC)
		Endif
		nPos+=70
		If 	nPos>=2800
			oPrint:EndPage()
			oPrint:StartPage() 			// Inicia uma nova pagina
			ContFl++
			CabecGraf()
		Endif
		oPrint:say (nPos,040 ,SPACE(05)+STR0060,cFont)  	//ITENS DO PROCESSO
		oPrint:say (nPos,850,STR0061,cFont)     			//Hora
		oPrint:say (nPos,1145,STR0062,cFont)     			//Data
		oPrint:say (nPos,1380,STR0063,cFont)     			//Resultado
		oPrint:say (nPos,1790,STR0036,cFont)				//Teste Realizado

        dbSelectArea("SQD")
        dbSetOrder(3)


		While !Eof() .And. (aVagas[nx][2]+ aVagas[nx][1]+SQG->QG_CURRIC == SQD->QD_FILIAL + SQD->QD_VAGA + SQD->QD_CURRIC )
			//IMPRIME OS TOPICOS DO PROCESSO//
			nPos+=50

			If 	nPos>=2800
				oPrint:EndPage()
				oPrint:StartPage() 			// Inicia uma nova pagina
				ContFl++
				CabecGraf()
			Endif
			oPrint:say (nPos,080 ,SQD->QD_TPPROCE+"-",cFont)		//TITULO DO ITEM DO PROCESSO
			oPrint:say (nPos,140 ,fDesc("SX5","R9"+SQD->QD_TPPROCE,"X5DESCRI()",30,,),cFont)
			oPrint:say (nPos,860 ,SQD->QD_HORA,cFont)       		//HORA DO TESTE
			oPrint:say (nPos,1145,DTOC(SQD->QD_DATA),cFont) 		//DATA DO TESTE
			oPrint:say (nPos,1390,SQD->QD_RESULTA+"-",cFont)		//RESULTADO DO TESTE
			oPrint:say (nPos,1440,fDesc("SX5","RA"+SQD->QD_RESULTA,"X5DESCRI()",30,,),cFont)

			dbSelectArea("SQQ")			//SQQ - TESTE
			dbSeek(SQD->QD_FILIAL+SQD->QD_TESTE)
			oPrint:say (nPos,1795,SQD->QD_TESTE+" - "+SQQ->QQ_DESCRIC,cFont)

			dbSelectArea("SQD")
			dbSetOrder(3)
			dbSkip()
		EndDo
	EndIf
Next nX

//����������������������������������������������������������������������������Ŀ
//�FIM DO RELATORIO                                                            �
//������������������������������������������������������������������������������
oPrint:EndPage()
CONTFL:=1

dbSelectArea("SQD")
dbSetOrder(1)

RestArea(aSaveArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � Imprcanlin   � Autor �Desenvolvimento R.H� Data � 06.03.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checagem do numero de linhas para impressao                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Imprcanlin()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � IMPRCAN  											  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Imprcanlin(cAlias,nTipo)

Local aSaveArea := GetArea()
Local aSaveArea1:= SQG->(GetArea())
Local aSaveArea2:= SQL->(GetArea())
Local aSaveArea3:= SQM->(GetArea())
Local aSaveArea4:= SQI->(GetArea())
Local aSaveArea5:= SQR->(GetArea())
Local aAux		:= {}
Local cFil		:= ""
Local nLi	    := 0
Local cDescDet  := ""

Do Case
    Case cAlias == "SQG"
    	If !Empty(SQG->QG_EXPER) .And. nTipo == 1 //Experiencia Profissional
    		cDescDet := MSMM(SQG->QG_EXPER,,,,3)
			nLi  := MlCount(cVar,110)
		ElseIf !Empty(SQG->QG_ANALISE) .And. nTipo == 2 //Analise
    		cDescDet := MSMM(SQG->QG_ANALISE,,,,3)
			nLi  := MlCount(cVar,110)
		EndIf
	Case cAlias == "SQL" .And. nTipo == 3 //Historico Profissional
		dbSelectArea("SQL")
		dbSetOrder(1)
		cFil:= If(xFilial("SQL") == Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),SQL->QL_FILIAL)
		If dbSeek(xFilial("SQL")+SQG->QG_CURRIC)
			While !Eof() .And. cFil+SQL->QL_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC
				nLi ++
				DbSkip()
			EndDo
		EndIf
	Case cAlias == "SQM" .And. nTipo == 4 //Cursos Extracurriculares
		dbSelectArea("SQM")								//SQM - CURSOS DO CURRICULO
		dbSetOrder(1)
		cFil:= If(xFilial("SQM") == Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),SQM->QM_FILIAL)
		If dbSeek(xFilial("SQM")+SQG->QG_CURRIC)
			While !Eof() .And. cFil+SQM->QM_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC
				nLi ++
				DbSkip()
			EndDo
		EndIf
	Case cAlias == "SQI" .And. nTipo == 5 //Qualificacoes
		dbSelectArea("SQI")
		dbSetOrder(1)
		cFil:= If(xFilial("SQI") == Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),SQI->QI_FILIAL)
		If dbSeek(xFilial("SQI")+SQG->QG_CURRIC)
			While !Eof() .And. cFil+SQI->QI_CURRIC == SQG->QG_FILIAL+SQG->QG_CURRIC
		    	nLi ++
		    	DbSkip()
		    EndDo
		EndIf
	Case cAlias == "SQR" .And. nTipo == 6  //Avaliacao
		dbSelectArea("SQR")
		cFil:= If(xFilial("SQR") == Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),SQR->QR_FILIAL)
		If dbSeek(SQG->QG_FILIAL+SQG->QG_CURRIC)
			cChaveSQR := SQR->QR_FILIAL+SQR->QR_CURRIC
			While !Eof() .And. cFil+SQR->QR_CURRIC == cChaveSQR
				nLi ++
				DbSkip()
			EndDo
		EndIf
	Case cAlias == "SM6" .And. nTipo == 7  //Perfil do Candidato
		DbSelectArea("RS6")
		dbSelectArea("SM6")
		If dbSeek(xFilial("SM6")+SQG->QG_CURRIC)
			While SM6->(!Eof() .And. M6_FILIAL+M6_CURRIC == xFilial("SM6") + SQG->QG_CURRIC)
				RS6->(DbSeek(xFilial("RS6")+SM6->M6_TIPO))
				If RS6->RS6_RESP == "3" .AND. RS6->RS6_INTERN == "1"

					If !empty(SM6->M6_ALTERNA)
						nLi += (Len(SM6->M6_ALTERNA) / 80) +1
					Else
						nLi +=1
					EndIf
				ElseIf RS6->RS6_RESP == "1" .AND. RS6->RS6_INTERN == "1"
					nLi += 2
				ElseIf RS6->RS6_RESP == "2" .AND. RS6->RS6_INTERN == "1"
					aAux := StrToArray( SM6->M6_ALTERNA , "*")
					nLi += Len(aAux)
				EndIf
				DbSkip()
			EndDo
		EndIf
EndCase

RestArea(aSaveArea1)
RestArea(aSaveArea2)
RestArea(aSaveArea3)
RestArea(aSaveArea4)
RestArea(aSaveArea5)
RestArea(aSaveArea)

Return(nLi)



/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � ImpAcertSX1  � Autor � Desenvimento RH  	� Data � 23/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Correcao nas perguntas.					                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � ImpAcertSX1()                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � IMPRCAN  											  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ImpAcertSX1()

Local aSaveArea	:= GetArea()

dbSelectArea("SX1")
dbSetOrder(1)
dbSeek("IMPCAN")
While !Eof() .And. X1_GRUPO == "IMPCAN"
	If ( "FILIAL" $ UPPER(X1_PERGUNT) ) .And. ( "NAOVAZIO" $ UPPER(X1_VALID) )
		RecLock("SX1", .F.)
			X1_VALID := " "
		MsUnlock()
	EndIf
	dbSkip()
EndDo

RestArea(aSaveArea)
Return Nil


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 � fFoto	    � Autor � Desenvimento RH  	� Data � 20/04/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao Foto do Candidato				                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fFoto()                                            		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � IMPRCAN  											  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fFoto()

Local lFile
Local cBmpPict	:= ""
Local cPath		:= GetSrvProfString("Startpath","")
Local oDlg8
Local oBmp
Local cSAlias := Alias()
Local nSRecno := RecNo()
Local nSOrdem := IndexOrd()

/*
��������������������������������������������������������������Ŀ
� Carrega a Foto do Funcionario								   �
����������������������������������������������������������������*/
cBmpPict := Upper( AllTrim( SQG->QG_BITMAP))
cPathPict 	:= ( cPath + cBmpPict+".BMP" )

/*
��������������������������������������������������������������Ŀ
� Para impressao da foto eh necessario abrir um dialogo para   �
� extracao da foto do repositorio.No entanto na impressao,nao  |
� ha a necessidade de visualiza-lo( o dialogo).Por esta razao  �
� ele sera montado nestas coordenadas fora da Tela             �
����������������������������������������������������������������*/
DEFINE MSDIALOG oDlg8   FROM -1000000,-4000000 TO -10000000,-8000000  PIXEL
@ -10000000, -1000000000000 REPOSITORY oBmp SIZE -6000000000, -7000000000 OF oDlg8
	oBmp:LoadBmp(cBmpPict)
	oBmp:Refresh()

	//-- Box com  Foto
	oPrint:Box( 325,60,685, 460 )

	IF !Empty( cBmpPict := Upper( AllTrim( SQG->QG_BITMAP ) ) )
		IF !File( cPathPict)
			lFile:=oBmp:Extract(cBmpPict  ,cPathPict,.F.)
			If lFile

				oPrint:SayBitmap(340,75,cPathPict,370,330) //Linha, Coluna, Largura, Altura

			Endif
		Else

			oPrint:SayBitmap(340,75,cPathPict,370,330)	//Linha, Coluna, Largura, Altura

		EndIF
	EndIF

	aAdd(aFotos,cPathPict)

ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T.,oDlg8:End())

dbselectarea(cSAlias)
dbsetorder(nSOrdem)
dbgoto(nSRecno)
Return


Static Function QuebraR(cTexto)
Local nSpace 	:= 80
Local nTamStr 	:= Len( cTexto )
Local nIniStr 	:= 0
Local aLinhas	:= {}
Local cLinha	:= ""
Local nI		:= 1
Local nTam		:= 0
If nTamStr > nSpace
	nIniStr := 1
	While nTam < nTamStr
    	cLinha := SubStr( cTexto, nIniStr , nSpace )
		aAdd(aLinhas,cLinha)
    	nTam += Len(cLinha)
    	nIniStr += Len(cLinha)
    Enddo
Else
	cLinha += cTexto + Space(nSpace - Len(cTexto) -1)
	aAdd(aLinhas,cLinha)
EndIf

Return aLinhas
