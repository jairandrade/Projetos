#INCLUDE "PROTHEUS.CH"

//Aguardando outros niveis
#define CR_AGUAR     '01'
//Pendente do usuario
#define CR_PENDE     '02'
//Aaprovado
#define CR_APROVAD     '03'
//Bloqueado pelo usuario
#define CR_BLOQUE  '04'
//Aprovado por outro usuario do mesmo nivel
#define CR_APOUT     '05'
//Rejeitado pelo usuaraio
#define CR_ROUT      '06'
//Documento Rejeitado ou Bloqueado por outro usuário
#define CR_RROUT     '07'
   
#define PENDIN     'Pending'
#define APPROV     'Approved'
#define REJECT     'Rejected'
#define NORESP     'NoResponse'


CLASS ClassCtrRetApproval 

DATA oObjRet
Data cErro
data cSugestao
Data oIntPc
method new() constructor 
method atualizaAlcada()
method atuAprovacao()
method convertStatus()
method getApr()
method procPed()
method aprovaPed()
method rejeitaPed()

ENDCLASS

method new() class ClassCtrRetApproval

	::oObjRet     := ''
	::cErro       := ''
	::oIntPc      := NIL
	::cSugestao   := ''
	
return

method atualizaAlcada(_cTipo,oObjSales,_cOper,cBody,cOrig) class ClassCtrRetApproval
	Local lRet := .F.
	
	IF oObjSales != NIL .AND. VALTYPE(oObjSales:PurchaseOrderId) == 'C'
		oIntPc  := ClassIntPcCompras():new()    
		
		oIntPc:cCorpoPost := cBody
		oIntPc:registraIntegracao(_cTipo,oObjSales:PurchaseOrderId,_cOper)  
		
		IF !empty(oIntPc:cNumPc)
		
			IF VALTYPE(oObjSales:Aprovadores) == 'A' 
	//			IF oIntPc:vincAlcada(oObjSales:Aprovadores)
					IF ::atuAprovacao(oIntPc,oObjSales)
						lRet := .T.
					ENDIF
	//			ENDIF
			ENDIF
			
			if EMPTY(::cErro) .AND. oObjSales:Status != PENDIN
				::procPed(oIntPc:cFilPc,oIntPc:cNumPc,oObjSales:Status)
			endif
			
			oIntPc:cErro := ::cErro 
			_cAut  := IF(EMPTY(::cErro ),'200 OK','400')
			oIntPc:atuLog('',_cAut,cOrig)
			
		else
			::cErro := 'Pedido não encontrado. Código: '+oObjSales:PurchaseOrderId
			::cSugestao := 'Entre em contato com o suporte.'
			oIntPc:cErro := ::cErro
			oIntPc:cSugestao := ::cSugestao
			oIntPc:cNumPc := 'XXXXXX'
			oIntPc:gravaLogZZK('W')
			lRet := .F.
			
		endif
		
		FreeObj( oIntPc )
		
	ENDIF

