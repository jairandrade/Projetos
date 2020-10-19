#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TCMD04KM
Fonte responsavel por validar o saldo do endereço da tela de EPI x 
Funcionario. 
@author  Kaique Sousa
@since   23/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function TCMD04KM()

    Local nPosLocal := aScan(aHeader,{|x| Alltrim(x[2]) == "TNF_LOCAL"})
    Local nPosCod   := aScan(aHeader,{|x| Alltrim(x[2]) == "TNF_CODEPI"})
    Local nPosQuant := aScan(aHeader,{|x| Alltrim(x[2]) == "TNF_QTDENT"})
    Local cLocal    := aCols[n,nPosLocal] 
    Local cEnderec  := &(ReadVar()) 
    Local cCodEPI   := aCols[n,nPosCod] 
    Local nQuant    := aCols[n,nPosQuant]
    Local lRet      := .T.
    
    If QtdComp(SaldoSBF(cLocal,cEnderec,cCodEPI)) < nQuant
      Alert("O produto não tem saldo Enderecado suficiente ou o Endereço selecionado não tem saldo suficiente. Pressione a tecla F4 para listar os endereços com estoque disponivel.")
      lRet:=.F.
    EndIf

Return( lRet )