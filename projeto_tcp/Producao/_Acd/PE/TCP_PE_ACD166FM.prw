#include "protheus.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#include "Totvs.ch"  

/*{Protheus.doc} ACD166FM
Ponto de Entrada após o encerramento da Ordem de Separação

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
*/
user function ACD166FM()

	Local lTotal := .T.

	Local aAreas := {}
	Local cTCP_MAILTI  := SuperGetMV("TCP_MAILTI",.F.,"walter.junior@tcp.com.br;deosdete.pereira@totvspartners.com.br")
	Local cNomLog   := NomeAutoLog()
	Local _lIntManu :=  SUPERGETMV( "TCP_MANUSI", .f., .F. )

	Private cRequisi := ""
	Private cxOp 	 := ""
	Private cxConta  := ""
	Private cxCc     := ""
	Private cxItem   := ""
	
	//Conout("ordem NOVO -> " + CB7->CB7_OP)
	
	If Type("cNomLog") <> "C"
		 cNomLog := ""
	EndIf  

	If lMSErroAuto // Ser verdadeiro nao consegui gerar o movimento no estoque

		VTYesNo("ERRO GRAVE! Movimento estoque Ord Sep "+CB7->CB7_ORDSEP+" nao realizado. Avise ao gestor! Sair?","ERRO!!! ",.T.)
		SendMail("<!DOCTYPE html><html><body><p><font face='verdana' size='2'>Sr. Administrador do ERP Protheus: </font></p><p><font face='verdana' size='2'>ERRO GRAVE! Movimento estoque Ord Sep "+;
				CB7->CB7_ORDSEP+" nao realizado</font></p></body></html>",cTCP_MAILTI,"Log de Erro",cNomLog)

	ELSE
		//se for OP
		IF ! Empty(CB7->CB7_OP)
		    // Atualizar o status da TNF (EPI)
		    statusEPI()
		    excluiSCP_EPI()
			
			ZDW->( dbSetOrder(2) )
			ZDW->( dbSeek( xFilial("ZDW") + CB7->CB7_OP ) )

			IF ZDW->( Found() )
				cRequisi := ZDW->ZDW_REQUIS 
				
				IF ZDW->ZDW_TIPO == "2" .OR. ZDW->ZDW_TIPO == "3"
					cxCc     := ZDW->ZDW_CC  
				ELSEIF ZDW->ZDW_TIPO == "1"
					cxCc     := GetMV("TCP_CCUSTO")  
				ENDIF
				
				IF ZDW->ZDW_TIPO == "2" .OR. ZDW->ZDW_TIPO == "3"
					cxConta     := GTRIGGER(ZDW->ZDW_ITEMCT,POSICIONE("SB1",1,xFilial("SB1")+ZDW->ZDW_EPI,"B1_GRUPO")) 
				ELSEIF ZDW->ZDW_TIPO == "1"
					cxConta     := GetMV("TCP_CONTA")    
				ENDIF
				
				IF  ZDW->ZDW_TIPO == "2" .OR. ZDW->ZDW_TIPO == "3"
					cxItem     := ZDW->ZDW_ITEMCT  
				ELSEIF ZDW->ZDW_TIPO == "1"
					cxItem     := GetMV("TCP_CONTAI")    
				ENDIF   
			Else
				
				SC2->( dbSetOrder(1) )
				SC2->( dbSeek( xFilial("SC2") + CB7->CB7_OP ) )

				cxConta  := SC2->C2_XCONTA 
				cxCc     := SC2->C2_CC  
				cxItem   := SC2->C2_ITEMCTA
				
				cRequisi := "000000"
				
				//Conout("nao achou")
			EndIF
			aEval({"CB7","SD3","SC2","SD4","SB1","SB2"}, {|alias| aAdd(aAreas, GetArea(alias))})

			//Conout("achou -> " + CB7->CB7_OP)

			SD4->( dbSetOrder(2) )
			SD4->( dbSeek( xFilial("SD4") + CB7->CB7_OP ) )

			lTotal := SD4->( Found() )


			While ! SD4->( Eof() ) .And. alltrim(SD4->(D4_FILIAL+D4_OP)) == alltrim(xFilial("SD4") + CB7->CB7_OP)
				IF SD4->D4_QUANT != 0
					lTotal := .F.
				EndIF
				SD4->(dbSkip())
			EndDO

			IF lTotal .AND. CB7->CB7_STATPA != "1"

				Private lMsErroAuto := .F., lMsHelpAuto := lAutoErrNoFile := .T.

				begin transaction
				
				cxOp := CB7->CB7_OP
				
				//aponta producao parcial
				IF apontaProducao()
					//requisita o que apontou
					IF requisitaProducao()
						//e encerra a ordem de producao
						IF !encerraOrdem()
							//Conout(" -> erroauto no encerramento")
							MyMostraErro("Encerramento")
						EndIF
						
						//Atualiza a movimentação, para preencher o número da OP,
						RecLock("SD3",.F.)
						SD3->D3_OP := CB7->CB7_OP
						SD3->(msUnlock())
						
						xupdsd3() // Confirmar gravacao dos dados na SD3
					Else
						//Conout(" -> erroauto na requisição")
						MyMostraErro("Requisicao")
					EndIF
									
				Else
					//Conout(" -> erroauto no apontamento")
					MyMostraErro("Apontamento")
				EndIF
				
				end transaction
				
				DbSelectArea("CB9")
				CB9->(DbSetOrder(11))
				IF CB9->(MsSeek(xFilial("CB9")+CB7->CB7_ORDSEP)) .AND. !EMPTY(CB7->CB7_XOM)
					//Envia as baixas
					While !CB9->(EOF()) .AND. _lIntManu .AND. ALLTRIM(CB9->CB9_ORDSEP) == ALLTRIM(CB7->CB7_ORDSEP)
				
						nRecCb9 := CB9->(RECNO())
						oManusis  := ClassIntManusis():newIntManusis()    
						oManusis:cFilZze    := xFilial("ZZE")
						oManusis:cChave     := CB9->(CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)
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
						
						CB9->(DbSkip())
					EndDo
					
					//atualiza timeline e status das reservas
					oManusis  := ClassIntManusis():newIntManusis()    
					oManusis:cFilZze    := xFilial("ZZE")
					oManusis:cChave     := CB7->CB7_FILIAL+CB7->CB7_OP
					oManusis:cTipo	    := "E"
					oManusis:cStatus    := "P"
					oManusis:cErro      := ""
					oManusis:cEntidade  := "AWF"
					oManusis:cOperacao  := "I"
					oManusis:cRotina    := FunName()
					oManusis:cErroValid := ""
					oManusis:cTxtStat   := "Produtos baixados com sucesso. Ordem de Separação: "+ALLTRIM(CB7->CB7_OP)
					
					IF oManusis:gravaLog()  
						U_MNSINT03(oManusis:cChaveZZE)              
					ELSE
						ALERT(oManusis:cErroValid)
					ENDIF  
					
					DbSelectArea("ZZF")
					  
					ZZF->(DBOrderNickname( "NUMEROOP"))
					IF ZZF->(DbSeek(xFilial("ZZF")+CB7->CB7_OP))
						While !ZZF->(EOF()) .AND. ALLTRIM(ZZF->ZZF_OP) == ALLTRIM(CB7->CB7_OP)
				
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
							//
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
				
			EndIF
						
			aEval(aAreas, {|area| RestArea(area) })
			
		EndIF
	EndIf
