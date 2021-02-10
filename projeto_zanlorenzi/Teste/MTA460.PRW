#include "Protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNNFS02  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Amarracao de pedidos x Notas Fiscais                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNNFS02()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPerg       := "BSNF001"
Local aArea			:= GetArea("SC5")
Local cFilBrw		:= ""
Local cQrySC5		:= ""
Local aIndexSC5   	:= {}	

Private cDeCliente                         
Private cAteCliente                         
Private cDeLoja
Private cAteLoja
Private cDePedido
Private cAtePedido

Private nTipo       := 0 
Private cCadastro   := "RElaciona Pedido x Nota Fiscal"
Private aFixo		:= {}        
Private lInverte    := .F.
PRIVATE bFiltraBrw  := {|| Nil}
Private aIndexSC5	:= {}
Private cCondicao   := ""
Private aCores      := {}
Private aRotina 	:= MenuDef()
Private cAlias		:= "SC5"
Private cMarca      := GetMark(,"SC5" , "C5_OK")

//Habilita Tecla de atalho na tela
SetKey(VK_F4,{|| U_SYNFS02B()})
SetKey(VK_F6,{|| U_SYNFS02D()})
                    
AjustaSX1(cPerg)   


aCores := { { "!Empty(C5_NOTA)" ,'DISABLE' },;                            //Nota Fiscal Vinculada
			{ "Empty(C5_NOTA)" ,'Enable'} ,;                                 //Nota Fiscal não vinculada
			{ "!Empty(C5_NOTA)",'BR_AMARELO' }}   		                        //Nota Fiscal já emitida


If Pergunte(cPerg , .T.)	

	cDeCliente   := MV_PAR01
	cAteCliente  := MV_PAR02
	cDeLoja      := MV_PAR03
	cAteLoja     := MV_PAR04
	cDePedido    := MV_PAR05
	cAtePedido   := MV_PAR06

	cFilBrw := " C5_CLIENTE >= '" + cDeCliente  + "' .AND. C5_CLIENTE <= '" + cAteCliente + "' "
	cFilBrw += " .AND. C5_LOJACLI >= '" + cDeLoja  + "' .AND. C5_LOJACLI <= '" + cAteLoja + "' "
	cFilBrw += " .AND. C5_NUM >= '" + cDePedido  + "' .AND. C5_NUM <= '" + cAtePedido + "' "
	cFilBrw += " .AND. C5_LIBEROK == 'S' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bFiltraBrw := {|x| If(x==Nil,FilBrowse("SC5",@aIndexSC5,@cFilBrw),{cFilBrw,cQrySC5,"","",aIndexSC5}) }
	Eval(bFiltraBrw)
	
	SC5->( MsSeek(xFilial("SC5")) )
	SC5->( dbgoTop() ) 

	MarkBrow(cAlias,"C5_OK","U_SYNFS02E()",     , .F. ,cMarca   ,"U_SYNFS02G()",,,,"U_SYNFS02A()",,,,aCores)
	
	dbSelectArea("SC5")
	RetIndex("SC5")
	dbClearFilter()
	aEval(aIndexSC5,{|x| Ferase(x[1]+OrdBagExt())})
	
	RestArea(aArea)
	
EndIf	


Return()






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNFS02A  ºAutor  ³Microsiga           º Data ³  05/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se pode ser marcado ou não                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02A()
Local lRet := .T.  //Falso permite marcar, Verdadeiro não permite marcar.
    
If !Empty(SC5->C5_NOTA)
	Alert("Pedido já gerou nota, não é permitido, associar a nota fiscal!")
	lRet := .F.
EndIf

