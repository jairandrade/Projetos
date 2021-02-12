#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Valida acesso para criação de Títulos de Tipo RA/PA.    ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/05/2020                                              !
+------------------+--------------------------------------------------------*/
User Function OkTpTit()
Local lRet  := .T.
Local cTipo := AllTrim(&(ReadVar()))  

If cTipo $ "RA/PA" .And. !(RetCodUsr() $ SuperGetMv("KP_USRTP"+cTipo,,""))
	lRet := .F.	
	Alert("<html>Usuário sem acesso para criação de Títulos do Tipo <b>" + cTipo + "</b>"+;
		  "<br><b>Código Usr:</b> "        + RetCodUsr() +;
		  "<br><b>Parâmetro:</b> KP_USRTP" + cTipo       + "</html>")		  	
EndIf

Return lRet