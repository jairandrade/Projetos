#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM009
E-mail com carta de avaliação de fornecedor

@return 
@author Felipe Toazza Caldeira@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RCOM009()
	Local cPerg  := 'ACOM007'
	Local cAlias := GetNextAlias()
	Local dUltData := ''
	Local cUltHora := ''
	Private aErros 	:= {}

	CriaPerg(cPerg)
	//Jair-27-10-2020. Reenvio diretamente da SA2 item posicionado
	IF FunName() == "MATA020"
		//Posiciona na ZZB no ultimo envio da carta
		BeginSQL Alias cAlias
		select ZZB_DATA, ZZB_HORA from %table:ZZB% ZZB
		where  R_E_C_N_O_  = (SELECT MAX(R_E_C_N_O_) AS RECNO FROM %table:ZZB% ZZB1
		WHERE ZZB1.ZZB_FILIAL = ZZB.ZZB_FILIAL
		and ZZB1.ZZB_FORNEC = %Exp:SA2->A2_COD%
		and ZZB1.ZZB_LOJA = %Exp:SA2->A2_LOJA%
		AND ZZB1.%NotDel%)
		AND ZZB.ZZB_FILIAL = %xFilial:ZZB%
		and ZZB.%NotDel%
		EndSQL
		If !(cAlias)->( Eof() )
			dUltData :=DTOC(STOD((cAlias)->ZZB_DATA))
			cUltHora :=(cAlias)->ZZB_HORA
		EndIf
		(cAlias)->(dbCloseArea())
		If MsgYesNo('Deseja reenviar novamente a carta de avaliação do fornecedor:'+SA2->A2_COD+' Loja:'+SA2->A2_LOJA+'?. Ultimo envio foi no dia '+(dUltData)+' as '+cUltHora)
			MV_PAR01 := SA2->A2_COD
			MV_PAR03 := SA2->A2_COD
			MV_PAR02 := SA2->A2_LOJA
			MV_PAR04 := SA2->A2_LOJA
			Processa( {|| PROCURAFOR()})

			Processa({||EXECUTA(QRYFOR->A2_COD, QRYFOR->A2_LOJA) })
		EndIf
	ElseIf FunName() == "MCOM017"
		//Posiciona na ZZB no ultimo envio da carta
		BeginSQL Alias cAlias
		select ZZB_DATA, ZZB_HORA from %table:ZZB% ZZB
		where  R_E_C_N_O_  = (SELECT MAX(R_E_C_N_O_) AS RECNO FROM %table:ZZB% ZZB1
		WHERE ZZB1.ZZB_FILIAL = ZZB.ZZB_FILIAL
		and ZZB1.ZZB_FORNEC = %Exp:ZZB->ZZB_FORNEC%
		and ZZB1.ZZB_LOJA = %Exp:ZZB->ZZB_LOJA%
		AND ZZB1.%NotDel%)
		AND ZZB.ZZB_FILIAL = %xFilial:ZZB%
		and ZZB.%NotDel%
		EndSQL
		If !(cAlias)->( Eof() )
			dUltData :=DTOC(STOD((cAlias)->ZZB_DATA))
			cUltHora :=(cAlias)->ZZB_HORA
		EndIf
		(cAlias)->(dbCloseArea())
		If MsgYesNo('Deseja reenviar novamente a carta de avaliação do fornecedor:'+ZZB->ZZB_FORNEC+' Loja:'+ZZB->ZZB_LOJA+'?. Ultimo envio foi no dia '+dUltData+' as '+cUltHora)
			MV_PAR01 := ZZB->ZZB_FORNEC
			MV_PAR03 := ZZB->ZZB_FORNEC
			MV_PAR02 := ZZB->ZZB_LOJA
			MV_PAR04 := ZZB->ZZB_LOJA
			Processa( {|| PROCURAFOR()})

			Processa({||EXECUTA(QRYFOR->A2_COD, QRYFOR->A2_LOJA) })
		EndIf
	Else

		If !Pergunte(cPerg,.T.)
			Return
		EndIf

		Processa( {|| PROCURAFOR()} )


		QRYFOR->(DbGoTop())
		While !QRYFOR->(Eof())
			Processa({||EXECUTA(QRYFOR->A2_COD, QRYFOR->A2_LOJA) })
			QRYFOR->(DbSkip())
		EndDo

	EndIf
	If len(aErros) > 0
		nRetMsg := Aviso("Atenção","Existem fornecedores com e-mail vazio . Verifique o Log de Erros 'Erro_SA2.txt' ", {"Gera Log.Erros","Fechar"}, 2)
		If nRetMsg == 1
			fSalvArq()
		EndIf
		//envia email de acordo com emails do parametro TCP_ALCADP
		U_RCOM012(aErros)
	EndIf

	Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} EXECUTA
