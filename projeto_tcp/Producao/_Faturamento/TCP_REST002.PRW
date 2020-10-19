/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório Impressão de Etiqueta                         !
+------------------+---------------------------------------------------------+
!Módulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! REST002                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressão de Etiqueta                                   !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/
#include 'totvs.ch'
#INCLUDE "TOPCONN.CH"

//Rotina de impressão da etiqueta
User Function REST002()

Local aArea    := GetArea()
Local aPerg    := {}
local cAlias   := getNextAlias()
Local cProduto := ""
Local cPedido  := ""
Local cQuery   := ""

Private aAux      := {}
Private cB1CodBar := ''
Private cB1cod    := ''
Private cB1Desc   := ''
Private cB1Um     := ''
Private cB1APL    := ""
Private cDBLocal  := ''
Private cDBDoc    := ''
Private cDBSerie  := ''
Private cDBForne  := ''
Private cDBLoja   := ''
Private cDescFor  := ''
Private lCon      := .F.
Private nCount    := 1
Private nQuant    := 0  
Private lImpAux   := .T.

If MSgYesNo('Deseja imprimir as etiquetas para a nota posicionada?')

	cQuery += " SELECT D1_DOC, D1_SERIE, D1_COD, D1_FORNECE, D1_LOJA, D1_QUANT "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " WHERE D1_FILIAL = '" + SF1->F1_FILIAL + "'"
	cQuery += " AND D1_DOC = '" + SF1->F1_DOC + "'"
	cQuery += " AND D1_SERIE = '" + SF1->F1_SERIE+ "'"
	cQuery += " AND D1_FORNECE = '" + SF1->F1_FORNECE+ "'"
	cQuery += " AND D1_LOJA = '" + SF1->F1_LOJA+ "'"
	cQuery += " AND SD1.D_E_L_E_T_ <> '*' "

	If Select(cAlias) <> 0
		DBSelectArea(cAlias)
		DBCloseArea()
	EndIf

	TCQUERY cQuery New Alias (cAlias)
	
    (cAlias)->(DbGoTop())
                               
	While !(cAlias)->(EOF())
		cDBDoc   := (cAlias)->D1_DOC //(nº NF entrada)
		cDBSerie := (cAlias)->D1_SERIE //(da NF)
		cDBForne := (cAlias)->D1_FORNECE //(cód. Fornecedor).
		cDBLoja  := (cAlias)->D1_LOJA
		cProduto := (cAlias)->D1_COD
		nQuant	 := (cAlias)->D1_QUANT

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		if SB1->(dbSeek(xFilial('SB1')+cProduto))
			cB1cod    := SB1->B1_COD
			cB1Desc   := SB1->B1_DESC
			cB1Um     := SB1->B1_UM
			cDBLocal  := SB1->B1_ZLOCALI
			cB1CodBar := iif(empty(SB1->B1_CODBAR), SB1->B1_COD, SB1->B1_CODBAR)

   			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial('SA2')+cDBForne+cDBLoja)
			cDescFor := SA2->A2_COD+'/'+SA2->A2_LOJA+' - '+SA2->A2_NOME //(razão social fornecedor)


//			if Empty(cDBLocal)
//				Alert("Produto sem endereço cadastrado, favor endereçar.")
//			else
				if SB1->B1_MSBLQL == '1'
					Alert("Produto bloqueado.")
           	    else
					Processa( {|lEnd| ConPrint(@lEnd)}, "Conectando com impressora...", "Aguarde...", .T.)
					if !lCon
						Alert("Não foi possível conectar com a impressora, verifique o cadastro de locais de impressão.")
					else
						Processa( {|lEnd| ProcEtiq(@lEnd)}, "Processando etiquetas...", "Aguarde...", .T.)
//						msginfo("Etiqueta(s) Gerada(s)!")
					endif
				endif
//			endif
		endif
		(cAlias)->(DbSkip())
	EndDo
	msginfo("Etiqueta(s) Gerada(s)!")
endif                                          

RestArea(aArea)

Return

//+-----------------------------------------------------------------------------------------------+
//! Tela de processamento para conexão da impressora...                                           !
//+-----------------------------------------------------------------------------------------------+
Static Function ConPrint(lCancel)

Local nTent := 1
Local _PrtZe := SUPERGETMV('MV_PRTZE', .F., '0001')
ProcRegua( 3 ) // regua boba

while !lCon .And. !lCancel .and. nTent <= 3
	IncProc('Tentativa ' + cValToChar(nTent) + ' de 3...')
	ProcessMessage()
	lCon := CB5SetImp(_PrtZe,IsTelNet())
	nTent++
enddo

return

//+-----------------------------------------------------------------------------------------------+
//! Tela de processamento para as etiquetas...                                                    !
//+-----------------------------------------------------------------------------------------------+
Static Function ProcEtiq(lCancel)

Local nL   := 0
Local nCnt := 0

