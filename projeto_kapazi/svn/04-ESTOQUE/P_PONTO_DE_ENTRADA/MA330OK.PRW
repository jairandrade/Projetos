#include "protheus.ch"

#define ENTER chr(13)+chr(10)

/*/{Protheus.doc} MA330OK
    Validar execução do recálculo do custo médio - início processamento
@type functin
@version 
@author Luiz Jacinto
@since 17/06/2020
@return bool, retorna se deve continuar a execucao
/*/
User Function MA330OK()
    Local lRet      := .T.
    Local aArea     := GetArea()
    Local lPerda    := GetMv("KA_PERDSEQ",,.F.)
    Local dDtIni    := dInicio
    Local dDtFim    := MV_PAR01

    // atribui novamente pro compilador não reclamar de declarado e nunca usado.
    dDtIni    := dInicio
    dDtFim    := MV_PAR01

    If lPerda .and. ExistBlock("KESTR25")
        if !isBlind()
            Processa({|| U_KESTR25(dDtIni,dDtFim) },"Corrigindo apontamentos de perdas...","Aguarde...")
        Else
            U_KESTR25(dDtIni,dDtFim) 
        Endif
    Endif

    RestArea(aArea)
Return lRet