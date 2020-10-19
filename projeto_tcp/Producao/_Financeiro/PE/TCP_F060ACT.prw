#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  F060ACT		¦ Autor ¦ Lucilene Mendes    ¦ Data ¦18.11.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ponto de entrada na gravação da transf de carteira        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function F060ACT()
Local aDados:= Paramixb   //M->E1_SITUACA,cPort060,cAgen060,cConta060,lDesc,cCliente,cTitulo,cSituAnt,cContrato,cPortador                      	
Local cCarteira	:= aDados[1,1]
Local cCartAnt 	:= aDados[1,8]
Local cBcoProt:= GetNewPar("TC_BCOINST","341")  //Banco com instrução bancária configurada                 
Local cOcorren:= GetNewPar("TC_"+aDados[1,2]+"BAIX","02") //Ocorrencia de pedido de baixa
Local cBcoTit := Substr(aDados[1,10],1,3)

//Identifica se o título foi enviado para o banco
If cBcoTit $ cBcoProt .and. !Empty(SE1->E1_IDCNAB)
	If cCartAnt = '1' .and. cCarteira = '0' //Se alterado de Cobrança Simples para Carteira
	    
		Aviso("Instrução de Cobrança","Não será possível gerar automaticamente a instrução de PEDIDO DE BAIXA. Cadastre a instrução diretamente no banco.",{"OK"})
	Endif		
Endif	

	
Return