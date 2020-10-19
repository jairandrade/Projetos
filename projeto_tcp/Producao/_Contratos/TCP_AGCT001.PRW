//-----------------------------------------
//Cadastro de grupos de responsaveis do GCT
//-----------------------------------------
#include "rwmake.ch"

User Function AGCT001()

	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias := "ZZC"
	
	//--< procedimentos >-----------------------------------------------------------------------

	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, "Grupos de contratos", cVldExc, cVldAlt)
	

Return

//-----------------------------------------
//Cadastro de responsaveis do GCT
//-----------------------------------------
#include "rwmake.ch"

User Function AGCT002()

	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias := "ZZD"
	
	//--< procedimentos >-----------------------------------------------------------------------

	chkFile(cAlias)
	dbSelectArea(cAlias)
	//indices
	dbSetOrder(1)
	axCadastro(cAlias, "Grupos de contratos", cVldExc, cVldAlt)
	

Return