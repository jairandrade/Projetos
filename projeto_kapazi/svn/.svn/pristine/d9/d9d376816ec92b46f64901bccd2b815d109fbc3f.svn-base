#include "protheus.ch"
#INCLUDE "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

User function KFATR20()
    Local aArea     := GetArea()
    Local cCliente  := "056333" //Space(6)
    Local cLoja     := "01" // Space(2)
    Local dDtIni    := Date()-30
    Local dDtFim    := Date()
    Local nLinha    := 0
    Local nCol1     := 0
    Local nCol2     := 0
    Local oCliente
    Local oLoja
    Local oDtIni
    Local oDtFim
    Local oBtAtu
    Local cCadastro := "Geração de packing list"
    Local cSearch   := Space(6)
    Local oSearch

    // funcao botao ok
	Local 	bOkb	 	:= {|| oDlgPack:End() }
	// funcao cancelar
	Local 	bCancel 	:= {|| oDlgPack:End() }
	// msg ao deletar
	Local 	lMsgDel		:= .F.
	// botoes
	Local 	aButtons	:= {}
	// exibe mashups
	Local 	lMashups	:= .F.
	// imprime padrao
	Local 	lImpCad		:= .F.
	// botoes padra
	Local 	lPadrao		:= .F.
	// exibe botao ok
	Local 	lHasOk		:= .T.
	// exibe walk
    Local 	lWalkThru	:= .F.
    Local   cAlias      := ""
    Local   nReg        := 0

    Private aColsPed    := {{.F.,"",StoD(""),Stod(""),{{"","","","","",0,""}}}}
    Private aColsProd   := {{"","","","","",0,""}}
	// tamanho da tela
	Private aSize		:= {}
	// objetos contidos na tela
	Private aObjects	:= {}
	// array tamanho da tela
	Private aInfo		:= {}
	// posicao dos getdados
    Private aPosObj		:= {}
    Private oLbxPed
    Private oLbxProd
	// marcado
	private oOk       := LoadBitmap( GetResources(), "LBOK")
	// desmarcado
    private oNo       := LoadBitmap( GetResources(), "LBNO")
    
    Static oDlgPack

    screenSize()

    DEFINE MSDIALOG oDlgPack TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] pixel 

        // margem do filtro
        @ aPosObj[1,1], aPosObj[1,2] Group to aPosObj[1,3], aPosObj[1,4]  Prompt "[ Filtro ]" of oDlgPack Pixel

        nLinha  := aPosObj[1,1] + 10 
        nCol1   := aPosObj[1,2] + 10
        nCol2   := aPosObj[1,2] + 50
        nCol3   := nCol2 + 65
        nCol4   := nCol3 + 45
        nCol9   := aPosObj[1,4] - 45
        nUltLin := aPosObj[1,3] - 17

        @ nLinha	, nCol1 	Say "Cliente:" PIXEL
		@ nLinha-1	, nCol2		MsGet oCliente 	Var cCliente 	Picture PesqPict("SA1","A1_COD") SIZE 050,08 F3 "SA1" OF oDlgPack PIXEL //Valid VldRec(@cRecCod,@cRecDesc,@cMaq)	
        @ nLinha	, nCol3 	Say "Loja:" PIXEL
		@ nLinha-1	, nCol4		MsGet oLoja 	Var cLoja    	Picture PesqPict("SA1","A1_LOJA") SIZE 050,08 OF oDlgPack PIXEL 

        nLinha += 12
        @ nLinha	, nCol1 	Say "Dt Ini Libera:" PIXEL
		@ nLinha-1	, nCol2		MsGet oDtIni 	Var dDtIni   	Picture PesqPict("SC9","C9_DATALIB") SIZE 050,08 OF oDlgPack PIXEL 
        @ nLinha	, nCol3 	Say "Dt Fim Libera:" PIXEL
        @ nLinha-1	, nCol4		MsGet oDtFim 	Var dDtFim    	Picture PesqPict("SC9","C9_DATALIB") SIZE 050,08 OF oDlgPack PIXEL 

        nLinha += 12
        // botao atualizar
        @ nUltLin   , nCol9 BUTTON oBtAtu PROMPT "Atualizar" 	SIZE 037, 012 OF oDlgPack ACTION {|| { Processa( { || KFATR20R(cCliente,cLoja,dDtIni,dDtFim) }, "Carregando Dados..."			)	 } } PIXEL
        // margem do filtro

        // margem pedido 
        @ aPosObj[2,1], aPosObj[2,2] Group to aPosObj[2,3], aPosObj[2,4]/3 Prompt "[ Pedidos ]" of oDlgPack  Pixel
        // margem pedido 

        
        // margem produto direita embaixo
        @ aPosObj[2,1], aPosObj[2,2]+aPosObj[2,4]/3 Group to aPosObj[2,3], aPosObj[2,4] PROMPT "[ Produtos ]" of oDlgPack  Pixel
        // margem produto direita embaixo

        nLinha  := aPosObj[2,1] + 10
        nSize   := (aPosObj[2,2]+aPosObj[2,4]/3) - 15 - (nCol1 + 25 ) 
        @ nLinha	, nCol1 - 5	    Say "Pesquisar: " PIXEL
        @ nLinha-1	, nCol1 + 27    MsGet oSearch 	Var cSearch	Picture PesqPict("SC9","C9_PEDIDO") SIZE nSize,08 OF oDlgPack PIXEL 
        
        @ nLinha    , aPosObj[2,2]+aPosObj[2,4]/3 + 5 ListBox oLbxProd Fields Header size ((aPosObj[2,4]-aPosObj[2,2])/3*2)-15,aPosObj[2,3]-aPosObj[2,1]-15 of oDlgPack Pixel

        nLinha += 12
        @ nLinha    ,aPosObj[2,2]+5 ListBox oLbxPed Fields Size ((aPosObj[2,4]-aPosObj[2,2])/3)-10,aPosObj[2,3]-aPosObj[2,1]-25 of oDlgPack  Pixel
        AtuLbx()

    ACTIVATE MSDIALOG oDlgPack ON INIT EnchoiceBar(oDlgPack,bOkb,bCancel,lMsgDel,aButtons,nReg,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

    RestArea(aArea)
Return

Static Function screenSize()
	aSize := MsAdvSize()

	aObjects := {}
	AAdd( aObjects, { 060, 060, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )	
Return

Static Function KFATR20R(cCliente,cLoja,dDtIni,dDtFim)
    Local aArea := GetArea()
    Local cQuery:= ""
    Local cTemp := GetNextAlias()
    Local aItem := {}
    Local nPos  := 0

    aColsPed    := {}
    aColsProd   := {}

    ProcRegua(0)
    IncProc()
    IncProc()

    cQuery += "SELECT "+ENTER
	cQuery += "	C6_NUM "+ENTER
	cQuery += "	,C9_DATENT "+ENTER
	cQuery += "	,C9_DATALIB "+ENTER
	cQuery += "	,C9_ITEM "+ENTER
	cQuery += "	,C9_SEQUEN "+ENTER
	cQuery += "	,C9_PRODUTO "+ENTER
	cQuery += "	,C6_DESCRI "+ENTER
	cQuery += "	,C9_QTDLIB "+ENTER
	cQuery += "	,C6_UM "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" SC9 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C6_FILIAL   = C9_FILIAL "+ENTER
	cQuery += "		AND C6_NUM      = C9_PEDIDO "+ENTER
	cQuery += "		AND C6_ITEM     = C9_ITEM "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "	SC9.D_E_L_E_T_	<> '*' "+ENTER
	cQuery += "	AND C9_FILIAL	 = '"+xFilial("SC9")+"' "+ENTER
	cQuery += "	AND C9_CLIENTE	 = '"+cCliente      +"' "+ENTER
	cQuery += "	AND C9_LOJA		 = '"+cLoja         +"' "+ENTER
	cQuery += "	AND C9_DATALIB	>= '"+DtoS(dDtIni)  +"' "+ENTER
	cQuery += "	AND C9_DATALIB	<= '"+DtoS(dDtFim)  +"' "+ENTER
	cQuery += "	AND C9_NFISCAL	 = '' "+ENTER
	cQuery += "	AND C9_BLCRED	 = '' "+ENTER
	cQuery += "	AND C9_BLEST	<> '' "+ENTER
	cQuery += "	AND 0 = (	SELECT COUNT(*)  "+ENTER
	cQuery += "				FROM "+RetSqlName("Z03")+" "+ENTER
	cQuery += "				WHERE D_E_L_E_T_	<> '*'  "+ENTER
	cQuery += "					AND Z03_FILIAL	 = C9_FILIAL  "+ENTER
	cQuery += "					AND Z03_PEDIDO	 = C9_PEDIDO "+ENTER
	cQuery += "			) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY  "+ENTER
	cQuery += "	C6_NUM "+ENTER
	cQuery += "	,C9_DATENT "+ENTER
	cQuery += "	,C9_DATALIB "+ENTER
	cQuery += "	,C9_ITEM "+ENTER
	cQuery += "	,C9_SEQUEN "+ENTER
    
    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif
    
    TcQuery cQuery New Alias (cTemp)

    If !(cTemp)->( EOF() )
        
        TCSetField(cTemp,"C9_DATENT"    ,"D")
        TCSetField(cTemp,"C9_DATALIB"   ,"D")

        While !(cTemp)->( EOF() )
            aItem   := {}
            nPos    := aScan(aColsPed,{|x| x[2] == (cTemp)->C6_NUM })

            If nPos == 0
                aadd(aItem,.F.                  )
                aadd(aItem,(cTemp)->C6_NUM      )
                aadd(aItem,(cTemp)->C9_DATENT   )
                aadd(aItem,(cTemp)->C9_DATALIB  )
                aadd(aItem,{}                   )
                aadd(aColsPed,aItem)
                nPos := Len(aColsPed)
            Endif
            
            aItem := {}
            aadd(aItem,(cTemp)->C6_NUM      ) // 1
            aadd(aItem,(cTemp)->C9_ITEM     ) // 2
            aadd(aItem,(cTemp)->C9_SEQUEN   ) // 3
            aadd(aItem,(cTemp)->C9_PRODUTO  ) // 4 
            aadd(aItem,(cTemp)->C6_DESCRI   ) // 5 
            aadd(aItem,(cTemp)->C9_QTDLIB   ) // 6
            aadd(aItem,(cTemp)->C6_UM       ) // 7
            aadd(aColsPed[nPos][5],aItem)

            (cTemp)->( DbSkip() )
        Enddo
    Endif

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif
    
    AtuLbx()

    RestArea(aArea)
Return

Static Function AtuLbx(cID)
    Local aHeadPed  := {" " ,"Pedido","Dt. Entrega"  ,"Dt. Liberação"}
    Local aSizePed  := {10  ,30      ,15             ,15             }
    Local aHeadProd := {"Item"  ,"Sequência","Produto"   ,"Descrição"    ,"Qtde" ,"UM"   }
    Local aSizeProd := {20      ,20         ,30          ,50             ,20     ,10     }

    If Empty(AllTrim(cID))
        aColsProd := aClone(aColsPed[1][5])
    Endif

    If cID == "PRODUTO" .or. Empty(AllTrim(cId))
        oLbxProd:aHeaders   := aHeadProd
        oLbxProd:aColSizes  := aSizeProd
        oLbxProd:lAdjustColSize := .T.
        oLbxProd:SetArray(aColsProd)
        oLbxProd:bLine := {|| {     aColsProd[oLbxProd:nAt][2] ,; // item
                                    aColsProd[oLbxProd:nAt][3] ,; // sequencia
                                    aColsProd[oLbxProd:nAt][4] ,; // produto
                                    aColsProd[oLbxProd:nAt][5] ,; // descricao
                                    aColsProd[oLbxProd:nAt][6] ,; // qtde liberada
                                    aColsProd[oLbxProd:nAt][7]  ; // um
                                }}
        oLbxProd:Refresh()
    Endif

    If cID == "PEDIDOS" .or. Empty(AllTrim(cId))
        oLbxPed:aHeaders    := aHeadPed
        oLbxPed:aColSizes   := aSizePed
        oLbxPed:lAdjustColSize:= .T.
        oLbxPed:SetArray(aColsPed)
        oLbxPed:bLine := {|| {	Iif(aColsPed[oLbxPed:nAt][1], oOk, oNo) ,; // selecao
                                    aColsPed[oLbxPed:nAt][2] 	        ,; // pedido
                                    aColsPed[oLbxPed:nAt][3] 		    ,; // data entrega
                                    aColsPed[oLbxPed:nAt][4] 		     ; // data liberacao 
                            }} 

        oLbxPed:Refresh()
    Endif

Return
