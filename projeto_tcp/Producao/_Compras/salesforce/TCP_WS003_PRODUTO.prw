#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"

wsservice wsPWSProdutoTCP description "Webservice Produtos."

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata sEmpresa  as string
	wsdata sFilial   as string 
	wsdata sConteudo as string
	wsdata nNumPag   as integer
	wsdata sTipo	 as string
			  
	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSProduto  as  PWSProduto_Struct
	wsdata oPWSProdutos as  PWSProdutos_Struct
	
	// DELCARACAO DO METODOS
	wsmethod GetProdByCod description "Pesquisa pelo codigo."
	wsmethod GetProds     description "Pesquisa pela descricao."
		
endwsservice

//--------------------------------------------------
wsmethod GetProdByCod wsreceive sEmpresa,sFilial,nNumPag,sConteudo,sTipo wssend oPWSProdutos wsservice wsPWSProdutoTCP
    
	Local cAlias := GetNextAlias()                          
	Local cQuery := ""
	Local nX 	 := 1 
	Local oPWSProd := WSClassNew("PWSProduto_Struct")
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	
	Default sEmpresa := "99"
	Default sFilial	 := "01"
	
	//Se nao existir	
	If lRpc
		RPCSetType(3)
		WfPrepEnv(sEmpresa,sFilial)
	EndIf	
	      
	//Selecionando tabela de produtos	
	DbSelectArea("SB1")
	
	//USUARIO PESQUISA POR CODIGO, APRESENTO APENAS UM ITEM
	If sTipo == "CODIGO"
		
		SB1->(DBSetOrder(1))//B1_FILIAL+B1_COD
		
		if SB1->(DBSeek(xfilial("SB1") + sConteudo))	.AND. SB1->B1_MSBLQL != '1'   
			oPWSProd  := WSClassNew("PWSProduto_Struct")
			aAdd(::oPWSProdutos:Item, oPWSProd )
			   	
			::oPWSProdutos:Item[nX]:COD    := U_fStdStr2(SB1->B1_COD)
			::oPWSProdutos:Item[nX]:DESC   := U_fStdString(SB1->B1_DESC)
			::oPWSProdutos:Item[nX]:NUMPAG := cvaltochar(nNumPag)		
		ELSE
			oPWSProd  := WSClassNew("PWSProduto_Struct")
			aAdd(::oPWSProdutos:Item, oPWSProd )
			::oPWSProdutos:Item[nX]:COD    := ''
			::oPWSProdutos:Item[nX]:DESC   := ''
			::oPWSProdutos:Item[nX]:NUMPAG := ''	
		ENDIF	
	
	//USUARIO PESQUISA POR DESCRICAO, APRESENTO TUDO QUE CONTEM
	Else
		
		SB1->(DBSetOrder(3))//B1_FILIAL+B1_DESC+B1_COD
		
		cQuery += " SELECT * FROM SB1020 SB1" 
		cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' AND B1_MSBLQL != '1' " 
		cQuery += " AND ( UPPER(SB1.B1_DESC) LIKE  '%" + UPPER(sConteudo) +"%' OR UPPER(SB1.B1_COD) LIKE  '%" + UPPER(sConteudo) +"%' )"  
		
		TCQUERY cQuery New Alias (cAlias) 
		
		if (cAlias)->(!Eof())
			while (cAlias)->(!Eof())
			    
			   	oPWSProd  := WSClassNew("PWSProduto_Struct")
				aAdd(::oPWSProdutos:Item, oPWSProd )
				   	
				::oPWSProdutos:Item[nX]:COD    := U_fStdString((cAlias)->B1_COD)
				::oPWSProdutos:Item[nX]:DESC   := U_fStdString((cAlias)->B1_DESC)
				::oPWSProdutos:Item[nX]:NUMPAG := cvaltochar(nNumPag)
					
				nX++
				(cAlias)->(DBSkip())			
			enddo 
		ELSE
			oPWSProd  := WSClassNew("PWSProduto_Struct")
			aAdd(::oPWSProdutos:Item, oPWSProd )
			::oPWSProdutos:Item[nX]:COD    := ''
			::oPWSProdutos:Item[nX]:DESC   := ''
			::oPWSProdutos:Item[nX]:NUMPAG := ''	
		ENDIF
		(cAlias)->(DBCloseArea())		
	EndIf
	
	SB1->(dbCloseArea())
	
return .T. 

//--------------------------------------------------
wsmethod GetProds wsreceive sEmpresa, sFilial, nNumPag,sConteudo wssend oPWSProdutos wsservice wsPWSProdutoTCP
                                   
	Local nX := 1 
	Local oPWSProd        
	Local cAlias := GetNextAlias()                          
	Local cQuery := ""
	Local nIni   := 0
	Local nFim   := 0   
	Local nPreco := 0
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Default sEmpresa := "99"
	Default sFilial	 := "01"

	RPCSetType(3)
	WfPrepEnv(sEmpresa,sFilial)
	
	//--- Processa Paginação da Consulta de Produtos
	If nNumPag == 1
		nIni := 1
		nFim := 500
	Else
		nIni := ((nNumPag-1)*1000)+1
		nFim := (nNumPag*1000)
	EndIf	
	
	cQuery += " select * from ( "
	cQuery += " 	select ROW_NUMBER() OVER(ORDER BY B1_COD) as LINHA,"
	cQuery += " 	* from "+ RetSqlName('SB1') 
	cQuery += " 	where " 
	cQuery += " 	B1_MSBLQL <> '1' "
	IF(!EMPTY(sConteudo))
		cQuery += " AND ( UPPER(B1_DESC) LIKE  '%" + UPPER(sConteudo) +"%' OR UPPER(B1_COD) LIKE  '%" + UPPER(sConteudo) +"%' )" 
	ENDIF
	cQuery += " and D_E_L_E_T_ = ' ' "
	cQuery += " ) wlinha1 "
   	cQuery += " where "
   	cQuery += " 	wlinha1.LINHA >= "+ cValToChar(nIni) +""
   	cQuery += " and wlinha1.LINHA <= "+ cValToChar(nFim) +""
	
	TCQUERY cQuery New Alias (cAlias) 
	
	
	if (cAlias)->(!Eof())
		while (cAlias)->(!Eof())
		    
		    if !Empty(U_fStdString((cAlias)->B1_COD)) .and. !Empty(U_fStdString((cAlias)->B1_DESC))
		    
			    oPWSProd  := WSClassNew("PWSProduto_Struct")
			   	aAdd(::oPWSProdutos:Item, oPWSProd )
			   	
			   	::oPWSProdutos:Item[nX]:COD    := U_fStdString((cAlias)->B1_COD)
				::oPWSProdutos:Item[nX]:DESC   := U_fStdString((cAlias)->B1_DESC)
				::oPWSProdutos:Item[nX]:NUMPAG := cvaltochar(nNumPag)
				
			    nX++
				(cAlias)->(DBSkip())
			endif
		enddo 
	else
		    oPWSProd  := WSClassNew("PWSProduto_Struct")
    endif	
	
	(cAlias)->(DBCloseArea())
	
return .T.

//--------------------------------------------------
wsstruct PWSProduto_Struct  

	wsdata COD as string
	wsdata DESC as string  
	wsdata NUMPAG as string  

endwsstruct

//--------------------------------------------------
wsstruct PWSProdutos_Struct  

	wsdata Item as array of PWSProduto_Struct optional
	
endwsstruct 