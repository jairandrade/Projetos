#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda - inclusão da linha                                                                                          **/
/** Calculo de custo medio baseado na tabela de custo                            																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   

User Function CALCCM() 

Local aArea  	 		:= GetArea()
Private	cTabela			:= 'EMP01FIL01ARM20'
Private nCPar				:= 0
Private nCAux				:= 0
Private nI					:= 0 
Private nX					:= 0
Private cErro				:= ""
Private cTm				:= ""
Private cCodProd  := ""
Private cUm				:= ""
Private cArm			:= ""
Private cGrupo		:= ""
Private cEmis			:= "31/07/2016"
Private cCtb			:= ""
Private cCusto		:= ""
Private	cDesc			:= ""

//CALCULA SALDO MENOR QUE ZERO
QSB2CM()
//CALCULA SALDO MAIOR QUE ZERO
QSB2O()

	While (!QSB2CM->(Eof()))
	
				cCodProd  := QSB2CM->B2_COD
				cUm				:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_UM")
				cArm			:= QSB2CM->B2_LOCAL
				cDesc			:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_DESC")
				cGrupo		:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_GRUPO")
				cCtb			:= "110301003"//POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_CONTA")
				
				nCPar	:=	(QSB2CM->B2_VATU1 *-1)
				cCusto 	:=  cValtoChar(nCPar)
				
										//PROCESSA MOVIMENTO INTERNO REMOVENDO SALDO (+)
				cTm				:= "320"
				cErro := GrvMovInt( cTm, cCodProd,cDesc, cUm, cArm, cGrupo, cEmis, cCusto, cCtb )
				//MSGINFO("" + cCodProd + " - " + cErro) 
				nI++
					
	QSB2CM->(DbSkip())
	
EndDo
				      
	While (!QSB2O->(Eof()))
	
				cCodProd  := QSB2O->B2_COD
				cUm				:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_UM")
				cArm			:= QSB2O->B2_LOCAL
				cDesc			:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_DESC")
				cGrupo		:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_GRUPO")
				cCtb			:= "110301003"//POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_CONTA")
				
				nCPar	:=	(QSB2O->B2_VATU1)
				cCusto 	:=  cValtoChar(nCPar)
				
										//PROCESSA MOVIMENTO INTERNO REMOVENDO SALDO (-)
				cTm				:= "620"
				cErro := GrvMovInt( cTm, cCodProd,cDesc, cUm, cArm, cGrupo, cEmis, cCusto, cCtb )
				//MSGINFO("" + cCodProd + " - " + cErro) 
				nX++
					
	QSB2O->(DbSkip())

EndDo
 
 MSGINFO("CUSTO ZERADO!!!!.: " +  cValToChar(nI) + " - "  +  cValToChar(nX) + " TOTAL " + cValToChar(nX + nI)   )
 
 QSB2O->(DbCloseArea())
 QSB2CM->(DbCloseArea())
RestArea(aArea)

Return nil

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   

User Function INCCUS() 

Local aArea  	 		:= GetArea()
Private	cTabela			:= 'EMP01FIL01ARM20'
Private nCPar				:= 0
Private nCAux				:= 0
Private nI					:= 0 
Private nX					:= 0
Private cErro				:= ""
Private cTm				:= ""
Private cCodProd  := ""
Private cUm				:= ""
Private cArm			:= ""
Private cGrupo		:= ""
Private cEmis			:= "31/07/2016"
Private cCtb			:= ""
Private cCusto		:= ""
Private	cDesc			:= ""

//CALCULA SALDO MENOR QUE ZERO
QSB2IC()

	While (!QSB2IC->(Eof()))
				
				//CONSULTA PRODUTO PLANILHA DE CONTAGEM
			  EST(cTabela,QSB2IC->B2_COD)
				
			  If(	EST->CODIGO  <> NIL )
				
						cCodProd  := QSB2IC->B2_COD
						cUm				:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_UM")
						cArm			:= QSB2IC->B2_LOCAL
						cDesc			:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_DESC")
						cGrupo		:= POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_GRUPO")
						cCtb			:= "110301003"//POSICIONE("SB1", 1, xFilial("SB1") + cCodProd, "B1_CONTA")
						
						nCPar			:=	(QSB2IC->B2_QATU * EST->CUSTO )
						cCusto 		:=  cValtoChar(nCPar)
						
						//PROCESSA MOVIMENTO INTERNO INCLUINDO SALDO (+)
						cTm				:= "320"
						cErro 		:= GrvMovInt( cTm, cCodProd,cDesc, cUm, cArm, cGrupo, cEmis, cCusto, cCtb )
						//MSGINFO("" + cCodProd + " - " + cErro) 
						nI++
				
				EndIf	 
			 
				EST->(DbCloseArea())
					 
	QSB2IC->(DbSkip())
	
	
EndDo  

 QSB2IC->(DbCloseArea())
 
 MSGINFO("CUSTO INCLUIDO!!!!.: " +  cValToChar(nI) + " - "  +  cValToChar(nX) + " TOTAL " + cValToChar(nX + nI)     )

 
 
RestArea(aArea)

Return nil
 

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   

Static Function EST(cTab,cPr)  

Local aArea	:= GetArea()
Local cQuery  := ""  

cQuery := " 	  SELECT	  CODIGO
//cQuery += "		, DESCRICAO
//cQuery += "		, TIPO
//cQuery += "		, UNIDADE
cQuery += "		, INVENTARIO
cQuery += "		, CUSTO
		
cQuery += " FROM " + cTab + " EST " 

cQuery += "	WHERE	EST.CODIGO = '"+cPr+"'

//Define o alias da query
TcQuery cQuery New Alias "EST"

RestArea(aArea)

Return Nil

/**********************************************************************************************************************************/
/** static function GrvMovInt( cCodFil, cTm, cCodProd, cUm, cArm, cQuant, cGrupo, cEmis, cCusto, cCc, cCtb, cObs, cSolic )       **/
/** grava a movimentação interna mobile                                                                                          **/
/**********************************************************************************************************************************/
//static function GrvMovInt( cTm, cCodProd, cUm, cArm, cQuant, cGrupo, cEmis, cCusto, cCc, cCtb, cObs, cSolic, cCodEmp, cCodFil )
static function GrvMovInt( cTm, cCodProd,cDesc, cUm, cArm, cGrupo, cEmis, cCusto, cCtb ) 
  // retorno da função
  local cRet := ""
 
  // array de movimentação interna
  local aSd3 := {}
  private lMsErroAuto := .F.
      
  // monta o array de movimentação interna
  aSd3 := {}
  AAdd( aSd3, {"D3_FILIAL"			, xFilial("SD3")		, nil} )
  AAdd( aSd3, {"D3_TM"					, cTm								, nil} )
  AAdd( aSd3, {"D3_COD"					, cCodProd					, nil} )
  AAdd( aSd3, {"D3_DESCRI"			, cDesc							, nil} )
  AAdd( aSd3, {"D3_UM"					, cUm								, nil} )
  AAdd( aSd3, {"D3_LOCAL"				, cArm							, nil} )
  AAdd( aSd3, {"D3_QUANT"				, Val("0")					, nil} )
  AAdd( aSd3, {"D3_GRUPO"				, cGrupo						, nil} )
  AAdd( aSd3, {"D3_EMISSAO"			, Ctod(cEmis)				, nil} )
 
  // verifica se o tipo de TM aceita custo
  SF5->(dbSetOrder(1))
  SF5->(dbSeek(XFilial("SF5") + cTm))
  if (SF5->F5_VAL == "S")
    AAdd( aSd3, {"D3_CUSTO1", Val(cCusto), nil} )
  endIf
 
  //AAdd( aSd3, {"D3_CC", cCc, nil} )
  AAdd( aSd3, {"D3_CONTA", cCtb, nil} )
  //AAdd( aSd3, {"D3_I_OBS", cObs, nil} )
  //AAdd( aSd3, {"D3_I_SOLIC", cSolic, nil} )
 
  begin transaction
   
    //cria o armazem para o produto, se não existir
    CriaSb2( Padr(cCodProd, TamSx3("B1_COD")[01]), Padr(cArm, TamSx3("NNR_CODIGO")[01]) )
 
         // executa a rotina automatica
             lMsErroAuto := .F.
             MsExecAuto( {|x, y| Mata240(x, y)}, aSd3, 3 )
      
         if ( lMsErroAuto )
           // erro na rotina automatica
           DisarmTransactions()
           			// mostra erro
		 								Mostraerro()
                    cRet := "ParamOk=NO|MsgRet=" + GetMsErr() + "|DadosRet="
         else
           // procedimento ok
                    cRet := "ParamOk=OK|MsgRet=Movimento gravado com sucesso.|DadosRet="
         endIf
      
  end transaction
 
