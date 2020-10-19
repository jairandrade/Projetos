#include 'protheus.ch'

User Function Import20()

	Local bProcess
	Local oProcess

	bProcess := {|oSelf| Executa(oSelf) }

	oProcess := tNewProcess():New("IMPORT20","Criação de complemento de produtos",bProcess,"Rotina para criação de complemento de produtos. Na opção parametros, favor informar o arquivo .CSV para importação",,,.F.,,,.T.,.T.)

Return


Static Function Executa(oProc)

	Local aMata180 := {}
	Local cAlias := GetNextAlias()

	BeginSQL Alias cAlias
		%noparser%

		select B1_COD, B1_DESC
		from %table:SB1%

		where
		    B1_FILIAL  = %xFilial:SB1%
		and B1_MSBLQL <> '1'
		and B1_COD not in (
				select B5_COD
				from %table:SB5%
				where
				    B5_FILIAL  = %xFilial:SB5%
				and D_E_L_E_T_ = ' '
				)
		and D_E_L_E_T_ = ' '

	EndSQL

	oProc:SetRegua1( SB1->( LastRec() ) )


	While !(cAlias)->( Eof() )

		oProc:IncRegua1("Processando..")

		aMata180 := {}
		aAdd( aMata180, { "B5_COD"    , (cAlias)->B1_COD      , Nil })
		aAdd( aMata180, { "B5_CEME"   , (cAlias)->B1_DESC     , Nil })

		lMsErroAuto := .F.

		MSExecAuto({ |x,y| Mata180(x,y)}, aMata180, 3)

		IF lMsErroAuto
			MostraErro()
		EndIF

		(cAlias)->( dbSkip() )
	EndDO

Return