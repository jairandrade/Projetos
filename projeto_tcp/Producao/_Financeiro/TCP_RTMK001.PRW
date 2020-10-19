#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RTMK001
Rotina para geração de relatório de gestão de cobranças

@return 
@author Felipe Toazza Caldeira
@since 16/11/2015

/*/
//-------------------------------------------------------------------------------
User Function RTMK001()
Private cPerg := "RTMK001"   
Private cData1 := ""                      
Private cData2 := ""                      
Private cData3 := ""                      
Private cData4 := ""                      
Private cData5 := ""                      
Private cData6 := ""                      
Private cData7 := ""                      
Private cData8 := ""
Private cData9 := ""
Private cData10 := ""
Private cData11 := ""
Private cData12 := ""
Private cData13 := ""
Private cData14 := ""   

AjustaSX1(cPerg)	

If !Pergunte(cPerg,.t.)
   Return
Endif

oReport := ReportDef()
oReport:PrintDialog()


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Configura o objeto TReport. 

@sample	ReportDef() 

@author Felipe Toazza Caldeira
@since	12/11/2015
@return	oReport - Objeto de impressão do relatório
/*/
//-------------------------------------------------------------------   
Static Function ReportDef() 

Local cTituRel	:= "Relatório Gerencial CAR"
Local cDescRel 	:= "Este programa ira emitir o relatório "+cTituRel
Local aOrdem   	:= {} 
Local oReport  
Local oSection1
Local oSection11
Local oSection2
Local oSection3
Local oSection4
Local oBreak1
Local oBreak2

oReport := TReport():New(cPerg,cTituRel,cPerg, {|oReport| ReportPrint(oReport)},cDescRel)   

oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 
oReport:HideParamPage()
oReport:DisableOrientation()
 
oSection1 := TRSection():New(oReport," CAR - Relatório Contas a Receber - "+DtoC(MV_PAR07),{}) 
TRCell():new(oSection1,"DETALHA"		,"QRY1"		,"Detalhamento"		,"@!"						,40)
TRCell():new(oSection1,"TOTAL"			,"QRY1"		,"Total"	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection1,"SERV"			,"QRY1"		,"Serviços"	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection1,"VAZIO"			,"QRY1"		,"Vazio"	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection1,"JURMUL"			,"QRY1"		,"Juros/Multa" 		,"@!"						,5)
TRCell():new(oSection1,"ATRASO"			,"QRY1"		,"Dias Atraso"	   	,"@!"						,5)
oSection1:Cell("TOTAL"):nHeaderAlign := 3
oSection1:Cell("SERV"):nHeaderAlign := 3
oSection1:Cell("VAZIO"):nHeaderAlign := 3

