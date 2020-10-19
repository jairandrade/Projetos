#INCLUDE "PROTHEUS.CH"
#INCLUDE "SHELL.CH"  

#DEFINE CGETFILE_TYPE   GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE
#DEFINE CGETFILE_TYPE_I GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Program   �BcDoc   � Autor �Sergio Silveira        � Data �19/03/2001  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do banco de conhecimentos                         ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                        ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function BcDoc( cRotina, bBlock, nOper )

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSavARot := If(Type("aRotina")!="U",aRotina,{})
Local cSavcCad := If(Type("cCadastro")!="U",cCadastro,"")
Local nSavN    := NIL
Local nScan    := 0                
Local lHtml    := FindFunction("ISHTML") .And. IsHTML() //Verifica se eH HTML
DEFAULT nOper  := 0 

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi("GED TCP - Cadastro de Documento") 
PRIVATE aRotina   := MenuDef()

Private aGrupos := getGrupos()

If Len(aGrupos) == 0
    If cUsername == "Administrador"
        AADD(aGrupos,'000000')
    Else
        Aviso( "Atencao !", "O usu�rio "+cUserName+", n�o pertence a nenhum grupo de usu�rio!.", { "Ok" } )                        
        Return .T.        
    EndIf   
EndIf

//�������������������������������������������������������Ŀ
//� Banco de Conhecimento nao disponivel para remote HTML �
//���������������������������������������������������������
If lHtml
	FWAvisoHTML()
	Return(.T.)
EndIf 

//������������������������������������������������������������������������������Ŀ
//� Se a variavel N ja estiver definida,guarda seu conteudo e inicializa como 1  �
//��������������������������������������������������������������������������������
If (Type("N") != "U" )
	nSavN := N
	N := 1 
EndIf 	 

//����������������������������������Ŀ
//�Ajustes para o Protheus 10 Express�
//������������������������������������
If FindFunction( "Pyme_Dic_Ajust" )
	Pyme_Dic_Ajust("AC9", .T.)
	Pyme_Dic_Ajust("ACB", .T.)	
	Pyme_Dic_Ajust("ACC", .T.)		
EndIf	  
		             
If ValType( cRotina ) == "C"
	//����������������������������������������������������������Ŀ
	//� Faz tratamento para chamada por outra rotina             �
	//������������������������������������������������������������
	If !Empty( nScan := AScan( aRotina, { |x| Upper( x[2] ) == Upper( cRotina ) .And. x[4] == nOper } ) ) 
		cRoda := cRotina + "( 'ACB', ACB->( Recno() ), " + Str(nScan,2) + " )" 
		xRet  := Eval( { || &( cRoda ) } ) 
	EndIf 
Else    
	mBrowse( 6, 1,22,75,"ACB", , , , , , , , , , bBlock )
EndIf 	
	
//��������������������������������������������������������������Ŀ
//�Restaura os dados de entrada                                  �
//����������������������������������������������������������������
aRotina   := aSavARot
cCadastro := cSavcCad                    

If ValType( nSavN ) == "N"
	N := nSavN 
EndIf 	

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocAlter� Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento para Visualizacao,Alteracao e Exclusao ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do arquivo                                     ���
���          �ExpN2: Registro do Arquivo                                  ���
���          �ExpN3: Opcao da MBrowse                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���21/02/07  �Fernando       �Bops 119230 Altera��o feita para usar a     ���
���          �               �FilgetDados na montagem do Aheader e Acols  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������       
�����������������������������������������������������������������������������
*/
User Function BcDocAlter(cAlias,nReg,nOpcx)
      
Local aPosObj   := {} 
Local aObjects  := {}                        
Local aSize     := MsAdvSize() 
Local aArea     := GetArea()
Local aRecno    := {}

Local bWhile    := {|| .T. }

Local cCadastro := OemToAnsi( "GED TCP - Cadastro de Documento" ) // "Banco de conhecimento"

Local cTrab     := "ACC"

Local lContinua := .T.
Local lQuery    := .F.
Local lAltera   := .F.

Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0

Local oGetDad
Local oDlg
Local cSeek  := Nil
Local cWhile := Nil
Local cQuery    := ""
Local _nI
Local lPerm := .F.


PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}

PRIVATE INCLUI  := .F.         
PRIVATE aExclui := {}
N := 1 


//---- Verifica se usu�rio pertence ao grupo de usu�rio do arquivo ---
If !Empty(ACB->ACB_GRPUSU)
    For _nI := 1 To Len(aGrupos)
    	If Alltrim(ACB->ACB_GRPUSU) == Alltrim(aGrupos[_nI])
    		lPerm := .T.
    	EndIF 	
    Next _nI
Else
    lPerm := .T.
EndIf

//--- Se usu�rio possuir permiss�o, ir� viasualizar o documento
If cUserName $ SuperGetMV("MV_TCPDOCU",,"Administrador")
    lPerm := .T.    
EndIf
                    
If !lPerm
    Aviso( "Atencao !", "Voc� n�o possui permiss�o para altera��o deste documento!", { "Ok" }, 2 ) 
    Return .T.
EndIf

//--------------------------------------------------------------------

If aRotina[ nOpcx, 4 ] == 5 
	lContinua := u_BcDocDelOk()  
ElseIf 	aRotina[ nOpcx, 4 ] == 4 
	lAltera := .T.	
EndIf                        

//������������������������������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para validar permissao de alteracao/exclusao/visualizacao quando chamado por outra rotina �
//��������������������������������������������������������������������������������������������������������������
If ExistBlock( "Ft340VLD" ) 
	lRet := ExecBlock( "Ft340VLD", .F., .F.,{nOpcx,FunName()} ) 
	If ValType(lRet) == "L" .And. !lRet
		Return
	Endif
Endif

