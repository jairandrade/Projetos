/**
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Customização                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! ACD                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_AACD011                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Devolução de Material                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/10/2015                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
**/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

#define CAB 1
#define ITN 2

#DEFINE CRLF (chr(13)+chr(10))

User Function AACD011()

	Local aArea     := GetArea()
	Local aAreaCB7	:= CB7->(GetArea())
	Local aAreaCB8	:= CB8->(GetArea())
	Local nCntFor   := 0
	
	Private cAlias		:= "CB7"
	Private nReg		:= CB7->(RecNo())
	Private nOpcx		:= 4	
	
	Private aCampos 	:= {}
	Private	cCadastro	:= "Devolução de Material"
	Private aObjects	:= {}
	Private aPosObj		:= {}
	Private aSizeAut	:= MsAdvSize(.T.)
	
//	Private oOk			:= LoadBitmap(GetResources(),"LBOK")
//	Private oNo			:= LoadBitmap(GetResources(),"LBNO")

	Private aSldDoc		:= {}

	Private nPosPrd 	:= 0
	Private nPosDes 	:= 0
	Private nPosAmz		:= 0
	Private nPosEnd		:= 0
	Private nPosSld		:= 0
	Private nPosDev 	:= 0
	Private nPosOp 		:= 0
	Private nPosCta		:= 0
	Private nPosICt		:= 0
	Private nPosReq		:= 0
	Private nPosCC		:= 0
	
//	Private	nSldPrd		:= 0

	Private oGetPP		:= Nil
	Private oGetSel		:= Nil
	Static oDlgPP		:= Nil
	Static oDlgSel		:= Nil	
	
	aAdd(aObjects,{315,84,.T.,.F.})
	aAdd(aObjects,{100,20,.T.,.T.})
	
	aInfo := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects)

	If CB7->CB7_STATUS != "9"
		Aviso(cCadastro,"A devolução é permitida somente para status 'Embarque Finalizado'.",{"Ok"},1)
		Return
	EndIf

	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := (cAlias)->&(FieldName(nCntFor))
		AADD(aCampos,FieldName(nCntFor))
	Next nCntFor

	DEFINE MSDIALOG oDlgPP TITLE cCadastro From aSizeAut[7],aSizeAut[1] To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	Enchoice(cAlias,nReg,nOpcx,nil,nil,nil,aCampos,aPosObj[1],nil,nOpcx,nil,nil,nil,nil,nil,.F.)
	MB001()
	ACTIVATE MSDIALOG oDlgPP CENTER ON INIT EnchoiceBar(oDlgPP,{|| U_AACD11EX(),oDlgPP:End()},{|| oDlgPP:End()},,)
 	
 	RestArea(aAreaCB8)
 	RestArea(aAreaCB7)
	RestArea(aArea)

Return

