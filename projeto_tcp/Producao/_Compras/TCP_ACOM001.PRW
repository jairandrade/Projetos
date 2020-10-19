#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Customização                                            |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | ACOM001                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | Rotina para varredura de títulos da empresa 03 para a 02|
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                   			 |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 19/06/2013                                              |
+------------------+----------------------------------+-------------+--------+
| Alterações                                          | Responsavel | Data   |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+-------*/
User Function ACOM001()

Local aArea := GetArea()
Local lOk   := .F.
Local oTela := Nil	
Local cMsg  := 'Rotina para buscar a partir da Empresa 03, os clientes na Empresa 02 e atualizar os dados financeiros deste cliente.'

RPCSetType(3)
RpcSetEnv( "03", "01",,, "COM", "ACOM001",,,,,)
ACOM0010()
RPCClearEnv()

RestArea(aArea)

Return

/*--------------------------+---------------------------+----------------------+
| Rotina: ACOM0010          | Autor: Lucas J. C. Chagas | Data: 19/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Rotina de processamento dos registros.                            |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ACOM0010()

Local aArea     := GetArea()
Local aDados    := {}
Local bError    := Nil
Local cAlias    := getNextAlias()
Local cAlias2   := getNextAlias()
Local cData     := ''
Local cError    := ''                 
Local cHora     := ''
Local cArquivo  := ''
Local cCodigo   := ''
Local cComando  := ''
Local cComando2 := ''
Local cLog      := ''
Local cLog2     := ''
Local cLoja     := ''
Local cQry      := ''
Local lFind     := .F.  
Local lQtde     := .F.
Local oError    := Nil  

//Conout('Inicio - ' + time())
//Conout("ACOM0010")
//Conout("Verificando pasta de Logs")
if !ExistDir('\logsTcp')
	MakeDir('\logsTcp')
endif

// vai buscar os campos para a macrosubstituição

cLog2 += "" + CRLF
cLog2 += "-----------------------------------------------------------" + CRLF
cLog2 += "- Fornecedores --------------------------------------------" + CRLF
cLog2 += "-----------------------------------------------------------" + CRLF

cQry := "SELECT * FROM SA2030 WHERE D_E_L_E_T_ <> '*' and A2_CGC <> '" + Space(TamSx3('A2_CGC')[1]) + "'"
cAlias := GetNextAlias()
TcQuery cQry New Alias (cAlias)

while !(cAlias)->(EOF())

	cQry := "SELECT count(*) as MAISDEUM FROM SA2020 WHERE D_E_L_E_T_ <> '*' AND A2_CGC = '" +(cAlias)->A2_CGC+ "'"
	TcQuery cQry New Alias (cAlias2)
	lQtde := .F.	
	while !(cAlias2)->(EOF()) .AND. lQtde == .F.
		lQtde := (cAlias2)->MAISDEUM > 1
		(cAlias2)->(dbSkip())
	enddo                               
	(cAlias2)->(dbCloseArea())
	
	if lQtde
		cLog2 += chr(10) + chr(13) + "O CNPJ '"+(cAlias)->A2_CGC+"' possui mais de um registro e não será importado." + CRLF
	else
		// verifica na empresa '02' se existe registro com aquele cgc
		lFind := .F.
		cQry := "SELECT * FROM SA2020 WHERE D_E_L_E_T_ <> '*' AND A2_CGC = '" +(cAlias)->A2_CGC+ "'"
		TcQuery cQry New Alias (cAlias2)	
		while !(cAlias2)->(EOF()) .and. (lFind == .f.)
			lFind := .T.		
			cLog2 += ACOM0014( {(cAlias)->A2_COD, (cAlias)->A2_LOJA}, {(cAlias2)->A2_COD, (cAlias2)->A2_LOJA} ) + CRLF		
			(cAlias2)->(dbSkip())
		enddo
		
		if !lFind
			cLog2 += ACOM0015( cAlias, {(cAlias)->A2_COD, (cAlias)->A2_LOJA} )		
		endif
		
		dbCloseArea(cAlias2)
	endif
	(cAlias)->(dbSkip())
enddo
dbCloseArea(cAlias)

cLog     := ''
cHora    := Time()
cData    := DtoC(Date())
cArquivo := '\logsTcp\ACOM001_' + DtoS(Date()) + StrTran(cHora, ':', '') + '.log'
	
//Adiciona informações ao arquivo
cLog += "-----------------------------------------------------------" + CRLF
cLog += "- Log de Importação ---------------------------------------" + CRLF
cLog += "-----------------------------------------------------------" + CRLF
cLog += " Data...............: " + cData    + CRLF
cLog += " Hora...............: " + cHora    + CRLF
cLog += "-----------------------------------------------------------" + CRLF
cLog += cLog2
		
MemoWrite ( cArquivo, cLog ) 
//Conout('FIM - ' + time())

RestArea(aArea)

//oTela:End()

Return

/*--------------------------+---------------------------+----------------------+
| Rotina: ACOM0011          | Autor: Lucas J. C. Chagas | Data: 19/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Realiza updates na Empresa 3, repassando os dados da Empresa 02   |
+------------------------------------------------------------------------------+
| Parâmetros: aDados02 ---> contém codigo e loja da empresa 02                 |
|             aDados03 ---> contém codigo e loja da empresa 03                 |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ACOM0011( aOrigem, aDestino )

Local aArea     := getArea()
Local cTabela   := ''
Local cNewAlias := ''
Local cQry      := ''
Local cLog      := CRLF

//Conout("ACOM0011")

cLog += "Cliente Destino....: " + aDestino[1] + CRLF
cLog += "Loja Destino.......: " + aDestino[2] + CRLF
cLog += "Cliente Origem.....: " + aOrigem[1] + CRLF
cLog += "Loja Origem........: " + aOrigem[2] + CRLF

cQry := "UPDATE SE1030 SET E1_CLIENTE = '" + aDestino[1] + "', E1_LOJA = '" + aDestino[2] + "' "
cQry += "WHERE E1_CLIENTE = '" + aOrigem[1] + "' AND E1_LOJA = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SE1030: "  + TCSQLError() + CRLF
else
	cLog += "Contas a Receber atualizadas com sucesso." + CRLF
EndIf			

cQry := "UPDATE SEF030 SET EF_CLIENTE = '" + aDestino[1] + "', EF_LOJACLI = '" + aDestino[2] + "' "
cQry += "WHERE EF_CLIENTE = '" + aOrigem[1] + "' AND EF_LOJACLI = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SEF030: "  + TCSQLError() + CRLF
else
	cLog += "Cheques atualizados com sucesso." + CRLF
EndIf			

cQry := "UPDATE SE5030 SET E5_CLIFOR = '" + aDestino[1] + "' ,E5_CLIENTE = '" + aDestino[1] + "', E5_LOJA = '" + aDestino[2] + "' "
cQry += "WHERE E5_CLIFOR = '" + aOrigem[1] + "' AND E5_CLIENTE = '" + aOrigem[1] + "' AND E5_LOJA = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SE5030: "  + TCSQLError() + CRLF
else
	cLog += "Movimentos Bancários atualizados com sucesso." + CRLF
EndIf			

RestArea(aArea)

Return cLog

/*--------------------------+---------------------------+----------------------+
| Rotina: ACOM0013          | Autor: Lucas J. C. Chagas | Data: 19/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Cria novo registro de clientes via execauto                       |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ACOM0013( cAlias, aOrigem )

Local aArea     := getArea()
Local aTemp     := (cAlias)->(dbStruct())
Local aDados    := {}
Local cTabela   := ''
Local cComando  := ''
Local cComando2 := ''
Local cQry      := ''
Local cLog      := ''
Local nI        := 0

Private lMsErroAuto := .F.

//Conout("ACOM0013")

ProcessMessage()

dbSelectArea('SA1')
SA1->(dbSetOrder(1))

// auto numeração
cCodigo := GetSx8Num('SA1','A1_COD')
ConfirmSX8()

while ExistNum( cCodigo, '01' ) == .F.
	cCodigo := GetSx8Num('SA1','A1_COD')
	ConfirmSX8()
enddo

aAdd(aDados, {'A1_FILIAL', xFilial('SA1'), NIL})
aAdd(aDados, {'A1_COD'   , cCodigo       , NIL})

for nI := 1 to len(aTemp)
	if (aTemp[nI,1] != 'A1_FILIAL' .AND. !(aTemp[nI,1] == 'A1_COD') .AND. substr(aTemp[nI,1],1,2) == 'A1')	
		cComando := cAlias + '->' + aTemp[nI,1]
		if ( FieldPos(aTemp[nI,1]) > 0 ) .AND. X3Uso(GetSx3Cache(aTemp[nI,1],"X3_USADO"))
			if (GetSx3Cache(aTemp[nI,1],"X3_TIPO") == 'D')
				aAdd(aDados, {aTemp[nI,1], cToD(&(cComando)), NIL})
			else			
				aAdd(aDados, {aTemp[nI,1], &(cComando), NIL})
			endif
		endif
		ProcessMessage()
	endif
next nI

msExecAuto( { |x,y| MATA030(x,y) }, aDados, 3 )
if lMsErroAuto
	cHora := Time()
	cData := DtoC(Date())
	cArquivo := 'cliente_' + DtoS(Date()) + StrTran(cHora, ':', '') + '.erro'

	//Adiciona informações da nota ao arquivo
	AutoGrLog( "Data..........: " + cData             )
	AutoGrLog( "Hora..........: " + cHora             )
	AutoGrLog( "Opcao.........: 3"                    )
	AutoGrLog( "Codigo Origem.: " + (cAlias)->A1_COD  )
	AutoGrLog( "Loja Origem...: " + (cAlias)->A1_LOJA )
	AutoGrLog( '' )		

	MostraErro( '\logsTcp', cArquivo )
	cLog += MemoRead( "\logsTcp\" + cArquivo ) + CRLF
else
	cLog += 'Cliente ' + (cAlias)->A1_CGC + ' cadastrado com sucesso.' + CRLF
	cLog += ACOM0011( aOrigem, {cCodigo, (cAlias)->A1_LOJA} ) + CRLF
endif

RestArea(aArea)

Return cLog

/*--------------------------+---------------------------+----------------------+
| Rotina: ACOM0014          | Autor: Lucas J. C. Chagas | Data: 19/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Realiza updates na Empresa 3, repassando os dados da Empresa 02   |
+------------------------------------------------------------------------------+
| Parâmetros: aDados02 ---> contém codigo e loja da empresa 02                 |
|             aDados03 ---> contém codigo e loja da empresa 03                 |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ACOM0014( aOrigem, aDestino )

Local aArea     := getArea()
Local cTabela   := ''
Local cNewAlias := ''
Local cQry      := ''
Local cLog      := CRLF

//Conout('ACOM0014')

cLog += "Fornecedor Destino.: " + aDestino[1] + CRLF
cLog += "Loja Destino.......: " + aDestino[2] + CRLF
cLog += "Fornecedor Origem..: " + aOrigem[1] + CRLF
cLog += "Loja Origem........: " + aOrigem[2] + CRLF

cQry := "UPDATE SE2030 SET E2_FORNECE = '" + aDestino[1] + "', E2_LOJA = '" + aDestino[2] + "' "
cQry += "WHERE E2_FORNECE = '" + aOrigem[1] + "' AND E2_LOJA = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SE2030: "  + TCSQLError() + CRLF
else
	cLog += "Contas a Pagar atualizadas com sucesso." + CRLF
EndIf			

cQry := "UPDATE SEF030 SET EF_FORNECE = '" + aDestino[1] + "', EF_LOJA = '" + aDestino[2] + "' "
cQry += "WHERE EF_FORNECE = '" + aOrigem[1] + "' AND EF_LOJA = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SEF030: "  + TCSQLError() + CRLF
else
	cLog += "Cheques atualizados com sucesso." + CRLF
EndIf			

cQry := "UPDATE SE5030 SET E5_CLIFOR = '" + aDestino[1] + "', E5_FORNECE = '" + aDestino[1] + "', E5_LOJA = '" + aDestino[2] + "' "
cQry += "WHERE E5_CLIFOR = '" + aOrigem[1] + "' AND E5_FORNECE = '" + aOrigem[1] + "' AND E5_LOJA = '" + aOrigem[2] + "' AND D_E_L_E_T_ <> '*'"

If (tcSqlExec(cQry) < 0)	
	cLog += "Erro para atualizar a tabela SE5030: "  + TCSQLError() + CRLF
else
	cLog += "Movimentos Bancarios atualizados com sucesso." + CRLF
EndIf			

RestArea(aArea)

Return cLog

/*--------------------------+---------------------------+----------------------+
| Rotina: ACOM0015          | Autor: Lucas J. C. Chagas | Data: 19/06/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Cria novo registro de clientes via execauto                       |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ACOM0015( cAlias, aOrigem )

Local aArea     := getArea()
Local aDados    := {}
Local aTemp     := (cAlias)->(dbStruct())
Local cTabela   := ''
Local cComando  := ''
Local cComando2 := ''
Local cQry      := ''
Local cLog      := ''
Local nI        := 0

Private lMsErroAuto := .F.

ProcessMessage()

dbSelectArea('SA2')
SA2->(dbSetOrder(1))

// auto numeração
cCodigo := GetSx8Num('SA2','A2_COD')
ConfirmSX8()

while ExistNum2( cCodigo, '01' ) == .F.
	cCodigo := GetSx8Num('SA2','A2_COD')
	ConfirmSX8()	
enddo

aAdd(aDados, {'A2_FILIAL', xFilial('SA2'), NIL})
aAdd(aDados, {'A2_COD'   , cCodigo       , NIL})

for nI := 1 to len(aTemp)
	if (aTemp[nI,1] <> 'A2_FILIAL' .AND. !(aTemp[nI,1] == 'A2_COD') .AND. substr(aTemp[nI,1],1,2) == 'A2')	
		cComando := cAlias + '->' + aTemp[nI,1]
		
		//SX3->(dbGoTop())
		if ( FieldPos(aTemp[nI,1]) > 0 ) .AND. X3Uso(GetSx3Cache(aTemp[nI,1],"X3_USADO"))
			if (GetSx3Cache(aTemp[nI,1],"X3_TIPO") == 'D')
				aAdd(aDados, {aTemp[nI,1], cToD(&(cComando)), NIL})
			else			
				aAdd(aDados, {aTemp[nI,1], &(cComando), iif(aTemp[nI,1] == 'A2_MJURIDI' .OR. aTemp[nI,1] == 'A2_CGC', .F., Nil)})
			endif
		endif
		ProcessMessage()
	endif
next nI

msExecAuto( { |x,y| MATA020(x,y) }, aDados,3 )
if lMsErroAuto
	cHora := Time()
	cData := DtoC(Date())
	cArquivo := 'fornece_' + DtoS(Date()) + StrTran(cHora, ':', '') + '.erro'

	//Adiciona informações da nota ao arquivo
	AutoGrLog( "Data..............: " + cData             )
	AutoGrLog( "Hora..............: " + cHora             )
	AutoGrLog( "Opcao.............: 3"                    )
	AutoGrLog( "Fornecedor Origem.: " + (cAlias)->A2_COD  )
	AutoGrLog( "Loja Origem.......: " + (cAlias)->A2_LOJA )
	AutoGrLog( '' )		

	MostraErro( '\logsTcp', cArquivo )
	cLog += MemoRead( "\logsTcp\" + cArquivo ) + CRLF
else
	cLog += 'Fornecedor ' + (cAlias)->A2_CGC + ' cadastrado com sucesso.' + CRLF
	cLog += ACOM0014( aOrigem, {cCodigo, (cAlias)->A2_LOJA} )
endif

RestArea(aArea)

Return cLog

/*--------------------------+---------------------------+----------------------+
| Rotina: ExistNum          | Autor: Lucas J. C. Chagas | Data: 30/08/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Valida codigo e loja para o novo cliente                          |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ExistNum( cCodigo, cLoja )

Local cAlias := getNextAliaS()
Local cQry := "SELECT count(*) as CLI FROM SA1020 WHERE A1_COD = '" +cCodigo+ "' AND A1_LOJA = '" +cLoja+ "' AND D_E_L_E_T_ <> '*'"
Local lRet := .F.

TcQuery cQry New Alias (cAlias)
while !(cAlias)->(EOF())
	lRet := (cAlias)->CLI == 0
	(cAlias)->(dbSkip())
enddo
(cAlias)->(dbCloseArea())

return lRet

/*--------------------------+---------------------------+----------------------+
| Rotina: ExistNum2         | Autor: Lucas J. C. Chagas | Data: 30/08/2013     |
+---------------------------+---------------------------+----------------------+
| Descrição: Valida codigo e loja para o novo fornecedor                       |
+-------------------------------------------------------+-------------+--------+
| Alterações                                            | Responsavel | Data   |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+--------+
|                                                       |             |        |
|                                                       |             |        |
+-------------------------------------------------------+-------------+-------*/
Static Function ExistNum2( cCodigo, cLoja )

Local cAlias := getNextAliaS()
Local cQry := "SELECT count(*) as FORN FROM SA2020 WHERE A2_COD = '" +cCodigo+ "' AND A2_LOJA = '" +cLoja+ "' AND D_E_L_E_T_ <> '*'"
Local lRet := .F.

TcQuery cQry New Alias (cAlias)
while !(cAlias)->(EOF())
	lRet := (cAlias)->FORN == 0
	(cAlias)->(dbSkip())
enddo
(cAlias)->(dbCloseArea())

return lRet