If lContinua 

	//������������������������������������������������������Ŀ
	//�Montagem da Variaveis de Memoria                      �
	//��������������������������������������������������������
	dbSelectArea("ACB")
	dbSetOrder(1)
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor 
	
	#IFDEF TOP
		lQuery := .T.
		cQuery := "SELECT ACC.*,ACC.R_E_C_N_O_ ACCRECNO "
		cQuery += "FROM "+RetSqlName("ACC")+" ACC "
		cQuery += "WHERE ACC.ACC_FILIAL='"+xFilial("ACC") +"' AND "
		cQuery +=       "ACC.ACC_CODOBJ='"+ACB->ACB_CODOBJ+"' AND "
		cQuery +=       "ACC.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(ACC->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		cTrab  := CriaTrab( , .F. ) 
		
	#ELSE
	
		ACC->(MsSeek(xFilial("ACC")+ACB->ACB_CODOBJ))	
	 
	#ENDIF
	
	//������������������������������������������������������Ŀ
	//�Montagem do aHeader e aCols                           �
	//��������������������������������������������������������
    
	 
	cSeek  := xFilial("ACC")+ACB->ACB_CODOBJ
 	cWhile :="ACC->ACC_FILIAL+ACC->ACC_CODOBJ" 
 	    
	aCols	:={}
	aHeader :={}
	
	DbSelectArea("ACC")
	dbclosearea()
	
	FillGetDados(	nOpcx 		, "ACC", 1	, cSeek,; 
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
			   		/*aYesFields*/, /*lOnlyYes*/, cQuery, /*bMontAcols*/,.F.,; 
					/*aHeaderAux*/, /*aColsAux*/,{||u_BcDocRec(aRecno,lQuery,cTrab)}, /*bBeforeCols*/,;
					/*bAfterHeader*/,cTrab /*cAliasQry*/)

 

	If ( lQuery )
  		If Select(cTrab) > 0
	  		dbSelectArea(cTrab)
  			dbCloseArea()
  		Endif	
  		dbSelectArea(cAlias)
 	EndIf
	

	aObjects := {} 
	AAdd( aObjects, {  60, 100, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
	
	//������������������������������������������������������Ŀ
	//�Montagem da Tela                                      �
	//��������������������������������������������������������
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	
	oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"u_BcDocLOk","u_BcDocTOK","",nOpcx!=2,,,,,,,,"u_BcDocDOK")
	
	If ( nOpcx!=2 )
	
		ACTIVATE MSDIALOG oDlg ON INIT ( u_BcDocBar(oDlg,{|| nOpcA:=If(u_BcDocTOK() .And. oGetDad:TudoOk() .And. Obrigatorio(aGets,aTela),1,0),;
			If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()},nOpcx) ) 
		
		If ( nOpcA == 1 )
			Begin Transaction      
				u_BcDocGrv(nOpcx-2,aRecno)
				EvalTrigger()
			End Transaction
		EndIf
	Else
		ACTIVATE MSDIALOG oDlg ON INIT ( u_BcDocBar(oDlg,{||oDlg:End()},{||oDlg:End()},nOpcx) ) 
	EndIf
	
	u_MsDocExclui( aExclui, .F. ) 

EndIf 
		
//������������������������������������������������������Ŀ
//�Restaura a integridade dos dados                      �
//��������������������������������������������������������
MsUnLockAll()
RestArea(aArea)
Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    |BcDocRec	  �Autor �Fernando Amorim      � Data � 23/02/07  ���
�������������������������������������������������������������������������͹��
���Descricao �retorna o recno para fillgetdados                           ���
�������������������������������������������������������������������������͹��
���Parametros�												              ���
�������������������������������������������������������������������������͹��
���Uso       � banco de conhecimento                                  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
  
User Function BcDocRec(aRecno,lQuery,cTrab)  

If Select(cTrab) > 0 .And. (cTrab)->(!Eof())
	AAdd(aRecno, If( lQuery, (cTrab)->ACCRECNO, ACC->(RecNo()) ) )
Endif	

return(.T.)            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocInclu� Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Tratamento da Inclusao                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do arquivo                                     ���
���          �ExpN2: Registro do Arquivo                                  ���
���          �ExpN3: Opcao da MBrowse                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���21/02/07  �Fernando       �Bops 119230 Altera��o feita para usar a     ���
���          �               �FilgetDados na montagem do Aheader e Acols  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocInclu(cAlias,nReg,nOpcx)

Local aPosObj    := {} 
Local aObjects   := {}                        
Local aSize      := MsAdvSize() 
Local aArea      := GetArea()
Local aRecno     := {}

Local cOldFilter := ""
Local cCadastro  := OemToAnsi( "GED TCP - Cadastro de Documento" ) // "Banco de Conhecimento"

Local nUsado     := 0
Local nCntFor    := 0
Local nOpcA      := 0
Local nSaveSx8   := 0
Local cSeek   	 := Nil 
Local cWhile 	 := Nil
Local oDlg            
N := 1            

PRIVATE aHEADER  := {}
PRIVATE aCOLS    := {}
PRIVATE aGETS    := {}
PRIVATE aTELA    := {} 

PRIVATE INCLUI   := .T.
PRIVATE aExclui := {} 

//�������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para validar permissao de inclusao quando chamado por outra rotina �
//���������������������������������������������������������������������������������������
If ExistBlock( "Ft340VLD" ) 
	lRet := ExecBlock( "Ft340VLD", .F., .F.,{nOpcx,FunName()} ) 
	If ValType(lRet) == "L" .And. !lRet
		Return
	Endif
Endif
//��������������������������������������������������������������Ŀ
//� Limpa algum filtro do ACB                                    �
//����������������������������������������������������������������
cOldFilter := ACB->( dbFilter() ) 
ACB->( dbClearFilter() ) 

//������������������������������������������������������Ŀ
//�Montagem da Variaveis de Memoria                      �
//��������������������������������������������������������
dbSelectArea("ACB")
dbSetOrder(1)
For nCntFor := 1 To FCount()          
	If AllTrim( FieldName(nCntFor) ) == "ACB_OBJETO" 
		M->&(FieldName(nCntFor)) := Space( 1000 ) 	
	ElseIf AllTrim( FieldName(nCntFor) ) == "ACB_PATH"
		If FindFunction( "MsMultDir" ) .And. u_MsMultDir()
			M->&(FieldName(nCntFor)) := u_MsRetPath()
		Endif
	Else
		M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
	EndIf 	
Next nCntFor
//������������������������������������������������������Ŀ
//�Montagem do aHeader                                   �
//��������������������������������������������������������


	cSeek  := xFilial("ACC")+ACB->ACB_CODOBJ
 	cWhile :=	"ACC->ACC_FILIAL + ACC->ACC_CODOBJ"     

	FillGetDados(	nOpcx 		, "ACC", 1	, cSeek,; 
					{||&(cWhile)}, /*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
			   		/*aYesFields*/, /*lOnlyYes*/, /*cQuery*/, /*bMontAcols*/, .T.,; 
					/*aHeaderAux*/, /*aColsAux*/,/*bafterCols*/ , /*bBeforeCols*/,;
					/*bAfterHeader*/, /*cAliasQry*/)




                
aObjects := {} 
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects ) 

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
                  
oGetDad  := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],;
	nOpcx,"U_BcDocLOK","U_BcDocTOK","",.T.,,,,,,,,,)

ACTIVATE MSDIALOG oDlg ON INIT ( u_BcDocBar(oDlg,{|| nOpcA:=If(u_BcDocTOK() .And. oGetDad:TudoOk() .And. Obrigatorio(aGets,aTela) .And. u_BcDocCpyObj(M->ACB_OBJETO),1,0),;
	If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()},nOpcx ) ) 
	
If ( nOpcA == 1 )
	Begin Transaction
		u_BcDocGrv(1,aRecno)
		While (GetSx8Len() > nSaveSx8)
			ConfirmSX8()
		EndDo
		EvalTrigger()
	End Transaction
Else
	While (GetSx8Len() > nSaveSx8)
		RollBackSX8()
	EndDo
EndIf

u_MsDocExclui( aExclui, .F. ) 

MsUnLockAll()   

//��������������������������������������������������������������Ŀ
//� Retorna o filtro original                                    �
//����������������������������������������������������������������
If !Empty( cOldFilter )                                          
	dbSelectArea( cAlias ) 
	SET FILTER TO &cOldFilter
EndIf                     

RestArea(aArea)
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocGrv  � Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Gravacao do Banco de Conhecimento                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: [1] Inclusao                                         ���
���          �       [2] Alteracao                                        ���
���          �       [3] Exclusao                                         ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocGrv( nTipo, aRecs )

Local aArea      := GetArea()
                 
