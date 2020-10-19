#Include "Protheus.ch"
#Include "TOPCONN.ch"
       
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MPCO001
Funções do PCO para serem utilizadas na tabela AKC e AKI

@return 
@author Felipe Toazza Caldeira
@since 05/07/2016
/*/
//-------------------------------------------------------------------------------
                                                                                 



//-------------------------------------------------------------------------------
/*/{Protheus.doc} MPCO001A
Busca do Centro de Custo na Ordem de Serviço

@return 
@author Felipe Toazza Caldeira
@since 05/07/2016
/*/
//-------------------------------------------------------------------------------
User Function MPCO001A() 
Local cCcusto := ""

	cCCusto := Posicione("STJ",1,xFilial('STJ')+SC2->C2_NUM,"TJ_XCC")   
	If Empty(Alltrim(cCCusto))
		cCCusto := Posicione("STJ",1,xFilial('STJ')+SC2->C2_NUM,"TJ_CCUSTO")   	
	EndIf

Return cCCusto
 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MPCO001B
Busca do Item Conta

@return 
@author Felipe Toazza Caldeira
@since 05/07/2016
/*/
//-------------------------------------------------------------------------------
User Function MPCO001B() 
Local cItemCta := ""

	cItemCta := Posicione("STJ",1,xFilial('STJ')+SC2->C2_NUM,"TJ_XITEMCT")   
	If Empty(Alltrim(cItemCta))
		cItemCta := Posicione("ST9",1,xFilial('ST9')+STJ->TJ_CODBEM,"T9_ZITEMCT")
		If Empty(Alltrim(cItemCta))
			cItemCta := Posicione("ST9",1,xFilial('ST9')+Posicione("STC",3,xFilial('STC')+STJ->TJ_CODBEM,"TC_CODBEM"),"T9_ZITEMCT")		
		EndIf
	EndIf

Return cItemCta
 
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MPCO001C
Busca do valor

@return 
@author Felipe Toazza Caldeira
@since 05/07/2016
/*/
//-------------------------------------------------------------------------------
User Function MPCO001C() 
Local nValor := 0            

cQuery := " SELECT SUM(D4_QUANT*B2_CM1) AS CUSTO "
cQuery += " FROM "+RetSqlName('SD4')+" SD4, "+RetSqlName('SB2')+" SB2 "
cQuery += " WHERE
cQuery += "   D4_OP = '"+SC2->C2_NUM+"OS001"+"' AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND SD4.D_E_L_E_T_ != '*'  AND SB2.D_E_L_E_T_ != '*' "

cQuery := ChangeQuery(cQuery)

IF SELECT("TMPCUSTO")<>0
	TMPCUSTO->(DBCLOSEAREA())
EndIf
 
TcQuery cQuery new Alias "TMPCUSTO"
dbSelectArea("TMPCUSTO")
TMPCUSTO->(DbGoTop())			
		
nValor	:= TMPCUSTO->CUSTO
TMPCUSTO->(DBCLOSEAREA())


Return nValor
                                                  

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MPCO001D
Busca a Conta Contábil

@return 
@author Felipe Toazza Caldeira
@since 05/07/2016
/*/
//-------------------------------------------------------------------------------
User Function MPCO001D() 
Local cConta := ""
                    
M->D3_ITEMCTA 	:= CriaVar('D3_ITEMCTA') 
M->D3_CONTA 	:= CriaVar('D3_CONTA') 
M->D3_GRUPO		:= CriaVar('D3_GRUPO') 

M->D3_ITEMCTA 	:= U_MPCO001B() 

RunTrigger(1,,nil,,'D3_ITEMCTA')

cConta	:= M->D3_CONTA

If !Empty(Alltrim(Posicione("STJ",1,xFilial('STJ')+SC2->C2_NUM,"TJ_XCONTA")))
	cConta := STJ->TJ_XCONTA
EndIf

Return cConta


