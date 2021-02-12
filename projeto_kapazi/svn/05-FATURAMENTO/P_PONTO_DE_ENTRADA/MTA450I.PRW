#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                		 **/
/** Ponto de entrada MTA450I                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/

User Function MTA450I()
Local aArea 	:=	GetArea() 
Local lRet		:=	.T.
Local cPedido	:= SC9->C9_PEDIDO
Private nVlrLib	:= 0
//GRAVA DADOS DE LIBERACAO DE CREDITO FINANCEIRO AUTOMATICA
//U_GRVLIBF(.T.)  - COMENTADO DIA 16/11/2017 

//Ponto de entrada na liberação de estoques automática
U_LFINAU()  

//Gravação realizada pelo PE MTA450RP
//grava log de liberação do pedido
//If ExistBlock("KFATR15") .and. IsInCallStack("a450libman")
//	U_KFATR15("03",SC9->C9_PEDIDO)
//Endif

//EDITADO EM 27/01/2017 
cQuebra:=SC9->C9_PEDIDO
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
	//nVlr	:= TRAB->VLR
	nVlrLib	:= TRAB->VLR
EndIF          

reclock('SC5',.F.)
SC5->C5_VLIB  :=  nVlrLib + SC5->C5_FRETE
msunlock() 

// chama a rotina para gravar o historico de liberação de credito
U_KFATA02(SC9->C9_BLCRED, SC9->C9_PEDIDO)

If cEmpAnt == "04" .And. PARAMIXB[1] == 1 .And. !IsInCallStack("U_M410PVNF")
	If Alltrim(SC5->C5_XPVSPC) == "S"
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		SC5->(DbGoTop())
		If MsSeek(xFilial("SC5")+cPedido)
			If Type("NVLR") == "U" 
					ApuZCLMV(nVlrLib) //Variavel NVLR
				Else
					ApuZCLMV(NVLR) //Variavel NVLR 
			EndIf
		EndIf
		
	EndIf
EndIf

If Alltrim(cEmpAnt) == "04" .And. !Empty(SC6->C6_NUMORC) //Adicionado tratamento para empresa 04 - Luis 21-05-18
	    SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,TamSX3('CJ_NUM')[1])))
	    If !Empty(SCJ->CJ_XNUMFLU) //Verifica se tem origem FLUIG
		    			        
	    	if !isBlq() //Se não está bloqueado
				Reclock('ZA1',.T.)
				ZA1->ZA1_FILIAL:=xFilial('ZA1')
				ZA1->ZA1_TIPO  :='LIB CREDITO'
				ZA1->ZA1_NUM   :=SC5->C5_NUM
				ZA1->ZA1_STATUS:='1' //Aguardando	
				ZA1->ZA1_DTCRIA:=Date()
			    ZA1->ZA1_HRCRIA:=Time()
			    ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
				MsUnlock()
		
				//Inicia o JOB que irá integrar com o Fluig
				//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
				StartJob('U_KAPJOB',GetEnvServer(),.F., 'LIB CREDITO', SC5->C5_NUM, CEMPANT, CFILANT)
			endif
		endif
endif

RestArea(aArea)
Return()  

/*--------------------------------------------------------------------------+
|  isBlq - Retorna .T. se está bloqueado                                    |
----------------------------------------------------------------------------*/
Static function isBlq()
	Local cAliasSC9	:= GetNextAlias()
	Local lBlqCre:=.F.
	
        //Verifica se houve bloqueio de Crédito
		cQuery := "	SELECT C9_BLCRED "
		cQuery += "	FROM " + RetSqlName("SC9")
		cQuery += "	WHERE "
		cQuery += "	C9_FILIAL = '" + xFilial("SC9")+"'"
		cQuery += "	AND C9_PEDIDO = '" + SC6->C6_NUM+"'"
		cQuery += "	AND D_E_L_E_T_ = ' ' "
		//cQuery += "	AND C9_NFISCAL = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

		While !(cAliasSC9)->(Eof())
			If !Empty((cAliasSC9)->C9_BLCRED)
				lBlqCre := .T.
				Exit
			EndIf
			(cAliasSC9)->(dbSkip())
		EndDo
		(cAliasSC9)->(DBCloseArea())

