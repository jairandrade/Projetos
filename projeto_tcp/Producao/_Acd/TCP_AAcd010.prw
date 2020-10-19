#include 'protheus.ch'
#include "fwmvcdef.ch" 	       
#include "topconn.ch" 	       


/*/{Protheus.doc} AAcd010
Rotina para manutenção do cadastro de Alçada de aprovadores

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@see (links_or_references)
/*/
User Function AAcd010()

	Private aRotina := MenuDef()
	Private cCadastro := "Cadastro de Alçada de Aprovadores"

	//Instacia a classe
	oBrw := FWMBrowse():New()

	//tabela que será utilizada
	oBrw:SetAlias( "ZD1" )

	//Titulo
	oBrw:SetDescription( cCadastro )

	//legendas
	oBrw:AddLegend( "ZD1_ATIVO != 'N'", "BR_VERDE"   ,'Aprovador Ativo.')
	oBrw:AddLegend( "ZD1_ATIVO == 'N'", "BR_VERMELHO",'Aprovador Desativado.')

	//ativa
	oBrw:Activate()

Return


/*/{Protheus.doc} MenuDef
Monta opções do menu da rotina

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@return aRot, array, opções da rotina
/*/
Static Function MenuDef()

	Local aRot := {}

	Add Option aRot Title 'Pesquisar'  Action 'AxPesqui'        Operation 1 Access 0
	Add Option aRot Title 'Visualizar' Action 'AxVisual'        Operation 2 Access 0
	Add Option aRot Title 'Incluir'    Action "AxInclui('ZD1')" Operation 3 Access 0
	Add Option aRot Title "Alterar"    Action 'AxAltera'        Operation 4 Access 0
	Add Option aRot Title 'Excluir'    Action 'u_AAcd010D'      Operation 5 Access 0

Return aRot


/*/{Protheus.doc} AAcd010D
(long_description)
@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cAlias, character, Alias da rotina
@param nReg, numérico, Registro posicionado
@param nOpc, numérico, Opção do menu
/*/
User Function AAcd010D( cAlias, nReg, nOpc )

	Local lUsaFil := !Empty( xFilial( cAlias ) )
	Local lExist  := .F.

	//valida nos residuos
	//lExist := If( !lExist, u_lExistIN( "Z00", {"Z00_TIPO"}, {Z02->Z02_TIPO}, lUsaFil ), lExist )

	//se existir
	IF lExist
		//avisa usuario
		Aviso( "Registro usado", "Este registro não pode ser excluído, pois possui vinculo com outro(s) cadastro(s).", {"Ok"}, 2 )
		//se nao existir vinculo
	Else
		//abre tela pra deletar
		AxDeleta( cAlias, nReg, nOpc )
	EndIF

Return



/*/{Protheus.doc} AAcd010Gera
Rotina para gerar Alçadas de aprovação a partir da Ordem de Separação

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
/*/
User Function AAcd010Gera()

	Local aNiveis := GetNiveis()
	Local nValorOrdem := GetValorOrdem()
	
	Local cNivelAprov := ""

	Local lGerou := .F.

	Local n1    
	
	Private aTxtManusis := {}
	private _cOrdSep := CB7->CB7_ORDSEP
	
	If nValorORdem <= GetMv('TCP_VALIBO') //.OR. ALLTRIM(Posicione('SC2',1,CB7->CB7_FILIAL+Alltrim(CB7->CB7_OP),"C2_PRODUTO")) == 'EPI'
