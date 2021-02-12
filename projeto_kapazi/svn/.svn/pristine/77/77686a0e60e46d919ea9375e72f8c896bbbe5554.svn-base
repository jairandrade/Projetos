#include "protheus.ch"
#include "topconn.ch"
#include "rptdef.ch"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+-------------------------'--------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN - Financeiro                                        !
+------------------+---------------------------------------------------------+
!Nome              ! BOLKAPX                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Chamada de impressão dos boletos  banco Itau.           !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Dotti																		     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/06/2013                                              !
+------------------+---------------------------------------------------------+
*/

//### ROTINA CHAMADA NO P.E F200FIM.PRW (RETORNO DO CNAB ### ///


//realizado ajustes no layout (MSBAR e mensagens) -- Andre/Rsac -- 21/12/2016
//Alteração do modo de criação do nosso numero -- Andre/Rsac -- 17/01/2017
//Compilado no Kapazi -- Andre/Rsac -- 17/01/2016
//Realizado validação no ambiente compilar -- 09.08.2017 -- Andre/Rsac
// Validação para versão P12 -- Andre/Rsac  -- 03.01.2017

User Function BOLKAPX(aTit)
Local cAls
Local aTitulo  	:= {}
Local cFile			:= ""
Local cPerg			:= PadR("BOLKAPX", 10)

Local lIsAuto		:= .t.
Private cCodBanco	:= "341"
Private cCodAg		:= "3813 "
Private cCodCC		:= "031550    "

Default aTit		:= {}

//RpcSetEnv('04', '01')
lIsAuto	:= !Empty(aTit)
If !lIsAuto
		fCriaSX1(cPerg)
		If !Pergunte(cPerg, .t.)
				Return
			Else
				cCodBanco := MV_PAR07
				cCodAg := MV_PAR08
				cCodCC := MV_PAR09
				aTitulo := fSelTitulo(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10)  // INCLUIDO MV_PAR10 -- Andre/Rsac 17.01.2017
		EndIf
	Else
		aTitulo := aTit
EndIf

If Len(aTitulo) > 0
	cFile := fImprime(aTitulo, lIsAuto)
EndIf

Return cFile

Static Function fImprime(aTitulo, lAuto)
Local n 				:= 0
Local aDadosTit
Local aDadosBanco
Local aDatSacado
Local cPath				:= SuperGetMV("KP_F001DIR",.f.,'\TMP\RFIN001\')
Local lAdjustToLegacy 	:= .t.
Local lDisableSetup 	:= .t.
Local lTReport 			:= .t.
Local lServer 			:= .t.
Local lPDFAsPNG 		:= .t.
Local lRaw 				:= .f.
Local lViewPDF 			:= .f.
Local nQtdCopy 			:= 1
Local cFileName 		:= ''
Local cFilePath 		:= ''
Local nI
Private _cNossonuM 		:="" 
Private i         		:= 1
Private CB_RN_NN  		:= {}
Private nRec      		:= 0
Private _nVlrAbat 		:= 0
Private lPrint 			:= .F.
Private aDadosEmp    	:= {SM0->M0_NOMECOM ,; //Nome da Empresa
							SM0->M0_ENDCOB                                                            ,; //Endereço
							AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //Complemento
							"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //CEP
							"PABX/FAX: "+SM0->M0_TEL                                                  ,; //Telefones
							Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+                       ;
							Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ;
							Subs(SM0->M0_CGC,13,2)                                                    ,; //CGC
							"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ;
							Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                         }  //I.E

Private xDac    		:= ''
Private oPrint
Private aImprime 		:= {}

SE1->(DbGoTo(aTitulo[1,1]))
cFileName := AllTrim(SE1->E1_NUM) + '.rel'
cFilePath := StrTran(cPath + cFileName, '.rel', '.pdf')	// O arquivo final eh renomeado de rel para pdf

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

If File(cFilePath)
	FErase(cFilePath)
EndIf

If lAuto
		oPrint := FWMSPrinter():New( cFileName, IMP_PDF, lAdjustToLegacy, cPath, lDisableSetup, lTReport, , ,lServer, lPDFAsPNG, lRaw, lViewPDF, nQtdCopy)
		oPrint:cPathPDF := cPath
		//oPrint:cPrinter := "HP Officejet 4300 Series"
	Else
		oPrint := TMSPrinter():New()
EndIf

oPrint:SetPortrait()

DbSelectArea("SE1")
For nI := 1 To Len(aTitulo)
	
	DbSelectArea("SE1")
	SE1->(DbGoTop())
	SE1->(DbGoTo(aTitulo[nI,1]))
	If Empty(SE1->E1_NUMBCO) 
			If MsgYesNo("Este título("+SE1->E1_NUM+") parcela ("+SE1->E1_PARCELA+") nao possui NOSSO NÚMERO, deseja enviar mesmo assim?")
				BolItau(aTitulo[nI,1], aTitulo[nI,2], lAuto)
				lImprimi	:= .T.
			EndIf
		Else
			BolItau(aTitulo[nI,1], aTitulo[nI,2], lAuto)
			lImprimi	:= .T.
	EndIf
 	   
next nI

If lAuto
	oPrint:Print()
	Sleep(1)
Else
	oPrint:Preview()
EndIf

//ConOut("KAPAZI_BOLKAPX: " + cFilePath)

If !File(cFilePath)
	cFilePath := ""
EndIf
Return cFilePath

Static Function BolItau(nE1RecNo, nA1Recno, lAuto)

SE1->(DbGoTo(nE1RecNo))
If !Empty(SE1->E1_NUMBOR) .AND. Empty(SE1->E1_NUMBCO)//Empty(SE1->E1_BOLETO)
	cMsg := "BOLKAPX: O titulo número: "+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA +" Pertence a carteira 112 - Para impressão favor acessar portal do BANCO!"
	If lAuto
			ConOut(cMsg)
		Else
			//Alert(cMsg)
	EndIf
	//Return
EndIf

SA1->(DbGoTo(nA1Recno))
nPorcDia	:= SA1->A1_PORCJUR
nMulta 		:= 0.02 * SE1->E1_VALOR

cDoc := Posicione("SF2", 1, xFilial("SF2") + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA), "F2_DOC")

