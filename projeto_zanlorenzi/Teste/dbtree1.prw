#include "TOTVS.CH"
User Function DbTtree1()
	DEFINE DIALOG oDlg TITLE "Exemplo de DBTree" FROM 180,180 TO 550,700 PIXEL
// Cria a Tree    
oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)		    
// Insere itens    
	oTree:AddItem("Primeiro nível da DBTree","001", "FOLDER5" ,,,,1)
	If oTree:TreeSeek("001")
		oTree:AddItem("Segundo nível da DBTree","002", "FOLDER10",,,,2)
		If oTree:TreeSeek("002")
			oTree:AddItem("Subnível 01","003", "FOLDER6",,,,2)
			oTree:AddItem("Subnível 02","004", "FOLDER6",,,,2)
			oTree:AddItem("Subnível 03","005", "FOLDER6",,,,2)
		endif
	endif
	oTree:TreeSeek("001")
	// Retorna ao primeiro nível
	// Cria botões com métodos básicos
	TButton():New( 160, 002, "Seek Item 4", oDlg,{|| oTree:TreeSeek("004")},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 160, 052, "Enable"	, oDlg,{|| oTree:SetEnable() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 160, 102, "Disable"	, oDlg,{|| oTree:SetDisable() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 160, 152, "Novo Item", oDlg,{|| TreeNewIt() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 172,02,"Dados do item", oDlg,{|| Alert("Cargo: "+oTree:GetCargo()+chr(13)+"Texto: "+oTree:GetPrompt(.T.)) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 172, 052, "Muda Texto", oDlg,{||	oTree:ChangePrompt("Novo Texto Item 001","001") },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 172, 102, "Muda Imagem", oDlg,{||oTree:ChangeBmp("LBNO","LBTIK",,,"001") },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 172, 152, "Apaga Item", oDlg,{||	if(oTree:TreeSeek("006"),oTree:DelItem(),) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	// Indica o término da contrução da Tree
	oTree:EndTree()
	ACTIVATE DIALOG oDlg CENTERED
Return
	//----------------------------------------
	// Função auxiliar para inserção de item
	//----------------------------------------
Static Function TreeNewIt()
	// Cria novo item na Tree
	oTree:AddTreeItem("Novo Item","FOLDER7",,"006")
	if oTree:TreeSeek("006")
		oTree:AddItem("Sub-nivel 01","007", "FOLDER6",,,,2)
		oTree:AddItem("Sub-nivel 02","008", "FOLDER6",,,,2)
	endif

// Localiza o Cargo 001 e posiciona o cursor// para que o segundo nível seja criado abaixo dele// -----------------------------------------------------if oTree:TreeSeek("001")   oTree:AddItem("Segundo nível da DBTree","002", "FOLDER10",,,,2)	endif

Return
