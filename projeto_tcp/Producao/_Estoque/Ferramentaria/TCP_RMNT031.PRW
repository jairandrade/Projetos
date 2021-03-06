/*---------------------------------------------------------------------------+
!                             FICHA T�CNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relat�rio Impress�o de Etiqueta                         !
+------------------+---------------------------------------------------------+
!M�dulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! REST001                                                 !
+------------------+---------------------------------------------------------+
!Descri��o         ! Impress�o de Etiqueta                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Rodrigo Favero                                          !
+------------------+---------------------------------------------------------+
!Data de Cria��o   ! 12/07/2012                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZAC�ES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descri��o detalhada da atualiza��o      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! Rotina alterada para criar reguas de pro- ! Walter /  ! Lucas     ! 18/02/ !
! cessos para as tarefas de conex�o e im-   ! T.I.      !    Chagas ! 2014   !
! press�o. Verificado que a configura��o re-!           !           !        !
! passada estava sendo repassada com tr�s   !           !           !        !
! d�gitos. Verificado que no cadastro da CB5!           !           !        !
! o cadastro possui quatro d�gitos, sendo   !           !           !        !
! assim modificado.                         !           !           !        !
! Tamb�m foi alterado para utilizar o para- !           !           !        !
! metro MV_PRTZE, caso seja necess�rio uti- !           !           !        !
! lizar outro cadastro, somente o conte�do  !           !           !        !
! do par�metro dever� ser alterado.         !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/
#include 'totvs.ch'
#INCLUDE "TOPCONN.CH"
                  
User Function RMNT031()
Private cCadastro := "Etiquetas Ferramentas"
Private aRotina := {}
Private cAlias := "SBF"
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  	, "AxPesqui"   	,0,1})  
	AADD(aRotina,{"Visualizar" 	, "AxVisual"   	,0,2})
	AADD(aRotina,{"Imprimir" 	, "U_RMNT031P" 	,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

  mBrowse(006,001,022,075,cAlias,,,,,,)
Return

//Rotina de impress�o da etiqueta
User Function RMNT031P()

Local aArea    := GetArea()
Local aPerg    := {}
local cAlias   := getNextAlias()
Local cPerg    := "RMNT031"
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
Private cDBSerie  := ''
Private lCon      := .F.
Private nCount    := 1
Private nQuant    := 0
                
Cria2SX1(cPerg)
Pergunte(cPerg)
                      
nQuant := MV_PAR01

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
if SB1->(dbSeek(xFilial('SB1')+SBF->BF_PRODUTO))
	cB1cod    := SB1->B1_COD
	cB1Desc   := SB1->B1_DESC
	cB1Um     := SB1->B1_UM
	cDBLocal  := SBF->BF_LOCALIZ
	cB1CodBar := iif(empty(SB1->B1_CODBAR), SB1->B1_COD, SB1->B1_CODBAR)
	cDBSerie  := Alltrim(SBF->BF_NUMSERI)

	if Empty(cDBLocal)
		Alert("Produto sem endere�o cadastrado, favor endere�ar.")
	else
		if SB1->B1_MSBLQL == '1'
			Alert("Produto bloqueado.")
		else
			dbSelectArea("SB5")
			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial('SB5')+cProduto))
			cB1APL := alltrim(SB5->B5_CEME)
			Processa( {|lEnd| ConPrint(@lEnd)}, "Conectando com impressora...", "Aguarde...", .T.)
			if !lCon
				Alert("N�o foi poss�vel conectar com a impressora, verifique o cadastro de locais de impress�o.")
			else           
				Processa( {|lEnd| ProcEtiq(@lEnd)}, "Processando etiquetas...", "Aguarde...", .T.)
			endif
		endif
	endif
endif
RestArea(aArea)

Return

//+-----------------------------------------------------------------------------------------------+
//! Tela de processamento para conex�o da impressora...                                           !
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

//Inicia a impress�o
while nCount <= nQuant .and. !lCancel

	IncProc('Processando etiqueta ' +cValToChar(nCount)+ ' de ' +cValToChar(nQuant)+ '...')
	ProcessMessage()

	nL := 0
	MSCBLOADGRF("LOGO_TCP.GRF")
	MSCBBEGIN(1,6, )
	MSCBBEGIN(1,6)

	//Impress�o da imagem
    MSCBGRAFIC(08,05,"LOGO_TCP")

	//C�digo de barras
	MSCBSay(60,nL+5, Padr(cB1CodBar, TamSx3("B1_CODBAR")[1]),"N","C","030,015")
	MSCBSAYBAR(50,nL+=10,cB1CodBar,"N","MB07",12,.F.,.F.,.T.,,2,1)
	nL+=18

	// Descri��o produto
	MSCBSay( 08, nL,"Descricao:","N","0","040,028")
	aAux := justificaTXT(cB1Desc, 40)//Quebra a descri��o do produto
	for nCnt := 1 to len(aAux)
		MSCBSAY(28,nL,aAux[nCnt],"N","0","040,028")
		nL += 5
	next nCnt

	if len(aAux) < 2
		nL += 5
	endif
	//Localiza�ao
	MSCBSay( 08, nL, Padr("Localizacao:",15),"N","0","040,028")
	MSCBSay( 28, nL, Padr(alltrim(cDBLocal),30),"N","0","040,028")
	nL+=5

	//C�digo de barras
	MSCBSay(60,nL+5, Padr(cDBSerie, TamSx3("BF_NUMSERI")[1]),"N","C","030,015")
	MSCBSAYBAR(50,nL+=10,"XXXX"+cDBSerie,"N","MB07",12,.F.,.F.,.T.,,2,1)//for�a o tamanho da etiqueta iniciando com X
	nL+=18

	MSCBEND()
	MSCBCLOSEPRINTER()
	nCount++
enddo

if lCancel
	MsgStop("Processamento cancelado pelo operador.")
endif

Return



//+-----------------------------------------------------------------------------------------------+
//! Rotina para cria��o do CriaSX1 (grupo de par�metros).                                         !
//+-----------------------------------------------------------------------------------------------+
Static Function Cria2SX1(cPerg)                                                                                 //Consulta

//putSx1(cPerg, '01', 'Quantidade de etiquetas?', '', '', 'mv_ch1', 'N', 6 , 0, 0, 'G', '', "", '', '', 'mv_par01')

Return