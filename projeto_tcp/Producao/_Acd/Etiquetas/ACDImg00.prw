#include 'protheus.ch'


/*/{Protheus.doc} IMG00
Impressaos dos parametros de impressao

@author Rafael Ricardo Vieceli
@since 06/08/2015
@version 1.0
/*/
User Function IMG00()

	Local cRotinaOrigem := ParamIXB[1]

	IF cRotinaOrigem $ 'ACDI10PR-ACDI10CX-ACDI10DE'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'PRODUTO DE :'+mv_par01,"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+mv_par01,"B1_DESC"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'PRODUTO ATE:'+mv_par02,"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('SB1',1,xFilial("SB1")+mv_par02,"B1_DESC"),"N","0","025,035",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem == 'ACDI070'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'RECURSO DE :'+mv_par01,"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('SH1',1,xFilial("SH1")+mv_par01,"H1_DESCRI"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'RECURSO ATE:'+mv_par02,"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('SH1',1,xFilial("SH1")+mv_par02,"H1_DESCRI"),"N","0","025,035",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem == 'ACDI080'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'TRANSACAO DE :'+mv_par01,"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('CBI',1,xFilial("CBI")+mv_par01,"CBI_DESCRI"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'TRANSACAO ATE:'+mv_par02,"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('CBI',1,xFilial("CBI")+mv_par02,"CBI_DESCRI"),"N","0","025,035",.T.)
		MSCBEND()
	ElseIF cRotinaOrigem $ 'ACDV210-ACDV220'
		MSCBBEGIN(1,6) //Inicio da Imagem da Etiqueta
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'PRODUTO DE :'+CB0->CB0_CODPRO,"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'PRODUTO ATE:'+CB0->CB0_CODPRO,"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem $ 'RACDI10PR-RACDI10CX'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
		MSCBSAY(05,10,'PRODUTO : '+CB0->CB0_CODPRO,"N","0","025,035",.T.)
		MSCBSAY(05,14,Posicione('SB1',1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),"N","0","025,035",.T.)
		MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
		MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem $ 'ACDI10PD-ACDV125'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'PEDIDO :'+ParamIXB[2],"N","0","025,035",.T.)
		MSCBSAY(05,16,'FORNECEDOR:'+ParamIXB[3],"N","0","025,035",.T.)
		MSCBSAY(05,20,Posicione('SA2',1,xFilial("SA2")+ParamIXB[3]+ParamIXB[4],"A2_NREDUZ"),"N","0","025,035",.T.)
		MSCBEND()

	// identificacao de produto
	ElseIF cRotinaOrigem == 'ACDI10NF'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'NOTA :'+SF1->F1_DOC+' '+SF1->F1_SERIE,"N","0","025,035",.T.)
		MSCBSAY(05,16,'FORNECEDOR:'+SF1->F1_FORNECE,"N","0","025,035",.T.)
		MSCBSAY(05,20,Posicione('SA2',1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ"),"N","0","025,035",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem $ 'ACDI10OP-ACDV025'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBSAY(05,12,'PRODUTO  :'+SD3->D3_COD,"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('SB1',1,xFilial("SB1")+SD3->D3_COD,"B1_DESC"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'DOCUMENTO:'+SD3->D3_DOC,"N","0","025,035",.T.)
		MSCBSAYBAR(23,24,SD3->D3_DOC,"N",'C',8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
		MSCBEND()

	ElseIF cRotinaOrigem =='ACDV040'
		IF Posicione('SF5',1,xFilial("SF5")+ParamIXB[2],"F5_TIPO")=="R"
			//Inicio da Imagem da Etiqueta
			MSCBBEGIN(1,6)
			MSCBLineV(01,01,32,300)
			MSCBSAY(05,12,'REQUISICAO:',"N","0","025,035",.T.)
			IF ! Empty(ParamIXB[3])
				MSCBSAY(05,18,'O.P: '+ParamIXB[3],"N","0","025,035",.T.)
			EndIF
			MSCBEND()
		Else
			//Inicio da Imagem da Etiqueta
			MSCBBEGIN(1,6)
			MSCBLineV(01,01,32,300)
			MSCBSAY(05,12,'DEVOLUCAO:',"N","0","025,035",.T.)
			MSCBEND()
		EndIF

	ElseIF cRotinaOrigem =='ACDV170'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBLineV(01,01,32,300)
		MSCBSAY(05,12,'EXPEDICAO:',"N","0","025,035",.T.)
		If ! Empty(ParamIXB[2])
			MSCBSAY(05,18,'ORDEM DE SEP: '+ParamIXB[2],"N","0","025,035",.T.)
		EndIF
		MSCBEND()

	ElseIF cRotinaOrigem =='ACDV230'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBLineV(01,01,32,300)
		MSCBSAY(05,12,'PALLET: '+ParamIXB[2],"N","0","025,035",.T.)
		MSCBEND()

	// endereco
	ElseIF cRotinaOrigem =='ACDI020LO'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(01,01,75,39,200)
		MSCBSAY(08,15,'Almox de :'+mv_par01,"N","0","025,035",.T.)
		MSCBSAY(08,19,'Almox ate:'+mv_par02,"N","0","025,035",.T.)
		MSCBSAY(08,23,'Endereco de :'+mv_par03,"N","0","025,035",.T.)
		MSCBSAY(08,27,'Endereco ate:'+mv_par04,"N","0","025,035",.T.)
		MSCBEND()

	// endereco
	ElseIF cRotinaOrigem =='RACDI020LO'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
		MSCBSAY(05,10,'ENDERECO : '+CB0->CB0_LOCALI,"N","0","025,035",.T.)
		MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
		MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
		MSCBEND()

	// dispositivo de movimentacao
	ElseIF cRotinaOrigem == 'ACDI030DM'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'Dispositivo de :'+ParamIXB[2],"N","0","025,035",.T.)
		MSCBSAY(05,20,'Dispositivo ate:'+ParamIXB[3],"N","0","025,035",.T.)
		MSCBEND()

	// dispositivo de movimentacao
	ElseIF cRotinaOrigem == 'RACDI030DM'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
		MSCBSAY(05,10,'DISPOSITIVO MOV.: '+CB0->CB0_DISPID,"N","0","025,035",.T.)
		MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
		MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
		MSCBEND()

	// transportadora
	ElseIF cRotinaOrigem == 'ACDI050TR'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'Transportadora de :'+ParamIXB[2],"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('SA4',1,xFilial("SA4")+ParamIXB[2],"A4_NOME"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'Transportadora ate:'+ParamIXB[3],"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('SA4',1,xFilial("SA4")+ParamIXB[3],"A4_NOME"),"N","0","025,035",.T.)
		MSCBEND()

	// transportadora
	ElseIF cRotinaOrigem == 'RACDI050TR'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
		MSCBSAY(05,10,'TRANSPORTADORA: '+CB0->CB0_TRANSP,"N","0","025,035",.T.)
		MSCBSAY(05,14,Posicione('SA4',1,xFilial("SA4")+CB0->CB0_TRANSP,"A4_NOME"),"N","0","025,035",.T.)
		MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
		MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
		MSCBEND()

	// OPERADOR (USUARIO)
	ElseIF cRotinaOrigem == 'ACDI060US'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,12,'Operador de :'+ParamIXB[2],"N","0","025,035",.T.)
		MSCBSAY(05,16,Posicione('CB1',1,xFilial("CB1")+ParamIXB[2],"CB1_NOME"),"N","0","025,035",.T.)
		MSCBSAY(05,20,'Operador ate:'+ParamIXB[3],"N","0","025,035",.T.)
		MSCBSAY(05,24,Posicione('CB1',1,xFilial("CB1")+ParamIXB[3],"CB1_NOME"),"N","0","025,035",.T.)
		MSCBEND()

	// transportadora
	ElseIF cRotinaOrigem == 'RACDI060US'
		//Inicio da Imagem da Etiqueta
		MSCBBEGIN(1,6)
		MSCBBOX(00,00,76,40,200)
		MSCBSAY(05,04,'RE-IMPRESSAO DE ETIQUETA',"N","0","025,035",.T.)
		MSCBSAY(05,10,'Operador: '+CB0->CB0_USUARI,"N","0","025,035",.T.)
		MSCBSAY(05,14,Posicione('CB1',1,xFilial("CB1")+CB0->CB0_USUARI,"CB1_NOME"),"N","0","025,035",.T.)
		MSCBSAY(05,18,'DESCRICAO DA BARRA: ',"N","0","025,035",.T.)
		MSCBSAY(05,26,CB0->CB0_CODETI,"N","0","025,035",.T.)
		MSCBEND()
	EndIF

Return .T.
