#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Ponto de entrada a fim de permitir o acesso ao registro !
!                  ! da tabela CC0, logo após uma MDF-E ser transmitida como !
!                  ! cancelada/encerrada pela rotina SPEDMDFE.               !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 30/08/2020                                              !
+------------------+--------------------------------------------------------*/
User Function MDFEEVTLOG()
Local aArea     := GetArea()
Local aAreaCC0  := CC0->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local cQuery    := ""
Local cStatus   := Paramixb[1]
Local cDescSta  := Paramixb[2]
Local nRecnoCC0 := Paramixb[3]
Local cOcorrCod := "26"
Local cObsTran  := "ENCERRAMENTO MDF-e"
Local aOcorre   := {}			
Local cOcorrDes := ""
Local cSitLib   := ""

If cStatus == "6" //Encerramento
	dbSelectArea("CC0")
	CC0->(dbGoTo(nRecnoCC0))
	
	//Atualiza todos os Pedidos que não estejam com Satus em Ocorrência de Transporte
	cQuery := " SELECT DISTINCT F2_DOC, F2_SERIE, D2_FILIAL, D2_PEDIDO
	cQuery += " FROM " + RetSqlName("SF2") + " SF2
	cQuery += "     INNER JOIN " + RetSqlName("SD2") + " SD2 ON 
	cQuery += "         D2_FILIAL      = F2_FILIAL 
	cQuery += "         AND D2_DOC     = F2_DOC 
	cQuery += "         AND D2_SERIE   = F2_SERIE 
	cQuery += "         AND D2_CLIENTE = F2_CLIENTE
	cQuery += "         AND D2_LOJA    = F2_LOJA 
	cQuery += "         AND SD2.D_E_L_E_T_ = ' '
	cQuery += " WHERE F2_FILIAL   = '" + xFilial("CC0")  + "'
	cQuery += "     AND F2_SERMDF = '" + CC0->CC0_SERMDF + "'
	cQuery += "     AND F2_NUMMDF = '" + CC0->CC0_NUMMDF + "'
	cQuery += "     AND SF2.D_E_L_E_T_ = ' '
	cQuery += "     AND F2_TRANSP = ' '
	cQuery += "     AND (SELECT TOP 1 ZF_CODIGO+ZF_TROBS
	cQuery += "          FROM " + RetSqlName("SZF") + " SZF
	cQuery += "          WHERE ZF_FILIAL   = D2_FILIAL
	cQuery += "              AND ZF_PEDIDO = D2_PEDIDO
	cQuery += "              AND SZF.D_E_L_E_T_ = ' '
	cQuery += "              ORDER BY SZF.R_E_C_N_O_ DESC) <> '20" + cObsTran + "'"
	MpSysOpenQuery(cQuery, "QRYMDF")
	
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	While !QRYMDF->(Eof())
		If SC5->(dbSeek(QRYMDF->D2_FILIAL+QRYMDF->D2_PEDIDO))
			aOcorre   := StaticCall(KESTR19,OCORRE_Descri,cOcorrCod)			
			cOcorrDes := aOcorre[1]
			cSitLib	  := aOcorre[2]
			
			RecLock("SC5",.F.)
			SC5->C5_XSITLIB := cSitLib
			MsUnLock("SC5")
			
			U_KFATR15("20",SC5->C5_NUM,,QRYMDF->F2_DOC,QRYMDF->F2_SERIE,,cOcorrCod,cOcorrDes,cObsTran,Date(),Time())
		EndIf
		QRYMDF->(dbSkip())
	EndDo
	QRYMDF->(dbCloseArea())
EndIf

RestArea(aAreaSC5)
RestArea(aAreaCC0)
RestArea(aArea)
Return Nil





