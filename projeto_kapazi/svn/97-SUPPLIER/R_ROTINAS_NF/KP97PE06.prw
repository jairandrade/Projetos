#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PE06		|	Autor: Luis Paulo							|	Data: 19/09/2018	//
//==================================================================================================//
//	Descri��o: Funcao responsavel por gerar o arquivo Supplier										//
//																									//
//==================================================================================================//
User Function KP97PE06()
Private cNmArq	:= ""
Private nHdlLog	:= ""
Private cPData		:= GetSrvProfString ("ROOTPATH","")
Private cDirtAtu	:= "\Supplier\Nota Fiscal\"
Private lCriou		:= .F.
Private cArqAtu		:= ""
Private cArqNew		:= ""
Private cDir		:= ""
Private cQuebra 	:= CHR(13) + CHR(10)
Private cDirTemp	:= GetTempPath() 	//Pasta temporaria do usuario
Private cDirProc	:= "\Supplier\Nota Fiscal"
Private cIdSP		:= ""	
Private lErroE		:= .F.

If ValItenS() //Valida se tem itens pendentes de verificacao
		U_KP97A16() //Processa os registro pendentes da supplier
		MsgInfo("Processo finalizado!!","KAPAZI - NF SUPPLIER CARD")
	Else
		MsgInfo("Existem itens com inconsistencias(NF), favor verificar!!","KAPAZI - NF SUPPLIER CARD")
		cAliasS2->(DbCloseArea())
EndIf

Return()


Static Function ValItenS()
Local cQr 			:= ""
Local cAliasS2		:= GetNextAlias()

If Select("cAliasS2")<>0
	DbSelectArea("cAliasS2")
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,* "
cQr += " FROM "+ RetSqlName("ZS6") +" ZS6 "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += " AND ZS6_XIDINT = '' "
cQr += " AND ZS6_STATUS = '1' "

// abre a query
TcQuery cQr new alias "cAliasS2"

DbSelectArea("cAliasS2")
cAliasS2->(DbGoTop())

Return(cAliasS2->(EOF()))
