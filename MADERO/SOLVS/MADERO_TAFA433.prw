#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA433.CH"
#Define STR0074 "Apenas eventos com o mesmo tributo podem ser relacionados"
#Define STR0077 "Dicionário Incompatível"
#Define STR0078 "Encerrar"
#Define STR0079 "Visualizar"
#Define STR0080 "Incluir"
#Define STR0081 "Alterar"
#Define STR0082 "Excluir"
#Define STR0083 "É necessário informar a Forma de Tributação para definição das informações a serem exibidas no cadastro."
#Define STR0084 "Forma de Tributação inválida"
#Define STR0085 "Forma de Tributação não informada"
#Define STR0086 "Tributo inválido"
#Define STR0087 "Tributo não informado"
#Define STR0088 "Simulação da Apuração"
#Define STR0090 "Informe os períodos para simulação" 
#Define STR0091 "Simulação da Apuração"
#Define STR0092 "Evento Tributário 1"
#Define STR0093 "Descrição"
#Define STR0094 "Simulação comparativa?"
#Define STR0095 "Evento Tributário 2"
#Define STR0096 "Selecionar Períodos"
#Define STR0097 "Simular"
#Define STR0098 "Fechar"
#Define STR0099 "Código inexistente"
#Define STR0100"Os Eventos devem ter o mesmo tributo."
#Define STR0101 "Início Período"
#Define STR0102 "Fim Período"
#Define STR0103 "Período"
#Define STR0104 "Saldo Apurado"
#Define STR0105 "Períodos"
#Define STR0106 "Evento Tributário"
#Define STR0107 "Simulação"
#Define STR0108 "Detalhamento"
#Define STR0109 "Log da Apuração"
#Define STR0110 "Base de Cálculo"
#Define STR0111 "Lucro Estimado"
#Define STR0112 "Exclusões"
#Define STR0113 "Lucro Real"
#Define STR0114 "Compensação Prejuízo"
#Define STR0116 "Receita Grupo 1"
#Define STR0117 "Receita Grupo 2"
#Define STR0118 "Receita Grupo 3"
#Define STR0119 "Receita Grupo 4"
#Define STR0120 "Demais Receitas"
#Define STR0121 "Receita Alíquota 4"
#Define STR0122 "% Estimado Alíquota 4"
#Define STR0123 "Receita Alíquota 2"
#Define STR0124 "Receita Alíquota 3"
#Define STR0125 "% Estimado Alíquota 3"
#Define STR0126 "% Estimado Alíquota 2"
#Define STR0127 "Receita Alíquota 1"
#Define STR0128 "% Estimado Alíquota 1" 
#Define STR0129 "Saldo Devedor"
#Define STR0130 "Provisão IRPJ"
#Define STR0131 "Valor Imposto"
#Define STR0132 "Deduções"
#Define STR0133 "Imposto Devido no Mês"
#Define STR0134 "Compensações"
#Define STR0135 "Adicionais do Tributo"
#Define STR0136 "Valor Adicional"
#Define STR0138 "Imp. devido meses ant."
#Define STR0139 "Adições por Doação"
#Define STR0140 "Adições"
#Define STR0141 "Resultado Contábil"
#Define STR0142 "Resultado Não Operacional"
#Define STR0143 "Resultado Operacional"
#Define STR0144 "Alíquota"
#Define STR0145 "Número de meses"
#Define STR0146 "Valor Parcela Isenta"
#Define STR0147 "Valor Isento"
#Define STR0148 "Alíquota Adicional"
#Define STR0149 "Valor Adicional"
#Define STR0150 "Dados da Simulação"
#Define STR0151 "Atividade Geral:"
#Define STR0152 "Atividade Rural:"
#Define STR0153 "Apuração:"
#Define STR0154 "Base Atividade Rural"
#Define STR0155 "Base Atividade Geral"
#Define STR0156 "Lucro Real Após Prej."
#Define STR0157 "Base Cálc. Parcial"
#Define STR0158 "Prej. Ativ. Geral"
#Define STR0159 "Prej. Ativ. Rural"
#Define STR0160 "Prej. Comp. na Ativ. Rural"
#Define STR0161 "Prej. Comp. na Ativ. Geral"
#Define STR0162 "Relatório Parte A - Estimativa por balanço"
#Define STR0163 "Relatório Parte B - Estimativa por balanço"
#Define STR0164 "ATENÇÃO"
#Define STR0165 "Status"



//Grupos do Evento Tributário
#DEFINE GRUPO_RESULTADO_OPERACIONAL	 	1		//Resultado Contábil - Operacional
#DEFINE GRUPO_RESULTADO_NAO_OPERACIONAL	2		//Resultado Contábil - Não operacional
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ1	 	 	3		//Receita Bruta - Alíquota 1
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ2	 	 	4		//Receita Bruta - Alíquota 2
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ3	 	 	5		//Receita Bruta - Alíquota 3
#DEFINE GRUPO_RECEITA_BRUTA_ALIQ4			6		//Receita Bruta - Alíquota 4
#DEFINE GRUPO_DEMAIS_RECEITAS	 	 		7		//Demais Receitas
#DEFINE GRUPO_BASE_CALCULO	 				8		//Base de Cálculo
#DEFINE GRUPO_ADICOES_LUCRO		 			9		//Adições do Lucro
#DEFINE GRUPO_ADICOES_DOACAO				10		//Adições por Doação
#DEFINE GRUPO_EXCLUSOES_LUCRO				11		//Exclusões do Lucro
#DEFINE GRUPO_EXCLUSOES_RECEITA				12		//Exclusões da Receita
#DEFINE GRUPO_COMPENSACAO_PREJUIZO			13		//Compensação de Prejuízo
#DEFINE GRUPO_DEDUCOES_TRIBUTO				14		//Deduções do Tributo
#DEFINE GRUPO_COMPENSACAO_TRIBUTO			15		//Compensação do Tributo
#DEFINE GRUPO_ADICIONAIS_TRIBUTO			16		//Adicionais do Tributo
#DEFINE GRUPO_RECEITA_LIQUIDA_ATIVIDA		17		//Receita Líquida p/Atividade
#DEFINE GRUPO_LUCRO_EXPLORACAO				18		//Lucro da Exploração

//Parâmetros do Array de Grupos
#DEFINE PARAM_GRUPO_ID					1
#DEFINE PARAM_GRUPO_NOME					2
#DEFINE PARAM_GRUPO_DESCRICAO			3
#DEFINE PARAM_GRUPO_TIPO					4

//Tipo Grupo
#DEFINE TIPO_GRUPO_BASE_CALCULO			1
#DEFINE TIPO_GRUPO_CALCULO_TRIBUTO		2

//Forma de Tributação
#DEFINE TRIBUTACAO_LUCRO_REAL						'000001'	//Lucro Real
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO		'000002'	//Lucro Real - Estimativa por levantamento de balanço
#DEFINE TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA	'000003'	//Lucro Real - Estimativa por Receita Bruta
#DEFINE TRIBUTACAO_LUCRO_REAL_ATIV_RURAL			'000004'	//Lucro Real - Atividade Rural
#DEFINE TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO			'000005'	//Lucro Real - Lucro da exploração
#DEFINE TRIBUTACAO_LUCRO_PRESUMIDO					'000006'	//Lucro Presumido
#DEFINE TRIBUTACAO_LUCRO_ARBITRADO					'000007'	//Lucro Arbitrado
#DEFINE TRIBUTACAO_IMUNE								'000008'	//Imune
#DEFINE TRIBUTACAO_ISENTA							'000009'	//Isenta

//Origem
#DEFINE ORIGEM_CONTA_CONTABIL		'1'		//Conta Contábil
#DEFINE ORIGEM_LALUR_PARTE_B		'2'		//Lalur - Parte B
#DEFINE ORIGEM_EVENTO_TRIBUTARIO	'3'		//Evento Tributário
#DEFINE ORIGEM_LANCAMENTO_MANUAL	'4'		//Lançamento Manual
#DEFINE ORIGEM_APURACAO				'5'		//Apuração

//Tipo de atividade
#DEFINE ATIVIDADE_ISENCAO				'1'		//Isenção
#DEFINE ATIVIDADE_REDUCAO				'2'		//Redução
#DEFINE ATIVIDADE_DEMAIS_ATIVIDADES	'3'		//Demais Atividades

//Tributos
#DEFINE TRIBUTO_IRPJ		'000019'
#DEFINE TRIBUTO_CSLL		'000018'

//Qualificação PJ
#DEFINE QUALIFICACAO_PJ_EM_GERAL								'01' //Pessoa Jurídica em Geral
#DEFINE QUALIFICACAO_PJ_FINANCEIRO								'02' //Pessoa Jurídica Componente do Sistema Financeiro
#DEFINE QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL		'03' //Sociedades Seguradoras, de Capitalização ou Entidade Aberta de Previdência Complementar

//Efeito na parte B do Lalur
#DEFINE EFEITO_NAO_APLICAVEL				"1" //Não se aplica
#DEFINE EFEITO_CONSTITUIR_SALDO				"2" //Constituir saldo da Conta
#DEFINE EFEITO_BAIXAR_SALDO					"3" //Baixar saldo da Conta
#DEFINE EFEITO_INCLUIR_LANC_AUTOMATICO		"4" //Incluir Lançamento Automático

//Natureza Conta Lalur Parte B
#DEFINE NATUREZA_ADICAO							'1' //Adição
#DEFINE NATUREZA_EXCLUSAO						'2' //Exclusão
#DEFINE NATUREZA_COMPENSACAO_BASE_NEGATIVA	'3' //Compensação de Prejuízo/Base de Cálculo Negativa
#DEFINE NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO	'4' //Dedução/Compensação de Tributo

//Tipo de Operação
#DEFINE OPERACAO_SOMA		'1'
#DEFINE OPERACAO_SUBTRACAO	'2'

//Parâmetros do Array da Simulação
#DEFINE PARAM_SIMUL_MODEL_EVENTO	1
#DEFINE PARAM_SIMUL_LISTA_PAR		2
#DEFINE LISTA_PAR_MODEL_PERIODO		1
#DEFINE LISTA_PAR_ARRAY_PARAMETRO	2
#DEFINE LISTA_PAR_LOG_PERIODO		3
#DEFINE LISTA_PAR_ARRAY_PAR_RURAL	4

//Parâmetros Apuração
/*
Todos os Defines dos Grupos do Evento Tributário

GRUPO_RESULTADO_OPERACIONAL			1	//Resultado Contábil - Operacional
GRUPO_RESULTADO_NAO_OPERACIONAL		2	//Resultado Contábil - Não Operacional
GRUPO_RECEITA_BRUTA_ALIQ1			3	//Receita Bruta - Alíquota 1
GRUPO_RECEITA_BRUTA_ALIQ2			4	//Receita Bruta - Alíquota 2
GRUPO_RECEITA_BRUTA_ALIQ3			5	//Receita Bruta - Alíquota 3
GRUPO_RECEITA_BRUTA_ALIQ4			6	//Receita Bruta - Alíquota 4
GRUPO_DEMAIS_RECEITAS				7	//Demais Receitas
GRUPO_BASE_CALCULO					8	//Base de Cálculo
GRUPO_ADICOES_LUCRO					9	//Adições do Lucro
GRUPO_ADICOES_DOACAO					10	//Adições por Doação
GRUPO_EXCLUSOES_LUCRO				11	//Exclusões do Lucro
GRUPO_EXCLUSOES_RECEITA				12	//Exclusões da Receita
GRUPO_COMPENSACAO_PREJUIZO			13	//Compensação de Prejuízo
GRUPO_DEDUCOES_TRIBUTO				14	//Deduções do Tributo
GRUPO_COMPENSACAO_TRIBUTO			15	//Compensação do Tributo
GRUPO_ADICIONAIS_TRIBUTO				16	//Adicionais do Tributo
GRUPO_RECEITA_LIQUIDA_ATIVIDA		17	//Receita Líquida por Atividade
GRUPO_LUCRO_EXPLORACAO				18	//Lucro da Exploração

Mais os listados abaixo
*/

#DEFINE ALIQUOTA_RECEITA_1					19
#DEFINE ALIQUOTA_RECEITA_2					20
#DEFINE ALIQUOTA_RECEITA_3					21
#DEFINE ALIQUOTA_RECEITA_4					22
#DEFINE ALIQUOTA_IMPOSTO						23
#DEFINE ALIQUOTA_IR_ADICIONAL_IMPOSTO		24
#DEFINE PARCELA_ISENTA						25
#DEFINE INICIO_PERIODO						26
#DEFINE FIM_PERIODO							27
#DEFINE ITENS_PROPORCAO_DO_LUCRO			28

//Parâmetros dos Itens da Proporção do Lucro
#DEFINE PROUNI								1
#DEFINE PERCENTUAL_REDUCAO					2
#DEFINE TIPO_ATIVIDADE						3
#DEFINE VALOR									4
#DEFINE ID_TABELA_ECF						5
#DEFINE ORIGEM								6
#DEFINE ID_TABELA_ECF_DED					7
#DEFINE TIPO_TRIBUTO							29
#DEFINE POEB									30
#DEFINE PERCENTUAL_COMP_PREJU				31
#DEFINE VLR_DEVIDO_PERIODOS_ANTERIORES		32
#DEFINE VLR_PAGO_PERIODOS_ANTERIORES		33
#DEFINE VLR_PREJUIZO_OPERACIONAL			34
#DEFINE VLR_PREJUIZO_NAO_OPERACIONAL		35
#DEFINE VLR_PREJUIZO_COMP_NO_PERIODO		36

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA433

Cadastro de Evento Tributário.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
User Function XTAFA433()

Local oBrw		as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "T0N" )
	oBrw:SetDescription( STR0001 ) //"Cadastro de Evento Tributário"
	oBrw:SetAlias( "T0N" )
	oBrw:SetMenuDef( "MADERO_TAFA433" )

	oBrw:SetCacheView( .F. )

	T0N->( DBSetOrder( 1 ) )

	oBrw:Activate()
Else
	Aviso( STR0077, TafAmbInvMsg(), { STR0078 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local nPos		as numeric
Local aFuncao	as array
Local aRotina	as array

nPos		:=	0
aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { STR0067, "TAF433Pre( 'Cópia do Evento Tributário', 'TAFA433Cpy' )" } ) //"Cópia do Evento Tributário"
aAdd( aFuncao, { STR0088, "TAF433Pre( 'Simulação da Apuração', 'U_xVMTAFA433' )" } ) //"Simulação da Apuração"

aRotina := xFunMnuTAF( "TAFA433",, aFuncao )

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0079 } ) ) > 0 //"Visualizar"
	aRotina[nPos,2] := "TAF433Pre( 'Visualizar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0080 } ) ) > 0 //"Incluir"
	aRotina[nPos,2] := "TAF433Pre( 'Incluir' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0081 } ) ) > 0 //"Alterar"
	aRotina[nPos,2] := "TAF433Pre( 'Alterar' )"
EndIf

If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0082 } ) ) > 0 //"Excluir"
	aRotina[nPos,2] := "TAF433Pre( 'Excluir' )"
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF433Pre

Executa pré-condições para a operação desejada.

@Param		cOper		-	Indica a operação a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author	Felipe C. Seolin
@Since		09/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TAF433Pre( cOper, cRotina )

Local nOperation	as numeric
Local aButtons	as array
Local lOk			as logical

Private cIDFormTrib	as character
Private cT0N_IDFTRI	as character
Private cT0N_DFTRIB	as character
Private cT0N_IDTRIB	as character
Private cT0N_DTRIBU	as character
Private lCopia		as logical

Default cRotina		:=	"TAFA433"

nOperation		:=	MODEL_OPERATION_VIEW
aButtons		:=	{}
lOk				:=	.F.

cIDFormTrib	:=	""
cT0N_IDFTRI	:=	""
cT0N_DFTRIB	:=	""
cT0N_IDTRIB	:=	""
cT0N_DTRIBU	:=	""
lCopia			:=	.F.

//De-Para de opções do Menu para a operações em MVC
If Upper( cOper ) == Upper( "Visualizar" )
	nOperation := MODEL_OPERATION_VIEW
ElseIf Upper( cOper ) == Upper( "Incluir" )
	nOperation := MODEL_OPERATION_INSERT
ElseIf Upper( cOper ) == Upper( "Alterar" )
	nOperation := MODEL_OPERATION_UPDATE
ElseIf Upper( cOper ) == Upper( "Excluir" )
	nOperation := MODEL_OPERATION_DELETE
ElseIf Upper( cOper ) $ Upper( "|Cópia do Evento Tributário|Simulação da Apuração|" )
	nOperation := 0
Else
	nOperation := 0
EndIf

//É permitido o uso do cadastro apenas se for executado em Filial Matriz ou SCP.
//Caso contrário, apenas será permitido a Visualização do referido cadastro.
If TAFColumnPos( "C1E_MATRIZ" ) .and. TAFColumnPos( "CWX_RURAL" )
	If GrantAccess()

		If Upper( cOper ) $ ( Upper( "|Cópia do Evento Tributário|" ) )
			&cRotina.()
		ElseIf Upper( cOper ) $ ( Upper( "|Simulação da Apuração|" ) )
			/*
			C1O_NATURE	--> Dicionário do Plano de Contas
			T0T_IDDETA	--> Dicionário do Encerramento
			CWX_RURAL	--> Dicionario do Detalhamento
			C0R_VLPAGO	--> Cadastro de Guias
			*/
			If TAFColumnPos( "C1O_NATURE" ) .and. TAFAlsInDic( "CWX" ) .and. TAFColumnPos( "T0T_IDDETA" ) .and. TAFColumnPos( "C0R_VLPAGO" )
				&cRotina.()
			Else
				MsgInfo( TafAmbInvMsg() )
			EndIf
		ElseIf nOperation == MODEL_OPERATION_INSERT

			aAdd( aButtons, { 1, .T., { |x| lOk := .T., x:oWnd:End() } } )
			aAdd( aButtons, { 2, .T., { |x| x:oWnd:End() } } )

			If PergTAF( cRotina, STR0002, { STR0003 }, aButtons, { || .T. },,, .F. ) .and. lOk //##"Forma de Tributação" ##"Forma de Tributação do Evento Tributário"
				cIDFormTrib := xFunCh2ID( MV_PAR01, "T0K", 2 )
				FWExecView( cOper, cRotina, nOperation )
			Else
				cIDFormTrib := "CANCEL"
				MsgInfo( STR0083 ) //"É necessário informar a Forma de Tributação para definição das informações a serem exibidas no cadastro."
			EndIf

		Else
			FWExecView( cOper, cRotina, nOperation )
		EndIf

	Else

		If nOperation == MODEL_OPERATION_VIEW
			cIDFormTrib := ""
			FWExecView( cOper, cRotina, nOperation )
		Else
			MsgInfo( STR0025 ) //"Apenas Filial Matriz ou Filial SCP possui permissão de manipulação do cadastro."
		EndIf

	EndIf
Else
	MsgInfo( TafAmbInvMsg() )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do modelo.

@Return	oModel	- Objeto do Model MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0N	as object
Local oStruLEC	as object
Local oStruLED	as object
Local oModel		as object
Local nI			as numeric
Local aGrupos		as array

oStruT0N	:=	FWFormStruct( 1, "T0N" )
oStruLEC	:=	FWFormStruct( 1, "LEC" )
oStruLED	:=	FWFormStruct( 1, "LED" )
oModel		:=	MPFormModel():New( "TAFA433",,, { |oModel| SaveModel( oModel ) } )
nI			:=	0
aGrupos	:=	GetGrupos( , .T. )

//Inicialização de variáveis Private para não gerar erro em
//chamadas diretas da View, por exemplo via Consulta Padrão
lCopia := Iif( Type( "lCopia" ) == "U", .F., lCopia )

//A Forma de Tributação não pode ser alterada
oStruT0N:SetProperty( "T0N_CODFTR", MODEL_FIELD_WHEN, { || .F. .or. lCopia } )

//Inicializa o ID da Forma de Tributação
oStruT0N:SetProperty( "T0N_IDFTRI", MODEL_FIELD_INIT, { |oModel| cIDFormTrib } )

//O Tributo não pode ser alterado durante a edição
oStruT0N:SetProperty( "T0N_COTRIB", MODEL_FIELD_WHEN, { || ( !( ( Type( "ALTERA" ) <> "U" ) .and. ALTERA ) ) .or. lCopia } )

oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODECF",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODEC",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODE",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODLAL",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODLA",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODL",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_ATIVID",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_PROUNI",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_PERRED",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_CODTDE",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_DCODTD",, { || "" } )
oStruLEC:AddTrigger( "LEC_CODGRU", "LEC_IDCODT",, { || "" } )
oStruLEC:AddTrigger( "LEC_ATIVID", "LEC_PROUNI",, { || "" } )
oStruLEC:AddTrigger( "LEC_ATIVID", "LEC_PERRED",, { || "" } )

oModel:AddFields( "MODEL_T0N", /*cOwner*/, oStruT0N )
oModel:GetModel( "MODEL_T0N" ):SetPrimaryKey( { "T0N_CODIGO" } )

If !CanUpdate()
	oStruT0N:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
EndIf

//Cria um model para cada grupo.
For nI := 1 to Len( aGrupos )
	AddModelGr( @oModel, aGrupos[nI] )
Next nI

If TAFAlsInDic( "LEC" ) .and. TAFAlsInDic( "LED" ) .and. !lCopia
	oModel:AddGrid( "MODEL_LEC", "MODEL_T0N", oStruLEC )
	oModel:GetModel( "MODEL_LEC" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_LEC" ):SetUniqueLine( { "LEC_CODLAN" } )
	oModel:SetRelation( "MODEL_LEC",{ { "LEC_FILIAL", "xFilial( 'LEC' )" }, { "LEC_ID", "T0N_ID" } }, LEC->( IndexKey( 1 ) ) )

	oModel:AddGrid( "MODEL_LED", "MODEL_LEC", oStruLED )
	oModel:GetModel( "MODEL_LED" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_LED" ):SetUniqueLine( { "LED_IDPROC" } )
	oModel:SetRelation( "MODEL_LED",{ { "LED_FILIAL", "xFilial( 'LED' )" }, { "LED_ID", "T0N_ID" }, { "LED_CODLAN", "LEC_CODLAN" } }, LED->( IndexKey( 1 ) ) )
EndIf

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView	- Objeto da View MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local cFormaTrib	as character

oModel		:=	FWLoadModel( "TAFA433" )
oView		:=	FWFormView():New()
cFormaTrib	:=	""

//Inicialização de variáveis Private para não gerar erro em
//chamadas diretas da View, por exemplo via Consulta Padrão
cIDFormTrib	:=	Iif( Type( "cIDFormTrib" ) == "U", "", cIDFormTrib )
lCopia			:=	Iif( Type( "lCopia" ) == "U", .F., lCopia )

// Na inclusão/cópia será solicitado a seleção da Forma de Tributação antes de apresentar a tela de edição.
// Na edição será carregado a Forma de Tributação do cadastro.
// A partir da Forma de Tributação serão definidos quais os campos/abas deverão ser apresentados.
If lCopia
	CopiarEven( @cFormaTrib, @oModel )
ElseIf !Empty( cIDFormTrib )
	If cIDFormTrib == "CANCEL"
		cFormaTrib := ""
	Else
		cFormaTrib := xFunID2Cd( cIDFormTrib, "T0K", 1 )
	EndIf
Else
	cFormaTrib := xFunID2Cd( T0N->T0N_IDFTRI, "T0K", 1 )
EndIf

oView:SetModel( oModel )
oView:CreateHorizontalBox( "PAINEL_ABAS", 100 )
oView:CreateFolder( "FOLDER_GERAL", "PAINEL_ABAS" )

AbaIndenti( @oView, cFormaTrib )
AbaRegrasT( @oView, cFormaTrib )

If TAFAlsInDic( "LEC" ) .and. TAFAlsInDic( "LED" ) .and. !lCopia
	AbaLancMan( @oView, cFormaTrib )
EndIf

If lCopia
	lCopia := .F.
EndIf

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrantAccess

Função para verificar a permissão de manipulação do cadastro.

@Return	lRet - Indica se possui permissão

@Author	Felipe C. Seolin
@Since		09/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GrantAccess()

Local lRet	as logical

lRet	:=	.F.

DBSelectArea( "C1E" )
C1E->( DBSetOrder( 3 ) )
If C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt + "1" ) )
	If C1E->C1E_MATRIZ .or. FilialSCP( C1E->C1E_ID )
		lRet := .T.
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaIndenti
Monta a Aba Identificação do Cadastro de Evento Tributário

@Param oView - Objeto da View MVC
cFormaTrib - Forma de Tributação do Evento Tributário

@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaIndenti( oView, cFormaTrib )

Local oStruT0N	as object

oStruT0N	:=	CamposView( "T0N",, cFormaTrib )

oView:AddField( 'VIEW_T0N', oStruT0N, 'MODEL_T0N' )
oView:EnableTitleView( 'VIEW_T0N', STR0001 ) //"Cadastro de Evento Tributário"

oView:AddSheet( 'FOLDER_GERAL', 'ABA_IDENTIFICACAO', STR0004 ) //"Identificação"
oView:CreateHorizontalBox( 'PAINEL_ABA_IDENTIFICACAO' , 100,,, 'FOLDER_GERAL', 'ABA_IDENTIFICACAO' )

oView:SetOwnerView( 'VIEW_T0N', 'PAINEL_ABA_IDENTIFICACAO' )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaRegrasT
Monta a Aba Regras Tributárias do Cadastro de Evento Tributário

@Param oView - Objeto da View MVC
		cFormaTrib - Forma de Tributação do Evento Tributário

@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaRegrasT( oView, cFormaTrib )

oView:AddSheet( 'FOLDER_GERAL', 'ABA_REGRAS_TRIBUTARIAS', STR0005 ) //"Regras Tributárias"
oView:CreateHorizontalBox( 'PAINEL_ABAS_REGRAS_TRIBUTARIAS' , 100,,, 'FOLDER_GERAL', 'ABA_REGRAS_TRIBUTARIAS' )
oView:CreateFolder( 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'PAINEL_ABAS_REGRAS_TRIBUTARIAS' )

AbaBaseCal( @oView, cFormaTrib )

If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL 
	AbaCalTrib( @oView, cFormaTrib )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaBaseCal
Monta a Aba Base de Calculo

@Param oView - Objeto da View MVC
		cFormaTrib - Forma de Tributação do Evento Tributário
		
@author David Costa
@since 21/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AbaBaseCal( oView, cFormaTrib )

Local cFolder	as character
Local nI		as numeric
Local aGrupos	as array

cFolder	:=	"FOLDER_ABA_BASE_CALCULO"
nI			:=	0
aGrupos	:=	GetGrupos( cFormaTrib )

oView:AddSheet( 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'ABA_BASE_CALCULO', STR0006 ) //"Base de Cálculo"
oView:CreateHorizontalBox( 'PAINEL_ABA_BASE_CALCULO' , 100,,, 'FOLDER_ABAS_REGRAS_TRIBUTARIAS', 'ABA_BASE_CALCULO' )
oView:CreateFolder( cFolder, 'PAINEL_ABA_BASE_CALCULO' )

