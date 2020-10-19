#include "rwmake.ch"
#include "tk.ch"

user function _WFW120P()

Local aArea      := GetArea()
Local aAprovador := {}
Local cOrigem    := ''
Local cAprovador := ''
Local nVlrTotal  := 0
Local nSC7ItFrSg := 0
Local nDesconto  := 0

	Local oProcess
	Local oHtml

begin sequence
	oProcess := TWFProcess():New( "000001", "Requisição de Aprovação de Pedido de Compras" )
	oProcess:NewTask( "000001", "\WORKFLOW\HTML\wfw120p1.HTM" )
	oProcess:cSubject := "Requisição de Aprovação de Pedido de Compras "+SC7->C7_NUM
	oProcess:bReturn := "U_PC001R()"
	oProcess:bTimeOut := {{"U_PC001T()",1,0,0}}
	oProcess:fDesc := "Pedido de Compras No "+SC7->C7_NUM
	
	oHTML := oProcess:oHTML
	oHTML:ValByName('cPC',SC7->C7_NUM)
	oHTML:ValByName('cComprador',trim(Subs(cUsuario,7,15))+"-"+Posicione("SY1",3,xFILIAL("SY1")+__CUSERID,"Y1_NOME"))
	oHTML:ValByName('cEmissao',SC7->C7_EMISSAO)
	oHTML:ValByName('cFornecedor',Posicione("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"))
	oHTML:ValByName('cCondPagto',POSICIONE("SE4",1,xFILIAL("SE4")+SC7->C7_COND,"E4_DESCRI"))
	cPC := SC7->C7_NUM
	SC7->(dbsetorder(1))
	SC7->(dbseek(xFILIAL("SC7")+cPC))
	nVlrTotal:=0
	nSC7ItFrSg:=0
	nDesconto:=0
	while !SC7->(EOF()) .and. SC7->C7_FILIAL==xFILIAL("SC7") .and. SC7->C7_NUM==cPC
		cPRODUTO	:= 	SC7->C7_PRODUTO
		nContador := 0
		while !SC7->(EOF()) .and. SC7->C7_FILIAL==xFILIAL("SC7") .and. SC7->C7_NUM==cPC .and. ;
			SC7->C7_PRODUTO==cPRODUTO
			aadd((oHtml:ValByName( "produto.codigo")),SC7->C7_PRODUTO)
			aadd((oHtml:ValByName( "produto.descricao" )),SC7->C7_DESCRI)
			aadd((oHtml:ValByName( "produto.quant" )),transf(SC7->C7_QUANT,U_TKSX3("C7_QUANT")[MASCARA]))
			aadd((oHtml:ValByName( "produto.preco" )),transf(SC7->C7_PRECO,U_TKSX3("C7_PRECO")[MASCARA]))
			aadd((oHtml:ValByName( "produto.total" )),transf(SC7->C7_TOTAL+SC7->C7_VALIPI,U_TKSX3("C7_TOTAL")[MASCARA]))
			nVlrTotal +=(SC7->C7_TOTAL+SC7->C7_VALIPI)
			nSC7ItFrSg+=(SC7->C7_SEGURO+SC7->C7_VALFRE)
			nDesconto +=SC7->C7_VLDESC
			WFSalvaID('SC7','C7_WFID',oProcess:fProcessID)
			SC7->(dbskip(1))
		Enddo
	enddo
	
	oHTML:ValByName('cTotal',transf(nVlrTotal,U_TKSX3("C7_TOTAL")[MASCARA]))
	oHTML:ValByName('cFrSg',transf(nSC7ItFrSg,U_TKSX3("C7_TOTAL")[MASCARA]))
	//		oHTML:ValByName('cDesconto',transf(nSC7ItFrSg,U_TKSX3("C7_TOTAL")[MASCARA]))
	oHTML:ValByName('cDesconto',transf(nDesconto,U_TKSX3("C7_TOTAL")[MASCARA]))		// MSG EM 14/01/05.
	oHTML:ValByName('cTotGer',transf(nVlrTotal+nSC7ItFrSg-nDesconto,U_TKSX3("C7_TOTAL")[MASCARA]))
	oHtml:ValByName( "RBAPROVA" , "Sim" )
	oProcess:ClientName( Subs(cUsuario,7,15) )
	SAK->(dbseek(xFilial("SAK")))
	cAprovador:=""
	oProcess:cTo := U_Aprovador(__CUSERID)
	oProcess:UserSiga := __CUSERID
	oProcess:Start()
	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100001')
	oProcess:Free()
end sequence

RestArea(aArea)

return TRUE