return lBlqCre


Static Function ApuZCLMV(NVLR)
Local nNew		:= 0
Local lValAtu	:= 0
Local nRecoC5 	:= SC5->(RECNO())
Local cQr 		:= ""

cQr += " SELECT R_E_C_N_O_ RECOZCL,*
cQr += " FROM ZCL040
cQr += " WHERE ZCL_RECSC5 = "+ cValtoChar(nRecoC5) +""
cQr += " ORDER BY R_E_C_N_O_ DESC

// abre a query
TcQuery cQr new alias "cAliaZS7"

DbSelectArea("cAliaZS7")
cAliaZS7->(DbGoTop())

If cAliaZS7->(EOF())
		DbSelectArea("ZCL")
		Reclock("ZCL",.T.)
		ZCL->ZCL_FILINC	:= xFilial("SC5")
		ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
		ZCL->ZCL_SEQ	:= PegaSeq()
		ZCL->ZCL_VALOR	:= NVLR
		ZCL->ZCL_RECSC5	:= SC5->(RECNO())
		ZCL->ZCL_CDUSER	:= __cUserId
		ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
		ZCL->ZCL_DTALT	:= Date()
		ZCL->ZCL_HRALT	:= Time()
		ZCL->(MsUnLock())
	
	ElseIf !cAliaZS7->(EOF()) .And. Empty(cAliaZS7->ZCL_OFF) 
		DbSelectArea("ZCL")
		ZCL->(DbSetOrder(1))
		ZCL->(DbGoTop())
		ZCL->(DbGoTo(cAliaZS7->RECOZCL))
		lValAtu	:= cAliaZS7->ZCL_VALOR
		
		Reclock("ZCL",.F.)
		ZCL->ZCL_VALOR	:= NVLR
		ZCL->ZCL_CDUSER	:= __cUserId
		ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
		ZCL->ZCL_DTALT	:= Date()
		ZCL->ZCL_HRALT	:= Time()
		ZCL->(MsUnLock())
	
	ElseIf !cAliaZS7->(EOF()) .And. !Empty(cAliaZS7->ZCL_OFF)
		DbSelectArea("ZCL")
		Reclock("ZCL",.T.)
		ZCL->ZCL_FILINC	:= xFilial("SC5")
		ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
		ZCL->ZCL_SEQ	:= PegaSeq()
		ZCL->ZCL_VALOR	:= NVLR
		ZCL->ZCL_RECSC5	:= SC5->(RECNO())
		ZCL->ZCL_CDUSER	:= __cUserId
		ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
		ZCL->ZCL_DTALT	:= Date()
		ZCL->ZCL_HRALT	:= Time()
		ZCL->(MsUnLock())
EndIf	
		
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTOp())
If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	nNew := SA1->A1_SALPEDL - (NVLR - lValAtu) //Pega o valor do controle de limite para achar o decrescimo, pois pedidos supplier nao podem usar o limite.
	
	RecLock("SA1",.F.)
	SA1->A1_SALPEDL := nNew
	SA1->(MsUnlock())
EndIf

cAliaZS7->(DbCloseArea())

Return()


Static Function PegaSeq()
Local cQry := ""
Local cSeq := ""
 
cQry:=" SELECT  TOP 1 ZCL_SEQ FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCL')<>0
	TRZCL->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCL'

If TRZCL->(eof())
		cSeq := '001'
	Else
		cSeq := Soma1(TRZCL->ZCL_SEQ)
EndIf

TRZCL->(DBCloseArea())
Return(cSeq)


user function LFINAU()

	local _cPedido:=sc9->c9_pedido

	if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
		sc5->c5_xsitlib:=u_KpFatC01(_cPedido)

		_vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
		sc5->c5_xdtlibp:=_vDatas[1]	//DESCOMENTADO DIA 30/05/2017 - SULIVAN
		sc5->c5_xdtlibf:=_vDatas[2]
		sc5->c5_xdtlibe:=_vDatas[3]

		sc5->(msunlock())
	endif  

return Nil