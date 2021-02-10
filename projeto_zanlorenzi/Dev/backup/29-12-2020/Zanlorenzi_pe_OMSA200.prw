#include "protheus.ch"

/*/{Protheus.doc} OM200MNU
//Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, 
ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OM200MNU
/*
Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.
*/  
	AAdd( aRotina, { 'EDI Transportadoras', 'U_OMS100T', 0, 4 } )
	AAdd( aRotina, { 'Cancelar EDI', 'U_OMS100C', 0, 4 } )
Return Nil
/*/{Protheus.doc} OM200LEG
//O ponto de entrada OM200LEG tem por objetivo a inclusão de novas legendas na rotina de montagem de carga.
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OM200LEG()
	Local aLeg := {}
	AAdd(aLeg,{"BR_AZUL"    , "Enviado transportadora"    } )
	AAdd(aLeg,{"BR_BRANCO"    , "Aguardando faturamento"    } )
	AAdd(aLeg,{"BR_AMARELO"    , "Cancelamento transportadora"    } )
	
Return( aLeg )
/*/{Protheus.doc} OM200CND
//Este Ponto de Entrada permite incluir as condições para apresentação, na rotina de Montagem de Carga (OMSA200), 
das legendas criadas no ponto de entrada OM200LEG.
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OM200CND()
	Local aCores :={}//aCores	Array
	aCores := {{ "DAK_STATUS=='3'" 	,  "BR_AZUL" },;
	{"DAK_STATUS=='4'","BR_BRANCO"},;
	{"DAK_STATUS=='5'","BR_AMARELO"}}

Return(aCores)
