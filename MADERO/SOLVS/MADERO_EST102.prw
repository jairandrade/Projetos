#Include "Protheus.ch"
#Include "TopConn.CH"
#Include "TryException.CH"
#Include "rwmake.ch"
#Include "TBICONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AEST102 - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Geração de demanda para a Fabrica                       !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 23/05/2018                                              !
+------------------+----------------- ---------------------------------------*/
//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
//User Function AEST102(paramixb)
User Function AEST102(paramixb,cThdId02)
Local _cEmpresa  := paramixb[1] // Empresa destino (da fábrica)
Local _cFilial   := paramixb[2] // Filial destino (da fábrica)
Local cGrupoEmp  := paramixb[3] // Grupo de Empresas originais (de onde buscar as SCs - obtido a partir do cEmpAnt) 
Local nQtdeDias  := paramixb[4] // Numero de dias totais de estoque 
Local cFilOrig   := paramixb[6] // Filial de origem
Local dDataIni   := paramixb[8] // Data do sistema
Local cAliTmp0   := GetNextAlias()
Local cAliTmp1   := GetNextAlias()
Local cQuery     := ""
Local cCleanDem  := ""
Local lErro      := .F.
Local _xaEventL  := {.F.,{}}
Local aDados     := {}
Local aDadosSA5  := {}
Local cPathTmp   := "\temp\"
Local cAuxLog    := ""
Private lMsErroAuto:=.F.
		
	// Composicao do nome das tabelas dos restaurantes	
	if len(cGrupoEmp) = 2
		cGrupoEmp += "0"
	Endif
	RpcClearEnv()
	RPcSetType(3)
    Prepare Environment Empresa _cEmpresa filial _cFilial Tables "SA2","SB1","SB2","SC2","SC3","SC4","SC6","SX5","SBM","ADK","Z25" Modulo "FAT"
    	    
    dDataBase:=dDataIni	    
    	    
    Begin Transaction

    	// -> Apagar as demandas para a fábrica
		cAuxLog:="MRP | " + ': Excluindo demandas da industria...' 
		aadd(_xaEventL[02],cAuxLog)
		ConOut(cAuxLog)                              

		SX2->(dbSetOrder(1))
		cCleanDem := "DELETE FROM "+RetSQLName("SC4")         + "       "
		cCleanDem += "WHERE C4_FILIAL  = '" + xFilial("SC4")  + "'  AND "
		
		//#TB20191126 Thiago Berna - Ajuste para corrigir a exclusao
		//cCleanDem += "      C4_DATA   >= '" + DtoS(dDataBase) + "   AND "
		cCleanDem += "      C4_DATA   >= '" + DtoS(dDataBase) + "'   AND "
		
		cCleanDem += "      C4_XFILERP = '" + cFilOrig        + "'      "       
		TCSqlExec(cCleanDem)

		cAuxLog:="MRP | " + 'Ok.' 
		aadd(_xaEventL[02],cAuxLog)
		ConOut(cAuxLog)                              

    	// -> Incluir as novas demandas para a fábrica
    	DbSelectArea("SA2")
    	SA2->(dbSetOrder(3))
    	SA2->(dbSeek(xFilial("SA2")+SM0->M0_CGC))
		
		cAuxLog:="MRP | " + ': Verificando cadastro de produtos na industria...' 
		aadd(_xaEventL[02],cAuxLog)
		ConOut(cAuxLog)                              

		cQuery:="SELECT DISTINCT B1_FILIAL, B1_COD, B1_DESC, A5_CODPRF "
		cQuery+="FROM Z25"+cGrupoEmp+" Z25, SA5"+cGrupoEmp+" SA5, SB1"+cGrupoEmp+" SB1  " 
		cQuery+="WHERE  Z25.Z25_FILIAL   = '" + cFilOrig                        + "' AND " 
		cQuery+="       Z25.Z25_DTNECE  >= '" + DtoS(dDataBase)                 + "' AND " 
		cQuery+="       Z25.Z25_DTNECE  <= '" + DToS(dDataBase+nQtdeDias)       + "' AND "
		cQuery+="       Z25.Z25_CODFOR   = '" + SA2->A2_COD                     + "' AND "
		cQuery+="       Z25.Z25_CODLOJ   = '" + SA2->A2_LOJA                    + "' AND "
		cQuery+="       Z25.Z25_QUANT   > 0                                          AND "		
		cQuery+="       Z25.D_E_L_E_T_   = ' '             AND "
		cQuery+="       SA5.A5_FILIAL    = Z25.Z25_FILIAL  AND "
		cQuery+="       SA5.A5_PRODUTO   = Z25.Z25_PRODUT  AND "
		cQuery+="       SA5.D_E_L_E_T_   = ' '             AND "
		cQuery+="       SB1.B1_FILIAL    = Z25.Z25_FILIAL  AND "
		cQuery+="       SB1.B1_COD       = Z25.Z25_PRODUT  AND "
		cQuery+="       SB1.D_E_L_E_T_  = ' '              AND "
		cQuery+="       SA5.A5_CODPRF NOT IN (SELECT B1_COD FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+_cFilial+"')"
		cQuery+="ORDER BY  B1_FILIAL, B1_COD, A5_CODPRF "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp1,.T.,.T.)				
		(cAliTmp1)->(dbGoTop())
		
		While !(cAliTmp1)->(eof())
			lErro        :=.F.
			_xaEventL[01]:=lErro
			cAuxLog      :="MRP | " + "Produto "+AllTrim((cAliTmp1)->B1_COD)+"-"+AllTrim((cAliTmp1)->B1_DESC)+" nao cadastrado na industria. [B1_COD = " +AllTrim((cAliTmp1)->A5_CODPRF)+"]"
		    Aadd(_xaEventL[02],cAuxLog)
			ConOut(cAuxLog)                              
			(cAliTmp1)->(DbSkip())
		EndDo
		(cAliTmp1)->(dbCloseArea())
		
		cAuxLog:=IIF(lErro,"MRP | " + "Erro.","MRP | " + "Ok.") 
		aadd(_xaEventL[02],cAuxLog)
		ConOut(cAuxLog)                              

		If !lErro	
			cAuxLog:="MRP | " + ': Incluindo demandas na industria...' 
			aadd(_xaEventL[02],cAuxLog)
			ConOut(cAuxLog)                              			
			cQuery  := "SELECT Z25_FILIAL, Z25_PRODUT, A5_CODPRF, A5_PRODUTO, A5_FORNECE, A5_LOJA, Z25_DTNECE, SUM(Z25_QUANT) SMQTD " 
			cQuery  += "FROM Z25" + cGrupoEmp + " Z25 INNER JOIN SB1" + cGrupoEmp + " SB1 " 
			cQuery  += "ON Z25.Z25_FILIAL   = SB1.B1_FILIAL  AND " 
			cQuery  += "   Z25.Z25_PRODUT   = SB1.B1_COD     AND " 
			cQuery  += "   SB1.D_E_L_E_T_   = ' '                "
			cQuery  += "INNER JOIN "+RetSqlName("ADK") + " ADK   "
			cQuery  += "ON ADK.ADK_XFILI    =  Z25.Z25_FILIAL  AND  "  
			cQuery  += "   ADK.D_E_L_E_T_   = ' '                   "
			cQuery  += "INNER JOIN SA5" + cGrupoEmp + " SA5         "
			cQuery  += "ON    SA5.A5_FILIAL    = ADK.ADK_XFILI  AND "  
			cQuery  += "      SA5.A5_FORNECE   = Z25.Z25_CODFOR AND "  
			cQuery  += "      SA5.A5_LOJA      = Z25.Z25_CODLOJ AND " 
			cQuery  += "      SA5.A5_PRODUTO   = Z25.Z25_PRODUT AND " 
			cQuery  += "      SA5.D_E_L_E_T_   = ' '                "
			cQuery	+= "WHERE Z25.Z25_FILIAL   = '" + cFilOrig                  + "' AND " 
			cQuery  += "      Z25.Z25_DTNECE  >= '" + dtos(dDataBase)           + "' AND " 
			cQuery  += "      Z25.Z25_DTNECE  <= '" + dtos(dDataBase+nQtdeDias) + "' AND " 
			cQuery  += "      Z25.Z25_CODFOR   = '" + SA2->A2_COD  + "'              AND "
			cQuery  += "      Z25.Z25_CODLOJ   = '" + SA2->A2_LOJA + "'              AND "
			cQuery	+= "      Z25.Z25_QUANT   > 0                                    AND "	
			cQuery  += "      Z25.D_E_L_E_T_   = ' '                                     "
			cQuery  += "GROUP BY Z25_FILIAL, Z25_PRODUT, A5_CODPRF, A5_PRODUTO, A5_FORNECE, A5_LOJA, Z25_DTNECE  "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp0,.T.,.T.)				
			
			(cAliTmp0)->(dbGoTop())
			While !(cAliTmp0)->(eof())
				aDados:={}
				SB1->(DbSetOrder(1))
        		If SB1->(MsSeek(xFilial("SB1")+(cAliTmp0)->A5_CODPRF))
					// -> Calcula dados do fornecedor (industria)
				
					//#TB20191126 Thiago Berna - Ajuste para corrigir a conversao
					//aDadosSA5:=u_C104PRF((cAliTmp0)->SMQTD,(cAliTmp0)->A5_FORNECE,(cAliTmp0)->A5_LOJA,SB1->B1_COD,.F.)
					//#TB20191217 Thiago Berna - Ajuste para considerar o produto do restaurante 
					//aDadosSA5:=u_C104PRF((cAliTmp0)->SMQTD,(cAliTmp0)->A5_FORNECE,(cAliTmp0)->A5_LOJA,SB1->B1_COD,.F.,.F.,cFilOrig
					aDadosSA5:=u_C104PRF((cAliTmp0)->SMQTD,(cAliTmp0)->A5_FORNECE,(cAliTmp0)->A5_LOJA,SB1->B1_COD,.F.,.F.,cFilOrig,(cAliTmp0)->A5_PRODUTO)

					//#TB20191126 Thiago Berna - Incluido log para monitorar se o valor não esta sendo convertido
					If (cAliTmp0)->SMQTD == aDadosSA5[1]
						cAuxLog:="MRP | " + "Filial:[" + cFilOrig + "], Produto [" + AllTrim((cAliTmp0)->A5_PRODUTO) + "], Fornecedor [" + (cAliTmp0)->A5_FORNECE + "], Loja [" + (cAliTmp0)->A5_LOJA + "], Quantidade[" + AllTrim(Transform((cAliTmp0)->SMQTD,PesqPict( 'Z25' , 'Z25_QUANT' ))) + "] Produto Fornecedor[" + AllTrim((cAliTmp0)->A5_CODPRF) + "]nao convertido."
						Aadd(_xaEventL[02],cAuxLog)	
					EndIf

					aadd(aDados,{"C4_FILIAL" ,xFilial("SC4")         									,Nil})
					aadd(aDados,{"C4_PRODUTO",SB1->B1_COD            									,Nil})
		            aadd(aDados,{"C4_LOCAL"  ,SB1->B1_LOCPAD									        ,Nil})
        		    aadd(aDados,{"C4_DOC"    ,StrZero(Year(dDataBase),4,0)+StrZero(Month(dDataBase),2,0),Nil})
		            aadd(aDados,{"C4_QUANT"  ,aDadosSA5[1]												,Nil})
		            aadd(aDados,{"C4_DATA"   ,stod((cAliTmp0)->Z25_DTNECE)								,Nil})
		            aadd(aDados,{"C4_OBS"    ,"Demanda restaurantes."									,Nil})
		            aadd(aDados,{"C4_XFILERP",(cAliTmp0)->Z25_FILIAL								    ,Nil})
					// -> Executa inclusão
					//#TB20190315 - Somente itens com quantidade maior que zero
					If aDadosSA5[1] > 0
						MATA700(aDados,3)
					EndIf
					If lMsErroAuto
						lErro        := .T.
						_xaEventL[01]:=lErro
						cAuxLog := "MRP | " + "dm_"+cFilAnt+"_"+SB1->B1_COD+"_"+strtran(time(),":","")
						MostraErro(cPathTmp, cAuxLog)
						Aadd(_xaEventL[02],cAuxLog)		    
						ConOut(cAuxLog)                              
						DisarmTransaction()
						Exit
					EndIf					
				Else
					cAuxLog:="MRP | " + "Produto nao encontrado no cadastro da industria: "+(cAliTmp0)->A5_CODPRF
					Aadd(_xaEventL[02],cAuxLog)		    
					conout(cAuxLog)
				EndIf   
				(cAliTmp0)->(dbSkip())
			EndDo 			
			(cAliTmp0)->(dbCloseArea())		

			cAuxLog:=IIF(lErro,"MRP | " + "Erro.","MRP | " + "Ok.")
			aadd(_xaEventL[02],cAuxLog)
			ConOut(cAuxLog)                              

		EndIf			
		
	End Transaction
		
    //#TB20191129 Thiago Berna
	//RESET ENVIRONMENT
	RpcClearEnv()

	_xaEventL[01]:=!_xaEventL[01]

	//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
	PutGlbVars(cThdId02,_xaEventL)

	//#TB20191129 Thiago Berna - Ajuste para encerrar a thread.
	KillApp(.T.)
        
Return(_xaEventL)