#INCLUDE "RWMAKE.CH"

//-------------------------
/*/{Protheus.doc} MT103NTZ
Ponto de entrada para tratar a natureza de acordo com o pedido, na geração do documento de entrada.

@author Edilson Marques
@since 09/10/2012
@version 2.0

@return cMT103NTZ Retorna a Natureza

@sample cValor := U_MT103NTZ()

@obs
Lucas - FSW - TOTVS Curitiba | 28-04-2014 | 
	Revisão na rotina após apontamento de não conformidade. Em verificação, a rotina da erro no momento de busca de dados.
/*/
//-------------------------
User Function MT103NTZ()

Local cMT103NTZ	:= ParamIxb[1]
Local nPosxNat  := aScan(aHeader,{|x| alltrim(x[2]) == 'D1_XNATURE'})
Local nPosPed   := aScan(aHeader,{|x| alltrim(x[2]) == 'D1_PEDIDO' })
Local nPosItPed := aScan(aHeader,{|x| alltrim(x[2]) == 'D1_ITEMPC' })

if nPosPed > 0 .and. Empty(cMT103NTZ)
	cMT103NTZ := aCols[n, nPosxNat]
endif

Return(cMT103NTZ)