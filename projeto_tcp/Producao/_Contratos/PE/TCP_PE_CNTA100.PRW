/*/{Protheus.doc} CN100SIT
Situa��es do contrato
LOCALIZA��O : Function CN100Situac() - Respons�vel pelo controle de situa��es do contrato.
EM QUE PONTO : � executado ap�s a altera��o da situa��o do contrato, quando � definido que o contrato passar� de uma situa��o para outra. Sua execu��o ocorre ap�s o processamento interno do sistema.

@author Hugo
@since 17/09/2014
@version 1.0

@see http://tdn.totvs.com/pages/releaseview.action?pageId=6089554
/*/
//******************************************************//
User Function CN100SIT()
	
	Local aAreaA := GETAREA()
	
	//Chama rotina para gerar titulo de adiantamento
	If CN9->CN9_SITUAC == "05"
		// pesquisa se o tipo do contrato � de compra....
		dbSelectArea('CN1')
		CN1->(dbSetOrder(1))
		If CN1->(dbSeek( xFilial('CN1') + CN9->CN9_TPCTO ))
			If (allTrim(CN1->CN1_ESPCTR) == '1')
				
				//Busca os usu�rios responsaveis do grupo
				DbSelectArea('ZZD')
				If ZZD->(DbSeek(xFilial('ZZD') + CN9->CN9_RESP))
					
					While ZZD->ZZD_GRUPO = CN9->CN9_RESP
						
						If !CNN->(DbSeek(xFilial('CNN') + ZZD->ZZD_USER + CN9->CN9_NUMERO))
							
							//Libera as medi��es
							RecLock('CNN', .T.)
							CNN_FILIAL := CN9->CN9_FILIAL
							CNN_CONTRA := CN9->CN9_NUMERO
							CNN_USRCOD := ZZD->ZZD_USER
							CNN_GRPCOD := ''
							CNN_TRACOD := '020'
							CNN->(MsUnlock())
							
							//Libera visualiza��o dos contratos
							RecLock('CNN', .T.)
							CNN_FILIAL := CN9->CN9_FILIAL
							CNN_CONTRA := CN9->CN9_NUMERO
							CNN_USRCOD := ZZD->ZZD_USER
							CNN_GRPCOD := ''
							CNN_TRACOD := '037'
							CNN->(MsUnlock())
							
						EndIf
						
						ZZD->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
	EndIf
	               
	RESTAREA(aAreaA)	
Return            




User function CN100GRC

Local xnopcao:=paramixb[1]
if xnopcao == 3  .or. xnopcao == 4
	Reclock("CN9",.F.)
	CN9->CN9_DTFIM:=CN9->CN9_XDTFIM+CN9->CN9_XVIGEN
	MSUNLOCK()			
EndIF
Return

