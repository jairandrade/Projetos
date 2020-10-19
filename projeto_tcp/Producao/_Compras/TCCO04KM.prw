#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCCO04KM
Rotina responsavel por realizar a amarracao de documento x entidade
automaticamente ao incluir/classificar o documento de entrada.
@author  Kaique Sousa
@since   1.0
@version version
/*/
//-------------------------------------------------------------------

User Function TCCO04KM()
    
    Local aArea := GetArea()
    Local lMacOS:= .F.
    Local cLibCli	 := "" 
    
    GetRemoteType( @cLibCli )
    lMacOS := Iif('MAC' $ cLibCli,.T.,.F.)  

    Private cSep:= If(lMacOS, "/", "\")

    //Gero o relatorio 
    u_Matr110( 'SC7', SC7->(RECNO()), 2, '' )

    //Anexo no GED
    lAnexo := u_DocGrvGED( GetTempPath() + cSep + "totvsprinter" + cSep + "pc"+SC7->C7_NUM+".pdf","pc"+SC7->C7_NUM+".pdf" )

    //Apago o arquivo da pasta temp
    FErase( GetTempPath() + cSep + "totvsprinter" + cSep + "PC"+SC7->C7_NUM+".pdf" )

    RestArea(aArea)

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} TCCO04KM
Função responsavel por persistir os dados 
@author  Kaique Sousa
@since   1.0
@version version
/*/
//-------------------------------------------------------------------


User Function DocGrvGED(cAnexo, cFileName)
    
    Local aArea		:= GetArea()
    
    Local nPos 		:= RAt(If(IsSrvUnix(), "/", "\"), cFileName)
    Local nPos2		:= 0
    Local cDirDoc	:= MsDocPath()
    Local cAnexoGrv	:= Upper(SubStr( cFileName , nPos+1 ))
    Local nCount	:= 1

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Busca por um nome de arquivo nao utilizado, incrementando o arquivo        ³
    //³com um sequencial ao final do nome, exemplo: arquivo(1).txt, arquivo(2).txt³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("ACB")
    ACB->(DbSetOrder(2)) //ACB_FILIAL+ACB_OBJETO

    While DbSeek(xFilial("ACB") + AllTrim(SubStr( cAnexoGrv , nPos+1 )))
        nPos2		:= Rat(".",cAnexoGrv)
        cAnexoGrv	:= SubStr(cAnexoGrv,1,nPos2-1)+"("+cValToChar(nCount)+")"+SubStr(cAnexoGrv,nPos2,Len(cAnexoGrv))
        nCount++
    End
    
    __CopyFile(cAnexo, cDirDoc + "\" + cAnexoGrv )

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Inclui registro no banco de conhecimento³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    _nCodAcb := proxAcb()
    RecLock("ACB",.T.)
    ACB->ACB_FILIAL := xFilial("ACB")
    ACB->ACB_CODOBJ := _nCodAcb
    ACB->ACB_OBJETO	:= Upper(cAnexoGrv)
    ACB->ACB_DESCRI	:= Upper(SubStr(cFileName,1,Rat(".",cAnexoGrv)-1))
    MsUnLock()

    ConfirmSx8()

    cEntidade := getEntidade()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Inclui amarração entre registro do banco e entidade³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cUnico := Posicione('SX2',1,cEntidade,'X2_UNICO')
    
    cUnico := StrTran( cUnico, '+CND_REVISA', '')
    
    RecLock("AC9",.T.)
    AC9->AC9_FILIAL	:= xFilial("AC9")
    AC9->AC9_FILENT	:= xFilial("SC7") 
    AC9->AC9_ENTIDA	:= cEntidade
    AC9->AC9_CODENT	:= (cEntidade)->(&(cUnico))
    AC9->AC9_CODOBJ	:= ACB->ACB_CODOBJ
    MsUnLock()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TCCO04KM
Função responsavel por retornar a entidade do documento a ser anexado
@author  Kaique Sousa
@since   1.0
@version version
/*/
//-------------------------------------------------------------------

Static function getEntidade() 

    Local cAlias := "SF1"
    Local cAlDoc := "SC7"   

    //Busca Solicitação de Compras pela NF Entrada
	If cAlias == 'SF1'	
				
		//Busca Item de NF de Entrada
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		
			//Busca Pedido de Compra
			DbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				
				if !Empty(SC7->C7_MEDICAO )
					//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED						
					DBSelectArea('CND') 
					DBSetorder(4)
					DBSeek(xFilial('CND')+SC7->C7_MEDICAO)
					cAlDoc := "CND"
				Else
				
					//Busca Colicitação de Compras
					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))
					If SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
						cAlDoc := "SC1"
					Else
						//Se não encontrar Solicitação de Compras, busca posiciona pedido de compras
						cAlDoc := "SC7"
					EndIf
				EndIF					
			EndIf	
			
		EndIf	

	EndIf	

Return( cAlDoc )

STATIC function proxAcb()
	Local cNextCod := GetSxeNum("ACB","ACB_CODOBJ")

	//Valida se o código está sendo usado.
	dbSelectArea('ACB')
	ACB->( dbSetOrder(1) )
	IF ACB->( dbSeek( xFilial("ACB") + cNextCod ) )
		//Enquanto encontrar código, pega um novo. Até q encontre 1 q não existe
		while ACB->( dbSeek( xFilial("ACB") +  cNextCod ) )
			cNextCod  := GetSxeNum("ACB","ACB_CODOBJ")
		enddo
	endif

	ConfirmSX8()

return cNextCod