For nI := 1 to Len( aGrupos )
	If aGrupos[nI][PARAM_GRUPO_TIPO] == TIPO_GRUPO_BASE_CALCULO
		AddViewItem( @oView, cFolder, aGrupos[nI], cFormaTrib )
	EndIf
Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AddViewItem

Adiciona um Item Tributário na View.

@Param	oView		- Objeto da View MVC
		cFolder	- Folder na qual será adicionado o Item Tributário
		aGrupo		- Array do Grupo Tributário ( Gerado pela Função GetGrupos() )
		cFormaTrib	- Forma de Tributação do Evento Tributário

@Author	David Costa
@Since		30/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AddViewItem( oView, cFolder, aGrupo, cFormaTrib )

Local oStruT0O	as object
Local oStruT0P	as object
Local oStruT0R	as object

oStruT0O	:=	CamposView( "T0O", aGrupo[PARAM_GRUPO_ID], cFormaTrib )
oStruT0P	:=	CamposView( "T0P", aGrupo[PARAM_GRUPO_ID], cFormaTrib )
oStruT0R	:=	CamposView( "T0R", aGrupo[PARAM_GRUPO_ID], cFormaTrib )

//Aba do Item Tributário
oView:AddSheet( cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME], aGrupo[PARAM_GRUPO_DESCRICAO] )

//Item Tributário
oView:CreateHorizontalBox( "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_ITEM", 60,,, cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME] )

