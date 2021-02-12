#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PE01		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo envio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PE01()
Private cNmArq	:= ""
Private nHdlLog	:= ""
Private cPData		:= GetSrvProfString ("ROOTPATH","")
Private cDirtAtu	:= "\Supplier\AlteracaoLimites\"
Private lCriou		:= .F.
Private cArqAtu		:= ""
Private cArqNew		:= ""
Private cDir		:= ""
Private cQuebra 	:= CHR(13) + CHR(10)
Private cDirTemp	:= GetTempPath() 	//Pasta temporaria do usuario
Private cDirProc	:= "\Supplier\AlteracaoLimites\Enviados"
Private cIdSP		:= ""	
Private lErroE		:= .F.

If ValItenS() //Valida se tem itens pendentes de verificacao
		U_KP97A04() //Processa os registro pendentes da supplier
		U_KP97EALS(.F.) //Envia e-mail para supplier com os registros processados
		MovAEnv()
		If !lErroE
				GrvRetEm(.F.)
				MsgInfo("Envio de Planilha de Alteracao de Limites Finalizado com Sucesso!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
			Else
				GrvRetEm(.T.)
				MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
		EndIf
	Else
		MsgInfo("Existem itens com inconsistencias, favor verificar!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
		cAliasS2->(DbCloseArea())
EndIf

Return()


Static Function MovAEnv()
Local cDriveR 	:= ""
Local cDirFim	:= ""
Local cNomeArq 	:= ""
Local cExten	:= ""

If lCriou
	//cArquivo		Indica o nome do arquivo que será quebrado. Além disso, opcionalmente, pode-se incluir o diretório e unidade do disco.	X	 
	//cDrive		Indica o nome da unidade do disco (exemplo: C:\). Caso o arquivo informando não possua a unidade de disco ou o diretório refira-se ao servidor, a função retornará uma string em branco.	 	X
	//cDiretorio	Indica o nome do diretório. Caso o arquivo informado não possua diretório, a função retornará uma string em branco.	 	X
	//cNome			Indica o nome do arquivo sem extensão. Caso o parâmetro cArquivo não seja informado, a função retornará uma string em branco.	 	X
	//cExtensao		Indica a extensão do arquivo informado, no parâmetro cArquivo, pré-fixada com um ponto ".". Caso a extensão, no parâmetro cArquivo, não seja especificada, a função retornará uma string em branco.	 	X
	//SplitPath (cDirtAtu+cNmArq, @cDriveR, @cDirFim, @cNomeArq, @cExten )
	
	cArqNew	:= cDirtAtu + "enviados\" + cNmArq
	
	If FRename( cDirtAtu+cNmArq,cArqNew ) < 0 //Move para enviados
		MsgAlert(FError())
	EndIf
	
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
cQr += " FROM "+ RetSqlName("ZS2") +" ZS2 "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += " AND ZS2_XIDINT = '' "
cQr += " AND ZS2_STATUS = '1' "

// abre a query
TcQuery cQr new alias "cAliasS2"

DbSelectArea("cAliasS2")
cAliasS2->(DbGoTop())

Return(cAliasS2->(EOF()))

//Grava o retorno do email
Static Function GrvRetEm(lRet)
Local cSql	:= ""

cSql	:= " UPDATE "+ RetSqlName("ZS2") +" "
If lRet
		cSql	+= " SET ZS2_NMARQI = '"+cNmArq+"', ZS2_ENVEMA = 'S' "
	Else
		cSql	+= " SET ZS2_NMARQI = '"+cNmArq+"', ZS2_ENVEMA = 'N' "
EndIf
cSql	+= " WHERE ZS2_XIDINT = '"+cIdSP+"' "

Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif

Return()