#include "ACDR100.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ACD100RE  ³ Autor ³ Thiago Berna   		³ Data ³ 15/08/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Ordens de Separacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Madero                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function ACD100RE()

Local aOrdem		:= {STR0001}//"Ordem de Separação"
Local aDevice		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
Local bParam		:= {|| Pergunte("ACD100", .T.)}
Local cDevice		:= ""
Local cPathDest	    := GetSrvProfString("StartPath","\system\")
Local cRelName	    := "ACD100RE"
Local cSession	    := GetPrinterSession()
Local lAdjust		:= .F.
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
Local nLocal		:= 1
Local nOrdem		:= 1
Local nOrient		:= 1
Local nPrintType	:= 6
Local oPrinter	    := Nil
Local oSetup		:= Nil
Private nMaxLin	    := 600
Private nMaxCol	    := 800

//#20190815 Thiago Berna - Criacao de parametros necessarios
FSAtuSX1()

cSession	:= GetPrinterSession()
cDevice	    := If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nOrient	    := If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
nLocal		:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nPrintType	:= aScan(aDevice,{|x| x == cDevice })     

oPrinter	:= FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
oSetup		:= FWPrintSetup():New (nFlags,cRelName)

oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , nOrient)
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
oSetup:SetOrderParms(aOrdem,@nOrdem)
oSetup:SetUserParms(bParam)