oSection2 := TRSection():New(oReport,"Comparação Armador - Vencido",{}) 
TRCell():new(oSection2,"A1_RESFAT"		,"QRY3"		,"Resp. Fat"			,"@!"						,20)
TRCell():new(oSection2,"A1_NOME"		,"QRY3"		,"Total Vencidos"		,"@!"						,40)
TRCell():new(oSection2,"VAL_VCANT"		,"QRY3"		,DtoC(MV_PAR07-7)		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection2,"VAL_VCATU"		,"QRY3"		,DtoC(MV_PAR07)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection2,"DIFERE"			,"QRY3"		,"Delta"	   			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection2:Cell("VAL_VCANT"):nHeaderAlign := 3
oSection2:Cell("VAL_VCATU"):nHeaderAlign := 3
oSection2:Cell("DIFERE"):nHeaderAlign := 3

dDomingo := MV_PAR07
While Dow(dDomingo) != 1
 	dDomingo := dDomingo + 1
EndDo

oSection3 := TRSection():New(oReport,"Comparação Armador - A Vencer",{}) 
TRCell():new(oSection3,"A1_RESFAT"		,"QRY4"		,"Resp. Fat"				,"@!"						,20)
TRCell():new(oSection3,"A1_NOME"		,"QRY4"		,"Total Vencer"				,"@!"						,40)
TRCell():new(oSection3,"VALD1"			,"QRY4"		,DtoC(dDomingo+1)			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection3,"VALD2"			,"QRY4"		,DtoC(dDomingo+2)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection3,"VALD3"			,"QRY4"		,DtoC(dDomingo+3)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection3,"VALD4"			,"QRY4"		,DtoC(dDomingo+4)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection3,"VALD5"			,"QRY4"		,DtoC(dDomingo+5)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection3:Cell("VALD1"):nHeaderAlign := 3
oSection3:Cell("VALD2"):nHeaderAlign := 3
oSection3:Cell("VALD3"):nHeaderAlign := 3
oSection3:Cell("VALD4"):nHeaderAlign := 3
oSection3:Cell("VALD5"):nHeaderAlign := 3
                                          
dAuxData := MonthSub(StoD(SubStr(DtoS(MV_PAR07),1,6)+'01'),14)
oSection4 := TRSection():New(oReport,"Acompanhamento Mensal",{}) 
TRCell():new(oSection4,"A1_TIPOCR"	,"QRY10"		,"R$ "				,"@!"						,20)
cData1 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD1"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")  

dAuxData := MonthSum(dAuxData,1)
cData2 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD2"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData3 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD3"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData4 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD4"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData5 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD5"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData6 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD6"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData7 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD7"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData8 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD8"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData9 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD9"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData10 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD10"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData11 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD11"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData12 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD12"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData13 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD13"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")

dAuxData := MonthSum(dAuxData,1)    
cData14 := Substr(DtoS(dAuxData),1,6)
TRCell():new(oSection4,"VALD14"		,"QRY10"		,Substr(cMonth(dAuxData),1,3)+'/'+Alltrim(Str(Year(dAuxData)))	,"@E 9,999,999,999.99"  ,19,,,"RIGHT",,"RIGHT")
oSection4:Cell("VALD1"):nHeaderAlign := 3
oSection4:Cell("VALD2"):nHeaderAlign := 3
oSection4:Cell("VALD3"):nHeaderAlign := 3
oSection4:Cell("VALD4"):nHeaderAlign := 3
oSection4:Cell("VALD5"):nHeaderAlign := 3
oSection4:Cell("VALD6"):nHeaderAlign := 3
oSection4:Cell("VALD7"):nHeaderAlign := 3
oSection4:Cell("VALD8"):nHeaderAlign := 3
oSection4:Cell("VALD9"):nHeaderAlign := 3
oSection4:Cell("VALD10"):nHeaderAlign := 3
oSection4:Cell("VALD11"):nHeaderAlign := 3
oSection4:Cell("VALD12"):nHeaderAlign := 3
oSection4:Cell("VALD13"):nHeaderAlign := 3
oSection4:Cell("VALD14"):nHeaderAlign := 3

oSection5 := TRSection():New(oReport,"Comparação TCP Log - Vencido",{}) 
TRCell():new(oSection5,"A1_RESFAT"		,"QRY3"		,"Resp. Fat"			,"@!"						,20)
TRCell():new(oSection5,"A1_NOME"		,"QRY3"		,"Total Vencidos"		,"@!"						,40)
TRCell():new(oSection5,"VAL_VCANT"		,"QRY3"		,DtoC(MV_PAR07-7)		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection5,"VAL_VCATU"		,"QRY3"		,DtoC(MV_PAR07)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection5,"DIFERE"			,"QRY3"		,"Delta"	   			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection5:Cell("VAL_VCANT"):nHeaderAlign := 3
oSection5:Cell("VAL_VCATU"):nHeaderAlign := 3
oSection5:Cell("DIFERE"):nHeaderAlign := 3


oSection6 := TRSection():New(oReport,"Comparação TCP Log - A Vencer",{}) 
TRCell():new(oSection6,"A1_RESFAT"		,"QRY4"		,"Resp. Fat"				,"@!"						,20)
TRCell():new(oSection6,"A1_NOME"		,"QRY4"		,"Total Vencer"				,"@!"						,40)
TRCell():new(oSection6,"VALD1"			,"QRY4"		,DtoC(dDomingo+1)			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection6,"VALD2"			,"QRY4"		,DtoC(dDomingo+2)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection6,"VALD3"			,"QRY4"		,DtoC(dDomingo+3)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection6,"VALD4"			,"QRY4"		,DtoC(dDomingo+4)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection6,"VALD5"			,"QRY4"		,DtoC(dDomingo+5)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection6:Cell("VALD1"):nHeaderAlign := 3
oSection6:Cell("VALD2"):nHeaderAlign := 3
oSection6:Cell("VALD3"):nHeaderAlign := 3
oSection6:Cell("VALD4"):nHeaderAlign := 3
oSection6:Cell("VALD5"):nHeaderAlign := 3

oSection7 := TRSection():New(oReport,"Comparação Terminal e TOP50 - Vencido",{}) 
TRCell():new(oSection7,"A1_RESFAT"		,"QRY3"		,"Resp. Fat"			,"@!"						,20)
TRCell():new(oSection7,"A1_NOME"		,"QRY3"		,"Total Vencidos"		,"@!"						,40)
TRCell():new(oSection7,"VAL_VCANT"		,"QRY3"		,DtoC(MV_PAR07-7)		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection7,"VAL_VCATU"		,"QRY3"		,DtoC(MV_PAR07)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection7,"DIFERE"			,"QRY3"		,"Delta"	   			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection7:Cell("VAL_VCANT"):nHeaderAlign := 3
oSection7:Cell("VAL_VCATU"):nHeaderAlign := 3
oSection7:Cell("DIFERE"):nHeaderAlign := 3


oSection8 := TRSection():New(oReport,"Comparação Terminal e TOP50 - A Vencer",{}) 
TRCell():new(oSection8,"A1_RESFAT"		,"QRY4"		,"Resp. Fat"				,"@!"						,20)
TRCell():new(oSection8,"A1_NOME"		,"QRY4"		,"Total Vencer"				,"@!"						,40)
TRCell():new(oSection8,"VALD1"			,"QRY4"		,DtoC(dDomingo+1)			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection8,"VALD2"			,"QRY4"		,DtoC(dDomingo+2)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection8,"VALD3"			,"QRY4"		,DtoC(dDomingo+3)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection8,"VALD4"			,"QRY4"		,DtoC(dDomingo+4)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection8,"VALD5"			,"QRY4"		,DtoC(dDomingo+5)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection8:Cell("VALD1"):nHeaderAlign := 3
oSection8:Cell("VALD2"):nHeaderAlign := 3
oSection8:Cell("VALD3"):nHeaderAlign := 3
oSection8:Cell("VALD4"):nHeaderAlign := 3
oSection8:Cell("VALD5"):nHeaderAlign := 3

oSection9 := TRSection():New(oReport,"Comparativo Cobrança Judicial",{}) 
TRCell():new(oSection9,"A1_RESFAT"		,"QRY3"		,"Resp. Fat"			,"@!"						,20)
TRCell():new(oSection9,"A1_NOME"		,"QRY3"		,"Total Vencidos"		,"@!"						,40)
TRCell():new(oSection9,"VAL_VCANT"		,"QRY3"		,DtoC(MV_PAR07-7)		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection9,"VAL_VCATU"		,"QRY3"		,DtoC(MV_PAR07)	   		,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
TRCell():new(oSection9,"DIFERE"			,"QRY3"		,"Delta"	   			,"@E 9,999,999,999,999.99"  ,22,,,"RIGHT",,"RIGHT")
oSection9:Cell("VAL_VCANT"):nHeaderAlign := 3
oSection9:Cell("VAL_VCATU"):nHeaderAlign := 3
oSection9:Cell("DIFERE"):nHeaderAlign := 3


                                                    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função de impressão do relatório.

@sample	ReportPrint(oReport)

@param	oReport - Objeto do tReport para impressão

@author	Alessandro Smaha
@since	29/09/2014
@return	NIL
/*/
//-------------------------------------------------------------------   
Static Function ReportPrint(oReport)
    
    Local cTextPrt	 := ""                                                                            
	Local nTotTit	 := 0
	Local nValPerc	 := 0
	Local oSection1  := oReport:Section(1)				// Define a secao 1 do relatorio
	Local oSection2  := oReport:Section(2)				// Define a secao 2 do relatorio 
	Local oSection3  := oReport:Section(3)				// Define a secao 3 do relatorio 
	Local oSection4	 := oReport:Section(4)
	Local oSection5	 := oReport:Section(5)
	Local oSection6	 := oReport:Section(6)
	Local oSection7	 := oReport:Section(7)
	Local oSection8	 := oReport:Section(8)
	Local oSection9	 := oReport:Section(9)
    Local nValTot	 := 0   
    Local cOperador  := ""
    Local nI
    
	dDomingo := MV_PAR07
	While Dow(dDomingo) != 1
	 	dDomingo := dDomingo + 1
	EndDo
	
              
    fMontaQry( )
    
    oReport:SetMeter(0)
            
    oReport:SetTitle( oReport:Title() )  
    oReport:SkipLine(2)   
      
   	DbSelectArea("QRY1")   
	QRY1->(DbGoTop()) 
   	DbSelectArea("QRY2")   
	QRY2->(DbGoTop()) 


	oReport:PrintText(oSection1:cTitle)
		  	
	oSection1:Init()

//**************************************************************************
//
//		Fazer o somatório para a primeira linha
//
//**************************************************************************
    nTotal 	:= nTotSer := nTotVaz	:= 0                                          
    
    nTotalAV 	:= nTotSerAV 	:= nTotVazAV	:= 0                                              

    nTotalVC 	:= nTotSerVC 	:= nTotVazVC	:= 0                                              

    nTotVZ1 	:= nTotVZ2 	:= nTotVZ3	:= nTotVZ4	:= nTotVZ5		:= 0
    nTotSV1 	:= nTotSV2 	:= nTotSV3	:= nTotSV4	:= nTotSV5		:= 0

	While !oReport:Cancel() .AND. !QRY1->(Eof())
			
		nTotal		+= QRY1->VALVENCVZ+QRY1->VALVENCSV-QRY1->VALPGVZ-QRY1->VALPGVSV     //Total Geral
		nTotSer		+= QRY1->VALVENCSV-QRY1->VALPGVSV
		nTotVaz		+= QRY1->VALVENCVZ-QRY1->VALPGVZ
		nTotalAV	+= QRY1->VALVENCVZ+QRY1->VALVENCSV-QRY1->VALPGVZ-QRY1->VALPGVSV   //Total a vencer
		nTotSerAV	+= QRY1->VALVENCSV-QRY1->VALPGVSV
		nTotVazAV	+= QRY1->VALVENCVZ-QRY1->VALPGVZ
									
  		QRY1->(DbSkip())
				
	EndDo 

	QRY2->(DbGoTop()) 
        

	While !oReport:Cancel() .AND. !QRY2->(Eof())
			
		nTotal		+= QRY2->VALVCVZ+QRY2->VALVCSV     //Total Geral
		nTotSer		+= QRY2->VALVCSV
		nTotVaz		+= QRY2->VALVCVZ
		nTotalVC	+= QRY2->VALVCVZ+QRY2->VALVCSV  //Total a vencer
		nTotSerVC	+= QRY2->VALVCSV
		nTotVazVC	+= QRY2->VALVCVZ
		
		If Alltrim(QRY2->A1_TIPOCR) == 'ARMADOR'
			nTotSV1 += QRY2->VALVCSV 
			nTotVZ1 += QRY2->VALVCVZ			
		ElseIf Alltrim(QRY2->A1_TIPOCR) == 'TCPLOG'
			nTotSV4 += QRY2->VALVCSV 
			//nTotVZ4 += QRY2->VALVCVZ							
		ElseIF Alltrim(QRY2->A1_TIPOCR) == 'TERMINAL'
			nTotSV2 += QRY2->VALVCSV 
			//nTotVZ2 += QRY2->VALVCVZ					
		ElseIf Alltrim(QRY2->A1_TIPOCR) == 'TOP50'
			nTotSV3 += QRY2->VALVCSV 
			//nTotVZ3 += QRY2->VALVCVZ							
		Else
			nTotSV5 += QRY2->VALVCSV 
			//nTotVZ5 += QRY2->VALVCVZ							
		EndIf
							
  		QRY2->(DbSkip())
				
	EndDo 

//**************************************************************************
//
//		Montagem dos valores do cenário atual
//
//**************************************************************************
	oSection1:Cell("DETALHA"):SetValue("CAR")
	oSection1:Cell("TOTAL"):SetValue(nTotal)
	oSection1:Cell("SERV"):SetValue(nTotSer)			 
	oSection1:Cell("VAZIO"):SetValue(nTotVaz)	
	oSection1:Cell("JURMUL"):SetValue('N.A')			 
	oSection1:Cell("ATRASO"):SetValue('N.A')			 
	oSection1:PrintLine()


	oSection1:Cell("DETALHA"):SetValue("A VENCER")
	oSection1:Cell("TOTAL"):SetValue(nTotalAV)
	oSection1:Cell("SERV"):SetValue(nTotSerAV)			 
	oSection1:Cell("VAZIO"):SetValue(nTotVazAV)	
	oSection1:Cell("JURMUL"):SetValue('N.A')			 
	oSection1:Cell("ATRASO"):SetValue('N.A')			 
	oSection1:PrintLine()

	QRY1->(DbGoTop()) 

	While !oReport:Cancel() .AND. !QRY1->(Eof())
			
		oReport:IncMeter() 
			
		If oReport:Cancel()
			Exit
		EndIf  

		oSection1:Cell("DETALHA"):SetValue('-   '+QRY1->A1_TIPOCR)
		oSection1:Cell("TOTAL"):SetValue(QRY1->VALVENCVZ+QRY1->VALVENCSV-QRY1->VALPGVZ-QRY1->VALPGVSV)
		oSection1:Cell("SERV"):SetValue(QRY1->VALVENCSV-QRY1->VALPGVSV)			 
		oSection1:Cell("VAZIO"):SetValue(QRY1->VALVENCVZ-QRY1->VALPGVZ)	
		oSection1:Cell("JURMUL"):SetValue('N.A')			 
		oSection1:Cell("ATRASO"):SetValue('N.A')			 

		oSection1:PrintLine()
							
  		QRY1->(DbSkip())
				
	EndDo 

	oSection1:Cell("DETALHA"):SetValue("VENCIDOS")
	oSection1:Cell("TOTAL"):SetValue(nTotalVC)
	oSection1:Cell("SERV"):SetValue(nTotSerVC)			 
	oSection1:Cell("VAZIO"):SetValue(nTotVazVC)	
	oSection1:Cell("JURMUL"):SetValue('N.A')			 
	oSection1:Cell("ATRASO"):SetValue('N.A')			 
	oSection1:PrintLine()

	oSection1:Cell("DETALHA"):SetValue('-   '+"ARMADOR")
	oSection1:Cell("TOTAL"):SetValue(nTotSV1+nTotVZ1)
	oSection1:Cell("SERV"):SetValue(nTotSV1)			 
	oSection1:Cell("VAZIO"):SetValue(nTotVZ1)	
	oSection1:Cell("JURMUL"):SetValue('N.A')			 
	oSection1:Cell("ATRASO"):SetValue('N.A')			 
	oSection1:PrintLine()

	QRY2->(DbGoTop()) 
                                              
	cAuxTer := ''
	cAuxTop := ''
	cAuxLog	:= '' 
	cAuxOut	:= ''
	While !oReport:Cancel() .AND. !QRY2->(Eof())
			
		oReport:IncMeter() 

		If Empty(cAuxLog) .AND. QRY2->A1_TIPOCR != 'ARMADOR' 
			oSection1:Cell("DETALHA"):SetValue('-   '+"TCP Log")
			oSection1:Cell("TOTAL"):SetValue(nTotSV4+nTotVZ4)
			oSection1:Cell("SERV"):SetValue(nTotSV4)			 
			oSection1:Cell("VAZIO"):SetValue(nTotVZ4)	
			oSection1:Cell("JURMUL"):SetValue('N.A')			 
			oSection1:Cell("ATRASO"):SetValue('N.A')			 
			cAuxLog := 'USADO'
			oSection1:PrintLine()
		EndIf			                                     
//		.AND. QRY2->A1_TIPOCR != "TOP50" .AND. QRY2->A1_TIPOCR != "TERMINAL" 
		If Empty(cAuxTer) .AND. QRY2->A1_TIPOCR != 'ARMADOR' .AND. QRY2->A1_TIPOCR != "TCPLOG" 
			oSection1:Cell("DETALHA"):SetValue('-   '+"Terminal")
			oSection1:Cell("TOTAL"):SetValue(nTotSV2+nTotVZ2)
			oSection1:Cell("SERV"):SetValue(nTotSV2)			 
			oSection1:Cell("VAZIO"):SetValue(nTotVZ2)	
			oSection1:Cell("JURMUL"):SetValue('N.A')			 
			oSection1:Cell("ATRASO"):SetValue('N.A')
			cAuxTer := "USADO"			 
			oSection1:PrintLine()
		EndIf
		If Empty(cAuxTop) .AND. QRY2->A1_TIPOCR != "TERMINAL" .AND. QRY2->A1_TIPOCR != 'ARMADOR' .AND. QRY2->A1_TIPOCR != "TCPLOG"
			oSection1:Cell("DETALHA"):SetValue('-   '+"TOP50")
			oSection1:Cell("TOTAL"):SetValue(nTotSV3+nTotVZ3)
			oSection1:Cell("SERV"):SetValue(nTotSV3)			 
			oSection1:Cell("VAZIO"):SetValue(nTotVZ3)	
			oSection1:Cell("JURMUL"):SetValue('N.A')			 
			oSection1:Cell("ATRASO"):SetValue('N.A')			 
			cAuxTop := 'USADO'
			oSection1:PrintLine()  
		EndIf
		If Empty(cAuxOut) .AND. QRY2->A1_TIPOCR != "TCPLOG"  .AND. QRY2->A1_TIPOCR != "TOP50" 	 .AND. QRY2->A1_TIPOCR != "TERMINAL" .AND. QRY2->A1_TIPOCR != 'ARMADOR' 	
			oSection1:Cell("DETALHA"):SetValue('-   '+"Outros")
			oSection1:Cell("TOTAL"):SetValue(nTotSV5+nTotVZ5)
			oSection1:Cell("SERV"):SetValue(nTotSV5)			 
			oSection1:Cell("VAZIO"):SetValue(nTotVZ5)	
			oSection1:Cell("JURMUL"):SetValue('N.A')			 
			oSection1:Cell("ATRASO"):SetValue('N.A')			 
			cAuxOut := 'USADO'
			oSection1:PrintLine()				
		EndIf 

		oSection1:Cell("DETALHA"):SetValue('-      '+QRY2->A1_NOME)
		oSection1:Cell("TOTAL"):SetValue(QRY2->VALVCVZ+QRY2->VALVCSV)
		oSection1:Cell("SERV"):SetValue(QRY2->VALVCSV)			 
		oSection1:Cell("VAZIO"):SetValue(QRY2->VALVCVZ)	
		oSection1:Cell("JURMUL"):SetValue('N.A')			 
		oSection1:Cell("ATRASO"):SetValue('N.A')			 

		oSection1:PrintLine()
							
  		QRY2->(DbSkip())
				
	EndDo 
	oSection1:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações de acompanhamento mes/ano
//
//**************************************************************************


   	DbSelectArea("QRY10")   
	QRY10->(DbGoTop()) 

	oReport:PrintText(oSection4:cTitle)
		  	
	oSection4:Init()

	oSection4:Cell("A1_TIPOCR"):SetValue("A Vencer")
	oSection4:Cell("VALD1"):SetValue()			 
	oSection4:Cell("VALD2"):SetValue()	
	oSection4:Cell("VALD3"):SetValue()			 
	oSection4:Cell("VALD4"):SetValue()			 
	oSection4:Cell("VALD5"):SetValue()	
	oSection4:Cell("VALD6"):SetValue()			 
	oSection4:Cell("VALD7"):SetValue()			 
	oSection4:Cell("VALD8"):SetValue()	
	oSection4:Cell("VALD9"):SetValue()			 
	oSection4:Cell("VALD10"):SetValue()			 
	oSection4:Cell("VALD11"):SetValue()			 
	oSection4:Cell("VALD12"):SetValue()	
	oSection4:Cell("VALD13"):SetValue()			 
	oSection4:Cell("VALD14"):SetValue()			 
	oSection4:PrintLine()
    aTotAnoAV := {} 
    aTotAnoVC := {}
	While !oReport:Cancel() .AND. !QRY10->(Eof()).AND. QRY10->Z10_TIPO == '1'
		cAuxTP := Alltrim(QRY10->Z10_TPCLI)
 		If QRY10->Z10_VAZIO == '1'
	 		cAuxTP := "   VAZIOS"
 		EndIf		
			
		IF QRY10->Z10_ANO+QRY10->Z10_MES == cData1 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][2] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData2 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][3] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData3 			
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][4] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData4 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][5] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData5 			
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][6] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData6 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][7] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData7  
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][8] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData8 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][9] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData9 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][10] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData10 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][11] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData11 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][12] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData12 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0})
		 	Else
			 	aTotAnoAV[nPosCli][13] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData13 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0})
		 	Else
			 	aTotAnoAV[nPosCli][14] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData14 
		 	nPosCli := aScan(aTotAnoAV, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoAV,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR})
		 	Else
			 	aTotAnoAV[nPosCli][15] := QRY10->Z10_VALOR
		 	EndIf
		EndIf										
									
  		QRY10->(DbSkip())
				
	EndDo 
                                                 
	For nI := 1 to Len(aTotAnoAV)                                                
		oSection4:Cell("A1_TIPOCR"):SetValue('-   '+aTotAnoAV[nI][1])
		oSection4:Cell("VALD1"):SetValue(aTotAnoAV[nI][2])			 
		oSection4:Cell("VALD2"):SetValue(aTotAnoAV[nI][3])	
		oSection4:Cell("VALD3"):SetValue(aTotAnoAV[nI][4])			 
		oSection4:Cell("VALD4"):SetValue(aTotAnoAV[nI][5])			 
		oSection4:Cell("VALD5"):SetValue(aTotAnoAV[nI][6])	
		oSection4:Cell("VALD6"):SetValue(aTotAnoAV[nI][7])			 
		oSection4:Cell("VALD7"):SetValue(aTotAnoAV[nI][8])			 
		oSection4:Cell("VALD8"):SetValue(aTotAnoAV[nI][9])	
		oSection4:Cell("VALD9"):SetValue(aTotAnoAV[nI][10])			 
		oSection4:Cell("VALD10"):SetValue(aTotAnoAV[nI][11])			 
		oSection4:Cell("VALD11"):SetValue(aTotAnoAV[nI][12])	
		oSection4:Cell("VALD12"):SetValue(aTotAnoAV[nI][13])	
		oSection4:Cell("VALD13"):SetValue(aTotAnoAV[nI][14])			 
		oSection4:Cell("VALD14"):SetValue(aTotAnoAV[nI][15])			                                         
		oSection4:PrintLine()
	Next


	oSection4:Cell("A1_TIPOCR"):SetValue("Vencido")
	oSection4:Cell("VALD1"):SetValue()			 
	oSection4:Cell("VALD2"):SetValue()	
	oSection4:Cell("VALD3"):SetValue()			 
	oSection4:Cell("VALD4"):SetValue()			 
	oSection4:Cell("VALD5"):SetValue()	
	oSection4:Cell("VALD6"):SetValue()			 
	oSection4:Cell("VALD7"):SetValue()			 
	oSection4:Cell("VALD8"):SetValue()	
	oSection4:Cell("VALD9"):SetValue()			 
	oSection4:Cell("VALD10"):SetValue()			 
	oSection4:Cell("VALD11"):SetValue()			 	
	oSection4:Cell("VALD12"):SetValue()	
	oSection4:Cell("VALD13"):SetValue()			 
	oSection4:Cell("VALD14"):SetValue()			 
	oSection4:PrintLine()
	

	While !oReport:Cancel() .AND. !QRY10->(Eof()).AND. QRY10->Z10_TIPO == '2'
		cAuxTP := Alltrim(QRY10->Z10_TPCLI)
 		If QRY10->Z10_VAZIO == '1'
	 		cAuxTP := "   VAZIOS"
 		EndIf		
			
		IF QRY10->Z10_ANO+QRY10->Z10_MES == cData1 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][2] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData2 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][3] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData3 			
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][4] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData4 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][5] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData5 			
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][6] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData6 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][7] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData7  
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][8] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData8 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][9] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData9 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][10] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData10 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][11] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData11 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][12] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData12 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0,0})
		 	Else
			 	aTotAnoVC[nPosCli][13] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData13 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR,0})
		 	Else
			 	aTotAnoVC[nPosCli][14] := QRY10->Z10_VALOR
		 	EndIf
		ElseIf QRY10->Z10_ANO+QRY10->Z10_MES == cData14 
		 	nPosCli := aScan(aTotAnoVC, { |x| Upper(AllTrim(x[1])) == cAuxTP})
		 	If nPosCli == 0                     
		 	 	Aadd(aTotAnoVC,{cAuxTP,0,0,0,0,0,0,0,0,0,0,0,0,0,QRY10->Z10_VALOR})
		 	Else
			 	aTotAnoVC[nPosCli][15] := QRY10->Z10_VALOR
		 	EndIf
		EndIf										
									
  		QRY10->(DbSkip())
				
	EndDo 
                                                 
	For nI := 1 to Len(aTotAnoVC)                                                
		oSection4:Cell("A1_TIPOCR"):SetValue('-   '+aTotAnoVC[nI][1])
		oSection4:Cell("VALD1"):SetValue(aTotAnoVC[nI][2])			 
		oSection4:Cell("VALD2"):SetValue(aTotAnoVC[nI][3])	
		oSection4:Cell("VALD3"):SetValue(aTotAnoVC[nI][4])			 
		oSection4:Cell("VALD4"):SetValue(aTotAnoVC[nI][5])			 
		oSection4:Cell("VALD5"):SetValue(aTotAnoVC[nI][6])	
		oSection4:Cell("VALD6"):SetValue(aTotAnoVC[nI][7])			 
		oSection4:Cell("VALD7"):SetValue(aTotAnoVC[nI][8])			 
		oSection4:Cell("VALD8"):SetValue(aTotAnoVC[nI][9])	
		oSection4:Cell("VALD9"):SetValue(aTotAnoVC[nI][10])			 
		oSection4:Cell("VALD10"):SetValue(aTotAnoVC[nI][11])			 
		oSection4:Cell("VALD11"):SetValue(aTotAnoVC[nI][12])	
		oSection4:Cell("VALD12"):SetValue(aTotAnoVC[nI][13])	
		oSection4:Cell("VALD13"):SetValue(aTotAnoVC[nI][14])			 
		oSection4:Cell("VALD14"):SetValue(aTotAnoVC[nI][15])			                                         
		oSection4:PrintLine()
	Next

	oSection4:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações de vencidos dos armadores
//
//**************************************************************************

   	DbSelectArea("QRY3")   
	QRY3->(DbGoTop()) 
	oReport:PrintText(oSection2:cTitle)		  	
	oSection2:Init()

    nTotAtu 	:= 0
    nTotPass 	:= 0
	While !oReport:Cancel() .AND. !QRY3->(Eof())
			
		nTotAtu		+= QRY3->VAL_VCATU     //Total Geral
		nTotPass	+= IIF(QRY3->VAL_VCANT>0,QRY3->VAL_VCANT,0)
									
  		QRY3->(DbSkip())
				
	EndDo 

	oSection2:Cell("A1_RESFAT"):SetValue(" ")
	oSection2:Cell("A1_NOME"):SetValue("  ")
	oSection2:Cell("VAL_VCANT"):SetValue(nTotPass)			 
	oSection2:Cell("VAL_VCATU"):SetValue(nTotAtu)	
	oSection2:Cell("DIFERE"):SetValue(nTotAtu-nTotPass)			 
	oSection2:PrintLine()

	QRY3->(DbGoTop()) 

	While !oReport:Cancel() .AND. !QRY3->(Eof())
			
		oReport:IncMeter() 			
		If QRY3->VAL_VCATU > 0 .OR. QRY3->VAL_VCANT > 0
			oSection2:Cell("A1_RESFAT"):SetValue(QRY3->A1_RESFAT)
			oSection2:Cell("A1_NOME"):SetValue(QRY3->A1_NOME)
			oSection2:Cell("VAL_VCANT"):SetValue(IIF(QRY3->VAL_VCANT>0,QRY3->VAL_VCANT,0))			 
			oSection2:Cell("VAL_VCATU"):SetValue(QRY3->VAL_VCATU)	
			oSection2:Cell("DIFERE"):SetValue(QRY3->VAL_VCATU-IIF(QRY3->VAL_VCANT>0,QRY3->VAL_VCANT,0))			 
			oSection2:PrintLine()
		EndIf								
  		QRY3->(DbSkip())
				
	EndDo 
	oSection2:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações A VENCER DOS ARMADORES
//
//**************************************************************************
   	DbSelectArea("QRY4")   
	QRY4->(DbGoTop()) 

	oReport:PrintText(oSection3:cTitle)		  	
	oSection3:Init()

    nTotD1 	:= nTotD2 	:= nTotD3	:= nTotD4	:= nTotD5	:= nTotD6	:= nTotD7	:= 0      
              
	cData1S := DtoS(dDomingo+1)
	cData2S := DtoS(dDomingo+2)
	cData3S := DtoS(dDomingo+3)
	cData4S := DtoS(dDomingo+4)
	cData5S := DtoS(dDomingo+5)
	aDatasCli := {}
	While !oReport:Cancel() .AND. !QRY4->(Eof())
		IF QRY4->E1_VENCREA == cData1S
		 	nTotD1 += QRY4->VAL_VCATU 
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,QRY4->VAL_VCATU,0,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][3]+QRY4->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY4->E1_VENCREA == cData2S
			nTotD2 += QRY4->VAL_VCATU                                     
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,QRY4->VAL_VCATU,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][4]+QRY4->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY4->E1_VENCREA == cData3S
			nTotD3 += QRY4->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,0,QRY4->VAL_VCATU,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][5]+QRY4->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY4->E1_VENCREA == cData4S
			nTotD4 += QRY4->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,0,0,QRY4->VAL_VCATU,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][6]+QRY4->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY4->E1_VENCREA == cData5S
			nTotD5 += QRY4->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,0,0,0,QRY4->VAL_VCATU,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][7]+QRY4->VAL_VCATU			 	
		 	EndIf			
/*
		ElseIf QRY4->E1_VENCREA == cData6S
			nTotD6 += QRY4->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,0,0,0,0,QRY4->VAL_VCATU,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][8]+QRY4->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY4->E1_VENCREA == cData7S
			nTotD7 += QRY4->VAL_VCATU
			nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY4->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY4->A1_RESFAT,QRY4->A1_NOME,0,0,0,0,0,0,QRY4->VAL_VCATU})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][9]+QRY4->VAL_VCATU			 	
		 	EndIf		
*/		 	
		EndIf										
									
  		QRY4->(DbSkip())
				
	EndDo 

	oSection3:Cell("A1_RESFAT"):SetValue(" ")
	oSection3:Cell("A1_NOME"):SetValue("Total a Vencer - Semana")
	oSection3:Cell("VALD1"):SetValue(nTotD1)			 
	oSection3:Cell("VALD2"):SetValue(nTotD2)	
	oSection3:Cell("VALD3"):SetValue(nTotD3)			 
	oSection3:Cell("VALD4"):SetValue(nTotD4)			 
	oSection3:Cell("VALD5"):SetValue(nTotD5)	
	oSection3:PrintLine()

	For nI := 1 To Len(aDatasCli)
			
		oReport:IncMeter() 			

		oSection3:Cell("A1_RESFAT"):SetValue(aDatasCli[nI][1])
		oSection3:Cell("A1_NOME"):SetValue(aDatasCli[nI][2])
		oSection3:Cell("VALD1"):SetValue(aDatasCli[nI][3])			 
		oSection3:Cell("VALD2"):SetValue(aDatasCli[nI][4])	
		oSection3:Cell("VALD3"):SetValue(aDatasCli[nI][5])			 
		oSection3:Cell("VALD4"):SetValue(aDatasCli[nI][6])			 
		oSection3:Cell("VALD5"):SetValue(aDatasCli[nI][7])	
		oSection3:PrintLine()
				
	Next
	 
	oSection3:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações de vencidos dos TCPLog
//
//**************************************************************************
   	DbSelectArea("QRY5")   
	QRY5->(DbGoTop()) 

	oReport:PrintText(oSection5:cTitle)
	oSection5:Init()

    nTotAtu 	:= 0
    nTotPass 	:= 0
	While !oReport:Cancel() .AND. !QRY5->(Eof())
			
		nTotAtu		+= QRY5->VAL_VCATU     //Total Geral
		nTotPass	+= QRY5->VAL_VCANT
									
  		QRY5->(DbSkip())
				
	EndDo 

	oSection5:Cell("A1_RESFAT"):SetValue(" ")
	oSection5:Cell("A1_NOME"):SetValue("  ")
	oSection5:Cell("VAL_VCANT"):SetValue(nTotPass)			 
	oSection5:Cell("VAL_VCATU"):SetValue(nTotAtu)	
	oSection5:Cell("DIFERE"):SetValue(nTotAtu-nTotPass)			 
	oSection5:PrintLine()

	QRY5->(DbGoTop()) 

	While !oReport:Cancel() .AND. !QRY5->(Eof())
			
		oReport:IncMeter() 			
		If QRY5->VAL_VCATU > 0 .OR. QRY5->VAL_VCANT > 0
			oSection5:Cell("A1_RESFAT"):SetValue(QRY5->A1_RESFAT)
			oSection5:Cell("A1_NOME"):SetValue(QRY5->A1_NOME)
			oSection5:Cell("VAL_VCANT"):SetValue(IIF(QRY5->VAL_VCANT>0,QRY5->VAL_VCANT,0))			 
			oSection5:Cell("VAL_VCATU"):SetValue(QRY5->VAL_VCATU)	
			oSection5:Cell("DIFERE"):SetValue(QRY5->VAL_VCATU-IIF(QRY5->VAL_VCANT>0,QRY5->VAL_VCANT,0))			 
			oSection5:PrintLine()
		EndIf								
  		QRY5->(DbSkip())
				
	EndDo 
	oSection5:Finish()
	oReport:SkipLine(5)

//**************************************************************************
//
//	     Impressão das informações A VENCER TCPLOG
//
//**************************************************************************
	cTitSec3 := 'Comparação TCP Log - A Vencer'
   	DbSelectArea("QRY6")   
	QRY6->(DbGoTop()) 

	oReport:PrintText(oSection6:cTitle)		  	
	oSection6:Init()

    nTotD1 	:= nTotD2 	:= nTotD3	:= nTotD4	:= nTotD5	:= nTotD6	:= nTotD7	:= 0      
              
	aDatasCli := {}
	While !oReport:Cancel() .AND. !QRY6->(Eof())
		IF QRY6->E1_VENCREA == cData1S
		 	nTotD1 += QRY6->VAL_VCATU 
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,QRY6->VAL_VCATU,0,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][3]+QRY6->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY6->E1_VENCREA == cData2S
			nTotD2 += QRY6->VAL_VCATU                                     
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,QRY6->VAL_VCATU,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][4]+QRY6->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY6->E1_VENCREA == cData3S
			nTotD3 += QRY6->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,0,QRY6->VAL_VCATU,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][5]+QRY6->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY6->E1_VENCREA == cData4S
			nTotD4 += QRY6->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,0,0,QRY6->VAL_VCATU,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][6]+QRY6->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY6->E1_VENCREA == cData5S
			nTotD5 += QRY6->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,0,0,0,QRY6->VAL_VCATU,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][7]+QRY6->VAL_VCATU			 	
		 	EndIf			
/*
		ElseIf QRY6->E1_VENCREA == cData6S
			nTotD6 += QRY6->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,0,0,0,0,QRY6->VAL_VCATU,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][8]+QRY6->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY6->E1_VENCREA == cData7S
			nTotD7 += QRY6->VAL_VCATU
			nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY6->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY6->A1_RESFAT,QRY6->A1_NOME,0,0,0,0,0,0,QRY6->VAL_VCATU})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][9]+QRY6->VAL_VCATU			 	
		 	EndIf		
/*/
		EndIf										
									
  		QRY6->(DbSkip())
				
	EndDo 



	oSection6:Cell("A1_RESFAT"):SetValue(" ")
	oSection6:Cell("A1_NOME"):SetValue("Total a Vencer - Semana")
	oSection6:Cell("VALD1"):SetValue(nTotD1)			 
	oSection6:Cell("VALD2"):SetValue(nTotD2)	
	oSection6:Cell("VALD3"):SetValue(nTotD3)			 
	oSection6:Cell("VALD4"):SetValue(nTotD4)			 
	oSection6:Cell("VALD5"):SetValue(nTotD5)	
	oSection6:PrintLine()

	For nI := 1 To Len(aDatasCli)
			
		oReport:IncMeter() 			

		oSection6:Cell("A1_RESFAT"):SetValue(aDatasCli[nI][1])
		oSection6:Cell("A1_NOME"):SetValue(aDatasCli[nI][2])
		oSection6:Cell("VALD1"):SetValue(aDatasCli[nI][3])			 
		oSection6:Cell("VALD2"):SetValue(aDatasCli[nI][4])	
		oSection6:Cell("VALD3"):SetValue(aDatasCli[nI][5])			 
		oSection6:Cell("VALD4"):SetValue(aDatasCli[nI][6])			 
		oSection6:Cell("VALD5"):SetValue(aDatasCli[nI][7])	
		oSection6:PrintLine()
				
	Next
	 
	oSection6:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações de vencidos dos Terminal - Top50
//
//**************************************************************************

   	DbSelectArea("QRY7")   
	QRY7->(DbGoTop()) 

	oReport:PrintText(oSection7:cTitle)
	oSection7:Init()

    nTotAtu 	:= 0
    nTotPass 	:= 0
	While !oReport:Cancel() .AND. !QRY7->(Eof())
			
		nTotAtu		+= QRY7->VAL_VCATU     //Total Geral
		nTotPass	+= QRY7->VAL_VCANT
									
  		QRY7->(DbSkip())
				
	EndDo 
	
	oSection7:Cell("A1_RESFAT"):SetValue(" ")
	oSection7:Cell("A1_NOME"):SetValue("  ")
	oSection7:Cell("VAL_VCANT"):SetValue(nTotPass)			 
	oSection7:Cell("VAL_VCATU"):SetValue(nTotAtu)	
	oSection7:Cell("DIFERE"):SetValue(nTotAtu-nTotPass)			 
	oSection7:PrintLine()
    
	QRY7->(DbGoTop()) 

	While !oReport:Cancel() .AND. !QRY7->(Eof())
			
		oReport:IncMeter() 			
		If QRY7->VAL_VCATU > 0 .OR. QRY7->VAL_VCANT > 0

			oSection7:Cell("A1_RESFAT"):SetValue(QRY7->A1_RESFAT)
			oSection7:Cell("A1_NOME"):SetValue(QRY7->A1_NOME)
			oSection7:Cell("VAL_VCANT"):SetValue(QRY7->VAL_VCATU)			 
			oSection7:Cell("VAL_VCATU"):SetValue(QRY7->VAL_VCATU)	
			oSection7:Cell("DIFERE"):SetValue(QRY7->VAL_VCATU-QRY7->VAL_VCATU)			 
			oSection7:PrintLine()
	
		EndIf
								
  		QRY7->(DbSkip())
				
	EndDo 
	oSection7:Finish()
	oReport:SkipLine(5)                           
	
//**************************************************************************
//
//	     Impressão das informações A VENCER TERMINAL E TOP50
//
//**************************************************************************

   	DbSelectArea("QRY8")   
	QRY8->(DbGoTop()) 
	oReport:PrintText(oSection8:cTitle)		  	
	oSection8:Init()

    nTotD1 	:= nTotD2 	:= nTotD3	:= nTotD4	:= nTotD5	:= nTotD6	:= nTotD7	:= 0      
              
	aDatasCli := {}
	While !oReport:Cancel() .AND. !QRY8->(Eof())
		IF QRY8->E1_VENCREA == cData1S
		 	nTotD1 += QRY8->VAL_VCATU 
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,QRY8->VAL_VCATU,0,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][3]+QRY8->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY8->E1_VENCREA == cData2S
			nTotD2 += QRY8->VAL_VCATU                                     
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,QRY8->VAL_VCATU,0,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][4]+QRY8->VAL_VCATU			 	
		 	EndIf
		ElseIf QRY8->E1_VENCREA == cData3S
			nTotD3 += QRY8->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,0,QRY8->VAL_VCATU,0,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][5]+QRY8->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY8->E1_VENCREA == cData4S
			nTotD4 += QRY8->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,0,0,QRY8->VAL_VCATU,0,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][6]+QRY8->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY8->E1_VENCREA == cData5S
			nTotD5 += QRY8->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,0,0,0,QRY8->VAL_VCATU,0,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][7]+QRY8->VAL_VCATU			 	
		 	EndIf			