return


static function statusEPI()
    cQuery := " SELECT ZDW_REQUIS, ZDW_EPI, ZDW_NUMERO, ZDW_DATA "
	cQuery += " FROM " + RetSqlName("ZDW") + " ZDW "
	cQuery += " WHERE ZDW_FILIAL = '" + xFilial("ZDW") + "'"
    cQuery += "   AND ZDW_OP = '" + CB7->CB7_OP + "' "
	cQuery += "   AND D_E_L_E_T_ <> '*' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
	
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)                                               
    dbSelectArea("QRY")
    QRY->(dbGoTop())     
	
	While QRY->(!Eof()) 
	    //cria o update para atualizar todos os registros processados em um unico comando
	    cUpdate := " UPDATE " + retsqlname("TNF") + " "   
	    cUpdate += " set TNF_INDDEV = '2' "
	    cUpdate += " where TNF_FILIAL = '" + xFilial('TNF') + "' "
	    cUpdate += "   AND TNF_CODEPI = '" + QRY->ZDW_EPI + "' "
	    //cUpdate += "   AND TNF_DTENTR = '" + QRY->ZDW_DATA + "' "
	    cUpdate += "   AND TNF_MAT = '" + QRY->ZDW_REQUIS + "' "
		cUpdate += "   AND TNF_YNUMRE = '" + QRY->ZDW_NUMERO + "' "
		cUpdate += "   AND D_E_L_E_T_ <> '*' "
	            
	    cUpdate := UPPER(cUpdate)
	    
	    nUpdate := TcSqlExec(cUpdate)
        QRY->(dbSkip())
	EndDo
 	
    return
     
