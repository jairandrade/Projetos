#include 'protheus.ch'


/*/{Protheus.doc} Img01
Impressão de produtos

@author Rafael Ricardo Vieceli
@since 07/08/2015
@version 1.0
/*/
User Function Img01()

	Local cCodigo,sConteudo,cTipoBar, nX
	Local nqtde 	:= If(len(paramixb) >= 1,paramixb[ 1],NIL)
	Local cCodSep 	:= If(len(paramixb) >= 2,paramixb[ 2],NIL)
	Local cCodID 	:= If(len(paramixb) >= 3,paramixb[ 3],NIL)
	Local nCopias	:= If(len(paramixb) >= 4,paramixb[ 4],0)
	Local cNFEnt  	:= If(len(paramixb) >= 5,paramixb[ 5],NIL)
	Local cSeriee  := If(len(paramixb) >= 6,paramixb[ 6],NIL)
	Local cFornec  := If(len(paramixb) >= 7,paramixb[ 7],NIL)
	Local cLojafo  := If(len(paramixb) >= 8,paramixb[ 8],NIL)
	Local cArmazem := If(len(paramixb) >= 9,paramixb[ 9],NIL)
	Local cOP      := If(len(paramixb) >=10,paramixb[10],NIL)
	Local cNumSeq  := If(len(paramixb) >=11,paramixb[11],NIL)
	Local cLote    := If(len(paramixb) >=12,paramixb[12],NIL)
	Local cSLote   := If(len(paramixb) >=13,paramixb[13],NIL)
	Local dValid   := If(len(paramixb) >=14,paramixb[14],NIL)
	Local cCC  		:= If(len(paramixb) >=15,paramixb[15],NIL)
	Local cLocOri  := If(len(paramixb) >=16,paramixb[16],NIL)
	Local cOPREQ   := If(len(paramixb) >=17,paramixb[17],NIL)
	Local cNumSerie:= If(len(paramixb) >=18,paramixb[18],NIL)
	Local cOrigem  := If(len(paramixb) >=19,paramixb[19],NIL)
	Local cEndereco:= If(len(paramixb) >=20,paramixb[20],NIL)
	Local cPedido  := If(len(paramixb) >=21,paramixb[21],NIL)
	Local nResto   := If(len(paramixb) >=22,paramixb[22],0)
	Local cItNFE   := If(len(paramixb) >=23,paramixb[23],NIL)
	Local nCnt
	Local aAux := {}
	Local nLinha := 0

	cLocOri := If(cLocOri==cArmazem,' ',cLocOri)
	nQtde   := If(nQtde==NIL,SB1->B1_QE,nQtde)
	cCodSep := If(cCodSep==NIL,'',cCodSep)

	SB5->( dbSetOrder(1) )
	SB5->( dbSeek( xFilial("SB5") + SB1->B1_COD ) )


	IF nResto > 0
		nCopias++
	EndIF

	For nX := 1 to nCopias

		nLinha := 0

		MSCBBEGIN(1,6)

		MSCBSay(60,nLinha+5, alltrim(SB1->B1_CODBAR),"N","C","030,015")
		MSCBSAYBAR(50,nLinha+=10, alltrim(SB1->B1_CODBAR),"N","MB07",12,.F.,.F.,.T.,,2,1)
		nLinha+=20

		// Descrição produto
		MSCBSay( 08, nLinha,"Descricao:","N","0","040,028")
		aAux := JustificaTXT( IIF(Empty(SB5->B5_CEME),SB1->B1_DESC,SB5->B5_CEME) , 40)//Quebra a descrição do produto
		For nCnt := 1 to len(aAux)
			MSCBSAY(28,nLinha,aAux[nCnt],"N","0","040,028")
			nLinha += 5
		Next nCnt

		IF len(aAux) < 2
			nLinha += 5
		EndIF

		//Aplicaçao do produto
		MSCBSay( 08, nLinha, Padr("Aplicacao:",15),"N","0","040,028")
		aAux := {}
		aAux := justificaTXT(SB5->B5_APLGER, 40)//Quebra a aplicação do produto
		for nCnt := 1 to len(aAux)
			if nCnt > 1
				nLinha+=5
			endif
			MSCBSAY(28,nLinha,aAux[nCnt],"N","0","040,028")
		next nCnt

		if len(aAux) < 2
			nLinha+=5
		endif
		nLinha+=5


		IF !Empty(cEndereco)
			MSCBSay( 08, nLinha, "Localizacao: " + cEndereco,"N","0","040,028")
			nL+=5
		EndIF

		//se for a partir de nota
		IF !Empty(cNFEnt) .And. !Empty(cSeriee)

			IF SA2->(A2_COD+A2_LOJA) != cFornec + cLojafo
				SA2->( dbSetOrder(1) )
				SA2->( dbSeek( xFilial("SA2") + cFornec + cLojafo ) )
			EndIF

			//Nota fiscal
			MSCBSay( 08, nLinha, "Nota Fiscal: " + alltrim(cNFEnt) + "/" + cSeriee ,"N","0","040,028")
			nLinha+=5
			//Razao Social
			MSCBSay( 08, nLinha, "Fornecedor:  " + SA2->A2_NOME,"N","0","040,028")

		EndIF

		MSCBInfoEti("Produto","65X100")

		sConteudo := MSCBEND()

	Next

Return sConteudo