/*
		ElseIf QRY8->E1_VENCREA == cData6S
			nTotD6 += QRY8->VAL_VCATU
		 	nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,0,0,0,0,QRY8->VAL_VCATU,0})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][8]+QRY8->VAL_VCATU			 	
		 	EndIf			
		ElseIf QRY8->E1_VENCREA == cData7S
			nTotD7 += QRY8->VAL_VCATU
			nPosCli := aScan(aDatasCli, { |x| Upper(AllTrim(x[2])) == QRY8->A1_NOME})
		 	If nPosCli == 0
		 	 	Aadd(aDatasCli,{QRY8->A1_RESFAT,QRY8->A1_NOME,0,0,0,0,0,0,QRY8->VAL_VCATU})
		 	Else
			 	aDatasCli[nPosCli][3] := aDatasCli[nPosCli][9]+QRY8->VAL_VCATU			 	
		 	EndIf		
/*/
		EndIf										
									
  		QRY8->(DbSkip())
				
	EndDo 

	oSection8:Cell("A1_RESFAT"):SetValue(" ")
	oSection8:Cell("A1_NOME"):SetValue("Total a Vencer - Semana")
	oSection8:Cell("VALD1"):SetValue(nTotD1)			 
	oSection8:Cell("VALD2"):SetValue(nTotD2)	
	oSection8:Cell("VALD3"):SetValue(nTotD3)			 
	oSection8:Cell("VALD4"):SetValue(nTotD4)			 
	oSection8:Cell("VALD5"):SetValue(nTotD5)	
	oSection8:PrintLine()

	For nI := 1 To Len(aDatasCli)
			
		oReport:IncMeter() 			

		oSection8:Cell("A1_RESFAT"):SetValue(aDatasCli[nI][1])
		oSection8:Cell("A1_NOME"):SetValue(aDatasCli[nI][2])
		oSection8:Cell("VALD1"):SetValue(aDatasCli[nI][3])			 
		oSection8:Cell("VALD2"):SetValue(aDatasCli[nI][4])	
		oSection8:Cell("VALD3"):SetValue(aDatasCli[nI][5])			 
		oSection8:Cell("VALD4"):SetValue(aDatasCli[nI][6])			 
		oSection8:Cell("VALD5"):SetValue(aDatasCli[nI][7])	
		oSection8:PrintLine()
				
	Next
	 
	oSection8:Finish()
	oReport:SkipLine(5)


