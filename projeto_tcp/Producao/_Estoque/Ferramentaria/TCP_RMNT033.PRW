#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"                          
#INCLUDE "RPTDEF.CH"
#INCLUDE "REPORT.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RMNT033
Termo de devolução	

@return 
@author Felipe Toazza Caldeira
@since 28/08/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RMNT033()                      
Local oReport
Local lTRepInUse := .T.

PRIVATE lAuto  := .T.

	oReport:= ReportDef()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pedido de Compras / Autorizacao de Entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01: nReg = Registro posicionado do SC7 apartir Browse  ³±±
±±³          ³ nExp02: nOpcx= 1 - PC / 2 - AE                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local cTitle   := "Termo de Não Conformidade no Recebimento de Ferramenta"
Local cTime := Time()
Local cTitulo := "Termo de Não Conformidade no Recebimento de Ferramenta"
Local cQuery	:= ""             

Private oPrinter 			
Private nLin		:= 0  
Private nBox		:= 0    
Private nTotalQ		:= 0    
Private nTotalV		:= 0    

Private oFont10		:= TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
Private oFont10n	:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
Private oFont12		:= TFont():New("Arial",,12,,.F.,,,,.F.,.F.)
Private oFont12n	:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
Private oFont13n	:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)
Private oFont14n	:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
Private oFont16n	:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
Private oFont24n	:= TFont():New("Arial",,24,,.T.,,,,.F.,.F.)


oPrinter 	:= FWMSPrinter():New("RMNT033", IMP_SPOOL,,,.T.)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(30,30,00,00)	    
oPrinter:Setup()
	

ImpCabec()                 
ImpItens()
ImpRodape()

oPrinter :EndPage()
oPrinter :Preview()      
                                         
Return(oPrinter )
              
Static Function ImpCabec()
Local nSeqBol := ""

	oPrinter :StartPage()
                             
	nLin := 075
	oPrinter :Say(nLin,080,"Data: "+DtoC(dDataBase),oFont12n)
	oPrinter :Say(nLin,400,"Colaborador: "+Posicione('SRA',1,xFilial('SRA')+Z12->Z12_MATRIC,"RA_NOME"),oFont12n)
	oPrinter :Say(nLin,1500,"Matricula: "+Z12->Z12_MATRIC,oFont12n)
	nLin += 80                             	
	oPrinter :Say(nLin,080,"Termo de Não Conformidade no Recebimento de Ferramenta",oFont13n)
	nLin += 60                             	
	oPrinter :Say(nLin,080,"As Ferramentas abaixo descritas estão pendente de devolução, o colaborador descrito tem o prazo de 24 horas para entrega das mesmas no setor da ferramentaria",oFont12)
	nLin += 40                             	
	oPrinter :Say(nLin,080,"em perfeito estado de conservação, caso o fato não ocorra a empresa tem o direito de cobrar o valor de uma ferramenta nova da mesma marca ou equivalente ao da",oFont12)
	nLin += 40                             	
	oPrinter :Say(nLin,080,"praça, sem prejuízo da aplicação das medidas prevista em lei.",oFont12)
	nLin += 40                             	

Return


Static Function ImpItens()
Private nConta := 0              
    
	nLin += 40 
	DbSelectArea('Z14')
	Z14->(DbSetORder(1))
	Z14->(DbGoTop())
	Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM))
	While !Z14->(EOF()) .AND. Z14->Z14_NUM == Z12->Z12_NUM
		IF Z14->Z14_STATUS == '3' 
			oPrinter :Say(nLin,080,Alltrim(Posicione('SB1',1,xFilial('SB1')+Z14->Z14_COMPON,'B1_DESC')),oFont12)			
			oPrinter :Say(nLin,880,' - Num.Serie: '+Alltrim(Z14->Z14_COMSER),oFont12)			
			nLin += 40 
		EndIf
		Z14->(DbSkip())
	EndDo
	nLin += 40 

Return 

Static Function ImpRodape()
	nLin += 40 
	nLin += 40 
	oPrinter :Say(nLin,080,"Declaro estar ciente de todas as orientações e obrigações.",oFont12)
	nLin += 80                             	

	oPrinter :Say(nLin,080,"_______________________________________",oFont12)
	nLin += 40                             	
	oPrinter :Say(nLin,080,Posicione('SRA',1,xFilial('SRA')+Z12->Z12_MATRIC,'RA_NOME'),oFont12)
	nLin += 80                             	

	
Return

