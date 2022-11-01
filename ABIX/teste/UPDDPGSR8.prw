#INCLUDE "TOTVS.CH"
#INCLUDE "UPDDPGSR8.CH"

/*/{Protheus.doc} UPDDPGSR8
Programa para ajustar o campo R8_DPAGOS que est�o incorretos devido a erro no fechamento do periodo
@author  paulo.inzonha
@since   22/03/2019
@version 1.0
/*/
User Function UPDDPGSR8()
    Local aArea    := GetArea()

    fMontaWizard()
    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaWizard
Fun��o para montar a Wizard de execu��o
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
Static Function fMontaWizard()
    Local cText1 := STR0001 //"Realize o backup da base antes de executar esse processo."
    Local cText2 := STR0002 //"Ferramenta para ajuste dos dias pagos na SR8."
    Local cText3 := STR0003 //"UPDDPGSR8 - Atualizada dias pagos empresa na aus�ncia do funcion�rio."
    Local ctext4 := STR0004 //"Ao final do processamento os dias pagos da SR8 estar�o corrigidos."
    
	oWizard := APWizard():New( cText1, cText2, cText3, ctext4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )
	
	//Painel 2 - Execu��o do processo
	oWizard:NewPanel(	STR0005 ,; //"Realizando atualiza��o da base..."
						STR0006 ,; //"Aguarde enquanto o processamento � executado."
						{||.F.}                   ,; //<bBack>
						{||.F.}                   ,; //<bNext>
						{||.T.}                   ,; //<bFinish>
						.T.                       ,; //<.lPanel.>
						{| lEnd| fCallExec(@lEnd)}) //<bExecute>
	
	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/{Protheus.doc} fCallExec
Fun��o para prepara��o e chamada da execu��o
@author  gabriel.almeida
@since   25/02/2018
@version 1.0
/*/
Static Function fCallExec(lEnd)
	Private oProcess
	
	// Executa o processamento de atualiza��o das datas chamando a fun��o fUpdDtPgFer
	oProcess := MsNewProcess():New( {|lEnd| fUpdDPgSR8(oProcess) } , STR0007 , STR0007 ) //"Executando atualiza��o das datas..."
	oProcess:Activate()
	
Return

/*/{Protheus.doc} fUpdDtPgFer
Fun��o que executa o processo de atualiza��o da base corrigindo os dias pagos 
@author  paulo.inzonha
@since   22/03/2019
@version 1.0
/*/
Static Function fUpdDPgSR8(lEnd)
	Local cErro		:= ""
	Local lBackup   := MsgYesNo(STR0008) //"O backup da base j� foi realizado?"

    If lBackup
	    Begin Transaction			
			cQry := " UPDATE " + Retsqlname("SR8")+ " SET R8_DPAGOS = CASE WHEN R8_DIASEMP < R8_DURACAO THEN R8_DIASEMP"
			cQry += 												" ELSE R8_DURACAO END, "
			cQry += 									  "R8_SDPAGAR = CASE WHEN R8_SDPAGAR > R8_DPAGAR THEN 0 ELSE R8_SDPAGAR END "
			cQry += " WHERE D_E_L_E_T_='' AND ( R8_DPAGOS > R8_DURACAO OR R8_DPAGOS > R8_DIASEMP OR R8_DPAGOS < 0 ) "
			nRet := TCSQLEXEC(cQry)
			If nRet != 0
				cErro += TCSqlError()
				DisarmTransaction()
			EndIf
		End Transaction
		MsgInfo(STR0010 + If(!Empty(cErro), " - " + cErro, ""))
    Else
        MsgInfo(STR0009) //"Realize o backup e execute a rotina novamente."
    EndIf
Return