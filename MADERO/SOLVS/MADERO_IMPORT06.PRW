#include "protheus.ch"

User Function IMPORT06()

	Local bProcess
	Local cPerg := Padr("IMPORT06",10)
	Local oProcess

	bProcess := {|oSelf| Executa(oSelf) }

	//cria as peguntas se não existe
	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oProcess := tNewProcess():New("IMPORT06","Importação de Produtos X Fornecedores",bProcess,"Rotina para importação de Produtos X Fornecedores especifica para o MADERO. Na opção parametros, favor informar o arquivo .CSV para importação",cPerg,,.F.,,,.T.,.T.)

Return

Static Function Executa(oProc)

	Local cArq       	:= alltrim(mv_par01)
	Local lPrim      	:= .T.
	Local aCampos    	:= {}
	Local aDados     	:= {}
	Local aMemo		 	:= {}
	Local nMostra   	:= mv_par02
	Local lErroGlb 		:= .F.
	Local lErro 		:= .F.
	Local lRetMens 		:= .F.
	Local lRet 			:= .F.
	Local oBtnOk 		:= ""
    Local oFntTxt 		:= TFont():New("Lucida Console",,-9,,.F.,,,,,.F.,.F.)
    Local cMsg    		:= ""
    Local cTitulo 		:= "Erros de importacao"
	Local cPathTmp  	:= "\temp\"
	Local cFileErr  	:= ""
	Local aProdsAlt 	:= {}
	Local aProdsAux 	:= {}
	Local aProdAlter 	:= {}
	Local cErrProdAl 	:= .F.
	Local cOrdem	 	:= ""
	Local lExist		:= .F.
	Local cLine 		:= ''
	Local aRetErro 		:= {}
	Local aErros 		:= {}
	Local cQebraL		:= Chr(13)+Chr(10)
	Local oMsg
	Local i
	Local h
	Local j
	Local nX
	Local nY
	Local nXY
	Local oDlgMens
	Local cDiretory
	Local nHandle
	Local oTXTFile

	IF !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[IMPORT03] - ATENCAO")
		Return
	EndIF

	//valida o diretório se for pra gravar em disco
	IF nMostra == 2
		cDiretory := alltrim(mv_par03)
		cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
		//valida o diretório
		If !ExistDir( cDiretory )
			Aviso("Diretório","Diretório " + cDiretory + " invalido.",{"Ok"},2)
			Return
		EndIF
	EndIF

	SetFunName("MATA060")


	oTXTFile := ZFWReadTXT():New(cArq)
	If !oTXTFile:Open()
		MsgStop(oTXTFile:GetErrorStr(),"OPEN ERROR")
		Return
	Endif
	While oTXTFile:ReadLine(@cLine)
		If lPrim
			oProc:SetRegua1( (Len(oTXTFile:_BUFFER)) )
			aCampos := Separa(@cLine,";",.T.)
			lPrim := .F.
		Else
			//aAdd(aDados,Separa(cLinha,";",.T.))
			oProc:IncRegua1("Lendo Linha " + alltrim(str(oTXTFile:_POSBUFFER)) + " de " + alltrim(str((Len(oTXTFile:_BUFFER)))))
			//aRetErro := StartJob("U_TESTIMPORT",GetEnvServer(),.T., { aCampos, Separa(@cLine,";",.T.)}, cEmpAnt, cFilAnt) //U_TESTIMPORT({ aCampos, Separa(@cLine,";",.T.)})
			aRetErro := U_IMPORTPDFO({ aCampos, Separa(@cLine,";",.T.)})
			If Len(aRetErro) > 0
				lErroGlb := .T.
				aAdd(aErros, aRetErro)
			EndIf
		EndIf
	Enddo

	If !Empty(oTXTFile:_Resto)
		oProc:IncRegua1("Lendo Linha " + alltrim(str((Len(oTXTFile:_BUFFER)))) + " de " + alltrim(str((Len(oTXTFile:_BUFFER)))))
			//aRetErro := StartJob("U_TESTIMPORT",GetEnvServer(),.T., { aCampos, Separa(@cLine,";",.T.)}, cEmpAnt, cFilAnt) //U_TESTIMPORT({ aCampos, Separa(@cLine,";",.T.)})
		aRetErro := U_IMPORTPDFO({ aCampos, Separa(oTXTFile:_Resto,";",.T.)})
		If Len(aRetErro) > 0
			lErroGlb := .T.
			aAdd(aErros, aRetErro)
		EndIf
	EndIf
	oTXTFile:Close()

		IF lErroGlb
			IF nMostra == 1
				For nY := 1 to Len(aErros)
					cMsg += aErros[nY][1] + cQebraL
				Next nY
				DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
					@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
					oMsg:lReadOnly := .T.
					@ 127, 144 BUTTON oBtnOk  PROMPT '&Ok'   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
				ACTIVATE MSDIALOG oDlgMens CENTERED
			ElseIF nMostra == 2
				cNome := "["+cFilAnt+"]"
				cNome += "["+DtoS(Date())+"]"
				cNome += "["+RetNum(Time())+"]"
				cNome += "["+cValToChar(i)+"]"
				cNome += ".txt"
				nHandle := FCreate(cDiretory+cNome)

				For nY := 1 to Len(aErros)
					FWrite(nHandle, aErros[nY][1]+ cQebraL)
				Next nY

				FClose(nHandle)
			EndIF
		Else
			MSGINFO("Importado com sucesso.")
		EndIF
