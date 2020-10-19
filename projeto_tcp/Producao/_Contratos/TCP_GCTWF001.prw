#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#include "fileio.ch"

#DEFINE CRLF (chr(13)+chr(10))


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
! Versão           ! Protheus 11                                             !
+------------------+---------------------------------------------------------+
! Tipo             ! WKF                                                     !
+------------------+---------------------------------------------------------+
! Modulo           ! GCT                                                     !
+------------------+---------------------------------------------------------+
! Nome             ! GCTWF001                                                !
+------------------+---------------------------------------------------------+
! Descricao        ! Disparo de e-mails informando fim da vigencia.          !
+------------------+---------------------------------------------------------+
! Autor            ! HUGO                                                    !
+------------------+---------------------------------------------------------+
! Data de Criacao  ! 17/03/2015                                              !
+------------------+---------------------------------------------------------+

*/

// Preencher no schedule U_GCTWF001("02","01") e compilar e configurar.

User Function GCTWF001() 
 
   	OpenSM0()	
	RPCSETENV('02', '01',)
	EnviCt('02', '01')   	


Return
User Function GCTWF002() 
 
   	OpenSM0()	
	RPCSETENV('03', '01',)
	EnviCt('03', '01')   	
    
	

Return

Static Function EnviCt(cEmpTCP, cFilTCP)
	
	//Verifica se o parametro de envio de e-mail esta como True
	Local lEnvMail	:= ''
	Local cLog 		:= ''	
	Private cAlias := 'TRBCN9' //GetNewAlias()	
	If Type('cEmpTCP')=='U'
		Default cEmpTCP := ''
	Endif
	
	If Type('cFilTCP')=='U'
		Default cFilTCP := ''
	Endif
	
	If Empty(Alltrim(cEmpTCP))
		cEmpTCP := '02'
	Endif
	If Empty(Alltrim(cFilTCP))
		cFilTCP := '01'
	Endif
	
	BuscaCont()
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	ncont:=0
	While !(cAlias)->(EOF())  
		ncont++
	   	EnvWFPCO(UsrRetMail ( (cAlias)->CNN_USRCOD ), (cAlias)->CN9_NUMERO, DTOC(STOD((cAlias)->CN9_DTFIM)),"Fim de vigencia de contrato: "+(cAlias)->CN9_DESCRI)		
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(DbCloseArea())
	
Return

/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! BuscaDados                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Query de busca os contratos a vencer.                   !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function BuscaCont()
	
	Local nPeriodo := SuperGetMv('MV_XDIAGCT', .F., 60)
	Local dDataFim := dDAtaBase + nPeriodo
	
	If SELECT("TRBNC9") > 0
		TRBNC9->(DbCloseArea())
	EndIf
			
		cWhen:="%	CN9_DTFIM BETWEEN '" + DTOs(dDAtaBase) + "'  AND  '" +DTOs(dDataFim) + "' %"
		
		
	BeginSql Alias cAlias

		SELECT CN9_NUMERO, CN9_REVISA, CN9_DTFIM,CNN_USRCOD,CN9_DESCRI
		FROM %TABLE:CN9%  CN9
		INNER JOIN %TABLE:CNN%  CNN
			ON CNN_FILIAL = CN9_FILIAL
			AND CNN_CONTRA = CN9_NUMERO
			AND CNN.%NOTDEL%
		WHERE
	    %exp:cWhen%
		AND CN9_SITUAC = %EXP:'05'%
		AND CN9.%NOTDEL%
		
		
	EndSql
	
Return


/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! EnvWFPCO                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Envia WorkFlow PCO.                                     !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function EnvWFPCO(cMailTo, cContra, cData, cAssunto)
	
	// Localiza o(s) aprovador(es) do nível 1
	Local nValIPI 	:= 0
	Local nTotAux 	:= 0	
	//Local cAssAux	:= "Fim de vigencia de contrato: "
	Local cTitulo	:= cAssunto
	Local cHtmlCon	:= ""	
	Local cLinkMsg 	:= ""
	Local lStyle := .T.
	
	oProc := TWFProcess():New("GCT","GCT")	
	oProc:NewTask("PCO2", "\WORKFLOW\HTML\FIM_CONTRATO_GCT.HTM")
	oProc:cSubject := cAssunto
	
	//Preenchimento do titulo da pagina
	oProc:oHtml:ValByName("cTitulo"	, cTitulo)
	oProc:oHtml:ValByName("CN9_NUMERO"	, 'Contrato' + ": </b>" + cContra)
	oProc:oHtml:ValByName("CN9_DTFIM"	, 'Data Termino Vigencia' + ": </b>" + cData)
	
	oProc:cTo :=  Alltrim(cMailTo)
	
	oProc:Start() // modo normal
	oProc:Finish()
	
return



