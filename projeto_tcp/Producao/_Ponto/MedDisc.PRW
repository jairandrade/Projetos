#Include "totvs.ch"
#Include "topconn.ch" 
#Include "rptdef.ch" 

/*/{Protheus.doc} MedDisc
Rotina Medidas Disciplinares
@type function
@since 12/10/2016

Alteração
@since 31/07/2020
@author Willian Kaneta
@descritpion Alteração Layout Impressão Advertência

/*/
User Function MedDisc()
local cQuery := ""   
  
local lCad := .F.

Private cCadastro := "Medidas Disciplinares"
Private aRotina := {}
Private cCusto := ""                                         
Private	aCores := { { 'ZP3_STATUS = "P"   ','BR_VERMELHO' },;
					{ 'ZP3_STATUS = "E"   ','BR_VERDE'    },;
					{ 'ZP3_STATUS = "J"   ','BR_AZUL'     }}

If cModulo=="GPE"
	AADD(aRotina,{"Pesquisar","AxPesqui",0,1})
	AADD(aRotina,{"Visualizar","AxVisual",0,2})
	AADD(aRotina,{"Incluir","AxInclui",0,3})
	AADD(aRotina,{"Alterar","AxAltera",0,4})
	AADD(aRotina,{"Excluir","AxDeleta",0,5})
	AADD(aRotina,{"Motivos","U_MotMD",0,3})
	AADD(aRotina,{"Imprimir","U_ImprMD",0,6})
	AADD(aRotina,{"Relatório","U_RelMD",0,6})
	AADD(aRotina,{"Legenda","U_LegMD",0,4})   
Else
	AADD(aRotina,{"Pesquisar","AxPesqui",0,1})
	AADD(aRotina,{"Visualizar","AxVisual",0,2})
	AADD(aRotina,{"Incluir","AxInclui",0,3})
	AADD(aRotina,{"Imprimir","U_ImprMD",0,6})
	AADD(aRotina,{"Legenda","U_LegMD",0,4})   
EndIf   

_cCodUsr := RETCODUSR()

cQuery := "SELECT * "
cQuery += " FROM "+RetSQLName("ZD5")+" ZD5 "
cQuery += " WHERE ZD5.ZD5_IDUSER = '"+ALLTRIM(_cCodUsr)+"'" 
cQuery += " AND ZD5.D_E_L_E_T_ <> '*' "

TCQUERY cQuery NEW ALIAS "QRY"
// inicio arquivo 
QRY->(DbGoTop())
	If !QRY->( Eof() )   
		cCusto := QRY->ZD5_CCUSTO 
		lCad:=.T.
	endif
QRY->(DbCloseArea())	
// fecha query  

dbSelectArea("ZP3")
dbSetOrder(1)        

// se não for final de arquivo
If lCad
	SET FILTER TO ALLTRIM(ZP3->ZP3_CC) $ ALLTRIM(cCusto)
ElseIf cModulo=="PON"                                                     
	SET FILTER TO ALLTRIM(ZP3->ZP3_IDGEST) == RETCODUSR()
Else
	If Empty(FunName())
		SET FILTER TO ZP3->ZP3_STATUS == "P"                         
	EndIf
EndIf


mBrowse(,,,,"ZP3",,,,,,aCores)

Return

/*/{Protheus.doc} LegMD
/*/
User Function LegMD()

Private cCadastro := "STATUS DA OCORRÊNCIA"

Private aCores2 := { { 'BR_VERMELHO' , "Pendente" },;
				     { 'BR_VERDE'    , "Entregue" },;
				     { 'BR_AZUL'     , "Justificada"}}
                 
BrwLegenda(cCadastro,"Legenda",aCores2)

Return

/*/{Protheus.doc} MotMD
/*/
User Function MotMD()

Local aArea		:= GetArea()

Private cString := "ZP1"

dbSelectArea("ZP1")
dbSetOrder(1)

//AxCadastro(cString,"Motivos MD",cVldExc,cVldAlt)
AxCadastro(cString,"Motivos MD")

