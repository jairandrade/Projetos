#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Rotina                                                  |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_MCOM007.PRW                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Rotina disparada a partir da tela do MATA150 para cance-|
|                  | lamento de cotacao.                                     |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 29/05/2013                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|                                           |           |           |        |
|                                           |           |           |        |
+-------------------------------------------+-----------+-----------+-------*/
User Function MCOM007()

Local aArea   := GetArea()
Local aPergs  := {}
Local aRet    := {}
Local cTitulo := 'Motivo' 
Local cMsg    := ''
Local cSubTit := ''
Local nI
Local nRecNo  := SC8->(Recno())
lOCAL _cCodUsr := RetCodUsr()
Private aEmails := {}
Private cMotivo := Space(TamSx3('C8_MOTCAN')[1])
Private cC8Num  := Space(TamSx3('C8_NUM'   )[1])

aAdd( aPergs, {11,'Motivo do cancelamento'   , cMotivo,".T.",".T.",.T.})
aAdd( aPergs, {1 ,'Cotacao para Cancelamento', cC8Num , PESQPICT('SC8','C8_NUM'), '.T.', , '.T.', TamSx3('C8_NUM')[1], .T.})

if ParamBox (aPergs,cTitulo,aRet,,,,,,,,.F.,.F.)
	cC8Num := aRet[2]
	SC8->(dbGoTop())
	
	if (SC8->(dbSeek(xFilial('SC8') + cC8Num)))
		if (!Empty(SC8->C8_MOTCAN) .AND. !Empty(SC8->C8_USUCAN) .AND. !Empty(SC8->C8_DTCANC))
			Aviso( 'Cancelamento de Cotações', 'A cotação selecionada já esta cancelada.', { "Ok" }, 2, 'Cotação já cancelada', 1, , .F.)
		else
 			while !SC8->(EOF()) .AND. SC8->C8_NUM == cC8Num
 				RecLock('SC8',.F.)
					SC8->C8_DTCANC := dDataBase
					SC8->C8_MOTCAN := aRet[1]
					SC8->C8_USUCAN := _cCodUsr
				SC8->(dbUnlock())
				MCOM007A( aRet[1] )			
				
				SC8->(dbSkip())
			enddo
		endif
	endif
	
endif  

// vai tentar enviar os emails para os respectivos fornecedores da cotacao
if len(aEmails) > 0
	aRet := U_MCOM002(aClone(aEmails))
	
	// verifica o retorno da informação
	if len(aRet) > 0
		cMsg := ''
		for nI := 1 to len(aRet)
			if !aRet[nI,1]
				cMsg += 'E-mail para o fornecedor ' + aRet[nI,2] + ' não enviado. Observações: ' + CRLF
				cMsg += aRet[nI,3] + CRLF
			endif
		next nI
		
		if !Empty(cMsg)
			cSubTit := 'E-mails não enviados'		
			Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
		endif
	endif                                          
endif

SC8->(dbGoTo(nRecNo))

RestArea(aArea)

Return

/*--------------------------+----------------------------+--------------------+
| Função: MCOM007A          | Autor: Lucas J. C. Chagas  | Data: 30/05/2013   |
+------------+--------------+----------------------------+--------------------+
| Parâmetros | cMotCan - Motivo do Cancelamento.                              |
+------------+----------------------------------------------------------------+
| Descricao  | Envia e-mail informando o cancelamento da cotação              |
+------------+---------------------------------------------------------------*/
Static Function MCOM007A( cMotCan )

Local aArea    := GetArea()
Local cHtml    := ''
Local cTitulo  := 'Workflow - Geração de E-mail de Envio'
Local cSubTit  := ''
Local cMsg     := ''
Local lRet     := ''
Local cId      := ''
Local cAssunto := ''

dbSelectArea('SA2')
SA2->(dbSetOrder(1))

dbSelectArea('SC1')
SC1->(dbSetOrder(1))
     
if !SA2->(dbSeek(xfilial('SA2') + SC8->C8_FORNECE + SC8->C8_LOJA))
	cSubTit := 'Fornecedor da cotação não encontrado!'
	cMsg    := "Fornecedor da cotação não encontrado com os dados de código e loja repassados ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "')."
	Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
else
	if Empty(SA2->A2_EMAIL)
		cSubTit := 'E-mail do fornecedor não cadastrado na base de dados!'
		cMsg    := "O campo e-mail para o fornecedor ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "') não foi cadastrado."
		Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
	else	                          		
		cHtml := MCOM007B( SA2->A2_EST != 'EX', cMotCan )
					
		cMail := SA2->A2_EMAIL
		cCc	  := ""
		if (SA2->A2_EST != 'EX')
			cAssunto := "Cancelamento de Cotação de Produtos - " + SM0->M0_NOME
		else
			cAssunto := "Cancellation of Listing of Products - " + SM0->M0_NOME
		endif

		aAdd(aEmails,{cMail, cCc, cAssunto, cHtml, SC8->C8_FORNECE + SC8->C8_LOJA})
	endif
endif

RestArea(aArea)

return

/*----------+-----------+-------+--------------------+------+----------------+
! Método    ! MCOM007B  ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013    !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Monta corpo do e-mail                                          !
+-----------+---------------------------------------------------------------*/
Static Function MCOM007B( lNacional, cMotCan )

Local aArea := GetArea()
Local cHtml := ''

cHtml := '<html>' + CRLF
cHtml += '	<head>' + CRLF 
cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' + CRLF 
cHtml += '		<title>Solicitação de Cotação</title>' + CRLF 
cHtml += '		<style type="text/css">' + CRLF 
cHtml += '			.Arial {' + CRLF 
cHtml += '				font-family: Arial, Helvetica, sans-serif;' + CRLF 
cHtml += '				font-size: 20px;' + CRLF 
cHtml += '			}' + CRLF 
cHtml += '		</style>' + CRLF 
cHtml += '	</head>' + CRLF 
cHtml += '         ' + CRLF 
cHtml += '	<body>' + CRLF

if (lNacional)
	cHtml += '		<p>A cotação n.º ' + AllTrim(SC8->C8_NUM) + ' foi cancelada pelos seguintes motivos:</p>' + CRLF
	cHtml += '		<p>' + cMotCan + '</p>' + CRLF
	cHtml += '		<p></p>' + CRLF						
	cHtml += '		<p>Ps.: E-mail automático. Favor não responder.</p>' + CRLF
else
	cHtml += '		<p>The quotation n. º ' + AllTrim(SC8->C8_NUM) + ' was canceled for the following reasons:</p>' + CRLF
	cHtml += '		<p>' + cMotCan + '</p>' + CRLF
	cHtml += '		<p></p>' + CRLF
	cHtml += '		<p>Ps.: E-mail automatically. Please do not reply.</p>' + CRLF
							
endif
cHtml += '	</body>' + CRLF 
cHtml += '</html>' + CRLF 

RestArea(aArea)

Return cHtml