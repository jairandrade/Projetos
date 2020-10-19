#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "Directry.ch"  

User Function ImpUniC()


	Local cNomeTXT	:= ""
	Local cTipo := "Arquivos Texto  (*.CSV)  | *.CSV | "
	cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))
	
	Processa( {|| impArq(cNomeTXT,1) }, "Aguarde...", "Importando planilha...",.F.) 
	  
return
	
static function impArq(cNomeTXT)

	
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
	Local cNomTitul	:= ""
	Local cMatric	:= ""
	Local cCPF		:= "" 

	Local nColBen	:= 0
	Local nColNomB	:= 0
	Local nColMatr	:= 0
	Local nColTit	:= 0
	Local nColNomT	:= 0
	Local nColCPF	:= 0

	Local aErros    := {}

	if Empty(cNomeTXT)
		Return
	EndIF

	nHandle := FT_FUSE(cNomeTXT)

	if nHandle < 0
		Alert("Erro ao abrir o arquivo de texto!")
		Return .F.
	endif

	FT_FGOTOP()
	
	nCol		:= 1 
	cVar   		:= FT_FREADLN()   
	cBloco1		:= carcEsp(cVar)  
	cBloco2		:= ""
	nPos1		:= 0
	nPos2  		:= 0      
	cConteudo	:= ""   

	While .t.    
		nPos1  	   		:= AT(";",cBloco1) 
		cConteudo 		:= SubStr(cBloco1,1,nPos1-1)  
		If AllTrim(cConteudo)=="CD_BENEF"
			nColBen		:= nCol
		EndIf
		If AllTrim(cConteudo)=="NM_BENEF"
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
		If AllTrim(cConteudo)=="CPF"
			nColCPF		:= nCol
			Exit
		EndIf
		nCol++
		If nCol==50
			Exit
		EndIf  
		cBloco2		:= SubStr(cBloco1,nPos1+1,Len(cBloco1)-nPos1) 	
		cBloco1		:= ""
		cBloco1		:= cBloco2  
		cBloco2		:= ""			
	End

	FT_FSKIP()

	//Ignorar o cabeçalho
	nCount := 1
	
	ProcRegua(4000)
	
	While !FT_FEOF()

		IncProc("Processando arquivo... ")

		nCount++   

		nCol		:= 1   
		cVar   		:= FT_FREADLN()  
		cBloco1		:= carcEsp(cVar)
		cBloco2		:= ""
		nPos1		:= 0
		nPos2  		:= 0      
		cConteudo	:= ""   

		While .t.    
			nPos1  		:= AT(";",cBloco1) 
			cConteudo	:= SubStr(cBloco1,1,nPos1-1)  
			If nCol==nColBen  
				cBenefic 	:=  PADR(cConteudo,TamSx3("RA_XUNIMED")[1])
			EndIf
			If nCol==nColNomB 
				cNomBenef	:= cConteudo
			EndIf
			If nCol==nColMatr 
				cMatric  := PADR(cConteudo,TamSx3("ZZM_MATRIC")[1]) 
			EndIf
			
			If nCol==nColTit  
				cTitular 	:= PADR(cConteudo,TamSx3("RA_XUNIMED")[1])
			EndIf
			If nCol==nColNomT 
				cNomTitul	:= cConteudo
			EndIf
			If nCol==nColCPF 
				cCPF		:= trataNum(cConteudo )
			EndIf
			nCol++
			If nCol==35
				Exit
			EndIf  
			cBloco2		:= SubStr(cBloco1,nPos1+1,Len(cBloco1)-nPos1) 	
			cBloco1		:= ""
			cBloco1		:= cBloco2  
			cBloco2		:= ""			
		End
		
		cErro := ''
		
		if empty(cCPF)
			cErro += " CPF não preenchido. Titular - "+cTitular+" "+UPPER(cNomTitul)+" Matrícula: "+cMatric+IF(cTitular != cBenefic,' Dependente: '+UPPER(cNomBenef),'') +' CPF: '+cCPF
		else
			cErro += valCodigos(cBenefic,cTitular,cCPF)
		endif
		
		if !empty(cErro)
			aaDD(aErros,{cErro,nCount})
		else
			If cBenefic==cTitular	
			
				if !empty(cCPF)
					DbSelectArea("SRA")
					SRA->(DbSetOrder(5))
					IF SRA->(DbSeek(xFilial("SRA")+StrZero(Val(cCPF),11,0)))  
						RecLock("SRA",.f.) 
						SRA->RA_XUNIMED	:= cTitular
						SRA->(MsUnLock()) 
					ELSE
						aaDD(aErros,{"Não encontrado Titular - "+cTitular+" "+UPPER(cNomTitul)+" Matrícula: "+cMatric+' CPF: '+cCPF,nCount})
					ENDIF
				ELSE
					SRA->(DbSetOrder(1))
					IF SRA->(DbSeek(xFilial("SRA")+StrZero(Val(cMatric),6,0)))  // PROCURA PELA MATRICULA
				
						RecLock("SRA",.f.) 
						SRA->RA_XUNIMED	:= cTitular
						SRA->(MsUnLock())  
					ELSE
						aaDD(aErros,{"Não encontrado Titular - "+cTitular+" "+UPPER(cNomTitul)+" Matrícula: "+cMatric+' CPF: '+cCPF,nCount})
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
				ENDIF
