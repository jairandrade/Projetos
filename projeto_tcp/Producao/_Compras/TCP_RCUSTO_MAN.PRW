/*******************BR***************************************************************************************************************/
/** user function RCUSTMAN                                                                                                       **/
/** Relatorio de custos da manutenção.            						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 22/12/2016     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function RCUSTMAN

private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "RCUSTMAN"


// processa perguntas
//criaSX1(cPerg)

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
oReport := TReport():New("RCAP", "Relatório Custos de OS", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime os custos referentes as OS abertas pela manutenção")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "CUSTOS", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"OP"         , nil, "OP "                  ,"@!",  6)
TRCell():New(oSection,"ITENCONTA"  , nil, "Item Conta "          ,"@!",  3)
TRCell():New(oSection,"PRODUTO"    , nil, "Produto"              ,"@!",  6)
TRCell():New(oSection,"DESCRICAO"  , nil, "Descricao"            ,"@!", 15) 
TRCell():New(oSection,"CCUSTO"     , nil, "c custo"              ,"@!",  6)
TRCell():New(oSection,"CUSTO"      , nil, "custo"                ,"@!",  6)
TRCell():New(oSection,"OS"         , nil, "O Servico"            ,"@!",  6) 
TRCell():New(oSection,"DT_ORIG"    , nil, "Dt Origem"            ,"@!",  8) 
TRCell():New(oSection,"BEM"        , nil, "Bem"                  ,"@!",  6)
TRCell():New(oSection,"SERVICO"    , nil, "Servico"              ,"@!", 10)
TRCell():New(oSection,"TIPO"       , nil, "Tipo"                 ,"@!",  5)
TRCell():New(oSection,"DT_INICIO"  , nil, "Dt. Prev. Parada"     ,"@!",  8)  
TRCell():New(oSection,"DT_FIM"     , nil, "Dt. Prev. Fim Parada" ,"@!",  8)  
//TRCell():New(oSection,"DTPPINI"    , nil, "Dt. Prev. Inicio Man.","@!",  8)
//TRCell():New(oSection,"DTPPFIM"    , nil, "."      ,"@!",  8)
TRCell():New(oSection,"DTMPINI"    , nil, "Dt. Prev. Inicio Man.","@!",  8)
TRCell():New(oSection,"DTMPFIM"    , nil, "Dt. Prev. Fim Man."   ,"@!",  8)
TRCell():New(oSection,"HOPPINI"    , nil, "Hora Prev. Parada"    ,"@!",  5)
TRCell():New(oSection,"HOPPFIM"    , nil, "Hora Prev. Fim Parada","@!",  5)
TRCell():New(oSection,"OBS"        , nil, "OBS"                  ,"@!", 15) 
TRCell():New(oSection,"CENTRAB"    , nil, "CENTRAB"              ,"@!", 17)

return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()
oSection:Init() 

SD3QRY()
SD3QRY->(DbGoTop())
While (!SD3QRY->(Eof()))
                     
 	
 		oSection:Cell("OP")           :SetValue(SD3QRY->OP)     
     	oSection:Cell("ITENCONTA")    :SetValue(SD3QRY->ITEMCTA) 
	    oSection:Cell("CCUSTO")       :SetValue(SD3QRY->CC) 
     	oSection:Cell("PRODUTO")      :SetValue(SD3QRY->PROD) 
   		oSection:Cell("DESCRICAO")    :SetValue(SD3QRY->DESCR) 
    	oSection:Cell("CUSTO")        :SetValue(SD3QRY->CUSTO) 
    	oSection:Cell("OS")           :SetValue(SD3QRY->ORDEM)  
    	oSection:Cell("DT_ORIG")      :SetValue(SUBSTR(SD3QRY->DTORIGI,7,2)+'/'+SUBSTR(SD3QRY->DTORIGI,5,2)+'/'+SUBSTR(SD3QRY->DTORIGI,1,4))
     	oSection:Cell("BEM")          :SetValue(SD3QRY->BEM) 
    	oSection:Cell("SERVICO")      :SetValue(SD3QRY->SERV) 
    	oSection:Cell("TIPO")         :SetValue(SD3QRY->TIPO)
    	oSection:Cell("DT_INICIO")    :SetValue(SUBSTR(SD3QRY->DTPRVPARADA,7,2)+'/'+SUBSTR(SD3QRY->DTPRVPARADA,5,2)+'/'+SUBSTR(SD3QRY->DTPRVPARADA,1,4)) 
    	oSection:Cell("DT_FIM")       :SetValue(SUBSTR(SD3QRY->DTPRVFIMPARADA,7,2)+'/'+SUBSTR(SD3QRY->DTPRVFIMPARADA,5,2)+'/'+SUBSTR(SD3QRY->DTPRVFIMPARADA,1,4)) 
	  	oSection:Cell("DTMPINI")      :SetValue(SUBSTR(SD3QRY->DTPRVINIMAN,7,2)+'/'+SUBSTR(SD3QRY->DTPRVINIMAN,5,2)+'/'+SUBSTR(SD3QRY->DTPRVINIMAN,1,4)) 
     	oSection:Cell("DTMPFIM")      :SetValue(SUBSTR(SD3QRY->DTPRVFIMMAN,7,2)+'/'+SUBSTR(SD3QRY->DTPRVFIMMAN,5,2)+'/'+SUBSTR(SD3QRY->DTPRVFIMMAN,1,4)) 
    	oSection:Cell("HOPPINI")      :SetValue(SD3QRY->HOPRVPAR) 
    	oSection:Cell("HOPPFIM")      :SetValue(SD3QRY->HOPRVFIMPAR)
 //   	oSection:Cell("HOMPINI")      :SetValue(SD3QRY->HOPRVINIMAN) 
 //      	oSection:Cell("HOMPFIM")      :SetValue(SD3QRY->HOPRVFIMMAN) 
    	oSection:Cell("OBS")          :SetValue(SD3QRY->OBS) 
    	oSection:Cell("CENTRAB")      :SetValue(SD3QRY->CENTRAB) 	
	oSection:PrintLine()
	
	SD3QRY->(dbSkip())    
	
EndDo                 
SD3QRY->(dbCloseArea())     
    
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
static Function SD3QRY
  	local aArea := GetArea()

	local cQry  := "" 
      
		cQry  := "select    D3.D3_OP OP,D3.D3_ITEMCTA ITEMCTA,D3.D3_CC CC,D3.D3_COD PROD,B1.B1_DESC DESCR,D3.D3_CUSTO1 CUSTO,TJ.TJ_ORDEM ORDEM,"
		cQry  += "          TJ_DTORIGI DTORIGI, TJ.TJ_CODBEM BEM,TJ_SERVICO SERV, TJ.TJ_TIPO TIPO,TJ.TJ_CUSTMDO CUTMED,"
		cQry  += "          TJ.TJ_DTPPINI DTPRVPARADA, TJ.TJ_DTPPFIM DTPRVFIMPARADA,"
		cQry  += "          TJ.TJ_DTMPINI DTPRVINIMAN, TJ.TJ_DTMPFIM DTPRVFIMMAN,TJ_HOPPINI HOPRVPAR, TJ_HOPPFIM HOPRVFIMPAR,TJ_HOMPINI HOPRVINIMAN, TJ_HOMPFIM HOPRVFIMMAN,"
		cQry  += "          TJ.TJ_XOBSERV OBS, TJ.TJ_CENTRAB CENTRAB"
		cQry  += " from SD3020 D3 "
		cQry  += "  left outer join STJ020 TJ on"
		cQry  += "         TJ.TJ_FILIAL = D3.D3_FILIAL"
		cQry  += "     and TJ.TJ_ORDEM = SUBSTRING(D3.D3_OP,1,6)"
		cQry  += "       and TJ.D_E_L_E_T_ <> '*'"
		cQry  += "  left outer join SB1020 B1 ON"
		cQry  += "         B1.D_E_L_E_T_ <> '*' "
		cQry  += "     and B1.B1_COD = D3.D3_COD "
		cQry  += "where  D3.D3_TM = '501'"
		cQry  += "  and D3.D3_ESTORNO != 'S'"
		cQry  += "  and D3.D_E_L_E_T_ <> '*'"
		cQry  += "  and D3.D3_EMISSAO between '"+AllTrim(SUBSTR(DTOC(mv_par01),7,6)+SUBSTR(DTOC(mv_par01),4,2)+SUBSTR(DTOC(mv_par01),1,2))+"' and '"+AllTrim(SUBSTR(DTOC(mv_par02),7,6)+SUBSTR(DTOC(mv_par02),4,2)+SUBSTR(DTOC(mv_par02),1,2))+"'"
		cQry  += "  and D3.D3_LOCAL = '"+AllTrim(mv_par03)+"'"
		cQry  += "  And ( SUBSTRING(D3.D3_OP,7,5) = 'OS001' OR D3.D3_OP = '  ' )"
		cQry  += "  and D3.D3_ITEMCTA BETWEEN '" +AllTrim(mv_par04)+ "' AND '" +Alltrim(mv_par05)+ "'
		cQry  += "  and D3.D3_CC = '001032'"
		
/*		                                                                            

     cQry  := "Select F1.F1_FILIAL FILIAL,F1.F1_DOC NOTA, F1.F1_FORNECE FORNECEDOR,"
     cQry  += "       F1.F1_LOJA LOJA, A2.A2_NOME RAZAO, A2.A2_CGC CGC,"
	 cQry  += "       F1.F1_EMISSAO EMISSAO, A2.A2_EST ESTADO,  F1.F1_DTDIGIT DIGITACAO,E2.E2_VALOR VLRLIQ,"
     cQry  += "       F1.F1_ESPECIE TIPO, "
	 cQry  += "       E2.E2_VRETINS VLRINSS, E2.E2_ISS VLRISS,"
     cQry  += "       E2.E2_VRETCOF VLRCOFINS, E2.E2_VRETCSL VLRCSLL, E2.E2_VRETIRF VLRIR, E2.E2_VRETPIS VLRPIS,"
     cQry  += "       E2.E2_VENCREA VENCREAL, (E2.E2_VALOR+E2.E2_VRETINS+E2.E2_ISS+E2.E2_VRETCOF+E2.E2_VRETCSL+E2.E2_VRETIRF+E2.E2_VRETPIS) VALOR"
     cQry  += " from "+ RetSqlName("SF1") +" F1, "+ RetSqlName("SE2") +" E2, "+ RetSqlName("SA2") +" A2"
     cQry  += " where F1.F1_DOC between '"+MV_PAR03+"' and '"+MV_PAR04+"'"
     cQry  += "  and F1.F1_FILIAL  between '"+MV_PAR01+"' and '"+MV_PAR02+"'"
     cQry  += "  and F1.F1_DTDIGIT between '"+DtoS(MV_PAR07)+"' and '"+DtoS(MV_PAR08)+"'"  
     cQry  += "  and F1.F1_FORNECE between '"+MV_PAR05+"' and '"+MV_PAR06+"'"
     cQry  += "  and F1.D_E_L_E_T_ <> '*'"
     cQry  += "  and E2.E2_FILIAL = F1.F1_FILIAL"
     cQry  += "  and E2.E2_FORNECE = F1.F1_FORNECE"
     cQry  += "  and E2.E2_LOJA = F1.F1_LOJA"
     cQry  += "  and E2.E2_NUM = F1.F1_DOC"
     cQry  += "  and E2.E2_EMISSAO = F1.F1_EMISSAO"
     cQry  += "  and E2.D_E_L_E_T_ <> '*'"
     cQry  += "  and A2.A2_COD = F1.F1_FORNECE"
     cQry  += "  and A2.A2_LOJA = F1.F1_LOJA"
     cQry  += "  and A2.D_E_L_E_T_ <> '*'"
          
     If(mv_par09 == 1)
    	 cQry  += "   and E2.E2_SALDO = 0"
     EndIf
     If(mv_par09 == 2)
     	 cQry  += "   and E2.E2_SALDO <> 0"
     EndIf
     
     cQry  += " Group By  F1.F1_FILIAL,F1.F1_DOC, F1.F1_FORNECE,"
     cQry  += "          F1.F1_LOJA, A2.A2_NOME, A2.A2_CGC, F1.F1_EMISSAO,"
     cQry  += "          A2.A2_EST, E2.E2_VALOR, F1.F1_DTDIGIT,"
     cQry  += "          F1.F1_ESPECIE, E2.E2_VRETINS, E2.E2_ISS,"
     cQry  += "          E2.E2_VRETCOF, E2.E2_VRETCSL, E2.E2_VRETIRF, E2.E2_VRETPIS,"
     cQry  += "          E2.E2_VENCREA, (E2.E2_VALOR+E2.E2_VRETINS+E2.E2_VRETISS+E2.E2_VRETCOF+E2.E2_VRETCSL+E2.E2_VRETIRF+E2.E2_VRETPIS)"
     */
    TcQuery cQry New Alias "SD3QRY"
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
/*static function criaSX1(cPerg)


//PutSx1(cPerg,"01","Periodo de?"     ,"Periodo de?"       ,"Periodo de?"          ,"mv_ch1"  ,"D" ,8 ,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",{"Periodo inicio."    ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Periodo até?"    ,"Periodo até?"      ,"Periodo até?"         ,"mv_ch2"  ,"D" ,8 ,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{"Periodo fim."       ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","Local?"          ,"Local?"            ,"Local?"               ,"mv_ch3"  ,"C" ,2 ,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",{"Local."             ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","Item Conta?"     ,"Item Conta?"       ,"Item Conta?"          ,"mv_ch4"  ,"C" ,99,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{"Item Conta"         ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Item Conta?"     ,"Item Conta?"       ,"Item Conta?"          ,"mv_ch5"  ,"C" ,99,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{"Item Conta"         ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Bem"             ,"Bem"               ,"Bem"                  ,"mv_ch5"  ,"C" ,50,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{"Bem"                ,"","",""},{"","","",""},{"","",""},"")

return*/


