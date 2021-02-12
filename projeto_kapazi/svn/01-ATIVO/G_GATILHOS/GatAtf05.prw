#include 'protheus.ch'
#include 'parmtype.ch'

user function GatAtf05()

oModelx := fwModelActive()

oModelxMo := oModelx:getModel('SNGMASTER')

oModelxMo:loadValue('NG_GRUPO', strZero(val(allTrim(oModelxMo:getValue('NG_GRUPO'))) ,4 ,0) )

oView := fwViewActive()

oView:refresh()

return strZero(val(allTrim(oModelxMo:getValue('NG_GRUPO'))), 4, 0) 