oView:AddGrid( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0O, "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] )
oView:EnableTitleView( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], aGrupo[PARAM_GRUPO_DESCRICAO] )
oView:SetOwnerView( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_ITEM" )
oView:AddIncrementField( "VIEW_T0O_" + aGrupo[PARAM_GRUPO_NOME], "T0O_SEQITE" )

//Filhos do Item Tributário
oView:CreateHorizontalBox( "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_FILHOS", 40,,, cFolder, "ABA_" + aGrupo[PARAM_GRUPO_NOME] )
oView:CreateFolder( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_" + aGrupo[PARAM_GRUPO_NOME] + "_FILHOS" )

//Histórico Padrão
oView:AddSheet( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_HISTORICO_PADRAO", STR0020 ) //"Histórico Padrão"
oView:CreateHorizontalBox( "PAINEL_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], 100,,, "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_HISTORICO_PADRAO" )

oView:AddGrid( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], oStruT0R, "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] )
oView:EnableTitleView( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], STR0020 ) //"Histórico Padrão"
oView:SetOwnerView( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME] )
oView:AddIncrementField( "VIEW_T0R_HISTORICO_PADRAO" + aGrupo[PARAM_GRUPO_NOME], "T0R_SEQHIS" )

//Processos Referenciados
oView:AddSheet( "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_PROCESSO_JUD_ADMIN", STR0021 ) //"Processo Jud./Admin."
oView:CreateHorizontalBox( "PAINEL_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], 100,,, "FOLDER_FILHOS" + aGrupo[PARAM_GRUPO_NOME], "ABA_PROCESSO_JUD_ADMIN" )

oView:AddGrid( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], oStruT0P, "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] )
oView:EnableTitleView( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], STR0021 ) //"Processo Jud./Admin."
oView:SetOwnerView( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], "PAINEL_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME] )
oView:AddIncrementField( "VIEW_T0P_PROCESSO_JUD_ADMIN" + aGrupo[PARAM_GRUPO_NOME], "T0P_SEQPRO" )

If TamSX3("T0O_IDCC")[1] == 36
	oStruT0O:RemoveField( "T0O_IDCC")
EndIf
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaCalTrib

Monta a Aba Cálculo do Tributo

@Param	oView		- Objeto da View MVC
		cFormaTrib	- Forma de Tributação do Evento Tributário

@Author	David Costa
@Since		21/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaCalTrib( oView, cFormaTrib )

Local cFolder	as character
Local nI		as numeric
Local aGrupos	as array

cFolder	:=	"FOLDER_ABA_CALCULO_TRIBUTO"
nI			:=	0
aGrupos	:=	GetGrupos( cFormaTrib )

oView:AddSheet( "FOLDER_ABAS_REGRAS_TRIBUTARIAS", "ABA_CALCULO_TRIBUTO", STR0022 ) //"Cálculo do Tributo"
oView:CreateHorizontalBox( "PAINEL_ABA_CALCULO_TRIBUTO", 100,,, "FOLDER_ABAS_REGRAS_TRIBUTARIAS", "ABA_CALCULO_TRIBUTO" )
oView:CreateFolder( cFolder, "PAINEL_ABA_CALCULO_TRIBUTO" )

For nI := 1 to Len( aGrupos )
	If aGrupos[nI][PARAM_GRUPO_TIPO] == TIPO_GRUPO_CALCULO_TRIBUTO
		AddViewItem( @oView, cFolder, aGrupos[nI], cFormaTrib )
	EndIf
Next nI

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaLancMan

Monta a Aba Regras Tributárias do Cadastro de Evento Tributário

@Param	oView		- Objeto da View MVC
		cFormaTrib	- Forma de Tributação do Evento Tributário

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaLancMan( oView, cFormaTrib )

Local oStruLEC	as object
Local oStruLED	as object

oStruLEC	:=	CamposView( "LEC",, cFormaTrib )
oStruLED	:=	CamposView( "LED",, cFormaTrib )

oView:AddGrid( "VIEW_LEC", oStruLEC, "MODEL_LEC" )
oView:EnableTitleView( "VIEW_LEC", STR0071 ) //"Lançamento Manual"
oView:AddIncrementField( "VIEW_LEC", "LEC_CODLAN" )

oView:AddGrid( "VIEW_LED", oStruLED, "MODEL_LED" )
oView:EnableTitleView( "VIEW_LED", STR0072 ) //"Processo Judicial e Administrativo dos Lançamentos Manuais"

oView:AddSheet( "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL", STR0071 ) //"Lançamento Manual"

oView:CreateHorizontalBox( "PAINEL_ABA_LANCAMENTO_MANUAL_SUPERIOR", 50,,, "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL" )
oView:CreateHorizontalBox( "PAINEL_ABA_LANCAMENTO_MANUAL_INFERIOR", 50,,, "FOLDER_GERAL", "ABA_LANCAMENTO_MANUAL" )


oView:SetOwnerView( "VIEW_LEC", "PAINEL_ABA_LANCAMENTO_MANUAL_SUPERIOR" )
oView:SetOwnerView( "VIEW_LED", "PAINEL_ABA_LANCAMENTO_MANUAL_INFERIOR" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CamposView
Retorna os campos para a View conforme as Regras de cada Grupo tributário

@Param cAlias - Tabela com os campos do Form
		nIdGrupo - Identificador do Grupo Tributário
		cFormaTrib - Forma de Tributação do Evento Tributário
		
@return FormStruct

@author David Costa
@since 30/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CamposView( cAlias, nIdGrupo, cFormaTrib )

Local oStruct		as object
Local cIdFilial	as character

oStruct	:=	FWFormStruct( 2, cAlias )
cIdFilial	:=	""

If cAlias $ 'T0O'
	oStruct:RemoveField( 'T0O_ID' )
	oStruct:RemoveField( 'T0O_IDGRUP' )
	oStruct:RemoveField( 'T0O_IDECF' )
	oStruct:RemoveField( 'T0O_IDLAL' )
	oStruct:RemoveField( 'T0O_IDLIDC' )
	oStruct:RemoveField( 'T0O_IDCC' )
	oStruct:RemoveField( 'T0O_IDEVEN' )
	oStruct:RemoveField( 'T0O_IDTDEX' )
	oStruct:RemoveField( 'T0O_IDPARB' )
	
	Do Case
		Case nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_BASE_CALCULO;
		.or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA .or. nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_EFEITO' )
			oStruct:RemoveField( 'T0O_ATIVID' )
			oStruct:RemoveField( 'T0O_PROUNI' )
			oStruct:RemoveField( 'T0O_PERRED' )
			oStruct:RemoveField( 'T0O_CODTDE' )
			oStruct:RemoveField( 'T0O_DTDEXP' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			oStruct:RemoveField( 'T0O_CODLAL' )
			oStruct:RemoveField( 'T0O_DTDLAL' )

			If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
				//Quando a forma de tributação for "Lucro Real - Lucro da Exploração" a Origem deverá ser "Conta Contábil"
				oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Contábil" } )

				//Quando a forma de tributação for "Lucro Real - Lucro da Exploração" o campo "Conta Lalur – Parte B" não estará disponível.
				oStruct:RemoveField( "T0O_CODPAB" )
				oStruct:RemoveField( "T0O_DPARTB" )
			EndIf

		Case nIdGrupo == GRUPO_DEDUCOES_TRIBUTO
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lançamento Automático" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODLAL" )
			oStruct:RemoveField( "T0O_DTDLAL" )

			If cFormaTrib <> TRIBUTACAO_LUCRO_REAL .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				//Se a Origem "Evento Tributário" não estiver disponível os campos devem ser removidos
				oStruct:RemoveField( 'T0O_CODEVE' )
				oStruct:RemoveField( 'T0O_DEVENT' )
			Else
				//Adicionar a opção "3=Evento Tributário"
				oStruct:SetProperty( 'T0O_ORIGEM' , MVC_VIEW_COMBOBOX , { "1=Conta Contábil", "2=Lalur - Parte B", "3=Evento Tributário" } )
			EndIf
		Case nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_ATIVID' )
			oStruct:RemoveField( 'T0O_PROUNI' )
			oStruct:RemoveField( 'T0O_PERRED' )
			oStruct:RemoveField( 'T0O_CODTDE' )
			oStruct:RemoveField( 'T0O_DTDEXP' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				oStruct:RemoveField( 'T0O_CODECF' )
				oStruct:RemoveField( 'T0O_DTDECF' )
			Else
				oStruct:RemoveField( 'T0O_CODLAL' )
				oStruct:RemoveField( 'T0O_DTDLAL' )
			EndIf
			
		Case nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lançamento Automático" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )
			oStruct:RemoveField( "T0O_CODLAL" )
			oStruct:RemoveField( "T0O_DTDLAL" )

		Case nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO
			oStruct:SetProperty( "T0O_EFEITO", MVC_VIEW_COMBOBOX, { "4=Incluir Lançamento Automático" } )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODTDE" )
			oStruct:RemoveField( "T0O_DTDEXP" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )

			//O campo "Conta Contábil" só estará disponível quando a Origem for "Conta Contábil"
			oStruct:RemoveField( 'T0O_CODCC' )
			oStruct:RemoveField( 'T0O_DCONTC' )
			
			//O campo "Centro de Custo" só estará disponível quando a Origem for "Conta Contábil"
			oStruct:RemoveField( 'T0O_IDCUST' )
			oStruct:RemoveField( 'T0O_DCUSTO' )
			
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				oStruct:RemoveField( 'T0O_CODECF' )
				oStruct:RemoveField( 'T0O_DTDECF' )
			Else
				oStruct:RemoveField( 'T0O_CODLAL' )
				oStruct:RemoveField( 'T0O_DTDLAL' )
			EndIf

		Case nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA
			oStruct:RemoveField( 'T0O_PERDED' )
			oStruct:RemoveField( 'T0O_CODLID' )
			oStruct:RemoveField( 'T0O_DLIMDC' )
			oStruct:RemoveField( 'T0O_EFEITO' )
			oStruct:RemoveField( 'T0O_CODEVE' )
			oStruct:RemoveField( 'T0O_DEVENT' )
			oStruct:RemoveField( 'T0O_CODLAL' )
			oStruct:RemoveField( 'T0O_DTDLAL' )

			If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
				//Quando a forma de tributação for "Lucro Real - Lucro da Exploração" a Origem deverá ser "Conta Contábil"
				oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Contábil" } )

				//Quando a forma de tributação for "Lucro Real - Lucro da Exploração" o campo "Conta Lalur – Parte B" não estará disponível.
				oStruct:RemoveField( "T0O_CODPAB" )
				oStruct:RemoveField( "T0O_DPARTB" )
			EndIf

		Case nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL
			oStruct:SetProperty( "T0O_ORIGEM", MVC_VIEW_COMBOBOX, { "1=Conta Contábil" } )
			oStruct:RemoveField( "T0O_CODECF" )
			oStruct:RemoveField( "T0O_DTDECF" )
			oStruct:RemoveField( "T0O_PERDED" )
			oStruct:RemoveField( "T0O_CODLID" )
			oStruct:RemoveField( "T0O_DLIMDC" )
			oStruct:RemoveField( "T0O_EFEITO" )
			oStruct:RemoveField( "T0O_CODEVE" )
			oStruct:RemoveField( "T0O_DEVENT" )
			oStruct:RemoveField( "T0O_ATIVID" )
			oStruct:RemoveField( "T0O_PROUNI" )
			oStruct:RemoveField( "T0O_PERRED" )
			oStruct:RemoveField( "T0O_CODPAB" )
			oStruct:RemoveField( "T0O_DPARTB" )

	EndCase

	cIdFilial := XFUNCh2ID( cFilAnt , 'C1E' , 3, , , , .T. )
	
	If FilialSCP( cIdFilial, Space( 1 ) ) .or. ( FWModeAccess( "C1O" ) == "C" .and. FWModeAccess( "C1P" ) == "C" .and. FWModeAccess( "T0S" ) == "C" )
		oStruct:RemoveField( "T0O_FILITE" )
	EndIf

	If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		oStruct:RemoveField( 'T0O_CODTDE' )
		oStruct:RemoveField( 'T0O_DTDEXP' )
	EndIf

ElseIf cAlias $ 'T0P'
	oStruct:RemoveField( 'T0P_ID' )
	oStruct:RemoveField( 'T0P_IDGRUP' )
	oStruct:RemoveField( 'T0P_SEQITE' )
ElseIf cAlias $ 'T0R'
	oStruct:RemoveField( 'T0R_ID' )
	oStruct:RemoveField( 'T0R_IDGRUP' )
	oStruct:RemoveField( 'T0R_SEQITE' )
	oStruct:RemoveField( 'T0R_IDHIST' )
ElseIf cAlias $ 'T0N'
	oStruct:RemoveField( 'T0N_ID')
	oStruct:RemoveField( 'T0N_IDFTRI' )
	oStruct:RemoveField( 'T0N_IDEVEN' )
	oStruct:RemoveField( 'T0N_IDTRIB' )

	oStruct:SetProperty( "T0N_COTRIB", MVC_VIEW_ORDEM, "09" )
	oStruct:SetProperty( "T0N_DTRIBU", MVC_VIEW_ORDEM, "10" )
	oStruct:SetProperty( "T0N_CODEVE", MVC_VIEW_ORDEM, "12" )
	oStruct:SetProperty( "T0N_DEVENT", MVC_VIEW_ORDEM, "13" )

	//O campo "Evento Tributário para apuração da atividade rural" estará disponível somente para as formas 
	//de tributação "Lucro Real" e "Lucro Real - estimativa levantamento de balanço"
	If cFormaTrib <> TRIBUTACAO_LUCRO_REAL .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
		oStruct:RemoveField( 'T0N_CODEVE' )
		oStruct:RemoveField( 'T0N_DEVENT' )
	EndIf
	
	//O campo "Tributo" não será apresentado quando a Forma de Tributação for "Lucro Real - Lucro da Exploração"
	If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		oStruct:RemoveField( 'T0N_COTRIB' )
		oStruct:RemoveField( 'T0N_DTRIBU' )
	EndIf

ElseIf cAlias $ "LEC"

	oStruct:RemoveField( "LEC_IDCODG" )
	oStruct:RemoveField( "LEC_IDCODE" )
	oStruct:RemoveField( "LEC_IDCODL" )
	oStruct:RemoveField( "LEC_IDCODT" )

EndIf

Return( oStruct )

//-------------------------------------------------------------------
/*/{Protheus.doc} AddModelGr

Adiciona o Modelo do Grupo Tributário .

@Param	oModel	- Objeto do Modelo MVC
		aGrupo	- Array do Grupo Tributário ( Gerado pela Função GetGrupos() )

@Author	David Costa
@Since		30/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AddModelGr( oModel, aGrupo )

Local oStruT0O	as object
Local oStruT0P	as object
Local oStruT0R	as object
Local cIdFilial	as character

oStruT0O	:=	FWFormStruct( 1, "T0O" )
oStruT0P	:=	FWFormStruct( 1, "T0P" )
oStruT0R	:=	FWFormStruct( 1, "T0R" )
cIdFilial	:=	""

If aGrupo[PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_PREJUIZO
	//No Grupo "Compensação de Prejuízos" só deve ser possível associar Conta da Parte B do Lalur
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_INIT, { || ORIGEM_LALUR_PARTE_B } )
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_WHEN, { || .F. } )
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lançamento Automático" } )

ElseIf aGrupo[PARAM_GRUPO_ID] == GRUPO_DEDUCOES_TRIBUTO
	//A opção "Evento Tributário" só pode ser selecionada no Grupo de Deduções do Tributo
	oStruT0O:SetProperty( "T0O_ORIGEM", MODEL_FIELD_VALUES, { "1=Conta Contábil", "2=Lalur - Parte B", "3=Evento Tributário" } )
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lançamento Automático" } )

ElseIf aGrupo[PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_TRIBUTO
	oStruT0O:SetProperty( "T0O_EFEITO", MODEL_FIELD_VALUES, { "4=Incluir Lançamento Automático" } )
EndIf

cIdFilial := xFunCh2ID( cFilAnt, "C1E", 3,,,, .T. )

//Se a Filial for SCP, o campo será carregado automaticamente com a Filial logada, e este campo não poderá ser alterado
If FilialSCP( cIdFilial )
	DBSelectArea( "C1E" )
	C1E->( DBSetOrder( 2 ) )
	If C1E->( MsSeek( xFilial( "C1E" ) + cIdFilial ) )
		oStruT0O:SetProperty( "T0O_FILITE", MODEL_FIELD_INIT, { || C1E->C1E_CODFIL } )
		oStruT0O:SetProperty( "T0O_FILITE", MODEL_FIELD_WHEN, { || .F. } )
	EndIf
EndIf

oStruT0O:SetProperty( "T0O_IDGRUP", MODEL_FIELD_INIT, { |oModel| aGrupo[PARAM_GRUPO_ID] } )

If !CanUpdate()
	oStruT0O:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
	oStruT0P:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
	oStruT0R:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
EndIf

oModel:AddGrid( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0N", oStruT0O, { |oModelGrid, nLine, cAction, cField, xValNew, xValOld| PutcModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], cField ) } )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetLoadFilter( { { "T0O_IDGRUP", Str( aGrupo[PARAM_GRUPO_ID] ) } } )
oModel:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0O_IDGRUP", "T0O_SEQITE" } )

oModel:AddGrid( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0P )
oModel:GetModel( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0P_IDGRUP", "T0P_SEQITE", "T0P_SEQPRO" } )

oModel:AddGrid( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME], "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], oStruT0R, { |oModelGrid, nLine, cAction| VldHistEve( cAction ) } )
oModel:GetModel( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] ):SetOptional( .T. )
oModel:GetModel( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME] ):SetUniqueLine( { "T0R_IDGRUP", "T0R_SEQITE", "T0R_SEQHIS" } )

oModel:SetRelation( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME], { { "T0O_FILIAL", "xFilial( 'T0O' )" }, { "T0O_ID", "T0N_ID" } }, T0O->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0P_" + aGrupo[PARAM_GRUPO_NOME], { { "T0P_FILIAL", "xFilial( 'T0P' )" }, { "T0P_ID", "T0N_ID" }, { "T0P_IDGRUP", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_IDGRUP" }, { "T0P_SEQITE", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_SEQITE" } }, T0P->( IndexKey( 1 ) ) )
oModel:SetRelation( "MODEL_T0R_" + aGrupo[PARAM_GRUPO_NOME], { { "T0R_FILIAL", "xFilial( 'T0R' )" }, { "T0R_ID", "T0N_ID" }, { "T0R_IDGRUP", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_IDGRUP" }, { "T0R_SEQITE", "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] + ".T0O_SEQITE" } }, T0R->( IndexKey( 1 ) ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCmpEven

Funcao utilizada para consistir os campos do evento tributário

@return cRet - Retorna se o campo está válido

@author David Costa
@since 24/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldCmpEven()

Local cCmp			as character
Local cOrigem		as character
Local cFilItem	as character
Local cLogValid	as character
Local cFormaTrib	as character
Local cTributo	as character
Local cCodTDECF	as character
Local cEfeito		as character
Local cGrupo		as character
Local nIdGrupo	as numeric
Local aAreaBkp	as array
Local lRet			as logical
Local xValueCmp

cCmp		:=	ReadVar()
cOrigem	:=	""
cFilItem	:=	""
cLogValid	:=	""
cFormaTrib	:=	""
cTributo	:=	""
cCodTDECF	:=	""
cEfeito	:=	""
cGrupo		:=	""
nIdGrupo	:=	0
aAreaBkp	:=	{}
lRet		:=	.T.
xValueCmp	:=	Nil

If !( "LEC_" $ AllTrim( SubStr( cCmp, 4 ) ) )
	cFilItem	:= xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
	cOrigem	:= GetValueCmp( "T0O_ORIGEM" )
	nIdGrupo	:= GetValueCmp( "T0O_IDGRUP" )
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_FILITE"
	If !Empty( GetValueCmp( "T0O_CODCC" ) ) .or. !Empty( GetValueCmp( "T0O_IDCUST" ) ) .or. !Empty( GetValueCmp( "T0O_CODPAB" ) )
		cLogValid += STR0026 + CRLF + CRLF //"Antes de Alterar o campo T0O_FILITE é necessário limpar o conteúdo dos campos 'Conta contábil' (T0O_CODCC), 'Centro de Custo' (T0O_IDCUST) e 'Conta da Parte B do Lalur' (T0O_CODPAB)"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_ORIGEM"
	
	If !VldHistEve( 'ALTERACAO_ORIGEM' )
		lRet := .F.	
		cLogValid := STR0027 + CRLF + CRLF //"Apague o Histórico Padrão antes de alterar a Origem."
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_OPERAC|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_OPERAC" )
	
	//Quando for selecionada a origem "Evento Tributário" a operação deve ser obrigatoriamente SOMA.
	If !Empty( xValueCmp ) .and. xValueCmp <> OPERACAO_SOMA .and. cOrigem == ORIGEM_EVENTO_TRIBUTARIO
		lRet := .F.
		cLogValid := STR0028 + CRLF + CRLF //"Quando for selecionada a origem 'Evento Tributário' a operação deve ser obrigatoriamente SOMA."
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODCC|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_CODCC" )
	
	//O campo "Conta Contábil" só estará disponível quando a Origem for "Conta Contábil" 
	If !Empty( xValueCmp ) .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0029 + CRLF + CRLF //"O campo 'Conta Contábil' só pode ser utilizado quando a Origem for 'Conta Contábil' "
		lRet := .F.
	EndIf
	
	//A conta contábil preenchida precisa ser da Filial selecionada no campo "Filial"
	C1O->( DbSetOrder( 1 ) )
	If !Empty( xValueCmp ) .and. !( C1O->( MsSeek( xFilial( "C1O", cFilItem ) + xValueCmp ) ) )
		cLogValid += STR0030 + CRLF + CRLF //A Conta Contábil não pertence a Filial informada no campo T0O_FILITE
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODPAB|T0O_ORIGEM|T0O_EFEITO"

	xValueCmp := GetValueCmp( "T0O_CODPAB" )
	
	If !Empty( xValueCmp )
		
		T0S->( DbSetOrder( 2 ) )
		
		//A conta da parte B preenchida precisa ser da Filial selecionada no campo "Filial"
		If !( T0S->( MsSeek( xFilial( "T0S", cFilItem ) + xValueCmp ) ) )
			cLogValid += STR0050 + CRLF + CRLF //"A Conta da Parte B não pertence a Filial informada no campo T0O_FILITE"
			lRet := .F.
		
		Else
			LE9->( DbSetOrder( 1 ) )
			//Apenas contas da parte B cujo o tributo seja o mesmo selecionado no evento tributário pode ser informadas.
			If ! ( LE9->( MsSeek( xFilial( "LE9", cFilItem ) + T0S->T0S_ID + FWFldGet( "T0N_IDTRIB" ) ) ) )
				cLogValid += STR0057 + CRLF + CRLF //"A conta deverá ter o mesmo tributo do Evento tributário."
				lRet := .F.
			EndIf
		EndIf
		
		If cOrigem == ORIGEM_CONTA_CONTABIL
			
			cEfeito := GetValueCmp( "T0O_EFEITO" )
			
			If Empty( cEfeito ) .or. cEfeito == EFEITO_NAO_APLICAVEL
				cLogValid += STR0052 + CRLF + CRLF //"É necessário selecionar um Efeito antes de selecionar uma conta da parte B do Lalur"
				lRet := .F.
			EndIf
			
			//Nos Grupos de Adições do Lucro e Adições por Doação
			If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
				
				//Se o efeito for "Constituir saldo na Conta", devem ser apresentadas contas da Parte B com natureza de "Exclusão".
				If cEfeito == EFEITO_CONSTITUIR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO
						cLogValid += STR0053 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B deverá ser de natureza de 'Exclusão'"
						lRet := .F.
					EndIf
				
				//Se o efeito for "Baixar saldo da Conta", devem ser apresentadas contas da Parte B com natureza de "Adição".
				ElseIf cEfeito == EFEITO_BAIXAR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_ADICAO
						cLogValid += STR0054 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B deverá ser de natureza de 'Adição'"
						lRet := .F.
					EndIf
				EndIf
				
			//No Grupo de Exclusões do Lucro
			ElseIf nIdGrupo == GRUPO_EXCLUSOES_LUCRO
				
				//Se o efeito for "Constituir saldo na Conta", devem ser apresentadas contas da Parte B com natureza de "Adição".
				If cEfeito == EFEITO_CONSTITUIR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_ADICAO
						cLogValid += STR0054 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B deverá ser de natureza de 'Adição'"
						lRet := .F.
					EndIf
				
				//Se o efeito for "Baixar saldo da Conta", devem ser apresentadas contas da Parte B com natureza de "Exclusão".
				ElseIf cEfeito == EFEITO_BAIXAR_SALDO
					If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO
						cLogValid += STR0053 + CRLF + CRLF //"Para o 'Efeito' (T0O_EFEITO) informado, a conta da Parte B deverá ser de natureza de 'Exclusão'"
						lRet := .F.
					EndIf
				EndIf
			EndIf
			
		ElseIf cOrigem == ORIGEM_LALUR_PARTE_B
		
			//Grupos de "Adições do Lucro" e "Adições por Doação"
			If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
				//filtrar contas com Natureza de Adição
				If T0S->T0S_NATURE <> NATUREZA_ADICAO
					cLogValid += STR0059 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B deverá ser de natureza de 'Adição'"
					lRet := .F.
				EndIf
				
			//Grupo de "Exclusões do Lucro"
			ElseIf nIdGrupo == GRUPO_EXCLUSOES_LUCRO
				//filtrar contas com Natureza de Exclusão
				If T0S->T0S_NATURE <> NATUREZA_EXCLUSAO
					cLogValid += STR0060 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B deverá ser de natureza de 'Exclusão'"
					lRet := .F.
				EndIf
				
			//Grupo de "Compensação de Prejuízo"
			ElseIf nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO
				 //filtrar contas com Natureza de Compensação de Prej./BC Negativa
				If T0S->T0S_NATURE <> NATUREZA_COMPENSACAO_BASE_NEGATIVA
					cLogValid += STR0061 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B deverá ser de natureza de 'Compensação de Prej./BC Negativa'"
					lRet := .F.
				EndIf
				 
			//Grupos de "Deduções" e "Compensações do Tributo"
			ElseIf nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
				//filtrar contas com Natureza de Dedução/Compensação de Tributo
				If T0S->T0S_NATURE <> NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO
					cLogValid += STR0062 + CRLF + CRLF //"Para a 'Origem' informada, a conta da Parte B deverá ser de natureza de 'Dedução/Compensação de Tributo'"
					lRet := .F.
				EndIf
				 
			EndIf
		Else
			cLogValid += STR0051 + CRLF + CRLF //"A Origem ('T0O_ORIGEM') precisa ser informada antes da conta da parte B do Lalur."
			lRet := .F.
		EndIf
	EndIf
EndIf
	
If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_IDCUST|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_IDCUST" )
	
	//O campo "Centro de Custo" só estará disponível quando a Origem for "Conta Contábil"
	If !Empty( xValueCmp ) .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0031 + CRLF + CRLF //"O campo 'Centro de Custo' só pode ser utilizado quando a Origem for 'Conta Contábil' "
		lRet := .F.
	EndIf
	
	//O centro de custo preenchido precisa ser da Filial selecionada no campo "Filial"
	C1P->( DbSetOrder( 3 ) )
	If !Empty( xValueCmp ) .and. !( C1P->( MsSeek( xFilial( "C1P", cFilItem ) + xValueCmp ) ) )
		cLogValid += STR0032 + CRLF + CRLF //"Este Centro de Custo não existe na Filial informada no campo T0O_FILITE"
		lRet := .F.
	EndIf
EndIf
	
If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_TIPOCC|T0O_ORIGEM"

	xValueCmp := GetValueCmp( "T0O_TIPOCC" )
	
	//As opções "Saldo Anterior" e "Saldo Atual" estarão disponíveis somente quando a Origem for "Conta Contábil"
	If xValueCmp $ "4|5" .and. ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL )
		cLogValid += STR0033 + CRLF + CRLF //"As opções 'Saldo Anterior' e 'Saldo Atual' só podem ser utilizadas quando a Origem for 'Conta Contábil'"
		lRet := .F.
	EndIf
	
	//Quando a origem for "Lalur – Parte B" a opção "Débito" estará disponível somente nos Grupos "Adições do Lucro" e "Adições por Doação"
	If cOrigem == ORIGEM_LALUR_PARTE_B .and. xValueCmp $ "1|" .and. nIdGrupo <> GRUPO_ADICOES_LUCRO .and. nIdGrupo <> GRUPO_ADICOES_DOACAO
		cLogValid += STR0034 + CRLF + CRLF //"Quando a origem for 'Lalur – Parte B' a opção 'Débito' estará disponível somente nos Grupos 'Adições do Lucro' e 'Adições por Doação'"
		lRet := .F.
	EndIf
	
	//Quando a origem for "Lalur – Parte B" a opção "Crédito" estará indisponível nos Grupos "Adições do Lucro" e "Adições por Doação
	If cOrigem == ORIGEM_LALUR_PARTE_B .and. xValueCmp $ "2|" .and. ( nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO )
		cLogValid += STR0035 + CRLF + CRLF //"Quando a origem for 'Lalur – Parte B' a opção 'Crédito' não poderá ser utilizada nos Grupos 'Adições do Lucro' e 'Adições por Doação'"
		lRet := .F.
	EndIf 
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_EFEITO|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_EFEITO" )
	
	//O campo "Efeito na Parte B do Lalur" só estará disponível quando a Origem for "Conta Contábil"
	If !Empty( xValueCmp ) .and. ( ( Empty( cOrigem ) .or. cOrigem <> ORIGEM_CONTA_CONTABIL ) .and. xValueCmp <> EFEITO_INCLUIR_LANC_AUTOMATICO )
		cLogValid += STR0036 + CRLF + CRLF //"O campo 'Efeito na Parte B do Lalur' só poderá ser preenchido quando a Origem for 'Conta Contábil'"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODEVE|T0O_ORIGEM"
	
	xValueCmp := GetValueCmp( "T0O_CODEVE" )
	
	If !Empty( xValueCmp )
		//O campo " Evento Tributário" só estará disponível quando a Origem for "Evento Tributário"
		If Empty( cOrigem ) .or. cOrigem <> ORIGEM_EVENTO_TRIBUTARIO
			cLogValid += STR0037 + CRLF + CRLF //"O Evento Tributário só pode ser preenchido quando a Origem for 'Evento Tributário'"
			lRet := .F.
		EndIf

		aAreaBkp := T0N->( GetArea() )
		
		T0N->( DbSetOrder( 2 ) )
		If T0N->( MsSeek( xFilial( "T0N" ) + xValueCmp ) )
			
			T0K->( DbSetOrder( 1 ) )
			If T0K->( DbSeek ( xFilial("T0K") + T0N->T0N_IDFTRI ) )
				cFormaTrib := T0K->T0K_CODIGO
				If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
					//Apenas Eventos Tributários que estejam com a forma de tributação "Lucro Real - Lucro da exploração" podem ser selcionados.
					cLogValid += STR0038 + CRLF + CRLF //"Apenas Eventos Tributários que estejam com a forma de tributação 'Lucro Real - Lucro da exploração' podem ser selecionados."
					lRet := .F.
				EndIf
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //"Código inválido."
			lRet := .F.
		EndIf
		
		RestArea( aAreaBkp )
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_PROUNI|T0O_ATIVID"
	
	xValueCmp := GetValueCmp( "T0O_PROUNI" )
	
	//O campo "Prouni" deve ser habilitado se o Tipo de Atividade for "Isenção"
	If !Empty( xValueCmp ) .and. GetValueCmp( "T0O_ATIVID" ) <> ATIVIDADE_ISENCAO
		cLogValid += STR0040 + CRLF + CRLF //"O campo 'Prouni' somente poderá ser preenchido se o Tipo de Atividade for 'Isenção'"
		lRet := .F.
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_PERRED|T0O_ATIVID"
	
	xValueCmp := GetValueCmp( "T0O_PERRED" )
	
	//Este "% de Redução" deve ser habilitado se o Tipo de Atividade for "Redução"
	If !Empty( xValueCmp ) .and. GetValueCmp( "T0O_ATIVID" ) <> ATIVIDADE_REDUCAO
		cLogValid += STR0041 + CRLF + CRLF //"O campo '% de Redução' somente poderá ser preenchido se o Tipo de Atividade for 'Redução'"
		lRet := .F.
	EndIf

EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF|LEC_CODECF"

	If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF"
		xValueCmp := GetValueCmp( "T0O_CODECF" )
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODECF"
		xValueCmp := FWFldGet( "LEC_CODECF" )
	EndIf

	If !Empty( xValueCmp )
		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		T0J->( DBSetOrder( 1 ) )
		If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
			cTributo := T0J->T0J_TPTRIB
		EndIf

		//Se nenhum tributo for selecionado nada deverá ser apresentado
		If Empty( cTributo ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
			cLogValid += STR0042 + CRLF + CRLF //"Selecione um tributo antes de selecionar o código da tabela dinâmica."
			lRet := .F.
		Else

			If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODECF"
				nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
			EndIf

			cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

			If !( cCodTDECF $ xValueCmp ) .or. Empty( cCodTDECF )
				cLogValid += STR0039 + CRLF + CRLF //"Código inválido."
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL|LEC_CODLAL"

	If AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL"
		xValueCmp := GetValueCmp( "T0O_CODLAL" )
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL"
		xValueCmp := FWFldGet( "T0O_CODLAL" )
	EndIf

	If !Empty( xValueCmp )
		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		T0J->( DBSetOrder( 1 ) )
		If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
			cTributo := T0J->T0J_TPTRIB
		EndIf

		//Se nenhum tributo for selecionado nada deverá ser apresentado
		If Empty( cTributo ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
			cLogValid += STR0042 + CRLF + CRLF //"Selecione um tributo antes de selecionar o código da tabela dinâmica."
			lRet := .F.
		Else
			cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )
			If !( cCodTDECF $ xValueCmp ) .or. Empty( cCodTDECF )
				cLogValid += STR0039 + CRLF + CRLF //"Código inválido."
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0N_CODEVE"
	
	xValueCmp := FWFldGet( "T0N_CODEVE" )
	
	If !Empty( xValueCmp )
		aAreaBkp := T0N->( GetArea() )
		
		T0N->( DbSetOrder( 2 ))
		If T0N->( MsSeek( xFilial( "T0N" ) + xValueCmp ) )
		
			T0K->( DbSetOrder( 1 ) )
			If T0K->( DbSeek ( xFilial( "T0K" ) + T0N->T0N_IDFTRI ) )
				cFormaTrib := T0K->T0K_CODIGO
				If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
					//Apenas Eventos Tributários que estejam com a forma de tributação "Lucro Real - Atividade Rural" podem ser selcionados.
					cLogValid += STR0043 + CRLF + CRLF //"Apenas Eventos Tributários que estejam com a forma de tributação 'Lucro Real - Atividade Rural' podem ser selecionados."
					lRet := .F.
				EndIf
			EndIf
			
			If FWFldGet( "T0N_IDTRIB" ) <> T0N->T0N_IDTRIB
				cLogValid += STR0074 + CRLF + CRLF //"Apenas eventos com o mesmo tributo podem ser relacionados"
				lRet := .F.
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //'Código inválido.'
			lRet := .F.
		EndIf
		
		RestArea( aAreaBkp )
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0N_COTRIB"
	
	xValueCmp := FWFldGet( "T0N_COTRIB" )
	If !Empty( xValueCmp )
		T0J->( DbSetOrder( 2 ) )
		If T0J->( DbSeek ( xFilial( "T0J" ) + xValueCmp ) )
			cTributo := T0J->T0J_TPTRIB
			If cTributo <> TRIBUTO_IRPJ .and. cTributo <> TRIBUTO_CSLL
				cLogValid += STR0039 + CRLF + CRLF //'Código inválido.'
				lRet := .F.
			EndIf
		Else
			cLogValid += STR0039 + CRLF + CRLF //'Código inválido.'
			lRet := .F.
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp , 4 ) ) $ "T0O_CODTDE"

	xValueCmp := GetValueCmp( "T0O_CODTDE" )
	
	If !Empty( xValueCmp )
		If !( "N600" $ xValueCmp )
			cLogValid += STR0039 + CRLF + CRLF //'Código inválido.'
			lRet := .F.
		 EndIf
	 EndIf
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODGRU"
	xValueCmp := FWFldGet( "LEC_CODGRU" )

	If !Empty( xValueCmp )

		T0K->( DBSetOrder( 1 ) )
		If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
			cFormaTrib := T0K->T0K_CODIGO
		EndIf

		cGrupo := GetGrupo( cFormaTrib )

		If !( xValueCmp $ cGrupo )
			cLogValid += STR0039 + CRLF + CRLF //"Código inválido."
			lRet := .F.
		EndIf
	EndIf

EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_ATIVID|LEC_PROUNI|LEC_PERRED|LEC_CODTDE"

	If Val( FWFldGet( "LEC_CODGRU" ) ) <> GRUPO_RECEITA_LIQUIDA_ATIVIDA
		cLogValid += STR0073 + CRLF + CRLF //"Este campo só pode ser editado quando o Grupo for 'Receita Líquida p/Atividade'."
		lRet := .F.
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_PROUNI" .and. FWFldGet( "LEC_ATIVID" ) <> ATIVIDADE_ISENCAO
		cLogValid += STR0040 + CRLF + CRLF //"O campo 'Prouni' somente poderá ser preenchido se o Tipo de Atividade for 'Isenção'"
		lRet := .F.
	ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_PERRED" .and. FWFldGet( "LEC_ATIVID" ) <> ATIVIDADE_REDUCAO
		cLogValid += STR0041 + CRLF + CRLF //"O campo '% de Redução' somente poderá ser preenchido se o Tipo de Atividade for 'Redução'"
		lRet := .F.
	EndIf

EndIf

If !Empty( cLogValid )
	Help( ,, "HELP",, cLogValid, 1, 0 )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FilSXBEven

Função responsável por gerenciar os filtros que precisam ser
aplicados nas consultas padrões do cadastro de evento tributário

@Param cCmp - Campo a qual o filtro será aplicado
		
@return Nil

@author David Costa
@since 27/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilSXBEven( cCmp )

Local cRet			as character
Local cTributo	as character
Local cFormaTrib	as character
Local cCodTDECF	as character
Local cGrupo		as character
Local nIdGrupo	as numeric

cRet		:=	""
cTributo	:=	""
cFormaTrib	:=	""
cCodTDECF	:=	""
cGrupo		:=	""
nIdGrupo	:=	0

If "T0N_CODEVE" $ cCmp
	//Deverá apresentar para seleção, apenas os Eventos Tributários que estejam com a forma de tributação "Lucro Real - Atividade Rural"
	cRet := "@# T0N_IDFTRI == 'ebf125bc-3140-9c7b-1e01-de4a61fd16e3' @#"

ElseIf "T0O_CODEVE" $ cCmp	
	//Devem ser listados apenas os Eventos Tributários com a forma de tributação "Lucro Real - Lucro da exploração"
	cRet := "@# T0N_IDFTRI == '1a46ceda-ffae-fa0f-0d9b-693dcb256849' @#"

//Apresentar somente os tributos referentes à IRPJ, CSLL. Listar informações da tabela de Tributo.
ElseIf "T0N_COTRIB" $ cCmp
	cRet := "@# T0J_TPTRIB == '" + TRIBUTO_IRPJ + "' .or. T0J_TPTRIB == '" + TRIBUTO_CSLL + "' @#"

//Regras de visibilidade dos itens da tabela dinâmica da ECF
ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODECF|LEC_CODECF"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	T0J->( DBSetOrder( 1 ) )
	If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
		cTributo := T0J->T0J_TPTRIB
	EndIf

	If "T0O_CODECF" $ cCmp
		nIdGrupo := GetValueCmp( "T0O_IDGRUP" )
	ElseIf "LEC_CODECF" $ cCmp
		nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
	EndIf

	cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

	If Empty( cCodTDECF )
		cRet := "@# 1 == 0 @#" //Nada será apresentado
	Else
		cRet := "@# CH6_CODREG == '" + cCodTDECF + "' @#"
	EndIf

//Regras de visibilidade dos itens da tabela dinâmica do Lalur
ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODLAL|LEC_CODLAL"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	T0J->( DBSetOrder( 1 ) )
	If T0J->( DBSeek( xFilial( "T0J" ) + FWFldGet( "T0N_IDTRIB" ) ) )
		cTributo := T0J->T0J_TPTRIB
	EndIf

	If "T0O_CODLAL" $ cCmp
		nIdGrupo := GetValueCmp( "T0O_IDGRUP" )
	ElseIf "LEC_CODLAL" $ cCmp
		nIdGrupo := Val( FWFldGet( "LEC_CODGRU" ) )
	EndIf

	cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

	If Empty( cCodTDECF )
		cRet := "@# 1 == 0 @#" //Nada será apresentado
	Else
		cRet := "@# CH8_CODREG == '" + cCodTDECF + "' @#"
	EndIf

ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "T0O_CODTDE|LEC_CODTDE"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
		cRet := "@# CH6_CODREG == 'N600 ' @#"
	Else
		cRet := "@# 1 == 0 @#" //Nada será apresentado
	EndIf

ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "LEC_CODGRU"

	T0K->( DBSetOrder( 1 ) )
	If T0K->( DBSeek( xFilial( "T0K" ) + FWFldGet( "T0N_IDFTRI" ) ) )
		cFormaTrib := T0K->T0K_CODIGO
	EndIf

	cGrupo := GetGrupo( cFormaTrib )

	cRet := "@#LEE_CODIGO $ '" + cGrupo + "' @#"

EndIf

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PutcModel
Função responsável por alimentar a variavel global cModel com o nome do model em edição no momento

@Param cModel - Nome do Model
		cField - Nome do campo que está em edição
		
@return .T.

@author David Costa
@since 28/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PutcModel( cModel, cField  )

If !Empty( cField ) .and. ( cField $ "|T0O_ORIGEM|T0O_FILITE|T0O_CODCC|T0O_OPERAC|T0O_CODCC|T0O_IDCUST|T0O_TIPOCC|T0O_EFEITO|T0O_CODEVE|T0O_PROUNI|T0O_ATIVID|T0O_PERRED|T0O_CODECF|T0O_CODTDE|T0O_CODLAL|T0O_CODPAB|" .or. "T0R_" $ cField )
	PutGlbValue( "cModel" , cModel )
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValueCmp

Retorna um valor de um campo da linha em edição no formulário.

@Param		cField - Nome do campo que está em edição

@Return	.T.

@Author	David Costa
@Since		28/04/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetValueCmp( cField )

Local cModel		as character
Local oModel		as object
Local oModelEdit	as object
Local xRet

cModel		:=	GetGlbValue( "cModel" )
oModel		:=	FWModelActive()
oModelEdit	:=	oModel:GetModel( cModel )
xRet		:=	Nil

If !Empty( cModel )
	oModelEdit := oModel:GetModel( cModel )
	xRet := oModelEdit:GetValue( cField )
EndIf

Return( xRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldHistEve
Valida se o Historico padrão pode ser inserido conforme regras de negocio

@Param  cAction -> Ação que esta sendo executada

@Return lRet

@Author David Costa
@Since 29/04/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldHistEve( cAcao )

Local oModel		as object
Local oModelHist	as object
Local cLogValid	as character
Local cModel		as character
Local nI			as numeric
Local lRet			as logical

oModel		:=	Nil
oModelHist	:=	Nil
cLogValid	:=	""
cModel		:=	""
nI			:=	0
lRet		:=	.T.

//O campo "Histórico Padrão" só estará disponível quando a Origem for "Conta Contábil".
If GetValueCmp( "T0O_ORIGEM" ) <> ORIGEM_CONTA_CONTABIL
	
	If cAcao == 'ALTERACAO_ORIGEM'
		
		cModel		:= GetGlbValue( "cModel" )
		oModel		:= FWModelActive()
		cModel		:= StrTran( cModel, "T0O_", "T0R_" )
		oModelHist	:= oModel:GetModel( cModel )
		
		For nI := 1 To oModelHist:Length()
			oModelHist:GoLine( nI )
			If !oModelHist:IsDeleted() .and. !Empty( oModelHist:GetValue( "T0R_IDHIST" ) )
				lRet := .F.
				exit
			EndIf
		Next nI

	ElseIf cAcao <> "DELETE" .and. !lCopia
		cLogValid := STR0044+ CRLF //"O Histórico Padrão só está disponível quando a Origem é 'Conta Contábil'."
		lRet := .F.
	EndIf
	
EndIf

If !Empty( cLogValid )
	Help( ,, "HELP",, cLogValid, 1, 0 )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Função de gravação dos dados, chamada no
final, no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return	lRet

@Author	David Costa
@Since		29/04/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local oModelT0O	as object
Local oModelT0N	as object
Local cModel		as character
Local cLogSave	as character
Local cFormaTrib	as character
Local nI			as numeric
Local nAux			as numeric
Local nIndiceT0O	as numeric
Local aGrupos		as array
Local lRet			as logical
Local lLucroEx	as logical

oModelT0O	:=	Nil
oModelT0N	:=	Nil
cModel		:=	""
cLogSave	:=	""
cFormaTrib	:=	""
nI			:=	0
nAux		:=	0
nIndiceT0O	:=	0
aGrupos	:=	GetGrupos( , .T. )
lRet		:=	.F.
lLucroEx	:=	.F. //Não modificar para False dentro do For

//Percorre todos os Grupos Tributários
For nI := 1 to Len( aGrupos )
	cModel := "MODEL_T0O_" + aGrupos[nI][PARAM_GRUPO_NOME]

	oModelT0O := oModel:GetModel( cModel )
	nAux := 0

	//Percorre os Itens do Grupo Tributário
	For nIndiceT0O := 1 to oModelT0O:Length()
		oModelT0O:GoLine( nIndiceT0O )

		If !oModelT0O:IsDeleted()
			Do Case
				Case aGrupos[nI][PARAM_GRUPO_ID] == GRUPO_COMPENSACAO_PREJUIZO

					//No Grupo "Compensação de Prejuízo" o percentual limite de compensação é único para todos os Itens Tributários que forem incluídos no Grupo
					If nAux == 0
						nAux := oModelT0O:GetValue( "T0O_PERDED" )
					ElseIf nAux <> oModelT0O:GetValue( "T0O_PERDED" )
						cLogSave += STR0045 + CRLF + CRLF //"No Grupo 'Compensação de Prejuízo' o percentual limite de compensação precisa ser o mesmo para todos os Itens Tributários."
					EndIf
			EndCase

			//Apenas um Item Tributário pode ser configurado com origem "Evento Tributário"
			If oModelT0O:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO

				If !lLucroEx
					lLucroEx := .T.
				Else
					cLogSave := STR0046 + CRLF + CRLF //"Apenas um Item Tributário pode ser configurado com a origem 'Evento Tributário'"
				EndIf
			EndIf
		EndIf
	Next nIndiceT0O
Next nI

oModelT0N := oModel:GetModel( "MODEL_T0N" )
cFormaTrib := xFunID2Cd( M->T0N_IDFTRI, "T0K", 1 )
If Empty( oModelT0N:GetValue( "T0N_COTRIB" ) ) .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO

	cLogSave += STR0049 + CRLF + CRLF //"O Tributo não foi preenchido."
EndIf

If !Empty( cLogSave )
	Help( ,, "HELP",, cLogSave, 1, 0 )
	lRet := .F.
Else
	FWFormCommit( oModel )
	lRet := .T.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsC1PA

Consulta Específica para Centro de Custo.

@Return	.T.

@Author	David Costa
@Since		03/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function ConsC1PA()

Local cAliasQry	as character
Local cTempTab	as character
Local cCampos		as character
Local cChave		as character
Local cTitle		as character
Local cReadVar	as character
Local cCombo		as character
Local cFilItem	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character
Local nPos			as numeric
Local nI			as numeric
Local aStruct		as array
Local aColumns	as array
Local aAux			as array
Local aIndex		as array
Local aSeek		as array
Local aCombo		as array
Local aID			as array
Local aCodigo		as array
Local aDescri		as array

cAliasQry	:=	GetNextAlias()
cTempTab	:=	""
cCampos	:=	"C1P_ID|C1P_CODCUS|C1P_CCUS"
cChave		:=	"C1P_ID"
cTitle		:=	STR0047 //"Centro de Custo"
cReadVar	:=	ReadVar()
cCombo		:=	""
cFilItem	:=	xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct	:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aID			:=	TamSX3( "C1P_ID" )
aCodigo	:=	TamSX3( "C1P_CODCUS" )
aDescri	:=	TamSX3( "C1P_CCUS" )

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	:= "C1P_ID, C1P_CODCUS, C1P_CCUS "
cFrom		:= RetSqlName( "C1P" ) + " C1P "
cWhere		:= "    C1P.C1P_FILIAL = '" + xFilial( "C1P", cFilItem ) + "' "
cWhere		+= "AND C1P.D_E_L_E_T_ = '' "
cOrderBy	:= "C1P.C1P_ID "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK"			, "C"			, 2				, 0 			} )
aAdd( aStruct, { "C1P_ID"		, aID[3]		, aID[1]		, aID[2]		} )
aAdd( aStruct, { "C1P_CODCUS"	, aCodigo[3]	, aCodigo[1]	, aCodigo[2]	} )
aAdd( aStruct, { "C1P_CCUS"		, aDescri[3]	, aDescri[1]	, aDescri[2]	} )

cTempTab := CriaTrab( aStruct, .T. )

DBUseArea( .T.,, cTempTab, cTempTab, .T., .F. )

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
( cTempTab )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )

	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		:=	"  "
		( cTempTab )->C1P_ID		:=	( cAliasQry )->C1P_ID
		( cTempTab )->C1P_CODCUS	:=	( cAliasQry )->C1P_CODCUS
		( cTempTab )->C1P_CCUS	:=	( cAliasQry )->C1P_CCUS
		( cTempTab )->( MsUnLock() )
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		//aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"

			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf

		EndIf

		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )

	EndIf
Next nI

//----------------------------
// Cria estrutura de índices
//----------------------------
aAux := aClone( aIndex )
aIndex := Array( Len( aAux ) )
nPos := 0

For nI := 1 to Len( aAux )
	nPos := Len( aAux ) - ( nI - 1 )
	aIndex[nPos] := aAux[nI]
Next nI

For nI := 1 to Len( aIndex )
	&( "cIndex" + AllTrim( Str( nI ) ) ) := CriaTrab( , .F. )
	IndRegua( cTempTab, &( "cIndex" + AllTrim( Str( nI ) ) ), aIndex[nI] )
Next nI

For nI := 1 to Len( aIndex )
	DBSetIndex( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//--------------------------------
// Apaga arquivo(s) temporário(s)
//--------------------------------
If !Empty( cTempTab )
	( cTempTab )->( DBCloseArea() )
	FErase( cTempTab + GetDBExtension() )

	For nI := 1 to Len( aIndex )
		FErase( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
	Next nI
EndIf

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsC1OA

Consulta Específica para Conta Contábil.

@Return	.T.

@Author	David Costa
@Since		03/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function ConsC1OA()

Local cAliasQry	:=	GetNextAlias()
Local cTempTab	:=	""
Local cCampos		:=	"C1O_CODIGO|C1O_DESCRI"
Local cChave		:=	"C1O_CODIGO"
Local cTitle		:=	STR0048 //"Conta Contábil"
Local cReadVar	:=	ReadVar()
Local cCombo		:=	""
Local cFilItem	:=	xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cOrderBy	:=	""
Local nPos			:=	0
Local nI			:=	0
Local aStruct		:=	{}
Local aColumns	:=	{}
Local aAux			:=	{}
Local aIndex		:=	{}
Local aSeek		:=	{}
Local aCombo		:=	{}
Local aCodigo		:=	TamSX3( "C1O_CODIGO" )
Local aDescri		:=	TamSX3( "C1O_DESCRI" )

cAliasQry	:=	GetNextAlias()
cTempTab	:=	""
cCampos	:=	"C1O_CODIGO|C1O_DESCRI"
cChave		:=	"C1O_CODIGO"
cTitle		:=	STR0048 //"Conta Contábil"
cReadVar	:=	ReadVar()
cCombo		:=	""
cFilItem	:=	xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct	:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aCodigo	:=	TamSX3( "C1O_CODIGO" )
aDescri	:=	TamSX3( "C1O_DESCRI" )

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	:= "C1O_CODIGO, C1O_DESCRI "
cFrom		:= RetSqlName( "C1O" ) + " C1O "
cWhere		:= "    C1O.C1O_FILIAL = '" + xFilial( "C1O", cFilItem ) + "' "
cWhere		+= "AND C1O.D_E_L_E_T_ = '' "
cOrderBy	:= "C1O.C1O_CODIGO "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK"			, "C"			, 2				, 0 			} )
aAdd( aStruct, { "C1O_CODIGO"	, aCodigo[3]	, aCodigo[1]	, aCodigo[2]	} )
aAdd( aStruct, { "C1O_DESCRI"	, aDescri[3]	, aDescri[1]	, aDescri[2]	} )

cTempTab := CriaTrab( aStruct, .T. )

DBUseArea( .T.,, cTempTab, cTempTab, .T., .F. )

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
( cTempTab )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )

	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		:=	"  "
		( cTempTab )->C1O_CODIGO	:=	( cAliasQry )->C1O_CODIGO
		( cTempTab )->C1O_DESCRI	:=	( cAliasQry )->C1O_DESCRI
		( cTempTab )->( MsUnLock() )
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		//aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"

			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf

		EndIf

		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		aAdd( aIndex, aStruct[nI,1] )
		aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )

	EndIf
Next nI

//----------------------------
// Cria estrutura de índices
//----------------------------
aAux := aClone( aIndex )
aIndex := Array( Len( aAux ) )
nPos := 0

For nI := 1 to Len( aAux )
	nPos := Len( aAux ) - ( nI - 1 )
	aIndex[nPos] := aAux[nI]
Next nI

For nI := 1 to Len( aIndex )
	&( "cIndex" + AllTrim( Str( nI ) ) ) := CriaTrab( , .F. )
	IndRegua( cTempTab, &( "cIndex" + AllTrim( Str( nI ) ) ), aIndex[nI] )
Next nI

For nI := 1 to Len( aIndex )
	DBSetIndex( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//--------------------------------
// Apaga arquivo(s) temporário(s)
//--------------------------------
If !Empty( cTempTab )
	( cTempTab )->( DBCloseArea() )
	FErase( cTempTab + GetDBExtension() )

	For nI := 1 to Len( aIndex )
		FErase( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
	Next nI
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatiIDCUST
Gatilho do campo T0O_IDCUST para o Campo T0O_DCUSTO

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GatiIDCUST( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1P" )
	C1P->( DbSetOrder( 3 ) )
	If MsSeek(xFilial( "C1P", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1P", 3, xFilial( "C1P", cFilItem ) + cValueCmp, "C1P->( AllTrim( C1P_CODCUS )+' - '+SubStr( C1P_CCUS, 1, 60 ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatiCODCC
Gatilho do campo T0O_CODCC para o campo T0O_IDCC

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GatiCODCC( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1O" )
	C1O->( DbSetOrder( 1 ) )
	If MsSeek( xFilial( "C1O", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1O", 1, xFilial( "C1O", cFilItem ) + cValueCmp, "C1O->C1O_ID" )
	EndIf
EndIf

Return( cValueCmp )
//-------------------------------------------------------------------
/*/{Protheus.doc} GatiCODCC2
Gatilho do campo T0O_CODCC para o campo T0O_DCONTC

@Return cValueCmp

@Author David Costa
@Since 03/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GatiCODCC2( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "C1O" )
	C1O->( DbSetOrder( 1 ) )
	If MsSeek( xFilial( "C1O", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "C1O", 1, xFilial( "C1O", cFilItem ) + cValueCmp, "C1O->( AllTrim( C1O_DESCRI ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodECF
Função para criação de consultas especificas para o eventro tributário

@Param cFormaTrib -> Forma de tributação do Evento tributário
		nIdGrupo -> Id do grupo tributário
		cTributo -> Tributo IRPJ ou CSLL

@Return cCodTDECF

@Author David Costa
@Since 09/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCodECF( cFormaTrib, nIdGrupo, cTributo )

Local cCodTDECF	as character
Local cQualifPJ	as character

cCodTDECF	:=	""
cQualifPJ	:=	""

//Lucro da exploração não apresenta o campo tributo
If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO
	If nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
		cCodTDECF := "N600"
 	EndIf
Else
	If cTributo == TRIBUTO_IRPJ
		Do Case
			Case cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "P200"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "P300"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "T120"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "T150"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "N500"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N620"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA
				If nIdGrupo == GRUPO_BASE_CALCULO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "U180"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				
				cQualifPJ := GetQualiPJ()
				
				If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO .or. nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL .or. nIdGrupo == GRUPO_ADICOES_DOACAO

					If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "M300A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "M300B"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL
			 			cCodTDECF := "M300C"
			 		EndIf
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "N630A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "N630B"
			 		EndIf
			 	EndIf
		EndCase
	ElseIf cTributo == TRIBUTO_CSLL
		Do Case
			Case cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "P400"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "P500"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "T170"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "T181"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
				If nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ1 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ2 .or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ3;
			 		.or. nIdGrupo == GRUPO_RECEITA_BRUTA_ALIQ4 .or. nIdGrupo == GRUPO_DEMAIS_RECEITAS .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA
			 		cCodTDECF := "N650"
			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N660"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA
				If nIdGrupo == GRUPO_BASE_CALCULO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "U182"
			 	EndIf
			Case cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL
				If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_COMPENSACAO_PREJUIZO .or. nIdGrupo == GRUPO_ADICOES_DOACAO .or. nIdGrupo == GRUPO_RESULTADO_OPERACIONAL .or. nIdGrupo == GRUPO_RESULTADO_NAO_OPERACIONAL

					cQualifPJ := GetQualiPJ()
					
					If cQualifPJ == QUALIFICACAO_PJ_EM_GERAL
			 			cCodTDECF := "M350A"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_FINANCEIRO
			 			cCodTDECF := "M350B"
			 		ElseIf cQualifPJ == QUALIFICACAO_PJ_SOCIEDADE_SEG_PREVIDENCIA_COMPL
			 			cCodTDECF := "M350C"
			 		EndIf

			 	ElseIf nIdGrupo == GRUPO_ADICIONAIS_TRIBUTO .or. nIdGrupo == GRUPO_DEDUCOES_TRIBUTO .or. nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
			 		cCodTDECF := "N670"
			 	EndIf
		EndCase
	EndIf
EndIf

Return( cCodTDECF )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQualiPJ

Retorna o código de Qualificação da Pessoa Jurídica
mais atual dos Parâmetros de Abertura da ECF.

@Return	cQualifPJ

@Author	David Costa
@Since		10/05/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetQualiPJ()

Local cQualifPJ	as character
Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character

cQualifPJ	:=	""
cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""

cSelect	:= " CHD_CODQUA "
cFrom		:= RetSqlName( "CHD" ) + " CHD "
cWhere		:= " CHD_PERFIN = ( SELECT MAX(CHD_PERFIN) FROM " + RetSqlName( "CHD" )
cWhere		+= " WHERE CHD.D_E_L_E_T_ = '' "
cWhere		+= " AND CHD_FILIAL = '" + xFilial( "CHD" ) + "' ) "
cOrderBy	:= " CHD_PERFIN DESC "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"
cOrderBy 	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

If ( cAliasQry )->( !( Eof() ) )
	cQualifPJ := ( cAliasQry )->CHD_CODQUA
EndIf

Return( cQualifPJ )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatCODPAB
Gatilho do campo T0O_CODPAB para o Campo T0O_DPARTB

@Return cValueCmp

@Author David Costa
@Since 16/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GatCODPAB( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "T0S" )
	T0S->( DbSetOrder( 2 ) )
	If MsSeek( xFilial( "T0S", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "T0S", 2, xFilial( "T0S", cFilItem ) + cValueCmp, "T0S->( AllTrim( T0S_DESCRI ) )" )
	EndIf
EndIf

Return( cValueCmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GatCODPAB2
Gatilho do campo T0O_CODPAB para o campo T0O_IDPARB

@Return cValueCmp

@Author David Costa
@Since 16/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GatCODPAB2( )

Local cValueCmp	as character
Local cFilItem	as character

cValueCmp	:=	&( ReadVar() )
cFilItem	:=	""

If !Empty( cValueCmp )
	
	cFilItem	:= XFUNCh2ID( GetValueCmp( "T0O_FILITE" ) , 'C1E' , 1 )

	DbSelectArea( "T0S" )
	T0S->( DbSetOrder( 2 ) )
	If MsSeek( xFilial( "T0S", cFilItem ) + cValueCmp )
		cValueCmp := Posicione( "T0S", 2, xFilial( "T0S", cFilItem ) + cValueCmp, "T0S->T0S_ID" )
	EndIf
EndIf

Return( cValueCmp )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConsT0SA

Consulta Específica para Conta da Parte B do Lalur.

@Return	.T.

@Author	David Costa
@Since		17/05/2016
@Version	1.0

@Altered by Felipe C. Seolin in 28/12/2016 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function ConsT0SA()

Local cAliasQry	as character
Local cTempTab	as character
Local cCampos		as character
Local cChave		as character
Local cTitle		as character
Local cReadVar	as character
Local cCombo		as character
Local cFilItem	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character
Local nPos			as numeric
Local nI			as numeric
Local aStruct		as array
Local aColumns	as array
Local aAux			as array
Local aIndex		as array
Local aSeek		as array
Local aCombo		as array
Local aCodigo		as array
Local aDescri		as array
Local aNature		as array

cAliasQry	:=	GetNextAlias()
cTempTab	:=	""
cCampos	:=	"T0S_CODIGO|T0S_DESCRI|T0S_NATURE"
cChave		:=	"T0S_CODIGO"
cTitle		:=	STR0058 //"Conta da Parte B do Lalur"
cReadVar	:=	ReadVar()
cCombo		:=	""
cFilItem	:=	xFunCh2ID( GetValueCmp( "T0O_FILITE" ), "C1E", 1 )
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct	:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aCodigo	:=	TamSX3( "T0S_CODIGO" )
aDescri	:=	TamSX3( "T0S_DESCRI" )
aNature	:=	TamSX3( "T0S_NATURE" )

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	:= "T0S_CODIGO, T0S_DESCRI, T0S_NATURE "
cFrom		:= RetSqlName( "T0S" ) + " T0S "
cWhere		:= "    T0S.T0S_FILIAL = '" + xFilial( "T0S", Iif( Empty( cFilItem ), xFilial( "T0S" ), cFilItem ) ) + "' "
cWhere		+= "AND T0S.D_E_L_E_T_ = '' "
cOrderBy	:= "T0S.T0S_CODIGO "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK"			, "C"			, 2				, 0 			} )
aAdd( aStruct, { "T0S_CODIGO"	, aCodigo[3]	, aCodigo[1]	, aCodigo[2]	} )
aAdd( aStruct, { "T0S_DESCRI"	, aDescri[3]	, aDescri[1]	, aDescri[2]	} )
aAdd( aStruct, { "T0S_NATURE"	, aNature[3]	, aNature[1]	, aNature[2]	} )

cTempTab := CriaTrab( aStruct, .T. )

DBUseArea( .T.,, cTempTab, cTempTab, .T., .F. )

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
( cTempTab )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )

	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		:=	"  "
		( cTempTab )->T0S_CODIGO	:=	( cAliasQry )->T0S_CODIGO
		( cTempTab )->T0S_DESCRI	:=	( cAliasQry )->T0S_DESCRI
		( cTempTab )->T0S_NATURE	:=	( cAliasQry )->T0S_NATURE
		( cTempTab )->( MsUnLock() )
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		//aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"

			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf

		EndIf

		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		If aStruct[nI,1] <> "T0S_NATURE"
			aAdd( aIndex, aStruct[nI,1] )
			aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )
		EndIf

	EndIf
Next nI

//----------------------------
// Cria estrutura de índices
//----------------------------
aAux := aClone( aIndex )
aIndex := Array( Len( aAux ) )
nPos := 0

For nI := 1 to Len( aAux )
	nPos := Len( aAux ) - ( nI - 1 )
	aIndex[nPos] := aAux[nI]
Next nI

For nI := 1 to Len( aIndex )
	&( "cIndex" + AllTrim( Str( nI ) ) ) := CriaTrab( , .F. )
	IndRegua( cTempTab, &( "cIndex" + AllTrim( Str( nI ) ) ), aIndex[nI] )
Next nI

For nI := 1 to Len( aIndex )
	DBSetIndex( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek )

//--------------------------------
// Apaga arquivo(s) temporário(s)
//--------------------------------
If !Empty( cTempTab )
	( cTempTab )->( DBCloseArea() )
	FErase( cTempTab + GetDBExtension() )

	For nI := 1 to Len( aIndex )
		FErase( &( "cIndex" + AllTrim( Str( nI ) ) ) + OrdBagExt() )
	Next nI
EndIf

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesNatu
Retorna a descrição da Natureza da conta parte B

@Param cNat -> Código da Natureza

@Return lRet

@Author David Costa
@Since 17/05/2016
@Version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function GetDesNatu( cNat )

Local cRet	as character

cRet	:=	""

Do Case
	Case cNat == NATUREZA_ADICAO
		cRet := STR0063 //"Adição"
	Case cNat == NATUREZA_EXCLUSAO
		cRet := STR0064 //"Exclusão"

	Case cNat == NATUREZA_COMPENSACAO_BASE_NEGATIVA
		cRet := STR0065 //"Compensação de Prejuízo/Base de Cálculo Negativa"
	
	Case cNat == NATUREZA_DEDUCAO_COMPENSACAO_TRIBUTO
		cRet := STR0066 //"Dedução/Compensação de Tributo "
   
EndCase

Return( cRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA433Cpy

Função para execução da Cópia do Evento Tributário. 

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFA433Cpy()

lCopia := .T.

If Perg433()
	FwExecView( STR0067, "TAFA433", 9,, { || .T. } ) //"Cópia do Evento Tributário"; 9 = Cópia
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiarEven

Função auxilixar para preparação do modelo para Cópia.

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function CopiarEven( cFTribDest, oModel )

Local oModelT0N	as object
Local cFTribOrig	as character
Local cTribuOrig	as character
Local cTribuDest	as character
Local cIDEvento	as character

oModelT0N	:=	Nil
cFTribOrig	:=	""
cTribuOrig	:=	""
cTribuDest	:=	""
cIDEvento	:=	TAFGeraID( "TAF" )

oModel:SetOperation( MODEL_OPERATION_UPDATE )
oModel:Activate( lCopia )

oModelT0N := oModel:GetModel( "MODEL_T0N" )

//Forma de Tributação do Evento de Destino
cFTribDest := cT0N_IDFTRI

//Forma de Tributação do Evento de Origem
cFTribOrig := xFunID2Cd( oModelT0N:GetValue( "T0N_IDFTRI" ), "T0K", 1 )

//Tributo do Evento de Destino
cTribuDest := cT0N_IDTRIB

//Tributo do Evento de Origem
cTribuOrig := xFunID2Cd( oModelT0N:GetValue( "T0N_IDTRIB" ), "T0J", 1 )

CopiaIdent( @oModelT0N, cIDEvento )
CopiaItens( @oModel, cIDEvento, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Perg433

Função para solicitar ao usuário a Forma de Tributação
e o Tributo do Evento de Destino. 

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function Perg433()

Local oDlg			as object
Local oFont		as object
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nLarguraSay	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local lRet			as logical

oDlg			:=	Nil
oFont			:=	TFont():New( "Arial",, -11 )
nLarguraBox	:=	0
nAlturaBox		:=	0
nLarguraSay	:=	0
nTop			:=	0
nAltura		:=	250
nLargura		:=	520
nPosIni		:=	0
lRet			:=	.F.

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0070,,,,,,,,, .T. ) //"Parâmetros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

//Como default será carregado os valores do evento de origem
cT0N_IDFTRI := xFunID2Cd( T0N->T0N_IDFTRI, "T0K", 1 )
cT0N_DFTRIB := Posicione( "T0K", 1, xFilial( "T0K" ) + T0N->T0N_IDFTRI, "T0K_DESCRI" )
cT0N_IDTRIB := xFunID2Cd( T0N->T0N_IDTRIB, "T0J", 1 )
cT0N_DTRIBU := Posicione( "T0J", 1, xFilial( "T0J" ) + T0N->T0N_IDTRIB, "T0J_DESCRI" )

nLarguraSay := nLarguraBox - 30
nTop := 20
TGet():New( nTop, 20, { |x| If( PCount() == 0, cT0N_IDFTRI, cT0N_IDFTRI := x ) }, oDlg, 65, 10, "@!", { || ValidPerg( 1 ) },,,,,, .T.,,,,,,,,, "T0KA",,,,,,,, STR0002, 1, oFont ) //"Forma de Tributação"
TGet():New( nTop + 8, 90, { |x| If( PCount() == 0, cT0N_DFTRIB, cT0N_DFTRIB := x ) }, oDlg, 152, 10, "@!",,,,,,, .T.,,, { || .F. } )
nTop += 30
TGet():New( nTop, 20, { |x| If( PCount() == 0, cT0N_IDTRIB, cT0N_IDTRIB := x ) }, oDlg, 65, 10, "@!", { || ValidPerg( 2 ) },,,,,, .T.,,,,,,,,, "T0J", "M->T0N_TGET_T0J",,,,,,, STR0069, 1, oFont ) //"Tributo"
TGet():New( nTop + 8, 90, { |x| If( PCount() == 0, cT0N_DTRIBU, cT0N_DTRIBU := x ) }, oDlg, 152, 10, "@!",,,,,,, .T.,,, { || .F. } )
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - ( 2 * 32 )

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( lRet := ValidPergOk(), x:oWnd:End(), ) }, oDlg )
SButton():New( nAlturaBox + 10, nPosIni + 32, 2, { |x| x:oWnd:End() }, oDlg )

oDlg:Activate( ,,,.T. )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidPergOk

Validação do botão para confirmar a entrada de todos os dados dos
parâmetros da funcionalidade de Cópia do Evento Tributário.

@Return	lRet - Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		09/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ValidPergOk()

Local lRet	as logical

lRet	:=	.T.

If !(	ValidPerg( 1 ) .and.;
		ValidPerg( 2 ) )
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg

Valida se os parâmetros preenchidos pelo 
usuário durante a Cópia são válidos.

@Return	lRet - Indica se as condições foram respeitadas

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidPerg( nOpc )

Local lRet	as logical

lRet	:=	.T.

If nOpc == 1

	If !Empty( cT0N_IDFTRI )
		If T0K->( DBSetOrder( 2 ), T0K->( MsSeek( xFilial( "T0K" ) + cT0N_IDFTRI ) ) )
			cT0N_IDFTRI := T0K->T0K_CODIGO
			cT0N_DFTRIB := AllTrim( T0K->T0K_DESCRI )
		Else
			MsgInfo( STR0084 ) //"Forma de Tributação inválida"
			lRet := .F.
		EndIf
	Else
		MsgInfo( STR0085 ) //"Forma de Tributação não informada"
		lRet := .F.
	EndIf

ElseIf nOpc == 2

	If !Empty( cT0N_IDTRIB )
		If T0J->( DBSetOrder( 2 ), T0J->( MsSeek( xFilial( "T0J" ) + cT0N_IDTRIB ) ) )
			If !Empty( T0J->T0J_TPTRIB ) .and. ( T0J->T0J_TPTRIB == TRIBUTO_IRPJ .or. T0J->T0J_TPTRIB == TRIBUTO_CSLL )
				cT0N_IDTRIB := T0J->T0J_CODIGO
				cT0N_DTRIBU := AllTrim( T0J->T0J_DESCRI )
			Else
				MsgInfo( STR0086 ) //"Tributo inválido"
				lRet := .F.
			EndIf
		Else
			MsgInfo( STR0086 ) //"Tributo inválido"
			lRet := .F.
		EndIf
	Else
		MsgInfo( STR0087 ) //"Tributo não informado"
		lRet := .F.
	EndIf

EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiaIdent

Ajusta os campos da Identificação que não serão copiados

@Return Nil 

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CopiaIdent( oModelT0N, cIDEvento )

oModelT0N:SetValue( "T0N_ID", cIDEvento )
oModelT0N:SetValue( "T0N_CODIGO", "" )
oModelT0N:SetValue( "T0N_DESCRI", "" )
oModelT0N:SetValue( "T0N_IDFTRI", xFunCh2ID( cT0N_IDFTRI, "T0K", 2 ) )
oModelT0N:SetValue( "T0N_CODFTR", cT0N_IDFTRI )
oModelT0N:SetValue( "T0N_DFTRIB", Posicione( "T0K", 2, xFilial( "T0K" ) + cT0N_IDFTRI, "AllTrim( T0K_DESCRI )" ) )
oModelT0N:SetValue( "T0N_IDEVEN", "" )
oModelT0N:SetValue( "T0N_CODEVE", "" )
oModelT0N:SetValue( "T0N_DEVENT", "" )
oModelT0N:SetValue( "T0N_IDTRIB", xFunCh2ID( cT0N_IDTRIB, "T0J", 2 ) )
oModelT0N:SetValue( "T0N_COTRIB", cT0N_IDTRIB )
oModelT0N:SetValue( "T0N_DTRIBU", Posicione( "T0J", 2, xFilial( "T0J" ) + cT0N_IDFTRI, "AllTrim( T0J_DESCRI )" ) )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CopiaItens

Ajusta os campos dos itens tributários removendo os que não poderão ser copiados

@Return Nil 

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CopiaItens( oModel, cIDEvento, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Local oModelT0O	as object
Local oModelT0P	as object
Local oModelT0R	as object
Local nIndiceT0O	as numeric
Local nIndiceT0P	as numeric
Local nIndiceT0R	as numeric
Local nIndiceGrup	as numeric
Local aGrupos		as array

oModelT0O		:=	Nil
oModelT0P		:=	Nil
oModelT0R		:=	Nil
nIndiceT0O		:= 0
nIndiceT0P		:= 0
nIndiceT0R		:= 0
nIndiceGrup	:= 0
aGrupos		:= GetGrupos( , .T. )

For nIndiceGrup := 1 To Len( aGrupos )
	
	//Grupo Tributário
	oModelT0O := oModel:GetModel( "MODEL_T0O_" + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ]  )
	For nIndiceT0O := 1 To oModelT0O:Length()
		
		oModelT0O:GoLine( nIndiceT0O )
		
		If PodeCopiar( aGrupos[ nIndiceGrup ][ PARAM_GRUPO_ID ], cFTribDest, cFTribOrig )

			If !Empty( oModelT0O:GetValue( "T0O_ID" ) )
			
				oModelT0O:SetValue( "T0O_ID", cIDEvento )
				CpyOrigem( @oModelT0O, cFTribDest )
				CpyCodECF( @oModelT0O, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )
				CpyContaB( @oModelT0O, cTribuDest, cTribuOrig )
				
			EndIf
		Else
			oModelT0O:DeleteLine()
		EndIf
	Next nIndiceT0O
	
	//Processos
	oModelT0P := oModel:GetModel( 'MODEL_T0P_' + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ] )				
	For nIndiceT0P := 1 To oModelT0P:Length()
		oModelT0P:GoLine( nIndiceT0P )
		If !Empty( oModelT0P:GetValue( "T0P_ID" ) )
			oModelT0P:SetValue( "T0P_ID", cIDEvento )
		EndIf
	Next nIndiceT0P
	
	//Histórico Padrão
	oModelT0R := oModel:GetModel( 'MODEL_T0R_' + aGrupos[ nIndiceGrup ][ PARAM_GRUPO_NOME ] )
	For nIndiceT0R := 1 To oModelT0R:Length()
		oModelT0R:GoLine( nIndiceT0R )
		If !Empty( oModelT0R:GetValue( "T0R_ID" ) )
			oModelT0R:SetValue( "T0R_ID", cIDEvento )
		EndIf
	Next nIndiceT0R
	
Next nIndiceGrup

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} PodeCopiar

Verifica se o Item tributário pode ser levado para o Evento de destino

@Param nIdGrupo -> Id do Grupo do Evento de Destino
		 cFTribDest -> Forma de tributação do Evento de destino
		 cFTribOrig -> Forma de tributação do Evento de Origem

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function PodeCopiar( nIdGrupo, cFTribDest, cFTribOrig )

Local aGrupoDest	as array
Local lRet			as logical

aGrupoDest	:=	GetGrupos( cFTribDest )
lRet		:=	.F.

lRet := cFTribDest == cFTribOrig
lRet := lRet .or. ( aScan( aGrupoDest, { |x| x[ PARAM_GRUPO_ID ] == nIdGrupo } ) <> 0 )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrupos

Retorna um array com os parametros do grupo do evento tributário
Exemplo:
	aGrupo[x][1] Id do Grupo
	aGrupo[x][2] Nome do Grupo
	aGrupo[x][3] Descrição do Grupo
	aGrupo[x][4] Tipo do Grupo que pode ser:
					1 - Grupo da Base de Calculo
					2 - Grupo do Calculo do Tributo 

@Param nIdGrupo -> Id do Grupo do Evento de Destino
		 cFTribDest -> Forma de tributação do Evento de destino
		 cFTribOrig -> Forma de tributação do Evento de Origem

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetGrupos( cFormaTrib, lTodos )

Local aGruposEve	as array

Default cFormaTrib	:=	""
Default lTodos		:=	.F.

aGruposEve	:=	{}

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO .or. lTodos
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ1, 'RECEITA_BRUTA_ALIQ1', STR0007, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 1"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ2, 'RECEITA_BRUTA_ALIQ2', STR0008, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 2"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ3, 'RECEITA_BRUTA_ALIQ3', STR0009, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 3"
	Aadd( aGruposEve, { GRUPO_RECEITA_BRUTA_ALIQ4, 'RECEITA_BRUTA_ALIQ4', STR0010, TIPO_GRUPO_BASE_CALCULO } )		//"Receita Bruta - Aliquota 4"
	Aadd( aGruposEve, { GRUPO_DEMAIS_RECEITAS, 'DEMAIS_RECEITAS', STR0011, TIPO_GRUPO_BASE_CALCULO } )				//"Demais Receitas"
	Aadd( aGruposEve, { GRUPO_EXCLUSOES_RECEITA, 'EXCLUSOES_RECEITA', STR0015, TIPO_GRUPO_BASE_CALCULO } )			//"Exclusões da Receita"
EndIf

If cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA .or. lTodos
	Aadd( aGruposEve, { GRUPO_BASE_CALCULO, 'BASE_CALCULO_IMUNE_ISENTA', STR0006, TIPO_GRUPO_BASE_CALCULO } )			//"Base de Cálculo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL .or. lTodos
	aAdd( aGruposEve, { GRUPO_RESULTADO_OPERACIONAL, "RESULTADO_OPERACIONAL", STR0143, TIPO_GRUPO_BASE_CALCULO } )				//"Resultado Operacional"
	aAdd( aGruposEve, { GRUPO_RESULTADO_NAO_OPERACIONAL, "RESULTADO_NAO_OPERACIONAL", STR0142, TIPO_GRUPO_BASE_CALCULO } )		//"Resultado Não Operacional"
	aAdd( aGruposEve, { GRUPO_ADICOES_LUCRO, "ADICOES_LUCRO", STR0012, TIPO_GRUPO_BASE_CALCULO } )									//"Adições do Lucro"
	aAdd( aGruposEve, { GRUPO_ADICOES_DOACAO, "ADICOES_DOACAO", STR0013, TIPO_GRUPO_BASE_CALCULO } )								//"Adições Doação"
	aAdd( aGruposEve, { GRUPO_EXCLUSOES_LUCRO, "EXCLUSOES_LUCRO", STR0014, TIPO_GRUPO_BASE_CALCULO } )							//"Exclusões do Lucro"
	aAdd( aGruposEve, { GRUPO_COMPENSACAO_PREJUIZO, "COMPENSACAO_PREJUIZO", STR0016, TIPO_GRUPO_BASE_CALCULO } )					//"Compensação de Prejuízo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO .or. lTodos
	aAdd( aGruposEve, { GRUPO_ADICIONAIS_TRIBUTO, "ADICIONAIS_TRIBUTO", STR0017, TIPO_GRUPO_CALCULO_TRIBUTO } ) //"Adicionais do Tributo"
EndIf

If cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .or. lTodos
	Aadd( aGruposEve, { GRUPO_RECEITA_LIQUIDA_ATIVIDA, 'RECEITA_LIQ_ATIVIDADE', STR0018, TIPO_GRUPO_BASE_CALCULO } )	//"Receita Líquida por Atividade"
	Aadd( aGruposEve, { GRUPO_LUCRO_EXPLORACAO, 'LUCRO_EXPLORACAO', STR0019, TIPO_GRUPO_BASE_CALCULO } )					//"Lucro da Exploração"
EndIf

If cFormaTrib <> TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFormaTrib <> TRIBUTACAO_LUCRO_REAL_ATIV_RURAL .or. lTodos
	Aadd( aGruposEve, { GRUPO_DEDUCOES_TRIBUTO, 'DEDUCOES_TRIBUTO', STR0023, TIPO_GRUPO_CALCULO_TRIBUTO } )					//"Deduções do Tributo"
	Aadd( aGruposEve, { GRUPO_COMPENSACAO_TRIBUTO, 'COMPENSACAO_TRIBUTO', STR0024, TIPO_GRUPO_CALCULO_TRIBUTO } )			//"Compensação do Tributo"
EndIf

Return( aGruposEve )

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyOrigem

Aplica as regras de Cópia do campo Origem

@Param oModelT0O -> Model de Itens para validar a cópia
		 cFTribDest -> Forma de tributação do Evento de destino

@Author David Costa
@Since 07/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpyOrigem( oModelT0O, cFTribDest )

If oModelT0O:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO
	If cFTribDest <> TRIBUTACAO_LUCRO_REAL .and. cFTribDest <> TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and.;
	  cFTribDest <>  TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		oModelT0O:SetValue( "T0O_IDEVEN", "" )
		oModelT0O:SetValue( "T0O_CODEVE", "" )
		oModelT0O:SetValue( "T0O_DEVENT", "" )
		oModelT0O:SetValue( "T0O_ORIGEM", "" )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyCodECF

Aplica as regras de Cópia do campo Código da Tabela Dinâmica.

@Param	oModelT0O	- Modelo de Itens para validar a Cópia
		cFTribDest	- Forma de Tributação do Evento de destino
		cFTribOrig	- Forma de Tributação do Evento de origem
		cTribuDest	- Tributo do Evento de destino
		cTribuOrig	- Tributo do Evento de origem

@Author	David Costa
@Since		07/06/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function CpyCodECF( oModelT0O, cFTribDest, cFTribOrig, cTribuDest, cTribuOrig )

Local lCopiar	as logical

lCopiar	:=	.F.

lCopiar :=	( cFTribDest == TRIBUTACAO_IMUNE .or. cFTribDest == TRIBUTACAO_ISENTA) .and.; 
			( cFTribOrig == TRIBUTACAO_IMUNE .or. cFTribOrig == TRIBUTACAO_ISENTA) .and.;
			cTribuDest == cTribuOrig
lCopiar := lCopiar .or. ( cFTribDest == cFTribOrig .and. cTribuDest == cTribuOrig )
lCopiar := lCopiar .or. ( cFTribDest == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO .and. cFTribOrig == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO )

//Se não for para copiar, limpa os campos
If !lCopiar
	oModelT0O:SetValue( "T0O_IDTDEX", "" )
	oModelT0O:SetValue( "T0O_CODTDE", "" )
	oModelT0O:SetValue( "T0O_DTDEXP", "" )
	oModelT0O:SetValue( "T0O_IDECF", "" )
	oModelT0O:SetValue( "T0O_CODECF", "" )
	oModelT0O:SetValue( "T0O_DTDECF", "" )
	oModelT0O:SetValue( "T0O_IDLAL", "" )
	oModelT0O:SetValue( "T0O_CODLAL", "" )
	oModelT0O:SetValue( "T0O_DTDLAL", "" )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CpyContaB

Aplica as regras de Cópia do campo Código da Conta Parte B do Lalur

@Param oModelT0O -> Model de Itens para validar a cópia
		 cTribuDest -> Tributo do Evento de destino
		 cTribuOrig -> Tributo do Evento de origem

@Author David Costa
@Since 15/06/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function CpyContaB( oModelT0O, cTribuDest, cTribuOrig )

Local cFilItem 	:= ""
Local cIdContPaB	:= ""
Local cIdTributo	:= ""

If cTribuDest <> cTribuOrig
	DbSelectArea( "LE9" )
	LE9->( DBSetOrder( 1 ) )
	cFilItem := xFunCh2ID( oModelT0O:GetValue( "T0O_FILITE"), "C1E", 1 )
	cIdContPaB := oModelT0O:GetValue( "T0O_IDPARB" )
	cIdTributo := XFUNCh2ID( cTribuDest, "T0J", 2 )
	
	//Se o tributo do evento de destino não existir na conta da Parte B ela não será copiada
	If !LE9->( MsSeek( xFilial( "LE9", cFilItem ) + cIdContPaB + cIdTributo ) )
		oModelT0O:SetValue( "T0O_IDPARB", "" )
		oModelT0O:SetValue( "T0O_CODPAB", "" )
		oModelT0O:SetValue( "T0O_DPARTB", "" )
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetGrupo

Rotina para indicar os grupos de acordo com a forma de tributação.

@Param		cFormaTrib	- Forma de tributação desejada

@Return	cGrupo		- Grupos relacionados a forma de tributação

@Author	Felipe de Carvalho Seolin
@Since		07/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetGrupo( cFormaTrib )

Local cGrupo	as character

cGrupo	:=	""

If cFormaTrib == TRIBUTACAO_LUCRO_REAL .or. cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO

	cGrupo += "|" + StrZero( GRUPO_RESULTADO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_RESULTADO_NAO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_DOACAO, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICIONAIS_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or. cFormaTrib == TRIBUTACAO_LUCRO_PRESUMIDO .or. cFormaTrib == TRIBUTACAO_LUCRO_ARBITRADO

	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ1, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ2, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ3, 2 )
	cGrupo += "|" + StrZero( GRUPO_RECEITA_BRUTA_ALIQ4, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEMAIS_RECEITAS, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_RECEITA, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICIONAIS_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_IMUNE .or. cFormaTrib == TRIBUTACAO_ISENTA

	cGrupo += "|" + StrZero( GRUPO_BASE_CALCULO, 2 )
	cGrupo += "|" + StrZero( GRUPO_DEDUCOES_TRIBUTO, 2 )
	cGrupo += "|" + StrZero( GRUPO_COMPENSACAO_TRIBUTO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_LUCRO_EXPLO

	cGrupo += "|" + StrZero( GRUPO_RECEITA_LIQUIDA_ATIVIDA, 2 )
	cGrupo += "|" + StrZero( GRUPO_LUCRO_EXPLORACAO, 2 )

ElseIf cFormaTrib == TRIBUTACAO_LUCRO_REAL_ATIV_RURAL

	cGrupo += "|" + StrZero( GRUPO_RESULTADO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_RESULTADO_NAO_OPERACIONAL, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_LUCRO, 2 )
	cGrupo += "|" + StrZero( GRUPO_ADICOES_DOACAO, 2 )
	cGrupo += "|" + StrZero( GRUPO_EXCLUSOES_LUCRO, 2 )

EndIf

Return( cGrupo )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF433When

Funcionalidade para atribuição da propriedade de edição do campo.

@Return	lWhen - Indica o modo de edição do campo

@Author	Felipe C. Seolin
@Since		07/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TAF433When()

Local oModel		as object
Local oModelLEC	as object
Local cCampo		as character
Local lWhen		as logical

oModel		:=	FWModelActive()
oModelLEC	:=	oModel:GetModel( "MODEL_LEC" )
cCampo		:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
lWhen		:=	.T.

If cCampo $ "LEC_ATIVID|LEC_PROUNI|LEC_PERRED|LEC_CODTDE"
	If Val( oModelLEC:GetValue( "LEC_CODGRU" ) ) <> GRUPO_RECEITA_LIQUIDA_ATIVIDA
		lWhen := .F.
	ElseIf cCampo $ "LEC_PROUNI" .and. oModelLEC:GetValue( "LEC_ATIVID" ) <> ATIVIDADE_ISENCAO
		lWhen := .F.
	ElseIf cCampo $ "LEC_PERRED" .and. oModelLEC:GetValue( "LEC_ATIVID" ) <> ATIVIDADE_REDUCAO
		lWhen := .F.
	EndIf
EndIf

Return( lWhen )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF433SXB

Função para execução das Consultas Especificas do Evento Tributário.

@Param		cTitle		- Título da Tela de Consulta Específica
			cAlias		- Alias da Tabela Temporária criada
			cReadVar	- Campo em memória que receberá o retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no campo em memória
			aColuns	- Colunas que serão utilizadas na Consulta Específica
			aSeek		- Índice de pesquisas serão utilizadas na Consulta Específica
			lMult		- Indica se a tela permitirá seleção de múltiplos registros

@Author	Felipe C. Seolin
@Since		12/08/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function TAF433SXB( cTitle, cAlias, cReadVar, cChave, aColumns, aSeek, lMult )

Local oDlg			as object
Local oMrkBrowse	as object
Local nTop			as numeric
Local nLeft		as numeric
Local aSize		as array
Local bConfirm	as codeblock
Local bClose		as codeblock

Default aSeek		:=	{}
Default lMult		:=	.F.

oDlg		:=	Nil
oMrkBrowse	:=	Nil
nTop		:=	0
nLeft		:=	0
aSize		:=	FWGetDialogSize( oMainWnd )
bConfirm	:=	{ || FConfirm( oMrkBrowse, cReadVar, cChave, lMult ), oDlg:End() }
bClose		:=	{ || oDlg:End() }

nTop	:=	( aSize[1] + aSize[3] ) / 5
nLeft	:=	( aSize[2] + aSize[4] ) / 5

If ( cAlias )->( !Eof() )

	oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4], cTitle,,,,,,,,, .T.,,,, .F. )

	oMrkBrowse := FWMarkBrowse():New()

	oMrkBrowse:SetOwner( oDlg )

	//Tipo de dados
	oMrkBrowse:SetTemporary()
	oMrkBrowse:SetAlias( cAlias )

	//Configuração de colunas
	oMrkBrowse:SetFieldMark( "MARK" )
	oMrkBrowse:SetColumns( aColumns )
	oMrkBrowse:SetCustomMarkRec( { || FMark( oMrkBrowse, lMult ) } )
	oMrkBrowse:SetAllMark( { || } )

	//Configuração de opções
	oMrkBrowse:SetMenuDef( "" )
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:SetWalkThru( .F. )
	oMrkBrowse:SetAmbiente( .F. )

	If !Empty( aSeek )
		oMrkBrowse:SetSeek( .T., aSeek )
	Else
		oMrkBrowse:SetSeek()
	EndIf

	oMrkBrowse:AddButton( "Sair", bClose ) //"Sair"
	oMrkBrowse:AddButton( "Confirmar", bConfirm ) //"Confirmar"

	oMrkBrowse:Activate()

	oDlg:Activate()

Else
	Help( " ", 1, "RECNO" )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FMark

Inverte a indicação de seleção do registro da Browse.

@Param		oBrowse	- Objeto da Browse
			lMult		- Indica se a tela permitirá seleção de múltiplos registros

@Author	Felipe C. Seolin
@Since		29/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FMark( oBrowse, lMult )

Local cAlias	as character
Local cMark		as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

If lMult
	If RecLock( cAlias, .F. )
		( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )
		( cAlias )->( MsUnlock() )
	EndIf
Else
	( cAlias )->( DBGoTop() )

	While ( cAlias )->( !Eof() )

		If RecLock( cAlias, .F. )
			( cAlias )->MARK := "  "
			( cAlias )->( MsUnlock() )
		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	( cAlias )->( DBGoTo( nRecno ) )

	If RecLock( cAlias, .F. )
		( cAlias )->MARK := cMark
		( cAlias )->( MsUnlock() )
	EndIf
EndIf

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FConfirm

Executa a gravação do retorno da Consulta Específica.

@Param		oBrowse	- Objeto da Browse
			cReadVar	- Campo de retorno da Consulta Específica
			cChave		- Campo(s) a serem gravados no retorno da Consulta Específica
			lMult		- Indica se a tela permitirá seleção de múltiplos registros

@Author	Felipe C. Seolin
@Since		29/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function FConfirm( oBrowse, cReadVar, cChave, lMult )

Local cAlias	as character
Local cMark	as character
Local nRecno	as numeric

cAlias	:=	oBrowse:Alias()
cMark	:=	oBrowse:Mark()
nRecno	:=	( cAlias )->( Recno() )

If Type( "cListKey" ) <> "U"
	cListKey := ""
EndIf

( cAlias )->( DBGoTop() )

While ( cAlias )->( !Eof() )

	If oBrowse:IsMark( cMark )
		If lMult
			cListKey += ( cAlias )->&( cChave ) + "|"
		Else
			SetMemVar( cReadVar, ( cAlias )->&( cChave ) )
			SysRefresh( .T. )
			Exit
		EndIf
	EndIf

	( cAlias )->( DBSkip() )
EndDo

( cAlias )->( DBGoTo( nRecno ) )

oBrowse:Refresh()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrupoEvnto

Retorna um array com todos os grupos pertinentes a Forma de Tributação passada.

@Param		cFormaTrib	- Forma de Tributação do Evento Tributário
			lTodos		- Indica que todos os Grupos serão retornados

@Return	aGruposEve	- Todos os grupos do Evento Tributário e seus parâmetros

@Author	David Costa
@Since		17/10/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GrupoEvnto( cFormaTrib, lTodos )

Local aGruposEve	as array

aGruposEve	:=	GetGrupos( cFormaTrib, lTodos )

Return( aGruposEve )

//---------------------------------------------------------------------
/*/{Protheus.doc} CanUpdate

Verifica se o cadastro pode sofrer alterações.

@Return	lCan	- Retorna se o cadastro pode ser alterado

@Author	David Costa
@Since		06/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function CanUpdate()

Local lCan	as logical

lCan	:=	.T.

//Dicionário do cadastro do Período
If TAFAlsInDic( "CWV" ) .and. ( ( Type( "INCLUI" ) <> "U" .and. !INCLUI ) .and. ( Type( "lCopia" ) <> "U" .and. !lCopia ) )
	DBSelectArea( "CWV" )
	CWV->( DBSetOrder( 6 ) )

	//Se o Evento estiver em uso por algum Período de Apuração, o cadastro não pode ser alterado
	If CWV->( MsSeek( xFilial( "CWV" ) + T0N->T0N_ID ) )
		If CWV->( !Eof() )
			lCan := .F.
		EndIf
	EndIf
EndIf

Return( lCan )

/*/{Protheus.doc} TAFA433SIM
Processo de Simulação da Apuração
@author david.costa
@since 27/01/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA433SIM()
/*/User Function xVMTAFA433()

Local cLogAvisos	as character
Local cLogErros		as character
Local lEnd			as logical

cLogAvisos	:=	""
cLogErros	:=	""
lEnd		:=	.F.

Processa( { || TelaParSim( @cLogAvisos, @cLogErros ) } )

//Limpando a memória
DelClassIntf()

Return( Nil )

/*/{Protheus.doc} ProcSimula
Processa a simulação
@author david.costa
@since 27/01/2017
@version 1.0
@param aListParam, array, (Descrição do parâmetro)
@return ${Nil}, ${Nulo}
@example
ProcSimula( @aListParam, @cLogAvisos, @cLogErros )
/*/Static Function ProcSimula( aListParam )

Local cAvisosPer	as character
Local cErrosPeri	as character
Local nIndicePar	as numeric
Local nIndicePer	as numeric

cAvisosPer	:=	""
cErrosPeri	:=	""
nIndicePar	:=	0
nIndicePer	:=	0

//Calcula os valores da simulação
For nIndicePar := 1 To Len( aListParam )
	For nIndicePer := 1 To Len( aListParam[ nIndicePar ][ PARAM_SIMUL_LISTA_PAR ] )
		cAvisosPer := ""
		cErrosPeri := ""
		
		ApuraEvent( aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ], aListParam[ nIndicePar, PARAM_SIMUL_MODEL_EVENTO ],;
		@cErrosPeri, @cAvisosPer, aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ], .T., ;
		aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ] )
		
		aListParam[ nIndicePar, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ] := cAvisosPer + CRLF + cErrosPeri
		
	Next nIndicePer
Next nIndicePar

Return( Nil )

/*/{Protheus.doc} SetListPar
Preenche a lista de parametros da simulação
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@param aListParam, array, Paramentros da Simulação
@return ${Nil}, ${Nulo}
@example
SetListPar( @oModelEven, @aListParam )
/*/Static Function SetListPar( oModelEven, aListParam )

Local oModelEven	as object

oModelEven	:=	Nil

//Carrega o evento principal
If LoadEvento( @oModelEven, XFUNCh2ID( uCampo1, "T0N", 2 ) )
	//Pametros para a simulação do primeiro evento
	aAdd( aListParam, { oModelEven, ListPerPar( oModelEven ) } )
	
	//Carrega o evento de comparação
	If LoadEvento( @oModelEven, XFUNCh2ID( uCampo4, "T0N", 2 ) ) .and. uCampo3
		//Pametros para a simulação do segundo evento
		aAdd( aListParam, { oModelEven, ListPerPar( oModelEven ) } )
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} Simular
Simulação da Apuração
@author david.costa
@since 27/01/2017
@version 1.0
@param cLogAvisos, character, Log de Avisos do processo
@param cLogErros, character, Log de Erros do processo
@return ${Nil}, ${Nulo}
@example
Simular( @cLogAvisos, @cLogErros )
/*/Static Function Simular( cLogAvisos, cLogErros )

Local oModelEven	as object
Local aListParam	as array

oModelEven	:=	Nil
aListParam	:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	//Os logs precisa ser reiniciados a cada simulação
	cLogAvisos := cLogErros := ""
	
	//Preenche os parametros para a simulação
	SetListPar( @oModelEven, @aListParam )
	
	//Processa a simulção conforme a lista de parametros
	ProcSimula( @aListParam, @cLogAvisos, @cLogErros )
	
	//Se existirem itens na lista a mesma será exibida
	If Len( aListParam ) > 0
		
		//Exibe os resutlados
		ExibirSimu( aListParam, @cLogAvisos, @cLogErros )
	EndIf
Else
	Alert( STR0090 )//"Informe os períodos para simulação"
EndIf

Return( Nil )

/*/{Protheus.doc} TelaParSim
Tela dos parametros do processo de simulação
@author david.costa
@since 27/01/2017
@version 1.0
@param cLogAvisos, character, Log de Avisos do processo
@param cLogErros, character, Log de Erros do processo
@return ${return}, ${return_description}
@example
TelaParSim( @cLogAvisos, @cLogErros )
/*/Static Function TelaParSim( cLogAvisos, cLogErros )

Local oFont		as object
Local oDlgParam	as object
Local aSizeAuto	as array
Local aHeader		as array
Local aCols		as array

Private oGetDBPer	as object
Private cListKey	as character
Private uCampo1	as character
Private uCampo2	as character
Private uCampo3	as logical
Private uCampo4	as character
Private uCampo5	as character

oFont		:=	TFont():New( "Arial",, -11 )
oDlgParam	:=	Nil
aSizeAuto	:=	MsAdvSize()
aHeader	:=	{}
aCols		:=	{}

oGetDBPer	:=	Nil
cListKey	:=	""
uCampo1	:=	Space( 6 )
uCampo2	:=	Space( 200 )
uCampo3	:=	.F.
uCampo4	:=	Space( 6 )
uCampo5	:=	Space( 200 )

//Define as Colunas da Grid de Períodos
GetHeadCols( aHeader )

//Tela dos Parametros da simulação
oDlgParam := MSDialog():New( 50,50,600,800, Upper( STR0091 ),,,.F.,,,,,,.T.,,,.T. )//"Simulação da Apuração"

//Como Default o item posicionado na Grid do Cadastro é carregado como principal
uCampo1 := T0N->T0N_CODIGO
uCampo2 := T0N->T0N_DESCRI

nTop := 5

//Evento tributário 1
TGet():New( nTop, 20, { |x| If( PCount() == 0, uCampo1, uCampo1 := x ) }, oDlgParam, 65, 10, "@!", { || ValidEvent( "1" ) },,,,,, .T.,,,,,,,,, "T0NA",,,,,,,, STR0092 , 1, oFont ) //"Evento Tributário 1"
TGet():New( nTop, 90, { |x| If( PCount() == 0, uCampo2, uCampo2 := x ) }, oDlgParam, 200, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0093, 1, oFont ) //"Descrição"

//"Simulação comparativa?"
nTop += 25
TCheckBox():New( nTop, 20, STR0094, { |x| If( PCount() == 0, uCampo3, uCampo3 := x ) }, oDlgParam, 65, 10,,,,,,,,.T.,,,)//"Simulação comparativa?"

//Evento tributário 2
nTop += 10
TGet():New( nTop, 20, { |x| If( PCount() == 0, uCampo4, uCampo4 := x ) }, oDlgParam, 65, 10, "@!", { || ValidEvent( "2" ) },,,,,, .T.,,,{ || uCampo3 },,,,,, "T0NA",,,,,,,, STR0095, 1, oFont ) //"Evento Tributário 2"
TGet():New( nTop, 90, { |x| If( PCount() == 0, uCampo5, uCampo5 := x ) }, oDlgParam, 200, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0093, 1, oFont ) //"Descrição"

nTop += 30
TButton():New( nTop, 020, STR0096, oDlgParam, { || AddPeriodo() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Selecionar Períodos"
nTop += 30

//Grid de períodos
oGetDBPer := MsNewGetDados():New(nTop, 010, 225, 370, GD_DELETE, "AllwaysTrue", "AllwaysTrue", "", { } ,;
0 , 99, "AllwaysTrue", "", "AllwaysTrue", oDlgParam, aHeader, aCols)

nTop += 150

TButton():New( nTop, 230, STR0097, oDlgParam, { || Processa( { || Simular( @cLogAvisos, @cLogErros ) } ) }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Simular"
TButton():New( nTop, 300, STR0098, oDlgParam, { || EndSimulac() .and. oDlgParam:End() }, 55,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Fechar"

oDlgParam:lCentered := .T.
oDlgParam:Activate()

Return( Nil )

/*/{Protheus.doc} EndSimulac
Limpas as Váriáveis dos parametros
@author david.costa
@since 27/01/2017
@version 1.0
@return ${.T.}, ${Verdadeiro}
@example
EndSimulac()
/*/Static Function EndSimulac()

uCampo4 := uCampo1 := Space( 6 )
uCampo5 := uCampo2 := Space( 200 )
uCampo3 := .F.
cListKey := ""

Return( .T. )

/*/{Protheus.doc} ListPerPar
Monta a Lista de Período e parametros da apuração para o evento
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@return ${aPerParam}, ${Lista de Parametros do Evento}
@example
ListPerPar( oModelEven )
/*/Static Function ListPerPar( oModelEven )

Local oModelPeri	as object
Local cChave		as character
Local nTamChave	as numeric
Local nPosicao	as numeric
Local aPerParam	as array
Local aParametro	as array
Local aParRural	as array

oModelPeri	:=	Nil
cChave		:=	""
nTamChave	:=	36
nPosicao	:=	1
aPerParam	:=	{}
aParametro	:=	{}
aParRural	:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	While nPosicao <= Len( cListKey )
		cChave := SubStr( cListKey, nPosicao, nTamChave )
		
		If LoadPeriod( @oModelPeri, cChave )
			
			//Carrega os parametros da apuração
			LoadParam( @aParametro, oModelPeri, oModelEven )
			
			//Carrega os parametros da atividade Rural
			LoadParam( @aParRural, oModelPeri, oModelEven )
			
			//Adiciona na lista dos parametros
			aAdd( aPerParam, { oModelPeri, aParametro, "", aParRural } )
		EndIf
		
		nPosicao += nTamChave + 1
	EndDo
	//Ordena os períodos
	aPerParam := aSort( aPerParam,,,{ |x,y| x[1]:GetValue( "MODEL_CWV", "CWV_INIPER") < y[1]:GetValue( "MODEL_CWV", "CWV_INIPER") } )
EndIf

Return( aPerParam )

/*/{Protheus.doc} ValidEvent
Valida se os parametros passados na tela estão corretos
@author david.costa
@since 27/01/2017
@version 1.0
@param nOp, numérico, Opção do campo para validação
@return ${lRet}, ${se o campo está válido ou não}
@example
ValidEvent( nOp )
/*/Static Function ValidEvent( nOp )

Local cTributo1	as character
Local cTributo2	as character
Local lRet			as logical

cTributo1	:=	""
cTributo2	:=	""
lRet		:=	.T.

DbSelectArea( "T0N" )
T0N->( DbSetOrder(2) )
If nOp == "1" .and. T0N->( MsSeek( xFilial( "T0N" ) + uCampo1 ) )
	uCampo2 := T0N->T0N_DESCRI
ElseIf nOp == "2" .and. T0N->( MsSeek( xFilial( "T0N" ) + uCampo4 ) )
	uCampo5 := T0N->T0N_DESCRI
ElseIf ( !Empty( uCampo1 ) .and. nOp == "1" ) .or.;
		( !Empty( uCampo4 ) .and. nOp == "2" )
	MsgInfo( STR0099 ) //"Código inexistente"
	lRet := .F.
EndIf

If !Empty( uCampo1 ) .and. !Empty( uCampo4 ) .and. uCampo3
	cTributo1 := Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo1, "T0N->T0N_IDTRIB" )
	cTributo2 := Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo4, "T0N->T0N_IDTRIB" )

	If cTributo1 != cTributo2
		MsgInfo( STR0100 ) //"Os Eventos devem ter o mesmo tributo."
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*/{Protheus.doc} GetHeadCols
Define as colunas da Grid de períodos
@author david.costa
@since 27/01/2017
@version 1.0
@param aHeader, array, Array que receberá o dicionário da Grid
@return ${Nil}, ${Nulo}
@example
GetHeadCols( aHeader )
/*/Static Function GetHeadCols( aHeader )

Aadd(aHeader, {;
              STR0101,;				//X3Titulo() // "Início Período"
              "INIPER",;  			//X3_CAMPO
              "@!",;					//X3_PICTURE
              8,;						//X3_TAMANHO
              0,;						//X3_DECIMAL
              "",;					//X3_VALID
              "",;					//X3_USADO
              "D",;					//X3_TIPO
              "",;					//X3_F3
              "V",;					//X3_CONTEXT
              "",;					//X3_CBOX
              "",;					//X3_RELACAO
              .F.})					//X3_WHEN

Aadd(aHeader, {;
              STR0102,;			//X3Titulo()//"Fim Período"
              "FIMPER",;  		//X3_CAMPO
              "@!",;				//X3_PICTURE
              8,;					//X3_TAMANHO
              0,;					//X3_DECIMAL
              "",;				//X3_VALID
              "",;				//X3_USADO
              "D",;				//X3_TIPO
              "",;				//X3_F3
              "V",;				//X3_CONTEXT
              "",;				//X3_CBOX
              "",;				//X3_RELACAO
              .F.})				//X3_WHEN

Aadd(aHeader, {;
              STR0165,;									//X3Titulo()//"Status"
              "STATUS",;  								//X3_CAMPO
              "",;										//X3_PICTURE
              1,;											//X3_TAMANHO
              0,;											//X3_DECIMAL
              "",;										//X3_VALID
              "",;										//X3_USADO
              "C",;										//X3_TIPO
              "",;										//X3_F3
              "V",;										//X3_CONTEXT
              "1=Aberto;2=Encerrado",;					//X3_CBOX
              "",;										//X3_RELACAO
              .F.})	
 
Return( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} AddPeriodo

Tela para seleção dos Períodos.

@Return	.T.

@Author	David Costa
@Since		27/01/2017
@Version	1.0

@Altered by Felipe C. Seolin in 15/02/2017 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function AddPeriodo()

Local cAliasQry		as character
Local cTempTab		as character
Local cCampos		as character
Local cChave		as character
Local cTitle		as character
Local cReadVar		as character
Local cCombo		as character
Local cSelect		as character
Local cFrom			as character
Local cWhere		as character
Local cOrderBy		as character
Local nPos			as numeric
Local nI			as numeric
Local aStruct		as array
Local aColumns		as array
Local aAux			as array
Local aIndex		as array
Local aSeek			as array
Local aCombo		as array
Local aID			as array
Local aPerIni		as array
Local aPerFim		as array
Local aStatus		as array

cAliasQry	:=	GetNextAlias()
cTempTab	:=	""
cCampos		:=	"CWV_INIPER|CWV_FIMPER|CWV_STATUS"
cChave		:=	"CWV_ID"
cTitle		:=	STR0103 //"Período"
cReadVar	:=	ReadVar()
cCombo		:=	""
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct		:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aID			:=	TamSX3( "CWV_ID" )
aPerIni	:=	TamSX3( "CWV_INIPER" )
aPerFim	:=	TamSX3( "CWV_FIMPER" )
aStatus	:=	TamSX3( "CWV_STATUS" )

//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect		:= "CWV_ID, CWV_INIPER, CWV_FIMPER, CWV_STATUS "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cWhere		:= "    CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere		+= "AND CWV.CWV_IDTRIB = '" + Posicione( "T0N", 2, xFilial( "T0N" ) + uCampo1, "T0N->T0N_IDTRIB" ) + "' "
cWhere		+= "AND CWV.D_E_L_E_T_ = '' "
cOrderBy	:= "CWV.R_E_C_N_O_ "

cSelect		:= "%" + cSelect 	+ "%"
cFrom  		:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	column CWV_INIPER as Date
	column CWV_FIMPER as Date

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK"			, "C"			, 2				, 0 			} )
aAdd( aStruct, { "CWV_ID"		, aID[3]		, aID[1]		, aID[2]		} )
aAdd( aStruct, { "CWV_INIPER"	, aPerIni[3]	, aPerIni[1]	, aPerIni[2]	} )
aAdd( aStruct, { "CWV_FIMPER"	, aPerFim[3]	, aPerFim[1]	, aPerFim[2]	} )
aAdd( aStruct, { "CWV_STATUS"	, aStatus[3]	, aStatus[1]	, aStatus[2]	} )

cTempTab := CriaTrab( aStruct, .T. )

DBUseArea( .T.,, cTempTab, cTempTab, .T., .F. )

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
( cTempTab )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )

	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		:=	"  "
		( cTempTab )->CWV_ID		:=	( cAliasQry )->CWV_ID
		( cTempTab )->CWV_INIPER	:=	( cAliasQry )->CWV_INIPER
		( cTempTab )->CWV_FIMPER	:=	( cAliasQry )->CWV_FIMPER
		( cTempTab )->CWV_STATUS	:=	( cAliasQry )->CWV_STATUS
		( cTempTab )->( MsUnLock() )
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		//aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"

			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf

		EndIf

	EndIf
Next nI

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns,, .T. )

//--------------------------------
// Apaga arquivo(s) temporário(s)
//--------------------------------
If !Empty( cTempTab )
	( cTempTab )->( DBCloseArea() )
	FErase( cTempTab + GetDBExtension() )
EndIf

//Preenche a Grid de seleção dos períodos
SetGridPer()

Return( .T. )

/*/{Protheus.doc} SetGridPer
Atualiza a Grid dos perídos a partir do que foi slecionado pelo usuário
@author david.costa
@since 27/01/2017
@version 1.0
@return ${.T.}, ${Verdadeiro}
@example
SetGridPer()
/*/Static Function SetGridPer()

Local cChave		as character
Local nTamChave	as numeric
Local nPosicao	as numeric
Local aCols		as array

cChave		:=	""
nTamChave	:=	36
nPosicao	:=	1
aCols		:=	{}

If !Empty( StrTran( cListKey, "|", "" ) )
	While nPosicao <= Len( cListKey )
		cChave := SubStr( cListKey, nPosicao, nTamChave )
		aAdd( aCols, { Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_INIPER" ), ;
			Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_FIMPER" ), ;
			Posicione( "CWV", 1, xFilial( "CWV" ) + cChave , "CWV->CWV_STATUS" ), .F. } )
		nPosicao += nTamChave + 1
	EndDo
	
	//Ordena a Grid pela data inicial do período
	aCols:= aSort( aCols,,,{ |x,y| x[1] < y[1] } )
	oGetDBPer:SetArray( aCols, .T. )
	oGetDBPer:Refresh()
EndIf

Return( .T. )

/*/{Protheus.doc} LoadPeriod
Carrega o Model do Período
@author david.costa
@since 27/01/2017
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cIdPeriodo, character, Identificador do período
@return ${lRet}, ${verdadeiro se o model for carregado}
@example
LoadPeriod( @oModelPeri, cIdPeriodo )
/*/Static Function LoadPeriod( oModelPeri, cIdPeriodo )

Local lRet	as logical

lRet	:=	.F.

DbSelectArea( "CWV" )
CWV->( DbSetOrder( 1 ) )

If CWV->( MsSeek( xFilial( "CWV" ) + cIdPeriodo ) )
	oModelPeri := FWLoadModel( 'TAFA444' )
	oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
	oModelPeri:Activate()
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} ExibirSimu
Exibe a Tela com o Resultados da Simulação
@author david.costa
@since 27/01/2017
@version 1.0
@param aListParam, array, Paramentro da Simulação
@param cLogAvisos, character, Log de Avisos do Processo
@param cLogErros, character, Log de Erros do Processo
@return ${Nil}, ${Nulo}
@example
ExibirSimu( aListParam, @cLogAvisos, @cLogErros )
/*/Static Function ExibirSimu( aListParam, cLogAvisos, cLogErros )

Local oFont			as object
Local oFolderGer	as object
Local cTitulo1		as character
Local cTitulo2		as character
Local cCadastro		as character
Local cDecPer		as character
Local nTopGeral		as numeric
Local nAltGSaldo	as numeric
Local nIndicePer	as numeric
Local aHeader		as array
Local aCols			as array
Local aAbasEvent	as array
Local aSize			as array
Local aButtons		as array
Local lComparar		as logical

Private oMultiGet	as object
Private oTreePerio	as object
Private oDlgSimula	as object
Private oGetDBDet1	as object
Private oGetDBDet2	as object
Private oFolderEve	as object
Private oFolder1	as object
Private oFolder2	as object
Private oScroll1	as object
Private oScroll2	as object
Private oPanel1		as object
Private oPanel2		as object
Private aColsDet1	as array
Private aColsDet2	as array
Private aoGet		as array
Private cDescEve1	as character
Private cDescEve2	as character
Private cDescFTri1	as character
Private cDescFTri2	as character
Private cDescPerio	as character
Private cTribu		as character
Private cLogPerio1	as character
Private cLogPerio2	as character
Private nSaldoEve1	as numeric
Private nSaldoEve2	as numeric
Private nVlrImpost	as numeric
Private nBaseCalcu	as numeric
Private nAliqImpos	as numeric
Private nVlrIsento	as numeric
Private nParcIsent	as numeric
Private nNMesesIse	as numeric
Private nVlrAdicio	as numeric
Private nAliqAdici	as numeric
Private nVlrPrIRPJ	as numeric
Private nSaldoDeve	as numeric
Private nVlrDeduco	as numeric
Private nVlrCompen	as numeric
Private nReceAliq1	as numeric
Private nReceAliq2	as numeric
Private nReceAliq3	as numeric
Private nReceAliq4	as numeric
Private nReceGrup1	as numeric
Private nReceGrup2	as numeric
Private nReceGrup3	as numeric
Private nReceGrup4	as numeric
Private nAliqGrup1	as numeric
Private nAliqGrup2	as numeric
Private nAliqGrup3	as numeric
Private nAliqGrup4	as numeric
Private nLucEstima	as numeric
Private nVlrExclus	as numeric
Private nDemaisRec	as numeric
Private nResulCont	as numeric
Private nResulOper	as numeric
Private nResulNOpe	as numeric
Private nLucroReal	as numeric
Private nVlrAdicoe	as numeric
Private nVlrDoacoe	as numeric
Private nCompPreju	as numeric
Private nImpDevMes	as numeric
Private nDeviAnter	as numeric
Private nAdicTribu	as numeric
Private nVlrImpos2	as numeric
Private nBaseCalc2	as numeric
Private nAliqImpo2	as numeric
Private nVlrIsent2	as numeric
Private nParcIsen2	as numeric
Private nNMesesIs2	as numeric
Private nVlrAdici2	as numeric
Private nAliqAdic2	as numeric
Private nVlrPrIRP2	as numeric
Private nSaldoDev2	as numeric
Private nVlrDeduc2	as numeric
Private nVlrCompe2	as numeric
Private nReceAlq12	as numeric
Private nReceAlq22	as numeric
Private nReceAlq32	as numeric
Private nReceAlq42	as numeric
Private nReceGrp12	as numeric
Private nReceGrp22	as numeric
Private nReceGrp32	as numeric
Private nReceGrp42	as numeric
Private nAliqGrp12	as numeric
Private nAliqGrp22	as numeric
Private nAliqGrp32	as numeric
Private nAliqGrp42	as numeric
Private nLucEstim2	as numeric
Private nVlrExclu2	as numeric
Private nDemaisRe2	as numeric
Private nResulCon2	as numeric
Private nResulOpe2	as numeric
Private nResulNOp2	as numeric
Private nLucroRea2	as numeric
Private nVlrAdico2	as numeric
Private nVlrDoaco2	as numeric
Private nCompPrej2	as numeric
Private nImpDevMe2	as numeric
Private nDeviAnte2	as numeric
Private nAdicTrib2	as numeric
Private nLRAposPj1	as numeric
Private nLRAposPj2	as numeric
Private nBCParcia1	as numeric
Private nBCParcia2	as numeric
Private nPrejRura1	as numeric
Private nPrejRura2	as numeric
Private nResCtbRu1	as numeric
Private nResCtbRu2	as numeric
Private nResOpRur1	as numeric
Private nResOpRur2	as numeric
Private nResNOpRu1	as numeric
Private nResNOpRu2	as numeric
Private nLRealRur1	as numeric
Private nLRealRur2	as numeric
Private nVlrAdRur1	as numeric
Private nVlrAdRur2	as numeric
Private nVlrExRur1	as numeric
Private nVlrExRur2	as numeric
Private nVlrDoaRu1	as numeric
Private nVlrDoaRu2	as numeric
Private nLRApPjRu1	as numeric
Private nLRApPjRu2	as numeric
Private nPrejGera1	as numeric
Private nPrejGera2	as numeric
Private nPjCompGe1	as numeric
Private nPjCompGe2	as numeric
Private nBCParRur1	as numeric
Private nBCParRur2	as numeric
Private nCompPjRu1	as numeric
Private nCompPjRu2	as numeric

oFont		:=	TFont():New( "Arial",, -11 )
oFolderGer	:=	Nil
cTitulo1	:=	STR0092 //"Evento Tributário 1"
cTitulo2	:=	STR0095 //"Evento Tributário 2"
cCadastro	:=	Upper( STR0088 ) //"Simulação da Apuração"
cDecPer		:=	""
nTopGeral	:=	0
nAltGSaldo	:=	0
nIndicePer	:=	0
aHeader		:=	{}
aCols		:=	{}
aAbasEvent	:=	{}
aButtons	:=	{}
aSize		:=	MsAdvSize( .T. )
lComparar	:=	Len( aListParam ) > 1

oMultiGet	:= Nil
oTreePerio	:= Nil
oDlgSimula	:= Nil
oGetDBDet1	:= Nil
oGetDBDet2	:= Nil
oFolderEve	:= Nil
oFolder1	:= Nil
oFolder2	:= Nil
oScroll1	:= Nil
oScroll2	:= Nil
oPanel1		:= Nil
oPanel2		:= Nil
aColsDet1	:= {}
aColsDet2	:= {}
aoGet		:= {}

//Variáveis com os valores da Tela de Simulação
cDescEve1	:=	""
cDescEve2	:=	""
cDescFTri1	:=	""
cDescFTri2	:=	""
cDescPerio	:=	""
cTribu		:=	""
cLogPerio1	:=	""
cLogPerio2	:=	""
nSaldoEve1	:=	0
nSaldoEve2	:=	0
nVlrImpost	:=	0
nBaseCalcu	:=	0
nAliqImpos	:=	0
nVlrIsento	:=	0
nParcIsent	:=	0
nNMesesIse	:=	0
nVlrAdicio	:=	0
nAliqAdici	:=	0
nVlrPrIRPJ	:=	0
nSaldoDeve	:=	0
nVlrDeduco	:=	0
nVlrCompen	:=	0
nReceAliq1	:=	0
nReceAliq2	:=	0
nReceAliq3	:=	0
nReceAliq4	:=	0
nReceGrup1	:=	0
nReceGrup2	:=	0
nReceGrup3	:=	0
nReceGrup4	:=	0
nAliqGrup1	:=	0
nAliqGrup2	:=	0
nAliqGrup3	:=	0
nAliqGrup4	:=	0
nLucEstima	:=	0
nVlrExclus	:=	0
nDemaisRec	:=	0
nResulCont	:=	0
nResulOper	:=	0
nResulNOpe	:=	0
nLucroReal	:=	0
nVlrAdicoe	:=	0
nVlrDoacoe	:=	0
nCompPreju	:=	0
nImpDevMes	:=	0
nDeviAnter	:=	0
nAdicTribu	:=	0
nVlrImpos2	:=	0
nBaseCalc2	:=	0
nAliqImpo2	:=	0
nVlrIsent2	:=	0
nParcIsen2	:=	0
nNMesesIs2	:=	0
nVlrAdici2	:=	0
nAliqAdic2	:=	0
nVlrPrIRP2	:=	0
nSaldoDev2	:=	0
nVlrDeduc2	:=	0
nVlrCompe2	:=	0
nReceAlq12	:=	0
nReceAlq22	:=	0
nReceAlq32	:=	0
nReceAlq42	:=	0
nReceGrp12	:=	0
nReceGrp22	:=	0
nReceGrp32	:=	0
nReceGrp42	:=	0
nAliqGrp12	:=	0
nAliqGrp22	:=	0
nAliqGrp32	:=	0
nAliqGrp42	:=	0
nLucEstim2	:=	0
nVlrExclu2	:=	0
nDemaisRe2	:=	0
nResulCon2	:=	0
nResulOpe2	:=	0
nResulNOp2	:=	0
nLucroRea2	:=	0
nVlrAdico2	:=	0
nVlrDoaco2	:=	0
nCompPrej2	:=	0
nImpDevMe2	:=	0
nDeviAnte2	:=	0
nAdicTrib2	:=	0
nLRAposPj1	:=	0
nLRAposPj2	:=	0
nBCParcia1	:=	0
nBCParcia2	:=	0
nPrejRura1	:=	0
nPrejRura2	:=	0
nResCtbRu1	:=	0
nResCtbRu2	:=	0
nResOpRur1	:=	0
nResOpRur2	:=	0
nResNOpRu1	:=	0
nResNOpRu2	:=	0
nLRealRur1	:=	0
nLRealRur2	:=	0
nVlrAdRur1	:=	0
nVlrAdRur2	:=	0
nVlrExRur1	:=	0
nVlrExRur2	:=	0
nVlrDoaRu1	:=	0
nVlrDoaRu2	:=	0
nLRApPjRu1	:=	0
nLRApPjRu2	:=	0
nPrejGera1	:=	0
nPrejGera2	:=	0
nPjCompGe1	:=	0
nPjCompGe2	:=	0
nBCParRur1	:=	0
nBCParRur2	:=	0
nCompPjRu1	:=	0
nCompPjRu2	:=	0

//Tela Principal da Simulação
oDlgSimula := MSDialog():New( 50, 50, aSize[6], aSize[5], cCadastro,,, .F.,,,,,, .T.,,, .T. )

//Aba Período
oFolderGer := TFolder():New( 30, 5, { STR0103 },, oDlgSimula,,,, .T.,, ( oDlgSimula:nWidth / 2.45 / 100 ) * 20, oDlgSimula:nHeight / 2.4 ) //"Período"

//Grupo Saldo Apurado
nAltGSaldo := Iif( lComparar, 70, 45 )
@nTopGeral,5 GROUP oGrupSaldo TO nAltGSaldo, oFolderGer:nWidth / 2.1 PROMPT STR0104 OF oFolderGer:aDialogs[1] PIXEL //"Saldo Apurado"
nTopGeral += 10

//Saldo Apurado Evento 1
aAdd( aoGet, TGet():New( nTopGeral, 10, { || @nSaldoEve1 }, oGrupSaldo, oGrupSaldo:nWidth / 2.2, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,, .T.,, cTitulo1, 1, oFont ) )

If lComparar
	nTopGeral += 25

	//Saldo Apurado Evento 2
	aAdd( aoGet, TGet():New( nTopGeral, 10, { || @nSaldoEve2 }, oGrupSaldo, oGrupSaldo:nWidth / 2.2, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,, .T.,, cTitulo2, 1, oFont ) )
EndIf

nTopGeral += 40

//Cria a Árvore dos Períodos
oTreePerio := DBTree():New( nTopGeral, 5, oFolderGer:nHeight / 2.3, oFolderGer:nWidth / 2.1, oFolderGer:aDialogs[1], { || LoadSimula( aListParam,, @cLogAvisos ) },, .T. )
oTreePerio:AddTree( STR0105, .T., "FOLDER01", "FOLDER02",,, "001" ) //"Períodos"
oTreePerio:TreeSeek( "001" )

//Adiciona os Períodos na Árvore
For nIndicePer := 1 to Len( aListParam[1,PARAM_SIMUL_LISTA_PAR] )
	cDecPer := DToC( aListParam[1,PARAM_SIMUL_LISTA_PAR,nIndicePer,LISTA_PAR_MODEL_PERIODO]:GetValue( "MODEL_CWV", "CWV_INIPER" ) )

	//Formata para dd/mm/aa
	cDecPer := SubStr( cDecPer, 1, 6 ) + SubStr( cDecPer, 9, 2 )

	oTreePerio:AddItem( cDecPer, AllTrim( Str( nIndicePer + 1 ) ), "FOLDER3",,,, 2 )
Next nIndicePer

//Abas dos Eventos
aAbasEvent := Iif( lComparar, { cTitulo1, cTitulo2 }, { cTitulo1 } )
oFolderEve := TFolder():New( 30, ( ( oDlgSimula:nWidth / 2.45 / 100 ) * 20 ) + 10, aAbasEvent,, oDlgSimula,,,, .T.,, oDlgSimula:nWidth / 2.45, oDlgSimula:nHeight / 2.4 )

//Adiciona os dados do Evento 1
AddDadoEve( oFolderEve:aDialogs[1], oFont, @cDescEve1, @cDescFTri1 )

If lComparar
	//Adiciona os dados do Evento 2
	AddDadoEve( oFolderEve:aDialogs[2], oFont, @cDescEve2, @cDescFTri2 )
EndIf

If lComparar
	//Adiciona os dados da Simulação e do Detalhamento dos dois Eventos
	AddSimuDet( oFolderEve:aDialogs[1], oFont, aListParam, oFolderEve:aDialogs[2], lComparar )
Else
	//Adiciona os dados da Simulação e do Detalhamento
	AddSimuDet( oFolderEve:aDialogs[1], oFont, aListParam,, lComparar )
EndIf

aAdd( aButtons, { , { || RelPartA( aListParam ) }, , STR0162, { || .T. } } )//"Relatório Parte A - Estimativa por balanço"
aAdd( aButtons, { , { || RelPartB( aListParam ) }, , STR0163, { || .T. } } )//"Relatório Parte B - Estimativa por balanço"
aAdd( aButtons, { , { || U_RTAFM01B( ) }, , "Titulo Provisao", { || .T. } } )//"Geração de titulos de provisão"

oDlgSimula:bInit := EnchoiceBar( oDlgSimula, { || oDlgSimula:End() }, { || oDlgSimula:End() },, @aButtons,,,,,,.F.,.F.,.F.)
oDlgSimula:lCentered := .T.

//Atualiza a Tela da Simulação com o Resultado da Simulação do primeiro Período
LoadSimula( aListParam, 1, @cLogAvisos )

oDlgSimula:Activate()

Return()

/*/{Protheus.doc} AddDadoEve
Adiciona os dados de identificação do Evento
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgEve, objeto, Objeto que receberá os campos
@param oFont, objeto, Obejto com a fonte
@param cEvento, character, Passar por refência a variavel Private que armazenará a descrição do Evento
@param cFtrib, character, Passar por refência a variavel Private que armazenará a forma te tributação do Evento
@return ${Nil}, ${Nulo}
@example
AddDadoEve( oFolderEve:aDialogs[ 2 ], oFont, @cDescEve2, @cDescFTri2 )
/*/Static Function AddDadoEve( oDlgEve, oFont, cEvento, cFtrib )

Local oGrupo	as object
Local nTopEvent	as numeric
Local nWidthGet as numeric
Local nLeftGet	as numeric

oGrupo		:=	Nil
nTopEvent	:=	0
nWidthGet	:=	0
nLeftGet	:=	0

//Grupo Dados da Simulação
@nTopEvent,5 GROUP oGrupo TO 45,oFolderEve:nWidth / 2.05 PROMPT STR0150 OF oDlgEve PIXEL //"Dados da Simulação"

nWidthGet := ( oGrupo:nWidth / 2 ) / 4.5

nTopEvent += 10
nLeftGet += 12

//Tributo
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cTribu }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0069, 1, oFont ) ) //"Tributo"

nLeftGet += nWidthGet + 12

//Período
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { |x| @cDescPerio }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0103, 1, oFont ) ) //"Período"

