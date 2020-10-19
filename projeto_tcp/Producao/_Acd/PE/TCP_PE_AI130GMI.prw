#include "protheus.ch"
#include "apvt100.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AI130GMI  ºAutor  ³Deosdete P. Silva   º Data ³  11/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de entrada para pegar o numero da OS no Retorno de  º±±
±±º          ³  OS                                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AI130GMI()
Local aMATA      := PARAMIXB 
Local cTM        := SuperGetMV("TCP_AI130TM",.F.,"111")   //Tipo de Movimentacao especifica para retorno de OS com vinculo OS/OP
Local nPosTM     := aScan(aMATA, {|x| x[1] == "D3_TM"}) 
Local nPosQUANT  := aScan(aMATA, {|x| x[1] == "D3_QUANT"})  
Local nPosProd   := aScan(aMATA, {|x| x[1] == "D3_COD"})  
Local cOM        := Space(6)  
Local cOP        := Space(11)  
Local nLinha     := 0
Local lValid     := .T.

//Conout('quant: '+STR(aMata[nPosQUANT][2]))

If cTM == aMATA[nPosTM][2]

	VTClear()
	@ 0,0 VTSay "Retorno OS TCP"
	@ ++nLinha,0 VTSay "OM" VTGet cOM  pict '@!'  F3 "OPOM" //Valid AI130VLOM(cOM)
	
	@ ++nLinha,0 VTSay "OP" VTGet cOP  pict '@!' F3 "SC2" //Valid AI130VLOS(cOP) 
	VTRead

EndIf

lValid := AI130VLOM(cOM,cOP,aMata[nPosProd][2],aMata[nPosQUANT][2])

If lValid
	
//Conout('quant: '+STR(aMata[nPosQUANT][2]))
	//aAdd(aMata,{"D3_ORDEM", cOP         , nil})
	//aAdd(aMata,{"D3_OP", SC2->C2_NUM +SC2->C2_ITEM + SC2->C2_SEQUEN   , nil})
	aAdd(aMata,{"D3_XOBS", SC2->C2_NUM +SC2->C2_ITEM + SC2->C2_SEQUEN   , nil})
	aAdd(aMata,{"D3_CC", SC2->C2_CC   , nil})
	aAdd(aMata,{"D3_CONTA", SC2->C2_XCONTA   , nil})
	aAdd(aMata,{"D3_ITEMCTA", SC2->C2_ITEMCTA   , nil})
	
Else
	aMata[nPosQUANT][2] := 0
	VTBEEP(2)
	VTALERT("Retorno nao efetivado. Verifique OS","AVISO",.T.,4000) 
	VTKeyBoard(chr(20))
EndIf	

Return aMATA
     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AI130VL   ºAutor  ³Deosdete P. Silva   º Data ³  11/22/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de entrada para pegar o numero da OS no Retorno de  º±±
±±º          ³  OS                                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI130VLOM(cOm, cOP, cCodProd,nQtdEst)
Local lRet    := .T.
Local cNumOp  := ''
Local nQtdReq := 0
local cAlias
local cWhere  := ''

//Verificar se a OP existe
DbSelectArea("SC2")

If Empty(cOm) .AND. Empty(cOP)
	VTBEEP(2)
	VTALERT("Informe a OS ou OM","AVISO",.T.,4000) 
	VTKeyBoard(chr(20))
	lRet :=  .F.
EndIf


If lRet .AND. !EMPTY(cOm) 
	SC2->(DbSetOrder(12)) //C2_FILIAL, C2_XNUMOM
	IF !SC2->(DbSeek(xFilial("SC2")+cOm))
		VTBEEP(2)
		VTALERT("O.P invalida op nao encontrada","AVISO",.T.,4000) 
		VTKeyBoard(chr(20))
		lRet :=  .F.
	else
		cNumOp := SC2->C2_NUM +SC2->C2_ITEM + SC2->C2_SEQUEN
	ENDIF
EndIf
	
If lRet .AND. !EMPTY(cOP)
	dbSelectArea('SC2')
	SC2->(DbSetOrder(1)) //C2_FILIAL, C2_XNUMOM
	IF !SC2->(DbSeek(xFilial("SC2")+cOP))
		
		VTBEEP(2)
		VTALERT("O.S invalida os nao encontrada","AVISO",.T.,4000) 
		VTKeyBoard(chr(20))
		lRet :=  .F.
	ELSE
	
		SC2->(DbSetOrder(1)) //DbSetOrder(1) //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
		IF !SC2->(DbSeek(xFilial("SC2")+cOP))
		
			VTBEEP(2)
			VTALERT("O.P da OS invalida op nao encontrada","AVISO",.T.,4000) 
			VTKeyBoard(chr(20))
			lRet :=  .F.
		ELSEIF (!EMPTY(cNumOp) .AND. cNumOp != SC2->C2_NUM +SC2->C2_ITEM + SC2->C2_SEQUEN)
			VTBEEP(2)
			VTALERT("OM e OS não compatíveis. Preencha apenas uma.","AVISO",.T.,4000) 
			VTKeyBoard(chr(20))
			lRet :=  .F.
		ENDIF
	ENDIF
