#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER CHR(13)+CHR(10)

Static cTitulo := "OP's Previstas"

/*/{Protheus.doc} PCP020
OP's Previstas (SC2)
@author Thiago Berna
@since 12/Setembro/2019
@version 1.0
@return Nil, Função não tem retorno
/*/

User Function PCP020()

	Local aArea   	:= GetArea()
	Local aSC2		:= {}
	Local aDescSC2	:= {}
    Local cPerg     := 'PCP020'
    Local cFiltro   := ''
	Local cArq		:= ''
	Local nA		:= 0
	
	Private cCodPrg	:= ''
	Private cAliasBR:= GetNextAlias()
	//Private cLotePI	:= ''
	//Private dValPI	:= STOD('')
	Private aLocal	:= {}
	Private aUtiliz	:= {}
	Private oBrowse

	If Pergunte(cPerg)

		cCodPrg := MV_PAR09
    
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SC2")
		
		While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == 'SC2'
		
			If AllTrim(SX3->X3_BROWSE) == 'S' .And. cNivel >= SX3->(X3_NIVEL) .And. AllTrim(SX3->X3_CONTEXT) != 'V'	
				AAdd(aSC2,{AllTrim(SX3->X3_CAMPO),AllTrim(SX3->X3_TIPO),SX3->X3_TAMANHO,SX3->X3_DECIMAL})
				AAdd(aDescSC2, {AllTrim(SX3->X3_TITULO),AllTrim(SX3->X3_CAMPO),AllTrim(SX3->X3_TIPO),SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,AllTrim(SX3->X3_PICTURE)} )
			Else
				If AllTrim(SX3->X3_CAMPO) $ 'C2_FILIAL|C2_NUM|C2_ITEM|C2_SEQUEN|C2_ITEMGRD|C2_DATPRF|C2_DATPRI|C2_PRODUTO'
					AAdd(aSC2,{AllTrim(SX3->X3_CAMPO),AllTrim(SX3->X3_TIPO),SX3->X3_TAMANHO,SX3->X3_DECIMAL})
					AAdd(aDescSC2, {AllTrim(SX3->X3_TITULO),AllTrim(SX3->X3_CAMPO),AllTrim(SX3->X3_TIPO),SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,AllTrim(SX3->X3_PICTURE)} )
				EndIf
			EndIf
		
			SX3->(DbSkip())
		
		EndDo

		//Adiciona o campo recno
		AAdd(aSC2,{'RECNO','N',25,0})
		AAdd(aDescSC2, {'RECNO','RECNO','N',25,0,''} )

		cArq := CriaTrab(aSC2,.T.)
		dbUseArea(.T.,"DBFCDX",cArq,cAliasBR,.F.)
		DbSelectArea(cAliasBR)

		oProcess := MsNewProcess():New({|lEnd| GeraDados(@oProcess,@lEnd)},OemToAnsi('Carregando Dados'),OemToAnsi('OPS Previstas'),.T.)
		oProcess:Activate()
		
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetAlias(cAliasBR)
		oBrowse:SetFields(aDescSC2)
		oBrowse:SetTemporary(.T.)
        oBrowse:SetDescription(cTitulo)
        oBrowse:SetMenuDef('MADERO_PCP020')
        oBrowse:Activate()

    Else
        MsgInfo("Rotina encerrada pelo usuário.","Atenção!")
    EndIf

	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando opções	
	ADD OPTION aRot TITLE 'Firma OPs'    	ACTION "U_PCP020FI()"	        OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Visualizar'	    ACTION 'VIEWDEF.MADERO_PCP020'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir OP'    	ACTION "U_PCP020EX()"   	    OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

  