nLeftGet += nWidthGet + 12

//Forma de Tributação
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cFtrib }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0002, 1, oFont ) ) //"Forma de Tributação"

nLeftGet += nWidthGet + 12

//Evento Tributário
aAdd( aoGet, TGet():New( nTopEvent, nLeftGet, { || @cEvento }, oGrupo, nWidthGet, 10, "@!", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, STR0106, 1, oFont ) ) //"Evento Tributário"

Return()

/*/{Protheus.doc} AddSimuDet
Adiciona as Abas de Simulação e Detalhamento da simulação do período
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que Receberá os Campos do Evento 1
@param oFont, objeto, Objeto da fonte
@param aListParam, array, Parametros da Simulação
@param oDlgSimu2, objeto, Objeto que Receberá os Campos do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@return ${Nil}, ${Nulo}
@example
AddSimuDet( oFolderEve:aDialogs[ 1 ], oFont, aListParam, oFolderEve:aDialogs[ 2 ], lComparar )
/*/Static Function AddSimuDet( oDlgSimu, oFont, aListParam, oDlgSimu2, lComparar )

Local oModelEve1	as object
Local oModelEve2	as object
Local cTitulo1		as character
Local cTitulo2		as character
Local cTitulo3		as character
Local cFormaTri1	as character
Local cFormaTri2	as character
Local cTributo		as character
Local aHeader		as array
Local aAbasEve1		as array
Local aAbasEve2		as array
Local lRural1		as logical
Local lRural2		as logical

