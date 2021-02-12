#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

#Define ENTER chr(13)+chr(10)

/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Exclusao da nota fiscal de saida                                                                                      		 **/
/** Ponto de entrada M521CART                																					 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Deve estornar o pedido de venda apos a exclusao da nota fiscal de saida?                                                     **/
/**********************************************************************************************************************************/
User Function M521CART()
Local lRet 		:= .T.
Local lAtivado 	:= .T. //Volta para carteira da kapazi - Luis - 10/09/2019  devido aos processos de PV`s sempre volta para carteira

Pergunte("MTA521",.F.) //Volta os mv_pars do usuario

If !IsInCallStack("U_DLNFSEKP") .And. (TYPE("__NfMista") == "L")
	
	If !__NfMista //Senao é NF Mista
	
		// recebe o filtro da query
		lRet 		:= mv_par04 == 1
		// se processo ativado 
		lAtivado	:= TGetMv("  ","KA_FLGPVCA","L",.F.,"M521CART - Deixar o pedido fluig liberado apos exclusao da nota fiscal de saida.")
		
		// se processo ativado e area aberta
		If lAtivado .and. Select("MA521MARKB") > 0 .and. SD2->( D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ) == MA521MARKB->( F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA )  
			// se a nota de pedido fluig retorna .F. para manter o pedido liberado
			//lRet := !fromFluig(MA521MARKB->F2_DOC,MA521MARKB->F2_SERIE,MA521MARKB->F2_CLIENTE,MA521MARKB->F2_LOJA)
			lRet := !StaticCall(KFATA13,fromFluig,SD2->D2_PEDIDO)
		Endif
	
	EndIf
EndIf	

// retorna
Return(lRet)

static Function criaSX6(_cFil,_cPar,_cTipo,xValor,cDescr)
Local aArea 	:= GetArea()
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""

cDesc1	:= Substr(cDescr,001,50)
If Len(cDescr) > 50
	cDesc2	:= Substr(cDescr,051,50)
Endif

If Len(cDescr) > 100 
	cDesc3	:= Substr(cDescr,101,50)
Endif

SX6->( DbSetOrder(1) )
If !SX6->( MsSeek(_cFil+_cPar,.T.))
	RecLock("SX6",.T.)
	SX6->X6_FIL 	:= _cFil
	SX6->X6_VAR		:= _cPar
	SX6->X6_TIPO	:= _cTipo
	SX6->X6_CONTEUD	:= cValToChar(xValor)
	SX6->X6_CONTSPA	:= cValToChar(xValor)
	SX6->X6_CONTENG	:= cValToChar(xValor)
	SX6->X6_PROPRI	:= "U"
	SX6->X6_PYME	:= ""
	SX6->X6_DESCRIC	:= cDesc1
	SX6->X6_DESC1	:= cDesc2
	SX6->X6_DESC2	:= cDesc3
	SX6->X6_DSCSPA	:= cDesc1
	SX6->X6_DSCSPA1	:= cDesc2
	SX6->X6_DSCSPA2	:= cDesc3
	SX6->X6_DSCENG	:= cDesc1
	SX6->X6_DSCENG1	:= cDesc2
	SX6->X6_DSCENG2	:= cDesc3
	MsUnLock("SX6")
Endif

RestArea(aArea)
Return


Static Function TGetMv(_cFil,_cPar,_cTipo,xValor,cDescr)

criaSX6(_cFil,_cPar,_cTipo,xValor,cDescr)

Return GetMv(_cPar,,xValor)
