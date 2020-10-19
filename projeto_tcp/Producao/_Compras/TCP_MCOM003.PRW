/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Rotina                                                  |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_MCOM003.PRW                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Fonte para geração da SA5 automaticamente               |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 16/05/2013                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|                                           |           |           |        |
|                                           |           |           |        |
+-------------------------------------------+-----------+-----------+-------*/
// includes e defines
#INCLUDE "RWMAKE.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

/*--------------------------+----------------------------+--------------------+
| Função: MCOM003           | Autor: Lucas J. C. Chagas  | Data: 16/05/2013   |
+------------+--------------+----------------------------+--------------------+
| Parâmetros |                                                                |
+------------+----------------------------------------------------------------+
| Descricao  | Rotina para cadastrar automaticamente SA5 a partir da SC8      |
+------------+---------------------------------------------------------------*/
User Function MCOM003()

Local aArea := GetArea()
Local bProcess := Nil
Local oProcess := Nil	
private nErros := 0

dbSelectArea('SA5')
SA5->(dbSetOrder(1))

dbSelectArea('SC8')
SC8->(dbSetOrder(1)) 
SC8->(dbGoTop())

bProcess := {|oSelf| MCOM0031(oSelf)}
oProcess := tNewProcess():New("MCOM0031","Criação de cadastro Produtos x Fornecedores" ,bProcess,"Geração de cadastro de Produtos x Fornecedores a partir das Cotações.",,,.F.,,,.T.,.F.)

if nErros > 0
	Aviso ( 'Produtos x Fornecedores','Um ou mais erros foram gerados na rotina, por favor verificar a pasta "c:\temp" de seu computador.',{'OK'},1,'',1,,.F.,200,1)
endif

oProcess := FreeObj(oProcess)

RestArea(aArea)

return 

/*--------------------------+----------------------------+--------------------+
| Função: MCOM0031          | Autor: Lucas J. C. Chagas  | Data: 16/05/2013   |
+------------+--------------+----------------------------+--------------------+
| Parâmetros |                                                                |
+------------+----------------------------------------------------------------+
| Descricao  | Rotina para cadastrar automaticamente SA5 a partir da SC8      |
+------------+---------------------------------------------------------------*/
Static Function MCOM0031( oProcess )

Local aArea    := GetArea()	
Local aMata060 := {}

oProcess:SetRegua1(SC8->(RecCount)) // regua boba
oProcess:IncRegua1("Iniciando processamento: " + dToC(dDatabase) + " " + Time())
oProcess:SaveLog("Iniciando processamento: " + dToC(dDatabase) + " " + Time())
ProcessMessage()

while !SC8->(EOF()) .AND. !oProcess:lEnd
	
	// vai procurar se na SA5 jÃ¡ existe um cadastro de fornecedor + loja + produto para o registro da SC8
	SA5->(dbGoTop())
	oProcess:IncRegua1("Pesquisando registro (" + xFilial('SA5') + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_PRODUTO + ")...")
	ProcessMessage()
	if !SA5->(dbSeek(xFilial('SA5') + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_PRODUTO))
	
		oProcess:IncRegua1("Registro encontrado... cadastrando na tabela SA5...")
		ProcessMessage()
		aMata060 := {}		
		aAdd( aMata060, { "A5_FILIAL" , xFilial('SA5') , Nil } )
		aAdd( aMata060, { "A5_FORNECE", SC8->C8_FORNECE, Nil } )
		aAdd( aMata060, { "A5_LOJA"   , SC8->C8_LOJA   , Nil } )
		aAdd( aMata060, { "A5_PRODUTO", SC8->C8_PRODUTO, Nil } )
		
		nErros := iif(U_TCPMTA060(aMata060, 3), nErros, nErros + 1)				
	endif
	
	SC8->(dbSkip())	
	ProcessMessage() 
enddo

oProcess:IncRegua1("Finalizando processamento: " + dToC(dDatabase) + " " + Time())
oProcess:SaveLog("Finalizando processamento: " + dToC(dDatabase) + " " + Time())

RestArea(aArea)

Return Nil