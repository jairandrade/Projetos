	
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN - Financeiro                                        !
+------------------+---------------------------------------------------------+
!Nome              ! RFIN001                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Chamada de impressão dos boletos  banco Itau.           !
+------------------+---------------------------------------------------------+
!Autor             ! Rodrigo Slisinski														           !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/06/2013                                              !
+------------------+---------------------------------------------------------+
*/

#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function RFIN001(cPref,cNum,cParc,cTipo,cInstr)

Local lRet := .F.

Private aBord     := {}
Private aTitulo   := {}
Private oBoleto
Private nSaltLn   := 80
Private nLinDados := 30
Private nLin      := 5000
Private lPrimPag  := .T.
Private nPag      := 0
Private cPerg     := PADR("RFIN001_",10)

Private oArial06  := TFont():New('Arial',06,06,,.F.,,,,.T.,.F.,.F.)
Private oArial06N := TFont():New('Arial',06,06,,.T.,,,,.T.,.F.,.F.)
Private oArial07  := TFont():New('Arial',07,07,,.F.,,,,.T.,.F.,.F.)
Private oArial07N := TFont():New('Arial',07,07,,.T.,,,,.T.,.F.,.F.)
Private oArial08  := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.,.F.)
Private oArial08N := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.,.F.)
Private oArial09N := TFont():New('Arial',09,09,,.T.,,,,.T.,.F.,.F.)
Private oArial10  := TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
Private oArial10N := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
Private oArial14  := TFont():New('Arial',14,14,,.F.,,,,.T.,.F.,.F.)
Private oArial14N := TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
Private oArial16N := TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
Private oArial18N := TFont():New('Arial',18,18,,.T.,,,,.T.,.F.,.F.)

DEFAULT cPref  := NIL
DEFAULT cNum   := NIL
DEFAULT cParc  := NIL
DEFAULT cTipo  := NIL
DEFAULT cInstr := NIL

If cNum == NIL
	fCriaPerg(cPerg)
	If Pergunte(cPerg,.T.)
		If Empty(MV_PAR05) .OR. Empty(MV_PAR06) .OR. Empty(MV_PAR07)
			MsgStop("Favor preencher os dados referente ao banco")
		Else
			Processa( { || fSelTitulo() }, "[RFIN001] - AGUARDE")
		EndIf
	EndIf
Else
	
	cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, (E1_SALDO) SALDO "
	cQuery += "FROM " + RETSQLNAME("SE1") + " "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	cQuery += "AND E1_FILIAL = '" + cFilAnt + "' "
	cQuery += "AND E1_PREFIXO = '" + cPref + "' "
	cQuery += "AND E1_NUM = '" + cNum + "' "
	cQuery += "AND E1_PARCELA = '" + cParc + "' "
	cQuery += "AND E1_TIPO = '" + cTipo + "' "
	cQuery += "AND E1_CLIENTE + E1_LOJA <>  '99999901' " //Supplier
	
	cQuery := ChangeQuery(cQuery)
	
	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRB"
	TCSETFIELD("TRB", "E1_EMISSAO" , "D", 08, 0)
	TCSETFIELD("TRB", "E1_VENCREA" , "D", 08, 0)
	TCSETFIELD("TRB", "SALDO"   , "N", 14, 2)
	
	dbSelectArea("TRB")
	ProcRegua(0)
	dbGoTop()
	While !Eof()
		
		IncProc("Buscando informações dos boletos...")
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA)
			AADD(aTitulo,{.T., TRB->E1_PREFIXO, TRB->E1_NUM, TRB->E1_PARCELA, TRB->E1_TIPO, TRB->E1_CLIENTE, TRB->E1_LOJA, SA1->A1_NOME, TRB->E1_EMISSAO, TRB->E1_VENCREA, TRB->SALDO})
		EndIf
		
		dbSelectArea("TRB")
		TRB->(dbSkip())
	EndDo
	
	If Len(aTitulo) <= 0
		ApMsgAlert("Não existem títulos a serem impressos. Confira os parâmetros!")
		Return
	EndIf
	
	Processa( { || fImprime(cInstr) },"[RFIN001] - AGUARDE")
EndIf

Return


//============================ PRINTREPORT ============================//

Static Function fImprime(cInstr)
Local n := 0


Local aDadosTit
Local aDadosBanco
Local aDatSacado

Private i         := 1
Private CB_RN_NN  := {}
Private nRec      := 0
Private _nVlrAbat := 0
Private lPrint := .F.
Private aDadosEmp    := {SM0->M0_NOMECOM                                                           ,; //Nome da Empresa
SM0->M0_ENDCOB                                                            ,; //Endereço
AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //Complemento
"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //CEP
"PABX/FAX: "+SM0->M0_TEL                                                  ,; //Telefones
Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+                       ;
Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ;
Subs(SM0->M0_CGC,13,2)                                                    ,; //CGC
"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ;
Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                         }  //I.E


Private xDac    := ''
Private oPrint

oPrint:= TMSPrinter():New( )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página

Private aImprime := {}

DEFAULT cInstr := NIL

ProcRegua(Len(aTitulo))
For Yi:=1 To Len(aTitulo)
	
	IncProc("Gerando nosso número...")
	
	If !aTitulo[Yi,1]
		Loop
	EndIf
	
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SE1")+aTitulo[Yi,2]+aTitulo[Yi,3]+aTitulo[Yi,4]+aTitulo[Yi,5])
		Loop
	EndIf
	If !Empty(SE1->E1_NUMBOR) .AND. Empty(SE1->E1_BOLETO)     
		Aviso("Atenção","O titulo número: "+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+CHR(13)+CHR(10)+ "Pertence a carteira 112 "+CHR(13)+CHR(10)+ "Para impressão favor acessar portal do BANCO!",{"OK"},2,"Atencao",,'lgrl01.bmp',.t.,,1) 
  	Loop
	EndIF

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		Loop
	EndIf
	
	
	Do Case
		Case MV_PAR05 <> "341" 
			ALERT("banco nao configurado para impressao de boletos!")
		Case MV_PAR05 == "341"
			Processa({ ||  bolitau() },"[RFIN002] - AGUARDE")
	EndCase
	
	
