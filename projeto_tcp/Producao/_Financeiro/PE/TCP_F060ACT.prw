#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  F060ACT		� Autor � Lucilene Mendes    � Data �18.11.18 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Ponto de entrada na grava��o da transf de carteira        ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function F060ACT()
Local aDados:= Paramixb   //M->E1_SITUACA,cPort060,cAgen060,cConta060,lDesc,cCliente,cTitulo,cSituAnt,cContrato,cPortador                      	
Local cCarteira	:= aDados[1,1]
Local cCartAnt 	:= aDados[1,8]
Local cBcoProt:= GetNewPar("TC_BCOINST","341")  //Banco com instru��o banc�ria configurada                 
Local cOcorren:= GetNewPar("TC_"+aDados[1,2]+"BAIX","02") //Ocorrencia de pedido de baixa
Local cBcoTit := Substr(aDados[1,10],1,3)

//Identifica se o t�tulo foi enviado para o banco
If cBcoTit $ cBcoProt .and. !Empty(SE1->E1_IDCNAB)
	If cCartAnt = '1' .and. cCarteira = '0' //Se alterado de Cobran�a Simples para Carteira
	    
		Aviso("Instru��o de Cobran�a","N�o ser� poss�vel gerar automaticamente a instru��o de PEDIDO DE BAIXA. Cadastre a instru��o diretamente no banco.",{"OK"})
	Endif		
Endif	

	
Return