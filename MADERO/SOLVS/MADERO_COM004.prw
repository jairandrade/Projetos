#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} COM004T1
MATA103 TRIGGER 1
@type function
@version 
@author Thiago Berna
@since 23/07/2020
@param cCampo, character, param_description
@return return_type, return_description
/*/
User Function COM004T1(cCampo)

    Local cRetorno  := ""

    Default cCampo  := ''

    If !Empty(cCampo)
        
        //Verifica se existe Produto x Fornecedor e se o campo A5_ORIGEM esta preenchido
        SA5->(dbSetOrder(14)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF

        If  GDFieldPos("D1_XCODPRF") > 0 .And. SA5->(DbSeek(xFilial("SA5")+ CA100FOR + CLOJA + aCols[n,GDFieldPos("D1_XCODPRF")]))
            If SA5->A5_PRODUTO == aCols[n,GDFieldPos("D1_COD")]
                If cCampo == 'D1_XCODPRF'
                    cRetorno := SA5->A5_PRODUTO
                ElseIf cCampo == 'D1_COD' .Or. cCampo == 'D1_TES'
                    If !Empty(SA5->A5_XORIGEM)
                        cRetorno := SA5->A5_XORIGEM + IIF(GDFieldPos("D1_CLASFIS") > 0,SubStr(aCols[n,GDFieldPos("D1_CLASFIS")],2),'')
                    Else
                        cRetorno := SB1->B1_ORIGEM + IIF(GDFieldPos("D1_CLASFIS") > 0,SubStr(aCols[n,GDFieldPos("D1_CLASFIS")],2),'')
                    EndIf
                EndIf
            Else
                If cCampo == 'D1_XCODPRF'
                    cRetorno  := ""
                ElseIf cCampo == 'D1_COD' .Or. cCampo == 'D1_TES'
                    cRetorno := SB1->B1_ORIGEM + IIF(GDFieldPos("D1_CLASFIS") > 0,SubStr(aCols[n,GDFieldPos("D1_CLASFIS")],2),'')
                EndIf
            EndIf 
        Else
            If cCampo == 'D1_XCODPRF'
                cRetorno  := ""
            ElseIf cCampo == 'D1_COD' .Or. cCampo == 'D1_TES'
                cRetorno := SB1->B1_ORIGEM + IIF(GDFieldPos("D1_CLASFIS") > 0,SubStr(aCols[n,GDFieldPos("D1_CLASFIS")],2),'')
            EndIf
        EndIf

    EndIf

Return cRetorno

/*/{Protheus.doc} COM004T2
MATA103 TRIGGER 2
@type function
@version 
@author Thiago Berna
@since 23/07/2020
@param cCampo, character, param_description
@return return_type, return_description
/*/
User Function COM004T2(cCampo)

    Local cRetorno := ''
    Default cCampo := ''
    
    If cCampo == 'D1_XCODPRF'

        If ExistTrigger('D1_COD') 
            RunTrigger(2,N,nil,,'D1_COD')
        EndIf

        If !FunName() == "DOCFIS"
            If ExistTrigger('D1_TES') 
                RunTrigger(2,N,nil,,'D1_TES')
            EndIf
        EndIf
        If GDFieldPos("D1_COD") > 0
            cRetorno := aCols[n,GDFieldPos("D1_COD")]  
        EndIf
    EndIf

Return cRetorno

/*/{Protheus.doc} COM004T3
MATA103 TRIGGER 3
@type function
@version 
@author Thiago Berna
@since 23/07/2020
@param cCampo, character, param_description
@return return_type, return_description
/*/
User Function COM004T3(cCampo)

    Local cRetorno  := ""

    Default cCampo  := ''

    If !Empty(cCampo)
        
        //Verifica se existe Produto x Fornecedor e se o campo A5_ORIGEM esta preenchido
        SA5->(dbSetOrder(14)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF
        If GDFieldPos("D1_XCODPRF") > 0 .And. SA5->(DbSeek(xFilial("SA5")+ CA100FOR + CLOJA + aCols[n,GDFieldPos("D1_XCODPRF")]))
            If !SA5->A5_PRODUTO == aCols[n,GDFieldPos("D1_COD")]
                cRetorno := ''
            Else
                cRetorno := aCols[n,GDFieldPos("D1_XCODPRF")]
            EndIf 
        Else
            cRetorno := ''
        EndIf

        If !FunName() == "DOCFIS"
            If ExistTrigger('D1_TES') 
                RunTrigger(2,N,nil,,'D1_TES')
            EndIf
        EndIf

    EndIf

Return cRetorno
