#Include "Protheus.ch"
#Include "TopConn.ch"
/*/{Protheus.doc} MS520VLD
Esse ponto de entrada é chamado para validar ou não a exclusão da nota na rotina MATA521      
@author Jair Andrade    
@since 20/01/2020
@version version
/*/
User Function MS520VLD
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local cAliasTemp:= GetNextAlias()
	Local cQrySC9 	:= ""
	Local cNumDOC 	:= ""
	Local cCodZA7	:= ""
	Local cNumRom 	:= ""
	Local cMsgErro  := ""
	Local oModel    := Nil
	Local aCabec 	:= {}
	Private cOpera	:= "C"
//este PE vai ser utilizado somente para transações de cargas feitas na tabela ZA7 - EDI transportadoras
	cQrySC9 := " SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM, C9_XSTAWMS, F2_DOC, F2_SERIE,ZA7_CODIGO "
	cQrySC9 += " FROM  "+RetSQLName("SF2")+" SF2 "
	cQrySC9 += " JOIN "+RetSQLName("SD2")+" SD2 ON  F2_FILIAL=D2_FILIAL AND F2_DOC=D2_DOC "
	cQrySC9 += " AND F2_SERIE=D2_SERIE AND F2_CLIENTE=D2_CLIENTE AND F2_LOJA=D2_LOJA AND SD2.D_E_L_E_T_ = ' ' "
	cQrySC9 += " JOIN "+RetSQLName("SC9")+" SC9 ON  C9_FILIAL=D2_FILIAL AND C9_PEDIDO=D2_PEDIDO "
	cQrySC9 += " AND C9_ITEM = D2_ITEMPV AND SC9.D_E_L_E_T_ = ' ' "
	cQrySC9 += " JOIN "+RetSQLName("ZA7")+" ZA7 ON  ZA7_FILIAL=C9_FILIAL AND ZA7_PEDIDO=C9_PEDIDO "
	cQrySC9 += " AND ZA7_ITEMPD = C9_ITEM AND ZA7_DOC ='"+SF2->F2_DOC+"' AND ZA7.D_E_L_E_T_ = ' ' "
	cQrySC9 += " WHERE SF2.D_E_L_E_T_ = ' ' "
	cQrySC9 += " AND SF2.R_E_C_N_O_ = "+cValtoChar(SF2->(RECNO()))+" "
	cQrySC9 += " ORDER BY C9_PEDIDO,C9_ITEM "

	If Select(cAliasTemp) > 0
		dbSelectArea(cAliasTemp)
		dbCloseArea()
	EndIf

	TCQUERY cQrySC9 NEW ALIAS &cAliasTemp
	If !(cAliasTemp)->(EOF())
		Begin Transaction
			While !(cAliasTemp)->(EOF())
				cFilSC9 := (cAliasTemp)->C9_FILIAL
				cPedSC9 := (cAliasTemp)->C9_PEDIDO
				cIteSC9 := (cAliasTemp)->C9_ITEM
				cNumDOC := (cAliasTemp)->F2_DOC
				cCodZA7 := (cAliasTemp)->ZA7_CODIGO
				If  (cAliasTemp)->C9_XSTAWMS=="O"
					aRet:= U_fConJson( GetMv('FZ_WSWMS5'), 'SC9', 1, 'C9_FILIAL+C9_PEDIDO+C9_ITEM',cFilSC9+cPedSC9+cIteSC9 )
					If aRet[1] == .T.
						//GRAVA O STATUS NA SC9
						DbSelectArea("SC9")
						SC9->(DbSetOrder(1))//C9_FILIAL+C9_PEDIDO+C9_ITEM
						SC9->(DbGoTop())
						If SC9->(dbSeek(cFilSC9+cPedSC9+cIteSC9))
							SC9->(RecLock("SC9" , .F.))
							SC9->C9_XSTAWMS:="C"
							SC9->(MsUnLock())
						EndIf

						//apaga os dados da tabela customizada do envio de EDI para as transportadoras.
						DbSelectArea("ZA7")
						ZA7->(DbGotop())
						ZA7->(DbSetOrder(1))
						If ZA7->(DbSeek( cFilSC9 + cCodZA7 ))
							cNumRom := ZA7_NRROM
							While ZA7->(!Eof()) .AND. ZA7->ZA7_FILIAL = cFilSC9 .AND. ZA7->ZA7_CODIGO == cCodZA7
								If ZA7_STATUS !="2"
									ZA7->(RecLock("ZA7" , .F.))
									ZA7->ZA7_STATUS := "2"
									ZA7->(MsUnLock())
								EndIf
								ZA7->(DbSkip())
							Enddo
						EndIf
					Else
						DisarmTransaction()
						lRet := .F.
						Aviso("Exclusão de N.Fiscal", "Não é possivel estornar a Nf. "+cNumDOC+" EDI: "+cCodZA7+". Motivo: "+aRet[2], {"Ok"}, 1)
						Exit
					Endif
				Else
					lRet := .F.
				EndIf
				(cAliasTemp)->(dbSKip())
			Enddo
			If lRet
				//apaga o romaneio
				DbSelectArea("GWN")
				GWN->(DbSetOrder(1))
				GWN->(DbGotop())
				If GWN->(DbSeek( xFilial("GWN") + cNumRom ))
					GWN->(RecLock("GWN" , .F.))
					GWN->GWN_SIT := "1"
					GWN->(MsUnLock())
					aadd(aCabec,{"GWN_NRROM",GWN->GWN_NRROM})
					aadd(aCabec,{"GWN_CDTRP",GWN->GWN_CDTRP})//transportadora
					aadd(aCabec,{"GWN_CDTPOP",GWN->GWN_CDTPOP})
					lMsErroAuto := .F.
					oModel := FwLoadModel("GFEA050")
					FWMVCRotAuto( oModel,"GWN",5,{{"GFEA050_GWN", aCabec}})
					If lMsErroAuto
						DisarmTransaction()
						cMsgErro := MostraErro()
					Else
						cMsgErro := "Romaneio "+cNumRom+" apagado com sucesso. "
					EndIf
				EndIf
				//Grava na tabela de log os dados
				DbSelectArea("ZA6")
				ZA6->(DbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				ZA6->(DbGoTop())
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_MSG   	:= ZA6_MSG+cMsgErro+ " Nf. estornada: "+cNumDOC+" no dia "+dtoc(date())+" / "+time()+CHR(13)+CHR(10)
					ZA6->(MsUnlock())
				EndIf
			EndIf
		End Transaction
	Endif
	(cAliasTemp)->(DbCloseArea())
	RestArea(aArea)
Return lRet