Private nTopSimula	as numeric
Private nTopSimul2	as numeric

oModelEve1	:=	Nil
oModelEve2	:=	Nil
cTitulo1	:=	STR0107 //"Simulação"
cTitulo2	:=	STR0108 //"Detalhamento"
cTitulo3	:=	STR0109 //"Log da Apuração"
cFormaTri1	:=	""
cFormaTri2	:=	""
cTributo	:=	""
aHeader		:=	{}
aAbasEve1	:=	{}
aAbasEve2	:=	{}
lRural1		:=	.F.
lRural2		:=	.F.

//Posicionamento dos campos na tela
nTopSimula	:=	0
nTopSimul2	:=	0

//Grid do Detalhamento
GetHeadCWX( aHeader )

//Evento 1
oModelEve1 := aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ]

//Verifica se o Evento tem atividade Rural
lRural1 := !Empty( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )

//Tipo do Tributo
cTributo := Posicione( "T0J", 1, xFilial( "T0J" ) + oModelEve1:GetValue( "MODEL_T0N", "T0N_IDTRIB" ), "T0J_TPTRIB" )

//Forma de Tributação
cFormaTri1 := XFUNID2Cd( oModelEve1:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )

//Simulação e Detalhamento
aAbasEve1 := { cTitulo1, cTitulo2, cTitulo3 }
oFolder1 := TFolder():New( 45, 5, aAbasEve1,, oDlgSimu,,,, .T.,, oFolderEve:nWidth / 2.05, oFolderEve:nHeight / 2.9 )
oScroll1 := TScrollArea():New( oFolder1:aDialogs[1], 01, 01, ( oFolder1:nHeight / 2.3 ), oFolder1:nWidth / 2.02, .T. )
@01,01 MSPanel oPanel1 Of oScroll1 Size oFolder1:nWidth / 2.02,( oFolder1:nHeight / 2.3 ) + 250
oScroll1:SetFrame( oPanel1 )