/*---------------------------------------------------------------------*
| Func:  PCP020FI                                                     |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Firmar OPS                                                   |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

User Function PCP020FI()

Local nOpc 			:= 0
Local nCount		:= 0
Local nRecnoPA		:= 0
Local nA			:= 0
Local nB			:= 0
Local lMsErroAuto	:= .F.
Local aDadosPA 		:= {}
Local aDadosPI 		:= {}
Local aDadosIn 		:= {}
Local aOPsIn		:= {}
Local aArea			:= GetArea()
Local aErro			:= {}			
Local cTipo			:= ''
Local cOPOrig		:= ''
Local cOP			:= ''
Local cItem			:= ''
Local cSeq			:= ''
Local cNovaOP		:= ''
Local cLote			:= ''
Local cQuery		:= ''
Local cLinha		:= ''
Local cErro			:= ''
Local cSeqPai		:= ''
Local cArm			:= ''
Local cInd			:= ''
Local cZona			:= ''
Local cAlias01		:= GetNextAlias()
Local cAlias02		:= GetNextAlias()
Local cEndAnt		:= ''
Local cLinAnt		:= ''
Local dValid		:= STOD('')
Local lDisarm		:= .F.
Local lEof02		:= .T.

(cAliasBR)->(DbGoTop())

Begin Transaction

While (cAliasBR)->(!EOF())

	DbSelectArea('SC2')
	SC2->(DbGoTo((cAliasBR)->RECNO))

	//Identifica o tipo do produto
	cTipo := Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_TIPO')

	//Valida Roteiro
	//#TB20191122 Thiago Berna - Ajuste para considerar todos os tipos
	//If cTipo == 'PA'
		lDisarm := ValRotei(@cLinha,(cAliasBR)->C2_PRODUTO,@aErro,AllTrim((cAliasBR)->C2_NUM+(cAliasBR)->C2_ITEM+(cAliasBR)->C2_SEQUEN),lDisarm)
	//EndIf

	If Empty(cOP + cItem + cSeq)
		cOP		:= (cAliasBR)->C2_NUM
		cItem	:= (cAliasBR)->C2_ITEM
		cSeq	:= (cAliasBR)->C2_SEQUEN
	EndIf
	
	If cOP + cItem == (cAliasBR)->(C2_NUM+C2_ITEM)
		nCount++
	Else
		
		//cLinha	:= SG2->G2_LINHAPR

		//Carrega Locais
		//#TB20200227 Thiago Berna - Ajuste para considerar 1 endereco para cada OP
		//aLocal := GeraLocal(cLinha,@lDisarm,@aErro,@cArm,@cInd,@cZona,@lEof02,cOp+cItem+cSeq)
		aLocal := GeraLocal(cLinha,@lDisarm,@aErro,@cArm,@cInd,@cZona,@lEof02,cOp+cItem+cSeq,aOPsIn)

		//Firma PA
		lDisarm := FirmaPA(aDadosPA,aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm)

		//#TB20200227 Thiago Berna - Executa caso nao tenha ocorrido erro
		If !lDisarm 

			//#TB20200227 Thiago Berna - Verifica se encontrou endereco disponivel para todas OPS
			//If Len(aLocal) >= Len(aOPsIn) + 1
				
				For nB := 1 to Len(aOPsIn)
					//Inclui novos PI e PP			
					//#TB20191213 Thiago Berna - Ajuste para reutilizar endereco do PI no PP
					//lDisarm := FirmaPI(aOPsIn[nB,1],aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm,aOPsIn[nB,2])
					lDisarm := FirmaPI(aOPsIn[nB,1],aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm,aOPsIn[nB,2],@cEndAnt,@cLinAnt)
					
					//#TB20200227 Thiago Berna - Encerra caso tenha ocorrido erro
					If lDisarm
						Exit
					EndIf

				Next nB

			/*Else
				lDisarm := .T.
				If !lEof02			
					AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
				Else			
					AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Não existem endereços cadastrados para o armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
				EndIf
			EndIf*/
		EndIf

		//#TB20191213 Thiago Berna - Ajuste para reutilizar endereco do PI no PP
		cLinAnt := ''
		cEndAnt := ''

		SC2->(DbGoTo((cAliasBR)->RECNO))
		nCount 	:= 1
		cOP		:= (cAliasBR)->C2_NUM
		cItem	:= (cAliasBR)->C2_ITEM
		cSeq	:= (cAliasBR)->C2_SEQUEN

	EndIf

	//#TB20200227 Thiago Berna - Encerra caso tenha ocorrido erro
	If lDisarm
		Exit
	EndIf

	//Identifica o tipo do produto
	//cTipo := Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_TIPO')

	If nCount == 1
	
		//#TB20191010 Thiago Berna - Ajuste para firmar PI quando nao existir PA
		//If cTipo == 'PA'
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Parâmetros para Firmar OP - MATA651                          ³
			//³ mv_par01            // De  Produto                           ³
			//³ mv_par02            // Ate Produto                           ³
			//³ mv_par03            // De  Ordem de Producao                 ³
			//³ mv_par04            // Ate Ordem de Producao                 ³
			//³ mv_par05            // De  Data de Entrega                   ³
			//³ mv_par06            // Ate Data de Entrega                   ³
			//³ mv_par07            // De  Data de Inicio                    ³
			//³ mv_par08            // Ate Data de Inicio                    ³
			//³ mv_par09            // Firma OPs Intermediarias (1=Sim 2=Não)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//Dados da OP do PA para firmar
			aDadosPA	:= {{'MV_PAR01',(cAliasBR)->C2_PRODUTO},{'MV_PAR02',(cAliasBR)->C2_PRODUTO},{'MV_PAR03',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR04',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR05',(cAliasBR)->C2_DATPRF},{'MV_PAR06',(cAliasBR)->C2_DATPRF},{'MV_PAR07',(cAliasBR)->C2_DATPRI},{'MV_PAR08',(cAliasBR)->C2_DATPRI},{'MV_PAR09',1}}

			//#TB20191220 Thiago Berna - Carrega variavel cSeqPai
			cSeqPai := SC2->C2_SEQUEN
			//cLinha	:= SG2->G2_LINHAPR

			//Ajusta dados da OP PA
			SC2->(RecLock('SC2',.F.))
			SC2->C2_XLOTE   := &(Posicione('SM4',1,xFilial('SM4')+Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_FORMLOT'),'M4_FORMULA'))
			SC2->C2_XDTVAL  := dDataBase + Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_PRVALID')
			SC2->C2_XDTFIR  := dDataBase
			SC2->C2_XORIGEM := 'PCP020' 
			SC2->C2_XCODPRG	:= cCodPrg
			SC2->(MsUnlock())
			
		//EndIf

	Else

		//Exclusão
		nOpc := 5

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parâmetros para Excluir OP - MATA651                         ³
		//³ mv_par01            // De  Produto                           ³
		//³ mv_par02            // Ate Produto                           ³
		//³ mv_par03            // De  Ordem de Producao                 ³
		//³ mv_par04            // Ate Ordem de Producao                 ³
		//³ mv_par05            // De  Data de Entrega                   ³
		//³ mv_par06            // Ate Data de Entrega                   ³
		//³ mv_par07            // De  Data de Inicio                    ³
		//³ mv_par08            // Ate Data de Inicio                    ³
		//³ mv_par09            // Firma OPs Intermediarias (1=Sim 2=Não)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aDadosPI	:= {{'MV_PAR01',(cAliasBR)->C2_PRODUTO},{'MV_PAR02',(cAliasBR)->C2_PRODUTO},{'MV_PAR03',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR04',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR05',(cAliasBR)->C2_DATPRF},{'MV_PAR06',(cAliasBR)->C2_DATPRF},{'MV_PAR07',(cAliasBR)->C2_DATPRI},{'MV_PAR08',(cAliasBR)->C2_DATPRI},{'MV_PAR09',1}}
		
		//Identifica a OP do PI para reinclusao
		//#TB20191220 Thiago Berna - Ajuste para considerar PI e PP na reinclusao de OPS
		//If Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_TIPO') == 'PI'
		If Posicione('SB1',1,xFilial('SB1')+(cAliasBR)->C2_PRODUTO,'B1_TIPO') $ 'PI|PP'
 
			cNovaOP := GetNumSC2()
			
			//#TB20191220 Thiago Berna - Ajuste para incluir OPS intermediarias que tenham  o campo C2_SEQPAI = C2_SEQUEN da OP principal
			//#TB20200227 Thiago Berna - AJuste para reincluir todas OPS intermediarias
			//If SC2->C2_SEQPAI == cSeqPai
			
				//Incluir nova OP do PI
				//#TB20200227 Thiago Berna - Ajuste para nao gerar OPS Intermediarias 
				/*aDadosIn:={	{'C2_FILIAL'   	,xFilial('SC2')	,NIL},;
							{'C2_PRODUTO'  	,SC2->C2_PRODUTO,NIL},;
							{'C2_NUM'  	   	,cNovaOP		,NIL},;          
							{'C2_ITEM'     	,'01'			,NIL},;          
							{'C2_SEQUEN'   	,'001'			,NIL},;
							{'C2_LOCAL'   	,SC2->C2_LOCAL	,NIL},;
							{'C2_CC'	   	,SC2->C2_CC		,NIL},;
							{'C2_QUANT'		,SC2->C2_QUANT	,NIL},;
							{'C2_DATPRI'    ,SC2->C2_DATPRI	,NIL},;
							{'C2_DATPRF'    ,SC2->C2_DATPRF	,NIL},;
							{'C2_OBS'   	,SC2->C2_OBS	,NIL},;
							{'C2_EMISSAO'   ,SC2->C2_EMISSAO,NIL},;
							{'C2_PRIOR'    	,SC2->C2_PRIOR	,NIL},;
							{'C2_STATUS'   	,SC2->C2_STATUS	,NIL},;
							{'C2_ROTEIRO'  	,'01'			,NIL},;
							{'C2_TPOP'      ,'F'			,NIL},;
							{'C2_LINHA'  	,SC2->C2_LINHA	,NIL},;
							{'C2_DIASOCI'  	,SC2->C2_DIASOCI,NIL},;
							{'C2_TPPR'  	,SC2->C2_TPPR	,NIL},;
							{'C2_OPTERCE'  	,SC2->C2_OPTERCE,NIL},;
							{'C2_DESTINA'  	,SC2->C2_DESTINA,NIL},;
							{'C2_XSEQVDA'   ,SC2->C2_XSEQVDA,NIL},;
							{'C2_XCAIXA'    ,SC2->C2_XCAIXA	,NIL},;
							{'C2_XSEQIT'    ,SC2->C2_XSEQIT	,NIL},;											
							{'AUTEXPLODE'   ,'S'			,Nil} ;
						}*/

				aDadosIn:={	{'C2_FILIAL'   	,xFilial('SC2')	,NIL},;
							{'C2_PRODUTO'  	,SC2->C2_PRODUTO,NIL},;
							{'C2_NUM'  	   	,cNovaOP		,NIL},;          
							{'C2_ITEM'     	,'01'			,NIL},;          
							{'C2_SEQUEN'   	,'001'			,NIL},;
							{'C2_LOCAL'   	,SC2->C2_LOCAL	,NIL},;
							{'C2_CC'	   	,SC2->C2_CC		,NIL},;
							{'C2_QUANT'		,SC2->C2_QUANT	,NIL},;
							{'C2_DATPRI'    ,SC2->C2_DATPRI	,NIL},;
							{'C2_DATPRF'    ,SC2->C2_DATPRF	,NIL},;
							{'C2_OBS'   	,SC2->C2_OBS	,NIL},;
							{'C2_EMISSAO'   ,SC2->C2_EMISSAO,NIL},;
							{'C2_PRIOR'    	,SC2->C2_PRIOR	,NIL},;
							{'C2_STATUS'   	,SC2->C2_STATUS	,NIL},;
							{'C2_ROTEIRO'  	,'01'			,NIL},;
							{'C2_TPOP'      ,'F'			,NIL},;
							{'C2_LINHA'  	,SC2->C2_LINHA	,NIL},;
							{'C2_DIASOCI'  	,SC2->C2_DIASOCI,NIL},;
							{'C2_TPPR'  	,SC2->C2_TPPR	,NIL},;
							{'C2_OPTERCE'  	,SC2->C2_OPTERCE,NIL},;
							{'C2_DESTINA'  	,SC2->C2_DESTINA,NIL},;
							{'C2_XSEQVDA'   ,SC2->C2_XSEQVDA,NIL},;
							{'C2_XCAIXA'    ,SC2->C2_XCAIXA	,NIL},;
							{'C2_XSEQIT'    ,SC2->C2_XSEQIT	,NIL},;
							{'AUTEXPLODE'   ,'S'			,Nil},;
							{'GERAOPI'   	,'N'			,Nil} ;
						}

				cOPOrig := aDadosPI[3,2]

				AAdd(aOPsIn,{aDadosIn,cOPOrig})

			//EndIf
		EndIf

		//Excluir OPS de PI e PP
		MsgRun("Excluindo OP " + (cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),,{|| MSExecAuto({|x,y| Mata651(x,y)},aDadosPI,nOpc) })

		If lMsErroAuto					
			AAdd(aErro,{AllTrim((cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)),NomeAutoLog()})
			lDisarm	:= .T.
			Exit
		EndIf

	EndIf	

	(cAliasBR)->(DbSkip())

EndDo

//Carrega locais
//#TB20200227 Thiago Berna - Ajuste para considerar 1 endereco para cada OP
//aLocal := GeraLocal(cLinha,@lDisarm,@aErro,@cArm,@cInd,@cZona,@lEof02,cOp+cItem+cSeq)
aLocal := GeraLocal(cLinha,@lDisarm,@aErro,@cArm,@cInd,@cZona,@lEof02,cOp+cItem+cSeq,aOPsIn)

//#TB20200227 Thiago Berna - Executa caso nao tenha ocorrido erro
If !lDisarm

	//#TB20200227 Thiago Berna - Verifica se encontrou endereco disponivel para todas OPS
	//If Len(aLocal) >= Len(aOPsIn) + 1
	
		//FirmaPA
		lDisarm := FirmaPA(aDadosPA,aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm)

		For nB := 1 to Len(aOPsIn)
			//Inclui novos PI e PP
			//#TB20191213 Thiago Berna - Ajuste para reutilizar endereco do PI no PP
			//lDisarm := FirmaPI(aOPsIn[nB,1],aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm,aOPsIn[nB,2])
			lDisarm := FirmaPI(aOPsIn[nB,1],aLocal,lEof02,cArm,cInd,cZona,@aErro,lDisarm,aOPsIn[nB,2],@cEndAnt,@cLinAnt)

			//#TB20200227 Thiago Berna - Encerra caso tenha ocorrido erro
			If lDisarm
				Exit
			EndIf

		Next nB

	/*Else
		lDisarm := .T.
		If !lEof02			
			AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
		Else			
			AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Não existem endereços cadastrados para o armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
		EndIf
	EndIf*/

EndIf

//#TB20191213 Thiago Berna - Ajuste para reutilizar endereco do PI no PP
cLinAnt := ''
cEndAnt := ''

//Verifica se ocorreu algum erro
If lDisarm

	//Ordena os erros para gerar os logs na ordem correta
	ASort(aErro, , , { | x,y | y[1] > x[1] } )

	For nA := 1 to Len(aErro)
		cErro += aErro[nA,2] + ENTER + ENTER
	Next
	
	If !Empty(cErro)
		GeraLog(cErro, "Erros Ocorridos", 1, .F.)
	Endif
	
	//Redefine Array com enderecos utilizados
	aUtiliz := {}

	DisarmTransaction()
	
Else
	(cAliasBR)->(DbGoTop())
	While (cAliasBR)->(!EOF())
		(cAliasBR)->(DbDelete())
		(cAliasBR)->(DbSkip())
	EndDo
EndIf

End Transaction

If Select(cAlias01) > 0
	DbSelectArea(cAlias01)
	DbCloseArea()
EndIf

If Select(cAlias02) > 0
	DbSelectArea(cAlias02)
	DbCloseArea()
EndIf

oBrowse:GoTop(.T.)
oBrowse:Refresh()

Return

/*---------------------------------------------------------------------*
| Func:  PCP020EX                                                     |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Excluir OP                                                   |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

User Function PCP020EX()

Local nOpc 			:= 0
Local lMsErroAuto	:= .F.
Local aDados 		:= {}

//Exclusão
nOpc := 5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parâmetros para Excluir OP - MATA651                         ³
//³ mv_par01            // De  Produto                           ³
//³ mv_par02            // Ate Produto                           ³
//³ mv_par03            // De  Ordem de Producao                 ³
//³ mv_par04            // Ate Ordem de Producao                 ³
//³ mv_par05            // De  Data de Entrega                   ³
//³ mv_par06            // Ate Data de Entrega                   ³
//³ mv_par07            // De  Data de Inicio                    ³
//³ mv_par08            // Ate Data de Inicio                    ³
//³ mv_par09            // Firma OPs Intermediarias (1=Sim 2=Não)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aDados	:= {{'MV_PAR01',(cAliasBR)->C2_PRODUTO},{'MV_PAR02',(cAliasBR)->C2_PRODUTO},{'MV_PAR03',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR04',(cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)},{'MV_PAR05',(cAliasBR)->C2_DATPRF},{'MV_PAR06',(cAliasBR)->C2_DATPRF},{'MV_PAR07',(cAliasBR)->C2_DATPRI},{'MV_PAR08',(cAliasBR)->C2_DATPRI},{'MV_PAR09',1}}

MsgRun("Excluindo OP " + (cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),,{|| MSExecAuto({|x,y| Mata651(x,y)},aDados,nOpc) })

If lMsErroAuto	
	AAdd(aErro,{AllTrim((cAliasBR)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)),NomeAutoLog()})
	lDisarm	:= .T.
Else
	(cAliasBR)->(DbDelete())
EndIf

oBrowse:GoTop(.T.)
oBrowse:Refresh()

Return

/*---------------------------------------------------------------------*
| Func:  GeraDados                                                    |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Gera dados na tabela temporaria                              |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function GeraDados(oProcess,lEnd)

	Local cQuery		:= ''
	Local cAliasGD		:= GetNextAlias()	
	Local lOracle		:= TcGetDb() $ "INFORMIX*ORACLE" 
	Local nCount		:= 0

	If Select(cAliasGD) > 0		
		(cAliasGD)->(DbCloseArea())
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parâmetros MADERO_PCP020                                     ³
	//³ mv_par01            // De  Ordem de Producao                 ³
	//³ mv_par02            // Ate Ordem de Producao                 ³
	//³ mv_par03            // De  Data de Inicio                    ³
	//³ mv_par04            // Ate Data de Entrega                   ³
	//³ mv_par05            // De  Data de Emissão                   ³
	//³ mv_par06            // Ate Data de Emissão                   ³
	//³ mv_par07            // De Produto                            ³
	//³ mv_par08            // Ate Produto                           ³
	//³ mv_par09            // Programador                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//#TB20191206 Thiago Berna - Ajuste para considerar todas as OPS Pai e Filhas
	cQuery := "SELECT * FROM " + RetSqlTab("SC2")
	cQuery += "WHERE  SC2.C2_FILIAL = '" + xFilial("SC2") + "'  
	cQuery += "AND SC2.C2_NUM IN ( "
 
	//#TB20191206 Thiago Berna - Ajuste para considerar todas as OPS Pai e Filhas
	//cQuery := "SELECT * " 
	cQuery += "SELECT DISTINCT SC2.C2_NUM "
	
	cQuery += "FROM " + RetSqlTab("SC2")
	
	//Considera o programador
	If !Empty(MV_PAR09)
		cQuery += "INNER JOIN " + RetSqlTab("Z56")
		cQuery += "ON Z56.Z56_FILIAL = '" + xFilial("Z56") + "' "		   
		cQuery += "AND Z56.Z56_COD = '" + MV_PAR09 + "' "
		cQuery += "AND Z56.Z56_PROD = SC2.C2_PRODUTO "
		cQuery += "AND Z56.D_E_L_E_T_ = '' "
	EndIf
	
	cQuery += "WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' " 
	cQuery += "AND SC2.C2_TPOP = 'P' "
	cQuery += "AND SC2.C2_BATCH = 'S' "

	If lOracle
		cQuery += "AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD >= '" + MV_PAR01 + "' "
		cQuery += "AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD <= '" + MV_PAR02 + "' " 
	Else
		cQuery += "AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN + SC2.C2_ITEMGRD >= '" + MV_PAR01 + "' "
		cQuery += "AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN + SC2.C2_ITEMGRD <= '" + MV_PAR02 + "' " 
	EndIf

	cQuery += "AND SC2.C2_DATPRI >= '" + DTOS(MV_PAR03) + "' " 
	cQuery += "AND SC2.C2_DATPRF <= '" + DTOS(MV_PAR04) + "' " 
	cQuery += "AND SC2.C2_PRODUTO >= '" + MV_PAR07 + "' "
	cQuery += "AND SC2.C2_PRODUTO <= '" + MV_PAR08 + "' "
	cQuery += "AND SC2.C2_EMISSAO >= '" + DTOS(MV_PAR05) + "' "
	cQuery += "AND SC2.C2_EMISSAO <= '" + DTOS(MV_PAR06) + "' "

	cQuery += "AND SC2.D_E_L_E_T_ = '' "
	
	//#TB20191206 Thiago Berna - Ajuste para considerar todas as OPS Pai e Filhas
	cQuery += ") "
	cQuery += "AND SC2.D_E_L_E_T_ = '' "
	
	cQuery += "ORDER BY SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGD, .F., .T.)
	
	Count to nCount
	
	oProcess:SetRegua1()
	oProcess:IncRegua1()
	oProcess:SetRegua2(nCount)

	DbSelectArea(cAliasGD)
	DbGoTop()

	While (cAliasGD)->(!Eof())
		
		oProcess:IncRegua2()

		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SC2")
		
		RecLock(cAliasBR,.T.)
		While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == 'SC2'
		
			If AllTrim(SX3->X3_BROWSE) == 'S' .And. cNivel >= SX3->(X3_NIVEL) .And. AllTrim(SX3->X3_CONTEXT) != 'V'		
				&(cAliasBR + '->' + AllTrim(SX3->X3_CAMPO)) := IIF(SX3->X3_TIPO == 'D',STOD(&(cAliasGD + '->' + AllTrim(SX3->X3_CAMPO))),&(cAliasGD + '->' + AllTrim(SX3->X3_CAMPO)))  
			Else
				If AllTrim(SX3->X3_CAMPO) $ 'C2_FILIAL|C2_NUM|C2_ITEM|C2_SEQUEN|C2_ITEMGRD|C2_DATPRF|C2_DATPRI|C2_PRODUTO'
					&(cAliasBR + '->' + AllTrim(SX3->X3_CAMPO)) := IIF(SX3->X3_TIPO == 'D',STOD(&(cAliasGD + '->' + AllTrim(SX3->X3_CAMPO))),&(cAliasGD + '->' + AllTrim(SX3->X3_CAMPO)))  
				EndIf
			EndIf
		
			SX3->(DbSkip())
		
		EndDo
		//Adiciona dados no campo RECNO
		&(cAliasBR + '->' + 'RECNO') := &(cAliasGD + '->R_E_C_N_O_')
	
		(cAliasBR)->(MsUnlock())

		(cAliasGD)->(DbSkip())
	Enddo

	

	If Select(cAliasGD) > 0		
		(cAliasGD)->(DbCloseArea())
	EndIf

Return

/*---------------------------------------------------------------------*
| Func:  GeraLog                                                      |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Gera LOG						                              |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function GeraLog(cMsg, cTitulo, nTipo, lEdit)
	Local lRetMens := .F.
	Local oDlgMens
	Local oBtnOk, cTxtConf := ""
	Local oBtnCnc, cTxtCancel := ""
	Local oBtnSlv
	Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
	Local oMsg
	Default cMsg    := "..."
	Default cTitulo := "zMsgLog"
	Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
	Default lEdit   := .F.

	//Definindo os textos dos botões
	If(nTipo == 1)
		cTxtConf:='&Ok'
	Else
		cTxtConf:='&Confirmar'
		cTxtCancel:='C&ancelar'
	EndIf

	//Criando a janela centralizada com os botões
	DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
	//Get com o Log
	@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
	If !lEdit
		oMsg:lReadOnly := .T.
	EndIf

	//Se for Tipo 1, cria somente o botão OK
	If (nTipo==1)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL

		//Senão, cria os botões OK e Cancelar
	ElseIf(nTipo==2)
		@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
		@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
	EndIf

	//Botão de Salvar em Txt
	@ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
	ACTIVATE MSDIALOG oDlgMens CENTERED

Return lRetMens

/*---------------------------------------------------------------------*
| Func:  SalvaLog                                                     |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Salva Log Gerado                                             |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function fSalvArq(cMsg, cTitulo)
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""

	//Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)

	//Se o nome não estiver em branco    
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf

		//Montando a mensagem
		cTexto := "Função   - "+ FunName()       + CRLF
		cTexto += "Usuário  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra

		//Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return

/*---------------------------------------------------------------------*
| Func:  GeraLocal                                                    |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Gera array com enderecos disponiveis                         |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function GeraLocal(cLinha,lDisarm,aErro,cArm,cInd,cZona,lEof02,cOp,aOPsIn)

Local cQuery := ''
Local cLinCod:= ''
Local cAlias02	:= GetNextAlias()
Local cAlias01	:= GetNextAlias()
Local aLocal	:= {}
Local aAreaZ55	:= Z55->(GetArea())

	//#TB20190820 Thiago Berna - Localiza os dados na Tabela Z55 (Cadastro de Linhas) para preencher o campo C2_XLOCALI (Endereço Requisições)
	DbSelectArea('Z55')
	DbSetOrder(1)

	If DbSeek(xFilial('Z55') + cLinha)

		cArm 	:= Z55->Z55_CODARM
		cInd	:= Z55->Z55_CODIND
		cZona	:= Z55->Z55_CODZON
					
		cQuery := "SELECT TMPSC2.C2_XLOCALI " + ENTER
		cQuery += "FROM " + ENTER

		cQuery += "(SELECT SUBSTR(SC2.C2_XLOCALI,1,5) C2_XLOCALI " + ENTER
		cQuery += "FROM " + RetSqlTab('SC2') + ENTER
		cQuery += "WHERE C2_FILIAL =  '" + xFilial('SC2') + "' " + ENTER
		cQuery += "AND SC2.C2_TPOP = 'F' " + ENTER
		cQuery += "AND SC2.C2_FILIAL||SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN NOT IN " + ENTER
		cQuery += "(SELECT SD3.D3_FILIAL||SD3.D3_OP FROM " + RetSqlTab('SD3') + " WHERE SD3.D3_PARCTOT = 'T' AND SD3.D3_ESTORNO = ' ' AND SD3.D_E_L_E_T_ = '') " + ENTER
		cQuery += "AND SC2.C2_XORIGEM = 'PCP020' " + ENTER
		cQuery += "AND SC2.D_E_L_E_T_ <> '*') TMPSC2 " + ENTER

		cQuery += "WHERE TMPSC2.C2_XLOCALI = '" + Z55->(Z55_CODIND+Z55_CODZON) + "' "

		cQuery := ChangeQuery(cQuery)

		If Select(cAlias02) > 0
			DbSelectArea(cAlias02)
			DbCloseArea()
		EndIf
							
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias02, .F., .T.)

		If (cAlias02)->(!EOF())
			lEof02 := .F.
		Else
			lEof02 := .T.
		EndIf
		
		cQuery := "SELECT TMPSBE.BE_LOCALIZ " + ENTER
		cQuery += "FROM " + ENTER
						
		cQuery += "(SELECT SBE.BE_LOCALIZ, SUBSTR(SBE.BE_LOCALIZ,1,5) Z5_LOCALIZ " + ENTER
		cQuery += "FROM " + RetSqlTab('SBE') + ENTER
		cQuery += "WHERE SBE.BE_FILIAL = '" + xFilial('SBE') + "' " + ENTER
		cQuery += "AND SBE.BE_LOCAL = '" + Z55->Z55_CODARM + "' " + ENTER

		cQuery += "AND NOT SBE.BE_LOCALIZ IN " + ENTER
		cQuery += "(SELECT SC2.C2_XLOCALI " + ENTER
		cQuery += "FROM " + RetSqlTab('SC2') + ENTER
		cQuery += "WHERE C2_FILIAL =  '" + xFilial('SC2') + "' "  + ENTER
		cQuery += "AND SC2.C2_TPOP = 'F' " + ENTER
		
		//#TB20200226 Thiago Berna - Ajuste para buscar os enderecos disponiveis
		cQuery += "AND SC2.C2_DATRF = ' ' "
		/*cQuery += "AND SC2.C2_FILIAL||SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN NOT IN " + ENTER
		cQuery += "(SELECT SD3.D3_FILIAL||SD3.D3_OP FROM " + RetSqlTab('SD3') + " WHERE SD3.D3_PARCTOT = 'T' AND SD3.D3_ESTORNO = ' ' AND SD3.D_E_L_E_T_ = '' ) " + ENTER*/
		
		cQuery += "AND SC2.C2_XORIGEM = 'PCP020' " + ENTER
		cQuery += "AND SC2.D_E_L_E_T_ <> '*') " + ENTER

		cQuery += "AND SBE.D_E_L_E_T_ = '' " + ENTER
		cQuery += "ORDER BY BE_LOCALIZ) TMPSBE " + ENTER
						
		cQuery += "WHERE TMPSBE.Z5_LOCALIZ = '" + Z55->(Z55_CODIND+Z55_CODZON) + "' "

		cQuery := ChangeQuery(cQuery)

		If Select(cAlias01) > 0
			DbSelectArea(cAlias01)
			DbCloseArea()
		EndIf
							
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias01, .F., .T.)

		//#TB20191213 Thiago Berna - Ajuste para preencher a linha
		cLinCod := Z55->Z55_COD

		//#TB20200227 Thiago Berna - Ajuste para considerar 1 endereco para cada OP
		//While (cAlias01)->(!Eof()) .And. Len(aLocal) < 2
		While (cAlias01)->(!Eof()) .And. Len(aLocal) < ( Len(aOPsIn) + 1 )

			//#TB20191127 Thiago Berna - Ajuste para nao considerar endereços de transição especificados na Z55
			DbSelectArea('Z55')
			Z55->(DbSetOrder(4))
			If !Z55->(DbSeek(xFilial('Z55') + (cAlias01)->BE_LOCALIZ))
				
				If !Ascan(aUtiliz,{|x| x[1] == (cAlias01)->BE_LOCALIZ})
					//#TB20191213 Thiago Berna - Ajuste para preencher a linha
					//AAdd(aLocal,{(cAlias01)->BE_LOCALIZ,Z55->Z55_COD})
					AAdd(aLocal,{(cAlias01)->BE_LOCALIZ,cLinCod})
				EndIf

			EndIf
			RestArea(aAreaZ55)
			Z55->(DbSetOrder(1))
			
			(cAlias01)->(DbSkip())
		EndDo

	Else
		AAdd(aErro,{AllTrim(cOp),'OP: ' + cOP + '.Linha de produção [' + cLinha + '] não encontrada na tabela Z55.'})
		lDisarm	:= .T.
	EndIf

Return aLocal

/*---------------------------------------------------------------------*
| Func:  FirmaPA                                                      |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Firma OP do PA                                               |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function FirmaPA(aDadosPA,aLocal,lEof02,cArm,cInd,cZona,aErro,lDisarm)

Local nOpc 			:= 4
Local lMsErroAuto	:= .F.

//Firmar OP do PA
If Len(aDadosPA) > 0
			
	//cLotePI := 'PA'
	If Len(aLocal) > 0
		If aLocal[1] != Nil
			cLinPI	:= aLocal[1,2]
			cEndPI	:= aLocal[1,1]
			AAdd(aUtiliz,{aLocal[1,1]})
			aDel(aLocal,1)
		Else
			AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})			
			lDisarm := .T.
		EndIf
	Else
		If !lEof02			
			AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
		Else			
			AAdd(aErro,{AllTrim(aDadosPA[3,2]),'OP: ' + aDadosPA[3,2] + '.Não existem endereços cadastrados para o armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
		EndIf
		lDisarm := .T.
	EndIf

	If !lDisarm
		MsgRun("Firmando OP " + aDadosPA[3,2],,{|| MSExecAuto({|x,y| Mata651(x,y)},aDadosPA,nOpc) })
	EndIf

	If lMsErroAuto			
		AAdd(aErro,{AllTrim(aDadosPA[3,2]),NomeAutoLog()})
		lDisarm	:= .T.
	EndIf

	aDadosPA := {}
			
EndIf

Return lDisarm

/*---------------------------------------------------------------------*
| Func:  FirmaPI                                                      |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Inclui novas OPS do PI e PP                                  |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function FirmaPI(aDadosIn,aLocal,lEof02,cArm,cInd,cZona,aErro,lDisarm,cOPOrig,cEndAnt,cLinAnt)

Local nOpc 			:= 3
Local lMsErroAuto	:= .F.
		
		//Incluir OP do PI
		If Len(aDadosIn) > 0
			
			DbSelectArea('SB1')
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1')+aDadosIn[2,2]))

			//cLotePI := &(Posicione('SM4',1,xFilial('SM4')+SB1->B1_FORMLOT,'M4_FORMULA'))
			//dValPI 	:= dDataBase + SB1->B1_PRVALID

			If Len(aLocal) > 0
				If aLocal[1] != Nil
					cLinPI	:= aLocal[1,2]
					cEndPI	:= aLocal[1,1]
					
					//#TB20191213 Thiago Berna - Ajuste para gravar o endereco para usar nas demais sequencias de PI/PP
					cLinAnt	:= aLocal[1,2]
					cEndAnt	:= aLocal[1,1]
					
					AAdd(aUtiliz,{aLocal[1,1]})
					aDel(aLocal,1)
				Else					
					//#TB20191213 Thiago Berna - Ajuste para gravar o endereco para usar nas demais sequencias de PI/PP
					//#TB20200227 Thiago Berna - Ajuste para usar um endereco em cada OP
					/*If !Empty(cLinAnt) .And. !Empty(cEndAnt)
						cLinPI	:= cLinAnt
						cEndPI	:= cEndAnt
					Else*/
						AAdd(aErro,{AllTrim(cOPOrig),'OP: ' + cOPOrig + '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})					
						lDisarm := .T.
					//EndIf
				EndIf
			Else				
				If !lEof02 					
					AAdd(aErro,{AllTrim(cOPOrig),'OP: ' + cOPOrig+ '.Todos os endereços cadastrados foram utilizados nas ordens de produção do armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
				Else					
					AAdd(aErro,{AllTrim(cOPOrig),'OP: ' + cOPOrig + '.Não existem endereços cadastrados para o armazém, indústria e zona de armazenagem. [Z55_CODARM = ' + cArm + ', Z55_CODIND = ' + cInd + ' e Z55_CODZON = ' + cZona + ']'})
				EndIf				
				lDisarm := .T.
			EndIf

			If !lDisarm
				MsgRun("Incluindo OP " + aDadosIn[3,2]+aDadosIn[4,2]+aDadosIn[5,2],,{|| MSExecAuto({|x,y| Mata650(x,y)},aDadosIn,nOpc) })
			EndIf

			If lMsErroAuto		
				AAdd(aErro,{AllTrim(cOPOrig),NomeAutoLog()})
				lDisarm := .T.
			EndIf

			aDadosIn:= {}
			//cLotePI	:= ''
			//dValPI	:= STOD('')
			
		EndIf

Return lDisarm

/*---------------------------------------------------------------------*
| Func:  ValRotei                                                     |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Valida Roteiro                                               |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function ValRotei(cLinha,cProduto,aErro,cOp,lDisarm)

Local nValida 	:= 0
Local nValLinha	:= 0

DbSelectArea('SG2')
SG2->(DbSetOrder(1))
SG2->(DbSeek(xFilial('SG2')+cProduto))

If SG2->(Found())
	cLinha	:= SG2->G2_LINHAPR
EndIf

While SG2->(!EOF()) .And. SG2->G2_FILIAL == xFilial('SG2') .And. SG2->G2_PRODUTO == cProduto
	nValida 	:= nValida + IIF(Val(SG2->G2_OPERAC)>0,1,0)
	nValLinha	:= IIF(StrZero(nValida,2) == '01',1,nValLinha)
	SG2->(DbSkip())
EndDo

If nValida == 0 
	AAdd(aErro,{AllTrim(cOP),'OP: ' + cOp + ' .Não há roteiro de operação para o produto ' + cProduto + '.'})
	lDisarm	:= .T.
ElseIf nValida > 1
	AAdd(aErro,{AllTrim(cOp),'OP: ' + cOp + ' .Há mais de um roteiro de operação para o produto ' + cProduto + '. Deverá ser informado apenas um roteiro por produto conforme especificação do processo.'})
	lDisarm	:= .T.
EndIf

If nValLinha == 0	
	AAdd(aErro,{AllTrim(cOp),'OP: ' + cOp + ' .Linha de produção não informada no roteiro de operação para o produto ' + cProduto + '.'})
	lDisarm	:= .T.
EndIf

Return lDisarm