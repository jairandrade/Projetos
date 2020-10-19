#Include 'Protheus.ch'

/*/{Protheus.doc} PN210VAL
Ponto de entrada na manutencao de abonos.
PN210VAL - Validação da Linha
http://tdn.totvs.com.br/pages/releaseview.action?pageId=6082570
@type function
@author luizf
@since 18/08/2016
/*/
User Function PN210VAL()

LOCAL lRet   := .T.
LOCAL aParam := PARAMIXB[1] 

Return u_APONV01(aParam[02])//Data
/*
Será enviado um array ao Ponto de Entrada e este deve retornar um valor lógico informando se a linha digitada está correta ou incorreta.

Os dados do array são:
[01] - Data do evento a ser abonado;
[02] - Código do abono;
[03] - Descrição do abono;
[04] - Horas abonadas;
[05] - Hora inicial;
[06] - Hora final;
[07] - Flag da inclusão;
[08] - Alias da tabela;
[09] - Recno do registro;
[10] - Linha deletada?
*/
