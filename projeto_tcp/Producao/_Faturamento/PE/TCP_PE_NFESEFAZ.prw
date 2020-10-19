#include 'protheus.ch'

/*-----------------+---------------------------------------------------------+
!Nome              ! NFEPROD                                                 !
+------------------+---------------------------------------------------------+
!Descri��o         ! Altera��o de Produtos                                   !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Data de Cria��o   ! 24/11/2014                                              !
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting                                       !
+------------------+--------------------------------------------------------*/
User Function NFEPROD()
	Local aProd 	:= ParamIXB[4]
	Local _cDescri	:= ""
	Local _aSB5 := GetArea("SB5")

	//Nota de Sa�da
	If ParamIXB[1] == '1'
	
		//-- Busca Descri��o Cient�fica --
		DbSelectArea("SB5")
		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+aProd[2]))
			aProd[4] := Alltrim(SB5->B5_CEME)		
		EndIf		

	EndIf 
	
	RestArea(_aSB5)
Return aProd


User Function DFELogo(oDanfe, cLogoD, cLogo, lMv_Logod)

	If lMv_Logod
		oDanfe:SayBitmap(052,002,cLogoD,090,033)
	Else
		oDanfe:SayBitmap(052,002,cLogo,090,033)
	EndIF

Return