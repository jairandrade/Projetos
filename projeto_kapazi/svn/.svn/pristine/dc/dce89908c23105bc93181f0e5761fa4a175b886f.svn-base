#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97A04		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por processar os registro pendentes de envio para  supplier. Alt L//
//																									//
//==================================================================================================//
User Function KP97A04()
Local cQr 			:= ""
Local cAliasS1		:= GetNextAlias()
Local lRet			:= .T.
Local nRegs			:= 0
Local cLinha		:= ""

If Select("cAliasS1")<>0
	DbSelectArea("cAliasS1")
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM "+ RetSqlName("ZS2") +" ZS2 "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZS2_XIDINT = ''
cQr += " ORDER BY ZS2.ZS2_CGC

// abre a query
TcQuery cQr new alias "cAliasS1"

DbSelectArea("cAliasS1")
cAliasS1->(DbGoTop())

If cAliasS1->(EOF())
		MsgInfo("Nao existem dados para integracao","KAPAZI - SUPPLIER CARD")
	Else
		
		If FM_Direct( cDirProc, .F., .F. )	//Caso nao tenha o diretorio Supplier, criaa
			cArqAtu	:= KP97IRBL() 			//Cria o arquivo
			lCriou	:= .T.
		EndIf
		cIdSP	:= GetSx8Num("ZS2", "ZS2_XIDINT","ZS2_XIDINT" + "\system\"+RetSqlName("ZS2"),3)
		ConfirmSx8()
EndIf

While !cAliasS1->(EOF()) .And. lCriou
	
	//cLinha	:= "teste;teste;teste;12.2;8888"
	/*
	cNewCGC	:= cAliasS1->ZS2_CGC
	If cNewCGC <> cAtuCGC
		aAdd(aLogKP,{cAliasS1->ZS2_CGC, STOD(ZS2_DATAIN),ZS2_HORAII,DATE(),TIME(),__cUserID,UsrFullName(__cUserID)})
		cAtuCGC := cAliasS1->ZS2_CGC
	EndIf
	*/

	cMailF	:= Alltrim(cAliasS1->ZS2_EMAIL)
	aMailF 	:= StrTokArr(cMailF,";")
	cMailF	:= aMailF[1]
	
	cMailC	:= Alltrim(cAliasS1->ZS2_EMAILC)
	aMailC 	:= StrTokArr(cMailC,";")
	cMailC	:= aMailc[1]
	
	aEnder		:= StrTokArr((Alltrim(cAliasS1->ZS2_RUA)),",") 
	
	If Len(aEnder) == 2
			cNumer	:= aEnder[2]
			cRua	:= aEnder[1]
		ElseIf Len(aEnder) == 1
			cRua	:= aEnder[1]
		Else
			cRua	:= aEnder[1]
			cNumer	:= Alltrim(cAliasS1->ZS2_NUMERO)
	EndIf 
	
	
	cDataNs	:= SUBSTR(cAliasS1->ZS2_DTNASC,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_DTNASC,5,2) + "/" + SUBSTR(cAliasS1->ZS2_DTNASC,1,4)
	cDatadd	:= SUBSTR(cAliasS1->ZS2_CDESDE,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_CDESDE,5,2) + "/" + SUBSTR(cAliasS1->ZS2_CDESDE,1,4)
	cDataFT	:= SUBSTR(cAliasS1->ZS2_DTFATU,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_DTFATU,5,2) + "/" + SUBSTR(cAliasS1->ZS2_DTFATU,1,4)
	cDataVc	:= SUBSTR(cAliasS1->ZS2_DTVENC,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_DTVENC,5,2) + "/" + SUBSTR(cAliasS1->ZS2_DTVENC,1,4)
	cDataPg	:= SUBSTR(cAliasS1->ZS2_DTPGPA,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_DTPGPA,5,2) + "/" + SUBSTR(cAliasS1->ZS2_DTPGPA,1,4)
	cDataSO	:= SUBSTR(cAliasS1->ZS2_DTNSOC,7,2)  + "/" + SUBSTR(cAliasS1->ZS2_DTNSOC,5,2) + "/" + SUBSTR(cAliasS1->ZS2_DTNSOC,1,4)
	
	//cLinha	:= "teste;teste;teste;12.2;8888"
	cLinha	:= 	cAliasS1->ZS2_TPPESS+";"+;
				Alltrim(cAliasS1->ZS2_CGC)	+";"+;
				Alltrim(cAliasS1->ZS2_NOME)	+";"+;
				IIF(!Empty(cAliasS1->ZS2_DTNASC),cDataNs,"")+";"+;
				Alltrim(cAliasS1->ZS2_TPSOLI)+";"+;
				cRua	+";"+;
				cNumer	+";"+;
				Alltrim(cAliasS1->ZS2_COMPLE)+";"+;
				Alltrim(cAliasS1->ZS2_BAIRRO)+";"+;
				Alltrim(cAliasS1->ZS2_CEP)	+";"+;
				Alltrim(cAliasS1->ZS2_CIDADE)+";"+;
				Alltrim(cAliasS1->ZS2_UF)	+";"+;
				Alltrim(cAliasS1->ZS2_NMCONT)+";"+;
				Alltrim(cAliasS1->ZS2_DDD)	+";"+;
				Alltrim(cAliasS1->ZS2_TEL)	+";"+;
				Alltrim(cAliasS1->ZS2_RAMAL)	+";"+;
				Alltrim(cMailF)	+";"+;
				Alltrim(cAliasS1->ZS2_DDDCEL)+";"+;
				Alltrim(cAliasS1->ZS2_TELCEL)+";"+;
				Alltrim(cMailC)+";"+;
				IIF(!Empty(cAliasS1->ZS2_CDESDE),cDatadd,"")+";"+;
				Alltrim(cAliasS1->ZS2_TPCLIE)+";"+;
				Alltrim(cAliasS1->ZS2_INFCOM)+";"+;
				Alltrim(Transform(cAliasS1->ZS2_LIMATU,"@E 999,999,999.99"))+";"+;
				Alltrim(Transform(cAliasS1->ZS2_NEWLIM,"@E 999,999,999.99"))+";"+;
				Alltrim(cAliasS1->ZS2_PHISTC)+";"+;
				Alltrim(cAliasS1->ZS2_CODCOM)+";"+;
				IIF(!Empty(cAliasS1->ZS2_DTFATU),cDataFT,"")+";"+;
				Alltrim(Transform(cAliasS1->ZS2_VLRTOR,"@E 999,999,999.99"))+";"+;
				IIF(!Empty(cAliasS1->ZS2_DTVENC),cDataVc,"")+";"+;
				Alltrim(Transform(cAliasS1->ZS2_VLRPAR,"@E 999,999,999.99"))+";"+;
				IIF(!Empty(cAliasS1->ZS2_DTPGPA),cDataPg,"")+";"+;
				Alltrim(Transform(cAliasS1->ZS2_VPGPAR,"@E 999,999,999.99"))+";"+;
				Alltrim(cAliasS1->ZS2_TPPSOC)+";"+;
				Alltrim(cAliasS1->ZS2_CGCSO)+";"+;
				Alltrim(cAliasS1->ZS2_NOMESO)+";"+	IIF(!Empty(cAliasS1->ZS2_DTNSOC),cDataSO,"") +"" + cQuebra
				
	FWrite( cArqAtu, cLinha, Len(cLinha) )
	cLinha 	:= ""	
	
	DbSelectArea("ZS2")
	ZS2->(DbSetOrder(1))
	ZS2->(DbGoTop())
	ZS2->(DbGoTo(cAliasS1->RECORECO))
	RecLock("ZS2",.F.)
	ZS2->ZS2_XIDINT	:= cIdSP
	ZS2->(MsUnlock())
	
	cAliasS1->(DbSkip())
EndDO

If lCriou
	FT_FGoto((FT_FLastRec()))	//Vai para ultima linha
	FT_FUse() 					//Fecha o arquivo
	
	If !FCLOSE(cArqAtu)
		Conout( "Erro ao fechar arquivo, erro numero: " + STR(FERROR()) )
	EndIf
	//KP97ABAR(cNmArq, cDir) //exibe arquivo de log
	
EndIf

cAliasS1->(DbCloseArea())
Return()


//Senao existe cria o diretorio
Static Function FM_Direct( cPath, lDrive, lMSg )
Local aDir
Local lRet:=.T.
Default lMSg := .T.

If Empty(cPath)
	Return lRet
EndIf

lDrive := If(lDrive == Nil, .T., lDrive)
cPath := Alltrim(cPath)

If Subst(cPath,2,1) <> ":" .AND. lDrive
		MsgInfo("Unidade de drive nao especificada") //Unidade de drive n?o especificada
		lRet:=.F.
	Else
		cPath := If(Right(cPath,1) == "", Left(cPath,Len(cPath)-1), cPath)
		aDir  := Directory(cPath,"D")
		If Len(aDir) = 0
			If lMSg
				If MsgYesNo("Diretorio - "+cPath+" - nao encontrado, deseja cria-lo" ) //Diretorio  -  nao encontrado, deseja cria-lo
					If MakeDir(cPath) <> 0
						Help(" ",1,"NOMAKEDIR")
						lRet := .F.
					EndIf
				EndIf
			
			Else
				If MakeDir(cPath) <> 0
					Help(" ",1,"NOMAKEDIR")
					lRet := .F.
				EndIf
				
			EndIF
		EndIf
EndIf
Return lRet

/*
+--------------------------------------------------------------------------+
! Função    ! KP97IRBL   ! Autor !Luis                ! Data ! 02/07/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Cria arquivo.  		                                       !
+-----------+--------------------------------------------------------------+
*/
Static Function KP97IRBL()
//cria arquivo de log
cDir := "\Supplier\AlteracaoLimites\"
if !ExistDir(cDir)
	//cria diretorio
	MakeDir(cDir)
endif

cNmArq := "ALT-LIMITES" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt + ".csv"
nHdlLog := msFCreate( Alltrim(cDir+cNmArq) )
Return(nhdllog)


/*
+--------------------------------------------------------------------------+
! Função    ! KP97ABAR   ! Autor !Luis   			  ! Data ! 02/07/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Exibe arquivo de importacao.                                 !
+-----------+--------------------------------------------------------------+
*/
Static Function KP97ABAR(cAArq, cDir)

If CPYS2T(cDir+cAArq, cDirTemp,.F.,.F.)
		//FErase(cDir+cAArq)
		ShellExecute( "open", cDirTemp+Alltrim(cAArq) , "" , "" ,  1 )
	
	Else
		MsgInfo("Nao foi possivel copiar o arquivo do servidor! -> " + Str(FError()))
		Conout(FError())
EndIf

Return()