//		MsgInfo('Ordem de separação liberada!')
		
		RecLock("ZD2",.T.)
		ZD2->ZD2_FILIAL := xFilial("ZD2")
		ZD2->ZD2_ORDSEP := CB7->CB7_ORDSEP
		ZD2->ZD2_APROV  := RetCodUsr()
		ZD2->ZD2_NIVEL  := '1'
		ZD2->ZD2_STATUS := "L"
		ZD2->ZD2_DHEMIS := FormDate(Date()) + " " + Time()
		ZD2->ZD2_DHLIB  := FormDate(Date()) + " " + Time()		
		ZD2->ZD2_HASH   := SHA1(ZD2->(ZD2_FILIAL+ZD2_ORDSEP+ZD2_APROV+ZD2_NIVEL+ZD2_STATUS+ZD2_DHEMIS))
		ZD2->( MsUnLock())

		//marca o ordem como bloqueada
		RecLock("CB7",.F.)
		CB7->CB7_LIBOK  := "L"
		CB7->CB7_LIBVAL := nValorOrdem
		CB7->( MsUnLock() )
		
		aAdd(aTxtManusis,{'Materiais liberados para retirada no almoxarifado.','2'})
		ENVIAMANUSIS()
		
		Return	
	EndIf

	//se tiver niveis de aprovação
	IF len(aNiveis) != 0

		//percore todos os niveis
		For n1 := 1 to len(aNiveis)
			//quando encontrar o nivel que tenha valor de limite maior que da ordem
			IF aNiveis[n1][3] >= nValorOrdem
				//pega o nivel
				cNivelAprov := aNiveis[n1][1]
				//e sai fora
				Exit
			EndIF
		Next n1

		//se o valor for maior que o limite de todos os niveis
		//pega o ultimo nivel
		IF Empty(cNivelAprov)
			cNivelAprov := aNiveis[len(aNiveis)][1]
		EndIF

		Begin Transaction

			//percore todos os niveis novamente
			For n1 := 1 to len(aNiveis)
				//porem se o nivel por maior que o nivel de aprovação selecionado
				IF aNiveis[n1][1] <= cNivelAprov

					//grava as alçadas
					RecLock("ZD2",.T.)
					ZD2->ZD2_FILIAL := xFilial("ZD2")
					ZD2->ZD2_ORDSEP := CB7->CB7_ORDSEP
					ZD2->ZD2_APROV  := aNiveis[n1][2]
					ZD2->ZD2_NIVEL  := aNiveis[n1][1]
					ZD2->ZD2_STATUS := "B"
					ZD2->ZD2_DHEMIS := FormDate(Date()) + " " + Time()
					ZD2->ZD2_HASH   := SHA1(ZD2->(ZD2_FILIAL+ZD2_ORDSEP+ZD2_APROV+ZD2_NIVEL+ZD2_STATUS+ZD2_DHEMIS))
					ZD2->( MsUnLock())

					lGerou := .T.

				EndIF

			Next n1

			IF lGerou
				//marca o ordem como bloqueada
				RecLock("CB7",.F.)
				CB7->CB7_LIBOK  := "B"
				CB7->CB7_LIBVAL := nValorOrdem
				CB7->( MsUnLock() )

				//manda e-mail pro primeiro nivel
				SendWorkFlow(CB7->CB7_ORDSEP, aNiveis[1][1])
			EndIF

		End Transaction

	EndIF
	
	IF(LEN(aTxtManusis) > 0)
		ENVIAMANUSIS()
	ENDIF
	
Return




/*/{Protheus.doc} GetNiveis
Busca os Niveis de aprovações ativos

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@return aNiveis, array, Niveis de aprovação ativos
/*/
Static Function GetNiveis()
	
	Local aNiveis := {}
	//Local cCCAux	:= Posicione('STJ',1,xFilial('STJ')+SubStr(CB7->CB7_OP,1,Len(STJ->TJ_ORDEM)),"TJ_XCC")
	
	//Caiu essa regra, pois agora as OPs veem do manusis, já com o CC certo
	//If Alltrim(SubStr(CB7->CB7_OP,Len(STJ->TJ_ORDEM)+1,5)) == '01001'
	private cCCAux := Posicione('SC2',1,xFilial('SC2')+Alltrim(CB7->CB7_OP),"C2_CC")
	//EndIf
//	private 0   :=cCCAux //centro de custo, para validar regra de aprovacao TI.
	
	ZD1->( dbSetOrder(1) )
	ZD1->( dbGoTop() )              	
	
                                                                                                                                              
	While !ZD1->( Eof() )

		IF ZD1->ZD1_ATIVO != "N" 	
		    
			If !Empty(cCCAux) .AND. ZD1->ZD1_CC == cCCAux
        	
				aAdd( aNiveis, {;
					ZD1->ZD1_NIVEL, ;
					ZD1->ZD1_APROV, ;
					ZD1->ZD1_LIMITE })
			EndIf

		EndIF

		ZD1->( dbSkip() )
	EndDO        

	ZD1->( dbSetOrder(1) )
	ZD1->( dbGoTop() )

	If Len(aNiveis) == 0 

		While !ZD1->( Eof() )
	
			IF ZD1->ZD1_ATIVO != "N" .AND. Empty(Alltrim(ZD1->ZD1_CC))
	        	
				aAdd( aNiveis, {;
					ZD1->ZD1_NIVEL, ;
					ZD1->ZD1_APROV, ;
					ZD1->ZD1_LIMITE })	
			EndIF
	
			ZD1->( dbSkip() )
		EndDO        	
	
	EndIf

Return aNiveis



