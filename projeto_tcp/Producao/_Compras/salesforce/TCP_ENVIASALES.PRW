#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*---------------------------------------------------------------------------+
!                             FICHA T√NICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Modulo            ! GenErico                                             !
+------------------+---------------------------------------------------------+
!Descrico         ! Envia integraÁ„o apra o Sales em casos que È bom garantir que n„o apareÁa erro na tela.
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSINTEG!			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/

User Function ENVSALES(_cChave)

STARTJOB("U_ENVSAL01", GetEnvServer(), .F., cEmpAnt, cFilAnt,_cChave)
//U_ENVSAL02(cEmpAnt, cFilAnt,_cChave)
return .T.

User function ENVSAL01(_cEmp,_cFil,_cChave)

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil TABLES "ZZK" MODULO "SIGACOM"
		
	oCompras := ClassIntCompras():new()    
	oCompras:cCodInt := _cChave   
	oCompras:cFilSc := _cFil
	oCompras:enviaSales()

RESET ENVIRONMENT
return

User function ENVSAL02(_cChave)

//PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil TABLES "ZZK" MODULO "SIGACOM"
		
	oCompras := ClassIntCompras():new()    
	oCompras:cCodInt := _cChave
	oCompras:cFilSc := cFilAnt
	oCompras:enviaSales()

//RESET ENVIRONMENT
return


User function ENVSAL03()

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "ZZK" MODULO "SIGACOM"
		
	oCompras := ClassIntCompras():new()    
	oCompras:reenviaSales()

RESET ENVIRONMENT
return

User function ENVSAL04()

PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "ZZK" MODULO "SIGACOM"
		
	oCompras := ClassIntCompras():new()    
	oCompras:reenviaSales()

RESET ENVIRONMENT
return

//Atualiza o status da solicitaÁ„o no salesforce
user function ENVSAL05()
	oCompras  := ClassIntCompras():new()    
	
	oCompras:registraIntegracao('5',SC1->C1_FILIAL+SC1->C1_NUM,'A')  
	
	oCompras:enviaSales()
	
RETURN

user function ENVSAL06()
	
PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "ZZK" MODULO "SIGACOM"
// ctrSales(_cFil,_cNum,_lInclui,_lAltera,_lExc,_lResid)
	oRetPed := u_ctrSales( '01','118083', .t., .f.,.F.,.F.)

RESET ENVIRONMENT
	
RETURN

user function ENVSAL16()
	
PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "ZZK" MODULO "SIGACOM"
		oCompras  := ClassIntCompras():new()    
	
	oCompras:registraIntegracao('5','01114645','A')  
	
	oCompras:enviaSales()
	
RESET ENVIRONMENT
	
RETURN

USER FUNCTION REENVALL()

	cAliaAux2 := getNextAlias()
	
	BeginSQL Alias cAliaAux2
		SELECT C1_FILIAL,C1_NUM
		FROM %TABLE:SC1% SC1
		WHERE SC1.%NotDel%  AND C1_XSALES != ' '
		GROUP BY C1_FILIAL,C1_NUM

	EndSQL
	
	WHILE !(cAliaAux2)->(Eof())
		dbSelectArea('SC1')
		SC1->(DbsetOrder(1))
		IF SC1->(DBSeek((cAliaAux2)->C1_FILIAL+(cAliaAux2)->C1_NUM))  
			oCompras  := ClassIntCompras():new()    
		
			oCompras:registraIntegracao('5',SC1->C1_FILIAL+SC1->C1_NUM,'A')  
			
			oCompras:enviaSales()
			FreeObj(oCompras)
		ENDIF
		(cAliaAux2)->(DbSkip())
	ENDDO
	
	(cAliaAux2)->(dbCloseArea())

RETURN

user function testapos(_cNumPed)

Local aHeadSal := {}
	Local cAutRet  := ""
	Local _cPostAu := ""
	Local _cCorpo  := ""
	Local _nTime   := 1200
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(xFilial("SC7")+_cNumPed)) .AND. !EMPTY(SC7->C7_XSALES)
		_cUrlSal := 'http://vhprotheus01.tcp.com.br:9991/rest/WSAPPROVAL/api/v1/approval'
		cCrpTst:= '{"Status":"Approved","PurchaseOrderId":"'+ALLTRIM(SC7->C7_XSALES)+'","OrderId":'+SC7->C7_NUM+',"Mensagem":"Aprova√ß√£o protheus update steps","Company":"02","Branch":"01","Area":"Maintenance","Aprovadores":[{"UsuarioOriginal":"jsilas","Usuario":"jsilas","Status":"Started","NomeOriginal":"Jeferson Silas Fernandes Adams","Nome":"Jeferson Silas Fernandes Adams","Nivel":0,"EmailUsuarioOriginal":"jeferson.silas@tcp.com.br","Data":"07/22/2020 13:42:37","Comentario":"Start Process by the Protheus system."},{"UsuarioOriginal":"kwang","Usuario":"kwang","Status":"Approved","NomeOriginal":"King Wang","Nome":"King Wang","Nivel":1,"EmailUsuarioOriginal":"king.wang@tcp.com.br","Data":"07/22/2020 13:54:54","Comentario":null},{"UsuarioOriginal":"rmattoso","Usuario":"rmattoso","Status":"Approved","NomeOriginal":"Ricardo da Silva Mattoso","Nome":"Ricardo da Silva Mattoso","Nivel":2,"EmailUsuarioOriginal":"ricardo.mattoso@tcp.com.br","Data":"07/22/2020 15:00:49","Comentario":null},{"UsuarioOriginal":"lbressan","Usuario":"lbressan","Status":"Approved","NomeOriginal":"Luiz Alberto Bressan","Nome":"Luiz Alberto Bressan","Nivel":3,"EmailUsuarioOriginal":"luiz.bressan@tcp.com.br","Data":"07/22/2020 17:00:38","Comentario":null},{"UsuarioOriginal":"rofilho","Usuario":"rofilho","Status":"Approved","NomeOriginal":"Romauro Santos Filho","Nome":"Romauro Santos Filho","Nivel":3,"EmailUsuarioOriginal":"romauro.santos@tcp.com.br","Data":"07/23/2020 09:07:18","Comentario":null}]}'
		//ADICIONA HEADER DA CHAMADA POST - AUTENTICA«√O.
		aadd(aHeadSal,'Content-Type: application/json; charset=UTF-8')

		//EXECUTA A CHAMADA DA FUN«√O - AUTENTICA«√O.
		_cPostAu := HttpPost(_cUrslSal,"",cCrpTst,_nTime,aHeadSal,@cAutRet)
		alert(_cPostAu)
	endif
return
