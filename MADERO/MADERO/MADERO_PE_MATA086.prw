#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! MT086VLD                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Confirma a gravação do Grupo de Aprovadores   	 		 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/10/18                                                !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 !
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function MT086VLD()
Local lRet := .T.
Local cDescri :=Space(TamSx3("AJ_XDESCG")[1])
Local lDeleta    := PARAMIXB[3]
Local nX := 0
Local nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2]) == "AJ_XDESCG"})

If 	!lDeleta
	If Altera
		cDescri := 	aCols[1,nPosDesc]
	EndIf
	
	DEFINE DIALOG oDlg TITLE "Descrição do Grupo de Compras" FROM 180,180 TO 300,600 PIXEL Style DS_MODALFRAME // Cria Dialog sem o botão de Fechar.
	// Usando New
	@ 002, 002 SAY "Digite / Altere a descrição para o Grupo de Compras' " of oDlg PIXEL
	@ 025, 002 MSGET cDescri SIZE 150,05 PICTURE PesqPict("SAJ","AJ_XDESCG") PIXEL OF oDlg
	@ 048,142 Button "Confirma" Size 36,10 Of oDlg Pixel Action (IIf(ChamaMsg(cDescri),Close(oDlg),Nil))
	oDlg:lEscClose := .F.
	ACTIVATE DIALOG oDlg CENTERED
	
	For nX = 1 to Len(aCols)
		aCols[nX,nPosDesc]  := cDescri
	Next nX
	
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} ChamaMsg(cDescri)
Valida a Descrição do Grupo de Compras

@author Jair  Matos
@since 10/10/2018
@version P11
@return lRet
/*/
//---------------------------------------------------------------------
Static Function ChamaMsg(cDescri)
Local lRet := .T.

If Empty(cDescri)
	MsgAlert("Digite um nome para o Grupo de Compras","Aviso")
	lRet := .F.
EndIf

Return  lRet