//				cQuery += "   AND (SUBSTRING(SRB.RB_NOME,1,7) = '"+UPPER(SubStr(cNomBenef,1,7))+"' OR SRB.RB_CIC	= '"+StrZero(Val(cCPF),11,0)+"' )" 
//				cQuery += "   AND SRB.RB_MAT	= '"+StrZero(Val(cMatric),6,0)+"' " 	
				TcQuery cQuery new Alias "QRY"   
				DbSelectArea("QRY")
				DbGoTop()
				If Eof()     
					aaDD(aErros,{"Não encontrado Dep - "+cMatric+" "+UPPER(cNomBenef)+" Titular - "+cTitular+" "+UPPER(cNomTitul)+ " Matrícula: "+cMatric+" CPF: "+StrZero(Val(cCPF),11,0),nCount})  
				Else
					DbSelectArea("SRB")
					DbSetOrder(1)
					DbSeek(QRY->RB_FILIAL+QRY->RB_MAT+QRY->RB_COD)
					If Found()   
						RecLock("SRB",.f.)
						SRB->RB_XUNIMED	:= cBenefic
						MsUnLock()
					EndIf
				EndIf						                            
				DbSelectArea("QRY")
				DbCloseArea()		
			EndIf
		
		ENDIF
		
		FT_FSKIP()
	End 

	IF LEN(aErros) == 0
		MsgAlert("Concluído com sucesso. Total de funcionários: "+ALLTRIM(STR(nCount)))
	ELSE
		MsgAlert("Concluído com erros. Corrija-os e reimporte o arquivo.")
		impErros(aErros)
	ENDIF


	FT_FUSE()  

Return     

static function valCodigos(cBenefic,cTitular,cCPF)
Local cErro := ''

IF !validaCod(cBenefic)
	cErro += " Beneficiário inválido. "+cBenefic
ENDIF

IF !validaCod(cTitular)
	cErro += " Titular inválido. "+cTitular
ENDIF

IF !validaCod(cCPF)
	cErro += " CPF inválido. "+cCPF
ENDIF

return cErro

static function validaCod(cCodigo)

Local lValid := .T.
Local nvalTem := VAL(cCodigo)

IF ALLTRIM(cCodigo) != StrZero(nvalTem,LEN(ALLTRIM(cCodigo)),0)
	lValid := .F. 
ENDIF

return lValid 

static function impErros(aErros)

	Local oReport

	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		oReport := ReportDef(aErros)
		oReport:PrintDialog()
	EndIf

Return

Static Function ReportDef(aErros)

	Local oReport
	Local oSection

	oReport := TReport():New("IMPUNI","Erros de Importação",,{|oReport| PrintReport(oReport,aErros)},"Erros de importação.")
	oReport:SetLandscape()

	oSection := TRSection():New(oReport,,{})

	TRCell():New(oSection,"ERRO"  ,,"Erro","@!", 60)
	TRCell():New(oSection,"LINHA"  ,,"Linha")

Return oReport

Static Function PrintReport(oReport,aErro)

	Local oSection := oReport:Section(1)
	lOCAL i
	oReport:SetMeter(Len(aErro))

	oSection:Init()

	For i:=1 to Len(aErro)

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		oSection:Cell("ERRO"):SetValue(aErro[i,1])
		oSection:Cell("LINHA"):SetValue(ALLTRIM(STR(aErro[i,2])))
		oSection:PrintLine()
	Next i

	oSection:Finish()

Return


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

static function trataNum(cTxt)
   Local _sRet := cTxt
	_sRet := StrTran (_sRet, "-", "")
	_sRet := StrTran (_sRet, ".", "")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   _sRet := StrTran (_sRet, 'ï»¿', "") // TAB
return _sRet