#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PE00		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo envio de email com planilha para supplier					//
//	Concessao de limites																								//
//==================================================================================================//
User Function KP97PE00()
Private cNmArq	:= ""
Private nHdlLog	:= ""
Private cPData		:= GetSrvProfString ("ROOTPATH","")
Private cDirtAtu	:= "\Supplier\ConcessaoLimites\"
Private lCriou		:= .F.
Private cArqAtu		:= ""
Private cArqNew		:= ""
Private cDir		:= ""
Private cQuebra 	:= CHR(13) + CHR(10)
Private cDirTemp	:= GetTempPath() 	//Pasta temporaria do usuario
Private cDirProc	:= "\Supplier\ConcessaoLimites\Enviados"
Private cIdSP		:= ""	
Private lErroE		:= .F.
Private aLogKP		:= {}

If ValItenS() //Valida se tem itens pendentes de verificacao
		U_KP97A02() //Processa os registro pendentes da supplier
		U_KP97ECLS(.F.) //Envia e-mail para supplier com os registros processados
		MovAEnv()
		GravaLGK()
		If !lErroE .And. lCriou
				GrvRetEm(.F.)
				MsgInfo("Processo finalizado!!","KAPAZI - SUPPLIER CARD")
			Else
				GrvRetEm(.T.)
				MsgInfo("Aconteceu um erro na autenticacao do e-mail, informe ao TI e tente REENVIAR novamente mais tarde!!","KAPAZI - SUPPLIER CARD")
		EndIf
	Else
		MsgInfo("Existem itens com inconsistencias, favor verificar!!","KAPAZI - SUPPLIER CARD")
		cAliasS1->(DbCloseArea())
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
Local cAliasS1		:= GetNextAlias()

If Select("cAliasS1")<>0
	DbSelectArea("cAliasS1")
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,* "
cQr += " FROM "+ RetSqlName("ZS1") +" ZS1 "
cQr += " WHERE D_E_L_E_T_ = '' "
cQr += " AND ZS1_XIDINT = '' "
cQr += " AND ZS1_STATUS = '1' "

// abre a query
TcQuery cQr new alias "cAliasS1"

DbSelectArea("cAliasS1")
cAliasS1->(DbGoTop())

Return(cAliasS1->(EOF()))

//Grava o retorno do email
Static Function GrvRetEm(lRet)
Local cSql	:= ""

cSql	:= " UPDATE "+ RetSqlName("ZS1") +" "
If lRet
		cSql	+= " SET ZS1_NOMARQ = '"+cNmArq+"', ZS1_ENVEMA = 'S' "
	Else
		cSql	+= " SET ZS1_NOMARQ = '"+cNmArq+"', ZS1_ENVEMA = 'N' "
EndIf
cSql	+= " WHERE ZS1_XIDINT = '"+cIdSP+"' "

Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif

Return()

//Log
Static Function GravaLGK()
Local nL		:= 1
Local cItemG	:= ""
Local cItem		:= ""

For nL	:= 1 To Len(aLogKP)
	
	cItemG	:= GETSXENUM( "ZL1","ZL1_ITGER", "ZL1_ITGER",4)
	ConfirmSX8()
	cItem	:= RetIteCGC(aLogKP[nL][1])

	//aAdd(aLogKP,{cAliasS1->ZS1_CGC, STOD(ZS1_DATAIN),ZS1_HORAII,DATE(),TIME(),__cUserID,UsrFullName(__cUserID)})
	DbSelectArea("ZL1")
	Reclock("ZL1",.T.)
	ZL1->ZL1_ITGER	:= cItemG
	ZL1->ZL1_CGC	:= aLogKP[nL][1]
	ZL1->ZL1_ITEM	:= cItem
	ZL1->ZL1_DTAPUR	:= aLogKP[nL][2]
	ZL1->ZL1_HRAPUR	:= aLogKP[nL][3]
	ZL1->ZL1_DTENVI	:= aLogKP[nL][4]
	ZL1->ZL1_HRENVI	:= aLogKP[nL][5]
	ZL1->ZL1_ARQUIV	:= cNmArq
	ZL1->ZL1_USRID	:= aLogKP[nL][6]
	ZL1->ZL1_USRNM	:= aLogKP[nL][7]
	ZL1->(MsUnlock())

Next

Return()

//Retorna item
Static Function RetIteCGC(cCGCc)
Local cNum	:= ""
Local TRZL1	
Local cQry	:= ""

cQry:=" SELECT TOP 1 ZL1_ITEM FROM "+RetSqlName('ZL1')
cQry+=" WHERE ZL1_CGC ='"+cCGCc+"'
cQry+=" ORDER BY ZL1_ITEM DESC"

IF Select('TRZL1')<>0
	TRZL1->(DbCloseArea())
EndIF
TCQuery cQry New Alias "TRZL1"

TRZL1->(DbGoTop())
IF TRZL1->(EOF())
		cNum := "000001"
	Else
		cNum := Soma1(TRZL1->ZL1_ITEM)
EndIF

Return(cNum)