/*/{Protheus.doc} GetValorOrdem
Calculo o custo da ordem de separação

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@return nValor, numerico, Custo da Ordem de separação
/*/
Static Function GetValorOrdem()

	Local nValor := 0

	CB8->( dbSetOrder(1) )
	CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

	While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)

		//soma o valor de todos os itens
		nValor += CB8->(CB8_QTDORI * CB8_CUSTOL)

		CB8->( dbSkip() )
	EndDO

Return nValor


/*/{Protheus.doc} AAcd010Estorna
Rotina para estornar as alçadas, executado na exclusão da ordem de separação

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
/*/
User Function AAcd010Estorna()

	ZD2->( dbSetOrder(1) )
	ZD2->( dbSeek( xFilial("ZD2") + CB7->CB7_ORDSEP ) )

	Begin Transaction

		While !ZD2->( Eof() ) .And. ZD2->(CB7_FILIAL+CB7_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)

//			RecLock("ZD2",.F.) retirado devido a problemas operacionais com os usuários
//			ZD2->( dbDelete() )
//			ZD2->( MsUnLock())

			ZD2->( dbSkip() )
		EndDO

	End Transaction

Return



/*/{Protheus.doc} AAcd010Libera
Função para liberação no nivel da alçada e aviso ao proximo nivel ou liberação da ordem

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cHash, character, Codigo Hash para buscar o nivel da aprovação
@return array, Liberou ou não e qual o problema
/*/
User Function AAcd010Libera(cHash)

	Local lContinua := .F.

	Local aLiberacoes := {}
	Local cMensagem := ""
	Local nInd
	Local nOk
	Local cNivelCont := "1"
	Private aTxtManusis := {}
	Private _cOrdSep := ''
	ZD2->( dbSetOrder(2) )
	ZD2->( dbSeek( cHash ) )

	//se achar
	IF ZD2->( Found() )
		_cOrdSep := ZD2->ZD2_ORDSEP
		dbSelectArea('CB7')
		CB7->( dbSetOrder(1) )

		IF CB7->( dbSeek( xFilial("CB7") + _cOrdSep ) )
			//Se já estiver aprovada não deixa fazer denovo
			if(CB7->CB7_LIBOK == "L")
				lContinua := .F.
				cMensagem := "Liberação não permitida, pois o Nivel " +ZD2->ZD2_NIVEL + " já foi liberado."
			else
				//se estiver bloqueado
				IF ZD2->ZD2_STATUS == "B"
					lContinua := .T.
					//busca as liberações
					aLiberacoes := GetLiberacoes(ZD2->ZD2_ORDSEP)
		
					//loop para validar os niveis
					While cNivelCont <= ZD2->ZD2_NIVEL .And. lContinua
						//procura por item bloqueado no nivel
						//já tratou o nivel 1 no GerLiberacoes
						nOk := aScan(aLiberacoes, {|x| x[1] == cNivelCont .And. x[3] == "B"  })
		
						//se for o mesmo nivel
						IF cNivelCont == ZD2->ZD2_NIVEL
							IF nOk == 0
								lContinua := .F.
								cMensagem := "Liberação não permitida, pois o Nivel " +cNivelCont + " já foi liberado."
							EndIF
						Else
							//se não for o mesmo nivel do que estamos liberando (nivel abaixo)
							//e significa que precisa liberar os niveis anteriores
							IF nOk != 0 .AND. ZD2->ZD2_NIVEL != '3'
								lContinua := .F.
								cMensagem := "Liberação não permitida, pois o Nivel " +cNivelCont + " está bloqueado."
							EndIF
						EndIF
		
						//proximo nivel
						cNivelCont := Soma1(cNivelCont)
					EndDO
		
					//libera
					IF lContinua
		
						//grava a liberação
						RecLock("ZD2",.F.)
						ZD2->ZD2_STATUS := "L"
						ZD2->ZD2_DHLIB  := FormDate(Date()) + " " + Time()
						ZD2->( MsUnLock())
						
						aAdd(aTxtManusis,{'Liberado por '+RetNomFunc(ZD2->ZD2_APROV)+' Nivel '+ZD2->ZD2_NIVEL,''})
					
						//e verifica se manda e-mail pro proximo nivel
						//se for Nivel 1, OU, se os outros aprovadores do nivel já liberação (x[1] mesmo nivel, x[2] bloqueado, x[4] hash diferente do que estamos liberado)
		//				IF ZD2->ZD2_NIVEL == "1" .Or. aScan(aLiberacoes,{|x| x[1] == ZD2->ZD2_NIVEL .And. x[3] == "B" .And. x[4] != ZD2->ZD2_HASH }) == 0
						IF ZD2->ZD2_NIVEL == "1" .Or. ZD2->ZD2_NIVEL == "2" .Or. ZD2->ZD2_NIVEL == "3" .Or. aScan(aLiberacoes,{|x| x[1] == ZD2->ZD2_NIVEL .And. x[3] == "L"  }) > 0
							cMensagem := ProximoNivelOuLibera(aLiberacoes, ZD2->ZD2_NIVEL)
						Else
							cAprovs := ''
							_cNivel := ''
							For nInd := 1 to len(aLiberacoes)
								if(aLiberacoes[nInd][1] == ZD2->ZD2_NIVEL  .AND. aLiberacoes[nInd][3] )
									cAprovs += IF(!EMPTY(cAprovs),', ','')+RetNomFunc(aLiberacoes[nInd][2])
								ENDIF
							next
							
							IF !EMPTY(cAprovs)
								aAdd(aTxtManusis,{'Aguardando aprovação de '+cAprovs+' Nivel '+ZD2->ZD2_NIVEL,''})
							ENDIF
							
							cMensagem := "Ordem de separação "+ZD2->ZD2_ORDSEP+" aguardando outros aprovadores do nivel."
						EndIF
					EndIF
				Else
					cMensagem := "Nivel já liberado para esta ordem de separação."
				EndIF
			endif
		ELSE
			cMensagem := "Ordem de Separação não encontrada."
		ENDIF
	Else
		cMensagem := "Alçada para ordem de separação não encontrada."
	EndIF

	
	IF(LEN(aTxtManusis) > 0)
		ENVIAMANUSIS()
	ENDIF
	
