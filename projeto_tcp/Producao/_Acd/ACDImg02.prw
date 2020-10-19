#include 'protheus.ch'

/*/{Protheus.doc} Img02
Etiqueta de endereços

@author Rafael Ricardo Vieceli
@since 06/08/2015
@version 1.0
/*/
User Function Img02()

	Local cCodigo
	Local cCodID := ParamIXB[1]

	IF cCodID # NIL
		cCodigo := cCodID
	ElseIF Empty(SBE->BE_IDETIQ)
		IF UsaCB0('02')
			cCodigo := CBGrvEti('02',{SBE->BE_LOCALIZ,SBE->BE_LOCAL})
			RecLock("SBE",.F.)
			SBE->BE_IDETIQ := cCodigo
			MsUnlock()
		Else
			cCodigo :=SBE->(BE_LOCAL+BE_LOCALIZ)
		EndIF
	Else
		IF UsaCB0('02')
			cCodigo := SBE->BE_IDETIQ
		Else
			cCodigo :=SBE->(BE_LOCAL+BE_LOCALIZ)
		EndIF
	EndIF
	cCodigo := alltrim(cCodigo)

	MSCBBEGIN(1,6)
	MSCBSAYBAR(05,02,cCodigo,"N","MB07",16,.F.,.F.,.F.,,3,2,.F.,.F.,"1",.T.)
	MSCBSAY(65,05, AllTrim(SBE->BE_LOCALIZ), "N", "0", "050,050")
	MSCBInfoEti("Endereco","20X100")
	MSCBEND()

Return .F.