ProcRegua( nQuant )

//Inicia a impressão                 

If lImpAux

	nL := 0
	MSCBLOADGRF("LOGO_TCP.GRF")
	MSCBBEGIN(1,6, )
	MSCBBEGIN(1,6)

	//Impressão da imagem
    MSCBGRAFIC(08,05,"LOGO_TCP")

	//Código de barras
	MSCBSay(30,nL+5, "NF: "+Padr(cDBDoc+cDBSerie, 12),"N","C","030,015")
	MSCBSAYBAR(30,nL+=10,cDBDoc+cDBSerie,"N","MB07",12,.F.,.F.,.T.,,2,1)
	nL+=18

	//Código de barras
	MSCBSay(20,nL+5, "Forn: "+Padr(cDBForne+cDBLoja, 10),"N","C","030,015")
	MSCBSAYBAR(30,nL+=10,cDBForne+cDBLoja,"N","MB07",12,.F.,.F.,.T.,,2,1)

	MSCBEND()
	MSCBCLOSEPRINTER()
    
	lImpAux := .F.
EndIf



nCount := 1
while nCount <= nQuant .and. !lCancel

	IncProc('Processando etiqueta ' +cValToChar(nCount)+ ' de ' +cValToChar(nQuant)+ '...')
	ProcessMessage()

	nL := 0
	MSCBLOADGRF("LOGO_TCP.GRF")
	MSCBBEGIN(1,6, )
	MSCBBEGIN(1,6)

	//Impressão da imagem
    MSCBGRAFIC(08,05,"LOGO_TCP")

	//Código de barras
	MSCBSay(40,nL+5, Padr(cB1CodBar, TamSx3("B1_CODBAR")[1]),"N","C","030,015")
	MSCBSAYBAR(30,nL+=10,cB1CodBar,"N","MB07",12,.F.,.F.,.T.,,2,1)
	nL+=18

	// Descrição produto
	MSCBSay( 08, nL,"Descricao:","N","0","040,028")
	aAux := justificaTXT(cB1Desc, 40)//Quebra a descrição do produto
	for nCnt := 1 to len(aAux)
		MSCBSAY(28,nL,aAux[nCnt],"N","0","040,028")
		nL += 5
	next nCnt

	if len(aAux) < 2
		nL += 5
	endif

	//Aplicaçao do produto
	MSCBSay( 08, nL, Padr("Aplicacao:",15),"N","0","040,028")
	aAux := {}
	aAux := justificaTXT(cB1APL, 40)//Quebra a aplicação do produto
	for nCnt := 1 to len(aAux)
		if nCnt > 1
			nL+=5
		endif
		MSCBSAY(28,nL,aAux[nCnt],"N","0","040,028")
	next nCnt

	if len(aAux) < 2
		nL+=5
	endif
	nL+=5

	//Localizaçao
	MSCBSay( 08, nL, Padr("Localizacao:",15),"N","0","040,028")
	MSCBSay( 28, nL, Padr(alltrim(cDBLocal),30),"N","0","040,028")
	nL+=5

	//Nota fiscal
	MSCBSay( 08, nL, Padr("Nota Fiscal:",15),"N","0","040,028")
	MSCBSay( 28, nL, Padr(alltrim(cDBDoc),30),"N","0","040,028")
	nL+=5

	//Razao Social
	MSCBSay( 08, nL, Padr("Fornecedor:",15),"N","0","040,028")
	MSCBSay( 28, nL, Padr(alltrim(cDescFor), 60),"N","0","040,028")

	MSCBEND()
	MSCBCLOSEPRINTER()
	nCount++
enddo

if lCancel
	MsgStop("Processamento cancelado pelo operador.")
endif

Return

//+-----------------------------------------------------------------------------------------------+
//! Define perguntas para a rotina                                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function DefinePerg(cPerg)

Local aRet := {}

if ALLTRIM(funname()) != "MATA121"
	Cria2SX1("REST001A")

	DBSelectArea("SC7")
	if Pergunte("REST001A",.T.)
		SC7->(DBSetOrder(4))//C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
		SC7->(DBSeek(xFilial("SC7")+ mv_par01+ mv_par02))

		aRet := {Mv_Par01, SC7->C7_NUM, Mv_Par03}
	endif
else
	CriaSX1(cPerg)
	if Pergunte(cPerg,.T.)
		aRet := {SC7->C7_PRODUTO, SC7->C7_NUM, mv_par01}
	endif
endif

Return aRet

//+-----------------------------------------------------------------------------------------------+
//! Rotina para criação do CriaSX1 (grupo de parâmetros).                                         !
//+-----------------------------------------------------------------------------------------------+
Static Function CriaSX1(cPerg)                                                                                 //Consulta

//putSx1(cPerg, '01', 'Quantidade de etiquetas?', '', '', 'mv_ch1', 'N', 6 , 0, 0, 'G', '', "", '', '', 'mv_par01')

Return