/*
!FNC! PC001R()
!OBJ! Tratar retorno do workflow de pedido de compra
!PAR! Nenhum
!AUT! HMO - COMSIS
!OBS!
*/
User Function PC001R(oProcess)
begin sequence
//Verifica se foi aprovado ou não
//Conout("Verifica se foi aprovado ou nao")
If oProcess:oHtml:RetByName('RBAPROVA') == "Sim"
	
	//Conout("==>>PROCESSO DE APROVADO")
	
	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100002')
	SCR->(dbsetorder(2))
	//	if SCR->(dbseek(xFilial("SCR")+oProcess:oHtml:RetByName('cPC')))
	If SCR->(dbseek(xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('cPC')))
		SCR->(RecLock("SCR",FALSE))
		SCR->CR_DataLib := dDataBase
		SCR->CR_Obs     := ""
		SCR->CR_STATUS  := "03"
		SCR->(MsUnLock())
	endif
	SC7->(DBSETORDER(1))
	SC7->(dbseek(xFilial("SC7")+oProcess:oHtml:RetByName('cPC')))
	while !SC7->(EOF()) .and. SC7->C7_Num == oProcess:oHtml:RetByName('cPC')
		SC7->(RecLock("SC7",FALSE))
		SC7->C7_ConaPro := "L"
		SC7->(MsUnLock())
		SC7->(DBSkip())
	enddo
ElseIf oProcess:oHtml:RetByName('RBAPROVA') <> "Sim"
	
	//Conout("==>>PROCESSO DE REPROVADO")
	
	RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100003')
	SCR->(dbsetorder(2))
	//	If SCR->(dbseek(xFilial("SCR")+oProcess:oHtml:RetByName('cPC')))
	If SCR->(dbseek(xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('cPC')))
		
		//Conout("==>>PROCESSO DE REPROVADO 01")
		
		SCR->(RecLock("SCR",FALSE))
		//SCR->CR_DataLib := ctod("")
		//SCR->CR_Obs     := ""
		//SCR->CR_STATUS  := "01"
		SCR->CR_DataLib := dDataBase
		SCR->CR_Obs     := oProcess:oHtml:RetByName('cMOTIVO')
		SCR->CR_STATUS  := "04"
		SCR->(MsUnLock())
	endif
	SC7->(DBSETORDER(1))
	SC7->(dbseek(xFilial("SC7")+oProcess:oHtml:RetByName('cPC')))
	while !SC7->(EOF()) .and. SC7->C7_Num == oProcess:oHtml:RetByName('cPC')
		
		//Conout("==>>PROCESSO DE REPROVADO 02")
		
		SC7->(RecLock("SC7",FALSE))
		SC7->C7_ConaPro := "B"
		SC7->(MsUnLock())
		SC7->(DBSkip())
	enddo
Endif
oProcess:Finish()
oProcess:Free()
end sequence
return TRUE

/*
!FNC! PC001T(oProcess)
!OBJ! Tratar timeout do workflow de pedido de compra
!PAR! Nenhum
!AUT! HMO - COMSIS
!OBS!
*/
User Function PC001T(oProcess)
begin sequence
RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'100004')
oProcess:Finish()
oProcess:Free()
end sequence
return TRUE

/*
!FNC! Aprovador(Comprador)
!OBJ! retorna nome do aprovador
!PAR! Comprador Código do comprador que emitiu o Pc
!RET! e-mail do aprovador
!AUT! HMO - COMSIS
!OBS!
*/
user function Aprovador(Comprador)
local eMail:="",cGrupoAprv
begin sequence
cGrupoAprv:=Posicione("SY1",3,xFILIAL("SY1")+Comprador,"Y1_GRAPROV")
SAL->(dbsetorder(2))
if SAL->(dbseek(xFilial("SAL")+cGrupoAprv))
	while !SAL->(EOF()) .and. xFilial("SAL")==SAL->AL_FILIAL .and. SAL->AL_COD == cGrupoAprv
		eMail+=USRRETMAIL(SAL->AL_USER)+";"
		SAL->(dbskip())
	enddo
endif
eMail:=substr(eMail,1,len(eMail)-1) //retirar o último ;
end sequence
/*
while !SAK->(EOF()) .and. SAK->AK_FILIAL==xFILIAL("SAK")
if (nVlrTotal+nSC7ItFrSg)>SAK->AK_LIMMIN .and. (nVlrTotal+nSC7ItFrSg)<=SAK->AK_LIMMAX
cAprovador+=trim(USRRETMAIL(SAK->AK_USER))+";"
endif
SAK->(dbskip())
enddo
*/
return eMail
