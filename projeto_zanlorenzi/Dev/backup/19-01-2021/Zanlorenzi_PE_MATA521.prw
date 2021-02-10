#include "protheus.ch"
/*/{Protheus.doc} SF2520E
//O ponto de entrada SF2520E não espera nenhum retorno lógico em sua execução por isso 
não pode impedir que o processo continue, ele tem a finalidade de permitir a
execução de procedimentos antes que o estorno do documento de saída seja finalizado. 
@author Jair Andrade    
@since 15/01/2020
@version version
/*/
User Function SF2520E
	DbSelectArea("ZA7")
	ZA7->(DbGotop())
	ZA7->(DbSetOrder(3))
	If ZA7->(DbSeek( SD2->D2_FILIAL + SD2->D2_PEDIDO + SD2->D2_ITEMPD ))
		While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
			ZA7->(RecLock("ZA7" , .F.))
			ZA7->ZA7_STATUS := "4"
			ZA7->ZA7_DTFAT := ""
			ZA7->ZA7_HRFAT := ""
			ZA7->ZA7_DOC   := ""
			ZA7->(MsUnLock())
			ZA7->(DbSkip())
		Enddo
	EndIf
EndIf
Return
