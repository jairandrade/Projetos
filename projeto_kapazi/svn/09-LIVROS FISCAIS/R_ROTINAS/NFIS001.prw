#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFIS001   บ Autor ณMauricio Micheli    บ Data ณ  27/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณINFORMA DATA PARA TRAVAR O MOVIMENTIO FISCAL                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FISCAL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function NFIS001()

Private oFis                                                    
Private cFimLin := (chr(13)+chr(10))
Private dDTFIS  := getmv("MV_DATAFIS")
Private oDTFIS
Private cMsg1   := "Aten็ใo, nใo serแ possํvel efetuar"
pRIVATE cMsg2   := "movimenta็๕es anteriores a data"
pRIVATE cMsg3   := "informada !"

DEFINE MSDIALOG oFis from 000,000 to 200,300 title "ฺltimos Fechamentos" pixel
@ 005,005 Say OemToAnsi("Data ?") PIXEL COLORS CLR_HBLUE OF oFis 
@ 005,060 MsGet oDTFIS VAR dDTFIS SIZE 40,08  PIXEL OF oFis Valid !empty(dDTFIS)
@ 005,115 BUTTON "Confirma" OF oFIS SIZE 030,015 PIXEL ACTION ConOK(.t.,dDTFIS)
@ 020,115 BUTTON "Cancela"  OF oFIS SIZE 030,015 PIXEL ACTION ConOk(.f.)

@ 050,005 Say OemToAnsi(cMsg1) PIXEL COLORS CLR_HRED OF oFis                                                  
@ 060,005 Say OemToAnsi(cMsg2) PIXEL COLORS CLR_HRED OF oFis                                                  
@ 070,005 Say OemToAnsi(cMsg3) PIXEL COLORS CLR_HRED OF oFis                                                  

ACTIVATE MSDIALOG oFis CENTER

Return(.T.)

Static function ConOk(lPar,dParFIS)

if lPar
	if MsgYESNO("Confirma atualiza็ใo ?","Atencao...","YESNO")
		putmv("MV_DATAFIS",dParFis)
	Endif
endif 

oFis:end()

return(.t.)