aBolText := {	"APOS O VENCIMENTO COBRAR MULTA DE R$ " + AllTrim(Transform(nMulta, "@E 999,999,999.99")) + " MAIS MORA DE R$ "+AllTrim(Transform(SE1->E1_SALDO * nPorcDia/100 ,"@E 999,999,999.99"))+" AO DIA" ,;
				"SUJEITO A PROTESTO APÓS O VENCIMENTO"		,;
				"SEGUNDA VIA NO SITE WWW.KAPAZI.COM.BR"		,;
				IIf(Empty(cDoc), "", "COBRANÇA REFERENTE A NOTA FISCAL: " + SF2->F2_DOC + '/' + SF2->F2_SERIE)	}

/*
If SE1->E1_PORTADO <> "341"
	cMsg := "Portador do titulo (" + SE1->E1_PORTADO + ") nao configurado para impressao de boletos!"
	If lAuto
		ConOut(cMsg)
	Else
		MsgAlert(cMsg)
	EndIf
	Return
EndIf
*/
//Posiciona o SA6 (Bancos)
DbSelectArea("SA6")
SA6->(dbSetOrder(1))// filial+ banco + agencia + conta
If !Empty(SE1->E1_PORTADO)
	cCodBanco 	:= SE1->E1_PORTADO
	cCodAg 		:= SE1->E1_AGEDEP
	cCodCC 		:= SE1->E1_CONTA
EndIf

xDac := ''

If cCodBanco == "341"  
		If SA6->(dbSeek(xFilial("SA6") + cCodBanco + cCodAg + cCodCC))
				aDadosBanco	:= {	SA6->A6_COD                  		,;   //Numero do Banco
				"Banco Itaú SA"               	,;   //Nome do Banco
				SUBSTR(SA6->A6_AGENCIA, 1, 5) 	,;   //Agência
				SA6->A6_NUMCON                	,;   //Conta Corrente
				"2"                          		,;   //Carteira
				SA6->A6_COD                    	}  //Codigo no SA6
			Else
				aDadosBanco	:= {	'341'				                  		,;   //Numero do Banco
				"Banco Itaú SA"               	,;   //Nome do Banco
				SUBSTR(cCodAg, 1, 5) 						,;   //Agência
				cCodCC					                	,;   //Conta Corrente
				"2"                          		,;   //Carteira
				'341'				                    	}  //Codigo no SA6
		EndIf

	Else
		If SA6->(dbSeek(xFilial("SA6") + cCodBanco + cCodAg + cCodCC))
			aDadosBanco	:= {	SA6->A6_COD                  		,;   //Numero do Banco
			"Banco do Brasil"               	,;   //Nome do Banco
			SUBSTR(SA6->A6_AGENCIA, 1, 5) 	,;   //Agência
			SA6->A6_NUMCON                	,;   //Conta Corrente
			"2"                          		,;   //Carteira
			SA6->A6_COD                    	}  //Codigo no SA6
		Else
			aDadosBanco	:= {	'001'				                  		,;   //Numero do Banco
			"Banco do Brasil"               	,;   //Nome do Banco
			SUBSTR(cCodAg, 1, 5) 						,;   //Agência
			cCodCC					                	,;   //Conta Corrente
			"2"                          		,;   //Carteira
			'001'				                    	}  //Codigo no SA6
		EndIf
EndIf


SA1->(DbGoTo(nA1RecNo))
aDatSacado   := {AllTrim(SA1->A1_NOME)		,;   //Razão Social
				AllTrim(SA1->A1_COD )		,;   //Código
				AllTrim(SA1->A1_ENDCOB)	,;   //Endereço
				AllTrim(SA1->A1_MUNC )		,;   //Cidade
				SA1->A1_ESTC	          	,;   //Estado
				SA1->A1_CEPC							,;   //CEP
				SA1->A1_CGC           			}  //CGC

_nVlrAbat	:=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

_cPrefixo   := SE1->E1_PREFIXO
_nTitulo    := SE1->E1_NUM

