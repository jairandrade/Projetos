/*/{Protheus.doc} Instalação do Madero
Fonte criado para recuperar campos perdidos na base
@type function
 
@author Leandro Favero
@since 08/08/2018
@version 1.0
/*/

/*--------------------------------------------------------------------------+
|  MadInstall - Cria os campos customizados do Madero                       |
----------------------------------------------------------------------------*/
User function MadInstall()
	 //SX5MAPA()  //Tabelas para o Ministério do Agricultura
	 //SX3MAPA()    //Campos para o Ministério do Agricultura
	 //FixSX2()   //Arquivos
	 //FixSXB()   //Consulta padrão
	 //FixSX3()   //Dicionario de dados
Return


//+--------------------------------------------------------------+
//¦ SX5MAPA - Tabelas para o Ministério do Agricultura           ¦
//+--------------------------------------------------------------+
Static Function SX5MAPA()

    //1 – CATEG PROD MAPA – Campo a ser preenchido com a categoria do produto produzido perante o Ministério da Agricultura.
	CriaSX5('00','Z4','Categoria Produto MAPA') //B1_CATMAPA	
	CriaSX5('Z4','01','Produtos Submetidos a Tratamento Térmico')
	CriaSX5('Z4','02','Produtos em Natureza')	
	CriaSX5('Z4','03','Produtos Não Submetidos a Tratamento Térmico')
	
	//2 – PRODUTO ACAB MAPA – Campo a ser preenchido com a descrição do produto produzido perante o Ministério da Agricultura.   
    CriaSX5('00','Z6','Produto Acab. MAPA')     //B1_PACAMAPA
    CriaSX5('Z6','01','Barriga Defumada')  
    CriaSX5('Z6','02','Carne Congelada de Bovino sem Osso') 
    CriaSX5('Z6','03','Linguiça Defumada')
    CriaSX5('Z6','04','Prato Pronto ou Semipronto')
    CriaSX5('Z6','05','Carne Congelada de Frango sem Osso')
    CriaSX5('Z6','06','Hamburguer congelado de bovino')
    CriaSX5('Z6','07','Hamburguer congelado Misto')
    CriaSX5('Z6','08','Carne Congelada de Ovino sem Osso')
    CriaSX5('Z6','09','Carne Temperada Congelada de Frango Sem Osso')
    CriaSX5('Z6','10','Carne Temperada Congelada de Suíno Sem Osso')
    CriaSX5('Z6','11','Hamburguer congelado de suíno')
    
    //4 - CATEG RECEB MAPA – Campo a ser preenchido com a categoria do produto referente ao recebimento perante o Ministério da Agricultura.
	CriaSX5('00','Z7','Categoria Receb. MAPA')  //B1_CRECMAPA
	CriaSX5('Z7','01','Produtos em Natureza')
	CriaSX5('Z7','02','Cozinha Industrial') 
	CriaSX5('Z7','03','Submetido a Tratamento Térmico') 
	
	//5 - PRODUTO RECEB MAPA – Campo a ser preenchido com a descrição do produto recebido perante o Ministério da Agricultura.
	CriaSX5('00','ZD','Produto Receb. MAPA')    //B1_PRECMAPA	
	CriaSX5('ZD','01','Carne Congelada de Ovino sem Osso')
	CriaSX5('ZD','02','Cozinha Industrial')
	CriaSX5('ZD','03','Carne Resfriada de Bovino sem Osso')
	CriaSX5('ZD','04','Carne Congelada de Bovino sem Osso')
	CriaSX5('ZD','05','Carne Resfriada De Suíno Sem Osso')
	CriaSX5('ZD','06','Carne Resfriada De Suíno Com Osso')
	CriaSX5('ZD','07','Carne Congelada de Suíno sem Osso')
	CriaSX5('ZD','08','Carne Resfriada De Frango Sem Osso')
	CriaSX5('ZD','09','Toucinho Resfriado De Suíno')
	CriaSX5('ZD','10','Envoltórios Naturais Conservados de Bovino')
	CriaSX5('ZD','11','Envoltórios Naturais Conservados de Ovino')
	CriaSX5('ZD','12','Envoltórios Naturais Dessecado de Suíno')
	CriaSX5('ZD','13','Gordura congelada de bovino')
	CriaSX5('ZD','14','Papada resfriada de suíno')  
return

