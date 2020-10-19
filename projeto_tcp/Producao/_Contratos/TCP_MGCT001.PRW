#Include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"


User Function MGCT001

Local oXml 		:= NIL
Local cPerg := Padr("MGCT001",10)
Local oProcess

Private cCam   	:= ""

//CriaSX1(cPerg)
if !(Pergunte(cPerg))
	return
EndIF

oProcess := MsNewProcess():New({|lEnd| impXls(@oProcess, @lEnd) },"Importando registros","Lendo produtos importados",.T.)
oProcess:Activate()

Return


Static Function impXls(oProcess,lEnd)

Local nX:=1
Local nA:=1
Local aRet		   := {}
Local nxi
Private cArq       := ""
Private cArqMacro  := "XLS2DBF.XLA"
Private cTemp      := GetTempPath() //pega caminho do temp do client
Private aArquivos  := {}
Private aRet       := {}
Private cNomeA	   := ""



nPDesc	:= 01  // descricao do projeto (CN9_DESCRI)
nPManual:= 02  // Cadastro manual ( se nao for vazio o programa importará se nao ignora a linha)
nPNum	:= 03  // Numero do contrato(CN9_NUMERO)
nPPeraL := 04  // Informa período em dias, para emissão de alerta sobre o término da vigência do contrato(CN1_PRDALT)
nPRev	:= 05  // Revisão do Contrato
nPdIni	:= 06  // Data de Inicio CN9_DTINC
nTPCT   := 07  // Tipo contrato
npDtFim	:= 08  // Data Final do Contrato CN9_DTFIM
nPcgcC	:= 09 		 // CNPJ Contratante (se estiver em branco ignora o registro) posiciona na empresa durante a importacao
nPcgcF 	:= 10  // CNPJ Fornecedor (se estiver em branco ignora o registro) busca o cadastro do fornecedor
nPConPG := 11  // Condicao de Pagamento
nPind	:= 12  // Indice
nPReaj 	:= 13  // Reajuste
nPUnVig	:= 14  // Unidade de vigencia
nPVig	:= 15  // Vigencia
nPprod	:= 16  // Produto
nPQtde	:= 17  // Quantidade
nPVuni	:= 18  // Valor Unitario
nPresp	:= 19  // Responsavel (codigo do grupo)
nPobj  	:= 21  // Objeto Contratual
nPObs	:= 22  // Observações
nPSald	:= 20  // Saldo

cArq       := mv_par01
cOrigem    := cArq

lConv := convArqs(cArq)

if lConv
	aRet:=CargaArray(cArq)
Else
	return
EndIF

