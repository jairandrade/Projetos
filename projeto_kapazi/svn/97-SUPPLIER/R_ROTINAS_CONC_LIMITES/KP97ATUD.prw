#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97ATUD		|	Autor: Luis Paulo							|	Data: 11/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por atualizar os dados de clientes na concessão de limites		//
//																									//
//==================================================================================================//
User Function KP97ATUD()
Local aArea	:= GetArea()

//If Empty(ZS1->ZS1_XIDINT)
		Processa({||ProcAtuCo()} ,"Processando atualizações","Aguarde...")
//	Else
//		MsgInfo("Este ","Kapazi")
//EndIf
RestArea(aArea)
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ProcAtuCo    ! Autor !                  ! Data ! 12/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Processa atualizacoes.                                       !
+-----------+--------------------------------------------------------------+
*/
Static Function ProcAtuCo()
Local cQry		:= ""
Local cCRLF 	:= CRLF
Local cAliasSP	:= GetNextAlias()
Local nRegs		:= 0
Local nCount	:= 0

If Select("cAliasSP") <> 0
	DbSelectArea("cAliasSP")
	cAliasSP->(DbCloseArea())
EndIf

cQry	+= " SELECT	ZS1.ZS1_CGC,ZS1_NOME,ZS1.ZS1_DTNASC,ZS1.ZS1_RUA,ZS1.ZS1_NUMERO,ZS1.ZS1_COMPLE,ZS1.ZS1_CEP,ZS1.ZS1_CIDADE,ZS1.ZS1_UF,ZS1.ZS1_NMCONT,ZS1.ZS1_TEL,ZS1.ZS1_EMAIL,ZS1.ZS1_EMAILC,ZS1.ZS1_LIMATU, "+cCRLF
cQry	+= "		SA1.A1_CGC,SA1.A1_NOME,SA1.A1_DTNASC,SA1.A1_END,SA1.A1_NR_END,SA1.A1_COMPLEM,SA1.A1_CEP,SA1.A1_MUN,SA1.A1_EST,SA1.A1_CONTATO,SA1.A1_TEL,SA1.A1_EMAIL,SA1.A1_LC,ZS1.R_E_C_N_O_ AS RECZS1 "+cCRLF
cQry	+= " FROM ZS1040 ZS1 "+cCRLF
cQry	+= " INNER JOIN SA1010 SA1 ON ZS1.ZS1_CGC = SA1.A1_CGC AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQry	+= " WHERE ZS1_XIDINT = '' "+cCRLF
cQry	+= " AND ZS1.ZS1_STATUS = '1' "+cCRLF
cQry	+= " AND ZS1.ZS1_CGC = '"+ZS1->ZS1_CGC+"' "+cCRLF
cQry	+= " ORDER BY ZS1.R_E_C_N_O_ "+cCRLF

Conout(cQry)

TcQuery cQry New Alias "cAliasSP"
Count To nRegs

DbSelectArea("cAliasSP")
cAliasSP->(DbGoTop())

ProcRegua(nRegs)
While !cAliasSP->(EOF())
	
	nCount++
	IncProc('Processando atualizacoes  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	DbSelectArea("ZS1")
	ZS1->(DbGotop())
	ZS1->(DbGoto(cAliasSP->RECZS1))
	
	RecLock("ZS1",.F.)
	ZS1->ZS1_CGC		:= cAliasSP->A1_CGC
	ZS1->ZS1_NOME		:= cAliasSP->A1_NOME
	ZS1->ZS1_DTNASC		:= STOD(cAliasSP->A1_DTNASC)
	ZS1->ZS1_RUA		:= cAliasSP->A1_END
	ZS1->ZS1_NUMERO		:= cAliasSP->A1_NR_END
	ZS1->ZS1_COMPLE		:= cAliasSP->A1_COMPLEM
	ZS1->ZS1_CEP		:= cAliasSP->A1_CEP
	ZS1->ZS1_CIDADE		:= cAliasSP->A1_MUN
	ZS1->ZS1_UF			:= cAliasSP->A1_EST
	ZS1->ZS1_NMCONT		:= cAliasSP->A1_CONTATO
	ZS1->ZS1_TEL		:= cAliasSP->A1_TEL
	ZS1->ZS1_EMAIL		:= cAliasSP->A1_EMAIL
	ZS1->ZS1_EMAILC		:= cAliasSP->A1_EMAIL
	ZS1->ZS1_LIMATU		:= cAliasSP->A1_LC
	ZS1->(MsUnlock())
	
	XANREGA()
	
	cAliasSP->(DbSkip())
EndDo
	
Return()



//Atualiza o status
Static Function XANREGA()
Local aAreaZ1	:= ZS1->(GetArea())
Local cCmpObA	:= "ZS1_TPPESS/ZS1_CGC/ZS1_NOME/ZS1_TPSOLI/ZS1_RUA/ZS1_NUMERO/ZS1_BAIRRO/ZS1_CEP/ZS1_CIDADE/ZS1_UF/ZS1_NMCONT/ZS1_DDD/ZS1_TEL/ZS1_CDESDE/ZS1_TPCLIE/"
Local cCmpObB	:= "ZS1_PHISTC/ZS1_CODCOM/ZS1_DTFATU/ZS1_VLRTOR/ZS1_DTVENC/ZS1_VLRPAR"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZS1->ZS1_PHISTC) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
EndIf
	
RestArea(aAreaZ1)
Return()