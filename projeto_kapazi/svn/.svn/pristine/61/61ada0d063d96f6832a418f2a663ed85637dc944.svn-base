#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: FINA460A		|	Autor: Luis Paulo							|	Data: 02/04/2018	//
//==================================================================================================//
//	Descrição: Ponto de entrada da rotina FINA460 - LIQUIDACOES										//
//																									//
//==================================================================================================//
User Function FINA460A()
Local aParam	:=	PARAMIXB
Local oObj		:=	aParam[1]     // OBJETO
Local cIdPonto	:=	aParam[2]     // ID DO PONTO DE ENTRADA
Local cIdObj	:=	oObj:GetId()
Local cClasse   :=  oObj:ClassName()
Local nQtdLinhas:= 	0
Local nLinha    := 	0
Local xRet		:=	.T.

/*****NF MISTA ****/
Local oFO2 			:= oObj:GetModel('TITGERFO2')
Local LINCLUI		:= oFO2:GetOperation() == 3 //Insert
Local cParcel		:= ""
Local cParcelN		:= ""
Local cTitulo		:= ""
Local cTipo			:= ""
Local cPrefixo		:= ""
Local oModelAt		:= FWModelActive()
Local nI 			:= 0
Local nX 			:= 0
Local aSaveLines 	:= {}
Local nCount		:= 0

/*****NF MISTA ****/

If cClasse	==	"FWFORMGRID"
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

Do Case
	Case cIdPonto == 'MODELPOS' 
	
	Case cIdPonto == 'FORMLINEPOS'
	
	Case cIdPonto	==	"FORMPOS"
	
	cMsg	:=	'Na validação total do formulário (requer retorno lógico)'+CRLF
	cMsg	+=	'ID: '+cIdObj+CRLF

	If      cClasse == 'FWFORMGRID'
		cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
		cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
	ElseIf cClasse == 'FWFORMFIELD'
		cMsg += 'É um FORMFIELD' + CRLF
	EndIf

	If LINCLUI .And. (IsInCallStack("MATA410") .OR. IsInCallStack("M460FIM")) .And. Alltrim(cIdObj) == "TITGERFO2"	//Inclusao@@
		
			oFO2 			:= oModelAt:GetModel('TITGERFO2')
			
			If nQtdLinhas > 0 .And. ValType(oFO2) != "U"
				
				//Altera as parcelas do pedido6
				aSaveLines 	:= FWSaveRows()
				For nI := 1 To oFO2:Length()
					oFO2:GoLine( nI )
					cParcel	:= oFO2:GetValue("FO2_PARCEL") //cCodigo	:= M->ZP2_CODIGO
					oFO2:LoadValue("FO2_PARCEL",StrZero((nI),2))
				Next
				
			EndIf
			
		ElseIf LINCLUI .And. Alltrim(cIdObj) == "TITGERFO2" //para os da rotina original... onde se verifica as parcelas
			
			oFO2 			:= oModelAt:GetModel('TITGERFO2')
			If nQtdLinhas > 0 .And. ValType(oFO2) != "U"
				//Altera as parcelas do pedido6
				aSaveLines 	:= FWSaveRows()
				For nI := 1 To oFO2:Length()
					oFO2:GoLine( nI )
					cTitulo		:= oFO2:GetValue("FO2_NUM")
					cParcel		:= oFO2:GetValue("FO2_PARCEL") //cCodigo	:= M->ZP2_CODIGO
					cTipo 		:= oFO2:GetValue("FO2_TIPO")
					cPrefixo 	:= oFO2:GetValue("FO2_PREFIX") 
					cParcel 	:= ValidParc(cTitulo,cTipo,cParcel,cPrefixo)
					
					//Verifica se no range de linhas tem algum outro titulo com o mesmo titulo e tb altera a parcela
					oFO2:LoadValue("FO2_PARCEL",cParcel)
										
				Next
				
				For nI := 1 To oFO2:Length()
					oFO2:GoLine( nI )
					
					cParcel := oFO2:GetValue("FO2_PARCEL")
					cTitulo	:= oFO2:GetValue("FO2_NUM")
					
					nCount		:= 0
					
					For nX := (nI + 1) To oFO2:Length()
						
						//Verifica se tem mais um titulo com esse numero
						//caso tenha acrescenta mais +1
						oFO2:GoLine(nX)
						
						If  cTitulo == oFO2:GetValue("FO2_NUM") .And. cParcel == oFO2:GetValue("FO2_PARCEL")
						 	
						 	cParcelN := oFO2:GetValue("FO2_PARCEL")
						 	cParcelN := Soma1(cParcelN)
						 	oFO2:LoadValue("FO2_PARCEL",cParcelN)
						 	
						EndIf
						
					Next
				
				Next
				
			EndIF
	EndIf
	
	
EndCase

Return(xRet)

Static Function XVERCDZP(cCodigo)
Local cQry	:= ""
Local cRet	:= ""

cQry	+= " SELECT MAX(ZP2_CODIGO) AS CODIGO
cQry	+= " FROM ZP2010
//cQry	+= " WHERE D_E_L_E_T_ = ''

If Select('TRBZP2')<>0
	DbSelectArea('TRBZP2')
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'TRBZP2', .F., .T.)

If (Val(cCodigo)) < (Val(TRBZP2->CODIGO))
		cRet	:= ((Val(TRBZP2->CODIGO)) - (Val(cCodigo))+1)
		cRet 	:= StrZero((Val(cCodigo) + cRet),6)
	
	ElseIf Val(cCodigo) == Val(TRBZP2->CODIGO)
		cRet	:= SOMA1(cCodigo)
	
	Else
		cRet	:= cCodigo
EndIf

Return(cRet)

//Valida se tem um numero de fatura na base
Static Function ValidParc(cTitulo,cTipo,cParcel,cPrefixo)
Local cRet		:= "01"
Local cSql		:= ""
Local cAliasFT	
Local nRegs		:= 0

If Select('cAliasFT')<>0
	cAliasFT->(DBSelectArea('cAliasFT'))
	cAliasFT->(DBCloseArea())
Endif

cSql	:= " SELECT E1_NUMLIQ,*
cSql	+= " FROM "+RetSqlName("SE1")+" "
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= "		AND E1_PREFIXO = '"+cPrefixo+"'"
cSql	+= "		AND E1_TIPO = '"+cTipo+"'
cSql	+= "		AND E1_NUM = '"+ (StrZero((Val(cTitulo)),9)) +"'
cSql	+= "		AND E1_FILIAL = '"+xFilial("SE1")+"'
cSql	+= " ORDER BY E1_PARCELA DESC

TcQuery cSql new Alias "cAliasFT"

DbSelectArea("cAliasFT")
cAliasFT->(DbGoTOp())

If !cAliasFT->(EOF())
	cRet := SOMA1(cAliasFT->E1_PARCELA)
EndIf

cAliasFT->(DbCloseArea())
Return(cRet)