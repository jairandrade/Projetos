#include "protheus.ch"


#define nSAY   1
#define nMETER 2



/*/{Protheus.doc} MaderoProcess
Classe para montar varias reguas conforme necessidade.

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0

@type class
/*/
class MaderoProcess

	data oDlg
	data bAction
	data aMeters
	data nWidth

	method new(bAction)
	method add(cTitle)
	method run()
	method setMeter(nIndice,nSet)
	method incMeter(nIndice,nMeter)
	method getMeter(nIndice)

endclass



/*/{Protheus.doc} new
Contrutor da classe

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param bAction, block, Ação do processamento
@param nWidth, numeric, Largura da janela, altura é dimensionavel conforme numero de reguas
@type function
/*/
method new(bAction, nWidth) class MaderoProcess

	default nWidth := 700

	::bAction := bAction
	::aMeters := {}

	::nWidth := nWidth

return self



/*/{Protheus.doc} add
Função para adicionar uma regua, apenas com titulo

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param cTitle, characters, descricao
@type function
/*/
method add(cTitle, cSubTitle) class MaderoProcess

	default cTitle := ''
	default cSubTitle := ''

	aAdd(::aMeters,{{ , cTitle, cSubTitle  }, { , 0 }})

return self



/*/{Protheus.doc} run
Metodo para ativação da classe

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0

@type function
/*/
method run() class MaderoProcess

	Local nIndice
	Local nLine := 5

	define msdialog ::oDlg from 0,0 to (55*len(::aMeters)),::nWidth title "" style nOR(WS_VISIBLE,WS_POPUP) status pixel

	For nIndice := 1 to len(::aMeters)

		::aMeters[nIndice][nSAY][1]   := TSay():New( nLine, 10, {|| "" }, ::oDlg, /*cPict*/, /*oFont*/, /*lCenter*/, /*lRight*/, /*lBorder*/,.T., /*nClrText*/, /*nClrBack*/, ::nWidth/2.1, 10, /*lDesign*/, /*lUpdate*/, /*lShaded*/, /*lBox*/, /*lRaised*/, .T./*lHtml*/ )
		::aMeters[nIndice][nSAY][1]:SetText('<b>' + ::aMeters[nIndice][nSAY][2] + '</b>       ' + ::aMeters[nIndice][nSAY][3] )

		::aMeters[nIndice][nMETER][1] := TMeter():New( nLine+11, 10, bSETGET(&("{|| ::aMeters["+cValToChar(nIndice)+"][nMETER][2] }")), 10/*nTotal*/, ::oDlg, ::nWidth/2.1, 10, /*lUpdate*/,.T., /*oFont*/, /*cPrompt*/, /*lNoPercentage*/,/*nClrPane*/, /*nClrText*/,/*nClrBar*/, /*nClrBText*/, /*lDesign*/ )
		::aMeters[nIndice][nMETER][1]:setFastMode(.T.)

		nLine += 25
	Next nIndice

	::oDlg:bStart := {|| Eval(self:bAction, @Self), self:oDlg:End()}

	activate msdialog ::oDlg centered

return



/*/{Protheus.doc} setMeter
Metodo para setar o tamanho (iterações) da regua

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@param nSet, numeric, tamanho
@type function
/*/
method setMeter(nIndice,nSet) class MaderoProcess

	default nSet := 10

	::aMeters[nIndice][nMETER][1]:Set(0)
	::aMeters[nIndice][nMETER][1]:SetTotal(nSet-1)
	::aMeters[nIndice][nMETER][1]:Refresh()

	SysRefresh()

return self


/*/{Protheus.doc} incMeter
incrementa a regua

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@type function
/*/
method incMeter(nIndice) class MaderoProcess

	::aMeters[nIndice][nMETER][1]:Set( ::aMeters[nIndice][nMETER][2] ++ )
	::aMeters[nIndice][nMETER][1]:Refresh()

	::aMeters[nIndice][nSAY][1]:SetText('<b>' + ::aMeters[nIndice][nSAY][2] + '</b>       '+cValToChar(::aMeters[nIndice][nMETER][2])+' de ' + ::aMeters[nIndice][nSAY][3] )

	SysRefresh()

return self


/*/{Protheus.doc} getMeter
Return o tamanho incrementado até o momento

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@type function
/*/
method getMeter(nIndice) class MaderoProcess
return ::aMeters[nIndice][nMETER][2]