#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  FA040ALT	¦ Autor ¦ Lucilene Mendes    ¦ Data ¦20.11.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ponto de entrada na alteração de titulo a receber         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FA040ALT()
Local lRet		:= .T.                       
Local cChaveSE1	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
Local cSuperior	:= GetNewPar("TC_SUPERIOR","000726") //Login do superior
Local nMaxAlter	:= GetNewPar("TC_MAXALTER",3) //Quantidade máxima de alterações de vencimento
Local nCont		:= 0

//Se o vencimento for alterado
If M->E1_VENCTO <>  SE1->E1_VENCTO .or. M->E1_VENCREA <>  SE1->E1_VENCREA
	//Busca a quantidade de alterações realizadas
	dbSelectArea("ZAV")
	ZAV->(dbSetOrder(1))
	If ZAV->(dbSeek(cChaveSE1))
		While ZAV->(!Eof()) .and. ZAV->(ZAV_FILIAL+ZAV_PREFIX+ZAV_NUM+ZAV_PARCEL+ZAV_TIPO) == cChaveSE1
			nCont++
			If nCont > nMaxAlter
				Exit
			Endif	
			ZAV->(dbSkip())
		End	 
	Endif 
	                   
	//Verifica se a quantidade de alterações de vencimento ultrapassa o máximo permitido
	If nCont > nMaxAlter .and. !Empty(cSuperior)
		lRet:= AltAprov(cSuperior) //rotina para liberação da alteração com a senha do supervisor
	Endif                                                                                        
	
	If lRet
		//Grava o log da alteração
		Reclock("ZAV",.T.)
			ZAV_FILIAL := SE1->E1_FILIAL
			ZAV_PREFIX := SE1->E1_PREFIXO
			ZAV_NUM	   := SE1->E1_NUM
			ZAV_PARCEL := SE1->E1_PARCELA
			ZAV_TIPO   := SE1->E1_TIPO
			ZAV_VENCOR := SE1->E1_VENCTO
			ZAV_VENCNO := M->E1_VENCTO
			ZAV_DATA   := date()
			ZAV_HORA   := time()
			ZAV_USER   := __cUserId
			ZAV_USRLIB := Iif(nCont > nMaxAlter,cSuperior,"")  	
		ZAV->(msUnlock())
	Endif
	
Endif

Return lRet



/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ AltAprov ¦ Libera a alteração de vencto através da senha do supervisor¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function AltAprov(cSuperior)
Local lRet := .F.
Local aPergs := {}
Local aRet   := {}  

aAdd(aPergs,{9,"A senha do supervisor "+FwUserName(cSuperior)+" é necessária para salvar a alteração.",170,20,.T.}) 
aAdd(aPergs,{8,"Digite a senha",Space(15),"","","","",80,.T.})

If ParamBox(aPergs ,"Alteração de Vencimento",@aRet)  //,,{},.T.,0,0,/*oDlg*/,/*cLoad*/,.F.,.F.)      
	PSWOrder(1) //Busca pelo usuário
	If PswSeek(cSuperior,.T.)  
	    //Valida a senha                 
		If PswName(alltrim(aRet[2]))  
			lRet:= .T.
		Else          
			Aviso("Usuário não autenticado","Senha inválida.",{"OK"})
			Return AltAprov(cSuperior)
		Endif 
	Else
   		Aviso("Usuário não autenticado","Usuário inválido.",{"OK"})  
   		Return AltAprov(cSuperior)
	Endif
Endif


Return lRet