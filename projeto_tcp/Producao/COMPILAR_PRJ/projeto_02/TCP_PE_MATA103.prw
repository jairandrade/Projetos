/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de Entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Ponto de entrada na rotina Documento de Entrada MATA103 !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Ricardo Vieceli                                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/05/11                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
#include "protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"

/*
+------------------+---------------------------------------------------------+
!Nome              ! MTA103MNU                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Inclusão de botoes no menu da rotina                    !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Ricardo Vieceli                                  !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 04/05/2011                                              !
+------------------+---------------------------------------------------------+
*/
user Function MTA103MNU

	//aAdd(aRotina, {"Cod.Bar. Titulo","u_mCom001()",0,6})

	AAdd( aRotina, { 'GED.TCP', "U_TCPGED", 0, 4 } )
	AAdd( aRotina, { 'Imp. Etiqueta', "U_REST002", 0, 4 } )

	//Retira o conhecimento do Menu
	nPos := ASCAN(aRotina, { |x|   If(ValType(x[2])=="C",UPPER(x[2]) == "MSDOCUMENT",.F.) })
	If nPos > 0
		Adel(aRotina,nPos)
		Asize(aRotina,Len(aRotina)-1)
	EndIf

Return( Nil )

/*
+------------------+---------------------------------------------------------+
!Nome              ! MT100AGR                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Após gravaçao dos dados da nf de entrada                !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Ricardo Vieceli                                  !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 26/04/2011                                              !
+------------------+---------------------------------------------------------+
*/
user Function MT100AGR()

	/*

	//INCLUI Usuario esta incluindo uma nota
	//ALTERA Usuario esta classificando uma nota
	//Tipo da nota obrigatoriamente deve ser N=Normal
	If ( FunName() == "MATA103" ).And.( INCLUI .Or. ALTERA ).And.( SF1->F1_TIPO == "N" )

	//Funcao para alteração do codigo de barras
	u_mCom001()

	Endif

	*/

Return()

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
Ponto de entrada para alteração de titulos financeiros

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function MT103FIM()

	Local aObjects  	:= {}
	Local aPosObj   	:= {}
	Local aSizeAut  	:= MsAdvSize()
	Local aButtons 		:= {}
	Local nConfirma     := PARAMIXB[2] // Se o usuario confirmou a operação de gravação da NFE
	Local nOpcao        := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local aArea			:= GetArea()
	Local nPontos		:= 0
	Local _cUsrNf       := IF(!EMPTY(SF1->F1_USERLGI),SUBSTR( EMBARALHA(SF1->F1_USERLGI,1),3,6 ) , __cUserId)
	Local _cNomDig		:= Capital(AllTrim(UsrFullName(_cUsrNf))) //Capital(AllTrim(UsrFullName(__cUserId)))
	Local _cEmaDig		:= Lower(AllTrim(UsrRetMail(_cUsrNf)))
	Local _cEmaPar		:= Lower(AllTrim(GetMv("MV_EMAGES")))
	Local _nDifDia		:= GetMv("MV_DIFDIA")
	Local _cDestin		:= ""
	Local lIntMdt   	:= GetMv('TCP_INTMST')
	Local cDComMdt		:= GetMv('TCP_COMMDT')
	Private _cNomGes	:= ""	//"Gestor Responsável"
	Private _cEmaGes	:= ""	//Lower(AllTrim(GetMv("MV_EMAGES")))

	Private lContra		:= .f.
	Private oGet
	Private nLen		:= 0
	/* Adicionado variaveis Private para tratar Avaliação Fornecedor*/
	Private aNotas			:= {}
	Private nLaco			:= 0
	Private cRegra			:= ""
	Private cTMPZ07		:= ""
	Private nGravou      := 0
	/*Aqui termina variaveis Private para tratar Avaliação Fornecedor*/

	static oDlgI

	//Se for inclusão - Validar a diferença entre as datas de emissão/digitação para o envio do e-mail de alerta
	If (nOpcao==3 .Or. nOpcao==4) .And. (Alltrim(FunName())='MATA103') .AND. nConfirma == 1	//3=Inclusão, 4=Classificação
		_nDif := DateWorkDay(DDEmissao, DATE())	//Diferença em dias úteis

		If Month(DDEmissao) <> Month(DATE()) .Or. _nDif > _nDifDia		//Se o mês de emissão for diferente do mês da digitação ou o prazo for maior que o do parâmetro
			//BuscaApr() //Atualiza os campos do nome e e-mail do gestor (primeiro nível do grupo de aprovação dos pedidos)
			_cDestin:= AllTrim(_cEmaDig) //+ ";" + AllTrim(_cEmaGes) //+ ";" + AllTrim(_cEmaPar)
			_cMen	:= u_MontaHTML(CNFISCAL, CSERIE, CA100FOR, CLOJA, Alltrim(Posicione('SA2',1,Padr(xFilial('SA2'),2) + CA100FOR + CLOJA, 'A2_NREDUZ'))   , DDEMISSAO, CESPECIE, dDataBase, _cNomDig, _cEmaDig, _cNomGes, _cEmaGes)
			u_SendMail(,,,,_cDestin,"Lançamento de NF Fora do Prazo",_cMen,)
		EndIf

	EndIf

    /* Se for Inclusão ele verificar se precisar aprovar a nota*/
	//Removido, pois mais pra baixo chama o ACOM009
//	If (nOpcao==3 .Or. nOpcao==4) .And. Alltrim(FunName())='MATA103'  
//		if nConfirma<>1
//   			RETURN
//   		EndIf 
//		cQry := " SELECT * FROM "+RetSqlName('Z03')+" WHERE "
//		cQry += "      Z03_FILIAL = '"+xFilial('Z03')+"' AND Z03_INICIO <= '"+DtoS(dDataBase)+"' "
//		cQry += " AND (Z03_FIM >= '"+DtoS(dDataBase)+"' OR Z03_FIM = ' ')AND D_E_L_E_T_ != '*'  "
//		
//		If (Select("Z03REG") <> 0)
//			DbSelectArea("Z03REG")
//		 	Z03REG->(DbCloseArea())
//		Endif
//		                                                                       	
//		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), "Z03REG",.T., .F.)
//		
//		DbSelectArea("Z03REG")
//		Z03REG->(DbGoTop())	     
//		If !Z03REG->(EOF())  
//	   		cRegra := Z03REG->Z03_CODIGO
//		Else
//			Alert('Não existem regras vigentes!!!')
//	   		//Return .F.
//		EndIf    
//		Z03REG->(DbCloseArea())	
//	
//		RestArea(aArea)  		
//
//		GraZ07Z06() 
//	Endif

	if nConfirma<>1
		RETURN
	EndIf

   /*Kaique Mathias - 10/02/2019 
	Retirado trecho do codigo pois no padrão ja realiza a atualização desse campo.*/     

   /*IF paramixb[1]==5 ///.AND. IsInCallStack("MATA140") 
     		
   		nrecC7:=SC7->(RECNO())
	   	cSql:=" SELECT SC7.R_E_C_N_O_ REC, D1_QUANT  FROM "+RetSqlName('SD1')+" SD1"+chr(13)+chr(10)
		cSql+=" 	INNER JOIN "+RetSqlName('SC7')+"  SC7"+chr(13)+chr(10)
		cSql+=" 		ON C7_FILIAL = D1_FILIAL"+chr(13)+chr(10)
		cSql+=" 		AND C7_NUM = D1_PEDIDO"+chr(13)+chr(10)
		cSql+=" 		AND C7_ITEM = D1_ITEMPC"+chr(13)+chr(10)
		cSql+=" WHERE D1_FILIAL='"+SF1->F1_FILIAL+"'" +chr(13)+chr(10)
		cSql+=" 	AND D1_DOC='"+SF1->F1_DOC+"'"+chr(13)+chr(10)
		cSql+=" 	AND D1_SERIE ='"+SF1->F1_SERIE+"'"+chr(13)+chr(10)
		cSql+=" 	AND D1_FORNECE ='"+SF1->F1_FORNECE+"'	"+chr(13)+chr(10)
		cSql+=" 	AND D1_LOJA ='"+SF1->F1_LOJA+"'"+chr(13)+chr(10)
		cSql+=" 	AND SD1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
		cSql+=" 	AND SC7.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
	IF Select('TRC7')<>0
			TRC7->(DBCloseArea())
	EndIF
		TcQuery cSql new Alias 'TRC7' 
	WHILE !TRC7->(EOF())
		    dbSelectArea('SC7')
		    DBGoto(TRC7->REC)
		    reclock('SC7',.F.)
		   	SC7->C7_QUJE := SC7->C7_QUJE - TRC7->D1_QUANT
		    SC7->C7_ENCER := If(SC7->C7_QUANT - SC7->C7_QUJE > 0," ","E")             
			MSUNLOCK()
			TRC7->(DBSkip())
	EndDo
		SC7->(DBGOTO(nrecC7)) 
EndIF*/
    
