#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97A06		|	Autor: Luis Paulo							|	Data: 26/08/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por processar os registro pendentes de envio para  supplier		//
//																									//
//==================================================================================================//
User Function KP97A06()
Local cQr 			:= ""
Local cAliasS1		:= GetNextAlias()
Local lRet			:= .T.
Local nRegs			:= 0
Local cLinha		:= ""
Local nCount		:= 0

If Select("cAliasS1")<>0
	DbSelectArea("cAliasS1")
	DbCloseArea()
Endif

cQr += " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM "+ RetSqlName("ZS3") +" ZS3 "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZS3_XIDINT = ''

// abre a query
TcQuery cQr new alias "cAliasS1"

DbSelectArea("cAliasS1")
cAliasS1->(DbGoTop())

If cAliasS1->(EOF())
		MsgInfo("Nao existem dados!!","KAPAZI - SUPPLIER CARD")
	Else
		
		If FM_Direct( cDirProc, .F., .F. )	//Caso nao tenha o diretorio Supplier, criaa
			cArqAtu	:= KP97IRBL() 			//Cria o arquivo CSV -- Descontinuado o CSV, somente esta ativo o nome do arquivo
			lCriou	:= .T.
			cIdSP	:= GetSx8Num("ZS3", "ZS3_XIDINT","ZS3_XIDINT" + "\system\"+RetSqlName("ZS3"),1)
			ConfirmSx8()
			xGeraXml()
		EndIf
		
EndIf


/*
While !cAliasS1->(EOF()) .And. lCriou
	
	
	nCount++
	If nCount == 1 //Grava o cabecalho
		cLinha	:= 	"COD SOLICITACAO;"+;
					"CNPJ;"+;
					"CNPJ KAPAZI;"+;
					"TIPO DE TRANSACAO;"+;
					"CODIGO DO PEDIDO;"+;
					"VALOR DO PEDIDO;"+;
					"QTD DE PARCELAS;"+;
					"DIAS PRI VENCIMENTO;"+;
					"CONDICAO;"+;
					"QTD DE DIAS ENTRE PARC;"+;
					"TAXA CLIENTE;"+;
					"TAXA ANTECIPACAO;"+;
					"TAXA PARCEIRO;"+;
					"FORMA DE RECEBIMENTO;"+;
					"PRAZO DE RECEBIMENTO;"+;
					"Obs" + cQuebra
			FWrite( cArqAtu, cLinha, Len(cLinha) )
			cLinha 	:= ""
	EndIf
	
	//cLinha	:= "teste;teste;teste;12.2;8888"
	cLinha	:= 	cAliasS1->ZS3_CODSOL+";"+;
				Alltrim(cAliasS1->ZS3_CGC)	+";"+;
				Alltrim(cAliasS1->ZS3_CGCK)	+";"+;
				Alltrim(cAliasS1->ZS3_TIPOTR)+";"+;
				Alltrim(cAliasS1->ZS3_CODPVS)+";"+;
				Alltrim(Transform(cAliasS1->ZS3_VALPV,"@E 999,999,999.99"))+";"+;
				Alltrim(cAliasS1->ZS3_QTDPAR)+";"+;
				Alltrim(cAliasS1->ZS3_DPRIVE)+";"+;
				Alltrim(cAliasS1->ZS3_CONDSP)+";"+;
				Alltrim(cAliasS1->ZS3_QTDDEP)+";"+;
				Alltrim(cAliasS1->ZS3_TXCLI)+";"+;
				Alltrim(cAliasS1->ZS3_TXAPAR)+";"+;
				Alltrim(cAliasS1->ZS3_TXPPAR)+";"+;
				Alltrim(cAliasS1->ZS3_FORREC)+";"+;
				Alltrim(cAliasS1->ZS3_PRECPA)+";"+;
				Alltrim(cAliasS1->ZS3_OBS)+"" + cQuebra
				
	FWrite( cArqAtu, cLinha, Len(cLinha) )
	cLinha 	:= ""	
	
	DbSelectArea("ZS3")
	ZS3->(DbSetOrder(1))
	ZS3->(DbGoTop())
	ZS3->(DbGoTo(cAliasS1->RECORECO))
	RecLock("ZS3",.F.)
	ZS3->ZS3_XIDINT	:= cIdSP
	ZS3->(MsUnlock())
	
	cAliasS1->(DbSkip())
EndDO

If lCriou
	FT_FGoto((FT_FLastRec()))	//Vai para ultima linha
	FT_FUse() 					//Fecha o arquivo
	
	If !FCLOSE(cArqAtu)
		Conout( "Erro ao fechar arquivo, erro numero: " + STR(FERROR()) )
	EndIf
	KP97ABAR(cNmArq, cDir) //exibe arquivo de log
	
EndIf
*/
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
cDir := "\Supplier\PedidosdeVenda\"
if !ExistDir(cDir)
	//cria diretorio
	MakeDir(cDir)
endif

//cNmArq := "PED-VENDA" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt + ".csv"
cNmArq := "PED-VENDA" + DTOS(DATE()) + SUBSTR(TIME(),1,2) + SUBSTR(TIME(),4,2) + "-" +cEmpAnt+cFilAnt+".xml"
//nHdlLog := msFCreate( Alltrim(cDir+cNmArq) ) Vai ser gerado XML
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


Static Function xGeraXml()
Local 	oExcel
Local 	cDir    	:= "C:\TEMP\"
Local 	cArq    	:= ""
Local 	nLinha		:= 1
Local 	_cCad		:= "Gerar XML"
Local 	_cDirTmp 	:= ""	//:= "C:\TEMP\"
Local 	_cDir 		:= "\Supplier\PedidosdeVenda\" //GetSrvProfString("Startpath","")
Local 	_cHour		:= ""
Local 	_cMin		:= ""
Local 	_cSecs		:= ""
Local 	cValor
Local cDirectory	:= ""

_cDirTmp := ALLTRIM(cGetFile("Salvar em?|*|",'Salvar em?', 0,'c:\Temp\', .T., GETF_OVERWRITEPROMPT + GETF_LOCALHARD + GETF_RETDIRECTORY,.T.))

_cTime := Time() // Resultado: 10:37:17
_cHour := SubStr( _cTime, 1, 2 ) // Resultado: 10
_cMin  := SubStr( _cTime, 4, 2 ) // Resultado: 37
_cSecs := SubStr( _cTime, 7, 2 ) // Resultado: 17
_cTimeF	:=_cHour+_cMin+_cSecs

cArq    	:= cNmArq

oExcel := FWMsExcel():New()		//Instancia a classe
	
oExcel:AddworkSheet("SUPPLIER CARD")							//Adiciona uma Worksheet ( Planilha "Pasta de Trabalho" )
oExcel:AddTable ("SUPPLIER CARD","PEDIDOS")						//Adiciona uma tabela na Worksheet. Uma WorkSheet pode ter apenas uma tabela
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","COD SOLICITACAO"		,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","CNPJ"					,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","CNPJ KAPAZI"  			,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","TIPO DE TRANSACAO"		,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","CODIGO DO PEDIDO"		,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","VALOR DO PEDIDO"		,2,3)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","QTD DE PARCELAS"		,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","DIAS PRI VENCIMENTO"	,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","CONDICAO"				,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","QTD DE DIAS ENTRE PARC"	,2,1)

oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","TAXA CLIENTE"			,2,2)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","TAXA ANTECIPACAO"		,2,2)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","TAXA PARCEIRO"			,2,2)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","FORMA DE RECEBIMENTO"	,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","PRAZO DE RECEBIMENTO"	,2,1)
oExcel:AddColumn("SUPPLIER CARD","PEDIDOS","OBS"					,2,1)

