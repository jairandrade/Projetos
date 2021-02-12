               
/*/
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Descricao produto do pedido de compras para o documento de entrada quando utilizado a amarracao do pedido(F5)                          |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Fonte:MT103IPC.prw                                                                                                                     |
| Funcao:MT103IPC()                                                                                                                      |
| Data: 17/07/2014                                                                                                                       |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/


User Function MT103IPC()
  
 _xx := Len(aCols)
 aCols[_xx,aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="D1_DESCRI" })]:=SC7->C7_DESCRI

 
 Return	