#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"   
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM007
E-mail com aviso de entrega do pedido

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RCOM007(cEmp,cFil) 
   

	If Empty(cEmp)
		cEmp := '02'
		cFil := '01'
	EndIf
	RpcSetType( 3 )           
	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil    
	
    If DtoS(dDataBase) > GetMv('TCP_DREL07') .AND. Time() > "06:29:00"

	 	PUTMV('TCP_DREL07', DtoS(dDataBase))
    	
		Processa( {|| PROCURAPC()} )
		//Conout(4)
		QRYPC->(DbGoTop())  
		While !QRYPC->(Eof())
			EXECUTA(QRYPC->C7_NUM)
			QRYPC->(DbSkip())
		EndDo

	EndIF

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} EXECUTA
E-mail com aviso de entrega do pedido 

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function EXECUTA(cNum)
	Local cArq		:= ''
		
	Local lRet		:= .F. 
	Local nDesc
	Local cQuery	:= ""
	Local cCorpo	:= ""    

	Private cTime		:= TIME()	
	Private cDirPdf 	:= "\_PEDIDO_PDF\"
	Private cNomeRel 	:= "PCENT_" + SubStr(DtoS(Date()),1,4) + SubStr(DtoS(Date()),5,2) + SubStr(DtoS(Date()),7,2) +;
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
            
//Conout(5)
	Processa( {|| GERADADOS(cNum)} )
//Conout(6)
	//Verifica se a pasta existe
	If !ExistDir(cDirPdf)
		MakeDir(cDirPdf)
	EndIf
	        
	//Conout(7)
    	oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )

	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(05,05,05,05)	    

	oPrint:cPathPDF := cDirPdf
		
	ImpCabec()
   //Conout(8)
	nPagi := 1

	nLin += 70		
	oPrint:Say(nLin,0050,"Código",oFont10n)
	oPrint:Say(nLin,0390,"Descrição",oFont10n)
	oPrint:Say(nLin,1550,"UM",oFont10n) 
	oPrint:Say(nLin,1750,"Quantidade",oFont10n) 
	oPrint:Say(nLin,2150,"Valor R$",oFont10n) 
	oPrint:Say(nLin,2650,"Total R$",oFont10n) 

	nValor := 0
	ProcRegua(RecCount())
	QRY->(DbGoTop())  
	While !QRY->(Eof())
											
		nLin += 10
		oPrint:Line(nLin,0050,nLin,3000)                          
		VERQUEBRA("N") 
		nLin += 30 

		oPrint:Say(nLin,0050,QRY->C7_PRODUTO,oFont10n)
