/**********************************************************************************************************************************/
/** SIGAFAT - Faturamento                                                                                                        **/
/** Etiquetas de volumes                                                                                                         **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 07/08/2013 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function KFATA01()                                                                                                      **/
/** Chamada para impressão das etiquetas                                                                                         **/
/**********************************************************************************************************************************/
user function KFATA01()

	// variaveis auxiliares
	local nPosX := 0
	local nPosY := 0
	local lContinua := .T.
	local cVolume := ""
	local nForMax := 0
	local nI := 0
	private cPerg := "KFATA01"
	private oImgOk := LoadBitmap(GetResources(), "LBOK")
	private oImgNo := LoadBitmap(GetResources(), "LBNO")
	private oDlgVols := Nil
	private oGrpVols := Nil
	private oLbxVols := Nil
	private aLbxVols := {}
	/*	aLbxVols[] : listbox de volumes
		aLbxVols[n][01] : flag de selecao
		aLbxVols[n][02] : numero da nota
		aLbxVols[n][03] : serie da nota
		aLbxVols[n][04] : numero do pedido
		aLbxVols[n][05] : razao social do cliente/fornecedor
		aLbxVols[n][06] : endereco
		aLbxVols[n][07] : bairro
		aLbxVols[n][08] : cep
		aLbxVols[n][09] : cidade
		aLbxVols[n][10] : estado
		aLbxVols[n][11] : numero do volume
		aLbxVols[n][12] : volumes totais
		aLbxVols[n][13] : chave acesso nfe
	*/

	// processa a criação das perguntas
	Processa({|| ProcSX1()})

	// recupera as notas fiscais do periodo
	lContinua := .T.
	while lContinua

		// pergunta os parametros
		if !Pergunte(cPerg, .T.)
			lContinua := .F.
			loop
		endIf 

		// recupera os dados da nota e valida se ha dados
		QrySF2()
		if QSF2->(Eof())
			QSF2->(DbCloseArea())
			lContinua := .F.
			MsgAlert("Não foram localizadas notas fiscais nos parâmetros informados!")
			loop
		endIf

		// preenche o array de volumes
		aLbxVols := {}
		while !QSF2->(Eof())

			// tratamento para volume zerado                           
			if QSF2->C5_VOLUME == 0
				nForMax := 1
				nVolume := 0
			else
				nForMax := QSF2->C5_VOLUME
				nVolume := 1
			endIf

			for nI := 1 to nForMax

				// adiciona os dados ao array 
				if QSF2->F2_TIPO $ "BD"
					AAdd(aLbxVols, {.T., QSF2->F2_DOC, QSF2->F2_SERIE, QSF2->D2_PEDIDO, AllTrim(QSF2->A2_NOME), AllTrim(QSF2->A2_END), AllTrim(QSF2->A2_BAIRRO), Transform(QSF2->A2_CEP, "@R 99.999-999"), AllTrim(QSF2->A2_MUN), QSF2->A2_EST, nVolume, QSF2->C5_VOLUME,QSF2->F2_CHVNFE})
				else
					AAdd(aLbxVols, {.T., QSF2->F2_DOC, QSF2->F2_SERIE, QSF2->D2_PEDIDO, AllTrim(QSF2->A1_NOME), AllTrim(QSF2->A1_END), AllTrim(QSF2->A1_BAIRRO), Transform(QSF2->A1_CEP, "@R 99.999-999"), AllTrim(QSF2->A1_MUN), QSF2->A1_EST, nVolume, QSF2->C5_VOLUME,QSF2->F2_CHVNFE})
				endIf

				// incrementa o volume
				nVolume++

			next nI

			// proximo registro
			QSF2->(DbSkip())

		endDo

		// fecha a query
		QSF2->(DbCloseArea())


		// monta a tela de seleção dos volumes por nota fiscal
		define MsDialog oDlgVols from 0, 0 to 527, 770 title "Etiquetas de Volume" pixel

		// define a divisão da tela
		nPosX := 0
		nPosY := 2
		oGrpVols := TGroup():New(nPosX, nPosY, nPosX + 245, nPosY + 380, "[ Selecione os volumes a imprimir ]", oDlgVols, Nil, Nil, .T.)

		// posiciona o listbox dos volumes a imprimir
		nPosX += 10
		nPosY += 5
		oLbxVols := TCBrowse():New(nPosX, nPosY, 370, 230, Nil, Nil, Nil, oGrpVols, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .F., Nil, .T., Nil,.F., Nil, Nil, Nil)
		oLbxVols:bLDblClick 	:= {|| LbxVolsMar()}
		oLbxVols:bHeaderClick 	:= {|| LbxVolsAll()}
		oLbxVols:AddColumn(TCColumn():New("X"			, {|| Iif(aLbxVols[oLbxVols:nAt, 1], oImgOk, oImgNo)}, Nil, Nil, Nil, Nil, 8, .T., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Volume"		, {|| StrZero(aLbxVols[oLbxVols:nAt, 11], 4) + "/" + StrZero(aLbxVols[oLbxVols:nAt, 12], 4)}, "", Nil, Nil, Nil, 30, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Documento"	, {|| aLbxVols[oLbxVols:nAt, 2	]}, "", Nil, Nil, Nil, 035, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Série"		, {|| aLbxVols[oLbxVols:nAt, 3	]}, "", Nil, Nil, Nil, 020, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Pedido"		, {|| aLbxVols[oLbxVols:nAt, 4	]}, "", Nil, Nil, Nil, 030, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Razão Social", {|| aLbxVols[oLbxVols:nAt, 5	]}, "", Nil, Nil, Nil, 150, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Endereco"	, {|| aLbxVols[oLbxVols:nAt, 6	]}, "", Nil, Nil, Nil, 100, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Bairro"		, {|| aLbxVols[oLbxVols:nAt, 7	]}, "", Nil, Nil, Nil, 100, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("CEP"			, {|| aLbxVols[oLbxVols:nAt, 8	]}, "", Nil, Nil, Nil, 030, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("Município"	, {|| aLbxVols[oLbxVols:nAt, 9	]}, "", Nil, Nil, Nil, 050, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:AddColumn(TCColumn():New("UF"			, {|| aLbxVols[oLbxVols:nAt, 10	]}, "", Nil, Nil, Nil, 010, .F., .F., Nil, Nil, Nil, .F., Nil))
		oLbxVols:SetArray(aLbxVols)
		oLbxVols:Refresh()

		// posiciona os botoes de comando
		nPosX += 239
		nPosY := 301
		@ nPosX, nPosY Button "Imprimir" size 40, 12 action ImpEtiq() of oDlgVols pixel
		nPosY += 42
		@ nPosX, nPosY Button "Cancelar" size 40, 12 action oDlgVols:End() of oDlgVols pixel

		// ativa a tela
		activate MsDialog oDlgVols centered

	endDo

return Nil


/**********************************************************************************************************************************/
/** static function ImpEtiq()                                                                                                    **/
/** Executa a impressão das etiquetas                                                                                            **/
/**********************************************************************************************************************************/
static function ImpEtiq()

	// variaveis auxiliares
	local 	cDesc1 	:= "Este programa tem como objetivo fazer a emissão "
	local 	cDesc2 	:= "das etiquetas de volumes, especificos do "
	local 	cDesc3 	:= "cliente Kapazi."
	local 	nLi 	:= 80
	local 	aOrd 	:= {}
	local 	lCmp 	:= .F.
	local 	cEtiq 	:= ""
//	local nTotLin := 0
	local 	cLinha 	:= ""
	local 	nI 		:= 0
	local 	nLin 	:= 0
	local 	aLinhas := {}
	local 	cAux 	:= ""
	local 	nA 		:= 0
	local 	nLine 	:= 0
	Local	lModNfe	:= StaticCall(M521CART,TGetMv,"  ","KA_ETVONFC","L",.f.,"KAFATA01 - Utilizar o modelo de etiqueta zebra com CHV da NF-e?")
	private cTit 	:= "Emissão de Etiquetas de Volumes"
	private cProg 	:= "KFATA01"
	private cTam 	:= "M"
	private nTipo 	:= 18
	private cRel 	:= ""
	private nLin 	:= 999
	private cPerg 	:= cProg
	private limite 	:= 132
	private aReturn := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 0 }
	private m_pag 	:= 1

	// chama a tela de seleção de impressão
	cRel := SetPrint(nil, cProg, Nil, @cTit, cDesc1, cDesc2, cDesc3, .F., nil, .T., cTam, nil, nil)

	// verifica se o usuário cancelou
	if (nLastKey == 27)
		return nil
	endIf

	// chama a impressao 
	setDefault(aReturn, nil)

	// verifica se o usuário cancelou
	if (nLastKey == 27)
		return nil
	endIf

	// se usa o modelo com a chave da nfe e o arquivo existe na pasta
	If lModNfe .and. File("\etiquetas\pedido_volumes_chvnfe.prn")
		// carrega o arquivo de etiqueta
		cEtiq 	:= MemoRead("\etiquetas\pedido_volumes_chvnfe.prn")
	// utiliza modelo antigo
	Else
		// carrega o arquivo de etiqueta
		cEtiq 	:= MemoRead("\etiquetas\pedido_volumes.prn")
	Endif
	//nTotLin := MlCount(cEtiq, 60, 3, .T.) 
	nLine 	:= 1

	// processa as etiquetas
	for nI := 1 to Len(aLbxVols)

		// verifica se está marcada a etiqueta
		if aLbxVols[nI][1]

			cLinha := cEtiq
			cLinha := StrTran(cLinha, "%TEL%"			, AllTrim(SM0->M0_TEL)												)
			cLinha := StrTran(cLinha, "%NF%"			, aLbxVols[nI][2] + "/" + aLbxVols[nI][3]							)
			cLinha := StrTran(cLinha, "%PEDIDO%"		, aLbxVols[nI][4]													)
			cLinha := StrTran(cLinha, "%VOL%"			, StrZero(aLbxVols[nI][11], 4) + " / " + StrZero(aLbxVols[nI][12],4))
			cLinha := StrTran(cLinha, "%RAZAO_SOCIAL%"	, aLbxVols[nI][5]													)
			cLinha := StrTran(cLinha, "%ENDERECO%"		, aLbxVols[nI][6]													)
			cLinha := StrTran(cLinha, "%BAIRRO%"		, aLbxVols[nI][7]													)
			cLinha := StrTran(cLinha, "%CEP%"			, aLbxVols[nI][8] + " - " + aLbxVols[nI][9] + "/" + aLbxVols[nI][10])
			cLinha := StrTran(cLinha, "%CODBAR%"		, aLbxVols[nI][4] + StrZero(aLbxVols[nI][11], 3)					)
			
			If at("%CHVNFE%",cEtiq) > 0
				cLinha := StrTran(cLinha, "%CHVNFE%"	, aLbxVols[nI][13])
			Endif

			// imprime a linha
			@ nLine, 001 pSay cLinha
			nLine++

		endIf

	next nI

	// ajusta o dispositivo para a tela
	Set Device To Screen

	// se selecionou em disco, chama o visualizador de impressao
	if (aReturn[5] == 1)
		set printer to
		OurSpool(cRel)
	endIf

	// finaliza a impressão
	Ms_Flush()
	PrnFlush()

return Nil


/**********************************************************************************************************************************/
/** static function LbxVolsAll()                                                                                                 **/
/** Rotina para marcar/desmarcar todos os itens                                                                                  **/
/**********************************************************************************************************************************/
static function LbxVolsAll()

	// variaveis auxiliares
	local lFlag := .F.
	local nI := 0      


	// verifica se ha itens a marcar
	if Len(aLbxVols) == 0
		return Nil
	endIf

	// verifica se o primeiro item esta marcado
	lFlag := !aLbxVols[1][1]

	// atualiza o flag de todos os itens
	for nI := 1 to Len(aLbxVols)
		aLbxVols[nI][1] := lFlag
	next nI

	// atualiza o listbox
	oLbxVols:SetArray(aLbxVols)
	oLbxVols:Refresh()

return Nil


/**********************************************************************************************************************************/
/** static function LbxVolsMar()                                                                                                 **/
/** Rotina para marcar/desmarcar o item                                                                                          **/
/**********************************************************************************************************************************/
static function LbxVolsMar()

	// verifica se ha itens a marcar
	if Len(aLbxVols) == 0
		return Nil
	endIf

	// verifica se o item esta marcado
	aLbxVols[oLbxVols:nAt][1] := !aLbxVols[oLbxVols:nAt][1]

	// atualiza o listbox
	oLbxVols:SetArray(aLbxVols)
	oLbxVols:Refresh()

return Nil


/**********************************************************************************************************************************/
/** static function QrySf2()                                                                                                     **/
/** Recupera os dados das notas conforme os parâmetros informados                                                                **/
/**********************************************************************************************************************************/
static function QrySf2()

	// variaveis auxiliares
	local cQr := ""
	local aArea := GetArea()


	// monta a query
	cQr := " select SF2.F2_TIPO,
	cQr += "        SF2.F2_DOC,
	cQr += "        SF2.F2_SERIE,
	cQr += "        SF2.F2_CHVNFE,
	cQr += " 			  SA1.A1_NOME,
	cQr += " 			  SA1.A1_END,
	cQr += " 			  SA1.A1_BAIRRO,
	cQr += " 			  SA1.A1_CEP,
	cQr += " 			  SA1.A1_MUN,
	cQr += " 			  SA1.A1_EST,
	cQr += " 			  SA2.A2_NOME,
	cQr += " 			  SA2.A2_END,
	cQr += " 			  SA2.A2_BAIRRO,
	cQr += " 			  SA2.A2_CEP,
	cQr += " 			  SA2.A2_MUN,
	cQr += " 			  SA2.A2_EST,
	cQr += " 			  SD2.D2_PEDIDO,
	cQr += " 			  SC5.C5_VOLUME1 + SC5.C5_VOLUME2 + SC5.C5_VOLUME3 + SC5.C5_VOLUME4 C5_VOLUME

	cQr += "   from " + RetSqlName("SF2") + " SF2

	cQr += " 	 left join " + RetSqlName("SD2") + " SD2
	cQr += " 	   on SD2.D_E_L_E_T_ = ' '
	cQr += "    and SD2.D2_FILIAL = '" + XFilial("SD2") + "'
	cQr += " 	  and SD2.D2_DOC = SF2.F2_DOC
	cQr += " 	  and SD2.D2_SERIE = SF2.F2_SERIE
	cQr += " 	  and SD2.D2_CLIENTE = SF2.F2_CLIENTE
	cQr += " 	  and SD2.D2_LOJA = SF2.F2_LOJA
	cQr += " 	  and SD2.D2_TIPO = SF2.F2_TIPO

	cQr += "   left join " + RetSqlName("SC5") + " SC5
	cQr += " 	   on SC5.D_E_L_E_T_ = ' '
	cQr += "    and SC5.C5_FILIAL = '" + XFilial("SC5") + "'
	cQr += " 	  and SC5.C5_NUM = SD2.D2_PEDIDO

	cQr += " 	 left join " + RetSqlName("SA1") + " SA1
	cQr += " 	   on SA1.D_E_L_E_T_ = ' '
	cQr += "    and SA1.A1_FILIAL = '" + XFilial("SA1") + "'
	cQr += " 	  and SA1.A1_COD = SF2.F2_CLIENTE
	cQr += " 	  and SA1.A1_LOJA = SF2.F2_LOJA

	cQr += " 	 left join " + RetSqlName("SA2") + " SA2
	cQr += " 	   on SA2.D_E_L_E_T_ = ' '
	cQr += "  	and SA2.A2_FILIAL = '" + XFilial("SA2") + "'
	cQr += " 	  and SA2.A2_COD = SF2.F2_CLIENTE
	cQr += " 	  and SA2.A2_LOJA = SF2.F2_LOJA

	cQr += "  where SF2.D_E_L_E_T_ = ' '
	cQr += "    and SF2.F2_FILIAL = '" + XFilial("SF2") + "'
	cQr += " 	  and SF2.F2_DOC between '" + mv_par01 + "' and '" + mv_par02 + "'
	cQr += " 	  and SF2.F2_SERIE between '" + mv_par03 + "' and '" + mv_par04 + "'
	cQr += " 	  and SF2.F2_EMISSAO between '" + Dtos(mv_par05) + "' and '" + Dtos(mv_par06) + "'

	// valida se o campo existe
	IF SF2->( FieldPos("F2_K_USRCO") ) > 0
		if substr(Alltrim(cValToChar(mv_par07)),1,1) == "1"
			cQr += " 	  and SF2.F2_K_USRCO = '" + RetCodUsr() + "'  "
		EndIf
	EndIf

	cQr += "  group by SF2.F2_TIPO,
	cQr += "        SF2.F2_DOC,
	cQr += "        SF2.F2_SERIE,
	cQr += "        SF2.F2_CHVNFE,
	cQr += " 		    SA1.A1_NOME,
	cQr += " 		    SA1.A1_END,
	cQr += " 		    SA1.A1_BAIRRO,
	cQr += " 		    SA1.A1_CEP,
	cQr += " 			  SA1.A1_MUN,
	cQr += " 			  SA1.A1_EST,
	cQr += " 			  SA2.A2_NOME,
	cQr += " 			  SA2.A2_END,
	cQr += " 			  SA2.A2_BAIRRO,
	cQr += " 			  SA2.A2_CEP,
	cQr += " 			  SA2.A2_MUN,
	cQr += " 			  SA2.A2_EST,
	cQr += " 			  SD2.D2_PEDIDO,
	cQr += " 			  SC5.C5_VOLUME1 + SC5.C5_VOLUME2 + SC5.C5_VOLUME3 + SC5.C5_VOLUME4

	cQr += "  order by SF2.F2_DOC,
	cQr += "        SF2.F2_SERIE

	// abre a query
	TcQuery cQr new alias "QSF2"
	RestArea(aArea)


return Nil


/**********************************************************************************************************************************/
/** static function ProcSx1()                                                                                                    **/
/** processa a criação das perguntas no SX1                                                                                      **/
/**********************************************************************************************************************************/
static function ProcSx1()

	// variáveis auxiliares
	local cIndice := "00"
	local cVarCh := "mv_ch0"
	local cVarPar := "mv_par00"
	local cIdx0 := "0"
	local aParPerg := {}
	/* aParPerg[]
	aParPerg[n][01] : nome da pergunta
	aParPerg[n][02] : descrição
	aParPerg[n][03] : tipo
	aParPerg[n][04] : tamanho
	aParPerg[n][05] : decimais
	aParPerg[n][06] : indice de pre selecao de combo
	aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )
	aParPerg[n][08] : rotina de validação do SX1
	aParPerg[n][09] : F3
	aParPerg[n][10] : grupo de perguntas
	aParPerg[n][11] : item 1 do combo
	aParPerg[n][11] : item 2 do combo
	aParPerg[n][11] : item 3 do combo
	aParPerg[n][11] : item 4 do combo
	aParPerg[n][11] : item 5 do combo
	aParPerg[n][12] : array de help */

	// cria as perguntas do array
	AAdd(aParPerg, {cPerg, "Da Nota Fiscal?", "C", TamSx3("F2_DOC")[1], TamSx3("F2_DOC")[2], 0, "G", "", "SF2", "", "", "", "", Nil, Nil, {"Informe a nota fiscal inicial"}})
	AAdd(aParPerg, {cPerg, "Ate Nota Fiscal?", "C", TamSx3("F2_DOC")[1], TamSx3("F2_DOC")[2], 0, "G", "", "SF2", "", "", "", "", Nil, Nil, {"Informe a nota fiscal final"}})
	AAdd(aParPerg, {cPerg, "Da Serie?", "C", TamSx3("F2_SERIE")[1], TamSx3("F2_SERIE")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe a serie inicial"}})
	AAdd(aParPerg, {cPerg, "Ate Serie?", "C", TamSx3("F2_SERIE")[1], TamSx3("F2_SERIE")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe a serie final"}})
	AAdd(aParPerg, {cPerg, "Da Emissao?", "D", TamSx3("F2_EMISSAO")[1], TamSx3("F2_EMISSAO")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe a data de emissao inicial"}})
	AAdd(aParPerg, {cPerg, "Ate Emissao?", "D", TamSx3("F2_EMISSAO")[1], TamSx3("F2_EMISSAO")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe a data de emissao final"}})
	AAdd(aParPerg, {cPerg, "Filtra suas notas?", "N", 1, 0, 1, "C", "", "", "", "Sim", "Não", "", Nil, Nil, {"Filtra as notas emitidas pelo seu usuário?"}})

	// inicializa as variaveis
	cIndice := "00"
	cIdx0 := "0"
	cVarCh := "mv_ch0"
	cVarPar := "mv_par00"

	// inicializa a barra de progressos
	ProcRegua(Len(aParPerg))

	// loop sobre os parametros a adicionar
	for nI := 1 to Len(aParPerg)

		// incrementa os contadores
		cIndice := soma1(cIndice)
		cIdx0 := soma1(cIdx0)
		cVarCh := "mv_ch" + cIdx0
		cVarPar := "mv_par" + cIndice

		// incrementa a barra de progressos
		IncProc("Criando perguntas " + allTrim(cIndice) + "/" + StrZero(Len(aParPerg), 2) + "..." )

		// adiciona o parametro
		xPutSx1( aParPerg[nI][01] ,; // nome da pergunta
		cIndice          ,; // indice
		aParPerg[nI][02] ,; // descricao portugues
		aParPerg[nI][02] ,; // descricao espanhol
		aParPerg[nI][02] ,; // descricao ingles
		cVarCh           ,; // variavel mv_ch
		aParPerg[nI][03] ,; // tipo
		aParPerg[nI][04] ,; // tamanho
		aParPerg[nI][05] ,; // decimais
		aParPerg[nI][06] ,; // indice de pre-seleção (combo)
		aParPerg[nI][07] ,; // tipo do objeto
		aParPerg[nI][08] ,; // validação
		aParPerg[nI][09] ,; // F3
		aParPerg[nI][10] ,; // grupo de perguntas
		" "              ,; // parametro pyme
		cVarPar          ,; // variavel mv_par
		aParPerg[nI][11] ,; // item 1 do combo (portugues)
		aParPerg[nI][11] ,; // item 1 do combo (espanhol)
		aParPerg[nI][11] ,; // item 1 do combo (ingles)
		""               ,; // conteudo padrao da pergunta
		aParPerg[nI][12] ,; // item 2 do combo (portugues)
		aParPerg[nI][12] ,; // item 2 do combo (espanhol)
		aParPerg[nI][12] ,; // item 2 do combo (ingles)
		aParPerg[nI][13] ,; // item 3 do combo (portugues)
		aParPerg[nI][13] ,; // item 3 do combo (espanhol)
		aParPerg[nI][13] ,; // item 3 do combo (ingles)
		aParPerg[nI][14] ,; // item 4 do combo (portugues)
		aParPerg[nI][14] ,; // item 4 do combo (espanhol)
		aParPerg[nI][14] ,; // item 4 do combo (ingles)
		aParPerg[nI][15] ,; // item 5 do combo (portugues)
		aParPerg[nI][15] ,; // item 5 do combo (espanhol)
		aParPerg[nI][15] ,; // item 5 do combo (ingles)
		aParPerg[nI][16] ,; // memo de help (portugues)
		aParPerg[nI][16] ,; // memo de help (espanhol)
		aParPerg[nI][16] ,; // memo de help (ingles)
		"" /* help*/ )

	next nI

return nil


Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f.

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme   == Nil, " ", cPyme  )
	cF3      := Iif( cF3   == NIl, " ", cF3  )
	cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg )
	cCnt01   := Iif( cCnt01  == Nil, "" , cCnt01  )
	cHelp  := Iif( cHelp  == Nil, "" , cHelp  )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return
