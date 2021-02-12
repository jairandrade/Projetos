#include 'protheus.ch'
#include 'parmtype.ch'
//Este ponto de entrada foi disponibilizado a fim de permitir alteração no filtro do usuário administrador na rotina SPEDNFE.
user function FISFILNFE()
local cCondicao 	:= ""
Local aParamBox 	:= {}
local lFiltra 		:= .T.
Local cTipo 		:= SubStr(MV_PAR01,1,1) == "1"	
Private aRet	 	:= {}

public _lFiltraNF := .T.
cTipo 		:= SubStr(MV_PAR01,1,1) == "1"	

If SubStr(MV_PAR01,1,1) == "1"	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³Realiza a Filtragem na 1-Saida                                          ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"	
	If !Empty(MV_PAR03)		
		cCondicao += ".AND.F2_SERIE=='"+MV_PAR03+"'"	
	EndIf	
	If SubStr(MV_PAR02,1,1) == "1" //"1-NF Autorizada"		
		cCondicao += ".AND. F2_FIMP$'S' "	
	ElseIf SubStr(MV_PAR02,1,1) == "3" //"3-Não Autorizadas"		
		cCondicao += ".AND. F2_FIMP$'N' "	
	Elseif SubStr(MV_PAR02,1,1) == "4" //"4-Transmitidas"		
		cCondicao += ".AND. F2_FIMP$'T' "	
	Elseif SubStr(MV_PAR02,1,1) == "5" //"5-Não Transmitidas"		
		cCondicao += ".AND. F2_FIMP$' ' "					
	EndIf

	// valida se o campo existe
	IF SF2->( FieldPos("F2_K_USRCO") ) > 0 
		// Tipo 2 -> Combo
		// [2]-Descricao
		// [3]-Numerico contendo a opcao inicial do combo
		// [4]-Array contendo as opcoes do Combo
		// [5]-Tamanho do Combo
		// [6]-Validacao
		// [7]-Flag .T./.F. Parametro Obrigatorio ?
		AAdd(aParamBox, { 2, "Filtra somente suas notas","1-Sim",{"1-Sim","2-Não"},120,".T.",.T.,".T."})

		/*
		// 1 - < aParametros > - Vetor com as configurações
		// 2 - < cTitle >      - Título da janela
		// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
		// 4 - < bOk >         - Code block para validar o botão Ok
		// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
		// 6 - < lCentered >   - Centralizar a janela
		// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
		// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
		// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
		//10 - < cLoad >       - Nome do perfil se caso for carregar
		//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
		//12 - < lUserSave >   - Configuração por usuário
		*/
		If ParamBox(aParamBox,"Notas por usuário",@aRet,/*bOk*/,/*abuttons*/,.T./*lcenter*/,/*nposx*/,/*nposy*/,/*odlgwiz*/,/*cload*/,.F./*lcansave*/,.F./*lusersave*/)
			If SubStr(aRet[1],1,1) == "2"
				lFiltra := .F.
				_lFiltraNF := .F.
			EndIf
		Endif

		if  lFiltra
			cCondicao += ".and. F2_K_USRCO = '"+RetCodUsr()+"'"
		EndIf
	EndIf		
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
	//³Realiza a Filtragem na 2-Entrada                                        ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cCondicao := "F1_FILIAL=='"+xFilial("SF1")+"' .AND. "	
	cCondicao += "F1_FORMUL=='S'"	
	If !Empty(MV_PAR03)		
		cCondicao += ".AND.F1_SERIE=='"+MV_PAR03+"'"	
	EndIf	
	If SubStr(MV_PAR02,1,1) == "1" .And. SF1->(FieldPos("F1_FIMP"))>0 //"1-NF Autorizada"		
		cCondicao += ".AND. F1_FIMP$'S' "	
	Elseif SubStr(MV_PAR02,1,1) == "3" .And. SF1->(FieldPos("F1_FIMP"))>0 //"3-Não Autorizadas"		
		cCondicao += ".AND. F1_FIMP$'N' "	
	Elseif SubStr(MV_PAR02,1,1) == "4" .And. SF1->(FieldPos("F1_FIMP"))>0 //"4-Transmitidas"		
		cCondicao += ".AND. F1_FIMP$'T' "	
	Elseif SubStr(MV_PAR02,1,1) == "5" .And. SF1->(FieldPos("F1_FIMP"))>0 //"5-Não Transmitidas"		
		cCondicao += ".AND. F1_FIMP$' ' "					
	EndIf
Endif

return cCondicao