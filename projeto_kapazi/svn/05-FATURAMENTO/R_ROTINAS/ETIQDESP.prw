#include "protheus.ch"
User Function ETIQDESP()

Local oFont   := TFont():New("Arial", Nil, 16, Nil, .F., Nil, Nil, Nil, .F., .F.)
Local oPrn    := TMSPrinter():New("Etiquetas", .T.)
Local nY, nX, nVol
Local cPed    := Posicione("SD2", 3, xFilial("SD2") + D2_DOC + D2_SERIE, "D2_PEDIDO")
Local cCliEnt := Posicione("SC5", 1, xFilial("SC5") + C5_NUM, "(C5_CLIENT + C5_LOJAENT)")
//Local cEndEnt := Posicione("SA1", 1, xFilial("SA1") + , "A1_END")
Local cBaiEnt := SA1->A1_BAIRRO
Local cCidEnt := SA1->A1_MUN
Local cEstEnt := SA1->A1_EST
Local cCEPEnt := SA1->A1_CEP

Posicione("SF2", 1, xFilial("SF2") + F2_DOC + F2_SERIE, "F2_DOC")
Posicione("SA1", 1, xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA), "A1_COD")

oPrn:Setup()

For nVol := 1 To SF2->F2_VOLUME1
	oPrn:StartPage()
	
	nX := 0.6 //1.2
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, SM0->M0_NOMECOM, oFont)
	
	nX := 1.2 //1.8
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Nota Fiscal: " , oFont)
	
	nX := 1.8 //2.4
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Pedido: " , oFont)
	
	nX := 2.4 //3
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Volume: " + AllTrim(Str(nVol)) + "/" + AllTrim(Str(SF2->F2_VOLUME1)), oFont)
	
	nX := 3
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Transp.: " + AllTrim(SC5->C5_TRANSP) + If(Empty(SC5->C5_TRANSP), "", " - " + AllTrim(Posicione("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_NOME"))), oFont)
	
	nX := 4.6
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Cliente: " + AllTrim(SA1->A1_NOME), oFont)

	nX := 5.2
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "Endereço: " + AllTrim(cEndEnt), oFont)
	
	nX := 5.8
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "          " + AllTrim(cBaiEnt), oFont)
	
	nX := 6.4
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "          " + AllTrim(cCidEnt) + "-" + cEstEnt, oFont)
	
	nX := 7
	nY := 1
	oPrn:Cmtr2Pix(nX, nY)
	oPrn:Say(nX, nY, "          " + Transform(cCEPEnt, "@R 99999-999"), oFont)
	
	oPrn:EndPage()
Next
oPrn:Preview()
Return