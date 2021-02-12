#include 'protheus.ch'
#include 'parmtype.ch'

user function GatAtf03()

oModelx := fwModelActive()

oModelxMo := oModelx:getModel('SN1MASTER')

oModelxMo:loadValue('N1_CBASE', strZero(val(allTrim(oModelxMo:getValue('N1_CBASE'))) ,10 ,0) )

oView := fwViewActive()

oView:refresh()

return strZero(val(allTrim(oModelxMo:getValue('N1_CBASE'))), 10, 0) 
