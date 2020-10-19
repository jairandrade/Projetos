#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"   


User Function RELDISS()

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELDISS"
Local cPict          := ""
Local titulo         := "RELDISS"
Local nLin           := 65	
//                                 1         2         3         4         5         6         7         8         9        10        11        12        13        14         15        16       17        18        19         20       21        22
//                       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local Cabec2         := ""
Local Cabec1         := ""
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private tamanho      := "M"
Private nomeprog     := "RELDISS" 
Private cPerg	     := ""
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 1, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RELDISS" 

Private cString      := "SRA"  
Private xParFilial   :=	Space(2)
Private xParCCusto   :=	Space(9)
Private xParSituac   :=	Space(5)
Private lQuebra		 := .f.      
Private lImpDiss	 := .f.

Private nCol	     := 0
Private cBarra	     := ""


//********************************************************************************
// PROCEDIMENTOS INICIAIS
//********************************************************************************

wnrel := SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.f.,aOrd,.F.,Tamanho,.f.,.f.)
   
If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18) 

titulo         := "Relação de funcionários"

//********************************************************************************
// PROCESSA RELATORIO
//********************************************************************************

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

//********************************************************************************

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin) 

Local cCCustoAnt := ""
Local nCont      := 0 
Local nQuebraPag := 0     
Local cQuery 	:= "" 
Local MV_PARDT  := AllTrim(MV_DTRELDIS)

    cQuery := " SELECT RHH_CC, RHH_VERBA, SUM(RHH_VALOR) VALOR"
    cQuery += " FROM " + RetSQLName("RHH") + " RHH" 
    cQuery += " WHERE RHH.D_E_L_E_T_ <> '*' "
    cQuery += "   AND RHH.RHH_MESANO = '"+MV_PARDT+"'" 
	cQuery += "   AND RHH.RHH_VERBA <> '   '" 
	cQuery += " GROUP BY RHH_CC, RHH_VERBA " 
	cQuery += " ORDER BY RHH_CC, RHH_VERBA " 

	TcQuery cQuery new Alias "QRY"   

	DbSelectArea("QRY")
	DbGoTop()

	While !Eof()
		If nLin > 60	
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
			nLin++
		EndIf
    	If QRY->RHH_CC <> cCCustoAnt    
			If !Empty(cCCustoAnt)
				nLin++  	
				nLin++
			EndIf
			@nLin,001 PSay QRY->RHH_CC + " - " + Posicione("CTT",1,xFilial("CTT")+QRY->RHH_CC,"CTT_DESC01") 
			cCCustoAnt := QRY->RHH_CC 
		EndIf
		@nLin,054 PSay QRY->RHH_VERBA + " - " + Posicione("SRV",1,xFilial("SRV")+QRY->RHH_VERBA,"RV_DESC")
		@nLin,085 PSay QRY->VALOR PICTURE "@E 999,999.99"    
		nLin++  	
		DbSelectArea("QRY") 
		DbSkip()
	End
	
	DbSelectArea("QRY")
	DbCloseArea()
	

//********************************************************************************

If aReturn[5]==1
   DbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
  

