#INCLUDE "PROTHEUS.CH"       
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Ponto de entrada                                                                                                                       |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 20.01.2017                                                                                                                       |
| Descricao: Desabilita a altera��o dos campos data Data recebimento e Data Credito - Solicitado por Laertes                             |
| Empresa: KAPAZI                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/ 
//Compilado e validado no ambiente "compilar" - realizado testes por Laertes/Tati -- 20/01/2017
// Compilado em produ��o 20/01/2017 19hrs -- Andre/Rsac 
     

User Function F070DCNB()

Local aDisableFields := {} // Array 

/*outros campos disponiveis para utiliza��o na rotina
aAdd(aDisableFields, 'MULTA' )
aAdd(aDisableFields, 'DESCONTO' )
aAdd(aDisableFields, 'JUROS' )*/
aAdd(aDisableFields, 'DATABAIXA' )
aAdd(aDisableFields, 'DATACREDITO' )

Return(aDisableFields)
