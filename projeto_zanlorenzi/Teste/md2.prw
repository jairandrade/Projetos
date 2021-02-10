#include "protheus.ch"
User Function Md2()
	nOpcx:=3
//+-----------------------------------------------+
//¦ Montando aHeader para a Getdados              ¦
//+-----------------------------------------------+
	dbSelectArea("Sx3")
	dbSetOrder(1)
	dbSeek("SX5")
	nUsado:=0
    aHeader:={}
	While !Eof() .And. (x3_arquivo == "SX5")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(x3_titulo),x3_campo,x3_picture,x3_tamanho,x3_decimal,"ExecBlock('Md2valid',.f.,.f.)",x3_usado,x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End
//+-----------------------------------------------+
//¦ Montando aCols para a GetDados                ¦
//+-----------------------------------------------+
	aCols:=Array(1,nUsado+1)
	dbSelectArea("Sx3")
	dbSeek("SX5")
	nUsado:=0
	While !Eof() .And. (x3_arquivo == "SX5")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			IF nOpcx == 3
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				Elseif x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				Elseif x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				Elseif x3_tipo == "M"
					aCOLS[1][nUsado] := ""
				Else
					aCOLS[1][nUsado] := .F.
				Endif
			Endif
		Endif
		dbSkip()
	End
	aCOLS[1][nUsado+1] := .F.
//+----------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2           ¦
//+----------------------------------------------+
	cCliente:=Space(6)
	cLoja   :=Space(2)
	dData   :=Date()
//+----------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2
//+----------------------------------------------+
	nLinGetD:=0
//+----------------------------------------------+
//¦ Titulo da Janela                             ¦
//+----------------------------------------------+
	cTitulo:="TESTE DE MODELO2"
//+----------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho  ¦
//+----------------------------------------------+
	aC:={}
	#IFDEF WINDOWS
		AADD(aC,{"cCliente" ,{15,10} ,"Cod. do Cliente","@!",'ExecBlock("MD2VLCLI",.F.,.F.)',"SA1",})
		AADD(aC,{"cLoja"    ,{15,200},"Loja","@!",,,})
		AADD(aC,{"dData"    ,{27,10} ,"Data de Emissao",,,,})
	#ELSE
		AADD(aC,{"cCliente" ,{6,5} ,"Cod. do Cliente","@!",'ExecBlock("MD2VLCLI",.F.,.F.)',"SA1",})
		AADD(aC,{"cLoja"    ,{6,40},"Loja","@!",,,})
		AADD(aC,{"dData"    ,{7,5} ,"Data de Emissao",,,,})
	#ENDIF
//+-------------------------------------------------+
//¦ Array com descricao dos campos do Rodape        ¦
//+-------------------------------------------------+
	aR:={}
	#IFDEF WINDOWS
		AADD(aR,{"nLinGetD" ,{120,10},"Linha na GetDados", "@E 999",,,.F.})
	#ELSE
		AADD(aR,{"nLinGetD" ,{19,05},"Linha na GetDados","@E 999",,,.F.})
	#ENDIF
//+------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2   ¦
//+------------------------------------------------+
	#IFDEF WINDOWS
		aCGD:={44,5,118,315}
	#ELSE
		aCGD:={10,04,15,73}
	#ENDIF
//+----------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2           ¦
//+----------------------------------------------+
	cLinhaOk := "ExecBlock('Md2LinOk',.f.,.f.)"
	cTudoOk  := "ExecBlock('Md2TudOk',.f.,.f.)"
//+----------------------------------------------+
//¦ Chamada da Modelo2                           ¦
//+----------------------------------------------+
// lRet = .t. se confirmou
// lRet = .f. se cancelou
	lRet:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
Return
