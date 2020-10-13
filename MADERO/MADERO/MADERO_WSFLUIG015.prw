#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} GetGruposProdutos
//TODO Declaração do WebService WSProdutoFLuig
@author Mario L. B. Faria
@since 12/07/2018
@version 1.0
alteração - JAIR - 27-04-2020 - incluido campo B1_XUSER -> CMAIL na gravação dos dados.
/*/

WSRESTFUL WSProdutoFluig DESCRIPTION "Madero - CRUD de Produtos enviados via FLUIG - FLUIG"

WSMETHOD POST 	DESCRIPTION "Gravação de Produtos enviados via FLUIG" 	WSSYNTAX "/WSProdutoFluig"
WSMETHOD PUT 	DESCRIPTION "Edição de Produtos enviados via FLUIG" 	WSSYNTAX "/WSProdutoFluig"
//WSMETHOD PUT 	DESCRIPTION "Bloquei de Produtos enviados via FLUIG" 	WSSYNTAX "/WSProdutoFLuig"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSProdutoFLuig
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE WSProdutoFluig

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial 
	Local aVetor	:= {}
	Local cGerar	:= .F.
	Local B1_XLOCAL := ""
	Local B1_XTIPO  := ""
	Local B1_TIPO   := ""
	Local B1_GRUPO  := ""
	Local B1_DESC   := ""
	Local B1_UM     := ""
	Local B1_SEGUM  := ""
	Local B1_CONV   := ""
	Local B1_TIPCON := ""
	Local B1_APROPRI := ""
	Local B1_XCLAS  := ""
	Local B1_LOCPAD := ""
	Local B1_LOCALIZ := ""
	Local B1_RASTRO := ""
	Local B1_POSIPI := ""
	Local B1_ORIGEM := ""
	Local B1_GRUPCOM := ""
	Local B1_MCUSTD := ""
	Local B1_XN1    := ""
	Local B1_XN2    := ""
	Local B1_XN3    := ""
	Local B1_XN4    := ""
	Local B1_IPI    := ""
	Local B1_GRTRIB := ""
	Local B1_IRRF   := ""
	Local B1_INSS   := ""
	Local B1_REDPIS := ""
	Local B1_REDCOF := ""
	Local B1_PPIS   := ""
	Local B1_PCOFINS := ""
	Local B1_CSLL   := ""
	Local B1_PCSLL  := ""
	Local B1_CEST   := ""
	Local B1_CONTA  := ""
	Local B1_CTAREC := ""
	Local B1_CTADESP := ""
	Local B1_CTACUST := ""
	Local B1_CTATRAN := ""
	Local B1_EMIN   := ""
	Local B1_XDIAES := ""
	Local B1_ESTSEG := ""
	Local B1_PE     := ""
	Local B1_MRP    := ""
	Local B1_EMAX   := ""
	Local B1_PRVALID := ""
	Local B1_TIPOCQ := ""
	Local B1_NUMCQPR := ""
	Local B1_COD	:=	""
	Local B1_MSBLQL	:=	""
	LOCAL B1_TIPCAR  := ""
	LOCAL B1_XCODEXT := ""
	LOCAL B1_CATMAPA := ""
	LOCAL B1_PACAMAP := ""
	LOCAL B1_CRECMAP := ""
	LOCAL B1_PRECMAP := ""
	LOCAL B1_PESOMAP := ""
	LOCAL B1_XLACTOS := ""
	LOCAL B1_XPADMAP := ""
	LOCAL B1_XALERG  := ""
	LOCAL B1_XCODARV := ""
	LOCAL B1_CODGTIN := ""
	LOCAL B1_ALTER   := ""
	LOCAL B1_FANTASM := ""
	LOCAL B1_CODISS  := ""
	Local CSOLIC	 := ""
	Local CMAIL		 := ""

	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:= cValtoChar(oObj:cdempresa)
		cdfilial 	:= cValtoChar(oObj:cdfilial) 
		B1_COD 		:= cValtoChar(oObj:B1_COD)
		B1_XLOCAL 	:= cValtoChar(oObj:B1_XLOCAL) 
		B1_XTIPO 	:= cValtoChar(oObj:B1_XTIPO) 
		B1_TIPO 	:= cValtoChar(oObj:B1_TIPO) 
		B1_GRUPO 	:= cValtoChar(oObj:B1_GRUPO) 
		B1_DESC 	:= cValtoChar(oObj:B1_DESC) 
		B1_UM 		:= cValtoChar(oObj:B1_UM) 
		B1_SEGUM 	:= cValtoChar(oObj:B1_SEGUM) 
		B1_CONV 	:= cValtoChar(oObj:B1_CONV) 
		B1_TIPCON 	:= cValtoChar(oObj:B1_TIPCON) 
		B1_APROPRI 	:= cValtoChar(oObj:B1_APROPRI) 
		B1_XCLAS 	:= cValtoChar(oObj:B1_XCLAS) 
		B1_LOCPAD 	:= cValtoChar(oObj:B1_LOCPAD) 
		B1_LOCALIZ 	:= cValtoChar(oObj:B1_LOCALIZ) 
		B1_RASTRO 	:= cValtoChar(oObj:B1_RASTRO) 
		B1_POSIPI 	:= cValtoChar(oObj:B1_POSIPI) 
		B1_ORIGEM 	:= cValtoChar(oObj:B1_ORIGEM) 
		B1_GRUPCOM 	:= cValtoChar(oObj:B1_GRUPCOM) 
		B1_MCUSTD 	:= cValtoChar(oObj:B1_MCUSTD) 
		B1_XN1 		:= cValtoChar(oObj:B1_XN1) 
		B1_XN2 		:= cValtoChar(oObj:B1_XN2) 
		B1_XN3 		:= cValtoChar(oObj:B1_XN3) 
		B1_XN4 		:= cValtoChar(oObj:B1_XN4) 
		B1_IPI 		:= cValtoChar(oObj:B1_IPI) 
		B1_GRTRIB 	:= cValtoChar(oObj:B1_GRTRIB) 
		B1_IRRF 	:= cValtoChar(oObj:B1_IRRF) 
		B1_INSS 	:= cValtoChar(oObj:B1_INSS) 
		B1_REDPIS 	:= cValtoChar(oObj:B1_REDPIS) 
		B1_REDCOF 	:= cValtoChar(oObj:B1_REDCOF) 
		B1_PPIS 	:= cValtoChar(oObj:B1_PPIS) 
		B1_PCOFINS 	:= cValtoChar(oObj:B1_PCOFINS) 
		B1_CSLL 	:= cValtoChar(oObj:B1_CSLL) 
		B1_PCSLL 	:= cValtoChar(oObj:B1_PCSLL) 
		B1_CEST 	:= cValtoChar(oObj:B1_CEST) 
		B1_CONTA 	:= cValtoChar(oObj:B1_CONTA) 
		B1_CTAREC 	:= cValtoChar(oObj:B1_CTAREC) 
		B1_CTADESP 	:= cValtoChar(oObj:B1_CTADESP) 
		B1_CTACUST 	:= cValtoChar(oObj:B1_CTACUST) 
		B1_CTATRAN 	:= cValtoChar(oObj:B1_CTATRAN) 
		B1_EMIN 	:= cValtoChar(oObj:B1_EMIN) 
		B1_XDIAES 	:= cValtoChar(oObj:B1_XDIAES) 
		B1_ESTSEG 	:= cValtoChar(oObj:B1_ESTSEG) 
		B1_PE 		:= cValtoChar(oObj:B1_PE) 
		B1_MRP 		:= cValtoChar(oObj:B1_MRP) 
		B1_EMAX 	:= cValtoChar(oObj:B1_EMAX) 
		B1_PRVALID 	:= cValtoChar(oObj:B1_PRVALID) 
		B1_TIPOCQ 	:= cValtoChar(oObj:B1_TIPOCQ) 
		B1_NUMCQPR 	:= cValtoChar(oObj:B1_NUMCQPR)
		B1_MSBLQL 	:= cValtoChar(oObj:B1_MSBLQL)
		B1_TIPCAR  := cValtoChar(oObj:B1_TIPCAR)
		B1_XCODEXT := cValtoChar(oObj:B1_XCODEXT)
		B1_CATMAPA := cValtoChar(oObj:B1_CATMAPA)
		B1_PACAMAP := cValtoChar(oObj:B1_PACAMAP)
		B1_CRECMAP := cValtoChar(oObj:B1_CRECMAP)
		B1_PRECMAP := cValtoChar(oObj:B1_PRECMAP)
		B1_PESOMAP := cValtoChar(oObj:B1_PESOMAP)
		B1_XLACTOS := cValtoChar(oObj:B1_XLACTOS)
		B1_XPADMAP := cValtoChar(oObj:B1_XPADMAP)
		B1_XALERG  := cValtoChar(oObj:B1_XALERG)
		B1_XCODARV := cValtoChar(oObj:B1_XCODARV)
		B1_CODGTIN := cValtoChar(oObj:B1_CODGTIN)
		B1_ALTER   := cValtoChar(oObj:B1_ALTER)
		B1_FANTASM := cValtoChar(oObj:B1_FANTASM)
		B1_CODISS  := cValtoChar(oObj:B1_CODISS)
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		CMAIL		:= cValtoChar(oObj:CMAIL)

		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			If Empty(Alltrim(B1_COD)) 
				B1_COD := GetNomePrd(cdempresa, cdfilial, B1_XLOCAL, B1_XTIPO, B1_XCLAS, B1_GRUPO)
			EndIf
			aVetor:= { {"B1_FILIAL" 	,cdfilial 		,.T.},;
			{"B1_XLOCAL" 	,B1_XLOCAL 		,.T.},;
			{"B1_COD" 		,B1_COD 		,.T.},;
			{"B1_XTIPO"		,B1_XTIPO		,.T.},;
			{"B1_TIPO"		,B1_TIPO		,.T.},;
			{"B1_GRUPO"		,B1_GRUPO		,.T.},;
			{"B1_DESC"		,B1_DESC		,.T.},;
			{"B1_UM"		,B1_UM			,.T.},;
			{"B1_SEGUM"		,B1_SEGUM		,.T.},;
			{"B1_CONV"	   	,VAL(B1_CONV)	,.T.},;
			{"B1_APROPRI"	,B1_APROPRI		,.T.},;
			{"B1_XCLAS"		,B1_XCLAS		,.T.},;
			{"B1_LOCPAD"	,B1_LOCPAD		,.T.},;
			{"B1_LOCALIZ"	,B1_LOCALIZ 	,.T.},;
			{"B1_RASTRO"	,B1_RASTRO 		,.T.},;
			{"B1_POSIPI"	,B1_POSIPI 		,.T.},;
			{"B1_ORIGEM"	,B1_ORIGEM 		,.T.},;
			{"B1_GRUPCOM"	,B1_GRUPCOM 	,.T.},;
			{"B1_MCUSTD"	,B1_MCUSTD 		,.T.},;
			{"B1_XN1"		,B1_XN1 		,.T.},;
			{"B1_XN2"		,B1_XN2 		,.T.},;
			{"B1_XN3"		,B1_XN3 		,.T.},;
			{"B1_XN4"		,B1_XN4 		,.T.},;
			{"B1_IPI"		,VAL(B1_IPI)	,.T.},;
			{"B1_GRTRIB"	,B1_GRTRIB 		,.T.},;
			{"B1_IRRF"		,B1_IRRF 		,.T.},;
			{"B1_INSS"		,B1_INSS 		,.T.},;
			{"B1_REDPIS"	,VAL(B1_REDPIS)	,.T.},;
			{"B1_REDCOF"	,VAL(B1_REDCOF)	,.T.},;
			{"B1_PPIS"		,VAL(B1_PPIS)	,.T.},;
			{"B1_PCOFINS"	,VAL(B1_PCOFINS),.T.},;
			{"B1_CSLL"		,B1_CSLL 		,.T.},;
			{"B1_PCSLL"		,VAL(B1_PCSLL) 	,.T.},;
			{"B1_CEST"		,B1_CEST 		,.T.},;
			{"B1_CONTA"		,B1_CONTA 		,.T.},;
			{"B1_CTAREC"	,B1_CTAREC 		,.T.},;
			{"B1_CTADESP"	,B1_CTADESP 	,.T.},;
			{"B1_CTACUST"	,B1_CTACUST 	,.T.},;
			{"B1_CTATRAN"	,B1_CTATRAN 	,.T.},;
			{"B1_EMIN"		,VAL(B1_EMIN)	,.T.},;
			{"B1_XDIAES"	,VAL(B1_XDIAES)	,.T.},;
			{"B1_ESTSEG"	,VAL(B1_ESTSEG)	,.T.},;
			{"B1_PE"		,VAL(B1_PE)		,.T.},;
			{"B1_MRP"		,B1_MRP 		,.T.},;
			{"B1_EMAX"		,VAL(B1_EMAX) 	,.T.},;
			{"B1_PRVALID"	,VAL(B1_PRVALID),.T.},;
			{"B1_TIPOCQ"	,B1_TIPOCQ 		,.T.},;
			{"B1_NUMCQPR"	,VAL(B1_NUMCQPR),.T.},;
			{"B1_MSBLQL"	,B1_MSBLQL		,.T.},;
			{"B1_TIPCAR"	,B1_TIPCAR		,.T.},;
			{"B1_XCODEXT"	,B1_XCODEXT		,.T.},;
			{"B1_CATMAPA"	,B1_CATMAPA		,.T.},;
			{"B1_PACAMAP"	,B1_PACAMAP		,.T.},;
			{"B1_CRECMAP"	,B1_CRECMAP		,.T.},;
			{"B1_PRECMAP"	,B1_PRECMAP		,.T.},;
			{"B1_PESOMAP"	,VAL(B1_PESOMAP),.T.},;
			{"B1_XLACTOS"	,B1_XLACTOS		,.T.},;
			{"B1_XPADMAP"	,B1_XPADMAP		,.T.},;
			{"B1_XALERG"	,B1_XALERG		,.T.},;
			{"B1_XCODARV"	,B1_XCODARV		,.T.},;
			{"B1_CODGTIN"	,B1_CODGTIN		,.T.},;
			{"B1_ALTER"		,B1_ALTER		,.T.},;
			{"B1_FANTASM"	,B1_FANTASM		,.T.},;
			{"B1_CODISS"	,B1_CODISS		,.T.},;
			{"B1_XUSER"		,CMAIL,.T.}} 


			cResponse := WSFLUIG015(cdempresa, cdfilial, 1, aVetor, B1_COD)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSProdutoFLuig
@author Paulo Gabriel F.Silva
@since 09/08/2018
@version 1.0
/*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE WSProdutoFluig

	Local cResponse	:= ""
	Local idproduto := ""
	Local cBody
	Local oObj
	Local cdempresa := ""
	Local cdfilial 
	Local aVetor	:= {}
	Local cGerar	:= .F.
	Local B1_XLOCAL := ""
	Local B1_XTIPO  := ""
	Local B1_TIPO   := ""
	Local B1_GRUPO  := ""
	Local B1_DESC   := ""
	Local B1_UM     := ""
	Local B1_SEGUM  := ""
	Local B1_CONV   := ""
	Local B1_TIPCON := ""
	Local B1_APROPRI := ""
	Local B1_XCLAS  := ""
	Local B1_LOCPAD := ""
	Local B1_LOCALIZ := ""
	Local B1_RASTRO := ""
	Local B1_POSIPI := ""
	Local B1_ORIGEM := ""
	Local B1_GRUPCOM := ""
	Local B1_MCUSTD := ""
	Local B1_XN1    := ""
	Local B1_XN2    := ""
	Local B1_XN3    := ""
	Local B1_XN4    := ""
	Local B1_IPI    := ""
	Local B1_GRTRIB := ""
	Local B1_IRRF   := ""
	Local B1_INSS   := ""
	Local B1_REDPIS := ""
	Local B1_REDCOF := ""
	Local B1_PPIS   := ""
	Local B1_PCOFINS := ""
	Local B1_CSLL   := ""
	Local B1_PCSLL  := ""
	Local B1_CEST   := ""
	Local B1_CONTA  := ""
	Local B1_CTAREC := ""
	Local B1_CTADESP := ""
	Local B1_CTACUST := ""
	Local B1_CTATRAN := ""
	Local B1_EMIN   := ""
	Local B1_XDIAES := ""
	Local B1_ESTSEG := ""
	Local B1_PE     := ""
	Local B1_MRP    := ""
	Local B1_EMAX   := ""
	Local B1_PRVALID := ""
	Local B1_TIPOCQ := ""
	Local B1_NUMCQPR := ""
	Local B1_COD	:=	""
	Local B1_MSBLQL	:=	""
	LOCAL B1_TIPCAR  := ""
	LOCAL B1_XCODEXT := ""
	LOCAL B1_CATMAPA := ""
	LOCAL B1_PACAMAP := ""
	LOCAL B1_CRECMAP := ""
	LOCAL B1_PRECMAP := ""
	LOCAL B1_PESOMAP := ""
	LOCAL B1_XLACTOS := ""
	LOCAL B1_XPADMAP := ""
	LOCAL B1_XALERG  := ""
	LOCAL B1_XCODARV := ""
	LOCAL B1_CODGTIN := ""
	LOCAL B1_ALTER   := ""
	LOCAL B1_FANTASM := ""
	LOCAL B1_CODISS  := ""
	Local CSOLIC	 := ""
	Local CMAIL	 	 := ""


	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:= cValtoChar(oObj:cdempresa)
		cdfilial 	:= cValtoChar(oObj:cdfilial) 
		B1_COD 		:= cValtoChar(oObj:B1_COD)
		B1_XLOCAL 	:= cValtoChar(oObj:B1_XLOCAL) 
		B1_XTIPO 	:= cValtoChar(oObj:B1_XTIPO) 
		B1_TIPO 	:= cValtoChar(oObj:B1_TIPO) 
		B1_GRUPO 	:= cValtoChar(oObj:B1_GRUPO) 
		B1_DESC 	:= cValtoChar(oObj:B1_DESC) 
		B1_UM 		:= cValtoChar(oObj:B1_UM) 
		B1_SEGUM 	:= cValtoChar(oObj:B1_SEGUM) 
		B1_CONV 	:= cValtoChar(oObj:B1_CONV) 
		B1_TIPCON 	:= cValtoChar(oObj:B1_TIPCON) 
		B1_APROPRI 	:= cValtoChar(oObj:B1_APROPRI) 
		B1_XCLAS 	:= cValtoChar(oObj:B1_XCLAS) 
		B1_LOCPAD 	:= cValtoChar(oObj:B1_LOCPAD) 
		B1_LOCALIZ 	:= cValtoChar(oObj:B1_LOCALIZ)
		B1_RASTRO 	:= cValtoChar(oObj:B1_RASTRO) 
		B1_POSIPI 	:= cValtoChar(oObj:B1_POSIPI) 
		B1_ORIGEM 	:= cValtoChar(oObj:B1_ORIGEM) 
		B1_GRUPCOM 	:= cValtoChar(oObj:B1_GRUPCOM) 
		B1_MCUSTD 	:= cValtoChar(oObj:B1_MCUSTD) 
		B1_XN1 		:= cValtoChar(oObj:B1_XN1) 
		B1_XN2 		:= cValtoChar(oObj:B1_XN2) 
		B1_XN3 		:= cValtoChar(oObj:B1_XN3) 
		B1_XN4 		:= cValtoChar(oObj:B1_XN4) 
		B1_IPI 		:= cValtoChar(oObj:B1_IPI) 
		B1_GRTRIB 	:= cValtoChar(oObj:B1_GRTRIB) 
		B1_IRRF 	:= cValtoChar(oObj:B1_IRRF) 
		B1_INSS 	:= cValtoChar(oObj:B1_INSS) 
		B1_REDPIS 	:= cValtoChar(oObj:B1_REDPIS) 
		B1_REDCOF 	:= cValtoChar(oObj:B1_REDCOF) 
		B1_PPIS 	:= cValtoChar(oObj:B1_PPIS) 
		B1_PCOFINS 	:= cValtoChar(oObj:B1_PCOFINS) 
		B1_CSLL 	:= cValtoChar(oObj:B1_CSLL) 
		B1_PCSLL 	:= cValtoChar(oObj:B1_PCSLL) 
		B1_CEST 	:= cValtoChar(oObj:B1_CEST) 
		B1_CONTA 	:= cValtoChar(oObj:B1_CONTA) 
		B1_CTAREC 	:= cValtoChar(oObj:B1_CTAREC) 
		B1_CTADESP 	:= cValtoChar(oObj:B1_CTADESP) 
		B1_CTACUST 	:= cValtoChar(oObj:B1_CTACUST) 
		B1_CTATRAN 	:= cValtoChar(oObj:B1_CTATRAN) 
		B1_EMIN 	:= cValtoChar(oObj:B1_EMIN) 
		B1_XDIAES 	:= cValtoChar(oObj:B1_XDIAES) 
		B1_ESTSEG 	:= cValtoChar(oObj:B1_ESTSEG) 
		B1_PE 		:= cValtoChar(oObj:B1_PE) 
		B1_MRP 		:= cValtoChar(oObj:B1_MRP) 
		B1_EMAX 	:= cValtoChar(oObj:B1_EMAX) 
		B1_PRVALID 	:= cValtoChar(oObj:B1_PRVALID) 
		B1_TIPOCQ 	:= cValtoChar(oObj:B1_TIPOCQ) 
		B1_NUMCQPR 	:= cValtoChar(oObj:B1_NUMCQPR)
		B1_MSBLQL 	:= cValtoChar(oObj:B1_MSBLQL)
		B1_TIPCAR  := cValtoChar(oObj:B1_TIPCAR)
		B1_XCODEXT := cValtoChar(oObj:B1_XCODEXT)
		B1_CATMAPA := cValtoChar(oObj:B1_CATMAPA)
		B1_PACAMAP := cValtoChar(oObj:B1_PACAMAP)
		B1_CRECMAP := cValtoChar(oObj:B1_CRECMAP)
		B1_PRECMAP := cValtoChar(oObj:B1_PRECMAP)
		B1_PESOMAP := cValtoChar(oObj:B1_PESOMAP)
		B1_XLACTOS := cValtoChar(oObj:B1_XLACTOS)
		B1_XPADMAP := cValtoChar(oObj:B1_XPADMAP)
		B1_XALERG  := cValtoChar(oObj:B1_XALERG)
		B1_XCODARV := cValtoChar(oObj:B1_XCODARV)
		B1_CODGTIN := cValtoChar(oObj:B1_CODGTIN)
		B1_ALTER   := cValtoChar(oObj:B1_ALTER)
		B1_FANTASM := cValtoChar(oObj:B1_FANTASM)
		B1_CODISS  := cValtoChar(oObj:B1_CODISS)
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		CMAIL		:= cValtoChar(oObj:CMAIL)

		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			aVetor:= { {"B1_COD" 		,B1_COD 		,.T.},;
			{"B1_FILIAL" 	,cdfilial 		,.T.},;
			{"B1_XLOCAL" 	,B1_XLOCAL 		,.T.},;
			{"B1_XTIPO"		,B1_XTIPO		,.T.},;
			{"B1_TIPO"		,B1_TIPO		,.T.},;
			{"B1_GRUPO"		,B1_GRUPO		,.T.},;
			{"B1_DESC"		,B1_DESC		,.T.},;
			{"B1_UM"		,B1_UM			,.T.},;
			{"B1_SEGUM"		,B1_SEGUM		,.T.},;
			{"B1_CONV"	   	,VAL(B1_CONV)	,.T.},;
			{"B1_APROPRI"	,B1_APROPRI		,.T.},;
			{"B1_XCLAS"		,B1_XCLAS		,.T.},;
			{"B1_LOCPAD"	,B1_LOCPAD		,.T.},;
			{"B1_LOCALIZ"	,B1_LOCALIZ 	,.T.},;
			{"B1_RASTRO"	,B1_RASTRO 		,.T.},;
			{"B1_POSIPI"	,B1_POSIPI 		,.T.},;
			{"B1_ORIGEM"	,B1_ORIGEM 		,.T.},;
			{"B1_GRUPCOM"	,B1_GRUPCOM 	,.T.},;
			{"B1_MCUSTD"	,B1_MCUSTD 		,.T.},;
			{"B1_XN1"		,B1_XN1 		,.T.},;
			{"B1_XN2"		,B1_XN2 		,.T.},;
			{"B1_XN3"		,B1_XN3 		,.T.},;
			{"B1_XN4"		,B1_XN4 		,.T.},;
			{"B1_IPI"		,VAL(B1_IPI)	,.T.},;
			{"B1_GRTRIB"	,B1_GRTRIB 		,.T.},;
			{"B1_IRRF"		,B1_IRRF 		,.T.},;
			{"B1_INSS"		,B1_INSS 		,.T.},;
			{"B1_REDPIS"	,VAL(B1_REDPIS)	,.T.},;
			{"B1_REDCOF"	,VAL(B1_REDCOF)	,.T.},;
			{"B1_PPIS"		,VAL(B1_PPIS)	,.T.},;
			{"B1_PCOFINS"	,VAL(B1_PCOFINS),.T.},;
			{"B1_CSLL"		,B1_CSLL 		,.T.},;
			{"B1_PCSLL"		,VAL(B1_PCSLL) 	,.T.},;
			{"B1_CEST"		,B1_CEST 		,.T.},;
			{"B1_CONTA"		,B1_CONTA 		,.T.},;
			{"B1_CTAREC"	,B1_CTAREC 		,.T.},;
			{"B1_CTADESP"	,B1_CTADESP 	,.T.},;
			{"B1_CTACUST"	,B1_CTACUST 	,.T.},;
			{"B1_CTATRAN"	,B1_CTATRAN 	,.T.},;
			{"B1_EMIN"		,VAL(B1_EMIN)	,.T.},;
			{"B1_XDIAES"	,VAL(B1_XDIAES)	,.T.},;
			{"B1_ESTSEG"	,VAL(B1_ESTSEG)	,.T.},;
			{"B1_PE"		,VAL(B1_PE)		,.T.},;
			{"B1_MRP"		,B1_MRP 		,.T.},;
			{"B1_EMAX"		,VAL(B1_EMAX) 	,.T.},;
			{"B1_PRVALID"	,VAL(B1_PRVALID),.T.},;
			{"B1_TIPOCQ"	,B1_TIPOCQ 		,.T.},;
			{"B1_NUMCQPR"	,VAL(B1_NUMCQPR),.T.},;
			{"B1_MSBLQL"	,B1_MSBLQL		,.T.},;
			{"B1_TIPCAR"	,B1_TIPCAR		,.T.},;
			{"B1_XCODEXT"	,B1_XCODEXT		,.T.},;
			{"B1_CATMAPA"	,B1_CATMAPA		,.T.},;
			{"B1_PACAMAP"	,B1_PACAMAP		,.T.},;
			{"B1_CRECMAP"	,B1_CRECMAP		,.T.},;
			{"B1_PRECMAP"	,B1_PRECMAP		,.T.},;
			{"B1_PESOMAP"	,VAL(B1_PESOMAP),.T.},;
			{"B1_XLACTOS"	,B1_XLACTOS		,.T.},;
			{"B1_XPADMAP"	,B1_XPADMAP		,.T.},;
			{"B1_XALERG"	,B1_XALERG		,.T.},;
			{"B1_XCODARV"	,B1_XCODARV		,.T.},;
			{"B1_CODGTIN"	,B1_CODGTIN		,.T.},;
			{"B1_ALTER"		,B1_ALTER		,.T.},;
			{"B1_FANTASM"	,B1_FANTASM		,.T.},;
			{"B1_CODISS"	,B1_CODISS		,.T.},;
			{"B1_XUSER"		,CMAIL,.T.}} 


			cResponse := WSFLUIG015(cdempresa, cdfilial, 2, aVetor, B1_COD)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.



Static Function WSFLUIG015(cdempresa, cdfilial, cOper, aVetor, cCodPrd)
	Local cJson := ""
	Local nPos := 1
	Local aReturn := {}
	Local Filial := ""
	Local SM0_aux := ""
	Local lCont := .T.
	Local cQuery := ""
	Local cAlQry	:= ""
	Local lRet	:= .F.

	aReturn := U_WSFLUIG016( aVetor, cOper, cdempresa, cdfilial )

	If aReturn[1]
		cJson := '{"B1_COD":"'+ cCodPrd +'"}'
	Else
		cJson := '{'+CRLF
		cJson += '"erro": true,'+CRLF
		cJson += '"message":'
		cJson += '"' + U_FTEXECAUTO(EncodeUTF8(cvaltochar(aReturn[2]))) + '"'
		cJson += '}'
	EndIf
Return cJson

Static Function GetNomePrd(cEmp, cFil, cxLocal, cxTipo, cxClass, cGrupo)
	Local cName 	:= ""
	Local cAux		:= ""
	Local cQuery 	:= ""
	Local cAlQry	:= ""

	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	cNumEmp := cEmpAnt+cFilAnt
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)

	cQuery := "	SELECT MAX(B1_COD) B1_COD  " + CRLF
	cQuery += "	FROM " + RetSqlName("SB1") + CRLF
	cQuery += "	WHERE  " + CRLF
	cQuery += "	    	B1_FILIAL = '"+ cFilAnt +"'  " + CRLF
	cQuery += "	    AND B1_XLOCAL = '"+ cxLocal +"'  " + CRLF
	cQuery += "	    AND B1_XTIPO  = '"+ cxTipo 	+"'  " + CRLF
	cQuery += "	    AND B1_XCLAS  = '"+ cxClass +"'  " + CRLF
	cQuery += "	    AND B1_GRUPO  = '"+ cGrupo  +"'  " + CRLF
	cQuery += "		AND D_E_L_E_T_ = ' ' 			 " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)

	If (cAlQry)->(Eof())
		cName := cxLocal + cxTipo + cxClass + cGrupo + "000100"
	Else
		cAux  := VAL(SUBSTR((cAlQry)->B1_COD, 9, 4))
		cName := cxLocal + cxTipo + cxClass + cGrupo + STRZERO(cAux + 1,4) + "00"
	EndIf

Return cName

User Function FTEXECAUTO(cErro)
	Local cErroAtual := cErro
	Local cErraTrat := ""
	Local cIniString := "Mensagem do erro:"
	Local cFimString := "Id do campo de erro:"
	Local aArray := {}
	Local nX     := 0


	aArray := StrToKarr( cErroAtual , Chr(13) + Chr(10))

	cErraTrat := aArray[AScan( aArray,cFimString)]
	cErraTrat += " "
	For nX:= AScan( aArray, cIniString) to  AScan( aArray, "Id do formulario de erro:",AScan( aArray, cIniString)) -1
		cErraTrat += aArray[nX]
	Next
	cErraTrat:=StrTran( cErraTrat, "-", "" )
	cErraTrat:=StrTran( cErraTrat, Chr(13) + Chr(10), "" )
	cErraTrat:=StrTran( cErraTrat, '"', "'" )

Return cErraTrat