/**********************************************************************************************************************************/
/** user function NIVER                                                                                                          **/
/** Relatorio de Aniversariantes.                						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 26/01/2017     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function NIVER

private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "NIVER"


// processa perguntas
criaSX1(cPerg)

Pergunte(cPerg, .F.)
// cria o relatorio                                                                                                              
oReport := GerRelDef(cPerg)

// exibe tela de parametros
oReport:PrintDialog()

return 

/**********************************************************************************************************************************/
/** static function GerRelDef()                                                                                                  **/
/** definição dos objetos do relatório                                                                                           **/
/**********************************************************************************************************************************/
static function GerRelDef(cPerg)

// define o relatório
oReport := TReport():New("NIVER", "Relatório Aniversariantes", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre os aniversariantes do mes.")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Aniversariantes", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"NOME"         , nil, "Nome "       ,"@!", 30)
TRCell():New(oSection,"MATRICULA"    , nil, "Mat. "       ,"@!",  6)
TRCell():New(oSection,"DTNASCIMENTO" , nil, "Nascimento"  ,"@!", 10) 
//TRCell():New(oSection,"CODFUN"       , nil, "Cod. Func."  ,"@!",  6)
TRCell():New(oSection,"FUNCAO"       , nil, "Função"      ,"@!", 30) 
TRCell():New(oSection,"CODCC"        , nil, "Setor"       ,"@!" ,30) 


return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()
oSection:Init() 

RA2QRY()
RA2QRY->(DbGoTop())
While (!RA2QRY->(Eof()))

  
 		oSection:Cell("NOME")           :SetValue(RA2QRY->NOME)     
     	oSection:Cell("MATRICULA")      :SetValue(RA2QRY->MATRICULA) 
     	oSection:Cell("DTNASCIMENTO")   :SetValue(RA2QRY->NASCIMENTO) 
   		oSection:Cell("FUNCAO")         :SetValue(RA2QRY->FUNCAO)
    	oSection:Cell("CODCC")          :SetValue(RA2QRY->SETOR) 
    	
	
	oSection:PrintLine()
	
	RA2QRY->(dbSkip())    
	
EndDo                 
RA2QRY->(dbCloseArea())     
    
oSection:Finish()
Return


/**********************************************************************************************************************************/
/** static function RA2QRY                                                                                                       **/
/** restaura as informações de afastamento                                                                                       **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/ 
static Function RA2QRY
  	local aArea := GetArea()

	local cQry  := "" 

	cQry  := "select RA.RA_NOME NOME, RA.RA_MAT MATRICULA,SUBSTRING (RA_NASC,7,2)+'/'+SUBSTRING (RA_NASC,5,2)+'/'+SUBSTRING (RA_NASC,1,4) NASCIMENTO, RJ.RJ_DESC FUNCAO, CT2.CTT_DESC01 SETOR
    cQry  += " from "+ RetSqlName("SRA") +" RA
	cQry  += " Inner Join "+ RetSqlName("CTT") +" CT2 ON
    cQry  += "		CT2.CTT_CUSTO = RA.RA_CC
	cQry  += "	and CT2.CTT_FILIAL = RA.RA_FILIAL
    cQry  += "  and CT2.D_E_L_E_T_ <> '*'
	cQry  += " Inner Join "+ RetSqlName("SRJ") +" RJ ON
   	cQry  += "		RJ.RJ_FUNCAO = RA.RA_CODFUNC
	cQry  += "	and RJ.D_E_L_E_T_ <> '*'
    cQry  += " where RA.RA_SITFOLH <> 'D'
    cQry  += "   and SUBSTRING (RA_NASC,5,2) between '"+mv_par05+"' and '"+mv_par06+"'"
    cQry  += "   and RA.RA_MAT between '"+mv_par03+"' and '"+mv_par04+"'" 
    cQry  += "   and RA.RA_FILIAL between '"+mv_par01+"' and '"+mv_par02+"'" 
    
    TcQuery cQry New Alias "RA2QRY"
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


//PutSx1(cPerg,"01","Filial de?"      ,"Filial de?"     ,"Filial de?"     ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."  ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Filial até?"     ,"Filial até?"    ,"Filial até?"    ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."     ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Matricula de?"   ,"Matricula de?"  ,"Matricula de?"  ,"mv_ch3"  ,"C" ,6,0,0,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","",{"Matricula de."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Matricula até?"  ,"Matricula até?" ,"Matricula até?" ,"mv_ch4"  ,"C" ,6,0,0,"G","","SRA","","","mv_par04","","","","","","","","","","","","","","","","",{"Matricula até."  ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Mes de?"         ,"Mes de?"        ,"Mes de?"        ,"mv_ch5"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{"Mes de."         ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Mes até?"        ,"Mes até?"       ,"Mes até?"       ,"mv_ch6"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{"Mes até."        ,"","",""},{"","","",""},{"","",""},"")
return