return lRet 
//#define CR_AGUAR     '01'
////Pendente do usuario
//#define CR_PENDE     '02'
////Aaprovado
//#define CR_APROVAD     '03'
////Bloqueado pelo usuario
//#define CR_BLOQUE  '04'
////Aprovado por outro usuario do mesmo nivel
//#define CR_APOUT     '05'
////Rejeitado pelo usuaraio
//#define CR_ROUT      '06'
////Documento Rejeitado ou Bloqueado por outro usuário
//#define CR_RROUT     '07'
//
//#define PENDIN     'Pending'
//#define APPROV     'Approved'
//#define REJECT     'Rejected'
method atuAprovacao(oIntPc,oObjSales) class ClassCtrRetApproval

	Local cFilPc   := oIntPc:cFilPc
	Local cNumPc   := oIntPc:cNumPc
	Local cGrpApr  := ''
	Local dDtEmis  := CTOD('  /  /    ')
	Local _nInd    := 1
	Local lRet := .t.
	Local _nMoed := 1
	Local _nTot  := 0
	Local aAprova := oObjSales:Aprovadores
	Local _cAliAks
	Local nCntApr := 0
	if !empty(oIntPc:cFilPc) .OR. EMPTY(oIntPc:cNumPc)
		_cAliAks := getNextAlias()
	
		BeginSQL Alias _cAliAks
			SELECT SCR.R_E_C_N_O_ AS RECCR, CR_NIVEL,CR_STATUS,CR_USER,AK_XSALES,CR_EMISSAO,CR_GRUPO,CR_TOTAL,CR_MOEDA,C7_EMISSAO,C7_APROV,C7_TOTAL,C7_MOEDA
			FROM %TABLE:SC7% SC7
			LEFT JOIN %TABLE:SCR% SCR ON CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO='PC' AND SCR.%NotDel%
			LEFT JOIN %TABLE:SAK% SAK ON AK_COD =  CR_APROV AND SAK.%NotDel% 
			WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:cFilPc%  AND C7_NUM = %EXP:cNumPc% 
			GROUP BY  SCR.R_E_C_N_O_ , CR_NIVEL,CR_STATUS,CR_USER,AK_XSALES,CR_EMISSAO,CR_GRUPO,CR_TOTAL,CR_MOEDA,C7_EMISSAO,C7_APROV,C7_TOTAL,C7_MOEDA
			ORDER BY CR_NIVEL
	
		EndSQL
		
		for _nInd := 1 to LEN(aAprova)
			oObjTmp := aAprova[_nInd]
			
			if oObjTmp:Status != 'Started'
				nCntApr++
				aCodApr := {}
				oObjTmp:Usuario
				oObjTmp:Nome
				
				nRecCr := 0
				(_cAliAks)->(DbGoTop())
				While (_cAliAks)->(!Eof())
				
					dDtEmis := STOD((_cAliAks)->C7_EMISSAO)
					
					cGrpApr := (_cAliAks)->C7_APROV
					_nTot   := (_cAliAks)->C7_TOTAL
					_nMoed  := (_cAliAks)->C7_MOEDA
					
					IF((_cAliAks)->RECCR != NIL .AND. ALLTRIM((_cAliAks)->AK_XSALES)) == AlLTRIM(oObjTmp:UsuarioOriginal) .AND. PadL( AllTrim(STR(oObjTmp:Nivel)), 2, "0") == (_cAliAks)->CR_NIVEL
						nRecCr := (_cAliAks)->RECCR
					ENDIF
				
					(_cAliAks)->(dbSkip())
				EndDo
				
				IF oObjTmp:Nivel != 0

					aRetApr := oIntPc:vincUsuario(oObjTmp:Usuario,oObjTmp:Nome)
					aRetOri := oIntPc:vincUsuario(oObjTmp:UsuarioOriginal,oObjTmp:NomeOriginal)
					
					cTmpStat := ::convertStatus(oObjTmp:Status)
					
					
					IF LEN(aRetOri) > 0
						
						IF EMPTY(cGrpApr) .AND. !EMPTY(oObjSales:Area)
							oIntPc:vincGrupo(oObjSales:Area,aRetOri,nCntApr,oObjTmp:Nivel)
							cGrpApr := oIntPc:cGrpProt
							
							oIntPc:atuCodPed(oObjSales:PurchaseOrderId)
						ENDIF
						if LEN(aRetApr) > 0 .AND. LEN(aRetOri) > 0
						
							if nRecCr > 0 
								
								IF  cTmpStat != CR_PENDE
										
									DBSelectArea('SCR')
									SCR->(DBGOTO(nRecCr))
									RecLock("SCR",.F.)
									_dDtApr := dDataBase
									if (oObjTmp:Data != nil)
										_dDtApr := CTOD(SUBSTR(oObjTmp:Data,1,10))
									endif
									SCR->CR_DATALIB := _dDtApr
									SCR->CR_USERLIB := aRetApr[1][2]
									SCR->CR_STATUS  := cTmpStat
									SCR->CR_OBS     := oObjTmp:Comentario
									
									if cTmpStat == CR_APROVAD
										SCR->CR_LIBAPRO := aRetApr[1][1]
									endif
									
									IF empty(SCR->CR_GRUPO)
										SCR->CR_GRUPO  := cGrpApr
									endif
									
									SCR->(msUnlock())
								endif
								
							else
								RecLock("SCR",.T.)
								SCR->CR_FILIAL := cFilPc
								SCR->CR_NUM    := cNumPc
								SCR->CR_NIVEL  := PadL(AllTrim(STR(oObjTmp:Nivel)), 2, "0") 
								SCR->CR_USER   := aRetOri[1][2]
								SCR->CR_STATUS := cTmpStat
								SCR->CR_EMISSAO:= dDtEmis
								SCR->CR_MOEDA  := _nMoed
								SCR->CR_TIPO   := 'PC'
								SCR->CR_TOTAL  := _nTot
								SCR->CR_GRUPO  := cGrpApr
								SCR->CR_APROV  := aRetOri[1][1]
								
								IF  cTmpStat != CR_PENDE
									_dDtApr := dDataBase
									if (oObjTmp:Data != nil)
										_dDtApr := CTOD(SUBSTR(oObjTmp:Data,1,10))
									endif
									SCR->CR_DATALIB := _dDtApr
									SCR->CR_USERLIB := aRetApr[1][2]
									if cTmpStat == CR_APROVAD
										SCR->CR_LIBAPRO := aRetApr[1][1]
									endif
									SCR->CR_OBS     := oObjTmp:Comentario
								endif
								
								SCR->(msUnlock())
							endif
							
							if EMPTY(::cErro) .AND. cTmpStat == CR_BLOQUE
								::rejeitaPed(cFilPc,cNumPc,oObjTmp:Comentario)
							ENDIF
						ELSE
							::cErro := 'Usuário não cadastrado como aprovador no Protheus. Usuário: '+if(valTYPE(oObjTmp:UsuarioOriginal) == 'C',oObjTmp:UsuarioOriginal,'')+' .'
							::cErro += 'Substituto: '+if(valTYPE(oObjTmp:Usuario) == 'C',oObjTmp:Usuario,'')+' .'
							::cSugestao := 'Entre em contato com o suporte.'
							lRet := .F.
						ENDIF
					ELSE
						::cErro := 'Usuário não cadastrado como aprovador no Protheus. Usuário: '+if(valTYPE(oObjTmp:UsuarioOriginal) == 'C',oObjTmp:UsuarioOriginal,'')+' .'
						::cSugestao := 'Entre em contato com o suporte.'
						lRet := .F.
					ENDIF
				ELSE
					::cErro := 'Nivel inválido. Nível: '+ALLTRIM(STR(oObjTmp:Nivel))+' Usuário: '+if(valTYPE(oObjTmp:UsuarioOriginal) == 'C',oObjTmp:UsuarioOriginal,'')+' .'
					::cSugestao := 'Entre em contato com o suporte.'
					lRet := .F.
				ENDIF
			endif
		next
	
		(_cAliAks)->(dbCloseArea())
	ELSE
		::cErro := 'Pedido não encontrado no Protheus.'
		::cSugestao := 'Verifique no Protheus.'
		lRet := .F.
	ENDIF