Return {lContinua, cMensagem}



/*/{Protheus.doc} GetLiberacoes
Busca status das alçadas

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cOrdemSeparacao, character, Numero da ordem de separação
@return aLiberacoes, array, Lista as alçadas, com status de liberação
/*/
Static Function GetLiberacoes(cOrdemSeparacao)

	Local aLiberacoes := {}
	Local nRegistroZD2 := ZD2->( Recno() )

	Local n1
	Local nOk

	ZD2->( dbSetOrder(1) )
	ZD2->( dbSeek( xFilial("ZD2") + cOrdemSeparacao ) )

	//pescore todos os niveis
	While !ZD2->( Eof() ) .And. ZD2->(ZD2_FILIAL+ZD2_ORDSEP) == xFilial("ZD2") + cOrdemSeparacao

		aAdd( aLiberacoes, {;
			ZD2->ZD2_NIVEL ,;
			ZD2->ZD2_APROV ,;
			ZD2->ZD2_STATUS ,;
			ZD2->ZD2_HASH ,;
			ZD2->ZD2_DHLIB })

		ZD2->( dbSkip() )
	EndDO

	//pesquisa no nivel 1, se tem alguma liberação
	nOk := aScan(aLiberacoes, {|x| x[1] == "1" .And. x[3] == "L"  })
	//se tiver
	IF nOk != 0
		For n1 := 1 to len(aLiberacoes)
			//marcado todos do nivel 1
			IF aLiberacoes[n1][1] == "1"
				//como liberado
				aLiberacoes[n1][3] := "L"
			EndIF
		Next
	EndIF

	ZD2->( dbGoTo( nRegistroZD2 ) )

Return aLiberacoes



/*/{Protheus.doc} ProximoNivelOuLibera
(long_description)
@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param aLiberacoes, array, Lista de status de liberação
@param cNivelAtual, character, Nivel liberado agora
/*/
Static Function ProximoNivelOuLibera(aLiberacoes, cNivelAtual)

	Local n1
	Local cProximoNivel := ""

	Local cReturn

	//passa todas as liberações procurando o proximo nivel
	For n1 := 1 to len(aLiberacoes)
		//se encontrar nivel maior
		IF aLiberacoes[n1][1] > cNivelAtual
			//pega o nivel
			cProximoNivel := aLiberacoes[n1][1]
			//e sai fora
			Exit
		EndIF
	Next

	//se o nivel estiver preechido
	IF !Empty(cProximoNivel)

		CB7->( dbSetOrder(1) )
		CB7->( dbSeek( xFilial("CB7") + ZD2->ZD2_ORDSEP ) )
		
		cQueryValid := " SELECT COUNT(*) AS TOTAL FROM "+RetSqlName('ZD2')+" "
		cQueryValid += " WHERE ZD2_FILIAL = '"+xFilial('ZD2')+"' and ZD2_ORDSEP = '"+ZD2->ZD2_ORDSEP+"' AND ZD2_NIVEL = '"+cNivelAtual+"' AND ZD2_STATUS = 'L' AND D_E_L_E_T_ != '*' " 

		IF SELECT("ZD2VAL")<>0
			ZD2VAL->(DBCLOSEAREA())
		EndIf
		 
		TcQuery cQueryValid new Alias "ZD2VAL"

		If ZD2VAL->TOTAL < 2                                   
			//manDa workflow para liberação
			SendWorkFlow(ZD2->ZD2_ORDSEP, cProximoNivel)
		EndIf        
   		ZD2VAL->(DBCLOSEAREA())
                           		
		cReturn := "Ordem de separação "+ZD2->ZD2_ORDSEP+" passou para nivel "+cProximoNivel+" de aprovação."
	Else
		//o estiver em branco, liberou todos os niveis
		//posiciona na ordem de separação
		CB7->( dbSetOrder(1) )
		CB7->( dbSeek( xFilial("CB7") + ZD2->ZD2_ORDSEP ) )

		IF CB7->( Found() )
			RecLock("CB7",.F.)
			CB7->CB7_LIBOK := "L"
			CB7->( MsUnLock())
		EndIF
		
		aAdd(aTxtManusis,{'Materiais liberados para retirada no almoxarifado.','2'})
		//aAdd(aTxtManusis,{'Reserva liberada totalmente','2'})
		
		cReturn := "Ordem de separação "+ZD2->ZD2_ORDSEP+" liberada totalmente."
	EndIF

