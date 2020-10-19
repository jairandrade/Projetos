#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} User Function TCGA001
Classe
@type  Function
@author Kaique Mathias
@since 18/08/2020
@version 1.0
/*/

Class TCGA001EVDEF FROM FWModelEvent
    Method New() CONSTRUCTOR
    Method ModelPosVld(oModel, cModelId)
End Class

Method New() Class TCGA001EVDEF
Return( self )

Method ModelPosVld(oModel, cModelId) Class TCGA001EVDEF
    
    Local aEmails   := StrTokArr( AllTrim( GetMV("TCP_ALCADP") ), ";" )
    Local nOperation := oModel:GetOperation()
    Local cProdQuim  := oModel:GetValue("SB1MASTER","B1_XQUIMI")
    Local cErro      := ""

    If( nOperation == MODEL_OPERATION_UPDATE ) 
        If( cProdQuim <> SB1->B1_XQUIMI )
            oMail := TCPMail():New()
            oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFICATION.html")
            oHtml:ValByName("HEADER","NOTIFICAÇÃO DE ALTERAÇÃO DE PRODUTO QUIMICO")
            oHtml:ValByName("BODY","A classificação do produto " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + " foi alterada pelo usuario " + FwGetUserName(__cUserId) + ". <br> Para realizar cotação / compra do mesmo será necessário homologar os fornecedores junto ao departamento ambiental.")
            oMail:SendMail( aEmails ,;
            ":: Notificação de alteração de Produto Quimico",;
            oHtml:HtmlCode(),;
            @cErro,;
            {})
        EndIf
    EndIf

Return( .T. )

