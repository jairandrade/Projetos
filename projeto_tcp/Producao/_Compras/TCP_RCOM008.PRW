#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "REPORT.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM008
E-mail com pedido aprovado

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RCOM008(cFil,cNum)

Local oReport
Local lTRepInUse := .T.

PRIVATE lAuto  := .T.
Private cReqSc := ""
//cFil := '01'
//cNum := '000170'//'010935'//

DbSelectArea('SC7')
SC7->(DbSetOrder(1))
SC7->(DbGoTop())
SC7->(DbSeek(cFil+cNum))

nReg := SC7->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?ara versoes localizadas em TReport R4 e usado o MATR110, a chamada e       ?
//?ealizada atraves do MATR111 onde a funcao TRepInUse() e executada para     ?
//?elecionar o tipo de impressao R3 ou R4, este tratamento e para impedir que ?
//? pergunta seja apresentada 2 vezes.                                        ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTRepInUse := .T.

If lTRepInUse
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?nterface de impressao                                                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef(nReg, '1',cNum)
	//	oReport:PrintDialog()
Else
	RMAT110R3( cAlias, nReg, '1' )
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?rograma  ?ReportDef?utor  ?lexandre Inacio Lemes ?ata  ?6/09/2006³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Pedido de Compras / Autorizacao de Entrega                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?nExp01: nReg = Registro posicionado do SC7 apartir Browse  ³±?
±±?         ?nExp02: nOpcx= 1 - PC / 2 - AE                             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?oExpO1: Objeto do relatorio                                ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function ReportDef(nReg,nOpcx,cNum)

Local cTitle   := "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega" // "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
Local nTamCdProd:= TamSX3("C7_PRODUTO")[1]
Local cTime := Time()
Local cTitulo := "Orcamento"
Local cArq		:= ''

Local cQuery	:= ""
Local cCorpo	:= ""



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Variaveis utilizadas para parametros                         ?
//?mv_par01               Do Pedido                             ?
//?mv_par02               Ate o Pedido                          ?
//?mv_par03               A partir da data de emissao           ?
//?mv_par04               Ate a data de emissao                 ?
//?mv_par05               Somente os Novos                      ?
//?mv_par06               Campo Descricao do Produto    	     ?
//?mv_par07               Unidade de Medida:Primaria ou Secund. ?
//?mv_par08               Imprime ? Pedido Compra ou Aut. Entreg?
//?mv_par09               Numero de vias                        ?
//?mv_par10               Pedidos ? Liberados Bloqueados Ambos  ?
//?mv_par11               Impr. SC's Firmes, Previstas ou Ambas ?
//?mv_par12               Qual a Moeda ?                        ?
//?mv_par13               Endereco de Entrega                   ?
//?mv_par14               todas ou em aberto ou atendidos       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Pergunte("MTR110",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?riacao do componente de impressao                                      ?
//?                                                                       ?
//?Report():New                                                           ?
//?xpC1 : Nome do relatorio                                               ?
//?xpC2 : Titulo                                                          ?
//?xpC3 : Pergunte                                                        ?
//?xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ?
//?xpC5 : Descricao                                                       ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oReport

Private cDirPdf 	:= "\_PEDIDO_PDF\"
Private cNomeRel 	:= "PCAPRO_" + cFilAnt + SC7->C7_NUM + "_" + SubStr(DtoS(dDataBase),1,4) + SubStr(DtoS(dDataBase),5,2) + SubStr(DtoS(dDataBase),7,2) +;
SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + ".pdf"

Private nPagi    	:= 1

Private nLin		:= 0
Private nPaginaAux	:= 1
Private oPrint		:= NIL
Private nTotalm		:= 0
Private nTotalMerc	:= 0
Private cUsrPed		:= ""
Private cCC         := ""
Private cTo         := ""

//Verifica se a pasta existe
If !ExistDir(cDirPdf)
	MakeDir(cDirPdf)
EndIf

oReport := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )
oReport:SetPortrait()
oReport:SetPaperSize(DMPAPER_A4)
oReport:SetMargin(05,05,05,05)
oReport:StartPage()

oReport:cPathPDF := cDirPdf

Private oFont10		:= TFont():New("Arial",,14,,.F.,,,,.F.,.F.)
Private oFont10n	:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
Private oFont12n	:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
Private oFont13n	:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)
Private oFont16n	:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
Private oFont24n	:= TFont():New("Arial",,24,,.T.,,,,.F.,.F.)


ImpCabec()
ImpRodape()

ImpItens(nPagi)

oReport:EndPage()
oReport:Preview()


cAssunto := 'Aprovação Pedido'

//=============================================================================
// falta fazer o corpo do e-mail
//==============================================================================

cCorpo := corpoM(cNum)
If empty(alltrim(GetMv("TCP_MAILTS")))
	cCCAcomp := ""
	If !empty(alltrim(SuperGetMv("TCP_MAILAC",,"")))
		cCCAcomp := ";"+alltrim(GetMv("TCP_MAILAC"))
	EndIf
	
	// Se Pedido é de contrato, não envia e-mail para o Fornecedor...
	If !Empty(SC7->C7_CONTRA)
		cTo := UsrRetMail(cUsrPed)+cCCAcomp
	Else
		cTo		 := SA2->A2_EMAIL
		cCC		 := UsrRetMail(cUsrPed)+cCCAcomp
	EndIf
	
	If !Empty(Alltrim(cReqSc))
		DbSelectArea('SRA')
		SRA->(DbSetOrder(1))
		IF SRA->(DbSeek(xFilial('SRA')+cReqSc))
			cCC += ' ; '+SRA->RA_EMAIL
		EndIf
	EndIf
Else
	cTo		 := alltrim(GetMv("TCP_MAILTS"))
	cCC		 := alltrim(GetMv("TCP_MAILTS"))
