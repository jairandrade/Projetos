/***********************adm***********************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda - inclusão da linha                                                                                          **/
/** Ponto de entrada M410LIOK                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 04/05/2015 | Marcos Sulivan									| Ponto de entrada para validar se produto esta bloqueado para comercializacao   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   
//
User Function M410LIOK()
Local aArea		:= GetArea()
Local lRetp		:=	.T.  

If (IsInCallStack("A410Inclui")) .OR. (IsInCallStack("A410PCopia")) .OR. (IsInCallStack("A410Altera"))
	lRetp	:=	U_VALPRBL() 
EndIf

If	(lRetp .AND.  M->C5_TIPO = 'N' )
	lRetp	:=	U_VALOPEC()
EndIf

RestArea(aArea)
Return(lRetp)  



/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 19/05/2017 | Marcos Sulivan									| VALIDA A OPERACAO INFORMADA NO CABECALHO  **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/ 
User Function	VALOPEC()
Local aArep  	 := GetArea() 
Local nAa		 := 0
Local nAb		 := 0 
Local cTesc		 := ""
Local cTesi		 := ""

//POSICAO DO CAMPO
nAa :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_OPER"}) 
nAb :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"}) 
nAc :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"}) 
nAd :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_NFORI"}) 

//MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")          
//MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")          
lRetc	:=	.T.
cTesc	:=	MaTesInt(2,M->C5_K_OPER,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[n,nAc],"C6_TES") 
cTesi	:=	MaTesInt(2,aCols[n,nAa],M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),aCols[n,nAc],"C6_TES")

If	(cTesc == aCols[n,nAb] .OR. ALLTRIM(M->C5_K_OPER) = "07" )   

 	RestArea(aArep)
	Return .T.

EndIf

If !(aCols[n,nAa]	==	M->C5_K_OPER)

	MSGALERT("Confira o Campo Operacao", "ATENCAO!" )
	lRetc	:=	.F.

EndIf

RestArea(aArep)

Return lRetc

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 04/05/2015 | Marcos Sulivan					| Ponto de entrada para validar se produto esta bloqueado para comercializacao   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   
User  Function VALPRBL()
Local aArea	:= GetArea() 
Local nAx	:= 0
Local nAy	:= 0
Private nXX := 1
Private nAW	:= 0
Private cItem := ""
Private cItemBlq := ""

//POSICAO DO CAMPO
nAx :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
nAW :=	aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})

lRet	:=	.T.
cFil	:= Alltrim(SM0->M0_CODFIL)
cEmp	:= Alltrim(SM0->M0_CODIGO) 

If  IsInCallStack("A410TudOk") //se pe total
		For nXX := 1 To Len(aCols)
			
			If !aCols[nXX,Len(aHeader)+1]

				cProd := aCols[nXX,nAx]
				cItem := aCols[nXX,nAW]

				DBselectArea('SZ3')
				SZ3->(dbSetOrder(1))
				SZ3->(DbGoTop())
				If (SZ3->(dbSeek((xFilial("SZ3") + cProd))))

					If !ValidPrd() //Valida se o produto possui bloqueio temporário
						lRet	:=	.F.
					EndIf

				EndIf

			EndIf 
		Next
		iF !Empty(cItemBlq)
			MsgAlert("Os Seguintes itens estao bloqueados -> " + Substr(cItemBlq,1,Len(cItemBlq) -1),"Kapazi")
		eNDiF
		SZ3->(DbCloseArea('SZ3'))

	Else //IsInCallStack("M410LIOK") //
		/*
		n := Len(Acols)
		cProd := aCols[n,nAx]
		cItem := aCols[n,nAW]

		DBselectArea('SZ3')
		SZ3->(dbSetOrder(1))
		SZ3->(DbGoTop())
		If (SZ3->(dbSeek((xFilial("SZ3") + cProd))))

			If !ValidPrd() //Valida se o produto possui bloqueio temporário
				lRet	:=	.F.
			EndIf

		EndIf
		*/
EndIf

RestArea(aArea)
Return lRet  

//Valida o produto
Static Function ValidPrd(cProd)
Local lRet := .t.

If cEmpAnt == "01"
	
	If cFilAnt =="01" //EMPRESA 01 FILIAL 01
		If Alltrim(SZ3->Z3_EMP1_01) == "1"
			lRet	:=	.F.
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="02" //EMPRESA 01 FILIAL 02
		If Alltrim(SZ3->Z3_EMP1_02) == "1"
			lRet	:=	.F.
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="03" //EMPRESA 01 FILIAL 03
		If Alltrim(SZ3->Z3_EMP1_03) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="04" //EMPRESA 01 FILIAL 04
		If Alltrim(SZ3->Z3_EMP1_04) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf		

	If cFilAnt =="05" //EMPRESA 01 FILIAL 05
		If Alltrim(SZ3->Z3_EMP1_05) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

EndIf
//FIM EMPRESA 01

//INICIO DA EMPRESA 02
If cEmpAnt == "02"
	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP2_01) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

EndIf
//FIM EMPRESA 02

//INICIO EMPRESA 03
If cEmpAnt == "03"
	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP3_01) == "1"
			lRet	:=	.F.
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf 	
EndIf
//FIM EMPRESA 03	

//EMPRESA 04
If cEmpAnt == "04"

	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP4_01) == "1"
			lRet	:=	.F.   
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="02" //FILIAL 02
		If Alltrim(SZ3->Z3_EMP4_02) == "1"
			lRet	:=	.F.
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf 	

	If cFilAnt =="03" //FILIAL 03
		If Alltrim(SZ3->Z3_EMP4_03) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="04" //FILIAL 04
		If Alltrim(SZ3->Z3_EMP4_04) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="05" //FILIAL 05
		If Alltrim(SZ3->Z3_EMP4_05) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="06" //FILIAL 06
		If Alltrim(SZ3->Z3_EMP4_06) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

	If cFilAnt =="07" //FILIAL 07
		If Alltrim(SZ3->Z3_EMP4_07) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf

EndIf
//FIM EMPRESA 04	


//EMPRESA 05
If cEmpAnt == "05"

	If cFilAnt =="01" //FILIAL 01
		If Alltrim(SZ3->Z3_EMP5_01) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf 	

EndIf
//FIM EMPRESA 05

//EMPRESA 06
If cEmpAnt == "06"

	//FILIAL 01     
	If cFilAnt =="01"
		If Alltrim(SZ3->Z3_EMP6_01) == "1"
			lRet	:=	.F. 
			//MSGSTOP("Produto com bloqueio temporário para esta FILIAL!! Verique o item-> "+cItem, "KAPAZI")
			cItemBlq += cItem + ","
		EndIf
	EndIf 	

EndIf
//FIM EMPRESA 06


Return(lRet)
