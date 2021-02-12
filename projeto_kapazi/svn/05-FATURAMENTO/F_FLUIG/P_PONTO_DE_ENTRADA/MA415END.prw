/*/{Protheus.doc} MA415END
Ponto de Entrada que criar registro na tabela de integração e chama JOB para integrar
@type function
 
@author Leandro Favero
@since 01/07/2019
@version 1.0
/*/

#include 'protheus.ch'

user function MA415END()
    Local aArea := GetArea()
	Local nTipo := PARAMIXB[1] //Indica se confirmou a operação: 0 - Não confirmou / 1 - Confirmou a operação
	Local nOper := PARAMIXB[2] //Indica o tipo de operação: 1 - Inclusão / 2 - Alteração / 3 - Exclusão

	//Indica se confirmou a operação: 0 - Não confirmou / 1 - Confirmou a operação
	If  nTipo == 1 
		//1 - Inclusão
		If  nOper == 1  
		    If !Empty(SCJ->CJ_XREFERE)  
				Reclock('ZA1',.T.)
				ZA1->ZA1_FILIAL:=xFilial('ZA1')
				ZA1->ZA1_TIPO  :='ORCAMENTO'
				ZA1->ZA1_NUM   :=SCJ->CJ_NUM
				ZA1->ZA1_STATUS:='1' //Aguardando	
				ZA1->ZA1_DTCRIA:=Date()
			    ZA1->ZA1_HRCRIA:=Time()
			    MsUnlock()
	
				//Inicia o JOB que irá integrar com o Fluig
				//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
				StartJob('U_KAPJOB',GetEnvServer(),.F., 'ORCAMENTO', SCJ->CJ_NUM, CEMPANT, CFILANT)
			endif
		EndIf
	EndIf

	RestArea(aArea)

return .T.