if l103class .or. nOpcao==3
     
        nrecC7:=SC7->(RECNO())
	   	cSql:=" SELECT SC7.R_E_C_N_O_ REC, D1_QUANT  FROM "+RetSqlName('SD1')+" SD1"+chr(13)+chr(10)
		cSql+=" 	INNER JOIN "+RetSqlName('SC7')+"  SC7"+chr(13)+chr(10)
		cSql+=" 		ON C7_FILIAL = D1_FILIAL"+chr(13)+chr(10)
		cSql+=" 		AND C7_NUM = D1_PEDIDO"+chr(13)+chr(10)
		cSql+=" 		AND C7_ITEM = D1_ITEMPC"+chr(13)+chr(10)
		cSql+=" WHERE D1_FILIAL='"+SF1->F1_FILIAL+"'" +chr(13)+chr(10)
		cSql+=" 	AND D1_DOC='"+SF1->F1_DOC+"'"+chr(13)+chr(10)
		cSql+=" 	AND D1_SERIE ='"+SF1->F1_SERIE+"'"+chr(13)+chr(10)
		cSql+=" 	AND D1_FORNECE ='"+SF1->F1_FORNECE+"'	"+chr(13)+chr(10)
		cSql+=" 	AND D1_LOJA ='"+SF1->F1_LOJA+"'"+chr(13)+chr(10)
		cSql+=" 	AND SD1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
		cSql+=" 	AND SC7.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
		
	IF Select('TRC7')<>0
			TRC7->(DBCloseArea())
	EndIF
		
		TcQuery cSql new Alias 'TRC7'     
		lContra:=.f.
		
	WHILE !TRC7->(EOF())
		    
			dbSelectArea('SC7')
		    DBGoto(TRC7->REC)
		    
		if !Empty(SC7->C7_CONTRA)
		    lContra:=.T.
			exit
		EndIf
			/*Kaique Mathias - 10/02/2019 
			Retirado trecho do codigo pois no padrão ja realiza a atualização desse campo.*/
		    
			/*cSql:=" select SUM(D1_QUANT) CNT FROM "+RETSQLNAME('SD1')
		    cSql+=" WHERE D1_PEDIDO ='"+SC7->C7_NUM+"'"
		    cSql+=" AND D1_FILIAL = '"+SC7->C7_FILIAL+"'"
		    cSql+=" AND D1_ITEMPC = '"+SC7->C7_ITEM+"'"
		    cSql+=" AND D_E_L_E_T_<>'*'"           
		IF Select('TRQTD')<>0
		    	TRQTD->(DBCLOSEAREA())
		EndIF
		    TCQuery cSql New alias 'TRQTD'
		    nQtdJe:=0
		if !TRQTD->(eof())
		         nQtdJe:=TRQTD->CNT
		Endif
		    
		IF SC7->C7_QUJE < nQtdJe
		    	reclock('SC7',.F.)
		   		SC7->C7_QUJE := SC7->C7_QUJE + TRC7->D1_QUANT
		    	SC7->C7_ENCER := If(SC7->C7_QUANT - SC7->C7_QUJE > 0," ","E")             
				MSUNLOCK()
				TRC7->(DBSkip())
		EndIF */
			TRC7->(DBSkip())
	EndDo
		SC7->(DBGOTO(nrecC7))

EndIF

    // Realiza vinculo com processo de garantia/reparo caso o pedido tenha origem neste processo.
if nOpcao = 3
        U_NF1FRE(SF1->F1_DOC, SF1->F1_SERIE, SD1->D1_PEDIDO)
endif
	
IF (nOpcao==3 .Or. nOpcao==4) .And. Alltrim(FunName())='MATA103' .AND.!Empty(alltrim(cNFiscal))

		RecLock('SF1',.F.)
		SF1->F1_IDCOMPR := Posicione('SC7',1,xFilial('SC7')+SD1->D1_PEDIDO,"C7_USER")
		SF1->(MsUnlock())
	If !lContra
			U_RCOM006()
	Else
	//INICIO JAIR - 27-10-2020. Grava o STATUS de todos os documentos que foram gerados a partir da MEDICAO CONTRATOS
			RecLock('SF1',.F.)
			SF1->F1_AVALFOR := '1'
			SF1->(MsUnlock())
			//FIM JAIR - 27-10-2020
	EndIf
		U_ACOM009()

EndIf
	
	// Rotina comentada conforme alinhado com o Walter, devido a não utilização - Valtenio Totvs 17/10/2018
If !Empty(Alltrim(SF1->F1_DUPL)) .AND. (nOpcao==3  .or. l103Class) .AND. !Empty(alltrim(cNFiscal))


		//***************************************************************//
		//Inicio da criação da tela										 //
		//***************************************************************//
	
		aObjects := {}
		AAdd( aObjects, { 315,  50, .T., .T. } )
		AAdd( aObjects, { 100,  20, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		Private cCadastro 	:= 'Titulos Financeiros' 
		DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL

		@ 005, 005 group oGrpCabec to 030, 505 prompt ' Nota Fiscal ' of oDlgI	color 0,16777215 pixel
		DADOSCC()// cabecalho

		@ 040, 005 group oGrpVisual to 265, 505 prompt ' Títulos ' of oDlgI color 0,16777215 pixel
		GRIDTIT() // Grid de Criterios

		ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(.T.,oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))

		GrvHistSE2()
		grvrat()
EndIf

If  nConfirma == 1 .And. (Alltrim(FunName())='MATA103')
		oCompras  := ClassIntCompras():new()    

	IF oCompras:registraIntegracao('3',SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO,IF(nOpcao==3 .Or. nOpcao==4,'I','E'))
			oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
			ALERT(oCompras:cErro)
	ENDIF
endif

	//Anexo automatico no GED
If  ( nConfirma == 1 .And. Alltrim(FunName())='MATA103' )
	If ExistBlock("TCCO04KM")
		If ( l103class .or. (nOpcao==3 .and. Alltrim(FUNNAME()) <> 'TC04A020')) .And. !Empty(SD1->D1_PEDIDO)
				dbSelectArea("SC7")
				SC7->(dbSetOrder(1))
				SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO))
				ExecBlock("TCCO04KM",.F.,.F.)
		EndIf
	EndIf
EndIf

