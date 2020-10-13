#include "protheus.ch"

User Function IMPORT03()

	Local bProcess
	Local cPerg := Padr("IMPORT03",10)
	Local oProcess

	bProcess := {|oSelf| Executa(oSelf) }

	//cria as peguntas se n�o existe
	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oProcess := tNewProcess():New("IMPORT03","Importa��o de Clientes",bProcess,"Rotina para importa��o de Clientes especifica para o MADERO. Na op��o parametros, favor informar o arquivo .CSV para importa��o",cPerg,,.F.,,,.T.,.T.)

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
		MsgStop("O arquivo " +cArq + " n�o foi encontrado. A importa��o ser� abortada!","[IMPORT03] - ATENCAO")
		Return
	EndIF

	//valida o diret�rio se for pra gravar em disco
	IF nMostra == 2
		cDiretory := alltrim(mv_par03)
		cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
		//valida o diret�rio
		If !ExistDir( cDiretory )
			Aviso("Diret�rio","Diret�rio " + cDiretory + " invalido.",{"Ok"},2)
			Return
		EndIF
	EndIF

	SetFunName("MATA030")

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
			aRetErro := U_IMPORTCLIE({ aCampos, Separa(@cLine,";",.T.)})
			If Len(aRetErro) > 0
				lErroGlb := .T.
				aAdd(aErros, aRetErro)
			EndIf
		EndIf
	Enddo

	If !Empty(oTXTFile:_Resto)
		oProc:IncRegua1("Lendo Linha " + alltrim(str((Len(oTXTFile:_BUFFER)))) + " de " + alltrim(str((Len(oTXTFile:_BUFFER)))))
			//aRetErro := StartJob("U_TESTIMPORT",GetEnvServer(),.T., { aCampos, Separa(@cLine,";",.T.)}, cEmpAnt, cFilAnt) //U_TESTIMPORT({ aCampos, Separa(@cLine,";",.T.)})
		aRetErro := U_IMPORTCLIE({ aCampos, Separa(oTXTFile:_Resto,";",.T.)})
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
oProc:IncRegua1("Fim da importa��o.")
Return

Static Function toNumber(xValor)

	//se exitir virgula na string
	IF At(",",xValor) != 0
		//se o ponto vier antes da virgula ou ponto n�o existir
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
	xPutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importa��o,","obrigat�riamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
	//Mostra erros?
	xPutSx1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","N�o Mostra","N�o Mostra","N�o Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
	//Diretorio
	xPutSx1(cPerg,"03","Diret�rio?","Diret�rio?","Diret�rio?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diret�rio para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")

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

// Ajusta o tamanho do grupo. Ajuste emergencial para valida��o dos fontes. 
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



User Function IMPORTCLIE(aArrComp, cEmp, cFil)
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
					IF alltrim(aCampos[j]) != "A1_FILIAL"
						IF alltrim(aCampos[j]) == "A1_NOME"
							aAdd(AMATA030,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
							cNomeCli := alltrim(aDados[j])
						ElseIF alltrim(aCampos[j]) == "A1_COD"
						
							If Empty(alltrim(aDados[j]))
								AADD(aErros,"Cliente com codigo vazio vazio. [A1_NOME="+cNomeCli+"]")
								lErro := .T.
								lErroGlb := .T.
							Else
								cCod := PADR(alltrim(aDados[j]),TAMSX3("A1_COD")[1])
								aAdd(AMATA030,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
							EndIf
						ElseIF alltrim(aCampos[j]) == "A1_LOJA"
						
							If Empty(alltrim(aDados[j]))
								AADD(aErros,"Cliente com LOJA vazio. [A1_NOME="+cNomeCli+"]")
								lErro := .T.
								lErroGlb := .T.
							Else
								SA1->( dbSetOrder(1) )
								If SA1->( dbSeek( xFilial("SA1") + cCod +  alltrim(aDados[j])) )																					
									lContinua := .F.
								Endif
								aAdd(AMATA030,{alltrim(aCampos[j]), alltrim(aDados[j]), NIL})
							EndIf
							
						Else
							Do Case
							Case SX3->X3_TIPO == 'N'
								AADD(AMATA030,{alltrim(aCampos[j]), toNumber(aDados[j]), NIL})
							Case SX3->X3_TIPO == 'D'
								AADD(AMATA030,{alltrim(aCampos[j]), CTOD(aDados[j]), NIL})
							Otherwise
								AADD(AMATA030,{alltrim(aCampos[j]), upper(alltrim(aDados[j])), NIL})
							EndCase
						EndIF
					EndIF
				Else
					Alert("O campo " + aCampos[j] + " n�o existe na tabela, corrija o arquivo de importa��o!")
					Return
				EndIF
		Next j

		lMsErroAuto := .F.
			If !lErro
				If !lContinua
					MSExecAuto({|x,y| mata030(x,y)},AMATA030,4)
				Else
					MSExecAuto({|x,y| mata030(x,y)},AMATA030,3) // Inclus�o
				Endif
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