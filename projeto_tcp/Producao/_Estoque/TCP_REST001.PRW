/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório Impressão de Etiqueta                         !
+------------------+---------------------------------------------------------+
!Módulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! REST001                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressão de Etiqueta                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Rodrigo Favero                                          !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 12/07/2012                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! Rotina alterada para criar reguas de pro- ! Walter /  ! Lucas     ! 18/02/ !
! cessos para as tarefas de conexão e im-   ! T.I.      !    Chagas ! 2014   !
! pressão. Verificado que a configuração re-!           !           !        !
! passada estava sendo repassada com três   !           !           !        !
! dígitos. Verificado que no cadastro da CB5!           !           !        !
! o cadastro possui quatro dígitos, sendo   !           !           !        !
! assim modificado.                         !           !           !        !
! Também foi alterado para utilizar o para- !           !           !        !
! metro MV_PRTZE, caso seja necessário uti- !           !           !        !
! lizar outro cadastro, somente o conteúdo  !           !           !        !
! do parâmetro deverá ser alterado.         !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/
#include 'totvs.ch'
#INCLUDE "TOPCONN.CH"

//Rotina de impressão da etiqueta
User Function REST001()

Local aArea    := GetArea()
Local aPerg    := {}
local cAlias   := getNextAlias()
local cAliasTN3:= getNextAlias()
Local cPerg    := "REST001"
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
Private cDBNUMCAP := ''
Private cDBDTVENC := ''
Private cDescFor  := ''
Private lCon      := .F.
Private nCount    := 1
Private nQuant    := 0
PRIVATE cEnd:=""

aPerg := DefinePerg(cPerg)
if len(aPerg) > 0
	cProduto := aPerg[1]
	cPedido  := aPerg[2]
	nQuant   := aPerg[3]

	If Select("SB1") <> 0
		DBSelectArea("SB1")
		SB1->( DBCloseArea() )
	EndIf
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if SB1->(dbSeek(xFilial('SB1')+cProduto))
		cB1cod    := SB1->B1_COD
		cB1Desc   := SB1->B1_DESC
		cB1Um     := SB1->B1_UM
		U_XML01(SB1->B1_COD,SB1->B1_LOCPAD)
		cDBLocal  := cEnd
		//ALERT(cEnd)
		cB1CodBar := iif(empty(SB1->B1_CODBAR), SB1->B1_COD, SB1->B1_CODBAR)

		if Empty(cDBLocal)
		//	Alert("Produto sem endereço cadastrado, favor endereçar.")
			Return
		else
			if SB1->B1_MSBLQL == '1'
				Alert("Produto bloqueado.")
			else
				dbSelectArea("SB5")
				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial('SB5')+cProduto))
