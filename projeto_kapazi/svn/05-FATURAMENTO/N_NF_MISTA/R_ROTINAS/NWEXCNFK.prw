#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: NWEXCNFK		|	Autor: Luis Paulo							|	Data: 01/01/2019	//
//==================================================================================================//
//	Descrição: Funcao JOB por excluir faturas no processo de NF Mista entre filiais					//
//																									//
//	Alterações:																						//
//	-																								//
//==================================================================================================//
User Function NWEXCNFK(cIdNFSE)
Local cEmpNew 		:= "04"
Local cFilNew		:= "01"
Private lRet		:= .T.
Private cCondPGK	:= ""
Private lPedSpp		:= .F.
Private cErro		:= ""
	
Conout("Excluindo Faturas na 0401...")
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)

//Seta a nova empresa
RpcClearEnv()
RpcSetType(3)
lConec := RpcSetEnv(cEmpNew, cFilNew,"NFMISTA","kylix125","FAT")

xExFatur(cIdNFSE) //Exclui as faturas 

Conout("Fim do processo de faturas na 0401..."+cIdNFSE)
conout("cEmpNew = " + cEmpNew)
conout("cFilNew = " + cFilNew)	
Return(lRet)

//Exclui a fatura
Static Function xExFatur(cIdNFSE)
Local cAliasE1	:= ""
Local nRegs		:= 0
Local cQuery	:= ""
Local aArea		:= GetArea()
Local nReco		:= 0

If Select("cAliasE1") <> 0
	DBSelectArea("cAliasE1")
	cAliasE1->(DBCloseArea())
Endif

cAliasE1	:= GetNextAlias()

cQuery := " SELECT E1_PREFIXO,E1_NUMLIQ,R_E_C_N_O_ AS RECNOE1
cQuery += " FROM SE1040
cQuery += " WHERE D_E_L_E_T_ = ''
cQuery += " AND E1_XIDVNFK = '"+cIdNFSE+"'
cQuery += " AND E1_PREFIXO = 'FAT'

TCQuery cQuery NEW ALIAS 'cAliasE1'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasE1")
Count To nRegs
cAliasE1->(DbGoTop())

If nRegs > 0
	nReco	:= cAliasE1->RECNOE1
	DbSelectArea("SE1")
	DbGoto(nReco)
	FINA460( , , , 5, , cAliasE1->E1_NUMLIQ )	//Cancelamento da liquidacao

EndIf

cAliasE1->(DBCloseArea())

RestArea(aArea)
Return()