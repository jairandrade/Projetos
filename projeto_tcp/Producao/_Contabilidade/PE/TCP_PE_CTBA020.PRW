
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  CTBA020                                                                                              |
 | Desc:  Ponto de Entrada para gravar informações na conta contabil                                          |
 | Desc:  Utilizado para enviar as informações para o Manusis  |                                        |
 *--------------------------------------------------------------------------------------------------------------*/
  
User Function CTBA020()                 

Local aParam     := PARAMIXB
Local oManusis  
     

If aParam <> NIL .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. )
		
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3] 
	If cIdPonto == 'MODELCOMMITNTTS'     
		oManusis  := ClassIntManusis():newIntManusis()  
	
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := CT1->CT1_FILIAL+CT1->CT1_CONTA
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'CT1'
		oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
	
		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF  
	endif			
ENDIF

Return .T.

#include 'totvs.ch'

/*---------------------------------------------------------------------------+
|                             FICHA TÉCNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Ponto de Entrada                                        |
+------------------+---------------------------------------------------------+
|Módulo            | Contabilidade Gerencial                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_PE_CTBA020                                          |
+------------------+---------------------------------------------------------+
|Descrição         | Fonte de ponto de entrada do programa CTBA020           |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criação   | 20/06/2013                                              |
+------------------+--------------------------------------------------------*/

/*----------+----------------------------------------------------------------+
| Rotina    | CT20GRD - Inclusão de Plano de Contas                          |
+-----------+----------------------------------------------------------------+
| Fonte     | http://tdn.totvs.com/pages/releaseview.action?pageId=6068599   |
+-----------+--------------------------+------+------------------------------+
| Analista  | Lucas José Corrêa Chagas | Data | 20/06/2013                   |
+-----------+--------------------------+------+------------------------------+
| Descrição | O ponto de entrada CT20GRD é executado após a inclusão no Plano|
| TDN       | de Contas.                                                     |
+-----------+----------------------------------------------------------------+
| Objetivo  | Ponto de entrada utilizado para exportar dados da empresa loga-|
|           | da para a empresa consolidadora, levando em consideração a ope-|
|           | ração realizada (inclusão, alteração e exclusão).              |
+-----------+----------------------------------------------------------------+
| Retorno   | Nenhum                                                         |
+-----------+---------------------------------------------------------------*/
User Function CT20GRD()

Local aArea := GetArea()

if AllTrim(cEmpAnt) != '90'
	U_ACTB001(M->CT1_FILIAL + M->CT1_CONTA) // rotina para tratar a inclusão
endif

RestArea(aArea)
Return Nil