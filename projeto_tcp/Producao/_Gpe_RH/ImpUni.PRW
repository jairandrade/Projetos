#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "Directry.ch"  

User function ImpUni() 

Private nColBen		:= 0
Private nColNomB	:= 0
Private nColMatr	:= 0
Private nColTit		:= 0
Private nColNomT	:= 0
Private nColValor	:= 0
Private nColAtend	:= 0
Private nColDtAte	:= 0
Private nColCod		:= 0
Private nColPrest 	:= 0
Private nColAno		:= 0
Private nColPer 	:= 0
Private nColCPF     := 0
Private lErrValid 	:= .f.
Private nHandle 
Private nTotalLin   := 10000
cTipo := "Arquivos Texto  (*.CSV)  | *.CSV | "
cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))

if !empty(cNomeTXT)

	nHandle := FT_FUSE(cNomeTXT)
	
	if nHandle < 0
		Alert("Erro ao abrir o arquivo de texto!")
		Return .F.
	endif
	
	Processa( {|| impArq(cNomeTXT,1) }, "Aguarde...", "Validando planilha...",.F.)   
	
	if !lErrValid 
		Processa( {|| impArq(cNomeTXT,2) }, "Aguarde...", "Importando cooparticipação...",.F.)   
	endif 
	
	FT_FUSE()  
	
endif

RETURN

STATIC function impArq(cNomeTXT, _cTp)
Local cQuery	:= ""

Local aRegMes   := {}
Local nCount	:= 0
Local cNome		:= Space(40)
Local cMat		:= Space(6)

Local cNomeArq	:= ""
Local cArquivo	:= ""    

Local nPos1		:= 0
Local nPos2		:= 0

Local cPeriodo	:= ""    

Local nCol		:= 0    
Local cBloco1	:= ""
Local cBloco2	:= ""    
Local cConteudo	:= ""    

Local cBenefic	:= ""
Local cNomBenef	:= ""
Local cTitular	:= ""
Local _cCpfPes	:= ""
Local cNomTitul	:= ""
Local cMatric	:= ""
Local cValor	:= ""     


