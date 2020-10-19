#include "protheus.ch"

/*/{Protheus.doc} FI290COLS
Ponto de entrada para inclusão de campos no aCols/aHeader
@type user function
@version 
@author Kaique Mathias
@since 9/11/2020
@return return_type, return_description
/*/

User Function FI290COLS()
    
    Local nTipo := PARAMIXB[1] // Array
    Local aRet  := PARAMIXB[2] // Posição do Array
    Local nI    := PARAMIXB[3] // Posição do Array aHeader
    Local nCount // Array com os campos a serem incluídos
    Local aColPE:= {"E2_XORIGEM"} // Condição utilizado para retornar o restante do aHeader
    
    If nTipo == 1

        dbSelectArea("SX3")
        dbSetOrder(2)
    
        For nCount := 1 to len(aColPE)
            DbSeek(aColPE[nCount])

            AADD(aRet,{ X3TITULO(aColPE[nCount]), aColPE[nCount], X3PICTURE(aColPE[nCount]), TamSx3(aColPE[nCount])[1] ,0,"","û",Posicione("SX3",2,aColPE[nCount],'X3_TIPO'),"SE2" } ) // "Cabeçalho do campo adicinado FI290Cols"

        next nCount // Ponto que Incrementa os valores das colunas

    Else
        
        aAdd(aRet[nI],fRetOrigem()) //Novo campo Adicionado
        //Identifica se o registro esta deletado
        //Esta posição deve ser adicionada sempre que
        //criado o ponto de entrada
        AaDD(aRet[nI],.F.)

    EndIF

Return( aRet )

/*/{Protheus.doc} fRetOrigem
Retorna a Origem do titulo de maior valor.
@type function
@version 
@author Kaique Mathias
@since 9/14/2020
@return return_type, return_description
/*/

Static Function fRetOrigem()

    Local aAreaSE2  := SE2->(getArea())
    Local aRegs     := {}
    
    While !TRBSE2->(Eof())
        dbSelectArea('SE2')
        SE2->(dbgoto(TRBSE2->RECNO))
        aAdd(aRegs,{SE2->E2_VALOR,SE2->E2_XORIGEM})
        TRBSE2->(dbSkip())
    EndDo

    aSort(aRegs,,,{|x,y| x[1] > y[1]})

    RestArea( aAreaSE2 )

Return(aRegs[1][2])
