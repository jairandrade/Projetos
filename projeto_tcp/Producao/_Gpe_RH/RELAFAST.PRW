/**********************************************************************************************************************************/
/** user function RAFASTAMENTO                                                                                                   **/
/** Relatorio de afastamento.                						                                                             **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 27/10/2015      						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function afasta

private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "AFAST"


// processa perguntas
criaSX1(cPerg)

Pergunte(cPerg, .F.)
// cria o relatorio                                                                                                              
oReport := GerRelDef(cPerg)

// exibe relatorio
oReport:PrintDialog()

return 

/**********************************************************************************************************************************/
/** static function GerRelDef()                                                                                                  **/
/** definição dos objetos do relatório                                                                                           **/
/**********************************************************************************************************************************/
static function GerRelDef(cPerg)

// define o relatório
oReport := TReport():New("RAFAST", "Relatório de afastamento", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre o afastamento de colaboradores.")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Afastamento", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"FILIAL"              , nil, "Filial "        ,"@!", 3)
TRCell():New(oSection,"MATRICULA"           , nil, "Matricula "     ,"@!", 6)
TRCell():New(oSection,"NOME"                , nil, "Nome"           ,"@!",30)
TRCell():New(oSection,"C. CUSTO"            , nil, "C. Custo"       ,"@!", 9) 
TRCell():New(oSection,"DATA AFASTAMENTO"    , nil, "Afastamento"    ,"@!", 8)
TRCell():New(oSection,"DATA RETORNO"        , nil, "Retorno"        ,"@!",10) 
TRCell():New(oSection,"FUNCAO"              , nil, "Funcao"         ,"@!",15) 
TRCell():New(oSection,"CARGO"               , nil, "Cargo"          ,"@!",15)
TRCell():New(oSection,"SETOR"               , nil, "Setor"          ,"@!",15)
TRCell():New(oSection,"MOTIVO"              , nil, "Motivo"         ,"@!",15)  


return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()
oSection:Init() 
	
SR8QRY()
SR8QRY->(DbGoTop())
While (!SR8QRY->(Eof()))
 
	oSection:Cell("FILIAL")              :SetValue(SR8QRY->Filial) 
	oSection:Cell("MATRICULA")           :SetValue(SR8QRY->MAT)
	oSection:Cell("NOME")                :SetValue(SR8QRY->NOME)  
	oSection:Cell("C. CUSTO")            :SetValue(SR8QRY->CC) 
	oSection:Cell("DATA AFASTAMENTO")    :SetValue(SUBSTR(SR8QRY->INI,7,2)+'/'+SUBSTR(SR8QRY->INI,5,2)+'/'+SUBSTR(SR8QRY->INI,1,4))//:SetValue(SR8QRY->INI) 
	oSection:Cell("DATA RETORNO")        :SetValue(SUBSTR(SR8QRY->FIM,7,2)+'/'+SUBSTR(SR8QRY->FIM,5,2)+'/'+SUBSTR(SR8QRY->FIM,1,4))//:SetValue(SR8QRY->FIM)
	oSection:Cell("FUNCAO")              :SetValue(SR8QRY->FUNCAO)
	oSection:Cell("CARGO")               :SetValue(SR8QRY->CARGO)
	oSection:Cell("SETOR")               :SetValue(SR8QRY->SETOR)
	oSection:Cell("MOTIVO")              :SetValue(SR8QRY->MOTIVO)
	
	oSection:PrintLine()
	
	SR8QRY->(dbSkip())    
	
EndDo                 
SR8QRY->(dbCloseArea())     

oSection:Finish()
Return


