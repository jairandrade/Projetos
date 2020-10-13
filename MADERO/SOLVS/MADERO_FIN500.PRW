/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FIN500                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de credenciadoras de cartão                                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 10/04/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#Include 'Protheus.ch'
#Include "topconn.ch"

User Function FIN500()
Local   aArea   :=GetArea()
Private cTab    :="Z31"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
Private bOK     
Private bTTS
Private bNoTTS             
Private cCadTit :="Credenciadoras de cartão"
   //Aadd(aRotAdic,{ "Desc. Opção","Processa({|| u_xxx()   },'Processando...')", 0 , 6 }) 
   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
   RestArea(aArea)
Return