E-mail com aviso de entrega do pedido já atrasado

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function EXECUTA(cCod, cLoja)
	Local cArq		:= ''
	Local lRet		:= .F.
	Local cQuery	:= ""
	Local cTime		:= TIME()
	Local cErro		:= ''

	Private cDirPdf 	:= "\_PEDIDO_PDF\"
	Private cNomeRel 	:= "CARTA_" + cFilAnt + "_" + SubStr(DtoS(dDataBase),1,4) + SubStr(DtoS(dDataBase),5,2) + SubStr(DtoS(dDataBase),7,2) +;
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

	Private nSeqCar		:= 0


	Processa( {|| GERADADOS(cCod,cLoja)} )
	ProcRegua(1000)
	//Verifica se a pasta existe
	If !ExistDir(cDirPdf)
		MakeDir(cDirPdf)
	EndIf

	oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )

	oPrint:SetPortrait()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(05,05,05,05)

	oPrint:cPathPDF := cDirPdf

	ImpCabec(cCod, cLoja) //cabeçalho do relatório

	ImpCorpo() //corpo do relatório

	ImpClassi() //classificação do fornecedor no relatório

	ImpRodape()

	oPrint:EndPage()
	oPrint:Preview()

	//Envia email do relatorio

	cAssunto := 'Carta de avaliação de fornecedor n°'+Alltrim(Str(nSeqCar))+' - Fechamento: '+SUBSTR(QRYFOR->A2_FECHAVA,5,2)+'/'+SUBSTR(QRYFOR->A2_FECHAVA,1,4)
	//=============================================================================
	// falta fazer o corpo do e-mail
	//==============================================================================

	cCorpo := corpo()
	If empty(alltrim(GetMv("TCP_MAILTS")))
		cTo		 := SA2->A2_EMAIL
		cCC		 := GetMv("TCP_MAILRE")
	Else
		cTo		 := alltrim(GetMv("TCP_MAILTS"))
		cCC		 := alltrim(GetMv("TCP_MAILTS"))
	EndIf

	If !Empty(Alltrim(cTo))
		U_MCOM016(cTo, cCC, cAssunto, cCorpo, cDirPdf + cNomeRel, .T. )
		ZZB->(DBSETORDER(1))
		RECLOCK("ZZB",.T.)
		ZZB->ZZB_FILIAL 	:= cFilAnt
		ZZB->ZZB_DATA		:= date()
		ZZB->ZZB_HORA		:= Time()
		ZZB->ZZB_FORNECE	:= SA2->A2_COD
		ZZB->ZZB_LOJA		:= SA2->A2_LOJA
		ZZB->ZZB_RAZAO		:= SA2->A2_NOME
		ZZB->ZZB_USR		:= ALLTRIM(USRRETNAME(RETCODUSR()))
		ZZB->ZZB_PONTUA		:= Posicione("Z08",1,xFilial("Z08")+SA2->A2_COD+SA2->A2_LOJA+MV_PAR05+MV_PAR06,"Z08_PONTOS")
		ZZB->ZZB_CLASSI 	:= Z08->Z08_CLASSI
		ZZB->ZZB_DISPARO	:= SA2->A2_EMAIL
		ZZB->ZZB_STATUS		:= "1" // 1 = ENVIADO OU 2 = ERRO NO ENVIO
		ZZB->(MSUNLOCK())
		ZZB->(DBCLOSEAREA())
	Else
		ZZB->(DBSETORDER(1))
		RECLOCK("ZZB",.T.)
		ZZB->ZZB_FILIAL 	:= cFilAnt
		ZZB->ZZB_DATA		:= date()
		ZZB->ZZB_HORA		:= Time()
		ZZB->ZZB_FORNECE	:= SA2->A2_COD
		ZZB->ZZB_LOJA		:= SA2->A2_LOJA
		ZZB->ZZB_RAZAO		:= SA2->A2_NOME
		ZZB->ZZB_USR		:= ALLTRIM(USRRETNAME(RETCODUSR()))
		ZZB->ZZB_PONTUA		:= Posicione("Z08",1,xFilial("Z08")+SA2->A2_COD+SA2->A2_LOJA+MV_PAR05+MV_PAR06,"Z08_PONTOS")
		ZZB->ZZB_CLASSI 	:= Z08->Z08_CLASSI
		ZZB->ZZB_DISPARO	:= SA2->A2_EMAIL
		ZZB->ZZB_STATUS		:= "2" // 1 = ENVIADO OU 2 = ERRO NO ENVIO
		ZZB->(MSUNLOCK())
		ZZB->(DBCLOSEAREA())

		cErro 	:= 'E-mail não enviado ao fornecedor '+SA2->A2_COD+'/'+SA2->A2_LOJA+' - '+Alltrim(SA2->A2_NOME)+' devido a falta de cadastro de endereço de e-mail no cadastro de Fornecedores.'
		aAdd(aErros, cErro)
		//comentado para gravar erro em um arquivo	Alert('E-mail não enviado ao fornecedor '+SA2->A2_COD+'/'+SA2->A2_LOJA+' - '+Alltrim(SA2->A2_NOME)+' devido a falta de cadastro de endereço de e-mail')

	EndIf

	nRet := FERASE(cDirPdf + cNomeRel)

	QRY->(dbCloseArea())
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} IMPCABEC
Cabeçalho do relatório          	

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function IMPCABEC(cCod, cLoja)
	oPrint:SayBitmap( 020, 030,  "\sigaadv\lgrl01.bmp", 480, 200)
	oPrint:SayBitmap( 000, 1950, "\sigaadv\selotcp.bmp", 420, 300)

	nLin := 250
	nLin += 35
	oPrint:Box( nLin, 50, nLin+170, 2350, "-8")
	nLin += 40
	oPrint:Say(nLin,1100,"INDICE DE",oFont16n)
	nLin += 50
	oPrint:Say(nLin,1050,"DESEMPENHO DE",oFont16n)
	nLin += 50
	oPrint:Say(nLin,1070,"FORNECEDOR",oFont16n)
	nLin += 110
	nSeqCar := GetMv("TCP_SEQCAR")+1
	PutMv("TCP_SEQCAR",nSeqCar)

	oPrint:Box( nLin, 050, nLin+70, 816, "-4")
	oPrint:Say(nLin+40,310,Alltrim(GetMv("TCP_FOCART")),oFont24n)
	oPrint:Box( nLin, 815, nLin+70, 1583, "-4")
	oPrint:Say(nLin+40,1190,'N° '+Alltrim(Str(nSeqCar)),oFont24n)
	oPrint:Box( nLin, 1583, nLin+70, 2350, "-4")
	oPrint:Say(nLin+40,1785,"Fechamento: "+SUBSTR(QRYFOR->A2_FECHAVA,5,2)+'/'+SUBSTR(QRYFOR->A2_FECHAVA,1,4),oFont24n)
	nLin += 120

	oPrint:Box( nLin, 050, nLin+140, 816, "-4")
	oPrint:Box( nLin, 815, nLin+70, 2350, "-4")
	oPrint:Say(nLin+40,817,cCod+"/"+cLoja,oFont24n)
	oPrint:Say(nLin+80,100,"FORNECEDOR:",oFont24n)
	nLin += 70
	oPrint:Box( nLin, 815, nLin+72, 2350, "-4")
	oPrint:Say(nLin+40,817,QRYFOR->A2_NOME,oFont24n)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ImpCorpo
