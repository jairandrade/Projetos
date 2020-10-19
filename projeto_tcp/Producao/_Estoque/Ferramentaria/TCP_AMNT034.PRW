#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT034
Histórico emprestimos e devoluções
@return 
@author Felipe Toazza Caldeira
@since 22/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))
                                           
User Function AMNT034()            

Private cAlias := "Z13"
Private cCadastro := "Acompanhamento Ferramentas"
Private aRotina := {}
Private aCores := {}                 
	
	aCORES := {	{"Z13->Z13_STATUS == '1' .AND. Empty(Z13_DTENTR) .AND. Z13_DTPREV < dDataBase " ,"BR_LARANJA" } 	,;   
				{"Z13->Z13_STATUS == '1' " ,"BR_AMARELO" } 	,;   
				{"Z13->Z13_STATUS == '2' " ,"BR_VERDE" } 	,;   
				{"Z13->Z13_STATUS == '3' " ,"BR_VERMELHO"}	,;
				{"Z13->Z13_STATUS == '4' " ,"BR_PRETO" }	} 
	
	//***************************************************************//
	//Montagem do aRotina											 //
	//***************************************************************//                          
	AADD(aRotina,{"Pesquisar"  		, "AxPesqui"   		,0,1})  
	AADD(aRotina,{"Visualizar" 		, "AxVisual"		,0,2})
	AADD(aRotina,{"Legendas"   		, "U_AMNT034L()" 	,0,6})
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())
                                   	
 	mBrowse(006,001,022,075,cAlias,,,,,,aCores)
 		
Return

User Function AMNT034L()
Private cCadastro := "Acompanhamento Ferramentras"

	BrwLegenda( cCadastro , "Legenda" ,{{"BR_AMARELO"		,"Ferramenta Emprestada"	},;
										{"BR_VERDE"			,"Ferramenta Devolvida"		},;
										{"BR_LARANJA"			,"Devolução em Atraso"		},;
										{"BR_VERMELHO"		,"Ferramenta com Pendencia"	},;
										{"BR_PRETO"			,"Ferramenta Baixada com Pendencia"	}})

Return .T.
                                                