Next Yi

oPrint:Preview()

Return

Static Function bolitau

nMulta := 0.02 * SE1->E1_VALOR
xMDia    := (0.058 * SE1->E1_SALDO)/30
aBolText := {"APOS O VENCIMENTO COBRAR MULTA DE R$ "+ alltrim(transform(0.02 * SE1->E1_VALOR,")@E 999,999,999.99")) +" MAIS MORA DE R$"+alltrim(transform((SE1->E1_SALDO*SA1->A1_PORCJUR)/100,"@E 999,999,999.99"))+" AO DIA" ,;  //SE1->E1_SALDO*SE1->E1_PORCJUR)/100,
"PROTESTAR APóS 05 DIAS ÚTEIS",;  //25/08/2016 -- "DEVOLVER EM "+DTOC(SE1->E1_VENCTO+30),;  
"",;
""}

//DbSelectArea("TRA")
//Posiciona o SA6 (Bancos)
DbSelectArea("SA6")
DbSetOrder(1)// filial+ banco + agencia + conta
DbSeek(xFilial()+MV_PAR05+MV_PAR06+MV_PAR07,.T.)

xDac := ''
aDadosBanco  := {SA6->A6_COD                                   ,;   //Numero do Banco
"Banco Itaú SA"                                   ,;   //Nome do Banco
SUBSTR(SA6->A6_AGENCIA, 1, 5)                    ,;   //Agência
SA6->A6_NUMCON                                   ,;   //Conta Corrente
"2"                                              ,;   //Carteira
SA6->A6_COD                                       }   //Codigo no SA6


aDatSacado   := {AllTrim(SA1->A1_NOME)                            ,;   //Razão Social
AllTrim(SA1->A1_COD )                            ,;   //Código
AllTrim(SA1->A1_END )                            ,;   //Endereço
AllTrim(SA1->A1_MUN )                            ,;   //Cidade
SA1->A1_EST                                      ,;   //Estado
SA1->A1_CEP										,;   //CEP
SA1->A1_CGC                                       }    //CGC
_nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

_cPrefixo   := SE1->E1_PREFIXO
_nTitulo    := SE1->E1_NUM
If !Empty(SE1->E1_PARCELA)
	_nTitulo  := _nTitulo + " - " + SE1->E1_PARCELA
Endif
_dEmissao := SE1->E1_EMISSAO
_dVenc    := SE1->E1_VENCREA
_nSaldo   := SE1->E1_SALDO
xParcela  := SE1->E1_PARCELA
CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3)+"9" , aDadosBanco[3] , aDadosBanco[4] ,;
aDadosBanco[5],AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),(SE1->E1_SALDO-_nVlrAbat),aDadosBanco[6],DTOS(SE1->E1_VENCREA),SE1->E1_PREFIXO )

aDadosTit := {AllTrim(_nTitulo)    ,;     //Número do título
_dEmissao            ,;     //Data da emissão do título
Date()               ,;     //Data da emissão do boleto
_dVenc               ,;     //Data do vencimento
(_nSaldo - _nVlrAbat),;     //Valor do título
CB_RN_NN[3]          ,;     //Nosso Numero
xParcela              }     // parcela incluido em 18/02/03                                                                 //Nosso número (Ver fórmula para calculo)

Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN) //Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

Return



Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)  //Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
Local oFont8
Local oFont10
Local oFont16
Local oFont16n
Local oFont24
Local i := 0
Local aCoords1  := {2000,1900,2100,2300}
Local aCoords2  := {2270,1900,2340,2300}
Local oBrush
// Local _cNN := Substr(aDadosTit[6],1,2) + " " + Substr(aDadosTit[6],3,3) + " " + Substr(aDadosTit[6],6,3) + " " + Substr(aDadosTit[6],9,2) + " " + Substr(aDadosTit[6],11,1)
Local xCarteira := '109'
Local _cNN      := "109/" + aDadosTit[6]
Local cMsg1     := ''
Local cMsg2     := ''
Local cMsg3     := ''

IF SuBStr(aDadosBanco[1],1,3) == '347'
	_cNN        := aDadosTit[6]
	xCarteira   := '20'
ElseIF SuBStr(aDadosBanco[1],1,3) == '409'  // Unibanco
	_cNN        := "1/" + aDadosTit[6]
	xCarteira   := '04'
ElseIF SuBStr(aDadosBanco[1],1,3) == '237'
	_cNN        := '09/'+aDadosTit[6]
	xCarteira   := '09'
ElseIF SuBStr(aDadosBanco[1],1,3) == '422' // Safra
	_cNN        := aDadosTit[6]
	xCarteira   := '02'
EndIF

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont09  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)

oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

//oBrush := TBrush():New("",4)

oPrint:StartPage()   // Inicia uma nova página

//Primeira Via
oPrint:Line (150,100,150,2300)
oPrint:Line (150,550,50,550)
oPrint:Line (150,800,50,800)
oPrint:Say  (50,100,aDadosBanco[2]                                   ,oFont16)
oPrint:Say  (50,567,aDadosBanco[1]                                   ,oFont24)
oPrint:Say  (70,820,CB_RN_NN[2]                                      ,oFont14)
oPrint:Say  (20,1900,"Recibo do Pagador"                              ,oFont14)

