#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"                          
#INCLUDE "RPTDEF.CH"
#INCLUDE "REPORT.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RMNT032
Termo de emprestimo	

@return 
@author Felipe Toazza Caldeira
@since 28/08/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RMNT032()                      
Local oReport
Local lTRepInUse := .T.

PRIVATE lAuto  := .T.

	oReport:= ReportDef()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef�Autor  �Alexandre Inacio Lemes �Data  �06/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pedido de Compras / Autorizacao de Entrega                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nExp01: nReg = Registro posicionado do SC7 apartir Browse  ���
���          � nExp02: nOpcx= 1 - PC / 2 - AE                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oExpO1: Objeto do relatorio                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local cTitle   := "TERMO DE RESPONSABILIDADE"
Local cTime := Time()
Local cTitulo := "TERMO DE RESPONSABILIDADE"
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


oPrinter 	:= FWMSPrinter():New("RMNT032", IMP_SPOOL,,,.T.)
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
	oPrinter :Say(nLin,080,"Recebi da empresa",oFont12)
	oPrinter :Say(nLin,320," TCP - TERMINAL DE CONT�INERES DE PARANAGU� S.A",oFont12n)
	oPrinter :Say(nLin,1050,",  a, t�tulo de empr�stimo, para uso exclusivo, conforme determinado em lei, as ",oFont12)
	nLin += 40                             	
	oPrinter :Say(nLin,080,"ferramentas e equipamentos especificados neste termo de responsabilidade.",oFont12)
	nLin += 40                             	


Return


Static Function ImpItens()
Private nConta := 0              
    
	nLin += 40 
	DbSelectArea('Z13')
	Z13->(DbSetORder(1))
	Z13->(DbGoTop())
	Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM))
	While !Z13->(EOF()) .AND. Z13->Z13_NUM == Z12->Z12_NUM 
		oPrinter :Say(nLin,080,Alltrim(Posicione('SB1',1,xFilial('SB1')+Z13_FERRAM,'B1_DESC')),oFont12)			
		oPrinter :Say(nLin,880,' - Num.Serie: '+Alltrim(Z13->Z13_NUMSER),oFont12)			
		nLin += 40 
		If SubSTr(Z13->Z13_FERRAM,1,3) == 'KIT'
			DbSelectArea('Z14')
			Z14->(DbSetORder(1))
			Z14->(DbGoTop())
			Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM))
			While !Z14->(EOF()) .AND. Z14->Z14_NUM == Z12->Z12_NUM 
				oPrinter :Say(nLin,080,"   "+Alltrim(Posicione('SB1',1,xFilial('SB1')+Z14_COMPON,'B1_DESC')),oFont12)			
				oPrinter :Say(nLin,880,' - Num.Serie: '+Alltrim(Z14->Z14_COMSER),oFont12)			
				nLin += 40 
				Z14->(DbSkip())			                                      
				QuebraPG()
			EndDo		
		EndIf
		Z13->(DbSkip())   
		QuebraPG()
	EndDo
	nLin += 40 

	
Return 

Static Function ImpRodape()

	oPrinter :Say(nLin,080,"Declaro, ainda, que recebi neste ato, as orienta��es quanto o uso correto das mesmas, bem como demais cuidados para conserva��o.",oFont12)
	nLin += 50    
	QuebraPG()                         	
	oPrinter :Say(nLin,080,"Comprometendo-me a mant�-los em perfeito estado de conserva��o, ficando ciente de que:",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"1- Se o equipamento for danificado ou inutilizado por emprego inadequado, mau uso, de um equipamento da mesma marca ou equivalente ao da pra�a, sem preju�zo da",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"aplica��o das medidas disciplinares previstas em lei.",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"2- Em caso de dano, inutiliza��o, ou extravio do equipamento deverei comunicar imediatamente ao setor competente.  ",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"3- Terminando os servi�os ou no caso de rescis�o do contrato de trabalho, devolverei o equipamento completo e em perfeito estado de conserva��o, considerando-se o  ",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"tempo do uso do mesmo (tempo de vida �til), ao setor competente.",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"4- Estando os equipamentos em minha posse, estarei sujeito a inspe��es sem pr�vio aviso. ",oFont12)
	nLin += 40                             	
	nLin += 40                             	
	QuebraPG()
	oPrinter :Say(nLin,080,"Orienta��es:   ",oFont14n)
	nLin += 60                             	
	QuebraPG()
	oPrinter :Say(nLin,100,"Toda ferramenta dever� ser limpa ao final de cada expediente ou ap�s o uso.  ",oFont12)
	nLin += 40                             	
	QuebraPG()
	oPrinter :Say(nLin,100,"Ferramentas de precis�o, devem ser manuseadas com cuidado e guardadas ap�s o uso em sua embalagem. ",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,100,"Caso necessite de alguma ferramenta, procure orienta��o sobre seu uso, para somente ent�o utiliza-la.  ",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,100,"Toda ferramenta possui uma fun��o espec�fica, portanto, nunca utilize a ferramenta para fins diferentes dos quais se destina.  ",oFont12)
	nLin += 60
	QuebraPG()                             	
	oPrinter :Say(nLin,080,"Declaro estar ciente de todas as orienta��es e obriga��es.",oFont12)
	nLin += 80
	QuebraPG()                             	

	oPrinter :Say(nLin,080,"_______________________________________",oFont12)
	nLin += 40
	QuebraPG()                             	
	oPrinter :Say(nLin,080,Posicione('SRA',1,xFilial('SRA')+Z12->Z12_MATRIC,'RA_NOME'),oFont12)
	nLin += 80                             	
	
Return


Static Function QuebraPG()

	If nLin > 2600 
		oPrinter :EndPage()	
		nLin := 075
		oPrinter :StartPage()
	EndIf                             
     
Return