ncont:=LEN(aRet)
aAvisos:={}
oProcess:SetRegua1(ncont)
oProcess:SetRegua2(0)
aCont:={}
for nA:=2 TO LEN(aRet)
	
	oProcess:IncRegua1("Importando Contratos...")
	oProcess:IncRegua2("Processando "+cValtoChar(nA)+" de "+ cValtoChar(NCONT) )
	
	IF LEN(aRet[na])<nPManual
		Loop
	EndIF    
	IF LEN(aRet[na])<nPNum
		Loop
	EndIF
	if !Empty(aRet[na][nPManual]) 
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - CADASTRO MANUAL  -  "+aRet[na][nPDesc])
		Loop
	EndIF
	
	
	//VERIFICAR A EMPRESA PELA COLUNA coluna 09
	if alltrim(SM0->M0_CGC) <> alltrim(aRet[na][nPcgcC])
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Empresa invalida  -  "+alltrim(aRet[na][nPcgcC]))
		Loop 
		
	EndIf
	
	if Empty(aRet[na][1]+aRet[na][2]+aRet[na][3]+aRet[na][4])
		Loop
	EndIF
	
	if Empty(aRet[na][nPcgcC])
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" CNPJ - CONTRATANTE EM BRANCO  -  "+aRet[na][npDesc])
		Loop
	EndIF
	if Empty(aRet[na][nPcgcF])
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" CNPJ - FORNECEDOR EM BRANCO  -  "+aRet[na][npDesc])
		Loop
	EndIF
	DBSelectArea('SA2')
	DBSetOrder(3)
	if !(dbSeek(xFilial('SA2')+aRet[na][nPcgcF]))
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Fornecedor nao cadastrado  -  "+aRet[na][npDesc])
		Loop
	ENDif
	
	dbSelectArea('SB1')
	DBSetOrder(1)
	if !(dbSeek(xFilial('SB1')+aRet[na][nPprod]))
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Produto nao cadastrado  -  "+alltrim(aRet[na][npDesc])+'    ---->>> Produto: '+aRet[na][nPprod])
		Loop
	EndIF
	
	dbSelectArea('SE4')
	DBSetOrder(1)
	if !(dbSeek(xFilial('SE4')+padl(aRet[na][nPConPG],3,'0')))
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Condicao de pagamento nao cadastrado  -  "+alltrim(aRet[na][npDesc])+'    ---->>> Condicao: '+padl(aRet[na][nPConPG],3,'0'))
		Loop
	EndIF
	
	dbSelectArea('CN1')
	DBSetOrder(1)
	if !(dbSeek(xFilial('CN1')+aRet[na][nTPCT]))
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Tipo de contrato invalido  -  "+alltrim(aRet[na][npDesc])+'    ---->>> Tp.Contrato: '+aRet[na][nTPCT])
		Loop
	EndIF
	if ascan(aCont,StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+alltrim(aRet[na][nPcgcC]))==0
		aadd(aCont,StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+alltrim(aRet[na][nPcgcC]))
	ElSe
		aadd(aAvisos,STRZERO(nA,5)+'-'+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))+" - Contrato duplicado para este cnpj  -  "+alltrim(aRet[na][npDesc])+'    ---->>> Contrato: '+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO)))
		Loop
	EndIF
    

		
	DbSelectArea("CN9")
	CN9->(DbSetORder(1))
	CN9->(DbGoTop())
	
	If !CN9->(DbSeek(xFilial('CN9')+StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))))
		linc:=.t.
	Else
		linc:=.f.
	EndIF
	
	RecLock("CN9",linc)
	
	CN9->CN9_FILIAL	:= xFilial('CN9')
	CN9->CN9_NUMERO	:= StrZero(Val(aRet[na][nPNum]),Len(CN9->CN9_NUMERO))
	CN9->CN9_DESCRI	:= UPPER(NoAcento(aRet[na][nPDesc]))
	CN9->CN9_DTINIC	:= CtoD(aRet[na][nPdIni])
	CN9->CN9_DTASSI	:= CtoD(aRet[na][nPdIni])
	CN9->CN9_VIGE	:= Val(aRet[na][nPVig])
	CN9->CN9_UNVIGE	:= aRet[na][nPUnVig] 
	if aRet[na][nPUnVig]=='4'
		CN9->CN9_DTFIM 	:= CtoD('31/12/2049')
	Else
		CN9->CN9_DTFIM 	:= CtoD(aRet[na][npDtFim])
	EndIF
	CN9->CN9_CONDPG := SE4->E4_CODIGO
	CN9->CN9_TPCTO	:= aRet[na][nTPCT]
	CN9->CN9_VLINI	:= round(convnum(aRet[na][nPQtde])*convnum(aRet[na][nPVuni]),tamsx3('CN9_VLINI')[2])
	CN9->CN9_VLATU	:= round(convnum(aRet[na][nPQtde])*convnum(aRet[na][nPVuni]),tamsx3('CN9_VLATU')[2])
	CN9->CN9_FLGREJ := IIF(!Empty(Alltrim(aRet[na][nPReaj])),'1','2')
	CN9->CN9_FLGCAU := '2'
	CN9->CN9_SALDO	:= round(convnum(aRet[na][nPSald]),tamsx3('CN9_SALDO')[2])
	CN9->CN9_SITUAC := '05' 
	CN9->CN9_DTULST := dDataBase
	CN9->CN9_MOEDA 	:= 1
	CN9->CN9_TPCAUC	:= '1'
	CN9->CN9_INDICE := aRet[na][nPind]
	CN9->CN9_FILORI := xFilial('CN9')
	CN9->CN9_RESP   := aRet[na][nPresp]   		
	IF LEN(aRet[na])>=nPobj
 		_cTeste1 := NoAcento(aRet[na][nPobj])
		MSMM(CN9->CN9_CODOBJ,,,_cTeste1,1,,,"CN9","CN9_CODOBJ")	
    EndIF
   	IF LEN(aRet[na])>=nPObs
 		_cTeste := NoAcento(aRet[na][nPObs])
    	MSMM(CN9->CN9_CODCLA,,,_cTeste,1,,,"CN9","CN9_CODCLA")
    EndIF
	

	CN9->(MsUnlock())                                             
	//RegToMemory("CN9", .F., .F. )
   
	

	cCod := SA2->A2_COD
	
	dbSelectArea('CNC')
	DBSetOrder(1)
	//CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA
	cRevisa:=space(TAMSX3('CNC_REVISA')[1])
	if DBSeek(xFilial('CNC')+StrZero(Val(aRet[na][nPNum]),15)+cRevisa+SA2->A2_COD+SA2->A2_LOJA)
		RecLock("CNC",.f.)
	Else
		RecLock("CNC",.T.)
	EndIF
	CNC->CNC_FILIAL	:= xFilial('CNC')
	CNC->CNC_NUMERO	:= StrZero(Val(aRet[na][nPNum]),15)
	CNC->CNC_CODIGO	:= SA2->A2_COD
	CNC->CNC_LOJA	:= SA2->A2_LOJA
	CNC->(MsUnlock())
	
	
	dbSelectArea('CNA')
	DBSetOrder(1)
	//CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA
	cRevisa:=space(TAMSX3('CNC_REVISA')[1])
	if DBSeek(xFilial('CNA')+StrZero(Val(aRet[na][nPNum]),15)+cRevisa+"000001")
		RecLock("CNA",.f.)
	Else
		RecLock("CNA",.T.)
	EndIF
	
	CNA->CNA_FILIAL	:= xFilial('CNA')
	CNA->CNA_CONTRA	:= StrZero(Val(aRet[na][nPNum]),15)
	CNA->CNA_NUMERO	:= "000001"
	CNA->CNA_FORNEC	:= SA2->A2_COD
	CNA->CNA_LJFORN	:= SA2->A2_LOJA
	CNA->CNA_DTINI	:= CtoD(aRet[na][nPdIni])
	CNA->CNA_VLTOT	:= round(convnum(aRet[na][nPQtde])*convnum(aRet[na][nPVuni]),tamsx3('CNA_VLTOT')[2])
	CNA->CNA_SALDO	:= round(convnum(aRet[na][nPSald]),tamsx3('CNA_SALDO')[2])
	
	if aRet[na][nPUnVig]=='4'
		CNA->CNA_DTFIM 	:= CtoD('31/12/2049')
	Else
		CNA->CNA_DTFIM 	:= CtoD(aRet[na][npDtFim])
	EndIF
	CNA->CNA_TIPPLA	:= "001"
	CNA->CNA_FLREAJ := IIF(!Empty(Alltrim(aRet[na][nPReaj])),'1','2')
	CNA->(MsUnlock())
	
	
	dbSelectArea('CNB')
	DBSetOrder(1)
	//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
	cRevisa:=space(TAMSX3('CNB_REVISA')[1])
	if DBSeek(xFilial('CNB')+StrZero(Val(aRet[na][nPNum]),15)+cRevisa+"000001"+"001")
		RecLock("CNB",.f.)
	Else
		RecLock("CNB",.T.)
	EndIF
	
	CNB->CNB_FILIAL	:= xFilial('CNA')
	CNB->CNB_CONTRA	:= StrZero(Val(aRet[na][nPNum]),15)
	CNB->CNB_NUMERO	:= "000001"
	CNB->CNB_ITEM	:= "001"
	CNB->CNB_PRODUT	:= aRet[na][nPprod]
	CNB->CNB_DESCRI	:= Posicione('SB1',1,xFilial('SB1')+aRet[na][nPprod],"B1_DESC")
	CNB->CNB_UM		:= SB1->B1_UM
	CNB->CNB_QUANT	:= round(convnum(aRet[na][nPQtde]),tamsx3('CNB_QUANT')[2])
	CNB->CNB_VLUNIT	:= round(convnum(aRet[na][nPVuni]),tamsx3('CNB_VLUNIT')[2])
	CNB->CNB_VLTOT	:= round(convnum(aRet[na][nPQtde])*convnum(aRet[na][nPVuni]),tamsx3('CNB_VLTOT')[2])
	CNB->CNB_DTANIV	:= dDataBase
	CNB->CNB_DTCAD	:= dDataBase
	CNB->CNB_SLDMED	:= round(convnum(aRet[na][nPSald]),tamsx3('CNB_SLDMED')[2])/round(convnum(aRet[na][nPVuni]),tamsx3('CNB_VLUNIT')[2])
	//		CNB->CNB_SLDERC	:= num(aLinha[nI][1][16])
	CNB->(MsUnlock())
	
	If !CNN->(DbSeek(xFilial('CNN') + '000000'+ CN9->CN9_NUMERO))
		RecLock('CNN', .T.)
		CNN_FILIAL := CN9->CN9_FILIAL
		CNN_CONTRA := CN9->CN9_NUMERO
		CNN_USRCOD := '000000'
		CNN_GRPCOD := ''
		CNN_TRACOD := '001'
		CNN->(MsUnlock())
	EndIF
	
	
	If !CNN->(DbSeek(xFilial('CNN') + '000621' + CN9->CN9_NUMERO))
		RecLock('CNN', .T.)
		CNN_FILIAL := CN9->CN9_FILIAL
		CNN_CONTRA := CN9->CN9_NUMERO
		CNN_USRCOD := '000621'
		CNN_GRPCOD := ''
		CNN_TRACOD := '001'
		CNN->(MsUnlock())
	EndIF
	
	If !CNN->(DbSeek(xFilial('CNN') +'000451' + CN9->CN9_NUMERO))
		RecLock('CNN', .T.)
		CNN_FILIAL := CN9->CN9_FILIAL
		CNN_CONTRA := CN9->CN9_NUMERO
		CNN_USRCOD := '000451'
		CNN_GRPCOD := ''
		CNN_TRACOD := '001'
		CNN->(MsUnlock())
	EndIF
	
	
	
	
	//Busca os usuários responsaveis do grupo
	DbSelectArea('ZZD')
	If ZZD->(DbSeek(xFilial('ZZD') + CN9->CN9_RESP ))
		
		While ZZD->ZZD_GRUPO = CN9->CN9_RESP
			
			If !CNN->(DbSeek(xFilial('CNN') + ZZD->ZZD_USER + CN9->CN9_NUMERO))
				
				RecLock('CNN', .T.)
				CNN_FILIAL := CN9->CN9_FILIAL
				CNN_CONTRA := CN9->CN9_NUMERO
				CNN_USRCOD := ZZD->ZZD_USER
				CNN_GRPCOD := ''
				CNN_TRACOD := '020'
				CNN->(MsUnlock())
				//Libera visualização dos contratos
				RecLock('CNN', .T.)
				CNN_FILIAL := CN9->CN9_FILIAL
				CNN_CONTRA := CN9->CN9_NUMERO
				CNN_USRCOD := ZZD->ZZD_USER
				CNN_GRPCOD := ''
				CNN_TRACOD := '037'
				CNN->(MsUnlock())
				
			EndIf     
			
			ZZD->(DbSkip())
		EndDo 
		aadd(aAvisos,"Registro importado  -  "+StrZero(Val(aRet[na][nPNum]),15)+"-"+alltrim(aRet[na][npDesc]))
				
	EndIf   
	
