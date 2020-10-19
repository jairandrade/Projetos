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
!Nome              ! TCP                                                     !        	
+------------------+---------------------------------------------------------+
!Descricao         ! Preenche as informacoes para pagamento de tributos      !
!		   		   ! utilizando o sispag				                     !
+------------------+---------------------------------------------------------+
!Atualizado por    ! Douglas Giovanni Negrello                 		         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/08/2012                                              !
+------------------+---------------------------------------------------------+
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"
                             
//Recebe o valor de Modelo de pagamento(SEA->EA_MODELO)
User Function AFIN001(cModelo)   
 
//Modelos de pagamento(EA_MODELO)(TABELA 58, SX5)
If 		cModelo == "17"							//Pagamento de GPS
	cDados	:=  AFIN001A()
ElseIf 	cModelo == "16"							//Pagamento de DARF             
	cDados	:= 	AFIN001B()
ElseIf 	cModelo == "11"							//Pagamento de FGTS-GFIP
	cDados	:= 	AFIN001C() 
ElseIf 	cModelo == "03"	.OR. cModelo == "41" .OR. cModelo == "43"	//Pagamento DOC TED
	cDados	:= 	AFIN001D() 
ElseIf 	cModelo == "01"							//Pagamento Credito em conta
	cDados	:= 	AFIN001E() 
Else
	Alert("Modelo de pagamento não contemplado pelo SISPAG")
	//Return
EndIf             

//cDados := ""//Composição da string formada pelos dados das diferentes formas de pagamento.
Return (cDados)                          

Static Function AFIN001A
/*==========================GPS=====================================
TRIBUTO 	   		|IDENTIFICAÇÃO DO TRIBUTO						|018|019|9(02)Z		|01 = GPS
CÓDIGO DE PAGTO 	|CÓDIGO DE PAGAMENTO	   						|020|023|9(04)		|NOTA 20
COMPETÊNCIA	   		|MÊS E ANO DA COMPETÊNCIA  						|024|029|9(06)		|MMAAAA
IDENTIFICADOR 		|IDENTIFICAÇÃO CNPJ/CEI/NIT/PIS DO CONTRIBUINTE |030|043|9(14)      |
VALOR DO TRIBUTO 	|VALOR PREVISTO DO PAGAMENTO DO INSS 			|044|057|9(12)V9(02)| 
VALOR OUTR.ENTIDADE |VALOR DE OUTRAS ENTIDADES 						|058|071|9(12)V9(02)|
ATUALIZ. MONETÁRIA 	|ATUALIZAÇÃO MONETÁRIA 							|072|085|9(12)V9(02)|
VALOR ARRECADADO 	|VALOR ARRECADADO 								|086|099|9(12)V9(02)|
DATA ARRECADAÇÃO 	|DATA DA ARRECADAÇÃO/ EFETIVAÇÃO DO PAGAMENTO 	|100|107|9(08) 		|DDMMAAAA
BRANCOS 			|COMPLEMENTO DO REGISTRO 						|108|115|X(08)      |
USO EMPRESA 		|INFORMAÇÕES COMPLEMENTARES 					|116|165|X(50)  	|NOTA 21
CONTRIBUINTE 		|NOME DO CONTRIBUINTE 							|166|195|X(30)		|NOTA 22
*/ 
Local cTribu	:=	"01"//AllTrim(SubStr(SEA->EA_MODELO,1,2))	
Local cPagto	:=	AllTrim(SubStr(SE2->E2_CODPGPS,1,4))//necessario criar o campo na SE2(SE2->E2_CODPAG, C, 4)
Local cCompe  	:=	Alltrim(SubStr(SE2->E2_MESBASE,1,2) + SubStr(SE2->E2_ANOBASE,1,4))
Local cIdent	:=	AllTrim(SubStr(SE2->E2_IDENGPS,1,14))
Local cVTrib	:=	STRTRAN(AllTrim(SubStr(CValToChar(SE2->E2_SALDO*100),1,14)),".","")
Local cVEnti	:=	"0"//???                                      
Local cMonet	:=	"0"//???
Local cVArre	:=	"0"//???
Local cDArre	:=	Alltrim(SubStr(DToS(SE2->E2_VENCREA),7,2) + SubStr(DToS(SE2->E2_VENCREA),5,2) + SubStr(DToS(SE2->E2_VENCREA),1,4))// (AAAAMMDD)
Local cBranc	:=	Replicate(" ",8)//???
Local cInfor	:=	Replicate(" ",50)//???
Local cContr	:=	AllTrim(SubStr(SM0->M0_NOMECOM,1,30))

cDados := PADL(cTribu,2,"0")
cDados += PADL(cPagto,4,"0")
cDados += PADL(cCompe,6,"0")
cDados += PADR(cIdent,14,"0")
cDados += PADL(cVTrib,14,"0")
cDados += PADL(cVEnti,14,"0")
cDados += PADL(cMonet,14,"0")
cDados += PADL(cVArre,14,"0")
cDados += PADL(cDArre,8,"0")
cDados += PADL(cBranc,8)
cDados += PADL(cInfor,50)
cDados += PADR(cContr,30)

