#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97A02		|	Autor: Luis Paulo							|	Data: 20/05/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por processar os registro pendentes de envio para  supplier		//
//	Concessao de limites																			//
//==================================================================================================//
User Function KP97A02()
Local cQr 			:= ""
Local cAliasS1		:= GetNextAlias()
Local lRet			:= .T.
Local nRegs			:= 0
Local cLinha		:= ""
Local cMailF		:= ""
Local aMailF		:= ""
Local cMailC		:= ""
Local aMailC		:= ""
Local cAtuCGC		:= ""
Local cNewCGC		:= ""
Local	cDataNs		:= ""
Local	cDataFT		:= ""
Local	cDatadd		:= ""
Local	cDataVc		:= ""
Local	cDataPg		:= ""
Local	cDataSO		:= ""
Local 	aEnder		:= {}
Local 	cRua		:= ""
Local 	cNumer		:= ""
	
If Select("cAliasS1")<>0
	DbSelectArea("cAliasS1")
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM "+ RetSqlName("ZS1") +" ZS1 "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZS1_XIDINT = ''
cQr += " ORDER BY ZS1.ZS1_CGC

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
			cIdSP	:= GetSx8Num("ZS1", "ZS1_XIDINT","ZS1_XIDINT" + "\system\"+RetSqlName("ZS1"),3)
			ConfirmSx8()
		EndIf
		
EndIf


While !cAliasS1->(EOF()) .And. lCriou
	
	
	cNewCGC	:= cAliasS1->ZS1_CGC
	If cNewCGC <> cAtuCGC
		aAdd(aLogKP,{cAliasS1->ZS1_CGC, STOD(ZS1_DATAIN),ZS1_HORAII,DATE(),TIME(),__cUserID,UsrFullName(__cUserID)})
		cAtuCGC := cAliasS1->ZS1_CGC
	EndIf
	

	cMailF	:= Alltrim(cAliasS1->ZS1_EMAIL)
	aMailF 	:= StrTokArr(cMailF,";")
	cMailF	:= aMailF[1]
	
	cMailC	:= Alltrim(cAliasS1->ZS1_EMAILC)
	aMailC 	:= StrTokArr(cMailC,";")
	cMailC	:= aMailc[1]
	
	aEnder		:= StrTokArr((Alltrim(cAliasS1->ZS1_RUA)),",") 
	
	If Len(aEnder) == 2
			cNumer	:= aEnder[2]
			cRua	:= aEnder[1]
		ElseIf Len(aEnder) == 1
			cRua	:= aEnder[1]
		Else
			cRua	:= aEnder[1]
			cNumer	:= Alltrim(cAliasS1->ZS1_NUMERO)
	EndIf 
	
	
	cDataNs	:= SUBSTR(cAliasS1->ZS1_DTNASC,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_DTNASC,5,2) + "/" + SUBSTR(cAliasS1->ZS1_DTNASC,1,4)
	cDatadd	:= SUBSTR(cAliasS1->ZS1_CDESDE,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_CDESDE,5,2) + "/" + SUBSTR(cAliasS1->ZS1_CDESDE,1,4)
	cDataFT	:= SUBSTR(cAliasS1->ZS1_DTFATU,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_DTFATU,5,2) + "/" + SUBSTR(cAliasS1->ZS1_DTFATU,1,4)
	cDataVc	:= SUBSTR(cAliasS1->ZS1_DTVENC,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_DTVENC,5,2) + "/" + SUBSTR(cAliasS1->ZS1_DTVENC,1,4)
	cDataPg	:= SUBSTR(cAliasS1->ZS1_DTPGPA,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_DTPGPA,5,2) + "/" + SUBSTR(cAliasS1->ZS1_DTPGPA,1,4)
	cDataSO	:= SUBSTR(cAliasS1->ZS1_DTNSOC,7,2)  + "/" + SUBSTR(cAliasS1->ZS1_DTNSOC,5,2) + "/" + SUBSTR(cAliasS1->ZS1_DTNSOC,1,4)
	
	//cLinha	:= "teste;teste;teste;12.2;8888"
		cLinha	:= 	cAliasS1->ZS1_TPPESS+";"+;
					Alltrim(cAliasS1->ZS1_CGC)	+";"+;
					Alltrim(cAliasS1->ZS1_NOME)	+";"+;
					IIF(!Empty(cAliasS1->ZS1_DTNASC),cDataNs,"")+";"+;
					Alltrim(cAliasS1->ZS1_TPSOLI)+";"+;
					cRua	+";"+;
					cNumer	+";"+;
					Alltrim(cAliasS1->ZS1_COMPLE)+";"+;
					Alltrim(cAliasS1->ZS1_BAIRRO)+";"+;
					Alltrim(cAliasS1->ZS1_CEP)	+";"+;
					Alltrim(cAliasS1->ZS1_CIDADE)+";"+;
					Alltrim(cAliasS1->ZS1_UF)	+";"+;
					Alltrim(cAliasS1->ZS1_NMCONT)+";"+;
					Alltrim(cAliasS1->ZS1_DDD)	+";"+;
					Alltrim(cAliasS1->ZS1_TEL)	+";"+;
					Alltrim(cAliasS1->ZS1_RAMAL)	+";"+;
					Alltrim(cMailF)	+";"+;
					Alltrim(cAliasS1->ZS1_DDDCEL)+";"+;
					Alltrim(cAliasS1->ZS1_TELCEL)+";"+;
					Alltrim(cMailC)+";"+;
					IIF(!Empty(cAliasS1->ZS1_CDESDE),cDatadd,"")+";"+;
					Alltrim(cAliasS1->ZS1_TPCLIE)+";"+;
					Alltrim(cAliasS1->ZS1_INFCOM)+";"+;
					Alltrim(Transform(cAliasS1->ZS1_LIMATU,"@E 999,999,999.99"))+";"+;
					"0;"+;
					Alltrim(cAliasS1->ZS1_PHISTC)+";"+;
					Alltrim(cAliasS1->ZS1_CODCOM)+";"+;
					IIF(!Empty(cAliasS1->ZS1_DTFATU),cDataFT,"")+";"+;
					Alltrim(Transform(cAliasS1->ZS1_VLRTOR,"@E 999,999,999.99"))+";"+;
					IIF(!Empty(cAliasS1->ZS1_DTVENC),cDataVc,"")+";"+;
					Alltrim(Transform(cAliasS1->ZS1_VLRPAR,"@E 999,999,999.99"))+";"+;
					IIF(!Empty(cAliasS1->ZS1_DTPGPA),cDataPg,"")+";"+;
					Alltrim(Transform(cAliasS1->ZS1_VPGPAR,"@E 999,999,999.99"))+";"+;
					Alltrim(cAliasS1->ZS1_TPPSOC)+";"+;
					Alltrim(cAliasS1->ZS1_CGCSO)+";"+;
					Alltrim(cAliasS1->ZS1_NOMESO)+";"+	IIF(!Empty(cAliasS1->ZS1_DTNSOC),cDataSO,"") +"" + cQuebra
				
	FWrite( cArqAtu, cLinha, Len(cLinha) )
	cLinha 	:= ""	
	
	DbSelectArea("ZS1")
	ZS1->(DbSetOrder(1))
	ZS1->(DbGoTop())
	ZS1->(DbGoTo(cAliasS1->RECORECO))
	RecLock("ZS1",.F.)
	ZS1->ZS1_XIDINT	:= cIdSP
	ZS1->(MsUnlock())
	
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
cDir := "\Supplier\ConcessaoLimites\"
if !ExistDir(cDir)
	//cria diretorio
	MakeDir(cDir)
endif

cNmArq := "CON-LIMITES" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt + ".csv"
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