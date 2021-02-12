/**----------------------------------------------------------------------------------------------------------------	**/
/** CLIENTE		: KAPAZI  										  	 		           								**/
/** SOLICITANTE	: LUIS PAULO    		              					                                            **/
/** DATA		: 28/01/2020																						**/
/** MODULO		: Compras                         					 		  	 		              				**/
/** FINALIDADE	: Ponto de entrada na criacao do numero de sequencia                       							**/
/** RESPONSAVEL	: RSAC Solucoes                																		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                          DECLARACAO DAS BIBLIOTECAS                                         	**/
/**----------------------------------------------------------------------------------------------------------------	**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

/**----------------------------------------------------------------------------------------------------------------	**/
/**                                           DEFINICAO DE PALAVRAS 	                  							**/
/**----------------------------------------------------------------------------------------------------------------	**/
#Define ENTER CHR(13)+CHR(10)

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: CriaSXE													                                  	**/
/** DESCRICAO		: Altera retorno para criacao de numero de sequencia.      			                  	    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**									  CRIACAO / ALTERACOES / MANUTENCOES               	   			 				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	| Descricao                          				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 28/01/2020 	| Luis Paulo           | Criacao              	| Correcao numeracao de sequencia para reducao do	**/
/**																| tempo na inclusao de pedido de compra				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	   					   		             PARAMETROS     	        	      									**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**----------------------------------------------------------------------------------------------------------------	**/
User function CRIASXE()
// numero de retorno
Local cNum 			:= Nil
Local aArea 		:= GetArea()
Local cAlias    	:= paramixb[1] 	// tabela
Local cCpoSx8   	:= paramixb[2] 	// campo
Local cAliasSx8 	:= paramixb[3]	// alias da tabela sx8
Local nOrdSX8   	:= paramixb[4]	// indice tabela sx8

//Customizado
Local cQuery		:= ""+ENTER // query temporaria
Local cTemp			:= ""  		// alias temporario
Local cZ02			:= "Z02" 	//Trata a tabela de procotolo
Local cSE5			:= "SE5" 	//Trata a tabela de Matriculas
Local cSA2			:= "SA2" 	//Trata a tabela de Fornecedores
Local cSA1			:= "SA1" 	//Trata a tabela de Clientes
Local cSC7			:= "SC7" 	//Trata a tabela de PC
Local cSC2			:= "SC2" 	//Trata a tabela de PC
Local cSC1			:= "SC1" 	//Trata a tabela de PC
Local cSCP			:= "SCP" 	//Trata a tabela de PC
Local cSE4			:= "SE4" 	//Trata a tabela de PC

// colocar os alias que irão permitir a execução do P.E.
If cAlias $ cSA1 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) .And. Alltrim(cCpoSx8) == 'A1_COD'
	cNum := GNextA1N()
	cNum := Soma1(cNum)
EndIf

// colocar os alias que irão permitir a execução do P.E.
If cAlias $ cSA2 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) //.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextFOF() //Busca o ultimo fornecedor
	cNum := Soma1(cNum)
EndIf

// colocar os alias que irão permitir a execução do P.E.
If cAlias $ cSC7 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) .And. cEmpAnt == "04" .And. cFilAnt == "01"//.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextPC() //Busca o pedido de compra
	cNum := Soma1(cNum)
EndIf

// colocar os alias que irão permitir a execução do P.E.
If cAlias $ cSC2 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) .And. cEmpAnt == "04" //.And. cFilAnt == "01"//.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextOP() //Busca a OP
	cNum := Soma1(cNum)
EndIf

If cAlias $ cSC1 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) //.And. cEmpAnt == "04" .And. cFilAnt == "01"//.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextSC() //Busca a solicitacao de compra
	cNum := Soma1(cNum)
EndIf

If cAlias $ cSCP .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) //.And. cEmpAnt == "04" .And. cFilAnt == "01"//.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextSP() 	//Busca a solicitacao ao armazem
	cNum := Soma1(cNum)
EndIf

If cAlias $ cSE4 .and.  ! ( Empty(cAlias) .and. empty(cCpoSx8) .and. empty(cAliasSx8) ) //.And. cEmpAnt == "04" .And. cFilAnt == "01"//.And. Alltrim(cCpoSx8) == 'A2_COD'
	cNum := GNextCND() 	//Busca a solicitacao ao armazem
	cNum := Soma1(cNum)
EndIf

RestArea(aArea)
Return cNum


//Busca o ultimo numero de SC
Static Function GNextCND()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasE4	:= GetNextAlias()		

cSql	+= " SELECT TOP 1 E4_CODIGO AS E4CODIGO
cSql	+= " FROM "+ RetSqlName("SE4") +" WITH(NOLOCK) "
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND E4_CODIGO NOT LIKE '9%'
cSql	+= " AND E4_CODIGO NOT LIKE '8%'
cSql	+= " ORDER BY E4_CODIGO DESC

TcQuery cSql New Alias (cAliasE4)

DbSelectArea((cAliasE4))
(cAliasE4)->(DbGotop())

If !(cAliasE4)->(EOF())
	cRet := (cAliasE4)->E4CODIGO