Return cReturn



/*/{Protheus.doc} SendWorkFlow
Seleciona todos os aprovadores do nivel para enviar e-mail

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cOrdemSeparacao, character, Numero da ordem de separação
@param cNovoNivel, character, Nivel para enviar e-mail de aprovação
/*/
Static Function SendWorkFlow(cOrdemSeparacao, cNovoNivel)

	Local nRegistroZD2 := ZD2->( Recno() )
	Local cAprovs := ''
	Local _cNivel := ''
	ZD2->( dbSetOrder(1) )
	ZD2->( dbSeek( xFilial("ZD2") + cOrdemSeparacao + cNovoNivel ) )
	

	While !ZD2->( Eof() ) .And. ZD2->(ZD2_FILIAL+ZD2_ORDSEP+ZD2_NIVEL) == xFilial("ZD2") + cOrdemSeparacao + cNovoNivel
		
		cAprovs += IF(!EMPTY(cAprovs),', ','')+RetNomFunc(ZD2->ZD2_APROV)
		
		//função para montar e enviar o e-mail
		MontaEmail()
		_cNivel := ZD2->ZD2_NIVEL
		
		ZD2->( dbSkip() )
	EndDO

	ZD2->( dbGoTo( nRegistroZD2 ) )
	
	IF !EMPTY(cAprovs)
		aAdd(aTxtManusis,{'Aguardando aprovação de '+cAprovs+' Nivel '+_cNivel,IF(_cNivel =='1','6','')})
	ENDIF
	
	
	Return