If lComparar
	//Evento 2
	oModelEve2 := aListParam[ 2, PARAM_SIMUL_MODEL_EVENTO ]
	
	//Verifica se o Evento tem atividade Rural
	lRural2 := !Empty( oModelEve2:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )
	
	//Forma de Tributação
	cFormaTri2 := XFUNID2Cd( oModelEve2:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )
	
	//Simulação e Detalhamento
	aAbasEve2 := { cTitulo1, cTitulo2, cTitulo3 }
	oFolder2 := TFolder():New( 45, 5, aAbasEve2,, oDlgSimu2,,,, .T.,, oFolderEve:nWidth / 2.05, oFolderEve:nHeight / 2.9 )
	oScroll2 := TScrollArea():New( oFolder2:aDialogs[1], 01, 01, oFolder2:nHeight / 2.3, oFolder2:nWidth / 2.02, .T. )
	@01,01 MSPanel oPanel2 Of oScroll2 Size oFolder2:nWidth / 2.02,( oFolder2:nHeight / 2.3 ) + 200
	oScroll2:SetFrame( oPanel2 )

	//Simulação
	//Campos da Atividade Geral
	If lRural1
		AddSeparad( STR0151, oPanel1, oPanel2, lComparar, lRural2 ) //"Atividade Geral:"
		AddResCont( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLucReal( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLRAposP( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddBCParci( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		
		AddSeparad( STR0152, oPanel1, oPanel2, lComparar, lRural2 ) //"Atividade Rural:"
		AddResCont( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
		AddLucReal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
		AddLRAposP( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
		AddBCParci( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
	Else
		AddResCont( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
		AddLucReal( oPanel1, oFont, cFormaTri1,, oPanel2, cFormaTri2 )
	EndIf

	AddRecAlq1( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq2( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq3( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddRecAlq4( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	AddLucEsti( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	
	//Campos da Apuração
	If lRural1
		AddSeparad( STR0153, oPanel1, oPanel2, lComparar, lRural2 ) //"Apuração:"
	EndIf
	
	AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
	AddVlrImpo( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	
	If cTributo == TRIBUTO_IRPJ
		AddVlrIsen( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
		AddVlrAdic( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
		AddProIRPJ( oPanel1, oFont, cFormaTri1, oPanel2, cFormaTri2 )
	EndIf
	
	AddDeviMes( oPanel1, oFont, cFormaTri1, cTributo, oPanel2, cFormaTri2 )
	AddDevedor( oPanel1, oFont, cFormaTri1, cTributo, oPanel2, cFormaTri2 )
	
	//Grid dos itens do detalhamento
	oGetDBDet2 := MsNewGetDados():New( 5, 5, oFolder1:nHeight / 2.3, oFolder1:nWidth / 2.05,, "AllwaysTrue", "AllwaysTrue", "", {}, 0, 99, "AllwaysTrue", "", "AllwaysTrue", oFolder2:aDialogs[2], aHeader, {} )
	
	//Log do Período
	oMultiGet2 := TMultiget():New( 5, 5, { || @cLogPerio2 }, oFolder2:aDialogs[3], oFolder1:nWidth / 2.05, oFolder1:nHeight / 2.4,,,,,,.T.,,,,,,,,,,, .T. )
Else
	//Simulação
	//Campos da Atividade Geral
	If lRural1
		AddSeparad( STR0151, oPanel1 ) //"Atividade Geral:"
		AddResCont( oPanel1, oFont, cFormaTri1 )
		AddLucReal( oPanel1, oFont, cFormaTri1 )
		AddLRAposP( oPanel1, oFont, cFormaTri1 )
		AddBCParci( oPanel1, oFont, cFormaTri1 )
		
		AddSeparad( STR0152, oPanel1 ) //"Atividade Rural:"
		AddResCont( oPanel1, oFont, cFormaTri1, lRural1 )
		AddLucReal( oPanel1, oFont, cFormaTri1, lRural1 )
		AddLRAposP( oPanel1, oFont, cFormaTri1, lRural1 )
		AddBCParci( oPanel1, oFont, cFormaTri1, lRural1 )
	Else
		AddResCont( oPanel1, oFont, cFormaTri1 )
		AddLucReal( oPanel1, oFont, cFormaTri1 )
	EndIf

	AddRecAlq1( oPanel1, oFont, cFormaTri1 )
	AddRecAlq2( oPanel1, oFont, cFormaTri1 )
	AddRecAlq3( oPanel1, oFont, cFormaTri1 )
	AddRecAlq4( oPanel1, oFont, cFormaTri1 )
	AddLucEsti( oPanel1, oFont, cFormaTri1 )
	
	//Campos da Atividade Rural
	//Campos da Apuração
	If lRural1
		AddSeparad( STR0153, oPanel1 ) //"Apuração:"
	EndIf
	
	AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1 )
	AddVlrImpo( oPanel1, oFont, cFormaTri1 )
	
	If cTributo == TRIBUTO_IRPJ
		AddVlrIsen( oPanel1, oFont, cFormaTri1 )
		AddVlrAdic( oPanel1, oFont, cFormaTri1 )
		AddProIRPJ( oPanel1, oFont, cFormaTri1 )
	EndIf
	
	AddDeviMes( oPanel1, oFont, cFormaTri1, cTributo )
	AddDevedor( oPanel1, oFont, cFormaTri1, cTributo )
EndIf

//Grid dos itens do detalhamento
oGetDBDet1 := MsNewGetDados():New( 5, 5, oFolder1:nHeight / 2.3, oFolder1:nWidth / 2.05,, "AllwaysTrue", "AllwaysTrue", "", {}, 0, 99, "AllwaysTrue", "", "AllwaysTrue", oFolder1:aDialogs[2], aHeader, {} )

//Log do Período
oMultiGet := TMultiget():New( 5, 5, { || @cLogPerio1 }, oFolder1:aDialogs[3], oFolder1:nWidth / 2.05, oFolder1:nHeight / 2.4,,,,,,.T.,,,,,,,,,,, .T. )

Return( Nil )

/*/{Protheus.doc} AddSeparad
Adiciona uma linha de separação para organizar melhor a simulação
@author david.costa
@since 02/02/2017
@version 1.0
@param cTexto, character, Titulo da separação
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@param lRural2, ${bool}, Informa se o Segundo Evento tem Atividade Rural
@return ${Nil}, ${Nulo}
@example
AddSeparad( cTexto, oDlgSimu, oDlgSimu2, lComparar )
/*/Static Function AddSeparad( cTexto, oDlgSimu, oDlgSimu2, lComparar, lRural2 )

Local oFonteLbel	as object

Default lRural2	:=	.F.
Default lComparar	:=	.F.

oFonteLbel	:=	TFont():New( "Arial",, -11 )

oFonteLbel:Bold := .T.

TSay():New( nTopSimula, 2,{ || cTexto }, oDlgSimu,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 60, 10 )
nTopSimula += 5

TSay():New( nTopSimula, 2,{ || Replicate( "=" , 200 ) }, oDlgSimu,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 300, 10 )
nTopSimula += 10

//Segundo Evento
If lComparar .and. lRural2
	TSay():New( nTopSimul2, 2,{ || cTexto }, oDlgSimu2,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 60, 10 )
	nTopSimul2 += 5

	TSay():New( nTopSimul2, 2,{ || Replicate( "=" , 200 ) }, oDlgSimu2,, oFonteLbel,,,,.T., CLR_CYAN, CLR_WHITE, 300, 10 )
	nTopSimul2 += 10
EndIf

Return( Nil )

/*/{Protheus.doc} AddLRAposP
Adiciona os campos do Lucro Real após a compensação de prejuízo
@author david.costa
@since 07/02/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param lRural1, ${bool}, Informa se os campos é para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lRural2, ${bool}, Informa se os campos é para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddLRAposP( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )
/*/Static Function AddLRAposP( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Lucro Real Após Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRApPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRealRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejGera1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0158, 1, oFont ) )		//"Prej. Ativ. Geral"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Comp. na Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejRura1}, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0161, 1, oFont ) )		//"Prej. Comp. na Ativ. Geral"
		
		nTopSimula += 25
	Else
		//"Lucro Real Após Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRAposPj1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejRura1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0159, 1, oFont ) )		//"Prej. Ativ. Rural"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Comp. na Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nPrejGera1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0160, 1, oFont ) )		//"Prej. Comp. na Ativ. Rural"
		
		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Lucro Real Após Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRApPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRealRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejGera2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0158, 1, oFont ) )		//"Prej. Ativ. Geral"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Comp. na Ativ. Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejRura2}, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0161, 1, oFont ) )		//"Prej. Comp. na Ativ. Geral"
		
		nTopSimul2 += 25
	Else
		//"Lucro Real Após Prej."
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRAposPj2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejRura2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0159, 1, oFont ) )		//"Prej. Ativ. Rural"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Prej. Comp. na Ativ. Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nPrejGera2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0160, 1, oFont ) )		//"Prej. Comp. na Ativ. Rural"
		
		nTopSimul2 += 25
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddBCParci
Adiciona os campos da Base de Cálculo Parcial
@author david.costa
@since 07/02/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param lRural1, ${bool}, Informa se os campos é para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lRural2, ${bool}, Informa se os campos é para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddBCParci( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )
/*/Static Function AddBCParci( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Base Cálc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base Cálc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real Após Prej."
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRApPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Compensação Prejuízo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPjRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
		
		nTopSimula += 25
	Else
		//"Base Cálc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParcia1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base Cálc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//Lucro Real Após Prej.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRAposPj1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Compensação Prejuízo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPreju }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
		
		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Base Cálc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base Cálc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Lucro Real Após Prej."
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRApPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Compensação Prejuízo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPjRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
		
		nTopSimul2 += 25
	Else
		//"Base Cálc. Parcial"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParcia2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0157, 1, oFont ) )		//"Base Cálc. Parcial"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//Lucro Real Após Prej.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRAposPj2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0156, 1, oFont ) )		//"Lucro Real Após Prej."
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Compensação Prejuízo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPrej2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
		
		nTopSimul2 += 25
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddBaseCal
Adiciona os campos da Base de Cálculo
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param lRural1, ${bool}, Informa se os campos é para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lRural2, ${bool}, Informa se os campos é para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddBaseCal( oPanel1, oFont, cFormaTri1, lRural1, oPanel2, cFormaTri2, lRural2 )
/*/Static Function AddBaseCal( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO

	//"Base de Cálculo"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )	//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	If lRural1
		//"Base Atividade Geral"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParcia1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0155, 1, oFont ) )		//"Base Atividade Geral"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Base Atividade Rural"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBCParRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0154, 1, oFont ) )		//"Base Atividade Rural"
		
		nTopSimula += 25
	
	Else
		If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
			//"Lucro Estimado"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucEstima }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			//"Exclusões"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExclus }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
			
			nTopSimula += 25
		
		ElseIf cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
			cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
			//"Lucro Real"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			//"Compensação Prejuízo"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nCompPreju }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
			
			nTopSimula += 25
		EndIf
	EndIf
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO

	//"Base de Cálculo"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )	//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.

	If lRural2
		//"Base Atividade Geral"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParcia2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0155, 1, oFont ) )		//"Base Atividade Geral"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Base Atividade Rural"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBCParRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0154, 1, oFont ) )		//"Base Atividade Rural"
		
		nTopSimul2 += 25
	
	Else
		//"Base de Cálculo"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )	//"Base de Cálculo"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
			//"Lucro Estimado"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucEstim2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			//"Exclusões"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExclu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
			
			nTopSimul2 += 25
		
		ElseIf cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
			cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
			//"Lucro Real"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
			
			//"Compensação Prejuízo"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nCompPrej2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0114, 1, oFont ) )			//"Compensação Prejuízo"
			
			nTopSimul2 += 25
		EndIf
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} AddLucEsti
Adiciona os campos do Lucro Estimado
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@return ${Nil}, ${Nulo}
@example
AddLucEsti( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddLucEsti( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Lucro Estimado"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucEstima }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Grupo 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )		//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )		//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )		//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Demais Receitas"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nDemaisRec }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0120, 1, oFont ) )		//"Demais Receitas"
	
	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Lucro Estimado"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucEstim2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0111, 1, oFont ) )		//"Lucro Estimado"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Grupo 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )		//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )		//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )		//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Receita Grupo 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Demais Receitas"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nDemaisRe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0120, 1, oFont ) )		//"Demais Receitas"
	
	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq4
Adiciona os campos do Da Receita Líquida Alíquota 4
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@return ${Nil}, ${Nulo}
@example
AddRecAlq4( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq4( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 4"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq4 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0121, 1, oFont ) )		//"Receita Alíquota 4"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 4"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup4 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0122, 1, oFont ) )			//"% Estimado Alíquota 4"
	
	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 4"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0119, 1, oFont ) )		//"Receita Grupo 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq42 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0121, 1, oFont ) )		//"Receita Alíquota 4"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 4"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp42 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0122, 1, oFont ) )			//"% Estimado Alíquota 4"
	
	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq3
Adiciona os campos do Da Receita Líquida Alíquota 3
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@return ${Nil}, ${Nulo}
@example
AddRecAlq3( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq3( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 3"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )			//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq3 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0124, 1, oFont ) )			//"Receita Alíquota 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 3"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup3 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0125, 1, oFont ) )			//"% Estimado Alíquota 3"
	
	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 3"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0118, 1, oFont ) )			//"Receita Grupo 3"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq32 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0124, 1, oFont ) )			//"Receita Alíquota 3"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 3"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp32 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0125, 1, oFont ) )			//"% Estimado Alíquota 3"
	
	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq2
Adiciona os campos do Da Receita Líquida Alíquota 2
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lComparar, ${bool}, Informa se trata-se de uma simulação
@return ${Nil}, ${Nulo}
@example
AddRecAlq2( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq2( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 2"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )			//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq2 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0123, 1, oFont ) )			//"Receita Alíquota 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 2"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup2 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0126, 1, oFont ) )				//"% Estimado Alíquota 2"
	
	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 2"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0117, 1, oFont ) )			//"Receita Grupo 2"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq22 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0123, 1, oFont ) )			//"Receita Alíquota 2"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 2"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp22 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0126, 1, oFont ) )				//"% Estimado Alíquota 2"
	
	nTopSimul2 += 25
EndIf

Return( Nil )

/*/{Protheus.doc} AddRecAlq1
Adiciona os campos do Da Receita Líquida Alíquota 1
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddRecAlq1( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddRecAlq1( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 1"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceGrup1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )			//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nReceAliq1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0127, 1, oFont ) )			//"Receita Alíquota 1"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 1"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqGrup1 }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0128, 1, oFont ) )			//"% Estimado Alíquota 1"
	
	nTopSimula += 25
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Receita Grupo 1"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceGrp12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0116, 1, oFont ) )			//"Receita Grupo 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Receita Alíquota 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nReceAlq12 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0127, 1, oFont ) )			//"Receita Alíquota 1"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"% Estimado Alíquota 1"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqGrp12 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0128, 1, oFont ) )			//"% Estimado Alíquota 1"
	
	nTopSimul2 += 25
EndIf
		
Return( Nil )

/*/{Protheus.doc} AddDevedor
Adiciona os campos do Slado Devedor
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param cTributo, character, Código do Tributo da Apuração
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddDevedor( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )
/*/Static Function AddDevedor( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;	
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Saldo Devedor"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nSaldoDeve }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0129, 1, oFont ) )		//"Saldo Devedor"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	If cFormaTri1 != TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. cFormaTri1 != TRIBUTACAO_LUCRO_REAL
		If cTributo == TRIBUTO_IRPJ
			//"Provisão IRPJ"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )			//"Provisão IRPJ"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
		Else
			//"Valor Imposto"
			aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )			//"Valor Imposto"
			nEspaco += 65
			TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
		EndIf
		
		//"Deduções"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDeduco }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Deduções"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	Else
		//"Imposto Devido no Mês"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nImpDevMes }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no Mês"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	EndIf
	
	//"Compensações"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrCompen }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0134, 1, oFont ) )		//"Compensações"
	
	If cTributo == TRIBUTO_CSLL .and. cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		//"Adicionais do Tributo"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAdicTribu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	EndIf
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;	
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Saldo Devedor"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nSaldoDev2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0129, 1, oFont ) )		//"Saldo Devedor"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	If cFormaTri1 != TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. cFormaTri2 != TRIBUTACAO_LUCRO_REAL
		If cTributo == TRIBUTO_IRPJ
			//"Provisão IRPJ"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )			//"Provisão IRPJ"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
		Else
			//"Valor Imposto"
			aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )			//"Valor Imposto"
			nEspaco += 65
			TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
			nEspaco += 20
		EndIf
		
		//"Deduções"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDeduc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Deduções"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	Else
		//"Imposto Devido no Mês"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nImpDevMe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no Mês"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	EndIf
	
	//"Compensações"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrCompe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0134, 1, oFont ) )		//"Compensações"
	
	If cTributo == TRIBUTO_CSLL .and. cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		//"Adicionais do Tributo"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	EndIf
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddProIRPJ
Adiciona os campos da Provisão de IRPJ
@author david.costa
@since 27/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddProIRPJ( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )
/*/Static Function AddProIRPJ( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Provisão IRPJ"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provisão IRPJ"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Valor Imposto"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Valor Adicional"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicio }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0136, 1, oFont ) )		//"Valor Adicional"
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Provisão IRPJ"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provisão IRPJ"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Valor Imposto"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Valor Adicional"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdici2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0136, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrAdic
Adiciona os campos do valor de adicional do tributo
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrAdic( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddVlrAdic( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Adicional"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicio }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0149, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=(" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Base de Cálculo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Valor Isento"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrIsento }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || ")x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Alíquota Adicional"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqAdici }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0148, 1, oFont ) )		//"Alíquota Adicional"
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Adicional"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdici2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0149, 1, oFont ) )		//"Valor Adicional"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=(" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Base de Cálculo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Valor Isento"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrIsent2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || ")x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Alíquota Adicional"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqAdic2 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0148, 1, oFont ) )		//"Alíquota Adicional"
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrIsen
Adiciona os campos do valor de isentos
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrIsen( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2, lComparar )
/*/Static Function AddVlrIsen( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Isento"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrIsento }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Valor Parcela Isenta"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nParcIsent }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0146, 1, oFont ) )		//"Valor Parcela Isenta"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Número de meses"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nNMesesIse }, oDlgSimu, 50, 10, "@E 99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0145, 1, oFont ) )		//"Número de meses"
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//"Valor Isento"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrIsent2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0147, 1, oFont ) )		//"Valor Isento"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Valor Parcela Isenta"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nParcIsen2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0146, 1, oFont ) )		//"Valor Parcela Isenta"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Número de meses"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nNMesesIs2 }, oDlgSimu2, 50, 10, "@E 99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0145, 1, oFont ) )		//"Número de meses"
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddVlrImpo
Adiciona os campos do valor do imposto
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddVlrImpo( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )
/*/Static Function AddVlrImpo( oDlgSimu, oFont, cFormaTri1, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_IMUNE .or.;
	cFormaTri1 == TRIBUTACAO_ISENTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//Valor Imposto
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Base de Cálculo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nBaseCalcu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "x" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Alíquota"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAliqImpos }, oDlgSimu, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0144, 1, oFont ) )		//"Alíquota"
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_IMUNE .or.;
	cFormaTri2 == TRIBUTACAO_ISENTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_PRESUMIDO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_RECEI_BRUTA .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_ARBITRADO
	
	//Valor Imposto
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	//"Base de Cálculo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nBaseCalc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0110, 1, oFont ) )		//"Base de Cálculo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "x" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Alíquota"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAliqImpo2 }, oDlgSimu2, 50, 10, "@E 999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0144, 1, oFont ) )		//"Alíquota"
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddResCont
Adiciona os campos do Resultado Contábil
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param lRural1, ${bool}, Informa se os campos é para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lRural2, ${bool}, Informa se os campos é para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddResCont( oDlgSimu, oFont, cFormaTri1, .F., oDlgSimu2, cFormaTri2, .T. )
/*/Static Function AddResCont( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural1
		//"Resultado Contábil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResCtbRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResOpRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Resultado Não Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResNOpRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado Não Operacional"
		
		nTopSimula += 25
	Else
		//"Resultado Contábil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulCont }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulOper }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Resultado Não Operacional"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulNOpe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado Não Operacional"
		
		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Resultado Contábil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResCtbRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResOpRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Resultado Não Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResNOpRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado Não Operacional"
		
		nTopSimul2 += 25
	Else
		//"Resultado Contábil"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulCon2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulOpe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0143, 1, oFont ) )		//"Resultado Operacional"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Resultado Não Operacional"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulNOp2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0142, 1, oFont ) )		//"Resultado Não Operacional"
		
		nTopSimul2 += 25
	
	EndIf
	
EndIf

Return( Nil )

/*/{Protheus.doc} AddLucReal
Adiciona os campos do Lucro Real
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param lRural1, ${bool}, Informa se os campos é para a atividade Rural Evento 1
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@param lRural2, ${bool}, Informa se os campos é para a atividade Rural Evento 2
@return ${Nil}, ${Nulo}
@example
AddLucReal( oDlgSimu, oFont, cFormaTri1, .F., oDlgSimu2, cFormaTri2, .T. )
/*/Static Function AddLucReal( oDlgSimu, oFont, cFormaTri1, lRural1, oDlgSimu2, cFormaTri2, lRural2 )

Local oFonteOper	as object
Local nEspaco		as numeric

Default lRural1	:=	.F.
Default lRural2	:=	.F.

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If  lRural1
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLRealRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Contábil"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResCtbRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adições"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Exclusões"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExRur1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições por Doação"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDoaRu1 }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adições por Doação"
		
		nTopSimula += 25
	Else
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nLucroReal }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Contábil"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nResulCont }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrAdicoe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adições"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Exclusões"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrExclus }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições por Doação"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDoacoe }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adições por Doação"
		
		nTopSimula += 25
	EndIf
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.; 
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	If lRural2
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLRealRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Contábil"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResCtbRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adições"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Exclusões"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExRur2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições por Doação"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDoaRu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adições por Doação"
		
		nTopSimul2 += 25
	Else
		//"Lucro Real"
		oFont:Bold := .T.
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nLucroRea2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0113, 1, oFont ) )		//"Lucro Real"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		oFont:Bold := .F.
		
		//"Resultado Contábil"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nResulCon2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0141, 1, oFont ) )		//"Resultado Contábil"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrAdico2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0140, 1, oFont ) )		//"Adições"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Exclusões"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrExclu2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0112, 1, oFont ) )		//"Exclusões"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
		
		//"Adições por Doação"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDoaco2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0139, 1, oFont ) )		//"Adições por Doação"
		
		nTopSimul2 += 25
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} AddDeviMes
Adiciona os campos do cálculo do imposto devido no mês
@author david.costa
@since 30/01/2017
@version 1.0
@param oDlgSimu, objeto, Objeto que receberá os campos do Evento 1
@param oFont, objeto, Objeto com a fonte que será utilizada
@param cFormaTri1, character, Forma de tributação do Evento 1
@param cTributo, character, Tipo do tributo
@param oDlgSimu2, objeto, Objeto que receberá os campos do Evento 2
@param cFormaTri2, character, Forma de tributação do Evento 2
@return ${Nil}, ${Nulo}
@example
AddDeviMes( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )
/*/Static Function AddDeviMes( oDlgSimu, oFont, cFormaTri1, cTributo, oDlgSimu2, cFormaTri2 )

Local oFonteOper	as object
Local nEspaco		as numeric

oFonteOper	:=	TFont():New( "Arial",, -11 )
nEspaco	:=	12

oFonteOper:Bold := .T.

//Evento 1
If cFormaTri1 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri1 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	//"Imposto Devido no Mês"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nImpDevMes }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no Mês"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "=" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	If cTributo == TRIBUTO_IRPJ
		//"Provisão IRPJ"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrPrIRPJ }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provisão IRPJ"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	Else
		//"Valor Imposto"
		aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrImpost }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
		nEspaco += 65
		TSay():New( nTopSimula + 8, nEspaco,{ || "+" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	EndIf
		
	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nAdicTribu }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	
	//"Deduções"
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nVlrDeduco }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Deduções"
	nEspaco += 65
	TSay():New( nTopSimula + 8, nEspaco,{ || "-" }, oDlgSimu,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Imp. devido meses ant."
	aAdd( aoGet, TGet():New( nTopSimula, nEspaco, { || @nDeviAnter }, oDlgSimu, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0138, 1, oFont ) )			//"Imp. devido meses ant."
	
	nTopSimula += 25
	
EndIf

nEspaco := 12

//Evento 2
If cFormaTri2 == TRIBUTACAO_LUCRO_REAL .or.;
	cFormaTri2 == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	
	//"Imposto Devido no Mês"
	oFont:Bold := .T.
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nImpDevMe2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0133, 1, oFont ) )		//"Imposto Devido no Mês"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "=" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	oFont:Bold := .F.
	
	If cTributo == TRIBUTO_IRPJ
		//"Provisão IRPJ"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrPrIRP2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0130, 1, oFont ) )		//"Provisão IRPJ"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	Else
		//"Valor Imposto"
		aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrImpos2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0131, 1, oFont ) )		//"Valor Imposto"
		nEspaco += 65
		TSay():New( nTopSimul2 + 8, nEspaco,{ || "+" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
		nEspaco += 20
	EndIf
	
	//"Adicionais do Tributo"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nAdicTrib2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0135, 1, oFont ) )		//"Adicionais do Tributo"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20

	//"Deduções"
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nVlrDeduc2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0132, 1, oFont ) )		//"Deduções"
	nEspaco += 65
	TSay():New( nTopSimul2 + 8, nEspaco,{ || "-" }, oDlgSimu2,, oFonteOper,,,,.T., CLR_CYAN, CLR_WHITE, 20, 20 )
	nEspaco += 20
	
	//"Imp. devido meses ant."
	aAdd( aoGet, TGet():New( nTopSimul2, nEspaco, { || @nDeviAnte2 }, oDlgSimu2, 50, 10, "@E 99,999,999,999.99", { || .T. },,,,,, .T.,,, { || .F. },,,,,,,,,,,,.T.,, STR0138, 1, oFont ) )			//"Imp. devido meses ant."
	
	nTopSimul2 += 25
	
