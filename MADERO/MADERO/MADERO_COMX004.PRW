#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+ 
!Módulo            ! Estoque / Custos                                        !
+------------------+---------------------------------------------------------+
!Nome              ! ESTR016                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Cadastro de CFOP x TES				 	                 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 27/05/2020                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!PUTSX1 customizado							!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function COMX004()

	Local oDlg := NIL 
	Local oFilBase
	Local cFilBase := ZTB->ZTB_FILIAL
	Local oFilCopy
	Local cFilCopy := SPACE(10)
	Local dDataAte  := Date()-1 
	Local nDisp,nTotal := 0 
	Local lRet  := .T.

	Private lHabilita := .T.
	Private lMark := .T.
	Private oFont14 := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)
	Private oLista  := NIL
	Private aVetLis := {}  
	Private aInfoRet1:= {} 
	Private cVar := NIL
	Private aTotal := {}
	Private oOk := LoadBitmap( GetResources(),"LBOK")
	Private oNo := LoadBitmap( GetResources(),"LBNO")

	// Monta a tela  
	DEFINE MSDIALOG oDlg TITLE "Cópia Automática de CFOP" FROM 001,001 TO 535,840 PIXEL
	@ 015,006 SAY "Filial Origem: " SIZE 50, 07 PIXEL OF oDlg
	@ 012,045 MSGET oFilBase  VAR cFilBase PICTURE PesqPict("ZTB","ZTB_FILIAL") SIZE 50,12 WHEN .F. OF oDlg PIXEL
	@ 015,110 SAY "Filial Destino: "SIZE 50, 07 PIXEL OF oDlg
	@ 1.0,037 BUTTON oBtnMark PROMPT "Selec.Filial" SIZE 50,15  WHEN lHabilita OF oDlg ACTION {||GetFilDest()}
	@ 24.7,003 BUTTON oBtnMark PROMPT "Marca/Desmarca" SIZE 45,12 OF oDlg ACTION {||MARCA()}
	@ 035,005 SAY "Lista de CFOP´S" SIZE 350,7 FONT oFont14  PIXEL OF oDlg
	@ 045,005 LISTBOX oLista VAR cVar FIELDS HEADER " ","Filial","CFOP","TES";
	COLSIZES 05,15,15,15,70 SIZE 410,195 OF oDlg PIXEL ON dblClick(aVetLis[oLista:nAt,1] := !aVetLis[oLista:nAt,1])
	DEFINE SBUTTON FROM 250,355 TYPE 1 ACTION Iif(PROCESSAR(@cFilBase),oDlg:End(),Nil) ENABLE OF oDlg
	DEFINE SBUTTON FROM 250,388 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	GetCFOP(cFilBase)
	If Len(aVetLis)==0
		aAdd(aVetLis,{lMark,"","",""})
	Endif

	// Inicializa a lista                    
	oLista:SetArray( aVetLis )
	oLista:bLine := {||{Iif(aVetLis[oLista:nAt,1],oOk,oNo),	aVetLis[oLista:nAt,2],;
	aVetLis[oLista:nAt,3],;
	aVetLis[oLista:nAt,4],;
	}}
	oLista:nAt := 1
	oLista:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED
Return lRet

Static Function MARCA()
	Local i
	If Len(aVetLis)> 0
		For i:=1 to Len(aVetLis)
			aVetLis[i,1] := !aVetLis[i,1]	
		Next
	Else
		aAdd(aVetLis,{lMark,"","",""})
	EndIf

Return 

