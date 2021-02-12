#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "rwmake.ch"

//WebService
wsservice WS_NOSSONUMERO description "WEBSERVICE NOSSONUMERO" 

	// DECLARACAO DAS VARIVEIS GERAIS
	WSDATA LOGIN	as string
	WSDATA SENHA	as string	
	WSDATA CGC	as string

	WSDATA oCab   	 as NOSSONUMERO_CAB
	WSDATA oItens as array of NOSSONUMERO_ITENS

	// DECLARACAO DOS METODOS	
	
	wsmethod CONSULTA_ITENS  		description "Consulta titulos com saldo do CNPJ informado"

endwsservice

//----------------------
//METODO CONSULTA_ITENS 
//----------------------
wsmethod CONSULTA_ITENS wsreceive LOGIN,SENHA,CGC wssend oCab wsservice WS_NOSSONUMERO
local lAuto := .F.
private cAlias := GetNextAlias()


	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)
			/*
			::oCab := WSClassNew("NOSSONUMERO_CAB")
			::oCab:CGC := ""
			::oCab:NOME := "Em Manutencao"
			::oCab:Item:={}
			
				aAdd(::oCab:Item, WSClassNew("NOSSONUMERO_ITENS") )
				nX := Len(::oCab:Item)
				::oCab:Item[nX]:CNPJ_EMISSOR := ""
				::oCab:Item[nX]:NOME_EMISSOR := ""
				::oCab:Item[nX]:NOSSONUMERO := ""
				::oCab:Item[nX]:BANCO := ""
				::oCab:Item[nX]:EMISSAO      := ""
				::oCab:Item[nX]:VENCIMENTO   := ""
				::oCab:Item[nX]:VALOR := 0
				::oCab:Item[nX]:SALDO := 0
			*/
			
			If	Select('SX2') == 0
				RPCSettype( 3 )						//NÃ£o consome licensa de uso
				//conout("Utilizando empresa " + cEmp + " filial " + cFil)
				RpcSetEnv("04","01",,,"FIN",GetEnvServer(),{ "SM2" })
				//sleep( 2000 )						//Aguarda 5 segundos para que as jobs IPC subam.
				lAuto := .T.
			EndIf
			
			
			BeginSQL alias cAlias
				%noparser%

				SELECT *
				FROM
				NOSSO_NUMERO
				WHERE
				A1_CGC = %Exp:CGC%
				order by E1_VENCREA

			EndSql
			
			::oCab := WSClassNew("NOSSONUMERO_CAB")
			::oCab:CGC := (cAlias)->A1_CGC
			::oCab:NOME := (cAlias)->A1_NOME
			::oCab:Item:={}
			
			If (cAlias)->(EOF())
			::oCab := WSClassNew("NOSSONUMERO_CAB")
			::oCab:CGC := ""
			::oCab:NOME := "CGC nao localizado ou sem titulos"
			::oCab:Item:={}
			
				aAdd(::oCab:Item, WSClassNew("NOSSONUMERO_ITENS") )
				nX := Len(::oCab:Item)
				::oCab:Item[nX]:CNPJ_EMISSOR := ""
				::oCab:Item[nX]:NOME_EMISSOR := ""
				::oCab:Item[nX]:NOSSONUMERO := ""
				::oCab:Item[nX]:BANCO := ""
				::oCab:Item[nX]:EMISSAO      := ""
				::oCab:Item[nX]:VENCIMENTO   := ""
				::oCab:Item[nX]:VALOR := 0
				::oCab:Item[nX]:SALDO := 0	
			EndIf


			while (cAlias)->(!Eof())


				aAdd(::oCab:Item, WSClassNew("NOSSONUMERO_ITENS") )
				nX := Len(::oCab:Item)
				
//				OpenSxs(,,,,"04","SM0","SM0",,.F.)
//				If Select("SM0") > 0
				   
				 
					
					DbSelectArea("SM0")
					SM0->(DbGoTop())
					SM0->(DbSeek((cAlias)->EMPRESA+ (cAlias)->E1_FILIAL))
					
					 if( (cAlias)->EA_PORTADO == "001") 
						cNosso:= ALLTRIM((cAlias)->EE_CODEMP)+strzero(val(ALLTRIM((cAlias)->E1_NUMBCO)),10)
					else 
						cNosso := Ret_cBarra( (cAlias)->EA_PORTADO+"9", SUBSTR((cAlias)->EA_AGEDEP,1,5), (cAlias)->EA_NUMCON, "2", AllTrim((cAlias)->E1_NUM)+AllTrim((cAlias)->E1_PARCELA),(cAlias)->E1_VALOR, (cAlias)->EA_PORTADO, (cAlias)->E1_VENCREA, (cAlias)->E1_PREFIXO )[3]		
						cNosso:= "109"+cNosso
						cNosso:= strtran(cNosso,"-","") 
					EndIf
	
					::oCab:Item[nX]:CNPJ_EMISSOR := ALLTRIM(SM0->M0_CGC)
					::oCab:Item[nX]:NOME_EMISSOR := ALLTRIM(SM0->M0_NOMECOM)
					::oCab:Item[nX]:NOSSONUMERO 	:= cNosso 
					::oCab:Item[nX]:BANCO	:= ALLTRIM((cAlias)->EA_PORTADO)
					::oCab:Item[nX]:EMISSAO      := DTOC(STOD((cAlias)->E1_EMISSAO))
					::oCab:Item[nX]:VENCIMENTO   := DTOC(STOD((cAlias)->E1_VENCTO))
					::oCab:Item[nX]:VALOR := (cAlias)->E1_VALOR
					::oCab:Item[nX]:SALDO := (cAlias)->E1_SALDO


