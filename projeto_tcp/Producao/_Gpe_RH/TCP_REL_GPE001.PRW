#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#include "fileio.ch"

#DEFINE CRLF (chr(13)+chr(10))


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
! Versão           ! Protheus 11                                             !
+------------------+---------------------------------------------------------+
! Tipo             ! Relatorio                                               !
+------------------+---------------------------------------------------------+
! Modulo           ! GPE                                                     !
+------------------+---------------------------------------------------------+
! Nome             ! GPE001                                                  !
+------------------+---------------------------------------------------------+
! Descricao        ! Impressão de informações do funcionario.                !
+------------------+---------------------------------------------------------+
! Autor            ! HUGO                                                    !
+------------------+---------------------------------------------------------+
! Data de Criacao  ! 27/03/2015                                              !
+------------------+---------------------------------------------------------+

*/

User Function GPE001()

	Local oPrint
	Local cPerg		:= "GPE001"
	Local cTitulo	:= "FICHA DE REGISTRO"
	
	CriaPerg(cPerg)
	Pergunte(cPerg,.T.)
	
	oPrint	:= TMSPrinter():New( cTitulo )
	oPrint:SetPortrait() //Retrato
	//oPrint:SetLandscape() //Paisagem

	//Busca os registros a serem impressos
	BuscaDados()

	PrintPag( oPrint, cTitulo )
	oPrint:Preview()

