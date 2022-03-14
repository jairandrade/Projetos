#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

//==================================================================================================//
//	Programa: KESTR27A		|	Autor: Andre Sakai							|	Data: 18/02/2021	//
//==================================================================================================//
//	Descrição: PE para automatizar o endereçamento de Estoque - empresa 04                										//
//																									//
//==================================================================================================//
/*
Rotina para endereçamento automático ou manual a partir da inclusão do documento de entrada
Pode ser chamada atrves de rotina no menu
*/

USER FUNCTION KESTR27A(_nTipo,_aDoc)

    Local _cAlias1 := getnextalias()
//    Local _cAlias2 := getnextalias()
    Local _cSql := ''
//    Local _cConta := '' 

    Local _aArea := GETAREA()
 //   Local _cCampo

    Local _lwizard := isincallstack('U_KREST27W')
    Local _nRegs := 0 
    Local _nX := 0

    Local aCabSDA := {}
    Local aItemSDB :={}
    Local cItemDB := '00'

	Local _cLog := ''
	Local _cLocaliz := ''

    Private lMsErroAuto 

    Private _lXAuto := .f.

    Default _nTipo := 0

    if(type('oMainWnd')='U')
        _lXAuto := .T.
    Else 
        _lXAuto := .F.
    EndIf

    If(isincallstack('U_MT103FIM') .or. _nTipo = 1)
        _cSql += "% AND DA_FILIAL='"+SF1->F1_FILIAL+"' AND DA_DOC='"+SF1->F1_DOC+"' AND DA_SERIE='"+SF1->F1_SERIE+"' AND DA_CLIFOR='"+SF1->F1_FORNECE+"' AND DA_LOJA='"+SF1->F1_LOJA+"' AND DA_ORIGEM='SD1'  AND DA_SALDO > 0 %"
    ElseIf(_nTipo = 9)//chamada pelo wizard
		_cSql += "% AND DA_FILIAL='"+fwfilial('SDA')+"' AND DA_ORIGEM='SD1'  AND DA_SALDO > 0 %"
    ElseIf(_nTipo = 10)//chamada pelo wizard
		_cSql += "% AND DA_FILIAL='"+fwfilial('SDA')+"' AND DA_ORIGEM='SD1' AND DA_DOC='"+_aDoc[1]+"' AND DA_SERIE='"+_aDoc[2]+"' AND DA_CLIFOR='"+_aDoc[3]+"' AND DA_LOJA = '"+_aDoc[4]+"'  AND DA_SALDO = 0 %"
    EndIf


    BeginSQL ALIAS _cAlias1
        SELECT R_E_C_N_O_ SDAREC, * 
        FROM %TABLE:SDA% SDA (NOLOCK)
        WHERE SDA.D_E_L_E_T_=' ' %EXP:_cSql%
    EndSQL

    If(_lwizard)
        _nRegs := (_cAlias1)->(LastRec())
        procregua(_nRegs)
    EndIf


    _nX := 1
    While (_cAlias1)->(!EOF())
        If(_lwizard)
            incproc(cvaltochar(_nX++) + '/' + cvaltochar(_nRegs))
        Endif
        
        /*
            AND FT_ENTRADA >= '20200101'
            AND FT_CONTA = ' '
            AND FT_TIPOMOV = 'S'
        */

        SDA->(DBGOTO((_cAlias1)->SDAREC))
        IF((_cAlias1)->DA_FILIAL = '08')

			If(SDA->DA_LOCAL='04' )
				If(SDA->DA_SALDO > 0 )
					_cLocaliz := GETMV('KP_LCZ0804',.T.,'EXPEDICAO')
				Else
                    IF(_nTipo = 10)
                        _cLocaliz:= GETMV('KP_LCZ0804',.T.,'EXPEDICAO')
                    ELSE
					(_cAlias1)->(dbskip())
					loop
                    EndIf
				EndIf
			Else
				//necessário cria regras para outros armazens
				(_cAlias1)->(dbskip())
				loop
			EndIf
		Else
			//necessário cria regras para outras empresas
			(_cAlias1)->(dbskip())
			loop

        EndIf


        // zera variaveis
        aCabSDA  := {}
        aItemSDB := {}

        // cabecalho de movimentacao da mercadoria
        aCabSDA := {{"DA_FILIAL",SDA->DA_FILIAL ,NIL},;
        {"DA_PRODUTO"	,SDA->DA_PRODUTO	,NIL},;
        {"DA_QTDORI"	,SDA->DA_QTDORI	    ,NIL},;
        {"DA_SALDO"		,SDA->DA_QTDORI		,NIL},;
        {"DA_DATA"		,dDataBase			,NIL},;
        {"DA_DOC"		,SDA->DA_DOC		,NIL},;
        {"DA_SERIE"		,SDA->DA_SERIE		,NIL},;
        {"DA_CLIFOR"	,SDA->DA_CLIFOR	    ,NIL},;
        {"DA_LOJA"		,SDA->DA_LOJA		,NIL},;
        {"DA_TIPONF"	,SDA->DA_TIPONF	    ,NIL},;
        {"DA_NUMSEQ"	,SDA->DA_NUMSEQ	    ,NIL},;
        {"DA_LOCAL"		,SDA->DA_LOCAL		,NIL},;
        {"DA_ORIGEM"	,SDA->DA_ORIGEM	    ,NIL}}

        // pesquisa a ultimo item utilizado
        if(_nTipo=10)
             cItemDB := '0001'
        else
            cItemDB := Soma1(A265UltIt('C'))
        endif

		Aadd(aItemSDB,{	{"DB_FILIAL",xFilial("SDB"),NIL},;
        				{"DB_ITEM"		,cItemDB			,NIL},;
                    	{"DB_LOCAL"		,SDA->DA_LOCAL   	,NIL},;
                   		{"DB_ESTORNO"	,IIF(_nTipo = 10,'S',' ')			    ,Nil},;
                    	{"DB_LOCALIZ"	,_cLocaliz          ,NIL},; //LOCAL
                   		{"DB_PRODUTO"	,SDA->DA_PRODUTO	,NIL},;
						{"DB_DOC"		,SDA->DA_DOC		,NIL},;
						{"DB_SERIE"		,SDA->DA_SERIE		,NIL},;
						{"DB_NUMSEQ"	,SDA->DA_NUMSEQ		,NIL},;
						{"DB_DATA"		,Date()			    ,NIL},;
						{"DB_QUANT"		,SDA->DA_QTDORI	,NIL}})

        _cLog += Time() + " - Iniciando endereçamento do produto : " + AllTrim(SDA->DA_PRODUTO) + " / Quant.: " + AllTrim(Str(SDA->DA_SALDO)) + CRLF

        lMsErroAuto := .F.
        // executa rotina automática
        MSExecAuto({|x,y,z| mata265(x,y,z)}, aCabSDA, aItemSDB, IIF(_nTipo = 10,4,3)) // 3 - Distribui

        // se ocorreu erro na rotina automatica
        If (lMsErroAuto)
            MostraErro()
        EndIf

        (_cAlias1)->(DBSkip())
    EndDo

     (_cAlias1)->(DBCloseArea())
    RESTAREA(_aArea)

Return





//==================================================================================================//
//	Programa: KPFIS01W		|	Autor: Andre Sakai							|	Data: 18/02/2021	//
//==================================================================================================//
//	Descrição: Wizard para execução manual da rotina de endereçamento								//
//																									//
//==================================================================================================//

USER FUNCTION KESTR27W()

Local _cTexto := 'Rotina de Enderecamento automatico'

If(MsgYesNo("Deseja executar a rotina de enderecamento?",_cTexto))
	processa({||U_KESTR27A(9)})
EndIf

Return


USER FUNCTION KESTR27Z(_aDoc)

Local _cTexto := 'Rotina de Enderecamento automatico'

If(MsgYesNo("Deseja executar a rotina de enderecamento para a nota ("+_aDoc[1]+"-"+_aDoc[2]+")?",_cTexto))
	processa({||U_KESTR27A(10,_aDoc)})
EndIf

Return
