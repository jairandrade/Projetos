#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Funcao                                                  !
+------------------+---------------------------------------------------------+
!Módulo            ! Todos                                                   !
+------------------+---------------------------------------------------------+
!Nome              ! XPutSX1                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Função responsável por criar as perguntas recebidas por !
!				   ! paramêtros. Serão inseridas na SX1                      !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 09/10/2018                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function XPutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp)
	Local aArea       := GetArea()
	Local cChaveHelp  := ""
	Local nPreSel     := 0
	Default cGrupo    := Space(10)
	Default cOrdem    := Space(02)
	Default cTexto    := Space(30)
	Default cMVPar    := Space(15)
	Default cVariavel := Space(6)
	Default cTipoCamp := Space(1)
	Default nTamanho  := 0
	Default nDecimal  := 0
	Default cTipoPar  := "G"
	Default cValid    := Space(60)
	Default cF3       := Space(6)
	Default cPicture  := Space(40)
	Default cDef01    := Space(15)
	Default cDef02    := Space(15)
	Default cDef03    := Space(15)
	Default cDef04    := Space(15)
	Default cDef05    := Space(15)
	Default cHelp     := ""

//Se tiver Grupo, Ordem, Texto, Parâmetro, Variável, Tipo e Tamanho, continua para a criação do parâmetro
	If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0

		//Definição de variáveis
		cGrupo     := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")           //Adiciona espaços a direita para utilização no DbSeek
		cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
		cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em maiúsculo
		nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o pré-selecionado será o Primeiro
		cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definição para ser tanto Servidor quanto Local
		nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - Limitação do Protheus
		nDecimal   := Iif(nDecimal > 9,  9,  nDecimal)                //Se o decimal for maior que 9, volta para 9
		nDecimal   := Iif(cTipoPar == "N", nDecimal, 0)               //Se não for parâmetro do tipo numérico, será 0 o Decimal
		cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em maiúsculo
		cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo não estiver entre Caracter / Data / Numérico, será Caracter
		cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Parâmetro em maiúsculo
		cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Parâmetro estiver em branco, será um Get
		nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho será 1

		DbSelectArea('SX1')
		SX1->(DbSetOrder(1)) // Grupo + Ordem

		//Se não conseguir posicionar, a pergunta será criada
		If ! SX1->(DbSeek(cGrupo + cOrdem))
			RecLock('SX1', .T.)
			X1_GRUPO   := cGrupo
			X1_ORDEM   := cOrdem
			X1_PERGUNT := cTexto
			X1_PERSPA  := cTexto
			X1_PERENG  := cTexto
			X1_VAR01   := cMVPar
			X1_VARIAVL := cVariavel
			X1_TIPO    := cTipoCamp
			X1_TAMANHO := nTamanho
			X1_DECIMAL := nDecimal
			X1_GSC     := cTipoPar
			X1_VALID   := cValid
			X1_F3      := cF3
			X1_PICTURE := cPicture
			X1_DEF01   := cDef01
			X1_DEFSPA1 := cDef01
			X1_DEFENG1 := cDef01
			X1_DEF02   := cDef02
			X1_DEFSPA2 := cDef02
			X1_DEFENG2 := cDef02
			X1_DEF03   := cDef03
			X1_DEFSPA3 := cDef03
			X1_DEFENG3 := cDef03
			X1_DEF04   := cDef04
			X1_DEFSPA4 := cDef04
			X1_DEFENG4 := cDef04
			X1_DEF05   := cDef05
			X1_DEFSPA5 := cDef05
			X1_DEFENG5 := cDef05
			X1_PRESEL  := nPreSel

			//Se tiver Help da Pergunta
			If !Empty(cHelp)
				X1_HELP    := ""

				fPutHelp(cChaveHelp, cHelp)
			EndIf
			SX1->(MsUnlock())
		EndIf
	EndIf

	RestArea(aArea)
Return
/*---------------------------------------------------*
| Função: fPutHelp                                  |
| Desc:   Função que insere o Help do Parametro     |
*---------------------------------------------------*/
Static Function fPutHelp(cKey, cHelp, lUpdate)
Local cFilePor  := "SIGAHLP.HLP"
Local cFileEng  := "SIGAHLE.HLE"
Local cFileSpa  := "SIGAHLS.HLS"
Local nRet      := 0
Default cKey    := ""
Default cHelp   := ""
Default lUpdate := .F.

//Se a Chave ou o Help estiverem em branco
	If Empty(cKey) .Or. Empty(cHelp)
	Return
	EndIf

//**************************** Português
nRet := SPF_SEEK(cFilePor, cKey, 1)

//Se não encontrar, será inclusão
	If nRet < 0
	SPF_INSERT(cFilePor, cKey, , , cHelp)
	
	//Senão, será atualização
	Else
		If lUpdate
		SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
		EndIf
	EndIf



//**************************** Inglês
nRet := SPF_SEEK(cFileEng, cKey, 1)

//Se não encontrar, será inclusão
	If nRet < 0
	SPF_INSERT(cFileEng, cKey, , , cHelp)
	
	//Senão, será atualização
	Else
		If lUpdate
		SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
		EndIf
	EndIf



//**************************** Espanhol
nRet := SPF_SEEK(cFileSpa, cKey, 1)

//Se não encontrar, será inclusão
	If nRet < 0
	SPF_INSERT(cFileSpa, cKey, , , cHelp)
	
	//Senão, será atualização
	Else
		If lUpdate
		SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
		EndIf
	EndIf
Return