Local lLayout := .T.
Local nTotUni	:= 0         
Local cUsrLg    := RetCodUsr()
Local cPeriodo	:= Space(6)
Local nValLim1   := SUPERGETMV("TCP_UNMLM1", .T., 200)  
Local nValLim2   := SUPERGETMV("TCP_UNMLM2" ,.T., 500)      
Local nPercSal   := SUPERGETMV("TCP_UNMPER" ,.T., 40)              
Local lTmpVal   := .f.
Local _cOrigem  := ''
Local _cTpForn  := ''
Local _cCodFor  := ''
Local _cCodDep  := ''
Local _cTpPlan  := ''
Local _cCodPd   := ''
Local nValParc := 0
Local aValMat  := {}
Local cAliasAx
Local cPrimCod := ''
Local cItem   := ''
Local nInd2
Local nInd
Local _cTxtProc :='Validando planilha'

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
	
	nCol		:= 1 
	cVar   		:= FT_FREADLN()   
	cBloco1		:= carcEsp(cVar)  
	cBloco2		:= ""
	nPos1		:= 0
	nPos2  		:= 0      
	cConteudo	:= ""   
	//fAZ Isso só durante a validação
	IF _cTp == 1
		IncProc("Lendo Cabeçalho... ")
		While !EMPTY(cBloco1)    
   			nPos1  	   		:= AT(";",cBloco1) 
			cConteudo 		:= SubStr(cBloco1,1,nPos1-1)  
			
			If AllTrim(cConteudo)=="BENEFICIARIO"
				nColBen		:= nCol
			EndIf
			If AllTrim(cConteudo)=="NOME"
				nColNomB	:= nCol
			EndIf
			If AllTrim(cConteudo)=="MATRICULA"
				nColMatr	:= nCol
			EndIf
			If AllTrim(cConteudo)=="TITULAR"
				nColTit		:= nCol
			EndIf
			If AllTrim(cConteudo)=="NM_TITULAR"
				nColNomT	:= nCol
			EndIf
			If AllTrim(cConteudo)=="VALOR_COBRAR"
				nColValor	:= nCol
			EndIf
			If AllTrim(cConteudo)=="ATENDIMENTO"
				nColAtend	:= nCol
			EndIf
			If AllTrim(cConteudo)=="DT_ATEND"
				nColDtAte	:= nCol
			EndIf
			If AllTrim(cConteudo)=="CODIGO"
				nColCod	:= nCol
			EndIf
			If AllTrim(cConteudo)=="CD_PREST_CRED"
				nColPrest	:= nCol
			EndIf
			If AllTrim(cConteudo)=="PERIODO"
				nColPer	:= nCol
			EndIf
			If AllTrim(cConteudo)=="ANO"
				nColAno	:= nCol
			EndIf
			If AllTrim(cConteudo)=="CPF"
				nColCPF		:= nCol
			EndIf
			
			nCol++
			If nCol==50
				Exit
			EndIf  
			cBloco2		:= SubStr(cBloco1,nPos1+1,Len(cBloco1)-nPos1) 	
			cBloco1		:= ""
			cBloco1		:= cBloco2  
			cBloco2		:= ""	
		Enddo
	else
		_cTxtProc := 'Importando cooparticipação'
	ENDIF
		
	FT_FSKIP()
	
	nTotSuss := 0
	nTotErr := 0
	
	//Ignorar o cabeçalho
	nCount := 1
	
	IF nColBen ==0 .OR. nColMatr == 0 .OR. nColTit == 0 .OR. nColNomT == 0 .OR. nColValor == 0 .OR. nColNomB == 0 .OR. nColPrest == 0 .OR. nColCod == 0;
	.OR. nColDtAte == 0 .OR. nColAtend == 0 .OR. nColAno == 0 .OR. nColPer == 0
		MsgInfo("Layout do arquivo inválido.")
		return
	ENDIF
	
	_cCodLog := getCodigo()
	
	ProcRegua(nTotalLin)
	
	 while !FT_FEOF()

		IncProc(_cTxtProc+". Linha "+ALLTRIM(STR(nCount))+if(_cTp != 1 ,'. Total Linhas: '+ALLTRIM(STR(nTotalLin)),''))
		
		nCount++   
		_cErro := ''
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
		
		if len(aLinha) >= nColValor
			cPeriodo := aLinha[nColPer]
			cAno 	 := aLinha[nColAno]
			cPrest 	 := PADR(aLinha[nColPrest],TamSx3("ZZM_PREST")[1])
			cAtend 	 := PADR(aLinha[nColAtend],TamSx3("ZZM_ATEND")[1]) 
			dDtAten  := CTOD(aLinha[nColDtAte])
			cTitular := aLinha[nColTit]
			cTitular := PADR(aLinha[nColTit],TamSx3("ZZM_TITUL")[1]) 
			cBenefic := PADR(aLinha[nColBen],TamSx3("ZZM_BENEF")[1]) 
			cMatric  := PADL(aLinha[nColMatr],TamSx3("ZZM_MATRIC")[1],'0') 
			cCodEx 	 := PADR(aLinha[nColCod],TamSx3("ZZM_CODEXA")[1]) 
			_cValor 	 := aLinha[nColValor]
			nValor 	 := trataValor(aLinha[nColValor]) 
			cNomTitul:= ALLTRIM(aLinha[nColNomT])
			cNomBenef:= ALLTRIM(aLinha[nColNomB]) 
			_cCpfPes := if(nColCPF > 0 ,PADR(ALLTRIM(aLinha[nColCPF]),TamSx3("ZZM_CPF")[1]) ,'') 
			cArqui 	 := cNomeTXT
			nLinha 	 := nCount
			cItem    := PADL(ALLTRIM(STR(nLinha)), 6    , '0' )
			cConteud := cBloco1
			cCodUsu	 := cUsrLg
			_cFilial := '  '
			lTmpVal   := .f.
			
			//Tratamento para linha em branco, e para a útlima linha com totalizadores
			if !EMPTY(cBenefic) .AND. !EMPTY(cTitular) .AND. !EMPTY(cCodEx)
			
				If cBenefic==cTitular	
							
					cQuery := " SELECT '  ' as RB_COD, RA_FILIAL,RA_MAT,RA_SALARIO "
				    cQuery += " FROM " + RetSQLName("SRA") + " SRA "
				  	cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' "
					cQuery += "   AND SRA.RA_XUNIMED	= '"+cTitular+"' " 
					
				ELSE
					cQuery := " SELECT RB_COD, RA_FILIAL,RA_MAT,RA_SALARIO "
				    cQuery += " FROM " + RetSQLName("SRB") + " SRB "
				    cQuery += " INNER JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_MAT=SRB.RB_MAT AND SRB.D_E_L_E_T_ <> '*' "
				  	cQuery += " WHERE SRB.D_E_L_E_T_ <> '*' "
					cQuery += " AND SRB.RB_XUNIMED 	= '"+cBenefic+"' " 
					
				ENDIF
				
				If Select('QRY')<>0
					QRY->(DBCloseArea()) 				
				EndIF
				
				TcQuery cQuery new Alias "QRY"   
				DbSelectArea("QRY")
				QRY->(DbGoTop()) 
				If QRY->(Eof()) 
				
					If cBenefic==cTitular	
						_cErro := "Títular não encontrado - "+cTitular+" - "+UPPER(cNomTitul)
						lErrValid := .t.
					ELSE
						_cErro := "Dependente não encontrado - "+cBenefic+" - "+UPPER(cNomBenef)+ " -> " + UPPER(cNomTitul)
						lErrValid := .t.
					ENDIF
					
				else
					_cFilial := QRY->RA_FILIAL
				endif
				
				gravaLog(_cCodLog,_cFilial,cPeriodo,cAno,cPrest,cAtend,dDtAten, cBenefic, cMatric, cCodEx, nValor, cArqui, nLinha, cConteud, cCodUsu,cTitular,cItem)
				