Return (cDados)

Static Function AFIN001B
/*==========================DARF====================================
TRIBUTO 			|IDENTIFICAÇÃO DO TRIBUTO 						|018|019|9(02) 		|02 = DARF
RECEITA				|CÓDIGO DA RECEITA								|020|023|9(04)      |
EMPRESA – INSCRIÇÃO |TIPO DE INSCRIÇÃO DO CONTRIBUINTE 				|024|024|9(01) 		|1 = CPF 2 = CNPJ
INSCRIÇÃO NÚMERO  	|CPF OU CNPJ DO CONTRIBUINTE                    |025|038|9(14)		|NOTA 34
PERÍODO 			|PERÍODO DE APURAÇÃO 							|039|046|9(08) 		|DDMMAAAA
REFERÊNCIA			|NÚMERO DE REFERÊNCIA							|047|063|9(17)      |
VALOR PRINCIPAL 	|VALOR PRINCIPAL 								|064|077|9(12)V9(02)|
MULTA				|VALOR DA MULTA									|078|091|9(12)V9(02)|
JUROS/ENCARGOS 		|VALOR DOS JUROS/ENCARGOS 						|092|105|9(12)V9(02)|
VALOR TOTAL			|VALOR TOTAL A SER PAGO							|106|119|9(12)V9(02)|
DATA VENCIMENTO 	|DATA DE VENCIMENTO 							|120|127|9(08) 		|DDMMAAAA
DATA PAGAMENTO		|DATA DO PAGAMENTO 								|128|135|9(08)		|DDMMAAAA
BRANCOS 			|COMPLEMENTO DE REGISTRO 						|136|165|X(30)		|
CONTRIBUINTE		|NOME DO CONTRIBUINTE							|166|195|X(30)		|NOTA 22
*/
Local cTribu	:=	"02"//AllTrim(SubStr(SEA->EA_MODELO,1,2))
Local cRecei	:=	ALLTRIM(SE2->E2_CODRET)//???
Local cTpIns	:=	IIF(LEN(SM0->M0_CGC)>11,2,1)
Local cInscr	:=	AllTrim(SubStr(SM0->M0_CGC,1,14))
Local cPerio	:=	AllTrim(SubStr(DToS(SE2->E2_EMISSAO),7,2) + SubStr(DToS(SE2->E2_EMISSAO),5,2) + SubStr(DToS(SE2->E2_EMISSAO),1,4))// (AAAAMMDD)
local cRefer	:=	"0"//StrZero(SE2->E2_REFER,1,17)//Campo precisa ser criado(SE2->E2_REFER, C, 17,0)
Local cVPrin	:=	STRTRAN(AllTrim(SubStr(CValToChar(SE2->E2_SALDO*100),1,14)),".","")   
Local cVMult	:=	STRTRAN(AllTrim(SubStr(CValToChar(SE2->E2_MULTA*100),1,14)),".","")
Local cVJuro	:=	STRTRAN(AllTrim(SubStr(CValToChar(SE2->E2_JUROS*100),1,14)),".","")
Local cVTota	:=	STRTRAN(AllTrim(SubStr(CValToChar(SE2->E2_SALDO*100),1,14)),".","")
Local cVenci	:=	AllTrim(SubStr(DToS(SE2->E2_VENCTO),7,2) + SubStr(DToS(SE2->E2_VENCTO),5,2) + SubStr(DToS(SE2->E2_VENCTO),1,4))// (AAAAMMDD)
Local cPagam	:=	AllTrim(SubStr(DToS(SE2->E2_VENCTO),7,2) + SubStr(DToS(SE2->E2_VENCTO),5,2) + SubStr(DToS(SE2->E2_VENCTO),1,4))// (AAAAMMDD)
Local cCompl	:=	Replicate(" ",30)//???
Local cContr	:=	AllTrim(SubStr(SM0->M0_NOMECOM,1,30))

cDados := PADL(cTribu,2,"0")
cDados += PADL(cRecei,4,"0")
cDados += PADL(cTpIns,1,"0")
cDados += PADL(cInscr,14,"0")
cDados += PADL(cPerio,8,"0")
cDados += PADL(cRefer,17,"0")
cDados += PADL(cVPrin,14,"0")
cDados += PADL(cVMult,14,"0")
cDados += PADL(cVJuro,14,"0")
cDados += PADL(cVTota,14,"0")
cDados += PADL(cVenci,8,"0")
cDados += PADL(cPagam,8,"0")
cDados += PADR(cCompl,30)
cDados += PADR(cContr,30)

Return (cDados)

Static Function AFIN001C 

