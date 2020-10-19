#include "protheus.ch"

/*/{Protheus.doc} MDTA6959
O ponto de entrada MDTA6959 pode ser utilizado para a inclus�o de novos 
campos dentro da fun��o de grava��o das solicita��es de EPI ao armaz�m.
@type User Function
@author Kaique Mathias
@since 20/04/2020
/*/

User Function MDTA6959()

    Local aItens := ParamIXB[2]

    If( aScan(aItens,{|x| Alltrim(x[1]) == "CP_DATPRF"} ) = 0 )
        aAdd(aItens,{"CP_DATPRF",TNF->TNF_DTENTR,Nil})
    EndIf

Return({,aItens})