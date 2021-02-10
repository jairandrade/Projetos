
// Funcao disparada num gatilho para preencher o codigo de barras a partir do campo linha editavel e2_linedit  By Rodrigo Slisinski 10/01/2010
User Function xCODBAR2(_cCodBar,oFld)
local cret:=""

local lRet:=.T.

If Len(alltrim(_cCodBar))== 48 .AND. !EMPTY(_cCodBar)
	cret:=substr(alltrim(_cCodBar),1,11)+substr(alltrim(_cCodBar),13,11)+substr(alltrim(_cCodBar),25,11)+substr(alltrim(_cCodBar),37,11)
	if !VLDCODBAR(cret)
		alert("Linha digitável inválida. Verificar digitacao!")
		cret:=""
		lRet := .F.
	EndIF
	oFld:SetValue('ZA0_CODBAR',cRet)
	Return lRet
	
EndIF
Return lRet

User Function xCODBAR(_cCodBar)
local cret:=""
If Len(alltrim(_cCodBar))== 48
	cret:=substr(alltrim(_cCodBar),1,11)+substr(alltrim(_cCodBar),13,11)+substr(alltrim(_cCodBar),25,11)+substr(alltrim(_cCodBar),37,11)
	if !VLDCODBAR(cret)
		alert("Verificar digitacao!")
		cret:=""
	EndIF
	
	Return cRet
	
EndIF
	cret:=substr(alltrim(_cCodBar),1,4)+substr(alltrim(_cCodBar),33,1)+substr(alltrim(_cCodBar),34,4)+substr(alltrim(_cCodBar),38,10);
	+substr(alltrim(_cCodBar),5,5)+substr(alltrim(_cCodBar),11,10)+substr(alltrim(_cCodBar),22,10)  
	
	
	if !VLDCODBAR(cret)
		alert("Verificar digitacao!")
		cret:=""
	EndIF
	
Return cRet

STATIC FUNCTION Modulo11(cData)
Local i := 1 
nMulti:=2
Nsoma:=0 
cDv:=""
for i:=1 to LEN(cData)
    nSoma  +=   Val(substr(cdata,len(cdata) - i + 1 , 1)) *  nMulti
 	nMulti:=nMulti+1
 	if nMulti > 9		
 		nMulti:=2
 	EndIF	
Next

cDv := IIF( (11 - mod(nSoma,11) ) > 9 ,'0',cValtoChar((11 - mod(nSoma,11)) ))          

RETURN(cDv)