Static Function excluiSCP_EPI()
    cQuery := " SELECT DISTINCT TNF_NUMSA "
	cQuery += " FROM " + RetSqlName("TNF") + " TNF, "
	cQuery += "      " + RetSqlName("ZDW") + " ZDW "
	cQuery += " WHERE ZDW_FILIAL = '" + xFilial("ZDW") + "'"
    cQuery += "   AND ZDW_OP = '" + CB7->CB7_OP + "' "
	cQuery += "   AND ZDW.D_E_L_E_T_ <> '*' "
	cQuery += "   AND ZDW_FILIAL = TNF_FILIAL "
    cQuery += "   AND ZDW_EPI = TNF_CODEPI  "
//	cQuery += "   AND ZDW_DATA = TNF_DTENTR  "
	cQuery += "   AND ZDW_REQUIS = TNF_MAT "
	cQuery += "   AND ZDW_NUMERO = TNF_YNUMRE"
	cQuery += "   AND TNF.D_E_L_E_T_ <> '*' "

    If Select("QRY") > 0
        QRY->(dbCloseArea())
    EndIf
	
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRY",.F.,.T.)                                               
    dbSelectArea("QRY")
    QRY->(dbGoTop())     
	
	While QRY->(!Eof()) 
		If !empty(QRY->TNF_NUMSA)
		    // Deletar a Solicitação ao armazem gerada pois o processo de S.A. não é usada pela TCP.
		 	//cria o update para atualizar todos os registros processados em um unico comando
		    cUpdate := " update " + retsqlname("SCP") + " "   
		    cUpdate += " set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		    cUpdate += " where CP_FILIAL = '" + xFilial('SCP') + "' "
		    cUpdate += "   and CP_NUM = '" + QRY->TNF_NUMSA + "' "

		    cUpdate := UPPER(cUpdate)
		    
		    nUpdate := TcSqlExec(cUpdate)
	    EndIf
        QRY->(dbSkip())
	EndDo

    return
   
	