/*/{Protheus.doc} MontaEmail
Função para montar os e-mail de aprovação

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
/*/
Static Function MontaEmail(lRej)

	Local oProc
	Local oHtml
	Local nValor := 0
    
	Local cEmail := UsrRetMail(ZD2->ZD2_APROV)

	Local aArea := GetArea("CB8")

	IF !Empty(cEmail)

		oProc := TWFProcess():New("MAILACD01","Aprovação Ordem Separação")
		if lRej                                                               
			oProc:NewTask("Ordem Separação", "\WORKFLOW\HTML\MAILACD02.HTML" )
			cEmail :=  "felipe@afsouza.com.br"//Posicione('STJ',1,xFilial('STJ')+SubStr(CB7->CB7_OP,1,Len(STJ->TJ_ORDEM)),"TJ_USUAINI")
			oProc:cSubject := "Rejeição Ordem Separação "+CB7->CB7_ORDSEP+" - Nível " + ZD2->ZD2_NIVEL		
		Else
			oProc:NewTask("Ordem Separação", "\WORKFLOW\HTML\MAILACD01.HTML" )
			oProc:cSubject := "Aprovação Ordem Separação "+CB7->CB7_ORDSEP+" - Nível " + ZD2->ZD2_NIVEL
		EndIF

		oHtml := oProc:oHtml

		IF valtype(oHtml) != "U"
			cCodBem := " "
			DbSelectArea('ZZF')
			ZZF->( dbSetOrder(2) )
			
			DbSelectArea('ZDW')
			ZDW->( dbSetOrder(2) )
			
			IF ZZF->( dbSeek( CB7->CB7_FILIAL+CB7->CB7_OP ) )
				cCodBem 	  := ALLTRIM(ZZF->ZZF_CODBEM)+' - '+ ALLTRIM(ZZF->ZZF_BEM   )
				cRequisitante := ''
			ElseIF ZDW->( dbSeek( CB7->CB7_FILIAL+CB7->CB7_OP ) )
				cCodBem 		:= " "   
				cRequisitante   := ZDW->ZDW_OBSERV
			else  
				cCodBem 		:= " "   
				cRequisitante   := Posicione('ZD4',5,xFilial('ZD4')+CB7->CB7_OP,"ZD4_NOME")
			EndIf   

			oHtml:ValByName("cOrdemSeparacao", CB7->CB7_ORDSEP)
			oHtml:ValByName("cRequisitante", cRequisitante)
			oHtml:ValByName("cOS",CB7->CB7_OP)       
			oHtml:ValByName("cOm",CB7->CB7_XOM)           
			oHtml:ValByName("cData",DtoS(dDataBase))        
			oHtml:ValByName("cBem",cCodBem)           


			CB8->( dbSetOrder(1) )
			CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

			While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)

				SB5->( dbSetOrder(1) )
				SB5->( dbSeek( xFilial("SB5") + CB8->CB8_PROD ) )

				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + CB8->CB8_PROD ) )
				
				If !Empty(Alltrim(SB5->B5_DCOMPR))
					cAuxDesc := SB5->B5_DCOMPR
				ElseIf !Empty(Alltrim(SB5->B5_CEME))
					cAuxDesc := SB5->B5_CEME
				Else
					cAuxDesc := SB1->B1_DESC
				EndIf

				aAdd((oHtml:ValByName("it.codigo")),CB8->CB8_PROD)
				aAdd((oHtml:ValByName("it.descricao")),cAuxDesc)
				aAdd((oHtml:ValByName("it.quantidade")),TransForm(CB8->CB8_QTDORI,'@E 999,999.99'))
				aAdd((oHtml:ValByName("it.valor")),TransForm(CB8->CB8_CUSTOL,'@E 999,999,999.99'))
				aAdd((oHtml:ValByName("it.total")),TransForm(CB8->(CB8_QTDORI * CB8_CUSTOL),'@E 999,999,999.99'))

				//soma o valor de todos os itens
				nValor += CB8->(CB8_QTDORI * CB8_CUSTOL)

				CB8->( dbSkip() )
			EndDO

			//favor total
			oHtml:ValByName("ntotal",TransForm(nValor,'@E 999,999,999.99'))
			If TYPE("lRej") == "U"
				oHtml:ValByName("clink",'http://' + GetMV("MV_ENDWF",,"localhost") + ':' + GetMV("TCP_PORTWF",,"80") + '/pp/u_wAcd010.apw?keyvalue='+ZD2->ZD2_HASH)
				oHtml:ValByName("clink2",'http://' + GetMV("MV_ENDWF",,"localhost") + ':' + GetMV("TCP_PORTWF",,"80") + '/pp/u_wAcd010R.apw?keyvalue='+ZD2->ZD2_HASH)
			EndIf

			oProc:cTo := cEmail
			oProc:Start()

			WFSendMail()

			//falta montar o layout do E-mail
			//falta fazer as pagina para o portal

		EndIF

	EndIF

	RestArea(aArea)

Return




/*/{Protheus.doc} AAcd010Consulta
Monta tela com os Status de aprovações dos niveis

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cAlias, character, Alias da rotina
@param nReg, numérico, Registro posicionado
@param nOpc, numérico, Opção do menu
/*/
User Function AAcd010Consulta(cAlias, cReg, cOpc)

	Local oBold
	Local oDlg

	Local oOk := LoadBitmap( GetResources(), "ENABLE" )
	Local oNo := LoadBitmap( GetResources(), "DISABLE" )

	Local oLista
	Local aLiberacoes := GetLiberacoes(CB7->CB7_ORDSEP)

	IF len(aLiberacoes) != 0

		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE "Aprovação da Ordem de Separação - Ordem de Produção" From 109,095 To 400,600 PIXEL

		@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL

		@ 015,007 SAY "Ordem de Separação: " + CB7->CB7_ORDSEP OF oDlg FONT oBold PIXEL SIZE 120,009
		@ 015,127 SAY "Ordem Produção: " + CB7->CB7_OP OF oDlg PIXEL SIZE 120,009 FONT oBold

		@ 33, 03 Listbox oLista Var  cVar Fields Header " ","Nivel", "Aprovador", "Status", "Data Liberação" ;
						Size 247, 95 Of oDlg Pixel

			oLista:SetArray(  aLiberacoes )

			oLista:bLine := {|| {;
				IIF(aLiberacoes[oLista:nAt][3]=="L", oOk, oNo ) ,;
				aLiberacoes[oLista:nAt][1] ,;
				FWGETUSERNAME(aLiberacoes[oLista:nAt][2]) ,;
				IIF(aLiberacoes[oLista:nAt][3]=="L","Liberado","Bloqueado") ,;
				aLiberacoes[oLista:nAt][5] }}

		@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
		@ 132,038 SAY IIF(aScan(aLiberacoes, {|x| x[3] == "B" }) == 0,'Liberado','Bloqueado') OF oDlg PIXEL SIZE 120,009 FONT oBold
		@ 132,215 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL

	 	ACTIVATE MSDIALOG oDlg CENTERED
	Else
		Aviso("Atenção", "Esta ordem de separação não possivel Liberações", {"Sair"}, 2)
	EndIF

