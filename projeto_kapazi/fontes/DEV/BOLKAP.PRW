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
+------------------+-----------------------------------	----------------------+
!Descricao         ! Chamada de impressão dos boletos  banco Itau/Banco BB.  !
+------------------+---------------------------------------------------------+
!Autor             ! Rodrigo Slisinski									     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/06/2013                                              !
+------------------+---------------------------------------------------------+
*/
//Alteração -- 04.08.2017 -- Adequação do fonte para novo processo de geração de cnab
//Realizado validação no ambiente compilar -- 09.08.2017 -- Andre/Rsac
//alterações pra ajustar layout do boleto para o banco BB -- Andre-rsac -- 03.10.2017
//Ajustes na geração do nosso numero para o banco BB -- 06.10.2017 
// Alterado o modo de busca do titulo, sem a necessidade do usuario preencher od dados bancarios -- Andre/Rsac -- 27.11.2017
// Validação para versão P12 -- Andre/Rsac  -- 03.01.2017
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BOLKAP()

	Local lRet := .F.

	Private aBord     := {}
	Private aTitulo   := {}
	Private oBoleto
	Private nSaltLn   := 80
	Private nLinDados := 30
	Private nLin      := 5000
	Private lPrimPag  := .T.
	Private nPag      := 0
	Private cPerg     := PADR("BOLKAP",10)
	Private cNomeBCO := "" // Incluido 04.09.2017 -- Andre/rsac

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

	fCriaPerg(cPerg)
	If Pergunte(cPerg,.T.)
		//	If Empty(MV_PAR05) .OR. Empty(MV_PAR06) .OR. Empty(MV_PAR07)
		//		MsgStop("Favor preencher os dados referente ao banco")
		//	Else
		Processa( { || fSelTitulo() }, "[BOLKAP] - AGUARDE")
		//EndIf
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
	Private aCB_RN_NN    := {}
	Private nRec      := 0
	Private _nVlrAbat := 0
	Private lPrint := .F.
	pRIVATE _cNossonuM :=""
	Private aDadosEmp    := {SM0->M0_NOMECOM                                  ,; //Nome da Empresa
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
	oPrint:SetPortrait()
	oPrint:StartPage()

	Private aImprime := {}

	DEFAULT cInstr := NIL

	ProcRegua(Len(aTitulo))
	For Yi:=1 To Len(aTitulo)

		If !aTitulo[Yi,1]
			Loop
		EndIf

		dbSelectArea("SE1")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("SE1")+aTitulo[Yi,2]+aTitulo[Yi,3]+aTitulo[Yi,4]+aTitulo[Yi,5])
			Loop
		EndIf
		If !Empty(SE1->E1_NUMBOR) .AND. Empty(SE1->E1_NUMBCO)
			Aviso("Atenção","O titulo número: "+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+CHR(13)+CHR(10)+ "Pertence a carteira 112 "+CHR(13)+CHR(10)+ "Para impressão favor acessar portal do BANCO!",{"OK"},2,"Atencao",,'lgrl01.bmp',.t.,,1)
			Loop
		EndIF

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			Loop
		EndIf

		DbSelectArea("SEE")
		DbSetOrder(1)
		If !DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
			Alert("Banco, Agencia ou Conta não encontrado nos Parametros de Bancos")
			Return
		EndIf


//	Do Case
//		Case !MV_PAR05 $  "341,001" //MV_PAR05 == "341" .OR. MV_PAR05 == "001" 
		//			ALERT("banco nao configurado para impressao de boletos!")
//		Case MV_PAR05 == "341"  .OR. MV_PAR05 == "001"
		Processa({ ||  boleto_() },"[BOLKAP] - AGUARDE")  // alterado nome da função de bolitau para boleto_ -- Andre/Rsac 04.09.2017
//	EndCase


	Next Yi

	oPrint:Preview()

Return

Static Function boleto_

	nMulta := 0.02 * SE1->E1_VALOR
	xMDia    := (0.058 * SE1->E1_SALDO)/30
	If SE1->E1_PORTADOR = '422'
		aBolText := {"APOS O VENCIMENTO COBRAR MULTA DE R$ "+ alltrim(transform(nMulta,")@E 999,999,999.99")) +" MAIS MORA DE R$"+alltrim(transform((SE1->E1_SALDO*SA1->A1_PORCJUR)/100,"@E 999,999,999.99"))+" AO DIA" ,;  //SE1->E1_SALDO*SE1->E1_PORCJUR)/100,
		"SUJEITO A PROTESTO APOS O VENCIMENTO",;  //25/08/2016 -- "DEVOLVER EM "+DTOC(SE1->E1_VENCTO+30),;
			"",;
			""}
	Else
		aBolText := {"APOS O VENCIMENTO COBRAR MULTA DE R$ "+ alltrim(transform(nMulta,")@E 999,999,999.99")) +" MAIS MORA DE R$"+alltrim(transform((SE1->E1_SALDO*SA1->A1_PORCJUR)/100,"@E 999,999,999.99"))+" AO DIA" ,;  //SE1->E1_SALDO*SE1->E1_PORCJUR)/100,
		"PROTESTAR APOS 05 DIAS ÚTEIS",;  //25/08/2016 -- "DEVOLVER EM "+DTOC(SE1->E1_VENCTO+30),;
			"",;
			""}
	EndIf

//DbSelectArea("TRA")
//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)// filial+ banco + agencia + conta
//DbSeek(xFilial()+MV_PAR05+MV_PAR06+MV_PAR07,.T.)
	DbSeek(xFilial()+SE1->E1_PORTADOR+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)



// Incluido para contemplar banco do Brasil  -- 04.09./2017
	if SE1->E1_PORTADOR == '341' //MV_PAR05 == '341'
		cNomeBCO:= "Banco Itaú SA"
	ELSEIF SE1->E1_PORTADOR == '001'//MV_PAR05 == '001'
		cNomeBCO:= "Banco do Brasil"
	ELSEIF SE1->E1_PORTADOR == '085'//MV_PAR05 == '001'
		cNomeBCO:= "Banco Viacredi"
	ELSEIF SE1->E1_PORTADOR == '422'//MV_PAR05 == '001'//jair 16/04/2021
		cNomeBCO:= "Banco Safra"
	endif
//fim 

	xDac := ''
	aDadosBanco  := {SA6->A6_COD                       ,;   //Numero do Banco
	cNomeBCO                                         ,;   //Nome do Banco
	SUBSTR(SA6->A6_AGENCIA, 1, 5)                    ,;   //Agência
	SA6->A6_NUMCON                                   ,;   //Conta Corrente
	"2"                                              ,;   //Carteira
	SA6->A6_COD                                       }   //Codigo no SA6

	IF SE1->E1_PORTADOR == '085'//MV_PAR05 == '001'
		aDadosBanco  := {SA6->A6_COD                       ,;   //Numero do Banco
		cNomeBCO                                         ,;   //Nome do Banco
		SUBSTR(alltrim(SA6->A6_AGENCIA)+alltrim(SA6->A6_DVAGE), 1, 5)                    ,;   //Agência
		SA6->(alltrim(A6_NUMCON)+alltrim(A6_DVCTA))                                   ,;   //Conta Corrente
		"2"                                              ,;   //Carteira
		SA6->A6_COD                                       }   //Codigo no SA6

	ElseIf	SE1->E1_PORTADOR == '422'
		aDadosBanco  := {SA6->A6_COD                       ,;   //Numero do Banco
		cNomeBCO                                         ,;   //Nome do Banco
		SUBSTR(alltrim(SA6->A6_AGENCIA)+alltrim(SA6->A6_DVAGE), 1, 5)                    ,;   //Agência
		SA6->(alltrim(A6_NUMCON)+alltrim(A6_DVCTA))                                   ,;   //Conta Corrente
		"1"                                              ,;   //Carteira
		SA6->A6_COD                                       }   //Codigo no SA6
	endif

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
	_cNossonuM := strzero(val(SE1->E1_NUMBCO),10)
	_cNossonuM:= ALLTRIM(SEE->EE_CODEMP)+_cNossonuM

	if adadosbanco[1] == '341'
		CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3)+"9" , aDadosBanco[3] , aDadosBanco[4] ,;
			aDadosBanco[5],AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),(SE1->E1_SALDO-_nVlrAbat),aDadosBanco[6],DTOS(SE1->E1_VENCREA),SE1->E1_PREFIXO )

	elseif  adadosbanco[1] == '001'
		CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3)+"9" , aDadosBanco[3] , aDadosBanco[4] ,;
			aDadosBanco[5],AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),(SE1->E1_SALDO-_nVlrAbat),"17",DTOS(SE1->E1_VENCREA),SE1->E1_PREFIXO )

	/*CB_RN_NN    :=Ret_cBarr1(	SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA	,SE1->E1_TIPO	,;
		Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[4] ,aDadosBanco[5]	,;
		_cNossonuM		,(SE1->E1_VALOR-_nVlrAbat)	, "17"	,"9" ,alltrim(SEE->EE_CODEMP)	)  */
	elseif  adadosbanco[1] == '085'

		_cNossonuM := strzero(val(AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)),9)     

		CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3) , aDadosBanco[3] , aDadosBanco[4] ,;
		aDadosBanco[5],strzero(val(AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)),9),(SE1->E1_SALDO-_nVlrAbat),"17",DTOS(SE1->E1_VENCREA),SE1->E1_PREFIXO )
	elseif  adadosbanco[1] == '422'//jair 16/04/2021

		_cNossonuM := strzero(val(AllTrim(SE1->E1_NUM)),9)     

		CB_RN_NN  := Ret_cBarra( Subs(aDadosBanco[1],1,3) , aDadosBanco[3] , aDadosBanco[4] ,;
		aDadosBanco[5],strzero(val(AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)),9),(SE1->E1_SALDO-_nVlrAbat),"17",DTOS(SE1->E1_VENCREA),SE1->E1_PREFIXO )
	
	
	endif

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

 //03.10.2017 -- Andre/Rsac
local cLogoItau	:= "\system\logoitau2.bmp"
local cLogoBB	:= "\system\logoBB.bmp"
local cLogoVia	:= "\system\logoVia.bmp"
local cLogoSafra:= "\system\logosafra.bmp"



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
	xCarteira   := '01' 
	ElseIF SuBStr(aDadosBanco[1],1,3) == '001' //  bb
	_cNN        := aDadosTit[6]
	xCarteira   := '17'	
	
	ElseIF SuBStr(aDadosBanco[1],1,3) == '085' //  bb
	_cNN        := aDadosTit[6]
	xCarteira   := '21'	
	
	EndIF