If ( nOpcao == 3 .Or. l103class ) .And. nConfirma == 1  //Inclusao ou Classificacao
	If ExistBlock("ACOM010W")
			ExecBlock("ACOM010W",.F.,.F.)
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DADOSCC
Montagem do cabeçalho da tela de alteração de titulos

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function DADOSCC()
	Local cNF 	:= Alltrim(SF1->F1_DOC)+' / '+SF1->F1_SERIE
	Local cForn := Alltrim(SF1->F1_FORNECE)+' / '+SF1->F1_LOJA
	Local cNome := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")

	@ 017, 010 say 'Nota Fiscal' 	size 030, 010 pixel
	@ 015, 040 get cNF 				size 080, 010 when .F. pixel
	@ 017, 130 say 'Fornecedor' 	size 030, 010 pixel
	@ 015, 160 get cForn 			size 080, 010 when .F. pixel
	@ 017, 250 say 'Nome' 			size 030, 010 pixel
	@ 015, 280 get cNome		   	size 150, 010 when .F. pixel

return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDTIT
Montagem do grid da tela de alteração de titulos

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GRIDTIT()
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'E2_PARCELA', 'E2_VENCREA','E2_VALOR','E2_DESCONT','E2_HIST'}
	local aFieldFill	:= {}
	local aAlterFields	:= {'E2_DESCONT'}
	local nX			:= 0
	Local aField		:= {}

	AEval(aFields, {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
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
		})})

	aHeader := aClone(aField)

	for nX := 1 to len(aFields)
		aAdd(aFieldFill, criaVar(aFields[nX], .F.))
	next nX

	aAdd(aFieldFill, .f.)

	cQuery := " SELECT * FROM "+RetSqlName('SE2')
	cQuery += " WHERE "
	cQuery += "      E2_FILIAL = '"+xFilial('SE2')+"' AND E2_PREFIXO = '"+SF1->F1_PREFIXO+"' AND E2_NUM = '"+SF1->F1_DUPL+"' "
	cQuery += "  AND E2_TIPO = 'NF' AND E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' AND D_E_L_E_T_ != '*' "

	TCQuery cQuery Alias 'TMPSE2' NEW
	dbSelectArea('TMPSE2')
	TMPSE2->(DbGoTop())


	cSql:=" SELECT  CND_XVENCR, CND.R_E_C_N_O_ REC  FROM "+RetSqlName('SD1')+" SD1"+chr(13)+chr(10)
	cSql+=" 	INNER JOIN "+RetSqlName('SC7')+"  SC7"+chr(13)+chr(10)
	cSql+=" 		ON C7_FILIAL = D1_FILIAL"+chr(13)+chr(10)
	cSql+=" 		AND C7_NUM = D1_PEDIDO"+chr(13)+chr(10)
	cSql+=" 		AND C7_ITEM = D1_ITEM"+chr(13)+chr(10)
	cSql+=" 	INNER JOIN "+RetSqlName('CND')+"  CND "+chr(13)+chr(10)
	cSql+=" 		ON CND_FILIAL = C7_FILIAL"+chr(13)+chr(10)
	cSql+=" 		AND CND_NUMMED = C7_MEDICAO"+chr(13)+chr(10)
	cSql+=" 		AND CND_CONTRA = C7_CONTRA"+chr(13)+chr(10)
	cSql+=" 		AND CND_REVISA = C7_CONTREV"+chr(13)+chr(10)
	cSql+=" WHERE D1_FILIAL='"+SF1->F1_FILIAL+"'" +chr(13)+chr(10)
	cSql+=" 	AND D1_DOC='"+SF1->F1_DOC+"'"+chr(13)+chr(10)
	cSql+=" 	AND D1_SERIE ='"+SF1->F1_SERIE+"'"+chr(13)+chr(10)
	cSql+=" 	AND D1_FORNECE ='"+SF1->F1_FORNECE+"'	"+chr(13)+chr(10)
	cSql+=" 	AND D1_LOJA ='"+SF1->F1_LOJA+"'"+chr(13)+chr(10)
	cSql+=" 	AND SD1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
	cSql+=" 	AND SC7.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
	cSql+=" 	AND CND.D_E_L_E_T_<>'*'"+chr(13)+chr(10)

	If Select('TRCT')<>0
		TRCT->(dbCloseArea())
	EndIF
	TcQuery cSql new Alias 'TRCT'
	dDtCtr:=ctod("//")
	cobsCtr:=""
	If !TRCT->(eof())
		dDtCtr:= STOD(TRCT->CND_XVENCR)
		dbSelectArea('CND')
		DBGoto(TRCT->REC)
		cobsCtr:= CND->CND_OBS
	EndIf


	While !TMPSE2->(EOF())

		aFieldFill[1]  := TMPSE2->E2_PARCELA
		aFieldFill[2]  := dtoc(if(empty(dDtCtr),fCalcVReal("TMPSE2",STOD(TMPSE2->E2_VENCTO),STOD(TMPSE2->E2_VENCTO),STOD(TMPSE2->E2_EMISSAO)),fCalcVReal("TMPSE2",dDtCtr,STOD(TMPSE2->E2_VENCTO),STOD(TMPSE2->E2_EMISSAO),.T.)))
		aFieldFill[3]  := TMPSE2->E2_VALOR
		aFieldFill[4]  := TMPSE2->E2_DESCONT
		aFieldFill[5]  := if(!Empty(cobsCtr),'Contrato - ','')+ALLTRIM(TMPSE2->E2_HIST)+if(!(alltrim(cobsCtr) $ ALLTRIM(TMPSE2->E2_HIST)) ,cobsCtr,"")
		aAdd(aCols, aClone(aFieldFill))

		TMPSE2->(DbSkip())
	EndDo

	oGet := MsNewGetDados():New( 050, 010, 250, 500,GD_INSERT + GD_UPDATE + GD_DELETE, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)

	TMPSE2->(dbCloseArea())