Local cCodObj    := M->ACB_CODOBJ
Local cFile      := ""
Local cExten     := ""
Local cDirDocs   := ""

Local nLoop      := 0
Local nLoop2     := 0
Local nPosKeyWrd := GDFieldPos( "ACC_KEYWRD" ) 
Local nCntSleep  := 0
Local lHtml   	 := FindFunction("ISHTML") .And. IsHTML() // Indica se e remote HTML 
Local lLibHtml 	 := FindFunction("IsDirLocal")

Begin Transaction

Do Case 
Case nTipo <> 3         
                     
	If nTipo == 1                     
		//��������������������������������������������������Ŀ
		//� Transforma o path completo em arquivo / extensao �
		//����������������������������������������������������
		cObjeto := M->ACB_OBJETO
		SplitPath( cObjeto,,, @cFile, @cExten ) 
		M->ACB_OBJETO := Left( Upper( cFile + cExten ), Len( ACB->ACB_OBJETO ) ) 
	EndIf                      
                     
	cSeekACB := xFilial( "ACB" ) + cCodObj
	
	ACB->( dbSetOrder( 1 ) )
	
	If ACB->( dbSeek( cSeekACB ) )
		RecLock( "ACB", .F. )
	Else
		RecLock( "ACB", .T. )
		ACB->ACB_FILIAL  := xFilial( "ACB" )
		ACB->ACB_CODOBJ  := M->ACB_CODOBJ
		If FindFunction( "MsMultDir" ) .And. u_MsMultDir()
			ACB->ACB_PATH	:= u_MsRetPath( M->ACB_OBJETO )
		Endif
		ACB->ACB_GRPUSU := getGrupo()
	EndIf
	
	dbSelectArea( "ACB" )
	
	//����������������������������������������������Ŀ
	//� Grava os demais campos inclusive especificos �
	//������������������������������������������������
	For nLoop := 1 To FCount()
		cCampo := FieldName( nLoop )
		If !( cCampo $ "ACB_FILIAL/ACB_CODOBJ/ACB_PATH/ACB_GRPUSU" ) .And. ValType(&("M->"+cCampo)) <> "U"
			FieldPut( nLoop, M->&cCampo )
		EndIf
	Next nLoop
	
	ACB->( MsUnlock() )
	
	//��������������������������������Ŀ
	//� Gravacao dos itens             �
	//����������������������������������
	For nLoop := 1 To Len( aCols )
	
		//��������������������������������������������������������Ŀ
		//� Efetua a gravacao apenas se nao for a linha "fantasma" �
		//����������������������������������������������������������
		If !( Len( aCols ) == 1 .And. ( Empty( aCols[ 1, nPosKeyWrd ] ) ) )
			
			If nLoop > Len( aRecs ) 
				If !GDDeleted( nLoop ) 			
					RecLock( "ACC", .T. ) 				       
				EndIf
			Else 
				ACC->( dbGoto( aRecs[ nLoop ] ) )         
				RecLock( "ACC", .F. )
			EndIf 	
				
			If !GDDeleted( nLoop ) 
				//��������������������������������Ŀ
				//� Se nao estiver excluido        �
				//����������������������������������
				//��������������������������������Ŀ
				//� Grava campos chave             �
				//����������������������������������
				ACC->ACC_FILIAL  := xFilial( "ACC" )
				ACC->ACC_CODOBJ  := ACB->ACB_CODOBJ
					
				dbSelectArea( "ACC" )
		
				For nLoop2 := 1 To Len( aHeader )
					cCampoAh  := AllTrim( aHeader[ nLoop2, 2 ] )
					If !( cCampoAh $ "ACC_CODOBJ/ACC_FILIAL" )
						nPosArq := ACC->( FieldPos( cCampoAh ) ) 
						If !Empty( nPosArq )
							ACC->( FieldPut( nPosArq, aCols[ nLoop, nLoop2 ] ) ) 
						EndIf
					EndIf
				Next nLoop2
		
			Else 
				//��������������������������������Ŀ
				//� Se o registro estiver excluido �
				//����������������������������������
				If nLoop <= Len( aRecs ) 
					ACC->( dbDelete() )
				EndIf					
			EndIf
			ACC->( MsUnLock() )

		EndIf 			
		
	Next nLoop
	
