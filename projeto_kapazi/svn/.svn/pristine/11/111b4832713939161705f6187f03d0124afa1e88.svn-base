#include "protheus.ch"
#include "topconn.ch"

#define ENTER chr(13)+chr(10)

/*/{Protheus.doc} KESTR25
Função que troca o numseq dos movimentos de perda igualando ao movimento de producao para abater o valor da perda do produto produzido.
Chamado no ponto de entrada MA330OK
@type function
@version 
@author Luiz Jacinto
@since 17/06/2020
@param dDtIni, date, Data Inicio processamento Custo médio
@param dDtFim, date, Data Fim processamento do custo médio
@return nil, nil
/*/
User Function KESTR25(dDtIni,dDtFim)
    Local aArea     := GetArea()
    Local cDtIni    := ""
    Local cDtFim    := ""
    
    If Empty(dDtIni) .or. Empty(dDtFim)
        Return
    Endif

    If dDtFim < dDtIni
        Return
    Endif

    If !isBlind()
        ProcRegua(0)
        IncProc()
        IncProc()
    Endif

    cDtIni := DtoS(dDtIni)
    cDtFim := DtoS(dDtFim)

    if SD3Atualizar(cDtIni,cDtFim)
        SBCAtualizar(cDtIni,cDtFim)
    Endif

    RestArea(aArea)
Return


Static Function SD3Atualizar(cDtIni,cDtFim)
    Local cQuery    := ""
    Local nErro     := 0
    Local cErro     := ""
    Local lRet      := .T.

    cQuery += "UPDATE "+RetSqlName("SD3")+" SET D3_NUMSEQ = BC_NUMSEQ "+ENTER
	cQuery += "FROM "+RetSqlName("SBC")+" SBC "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SD3")+" SD3 ON SD3.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND D3_FILIAL = BC_FILIAL "+ENTER
	cQuery += "		AND D3_NUMSEQ = BC_SEQSD3 "+ENTER
	cQuery += "		AND D3_EMISSAO >= '"+cDtIni+"' "+ENTER
	cQuery += "		AND D3_EMISSAO <= '"+cDtFim+"' "+ENTER
	cQuery += "		AND D3_OP = BC_OP "+ENTER
	cQuery += "		AND D3_COD = BC_CODDEST "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		SBC.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND BC_DATA>='"+cDtIni+"' "+ENTER
	cQuery += "	AND BC_DATA<='"+cDtFim+"' "+ENTER
	cQuery += "	AND BC_NUMSEQ <> BC_SEQSD3 "+ENTER

    nErro := TcSqlExec(cQuery)
    if nErro < 0
        lRet  := .F.
        cErro := TCSQLError()
    Endif

Return lRet


Static Function SBCAtualizar(cDtIni,cDtFim)
    Local cQuery    := ""
    Local nErro     := 0
    Local cErro     := ""
    Local lRet      := .T.

	cQuery += "UPDATE "+RetSqlName("SBC")+" SET BC_SEQSD3 = BC_NUMSEQ "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND BC_DATA>='"+cDtIni+"' "+ENTER
	cQuery += "	AND BC_DATA<='"+cDtFim+"' "+ENTER
	cQuery += "	AND BC_NUMSEQ <> BC_SEQSD3 "+ENTER
    
    nErro := TcSqlExec(cQuery)
    if nErro < 0
        lRet  := .F.
        cErro := TCSQLError()
    Endif

Return
