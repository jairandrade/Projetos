#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDEF.ch"



User Function MONPEDID()

LOCAL nDias := SUPERGETMV("TCP_XPCDAY", .T., 60)
private dDtLim  := DaySub(dDatabase,nDias)
Private oMark
Private lMsErroAuto := .F.
Private _cNumPed    := ""
Private _cQuery     := ""
Private _cQry       := ""


aRotina := {}
// Instanciamento do classeot
oMark := FWMarkBrowse():New()
// Definição da tabela a ser utilizada
oMark:SetAlias('ZZK')
// Define se utiliza controle de marcação exclusiva
oMark:SetSemaphore(.T.)
// Define a titulo do browse de marcacao
oMark:SetDescription('Pedidos de Compras')
// Define o campo que sera utilizado para a marcação
oMark:SetFieldMark( 'ZZK_OK' )
// Define a legenda
oMark:AddLegend( "ZZK_ERRO==''", "GREEN" , "Sucesso" )
oMark:AddLegend( "ZZK_ERRO!=''", "RED", "Erro" )
// Definição do filtro de aplicacao
oMark:SetFilterDefault( "ZZK_DATA >= '"+DTOS(dDtLim)+"' .AND. ZZK_NUMPC != ' ' .AND. ZZK_TIPO!= ' ' .AND. ZZK_TIPO != '2'  " )
//Passando o menu para o aRotina
aRotina := MenuDef()
// Ativacao da classe
oMark:Activate()

Return NIL
//-------------------------------------------------------------------

Static Function MenuDef()

Private aRotina := {}

aAdd(aRotina, {"Visualizar" , "ViewDef.MONPEDID" , 0, 2, 0, Nil})
aAdd(aRotina, {"Reenviar"	, "U_MONPEDI1()" , 0, 3, 0, Nil})
aAdd(aRotina, {"Reprocessar"	, "U_MONPEDI2()" , 0, 4, 0, Nil})

Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruDT6   := FWFormStruct(1,"ZZK")
Local oModel     := MPFormModel():New("MONPEDID")

//Remove os campos da Grid
//oStruDT6:RemoveField("ZCG_YFILVG")
//oStruDT6:RemoveField("ZCG_YVIAGE")

oModel:AddFields("ZZKUNICO", Nil, oStruDT6)

oModel:SetDescription("Integrações")

oModel:GetModel("ZZKUNICO"):SetDescription("Integrações")

Return ( oModel )

//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel   := FWLoadModel("MONPEDID")
Local oView	   := FWFormView():New()
Local oStruDT6 := FWFormStruct(2,"ZZK")

oView:SetModel(oModel)

oView:AddField("VIEW_ZZK", oStruDT6, "ZZKUNICO")

oView:EnableTitleView('VIEW_ZZK','Integrações')

oView:CreateHorizontalBox( "SUP"  , 100 )

oView:SetOwnerView("VIEW_ZZK" , "SUP")

Return ( oView )


USER Function MONPEDI1()

Local aArea   		:= GetArea()
Local cMarca  		:= oMark:Mark()
Local lReenvi := .F.
	cAliaAux2 := getNextAlias()
	
	BeginSQL Alias cAliaAux2
		SELECT ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMPC,ZZK_OK,ZZK_XMLENV,ZZK_XMLRET,ZZK_TIPO
		FROM %TABLE:ZZK% ZZK
		WHERE ZZK.%NotDel% AND ZZK_DATA >= %EXP:DTOS(dDtLim)% AND ZZK_OK = %EXP:cMarca%
		GROUP BY ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMPC,ZZK_OK,ZZK_XMLENV,ZZK_XMLRET,ZZK_TIPO

	EndSQL
	
WHILE !(cAliaAux2)->(Eof())
	If cMarca == (cAliaAux2)->ZZK_OK .AND. (cAliaAux2)->ZZK_TIPO == '1'
		
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
			
		If SC7->(dbSeek((cAliaAux2)->ZZK_FILIAL+(cAliaAux2)->ZZK_NUMPC))
			IF(SC7->C7_CONAPRO == 'L')
				MsgAlert("Pedido aprovado. Não é possível reenviar por esta rotina.")
			ELSE
				u_PcDelSCR((cAliaAux2)->ZZK_FILIAL,(cAliaAux2)->ZZK_NUMPC)
				U_ctrSales((cAliaAux2)->ZZK_FILIAL,(cAliaAux2)->ZZK_NUMPC,if(EMPTY(SC7->C7_XSALES),.T.,.F.),if(EMPTY(SC7->C7_XSALES),.F.,.T.),.F.)
				lReenvi := .T.
			ENDIF
		endif
	EndIf
	(cAliaAux2)->( dbSkip() )
EndDo
	
IF lReenvi
	MsgAlert("Pedidos enviaadaos com sucesso para o Sales.")
EndIf

RestArea( aArea )

Return ( Nil )


USER Function MONPEDI2()