Corpo do relatório

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function ImpCorpo()

	nLin += 180
	oPrint:Say(nLin,50,"Prezado fornecedor,",oFont10n)
	nLin += 65
	oPrint:Say(nLin,80,"O TCP - Terminal de Contêineres de Paranaguá S/A, executa a classificação inicial e avalia mensalmente seus fornecedores",oFont10n)
	nLin += 40
	oPrint:Say(nLin,50,"aceitáveis, baseada na capacidade dos mesmos de fornecerem materiais, produtos, componentes e serviços que satisfaçam aos",oFont10n)
	nLin += 40
	oPrint:Say(nLin,50,"requisitos da qualidade, bem como de sua sintonia com a Politica Ambiental do TCP, quer seja através da compatibilidade",oFont10n)
	nLin += 40
	oPrint:Say(nLin,50,"de seu Sistema de Gestão Ambiental, quer seja através do atendimento das Intruções de Trabalho fomuladas pelo TCP,",oFont10n)
	nLin += 40
	oPrint:Say(nLin,50,"quando aplicável",oFont10n)


Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} impClassi
Classificação do Fornecedor

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function impClassi()
	Local n1
	nLin += 100
	oPrint:Say(nLin,50,"Os métodos, critérios para essa avaliação e reclassificação são dos descritos abaixo:",oFont10n)
	nLin +=65

	QRY->(DbGoTop())
	While !QRY->(Eof())
		IncProc()
		oPrint:Say(nLin,300,"# "+Alltrim(QRY->Z04_DESC)+" ("+Alltrim(STR(QRY->Z04_PESO))+"%)",oFont10n)
		QRY->(DbSkip())
		If !QRY->(Eof())
			oPrint:Say(nLin,1350,"# "+Alltrim(QRY->Z04_DESC)+" ("+Alltrim(STR(QRY->Z04_PESO))+"%)",oFont10n)
			QRY->(DbSkip())
		EndIf
		nLin +=60
	EndDo
	oPrint:Say(nLin,50,"Desta forma o seu Desempenho de Fornecimentos é o seguinte:",oFont10n)
	nLin += 80
	oPrint:Box( nLin, 050, nLin+60, 2350, "-4")
	oPrint:Say(nLin+35,1130,"NOTA",oFont12n)
	nLin += 60
	oPrint:Box( nLin, 050, nLin+120, 1175, "-4")
	oPrint:Box( nLin, 1175, nLin+120, 2350, "-4")
	nLin+=40
	oPrint:Say(nLin,400,"INICIAL E/OU ANTERIOR",oFont12n)
	oPrint:Say(nLin,1750,"ATUAL",oFont12n)
	nLin +=60
	oPrint:Say(nLin,600,QRYFOR->A2_NOTAANT,oFont16n)
	oPrint:Say(nLin,1800,QRYFOR->A2_NOTAFOR,oFont16n)
	nLin += 100
	oPrint:Box( nLin, 050, nLin+60, 1175, "-4")
	oPrint:Box( nLin, 1175, nLin+60, 2350, "-4")
	oPrint:Say(nLin+40,550,"SITUAÇÃO",oFont12n)
	oPrint:Say(nLin+40,1225,Posicione('Z02',1,xFilial('Z02')+QRYFOR->A2_NOTAFOR,"Z02_SITUAC"),oFont12n)
	nLin += 80
	oPrint:Box( nLin, 050, nLin+300, 1175, "-4")
	oPrint:Box( nLin, 1175, nLin+300, 2350, "-4")

	oPrint:Say(nLin+180,0250,"PLANO DE AÇÃO E/OU MELHORIA",oFont12n)

	aObs := QLinha(StrTran(Z02->Z02_PLANOA,chr(10),chr(13)), 60)
	For n1 := 1 To len(aObs)
		IF !Empty(aObs[n1])
			oPrint:Say(nLin+35,1225,aObs[n1],oFont12n,,,,0)
			nLin += 40
		EndIF
	Next n1

	nLin += 300
	oPrint:Say(nLin,50,"Colocamo-nos á disposição para quaisquer esclarecimentos.",oFont10n)
	nLin +=50
	oPrint:Say(nLin,50,"Atenciosamente,",oFont10n)


Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} Improdapé
Função para imprimir rodapé da página

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015
/*/
//-------------------------------------------------------------------------------
Static Function ImpRodape(cChama)
	Local cNome1 	:= GetMv("TCP_NOMEV1")
	Local cCargo1 	:= GetMv("TCP_CARGV1")
	Local cFone1 	:= GetMv("TCP_FONEV1")
	Local cNome2 	:= GetMv("TCP_NOMEV2")
	Local cCargo2 	:= GetMv("TCP_CARGV2")
	Local cFone2 	:= GetMv("TCP_FONEV2")


	nLin := 2650
	oPrint:Say(nLin,0050,Alltrim(cNome1),oFont12n)
	oPrint:Say(nLin,1425,Alltrim(cNome2),oFont12n)
	nLin += 50
	oPrint:Say(nLin,0050,Alltrim(cCargo1),oFont10n)
	oPrint:Say(nLin,1425,Alltrim(cCargo2),oFont10n)
	nLin += 50
	oPrint:Say(nLin,0050,Alltrim(cFone1),oFont10n)
	oPrint:Say(nLin,1425,Alltrim(cFone2),oFont10n)

	nLin += 90
	oPrint:SayBitmap( nLin, 1200, "\sigaadv\tcp_rodape2.bmp", 1150, 200)
	oPrint:SayBitmap( nLin, 100, "\sigaadv\ass_carta.bmp", 430, 190)

	//	oPrint:SayBitmap( nLin, 010, "\sigaadv\lgrl01.bmp", 2340, 200)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GERADADOS
Busca informações para geração de e-mail

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GERADADOS(cCod,cLoja)
	Local cQuery  := ''
	Local aItem    := {}

	cQuery := "SELECT DISTINCT "
	cQuery += "	Z04.* "
	cQuery += "FROM "
	cQuery +=  retSqlName('Z04') + " Z04, "
	cQuery +=  retSqlName('Z03') + " Z03 "
	cQuery += "WHERE"
	cQuery += "     Z03.Z03_FILIAL  = '"+xFilial('Z03')+"' AND Z03.D_E_L_E_T_ <> '*' "
	cQuery += " AND Z03.Z03_INICIO  <= '"+Posicione('SA2',1,xFilial('SA2')+cCod+cLoja,"A2_FECHAVA")+"28' AND (Z03_FIM = ' ' OR Z03_FIM >= '"+Posicione('SA2',1,xFilial('SA2')+cCod+cLoja,"A2_FECHAVA")+"28' ) "
	cQuery += " AND Z04.Z04_FILIAL  = '"+xFilial('Z04')+"' AND Z03.Z03_CODIGO = Z04_REGRA AND Z04.D_E_L_E_T_ <> '*' "
	cQuery += "ORDER BY Z04_CRITER "


	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRY", .F., .T.)
	dbSelectArea("QRY")
	QRY->(dbGotop())

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} PROCURAFOR
Busca informações para geração de e-mail

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015

/*/                      

