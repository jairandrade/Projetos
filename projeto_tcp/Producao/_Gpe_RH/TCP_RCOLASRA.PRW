/**********************************************************************************************************************************/
/** user function SRAFUN                                                                                                         **/
/** Relatorio de funcionarios.                  						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 02/06/2016     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function SRAFUNC
                                                                
private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "SRAFUNC"


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
oReport := TReport():New("SRAFUNC", "Relatório Funcionarios", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre funcionarios.")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Funcionarios", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"FILIAL"          , nil, "Filial "            ,"@!", 2)
TRCell():New(oSection,"MATRICULA"       , nil, "Matricula "         ,"@!", 6)
TRCell():New(oSection,"NOME"            , nil, "Nome"               ,"@!",30)
TRCell():New(oSection,"CFUNC"           , nil, "Cod. Func."         ,"@!", 6) 
TRCell():New(oSection,"FUNCAO"          , nil, "Função"             ,"@!",30)
TRCell():New(oSection,"CODCC"           , nil, "Cod. CC."           ,"@!", 6)
TRCell():New(oSection,"CC"              , nil, "Centro de Custo"    ,"@!",30) 

return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()
oSection:Init() 

RA1QRY()
RA1QRY->(DbGoTop())
While (!RA1QRY->(Eof()))
  
 		oSection:Cell("FILIAL")           :SetValue(RA1QRY->RA_FILIAL)     
     	oSection:Cell("MATRICULA")        :SetValue(RA1QRY->RA_MAT) 
     	oSection:Cell("NOME")             :SetValue(RA1QRY->RA_Nome)  
     	oSection:Cell("CFUNC")            :SetValue(RA1QRY->RA_CODFUNC)  
   		oSection:Cell("FUNCAO")           :SetValue(RA1QRY->RJ_DESC) 
   		oSection:Cell("CODCC")            :SetValue(RA1QRY->RA_CC)
   		oSection:Cell("CC")               :SetValue(RA1QRY->CTT_DESC01)
   		
   		
	
	oSection:PrintLine()
	
	RA1QRY->(dbSkip())    
	
EndDo                 
RA1QRY->(dbCloseArea())     
    
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
static Function RA1QRY
  	local aArea := GetArea()

	local cQry  := "" 
    
     cQry  := "select RA_FILIAL, RA_MAT, RA_NOME, RA_CODFUNC, RJ_DESC,RA_CC, CTT_DESC01 "
     cQry  += "  from SRA020 RA "
     cQry  += "Inner Join SRJ020 RJ ON"
     cQry  += "	RJ.RJ_FUNCAO = RA.RA_CODFUNC"
     cQry  += "	and RJ.D_E_L_E_T_ <> '*'"
     cQry  += "  INNER Join CTT020 CTT ON"
     cQry  += "	CTT.CTT_CUSTO = RA.RA_CC"
     cQry  += "	and CTT.D_E_L_E_T_ <> '*'"		
     cQry  += " where RA.D_E_L_E_T_ <> '*'"
     cQry  += " and RA_SITFOLH <> 'D'"
     cQry  += " AND RA_MAT between '"+ALLTRIM(mv_par03)+"' and '"+ALLTRIM(mv_par04)+"'"
     cQry  += " AND RA_FILIAL between '"+ALLTRIM(mv_par01)+"' and '"+ALLTRIM(mv_par02)+"'"
     cQry  += " AND RA_CC between '"+ALLTRIM(mv_par05)+"' and '"+ALLTRIM(mv_par06)+"'"
     
    TcQuery cQry New Alias "RA1QRY"
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


//PutSx1(cPerg,"01","Filial de?"     ,"Filial de?"       ,"Filial de?"          ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."    ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Filial até?"    ,"Filial até?"      ,"Filial até?"         ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."       ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Matricula de?"  ,"Matricula de?"    ,"Matricula de?"       ,"mv_ch3"  ,"C" ,9,0,0,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","",{"Matricula de."     ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Matricula até?" ,"Matricula até?"   ,"Matricula até?"      ,"mv_ch4"  ,"C" ,9,0,0,"G","","SRA","","","mv_par04","","","","","","","","","","","","","","","","",{"Matricula até."    ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","cc de?"         ,"cc de?"           ,"cc de?"              ,"mv_ch5"  ,"C" ,6,0,0,"G","","CTT","","","mv_par05","","","","","","","","","","","","","","","","",{"CC de."            ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","cc até?"        ,"cc até?"          ,"cc até?"             ,"mv_ch6"  ,"C" ,6,0,0,"G","","CTT","","","mv_par06","","","","","","","","","","","","","","","","",{"CC até."           ,"","",""},{"","","",""},{"","",""},"")

return