//		oPrint:Say(nLin,0390,Posicione("SB1",1,xFilial("SB1")+QRY->C7_PRODUTO,"B1_DESC"),oFont10n)
		oPrint:Say(nLin,1550,QRY->C7_UM,oFont10n)
		oPrint:SayAlign(nLin-30,1750,Transform(QRY->C7_QUANT-QRY->C7_QUJE,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK ,1) 
		oPrint:SayAlign(nLin-30,2150,Transform(QRY->C7_PRECO,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK,1) 
		oPrint:SayAlign(nLin-30,2650,Transform((QRY->C7_QUANT-QRY->C7_QUJE)*QRY->C7_PRECO,"@E 99,999,999.99"),oFont10n,180, , CLR_BLACK ,1) 

		cDescProd := Posicione('SB5',1,xFilial('SB5')+QRY->C7_PRODUTO,"B5_DCOMPR")   
		If Empty(Alltrim(cDescProd)) 
			cDescProd := Posicione('SB5',1,xFilial('SB5')+QRY->C7_PRODUTO,"B5_CEME")   
		EndIf 		
		If Empty(Alltrim(cDescProd)) 
			cDescProd := Posicione('SB1',1,xFilial('SB1')+QRY->C7_PRODUTO,"B1_DESC")
		EndIf 
                                                  
        nTval := INT(Len(Alltrim(cDescProd))/70)+IIF(MOD(Len(Alltrim(cDescProd)),70)==0,0,1)
 
		For nDesc := 1 to nTval
			oPrint:Say(nLin,0390,Substr(cDescProd,(1+(nDesc-1)*70),70),oFont10)   
			IF nDesc != nTVal
				nLin+=30
			EndIF
		Next

		nValor += (QRY->C7_QUANT-QRY->C7_QUJE)*QRY->C7_PRECO
		
		cUsrPed := QRY->C7_USER
		 				
		IncProc()
		QRY->(DbSkip())
	Enddo
	    
	nLin += 10      
	oPrint:Line(nLin,0050,nLin,3000)
	nLin += 050     
	oPrint:Say(nLin,2350,"TOTAL DO PEDIDO:  R$",oFont13n)
	oPrint:Say(nLin,2840,Transform(nValor,"@E 99,999,999.99"),oFont13n,,,,1)	
	
	oPrint:Say(2250,2800,"Página: "+Transform(nPagi,"@E 99"),oFont10n)
	oPrint:Say(2250,0070,DtoC(Date())+"  "+cTime,oFont10n)

	oPrint:EndPage()
	oPrint:Preview()      
	
	//Envia email do relatorio

	cAssunto := 'Aviso de entrega de pedido'
	
	//=============================================================================
	// falta fazer o corpo do e-mail
	//==============================================================================
	 //Conout(9)
	cCorpo := CorpoM(cNum) 
	If empty(alltrim(GetMv("TCP_MAILTS")))
		cTo		 := SA2->A2_EMAIL
		cCC		 :=  UsrRetMail(cUsrPed)   
	Else         
		cTo		 := alltrim(GetMv("TCP_MAILTS"))
		cCC		 := alltrim(GetMv("TCP_MAILTS"))     	
	EndIf

	If !empty(alltrim(GetMv("TCP_MAILAP")))
		If !Empty(Alltrim(cCC))
			cCC		 +=  ";"+alltrim(GetMv("TCP_MAILAP"))
		Else
	   		cCC		 :=  alltrim(GetMv("TCP_MAILAP"))
		EndIf
	Endif

	
	If !Empty(Alltrim(cTo))
		U_MCOM016(cTo, cCC, cAssunto, cCorpo, cDirPdf + cNomeRel, .F. )
	Else
		Alert('E-mail não enviado ao fornecedor devido a falta de cadastro de endereço de e-mail')
	EndIf
	 //Conout(11)
	nRet := FERASE(cDirPdf + cNomeRel)

	QRY->(dbCloseArea())
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} IMPCABEC
Cabeçalho do relatório

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function IMPCABEC()

	oPrint:StartPage()   
	oPrint:SayBitmap( 080, 140,  "\sigaadv\lgrl01.bmp", 400, 150)	
	oPrint:Say(0150,1470,SM0->M0_NOME,oFont24n)
	oPrint:Say(0220,1030,"FALTAM "+ALLTRIM(STR((StoD(QRY->C7_DATPRF)-ddatabase)*24))+" HORAS PARA A ENTREGA DO PEDIDO ABAIXO",oFont16n)
	oPrint:Say(0290,1340,"PEDIDO DE COMPRAS",oFont16n)
	oPrint:Line(0245,0050,0245,3000)                          
	oPrint:Line(0250,0050,0250,3000)                          
	nLin := 320
	nLin += 35
	oPrint:Say(nLin,0050,"Pedido de Compra:",oFont13n)
	oPrint:Say(nLin,0350,Alltrim(QRY->C7_NUM),oFont13n)
	oPrint:Say(nLin,0950,"Dt.Entrega:",oFont13n)  
	oPrint:Say(nLin,1200,DtoC(STOD(QRY->C7_DATPRF)),oFont13n)
	oPrint:Say(nLin,1550,"Cond. Pagto:",oFont13n)  
	oPrint:Say(nLin,1800,Posicione('SE4',1,xFilial('SE4')+QRY->C7_COND,"E4_DESCRI"),oFont13n)
	nLin+=35
	oPrint:Say(nLin,0050,"Fornecedor:",oFont13n)
	oPrint:Say(nLin,0350,Alltrim(QRY->C7_FORNECE)+'/'+Alltrim(QRY->C7_LOJA)+' - '+Posicione("SA2",1,xFilial("SA2")+QRY->C7_FORNECE+QRY->C7_LOJA,"A2_NOME"),oFont13n)

	
	
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} VERQUEBRA
Função para quebra de página

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015
/*/
//-------------------------------------------------------------------------------
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

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GERADADOS
Busca informações para geração de e-mail

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GERADADOS(cNum)
	Local cQuery  	:= ''
	Local aItem    	:= {}
	                            
	cQuery += " SELECT"
	cQuery += "	SC7.* "
	cQuery += " FROM "
	cQuery +=  retSqlName('SC7') + " SC7 " 
	cQuery += " WHERE" 
	cQuery += "     SC7.C7_FILIAL  = '"+xFilial('SC7')+"'  AND SC7.C7_NUM = '"+cNum+"'  AND SC7.C7_RESIDUO = ' ' AND SC7.C7_ENCER = ' '"
	cQuery += " AND SC7.C7_CONAPRO = 'L' AND SC7.D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRY", .F., .T.)
	dbSelectArea("QRY")
	QRY->(dbGotop())
	
Return 
                                                    
//-------------------------------------------------------------------------------
/*/{Protheus.doc} PROCURAPC
Busca informações para geração de e-mail

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/                      