return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CONFIRMAR
Função para imput das informações alteradas, via execauto

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
/* Rotina comentada conforme alinhado com o Walter, devido a não utilização - Valtenio Totvs 17/10/2018

Static Function CONFIRMAR()
	Local _aVetor := {}

	Begin Transaction

		For nI := 1 to Len (oGet:aCols)
			_aVetor :={{"E2_PREFIXO",SF1->F1_PREFIXO													,Nil},;
			{"E2_NUM"	,SF1->F1_DUPL														,Nil},;
			{"E2_PARCELA",oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='E2_PARCELA'})],Nil},;
			{"E2_TIPO"	,'NF '																,Nil},;
			{"E2_FORNECE",SF1->F1_FORNECE													,Nil},;
			{"E2_LOJA"	,SF1->F1_LOJA														,Nil},;
			{"E2_DESCONT",oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='E2_DESCONT'})],Nil},;
			{"E2_HIST"	,oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='E2_HIST'})]	,Nil}}

			lMsErroAuto := .F.

			MSExecAuto({|a,b,c,d,e| Fina050(a,b,c,d,e)},_aVetor,,4,,,.f.) //Alteracao

			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Return .F.
			EndIf
		Next

	End Transaction

Return .T.
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GrvHistSE2

@return Verdadeiro ou Falso
@author Felipe Toazza Caldeira
@since 03/09/2015
/*/
//------------------------------------------------------------------------------
Static Function GrvHistSE2()

	Local cQuery 	:= ""
	Local cDesc	 	:= ""
	Local lcontrat	:=.f.

	//Busca informação dos produtos
	cQuery := " SELECT  * FROM "+RetSqlName('SD1')+" WITH (NOLOCK) "
	cQuery += " WHERE "
	cQuery += "      D1_FILIAL = '"+SF1->F1_FILIAL+"' AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' "
	cQuery += " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' AND D1_LOJA = '"+SF1->F1_LOJA+"' AND D_E_L_E_T_ != '*' "

	If SELECT("TMPGSD1") > 0
		TMPGSD1->(dbCloseArea())
	EndIf
	TCQuery cQuery Alias "TMPGSD1" NEW
	dbSelectArea("TMPGSD1")
	TMPGSD1->(DbGoTop())

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	SC7->(MsSeek(xFilial("SC7")+TMPGSD1->D1_PEDIDO))
	While !TMPGSD1->(EOF())
		If !"PC"+Alltrim(TMPGSD1->D1_PEDIDO)+" - "+Alltrim(Posicione('SB1',1,xFilial('SB1')+TMPGSD1->D1_COD,"B1_DESC"))+" ||" $ cDesc
			cDesc += "PC"+Alltrim(TMPGSD1->D1_PEDIDO)+" - "+Alltrim(Posicione('SB1',1,xFilial('SB1')+TMPGSD1->D1_COD,"B1_DESC"))+" || "
		EndIf

		TMPGSD1->(DbSkip())
	EndDo
	TMPGSD1->(dbCloseArea())

	//Procura os  titulos para gravação
	cQuery := " SELECT R_E_C_N_O_ as RECSE2, * FROM "+RetSqlName('SE2')
	cQuery += " WHERE "
	cQuery += "      E2_FILIAL = '"+xFilial('SE2')+"' AND E2_PREFIXO = '"+SF1->F1_PREFIXO+"' AND E2_NUM = '"+SF1->F1_DUPL+"' "
	cQuery += "  AND E2_TIPO = 'NF' AND E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' AND D_E_L_E_T_ != '*' "
	cQuery += " ORDER BY E2_VENCREA "

	If SELECT("TMPGSE2") > 0
		TMPGSE2->(dbCloseArea())
	EndIf

	TCQuery cQuery Alias 'TMPGSE2' NEW
	dbSelectArea('TMPGSE2')
	TMPGSE2->(DbGoTop())

	cSql:=" SELECT  CND_XVENCR  FROM "+RetSqlName('SD1')+" SD1"+chr(13)+chr(10)
	cSql+=" 	INNER JOIN "+RetSqlName('SC7')+"  SC7"+chr(13)+chr(10)
	cSql+=" 		ON C7_FILIAL = D1_FILIAL"+chr(13)+chr(10)
	cSql+=" 		AND C7_NUM = D1_PEDIDO"+chr(13)+chr(10)
	cSql+=" 		AND C7_ITEM = D1_ITEM"+chr(13)+chr(10)
	cSql+=" 	INNER JOIN "+RetSqlName('CND')+"  CND "+chr(13)+chr(10)
	cSql+=" 		ON CND_FILIAL = C7_FILIAL"+chr(13)+chr(10)
	cSql+=" 		AND CND_NUMMED = C7_MEDICAO"+chr(13)+chr(10)
	cSql+=" 		AND CND_CONTRA = C7_CONTRA"+chr(13)+chr(10)
	cSql+=" 		AND CND_REVISA = C7_CONTREV"+chr(13)+chr(10)
	cSql+=" WHERE D1_FILIAL='"+SF1->F1_FILIAL+"'" +chr(13)+chr(10)
	cSql+=" 	AND D1_DOC='"+SF1->F1_DOC+"'"+chr(13)+chr(10)
	cSql+=" 	AND D1_SERIE ='"+SF1->F1_SERIE+"'"+chr(13)+chr(10)
	cSql+=" 	AND D1_FORNECE ='"+SF1->F1_FORNECE+"'	"+chr(13)+chr(10)
	cSql+=" 	AND D1_LOJA ='"+SF1->F1_LOJA+"'"+chr(13)+chr(10)
	cSql+=" 	AND SD1.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
	cSql+=" 	AND SC7.D_E_L_E_T_<>'*'"+chr(13)+chr(10)
	cSql+=" 	AND CND.D_E_L_E_T_<>'*'"+chr(13)+chr(10)

	If Select('TRCT')<>0
		TRCT->(dbCloseArea())
	EndIF
	TcQuery cSql new Alias 'TRCT'
	dDtCtr := CtoD('  /  /  ')

	lcontrat:= !TRCT->(eof()) //adiciona do para limpar a flag de contabilizacao apenas do contrato

	If lcontrat
		dDtCtr:= STOD(TRCT->CND_XVENCR)
	EndIf

	nCont:=0

	While !TMPGSE2->(EOF())
		nCont++
		SE2->(DbGoTop())
		SE2->(DbGoTo(TMPGSE2->RECSE2))

		RecLock('SE2',.F.)
		/**
		Kaique Mathias - 05/11/2019
		Regra para postergar vencimento real
		**/

		if lcontrat
			dVencRea := fCalcVReal("SE2",dDtCtr,SE2->E2_VENCTO,SE2->E2_EMISSAO,.T.,.T.,SC7->C7_USER) 
		Else
			dVencRea := fCalcVReal("SE2",SE2->E2_VENCTO,SE2->E2_VENCTO,SE2->E2_EMISSAO,.F.,.T.,SC7->C7_USER) 
		EndIf
		//Removida esta regra daqui. Agora está pegando esta data na hora que calcula o vencumento.
		if nCont ==1 .and. !Empty(dVencRea)
			SE2->E2_VENCREA := dVencRea
		ENDIF
		
		//SE2->E2_HIST := if(!(alltrim(cDesc) $ ALLTRIM(SE2->E2_HIST)) ,cDesc,"")+SE2->E2_HIST  
		
		if lcontrat
			SE2->E2_LA	 := Space(01)
		EndIF
		SE2->(MsUnlock())
		
		//grvrat()
		
		TMPGSE2->(DbSkip())
	EndDo

	TMPGSE2->(dbCloseArea())