/*
oExcel:SetFont('Arial')
oExcel:SetFontSize(10)
oExcel:SetTitleBold(.T.)
oExcel:SetTitleSizeFont(16)
oExcel:SetHeaderBold(.T.)
oExcel:SetHeaderSizeFont(14)
oExcel:SetBold(.T.)
*/
ProcRegua(0)
While !cAliasS1->(EOF()) .And. lCriou
	IncProc()
	
	cValor		:= Alltrim(Transform(cAliasS1->ZS3_VALPV,"@E 999,999,999.99"))
	oExcel:AddRow("SUPPLIER CARD","PEDIDOS"	,{	Alltrim(cAliasS1->ZS3_CODSOL),;
												Alltrim(cAliasS1->ZS3_CGC),;
												Alltrim(cAliasS1->ZS3_CGCK),;
												Alltrim(cAliasS1->ZS3_TIPOTR),;
												Alltrim(cAliasS1->ZS3_CODPVS),;
												cValor,;
												Alltrim(cAliasS1->ZS3_QTDPAR),;
												Alltrim(cAliasS1->ZS3_DPRIVE),;
												Alltrim(cAliasS1->ZS3_CONDSP),;
												Alltrim(cAliasS1->ZS3_QTDDEP),;
												Alltrim(cAliasS1->ZS3_TXCLI),;
												Alltrim(cAliasS1->ZS3_TXAPAR),;
												Alltrim(cAliasS1->ZS3_TXPPAR),;
												Alltrim(cAliasS1->ZS3_FORREC),;
												Alltrim(cAliasS1->ZS3_PRECPA),;
												Alltrim(cAliasS1->ZS3_OBS)})
												
	DbSelectArea("ZS3")
	ZS3->(DbSetOrder(1))
	ZS3->(DbGoTop())
	ZS3->(DbGoTo(cAliasS1->RECORECO))
	RecLock("ZS3",.F.)
	ZS3->ZS3_XIDINT	:= cIdSP
	ZS3->ZS3_NMARQI	:= cNmArq
	ZS3->(MsUnlock())
	
	DbSelectArea("SC5")
	SC5->(DbGoTop())
	SC5->(DbGoTo(cAliasS1->ZS3_RECSC5))
	RecLock("SC5",.F.)
	SC5->C5_XSTSSPP	:= "2"
	SC5->(MsUnlock())
	
	cAliasS1->(DbSkip())

EndDo

oExcel:Activate() 				//Habilita o uso da classe, indicando que esta configurada e pronto para uso
	
LjMsgRun( "Gerando o arquivo, aguarde...", _cCad, {|| oExcel:GetXMLFile( ( (_cDir) + cArq) ) } )//Cria um arquivo no formato XML do MSExcel 2003 em diante 

//oExcel:GetXMLFile("TESTE.xml")	//Arquivo teste.xml gerado com sucesso no \system\

If __CopyFile( ( (_cDir) + cArq), _cDirTmp + cArq )

	//oExcelApp := MsExcel():New()
	//oExcelApp:WorkBooks:Open( _cDirTmp + cArq )
	//oExcelApp:SetVisible(.T.)

	ELSE
	
	MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diretório " + _cDir )
	MsgInfo( "Arquivo não copiado para temporário do usuário." )

Endif
	
Return()