//				if(empty(cPrimCod))
//					cPrimCod := _cCodLog
//				endif
				
				if empty(_cErro)
			//		ZZM_FILIAL+ZZM_PREST+ZZM_ATEND+ZZM_DTATEN+ZZM_BENEF+ZZM_MATRIC+ZZM_CODEXA+ZZM_VALOR 
					dbSelectArea('ZZM')
					ZZM->( dbSetOrder(1) )
					
					cAliasAx := getNextAlias()
			
					BeginSQL Alias cAliasAx
						 
					 SELECT *
					 FROM %TABLE:ZZM% ZZM
					 WHERE ZZM.%NotDel%  AND ZZM_FILIAL = %EXP:_cFilial% AND ZZM_PREST = %EXP:cPrest% AND ZZM_ATEND = %EXP:cAtend%
					   AND ZZM_DTATEN = %EXP:DTOS(dDtAten)%  AND ZZM_BENEF = %EXP:cBenefic%  AND ZZM_MATRIC = %EXP:cMatric%  
					   AND ZZM_CODEXA = %EXP:cCodEx% AND ZZM_VALOR = %EXP:STR(nValor,14,2)%  AND ZZM_IMP = '1'  
					   AND ZZM_CODIGO != %EXP:_cCodLog% 
					EndSQL
					
//					CONOUT(GETLASTQUERY()[2])
					
//					WHILE !(cAliasAx)->(Eof())
//						_nValTmp := (cAliasAx)->valorTotal
//						if ALLTRIM((cAliasAx)->RHO_CODIGO) == ALLTRIM(QRY->RB_COD)
//							_nValTmp += nValor
//							lTmpVal   := .T.
//						ENDIF
//						AAdd(aValMat,{(cAliasAx)->RHO_CODIGO,_nValTmp})
//						nTotMat += (cAliasAx)->valorTotal
//						
//						(cAliasAx)->(DBSkip())
//					ENDDO
//					
					
					IF (cAliasAx)->(Eof())
					
						If nValor > 0	
								
							_cMat := QRY->RA_MAT
							
							//Consulta o valor em aberto para os próximos meses.
							cAliasAx2 := getNextAlias()
			
							BeginSQL Alias cAliasAx2
								 
							 SELECT SUM(RHO_VLRFUN) as valorTotal, RHO_CODIGO
							 FROM %TABLE:RHO% RHO
							 WHERE RHO.%NotDel%  AND RHO_MAT= %EXP:_cMat% AND RHO_COMPPG >= %EXP:cPeriodo% AND RHO_FILIAL = %EXP:QRY->RA_FILIAL%
							 GROUP BY RHO_CODIGO
							EndSQL
							
							WHILE !(cAliasAx2)->(Eof())
								_nValTmp := (cAliasAx2)->valorTotal
								if ALLTRIM((cAliasAx2)->RHO_CODIGO) == ALLTRIM(QRY->RB_COD)
									_nValTmp += nValor
									lTmpVal   := .T.
								ENDIF
								AAdd(aValMat,{(cAliasAx2)->RHO_CODIGO,_nValTmp})
								nTotMat += (cAliasAx2)->valorTotal
								
								(cAliasAx2)->(DBSkip())
							ENDDO
							
							IF !lTmpVal
								AAdd(aValMat,{QRY->RB_COD,nValor})
							ENDIF			
										
							nTotMat += nValor
							
							if(nTotMat <= nValLim1)
								nParc := 1
							elseif(nTotMat > nValLim1 .AND. nTotMat <= nValLim2)
								nParc := 2
							else	
								nLimSal := 	(QRY->RA_SALARIO * nPercSal) / 100
								nParc := nTotMat / nLimSal		
								if (nParc < 3)
									nParc := 3
								endif		
							endif
							
							//Durante a validação não grava
							if _cTp != 1
								_cPerAux := cPeriodo
								for nInd := 1 to nParc
									for nInd2 := 1 to LEN(aValMat)
										gravaPartic(QRY->RA_FILIAL,_cMat,aValMat[nInd2][1],aValMat[nInd2][2]/nParc,_cPerAux)
									next
									
									_cPerAux := nextPer(_cPerAux)
								next
								
								cImp := '1'
							endif	
							
							(cAliasAx2)->(dbclosearea())
							
						else
							//Isso não se caracteriza erro, pois quando o exame não tem valor, vem assim.
							if alltrim(_cValor) != "R$ -"
								lErrValid := .t.
								_cErro := 'Valor do exame inválido. Valor: '+alltrim(aLinha[nColValor])
								cImp := '1'
							endif
							
						EndIf
					ELSE
						lErrValid := .t.
						_cErro := 'Registro já importado.'
					endif
					
					(cAliasAx)->(dbclosearea())
					
				endif
				
				
				if(cImp == '1')
					nTotSuss++
				else
					nTotErr++
				endif
				
				atuLog(_cFilial,_cCodLog,cImp,_cMat,nParc,_cErro,cItem )
			ENDIF
		endif
		
		FT_FSKIP()
	End 