oPrint:Line (220,1900,220,2300 )
oPrint:Line (220,100,220,2300 )

oPrint:Line (290,100,290,2300 )
oPrint:Line (360,100,360,2300 )
oPrint:Line (425,100,425,2300 )
oPrint:Line (490,100,490,2300 )

oPrint:Line (360,500,490,500)
oPrint:Line (425,750,490,750)
oPrint:Line (360,1000,490,1000)
oPrint:Line (220,1350,290,1350)

oPrint:Line (360,1350,425,1350)

oPrint:Line (360,1550,490,1550)

IF SuBStr(aDadosBanco[1],1,3) == '341'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO ITAÚ"
	cMSg3 := ''
ElseIF SuBStr(aDadosBanco[1],1,3) == '347'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO SUDAMERIS"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO SUDAMERIS"
	cMSg3 := ''
ElseIF SuBStr(aDadosBanco[1],1,3) == '409'
	cMsg1 := "ATÉ O VENCIMENTO, PAGAVEL EM QUALQUER BANCO"
	cMsg2 := "APÓS O VENCIMENTO, EM QUALQUER AGENCIA DO UNIBANCO"
	cMSg3 := "MEDIANTE A CONSULTA NO SISTEMA VC"
ElseIF SuBStr(aDadosBanco[1],1,3) == '237'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BRADESCO"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO BRADESCO"
	cMSg3 := ''
ElseIF SuBStr(aDadosBanco[1],1,3) == '422'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO SAFRA"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO SAFRA"
	cMSg3 := ''
ElseIF SuBStr(aDadosBanco[1],1,3) == '655'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BANCO BV"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO BANCO BV"
	cMSg3 := ''
EndIF
oPrint:Say  (150,100 ,"Local de Pagamento"                           ,oFont8)
oPrint:Say  (150,400 ,cMsg1                                          ,oFont10)
oPrint:Say  (185,400 ,cMsg2                                          ,oFont10)
oPrint:Say  (220,400 ,cMsg3                                          ,oFont10)

oPrint:Say  (150,1910,"Vencimento"                                   ,oFont8)
oPrint:Say  (175,2120,alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10)