Return
/*/{Protheus.doc} grvrat
Grava os rateios vindo do SIGAGCT
@author Rodrigo Slisinski
@since 31/08/2017
@version 1.0
/*/
Static Function grvrat()

	cSql:=" SELECT D1_PEDIDO FROM "+RetSqlName('SD1')
	cSql+="	WHERE D1_DOC ='"+SF1->F1_DOC+"'"
	cSql+=" AND D1_SERIE = '"+SF1->F1_SERIE+"'"
	cSql+=" AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
	cSql+=" AND D1_LOJA = '"+SF1->F1_LOJA+"'"
	cSql+=" AND D_E_L_E_T_<>'*'"

	IF Select('TRD1')<>0
		TRD1->(DBCloseArea())
	EndIF
	TcQuery cSql New Alias 'TRD1'

	IF TRD1->(EOF())
		RETURN
	EndIf

	DBSelectArea('SC7')
	DBSetOrder(1)
	If SC7->(DBSeek(xFilial('SC7')+TRD1->D1_PEDIDO))

		If !Empty(Alltrim(SC7->C7_MEDICAO))


			cSql:=" select R_E_C_N_O_ REC from "+RETSQLNAME('SEV')
			cSql+=" WHERE EV_FILIAL = '"+SE2->E2_FILIAL+"'"
			cSql+=" AND EV_PREFIXO ='"+SE2->E2_PREFIXO+"'"
			cSql+=" AND EV_NUM ='"+SE2->E2_NUM+"'"
			cSql+=" AND EV_PARCELA ='"+SE2->E2_PARCELA+"'"
			cSql+=" AND EV_TIPO ='"+SE2->E2_TIPO+"'"
			cSql+=" AND EV_CLIFOR ='"+SE2->E2_FORNECE+"'"
			cSql+=" AND EV_LOJA ='"+SE2->E2_LOJA+"'"
			cSql+=" AND D_E_L_E_T_<>'*'"

			IF Select('TREV')<>0
				TREV->(DBCloseArea())
			EndIF
			TcQuery cSql New Alias 'TREV'
			While !TREV->(eof())
				SEV->(dbSelectArea('SEV'))
				SEV->(DBGoto(TREV->REC))
				SEV->(reclock('SEV',.F.))
				SEV->(DBDELETE())
				SEV->(MSUnlock())
				TREV->(dBSkip())
			EndDo

			cQuery := " SELECT Z21_NATURE, SUM(Z21_VALOR) AS VALOR FROM "+RetSqlNAme('Z21')
			cQuery += "	WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+SC7->C7_CONTRA+"' "
			cQuery += "	  AND Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND D_E_L_E_T_ != '*' "
			cQuery += " GROUP BY Z21_NATURE "

			If SELECT("TMPGSE2") > 0
				TMPGSE2->(dbCloseArea())
			EndIf

			TCQuery cQuery Alias 'TMPGSE2' NEW
			dbSelectArea('TMPGSE2')
			TMPGSE2->(DbGoTop())

			cId := '0'
			cId := Soma1(cId)
			While !TMPGSE2->(EOF())

				cQuery2 := " SELECT Z21_NATURE, Z21_CCUSTO,Z21_ITEMCT, SUM(Z21_VALOR) AS VALOR FROM "+RetSqlNAme('Z21')
				cQuery2 += "	WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+SC7->C7_CONTRA+"' "
				cQuery2 += "	  AND Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND Z21_CCUSTO != ' ' AND D_E_L_E_T_ != '*' and Z21_NATURE ='"+TMPGSE2->Z21_NATURE+"'"
				cQuery2 += " GROUP BY Z21_NATURE,Z21_CCUSTO,Z21_ITEMCT "
				If SELECT("TMPSE2CC") > 0
					TMPSE2CC->(dbCloseArea())
				EndIf

				TCQuery cQuery2 Alias 'TMPSE2CC' NEW
				dbSelectArea('TMPSE2CC')
				TMPSE2CC->(DbGoTop())
				If !TMPSE2CC->(EOF())
					cRatCC := '1'
				Else
					cRatCC := '2'
				EndIf

				nPerc:=TMPGSE2->VALOR/SF1->F1_VALBRUT
				RecLock('SEV',.T.)
				SEV->EV_FILIAL 	:= SE2->E2_FILIAL
				SEV->EV_PREFIXO := SE2->E2_PREFIXO
				SEV->EV_NUM 	:= SE2->E2_NUM
				SEV->EV_PARCELA := SE2->E2_PARCELA
				SEV->EV_CLIFOR 	:= SE2->E2_FORNECE
				SEV->EV_LOJA	:= SE2->E2_LOJA
				SEV->EV_TIPO	:= SE2->E2_TIPO
				SEV->EV_VALOR 	:= TMPGSE2->VALOR
				SEV->EV_NATUREZ := TMPGSE2->Z21_NATURE
				SEV->EV_RECPAG 	:= "P"
				SEV->EV_PERC 	:= round(nPerc,tamsx3('EV_PERC')[2])
				SEV->EV_RATEICC := cRatCC
				SEV->EV_IDENT 	:= cId
				SEV->(MsUnlock())
				if cRatCC=='1'
					//cId := '0'
					While !TMPSE2CC->(EOF())
						//cId := Soma1(cId)
						RecLock('SEZ',.T.)
						SEZ->EZ_FILIAL 	:= SE2->E2_FILIAL
						SEZ->EZ_PREFIXO := SE2->E2_PREFIXO
						SEZ->EZ_NUM 	:= SE2->E2_NUM
						SEZ->EZ_PARCELA := SE2->E2_PARCELA
						SEZ->EZ_CLIFOR 	:= SE2->E2_FORNECE
						SEZ->EZ_LOJA	:= SE2->E2_LOJA
						SEZ->EZ_TIPO	:= SE2->E2_TIPO
						SEZ->EZ_VALOR 	:= TMPSE2CC->VALOR
						SEZ->EZ_NATUREZ := TMPSE2CC->Z21_NATURE
						SEZ->EZ_ITEMCTA := TMPSE2CC->Z21_ITEMCT
						SEZ->EZ_CCUSTO 	:= TMPSE2CC->Z21_CCUSTO
						SEZ->EZ_RECPAG 	:= "P"
						SEZ->EZ_PERC 	:= round(TMPSE2CC->VALOR/SE2->E2_VALOR,tamsx3('EZ_PERC')[2])*100
						SEZ->EZ_IDENT 	:= cId
						SEZ->(MsUnlock())
						TMPSE2CC->(DbSkip())
					EndDo
				endif
				TMPGSE2->(DbSkip())
			EndDo
		EndIf
	ENDif
Return