Local aArea   		:= GetArea()
Local cMarca  		:= oMark:Mark()
Local _cErro := ''
lOCAL oJTransfer
Local cXmlSl := ''
	cAliaAux2 := getNextAlias()
	
	BeginSQL Alias cAliaAux2
		SELECT ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMPC,ZZK_OK,ZZK_XMLENV,ZZK_XMLRET,ZZK_TIPO,
		 ISNULL((SELECT MAX(ZZK2.R_E_C_N_O_) FROM %Table:ZZK% ZZK2 WHERE ZZK.ZZK_FILIAL = ZZK2.ZZK_FILIAL AND ZZK.ZZK_NUMPC=ZZK2.ZZK_NUMPC AND ZZK2.D_E_L_E_T_ = ' ' ),'') as ULTRECNO
		
		FROM %TABLE:ZZK% ZZK
		WHERE ZZK.%NotDel% AND ZZK_OK = %EXP:cMarca%
		
		GROUP BY ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMPC,ZZK_OK,ZZK_XMLENV,ZZK_XMLRET,ZZK_TIPO

	EndSQL
	
	if MsgYesNo('O reprocessamento deste pedido irá excluir todo o histórico de aprovações deste pedido e irá refazer o cadastro apartir da integração mais recente deste pedido. Deseja confirmar o reprocessamento do pedido?')	
	
		WHILE !(cAliaAux2)->(Eof())
			If cMarca == (cAliaAux2)->ZZK_OK //.AND. ZZK->ZZK_TIPO == '4'
				
				IF (cAliaAux2)->ULTRECNO != NIL
					ZZK->(DBGOTO((cAliaAux2)->ULTRECNO))
					
					if ZZK->ZZK_TIPO =='4'
						cXmlSl := ZZK->ZZK_XMLENV
					else
						cXmlSl := ZZK->ZZK_XMLRET
					endif
					
					lReenvi := reproc(ZZK->ZZK_FILIAL,ZZK->ZZK_NUMPC,cXmlSl)
				ENDIF
			EndIf
			(cAliaAux2)->( dbSkip() )
		EndDo
			
		IF lReenvi
			if !empty(_cErro)
				Help(NIL, NIL, "Pedido não enviadao para o Sales.", NIL, _cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {'Reenvie o pedido'})
			
			else
				MsgAlert("Pedidos reprocessados com sucesso para o Sales.")
			endif
		EndIf
	endif

RETURN

static function reproc(_cFil,_cNum,cXmlSl)
Local lRet := .t.
lOCAL oJTransfer := NIL
Local lReenvi := .f.
dbSelectArea("SC7")
SC7->(dbSetOrder(1))
If SC7->(dbSeek(_cFil+_cNum))
	// IF(SC7->C7_CONAPRO == 'L')
	// 	MsgAlert("Pedido aprovado. Não é possível reenviar por esta rotina.")
	// ELSE
		lReenvi := .T.
		oJTransfer := nil
		
		bloqPedCompra(SC7->C7_FILIAL,SC7->C7_NUM)

		u_PcDelSCR(SC7->C7_FILIAL,SC7->C7_NUM)
		
		cBody := cXmlSl
		FWJsonDeserialize(cXmlSl,@oJTransfer)
		oRetAppr  := ClassCtrRetApproval():new()    
		
		IF oRetAppr:atualizaAlcada('4',oJTransfer,'W',cBody,'Monitor Pedidos') 
			 	
			_cErro := oRetAppr:cErro
			lRet := .T.
			
		elseif !empty(oRetAppr:cErro)
			_cErro := "Erro ao integrar com o Sales."+ ' '+oRetAppr:cErro+ ' '+oRetAppr:cSugestao
			lRet := .F.
		ENDIF  
		FreeObj( oRetAppr )
		lReenvi := .T.
	// ENDIF
endif

return lRet

user function PcDelSCR(_cFil,_cNum)

SCR->(dbSetOrder(1))
SCR->(dbGoTop())
SCR->(dbSeek(_cFil+"PC"+PADR(_cNum,TamSx3("CR_NUM")[1])))

While _cFil+"PC"+PADR(_cNum,TamSx3("CR_NUM")[1]) == SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM

	RecLock("SCR",.F.)	
	SCR->(dbDelete())
	SCR->(MsUnLock())

	SCR->(dbSkip())

EndDo

return

static function bloqPedCompra(_cFil,_cPed)
Local lRet := .t.
 
  //cria o update para atualizar todos os registros processados em um unico comando
    cUpdate := " UPDATE " + retsqlname("SC7") + " "  
    cUpdate += " SET C7_CONAPRO = 'B' "
    cUpdate += " where C7_FILIAL = '" + _cFil + "' "
    cUpdate += "   AND C7_NUM = '" + _cPed + "' "
	cUpdate += "   AND D_E_L_E_T_ <> '*' "
    
    nUpdate := TcSqlExec(cUpdate)
	
    if (nUpdate < 0)
    	::cErro := 'Erro ao atualizar o pedido de compras. '+TCSQLError()
		::cSugestao := 'Entre em contato com o suporte.'
		lRet := .F.
	endif
   
	
return lRet