EndIf

(cAliasE4)->(DbCloseArea())
Return(cRet)

//Busca o ultimo numero de SC
Static Function GNextSP()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasCP	:= GetNextAlias()		

cSql	+= " SELECT TOP 1 CP_NUM AS CPNUM
cSql	+= " FROM "+ RetSqlName("SCP") +" WITH(NOLOCK) " 
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND CP_FILIAL = '"+ xFilial("SCP") +"'"
cSql	+= " AND CP_NUM NOT IN ('201904','6762  ','19580 ')
cSql	+= " AND CP_NUM NOT LIKE 'AL%'
cSql	+= " AND CP_NUM NOT LIKE '98%'
cSql	+= " ORDER BY CP_NUM DESC 

TcQuery cSql New Alias (cAliasCP)

DbSelectArea((cAliasCP))
(cAliasCP)->(DbGotop())

If !(cAliasCP)->(EOF())
	cRet := (cAliasCP)->CPNUM
EndIf

(cAliasCP)->(DbCloseArea())
Return(cRet)


//Busca o ultimo numero de SC
Static Function GNextSC()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasC1	:= GetNextAlias()		

cSql	+= " SELECT TOP 1 C1_NUM AS C1NUM
cSql	+= " FROM "+ RetSqlName("SC1") +" WITH(NOLOCK) " 
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND C1_FILIAL = '"+ xFilial("SC1") +"'"
cSql	+= " AND C1_NUM NOT LIKE 'MC%'
cSql	+= " ORDER BY C1_NUM DESC 

TcQuery cSql New Alias (cAliasC1)

DbSelectArea((cAliasC1))
(cAliasC1)->(DbGotop())

If !(cAliasC1)->(EOF())
	cRet := (cAliasC1)->C1NUM
EndIf

(cAliasC1)->(DbCloseArea())
Return(cRet)


//Busca o ultimo numero do pedido de compra
Static Function GNextOP()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasC2	:= GetNextAlias()		

cSql	+= " SELECT TOP 1 C2_NUM AS C2NUM
cSql	+= " FROM "+ RetSqlName("SC2") +" WITH(NOLOCK) " 
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND C2_FILIAL = '"+ xFilial("SC2") +"'"
cSql	+= " AND (C2_NUM NOT LIKE 'B%' AND C2_NUM NOT LIKE 'A%')
cSql	+= " ORDER BY C2_NUM DESC

TcQuery cSql New Alias (cAliasC2)

DbSelectArea((cAliasC2))
(cAliasC2)->(DbGotop())

If !(cAliasC2)->(EOF())
	cRet := (cAliasC2)->C2NUM
EndIf

(cAliasC2)->(DbCloseArea())
Return(cRet)


//Busca o ultimo numero do pedido de compra
Static Function GNextPC()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasC7	:= GetNextAlias()		

cSql	+= " SELECT TOP 1 C7_NUM AS C7NUM,*
cSql	+= " FROM "+ RetSqlName("SC7") +""
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND C7_FILIAL = '"+ xFilial("SC7") +"'"
cSql	+= " AND C7_NUM NOT IN ('302242')
cSql	+= " ORDER BY C7_NUM DESC

TcQuery cSql New Alias (cAliasC7)

DbSelectArea((cAliasC7))
(cAliasC7)->(DbGotop())

If !(cAliasC7)->(EOF())
	cRet := (cAliasC7)->C7NUM
EndIf

(cAliasC7)->(DbCloseArea())
Return(cRet)


//Busca o ultimo numero do cliente
Static Function GNextA1N()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasA1	:= GetNextAlias()		
		
cSql	+= " SELECT TOP 1 A1_COD AS A1COD
cSql	+= " FROM "+ RetSqlName("SA1") +""
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND A1_FILIAL = '"+ xFilial("SA1") +"'"
cSql	+= " AND A1_COD NOT IN ('999999','99999A')
cSql	+= " ORDER BY R_E_C_N_O_ DESC 


TcQuery cSql New Alias (cAliasA1)

DbSelectArea((cAliasA1))
(cAliasA1)->(DbGotop())

If !(cAliasA1)->(EOF())
	cRet := (cAliasA1)->A1COD
EndIf

(cAliasA1)->(DbCloseArea())
Return(cRet)

//Busca o ultimo numero do Lote correto na SA2
Static Function GNextFOF()
Local cRet		:= "000000"
Local cSql		:= ""
Local cAliasA2	:= GetNextAlias()		
		
cSql	+= " SELECT TOP 1 A2_COD
cSql	+= " FROM SA2010
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= " AND A2_COD NOT IN ('33875 ','UNIAO ','MUNIC ')
cSql	+= " AND A2_COD NOT LIKE ('I000%')
cSql	+= " ORDER BY A2_COD DESC

TcQuery cSql New Alias (cAliasA2)

DbSelectArea((cAliasA2))
(cAliasA2)->(DbGotop())

If !(cAliasA2)->(EOF())
	cRet := (cAliasA2)->A2_COD
EndIf

(cAliasA2)->(DbCloseArea())
Return(cRet)