oPrint:Say  (220,1910,"Agência/Código Beneficiário" ,oFont8)
oPrint:Say  (245,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
//oPrint:Say  (245,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10,10,,,2)

oPrint:Say  (220,100 ,"Beneficiário"                                       ,oFont8)
oPrint:Say  (245,100 ,aDadosEmp[1]                                    ,oFont10)


oPrint:Say  (220,1355,"CNPJ/CPF"                                      ,oFont8)
oPrint:Say  (245,1455,aDadosEmp[6]                                    ,oFont10)

oPrint:Say  (290,100 ,"Endereço Beneficiário"                                ,oFont8)
oPrint:Say  (317,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999"))   ,oFont10)



oPrint:Say  (290,1910,"Nosso Número"                                  ,oFont8)
oPrint:Say  (315,2045,alltrim(_cNN)                                    ,oFont10)
//oPrint:Say  (315,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (360,100 ,"Data do Documento"                             ,oFont8)
oPrint:Say  (385,100 ,DTOC(aDadosTit[3])                              ,oFont10)

oPrint:Say  (360,505 ,"Número do Documento"                            ,oFont8)
oPrint:Say  (385,605 ,aDadosTit[1]                                     ,oFont10)

oPrint:Say  (360,1005,"Espécie"                                        ,oFont8)
oPrint:Say  (385,1105,"DM"                                             ,oFont10)

oPrint:Say  (360,1355,"Aceite"                                          ,oFont8)
oPrint:Say  (385,1455,"NAO"                                             ,oFont10)

oPrint:Say  (360,1555,"Data do Processamento"                           ,oFont8)
oPrint:Say  (385,1655,DTOC(aDadosTit[2])                                ,oFont10)

oPrint:Say  (360,1910,"(=)Valor do Documento"                           ,oFont8)
oPrint:Say  (385,2195,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10)
//oPrint:Say  (385,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10,,,2)

if SuBStr(aDadosBanco[1],1,3) <> '422'  // SAFRA
	oPrint:Say  (425,100 ,"Uso do Banco"                                    ,oFont8)
	IF SuBStr(aDadosBanco[1],1,3) == '409'
		oPrint:Say  (450,150 ,"CVT 5539-5"                                    ,oFont10)
	Else
		oPrint:Say  (450,150 ,""                                    ,oFont10)
	EndIF
else // para o SAfra
	oPrint:Say  (425,100 ,"Data de Operação"  ,oFont8)
	oPrint:Say  (450,150 ,DTOC(aDadosTit[2])   ,oFont10)
endif
oPrint:Say  (425,505 ,"Carteira"                                        ,oFont8)
oPrint:Say  (450,555 ,xCarteira                                         ,oFont10)

oPrint:Say  (425,755 ,"Espécie Moeda"                                   ,oFont8)
oPrint:Say  (450,805 ,"R$"                                              ,oFont10)

oPrint:Say  (425,1005,"Quant. Moeda"                                    ,oFont8)
oPrint:Say  (425,1555,"Valor da Moeda"                                  ,oFont8)

oPrint:Say  (490,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do Beneficiário.)" ,oFont8)
oPrint:Say  (520,150 ,aBolText[1]                                       ,oFont10)
oPrint:Say  (570,150 ,aBolText[2]                                       ,oFont10)
oPrint:Say  (620,150 ,aBolText[3]                                       ,oFont10)
oPrint:Say  (690,150 ,aBolText[4]                                       ,oFont10)

oPrint:Say  (425,1910,"(-)Desconto"                                     ,oFont8)
oPrint:Say  (490,1910,"(-)Outras Deduções/Abatimento"                   ,oFont8)
oPrint:Say  (560,1910,"(+)Mora/Multa"                                   ,oFont8)
oPrint:Say  (630,1910,"(+)Outros Acréscimos"                            ,oFont8)
oPrint:Say  (700,1910,"(=)Valor Cobrado"                                ,oFont8)

oPrint:Say  (770,100 ,"Pagador"                                          ,oFont8)
oPrint:Say  (800,400 ,aDatSacado[1]                                     ,oFont10)
oPrint:Say  (800,1870,"CNPJ/CPF- "+aDatSacado[7]                        ,oFont09)
//oPrint:Say  (800,2100,"CNPJ/CPF- "+aDatSacado[7]                        ,oFont09,10,,,2)

oPrint:Say  (853,400 ,aDatSacado[3]                                     ,oFont10)
oPrint:Say  (906,400 ,aDatSacado[4]+" - "+aDatSacado[5]+" CEP "+aDatSacado[6] ,oFont10)

//oPrint:Say  (853,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (922,100 ,"Pagador/Avalista"                                ,oFont8)
oPrint:Say  (922,2000 ,"Código de Baixa"                                ,oFont8)

oPrint:Say  (962,100,"Recebimento através do cheque num.                    do banco            ." ,oFont8)
oPrint:Say  (962,1900,"Autenticação Mecânica"                           ,oFont8)
oPrint:Say  (982 ,100,"Esta quitação só terá validade após o pagamento do cheque pelo" ,oFont8)
oPrint:Say  (1002,100,"banco Pagador.",oFont8)

oPrint:Line (150,1900,770,1900 )
oPrint:Line (560,1900,560,2300 )
oPrint:Line (630,1900,630,2300 )
oPrint:Line (700,1900,700,2300 )
oPrint:Line (770,100,770,2300 )

oPrint:Line (957,100,957,2300  )

//Gambiarra, descobrir como mudar tipo da linha.
For i := 100 to 2300 step 50
	oPrint:Line( 1083, i, 1083, i+30)
Next i

//Segunda Via
oPrint:Line (1180,100,1180,2300)
oPrint:Line (1180,550,1080,550)
oPrint:Line (1180,800,1080,800)

oPrint:Say  (1080,100,aDadosBanco[2]                                    ,oFont16)
oPrint:Say  (1080,567,aDadosBanco[1]                                    ,oFont24)
oPrint:Say  (1080,1900,""                                 ,oFont14)

oPrint:Line (1250,100,1250,2300 )
oPrint:Line (1320,100,1320,2300 )
oPrint:Line (1390,100,1390,2300 )
oPrint:Line (1455,100,1455,2300 )
oPrint:Line (1520,100,1520,2300 )

oPrint:Line (1390,500,1520,500)
oPrint:Line (1455,750,1520,750)
oPrint:Line (1390,1000,1520,1000)

oPrint:Line (1250,1350,1320,1350)
oPrint:Line (1390,1350,1455,1350)


oPrint:Line (1390,1550,1520,1550)

oPrint:Say  (1180,100 ,"Local de Pagamento"                             ,oFont8)
oPrint:Say  (1180,400 ,cMsg1                                            ,oFont10)
oPrint:Say  (1215,400 ,cMsg2                                            ,oFont10)
oPrint:Say  (1250,400 ,cMsg3                                            ,oFont10)
oPrint:Say  (1180,1910,"Vencimento"                                     ,oFont8)
oPrint:Say  (1205,2120,alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10)

oPrint:Say  (1250,1910,"Agência/Código Beneficiário" ,oFont8)
oPrint:Say  (1275,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10)
//oPrint:Say  (1275,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10,,,2)


oPrint:Say  (1250,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (1275,100 ,aDadosEmp[1]                                     ,oFont10)

oPrint:Say  (1250,1355,"CNPJ/CPF"					                    ,oFont8)
oPrint:Say  (1275,1455,aDadosEmp[6]		                                ,oFont10)
                
oPrint:Say  (1320,100 ,"Endereço Beneficiário"                                        ,oFont8)
oPrint:Say  (1347,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999")) ,oFont10)


oPrint:Say  (1320,1910,"Nosso Número"                                   ,oFont8)
oPrint:Say  (1345,2045,alltrim(_cNN)                                    ,oFont10)
//oPrint:Say  (1345,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (1390,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (1415,100 ,DTOC(aDadosTit[3])                               ,oFont10)

oPrint:Say  (1390,505 ,"Número do Documento"                            ,oFont8)
oPrint:Say  (1415,605 ,aDadosTit[1]                                     ,oFont10)

oPrint:Say  (1390,1005,"Espécie"                                        ,oFont8)
oPrint:Say  (1415,1105,"DM"                                             ,oFont10)

oPrint:Say  (1390,1355,"Aceite"                                         ,oFont8)
oPrint:Say  (1415,1455,"NAO"                                            ,oFont10)

oPrint:Say  (1390,1555,"Data do Processamento"                          ,oFont8)
oPrint:Say  (1415,1655,DTOC(aDadosTit[2])                               ,oFont10)

oPrint:Say  (1390,1910,"(=)Valor do Documento"                          ,oFont8)
oPrint:Say  (1415,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10)
//oPrint:Say  (1415,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10,,,2)

oPrint:Say  (1455,100 ,"Uso do Banco"                                   ,oFont8)
oPrint:Say  (1480,150 ," "                                         ,oFont10)

oPrint:Say  (1455,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (1480,555 ,xCarteira                                        ,oFont10)

oPrint:Say  (1455,755 ,"Espécie Moeda"                                  ,oFont8)
oPrint:Say  (1480,805 ,"R$"                                             ,oFont10)

oPrint:Say  (1455,1005,"Quant. Moeda"                                   ,oFont8)
oPrint:Say  (1455,1555,"Valor da Moeda"                                 ,oFont8)

oPrint:Say  (1520,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do Beneficiário.)" ,oFont8)
oPrint:Say  (1550,150 ,aBolText[1]                                      ,oFont10)
oPrint:Say  (1600,150 ,aBolText[2]                                      ,oFont10)
oPrint:Say  (1650,150 ,aBolText[3]                                      ,oFont10)
oPrint:Say  (1700,150 ,aBolText[4]                                      ,oFont10)

oPrint:Say  (1455,1910,"(-)Desconto"                                    ,oFont8)
oPrint:Say  (1520,1910,"(-)Outras Deduções/Abatimento"                  ,oFont8)
oPrint:Say  (1590,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (1660,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (1730,1910,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (1800,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (1830,400 ,aDatSacado[1]                                    ,oFont10)
oPrint:Say  (1830,1870,"CNPJ/CPF- "+aDatSacado[7]                           ,oFont09,10)
//oPrint:Say  (1830,2100,"CNPJ/CPF- "+aDatSacado[7]                           ,oFont09,10,,,2)

oPrint:Say  (1883,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (1936,400 ,aDatSacado[4]+" - "+aDatSacado[5]+" CEP "+aDatSacado[6] ,oFont10)

//oPrint:Say  (1883,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (1952,100 ,"Pagadorr/Avalista"                               ,oFont8)
oPrint:Say  (1952,2000 ,"Código de Baixa"                               ,oFont8)

oPrint:Say  (1992,1900,"Autenticação Mecânica"                          ,oFont8)

oPrint:Line (1180,1900,1800,1900 )
oPrint:Line (1590,1900,1590,2300 )
oPrint:Line (1660,1900,1660,2300 )
oPrint:Line (1730,1900,1730,2300 )
oPrint:Line (1800,100,1800,2300 )

oPrint:Line (1987,100,1987,2300  )
nAjust:=150
//Gambiarra, descobrir como mudar tipo da linha.
For i := 100 to 2300 step 50
	oPrint:Line(2213-nAjust, i, 2213-nAjust, i+30)
Next i

//Inicio da ultima via
oPrint:Line (2363-nAjust,100,2363-nAjust,2300)
oPrint:Line (2363-nAjust,550,2263-nAjust,550 )
oPrint:Line (2363-nAjust,800,2263-nAjust,800 )

oPrint:Say  (2263-nAjust,100,aDadosBanco[2],oFont16 )
oPrint:Say  (2263-nAjust,567,aDadosBanco[1],oFont24 )
oPrint:Say  (2263-nAjust,820,CB_RN_NN[2],oFont14)

oPrint:Line (2433-nAjust,1900,2433-nAjust,2300 )
oPrint:Line (2503-nAjust,100,2503-nAjust,2300 )
oPrint:Line (2573-nAjust,100,2573-nAjust,2300 )
oPrint:Line (2638-nAjust,100,2638-nAjust,2300 )
oPrint:Line (2703-nAjust,100,2703-nAjust,2300 )

oPrint:Line (2573-nAjust,500,2703-nAjust,500)
oPrint:Line (2638-nAjust,750,2703-nAjust,750)
oPrint:Line (2573-nAjust,1000,2703-nAjust,1000)

oPrint:Line (2433-nAjust,1350,2503-nAjust,1350)
oPrint:Line (2573-nAjust,1350,2638-nAjust,1350)

oPrint:Line (2573-nAjust,1550,2703-nAjust,1550)

oPrint:Say  (2363-nAjust,100 ,"Local de Pagamento"                             ,oFont8)
oPrint:Say  (2363-nAjust,400 ,cMsg1 ,oFont10)
oPrint:Say  (2395-nAjust,400 ,cMsg2 ,oFont10)
oPrint:Say  (2435-nAjust,400 ,cMsg3 ,oFont10)
oPrint:Say  (2363-nAjust,1910,"Vencimento"                                     ,oFont8)
oPrint:Say  (2388-nAjust,2120,alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10)
//oPrint:Say  (2388-nAjust,2170,alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10,,,,2)

oPrint:Say  (2433-nAjust,1910,"Agência/Código Beneficiário"                         ,oFont8)
oPrint:Say  (2458-nAjust,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10)
//oPrint:Say  (2458-nAjust,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10,,,2)


oPrint:Say  (2433-nAjust,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (2458-nAjust,100 ,aDadosEmp[1]                                    ,oFont10)

oPrint:Say  (2733-nAjust,1355,"CNPJ/CPF"					                             ,oFont8)
oPrint:Say  (2458-nAjust,1455,aDadosEmp[6]		                                 ,oFont10)
                 
oPrint:Say  (2503-nAjust,100 ,"Endereço Beneficiário"                                        ,oFont8)
oPrint:Say  (2530-nAjust,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999")) ,oFont10)


oPrint:Say  (2503-nAjust,1910,"Nosso Número"                                   ,oFont8)
oPrint:Say  (2528-nAjust,2045,alltrim(_cNN)                                    ,oFont10,10)
//oPrint:Say  (2528-nAjust,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (2573-nAjust,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (2598-nAjust,100 ,DTOC(aDadosTit[3])                               ,oFont10)

oPrint:Say  (2573-nAjust,505 ,"Número do Documento"                            ,oFont8)
oPrint:Say  (2598-nAjust,605 ,aDadosTit[1]                                     ,oFont10)

oPrint:Say  (2573-nAjust,1005,"Espécie"                                        ,oFont8)
oPrint:Say  (2598-nAjust,1105,"DM"                                             ,oFont10)

oPrint:Say  (2573-nAjust,1355,"Aceite"                                         ,oFont8)
oPrint:Say  (2598-nAjust,1455,"NAO"                                            ,oFont10)

oPrint:Say  (2573-nAjust,1555,"Data do Processamento"                          ,oFont8)
oPrint:Say  (2598-nAjust,1655,DTOC(aDadosTit[2])                               ,oFont10)

oPrint:Say  (2573-nAjust,1910,"(=)Valor do Documento"                              ,oFont8      )
oPrint:Say  (2598-nAjust,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10)
//oPrint:Say  (2598-nAjust,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10,,,2)

oPrint:Say  (2638-nAjust,100 ,"Uso do Banco"                                   ,oFont8)
oPrint:Say  (2663-nAjust,150 ," "                                    ,oFont10)

oPrint:Say  (2638-nAjust,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (2663-nAjust,555 ,xCarteira                                        ,oFont10)

oPrint:Say  (2638-nAjust,755 ,"Espécie Moeda"                                  ,oFont8)
oPrint:Say  (2663-nAjust,805 ,"R$"                                             ,oFont10)

oPrint:Say  (2638-nAjust,1005,"Quant. Moeda"                                   ,oFont8)
oPrint:Say  (2638-nAjust,1555,"Valor da Moeda"                                 ,oFont8)

oPrint:Say  (2703-nAjust,100 ,"Instruções (Todas informações deste boleto são de exclusiva responsabilidade do Beneficiário.)" ,oFont8)
oPrint:Say  (2733-nAjust,150 ,aBolText[1]                                      ,oFont10)
oPrint:Say  (2783-nAjust,150 ,aBolText[2]                                      ,oFont10)
oPrint:Say  (2833-nAjust,150 ,aBolText[3]                                      ,oFont10)
oPrint:Say  (2893-nAjust,150 ,aBolText[4]                                      ,oFont10)

oPrint:Say  (2638-nAjust,1910,"(-)Desconto"                                    ,oFont8)
oPrint:Say  (2703-nAjust,1910,"(-)Outras Deduções/Abatimento"                  ,oFont8)
oPrint:Say  (2773-nAjust,1910,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (2843-nAjust,1910,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (2913-nAjust,1910,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (2983-nAjust,100 ,"Pagador"                                         ,oFont8)
oPrint:Say  (3013-nAjust,400 ,aDatSacado[1]                                    ,oFont10)
oPrint:Say  (3013-nAjust,1870,"CNPJ/CPF- "+aDatSacado[7]                       ,oFont09  ,10)
//oPrint:Say  (3013-nAjust,2100,"CNPJ/CPF- "+aDatSacado[7]                       ,oFont09  ,10,,,2)

oPrint:Say  (3066-nAjust,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (3119-nAjust,400 ,aDatSacado[4]+" - "+aDatSacado[5]+" CEP "+aDatSacado[6] ,oFont10)

//oPrint:Say  (3066,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)

oPrint:Say  (3135-nAjust,100 ,"Pagador/Avalista"                               ,oFont8)
oPrint:Say  (3135-nAjust,2000 ,"Código de Baixa"                               ,oFont8)

oPrint:Say  (3175-nAjust,1400,"Autenticação Mecânica - Ficha de Compensação"   ,oFont8)

oPrint:Line (2363-nAjust,1900,2983-nAjust,1900 )
oPrint:Line (2773-nAjust,1900,2773-nAjust,2300 )
oPrint:Line (2843-nAjust,1900,2843-nAjust,2300 )
oPrint:Line (2913-nAjust,1900,2913-nAjust,2300 )
oPrint:Line (2983-nAjust,100,2983-nAjust,2300 )
oPrint:Line (3170-nAjust,100,3170-nAjust,2300  )
MSBAR("INT25",26.0,1.6,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660
oPrint:EndPage() // Finaliza a página

Return Nil



Return

//============================ SELECIONA TITULOS ===========================//

Static Function fSelTitulo()

Local lRet := .F.
Local nOpc := 0
Local oOk  := LoadBitMap(GetResources(), "LBOK")
Local oNo  := LoadBitMap(GetResources(), "LBNO")

cQuery := "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCREA, (E1_SALDO) SALDO "
cQuery += "FROM " + RETSQLNAME("SE1") + " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND E1_FILIAL = '" + cFilAnt + "' "
cQuery += "AND E1_PREFIXO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
cQuery += "AND E1_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cQuery += "AND E1_TIPO NOT IN ('PA ', 'PR ') "
cQuery += "AND E1_CLIENTE + E1_LOJA <>  '99999901' " //Supplier

//If !Empty(MV_PAR08)
//	cQuery += "AND E1_NUMBOR = '" + MV_PAR08 + "' "
//	cQuery += "AND E1_PORTADO = '" + MV_PAR05 + "' "
//	cQuery += "AND E1_AGEDEP = '" + MV_PAR06 + "' "
//	cQuery += "AND E1_CONTA = '" + MV_PAR07 + "' "/
//Else
	cQuery += "AND (E1_PORTADO = '' OR (E1_PORTADO = '" + MV_PAR05 + "' AND E1_AGEDEP = '" + MV_PAR06 + "' AND E1_CONTA = '" + MV_PAR07 + "')) "
//EndIf

cQuery := ChangeQuery(cQuery)

If ( SELECT("TRB") ) > 0
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "TRB"
TCSETFIELD("TRB", "E1_EMISSAO" , "D", 08, 0)
TCSETFIELD("TRB", "E1_VENCREA" , "D", 08, 0)
TCSETFIELD("TRB", "SALDO"   , "N", 14, 2)

dbSelectArea("TRB")
ProcRegua(0)
dbGoTop()
While !Eof()
	
	IncProc("Buscando informações...")
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA)
		AADD(aTitulo,{.F., TRB->E1_PREFIXO, TRB->E1_NUM, TRB->E1_PARCELA, TRB->E1_TIPO, TRB->E1_CLIENTE, TRB->E1_LOJA, SA1->A1_NOME, TRB->E1_EMISSAO, TRB->E1_VENCREA, TRB->SALDO})
	EndIf
	
	dbSelectArea("TRB")
	TRB->(dbSkip())
EndDo

If Len(aTitulo) <= 0
	ApMsgAlert("Não existem títulos a serem impressos. Confira os parâmetros!")
	Return
EndIf

DEFINE MSDIALOG oDlgTit TITLE "[RFIN001] - Impressão de Boleto de Cobrança" From 001,001 to 380,615 Pixel

//========================// Browse com os títulos //========================//

oBrwTit := TCBrowse():New(010,005,300,150,,,,oDlgTit,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oBrwTit:AddColumn(TCColumn():New(" "            , {|| If(aTitulo[oBrwTit:nAt,01],oOk,oNo) },,,,,,.T.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Prefixo"      , {|| aTitulo[oBrwTit:nAt,02]},,,,, ,.F.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Número"       , {|| aTitulo[oBrwTit:nAt,03]},,,,, ,.F.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Parcela"      , {|| aTitulo[oBrwTit:nAt,04]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Tipo"         , {|| aTitulo[oBrwTit:nAt,05]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Cliente"      , {|| aTitulo[oBrwTit:nAt,06]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Loja"         , {|| aTitulo[oBrwTit:nAt,07]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Nome Cliente" , {|| aTitulo[oBrwTit:nAt,08]},,,,, 40 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Dt. Emissão"  , {|| aTitulo[oBrwTit:nAt,09]},,,,, 10 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Dt. Vencto."  , {|| aTitulo[oBrwTit:nAt,10]},,,,, 10 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Valor"        , {|| aTitulo[oBrwTit:nAt,11]},"@E 9,999,999.99",,,"RIGHT", ,.F.,.T.,,,,.F., ) )

oBrwTit:SetArray(aTitulo)

oBrwTit:bLDblClick   := { || aTitulo[oBrwTit:nAt,01] := !aTitulo[oBrwTit:nAt,01]  }
oBrwTit:bHeaderClick := { || fSelectAll() }

oBtnImpr := tButton():New(170,210,'Imprimir'  ,oDlgTit, {|| nOpc := 1, oDlgTit:End() },40,12,,,,.T.)
oBtnSair := tButton():New(170,260,'Sair'      ,oDlgTit, {|| oDlgTit:End() },40,12,,,,.T.)

ACTIVATE MSDIALOG oDlgTit CENTERED

If nOpc == 1
	Processa( { || fImprime() },"[RFIN001] - AGUARDE" )
EndIf

Return

//============================ Inverte a seleção ============================//
Static Function fSelectAll()

For i:=1 to Len(aTitulo)
	aTitulo[i,1] := !aTitulo[i,1]
	Next i

oBrwTit:Refresh()

Return


                              //1     2      3       4         5       6      7         8      9
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cCarteira,cNroDoc,nValor,cCodBanco,dVencto,cPref)
Local blvalorfinal := strzero(nValor*100,10)
Local dvnn := 0
Local dvcb := 0
Local dv   := 0
Local NN := ''
Local RN := ''
Local CB := ''
Local s  := ''
Local cLivre := ''
Local _nFator := 0

_nFator := stod(dVencto) - CTOD("07/10/1997") ///"00/07/2003")
//_nFator += 1000

If SuBStr(cBanco,1,3) == '341' .OR. SuBStr(cBanco,1,3) == '655'
		NN := u_numItau()
EndIf


IF SuBStr(cBanco,1,3) == '341' 
	s:= AllTrim(cAgencia) + SubStr(alltrim(cConta),1,5) + "109" + SubStr(alltrim(NN),1,8) // incluido em 19/02/03
	dvnn := modulo10(s)
	
	s := cBanco      + Alltrim(Str(_nFator)) + blvalorfinal + "109" + SubStr(alltrim(NN),1,8)+Alltrim(Str(dvnn)) +AllTrim(cAgencia) + SubStr(alltrim(cConta),1,6) + "000"
	
	dvcb := str(Mod11CB(s))
	CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)
	
	// Linha digitavel
	//   banco+ moeda   carteira    2 primeiros digitos do nosso numero
	s := cBanco       + "109"     + SubStr(NN, 1, 2)
	dv := modulo10(s)
	RN := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + ' '
	
	//   Restante do nosso numero  DAC (NN)  3 pos. inic. agencia
	s := SubStr(NN, 3, 6)          +Alltrim(Str(dvnn))  + SubStr(cAgencia, 1, 3)
	dv := modulo10(s)
	RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + ' '
	
	//   Resto da agencia         conta                         dac conta
	s := SubStr(cAgencia, 4, 1) + SubStr(alltrim(cConta),1,6)+ "000"
	dv := modulo10(s)
	RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + ' '
	
	RN := RN + AllTrim(dvcb) + ' '
	RN := RN + Alltrim(Str(_nFator)) + blvalorfinal
	// monta o nosso numero com o digito verificador
	NN:= NN + "-" + Alltrim(Str(dvnn))
EndIf
// Codigo de barras, Linha digitavel, nosso numero
Return({CB,RN,NN})



Static Function Modulo10(cData)
Local Soma, Mult, M, N
Soma := 0
Mult := 2
For i:=Len(cData) to 1 step -1
	If Mult == 0
		Mult := 2
	Endif
	M := Val(SubStr(cData, i, 1)) * Mult
	If M >= 10
		Soma += (Val(SubStr(Alltrim(Str(M)), 1, 1)) + Val(SubStr(Alltrim(Str(M)), 2, 1)))
	Else
		Soma += M
	Endif
	Mult -= 1
Next
If Soma < 10
	DV := 10 - Soma
Else
	DV := Mod(Soma, 10)
	If DV > 0
		DV := 10 - DV
	Endif
Endif
Return(DV)


USER FUNCTION numItau(cTitu)       

LOCAL nNum     := ""
LOCAL aAreaSE1 := SE1->(GetArea())
LOCAL aAreaSEE := SEE->(GetArea())

//SE1->(dbSetOrder(1))
//SE1->(DBGoTo(cTitu))   

	IF !Empty(SE1->E1_BOLETO)
		nNum:=padr(SE1->E1_BOLETO,8,'0' )
//	elseif !Empty(MV_PAR08)
//		nNum:=padr(MV_PAR08,8,'0' )
	Else		
			
		cQry:=" SELECT EE_FAXATU FROM "+retSqlName('SEE')
	cQry+=" WHERE EE_FILIAL='01'"
 //	cQry+=" AND EE_CODIGO='"+SE1->E1_PORTADO+"'"  -- Andre/rsac 19.01.2017
 //	cQry+=" AND EE_AGENCIA='"+SE1->E1_AGEDEP+"'" -- Andre/rsac 19.01.2017
 //	cQry+=" AND EE_CONTA ='"+SE1->E1_CONTA+"'"  -- Andre/rsac 19.01.2017
	cQry+=" AND EE_CODIGO='"+MV_PAR07+"'"
	cQry+=" AND EE_AGENCIA='"+MV_PAR08+"'"
	cQry+=" AND EE_CONTA ='"+MV_PAR09+"'"
	cQry+=" AND EE_SUBCTA='"+MV_PAR10+"'"   //Incluido -- Andre/Rsac 19.01.2017
	cQry+=" AND D_E_L_E_T_<>'*'"
	
			IF Select('TRBEE') <> 0
				TRBEE->(DBCloseArea())
			EndIF
			
			TcQuery cQry new Alias "TRBEE"
			nNum := StrZero(Val(TRBEE->EE_FAXATU)+1,8)//fazer programa para buscar de um txt	
				
	   	cQuery := "UPDATE  "+retSqlName('SEE')+" SET EE_FAXATU ='"+StrZero(Val(TRBEE->EE_FAXATU)+1,8)+"'"
	cQuery +=" WHERE EE_FILIAL='01'"
	//cQuery +=" AND EE_CODIGO='"+SE1->E1_PORTADO+"'"
	//cQuery +=" AND EE_AGENCIA='"+SE1->E1_AGEDEP+"'"
 	//cQuery  +=" AND EE_CONTA ='"+SE1->E1_CONTA+"'"
	cQry+=" AND EE_CODIGO='"+MV_PAR07+"'"
	cQry+=" AND EE_AGENCIA='"+MV_PAR08+"'"
	cQry+=" AND EE_CONTA ='"+MV_PAR09+"'"
	cQry+=" AND EE_SUBCTA='"+MV_PAR10+"'"   //Incluido -- Andre/Rsac 19.01.2017
	cQry+=" AND D_E_L_E_T_<>'*'"
		
	
		nErro := TCSQLExec(cQuery)

			RECLOCK("SE1",.F.)
				SE1->E1_BOLETO:= nNum
			SE1->(msUnlock())
								
	EndIf

RestArea(aAreaSE1)
RestArea(aAreaSEE)

return StrZero(Val(nNum),8)


//============================= CRIA PERGUNTAS =============================//
Static Function fCriaPerg(cPerg)

PutSX1(cPerg, "01", "Prefixo de"  , "", "", "mv_ch1", "C", TAMSX3("E1_PREFIXO")[1] , 0, 0, "G", "",       , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Prefixo ate" , "", "", "mv_ch2", "C", TAMSX3("E1_PREFIXO")[1] , 0, 0, "G", "",       , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "Numero de"   , "", "", "mv_ch3", "C", TAMSX3("E1_NUM")[1]     , 0, 0, "G", "",       , "", "", "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "Numero ate"  , "", "", "mv_ch4", "C", TAMSX3("E1_NUM")[1]     , 0, 0, "G", "",       , "", "", "mv_par04", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "05", "Banco"       , "", "", "mv_ch5", "C", TAMSX3("E1_PORTADO")[1] , 0, 0, "G", "", "SA6" , "", "", "mv_par05", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "06", "Agencia"     , "", "", "mv_ch6", "C", TAMSX3("E1_AGEDEP")[1]  , 0, 0, "G", "",       , "", "", "mv_par06", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "07", "Conta"       , "", "", "mv_ch7", "C", TAMSX3("E1_CONTA")[1]   , 0, 0, "G", "",       , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "08", "Boleto"      , "", "", "mv_ch8", "C", TAMSX3("E1_BOLETO")[1]   , 0, 0, "G", "",       , "", "", "mv_par08", "","","","","","","","","","","","","","","","")
//PutSX1(cPerg, "08", "Bordero"     , "", "", "mv_ch8", "C", TAMSX3("E1_NUMBOR")[1]  , 0, 0, "G", "",       , "", "", "mv_par08", "","","","","","","","","","","","","","","","")

Return



Static Function Mod11CB(cData)

LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
nSub:= 11 - mod(D,11)

if nsub==0 .or.nsub > 9 
	Dv:=1
Else
	Dv:=nsub
EndIF
  
Return(Dv)

