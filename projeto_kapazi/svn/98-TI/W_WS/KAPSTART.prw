#include 'protheus.ch'
#include 'parmtype.ch'

/**********************************************************************************************************************************/
/** WS                                                                                                                          **/
/** Rotina que chama o bat reiniciaWS.bat para reiniciar o webservice devido ao erro no comentario abaixo                        **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** KAPAZI                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 19/09/2018 | Antonio Rafael Santos Prestes  | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/

/*
Quando excede o número de licenças FULL do protheus o webservice nao consegue se conectar, gerando o erro abaixo.
Este fonte faz um wrapper nas funções __WSSTART e __WSCONNECT e trata os erros reiniciando o appserver

=======================
o conteúdo do bat D:\reiniciaWS.bat deve ser:

@echo off

REM **********************************
REM * ESTE BAT FOI DESENVOLVIDO PARA *
REM * REINICIAR O SERVICO DO FLUIG   *
REM **********************************

taskkill /F /FI "SERVICES eq .TOTVS12-Appserver-WS_FLUIG" 
wmic service where "name like '.TOTVS12-Appserver-WS_FLUIG'" call startservice
=======================

ADVPL WSDL Server 1.110216 ONLOAD  FATAL ERROR 

-------------------------------------------------------------------------------

Environment .........: WS_FLUIG

Date / Time .........: 20180919 14:59:49

Description .........: 


THREAD ERROR ([23976], JOB_WS, THIS)   19/09/2018 14:59:49
Muitos usuários on RPCSETENV(TBICONN.PRW) 15/05/2018 17:39:50 line : 634

[TOTVS build: 7.00.131227A-20180425 NG]
Called from RPCSETENV(TBICONN.PRW) 15/05/2018 17:39:50 line : 634
Called from __WSSTART(XMLWSVCS.PRW) 15/05/2018 17:39:45 line : 116
Called from U_KAPSTART(KAPSTART.PRW) 19/09/2018 14:55:00 line : 15
Called from STATICCALL(KAPSTART.PRW) 19/09/2018 14:55:00 line : 15
*/

user function KAPSTART()
Local 	oError 			:= ErrorBlock({|e| u_CHAMABAT()  })
local lRet := .F.

Conout(dtoc(date())+"/"+time()+"***")
Conout(dtoc(date())+"/"+time()+"*** KAPSTART ***")
Conout(dtoc(date())+"/"+time()+"***")

//Inicia a sequencia de erro
Begin Sequence

lRet := __WSSTART()
Conout(dtoc(date())+"/"+time()+"*** KAPSTART :"+cValtochar(lRet))

RECOVER
u_CHAMABAT()

//Finaliza a sequencia de erro
End Sequence

// captura de erro
ErrorBlock(oError)

if valtype(lRet) <> 'L'
lRet := .F.
EndIf


if !lRet
u_CHAMABAT()
EndIf

Return lRet

user function KAPCONNECT()
Local 	oError 			:= ErrorBlock({|e| u_CHAMABAT()  })
local cRet := ""

Conout(dtoc(date())+"/"+time()+"***")
Conout(dtoc(date())+"/"+time()+"*** KAPCONNECT ***")
Conout(dtoc(date())+"/"+time()+"***")

//Inicia a sequencia de erro
Begin Sequence

cRet := __WSCONNECT()
//Conout(dtoc(date())+"/"+time()+"*** KAPCONNECT :"+cValtochar(cRet))

RECOVER
u_CHAMABAT()

//Finaliza a sequencia de erro
End Sequence

// captura de erro
ErrorBlock(oError)

if valtype(cRet) <> 'C' .and. Empty(alltrim(cRet)) 
u_CHAMABAT()
EndIf

Return cRet


User Function CHAMABAT

Local cCommand := "D:\reiniciaWS.bat"
Local lWait := .F.
Local cPath := "D:\"

Conout(dtoc(date())+"/"+time()+"***")
Conout(dtoc(date())+"/"+time()+"*** CHAMABAT ***")
Conout(dtoc(date())+"/"+time()+"***")


WaitRunSrv( @cCommand , @lWait , @cPath )

BREAK

return
