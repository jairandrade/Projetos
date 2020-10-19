#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "FWBROWSE.CH"
#include "fwmvcdef.ch"

//---------------------------
/*/{Protheus.doc} ACOM002
Tela para visualização do Log do Workflow de Cotações.

@author Lucas
@since 13/06/2014
@version 1.0
/*/
//---------------------------
User Function ACOM002()

Local aArea   := GetArea()
Local cTitulo := 'Log Workflow de Cotações'

Private aRegs   := {}
Private aRotina := {}
Private lMarca  := .F.
Private oBrowse := Nil // objeto do markbrowse

MenuDef() // dispara a criação de menus da rotina

oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'SZ0' )
	oBrowse:SetDescription( cTitulo )		
	oBrowse:DisableReport() // desabilita relatório de tela
	oBrowse:DisableConfig() // não permite configuração da tela
	oBrowse:Activate()
oBrowse := FreeObj(oBrowse)

RestArea(aArea)

Return

//---------------------------
/*/{Protheus.doc} MenuDef
Rotina para criação de menus para o browse, preenchedo array aRotina definido como private na rotina principal.

@author Lucas
@since 13/06/2014
@version 1.0

@protected
/*/
//---------------------------
Static Function MenuDef()

ADD OPTION aRotina TITLE "Pesquisar"  ACTION 'U_ACOM0020' OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION 'U_ACOM0020' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION 'U_ACOM0020' OPERATION 3 ACCESS 0

Return

//---------------------------
/*/{Protheus.doc} ACOM0020
Rotina definida para execução dos menus.

@author Lucas
@since 13/06/2014
@version 1.0

@param cAlias, character, Alias da Tela
@param nReg, numérico, Registro posicionado
@param nOpc, numérico, Opção para execução do menu
/*/
//---------------------------
User Function ACOM0020( cAlias, nReg, nOpc )

do case
	case nOpc == 1
		AxPesqui( cAlias, nReg, nOpc )
	
	case nOpc == 2
		AxVisual( cAlias, nReg, nOpc )
	
	case nOpc == 3
		if nReg == -1
			ACOM0021( cAlias, nReg, nOpc )
		endif
endcase

Return

//---------------------------
/*/{Protheus.doc} ACOM0021
Rotina insere dados na tabela SZ0. Os dados são repassados através do ParamIxb e seu retorno também é feito através do PAramIxb.

@author Lucas
@since 13/06/2014
@version 1.0

@param cAlias, character, Alias da Tela
@param nReg, numérico, Registro posicionado
@param nOpc, numérico, Opção para execução do menu

@protected
/*/
//---------------------------
Static Function ACOM0021( cAlias, nReg, nOpc )

Local aDados := {}
Local bError := Nil

Private cRetError := 0

bError := ErrorBlock( { |oError| ExpError( oError )})
BEGIN SEQUENCE
	aDados := aClone(ParamIxb)

	RecLock(cAlias, .T.)
		(cAlias)->Z0_FILIAL  := xFilial(cAlias)
		(cAlias)->Z0_IP      := aDados[1]
		(cAlias)->Z0_END     := aDados[2]
		(cAlias)->Z0_COTACAO := aDados[3]
		(cAlias)->Z0_DATA    := dDatabase
		(cAlias)->Z0_HORA    := Time()
		(cAlias)->Z0_OBS     := aDados[4]
		(cAlias)->Z0_TIPOLOG := aDados[5]
		
		if len(aDados) > 5
		
			do case
				case aDados[6] == 'MOZILLA'
					(cAlias)->Z0_BROWSE := '3'
				
				case aDados[6] == 'OPERA'
					(cAlias)->Z0_BROWSE := '2'
					
				case aDados[6] == 'MSIE'
					(cAlias)->Z0_BROWSE := '1'
				
				case aDados[6] == 'CHROME'
					(cAlias)->Z0_BROWSE := '4'
			endcase
		
			(cAlias)->Z0_VERSAO := aDados[7]
		endif
	(cAlias)->(MsUnLock())

	ParamIxb := {.T.}
Recover
	ParamIxb := {.F., 'ERR009', cRetError}
EndSequence
ErrorBlock( bError )
bError := Nil

Return

//-----------------------------
/*/{Protheus.doc} ExpError
Rotina para Tratamento de Erro.

@author Lucas
@since 13/06/2014
@version 1.0

@param oError, objeto, Objeto para tratamento de erro.
/*/
//-----------------------------
Static Function ExpError( oError )

Local cErro := oError:Description
Local cStack := oError:ERRORSTACK

if Type('cRetError') == 'C'
	cRetError := cErro + chr(10) + chr(13) + cStack
else
	Alert(cErro + chr(10) + chr(13) + cStack)
endif

//Conout(cErro + chr(10) + chr(13) + cStack)

BREAK
Return( NIL )