/**********************************************************************************************************************************/
/** static function criaSX1                                                                                                      **/
/** cria perguntas.											                                                                     **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
/*static function criaSX1(cPerg)


//PutSx1(cPerg,"01","Filial de?"             ,"Filial de?"       ,"Filial de?"          ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"02","Filial até?"            ,"Filial até?"      ,"Filial até?"         ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."      ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"03","NF de?"                 ,"NF de?"           ,"NF de?"              ,"mv_ch3"  ,"C" ,9,0,0,"G","",""   ,"","","mv_par03","","","","","","","","","","","","","","","","",{"NF de."           ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"04","NF até?"                ,"NF até?"          ,"NF até?"             ,"mv_ch4"  ,"C" ,9,0,0,"G","",""   ,"","","mv_par04","","","","","","","","","","","","","","","","",{"NF até."          ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Pedido de?"             ,"Pedido de?"       ,"Pedido de?"          ,"mv_ch5"  ,"C" ,6,0,0,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",{"Pedido de."       ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Pedido até?"            ,"Pedido até?"      ,"Pedido até?"         ,"mv_ch6"  ,"C" ,6,0,0,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",{"Pedido até."      ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"05","Fornecedor de?"         ,"Fornecedor de?"   ,"Fornecedor de?"      ,"mv_ch5"  ,"C" ,6,0,0,"G","","SA2","","","mv_par05","","","","","","","","","","","","","","","","",{"Fornecedor de."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"06","Fornecedor até?"        ,"Fornecedor até?"  ,"Fornecedor até?"     ,"mv_ch6"  ,"C" ,6,0,0,"G","","SA2","","","mv_par06","","","","","","","","","","","","","","","","",{"Fornecedor até."  ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"07","Digitação de?"          ,"Digitação de?"    ,"Digitação de?"       ,"mv_ch7"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",{"Digitação de."    ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"08","Digitação até?"         ,"Digitação até?"   ,"Digitação até?"      ,"mv_ch8"  ,"D" ,8,0,0,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",{"Digitação até."   ,"","",""},{"","","",""},{"","",""},"")
//PutSx1(cPerg,"09","Liquidado?"             ,"Liquidado?"       ,"Liquidado?"          ,"mv_ch9"  ,"C" ,1,0,0,"C","",""   ,"","","mv_par09","Sim","Sim","Sim","Não","Não","Não","Ambos","Ambos","Ambos","","","","","","","",{"Liquidado?.","","",""},{"","","",""},{"","",""},"")
return                                                                                                   */
