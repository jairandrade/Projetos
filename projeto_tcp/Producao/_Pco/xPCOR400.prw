#INCLUDE "PCOR400.ch"
#INCLUDE "PROTHEUS.CH"

#define ANTES_LACO   	1
#define COND_LACO 		2
#define PROC_LACO 		3
#define DEPOIS_LACO 	4
#define PROC_FILTRO 	5
#define PROC_CARGO		6
#define BLOCK_FILTRO 	7

#define LIM_PERG 11
#define QUEB_INDEX 01
#define QUEB_LACO 02
#define QUEB_SEEK 03
#define QUEB_COND 04
#define QUEB_TITSUB 05
#define QUEB_FILTRO 06
#define COL_TIT 01
#define COL_IMPR 02
#define COL_TAM 03
#define COL_ORDEM 04
#define COL_ALIGN 05
#define COL_TRUNCA 06

// Release 4
#define TAM_CO			35		// Tamanho da celula conta orcamentaria
#define TAM_CLASSE		30		// Tamanho da celula classe
#define TAM_OPER		30		// Tamanho da celula operacao
#define TAM_HIST		40		// Tamanho da celula historico
#define TAM_PROCES		10		// Tamanho da celula Processo
#define TAM_DATA		12		// Tamanho da celula Data


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOR400  ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 09/03/2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de impressao dos movimentos (tabela AKD)            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOR400                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de impressao dos movimentos mod SIGAPCO.            ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao devera ser utilizada com a sua chamada normal a  ณฑฑ
ฑฑณ          ณ partir do Menu do sistema.                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function xPCOR400()

Local aArea	:= GetArea()
Local cPerg := "PCR400"

Local nX	:= 1		// Contador generico

If FindFunction("TRepInUse") .And. TRepInUse()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Desabilita as perguntas referentes a ordem e impressao de linha de total ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//    For nX := 12 To 16	                  
//		AjustaSXR4(  PadR(cPerg, Len(SX1->X1_GRUPO)) + AllTrim( Str( nX ) ), "S" )
//	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface de impressao                                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport := ReportDef( cPerg )
	
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf	             
	
	oReport:PrintDialog()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Antes de sair, habilita novamente as perguntas de ordem e linha de total ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//    For nX := 12 To 16	                  
//		AjustaSXR4(  PadR(cPerg, Len(SX1->X1_GRUPO)) + AllTrim( Str(nX) ), "C" )
//	Next nX

Else

	Return xPCOR400R3()

EndIf

RestArea(aArea)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ ReportDef บ Autor ณ Gustavo Henrique   บ Data ณ  03/07/06  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Definicao do objeto do relatorio personalizavel e das      บฑฑ
ฑฑบ          ณ secoes que serao utilizadas.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 - Grupo de perguntas do relatorio                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef( cPerg )

Local oReport
Local oMovOrdem1
Local oMovOrdem2
Local oMovOrdem3
Local oMovOrdem4
Local oMovOrdem5
Local nX, aTotFunc := {}

Local cReport 		:= "PCOR400" // Nome do relatorio
Local cAliasQry		:= GetNextAlias()

Local aOrdem		:= { STR0018, STR0019, STR0020, STR0021, STR0022 }	// "C.O.+Data" ### "C.O.+Classe+Opera็ใo" ### "Classe+Opera็ใo" ### "Opera็ใo" ### "Data+C.O.+Classe+Opera็ใo"

