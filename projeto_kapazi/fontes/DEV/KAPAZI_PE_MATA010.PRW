#include "Protheus.ch"
#Include "TopConn.ch"
/*/{Protheus.doc} MATA010
//TODO Ponto de Entrada executado após o encerramento do cadastro de produtos
@author Jair Matos
@since 14/02/2019
@version P12

@type function
/*/
User Function ITEM()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oModel  //ParamIXB[1]
	Local cIdPonto //ParamIXB[2]
	Local cIdModel //ParamIXB[3]

	If aParam <> NIL

		oModel   := ParamIXB[1]
		cIdPonto := ParamIXB[2]
		cIdModel := ParamIXB[3]

		If     cIdPonto == 'MODELPOS'

		ElseIf cIdPonto == 'FORMPOS'

		ElseIf cIdPonto == 'FORMLINEPRE'

		ElseIf cIdPonto == 'FORMLINEPOS'

		ElseIf cIdPonto == 'MODELCOMMITTTS'

		ElseIf cIdPonto == 'MODELCOMMITNTTS'
			GeraSB5(oModel)

		ElseIf cIdPonto == 'FORMCOMMITTTSPOS'

		ElseIf cIdPonto == 'MODELCANCEL'

		ElseIf cIdPonto == 'BUTTONBAR'

		EndIf

	EndIf

Return xRet
/*/{Protheus.doc} GeraSB5
//TODO Funcao que grava os dados do produto na tabela SB5 - Dados adicionais do produto
@author Jair Matos
@since 14/02/2019
@version P12

@type function
/*/
Static Function GeraSB5(oModel)

	Local aCab          := {}
	Private oModel2     := Nil
	Private lMsErroAuto := .F.
	Private aRotina     := {}

	// informe o código do produto, a qual já deve estar registrado na tabela SB1
	cCodigo := SB1->B1_COD

	If 	oModel:GetOperation() == 3
		If SB1->B1_TIPO $ 'ME|PA'
			//Adicionando os dados do ExecAuto cab
			aCab:= {{"B5_COD"  	, SB1->B1_COD  		,Nil},;   	// Código identificador do produto
			{"B5_CEME"  		, SB1->B1_DESC  	,Nil},;    	// Nome científico do produto
			{"B5_2CODBAR"		, SB1->B1_CODGTIN  	,Nil},;   	// codigo gtin
			{"B5_UMIND"  		, "1"  				,Nil}}    	// unidade de medida

			oModel2 := FwLoadModel("MATA180")

			FWMVCRotAuto( oModel2,"SB5",3,{{"SB5MASTER", aCab}})

			//Se houve erro no ExecAuto, mostra mensagem
			If lMsErroAuto
				MostraErro()
				//Senão, mostra uma mensagem de inclusão
			Else
				conout("Codigo "+cCodigo+" incluido na SB5!")
			EndIf

			oModel2:DeActivate()
			oModel2:Destroy()
			oModel2 := NIL
		EndIf
	EndIf

Return

