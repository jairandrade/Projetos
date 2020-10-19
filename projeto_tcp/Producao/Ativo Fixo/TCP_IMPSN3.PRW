#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "Directry.ch"  

User function IMPsn3() 

Private nColcBase	:= 1
Private nColFil	:= 2
Private nColItem	:= 3
Private nColTipo		:= 4
Private nColBx	:= 5
Private nColHist	:= 6
Private nColcConta	:= 7
Private nColcDepr	:= 8
Private nColccDep		:= 9
Private nColdIndep 	:= 10
Private nColvOrig		:= 11
Private nColTxDp 	:= 12
Private nColVdrCm    := 13
Private nColAqs    := 14
Private nColTpDep    := 15
Private nColTpSld    := 16
Private nHandle 
Private _cErro 
cTipo := "Arquivos Texto  (*.CSV)  | *.CSV | "
cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))

if !empty(cNomeTXT)

	nHandle := FT_FUSE(cNomeTXT)
	
	if nHandle < 0
		Alert("Erro ao abrir o arquivo de texto!")
		Return .F.
	endif
	
	Processa( {|| impArq(cNomeTXT,1) }, "Aguarde...", "Importando...",.F.)   
	
	FT_FUSE()  
	
	if !empty(_cErro)
		Help(NIL, NIL, "Registro inválido", NIL, _cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Fale com o Raphael"})
	endif
		
	
	
endif

RETURN

STATIC function impArq(cNomeTXT, _cTp)

	local cLFRC    		:= Chr(13) + Chr(10) 
if Empty(cNomeTXT)
	Return
EndIF

	IF _cTp == 1
		DbSelectArea("RCH")
		DbSetOrder(8)
		DbSeek(xFilial("RCH")+"00001"+"PLA"+"1")
		If !Found()    
			Alert("Não existe Roteiro PLA selecionado")
			Return    
		Else
			cPerAber	:= RCH->RCH_PER
		EndIf
		
		
	ENDIF
	
//	
//	DO while !FT_FEOF()
//		cVar   := FT_FREADLN()
//		aLinha := StrTokArr(cVar,"|")  
//		ProcRegua(Len(aRegMes))     
	
	FT_FGOTOP()
	
	FT_FSKIP()
	
	nTotSuss := 0
	nTotErr := 0
	
	nCount := 0
	_cErro := ''
	ProcRegua(2500)
	
	 while !FT_FEOF()

		IncProc("Processando arquivo. Linha "+ALLTRIM(STR(nCount)))
		
		nCount++   
		_cMat  := ''
		aValMat  := {}
		cImp	 := '2'
		nParc    := 0
		nLimSal  := 0
		
		nTotMat := 0
		
		nCol		:= 1   
		cVar   		:= FT_FREADLN()  
		cBloco1		:= carcEsp(cVar)
		cBloco2		:= ""
		nPos1		:= 0
		nPos2  		:= 0      
		cConteudo	:= ""   
		
		aLinha 	 := StrTokArr2(cBloco1,";", .t. )
		
		dbSelectArea('SN1')
		SN1->(DBSetORder(1))
		
		_cCContab := ''
		_cCdDepre := ''
		_cCCDep := ''
		
		cCodBase := PADR(PADL(aLinha[nColcBase],6,'0'),TamSx3("N3_CBASE")[1])
		cNumItm  := PADR(PADL(aLinha[nColItem],4,'0'),TamSx3("N3_ITEM")[1])
		
		IF !EMPTY(cCodBase)
			if (SN1->(DBSeek(xFilial('SN1')+cCodBase+cNumItm)))
				dbSelectArea('SN3')
				SN3->(DBSetORder(1))
				if (SN3->(DBSeek(xFilial('SN3')+cCodBase+cNumItm+'01')))
				
					_cCContab := SN3->N3_CCONTAB
					_cCdDepre := SN3->N3_CDEPREC
					_cCCDep := SN3->N3_CCDEPR
					
					SN3->(DBGoTop())
					
					if (SN3->(DBSeek(xFilial('SN3')+cCodBase+cNumItm+'10')))
						RecLock("SN3",.F.)
					else
						RecLock("SN3",.T.)
					endif	
					
					SN3->N3_FILIAL := xFilial('SN3')
					SN3->N3_CBASE    := cCodBase
					SN3->N3_FILIAL   := PADL(aLinha[nColFil],2,'0')
					SN3->N3_ITEM     := cNumItm 
					SN3->N3_TIPO     := aLinha[nColTipo]
					SN3->N3_BAIXA    := aLinha[nColBx]
					SN3->N3_HISTOR   := aLinha[nColHist]
					SN3->N3_CCONTAB  := _cCContab
					SN3->N3_CDEPREC  := _cCdDepre
					SN3->N3_CCDEPR   := _cCCDep
					SN3->N3_DINDEPR  := CTOD(aLinha[nColdIndep])
					SN3->N3_VORIG1   := VAL(tratValo(aLinha[nColvOrig]))
					SN3->N3_TXDEPR1  := VAL(tratValo(aLinha[nColTxDp]))
					SN3->N3_VRDACM1  := VAL(tratValo(aLinha[nColVdrCm]))
					SN3->N3_AQUISIC  := CTOD(aLinha[nColAqs])
					SN3->N3_TPDEPR   := aLinha[nColTpDep]
					SN3->N3_TPSALDO  := aLinha[nColTpSld]
					
					SN3->(msUnlock())
					
				ELSE
					_cErro += 'Ativo não possui saldo do tipo 01 - '+aLinha[nColcBase]+cLFRC
				ENDIF
				
			ELSE
				_cErro += 'Ativo não encontrado - '+aLinha[nColcBase]+cLFRC
			ENDIF
		ENDIF
		
		FT_FSKIP()
	Enddo 

Return       

STATIC function getCodigo()
	Local cCodigo := GETSX8NUM("ZZM","ZZM_CODIGO")
	
	//Valida se o código está sendo usado.
	dbSelectArea('ZZM')
	ZZM->( dbSetOrder(2) )
	IF ZZM->( dbSeek( xFilial("ZZM") + cCodigo ) )
		//Enquanto encontrar código, pega um novo. Até q encontre 1 q não existe
		while ZZM->( dbSeek( xFilial("ZZM") + cCodigo ) )
			cCodigo := GETSX8NUM("ZZM","ZZM_CODIGO")
		enddo
	endif
	
return cCodigo

static function gravaLog(_cod,_cFilial,cPer,cAno,cPrest,cAtend,dDtAten, cBenef, cMatric, cCodEx, nValor, cArqui, nLinha, cConteud, cCodUsu,cTitular,cItem)
	
	RecLock("ZZM",.T.)
	ZZM->ZZM_FILIAL := _cFilial
	ZZM->ZZM_CODIGO := _cod
	ZZM->ZZM_DATA   := date()
	ZZM->ZZM_HORA   := time()
	ZZM->ZZM_PERIOD := cPer
	ZZM->ZZM_ANO    := cAno
	ZZM->ZZM_PREST  := cPrest
	ZZM->ZZM_ATEND  := cAtend
	ZZM->ZZM_DTATEN := dDtAten
	ZZM->ZZM_BENEF  := cBenef
	ZZM->ZZM_MATRIC := cMatric
	ZZM->ZZM_CODEXA := cCodEx
	ZZM->ZZM_VALOR  := nValor
	ZZM->ZZM_ARQUIV := cArqui
	ZZM->ZZM_LINHA  := nLinha
	ZZM->ZZM_CONT   := cConteud
	ZZM->ZZM_USU    := cCodUsu
	ZZM->ZZM_TITUL  := cTitular
	ZZM->ZZM_ITEM   := cItem
	
	ZZM->(msUnlock())
	ConfirmSX8() 
	
return _Cod

static function tratValo(cNum)

cNum := StrTran(cNum,'.','')
cNum := StrTran(cNum,',','.')

return cNum

static function gravaPartic(_cFilial,_cMat,cCodDep,nVal,_cPerAux)
Local cVerbTit := SUPERGETMV('TCP_VRBUN1', .T., '436')
Local cVerbDep := SUPERGETMV('TCP_VRBUN2', .T., '438')
Local dDtOcorr := _cPerAux+'01'

_cOrigem  := '1'
_cTpForn  := '1'
_cCodFor  := '003'
_cTpPlan  := '1'
if empty(cCodDep)
	_cCodPd   := cVerbTit
	_cOrigem  := '1'
else
	_cCodPd   := cVerbDep
	_cOrigem  := '2'
endif

//DbSelectArea("RHO")
//DbSetOrder(3)
//DbGoTop()
//DbSeek(QRY->RB_FILIAL+QRY->RB_MAT+cPeriodo+"01"+"1"+"003"+"2"+QRY->RB_COD+"438"+cPeriodo) 
//RHO_FILIAL+RHO_MAT+DTOS(RHO_DTOCOR)+RHO_TPFORN+RHO_CODFOR+RHO_ORIGEM+RHO_CODIGO+RHO_PD+RHO_COMPPG                                                               
//RHO_FILIAL+RHO_MAT+DTOS(RHO_DTOCOR)+RHO_TPFORN+RHO_CODFOR+RHO_ORIGEM+RHO_PD+RHO_COMPPG                                                                          
	DbSelectArea("RHO")
	RHO->(DbSetOrder(1))
	RHO->(DbGoTop())
	If RHO->(DbSeek(_cFilial+_cMat+dDtOcorr+_cTpForn+_cCodFor+_cOrigem+_cCodPd+_cPerAux+ PADR(cCodDep,TamSx3("RHO_CODIGO")[1]))) 
		RecLock("RHO",.f.)   
		RHO->RHO_VLRFUN	:= nVal
		MsUnLock()
	Else  
		RecLock("RHO",.t.)   
		RHO->RHO_FILIAL	:= _cFilial
		RHO->RHO_MAT	:= _cMat
		RHO->RHO_DTOCOR	:= Stod(dDtOcorr)
		RHO->RHO_ORIGEM	:= _cOrigem
		RHO->RHO_TPFORN	:= _cTpForn
		RHO->RHO_CODFOR	:= _cCodFor
		RHO->RHO_CODIGO	:= cCodDep
		RHO->RHO_TPLAN	:=_cTpPlan
		RHO->RHO_PD		:= _cCodPd
		RHO->RHO_VLRFUN	:= nVal
		RHO->RHO_COMPPG	:= _cPerAux
		RHO->(MsUnLock())
	EndIf

return

static function atuLog(_cFil,cCod,cImp,cMat,cParc,_cErro,cItem)
	DbSelectArea("ZZM")
	ZZM->(DbSetOrder(2))
	ZZM->(DbGoTop())
	If ZZM->(DbSeek(_cFil+cCod+cItem)) 
		RecLock("ZZM",.F.)
		ZZM->ZZM_ERRO   := _cErro
		ZZM->ZZM_IMP    := cImp
		ZZM->ZZM_MAT    := cMat
		ZZM->ZZM_PARC   := cParc
		ZZM->ZZM_ITEM   := cItem
		ZZM->(msUnlock())
	endif
return

STATIC function nextPer(cPerAtu)

	_cMes := substr(cPerAtu,5,2)
	_cAno := substr(cPerAtu,1,4)
	
	if(VAL(_cMes)+ 1 >= 13)
		cPerAtu := 	ALLTRIM(STR(VAL(_cAno)+1))+'01'
	else
		cPerAtu := 	_cAno+PADL(ALLTRIM(STR(VAL(_cMes)+1)),2,'0')
	endif

return cPerAtu

static function carcEsp(cTxt)
   Local _sRet := cTxt
	_sRet := StrTran (_sRet, "'", "")
   _sRet := StrTran (_sRet, '"', "")
   _sRet := StrTran (_sRet, "º", ".")
   _sRet := StrTran (_sRet, "ª", ".")
   _sRet := StrTran (_sRet, "&", "e")
   _sRet := StrTran (_sRet, "|", "")
   _sRet := StrTran (_sRet, "\", " ")
   _sRet := StrTran (_sRet, "/", " ")
   _sRet := StrTran (_sRet, "<", " ")
   _sRet := StrTran (_sRet, ">", " ")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   _sRet := StrTran (_sRet, 'ï»¿', "") // TAB
return _sRet

static function trataValor(cValor)
Local nVal

nVal := strTran(cValor,"R$","") 
nVal := Val(StrTran(nVal,",",".")) 

return nVal

static function gravaVinc(cMatric,cTitular,cBenefic,_cCpfPes,cNomBenef)
Local lErro := .F.

If cBenefic==cTitular	
	DbSelectArea("SRA")
	DbSetOrder(1)
	DbSeek(xFilial("SRA")+StrZero(Val(cMatric),6,0))  // PROCURA PELA MATRICULA
	If Found()   
		RecLock("SRA",.f.) 
		SRA->RA_XUNIMED	:= cTitular
		SRA->(MsUnLock())     
	ElseIF _cCpfPes!= ''
		DbSelectArea("SRA")
		DbSetOrder(5)
		DbSeek(xFilial("SRA")+StrZero(Val(_cCpfPes),11,0))  // SE NÃO ENCONTRAR PELA MATRICULA, PROCURA PELO CPF
		If Found()   
			RecLock("SRA",.f.) 
			SRA->RA_XUNIMED	:= cTitular
			SRA->(MsUnLock()) 
		Else
			lErro := .T.
		EndIf  
	ELSE
	 	lErro := .T.
	EndIf 
Else
    cQuery := " SELECT *"
    cQuery += " FROM " + RetSQLName("SRB") + " SRB "
  	cQuery += " WHERE SRB.D_E_L_E_T_ <> '*' "
	cQuery += "   AND SRB.RB_FILIAL = '"+xFilial("SRB")+"' " 
	cQuery += "   AND (SRB.RB_MAT	= '"+StrZero(Val(cMatric),6,0)+"' OR SRB.RB_CIC	= '"+StrZero(Val(_cCpfPes),11,0)+"' )" 
	cQuery += "   AND SUBSTRING(SRB.RB_NOME,1,7) = '"+UPPER(SubStr(cNomBenef,1,7))+"' " 	
	
	If Select('QRY2')<>0
		QRY2->(DBCloseArea()) 				
	EndIF
	
	TcQuery cQuery new Alias "QRY2"   
	DbSelectArea("QRY2")
	DbGoTop()
	If Eof()       
		lErro := .T.
	Else
		DbSelectArea("SRB")
		DbSetOrder(1)
		DbSeek(QRY2->RB_FILIAL+QRY2->RB_MAT+QRY2->RB_COD)
		If Found()   
			RecLock("SRB",.f.)
			SRB->RB_XUNIMED	:= cBenefic
			SRB->(MsUnLock())
		EndIf
	EndIf						                            
	DbSelectArea("QRY2")
	DbCloseArea()		
EndIf

return lErro