// Define blocos de codigo para impressao do codigo e descricao dos campos de quebra
Local bCO  			:= { || (cAliasQry)->( AllTrim( PcoRetCo(AKD_CO) + "-" + AK5_DESCRI) ) }
Local bClasse		:= { || (cAliasQry)->( AllTrim( AKD_CLASSE ) + "-" + AK6_DESCRI ) }
Local bOper  		:= { || (cAliasQry)->( AllTrim( AKD_OPER   ) + "-" + AKF_DESCRI ) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao do componente de impressao                                      ณ
//ณ                                                                        ณ
//ณTReport():New                                                           ณ
//ณExpC1 : Nome do relatorio                                               ณ
//ณExpC2 : Titulo                                                          ณ
//ณExpC3 : Pergunte                                                        ณ
//ณExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ณ
//ณExpC5 : Descricao                                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// "Relacao de Movimentos" ### "Este relatorio ira imprimir a Rela็ใo de Movimentos de acordo com os parโmetros solicitados pelo usuแrio. Para mais informa็๕es sobre este relatorio consulte o Help do Programa ( F1 )."
oReport := TReport():New( cReport, STR0001, cPerg, { |oReport| PCOR400Prt( oReport, cAliasQry, aOrdem, aTotFunc ) }, STR0017 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 1a. secao do relatorio - C.O. + Data                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem1 := TRSection():New( oReport, STR0025+":"+STR0018, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH"} , aOrdem )

TRCell():New( oMovOrdem1, "AKD_CO"    , "AKD", STR0008, /*Picture*/, TAM_CO		, /*lPixel*/, bCO		) 	// Conta Orcamentaria
TRCell():New( oMovOrdem1, "AKD_DATA"  , "AKD", STR0011, /*Picture*/, TAM_DATA	, /*lPixel*/, 			)	// Dt.Movim.
TRCell():New( oMovOrdem1, "AKD_CLASSE", "AKD", STR0012, /*Picture*/, TAM_CLASSE	, /*lPixel*/, bClasse	) 	// Classe
TRCell():New( oMovOrdem1, "AKD_OPER"  , "AKD", STR0013, /*Picture*/, TAM_OPER		, /*lPixel*/, bOper		) 	// Operacao
TRCell():New( oMovOrdem1, "AKD_HIST"  , "AKD", STR0014, /*Picture*/, TAM_HIST		, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem1, "AKD_PROCES", "AKD", STR0015, /*Picture*/, TAM_PROCES		, /*lPixel*/,			)	// Processo
TRCell():New( oMovOrdem1, "AKD_VALOR1", "AKD", STR0016, "@E 999,999,999.99"/*Picture*/, /*Tamanho*/, /*lPixel*/, {||AKD_VALOR1*IIf(AKD_TIPO=="1",1,-1)}/*CodeBlock*/ )	// Valor
oMovOrdem1:Cell("AKD_CO"):SetLineBreak()
oMovOrdem1:Cell("AKD_CLASSE"):SetLineBreak()
oMovOrdem1:Cell("AKD_OPER"):SetLineBreak()
oMovOrdem1:Cell("AKD_HIST"):SetLineBreak()

oBreak1 := TRBreak():New( oMovOrdem1, { || (cAliasQry)->( AKD_CO + DtoS(AKD_DATA) )	}, STR0004 )	// "* Total da Data *"
oBreak2 := TRBreak():New( oMovOrdem1, { || (cAliasQry)->( AKD_CO )					}, STR0003 )	// "* Total da Conta Orcamentaria *"
	           
aAdd(aTotFunc, TRFunction():New( oMovOrdem1:Cell("AKD_VALOR1"), , "SUM", oBreak1, , , , .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem1:Cell("AKD_VALOR1"), , "SUM", oBreak2, , , , .F. ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 2a. secao do relatorio - C.O. + Classe + Operacao     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem2 := TRSection():New( oReport, STR0025+":"+STR0019, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )

TRCell():New( oMovOrdem2, "AKD_CO"    , "AKD", STR0008, /*Picture*/, TAM_CO		, /*lPixel*/, bCO    	)	// Conta Orcamentaria
TRCell():New( oMovOrdem2, "AKD_CLASSE", "AKD", STR0012, /*Picture*/, TAM_CLASSE	, /*lPixel*/, bClasse	)	// Classe
TRCell():New( oMovOrdem2, "AKD_OPER"  , "AKD", STR0013, /*Picture*/, TAM_OPER		, /*lPixel*/, bOper 	)	// Operacao
TRCell():New( oMovOrdem2, "AKD_DATA"  , "AKD", STR0011, /*Picture*/, TAM_DATA		, /*lPixel*/, 			)	// Dt.Movim.
TRCell():New( oMovOrdem2, "AKD_HIST"  , "AKD", STR0014, /*Picture*/, TAM_HIST		, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem2, "AKD_PROCES", "AKD", STR0015, /*Picture*/, TAM_PROCES		, /*lPixel*/, 			)	// Processo
TRCell():New( oMovOrdem2, "AKD_VALOR1", "AKD", STR0016, "@E 999,999,999.99"/*Picture*/, /*Tamanho*/, /*lPixel*/, {|| AKD_VALOR1 * IIf( AKD_TIPO=="1",1,-1 ) }/*CodeBlock*/ )	// Valor
oMovOrdem2:Cell("AKD_CO"):SetLineBreak()
oMovOrdem2:Cell("AKD_CLASSE"):SetLineBreak()
oMovOrdem2:Cell("AKD_OPER"):SetLineBreak()
oMovOrdem2:Cell("AKD_HIST"):SetLineBreak()

oBreak1 := TRBreak():New( oMovOrdem2, { || (cAliasQry)->( AKD_CO + AKD_CLASSE + AKD_OPER )	}, STR0006 )	// "* Total Opera็ใo *"
oBreak2 := TRBreak():New( oMovOrdem2, { || (cAliasQry)->( AKD_CO + AKD_CLASSE ) 				}, STR0005 )	// "* Total da Classe *"
oBreak3 := TRBreak():New( oMovOrdem2, { || (cAliasQry)->( AKD_CO )							}, STR0003 )	// "* Total da Conta Orcamentaria *"
	           
aAdd(aTotFunc, TRFunction():New( oMovOrdem2:Cell("AKD_VALOR1"),, "SUM", oBreak1,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem2:Cell("AKD_VALOR1"),, "SUM", oBreak2,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem2:Cell("AKD_VALOR1"),, "SUM", oBreak3,,,, .F. ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 3a. secao do relatorio - Classe + Operacao            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem3 := TRSection():New( oReport, STR0025+":"+STR0020, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )

TRCell():New( oMovOrdem3, "AKD_CLASSE", "AKD", STR0012, /*Picture*/, TAM_CLASSE, /*lPixel*/, bClasse	)	// Classe
TRCell():New( oMovOrdem3, "AKD_OPER"  , "AKD", STR0013, /*Picture*/, TAM_OPER	, /*lPixel*/, bOper  	)	// Operacao
TRCell():New( oMovOrdem3, "AKD_CO"    , "AKD", STR0008, /*Picture*/, TAM_CO	, /*lPixel*/, bCO    	)	// Conta Orcamentaria
TRCell():New( oMovOrdem3, "AKD_DATA"  , "AKD", STR0011, /*Picture*/, TAM_DATA	, /*lPixel*/,			)	// Dt.Movim.
TRCell():New( oMovOrdem3, "AKD_HIST"  , "AKD", STR0014, /*Picture*/, TAM_HIST	, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem3, "AKD_PROCES", "AKD", STR0015, /*Picture*/, TAM_PROCES	, /*lPixel*/, 			)	// Processo
TRCell():New( oMovOrdem3, "AKD_VALOR1", "AKD", STR0016, "@E 999,999,999.99"/*Picture*/, /*Tamanho*/, /*lPixel*/, {|| AKD_VALOR1 * IIf( AKD_TIPO=="1",1,-1 ) }/*CodeBlock*/ )	// Valor
oMovOrdem3:Cell("AKD_CO"):SetLineBreak()
oMovOrdem3:Cell("AKD_CLASSE"):SetLineBreak()
oMovOrdem3:Cell("AKD_OPER"):SetLineBreak()
oMovOrdem3:Cell("AKD_HIST"):SetLineBreak()

oBreak1 := TRBreak():New( oMovOrdem3, { || (cAliasQry)->( AKD_CLASSE + AKD_OPER )	}, STR0006 )	// "* Total Opera็ใo *"
oBreak2 := TRBreak():New( oMovOrdem3, { || (cAliasQry)->( AKD_CLASSE )			}, STR0005 )	// "* Total da Classe *"
	           
aAdd(aTotFunc, TRFunction():New( oMovOrdem3:Cell("AKD_VALOR1"),, "SUM", oBreak1,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem3:Cell("AKD_VALOR1"),, "SUM", oBreak2,,,, .F. ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 4a. secao do relatorio - Operacao                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem4 := TRSection():New( oReport, STR0025+":"+STR0021, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )

TRCell():New( oMovOrdem4, "AKD_OPER"  , "AKD", STR0013, /*Picture*/, TAM_OPER	, /*lPixel*/, bOper		)	// Operacao
TRCell():New( oMovOrdem4, "AKD_CLASSE", "AKD", STR0012, /*Picture*/, TAM_CLASSE, /*lPixel*/, bClasse	)	// Classe
TRCell():New( oMovOrdem4, "AKD_CO"    , "AKD", STR0008, /*Picture*/, TAM_CO	, /*lPixel*/, bCO		)	// Conta Orcamentaria
TRCell():New( oMovOrdem4, "AKD_DATA"  , "AKD", STR0011, /*Picture*/, TAM_DATA	, /*lPixel*/, 			)	// Dt.Movim.
TRCell():New( oMovOrdem4, "AKD_HIST"  , "AKD", STR0014, /*Picture*/, TAM_HIST	, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem4, "AKD_PROCES", "AKD", STR0015, /*Picture*/, TAM_PROCES	, /*lPixel*/, 			)	// Processo
TRCell():New( oMovOrdem4, "AKD_VALOR1", "AKD", STR0016, "@E 999,999,999.99"/*Picture*/, /*Tamanho*/, /*lPixel*/, {|| AKD_VALOR1 * IIf( AKD_TIPO=="1",1,-1 ) }/*CodeBlock*/ )	// Valor
oMovOrdem4:Cell("AKD_CO"):SetLineBreak()
oMovOrdem4:Cell("AKD_CLASSE"):SetLineBreak()
oMovOrdem4:Cell("AKD_OPER"):SetLineBreak()
oMovOrdem4:Cell("AKD_HIST"):SetLineBreak()

oBreak1 := TRBreak():New( oMovOrdem4, { || (cAliasQry)->AKD_OPER }, STR0006 )	// "* Total Opera็ใo *"
           
aAdd(aTotFunc, TRFunction():New( oMovOrdem4:Cell("AKD_VALOR1"),, "SUM", oBreak1,,,, .F. ) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a 5a. secao do relatorio - Data + CO + Classe + Operacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMovOrdem5 := TRSection():New( oReport, STR0025+":"+STR0022, { cAliasQry, "AKD","AK1","AK5","AK6","AKF","AL2","CTT","CTD","CTH" } )

TRCell():New( oMovOrdem5, "AKD_DATA"  , "AKD", STR0011, /*Picture*/, TAM_DATA	, /*lPixel*/,         	)	// Dt.Movim.
TRCell():New( oMovOrdem5, "AKD_CO"    , "AKD", STR0008, /*Picture*/, TAM_CO	, /*lPixel*/, bCO		)	// Conta Orcamentaria
TRCell():New( oMovOrdem5, "AKD_CLASSE", "AKD", STR0012, /*Picture*/, TAM_CLASSE, /*lPixel*/, bClasse	)	// Classe
TRCell():New( oMovOrdem5, "AKD_OPER"  , "AKD", STR0013, /*Picture*/, TAM_OPER	, /*lPixel*/, bOper		)	// Operacao
TRCell():New( oMovOrdem5, "AKD_HIST"  , "AKD", STR0014, /*Picture*/, TAM_HIST	, /*lPixel*/, 			)	// Historico
TRCell():New( oMovOrdem5, "AKD_PROCES", "AKD", STR0015, /*Picture*/, TAM_PROCES	, /*lPixel*/, /*CodeBlock*/ )	// Processo
TRCell():New( oMovOrdem5, "AKD_VALOR1", "AKD", STR0016, "@E 999,999,999.99"/*Picture*/, /*Tamanho*/, /*lPixel*/, {|| AKD_VALOR1 * IIf( AKD_TIPO=="1",1,-1 ) }/*CodeBlock*/ )	// Valor
oMovOrdem5:Cell("AKD_CO"):SetLineBreak()
oMovOrdem5:Cell("AKD_CLASSE"):SetLineBreak()
oMovOrdem5:Cell("AKD_OPER"):SetLineBreak()
oMovOrdem5:Cell("AKD_HIST"):SetLineBreak()

oBreak1 := TRBreak():New( oMovOrdem5, { || (cAliasQry)->( DtoS(AKD_DATA) + AKD_CO + AKD_CLASSE + AKD_OPER )	}, STR0006 )	// "* Total Opera็ใo *"
oBreak2 := TRBreak():New( oMovOrdem5, { || (cAliasQry)->( DtoS(AKD_DATA) + AKD_CO + AKD_CLASSE )         		}, STR0005 )	// "* Total da Classe *"
oBreak3 := TRBreak():New( oMovOrdem5, { || (cAliasQry)->( DtoS(AKD_DATA) + AKD_CO )                      		}, STR0003 )	// "* Total da Conta Orcamentaria *"
oBreak4 := TRBreak():New( oMovOrdem5, { || (cAliasQry)->( DtoS(AKD_DATA) )                               		}, STR0004 )	// "* Total da Data *"
	           
aAdd(aTotFunc, TRFunction():New( oMovOrdem5:Cell("AKD_VALOR1"),, "SUM", oBreak1,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem5:Cell("AKD_VALOR1"),, "SUM", oBreak2,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem5:Cell("AKD_VALOR1"),, "SUM", oBreak3,,,, .F. ) )
aAdd(aTotFunc, TRFunction():New( oMovOrdem5:Cell("AKD_VALOR1"),, "SUM", oBreak4,,,, .F. ) )

oReport:SetTotalInLine( .F. )		// Configura total geral para impressao em colunas

For nX := 1 TO Len(aTotFunc)
	aTotFunc[nX]:disable()
Next 

Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PCOR400Prt บAutor ณ Gustavo Henrique  บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Executa query de consulta na tabela de movimentos (AKD) e  บฑฑ
ฑฑบ          ณ imprime o objeto oReport definido na funcao ReportDef.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPO1 - Objeto tReport com a definicao das secoes e celulasบฑฑ
ฑฑบ          ณ para impressao do relatorio.                               บฑฑ
ฑฑบ          ณ EXPC2 - Alias da query do relatorio                        บฑฑ
ฑฑบ          ณ EXPA3 - Array com as ordens do relatorio                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOR400Prt( oReport, cAliasQry, aOrdem, aTotFunc )
                           
Local oSection1 

Local nOrdem	:= oReport:Section(1):GetOrder() 
Local nX		:= 1					// Contador generico
Local nCont		:= 1					// Contador generico

Local aQuebras	:= {}					// Array com as condicoes de quebra do relatorio

Local cSqlExp	:= ""					// Expressao SQL de filtros do relatorio
Local cCO		:= ""					// Codigo da Conta orcamentaria
Local cClasse	:= ""					// Codigo da Classe
Local cOper		:= ""					// Codigo da Operacao
Local dData		:= CToD( "  /  /  " )	// Data do lancamento  
Local cQuery := ""
Local cQuery1:= ""
Local cDesc  := "" 
Local nQt    := 5    
Local aControle := {}    

Static nQtdEntid := CtbQtdEntd()                                     


MakeSqlExp( oReport:uParam )   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta descricao e query para atender 				ณ
//ณa abertura de (n) entidades                      	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nQtdEntid == Nil
	nQtdEntid := If(FindFunction("CtbQtdEntd"), CtbQtdEntd(), 4)
Else
	aArea := GetArea()
	If nQtdEntid > 4
		While nQt <= nQtdEntid
			DbSelectArea('CT0')
			DbSetOrder(1)
			DbSeek(xFilial()+STRZERO(nQt,2))
			If AScan(aControle,CT0_ALIAS) == 0
				AADD(aControle, CT0_ALIAS)
				If &("AKD->AKD_ENT"+STRZERO(nQt,2)) == ""
					cDesc += ", "+CT0_CPODSC 
					cQuery1 += " LEFT OUTER JOIN "  
					cQuery1 += RetSqlName(CT0_ALIAS)+" "+CT0_ALIAS
					cQuery1 += " ON "+CT0->CT0_ALIAS+"." + Alltrim(CT0->CT0_ALIAS) + "_FILIAL" +" = '"+xFilial(CT0->CT0_ALIAS)+"' "   
					cQuery1 += " AND "+CT0->CT0_ALIAS+"." + CT0->CT0_CPOCHV +" = AKD.AKD_ENT"+STRZERO(nQt,2)
					cQuery1 += " AND "+CT0->CT0_ALIAS+".D_E_L_E_T_ = ' ' "
				EndIf
			Endif
			nQt += 1
		CT0->(DbSkip())
		Enddo
	Endif       
	RestArea(aArea)          
Endif        

If AKD->(FieldPos("AKD_UNIORC")) > 0
	cDesc += ", AMF_DESCRI"

	cQuery1 += " LEFT OUTER JOIN "
	cQuery1 += RetSqlName("AMF")+" AMF ON "
	cQuery1 += " AMF_FILIAL = '"+xFilial("AMF")+"' "
	cQuery1 += " AND AMF_CODIGO = AKD.AKD_UNIORC "
	cQuery1 += " AND AMF.D_E_L_E_T_ = ' ' "
Endif

cDesc	:= '%' + cDesc + '%'
cQuery1	:= '%' + cQuery1 + '%'
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta expressao de filtro da query com os parametros informados                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSqlExp += " AND AKD_DATA	BETWEEN '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "'"
cSqlExp += " AND AKD_CO		BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
cSqlExp += " AND AKD_CLASSE	BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "'"
cSqlExp += " AND AKD_OPER	BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "'"

If !Empty(mv_par09)
	cSqlExp += " AND AKD_TPSALD = '" + mv_par09 + "'"
Else
	Aviso(STR0023,STR0026, {"Ok"})  //"Atencao"##"Tipo de Saldo nao Informado. Verifique."
	oReport:CancelPrint()
	Return
EndIf

cSqlExp += " AND AKD_PROCES	BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "'"
//nao considera os lancamentos estornados
cSqlExp += " AND AKD_STATUS != '3'"

cSqlExp := "%" + cSqlExp + "%"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria objetos de quebra e totalizacao de acordo com a ordem escolhida no relatorio      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem == 1			// C.O. + Data
                
	oSection1 := oReport:Section(nOrdem)

	AAdd( aQuebras, { { || cCO   <> (cAliasQry)->AKD_CO   }, "AKD_CO"  , { || cCO   := (cAliasQry)->AKD_CO   }, .F. } )	
	AAdd( aQuebras, { { || dData <> (cAliasQry)->AKD_DATA }, "AKD_DATA", { || dData := (cAliasQry)->AKD_DATA }, .F. } )
	aTotFunc[1]:enable()
	aTotFunc[2]:enable()
	
	cOrder := "%" + " AKD_CO , AKD_DATA" + "%"
                                                        
ElseIf nOrdem == 2		// C.O. + Classe + Oper

	oSection1 := oReport:Section(nOrdem)

	AAdd( aQuebras, { { || cCO     <> (cAliasQry)->AKD_CO     }, "AKD_CO"    , { || cCO     := (cAliasQry)->AKD_CO     }, .F. } )	
	AAdd( aQuebras, { { || cClasse <> (cAliasQry)->AKD_CLASSE }, "AKD_CLASSE", { || cClasse := (cAliasQry)->AKD_CLASSE }, .F. } )
	AAdd( aQuebras, { { || cOper   <> (cAliasQry)->AKD_OPER   }, "AKD_OPER"  , { || cOper   := (cAliasQry)->AKD_OPER   }, .F. } )
	aTotFunc[3]:enable()
	aTotFunc[4]:enable()
	aTotFunc[5]:enable()

	cOrder := "%" + " AKD_CO , AKD_CLASSE , AKD_OPER" + "%"

ElseIf nOrdem == 3		// Classe + Oper

	oSection1 := oReport:Section(nOrdem)

	AAdd( aQuebras, { { || cClasse <> (cAliasQry)->AKD_CLASSE }, "AKD_CLASSE", { || cClasse := (cAliasQry)->AKD_CLASSE }, .F. } )
	AAdd( aQuebras, { { || cOper   <> (cAliasQry)->AKD_OPER   }, "AKD_OPER"  , { || cOper   := (cAliasQry)->AKD_OPER   }, .F. } )
	aTotFunc[6]:enable()
	aTotFunc[7]:enable()

	cOrder := "%" + " AKD_CLASSE , AKD_OPER" + "%"

ElseIf nOrdem == 4		// Operacao

	oSection1 := oReport:Section(nOrdem)

	AAdd( aQuebras, { { || cOper <> (cAliasQry)->AKD_OPER }, "AKD_OPER", { || cOper := (cAliasQry)->AKD_OPER }, .F. } )
	aTotFunc[8]:enable()

	cOrder := "%" + " AKD_OPER" + "%"

ElseIf nOrdem == 5		// Data + CO + Classe + Operacao

	oSection1 := oReport:Section(nOrdem)

	AAdd( aQuebras, { { || dData   <> (cAliasQry)->AKD_DATA   }, "AKD_DATA"  , { || dData   := (cAliasQry)->AKD_DATA   }, .F. } )
	AAdd( aQuebras, { { || cCO     <> (cAliasQry)->AKD_CO     }, "AKD_CO"    , { || cCO     := (cAliasQry)->AKD_CO     }, .F. } )	
	AAdd( aQuebras, { { || cClasse <> (cAliasQry)->AKD_CLASSE }, "AKD_CLASSE", { || cClasse := (cAliasQry)->AKD_CLASSE }, .F. } )
	AAdd( aQuebras, { { || cOper   <> (cAliasQry)->AKD_OPER   }, "AKD_OPER"  , { || cOper   := (cAliasQry)->AKD_OPER   }, .F. } )
	aTotFunc[ 9]:enable()
	aTotFunc[10]:enable()
	aTotFunc[11]:enable()
	aTotFunc[12]:enable()

	cOrder := "%" + " AKD_DATA , AKD_CO , AKD_CLASSE , AKD_OPER" + "%"

EndIf

oReport:SetTitle( oReport:Title() + " - Por ordem de " + aOrdem[nOrdem] )

nLenQuebra := Len( aQuebras )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Query do relatorio para a secao 1                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1:BeginQuery()

BeginSql Alias cAliasQry

	SELECT
		AKD_CO, AKD_DATA, AKD_CLASSE, AKD_OPER, AKD_HIST, AKD_PROCES,;
		AKD_TIPO, AKD_VALOR1, AK5_DESCRI, AK6_DESCRI, AKF_DESCRI %exp:cDesc%
	FROM 
		%table:AKD% AKD 

			LEFT OUTER JOIN %table:AK1% AK1
			ON 	AK1.AK1_FILIAL = %xfilial:AK1%
				AND AK1_CODIGO = AKD_CODPLA
				AND AK1.%notDel%

			LEFT OUTER JOIN %table:AK5% AK5
			ON 	AK5.AK5_FILIAL = %xfilial:AK5%
				AND AK5_CODIGO = AKD_CO
				AND AK5.%notDel%

			LEFT OUTER JOIN %table:AK6% AK6
			ON	AK6.AK6_FILIAL = %xfilial:AK6%
				AND AK6_CODIGO = AKD_CLASSE
				AND AK6.%notDel%

			LEFT OUTER JOIN %table:AKF% AKF
			ON  AKF.AKF_FILIAL = %xfilial:AKF%
				AND AKF_CODIGO = AKD_OPER
				AND AKF.%notDel%

			LEFT OUTER JOIN %table:AL2% AL2
			ON 	AL2.AL2_FILIAL = %xfilial:AL2%
				AND AL2_TPSALD = AKD_TPSALD
				AND AL2.%notDel%

			LEFT OUTER JOIN %table:CTT% CTT
			ON  CTT.CTT_FILIAL = %xfilial:CTT%
				AND CTT_CUSTO  = AKD_CC
				AND CTT.%notDel%

			LEFT OUTER JOIN %table:CTD% CTD
			ON  CTD.CTD_FILIAL = %xfilial:CTD%
				AND CTD_ITEM  = AKD_ITCTB
				AND CTD.%notDel%

			LEFT OUTER JOIN %table:CTH% CTH
			ON  CTH.CTH_FILIAL = %xfilial:CTH%
				AND CTH_CLASSE  = AKD_CLVLR
				AND CTH.%notDel%             
				
			%exp:cQuery1%	       
			
	WHERE
		AKD.AKD_FILIAL = %xfilial:AKD%
		AND AKD.%notDel%
		%exp:cSqlExp%
	ORDER BY %exp:cOrder%

EndSql	
                      
oSection1:EndQuery()

oSection1:SetHeaderPage()			// Configura cabecalho para impressao no inicio de cada pagina

oReport:SetMeter( AKD->( RecCount() ) )
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia impressao do relatorio                                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
(cAliasQry)->( dbGoTop() )

If (cAliasQry)->( Eof() )

	Aviso( STR0023, STR0024, {"Ok"} )	// "Aten็ใo" ### "Nใo existem dados para os parโmetros especificados."

	oReport:CancelPrint()

Else	

	oSection1:Init()
	
	Do While (cAliasQry)->( ! EoF() ) .And. !oReport:Cancel()
	                    
		If oReport:Cancel()
			Exit
		EndIf		                    
	                                    
		oReport:IncMeter()
	
	    For nX := 1 To nLenQuebra
			If Eval( aQuebras[ nX, 1 ] ) .Or. ( nX > 1 .And. aQuebras[ nX-1, 4 ] )
				oSection1:Cell( aQuebras[ nX, 2 ] ):Show()
				Eval( aQuebras[ nX, 3 ] )
				aQuebras[ nX, 4 ] := .T.
			EndIf
		Next nX
	                                     
	 	oSection1:PrintLine()
	                         
		For nX := 1 To nLenQuebra
			If aQuebras[ nX, 4 ]
				oSection1:Cell( aQuebras[ nX, 2 ] ):Hide()
				aQuebras[ nX, 4 ] := .F.     
			EndIf
		Next nX
	     
		(cAliasQry)->( dbSkip() )
		
	EndDo           
	
	oSection1:Finish()

EndIf
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjustaSXR4 บ Autor ณ Gustavo Henrique บ Data ณ  04/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Desabilita as perguntas de ordem e de impressao de linhas  บฑฑ
ฑฑบ          ณ totalizadoras no relatorio.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Planejamento e Controle Orcamentario                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSXR4( cPerg, cValor )

/*dbSelectArea("SX1")
dbSetOrder(1)
If MsSeek( cPerg )
	Reclock("SX1", .F.)
	SX1->X1_GSC := cValor
	MsUnlock()
EndIf*/

Return NIL

/*
------------------------------------------------------------- RELEASE 3 --------------------------------------------------------
*/



/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOR400R3ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 09/03/2005 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de impressao dos movimentos (tabela AKD)            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOR400                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de impressao dos movimentos mod SIGAPCO.            ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao devera ser utilizada com a sua chamada normal a  ณฑฑ
ฑฑณ          ณ partir do Menu do sistema.                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function uPCOR400R3()
Local aArea		:= GetArea()
Local lOk		:= .F.
Local nX, cPerg := "PCR400"
Private nLin	:= 200
Private cTitulo := STR0001 //"Relacao dos Movimentos"
////ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
////ณ habilita sempre as perguntas de ordem e linha de total ณ
////ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//For nX := 12 To 16	                  
//	AjustaSXR4( PadR(cPerg, Len(SX1->X1_GRUPO)) + AllTrim( Str(nX) ), "C" )
//Next nX
	
oPrint := PcoPrtIni(cTitulo,.T.,2,,@lOk,"PCR400") 

If lOk
	RptStatus( {|lEnd| PCOR400Imp(@lEnd,oPrint)})
EndIf

PcoPrtEnd(oPrint)

RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณPCOR400Impณ Autor ณ Paulo Carnelossi      ณ Data ณ09/03/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao de impressao dos movimentos (tabela AKD).            ณฑฑ
ฑฑณ          ณDefinicao do array com as quebras e com as colunas          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณPCOR400Imp(lEnd)                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ lEnd - Variavel para cancelamento da impressao pelo usuarioณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PCOR400Imp(lEnd,oPrint)
Local nX, lAlinDir := .T.

Private aColPos := {}
Private aQuebra, aColuna, nOrdem := mv_par12
Private aCondRel
Private aTitQueb
Private aValQueb, aImprTot

//parametros do relatorio
//PCR400  ฆ01      ฆPeriodo de ?
//PCR400  ฆ02      ฆPeriodo ate ?
//PCR400  ฆ03      ฆC.O. de ?
//PCR400  ฆ04      ฆC.O. ate ?
//PCR400  ฆ05      ฆClasse de ?
//PCR400  ฆ06      ฆClasse ate ?
//PCR400  ฆ07      ฆOperacao de ?
//PCR400  ฆ08      ฆOperacao ate ?
//PCR400  ฆ09      ฆTipo de Saldo ?
//PCR400  ฆ10      ฆProcesso de ?
//PCR400  ฆ11      ฆProcesso Ate ?
//PCR400  ฆ12      ฆOrdem Relatorio ?
//PCR400  ฆ13      ฆNivel 1 - Totaliza ?
//PCR400  ฆ14      ฆNivel 2 - Totaliza ?
//PCR400  ฆ15      ฆNivel 3 - Totaliza ?
//PCR400  ฆ16      ฆNivel 4 - Totaliza ?

//acerta mv_par para nao dar conflito com base de dados
//porem sx1 deve ser acertado caso cliente modifique os tamanhos padroes
mv_par03 := PadR(mv_par03, Len(AKD->AKD_CO))
mv_par04 := PadR(mv_par04, Len(AKD->AKD_CO))
mv_par05 := PadR(mv_par05, Len(AKD->AKD_CLASSE))
mv_par06 := PadR(mv_par06, Len(AKD->AKD_CLASSE))
mv_par07 := PadR(mv_par07, Len(AKD->AKD_OPER))
mv_par08 := PadR(mv_par08, Len(AKD->AKD_OPER))
mv_par09 := PadR(mv_par09, Len(AKD->AKD_TPSALD))
mv_par10 := PadR(mv_par10, Len(AKD->AKD_PROCES))
mv_par11 := PadR(mv_par11, Len(AKD->AKD_PROCES))

If Empty(mv_par09)
	Aviso(STR0023,STR0026, {"Ok"})//"Atencao"##"Tipo de Saldo nao Informado. Verifique."
	Return
EndIf

If nOrdem == 0
	Aviso(STR0023,STR0027, {"Ok"})//"Atencao"##"Ordem nao informada. Verifique!"
	Return
EndIf

//acerta titulo principal do relatorio
cTitCab := cTitulo
cTitCab += STR0009+DtoC(mv_par01)+STR0010+DtoC(mv_par02) //" - Periodo de: "###" a "
cTitCab += STR0002+mv_par09+" - " //"   - Tipo de Saldo: "
cTitCab += Alltrim(Posicione("AL2", 1, xFilial("AL2")+mv_par09,"AL2_DESCRI"))

//DEFINICAO DAS QUEBRAS DO RELATORIO / INDICE / SEEK INICIAL

//1o. Elemento - Indice	da tabela AKD
//2o. Elemento - Array com CodeBlock das quebras
//3o. Elemento - dbSeek com sotseek para inicio
//4o. Elemento - Condicao Loop principal
//5o. Elemento - Array com titulos para Sub-total
//6o. Elemento - array Filtros para quebras

aQuebra := 	{;
				{ 2, ;   // indice
					{ {||AKD->AKD_CO}, {||DTOS(AKD->AKD_DATA)} }, ; //quebras
					{||dbSeek(xFilial("AKD")+mv_par03, .T.) }, ;  //softseek inicio
    				{||AKD_CO <= mv_par04 }, ; //cond loop principal
	                {STR0003, STR0004}, ;  //titulo SubTotal //"* Total da Conta Orcamentaria *"###"* Total da Data *"
					{R400MontaFiltro({3,4}), R400MontaFiltro({1,2})};  //filtros
				},;
				{ 6, ;
					{ {||AKD->AKD_CO}, {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER} }, ;
					{||dbSeek(xFilial("AKD")+mv_par03, .T.)}, ;
    	            {||AKD_CO <= mv_par04 }, ;
	                {STR0003, STR0005, STR0006}, ; //"* Total da Conta Orcamentaria *"###"* Total da Classe *"###"* Total Operacao *"
                	{R400MontaFiltro({3,4}), R400MontaFiltro({5,6}), R400MontaFiltro({7,8}) };
				},;
				{ 7, ;
					{ {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER} }, ;
					{||dbSeek(xFilial("AKD")+mv_par05, .T.)}, ;
    	            {||AKD_CLASSE <= mv_par06 }, ;
	                {STR0007, STR0006}, ; //"* Total da Classe Orcamentaria *"###"* Total Operacao *"
                	{R400MontaFiltro({5,6}), R400MontaFiltro({7,8})};
				},;
				{ 8, ;
					{ {||AKD->AKD_OPER} } , ;
					{||dbSeek(xFilial("AKD")+mv_par07, .T.)}, ;
    	            {||AKD_OPER <= mv_par08 }, ;
	                {STR0006}, ; //"* Total Operacao *"
                	{R400MontaFiltro({7,8})};
				},;
				{ 9, ;
					{ {||DTOS(AKD->AKD_DATA)}, {||AKD->AKD_CO}, {||AKD->AKD_CLASSE}, {||AKD->AKD_OPER}  }, ;
					{||dbSeek(xFilial("AKD")+DTOS(mv_par01), .T.)}, ;
    	            {||DTOS(AKD_DATA) <= DTOS(mv_par02) }, ;
	                {STR0004, STR0003, STR0007, STR0006}, ; //"* Total da Data *"###"* Total da Conta Orcamentaria *"###"* Total da Classe Orcamentaria *"###"* Total Operacao *"
                	{R400MontaFiltro({1,2}), R400MontaFiltro({3,4}), R400MontaFiltro({5,6}), R400MontaFiltro({7,8})};
				};
			}

//DEFINICAO DAS COLUNAS DO RELATORIO

//1o. Elemento - Titulo da Coluna
//2o. Elemento - CodeBlock para impressao da linha detalhe
//3o. Elemento - Tamanho da Coluna (impressao grafica)
//4o. Elemento - Array com posicao da coluna de acordo ordem do relatorio
aColuna := {;
				{STR0008, ; //"Conta Orcamentaria"
					{||PcoRetCo(AKD->AKD_CO)+"-"+PadR(Posicione("AK5", 1, xFilial("AK5")+AKD->AKD_CO, "AK5_DESCRI"), 40) },;
						700, ;
							{1, 1, 3, 2, 2 }, !lAlinDir, .F. },;
				{STR0011,; //"Dt.Movim."
					{||DTOC(AKD->AKD_DATA)},;
						180, ;
							{2, 4, 4, 3, 1 }, !lAlinDir, .F. },;
				{STR0012,; //"Classe"
					{||AKD->AKD_CLASSE+"-"+PadR(Posicione("AK6", 1, xFilial("AK6")+AKD->AKD_CLASSE,"AK6_DESCRI"),30)},;
						600, ;
							{3, 2, 1, 4, 3 }, !lAlinDir, .T. },;
				{STR0013,; //"Operacao"
					{||AKD->AKD_OPER+"-"+PadR(Posicione("AKF", 1, xFilial("AKF")+AKD->AKD_OPER,"AKF_DESCRI"),30)},;
						400, ;
							{4, 3, 2, 1, 4 }, !lAlinDir, .T. },;
				{STR0014,; //"Historico"
					{||SubStr(AKD->AKD_HIST,1,48)},;
						700, ;
							{5, 5, 5, 5, 5 }, !lAlinDir, .F. },;
				{STR0015,; //"Proc."
					{||AKD->AKD_PROCES},;
						180, ;
							{6, 6, 6, 6, 6 }, !lAlinDir, .F. },;  							
				{STR0016,; //"Valor"
					{|| Transform(AKD->AKD_VALOR1*IIf(AKD->AKD_TIPO=="1",1,-1), "@E 999,999,999.99")},;
						400, ;
							{7, 7, 7, 7, 7 }, lAlinDir, .F. };
			}

//chamada da funcao de impressao do relatorio
R400DetRel(aQuebra, aColuna, cTitCab, nOrdem)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400DetRel  บAutor  ณPaulo Carnelossi  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do relatorio - monta as quebras e filtros e execu-บฑฑ
ฑฑบ          ณta funcao que imprimira o relatorio                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400DetRel(aQuebra, aColuna, cTitCab, nOrdem)
Local bProcto, bExecNotFilter, nCondRel
Local nX

dbSelectArea("AKD")
dbSetOrder(aQuebra[nOrdem][QUEB_INDEX])
Eval(aQuebra[nOrdem][QUEB_SEEK])

ASORT(aColuna,,, { |x, y| x[COL_ORDEM][nOrdem] < y[COL_ORDEM][nOrdem] })

//bloco de codigo para impressao do detalhe do relatorio
//nao pode esquecer dbskip -- senao sistema entra em loop 
bProcto := {|nNivel|R400ImpDet(aColuna, cTitCab, nNivel),;
					aValQueb[nNivel] += (AKD->AKD_VALOR1*IIf(AKD->AKD_TIPO=="1",1,-1)),;
					 AKD->(dbSkip())}
					 
//bloco de codigo para execucao quando filtro nao satisfaz a condicao
//tradicionalmente e colocado if <condicao> -- dbskip -- loop -- endif
//funciona da mesma forma - nao pode esquecer dbskip -- senao sistema entra em loop 
bExecNotFilter :=  {|nNivel| AKD->(dbSkip())}

//array que contera as quebras e blocos de codigos a ser executado em cada nivel
//para ser utilizado na funcao DetalheRel()
aCondRel := {}
nCondRel := Len(aQuebra[nOrdem][QUEB_LACO])

For nX := 1 TO nCondRel
	aAuxCond := {,,,,,,}
	If nX == 1   //no caso deste relatorio nivel 1 e definido aqui
		aAuxCond[ANTES_LACO] := {||Eval(aQuebra[nOrdem][QUEB_LACO][1])}
		aAuxCond[COND_LACO] := aQuebra[nOrdem][QUEB_COND]
		If nCondRel == nX  //quando ha somente um nivel o detalhe e no proprio nivel
			aAuxCond[PROC_LACO] := {|nNivel|R400ChkQuebra(nNivel, aColuna), R400TitQuebra(nNivel, aColuna), Eval(bProcto, nNivel)}
		Else
			aAuxCond[PROC_LACO] := {|nNivel|R400ChkQuebra(nNivel, aColuna), R400TitQuebra(nNivel, aColuna)}
		EndIf		
		aAuxCond[DEPOIS_LACO] := {|nNivel|R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))}
		aAuxCond[PROC_FILTRO] := aQuebra[nOrdem][QUEB_FILTRO][nX]
    Else
    	//demais niveis monta a chave e a condicao do laco de cada nivel
		aAuxCond[ANTES_LACO] := R400Chave(aClone(aQuebra[nOrdem][QUEB_LACO]), nX)
		aAuxCond[COND_LACO] := R400CondLaco(aClone(aQuebra[nOrdem][QUEB_LACO]), nX)
		aAuxCond[PROC_LACO] := If(Len(aQuebra[nOrdem][QUEB_LACO])==nX, bProcto, {|nNivel|R400TitQuebra(nNivel, aColuna)})
		aAuxCond[DEPOIS_LACO] := {|nNivel|aValQueb[nNivel-1] += aValQueb[nNivel],R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))}
		aAuxCond[PROC_FILTRO] := aQuebra[nOrdem][QUEB_FILTRO][nX]
	EndIf
	aAuxCond[PROC_CARGO] := ""
	aAuxCond[BLOCK_FILTRO] := bExecNotFilter
	aAdd(aCondRel, aClone(aAuxCond))
Next

//imprime o cabecalho
R400Cab(aColuna, aColPos, cTitCab)

//array para checkar se mudou a quebra e se imprime total de cada quebra
aTitQueb := {"","","",""}   //inicializado pois relatorio so tem 04 quebras no maximo
aValQueb := {0,0,0,0}   //inicializado pois relatorio so tem 04 quebras no maximo
aImprTot := {MV_PAR13==1,MV_PAR14==1,MV_PAR15==1,MV_PAR16==1}   //inicializado pois relatorio so tem 04 quebras no maximo

//imprime o relatorio  -- passado array aCondicao - nNivel Inicio - ALIAS
DetalheRel(aCondRel, 1, "AKD")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ImpDet  บAutor  ณPaulo Carnelossi  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao da linha detalhe do relatorio                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ImpDet(aColuna, cTitCab, nNivel)
Local nX

If PcoPrtLim(nLin)
	nLin := 200
	R400Cab(aColuna, aColPos, cTitCab)
EndIf

//impressao da coluna na posicao nNivel
R400TitQuebra(nNivel, aColuna)

//impressao do detalhe  - sempre imprime nNivel + 1 por que nNivel foi impresso acima
For nX := nNivel+1 TO Len(aColuna)
	R400LinImpr(nX, aColuna)
Next	

nLin+=60

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณR400LinImpr  บAutor  ณPaulo Carnelossi  บ Data ณ 15/03/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime conteudo do array aColuna na posicao nCol           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400LinImpr(nCol, aColuna)
Local cSay 		:= Alltrim(Eval(aColuna[nCol][COL_IMPR]))
Local nTamCol 	:= PcoPrtTam(nCol)
Local nTamSay
Local lTrunca := aColuna[nCol][COL_TRUNCA]

If lTrunca
	nTamSay := PcoPrtSize(cSay,2/*nFonte*/)
	
	If nTamCol > 0 .And. nTamSay+3 > nTamCol
	   While nTamSay > nTamCol
	   		cSay 	:= PadR(cSay, Len(cSay)-1)
			nTamSay := PcoPrtSize(cSay,2/*nFonte*/)
	   End
	   cSay += "..."		
	EndIf
EndIf

PcoPrtCell(PcoPrtPos(nCol),nLin,nTamCol,60,cSay,oPrint,1,2,/*RgbColor*/,"",aColuna[nCol][COL_ALIGN])

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณR400TitQuebraบAutor  ณPaulo Carnelossi  บ Data ณ 15/03/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime conteudo do array aColuna na posicao nNivel sempre  บฑฑ
ฑฑบ          ณ na entrada pois servira como titulo ate a proxima quebra   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400TitQuebra(nNivel, aColuna)
Local cChave := ""
Local aAux := aClone(aQuebra[nOrdem][QUEB_LACO])
AEVAL(aAux,;
				{|cX, nX| cChave+=AKD->(Eval(aAux[nX], nX)) } ,  1,  nNivel)

If aTitQueb[nNivel] != cChave
	R400LinImpr(nNivel, aColuna)
	aTitQueb[nNivel] := cChave
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400Cab   บAutor  ณPaulo Carnelossi    บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Cabecalho de acordo com array aColuna que contem as บฑฑ
ฑฑบ          ณdefinicoes das colunas a serem impressas                    บฑฑ
ฑฑบ          ณe array aColPos que contem as posicoes das colunas          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400Cab(aColuna, aColPos, cTitCab)
Local nColIni := 20
Local nX

PcoPrtCab(oPrint)

//se receber vazio popula de acordo com array acoluna
If Empty(aColPos)
	For nX := 1 TO Len(aColuna)
		aAdd(aColPos, nColIni)
		nColIni += aColuna[nX][COL_TAM]
	Next
EndIf

If cTitCab != NIL
	PcoPrtCol({20, 1000})
	PcoPrtCell(PcoPrtPos(2),nLin,,60,cTitCab,oPrint,5,3) 
	nLin+=60
EndIf

PcoPrtCol(aColPos)
//impressao do cabecalho
For nX := 1 TO Len(aColuna)
	PcoPrtCell(PcoPrtPos(nX),nLin,PcoPrtTam(nX),60,aColuna[nX][COL_TIT],oPrint,4,2,/*RgbColor*/,) 
Next	
nLin+=60

Return(aColPos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณR400MontaFiltro บAutor ณPaulo Carnelossi บ Data ณ15/03/2005 บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo que executara os code blocks de filtroบฑฑ
ฑฑบ          ณde acordo a parametrizacao do relatorio                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400MontaFiltro(aExc_MvPar)
Local aMvpar := {}, nPosCol
Local nX, cFiltro, bFilter
Local aExcMvPar := {}

DEFAULT aExc_MvPar := {}

For nX := 1 TO Len(aExc_MvPar)
	aAdd( aExcMvPar, "mv_par"+StrZero(aExc_MvPar[nX], 2) )
Next

For nX := 1 TO LIM_PERG
	aAdd( aMvPar, {"mv_par"+StrZero(nX,2), NIL, NIL})
Next

aMvPar[01][03] := "DTOS(AKD->AKD_DATA)"
aMvPar[02][03] := "DTOS(AKD->AKD_DATA)"
aMvPar[03][03] := "AKD->AKD_CO"
aMvPar[04][03] := "AKD->AKD_CO"
aMvPar[05][03] := "AKD->AKD_CLASSE"
aMvPar[06][03] := "AKD->AKD_CLASSE"
aMvPar[07][03] := "AKD->AKD_OPER"
aMvPar[08][03] := "AKD->AKD_OPER"
aMvPar[09][03] := "AKD->AKD_TPSALD"
aMvPar[10][03] := "AKD->AKD_PROCES"
aMvPar[11][03] := "AKD->AKD_PROCES"

aMvPar[01][02] := " >= "
aMvPar[02][02] := " <= "
aMvPar[03][02] := " >= "
aMvPar[04][02] := " <= "
aMvPar[05][02] := " >= "
aMvPar[06][02] := " <= "
aMvPar[07][02] := " >= "
aMvPar[08][02] := " <= "
aMvPar[09][02] := " == "
aMvPar[10][02] := " >= "
aMvPar[11][02] := " <= "


//agora monta a expressao

cFiltro := "{||"
	cFiltro += "( "
	For nX := 1 TO LIM_PERG
		If Empty(aExcMvPar) .OR. (nPosCol := aScan(aExcMvPar,{|x| AllTrim(lower(x))==AllTrim(lower(aMvPar[nX][1]))})) == 0
			xParam := aMvPar[nX][01]
			xParam := &xParam
			If Valtype(xParam) == "D"   //somente caracter e data
				xParam := DTOS(xParam)
			EndIf	
			cFiltro += "PadR("+aMvPar[nX][03]+", Len("+aMvPar[nX][03] +"))"+aMvPar[nX][02]+"'"+xParam+"'"
			If nX < LIM_PERG
				cFiltro += " .And. "
			EndIf	
		EndIf
	Next
	If Right(cFiltro,7)==" .And. "
		cFiltro := Subs(cFiltro, 1, Len(cFiltro)-7)
	EndIf
	//nao considera os lanctos estornados no relatorio
	cFiltro += " .And. AKD->AKD_STATUS != '3' "
    //fecha o bloco de codigo
    cFiltro += " )"
cFiltro += " }"

//monta o bloco para filtro
bFilter := MontaBlock(cFiltro)

Return(bFilter)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400Chave    บAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo que executa os code blocks das quebrasบฑฑ
ฑฑบ          ณpara utilizacao na condicao do laco (While)                 บฑฑ
ฑฑบ          ณ**Nao utilizado os defines pois e montado via macro substit.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400Chave(aQuebra, nNivel)
Local bChave, cBlock, nX
cBlock := "{||"

For nX := 1 TO Len(aQuebra)
	If nX > nNivel
		Exit
	EndIf
	cBlock += "Eval(aQuebra[nOrdem][2]["+StrZero(nX,2)+"])+"
Next

If Right(cBlock, 1) == "+"
	cBlock := Subs(cBlock, 1, Len(cBlock)-1)+"}
EndIf
	
bChave := MontaBlock(cBlock)

Return bChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400CondLaco บAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta bloco de codigo com condicao do laco (while......End) บฑฑ
ฑฑบ          ณpara os niveis abaixo do primeiro                           บฑฑ
ฑฑบ          ณ**Nao utilizado os defines pois e montado via macro substit.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400CondLaco(aQuebra, nNivel)
Local bCondic, cBlock, nX
cBlock := "{|nNivel|"

For nX := 1 TO Len(aQuebra)
	If nX > nNivel
		Exit
	EndIf
	cBlock += "Eval(aQuebra[nOrdem][2]["+StrZero(nX,2)+"])+"
Next

If Right(cBlock, 1) == "+"
	cBlock := Subs(cBlock, 1, Len(cBlock)-1)+"==aCondRel[nNivel][6]}"
EndIf
	
bCondic := MontaBlock(cBlock)

Return bCondic

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ImpSubTotบAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime subtotal apos a quebra no nivel respectivo          บฑฑ
ฑฑบ          ณde acordo com parametros imprime subtotal nivel 1...4       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ImpSubTot(cTitle, nNivel, nxValor, nColImpr)

If aImprTot[nNivel]
	PcoPrtLine(PcoPrtPos(nNivel), nLin)
	PcoPrtCell(PcoPrtPos(nNivel),nLin,PcoPrtTam(nNivel),60,Alltrim(cTitle)+Space(3)+Replicate(">", nNivel),oPrint,1,2,/*RgbColor*/,"",.F.)
	PcoPrtCell(PcoPrtPos(nColImpr),nLin,PcoPrtTam(nColImpr),60, Transform(nxValor, "@E 999,999,999.99"),oPrint,1,2,/*RgbColor*/,"",.T.)
	nLin+=60

	If nNivel == 1
		PcoPrtLine(PcoPrtPos(nNivel), nLin)
	EndIf
EndIf

aValQueb[nNivel] := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR400ChkQuebraบAutor  ณPaulo Carnelossi บ Data ณ 15/03/2005  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChecka se ha quebra no primeiro nivel e caso exista imprime บฑฑ
ฑฑบ          ณSubTotal                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R400ChkQuebra(nNivel, aColuna)
Local cChave := ""
Local aAux

If nNivel == 1 .And. !Empty(aTitQueb[nNivel])  //para nao checkar na 1a. vez
	
	aAux := aClone(aQuebra[nOrdem][QUEB_LACO])
	
	AEVAL(aAux,;
				{|cX, nX| cChave+=AKD->(Eval(aAux[nX], nX)) } ,  1,  nNivel)
	
	If aTitQueb[nNivel] != cChave
		R400ImpSubTot(aQuebra[nOrdem][QUEB_TITSUB][nNivel], nNivel, aValQueb[nNivel], Len(aColuna))				
    EndIf
    
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  15/03/2005 บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondicao (array contendo blocos de codigos)  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondicao, nNivel, cAlias)
AEVAL(aCondicao,;
				{|cX, nX| (cAlias)->(Eval(aCondicao[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

aCondicao[nNivel][PROC_CARGO] := Eval(aCondicao[nNivel][ANTES_LACO])

While (cAlias)->( ! Eof() .And. AvaliaCondicao(aCondicao, nNivel, cAlias) )

		If .Not. (cAlias)->(Eval(aCondicao[nNivel][PROC_FILTRO], nNivel))
			(cAlias)->(Eval(aCondicao[nNivel][BLOCK_FILTRO], nNivel))			
		Else
			(cAlias)->(Eval(aCondicao[nNivel][PROC_LACO], nNivel))
		
			If nNivel < Len(aCondicao)  // avanca para proximo nivel
				DetalheRel(aCondicao, nNivel+1, cAlias)
			EndIf
		EndIf

End

(cAlias)->(Eval(aCondicao[nNivel][DEPOIS_LACO],nNivel))

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 23/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondicao, nNivel, cAlias)
Local aAux := {}, lCond := .T., lRet := .T., nY

AEVAL(aCondicao,;
				{|cX, nX| aAdd(aAux,lCond:=(cAlias)->(Eval(aCondicao[nX][COND_LACO], nX))) } ,  1,  nNivel) 

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next    

Return(lRet)
