#include "protheus.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#include "rwmake.ch"
#include "topconn.ch"

WsService WsFAT004 description "Realiza a busca de informações por funcionário"

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sMAT    		 as string
	wsdata sNOMEF 		 as string
	wsdata sDTURNO 	   	 as string
	wsdata sDCCARGO	 	 as string
	wsdata sDFUNCAO	 	 as string
	wsdata sCCUSTO	 	 as string
	wsData Results   	 as Array of wfRFAT004
		
	// DELCARACAO DO METODOS

wsmethod ProcBuscaFuncionario description "Realiza a busca de informações por funcionário.<br /><br /><b>Parâmetros:</b><br /><font color='red'><b>sMAT</b></font>: Matricula do Funcionario. (string)<br /><font color='red'><b>sNOMEF</b></font>: Nome do Funcionário. (string)<br /><font color='red'><b>sDTURNO</b></font>: Descrição do Turno. (string)<br /><font color='red'><b>sDCCARGO</b></font>: Descrição do Cargo. (string)<br /><font color='red'><b>sDFUNCAO</b></font>: Descrição da Função (string)<br /><br/><b>Resposta: Array Results </b><br /><font color='red'><b>sMATRICULA</b></font>: Numero da Matricula (string).<br/><font color='red'><b>sNOMEFUNC</b></font>: Nome do Funcionário (string).<br/><font color='red'><b>sTURNO</b></font>: Código do Turno (string).<br/><font color='red'><b>sDESCTUR</b></font>: Descrição do Turno (string).<br/><font color='red'><b>sCARGO</b></font>: Código do Cargo(string).<br/><font color='red'><b>sDESCCAR</b></font>: Descrição do Cargo (string).<br/><font color='red'><b>sFuncao</b></font>: Codigo da Função (string).<br/><font color='red'><b>sDESCFUN</b></font>: Descrição da Função (string).<br/>"

endwsservice

wsStruct wfRFAT004

	wsdata sMATRICULA  	 as string
	wsdata sNOMEFUNC 	 as string
	wsdata sTURNO 	 	 as string
	wsdata sDESCTUR 	 as string
	wsdata sCARGO	 	 as string
	wsdata sDESCCAR	 	 as string
	wsdata sFUNCAO	 	 as string
	wsdata sDESCFUN	 	 as string
	wsdata sCCUSTO	 	 as string

EndWsStruct

