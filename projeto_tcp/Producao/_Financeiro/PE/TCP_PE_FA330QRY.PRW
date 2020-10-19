//-------------------------------------------------------------------------------
/*/{Protheus.doc} FA330QRY
Ponto de entrada para alteração de query reduzindo o tempo de carregamento dos titulos

@return 
@author Felipe Toazza Caldeira
@since 16/03/2016
/*/
//-------------------------------------------------------------------------------
User Function FA330QRY                    
Local cAux	  := PARAMIXB[1]  
Local cQryAux := ""

	If MV_PAR15 == 1  //parametro criado no grupo FIN330
		cQryAux := Substr(cAux,1,AT("ORDER",cAux)-1)+" AND (E1_VENCREA >= '"+DtoS(SE1->E1_EMISSAO-15)+"' AND E1_VENCREA <= '"+DtoS(SE1->E1_EMISSAO+45)+"')"+" ORDER BY E1_FILIAL, E1_EMISSAO , E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO "
	Else
		cQryAux := PARAMIXB[1]	
	endIf    
	         
	
Return cQryAux