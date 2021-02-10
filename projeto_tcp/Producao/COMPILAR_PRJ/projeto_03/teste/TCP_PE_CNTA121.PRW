#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

USER function CNTA121()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    Local lIsGrid    := .F.
    Local oModel 	 := FWModelActive()
    Local oModelCXN  := IIF(VALTYPE(oModel) == "O", oModel:GetModel("CXNDETAIL"), Nil)
    
    If aParam <> NIL

        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
        lIsGrid    := ( Len( aParam ) > 3 )


        if cIdPonto == 'FORMLINEPRE' 
            if  lIsGrid .AND. cIdModel == 'CXNDETAIL' 
                
                _campo   := aParam[6]
                if _campo == 'CXN_CHECK'
                    xRet := U_AGCT015(1)
                endif
               
            endif
        elseif cIdPonto == 'FORMLINEPOS'
            if  VALTYPE(oModel) == "O"
                If cIdModel == 'CXNDETAIL' .AND. aParam[4] == oModelCXN:Length() .AND. aParam[5] == "SETVALUE" .AND. aParam[6] == "CXN_CHECK" 
                    U_TCGC02WK(cIdPonto)
                EndIf
            EndIf
        elseIf cIdPonto == 'MODELVLDACTIVE'
            if Alltrim(FUNNAME()) = 'TC04A020'
                aContrato := {cCN9_CONTRA, cCN9_REVISA, ""}

                return aContrato
            endif                
        elseif cIdPonto == 'FORMPOS'
            if FWIsInCallStack('CN121MEDENC')
                xRet := U_CN120ENVL()
            endif
            IF xRet
                //Valida data de lançamento da emissão
                xRet := U_AGCT015(2)
            endif
        elseif cIdPonto == 'MODELPRE'
            If cIdModel == 'CNTA121' .AND. (ALTERA .OR. INCLUI)
                U_TCGC02WK() 
            endif
        elseif cIdPonto == 'MODELPOS'
        elseif cIdPonto == 'FORMLINEPOS'

            

        elseif cIdPonto == 'FORMCOMMITTTSPOS'

        elseif cIdPonto == 'MODELCOMMITTTS'
            IF TYPE("_cErrSales") == 'C' .AND. !EMPTY(_cErrSales)
                Alert(_cErrSales)
            ENDIF
        elseif cIdPonto == 'MODELCOMMITNTTS'
            U_SC7FRE(SC7->C7_NUM, SC7->C7_NUMSC, SC7->C7_MEDICAO)
            // if xRet .AND. oObj:nOperation == MODEL_OPERATION_DELETE
            //     U_MD130GRV()
            // ENDIF
            // xRet := U_CN130TOK()
            // U_CN130PGRV()
            IF FWIsInCallStack('CN121MEDENC')
                //Vincula fornecedores
                // U_CN130TOK()
                U_AGCT013()

                //Garantia
                U_CN130PGRV()
            ENDIF
            IF FWIsInCallStack('CN121ESTORN')
                //Deleta o rateio
                U_AGCT014()     
            ENDIF
            
        ENDIF

    endif
return xRet

