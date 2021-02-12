/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda                                                                                                              **/
/** Envio de email para representante e cliente                                                                                  **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 15/02/2015| Marcos Sulivan          | Criação da rotina/procedimento.                                                        **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH" 

/**********************************************************************************************************************************/
/** user function KPFINR01()                 cStatus, "cPedido, cCli, cLj)                                                       **/
/**********************************************************************************************************************************/
user function KPFINR01(cPedVend) 

	Local aArea  	:= GetArea()  
	Local cMailVend := ""
	Local cNomeFrom := ""
	Local cMailDest := ""	
	Local cMailVend := ""
	Local cAssunto  := ""
	Local cRepr		:= ""
	Local cMailRep	:= ""
	Local nItem	  	:= 0
	Local nQtd	   	:= 0
	Local nTotal  	:= 0  
	Local nGeral	:= 0 
	Local nJuros	:= 0
	Local cCodVend  := ""
	Local cCodCli   := ""
	Local cCodLoja	:= ""
	local cObser	:= ""
	Local cNomec	:= ""
	Local nN		:= 0 
	Local nCons		:= 0
	Local nCn		:= 0  
	Local cEmail	:= ""
	
	// cria o parametro e obtem o valor de volta
	Local cKPFINR02		:= AllTrim( StaticCall(M521CART,TGetMv,"  ","KA_PFINR02","C","P","KPFINR01 - Ativa novo modelo do email de titulos atrados? D=Desativado,P=Pergunta,A=Ativado" ) )
	
	// novo relatorio desativado
	If cKPFINR02 <> "D"
		// novo relatorio ativado ou ( pergunta ao usuario e o usuario respondeu sim )
		If cKPFINR02 == "A" .or. ( cKPFINR02 == "P" .and. MsgYesNo("Enviar o modelo novo com todos os clientes de um representante em um e-mail?") )
		 	// chama o novo relatorio
			U_KPFINR02()
			// sai da funcao
			Return
		Endif
	Endif
	
	Private cPerg	:= "KPFINR01"
	private cHtml 	:= ""  

	//Faz o processamento das perguntas
	Processa( {|lEnd| ProcSx1()} )
	If !Pergunte(cPerg, .T.)
		Return
	Endif

	//INICIA EXECUCAO DA CONSULTA 
	CDEB()

	//INICIALIZA CONSULTA
	CDEB->(DbGoTop())

	//Faz loop sobre a query
	While (!CDEB->(Eof()))

		//cMailRep
		cMailRep := 'relatorios@kapazi.com.br'
		//Recebe o email do remetente
		cMailVend := "relatorios@kapazi.com.br"

		//Email do remetente
		cNomeFrom := " Relatório Vencidos  "

		//Email de destino
		//cMailDest := "sulivan@rsacsolucoes.com.br"

		//Inicia o processo do workflow
		oWfProc   := TWfProcess():New( "000002", "RELATORIOKAPAZI", NIL )

		//Layout  
		cWfTaskId := oWfProc:NewTask( "RELATORIOKAPAZI", "\workflow\WF.html" )     
		oWfHtml   := oWfProc:oHtml     

		//Dispara o processo para o usuario
		oWfProc:ClientName(cUserName)

		oWfHtml   := oWfProc:oHtml

		// seta as variáveis do processo
		oWfHtml:ValByName("cHtml", cHtml) 

		//Dados do Pedido (Cabeçalho)
		oWfHtml:ValByName("NOMECOM", 	 		SM0->M0_NOMECOM)
		oWfHtml:ValByName("ENDCOB", 			alltrim(SM0->M0_ENDCOB))
		oWfHtml:ValByName("BAIRROCOB", 		alltrim(SM0->M0_BAIRCOB))
		oWfHtml:ValByName("CEPCOB", 			TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999")	)                 
		oWfHtml:ValByName("CIDCOB",				SM0->M0_CIDCOB 	)
		oWfHtml:ValByName("ESTCOB", 			SM0->M0_ESTCOB	)
		oWfHtml:ValByName("CNPJCOB",			TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99" ) 	)
		oWfHtml:ValByName("DTINI", 				mv_par07)      
		oWfHtml:ValByName("DTFIN", 				mv_par08)
		oWfHtml:ValByName("VENDEDOR", 		CDEB->NOME_VEND)
		oWfHtml:ValByName("EMAILVEND", 		CDEB->EMAIL_VEND)
		//CORRIGIDO, ESTAVA ENVIANDO PARA REPRESENTANTE ERRADO.
		cEmail := CDEB->EMAIL_VEND
		oWfHtml:ValByName("CODCLI", 		TRANSFORM(CDEB->CLIENTE +CDEB->LOJA  ,"@R 999999-99"))
		oWfHtml:ValByName("DESCCLI", 		ALLTRIM(CDEB->NOME))                 
		oWfHtml:ValByName("CNPJ",				TRANSFORM(CDEB->CNPJ,"@R 99.999.999/9999-99" ) 	)
		oWfHtml:ValByName("RAZAO", 			ALLTRIM(CDEB->RAZAO)) 
		oWfHtml:ValByName("EMAIL", 			ALLTRIM(CDEB->EMAIL))
		oWfHtml:ValByName("TELEFONE", 	TRANSFORM(CDEB->TELEFONE,"@R 99999-99999" ) 	) 

		cCodVend 	:= CDEB->COD_VEND
		cCodCli 	:= CDEB->CLIENTE 
		cCodLoja	:= CDEB->LOJA
		cNomec		:= CDEB->NOME

		nTotal  	:= 0 
		nJuros		:= 0
		nGeral		:= 0
		nCons  		:= 0
		cObser		:= ''


		While (		(cCodVend = CDEB->COD_VEND) .AND. (cCodCli = CDEB->CLIENTE) .AND. (cCodLoja	= CDEB->LOJA)   )	
			//While (		(cCodVend = CDEB->COD_VEND) )	

			If (	ALLTRIM(CDEB->PREFIXO) <> '10')
				nCn = 1 




				Aadd(oWfHtml:ValByName("IT.TITULO"),		 	ALLTRIM(CDEB->TITULO))
				Aadd(oWfHtml:ValByName("IT.PARCELA"),		 	ALLTRIM(CDEB->PARCELA))
				Aadd(oWfHtml:ValByName("IT.VALOR"),				TRANSFORM(CDEB->VALOR,"@E 999,999,999.99"))
				Aadd(oWfHtml:ValByName("IT.VLDEBITO"),		TRANSFORM(CDEB->SALDO,"@E 999,999,999.99"))
				Aadd(oWfHtml:ValByName("IT.VENC"),				STOD(CDEB->VENCREAL))
				Aadd(oWfHtml:ValByName("IT.DVENC"),				TRANSFORM(CDEB->DIAS_VENC,"@R 99999999"))
				Aadd(oWfHtml:ValByName("IT.OBSER"),		 		ALLTRIM(CDEB->COBRANCA) + ' - ')

				//RETORNA CONSULTA 
				If (ALLTRIM(cObser) == '')   

					If (ALLTRIM(CDEB->CODIGO) <> '-')

						cObser	:= MSMM(CDEB->CODIGO,44) 

					EndIf 

				EndIf                    

			ElseIf(	ALLTRIM(CDEB->PREFIXO) = '10') 

				nCons := nCons + CDEB->SALDO 

				If(nCn <> 1)
					Aadd(oWfHtml:ValByName("IT.TITULO"),		 	"")
					Aadd(oWfHtml:ValByName("IT.PARCELA"),		 	"")
					Aadd(oWfHtml:ValByName("IT.VALOR"),				"")
					Aadd(oWfHtml:ValByName("IT.VLDEBITO"),		"")
					Aadd(oWfHtml:ValByName("IT.VENC"),				"")
					Aadd(oWfHtml:ValByName("IT.DVENC"),				"")
					Aadd(oWfHtml:ValByName("IT.OBSER"),		 		"") 
				EndIf

			EndIf

			If(ALLTRIM(CDEB->PREFIXO) <> '10')

				nTotal  	:= CDEB->SALDO + nTotal  
				nJuros		:= CDEB->JUROS + nJuros  
			EndIf
			//nGeral		:= nTotal + nJuros + nGeral 



			//Próximo Registro
			CDEB->(DbSkip())				

		EndDo


		oWfHtml:ValByName("VLTOTAL", 		TRANSFORM(nTotal,"@E 999,999,999.99"))                 
		oWfHtml:ValByName("TJUROS",			TRANSFORM(nJuros,"@E 999,999,999.99"))
		oWfHtml:ValByName("CONSIG",			TRANSFORM(nCons,"@E 999,999,999.99"))             
		oWfHtml:ValByName("TOTALG",			TRANSFORM((nTotal + nJuros + nCons),"@E 999,999,999.99"))  

		oWfHtml:ValByName("OBSERVACAO",	cObser)

		//Define as propriedades de envio do e-mail

		If (ALLTRIM(mv_par09) <> '')

			oWfProc:cTo := ALLTRIM(mv_par09)

		Else

			oWfProc:cTo       :=  ALLTRIM(cEmail)//ALLTRIM(CDEB->EMAIL_VEND)	 

		EndIf

		//oWfProc:cFromAddr := 	"pv@e-kapazi.com.br"
		oWfProc:cFromAddr := 	GetNewPar('KP_CONTA','no-reply@kapazi.com.br')
		oWfProc:cFromName := 	cNomeFrom  
		oWfProc:cCC       := 	ALLTRIM(mv_par12)
		oWfProc:cSubject  :=  "Relatório Vencidos  " + "  " + ALLTRIM(cNomec)+"  " + DTOC(mv_par07) + " - " + DTOC(mv_par08) 

		oWfProc:bReturn   := Nil  
		nN := nN + 1                 



		oWfProc:Start()

		//Chama o workflow para enviar os e-mails
		WfSendMail() 

		cMailRep := ""


	EndDo

	//Fecha Query
	CDEB->(DbCloseArea()) 

	RestArea(aArea)

Return NIL 

/**********************************************************************************************************************************/
/** user function UPDDTV()                                                                                                      **/
/** CONSULTA DADOS DE COBRANÇA           														**/
/**********************************************************************************************************************************/  

Static Function CDEB()  

	Local aArea	:= GetArea()
	Local cQuery  := ""  

	cQuery := "  SELECT 	SE1.E1_CLIENTE  	CLIENTE
	cQuery += "		,SE1.E1_LOJA            LOJA
	cQuery += "		,SA1.A1_NOME            NOME
	cQuery += "		,SA1.A1_NREDUZ          RAZAO
	cQuery += "		,SE1.E1_NUM             TITULO
	cQuery += "		,SE1.E1_PARCELA         PARCELA
	cQuery += "		,SE1.E1_VENCREA         VENCREAL
	cQuery += "		,SE1.E1_VALOR           VALOR
	cQuery += "		,SE1.E1_SALDO           SALDO
	cQuery += "		,SE1.E1_PORCJUR					JURDIA	
	cQuery += "		,(CONVERT(INT,CONVERT(DATETIME,GETDATE())) - CONVERT(INT,CONVERT(DATETIME,SE1.E1_VENCREA))-1)  DIAS_VENC
	cQuery += "		,((CONVERT(INT,CONVERT(DATETIME,GETDATE())) - CONVERT(INT,CONVERT(DATETIME,SE1.E1_VENCREA))-1) * (SE1.E1_PORCJUR/100)) * ( SE1.E1_VALOR) JUROS
	//cQuery += "		,SE1.E1_XINFO						COBRANCA
	cQuery += "		,ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),E1_XINFOKA)),'') AS COBRANCA						
	cQuery += "		,SA3.A3_COD							COD_VEND
	cQuery += "		,SA3.A3_NOME            NOME_VEND
	cQuery += "		,SA3.A3_EMAIL           EMAIL_VEND
	cQuery += "		,SA3.A3_ENVEMAI	ENVEMAIL
	cQuery += "		,SA1.A1_EMAIL						EMAIL
	cQuery += "		,SA1.A1_CGC							CNPJ 
	cQuery += "		,SA1.A1_TEL 						TELEFONE 
	cQuery += "		,SE1.E1_PREFIXO					PREFIXO 
	cQuery += "		,SE1.E1_TIPO	TIPO


	cQuery += "		,                  ISNULL((
	cQuery += "							SELECT TOP 1 ACF.ACF_CODOBS FROM "+RetSqlName("ACG")+" ACG "	

	cQuery += "					JOIN 	"+RetSqlName("ACF")+" ACF "	
	cQuery += "					ON	ACF.ACF_CODIGO = ACG.ACG_CODIGO
	cQuery += "					AND ACG.D_E_L_E_T_ = ''	 

	cQuery += "							WHERE SE1.E1_NUM = ACG.ACG_TITULO 
	cQuery += "							AND		SE1.E1_PARCELA	= ACG.ACG_PARCEL
	cQuery += "							AND ACG.D_E_L_E_T_ = ''
	cQuery += "							ORDER BY ACG.ACG_CODIGO DESC
	cQuery += "		                  ), '-')
	cQuery += "		                  CODIGO

	cQuery += "		,*

	cQuery += "		FROM	"+RetSqlName("SE1")+" SE1 "	

	cQuery += "		JOIN	"+RetSqlName("SA1")+" SA1 "	
	cQuery += "		ON	SA1.A1_COD = SE1.E1_CLIENTE
	cQuery += "		AND SA1.A1_LOJA = SE1.E1_LOJA
	cQuery += "		AND SE1.E1_FILIAL BETWEEN '"+mv_par05 + "' AND '" + mv_par06 + "'
	cQuery += "		AND SA1.A1_FILIAL BETWEEN '"+mv_par05 + "' AND '" + mv_par06 + "'

	cQuery += "		JOIN	"+RetSqlName("SA3")+" SA3 "	
	cQuery += "		ON	SA3.A3_COD = SE1.E1_VEND1

	cQuery += "		WHERE	SE1.D_E_L_E_T_ = ''
	cQuery += "		AND SE1.E1_FILIAL BETWEEN '"+mv_par05 + "' AND '" + mv_par06 + "'
	cQuery += "		AND SA3.A3_FILIAL BETWEEN '"+mv_par05 + "' AND '" + mv_par06 + "'
	cQuery += "		AND SA1.D_E_L_E_T_ = ''
	cQuery += "		AND SA3.D_E_L_E_T_ = ''
	cQuery += "		AND SE1.E1_SALDO > 0
	cQuery += "		AND E1_VENCREA 	BETWEEN '"+Dtos(mv_par07) + "' AND '" + Dtos(mv_par08) + "'
	cQuery += "		AND	SA1.A1_COD 	BETWEEN '"+mv_par01 + "' AND '" + mv_par03 + "'
	cQuery += "		AND SA1.A1_LOJA BETWEEN '"+mv_par02 + "' AND '" + mv_par04 + "'
	cQuery += "		AND SA3.A3_COD BETWEEN	'"+mv_par10 + "' AND '" + mv_par11 + "'
	cQuery += "  	AND SE1.E1_TIPO <> 'PA' AND SE1.E1_TIPO <> 'RA'    

	cQuery += "  AND SE1.E1_TIPO <> 'NCC'
	cQuery += "  AND SE1.E1_TIPO <> 'CH'

	cQuery += "		ORDER BY  SA3.A3_COD, SA1.A1_COD, SA1.A1_LOJA, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VENCREA

	//Define o alias da query              
	TcQuery cQuery New Alias "CDEB"

	RestArea(aArea)

Return  Nil 

/**------------------------------------------------------------------------------------------------------------------------------**/
/** static function ProcSx1()                                                                                                    **/
/** processa a criação das perguntas no SX1                                                                                      **/
/**------------------------------------------------------------------------------------------------------------------------------**/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**------------------------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**------------------------------------------------------------------------------------------------------------------------------**/
Static Function ProcSx1()

	// array com os parametros
	Local aParPerg := {}


	/* aParPerg[]
	aParPerg[n][01] : nome da pergunta
	aParPerg[n][02] : descrição
	aParPerg[n][03] : tipo
	aParPerg[n][04] : tamanho
	aParPerg[n][05] : decimais
	aParPerg[n][06] : indice de pre selecao de combo
	aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )
	aParPerg[n][08] : rotina de validação do SX1
	aParPerg[n][09] : F3
	aParPerg[n][10] : grupo de perguntas
	aParPerg[n][11] : item 1 do combo
	aParPerg[n][11] : item 2 do combo
	aParPerg[n][11] : item 3 do combo
	aParPerg[n][11] : item 4 do combo
	aParPerg[n][11] : item 5 do combo
	aParPerg[n][12] : array de help
	*/

	//Indice da pergunta
	Local cIndice := "00"

	//Parametro mv_ch
	Local cVarCh := "mv_ch0"

	//Parametro mv_par
	Local cVarPar := "mv_par00"

	//Indice 0
	Local cIdx0 := "0"


	//Cria as perguntas do array 01
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"De Cliente"                           ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_COD")[01]                                         ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SA1"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Do Cliente         "        ,;
	"." }                                      ; // array de help
	}                                             ;
	) 

	//Cria as perguntas do array 03
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"De Loja"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_LOJA")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Da Loja"           ,;
	" " }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 02
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Até Cliente"                               ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_COD")[01]                       ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SA1"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Até Cliente      "         ,;
	"." }            ; // array de help
	}                                             ;
	)


	//Cria as perguntas do array 04
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Até Loja"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_LOJA")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Até Loja"           ,;
	" " }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 09
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"De Filial"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_FILIAL")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SM0"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"De Filial "           ,;
	"" }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 10
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Até Filial"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A1_FILIAL")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SM0"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Até Filial "           ,;
	"" }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 11
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Data Referencia Inicial"                            ,; // descrição
	"D"                                        ,; // tipo
	8                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Data Referencia Inicial "           ,;
	"" }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 12
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Data Referencia Final"                            ,; // descrição
	"D"                                        ,; // tipo
	8                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Data Referencia Final "           ,;
	"" }             ; // array de help
	}                                             ;
	) 

	//Cria as perguntas do array 13
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Email Destino"                            ,; // descrição
	"C"                                        ,; // tipo
	40                    										 ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"email de destino exclusivo. "           ,;
	"(Para Conferencia)" }             ; // array de help
	}                                             ;
	) 



	//Cria as perguntas do array 09
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"De Vendedor"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A3_COD")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SA3"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"De Vendedor "           ,;
	"" }             ; // array de help
	}                                             ;
	)

	//Cria as perguntas do array 10
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Até Vendedor"                            ,; // descrição
	"C"                                        ,; // tipo
	TamSx3("A3_COD")[01]                    ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	"SA3"                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"Até Vendedor "           ,;
	"" }             ; // array de help
	}                                             ;
	)  

	//Cria as perguntas do array 13
	aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
	"Email de Cópia"                            ,; // descrição
	"C"                                        ,; // tipo
	40                    										 ,; // tamanho
	0                                          ,; // decimais
	1                                          ,; // indice de pre seleção (combo)
	"G"                                        ,; // tipo de objeto
	""                                         ,; // rotina de validação do Sx1
	""                                         ,; // F3
	""                                         ,; // grupo de perguntas
	""                                         ,; // item 1 do combo
	""                                         ,; // item 2 do combo
	""                                         ,; // item 3 do combo
	nil                                        ,; // item 4 do combo
	nil                                        ,; // item 5 do combo
	{"'Destinatário de Copia de emails. "           ,;
	"" }             ; // array de help
	}                                             ;
	)

	//Inicializa as variaveis
	cIndice := "00"
	cIdx0 := "0"
	cVarCh := "mv_ch0"
	cVarPar := "mv_par00"

	//Inicializa a barra de progressos                    
	procRegua(len(aParPerg))

	//Loop sobre os parametros a adicionar        
	For nI := 1 to len(aParPerg)

		//Incrementa os contadores
		cIndice := soma1(cIndice)
		cIdx0 := soma1(cIdx0)
		cVarCh := "mv_ch" + cIdx0
		cVarPar := "mv_par" + cIndice

		//Incrementa a barra de progressos
		incProc("Criando perguntas " + allTrim(cIndice) + "/" + strZero(len(aParPerg), 2) + "..." )


		//Adiciona o parametro
		putSX1( aParPerg[nI][01] ,; // nome da pergunta
		cIndice          ,; // indice
		aParPerg[nI][02] ,; // descricao portugues
		aParPerg[nI][02] ,; // descricao espanhol
		aParPerg[nI][02] ,; // descricao ingles
		cVarCh           ,; // variavel mv_ch
		aParPerg[nI][03] ,; // tipo
		aParPerg[nI][04] ,; // tamanho
		aParPerg[nI][05] ,; // decimais
		aParPerg[nI][06] ,; // indice de pre-seleção (combo)
		aParPerg[nI][07] ,; // tipo do objeto
		aParPerg[nI][08] ,; // validação
		aParPerg[nI][09] ,; // F3
		aParPerg[nI][10] ,; // grupo de perguntas
		" "              ,; // parametro pyme
		cVarPar          ,; // variavel mv_par
		aParPerg[nI][11] ,; // item 1 do combo (portugues)
		aParPerg[nI][11] ,; // item 1 do combo (espanhol)
		aParPerg[nI][11] ,; // item 1 do combo (ingles)
		""               ,; // conteudo padrao da pergunta
		aParPerg[nI][12] ,; // item 2 do combo (portugues)
		aParPerg[nI][12] ,; // item 2 do combo (espanhol)
		aParPerg[nI][12] ,; // item 2 do combo (ingles)
		aParPerg[nI][13] ,; // item 3 do combo (portugues)
		aParPerg[nI][13] ,; // item 3 do combo (espanhol)
		aParPerg[nI][13] ,; // item 3 do combo (ingles)
		aParPerg[nI][14] ,; // item 4 do combo (portugues)
		aParPerg[nI][14] ,; // item 4 do combo (espanhol)
		aParPerg[nI][14] ,; // item 4 do combo (ingles)
		aParPerg[nI][15] ,; // item 5 do combo (portugues)
		aParPerg[nI][15] ,; // item 5 do combo (espanhol)
		aParPerg[nI][15] ,; // item 5 do combo (ingles)
		aParPerg[nI][16] ,; // memo de help (portugues)
		aParPerg[nI][16] ,; // memo de help (espanhol)
		aParPerg[nI][16] ,; // memo de help (ingles)
		"" ; // help
		)

	Next nI

Return nil  
