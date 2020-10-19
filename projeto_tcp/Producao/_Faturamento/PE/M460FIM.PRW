#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} M460FIM
PE chamado no final do faturamento de uma nota, após a gravação da mesma

@author Thiago Henrique dos Santos
@version P11
@since 15/10/2015
@return nil
/*/
//-------------------------------------------------------------------
User Function M460FIM()

If FindFunction("U_RFAT005")

	IF SF2->F2_TIPO == "B" .AND.;
		MsgYesNo("Deseja Imprimir a Declaração de Bens Materiais?","Atenção")
		
		U_RFAT005()
	Endif

Endif

Return