IF _cTp == 1 .AND. lErrValid
	MsgAlert("Foram identificados erros durante a importação. Verifique o log, corrija-os e reimporte a planilha.")
	
	if !empty(_cCodLog)
		u_RELIMPUN(_cCodLog)
	endif
	
ELSEIF _cTp != 1

	MsgAlert("Concluído. Importados com Sucesso: "+ALLTRIM(Str(nTotSuss))+ ' Erro ao importar: '+ALLTRIM(Str(nTotErr)))
	
	if !empty(_cCodLog)
		u_RELIMPUN(_cCodLog)
	endif
ENDIF

nTotalLin := nCount

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
	
	if !empty(_cCpfPes)
		DbSelectArea("SRA")
		SRA->(DbSetOrder(5))
		IF SRA->(DbSeek(xFilial("SRA")+StrZero(Val(_cCpfPes),11,0)))  
			RecLock("SRA",.f.) 
			SRA->RA_XUNIMED	:= cTitular
			SRA->(MsUnLock()) 
		else
			lErro := .t.
		ENDIF
	ELSE
		SRA->(DbSetOrder(1))
		IF SRA->(DbSeek(xFilial("SRA")+StrZero(Val(cMatric),6,0)))  // PROCURA PELA MATRICULA
	
			RecLock("SRA",.f.) 
			SRA->RA_XUNIMED	:= cTitular
			SRA->(MsUnLock())  
		else
			lErro := .t.
		ENDIF   
	EndIf 
Else
    cQuery := " SELECT *"
    cQuery += " FROM " + RetSQLName("SRB") + " SRB "
  	cQuery += " WHERE SRB.D_E_L_E_T_ <> '*' "
	cQuery += "   AND SRB.RB_FILIAL = '"+xFilial("SRB")+"' " 
	
	IF !EMPTY(cCPF)
		cQuery += "   AND ( SRB.RB_CIC	= '"+StrZero(Val(cCPF),11,0)+"' )" 
	ELSE
		cQuery += "   AND SUBSTRING(SRB.RB_NOME,1,7) = '"+UPPER(SubStr(cNomBenef,1,7))+"' AND SRB.RB_MAT	= '"+StrZero(Val(cMatric),6,0)+"'" 
	endif
	
//	cQuery += "   AND (SRB.RB_MAT	= '"+StrZero(Val(cMatric),6,0)+"' OR SRB.RB_CIC	= '"+StrZero(Val(_cCpfPes),11,0)+"' )" 
//	cQuery += "   AND SUBSTRING(SRB.RB_NOME,1,7) = '"+UPPER(SubStr(cNomBenef,1,7))+"' " 	
	
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