//+--------------------------------------------------------------+
//¦ SX3MAPA - Campos para o Ministério do Agricultura           ¦
//+--------------------------------------------------------------+
Static Function SX3MAPA()

	//3 – PESO MAPA - Campo a ser preenchido com o peso do produto produzido a ser utilizado nos cálculos para o Ministério da Agricultura. Este campo deve ser numérico com 3 casas decimais após a vírgula.
	//No cadastro de Fornecedores, teremos que criar o campo COD SIF, para o preenchimento do código de SIF (campo numérico com possibilidade de hífem).
	
	           //Campo,        Tipo, Tamanho, Decimal, F3, Usado, Titulo, Descrição        
    aFields:={{ "B1_CATMAPA"  , "C" , 2, 0, 'Z4','S', 'CATEG PROD MAPA'   , 'Categoria Prod. MAPA' },;						   
			  { "B1_PACAMAPA" , "C" , 2, 0, 'Z6','S', 'PRODUTO ACAB MAPA' , 'Produto Acab. MAPA' },;
			  { "B1_CRECMAPA" , "C" , 2, 0, 'Z7','S', 'CATEG RECEB MAPA'  , 'Categoria Receb. MAPA' },;
			  { "B1_PRECMAPA" , "C" , 2, 0, 'ZD','S', 'PRODUTO RECEB MAPA', 'Produto Receb. MAPA' },;
			  { "B1_PESOMAPA" , "N" ,10, 3, '  ','S', 'Peso MAPA'         , 'Peso MAPA' },;
			  { "A2_SIF"      , "C" ,10, 0, '  ','S', 'S.I.F'             , 'Código de SIF' }}

	CriaCampos(aFields)

Return


//+--------------------------------------------------------------+
//¦ CriaCampos                                                   ¦
//+--------------------------------------------------------------+
Static Function CriaCampos(aFieldList)
	local nCnt
	local cOrdem
	local lUpd:=.F.
	local cAlias

	SX3->(DBSetOrder(2)) //X3_CAMPO
	
	for nCnt:=1 to len(aFieldList)			
		if !SX3->(DBSeek(aFieldList[nCnt,1],.T.))
			cAlias:='S'+SubStr(aFieldList[nCnt,1],1,2)			
		
			if (cOrdem==nil)
				cOrdem:= nxtSeq(cAlias) //Pega a ordem mais alta
			endif
			cOrdem:=Soma1(cOrdem)		
			RecLock('SX3',.T.)
				SX3->X3_ARQUIVO:= cAlias
				SX3->X3_ORDEM  := cOrdem
				SX3->X3_CAMPO  := aFieldList[nCnt,1]
				SX3->X3_TIPO   := aFieldList[nCnt,2]
				SX3->X3_TAMANHO:= aFieldList[nCnt,3]
			 	SX3->X3_DECIMAL:= aFieldList[nCnt,4]
			 	SX3->X3_F3     := aFieldList[nCnt,5]
				SX3->X3_TITULO := aFieldList[nCnt,7]
				SX3->X3_TITSPA := aFieldList[nCnt,7]
				SX3->X3_TITENG := aFieldList[nCnt,7]
				SX3->X3_DESCRIC:= aFieldList[nCnt,8]
				SX3->X3_DESCSPA:= aFieldList[nCnt,8]
				SX3->X3_DESCENG:= aFieldList[nCnt,8]
				if (aFieldList[nCnt,6]=='S')
					SX3->X3_USADO := Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
								 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
								 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)
				endif
				SX3->X3_RESERV := Chr(254) + Chr(192)
				SX3->X3_CONTEXT:= 'R' //Real
				SX3->X3_VISUAL := 'A' //Altera
				SX3->X3_BROWSE := 'S' //Mostrar no Browser
				SX3->X3_PROPRI := 'U' //Campo customizado pelo usuário
			MsUnlock()
			lUpd:=.T. //Marca para atualizar a tabela
		endif
	Next
	
	if lUpd
		X31UPDTABLE(cAlias) //Efetua a atualização da tabela
	endif 
return

//+--------------------------------------------------------------+
//¦ CriaSX5 - Cria registro na tabela           ¦
//+--------------------------------------------------------------+
Static Function CriaSX5(cTabela,cChave,cDesc)
	if !SX5->(DBSeek(xFilial('SX5')+cTabela+cChave))
		RecLock('SX5',.T.)
		SX5->X5_FILIAL :=xFilial('SX5')
		SX5->X5_TABELA :=cTabela
		SX5->X5_CHAVE  :=cChave
		SX5->X5_DESCRI :=UPPER(cDesc)
		SX5->X5_DESCSPA:=UPPER(cDesc)
		SX5->X5_DESCENG:=UPPER(cDesc)
		MsUnlock()
	endif
Return

//+--------------------------------------------------------------+
//¦ FixSX2 - Acerta as tabelas que faltam no SX2                 ¦
//+--------------------------------------------------------------+
Static Function FixSX2()
	 Local cQry:='Select * from SX2USER'
	 Local cLista:=''

	 DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), 'SX2USER' , .F., .T. )
	 	 
	 DBSelectArea('SX2')
	 SX2->(DBSetorder(1)) //X2_CHAVE
	 
	 while !SX2USER->(EOF()) 
	 	SX2->(DBGoTop())
	 	if !SX2->(DBSeek(SX2USER->X2_CHAVE))	 	
	 		conout(SX2USER->X2_CHAVE)
	 		cLista+=SX2USER->X2_CHAVE+Chr(13)+Chr(10)
	 		
	 		CriaSX2()
	 	endif
	 	SX2USER->(DBSkip())
	 enddo
	 
	 SX2USER->(DBCloseArea())
	 
	 MemoWrite( '/lista.txt', cLista )