If !Empty(SE1->E1_PARCELA)
	_nTitulo	:= _nTitulo + " - " + SE1->E1_PARCELA
EndIf

//EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA, R_E_C_N_O_, D_E_L_E_T_
DbSelectArea("SEE")
SEE->(DbSetOrder(1))
SEE->(DbGoTop())
SEE->(DbSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA))

_dEmissao 	:= SE1->E1_EMISSAO
_dVenc    	:= SE1->E1_VENCREA
_nSaldo   	:= SE1->E1_SALDO
xParcela  	:= SE1->E1_PARCELA  
_cNossonuM 	:= StrZero(val(SE1->E1_NUMBCO),10)     
_cNossonuM	:= ALLTRIM(SEE->EE_CODEMP) + _cNossonuM


If cCodBanco == "341"   // incluido 10.11.2017 -- adre/rsac
		CB_RN_NN  := Ret_cBarra(Subs(aDadosBanco[1],1,3) + "9" ,;
		aDadosBanco[3], aDadosBanco[4], aDadosBanco[5],;
		AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;
		(SE1->E1_SALDO-_nVlrAbat), aDadosBanco[6],;
		DTOS(SE1->E1_VENCREA), SE1->E1_PREFIXO )
	
	ElseIf cCodBanco == "001" 
		CB_RN_NN  := 	Ret_cBarra(Subs(aDadosBanco[1],1,3) + "9" ,;
						aDadosBanco[3], aDadosBanco[4], aDadosBanco[5],;
						AllTrim(SE1->E1_NUM) + AllTrim(SE1->E1_PARCELA),;
						(SE1->E1_SALDO-_nVlrAbat), aDadosBanco[6],;
						DTOS(SE1->E1_VENCREA), SE1->E1_PREFIXO )
EndIf


aDadosTit := {AllTrim(_nTitulo)    ,;     //Número do título
			_dEmissao            ,;     //Data da emissão do título
			Date()               ,;     //Data da emissão do boleto
			_dVenc               ,;     //Data do vencimento
			(_nSaldo - _nVlrAbat),;     //Valor do título
			CB_RN_NN[3]          ,;     //Nosso Numero
			xParcela              }     // parcela incluido em 18/02/03                                                                 //Nosso número (Ver fórmula para calculo)

Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,lAuto) //Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

Return



Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN,lAuto)  //Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
// Local _cNN := Substr(aDadosTit[6],1,2) + " " + Substr(aDadosTit[6],3,3) + " " + Substr(aDadosTit[6],6,3) + " " + Substr(aDadosTit[6],9,2) + " " + Substr(aDadosTit[6],11,1)
Private xCarteira := '109'
Private _cNN      := "109/" + aDadosTit[6]
Private cMsg1     := ''
Private cMsg2     := ''
Private cMsg3     := ''

Private nPosBanco := 0