wsmethod ProcBuscaFuncionario wsreceive sMAT, sNOMEF, sDTURNO, sDCCARGO, sDFUNCAO, sCCUSTO wssend Results wsservice WsFAT004
local lRet 		:= .F.                                                        
Local nCont 	:= 1
	
	cQuery := " SELECT RA_MAT, RA_NOME, RA_CODFUNC, RA_CARGO, RA_TNOTRAB,RJ_DESC,R6_DESC,Q3_DESCSUM,RA_CC  "
	cQuery += " FROM "+RetSqlName('SRA')+" SRA "

	IF !Empty(Alltrim(sDFUNCAO))	
		cQuery += " INNER JOIN "+RetSqlName('SRJ')+" SRJ ON " //FUNCAO
		cQuery += " 	RJ_FILIAL = '"+xFilial('SRJ')+"' AND RJ_FUNCAO = RA_CODFUNC "
		cQuery += " AND RJ_DESC LIKE '%"+Alltrim(Upper(sDFUNCAO))+"%' "
	Else
		cQuery += " LEFT OUTER JOIN "+RetSqlName('SRJ')+" SRJ ON " //FUNCAO
		cQuery += " 	RJ_FILIAL = '"+xFilial('SRJ')+"' AND RJ_FUNCAO = RA_CODFUNC "
	EndIf                               
	cQuery += "  AND SRJ.D_E_L_E_T_ != '*' "
		
	IF !Empty(Alltrim(sDTURNO))
		cQuery += " INNER JOIN "+RetSqlName('SR6')+" SR6 ON " // TURNO
		cQuery += " 	R6_FILIAL = '"+xFilial('SR6')+"' AND R6_TURNO = RA_TNOTRAB "
		cQuery += " AND R6_DESC LIKE '%"+Alltrim(Upper(sDTURNO))+"%' "              
	Else
		cQuery += " LEFT OUTER JOIN "+RetSqlName('SR6')+" SR6 ON " // TURNO
		cQuery += " 	R6_FILIAL = '"+xFilial('SR6')+"' AND R6_TURNO = RA_TNOTRAB "	
	EndIf                                               
	cQuery += "  AND SR6.D_E_L_E_T_ != '*' "

	IF !Empty(Alltrim(sDCCARGO))		
		cQuery += " INNER JOIN "+RetSqlName('SQ3')+" SQ3 ON " // CARGO
		cQuery += " 	Q3_FILIAL = '"+xFilial('SQ3')+"' AND Q3_CARGO = RA_CARGO "
		cQuery += " AND Q3_DESCSUM LIKE '%"+Alltrim(Upper(sDCCARGO))+"%' "        
	Else
		cQuery += " LEFT OUTER JOIN "+RetSqlName('SQ3')+" SQ3 ON " // CARGO
		cQuery += " 	Q3_FILIAL = '"+xFilial('SQ3')+"' AND Q3_CARGO = RA_CARGO "
	EndIf                                   
	cQuery += "  AND SQ3.D_E_L_E_T_ != '*' "	
	
	cQuery += " WHERE RA_FILIAL = '"+xFilial('SRA')+"' AND RA_SITFOLH != 'D' "
	IF !Empty(Alltrim(sMAT))
		cQuery += " AND RA_MAT = '"+Alltrim(sMAT)+"' "
	EndIf
	IF !Empty(Alltrim(sNOMEF))
		cQuery += " AND RA_NOME LIKE '"+Alltrim(Upper(sNOMEF))+"%' "
	EndIf
	IF !Empty(Alltrim(sCCUSTO))
		cAuxCC := Alltrim(sCCUSTO)
		cQuery += " AND RA_CC IN ('"+STRTRAN(cAuxCC,",","','")+"') "
	EndIf
	cQuery += "  AND SRA.D_E_L_E_T_ != '*' "

	TCQUERY cQuery NEW ALIAS "QRYFUNC"
	DbSelectArea("QRYFUNC")
	QRYFUNC->(DbGoTop())
	
	IF QRYFUNC->(EOF())						
		aAdd(Self:Results,WsClassNew("wfRFAT004"))
		Self:Results[1]:sMATRICULA	:= '000000'
		Self:Results[1]:sNOMEFUNC  	:= 'FUNCIONARIO NAO LOCALIZADO'
		Self:Results[1]:sTURNO  	:= ''
		Self:Results[1]:sDESCTUR  	:= ''
		Self:Results[1]:sCARGO  	:= ''
		Self:Results[1]:sDESCCAR  	:= ''
		Self:Results[1]:sFUNCAO  	:= ''
		Self:Results[1]:sDESCFUN  	:= ''		
		Self:Results[1]:sCCUSTO  	:= ''
	EndIf


	While !QRYFUNC->(EOF())						
		aAdd(Self:Results,WsClassNew("wfRFAT004"))

		Self:Results[nCont]:sMATRICULA	:= Alltrim(QRYFUNC->RA_MAT)
		Self:Results[nCont]:sNOMEFUNC  	:= Alltrim(QRYFUNC->RA_NOME)
		Self:Results[nCont]:sTURNO  	:= Alltrim(QRYFUNC->RA_TNOTRAB)
		Self:Results[nCont]:sDESCTUR  	:= Alltrim(QRYFUNC->R6_DESC)
		Self:Results[nCont]:sCARGO  	:= Alltrim(QRYFUNC->RA_CARGO)
		Self:Results[nCont]:sDESCCAR  	:= Alltrim(QRYFUNC->Q3_DESCSUM)
		Self:Results[nCont]:sFUNCAO  	:= Alltrim(QRYFUNC->RA_CODFUNC)
		Self:Results[nCont]:sDESCFUN  	:= Alltrim(QRYFUNC->RJ_DESC)
		Self:Results[nCont]:sCCUSTO  	:= Alltrim(QRYFUNC->RA_CC)
		nCont++  
		QRYFUNC->(DbSkip())	
	EnddO
	QRYFUNC->(DbCloseArea())

return .T.
