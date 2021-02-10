#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"
#include "Protheus.ch"

#DEFINE __TAMLINHA 120
User Function OMS100()

//CHAMA importacao de ocorrencias
	fImpOco()

Return

Static Function fImpOco( pEmpresa, pFilial )
	Local nI := 0
	Private cArq
	Private nHandle
	Private cBuffer
	Private nBytesLidos
	Private lError := .F.
	Private oDlg,oList1,oConfirma,oImprime,oCancela
	Private aConfere := {}
	Private aOcorre	:= {}
	Private aPerguntas := {}
	Private cPerg    := "EDIRET"

	If Select("SX2") > 0

		cArq := cGetFile( '*.TXT |*.TXT | *.OCO |*.OCO',;
			"Selecione o arquivo a ser importado.", 1, "", .T.,;
			GETF_LOCALFLOPPY+;
			GETF_LOCALHARD+;
			GETF_NETWORKDRIVE )

		Processa({|| ImpArq(.F.)},"Lendo Arquivo")

		If ! lError
			If len(aConfere) = 0
				aAdd(aConfere, {"","","","","Não Existem ocorrencias informadas","",""})
			Endif
			oDlg := MSDIALOG():Create()
			oDlg:cName := "oDlg"
			oDlg:cCaption := "Verificação das Ocorrencias EDI Retorno - Proceda - Ocoren"
			oDlg:nLeft := 0
			oDlg:nTop := 0
			oDlg:nWidth := 910 // 501
			oDlg:nHeight := 391 // 391
			oDlg:lShowHint := .F.
			oDlg:lCentered := .T.

			oList1 := RDListBox(0.66,0.65,883,53,aConfere,{"N.Fiscal","Serie","Nome do Cliente","Ocorrencia","Descrição"})
			oList1:lColDrag := .F.
			oList1:lJustific := .T.
			oList1:lAdjustColSize := .T.
			oList1:lVisibleControl := .T.
			oList1:aArray := aConfere
			oList1:nAt := 1
			oList1:nLeft := 2
			oList1:nTop  := 3
			oList1:nWidth  := 899 //489
			oList1:nHeight := 331

			oImprime := SBUTTON():Create(oDlg)
			oImprime:cName := "oImprime"
			oImprime:cCaption := "oSBtn3"
			oImprime:nLeft := 7 //220
			oImprime:nTop := 338  //337
			oImprime:nWidth := 52
			oImprime:nHeight := 22
			oImprime:lShowHint := .F.
			oImprime:lReadOnly := .F.
			oImprime:Align := 0
			oImprime:lVisibleControl := .T.
			oImprime:nType := 6
			oImprime:bAction := {|| Imprime() }

			oCancela := SBUTTON():Create(oDlg)
			oCancela:cName := "oCancela"
			oCancela:cCaption := "oSBtn4"
			oCancela:nLeft := 438
			oCancela:nTop := 339
			oCancela:nWidth := 52
			oCancela:nHeight := 22
			oCancela:lShowHint := .F.
			oCancela:lReadOnly := .F.
			oCancela:Align := 0
			oCancela:lVisibleControl := .T.
			oCancela:nType := 2
			oCancela:bAction := {|| Cancela() }

			oDlg:Activate()

		EndIf
	Else

		PREPARE ENVIRONMENT EMPRESA pEmpresa FILIAL pFilial //Tables  "SD2", "SB1", "SF2", "SA3", "SA1", "SF4", "SC6", "SC5"

		cPasta := "C:\EDI\Recepcao\MBA\PATRUS\"
		aFiles := Directory(cPasta+"*.TXT")

		If Len(aFiles) > 0

			ProcRegua(Len(aFiles))

			For nI := 1 to Len(aFiles)

				cArq    := cPasta+alltrim(aFiles[nI][1])
				ImpArq(.T.)

				IncProc()

			Next nI
		Else
			Return
		Endif
	Endif

Return



