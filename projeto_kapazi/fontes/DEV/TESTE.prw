#Include 'Protheus.ch'
#Include 'TBICONN.ch'

User Function tStJb010()
	Private aDadoscab := {}
	Private aCab := {}
	Private oModel := Nil
	Private lMsErroAuto := .F.
	Private aRotina := {}

	oModel := FwLoadModel ("MATA010")

//Adicionando os dados do ExecAuto cab
	aAdd(aDadoscab, {"B1_COD" ,"RASB103" , Nil})
	aAdd(aDadoscab, {"B1_DESC" ,"PRODUTO TESTE3" , Nil})
	aAdd(aDadoscab, {"B1_TIPO" ,"PA" , Nil})
	aAdd(aDadoscab, {"B1_UM" ,"UN" , Nil})
	aAdd(aDadoscab, {"B1_GRUPO" ,"PA34" , Nil})
	aAdd(aDadoscab, {"B1_LOCPAD" ,"01" , Nil})
	aAdd(aDadoscab, {"B1_LOCALIZ" ,"N" , Nil})
	aAdd(aDadoscab, {"B1_CODBAR" ,"SEM GTIN" , Nil})
	aAdd(aDadoscab, {"B1_CODGTIN" ,"SEM GTIN" , Nil})
	aAdd(aDadoscab, {"B1_IMPZFRC" ,"S" , Nil})
	aAdd(aDadoscab, {"B1_POSIPI" ,"97060000" , Nil})

	aCab:= {{"B5_COD"  	, "RASB102"  		,Nil},;   	// Código identificador do produto
			{"B5_CEME"  		, "PRODUTO TESTE2"  		,Nil},;    	// Nome científico do produto
			{"B5_2CODBAR"		, "SEM GTIN"   	,Nil},;   	// codigo gtin
			{"B5_UMIND"  		, "1"  			,Nil}}    	// unidade de medida

//Chamando a inclusão - Modelo 1
	lMsErroAuto := .F.

	FWMVCRotAuto( oModel,"SB1",3,{{"SB1MASTER", aDadoscab}})

//Se houve erro no ExecAuto, mostra mensagem
	If lMsErroAuto
		MostraErro()
//Senão, mostra uma mensagem de inclusão
	Else
		MsgInfo("Registro incluido!", "Atenção")
	EndIf
	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL

//Inclui o mesmo produto na empresa '02'
	STARTJOB("U_T010Auto",getenvserver(),.t.,aCab)

Return

User Function T010Auto(aCab)
	PRIVATE lMsErroAuto := .F.
	Private INCLUI := .T.
	Private aRotina := {}
	PREPARE ENVIRONMENT EMPRESA "04" FILIAL '01'

	oModel2 := FwLoadModel("MATA180")
	FWMVCRotAuto( oModel2,"SB5",3,{{"SB5MASTER", aCab}})

	If !lMsErroAuto
		ConOut("Dados adicionais na SB5 incluído para a empresa 04 ")
	Else
		ConOut("Erro na inclusao!")
		MostraErro()
	EndIf
	oModel2:DeActivate()
	oModel2:Destroy()
	oModel2 := NIL
	RESET ENVIRONMENT

Return