Static Function GraZ07Z06()
	/* Variavies Locais ini Avaliação Fornecedor*/
	local aHeader		:= {}
	local aCols			:= {}
	local aFields 		:= {'Z07_PEDIDO', 'Z07_ITEMPC' ,'Z07_ITEMNF','Z07_PRODUT','Z07_DESC','Z07_QTDNF','Z07_QTDPED','Z07_TOTAL','Z07_DTPREV','Z07_DTREAL' }
	local aFieldFill	:= {}
	local aAlterFields	:= {}
	local cQryHdr		:= ""
	Local aRegra		:= {}
	local aHeader2		:= {}
	Local nX
	Local nI
	Local nCrit
	local aCols2		:= {}
	local aFields2 		:= {'Z06_CRITER','Z06_DCRITE','Z06_PESO','Z06_PONTOS','Z06_PTDIG','Z06_OBS'}
	local aFieldFi2		:= {}
	Local aField		:= {}

	//If nGravou = 0
	DBSelectArea('Z07')
	Z07->(dbSetOrder(1)) //Z07_FILIAL+Z07_FORNEC+Z07_LOJA+Z07_DOC+Z07_SERIE+Z07_REGRA+Z07_PEDIDO+Z07_PRODUT+Z07_ITEMNF
	if !Z07->(dbSeek(xFilial('Z07')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+cRegra))

		AEval(aFields, { |cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
			})})

		aHeader := aClone(aField)
		aField	:= {}

		cQryHdr := " SELECT SUBSTRING(Z04_DESC,1,10) AS TITULO, * FROM "+RetSqlName('Z04')+" WHERE "
		cQryHdr += "      Z04_FILIAL = '"+xFilial('Z04')+"' AND Z04_REGRA = '"+cRegra+"' AND Z04_ACAO = '1' AND D_E_L_E_T_ != '*' ORDER BY Z04_CRITER "

		If (Select("Z04HDR") <> 0)
			DbSelectArea("Z04HDR")
			Z04HDR->(DbCloseArea())
		Endif

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryHdr), "Z04HDR",.T., .F.)
		nCnt := 1
		DbSelectArea("Z04HDR")
		Z04HDR->(DbGoTop())
		While !Z04HDR->(EOF())
			aADD( aFields, Z04HDR->TITULO )
			aAdd(aHeader,{	Z04HDR->TITULO,;
				"Z04_PESO",;
				X3PICTURE("Z04_PESO"),;
				TamSX3("Z04_PESO")[1],;
				TamSX3("Z04_PESO")[2],;
				GetSx3Cache("Z04_PESO", "X3_VALID"),;
				GetSx3Cache("Z04_PESO", "X3_USADO"),;
				FwSX3Util():GetFieldType("Z04_PESO"),;
				X3F3("Z04_PESO"),;
				GetSx3Cache("Z04_PESO", "X3_CONTEXT"),;
				X3CBOX("Z04_PESO"),;
				GetSx3Cache("Z04_PESO", "X3_RELACAO");
				})
			aADD(aAlterFields,Z04HDR->TITULO)
			AADD(aRegra,Z04HDR->Z04_CRITER)
			AADD(aNotas,0)
			nCnt++
			Z04HDR->(DbSkip())
		EndDo

		for nX := 1 to len(aFields)
			if FieldPos(aFields[nX]) > 0
				aAdd(aFieldFill, criaVar(aFields[nX], .F.))
			Else
				aAdd(aFieldFill, criaVar('Z04_PESO', .F.))
			endIf
		next

		aAdd(aFieldFill, .f.)

		If Alltrim(SF1->F1_ESPECIE) == 'CTR' .OR. Alltrim(SF1->F1_ESPECIE) == 'CTE'
			cQueryGrd := " SELECT SD1.* FROM "+RetSqlName('SD1')+" SD1 "
			cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
			cQueryGrd += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND  SD1.D_E_L_E_T_ != '*' "
			cTipAux := 'CTR'
		Else
			cQueryGrd := " SELECT SD1.*, SC7.* FROM "+RetSqlName('SD1')+" SD1, "+RetSqlName('SC7')+" SC7 "
			cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
			cQueryGrd += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND  SD1.D_E_L_E_T_ != '*' "
			cQueryGrd += "   AND SD1.D1_FILIAL = SC7.C7_FILIAL AND SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM   "
			cQueryGrd += "   AND SD1.D1_COD = SC7.C7_PRODUTO AND SC7.D_E_L_E_T_ != '*' "
			cTipAux	:= 'NFE'
		EndIf

		If (Select("TMPGRD") <> 0)
			DbSelectArea("TMPGRD")
			TMPGRD->(DbCloseArea())
		Endif

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryGRD), "TMPGRD",.T., .F.)

		DbSelectArea("TMPGRD")
		TMPGRD->(DbGoTop())

		If TMPGRD->(EOF())
			Alert('Essa nota não poderá ser avaliada pois a mesma não está vinculada a Pedidos de Compras!')
		EndIf

		nLaco := 0
		While !TMPGRD->(EOF())
			If cTipAux == 'CTR'
				aFieldFill[1]  := TMPGRD->D1_PEDIDO
				aFieldFill[2]  := TMPGRD->D1_ITEMPC
				aFieldFill[3]  := TMPGRD->D1_ITEM
				aFieldFill[4]  := TMPGRD->D1_COD
				aFieldFill[5]  := TMPGRD->D1_DESCRI
				aFieldFill[6]  := TMPGRD->D1_QUANT
				aFieldFill[7]  := TMPGRD->D1_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)
				aFieldFill[8]  := TMPGRD->D1_TOTAL
				aFieldFill[9]  := SF1->F1_RECBMTO
				aFieldFill[10]  := SF1->F1_RECBMTO
				For nCrit := 1 to Len(aRegra)
					aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
					aNotas[nCrit] += aFieldFill[10+nCrit]
				Next
			Else
				aFieldFill[1]  := TMPGRD->D1_PEDIDO
				aFieldFill[2]  := TMPGRD->D1_ITEMPC
				aFieldFill[3]  := TMPGRD->D1_ITEM
				aFieldFill[4]  := TMPGRD->D1_COD
				aFieldFill[5]  := TMPGRD->D1_DESCRI
				aFieldFill[6]  := TMPGRD->D1_QUANT
				aFieldFill[7]  := TMPGRD->C7_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)
				aFieldFill[8]  := TMPGRD->D1_TOTAL
				aFieldFill[9]  := StoD(TMPGRD->C7_DATPRF)
				aFieldFill[10]  := SF1->F1_RECBMTO
				For nCrit := 1 to Len(aRegra)
					aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
					aNotas[nCrit] += aFieldFill[10+nCrit]
				Next
			EndIf
			aAdd(aCols, aClone(aFieldFill))
			nLaco++
			TMPGRD->(DbSkip())
		endDo
		aField		:= {}
		AEval(aFields2, { |cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
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
			})})

		aHeader2 := aClone(aFields2)

		for nX := 1 to len(aHeader2)
			aAdd(aFieldFi2, criaVar(aHeader[nX][02], .f.))
		next

		aAdd(aFieldFi2, .f.)

		nPontos := 0

		DbSelectArea('Z04')
		Z04->(DbSetOrder(1))
		Z04->(DbGoTop())
		Z04->(DbSeek(xFilial('Z04')+cRegra))

		nAux := 1
		While !Z04->(EOF()) .AND. xFilial('Z04')+Z04->Z04_REGRA == xFilial('Z04')+cRegra
			aFieldFi2[1]  := Z04->Z04_CRITER
			aFieldFi2[2]  := Z04->Z04_DESC
			aFieldFi2[3]  := Z04->Z04_PESO
			aFieldFi2[4]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))
			aFieldFi2[5]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))
			aFieldFi2[6]  := Space(len(Z06->Z06_OBS))

			nPontos += aFieldFi2[5]

			aAdd(aCols2, aClone(aFieldFi2))
			nAux++
			Z04->(DbSkip())
		EndDo




		if nPontos >=100
			For nI := 1 to Len(aCols)
				RecLock("Z07",.T.)
				Z07->Z07_FILIAL		:= xFilial('Z07')
				Z07->Z07_FORNECE  	:= SF1->F1_FORNECE
				Z07->Z07_LOJA    	:= SF1->F1_LOJA
				Z07->Z07_DOC  		:= SF1->F1_DOC
				Z07->Z07_SERIE     	:= SF1->F1_SERIE
				Z07->Z07_REGRA      := cRegra
				Z07->Z07_PEDIDO     := aCols[nI,1]
				Z07->Z07_ITEMNF     := aCols[nI,3]
				Z07->Z07_PRODUT     := aCols[nI,4]
				Z07->Z07_QTDNF      := aCols[nI,6]
				Z07->Z07_QTDPED     := aCols[nI,7]
				Z07->Z07_TOTAL      := aCols[nI,8]
				Z07->Z07_DTPREV     := aCols[nI,9]
				Z07->Z07_DTREAL     := SF1->F1_RECBMTO
				If ValType(aCols[nI,11]) == 'N'
					Z07->Z07_AVAL01		:= aCols[nI,11]
				EndIf
				If ValType(aCols[nI,12]) == 'N'
					Z07->Z07_AVAL02		:= aCols[nI,12]
				EndIf
				If ValType(aCols[nI,13]) == 'N'
					Z07->Z07_AVAL03		:= aCols[nI,13]
				EndIf
				If ValType(aCols[nI,14]) == 'N'
					Z07->Z07_AVAL04		:= aCols[nI,14]
				EndIf
				Z07->Z07_COMPRA		:= SF1->F1_IDCOMPR
				MsUnlock()

			Next

			For nI := 1 to Len(aCols2)
				RecLock("Z06",.T.)
				Z06->Z06_FILIAL		:= xFilial('Z06')
				Z06->Z06_FORNEC  	:= SF1->F1_FORNECE
				Z06->Z06_LOJA    	:= SF1->F1_LOJA
				Z06->Z06_NOTA  		:= SF1->F1_DOC
				Z06->Z06_SERIE     	:= SF1->F1_SERIE
				Z06->Z06_REGRA  	:= cRegra
				Z06->Z06_CRITER    	:= aCols2[nI,1]
				Z06->Z06_DCRITE    	:= aCols2[nI,2]
				Z06->Z06_PESO  		:= aCols2[nI,3]
				Z06->Z06_PONTOS     := aCols2[nI,4]
				Z06->Z06_PTDIG 		:= aCols2[nI,4]
				Z06->Z06_OBS     	:= 'Inserido através do PE de Compras'
				Z06->Z06_DATA		:= SF1->F1_RECBMTO
				Z06->Z06_COMPRA		:= SF1->F1_IDCOMPR
				MsUnlock()
			Next

			RecLock("SF1",.F.)
			SF1->F1_AVALFOR := '1'
			MsUnlock()
		endif
		nGravou := 1
	Endif

return