//-------------------------------------------------------------------------------
Static Function PROCURAFOR()
	Local cQuery  	:= ''

	cQuery += " SELECT  SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_NOTAFOR, SA2.A2_NOTAANT,SA2.A2_FECHAVA "
	cQuery += " FROM "
	cQuery +=  retSqlName('SA2') + " SA2 "
	cQuery += " WHERE"
	cQuery += "     SA2.A2_FILIAL  = '"+xFilial('SA2')+"'  AND SA2.A2_NOTAFOR  != ' ' AND  SA2.D_E_L_E_T_ <> '*' AND SA2.A2_COD  >= '"+MV_PAR01+"' "
	cQuery += " AND SA2.A2_COD  <= '"+MV_PAR03+"' AND SA2.A2_LOJA  >= '"+MV_PAR02+"'  AND SA2.A2_LOJA  <= '"+MV_PAR04+"'   "
	If !Empty(Alltrim(MV_PAR05))
		cQuery += " AND SA2.A2_FECHAVA  = '"+MV_PAR05+MV_PAR06+"'  "
	EndIF
	cQuery += " ORDER BY SA2.A2_COD, SA2.A2_LOJA  "

	If SELECT("QRYFOR") <> 0
		dbSelectArea("QRYFOR")
		QRYFOR->(DbCloseArea())
	EndIf


	cQuery := ChangeQuery(cQuery)
	Memowrit('c:\TEMP\sql.txt',cQuery)


	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRYFOR", .F., .T.)
	dbSelectArea("QRYFOR")
	QRYFOR->(dbGotop())

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} QLinha
Função para quebra de linha devido a problemas com a função padrão