User Function AACD11EX()

	Local aMata241 	:= {}
	Local cQuery	:= ""
	Local cDoc		:= ""
	Local cOrdem	:= ""
	Local nX
	Local nY
	Local cDocumento 	:= ""
	Local cTM     		:= GetMV("MV_CBREQD3")	

	cQuery := " SELECT TOP 1 ZD3_ORDEM, ZD3_DOC " + CRLF 
	cQuery += " FROM " + RetSqlName("ZD3") + " " + CRLF 
	cQuery += " WHERE " + CRLF 
	cQuery += " 		ZD3_FILIAL = '" + xFilial("ZD3") + "' " + CRLF 
	cQuery += " 	AND ZD3_ORDSEP = '" + M->CB7_ORDSEP + "' " + CRLF 
	cQuery += " 	AND D_E_L_E_T_ = ' ' " + CRLF 
	cQuery += " ORDER BY ZD3_ORDEM DESC " + CRLF 

	Memowrite("c:\temp\AACD11EX_01.sql",cQuery)
	cAliasGrv := GetNextAlias()
	TcQuery cQuery New Alias (cAliasGrv) 	

	cDoc	:= (cAliasGrv)->ZD3_DOC
	cOrdem	:= (cAliasGrv)->ZD3_ORDEM

	(cAliasGrv)->(dbCLoseARea())

	Begin Transaction

	dbSelectArea("SD3")
	SD3->(dbSetOrder(2))
	SD3->(dbGoTop())		
	If SD3->(dbSeek(xFilial("SD3")+cDoc))	

		aMata241 := {}
		aAdd(aMata241, {"D3_DOC"    , SD3->D3_DOC    , Nil})
	 	aAdd(aMata241, {"D3_TM"     , SD3->D3_TM     , Nil})
	 	aAdd(aMata241, {"D3_CC"     , SD3->D3_CC     , Nil})
	 	aAdd(aMata241, {"D3_EMISSAO", SD3->D3_EMISSAO, Nil})
		
		lMSErroAuto := .F.
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aMata241,,6)
	
		IF lMSErroAuto
			Aviso(cCadastro,"Falha no estorno da movimentacao.",{"Ok"},1)
			MostraErro()
			DisarmTransaction()
		EndIF	

	EndIf

	//Se efetuou o extorno, efetua a reserva com an nova quantidade

	aMata241 := {{/*cabeçalho*/},{/*itens*/}}
	If !lMSErroAuto
		
		cDocumento := NextDoc()

		//cabeçalho da requisição
	 	aAdd(aMata241[CAB], {"D3_DOC"    , cDocumento, Nil})
	 	aAdd(aMata241[CAB], {"D3_TM"     , cTM       , Nil})
	 	aAdd(aMata241[CAB], {"D3_EMISSAO", dDataBase , Nil})

		For nX := 1 to Len(oGetPP:aCols)
			
			If oGetPP:aCols[nX,nPosDev] > 0
			
			 	//Calcula a nova quantidade
			 	nSaldo := oGetPP:aCols[nX,nPosSld] - oGetPP:aCols[nX,nPosDev]
	
				cQuery := " SELECT CB8_NUMSER, CB8_LOTECT, CB8_TRT " + CRLF
				cQuery += " FROM " + RetSqlName("CB8") + " " + CRLF
				cQuery += " WHERE " + CRLF
				cQuery += " 		CB8_FILIAL = '" + xFilial("CB8") + "' " + CRLF
				cQuery += " 	AND CB8_ORDSEP = '" + M->CB7_ORDSEP + "' " + CRLF
				cQuery += " 	AND CB8_OP = '" + oGetPP:aCols[nX,nPosOp] + "' " + CRLF
				cQuery += " 	AND CB8_PROD = '" + oGetPP:aCols[nX,nPosPrd] + "' " + CRLF
				cQuery += " 	AND CB8_LOCAL = '" + oGetPP:aCols[nX,nPosAmz] + "' " + CRLF
				cQuery += " 	AND CB8_LCALIZ = '" + oGetPP:aCols[nX,nPosEnd] + "' " + CRLF
				cQuery += " 	AND D_E_L_E_T_ = ' ' " + CRLF

				Memowrite("c:\temp\MB001_01.sql",cQuery)
				cAliasGrv := GetNextAlias()
				TcQuery cQuery New Alias (cAliasGrv) 	
	
				For nY := 1 to nSaldo
	
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + oGetPP:aCols[nX,nPosPrd]))
	
					aAdd(aMata241[ITN],{})
					aAdd( aTail(aMata241[ITN]), {"D3_COD"    	,oGetPP:aCols[nX,nPosPrd]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_UM"     	,SB1->B1_UM       			,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_QUANT"  	,1  						,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOCAL"  	,oGetPP:aCols[nX,nPosAmz]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOCALIZ"	,oGetPP:aCols[nX,nPosEnd]  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_NUMSERI"	,(cAliasGrv)->CB8_NUMSER  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOTECTL"	,(cAliasGrv)->CB8_LOTECT  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_OP"     	,oGetPP:aCols[nX,nPosOp]   	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_EMISSAO"	,dDataBase        			,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_TRT"    	,(cAliasGrv)->CB8_TRT     	,nil})
	
					aAdd( aTail(aMata241[ITN]), {"D3_CONTA"    	,oGetPP:aCols[nX,nPosCta] 	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_ITEMCTA"   ,oGetPP:aCols[nX,nPosICt] 	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_REQUISI"   ,oGetPP:aCols[nX,nPosReq]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_CC"   		,oGetPP:aCols[nX,nPosCC] 	,nil})
	
				Next nY		
	
			Else
	
				cQuery := " SELECT CB8_NUMSER, CB8_LOTECT, CB8_TRT " + CRLF
				cQuery += " FROM " + RetSqlName("CB8") + " " + CRLF
				cQuery += " WHERE " + CRLF
				cQuery += " 		CB8_FILIAL = '" + xFilial("CB8") + "' " + CRLF
				cQuery += " 	AND CB8_ORDSEP = '" + M->CB7_ORDSEP + "' " + CRLF
				cQuery += " 	AND CB8_OP = '" + oGetPP:aCols[nX,nPosOp] + "' " + CRLF
				cQuery += " 	AND CB8_PROD = '" + oGetPP:aCols[nX,nPosPrd] + "' " + CRLF
				cQuery += " 	AND CB8_LOCAL = '" + oGetPP:aCols[nX,nPosAmz] + "' " + CRLF
				cQuery += " 	AND CB8_LCALIZ = '" + oGetPP:aCols[nX,nPosEnd] + "' " + CRLF
				cQuery += " 	AND D_E_L_E_T_ = ' ' " + CRLF

				Memowrite("c:\temp\MB001_01.sql",cQuery)
				cAliasGrv := GetNextAlias()
				TcQuery cQuery New Alias (cAliasGrv) 	
	
				For nY := 1 to oGetPP:aCols[nX,nPosSld] 
	
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + oGetPP:aCols[nX,nPosPrd]))
	
					aAdd(aMata241[ITN],{})
					aAdd( aTail(aMata241[ITN]), {"D3_COD"    	,oGetPP:aCols[nX,nPosPrd]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_UM"     	,SB1->B1_UM       			,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_QUANT"  	,1  						,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOCAL"  	,oGetPP:aCols[nX,nPosAmz]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOCALIZ"	,oGetPP:aCols[nX,nPosEnd]  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_NUMSERI"	,(cAliasGrv)->CB8_NUMSER  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_LOTECTL"	,(cAliasGrv)->CB8_LOTECT  	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_OP"     	,oGetPP:aCols[nX,nPosOp]   	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_EMISSAO"	,dDataBase        			,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_TRT"    	,(cAliasGrv)->CB8_TRT     	,nil})
	
					aAdd( aTail(aMata241[ITN]), {"D3_CONTA"    	,oGetPP:aCols[nX,nPosCta] 	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_ITEMCTA"   ,oGetPP:aCols[nX,nPosICt] 	,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_REQUISI"   ,oGetPP:aCols[nX,nPosReq]   ,nil})
					aAdd( aTail(aMata241[ITN]), {"D3_CC"   		,oGetPP:aCols[nX,nPosCC] 	,nil})
	
				Next nY	
					
			EndIf
			
		Next nX
				
		SD3->(DbSetOrder(1))
		If len(aMata241[ITN]) > 0 // Verifica se tem item que deve manter a baixa
			lMSErroAuto := .F.
			MSExecAuto({|x,y|MATA241(x,y)},aMata241[CAB],aMata241[ITN],3)
	
			IF lMSErroAuto
				Aviso(cCadastro,"Falha na gravacao movimentacao TM " + cTM + ".",{"Ok"},1)
				MostraErro()
				DisarmTransaction()
			EndIF	
		EndIf
	
	EndIf

	End Transaction

Return

/*/{Protheus.doc} MB001
Cria MsNewGetDados com Mark Browse para seleção
@type function
@author Mário
@since 28/10/2015
@version 1.0
/*/Static Function MB001() 

	Local nX			:= 0
	Local nTamSX3		:= 0
	Local nSldPrd		:= 0		
	Local aFieldFill 	:= {}
	Local aFields 		:= {"CB8_PROD","B1_DESC","CB8_LOCAL","CB8_LCALIZ","CB8_OP","SALDO","XCONTA","XITEMCTA","XREQUISI","XCC","QTD_DEV"} 
	Local aAlterFields 	:= {"XCONTA","XITEMCTA","XREQUISI","XCC","QTD_DEV"} 
	
	Local aHeader		:= {}
	Local aCols			:= {}
	
	Local cValid 		:= ""
	Local cQuery		:= ""
	Local cAliasCar		:= Nil
	Local cAliasVal		:= Nil
	Local aField := {}
	Local nX
	Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																			cField,;
																			X3PICTURE(cField),; 
																			TamSX3(cField)[1],;
																			TamSX3(cField)[2],;
																			GetSx3Cache(cField, "X3_VALID"),;
																			GetSx3Cache(cField, "X3_USADO"),;
																			FwSX3Util():GetFieldType(cField),;
																			X3F3(cField),;
																			GetSx3Cache(cField, "X3_CONTEXT"),;
																			X3CBOX(cField),;
																			GetSx3Cache(cField, "X3_RELACAO");
																			}))}
	
	
	aEval(aFields,bBlock)
	aHeader := aClone(aField)
	
	For nX := 1 to Len(aFields)
		
		If AllTrim(aFields[nX]) == "QTD_DEV"
			aAdd(aHeader,{"Qtd.Dev."	,"QTD_DEV"	,PesqPict("CB8","CB8_QTDORI")	,TamSx3("CB8_QTDORI")[1]	,TamSx3("CB8_QTDORI")[2]	,"U_AACD11VL()"				,"","N","","","",""})
		ElseIf AllTrim(aFields[nX]) == "SALDO"
			aAdd(aHeader,{"Saldo"		,"SALDO"	,PesqPict("CB8","CB8_QTDORI")	,TamSx3("CB8_QTDORI")[1]	,TamSx3("CB8_QTDORI")[2]	,""							,"","N","","","",""})
		ElseIf AllTrim(aFields[nX]) == "XCONTA"
			aAdd(aHeader,{"C Contabil"	,"XCONTA"	,PesqPict("SD3","D3_CONTA")		,TamSx3("D3_CONTA")[1]		,TamSx3("D3_CONTA")[2]		,"vazio().or.Ctb105Cta()"	,"","C","CT1","","",""})
		ElseIf AllTrim(aFields[nX]) == "XITEMCTA"
			aAdd(aHeader,{"Item Conta"	,"XITEMCTA"	,PesqPict("SD3","D3_ITEMCTA")	,TamSx3("D3_ITEMCTA")[1]	,TamSx3("D3_ITEMCTA")[2]	,"vazio().or. Ctb105Item()"	,"","C","CTD","","",""})
		ElseIf AllTrim(aFields[nX]) == "XREQUISI"
			aAdd(aHeader,{"Requisitante","XREQUISI"	,PesqPict("SD3","D3_REQUISI")	,TamSx3("D3_REQUISI")[1]	,TamSx3("D3_REQUISI")[2]	,""							,"","C","SRA","","",""})
		ElseIf AllTrim(aFields[nX]) == "XCC"
			aAdd(aHeader,{"C Custo"		,"XCC"		,PesqPict("SD3","D3_CC")		,TamSx3("D3_CC")[1]			,TamSx3("D3_CC")[2]			,"vazio().or. Ctb105CC()"	,"","C","CTT   ","","",""})
		EndIF
		
	Next nX     

	nPosPrd := aScan(aHeader,{|X|Alltrim(X[2])=="CB8_PROD"})
	nPosDes := aScan(aHeader,{|X|Alltrim(X[2])=="B1_DESC"})
	nPosAmz	:= aScan(aHeader,{|X|Alltrim(X[2])=="CB8_LOCAL"})
	nPosEnd := aScan(aHeader,{|X|Alltrim(X[2])=="CB8_LCALIZ"})
	nPosSld	:= aScan(aHeader,{|X|Alltrim(X[2])=="SALDO"})
	nPosDev := aScan(aHeader,{|X|Alltrim(X[2])=="QTD_DEV"})
	nPosOp	:= aScan(aHeader,{|X|Alltrim(X[2])=="CB8_OP"})
	nPosCta	:= aScan(aHeader,{|X|Alltrim(X[2])=="XCONTA"})
	nPosICt	:= aScan(aHeader,{|X|Alltrim(X[2])=="XITEMCTA"})
	nPosReq	:= aScan(aHeader,{|X|Alltrim(X[2])=="XREQUISI"})
	nPosCC	:= aScan(aHeader,{|X|Alltrim(X[2])=="XCC"})
	
	aEval(aHeader,{|aCampo,nI| aAdd(aFieldFill,If(FieldPos(aCampo[nI,2])>0,CriaVar(aCampo[nI,2],.F.),nil)) } )
	aAdd(aFieldFill, .f.)
	
	
	cQuery := "	SELECT DISTINCT CB8_PROD, CB8_LOCAL, CB8_LCALIZ, CB8_OP " + CRLF
	cQuery += "	FROM " + RetSqlName("CB8") + " " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "			CB8_FILIAL = '" + xFilial("CB8") + "' " + CRLF
	cQuery += "		AND CB8_ORDSEP = '" + M->CB7_ORDSEP + "' " + CRLF
	cQuery += "		AND D_E_L_E_T_ = ' ' " + CRLF
	
	Memowrite("c:\temp\MB001_01.sql",cQuery)
	cAliasCar := GetNextAlias()
	TcQuery cQuery New Alias (cAliasCar) 

	While !(cAliasCar)->(Eof())	

		cQuery := "	SELECT * " + CRLF
		cQuery += "	FROM " + RetSqlName("SD3") + " " + CRLF
		cQuery += "	WHERE " + CRLF 
		cQuery += "			D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
		cQuery += "		AND D3_OP = '" + (cAliasCar)->CB8_OP + "' " + CRLF
		cQuery += "		AND D3_COD = '" + (cAliasCar)->CB8_PROD + "' " + CRLF 
		cQuery += "		AND D3_LOCAL = '" + (cAliasCar)->CB8_LOCAL + "' " + CRLF
		cQuery += "		AND D3_LOCALIZ = '" + (cAliasCar)->CB8_LCALIZ + "' " + CRLF
		cQuery += "		AND D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	ORDER BY D3_DOC, D3_TM DESC " + CRLF

		Memowrite("c:\temp\MB001_02.sql",cQuery)
		cAliasVal := GetNextAlias()
		TcQuery cQuery New Alias (cAliasVal) 

		nSldPrd := 0
	
		While !(cAliasVal)->(Eof())	

			If (cAliasVal)->D3_TM >= "501"
				nSldPrd += (cAliasVal)->D3_QUANT
			Else
				nSldPrd -= (cAliasVal)->D3_QUANT
			EndIf
            
			cConta   := (cAliasVal)->D3_CONTA
			cCC		 := (cAliasVal)->D3_CC
			cItemCta := (cAliasVal)->D3_ITEMCTA 
			cRequis	 := (cAliasVal)->D3_REQUISI

			(cAliasVal)->(dbSkip())
						 
		EndDo
		
		(cAliasVal)->(dbCloseArea())
	
	 	aAdd(aCols,{;
					(cAliasCar)->CB8_PROD,;
					Posicione("SB1",1,xFilial("SB1")+(cAliasCar)->CB8_PROD,"B1_DESC"),;
					(cAliasCar)->CB8_LOCAL,;
					(cAliasCar)->CB8_LCALIZ,;
					(cAliasCar)->CB8_OP,;
					nSldPrd,;
					cConta,;
					cItemCta,;
					cRequis,;
					cCC,;
					0.00,;
					.F.;
			 	})
			 	