/*/{Protheus.doc} apontaProducao
função para apontamento de produção

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
static function apontaProducao()

	Local nQuantidade := 1
	Local aMata250    := {}

	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2") + CB7->CB7_OP ) )

	aAdd( aMata250, {"D3_TM"      , GetMV("TCP_TPPRD")       , nil })
	aAdd( aMata250, {"D3_OP"      , CB7->CB7_OP              , nil })
	aAdd( aMata250, {"D3_DOC"     , GetSXENum("SD3","D3_DOC"), nil })
	aAdd( aMata250, {"D3_QUANT"   , nQuantidade              , nil })
	aAdd( aMata250, {"D3_EMISSAO" , dDataBase                , nil })
	aAdd( aMata250, {"D3_PARCTOT" , "P"                      , nil })
	aAdd( aMata250, {"D3_CC"      , cxCc              , nil }) // 4101020116	
	aAdd( aMata250, {"D3_CONTA"   , cxConta         , nil }) // 4101020116     
	aAdd( aMata250, {"D3_ITEMCTA" , cxItem       , ".T." }) //A800    
	aAdd( aMata250, {"D3_REQUISI" , cRequisi         , nil })

	MsExecAuto({|x,y|Mata250(x,y)},aMata250,3)

	IF lMSErroAuto
		VarInfo("aMata250",aMata250)
	EndIF
	
return ! lMSErroAuto



/*/{Protheus.doc} requisitaProducao
função para requisição contra op

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
static function requisitaProducao()

	Local nQuantidade := 1
	Local aMata240    := {}

	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2") + CB7->CB7_OP ) )

	aAdd( aMata240, {"D3_TM"      , GetMV("TCP_TPREQ")         , nil })
	aAdd( aMata240, {"D3_COD"     , SC2->C2_PRODUTO            , nil })
	aAdd( aMata240, {"D3_OP"      , CB7->CB7_OP                , nil })
	aAdd( aMata240, {"D3_DOC"     , GetSXENum("SD3","D3_DOC")  , nil })
	aAdd( aMata240, {"D3_LOCAL"   , SC2->C2_LOCAL              , nil })
	aAdd( aMata240, {"D3_QUANT"   , nQuantidade              , nil })
	aAdd( aMata240, {"D3_EMISSAO" , dDataBase                , nil })	
	aAdd( aMata240, {"D3_CC"      , cxCc                 , nil })	
	aAdd( aMata240, {"D3_CONTA"   , cxConta                    , nil }) // 4101020116     
	aAdd( aMata240, {"D3_ITEMCTA" , cxItem                  , ".T." }) //A800    
	aAdd( aMata240, {"D3_REQUISI" , cRequisi          , nil })

	MSExecAuto( {|x, y| Mata240(x, y)}, aMata240, 3 )

	IF lMSErroAuto
		VarInfo("aMata250",aMata240)
	EndIF


return ! lMSErroAuto



/*/{Protheus.doc} encerraOrdem
Função para Encerramento da OP

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
static function encerraOrdem()

	Local aMata250 := {}

	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2") + CB7->CB7_OP ) )

	SD3->( dbSetOrder(1) )
	SD3->( dbSeek( xFilial("SD3") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_PRODUTO) ) )

	//e percore todos, porque não fica posicionado no apontamento como precisamos para encerrar
	While ! SD3->( Eof() ) .And. SD3->(D3_FILIAL+D3_OP+D3_COD) == SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_PRODUTO)

		//se estiver estornado
		IF SD3->D3_CF != "PR0" .or. SD3->D3_ESTORNO == "S"
			//proximo apontamento
			SD3->(dbSkip())
		Else

			//quando achar o movimento de produção
			aAdd(aMata250, {"D3_COD"    , SC2->C2_PRODUTO, Nil})
			aAdd(aMata250, {"D3_OP"     , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),Nil})

			//chamao executo para o encerramento (opcao 7)
			MSExecAuto({ |x,y| Mata250(x,y)}, aMata250, 7)

			//encerra a função aqui
			Return ! lMsErroAuto
		EndIF
	EndDO

return .F.


static function MyMostraErro(cLocal)
	
	Local _i
	
	aLog := GetAutoGRLog()
    cMensagem := ""
    
	for _i := 1 to len(aLog)
		cMensagem +=  CHR(10) + CHR(13) + aLog[_i]
    next _i
                
    //conout (cmensagem)
    
	VTAlert("Erro na rotina automatica de "+cLocal+". "+cMensagem,"Aviso",.T.,6000)

return

//----------------------------------------------------------------------------
// UPDATE tabela SD3 dos registros referente a OP em questão
//para reconfirmar os campos Conta Contabil, Item contabil, Centro de Custo e Requisitante
//-----------------------------------------------------------------------------
Static Function xupdsd3()

dbSelectArea("SD3")
dbSetOrder(1)
DbGoTop()
dbSeek( xFilial("SD3") + CB7->CB7_OP )

While !Eof() .AND. SD3->D3_OP == CB7->CB7_OP

	If  Alltrim(SD3->D3_COD) == "MANUTENCAO" .AND. SD3->D3_CF == "RE0"     
		//Atualiza SD3
		RecLock("SD3",.F.)
		SD3->D3_CC      := cxCc
		SD3->D3_CONTA   := cxConta   
		SD3->D3_ITEMCTA := cxItem 
		SD3->D3_REQUISI := cRequisi
		//SD3->D3_OP := ""						
		MsUnLock("SD3")
		SD3->(dbSkip())
	Else
			//Atualiza SD3
		RecLock("SD3",.F.)
		SD3->D3_CC      := cxCc
		SD3->D3_CONTA   := cxConta  
		SD3->D3_ITEMCTA := cxItem 
		SD3->D3_REQUISI := cRequisi
		MsUnLock("SD3")
		SD3->(dbSkip())
	Endif	
Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ SendMail  | Autor ³ Deosdete P.Silva     ³ Data ³08/11/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia email conforme parametros recebidos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SendMail(cMensagem,cPara,cAssunto,cArquivo)
Local oMail
Local oMessage

Local cSMTPServer	:= GetMV("MV_RELSERV")
Local cSMTPUser		:= GetMV("MV_RELACNT")
Local cSMTPPass		:= GetMV("MV_RELPSW")
Local cMailFrom		:= GetMV("MV_RELFROM")
Local lUseAuth		:= GetMv("MV_RELAUTH")


Local lRetMail 	:= .T.

oMail := TMailManager():New()
if ( GetMv("MV_RELTLS") )			
	oMail:SetUseTLS(.T.)
endif
if ( GetMv("MV_RELSSL") )
	oMail:SetUseSSL(.T.)
endif

oMail:Init( "", Left( cSMTPServer, Len(cSMTPServer)-4) , cSMTPUser, cSMTPPass, 0, Val(Right(cSMTPServer,3)) )

//	Establece timeout de 1 minuto para el servidor SMTP
If (oMail:SetSmtpTimeOut(120) != 0)
	MsgStop("Sem Conexão  - TimeOut para o servidor SMTP","Problema")
	Return .F.
EndIf
	         
//	Establece la conexión SMTP
nErro := oMail:SmtpConnect()
If (nErro != 0)
	MsgStop("Sem Conexão com o servidor SMTP","Problema")
	Return .F.
Endif
	
If nErro <> 0
	lRetMail 	:= .F.
End If

If lUseAuth
	nErro := oMail:SmtpAuth(cSMTPUser ,cSMTPPass)
      
	If nErro <> 0
		// Recupera erro ...
		cMAilError := oMail:GetErrorString(nErro)
		DEFAULT cMailError := "***UNKNOW***"
		//Conout("Erro de Autenticacao "+str(nErro,4)+" ("+cMAilError+")","AKRON")
		lRetMail := .F.
	EndIf
EndIf

If lRetMail
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cMailFrom
	oMessage:cTo      := alltrim(cPara)
	oMessage:cSubject := cAssunto
	oMessage:cBody    := cMensagem
	oMessage:MsgBodyType( "text/html" )
	If !Empty(cArquivo)
		oMessage:AttachFile("\system\"+cArquivo)
	End If
	
	nErro := oMessage:Send( oMail )
	
	oMail:SMTPDisconnect()           
	
EndIf

Return


Static Function GTRIGGER(cItem,cGrupo)

	Local aAreaSD3 	:= SD3->(GetArea())
	Local cRet		:= ""

	Private M->D3_ITEMCTA 	:= cItem
	Private M->D3_GRUPO		:= cGrupo
	Private M->D3_CONTA 	:= Criavar("D3_CONTA")

	If ExistTrigger("D3_ITEMCTA") 
		RunTrigger(1,,,,"D3_ITEMCTA")
	Endif

	cRet := M->D3_CONTA

	RestArea(aAreaSD3)

Return cRet
