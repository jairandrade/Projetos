#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MGPE010
Importaca de alteracao salaria
Rotina que importa arquivo CSV com alteracao salarial, através do execauto GPEA010

@author Thiago Henrique dos Santos
@version P11
@since 21/01/2016
@return nil
/*/
//-------------------------------------------------------------------
User Function MGPE011()

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
Local dData		:= CToD("  /  /  ")
Local cMotivo 	:= ""
Local nValor	:= 0  
Local lRetOK 	:= .T.
Local cMsgTmp	:= ""
Local nTotInc	:= 0
Local nM		:= 0
Local aProc		:= {}
Local nI
Local cAltSalt := GetMv("MV_ALTSAL")
Local cTmp := ""

PutMv("MV_ALTSAL","N")

DbSelectArea("SRA")
SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT

ProcRegua(0)

If File( cArqTxt )

	FT_FUse(cArqTxt ) 	// abre o arquivo
	FT_FGOTOP()     	// posiciona na primeira linha do arquivo
	
	
	ProcRegua(FT_FLASTREC())
	
	
	While !FT_FEOF()

		IncProc("Validando Arquivo...")
	
		cLinha := FT_FREADLN() 		
		aLinha := Separa(cLinha,';',.T.) 
		
		If !Empty(aLinha) .AND. Len(aLinha) <> 4  
			cMsgLog += "Layout do arquivo inválido!"+chr(13)+chr(10)  
			lRetOk := .F.        
			Exit
		EndIf 
		
		If !Empty(aLinha) .AND. !("MAT" $ Upper(aLinha[1])) 
		
			nTotLin++			
			cCodMat := PadL(AllTrim(aLinha[1]),TamSx3("RA_MAT")[1],"0")
			cTmp := StrTran(aLinha[2],".","")
			cTmp := StrTran(cTmp,",",".")
			nValor 	:= Val(cTmp)			
			cMotivo := PadL(AllTrim(aLinha[3]),TamSx3("RA_TIPOALT")[1],"0")
			dData	:= CToD(aLinha[4])
			
			If !SRA->(DbSeek(xFilial("SRA")+cCodMat))        
			    
		   		cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 
				cMsgLog += "Código da Matrícula não encontrada no cadastro de Funcionários."+chr(13)+chr(10) 
				
			ElseIf SRA->RA_SITFOLH == "D" .AND. !Empty(SRA->RA_DEMISSA)   
				
				cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10) 		
				cMsgLog += "Funcionário com Status Demitido."+chr(13)+chr(10)
				
            Else
            
            	AAdd(aProc,{cCodMat,nValor,cMotivo,dData})
            	
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
				nValor  := aProc[nI][2]
				cMotivo := aProc[nI][3]
				dData	:= aProc[nI][4]
				
				SRA->(DbSeek(xFilial("SRA")+cCodMat))
				
            	aCabec		:= {}
            	
				aadd(aCabec,{"RA_FILIAL"  ,xFilial("SRA"),Nil  })
				aadd(aCabec,{"RA_MAT"     ,cCodMat ,Nil  })
				aadd(aCabec,{"RA_SALARIO" ,nValor ,Nil  }) 
				aadd(aCabec,{"RA_DATAALT" ,dData ,Nil  })
				aadd(aCabec,{"RA_TIPOALT" ,cMotivo ,Nil  })
				
				cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
				cMsgLog += "Matrícula: "+cCodMat+chr(13)+chr(10)

				
				lMsHelpAuto := .T.
				lMsErroAuto := .F.
				MSExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},NIL,NIL,aCabec,4)
				Sleep(1000)


				If lMsErroAuto 
					cMsgTmp := "ERRO ao executar rotina GPEA010 para alteração."+chr(13)+chr(10)
					aAutoEr := GETAUTOGRLOG() // Função que retorna o evento de erro na forma de um array			
					For nM := 1 To Len(aAutoEr)
						cMsgTmp += aAutoEr[nM]+chr(13)+chr(10)
					Next nM  
					cMsgLog += cMsgTmp			              
					
					lRetOk := .F.
							
				Else
					cMsgLog += "Alteração Salarial OK."+chr(13)+chr(10) 
					nTotInc++					
				EndIf
				
				
            	
            Next nI
	Endif
	
	
	cMsgLog += Replicate("-",60)+chr(13)+chr(10) 
	cMsgLog += "Total de matriculas alteradas: "+cValToChar(nTotInc)+chr(13)+chr(10)
	cMsgLog += Replicate("-",60)+chr(13)+chr(10)+chr(13)+chr(10)  
	cMsgLog += Replicate("-",60)+chr(13)+chr(10)
	cMsgLog += "Total Linhas no arquivo: "+cValToChar(nTotLin)+chr(13)+chr(10)

Else

	cMsgLog += "Arquivo não encontrado!"+CRLF

Endif

PutMv("MV_ALTSAL",cAltSalt)					

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
	
	cMsg := "Importação de alteração salarial " + CHR(13)+CHR(10)+"Data: " + DtoC(Date())+;
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