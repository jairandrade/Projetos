#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"



user function ctrSales(_cFil,_cNum,_lInclui,_lAltera,_lExc,_lResid)

Local _cGrupo := ''
Local cOper
Local oRetPed := NIL

Local lTemMSErr := IF(TYPE('lMSErroAuto') != 'U',.T.,.F.)
lOCAL _lMsErroAx := IF(lTemMSErr,lMSErroAuto,.F.) 

Local _lIntSal := GETMV( 'TCP_PCSFOR' ) 
Default _lResid := .F.

IF _lInclui
	cOper := 'I'
ELSEIF _lAltera
	cOper := 'A'
ELSEif _lExc
	cOper := 'E'
elseif _lResid 
	cOper := 'L' 
else
	cOper := 'R' 
ENDIF

SetKey(VK_F5, {|| ''})
SetKey(VK_F6, {|| ''})

if _lIntSal .AND. VAL(_cNum) > 0 
	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	IF cOper == 'E' .OR. cOper == 'L'
		
		IF SC7->(dbSeek(_cFil+_cNum))
			_cGrupo := C7_XGRPSAL
		else
			_cGrupo := 'CANCELAR'
		ENDIF

		oRetPed := integraSales('5',cOper,_cGrupo,_cFil+_cNum )
		
	ELSEIf SC7->(dbSeek(_cFil+_cNum))
		If cOper == 'R'
			_cAliAks := getNextAlias()
	
			BeginSQL Alias _cAliAks
				SELECT AL_XSALES
				FROM %TABLE:SAL% SAL
				WHERE SAL.%NotDel% AND AL_COD = %EXP:SC7->C7_APROV%  
		
			EndSQL
			
			IF (_cAliAks)->(!Eof())
				_cGrupo := (_cAliAks)->AL_XSALES
			ENDIF
			
			(_cAliAks)->(dbCloseArea())
		ELSE
			_cGrupo := buscaAlcada(cOper,SC7->C7_FILIAL+SC7->C7_NUM)
		ENDIF
	//	_cGrupo := 'ENGINEERING'
		if !empty(_cGrupo)
		
			oRetPed := integraSales('1',cOper,_cGrupo,SC7->C7_FILIAL+SC7->C7_NUM)
		ELSE
			IF TYPE("_cErrSales") == 'C'
				_cErrSales := "Erro ao integrar com o Sales." 
			ENDIF
			Help(NIL, NIL, "Pedido não enviadao para o Sales.", NIL, 'Nenhuma alçada selecionada', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Reenvie o pedido'})
		endif
	ELSE
		IF TYPE("_cErrSales") == 'C'
			_cErrSales := "Erro ao integrar com o Sales." + oComprasPc:cErro+ ' - '+oComprasPc:cSugestao
		endif
		Help(NIL, NIL, "Pedido não enviadao para o Sales.", NIL, 'Nenhuma alçada selecionada', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Reenvie o pedido'})
	
	endif
	
	
endif

IF(lTemMSErr)
	//Volta o valor dessa variável, pois quando o anexo gerava erro de anexo duplicado, o sistema marcava lMSErroAuto como erro, mesmo o usuario ja tendo alterado o nome.
	lMSErroAuto:= _lMsErroAx
ENDIF	

return oRetPed

//Controla integracoess sales force
static function buscaAlcada(cOper,cChave)

Local _aGrupo := {}
Local _cGrupo := ''

	_aGrupo := integraSales('2',cOper,'',cChave) 

	if VALTYPE(_aGrupo) == 'A' .AND. LEN(_aGrupo) > 0
		_cGrupo := montaTela(_aGrupo,cChave)
	ENDIF

return _cGrupo 

static function integraSales(cTipo,cOper,cGrupo, cChave) 
	Local retornWs := nil
	
	
	oComprasPc  := ClassIntPcCompras():new()    
	
	oComprasPc:cGrpSales  := cGrupo
	
	oComprasPc:cGrpProt  := ''	
			
	IF oComprasPc:registraIntegracao(cTipo,cChave,cOper) 
	 	
		if oComprasPc:atuCodPed(NIL) 	
			IF oComprasPc:enviaSales()
				retornWs := oComprasPc:oRetorno
			ELSE
				Help(NIL, NIL, "Erro ao integrar com o Sales.", NIL, oComprasPc:cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {oComprasPc:cSugestao})
				
				IF TYPE("_cErrSales") == 'C'
					_cErrSales := "Erro ao integrar com o Sales." + oComprasPc:cErro+ ' - '+oComprasPc:cSugestao
				ENDIF
				
			ENDIF
		else
			Help(NIL, NIL, "Erro ao atualizar o pedido.", NIL, oComprasPc:cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {oComprasPc:cSugestao})
		ENDIF
	elseif !empty(oComprasPc:cErro)
		Help(NIL, NIL, "Erro ao integrar com o Sales.", NIL, oComprasPc:cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {oComprasPc:cSugestao})
		IF TYPE("_cErrSales") == 'C'
			_cErrSales := "Erro ao integrar com o Sales." + oComprasPc:cErro+ ' - '+oComprasPc:cSugestao
		ENDIF
	ENDIF  
	FreeObj( oComprasPc )

return retornWs

static function montaTela(aGrupo,cChave)
Local cGrupo := ''
Local lCOnt := .f.

While !lCOnt
	DEFINE MSDIALOG oDlgAprov TITLE "Definir grupo de aprovação. Pedido: "+SUBSTR(cChave,1,2)+' - '+SUBSTR(cChave,3,6) From 001,001 to 380,615 Pixel Style DS_MODALFRAME

	oDlgAprov:lEscClose     := .F.
	oBrwGrp := TCBrowse():New(010,005,300,150,,,,oDlgAprov,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	
	oBrwGrp:AddColumn(TCColumn():New("Grupo"      , {|| aGrupo[oBrwGrp:nAt,01]},,,,, ,.F.,.F.,,,,.F., ) )
	oBrwGrp:SetArray(aGrupo)
	
	oBrwGrp:bLDblClick   := { || cGrupo := aGrupo[oBrwGrp:nAt,01], oDlgAprov:End()}
	
	ACTIVATE MSDIALOG oDlgAprov CENTERED
	if !Empty(alltrim(cGrupo))
		lCOnt:= .T.
	Else
		aviso("Atenção", "Obrigatorio informar o grupo ",{"OK"})
	EndIF
EndDo

return cGrupo



