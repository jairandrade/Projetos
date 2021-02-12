#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Lançamentos Padrões                                                                                                                    |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 02/06/2020                                                                                                                       |
| Descricao: Busacar a natureza na FK2 devido ao registro de contra partida da compensação no SE5 estar deletado                         |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function NAT01()

Local aArea := GetArea()

Local cNat := " "


cQuery := "SELECT FK2_NATURE NATUREZ "
cQuery += "FROM " + RetSQLName("FK2") + " AS FK2 "
cQuery += "WHERE D_E_L_E_T_  = ' ' "
cQuery += "AND FK2_FILIAL = '" + SE5->E5_FILIAL + "' "
cQuery += "AND FK2_DATA = '" + DtoS(SE5->E5_DATA) + "' "
cQuery += "AND FK2_DOC = '" + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_FORNECE + SE5->E5_LOJA + "' "
cQuery += "AND FK2_SEQ = '" + SE5->E5_SEQ + "' "
If SE5->E5_TIPODOC == 'CP'
	cQuery += "AND FK2_TPDOC = 'BA' "
ElseIf SE5->E5_TIPODOC == 'BA'
	cQuery += "AND FK2_TPDOC = 'CP' "
ElseIf SE5->E5_TIPODOC == 'ES'
	cQuery += "AND FK2_TPDOC = 'ES' "
EndIf

TcQuery cQuery New Alias "CMPNAT"

If CMPNAT->(!Eof())
	cNat	:= CMPNAT->(NATUREZ)
Endif

dbCloseArea("CMPNAT")

RestArea(aArea)

Return(cNat)
