/**********************************************************************************************************************************/
/** Estoque & Custos                                                                                                             **/
/** Filtro para contabilizar somente transferencias entre produtos. LP 670/672                                                   **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 16/02/2018 | Luiz Henrique Jacinto          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KCTB03()                                                                                                       **/
/** Chamada da rotina de para validar se foi uma transferencia entre produtos                                                    **/
/**********************************************************************************************************************************/
User Function KCTB03(cNumSeq)
	// gera valor?
	Local 	lRet 	:= .F.
	// area temporaria
	Local 	cTemp	:= "TCTB"
	// query
	Local 	cQuery	:= ""
	// processo ativado
	Local 	lAtivado:= GetMv("KA_CTBTRAN",,.F.)
	// area aberta
	Local 	aArea	:= GetArea()
	
	// se nao esta ativado
	If !lAtivado
		// retorna para gerar valor
		Return .T.
	Endif
	
	// valor inicial
	Default cNumSeq	:= SD3->D3_NUMSEQ
	
	// monta a query
	cQuery += "SELECT "+ENTER
	cQuery += "	ISNULL( COUNT(*),0) NPRODUTOS "+ENTER
	cQuery += "FROM ( "+ENTER
	cQuery += "			SELECT DISTINCT "+ENTER
	cQuery += "				D3_NUMSEQ "+ENTER
	cQuery += "				,D3_COD "+ENTER
	cQuery += "			FROM "+RetSqlName("SD3")+"  "+ENTER
	cQuery += " "+ENTER
	cQuery += "			WHERE  "+ENTER
	cQuery += "						D_E_L_E_T_<>'*' "+ENTER
	cQuery += "				AND D3_FILIAL='"+xFilial("SD3")+"' "+ENTER
	cQuery += "				AND D3_NUMSEQ='"+cNumSeq+"' "+ENTER
	cQuery += "				AND D3_TM IN ('499','999') "+ENTER
	cQuery += "				AND D3_CF IN ('RE4','DE4') "+ENTER
	cQuery += "				AND D3_ESTORNO<>'S' "+ENTER
	cQuery += "		) TAB "+ENTER
	 
	// se area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DbCloseArea() )
	Endif
	
	// executa a query
	TcQuery cQuery New Alias (cTemp)
	
	// se retornou algo
	If !(cTemp)->( EOF() )
		// atualiza o retorno
		lRet := (cTemp)->NPRODUTOS > 1
	Endif
	
	// se area aberta
	If Select(cTemp) > 0
		// fecha a area
		(cTemp)->( DbCloseArea() )
	Endif
	
	// restaura a area
	RestArea(aArea)
	
	// retorno
Return lRet


//U_KCTB03('9BBP15')