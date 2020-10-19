#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MGPE010
Importaca de Lançamento de folha
Rotina que importa arquivo CSV para Lançamento de folha,
SRC, através do execauto GPEA090

@author Thiago Henrique dos Santos
@version P11
@since 21/01/2016
@return nil
/*/
//-------------------------------------------------------------------

User Function MGPE010()

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

DbSelectArea("SRC")
SRC->(DbSetOrder(1)) // // RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ

ProcRegua(0)

If File( cArqTxt )

	FT_FUse(cArqTxt ) 	// abre o arquivo
	FT_FGOTOP()     	// posiciona na primeira linha do arquivo
	
	
	ProcRegua(FT_FLASTREC())
	
	
	While !FT_FEOF()

		IncProc("Validando Arquivo...")
	
		cLinha := FT_FREADLN() 		
		aLinha := Separa(cLinha,';',.T.) 
		
		If !Empty(aLinha) .AND. Len(aLinha) <> 3  
			cMsgLog += "Layout do arquivo inválido!"+chr(13)+chr(10)  
			lRetOk := .F.        
			Exit
		EndIf 
		
		If !Empty(aLinha) .AND. !("VERBA" $ Upper(aLinha[1])) 
		
			nTotLin++			
			cVerba 	:= PadL(AllTrim(aLinha[1]),TamSx3("RC_PD")[1],"0")
			cCodMat := PadL(AllTrim(aLinha[2]),TamSx3("RA_MAT")[1],"0")
			cTmp := StrTran(aLinha[3],".","")
			cTmp := StrTran(cTmp,",",".")
			nValor 	:= Val(cTmp)		
			
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
				/*
			ElseIf SRA->RA_SITFOLH == "F"  
				
				cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 		
				cMsgLog += "Funcionário com Status Férias."+chr(13)+chr(10)  
		   
			ElseIf SRA->RA_SITFOLH == "A"  
				
				cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 		
				cMsgLog += "Funcionário com Status Afastado."+chr(13)+chr(10)  
				*/
            Else
            
            	AAdd(aProc,{cCodMat,cVerba,nValor})
            	
            Endif
            
					 
	 	EndIf
		
		FT_FSKIP()   
		
	EndDo
	
	FT_FUse()
	 
	
	
	If lRetOk .AND. !Empty(aProc)
	
		ProcRegua(len(aProc))
		
		
	
		
			For nI := 1 to len(aProc)
				
				
				IncProc("Importando Dados...")
	
				cCodMat := aProc[nI][1]
				cVerba := aProc[nI][2]
				nValor := aProc[nI][3]
				
				SRA->(DbSeek(xFilial("SRA")+cCodMat))
				
            	aCabec		:= {}
            	
            	aadd(aCabec,{"RA_FILIAL"  ,xFilial("SRA"),Nil  })
				aadd(aCabec,{"RA_MAT"     ,cCodMat ,Nil  }) 
            	
            	cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 
				cMsgLog += "Verba:     "+cVerba+chr(13)+chr(10)            
            	
            	           	
            	If SRC->(DbSeek(xFilial("SRC")+cCodMat+cVerba))            	           		
            	
            		//cMsgTmp := "Verba já cadastrada para a matrícula. Excluindo ..."+chr(13)+chr(10)
            	           		
					aItens := {} 	
					aadd(aItens,{	{"RC_PD" , 		SRC->RC_PD, Nil },;
									{"RC_TIPO1",	SRC->RC_TIPO1, Nil },;   
									{"RC_HORAS", 	SRC->RC_HORAS, Nil },;
									{"RC_DATA", 	SRC->RC_DATA, Nil },;
									{"RC_DTREF",	SRC->RC_DTREF, Nil },;
									{"RC_CC", 		SRC->RC_CC, Nil },;
									{"RC_SEMANA",	SRC->RC_SEMANA, Nil },;
									{"RC_VALOR", 	SRC->RC_VALOR, Nil },;
									{"RC_TIPO2", 	SRC->RC_TIPO2, Nil } })   
											
					lMsHelpAuto := .T.
					lMsErroAuto := .F.
				
					
					MsExecAuto({|w,x,y,z| GPEA090(w,x,y,z)},5,aCabec,aItens,5) // 3 - Inclusão, 4 - Alteração, 5 - Exclusão
					
										
					cMsgTmp := ""
					
					If lMsErroAuto .AND. SRC->(DbSeek(xFilial("SRC")+cCodMat+cVerba))
						cMsgTmp := "ERRO ao executar rotina GPEA090 para exclusão"+chr(13)+chr(10)
						aAutoEr := GETAUTOGRLOG() // Função que retorna o evento de erro na forma de um array			
						For nM := 1 To Len(aAutoEr)
							cMsgTmp += aAutoEr[nM]+chr(13)+chr(10)
						Next nM  
						cMsgLog += cMsgTmp			              
						DisarmTransaction() 			
						lRetOk := .F.  						 			
								
					Else
						//cMsgTmp := "EXCLUSÃO OK."+chr(13)+chr(10)
						nTotExc++					
					EndIf
					
					cMsgLog += cMsgTmp							           		 
            	            	
            	Endif
	            
	            aItens := {} 	

				aadd(aItens,{	{"RC_PD" , 		cVerba, Nil },;
								{"RC_VALOR", 	nValor, Nil },; 
								{"RC_TIPO1",	"V", Nil }})
										
				lMsHelpAuto := .T.
				lMsErroAuto := .F.
							
				Begin Transaction
				MsExecAuto({|w,x,y,z| GPEA090(w,x,y,z)},3,aCabec,aItens,3) // 3 - Inclusão, 4 - Alteração, 5 - Exclusão
											
				cMsgTmp := ""
				End Transaction		
				If lMsErroAuto .AND. SRC->(!DbSeek(xFilial("SRC")+cCodMat+cVerba))
					cMsgTmp := "ERRO ao executar rotina GPEA090 para inclusão."+chr(13)+chr(10)
					aAutoEr := GETAUTOGRLOG() // Função que retorna o evento de erro na forma de um array			
					For nM := 1 To Len(aAutoEr)
						cMsgTmp += aAutoEr[nM]+chr(13)+chr(10)
					Next nM  
					cMsgLog += cMsgTmp			              
					DisarmTransaction()			
					lRetOk := .F.
							
				Else
					cMsgTmp := "INCLUSÃO OK."+chr(13)+chr(10) 
					nTotInc++					
				EndIf
						
				cMsgLog += cMsgTmp
				
				
		
					
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