oProc:IncRegua1("Fim da importação.")
Return

Static Function toNumber(xValor)

	//se exitir virgula na string
	IF At(",",xValor) != 0
		//se o ponto vier antes da virgula ou ponto não existir
		IF ( At(",",xValor) > At(".",xValor) ).Or.At(".",xValor) == 0
			xValor := StrTran(xValor,".","")
			xValor := StrTran(xValor,",",".")
			xValor := val(xValor)
		Else
			xValor := StrTran(xValor,",","")
			xValor := val(xValor)
		EndIF
	Else
		xValor := val(xValor)
	EndIF

Return xValor



Static Function CriaSX1(cPerg)

	//Arquivo
	xPutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
	//Mostra erros?
	xPutSx1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","Não Mostra","Não Mostra","Não Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
	//Diretorio
	xPutSx1(cPerg,"03","Diretório?","Diretório?","Diretório?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If Fieldpos("X1_PYME") > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return

User Function IMPORTPDFO(aArrComp, cEmp, cFil)
	Local aCampos := aArrComp[1]
	Local aDados  := aArrComp[2]
	Local aMata010   := {}
	Local i
	Local j
	Local h
	Local nX
	Local nXY
	Local nY
	Local bB5		:= .F.
	Local aCab		:= {}
	Local lErroGlb 	:= .F.
	Local lErro 	:= .F.
	Local cErrProdAl := .F.
	Local cPathTmp  := "\temp\"
	Local aProdsAlt := {}
	Local aProdsAux := {}
	Local aProdAlter := {}
	Local cOrdem	 := ""
	Local lExist	:= .F.
	Local aErros := {}
	

		lContinua := .T.
		AMATA030 := {}
		lErro := .F.
		cNomeCli := ""
		cCod := ""
		AMATA060 	:= {}
		cFornec 	:= ""
		cLoja		:= ""
		cProd		:= ""
		cCodProd	:= ""
		cCodProd	:= ""
		cCodTab		:= ""

		// RpcClearEnv()
		// RPcSetType(3)
		// RpcSetEnv(cEmp,cFil, , ,'COM' , GetEnvServer() )
		// OpenSm0(cEmp, .f.)
		// SM0->(dbSetOrder(1))
		// SM0->(dbSeek(cEmp+cFil))
		// nModulo:=5
		// cEmpAnt:=SM0->M0_CODIGO
		// cFilAnt:=SM0->M0_CODFIL

		For j:=1 to Len(aCampos)

				SX3->(dbSetOrder(2))
				SX3->(dbGoTop())
				IF SX3->(dbSeek(alltrim(aCampos[j]))) .And. ALLTRIM(SX3->X3_CAMPO) == alltrim(aCampos[j])
					IF alltrim(aCampos[j]) != "A5_FILIAL"
						If alltrim(aCampos[j]) == "A5_FORNECE"
							cFornec := alltrim(aDados[j]) 
						ElseIf alltrim(aCampos[j]) == "A5_LOJA"
							cLoja := alltrim(aDados[j])
						ElseIf alltrim(aCampos[j]) == "A5_CODPRF"
							cProd := alltrim(aDados[j]) 
						ElseIf alltrim(aCampos[j]) == "A5_PRODUTO"
							cCodProd := alltrim(aDados[j]) 	
						ElseIf alltrim(aCampos[j]) == "A5_CODTAB"
							cCodTab := alltrim(aDados[j]) 	
						Endif
						Do Case
						Case SX3->X3_TIPO == 'N'
							AADD(AMATA060,{alltrim(aCampos[j]), toNumber(aDados[j]), NIL})
						Case SX3->X3_TIPO == 'D'
							AADD(AMATA060,{alltrim(aCampos[j]), CTOD(aDados[j]), NIL})
						Otherwise
						//	aRet := TamSX3(alltrim(aCampos[j]))
							//AADD(AMATA060,{alltrim(aCampos[j]), substr(aDados[j],1,aRet[01]), NIL})
							AADD(AMATA060,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
						EndCase
					
					EndIF				
				Else
					Alert("O campo " + aCampos[j] + " não existe na tabela, corrija o arquivo de importação!")
					Return
				EndIF
		Next j
		lErro := .F.
			dbSelectArea("SA5")
			DbOrderNickName("A5CODPRF")
			If SA5->( dbSeek( xFilial("SA5") + PADR(cFornec,TAMSX3("A5_FORNECE")[1]) + PADR(cLoja,TAMSX3("A5_LOJA")[1]) + PADR(cCodProd,TAMSX3("A5_PRODUTO")[1]) + PADR(cProd,TAMSX3("A5_CODPRF")[1])) )
				nPar01 := 4
			Else
				nPar01 := 3
			Endif
		 
		 	dbSelectArea("SB1")
			SB1->( dbSetOrder(1) )
			SB1->( dbSeek( xFilial("SB1") + PADR(cCodProd,TAMSX3("A5_PRODUTO")[1]) ))

			If !( SB1->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Produto nao encontrado na tabela de produtos - [PRODUTO:"+PADR(cCodProd,TAMSX3("A5_PRODUTO")[1])+"][FORNECEDOR:"+PADR(cFornec,TAMSX3("A5_FORNECE")[1])+"][FILIAL:"+cFilAnt+"]" )
			EndIf

			dbSelectArea("SA2")
			SA2->( dbSetOrder(1) )
			SA2->( dbSeek( xFilial("SA2") + PADR(cFornec,TAMSX3("A5_FORNECE")[1]) ))

			If !( SA2->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Fornecedor nao encontrado na tabela de fornecedores - [PRODUTO:"+PADR(cCodProd,TAMSX3("A5_PRODUTO")[1])+"][FORNECEDOR:"+PADR(cFornec,TAMSX3("A5_FORNECE")[1])+"][FILIAL:"+cFilAnt+"]" )
			EndIf

			If !Empty(PADR(cCodTab,TAMSX3("A5_CODTAB")[1]))
				dbSelectArea("AIB")
				AIB->( dbSetOrder(2) )
				AIB->( dbSeek( xFilial("AIB") + PADR(cFornec,TAMSX3("A5_FORNECE")[1]) + PADR(cLoja,TAMSX3("A5_LOJA")[1]) + PADR(cCodTab,TAMSX3("A5_CODTAB")[1]) + PADR(cCodProd,TAMSX3("A5_PRODUTO")[1]) ))

				If !( AIB->( Found() ) )
					lErro := .T.
					lErroGlb := .T.
					AADD(aErros,"Tabela de preco nao cadastrada - [PRODUTO:"+PADR(cCodProd,TAMSX3("A5_PRODUTO")[1])+"][FORNECEDOR:"+PADR(cFornec,TAMSX3("A5_FORNECE")[1])+"][LOJA:"+PADR(cLoja,TAMSX3("A5_LOJA")[1])+"][TABELA PRECO:"+PADR(cCodTab,TAMSX3("A5_CODTAB")[1])+"][FILIAL:"+cFilAnt+"]" )
				EndIf
			EndIf

			lMsErroAuto := .F.
			If !lErro
				MSExecAuto({|x,y| u_AMATA060(x,y)},AMATA060,nPar01)	
			EndIf
		
			IF lMsErroAuto // Se deu erro 
				lErro := .T.
				lErroGlb := .T.
				cFileErr := "["+cFilAnt+"]"
				cFileErr += "["+DtoS(Date())+"]"
				cFileErr += "["+RetNum(Time())+"]"
				cFileErr += ".txt"
				MostraErro(cPathTmp, cFileErr)
				cFileErr := memoread(cPathTmp+cFileErr)
				AADD(aErros,"Erro ao executar EXECAUTO: " + cFileErr)
			EndIF
Return aErros