Return


/*/{Protheus.doc} AAcd010XRejeita
Função para liberação no nivel da alçada e aviso ao proximo nivel ou liberação da ordem

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cHash, character, Codigo Hash para buscar o nivel da aprovação
@return array, Liberou ou não e qual o problema
/*/
User Function AAcd010XRejeita(cHash)

	Local lContinua := .F.

	Local aLiberacoes := {}
	Local cMensagem := ""

	Local nOk
	Local cNivelCont := "1"

	ZD2->( dbSetOrder(2) )
	ZD2->( dbSeek( cHash ) )
  


//	fazrej(ckey,cJus)            
//		conout("vai chamaar a pagina")

	cHtml := H_GRVREJOS(cHash) //H_WEBLOGIN()
	
//	conout("passou da pagina")
	
	aAux := U_AACD10X2(cHash)

Return {aAux[1], aAux[2]}

/*/{Protheus.doc} AAcd010XRejeita
Função para liberação no nivel da alçada e aviso ao proximo nivel ou liberação da ordem

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@param cHash, character, Codigo Hash para buscar o nivel da aprovação
@return array, Liberou ou não e qual o problema
/*/
User Function AACD10X2(cHash)
	Local lContinua := .F.

	Local aLiberacoes := {}
	Local cMensagem := ""

	Local nOk
	Local cNivelCont := "1"
	Local cTxtManusis := ''
		
	Private aTxtManusis := {}
	Private _cOrdSep := ''
	
	ZD2->( dbSetOrder(2) )
	ZD2->( dbSeek( cHash ) )

	//se achar
	IF ZD2->( Found() )
		_cOrdSep := ZD2->ZD2_ORDSEP 
		cTxtManusis := 'Rejeitado por '+RetNomFunc(ZD2->ZD2_APROV)+' Nivel '+ZD2->ZD2_NIVEL
		//se estiver bloqueado
		IF ZD2->ZD2_STATUS != "B"
			lContinua := .F.
			cMensagem := "Nivel já liberado para esta ordem de separação."			
			Return {lContinua, cMensagem}
		EndIF
	Else
		cMensagem := "Ordem de separação não localizada!"
		Return {lContinua, cMensagem}
	EndIF
	
	IF !CB7->( dbSeek( xFilial("CB7") + _cOrdSep ) )
		lContinua := .F.
		cMensagem := "Ordem de separação não encontrada."			
		Return {lContinua, cMensagem}
	ELSEIF (CB7->CB7_LIBOK =='L')
		lContinua := .F.
		cMensagem := "Ordem de separação já liberada."			
		Return {lContinua, cMensagem}
	ELSEif CB7->CB7_STATUS != '0'
		lContinua := .F.
		cMensagem := "Ordem de separação já liberada."			
		Return {lContinua, cMensagem}
	ENDIF
	
	_cOrdSep := ZD2->ZD2_ORDSEP
	ZD2->(DbGoTop())
	ZD2->( dbSetOrder(1) )
	ZD2->( dbSeek( xFilial("ZD2") + ZD2->ZD2_ORDSEP ) )
	
	Begin Transaction
	CB7->( dbSeek( xFilial("CB7") + _cOrdSep ) )
		
	MontaEmail(.T.)
    //conout(_cOrdSep)
	While !ZD2->( Eof() ) .And. ZD2->(ZD2_FILIAL+ZD2_ORDSEP) == xFilial("ZD2")+_cOrdSep
