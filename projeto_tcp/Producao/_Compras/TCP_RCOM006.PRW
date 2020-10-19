#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM006
E-mail com aviso de entrega do pedido

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RCOM006()

Local cTime		:= TIME()
Local aPedidos	:= {}
Local nDesc

Private cDirPdf 	:= "\_PEDIDO_PDF\"
Private cNomeRel 	:= "PC_"+"_" + SubStr(DtoS(Date()),1,4) + SubStr(DtoS(Date()),5,2) + SubStr(DtoS(Date()),7,2) +;
SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2) + ".pdf"

Private nPagi    	:= 0

Private oFont10		:= TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
Private oFont10n	:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
Private oFont12n	:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
Private oFont13n	:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)
Private oFont16n	:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
Private oFont24n	:= TFont():New("Arial",,24,,.T.,,,,.F.,.F.)

Private MV_PAR01 	:= 3
Private MV_PAR02 	:= 3

Private nLin		:= 0
Private oPrint		:= NIL
Private cUsrPed		:= ""
Private cReqSc		:= ""

Processa( {|| GERADADOS()} )

QRY->(DbGoTop()) //Se não tem dados para a NF, sai
IF QRY->(Eof()) .OR. SF1->F1_TIPO != 'N'
	Return
EndIF
//Verifica se a pasta existe
If !ExistDir(cDirPdf)
	MakeDir(cDirPdf)
EndIf

oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )

oPrint:SetLandscape()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(05,05,05,05)

oPrint:cPathPDF := cDirPdf

ImpCabec()

nPagi := 1

nLin += 70
oPrint:Say(nLin,0050,"Código",oFont10n)
oPrint:Say(nLin,0390,"Descrição",oFont10n)
oPrint:Say(nLin,1550,"Quantidade",oFont10n)
oPrint:Say(nLin,1950,"Valor R$",oFont10n)
oPrint:Say(nLin,2350,"Total R$",oFont10n)
oPrint:Say(nLin,2750,"Pedido",oFont10n)

