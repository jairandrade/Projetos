#include 'protheus.ch'
#include 'parmtype.ch'

user function GatAtf04()

oModelx := fwModelActive()

oModelxMo := oModelx:getModel('SN1MASTER')

oModelxMo:loadValue('N1_CHAPA', strZero(val(allTrim(oModelxMo:getValue('N1_CHAPA'))) ,20 ,0) )

oView := fwViewActive()

oView:refresh()

return strZero(val(allTrim(oModelxMo:getValue('N1_CHAPA'))), 20, 0) 