If lRet 
	//Verifica se o item a ser marcado é do mesmo cliente de itens já marcados
	cQuery := "SELECT Count(C5_NUM)  CONTADOR "
	cQuery += "FROM "
	cQuery += RetSqlName("SC5") + " SC5 (NOLOCK) "
	cQuery += "WHERE "
	cQuery += "SC5.C5_FILIAL  = '" + xFilial("SC5") + "' AND "
	cQuery += "SC5.C5_CLIENTE + C5_LOJACLI <> '" + SC5->C5_CLIENTE + SC5->C5_LOJACLI + "' AND "
	cQuery += "SC5.C5_OK = '" + cMarca + "' AND "
	cQuery += " SC5.D_E_L_E_T_ = '' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se arquivo temporario está em uso.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP") > 0
		TMP->( dbCloseArea() )
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	
	DbSelectArea("TMP")
	TMP->(DbGotop())
	If !TMP->(Eof())
		If TMP->CONTADOR > 0
			Alert("O pedido seleciona é de um cliente diferente dos pedidos já selecionados.")
			lRet := .F.	
		EndIf
	EndIf
EndIf

If lRet	
	If Empty(SC5->C5_NOTA) 
		lRet := .T.
	Else                   
		If SC5->C5_OK <> cMarca
			If Aviso("Atenção" , "Pedido já associado a outra nota, deseja marcar mesmo assim?" , {"SIM" , "NAO"}) == 2
				lRet := .F.	
			Else
				lRet := .T.
			EndIf	       
		Else
			lRet := .T.	
		EndIf	
	EndIf          
EndIf	
	
If lRet
	SC5->(RecLock("SC5" , .F.))
	If SC5->C5_OK == cMarca
		SC5->C5_OK := Criavar("C5_OK" , .F.)
	Else
		SC5->C5_OK := cMarca
	EndIf	
	SC5->(MsUnLock())
Else
	SC5->(RecLock("SC5" , .F.))
	SC5->C5_OK := Criavar("C5_OK" , .F.)
	SC5->(MsUnLock())	
EndIf

Return(lRet)   




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Microsiga           º Data ³  05/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta as perguntas da rotina no SX1                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)
Local aHelpPor01 := {"Informe o Cliente inicial a ser   ",    "considerado na selecao."}
Local aHelpEng01 := {"",""}
Local aHelpSpa01 := {"",""}
Local aHelpPor02 := {"Informe o Cliente final  a ser    ",    "considerado na selecao."}
Local aHelpEng02 := {"",""}
Local aHelpSpa02 := {"",""}
Local aHelpPor03 := {"Informe a Loja inicial do Cliente a ser",    "considerado na selecao."}
Local aHelpEng03 := {"",""}
Local aHelpSpa03 := {"",""}
Local aHelpPor04 := {"Informe a Loja final do Cliente a ser",    "considerado na selecao."}
Local aHelpEng04 := {"",""}
Local aHelpSpa04 := {"",""}
Local aHelpPor05 := {"Informe o pedido inicial a ser",    "considerado na selecao."}
Local aHelpEng05 := {"",""}
Local aHelpSpa05 := {"",""}
Local aHelpPor06 := {"Informe o pedido final a ser",    "considerado na selecao."}
Local aHelpEng06 := {"",""}
Local aHelpSpa06 := {"",""}

