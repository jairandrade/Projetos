#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
/*
+------------------+---------------------------------------------------------+
!Nome              ! MT010INC                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Ponto de entrada na inclusao de produtos.               !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio A.Sugahara                                       !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 23/10/2019                                              !
+------------------+---------------------------------------------------------+
*/
User Function MT010INC()
GravaF3K()
Return

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Realiza Gravações na Tabela F3K.                        !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/07/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function GravaF3K()

dbSelectArea("F3K")
F3K->(dbSetOrder(1)) //F3K_FILIAL+F3K_PROD+F3K_CFOP+F3K_CODAJU+F3K_CST
				     
dbSelectArea("SZH")
SZH->(dbSetOrder(1))
SZH->(dbGoTop())

While !SZH->(Eof())
	If !F3K->(dbSeek(xFilial("F3K")+SB1->B1_COD+SZH->ZH_CFOP+SZH->ZH_CODAJU+SZH->ZH_CST))
		RecLock("F3K", .T.)
		F3K->F3K_FILIAL := xFilial("F3K")
		F3K->F3K_PROD   := SB1->B1_COD
		F3K->F3K_CFOP   := SZH->ZH_CFOP
		F3K->F3K_CODAJU := SZH->ZH_CODAJU  
		F3K->F3K_VALOR  := "" 
		F3K->F3K_CST    := SZH->ZH_CST   
		F3K->F3K_CODREF := SZH->ZH_CODREF
		MsUnLock("F3K")  
	EndIf

	SZH->(dbSkip())
EndDo
Return Nil


/*
+--------------------------------------------------------------------------+
! Função    ! IncF3K     ! Autor !Marcio A.Sugahara   ! Data ! 23/10/2019  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Inclusao da tabela F3K a partir da tabela acessoria SZH      !
+-----------+--------------------------------------------------------------+
Static function IncF3K()
	Local cQuery := ""
	If ( SELECT("TRBSZH") ) > 0
		dbSelectArea("TRBSZH")
		TRBSZH->(dbCloseArea())
	EndIf

	cQuery := " SELECT DISTINCT ZH_FILIAL,ZH_CFOP,ZH_CODAJU,ZH_CST,ZH_CODREF "
	cQuery += " FROM " + RetSqlName("SZH")+" SZH 
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	

	TCQUERY cQuery NEW ALIAS "TRBSZH"

	While TRBSZH->(!Eof())
		RecLock("F3K",.T.)
		F3K->F3K_FILIAL := TRBSZH->ZH_FILIAL
		F3K->F3K_PROD   := SB1->B1_COD
		F3K->F3K_CFOP   := TRBSZH->ZH_CFOP
		F3K->F3K_CODAJU := TRBSZH->ZH_CODAJU  
		F3K->F3K_VALOR  := "" 
		F3K->F3K_CST    := TRBSZH->ZH_CST   
		F3K->F3K_CODREF := TRBSZH->ZH_CODREF
		MsUnLock("F3K")  
		TRBSZH->(DBSkip())
	End
Return()
*/