Private aBancoMsg := {	{'341', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ"				, "APÓS O VENCIMENTO, SOMENTE NO ITAÚ"										, ""}},;
						{'347', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO SUDAMERIS"	, "APÓS O VENCIMENTO, SOMENTE NO SUDAMERIS"							, ""}},;
						{'409', {"ATÉ O VENCIMENTO, PAGAVEL EM QUALQUER BANCO"				, "APÓS O VENCIMENTO, EM QUALQUER AGENCIA DO UNIBANCO"	, "MEDIANTE A CONSULTA NO SISTEMA VC"}},;
						{'237', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BRADESCO"		, "APÓS O VENCIMENTO, SOMENTE NO BRADESCO"								, ""}},;
						{'422', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO SAFRA"			, "APÓS O VENCIMENTO, SOMENTE NO SAFRA"										, ""}},;
						{'655', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BANCO BV"		, "APÓS O VENCIMENTO, SOMENTE NO BANCO BV"								, ""}},;
						{'001', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BANCO DO BRASIL"		, "APÓS O VENCIMENTO, SOMENTE NO BANCO DO BRASIL"								, ""}},;
						{'104', {"ATÉ O VENCIMENTO, PREFERENCIALMENTE NA CAIXA"  		, "APÓS O VENCIMENTO, SOMENTE NA CAIXA"										, ""}} }

If SuBStr(aDadosBanco[1],1,3) == '341' //ITAU
	//_cNN        := "109/"+aDadosTit[6]
	//xCarteira   := '20'
ElseIf SuBStr(aDadosBanco[1],1,3) == '409'  // Unibanco
	_cNN        := "1/" + aDadosTit[6]
	xCarteira   := '04'
ElseIf SuBStr(aDadosBanco[1],1,3) == '237'
	_cNN        := '09/'+aDadosTit[6]
	xCarteira   := '09'
ElseIf SuBStr(aDadosBanco[1],1,3) == '422' // Safra
	_cNN        := aDadosTit[6]
	xCarteira   := '02'    
ElseIf SuBStr(aDadosBanco[1],1,3) == '001' // banco do brasil
	_cNN        := aDadosTit[6]
	xCarteira   := '17'	
EndIf

nPosBanco := aScan(aBancoMsg, {|aItem| aItem[1] == SuBStr(aDadosBanco[1],1,3)})

oPrint:StartPage()   // Inicia uma nova página

nColIni := 100
nColFim	:= 2300

nFldHeight := IIf(lAuto, 70, 80)
nLin := IIf(lAuto, 100, 150)

nNewLin := fPrintVia(oPrint, nLin, nFldHeight, 1, lAuto)
nNewLin := fPrintVia(oPrint, nNewLin, nFldHeight, 2, lAuto)
nNewLin := fPrintVia(oPrint, nNewLin, nFldHeight, 3, lAuto)

oPrint:EndPage() // Finaliza a página

Return Nil
//1     2      3       4         5       6      7         8      9
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cCarteira,cNroDoc,nValor,cCodBanco,dVencto,cPref)
Local blvalorfinal := StrZero(nValor*100,10)
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
	NN := nBCOx(SE1->E1_NUM, SE1->E1_PARCELA)
(SE1->E1_NUM, SE1->E1_PARCELA)
EndIf
          
If SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
	NN := nBCOx(SE1->E1_NUM, SE1->E1_PARCELA)
EndIf

If SuBStr(cBanco,1,3) == '341' //.OR. SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
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
	// monta o nosso numero com o digito verIficador
	NN:= NN + "-" + Alltrim(Str(dvnn))
//EndIf  

ElseIf SuBStr(cBanco,1,3) == '001'
	s:= AllTrim(cAgencia) + SubStr(alltrim(cConta),1,5) + "17" + SubStr(alltrim(NN),1,8) // incluido em 19/02/03
	dvnn :=   modulo10(s)
	
	s := cBanco      + Alltrim(Str(_nFator)) + blvalorfinal + "17" + SubStr(alltrim(NN),1,8)+Alltrim(Str(dvnn)) +AllTrim(cAgencia) + SubStr(alltrim(cConta),1,6) + "000"
	
	dvcb := str(Mod11CB(s))
	CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)
	//_cCodBar			:=	'237'+'9'+_cNumDv+fator+StrZero(ROUND(_nSaldo,2)*100,10)+_cAgConv+'0911'+_cNossoNum+_cFxConv+'00589010'
   
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
 
 //Alteração para calculo do Digito VerIficador do codigo de barras -- 05.12.2017 -- Andre/Rsac
  cNumDig10 := substr(CB,1,4)+ substr(CB,6,44) 
  DVGERAL :=CalcDigM11(cNumDig10)
  // DVGERAL :=modulo11(substr(CB,1,4)+substr(CB,6,39)) // 24.11.2017 -- Inlcuido Andre-Rsac 
 
	RN:= "001"+"9"+substr(CB,20,5)+ALLTRIM(STR(DVCampo1))+substr(CB,25,1)+ALLTRIM(SEE->EE_CODEMP)+"00"+AllTrim(STR(DVCampo2))+NN+"17"+alltrim(str(DVCampo3))+AllTrim(DVGERAL)+Alltrim(Str(_nFator))+blvalorfinal //"001"+"9"+substr(CB,20,5)+ALLTRIM(STR(DVCampo1))+substr(CB,25,1)+ALLTRIM(SEE->EE_CODEMP)+"00"+AllTrim(STR(DVCampo2))+NN+"17"+alltrim(str(DVCampo3))+"1"+Alltrim(Str(_nFator))+blvalorfinal
	RN := substr(RN,1,5)+"."+substr(RN,6,5)+" "+substr(RN,11,5)+" "+substr(RN,16,6)+" "+substr(RN,22,5)+"."+substr(RN,27,6)+" "+substr(RN,33,1)+" "+substr(RN,34,14)
 
	 // Alteração 03.01.2017 -- Andre/rsac
	s := "001"+"9"+Alltrim(Str(_nFator))+blvalorfinal+"000000"+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,7)+StrZero(VAL(NN),10)+"17" //+substr(cAgencia,1,4)+ StrZero(val(cConta),8)
	dvcb := str(Mod11CB(s))
	CB := "001"+"9"+alltrim(dvcb)+Alltrim(Str(_nFator))+blvalorfinal+"000000"+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,7)+StrZero(VAL(NN),10)+"17"    //Alltrim(Str(_nFator))+blvalorfinal+SUBSTR(ALLTRIM(SEE->EE_CODEMP),1,6)+ALLTRIM(STR(VAL(NN)))+substr(cAgencia,1,4)+ StrZero(val(cConta),8)+"17"
	//Fim
	
	
		// monta o nosso numero com o digito verIficador
	NN:= NN + "-" + Alltrim(Str(dvnn))   
	
//_nNossonuM:= ALLTRIM(SEE->EE_CODEMP)+_nNossonuM
	
EndIf
//fim - 30.10.2017


// Codigo de barras, Linha digitavel, nosso numero
Return({CB,RN,NN})



Static Function Modulo10(cData)
Local Soma, Mult, M, N, I
Soma := 0
Mult := 2
For i:=Len(cData) to 1 step -1
	If Mult == 0
		Mult := 2
	EndIf
	M := Val(SubStr(cData, i, 1)) * Mult
	If M >= 10
		Soma += (Val(SubStr(Alltrim(Str(M)), 1, 1)) + Val(SubStr(Alltrim(Str(M)), 2, 1)))
	Else
		Soma += M
	EndIf
	Mult -= 1
Next
If Soma < 10
	DV := 10 - Soma
Else
	DV := Mod(Soma, 10)
	If DV > 0
		DV := 10 - DV
	EndIf
EndIf
Return(DV)  

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³          ³ Autor ³                                    ³   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o Digito VerIficador MOD11                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DIGITO DO CODIGO DE BARRAS                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcDigM11()  
Local nCnt   := 0,;
cDigito  := 0,;
nSoma  := 0,;
nBase  := 0,;
aPeso  := {9,8,7,6,5,4,3,2}; 

nBase := Len(aPeso)+1

FOR nCnt := Len(cNumDig10) TO 1 STEP -1
	nBase := If(--nBase = 0,Len(aPeso),nBase)
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
Return(cDigito)
                


Static Function nBCOx(cNum, cParc) //E1_NUMBCO

Local nNum     := ""
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSEE := SEE->(GetArea())
Default cNum	 := ""
Default cParc	 := ""


If !Empty(SE1->E1_NUMBCO)
	nNum:=padr(SE1->E1_NUMBCO,8,'0' )
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSEE)

Return StrZero(Val(nNum),8)


Static Function Mod11CB(cData)

Local L, D, P := 0
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

If nsub==0 .or.nsub > 9
	Dv:=1
Else
	Dv:=nsub
EndIf

Return(Dv)


Static Function fPrintVia(oPrint, nLinStart, nHeight, nNumVia, lAuto)
Local nLin := nLinStart
Local nFldHeight := nHeight

Local cLogoItau	:= "\system\logoitau2.bmp"
Local cLogoBB	:= "\system\logoBB.bmp"  


//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
Local oFont8   := TFont():New("Arial",9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont10  := TFont():New("Arial",9,9,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont09  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)

Local oFont14  := TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
Local oFont24  := TFont():New("Arial",9,23,.T.,.T.,5,.T.,5,.T.,.F.)
Local i 

//Primeira Via
oPrint:Line (nLin, 100, nLin, 2300)	// Linha horizontal
oPrint:Line (nLin - 90,  550, nLin, 550)
oPrint:Line (nLin - 90,  800, nLin, 800)


If cCodBanco == '341'  
	If File(cLogoItau)
		oPrint:SayBitmap(nLin - 90, 110, cLogoItau, 280, 83)
	Else
		oPrint:Say  (nLin - 40,  100, aDadosBanco[2]				, oFont16)
	EndIf
ElseIf cCodBanco == '001' //incluido Andre/Rsac -- 04.09.2017
	If File(cLogoBB)
		oPrint:SayBitmap(nLin - 90, 110, cLogoBB, 280, 83)
	Else
		oPrint:Say  (nLin - 40,  100, aDadosBanco[2]				, oFont16)
	EndIf 
EndIf // fim


oPrint:Say  (nLin - IIf(lAuto, 40, 100),  567, aDadosBanco[1]				, oFont24)
oPrint:Say  (nLin - IIf(lAuto, 45, 80),  820, CB_RN_NN[2]						, oFont14)
If nNumVia == 1
	oPrint:Say  (nLin - IIf(lAuto, 90, 100), 1900, "Recibo do Pagador"	, oFont09)
EndIf

nLin += nFldHeight
// -----------------------------------------------------------------------------------
oPrint:Say  (nLin - IIf(lAuto, 65, 70),100 ,"Local de Pagamento"                           ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 65, 75), 400 ,aBancoMsg[nPosBanco,2,1]                       ,oFont10)
oPrint:Say  (nLin - IIf(lAuto, 25, 35), 400 ,aBancoMsg[nPosBanco,2,2]                       ,oFont10)
oPrint:Say  (nLin - IIf(lAuto, 00, 10), 400 ,aBancoMsg[nPosBanco,2,3]                       ,oFont10)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1910, "Vencimento"                                   ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 35, 45), 2120, alltrim(substr(dtos(aDadosTit[4]),7,2)+"/"+substr(dtos(aDadosTit[4]),5,2)+"/"+substr(dtos(aDadosTit[4]),1,4)),oFont10)

oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),  100, "Beneficiário"                                  ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40),  100, aDadosEmp[1]                                    ,oFont10)
oPrint:Line (nLin - nFldHeight, 1350, nLin, 1350)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1355, "CNPJ/CPF"                                      ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 1455, aDadosEmp[6]                                    ,oFont10)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1910, "Agência/Código Beneficiário" ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 2085, alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIf( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10)
//oPrint:Say  (245,2165,alltrim(aDadosBanco[3])+"/"+alltrim(substr(aDadosBanco[4],1,len(alltrim(aDadosBanco[4]))-1))+IIf( RIGHT( ALLTRIM( aDadosBanco[4] ),1 ) <> '','-' + RIGHT( ALLTRIM( aDadosBanco[4] ),1),'' ) ,oFont10,10,,,2)
oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),  100, "Endereço Beneficiário"                                ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40),  100, alltrim(SM0->M0_ENDCOB)+"-"+alltrim(SM0->M0_CIDCOB)+"-"+alltrim(SM0->M0_ESTCOB)+"  Cep:"+alltrim(TRANSFORM(SM0->M0_CEPCOB,"@r 99999-999"))   ,oFont10)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1910, "Nosso Número"                                  ,oFont8)
If cCodBanco == '341' 
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 2045, alltrim(_cNN)                                    ,oFont10) 
ElseIf  cCodBanco == '001'
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 2045, alltrim(_cNossonuM)                                    ,oFont10) 
EndIf
//oPrint:Say  (315,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)
oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),  100, "Data do Documento"                             ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40),  100, Day2Str(aDadosTit[3]) + '/' + Month2Str(aDadosTit[3]) + '/' + Year2Str(aDadosTit[3]),oFont10)
oPrint:Line (nLin - nFldHeight,  500, nLin,  500)

