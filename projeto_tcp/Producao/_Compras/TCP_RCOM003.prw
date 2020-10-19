#INCLUDE "RWMAKE.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
#INCLUDE "FWBROWSE.CH"

/*-------------------------------------------------------------------------------------+
| Projeto ..: Suporte Pontual                                                          |
| Módulo ...: SIGACOM - Compras                                                        |
| Programa .: RCOM003 - Relatório de Prazos de Pedidos                                 |
+--------------------------------------------------------------------------------------+
| Desenvolvimento realizado com base no documento MIT044-REL_PRAZO_PEDIDOS, aprovado   |
| pela TCP para desenvolvimento.                                                       |
+----------+----------------------+----------------------------------------------------+
| Data     | Autor                | Descrição                                          |
+----------+----------------------+----------------------------------------------------+
| 24/10/14 | Lucas Chagas         | Inicio desenvolvimento                             |
+----------+----------------------+----------------------------------------------------+
|          |                      |                                                    |
+----------+----------------------+---------------------------------------------------*/
User Function RCOM003()

Local aArea := GetArea()

Local cPergunta := 'RCOM003'
Local cTitulo   := "Relatório de Prazos de Pedidos de Compras"
Local cDesc     := "Gera relatório em Excel com os prazos dos pedidos de compra."
Local bProcess  := {|oSelf| RCOM0031(oSelf)}
Local oProcess  := Nil

// cria grupo de perguntas
RCOM0030(cPergunta)
Pergunte(cPergunta,.F.)

oProcess := tNewProcess():New(cPergunta,cTitulo,bProcess,cDesc,cPergunta,,.F.,,,.T.,.F.)
if oProcess != nil
	oProcess := FreeObj(oProcess)
endif

RestArea(aArea)

Return

/*----------+--------------+-------+-----------------+------+-------------+
| Função    | RCOM0030     | Autor | Lucas Chagas    | Data | 24/01/2014  |
+-----------+--------------+-------+-----------------+------+-------------+
| Descricao | Cria grupo de perguntas para a rotina.                      |
+-----------+------------------------------------------------------------*/
Static Function RCOM0030(cPerg)

local aTam := {}
aAdd(aTam, TamSx3('C7_NUM' ))
aAdd(aTam, TamSx3('A2_COD' ))
aAdd(aTam, TamSx3('A2_LOJA'))
aAdd(aTam, TamSx3('C1_NUM' ))
aAdd(aTam, TamSx3('C8_NUM' ))
aAdd(aTam, {10,0}           )

//PutSx1(cPerg,"01","Pedido de?"            ,"Pedido de?"            ,"Pedido de?"            ,"mv_ch1","C",aTam[1,1],aTam[1,2],0,"G","","SC7","","","mv_par01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Pedido ate?"           ,"Pedido ate?"           ,"Pedido ate?"           ,"mv_ch2","C",aTam[1,1],aTam[1,2],0,"G","","SC7","","","mv_par02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Fornecedor de?"        ,"Fornecedor de?"        ,"Forneceor de?"         ,"mv_ch3","C",aTam[2,1],aTam[2,2],0,"G","","SA2","","","mv_par03","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Loja de?"              ,"Loja de?"              ,"Loja de?"              ,"mv_ch4","C",aTam[3,1],aTam[3,2],0,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Fornecedor ate?"       ,"Fornecedor ate?"       ,"Forneceor ate?"        ,"mv_ch5","C",aTam[2,1],aTam[2,2],0,"G","","SA2","","","mv_par05","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Loja ate?"             ,"Loja ate?"             ,"Loja ate?"             ,"mv_ch6","C",aTam[3,1],aTam[3,2],0,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"07","Solicitacao de?"       ,"Solicitacao de?"       ,"Solicitacao de?"       ,"mv_ch7","C",aTam[4,1],aTam[4,2],0,"G","","SC1","","","mv_par07","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"08","Solicitacao ate?"      ,"Solicitacao ate?"      ,"Solicitacao ate?"      ,"mv_ch8","C",aTam[4,1],aTam[4,2],0,"G","","SC1","","","mv_par08","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"09","Emissao do Pedido de?" ,"Emissao do Pedido de?" ,"Emissao do Pedido de?" ,"mv_ch9","D",aTam[5,1],aTam[5,2],0,"G","",""   ,"","","mv_par09","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"10","Emissao do Pedido Ate?","Emissao do Pedido ate?","Emissao do Pedido ate?","mv_ch0","D",aTam[5,1],aTam[5,2],0,"G","",""   ,"","","mv_par10","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"11","Salvar em?"            ,"Salvar em?"            ,"Salvar em?"            ,"mv_chA","C",99       ,0        ,0,"G","","HSSDIR"   ,"","","mv_par11","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")

