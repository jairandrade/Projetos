#include "totvs.ch"

/*/{Protheus.doc} MT150LOK
Ponto de entrada na validação da alteração da linha itens MATA150 - Atualiza Cotação
@type  Function
@author Willian Kaneta
@since 14/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return lRet = .T./.F.
@example
(examples)
@see (links_or_references)
/*/
User Function MT150LOK()
    
    Local lRet      := .T.
    Local nPosHml   := GDFieldPos("C8_XHOMFOR")
    Local cTipNPerm := "VE|NH"

    If( aCols[n,nPosHml] $ cTipNPerm )
        If( !M150VerAlt() )
            lRet := .F.
            If aCols[n,nPosHml] == "VE"
                Help(NIL, NIL, "HELP: MT150LOK", NIL, "Fornecedor com Homologação Vencida.", 1,0, NIL, NIL, NIL, NIL, NIL,;
                    {"Não é permitido atualizar a cotação de fornecedores de produtos químicos com homologação vencida."})
            ElseIf aCols[n,nPosHml] == "NH"
                Help(NIL, NIL, "HELP: MT150LOK", NIL, "Fornecedor não homologado até esta data.", 1,0, NIL, NIL, NIL, NIL, NIL,;
                    {"Não é permitido atualizar a cotação de fornecedores de produtos químicos que não possuem os dados da Homologação. Verifica cadastro do fornecedor."})
            EndIf
        EndIf
    EndIf
    
Return( lRet )

/*/{Protheus.doc} M150VerAlt
Funcao responsavel por validar alteracoes
@type  Function
@author Kaique Mathias
@since 14/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return lRet = .T./.F.
@example
(examples)
@see (links_or_references)
/*/

Static Function M150VerAlt()

    Local lRet      := .T.
    Local nPosItem  := GDFieldPos("C8_ITEM")
    Local aFields   := {"C8_TOTAL","C8_PRECO"}
    Local i         := 0
    
    If( aCols[n,len(aHeader)+1] )
        lRet := .F.
    else
        dbSelectArea("SC8")
        SC8->( dbSetOrder( 1 ) )
        SC8->( MSSeek( xFilial("SC8") + CA150NUM + CA150FORN + CA150LOJ + aCols[n][nPosItem] ) )
        //Verifico se foi realizado alteração
        For i := 1 to len( aFields )
            If( nPos := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim(aFields[i]) }) ) > 0
                If( SC8->&( aFields[i] ) <> aCols[n][nPos] )
                    lRet := .F.
                    Exit
                EndIf
            EndIf
        Next i
    EndIf

Return( lRet )