RestArea(aArea)

Return

/*/{Protheus.doc} RelMD
/*/
User Function RelMD()

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELMD"
Local titulo         := "RELMD"
Local nLin           := 65	
//                                 1         2         3         4         5         6         7         8         9        10        11        12        13        14         15        16       17        18        19         20       21        22
//                       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                       XXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX/XX/XXXX XX:XX ADV XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX 
Local Cabec1         := "MATR.  NOME                                       C.CUSTO                        TURNO DE TRABALHO                        FUNÇÃO                         DATA       HORA  OC. MOTIVO                         STATUS          "	
Local Cabec2         := ""
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private tamanho      := "G"
Private nomeprog     := "RELMD" 
Private cPerg	     := "MEDDISC"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 1, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RELMD" 

Private cString      := "ZP3"  
Private lQuebra		 := .f.      

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

titulo         := "Medidas Disciplinares"

//********************************************************************************
// PROCESSA RELATORIO
//********************************************************************************

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/{Protheus.doc} RunReport
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin) 

Local cQuery	:= ""
Local cGestAnt	:= ""  

Pergunte(cPerg,.f.)

Tamanho := "G"        
cBarra := "================================================================================================================================================================="

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSQLName("ZP3")+" ZP3 "
	cQuery += " WHERE ZP3.ZP3_MATR   >= '"+mv_par01+"'" 
	cQuery += "   AND ZP3.ZP3_MATR   <= '"+mv_par02+"'" 
	cQuery += "   AND ZP3.ZP3_CC     >= '"+mv_par03+"'" 
	cQuery += "   AND ZP3.ZP3_CC     <= '"+mv_par04+"'" 
	cQuery += "   AND ZP3.ZP3_TURNO  >= '"+mv_par05+"'" 
	cQuery += "   AND ZP3.ZP3_TURNO  <= '"+mv_par06+"'" 
	cQuery += "   AND ZP3.ZP3_FUNCAO >= '"+mv_par07+"'" 
	cQuery += "   AND ZP3.ZP3_FUNCAO <= '"+mv_par08+"'" 
	cQuery += "   AND ZP3.ZP3_DATA   >= '"+Dtos(mv_par09)+"'" 
	cQuery += "   AND ZP3.ZP3_DATA   <= '"+Dtos(mv_par10)+"'"  
	If mv_par11 == 1
		cQuery += "   AND ZP3.ZP3_OCORRE = 'ADV' "  
	Else
		If mv_par11 == 2
			cQuery += "   AND ZP3.ZP3_OCORRE = 'SUS' "  
		EndIf
	EndIf
	If mv_par12 == "999" .or. mv_par12 == "   " 
	Else
		cQuery += "   AND ZP3.ZP3_MOTIVO = '"+mv_par12+"' "  
	EndIf
	If mv_par13 == 1
		cQuery += "   AND ZP3.ZP3_STATUS = 'P' "  
	Else
		If mv_par13 == 2
  			cQuery += "   AND ZP3.ZP3_STATUS = 'E' "  
		Else                                      
			If mv_par13 == 3
  				cQuery += "   AND ZP3.ZP3_STATUS = 'J' "  
			EndIf
		EndIf
	EndIf
	cQuery += "   AND ZP3.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY ZP3.ZP3_GESTOR, ZP3.ZP3_MATR "

	TCQUERY cQuery NEW ALIAS "QRY"             
	DbSelectArea("QRY")
	DbGoTop()    
	
	While !Eof()
		If nLin > 63
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)	
			nLin++
		Endif   

		If QRY->ZP3_GESTOR <> cGestAnt
			nLin++                     
			@nLin,000 PSay "GESTOR: " + QRY->ZP3_GESTOR    
			nLin++                     
			nLin++
			cGestAnt := QRY->ZP3_GESTOR
		EndIf                      			
					      
		@nLin,000 PSay QRY->ZP3_MATR
		@nLin,007 PSay Posicione("SRA",1,QRY->ZP3_FILIAL+QRY->ZP3_MATR,"RA_NOME")    
		@nLin,050 PSay POSICIONE("CTT",1,XFILIAL("CTT")+QRY->ZP3_CC,"CTT_DESC01")                     
		@nLin,082 PSay POSICIONE("SR6",1,XFILIAL("SR6")+QRY->ZP3_TURNO,"R6_DESC")                                           
		@nLin,123 PSay POSICIONE("SRJ",1,XFILIAL("SRJ")+QRY->ZP3_FUNCAO,"RJ_DESC")                                                                
		@nLin,154 PSay Dtoc(Stod(QRY->ZP3_DATA))                                                                
		@nLin,165 PSay Transform(QRY->ZP3_HORA,"@R 99:99")                                                                
		@nLin,171 PSay QRY->ZP3_OCORRE                                                                
		@nLin,175 PSay SUBSTR(POSICIONE("ZP1",1,XFILIAL("ZP1")+QRY->ZP3_MOTIVO,"ZP1_DESCRI"),1,30)  
		If QRY->ZP3_STATUS == "P"                                                             
			@nLin,206 PSay "Pendente"
		Else
			If QRY->ZP3_STATUS == "E"                                                             
				@nLin,206 PSay "Entregue"
			Else
				@nLin,206 PSay "Justificada"
			EndIf                                                                
		EndIf                                                                
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
  