/*==========================FGTS - GRF/GRRF/GRDE====================     
TRIBUTO 			|IDENTIFICAÇÃO DO TRIBUTO 						|018|019|9(02) 		|11=FGTS-GFIP
RECEITA     		|CÓDIGO DA RECEITA  							|020|023|9(04)      |
TIPO IDENT.CONTRIB. |TIPO DE INSCRIÇÃO DO CONTRIBUINTE 				|024|024|9(01) 		|1 = CNPJ 2 = CEI
INSCRIÇÃO NÚMERO  	|CPF OU CNPJ DO CONTRIBUINTE   					|025|038|9(14)      |
COD.BARRAS 			|CODIGO DE BARRAS 								|039|086|X(48) 		|
IDENTIFICADOR 		|IDENTIFICADOR DO FGTS 							|087|102|9(16)      |
LACRE 				|LACRE DE CONECTIVIDADE SOCIAL 					|103|111|9(09)      |
DIGITO DO LACRE 	|DIGITO DO LACRE DE CONECTIVIDADE SOC. 			|112|113|9(02)      |
NOME CONTRIBUINTE 	|NOME DO CONTRIBUINTE 							|114|143|X(30)      |
DATA PAGAMENTO 		|DATA DO PAGAMENTO 								|144|151|9(08) 		|DDMMAAAA 
VALOR PAGAMENTO 	|VALOR DO PAGAMENTO 							|152|165|9(12)V9(02)| 
BRANCOS 			|COMPLEMENTO DE REGISTRO 						|166|195|X(30)      |
*/  
Local cTribu	:=	"11"//AllTrim(SubStr(SEA->EA_MODELO,1,2))	
Local cRecei	:=	"0"//SubStr(SE2->E2_CODREC,1,4)//Criar campo (SE2->E2_CODREC, C, 04,0)
Local cTpIns	:=	IIF(LEN(SM0->M0_CGC)>11,2,1)
Local cInscr	:=	AllTrim(SubStr(SM0->M0_CGC,1,14))
Local cCodba	:=	AllTrim(SE2->E2_CODBAR)
local cIFgts	:=	"0"//StrZero(SE2->E2_IFGTS,1,16)//Campo precisa ser criado(SE2->E2_IFGTS, C, 16,0) Identificador do FGTS
Local cLacre	:=	"0"//StrZero(SE2->E2_LACRE,9)//Campo precisa ser criado(SE2->E2_LACRE, C, 9, 0) Lacre de conectividade social
Local cDvLac	:=	"0"//StrZero(SE2->E2_DVCRE,2)//Campo precisa ser criado(SE2->E2_DVCRE, C, 2s, 0) Digito do Lacre de conectividade social
Local cContr	:=	AllTrim(SubStr(SM0->M0_NOMECOM,1,30))
Local cPagam	:=	AllTrim(SubStr(DToS(SE2->E2_VENCTO),7,2) + SubStr(DToS(SE2->E2_VENCTO),5,2) + SubStr(DToS(SE2->E2_VENCTO),1,4))// (AAAAMMDD)//???
Local cVPaga	:=	AllTrim(SubStr(CValToChar(SE2->E2_SALDO*100),1,14))
Local cCompl	:=	Replicate(" ",30)//???

cDados := PADL(cTribu,2,"0")
cDados += PADL(cRecei,4,"0")
cDados += PADL(cTpIns,1,"0")
cDados += PADL(cInscr,14,"0")
cDados += PADR(cCodba,48)
cDados += PADL(cIFgts,16,"0")
cDados += PADL(cLacre,9,"0")
cDados += PADL(cDvLac,2,"0")
cDados += PADR(cContr,30)
cDados += PADL(cPagam,8,"0")
cDados += PADL(cVPaga,14,"0")
cDados += PADR(cCompl,30)

Return (cDados)   
                                                                                                                         
Static Function AFIN001D
/*========================== DOC - TED ==========================
CONTA		NÚMERO DE C/C CREDITADA 		030   041	9(12)
BRANCOS		COMPLEMENTO DE REGISTRO 		042   042	X(01)
DAC 		DAC DA AGÊNCIA/CONTA CREDITADA	043   043	X(01)
*/
             
Local cConta	:= AllTrim(SA2->A2_CONCNAB)  
lOCAL cBrancos	:= ""
lOCAL cDAC		:= ""                       

cDados := PADL(cConta,12,"0")
cDados += PADL(cBrancos,1,"")
cDados += PADL(cDAC,1,"")

Return (cDados)
                                                                                                    
Static Function AFIN001E      
/*========================== CREDITO EM CONTA =================== 
ZEROS		COMPLEMENTO DE REGISTRO				030  035	9(06)
CONTA		NÚMERO DE C/C CREDITADA				036  041	9(06)
BRANCOS		COMPLEMENTO DE REGISTRO				042  042	X(01)
DAC			DAC  DA  AGÊNCIA/CONTA CREDITADA	043  043	9(01)
*/      
                                                
Local cZeros	:= ""
Local cConta	:= SubStr(CValToChar(Val(SA2->A2_CONCNAB)),1,Len(CValToChar(Val(SA2->A2_CONCNAB)))-1)
Local cBrancos	:= ""
Local cDAC		:= SubStr(CValToChar(Val(SA2->A2_CONCNAB)),-1,1)                       

cDados := PADL(cZeros,6,"0")
cDados += PADL(cConta,6,"0")
cDados += PADL(cBrancos,1,"")
cDados += PADL(cDAC,1,"0")

Return (cDados)