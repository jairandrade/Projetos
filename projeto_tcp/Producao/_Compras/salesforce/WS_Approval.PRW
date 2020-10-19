#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"



//------------------------------------------------------------------------------
/*/{Protheus.doc} wsApproval

Classe responsável por retornar uma Listagem de Documentos para conferencia

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSRESTFUL wsApproval DESCRIPTION "Retorna uma lista de Documentos para conferencia"
//WSRESTFUL wsApprovsssalPc DESCRIPTION "Retorna uma lista de Documentos para conferencia"

//WSDATA SearchKey 		AS STRING	OPTIONAL
//WSDATA Status			AS STRING  OPTIONAL
//WSDATA Page				AS INTEGER	OPTIONAL
//WSDATA PageSize			AS INTEGER	OPTIONAL
//WSDATA Code				AS STRING	OPTIONAL

WSMETHOD POST approval;
DESCRIPTION "Atualiza o Status da alçada de aprovação no protheus.";
WSSYNTAX "approval";
PATH "/api/v1/approval"   PRODUCES APPLICATION_JSON 

END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} POST  aprovacao / wsApproval
  

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON 

@author	 	Eduarado Vieira
@since		19/05/2012
@version	12.1.25
/*/
//-------------------------------------------------------------------
WSMETHOD POST approval WSSERVICE wsApproval

Local nStatusCode   := 500
Local oJTransfer	:= Nil
Local _cErro        := ''
Local oJsontrans	:= JsonObject():New()
Local aJtrans		:= {} 
Local lRet := .F.
Local nX
Local oRet := NIL
Local _cEmp := '02'
Local _cFil := '01'
Self:SetContentType("application/json; charset=UTF-8")

//If Len(cFilant) <> TamSX3("B1_FILIAL")[1]
//	ConOut( Replicate("R",80) )
//	ConOut('['+DtoC(date())+' - '+Time()+'] FILIAL COM TAMANHO INCORRETO NA TRANSFERENCIA ==> '+ Alltrim(str(Len(cFilant))) + ' <== FILIAL ==> ' + cFilAnt + ' <== TAMANHO CORRETO ==> ' + Alltrim(str(TamSX3("B1_FILIAL")[1])))
//	ConOut( Replicate("R",80) )
	 
//	RpcClearEnv()
//	
//	PREPARE ENVIRONMENT EMPRESA '02' FILIAL '02' MODULO "SIGAMDI" TABLES "SCR"
////Endif
//

If Len(Self:aURLParms) > 0 

	cBody 	 	:= Self:GetContent()

	If !Empty( cBody )
		
		FWJsonDeserialize(cBody,@oJTransfer)
		
		If !Empty( oJTransfer )
			
			IF VALTYPE(oJTransfer:Company) == 'C' .AND. VALTYPE(oJTransfer:Branch) == 'C' .AND. oJTransfer:Branch != 'NULL'

				_cEmp := PadL(AllTrim(oJTransfer:Company), 2, "0") 
				_cFil := PadL(AllTrim(oJTransfer:Branch), 2, "0") 
//				u_criaCon(_cEmp,_cFil)

				PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO "SIGAMDI" TABLES "SCR"
			
				oRetAppr  := ClassCtrRetApproval():new()    
				
				IF oRetAppr:atualizaAlcada('4',oJTransfer,'W',cBody,'WsApproval') 
					 	
					oRet := JsonObject():New()
					oRet['Status'] := 1
					oRet['Erro'] := oRetAppr:cErro
					lRet := .T.
					
				elseif !empty(oRetAppr:cErro)
					_cErro := "Erro ao integrar com o Sales."+ ' '+oRetAppr:cErro+ ' '+oRetAppr:cSugestao
					lRet := .F.
				ENDIF  
				FreeObj( oRetAppr )
				
//				RpcClearEnv()
				RESET ENVIRONMENT
				
				IF !EMPTY(_cErro)
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= _cErro
				endif
			ELSE
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= 'Nenhum foi informada a empresa e a filial.'
			ENDIF
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= 'Nenhum pedido enviado'
		EndIf			
		
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= 'Não foi possível ler os parâmetros enviados.' 
	EndIf
Else
	lRet 		:= .F.
	nStatusCode	:= 400
	cMessage 	:= 'Dados para atualização do pedido não encontrados' 
EndIf


If lRet
	cResponse := FwJsonSerialize( oRet )	
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, cMessage )		
	Self:SetResponse( cMessage )
EndIf
If ValType(oRet) == "O"
	FreeObj(oJsonTrans)
	oJsonTrans := Nil
Endif

Return( lRet )        	