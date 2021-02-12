#include 'protheus.ch'
#include 'parmtype.ch'

user function GatAtf02()
	
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local cDesc		:= oModel:GetValue('SN1MASTER','N1_DESCRIC')

oModel:SetValue('SN3DETAIL','N3_HISTOR',cDesc)

Return lRet