//		RecLock("ZD2",.F.) //retirado devido a problemas operacionais com os usuários
//		ZD2->( dbDelete() )
//		ZD2->( MsUnLock())
		ZD2->( dbSkip() )
	EndDO
	
	if !empty(cTxtManusis)
		//aAdd(aTxtManusis,{cTxtManusis,'7'})
		aAdd(aTxtManusis,{cTxtManusis,'1'})
	endif
	
	IF(LEN(aTxtManusis) > 0)
		ENVIAMANUSIS()
	ENDIF
	 
	CB8->(DbGoTop())               
	CB8->( dbSetOrder(1) )
	CB8->( dbSeek( xFilial("CB8") + _cOrdSep ) )

	While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == xFilial("CB8")+_cOrdSep
		RecLock("CB8",.F.)
		CB8->( dbDelete() )
		CB8->( MsUnLock())
		CB8->( dbSkip() )
	EndDO

	CB8->(DbGoTop())     

	DbSelectArea('SC2')
	SC2->( dbSetOrder(1) )

	IF SC2->( dbSeek( CB7->CB7_FILIAL+CB7->CB7_OP ) )
		RecLock("SC2",.F.)
		SC2->C2_ORDSEP := ''
		SC2->C2_OK := ''
		SC2->( MsUnLock())
	EndIf

	
	CB7->( dbSetOrder(1) )

	IF CB7->( dbSeek( xFilial("CB7") + _cOrdSep ) )
		RecLock("CB7",.F.)
		CB7->( dbDelete() )
		CB7->( MsUnLock())
	EndIf

	End Transaction
	lContinua := .T.
	cMensagem := 'Rejeição realizada com sucesso!'
	

Return {lContinua, cMensagem}

//Envia para manusis
STATIC FUNCTION ENVIAMANUSIS()
	Local nInd
	If SUPERGETMV( 'TCP_MANUSI', .f., .F. )
	
		CB7->( dbSetOrder(1) )
		if CB7->( dbSeek( xFilial("CB7") + _cOrdSep ) ) .AND. !EMPTY(CB7->CB7_XOM)
			For nInd := 1 to len(aTxtManusis)
						  
				oManusis  := ClassIntManusis():newIntManusis()    
				oManusis:cFilZze    := xFilial('ZZE')
				oManusis:cChave     := CB7->CB7_FILIAL+CB7->CB7_OP
				oManusis:cTipo	    := 'E'
				oManusis:cStatus    := 'P'
				oManusis:cErro      := ''
				oManusis:cEntidade  := 'AWF'
				oManusis:cOperacao  := 'I'
				oManusis:cRotina    := FunName()
				oManusis:cErroValid := ''
				oManusis:cTxtStat   := aTxtManusis[nInd][1]
				
				IF oManusis:gravaLog()  
					U_MNSINT03(oManusis:cChaveZZE)              
				ELSE
					ALERT(oManusis:cErroValid)
				ENDIF  
				
				if !empty(aTxtManusis[nInd][2])
					DbSelectArea('ZZF')
					  
					ZZF->(DBOrderNickname( 'NUMEROOP'))
					IF ZZF->(DbSeek(xFilial('ZZF')+CB7->CB7_OP))
						While !ZZF->(EOF()) .AND. ALLTRIM(ZZF->ZZF_OP) == ALLTRIM(CB7->CB7_OP)
				
							nRecZzf := ZZF->(RECNO())
							oManusis  := ClassIntManusis():newIntManusis()    
							oManusis:cFilZze    := xFilial('ZZE')
							oManusis:cChave     := ZZF->ZZF_FILIAL+ZZF->ZZF_OP+ZZF->ZZF_RESERV
							oManusis:cTipo	    := 'E'
							oManusis:cStatus    := 'P'
							oManusis:cErro      := ''
							oManusis:cEntidade  := 'SOP'
							oManusis:cOperacao  := 'I'
							oManusis:cRotina    :=  FunName()
							//
							oManusis:cStatOp 	:= aTxtManusis[nInd][2]//'7'
						
							IF oManusis:gravaLog()  
								U_MNSINT03(oManusis:cChaveZZE)              
							ELSE
								ALERT(oManusis:cErroValid)
							ENDIF 
							
							
							ZZF->(DbSetOrder(2))
							ZZF->(dbGoTo(nRecZzf))
							
							ZZF->(DbSkip())
						EndDo
					ENDIF	
				endif
				
			next
		endif
		
	ENDIF
return

STATIC FUNCTION RetNomFunc(cCodigo)
_cNomUsu := ''

IF(!EMPTY(cCodigo))
	_aRetUsu := FWSFALLUSERS({cCodigo})
	if(LEN(_aRetUsu) >= 1 .AND. LEN(_aRetUsu[1]) >= 4)
		_cNomUsu := ALLTRIM(_aRetUsu[1,4])
	ENDIF
endif

return _cNomUsu