Static Function CalcRegra(cRegra,cCritic)
	Local nPt 		:= 0
	Local cCampoUt 	:= ""
	Local cTabela	:= ""
	Local cQryReg 	:= ""
	Local cQryPt	:= ""

	Private xComp


	DbSelectArea('Z05')
	Z05->(DbSetOrder(1))
	Z05->(DbGotop())
	If Z05->(DbSeek(xFilial('Z05')+cRegra+cCritic)) 				//PROCURA REGRA QUE ESTÁ SENDO UTILIZADA
		cCampoUt := Z05->Z05_CAMPO 									// VERIFICA QUAL O CAMPO DE COMPARAÇÃO
		cTabAux := SubStr(Z05->Z05_CAMPO,1,AT("_",Z05->Z05_CAMPO)-1) 	// BUSCA NOME DA TABELA
		If Len(Alltrim(cTabAux)) == 2 								// verificar se é uma tabela iniciada com S ou não
			cTabela := "S"+cTabAux
		Else
			cTabela := cTabAux
		EndIf

		// ==============================================
		// BUSCA INFORMAÇÕES PARA COMPARAÇÃO
		//===============================================
		If cTabela == 'SD1'
			cQryReg := " SELECT D1_PEDIDO, D1_ITEMPC, SUM("+cCampoUt+") AS "+cCampoUt+" FROM "+RetSqlName(cTabela)
			cQryReg += " WHERE "
			cQryReg += "     D1_FILIAL = '"+xFilial(cTabela)+"' AND D1_DOC = '"+TMPGRD->D1_DOC+"' AND D1_SERIE = '"+TMPGRD->D1_SERIE+"'
			cQryReg += " AND D1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND D1_LOJA = '"+TMPGRD->D1_LOJA+"' AND D1_COD = '"+TMPGRD->D1_COD+"' "
			cQryReg += " AND D1_PEDIDO = '"+TMPGRD->D1_PEDIDO+"' AND D1_ITEMPC = '"+TMPGRD->D1_ITEMPC+"' AND D_E_L_E_T_ != '*' "
			cQryReg += " GROUP BY D1_PEDIDO, D1_ITEMPC "
		ElseIf cTabela == 'SF1'
			cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
			cQryReg += " WHERE "
			cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOC = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERIE = '"+TMPGRD->D1_SERIE+"'
			cQryReg += " AND "+cTabAux+"_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "
		ElseIf cTabela == 'QI2'
			cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
			cQryReg += " WHERE "
			cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOCNF = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERNF = '"+TMPGRD->D1_SERIE+"'
			cQryReg += " AND "+cTabAux+"_CODFOR = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJFOR = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "

		EndIf

		If (Select("CALCREG") <> 0)
			DbSelectArea("CALCREG")
			CALCREG->(DbCloseArea())
		Endif

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCREG",.T., .F.)

		DbSelectArea("CALCREG")
		CALCREG->(DbGoTop())
		// ==============================================

		If cTabela == 'SD1'
			xComp := IIF(cTipAux!='CTR',CALCREG->&cCAmpoUt/TMPGRD->C7_QUANT,1) //IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)   // MONTA PERCENTUAL DA REGRA
		ElseIf cTabela == 'SF1'
			xComp := StoD(CALCREG->&cCAmpoUt)-IIF(cTipAux!='CTR',StoD(TMPGRD->C7_DATPRF),StoD(CALCREG->&cCAmpoUt))   // MONTA PERCENTUAL DA REGRA
		ElseIf cTabela == 'QI2'
			xComp := IIF(!Empty(Alltrim(CALCREG->&cCAmpoUt)),1,0)
		EndIf

		// ===========================================================
		// NOVA REGRA PARA PEDIDOS PARCIAIS ENTREGUES DENTRO DO PRAZO
		//============================================================
		If cTabela == 'SD1' .AND. xComp < 1

			cQryReg := " SELECT F1_RECBMTO   FROM "+RetSqlName('SF1')
			cQryReg += " WHERE "
			cQryReg += "     F1_FILIAL = '"+xFilial('SF1')+"' AND F1_DOC = '"+TMPGRD->D1_DOC+"' AND F1_SERIE = '"+TMPGRD->D1_SERIE+"'
			cQryReg += " AND F1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND F1_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCALT",.T., .F.)

			DbSelectArea("CALCALT")
			CALCALT->(DbGoTop())
			If StoD(TMPGRD->C7_DATPRF)-StoD(CALCALT->F1_RECBMTO) > 0
				xComp := 1
			EndIF
			CALCALT->(DbCloseArea())
		EndIf
		// ==============================================
		// BUSCA INFORMAÇÕES DA REGRA PARA CALCULO
		//===============================================
		cQryPt := " SELECT * FROM "+RetSqlName('Z05')
		cQryPt += " WHERE "
		cQryPt += "      Z05_FILIAL = '"+xFilial('Z05')+"' AND Z05_REGRA = '"+cRegra+"' AND Z05_CRITER = '"+cCritic+"' AND D_E_L_E_T_ != '*' "

		If (Select("CALCPT") <> 0)
			DbSelectArea("CALCPT")
			CALCPT->(DbCloseArea())
		Endif

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryPt), "CALCPT",.T., .F.)

		DbSelectArea("CALCPT")
		CALCPT->(DbGoTop())

		While !CALCPT->(EOF())
			// ==============================================
			// ANALISA REGRA DE COMPARAÇÃO
			//===============================================

			If Empty(Alltrim(CALCPT->Z05_REGRA2)) 		// SE TIVER COMPARAÇÃO COM 1 REGRA

				If CALCPT->Z05_REGRA1 == '1'
					cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
				ElseIf CALCPT->Z05_REGRA1 == '2'
					cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
				ElseIf CALCPT->Z05_REGRA1 == '3'
					cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
				ElseIf CALCPT->Z05_REGRA1 == '4'
					cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
				ElseIf CALCPT->Z05_REGRA1 == '5'
					cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
				EndIF

				// ==============================================
				// VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
				//===============================================
				If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp
					nPt := CALCPT->Z05_NOTA
					Exit
				EndIf

			Else
				If CALCPT->Z05_REGRA1 == '1'
					cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
				ElseIf CALCPT->Z05_REGRA1 == '2'
					cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
				ElseIf CALCPT->Z05_REGRA1 == '3'
					cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
				ElseIf CALCPT->Z05_REGRA1 == '4'
					cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
				ElseIf CALCPT->Z05_REGRA1 == '5'
					cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
				EndIF

				// regra invertida para compreender a necessidade
				If CALCPT->Z05_REGRA2 == '1'
					cRegra1 += ' .AND. xComp < CALCPT->Z05_VALOR2/100 '
				ElseIf CALCPT->Z05_REGRA2 == '2'
					cRegra1 += ' .AND. xComp <= CALCPT->Z05_VALOR2/100 '
				ElseIf CALCPT->Z05_REGRA2 == '3'
					cRegra1 += ' .AND. xComp = CALCPT->Z05_VALOR2/100 '
				ElseIf CALCPT->Z05_REGRA2 == '4'
					cRegra1 += ' .AND. xComp >= CALCPT->Z05_VALOR2/100 '
				ElseIf CALCPT->Z05_REGRA2 == '5'
					cRegra1 += ' .AND. xComp > CALCPT->Z05_VALOR2/100 '
				EndIF

				// ==============================================
				// VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
				//===============================================
				If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp
					nPt := CALCPT->Z05_NOTA
					Exit
				EndIf
			EndIf

			CALCPT->(DbSkip())
		EndDo

		CALCPT->(DbCloseArea())
		CALCREG->(DbCloseArea())

	Else
		Alert('Problemas ao encontrar forma de cálculo para a Regra '+cRegra+'/'+cCritic)
	EndIf

	Z05->(DbCLoseArea())

Return nPt

User Function SD1100E()

	Local aAreaSD1 := SD1->(GetArea())
	Local lIntMst   := GetMv('TCP_INTMST')

	If ( lIntMst .And. SD1->D1_TP = 'ES' )

		dbSelectArea('TN3')
		TN3->(dbSetOrder( 3 ))
		TN3->(dbgotop())

		If TN3->(dbSeek(xFilial('TN3') + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA))
			While !TN3->(Eof()) .And. 	TN3->TN3_FILIAL == xFilial("TN3") .And.;
					TN3->TN3_XDOC == SD1->D1_DOC .And.;
					TN3->TN3_XSERIE == SD1->D1_SERIE .And.;
					TN3->TN3_FORNEC == SD1->D1_FORNECE .And.;
					TN3->TN3_LOJA == SD1->D1_LOJA
				TN3->TN3_CODEPI == SD1->D1_COD
				If RecLock('TN3',.F.)
					DBDELETE()
					MsUnlock()
				EndIf

				TN3->(dbSkip())
			EndDo
		EndIf

	EndIf

	RestArea(aAreaSD1)