oPrint:Say  (nLin - IIf(lAuto, 65, 70),  505, "Número do Documento"                            ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40),  605, aDadosTit[1]                                     ,oFont10)
oPrint:Line (nLin - nFldHeight, 1000, nLin, 1000)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1005, "Espécie"                                        ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 1105, "DM"                                             ,oFont10)
oPrint:Line (nLin - nFldHeight, 1350, nLin, 1350)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1355, "Aceite"                                          ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 1455, "NAO"                                             ,oFont10)
oPrint:Line (nLin - nFldHeight, 1550, nLin, 1550)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1555, "Data do Processamento"                           ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 1655, Day2Str(aDadosTit[2]) + '/' + Month2Str(aDadosTit[2]) + '/' + Year2Str(aDadosTit[2]),oFont10)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 1910, "(=)Valor do Documento"                           ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 2195, AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10)
//oPrint:Say  (385,2200,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")) ,oFont10,10,,,2)

oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------
nLin += nFldHeight

// Banco Safra ou outros
cCabec	:= IIf(SuBStr(aDadosBanco[1],1,3) == '422', "Data de Operação", "Uso do Banco")
cDesc		:= IIf(SuBStr(aDadosBanco[1],1,3) == '422', Day2Str(aDadosTit[2]) + '/' + Month2Str(aDadosTit[2]) + '/' + Year2Str(aDadosTit[2]), IIf(SuBStr(aDadosBanco[1],1,3) == '409', "CVT 5539-5", ""))

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 100, cCabec                             ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 100, cDesc                             ,oFont8)
oPrint:Line (nLin - nFldHeight,  500, nLin,  500)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 505 ,"Carteira"                                        ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 555 ,xCarteira                                         ,oFont10)
oPrint:Line (nLin - nFldHeight,  750, nLin,  750)

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 755 ,"Espécie Moeda"                                   ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 805 ,"R$"                                              ,oFont10)
oPrint:Line (nLin - nFldHeight, 1000, nLin, 1000)

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1005,"Quant. Moeda"                                    ,oFont8)
oPrint:Line (nLin - nFldHeight, 1550, nLin, 1550)

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1555,"Valor da Moeda"                                  ,oFont8)

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1910,"(-)Desconto"                                     ,oFont8)

oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------
nLin += nFldHeight

oPrint:Say  (nLin - 65, 100, "Instruções (Todas informações deste boleto são de exclusiva responsabilidade do Beneficiário.)" ,oFont8)

If cCodBanco $ "341|001"
	oPrint:Say  (nLin - 30, 150,aBolText[1]                                       ,oFont09)
	oPrint:Say  (nLin -  5, 150,aBolText[2]                                       ,oFont09)
	oPrint:Say  (nLin + 20, 150,aBolText[3]                                       ,oFont09)
	oPrint:Say  (nLin + 55, 150,aBolText[4]                                       ,oFont09)
//	oPrint:Say  (nLin + 85, 150,aBolText[5]                                       ,oFont10)
//	oPrint:Say  (nLin + 115, 150,aBolText[6]                                       ,oFont10)
//	oPrint:Say  (nLin + 145, 150,aBolText[7]                                       ,oFont10)
EndIf

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1910,"(-) Outras Deduções/Abatimento"                   ,oFont8)
oPrint:Line (nLin, 1910, nLin, 2300)
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1910,"(+) Mora/Multa"                                   ,oFont8)
oPrint:Line (nLin, 1910, nLin, 2300)
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1910,"(+) Outros Acréscimos"                            ,oFont8)
oPrint:Line (nLin, 1910, nLin, 2300)
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),1910,"(=) Valor Cobrado"                                ,oFont8)

oPrint:Line (nLin,  100, nLin, 1900)
oPrint:Line (nLin, 1900, nLin, 2300)
// -----------------------------------------------------------------------------------

// Divide o canhoto do descritivo (esquerda - direita)
oPrint:Line (nLinStart, 1900,  nLin, 1900)

// -----------------------------------------------------------------------------------
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70), 100, "Pagador"                                          ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 30, 40), 400, aDatSacado[1]                                      ,oFont09)
oPrint:Say  (nLin - IIf(lAuto,  5, 15), 400 ,aDatSacado[3]                                     ,oFont09)
oPrint:Say  (nLin + IIf(lAuto, 20, 30), 400 ,aDatSacado[4] + " - " + aDatSacado[5] + " CEP " + aDatSacado[6] ,oFont09)

