/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras	                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para retorno de informações de sol. de compra!
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti									 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 06/11/2014												 !
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE "RWMAKE.CH"
#include "Directry.ch"
#include "fileio.ch"	

#DEFINE CRLF (chr(13)+chr(10))

wsservice wsPWSSOLCOMTCP description "Webservice para tratamento de solicitacao de compra - TCP"

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sEmpresa as string
	wsdata sSOLICIT as string
	wsdata sNOME as string
	wsdata sNUMFLG as string
	wsdata sOBS as string
	wsdata sTipo as string

	wsdata oRetSolic as PWSSolComp_Struct
	wsdata sCodSolicitacao as string

	// DECLARACAO DAS ESTRUTURAS
	wsdata oItem as PWSItem_Struct
	wsdata oItens as PWSItens_Struct
	wsdata oAnexos as PWSAnexos_Struct optional
	wsdata oRateios as PWSRateios_Struct optional

	// DELCARACAO DO METODOS
	wsmethod INCLUIR description "Inclui uma solicitacao de compra"

endwsservice

/*
+------------+---------------------------------------------------------------+
! Funcao     ! INCLUIR											     		 !
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti										 !
+------------+---------------------------------------------------------------+
! Descricao  ! Inclui uma solicitacao de compra
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod INCLUIR wsreceive sFILIAL, sEmpresa, sSOLICIT,sNOME, sNUMFLG, sOBS,sTipo, oItens,oRateios, oAnexos wssend oRetSolic wsservice wsPWSSOLCOMTCP

	Local aArea := GetArea()
	Local _aSM0 := GetArea("SM0")

	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local cDoc   := ""
	Local aErros  := {}
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt
	Local aRatAx  := {}
	Local aRateios  := {}
	Local aRateio  := {}
	Local lRateio  := .f.
	Local nIndAx
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	RpcClearEnv()

	OpenSM0()

	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL, " ", "COM")//,,aTables, , , ,  )

	//RPCSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL, Nil, Nil, Nil, GetEnvServer())
	//PREPARE ENVIRONMENT EMPRESA SM0->M0_CODIGO FILIAL SM0->M0_CODFIL MODULO 'COM' TABLES 'SM0','SC1','SA1','SA2','CTT','SB1','SB5','SBE','SBM','SF1','SD1','SF2','SD2','SX5','SE2'

	aErros := validaSc(sFILIAL, sEmpresa, sSOLICIT, sNUMFLG, oItens, @oAnexos)
	
	lRateio := (TYPE('oRateios:Rateio') == 'A' .AND. len(oRateios:Rateio) > 0)
	
	if len(aErros) == 0
		//Conout("Empresa: "+cEmpAnt+"-> Filial: "+cFilAnt)
		//Conout("Empresa: "+SM0->M0_CODIGO+"-> Filial: "+SM0->M0_CODFIL)

		DbSelectArea("SC1")
		//Verifica numero da SC
		cDoc := GetSX8Num("SC1","C1_NUM")
		SC1->(dbSetOrder(1))
		While SC1->(dbSeek(xFilial("SC1")+cDoc))
			ConfirmSX8()
			cDoc := GetSX8Num("SC1","C1_NUM")
		EndDo

		aadd(aCabec,{"C1_NUM"    ,cDoc})
		aadd(aCabec,{"C1_SOLICIT",sSOLICIT})
		aadd(aCabec,{"C1_EMISSAO",dDataBase})

		aLinha := ::oItens:Item

		For nX := 1 To len(aLinha)
			aItem := {}
			aadd(aItem,{"C1_ITEM"   ,StrZero(nX,TamSX3("C1_ITEM")[1]),Nil})
			aadd(aItem,{"C1_PRODUTO",RTRIM(aLinha[nX]:PRODUTO)	,Nil})
			aadd(aItem,{"C1_QUANT"  ,aLinha[nX]:QUANT	,Nil})
			if !Empty(AllTrim(aLinha[nX]:UM))
				aadd(aItem,{"C1_UM"		,AllTrim(aLinha[nX]:UM)			,Nil})
			endif
			
			if !empty(AllTrim(aLinha[nX]:FORNECE))
				aadd(aItem,{"C1_FORNECE",AllTrim(aLinha[nX]:FORNECE)	,Nil})
			endif
			if !empty(AllTrim(aLinha[nX]:LOJA))
				aadd(aItem,{"C1_LOJA"	,AllTrim(aLinha[nX]:LOJA)		,Nil})
			endif
		
			if !empty(aLinha[nX]:DATPRF)
				aadd(aItem,{"C1_DATPRF"	,CTOD(aLinha[nX]:DATPRF)		,Nil})
			endif
			
			// Adiciona a observacao geral como de todos os itens
			aadd(aItem,{"C1_OBS",AllTrim(sOBS)						,Nil})

			PswOrder(2)
			_cRequisi := sSOLICIT 
			If  PswSeek(ALLTRIM(_cRequisi) ,.T.) //Se usuário encontrado
				aGrupos := Pswret(1)  
				if !empty(SUBSTR(aGrupos[1][22],5,6))
					_cRequisi   := SUBSTR(aGrupos[1][22],5,6)
				endif
				aadd(aItem,{"C1_USER",AllTrim(aGrupos[1][1])				,Nil})
			endif
			aadd(aItem,{"C1_XNOMREQ",AllTrim(sNOME)				,Nil})
			// Adiciona como requisitante do item o proprio solicitante
			aadd(aItem,{"C1_REQUISI",AllTrim(_cRequisi)				,Nil})
			// Adiciona o numero fluig da solicitacao
			aadd(aItem,{"C1_XSALES ",AllTrim(sNUMFLG)				,Nil})
			aadd(aItem,{"C1_XTIPO",AllTrim(sTipo)				,Nil})
			
			if(lRateio)
				nTotPerc := 0
						
				aadd(aItem,{"C1_RATEIO",'1'	,Nil})
				aRatAux := {}
				aRatAx := {}
				aadd(aRatAx,StrZero(nX,TamSX3("C1_ITEM")[1]))
				
				FOR nIndAx := 1 to LEN(oRateios:Rateio)
					aRateio := {}
//					aadd(aRateio,{"CX_SOLICIT",cDoc			,Nil})
//					aadd(aRateio,{"CX_ITEMSOL",StrZero(nX,TamSX3("C1_ITEM")[1])			,Nil})
					aadd(aRateio,{"CX_ITEM",StrZero(nIndAx,TamSX3("CX_ITEM")[1])				,Nil})
					aadd(aRateio,{"CX_PERC",oRateios:Rateio[nIndAx]:PERCENTUAL				,Nil})
					aadd(aRateio,{"CX_CC",oRateios:Rateio[nIndAx]:CENTROCUSTO				,Nil})
					aadd(aRateio,{"CX_ITEMCTA",oRateios:Rateio[nIndAx]:ITEMCTA			,Nil})
					aadd(aRateio,{"CX_XNATURE",oRateios:Rateio[nIndAx]:NATUREZA				,Nil})
					
					aadd(aRatAux,aRateio)
				NEXT
				
				aadd(aRatAx,aRatAux)
				
				aadd(aRateios,aRatAx)
				
//arametros?aRateioSC[nX,1]: item da solicitacao de compra.			  
//		 ?aRateioSC[nX,2]: array com os itens do rateio.			  
//		 ?aRateioSC[nX,2,nY,nZ,1]: nome do campo.					 
//		 ?aRateioSC[nX,2,nY,nZ,2]: conteudo do campo. 			  	  
//		 ?aRateioSC[nX,2,nY,nZ,3]: validacao especifica.			 
//				
			else
				
				aadd(aItem,{"C1_RATEIO",'2'	,Nil})
				if !empty(AllTrim(aLinha[nX]:CC))
					aadd(aItem,{"C1_CC"		,AllTrim(PadL(aLinha[nX]:CC, 6, "0"))			,Nil})
				endif
				if !empty(AllTrim(aLinha[nX]:ITEMCTA))
					aadd(aItem,{"C1_ITEMCTA",AllTrim(aLinha[nX]:ITEMCTA)	,Nil})
				endif
				if !empty(AllTrim(aLinha[nX]:NATUREZA))
					aadd(aItem,{"C1_XNATURE",AllTrim(aLinha[nX]:NATUREZA)	,Nil})
				endif
			endif
			

			aadd(aItens,aItem)
		Next nX

		MSExecAuto({|x,y,z,w,t,u| Mata110(x,y,z,w,t,u)},aCabec,aItens, 3,.F.,.F.,aRateios)
		If !lMsErroAuto
			ConfirmSX8()
			//Conout(OemToAnsi("Incluido com sucesso solicitacao de compra nro.: ")+cDoc)

			::oRetSolic:STATUS := 'OK'
			::oRetSolic:CODIGO := cDoc

			armazenaAnexo(cDoc,oAnexos)

		Else
			RollBackSX8()
			cErro := ""
			aLog := GetAutoGRLog()
			For nX := 1 To Len(aLog)
				cErro += aLog[nX] + "    " + CRLF
			Next nX

			aadd(aErros, WSClassNew("PWSErros_Struct"))
			aErros[len(aErros)]:ERRO := cErro

//			MemoWrite('INC_SC_'+cDoc+'_'+dtos(dDatabase)+Replace(time(),":","")+'.txt', cErro )

			::oRetSolic:STATUS := "ERRO"
			::oRetSolic:ERROS   := aErros
			::oRetSolic:CODIGO := ''
		EndIf
	ELSE
		::oRetSolic:STATUS := "ERRO"
		::oRetSolic:ERROS   := aErros
		::oRetSolic:CODIGO := ''
	endif
	cEmpAnt := _cEmpAux
	cFilAnt := _cFilAux

	RpcClearEnv()

	RpcSetType( 3 )
	if !empty(_cEmpAux) .and. !empty(_cEmpAux)
		RpcSetEnv( _cEmpAux, _cFilAux )
	endif

	RestArea(aArea)
	RestArea(_aSM0)
return .T.

static function validaSc(sFILIAL, sEmpresa, sSOLICIT, sNUMFLG, oItens, oAnexos)
	Local aErros := {}
	Local cServidor  := GetNewPar("TCP_SCURL",'10.41.4.74')
	Local cPorta    := GetNewPar("TCP_SCPORT",21)
	Local cLogin    := GetNewPar("TCP_SCUSER",'l-compras')
	Local cSenha    := GetNewPar("TCP_SCPWS",'compras@123')
	Local lConFtp   := .T.
	Local _cCaminho := 'dirdoc\co'+cEmpAnt+"\shared\"
	Local nX
	Local nIndAx
	IF EMPTY(sSOLICIT)
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := 'Solicitante não pode ser vazio.'
	ENDIF
	IF EMPTY(sNUMFLG)
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := "Número da solicitação não pode ser vazia."
	ENDIF

	IF EMPTY(sFILIAL)
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := "Filial da solicitação não pode ser vazia."
	ENDIF

	IF EMPTY(sEmpresa)
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := "Empresa da solicitação não pode ser vazia."
	ENDIF

	dbSelectArea('SM0')
	SM0->(DBSetOrder(1))

	IF !SM0->(DbSeek(sEmpresa+sFILIAL))
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := "Empresa+Filial inválida."
	ENDIF

	if(TYPE('oItens:Item') != 'A' .OR. len(oItens:Item) == 0)
		aadd(aErros, WSClassNew("PWSErros_Struct"))
		aErros[len(aErros)]:ERRO := "Solicitação sem nenhum item."
	endif

	IF LEN(aErros) == 0
		aLinha := oItens:Item

		dbSelectArea('SB1')
		SB1->(DBSetOrder(1))
		dbSelectArea('CTT')
		CTT->(DBSetOrder(1))
		dbSelectArea('CTD')
		CTD->(DBSetOrder(1))
		dbSelectArea('SAH')
		SAH->(DBSetOrder(1))
		dbSelectArea('SED')
		SED->(DBSetOrder(1))

		For nX := 1 To len(aLinha)

			IF !SB1->(DbSeek(xFilial('SB1')+RTRIM(aLinha[nX]:PRODUTO)))
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Produto inválido. Código: "+RTRIM(aLinha[nX]:PRODUTO)
			elseIF SB1->B1_MSBLQL  == '1'
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Produto bloqueado. Código: "+RTRIM(aLinha[nX]:PRODUTO)
			ELSEif !Empty(AllTrim(aLinha[nX]:UM))
				if !SAH->(DbSeek(xFilial('SAH')+RTRIM(aLinha[nX]:UM)))
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Unidade de medida inválida. Código: "+RTRIM(aLinha[nX]:UM)
				elseif SB1->B1_UM != SAH->AH_UNIMED .AND. SB1->B1_SEGUM   != SAH->AH_UNIMED
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Unidade de medida inválida para o produto. Código: "+RTRIM(aLinha[nX]:UM)
				endif
			ENDIF

			if VALTYPE(aLinha[nX]:QUANT) != 'N'
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Quantidade deve ser numérica.'
			elseif aLinha[nX]:QUANT <= 0
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Quantidade informada inválida. Qtd: "+ALLTRIM(STR(aLinha[nX]:QUANT))
			endif

			if !empty(AllTrim(aLinha[nX]:CC))

				IF !CTT->(DbSeek(xFilial('CTT')+RTRIM(aLinha[nX]:CC)))
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Centro de custo inválido. Código: "+RTRIM(aLinha[nX]:CC)
				elseIF CTT->CTT_BLOQ == '1'
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Centro de custo bloqueado. Código: "+RTRIM(aLinha[nX]:CC)
				ENDIF
			endif

			if !empty(AllTrim(aLinha[nX]:ITEMCTA))

				IF !CTD->(DbSeek(xFilial('CTD')+RTRIM(aLinha[nX]:ITEMCTA)))
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Item conta inválido. Código: "+RTRIM(aLinha[nX]:ITEMCTA)
				elseIF CTD->CTD_BLOQ == '1'
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Item conta bloqueado. Código: "+RTRIM(aLinha[nX]:ITEMCTA)
				ENDIF
			endif
			
			if !empty(AllTrim(aLinha[nX]:NATUREZA))

				IF !SED->(DbSeek(xFilial('SED')+RTRIM(aLinha[nX]:NATUREZA)))
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Natureza inválida. Código: "+RTRIM(aLinha[nX]:NATUREZA)
				elseIF SED->ED_MSBLQL == '1'
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Natureza bloqueada. Código: "+RTRIM(aLinha[nX]:NATUREZA)
				ENDIF
			endif

			_cDtTemp := CTOD(aLinha[nX]:DATPRF)

			if(VALTYPE(_cDtTemp) != 'D' .OR. EMPTY(_cDtTemp))
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Data do item "+ALLTRIM(STR(nX))+" em formato inválido. Data recebida: "+aLinha[nX]:DATPRF
			ENDIF
			
		Next nX
		
		if(TYPE('oRateios:Rateio') == 'A' .AND. len(oRateios:Rateio) > 0)
			nTotPerc := 0

			FOR nIndAx := 1 to LEN(oRateios:Rateio)
				IF oRateios:Rateio[nIndAx]:PERCENTUAL <= 0
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Item do rateio com percentual menor ou igual a 0. Item: "+alltrim(str(nIndAx))
				ENDIF
				
				IF oRateios:Rateio[nIndAx]:PERCENTUAL == 100
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Item do rateio com percentual igual a 100. Item: "+alltrim(str(nIndAx))
				ENDIF
				
				nTotPerc += oRateios:Rateio[nIndAx]:PERCENTUAL
				
				if !empty(oRateios:Rateio[nIndAx]:CENTROCUSTO)

					IF !CTT->(DbSeek(xFilial('CTT')+RTRIM(oRateios:Rateio[nIndAx]:CENTROCUSTO)))
						aadd(aErros, WSClassNew("PWSErros_Struct"))
						aErros[len(aErros)]:ERRO := "Centro de custo inválido. Código: "+RTRIM(oRateios:Rateio[nIndAx]:CENTROCUSTO)
					elseIF CTT->CTT_BLOQ == '1'
						aadd(aErros, WSClassNew("PWSErros_Struct"))
						aErros[len(aErros)]:ERRO := "Centro de custo bloqueado. Código: "+RTRIM(oRateios:Rateio[nIndAx]:CENTROCUSTO)
					ENDIF
				else
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Centro de custo do rateio não pode ser vazio. Item: "+alltrim(str(nIndAx))
				endif
				
				if empty(oRateios:Rateio[nIndAx]:NATUREZA) .AND. empty(oRateios:Rateio[nIndAx]:ITEMCTA)
					
					aadd(aErros, WSClassNew("PWSErros_Struct"))
					aErros[len(aErros)]:ERRO := "Para fazer o rateio é necessário preencher o Item contábil ou a natureza. Item: "+alltrim(str(nIndAx))
				else
					if !empty(oRateios:Rateio[nIndAx]:NATUREZA) 
						IF !SED->(DbSeek(xFilial('SED')+RTRIM(oRateios:Rateio[nIndAx]:NATUREZA)))
							aadd(aErros, WSClassNew("PWSErros_Struct"))
							aErros[len(aErros)]:ERRO := "Natureza inválida. Código: "+RTRIM(oRateios:Rateio[nIndAx]:NATUREZA)
						elseIF SED->ED_MSBLQL == '1'
							aadd(aErros, WSClassNew("PWSErros_Struct"))
							aErros[len(aErros)]:ERRO := "Natureza inválida. Código: "+RTRIM(oRateios:Rateio[nIndAx]:NATUREZA)
						ENDIF
					endif
					
					if !empty(oRateios:Rateio[nIndAx]:ITEMCTA) 
						IF !CTD->(DbSeek(xFilial('CTD')+RTRIM(oRateios:Rateio[nIndAx]:ITEMCTA)))
							aadd(aErros, WSClassNew("PWSErros_Struct"))
							aErros[len(aErros)]:ERRO := "Item Conta inválida. Código: "+RTRIM(oRateios:Rateio[nIndAx]:ITEMCTA)
						elseIF CTD->CTD_BLOQ == '1'
							aadd(aErros, WSClassNew("PWSErros_Struct"))
							aErros[len(aErros)]:ERRO := "Item Conta bloqueada. Código: "+RTRIM(oRateios:Rateio[nIndAx]:ITEMCTA)
						ENDIF
					endif
					
				endif
				
			NEXT
			
			if nTotPerc != 100
				aadd(aErros, WSClassNew("PWSErros_Struct"))
				aErros[len(aErros)]:ERRO := "Total do rateio diferente que 100%"
			endif
			
		endif
		
		if(TYPE('oAnexos:Anexo') == 'A' .AND. len(oAnexos:Anexo) > 0)
			aLinha := oAnexos:Anexo

//			oFTPHandle := tFtpClient():New()
//			nRet := oFTPHandle:FTPConnect(cServidor,cPorta,cLogin, cSenha)
//			sRet := oFTPHandle:GetLastResponse()
//
//			If (nRet != 0)
//				aadd(aErros, WSClassNew("PWSErros_Struct"))
//				aErros[len(aErros)]:ERRO := "Falha ao conectar no FTP! "+sRet
//				lConFtp := .F.
//			EndIf
			
			For nX := 1 To len(oAnexos:Anexo)
				
				IF(!EMPTY( oAnexos:Anexo[nX]:Nome))
					while FILE(_cCaminho + oAnexos:Anexo[nX]:Nome) 
						oAnexos:Anexo[nX]:Nome := 'v1_'+oAnexos:Anexo[nX]:Nome
					enddo
					
					nHandle := fcreate(_cCaminho+oAnexos:Anexo[nX]:Nome)
				
					cDecode64 := Decode64(oAnexos:Anexo[nX]:Arquivo)
					FWrite(nHandle, cDecode64)
					fclose(nHandle)	
					fHdl := fOpen(_cCaminho+oAnexos:Anexo[nX]:Nome,FO_READ,,.F.)
					
					if fHdl = -1
					    aadd(aErros, WSClassNew("PWSErros_Struct"))
						aErros[len(aErros)]:ERRO := "Não foi possível copiar o arquivo. Arquivo: "+ALLTRIM(oAnexos:Anexo[nX]:Nome) 
					endif
					fClose(fHdl)
				ENDIF
			next
		endif

	ENDIF
return aErros

STATIC Function armazenaAnexo(cNumSc,oAnexos)
	
	Local _cCaminho := 'dirdoc\co'+cEmpAnt+"\shared\"
	lOCAL lInc := .f.
	Local nX
	if(TYPE('oAnexos:Anexo') == 'A' .AND. len(oAnexos:Anexo) > 0)
		
	
		
		For nX := 1 To len(oAnexos:Anexo)
			
			IF(!EMPTY( oAnexos:Anexo[nX]:Nome))
				lInc := .t.
				
				cCodObj := GetSX8Num("AC9","AC9_CODOBJ")
				RecLock("ACB",.T.)
				ACB->ACB_FILIAL   := xFilial('ACB')
				ACB->ACB_DESCRI   := oAnexos:Anexo[nX]:Descricao
				ACB->ACB_OBJETO   := oAnexos:Anexo[nX]:Nome
				ACB->ACB_CODOBJ   := cCodObj
				ACB->(msUnlock())
				
				ConfirmSX8()
				RecLock("AC9",.T.)
				AC9->AC9_FILIAL   := xFilial('AC9')
				AC9->AC9_FILENT   := xFilial('SC1')
				AC9->AC9_ENTIDA   :='SC1'
				AC9->AC9_CODENT   := xFilial('SC1')+cNumSc+'0001'
				AC9->AC9_CODOBJ   := cCodObj
				AC9->(msUnlock())
			ENDIF
			
		next
		
	endif
return

// Definicao das estruturas

// Estrutura de um item da solicitacao
wsstruct PWSItem_Struct
	wsdata PRODUTO AS string
	wsdata QUANT AS float
	wsdata UM AS string optional
	wsdata CC AS string optional
	wsdata FORNECE AS string optional
	wsdata LOJA AS string optional
	wsdata ITEMCTA AS string optional
	wsdata NATUREZA AS string optional
	wsdata DATPRF AS string optional
	wsdata OBS AS string optional
endwsstruct

wsstruct PWSItens_Struct
	wsdata Item as array of PWSItem_Struct
endwsstruct

wsstruct PWSAnexos_Struct
	wsdata Anexo as array of PWSAnexo_Struct optional
endwsstruct

wsstruct PWSAnexo_Struct
	wsdata Arquivo as string
	wsdata Nome    as string
	wsdata Descricao    as string
endwsstruct

wsstruct PWSRateios_Struct
	wsdata Rateio	as array of PWSRateio_Struct optional
endwsstruct

wsstruct PWSRateio_Struct
	wsdata CentroCusto	as string
	wsdata Natureza     as string
	wsdata ItemCta      as string
	wsdata Percentual   as FLOAT
endwsstruct

wsstruct PWSSolComp_Struct

	wsdata STATUS as string
	wsdata CODIGO as string
	wsdata ERROS  as array of PWSErros_Struct optional

endwsstruct

// Estrutura de um item da solicitacao
wsstruct PWSErros_Struct
	wsdata ERRO AS string
endwsstruct