//				cB1APL := alltrim(SB5->B5_CEME)
				cB1APL := alltrim(SB5->B5_APLGER)
				If Empty(Alltrim(cB1APL))
					cB1APL := alltrim(SB5->B5_CEME)
				EndIf
				
				IF !EMPTY(cPedido)
				
					cQuery := " SELECT D1_DOC, D1_SERIE "
					cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
					cQuery += " WHERE D1_FILIAL = '" + SC7->C7_FILIAL + "'"
					cQuery += " AND D1_PEDIDO = '" + SC7->C7_NUM + "'"
					cQuery += " AND D1_ITEMPC = '" + SC7->C7_ITEM+ "'"
					cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
	
					If Select(cAlias) <> 0
						DBSelectArea(cAlias)
						DBCloseArea()
					EndIf
	
					TCQUERY cQuery New Alias (cAlias)
	
					cDBDoc   := (cAlias)->D1_DOC //(nº NF entrada)
					cDBSerie := (cAlias)->D1_SERIE //(da NF)
					cDBForne := SC7->C7_FORNECE //(cód. Fornecedor).
					cDBLoja  := SC7->C7_LOJA
					(cAlias)->(DBCloseArea())
					
					
					cQuery := " SELECT TN3_NUMCAP, TN3_DTVENC "
					cQuery += " FROM " + RetSqlName("TN3") + " TN3 "
					cQuery += " WHERE TN3_FILIAL = '" + xFilial('TN3') + "'"
					cQuery += "   AND TN3_FORNEC = '" + SC7->C7_FORNECE + "'"
					cQuery += "   AND TN3_LOJA = '" + SC7->C7_LOJA + "'"
					cQuery += "   AND TN3_CODEPI = '" + SB1->B1_COD + "'"
					cQuery += "   AND TN3_XDOC = '" + cDBDOC + "'"
					cQuery += "   AND TN3_XSERIE = '" + cDBSerie + "'"
					cQuery += "   AND TN3.D_E_L_E_T_ <> '*' "
					
					If Select(cAliasTN3) <> 0
						DBSelectArea(cAliasTN3)
						DBCloseArea()
					EndIf
	
					TCQUERY cQuery New Alias (cAliasTN3)
					
					IF !(CAliasTN3)->(EOF())
						cDBNUMCAP := (CAliasTN3)->TN3_NUMCAP
						cDBDTVENC := AllTrim(DTOC(STOD((CAliasTN3)->TN3_DTVENC)))
					ENDIF
					(cAliasTN3)->(DBCloseArea())
				ENDIF
				
				if EMPTY(cDBNUMCAP)
					cQuery := " SELECT TN3_NUMCAP, TN3_DTVENC "
					cQuery += " FROM " + RetSqlName("TN3") + " TN3 "
					cQuery += " WHERE TN3_FILIAL = '" + xFilial('TN3') + "'"
					cQuery += "   AND TN3_CODEPI = '" + SB1->B1_COD + "'"
					cQuery += "   AND TN3.D_E_L_E_T_ <> '*' AND TN3_NUMCAP != ' ' "
					
					If Select(cAliasTN3) <> 0
						DBSelectArea(cAliasTN3)
						DBCloseArea()
					EndIf
	
					TCQUERY cQuery New Alias (cAliasTN3)
					
					IF !(CAliasTN3)->(EOF())
						cDBNUMCAP := (CAliasTN3)->TN3_NUMCAP
						cDBDTVENC := AllTrim(DTOC(STOD((CAliasTN3)->TN3_DTVENC)))
					ENDIF
				ENDIF
					
				if !empty(cDBForne)
					dbSelectArea("SA2")
					dbSetOrder(1)
					dbSeek(xFilial('SA2')+cDBForne+cDBLoja)
					cDescFor := SA2->A2_NOME //(razão social fornecedor)
				endif
				
				
				Processa( {|lEnd| ConPrint(@lEnd)}, "Conectando com impressora...", "Aguarde...", .T.)
				if !lCon
					Alert("Não foi possível conectar com a impressora, verifique o cadastro de locais de impressão.")
				else
					Processa( {|lEnd| ProcEtiq(@lEnd)}, "Processando etiquetas...", "Aguarde...", .T.)
					msginfo("Etiqueta(s) Gerada(s)!")
				endif
			endif
		endif
	endif
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
	MSCBSay(60,nL+5, Padr(cB1CodBar, TamSx3("B1_CODBAR")[1]),"N","C","030,015")
	MSCBSAYBAR(50,nL+=10,cB1CodBar,"N","MB07",12,.F.,.F.,.T.,,2,1)
    
	if !empty(cDBNUMCAP)
		nL+=13
	else
		nL+=18
    endif
	
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


    if !empty(cDBNUMCAP)
		nL+=5
	
		//Dados de EPI
		MSCBSay( 08, nL, Padr("CA:",15),"N","0","040,028")
		MSCBSay( 28, nL, Padr(alltrim(cDBNUMCAP), 60),"N","0","040,028")
 		//Dados de EPI
		MSCBSay( 50, nL, Padr("Vencimento:",15),"N","0","040,028")
		MSCBSay(70, nL, Padr(alltrim(cDBDTVENC), 60),"N","0","040,028")
 
    endif 
    
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

DBSelectArea("SC7")
if ALLTRIM(funname()) != "MATA121"
	//Cria2SX1("REST001A")

	if Pergunte("REST001A",.T.)
		IF !EMPTY(mv_par02)
			SC7->(DBSetOrder(4))//C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
			SC7->(DBSeek(xFilial("SC7")+ mv_par01+ mv_par02))
		ENDIF
		aRet := {Mv_Par01, mv_par02, Mv_Par03}
	endif
