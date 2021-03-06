/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Classe			                              			 !
+------------------+---------------------------------------------------------+
!Módulo            ! Genérico             		                             !
+------------------+---------------------------------------------------------+
!Descri��o         !Classe para controle dos atestados													 !
+------------------+---------------------------------------------------------+
!Nome              ! ClassLancAtestado	                                             !
+------------------+---------------------------------------------------------+
!Parâmetros        ! 												  		 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 15/05/2019										 !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo Vieira		                                     !
+------------------+--------------------------------------------------------*/
#Include "TOTVS.CH"
#Include "TOPCONN.CH"


/*/{Protheus.doc} ClassLancAtestado
Classe para gerenciamento de Gera��o, Grava��o e Exibi��o de Logs
@author Eduardo vieira
@since 01/11/2018
@version 1.0
@type class
/*/
Class ClassLancAtestado
	
	Data cMat
	Data cNome
	Data dDtAtestado
	Data nQtdDias	 
	Data dDtOutros  	 
	Data nQtdDiasOutros                    
	Data dDtAcomp	                    
	Data dDiasAcomp                   
	Data dDtHoje   
	Data cMailAtest                 
	
	Method newLancAtestado() constructor
	Method enviaMail()
	
EndClass
 
/*/{Protheus.doc} newLog
Método construtor da Classe. Inicializa principais variáveis com valores padrões.
@author Eduardo vieira
@since 15/05/2019
@version 1.0
@return Self
@type function
/*/
Method newLancAtestado() Class ClassLancAtestado  
	
	::cMat          := '' 
	::cNome          := ''   
	::dDtAtestado    := ''
	::nQtdDias	     := ''
	::dDtOutros  	 := ''
	::nQtdDiasOutros := ''                   
	::dDtAcomp	     := ''               
	::dDiasAcomp     := ''            
	::dDtHoje        := ''             
	::cMailAtest     := GETMV( 'TCP_MAILAT')

Return Self

/*/{Protheus.doc} enviaMail
Envia e-mail do atestado
@author Eduardo vieira
@since 15/05/2019
@version 1.0
@param 
@type function
/*/
Method enviaMail() Class ClassLancAtestado
	
	oProc := TWFProcess():New("MAILRH01","Atestado inclu�do")
	                                                             
	oProc:NewTask("Ordem Separa��o", "\WORKFLOW\HTML\MAILRH01.HTML" )
	oProc:cSubject := "Atestado inclu�do"	

	oHtml := oProc:oHtml

	IF valtype(oHtml) != "U"
		
		oHtml:ValByName("cMat",self:cMat) 
		oHtml:ValByName("cNome",self:cNome)           
		oHtml:ValByName("cDtAtestado",self:dDtAtestado)    
		oHtml:ValByName("cQtdDias",self:nQtdDias)          
		oHtml:ValByName("cDtOutros",self:dDtOutros)          
		oHtml:ValByName("cQtdDiasOutros",self:nQtdDiasOutros)          
		oHtml:ValByName("cDtAcomp",self:dDtAcomp)          
//		oHtml:ValByName("cDiasAcomp",self:dDiasAcomp)          
		oHtml:ValByName("cDtHoje",self:dDtHoje)         
		
		PswOrder(1)
		If PswSeek(RetCodUsr(),.t.)
			aInfo   := PswRet(1)
			::cMailAtest += ';'+alltrim(aInfo[1,14])
		Endif
			
		oProc:cTo := ::cMailAtest
		oProc:Start()
		oProc:Finish()

		WFSendMail()
		
	endif
	
Return .T.