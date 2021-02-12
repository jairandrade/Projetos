#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"
//==================================================================================================//
//	Programa: CADSZ3		|	Autor: Luis Paulo							|	Data: 10/02/2020	//
//==================================================================================================//
//	Descrição: PE cadastro de bloqueios 															//
//	-																								//
//==================================================================================================//
User Function CADSZ3P()
Local aParam	:=	PARAMIXB
Local oObj		:=	aParam[1]     // OBJETO
Local cIdPonto	:=	aParam[2]     // ID DO PONTO DE ENTRADA
Local cIdObj	:=	oObj:GetId()
Local cClasse   :=  oObj:ClassName()
Local nQtdLinhas:= 	0
Local nLinha    := 	0
Local xRet		:=	.T.
Private cOpFp	:= ""
Private oSZ3	:= oObj:GetModel('Enchoice_SZ3')
Private lInclui	:= oSZ3:GetOperation() == 3 //Insert
Private lAltera	:= oSZ3:GetOperation() == 4 //Insert
Private lCopia	:= oSZ3:GetOperation() == 9 //Insert

If cClasse	==	"FWFORMGRID"
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

Do Case
	Case	cIdPonto	==	"MODELCOMMITTTS"
		cMsg	:=	'Apos a gravação total do modelo e dentro da transação'+CRLF
		cMsg	+=	'ID: '+cIdObj
		
	Case	cIdPonto	==	"MODELCOMMITNTTS"
		cMsg	:=	'Apos a gravação total do modelo e fora da transação'+CRLF
		cMsg	+=	'ID: '+cIdObj
		
		If lCopia .OR. lInclui .OR. lAltera//Ajusta o Status

		EndIf
	
	Case	cIdPonto	==	"FORMCOMMITTTSPRE"
		cMsg	:=	'Antes da gravação da tabela do formulário'+CRLF
		cMsg	+=	'ID: '+cIdObj
		
	Case	cIdPonto	==	"FORMCOMMITTTSPOS"
		cMsg	:=	'Apos a gravação da tabela do formulário'+CRLF
		cMsg	+=	'ID: '+cIdObj
		
	Case	cIdPonto	==	"MODELPOS"
		cMsg	:=	'Na validação total do modelo (requer retorno lógico)'+CRLF
		cMsg	+=	'ID: '+cIdObj+CRLF
		
        If lCopia .OR. lInclui .OR. lAltera //valida dupli
            If !IncMvApp(oSZ3:GetValue("Z3_CODPROD"),lInclui,lAltera)
                xRet := .f.
                MsgInfo("Este produto ja foi informado!!","Kapazi")
            EndIf
		EndIf
        
EndCase

Return xRet	

//funcao para validar duplicados
Static Function IncMvApp(cProdAtu,lInclui,lAltera)
Local _nSaldo	:= 0
Local _cSeq		:= ""
Local nReco		:= SZ3->(Recno())
Local cQry		:= ""
Local cAliasS3	:= GetNextAlias()
Local lRet      := .t.

cQry	+= " SELECT *
cQry	+= " FROM SZ3010
cQry	+= " WHERE D_E_L_E_T_ = ''
cQry	+= " AND Z3_CODPROD = '"+cProdAtu+"'
If lAltera
	cQry	+= " AND R_E_C_N_O_ <> " + cValTOchar( nReco )
EndIf 

TcQuery cQry New Alias (cAliasS3)

DbSelectArea((cAliasS3))
(cAliasS3)->(DbGoTop())

If !(cAliasS3)->(EOF())
    lRet      := .f.
EndIf

(cAliasS3)->(DbCloseArea())

Return(lRet)

