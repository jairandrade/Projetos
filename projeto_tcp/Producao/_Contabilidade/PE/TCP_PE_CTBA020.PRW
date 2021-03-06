
/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  CTBA020                                                                                              |
 | Desc:  Ponto de Entrada para gravar informa��es na conta contabil                                          |
 | Desc:  Utilizado para enviar as informa��es para o Manusis  |                                        |
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
|                             FICHA T�CNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Ponto de Entrada                                        |
+------------------+---------------------------------------------------------+
|M�dulo            | Contabilidade Gerencial                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_PE_CTBA020                                          |
+------------------+---------------------------------------------------------+
|Descri��o         | Fonte de ponto de entrada do programa CTBA020           |
+------------------+---------------------------------------------------------+
|Autor             | Lucas Jos� Corr�a Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Cria��o   | 20/06/2013                                              |
+------------------+--------------------------------------------------------*/

/*----------+----------------------------------------------------------------+
| Rotina    | CT20GRD - Inclus�o de Plano de Contas                          |
+-----------+----------------------------------------------------------------+
| Fonte     | http://tdn.totvs.com/pages/releaseview.action?pageId=6068599   |
+-----------+--------------------------+------+------------------------------+
| Analista  | Lucas Jos� Corr�a Chagas | Data | 20/06/2013                   |
+-----------+--------------------------+------+------------------------------+
| Descri��o | O ponto de entrada CT20GRD � executado ap�s a inclus�o no Plano|
| TDN       | de Contas.                                                     |
+-----------+----------------------------------------------------------------+
| Objetivo  | Ponto de entrada utilizado para exportar dados da empresa loga-|
|           | da para a empresa consolidadora, levando em considera��o a ope-|
|           | ra��o realizada (inclus�o, altera��o e exclus�o).              |
+-----------+----------------------------------------------------------------+
| Retorno   | Nenhum                                                         |
+-----------+---------------------------------------------------------------*/
User Function CT20GRD()

Local aArea := GetArea()

if AllTrim(cEmpAnt) != '90'
	U_ACTB001(M->CT1_FILIAL + M->CT1_CONTA) // rotina para tratar a inclus�o
endif

RestArea(aArea)
Return Nil