Return

	
/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! PrintPag                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Impressão do relatorio.                                 !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 31/03/2015                                              !
+------------------+--------------------------------------------------------*/
Static Function PrintPag(oPrint, cTitulo)

	Local cStartPath:= GetSrvProfString("StartPath","")
	Local cBmp 		:= cStartPath + "lgmid.png" //Logo
	Local oFont1	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)// Fonte o Titulo Negrito
	Local oFont2	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)// Fonte do cabeçalho negrito
	Local oFont3	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)// Fonte do cabeçalho
	Local oFont4	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)// Fonte do Sub-Titulo Negrito
	Local oFont5	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)// Fonte do Sub-Titulo
	
	Local nLinIni	:= 0150
	Local nColIni	:= 0150
	Local nLinFim	:= 3000
	Local nColFim	:= 2400
	
	Local nLinCabec	:= nLinIni + 250
	Local nColCabec	:= nColIni + 150
	
	Local nLinItens	:= nLinCabec + 700
	Local nColItens	:= nColIni + 150
	Local nColItMeio:= nColItens + 1000
	
	DbSelectArea('QAA')
	QAA->(DbGoTop())
	
	While !QAA->(EOF())
	
		//Inicio de pagina
		oPrint:StartPage()
		
		//oPrint:Say(nLinIni + 350,nColIni + 350,"teste"+transf(SM0->M0_CGC,pesqpict("SA1","A1_CGC")),oFont1) // CGC
	
		oPrint:Box(nLinIni,nColIni,nLinFim,nColFim)  // Margem principal
		oPrint:Box(nLinCabec,nColCabec - 50,nLinCabec + 600,nColFim - 100)  // Retangulo do Cabeçalho
		oPrint:Box(nLinItens, nColItens - 50,nLinItens + 1000  ,nColFim - 100)  // Retangulo dos Itens
			
		oPrint:SayBitmap(nLinIni + 10, nColIni + 10,cBmp, 210, 210) //Logo
		
		oPrint:Say(nLinIni + 100,nColIni + 850, cTitulo, oFont1) // Titulo
	
		//CABEÇALHO
		oPrint:Say(nLinCabec + 050, nColCabec, SM0->M0_NOMECOM, oFont3) // nome da empresa
		oPrint:Say(nLinCabec + 050, nColCabec + 1500, 'Filial: ' + SM0->M0_FILIAL, oFont3) // Filial
		
		oPrint:Say(nLinCabec + 150, nColCabec, SM0->M0_ENDCOB, oFont3) // Endereço
		
		oPrint:Say(nLinCabec + 250, nColCabec, AllTrim(SM0->M0_CIDCOB) + ' - ' + SM0->M0_ESTCOB, oFont3) // Cidade
		oPrint:Say(nLinCabec + 250, nColCabec + 1500, 'CEP: ' + transf(SM0->M0_CEPCOB,pesqpict("SA1","A1_CEP")), oFont3) // CEP
		
		oPrint:Say(nLinCabec + 350, nColCabec, 'CNPJ: ' + transf(SM0->M0_CGC,pesqpict("SA1","A1_CGC")), oFont3) // CNPJ
		oPrint:Say(nLinCabec + 350, nColCabec + 0750, 'C.N.A.E.:'+ SM0->M0_CNAE, oFont3) // CNAE
		oPrint:Say(nLinCabec + 350, nColCabec + 1500, 'Cod. Minic.:'+ SM0->M0_CODMUN, oFont3) // Cod Minicipio
		
		oPrint:Say(nLinCabec + 450, nColCabec, 'No Ficha', oFont4) 
		oPrint:Say(nLinCabec + 500, nColCabec, QAA->RA_REGISTR, oFont2) // Ficha
		oPrint:Say(nLinCabec + 450, nColCabec + 0300, 'Matricula', oFont4)
		oPrint:Say(nLinCabec + 500, nColCabec + 0300, QAA->RA_MAT, oFont2) // Matricula
		oPrint:Say(nLinCabec + 450, nColCabec + 0550, 'Nome', oFont4) 
		oPrint:Say(nLinCabec + 500, nColCabec + 0550, QAA->RA_NOME, oFont2) // Nome do Funcionario
		
		//ITENS
		oPrint:Say(nLinItens + 0050, nColItens, 'Centro Custo', oFont4) 
		oPrint:Say(nLinItens + 0100, nColItens, QAA->RA_CC, oFont5) 
		oPrint:Say(nLinItens + 0050, nColItMeio, 'Descr. CCusto', oFont4) 
		oPrint:Say(nLinItens + 0100, nColItMeio, QAA->CTT_DESC01, oFont5) 
		
		oPrint:Say(nLinItens + 0200, nColItens, 'Sexo', oFont4)
		oPrint:Say(nLinItens + 0250, nColItens, IIF(QAA->RA_SEXO = 'M', 'Masculino', 'Feminino'), oFont5)
		oPrint:Say(nLinItens + 0200, nColItMeio, 'Naturalid UF', oFont4)
		oPrint:Say(nLinItens + 0250, nColItMeio, QAA->RA_NATURAL, oFont5) 
		
		oPrint:Say(nLinItens + 0350, nColItens, 'Nacionalid.', oFont4) 
		oPrint:Say(nLinItens + 0400, nColItens, QAA->NACIONAL, oFont5)
		oPrint:Say(nLinItens + 0350, nColItMeio, 'Data Admis.', oFont4) 
		oPrint:Say(nLinItens + 0400, nColItMeio, DTOC(STOD(QAA->RA_ADMISSA)), oFont5)
		
		oPrint:Say(nLinItens + 0500, nColItens, 'Cod. Funcao.', oFont4) 
		oPrint:Say(nLinItens + 0550, nColItens, QAA->RA_CODFUNC, oFont5)
		oPrint:Say(nLinItens + 0500, nColItMeio, 'Desc. Funcao', oFont4) 
		oPrint:Say(nLinItens + 0550, nColItMeio, QAA->RJ_DESC, oFont5)
		
		oPrint:Say(nLinItens + 0650, nColItens, 'Desc. Gr. Inst.', oFont4) 
		oPrint:Say(nLinItens + 0700, nColItens, QAA->GRINSTRU, oFont5)
		
		oPrint:Say(nLinItens + 0800, nColItens, 'Desc. Cargo', oFont4) 
		oPrint:Say(nLinItens + 0850, nColItens, QAA->Q3_DESCSUM, oFont5)
		

		//Fim de pagina
		oPrint:EndPage()
	
		QAA->(DbSkip())
	EndDo
Return
	

/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! BuscaDados                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Query de busca dados dos funcionarios.                  !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/	