Static Function GetCFOP(cFilBase)
	Local cQuery := ""
	Local cCFOP := ""
	Local cTes := ""
	Local lApaga := .F.
	aVetLis := {} 

	dbSelectArea("ZTB")
	ZTB->(dbSetOrder(01))
	ZTB->(dbGoTop())
	ZTB->(dbSeek(cFilBase))
	While !ZTB->(EOF()).And. ZTB->ZTB_FILIAL = cFilBase 
		cTes := ""
		cQuery := " SELECT ZTC_TES  FROM "+RetSQLName("ZTC")+" A "
		cQuery += " WHERE A.D_E_L_E_T_=' ' "
		cQuery += " AND ZTC_FILIAL = '"+ZTB->ZTB_FILIAL+"' "
		cQuery += " AND ZTC_CFOP = '"+ZTB->ZTB_CFOP+"'"
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)
		dbSelectArea("QRY")
		QRY->(dbGotop())
		While !QRY->(eof()) 	
			cTes +=QRY->ZTC_TES+";"
			QRY->(dbSkip())  
		EndDo
		QRY->(DBCloseArea())
		aAdd(aVetLis,{lMark,ZTB->ZTB_FILIAL,ZTB->ZTB_CFOP,substr(cTes,1,len(cTes)-1)})
		ZTB->(dbSkip())
	EndDo 
	If Len(aVetLis)>0
		//Posiciona no topo e atualiza grid
		oLista:SetArray(aVetLis)
		oLista:bLine := {||{Iif(aVetLis[oLista:nAt,1],oOk,oNo),;
		aVetLis[oLista:nAt,2],;
		aVetLis[oLista:nAt,3],;
		aVetLis[oLista:nAt,4],;
		}}
		oLista:nAt := 1
		oLista:Refresh()
		lHabilita := .T.
	Else
		MsgAlert("Não existe CFOP cadastrada para esta filial.")
	EndIf

