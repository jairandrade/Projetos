#include 'protheus.ch'

/*/{Protheus.doc} ImgT1
Etiqueta de endereços

@author Rafael Ricardo Vieceli
@since 09/2015
@version 1.0
/*/
User Function ImgT1()

	Local cCodigo

	MSCBBEGIN(1,6)
	MSCBSAYBAR(02,02,AllTrim(SBF->BF_NUMSERI),"N","MB07",16,.F.,.F.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBSAY(67,05, AllTrim(SBF->BF_NUMSERI), "N", "0", "070,060")
	MSCBInfoEti("Numero-de-Serie","20X100")
	MSCBEND()
	//Aviso("mscb", MSCBEND(), {"botao"}, 3)

Return .F.