//					Space(TamSx3("D3_CONTA")[1]),;
//					Space(TamSx3("D3_ITEMCTA")[1]),;
//					Space(TamSx3("D3_REQUISI")[1]),;
//					Space(TamSx3("D3_CC")[1]),;
		
		(cAliasCar)->(dbSkip())
		
	EndDo	
	
	(cAliasCar)->(dbCloseArea())

	oGetPP := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],GD_UPDATE,;
									"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,;
								   	"AllwaysTrue","","AllwaysTrue",oDlgPP,aHeader,aCols) 

	oGetPP:SetEditLine(.F.) 
//	oGetPP:oBrowse:bLDblClick := {|| If(oGetPP:oBrowse:nColPos == 1 ,(DUPLOCLI(),oGetPP:oBrowse:Refresh()),oGetPP:EditCell()) } 
	
Return

User Function AACD11VL()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cMsg		:= ""

	If M->QTD_DEV < 0
		cMsg := "Quantidade Inválida"
	ElseIf M->QTD_DEV > oGetPP:aCols[oGetPP:nAt,nPosSld] 
		cMsg := "A quantidade informada é superior ao total solicitado."
	ElseIf Empty(oGetPP:aCols[oGetPP:nAt,nPosCta])
		cMsg := "Campo Conta Contabil preenchimento obrigatório"
	ElseIf Empty(oGetPP:aCols[oGetPP:nAt,nPosICt])
		cMsg := "Campo Item Conta Contabil preenchimento obrigatório"
	ElseIf Empty(oGetPP:aCols[oGetPP:nAt,nPosReq])
		cMsg := "Campo Requisitante Contabil preenchimento obrigatório"
	ElseIf Empty(oGetPP:aCols[oGetPP:nAt,nPosCC]) 
		cMsg := "Campo Centro de Custo  preenchimento obrigatório" 
	EndIf
	
	If !Empty(cMsg)
		Aviso(cCadastro,cMsg,{"Ok"},1)
		lRet := .F.	
	EndIf
	
	RestArea(aArea)
	
Return lRet

Static Function NextDoc()
	Local aSvAlias:=GetArea()
	Local aSvAliasD3:=GetArea("SD3")
	Local cDoc := Space(TamSx3("D3_DOC")[1])

	SD3->(DbSetOrder(2))
	cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	While SD3->(DbSeek(xFilial("SD3")+cDoc))
		cDoc := Soma1(cDoc,Len(SD3->D3_DOC))
	Enddo

	RestArea(aSvAliasD3)
	RestArea(aSvAlias)
Return cDoc