Return

/*----------+--------------+-------+-----------------+------+-------------+
| Função    | RCOM0031     | Autor | Lucas Chagas    | Data | 24/01/2014  |
+-----------+--------------+-------+-----------------+------+-------------+
| Descricao | Processa dados da rotina                                    |
+-----------+------------------------------------------------------------*/
Static Function RCOM0031( oProcess )

Local aDados := {}
Local aLinha := {}
Local cAlias := ''
Local cFile  := ''
Local cFile2 := ''
Local cLinha := ''
Local nArq   := 0
Local nI     := 0
Local nJ     := 0
Local aDados

oProcess:SetRegua1(4)
oProcess:IncRegua1("Pesquisando dados de acordo com parâmetros.")
oProcess:SaveLog("Pesquisando dados de acordo com parâmetros.")
ProcessMessage()

cAlias := RCOM0032()
if (cAlias)->(EOF())
	oProcess:IncRegua1('Dados não encontrados com os parâmetros definidos!')
	oProcess:SaveLog('Dados não encontrados com os parâmetros definidos!')
	ProcessMessage()

	Alert('Dados não encontrados com os parâmetros definidos!')
else
	if Empty(mv_par11)
		oProcess:IncRegua1("Parâmetro 11 (Salvar em?) não definido!")
		oProcess:SaveLog('Parâmetro 11 (Salvar em?) não definido!')
		ProcessMessage()
	else
		if !ExistDir(mv_par11)
			oProcess:IncRegua1("Pasta informada ["+mv_par11+"] não existente!")
			oProcess:SaveLog("Pasta informada ["+mv_par11+"] não existente!")
			ProcessMessage()
		else

			oProcess:IncRegua1("Definindo cabeçalhos...")
			oProcess:SaveLog('Definindo cabeçalhos...')
			ProcessMessage()

			aAdd(aLinha, '# SC'                 )//1
			aAdd(aLinha, 'Item SC'              )//2
			aAdd(aLinha, 'Produto'              )//3
			aAdd(aLinha, 'Descrição'            )//4
			aAdd(aLinha, 'Data SC'              )//5
			aAdd(aLinha, 'Tipo SC'              )//6
			aAdd(aLinha, 'Dias para PC'         )//7
			aAdd(aLinha, 'Valor Unitário'       )//8 
			aAdd(aLinha, 'Valor Total	'       )
			aAdd(aLinha, 'Data de Recebimento'  )
			aAdd(aLinha, 'Qtd Recebida	'       )
			aAdd(aLinha, 'Qtd Aprovada	'       )
			aAdd(aLinha, 'Prazo máximo para PC' )
			aAdd(aLinha, '# Cotação'            )
			aAdd(aLinha, '# PC'                 )
			aAdd(aLinha, 'Item PC'              )
			aAdd(aLinha, 'Data PC'              )
			aAdd(aLinha, 'Data Aprovação'       )
			aAdd(aLinha, 'Data Prevista Entrega')
			aAdd(aLinha, 'Status Entrega'       )
			aAdd(aLinha, 'Cod. Fornecedor'      )
			aAdd(aLinha, 'Nome Fornecedor'      )
			aAdd(aLinha, 'Loja. Fornecedor'     )
			aAdd(aLinha, 'Telefone'             )
			aAdd(aLinha, 'E-Mail Fornecedor'    )
			aAdd(aDados, aLinha)

			oProcess:IncRegua1("Iniciando processamento de dados... parte 1")
			oProcess:SaveLog("Iniciando processamento de dados... parte 1")

			oProcess:SetRegua2(0)
			ProcessMessage()

			cFile2 := Funname() + dToS(dDatabase) + strTran(time(), ':', '') + '.csv'

			cFile := alltrim(mv_par11)
			if (substr(cFile, len(cfile) - 1,1) == '\')
				cFile += Funname() + dToS(dDatabase) + strTran(time(), ':', '') + '.csv'
			else
				cFile += '\' + Funname() + dToS(dDatabase) + strTran(time(), ':', '') + '.csv'
			endif
			nArq := FCreate(cFile)

			if nArq == -1
				oProcess:IncRegua1("Erro ao gerar arquivo!")
				oProcess:SaveLog("Erro ao gerar arquivo!")
				ProcessMessage()
			else
				nI := len(aDados)
				cLinha := ''
				for nj := 1 to len(aDados[nI])
					if !empty(cLinha)
						cLinha += ';'
					endif
					cLinha += aDados[ni,nj]
				next nI
				FWrite(nArq, cLinha + Chr(13) + Chr(10))

				while !(cAlias)->(EOF()) .and. !oProcess:lEnd
					oProcess:IncRegua2("Registro " + (cAlias)->C1_NUM  + " - " + (cAlias)->C1_ITEM + " - " + (cAlias)->B1_COD )
					ProcessMessage()
                    
					aDados := RCOM0035((cAlias)->C7_NUM, (cAlias)->C7_ITEM)

					aLinha := {}
					aAdd(aLinha, (cAlias)->C1_NUM                             )//1
					aAdd(aLinha, (cAlias)->C1_ITEM                            )//2
					aAdd(aLinha, (cAlias)->B1_COD                             )//3
					aAdd(aLinha, (cAlias)->B1_DESC                            )//4
					aAdd(aLinha, dToC(stod((cAlias)->C1_EMISSAO))             )//5
					aAdd(aLinha, (cAlias)->TIPOSC                             )//6
					aAdd(aLinha, cValToChar((cAlias)->DIAS)                   )//7
					aAdd(aLinha, cValToChar((cAlias)->C7_PRECO)               )//Vlr Unitario
					aAdd(aLinha, cValToChar((cAlias)->C7_TOTAL)               )//Vlr Total
					aAdd(aLinha, aDados[1]									  )//Data de Receb
					aAdd(aLinha, cValToChar(aDados[2])					      )//Qtd Receb
					aAdd(aLinha, cValToChar((cAlias)->DIAS)                   )//Qtd Aprovad
					aAdd(aLinha, dToC(stod((cAlias)->C8_DATPRF))              )
					aAdd(aLinha, (cAlias)->C8_NUM                             )
					aAdd(aLinha, (cAlias)->C7_NUM                             )
					aAdd(aLinha, (cAlias)->C7_ITEM                            )
					aAdd(aLinha, dToC(sToD((cAlias)->C7_EMISSAO))             )
					aAdd(aLinha, RCOM0034( (cAlias)->C7_NUM ))
					aAdd(aLinha, dToc(DaySum(cToD(RCOM0034( (cAlias)->C7_NUM )),(cAlias)->C8_PRAZO))              )
					aAdd(aLinha, RCOM0033((cAlias)->C7_NUM, (cAlias)->C7_ITEM, (cAlias)->C7_QUANT, (cAlias)->C7_QUJE))
					aAdd(aLinha, (cAlias)->A2_COD                             )
					aAdd(aLinha, (cAlias)->A2_NOME                            )
					aAdd(aLinha, (cAlias)->A2_LOJA                            )
					aAdd(aLinha, (cAlias)->A2_TEL                             )
					aAdd(aLinha, (cAlias)->A2_EMAIL                           )

					aAdd(aDados, aClone(aLinha))
					oProcess:IncRegua2("Registro " + (cAlias)->C1_NUM  + " - " + (cAlias)->C1_ITEM + " - " + (cAlias)->B1_COD + '. Escrevendo...' )
					ProcessMessage()

					nI := len(aDados)
					cLinha := ''
					for nj := 1 to len(aDados[nI])
						if !empty(cLinha)
							cLinha += ';'
						endif
						cLinha += aDados[ni,nj]
					next nI
					FWrite(nArq, cLinha + Chr(13) + Chr(10))

					(cAlias)->(dbSkip())
				enddo

				FClose(nArq)

				if oProcess:lEnd
					oProcess:IncRegua1("Processo cancelado pelo usuário!")
					oProcess:SaveLog("Processo cancelado pelo usuário!")
					ProcessMessage()

					alert("Processo cancelado pelo usuário!")
					fErase(cFile)
				else
					oProcess:IncRegua1("Arquivo gerado com sucesso!")
					oProcess:SaveLog("Arquivo gerado com sucesso!")
					ProcessMessage()

					ShellExecute('OPEN',cFile,'','', 1 )
				endif
			endif
		endif
	endif
endif

if (select(cAlias) > 0)
	(cAlias)->(dbCloseArea())
endif

oProcess:IncRegua1("Fim do processamento.")
oProcess:SaveLog("Fim do processamento.")
ProcessMessage()

Return

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RCOM0032     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Cria query para busca de Funcionarios.                      !
+-----------+------------------------------------------------------------*/
Static Function RCOM0032()

Local cAlias := getNextAlias()
Local cDataS := dTos(dDatabase)
Local cQuery := ''

cQuery := "SELECT "
cQuery += "	SC1.C1_NUM, SC1.C1_ITEM, SB1.B1_COD, SB1.B1_DESC, SC1.C1_EMISSAO, "
cQuery += "	CASE "
cQuery += "		WHEN SUBSTRING(RTRIM(LTRIM(SB1.B1_COD)), 1, 2) = 'ST' THEN 'SERVICO' "
cQuery += "		WHEN SUBSTRING(RTRIM(LTRIM(SB1.B1_COD)), LEN(RTRIM(LTRIM(SB1.B1_COD))), 1) = 'R' THEN 'SERVICO' "
cQuery += "	ELSE "
cQuery += "		'PRODUTO' "
cQuery += "	END AS TIPOSC, DATEDIFF(D, SC1.C1_EMISSAO, SC8.C8_DATPRF) AS DIAS, "
cQuery += "	SC8.C8_DATPRF, SC8.C8_NUM, SC8.C8_PRAZO, SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_EMISSAO, SC7.C7_PRECO, SC7.C7_TOTAL, "
cQuery += "	SA2.A2_COD, SA2.A2_LOJA, SA2.A2_EMAIL, SA2.A2_NOME, SA2.A2_TEL, SC7.C7_DATPRF, SC7.C7_QUJE, SC7.C7_QUANT "
cQuery += "FROM "
cQuery += "	" + RetSqlName('SC1') + " SC1 "
cQuery += "INNER JOIN " + RetSqlName('SB1') + " SB1 ON "
cQuery += "	SB1.B1_FILIAL = '" +xFilial('SB1')+ "' "
cQuery += "	AND SB1.B1_COD = SC1.C1_PRODUTO "
cQuery += "	AND SB1.D_E_L_E_T_ <> '*' "
cQuery += "INNER JOIN " + RetSqlName('SC8') + " SC8 ON "
cQuery += "	SC8.C8_FILIAL = '" +xFilial('SC8')+ "' "
cQuery += "	AND SC8.C8_NUMSC = SC1.C1_NUM "
cQuery += "	AND SC8.C8_ITEMSC = SC1.C1_ITEM "
cQuery += "	AND (SC8.C8_NUMPED BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' ) "
cQuery += "	AND SC8.D_E_L_E_T_ <> '*' "
cQuery += "INNER JOIN " + RetSqlName('SC7') + " SC7 ON "
cQuery += "	SC7.C7_FILIAL = '" +xFilial('SC7')+ "' "
cQuery += "	AND (SC7.C7_EMISSAO BETWEEN '" + dToS(MV_PAR09) + "' AND '" + dToS(MV_PAR10) + "' ) "
cQuery += "	AND SC7.C7_NUM = SC8.C8_NUMPED "
cQuery += "	AND SC7.C7_ITEM = SC8.C8_ITEMPED "
cQuery += " 	AND ((SC7.C7_FORNECE + SC7.C7_LOJA) BETWEEN '" + (MV_PAR03 + MV_PAR04) + "' AND '" + (MV_PAR05 + MV_PAR06) + "') "
cQuery += "	AND SC7.D_E_L_E_T_ <> '*' "
cQuery += "INNER JOIN " + RetSqlName('SA2') + " SA2 ON "
cQuery += "	SA2.A2_FILIAL = '" + xFilial('SA2') + "' "
cQuery += "	AND SA2.A2_COD = SC7.C7_FORNECE "
cQuery += "	AND SA2.A2_LOJA = SC7.C7_LOJA "
cQuery += "	AND SA2.D_E_L_E_T_ <> '*' "
cQuery += "WHERE "
cQuery += "	SC1.C1_FILIAL = '" +xFilial('SC1')+ "' "
cQuery += "	AND (SC1.C1_NUM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' ) "
cQuery += "	AND SC1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "
cQuery += "	SC1.C1_NUM, SC1.C1_ITEM, SB1.B1_COD"

TCQUERY cQuery New Alias (cAlias)

return cAlias

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RCOM0033     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Busca notas para o item repassado por parametro             !
+-----------+------------------------------------------------------------*/
Static Function RCOM0033( cNum, cItem, nQuant, nEnt )

Local cAlias  := getNextAlias()
Local cStatus := ''
Local cQuery  := ''
Local dData   := dDataBase
Local dQuery  := ctod('//')

cQuery := "SELECT TOP 1"
cQuery += "	SD1.D1_DTDIGIT "
cQuery += "FROM "
cQuery += "	" + RetSqlName('SD1') + " SD1 "
cQuery += "WHERE "
cQuery += "	SD1.D1_FILIAL = '" +xFilial('SD1')+ "' "
cQuery += "	AND SD1.D1_PEDIDO = '" + cNum + "' "
cQuery += "	AND SD1.D1_ITEMPC = '" + cItem + "' "
cQuery += "	AND SD1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "
cQuery += "	SD1.D1_DTDIGIT DESC "

TCQUERY cQuery New Alias (cAlias)

while !(cAlias)->(EOF())
	dQuery := sToD((cAlias)->D1_DTDIGIT)
	(cAlias)->(dbSkip())
enddo

if (select(cAlias) > 0)
	(cAlias)->(dbCloseArea())
endif

do case

	case (dQuery == ctod('//'))
		cStatus := 'DOCUMENTO DE ENTRADA NÃO GERADO'

	case (dData > dQuery)
		do case
			case (nEnt == 0) .and. (nQuant > nEnt)
				cStatus := 'ATRASADO'

			case (nEnt > 0) .and. (nQuant > nEnt)
				cStatus := 'ENTREGA PARCIAL... EM ATRASO'

			case (nEnt > 0) .and. (nQuant == nEnt)
				cStatus := 'ENTREGUE'
		endcase

	case (dData <= dQuery)
		do case
			case (nEnt == 0) .and. (nQuant > nEnt)
				cStatus := 'AGUARDANDO... NO PRAZO'

			case (nEnt > 0) .and. (nQuant > nEnt)
				cStatus := 'ENTREGA PARCIAL... NO PRAZO'

			case (nEnt > 0) .and. (nQuant == nEnt)
				cStatus := 'ENTREGUE'
		endcase
endcase

return cStatus

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RCOM0034     ! Autor ! Lucas Chagas    ! Data !29/10/2013   !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Busca a data da liberacao                                   !
+-----------+------------------------------------------------------------*/
Static Function RCOM0034( cNum )

Local cAlias  := getNextAlias()
Local cQuery  := ''
Local dQuery  := ctod('//')

cQuery := "SELECT TOP 1"
cQuery += "	SCR.CR_DATALIB "
cQuery += "FROM "
cQuery += "	" + RetSqlName('SCR') + " SCR "
cQuery += "WHERE "
cQuery += "	SCR.D_E_L_E_T_ <> '*' "
cQuery += "	AND CAST(SCR.CR_DATALIB AS INT) > 0 "
cQuery += "	AND SCR.CR_TIPO = 'PC' "
cQuery += "	AND SCR.CR_LIBAPRO <> '" + space(tamSx3('CR_LIBAPRO')[1]) + "' "
cQuery += "	AND SCR.CR_NUM = '" + cNum + "' "
cQuery += "	AND SCR.CR_FILIAL = '" +xFilial('SCR')+ "' "
cQuery += "ORDER BY "
cQuery += "	SCR.CR_DATALIB DESC

TCQUERY cQuery New Alias (cAlias)

while !(cAlias)->(EOF())
	dQuery := sToD((cAlias)->CR_DATALIB)
	(cAlias)->(dbSkip())
enddo

if (select(cAlias) > 0)
	(cAlias)->(dbCloseArea())
endif

return dToc(dQuery)

/*----------+--------------+-------+-----------------+------+-------------+
! Função    ! RCOM0035     ! Autor ! Guilherme Nichetti Data !14/04/2014  !
+-----------+--------------+-------+-----------------+------+-------------+
! Descricao ! Busca notas para o item repassado por parametro             !
+-----------+------------------------------------------------------------*/
Static Function RCOM0035( cNum, cItem )

Local cAlias  := getNextAlias()
Local cStatus := ''
Local cQuery  := ''
Local dData   := dDataBase
Local aRet  := {}

cQuery := "SELECT TOP 1"
cQuery += "	SD1.D1_EMISSAO, SD1.D1_QUANT "
cQuery += "FROM "
cQuery += "	" + RetSqlName('SD1') + " SD1 "
cQuery += "WHERE "
cQuery += "	SD1.D1_FILIAL = '" +xFilial('SD1')+ "' "
cQuery += "	AND SD1.D1_PEDIDO = '" + cNum + "' "
cQuery += "	AND SD1.D1_ITEMPC = '" + cItem + "' "
cQuery += "	AND SD1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY "
cQuery += "	SD1.D1_EMISSAO DESC "

TCQUERY cQuery New Alias (cAlias)

while !(cAlias)->(EOF())
		aAdd(aRet, (cAlias)->D1_EMISSAO)
		aAdd(aRet, (cAlias)->D1_QUANT)
	(cAlias)->(dbSkip())
enddo

if (select(cAlias) > 0)
	(cAlias)->(dbCloseArea())
endif

return aRet