#INCLUDE "PROTHEUS.ch"

User Function MA280FIM()
    Local dData :=  ParamIxb  
    Local aResult := {}
    Local cAno := Substr( Dtos(dData), 1, 4)
    Local cMes := Substr( Dtos(dData), 5, 2)
    
    if cempant <> '02'
       return
    endif
    
    if cMes < '12' 
        cData := cAno + Soma1(cMes)
    else
        cData := Soma1(cAno) + '01'
    endif
    
    aResult := TCSPEXEC("PR_ORDER_POINT_"+cempant, cData)
 
    IF empty(TcSqlError())
    	MsgInfo("Procedure de geração de dados para ORDER POINT executada com sucesso.")
	Else
        Msginfo('Procedure de geração de dados para ORDER POINT não executada devido ao erro: '+TcSqlError())
    Endif
    
    return
    