Next
cAux:=""
for nxi:=1 to len(aAvisos)
	cAux+=aAvisos[nxi]+chr(13)+chr(10)
next

If !Empty(cAux)
	cTime:=strtran(time(),':',"_")
	memowrite(alltrim(mv_par02)+DTOS(ddatabase)+ctime+'.txt',cAux)
	if Aviso("Ocorrencias","A importacao gerou ocorrencias e foram gravadas no seguinte diretorio: "+chr(13)+chr(10)+alltrim(mv_par02)+DTOS(ddatabase)+cTime+'.txt',{"ok","Abrir"})==2
		shellExecute( "Open",alltrim(mv_par02)+DTOS(ddatabase)+ctime+'.txt', "", "C:\", 1 )
	EndIF
	
EndIf


Return

*-------------------------*
Static Function convArqs(cArq)
*-------------------------*
Local oExcelApp
Local cNomeXLS  := ""
Local cFile     := ""
Local i         := 1
Local j         := 1
Local aExtensao := {}
Local cDrive, cDir, cNome, cExt



//recebe o nome do arquivo corrente
SplitPath( cArq, @cDrive, @cDir, @cNome, @cExt )
If !File(cArq)
	Return .F.
EndIf


cNomeXLS := AllTrim(cNome)+cExt
cFile    := cArq


//verifica se existe o arquivo na pasta temporaria e apaga
If File(cTemp+cNome+cExt)
	fErase(cTemp+cNome+cExt)
EndIf

//Copia o arquivo XLS para o Temporario para ser executado
If !AvCpyFile(cFile,cTemp+cNome+cExt,.F.)
	Return .F.
EndIf

//apaga macro da pasta temporária se existir
If File(cTemp+cArqMacro)
	fErase(cTemp+cArqMacro)
EndIf

//Copia o arquivo XLA para o Temporario para ser executado
If !AvCpyFile('/sigaadv/'+cArqMacro,cTemp+cArqMacro,.F.)
	Return .F.
EndIf

//Exclui o arquivo antigo (se existir)
If File(cTemp+cNomeXLS+".csv")
	fErase(cTemp+cNomeXLS+".csv")
EndIf

//Inicializa o objeto para executar a macro
oExcelApp := MsExcel():New()
//define qual o caminho da macro a ser executada
oExcelApp:WorkBooks:Open(cTemp+cArqMacro)
//executa a macro passando como parametro da macro o caminho e o nome do excel corrente

oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNome+cExt)
//fecha a macro sem salvar
oExcelApp:WorkBooks:Close('savechanges:=False')
//sai do arquivo e destrói o objeto
oExcelApp:Quit()
oExcelApp:Destroy()

