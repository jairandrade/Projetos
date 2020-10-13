#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH" 
 
/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSFLG020 - Execauto MATA030
@author Jair Matos
@since 26/07/2019
@version 1.0
/*/
User Function WSFLG020( aVetor, cOper, cEmp, cFil)
	Local cMsg := ""
	Local cRet := ""
	Local aReturn := {}
	//private lMsErroAuto := .F.

	DO CASE
		CASE 	cOper == 1
		aReturn := IncluiSA1( aVetor, cEmp, cFil )
		CASE	cOper == 2
		aReturn := AlteraSA1( aVetor, cEmp, cFil )
		OTHERWISE
		cMsg := .F. 

	ENDCASE

Return aReturn

Static Function IncluiSA1( aVetor, cEmp, cFil )
	Local cRet 	:= .F.
	Local aCod	:= {}
	Local cMsg := ""
	Local aReturn := {cRet,cMsg}
	Local cPath := ""
	Local cNomeArq := ""
	Local cEmpProx 	:= 	Iif(cEmp =="01","02","01")
	Local cCodigo 	:= ""
	Local cCodRet 	:= ""
	Local nPosDesc  := aScan(aVetor,{|x| AllTrim(x[1]) == "A1_COD"})
	Private lMsErroAuto := .F.
	Private INCLUI := .T.
	Private ALTERA := .F.
	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	cNumEmp := cEmpAnt+cFilAnt
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)
	cCodRet :=aVetor[nPosDesc,2]
	
	BeginTran()

	MSExecAuto({|x,y| Mata030(x,y)},aVetor,3)
	If lMsErroAuto// OPERAÇÃO EXECUTADA COM ERRO
		cMsg := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
		aReturn := {cRet,cMsg}
		DisarmTransaction()
	Else // OPERAÇÃO FOI EXECUTADA COM SUCESSO
		cRet := .T.
		aReturn := {cRet,cMsg}
		//Grava o Conteudo do Parametro de Acordo com a Empresa de Referencia
		If substr(cCodRet,1,1)=="1"  //Clientes Intercompany  100000 - 199999
			cCodigo := "MV_XFX1CLI"
		ElseIf substr(cCodRet,1,1) =="2"//Clientes Diversos  200000-299999
			cCodigo := "MV_XFX2CLI"
		ElseIf substr(cCodRet,1,1) =="3"//Operadoras de Cartões  300000-399999
			cCodigo := "MV_XFX3CLI"
		ElseIf substr(cCodRet,1,1) =="4"//Consumidor Final 400000-499999
			cCodigo := "MV_XFX4CLI"
		ElseIf substr(cCodRet,1,1) =="9"//Cliente Padrão Restaurantes  900000-999999
			cCodigo := "MV_XFX9CLI"
		EndIf
		dbSelectArea("SX6")  //Tabela de Parametros
		SX6->(DBSetOrder(1)) //X6_FIL+X6_VAR
		If(SX6->(DbSeek(xFilial('SX6')+cCodigo)) )
			If cCodRet > SX6->X6_CONTEUD
				RecLock('SX6',.F.)
				SX6->X6_CONTEUD := cCodRet
				SX6->X6_CONTSPA := SX6->X6_CONTEUD
				SX6->X6_CONTENG := SX6->X6_CONTEUD
				MsUnlock()
				//Grava o Conteudo do Parametro de Acordo com a Empresa de Referencia
				StartJob( "U_COMX002P" , GetEnvServer() , .T. , cEmpProx , "" , cCodigo ,cCodRet  , .T. )
			EndIf
		EndIF
	EndIf

	EndTran()

Return aReturn //cRet

Static Function AlteraSA1( aVetor, cEmp, cFil )
	Local cMsg := ""
	Local cRet 	:= .F.
	Local aCod	:= {}
	Local aReturn := {cRet,cMsg}
	Local cPath := ""
	Local cNomeArq := "" 
	Private lMsErroAuto := .F.
	Private ALTERA := .T.
	Private INCLUI := .F.

	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	cNumEmp := cEmpAnt+cFilAnt
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)

	BeginTran()

	MSExecAuto({|x,y| MATA030(x,y)},aVetor,4)

	If lMsErroAuto// OPERAÇÃO EXECUTADA COM ERRO
		cMsg := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
		aReturn := {cRet,cMsg}
		DisarmTransaction()
	Else// OPERAÇÃO FOI EXECUTADA COM SUCESSO
		cRet := .T.
		aReturn := {cRet,cMsg}
	EndIf

	EndTran()

Return aReturn //cRet