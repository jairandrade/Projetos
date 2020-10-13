/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM502                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de niveis de produtos Tekniza - N3                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 08/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#Include 'Protheus.ch'
#Include "topconn.ch"

User Function COM502()
Local   aArea   :=GetArea()
Private cTab    :="Z20"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
Private bOK     
Private bTTS
Private bNoTTS             
Private cCadTit :="Nível 3 Produtos - TEKNIZA"
   //Aadd(aRotAdic,{ "Desc. Opção","Processa({|| u_xxx()   },'Processando...')", 0 , 6 }) 
   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
   RestArea(aArea)
Return