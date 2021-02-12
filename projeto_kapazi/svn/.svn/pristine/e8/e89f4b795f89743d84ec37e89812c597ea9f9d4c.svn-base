#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SANIBRAS_PE_FINA420    ºAutor  ³RODRIGO SLISINSKI   º Data ³  09/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  PONTO DE ENTRADA PARA PREENCHIMENTO DE DADOS DE PAGAMENTO º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                      				                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION F240TDOK()

lRet:=.T.
lRet1:=.T.

dbSelectArea(cAliasSE2)
dbGotop( )

While !(cAliasSE2)->( Eof( ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se titulo marcado -> gera o bordero com ele.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSE2)->E2_OK == cMarca				        	
		lRet:=cadpg()  
		if !lRet
			lret1:=.f.
		EndIF                    
	EndIF
	
	(cAliasSE2)->(dbSkip())
EndDo
dbSelectArea(cAliasSE2)
dbGotop( )
RETURN lret1


Static Function cadpg()

Local _cPref	:= (cAliasSE2)->E2_PREFIXO
Local _cNumt	:= (cAliasSE2)->E2_NUM
Local _cParc	:= (cAliasSE2)->E2_PARCELA
Local _cNome	:= posicione('SA2',1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_NOME')
Local _nVal		:= (cAliasSE2)->E2_VALOR+(cAliasSE2)->E2_ACRESC -(cAliasSE2)->E2_DECRESC
Local _nSld		:= (cAliasSE2)->E2_SALDO
Local _dVenc	:= (cAliasSE2)->E2_VENCTO
Local _cLingig	:= SPACE(TAMSX3('E2_LINDIG')[1])
Local _cCodBar	:= SPACE(TAMSX3('E2_CODBAR')[1])
Local _oPref
Local _oNumt
Local _oParc
Local _oNome
Local _oVal
Local _oSld
Local _oVenc
Local _oCodC
Local _oLojC
//EDITADO - MARCOS SULIVAN  
Local aCpms := {}        
Private lOk:=.f.     	

Private _cCodC	:= (cAliasSE2)->E2_FORNECE
Private _cCLojC	:= (cAliasSE2)->E2_LOJA

Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
{"Visualizar", "AxVisual", 0, 2},;
{"Incluir", "AxInclui", 0, 3},;
{"Alterar", "AxAltera", 0, 4},;
{"Excluir", "AxDeleta", 0, 5}}


aCOls:={}

if cModPgto $ '30/31/13/91/19'
     If !Empty((cAliasSE2)->E2_CODBAR)
     	return .t.
     ELSE 
     	aCpms:={'E2_LINDIG','E2_CODBAR'}               "
     		aadd(aCOls,{space(tamsx3('E2_LINDIG')[1]),space(tamsx3('E2_CODBAR')[1]),.f.	})
     EndIf
Endif   
if cModPgto $ '01/03/05/41/43'
     	dbSelectArea('SA2')
     	DBSetOrder(1)
     	dbSeek(xFilial('SA2')+_cCodC+_cCLojC)     	
     	aCpms:={'E2_BCOFOR','E2_AGFOR','E2_DIGAGEN','E2_CTAFOR','E2_DIGCTA'} 
     	/*
     	
     	*/
     	cSql:= " Select * from "+RETSQLNAME("FIL")
     	cSql+= " WHERE FIL_FORNEC=''"
     	cSql+= " AND FIL_LOJA=''
     	cSql+= " AND FIL_TIPO='1'
     	cSql+= " AND D_E_L_E_T_<>'*'"
     	iF Select('TRFIL')<>0
     		TRFIL->(DBCloseArea())
     	EndIf
     	TCQuery cSql New Alias 'TRFIL'
     	
     	aadd(aCOls,{TRFIL->FIL_BANCO,TRFIL->FIL_AGENCI,TRFIL->FIL_DVAGE,TRFIL->FIL_CONTA,TRFIL->FIL_DVCTA,.f.	})
Endif 

if cModPgto $ '17'         	
     	aCpms:={'E2_CDPGGP','E2_COMPGPS','E2_VLROUTE','E2_ATMJUR','E2_VLINSS'}
     	aadd(aCOls,{(cAliasSE2)->E2_CDPGGP,(cAliasSE2)->E2_COMPGPS,(cAliasSE2)->E2_VLROUTE,(cAliasSE2)->E2_ATMJUR,(cAliasSE2)->E2_VLINSS,.f.	})
Endif        

if cModPgto $ '35'         	
     	aCpms:={'E2_CDPGGP','E2_IDFGTS','E2_LACREF','E2_LINDIG','E2_CODBAR'}
     	aadd(aCOls,{(cAliasSE2)->E2_CDPGGP,(cAliasSE2)->E2_IDFGTS,(cAliasSE2)->E2_LACREF,space(tamsx3('E2_LINDIG')[1]),space(tamsx3('E2_CODBAR')[1]),.f.	})
Endif        


if cModPgto $ '16/18'             	
     	aCpms:={'E2_CODREC','E2_PERDAR','E2_REFDAR','E2_VALPRI','E2_VALMLT','E2_JUREND'}
     	aadd(aCOls,{(cAliasSE2)->E2_CODREC,(cAliasSE2)->E2_PERDAR,(cAliasSE2)->E2_REFDAR,(cAliasSE2)->E2_VALPRI,(cAliasSE2)->E2_VALMLT,(cAliasSE2)->E2_JUREND,.f.	})
Endif        


aHeader:={}
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For _nX := 1 to Len(aCpms)
	If SX3->(DbSeek(aCpms[_nX]))
		Aadd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	Endif
Next _nX


DEFINE MSDIALOG oDlgTit TITLE "[PAGAMENTOS]" From 001,001 to 400,1000 Pixel

@ 35, 10 SAY  "Prefixo" SIZE 025, 007 OF oDlgTit  PIXEL
@ 34, 30 MSGET _oPref VAR _cPref SIZE 030, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 35, 70 SAY  "Numero" SIZE 025, 007 OF oDlgTit COLORS 0, 16777215 PIXEL
@ 34, 100 MSGET _oNumt VAR _cNumt SIZE 040, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 35, 150 SAY  "Parcela" SIZE 025, 007 OF oDlgTit COLORS 0, 16777215 PIXEL
@ 34, 170 MSGET _oParc VAR _cParc SIZE 030, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 35, 210 SAY  "Cliente" SIZE 025, 007 OF oDlgTit COLORS 0, 16777215 PIXEL
@ 34, 230 MSGET _oCodc VAR _cCodc SIZE 030, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 35, 260 SAY  "Loja" SIZE 025, 007 OF oDlgTit COLORS 0, 16777215 PIXEL
@ 34, 280 MSGET _oCLojC VAR _cCLojC SIZE 030, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 35, 310 SAY  "Nome" SIZE 025, 007 OF oDlgTit COLORS 0, 16777215 PIXEL
@ 34, 330 MSGET  _oNome VAR _cNome SIZE 140, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 50, 10 SAY  "Venc." SIZE 025, 007 OF oDlgTit  PIXEL
@ 49, 30 MSGET _oVenc VAR _dVenc SIZE 040, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 50, 70 SAY  "Valor" SIZE 025, 007 OF oDlgTit  PIXEL
@ 49, 100 MSGET _oVal VAR _nVal PICTURE "@E 999,999,999.99" SIZE 060, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL

@ 50, 210 SAY  "Saldo" SIZE 025, 007 OF oDlgTit  PIXEL
@ 49, 230 MSGET _oVal VAR _nVal PICTURE "@E 999,999,999.99" SIZE 060, 010 WHEN .F. OF oDlgTit COLORS 0, 16777215 PIXEL


_oLista := MsGetDados():New(80, 07, 150, 490,4,"U_vlln()","","",.F.,aCpms,,,1)


ACTIVATE MSDIALOG oDlgTit CENTERED ON INIT (EnchoiceBar(oDlgTit,{|lOk|lOk:=grtit(oDlgTit)},{||lOk:=.F.,oDlgTit:End()}))
     
if lOk  
//	oDlgTit:End()
Else
    return .F.
EndIF

Return .t.
      

Static Function grtit(oDlgTit)
	cTemp:=""
	for nk:=1 to len(acols[1])-1
		cTemp+=alltrim(acols[1][nk])
	Next                                                                                                                      
	if empty(alltrim(cTemp))
		alert('Obrigatorio digitar os dados para proceguir')
		return .f.
	EndIF
	
	SE2->(dbSelectArea('SE2'))
	SE2->(DBSetOrder(1))
	SE2->(dbseek((cAliasSE2)->E2_FILIAL+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PARCELA+(cAliasSE2)->E2_TIPO+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA))
	SE2->(Reclock('SE2',.F.) )
	if cModPgto $ '30/31/13/91/19'
	     SE2->E2_LINDIG:=ACOLS[1][1]
	     SE2->E2_CODBAR:=ACOLS[1][2]	     
	EndIF
	if cModPgto $ '01/03/05/41/43'
		SE2->E2_BCOFOR:=ACOLS[1][1]
		SE2->E2_AGFOR:=ACOLS[1][2]
		SE2->E2_DIGAGEN:=ACOLS[1][3]
		SE2->E2_CTAFOR:=ACOLS[1][4]
		SE2->E2_DIGCTA:=ACOLS[1][5]
	EndIF
	
	if cModPgto $ '17' 
		SE2->E2_CDPGGP	:= ACOLS[1][1]
		SE2->E2_COMPGPS	:= ACOLS[1][2]
		SE2->E2_VLROUTE	:= ACOLS[1][3]
		SE2->E2_ATMJUR	:= ACOLS[1][4]
		SE2->E2_VLINSS 	:= ACOLS[1][5]
	EndIF
	
	if cModPgto $ '35'         	
	     	SE2->E2_CDPGGP:= ACOLS[1][1]
				SE2->E2_IDFGTS:= ACOLS[1][2]
				SE2->E2_LACREF:= ACOLS[1][3]
				SE2->E2_LINDIG:= ACOLS[1][4]
				SE2->E2_CODBAR:= ACOLS[1][5]             	
	Endif
	if cModPgto $ '16/18' 
		SE2->E2_CODREC	:= ACOLS[1][1]
		SE2->E2_PERDAR	:= ACOLS[1][2]
		SE2->E2_REFDAR	:= ACOLS[1][3]
		SE2->E2_VALPRI	:= ACOLS[1][4]
		SE2->E2_VALMLT 	:= ACOLS[1][5]
		SE2->E2_JUREND 	:= ACOLS[1][6]
	EndIF
	SE2->(MSUnlock())
	lOk:=.t.
	oDlgTit:End()

Return .t. 




user function F240BORD()
	
cAlias:='SE2'
Private cPerg   := "AFI420"
Pergunte(cPerg,.f.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros 		 ³
//³ mv_par01		 // Do Bordero 		  		 ³
//³ mv_par02		 // Ate Bordero   	  		 ³
//³ mv_par03		 // Arq.Configuracao   		 ³
//³ mv_par04		 // Arq. Saida			  		 ³
//³ mv_par05		 // Banco       		  		 ³
//³ mv_par06		 // Agencia 			  		 ³
//³ mv_par07		 // Conta       		  		 ³
//³ mv_par08		 // Sub-Conta			  		 ³
//³ mv_par09 		 // Modelo 1/Modelo 2  		 ³
//³ mv_par10		 // Cons.Filiais Abaixo		 ³
//³ mv_par11		 // Filial de     	       ³
//³ mv_par12		 // Filial Ate 		  		 ³
//³ mv_par13		 // Receita Bruta Acumulada ³

/*
Private cBanco   	:= CriaVar("E1_PORTADO")
Private cAgencia 	:= CriaVar("E1_AGEDEP")
Private cConta 		:= CriaVar("E1_CONTA")
*/
Private nHdlBco 	:=0,nHdlSaida:=0,nSeq:=0,cBanco,cAgencia,nSomaValor := 0
Private nSomaCGC	:=0,nSomaData:=0
//Private aRotina 	:= MenuDef()
PRIVATE xConteudo
PRIVATE nTotCnab2 	:= 0 // Contador de Lay-out nao deletar 
PRIVATE nLinha 		:= 0 // Contador de LINHAS, nao deletar
PRIVATE nSomaVlLote	:= 0
PRIVATE nQtdTotTit 	:= 0
PRIVATE nQtdTitLote	:= 0
PRIVATE nQtdLinLote	:= 0
PRIVATE nTotLinArq 	:= 0
PRIVATE nLotCnab2 	:= 1		//Contador de lotes do CNAB2

dbSelectArea('SEE')
DbSetOrder(1)
if !dbseek(xFilial('SEE')+cPort240+cAgen240+cConta240+'000')
    aviso("Parametros de banco ","Cadastrar parametro de banco com a sub-conta '000' ",{'OK'})
 	return
EndIF 
//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
mv_par01 := cNumBor		 	// Do Bordero 		  		 ³
mv_par02 := cNumBor		 	// Ate Bordero   	  		 ³
mv_par03 := SEE->EE_ARQEP	// Arq.Configuracao   		 ³
mv_par04 := ALLTRIM(SEE->EE_LOCGRP)+'\'+cNumBor			 // Arq. Saida			  		 ³
mv_par05 := SEE->EE_CODIGO		 // Banco       		  		 ³
mv_par06 := SEE->EE_AGENCIA		 // Agencia 			  		 ³
mv_par07 := SEE->EE_CONTA		 // Conta       		  		 ³
mv_par08 := SEE->EE_SUBCTA		 // Sub-Conta			  		 ³
mv_par09 := IIF(SEE->EE_NRBYTES>240,1,2)		 // Modelo 1/MJodelo 2  		 ³
mv_par10 := 2		 // Cons.Filiais Abaixo		 ³
mv_par11 :=""			 // Filial de     	       ³
mv_par12 :="ZZ"		 // Filial Ate 		  		 ³
mv_par13 :=0			 // Receita Bruta Acumulada ³
Fa420Gera(cAlias)//Fa420Ger()  
aviso("Arquivo Gerado","Arquivo gerado com sucesso!"+chr(13)+chr(10)+"No seguinte caminho: "+mv_par04,{"Ok"})

         
return


User FUnction vlln


Return .t.              


/*ponto de entrada para tratar retorno contas a pagar*/       

user Function FA430OCO

  DBSElectarea('SEB') 
  DBSETORDER(1)
  SEB->(dbSeek(xFilial("SEB")+mv_par05+cOcorr+"P"))
 
  

Return
  