//Exclui o Arquivo excel da temp
fErase(cTemp+cNomeXLS)
fErase(cTemp+cArqMacro) //Exclui a Macro no diretorio temporario
//
Return .T.



*-------------------------*
Static Function CargaArray(cArq)
*-------------------------*
Local cLinha  := ""
Local nLin    := 1
Local nTotLin := 0
Local aDados  := {}
Local cFile   := "" //cTemp + substr(cArq,1,len(cArq)-4) + ".csv"
Local nHandle := 0
Local cDrive, cDir, cNome, cExt


SplitPath( cArq, @cDrive, @cDir, @cNome, @cExt )
cFile:=cTemp+cNome+ ".csv"
If !File(cFile)
	Return .F.
EndIf
//abre o arquivo csv gerado na temp
nHandle := Ft_Fuse(cFile)
If nHandle == -1
	Return aDados
EndIf
Ft_FGoTop()

//percorre todas linhas do arquivo csv
Do While !Ft_FEof()
	//exibe a linha a ser lida
	//le a linha
	cLinha := Ft_FReadLn()
	//verifica se a linha está em branco, se estiver pula
	If Empty(AllTrim(StrTran(cLinha,';','')))
		Ft_FSkip()
		Loop
	EndIf
	//transforma as aspas duplas em aspas simples
	cLinha := StrTran(cLinha,'"',"'")
	cLinha := '{"'+cLinha+'"}'
	//adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array
	cLinha := StrTran(cLinha,';','","')
	aAdd(aDados, &cLinha)
	
	//passa para a próxima linha
	FT_FSkip()
	//
EndDo

//libera o arquivo CSV
FT_FUse()

//Exclui o arquivo csv
If File(cFile)
	FErase(cFile)
EndIf

Return aDados

Static Function convnum(cNum)
cNum:=strtran(cNum,'R','')
cNum:=strtran(cNum,'$','')
cNum:=strtran(cNum,' ','')
cNum:=strtran(cNum,'.','')
cNum:=strtran(cNum,',','.')

Return val(cNum)

/*static Function CriaSX1(cPerg)
//PutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .xls","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Diretório?","Diretório?","Diretório?","mv_ch2","C",99,0,0,"G","","HSSDIR","","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")
Return*/



static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString
