#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"
//#INCLUDE "msobjects.ch"

#DEFINE   CR   Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ REFI550J ºAutor  ³ Kaique Sousa      º Data ³  07/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ BROWSE PARA MANUTENCAO DAS OPERACOES COM PEFIN SERASA      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function REFI550J

Local aSize     		:= MsAdvSize()
Local aObjects  		:= {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo     		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj   		:= MsObjSize(aInfo,aObjects)
Local nSuperior  		:= 20
Local nEsquerda  		:= aPosObj[2,2]
Local nInferior  		:= aPosObj[2,3] - 15
Local nDireita   		:= aPosObj[2,4]

Local _nLinBut	  		:= 3
Local _nSalt	  		:= 11
Local _cCapOld	  		:= ''

PRIVATE lMsErroAuto 	:= .F.
Private _cCpoObg		:= 'E1_MSFIL|E1_OK|E1_VENCTO|E1_VENCREA|E1_CLIENTE|E1_LOJA|E1_NUM|E1_PARCELA|E1_PREFIXO|E1_TIPO|E1_VALOR|E1_SALDO|E1_ACPEFIN|E1_ANPEFIN|E1_STPEFIN|E1_DTPEFIN|E1_USPEFIN|E1_OBPEFIN|E1_UEPEFIN|E1_OCPEFIN|E1_ODPEFIN|E1_OLPEFIN|E1_URPEFIN|E1_MOPEFIN|A1_PEFIN'
Private _cCampos		:= GetNewPar('MV_SERCPOS','E1_FILIAL|E1_MSFIL|E1_CLIENTE|E1_LOJA|A1_NOME|E1_NUM|E1_PARCELA|E1_PREFIXO|E1_TIPO|E1_EMISSAO|E1_VENCTO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_SEGMENT|E1_STPEFIN|E1_DTPEFIN|E1_USPEFIN|E1_ACPEFIN|E1_ANPEFIN|E1_YNF1|E1_YNF2|E1_YNF3|E1_YNF4|E1_YNF5|E1_YNF6')
Private _aCpos			:= {"E1_STPEFIN", "E1_DTPEFIN", "E1_ACPEFIN", "E1_ANPEFIN", "E1_OBPEFIN"}

//Define as Cores - so objetos
Private _aCores 		:=  U_S550JMCOR(1)
Private _cArqTrb		:= ''
Private _cQryTrb  	:= ''
Private _aStru    	:= {}
Private oBrwMark
Private _aBrowse		:= {}
Private lInverte		:= .F.
Private _cMarca 		:= GetMark()
Private _lMosTodos   := .t.


Private _oDlgWin
Private _oDlg
Private _cPesq			:= Space(40)
Private _cCbPq			:= ""
Private _aCbPq			:= {"Código","Nome do Cliente"}
Private _oCbPq
Private _oPesq
Private _oPnPesq
Private _oPnBoto
Private cCadastro	:= " [Pefin - Serasa]"
Private _aEndTRB	:= {}
Private nValor 		:= 0
Private nQtdTitSel 	:= 0
Private oValor		:= Nil
Private oQtdTitSel 	:= Nil

If U_550JPARA(.T.)
	
	_oDlgWin := GetWndDefault()
	_cCapOld	:= _oDlgWin:cCaption
	_oDlgWin:cCaption := _cCapOld + cCadastro
	
	Define Dialog _oDlg Title cCadastro From aSize[7],0 to aSize[6]-28,aSize[5] STYLE nOR(WS_VISIBLE,WS_POPUP) of oMainWnd Pixel
	
	_oPnBoto := TPanel():New(aPosObj[1,2]-2,aPosObj[1,2]-2,'',_oDlg,, .T., .T.,, ,aPosObj[1,4]-(aPosObj[1,4]-46),nInferior+(16*2)+6,.T.,.T. )
	_oPnPesq := TPanel():New(aPosObj[1,2]-2,aPosObj[1,2]+45,'',_oDlg,, .T., .T.,, ,aPosObj[1,4]-45,22,.T.,.T. )
	
	@ 03,002 MSCOMBOBOX _oCbPq   VAR _cCbPq ITEMS _aCbPq  SIZE 80,40 OF _oPnPesq PIXEL
	@ 03,085 MSGET _oPesq Var _cPesq When .T. Picture "@!" SIZE 100,09 OF _oPnPesq PIXEL
	//TButton():New( 03, 190, "&Buscar"	, _oPnPesq,{|| Alert("Em Desenvolvimento") },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 03, 190, "&Buscar"	, _oPnPesq,{|| U_PESQ001L()	,oBrwMark:oBrowse:setFocus() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//Criacao do MsSelect 
	oBrwMark := MsSelect():New(_cArqTrb,"E1_OK","",_aBrowse,@lInverte,@_cMarca,{nSuperior+10,nEsquerda+45,nInferior+25,nDireita},,,,,_aCores) 
	oBrwMark:bMark := {||U_550JEXIB(_cArqTrb,_cMarca,oValor,oQtdTitSel)}

	@ nInferior + 028, nEsquerda+45 Say "Valor Selecionado: "		SIZE 50,8 PIXEL Of _oDlg
	@ nInferior + 028, nEsquerda+125 Say oValor   	VAR nValor		Picture "@E 999,999,999.99" PIXEL Of _oDlg

	@ nInferior + 028, nEsquerda+205 Say "Qtd Selecionado: "			SIZE 50,8 PIXEL Of _oDlg 
	@ nInferior + 028, nEsquerda+285 Say oQtdTitSel   	VAR nQtdTitSel PIXEL Of _oDlg

	oBrwMark:oBrowse:lCanAllmark := .T. 
	Eval(oBrwMark:oBrowse:bGoTop) 
	oBrwMark:oBrowse:Refresh()
	
	//Evento de Marcacao Individual 
	oBrwMark:bAval := {|| U_550JMARK(,_cArqTrb,_cMarca,oValor,oQtdTitSel) } // Para marca/desmarca individual
	oBrwMark:oBrowse:bAllMark := {|| Processa({|| U_550JALMK(9)},"Invertendo...") } // Para marca/desmarca geral
	
	// Evento de clique no cabeÁalho da browse
	//oBrowse:bHeaderClick := {|| alert('bHeaderClick') }
	// Evento de duplo click na celula
	//oBrowse:bLDblClick   := {|| alert('bLDblClick') }
	
	// Cria Botoes com metodos b·sicos
	oBtnVis := TButton():New( _nLinBut, 002, "&Visualizar"		, _oPnBoto , {|| SE1->(DbGoTo((_cArqTrb)->E1_RECNO)),AxVisual('SE1',(_cArqTrb)->E1_RECNO,2)	, oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	//Adição de botão apenas temporiario para Samanta dar manuntenção nos registros que foram pagos
	//Feito por Helitom Silva em 13/03/2013
	oBtnVis := TButton():New( _nLinBut, 002, "&Alterar"			, _oPnBoto , {|| SE1->(DbGoTo((_cArqTrb)->E1_RECNO)),AxAltera('SE1',(_cArqTrb)->E1_RECNO, 4,,_aCpos), oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnPar := TButton():New( _nLinBut, 002, "Parâme&tros"		, _oPnBoto , {|| U_550JPARA(.T.)	, oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnMar := TButton():New( _nLinBut, 002, "&Marcar"			, _oPnBoto , {|| U_550JPOP(1,oBtnMar:nLeft,oBtnMar:nTop) , oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnNeg := TButton():New( _nLinBut, 002, "&Negativar"		, _oPnBoto , {|| U_REFI061J(_cMarca) , U_550JMOV() ,oBrwMark:oBrowse:Refresh() , oBrwMark:oBrowse:setFocus()	} 	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnPos := TButton():New( _nLinBut, 002, "P&ositivar"		, _oPnBoto , {|| U_REFI062J(_cMarca) , U_550JMOV() ,oBrwMark:oBrowse:Refresh() , oBrwMark:oBrowse:setFocus()	} 	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnGer := TButton():New( _nLinBut, 002, "&Gerar Arquivo"	, _oPnBoto , {|| U_550JPOP(2,oBtnGer:nLeft,oBtnGer:nTop) }	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnPro := TButton():New( _nLinBut, 002, "Proc &Arquivo"	, _oPnBoto , {|| U_REFI066J("A") , MsAguarde({|| U_550JFIL(10)},'Filtro','Aguarde... Atualizando registros...') , U_550JMOV() ,oBrwMark:oBrowse:Refresh() ,oBrwMark:oBrowse:setFocus() } ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnCan := TButton():New( _nLinBut, 002, "&Cancelar"			, _oPnBoto , {|| U_550JCAN() , U_550JMOV() ,oBrwMark:oBrowse:setFocus() } ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnRel := TButton():New( _nLinBut, 002, "&Relatório"		, _oPnBoto , {|| U_REFI066J("R") , U_550JMOV() ,oBrwMark:oBrowse:setFocus()	} 	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnPar := TButton():New( _nLinBut, 002, "&Colunas"			, _oPnBoto , {|| U_CTFT175J('MV_SERCPOS') , _cCampos	 := GetNewPar('MV_SERCPOS',_cCampos) , oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnLeg := TButton():New( _nLinBut, 002, "&Legenda"			, _oPnBoto , {|| U_550JLEGE() 	, oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnFil := TButton():New( _nLinBut, 002, "&Filtrar"			, _oPnBoto , {|| U_550JRFIL() 	, oBrwMark:oBrowse:setFocus()	}	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	_nLinBut += _nSalt
	
	oBtnSai := TButton():New( _nLinBut, 002, "&Sair"				, _oPnBoto , {|| _oDlg:End() }	,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE DIALOG _oDlg
	
	_oDlgWin:cCaption := _cCapOld
	
EndIf

Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ 550JMOV  ºAutor  ³ Kaique Sousa      º Data ³  07/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JMOV

(_cArqTrb)->(DbGoTop())
(_cArqTrb)->(DbGoBottom())
(_cArqTrb)->(DbGoTop())

Return( Nil )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ 550JCAN  ºAutor  ³ Kaique Sousa      º Data ³  07/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ OPCAO DE CANCELAMENTO DE INCLUSAO OU EXCLUSAO MANUAL       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JCAN

	If (_cArqTrb)->E1_ACPEFIN = 'A'
		Aviso('Atenção','Títulos com o status de aguardando retorno não podem ter a operação cancelada !',{'OK'},,'Status Não Permitido !')
		Return( Nil )
	EndIf

	If Aviso('Atenção','Esta operação não poderá ser desfeita !',{'Sim','Não'},,'Confirma Cancelamento ?') = 1

		DbSelectArea(_cArqTrb)
		DbGoTop()

		ProcRegua(0)

		While (_cArqTrb)->(!Eof())
			
			If IsMark('E1_OK',_cMarca,.F.)

				SE1->(DbGoTo((_cArqTrb)->E1_RECNO))

				If !(SE1->E1_STPEFIN $ '13')
					//Aviso('Atenção','Somente títulos com status de Aguardando podem ter a operação cancelada !',{'OK'},,'Status Não Permitido !')
					//Return( Nil )
					(_cArqTrb)->(DbSkip())
				EndIf

				U_REFI060J(SE1->(Recno()),If(SE1->E1_STPEFIN$'12','IC','EC'),Nil,'xMANUALx',{'XXX'},dDataBase)
				
				IncProc('Aguarde.... efetuando Cancelamento...')
			
			EndIf
			
			(_cArqTrb)->(DbSkip())

		EndDo

	EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ 550JPOP  ºAutor  ³ Kaique Sousa      º Data ³  07/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CHAMA O MENU POPUP DO BOTAO.                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JPOP(_nTipo,_nX,_nY)

Local _oPMenu

Menu _oPMenu Popup

Do Case
	Case _nTipo = 1
		MenuItem "&Todos"     	ACTION Processa({|| U_550JALMK(1)},"Marcando...")
		MenuItem "&Nenhum" 		ACTION Processa({|| U_550JALMK(0)},"Desmarcando...")
		MenuItem "&Inverte" 		ACTION Processa({|| U_550JALMK(9)},"Invertendo...")
	Case _nTipo = 2
		MenuItem "&Inclusão"    ACTION U_REFI055J("I")
		MenuItem "&Exclusão" 	ACTION U_REFI055J("E")
		MenuItem "&Ambos" 		ACTION U_REFI055J("A")
EndCase

EndMenu

_oPMenu:Activate(_oDlg:nLeft+_nX+50,_oDlg:nTop+_nY+12)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REFI550J  ºAutor  ³Kaique Sousa           º Data ³  07/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PESQ001L

	Local _cFiltro := ""

	If !Empty(_cPesq)
		If Substr(_cCbPq,1,1)=="C"
			_cFiltro += " E1_CLIENTE = '"+Alltrim(_cPesq)+"'"
		Else
			_cFiltro += " A1_NOME LIKE '"+Alltrim(_cPesq)+"%'"
		EndIF
	EndIf
	_lMosTodos 	:= (MV_PAR09 = 2)
	MsAguarde({|| U_550JFIL(If(!_lMosTodos,10,),If(!Empty(_cFiltro),' AND '+_cFiltro,_cFiltro))},'Filtro','Aguarde... Filtrando registros...')

Return( Nil ) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FI50LEG   ºAutor  ³ Kaique Sousa      º Data ³  05/23/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LEGENDA                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JLEGE()

Local aCorLeg	:= U_S550JMCOR(2)

U_550JWLEG(cCadastro, "Legenda", aCorLeg)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³550JPARA  ºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ABRE TELA DE PARAMETROS PARA FILTRAR O BROWSE CONFORME AS   º±±
±±º          ³PERGUNTAS.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function 550JPARA(_lAtu,_cFiltro)

Local _lConv		:= .T.
Local _lRet			:= .F.
Local _aSegment		:= {"A","P"}
Local bPergunte		:= {|_lConv| _lConv := Pergunte('PEFIN1',.T.) }
Default _cFiltro	:= ""

If _lAtu
	If !Pergunte('PEFIN2',_lAtu)
		Return( _lRet )
	EndIf
Else
	Pergunte('PEFIN2',_lAtu)
EndIf

While _lConv .And. Empty(MV_PAR01)
	If (_lConv := (Aviso('Atenção','Obrigatório informar o convênio !' + CR + 'Tentar Novamente ?',{'Sim','Não'},,'Convênio não informado !') = 1))
		Eval(bPergunte,@_lConv)
	EndIf
EndDo

_lRet  := !Empty(MV_PAR01)

If _lRet
	
	_cConv			:= MV_PAR01
	_cFilDe 		:= POSICIONE('ZP6', 1, xFilial('ZP6') + _cConv, 'ZP6_FILINI') // Foi excluido filial inicial e final da pergunta pois as mesmas ficaram no cadastro de convenios
	_cFilAte		:= POSICIONE('ZP6', 1, xFilial('ZP6') + _cConv, 'ZP6_FILFIN') // Foi excluido filial inicial e final da pergunta pois as mesmas ficaram no cadastro de convenios
	//_cVenDe		:= MV_PAR02
	//_cVenAte		:= MV_PAR03
	_cCliDe			:= MV_PAR02
	_cCliAte		:= MV_PAR03
	_dEmiDe			:= MV_PAR04
	_dEmiAte		:= MV_PAR05
	_dVenDe   		:= MV_PAR06
	_dVenAte		:= MV_PAR07
	_cETipos		:= MV_PAR08
	
	If Empty(_cFilDe) .or. Empty(_cFilAte)
		MsgInfo('Atenção, não foi informado Filial Inicial/Final no cadastro de Convenios com SERASA!, verifique!')
	EndIf
	
	//Filial
	_cFiltro += " AND E1_MSFIL >= '"+_cFilDe+"' AND E1_MSFIL <= '"+_cFilAte+"'"

	//Vendedor
	/*_cFiltro += " AND (    E1_VEND1 >= '"+_cVenDe+"' AND E1_VEND1 <= '"+_cVenAte+"'"
	_cFiltro += "       OR E1_VEND2 >= '"+_cVenDe+"' AND E1_VEND1 <= '"+_cVenAte+"'"
	_cFiltro += "       OR E1_VEND3 >= '"+_cVenDe+"' AND E1_VEND1 <= '"+_cVenAte+"'"
	_cFiltro += "       OR E1_VEND4 >= '"+_cVenDe+"' AND E1_VEND1 <= '"+_cVenAte+"'"
	_cFiltro += "       OR E1_VEND5 >= '"+_cVenDe+"' AND E1_VEND1 <= '"+_cVenAte+"' )"*/
	//Cliente
	_cFiltro += " AND E1_CLIENTE >= '"+_cCliDe+"' AND E1_CLIENTE <= '"+_cCliAte+"'"
	//Emissao
	_cFiltro += " AND E1_EMISSAO >= '"+DtoS(_dEmiDe)+"' AND E1_EMISSAO <= '"+DtoS(_dEmiAte)+"'"
	//Vencimento
	_cFiltro += " AND E1_VENCREA >= '"+DtoS(_dVenDe)+"' AND E1_VENCREA <= '"+DtoS(_dVenAte)+"'"
	
	//Segmento
	If !Empty(_cETipos)
		//_cFiltro += " AND E1_TIPO NOT IN (" + U_CTCF054J(_cETipos,,-1) + ")"
		_cFiltro += " AND E1_TIPO NOT IN " + FormatIn(If(SubStr(_cETipos,1,Len(Alltrim(_cETipos)))==';',SubStr(_cETipos,1,Len(Alltrim(_cETipos))-1),_cETipos),';') + " "
	EndIf

	If _lAtu
		
		//Tratamento feito para que pudesse selecionar somente registros validos ou todos para processamento da rotina
		//Autor: Helitom Silva
		//Data: 05/03/2013
		_lMosTodos 	:= (MV_PAR09 = 2)
		
		If _lMosTodos// = .T.
			MsAguarde({|| U_550JFIL(, _cFiltro)}, "Selecionando todos os registros...")
		Else
			MsAguarde({|| U_550JFIL(10, _cFiltro)}, "Selecionando registros válidos...")
		EndIf
	
	EndIf
	
EndIf

Return( _lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ 550JFIL  ºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FILTRA A TELA DO MARKBROWSE CONFORME PARAMETROS DEFINIDOS  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JFIL(_nFiltro,_cFiltro)

Local _nRecno		:= SE1->(Recno())
Local _aSQLFil		:= U_S550JMCOR(3)
Local _cInTip		:= ''
Local _cInPrv		:= ''

//Se for passado o numero da Legenda.
If !Empty(_nFiltro)
	nQtdTitSel 	:= 0
	nValor		:= 0
	If _nFiltro <= Len(_aSQLFil)
		U_550JPARA(.F.,@_cFiltro)
		_cFiltro += _aSQLFil[_nFiltro]
	Else
		U_550JPARA(.F.,@_cFiltro)
	EndIf
Else
	U_550JPARA(.F.,@_cFiltro)
EndIf

//msgAlert( _cFiltro )

//Complementos de filtro somente para Filtro por Parametros.
//Saldo Zerado (baixa normal ou antes de ser enviado)
//Comentado por Helitom, pois não estava trazendo todos os status com essa regra abaixo
//If Empty(_nFiltro)
//	_cFiltro := _cFiltro + " AND ( E1_SALDO > 0 OR E1_SALDO <= 0 AND E1_STPEFIN IN ('1','2')) "
//EndIf

//Complementos do filtro que sempre vao ser aplicados
//Tipos de titulos excluidos
//Prepara para tudo ficar como valor de Clausula In
_cInTip += U_REFI052J( MVRECANT )

_cInPrv := U_REFI052J( MVTAXA )
_cInTip += If(!Empty(_cInTip) .And. !Empty(_cInPrv),',','') + _cInPrv

_cInPrv := U_REFI052J( MV_CRNEG )
_cInTip += If(!Empty(_cInTip) .And. !Empty(_cInPrv),',','') + _cInPrv

_cInPrv := U_REFI052J( MVABATIM,,'|' )
_cInTip += If(!Empty(_cInTip) .And. !Empty(_cInPrv),',','') + _cInPrv

_cInPrv := U_REFI052J( MVPROVIS )
_cInTip += If(!Empty(_cInTip) .And. !Empty(_cInPrv),',','') + _cInPrv

//Parametro do Usuario para informar outros tipos que nao devem aparecer no browse
_cInPrv := U_REFI052J( GetNewPar("MV_TIPOPFI","") )
_cInTip += If(!Empty(_cInTip) .And. !Empty(_cInPrv),',','') + _cInPrv

_cFiltro += " AND E1_TIPO NOT IN (" + _cInTip + ")"

//Log para desenv.
//If GetNewPar("MV_WSQLPFI",.T.)
//	MemoWrit("C:\TEMP\FILTRO_SE1_SERASA_PEFIN.SQL",_cFiltro)
//EndIf

//Monta ou Re-Monta o Array e o Browse com os dados.
U_550JMKTR(_cFiltro)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ 550JMKTR ºAutor  ³ Kaique Sousa      º Data ³  07/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PREPARA A AREA DE TRABALHO PARA O MARKBROWSE               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function 550JMKTR(_cFiltro)

Local _nRec     	:= 0
Local _nI				:= 0

Local _cQryCpos		:= ''
Local _cWhere			:= ''
Local _cQryCor		:= ''
Local _cQuery   	:= ''
Local _aTab     	:= {}

Local _cTipo			:= ''
Local _cTam			:= ''
Local _cDec			:= ''
Local _cTit			:= ''
Local _cPic			:= ''
Local _cBox 			:= ''

Local _lFirst   	:= Empty(_cArqTrb)
Local lAvisa    	:= .F.
Local _acpAppend	:= {}

// Abri a SA1 apenas pra verificacao a existencia de campos do array _aCampos
// Helitom Silva
// Data: 04/03/2012
_aTab := GetArea()
DbSelectArea('SA1')
RestArea(_aTab)

//Define os Campos Para Tabela Temporaria e Browse
_aCampos := U_REFI059J(_cCampos)

//Define os Campos Obrigatorios
_aCpoObg	:= U_REFI059J(_cCpoObg)

If !_lFirst
	If Select(_cArqTrb) > 0
		DbSelectArea(_cArqTrb)
		_nRec := (_cArqTrb)->(Recno())
		ZAP
		//(_cArqTrb)->(DbGoTop())
		//While !(_cArqTrb)->(Eof())
		//	If RecLock(_cArqTrb)
		//		(_cArqTrb)->(DbDelete())
		//		(_cArqTrb)->(MsUnlock())
		//	EndIf
		//	(_cArqTrb)->(DbSkip())
		//EndDo
	EndIf
Else
	//Campos Fixos
	For _nI := 1 To Len(_aCpoObg)
		If SE1->(FieldPos(_aCpoObg[_nI])) <> 0 .or. SA1->(FieldPos(_aCpoObg[_nI])) <> 0
			_cTipo	:= GetSx3Cache(_aCpoObg[_nI],'X3_TIPO')
			_cTam		:= GetSx3Cache(_aCpoObg[_nI],'X3_TAMANHO')
			_cDec		:= GetSx3Cache(_aCpoObg[_nI],'X3_DECIMAL')
			_cTit		:= GetSx3Cache(_aCpoObg[_nI],'X3_TITULO')
			
			//Define a estrutura da Tabela tempor·ria.
			Aadd( _aStru , {_aCpoObg[_nI] , _cTipo, _cTam, _cDec})
		EndIf
	Next _nI
	
	//Sempre Adiciona o Campo RECNO
	aAdd( _aStru , {"E1_COR" 		,"N", 02, 00})
	//	aAdd( _aStru , {"E1_RECNO"		,"N", 06, 00})  // retirado em 23/01/2012 Elso, pois apresentou erro na gravação neste campo
	aAdd( _aStru , {"E1_RECNO"		,"N", 07, 00})	// alterado para tamanho 7 23/01/2012 Elso
	
	//Campos Fixos do Browse (INICIO)
	aadd( _aBrowse ,{"E1_OK",,"",""})
	aadd( _aBrowse ,{"E1_FILIAL",,"Filial","99999999"})
	
	For _nI := 1 To Len(_aCampos)
		
		//Insere os Campos na Estrutura
		If !(_aCampos[_nI] $ _cCpoObg)
			If SE1->(FieldPos(_aCampos[_nI])) <> 0 .or. SA1->(FieldPos(_aCampos[_nI]))<> 0 //adicionei para verificacacao da existencia dos campos na tabela SA1 - Helitom Silva - 04/02/2013
				_cTipo	:= GetSx3Cache(_aCampos[_nI],'X3_TIPO')
				_cTam		:= GetSx3Cache(_aCampos[_nI],'X3_TAMANHO')
				_cDec		:= GetSx3Cache(_aCampos[_nI],'X3_DECIMAL')
				_cTit		:= GetSx3Cache(_aCampos[_nI],'X3_TITULO')
				
				//Define a estrutura da Tabela tempor·ria.
				Aadd( _aStru , {_aCampos[_nI] , _cTipo, _cTam, _cDec})
			EndIf
		EndIf
		
		//Insere os Campos no Browse
		If !(_aCampos[_nI] $ 'E1_OK|E1_FILIAL')
			If SE1->(FieldPos(_aCampos[_nI])) <> 0 .or. SA1->(FieldPos(_aCampos[_nI])) <> 0 //adicionei para verificacacao da existencia dos campos na tabela SA1 - Helitom Silva - 04/02/2013
				_cTipo	:= GetSx3Cache(_aCampos[_nI],'X3_TIPO')
				_cTam		:= GetSx3Cache(_aCampos[_nI],'X3_TAMANHO')
				_cDec		:= GetSx3Cache(_aCampos[_nI],'X3_DECIMAL')
				_cTit		:= GetSx3Cache(_aCampos[_nI],'X3_TITULO')
				_cPic		:= GetSx3Cache(_aCampos[_nI],'X3_PICTURE')
				_cBox		:= GetSx3Cache(_aCampos[_nI],'X3_CBOX')
				
				//Define os Campos que vao aparecer no Browse
				If !Empty(_cBox)
					aadd( _aBrowse ,{MontaBlock("{|| U_REFI070J('" + AllTrim(_aCampos[_nI]) + "', (_cArqTrb)->" + AllTrim(_aCampos[_nI]) + ") }"),,AllTrim(_cTit),AllTrim(_cPic)})
				Else
					aadd( _aBrowse ,{_aCampos[_nI],,AllTrim(_cTit),AllTrim(_cPic)})
				EndIf
			EndIf
		EndIf
		
	Next _nI
	
	//Campos Fixos no Browse (FIM)
	aadd( _aBrowse ,{"E1_RECNO",,"Registro",""})
	
EndIF

//Prepara a Qry de Campos.
//Campos Especiais
_cQryCpos := ",'  ' E1_OK, SE1.R_E_C_N_O_ E1_RECNO "

//Campos Obrigatorios
For _nI := 1 To Len(_aCpoObg)
	If _aCpoObg[_nI] <> 'E1_OK'
		_cQryCpos += ', ' + _aCpoObg[_nI]
	EndIf
Next _nI

//Campos do Usuario
For _nI := 1 To Len(_aCampos)
	If !(_aCampos[_nI] $ _cCpoObg)
		If SE1->(FieldPos(_aCampos[_nI])) <> 0 .or. SA1->(FieldPos(_aCampos[_nI])) <> 0 //adicionei para verificacacao da existencia dos campos na tabela SA1 - Helitom Silva - 04/02/2013
			_cQryCpos += ', ' + _aCampos[_nI]
		EndIf
	EndIf
Next _nI

//Query que Define a Cor de Status do Registro
_cQryCor := U_S550JMCOR(4)

//Define o Where da Consulta (Filtros)
_cWhere := "SE1.D_E_L_E_T_ = ' ' "
If !Empty(_cFiltro)
	_cWhere += _cFiltro
EndIf

_cQuery := " SELECT "
_cQuery += _cQryCor
_cQuery += _cQryCpos
_cQuery += " FROM " + RetSQLName('SE1') + " SE1 "
_cQuery += " LEFT JOIN " + RetSQLName('SA1') + " SA1 ON SA1.A1_COD = SE1.E1_CLIENTE "
_cQuery += "                                        AND SA1.A1_LOJA = SE1.E1_LOJA "
_cQuery += "                                    	 AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' "
_cQuery += "                                    	 AND SA1.D_E_L_E_T_ = ' ' "
_cQuery += " WHERE "
_cQuery += _cWhere
_cQuery += " ORDER BY " + Iif('A1_NOME' $ Upper(_cQryCpos), 'A1_NOME,', '') + "E1_CLIENTE, E1_LOJA, E1_PARCELA, E1_VENCTO" //-->> Incluido em 06/02/2013 por Carlos Miranda.

//MemoWrite("C:\TEMP\SQL_SE1_SERASA_PEFIN.SQL",_cQuery)

//Monta a Area de Trabalho
_cQryTrb   := GetNextAlias()

TcQuery _cQuery New Alias (_cQryTrb)

If _lFirst
	_cArqTrb := GetNextAlias()
	oTempTable := FWTemporaryTable():New( _cArqTrb )
	oTempTable:SetFields(_aStru)
	oTempTable:Create()
EndIf

_aEndTRB := {}

//Adiciona ao Array "_acpAppend" os campos a serem gravados na tabela _cArqTrb
//Para diminuir os calculos na hora da passagem dos valores para os campos.
For _nI := 1 To Len(_aCampos)
	If !(_aCampos[_nI] $ 'E1_FILIAL/E1_OK/E1_COR/E1_RECNO')
		If SE1->(FieldPos(_aCampos[_nI])) <> 0 .or. SA1->(FieldPos(_aCampos[_nI])) <> 0 //adicionei para verificacacao da existencia dos campos na tabela SA1 - Helitom Silva - 04/02/2013
			
			_cTipo	:= GetSx3Cache(_aCampos[_nI],'X3_TIPO')
			
			aAdd(_acpAppend, {_aCampos[_nI], _cTipo})
			
		EndIf
	EndIf
Next _nI

//Grava dados na tabela _cArqTrb
While !(_cQryTrb)->(Eof())
	
	RecLock(_cArqTrb, .T.)
	
	//Atualiza Campos Fixos
	(_cArqTrb)->E1_OK			:= (_cQryTrb)->E1_OK
	(_cArqTrb)->E1_COR			:= (_cQryTrb)->E1_COR
	(_cArqTrb)->A1_PEFIN		:= (_cQryTrb)->A1_PEFIN
	(_cArqTrb)->E1_FILIAL		:= (_cQryTrb)->E1_FILIAL
	(_cArqTrb)->E1_RECNO		:= (_cQryTrb)->E1_RECNO
	
	aAdd(_aEndTRB, {(_cQryTrb)->E1_RECNO, (_cQryTrb)->(Recno())})
	
	For _nI := 1 To Len(_acpAppend)
		
		Do Case
			Case _acpAppend[_nI, 2] = 'D'
				&( _cArqTrb+'->' + _acpAppend[_nI, 1] + ' := StoD(' + _cQryTrb + '->' + _acpAppend[_nI, 1] + ')' )
			Case _acpAppend[_nI, 2] = 'C'
				&( _cArqTrb+'->' + _acpAppend[_nI, 1] + ' := AllTrim(' + _cQryTrb + '->' + _acpAppend[_nI, 1] + ')' )
			Case _acpAppend[_nI, 2] = 'N'
				&( _cArqTrb+'->' + _acpAppend[_nI, 1] + ' := ' + _cQryTrb + '->' + _acpAppend[_nI, 1] )
		EndCase
		
	Next _nI
	
	(_cArqTrb)->(MsUnlock())
	(_cQryTrb)->(DbSkip())
	
EndDo

(_cQryTrb)->(DbCloseArea())

If _nRec <> 0
	(_cArqTrb)->(DbGoTo(_nRec))
Else
	(_cArqTrb)->(DbGoTop())
EndIF

If Type('oBrwMark') != 'U'
	Eval(oBrwMark:oBrowse:bGoTop)
	oBrwMark:oBrowse:Refresh()
EndIf

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³550JLEGE  ºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³BrwLegenda(cTitulo,cMensagem,aCores)                        º±±
±±º          ³                                                            º±±
±±º          ³cTitulo    :Titulo da Janela                                º±±
±±º          ³cMensagem  :Mensagem exibida                                º±±
±±º          ³aCores     :Array contendo as cores                         º±±
±±º          ³nXSize     :Tamanho do Bitmap para ajuste da mensagem       º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function 550JWLEG(cTitulo,cMensagem,aCores,nXSize)

Local nY       				:= 0
Local _nI      				:= 0
Local aBmp[Len(aCores)]
Local aSays[Len(aCores)]

Private oDlgLeg

DEFAULT  nXSize := 14

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aCores)*20)+50,320 TITLE cTitulo OF oMainWnd PIXEL

//No onclick do usuario a tela sera fechada=
//oDlgLeg:bLClicked:= {||oDlgLeg:End()}

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

// Desenho de Fundo
@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL

@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
@ 03,37 SAY cMensagem OF oDlgLeg PIXEL SIZE 100,009 FONT oBold
For _nI := 1 to Len(aCores)
	
	&('lChk'+cValToChar(_nI)) := .F.
	
	_bBloco2 := "{|u| If(PCount()>0,lChk" + cValToChar(_nI) + ":=u,lChk" + cValToChar(_nI) + ")}"
	_bBloco5 := "{|| ( MsAguarde({|| U_550JFIL("+cValToChar(_nI)+") },'Filtro','Aguarde... Aplicando filtro...'), oDlgLeg:End()) }"
	
	@ 20+((_nI-1)*10),46 BITMAP aBmp[_nI] RESNAME aCores[_nI][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER
	
	&('xChk'+cValToChar(_nI))	:= TCheckBox():New(20+((_nI-1)*10),36,'',MontaBlock(_bBloco2),oDlgLeg,10,10,Nil,MontaBlock(_bBloco5),Nil,Nil,CLR_HBLUE,Nil,.T.,.T.,Nil,.F.,{|| .T. })
	@ 20+((_nI-1)*10),(nXSize/2) + 49 SAY If((nY+=1)==nY,aCores[nY][2]+If(nY==Len(aCores),If((nY:=0)==nY,"",""),""),"") OF oDlgLeg PIXEL
	
Next _nI

nY := 0

ACTIVATE MSDIALOG oDlgLeg CENTERED

Return(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³050JMARK  ºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA USADA PARA MARCAR O REGISTRO.                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function 550JMARK(_nAcao,_cArqTrb,_cMarca,oValor,oQtdTitSel)

Local aArea   	:= GetArea()
Local lMarca 	:= (_cArqTrb)->E1_OK == _cMarca
Local _lVal		:= .T.
Local _cMsg		:= ""

Default _nAcao	:= -1

//So valida se Houver Marcacao ou Inversao
If _nAcao <> 0 .And. !lMarca
	
	If ( (_cArqTrb)->E1_COR =2 )
		//Incluido Por Luciano.
	Else
		//Valida Valor minimo e maximo do titulo (saldo)
		//If !(_lVal := E1_VALOR >= ZP6->ZP6_VLRMIN .And. (_cArqTrb)->E1_VALOR <= ZP6->ZP6_VLRMAX)   Alterado Por Luciano
		If !(_lVal := (_cArqTrb)->E1_SALDO >= ZP6->ZP6_VLRMIN .And. (_cArqTrb)->E1_SALDO <= ZP6->ZP6_VLRMAX)
			_cMsg += 'Título fora da faixa do convênio, mínimo ['+AllTrim(Transform(ZP6->ZP6_VLRMIN,'@E 999,999,999.99'))+'] máximo ['+AllTrim(Transform(ZP6->ZP6_VLRMAX,'@E 999,999,999,999,999.99'))+']' + CR
		EndIf
		
		//Valida idade minima do cliente
		If _lVal
			_cPessoa	:= Posicione('SA1',1,xFilial('SA1')+SE1->((_cArqTrb)->E1_CLIENTE+(_cArqTrb)->E1_LOJA),'A1_PESSOA')
			_dNascim := Posicione('SA1',1,xFilial('SA1')+SE1->((_cArqTrb)->E1_CLIENTE+(_cArqTrb)->E1_LOJA),'A1_DTNASC')
			If _cPessoa = 'F' .And. !Empty(_dNascim)
				_nIdade := HS_DifData(_dNascim, dDataBase)[1] * (if(_dNascim <= dDataBase,1,-1))
			Else
				_nIdade := 999
			EndIf
			
			//Valida dias de vencido do titulo
			If !(_lVal := ((dDatabase - (_cArqTrb)->E1_VENCREA) >= ZP6->ZP6_DIASVE))
				_cMsg := 'Título vencido à ' + cValToChar(dDatabase - (_cArqTrb)->E1_VENCREA) + ' dias, convênio exige pelo menos ' + cValToChar(ZP6->ZP6_DIASVE) + ' dias !'
			EndIf
		EndIf
		
		If _lVal .And. !(_lVal := (_nIdade >= ZP6->ZP6_IDADE))
			_cMsg += 'Cliente do Título tem ' + cValToChar(_nIdade) + ' anos, mínimo ' + cValToChar(ZP6->ZP6_IDADE) + ' anos conforme definido no convênio !'
		EndIf
		
		If _lVal .And. !(_lVal := ((_cArqTrb)->A1_PEFIN != 'N'))
			_cMsg += 'Cliente do Título é "Especial" e o mesmo não é enviado ao Serasa, conforme configuração de seu cadastro !'
		EndIf
		
		//Mostra a Msg se for o caso !
		If _nAcao < 0 .And. !_lVal
			MsgStop(_cMsg,'Atenção !')
		EndIf
	EndIf
EndIf

//Faz a Marcacao
If _lVal
	
	RecLock(_cArqTrb,.F.)
	Do Case
		Case _nAcao = 0
			(_cArqTrb)->E1_OK := ""
		Case _nAcao = 1
			(_cArqTrb)->E1_OK := _cMarca
		OtherWise
			(_cArqTrb)->E1_OK := If(lMarca,"",_cMarca)
	EndCase
	(_cArqTrb)->(MsUnLock())
	U_550JEXIB(_cArqTrb,_cMarca,oValor,oQtdTitSel)
	
EndIf

RestArea(aArea)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³550JALMARKºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ROTINA PARA MARCAR TODOS OS REGISTROS (CTRL + M)            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function 550JALMK(_nAcao)

Local aArea  	:= GetArea()
Local _nTot	   := 0

dbSelectArea(_cArqTrb)
DbGoTop()
ProcRegua(0)

While !Eof()
	
	IncProc("Marcando registros... " + cValToChar(++_nTot) )
	
	//chama rotina de marcar
	
	// Não marca os Vencidos - Incluídos quando o usuário clicar em marcar todos
	// Autor: Helitom Silva
	// Data: 04/03/2013
	If !(_nAcao == 1 .and. (_cArqTrb)->E1_COR == 6)
		U_550JMARK(_nAcao,_cArqTrb,_cMarca,oValor,oQtdTitSel)
	EndIf
	
	DbSkip()
	
EndDo

RestArea(aArea)
oBrwMark:oBrowse:Refresh() 
DbGoTop()

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³550JRFIL  ºAutor  ³ Kaique Sousa      º Data ³  05/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CHAMA O CONSTRUTOR DE FILTRO E SEM SEGUIDA FILTRA O BROWSE  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function 550JRFIL

Local _cFilRet	:= ""

If !Empty( _cFilRet := BuildExpr("SE1",,,.T.) )
	MsAguarde({|| U_550JFIL(,' AND '+_cFilRet)},'Filtro','Aguarde... Filtrando registros...')
EndIf

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³S550JMCOR ºAutor  ³ Kaique Sousa      º Data ³  07/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MONTA COMPONENTES DE COR DA LEGENDA E OUTROS.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function S550JMCOR(_nTipo,_cAlias,_nPRet)

Local _aRegCor		:= {}
Local _oRet
Local _cLegVal		:= '2#5' //Informe o ID das Legendas que a Legenda 8 Utiliza-ra.
Local _nI			:= 1

Default _cAlias		:= ''
Default _nPRet		:= 0

//   1-ID   2-COR                3-DESCRICAO                 4-REGRA MSSQL 								  																			  											5- REGRA ORACLE                                                																		 6- REGRA ADVPL
aAdd( _aRegCor , { "0" , "BR_BRANCO_OCEAN" 	, "Aguardando Retorno" 			, "E1_ACPEFIN = 'A'" 						  																									 , "E1_ACPEFIN = 'A'" 																														  , "!ALIAS!->E1_ACPEFIN = 'A'"} )
aAdd( _aRegCor , { "1" , "BR_LARANJA_OCEAN"	, "Baixado - Normal" 			, "E1_SALDO = 0 AND E1_STPEFIN = ' '" 																			  							 , "E1_SALDO = 0 AND E1_STPEFIN = ' '" 																		  			 			  , "!ALIAS!->E1_SALDO = 0 .AND. !ALIAS!->E1_STPEFIN = ' '" } )
aAdd( _aRegCor , { "2" , "BR_PINK_OCEAN" 	, "Baixado - Não Excluído"		, "E1_SALDO = 0 AND E1_ACPEFIN = 'O' AND E1_STPEFIN IN ('1','2')" 																 , "E1_SALDO = 0 AND E1_ACPEFIN = 'O' AND E1_STPEFIN IN ('1','2')" 					  										  , "!ALIAS!->E1_SALDO = 0 .AND. !ALIAS!->E1_ACPEFIN = 'O' .AND. !ALIAS!->E1_STPEFIN $ '1/2'" } )
aAdd( _aRegCor , { "3" , "BR_PRETO_OCEAN" 	, "Baixado - Excluído" 			, "E1_SALDO = 0 AND E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('3','4')" 														  		 , "E1_SALDO = 0 AND E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('3','4')" 					  										  , "!ALIAS!->E1_SALDO = 0 .AND. !ALIAS!->E1_ACPEFIN = 'I' .AND. !ALIAS!->E1_STPEFIN $ '3/4'" } )
aAdd( _aRegCor , { "4" , "BR_VERDE_OCEAN" 	, "Em Aberto - Normal" 			, "E1_SALDO > 0 AND CONVERT(VARCHAR,GETDATE(),112) <= E1_VENCREA" 									  							 , "E1_SALDO > 0 AND TO_CHAR(SYSDATE,'YYYYMMDD') <= E1_VENCREA" 																  , "!ALIAS!->E1_SALDO > 0 .AND. dDataBase <= !ALIAS!->E1_VENCREA"} )
aAdd( _aRegCor , { "5" , "BR_AMARELO_OCEAN" , "Vencido - Não Incluído"		, "E1_SALDO > 0 AND CONVERT(VARCHAR,GETDATE(),112) >  E1_VENCREA AND E1_ACPEFIN = ' ' AND E1_STPEFIN = ' '" 									 , "E1_SALDO > 0 AND TO_CHAR(SYSDATE,'YYYYMMDD') >  E1_VENCREA AND E1_ACPEFIN = ' ' AND E1_STPEFIN = ' '" 		  							  , "!ALIAS!->E1_SALDO > 0 .AND. dDataBase >  !ALIAS!->E1_VENCREA .AND. !ALIAS!->E1_ACPEFIN = ' ' .AND. !ALIAS!->E1_STPEFIN = ' '" } )
aAdd( _aRegCor , { "6" , "BR_AZUL_OCEAN" 	, "Vencido - Incluído" 			, "E1_SALDO > 0 AND CONVERT(VARCHAR,GETDATE(),112) >  E1_VENCREA AND E1_ACPEFIN = 'O' AND E1_STPEFIN IN ('1','2')" , "E1_SALDO > 0 AND TO_CHAR(SYSDATE,'YYYYMMDD') >  E1_VENCREA AND E1_ACPEFIN = 'O' AND E1_STPEFIN IN ('1','2')" , "!ALIAS!->E1_SALDO > 0 .AND. dDataBase >  !ALIAS!->E1_VENCREA .AND. !ALIAS!->E1_ACPEFIN = 'O' .AND. !ALIAS!->E1_STPEFIN $ '1/2'" } )
aAdd( _aRegCor , { "7" , "BR_MARRON_OCEAN" 	, "Vencido - Excluído" 			, "E1_SALDO > 0 AND CONVERT(VARCHAR,GETDATE(),112) >  E1_VENCREA AND E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('3','4')" , "E1_SALDO > 0 AND TO_CHAR(SYSDATE,'YYYYMMDD') >  E1_VENCREA AND E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('3','4')" , "!ALIAS!->E1_SALDO > 0 .AND. dDataBase >  !ALIAS!->E1_VENCREA .AND. !ALIAS!->E1_ACPEFIN = 'I' .AND. !ALIAS!->E1_STPEFIN $ '3/4'" } )
aAdd( _aRegCor , { "8" , "PMSTASK2" 		, "Marcados para Positivação"	, "E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('1','2')" 																 , "E1_ACPEFIN = 'I' AND E1_STPEFIN IN ('1','2')" 					  									     , "!ALIAS!->E1_ACPEFIN = 'I' .AND. !ALIAS!->E1_STPEFIN $ '1/2'" } )
aAdd( _aRegCor , { "9" , "PMSTASK4" 		, "Somente Válidos Mov."		, "", "", ""} ) 
// A Legenda 9 ira receber as regras validas, ou seja,
// informe na Variavel(_cLegVal) separado por # o ID da legenda que deseja definir como valida e a LEGENDA com ID 9 a utiliza-ra.
// Autor: Helitom Silva
// Data: 05/03/2013

If !Empty(_cLegVal) 
	
	For _nI := 1 To Len(_aRegCor)
		If cValToChar(_aRegCor[_nI, 1]) $ _cLegVal
			_aRegCor[10,4] += Iif(Empty(_aRegCor[10,4]), ' (' + _aRegCor[_nI,4] + ') ', ' OR (' + _aRegCor[_nI,4] + ') ')
			_aRegCor[10,5] += Iif(Empty(_aRegCor[10,5]), ' (' + _aRegCor[_nI,5] + ') ', ' OR (' + _aRegCor[_nI,5] + ') ')
			_aRegCor[10,6] += Iif(Empty(_aRegCor[10,6]), ' (' + _aRegCor[_nI,6] + ') ', ' .OR. (' + _aRegCor[_nI,6] + ') ')
		EndIf
	Next _nI
	
	_aRegCor[10,4] := '(' + _aRegCor[10,4] + ')'
	_aRegCor[10,5]	 := '(' + _aRegCor[10,5] + ')' 
	_aRegCor[10,6]	 := '(' + _aRegCor[10,6] + ')' 
	
EndIf

aAdd( _aRegCor , { "10"	 , "PMSTASK1" 				, "Marcados para Negativação"	, "E1_SALDO > 0 AND E1_ACPEFIN = 'N' AND E1_STPEFIN = ' '" 																 , "E1_SALDO > 0 AND E1_ACPEFIN = 'N' AND E1_STPEFIN = ' '" 					  									     , "!ALIAS!->E1_SALDO > 0 .AND. !ALIAS!->E1_ACPEFIN = 'N' .AND. !ALIAS!->E1_STPEFIN = ' '" } ) 
aAdd( _aRegCor , { "11"  , "PMSTASK3" 			   	, "Mostrar Todos"	, "1=1", "1=1", "1=1"} )

Do Case
	Case _nTipo = 1 
		_oRet := {}
		For _nI := 1 To Len(_aRegCor)
			aAdd( _oRet , {"(_cArqTrb)->E1_COR = " + _aRegCor[_nI][01] , _aRegCor[_nI][02]} )
		Next _nI
		
	Case _nTipo = 2
		_oRet := {}
		For _nI := 1 To Len(_aRegCor)
			aAdd( _oRet , {_aRegCor[_nI][02] , _aRegCor[_nI][03]} )
		Next _nI
		
	Case _nTipo = 3 
		_oRet := {}
		For _nI := 1 To Len(_aRegCor)
			If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
				aAdd( _oRet , "AND " + _aRegCor[_nI][05] )
			Else
				aAdd( _oRet , "AND " + _aRegCor[_nI][04] )
			EndIf
		Next _nI
		
	Case _nTipo = 4
		_oRet := " CASE "
		For _nI := 1 To Len(_aRegCor)
			If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
				_oRet +=	" WHEN " + _aRegCor[_nI][05] + " THEN " + _aRegCor[_nI][01]
			Else
				_oRet +=	" WHEN " + _aRegCor[_nI][04] + " THEN " + _aRegCor[_nI][01]
			EndIf
		Next _nI
		_oRet += " ELSE 9 END E1_COR "
		
	Case _nTipo = 5
		_oRet := "9"
		For _nI := 1 To Len(_aRegCor)
			_cEval := StrTran(_aRegCor[_nI][06],'!ALIAS!',_cAlias)
			If &(_cEval)
				_oRet := _aRegCor[_nI][_nPRet]
				Exit
			EndIf
		Next _nI
		
EndCase

Return( _oRet )

user Function 550JExib( cAlias, cMarca, oValor, oQtdTit ) 

	If 	!((cAlias)->E1_ACPEFIN = 'I' .AND. (cAlias)->E1_STPEFIN $ '1/2') .And.;
		!((cAlias)->E1_SALDO > 0 .AND. (cAlias)->E1_ACPEFIN = 'N' .AND. Empty((cAlias)->E1_STPEFIN))
		If 	!Empty((cAlias)->E1_YNF1) .And.;
			!Empty((cAlias)->E1_YNF2)
			U_550KEXNF(cAlias,cMarca) 
		EndIf
	EndIf

	DbSelectArea(cAlias)
	
	SE1->(DbGoTo((cAlias)->E1_RECNO))
	
	If (cAlias)->E1_OK == cMarca
		nValor 	+= (cAlias)->E1_VALOR
		nQtdTitSel++
		RecLock("SE1",.F.)
		SE1->E1_YNF1OK := cMarca 
		MsUnlock()
	Else
		nValor 	-= (cAlias)->E1_VALOR
		nQtdTitSel--
		RecLock("SE1",.F.)
		SE1->E1_YNF1OK := space(02)
		MsUnlock()
	EndIf

	nValor := IIf (nValor < 0, 0, nValor)
	nQtdTitSel:= Iif (nQtdTitSel < 0, 0 ,nQtdTitSel)
	oValor:Refresh()
	oQtdTit:Refresh()

Return( Nil )

user function 550KEXNF(_cAlias,_cMarca)

	Local _oPanel1
	Local _oDlgNF
	Local cAliasTMP	:= "TMP"
	Local cAliasSF2 := GetNextAlias()
	Local cMARCA	:= GetMark()
	Local lInverte	:= .F.

	SE1->(DbGoTo((_cAlias)->E1_RECNO))

	DEFINE MSDIALOG _oDlgNF TITLE "Selecione a(s) NF(s)" FROM 000, 000  TO 200, 380 COLORS 0, 16777215 PIXEL //STYLE nOR( WS_VISIBLE, WS_POPUP )
	@ 000, 000 MSPANEL _oPanel1 SIZE 400, 400 OF _oDlgNF COLORS 0, 16777215 RAISED
	_oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
	
	aDBF := {}
	AADD( aDBF , { "SF2_OK" 	, "C" , 02 , 0 } )
	AADD( aDBF , { "DOCUMENTO"	, "C" , 09 , 0 } )
	AADD( aDBF , { "VALOR" 		, "N" , 17 , 2 } )

	aTRB1 := {}
	AADD( aTRB1 , { "SF2_OK" 	, NIL , " "     , } )
	AADD( aTRB1 , { "DOCUMENTO" , NIL , "Documento" , } ) 
	AADD( aTRB1 , { "VALOR" 	, NIL , "Valor" , PesqPict("SF2","F2_VALBRUT")} )
	
	oTempTable := FWTemporaryTable():New( cAliasTMP )
	oTempTable:SetFields(aDBF)
	oTempTable:Create()

	cWhere := ""

	If !Empty((_cAlias)->E1_YNF1)
		cWhere += (_cAlias)->E1_YNF1
	EndIf
	If !Empty((_cAlias)->E1_YNF2)
		cWhere += If(!Empty(cWhere),",","") + (_cAlias)->E1_YNF2
	EndIf
	If !Empty((_cAlias)->E1_YNF3)
		cWhere += If(!Empty(cWhere),",","") + (_cAlias)->E1_YNF3 
	EndIf
	If !Empty((_cAlias)->E1_YNF4)
		cWhere += If(!Empty(cWhere),",","") + (_cAlias)->E1_YNF4 
	EndIf
	If !Empty((_cAlias)->E1_YNF5)
		cWhere += If(!Empty(cWhere),",","") + (_cAlias)->E1_YNF5 
	EndIf
	If !Empty((_cAlias)->E1_YNF6)
		cWhere += If(!Empty(cWhere),",","") + (_cAlias)->E1_YNF6
	EndIf 

	cWhere := "%" + FormatIn(cWhere,",") + "%"

	BeginSql Alias cAliasSF2
		Select 	F2_NFELETR,
				F2_VALBRUT
		from %Table:SF2% SF2 
		Where 	SF2.F2_NFELETR IN %exp:cWhere% And
				SF2.F2_CLIENTE = %exp:(_cAlias)->E1_CLIENTE% And
				SF2.F2_LOJA = %exp:(_cAlias)->E1_LOJA% And
				SF2.%NotDel%
	EndSql

	dbSelectArea(cAliasSF2)

	While !(cAliasSF2)->(Eof())
		
		RecLock("TMP",.T.)
		
		If 	Alltrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF1)
			If !Empty(SE1->E1_YNF1OK)
				TMP->SF2_OK		:= GetMark()
			EndIf
		EndIf

		If 	Alltrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF2)
			If !Empty(SE1->E1_YNF2OK) 
				TMP->SF2_OK		:= GetMark()
			EndIf
		EndIf

		If 	Alltrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF3)
			If !Empty(SE1->E1_YNF3OK) 
				TMP->SF2_OK		:= GetMark()
			EndIf
		EndIf

		If 	Alltrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF4)
			If !Empty(SE1->E1_YNF4OK) 
				TMP->SF2_OK		:= GetMark()
			EndIf
		EndIf

		If 	AllTrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF5)
			If !Empty(SE1->E1_YNF5OK) 
				TMP->SF2_OK		:= GetMark()
			EndIf
		EndIf

		If 	Alltrim((cAliasSF2)->F2_NFELETR) == Alltrim((_cAlias)->E1_YNF6)
			If !Empty(SE1->E1_YNF6OK) 
				TMP->SF2_OK		:= GetMark()	
			EndIf
		EndIf

		TMP->DOCUMENTO 	:= (cAliasSF2)->F2_NFELETR
		TMP->VALOR 		:= (cAliasSF2)->F2_VALBRUT
		MsUnlock()
		
		dbSelectArea(cAliasSF2)
		(cAliasSF2)->(dbSkip())
	EndDo

	oMARK := MsSelect():New(cAliasTMP,"SF2_OK","",aTRB1,@lInverte,@cMARCA,{000,000,080,192},,,_oPanel1,,)
	Eval(oMARK:oBrowse:bGoTop) 
	oMARK:oBrowse:Refresh() 
	
	TButton():New( 085, 100, "&Cancelar"	, _oPanel1,{|| _oDlgNF:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 085, 150, "&Confirmar"	, _oPanel1,{|| fGrava(_cAlias,cMarca),_oDlgNF:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG _oDlgNF CENTERED

	//Deleta TRB
	oTempTable:Delete() 

Return( Nil )

Static function fGrava(cAlias,cMarca)
	
	dbSelectArea("TMP")
	TMP->(dbGotop())

	While TMP->(!Eof())
		cMark := If(!Empty(TMP->SF2_OK),TMP->SF2_OK,"") 
		//If IsMark('SF2_OK',cMarca,.F.)
			If Alltrim(TMP->DOCUMENTO) == Alltrim(SE1->E1_YNF1)
				If RecLock("SE1",.F.)
					SE1->E1_YNF1OK := cMark
					SE1->(MsUnlock())
				EndIf
			ElseIf Alltrim(TMP->DOCUMENTO) == Alltrim(SE1->E1_YNF2)
				If RecLock("SE1",.F.)
					SE1->E1_YNF2OK := cMark
					SE1->(MsUnlock())
				EndIf
			ElseIf Alltrim(TMP->DOCUMENTO) == Alltrim(SE1->E1_YNF3)
				If RecLock("SE1",.F.)
					SE1->E1_YNF3OK := cMark
					SE1->(MsUnlock())
				EndIf
			ElseIf Alltrim(TMP->DOCUMENTO) == Alltrim(SE1->E1_YNF4)
				If RecLock("SE1",.F.)
					SE1->E1_YNF4OK := cMark
					SE1->(MsUnlock())
				EndIf
			ElseIf Alltrim(TMP->DOCUMENTO) == Alltrim(SE1->E1_YNF5)
				If RecLock("SE1",.F.)
					SE1->E1_YNF5OK := cMark
					SE1->(MsUnlock())
				EndIf
			Else
				If RecLock("SE1",.F.)
					SE1->E1_YNF6OK := cMark
					SE1->(MsUnlock())
				EndIf
			EndIf
		//EndIf
		TMP->(dbSkip()) 
	EndDo
Return( Nil )