EndIf

Return( Nil )

/*/{Protheus.doc} LoadSimula
Carregas a tela de simulação conforme os dados do período selecionado
@author david.costa
@since 30/01/2017
@version 1.0
@param aListParam, array, Parametros da Simulação
@param nIndicePer, numérico, Indica o período selecionados
@param cLogAvisos, character, Log de avisos do processo
@return ${lRet}, ${Verdadeiro se a atualização for bem sucedida}
@example
LoadSimula( aListParam, nIndicePer, @cLogAvisos )
/*/Static Function LoadSimula( aListParam, nIndicePer, cLogAvisos )

Local oModelPer	as object
Local cFormaTrib	as character
Local nIndiceGet	as numeric
Local aParametro	as array
Local aParRural	as array
Local lRet			as logical
Local lRural		as logical

Default nIndicePer	:=	Val( oTreePerio:GetCargo() ) - 1

oModelPer	:=	Nil
cFormaTrib	:=	""
nIndiceGet	:=	0
aParametro	:=	{}
aParRural	:=	{}
lRet		:=	.T.
lRural		:=	.F.

If nIndicePer > 0
	
	oModelPer := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
	
	//Forma de tributação 
	cFormaTrib := xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 )
	
	//Verifica se o Evento tem atividade Rural
	lRural := !Empty( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )

	//Atualiza o array da apuração
	aParametro := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
	
	//Atualiza o array da apuração da Atividade Rural
	aParRural := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
	
	//Atualiza o Evento 1
	AtualizaEv( @cDescEve1, @cDescFTri1, aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ] )
	
	//Saldo Evento 1
	nSaldoEve1 := oModelPer:GetValue( "MODEL_CWV", "CWV_APAGAR" )
	
	//Descrição do período
	cDescPerio := FormatStr( "@1 à @2", { dToc( oModelPer:GetValue( "MODEL_CWV", "CWV_INIPER" ) ),;
		dToc( oModelPer:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )

	//Atualiza os valores da simulação
	If lRural
		nBaseCalcu	:= VlrLucReal( aParametro, aParRural )
		nVlrImpost	:= Iif( VlrBCxAliq( aParametro, aParRural ) > 0, VlrBCxAliq( aParametro, aParRural ), 0 )
		nVlrAdicio	:= Iif( VlrAdiciIR( aParametro, aParRural ) > 0, VlrAdiciIR( aParametro, aParRural ), 0 )
		nVlrPrIRPJ	:= Iif( VlrProIRPJ( aParametro, aParRural ) > 0, VlrProIRPJ( aParametro, aParRural ), 0 )
		nSaldoDeve	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ) > 0,;
		CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ), 0 )
	Else
		nBaseCalcu	:= VlrLucReal( aParametro )
		nVlrImpost	:= Iif( VlrBCxAliq( aParametro ) > 0, VlrBCxAliq( aParametro ), 0 )
		nVlrAdicio	:= Iif( VlrAdiciIR( aParametro ) > 0, VlrAdiciIR( aParametro ), 0 )
		nVlrPrIRPJ	:= Iif( VlrProIRPJ( aParametro ) > 0, VlrProIRPJ( aParametro ), 0 )
		nSaldoDeve	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) > 0, CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) , 0 )
	EndIf
	
	nAliqImpos	:= aParametro[ ALIQUOTA_IMPOSTO ]
	nVlrIsento	:= VlrIsento( aParametro )
	nParcIsent	:= aParametro[ PARCELA_ISENTA ]
	nNMesesIse	:= ( DateDiffMonth( aParametro[ INICIO_PERIODO ], aParametro[ FIM_PERIODO ] ) + 1 )
	nAliqAdici	:= aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ]
	nVlrDeduco	:= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]
	nVlrCompen	:= aParametro[ GRUPO_COMPENSACAO_TRIBUTO ]
	nReceAliq1	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ1 ]
	nReceAliq2	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ2 ]
	nReceAliq3	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ3 ]
	nReceAliq4	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ4 ]
	nReceGrup1	:= VlrReAliq1( aParametro )
	nReceGrup2	:= VlrReAliq2( aParametro )
	nReceGrup3	:= VlrReAliq3( aParametro )
	nReceGrup4	:= VlrReAliq4( aParametro )
	nAliqGrup1	:= aParametro[ ALIQUOTA_RECEITA_1 ]
	nAliqGrup2	:= aParametro[ ALIQUOTA_RECEITA_2 ]
	nAliqGrup3	:= aParametro[ ALIQUOTA_RECEITA_3 ]
	nAliqGrup4	:= aParametro[ ALIQUOTA_RECEITA_4 ]
	nLucEstima	:= VlrLucroEs( aParametro )
	nVlrExclus	:= VlrExcluso( aParametro )
	nDemaisRec	:= aParametro [ GRUPO_DEMAIS_RECEITAS ]
	nResulCont	:= VlrResCont( aParametro )
	nResulOper	:= aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
	nResulNOpe	:= aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	nLucroReal	:= VlrLRAntes( aParametro )
	nVlrAdicoe	:= VlrAdicoes( aParametro )
	nVlrDoacoe	:= VlrDoacoes( aParametro )
	nCompPreju	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
	nImpDevMes	:= Iif( VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ) > 0,;
	 				VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ), 0 )
	nDeviAnter	:= Iif( cFormaTrib == TRIBUTACAO_LUCRO_REAL, aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] )
	nAdicTribu	:= aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]
	nLRAposPj1	:= VlrLRApoPj( aParametro, aParRural )
	nPrejRura1	:= aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]
	nBCParcia1	:= VlrBCParci( aParametro, aParRural )
	nResCtbRu1	:= VlrResCont( aParRural )
	nResOpRur1	:= aParRural[ GRUPO_RESULTADO_OPERACIONAL ]
	nResNOpRu1	:= aParRural[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	nLRealRur1	:= VlrLRAntes( aParRural )
	nVlrAdRur1	:= VlrAdicoes( aParRural )
	nVlrExRur1	:= VlrExcluso( aParRural )
	nVlrDoaRu1	:= VlrDoacoes( aParRural )
	nLRApPjRu1	:= VlrLRApoPj( aParRural, aParametro )
	nPrejGera1	:= aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ]
	nPjCompGe1	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
	nBCParRur1	:= VlrBCParci( aParRural, aParametro )
	nCompPjRu1	:= aParRural[ GRUPO_COMPENSACAO_PREJUIZO ]
	
	//Atualiza Detalhamento
	SetColDet( oModelPer, @aColsDet1, aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_ID" ) )
	oGetDBDet1:SetArray( aColsDet1, .T. )
	oGetDBDet1:Refresh()
	
	//Atualiza o Log de Erros
	cLogPerio1 := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ]
	
	oFolderEve:Refresh()
	oFolder1:Refresh()
	oPanel1:Refresh()

	If Len( aListParam ) == 2
		
		//Atualiza o array da apuração
		aParametro := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
		
		//Atualiza o array da apuração da Atividade Rural
		aParRural := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
		
		//Período do segundo evento
		oModelPer := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
		
		//Verifica se o Evento tem atividade Rural
		lRural := !Empty( aListParam[ 2, 1 ]:GetValue( "MODEL_T0N", "T0N_IDEVEN" ) )
	
		//Atualiza o Evento 2
		AtualizaEv( @cDescEve2, @cDescFTri2, aListParam[ 2, PARAM_SIMUL_MODEL_EVENTO ] )
		
		//Saldo Evento 2
		nSaldoEve2 := oModelPer:GetValue( "MODEL_CWV", "CWV_APAGAR" )
		
		//Atualiza os valores da simulação
		If lRural
			nBaseCalc2	:= VlrLucReal( aParametro, aParRural )
			nVlrImpos2	:= Iif( VlrBCxAliq( aParametro, aParRural ) > 0, VlrBCxAliq( aParametro, aParRural ), 0 )
			nVlrAdici2	:= Iif( VlrAdiciIR( aParametro, aParRural ) > 0, VlrAdiciIR( aParametro, aParRural ), 0 )
			nVlrPrIRP2	:= Iif( VlrProIRPJ( aParametro, aParRural ) > 0, VlrProIRPJ( aParametro, aParRural ), 0 )
			nSaldoDev2	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ) > 0,;
			CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T., aParRural ), 0 )
		Else
			nBaseCalc2	:= VlrLucReal( aParametro )
			nVlrImpos2	:= Iif( VlrBCxAliq( aParametro ) > 0, VlrBCxAliq( aParametro ), 0 )
			nVlrAdici2	:= Iif( VlrAdiciIR( aParametro ) > 0, VlrAdiciIR( aParametro ), 0 )
			nVlrPrIRP2	:= Iif( VlrProIRPJ( aParametro ) > 0, VlrProIRPJ( aParametro ), 0 )
			nSaldoDev2	:= Iif( CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) > 0, CalcVlrAPg( aParametro, @cLogAvisos, oModelPer, .T. ) , 0 )
		EndIf
	
		//Atualiza os valores da simulação
		nAliqImpo2	:= aParametro[ ALIQUOTA_IMPOSTO ]
		nVlrIsent2	:= VlrIsento( aParametro )
		nParcIsen2	:= aParametro[ PARCELA_ISENTA ]
		nNMesesIs2	:= ( DateDiffMonth( aParametro[ INICIO_PERIODO ], aParametro[ FIM_PERIODO ] ) + 1 )
		nAliqAdic2	:= aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ]
		nVlrDeduc2	:= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]
		nVlrCompe2	:= aParametro[ GRUPO_COMPENSACAO_TRIBUTO ]
		nReceAlq12	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ1 ]
		nReceAlq22	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ2 ]
		nReceAlq32	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ3 ]
		nReceAlq42	:= aParametro[ GRUPO_RECEITA_BRUTA_ALIQ4 ]
		nReceGrp12	:= VlrReAliq1( aParametro )
		nReceGrp22	:= VlrReAliq2( aParametro )
		nReceGrp32	:= VlrReAliq3( aParametro )
		nReceGrp42	:= VlrReAliq4( aParametro )
		nAliqGrp12	:= aParametro[ ALIQUOTA_RECEITA_1 ]
		nAliqGrp22	:= aParametro[ ALIQUOTA_RECEITA_2 ]
		nAliqGrp32	:= aParametro[ ALIQUOTA_RECEITA_3 ]
		nAliqGrp42	:= aParametro[ ALIQUOTA_RECEITA_4 ]
		nLucEstim2	:= VlrLucroEs( aParametro )
		nVlrExclu2	:= VlrExcluso( aParametro )
		nDemaisRe2	:= aParametro [ GRUPO_DEMAIS_RECEITAS ]
		nResulCon2	:= VlrResCont( aParametro )
		nResulOpe2	:= aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
		nResulNOp2	:= aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
		nLucroRea2	:= VlrLRAntes( aParametro )
		nVlrAdico2	:= VlrAdicoes( aParametro )
		nVlrDoaco2	:= VlrDoacoes( aParametro )
		nCompPrej2	:= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
		nImpDevMe2	:= Iif( VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ) > 0,;
	 				VlrDeviMes( aParametro, oModelPer, aParRural, xFunID2Cd( aListParam[ 1, 1 ]:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) ), 0 )
		nDeviAnte2	:= Iif( cFormaTrib == TRIBUTACAO_LUCRO_REAL, aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ], aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] )
		nAdicTrib2	:= aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]
		nLRAposPj2	:= VlrLRApoPj( aParametro, aParRural )
		nPrejRura2	:= aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]
		nBCParcia2	:= VlrBCParci( aParametro, aParRural )
		nResCtbRu2 := VlrResCont( aParRural )
		nResOpRur2 := aParRural[ GRUPO_RESULTADO_OPERACIONAL ]
		nResNOpRu2 := aParRural[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
		nLRealRur2 := VlrLRAntes( aParRural )
		nVlrAdRur2 := VlrAdicoes( aParRural )
		nVlrExRur2 := VlrExcluso( aParRural )
		nVlrDoaRu2 := VlrDoacoes( aParRural )
		nLRApPjRu2 := VlrLRApoPj( aParRural, aParametro )
		nPrejGera2 := aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ]
		nPjCompGe2 := aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
		nBCParRur2 := VlrBCParci( aParRural, aParametro )
		nCompPjRu2 := aParRural[ GRUPO_COMPENSACAO_PREJUIZO ]
	
		//Atualiza Detalhamento
		SetColDet( oModelPer, @aColsDet2, aListParam[ 2, 1 ]:GetValue( "MODEL_T0N", "T0N_ID" ) )
		oGetDBDet2:SetArray( aColsDet2, .T. )
		oGetDBDet2:Refresh()

		//Atualiza o Log de Erros
		cLogPerio2 := aListParam[ 2, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_LOG_PERIODO ]
		
	EndIf