@return 
@author Felipe Toazza Caldeira
@since 09/09/2015
/*/
//-------------------------------------------------------------------------------
Static Function QLinha(cString,nTam)

	local nI3     := 0   // Contador dos caracteres
	local nJ      := 0   // Contador dos caracteres
	local nL      := 0   // Contador das linhas
	local cLinha  := ""  // Guarda a linha editada no campo memo
	local aLinhas := {}  // Array com o memo dividido em linhas


	for nI3 := 1 to len(cString)
		if (MsAscii(substr(cString,nI3,1)) != 13 /*.Or. MsAscii(substr(cString,nI3,1)) != 10*/) .and. (nL < nTam)
			cLinha+=substr(cString,nI3,1)
			nL++
		else
			if MsAscii(substr(cString,nI3,1)) != 13 /*.Or. MsAscii(substr(cString,nI3,1)) != 10*/
				nI3--
				for nJ := len(cLinha) to 1 step -1
					if substr(cLinha,nJ,1) <> " "
						nI3--
						nL--
					else
						exit
					endif
				next nJ
				if nL <=0
					nL := len(cLinha)
				endif
			endif

			if nL >= 0
				cLinha := substr(cLinha,1,nL)
				AAdd(aLinhas, cLinha)
				cLinha := ""
				nL := 0
			endif
		endif
	next nI3

	if nL >= 0
		cLinha := substr(cLinha,1,nL)
		AAdd(aLinhas, cLinha)
		cLinha := ""
		nL := 0
	endif

