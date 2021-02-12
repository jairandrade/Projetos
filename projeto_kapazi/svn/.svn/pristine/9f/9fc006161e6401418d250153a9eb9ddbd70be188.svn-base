/*
Ponto de entrada na copia do pedido de venda
Executado depois de preencher os dados do cabecalho (enchoice) e dos itens (acols) antes de exibir em tela.
*/
#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH" 
#include "topconn.ch"

#Define ENTER chr(13)+chr(10)

User Function MT410CPY()
	Local aArea		:= GetArea()
	// zera os campos do cabecalho do pedido de venda?
	Local lZera		:= StaticCall(M521CART,TGetMv,"  ","KA_PVZERAC","L",.T.,"MT410CPY - Zerar campos em tela do pedido de venda ao iniciar uma cópia?" )
	
	// se zera
	If lZera
		// chama a funcao para limpar
		LimparCP()
	Endif
	
	RestArea(aArea)
Return

/*
Funcao que limpa os campos do pedido ao copiar
*/
Static Function LimparCp()
	// campos a serem limpos
	Local aCpoZera	:= {"C5_CLIENTE","C5_LOJACLI","C5_K_OPER"}
	Local cCampo	:= ""
	Local cCampos	:= ""
	Local nX		:= 0
	Local cMsg		:= ""
	
	// faz loop nos campos
	For nX := 1 to Len(aCpoZera)
		// cacmpo
		cCampo := aCpoZera[nX]
		
		// se preenchido
		If !Empty(AllTrim(cCampos))
			// adiciona separador
			cCampos += ", "
		Endif
		
		// titulo do campo
		cCampos += AllTrim(RetTitle(cCampo))
		
		// atualiza o valor
		&("M->"+cCampo):= CriaVar(cCampo)
		
	Next
	
	// se possui tela
	If !isBlind()
		// monta tela
		cMsg := "Foi realizada a limpeza do valor dos campos "+cCampos+"."+ENTER
		cMsg += "Verifique o preenchimento dos mesmos."
		// exibe msg
		MsgInfo(cMsg)
	Endif
	
Return


