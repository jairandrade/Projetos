#include 'protheus.ch'

#define BIT0 8
#define BIT1 7
#define BIT2 6
#define BIT3 5
#define BIT4 4
#define BIT5 3
#define BIT6 2
#define BIT7 1

static nPorta


/*/{Protheus.doc} ToledoGet
função para pegar o peso da Balança Toledo

@author Rafael Ricardo Vieceli
@since 16/06/2018
@version 1.0
@return array, retorno de peso

@type function
/*/
user function ToledoGet()

	Local oModal, oPanel, oTimer, oPeso, oAlert
	Local nPeso := 0

	Local lConfirma := .F.

	IF nPorta == Nil
		IF ! getPorta()
			return {.F.,0}
		EndIF
	EndIF

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.F.)
	oModal:setTitle("Balança Toledo - P03")
	oModal:setSize(120, 270)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

	oPanel := oModal:getPanelMain()

	TSay():New(17,10,{|| "Peso"},oPanel,,TFont():New(,,-45),,,,.T.,,,70,30,,,,,,.T.)
	oPeso := TGet():New(10, 80, bSetGet(nPeso) , oPanel ,  160, 30, "@E 99,999,999.99999", {|| .T. },,,TFont():New('Arial',,-35),.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nPeso')
	oAlert := TSay():New(50,10,{|| "" },oPanel,,TFont():New(,,-26),,,,.T.,,,200,30,,,,,,.T.)

	oModal:addButtons({{"", "Confirmar"  , {|| lConfirma := .T. , oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Cancelar"  , {|| lConfirma := .F. , oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	//chama por segundo
	oModal:setTimer(1, {|| ToledoConn(@nPeso, oAlert), oPeso:CtrlRefresh() })

	oModal:activate()

	IF lConfirma
		return {.T., nPeso}
	EndIF

return {.F.,0}



/*/{Protheus.doc} ToledoConn
Conexão com a balança, chamada a cada segundo

@author Rafael Ricardo Vieceli
@since 16/06/2018
@version 1.0
@return ${return}, ${return_description}
@param nPeso, numeric, descricao
@param oAlert, object, descricao
@type function
/*/
static function ToledoConn(nPeso, oAlert)

	//cPort:cBaudRate, cParity, cData, cStop
	Local cPorta      := "COM"+cValtoChar(nPorta)+":4800,e,7,1"
	Local nHnd        := 0
	Local cBuffer     := ""
	Local nTentativas := 0

	Local cWarning := ''

	//Conexao com a impressora
	Local lResult := MSOpenPort(@nHnd,cPorta)

	default nPeso := 0

	//Não conectou
	IF ! lResult
		oAlert:setText('<span style="color:RED">Conexão falhou na porta COM'+cValToChar(nPorta)+'</span>')
		oAlert:CtrlRefresh()
		return .F.
	EndIF

	While nTentativas <= 20

		//Leitura do peso
		MsRead(nHnd,@cBuffer)

		IF getPeso(cBuffer, @nPeso, @cWarning)

			oAlert:setText(cWarning)
			oAlert:CtrlRefresh()

			exit
		EndIF

		//Tentativas
		nTentativas++

		sleep(500)
	EndDO

	MsClearBuffer(nHnd)
	MsClosePort(nHnd)


return .T.


/*/{Protheus.doc} getPeso
Tratamento da string recebida pela balança

@author Rafael Ricardo Vieceli
@since 16/06/2018
@version 1.0
@return logical, se conseguiu ler
@param cBuffer, characters, string recebida pela balança
@param nPeso, numeric, @peso
@param cWarning, characters, @aviso
@type function
/*/
static function getPeso(cBuffer, nPeso, cWarning)

	/*
	STX SWA SWB SWC IIIIII TTTTTT CR (CS)
	ABREVIATURAS:
	STX ---> Start of Text = 02
	CR --->Carriage Return = 0DH
	CS ---> Byte deChecksum (se C12 = L)
	I ---> Peso indicado no Display (Líquido ou Bruto)
	T ---> Tara
	SWA --> STATUS WORD “A”:
	BIT2, 1 e 0 ----> 001 = DISPLAY x 10
	010 = DISPLAY x 1
	011 = DISPLAY x 0.1
	100 = DISPLAY x 0.01
	101 = DISPLAY x 0.001
	110 = DISPLAY x 0.0001
	BIT 4 e 3 -------> 01 = TAMANHO DO INCREMENTO I 1
	10 = TAMANHO DO INCREMENTO I 2
	11 = TAMANHO DO INCREMENTO I 5
	BIT 6 e 5 -------> 01 = SEMPRE
	BIT 7 -----------> = PARIDADE

	SWB --> STATUS WORD “B”:
	BIT 0 -----------> PESO LÍQUIDO = 1
	BIT 1 -----------> PESO NEGATIVO = 1
	BIT 2 -----------> SOBRECARGA = 1
	BIT 3 -----------> MOTION = 1
	BIT 4 -----------> SEMPRE = 1
	BIT 5 -----------> SEMPRE = 1
	BIT 6 -----------> SE AUTO ZERADO = 1
	BIT7 -----------> PARIDADE
	SWC --> STATUS WORD “C”:
	BIT 0 -----------> SEMPRE = 0
	BIT 1 -----------> SEMPRE = 0
	BIT 2 -----------> SEMPRE = 0
	BIT 3 -----------> TECLA IMPRIMIR = 1
	BIT 4 -----------> EXPANDIDO = 1
	BIT 5 -----------> SEMPRE = 1
	BIT 6 -----------> SEMPRE = 1
	BIT7 -----------> PARIDADE
	*/

	Local aSWA, nPrecisao, nIncremento, lZwaParidade
	Local aSWB, lPesoLiquido, lPesoNegativo, lSobrecarga, lMotion, lAutoZerado, lZwbParidade
	Local aSWC, lTeclaImprimir, lExpandido, lZwcParidade

	Local cPeso
	Local cTara

//cBuffer := strTran(cBuffer,"B41","´1")
	ConOut("String")
	ConOut(" " + cBuffer)

	//STX
	IF substr(cBuffer,1,1) != chr(02) .And. substr(cBuffer,17,1) != Chr(17)
		return .F.
	EndIF

	aSWA := toBit(substr(cBuffer,2,1))
	aSWB := toBit(substr(cBuffer,3,1))
	aSWC := toBit(substr(cBuffer,4,1))

	SWA(aSWA, @nPrecisao, @nIncremento, @lZwaParidade)
	SWB(aSWB, @lPesoLiquido, @lPesoNegativo, @lSobrecarga, @lMotion, @lAutoZerado, @lZwbParidade)
	SWC(aSWC, @lTeclaImprimir, @lExpandido, @lZwcParidade)

	cPeso := substr(cBuffer,5,6)
	cTara := substr(cBuffer,11,6)

	ConOut("ZWA")
	ConOut(" Previsao " + cValToChar(nPrecisao))
	ConOut(" Incremento " + cValToChar(nIncremento))
	ConOut(" Paridade " + allToChar(lZwaParidade))
	ConOut("ZWB")
	ConOut(" Peso Liquido " + allToChar(lPesoLiquido))
	ConOut(" Peso Negativo " + allToChar(lPesoNegativo))
	ConOut(" Sobrecarga " + allToChar(lSobrecarga))
	ConOut(" Motion " + allToChar(lMotion))
	ConOut(" AUTO Zerado " + allToChar(lAutoZerado))
	ConOut(" Paridade " + allToChar(lZwbParidade))
	ConOut("ZWC")
	ConOut(" Tecla Imprimir " + allToChar(lTeclaImprimir))
	ConOut(" Expandido " + allToChar(lExpandido))
	ConOut(" Paridade " + allToChar(lZwcParidade))
	ConOut("Pesos")
	ConOut(" Peso " + cPeso)
	ConOut(" Tara " + cTara)
	ConOut("Peso Real")
	ConOut(" Peso " + cValToChar(val(cPeso) * nPrecisao) )
	ConOut(" Tara " + cValToChar(val(cTara) * nPrecisao) )

	nPeso := 0
	cWarning := ''

	IF lPesoNegativo
		cWarning := '<span style="color:RED">Peso Negativo</span>'
	ElseIF lSobrecarga
		cWarning := '<span style="color:RED">Sobrecarga</span>'
	Else
		nPeso := val(cPeso) * nPrecisao
	EndIF

return .T.


static function SWA(aSWA, nPrecisao, nIncremento, lParidade)

	//SWA --> STATUS WORD “A”:
	//BIT2, 1 e 0
	Local cPrevisao   := aSWA[BIT2] + aSWA[BIT1] + aSWA[BIT0]
	//BIT 4 e 3
	Local cIncremento := aSWA[BIT4] + aSWA[BIT3]
	//BIT 7
	Local cParidade   := aSWA[BIT7]

	//PRECISAO
	do case
		//001 = DISPLAY x 10
		case cPrevisao == "001"
			nPrecisao := 10
		//010 = DISPLAY x 1
		case cPrevisao == "010"
			nPrecisao := 1
		//011 = DISPLAY x 0.1
		case cPrevisao == "011"
			nPrecisao := 0.1
		//100 = DISPLAY x 0.01
		case cPrevisao == "100"
			nPrecisao := 0.01
		//101 = DISPLAY x 0.001
		case cPrevisao == "101"
			nPrecisao := 0.001
		//110 = DISPLAY x 0.0001
		case cPrevisao == "110"
			nPrecisao := 0.0001
		otherwise
			nPrecisao := 0
	endCase

	//INCREMENTO
	do case
		//01 = TAMANHO DO INCREMENTO I 1
		case cIncremento == "01"
			nIncremento := 1
		//10 = TAMANHO DO INCREMENTO I 2
		case cIncremento == "10"
			nIncremento := 2
		//11 = TAMANHO DO INCREMENTO I 5
		case cIncremento == "11"
			nIncremento := 5
		otherwise
			nIncremento := 0
	endcase

	//PARIDADE
	lParidade := (cParidade == "1")

return

static function SWB(aSWB, lPesoLiquido, lPesoNegativo, lSobrecarga, lMotion, lAutoZerado, lParidade)

	//Bit 0 = Peso Líquido = 1
	lPesoLiquido  := aSWB[BIT0] == "1"
	//Bit 1 = Peso Negativo = 1
	lPesoNegativo := aSWB[BIT1] == "1"
	//Bit 2 = Sobrecarga = 1
	lSobrecarga   := aSWB[BIT2] == "1"
	//Bit 3 = Motion = 1
	lMotion       := aSWB[BIT3] == "1"
	//Bit 6 = Se AUTO Zerado = 1
	lAutoZerado   := aSWB[BIT6] == "1"
	//Bit 7 = Paridade Par
	lParidade     := aSWB[BIT7] == "1"

return

static function SWC(aSWC, lTeclaImprimir, lExpandido, lParidade)

	lTeclaImprimir := aSWC[BIT3] == "1"
	lExpandido     := aSWC[BIT4] == "1"
	lParidade      := aSWC[BIT7] == "1"

return

static function toBit(cString)

	Local aReturn := {}
	Local nC

	//converte para BITs
	cString := NToC( Asc( cString ), 2, 8, "0" )

	For nC := 1 to len(cString)
		aAdd(aReturn,Substr(cString,nC,1))
	Next nC

Return aReturn


/*/{Protheus.doc} getPorta
Seleção da porta da impressora

@author Rafael Ricardo Vieceli
@since 16/06/2018
@version 1.0
@return logical, se confirmou

@type function
/*/
static function getPorta()

	Local oModal, oPanel
	Local lConfirma := .F.

	Local nPort
	Local aPorts := {"1=COM1","2=COM2","3=COM3","4=COM4"}

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.F.)
	oModal:setTitle("Balança Toledo - P03 - Seleção de Porta COM")
	oModal:setSize(85, 200)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

	TComboBox():New(10,10,bSetGet(nPort),aPorts,100,20,oModal:getPanelMain(),,,,,,.T.,,,,,,,,,'nPort',"Selecione a Porta",1)

	oModal:addButtons({{"", "Confirmar"  , {|| lConfirma := .T. , oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Cancelar"  , {|| lConfirma := .F. , oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	oModal:activate()

	IF lConfirma
		nPorta := nPort
	EndIF

return lConfirma