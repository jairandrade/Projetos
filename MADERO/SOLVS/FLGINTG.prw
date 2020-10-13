#include "protheus.ch"

//integra��es dispon�veis
#define INTEGRACAO_PRODUTO "CODPRO"

/*/{Protheus.doc} FLGINTG
Classe de integra��es FLUIG
@type class
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
/*/
class FLGINTG from FwModelEvent

    method New()
    method After(oModel, cModelId, cAlias, lNewRecord)

end Class

/*/{Protheus.doc} FLGINTG::New
M�thodo construtor da classe
@type method
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
/*/
method New() class FLGINTG
return

/*/{Protheus.doc} FLGINTG::After
M�todo de disparo de evento p�s manuten��o da tabela Z27
@type method
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param oModel, object, Modelo ativo
@param cModelId, character, C�digo do modelo na opera��o executada
@param cAlias, character, Alias ativo (Z37)
@param lNewRecord, logical, Indica se � um novo registro
/*/
method After(oModel, cModelId, cAlias, lNewRecord) Class FLGINTG

    local aOperacoes := {}
    local nOperacao := 0

    //apenas processa registros pendentes de integra��o
    if oModel:GetValue("Z27_STATUS") != "P"
        return
    endIf

    //mapeia as opera��es pelos c�digos de processos definidos
    AADD(aOperacoes, { INTEGRACAO_PRODUTO, {|oModel| integCodPro(oModel) } })

    nOperacao := aScan(aOperacoes, {|blk| AllTrim(blk[1]) == AllTrim(oModel:GetValue("Z27_PROCES")) })

    //caso o processo n�o esteja registrado
    if nOperacao <= 0
        return
    endIf

    Eval(aOperacoes[nOperacao][2], oModel)

return

/*/{Protheus.doc} integCodPro
Fun��o de integra��o de produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param oModel, object, Modelo ativo de dados
/*/
static function integCodPro(oModel)

    local cOperacao := AllTrim(oModel:GetValue("Z27_OPERAC"))
    local cExec := ""

    do Case

        case cOperacao == "INCLUIR"
            cExec := "U_AFIN002I(Z27->Z27_REQUES)"

        case cOperacao == "ALTERAR"
            cExec := "U_AFIN002A(Z27->Z27_REQUES)"

        case "BLOQUEAR" $ cOperacao //bloqueio e desbloqueio
            cExec := "U_AFIN002B(Z27->Z27_REQUES)"

        case cOperacao == "REPLICAR"
            cExec := "U_AFIN002R(Z27->Z27_REQUES)"

    endCase

    //dispara o evento de integra��o de forma ass�ncrona
    StartJob( "U_AFIN000P", GetEnvServer(), .F., {cEmpAnt, cFilAnt}, Z27->(RecNo()), cExec)

return

/*/{Protheus.doc} AFIN000P
Fun��o gen�rica para processamento de registros
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param aEmp, array, Empresa e filial para prepara��o de ambiente
@param nRecno, numeric, N�mero do RECNO do registro de integra��o (Z27)
@param cExec, codeblock, Codeblock de execu��o (precisa ser string por ser via JOB)
/*/
user function AFIN000P(aEmp, nRecno, cExec, uValor)

    local cLockFile := "flgint_AFIN000P_" + aEmp[1] + aEmp[2] + "_" + cValToChar(nRecno) + ".lock"
    local cResponse := ""
    local oErrorBlk := ErrorBlock({|e| UnLockByName(cLockFile, .T., .T.) })

    //prepara��o de ambiente (n�o precisa limpar por ser via JOB)
    RpcSetType(3)
    RpcSetEnv(aEmp[1], aEmp[2])

    if ! LockByName(cLockFile, .T., .T.)
        return
    endIf
    
    //posiciona no registro de integra��o
    Z27->(DbGoTo( nRecno ))

    Begin Sequence

    cResponse := &(cExec)

    End Sequence

    ErrorBlock(oErrorBlk)

    if ! Empty(cResponse)

        //atualiza com a resposta do servi�o
        RecLock("Z27", .F.)
            Z27->Z27_RESPON := cResponse
            Z27->Z27_STATUS := "I"//=Integrado
            Z27->Z27_DTPROC := Date()
            Z27->Z27_HRPROC := Time()
        MsUnlock()

    endIf

    UnLockByName(cLockFile, .T., .T.)

return
