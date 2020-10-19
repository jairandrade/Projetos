/**********************************************************************************************************************************/
/** user function RCAP2                                                                                                           **/
/** Relatorio de contas a pagar impostos da nota de entrada.                						                                                         **/
/** Analista: Alessandro Cardozo Bueno        						                                                             **/ 
/** Data desenvolvimento: 15/12/2015     						                                                                 **/
/**********************************************************************************************************************************/
/** Parâmetro  | Tipo | Tamanho | Descrição                                                                                      **/
/**********************************************************************************************************************************/
/** Nenhum parametro esperado neste procedimento                                                                                 **/
/**********************************************************************************************************************************/
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function RCAP2

private oReport := nil
// variavel do relatorio
private oSection := nil
private oSection1 := nil      
private oSection2 := nil
// grupo de pergunta
private cPerg      := "RCAP"


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
oReport := TReport():New("RCAP", "Relatório Contas a Pagar", cPerg, {|oReport| GerRelExe()}, "Este relatório imprime dados sobre o titulos a pagar com relacionando fornecedores e NF de entrada.")
oReport:cFontBody := 'Courier New'
oReport:nFontBody := 8

// define a seção principal
oSection := TRSection():New(oReport, "Titulos", {},,,,,,.T.,,,,,,,,,,,,)  

