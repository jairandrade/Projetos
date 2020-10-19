#INCLUDE 'totvs.ch'
#INCLUDE "rwmake.ch" 

/*/{Protheus.doc} ITUP003
    Indentifica o PC referente ao título no financeiro
	OBS: Apenas para títulos gerados pela rotina MATA100
    @type  Function
    @author Marcos Feijó IT UP
    @since 23/06/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function ITUP003()
	Local _aPedidos	:= {}
	Local _aNumPC	:= {}
	Local _cNumPC	:= ''
	Local _lOpc		:= .F.
	Local aRotBKP   := aRotina
	Local INCBKP    := INCLUI 
	Local ALTBKP    := ALTERA 
	Local cAliasSC7 := GetNextAlias()

	// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
	Private aRotina   	:= {}
	Private INCLUI    	:= .F.
	Private ALTERA    	:= .F.
	Private nTipoPed  	:= 1
	Private cCadastro 	:= "Consulta Pedido de Compras"
	Private l120Auto	:= .F.

	//--Monta o aRotina para compatibilizacao
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )

	//aAdd(_aPedidos, {"095512", 111745})
	//aAdd(_aNumPC, "095512")

	If SE2->E2_ORIGEM = 'MATA100'
    			
        BeginSql Alias cAliasSC7
			Select C7_NUM, R_E_C_N_O_ REGSC7
			From %TABLE:SC7% SC7
			Where	SC7.C7_NUM		IN
								 (	Select Distinct D1_PEDIDO
									From  %TABLE:SD1%  SD1
									Where	SD1.D1_FILIAL		= %EXP:SE2->E2_FILIAL%
											AND SD1.D1_DOC		= %EXP:SE2->E2_NUM%
											AND SD1.D1_SERIE	= %EXP:SE2->E2_PREFIXO%
											AND SD1.D1_FORNECE	= %EXP:SE2->E2_FORNECE%
											AND SD1.D1_LOJA		= %EXP:SE2->E2_LOJA%
											AND SD1.D_E_L_E_T_	= ' ') 
					And SC7.D_E_L_E_T_	= ' '
        EndSql

		While (cAliasSC7)->(!Eof())
			aAdd(_aPedidos, {(cAliasSC7)->C7_NUM, (cAliasSC7)->REGSC7})
			aAdd(_aNumPC, (cAliasSC7)->C7_NUM)
			(cAliasSC7)->(dbSkip())
		EndDo

		(cAliasSC7)->(dbCloseArea())

		Do Case
		Case Len(_aPedidos) = 1
			SC7->(dbGoTo(_aPedidos[1][2]))
			A120Pedido("SC7",_aPedidos[1][2],2)
		Case Len(_aPedidos) > 1
			//Abro uma janela para selecionar o pedido que o usuário deseja visualizar

			@ 050,150 TO 150,400 DIALOG oDlg2 TITLE "Selecione o PC Desejado"
			@ 012,005 Say "Pedido de Compra:"			Size 50,10 COLOR CLR_HBLUE Pixel Of oDlg2
			@ 011,060 ComboBox _cNumPC Items _aNumPC Of oDlg2 Pixel Size 40,006			// 	          When lEditar Of oDlg Pixel Size 30,006     

			@ 030,060 BmpButton Type 1 Action (_lOpc := .T., Close(oDlg2))
			@ 030,090 BmpButton Type 2 Action (_lOpc := .F., Close(oDlg2))
		
			Activate Dialog oDlg2 Centered

			If _lOpc
				_nNumPC := aScan(_aPedidos, {|x| alltrim(x[1])==_cNumPC})
				If !Empty(_nNumPC)
					SC7->(dbGoTo(_aPedidos[_nNumPC][2]))
					A120Pedido("SC7",_aPedidos[_nNumPC][2],2,,.F.,.F.)
				EndIf
			EndIf	
			
		OtherWise
			MsgAlert("Pedido de Compra não Encontrado", "ATENÇÃO !!!")
		EndCase
	Else
		MsgAlert("Título Criado por Outra Rotina", "ATENÇÃO !!!")
	EndIf	

	aRotina := aRotBKP
	INCLUI  := INCBKP 
	ALTERA  := ALTBKP 
Return .T.
