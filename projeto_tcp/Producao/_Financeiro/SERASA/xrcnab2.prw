#INCLUDE 'RWMAKE.CH' 
#INCLUDE 'PROTHEUS.CH'

Static	__aLayCNAB	:= {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXRCNAB2   บAutor  ณ Kaique Sousa      บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFUNCAO PARA LER ARQUIVO DE RETORNO COM BASE NO LAYOUT DO    บฑฑ
ฑฑบ          ณARQUIVO DE CONFIGURACAO PADRAO CNAB2.                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XRCNAB2(nHandle,cLayOut,nMaxLn)

Local nHdlLay   	:= 0
Local lContinua 	:= .T.
Local cBuffer   	:= ""
Local nCntFor   	:= 0
Local nPosIni   	:= 0
Local nPosFim   	:= 0
Local nTamanho  	:= 0
Local nDecimal  	:= 0
Local nPosSeg   	:= 0
Local aSegmento 	:= {}
Local aDetalhe  	:= {}
Local cLinUlt   	:= ""
Local cLinAtu   	:= ""
Local nCntFor2  	:= 0
Local cIdent    	:= ""
Local xNOSSONUM 	:= ""
Local xOCORRENCI	:= ""
Local xRECNO	   := ""
Local xOPERACAO	:= ""
Local xACAO			:= ""
Local xDATA     	:= "000000"
Local xBuffer   	:= ""
Local nLeitura  	:= 0					// Numero de Leituras Efetuadas
Local lSegValido	:= .F.				// Controle de Leitura de segmentos validos
Local nLidosBco 	:= 0					// Numero de Bytes lidos do Arquivo de Retorno
Local aBuffer 	 	:= {}
Local cChave    	:= ""
Local aDirtmp   	:= {}
Local aHeadL	 	:= {}

Default nMaxLn 	 := 5000
Private xConteudo  := ""

If ( File(cLayOut) )
	//aDirTmp	:=	directory(cLayOut)
	//cChave := aDirTmp[1][1]+str(aDirTmp[1][2])+DtoC(aDirTmp[1][3])+aDirTmp[1][4]
	If Empty(__aLayCNAB) //.Or. cChave != __aLayCNAB[1]
		nHdlLay := FOpen(cLayOut,64)
		While ( lContinua )
			cBuffer := FreadStr(nHdlLay,502)
			If ( !Empty(cBuffer) )
				If ( SubStr(cBuffer,1,1)=="1" )
					If ( SubStr(cBuffer,3,1)=="D" )
						aadd(aSegmento,{AllTrim(SubStr(cBuffer,02,03)),;
						AllTrim(SubStr(cBuffer,35,255)),1,1})
						aadd(aDetalhe,Array(5,4))
					EndIf
				Else
					If ( SubStr(cBuffer,3,1)=="D" )
						nPosIni  := Val(SubStr(cBuffer,20,03))
						nPosFim  := Val(SubStr(cBuffer,23,03))
						nDecimal := Val(SubStr(cBuffer,26,01))
						nTamanho := nPosFim - nPosIni +1
						xConteudo:= AllTrim(SubStr(cBuffer,27,255))
						nPosSeg := AScan(aSegmento,{|x| x[1]==Alltrim(SubStr(cBuffer,02,03))})
						If ( nPosSeg != 0 )
							Do Case
								Case xConteudo=="DATA"
									aDetalhe[nPosSeg,1,1] := "DATA"
									aDetalhe[nPosSeg,1,2] := nPosIni
									aDetalhe[nPosSeg,1,3] := nTamanho
									aDetalhe[nPosSeg,1,4] := nDecimal
								Case xConteudo=="NOSSONUMERO"
									aDetalhe[nPosSeg,2,1] := "NOSSONUMERO"
									aDetalhe[nPosSeg,2,2] := nPosIni
									aDetalhe[nPosSeg,2,3] := nTamanho
									aDetalhe[nPosSeg,2,4] := nDecimal
								Case xConteudo=="OCORRENCIA"
									aDetalhe[nPosSeg,3,1] := "OCORRENCIA"
									aDetalhe[nPosSeg,3,2] := nPosIni
									aDetalhe[nPosSeg,3,3] := nTamanho
									aDetalhe[nPosSeg,3,4] := nDecimal
								Case xConteudo=="RECNO"
									aDetalhe[nPosSeg,4,1] := "RECNO"
									aDetalhe[nPosSeg,4,2] := nPosIni
									aDetalhe[nPosSeg,4,3] := nTamanho
									aDetalhe[nPosSeg,4,4] := nDecimal
								Case xConteudo=="ACAO"
									aDetalhe[nPosSeg,5,1] := "ACAO"
									aDetalhe[nPosSeg,5,2] := nPosIni
									aDetalhe[nPosSeg,5,3] := nTamanho
									aDetalhe[nPosSeg,5,4] := nDecimal									
							EndCase
						EndIf
						//Dados bancarios para a baixa
					ElseIf ( SubStr(cBuffer,3,1)=="H" )
						nPosIni  := Val(SubStr(cBuffer,20,03))
						nPosFim  := Val(SubStr(cBuffer,23,03))
						nDecimal := Val(SubStr(cBuffer,26,01))
						nTamanho := nPosFim - nPosIni +1
						xConteudo:= AllTrim(SubStr(cBuffer,27,255))
						Do Case
							Case xConteudo=="DATA"
								aAdd( aHeadL , {"DATA",nPosIni,nTamanho,nDecimal} )
							Case xConteudo=="OPERACAO"
								aAdd( aHeadL , {"OPERACAO",nPosIni,nTamanho,nDecimal} )
						EndCase
					EndIf
				EndIf
			Else
				lContinua := .F.
			EndIf
		EndDo
		FClose(nHdlLay)
		__aLayCNAB	:=	{}
		Aadd(__aLayCNAB,aSegmento)
		Aadd(__aLayCNAB,aDetalhe)
		Aadd(__aLayCNAB,aHeadL)
	Else
		aSegmento	:= aClone(__aLayCNAB[1])
		aDetalhe		:=	aClone(__aLayCNAB[2])
		aHeadL		:= aClone(__aLayCNAB[3])
	EndIf
EndIf
lContinua := .T.
While ( lContinua )
	aLinha		:= LerLinha(nHandle,nMaxLn)
	cBuffer 		:= aLinha[1]
	nLidosBco 	:= aLinha[2]
	nLeitura++
	lSegValido := .F.
	If (!Empty(cBuffer))
		//Lendo no Header de Lote o Banco, Agencia e Conta para baixa
		If Substr(cBuffer,1,1) == "0" .and. Len(aHeadL) > 0
			For nCntFor := 1 To Len(aHeadL)
				nPosIni := aHeadL[nCntFor,2]
				nTamanho:= aHeadL[nCntFor,3]
				nDecimal:= aHeadL[nCntFor,4]
				Do Case
					Case aHeadL[nCntFor,1]=="DATA"
						xDATA			:= SubStr(cBuffer,nPosIni,nTamanho)
					Case aHeadL[nCntFor,1]=="OPERACAO"
						xOPERACAO	:= SubStr(cBuffer,nPosIni,nTamanho)
				EndCase
			Next
		Else
			For nCntFor := 1 To Len(aSegmento)
				xConteudo := SubStr(cBuffer,aSegmento[nCntFor,3],aSegmento[nCntFor,4])
				If ( lContinua )
					If ( xConteudo $ aSegmento[nCntFor,2] )
						For nCntFor2 := 1 To Len(aDetalhe[nCntFor])
							nPosIni := aDetalhe[nCntFor,nCntFor2,2]
							nTamanho:= aDetalhe[nCntFor,nCntFor2,3]
							nDecimal:= aDetalhe[nCntFor,nCntFor2,4]
							Do Case
								Case aDetalhe[nCntFor,nCntFor2,1]=="DATA"
									xDATA := SubStr(cBuffer,nPosIni,nTamanho)
								Case aDetalhe[nCntFor,nCntFor2,1]=="OCORRENCIA"
									xOCORRENCI := SubStr(cBuffer,nPosIni,nTamanho)
								Case aDetalhe[nCntFor,nCntFor2,1]=="NOSSONUMERO"
									xNOSSONUM := SubStr(cBuffer,nPosIni,nTamanho)
								Case aDetalhe[nCntFor,nCntFor2,1]=="RECNO"
									xRECNO := SubStr(cBuffer,nPosIni,nTamanho)
									xRECNO := Val(U_SoNumero(xRECNO))
								Case aDetalhe[nCntFor,nCntFor2,1]=="ACAO"
									xACAO := SubStr(cBuffer,nPosIni,nTamanho)
							EndCase
						Next nCntFor2
						lContinua := .F.
					EndIf
				EndIf
			Next nCntFor
		Endif
	Else
		lContinua := .F.
	EndIf
EndDo
      //   1         2         3        4       5       6
Return( {xDATA,xOCORRENCI,xNOSSONUM,xRECNO,xOPERACAO,xACAO} )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLERLINHA  บAutor  ณ Kaique Sousa      บ Data ณ  06/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LerLinha(nHandle,nMaxLn)

Local cString := "" , nTotLidos :=0

Default nMaxLn := 1000

cString := Space(nMaxLn)
FReadLn(nHandle, @cString, nMaxLn) // Le uma linha ate CR+LF.
nTotLidos := Len(cString)+2

Return( {cString,nTotLidos} )