#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| FISCAL                                                                                                                                 |
| Gravação de dados do arquivo XML Ct-e para as tabelas ZC1 e ZC2                                                                        |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 24.05.2018                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
//11.07.2018
user function IMPCTE()

	local nFrete := 0
	LOCAL nFreteP := 0
	Local nOutros := 0
	local nPedagio := 0
	Local nTAS := 0
	Local nEmex := 0
	Local nGRIS := 0
	local nDESPACHO :=0 
	Local nREPASSADO :=0
	local nTRT := 0
	local cTpDados := ""
	Local cTpdado2 := ""
	Local lRet := .f.
	Local nValIcms := 0

	Local cTPCTE := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TPCTE:text
	Local cDescTp := ''
	Local lCompl := .f.
	Local cQry

	If cTPCTE ='0'
		cDescTp := 'CT-e Normal'
	ElseIf cTPCTE ='1'
		cDescTp := 'CT-e Complemento'
	ElseIf cTPCTE ='2'
		cDescTp := 'CT-e Anulacao'
	EndIf

	cTpdado2 := valtype(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP)

	if cTpdado2 == "A"
		FOR nZ := 1 to  len(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP)

			//EM 20/05/2019 [AKIRA]
			//ALTEADO DE IF PARA ELSEIF

			if oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "FRETE VALOR"
				nFrete :=  VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "FRETE PESO"
				nFreteP:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)	
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "PEDAGIO"
				nPedagio:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "GRIS"
				nGRIS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "EMEX"
				nEmex:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "TAS"
				nTAS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)	
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "DESPACHO"
				nDESPACHO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)		
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "TRT"
				nTRT:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nZ]:_XNOME:TEXT = "IMP REPASSADO"
				nREPASSADO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)

			Else
				nOutros:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP[nz]:_VCOMP:TEXT)
			endif

		next nZ
	ELSE

		if oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "FRETE VALOR"
			nFrete :=  VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "FRETE PESO"
			nFreteP:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "PEDAGIO"
			nPedagio:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "GRIS"
			nGRIS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "EMEX"
			nEmex:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "TAS"
			nTAS:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "DESPACHO"
			nDESPACHO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "TRT"
			nTRT:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)	
		Elseif oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT = "IMP REPASSADO"
			nREPASSADO:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		Else
			nOutros:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_VCOMP:TEXT)
		endif	
	ENDIF

	//EM 20/05/2019
	//tag imp (icms)
	If type('oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT') <> 'U'
		nValIcms := VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
	EndIf
	//ATE AQUI - 20/05/2019

	dbSelectArea('ZC1')
	DBSetOrder(1)
	If !DbSeek( xFilial("ZC1") + cChaveNf)
		lRet:= .t.
		RecLock("ZC1",.T.)
		ZC1_FILIAL := xFilial("ZC1")
		ZC1_DTLANC := DDATABASE
		ZC1_DTEMIS := ctod(SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,9,2)+"/"+SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,6,2)+"/"+SUBSTRING(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT,1,4))
		ZC1_FORNEC := POSICIONE('SA2',3,xfilial('SA2')+OXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,'A2_COD')
		ZC1_LOJFOR := POSICIONE('SA2',3,xfilial('SA2')+OXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,'A2_LOJA')
		ZC1_CTE    := cChaveNf

		IF TYPE("OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT")=="C"
			ZC1_CODCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,'A1_COD')
			ZC1_LOJCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT,'A1_LOJA')
		ELSE
			ZC1_CODCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT,'A1_COD')
			ZC1_LOJCLI := POSICIONE('SA1',3,xfilial('SA1')+OXML:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT,'A1_LOJA')
		ENDIF

		ZC1_VLSERV := VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
		ZC1_FRETE  := nFrete+nFreteP
		ZC1_PEDAGI := nPedagio
		ZC1_OUTROS := nDESPACHO+nTRT+nOutros
		ZC1_TAS    := nTas
		ZC1_GRIS   := nGRIS
		ZC1_EMEX   := nEMEX
		ZC1_VALICM := nValIcms
		//em 28/05/2019
		ZC1_MUN_I := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_xMunIni:text
		ZC1_UF_I  := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFIni:text
		ZC1_MUN_F := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_xMunFim:text
		ZC1_UF_F  := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFim:text

		//em 15/07/2019
		ZC1_TPCTE  := cTpCte
		ZC1_DESCTP := cDescTp
		If cTpCte = '1' //nota complementar
			cChvOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT
			lCompl := ValNFComp(cChvOri)
			//A = Ativo; B = Bloqueado 
			//se não encontrou CTE "original" fica bloqueado
			ZC1_STATUS := If(lCompl,"A","B")
		Else
			ZC1_STATUS := 'A' //ativo
		EndIf

		MsUnLock()
		//EndIf
		//Valida se o arquivo tem mais de uma nota fiscal.
		//NORMAL
		If type('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE') <>'U'
			cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE) 

			if cTpDados == "A" //Array

				FOR nX := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)  

					dbSelectArea('ZC2')
					DBSetOrder(1)	//ZC2_FILIAL+ZC2_CHAVE+ZC2_CTE
					//em 28/05/2019 
					//If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT)
					If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT+cChaveNf)
						RecLock("ZC2",.T.)
						ZC2_FILIAL := xFilial("ZC2")
						ZC2_CTE    := cChaveNf
						ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT
						ZC2_SEQUEN := cValToChar(nX)
						ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[NX]:_CHAVE:TEXT,26,9)
						ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT,23,3)
						MsUnLock()
					endif
				next

			else  // Indetificado que o tipo de dados é "O" Objeto 	

				dbSelectArea('ZC2')
				DBSetOrder(1)
				//em 28/05/2019
				//If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT)
				If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT+cChaveNf)
					RecLock("ZC2",.T.)
					ZC2_FILIAL := xFilial("ZC2")
					ZC2_CTE    := cChaveNf
					ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
					ZC2_SEQUEN := "1"
					ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,26,9)
					ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,3)
					MsUnLock()
				endif
			endif
		EndIf


		/*  EM 07/08/2020
		//COMPLEMENTO
		If type('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE') <>'U'
		cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE) 
		if cTpDados == "A" //Array
		FOR nX := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)  

		dbSelectArea('ZC2')
		DBSetOrder(1)	//ZC2_FILIAL+ZC2_CHAVE+ZC2_CTE
		//em 28/05/2019 
		//If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT)
		If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT+cChaveNf)
		RecLock("ZC2",.T.)
		ZC2_FILIAL := xFilial("ZC2")
		ZC2_CTE    := cChaveNf
		ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT
		ZC2_SEQUEN := cValToChar(nX)
		ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[NX]:_CHAVE:TEXT,26,9)
		ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT,23,3)
		MsUnLock()
		endif
		next

		else  // Indetificado que o tipo de dados é "O" Objeto 	

		dbSelectArea('ZC2')
		DBSetOrder(1)
		//em 28/05/2019
		//If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT)
		If !DbSeek( xFilial("ZC2") + oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT+cChaveNf)
		RecLock("ZC2",.T.)
		ZC2_FILIAL := xFilial("ZC2")
		ZC2_CTE    := cChaveNf
		ZC2_CHAVE  := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
		ZC2_SEQUEN := "1"
		ZC2_NUMNFE := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,26,9)
		ZC2_SERIE  := SUBSTRING(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT,23,3)
		MsUnLock()
		endif
		endif
		EndIf
		*/
		//COMPLEMENTO
		If type('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP') <>'U'
			cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP) 
			if cTpDados == "A" //Array
				FOR nX := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP)  
					cQry:=" select * from "+RETSQLNAME('ZC2')+""
					cQry+=" WHERE ZC2_CTE = '"+oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP[nx]:_CHCTE:TEXT+"'"
					cQry+=" AND D_E_L_E_T_<>'*'
					IF Select('TRZC2')<>0
						TRZC2->(DBCloseArea())
					EndIF
					TcQuery  cQry New Alias "TRZC2"
					RecLock("ZC2",.T.)
					ZC2->ZC2_FILIAL := xFilial("ZC2")
					ZC2->ZC2_CTE    := cChaveNf
					ZC2->ZC2_CHAVE  := TRZC2->ZC2_CHAVE 
					ZC2->ZC2_SEQUEN := TRZC2->ZC2_SEQUEN 
					ZC2->ZC2_NUMNFE := TRZC2->ZC2_NUMNFE 
					ZC2->ZC2_SERIE  := TRZC2->ZC2_SERIE 
					MsUnLock()
				next

			else 	
				cQry:=" select * from "+RETSQLNAME('ZC2')+""
				cQry+=" WHERE ZC2_CTE = '"+oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT+"'"
				cQry+=" AND D_E_L_E_T_<>'*'
				IF Select('TRZC2')<>0
					TRZC2->(DBCloseArea())
				EndIF
				TcQuery  cQry New Alias "TRZC2"
				RecLock("ZC2",.T.)
				ZC2->ZC2_FILIAL := xFilial("ZC2")
				ZC2->ZC2_CTE    := cChaveNf
				ZC2->ZC2_CHAVE  := TRZC2->ZC2_CHAVE 
				ZC2->ZC2_SEQUEN := TRZC2->ZC2_SEQUEN 
				ZC2->ZC2_NUMNFE := TRZC2->ZC2_NUMNFE 
				ZC2->ZC2_SERIE  := TRZC2->ZC2_SERIE 
				MsUnLock()
			endif
		endif
	EndIf

	//18.03.2019 -- Irá popular tabela ZC3 conforme a TAG  <infCarga>
	If TYPE('oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ') <>'U'
		cTpDados := ValType(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ) 
		if cTpDados == "A" //Array

			FOR nT := 1 to LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ)  
				ctpMed := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_tpMed:TEXT
				dbSelectArea('ZC3')
				DBSetOrder(1)
				If !DbSeek( xFilial("ZC3") + cChaveNf+ctpMed)
					RecLock("ZC3",.T.)
					lRet:= .t.
				Else
					RecLock("ZC3",.F.)
					lRet:= .t.
				endif
				ZC3_FILIAL 	:= xFilial("ZC3")
				ZC3_CTE 	:=  cChaveNf
				ZC3_UNIDAD 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_cUnid:TEXT
				ZC3_TPMED 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_tpMed:TEXT
				ZC3_QCARGA 	:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ[nT]:_qCarga:TEXT)
				MsUnLock()
			next nT
		Else
			ctpMed := oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_tpMed:TEXT
			dbSelectArea('ZC3')
			DBSetOrder(1)
			If !DbSeek( xFilial("ZC3") + cChaveNf+ctpMed)
				RecLock("ZC3",.T.)
				lRet:= .t.
			Else
				RecLock("ZC3",.F.)
				lRet:= .t.
			endif
			ZC3_FILIAL 	:= xFilial("ZC3")
			ZC3_CTE 	:=  cChaveNf
			ZC3_UNIDAD 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_cUnid:TEXT
			ZC3_TPMED 	:= oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_tpMed:TEXT
			ZC3_QCARGA 	:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_infCTeNorm:_infCarga:_infQ:_qCarga:TEXT)
			MsUnLock()		

		EndIf
	EndIf
	//FIM -- 18.03.2019

	//EM 07/08/2020
	//complemento
	If cTPCTE ='1'

		cQry:=" select * from "+RETSQLNAME('ZC3')+""
		cQry+=" WHERE ZC3_CTE = '"+oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT+"'"
		cQry+=" AND D_E_L_E_T_<>'*'
		IF Select('TRZC3')<>0
			TRZC3->(DBCloseArea())
		EndIF
		TcQuery  cQry New Alias "TRZC3"
		
		While !TRZC3->(eof())
			RecLock("ZC3",.T.)
			ZC3->ZC3_FILIAL := xFilial("ZC3")
			ZC3->ZC3_CTE 	:= cChaveNf
			ZC3->ZC3_UNIDAD := TRZC3->ZC3_UNIDAD
			ZC3->ZC3_TPMED 	:= TRZC3->ZC3_TPMED
			ZC3->ZC3_QCARGA := TRZC3->ZC3_QCARGA
			MsUnLock()
			TRZC3->(DbSkip())		
		End
		
	EndIf

	if lRet = .f.
		msgstop("Arquivo CTE já importado para a chave: "+ cChaveNf)
		return
	endif
return



Static Function ValNFComp(cChave)
	Local lRet := .F.
	Local cSql := ""

	cSql:=" SELECT * "
	cSql+=" FROM "+RetSqlName('SF1') + " SF1  "
	cSql+=" WHERE F1_CHVNFE ='"+cChave+"'"
	cSql+=" AND SF1.D_E_L_E_T_<>'*'"

	If Select('TRBNF')<>0
		TRBNF->(DbCloseArea())
	EndIf
	TcQuery cSql New Alias "TRBNF"
	If TRBNF->(EOF())
		lRet := .F.
	Else
		lRet := .T.
	EndIf
Return(lRet)