Return
	

//+--------------------------------------------------------------+
//¦ CriaSX2                                                  ¦
//+--------------------------------------------------------------+
Static Function CriaSX2()
	#define DBS_NAME	1
	local cField, nPos
		
	RecLock('SX2',.T.) 
		
	FOR nPos := 1 TO SX2->(FCOUNT())	
		cField:=SX2->(DBFieldInfo(DBS_NAME,nPos))
		SX2->&(cField):=SX2USER->&(cField)	
	Next  
	
	MsUnlock()
return	
	
	
//+--------------------------------------------------------------+
//¦ FixSXB - Acerta as Consulta padrão                           ¦
//+--------------------------------------------------------------+
Static Function FixSXB()
	 Local cQry:='Select * from SXBUSER'
	 Local cLista:=''

	 DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), 'SXBUSER' , .F., .T. )
	 	 
	 DBSelectArea('SXB')
	 SXB->(DBSetorder(1)) //XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA	 
	 
	 while !SXBUSER->(EOF()) 
	 	SXB->(DBGoTop())
	 	if !SXB->(DBSeek(SXBUSER->(XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA)))	 	
	 		conout(SXBUSER->XB_ALIAS)
	 		cLista+=SXBUSER->XB_ALIAS+Chr(13)+Chr(10)
	 		
	 		CriaSXB()
	 	endif
	 	SXBUSER->(DBSkip())
	 enddo
	 
	 SXBUSER->(DBCloseArea())
	 
	 MemoWrite( '/lista.txt', cLista )
Return



//+--------------------------------------------------------------+
//¦ CriaSXB                                                   ¦
//+--------------------------------------------------------------+
Static Function CriaSXB()
	#define DBS_NAME	1
	local cField, nPos
		
	RecLock('SXB',.T.) 
		
	FOR nPos := 1 TO SXB->(FCOUNT())	
		cField:=SXB->(DBFieldInfo(DBS_NAME,nPos))
		SXB->&(cField):=SXBUSER->&(cField)	
	Next  
	

	MsUnlock()
return
		
//+--------------------------------------------------------------+
//¦ FixSX3 - Acerta os campos que faltam na base                 ¦
//+--------------------------------------------------------------+
Static Function FixSX3()
	Local cQry:='Select * from SX3USER'
	 Local cLista:=''

	 DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), 'SX3USER' , .F., .T. )
	 	 
	 DBSelectArea('SX3')
	 SX3->(DBSetorder(2)) //X3_CAMPO	 
	 
	 while !SX3USER->(EOF()) 
	 	SX3->(DBGoTop())
	 	if !SX3->(DBSeek(SX3USER->X3_CAMPO))	 	
	 		conout(SX3USER->X3_CAMPO)
	 		cLista+=SX3USER->X3_CAMPO+Chr(13)+Chr(10)
	 		
	 		CriaCampo()
	 	endif
	 	SX3USER->(DBSkip())
	 enddo
	 
	 SX3USER->(DBCloseArea())
	 
	 MemoWrite( '/lista.txt', cLista )
Return


//+--------------------------------------------------------------+
//¦ CriaCampo                                                   ¦
//+--------------------------------------------------------------+
Static Function CriaCampo()
	#define DBS_NAME	1
	local cField, nPos
	local cOrdem:=nxtSeq(SX3USER->X3_ARQUIVO)	
		
	RecLock('SX3',.T.) 
		
	FOR nPos := 1 TO SX3->(FCOUNT())	
		cField:=SX3->(DBFieldInfo(DBS_NAME,nPos))
		SX3->&(cField):=SX3USER->&(cField)	
	Next  
		
	SX3->X3_ORDEM  := cOrdem
	SX3->X3_RESERV := Chr(254) + Chr(192)			

	MsUnlock()
	X31UPDTABLE(SX3USER->X3_ARQUIVO) //Efetua a atualização da tabela
return



//+--------------------------------------------------------------+
//¦ nxtSeq - Pega a ordem mais alta no SX3                       ¦
//+--------------------------------------------------------------+
Static Function nxtSeq(cAlias)
	Local cOrdem:='01'
	
	SX3->(DBSetOrder(1)) //X3_ARQUIVO+X3_ORDEM
	SX3->(DBSeek(cAlias))
	
	while !SX3->(eof()) .AND. SX3->X3_ARQUIVO==cAlias
		cOrdem:=SX3->X3_ORDEM
		SX3->(DBSkip())	
	EndDo
	
return cOrdem