/*/{Protheus.doc} ImprMD
Impressão Advertencia/  Suspensão
@type function
@since 12/10/2016

Alteração
@since 31/07/2020
@author Willian Kaneta
@descritpion Alteração Layout Impressão Advertência

/*/
User Function ImprMD()

Local nDiasSusp := 0
Local nLinhas 	:= 0
Local nX		:= 0
Local cDiasSusp := ""
Local cRef		:= ""   
Local cAtoArt	:= ""   
Local cHist		:= "" 
Local lAto		:= ""
Local cHora		:= SUBSTR(TIME(), 1, 2)+"_"+SUBSTR(TIME(), 4, 2)+"_"+SUBSTR(TIME(), 7, 2)
Local oBrush1 	:= TBrush():New( , CLR_BLUE)
Local oBrush2	:= TBrush():New( , Rgb(200, 156, 76))
Local _cTxtMot  := POSICIONE("ZP1",1,xFilial("ZP1")+ZP3->ZP3_MOTIVO,"ZP1_DESCRI")
Local cDepart	:= POSICIONE("CTT",1,XFILIAL("CTT")+ZP3->ZP3_CC," CTT_DESC01")
Local cFuncao	:= POSICIONE("SRJ",1,XFILIAL("SRJ")+ZP3->ZP3_FUNCAO,"RJ_DESC")
Local cLocalDT 	:= "Paranaguá, "+AllTrim(Str(Day(ZP3->ZP3_DATAR)))+" de "+Alltrim(mesextenso(Month(ZP3->ZP3_DATAR)))+" de "+StrZero(Year(ZP3->ZP3_DATAR),4,0)
//Local cFunGes	:= POSICIONE("SRA",1,XFILIAL("SRA")+ZP3->ZP3_IDGEST,"RA_CODFUNC")
//Local cDescFG	:= POSICIONE("SRJ",1,XFILIAL("SRJ")+cFunGes,"RJ_DESC")

Private oPrint
Private cAlias 	  	:= GetNextAlias() //cria um alias temporário

Private oFont12		:= TFont():New('Arial',,12,,.F.,,,,.F.,.F.)
Private oFont12n	:= TFont():New('Arial',,12,,.T.,,,,.F.,.F.)
Private oFont14		:= TFont():New('Arial',,14,,.F.,,,,.F.,.F.)
Private oFont14n	:= TFont():New('Arial',,14,,.T.,,,,.F.,.F.)
Private oFont14s	:= TFont():New('Arial',,14,,.T.,,,,.F.,.T.)
Private oFont16n	:= TFont():New('Arial',,16,,.T.,,,,.F.,.F.)

Private nLin		:= 1  

oPrint := FWMsPrinter():New('Medidas_Disc'+cHora,IMP_PDF,,,.T.)
oPrint:SetPortrait()    