//				EndIf

				(cAlias)->(DBSkip())
				
				
			enddo

			(cAlias)->(DBCloseArea())
			*/	
		Else
			::oCab := WSClassNew("NOSSONUMERO_CAB")
			::oCab:CGC := ""
			::oCab:NOME := "Falha no login"
			::oCab:Item:={}
			
				aAdd(::oCab:Item, WSClassNew("NOSSONUMERO_ITENS") )
				nX := Len(::oCab:Item)
				::oCab:Item[nX]:CNPJ_EMISSOR := ""
				::oCab:Item[nX]:NOME_EMISSOR := ""
				::oCab:Item[nX]:NOSSONUMERO := ""
				::oCab:Item[nX]:BANCO := ""
				::oCab:Item[nX]:EMISSAO      := ""
				::oCab:Item[nX]:VENCIMENTO   := ""
				::oCab:Item[nX]:VALOR := 0
				::oCab:Item[nX]:SALDO := 0
		EndIf
	Else
			::oCab := WSClassNew("NOSSONUMERO_CAB")
			::oCab:CGC := ""
			::oCab:NOME := "Falha no login"
			::oCab:Item:={}
			
				aAdd(::oCab:Item, WSClassNew("NOSSONUMERO_ITENS") )
				nX := Len(::oCab:Item)
				::oCab:Item[nX]:CNPJ_EMISSOR := ""
				::oCab:Item[nX]:NOME_EMISSOR := ""
				::oCab:Item[nX]:NOSSONUMERO := ""
				::oCab:Item[nX]:BANCO := ""
				::oCab:Item[nX]:EMISSAO      := ""
				::oCab:Item[nX]:VENCIMENTO   := ""
				::oCab:Item[nX]:VALOR := 0
				::oCab:Item[nX]:SALDO := 0

	EndIf
	
If lAuto
	RpcClearEnv()
EndIf	


Return .T.

//----------------------------------
// Estrutura de um item da solicitacao
wsstruct NOSSONUMERO_CAB
	
	WSDATA CGC 	AS STRING
	WSDATA NOME 		AS STRING
	WSDATA Item as array of NOSSONUMERO_ITENS OPTIONAL
	
	
endwsstruct

//----------------------------------
// Estrutura de um item da solicitacao
wsstruct NOSSONUMERO_ITENS

	WSDATA CNPJ_EMISSOR AS STRING
	WSDATA NOME_EMISSOR AS STRING
	WSDATA NOSSONUMERO	AS STRING
	WSDATA BANCO    	AS STRING
	WSDATA EMISSAO      AS STRING
	WSDATA VENCIMENTO   AS STRING
	WSDATA VALOR        as FLOAT
	WSDATA SALDO        AS FLOAT	

endwsstruct


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
	NN := padr((cAlias)->E1_NUMBCO,8,'0' )
EndIf
          
 If SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
	NN := padr((cAlias)->E1_NUMBCO,8,'0' )
EndIf

IF SuBStr(cBanco,1,3) == '341' //.OR. SuBStr(cBanco,1,3) == '001' // Incluido 04.09.2017 -- Andre/Rsac
	s:= AllTrim(cAgencia) + SubStr(alltrim(cConta),1,5) + "109" + SubStr(alltrim(NN),1,8) // incluido em 19/02/03
	dvnn := modulo10(s)		
	
	s := cBanco      + Alltrim(Str(_nFator)) + blvalorfinal + "109" + SubStr(alltrim(NN),1,8)+Alltrim(dvnn) +AllTrim(cAgencia) + SubStr(alltrim(cConta),1,6) + "000"
	
	dvcb := str(Mod11CB(s))
	CB := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s, 5, 39)
	
	// Linha digitavel
	//   banco+ moeda   carteira    2 primeiros digitos do nosso numero
	s := cBanco       + "109"     + SubStr(NN, 1, 2)
	dv := modulo10(s)
	RN := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(dv) + ' '
	
	//   Restante do nosso numero  DAC (NN)  3 pos. inic. agencia
	s := SubStr(NN, 3, 6)          +Alltrim(dvnn)  + SubStr(cAgencia, 1, 3)
	dv := modulo10(s)
	RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(dv) + ' '
	
	//   Resto da agencia         conta                         dac conta
	s := SubStr(cAgencia, 4, 1) + SubStr(alltrim(cConta),1,6)+ "000"
	dv := modulo10(s)
	RN := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(dv) + ' '
	
	RN := RN + AllTrim(dvcb) + ' '
	RN := RN + Alltrim(Str(_nFator)) + blvalorfinal
	// monta o nosso numero com o digito verificador
	NN:= NN + "-" + Alltrim(dvnn)
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
	
EndIf
Return({CB,RN,NN})

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




Static Function Modulo10(cData)
Local Soma, Mult, M, N
Local i

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
Return(alltrim(str(DV)))

