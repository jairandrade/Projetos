/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM501                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de niveis de produtos Tekniza - N2                                   !
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

User Function COM501()
Local   aArea   :=GetArea()
Private cTab    :="Z19"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
Private bOK     
Private bTTS
Private bNoTTS             
Private cCadTit :="Nível 2 Produtos - TEKNIZA"
   //Aadd(aRotAdic,{ "Desc. Opção","Processa({|| u_xxx()   },'Processando...')", 0 , 6 }) 
   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
   RestArea(aArea)
Return