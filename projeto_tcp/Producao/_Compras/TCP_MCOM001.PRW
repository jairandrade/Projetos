#INCLUDE "FWBROWSE.CH"

//-------------------------------
/*/{Protheus.doc} esptela
Rotina para re-envio de dados para o workflow.

@version 2.0
/*/
//-------------------------------
User Function esptela()

	Local oButton := nil
	Local oColumn := nil
	Local oDlg    := nil
	
	Private aFixe   := {}
	Private oBrowse := nil
	
	criaTemp(.T.)

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,600 PIXEL
		//-------------------------------------------------------------------
		// Define o Browse
		//-------------------------------------------------------------------
		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS "_TRB" OF oDlg	
	
			ADD BUTTON oButton TITLE "Reenviar WF" ACTION { || enviawf() } OF oBrowse
			
			ADD COLUMN oColumn DATA { || _TRB->ZLG_FILIAL } TITLE "Filial"  SIZE TamSx3('ZLG_FILIAL')[1] OF oBrowse
			ADD COLUMN oColumn DATA { || _TRB->ZLG_PEDIDO } TITLE "Pedido"  SIZE TamSx3('ZLG_PEDIDO')[1] OF oBrowse
			ADD COLUMN oColumn DATA { || _TRB->ZLG_PARA   } TITLE "Para"    SIZE TamSx3('ZLG_PARA'  )[1] OF oBrowse
			ADD COLUMN oColumn DATA { || _TRB->ZLG_TITU   } TITLE "Assunto" SIZE TamSx3('ZLG_TITU'  )[1] OF oBrowse
			ADD COLUMN oColumn DATA { || _TRB->ZLG_DATA   } TITLE "Data"    SIZE 10                      OF oBrowse
			ADD COLUMN oColumn DATA { || _TRB->ZLG_HORA   } TITLE "Hora"    SIZE TamSx3('ZLG_HORA'  )[1] OF oBrowse
			ADD COLUMN oColumn DATA { || trataUsu(_TRB->ZLG_USERGI)   } TITLE "Usuário" SIZE TamSx3('ZLG_USERGI'  )[1] OF oBrowse
			
		//-------------------------------------------------------------------
		// Ativação do Browse
		//-------------------------------------------------------------------
		ACTIVATE FWFORMBROWSE oBrowse
		oBrowse:DisableDetails()
	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------
	ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------
/*/{Protheus.doc} criaTemp
Cria tabela temporária.

@version 1.0
@param lNovo, boolean, Define se pesquisa dados ou não

@protected
/*/
//-------------------------------
Static Function criaTemp(lNovo)

	Local aStru		:= ZLG->(DbStruct())
	Local aField := {}
	Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																			cField,;
																			X3PICTURE(cField),; 
																			TamSX3(cField)[1],;
																			TamSX3(cField)[2],;
																			GetSx3Cache(cField, "X3_VALID"),;
																			GetSx3Cache(cField, "X3_USADO"),;
																			FwSX3Util():GetFieldType(cField),;
																			X3F3(cField),;
																			GetSx3Cache(cField, "X3_CONTEXT"),;
																			X3CBOX(cField),;
																			GetSx3Cache(cField, "X3_RELACAO");
																			}))}
	
	cQyr := buscaDados()
	
	Aadd(aStru, {"OK","C",2,0})
	Aadd(aStru, {"RECNO","N",10,0})
	
	//cArqTrab := CriaTrab(aStru,.T.) // Nome do arquivo temporario
	
	//dbUseArea(.T.,__LocalDriver,cArqTrab,'_TRB',.F.)

	oTempTable := FWTemporaryTable():New( "_TRB" )
	oTemptable:SetFields( aStru )
	oTemptable:AddIndex("1", {"ZLG_FILIAL","ZLG_PEDIDO" })
	oTempTable:Create()
	cArqTrab := oTempTable:GetRealName()
	
	If lNovo
		Processa({||SqlToTrb(cQyr, aStru, "_TRB")}) // Cria arquivo temporario
	Else
		SqlToTrb(cQyr, aStru, "_TRB")
	Endif
	
	//IndRegua ('_TRB',cArqTrab,"ZLG_FILIAL+ZLG_PEDIDO",,,"Selecionando Registros...")
	
	//Index On ZLG_PEDIDO    	TAG COTACAO                   TO &cArqTrab //1
	
	//DbClearIndex()
	//OrdListAdd(cArqTrab)
	
	DbSetOrder(1) //FICA NA ORDEM DA QUERY
	
	aCPOSTMP:={'ZLG_FILIAL','ZLG_PEDIDO','ZGL_PARA','ZGL_DATA','ZGL_HORA','ZGL_TITU','ZLG_USERGI'}
	
	aEval(aCPOSTMP,bBlock)
	aFixe := aClone(aField)

Return

//-------------------------------
/*/{Protheus.doc} buscaDados
Busca os dados para preenchimento da tabela temporária.


@version 1.0
@return cQry Variável com a query pronta para execução

@protected
/*/
//-------------------------------
Static function buscaDados()

	cQry:= " SELECT  ' ' AS OK ,* "
	cQry+= " FROM "+ RetSqlName("ZLG")+" ZLG "
	cQry+= " WHERE ZLG_FILIAL = '"+xFilial('ZLG')+"' AND ZLG_PEDIDO ='"+SC7->C7_NUM+"'"
	cQry+= " AND D_E_L_E_T_<>'*'"
	IF select("_TRB")<>0
		_TRB->(dbclosearea())
	EndIf

Return cQry

//-------------------------------
/*/{Protheus.doc} EnviaWF
Realiza a chamada para função de envio de dados para o workflow.

@version 1.0

@protected
/*/
//-------------------------------
Static Function EnviaWF()

	Local _nNivel  := substr(alltrim(_TRB->ZLG_TITU),len(alltrim(_TRB->ZLG_TITU))-1,2)
	Local lReenvia := .F.
	
	dbSelectArea("SCR")
	SCR->(dbSetorder(1))
	
	if SCR->(dbSeek(xFilial("SCR")+"PC"+PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1])+_nNivel))
		while SCR->(!Eof()) .AND. SC7->C7_FILIAL+"PC"+PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1]  )+ _nNivel == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL) 
			if SCR->CR_STATUS == '02' .OR. SCR->CR_STATUS == '04' .OR. SCR->CR_STATUS == '05'
				lReenvia := .T.
			endif
			
			SCR->(DbSkip())
		enddo
		IF lReenvia
			U_WFAprPed(_nNivel,.T.)
			aviso("Sucesso","E-Mail reenviado com sucesso!",{"Ok"})
			criaTemp(.F.)
		ELSE
			aviso("Atenção","Não é possível reenviar o e-mail para este aprovador, pois o WF está em outro nível.",{"Ok"})
		ENDIF
		
	ELSE
		aviso("Atenção","Nível não existe!",{"Ok"})
	ENDIF
	
	oBrowse:Refresh(.t.)

Return

static function trataUsu(cUsrLgi)
Local _cNomeUsu := ''
if !empty(cUsrLgi)
	_cNomeUsu := UsrFullName(SUBSTR( EMBARALHA(cUsrLgi,1),3,6 ))
endif
return _cNomeUsu