return(aLinhas)

Static Function corpo()
	Local cCorpo := ''
	cCorpo += '<html> '
	cCorpo += '	<body> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Empresa '+SA2->A2_NOME+'</span></span> '
	cCorpo += '			<BR><BR> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">É com satisfação que a TCP envia sua avaliação mensal no intuito de demonstrar o andamento de seu(s) atendimento(s), desta forma qualificá-lo para futuros atendimento junto a TCP.</span></span> '
	cCorpo += '			<BR> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Quaisquer dúvidas, favor entrar em contato com nosso setor de compras através do e-mail: compras@tcp.com.br</span></span> '
	cCorpo += '			<BR> '
	cCorpo += '			<BR> '
	cCorpo += '				<span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;">TCP</span></span> '

	cCorpo += '	</body>'
	cCorpo += '</html>

Return cCorpo



/*----------------------------------------------	totvs.felipe-----------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+------------------+---------------------------------------------------------+
|Descricao         | Cria Grupo de perguntas para o relatorio                |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jose Correa Chagas                                |
+------------------+----------------------------+-----------------+----------+
| Atualizacoes                                  | Analista        | Data     |
+-----------------------------------------------+-----------------+----------+
|                                               |                 |          |
+-----------------------------------------------+-----------------+---------*/
Static Function CriaPerg(cPerg)

//PutSX1(cPerg, "01", "Fornecedor de" , "Fornecedor de" , "Fornecedor de" , "mv_ch1", "C", TamSx3('A2_COD' )[1], TamSx3('A2_COD' )[2], 1, "G", "", "SA2", "", "", "MV_PAR01", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe o Fornecedor inicial."}, {"Informe o Fornecedor inicial."}, {"Informe o Fornecedor inicial."})
//PutSX1(cPerg, "02", "Loja de"       , "Loja de"       , "Loja de"       , "mv_ch2", "C", TamSx3('A2_LOJA')[1], TamSx3('A2_LOJA')[2], 1, "G", "", ""   , "", "", "MV_PAR02", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."})
//PutSX1(cPerg, "03", "Fornecedor até", "Fornecedor até", "Fornecedor até", "mv_ch3", "C", TamSx3('A2_COD' )[1], TamSx3('A2_COD' )[2], 0, "G", "", "SA2", "", "", "MV_PAR03", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe o Fornecedor final."  }, {"Informe o Fornecedor final."  }, {"Informe o Fornecedor final."  })
//PutSX1(cPerg, "04", "Loja Até"      , "Loja Ate"      , "Loja até"      , "mv_ch4", "C", TamSx3('A2_LOJA')[1], TamSx3('A2_LOJA')[2], 1, "G", "", ""   , "", "", "MV_PAR04", ""           , ""           , ""           , ""               , ""               , ""               , ""     , ""     , ""     , "", "", "", "", "", "", "", {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."}, {"Informe a Loja do Fornecedor."})
//PutSX1(cPerg, "05", "Ano"    	    , "Ano"        	  , "Ano"           , "mv_ch5", "C", 4                   , 0                   , 1, "C", "", ""   , "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   })
//PutSX1(cPerg, "06", "Mes"       	, "Mes"           , "Mes"           , "mv_ch6", "C", 2                   , 0                   , 1, "C", "", ""   , "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   }, {"Informe o ano para calculo"   })

Return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} fSalvArq
Função para gerar um arquivo texto 

@return 
@author Jair Andrade	
@since 28/10/2020

/*/
//-------------------------------------------------------------------------------

Static Function fSalvArq()
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".TXT"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	Local nX := 0

	//Pegando o caminho do arquivo
	cFileNom:= cGetFile( '*.txt|*.txt' , 'Selecione a pasta para gerar o arquivo', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
		cArqCPag := cFileNom+"Erro_SA2.txt"
		//Montando a mensagem
		cTexto := "Função:"+ FunName()
		cTexto += " Usuário:"+ cUserName
		cTexto += " Data:"+ dToC(dDataBase)
		cTexto += " Hora:"+ Time() + cQuebra  + "Log de Erros" + cQuebra
		For nX := 1 To Len(aErros)
			cTexto +=aErros[nX]+ CRLF
		Next nX

		//Testando se o arquivo já existe
		If File(cArqCPag)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cArqCPag, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cArqCPag,"Atenção")
		EndIf
	EndIf
Return