Return( Nil )

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Ponto Ent.³ BuscaApr ³ Autor ³ Marcos Feijó IT UP Sul³ Data ³ 09/04/19 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Busca o primeiro nível de aprovação dos pedidos de compra  ³±±
	±±³          ³ vinculados a nota fiscal.                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ TCP – Terminais de Contêineres de Paranaguá S.A.           ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function BuscaApr()
	Local _cPedido	:= ""
	Local _cGrpApr	:= ""
	Local _cAprov	:= ""
	Local _aPedidos := {}
	Local _cArea	:= Alias()

	dbSelectArea("SCR")
	dbSetOrder(1)

	_nPosPed    := aScan(aHeader, {|x| alltrim(x[2])=="D1_PEDIDO"})

	For _nI := 1 To Len(aCols)
		_cPedido := aCols[_nI,_nPosPed]																					//Pedido de compra na NFe
		_cGrpApr := Posicione("SC7", 1, xFilial("SC7") + _cPedido, "C7_APROV")											//Grupo de aprovação no PC
		_cAprov  := Posicione("SCR", 1, xFilial("SCR") + "PC" + PadR(_cPedido, TamSx3('CR_NUM')[1]) + "01", "CR_USER")	//Primeiro aprovador nos documentos com alçadas

		//Se encontrou o PC, grupo de aprovação e o aprovador
		If !Empty(_cPedido) .And. !Empty(_cGrpApr) .And. !Empty(_cAprov)
			//Se ainda não incluir ao array o aprovador
			If Empty(aScan(_aPedidos, {|x| alltrim(x[3])==_cAprov}))
				aAdd(_aPedidos, {_cPedido, _cGrpApr, _cAprov})
			EndIf
		EndIf
	Next _nI

	If Empty(_aPedidos)		//Não encontrou nenhum pedido de compras, grupo de aprovação ou aprovador
		_cNomGes:= "Gestor Responsável"
		_cEmaGes:= Lower(AllTrim(GetMv("MV_EMAGES")))
	Else					//Todos os itens retornam o mesmo aprovador
		_cNomGes:= Capital(AllTrim(UsrFullName(_aPedidos[1][3])))
		_cEmaGes:= Lower(AllTrim(UsrRetMail(_aPedidos[1][3])))
	EndIf

	dbSelectArea(_cArea)

Return Nil
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} fRetDtAtu
description Retorna data atualizada
@author  Kaique Mathias
@since   05/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fCalcVReal(cAlias,dData,dVencReal,dEmissao,lContrato,lSendAviso,cCodUsr)

	Local _nDias  		:= GetMv("TCP_DIAVEN",.F.,13)
	Local _nDiasCtr 	:= 0
	//Local dDtCtr		:= CTOD('  /  /  ')
	Local lAltVReal		:= .F.
	Local cErro         := ""
	Local oMail,oHtml   := Nil
	Private dVencInf	:= dData
	Private dVencRea	:= CTOD('  /  /  ')
	Default lContrato	:= .F.
	Default lSendAviso	:= .F.
	Default cCodUsr		:= __cUserId

	If lContrato

		_nDiasCtr := DateDiffDay(dVencReal,dEmissao)+1

		/**
		Regra 1 - Se a condição de pagamento for menor ou igual a 15 dias só valido se esta vencido
		**/
		
		If _nDiasCtr <= 15
			/**
			Se a data informada na medição estiver vencida, mudo vencimento real pra a vista.
			**/
			If ( dData < Date() )
				dVencRea := DataValida(Date(),.T.)
				lAltVReal:= .T.
			Else
				dVencRea := DataValida(dData,.T.)
			EndIf
		Else
			/**
			Regra 2 - Se o contrato for maior que 15 dias e a data informada na medição for 
			menor que a data atual + dias definidos no parametro recalculo o vencimento real 
			**/
			If ( dData < ( DaySum( Date() , _nDias ) ) )
				dVencRea := DataValida(DaySum( Date() , _nDias ),.T.)
				lAltVReal:= .T.
			Else
				dVencRea := dData
			EndIf
		EndIf
	Else
		if ( DateDiffDay( dVencReal , Date() ) < _nDias ) .Or. ( dVencReal <= Date() )
			dVencRea := DataValida(DaySum( Date() , _nDias ),.T.)
			lAltVReal:= .T.
		Else
			dVencRea := DataValida(dVencReal,.T.)
		EndIf
	EndIf

	If lAltVReal .And. lSendAviso
		
		oMail := TCPMail():New()
        oHtml := TWFHtml():New("\WORKFLOW\HTML\MAILAVISO.HTML")
        oHtml:ValByName("CHEADER","Aviso de Alteração de Vencimento Real")
		
		cBody := fMontaHTML()
        
		oHtml:ValByName("CBODY",cBody)
		
		oMail:SendMail(UsrRetMail(cCodUsr),"Aviso de Alteração de Vencimento Real" ,oHtml:HtmlCode(),@cErro,{})
        
		FreeObj(oMail)
        FreeObj(oHtml)
	
	EndIf

Return( dVencRea )

//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaHTML
description Monta o html 
@author  Kaique Sousa
@since   06/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static function fMontaHTML()

	Local _cHtml := ""

	_cHtml += "Caro(a) " + UsrFullName(__cUserId) + ", <br>"
	_cHtml += "foi realizado uma alteração automatica do vencimento real do titulo abaixo: <br>"
	_cHtml += "<br>"
	_cHtml += '<table>'
	_cHtml += '		<tr>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Titulo'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Fornecedor'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				CNPJ'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Emissão NF'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Digitação NF'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Vencto Real Informado'
	_cHtml += '			</th>'
	_cHtml += '			<th class="class_data">'
	_cHtml += '				Vencimento Real Novo'
	_cHtml += '			</th>'
	_cHtml += '		</tr>'

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+SF1->F1_FORNECE + SF1->F1_LOJA))

	_cHtml += "<tr>"
	_cHtml += "<td  class='class_data'>"
	_cHtml += SE2->E2_NUM + '/' + SE2->E2_PREFIXO
	_cHtml += "</td>"
	_cHtml += "<td  class='class_data'>"
	_cHtml += SA2->A2_COD + "/" + SA2->A2_LOJA + "-" + SA2->A2_NREDUZ
	_cHtml += "</td>"
	_cHtml += "<td  class='class_data'>"
	_cHtml += IF(LEN(ALLTRIM(SA2->A2_CGC))> 11,Transform( SA2->A2_CGC, "@R 99.999.999/9999-99" ),Transform( SA2->A2_CGC, "@R 999.999.999-99 " ))
	_cHtml += "</td>"
	_cHtml += "<td class='class_data'>"
	_cHtml += DTOC(SF1->F1_EMISSAO)
	_cHtml += "</td>"
	_cHtml += "<td class='class_data'>"
	_cHtml += DTOC(SF1->F1_DTDIGIT)
	_cHtml += "</td>"
	_cHtml += "<td class='class_data'>"
	_cHtml += DTOC(dVencInf)
	_cHtml += '</td>'
	_cHtml += "<td class='class_data'>"
	_cHtml += DTOC(dVencRea)
	_cHtml += '</td>'
	_cHtml += '</tr>'
	_cHtml += '</table>'
	_cHtml += '</td>'
	_cHtml += '<br>'

Return( _cHtml )
