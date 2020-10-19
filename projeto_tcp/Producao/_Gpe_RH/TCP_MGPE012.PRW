#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MGPE010
Importaca de Lançamento de folha
Rotina que importa arquivo CSV para Lançamento de folha,
SR1

@author Felipe Calderia
@version P11
@since 15/12/2016
@return nil
/*/
//-------------------------------------------------------------------

User Function MGPE012()

Local cArqTxt 	:= Space(200)
Local cMsgLog	:= "" 
Local aPergs	:= {}
Local aRet		:= {}

Private cHorInic 		:= Time()
Private lMsHelpAuto 	:= .T.
Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile 	:= .T.

aAdd( aPergs ,{6,"Arquivo",cArqTxt,"",,"", 90 ,.T.,"Arquivos .CSV |*.CSV","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

If ParamBox(aPergs ,"Parâmetros ",aRet)   
	cArqTxt := Alltrim(aRet[1])  
	  
	
	If !Empty(cArqTxt) 
		If File(cArqTxt)
			Processa( { || ImpArq( cArqTxt, @cMsgLog ) }, "Aguarde...", "Verificando arquivos...",.T.) 
		Else 
			cMsgLog += "Arquivo não encontrado!"+chr(13)+chr(10)		 
		EndIf
	Else
		cMsgLog += "Arquivo não informado!"+chr(13)+chr(10)
	EndIf
EndIf

If !Empty(cMsgLog)     

	cMsgLog += Replicate("-",60)+chr(13)+chr(10)
	cMsgLog += "  Final de Arquivo"+chr(13)+chr(10)    
	cMsgLog += Replicate("-",60)   
	
	TelaLog(cMsgLog)
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpArq
Processa arquivo

@author Thiago Henrique dos Santos
@version P11
@since 21/01/2016
@param 	cArqTxt - Caminho do Arquivo csv
		cMsgLog - Log de Processamento
		lExclui - .T. para exlcluir Lançamentos 
				  para a mesma verba e matricula
@return nil
/*/
//-------------------------------------------------------------------

Static Function ImpArq(cArqTxt,cMsgLog)
Local cLinha 	:= ""
Local aLinha 	:= {}
Local nTotLin	:= 0
Local cCodMat 	:= ""
Local cVerba	:= ""
Local nValor	:= 0  
Local lRetOK 	:= .T.
Local cMsgTmp	:= ""
Local nTotExc	:= 0   
Local nTotInc	:= 0
Local nM		:= 0
Local aProc		:= {}
Local nI

DbSelectArea("SRA")
SRA->(DbSetOrder(1)) // RA_FILIAL+RA_MAT

DbSelectArea("SRV")
SRV->(DbSetOrder(1)) // RV_FILIAL+RV_COD

ProcRegua(0)

If File( cArqTxt )

	FT_FUse(cArqTxt ) 	// abre o arquivo
	FT_FGOTOP()     	// posiciona na primeira linha do arquivo
	
	
	ProcRegua(FT_FLASTREC())
	
	
	While !FT_FEOF()

		IncProc("Validando Arquivo...")
	
		cLinha := FT_FREADLN() 		
		aLinha := Separa(cLinha,';',.T.) 
		
		If !Empty(aLinha) .AND. Len(aLinha) <> 7  
			cMsgLog += "Layout do arquivo inválido!"+chr(13)+chr(10)  
			lRetOk := .F.        
			Exit
		EndIf 
		
		If !Empty(aLinha) 
			nTotLin++	
			
			cFil 	:= PadL(AllTrim(aLinha[1]),TamSx3("RA_FILIAL")[1],"0")
			cCodMat := PadL(AllTrim(aLinha[2]),TamSx3("RA_MAT")[1],"0")
			cVerba 	:= PadL(AllTrim(aLinha[3]),TamSx3("RC_PD")[1],"0")
			cTmp := StrTran(aLinha[5],".","")
			cTmp := StrTran(cTmp,",",".")
			nValor 	:= Val(cTmp)		
			dData 	:= CtoD(AllTrim(aLinha[6]))
			cCC 	:= PadL(AllTrim(aLinha[7]),6,"0")
			
			
			If !SRV->(DbSeek(xFilial("SRV")+cVerba)) 
			
		   		cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Verba: "+cVerba+chr(13)+chr(10) 
				cMsgLog += "Código da Verba não encontrada no cadastro de Verbas."+chr(13)+chr(10) 
				
			ElseIf !SRA->(DbSeek(xFilial("SRA")+cCodMat))        
			    
		   		cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 
				cMsgLog += "Código da Matrícula não encontrada no cadastro de Funcionários."+chr(13)+chr(10) 
				
			ElseIf SRA->RA_SITFOLH == "D" .AND. !Empty(SRA->RA_DEMISSA)   
				
				cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 		
				cMsgLog += "Funcionário com Status Demitido."+chr(13)+chr(10)

            Else
            
            	AAdd(aProc,{cFil,cCodMat,cVerba,nValor,dData,cCC})
            	
            Endif
            
					 
	 	EndIf
		
		FT_FSKIP()   
		
	EndDo
	
	FT_FUse()
	 
	
	
	If lRetOk .AND. !Empty(aProc)
	
		ProcRegua(len(aProc))
				
			For nI := 1 to len(aProc)
								
				IncProc("Importando Dados...")
	
				RecLock('SR1',.T.)
				SR1->R1_FILIAL	:= aProc[nI][1]
				SR1->R1_MAT 	:= aProc[nI][2]
				SR1->R1_PD 		:= aProc[nI][3]
				SR1->R1_TIPO1 	:= 'V'
				SR1->R1_VALOR 	:= aProc[nI][4]
				SR1->R1_DATA 	:= aProc[nI][5]
				SR1->R1_CC 		:= aProc[nI][6]
				SR1->R1_TIPO2 	:= 'I' 
				MsUnlock()
				
				nTotInc++
		
							
			Next nI		   	
				
	Endif
	
	
	cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
	cMsgLog += "Total de itens incluídos: "+cValToChar(nTotInc)+chr(13)+chr(10)
	cMsgLog += Replicate("-",60)+chr(13)+chr(10)+chr(13)+chr(10)  
	cMsgLog += Replicate("-",60)+chr(13)+chr(10)
	cMsgLog += "Total Linhas no arquivo: "+cValToChar(nTotLin)+chr(13)+chr(10)
	 
	
	

Else

	cMsgLog += "Arquivo não encontrado!"+CRLF

Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TelaLog
Exibe log

@author Thiago Henrique dos Santos
@version P11
@since 21/01/2016
@param 	cMsgLog - Log de Processamento

@return nil
/*/
//-------------------------------------------------------------------
Static Function TelaLog(cMsg)

	Local  cMask	:= "Arquivos Texto (*.TXT) |*.txt|"
	Local _cFile	:= ""  
	
	cMsg := "Importação Lançamento Folha (MGPE010) " + CHR(13)+CHR(10)+"Data: " + DtoC(Date())+;
				" Hora Inicio: "+cHorInic+" Hora Fim: "+Time()+CHR(13)+CHR(10)+ cMsg
          
	// TELA PARA MOSTRAR O LOG E DAR OPÇÃO DE SALVAR O LOG
	__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cMsg)
	DEFINE FONT oFont NAME "Mono AS" SIZE 6,15  
	DEFINE MSDIALOG oDlg TITLE "Integração concluida." From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo  VAR cMsg MEMO SIZE 200,145 OF oDlg READONLY PIXEL 
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (_cFile:=cGetFile(cMask,""),If(_cFile="",.t.,MemoWrite(_cFile,cMsg))) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER
	
Return