//-------------------------------------------------------------------------------
Static Function PROCURAPC()
	Local cQuery  	:= ''
	Local aItem    	:= {}
	Local nDias 	:= GetMv("TCP_DIASPC")
    Local dDias		:= dDatabase
	Local nI
	If (Select("QRYPC") <> 0)
  		DbSelectArea("QRYPC")
   		QRYPC->(DbCloseArea())
    Endif

		
	For nI := 1 to nDias 
	    
		dDias		:= dDatabase+nI
	
		cQuery += " SELECT  DISTINCT SC7.C7_NUM  "
		cQuery += " FROM "
		cQuery +=  retSqlName('SC7') + " SC7 " 
		cQuery += " WHERE" 
		cQuery += "     SC7.C7_FILIAL  = '"+xFilial('SC7')+"'  AND SC7.C7_DATPRF  = '"+DtoS(dDias)+"' AND SC7.C7_RESIDUO = ' ' AND SC7.C7_ENCER = ' '"
		cQuery += " AND SC7.C7_CONAPRO = 'L' AND SC7.D_E_L_E_T_ <> '*'"
		If nI != nDias
			cQuery += " UNION "
		EndIf
	Next

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRYPC", .F., .T.)
	dbSelectArea("QRYPC")
	QRYPC->(dbGotop())
	
Return 
          
Static Function CorpoM(cPedido)
Local cCorpo := ""
 
cCorpo += '<html> '
cCorpo += '	<body> '
cCorpo += '		<div style="text-align: left;"> '
cCorpo += '			<p> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Bom-dia,</span></span> '
cCorpo += '			<BR><BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Informamos através deste que nosso pedido de compras nº '+Alltrim(cPedido)+' consta em aberto em nosso sistema, para evitarmos cobrança de multa através de "DESCONTO" conforme informado em nossa solicitação de orçamento e no envio do pedido de compras aprovado, informamos abaixo sua situação.</span></span></p> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Data prevista entregue: '+DtoC(Posicione('SC7',1,xFilial('SC7')+cPedido,"C7_DATPRF"))+'</span></span></p> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Status: Faltam '+ALLTRIM(STR(SC7->C7_DATPRF-ddatabase))+' dia(s) para entrega dentro do PRAZO</span></span></p> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Quaisquer dúvidas, favor entrar em contato com o comprador responsável deste pedido através de seu e-mail ou telefone.</span></span></p> '
cCorpo += '			<BR> '
cCorpo += '			<BR> '
cCorpo += '				<span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;">TCP</span></span></p> '
cCorpo += '		</div> '
cCorpo += '	</body>'
cCorpo += '</html>


Return cCorpo
