oPrint:StartPage()   //Inicia a página do relatório
	//Cabeçalho
	oPrint:Fillrect( {0,1200, 90, 2200 }, oBrush1)
	oPrint:Fillrect( {1000,70,1200,140 } , oBrush2)
	If cEmpAnt == "02"
		oPrint:SayBitmap(10, 200, "\system\meddisc_logo02.png"	,670,330)
	ElseIf cEmpAnt == "03"
		oPrint:SayBitmap(110, 200, "\system\meddisc_logo03.png"	,390,160)
	EndIf

	If ZP3->ZP3_OCORRE == "SUS"
		oPrint:Say(nLin+=390,1050,"SUSPENSÃO",oFont16n)  
	Else
		oPrint:Say(nLin+=390,0900,"ADVERTÊNCIA DISCIPLINAR",oFont16n)  
	EndIf      

	//Box Principal
	oPrint:Box(nLin+=60	,250,nLin+2300,2200)

	oPrint:Say(nLin+=60	,1710	,cLocalDT,oFont12)     
	oPrint:Say(nLin+=60	,270	,"Sr(a). "+Posicione("SRA",1,xFilial("SRA")+ZP3->ZP3_MATR,"RA_NOME"),oFont12)     
	oPrint:Say(nLin+=60 ,270	,"Matricula: " +ZP3->ZP3_MATR + "- Departamento: " + cDepart		,oFont12)  
	oPrint:Say(nLin+=60 ,270	,"Função: " + cFuncao 												,oFont12)
	
	If ZP3->ZP3_OCORRE == "ADV" .OR. ZP3->ZP3_OCORRE == "ADB"
		cRef := "ADVERTÊNCIA DISCIPLINAR"
	ElseIf ZP3->ZP3_OCORRE == "SUS"
		cRef := "SUSPENSÃO"
	EndIf
	oPrint:Say(nLin+=120,270	,"Ref.: " 		,oFont12 )
	oPrint:Say(nLin		,340	,cRef 			,oFont14n)
	
	oPrint:Say(nLin+=120,270	,"Prezado Sr.(a).:",oFont12)

	oPrint:Say(nLin+=120,270	,"O presente  documento aplica a  penalidade de ",oFont12)
	oPrint:Say(nLin     ,885	,cRef										   ,oFont14s)

	cAtoArt := Alltrim(LOWER(_cTxtMot))
	cAtoArt += " com base no Art. 482 da CLT e nos seguintes fatos:"

	lAto := IIF(At("ato ",_cTxtMot)>0 .OR. At("Ato ",_cTxtMot)>0 .OR. At("ATO ",_cTxtMot)>0,.T.,.F.)
	If ZP3->ZP3_OCORRE == "ADV" .OR. ZP3->ZP3_OCORRE == "ADB"
		If lAto
			oPrint:Say(nLin     ,1400	," devido  ao seu ",oFont12)
			If Len(cAtoArt) > 180
				oPrint:Say(nLin,1610,SUBSTR(cAtoArt,1,45),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,46,146),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,192,Len(cAtoArt)),oFont12)
			ElseIf Len(cAtoArt) > 45 .AND. Len(cAtoArt) < 180
				oPrint:Say(nLin,1610,SUBSTR(cAtoArt,1,45),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,46,Len(cAtoArt)),oFont12)
			ElseIf Len(cAtoArt) < 45
				oPrint:Say(nLin,1610,SUBSTR(cAtoArt,1,45),oFont12)	
			EndIf
		Else
			oPrint:Say(nLin     ,1375	," devido ao seu ato de ",oFont12)
			If Len(cAtoArt) > 180
				oPrint:Say(nLin,1665,SUBSTR(cAtoArt,1,38),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,39,146),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,185,Len(cAtoArt)),oFont12)
			ElseIf Len(cAtoArt) > 36 .AND. Len(cAtoArt) < 180
				oPrint:Say(nLin,1665,SUBSTR(cAtoArt,1,38),oFont12)
				oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,39,Len(cAtoArt)),oFont12)
			ElseIf Len(cAtoArt) < 36
				oPrint:Say(nLin,1665,SUBSTR(cAtoArt,1,36),oFont12)	
			EndIf
		EndIf

	ElseIf ZP3->ZP3_OCORRE == "SUS"
		If ZP3->ZP3_DATFIM == ZP3->ZP3_DATINI
			nDiasSusp	:= 1
		Else
			nDiasSusp	:= ZP3->ZP3_DATFIM-ZP3->ZP3_DATINI
		EndIf
	
		cDiasSusp	:= cValToChar(nDiasSusp) +" ("+ Extenso(nDiasSusp,.T.,,"")+" )" + " dia(s), com  a respectiva  perda do  recebimento de salário, devido  ao seu"

		If Len(cDiasSusp) > 84 
			If lAto
				oPrint:Say(nLin,1120,SUBSTR(cDiasSusp,1,84),oFont12)
				cDiasSusp := SUBSTR(cDiasSusp,84,Len(cDiasSusp)) + cAtoArt
				nLinhas := MlCount(cDiasSusp,147,,.F.)
				For nX := 1 To nLinhas  
					oPrint:Say(nLin+=60,270,MemoLine(cDiasSusp,147,nX,,.F.),oFont12)  
				Next nX	
			Else
				oPrint:Say(nLin,1120,SUBSTR(cDiasSusp,1,84),oFont12)
				cDiasSusp := SUBSTR(cDiasSusp,85,Len(cDiasSusp)) + " ato de " + cAtoArt
				nLinhas := MlCount(cDiasSusp,147,,.F.)
				For nX := 1 To nLinhas  
					oPrint:Say(nLin+=60,270,MemoLine(cDiasSusp,147,nX,,.F.),oFont12)  
				Next nX					
			EndIf
		Else 
			oPrint:Say(nLin,1120,cDiasSusp,oFont12)
			If lAto
				If Len(cAtoArt ) > 149
					oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,1,149),oFont12)
					oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,150,Len(cAtoArt)),oFont12)
				Else
					oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,1,149),oFont12)
				EndIf
			Else
				oPrint:Say(nLin+=60 ,270,"  ato de ",oFont12)
				If Len(cAtoArt ) > 147
					oPrint:Say(nLin,380,SUBSTR(cAtoArt,1,137),oFont12)
					oPrint:Say(nLin+=60,270,SUBSTR(cAtoArt,138,Len(cAtoArt)),oFont12)
				Else
					oPrint:Say(nLin,380,SUBSTR(cAtoArt,1,137),oFont12)
				EndIf
			EndIf
		EndIf
		
	EndIf

	nLin+=60
	//Historico
	cHist   := ZP3->ZP3_HISTOR
	cHist 	:= StrTran (cHist, chr(9)	," ") // TAB
	cHist 	:= StrTran (cHist, CRLF		," ") // enter
	nLinhas := MlCount(cHist,139,,.F.)
	nTamTXT := 139
	nQtdCarac := 1

	For nX := 1 To nLinhas 
		//Calcula o tamanho da string em pixel
		nTamanho := GetStringPixSize(SUBSTR(Alltrim(cHist),nQtdCarac,nTamTXT), "Arial", 12,.T.)[2]
		If nTamanho <= 1040
			oPrint:Say(nLin+=60,270,SUBSTR(Alltrim(cHist),nQtdCarac,nTamTXT),oFont12n)
		Else
			nTamTXT := nTamTXT - INT((nTamanho - 1040) / 10)
			oPrint:Say(nLin+=60,270,SUBSTR(Alltrim(cHist),nQtdCarac,nTamTXT),oFont12n)
		EndIf
		nQtdCarac += nTamTXT
		nTamTXT := 139
	Next nX	

	If ZP3->ZP3_OCORRE == "SUS"
		If ZP3->ZP3_DATFIM == ZP3->ZP3_DATINI
			oPrint:Say(nLin+=60,270,"O retorno ao trabalho deve ocorrer em " + AllTrim(Str(Day(ZP3->ZP3_DATFIM+1)))+" de "+Alltrim(mesextenso(Month(ZP3->ZP3_DATFIM)))+" de "+StrZero(Year(ZP3->ZP3_DATFIM),4,0),oFont12) 
		Else
			oPrint:Say(nLin+=60,270,"O retorno ao trabalho deve ocorrer em " + AllTrim(Str(Day(ZP3->ZP3_DATFIM)))+" de "+Alltrim(mesextenso(Month(ZP3->ZP3_DATFIM)))+" de "+StrZero(Year(ZP3->ZP3_DATFIM),4,0),oFont12) 
		EndIf
	EndIf

	nLin+=60

	oPrint:Say(nLin+=60,270,"Oportunamente, avisamos que a reincidência, se ocorrer, será punida com rigor necessário para manter a ordem, a disciplina, e a segurança no empre-",oFont12) 
	oPrint:Say(nLin+=60,270,"go.Contamos com seu apoio e colaboração para que as regras da companhia sejam seguidas.",oFont12) 	

	nLin+=60
	oPrint:Say(nLin+=60,270,"Solicitamos que você dê o seu de acordo neste aviso.",oFont12)

	oPrint:Say(nLin+=60,270,"Atenciosamente,",oFont12)

	nLin+=60
	oPrint:Say(nLin+=60,270,"TCP – TERMINAL DE CONTEINERES DE PARANAGUÁ S.A.",oFont14n)
	oPrint:Say(nLin+=60,270,UPPER(ZP3->ZP3_GESTOR),oFont12n)
	//oPrint:Say(nLin+=60,270,UPPER(cDescFG),oFont12)
	
	nLin+=60
	
	oPrint:Say(nLin+=60,1590,"Recebi uma cópia original deste documento.",oFont12)
	nLin+=120
	oPrint:Line(nLin,1580,nLin,2170)
	oPrint:Say(nLin+=60,1580,POSICIONE("SRA",1,xFilial("SRA")+ZP3->ZP3_MATR,"RA_NOME"),oFont12n)
	oPrint:Say(nLin+=60,1580,"Matricula nº: " + Alltrim(ZP3->ZP3_MATR),oFont12n)
	
	
	oPrint:Say(nLin+=60,270,"TESTEMUNHAS: ",oFont14)

	nLin+=120
	oPrint:Line(nLin,270,nLin,870)
	oPrint:Line(nLin,1320,nLin,2020)

	oPrint:Say(nLin+=60	,270,"Nome: ",oFont12n)
	oPrint:Say(nLin		,1320,"Nome: ",oFont12n)

	oPrint:Say(nLin+=60	,270,"Matricula nº: ",oFont12n)
	oPrint:Say(nLin		,1320,"Matricula nº: ",oFont12n)

	//Rodapé
	oPrint:Say(2830,100,"Av. do Batel, 1750 - cjto 219 - 2º andar - Curitiba / PR - Brasil - CEP 80420-090"	,,,CLR_BLUE)
	oPrint:Say(2830,1230,"1750 Batel Ave, room nº 219, 2nd floor, Curitiba, PR - Brazil - Zip Code 80420-090",,,CLR_BLUE)
	
	oPrint:Say(2890,100,"Av. Portuária, s/n - Porto D. Pedro II -  Paranaguá / PR - Brasil - CEP 83221-570",,,CLR_BLUE)
	oPrint:Say(2890,1230,"Portuária Ave, Porto D. Pedro II, Paranaguá, PR - Brazil - Zip COde 83221-570"	,,,CLR_BLUE)

	oPrint:Fillrect( {2930,500,3000,2000 }, oBrush1)

	oPrint:Preview()
oPrint:EndPage()
Return 

/*/{Protheus.doc} Cadrest
/*/
User Function Cadrest()

Local aArea		:= GetArea()

dbSelectArea("ZD5")
dbSetOrder(1)

AxCadastro("ZD5","Restriçao de usuarios p/ CC")

RestArea(aArea)

Return
