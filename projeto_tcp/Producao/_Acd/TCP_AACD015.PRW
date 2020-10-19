#include "protheus.ch"
#include 'topconn.ch'
/*user/fProtheus.doc} aacd015
	escription)
	@type  Function
	@author Erivalton Oliveira
	@since 09/12/2019
	@version 1.0
	/*/
user function aacd015()
local bprocesso		:= { |oself| processaOP(oself) }
local otproces
local _aRetUser := PswRet(1)

private cperg		:= "AACD015"
Private l240:=.F.,l250 :=.F.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.F.
//-------------------------------------------------------------------------------------------------------------------------------
// variaveis utilizadas para parametros                     
// mv_par01            // Ordem de Produção
//-------------------------------------------------------------------------------------------------------------------------------
pergunte(cperg,.f.)

//----------------------------------------------------s---------------------------------------------------------------------------
// janela principal                                             
//-------------------------------------------------------------------------------------------------------------------------------

otproces := tnewprocess():new( "AACD015" , "fechamento de ordem de produção " , bprocesso , "finaliza ordem de produção em aberto " , "AACD015",,,,,.t.,.t.)
otproces:savelog("Gravacao de log de Usuário: "+_aRetUser[1][2]) 

return

/*/{Protheus.doc} processaOP
	(long_description)
	@type  Function
	@author Erivalton Oliveira
	@since 09/12/2019
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
static function processaOP()
local ntotal:=0
lOCAL cWhere := '%'
Local cAlias := getNextAlias()
if !empty(Mv_par01)
 	cWhere += "AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN = substring('"+ALLTRIM(Mv_par01)+"',1,11)"
endif

cWhere += '%'

//DbSelectArea('SC2')
//SC2->( dbsetorder(1) )
//SC2->( dbgotop() )
//SC2->( dbseek( xfilial("SC2") + mv_par01 ) )
// SC2->( dbseek( xfilial("SC2") + '324777' ) )

 BeginSQL Alias cAlias

     SELECT * 
     FROM %TABLE:SC2% SC2
     INNER JOIN %TABLE:CB7% CB7 ON CB7_OP = C2_NUM+'01001' AND CB7.%NotDel% 
     WHERE SC2.%NotDel% AND C2_DATRF='' AND C2_ORDSEP!='' AND C2_QUJE <= C2_QUANT AND C2_XNUMOM!='' AND CB7_STATUS ='9'
     %EXP:cWhere%

 EndSQL 

while !(cAlias)->(eof()) //.and. alltrim((cAlias)->C2_XNUMOM) =='28417'
	if empty((cAlias)->C2_DATRF) .and. !empty((cAlias)->C2_ORDSEP) .and. (cAlias)->(C2_QUJE <= C2_QUANT) .and. !empty((cAlias)->C2_XNUMOM) 
		 DbSelectArea('SC2')
		 SC2->(DbSetOrder(1))
		 SC2->(DbGoTop())
		 If SC2->(DbSeek(xFilial('SC2')+Alltrim((cAlias)->C2_NUM)))
	 		RecLock('SC2',.F.)
	 		SC2->C2_DATRF := STOD((cAlias)->CB7_DTINIS)
	 		SC2->(MsUnlock())
		 EndIf
			
			DbSelectArea("CB9")
			CB9->(DbSetOrder(11))
			CB9->( dbgotop() )
			IF CB9->(MsSeek(xFilial("CB9")+SC2->C2_ORDSEP)) .AND. CB9->CB9_STATUS=='1'
					//Envia as baixas
				While !CB9->(EOF()) .and. ALLTRIM(CB9->CB9_ORDSEP) == ALLTRIM(SC2->C2_ORDSEP) //.AND. SUPERGETMV('TCP_MANUSI', .f., .f.)

					nRecCb9 := CB9->(RECNO())
					oManusis  := ClassIntManusis():newIntManusis()
					oManusis:cFilZze    := xFilial("ZZE")
					oManusis:cChave     := CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT)
					oManusis:cTipo	    := "E"
					oManusis:cStatus    := "P"
					oManusis:cErro      := ""
					oManusis:cEntidade  := "BXP"
					oManusis:cOperacao  := "I"
					oManusis:cRotina    :=  FunName()
					oManusis:nQtdBaixa  :=  CB9->CB9_QTESEP

					IF oManusis:gravaLog()
						U_MNSINT01(oManusis:cChaveZZE)
					ELSE
						ALERT(oManusis:cErroValid)
					ENDIF

					CB9->(DbSetOrder(11))
					CB9->(dbGoTo(nRecCb9))
					
					RecLock("CB9",.F.)
					CB9->CB9_STATUS := '2'
					CB9->(MsUnlock())
					
					CB9->(DbSkip())
				EndDo

				//atualiza timeline e status das reservas
				oManusis  := ClassIntManusis():newIntManusis()
				oManusis:cFilZze    := xFilial("ZZE")
				oManusis:cChave     := (cAlias)->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN)
				oManusis:cTipo	    := "E"
				oManusis:cStatus    := "P"
				oManusis:cErro      := ""
				oManusis:cEntidade  := "AWF"
				oManusis:cOperacao  := "I"
				oManusis:cRotina    := FunName()
				oManusis:cErroValid := ""
				oManusis:cTxtStat   := "Produtos baixados com sucesso. Ordem de Separação: "+ALLTRIM(SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)

				IF oManusis:gravaLog()
					U_MNSINT03(oManusis:cChaveZZE)
				ELSE
					ALERT(oManusis:cErroValid)
				ENDIF

				DbSelectArea("ZZF")

				ZZF->(DBOrderNickname( "NUMEROOP"))
				IF ZZF->(DbSeek(xFilial("ZZF")+(cAlias)->(C2_NUM+C2_ITEM+C2_SEQUEN)))
					While !ZZF->(EOF()) .AND. ALLTRIM(ZZF->ZZF_OP) == ALLTRIM((cAlias)->(C2_NUM+C2_ITEM+C2_SEQUEN))

						nRecZzf := ZZF->(RECNO())
						oManusis  := ClassIntManusis():newIntManusis()
						oManusis:cFilZze    := xFilial("ZZE")
						oManusis:cChave     := ZZF->ZZF_FILIAL+ZZF->ZZF_OP+ZZF->ZZF_RESERV
						oManusis:cTipo	    := "E"
						oManusis:cStatus    := "P"
						oManusis:cErro      := ""
						oManusis:cEntidade  := "SOP"
						oManusis:cOperacao  := "I"
						oManusis:cRotina    :=  FunName()

						oManusis:cStatOp 	:= "3"

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
			ENDIF
//		endif	
 
 ntotal++

	endif 

	(cAlias)->(DbSkip())
	
end
	
		(cAlias)->(dbCloseArea())
	msginfo("qtd de op's: "+cvaltochar(ntotal)," msginfo ") 

return