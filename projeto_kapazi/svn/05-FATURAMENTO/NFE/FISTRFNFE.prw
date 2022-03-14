/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financerio                                                                                                                             |
| Chamada de impress�o do boleto, no menu a��es relacionais da rotina SPEDNFE (NFE SEFAZ)                                                |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 04.08.2017                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//Realizado valida��o no ambiente compilar -- 09.08.2017 -- Andre/Rsac

User Function FISTRFNFE()

aadd(aRotina,{'Impress�o de boleto','U_BOLKAP' , 0 , 3,0,NIL})
aadd(aRotina,{'Boleto CHEIO','U_BOLKAPS' , 0 , 3,0,NIL})
aadd(aRotina,{'NFSe Betha','U_CADZP6' , 0 , 3,0,NIL})
aadd(aRotina,{'Monitor Kapazi','U_KPZMONFE()' , 0 , 3,0,NIL})
aadd(aRotina,{'Imprime CC-e','U_CPRTCCE' , 0 , 3,0,NIL})


Return Nil   

User Function NFEMNUCC()

Local aRotina := {}
aadd(aRotina,{'Imprime CC-e','U_CPRTCCE' , 0 , 3,0,NIL})

RETURN aRotina