oPrint:Say  (nLin - IIf(lAuto, 30, 40), 1870, "CNPJ/CPF- " + aDatSacado[7]                       ,oFont09)
//oPrint:Say  (800,2100,"CNPJ/CPF- "+aDatSacado[7]                        ,oFont09,10,,,2)
//oPrint:Say  (853,2145,alltrim(_cNN)                                    ,oFont10,10,,,2)
nLin += nFldHeight

oPrint:Say  (nLin - IIf(lAuto, 65, 70),  100 ,"Pagador/Avalista"                                ,oFont8)
oPrint:Say  (nLin - IIf(lAuto, 65, 70), 2000 ,"Código de Baixa"                                ,oFont8)
oPrint:Line (nLin, 100, nLin, 2300)

If nNumVia == 1
	nLin += nFldHeight + 25
	oPrint:Say  (nLin - IIf(lAuto, 85, 95), 100,"Recebimento através do cheque num.                    do banco            ." ,oFont8)
	oPrint:Say  (nLin - IIf(lAuto, 85, 95),1900,"Autenticação Mecânica"                           ,oFont8)
	oPrint:Say  (nLin - IIf(lAuto, 60, 70), 100,"Esta quitação só terá validade após o pagamento do cheque pelo" ,oFont8)
	oPrint:Say  (nLin - IIf(lAuto, 35, 45), 100,"banco Pagador.",oFont8)
EndIf

If nNumVia == 3 .and. !Empty(CB_RN_NN[1])
	If lAuto
	 	oPrint:FwMsBar("INT25",63.7,2.0,CB_RN_NN[1],oPrint,.F., , , ,1.4, , , ,.f., , , .f.)    // IMPressao em Jato de Tinta HP 660   
	 
	Else
		//	MSBAR("INT25",27.9,1.6,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660   -- Andre/Rsac 21/12/2016
		MSBAR("INT25",27.2,1.2,CB_RN_NN[1],oPrint,.F.,,,,1.8,,,,.F.)    // IMPressao em Jato de Tinta HP 660
	EndIf
Else
	//Gambiarra, descobrir como mudar tipo da linha.
	For i := 100 to nColFim step 50
		oPrint:Line( nLin, i, nLin, i+30)
	Next i
EndIf

Return nLin + 150

Static Function fSelTitulo(cPrefDe, cPrefAte, cNumDe, cNumAte, cParc, cTipo, cBco, cAg, cCC)
Local aRet 		:= {}
Local nOpc 		:= 0
Local cQuery 	:= ""
Local cAls			:= GetNextAlias()
Local oOk  		:= LoadBitMap(GetResources(), "LBOK")
Local oNo  		:= LoadBitMap(GetResources(), "LBNO")

Private aTitulo := {}

cQuery := "SELECT SE1.R_E_C_N_O_ E1RECNO, SA1.R_E_C_N_O_ A1RECNO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, E1_EMISSAO, E1_VENCREA, (E1_SALDO) SALDO "
cQuery += "FROM " + RETSQLNAME("SE1") + " SE1 (nolock) INNER JOIN " + RetSQLName("SA1") + " SA1 (nolock) ON ( "
cQuery += "	SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery += "AND SE1.E1_CLIENTE = SA1.A1_COD "
cQuery += "AND SE1.E1_LOJA = SA1.A1_LOJA "
cQuery += ") "
cQuery += "WHERE SE1.D_E_L_E_T_ = '' "
cQuery += "AND SE1.E1_FILIAL = '" + cFilAnt + "' "
cQuery += "AND SE1.E1_PREFIXO BETWEEN '" + cPrefDe + "' AND '" + cPrefAte + "' "
cQuery += "AND SE1.E1_NUM BETWEEN '" + cNumDe + "' AND '" + cNumAte + "' "
If !Empty(cParc)
	cQuery += "AND SE1.E1_PARCELA = '" + cParc + "' "
EndIf
If !Empty(cTipo)
	cQuery += "AND SE1.E1_TIPO = '" + cTipo + "' "
Else
	cQuery += "AND SE1.E1_TIPO NOT IN ('PA ', 'PR ') "
EndIf
cQuery += "AND (SE1.E1_PORTADO = '' OR (SE1.E1_PORTADO = '" + cBco + "' AND SE1.E1_AGEDEP = '" + cAg + "' AND SE1.E1_CONTA = '" + cCC + "')) "

TCQUERY cQuery NEW ALIAS &cAls
TCSetField(cAls, "E1_EMISSAO"	, "D"	, 08, 0)
TCSetField(cAls, "E1_VENCREA"	, "D"	, 08, 0)
TCSetField(cAls, "SALDO"   		, "N"	, 14, 2)