return lRet

method convertStatus(cStatSal) class ClassCtrRetApproval
	Local lRet := .T.
	Local cStatRet := ''

	DO CASE
		CASE cStatSal == PENDIN
		
			cStatRet := CR_PENDE
			
		CASE cStatSal == APPROV
		
			cStatRet := CR_APROVAD
			
		CASE cStatSal == REJECT
		
			cStatRet := CR_BLOQUE
			
		CASE cStatSal == NORESP
	
		cStatRet := CR_RROUT
		
		OTHERWISE
		::cErro := 'Status de aprovação inválido. Status: '+cStatSal
		::cSugestao := 'Entre em contato com o suporte'
		lRet := .F.

	ENDCASE

return cStatRet

method procPed(_cFil,_cPed,_cStatus,_cMot) class ClassCtrRetApproval
	
	if _cStatus == APPROV
		::aprovaPed(_cFil,_cPed)
//	elseif _cStatus == REJECT
//		::rejeitaPed(_cFil,_cPed,_cMot)
	endif
	
return

method aprovaPed(_cFil,_cPed) class ClassCtrRetApproval

	dbSelectArea("SC7")
	SC7->(dbGoTop())
	SC7->(dbSetOrder(1))
	if SC7->(dbSeek(_cFil+_cPed)) .AND. SC7->C7_CONAPRO != "L"
		While !SC7->(EOF()) .And. SC7->C7_NUM == _cPed .AND. C7_FILIAL == _cFil
	
			dDataCalc := (dDataBase + SC7->C7_PRAZO)  
			DbSelectArea('SP3')
			SP3->(DbSetOrder(1))
			SP3->(DbGoTop())
			If SP3->(DbSeek(xFilial('SP3')+DtoS(dDataCalc))) 
				dDataCalc := dDataCalc + 1
			EndIf		
			If Dow(dDataCalc) == 1 //domingo
				dDataCalc := dDataCalc + 1	
			ElseIf Dow(dDataCalc) == 7 //sabado
				dDataCalc := dDataCalc + 2
			EndIf
			
			RecLock("SC7",.F.)
				SC7->C7_CONAPRO := "L"
				SC7->C7_DATPRF  := dDataCalc 
			SC7->(MsUnLock("SC7"))
			
			U_ZPB_ATU(SC7->C7_NUM, SC7->C7_NUMSC, SC7->C7_MEDICAO, SC7->C7_CONAPRO)
			
			SC7->(dbSkip())
		Enddo
		
		oCompras  := ClassIntCompras():new()    
		
		IF oCompras:registraIntegracao('2',_cFil+_cPed,'I')  
			oCompras:enviaSales()
		ENDIF  

		IF FindFunction("u_RCOM008")
			U_RCOM008(_cFil,_cPed)
		EndIF   
	endif
	
return

method rejeitaPed(_cFil,_cPed,_cMot) class ClassCtrRetApproval

	dbSelectArea("SC7")
	SC7->(dbGoTop())
	SC7->(dbSetOrder(1))
	if SC7->(dbSeek(_cFil+_cPed))
		While !SC7->(EOF()) .And. SC7->C7_NUM == _cPed .AND. C7_FILIAL == _cFil
			RecLock("SC7",.F.)
			
			SC7->C7_MOTREJ:=AllTrim(_cMot)
			SC7->(MSUNLOCK())
			
			// Atualizar o registro da ZPB (Reparo/Garantia) caso a SC7 tenha sido gerada a partir do Monitor de GARANTIA/REPARO
			U_ZPB_ATU(SC7->C7_NUM, SC7->C7_NUMSC, SC7->C7_MEDICAO, 'X')
			SC7->(dbSkip())
		Enddo
	endif
	
return