return cRet 

/**********************************************************************************************************************************/
/** static function GetMsErr                                                                                                     **/
/** retorna a string com o ultimo erro do log de erros de rotinas automaticas.                                                   **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
static function GetMsErr

	// retorno da funcao
	local cRet      := ""
	// array de arquivos
	local aSysFiles := directory("*.LOG")
	// ultimo arquivo
	local cUltArq   := ""
	// controle de loop
	local nI        := 0
	// arquivo memo
	local cMemErr   := ""
	
	
	// loop sobre os arquivos
	cUltArq := ""
	for nI := 1 to len(aSysFiles)
		
		// verifica se é arquivo
		if ( valType(aSysFiles[nI][1]) == "C" )
			// atribui o ultimo arquivo
			if ( substr(allTrim(aSysFiles[nI][1]), 1, 2) == "SC" )
				cUltArq := allTrim(aSysFiles[nI][1])
			endIf
		endIf
		
	next nI
	
	
	// le o arquivo
	cMemErr := memoRead(cUltArq)
	nMemLin := MLCount( cMemErr, 40, 3, .T. )
	for nI := 1 to nMemLin
		cRet += MemoLine(cMemErr, 40, nI, 3, .T. )
	next nI
	
return cRet 

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   

Static Function QSB2O()  

Local aArea	:= GetArea()
Local cQuery  := ""  

cQuery := "			SELECT	SB2.B2_FILIAL
cQuery += "		,SB2.B2_COD
cQuery += "		,SB2.B2_LOCAL
cQuery += "		,SB2.B2_VATU1,*

cQuery += "		 FROM "+RetSqlName("SB2")+" SB2 "

cQuery += "		WHERE	SB2.D_E_L_E_T_ = '' 
cQuery += "		AND SB2.B2_VATU1  <> 0
cQuery += "		AND SB2.B2_FILIAL IN   ( '06')
cQuery += "   AND SB2.B2_QATU = 0

//Define o alias da query
TcQuery cQuery New Alias "QSB2O"

RestArea(aArea)

Return Nil  

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   
//320
Static Function QSB2CM(cPr)  

Local aArea	:= GetArea()
Local cQuery  := ""  

cQuery := "			SELECT	SB2.B2_FILIAL
cQuery += "		,SB2.B2_COD
cQuery += "		,SB2.B2_LOCAL
cQuery += "		,SB2.B2_VATU1,*

cQuery += "   FROM "+RetSqlName("SB2")+" SB2 "

cQuery += "		WHERE	SB2.D_E_L_E_T_ = '' 
cQuery += "		AND SB2.B2_VATU1  <> 0
cQuery += "		AND SB2.B2_FILIAL IN   ('06')
cQuery += "   AND SB2.B2_QATU = 0

//Define o alias da query
TcQuery cQuery New Alias "QSB2CM"

RestArea(aArea)

Return Nil

/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 30/10/2015 | Marcos Sulivan									|   **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/   

Static Function QSB2IC()  

Local aArea	:= GetArea()
Local cQuery  := ""  

cQuery := "			SELECT	SB2.B2_FILIAL
cQuery += "		,SB2.B2_COD
cQuery += "		,SB2.B2_LOCAL
cQuery += "		,SB2.B2_VATU1,*

cQuery += "	  FROM "+RetSqlName("SB2")+" SB2 "

cQuery += "		WHERE	SB2.D_E_L_E_T_ = '' 
cQuery += "		AND SB2.B2_VATU1  =  0 
cQuery += "		AND SB2.B2_FILIAL = '07'
cQuery += "		AND SB2.B2_LOCAL IN  ( '01')
cQuery += "   AND SB2.B2_QATU <> 0

//Define o alias da query
TcQuery cQuery New Alias "QSB2IC"

RestArea(aArea)

Return Nil