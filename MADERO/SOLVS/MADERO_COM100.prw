#Include 'Protheus.ch'

/*-----------------+---------------------------------------------------------+
!Nome              ! AFAT100 - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Cadastro de Calendario de Entregas de Fornecedor        !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/

User Function COM100()
Private cTab    :="Z22"
Private aRotAdic:={}                            
Private aButtons:={}
Private bOK     :={|| U_FAT100OK()}
Private bPre        
Private bTTS
Private bNoTTS             
Private cCadTit :="Calendario de Entregas"
	AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! Z22VlDia - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Validacao dos dias de entrega conforme o tipo de entrega!
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
User function Z22VlDia()
	Local lRet := .t.
	Local aDias
	Local nLaco
	if M->Z22_TIPO = 'S' // Entrega semanal - ate 7 dias considerando os dias padrao da semana separados por virgula
		aDias := separa(alltrim(M->Z22_DIA), ",")
		if len(aDias) > 7
			lRet := .f.
			alert("Entrega semanal limitado aos dias de 1 a 7, com separação com vírgulas.")
		Else
			for nLaco := 1 to len(aDias)
				if alltrim(aDias[nLaco]) < "1" .or. alltrim(aDias[nLaco]) > "7" .or. len(alltrim(aDias[nLaco])) > 1 .or. !empty(ascanx(aDias, {|x,y|x = aDias[nLaco] .and. y<>nLaco}))
					lRet := .f.
					alert("Entrega semanal limitado aos dias de 1 a 7, com separação com vírgulas.")
					exit
				Endif
			next
		Endif
	elseif M->Z22_TIPO = 'Q' // Entrega quinzenal - será considerado como Default 14 dias - validar
		if !(alltrim(M->Z22_DIA) == "14")
			lRet := .f.
			alert("Entrega quinzenal limitado ao dia 14 do mês")
		EndIf
	else  // Entrega mensal -  Dia do mês que a entrega entre 1 e 30
		if (val(alltrim(M->Z22_DIA)) < 1 .or. val(alltrim(M->Z22_DIA)) > 30) .or. !(cValToChar(val(alltrim(M->Z22_DIA))) == alltrim(M->Z22_DIA)) 
			lRet := .f.
			alert("Entrega mensal limitado aos dias 1 a 30 do mês")
		EndIf
		
	EndIf
return lRet




/*-----------------+---------------------------------------------------------+
!Nome              ! FAT100OK                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Validação ao gravar os dados                            !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function FAT100OK()
Local lRetok:=.T.

	// -> Verifica ja existe dados cadastrados e, caso exista retorna erro
	If Inclui
		Z22->(DbSetOrder(1))
		If Z22->(DbSeek(xFilial("Z22")+M->Z22_CODUN+M->Z22_FORN+M->Z22_LOJA+M->Z22_GRUPO))
			alert("Já existe calendário de ntrega para a unidade, fornecedor e grupo de compras.")
			lRetok:=.F.
		EndIf
	
		// -> Valida preenchimento da unidade de negócio 
		If Empty(M->Z22_DESCUN)
			alert("Favor informar a unidade de negócio.")
			lRetok:=.F.	
		EndIf
	
		// -> Valida preenchimento do fornecedor
		If Empty(M->Z22_NOME)
			alert("Favor informar os dados do fornecedor.")
			lRetok:=.F.	
		EndIf

		// -> Valida preenchimento do grupo
		If Empty(M->Z22_GRUPO)
			alert("Favor informar o grupo de compras.")
			lRetok:=.F.	
		EndIf
	
		// -> Valida preenchimento do tipo do calendário
		If Empty(M->Z22_TIPO)
			alert("Favor informar o tipo do calendário.")
			lRetok:=.F.	
		EndIf
	
	EndIf
		

Return(lRetOk)