//**************************************************************************
//
//	     Impressão das informações de vencidos Judicial
//
//**************************************************************************

   	DbSelectArea("QRY9")   
	QRY9->(DbGoTop())                  
	
	oReport:PrintText(oSection9:cTitle)		  	
	oSection9:Init()

    nTotAtu 	:= 0
    nTotPass 	:= 0
	While !oReport:Cancel() .AND. !QRY9->(Eof())
			
		nTotAtu		+= QRY9->VAL_VCATU     //Total Geral
		nTotPass	+= QRY9->VAL_VCANT
									
  		QRY7->(DbSkip())
				
	EndDo 

	oSection9:Cell("A1_RESFAT"):SetValue(" ")
	oSection9:Cell("A1_NOME"):SetValue("  ")
	oSection9:Cell("VAL_VCANT"):SetValue(nTotPass)			 
	oSection9:Cell("VAL_VCATU"):SetValue(nTotAtu)	
	oSection9:Cell("DIFERE"):SetValue(nTotAtu-nTotPass)			 
	oSection9:PrintLine()

	QRY9->(DbGoTop()) 

	While !oReport:Cancel() .AND. !QRY9->(Eof())
			
		oReport:IncMeter() 			
		If QRY9->VAL_VCATU > 0 .OR. QRY9->VAL_VCANT > 0
			oSection9:Cell("A1_RESFAT"):SetValue(QRY9->A1_RESFAT)
			oSection9:Cell("A1_NOME"):SetValue(QRY9->A1_NOME)
			oSection9:Cell("VAL_VCANT"):SetValue(QRY9->VAL_VCATU)			 
			oSection9:Cell("VAL_VCATU"):SetValue(QRY9->VAL_VCATU)	
			oSection9:Cell("DIFERE"):SetValue(QRY9->VAL_VCATU-QRY9->VAL_VCATU)			 
			oSection9:PrintLine()
		EndIf							
  		QRY9->(DbSkip())
				
	EndDo 
	oSection9:Finish()
	oReport:SkipLine(5)


						
