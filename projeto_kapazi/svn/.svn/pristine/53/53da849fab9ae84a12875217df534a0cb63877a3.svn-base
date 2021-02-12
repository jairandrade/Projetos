#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "rwmake.ch"

//WebService
wsservice WS_UPDSCJ description "Atualiza ORCAMENTOS"

	// DECLARACAO DAS VARIVEIS GERAIS
	WSDATA LOGIN	as string
	WSDATA SENHA	as string
	WSDATA EMPRESA 	as string
	WSDATA FILIAL 	as string
	WSDATA ORCAMENTO as string
	WSDATA FLUIG	as string  //CJ_XNUMFLU

	// VARIAVEIS DE RETORNO
	WSDATA sSTATUS   as string
	
	// DECLARACAO DOS METODOS	
	wsmethod UPDATE	 description "Atualiza Orçamento"

endwsservice

//----------------------
//METODO UPDATE
//----------------------
wsmethod UPDATE wsreceive LOGIN,SENHA,EMPRESA,FILIAL,ORCAMENTO, FLUIG wssend sSTATUS wsservice WS_UPDSCJ
    Local aArea  := Getarea()
	Local cSQL, nStatus
	Local cOrcamento:=::ORCAMENTO
	Local cFluig:=::FLUIG
	
	cOrcamento:=Padr(cOrcamento, TamSX3('CJ_NUM')[1])
	cFluig:=Padr(cFluig, TamSX3('CJ_XNUMFLU')[1])

	PswOrder(2)
	//Valida se o nome de usuário
	If PswSeek(AllTrim(::LOGIN),.T.)
		//Valida a senha
		If PswName(::SENHA)
			cSQL:="Update "+RetSQLName('SCJ')+" SET CJ_XNUMFLU='"+cFluig+"' where CJ_FILIAL='"+xFilial('SCJ')+"' and CJ_NUM='"+cOrcamento+"' and CJ_XNUMFLU='' and D_E_L_E_T_='' "
			nStatus := TCSqlExec(cSQL)
			
			if (nStatus < 0)
			   ::sSTATUS := TCSQLError()			   
			   conout(::sSTATUS)
			else 
				::sSTATUS := 'OK'
			endif
		Else
			::sSTATUS := "Usuario e/ou senha invalidos!"
		EndIf
	Else
		::sSTATUS := "Usuario e/ou senha invalidos!"
	EndIf
	
	RestArea(aArea)
	
return .T.

