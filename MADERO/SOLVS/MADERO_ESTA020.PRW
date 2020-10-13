/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FIN500                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de condições de pagamento por unidade de negócio                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 28/09/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#Include 'Protheus.ch'
#Include "topconn.ch"

User Function ESTA020()
Local   aArea   :=GetArea()
Private cTab    :="Z32"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
//Private bOK     := {|| U_GERAZ10()}
Private bTTS
Private bNoTTS             
Private cCadTit :="Produto Adicional GoodData"
   //Aadd(aRotAdic,{ "Desc. Opção","Processa({|| u_xxx()   },'Processando...')", 0 , 6 }) 
   
   aadd(aRotAdic,{ "Importa","U_ESTA016", 0 , 6 })
   aadd(aRotAdic,{ "Replica","U_EST021", 0 , 3 })
   //aadd(aRotAdic,{ "Replica","U_ESTA018", 0 , 7 })

   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, ".T.", ".T.", aRotAdic, , , , , , , , , )
   RestArea(aArea)
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! GERAZ10                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Gera Pendencia na tabela Z10                            !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Gabriel França e Silva                            !
+------------------+---------------------------------------------------------!
!Data              ! 06/09/2018                                              !
+------------------+--------------------------------------------------------*/
/*
User Function GERAZ10()
Local lRetok:=.T.
Local cXEmp := ""
Local cXFil := ""
	
		ADK->(DbOrderNickName("ADKXFILI"))
		If ADK->(DbSeek(xFilial("ADK")+cFilAnt))
			cXEmp := ADK->ADK_XEMP
			cXFil := ADK->ADK_XFIL
		EndIf
		
		If !Z10->(dbSeek(xFilial("Z10") + M->Z10_CODIGO + M->Z10_CODEXT )) .And. Inclui
			If Empty(M->Z10_CODEXT)
				M->Z10_XEMP			:= cXEmp
				M->Z10_XFIL			:= cXFil
				M->Z10_XSTINT		:= "P"
			Else
				M->Z10_XEMP		:= cXEmp
				M->Z10_XFIL		:= cXFil
				M->Z10_XSTINT	:= "I"
				M->Z10_XDINT	:= Date()
				M->Z10_XHINT	:= Time()
			EndIf
		ElseIf Z10->(dbSeek(xFilial("Z10") + M->Z10_CODIGO + M->Z10_CODEXT )) .And. Altera
				M->Z10_XEMP		:= cXEmp
				M->Z10_XFIL		:= cXFil
				M->Z10_XSTINT	:= "P"
		EndIf
		

Return(lRetOk)
*/
/*-----------------+---------------------------------------------------------+
!Nome              ! DelZ10                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Deleta Pendencia na tabela Z10                          !
+------------------+---------------------------------------------------------+
!Autor             ! Paulo Gabriel França e Silva                            !
+------------------+---------------------------------------------------------!
!Data              ! 06/09/2018                                              !
+------------------+--------------------------------------------------------*/
/*
User Function DelZ10()
Local lRetok	:= .T.
Local aArea 	:= GetArea()
	
	If Z10->(dbSeek(xFilial("Z10") + Z10->Z10_CODIGO + Z10->Z10_CODEXT ))
			Reclock("Z10",.F.)
				Z10->Z10_XSTINT		:= "P"
				Z10->Z10_XEXC		:= "S"
			Z10->(MsUnlock())
	EndIf

Return(lRetOk)
*/