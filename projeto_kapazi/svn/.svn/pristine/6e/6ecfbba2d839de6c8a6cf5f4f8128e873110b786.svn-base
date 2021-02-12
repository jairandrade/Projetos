#include 'protheus.ch'
#include 'parmtype.ch'

/*{Protheus.doc} FISENVNFE
//TODO Grava o numero da NF e Serie no Fluig.
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
//Ponto de entrada executado logo após a transmissão/autorizacao da NF-e.
User Function FISENVNFE()
	Local aIdNfe 	:= PARAMIXB
	Local cSerieNF	:= mv_par01
	Local cNotaDe	:= mv_par02 //nota de
	Local cNotaAte  := mv_par03 //nota ate
	local cNota     := ""       //variavel para While

	If Alltrim(cEmpAnt) == "04" //Adicionado tratamento para empresa 04 - Luis 21-05-18
	
		If Len(aIdNfe) > 0
			cNota := cNotade
		    DBSelectArea('SC6')  //Itens do Pedido de Vendas
		    SC6->(DBSetOrder(4)) //C6_FILIAL+C6_NOTA+C6_SERIE
		    
			DBSelectArea('SCJ')  //Orçamento
	        SCJ->(DBSetOrder(1)) //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	 
	        DBSelectArea('ZA1')  //Integração Protheus vs Fluig
			ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM			
	 
			While cNota <= cNotaAte
			   SC6->(DBSeek(xFilial('SC6') + cNota + cSerieNF))
			   SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,TamSX3('CJ_NUM')[1])))
			   If !Empty(SCJ->CJ_XNUMFLU)
			   		alert('ENTROU TRANSMISSAO')	
					alert(cNota + cSerieNF+"-"+CEMPANT + CFILANT+"-"+SCJ->CJ_XNUMFLU)	
					IF !ZA1->(DBSeek(xFilial('ZA1')+PADR('TRANSMITE NF',TamSX3('ZA1_TIPO')[1])+cNota + cSerieNF))
					  	alert('ENTROU IF')	
					   	Reclock('ZA1',.T.)
							ZA1->ZA1_FILIAL:=xFilial('ZA1')
							ZA1->ZA1_TIPO  :='TRANSMITE NF'
							ZA1->ZA1_NUM   :=cNota + cSerieNF
							ZA1->ZA1_STATUS:='1' //Aguardando	
							ZA1->ZA1_DTCRIA:=Date()
							ZA1->ZA1_HRCRIA:=Time()	
							ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU	
						MsUnlock()
						
						//Inicia o JOB que irá integrar com o Fluig
						//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
						StartJob('U_KAPJOB', GetEnvServer(),.F., 'TRANSMITE NF', cNota + cSerieNF, CEMPANT, CFILANT)
					ENDIF
					alert('SAIU TRANSMISSAO')	
				endif
				cNota := soma1(cNota)
			EndDo
		
		Else	
			MsgAlert("Transmissão da NF-e Falhou")
		EndIf
	
	EndIf

Return