else
	//CriaSX1(cPerg)
	if Pergunte(cPerg,.T.)
		//IF !EMPTY(mv_par02)
		//	SC7->(DBSetOrder(4))//C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
		//	SC7->(DBSeek(xFilial("SC7")+ mv_par01+ mv_par02))
		//ENDIF
		aRet := {SC7->C7_PRODUTO, SC7->C7_NUM, mv_par01}
	endif
endif

Return aRet

//+-----------------------------------------------------------------------------------------------+
//! Rotina para criação do CriaSX1 (grupo de parâmetros).                                         !
//+-----------------------------------------------------------------------------------------------+
/*Static Function CriaSX1(cPerg)                                                                                 //Consulta

//putSx1(cPerg, '01', 'Quantidade de etiquetas?', '', '', 'mv_ch1', 'N', 6 , 0, 0, 'G', '', "", '', '', 'mv_par01')

Return*/

//+-----------------------------------------------------------------------------------------------+
//! Rotina para criação do CriaSX1 (grupo de parâmetros).                                         !
//+-----------------------------------------------------------------------------------------------+
/*Static Function Cria2SX1(cPerg)                                                                                 //Consulta

//putSx1(cPerg, '01', 'Produto?', '', '', 'mv_ch1', 'C', TAMSX3("B1_COD")[1] , 0, 0, 'G', '', "SB1", '', '', 'mv_par01')
//putSx1(cPerg, '02', 'Pedido?', '', '', 'mv_ch2', 'C', TAMSX3("C7_NUM")[1] , 0, 0, 'G', '', "SC7", '', '', 'mv_par02')
//putSx1(cPerg, '03', 'Quantidade de etiquetas?', '', '', 'mv_ch3', 'N', 6 , 0, 0, 'G', '', "", '', '', 'mv_par03')

Return*/