EndIf

cArqLog := "\AFS\LOG\"+Alltrim(Funname())+"_"+DtoS(dDatabase)+"_"+StrTran(time(),":","")+"_"+retcodusr()+"_"+SC7->C7_FILIAL+SC7->C7_NUM+".txt"
MemoWrite(cArqLog,SC7->C7_NUM)
    
U_MCOM016(cTo, cCC, cAssunto, cCorpo, cDirPdf+cNomeRel, .F. )


Ferase("\_pedido_pdf\"+cNomeRel)

Return(oReport)

Static Function ImpCabec()
Local nDesc
DbSelectArea('SA2')
SA2->(DbSetOrder(1))
SA2->(DbGoTop())
SA2->(DbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA))
cUsrPed := SC7->C7_USER
oReport:Box( 010, 030, 200, 2350, "-8")
oReport:SayBitmap( 030, 040,  "\sigaadv\lgrl01.bmp", 340, 120)
nLin := 045
oReport:Say(nLin,410,"Empresa: "+SM0->M0_NOMECOM,oFont10)
nLin += 45
oReport:Say(nLin,410,"Endere?: "+SM0->M0_ENDENT,oFont10)
nLin += 45
oReport:Say(nLin,410,"CEP: "+Transform(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")),oFont10)
oReport:Say(nLin,1080,"Cidade: "+Alltrim(SM0->M0_CIDENT) + " - Estado:" + SM0->M0_ESTENT ,oFont10)
nLin += 45
oReport:Say(nLin,0410,"Tel: 55-41-21525800" ,oFont10)
oReport:Say(nLin,1080,"Fax: 55-41-21525800" ,oFont10)

oReport:Say(nLin,1800,"CNPJ: "+Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")),oFont10)
/*
If AllTrim(SM0->M0_CODIGO) == '03'//se for TCPLOG
If AllTrim(SM0->M0_CODFIL) == '01'
//imprime CNPJ da LOG S/A
oReport:Say(nLin,1800,"CNPJ: 13.438.815/0001-07" ,oFont10)
Else
If AllTrim(SM0->M0_CODFIL) == '02'
//imprime CNPJ da LOG Ponta Grossa
oReport:Say(nLin,1800,"CNPJ: 13.438.815/0002-80" ,oFont10)
else
//imprime CNPJ da LOG S? Jos?dos Pinhais
oReport:Say(nLin,1800,"CNPJ: 13.438.815/0003-60" ,oFont10)
EndIf
EndIf

Else
oReport:Say(nLin,1800,"CNPJ: 12.919.786/0001-24" ,oFont10)
EndIf
*/
nLin += 80


oReport:Box( 220, 030, 480, 2350, "-8")
oReport:Say(nLin,050,"PEDIDO DE COMPRAS - "+IIf(SC7->C7_MOEDA==1,'REAL',IIF(SC7->C7_MOEDA==2,'DOLAR','EURO')),oFont10)
oReport:Say(nLin,1080,SC7->C7_NUM,oFont10)
nLin += 55
oReport:Say(nLin,050,"Raz? Social: "+SA2->A2_NOME,oFont10)
oReport:Say(nLin,1800,"Codigo: "+SA2->A2_COD+" Loja: "+SA2->A2_LOJA,oFont10)
nLin += 45
oReport:Say(nLin,050,"Endere?: "+SA2->A2_END+"       Bairro: "+Alltrim(SA2->A2_BAIRRO) ,oFont10)
nLin += 45
oReport:Say(nLin,050,"Municipio: "+Alltrim(SA2->A2_MUN)+"       Estado:"+SA2->A2_EST+"                               CEP: "+Transform(SA2->A2_CEP,PesqPict("SA2","A2_CEP"))+"                  CNPJ: "+Alltrim(SA2->A2_CGC),oFont10)
nLin += 45
oReport:Say(nLin,050,"Tel: "+Alltrim(SA2->A2_TEL) ,oFont10)
oReport:Say(nLin,680,"Fax: "+Alltrim(SA2->A2_FAX) ,oFont10)
oReport:Say(nLin,1800,"IE: "+Alltrim(SA2->A2_INSCR) ,oFont10)
nLin += 45

Return

Static Function ImpItens(nPagina)
Local nDesc

If nPagina == 1
	nLin += 45
	
	oReport:Box( 500, 0030, 2000, 2350, "-8")
	oReport:Box( 500, 0030, 2000, 0115, "-8")
	//		oReport:Box( 500, 0115, 2000, 0380, "-8")
	oReport:Box( 500, 0380, 2000, 1110, "-8")
	//		oReport:Box( 500, 1100, 2000, 1170, "-8")
	oReport:Box( 500, 1180, 2000, 1400, "-8")
	oReport:Box( 500, 1400, 2000, 1700, "-8")
	oReport:Box( 500, 1700, 2000, 1850, "-8")
	oReport:Box( 500, 2110, 2000, 2350, "-8")
	oReport:Box( 500, 0030, 0550, 2350, "-8")
	
Else
	oReport:EndPage()
	oReport:StartPage()
	nLin := 45
	oReport:Box( 010, 0030, 2850, 2350, "-8")
	oReport:Box( 010, 0030, 2850, 0115, "-8")
	//		oReport:Box( 010, 0115, 2850, 0380, "-8")
	oReport:Box( 010, 0380, 2850, 1110, "-8")
	//		oReport:Box( 010, 1100, 2850, 1170, "-8")
	oReport:Box( 010, 1180, 2850, 1400, "-8")
	oReport:Box( 010, 1400, 2850, 1700, "-8")
	oReport:Box( 010, 1700, 2850, 1850, "-8")
	oReport:Box( 010, 2110, 2850, 2350, "-8")
	oReport:Box( 010, 0030, 0060, 2350, "-8")
	
EndIf
oReport:Say(nLin,0033,"Item",oFont10)
oReport:Say(nLin,0118,"Produto",oFont10)
oReport:Say(nLin,0383,"Descrição",oFont10)
oReport:Say(nLin,1113,"UM" ,oFont10)
oReport:Say(nLin,1183,"Quantidade" ,oFont10)
oReport:Say(nLin,1403,"Valor Unit." ,oFont10)
oReport:Say(nLin,1703,"Al. IPI" ,oFont10)
oReport:Say(nLin,1853,"Valor Total" ,oFont10)
oReport:Say(nLin,2123,"Dt. Entrega" ,oFont10)
//	oReport:Say(nLin,2300,"Nro. SC" ,oFont10)
nLin += 50
nTotalM := 0
cNumSC7 := SC7->C7_FILIAL+SC7->C7_NUM
cReqSc	:= Posicione('SC1',1,xFilial('SC1')+SC7->C7_NUMSC,'C1_REQUISI')

While SC7->C7_FILIAL+SC7->C7_NUM  == cNumSC7
	//nTotalM += SC7->C7_TOTAL
	
	If nLin >= 1750 .AND. nPagina == 1 //1650
		nPagina++
		oReport:EndPage()
		oReport:StartPage()
		
		nLin := 40
		oReport:Box( 010, 0030, 2850, 2350, "-8")
		oReport:Box( 010, 0030, 2850, 0115, "-8")
		//			oReport:Box( 010, 0115, 2850, 0380, "-8")
		oReport:Box( 010, 0380, 2850, 1110, "-8")
		oReport:Box( 010, 1180, 2850, 1400, "-8")
		oReport:Box( 010, 1400, 2850, 1710, "-8")
		oReport:Box( 010, 1710, 2850, 1850, "-8")
		oReport:Box( 010, 2110, 2850, 2350, "-8")
		oReport:Box( 010, 0030, 0060, 2350, "-8")
		oReport:Box( 2850, 0030, 2950, 2350, "-8")
		
		oReport:Say(nLin,0033,"Item",oFont10)
		oReport:Say(nLin,0118,"Produto",oFont10)
		oReport:Say(nLin,0873,"Descrição",oFont10)
		oReport:Say(nLin,1113,"UM" ,oFont10)
		oReport:Say(nLin,1183,"Quantidade" ,oFont10)
		oReport:Say(nLin,1403,"Valor Unit." ,oFont10)
		oReport:Say(nLin,1703,"Al. IPI" ,oFont10)
		oReport:Say(nLin,1853,"Valor Total" ,oFont10)
		oReport:Say(nLin,2123,"Dt. Entrega" ,oFont10)
		oReport:Say(2940,2150,"Pagina: "+Alltrim(Str(nPagina))+"/"+Alltrim(Str(nPaginaAux)),oFont10)
		nLin += 50
		
	ElseIf nLin >= 2050 .AND. nPagina > 1 //1650
		nPagina++
		oReport:EndPage()
		oReport:StartPage()
		
		nLin := 40
		oReport:Box( 010, 0030, 2850, 2350, "-8")
		oReport:Box( 010, 0030, 2850, 0115, "-8")
		//			oReport:Box( 010, 0115, 2850, 0380, "-8")
		oReport:Box( 010, 0380, 2850, 1110, "-8")
		oReport:Box( 010, 1180, 2850, 1400, "-8")
		oReport:Box( 010, 1400, 2850, 1700, "-8")
		oReport:Box( 010, 1700, 2850, 1850, "-8")
		oReport:Box( 010, 2110, 2850, 2350, "-8")
		oReport:Box( 010, 0030, 0060, 2350, "-8")
		oReport:Box( 2850, 0030, 2950, 2350, "-8")
		oReport:Say(nLin,0033,"Item",oFont10)
		oReport:Say(nLin,0118,"Produto",oFont10)
		oReport:Say(nLin,0383,"Descrição",oFont10)
		oReport:Say(nLin,1113,"UM" ,oFont10)
		oReport:Say(nLin,1183,"Quantidade" ,oFont10)
		oReport:Say(nLin,1403,"Valor Unit." ,oFont10)
		oReport:Say(nLin,1703,"Al. IPI" ,oFont10)
		oReport:Say(nLin,1853,"Valor Total" ,oFont10)
		oReport:Say(nLin,2123,"Dt. Entrega" ,oFont10)
		//	oReport:Say(nLin,2300,"Nro. SC" ,oFont10)
		oReport:Say(2940,2150,"Pagina: "+Alltrim(Str(nPagina))+"/"+Alltrim(Str(nPaginaAux)),oFont10)
		nLin += 50
		
	EndIF
	
	oReport:Say(nLin,0033,SC7->C7_ITEM,oFont10)
	oReport:Say(nLin,0118,SC7->C7_PRODUTO,oFont10)
	cDescProd := Posicione('SB5',1,xFilial('SB5')+SC7->C7_PRODUTO,"B5_DCOMPR")
	If Empty(Alltrim(cDescProd))
		cDescProd := Posicione('SB5',1,xFilial('SB5')+SC7->C7_PRODUTO,"B5_CEME")
	EndIf
	If Empty(Alltrim(cDescProd))
		cDescProd := Posicione('SB1',1,xFilial('SB1')+SC7->C7_PRODUTO,"B1_DESC")
	EndIf
	//	oReport:Say(nLin,0363,cDescProd,oFont10)
	oReport:Say(nLin,1113,SC7->C7_UM ,oFont10)
	oReport:SayAlign(nLin-35,1170,Transform(SC7->C7_QUANT,"@E 99,999.99") ,oFont10,227,,,1,1)
	oReport:SayAlign(nLin-35,1400,Transform(SC7->C7_PRECO,"@E 99,999,999.99") ,oFont10,297,,,1,1)
	oReport:SayAlign(nLin-35,1700,Transform(SC7->C7_IPI,"@E 99.99") ,oFont10,147,,,1,1)
	oReport:SayAlign(nLin-35,1850,Transform(SC7->C7_TOTAL,"@E 99,999,999.99") ,oFont10,257,,,1,1)
	
	oReport:Say(nLin,2120,DtoC(SC7->C7_DATPRF) ,oFont10)
	//		oReport:Say(nLin,2300,SC7->C7_NUMSC ,oFont10)
	
	For nDesc := 1 to Len(Alltrim(cDescProd))/30+IIF(MOD(Len(Alltrim(cDescProd)),30)==0,0,1)
		oReport:Say(nLin,0383,Substr(cDescProd,(1+(nDesc-1)*30),30),oFont10)
		nLin+=45
	Next
	
	SC7->(DbSkip())
EndDo
SC7->(DbSkip(-1)) //Voltar para um registro do pedido corrente

Return

Static Function ImpRodape()
Local nDesc
oReport:Box( 2020, 0030, 2950, 2350, "-8")

oReport:Box( 2020, 0030, 2100, 2350, "-8")
oReport:Say(2070,0033,"Descontos: ",oFont10)
oReport:Say(2070,0233,Transform(SC7->C7_DESC1,"@E 99.99")+"%",oFont10)
oReport:Say(2070,0393,Transform(SC7->C7_DESC2,"@E 99.99")+"%",oFont10)
oReport:Say(2070,0533,Transform(SC7->C7_DESC3,"@E 99.99")+"%",oFont10)
oReport:Say(2070,0853,Transform(SC7->C7_VLDESC,"@E 999,999.99"),oFont10)

oReport:Box( 2100, 0030, 2220, 2350, "-8")
oReport:Say(2140,0033,"Local de Entrega: "+Alltrim(SM0->M0_ENDENT)+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - CEP: "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),oFont10)
oReport:Say(2190,0033,"Local de Cobran?: " +Alltrim(SM0->M0_ENDCOB)+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - CEP: "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),oFont10)


oReport:Box( 2220, 0030, 2340, 2350, "-8")
oReport:Box( 2220, 1050, 2340, 1350, "-8")
oReport:Say(2270,0033,"Condição de Pagamento: "+SC7->C7_COND,oFont10)
oReport:Say(2320,0033,Posicione('SE4',1,xFilial('SE4')+SC7->C7_COND,"E4_DESCRI"),oFont10)

oReport:Say(2270,1053,"Data de Emiss?",oFont10)
oReport:Say(2320,1093,DtoC(SC7->C7_EMISSAO),oFont10)

nTotIpi	  := 0
nTotIcms  := 0
nTotDesp  := 0
nTotFrete := 0
nTotSeguro:= 0
nTotalNF  := 0
nTotalM	  := 0
nDesconto := 0
nLinAux 	:= nLin
nPaginaAux  := 1

cNumSC7 := SC7->C7_FILIAL+SC7->C7_NUM
While SC7->C7_FILIAL+SC7->C7_NUM  == cNumSC7
	
	If nLinAux >= 1750 .AND. nPaginaAux == 1 //1650
		nPaginaAux++
		nLinAux := 90
	ElseIf nLinAux >= 2300 .AND. nPaginaAux > 1 //1650
		nPaginaAux++
		nLinAux := 40
		nLinAux += 50
		
	EndIF
	
	cDescAux := Posicione('SB5',1,xFilial('SB5')+SC7->C7_PRODUTO,"B5_DCOMPR")
	If Empty(Alltrim(cDescAux))
		cDescAux := Posicione('SB5',1,xFilial('SB5')+SC7->C7_PRODUTO,"B5_CEME")
	EndIf
	If Empty(Alltrim(cDescAux))
		cDescAux := Posicione('SB1',1,xFilial('SB1')+SC7->C7_PRODUTO,"B1_DESC")
	EndIf
	
	For nDesc := 1 to Len(Alltrim(cDescAux))/30+IIF(MOD(Len(Alltrim(cDescAux)),30)==0,0,1)
		nLinAux+=45
	Next
	
	nTotIpi	  += SC7->C7_VALIPI
	nTotIcms  += SC7->C7_VALICM
	nTotDesp  += SC7->C7_DESPESA
	nTotFrete += IIF(SC7->C7_TPFRETE=='C',SC7->C7_VALFRE,0)
	nTotSeguro+= SC7->C7_SEGURO
	nTotalM	  += SC7->C7_TOTAL
	nDesconto += SC7->C7_VLDESC
	SC7->(DbSkip())
EndDo
DbSelectArea('SC7')
SC7->(dbSetOrder(1))
SC7->(DbGoTop())
SC7->(DbSeek(cNumSC7))
/*
MaFisEnd()
R110FIniPC(SC7->C7_NUM,,,"SC7->C7_QUANT > SC7->C7_QUJE")

nTotIpi	  := MaFisRet(,'NF_VALIPI')
nTotIcms  := MaFisRet(,'NF_VALICM')
nTotDesp  := MaFisRet(,'NF_DESPESA')
nTotFrete := MaFisRet(,'NF_FRETE')
nTotSeguro:= MaFisRet(,'NF_SEGURO')
nTotalNF  := MaFisRet(,'NF_TOTAL')
nTotalM	  := MaFisRet(,'NF_VALMERC')
*/
nTotalNF := nTotalM+nTotIpi
oReport:Say(2270,1353,"Total da Mercadoria: ",oFont10)
oReport:Say(2270,1653,Transform(nTotalM,"@E 999,999,999.99"),oFont10)
oReport:Say(2320,1353,"Total com Impostos: ",oFont10)
oReport:Say(2320,1653,Transform(nTotalNF,"@E 999,999,999.99"),oFont10)

oReport:Box( 2340, 0030, 2550, 2350, "-8")
oReport:Box( 2340, 0030, 2550, 0803, "-8")
oReport:Box( 2340, 0803, 2550, 1606, "-8")
oReport:Box( 2340, 1606, 2550, 2350, "-8")
oReport:Say(2390,0033,"IPI: ",oFont10)
oReport:Say(2390,0183,Transform(nTotIpi,"@E 999,999,999.99"),oFont10)
oReport:Say(2440,0033,"Frete: ",oFont10)
oReport:Say(2440,0183,Transform(nTotFrete,"@E 999,999,999.99"),oFont10)
oReport:Say(2390,0806,"ICMS: ",oFont10)
oReport:Say(2390,0956,Transform(nTotIcms,"@E 999,999,999.99"),oFont10)
oReport:Say(2440,0806,"Despesas: ",oFont10)
oReport:Say(2440,0956,Transform(nTotDesp,"@E 999,999,999.99"),oFont10)
oReport:Say(2490,0806,"Seguro: ",oFont10)
oReport:Say(2490,0956,Transform(nTotSeguro,"@E 999,999,999.99"),oFont10)
oReport:Say(2440,1609,"Total Geral: ",oFont10)
oReport:Say(2440,1759,Transform((nTotalNF+nTotDesp+nTotFrete)-nDesconto,"@E 999,999,999.99"),oFont10)

oReport:Box( 2550, 0030, 2620, 1190, "-8")
oReport:Box( 2550, 1190, 2620, 2350, "-8")
oReport:Say(2600,450,"PEDIDO LIBERADO",oFont10)
oReport:Say(2600,1200,"Obs do Frete: "+IIF(SC7->C7_TPFRETE=='C','CIF','FOB'),oFont10)

oReport:Box( 2620, 0030, 2850, 2350, "-8")
oReport:Say(2670,0033,"Comprador Respons?el: "+SC7->C7_USER+" - "+UsrFullName(Alltrim(SC7->C7_USER)),oFont10)
If SA2->A2_IMPOBS == 'S'
	oReport:Say(2710,0033,"Observação: "+SubStr(Alltrim(SC7->C7_OBS),1,100),oFont10)
	oReport:Say(2750,0033,SubStr(Alltrim(SC7->C7_OBS),101,110),oFont10)
	oReport:Say(2790,0033,SubStr(Alltrim(SC7->C7_OBS),211,110),oFont10)
	oReport:Say(2830,0033,SubStr(Alltrim(SC7->C7_OBS),321,120),oFont10)
EndIf

oReport:Box( 2850, 0030, 2950, 2350, "-8")
oReport:Say(2900,0033,"Nota: "+GetMv("TCP_MSGPC"),oFont10)
oReport:Say(2940,2150,"Pagina: 1/"+Alltrim(Str(nPaginaAux)),oFont10)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?uncao    ?110FIniPC?Autor ?Edson Maricate        ?Data ?0/05/2000³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escricao ?Inicializa as funcoes Fiscais com o Pedido de Compras      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?R110FIniPC(ExpC1,ExpC2)                                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 := Numero do Pedido                                  ³±?
±±?         ?ExpC2 := Item do Pedido                                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATR110,MATR120,Fluxo de Caixa                             ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local cValid		:= ""
Local nPosRef		:= 0
Local nItem		:= 0
Local cItemDe		:= IIf(cItem==Nil,'',cItem)
Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
Local cRefCols	:= ''
Local nX
DEFAULT cSequen	:= ""
DEFAULT cFiltro	:= ""

dbSelectArea("SC7")
dbSetOrder(1)
If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
	MaFisEnd()
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
	While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
		SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)
		
		// Nao processar os Impostos se o item possuir residuo eliminado
		If &cFiltro
			dbSelectArea('SC7')
			dbSkip()
			Loop
		EndIf
		
		// Inicia a Carga do item nas funcoes MATXFIS
		nItem++
		MaFisIniLoad(nItem)
		aAux := FwSX3Util():GetAllFields("SC7")
		For nX := 1 to len(aAux)
			cValid	:= StrTran(UPPER(GetSX3Cache(aAux[nX],"X3_VALID"))," ","")
			cValid	:= StrTran(cValid,"'",'"')
			If "MAFISREF" $ cValid
				nPosRef  := AT('MAFISREF("',cValid) + 10
				cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
				// Carrega os valores direto do SC7.
				MaFisLoad(cRefCols,&("SC7->"+ aAuxp[nX]),nItem)
			EndIf
		Next nX
		MaFisEndLoad(nItem,2)
		dbSelectArea('SC7')
		dbSkip()
	End
EndIf

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.


Static Function corpoM(cNum)
Local cCorpo := ''

cCorpo += '<style type="text/css">  '
cCorpo += '.tg  {border-collapse:collapse;border-spacing:0;} '
cCorpo += '.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg .tg-dadk{font-weight:bold;font-size:12px;font-family:Verdana, Geneva, sans-serif !important;;vertical-align:top}'
cCorpo += '.tg .tg-trty{font-weight:bold;background-color:#91b5df;color:#333333;vertical-align:top}'
cCorpo += '.tg .tg-qumh{background-color:#91b5df;color:#333333;vertical-align:top} '
cCorpo += '.tg .tg-9hbo{font-weight:bold;vertical-align:top} '
cCorpo += '.tg .tg-yw4l{vertical-align:top} '
cCorpo += '.tg .tg-8rx2{font-weight:bold;background-color:#91b5df;vertical-align:top} '
cCorpo += '.tg .tg-ojph{background-color:#91b5df;vertical-align:top} '
cCorpo += '.tg .tg-3we0{background-color:#ffffff;vertical-align:top}  '
cCorpo += '</style>'

cCorpo += '<style type="text/css"> '
cCorpo += '.tg2  {border-collapse:collapse;border-spacing:0;} '
cCorpo += '.tg2 td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg2 th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg2 .tg2-dadk{font-weight:bold;font-size:10px;font-family:Verdana, Geneva, sans-serif !important;;vertical-align:top} '
cCorpo += '.tg2 .tg2-763c{font-weight:bold;font-size:09px;font-family:Verdana, Geneva, sans-serif !important;;background-color:#91b5df;color:#333333;vertical-align:top}    '
cCorpo += '.tg2 .tg2-763R{font-weight:bold;font-size:09px;font-family:Verdana, Geneva, sans-serif !important;;background-color:#91b5df;color:#ff0000;vertical-align:top}    '
cCorpo += '</style> '

cCorpo += '<style type="text/css"> '
cCorpo += '.tg3  {border-collapse:collapse;border-spacing:0;} '
cCorpo += '.tg3 td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg3 th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'
cCorpo += '.tg3 .tg3-dadk{font-weight:bold;font-size:12px;font-family:Verdana, Geneva, sans-serif !important;;vertical-align:top} '
cCorpo += '.tg3 .tg3-763c{font-weight:bold;font-size:10px;font-family:Verdana, Geneva, sans-serif !important;;background-color:#91b5df;color:#333333;vertical-align:top}    '
cCorpo += '.tg3 .tg3-763r{font-weight:bold;font-size:10px;font-family:Verdana, Geneva, sans-serif !important;;background-color:#91b5df;color:#ff0000;vertical-align:top}    '
cCorpo += '</style> '


cCorpo += '<html> '
cCorpo += '	<body> '
cCorpo += '		<div style="text-align: left;"> '
cCorpo += '			<p> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Srs.(as),</span></span> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Confirmamos o pedido n&deg;'+cNum+' foi aprovado (obrigat&oacute;rio constar na nota fiscal o n&deg; do pedido).</span></span></p> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><b>Respeitando a orienta&ccedil;&atilde;o da RFB solicitamos que o transportador entregue no momento da entrada na tcp,<BR> um check list de tudo que possui em seu caminh&atilde;o aos vigilantes para inspe&ccedil;&atilde;o e posterior entrada do ve&iacute;culo.</b></span></span></p> '
cCorpo += '			<BR> '


cCorpo += '<table class="tg3" style="undefined;table-layout: fixed; width: 750px"> '
cCorpo += '<colgroup> '
cCorpo += '<col style="width: 750px"> '
cCorpo += '</colgroup> '
cCorpo += '  <tr> '
cCorpo += '    <th class="tg3-dadk">IMPORTANTE</th> '
cCorpo += '  </tr> '
cCorpo += '  <tr> '
cCorpo += '    <td class="tg3-764c"><span style="color:red">Materiais e/ou servi&ccedil;os entregues fora do prazo ser&atilde;o descontados 5% no ato e 1% a cada sete dias de atraso, valor considerado sobre o total do pedido de compra, al&eacute;m do desconto, atrasos impactar&atilde;o na avalia&ccedil;&atilde;o do fornecedor, correndo o risco do mesmo ser exclu&iacute;do de futuras cota&ccedil;&otilde;es.</span> '
cCorpo += '			<BR> '
cCorpo += '    <span style="color:red">ATENÇÃO: O fornecimento de produtos e a prestação de servi&ccedil;os dever&atilde;o, obrigatoriamente, assegurar prazo de garantia minímo de 01 (um) ano, contado da data de entrega/instalação do produto ou finalização do servi&ccedil;o. Servi&ccedil;os que envolvam reparos estruturais ou pinturas, obrigatoriamente, dever&atilde;o apresentar prazo de garantia min&iacute;mo de 02 (dois) anos.</span> '   
cCorpo += '			<BR> '
cCorpo += '    <span style="color:red">Prazo limite de Faturamento 	ATENÇÃO: As NFs de serviços/produtos devem ser emitidas até o 25&ordm; dia de cada m&ecirc;s, o que for emitida entre os dias 26 a 30 ou 31 dever&aacute; ser enviado NF simples reme&ccedil;a e faturado no primeiro dia &uacute;til do m&ecirc;s posterior.</span> '   
//cCorpo += '  </tr> '
//cCorpo += '  <tr> '
cCorpo += '			<BR> '
cCorpo += '    Nosso sistema envia automaticamente e-mails solicitando cota&ccedil;&otilde;es e os pedidos de compras s&atilde;o enviados assim que aprovados pelo quadro de al&ccedil;adas interno do TCP. Com isso, &eacute; importante que qualquer altera&ccedil;&atilde;o dever&aacute; ser realizada at&eacute; o fechamento do processamento do pedido de compras. Desta forma n&atilde;o ser&atilde;o aceitas altera&ccedil;&otilde;es de valores, prazo e/ou qualquer outra informa&ccedil;&atilde;o do g&ecirc;nero. Por isso, &eacute; imprescind&iacute;vel que no momento do preenchimento da cota&ccedil;&atilde;o, sejam informados os valores, prazos, etc., corretos para que n&atilde;o ocorrerem problemas no fornecimento ou no faturamento do pedido de compras. '
//cCorpo += '  </tr> '
//cCorpo += '  <tr> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '    Refor&ccedil;ando: Este tipo de problema, poder&aacute; levar a um poss&iacute;vel bloqueio do fornecedor em nossa base cadastral, boqueando a participa&ccedil;&atilde;o de futuras compras (cota&ccedil;&otilde;es). Os fornecedores dever&atilde;o manter uma conta de e-mail v&aacute;lida e que seja acessada frequentemente para receber as solicita&ccedil;&otilde;es de cota&ccedil;&otilde;es e futuros pedidos de compras aprovados, sendo que n&atilde;o nos responsabilizamos por eventuais problemas de comunica&ccedil;&atilde;o devidos &agrave; altera&ccedil;&atilde;o de contas de e-mails e/ou fornecimento de informa&ccedil;&otilde;es incorretas. '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '    <span style="color:red">Fornecedores e transportadores, favor notar que para acessar as dependências do terminal para entregas de materiais em nosso Almoxarifado e outros setores que necessitem, devem seguir as seguintes normas:<br>- Envio antecipado dos seguintes documentos para o primeiro acesso: Documento do veículo e a apólice de seguro, documento do condutor;<BR>- Motorista e Veículo devem estar cadastrados em nosso Portal (portal.tcp.com.br);<BR>- Veículo identificado através de plotagem ou adesivo magnético removível com logo e/ou nome da empresa e giroflex;<BR>                - Condutor utilizar os seguintes EPIs: Sapato de segurança, Capacete e Colete refletivo.<BR></span> '
cCorpo += '  </tr> '
cCorpo += '</table> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '


cCorpo += '				<table class="tg" style="undefined;table-layout: fixed; width: 750px">
cCorpo += '				<colgroup>   '
cCorpo += '				<col style="width: 260px">'
cCorpo += '				<col style="width: 490px"> '
cCorpo += '				</colgroup> '
cCorpo += '				  <tr> '
cCorpo += '				    <th class="tg-dadk">TERMOS</th> '
cCorpo += '				    <th class="tg-dadk">CONDIÇÕES</th> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-8rx2">Condição de Pagamento:</td> '
cCorpo += '				    <td class="tg-qumh">'+Posicione('SE4',1,xFilial('SE4')+Posicione('SC7',1,xFilial('SC7')+cNum,"C7_COND"),"E4_DESCRI")+'</td> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-9hbo"><br>Prazo de entrega:</td> '
cCorpo += '				    <td class="tg-yw4l">Prazo final de entrega dia '+DtoC(SC7->C7_DATPRF)+', entrega podendo ser ANTECIPADA caso os materiais estejam disponiveis antes deste prazo.</td> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-8rx2">Transporte:</td> '
cCorpo += '				    <td class="tg-ojph">'+IIF(SC7->C7_TPFRETE=='F','FOB','CIF - Por conta do Fornecedor')+'</td> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-9hbo">Horários para entregas:</td> '
cCorpo += '				    <td class="tg-3we0">Segunda,a Sexta das 08:00 as 16:00 horas e aos sabados das 08:00 as 11:00 horas.</td> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-8rx2">Valores do pedido:</td> '
cCorpo += '				    <td class="tg-ojph">Impostos, taxas ou descontos (Inclusos).</td> '
cCorpo += '				  </tr> '
cCorpo += '				  <tr> '
cCorpo += '				    <td class="tg-9hbo">Observações:</td> '
cCorpo += '				    <td class="tg-yw4l">Conforme orcamento via workflow cotação.<br><br>Enviar os arquivos XML e PDF referente as Notas Fiscais para os seguintes e- mails:<br><br>almoxarifado@tcp.com.br<br>compras@tcp.com.br<br></td> '
cCorpo += '				  </tr> '  '
cCorpo += '				</table> ' '
cCorpo += '			<BR><BR> '

cCorpo += '<table class="tg2" style="undefined;table-layout: fixed; width: 750px"> '
cCorpo += '<colgroup> '
cCorpo += '<col style="width: 750px"> '
cCorpo += '</colgroup> '
cCorpo += '  <tr> '
cCorpo += '    <th class="tg2-dadk">CONDIÇÕES GERAIS DE COMPRAS:</th> '
cCorpo += '  </tr> '
cCorpo += '  <tr> '
cCorpo += '    <td class="tg2-763c">- Os produtos devem ser entregues absolutamente dentro do prazo combinado. A não observância da presente cláusula garante-nos o direito de cancelar esse “Processo de Compras”, em todo ou em parte, sem qualquer prejuízo de nossa parte.<br>- Todo material fornecido deveem estar rigorosamente de acordo com o nosso pedido no que se refere a especificação, desenhos etc. Em caso de rejeição serem colocado a disposição, por conta e risco do fornecedor, até sua retirada. Qualquer despesa de transporte, relativo a materiais assim rejeitados, corre por conta do fornecedor.<br>- Reservamo-nos o direito de recusar e devolver, ás custas do fornecedor, qualquer parcela de material recebido em quantidade superior á ela cujo fornecimento foi autorizado pelo presente pedido de compra.<br>- A presente encomenda não poderão ser faturada por preços mais elevados do que aqueles aqui estabelecidos.<br>- Não assumimos qualquer responsabilidade por mercadorias, cujas entregas não tenham sido autorizadas neste processo de, compras devidamente aprovado ou que, de qualquer modo não esteja de acordo com os termos e condições supra-estabelecidas.<br>- Garanta a possibilidade de novos pedidos respeitando o estabelecido nos itens acima. Pedimos em benefício recíproco nos avisar por telefone, e-mail ou carta sobre qualquer dilatação que venha a sofrer o prazo de entrega originalmente fixado ou sobre sua impossibilidade de cumprir qualquer das cláusulas acima.<br>- Confirmar recebimento da autorização e aceite.</td> '
cCorpo += '  </tr> '
cCorpo += '</table> '

/*
cCorpo += '			<table style="border:1px solid black;" cellpadding="0" cellspacing="0"> '
cCorpo += '				<tbody> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>TERMOS</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '					<td style="width:466px;height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>CONDI&Ccedil;&Otilde;ES</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:2px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Condi&ccedil;&atilde;o de pagamento:</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:2px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">'+'AAAAAAAAAAAAAAAAA'+'.</span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Prazo de entrega:</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12x;"><span style="font-family:verdana,geneva,sans-serif;">Prazo final de entrega dia'+'AAAAAAAAAAAAAAAAAAAAA'+' entrega podendo ser ANTECIPADA caso os materiais estejam dispon&iacute;veis antes deste prazo.</span></span></p> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">(Data v&aacute;lida para avalia&ccedil;&atilde;o &eacute; a que est&aacute; no corpo deste e-mail)</span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Transporte:</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">CIF &ndash; Por conta fornecedor.</span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Hor&aacute;rios para entregas:</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Segunda a Sexta at&eacute; &agrave;s 16:00 horas e aos s&aacute;bados at&eacute; &agrave;s 11:00 horas.</span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Valores do pedido:</strong></span></span></p>'
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:4px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Impostos, taxas ou descontos (Inclusos).</span></span></p>'
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>Observa&ccedil;&otilde;es:</strong></span></span></p>'
cCorpo += '						</td> '
cCorpo += '						<td style="width:466px;height:15px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Conforme or&ccedil;amento via workflow cota&ccedil;&atilde;o.</span></span></p>'
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Enviar os arquivos XML e PDF referente as Notas Fiscais para os seguintes e-mails:</span></span>'
cCorpo += '							<br> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><a href="mailto:almoxarifado@tcp.com.br">almoxarifado@tcp.com.br</a></span></span>'
cCorpo += '							<br> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><a href="mailto:compras@tcp.com.br">compras@tcp.com.br</a></span></span>'
cCorpo += '							<br> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><a href="mailto:contasapagar@tcp.com.br">contasapagar@tcp.com.br</a></span></span></p>'
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '				</tbody> '
cCorpo += '			</table> '
cCorpo += '			<p> '
cCorpo += '				&nbsp;</p> '
cCorpo += '			<table class="tg" style="undefined;table-layout: fixed; width: 623px > '
cCorpo += '				<tbody> '
cCorpo += '					<tr> '
cCorpo += '						<td style="width:822px;"> '
cCorpo += '							<p> '
cCorpo += '								<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><strong>CONDI&Ccedil;&Otilde;ES GERAIS DE COMPRAS:</strong></span></span></p> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '					<tr> '
cCorpo += '						<td style="width:822px;"> '
cCorpo += '							<ul> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;">Os produtos dever&atilde;o ser entregues absolutamente dentro do prazo combinado. A n&atilde;o observ&acirc;ncia da presente cl&aacute;usula garante-nos o direito de cancelar esse &ldquo;Processo de Compras&rdquo;, em todo ou em parte, sem qualquer preju&iacute;zo de nossa parte.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;color:red;">- ATENCAO: O fornecimento de produtos e a prestacao de servicos deverao, obrigatoriamente, assegurar prazo de garantia minimo de 01 (um) ano, contado da data de entrega/instalacao do produto ou finalizacao do servico. Servicos que envolvam reparos estruturais ou pinturas, obrigatoriamente, deverao apresentar prazo de garantia minimo de 02 (dois) anos.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;">Todo material fornecido dever&aacute; estar rigorosamente de acordo com o nosso pedido no que se refere a especifica&ccedil;&atilde;o, desenhos etc. Em caso de rejei&ccedil;&atilde;o ser&aacute; colocado &agrave; disposi&ccedil;&atilde;o, por conta e risco do fornecedor, at&eacute; sua retirada. Qualquer despesa de transporte, relativo a materiais assim rejeitados, correr&aacute; por conta do fornecedor.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;" ><span style="font-family:verdana,geneva,sans-serif;">Reservamo-nos o direito de recusar e devolver, &agrave;s custas do fornecedor, qualquer parcela de material recebido em quantidade superior &agrave;quela cujo fornecimento foi autorizado pelo presente pedido de compra.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;">A presente encomenda n&atilde;o poder&aacute; ser faturada por pre&ccedil;os mais elevados do que aqueles aqui estabelecidos.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;">N&atilde;o assumimos qualquer responsabilidade por mercadorias, cujas entregas n&atilde;o tenham sido autorizadas neste processo de compras devidamente aprovado ou que, de qualquer modo n&atilde;o esteja de acordo com os termos e condi&ccedil;&otilde;es supra-estabelecidas.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8px;"><span style="font-family:verdana,geneva,sans-serif;">Garanta a possibilidade de novos pedidos respeitando o estabelecido nos itens acima. Pedimos em benef&iacute;cio rec&iacute;proco nos avisar por telefone, e-mail ou carta sobre qualquer dilata&ccedil;&atilde;o que venha a sofrer o prazo de entrega originalmente fixado ou sobre sua impossibilidade de cumprir qualquer das cl&aacute;usulas acima.</span></span></li> '
cCorpo += '								<li style="margin-left: 36pt;"> '
cCorpo += '									<span style="font-size:8p\x;"><span style="font-family:verdana,geneva,sans-serif;">Confirmar recebimento da autoriza&ccedil;&atilde;o e aceite.</span></span></li> '
cCorpo += '							</ul> '
cCorpo += '						</td> '
cCorpo += '					</tr> '
cCorpo += '				</tbody> '
cCorpo += '			</table> '
*/
cCorpo += '			<p> '
cCorpo += '		</div> '
cCorpo += '		<p>'
cCorpo += '			&nbsp;</p>'
cCorpo += '	</body>'
cCorpo += '</html>

Return cCorpo
