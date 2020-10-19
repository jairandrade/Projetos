#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM005
Rotina para visualização de classificação de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function ACOM005()
 
Private cCadastro := "Resultados por NF x Fornecedor"
Private aRotina 	:= {}                          
Private cAlias 	:= "Z06"
	

AADD(aRotina,{"Pesquisar"			,"AxPesqui"	, 		0,1})	
AADD(aRotina,{"Visualizar"			,"AxVisual"	, 		0,2})
                             
dbSelectArea(cAlias)
dbSetOrder(1)
	
mBrowse(,,,,cAlias)

Return 