User Function XML01(nProd,nLocal)
	Local cQry        := ''
	Local _stru       := {}
	Local aCpoBro     := {}
	Local oDlgLocal
	Local aCores  := {}
	Local nProd := nProd
	Local nLocal:= nLocal
	Private cPerg     := "TestSelec"
	Private lInverte  := .F.
	Private cMark     := GetMark()
	Private oMark     //Cria um arquivo de Apoio
	Private cTabSE1   := RetSQLName("SE1")
	Private cQuebra   := Chr(13)+Chr(10)
	Private cAliasSe1 := GetNextAlias()
	Private nNUMNF    := 0
	Private cQuantNF := ""
      
	//If Pergunte(cPerg,.T.)   // Perguntas do Relatorio
		cQry += CRLF + " SELECT BF_PRODUTO, BF_LOCALIZ, BF_QUANT "
		cQry += CRLF + " FROM " + RetSqlName("SBF") + ""
		cQry += CRLF + " WHERE BF_FILIAL = "+xFilial("SBF")+" AND BF_LOCAL = '"+nLocal+"' AND D_E_L_E_T_ <> '*' AND BF_PRODUTO = '"+nProd+"' "
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasSe1,.F.,.T.)
      
		AADD(_stru,{"OK"                    ,"C"     ,2          ,0         })
		AADD(_stru,{"PRODUTO"              ,"C"      ,11         ,0          })
		AADD(_stru,{"DESCRICAO"             ,"C"     ,50          ,0        })
		AADD(_stru,{"LOCALIZ"                  ,"C"  ,10          ,0        })
		AADD(_stru,{"SALDO"                  ,"N"     ,12          ,0       })

		//cArq:=Criatrab(_stru,.T.)

		//DBUSEAREA(.t.,,carq,"TTRB") //Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)

		oTempTable := FWTemporaryTable():New( "TTRB" )
		oTemptable:SetFields( _stru )
		oTempTable:Create()
		carq := oTempTable:GetRealName()

     //DbSelectArea("SE1") 
		(cAliasSe1)->(dbGotop())
		
		if (cAliasSe1)->(Eof())
			Alert("Produto sem endereço cadastrado, favor endereçar.")
			(cAliasSe1)->(DbCloseArea())
			TTRB->(DbCloseArea())
			freeObj(oTempTable)
			oTemptable := nil
			Return
		endif
		    
		While (cAliasSe1)->(!Eof())
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)

			TTRB->PRODUTO     :=   (cAliasSe1)->BF_PRODUTO
			TTRB->DESCRICAO   :=   POSICIONE("SB1",1,xFilial("SB1")+(cAliasSe1)->BF_PRODUTO,"B1_DESC")          
			TTRB->LOCALIZ :=   (cAliasSe1)->BF_LOCALIZ
			TTRB->SALDO :=   (cAliasSe1)->BF_QUANT
			MsunLock()
			(cAliasSe1)->(DbSkip())
		Enddo
      
     //Define as cores dos itens de legenda. 
		aCores := {}
     //Define quais colunas (campos da TTRB) serao exibidas na MsSelect 
		aCpoBro     := {{ "OK"                    ,, "Marcar"              ,"@!"},;        // @! @1!   @x " @E 999,999,999.99"
						{ "PRODUTO"               ,, "Produto"             ,"@!"},;
						{ "DESCRICAO"              ,, "Descricao"            ,"@!"},;
						{ "LOCALIZ"                ,, "Endereço"             ,"@!"},;
						{ "SALDO"                ,, "Saldo por/Endereço"             ," @E 999,999,999.99"}}

     //Cria uma Dialog                           
		cQuantNF := cValtoChar (nNUMNF)
		DEFINE MSDIALOG oDlg TITLE "Escolha um endereço para ser feita a impressão da etiqueta." From 9,0 To 315,1000 PIXEL
		DbSelectArea("TTRB")
		DbGotop()
      
     //Cria a MsSelect 
		oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{035,010,120,500},,,,,) //aCores) {17,1,150,400 {025,010,120,460}
		oMark:bMark := {| | Disp()}
     //Exibe a Dialog 
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| if(valid(),oDlg:End(),.F.)},{|| oDlg:End()})
      
     //Fecha a Area e elimina os arquivos de apoio criados em disco. 
		TTRB->(DbCloseArea())
		//MSGALERT("Dados Atualizados!", "Gravacao ok")
       (cAliasSe1)->(DbCloseArea())
       freeObj(oTempTable)
		oTemptable := nil

Return

//Funcao executada ao Marcar/Desmarcar um registro.    
Static Function Disp()
	
		RecLock("TTRB",.F.)
		If Marked("OK")
			TTRB->OK := cMark
		    //MSGALERT(cMark, "teste")   
		Else
			TTRB->OK := ""
		Endif
		//MSGALERT(cMark, "teste 222")    
		MSUNLOCK()
		oMark:oBrowse:Refresh()
 
Return()

Static Function valid()
Local aAreaAnt := GETAREA()
Local nCont := 0
local  lRet:= .T.

dbSelectArea("TTRB") 
//dbSetOrder(1) 
dbGotop() 
cEnd:= ""     
cProd:="" 
While TTRB->(!EoF())                
	If TTRB->OK == cMark 
	    nCont++
	    cEnd:=TTRB->LOCALIZ
	    cProd:= TTRB->PRODUTO 
	EndIf 
TTRB->(dbskip())      
Enddo
//TTRB->(DbCloseArea())
If nCont>1
		alert("NÃO É PERMITIDO MARCAR MAIS DE UM ENDEREÇO PARA IMPRESSÃO.")
		lRet:= .F.
		cEnd:= ""
		cProd:=""
		
Elseif nCont == 0
		alert("É NECESSARIO MARCAR AO MENOS UM ENDEREÇO PARA IMPRESSÃO.")
		lRet:= .F.
		cEnd:= ""
		cProd:=""
Endif

If !EMPTY(cEnd)
	lRet:=  MSGYESNO( "Você confirma a impressão da etiqueta produto "+cProd+""+cQuebra+" para o endereço "+cEnd, "Impressão de Etiqueta endereço "+cEnd)
	If lRet == .F.
		cEnd:=""
	Endif
Endif

RESTAREA(aAreaAnt) 
Return lRet

