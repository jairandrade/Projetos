/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM500                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Cadastro de niveis de produtos Tekniza - N1                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! M�rcio Zaguetti                                                               !
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

User Function COM500()
Local   aArea   :=GetArea()
Private cTab    :="Z18"
Private aRotAdic:={}                            
Private aButtons:={}
Private bPre   
Private bOK     
Private bTTS
Private bNoTTS             
Private cCadTit :="Nivel 1 Produtos - TEKNIZA"
   //Aadd(aRotAdic,{ "Desc. Op��o","Processa({|| u_xxx()   },'Processando...')", 0 , 6 }) 
   DbSelectArea(cTab)
   AxCadastro(cTab,cCadTit, , ,aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , ) 
   RestArea(aArea)
Return