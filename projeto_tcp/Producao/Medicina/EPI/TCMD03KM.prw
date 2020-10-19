#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} TCMD03KM
Funcao responsavel por incluir/excluir a requisicao de material
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/10/2020
@param dData, date, param_description
@param cCodEPI, character, param_description
@param cDescEPI, character, param_description
@param cLocal, character, param_description
@param nQtdEnt, numeric, param_description
@return return_type, return_description
/*/

User Function TCMD03KM(dData,cCodEPI,cLocal,cCodigo,nQtdEnt,nOpcZDW,cMatricula)

	Local cNumReq	:= ""
	Local aErro 	:= {}
	
	dbSelectArea("ZDW")
	ZDW->( dbSetOrder( 1 ) )

	If( nOpcZDW == MODEL_OPERATION_DELETE )
		ZDW->( MSSeek( xFilial("ZDW") + cCodigo + cCodEPI ))
	EndIf

	oModel := FWLoadModel('AEST055')

	oModel:SetOperation(nOpcZDW)
	oModel:Activate()

	If( nOpcZDW == 3 )
		dbSelectArea("SRA")
		SRA->( dbSetOrder( 1 ) )
		SRA->( MSSeek( xFilial("SRA") + cMatricula ) )

		oModel:SetValue("ZDW_CAB","ZDW_DATA",dDataBase)
		oModel:SetValue("ZDW_CAB","ZDW_OBSERV",SRA->RA_NOME)
		oModel:SetValue("ZDW_CAB","ZDW_REQUIS",cMatricula)
		oModel:SetValue("ZDW_CAB","ZDW_TIPO","1")

		dbSelectArea("SB1")
		SB1->( dbSetOrder( 1 ) )
		SB1->( MSSeek( xFilial("SB1") + cCodEPI ) )
		oModel:SetValue("ZDW_ITENS","ZDW_EPI",cCodEPI)
		oModel:SetValue("ZDW_ITENS","ZDW_DESC",SB1->B1_DESC)
		oModel:SetValue("ZDW_ITENS","ZDW_LOCAL",cLocal)
		oModel:SetValue("ZDW_ITENS","ZDW_QTDE",nQtdEnt)
		oModel:SetValue("ZDW_ITENS","ZDW_CC",SRA->RA_CC)
	EndIf
	
	If( oModel:VldData() )
		oModel:CommitData()
		If( nOpcZDW == 3 )
			cNumReq := ZDW->ZDW_NUMERO
		EndIf
	else
		aErro := oModel:GetErrorMessage()
		If( !IsBlind() )
			AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
			AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
			AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
			AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
			AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
			AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
			AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
			AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
			AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
			MostraErro()
		Else
			VarInfo("TCMD03KM",aErro)
		EndIf
		cNumReq := ZDW->ZDW_NUMERO
	Endif

	oModel:DeActivate()

	oModel:Destroy()

Return( cNumReq )