/**********************************************************************************************************************************/
/** static function SR8QRY                                                                                                       **/
/** restaura as informações de afastamento                                                                                       **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/ 
static Function SR8QRY
	local aArea := GetArea()

	local cQry  := "" 
	
	If(Empty(AllTrim(mv_par01))) 
		mv_par01 := ''
	EndIf
	If(Empty(AllTrim(mv_par02))) 
		mv_par02 := 'ZZ'
	EndIf
	If(Empty(AllTrim(mv_par05)))
		mv_par05 := ''
	EndIf
	If(Empty(AllTrim(mv_par06)))
		 mv_par06 := 'ZZZZZZ'
	EndIf	 
	 cQry  := "select R8_FILIAL [FILIAL], R8_MAT [MAT], RA_NOMECMP [NOME], RA_CC [CC], R8_DATAINI [INI], R8_DATAFIM [FIM], RJ_DESC [FUNCAO], Q3_DESCSUM [CARGO], QB_DESCRIC [SETOR], X5_DESCRI [MOTIVO]  from "+ RetSqlName("SR8") +" as R8 "
	 cQry  += "   Inner join "+ RetSqlName("SRA") +" RA ON"
	 cQry  += "      RA.RA_MAT = R8_MAT"
	 cQry  += "      and RA.RA_FILIAL = R8_FILIAL"
	 cQry  += "      AND RA.D_E_L_E_T_ <> '*'" 
	 cQry  += "      AND RA.RA_FILIAL = R8.R8_FILIAL"  
	 cQry  += "   Left JOIN "+ RetSqlName("SQB") +" QB on
	 cQry  += "      QB.QB_DEPTO = RA.RA_DEPTO
     cQry  += "      and QB.QB_CC = RA.RA_CC
     cQry  += "      and QB.D_E_L_E_T_ <> '*' 
     cQry  += "   Left JOIN "+ RetSqlName("SQ3") +" Q3 on
     cQry  += "	     Q3.Q3_CARGO = RA.RA_CARGO
     cQry  += "      and Q3.D_E_L_E_T_ <> '*' 
     cQry  += "   Left JOIN "+ RetSqlName("SRJ") +" RJ on
     cQry  += "      RJ.RJ_FUNCAO = RA.RA_CODFUNC
     cQry  += "      and RJ.D_E_L_E_T_ <> '*' 
     cQry  += "   Left JOIN "+ RetSqlName("SX5") +" X5 on
     cQry  += "      X5.X5_TABELA = '30'
     cQry  += "      and X5.X5_CHAVE = R8.R8_TIPO
     cQry  += "      and X5.D_E_L_E_T_ <> '*'
     cQry  += " where "
	 cQry  += "   R8.R8_DATAINI between  '"+dtos(MV_PAR03)+"' and '"+dtos(MV_PAR04)+"'"
	 cQry  += " and R8.R8_FILIAL between '"+mv_par01+"' and '"+mv_par02+"'" 
	 cQry  += " and R8.R8_MAT between '"+mv_par05+"' and '"+mv_par06+"'"
	 cQry  += " and R8.D_E_L_E_T_ <> '*'"
	 
	   TcQuery cQry New Alias "SR8QRY"
	// restaura area
	RestArea(aArea)
return

/**********************************************************************************************************************************/
/** static function criaSX1                                                                                                      **/
/** cria perguntas.											                                                                     **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
static function criaSX1(cPerg)


//PutSx1(cPerg,"01","Filial de?"          ,"Filial de?"          ,"Filial de?"          ,"mv_ch1" ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio.","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Filial até?"         ,"Filial até?"         ,"Filial até?"         ,"mv_ch2" ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Afastados de?"       ,"Afastados de?"       ,"Afastados de?"       ,"mv_ch3" ,"D" ,8,0,0,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","",{"Afastados de." ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Afastados até?"      ,"Afastados até?"      ,"Afastados até?"      ,"mv_ch4" ,"D" ,8,0,0,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{"Afastados até.","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Matricula de?"       ,"Matricula de?"       ,"Matricula de?"       ,"mv_ch5" ,"C" ,9,0,0,"G","","SRA","","","mv_par05","","","","","","","","","","","","","","","","",{"Matricula de." ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Matricula até?"      ,"Matricula até?"      ,"Matricula até?"      ,"mv_ch6" ,"C" ,9,2,0,"G","","SRA","","","mv_par06","","","","","","","","","","","","","","","","",{"Matricula até.","","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"07","Retorno de?"         ,"Retorno de?"         ,"Retorno de?"         ,"mv_ch7" ,"D" ,8,0,0,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{"Retorno de."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"08","Retorno até?"        ,"Retorno até?"        ,"Retorno até?"        ,"mv_ch8" ,"D" ,8,0,0,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{"Retorno até."  ,"","",""},{"","","",""},{"","",""},"")

return
