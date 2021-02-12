#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Liquidação de títulos a receber                                                                                                        |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 23/03/2016                                                                                                                       |
| Descricao: Alterar (SOMAR) o prefixo do título conforme a quantidade de cheques de terceiros com o mesmo número                        |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

/*
Estrutura do aCols:
aCols[n][1] = Prefixo do titulo
aCols[n][2] = Tipo
aCols[n][3] = Banco
aCols[n][4] = Agencia
aCols[n][5] = Conta
aCols[n][6] = Numero do Cheque
aCols[n][7] = Data de vencimento do cheque
aCols[n][8] = Nome do emitente
aCols[n][9] = Valor do cheque
aCols[n][10] = Acrescimo
aCols[n][11] = Decrescimo
aCols[n][12] = Valor total dos cheques
*/
//O ponto de entrada FA460CMC7 será utilizado apos a leitura de um cheque pela leitora de documentos, para permitir alterar dados do cheque capturados pela leitora.
//O ponto de entrada receberá em ParamIxb[1], os dados do cheque para manipulação, conforme exemplo abaixo:
User Function FA460CMC7()
Local aArea		:= GetArea()
Local oModelAt	:= FWModelActive()
Local oFO2 		:= ParamIxb[1] // Modelo Ativo -- oModelAt:GetModel('TITGERFO2')
Local cTitulo	:= ""
Local cParcela	:= ""
Local cBanco	:= ""
Local cAgencia	:= ""
Local cConta	:= ""
Local cNumCH	:= ""
Local cPrefixo	:= ""
Local cNumero	:= ""
Local cParcela	:= ""
Local cTipo 	:= ""

cPrefixo	:= oFO2:GetValue("FO2_PREFIX")
cNumero		:= oFO2:GetValue("FO2_NUM")
cParcela	:= oFO2:GetValue("FO2_PARCEL")
cTipo		:= oFO2:GetValue("FO2_TIPO")

cNumero		:= StrZero( (Val(cNumero)), TamSx3("E1_NUM")[1])
//cPrefixo	:= "LIQ" //Processo de liquidacao da Natali
	
If !ValTitK(cPrefixo,cNumero,cParcela,cTipo) //Valida o titulo e caso já exista o titulo, o sistema ajusta o numero da parcela automaticamente
	ValParcK(cPrefixo,cNumero,@cParcela,cTipo) //Valida a parcela
EndIf

//FO0_COND  FO0_TIPO  

oFO2:LoadValue("FO2_PREFIX"	,cPrefixo)
oFO2:LoadValue("FO2_NUM"	,cNumero)
oFO2:LoadValue("FO2_PARCEL"	,cParcela)
//oFO2:LoadValue("FO2_XNUMER"	,SUBSTR( Alltrim(_ACMC7_[Len(_ACMC7_)]),1,TamSx3("EF_CODCHEQ")[1]) )

/* Descontinuado na nova versao P12.
cSql:=" SELECT MAX(E1_NUM) NUMERO "
cSql+=" FROM "+RETSQLNAME('SE1')
cSql+=" WHERE E1_NUM = '"+ aCols[Len(aCols)][6]+"'"
cSql+=" AND E1_TIPO = 'CH' "
cSql+=" AND E1_FILIAL = '"+xFilial('SE1')+"'"
cSql+=" AND D_E_L_E_T_<>'*'"

IF Select('TRE1')<>0
	TRE1->(DbCloseArea())
EndIF

TcQuery cSql New Alias 'TRE1'

//Ajustar na proxima agenda terca-feira
IF !TRE1->(EOF())
	
	If !Empty(cQtd)
		cTitu	:= StrZero(Val( SOMA1(TRE1->NUMERO) ),TamSx3('E1_NUM')[1])
	EndIf
	
ENDIF

//Tabela de TITULOS FO2

//aCols[Len(aCols)][1] 												:= cPref
aCols[Len(aCols)][6] 												:= StrZero( (Val(cTitu)), TamSx3("E1_NUM")[1])
aCols[Len(aCols)][ascan(aHeader,{|x|alltrim(x[2])=="EF_CODCHEQ"})]	:=	_ACMC7_[Len(aCols)]
*/

RestArea(aArea)
Return(oFO2)

//Valida se o titulo já existe no protheus
Static Function ValTitK(cPrefixo,cNumero,cParcela,cTipo)
Local aArea		:= GetArea()
Local cSql		:= ""
Local lOk		:= .T.
Local cAliasL	:= GetNextAlias()

cSql:=" SELECT MAX(E1_NUM) NUMERO "
cSql+=" FROM "+ RetSqlName('SE1')
cSql+=" WHERE E1_FILIAL = '"+xFilial("SE1")+"'
cSql+="	AND E1_NUM = '"+ cNumero +"' "
cSql+=" AND E1_TIPO = '"+cTipo+"' "
cSql+=" AND D_E_L_E_T_ <> '*' "

TcQuery cSql New Alias (cAliasL)

DbSelectArea((cAliasL))
(cAliasL)->(DbGoTop())

If !(cAliasL)->(EOF())
	lOk		:= .F.
EndIf

(cAliasL)->(DbCloseArea())
RestArea(aArea)
Return(lOk)


Static Function ValParcK(cPrefixo,cNumero,cParcela,cTipo)
Local aArea		:= GetArea()
Local cSql		:= ""
Local lOk		:= .T.
Local cAliasL	:= GetNextAlias()

cSql:=" SELECT MAX(E1_PARCELA) PARCELA "
cSql+=" FROM "+ RetSqlName('SE1')
cSql+=" WHERE E1_FILIAL = '"+xFilial("SE1")+"'
cSql+="	AND E1_NUM = '"+ cNumero +"' "
cSql+=" AND E1_TIPO = '"+cTipo+"' "
cSql+=" AND D_E_L_E_T_ <> '*' "

TcQuery cSql New Alias (cAliasL)

DbSelectArea((cAliasL))
(cAliasL)->(DbGoTop())

cParcela := SOMA1((cAliasL)->PARCELA)

(cAliasL)->(DbCloseArea())
RestArea(aArea)
Return()