EndIf

//VALIDA quantidade
IF (lRet)
	
	IF !EMPTY(cOm) 
		//Se for por OM, consulta todas as OPS desta OM
		cWhere := "% AND RTRIM(LTRIM(C2_XNUMOM)) = '"+cOm+"' %"
		cAlias := getNextAlias()

		BeginSQL Alias cAlias
			 
			  SELECT SUM(CB8_QTDORI - CB8_SALDOS) AS QUANT, C2_NUM ,C2_ITEM , C2_SEQUEN
			 FROM %TABLE:CB8% CB8
			 INNER JOIN %TABLE:CB7% CB7 ON CB7_FILIAL = CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP
			 INNER JOIN %TABLE:SC2% SC2 ON CB7_FILIAL = C2_FILIAL AND CB7_OP = C2_NUM+C2_ITEM+C2_SEQUEN  
			 WHERE CB8.%NotDel% AND CB7.%NotDel% AND SC2.%NotDel% AND CB8.CB8_PROD = %EXP:cCodProd% AND RTRIM(LTRIM(C2_XNUMOM)) = %EXP:cOm%
			 GROUP BY C2_NUM ,C2_ITEM , C2_SEQUEN
			
		EndSQL  
		
		//Conout(getlastquery()[2])
		//Conout('getlastquery()[2]')
		nQtdReq := 0
		WHILE (cAlias)->(!Eof())
			nQtdReq += (cAlias)->QUANT
			cNumOp  := (cAlias)->C2_NUM +(cAlias)->C2_ITEM + (cAlias)->C2_SEQUEN
			(cAlias)->(DBSKIP())
		ENDDO

		(cAlias)->(dbclosearea())
	ELSEIF !EMPTY(cOP)
		
		cWhere := "% AND C2_NUM +C2_ITEM + C2_SEQUEN = '"+SC2->(C2_NUM +C2_ITEM + C2_SEQUEN)+"' %"
		cNumOp  := SC2->C2_NUM +SC2->C2_ITEM + SC2->C2_SEQUEN
		cAlias := getNextAlias()

		BeginSQL Alias cAlias
			 
			 SELECT SUM(CB8_QTDORI - CB8_SALDOS) AS QUANT
			 FROM %TABLE:CB8% CB8
			 WHERE CB8.%NotDel% AND CB8.CB8_PROD = %EXP:cCodProd% AND CB8_OP = %EXP:cOP%
			 
		EndSQL  
		
		IF (cAlias)->(!Eof())
			nQtdReq := (cAlias)->QUANT
		ENDIF

		(cAlias)->(dbclosearea())
		
	endif
	
	cAlias := getNextAlias()

	BeginSQL Alias cAlias
		 
		 SELECT SUM(D3_QUANT) AS QUANT
		 FROM %TABLE:SD3% SD3
		 INNER JOIN %TABLE:SC2% SC2 ON C2_NUM +C2_ITEM + C2_SEQUEN = D3_OP AND D3_FILIAL = C2_FILIAL
		 WHERE SD3.%NotDel% AND SC2.%NotDel% AND SD3.D3_COD = %EXP:cCodProd% AND D3_TM < '499' %EXP:cWhere% 
		 
	EndSQL  
	
	
	//Se a quantidade requisitada for menor que a quantidade já retornada + quantidade que está retornando agora, não permite
	IF nQtdReq < (cAlias)->QUANT + nQtdEst
		VTBEEP(2)
		VTALERT("Quantidade devolvida maior que a quantidade retirada.","AVISO",.T.,4000) 
		VTKeyBoard(chr(20))
		lRet :=  .F.
		
		//Conout(nQtdReq)
		//Conout('------.-------')
		//Conout((cAlias)->QUANT + nQtdEst)
	ENDIF
	
	(cAlias)->(dbclosearea())
	
	//Posiciona denovo, para pegar a OM correta que tenha saldo
	SC2->(DbSetOrder(1))
	IF !SC2->(DbSeek(xFilial("SC2")+cNumOp))
		VTBEEP(2)
		VTALERT("O.P invalida op nao encontrada 2"+cNumOp,"AVISO",.T.,4000) 
		VTKeyBoard(chr(20))
		lRet :=  .F.
	ENDIF

ENDIF
	
Return lRet