Static Function ImpArq(pSrv)

	Local nLinha := 0
	Local nX := 0


	Private cCod		:= space(06)
	Private cLoja		:= space(02)
	Private cNomeCli	:= Space(40)
	Private cDesOcor	:= Space(60)

	ProcRegua(1000)

	For nX:=len(cArq) to 1 step -1

		If substr(cArq,nX,1) == "\"
			cPath:= substr(cArq,1,nX)
			cNomeArq:= substr(cArq,Nx+1,Len(cArq))
			If len(cNomeArq) > 20
				cNomeAlt:= substr(cNomeArq,1,20)
			Else
				cNomeAlt:= cNomeArq
			Endif
			exit
		Endif

	Next

	If File(cArq)
		nHandle := FOpen(cArq)
		If nHandle > 0

			cBuffer := Space(__TAMLINHA+2)
			nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
			lOK:= .T.

			While (__TAMLINHA+2) == nBytesLidos

				IncProc("Leitura...")
				nLinha++

				If Substr(cBuffer,1,3) == "341"

					cCGCTrans      := SubStr( cBuffer, 4, 14)
					DbSelectArea("SA4")
					SA4->(DbsetOrder(3))
					If !SA4->( DbSeek( xFilial("SA4") + cCGCTrans ) )
						cMsg:="Cadastro da Transportadora não encontrado: " + CRLF + ;
							"CNPJ: " + Transform( cCGCTrans, "@R 99.999.999/9999-99" ) + CRLF +;
							"Transportadora: " + SA4->A4_NOME + CRLF + ;
							"Favor cadastrar."

						If pSrv
							Conout(cMsg)
						Else
							MsgBox( cMsg )
						Endif

						Return
					Else
						cTransp	:= SA4->A4_COD
					Endif

				ElseIf Substr(cBuffer,1,3) == "342"

					cCGCArq:= Substr(cBuffer,4,14)

					If cCGCArq == SM0->M0_CGC

						cNrImp	:= GetSXENum("GXL","GXL_NRIMP")
						cNRDC		:= substr(cBuffer,21,8)
						cSERDC	:= strzero(val(substr(cBuffer,18,3)),03)
						cOcorre	:= substr(cBuffer,29,2)
						dDatOco	:= ctod( substr(cBuffer,31,02)+"/"+substr(cBuffer,33,02)+"/"+substr(cBuffer,35,04) )
						cHorOco	:= substr(cBuffer,39,02) + ":" + substr(cBuffer,41,2)

						cNrNf		:= substr(cBuffer,23,6)
						cSerie	:= strzero(val(substr(cBuffer,18,3)),3)

						If cSerie == "000"
							cSerie:= space(3)
						Endif

						DbSelectArea("GXH")
						GXH->(DbSetOrder(2)) // GXH_FILIAL+GXH_NRDC+GXH_SERDC
						If ! GXH->(DbSeek(xFilial("GXH")+cNRDC+cSERDC, .T.))
							If pSrv
								Conout(cNrNf+"/"+cSerie+"- Nota Fiscal nao exite na base de Conhecimentos Importados")
							Else
								aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Nota Fiscal nao exite na base de Conhecimentos Importados"} )
							Endif
							lOK:= .F.
						Endif

						DbSelectArea("GXL")
						GXL->(DbSetOrder(5)) //GXL_FILIAL+DTOS(GXL_DTOCOR)+GXL_HROCOR+GXL_NRDC+GXL_SERDC+GXL_CODOCO
						If GXL->(DbSeek(xFilial("GXL")+dtos(dDatOco)+cHorOco+cNRDC+cSERDC+cOcorre, .T.))
							If pSrv
								Conout(cNrNf+"/"+cSerie+"- Ocorrencia ja existe no Arquivo")
							Else
								aAdd( aOcorre , {cNrImp,dDatOco,cHorOco,cNrNf,cSerie, "Ocorrencia ja existe no Arquivo"} )
							Endif
						Else

							If lOK

								cCod		:= GetAdvFVal("SF2","F2_CLIENTE",xFilial("SF2")+cNrNf+cSerie,1)
								cLoja		:= GetAdvFVal("SF2","F2_LOJA",xFilial("SF2")+cNrNf+cSerie,1)
								cNomeCli	:= GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+cCod+cLoja,1)
								cDesOcor := GetAdvFVal("DT2","DT2_DESCRI",xFilial("DT2")+cOcorre,1)
								If empty(cDesOcor)
									cDesOcor:= "Ocorrencia nao existe na Tabela DT2"
								Endif

								RecLock("GXL",.T.)
								GXL->GXL_FILIAL	:= xFilial("GXL")
								GXL->GXL_NRIMP		:= cNrImp
								GXL->GXL_CDTRP		:= cTransp
								GXL->GXL_DTOCOR	:= dDatOco
								GXL->GXL_HROCOR	:= cHorOco
								GXL->GXL_EMISDC	:= cCGCTrans
								GXL->GXL_SERDC		:= cSERDC
								GXL->GXL_NRDC		:= cNRDC
								GXL->GXL_CODOCO	:= cOcorre
								GXL->GXL_OBS		:= substr(cBuffer,45,70)
								GXL->GXL_EDISIT	:= "1" //1=Importado 2=Processado 3=Rejeitado 4= Alterado
								GXL->GXL_EDIMSG	:= ""
								GXL->GXL_EDINRL	:= nLinha
								GXL->GXL_EDILIN	:= cBuffer
								GXL->GXL_EDIARQ	:= cArq
								GXL->GXL_DTIMP		:= dDataBase
								GXL->GXL_CODOBS	:= substr(cBuffer,43,02)
								MsUnlock()

								AAdd(aConfere,{cNrNF,cSerie,cNomeCli,cOcorre,cDesOcor,cCod,cLoja})
							Endif

						Endif

					Endif

				Endif

				cBuffer := Space(__TAMLINHA+2)
				nBytesLidos := FRead(nHandle,@cBuffer,Len(cBuffer))
				If Len(cBuffer) == (__TAMLINHA-2)
					cBuffer += Space(2)
				EndIf

			End

			FClose(nHandle)

			cFileDest := "PROC_"+cNomeArq
			MakeDir(cPath+"PROCESSADO")
			__CopyFIle(cArq,cPath+'PROCESSADO\' + cFileDest)
			FERASE(cArq)

			aConfere:= aSort( aConfere,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

			If Len(aConfere) =  0
				If len(aOcorre)= 0
					cMsg:= "O arquivo não contém dados para essa empresa CGC: "+ transform( SM0->M0_CGC, "@R 99.999.999/9999-99")
					If pSrv
						Conout(cMsg)
					Else
						MsgBox(cMsg)
					Endif
					lError := .T.
				Endif
			EndIf

		Else
			cMsg:= 'Erro ao tentar abrir o arquivo!  ' + cArq
			If pSrv
				Conout(cMsg)
			Else
				MsgBox(cMsg)
			Endif
			lError := .T.
		EndIf

	Else
		cMsg:= 'Arquivo '+AllTrim(cArq)+' não encontrado!'
		If pSrv
			Cnout(cMsg)
		Else
			MsgBox()
		Endif
		lError := .T.
	EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cancela   ºAutor  ³Rodrigo dos Santos  º Data ³  01/18/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancela()
	oDlg:End()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³imprime   ºAutor  ³Rodrigo dos Santos  º Data ³  01/18/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Imprime()
	Local cDesc1         	:= "Este programa tem como objetivo imprimir as ocorrencias "
	Local cDesc2         	:= "no arquivo de retorno EDI - Proceda. "
	Local cDesc3         	:= ""
	Local cPerg		      := ""

	Private Titulo       		:= "Composicao do Arquivo de Retorno"
	Private Cabec1       		:= " "
	Private Cabec2       		:= " "

	Private nLin 			:= 80
	Private nPos 			:= 0
	Private aOrd            := {}
	Private lEnd         	:= .F.
	Private lAbortPrint  	:= .F.
	Private CbTxt        	:= ""
	Private Limite          := 132
	Private Tamanho         := "G"
	Private NomeProg        := "COMMC005" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo           := 18
	Private aReturn         := { "A4", 1, "Logistica", 1, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg         	:= ""
	Private cbTxt      		:= Space(10)
	Private cbCont     		:= 00
	Private ContFl     		:= 01
	Private M_Pag      		:= 01
	Private wNRel      		:= "RETORNO" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString		    := ""

	wNRel := SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	EndIf

	nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³runreport ºAutor  ³Microsiga           º Data ³  01/18/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function RunReport(Cabec1,Cabec2,Titulo)

	If Len(aOcorre) > 0

		Cabec1       		:= "Ocorrencias Nao Importadas "
		Cabec2       		:= "Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia"

		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9

		For nAux := 1 To Len(aOcorre)

			If nLin > 55
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			EndIf

		/*                                                                                                                                          
		         1         2         3         4         5         6         7         8         9         0         1         2         3
		1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		Nr.Importa         Dt.Ocorr  Hr.Ocorr  Nr.NF     Ser  Ocorrencia 
		9999999999999999   99/99/99  99:99     99999999  999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*/	

			@ nLin,01 PSay aOcorre[nAux,01]
			@ nLin,20 PSay aOcorre[nAux,02]
			@ nLin,30 PSay aOcorre[nAux,03]
			@ nLin,40 PSay aOcorre[nAux,04]
			@ nLin,50 PSay aOcorre[nAux,05]
			@ nLin,55 PSay aOcorre[nAux,06]
			nLin++

		Next

	Endif

	Cabec1       		:= "Ocorrencias Importadas "
	Cabec2       		:= "Serie         Numero           Cod.        Loja       Cliente                                                   Data Proc.             Cod.         Ocorrencia                                                              "
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	For nAux := 1 To Len(aConfere)

		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		EndIf

		@ nLin,000 PSay aConfere[nAux][2]
		@ nLin,014 PSay aConfere[nAux][1]
		@ nLin,054 PSay substr(alltrim(aConfere[nAux][3]),1,40)
		@ nLin,031 Psay aConfere[nAux][6]
		@ nLin,044 Psay aConfere[nAux][7]
		@ nLin,113 PSay Dtoc(DDatabase)
		@ nLin,135 PSay aConfere[nAux][4]
		@ nLin,148 Psay aConfere[nAux][5]
		nLin++

	Next

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Função    ³NUMNF     ³ Autor ³  Carlos Cleuber       ³ Data ³ 14/05/12 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descrição ³ Retorno o Tamanho correto da NF Formatado                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Diversos programas especificos                             ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function NumNF( cNF )
	Local nTamNf:= TamSX3("D1_DOC")[1]

	Local cRet := StrZero( Val( cNF ), nTamNf )

Return cRet

/*/{Protheus.doc} OMS100C
Rotina para exportação de dados para arquivo TXT.
@author Jair Andrade
@since 08/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS100T()
//

	SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

	If .Not. MsgBox("Confirma geração de arquivo para EDI ?","Geração de Arquivo para EDI das transportadoras","YESNO")
		@ 050,000 To 150,300 Dialog oDlg1 Title "Geração de Arquivos para EDI das transportadoras"
		@ 015,010 Say "Operacao Cancelada."
		@ 035,060 BUTTON "_Ok" SIZE 30,10 ACTION CLOSE(oDlg1)
		ACTIVATE DIALOG oDlg1 CENTER
		Return
	Endif

//+--------------------------------------+
//| Variaveis utilizadas para parâmetros |
//| mv_par01             // Da Emissao   |
//| mv_par02             // Até Emissao |
//+--------------------------------------+


	Processa({|lEnd| GeraArquivo()},"Geração de arquivo de EDI das transportadoras")

Return



Static Function GeraArquivo()
	Local cTexto := ""
	Local cConteudo := ""
	Local cCodReg := ""

	cArqCPag := "RE"+Substr(('20201001'),1,2)+Substr(('20201001'),4,2)+Substr(('20201001'),7,2)+".TXT"

	If File(cArqCPag)
		FErase(cArqCPag)
	Endif

	If (nHdlArq := FCreate(cArqCPag,0)) == -1
		MsgBox("Arquivo Texto não pode ser criado!","ATENÇÃO","ALERT")
		Return
	Else
		IncProc("Gerando arquivo "+cArqCPag)
	Endif

	PRIVATE cQuery
	cQuery := " SELECT * "
	cQuery += " FROM " +RetSqlName("ZA0")+" ZA0 "
	cQuery += " WHERE ZA0.D_E_L_E_T_ <> '*' "
	cQuery += " AND ZA0.ZA0_CODIGO = '000007' "
	cQuery += " ORDER BY ZA0.ZA0_CODREG "


	TCQUERY cQuery NEW ALIAS T01

	nContad := 0
	cCodReg := T01->ZA0_CODREG
	While !T01->(EOF())
		cConteudo := ""
		If 	cCodReg  <> T01->ZA0_CODREG
			FWrite(nHdlArq,cTexto+CHR(13)+CHR(10))
			cCodReg := T01->ZA0_CODREG
			cTexto := ""
		EndIf
		//REGISTRO 000 - CABEÇALHO DE INTERCÂMBIO
		//REGISTRO 500 - CABEÇALHO DE documento
		//REGISTRO 501 - DADOS DA EMBARCADORA
		//REGISTRO: 502 - DADOS DO LOCAL DE COLETA/RETIRADA
		//REGISTRO: 503 - DADOS DO DESTINATÁRIO DA NOTA
		//REGISTRO: 504 - DADOS DO LOCAL DE ENTREGA - Preenchimento: CONDICIONAL
		//REGISTRO: 505 - DADOS DA NOTA FISCAL - Preenchimento: OBRIGATÓRIO
		//REGISTRO: 506 – VALORES DA NOTA FISCAL - Preenchimento: OBRIGATÓRIO
		//REGISTRO: 507 – CÁLCULO DO FRETE - Preenchimento: CONDICIONAL
		//REGISTRO: 508 – DADOS DE IDENTIFICAÇÃO DA CARGA - Preenchimento: CONDICIONAL
		//REGISTRO: 509 – DADOS DE ENTREGA CASADA/REDESPACHO - Preenchimento: CONDICIONAL
		//REGISTRO: 511 – ITEM DA NOTA FISCAL - Preenchimento: CONDICIONAL
		//REGISTRO: 513 - DADOS DO CONSIGNATÁRIO DA NOTA - Preenchimento: CONDICIONAL
		//REGISTRO: 514 - DADOS DE REDESPACHO DA NOTA – Preenchimento: CONDICIONAL
		//REGISTRO: 515 - DADOS DO RESPONSÁVEL PELO FRETE - Preenchimento: CONDICIONAL
		//REGISTRO: 519 – TOTAIS DO ARQUIVO - Preenchimento: OBRIGATÓRIO
		//	If T01->ZA0_TIPO=="1"//HEADER
		If T01->ZA0_TPDADO=="1"//Caracter
			If SUBSTR(Alltrim(T01->ZA0_CONTEU),1,1) =='"'
				cConteudo :=STRTRAN(Alltrim(T01->ZA0_CONTEU), '"', "")
			Else
				cMacro := STRTRAN(Alltrim(T01->ZA0_CONTEU), '"', "")
				cConteudo :=&(cMacro)
			EndIf
		Else
			If SUBSTR(Alltrim(T01->ZA0_CONTEU),1,1) =='"'
				cConteudo := STRTRAN(Alltrim(T01->ZA0_CONTEU), '"', "")
			Else
				cMacro := STRTRAN(Alltrim(T01->ZA0_CONTEU), '"', "")
				cConteudo :=&(cMacro)
			EndIf
		EndIf
		//Calcula o tamanho do campo para a configuracao do texto
		_nTamCpo :=(Val(OMS100R(T01->ZA0_POSFIM)) - Val(OMS100R(T01->ZA0_POSINI))) + 1
		_cContTemp := _nTamCpo - Len(Alltrim(cConteudo))
		If _cContTemp > 0
			_cCompText := cConteudo+Padr("",_cContTemp)
		Else
			_cCompText :=Substr(cConteudo, 1,_nTamCpo)
		EndIf
		cTexto +=_cCompText
		//	ElseIf T01->ZA0_TIPO=="2"//Detalhes

		//	Else //Trailer

		//	EndIf
		nContad++
		T01->(DbSkip())

	Enddo
//grava o ultimo codigo de registro
	FWrite(nHdlArq,cTexto+Chr(10))
	dbCloseArea("T01")
	FClose(nHdlArq)

	If nContad = 0
		MsgBox("Não há dados. Favor vertificar os Parâmetros.","Atenção","ALERT")
		FErase(cArqCPag)
	Else
	Aviso("Geração de Arquivo de EDI", "Arquivo gerado: "+cArqCPag, {"Ok"}, 1)
	/*
		@ 050,000 To 150,300 Dialog oDlg1 Title "Geração de Arquivo de EDI - Transportadora"
		@ 010,010 Say "             Operação realizada com sucesso."
		@ 020,010 Say "               Arquivo gerado: "+cArqCPag
		@ 035,060 Button "_Ok" Size 30,10 Action Close(oDlg1)
		Activate Dialog oDlg1 Center
		*/
	Endif
Return
/*-----------------------------------------------*
| Função: fSalvArq                              |
| Descr.: Função para gerar um arquivo texto    |
*-----------------------------------------------*/

Static Function fSalvArq()
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".TXT"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	Local nX := 0

	//Pegando o caminho do arquivo
	cFileNom:= cGetFile( '*.txt|*.txt' , 'Selecione a pasta para gerar o arquivo', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
		cArqCPag := cFileNom+"Erro_SG1.txt"
		//Montando a mensagem
		cTexto := "Função:"+ FunName()
		cTexto += " Usuário:"+ cUserName
		cTexto += " Data:"+ dToC(dDataBase)
		cTexto += " Hora:"+ Time() + cQuebra  + "Log de Erros" + cQuebra
		For nX := 1 To Len(aErros)
			cTexto +=aErros[nX]+ CRLF
		Next nX

		//Testando se o arquivo já existe
		If File(cArqCPag)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cArqCPag, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cArqCPag,"Atenção")
		EndIf
	EndIf
Return
//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} OMS100R
Função que tira zeros a esquerda de uma variável caracter
@author Jair Andrade	
@since 08/12/2020
@version undefined
@param cTexto, characters, Texto que terá zeros a esquerda retirados
@type function
@example Exemplos abaixo:
    u_zTiraZeros("00000090") //Retorna "90"
    u_zTiraZeros("00000909") //Retorna "909"
    u_zTiraZeros("0000909A") //Retorna "909A"
    u_zTiraZeros("000909AB") //Retorna "909AB"
/*/

Static Function OMS100R(cTexto)
	Local aArea     := GetArea()
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

	//Pegando o texto atual
	cRetorno := Alltrim(cTexto)

	//Enquanto existir zeros a esquerda
	While lContinua
		//Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
		If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
			lContinua := .f.
		EndIf

		//Se for continuar o processo, pega da próxima posição até o fim
		If lContinua
			cRetorno := Substr(cRetorno, 2, Len(cRetorno))
		EndIf
	EndDo

	RestArea(aArea)
Return cRetorno