TRCell():New(oSection,"FILIAL"         , nil, "Filial "          ,"@!", 3)
TRCell():New(oSection,"NOTAFISCAL"     , nil, "Nota Fiscal "     ,"@!", 6)
//YTRCell():New(oSection,"PEDIDO"         , nil, "Pedido"           ,"@!", 6)
TRCell():New(oSection,"FORNECEDOR"     , nil, "Fornecedor"       ,"@!", 6) 
TRCell():New(oSection,"LOJA"           , nil, "Loja"             ,"@!", 3)
TRCell():New(oSection,"RSOCIAL"        , nil, "R. Social"        ,"@!",10) 
TRCell():New(oSection,"CNPJ/CPF"       , nil, "CNPJ/CPF"         ,"@R 99.999.999/9999-99",15) 
TRCell():New(oSection,"EMISSAO"        , nil, "Emissão"          ,"@!", 8)
TRCell():New(oSection,"ESTADO"         , nil, "Estado"           ,"@!", 2)
TRCell():New(oSection,"VLRTIT"         , nil, "Vlr. Bruto"       ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"DIGITACAO"      , nil, "Dt. Digitação"    ,"@!", 8)  
TRCell():New(oSection,"ESPDOC"         , nil, "Tp. Doc."         ,"@!", 5)  
TRCell():New(oSection,"VLRINSS"        , nil, "Vlr. INSS"        ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRISS"         , nil, "Vlr. ISS"         ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRPIS"         , nil, "Vlr PIS"          ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRCOF"         , nil, "Vlr. Cofins"      ,"@E 999,999,999,999.99", 17)  
TRCell():New(oSection,"VLRCSLL"        , nil, "Vlr. CSLL"        ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"IRRET"          , nil, "IR Retido"        ,"@E 999,999,999,999.99", 17)
TRCell():New(oSection,"VCTOREAL"       , nil, "Vcto. Real"       ,"@!", 8) 
TRCell():New(oSection,"VLRBRUTO"       , nil, "Vlr. Titulo"      ,"@E 999,999,999,999.99", 17)

return(oReport)    

/**********************************************************************************************************************************/
/** static function GerRelExe()                                                                                                  **/
/** processamento do relatório                                                                                                   **/
/**********************************************************************************************************************************/
static function GerRelExe()
oSection:Init() 

SF1QRY()
SF1QRY->(DbGoTop())
While (!SF1QRY->(Eof()))
  
 		oSection:Cell("FILIAL")           :SetValue(SF1QRY->FILIAL)     
     	oSection:Cell("NOTAFISCAL")       :SetValue(SF1QRY->NOTA) 
//	    oSection:Cell("PEDIDO")           :SetValue(SF1QRY->PEDIDO) 
     	oSection:Cell("FORNECEDOR")       :SetValue(SF1QRY->FORNECEDOR) 
   		oSection:Cell("LOJA")             :SetValue(SF1QRY->LOJA) 
    	oSection:Cell("RSOCIAL")          :SetValue(SF1QRY->RAZAO) 
    	oSection:Cell("CNPJ/CPF")         :SetValue(SF1QRY->CGC) 
    	oSection:Cell("EMISSAO")          :SetValue(SUBSTR(SF1QRY->EMISSAO,7,2)+'/'+SUBSTR(SF1QRY->EMISSAO,5,2)+'/'+SUBSTR(SF1QRY->EMISSAO,1,4))
     	oSection:Cell("ESTADO")           :SetValue(SF1QRY->ESTADO) 
    	oSection:Cell("VLRBRUTO")         :SetValue(SF1QRY->VLRLIQ) 
    	oSection:Cell("DIGITACAO")        :SetValue(SUBSTR(SF1QRY->DIGITACAO,7,2)+'/'+SUBSTR(SF1QRY->DIGITACAO,5,2)+'/'+SUBSTR(SF1QRY->DIGITACAO,1,4))
    	oSection:Cell("ESPDOC")           :SetValue(SF1QRY->TIPO) 
    	oSection:Cell("VLRINSS")          :SetValue(SF1QRY->VLRINSS) 
	    oSection:Cell("VLRISS")           :SetValue(SF1QRY->VLRISS) 
    	oSection:Cell("VLRPIS")           :SetValue(SF1QRY->VLRPIS) 
    	oSection:Cell("VLRCOF")           :SetValue(SF1QRY->VLRCOFINS) 
     	oSection:Cell("VLRCSLL")          :SetValue(SF1QRY->VLRCSLL) 
    	oSection:Cell("IRRET")            :SetValue(SF1QRY->VLRIR) 
    	oSection:Cell("VCTOREAL")         :SetValue(SUBSTR(SF1QRY->VENCREAL,7,2)+'/'+SUBSTR(SF1QRY->VENCREAL,5,2)+'/'+SUBSTR(SF1QRY->VENCREAL,1,4))
    	oSection:Cell("VLRTIT")           :SetValue(SF1QRY->VALOR) 
	
	oSection:PrintLine()
	
	SF1QRY->(dbSkip())    
	
EndDo                 
SF1QRY->(dbCloseArea())     
    
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
static Function SF1QRY
  	local aArea := GetArea()

	local cQry  := "" 

	 /*cQry  := "select D1.D1_FILIAL FILIAL,D1.D1_DOC NOTA, D1.D1_PEDIDO PEDIDO, D1.D1_FORNECE FORNECEDOR,"
	 cQry  += "       D1.D1_LOJA LOJA, A2.A2_NOME RAZAO, A2.A2_CGC CGC, D1.D1_EMISSAO EMISSAO,"
	 cQry  += "       A2.A2_EST ESTADO, E2.E2_VALOR VALOR, D1.D1_DTDIGIT DIGITACAO,"
	 cQry  += "	      E2.E2_TIPO TIPO, E2.E2_VRETINS VLRINSS, E2.E2_VRETISS VLRISS," 
	 cQry  += "	      E2.E2_VRETCOF VLRCOFINS, E2.E2_VRETCSL VLRCSLL, E2.E2_VRETIRF VLRIR, E2.E2_VRETPIS VLRPIS,"
	 cQry  += "	   E2.E2_VENCREA VENCREAL, E2.E2_VALOR VALOR"   
	   */	 
	 /*cQry  := "Select D1.D1_FILIAL FILIAL,D1.D1_DOC NOTA, D1.D1_PEDIDO PEDIDO, D1.D1_FORNECE FORNECEDOR,"
	 cQry  += "       D1.D1_LOJA LOJA, A2.A2_NOME RAZAO, A2.A2_CGC CGC, D1.D1_EMISSAO EMISSAO,"
	 cQry  += "       A2.A2_EST ESTADO, E2.E2_VALOR VLRLIQ, D1.D1_DTDIGIT DIGITACAO,"
	 cQry  += "       F1.F1_ESPECIE TIPO, E2.E2_VRETINS VLRINSS, E2.E2_ISS VLRISS,"
	 cQry  += "       E2.E2_VRETCOF VLRCOFINS, E2.E2_VRETCSL VLRCSLL, E2.E2_VRETIRF VLRIR, E2.E2_VRETPIS VLRPIS,"
	 cQry  += "	      E2.E2_VENCREA VENCREAL, (E2.E2_VALOR+E2.E2_VRETINS+E2.E2_ISS+E2.E2_VRETCOF+E2.E2_VRETCSL+E2.E2_VRETIRF+E2.E2_VRETPIS) VALOR"
	 cQry  += "  from "+ RetSqlName("SE2") +" E2, "+ RetSqlName("SD1") +" D1, "+ RetSqlName("SA2") +" A2, "+ RetSqlName("SF1") +" F1"
	 cQry  += " Where E2.E2_NUM = D1.D1_DOC"
	 cQry  += "   and E2.E2_FORNECE = D1.D1_FORNECE"
	 cQry  += "   and E2.E2_LOJA = D1.D1_LOJA" 
	 cQry  += "   and A2.A2_COD = D1.D1_FORNECE"
	 cQry  += "   and A2.A2_LOJA = D1.D1_LOJA"
	 cQry  += "   and E2.D_E_L_E_T_ <> '*'"
	 cQry  += "   and D1.D_E_L_E_T_ <> '*'" 
	 cQry  += "   and A2.D_E_L_E_T_ <> '*'"  
	 cQry  += "   and F1.F1_DOC = D1.D1_DOC"
	 cQry  += "   and F1.F1_FORNECE = D1.D1_FORNECE"
	 cQry  += "   and F1.F1_LOJA = D1.D1_LOJA"
	 cQry  += "   and E2.E2_FILIAL  between '"+MV_PAR01+"' and '"+MV_PAR02+"'"
	 cQry  += "   and D1.D1_PEDIDO  between '"+MV_PAR05+"' and '"+MV_PAR06+"'"
     cQry  += "   and D1.D1_FORNECE between '"+MV_PAR07+"' and '"+MV_PAR08+"'"
     cQry  += "   and D1.D1_DTDIGIT between '"+DtoS(MV_PAR09)+"' and '"+DtoS(MV_PAR10)+"'" 
     cQry  += " Group By  D1.D1_FILIAL,D1.D1_DOC, D1.D1_PEDIDO, D1.D1_FORNECE,"
     cQry  += "           D1.D1_LOJA, A2.A2_NOME, A2.A2_CGC, D1.D1_EMISSAO,"
     cQry  += "           A2.A2_EST, E2.E2_VALOR, D1.D1_DTDIGIT,"
     cQry  += "           F1.F1_ESPECIE, E2.E2_VRETINS, E2.E2_ISS,"
     cQry  += "           E2.E2_VRETCOF, E2.E2_VRETCSL, E2.E2_VRETIRF, E2.E2_VRETPIS,"
     cQry  += "	          E2.E2_VENCREA, (E2.E2_VALOR+E2.E2_VRETINS+E2.E2_VRETISS+E2.E2_VRETCOF+E2.E2_VRETCSL+E2.E2_VRETIRF+E2.E2_VRETPIS)"    
     */
     
     cQry  := "Select F1.F1_FILIAL FILIAL,F1.F1_DOC NOTA, F1.F1_FORNECE FORNECEDOR,"
     cQry  += "       F1.F1_LOJA LOJA, A2.A2_NOME RAZAO, A2.A2_CGC CGC,"
	 cQry  += "       F1.F1_EMISSAO EMISSAO, A2.A2_EST ESTADO,  F1.F1_DTDIGIT DIGITACAO,E2.E2_VALOR VLRLIQ,"
     cQry  += "       F1.F1_ESPECIE TIPO, "
	 cQry  += "       E2.E2_INSS VLRINSS, E2.E2_ISS VLRISS,"
     cQry  += "       E2.E2_COFINS VLRCOFINS, E2.E2_CSLL VLRCSLL, E2.E2_IRRF VLRIR, E2.E2_PIS VLRPIS,"
//   cQry  += "       E2.E2_VENCREA VENCREAL, (E2.E2_VALOR+E2.E2_VRETINS+E2.E2_ISS+E2.E2_VRETCOF+E2.E2_VRETCSL+E2.E2_VRETIRF+E2.E2_VRETPIS) VALOR"
     cQry  += "       E2.E2_VENCREA VENCREAL, (E2.E2_VALOR+E2.E2_INSS+E2.E2_ISS+E2.E2_COFINS+E2.E2_CSLL+E2.E2_IRRF+E2.E2_PIS) VALOR"
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
     cQry  += "          F1.F1_ESPECIE, E2.E2_INSS, E2.E2_ISS,"
     cQry  += "          E2.E2_COFINS, E2.E2_CSLL, E2.E2_IRRF, E2.E2_PIS,"
     cQry  += "          E2.E2_VENCREA, (E2.E2_VALOR+E2.E2_INSS+E2.E2_VRETISS+E2.E2_COFINS+E2.E2_CSLL+E2.E2_IRRF+E2.E2_PIS)"
     
    TcQuery cQry New Alias "SF1QRY"
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
return