If oSetup:Activate() == PD_OK 
	fwWriteProfString(cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )	
	fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )	
	fwWriteProfString(cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		
	oPrinter:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER	
	oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	oPrinter:setCopies(Val(oSetup:cQtdCopia))
	
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice		:= IMP_SPOOL
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oPrinter:cPrinter		:= oSetup:aOptions[PD_VALUETYPE]
	Else 
		oPrinter:nDevice		:= IMP_PDF
		oPrinter:cPathPDF		:= oSetup:aOptions[PD_VALUETYPE]
		oPrinter:SetViewPDF(.T.)
	Endif
	
	RptStatus({|lEnd| U_ACD100Imp(@lEnd,@oPrinter)},STR0003)//"Imprimindo Relatorio..."
Else 
	MsgInfo(STR0004) //"Relatório cancelado pelo usuário."
	oPrinter:Cancel()
EndIf

oSetup		:= Nil
oPrinter	:= Nil

Return ''

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | ACD100Imp  ³ Autor ³ Thiago Berna          ³ Data ³15/08/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o corpo do relatorio                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function ACD100Imp(lEnd,oPrinter)

Local nMaxLinha	    := 40
Local nLinCount	    := 0
Local nLinha        := 0
Local aArea		    := GetArea()
Local cQry			:= ""
Local cOrdSep		:= ""
Local cZona         := ""
Private cAliasOS	:= GetNextAlias()
Private nMargDir	:= 15
Private nMargEsq	:= 20
Private nColDes	    := nMargEsq+60
Private nColAmz	    := nColDes+170+85
Private nColEnd	    := nColAmz+45
Private nColLot	    := nColEnd+85

//#TB20190816 Thiago Berna - Ajuste para ocultar campos
//Private nColSLt	    := nColLot+85
//Private nSerie	    := nColSLt+40
//Private nQtOri	    := nSerie+110

Private nQtOri	    := nColLot+85
Private nQtSep	    := nQtOri+85
Private nQtEmb	    := nQtSep+85
Private oFontA7	    := TFont():New('Arial',,7,.T.)
Private oFontA12	:= TFont():New('Arial',,12,.T.)
Private oFontC8	    := TFont():New('Courier new',,8,.T.)
Private li			:= 10
Private nLiItm	    := 0
Private nPag		:= 0

Pergunte("ACD100",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o arquivo temporario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//#TB20190815 Thiago Berna - Parametro para agrupar por zona. (1 - Sim, 2 = Não)
If MV_PAR07 == 1

    cQry := "SELECT CB7_ORDSEP, SB5.B5_CODZON, CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
    cQry += "CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,SUM(CB8_QTDORI) CB8_QTDORI,SUM(CB8_SALDOS) CB8_SALDOS,SUM(CB8_SALDOE) CB8_SALDOE "
    cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
    
    cQry += " FULL OUTER JOIN " + RetSqlTab("SB5")
    cQry += " ON SB5.B5_FILIAL = CB8_FILIAL "
    cQry += " AND SB5.B5_COD = CB8_PROD "
    cQry += " AND SB5.D_E_L_E_T_ = '' "
    
    cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
    cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
    cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
    cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
    cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
    cQry += " CB8_FILIAL = CB7_FILIAL AND"
    cQry += " CB8_ORDSEP = CB7_ORDSEP AND"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Nao Considera as Ordens ja finalizadas ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If MV_PAR05 == 2
        cQry += " CB7_STATUS <> '9' AND"
    EndIf
    
    cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
    cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
    cQry += " GROUP BY CB7_ORDSEP, SB5.B5_CODZON ,CB7_CLIENT,CB7_LOJA,CB7_NOTA,CB7_SERIE,CB7_OP,CB7_STATUS,CB7_ORIGEM,CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER "
    //cQry += " ORDER BY CB7_ORDSEP, SB5.B5_CODZON, CB8_PROD"
	cQry += " ORDER BY CB7_ORDSEP, SB5.B5_CODZON ,CB7_CLIENT,CB7_LOJA,CB7_NOTA,CB7_SERIE,CB7_OP,CB7_STATUS,CB7_ORIGEM,CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER "

ElseIf MV_PAR07 == 2

    cQry := "SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
    cQry += "CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,CB8_QTDORI,CB8_SALDOS,CB8_SALDOE"
    cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
    cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
    cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
    cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
    cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
    cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
    cQry += " CB8_FILIAL = CB7_FILIAL AND"
    cQry += " CB8_ORDSEP = CB7_ORDSEP AND"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Nao Considera as Ordens ja finalizadas ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If MV_PAR05 == 2
        cQry += " CB7_STATUS <> '9' AND"
    EndIf
    cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
    cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
    cQry += " ORDER BY CB7_ORDSEP,CB8_PROD"

EndIf
cQry := ChangeQuery(cQry)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasOS,.T.,.T.)

SetRegua((cAliasOS)->(LastRec()))
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a impressao do relatorio ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !(cAliasOS)->(Eof())
	IncRegua()
	nLiItm		:= 110
	nLinCount	:= 0
    nLinha      := 0
	nPag++
	oPrinter:StartPage()
	U_CabPagina(@oPrinter)
	U_CabItem(@oPrinter,(cAliasOS)->CB7_ORIGEM,@nLinha)

    If nLinha > 0
        nLiItm += nLinha
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os titulos das colunas dos itens ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrinter:SayAlign(li+100+nLinha,nMargDir,STR0005,oFontC8,200,200,,0)//"Produto"
	oPrinter:SayAlign(li+100+nLinha,nColDes,STR0052,oFontC8,200,200,,0)//"Descrição"
	oPrinter:SayAlign(li+100+nLinha,nColAmz,STR0006,oFontC8,200,200,,0)//"Armazem"
	oPrinter:SayAlign(li+100+nLinha,nColEnd,STR0007,oFontC8,200,200,,0)//"Endereço"
	oPrinter:SayAlign(li+100+nLinha,nColLot,STR0008,oFontC8,200,200,,0)//"Lote"
	
	//#TB20190816 Thiago Berna - Ajuste para ocultar campos
	//oPrinter:SayAlign(li+100+nLinha,nColSLt,STR0009,oFontC8,200,200,,0)//"SubLt."
	//oPrinter:SayAlign(li+100+nLinha,nSerie,STR0010,oFontC8,200,200,,0)//"Num. Série"
	
	oPrinter:SayAlign(li+100+nLinha,nQtOri,STR0011,oFontC8,200,200,,0)//"Qtde. Original"
	oPrinter:SayAlign(li+100+nLinha,nQtSep,STR0012,oFontC8,200,200,,0)//"Qtd. a Separar"
	oPrinter:SayAlign(li+100+nLinha,nQtEmb,STR0013,oFontC8,200,200,,0)//"Qtd. a Embalar"
	oPrinter:Line(li+110+nLinha,nMargDir, li+110+nLinha, nMaxCol-nMargEsq,, "-2")
	
	//#TB20190815 Thiago Berna - Parametro para agrupar por zona quando for gerado por Pedido de Venda
    If MV_PAR07 == 1 .And. (cAliasOS)->CB7_ORIGEM == "1" 
        cZona   := (cAliasOS)->B5_CODZON
    EndIf
    
    cOrdSep := (cAliasOS)->CB7_ORDSEP
	
	While !(cAliasOS)->(Eof()) .and. IIF ( MV_PAR07 == 1 , (cAliasOS)->B5_CODZON == cZona .And. (cAliasOS)->CB8_ORDSEP == cOrdSep , (cAliasOS)->CB8_ORDSEP == cOrdSep ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia uma nova pagina caso nao estiver em EOF ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLinCount == nMaxLinha
			oPrinter:StartPage()
			nPag++
			U_CabPagina(@oPrinter)
			nLiItm		:= li+50
			nLinCount	:= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime os titulos das colunas dos itens ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			oPrinter:SayAlign(nLiItm,nMargDir,STR0014,oFontC8,200,200,,0)//"Produto"
			oPrinter:SayAlign(nLiItm,nColDes,STR0052,oFontC8,200,200,,0)//"Descrição"
			oPrinter:SayAlign(nLiItm,nColAmz,STR0015,oFontC8,200,200,,0)//"Armazem"
			oPrinter:SayAlign(nLiItm,nColEnd,STR0016,oFontC8,200,200,,0)//"Endereço"
			oPrinter:SayAlign(nLiItm,nColLot,STR0017,oFontC8,200,200,,0)//"Lote"
			
			//#TB20190816 Thiago Berna - Ajuste para ocultar campos
			//oPrinter:SayAlign(nLiItm,nColSLt,STR0018,oFontC8,200,200,,0)//"SubLt."
			//oPrinter:SayAlign(nLiItm,nSerie,STR0019,oFontC8,200,200,,0)//"Num. Série"
			
			oPrinter:SayAlign(nLiItm,nQtOri,STR0020,oFontC8,200,200,,0)//"Qtde. Original"
			oPrinter:SayAlign(nLiItm,nQtSep,STR0021,oFontC8,200,200,,0)//"Qtd. a Separar"
			oPrinter:SayAlign(nLiItm,nQtEmb,STR0022,oFontC8,200,200,,0)//"Qtd. a Embalar"
			oPrinter:Line(li+nLiItm,nMargDir, li+nLiItm, nMaxCol-nMargEsq,, "-2")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os itens da ordem de separacao ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrinter:SayAlign(li+nLiItm,nMargDir,(cAliasOS)->CB8_PROD ,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColDes,SubStr(Posicione('SB1',1,xFilial('SB1') + (cAliasOS)->CB8_PROD,'B1_DESC'),1,60) ,oFontC8,250,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColAmz,(cAliasOS)->CB8_LOCAL,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColEnd,(cAliasOS)->CB8_LCALIZ,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColLot,(cAliasOS)->CB8_LOTECT,oFontC8,200,200,,0)
		
		//#TB20190816 Thiago Berna - Ajuste para ocultar campos
		//oPrinter:SayAlign(li+nLiItm,nColSLt,(cAliasOS)->CB8_NUMLOT,oFontC8,200,200,,0)
		//oPrinter:SayAlign(li+nLiItm,nSerie,(cAliasOS)->CB8_NUMSER,oFontC8,200,200,,0)
		
		oPrinter:SayAlign(li+nLiItm,nQtOri+li,Transform((cAliasOS)->CB8_QTDORI,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0) 
		oPrinter:SayAlign(li+nLiItm,nQtSep+li,Transform((cAliasOS)->CB8_SALDOS,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		oPrinter:SayAlign(li+nLiItm,nQtEmb+li,Transform((cAliasOS)->CB8_SALDOE,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		
		nLinCount++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a pagina quando atingir a quantidade maxima de itens ³ 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nLinCount == nMaxLinha
			oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
			oPrinter:EndPage()
		Else
			nLiItm += li
		EndIf
			
		(cAliasOS)->(dbSkip())
		Loop
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a pagina se a quantidade de itens for diferente da quantidade ³ 
	//³ maxima, para evitar que a pagina seja finalizada mais de uma vez.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLinCount <> nMaxLinha
		oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
		oPrinter:EndPage()
	EndIf
EndDo

oPrinter:Print()

(cAliasOS)->(dbCloseArea())
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | CabPagina  ³ Autor ³ Thiago Berna          ³ Data ³15/08/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CabPagina(oPrinter)

Private nCol1Dir	:= 720-nMargDir   
Private nCol2Dir	:= 760-nMargDir

oPrinter:Line(li+5, nMargDir, li+5, nMaxCol-nMargEsq,, "-8")

oPrinter:SayAlign(li+10,nMargDir,STR0023,oFontA7,200,200,,0)//"SIGA/ACD100RE/v12"
oPrinter:SayAlign(li+20,nMargDir,STR0024+Time(),oFontA7,200,200,,0)//"Hora: "
oPrinter:SayAlign(li+30,nMargDir,STR0025+FWFilialName(,,2) ,oFontA7,300,200,,0)//"Empresa: "

oPrinter:SayAlign(li+20,340,STR0026,oFontA12,nMaxCol-nMargEsq,200,2,0)//"Impressão das Ordens de Separação"

oPrinter:SayAlign(li+10,nCol1Dir,STR0027,oFontA7,200,200,,0)//"Folha   : "
oPrinter:SayAlign(li+20,nCol1Dir,STR0028,oFontA7,200,200,,0)//"Dt. Ref.: "
oPrinter:SayAlign(li+30,nCol1Dir,STR0029,oFontA7,200,200,,0)//"Emissão : "

oPrinter:SayAlign(li+10,nCol2Dir,AllTrim(STR(nPag)),oFontA7,200,200,,0)
oPrinter:SayAlign(li+20,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)
oPrinter:SayAlign(li+30,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)

oPrinter:Line(li+40,nMargDir, li+40, nMaxCol-nMargEsq,, "-8")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | CabItem    ³ Autor ³ Thiago Berna          ³ Data ³15/08/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CabItem(oPrinter,cOrigem,nLinha)

Local cOrdSep		:= AllTrim((cAliasOS)->CB7_ORDSEP)
Local cZona         := ""
Local cPedVen		:= ""
Local cCarga        := ""
Local cCarAnt		:= ""
Local cVeiculo      := ""
Local cQry          := ""
Local cClient		:= AllTrim((cAliasOS)->CB7_CLIENT)+"-"+AllTrim((cAliasOS)->CB7_LOJA)
Local cNFiscal	    := AllTrim((cAliasOS)->CB7_NOTA)+"-"+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE')))
Local cOP			:= AllTrim((cAliasOS)->CB7_OP)
Local cStatus		:= RetStatus((cAliasOS)->CB7_STATUS)
Local cAliasCA     	:= GetNextAlias()

If MV_PAR07 == 1
    cZona   := AllTrim((cAliasOS)->B5_CODZON) + ' ' + AllTrim(Posicione('DC4',1,xFilial('DC4')+(cAliasOS)->B5_CODZON,"DC4_DESZON"))
Else    
    cPedVen	:= AllTrim((cAliasOS)->CB7_PEDIDO)
EndIf

oPrinter:SayAlign(li+60,nMargDir,STR0030,oFontC8,200,200,,0)//"Ordem de Separação:"
oPrinter:SayAlign(li+60,nMargDir+105,cOrdSep,oFontC8,200,200,,0)

If Alltrim(cOrigem) == "1" // Pedido venda
	
	//#TB20190815 Thiago Berna - Parametro para agrupar por zona. (1 - Sim, 2 = Não)
    If MV_PAR07 == 2
        oPrinter:SayAlign(li+60,nMargDir+160,STR0031,oFontC8,200,200,,0)//"Pedido de Venda:"
    
        If Empty(cPedVen) .And. (cAliasOS)->CB7_STATUS <> "9"
            oPrinter:SayAlign(li+60,nMargDir+245,STR0047,oFontC8,200,200,,0)//"Aglutinado"
            oPrinter:SayAlign(li+72,nMargDir,STR0048,oFontC8,200,200,,0)//"PV's Aglutinados:"
            oPrinter:SayAlign(li+72,nMargDir+105,A100AglPd(cOrdSep),oFontC8,550,200,,0)		
        Else
            oPrinter:SayAlign(li+60,nMargDir+245,cPedVen,oFontC8,200,200,,0)
        EndIf

    Else
        //#TB20190816 Thiago Berna - Preenchimento de dados de Zona
        oPrinter:SayAlign(li+72,nMargDir,STR0049,oFontC8,200,200,,0)//"Zona Arm.:"
        oPrinter:SayAlign(li+72,nMargDir+50,cZona,oFontC8,550,200,,0)

        //#TB20190816 Thiago Berna - Preenchimento de dados de Carga
        cQry := "SELECT SC9.C9_PRODUTO, SC9.C9_CARGA, SC9.C9_SEQCAR, CB7_ORDSEP,SB5.B5_CODZON,CB8_ORDSEP "
        cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
        
        cQry += " FULL OUTER JOIN " + RetSqlTab("SB5")
        cQry += " ON SB5.B5_FILIAL = CB8_FILIAL "
        cQry += " AND SB5.B5_COD = CB8_PROD "
        cQry += " AND SB5.D_E_L_E_T_ = '' "

        cQry += " INNER JOIN " + RetSqlTab("SC9")
        cQry += " ON SC9.C9_FILIAL = CB8_FILIAL "
        cQry += " AND SC9.C9_PRODUTO = CB8_PROD "
        cQry += " AND SC9.C9_ORDSEP = CB8_ORDSEP "
        cQry += " AND SC9.D_E_L_E_T_ = '' "
        
        cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
        cQry += " CB7_ORDSEP = '" + cOrdSep +"' AND"
        cQry += " CB8_FILIAL = CB7_FILIAL AND"
        cQry += " CB8_ORDSEP = CB7_ORDSEP AND"
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Nao Considera as Ordens ja finalizadas ³ 
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If MV_PAR05 == 2
            cQry += " CB7_STATUS <> '9' AND"
        EndIf
        
        cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
        cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
        cQry += " AND SB5.B5_CODZON = '" + AllTrim((cAliasOS)->B5_CODZON) + "' "

        cQry += " ORDER BY SC9.C9_CARGA, SC9.C9_SEQCAR, CB7_ORDSEP,SB5.B5_CODZON,CB8_ORDSEP, SC9.C9_PRODUTO  "

        cQry := ChangeQuery(cQry)                  
        DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasCA,.T.,.T.)

        While !(cAliasCA)->(Eof()) .And. !Empty(AllTrim((cAliasOS)->B5_CODZON))
            If !Empty((cAliasCA)->C9_CARGA) .And. cCarAnt != AllTrim((cAliasCA)->C9_CARGA) 
                cCarga := AllTrim((cAliasCA)->C9_CARGA) + '|' + AllTrim((cAliasCA)->C9_SEQCAR)
                cCarga += ' - ' + AllTrim(Posicione('DB0',1,xFilial('DB0')+Posicione('SB1',1,xFilial('SB1')+(cAliasCA)->C9_PRODUTO,'B1_TIPCAR'),'DB0_DESMOD'))
                oPrinter:SayAlign(li+100+nLinha,nMargDir,STR0050,oFontC8,200,200,,0) //"Carga:"
                oPrinter:SayAlign(li+100+nLinha,nMargDir+50,cCarga,oFontC8,550,200,,0)
        
                cVeiculo := Posicione('DAK',1,xFilial('DAK') + (cAliasCA)->C9_CARGA + (cAliasCA)->C9_SEQCAR, 'DAK_CAMINH')
                cVeiculo += ' - ' + Posicione('DA3',1,xFilial('DA3') + Posicione('DAK',1,xFilial('DAK') + (cAliasCA)->C9_CARGA + (cAliasCA)->C9_SEQCAR, 'DAK_CAMINH'), 'DA3_DESC')
                oPrinter:SayAlign(li+100+nLinha,nMargDir+430,STR0051,oFontC8,200,200,,0)//"Veículo:"
                oPrinter:SayAlign(li+100+nLinha,nMargDir+470,cVeiculo,oFontC8,200,200,,0)
                nLinha += 12
            EndIf
            cCarAnt := AllTrim((cAliasCA)->C9_CARGA)
            (cAliasCA)->(DbSkip())
        EndDo
        
        If nLinha > 0
            nLinha += 12
            oPrinter:Line(li+100+nLinha,nMargDir, li+100+nLinha, nMaxCol-nMargEsq,, "-2")
        EndIf

        (cAliasCA)->(DbCloseArea())
        
        //#TB20190816 Thiago Berna - Retorna para o cAliasOS
        DbSelectArea(cAliasOS)

    EndIf

	oPrinter:SayAlign(li+60,nMargDir+310,STR0032,oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)

ElseIf Alltrim(cOrigem) == "2" // Nota Fiscal
	oPrinter:SayAlign(li+60,nMargDir+160,STR0033,oFontC8,200,200,,0)//"Nota Fiscal:"
	oPrinter:SayAlign(li+60,nMargDir+230,cNFiscal,oFontC8,200,200,,0)
	oPrinter:SayAlign(li+60,nMargDir+310,STR0034,oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
ElseIf Alltrim(cOrigem) == "3" // Ordem de Producao
	oPrinter:SayAlign(li+60,nMargDir+160,STR0035,oFontC8,200,200,,0)//"Ordem de Produção:"
	oPrinter:SayAlign(li+60,nMargDir+255,cOP,oFontC8,200,200,,0)
EndIf

oPrinter:SayAlign(li+60,nMargDir+430,STR0036,oFontC8,200,200,,0)//"Status:"
oPrinter:SayAlign(li+60,nMargDir+470,cStatus,oFontC8,200,200,,0)
oPrinter:Line(li+90,nMargDir, li+90, nMaxCol-nMargEsq,, "-2")

If MV_PAR06 == 1
	oPrinter:FWMSBAR("CODE128",5/*nRow*/,60/*nCol*/,AllTrim(cOrdSep),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | RetStatus  ³ Autor ³ Thiago Berna          ³ Data ³15/08/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Status da Ordem de Separacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RetStatus(cStatus)

Local cDescri	:= ""

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= STR0037//"Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= STR0038//"Em separacao"
ElseIf cStatus == "2"
	cDescri:= STR0039//"Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= STR0040//"Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= STR0041//"Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= STR0042//"Nota gerada"
ElseIf cStatus == "6"
	cDescri:= STR0043//"Nota impressa"
ElseIf cStatus == "7"
	cDescri:= STR0044//"Volume impresso"
ElseIf cStatus == "8"
	cDescri:= STR0045//"Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:= STR0046//"Finalizado"
EndIf

Return(cDescri)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | A100AglPd  ³ Autor ³ Materiais             ³ Data ³ 08/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna String com os Pedidos de Venda aglutinados na OS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A100AglPd(cOrdSep)

Local cAliasPV	:= GetNextAlias()
Local cQuery		:= ""
Local cPedidos	:= ""
Local aArea		:= GetArea()

cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE C9_ORDSEP = '"+cOrdSep+"' AND "
cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND D_E_L_E_T_ = '' ORDER BY C9_PEDIDO"

cQuery := ChangeQuery(cQuery)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPV,.T.,.T.)

While !(cAliasPV)->(EOF())
	cPedidos += (cAliasPV)->C9_PEDIDO+"/"
	(cAliasPV)->(dbSkip())
EndDo

(cAliasPV)->(dbCloseArea())
RestArea(aArea)

If Len(cPedidos) > 119
	cPedidos := SubStr(cPedidos,1,119)+"..."
EndIf

Return cPedidos

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FSAtuSX1  ³ Autor ³ Thiago Berna           ³ Data ³ 15/08/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui parametro MV_PAR07 para agrupar por Zona              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACD100RE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSAtuSX1()
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

AutoGrLog( "Ínicio da Atualização " + cAlias + CRLF )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Perguntas
//

aAdd( aSX1, { ;
	'ACD100'																, ; //X1_GRUPO
	'07'																	, ; //X1_ORDEM
	'Agrupa por Zona de Arm. ?'		          								, ; //X1_PERGUNT
	'Agrupa por Zona de Arm. ?'		        								, ; //X1_PERSPA
	'Agrupa por Zona de Arm. ?'		        								, ; //X1_PERENG
	'MV_CH7'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR07'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Não'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''		    															, ; //X1_DEF03
	''			    														, ; //X1_DEFSPA3
	''				    													, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL


//
// Atualizando dicionário
//

nPosPerg:= aScan( aEstrut, "X1_GRUPO"   )
nPosOrd := aScan( aEstrut, "X1_ORDEM"   )
nPosTam := aScan( aEstrut, "X1_TAMANHO" )
nPosSXG := aScan( aEstrut, "X1_GRPSXG"  )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX1[nI][nPosSXG]  )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX1[nI][nPosSXG] ) )
			If aSX1[nI][nPosTam] <> SXG->XG_SIZE
				aSX1[nI][nPosTam] := SXG->XG_SIZE				
			EndIf
		EndIf
	EndIf

	If !SX1->( dbSeek( PadR( aSX1[nI][nPosPerg], nTam1 ) + PadR( aSX1[nI][nPosOrd], nTam2 ) ) )		
		RecLock( "SX1", .T. )
		
		For nJ := 1 To Len( aSX1[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
			EndIf
		Next nJ

		MsUnLock()

	EndIf

Next nI

Return NIL