aPedidos := {{'',ddatabase}}//zerar a matriz
ProcRegua(RecCount())
QRY->(DbGoTop())
While !QRY->(Eof())
	
	nLin += 10
	oPrint:Line(nLin,0050,nLin,3000)
	VERQUEBRA("N")
	nLin += 30
	
	oPrint:Say(nLin,0050,QRY->D1_COD,oFont10n)
	//		oPrint:Say(nLin,0390,Posicione("SB1",1,xFilial("SB1")+QRY->D1_COD,"B1_DESC"),oFont10n)
	oPrint:SayAlign(nLin-30,1550,Transform(QRY->D1_QUANT,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK ,1)
	oPrint:SayAlign(nLin-30,1950,Transform(QRY->D1_VUNIT,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK,1)
	oPrint:SayAlign(nLin-30,2350,Transform(QRY->D1_TOTAL,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK ,1)
	oPrint:Say(nLin,2750,QRY->D1_PEDIDO,oFont10n)
	cUsrPed := Posicione('SC7',1,xFilial('SC7')+QRY->D1_PEDIDO,"C7_USER")
	If cEmpAnt == '02' //campo customizado não utilizado na TCP LOG
		cReqSc	:= Posicione('SC1',1,xFilial('SC1')+Posicione('SC7',1,xFilial('SC7')+QRY->D1_PEDIDO,"C7_NUMSC"),'C1_REQUISI')
	EndIf
	If aScan(aPedidos,{|x|allTrim(x[1])==QRY->D1_PEDIDO}) == 0
		aadd(aPedidos,{QRY->D1_PEDIDO,StoD(QRY->D1_DTDIGIT)})
	EndIf
	
	cDescProd := Posicione('SB5',1,xFilial('SB5')+QRY->D1_COD,"B5_DCOMPR")
	If Empty(Alltrim(cDescProd))
		cDescProd := Posicione('SB5',1,xFilial('SB5')+QRY->D1_COD,"B5_CEME")
	EndIf
	If Empty(Alltrim(cDescProd))
		cDescProd := Posicione('SB1',1,xFilial('SB1')+QRY->D1_COD,"B1_DESC")
	EndIf
	
	nTval := INT(Len(Alltrim(cDescProd))/70)+IIF(MOD(Len(Alltrim(cDescProd)),70)==0,0,1)
	
	For nDesc := 1 to nTval
		oPrint:Say(nLin,0390,Substr(cDescProd,(1+(nDesc-1)*70),70),oFont10)
		IF nDesc != nTVal
			nLin+=30
		EndIF
	Next
	
	IncProc()
	QRY->(DbSkip())
Enddo

nLin += 10
oPrint:Line(nLin,0050,nLin,3000)
nLin += 050
oPrint:Say(nLin,2350,"TOTAL DA NOTA:  R$",oFont13n)
oPrint:Say(nLin,2840,Transform(SF1->F1_VALBRUT,"@E 99,999,999.99"),oFont13n,,,,1)

oPrint:Say(2250,2800,"Página: "+Transform(nPagi,"@E 99"),oFont10n)
oPrint:Say(2250,0070,DtoC(Date())+"  "+cTime,oFont10n)

oPrint:EndPage()
oPrint:Preview()

//Envia email do relatorio

cAssunto := 'Pedido Entregue'
//=============================================================================
// falta fazer o corpo do e-mail
//==============================================================================

cCorpo := CorpoM(aPedidos)
If empty(alltrim(GetMv("TCP_MAILTS")))
	cTo		 := SA2->A2_EMAIL
	cCC		 :=  UsrRetMail(cUsrPed)
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

If !Empty(Alltrim(cTo))
	cArqLog := "\AFS\LOG\"+Alltrim(Funname())+"_"+DtoS(dDatabase)+"_"+StrTran(time(),":","")+"_"+retcodusr()+"_"+SF1->F1_FILIAL+SF1->F1_DOC+".txt"
	MemoWrite(cArqLog,SF1->F1_DOC)
	
	U_MCOM016(cTo, cCC, cAssunto, cCorpo, cDirPdf + cNomeRel, .F. )
Else
	Alert('E-mail não enviado ao fornecedor devido a falta de cadastro de endereço de e-mail')
EndIf

nRet := FERASE(cDirPdf + cNomeRel)

QRY->(dbCloseArea())
Return

/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! IMPCABEC    ! Autor ! Mario L. B. Faria   ! Data ! 16/06/2014 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Imprime cabeçalho                                             !
+------------+---------------------------------------------------------------+
*/
Static Function IMPCABEC()

oPrint:StartPage()
oPrint:SayBitmap( 080, 140,  "\sigaadv\lgrl01.bmp", 400, 150)
oPrint:Say(0150,1360,SM0->M0_NOME,oFont24n)
oPrint:Say(0220,1240,"PEDIDO ENTREGUE",oFont16n)
oPrint:Line(0245,0050,0245,3000)
oPrint:Line(0250,0050,0250,3000)
nLin := 250
nLin += 35
oPrint:Say(nLin,0050,"Nota Fiscal:",oFont13n)
oPrint:Say(nLin,0280,Alltrim(SF1->F1_DOC)+'/'+Alltrim(SF1->F1_SERIE),oFont13n)
nLin+=35
oPrint:Say(nLin,0050,"Fornecedor:",oFont13n)
oPrint:Say(nLin,0280,Alltrim(SF1->F1_FORNECE)+'/'+Alltrim(SF1->F1_LOJA)+' - '+Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME"),oFont13n)
oPrint:Say(nLin,1450,"Dt.Recebimento:",oFont13n)
oPrint:Say(nLin,1680,DtoC(SF1->F1_RECBMTO),oFont13n)



Return

/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! VERQUEBRA   ! Autor ! Mario L. B. Faria   ! Data ! 17/06/2014 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Verifica se deve quebrar página                               !
+------------+---------------------------------------------------------------+
*/
Static Function VERQUEBRA(cChama)

If nLin + 50 > 2150
	oPrint:Say(2250,2800,"Página: "+Transform(nPagi,"@E 99"),oFont10n)
	oPrint:Say(2250,0070,DtoC(Date())+"  "+cTime,oFont10n)
	ImpCabec()
	nPagi ++
	If cChama == "I"
		nLin += 35
	EndIf
Endif

Return

/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! GERADADOS   ! Autor ! Mario L. B. Faria   ! Data ! 16/06/2014 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Rotina para gerar dados                                       !
+------------+---------------------------------------------------------------+
*/
Static Function GERADADOS()
Local cQuery  := ''

If (Select("QRY") <> 0)
	DbSelectArea("QRY")
	QRY->(DbCloseArea())
Endif


cQuery := "SELECT"
cQuery += "	SD1.*"
cQuery += "FROM "
cQuery +=  retSqlName('SD1') + " SD1 "
cQuery += "WHERE"
cQuery += "     SD1.D1_FILIAL  = '"+SF1->F1_FILIAL+"'  AND SD1.D1_DOC  = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"'  "
cQuery += " AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"'  "
cQuery += " AND SD1.D_E_L_E_T_ <> '*'"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRY", .F., .T.)
dbSelectArea("QRY")
QRY->(dbGotop())

Return

Static Function CorpoM(aPedidos)
Local cCorpo := ""
Local cQryStat := ""
Local cStatus := " ENTREGA TOTAL "
Local nI

cCorpo += '<html> '
cCorpo += '	<body> '
cCorpo += '		<div style="text-align: left;"> '
cCorpo += '			<p> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Bom-dia,</span></span> '
cCorpo += '			<BR> <BR>'
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Confirmamos através deste o recebido do(s) nosso(s) pedido(s) de compras conforme anexo e informamos abaixo sua situação.</span></span></p> '
cCorpo += '			<BR> '
For nI := 2 To Len(aPedidos) //pula a primeira posição onde o pedido está ''
	
	If (Select("QRYPC") <> 0)
		DbSelectArea("QRYPC")
		QRYPC->(DbCloseArea())
	Endif
	
	cQryStat := " SELECT  DISTINCT SC7.C7_NUM  "
	cQryStat += " FROM "
	cQryStat +=  retSqlName('SC7') + " SC7 "
	cQryStat += " WHERE"
	cQryStat += "     SC7.C7_FILIAL  = '"+xFilial('SC7')+"'  AND SC7.C7_NUM  = '"+aPedidos[nI,1]+"' AND SC7.C7_RESIDUO = ' ' AND SC7.C7_ENCER = ' '"
	cQryStat += " AND SC7.C7_CONAPRO = 'L' AND SC7.D_E_L_E_T_ <> '*' AND SC7.C7_QUANT > SC7.C7_QUJE AND SC7.C7_CONTRA  = ' '  "
	
	cQryStat := ChangeQuery(cQryStat)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryStat), "QRYPC", .F., .T.)
	dbSelectArea("QRYPC")
	QRYPC->(dbGotop())
	If !QRYPC->(EOF())
		cStatus := " ENTREGA PARCIAL "
	EndIf
	
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Pedidos: '+aPedidos[nI,1]+'</span></span></p> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Data prevista entregue: '+DtoC(Posicione('SC7',1,xFilial('SC7')+aPedidos[nI,1],"C7_DATPRF"))+'</span></span></p> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Data de recepção: '+DtoC(aPedidos[nI,2])+'</span></span></p> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Status:'+cStatus+"-"+IIF(SC7->C7_DATPRF >= aPedidos[nI,2]," NO PRAZO "," FORA DO PRAZO ")+' </span></span></p> '
	cCorpo += '			<BR><BR> '
	
	QRYPC->(dbCloseArea())
	cStatus := " ENTREGA TOTAL "
Next
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Quaisquer dúvidas, favor entrar em contato com o comprador responsável deste pedido através de seu e-mail ou telefone.</span></span></p> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;">TCP</span></span></p> '
cCorpo += '		</div> '
cCorpo += '	</body>'
cCorpo += '</html>


Return cCorpo






