#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: MT120ALT		|	Autor: Luis Paulo							|	Data: 13/03/2020    //
//==================================================================================================//
//	Descrição: PE NA ALTERACAO DO PC                    											//
//																									//
//==================================================================================================//
User Function MT120ALT()
Local lExecuta  := .T.
Local nOpcPe    :=  Paramixb[1]
Local cNfKp     := ""
Local cSeKp     := ""

If nOpcPe == 3 .or. nOpcPe == 4
    If Type("lAtualPr") == "U" 
            Public lAtualPr	:= .f.
        ElseIf Type("lAtualPr") == "L"
            lAtualPr	:= .f.
    EndIf
EndIf

If nOpcPe == 4  // Alteração

    If ValPreNfK(@cNfKp,@cSeKp) //tem pré nota ou nota
        MsgInfo("Existe uma nota/pré nota("+Alltrim(cSeKp)+"/"+cNfKp+") vinculada a este pedido, por isso não será possível alteracao!!!!","Kapazi")
        lExecuta  := .F.
    EndIf

EndIf

Return( lExecuta )

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 13/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function ValPreNfK(cNfKp,cSeKp)
    Local aArea     := GetArea()
    Local cAliasKp  := GetNextAlias()
    Local cQry      := ""
    //Nao tem pré nota
    Local lRet      := .f. 

    cQry += " SELECT D1_PEDIDO,D1_DOC,D1_SERIE "
    cQry += " FROM "+RetSqlName("SD1")+" "
    cQry += " WHERE D_E_L_E_T_<>'*' "
    cQry += " AND D1_FILIAL = '"+ xFilial("SD1") +"' "
    cQry += " AND D1_PEDIDO = '"+ SC7->C7_NUM +"' "

    If Select(cAliasKp) > 0
        (cAliasKp)->(DbCloseArea())
    Endif

    TcQuery cQry New Alias (cAliasKp)

    If !(cAliasKp)->(EOF())
        lRet    := .T.
        cNfKp   := (cAliasKp)->D1_DOC
        cSeKp   := (cAliasKp)->D1_SERIE
    EndIf

    If Select(cAliasKp) > 0
        (cAliasKp)->(DbCloseArea())
    Endif

    RestArea(aArea)
Return(lRet)
