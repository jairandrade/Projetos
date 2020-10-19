#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------
/*/ { Protheus.doc } TCFIA002EVDEF
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Kaique Mathias
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class TCFIA002EVDEF FROM FWModelEvent
    Method New() CONSTRUCTOR
    Method VldActivate(oModel, cModelId)
    Method ModelPosVld(oModel, cModelId)
    Method InTTS(oModel, cModelId)
End Class

Method New() Class TCFIA002EVDEF
Return( self )

/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Kaique Mathias
@since 29/06/2020
@version 1.0

@param oModel   , objeto  , objeto do modelo
@param cModelId , caracter, nome do modelo
@return lReturn		- Indica se os dados sao validos para ativacao
/*/

Method VldActivate(oModel, cModelId) Class TCFIA002EVDEF

    Local lReturn   := .T.
    Local nOperation:= oModel:GetOperation()
    Local cUserSol  := StaticCall(TCFIA002,fRetCodSol,ZA0->ZA0_CODSOL,2)

    If ( nOperation == MODEL_OPERATION_UPDATE )
        If ( __cUserID <> cUserSol )
            Help( , , "AJUDA", , "Você não tem permissão para alterar títulos de outros usuários.", 1, 0 )
            lReturn := .F.
        EndIf

        If (  ZA0->ZA0_STATUS $ '2~3~9' )
            Help( , , "AJUDA", , "Solicitação ja foi Aprovada ou Reprovada! Não pode ser alterado.", 1, 0 )
            lReturn := .F.
        EndIf
    EndIf

Return( lReturn )

/*/{Protheus.doc} ModelPosVld
Método para validação do modelo

@author Kaique Mathias
@since 29/06/2020
@version 1.0

@param oModel	- Modelo de dados
@param cModelId	- ID do modelo de dados
@return lRet	- Indica se o modelo de dados está válido
/*/

Method ModelPosVld(oModel, cModelId) Class TCFIA002EVDEF

    Local lRet := .T.
    Local lExclui   := oModel:GetOperation() == MODEL_OPERATION_DELETE

    If !lExclui
        If (;
                oModel:GetValue("ZA0MASTER","ZA0_MULTA") > 0 .Or.;
                oModel:GetValue("ZA0MASTER","ZA0_JUROS") > 0;
                )
            If Empty( oModel:GetValue("ZA0MASTER","ZA0_JUSJUR") )
                Help( " ", 1, "JUSJUR",, "Existem campos obrigatorios não preenchidos. Favor preencher o campo Justificativa do Juros.", 1, 0 )
                lRet := .F.
            EndIf
        EndIf
        If ( lRet )
            oModelZA2	:= oModel:GetModel("ZA2DETAIL")
            oModelZA3	:= oModel:GetModel("ZA3DETAIL")
            oModelZA0	:= oModel:GetModel("ZA0MASTER")
            lRet := StaticCall(TCFIA002,fMNPosMd,oModelZA2,oModelZA3,oModelZA0)
        EndIf
    EndIf

Return( lRet )

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.

@author Kaique Mathias
@since 29/06/2020
@version 1.0

@param oModel	- Modelo principal
@param cModelId	- Id do submodelo
@return Nil
/*/

Method InTTS(oModel, cModelId) Class TCFIA002EVDEF

    Local nOperation := oModel:GetOperation()
    Local lRet    	 := .T.
    Local cGrpAprov  := ""
    Local bSelAnexo  := {|| Empty(cGrpAprov := StaticCall(TCFIA002,fSelGrpApr)) }
    Local bAttach    := {|| StaticCall(TCFIA002,saveAttach) }
    Local lNoAttach  := .T.

    If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )

        If lRet
            dbSelectArea('Z99')
            Z99->(dbSetOrder(2))

            If Z99->(MSSeek(xFilial('Z99')+__cUserID))
                If ( Z99->Z99_ALTALC == "N" )
                    cGrpAprov := Z99->Z99_GRPAPR
                else
                    do while eval(bSelAnexo)
                    EndDo
                EndIf
            EndIf
        EndIf

        If !Empty(cGrpAprov)

            nValor  := FwFldGet("ZA0_VALOR")
            nMulta  := FwFldGet("ZA0_MULTA")
            nJuros  := FwFldGet("ZA0_JUROS")
            nVlTot  := nValor + nMulta + nJuros

            ZA0->ZA0_STATUS := '1'

            //Valida se existe anexo, e se não existir abre a tela de inclusão. Após a confirmação, valida denovo. 
            If( Type("__cChaveAnexo") <> "U" )
                lNoAttach := Empty(__cChaveAnexo)
            EndIf
            
            If( lNoAttach )
                do while !Eval(bAttach)
                enddo
            Else
                U_TCPGEDREP("ZA0",xFilial("ZA0"),__cChaveAnexo,xFilial("ZA0")+ZA0->ZA0_CODIGO)
            EndIf

            If ( nOperation == MODEL_OPERATION_UPDATE )
                dbSelectArea('SCR')
                SCR->(dbSetOrder(2))
                SCR->(MsSeek(xFilial("SCR") + "AP" + ZA0->ZA0_CODIGO ))
                While !Eof() .And.  SCR->CR_FILIAL+Substr(SCR->CR_NUM,1,len(ZA0->ZA0_CODIGO)) == ;
                        xFilial("SCR")+Substr(ZA0->ZA0_CODIGO,1,len(ZA0->ZA0_CODIGO)) .And. SCR->CR_TIPO == "AP"
                    If RecLock('SCR',.F.)
                        SCR->(dbDelete())
                        SCR->(MsUnlock())
                    EndIf
                    SCR->(dbSkip())
                EndDo
            EndIf

            MaAlcDoc({  FwFldGet("ZA0_CODIGO"),;
                "AP",;
                nVlTot,;
                ,;
                ,;
                cGrpAprov,;
                ,1;
                ,;
                ,;
                dDataBase,;
                ""},;
                dDataBase,;
                1)

        else
            lRet := .F.
        EndIf
    EndIf

Return( .T. )