CheckSX1(cPerg,"01","Cliente  De ? " , "Cliente  De ? " , "Cliente  De ? " ,"mv_ch1","C", 6 ,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor01,aHelpEng01,aHelpSpa01)
CheckSX1(cPerg,"02","Cliente Ate ? " , "Cliente Ate ? " , "Cliente Ate ? " ,"mv_ch2","C", 6 ,0,0,"G","","SA1","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor02,aHelpEng02,aHelpSpa02)
CheckSX1(cPerg,"03","Loja De ?     " , "Loja De ?     " , "Loja De ?     " ,"mv_ch3","C", 2 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor03,aHelpEng03,aHelpSpa03)
CheckSX1(cPerg,"04","Loja Ate ?    " , "Loja Ate ?    " , "Loja Ate ?    " ,"mv_ch4","C", 2 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor04,aHelpEng04,aHelpSpa04)
CheckSX1(cPerg,"05","Pedido De?    " , "Pedido de?    " , "Pedido De?    " ,"mv_ch5","C", 6 ,0,0,"G","","SC5","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor05,aHelpEng05,aHelpSpa05)
CheckSX1(cPerg,"06","Pedido Ate?   " , "Pedido Ate?   " , "Pedido Ate?   " ,"mv_ch6","C", 6 ,0,0,"G","","SC5","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor06,aHelpEng06,aHelpSpa06)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Microsiga           º Data ³  05/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define as rotinas de menu                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()
Local aRotina := { {"Pesquisar"        , "AxPesqui"         ,0, 1} ,; 
			         {"Visualizar"      , "A410Visual"     ,0, 2} ,;
                     {"Vinc Nota (F4)"  , "U_SYNFS02B()"   ,0, 4} ,;
                     {"Ger NFs (F6)"    , "U_SYNFS02D()"   ,0, 4} ,;
                     {"Legenda"         , "U_SYNFS02C()"     ,0, 4}}                     
                     

Return(aRotina) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNFS02B  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a marcação da nota fiscal ao pedido de venda       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02B()       
Local cNumNf := Criavar("C5_NOTA" , .F. )//SC5->C5_NOTA
Local oDlg         
Local oNumNf

Define MSDialog oDlg Title "Número de Nota Fiscal" From 00,00 TO 150,500 pixel
@  0.7, 1  Say  "Este processo irá associar o número da nota escolhida aos" 	Size 080,12 of oDlg
@  1.7, 1  Say  "Pedidos selecionados no Browser." 	Size 150,12 of oDlg
@  3, 1  Say  "Num. Nota Fiscal: "  Size 060,010 of oDlg
@  38,60 MsGet oNumNf var cNumNf   size 50,08 Picture PesqPict("SF2","F2_DOC")  pixel of oDlg

define sButton oBtOk  from 05,218 type 1 action (ProcOk(cNumNf , oDlg)) enable of oDlg pixel
define sButton oBtCan from 20,218 type 2 action (oDlg:End()) enable of oDlg pixel
  
Activate MSDialog oDlg Center             

Return()


//Processa associação de notas
Static Function ProcOk(CNUMNF, oDlg)

//Valida se alguma nota foi marcada
If !Marcados()
	Return()
EndIf     
	
Processa({ || UpdSC5(cNumNf) },"Aguarde!","Vinculando Notas") 	
oDlg:End()	

Return()






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNFS02C  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda da rotina                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02C()

BrwLegenda(cCadastro,"Leganda",{{'DISABLE'     ,"Nota Fiscal já emitida"        },;
                           		{'ENABLE'      ,"Nota Fiscal não vinculada"            },;
                           		{'BR_AMARELO'  ,"Nota Fiscal Vinculada"    }})
Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Marcados  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há itens selecionados                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Marcados()
Local lRet := .T.
Local aArea		:= GetArea()
Local cMarca	:= ThisMark()
Local cQuery	:= ""
Local lInverte  := ThisInv()

cQuery := "SELECT SC5.*,SC5.R_E_C_N_O_ RECNOSC5 "
cQuery += "FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
cQuery += "WHERE "
cQuery += "SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
cQuery += "SC5.C5_OK = '" + cMarca + "' AND "
cQuery += " SC5.D_E_L_E_T_ = '' "
cQuery += " ORDER BY SC5.C5_CLIENTE, SC5.C5_LOJACLI "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se arquivo temporario está em uso.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TMP") > 0
	TMP->( dbCloseArea() )
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)

dbSelectArea("TMP")
TMP->( dbgoTop() )

If TMP->( Eof() )
	MsgStop("Não existem registros a serem processados.","Atenção!")
	TMP->( dbCloseArea() )
	RestArea(aArea)
	Return(.F.)
Endif

TMP->( dbCloseArea() )    
RestArea(aArea)

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UpdSC5    ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Vincula pedido a nota fiscal selecionada                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UpdSC5(cNumNf)
Local cObj    := GetMarkBrow()  
Local cQuery
Local nRecAtu := SC5->(RecNo())

cQuery := "SELECT SC5.*,SC5.R_E_C_N_O_ RECNOSC5 "
cQuery += "FROM "
cQuery += RetSqlName("SC5") + " SC5 (NOLOCK) "
cQuery += "WHERE "
cQuery += "SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
cQuery += "SC5.C5_OK = '" + cMarca + "' AND "
cQuery += " SC5.D_E_L_E_T_ = '' "
cQuery += " ORDER BY SC5.C5_NUM "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se arquivo temporario está em uso.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TMP") > 0
	TMP->( dbCloseArea() )
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
                 
ProcRegua(TMP->(RecCount()))

dbSelectArea("TMP")
TMP->( dbgoTop() )

While !TMP->(Eof())      
	IncProc()
	DbSelectArea("SC5")
	SC5->(DbGoto( TMP->RECNOSC5 ))
	SC5->(RecLock("SC5" , .F.))
	SC5->C5_NOTA := cNumNf
	SC5->C5_OK      := Criavar("C5_OK" , .F.)
	SC5->(MsUnLock())
	
	TMP->(DbSkip())
EndDo

DbSelectArea("SC5")
SC5->(DbGotop())
SC5->(DbGoto( nRecAtu ))

cObj:oBrowse:Refresh()

Return()


User Function SYNFS02E()
Local lRet := .F.  //Falso permite marcar, Verdadeiro não permite marcar.
Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNFS02D  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara geracao de notas                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02D()

U_SYNFS02F(.T.)
               
Return()            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNFS02F  ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Notas Fiscais                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02F(lTela)
Local cObj  
Local _aNotas := {}
Local cQuery  := ""          
local cPerg       := "BSNF002"
Local cDeNota    
Local cAteNota   
local cMsgNota    := ""
Local cVirgula    := ""

Local aHelpPor01 := {"",""}
Local aHelpEng01 := {"",""}
Local aHelpSpa01 := {"",""}
Local aHelpPor02 := {"",""}
Local aHelpEng02 := {"",""}
Local aHelpSpa02 := {"",""}   
     

Default lTela := .F.                 

Private _cNotaGer := ""
Private cMsgErro  := ""

PutSX1(cPerg,"01","Nota  De ? "    , "Nota  De  ? "   , "Nota De     ? " ,"mv_ch1","C", 9 ,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor01,aHelpEng01,aHelpSpa01)
PutSX1(cPerg,"02","Nota Ate ? "    , "Nota  Ate ? "   , "Nota Ate    ? " ,"mv_ch2","C", 9 ,0,0,"G","","   ","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor02,aHelpEng02,aHelpSpa02)

//Monta lista de notas a serem geradas
If lTela
	cQuery := "SELECT DISTINCT SC5.C5_NOTA "
	cQuery += "FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
	cQuery += "WHERE "
	cQuery += "SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
	cQuery += " SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_CLIENTE >= '" + cDeCliente  + "' AND C5_CLIENTE <= '" + cAteCliente + "' "
	cQuery += " AND C5_LOJACLI >= '" + cDeLoja  + "' AND C5_LOJACLI <= '" + cAteLoja + "' "
	cQuery += " AND C5_NUM >= '" + cDePedido  + "' AND C5_NUM <= '" + cAtePedido + "' "
	cQuery += " AND C5_NOTA = '' AND C5_LIBEROK = 'S' "
	cQuery += " AND C5_NOTA <> '' "
	cQuery += " ORDER BY SC5.C5_NOTA "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se arquivo temporario está em uso.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMP") > 0
		TMP->( dbCloseArea() )
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	
	DbSelectArea("TMP")
	TMP->(DbGotop())
	While !TMP->(Eof())	
		AADD(_aNotas , TMP->C5_NOTA)
		cMsgNota += cVirgula + TMP->C5_NOTA 
		cVirgula := ", "
	
		TMP->(DbSkip())	
	EndDo                             
	
	DbSelectArea("TMP")
	TMP->(DbCloseArea())
Else    
	If Pergunte(cPerg , .T.)	
		cDeNota     := mv_par01
		cAteNota    := mv_par02
		
		cQuery := "SELECT DISTINCT SC5.C5_NOTA "
		cQuery += "FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
		cQuery += "WHERE "
		cQuery += "SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
		cQuery += " SC5.D_E_L_E_T_ = '' "
		cQuery += " AND C5_NOTA = '' AND C5_LIBEROK = 'S' "
		cQuery += " AND C5_NOTA >= '" + cDeNota + "' AND C5_NOTA <= '" + cAteNota + "' "
		cQuery += " AND C5_NOTA <> '' "
		cQuery += " ORDER BY SC5.C5_NOTA "
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se arquivo temporario está em uso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("TMP") > 0
			TMP->( dbCloseArea() )
		EndIf	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa Query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
		
		DbSelectArea("TMP")
		TMP->(DbGotop())
		While !TMP->(Eof())	
			AADD(_aNotas , TMP->C5_NOTA)
			cMsgNota += cVirgula + TMP->C5_NOTA 
			cVirgula := ", "
			
			TMP->(DbSkip())	
		EndDo                             
		
		DbSelectArea("TMP")
		TMP->(DbCloseArea())	
	EndIf	
EndIf         

If Aviso("Atenção" , "Serão geradas as notas: " + cMsgNota + ". Ok?", {"SIM","NAO"} , 3) == 1
	
	Processa({ || GeraNF(_aNotas) },"Aguarde!","Gerando notas") 	
	                      
	//Atualiza Browser apos gerada as notas
	If AllTrim(FunName()) $ "SYNNFS02"
		cObj := GetMarkBrow()  
		cObj:oBrowse:Refresh()
	EndIf	
	
	If !Empty(cMsgErro)
		cMsgErro := "Erros encontrados:" + CHR(10) + CHR(13) + "Foi gerado erro na pasta: \erros_GERNFS\" + CHR(10) + CHR(13) + cMsgErro
		Alert(cMsgErro)
		U_BSGrvErro("Erro_" + DTOS(dDataBase) + Replace(Time() , ":" , "") + ".log" , "\erros_GERNFS\", cMsgErro)
	EndIf
EndIf                   



Return()        

//Grava erro no log.
User Function BSGrvErro(cArq, cPatch, cMsg)

Local cArquivo := cPatch + cArq                        
Local _nHa
Local nBytesSalvo  := 0 
Local cTexto       := ""

//Cria diretórios da DIRECT no servidor 
U_BSCriaDir(cPatch)

If File(cArquivo)
	FErase(cArquivo)
EndIf  
	
_nHa := FCREATE(cArquivo)
	
If _nHa == -1
	MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')
	FCLOSE(_nHa)	// Fecha o arquivo de Origem
	Return()
Endif                                                                                

cTexto := cMsg
nBytes := Len(cTexto)
nBytesSalvo := FWRITE(_nHa, cTexto, nBytes)

FT_FUSE()
FClose(_nHa)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaDir   ºAutor  ³Microsiga           º Data ³  05/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria diretorios necessários para integracao                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BSCriaDir(cPatch)
Local cDir := SubStr(cPatch , 1, Len(cPatch) -1 )
Local aDir := Separa(cDir , "\" , .F.) 
Local i    := 0
Local cBarra := "\"
Local cDirGer := ""
          
For i := 1 To Len(aDir)
	cDirGer += cBarra + aDir[i] + "\"
	cBarra := ""	
	MakeDir(cDirGer)
Next i

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460NUM   ºAutor  ³Microsiga           º Data ³  08/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada utilizado para alterar o numero da NF     º±±
±±º          ³ no processo de geração de notas                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460NUM()

If AllTrim(FunName()) $ "SYNNFS02|SYNFS02F"
	cNumero := _cNotaGer    	
EndIf                     

Return()



Static Function GeraNF(_aNotas)
Local lContinua := .T.
Local cSerie	:= GetNewPar("BS_XSERGER","1")
Local cNFSaida 	:= ""
Local aPvlNfs   := {}
Local aPedidos  := {}

ProcRegua(Len(_aNotas))

For i := 1 to Len(_aNotas)
	IncProc("Gerando nota " + _aNotas[i])
	lContinua := .T.
	_cNotaGer := _aNotas[i]
	
	//Verifica se a nota já existe, caso sim aborta o processo para a nota
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbGotop())
	If SF2->(DbSeek( xFilial("SF2") + aVKey(_cNotaGer, "F2_DOC") + aVKey(cSerie, "F2_SERIE") ))
		cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + ", esta nota fiscal já existe no sistema."+ CHR(10) + CHR(13)
		lContinua := .F.
	EndIf
	
	If lContinua
		//Obtem os pedidos da Nota
		cQuery := "SELECT SC5.*, SC5.R_E_C_N_O_ RECNOSC5  "
		cQuery += "FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
		cQuery += "WHERE "
		cQuery += "SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
		cQuery += " SC5.D_E_L_E_T_ = '' "
		cQuery += " AND C5_NOTA = '" + _cNotaGer + "' "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se arquivo temporario está em uso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("TMPSC5") > 0
			TMPSC5->( dbCloseArea() )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa Query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSC5",.T.,.T.)
		
		DbSelectArea("TMPSC5")
		TMPSC5->(DbGotop())
		
		aPvlNfs := {}
		aPedidos := {}
		
		While !TMPSC5->(Eof())
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			DbSelectArea("SE4")
			SE4->(DbSetOrder(1))
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))

			If !Empty(SC9->C9_NOTA)
				SC9->(DbSkip())
				Loop
			EndIF	
			
			//Marca os pediso para flagar que a nota fiscal foi gerada
			If aScan(aPedidos , TMPSC5->C5_NUM ) <= 0
				AADD(aPedidos , TMPSC5->C5_NUM)
			EndIf
			
			If SC9->(DbSeek(xFilial("SC9")+TMPSC5->C5_NUM))
				While SC9->(!Eof()) .AND. SC9->C9_PEDIDO == TMPSC5->C5_NUM
					SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
					SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
					SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
					SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
					
					aAdd(aPvlNfs,{;
					SC9->C9_PEDIDO,;
					SC9->C9_ITEM,;
					SC9->C9_SEQUEN,;
					SC9->C9_QTDLIB,;
					SC9->C9_PRCVEN,;
					SC9->C9_PRODUTO,;
					.F.,;
					SC9->(RECNO()),;
					SC5->(RECNO()),;
					SC6->(RECNO()),;
					SE4->(RECNO()),;
					SB1->(RECNO()),;
					SB2->(RECNO()),;
					SF4->(RECNO());
					})
					SC9->(DbSkip())
				EndDo
			EndIf
			
			TMPSC5->(DbSkip())
		EndDo

		If Select("TMPSC5") > 0
			TMPSC5->( dbCloseArea() )
		EndIf
		
		Begin Transaction
			//Gera documento de saida
			Pergunte("MT460A",.F.)
			cNFSaida := MaPvlNfs(aPvlNfs, cSerie, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)
			
			If cNFSaida <> _cNotaGer .or. Empty(cNFSaida)
				DisarmTransaction()
				If Empty(cNFSaida)
					cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + CHR(10) + CHR(13)
				EndIf
				
				If cNFSaida <> _cNotaGer
					cMsgErro += "Nota fiscal numero " + _cNotaGer  + " gerada com numeração cNFSaida , processo não realizado." + CHR(10) + CHR(13)
				EndIf
			Else          
				/*
				For j := 1 to len(aPedidos)
					DbSelectArea("SC5")
					SC5->(DbGotop())
					SC5->(DbSetOrder(1))				
					If SC5->(DbSeek( xFilial("SC5") + aPedidos[j] ))
						SC5->(RecLock("SC5" , .F.))
						SC5->C5_XFLAGNF := "1"
						SC5->(MsUnLock())
					EndIf
				Next j
				*/
			EndIf	
		End Transaction		
	EndIf
	
Next i

Return()




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SYNNFS02G ºAutor  ³Microsiga           º Data ³  08/31/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Invertre seleção ao clicar no cabeçalho                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SYNFS02G()
Local nRecAtu := SC5->(RecNo())

DbSelectArea("SC5")
SC5->(DbGotop())
While !SC5->(Eof())
	If !Empty(SC5->C5_NOTA)
		SC5->(DbSkip())
		Loop
	EndIf
	
	If SC5->C5_OK == cMarca    
		SC5->(RecLock("SC5" , .F.))
		SC5->C5_OK := CriaVar("C5_OK" , .F.)
		SC5->(MsUnLock())	
	Else
		SC5->(RecLock("SC5" , .F.))
		SC5->C5_OK := cMarca
		SC5->(MsUnLock())		
	EndIf
     
	SC5->(DbSkip())
EndDO

SC5->(DbGoto(nRecAtu))

Return()