Return
Static Function PROCESSAR(cFilBase)
	Local lRet := .F.
	Local lMarca := .F.
	Local nCount := 0
	Local nSoma := 0

	If 	len(aInfoRet1)==0
		MsgAlert("Nenhuma Filial de Destino foi selecionada!")
		If Len(aVetLis) ==0//array com as CFOP´S
			aAdd(aVetLis,{lMark,"","",""})
		EndIf
		lRet := .F.
	Else
		For i:=1 to Len(aVetLis)//array com as CFOP´S
			If aVetLis[i,1] == .T.
				lMarca := .T.
				Exit
			EndIf 
		Next
		If lMarca
			If MsgYesNo("A Copia de CFOP da filial " +Alltrim(cFilBase)+ " será efetuada. Confirma?")

				//INICIAR O PROCESSO DE GRAVAÇÃO PARA AS FILIAIS SELECIONADAS
				For i:=1 to Len(aInfoRet1)//array com as FILIAIS
					nCount:= 0
					Begin Transaction
						//INICIAR A COPIA DA CFOP SELECIONADA PARA A FILIAL SELECIONADA ACIMA
						For j:=1 to Len(aVetLis)//array com as CFOP´S
							If aVetLis[j,1] == .T.
								nSoma++
								//Verifica se a CFOP e TES ja existem para a filial a ser copiada 
								DbSelectArea("ZTB")//cABEÇALHO CFOP x TES
								ZTB->(DBSetOrder(1))
								If ZTB->(DBSeek(aInfoRet1[i][2]+aVetLis[j,3]))//ja existe a CFOP. 

									//Verifica quantas tes existem para cada CFOP e apaga estas TES
									aArray := StrTokArr(Alltrim(aVetLis[j,4]),";")
									for k := 1 to Len( aArray )
										//Apaga a ZTC com as TES anteriores que não estão na nova lista de TES
										DbSelectArea("ZTC")//ITENS CFOP x TES
										ZTC->(DBSetOrder(1))//ZTC_FILIAL+ZTC_CFOP+ZTC_TES
										If ZTC->(DBSeek(aInfoRet1[i][2]+aVetLis[j,3]+aArray[k]))//ja existe a tes. 
											While !ZTC->( Eof() ) .And. ZTC->ZTC_FILIAL = aInfoRet1[i][2] .AND.  ZTC->ZTC_CFOP = aVetLis[j,3]
												RecLock("ZTC", .F.)	
												ZTC->( dbDelete() )
												ZTC->(MsUnlock())
												lApaga := .T.
												ZTC->(dbSkip())
											EndDo
										EndIf
									next k
									//GRAVA novamente a TES na tabela ZTC
									If lApaga
										for k := 1 to Len( aArray )
											//Verifica se TES existe na filial selecionada
											DbSelectArea("SF4")
											SF4->(DBSetOrder(1))//F4_FILIAL+F4_CODIGO
											If SF4->(DBSeek(aInfoRet1[i][2]+aArray[k]))
												//ITENS CFOP x TES
												RecLock("ZTC", .T.)	
												ZTC->ZTC_FILIAL := aInfoRet1[i][2]
												ZTC->ZTC_CFOP := aVetLis[j,3]
												ZTC->ZTC_TES := aArray[k]	
												ZTC->(MsUnlock()) // Confirma e finaliza a operação
											Else
												aAdd(aTotal,"TES "+aArray[k]+" não esta cadastrada para a filial "+aInfoRet1[i][2]+"")
											EndIf
										next
									endIf
									nCount++
								Else//NÃO existe a CFOP

									//GRAVA COM RECLOCK. NAO EXISTE EXECAUTO PARA ESTA AMARRAÇÃO
									RecLock("ZTB", .T.)	
									ZTB->ZTB_FILIAL :=  aInfoRet1[i][2]	
									ZTB->ZTB_CFOP := aVetLis[j,3]	
									ZTB->(MsUnlock()) // Confirma e finaliza a operação
									//Verifica quantas tes existem para cada CFOP
									aArray := StrTokArr(Alltrim(aVetLis[j,4]),";")
									for k := 1 to Len( aArray )
										//Verifica se TES existe na filial selecionada
										DbSelectArea("SF4")
										SF4->(DBSetOrder(1))//F4_FILIAL+F4_CODIGO
										If SF4->(DBSeek(aInfoRet1[i][2]+aArray[k]))
											//ITENS CFOP x TES
											RecLock("ZTC", .T.)	
											ZTC->ZTC_FILIAL := aInfoRet1[i][2]
											ZTC->ZTC_CFOP := aVetLis[j,3]
											ZTC->ZTC_TES := aArray[k]	
											ZTC->(MsUnlock()) // Confirma e finaliza a operação
										Else
											aAdd(aTotal,"TES "+aArray[k]+"não esta cadastrada para a filial "+aInfoRet1[i][2]+"")
										EndIf
									next
									nCount++
								EndIf
							EndIf
						Next j
						aAdd(aTotal,"Total cfop´s incluidas para a filial "+aInfoRet1[i][2]+"= "+Alltrim(Str(nCount)) )
					End Transaction
				Next i

				lRet := .T.
			EndIf
		Else
			MsgAlert("Nenhuma CFOP foi selecionada!")
		EndIf
	EndIf
	If lRet
		If nCount > 0
			MsgAlert("Foram criados "+PADL(ALLTRIM(STR(nSoma)),2,"0")+" CFOP´s .Verifique o Log.")
		Else
			MsgAlert("Nenhuma CFOP foi criada .Verifique o Log.")
		EndIf
		fSalvArq()
	EndIf

Return lRet

Static Function GetFilDest()

	aInfoRet1 := FwListBranches()

Return
/*-----------------------------------------------*
| Função: fSalvArq                              |
| Descr.: Função para gerar um arquivo texto    |
*-----------------------------------------------*/

Static Function fSalvArq()
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".TXT"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	Local nX := 0

	//Pegando o caminho do arquivo
	cFileNom:= cGetFile( '*.txt|*.txt' , 'Selecione a pasta para gerar o arquivo', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
		cArqCPag := cFileNom+"Log_CFOPxTES.txt"
		//Montando a mensagem
		cTexto := "Função:"+ FunName()
		cTexto += " Usuário:"+ cUserName
		cTexto += " Data:"+ dToC(dDataBase)
		cTexto += " Hora:"+ Time() + cQuebra  + "Log de Erros" + cQuebra
		For nX := 1 To Len(aTotal)
			cTexto +=aTotal[nX]+ CRLF
		Next nX

		//Testando se o arquivo já existe
		If File(cArqCPag)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cArqCPag, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cArqCPag,"Atenção")
		EndIf
	EndIf
Return