//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
/*oFont8   := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont09  := TFont():New("Arial",9,9 ,.T.,.F.,5,.T.,5,.T.,.F.)

oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.) */  

 oFont8   := TFont():New("Arial",9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
 oFont10  := TFont():New("Arial",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
 oFont09  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)

 oFont14  := TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
 oFont16  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
 oFont16n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
 oFont24  := TFont():New("Arial",9,23,.T.,.T.,5,.T.,5,.T.,.F.)

//oBrush := TBrush():New("",4)

oPrint:StartPage()   // Inicia uma nova página

	if SE1->E1_PORTADOR  == '341' //mv_par05 == '341'
		if File(cLogoItau)
		oPrint:SayBitmap( 50, 100, cLogoItau, 280, 83)
		else
		oPrint:Say  (50, 100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '001' //mv_par05 == '001' //incluido Andre/Rsac -- 04.09.2017
		if File(cLogoBB)
		oPrint:SayBitmap(50, 100, cLogoBB, 410, 85)
		else
		oPrint:Say  (50,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '085' //mv_par05 == '001' //incluido Andre Sakai
		if File(cLogoVia)
		oPrint:SayBitmap(50, 100, cLogoVia, 200, 98)
		else
		oPrint:Say  (50,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '422' //mv_par05 == '001' //incluido Jair Andrade
		if File(cLogoSafra)
		oPrint:SayBitmap(50, 100, cLogoSafra, 200, 98)
		else
		oPrint:Say  (50,  100, aDadosBanco[2]				, oFont16)
		endif
	endif // fim

//Primeira Via
oPrint:Line (150,100,150,2300)
oPrint:Line (150,550,50,550)
oPrint:Line (150,800,50,800)
//oPrint:Say  (50,100,aDadosBanco[2]                                   ,oFont16)
	if SE1->E1_PORTADOR == '422'
oPrint:Say  (70,580,aDadosBanco[1]+'-7'                               ,oFont16)
	Else
oPrint:Say  (70,580,aDadosBanco[1]                                   ,oFont16)
	EndIf
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
//Alteracao para contemplar boleto do BB -- 04.09.2017 -- Andre/Rsac	
	ElseIF SuBStr(aDadosBanco[1],1,3) == '001'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BANCO DO BRASIL"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO BANCO DO BRASIL
	cMSg3 := ''
//fim		
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
	cMsg1 := "PAGÁVEL EM QUALQUER BANCO DO SISTEMA DE COMPENSAÇÃO"
	cMsg2 := ""
	cMSg3 := ''
	ElseIF SuBStr(aDadosBanco[1],1,3) == '655'
	cMsg1 := "ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BANCO BV"
	cMsg2 := "APÓS O VENCIMENTO, SOMENTE NO BANCO BV"
	cMSg3 := ''
	ElseIF SuBStr(aDadosBanco[1],1,3) == '085'
	cMsg1 := "PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DO SISTEMA AILOS"
	cMsg2 := "                                                           "
	cMSg3 := ''
	EndIF
oPrint:Say  (150,100 ,"Local de Pagamento"                           ,oFont8)
oPrint:Say  (150,400 ,cMsg1                                          ,oFont10)
oPrint:Say  (185,400 ,cMsg2                                          ,oFont10)
oPrint:Say  (220,400 ,cMsg3                                          ,oFont10)

oPrint:Say  (150,1910,"Vencimento"                                   ,oFont8)
oPrint:Say  (175,2120,alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10)

oPrint:Say  (220,1910,"Agência/Código Beneficiário" ,oFont8)
	if(SE1->E1_PORTADO=='085')
	oPrint:Say  (245,2085,substr(aDadosBanco[3],1,4)+'-' + substr( aDadosBanco[3],5,1)+'' +"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	else
	oPrint:Say  (245,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	endif
//oPrint:Say  (245,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10,10,,,2)

oPrint:Say  (220,100 ,"Beneficiário"                                       ,oFont8)
oPrint:Say  (245,100 ,aDadosEmp[1]                                    ,oFont10)


oPrint:Say  (220,1355,"CNPJ/CPF"                                      ,oFont8)
oPrint:Say  (245,1455,aDadosEmp[6]                                    ,oFont10)

oPrint:Say  (290,100 ,"Endereço Beneficiário"                                ,oFont8)
oPrint:Say  (317,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999"))   ,oFont10)



oPrint:Say  (290,1910,"Nosso Número"                                  ,oFont8)
	IF SE1->E1_PORTADOR == '341' //mv_par05 == '341'
oPrint:Say  (315,2140,alltrim(_cNN)                                    ,oFont10,10,,,2)
	elseif  SE1->E1_PORTADOR == '001' //mv_par05 == '001'
oPrint:Say  (315,2040,alltrim(_cNossonuM)                ,oFont10)
	elseif  SE1->E1_PORTADOR == '085' //mv_par05 == '001'
oPrint:Say  (315,2040,alltrim("11390247"+_cNN)                                    ,oFont10,10)
	elseif  SE1->E1_PORTADOR == '422' //mv_par05 == '001'
oPrint:Say  (315,2040,alltrim(_cNN)                                    ,oFont10,10)
	endif
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

	If SE1->E1_PORTADOR $ "341|001|085|422" //MV_PAR05=='341'
	oPrint:Say(520,150, aBolText[1], oFont10)
	oPrint:Say(570,150, aBolText[2], oFont10)
	oPrint:Say(620,150, aBolText[3], oFont10)
	oPrint:Say(690,150, aBolText[4], oFont10)
	EndIf

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

oPrint:Say  (922,100 ,"Sacador/Avalista"                                ,oFont8)
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
 	oPrint:Line( 1060, i, 1060, i+30)
	Next i

	if SE1->E1_PORTADOR == '341' //mv_par05 == '341'
		if File(cLogoItau)
		oPrint:SayBitmap( 1080, 100, cLogoItau, 280, 83)
		else
		oPrint:Say  (1080, 100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '001' //mv_par05 == '001' //incluido Andre/Rsac -- 04.09.2017
		if File(cLogoBB)
		oPrint:SayBitmap(1080, 100, cLogoBB, 410, 85)
		else
		oPrint:Say  (1080,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '085' //mv_par05 == '001' //incluido Andre/Rsac -- 04.09.2017
		if File(cLogoVia)
		oPrint:SayBitmap(1080, 100, cLogoVia, 200, 98)
		else
		oPrint:Say  (1080,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '422' //mv_par05 == '001' //incluido Jair Andrade
		if File(cLogoSafra)
		oPrint:SayBitmap(1080, 100, cLogoSafra, 200, 98)
		else
		oPrint:Say  (1080,  100, aDadosBanco[2]				, oFont16)
		endif
	endif // fim
 
//Segunda Via
oPrint:Line (1180,100,1180,2300)
oPrint:Line (1180,550,1080,550)
oPrint:Line (1180,800,1080,800)

//oPrint:Say  (1080,100,aDadosBanco[2]                                    ,oFont16)
	if SE1->E1_PORTADOR == '422'
oPrint:Say  (1100,580,aDadosBanco[1]+'-7'                                  ,oFont16)
	Else
oPrint:Say  (1100,580,aDadosBanco[1]                                    ,oFont16)
	EndIf
oPrint:Say  (1100,820,CB_RN_NN[2]                                 ,oFont14)


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
//oPrint:Say  (1275,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10)
//oPrint:Say  (1275,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ),oFont10,10,,,2)
	if(SE1->E1_PORTADO=='085')
	oPrint:Say  (1275,2085,substr(aDadosBanco[3],1,4)+'-' + substr( aDadosBanco[3],5,1)+'' +"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	else
	oPrint:Say  (1275,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	endif

oPrint:Say  (1250,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (1275,100 ,aDadosEmp[1]                                     ,oFont10)

oPrint:Say  (1250,1355,"CNPJ/CPF"					                    ,oFont8)
oPrint:Say  (1275,1455,aDadosEmp[6]		                                ,oFont10)

oPrint:Say  (1320,100 ,"Endereço Beneficiário"                                        ,oFont8)
oPrint:Say  (1347,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999")) ,oFont10)


oPrint:Say  (1320,1910,"Nosso Número"                                   ,oFont8)
	IF SE1->E1_PORTADOR == '341' //mv_par05 == '341'
oPrint:Say  (1345,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)
	ELSEIF SE1->E1_PORTADOR == '001'  //mv_par05 == '001'
oPrint:Say  (1345,2040,alltrim(_cNossonuM)                                    ,oFont10)
	elseif  SE1->E1_PORTADOR == '085' //mv_par05 == '001'
oPrint:Say  (1345,2040,alltrim("11390247"+_cNN)         ,oFont10,10)
	elseif  SE1->E1_PORTADOR == '422'
oPrint:Say  (1345,2040,alltrim(_cNN)         ,oFont10,10)
	ENDIF
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

	If SE1->E1_PORTADOR $ "341|001|085|422" //MV_PAR05=='341'
	oPrint:Say(1550, 150, aBolText[1], oFont10)
	oPrint:Say(1600, 150, aBolText[2], oFont10)
	oPrint:Say(1650, 150, aBolText[3], oFont10)
	oPrint:Say(1700, 150, aBolText[4], oFont10)
	EndIf

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

oPrint:Say  (1952,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (1952,2000 ,"Código de Baixa"                               ,oFont8)

oPrint:Say  (1992,1900,"Autenticação Mecânica"                          ,oFont8)

oPrint:Line (1180,1900,1800,1900 )
oPrint:Line (1590,1900,1590,2300 )
oPrint:Line (1660,1900,1660,2300 )
oPrint:Line (1730,1900,1730,2300 )
oPrint:Line (1800,100,1800,2300 )

oPrint:Line (1987,100,1987,2300  ) 
nAjust:=150 //150 -- 03.10.2017
//Gambiarra, descobrir como mudar tipo da linha.
	For i := 100 to 2300 step 50
   //	oPrint:Line(2213-nAjust, i, 2213-nAjust, i+30)
	Next i

	if SE1->E1_PORTADOR == '341' //mv_par05 == '341'
		if File(cLogoItau)
		oPrint:SayBitmap( 2263-nAjust, 100, cLogoItau, 280, 83)
		else
		oPrint:Say  (2263-nAjust, 100, aDadosBanco[2]				, oFont16)
		endif                                                                RSAC
	elseif SE1->E1_PORTADOR == '001' //mv_par05 == '001' //incluido Andre/Rsac -- 04.09.2017
		if File(cLogoBB)
		oPrint:SayBitmap(2263-nAjust, 100, cLogoBB, 410, 85)
		else
		oPrint:Say  (2263-nAjust,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '085' //mv_par05 == '001' //incluido Andre/Rsac -- 04.09.2017
		if File(cLogoVia)
		oPrint:SayBitmap(2263-nAjust, 100, cLogoVia, 200, 98)
		else
		oPrint:Say  (2263-nAjust,  100, aDadosBanco[2]				, oFont16)
		endif
	elseif SE1->E1_PORTADOR == '422' //mv_par05 == '001' //incluido Jair Andrade
		if File(cLogoSafra)
		oPrint:SayBitmap(2263-nAjust, 100, cLogoSafra, 200, 98)
		else
		oPrint:Say  (2263-nAjust,  100, aDadosBanco[2]				, oFont16)
		endif
	endif // fim

//Inicio da ultima via
oPrint:Line (2363-nAjust,100,2363-nAjust,2300)
oPrint:Line (2363-nAjust,550,2263-nAjust,550 )
oPrint:Line (2363-nAjust,800,2263-nAjust,800 )

//oPrint:Say  (2263-nAjust,100,aDadosBanco[2],oFont16 )
	if SE1->E1_PORTADOR == '422'
oPrint:Say  (2283-nAjust,587,aDadosBanco[1]+'-7',oFont16 )
	Else
oPrint:Say  (2283-nAjust,587,aDadosBanco[1],oFont16 )
	EndIf
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
	if(SE1->E1_PORTADO=='085')
	oPrint:Say  (2458-nAjust,2085,substr(aDadosBanco[3],1,4)+'-' + substr( aDadosBanco[3],5,1)+'' +"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	else
	oPrint:Say  (2458-nAjust,2085,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIF( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
	endif


oPrint:Say  (2433-nAjust,100 ,"Beneficiário"                                        ,oFont8)
oPrint:Say  (2458-nAjust,100 ,aDadosEmp[1]                                    ,oFont10)

oPrint:Say  (2433-nAjust,1355,"CNPJ/CPF"					                             ,oFont8)
oPrint:Say  (2458-nAjust,1455,aDadosEmp[6]		                                 ,oFont10)

oPrint:Say  (2503-nAjust,100 ,"Endereço Beneficiário"                                        ,oFont8)
oPrint:Say  (2530-nAjust,100 ,alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999")) ,oFont10)


oPrint:Say  (2503-nAjust,1910,"Nosso Número"                                   ,oFont8)
	IF SE1->E1_PORTADOR == '001' //mv_par05 == '001'
oPrint:Say  (2528-nAjust,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)
	ELSEIF SE1->E1_PORTADOR == '341' //mv_par05 == '341'
oPrint:Say  (2528-nAjust,2040,alltrim(_cNossonuM)                                    ,oFont10,10)
	ELSEIF  SE1->E1_PORTADOR == '085' //mv_par05 == '001'
oPrint:Say  (2528-nAjust,2040,alltrim("11390247"+_cNN)         ,oFont10,10)
	ELSEIF  SE1->E1_PORTADOR == '422' //mv_par05 == '001'
oPrint:Say  (2528-nAjust,2040,alltrim(_cNN)         ,oFont10,10)
	ENDIF


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

	If SE1->E1_PORTADOR $ "341|001|085|422" //MV_PAR05=='341'
	oPrint:Say(2733-nAjust, 150, aBolText[1], oFont10)
	oPrint:Say(2783-nAjust, 150, aBolText[2], oFont10)
	oPrint:Say(2833-nAjust, 150, aBolText[3], oFont10)
	oPrint:Say(2893-nAjust, 150, aBolText[4], oFont10)
	EndIf

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

oPrint:Say  (3135-nAjust,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (3135-nAjust,2000 ,"Código de Baixa"                               ,oFont8)

oPrint:Say  (3175-nAjust,1400,"Autenticação Mecânica - Ficha de Compensação"   ,oFont8)

oPrint:Line (2363-nAjust,1900,2983-nAjust,1900 )
oPrint:Line (2773-nAjust,1900,2773-nAjust,2300 )
oPrint:Line (2843-nAjust,1900,2843-nAjust,2300 )
oPrint:Line (2913-nAjust,1900,2913-nAjust,2300 )
oPrint:Line (2983-nAjust,100,2983-nAjust,2300 )
oPrint:Line (3170-nAjust,100,3170-nAjust,2300  )
//MSBAR("INT25",26.0,1.6,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660
MSBAR("INT25",27.2,1.2,CB_RN_NN[1],oPrint,.F.,,,,1.8,,.t.,,.F.)
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
//cQuery += "AND (E1_PORTADO = '' OR (E1_PORTADO = '" + MV_PAR05 + "' AND E1_AGEDEP = '" + MV_PAR06 + "' AND E1_CONTA = '" + MV_PAR07 + "')) " - -Comentado para teste Andre/Rsac  04.09.2017
cQuery += "AND E1_VALBCO = 'S' "  // Campo é preechido ao ler o retorno do cnab pelo P.E FA200_02 -- Andre/Rsac 04.08.2017

/*
  // valida se o campo existe
	IF SF2->( FieldPos("F2_K_USRCO") ) > 0
		if substr(Alltrim(cValToChar(mv_par05)),1,1) == "1"
			If SF2->( FieldPos("F2_XIDVNFK")) > 0 .and.  SE1->( FieldPos("E1_XIDVNFK")) > 0
		  	cQuery += " 	  and EXISTS ( select * FROM "+RetSQLName("SF2")+" F2 where ((F2_DUPL = E1_NUM and F2.D_E_L_E_T_ <> '*' and F2_CLIENTE = E1_CLIENTE and F2_FILIAL = '"+xFilial("SF2")+"' and F2_K_USRCO = '" + RetCodUsr() + "' ) OR ( F2_XIDVNFK = E1_XIDVNFK and F2.D_E_L_E_T_ <> '*' and F2_CLIENTE = E1_CLIENTE and F2_FILIAL = '"+xFilial("SF2")+"' and F2_K_USRCO = '" + RetCodUsr() + "')  )  "
			else
		  	cQuery += " 	  and EXISTS ( select * FROM "+RetSQLName("SF2")+" F2 where F2_DUPL = E1_NUM and F2.D_E_L_E_T_ <> '*' and F2_CLIENTE = E1_CLIENTE and F2_FILIAL = '"+xFilial("SF2")+"' and F2_K_USRCO = '" + RetCodUsr() + "' )  "
			EndIf
		EndIf
	EndIf
*/
	cQuery := ChangeQuery(cQuery)
	cQuery += " ORDER BY 1,2,3 "

	If ( SELECT("TRB") ) > 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf

//cQuery := ChangeQuery(cQuery)

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
		ApMsgAlert("Boleto ainda não processado, favor entrar em contato com setor financeiro")
		Return
	EndIf

	DEFINE MSDIALOG oDlgTit TITLE "[BOLKAP] - Impressão de Boleto de Cobrança" From 001,001 to 380,615 Pixel

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
		Processa( { || fImprime() },"[BOLKAP] - AGUARDE" )
	EndIf

Return

//============================ Inverte a seleção ============================//
Static Function fSelectAll()

	For i:=1 to Len(aTitulo)
		aTitulo[i,1] := !aTitulo[i,1]
	Next i

	oBrwTit:Refresh()

Return


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

	If SuBStr(cBanco,1,3) == '341'
		NN := u_nBCO(SE1->E1_NUM, SE1->E1_PARCELA)
		(SE1->E1_NUM, SE1->E1_PARCELA)
	EndIf

	If SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
		NN := u_nBCO(SE1->E1_NUM, SE1->E1_PARCELA)
	EndIf

	If SuBStr(cBanco,1,3) == '085' // Incluido 04.09.2017 -- Andre Sakai
		//NN := u_nBCO(SE1->E1_NUM, SE1->E1_PARCELA)
		NN:=STRZERO(VAL(cNroDoc),9)
	EndIf
	If SuBStr(cBanco,1,3) == '422' // Incluido 16.04.2021 -- Jair Andrade
		NN:=STRZERO(VAL(cNroDoc),9)
	EndIf

	IF SuBStr(cBanco,1,3) == '341' //.OR. SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
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
		s := SubStr(NN, 3, 7)          +Alltrim(Str(dvnn))  + SubStr(cAgencia, 1, 3)
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
//EndIf  

	elseif SuBStr(cBanco,1,3) == '001'
		s:= AllTrim(cAgencia) + SubStr(alltrim(cConta),1,5) + "17" + SubStr(alltrim(NN),1,8) // incluido em 19/02/03
		dvnn :=   modulo10(s)

		s := cBanco + Alltrim(Str(_nFator)) + blvalorfinal + "17" + SubStr(alltrim(NN),1,8)+Alltrim(Str(dvnn)) +AllTrim(cAgencia) + SubStr(alltrim(cConta),1,6) + "000"


		dvcb := str(Mod11CB(s))
		CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)
		//_cCodBar			:=	'237'+'9'+_cNumDv+fator+strzero(ROUND(_nSaldo,2)*100,10)+_cAgConv+'0911'+_cNossoNum+_cFxConv+'00589010'

		// Linha digitavel
		//   banco+ moeda   carteira    2 primeiros digitos do nosso numero
		s := cBanco       + "17"     + SubStr(NN, 1, 2) //01 a 03 -- Código do Banco na Câmara de Compensação = ‘001’
		dv := modulo10(s) //04 a 04 -- Código da Moeda = '9'
		RN := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + ' ' //05 a 05 -- DV do Código de Barras (Anexo VI)

		//   Restante do nosso numero  DAC (NN)  3 pos. inic. agencia
		s := SubStr(NN, 3, 6)          +Alltrim(Str(dvnn))  + SubStr(cAgencia, 1, 3)
		dv := modulo10(s)
		RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + ' '

		//   Resto da agencia         conta                         dac conta
		s := SubStr(cAgencia, 4, 1) + SubStr(alltrim(cConta),1,6)+ "000"
		dv := modulo10(s)
		RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + ' ' //	RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + ' '

		RN := SUBSTR(RN,1,4)+AllTrim(dvcb)+Alltrim(Str(_nFator))+blvalorfinal+"000000"+ALLTRIM(SEE->EE_CODEMP)+PADL(nn,10,"0")+"17" //RN + AllTrim(dvcb) + ' '
		CB:= RN //Codigo barras -- 03.10.2017
		//20.10.2017 -- Andre/Rsac
		DVCampo1:=modulo10("001"+"9"+substr(CB,20,5))
		DVCampo2:=modulo10(substr(CB,25,1)+ALLTRIM(SEE->EE_CODEMP)+"00")
		DVCampo3:=modulo10(NN+"17")

		//Alteração para calculo do Digito Verificador do codigo de barras -- 05.12.2017 -- Andre/Rsac
		cNumDig10 := substr(CB,1,4)+ substr(CB,6,44)
		DVGERAL :=CalcDigM11(cNumDig10)
		// DVGERAL :=modulo11(substr(CB,1,4)+substr(CB,6,39)) // 24.11.2017 -- Inlcuido Andre-Rsac

		RN:= "001"+"9"+substr(CB,20,5)+ALLTRIM(STR(DVCampo1))+substr(CB,25,1)+ALLTRIM(SEE->EE_CODEMP)+"00"+AllTrim(STR(DVCampo2))+NN+"17"+alltrim(str(DVCampo3))+AllTrim(DVGERAL)+Alltrim(Str(_nFator))+blvalorfinal //"001"+"9"+substr(CB,20,5)+ALLTRIM(STR(DVCampo1))+substr(CB,25,1)+ALLTRIM(SEE->EE_CODEMP)+"00"+AllTrim(STR(DVCampo2))+NN+"17"+alltrim(str(DVCampo3))+"1"+Alltrim(Str(_nFator))+blvalorfinal
		RN := substr(RN,1,5)+"."+substr(RN,6,5)+" "+substr(RN,11,5)+" "+substr(RN,16,6)+" "+substr(RN,22,5)+"."+substr(RN,27,6)+" "+substr(RN,33,1)+" "+substr(RN,34,14)

		// Alteração 03.01.2017 -- Andre/rsac
		s := "001"+"9"+Alltrim(Str(_nFator))+blvalorfinal+"000000"+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,7)+strzero(VAL(NN),10)+"17" //+substr(cAgencia,1,4)+ STRZERO(val(cConta),8)
		dvcb := str(Mod11CB(s))
		CB := "001"+"9"+alltrim(dvcb)+Alltrim(Str(_nFator))+blvalorfinal+"000000"+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,7)+strzero(VAL(NN),10)+"17"    //Alltrim(Str(_nFator))+blvalorfinal+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,6)+ALLTRIM(STR(VAL(NN)))+substr(cAgencia,1,4)+ STRZERO(val(cConta),8)+"17"
		//Fim
		// monta o nosso numero com o digito verificador
		NN:= NN + "-" + Alltrim(Str(dvnn))

//_nNossonuM:= ALLTRIM(SEE->EE_CODEMP)+_nNossonuM
	Elseif(SuBStr(cBanco,1,3) == '085')
		cConta := STRZERO(VAL(ALLTRIM(SEE->EE_CONTA)+ALLTRIM(SEE->EE_DVCTA)),8)
		//3+1+4+10+6+8+9+1
		S := cBanco    +'9'  + Alltrim(Str(_nFator)) + blvalorfinal + alltrim(SEE->EE_CODEMP) + SubStr(alltrim(cConta),1,8) +SubStr(alltrim(NN),1,9) +'01'
		dvcb := CalcDigM11(s)
		CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)

		S1 := AllTrim(SEE->EE_CODIGO) //banco
		S1 += "9" // moeda
		S1 +=SUBSTR(SEE->EE_CODEMP,1,5) // numero do convenio
		dvnn1 :=  CVALTOCHAR(MODULO10(s1))

		S2 := SUBSTR(SEE->EE_CODEMP,6,1) // numero do convenio
		S2 += substr(cConta,1,8)
		S2 += SUBSTR(NN,1,1)
		dvnn2 := CVALTOCHAR(MODULO10(S2))


		S3 := SUBSTR(NN,2,8)
		S3 += "01" // carteira
		dvnn3 := CVALTOCHAR(MODULO10(S3))

//0859.101002.41139.024708.30132.902011.085680000074900
//08591.01008.41139.024701.30132.902013.185680000074900
		S:= S1 + dvnn1 + s2 + dvnn2 + s3 + dvnn3 + Alltrim(Str(_nFator)) + blvalorfinal
		dvnn := CVALTOCHAR(MODULO10(S))

		S :=   S1 + dvnn1 + s2 + dvnn2 + s3 + dvnn3 + dvnn + Alltrim(Str(_nFator)) + blvalorfinal
		RN := S

		//dvnn := cvaltochar(modulo10(NN))
		//NN:= NN + "-" + dvnn

	Elseif(SuBStr(cBanco,1,3) == '422')
		cConta := STRZERO(Val(cConta),9)
		//S := cBanco+'9'+'7'+cAgencia+SUBSTR(cAgencia,5,1) +(cConta) +(NN)+'2'+Alltrim(Str(_nFator)) + blvalorfinal
		S :=cBanco    +'9'  + Alltrim(Str(_nFator)) + blvalorfinal + '7'+cAgencia + cConta +SubStr(alltrim(NN),1,9) +'2'
		dvcb := CalcDigM11(s)
		CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)

		S1 := AllTrim(SEE->EE_CODIGO) //banco
		S1 += "9" // moeda
		S1 += "7" // 7 = dígito do Banco Safra
		S1 +=Alltrim(SUBSTR(SEE->EE_AGENCIA,1,4)) // numero da agencia
		dvnn1 :=  CVALTOCHAR(MODULO10(s1))

		S2 := STRZERO(Val(cConta),10)
		dvnn2 := CVALTOCHAR(MODULO10(S2))


		S3 := NN
		S3 += "2" // carteira
		dvnn3 := CVALTOCHAR(MODULO10(S3))

//0859.101002.41139.024708.30132.902011.085680000074900
//08591.01008.41139.024701.30132.902013.185680000074900
		S:= alltrim(S1) + dvnn1 + alltrim(s2) + dvnn2 + s3 + dvnn3 + Alltrim(Str(_nFator)) + blvalorfinal
		dvnn := CVALTOCHAR(MODULO10(S))

		S :=   S1 + dvnn1 + s2 + dvnn2 + s3 + dvnn3 + dvcb + Alltrim(Str(_nFator)) + blvalorfinal
		RN := S

		//dvnn := cvaltochar(modulo10(NN))
		//NN:= NN + "-" + dvnn
	EndIf
//fim - 30.10.2017


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


USER FUNCTION nBCO(cNum, cParc) //E1_NUMBCO

	LOCAL nNum     := ""
	LOCAL aAreaSE1 := SE1->(GetArea())
	LOCAL aAreaSEE := SEE->(GetArea())


	IF !Empty(SE1->E1_NUMBCO)
		nNum:=padr(SE1->E1_NUMBCO,8,'0' )
//Else



	EndIf

	RestArea(aAreaSE1)
	RestArea(aAreaSEE)

return StrZero(Val(nNum),8)


/*/
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³          ³ Autor ³                                    ³   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Calcula o Digito Verificador MOD11                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ DIGITO DO CODIGO DE BARRAS                                 ³±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION CalcDigM11(cNumDig10)
	LOCAL nCnt   := 0,;
		cDigito  := 0,;
		nSoma  := 0,;
		nBase  := 0,;
		aPeso  := {9,8,7,6,5,4,3,2};

	nBase := Len(aPeso)+1

	FOR nCnt := Len(cNumDig10) TO 1 STEP -1
		nBase := IF(--nBase = 0,Len(aPeso),nBase)
		nSoma += Val(SUBS(cNumDig10,nCnt,01)) * aPeso[ nBase ]
	NEXT

	cDigito := 11 - (nSoma % 11)

	DO CASE
	CASE cDigito = 0
		cDigito := "1"
	CASE cDigito > 9
		cDigito := "1"
	OTHERWISE
		cDigito := STR( cDigito, 1, 0 )
	ENDCASE
RETURN(cDigito)

//============================= CRIA PERGUNTAS =============================//
Static Function fCriaPerg(cPerg)

	// variáveis auxiliares
	local cIndice := "00"
	local cVarCh := "mv_ch0"
	local cVarPar := "mv_par00"
	local cIdx0 := "0"
	local aParPerg := {}
	/* aParPerg[]
	     aParPerg[n][01] : nome da pergunta
	     aParPerg[n][02] : descrição
     	aParPerg[n][03] : tipo
     	aParPerg[n][04] : tamanho
     	aParPerg[n][05] : decimais
     	aParPerg[n][06] : indice de pre selecao de combo
     	aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )
     	aParPerg[n][08] : rotina de validação do SX1
     	aParPerg[n][09] : F3
     	aParPerg[n][10] : grupo de perguntas
     	aParPerg[n][11] : item 1 do combo
     	aParPerg[n][11] : item 2 do combo
     	aParPerg[n][11] : item 3 do combo
     	aParPerg[n][11] : item 4 do combo
     	aParPerg[n][11] : item 5 do combo
     	aParPerg[n][12] : array de help */

/*
PutSX1(cPerg, "01", "Prefixo de"  , "", "", "mv_ch1", "C", TAMSX3("E1_PREFIXO")[1] , 0, 0, "G", "",       , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Prefixo ate" , "", "", "mv_ch2", "C", TAMSX3("E1_PREFIXO")[1] , 0, 0, "G", "",       , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "Numero de"   , "", "", "mv_ch3", "C", TAMSX3("E1_NUM")[1]     , 0, 0, "G", "",       , "", "", "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "Numero ate"  , "", "", "mv_ch4", "C", TAMSX3("E1_NUM")[1]     , 0, 0, "G", "",       , "", "", "mv_par04", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "05", "Filtra suas notas?"  , "", "", "mv_ch5", "N", 1     , 0, 2, "C", "",       , "", "", "mv_par05", "Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","")
//PutSX1(cPerg, "05", "Banco"       , "", "", "mv_ch5", "C", TAMSX3("E1_PORTADO")[1] , 0, 0, "G", "", "SA6" , "", "", "mv_par05", "","","","","","","","","","","","","","","","")
//PutSX1(cPerg, "06", "Agencia"     , "", "", "mv_ch6", "C", TAMSX3("E1_AGEDEP")[1]  , 0, 0, "G", "",       , "", "", "mv_par06", "","","","","","","","","","","","","","","","")
//PutSX1(cPerg, "07", "Conta"       , "", "", "mv_ch7", "C", TAMSX3("E1_CONTA")[1]   , 0, 0, "G", "",       , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
*/


// cria as perguntas do array
	AAdd(aParPerg, {cPerg, "Prefixo de", "C", TAMSX3("E1_PREFIXO")[1], TAMSX3("E1_PREFIXO")[2], 0, "G", "", "SF2", "", "", "", "", Nil, Nil, {"Informe Prefixo inicial"}})
	AAdd(aParPerg, {cPerg, "Prefixo ate", "C", TAMSX3("E1_PREFIXO")[1], TAMSX3("E1_PREFIXO")[2], 0, "G", "", "SF2", "", "", "", "", Nil, Nil, {"Informe Prefixo final"}})
	AAdd(aParPerg, {cPerg, "Numero de", "C", TAMSX3("E1_NUM")[1], TAMSX3("E1_NUM")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe Numero inicial"}})
	AAdd(aParPerg, {cPerg, "Numero ate", "C", TAMSX3("E1_NUM")[1], TAMSX3("E1_NUM")[2], 0, "G", "", "", "", "", "", "", Nil, Nil, {"Informe Numero final"}})
	AAdd(aParPerg, {cPerg, "Filtra suas notas?", "N", 1, 0, 1, "C", "", "", "", "Sim", "Não", "", Nil, Nil, {"Filtra as notas emitidas pelo seu usuário?"}})

// inicializa as variaveis
	cIndice := "00"
	cIdx0 := "0"
	cVarCh := "mv_ch0"
	cVarPar := "mv_par00"

	// inicializa a barra de progressos
	ProcRegua(Len(aParPerg))

	// loop sobre os parametros a adicionar
	for nI := 1 to Len(aParPerg)

		// incrementa os contadores
		cIndice := soma1(cIndice)
		cIdx0 := soma1(cIdx0)
		cVarCh := "mv_ch" + cIdx0
		cVarPar := "mv_par" + cIndice

		// incrementa a barra de progressos
		IncProc("Criando perguntas " + allTrim(cIndice) + "/" + StrZero(Len(aParPerg), 2) + "..." )

		// adiciona o parametro
		xPutSx1( aParPerg[nI][01] ,; // nome da pergunta
		cIndice          ,; // indice
		aParPerg[nI][02] ,; // descricao portugues
		aParPerg[nI][02] ,; // descricao espanhol
		aParPerg[nI][02] ,; // descricao ingles
		cVarCh           ,; // variavel mv_ch
		aParPerg[nI][03] ,; // tipo
		aParPerg[nI][04] ,; // tamanho
		aParPerg[nI][05] ,; // decimais
		aParPerg[nI][06] ,; // indice de pre-seleção (combo)
		aParPerg[nI][07] ,; // tipo do objeto
		aParPerg[nI][08] ,; // validação
		aParPerg[nI][09] ,; // F3
		aParPerg[nI][10] ,; // grupo de perguntas
		" "              ,; // parametro pyme
		cVarPar          ,; // variavel mv_par
		aParPerg[nI][11] ,; // item 1 do combo (portugues)
		aParPerg[nI][11] ,; // item 1 do combo (espanhol)
		aParPerg[nI][11] ,; // item 1 do combo (ingles)
		""               ,; // conteudo padrao da pergunta
		aParPerg[nI][12] ,; // item 2 do combo (portugues)
		aParPerg[nI][12] ,; // item 2 do combo (espanhol)
		aParPerg[nI][12] ,; // item 2 do combo (ingles)
		aParPerg[nI][13] ,; // item 3 do combo (portugues)
		aParPerg[nI][13] ,; // item 3 do combo (espanhol)
		aParPerg[nI][13] ,; // item 3 do combo (ingles)
		aParPerg[nI][14] ,; // item 4 do combo (portugues)
		aParPerg[nI][14] ,; // item 4 do combo (espanhol)
		aParPerg[nI][14] ,; // item 4 do combo (ingles)
		aParPerg[nI][15] ,; // item 5 do combo (portugues)
		aParPerg[nI][15] ,; // item 5 do combo (espanhol)
		aParPerg[nI][15] ,; // item 5 do combo (ingles)
		aParPerg[nI][16] ,; // memo de help (portugues)
		aParPerg[nI][16] ,; // memo de help (espanhol)
		aParPerg[nI][16] ,; // memo de help (ingles)
		"" /* help*/ )

	next nI

return nil


Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
		cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
		cF3, cGrpSxg,cPyme,;
		cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
		cDef02,cDefSpa2,cDefEng2,;
		cDef03,cDefSpa3,cDefEng3,;
		cDef04,cDefSpa4,cDefEng4,;
		cDef05,cDefSpa5,cDefEng5,;
		aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f.

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme   == Nil, " ", cPyme  )
	cF3      := Iif( cF3   == NIl, " ", cF3  )
	cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg )
	cCnt01   := Iif( cCnt01  == Nil, "" , cCnt01  )
	cHelp  := Iif( cHelp  == Nil, "" , cHelp  )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Rodrigo Slisinski   º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarr1(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
		cBanco		,cAgencia	,cConta		,cDacCC	,;
		_cNossonuM		,nValor		,cCart		,cMoeda,nCod	)



	Local cNosso		:= ""
	Local cDigNosso		:= ""
	Local NNUM			:= ""
	Local cCampoL		:= ""
	Local cFatorValor	:= ""
	Local cLivre		:= ""
	Local cDigBarra		:= ""
	Local cBarra		:= ""
	Local cParte1		:= ""
	Local cDig1			:= ""
	Local cParte2		:= ""
	Local cDig2			:= ""
	Local cParte3		:= ""
	Local cDig3			:= ""
	Local cParte4		:= ""
	Local cParte5		:= ""
	Local cDigital		:= ""
	Local aRet			:= {}

//DEFAULT nValor := 0

//cAgencia:=STRZERO(Val(cAgencia),4)

	cNosso := ""
	NNUM   := _cNossonuM    //nCod+
//STRZERO(Val(cNroDoc),11)
//Nosso Numero
	cDigNosso  := CALC_di9(NNUM)
	cNosso     := NNUM + cDigNosso

// campo livre			// verificar a conta e carteira
//			cCampoL := cNosso+substr(e1_agedep,1,4)+STRZERO(VAL(e1_conta),8)+'18'
	cCampoL := NNUM+cAgencia+StrZero(Val(cConta),8)+cCart

//campo livre do codigo de barra                   // verificar a conta
	If nValor > 0
		cFatorValor  := fator()+strzero(nValor*100,10)
	Else
		cFatorValor  := fator()+strzero(SE1->E1_VALOR*100,10)
	Endif

	cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
	cDigBarra := CALC_5p( cLivre )
	cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

// composicao da linha digitavel
	cParte1  := cBanco+cMoeda
	cParte1  := cParte1 + SUBSTR(cBarra,5,5)//cParte1 + SUBSTR(cCampoL,1,5)
	cDig1    := DIGIT001( cParte1 )
	cParte2  := SUBSTR(cBarra,10,10) //SUBSTR(cCampoL,6,10)
	cDig2    := DIGIT001( cParte2 )
	cParte3  := SUBSTR(cBarra,20,10) //SUBSTR(cCampoL,16,10)
	cDig3    := DIGIT001( cParte3 )
	cParte4  := " "+cDigBarra+" "
	cParte5  := cFatorValor

	cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
		substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
		substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
		cParte4+;
		cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)


Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_di9  ºAutor  ³Rodrigo Slisinski   º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo do nosso numero do banco do brasil             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_di9(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 9
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base == 1
			base := 9
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base - 1
		iDig   := iDig-1
	EndDo
	auxi := mod(Sumdig,11)
	If auxi == 10
		auxi := "X"
	Else
		auxi := str(auxi,1,0)
	EndIf
Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT001  ºAutor  ³Rodrigo Slisinski   º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Banco do Brasil          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIGIT001(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	umdois := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		auxi   := Val(SubStr(cBase, idig, 1)) * umdois
		sumdig := SumDig + If (auxi < 10, auxi, (auxi-9))
		if umdois == 2
			umdois := 1
		Else
			umdois := 2
		EndIF
		iDig:=iDig-1
	EndDo
	cValor:=AllTrim(STR(sumdig,12))
	nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
	auxi := nDezena - sumdig

	If auxi >= 10
		auxi := 0
	EndIf
Return(str(auxi,1,0))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Rodrigo Slisinski   º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Fator()
	If Len(ALLTRIM(SUBSTR(DTOC(SE1->E1_VENCTO),7,4))) = 4
		cData := SUBSTR(DTOC(SE1->E1_VENCTO),7,4)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
	Else
		cData := "20"+SUBSTR(DTOC(SE1->E1_VENCTO),7,2)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
	EndIf
	cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
//cFator := STR(1000+(SE1->E1_VENCREA-STOD("20000703")),4)
Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_5p   ºAutor  ³Rodrigo Slisinski   º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_5p(cVariavel)
	Local Auxi := 0, sumdig := 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	base   := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If base >= 10
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base   := base + 1
		iDig   := iDig-1
	EndDo
	auxi := mod(sumdig,11)
	If auxi == 0 .or. auxi == 1 .or. auxi >= 10
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(str(auxi,1,0))

Static Function Modulo11(cData)
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
	D := 11 - (mod(D,11))
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)




//------------------------------------------------------------------------------------
// Calcula modulo 11 
//------------------------------------------------------------------------------------
Static Function Modx11(cData,cBanc,cCarteira,xNC)

	Local L, D, P := 0

	If cBanc == "001" //Banco do Brasil
		L := Len(cdata)
		D  := 0
		DS := 0
		P := 6
		X := 0
		for X=1 to L
			P := P + 1
			if P = 10
				P := 2
			end

			DS := DS + (Val(SubStr(cData, X, 1)) * P)
			//L := L - 1
		next

		D := int( (DS / 11) )
		D := DS - (D * 11)

		If D == 10
			D := "X"
		Else
			D := AllTrim(Str(D))
		End

	ElseIf cBanc == "237" //Bradesco

		nSoma1 := val(subs(cCarteira,01,1))*2
		nSoma2 := val(subs(cCarteira,02,1))*7
		nSoma3 := val(subs(cData,01,1))   *6
		nSoma4 := val(subs(cData,02,1))   *5
		nSoma5 := val(subs(cData,03,1))   *4
		nSoma6 := val(subs(cData,04,1))   *3
		nSoma7 := val(subs(cData,05,1))   *2
		nSoma8 := val(subs(cData,06,1))   *7
		nSoma9 := val(subs(cData,07,1))   *6
		nSomaA := val(subs(cData,08,1))   *5
		nSomaB := val(subs(cData,09,1))   *4
		nSomaC := val(subs(cData,10,1))   *3
		nSomaD := val(subs(cData,11,1))   *2

		cDigito := mod(nSoma1+nSoma2+nSoma3+nSoma4+nSoma5+nSoma6+nSoma7+nSoma8+nSoma9+nSomaA+nSomaB+nSomaC+nSomaD,11)

		D := iif(cDigito == 1, "P", iif(cDigito == 0 , "0", strzero(11-cDigito,1)))

	ElseIf cBanc $ "422/104/085" //SAFRA ou CAIXA (CEF)

		nCnt	:= 0
		cDigito:= 0
		nSoma	:= 0
		nBase	:= 0
		aPeso	:= {9,8,7,6,5,4,3,2};

		nBase := Len(aPeso)+1

		FOR nCnt := Len(cData) TO 1 STEP -1
			nBase := IF(--nBase = 0,Len(aPeso),nBase)
			nSoma += Val(SUBS(cData,nCnt,01)) * aPeso[nBase]
		NEXT

		nResto	:= (nSoma % 11)

		cDigito := 11 - nResto

		DO CASE
		CASE cBanc == "104" //CAIXA
			cDigito := If(cDigito > 9 .or. cDigito < 0 , "0" , STR( cDigito, 1, 0 ) )
		CASE nResto = 1
			cDigito := "0"
		CASE nResto = 0
			cDigito := "1"
		CASE cDigito > 9
			cDigito := "1"
		OTHERWISE
			cDigito := STR( cDigito, 1, 0 )
		ENDCASE

		D := cDigito

	ElseIf cBanc $ "341/655" //ITAU ou VOTORANTIM

		nCnt	:= 0
		cDigito:= 0
		nSoma	:= 0
		nBase	:= 0
		aPeso	:= {9,8,7,6,5,4,3,2};

		nBase := Len(aPeso)+1

		FOR nCnt := Len(cData) TO 1 STEP -1
			nBase := IF(--nBase = 0,Len(aPeso),nBase)
			nSoma += Val(SUBS(cData,nCnt,01)) * aPeso[nBase]
		NEXT

		cDigito := 11 - (nSoma % 11)

		DO CASE
		CASE cDigito = 0
			cDigito := "1"
		CASE cDigito > 9
			cDigito := "1"
		OTHERWISE
			cDigito := STR( cDigito, 1, 0 )
		ENDCASE

		D := cDigito

	ElseIf cBanc == "479"
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
		D := Mod(D*10,11)
		If D == 10
			D := 0
		End
		D := AllTrim(Str(D))

	ElseIf cBanc == "033"
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
		R := (mod(D,11))
		Do Case
		Case R == 10
			D := 1
		Case R == 0
			D := 0
		Case R == 1
			D := 0
		OtherWise
			D := (11 - R )
		EndCase
		D := AllTrim(Str(D))

	ElseIf cBanc == "041" .or. cBanc == "399"

		L := Len(cdata)
		D := 0
		P := 1
		R   := 0
		While L > 0
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 7
				P := 1
			End
			L := L - 1
		End
		R := (mod(D,11))
		Do Case
		Case R == 0
			D := 0
		Case R == 1
			If cBanc == "399"
				D := 0
			ElseIf Valtype(xNC) <> "C"
				D := 1
			Else
				D := (11 - R )
			Endif
		OtherWise
			D := (11 - R )
		EndCase

		If D == 10 //Quando o RESTO for igual a 1, o Digito automaticamente ser?10 (invalido). Sendo assim, o primeiro NC ser?incrementado e o modulo11 refeito.
			Return "ERRO"
		Endif
		D := AllTrim(Str(D))
	Else
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
		D := 11 - (mod(D,11))
		If cBanc $ "SANTANDER/CAIXA" .OR. cA6_COD == '041'
			IF (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
				D := 1
			End
		Else
			If (D == 10 .Or. D == 11)
				D := 1
			End
		Endif
		D := AllTrim(Str(D))
	Endif

Return(D)
