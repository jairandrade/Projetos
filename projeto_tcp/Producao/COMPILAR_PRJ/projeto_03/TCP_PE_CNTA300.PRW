#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

USER function CNTA300()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.
	Local cTipRev		:=''// A300GTpRev()

	Local aArea := GetArea()
// Local nLinha     := 0
// Local nQtdLinhas := 0


	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )

		DO CASE

		CASE cIdPonto == 'FORMLINEPRE' .AND. !EMPTY(cTipRev)
			if  lIsGrid .AND. cIdModel == 'CNADETAIL'

				DbSelectArea('CNA')
				CNA->(DBSetOrder(1))
				IF EMPTY(M->CN9_TIPREV) .OR. ;
						( POSICIONE('CN0',1,CN9->CN9_FILIAL+M->CN9_TIPREV,'CN0_XINCPL') == '1' ;
						.AND. CNA->(DBSeek(CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA+oObj:GetVALUE('CNA_NUMERO')));
						);
						.OR. !empty(oObj:GetVALUE('CNA_XREVBL'))

					if EMPTY(M->CN9_TIPREV)
						alert('Selecione o tipo da revisão.')
					endif
					xRet  =.F.

				ENDIF
			endif

		CASE cIdPonto == 'MODELCOMMITTTS' .AND. VALTYPE(oObj) == 'O'
			if oObj:nOperation == 5 .AND. EMPTY(CN9->CN9_REVISA)
				//Remove bloqueio do contrato antigo
				//  U_AGCT012(oObj:nOperation)
			endif

		CASE cIdPonto == 'MODELCOMMITNTTS' .AND. VALTYPE(oObj) == 'O'

			IF   EMPTY(cTipRev) .AND. oObj:nOperation == 3 .AND. cIdModel == "CNTA300";
					.AND. FWIsInCallStack('CN300InCOM')

				//Obriga anexo no contrato
				//  U_AGCT007()
				IF CN9->CN9_SITUAC != '05'

					//Situação
					// U_AGCT012(oObj:nOperation)

					//Envia e-mail avisando que o contrato foi incluido
					// U_AGCT006()
				ENDIF
			elseIF !EMPTY(cTipRev)
				//Bloqueia planilhas antigas do contrato quando o tipo do contrato permitir
				//  U_AGCT010(oObj:nOperation)

			ENDIF

		CASE cIdPonto == 'BUTTONBAR'
			xRet := { {'Importar Planilha', 'IMPLA', { || u_AGCT009() }, 'Esta rotina importa uma planilha csv para a planilha do contrato' } }

		ENDCASE

	endif


	RestArea(aArea)

return xRet

