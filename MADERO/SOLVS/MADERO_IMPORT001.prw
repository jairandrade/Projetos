#include "protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "RWMAKE.CH"

User Function IMPORT01()

	Local bProcess
	Local cPerg := Padr("IMPORT01",10)
	Local oProcess

	bProcess := {|oSelf| Executa(oSelf) }

	//-> cria as peguntas se não existe
	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oProcess := tNewProcess():New("IMPORT01","Importação / Atualização de Produtos",bProcess,"Rotina para importação / Atualização de Produtos especifica para o MADERO. Na opção parametros, favor informar o arquivo .CSV para importação",cPerg,,.F.,,,.T.,.T.)

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
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[IMPORT01] - ATENCAO")
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

	SetFunName("MATA010")

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
			aRetErro := U_IMPORTPROD({ aCampos, Separa(@cLine,";",.T.)})
			If Len(aRetErro) > 0
				lErroGlb := .T.
				aAdd(aErros, aRetErro)
			EndIf
		EndIf
	Enddo

	If !Empty(oTXTFile:_Resto)
		oProc:IncRegua1("Lendo Linha " + alltrim(str((Len(oTXTFile:_BUFFER)))) + " de " + alltrim(str((Len(oTXTFile:_BUFFER)))))
			//aRetErro := StartJob("U_TESTIMPORT",GetEnvServer(),.T., { aCampos, Separa(@cLine,";",.T.)}, cEmpAnt, cFilAnt) //U_TESTIMPORT({ aCampos, Separa(@cLine,";",.T.)})
		aRetErro := U_IMPORTPROD({ aCampos, Separa(oTXTFile:_Resto,";",.T.)})
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




User Function IMPORTPROD(aArrComp, cEmp, cFil)
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
	Local cAlias	 := ''
	Local lExist	:= .F.
	Local aErros := {}
	

		lContinua := .T.
		aMata010  := {}
		aCab  	  := {}
		cCodProd  := ""
		cDescCEME := ""
		cDesc     := ""
		cLocPad	  := ""
		lErro	  := .F.
		B1_XN1	  := ""
		B1_XN2	  := ""
		B1_XN3	  := ""
		B1_XN4	  := ""
		B1_XTIPO  := ""
		B1_XCLAS  := ""
		B1_TIPO   := ""
		B1_UM     := ""
		B1_ORIGEM := ""
		cErrProdAl := .F.
		bB5		  	:= .F.

		For j:=1 to Len(aCampos)
			SX3->(dbSetOrder(2))
			SX3->(dbGoTop())
			IF SX3->(dbSeek(alltrim(aCampos[j]))) .And. ALLTRIM(SX3->X3_CAMPO) == alltrim(aCampos[j]) 
				If SX3->X3_CONTEXT != 'V'
					IF alltrim(aCampos[j]) != "B1_FILIAL"
						IF alltrim(aCampos[j]) == "B1_COD"
							SB1->( dbSetOrder(1) )							
							If SB1->( dbSeek( xFilial("SB1") + alltrim(aDados[j]) ) )
								lContinua := .F.
								//Loop
							Endif
							aAdd(aMata010,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
							cCodProd  := alltrim(aDados[j])
						ElseIF SUBSTR(alltrim(aCampos[j]), 0, 2) == "B5" .And. !(ALLTRIM(aCampos[j]) $ "B5_COD") // Alterar o SB5				
							//cDescCEME := alltrim(aDados[j])
							if SX3->X3_TIPO == 'N'
								AADD(aCab,{alltrim(aCampos[j]), toNumber(aDados[j]), NIL})
								bB5		  := .T.
							elseif SX3->X3_TIPO == 'D'
								AADD(aCab,{alltrim(aCampos[j]), CTOD(aDados[j]), NIL})
								bB5		  := .T.
							else
								If	!Empty(aDados[j])
									AAdd(aCab,{aCampos[j], aDados[j], Nil})
									bB5		  := .T.
								EndIf
							endif
						ElseIf alltrim(aCampos[j]) == "B5_CEME"
							cDescCEME := aDados[j]
						ElseIF alltrim(aCampos[j]) == "B1_XINFNUT" 
							aMemo := {}
							aMemo := Separa(alltrim(aDados[j]),"$",.T.) 
							cAuxMemo := ""
							For h:=1 to Len(aMemo)
								cAuxMemo += aMemo[h] + CRLF
							Next h
							AADD(aMata010,{alltrim(aCampos[j]), cAuxMemo, NIL})
						ElseIF alltrim(aCampos[j]) = "B1_VM_PROC"
						 	aMemo := {}
							aMemo := Separa(alltrim(aDados[j]),"$",.T.)
							cAuxMemo := ""
							For h:=1 to Len(aMemo)
								cAuxMemo += aMemo[h] + CRLF
							Next h
							AADD(aMata010,{alltrim(aCampos[j]), cAuxMemo, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_LOCPAD"
						 	cLocPad := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), cLocPad, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XN1"
						 	B1_XN1 := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XN1, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XN2"
						 	B1_XN2 := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XN2, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XN3"
						 	B1_XN3 := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XN3, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XN4"
						 	B1_XN4 := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XN4, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XTIPO"
						 	B1_XTIPO := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XTIPO, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_XCLAS"
						 	B1_XCLAS := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_XCLAS, NIL})	
						ElseIF alltrim(aCampos[j]) == "B1_TIPO"
						 	B1_TIPO := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_TIPO, NIL})	
						ElseIF alltrim(aCampos[j]) == "B1_UM"
						 	B1_UM := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_UM, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_ORIGEM"
						 	B1_ORIGEM := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), B1_ORIGEM, NIL})
						ElseIF alltrim(aCampos[j]) == "B1_DESC"
						 	cDesc := aDados[j]
							AADD(aMata010,{alltrim(aCampos[j]), cDesc, NIL})
						ElseIf alltrim(aCampos[j]) == "GI_PRODALT"
							If !Empty(aDados[j])
								aProdsAlt := strtokarr (aDados[j], "|")
								for nY := 1 to len(aProdsAlt)
									aProdsAux := strtokarr (aProdsAlt[nY], "/")
									If Len(aProdsAux) == 4
										If len(aProdAlter) > 0
											lExist := .F.
											for nXY := 1 to len(aProdAlter)
												If aProdAlter[nXY][1] == aProdsAux[1]
													lExist := .T.
												EndIf
											next

											If lExist
												lErroGlb := .T.
												AADD(aErros,"Codigo alternativo duplicado - [PRODUTO:"+cCodProd+"][PRODUTO ALTERNATIVO:"+aProdsAux[1]+"]" )
											Else
												aAdd(aProdAlter, {aProdsAux[1],aProdsAux[2],aProdsAux[3],aProdsAux[4]})
											EndIf
										Else
											aAdd(aProdAlter, {aProdsAux[1],aProdsAux[2],aProdsAux[3],aProdsAux[4]})
										EndIf
									Else
										cErrProdAl :=  .T.
									EndIf
								next
							EndIf
						Else
							Do Case
							Case SX3->X3_TIPO == 'N'
								AADD(aMata010,{alltrim(aCampos[j]), toNumber(aDados[j]), NIL})
							Case SX3->X3_TIPO == 'D'
								AADD(aMata010,{alltrim(aCampos[j]), CTOD(aDados[j]), NIL})
							Otherwise
							//	aRet := TamSX3(alltrim(aCampos[j]))
								//AADD(aMata010,{alltrim(aCampos[j]), substr(aDados[j],1,aRet[01]), NIL})
								AADD(aMata010,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
							EndCase
						EndIF
					EndIF
				EndIf
			Else
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"O campo " + aCampos[j] + " não existe na tabela, corrija o arquivo de importação!")
				Return aErros
			EndIF
		Next j

		dbSelectArea("NNR")
			NNR->( dbSetOrder(1) )
			NNR->( dbSeek( xFilial("NNR") + PADR(cLocPad,TAMSX3("B1_LOCPAD")[1]) ))
			If !( NNR->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Armazém padrão não cadastrado - [FILIAL:"+cFilAnt+"][COD. ARM:"+cLocPad+", B1_COD:"+cCodProd+"]" )
			EndIf

			dbSelectArea("Z18")
			Z18->(DbSetOrder(1))
			Z18->(DbSeek(xFilial("Z18")+B1_XN1))
			If !( Z18->( Found() ) ) .And. U_IsBusiness()
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Grupo Teknisa Nível 1 não cadastrado - [FILIAL:"+cFilAnt+"][TEK NIVEL 1:"+B1_XN1+", B1_COD:"+cCodProd+"]" )
			EndIf
			
			dbSelectArea("Z19")
			Z19->(DbSetOrder(1))
			Z19->(DbSeek(xFilial("Z19")+B1_XN1+B1_XN2))
			If !( Z19->( Found() ) ) .And. U_IsBusiness()
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Grupo Teknisa Nível 2 não cadastrado - [FILIAL:"+cFilAnt+"][TEK NIVEL 2:"+B1_XN2+", B1_COD:"+cCodProd+"]" )
			EndIf

			dbSelectArea("Z20")
			Z20->(DbSetOrder(1))
			Z20->(DbSeek(xFilial("Z20")+B1_XN1+B1_XN2+B1_XN3))
			If !( Z20->( Found() ) ) .And. U_IsBusiness()
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Grupo Teknisa Nível 3 não cadastrado - [FILIAL:"+cFilAnt+"][TEK NIVEL 3:"+B1_XN3+", B1_COD:"+cCodProd+"]" )
			EndIf

			dbSelectArea("Z21")
			Z21->(DbSetOrder(1))
			Z21->(DbSeek(xFilial("Z21")+B1_XN1+B1_XN2+B1_XN3+B1_XN4))
			If !( Z21->( Found() ) ) .And. U_IsBusiness()
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Grupo Teknisa Nível 4 não cadastrado - [FILIAL:"+cFilAnt+"][TEK NIVEL 4:"+B1_XN4+", B1_COD:"+cCodProd+"]" )
			Endif

			dbSelectArea("SX5")
			SX5->(DbSetOrder(1))
			SX5->(DbSeek(xFilial("SX5")+"Z2"+B1_XTIPO))
			If !( SX5->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Tipo customizado de produto não cadastrado - [FILIAL:"+cFilAnt+"][B1_XTIPO:"+B1_XTIPO+", B1_COD:"+cCodProd+"]" )
			Endif

			SX5->(DbSeek(xFilial("SX5")+"Z3"+B1_XCLAS))
			If !( SX5->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Classe customizada para o produto não cadastrada - [FILIAL:"+cFilAnt+"][B1_XCLAS:"+B1_XCLAS+", B1_COD:"+cCodProd+"]" )
			Endif

			SX5->(DbSeek(xFilial("SX5")+"02"+B1_TIPO))
			If !( SX5->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Tipo do produto não cadastrada - [FILIAL:"+cFilAnt+"][B1_TIPO:"+B1_TIPO+", B1_COD:"+cCodProd+"]" )
			Endif

			SX5->(DbSeek(xFilial("SX5")+"S0"+B1_ORIGEM))
			If !( SX5->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Origem não cadastrada - [FILIAL:"+cFilAnt+"][B1_ORIGEM:"+B1_ORIGEM+", B1_COD:"+cCodProd+"]" )
			Endif

			dbSelectArea("SAH")
			SAH->(DbSetOrder(1))
			SAH->(DbSeek(xFilial("SAH")+B1_UM))
			If !( SAH->( Found() ) )
				lErro := .T.
				lErroGlb := .T.
				AADD(aErros,"Unidade de medida não cadastrada - [FILIAL:"+cFilAnt+"][B1_UM:"+B1_UM+", B1_COD:"+cCodProd+"]" )
			Endif

			

			lMsErroAuto := .F.
			If !lErro
				If !lContinua
					//Loop
					MSExecAuto({|x,y| mata010(x,y)},aMata010,4) // Alteração
				Else
					MSExecAuto({|x,y| mata010(x,y)},aMata010,3) // Inclusão
				EndIf
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
			ElseIf !lErro // Se não deu erro inclui ou altera os SB5
				cCodProd := SB1->B1_COD

				DbSelectArea('SB5')
				SB5->(DbSetOrder(1)) //B5_FILIAL + B5_COD
				SB5->(DbGoTop())
				if bB5
					If SB5->(DbSeek(xFilial('SB5') + cCodProd)) // Se achar altera
						// alert("entrou altera")
						AAdd(aCab, {"B5_COD", cCodProd, Nil})
						// aCab:= {	{"B5_COD"  ,cCodProd  	,Nil},;    // Código identificador do produto            
					    // 			{"B5_CEME"  ,cDescCEME  ,Nil}}    // Nome científico do produto
	    
					    lMsErroAuto := .F.
					    MSExecAuto({|x,y| Mata180(x,y)},aCab,4) //Alteração
					    
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
						Endif
									    
					Else // Se não achar inclui
						/*If Empty(cDescCEME)
							AAdd(aCab, {"B5_CEME", cDesc, Nil})
						EndIf*/

						AAdd(aCab, {"B5_COD", cCodProd, Nil})
					    lMsErroAuto := .F.
					    MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão  
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
						Endif					    
						
					EndIf
				Else
					If !SB5->(DbSeek(xFilial('SB5') + cCodProd))
						AAdd(aCab, {"B5_CEME", cDesc, Nil})
						AAdd(aCab, {"B5_COD", cCodProd, Nil})

						lMsErroAuto := .F.
						MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão  
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
						Endif
					EndIf	
				Endif

				If !cErrProdAl .And. !lErro
					for nY := 1 to len(aProdAlter)
						dbSelectArea("SB1")
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek( xFilial("SB1") + aProdAlter[nY][1]))
						If !( SB1->( Found() ) )
							lErro := .T.
							lErroGlb := .T.
							AADD(aErros,"Produto alternativo não cadastrado - [COD PROD ALTER:"+aProdAlter[nY][1]+"][COD. PROD:"+cCodProd+"][FILIAL = "+cFilAnt+"]" )
						Else
							If VALTYPE(Val(aProdAlter[nY][3])) != "N"
								lErro := .T.
								lErroGlb := .T.
								AADD(aErros,"Tipo de valor incorreto no produto alternativo. O terceiro parâmentro(Fator conversão) deve ser numérico." )
							ElseIf Upper(aProdAlter[nY][4]) != "S" .And. Upper(aProdAlter[nY][4]) != "N"
								lErro := .T.
								lErroGlb := .T.
								AADD(aErros,"Tipo de valor incorreto no produto alternativo. O quarto parâmetro(Entra MRP) deve ser S ou N." )
							Else
								dbSelectArea("SGI")
								SGI->( dbSetOrder(1) )
								SGI->( MSSeek( xFilial("SGI") + cCodProd + cValtoChar(nY)))
								If !( SGI->( Found() ) )
									Reclock("SGI", .T.)
										SGI->GI_FILIAL 	:= cFilAnt
										SGI->GI_ORDEM 	:= cValtoChar(nY)
										SGI->GI_PRODORI := cCodProd
										SGI->GI_PRODALT := aProdAlter[nY][1]
										SGI->GI_TIPOCON := aProdAlter[nY][2]
										SGI->GI_FATOR	:= VAL(aProdAlter[nY][3])
										SGI->GI_MRP 	:= aProdAlter[nY][4]
									SGI->(MsUnLock())
								Else
									Reclock("SGI", .F.)
										SGI->GI_PRODALT := aProdAlter[nY][1]
										SGI->GI_TIPOCON := aProdAlter[nY][2]
										SGI->GI_FATOR	:= VAL(aProdAlter[nY][3])
										SGI->GI_MRP 	:= aProdAlter[nY][4]
									SGI->(MsUnLock())
								EndIf
							EndIf
						EndIf
					next
				EndIf

				If cErrProdAl
					lErro := .T.
					lErroGlb := .T.
					AADD(aErros,"Erro de montagem no campo de produtos alternativos [FILIAL = "+cFilAnt+"][PRODUTO = "+cCodProd+"]")
				EndIf

			EndIF
Return aErros