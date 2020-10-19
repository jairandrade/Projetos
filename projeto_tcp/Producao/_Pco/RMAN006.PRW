/**********************************************************************************************************************************/
/** user function rman                                                                                                          **/
/** Relatorio de OS e observações.                						                                                         **/
/** Analista: Paulo Geovane Estraich        						                                                             **/ 
/** Data desenvolvimento: 26/11/2017     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function RMAN006

private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "RMAN006"


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
oReport := TReport():New("RELMANUT", "Relatorio campo Memo", cPerg, {|oReport| GerRelExe()}, "Relatorio")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Aniversariantes", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"ORDEM"         , nil, "Ordem Serviço "       ,"@!", 6)
TRCell():New(oSection,"DTINICIO"    , nil, "Data Inicio. "       ,"@!",  8)
TRCell():New(oSection,"CODBEM" , nil, "Bem"  ,"@!", 10) 
//TRCell():New(oSection,"CODFUN"       , nil, "Cod. Func."  ,"@!",  6)
TRCell():New(oSection,"SERVICO"       , nil, "Serviço"      ,"@!", 10) 
TRCell():New(oSection,"OBSERVACAO"        , nil, "MEMO"       ,"@!" ,300) 
TRCell():New(oSection,"NOME"        , nil, "Nome"       ,"@!" ,30) 


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
 		oSection:Cell("ORDEM")          :SetValue(RA2QRY->TL_ORDEM)     
     	oSection:Cell("DTINICIO")       :SetValue(RA2QRY->TL_DTINICI) 
     	oSection:Cell("CODBEM") 	    :SetValue(RA2QRY->TJ_CODBEM) 
   		oSection:Cell("SERVICO")        :SetValue(RA2QRY->TJ_SERVICO)
    	oSection:Cell("OBSERVACAO")     :SetValue(RA2QRY->TL_OBSERVA) 
    	oSection:Cell("NOME")           :SetValue(RA2QRY->T1_NOME)
	
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

	cQry  := " SELECT TL_ORDEM,TL_DTINICI,TJ_CODBEM,TJ_SERVICO,CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), TL_OBSERVA)) TL_OBSERVA,T1_NOME "  
    cQry  += " from "+RetSqlName("STL")+" STL "                                                                                                 
	cQry  += " INNER JOIN "+RetSqlName("ST1")+" ST1 ON  T1_CODFUNC = TL_CODIGO AND ST1.D_E_L_E_T_ = ' ' "
    cQry  += " INNER JOIN "+RetSqlName("STJ")+" STJ ON TJ_FILIAL = TL_FILIAL AND TJ_ORDEM = TL_ORDEM AND STJ.D_E_L_E_T_ = ' ' "
	cQry  += " WHERE TL_ORDEM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND STL.D_E_L_E_T_ = ' ' "
    cQry  += " AND TL_DTINICI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "    
    cQry  += " ORDER BY TL_ORDEM ASC, TL_SEQTARE ASC "

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


//PutSx1(cPerg,"01","Data de?"      ,"Data de?"     ,"Filial de?"     ,"mv_ch1"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."  ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Data até?"     ,"Data até?"    ,"Filial até?"    ,"mv_ch2"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."     ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Ordem de?"   ,"Ordem de?"  ,"Matricula de?"  ,"mv_ch3"  ,"C" ,6,0,0,"G","","STL","","","mv_par03","","","","","","","","","","","","","","","","",{"Matricula de."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Ordem até?"  ,"Ordem até?" ,"Matricula até?" ,"mv_ch4"  ,"C" ,6,0,0,"G","","STL","","","mv_par04","","","","","","","","","","","","","","","","",{"Matricula até."  ,"","",""},{"","","",""},{"","",""},"")
return