Return        

        
//-------------------------------------------------------------------
/*/{Protheus.doc} fMontaQry
Montagem das Querys  

@param	
		
@author	Felipe Toazza Caldeira
@since	12/11/2015
@return	NIL
/*/
//-------------------------------------------------------------------
Static Function fMontaQry(  )  
Local cQuery := ""
                                                             
    //**************************************************************************************//
    //																						//
    //					QUERY PARA MONTAGEM RESUMO A VENCER									//
    //																						//      
    //**************************************************************************************//

    cQuery := " SELECT TIPO, A1_TIPOCR,  SUM(VAL_AV_VZ) AS VALVENCVZ, SUM(VAL_VC_VZ) AS VALPGVZ,SUM(VAL_AV_SV) AS VALVENCSV, SUM(VAL_VC_SV) AS VALPGVSV FROM ( "
    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		'' AS PAGTO , SUM(E1_SALDO) AS VAL_AV_VZ,  SUM(0)  AS VAL_VC_VZ, SUM(0) AS VAL_AV_SV, SUM(0) AS VAL_VC_SV  "
		cQuery += " FROM "
		cQuery += " 	SE1020 "//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'   AND A1_TIPOCR = 'ARMADOR' "
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_PREFIXO IN ('ARM','AVZ')  "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "

    	cQuery += " UNION 

    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		' ' AS PAGTO , SUM(E1_VALOR) AS VAL_AV,  SUM(0)  AS VAL_VC, SUM(0) AS VAL_AV_SV, SUM(0) AS VAL_VC_SV "
    	cQuery += " FROM
    	cQuery += " 	SE1030"//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'   AND A1_TIPOCR = 'ARMADOR'  "
		cQuery += " WHERE "
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_PREFIXO IN ('ARM','AVZ') "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+Alltrim(MV_PAR08)+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+Alltrim(MV_PAR09)+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "

    	cQuery += " UNION 

    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		' ' AS PAGTO ,SUM(0), SUM(0), SUM(E1_VALOR) AS VAL_AV_SV,  SUM(0)  AS VAL_VC_SV "
		cQuery += " FROM "
		cQuery += " 	SE1020 "//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR != 'ARMADOR'  "
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*'"	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "

    	cQuery += " UNION 

    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		' ' AS PAGTO ,SUM(0), SUM(0), SUM(E1_VALOR) AS VAL_AV_SV,  SUM(0)  AS VAL_VC_SV "
    	cQuery += " FROM
    	cQuery += " 	SE1030"//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR != 'ARMADOR'  "
		cQuery += " WHERE "
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*'"	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+Alltrim(MV_PAR08)+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+Alltrim(MV_PAR09)+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "


    	cQuery += " UNION 

    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		' ' AS PAGTO ,SUM(0), SUM(0), SUM(E1_VALOR) AS VAL_AV_SV,  SUM(0)  AS VAL_VC_SV "
		cQuery += " FROM "
		cQuery += " 	SE1020 "//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR = 'ARMADOR'  "
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*'  AND E1_PREFIXO NOT IN ('ARM','AVZ') "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "

    	cQuery += " UNION 

    	cQuery += " SELECT 'AR' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, 
    	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_TIPOCR, SUBSTRING(E1_VENCREA,1,6) AS VENCTO, "
		cQuery += " 		' ' AS PAGTO ,SUM(0), SUM(0), SUM(E1_VALOR) AS VAL_AV_SV,  SUM(0)  AS VAL_VC_SV "
    	cQuery += " FROM
    	cQuery += " 	SE1030"//tabela fixada por pegar informações de duas tabelas diferentes
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR = 'ARMADOR'  "
		cQuery += " WHERE "
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*'  AND E1_PREFIXO NOT IN ('ARM','AVZ')  "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+Alltrim(MV_PAR08)+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+Alltrim(MV_PAR09)+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA,  A1_TIPOCR, E1_VENCREA "


	cQuery += "	)  T "
	cQuery += "	GROUP BY TIPO, A1_TIPOCR ORDER BY A1_TIPOCR, VALVENCSV DESC"
	
	 
	oReport:IncMeter(1)
	cQuery := ChangeQuery(cQuery)       
	
	Memowrit("C:\Temp\SQL_1.TXT",cQuery) 
	  	   
	If ( Select("QRY1") ) > 0
		DbSelectArea("QRY1")
		QRY1->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY1"      
	              
	oReport:IncMeter(1)	                              
 
    //**************************************************************************************//
    //																						//
    //					QUERY PARA MONTAGEM RESUMO VENCIDOS								//
    //																						//      
    //**************************************************************************************//               
 
	cQuery := " SELECT TIPO, A1_TIPOCR,  E1_CLIENTE,E1_LOJA, A1_NOME,  SUM(VAL_VC_VZ) AS VALVCVZ, SUM(VAL_VC_SV) AS VALVCSV FROM ( "
		cQuery += " SELECT 'VC' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, "
		cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,A1_TIPOCR, SUM(E1_SALDO) AS VAL_VC_VZ,  SUM(0)  AS VAL_VC_SV "
		cQuery += " FROM "
		cQuery += " 	SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'   AND A1_TIPOCR = 'ARMADOR' "
		cQuery += " WHERE "  
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_PREFIXO IN ('ARM','AVZ')"	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,  A1_TIPOCR "

		cQuery += "	UNION 

		cQuery += "	SELECT 'VC' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, " 
		cQuery += "			E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME, A1_TIPOCR, SUM(E1_SALDO) AS VAL_VC_VZ,  SUM(0)  AS VAL_VC_SV "
		cQuery += "	FROM "
		cQuery += "		SE1030 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR = 'ARMADOR'  "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_PREFIXO IN ('ARM','AVZ')"	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,  A1_TIPOCR "

		cQuery += "	UNION 

		cQuery += " SELECT 'VC' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, "
		cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,A1_TIPOCR, SUM(0) AS VAL_VC_VZ,  SUM(E1_SALDO)  AS VAL_VC_SV "
		cQuery += " FROM "
		cQuery += " 	SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'   AND A1_TIPOCR != 'ARMADOR' "
		cQuery += " WHERE "  
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,  A1_TIPOCR "

		cQuery += "	UNION 

		cQuery += "	SELECT 'VC' AS TIPO, CASE WHEN E1_PREFIXO IN ('ARM','AVZ') AND A1_TIPOCR = 'ARMADOR' THEN 'VAZIO' ELSE 'SERVICO' END CLASSIF, E1_FILIAL, " 
		cQuery += "			E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME, A1_TIPOCR, SUM(0) AS VAL_VC_VZ,  SUM(E1_SALDO)  AS VAL_VC_SV "
		cQuery += "	FROM "
		cQuery += "		SE1030 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*'  AND A1_TIPOCR != 'ARMADOR'  "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 "	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, A1_NOME,  A1_TIPOCR "


	cQuery += "	)  T "
	cQuery += "	GROUP BY TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_TIPOCR "                                            
	cQuery += "	ORDER BY A1_TIPOCR, VALVCSV DESC "

	cQuery := ChangeQuery(cQuery) 
	Memowrit("C:\Temp\SQL2.TXT",cQuery) 
 

	If ( Select("QRY2") ) > 0
		DbSelectArea("QRY2")
		QRY2->(DbCloseArea())
	EndIf        
	
	TCQUERY cQuery NEW ALIAS "QRY2"      


    //**************************************************************************************/
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL VENCIDO ARMADOR					//
    //																						//      
    //**************************************************************************************//
	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SITUACA != '6' AND E1_VALOR-E5_VALOR > 0 " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SITUACA != '6' AND E1_VALOR-E5_VALOR > 0 " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT "
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL3.TXT",CqUERY)  	   
	If ( Select("QRY3") ) > 0
		DbSelectArea("QRY3")
		QRY3->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY3"      
	              
    //**************************************************************************************/
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL A VENCER ARMADOR				//
    //																						//      
    //**************************************************************************************//
    dDomingo := MV_PAR07
    While Dow(dDomingo) != 1
    	dDomingo := dDomingo + 1
    EndDo
    
	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(VAL_VCATU) AS VAL_VCATU FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'ARMADOR'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA"
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL4.TXT",CqUERY)  	   
	If ( Select("QRY4") ) > 0
		DbSelectArea("QRY4")
		QRY4->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY4"      


    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL VENCIDO TCPLOG					//
    //																						//      
    //**************************************************************************************//
	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'   " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "


		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E5_VALOR)*(-1)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'   " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E5_VALOR)*(-1)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "



	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT "
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL5.TXT",CqUERY)  	   
	If ( Select("QRY5") ) > 0
		DbSelectArea("QRY5")
		QRY5->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY5"      
	              	     

    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL A VENCER TCPLOG					//
    //																						//      
    //**************************************************************************************//

	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG'"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND A1_TIPOCR = 'TCPLOG' "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA "

	cQuery += " )  T "           
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA"
	cQuery += " HAVING SUM(VAL_VCATU) > 0 OR SUM(VAL_VCANT) > 0
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)   
	
	MEMOWRITE("C:\Temp\SQL6.TXT",CqUERY)  	   
	If ( Select("QRY6") ) > 0
		DbSelectArea("QRY6")
		QRY6->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY6"      
	     
    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL VENCIDO TERMINAL/TOP50			//
    //																						//      
    //**************************************************************************************//
	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND (A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50')"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND (A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50')"
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND (A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50')"	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'   " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND (A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50')"	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SITUACA != '6'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT "
	cQuery += " HAVING SUM(VAL_VCATU) > 0 OR SUM(VAL_VCANT) > 0
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL7.TXT",CqUERY)  	   
	If ( Select("QRY7") ) > 0
		DbSelectArea("QRY7")
		QRY7->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY7"      
	              

    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL A VENCER TERMINAL/TOP50			//
    //																						//      
    //**************************************************************************************//

	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND ( A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50' )"	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA > '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' AND ( A1_TIPOCR = 'TERMINAL' OR A1_TIPOCR = 'TOP50' ) "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(dDomingo)+"' AND E1_VENCREA <= '"+DtoS(dDomingo+5)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA != '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT,E1_VENCREA "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, E1_VENCREA"
	cQuery += " HAVING SUM(VAL_VCATU) > 0 OR SUM(VAL_VCANT) > 0	
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)   
	
	MEMOWRITE("C:\Temp\SQL8.TXT",CqUERY)  	   
	If ( Select("QRY8") ) > 0
		DbSelectArea("QRY8")
		QRY8->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY8"      


    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO SEMANA ATUAL VENCIDO JURIDICO				//
    //																						//      
    //**************************************************************************************//


  	cQuery := " SELECT TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT, SUM(VAL_VCATU) AS VAL_VCATU, SUM(VAL_VCANT)AS VAL_VCANT FROM ( "
		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA = '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(E1_SALDO) AS VAL_VCATU,  SUM(0)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND SE1030.D_E_L_E_T_ != '*' AND E1_SALDO > 0 AND E1_SITUACA = '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1020.D_E_L_E_T_ != '*' AND E1_SITUACA = '6'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT  "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT, SUM(0) AS VAL_VCATU,  SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC IN ('BA','VL','CP') AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07-7)+"' AND SE1030.D_E_L_E_T_ != '*'  AND E1_SITUACA = '6' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += " E1_CLIENTE, E1_LOJA, A1_NOME, A1_RESFAT "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO,  E1_CLIENTE,E1_LOJA, A1_NOME, A1_RESFAT "
	cQuery += " HAVING SUM(VAL_VCATU) > 0 OR SUM(VAL_VCANT) > 0	
	cQuery += " ORDER BY VAL_VCATU DESC "		 
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL9.TXT",CqUERY)  	   
	If ( Select("QRY9") ) > 0
		DbSelectArea("QRY9")
		QRY9->(DbCloseArea())
	EndIf        

	TCQUERY cQuery NEW ALIAS "QRY9"      
	              
    //**************************************************************************************//
    //																						//
    //				QUERY PARA MONTAGEM RESUMO MES/ANO										//
    //																						//      
    //**************************************************************************************//
	dAuxData := MonthSub(StoD(SubStr(DtoS(MV_PAR07),1,6)+'01'),14)
	cQuery := " SELECT * FROM Z10020 WHERE "
	cQuery += " ((Z10_MES >= '"+Substr(DtoS(dAuxData),5,2)+"' AND Z10_ANO = '"+Substr(DtoS(dAuxData),1,4)+"') OR (Z10_ANO > '"+Substr(DtoS(dAuxData),1,4)+"')) AND D_E_L_E_T_  !=  '*' "
	cQuery += " ORDER BY Z10_TIPO, Z10_TPCLI "	
// 	cQuery += " UNION "	 
//	cQuery := " SELECT * FROM Z10030 WHERE "
//	cQuery += " ((Z10_MES >= '"+Substr(DtoS(dAuxData),5,2)+"' AND Z10_ANO = '"+Substr(DtoS(dAuxData),1,4)+"') OR (Z10_ANO > '"+Substr(DtoS(dAuxData),1,4)+"')) AND D_E_L_E_T_  !=  '*' "


/*
	cQuery := " SELECT TIPO,  A1_TIPOCR,  MESANO, EMISSAO,  SUM(VAL_VCANT)AS VAL_VCANT FROM ( "

		cQuery += " SELECT 'ATU' AS TIPO, A1_TIPOCR, SUBSTRING(E1_EMISSAO,1,6) AS EMISSAO, SUBSTRING(E1_VENCREA,1,6) AS MESANO,  SUM(0) as VALAV, SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC = 'BA' AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND E1_EMISSAO >= '"+DtoS(dAuxData)+"'  AND   SE1020.D_E_L_E_T_ != '*'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "  A1_TIPOCR, E1_EMISSAO, E1_VENCREA "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, A1_TIPOCR, SUBSTRING(E1_EMISSAO,1,6) AS EMISSAO, SUBSTRING(E1_VENCREA,1,6) AS MESANO, SUM(0) as VALAV, SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC = 'BA' AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND E1_EMISSAO >= '"+DtoS(dAuxData)+"' AND  SE1030.D_E_L_E_T_ != '*' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "  A1_TIPOCR, E1_EMISSAO, E1_VENCREA "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, A1_TIPOCR, SUBSTRING(E1_EMISSAO,1,6) AS EMISSAO, SUBSTRING(E1_VENCREA,1,6) AS MESANO,  SUM(0) as VALAV, SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM "
		cQuery += " SE1020 "
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5020 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5020.D_E_L_E_T_ != '*'  and E5_TIPODOC = 'BA' AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "		
		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND E1_EMISSAO >= '"+DtoS(dAuxData)+"' AND SE1020.D_E_L_E_T_ != '*'  " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf                                                                                                               
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "  A1_TIPOCR, E1_EMISSAO, E1_VENCREA "

		cQuery += " 	UNION 

		cQuery += " SELECT 'ATU' AS TIPO, A1_TIPOCR,  SUBSTRING(E1_EMISSAO,1,6) AS EMISSAO,SUBSTRING(E1_EMISSAO,1,6) AS EMISSAO, SUBSTRING(E1_VENCREA,1,6) AS MESANO, SUM(0) as VALAV, SUM(E1_VALOR-E5_VALOR)  AS VAL_VCANT "
		cQuery += " FROM
		cQuery += " 	SE1030
		cQuery += " INNER JOIN SA1020 ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA "
		cQuery += " 	     AND SA1020.D_E_L_E_T_ != '*' "	
		cQuery += " LEFT OUTER JOIN SE5030 ON E1_FILIAL = E5_FILIAL AND E1_PREFIXO = E5_PREFIXO AND E1_NUM = E5_NUMERO "
		cQuery += " 	     AND E1_PARCELA = E5_PARCELA AND SE5030.D_E_L_E_T_ != '*'  and E5_TIPODOC = 'BA' AND E5_DTDISPO < '"+DtoS(MV_PAR07-7)+"' "

		cQuery += " WHERE 
		cQuery += " 	E1_FILIAL >= '  '  AND E1_FILIAL <= 'ZZ' AND E1_PREFIXO >= '"+MV_PAR05+"' AND E1_PREFIXO <= '"+MV_PAR06+"'  "  //Incluso filial para acelerar busca devido a indices em banco
		cQuery += " AND	E1_CLIENTE >= '"+MV_PAR01+"'  AND E1_CLIENTE <= '"+MV_PAR02+"' AND E1_LOJA >= '"+MV_PAR03+"' AND E1_LOJA <= '"+MV_PAR04+"'  "  
		cQuery += " AND E1_VENCREA <= '"+DtoS(MV_PAR07)+"' AND E1_EMISSAO >= '"+DtoS(dAuxData)+"' AND  SE1030.D_E_L_E_T_ != '*' " 	            
		If !Empty(Alltrim(MV_PAR08))
			cQuery += " AND	E1_TIPO IN ('"+STRTRAN(Alltrim(MV_PAR08),',',"','")+"') "    
	    EndIf
	    If !Empty(Alltrim(MV_PAR09))
			cQuery += " AND	E1_TIPO NOT IN ('"+STRTRAN(Alltrim(MV_PAR09),',',"','")+"') "    
	    EndIf
		cQuery += " GROUP BY  "
		cQuery += "  A1_TIPOCR, E1_EMISSAO, E1_VENCREA "

	cQuery += " )  T "
	cQuery += " GROUP BY TIPO, A1_TIPOCR, EMISSAO, MESANO  "
	cQuery += " ORDER BY VAL_VCANT DESC "		 
*/  
	
	cQuery := ChangeQuery(cQuery)  
	MEMOWRITE("C:\Temp\SQL10.TXT",CqUERY)  	   
	If ( Select("QRY10") ) > 0
		DbSelectArea("QRY10")
		QRY10->(DbCloseArea())
	EndIf        
                                                             	
	TCQUERY cQuery NEW ALIAS "QRY10"      
	              
				
Return      
              

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria os parametros de perguntas      

@author Felipe Toazza CAldeira
@since 12/11/2015
@version P11
/*/
//-------------------------------------------------------------------     

Static function AjustaSX1(cPerg)

//PutSx1(cPerg,"01","Cliente De","Cliente De","Cliente De"			,"MV_CH1"	,"C",6,0,1,"G","","SA1","",""	,"MV_PAR01","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"02","Cliente Ate","Cliente Ate","Cliente A"			,"MV_CH2"	,"C",6,0,1,"G","","SA1","",""	,"MV_PAR02","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"03","Loja De","Loja De","Loja De"						,"MV_CH3"	,"C",2,0,1,"G","","","",""		,"MV_PAR03","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"04","Loja Ate","Loja Ate","Loja A"					,"MV_CH4"	,"C",2,0,1,"G","","","",""		,"MV_PAR04","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"05","Prefixo De","Prefixo De","Prefixo De"			,"MV_CH5"	,"C",3,0,1,"G","","","",""		,"MV_PAR05","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"06","Prefixo Ate","Prefixo Ate","Prefixo Até"			,"MV_CH6"	,"C",3,0,1,"G","","","",""		,"MV_PAR06","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"07","Data Base","Data Base","Data Base"				,"MV_CH7"	,"D",8,0,1,"G","","","",""		,"MV_PAR07","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"08","Imprimir Tipos","Imprimir Tipos","Imprimir Tipos","MV_CH8"	,"C",40,0,1,"G","","","",""		,"MV_PAR08","","","","","","","","","","","","","","","","","",{})
//PutSx1(cPerg,"09","Não Imprimir Tipos","Não Imprimir Tipos","Não Imprimir Tipos","MV_CH9"	,"C",40,0,1,"G","","","",""		,"MV_PAR09","","","","","","","","","","","","","","","","","",{})                             

Return