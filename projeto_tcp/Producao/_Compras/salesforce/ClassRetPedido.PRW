#INCLUDE "PROTHEUS.CH"

CLASS ClassRetPedido 

DATA cCodAL
DATA cPuchase
DATA cOrderId
DATA cMensagem
DATA lLibera

method new() constructor 

ENDCLASS

method new() class ClassRetPedido
	::cCodAL    := ''
	::cPuchase  := ''
	::cOrderId  := ''
	::cMensagem := ''
	::lLibera   := ''
return