Static Function BuscaDados()

	Local nTot 		:= 0
	
	cQuery := "           SELECT "
	cQuery += "           RA_FILIAL, "
	cQuery += "           RA_NOME, "
	cQuery += "           RA_MAT, "
	cQuery += "           RA_REGISTR, "
	cQuery += "           RA_CC,  "
	cQuery += "           CTT_DESC01, "
	cQuery += "           RA_SEXO, "
	cQuery += "           RA_NATURAL, "
	cQuery += "           RA_NACIONA, "
	cQuery += "           RA_ADMISSA, "
	cQuery += "           RA_CODFUNC, "
	cQuery += "           RJ_DESC, "
	cQuery += "           RA_CARGO, "
	cQuery += "           Q3_DESCSUM, "
	cQuery += "           RA_GRINRAI, "
	cQuery += "           SX5.X5_DESCRI GRINSTRU, "
	cQuery += "           SX5B.X5_DESCRI NACIONAL"
	cQuery += "           FROM " + RetSqlName('SRA') + " SRA "
	cQuery += "           INNER JOIN " + RetSqlName('CTT') + " CTT "
	cQuery += "           ON (SRA.RA_FILIAL = CTT.CTT_FILIAL AND SRA.RA_CC = CTT.CTT_CUSTO) "
	cQuery += "           INNER JOIN " + RetSqlName('SX5') + " SX5 "
	cQuery += "           ON (SX5.X5_TABELA = '26' AND SX5.X5_CHAVE = SRA.RA_GRINRAI ) "
	cQuery += "           INNER JOIN " + RetSqlName('SX5') + " SX5B "
	cQuery += "           ON (SX5B.X5_TABELA = '34' AND SX5B.X5_CHAVE = SRA.RA_NACIONA ) "
	cQuery += "           INNER JOIN " + RetSqlName('SRJ') + " SRJ "
	cQuery += "           ON (SRJ.RJ_FUNCAO = SRA.RA_CODFUNC) "
	cQuery += "           INNER JOIN " + RetSqlName('SQ3') + " SQ3 "
	cQuery += "           ON (SQ3.Q3_CARGO = SRA.RA_CARGO) "
	cQuery += "           WHERE "
	cQuery += "           SRA.RA_FILIAL = '" + xFilial('SRA') + "' "
	cQuery += "           AND SRA.RA_MAT BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += "           AND SRA.D_E_L_E_T_ <> '*' "
	cQuery += "           AND SX5.D_E_L_E_T_ <> '*' "
	cQuery += "           AND SRJ.D_E_L_E_T_ <> '*' "
	cQuery += "           AND SQ3.D_E_L_E_T_ <> '*' "
	cQuery += "           ORDER BY SRA.RA_MAT "


	MemoWrite( "E:\Temp\GPE001.txt", cQuery )


//Verifica se a area já existe e fecha para ser recriada.
	If (Select("QAA")) <> 0
		dbselectarea("QAA")
		QAA->(dbclosearea())
	EndIf

	TcQuery	cQuery New Alias 'QAA'

//Pega a quantidade de linhas
	DbSelectArea('QAA')
	Count to nTot
	QAA->(DbGoTop())
	
	
	//Conout("WFPCO001 - nTot: " + cEmpTCP + " - " + cFilTCP + " - " + cCodCont + " - " + cAprRep)

//Alert(nTot)

Return

/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Descricao         ! Função para criação das perguntas na SX1	             !
+------------------+---------------------------------------------------------+
!Autor             ! Hugo                                                    !
+------------------+---------------------------------------------------------+
*/

Static Function CriaPerg(cPerg)

//Cria perguntas se não existir
//Grupo de Perguntas
//    cGrupo,cOrdem ,cPergunt             		,cPergSpa            		,cPergEng	            	,cVar     ,cTipo,nTamanho,nDecimal,nPreSel,cGSC ,cValid ,cF3  	,cGrpSXG,cPyme,cVar01    ,cDef01        	,cDefSpa1      		,cDefEng1      		,cDef02       	,cDefSpa2     		,cDefEng2     		,cDef03  		,cDefSpa3		,cDefEng3 	,cDef04  	,cDefSpa4		,cDefEng4		,cDef05 	 		,cDefSpa5		,cDefEng5		,aHelpPor		,aHelpEng		,aHelpSpa		,cHelp)
	//PutSx1(cPerg,"01", "Matricula de  ?", "Matricula de?  ", "Matricula de      ", 					"mv_ch1", "C",	6,0,0, 	"G", "", "SRA"   , "", "", "mv_par01",""            , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")
	//PutSx1(cPerg,"02", "Matricula até ?", "Matricula até? ", "Matricula até     ", 					"mv_ch2", "C", 	6,0,0, 	"G", "", "SRA"   , "", "", "mv_par02",""            , ""            , ""            , "", ""         , ""         , ""         , "", "", "", "", "", "", "", "", "", {"","","",""}, {"","","",""}, {"","",""}, "")

Return
