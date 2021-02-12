#INCLUDE "topconn.ch"

/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                		 **/
/** Ponto de entrada MA450PED                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/

#Define ENTER chr(13)+chr(10)

User Function MA450PED()

Local aArea :=	GetArea() 
Local lRet	:=	.T.

If ExistBlock("KFATR15") .and. ( IsInCallStack("A455LibAut") .or. IsInCallStack("A455LibMan") .or. IsInCallStack("A455LibAlt") )
	LogEst(PARAMIXB[1])
Endif
//GRAVA DADOS DE LIBERACAO DE CREDITO FINANCEIRO AUTOMATICA
//U_GRVLIBF(.T.) - COMENTADO DIA 16/11/2017 

cQuebra:=PARAMIXB[1]
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+cQuebra)

cQuery:=" Select SUM(C9_QTDLIB*C9_PRCVEN) VLR from "+RETSqlName('SC9')
cQuery+=" WHERE C9_FILIAL='"+XfILIAL('SC9')+"' "
cQuery+=" AND C9_PEDIDO='"+cQuebra+"' " 
cQuery+="  AND C9_BLCRED = '' "
cQuery+=" AND D_E_L_E_T_<>'*'
If Select('TRAB')<>0
	TRAB->(dbCloseArea())
EndIF
TcQuery cQuery new alias 'TRAB'

if !TRAB->(eof())
	nVlr:=TRAB->VLR
EndIF          

reclock('SC5',.F.)
SC5->C5_VLIB := nVlr +SC5->C5_FRETE
msunlock()

RestArea(aArea)

Return	lRet   

Static Function LogEst(cPed)
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cTemp	:= GetNextAlias() 
	// quantidade bloqueada
	Local nBlq	:= 0
	// quantidade liberada
	Local nLib	:= 0
	
	cQuery+= "SELECT COUNT(*) C9_CONTA "+ENTER
	cQuery+= "FROM "+RetSqlName("SC9")+" WITH(NOLOCK) "+ENTER
	cQuery+= " "+ENTER
	cQuery+= "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery+= "AND C9_FILIAL='"+xFilial("SC9")+"' "+ENTER
	cQuery+= "AND C9_PEDIDO='"+cPed+"' "+ENTER
	cQuery+= "AND C9_NFISCAL='' "+ENTER
	cQuery+= "AND C9_BLEST IN ('02','03') "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->(DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		nBlq := (cTemp)->C9_CONTA
	Endif
	
	cQuery:= "SELECT COUNT(*) C9_CONTA "+ENTER
	cQuery+= "FROM "+RetSqlName("SC9")+" WITH(NOLOCK) "+ENTER
	cQuery+= " "+ENTER
	cQuery+= "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery+= "AND C9_FILIAL='"+xFilial("SC9")+"' "+ENTER
	cQuery+= "AND C9_PEDIDO='"+cPed+"' "+ENTER
	cQuery+= "AND C9_NFISCAL='' "+ENTER
	cQuery+= "AND C9_BLEST='' "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->(DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		nLib := (cTemp)->C9_CONTA
	Endif
		
	If Select(cTemp)>0
		(cTemp)->(DbCloseArea() )
	Endif
	
	// liberacao parcial
	if nBlq > 0 .and. nLib > 0
		U_KFATR15("14",cPed )
	Endif
	
	// nenhuma liberacao
	If nBlq > 0 .and. nLib == 0
		U_KFATR15("15",cPed )
	Endif
	
	// liberacao total
	if nBlq == 0 .and. nLib > 0
		U_KFATR15("04",cPed)
	Endif
	
	RestArea(aArea)
Return