Otherwise 	

	ACB->( dbSetOrder( 1 ) )

	If ACB->( dbSeek( xFilial( "ACB" ) + M->ACB_CODOBJ ) )

		//��������������������������������Ŀ
		//� Exclui as palavras chave       �
		//����������������������������������
		cSeekACC := xFilial( "ACC" ) + ACB->ACB_CODOBJ

		If ACC->( dbSeek( cSeekACC ) )
			ACC->( dbEval( { || RecLock( "ACC", .F., .T. ),;
				ACC->( dbDelete() ), ACC->( MsUnLock() ) }, ,{ || cSeekACC;
				== ACC->ACC_FILIAL + ACC->ACC_CODOBJ }, , ,.T. ) )
		EndIf

		//��������������������������������Ŀ
		//� Retorna o Path do Documento    �
		//����������������������������������
		If FindFunction( "MsMultDir" ) .And. u_MsMultDir() .And. !Empty( ACB->ACB_PATH )
			cDirDocs := Alltrim( ACB->ACB_PATH )
		Else
			cDirDocs := MsDocPath()
		Endif

					
		If  lLibHtml .AND. lHtml .AND. IsDirLocal(cDirDocs)      
			FWAvisoHTML()
		Else    
					    
			//��������������������������������Ŀ
			//� Exclui o conhecimento          �
			//����������������������������������
			RecLock( "ACB", .F., .T. )
			ACB->( dbDelete() )
			ACB->( MsUnLock() )
	
			//������������������������������������������������������������������������Ŀ
			//� Faz a tentativa de apagar o arquivo                                    �
			//��������������������������������������������������������������������������
			nCntSleep := 0 
			While !Empty( FErase( cDirDocs + "\" + M->ACB_OBJETO )) .And. nCntSleep < 100
		  		Sleep( 100 ) 
				nCntSleep++
			EndDo 	
		EndIf	

	EndIf
	
EndCase	

End Transaction
//������������������������������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada apos o fim da transacao e antes da restauracao de area 								   �
//��������������������������������������������������������������������������������������������������������������
If ExistBlock("Ft340GRV")
	ExecBlock("Ft340GRV",.F.,.F.,{ nTipo })
EndIf
//��������������������������������������������������������������Ŀ
//�Restaura a integridade da rotina                              �
//����������������������������������������������������������������
RestArea(aArea)
Return( .T. )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocLOK  � Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da linha Ok                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocLOK()

Local lRetorno := .T.

Local nPKeyWrd  := GDFieldPos( "ACC_KEYWRD" ) 
Local nCntFor   := 0
Local nUsado    := Len(aHeader)
Local aHlpPor1  := {"Chave ja existe!"}
Local aHlpIng1  := {"Key allready exists!"}
Local aHlpEsp1  := {"llave ya existe"}

//Ajuste de Helps
PutHelp("PFT340LOK01",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)

//������������������������������������������������������Ŀ
//� verifica se linha do acols foi preenchida            �
//��������������������������������������������������������
If ( !CheckCols(n,aCols) )
	lRetorno := .F.
EndIf

If ( !aCols[n][nUsado+1] .And. lRetorno )
	//��������������������������������������������������������������Ŀ
	//�Verifica se nao ha palavras-chave duplicadas                  �
	//����������������������������������������������������������������
	If ( nPKeyWrd != 0 .And. lRetorno )
		For nCntFor := 1 To Len(aCols)
			If ( nCntFor != n .And. !aCols[nCntFor][nUsado+1])
				If ( aCols[n][nPKeyWrd] == aCols[nCntFor][nPKeyWrd]  )
					Help(" ",1,"FT340LOK01")
					lRetorno := .F.
				EndIf
			EndIf
	    Next nCntFor 
	EndIf
EndIf
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocTOK  � Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da Getdados                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocTOK()

Local lRetorno  := .T.
Local nI := 0    
Local nMaxArray := Len(aHeader)+1
Local nQtdDel := 0

For nI := 1 to Len(aCols)
	If aCols[nI][nMaxArray] //Deletado	
		nQtdDel++
	EndIf	
Next
If nQtdDel >= Len(aCols)
	Help(" ",1,"EXCLACOLS")
	lRetorno := .F.
EndIf

Return( lRetorno ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocDOk  � Autor �Sergio Silveira        � Data �03/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da Getdados                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocDOk() 

Return( .T. ) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocDelOk� Autor �Sergio Silveira        � Data �03/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da exclusao do conhecimento                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocDelOk() 

LOCAL lRetorno := .T. 

//������������������������������������������������������������������������Ŀ
//� Efetua a validacao da exclusao                                         �
//��������������������������������������������������������������������������
AC9->( dbSetOrder( 1 ) ) 
If AC9->( dbSeek( xFilial( "AC9" ) + ACB->ACB_CODOBJ ) ) 
	Help( " ", 1, "FT340EXC" ) // "Este objeto nao pode ser excluido pois esta associado a outra(s) entidade(s)
	lRetorno := .F. 
EndIf 

Return(lRetorno)

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocBar  � Autor �Sergio Silveira        � Data �19/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Enchoice bar especifica do programa de Oportunidades        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oDlg: 	Objeto Dialog                                     ���
���          � bOk:  	Code Block para o Evento Ok                       ���
���          � bCancel: Code Block para o Evento Cancel                   ���
���          � nOpc:	nOpc transmitido pela mbrowse                     ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	  ���
�������������������������������������������������������������������������Ĵ��
���Hanna C.  |30/03/07|9.12  �Bops 118469 - Alterado o nome dos Bitmaps   ���
���        	 �        |      �definidos pela Engenharia para o Protheus 10���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocBar(oDlg,bOk,bCancel,nOpc)

Local aButtons := {} 
Local aUsButtons
Local lMsDocFil:= ExistBlock( "MSDOCFIL" )

If INCLUI 
	AAdd( aButtons, { "bmpincluir", { || U_BcDocGetObj() }, "Seleciona Documento", "Seleciona Documento" } )  //"Seleciona objeto"
Else 	
	If !lMsDocFil .Or. ( lMsDocFil .And. FunName() == "BCDOC" )
		AAdd( aButtons, { "NOTE", { || U_BcDocExeObj() }, "Abre objeto", "Abre objeto" } )	 //"Abre objeto"
	Endif
EndIf	

//������������������������������������������������������������������������Ŀ
//� Adiciona botoes do usuario na EnchoiceBar                              �
//��������������������������������������������������������������������������
If ExistBlock( "Ft340BUT" ) 
	aUsButtons := ExecBlock( "Ft340BUT", .F., .F. ) 
	AEval( aUsButtons, { |x| AAdd( aButtons, x ) } ) 	 	
EndIf 	

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtons))

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocGetObj� Autor �Sergio Silveira       � Data �28/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtem o objeto a ser incluido no banco de conhecimentos     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocGetObj(cObjeto)

Local cFile := ""
                            
If GetMv("MV_SPLOCDR",.F.,.T.)
	cFile := cGetFile( "Todos os arquivos","Inclui objeto",0,GetMv("MV_SPLPATH",.F.,"C:\"),.T.,CGETFILE_TYPE) //"Todos (*.*) |*.*|"###"Todos os arquivos" //"Inclui objeto"
Else
	cFile := cGetFile( "Todos os arquivos","Inclui objeto",0,GetMv("MV_SPLPATH",.F.,"C:\"),.T.,CGETFILE_TYPE_I) //"Todos (*.*) |*.*|"###"Todos os arquivos" //"Inclui objeto"
EndIf

//�����������������������������������������������������������������������������������Ŀ
//� Verifica se o primeiro caracter e uma barra invertida, indicando o path do server �
//�������������������������������������������������������������������������������������
If Left( LTrim( cFile ), 1 ) == "\"
	Aviso( "Atencao", "Nao e possivel efetuar a copia a partir do local especificado !", { "Ok" }, 2 )  // "Atencao","Nao e possivel efetuar a copia a partir do local especificado !", "Ok"
Else                           

	If cObjeto == NIL 
		M->ACB_OBJETO := cFile 
		M->ACB_TAMANH := U_BcDocTaman( M->ACB_OBJETO ) 
	Else 
		If !Empty( cFile ) 
			cObjeto := cFile 	
		EndIf 	
	EndIf 		
		
EndIf

Return( .T. ) 
  
/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocCpyObj� Autor �Sergio Silveira       � Data �28/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Copia o objeto para o diretorio do banco de conhecimentos  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := BcDocCpyObj( ExpC1, ExpL2 )                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Copia bem sucedida                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 -> Path + nome do arquivo a copiar                   ���
���          � ExpL2 -> Verifica se o arquivo ja existe                   ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocCpyObj( cGetFile, lVerifExis )

LOCAL   cDirDocs   := ""
LOCAL   cFile      := ""
LOCAL   cExten     := ""     
LOCAL   cRmvName   := ""       
LOCAL   cNameTerm  := ""
LOCAL   cNameServ  := ""
LOCAL   cGet       := ""

LOCAL   lRet       := .T.         

LOCAL   nOpca      := 0 
LOCAL   nCount     := 0                

LOCAL   oDlgNome  
LOCAL   oBut1  
LOCAL   oBut2 
LOCAL   oBmp                   
LOCAL   oGet1                               
LOCAL   oBold 
Local 	aFiles
DEFAULT lVerifExis := .T. 

//������������������������������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para controlar o tamanho do arquivo que o usu�rio est� importando para o sistema.      �
//��������������������������������������������������������������������������������������������������������������
aFiles := Directory(cGetFile, "D")
If ExistBlock( "Ft340TAM" ) 
	lRet := ExecBlock( "Ft340TAM", .F., .F.,{aFiles} )
	If !lRet
		Return .F.  
	Endif	 
Endif

cGetFile := AllTrim( cGetFile ) 
 
SplitPath( cGetFile, , , @cFile, @cExten )  

cNameTerm := cFile + cExten
cNameServ := cNameTerm 

If FindFunction( "MsMultDir" ) .And. u_MsMultDir()
	cDirDocs := u_MsRetPath( cNameServ )
Else
	cDirDocs := MsDocPath()
Endif

//������������������������������������������������������������������������������������������������������������Ŀ
//� Ponto de Entrada para mudar o nome do arquivo durante a grava��o do arquivo no banco de conhecimento.      �
//��������������������������������������������������������������������������������������������������������������
If ExistBlock( "Ft340CHG" ) 
	cNameServ := ExecBlock( "Ft340CHG", .F., .F.,{cNameServ} ) 
Endif

If lVerifExis 

	While .T. 
	
		If File( cDirDocs + "\" + cNameServ ) 
			lRet := .F. 
			If Aviso( "Atencao!", "O arquivo '" + cFile + cExten + ; 
				"' nao pode ser incluido pois ja existe no diretorio do banco de conhecimento." + ; //"' nao pode ser incluido pois ja existe no diretorio do banco de conhecimento."
				"Deseja alterar seu nome ?", { "Sim", "Nao" }, 2 ) == 1   //"Atencao!"###"O arquivo '" //"Deseja alterar seu nome ?"###"Sim"###"Nao"
				
				SplitPath( cNameServ, , , @cFile, @cExten )  				
				
				cFile := Pad( cFile, Len( ACB->ACB_OBJETO ) ) 
				cGet  := ""
				
				//�����������������������������������������������������������������������Ŀ
				//� Abre a janela para a digitacao do novo nome                           �
				//�������������������������������������������������������������������������

				DEFINE MSDIALOG oDlgNome TITLE cCadastro From ;
			 			0,0 To 180, 344 OF oMainWnd PIXEL
			 			
					DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD	
					
               @  0, 0 BITMAP oBmp RESNAME "LOGIN" oF oDlgNome SIZE 40, 120 NOBORDER WHEN .F. PIXEL 
	
					@ 03, 50 SAY "Alteracao de nome" PIXEL FONT oBold  //"Alteracao de nome"
					@ 12 ,40 TO 14 ,400 LABEL '' OF oDlgNome PIXEL
					
					@ 35, 50 MSGET cFile SIZE 115, 08 of oDlgNome PICTURE "@S40" PIXEL VALID !Empty( cFile )  
				
					//�����������������������������������������������������������������������Ŀ
					//� Este GET foi criado para receber o foco do get acima. Nao retirar !!! �
					//�������������������������������������������������������������������������
					
					@ 1000, 1000 MSGET oGet1 VAR cGet SIZE 25, 08 of oDlgNome PIXEL 
					oGet1:bGotFocus := { || oBut1:SetFocus() } 
				
					DEFINE SBUTTON oBut1 FROM 52, 135 TYPE 1 ACTION ( nOpca := 1,;
							oDlgNome:End() ) ENABLE of oDlgNome
				                               
					DEFINE SBUTTON oBut2 FROM 70, 135 TYPE 2 ACTION ( nOpca := 0,;
							oDlgNome:End() ) ENABLE of oDlgNome
							
				ACTIVATE MSDIALOG oDlgNome CENTERED
				
				If nOpca == 1             
					cFile     := AllTrim( cFile ) 
					cNameServ := cFile + cExten 				   	
				Else
					lRet  := .F. 
					Exit
				EndIf 	 
			Else
				lRet := .F. 
				Exit 	
			EndIf 				
				
		Else
			lRet := .T.        
			Exit  
		EndIf 		
   
	EndDo 
	
EndIf	
	
If lRet 
 
 
 	//������������������������������������������������������������������������Ŀ
	//� Se precisar alterar o nome do arquivo na copia, usa __copyFile         �
	//��������������������������������������������������������������������������
	If cNameServ == cNameTerm	
		Processa( { || lRet := CpyT2S( cGetFile, cDirDocs, .F. ) }, "Transferindo objeto","Aguarde...",.F.) //"Transferindo objeto"###"Aguarde..."
	Else
		Processa( { || __CopyFile( cGetFile, cDirDocs + "\" + cNameServ ),lRet := File( cDirDocs + "\" + cNameServ ) }, "Transferindo objeto","Aguarde...",.F.) //"Transferindo objeto"###"Aguarde..." 
	EndIf 					
	
	cRmvName := U_BcDocRmvAc( cNameServ ) 
	
	//������������������������������������������������������������������������Ŀ
	//� Se o nome contiver caracteres estendidos, renomeia                     �
	//��������������������������������������������������������������������������
	If lRet 
	
		If !( cRmvName == cNameServ ) 
		
			nOpc := Aviso( "Atencao", "O arquivo '" + cNameServ + ; //"Atencao !"###"O arquivo '"
				"' possui caracteres estendidos. O caracteres estendidos serao alterados para _. Confirma a alteracao ?", { "Sim", "Nao" }, 2 )  //"' possui caracteres estendidos. O caracteres estendidos serao alterados para _. Confirma a alteracao ?"###"Sim"###"Nao"

			lRet   := .F. 		
						
			If nOpc == 1 
				cNameServ := cRmvName 
			EndIf	 
			
		EndIf				
		
		// Renomeia 
		
		If !( cNameServ == cNameTerm ) 
			nCount := 0 
			While nCount < 100
				If Empty( FRename( cDirDocs + "\" + cNameTerm, cDirDocs + "\" + cNameServ ) ) 
					lRet := .T. 
					Exit
				EndIf       
				nCount++
				Sleep( 100 ) 	
			EndDo 
		EndIf 
		
	EndIf 	
		
	If !lRet                                     
		//������������������������������������������������������������������������Ŀ
		//� Caso exista, exclui o arquivo com o nome anterior                      �
		//��������������������������������������������������������������������������
		FErase( cDirDocs + "\" + cNameTerm )  
	Else
		M->ACB_OBJETO := cNameServ
	EndIf 	
	
EndIf 	

If !lRet                                     
	Help( " ", 1, "FT340CPT2S" ) 	// Nao foi possivel transferir o arquivo para o banco de conhecimento !
EndIf 	

Return( lRet ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocExeObj� Autor �Sergio Silveira       � Data �28/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Abre o objeto efetuando a Shell Execute                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := BcDocCpyObj()                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Copia bem sucedida                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocExeObj()  

U_MsDocView( M->ACB_OBJETO, @aExclui, "" ) 

Return( .T. ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocTaman � Autor �Sergio Silveira       � Data �30/03/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Devolve o tamanho do arquivo do banco de conhecimento      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC1 := BcDocTaman( )                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 -> Tamanho do arquivo                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocTaman( cFilePath )
      
LOCAL aDir        := {}       
LOCAL cDirDocs		:= ""
LOCAL cTamanho    := ""    

DEFAULT cFilePath := ""

If !INCLUI .Or. !Empty( cFilePath )             

	If Empty( cFilePath )  .And. !Empty(ACB->ACB_OBJETO)
		If FindFunction( "MsMultDir" ) .And. U_MsMultDir()
			cDirDocs := u_MsRetPath( ACB->ACB_OBJETO )
		Else
			cDirDocs := MsDocPath() 
		Endif

		cDirDocs  := If( Right( cDirDocs, 1 ) == "\", Left( cDirDocs, Len( cDirDocs ) -1 ), cDirDocs )
		aDir      := Directory( Alltrim(cDirDocs + "\" +ACB->ACB_OBJETO ) ) 
	Else 
		aDir      := Directory( cFilePath ) 		
	EndIf 			
	
	If !Empty( aDir ) 
		cTamanho  := AllTrim( Str( aDir[ 1, 2 ] / 1024, 12 ) + " KB" )  //" KB"
	EndIf 	
		
EndIf 	
	
Return( cTamanho ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocSavAs � Autor �Sergio Silveira       � Data �02/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua o download ( gravar como ) do conhecimento          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := BcDocSavAs()                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Indica se a operacao foi bem sucedida             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocSavAs()   

LOCAL cDirDocs   := ""
LOCAL cGetFile   := ""
LOCAL cDrive     := ""
LOCAL cDir       := ""
LOCAL cFile      := ""
LOCAL cExten     := ""
LOCAL cExt1      := ""
Local _nI
LOCAL lRet       := .T.     

Local lPerm := .F.

//---- Verifica se usu�rio pertence ao grupo de usu�rio do arquivo ---
If !Empty(ACB->ACB_GRPUSU)
    For _nI := 1 To Len(aGrupos)
    	If Alltrim(ACB->ACB_GRPUSU) == Alltrim(aGrupos[_nI])
    		lPerm := .T.
    	EndIF 	
    Next _nI
Else
    lPerm := .T.
EndIf

//--- Se usu�rio possuir permiss�o, ir� viasualizar o documento
If cUserName $ SuperGetMV("MV_TCPDOCU",,"Administrador")
    lPerm := .T.    
EndIf
                    
If !lPerm
    Aviso( "Atencao !", "Voc� n�o possui permiss�o para altera��o deste documento!", { "Ok" }, 2 ) 
    Return .T.
EndIf

//--------------------------------------------------------------------

If FindFunction( "MsMultDir" ) .And. U_MsMultDir() .And. !Empty( ACB->ACB_PATH )
	cDirDocs := Alltrim( ACB->ACB_PATH )
Else
	cDirDocs := MsDocPath()
Endif
           
SplitPath( AllTrim( ACB->ACB_OBJETO ), , , , @cExt1 ) 

cExt1 := Lower( cExt1 )  

cMask := "Todos (*.*) |*.*| Arquivos tipo '" + cExt1 + "' (*" + cExt1 + ") |*" + cExt1


If GetMv("MV_SPLOCDR",.F.,.T.)
	cGetFile := cGetFile(cMask, "Salvar Objeto como",0, GetMv("MV_SPLPATH",.F.,"C:\") + AllTrim( ACB->ACB_OBJETO ),.F.,CGETFILE_TYPE) //"Salvar Objeto como"
Else
	cGetFile := cGetFile(cMask, "Salvar Objeto como",0, GetMv("MV_SPLPATH",.F.,"C:\") + AllTrim( ACB->ACB_OBJETO ),.F.,CGETFILE_TYPE_I) //"Salvar Objeto como"
EndIf

//������������������������������������������������������������������������Ŀ
//� Retira a ultima barra invertida ( se houver )                          �
//��������������������������������������������������������������������������
u_MsDocRmvBar( @cDirDocs ) 

//������������������������������������������������������������������������Ŀ
//� Separa os componentes                                                  �
//��������������������������������������������������������������������������
SplitPath( cGetFile, @cDrive, @cDir, @cFile, @cExten )

//������������������������������������������������������������������������Ŀ
//� Copia do servidor para o terminal                                      �
//��������������������������������������������������������������������������
If !Empty( cGetFile )

	If File( cGetFile ) 
		lRet := Aviso( "Atencao", "O arquivo '" + cFile + cExten + "' ja existe. Deseja substitui-lo ?", { "Sim", "Nao" }, 2 ) == 1 //"O arquivo '"###"' ja existe. Deseja substitui-lo ?"
 	EndIf 

	If lRet 
		//������������������������������������������������������������������������Ŀ
		//� Efetua a copia para o local especificado                               �
		//��������������������������������������������������������������������������
		Processa( { || lRet := __CopyFile( cDirDocs + "\" + Upper(AllTrim(ACB->ACB_OBJETO)), cDrive + cDir + Upper(cFile + cExten) ) }, "Transferindo objeto", "Aguarde...", .T. )	//"Transferindo objeto"###"Aguarde..."

		If !lRet
			Aviso( "Atencao", "Nao foi possivel copiar o arquivo '" + AllTrim(ACB->ACB_OBJETO) + "' !", { "Ok" }, 2 ) //"Nao foi possivel copiar o arquivo '"###"' !"###"Ok"
		EndIf 	
		
	EndIf 	
			
EndIf 

Return( lRet ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocUate� Autor �Sergio Silveira       � Data �02/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a atualizacao do arquivo de conhecimento no banco   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpL1 := BcDocUate()                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Indica se a operacao foi bem sucedida             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BcDocUFil()

U_BcDocUate()

RETURN


User Function BcDocUate(cDirSave,lMsgOk) 

Local cDrive    := ""
Local cDir      := ""
Local cFile     := ""
Local cExten    := ""
Local cMask     := ""
Local cExt1     := ""
Local _nI
Local lRet      := .T.

Local lPerm := .F.

DEFAULT lMsgOk	 := .T. 

//---- Verifica se usu�rio pertence ao grupo de usu�rio do arquivo ---
If !Empty(ACB->ACB_GRPUSU)
    For _nI := 1 To Len(aGrupos)
    	If Alltrim(ACB->ACB_GRPUSU) == Alltrim(aGrupos[_nI])
    		lPerm := .T.
    	EndIF 	
    Next _nI
Else
    lPerm := .T.
EndIf

//--- Se usu�rio possuir permiss�o, ir� viasualizar o documento
If cUserName $ SuperGetMV("MV_TCPDOCU",,"Administrador")
    lPerm := .T.    
EndIf
                    
If !lPerm
    Aviso( "Atencao !", "Voc� n�o possui permiss�o para altera��o deste documento!", { "Ok" }, 2 ) 
    Return .F.
EndIf

//--------------------------------------------------------------------

SplitPath( AllTrim( ACB->ACB_OBJETO ), , , , @cExt1 )

cExt1 := Lower( cExt1 )  

If cDirSave == Nil
	cMask := "Todos (*.*) |*.*| Arquivos tipo '" + cExt1 + "' (*" + cExt1 + ") |*" + cExt1

	If GetMv("MV_SPLOCDR",.F.,.T.)
		cGetFile := cGetFile(cMask, "Atualizar Objeto",0, GetMv("MV_SPLPATH",.F.,"C:\") + AllTrim( ACB->ACB_OBJETO ),.F.,CGETFILE_TYPE) //"Atualizar Objeto"
	Else
		cGetFile := cGetFile(cMask, "Atualizar Objeto",0, GetMv("MV_SPLPATH",.F.,"C:\") + AllTrim( ACB->ACB_OBJETO ),.F.,CGETFILE_TYPE_I) //"Atualizar Objeto"
	EndIf

Else
	cGetFile := cDirSave
EndIf

 
If !Empty( cGetFile ) 

	SplitPath( cGetFile, @cDrive, @cDir, @cFile, @cExten ) 
	
	//������������������������������������������������������������������������Ŀ
	//� Protecao para o ambiente LINUX                                         �
	//��������������������������������������������������������������������������
	cDrive   := Upper( cDrive ) 
	cDir     := Upper( cDir ) 
	cFile    := Upper( cFile ) 
	cExten   := Upper( cExten ) 
	
	If AllTrim( cFile + cExten ) == AllTrim( Upper( ACB->ACB_OBJETO ) ) 
		//������������������������������������������������������������������������Ŀ
		//� Efetua a copia para o servidor                                         �
		//��������������������������������������������������������������������������
		If !U_BcDocCpyObj( cGetFile, .F. )
			lRet := .F. 	                                 
			Help( " ", 1 , "FT340ATU" ) // "Nao foi possivel efetuar a atualizacao !"
		EndIf 	
	Else 
		Help( " ", 1, "FT340NOME" ) // "E necessario que os arquivos possuam o mesmo nome !"
		lRet := .F. 
	EndIf 

	If lRet 
		If lMsgOk
			Help( " ", 1, "FT340SUCES" ) // "Conhecimento atualizado com sucesso !"
		EndIf
	EndIf 
	
EndIf
	
Return( lRet )  

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocVlObj � Autor �Sergio Silveira       � Data �05/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BcDocVlObj                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 -> Path                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
       
User Function BcDocVlObj()

Local cGetFile := &( ReadVar() ) 
Local cFile    := ""
Local cExten   := ""

aArea    := GetArea() 
aAreaABH := ABH->( GetArea() ) 

SplitPath( cGetFile, , , cFile, cExten )  

ABH->( dbSetOrder( 2 ) ) 
If ABH->( dbSeek( xFilial( "ABH" ) + cFile + cExten ) ) 
	Aviso( "Atencao", "O arquivo '" + cFile + cExten + "' ja esta contido no banco de conhecimento !", { "Ok" }, 2 ) //"Atencao !"###"O arquivo '"###"' ja esta contido no banco de conhecimento !"###"Ok"
	lRet := .F.
EndIf 
                                
ABH->( RestArea( aAreaABH ) ) 
RestArea( aArea ) 

Return( lRet ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocPesqui� Autor �Sergio Silveira       � Data �06/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a chamada da janela de pequisa                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BcDocPesqui()                                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocPesqui()

LOCAL aResultado := {} 
LOCAL aListBox   := {}
LOCAL AOrdem     := {} 
LOCAL aArea      := GetArea() 
        
LOCAL cKeyWord   := Space( 100 ) 
LOCAL cDescri    := Space( 40 ) 
LOCAL cResultado := "" 
LOCAL cOrdem     := "" 
LOCAL cObjeto    := Space( 200 ) 

LOCAL lExata     := .F. 
LOCAL lKeyWord   := .F. 

LOCAL nPosList   := 0      
LOCAL nOpca      := 0      

LOCAL oDlg 
LOCAL oListBox
LOCAL oBut1 
LOCAL oBut2
LOCAL oBut3           
LOCAL oMenu
LOCAL oPesqExata                                          
LOCAL oOrdem 
      
If ( nAviso := Aviso( "Pesquisa", "Selecione o modelo de pesquisa:", { "Normal", "Avancada", "Cancelar" }, 2 ) ) == 1 //"Pesquisa"###"Selecione o modelo de pesquisa:"###"Normal"###"Avancada"###"Cancelar"
	AxPesqui()
ElseIf nAviso == 2  
	DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 09,0 TO 33.8,60 OF oMainWnd
	                 
	//������������������������������������������������������������������������Ŀ
	//� Define os itens do Menu PopUp                                          �
	//��������������������������������������������������������������������������
	MENU oMenu POPUP 
		MENUITEM "Visualiza" Action U_BcDocView( @aResultado, oListBox )   //"Visualiza"
	ENDMENU
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 55, 1000 NOBORDER WHEN .F. PIXEL 
	
	@ 03, 40 SAY "Localizar conhecimento" FONT oBold PIXEL // "Pesquisar entidade" //"Localizar conhecimento"
	
	@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL

	@ 25, 40 SAY "Objeto" SIZE 40, 10    PIXEL  //"Objeto"
	@ 23, 85 MSGET oGetPesq3 VAR cObjeto PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL 
	                                                      
	@ 38, 40 SAY "Descricao" SIZE 40, 10    PIXEL  //"Descricao"
	@ 36, 85 MSGET oGetPesq2 VAR cDescri PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL 
	                        
	@ 51, 40 SAY "Palavras chave"  SIZE 40, 10 PIXEL  //"Palavras chave"
	@ 49, 85 MSGET oGetPesq1 VAR cKeyWord PICTURE "@!" SIZE 80, 10 VALID .T. PIXEL 

	aOrdem := { "Ocorrencias", "Descricao" }  //"Ocorrencias"###"Descricao"
	cOrdem := ""	
	
	@ 64, 40 SAY "Ordenar por"  SIZE 40, 10 PIXEL 	 //"Ordenar por"
	
	@ 62, 85 COMBOBOX oOrdem VAR cOrdem ITEMS aOrdem SIZE 80,10 OF oDlg PIXEL;
		ON CHANGE U_BcDocShow( @oListBox, @aResultado, oOrdem, @lKeyWord ) 
	
	DEFINE SBUTTON oBut1 FROM 22, 202 TYPE 5 ACTION U_BcDocLocLz( @oListBox, cKeyWord, cDescri, cObjeto,;
	 @aResultado, lExata, oOrdem, @lKeyWord ) ENABLE of oDlg ONSTOP "Pesquisar"  //"Pesquisar"
	
	 oBut1:cTitle   := "Pesquisar"
	
	@ 81, 40 LISTBOX oListBox VAR cResultado ITEMS aListBox PIXEL SIZE 190, 80 OF oDlg MULTI
                                 
	@ 168,40 CHECKBOX oPesqExata VAR lExata SIZE 60,8 PIXEL OF oDlg PROMPT "Pesquisa Exata" //"Pesquisa Exata"
		                                                                                        
	DEFINE SBUTTON oBut3 FROM 168, 169 TYPE 1 ACTION ( nOpca := 1, nPosList := oListBox:nAt, oDlg:End() )  ENABLE of oDlg		 
	DEFINE SBUTTON oBut2 FROM 168, 202 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg
	 
	oListBox:bRClicked  := { |o,nX,nY| oMenu:Activate( nX, nY, o ) } // Posi��o x,y em rela��o a Dialog 

	ACTIVATE MSDIALOG oDlg CENTERED  
	
	If nOpca == 1 .And. !Empty( aResultado ) .And. !Empty( nPosList ) 
		ACB->( dbSetOrder( 1 ) )  
		ACB->( dbGoto( aResultado[ nPosList, 2 ] ) ) 
	Else 
		RestArea( aArea )
	EndIf 

EndIf 
                                                                         
Return( .T. ) 
                                                                          

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocLoclz � Autor �Sergio Silveira       � Data �12/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz a chamada da janela de pequisa                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BcDocLoclz()                                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 -> Objeto ListBox                                    ���
���          � ExpC1 -> String com palavras-chave                         ���
���          � ExpC2 -> Descricao para pesquisa                           ���
���          � ExpC3 -> Objeto para pesquisa                              ���
���          � ExpA1 -> Array contendo os resultados da busca             ���
���          � ExpL1 -> Indica pesquisa exata                             ���
���          � ExpO2 -> Objeto Combobox ( Ordem )                         ���
���          � ExpL2 -> Indica se havia keyword                           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocLocLz( oListBox, cKeyWord, cDescri, cObjeto, aResult, lExata, oOrdem, lKeyWord ) 

If Empty( cKeyWord ) .And. Empty( cDescri ) .And. Empty( cObjeto ) 
	Help( " ", 1, "FT340PARAM" ) // "Ao menos um parametro deve ser preenchido !"
Else
	//������������������������������������������������������������������������Ŀ
	//� Efetua a pesquisa                                                      �
	//��������������������������������������������������������������������������
	Processa( { || U_MsDocLoclz( cKeyWord, cDescri, cObjeto, @aResult, lExata, @lKeyWord ) }, "Efetuando pesquisa...","Aguarde...",.F.)  //"Efetuando pesquisa..."
	//������������������������������������������������������������������������Ŀ
	//� Alimenta e ordena a listbox                                            �
	//��������������������������������������������������������������������������
	Processa( { || U_BcDocShow( @oListBox, aResult, oOrdem, lKeyWord ) } , "Classificando resultado...","Aguarde...",.F.)   //"Classificando resultado..."
EndIf 	
	
Return( .T. ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocExtKey� Autor �Sergio Silveira       � Data �09/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Extrai as palavras chave da string para um array           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpA1 := BcDocExtKey( ExpC1 )                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA1 -> Array contendo as palavras chave                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 -> String contendo as palavras chave separadas por , ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocExtKey( cKeyWord ) 

LOCAL aKeyWord := {}
    
LOCAL cParc    := ""
LOCAL cByte    := ""

LOCAL nLoop    := 0 

cKeyWord := AllTrim( cKeyWord ) 
                                            
If !Empty( cKeyWord ) 

	For nLoop := 1 to Len( cKeyWord ) 
		cByte := SubStr( cKeyWord, nLoop, 1 )             
		If cByte == "," .Or. cByte == ";"	
			AAdd( aKeyWord, { cParc, .F. } ) 
			cParc := ""
		Else 		    
			cParc += cByte 			
		EndIf
	Next nLoop 	
	  
	If !Empty( cParc ) 
		AAdd( aKeyWord, { cParc, .F. } ) 
	EndIf 	
	
EndIf 	
	
Return( aKeyWord ) 

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocView  � Autor �Sergio Silveira       � Data �10/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a visualizacao a partir da pesquisa                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BcDocView( ExpA1, ExpO1 )                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 -> Array os recnos dos conhecimentos                 ���
���          � ExpO1 -> Objeto ListBox                                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function BcDocView( aResultado, oListBox ) 
   
LOCAL nPosList := oListBox:nAt

If nPosList >= 1 .And. nPosList <= Len( aResultado ) 
	ACB->( dbGoto( aResultado[ nPosList , 2 ] ) )  
	
	If !ACB->( Eof() ) 
		U_BcDocAltera( "ACB", ACB->( Recno() ), 2 )  
	EndIf 	
EndIf 	
	
Return( .T. )                   

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocShow  � Autor �Sergio Silveira       � Data �11/04/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe e Ordena os resultados da pesquisa                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � BcDocShow( ExpO1, ExpA1, ExpO2 )                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 -> Objeto ListBox                                    ���
���          � ExpA1 -> Array os recnos dos conhecimentos                 ���
���          � ExpO2 -> Objeto combobox                                   ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocShow( oListBox, aResultado, oOrdem, lKeyWord ) 

LOCAL aListBox := {} 
LOCAL bSort    := { || .T. } 
LOCAL nOpc := oOrdem:nAt 

CursorWait()

If nOpc == 1 
	bSort := { |x,y| x[3] > y[3] }
ElseIf nOpc == 2 
	bSort := { |x,y| x[1] < y[1] }
EndIf  

aResultado := ASort( aResultado, , , bSort )

If lKeyWord 
	AEval( aResultado, { |x| AAdd( aListBox, AllTrim( x[1] ) + " - " + AllTrim( Str( x[3] ) ) + " " + If( x[3]>1, "Ocorrencias", "Ocorrencia" ) ) } )	 //"Ocorrencias"###"Ocorrencia"
Else	
	AEval( aResultado, { |x| AAdd( aListBox, AllTrim( x[1] ) ) } )	
EndIf 

oListBox:SetArray( aListBox ) 
oListBox:Refresh() 
CursorArrow() 

Return( .T. )                                       

/*  
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �BcDocRmvAc � Autor �Sergio Silveira       � Data �21/11/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Remove acentos de uma string                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC1 := BcDocRmvAc( ExpC2 )                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC1 -> String sem acentos                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 -> String a converter                                ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BcDocRmvAc( cString ) 
                 
LOCAL cNewString := ""
LOCAL cAddChar   := ""
LOCAL cChar      := ""

LOCAL nLoop      := 0 

For nLoop := 1 To Len( cString ) 

	cChar := SubStr( cString, nLoop, 1 ) 
	
	If Asc( cChar ) < 32 .Or. Asc( cChar ) > 127 
		cAddChar := "_"		
	Else 				
		cAddChar := cChar	
	EndIf 
                     
	cNewString += cAddChar 

Next nLoop 

Return( cNewString ) 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina  := {	{ OemToAnsi("Pesquisar"),"u_BcDocPesqui",0,1,0,.F.},;	// "Pesquisar"
								{ OemToAnsi("Visual"),"u_BcDocAlter" ,0,2,0,NIL},;	// "Visual"
								{ OemToAnsi("Incluir"),"u_BcDocInclu" ,0,3,0,NIL},;	// "Incluir"
					 			{ OemToAnsi("Alterar"),"u_BcDocAlter" ,0,4,0,NIL},;	// "Alterar"
								{ OemToAnsi("Exclusao"),"u_BcDocAlter" ,0,5,0,NIL},;	// "Exclusao"							
								{ OemToAnsi("Atualiza"),"u_BcDocUFil",0,4,0,NIL},;	// "Atualiza"
								{ OemToAnsi("Salvar Como"),"u_BcDocSavAs" ,0,4,0,NIL} }	// "Salvar Como"

If ExistBlock("Ft340MNU")
	ExecBlock("Ft340MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
+-----------------------------------------------------------------------------+
! Fun��o     ! getGrupo     ! Autor ! Alexandre Effting  ! Data !  25/06/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Retorna o Grupo de Usu�rios do usu�rio logado                  !
+------------+----------------------------------------------------------------+
*/

Static Function getGrupo()
    Local cGrp := ""
    
    PswOrder(2)
	If PswSeek(__cUserId,.T.)
		_aInfo   := PswRet(1)
		cGrp := _aInfo[1,10,1]
	Endif

Return cGrp

/*
+-----------------------------------------------------------------------------+
! Fun��o     ! getGrupos    ! Autor ! Alexandre Effting  ! Data !  25/06/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Retorna os Grupos de Usu�rios do usu�rio logado                !
+------------+----------------------------------------------------------------+
*/

Static Function getGrupos()
    Local _aGrupos := {}
    
    PswOrder(2)
	If PswSeek(__cUserId,.T.)
		_aInfo   := PswRet(1)
		_aGrupos := _aInfo[1,10]
	Endif

Return _aGrupos