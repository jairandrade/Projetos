#include 'protheus.ch'

/*
Impressao de etiquetas de Localizacao
*/

User Function IACD011

	Local cPerg := IF(IsTelNet(),'VTPERGUNTE','PERGUNTE')


	//PutSX1("UAII011","01","Produto de"        ,"","","mv_ch01","C",15,0,0,"G","","SB1","","","mv_par01")
	//PutSX1("UAII011","02","Produto até"       ,"","","mv_ch02","C",15,0,0,"G","","SB1","","","mv_par02")
	//PutSX1("UAII011","03","Local de"          ,"","","mv_ch03","C",02,0,0,"G","","NNR","","","mv_par03")
	//PutSX1("UAII011","04","Local até"         ,"","","mv_ch04","C",02,0,0,"G","","NNR","","","mv_par04")
	//PutSX1("UAII011","05","Num. Serie de"     ,"","","mv_ch05","C",20,0,0,"G","",""   ,"","","mv_par05")
	//PutSX1("UAII011","06","Num. Serie até"    ,"","","mv_ch06","C",20,0,0,"G","",""   ,"","","mv_par06")
	//PutSX1("UAII011","07","Local Impressao"   ,"","","mv_ch07","C",06,0,0,"G","","CB5","","","mv_par07")


	CBChkTemplate()
	IF ! &(cPerg)("UAII011",.T.)
		Return
	EndIF
	IF IsTelNet()
		VtMsg('Imprimindo')
		ACDI011LO()
	Else
		Processa({|| ACDI011LO()})
	EndIF

Return

Static Function ACDI011LO()

	Local cIndexSBF,cCondicao
	Local cCodLoc,cCodAlmox,aRet
	Local cRet:=''
	Local lIMGT1 := ExistBlock('IMGT1')
	Local lIMG00 := ExistBlock('IMG00')
	
	IF ! CB5SetImp(MV_PAR07,IsTelNet())
		Return .f.
	EndIF

	cIndexSBF := CriaTrab(nil,.f.)
	DbSelectArea("SBF")
	cCondicao :=""
	cCondicao := cCondicao + "BF_FILIAL    == '"+ xFilial()+"' .And. "
	cCondicao := cCondicao + "BF_PRODUTO   >= '"+ mv_par01 +"' .And. "
	cCondicao := cCondicao + "BF_PRODUTO   <= '"+ mv_par02 +"' .And. "
	cCondicao := cCondicao + "BF_LOCAL     >= '"+ mv_par03 +"' .And. "
	cCondicao := cCondicao + "BF_LOCAL     <= '"+ mv_par04 +"' .And. "
	cCondicao := cCondicao + "BF_NUMSERI   >= '"+ mv_par05 +"' .And. "
	cCondicao := cCondicao + "BF_NUMSERI   <= '"+ mv_par06 +"' .And. "
	cCondicao := cCondicao + "BF_NUMSERI   <> ' ' "
	IndRegua("SBF",cIndexSBF,"BF_LOCAL",,cCondicao,,.f.)
	DBGoTop()

	While ! SBF->(Eof())
		IF lIMGT1
			ExecBlock("IMGT1",.f.,,)
		EndIF
		SBF->(DbSkip())
	End
	IF lIMG00
		ExecBlock("IMG00",,,{cRet+ProcName()})
	EndIF

	MSCBCLOSEPRINTER()
	RetIndex("SBF")
	Ferase(cIndexSBF+OrdBagExt())

Return .T.
