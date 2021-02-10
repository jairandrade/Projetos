/*------------------------------------------------------------------------
EXEMPLO DE INCLUSÃO NA TABELA SB5 UTILIZANDO MVC
------------------------------------------------------------------------*/
#INCLUDE "Protheus.CH"
User Function Incluir1()
Local oModel    := Nil
Local cCodigo    := ""
Local aCabec := {}
Private aRotina := {}

// informe o código do produto, a qual já deve estar registrado na tabela SB1
aadd(aCabec,{"GWN_NRROM","00000003"})
aadd(aCabec,{"GWN_CDTRP","000000004"})
aadd(aCabec,{"GWN_CDTPOP","0000000001"})

//Para utilização da mesma, o modelo de dados chama-se MATA180M e nao MATA180
oModel := FwLoadModel("GFEA050")
	Begin Transaction
    lMsErroAuto := .F.  
    FWMVCRotAuto( oModel,"GWN",3,{{"GFEA050_GWN", aCabec}})
	If lMsErroAuto
        DisarmTransaction()
        MostraErro()
	EndIf
	End Transaction
Return Nil