DbSelectArea(cAls)
ProcRegua(0)
While !(cAls)->(Eof())
	IncProc("Buscando informações...")
	AADD(aTitulo,	{	.f.,;
	(cAls)->E1RECNO,;
	(cAls)->E1_PREFIXO,;
	(cAls)->E1_NUM,;
	(cAls)->E1_PARCELA,;
	(cAls)->E1_TIPO,;
	(cAls)->E1_CLIENTE,;
	(cAls)->E1_LOJA,;
	(cAls)->A1_NOME,;
	(cAls)->E1_EMISSAO,;
	(cAls)->E1_VENCREA,;
	(cAls)->SALDO,;
	(cAls)->A1RECNO})
	(cAls)->(dbSkip())
EndDo
(cAls)->(dbCloseArea())

If Len(aTitulo) <= 0
	ApMsgAlert("Não existem títulos a serem impressos. Confira os parâmetros!")
	Return aRet
EndIf

DEFINE MSDIALOG oDlgTit TITLE "[BOLKAPX] - Impressão de Boleto de Cobrança" From 001,001 to 380,615 Pixel

//========================// Browse com os títulos //========================//

oBrwTit := TCBrowse():New(010,005,300,150,,,,oDlgTit,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oBrwTit:AddColumn(TCColumn():New(" "            , {|| If(aTitulo[oBrwTit:nAt,01],oOk,oNo) },,,,,,.T.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Prefixo"      , {|| aTitulo[oBrwTit:nAt,03]},,,,, ,.F.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Número"       , {|| aTitulo[oBrwTit:nAt,04]},,,,, ,.F.,.F.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Parcela"      , {|| aTitulo[oBrwTit:nAt,05]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Tipo"         , {|| aTitulo[oBrwTit:nAt,06]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Cliente"      , {|| aTitulo[oBrwTit:nAt,07]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Loja"         , {|| aTitulo[oBrwTit:nAt,08]},,,,, ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Nome Cliente" , {|| aTitulo[oBrwTit:nAt,09]},,,,, 40 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Dt. Emissão"  , {|| aTitulo[oBrwTit:nAt,10]},,,,, 10 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Dt. Vencto."  , {|| aTitulo[oBrwTit:nAt,11]},,,,, 10 ,.F.,.T.,,,,.F., ) )
oBrwTit:AddColumn(TCColumn():New("Valor"        , {|| aTitulo[oBrwTit:nAt,12]},"@E 9,999,999.99",,,"RIGHT", ,.F.,.T.,,,,.F., ) )

oBrwTit:SetArray(aTitulo)

oBrwTit:bLDblClick   := { || aTitulo[oBrwTit:nAt,01] := !aTitulo[oBrwTit:nAt,01]  }
oBrwTit:bHeaderClick := { || fSelectAll() }

oBtnImpr := tButton():New(170,210,'Imprimir'  ,oDlgTit, {|| nOpc := 1, oDlgTit:End() },40,12,,,,.T.)
oBtnSair := tButton():New(170,260,'Sair'      ,oDlgTit, {|| oDlgTit:End() },40,12,,,,.T.)

ACTIVATE MSDIALOG oDlgTit CENTERED

If nOpc == 1
	aEval(aTitulo, {|aItem| If(aItem[1], aAdd(aRet, {aItem[2], aItem[13]}), nil) })
Else
	aRet := {}
EndIf

Return aRet

//============================ Inverte a seleção ============================//
Static Function fSelectAll()
local i 

For i:=1 to Len(aTitulo)
	aTitulo[i,1] := !aTitulo[i,1]
Next i

oBrwTit:Refresh()

Return

Static Function fCriaSX1(cPerg)
PutSX1(cPerg, "01", "Prefixo de"		, "", "", "mv_ch1", "C", TAMSX3("E1_PREFIXO")[1], 0, 0, "G", "",       , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Prefixo ate"	, "", "", "mv_ch2", "C", TAMSX3("E1_PREFIXO")[1], 0, 0, "G", "",       , "", "", "mv_par02", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "03", "Numero de"		, "", "", "mv_ch3", "C", TAMSX3("E1_NUM")[1] 		, 0, 0, "G", "",       , "", "", "mv_par03", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "04", "Numero ate"		, "", "", "mv_ch4", "C", TAMSX3("E1_NUM")[1] 		, 0, 0, "G", "",       , "", "", "mv_par04", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "05", "Parcela"				, "", "", "mv_ch5", "C", TAMSX3("E1_PARCELA")[1], 0, 0, "G", "",       , "", "", "mv_par05", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "06", "Tipo"					, "", "", "mv_ch6", "C", TAMSX3("E1_TIPO")[1]   , 0, 0, "G", "",       , "", "", "mv_par06", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "07", "Banco"     		, "", "", "mv_ch7", "C", TAMSX3("E1_PORTADO")[1], 0, 0, "G", "", "SEE" , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "08", "Agencia"   		, "", "", "mv_ch8", "C", TAMSX3("E1_AGEDEP")[1] , 0, 0, "G", "",       , "", "", "mv_par08", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "09", "Conta"     		, "", "", "mv_ch9", "C", TAMSX3("E1_CONTA")[1]  , 0, 0, "G", "",       , "", "", "mv_par09", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "10", "SubConta"     	, "", "", "mv_cha", "C",3,0,0,"G","",,"","", "mv_par10", "","","","","","","","","","","","","","","","")
Return

