#include "protheus.ch"
#include "rwmake.ch"
/*
Padrao Zebra
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05     ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume temporario                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05   // imagem de etiqueta de volume temporaria
Local cVolume := paramixb[1]
Local cPedido := paramixb[2]
Local cNota   := IF(len(paramixb)>=3,paramixb[3],nil)
Local cSerie  := IF(len(paramixb)>=4,paramixb[4],nil)
Local cID := CBGrvEti('05',{cVolume,cPedido,cNota,cSerie})
Local sConteudo  
//MSCBLOADGRF("SIGA.GRF")
MSCBBEGIN(1,6)
MSCBWRITE("^FO040,020^A0N,45,60^FDMADERO^FS")
MSCBWRITE("^FO440,020^A0N,45,60^FD"+CVOLUME+"^FS")
MSCBWRITE("^FO04,060")
MSCBWRITE("^GB650,0,5^FS")
MSCBWRITE("^FO320,100^A0N,25,30^FDCarga: "+ALLTRIM(SC9->C9_CARGA)+"  Rota: "+"^FS")
MSCBWRITE("^FO320,150^A0N,25,30^FDVeiculo: ^FS")
MSCBWRITE("^FO320,200^A0N,25,30^FDNF_e:"+ALLTRIM(CNOTA)+"/"+ALLTRIM(CSERIE)+"^FS")
MSCBWRITE("^FO320,250^A0N,25,30^FDDest.:"+ALLTRIM(SA1->A1_NREDUZ)+"^FS")
MSCBWRITE("^FO320,300^A0N,25,30^FDPedido de Venda:"+ALLTRIM(CPEDIDO)+"^FS")
MSCBWRITE("^FO040,070")
MSCBWRITE("^BQN,2,10")
MSCBWRITE("^FDMM,A"+SUBSTR(ALLTRIM(SB1->B1_CODBAR),1,15)+CB8->CB8_LOTECT+"^FS")
MSCBWRITE("^FO040,350")
MSCBWRITE("^GB650,0,5^FS")
MSCBWRITE("^FO040,360^A0N,25,20^FD"+ALLTRIM(SB1->B1_COD)+"-"+SUBSTR(ALLTRIM(SB1->B1_DESC),1,35)+" Lote:"+ALLTRIM(CB8->CB8_LOTECT)+" Val: "+DTOC(DDATABASE)+"^FS")
MSCBEND()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMG05OFI  ºAutor  ³Sandro Valex        º Data ³  19/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada referente a imagem de identificacao do     º±±
±±º          ³volume permanente."Oficial"                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Img05OFI // imagem de etiqueta de volume permanente (OFICIAL)
Local cId     := CBGrvEti('05',{CB6->CB6_VOLUME,CB6->CB6_PEDIDO})
Local nTotEti := paramixb[1]
Local nAtu    := paramixb[2]    
MSCBBEGIN(1,6)  
MSCBWRITE("^FO040,020^A0N,45,60^FDMADERO^FS")
MSCBWRITE("^FO0340,020^A0N,45,60^FDStrZero(nAtu,2)+"/"+StrZero(nTotEti,2)^FS")
MSCBWRITE("^FO04,060")
MSCBWRITE("^GB650,0,5^FS")
MSCBWRITE("^FO320,100^A0N,25,30^FDCarga: "+ALLTRIM(SC9->C9_CARGA)+"  Rota: "+"^FS")
MSCBWRITE("^FO320,150^A0N,25,30^FDVeiculo: ^FS")
MSCBWRITE("^FO320,200^A0N,25,30^FDNF_e:"+ALLTRIM(CB8->CB8_NOTA)+"/"+ALLTRIM(CB8->CB8_SERIE)+"^FS")
MSCBWRITE("^FO320,250^A0N,25,30^FDDest.:"+ALLTRIM(SA1->A1_NREDUZ)+"^FS")
MSCBWRITE("^FO320,300^A0N,25,30^FDPedido de Venda:"+ALLTRIM(CB8->CB8_PEDIDO)+"^FS")
MSCBWRITE("^FO040,070")
MSCBWRITE("^BQN,2,10")
MSCBWRITE("^FDMM,A"+SUBSTR(ALLTRIM(SB1->B1_CODBAR),1,15)+CB8->CB8_LOTECT+"^FS")
MSCBWRITE("^FO040,350")
MSCBWRITE("^GB650,0,5^FS")
MSCBWRITE("^FO040,360^A0N,25,20^FD"+ALLTRIM(SB1->B1_COD)+"-"+SUBSTR(ALLTRIM(SB1->B1_DESC),1,35)+" Lote:"+ALLTRIM(CB8->CB8_LOTECT)+" Val: "+DTOC(DDATABASE)+"^FS")
MSCBEND()

Return .f.             

