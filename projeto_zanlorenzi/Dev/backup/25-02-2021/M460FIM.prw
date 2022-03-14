#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Luiz Casagrande     º Data ³  06/02/04   º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºDesc.     ³  Ponto de entrada que aplica desconto financeiro a partir  º±±
±±º          ³  do pedido de vendas                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±± ALTERAÇÕES                                                             ¼±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºPrograma  ³M460FIM   ºAutor  ³Nilton Salvalagio   º Data ³  11/09/08   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºDesc.     ³  Alterações realizadas para atender a necessidade da ulti- º±±
±±º          ³  lização da ST em outros estados                           º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                                      
User Function M460FIM()
	Local cAliasTemp:= GetNextAlias()
	Local cQryZA7 	:= ""
	Local cNumRom 	:= ""
	Local cCodZA7   := ""
	Local cTranspGU3 := ""
	Local cCodPedido := ""
	Local cMsgErro 	:= ""
	Local aCabec := {}
	_lFlagSt:=.F.

//grava romaneio quando existir ZA7 - CARGA TRANSPORTADORA X PEDIDOS 25-01-2021 - JAIR
	cQryZA7 := " SELECT DISTINCT ZA7_CODIGO, ZA7_NRROM, ZA7_TRANSP, ZA7_PEDIDO "
	cQryZA7 += " FROM  "+RetSQLName("SF2")+" SF2 "
	cQryZA7 += " JOIN "+RetSQLName("SD2")+" SD2 ON  F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC "
	cQryZA7 += " AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND SD2.D_E_L_E_T_ = ' ' "
	cQryZA7 += " JOIN "+RetSQLName("ZA7")+" ZA7 ON  ZA7_FILIAL=D2_FILIAL AND ZA7_PEDIDO=D2_PEDIDO "
	cQryZA7 += " AND ZA7.D_E_L_E_T_ = ' ' AND ZA7_STATUS = '4' "
	cQryZA7 += " WHERE SF2.D_E_L_E_T_ = ' ' "
	cQryZA7 += " AND SF2.R_E_C_N_O_ = "+cValtoChar(SF2->(RECNO()))+" "

	If Select(cAliasTemp) > 0
		dbSelectArea(cAliasTemp)
		dbCloseArea()
	EndIf

	TCQUERY cQryZA7 NEW ALIAS &cAliasTemp
	If !(cAliasTemp)->(EOF())

		cTranspGU3  := Alltrim(Posicione("GU3",13,xFilial("GU3")+(cAliasTemp)->ZA7_TRANSP,"GU3_CDEMIT"))
		cCodZA7		:= (cAliasTemp)->ZA7_CODIGO
		cCodPedido  := (cAliasTemp)->ZA7_PEDIDO

		If  Empty((cAliasTemp)->ZA7_NRROM) //criar um novo romaneio. informe oS dados para serem carregados na tabela GWN
			cNumRom 	:= GetSXENum("GWN", "GWN_NRROM")
			aadd(aCabec,{"GWN_NRROM",cNumRom})
			aadd(aCabec,{"GWN_CDTRP",cTranspGU3})//transportadora
			aadd(aCabec,{"GWN_CDTPOP","01"})
			aadd(aCabec,{"GWN_CDMTR",""})//CODIGO MOTORISTA
			aadd(aCabec,{"GWN_NMMTR",""})//nOME MOTORISTA
			aadd(aCabec,{"GWN_SIT","3"})//Situação = 3 - liberado

			oModel := FwLoadModel("GFEA050")
			Begin Transaction
				lMsErroAuto := .F.
				FWMVCRotAuto( oModel,"GWN",3,{{"GFEA050_GWN", aCabec}})
				If lMsErroAuto
					DisarmTransaction()
					cMsgErro := MostraErro()
				Else
					cMsgErro := "Romaneio "+cNumRom+" gerado com sucesso para a Nf: "+SF2->F2_DOC
					//Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
					DbSelectArea("GW1")
					GW1->(DbSetOrder(8))
					GW1->(DbGotop())
					If GW1->(DbSeek( xFilial("GW1") + SF2->F2_DOC ))
						GW1->(RecLock("GW1" , .F.))
						GW1->GW1_NRROM := cNumRom
						GW1->(MsUnLock())
					EndIf
				EndIf
			End Transaction
		Else //Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
			cNumRom :=(cAliasTemp)->ZA7_NRROM
			DbSelectArea("GW1")
			GW1->(DbSetOrder(8))
			GW1->(DbGotop())
			If GW1->(DbSeek( xFilial("GW1") + SF2->F2_DOC ))
				If Empty(GW1->GW1_NRROM)
					GW1->(RecLock("GW1" , .F.))
					GW1->GW1_NRROM := cNumRom
					GW1->(MsUnLock())
					cMsgErro := "Nf. "+SF2->F2_DOC+" vinculada ao Romaneio "+cNumRom
				EndIf
			EndIf
		EndIf

		//grava os dados da Nf e romaneio na tabela ZA7
		DbSelectArea("ZA7")
		ZA7->(DbGotop())
		ZA7->(DbSetOrder(1))
		If ZA7->(DbSeek( xFilial("ZA7") + cCodZA7))

			While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
				ZA7->(RecLock("ZA7" , .F.))
				If ZA7->ZA7_PEDIDO=cCodPedido
					ZA7->ZA7_DOC := SF2->F2_DOC
					ZA7->ZA7_STATUS := "6"
					ZA7->ZA7_DTFAT := DATE()
					ZA7->ZA7_HRFAT := TIME()
				EndIf
				If Empty(ZA7->ZA7_NRROM)
					ZA7->ZA7_NRROM := cNumRom
				EndIf
				ZA7->(MsUnLock())
				ZA7->(DbSkip())
			Enddo

		EndIf

		//Grava na tabela de log os dados
		dbSelectArea("ZA6")
		ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
		If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
			RecLock("ZA6",.F.)
			ZA6_MSG := ZA6_MSG+cMsgErro+CHR(13)+CHR(10)
			ZA6->(MsUnlock())
		EndIf
		(cAliasTemp)->(DbCloseArea())
	Endif
	//FIM GRAVA ROMANEIO 25-01-2021 - JAIR

Return