EndIf

//Refresh em todos os Tget da tela de simulação
For nIndiceGet := 1 to Len( aoGet ) 
	aoGet[ nIndiceGet ]:CtrlRefresh()
Next nIndiceGet
oMultiGet:Refresh()

Return( lRet )

/*/{Protheus.doc} SetColDet
Atualiza a Grid do Detalhamento com itens simulados
@author david.costa
@since 30/01/2017
@version 1.0
@param oModelPer, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param aColsDet, array, Passar por referência o array que receberá os dados da Grid
@param cIdEvento, character, Identificador do Evento
@return ${Nil}, ${Nulo}
@example
SetColDet( oModelPer, @aColsDet, cIdEvento )
/*/Static Function SetColDet( oModelPer, aColsDet, cIdEvento )

Local oModelDet	as object
Local oModelEve	as object
Local cTabelaECF	as character
Local cDescGrupo	as character
Local cCodCC		as character
Local cTipoCC		as character
Local cOperacao	as character
Local cRural		as character
Local cChaveT0O	as character
Local cOrigem		as character
Local cAliasQry	as character
Local nIndiceDet	as numeric
Local nIdGrupo	as numeric

oModelDet	:=	oModelPer:GetModel( "MODEL_CWX" )
oModelEve	:=	Nil
cTabelaECF	:=	""
cDescGrupo	:=	""
cCodCC		:=	""
cTipoCC	:=	""
cOperacao	:=	""
cRural		:=	""
cChaveT0O	:=	""
cOrigem	:=	""
cAliasQry	:= ""
nIndiceDet	:=	0
nIdGrupo	:= 0

aColsDet := {}
DbSelectArea( "T0O" )
T0O->( DbSetOrder( 1 ) )
For nIndiceDet := 1 to oModelDet:Length()
	oModelDet:GoLine( nIndiceDet )
	cOrigem := oModelDet:GetValue( "CWX_ORIGEM" )
	If !oModelDet:IsDeleted() .and. !Empty( oModelDet:GetValue( "CWX_ORIGEM" ) )
		
		cTipoCC := cCodCC := cOperacao := cRural := ""
		If !Empty( oModelDet:GetValue( "CWX_IDECF" ) )
			cTabelaECF := Posicione( "CH6", 1, xFilial("CH6") + oModelDet:GetValue( "CWX_IDECF" ) , "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
		Else
			cTabelaECF := Posicione( "CH8", 1, xFilial("CH8") + oModelDet:GetValue( "CWX_IDLAL" ) , "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" )
		EndIf
		
		cDescGrupo := Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_DESCRI )" )
		
		cChaveT0O := xFilial( "T0O" )
		cChaveT0O += cIdEvento
		cChaveT0O += STR( Val( Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_CODIGO )" ) ), 2 )
		cChaveT0O += oModelDet:GetValue( "CWX_SEQITE" )
		
		cRural := oModelDet:GetValue( "CWX_RURAL" )
		If !Empty( oModelDet:GetValue( "CWX_SEQITE" ) )
			nIdGrupo := Val( Posicione( "LEE", 1, xFilial("LEE") + oModelDet:GetValue( "CWX_IDCODG" ) ,"AllTrim( LEE_CODIGO )" ) )
			cChaveT0O := xFilial( "T0O" )
			If nIdGrupo == GRUPO_RECEITA_LIQUIDA_ATIVIDA .or. nIdGrupo == GRUPO_LUCRO_EXPLORACAO
				cChaveT0O += GetIdEvExp( cIdEvento )
			Else
				cChaveT0O += Posicione( "T0N", 1, xFilial("T0N") + cIdEvento ,"AllTrim( T0N_ID )" )
			EndIf
			cChaveT0O += STR( nIdGrupo, 2 )
			cChaveT0O += oModelDet:GetValue( "CWX_SEQITE" )
			T0O->( MsSeek( cChaveT0O ) )
		EndIf

	If cOrigem == ORIGEM_CONTA_CONTABIL
			//cCodCC := AllTrim( Posicione( "C1O", 3, xFilial("C1O") + T0O->T0O_IDCC ,"C1O_CODIGO" ) )
			cCodCC := AllTrim( Posicione( "C1O", 3, PadR( T0O->T0O_FILITE, Len( C1O->C1O_FILIAL ), " " ) + T0O->T0O_IDCC ,"C1O_CODIGO" ) )
			cTipoCC := T0O->T0O_TIPOCC
			cOperacao := T0O->T0O_OPERAC
		ElseIf cOrigem == ORIGEM_LALUR_PARTE_B
			cCodCC := XFUNID2Cd( T0O->T0O_IDPARB, "T0S", 1 )
			cTipoCC := T0O->T0O_TIPOCC
			cOperacao := T0O->T0O_OPERAC
		ElseIf cOrigem == ORIGEM_LANCAMENTO_MANUAL
			cOperacao := Posicione( "LEC", 1, xFilial("LEC") + cIdEvento + oModelDet:GetValue( "CWX_SEQITE" ), "LEC_TPOPER" )
		EndIf
		
		aAdd( aColsDet, { cOrigem, cDescGrupo, oModelDet:GetValue( "CWX_VALOR" ), cTabelaECF, cRural, cOperacao, cCodCC, cTipoCC, .F. } )
	EndIf
Next nIndiceDet

Return( Nil )

/*/{Protheus.doc} AtualizaEv
Atualiza os dados do evento que foi simulado
@author david.costa
@since 30/01/2017
@version 1.0
@param cDescEve, character, Passar por referência a variável global que armazenará a descrição do Evento
@param cDescFTri, character, Passar por referência a variável global que armazenará a forma de tributação do Evento
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@return ${Nil}, ${Nulo}
@example
AtualizaEv( @cDescEve, @cDescFTri, oModelEven )
/*/Static Function AtualizaEv( cDescEve, cDescFTri, oModelEven )

//Descrição do Evento
cDescEve := AllTrim( oModelEven:GetValue( "MODEL_T0N", "T0N_CODIGO" ) ) + Space(1) + AllTrim( oModelEven:GetValue( "MODEL_T0N", "T0N_DESCRI" ) )

//Forma de tributação do Evento
cDescFTri := Posicione( "T0K", 1, xFilial( "T0K" ) + oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "ALLTRIM( T0K_DESCRI )" )

//Descrição do Tributo
cTribu := Posicione( "T0J", 1, xFilial( "T0J" ) + oModelEven:GetValue( "MODEL_T0N", "T0N_IDTRIB" ), "ALLTRIM( T0J_CODIGO )" )

Return( Nil )

/*/{Protheus.doc} FormatStr
Formata uma string conforme os parametros passados
@author david.costa
@since 23/01/2017
@version 1.0
@param cTexto, character, Mensagem para que será formatada
@param aParam, Array, Array com valores para sibstituir variavéis na mensagem, 
	as variaveis na mensagem deverão iniciar com @ seguido de um sequencial
@return ${cTexto}, ${Mensagem tratada}
@example
AddLogErro( "O valor @1 do campo @2 está incorreto", @cLog, { 38, "AAA_TESTES" } )
A mensagem será gravada assim: "O valor 38 do campo AAA_TESTES está incorreto"
/*/Static Function FormatStr( cTexto, aParam )

Local nIndice	as numeric

Default aParam	:=	{}
Default cTexto	:=	""

nIndice	:=	0

For nIndice := 1 To Len( aParam )
	If ValType( aParam[ nIndice ] ) == "N"
		aParam[ nIndice ] := Str( aParam[ nIndice ] )
	EndIf

	cTexto := StrTran( cTexto, "@" + AllTrim( Str( nIndice ) ), AllTrim( aParam[ nIndice ] ) )
Next nIndice

Return( cTexto )

/*/{Protheus.doc} GetHeadCWX
Colunas da Grid de detalhamento dos itens na simulação
@author david.costa
@since 30/01/2017
@version 1.0
@param aHeader, array, Array que receberá as colunas
@return ${Nil}, ${Nulo}
@example
GetHeadCWX( @aHeader )
/*/Static Function GetHeadCWX( aHeader )

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("CWX")
While !Eof() .and. SX3->X3_ARQUIVO == "CWX"
		If Alltrim(SX3->X3_CAMPO) $ "CWX_ORIGEM|CWX_DCODGR|CWX_VALOR|CWX_TABECF|CWX_RURAL|"
  			aAdd( aHeader, { AlLTrim( X3Titulo() ),; // 01 - Titulo
				SX3->X3_CAMPO,;
           		SX3->X3_PICTURE,;
           		Iif( Alltrim(SX3->X3_CAMPO) $ "CWX_TABECF|", 60, 22 ),;
           		SX3->X3_DECIMAL,;
           		"",;
           		"",;
           		SX3->X3_TIPO,;
           		SX3->X3_F3,;				// 09 - F3
		 		SX3->X3_CONTEXT,;       	// 10 - Contexto
		 		SX3->X3_CBOX,; 	  			// 11 - ComboBox
		   		"", .F. } ) 		   		// 12 - Relacao
  		Endif
  		
   DbSkip()
End

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("T0O")
While !Eof() .and. SX3->X3_ARQUIVO == "T0O"
		If Alltrim(SX3->X3_CAMPO) $ "T0O_OPERAC|T0O_CODCC|T0O_TIPOCC|"
  			aAdd( aHeader, { AlLTrim( X3Titulo() ),;	// 01 - Titulo
				SX3->X3_CAMPO,;
           		SX3->X3_PICTURE,;
           		22,;
           		SX3->X3_DECIMAL,;
           		"",;
           		"",;
           		SX3->X3_TIPO,;
           		SX3->X3_F3,;							// 09 - F3
			 	SX3->X3_CONTEXT,;						// 10 - Contexto
			 	SX3->X3_CBOX,; 	  						// 11 - ComboBox
		    	"", .F. } ) 		   					// 12 - Relacao
  		Endif
  		
   DbSkip()
End

Return( Nil )

/*/{Protheus.doc} RelPartA
Gera o relatorio do LALUR Parte A
@author david.costa
@since 04/05/2017
@version 1.0
@param aListParam, array, (Descrição do parâmetro)
@return ${Nil}, ${Nulo}
@example
RelPartA( aListParam )
/*/Static Function RelPartA( aListParam )

Local oModelPeri	as object
Local oModelEven	as object
Local cLogErros	as character
Local nIndicePer	as numeric
Local nIndice		as numeric
Local aParametro	as array
Local aParRural	as array

cLogErros	:=	""
nIndicePer	:=	Iif( ( Val( oTreePerio:GetCargo() ) - 1 ) == 0, Val( oTreePerio:GetCargo() ), Val( oTreePerio:GetCargo() ) - 1 )
nIndice	:=	0
aParametro	:= {}
aParRural	:= {}

If nIndicePer > 0
	
	For nIndice := 1 to Len( aListParam )
		//Carrega o Período
		oModelPeri := aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
		
		//Carrega os parametros
		aParametro := aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PARAMETRO ]
		aParRural	:= aListParam[ nIndice, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_ARRAY_PAR_RURAL ]
		
		//Carrega o Evento
		oModelEven := aListParam[ nIndice, PARAM_SIMUL_MODEL_EVENTO ]
		
		If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
			xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
			RelApuraca( oModelEven, oModelPeri, @cLogErros, aParametro, aParRural )
		Else
			AddLogErro( STR0157, @cLogErros ) //"Este Relatório só pode ser gerado para a forma de tributação estimativa por levantamento de balanço."
		EndIf
	Next nIndice
		
	If !Empty( cLogErros )
		ShowLog( STR0164, cLogErros ) //ATENÇÃO
	EndIf
EndIf

Return()

/*/{Protheus.doc} RelPartB
Gera o relatorio do LALUR Parte B
@author david.costa
@since 05/05/2017
@version 1.0
@param aListParam, array, (Descrição do parâmetro)
@return ${Nil}, ${Nulo}
@example
RelPartB( aListParam )
/*/Static Function RelPartB( aListParam )

Local oModelPeri	as object
Local oModelEven	as object
Local cLogErros	as character
Local nIndicePer	as numeric

cLogErros	:=	""
nIndicePer	:=	Iif( ( Val( oTreePerio:GetCargo() ) - 1 ) == 0, Val( oTreePerio:GetCargo() ), Val( oTreePerio:GetCargo() ) - 1 )

If nIndicePer > 0 .and. Len( aListParam ) > 0
	oModelPeri := aListParam[ 1, PARAM_SIMUL_LISTA_PAR, nIndicePer, LISTA_PAR_MODEL_PERIODO ]
	
	//Carrega o Evento
	oModelEven := aListParam[ 1, PARAM_SIMUL_MODEL_EVENTO ]

	If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
		xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
		TAFR118( oModelPeri, @cLogErros )
	Else
		AddLogErro( STR0157, @cLogErros ) //"Este Relatório só pode ser gerado para a forma de tributação estimativa por levantamento de balanço."
	EndIf
		
	If !Empty( cLogErros )
		ShowLog( STR0164, cLogErros ) //ATENÇÃO
	EndIf
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe a mensagem de log de ocorrências.

@Param		cTitle	- Título da interface
			cBody	- Corpo da mensagem

@Author		Felipe C. Seolin
@Since		26/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ShowLog( cTitle, cBody )

Local oModal	as object

oModal	:=	FWDialogModal():New()

oModal:SetTitle( cTitle )
oModal:SetFreeArea( 250, 150 )
oModal:SetEscClose( .T. )
oModal:SetBackground( .T. )
oModal:CreateDialog()
oModal:AddCloseButton()

TMultiGet():New( 030, 020, { || cBody }, oModal:GetPanelMain(), 210, 100,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

oModal:Activate()

Return()

/*/{Protheus.doc} GetIdEvExp
Retorna o Id do Evento da Exploração
@author david.costa
@since 05/01/2018
@version 1.0
/*/Static Function GetIdEvExp( cIdEvento )

Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cAliasQry	as character
Local cIdEveExpl	as character

cAliasQry	:=	GetNextAlias()
cIdEveExpl	:= ""

cSelect	:= " T0O.T0O_IDEVEN "
cFrom		:= RetSqlName( "T0O" ) + " T0O "
cWhere		:= " T0O.T0O_FILIAL = '" + xFilial( "T0O" ) + "' "
cWhere		+= " AND T0O.D_E_L_E_T_ = ''"
cWhere		+= " AND T0O.T0O_ORIGEM = '" + ORIGEM_EVENTO_TRIBUTARIO + "' "
cWhere		+= " AND T0O.T0O_ID = '" + cIdEvento + "' "
cWhere		+= " AND T0O.T0O_IDGRUP = " + Str( GRUPO_DEDUCOES_TRIBUTO ) + " "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

If ( cAliasQry )->( !Eof() )
	cIdEveExpl := ( cAliasQry )->( T0O_IDEVEN )
EndIf

Return( cIdEveExpl )