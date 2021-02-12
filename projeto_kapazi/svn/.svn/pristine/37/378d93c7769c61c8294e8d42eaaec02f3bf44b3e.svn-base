#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
//Este ponto de entrada é utilizado para filtrar as NF’s na Exportação, permitindo exportar ou não a NF. 
user function SPDNFE01()
Local oNF     := ParamIXB[1]
Local lRet    := .T.
Local cChvNFe 
local cQry := ""

oNF     := ParamIXB[1]

/* 
Comentado em 28/08/18 - Luis RSAC
Conforme informado pela Silmara ao CID o sistema nao estava permitindo exportar NF Cancelada
Conforme alinhado com o CID neste dia, comentei essa parte do fonte para permitir a exportacao

If oNF:OWSNFECANCELADA<>Nil .And. !Empty(oNF:oWSNFeCancelada:cProtocolo)   
	cChvNFe := NfeIdSPED(oNF:oWSNFeCancelada:cXML,"Id")   
	lRet    := .F.
Endif
*/
if type("_lFiltraNF") <> "U" 
	_lFiltraNF := .F.
Endif

If _lFiltraNF
	// valida se o campo existe
	IF SF2->( FieldPos("F2_K_USRCO") ) > 0
		If !Empty(oNF:oWSNFe:cProtocolo)
			cNotaIni := oNF:cID
			cChvNFe  := NfeIdSPED(oNF:oWSNFe:cXML,"Id")
			cChvNFe := StrTran(cChvNFe,"NFe","")
			cChvNFe := StrTran(cChvNFe,"CTe","")
			cChvNFe := StrTran(cChvNFe,"MDFe","")		


			cQry := "select * from "+RetSQLName("SF2")+ " where F2_FILIAL = '"+xFilial("SF2")+"' and D_E_L_E_T_ <> '*' and F2_SERIE+F2_DOC = '"+cNotaIni+"' and F2_CHVNFE = '"+cChvNfe+"' "
			TcQuery cQry new Alias "QSF2"

			If QSF2->(!EOF())
				If QSF2->F2_K_USRCO <> RetCodUsr()
					lRet := .F.
				EndIf
			EndIf

			QSF2->(DbCloseArea())
		EndIf	 	
	EndIF
EndIf
Return lRet 
