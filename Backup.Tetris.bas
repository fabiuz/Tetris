' *****************************************************************************************
'   PROGRAMA:       TETRIS
'   VERS�O:         1.0
'   AUTOR:          F�BIO MOURA DE OLIVEIRA
'   DATA DE IN�CIO: 14/12/2016
'   DATA DE T�RMINO:
'   DESCRI��O:      ESTE PROGRAMA � UM JOGO DE COMPUTADOR SEMELHANTE AO JOGO CL�SSICO TETRIS.
' *****************************************************************************************

#COMPILE EXE
#DIM ALL
#INCLUDE "win32api.inc"

' Nomenclatura do jogo:
' Tabuleiro:    � o local onde os blocos s�o inseridos.
' C�lula:           Interse��o entre linha e coluna do tabuleiro.
' Bloco:            Um conjunto de c�lulas conectadas a uma outra c�lula vizinha
'                           formando um imagem.
' Pe�a:             Regi�o, geralmente, em forma quadr�tica, em que um bloco reside.


' Constantes do jogo
%CELULAS_POR_LINHA = 30
%CELULAS_POR_COLUNA = 20
%CELULAS_TOTAIS = %CELULAS_POR_LINHA * %CELULAS_POR_COLUNA

' Indica a quantidade de c�lulas em uma pe�a
%PECA_CELULAS_POR_LINHA = 3
%PECA_CELULAS_POR_COLUNA = 3
%PECA_CELULAS_TOTAIS = %PECA_CELULAS_POR_LINHA * %PECA_CELULAS_POR_COLUNA

' Indica a quantidade de linhas que a pe�a desloca pelo tabuleiro
%PECA_DESLOCAMENTO_VERTICAL = 1
%PECA_DESLOCAMENTO_HORIZONTAL = 1

' Indica as dimens�es de uma c�lula.
%CELULA_LARGURA = 20
%CELULA_ALTURA = 20
%CELULA_COR_BORDA = %RGB_BLACK
%CELULA_COR_PREENCHIMENTO = %RGB_WHITE

%BLOCO_LARGURA = 10
%BLOCO_ALTURA = 10

%BLOCO_LINHAS = 3
%BLOCO_COLUNAS = 3

%JOGO_LARGURA = 700
%JOGO_ALTURA = 700

' Indica as coordenadas do canto superior em pixel.
%TABULEIRO_COR_DE_FUNDO = %RGB_WHITE
%TABULEIRO_COR_DA_GRADE = %RGB_BLACK
%TABULEIRO_ESPACO_HORIZONTAL_ENTRE_CELULAS = 1
%TABULEIRO_ESPACO_VERTICAL_ENTRE_CELULAS = 1

' Define o tabuleiro para o centro da tela
%TABULEIRO_ESQUERDA = (%JOGO_LARGURA - ((%CELULA_LARGURA + %TABULEIRO_ESPACO_VERTICAL_ENTRE_CELULAS) * %CELULAS_POR_COLUNA))/2
%TABULEIRO_TOPO = 10

%TABULEIRO_LINHAS = %CELULAS_POR_LINHA
%TABULEIRO_COLUNAS = %CELULAS_POR_COLUNA

' Este tipo armazena onde a pe�a
' est� localizada no tabuleiro.
TYPE pecaPosicao
    x_esquerda AS LONG              ' Posi��o X no tabuleiro, onde o lado esquerdo da pe�a se localiza.
    x_direita AS LONG               ' Posicao X no tabuleiro, onde o lado direito da pe�a se localiza.
    y_superior AS LONG              ' Posi��o Y no tabuleiro, onde o lado superior da pe�a se localiza.
    y_inferior AS LONG              ' Posicao Y no tabuleiro, onde o lado inferior da pe�a se localiza.

END TYPE

TYPE blocoPosicao
    x_esquerda AS LONG              ' Posi��o X no tabuleiro, onde o lado esquerdo do bloco se localiza.
    x_direita AS LONG               ' Posicao X no tabuleiro, onde o lado direito do bloco se localiza.
    y_superior AS LONG              ' Posi��o Y no tabuleiro, onde o lado superior do bloco se localiza.
    y_inferior AS LONG              ' Posicao Y no tabuleiro, onde o lado inferior do bloco se localiza.
END TYPE

' No jogo Tetris, que criei, a l�gica funciona assim, se a c�lula
' do tabuleiro tem valor 1 que dizer que h� pe�a l�
' Entretanto, em PowerBasic, n�o � poss�vel criar um arranjo din�mico
' dentro de uma udt, ent�o, criarmos para nosso jogo, dentro de uma
' udt,

TYPE celulaComValorUm
    ' Em powerBasic, n�o podemos criar um arranjo din�mico
    ' dentro de uma UDT, por isto, criamos um arranjo de largura
    ' e altura fixa mas as pe�as tem tamanhos diferentes
    ' Pra sabermos onde come�a uma pe�a e termina a pe�a
    ' devemos saber onde dentra da caixa que circunda  a pe�a,
    ' qual a coluna mais a esquerda e coluna mais a direita que tem
    ' o valor 1 e qual a linha primeira linha e a �ltima linha
    ' que tem uma c�lula com valor 1.
    ' Isto, servir� tamb�m, para podermos nos orientar dentro
    ' do arranjo c�lula
    ' Pois, somente come�aremos a analisar o arranjo 'celula'
    ' somente em linha ou coluna que tenha uma c�lula com valor 1.

    primeira_coluna_com_celula_valor_um AS LONG     ' Indica qual coluna mais a esquerda que tem c�lula com valor 1.
    ultima_coluna_com_celula_valor_um  AS LONG       ' Indica qual coluna mais a direita que tem c�lula com valor 1.
    primeira_linha_com_celula_valor_um AS LONG       ' Indica qual linha acima de todas as outras que tem c�lula valor 1.
    ultima_linha_com_celula_valor_um AS LONG         ' Indica qual linha abaixo de todas as outras que tem c�lula valor 1.
END TYPE



' A pe�a � um dos componentes do jogo que guarda um conjunto de
' c�lulas. A pe�a � disposta em uma regi�o de lados iguais.
' Na pe�a, um c�lula � identificada por 1 ou por 0.
' O valor '1', significa, que a cor vai ser renderizada na
' posi��o onde a c�lula ser� desenhada.
' Ser� zero, se a cor n�o ser� renderizada.
' Ent�o, desta forma, no jogo Tetris, � poss�vel ver aqueles
' blocos de diversas formas.
TYPE peca
    ' Guarda a informa��o de cada c�lula da pe�a.
    ' Sempre a largura e altura da c�lula ter�o o mesmo valor.
    celulas(1 TO %BLOCO_LINHAS, 1 TO %BLOCO_COLUNAS) AS LONG

    celulaCor AS LONG
    posicao AS pecaPosicao

    ' Pode ser que cada pe�a, seja menor que a largura e/ou
    ' a altura da caixa que a circunda devemos, armazenar
    ' a largura e altura de cada pe�a.
    ' Isto ser� �til, quando girarmos a pe�a,
    ' Pois, iremos fazer diferente, vamos girar a caixa
    ' em que a pe�a se encontra, entretanto, devemos atualizar
    ' os valores abaixo.
    ' Por exemplo, se a largura � 3 e a altura � 2, quando
    ' girarmos para a esquerda, a largura ser� 2 e altura 3.
    largura_da_peca AS LONG
    altura_da_peca AS LONG

    celulaValorUm AS celulaComValorUm

END TYPE



' Vamos guarda as informa��es pertinentes a uma �nica c�lula.
TYPE celulaTabuleiro
    X_Superior_Esquerda AS LONG     ' Posi��o X do canto superior esquerdo da c�lula.
    Y_Superior_Esquerda AS LONG     ' Posi��o Y do canto superior esquerdo da c�lula.
    X_Inferior_Direita AS LONG      ' Posicao X do canto inferior direito da c�lula.
    Y_Inferior_Direita AS LONG      ' Posicao Y do canto inferior direito da c�lula.

    celulaOcupada AS LONG           ' Indica se a c�lula j� est� ocupada: 0, significa n�o ocupada
    celulaCor AS LONG               ' Se a c�lula est� ocupada, indica a cor do preenchimento.
END TYPE

' Criar as pe�as a serem utilizadas no jogo.
SUB PecasPreencher(BYREF pecas() AS peca)

    DATA "1", "0", "0"
    DATA "1", "1", "1"
    DATA "0", "0", "1"

   #IF 1
    ' Peca pequenas
    DATA "0", "0", "0"
    DATA "0", "1", "0"
    DATA "0", "0", "0"

    DATA "0", "1", "0"
    DATA "0", "1", "0"
    DATA "0", "0", "0"

    DATA "0", "1", "0"
    DATA "0", "1", "0"
    DATA "0", "1", "0"

    ' FORMATO L ESQUERDO
    DATA "1", "1", "0"
    DATA "0", "1", "0"
    DATA "0", "0", "0"

    DATA "1", "1", "0"
    DATA "0", "1", "0"
    DATA "0", "1", "0"

    ' FORMATO L DIREITO
    DATA "0", "1", "1"
    DATA "0", "1", "0"
    DATA "0", "0", "0"

    DATA "0", "1", "1"
    DATA "0", "1", "0"
    DATA "0", "1", "0"

    ' FORMATO T
    DATA "1", "1", "1"
    DATA "0", "1", "0"
    DATA "0", "0", "0"

    DATA "1", "1", "1"
    DATA "0", "1", "0"
    DATA "0", "1", "0"

    ' FORMATO QUADRADO
    DATA "1", "1", "1"
    DATA "1", "0", "1"
    DATA "1", "1", "1"

    ' FORMATO QUADRADO PREENCHIDO
    DATA "1", "1", "1"
    DATA "1", "1", "1"
    DATA "1", "1", "1"

    ' FORMATO L DOS CANTOS
    DATA "1", "1", "0"
    DATA "1", "0", "0"
    DATA "0", "0", "0"

    ' FORMATO L DOS CANTOS
    DATA "1", "1", "1"
    DATA "1", "0", "0"
    DATA "1", "0", "0"

    ' FORMATO L
    DATA "1", "1", "1"
    DATA "1", "0", "0"
    DATA "0", "0", "0"

    ' FORMATO L
    DATA "1", "1", "1"
    DATA "0", "0", "1"
    DATA "0", "0", "0"

    ' FORMATO L
    DATA "1", "0", "0"
    DATA "1", "1", "1"
    DATA "0", "0", "0"

    ' FORMATO L
    DATA "0", "0", "1"
    DATA "1", "1", "1"
    DATA "0", "0", "0"

    ' FORMATO C OU U
    DATA "1", "1", "0"
    DATA "0", "1", "0"
    DATA "1", "1", "0"

    ' FORMATO C OU U INVERTIDO
    DATA "1", "1", "0"
    DATA "1", "0", "0"
    DATA "1", "1", "0"

    ' FORMATO H
    DATA "1", "1", "1"
    DATA "0", "1", "0"
    DATA "1", "1", "1"

    ' FORMATO ESCADA
    DATA "1", "0", "0"
    DATA "1", "1", "0"
    DATA "0", "1", "0"

    DATA "1", "0", "0"
    DATA "1", "1", "1"
    DATA "0", "0", "1"

    DATA "1", "0", "1"
    DATA "0", "1", "0"
    DATA "1", "0", "1"

    #ENDIF

    ' Se inserimos novos dados, simplesmente, o
    ' arranjo, ser� criado com a quantidade correta.
    ' S� iremos pegar quantidades m�ltiplas da constantes %PECA_CELULAS_TOTAIS
    LOCAL pecasQuantidade AS LONG
    pecasQuantidade = INT(DATACOUNT / %PECA_CELULAS_TOTAIS)
    REDIM pecas(1 TO pecasQuantidade)

    LOCAL uA, uB, uC AS LONG
    LOCAL indiceLerData AS LONG
    indiceLerData = 1


    ' Um bloco � onde � armazenada uma pe�a do jogo
    ' Pode acontecer que a largura da pe�a e/ou a
    ' altura da pe�a seja menor que a largura do bloco.
    ' e/ou altura do bloco
    ' Um pe�a � composta de 1 ou mais c�lulas com valor
    ' 1, ent�o para podermos localizar a largura e
    ' a altura de uma pe�a, devemos, saber

    LOCAL primeira_coluna_com_celula_valor_um AS LONG      ' Indica qual coluna mais a esquerda que tem c�lula com valor 1.
    LOCAL ultima_coluna_com_celula_valor_um  AS LONG       ' Indica qual coluna mais a direita que tem c�lula com valor 1.
    LOCAL primeira_linha_com_celula_valor_um AS LONG       ' Indica qual linha acima de todas as outras que tem c�lula valor 1.
    LOCAL ultima_linha_com_celula_valor_um AS LONG         ' Indica qual linha abaixo de todas as outras que tem c�lula valor 1.

    FOR uA = LBOUND(pecas()) TO UBOUND(pecas())
        primeira_coluna_com_celula_valor_um = 0
        ultima_coluna_com_celula_valor_um = 0
        primeira_linha_com_celula_valor_um = 0
        ultima_linha_com_celula_valor_um   = 0

        FOR uB = 1 TO %BLOCO_LINHAS
            FOR uC = 1 TO %BLOCO_COLUNAS
                pecas(uA).celulas(uB, uC) = VAL(READ$(indiceLerData))
                INCR indiceLerData

                ' Vamos verificar se encontramos uma c�lula com valor 1
                ' Como todas as vari�veis tem valor zero, antes de executar o loop
                ' Vamos verificar se achamos uma c�lula 1.
                IF pecas(uA).celulas(uB, uC) = 1 THEN
                    ' Como todas as vari�veis s�o definidas com valor 0, ent�o
                    ' fica f�cil saber qual � a coluna mais a esquerda
                    IF primeira_coluna_com_celula_valor_um = 0 THEN
                        primeira_coluna_com_celula_valor_um = uC
                    ELSEIF uC < primeira_coluna_com_celula_valor_um THEN
                        primeira_coluna_com_celula_valor_um = uC
                    END IF

                    ' Vamos verificar a �ltima coluna, este � simples
                    IF uC > ultima_coluna_com_celula_valor_um THEN
                        ultima_coluna_com_celula_valor_um = uC
                    END IF

                    ' Como todas as vari�veis s�o definidas com valor 0, ent�o
                    ' fica f�cil saber qual � a menor linha que contem c�lula com valor 1
                    IF primeira_linha_com_celula_valor_um = 0 THEN
                        primeira_linha_com_celula_valor_um = uB
                    ELSEIF primeira_linha_com_celula_valor_um > uB THEN
                        primeira_linha_com_celula_valor_um = uB
                    END IF

                    ' Vamos verificar qual � a �ltima linha que cont�m o valor 1
                    IF uB > ultima_linha_com_celula_valor_um THEN
                        ultima_linha_com_celula_valor_um = uB
                    END IF

                END IF

            NEXT uC
        NEXT
        ' Agora, vamos guadar os dados que foram encontrados.
        pecas(uA).celulaValorUm.primeira_coluna_com_celula_valor_um = primeira_coluna_com_celula_valor_um
        pecas(uA).celulaValorUm.ultima_coluna_com_celula_valor_um = ultima_coluna_com_celula_valor_um
        pecas(uA).celulaValorUm.primeira_linha_com_celula_valor_um = primeira_linha_com_celula_valor_um
        pecas(uA).celulaValorUm.ultima_linha_com_celula_valor_um    = ultima_linha_com_celula_valor_um

        ' A largura, � f�cil
        pecas(uA).largura_da_peca = ultima_coluna_com_celula_valor_um - primeira_coluna_com_celula_valor_um + 1
        pecas(uA).altura_da_peca = ultima_linha_com_celula_valor_um - primeira_linha_com_celula_valor_um + 1

    NEXT

END SUB



'***********************************************************************************************
'   Sorte uma pe�a e retorna ela.
'***********************************************************************************************
SUB Peca_Sortear(BYREF pecas() AS peca, BYREF pecaAtual AS peca)

    ' Vamos sortear uma pe�a qualquer.
    DIM numeroAleatorio AS LONG
    numeroAleatorio = RND(LBOUND(pecas()), UBOUND(pecas()))

    pecaAtual = pecas(numeroAleatorio)


    ' Sortea uma cor para as c�lulas da pe�a.
    LOCAL peca_cor AS LONG
    peca_cor = CHOOSE(RND(1, 7), %RGB_BLUE, %RGB_CHOCOLATE, %RGB_CYAN, %RGB_DARKRED, %RGB_RED, %RGB_YELLOW, %RGB_GREEN)

    pecaAtual.celulacor = peca_cor

    ' Posicionar tabuleiro centralizado horizontalmente
    pecaAtual.posicao.x_Esquerda = INT((%TABULEIRO_COLUNAS - %PECA_CELULAS_POR_COLUNA)/ 2)

    ' Aqui, a largura de x ser� igual
    pecaAtual.posicao.x_Direita = pecaAtual.posicao.x_Esquerda + pecaAtual.largura_da_peca - 1

    ' Come�ar na primeira linha do tabuleiro.
    pecaAtual.posicao.y_Superior =  1
    pecaAtual.posicao.y_Inferior =  pecaAtual.posicao.y_Superior + pecaAtual.altura_da_peca - 1

END SUB



'***********************************************************************************************
'   Sorte uma pe�a e retorna ela.
'***********************************************************************************************
SUB Peca_Sortear_Antigo(BYREF pecas() AS peca, BYREF pecaAtual AS peca)

    ' Vamos sortear uma pe�a qualquer.
    DIM numeroAleatorio AS LONG
    numeroAleatorio = RND(LBOUND(pecas()), UBOUND(pecas()))

    'numeroAleatorio = 1

    ' Vamos criar um arranjo bidimensional para guardar os valores
    ' O tipo peca, tem um arranjo bidimensional, de nome celulas, ent�o devemos
    ' obter o limite inferior e superior das dimens�es 1 e 2, para podermos
    ' criar o arranjo com o tamanho correto.
    LOCAL pecaValores() AS LONG
    REDIM pecaValores(1 TO %PECA_CELULAS_POR_LINHA, 1 TO %PECA_CELULAS_POR_COLUNA)

    ' Agora, carrega a pe�a, que ser� retornada da fun��o
    LOCAL linha, coluna AS LONG

    FOR Linha = LBOUND(pecaValores(), 1) TO UBOUND(pecaValores(), 1)
        FOR coluna = LBOUND(pecaValores(), 2) TO UBOUND(pecaValores(), 2)
            pecaValores(linha,coluna) = pecas(numeroAleatorio).celulas(linha, coluna)
        NEXT coluna
    NEXT ulinha


    ' Agora, carrega o arranjo que carregar� os valores
    FOR Linha = LBOUND(pecaValores(), 1) TO UBOUND(pecaValores(), 1)
        FOR coluna = LBOUND(pecaValores(), 2) TO UBOUND(pecaValores(), 2)
            pecaAtual.celulas(linha,coluna) = pecaValores(linha, coluna)
        NEXT coluna
    NEXT ulinha

    ' Sortea uma cor para as c�lulas da pe�a.
    LOCAL peca_cor AS LONG
    peca_cor = CHOOSE(RND(1, 7), %RGB_BLUE, %RGB_CHOCOLATE, %RGB_CYAN, %RGB_DARKRED, %RGB_RED, %RGB_YELLOW, %RGB_GREEN)

    pecaAtual.celulacor = peca_cor

    ' Posicionar tabuleiro centralizado horizontalmente
    pecaAtual.posicao.x_Esquerda = INT((%TABULEIRO_COLUNAS - %PECA_CELULAS_POR_COLUNA)/ 2)

    ' Aqui, a largura de x ser� igual
    pecaAtual.posicao.x_Direita = pecaAtual.posicao.x_Esquerda + pecaAtual.largura_da_peca - 1

    ' Come�ar na primeira linha do tabuleiro.
    pecaAtual.posicao.y_Superior =  1
    pecaAtual.posicao.y_Inferior =  pecaAtual.posicao.y_Superior + pecaAtual.altura_da_peca - 1

END SUB

' Ao girar, a pe�a deve manter a coordenada do bloco onde a pe�a est�
' corretamente, pois, nossa coordenada � baseada na coordenada da pe�a
' e n�o do bloco.
' Ent�o, abaixo, iremos corretamente, chegar na coordenada do bloco.

SUB Peca_Girar(BYREF pecaAtual AS peca)
    LOCAL pecaTemp AS peca
    LOCAL linhaBloco, colunaBloco AS LONG
    LOCAL linhaBlocoDestino, colunaBlocoDestino AS LONG

    'pecaTemp = pecaAtual

    FOR linhaBloco = 1 TO %BLOCO_LINHAS
        colunaBlocoDestino = %BLOCO_COLUNAS - linhaBloco + 1
        FOR colunaBloco = 1 TO %BLOCO_COLUNAS
            ' Cada c�lula da esquerda pra direita da primeira linha, nesta ordem, da peca de Origem
            ' Vai para a �ltima coluna da pe�a de destino, come�ando a distribuir as c�lulas de cima
            ' para baixo.
            pecaAtual.celulas(colunaBloco, colunaBlocoDestino) = pecaTemp.celulas(linhaBloco, colunaBloco)
        NEXT
    NEXT linhabloco

    LOCAL primeira_coluna_com_celula_valor_um AS LONG      ' Indica qual coluna mais a esquerda que tem c�lula com valor 1.
    LOCAL ultima_coluna_com_celula_valor_um  AS LONG       ' Indica qual coluna mais a direita que tem c�lula com valor 1.
    LOCAL primeira_linha_com_celula_valor_um AS LONG       ' Indica qual linha acima de todas as outras que tem c�lula valor 1.
    LOCAL ultima_linha_com_celula_valor_um AS LONG         ' Indica qual linha abaixo de todas as outras que tem c�lula valor 1.

    primeira_coluna_com_celula_valor_um = 0
    ultima_coluna_com_celula_valor_um = 0
    primeira_linha_com_celula_valor_um = 0
    ultima_linha_com_celula_valor_um   = 0

    FOR linhaBloco = 1 TO %BLOCO_LINHAS
        FOR colunaBloco = 1 TO %BLOCO_COLUNAS

            ' Vamos verificar se encontramos uma c�lula com valor 1
            ' Como todas as vari�veis tem valor zero, antes de executar o loop
            ' Vamos verificar se achamos uma c�lula 1.
            IF pecaAtual.celulas(linhaBloco, colunaBloco) = 1 THEN
                ' Como todas as vari�veis s�o definidas com valor 0, ent�o
                ' fica f�cil saber qual � a coluna mais a esquerda
                IF primeira_coluna_com_celula_valor_um = 0 THEN
                    primeira_coluna_com_celula_valor_um = colunaBloco
                ELSEIF colunaBloco < primeira_coluna_com_celula_valor_um THEN
                    primeira_coluna_com_celula_valor_um = colunaBloco
                END IF

                ' Vamos verificar a �ltima coluna, este � simples
                IF colunaBloco > ultima_coluna_com_celula_valor_um THEN
                    ultima_coluna_com_celula_valor_um = colunaBloco
                END IF

                ' Como todas as vari�veis s�o definidas com valor 0, ent�o
                ' fica f�cil saber qual � a menor linha que contem c�lula com valor 1
                IF primeira_linha_com_celula_valor_um = 0 THEN
                    primeira_linha_com_celula_valor_um = linhaBloco
                ELSEIF primeira_linha_com_celula_valor_um > linhaBloco THEN
                    primeira_linha_com_celula_valor_um = linhaBloco
                END IF

                ' Vamos verificar qual � a �ltima linha que cont�m o valor 1
                IF linhaBloco > ultima_linha_com_celula_valor_um THEN
                    ultima_linha_com_celula_valor_um = linhaBloco
                END IF

            END IF

        NEXT colunaBloco
    NEXT
    ' Agora, vamos guadar os dados que foram encontrados.
    pecaAtual.celulaValorUm.primeira_coluna_com_celula_valor_um = primeira_coluna_com_celula_valor_um
    pecaAtual.celulaValorUm.ultima_coluna_com_celula_valor_um = ultima_coluna_com_celula_valor_um
    pecaAtual.celulaValorUm.primeira_linha_com_celula_valor_um = primeira_linha_com_celula_valor_um
    pecaAtual.celulaValorUm.ultima_linha_com_celula_valor_um    = ultima_linha_com_celula_valor_um

    ' A largura, � f�cil
    pecaAtual.largura_da_peca = ultima_coluna_com_celula_valor_um - primeira_coluna_com_celula_valor_um + 1
    pecaAtual.altura_da_peca = ultima_linha_com_celula_valor_um - primeira_linha_com_celula_valor_um + 1

    ' Agora, reposicionar as coordenadas.
    pecaAtual.posicao.x_Direita = pecaAtual.posicao.x_esquerda + pecaAtual.largura_da_peca - 1
    pecaAtual.posicao.y_Inferior = pecaAtual.posicao.y_superior + pecaAtual.altura_da_peca - 1

END SUB







' Esta fun��o verifica se todas as c�lulas de uma ou mais colunas da pe�a,
' come�ando da coluna 1, se tais c�lulas colidem com as c�lulas respectivas no tabuleiro.
' A quantidade de colunas a serem analisadas � igual a quantidade de deslocamento
' que uma pe�a faz em um �nico movimento.
' Este valor de deslocamento da pe�a � armazenado na vari�vel %PECA_DESLOCAMENTO_HORIZONTAL
' Retorna 1 se colidiu, 0 caso contr�rio.
FUNCTION peca_colidiu_a_esquerda(BYREF tabuleiro() AS celulatabuleiro, BYVAL pecaAtual AS peca) AS LONG
    ' Indica as coordenadas da c�lula na pe�a.
    LOCAL pecaLinha AS LONG, pecaColuna AS LONG

    ' Indica as coordenadas da pe�a no tabuleiro.
    LOCAL xPeca AS LONG, yPeca AS LONG

    ' Indica quantas colunas j� foram analisadas.
    LOCAL colunasAnalisadas AS LONG
    colunasAnalisadas = 0

    ' Indica se a linha tem pelo menos uma c�lula com valor 1.
    LOCAL linhaTemValorUm AS LONG

    ' Como a pe�a ir� deslocar para a esquerda, devemos analisar, todas as colunas
    ' de uma linha, em seguida todas as colunas da pr�xima linha.
    ' Em cada linha haver� uma vari�vel contabilizando as c�lulas j� analisadas,
    ' para melhor detec��o de colis�o, a contabiliza��o come�ar� somente a ocorrer
    ' quando for encontrado pela primeira vez, a c�lula com valor 1, ent�o a partir
    ' da�, qualquer c�lula da mesma linha que ainda n�o foi analisada, ao ser analisada
    ' ser� contabilizada, est� contabiliza��o ser� interrompida, se analisamos
    ' todas as c�lulas da mesma linha ou se a contabiliza��o atingir o mesmo valor
    ' que a constante '%PECA_DESLOCAMENTO_HORIZONTAL'.
    pecaLinha = pecaAtual.celulaValorUm.primeira_linha_com_celula_valor_um
    FOR yPeca = pecaAtual.posicao.y_Superior TO pecaAtual.posicao.y_Inferior STEP 1
        IF yPeca < 1 THEN
            EXIT FOR
        END IF

        ' Come�a da primeira coluna da pe�a.
        pecaColuna = pecaAtual.celulaValorUm.primeira_coluna_com_celula_valor_um
        colunasAnalisadas = 0
        linhaTemValorUm = 0
        FOR xPeca = pecaAtual.posicao.x_Esquerda TO pecaATual.posicao.x_Direita STEP 1
            ' Vamos verificar se h� alguma colis�o.
            IF tabuleiro(yPeca, xPeca).celulaOcupada = 1 AND pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                    FUNCTION = 1
                    EXIT FUNCTION
            END IF

            ' Se encontrarmos a primeira c�lula na linha com valor 1, a contabiliza��o
            ' vai come�ar a ocorrer, para todas as demais c�lulas independente do valor.
            IF pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                linhaTemValorUm = 1
            END IF

            ' Achamos uma c�lula com valor 1, ent�o come�aremos a contagem
            IF linhaTemValorUm = 1 THEN
                INCR colunasAnalisadas
            END IF

            ' Se a contabiliza��o est� ocorrendo e atingirmos a quantidade de c�lulas
            ' suficientes para detectarmos se vai ocorrer uma colis�o ou n�o.
            ' Devemos sair do loop.
            IF colunasAnalisadas = %PECA_DESLOCAMENTO_HORIZONTAL THEN
                EXIT FOR
            END IF

            ' Estamos analisando a pe�a da esquerda pra direita, ent�o, devemos incrementar.
            INCR pecaColuna
        NEXT xpeca

        ' Estamos analisando a pe�a de cima para baixo, devemos incrementar.
        INCR pecaLinha

    NEXT ypeca

END FUNCTION

' Vou usar esta.
FUNCTION peca_colidiu_a_direita(BYREF tabuleiro() AS celulatabuleiro, BYVAL pecaAtual AS peca) AS LONG
    ' Indica as coordenadas da c�lula na pe�a.
    LOCAL pecaLinha AS LONG, pecaColuna AS LONG

    ' Indica as coordenadas da pe�a no tabuleiro.
    LOCAL xPeca AS LONG, yPeca AS LONG

    ' Indica quantas colunas j� foram analisadas.
    LOCAL colunasAnalisadas AS LONG
    colunasAnalisadas = 0

    ' Indica se a linha tem pelo menos uma c�lula com valor 1.
    LOCAL linhaTemValorUm AS LONG

    ' Como a pe�a ir� deslocar para a esquerda, devemos analisar, todas as colunas
    ' de uma linha, em seguida todas as colunas da pr�xima linha.
    ' Em cada linha haver� uma vari�vel contabilizando as c�lulas j� analisadas,
    ' para melhor detec��o de colis�o, a contabiliza��o come�ar� somente a ocorrer
    ' quando for encontrado pela primeira vez, a c�lula com valor 1, ent�o a partir
    ' da�, qualquer c�lula da mesma linha que ainda n�o foi analisada, ao ser analisada
    ' ser� contabilizada, est� contabiliza��o ser� interrompida, se analisamos
    ' todas as c�lulas da mesma linha ou se a contabiliza��o atingir o mesmo valor
    ' que a constante '%PECA_DESLOCAMENTO_HORIZONTAL'.
    pecaLinha = pecaAtual.celulaValorUm.primeira_linha_com_celula_valor_um
    FOR yPeca = pecaAtual.posicao.y_Superior TO pecaAtual.posicao.y_Inferior STEP 1
        IF yPeca < 1 THEN
            EXIT FOR
        END IF

        ' Devemos analisar da direita para a esquerda.
        pecaColuna = pecaAtual.celulaValorUm.ultima_coluna_com_celula_valor_um
        colunasAnalisadas = 0
        linhaTemValorUm = 0
        FOR xPeca = pecaAtual.posicao.x_direita TO pecaATual.posicao.x_esquerda STEP -1
            ' Vamos verificar se h� alguma colis�o.
            IF tabuleiro(yPeca, xPeca).celulaOcupada = 1 AND pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                    FUNCTION = 1
                    EXIT FUNCTION
            END IF

            ' Se encontrarmos a primeira c�lula na linha com valor 1, a contabiliza��o
            ' vai come�ar a ocorrer, para todas as demais c�lulas independente do valor.
            IF pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                linhaTemValorUm = 1
            END IF

            ' Achamos uma c�lula com valor 1, ent�o come�aremos a contagem
            IF linhaTemValorUm = 1 THEN
                INCR colunasAnalisadas
            END IF

            ' Se a contabiliza��o est� ocorrendo e atingirmos a quantidade de c�lulas
            ' suficientes para detectarmos se vai ocorrer uma colis�o ou n�o.
            ' Devemos sair do loop.
            IF colunasAnalisadas = %PECA_DESLOCAMENTO_HORIZONTAL THEN
                EXIT FOR
            END IF

            ' Estamos analisando a pe�a da direita para a esquerda, ent�o, devemos devemos decrementar.
            DECR pecaColuna
        NEXT xpeca

        ' Estamos analisando a pe�a de cima para baixo, devemos incrementar.
        INCR pecaLinha

    NEXT ypeca

END FUNCTION






' Esta fun��o verifica se todas as c�lulas de uma ou mais colunas da pe�a,
' come�ando da coluna 1, se tais c�lulas colidem com as c�lulas respectivas no tabuleiro.
' A quantidade de colunas a serem analisadas � igual a quantidade de deslocamento
' que uma pe�a faz em um �nico movimento.
' Este valor de deslocamento da pe�a � armazenado na vari�vel %PECA_DESLOCAMENTO_HORIZONTAL
' Retorna 1 se colidiu, 0 caso contr�rio.
FUNCTION peca_colidiu_a_direita_antiga(BYREF tabuleiro() AS celulatabuleiro, BYVAL pecaAtual AS peca) AS LONG
    ' Indica as coordenadas da c�lula na pe�a.
    LOCAL pecaLinha AS LONG, pecaColuna AS LONG

    ' Indica as coordenadas da pe�a no tabuleiro.
    LOCAL xPeca AS LONG, yPeca AS LONG

    ' Indica quantas colunas j� foram analisadas.
    LOCAL colunasAnalisadas AS LONG
    colunasAnalisadas = 1

    ' Indica se a coluna tem pelo menos uma c�lula com valor 1.
    ' Isto serve para identificar se est�o comparando a colis�o com
    ' uma c�lula de valor 1.
    LOCAL colunaTemValorUm AS LONG


    pecaColuna = %PECA_CELULAS_POR_COLUNA

    ' Aqui, iremos fazer diferente, iremos percorrer, todas as linhas de uma �nica
    ' colunas em seguida, a pr�xima coluna e assim por diante.
    FOR xPeca = pecaAtual.posicao.x_direita TO pecaATual.posicao.x_esquerda STEP -1

        pecaLinha = 1
        FOR yPeca = pecaAtual.posicao.y_Superior TO pecaAtual.posicao.y_Inferior STEP 1
            ' Vamos verificar se h� colis�o.
            IF yPeca < 1 THEN
                EXIT FOR
            END IF

            ' Vamos verificar se h� alguma colis�o.
            IF tabuleiro(yPeca, xPeca).celulaOcupada = 1 AND pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                    FUNCTION = 1
                    EXIT FUNCTION
            END IF

            ' Vamos verificar se h� pelo menos uma c�lula da coluna com valor 1
            ' Se houver que dizer que pode ocorrer uma colis�o
            ' S� come�aremos a contabilizar uma linha se houve colis�o de houver
            ' pelo menos uma c�lula com valor 1.
            IF pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                colunaTemValorUm = 1
            END IF

            INCR pecaLinha
        NEXT yPeca

        ' Incrementa coluna
        DECR pecaColuna

        ' Incrementa a vari�vel colunasAnalisadas somente se
        ' houve pelo menos uma c�lula com valor 1, pois, se uma coluna
        ' est� vazia n�o haver� colis�o.
        IF colunaTemValorUm = 1 THEN
            INCR colunasAnalisadas
        END IF

        ' Uma pe�a se move 1 ou mais colunas em um �nico movimento.
        ' Ent�o, devemos analisar a mesma quantidade de colunas.
        ' Por exemplo, se ela move duas colunas por vez, ent�o devemos
        ' analisar duas colunas da pe�a, para haver� uma colis�o deve
        ' haver pelo menos uma coluna com uma c�lula valor 1.
        IF colunasAnalisadas > %PECA_DESLOCAMENTO_VERTICAL THEN
            EXIT FOR
        END IF
    NEXT

    FUNCTION = 0
END FUNCTION








'***********************************************************************************************



'***********************************************************************************************
' A fun��o abaixo verifica se a pr�xima linha, � esquerda, a direita, ou abaixo, colidem
' Eu devo verificar a colis�o somente com os cantos, e n�o com a parte interna da pe�a.
' A pe�a desce uma linha por vez, isto que dizer, que devemos, analisar somente a pr�xima linha
' Ou, se o usu�rio deslocar a pe�a pra a esquerda ou para a direita, � um incremento para a coluna
' � esquerda ou a direita.
' Quando implementei inicialmente, a fun��o, estava fazendo a l�gica de colis�o errada, pois
' estava considerando todas as c�lulas.
' Ou seja, quando a pe�a � sorteadas, a c�lula do tabuleiro � definido o valor 1
' se a c�lula da pe�a correspondente � tamb�m 1, isto quer dizer que, se movermos 1 linha ou
' 1 coluna por vez, ao compararmos todas as c�lulas na nova posi��o com as c�lulas j� no tabuleiro
' haver� sempre uma colis�o.
'***********************************************************************************************
FUNCTION peca_colidiu_embaixo(BYREF tabuleiro() AS celulaTabuleiro, BYVAL pecaAtual AS peca) AS LONG

    ' Quando a pe�a se desloca para baixo, devermos verificar
    ' se as c�lulas com valor 1 de cada linha colidem com as c�lulas
    ' respectivas na nova posi��o que tamb�m tem o valor 1.
    ' As pe�as se deslocam 1 ou mais linhas em um �nico movimento,
    ' a quantidade de movimento � igual ao valor da constante '%PECA_DESLOCAMENTO_VERTICAL'
    ' Como a pe�a est� descendo, iremos verificar em cada coluna, as c�lulas
    ' das linhas desta coluna, come�ando da linha inferior e subindo uma linha, por vez,
    ' Iremos analisar come�ando da linha inferior da pe�a e subir uma linha por vez, em uma �nica coluna,
    ' quando a primeira c�lula de valor 1 for localizada, iremos definir
    ' a vari�vel 'colunaTemValorUm' para o valor 1, ent�o, em seguida, continuando
    ' na mesma coluna, continuaremos a an�lise, mas agora, que a vari�vel 'colunaTemValorUm'
    ' tem o valor 1, cada c�lula analisada, independente de ter valor 1 ou n�o
    ' ser� contabilizada, a contabiliza��o ser� interrompida quando atingirmos o valor
    ' igual ao valor definido na constante '%PECA_DESLOCAMENTO_VERTICAL', ou se todas
    ' as c�lulas da primeira coluna terem sido analisadas.
    ' Em seguida, iremos para a pr�xima coluna, resetamos a vari�vel 'colunaTemValorUm' para zero
    ' e em seguida, come�ando a an�lise come�ando da linha inferior para superior.
    ' Tal qual descrito anteriormente.

    ' Vamos fazer assim, iremos analisar da parte inferior para a parte superior
    ' todas as linhas de uma �nica coluna, geralmente da esquerda pra direita
    ' Quando encontrarmos a primeira c�lula que tem o valor 1, iremos contabilizar
    ' como a primeira linha analisada, em seguida, iremos analisar as pr�ximas linhas
    ' e elas ser�o contabilizadas independente se houver 1 ou zero.
    ' As c�lulas das linhas ser� interrompida a an�lise, se a quantidade contabilizada
    ' for igual ao valor da constante '%PECA_DESLOCAMENTO_VERTICAL'

    LOCAL pecaLinha, pecaColuna AS LONG
    LOCAL xPeca AS LONG, yPeca AS LONG

    LOCAL linhasVerificadas AS LONG
    LOCAL colunaTemValorUm AS LONG

    LOCAL linhasAnalisadas AS LONG

    ' Vamos analisar a pe�a da esquerda pra direita, ent�o come�aremos na coluna 1 da pe�a.
    pecaColuna = pecaAtual.celulaValorUm.primeira_coluna_com_celula_valor_um

    FOR xPeca = pecaAtual.posicao.x_Esquerda TO pecaAtual.posicao.X_Direita STEP 1

        ' Antes de entrar no loop, devemos definir que n�o encontramos ainda
        ' um c�lula na coluna com valor 1.
        colunaTemValorUm = 0

        ' Come�a na linha inferior da pe�a
        pecaLinha = pecaAtual.celulaValorUm.ultima_linha_com_celula_valor_um

        ' Iremos entrar no loop abaixo, ele analisa todas as linhas de uma �nica coluna.
        linhasAnalisadas = 0

        ' Iremos analisar da linha inferior para a linha superior, afinal,
        ' a pe�a se desloca para baixo. Ent�o devemos verificar se haver� colis�o
        ' na parte inferior primeiro.
        FOR yPeca = pecaAtual.posicao.y_Inferior TO pecaAtual.posicao.y_Superior STEP -1
            ' A pe�a come�ar� iniciamente fora do tabuleiro, ent�o isto pode ocorrer.
            IF yPeca < 1 THEN
                EXIT FOR
            END IF

            ' Aqui, detectaremos a colis�o, se houver, iremos sair do sub, n�o precisamos
            ' analisar mais c�lulas.
            IF tabuleiro(yPeca, xPeca).celulaOcupada = 1 AND pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                FUNCTION = 1
                EXIT FUNCTION
            END IF

            ' Para detec��o mais eficiente, somente come�aremos a contar a quantidade de linhas
            ' analisadas, se encontrarmos, a primeira c�lula com valor 1, a partir de ent�o, todas
            ' as linhas ser�o analisadas at� atingirmos o valor da vari�vel '%PECA_DESLOCAMENTO_VERTICAL'.
            IF pecaAtual.celulas(pecaLinha, pecaColuna) = 1 THEN
                colunaTemValorUm = 1
            END IF

            IF colunaTemValorUm = 1 THEN
                INCR linhasAnalisadas
            END IF

            ' Se atingirmos o valor da constante %PECA_DESLOCAMENTO_VERTICAL
            ' Ent�o, as c�lulas analisadas s�o suficientes para detectarmos uma colis�o
            IF linhasAnalisadas = %PECA_DESLOCAMENTO_VERTICAL THEN
                EXIT FOR
            END IF

            ' Estamos analisando a linha da pe�a da parte inferior para a superior
            DECR pecaLinha
        NEXT ypeca

        ' Acabamos de analisar todas as linhas de uma �nica coluna, iremos ent�o para a pr�xima coluna
        INCR pecaColuna

    NEXT xpeca
END FUNCTION



'***********************************************************************************************
' Este sub, altera a posi��o, para indicar onde a pe�a deve ser posicionada no tabuleiro
' Este sub, n�o verifica se a c�lulas na nova posi��o colidem com c�lulas j� ocupadas no tabuleiro.
SUB peca_alterar_pra_esquerda(BYREF pecaAtual AS peca)
    IF pecaAtual.posicao.x_Esquerda >= 1 THEN
        pecaAtual.posicao.x_Esquerda -= %PECA_DESLOCAMENTO_HORIZONTAL
        ' Devemos decrementar 1, pois, o �ndice come�a em 1.
        'pecaAtual.posicao.x_Direita = pecaAtual.posicao.x_Esquerda + pecaAtual.largura_da_peca - 1
        pecaAtual.posicao.x_Direita -= %PECA_DESLOCAMENTO_VERTICAL
    END IF
END SUB

'***********************************************************************************************
' Este sub, altera a posi��o, para indicar onde a pe�a deve ser posicionada no tabuleiro
' Este sub, n�o verifica se a c�lulas na nova posi��o colidem com c�lulas j� ocupadas no tabuleiro.
SUB peca_alterar_pra_direita(BYREF pecaAtual AS peca)
    IF pecaAtual.posicao.x_Direita <= %TABULEIRO_COLUNAS THEN
        pecaAtual.posicao.x_Direita += %PECA_DESLOCAMENTO_HORIZONTAL
        ' Devemos incrementar em 1, pois o �ndice basea-se em 1.
        'pecaAtual.posicao.x_Esquerda = pecaAtual.posicao.x_Direita - pecaAtual.largura_da_peca + 1
        pecaAtual.posicao.x_Esquerda += %PECA_DESLOCAMENTO_HORIZONTAL
    END IF
END SUB

' Este sub, altera a posi��o, para indicar onde a pe�a deve ser posicionada no tabuleiro
' Este sub, n�o verifica se a c�lulas na nova posi��o colidem com c�lulas j� ocupadas no tabuleiro.
SUB peca_alterar_pra_baixo(BYREF pecaAtual AS peca)
    IF pecaAtual.posicao.y_Inferior <= %TABULEIRO_LINHAS THEN
        pecaAtual.posicao.y_Inferior += %PECA_DESLOCAMENTO_VERTICAL
        ' Devemos incrementar em 1, pois o �ndice basea-se em 1.
        'pecaAtual.posicao.y_Superior = pecaAtual.posicao.y_Inferior - pecaAtual.altura_da_peca + 1
        pecaAtual.posicao.y_superior += %PECA_DESLOCAMENTO_VERTICAL
    END IF
END SUB

' Este sub, altera a posi��o, para indicar onde a pe�a deve ser posicionada no tabuleiro
' Este sub, n�o verifica se a c�lulas na nova posi��o colidem com c�lulas j� ocupadas no tabuleiro.
SUB peca_alterar_pra_cima(BYREF pecaAtual AS peca)
    IF pecaAtual.posicao.y_Superior > 1 THEN
        pecaAtual.posicao.y_Superior -= %PECA_DESLOCAMENTO_VERTICAL
        ' Devemos incrementar em 1, pois o �ndice basea-se em 1.
        'pecaAtual.posicao.y_Inferior = pecaAtual.posicao.y_Superior + pecaAtual.altura_da_peca - 1
        pecaAtual.posicao.y_inferior -= %PECA_DESLOCAMENTO_VERTICAL
    END IF
END SUB

' Quando a pe�a se desloca, devemos zerar as c�lulas do tabuleiro, onde a pe�a
' anterior estava.
' Pois, se assim n�o o fizermos, a posi��o da c�lula da c�lula da posi��o anterior
' pode coincidir com a posi��o da c�lula da pe�a na nova posi��o.
SUB peca_apagar_rastro_superior(BYREF tabuleiro() AS celulaTabuleiro, BYREF pecaAnterior AS peca)
    ' Indica as coordenadas da c�lula na pe�a.
    LOCAL pecaLinha AS LONG, pecaColuna AS LONG

    ' Indica as coordenadas da pe�a no tabuleiro.
    LOCAL xPeca AS LONG, yPeca AS LONG

    ' Indica a quantidade de linhas j� analisadas
    ' S� iremos analisar a quantidade de linhas igual a quantidade de
    ' linhas que a pe�a se move em um �nico movimento.
    'LOCAL linhasAnalisadas AS LONG
    'linhasAnalisadas = 1

    ' Vamos analisar a linha come�ando da parte superior, afinal, a pe�a est� descendo
    ' e o rastro est� na parte de cima.
    pecaLinha = pecaAnterior.celulaValorUm.primeira_Linha_com_celula_valor_um
    FOR yPeca = pecaAnterior.posicao.y_Superior TO pecaAnterior.posicao.y_inferior STEP 1
        ' S� apagar rastro dentro do tabuleiro, pois, a pe�a come�a fora do tabuleiro.
        IF yPeca < 1 THEN
            EXIT FOR
        END IF

        ' Percorre da esquerda pra direita e s� apaga, se a c�lula do tabuleiro e
        ' a c�lula da pe�a for 1, por que isto, pois pode acontecer de j� existir
        ' c�lula com valor 1, mas vir de outra pe�a que j� foi colocada no tabuleiro.
        pecaColuna = pecaAnterior.celulaValorUm.primeira_coluna_com_celula_valor_um
        FOR xPeca = pecaAnterior.posicao.x_Esquerda TO pecaAnterior.posicao.x_Direita STEP 1
            ' Apga a c�lula.
            IF tabuleiro(yPeca, xPeca).celulaOcupada = 1 AND pecaAnterior.celulas(pecaLinha, pecaColuna) = 1 THEN
                tabuleiro(yPeca, xPeca).celulaOcupada = 0
            END IF

            INCR pecaColuna
        NEXT pecacoluna

        ' Vai pra pr�xima linha da pe�a.
        INCR pecaLinha

    NEXT

END SUB






' Se a altera��o de posi��o da pe�a � v�lida, ent�o devemos mover a pe�a na tabuleiro.
SUB peca_alterar_definitivo(BYREF tabuleiro() AS celulaTabuleiro, BYREF pecaAtual AS peca, BYREF pecaAnterior AS peca)
    ' Vamos definir as c�lulas no tabuleiro onde a pe�a est�.
    ' A vari�vel pecaAnterior armazena as coordenadas, antes da altera��o da posi��o da pe�a
    ' Ent�o, fica f�cil, fazer isto e em seguida, usamos, as novas coordenadas da pe�a atual.

    LOCAL pecaLinha, pecaColuna AS LONG
    LOCAL xPeca AS LONG, yPeca AS LONG


    ' *********************************************************************************
    '   Definir nova posi��o da pe�a no tabuleiro
    pecaLinha = pecaAtual.celulaValorUm.ultima_linha_com_celula_valor_um
    FOR yPeca = pecaAtual.posicao.y_Inferior TO pecaAtual.posicao.y_Superior STEP -1
        ' A pe�a pode est� fora do tabuleiro, se � uma nova pe�a
        ' lan�ada na primeira linha do tabuleiro.
        IF yPeca < 1 THEN
            EXIT FOR
        END IF

        pecaColuna = pecaAtual.celulaValorUm.primeira_coluna_com_celula_valor_um

        FOR xPeca = pecaAtual.posicao.x_Esquerda TO pecaAtual.posicao.x_Direita STEP 1
            ' Se a c�lula da pe�a � 1 e a c�lula de destino � zero, definir a c�lula do
            ' tabuleiro para 1, 1 indica que quando for desenhar o tabuleiro, a c�lula com valor
            ' 1, ser� desenhada.
            IF pecaAtual.celulas(pecaLinha, pecaColuna) = 1 AND tabuleiro(yPeca, xPeca).celulaOcupada = 0 THEN
                tabuleiro(yPeca, xPeca).celulaOcupada = 1
                tabuleiro(yPeca, xPeca).celulaCor = pecaAtual.celulacor
            END IF



            INCR pecaColuna
        NEXT pecacoluna

        ' Decrementa a linha da pe�a, como come�amos da �ltima linha, pela a linha
        ' acima.
        DECR pecaLinha

    NEXT pecalinha



END SUB


'***********************************************************************************************
SUB peca_Copiar(BYREF pecaAnterior AS peca, BYREF pecaAtual AS peca)
    pecaAnterior.posicao.x_Esquerda = pecaAtual.posicao.x_Esquerda
    pecaAnterior.posicao.x_Direita = pecaAtual.posicao.x_Direita
    pecaAnterior.posicao.y_Inferior = pecaAtual.posicao.y_Inferior
    pecaAnterior.posicao.y_Superior = pecaAtual.posicao.y_Superior
    pecaAnterior.celulaCor = pecaAtual.celulacor

    LOCAL pecaLinha, pecaColuna AS LONG
    FOR pecaLinha = 1 TO %PECA_CELULAS_POR_LINHA
        FOR pecaColuna = 1 TO %PECA_CELULAS_POR_COLUNA
            pecaAnterior.celulas(pecalinha, pecaColuna) = pecaAtual.celulas(pecalinha, pecaColuna)
        NEXT pecaColuna
    NEXT pecalinha

END SUB


'***********************************************************************************************


FUNCTION PBMAIN () AS LONG                            '
    LOCAL janelaBloco AS LONG, bitmapbloco AS LONG
    GRAPHIC WINDOW NEW "Tetris v1.0 - Autor F�bio Moura", 0, 0, %JOGO_LARGURA, %JOGO_ALTURA TO janelaBloco
    GRAPHIC BITMAP NEW 500, 500 TO bitmapBloco
    GRAPHIC ATTACH janelaBloco, 0, REDRAW

    ' Cria um tabuleiro com v�rias c�lulas.
    ' A l�gica do nosso jogo Tetris � que cada c�lula ocupada ter� o valor 1 e c�lula n�o ocupada
    ' ter� o valor 0.
    ' Todas as c�lulas da �ltima linha do tabuleiro, ter� o valor 1, pois as pe�as do tabuleiro
    ' deslocam sempre para baixo.
    ' E todas as c�lulas da coluna 0 e todas as c�lulas da �ltima coluna do tabuleiro, ter�o
    ' o valor 1 definido para evitar que a pe�a sai pela esquerda ou direita do tabuleiro, respectivamente.
    DIM  tabuleiro (1 TO %CELULAS_POR_LINHA + 1, 0 TO %CELULAS_POR_COLUNA + 1) AS celulaTabuleiro

    ' Define as coordenadas das c�lulas do tabuleiro.
    TabuleiroProjetarCoordenadas(tabuleiro())
    Tabuleiro_ZerarCelulas(tabuleiro())

    ' Cria as pe�as e a preenche.
    LOCAL pecas() AS peca
    PecasPreencher(pecas())

    LOCAL pecaAtual AS peca, pecaAnterior AS peca

    LOCAL tempoInicial, tempoFinal AS DOUBLE
    tempoInicial = TIMER

    Peca_Sortear(pecas(), pecaAtual)
    pecaAnterior = pecaAtual

    DIM pecaContador AS LONG
    pecaContador = 1

    LOCAL strTextoAnterior AS STRING
    TabuleiroDesenharCelulas(tabuleiro())

    ' Para evitar flicker ao desenhar, s� iremos desenhar dentro do loop
    ' o tabuleiro, se alguma pe�a se deslocou.
    LOCAL pecaSeDeslocou AS LONG
    pecaSeDeslocou = 0

    DO
        ' Eu detectei que se a pe�a est� colindo em algum dos lados
        ' e fico pressionando a tecla, ao desenhar gera um flicker
        ' ent�o pra evitar isto, s� irei desenhar o tabuleiro e as c�lulas
        ' quando houver alguma altera��o no movimento das pe�as.
        ' Ou seja, quando o usu�rio clicar em uma seta de dire��o
        ' ou houve deslocamento para baixo da pe�a.
        IF pecaSeDeslocou = 1 THEN
            pecaSeDeslocou = 0
            TabuleiroDesenharCelulas(tabuleiro())
        END IF


        LOCAL strTexto AS STRING

        strTexto = GRAPHIC$(INKEY$)
        IF ASC(strTexto) = 27 THEN
            EXIT DO
        END IF

        ' Verifica se o usu�rio pressionou a seta de dire�ao para a esquerda.
        ' Se sim, deslocar a pe�a para a esquerda.
        ' Mas devemos nos certificar se a pasta n�o vai colidir.
        IF ASC(MID$(strTexto, 2, 1)) = 75 THEN
            ' Alterar temporariamente a posi��o.
            pecaAnterior = pecaAtual

            ' Para evitar quase coisa, vamos apagar a pe�a atual do tabuleiro
            ' antes de mover.
            peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)

            peca_alterar_pra_esquerda(pecaAtual)

            ' Verifica se h� colis�o a esquerda, se houver reverter.
            IF peca_colidiu_a_esquerda(tabuleiro(), pecaAtual) = 1 THEN
                peca_alterar_pra_direita(pecaAtual)
                'peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
            ELSE
                peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)
                peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
                pecaSeDeslocou = 1
            END IF

        END IF

        ' Verifica se o usu�rio pressionou a seta de dire�ao para a direita.
        IF ASC(MID$(strTexto, 2, 1)) = 77 THEN
            ' Alterar temporariamente a posi��o.
            pecaAnterior = pecaAtual

            ' Para evitar quase bug, vamos apagar a pe�a atual do tabuleiro
            ' antes de mover.
            peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)
            peca_alterar_pra_direita(pecaAtual)

            ' Se houve colis�o a direita, devemos retornar as coordenadas
            ' da pe�a pra a esquerda.
            IF peca_colidiu_embaixo(tabuleiro(), pecaAtual) = 1 THEN
                peca_alterar_pra_esquerda(pecaAtual)
                ' Em seguida, devemos definir a pe�a nesta posi��o no tabuleiro.
            ELSE
                ' Aqui, quer dizer que o deslocamento pra direita � v�lido
                ' Ent�o, devemos apagar o rastro da pe�a na coordenada antiga.
                peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)

                ' Aqui, devemos definir a nova posi��o da pe�a.
                peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
                pecaSeDeslocou = 1
            END IF

        END IF

        ' Se o usu�rio clicar na seta pra cima, gira a pe�a.
        IF ASC(MID$(strTexto, 2, 1)) = 72 THEN
            ' Alterar pe�a, devemos armazenar a pe�a antes de alterar.
            pecaAnterior = pecaAtual

            ' Vamos girar a pe�a, mas antes deve apagar a pe�a atual,
            peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)

            ' Girando, s� precisamos passar a pr�pria pe�a.
            peca_girar(pecaAtual)

            ' Vamos verificar por colis�o
            IF  peca_colidiu_a_esquerda(tabuleiro(), pecaAtual) = 1 OR _
            peca_colidiu_a_direita(tabuleiro(), pecaAtual) = 1 OR _
            peca_colidiu_embaixo(tabuleiro(), pecaAtual) THEN
                ' Simplesmente, copiarmos o anterior.
                pecaAtual = pecaAnterior
            ELSE
                ' N�o colidiu, ent�o definir.
                peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
                pecaSeDeslocou = 1
            END IF
        END IF

        ' Se o usu�rio clica na seta pra baixo, a pe�a vai mais r�pido.
        IF ASC(MID$(strTexto, 2, 1)) = 80 THEN
            tempoInicial = TIMER - 0.5555
        END IF



        IF TIMER - tempoInicial < 0.5555 THEN
            ITERATE DO
        END IF





        ' Toda vez que o loop chega aqui, a pe�a desloca um ou mais linhas
        ' para baixo.
        ' Esta quantidade de linhas � definida pela vari�vel %PECA_DESLOCAMENTO_VERTICAL.


        pecaAnterior = pecaAtual
        peca_alterar_pra_baixo(pecaAtual)
        pecaSeDeslocou = 1

        ' Vamos verificar se h� colis�o, se houver, quer dizer que
        ' a c�lula da pe�a com valor 1, tem na mesma c�lula correspondente
        ' no tabuleiro, um valor 1.
        ' Ent�o, quer dizer,
        IF peca_colidiu_embaixo(tabuleiro(), pecaAtual) = 1 THEN
            INCR pecaContador
            IF pecaContador = 13 THEN
                pecaContador = pecaContador
            END IF

            ' Aqui, iremos reverter a posi��o anterior
            peca_alterar_pra_cima(pecaAtual)

            ' Definir as coordenadas no tabuleiro.
            peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)

            ' Sortear nova pe�a.
            Peca_Sortear(pecas(), pecaAtual)
            'peca_copiar(pecaAnterior, pecaAtual)

            pecaAnterior = pecaAtual

            ' Verificar colis�o, se houver jogo termina
            IF peca_colidiu_embaixo(tabuleiro(), pecaAtual) = 1 THEN
                MSGBOX "GAME OVER", %MB_ICONASTERISK
                END
            END IF


            peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
        ELSE
            peca_apagar_rastro_superior(tabuleiro(), pecaAnterior)
            peca_alterar_definitivo(tabuleiro(), pecaAtual, pecaAnterior)
        END IF

        IF strTexto <> "" THEN

            GRAPHIC COLOR %RGB_YELLOW, %RGB_YELLOW
            GRAPHIC SET POS (10, %JOGO_ALTURA - 50)
            GRAPHIC PRINT strTextoAnterior

            GRAPHIC SET POS (10, %JOGO_ALTURA - 50)
            GRAPHIC COLOR %RGB_RED, %RGB_YELLOW

            SELECT CASE LEN(strTexto)
                CASE 1
                    strTexto = strTexto + ", asc=" + FORMAT$(ASC(strTexto))
                CASE 2
                    strTexto = MID$(strTexto, 2, 1) + ", tecla ext.: " + FORMAT$(ASC(MID$(strTexto, 2, 1)))
            END SELECT

            GRAPHIC PRINT strTexto
            strTextoAnterior = strTexto

            GRAPHIC REDRAW
        END IF
        GRAPHIC REDRAW

        tempoInicial = TIMER

    LOOP

END FUNCTION

' Zera o tabuleiro.
SUB Tabuleiro_ZerarCelulas(BYREF tabuleiro() AS celulaTabuleiro)
    LOCAL linha AS LONG, coluna AS LONG

    FOR linha = 1 TO %TABULEIRO_LINHAS
        FOR coluna = 1 TO %TABULEIRO_COLUNAS
            tabuleiro(linha, coluna).celulaOcupada = 0
        NEXT coluna
    NEXT linha

    ' Pra evitar que a pe�a sa�a na parte inferior do tabuleiro
    FOR coluna = 1 TO %TABULEIRO_COLUNAS + 1
        tabuleiro(%TABULEIRO_LINHAS + 1, coluna).celulaOcupada = 1
    NEXT linha

    ' Pra evitar que a pe�a sa�a pela esquerda.
    FOR linha = 1 TO %TABULEIRO_LINHAS + 1
        tabuleiro(linha, 0).celulaOcupada = 1
        tabuleiro(linha, %TABULEIRO_COLUNAS + 1).celulaOcupada = 1
    NEXT linha



END SUB


'***********************************************************************************************


SUB TabuleiroProjetarCoordenadas(BYREF tabuleiro() AS celulaTabuleiro)
    LOCAL linha, coluna AS LONG

    LOCAL celulaXSuperiorEsquerda AS LONG
    LOCAL celulaYSuperiorEsquerda AS LONG
    LOCAL celulaXInferiorDireita AS LONG
    LOCAL celulaYInferiorDireita AS LONG

  ' Define as coordenadas iniciais.
    celulaXSuperiorEsquerda = %TABULEIRO_ESQUERDA
    celulaYSuperiorEsquerda = %TABULEIRO_TOPO
    celulaXInferiorDireita = celulaXSuperiorEsquerda + %CELULA_LARGURA
    celulaYInferiorDireita = celulaYSuperiorEsquerda + %CELULA_ALTURA

    ' Desenhar c�lulas.
    FOR linha = 1 TO %CELULAS_POR_LINHA

        FOR coluna = 1 TO %CELULAS_POR_COLUNA
            tabuleiro(linha, coluna).X_Superior_Esquerda = celulaXSuperiorEsquerda
            tabuleiro(linha, coluna).Y_Superior_Esquerda = celulaYSuperiorEsquerda
            tabuleiro(linha, coluna).X_Inferior_Direita = celulaXInferiorDireita
            tabuleiro(linha, coluna).Y_Inferior_Direita = celulaYInferiorDireita

            ' Indica onde a pr�xima c�lula na horizontal, ser� desenhada.
            celulaXSuperiorEsquerda = celulaXSuperiorEsquerda + %CELULA_LARGURA + %TABULEIRO_ESPACO_HORIZONTAL_ENTRE_CELULAS
            ' A posi��o y da c�lula superior esquerda e c�lula inferior direita n�o precisa ser alterada.
            celulaXInferiorDireita = celulaXSuperiorEsquerda + %CELULA_LARGURA
        NEXT coluna

        ' Devemos resetar a posi��o x do canto superior da c�lula para a posi��o x
        ' do lado esquerdo do tabuleiro.
        celulaXSuperiorEsquerda = %TABULEIRO_ESQUERDA
        ' e a posi��o x do canto inferior direito da c�lula ser� igual
        ' a soma da posi��o x do lado esquerdo da c�lula + a largura da c�lula
        celulaXInferiorDireita = celulaXSuperiorEsquerda + %CELULA_LARGURA

        ' Como aqui, iremos avan�ar para a pr�xima linha, ent�o, devemos calcular a nova posi��o
        ' y de onde a c�lula estar� posicionada.
        ' H� dois posi��es de y, uma para o canto superior esquerdo e outro para o canto inferior direito.
        ' A nova posi��o y da c�lula ser� igual a atual posi��o de y superior esquerda mais
        ' o espa�amento entre c�lulas na vertical no tabuleiro mais a altura da c�lual
        celulaYSuperiorEsquerda = celulaYSuperiorEsquerda + %CELULA_ALTURA + %TABULEIRO_ESPACO_VERTICAL_ENTRE_CELULAS
        ' A posi��o y da c�lula inferior direita ser� igual a soma da c�lula 'celulaYSuperiorEsquerda' mais
        ' a altura da c�lula.
        celulaYInferiorDireita = celulaYSuperiorEsquerda + %CELULA_ALTURA

    NEXT linha
    GRAPHIC REDRAW
END SUB


'***********************************************************************************************
'   Desenha as c�lulas do tabuleiro, as coordenadas de cada c�lula
' j� foram definidas.
'***********************************************************************************************

SUB TabuleiroDesenharCelulas(BYREF tabuleiro() AS celulaTabuleiro)
    LOCAL linha, coluna AS LONG

    LOCAL celulaXSuperiorEsquerda AS LONG
    LOCAL celulaYSuperiorEsquerda AS LONG
    LOCAL celulaXInferiorDireita AS LONG
    LOCAL celulaYInferiorDireita AS LONG

    ' Desenhar c�lulas.
    FOR linha = 1 TO %CELULAS_POR_LINHA

        FOR coluna = 1 TO %CELULAS_POR_COLUNA
            celulaXSuperiorEsquerda = tabuleiro(linha, coluna).x_superior_esquerda
            celulaYSuperiorEsquerda = tabuleiro(linha, coluna).y_superior_esquerda
            celulaXInferiorDireita = tabuleiro(linha, coluna).x_inferior_direita
            celulaYInferiorDireita = tabuleiro(linha, coluna).y_inferior_direita

            ' Se a c�lula indica que est� preenchida, devemos colocar a cor de preenchimento.
            IF tabuleiro(linha, coluna).celulaOcupada = 1 THEN
                GRAPHIC BOX (celulaXSuperiorEsquerda, celulaYSuperiorEsquerda) - _
                            (celulaXInferiorDireita, celulaYInferiorDireita), 0, _
                            %CELULA_COR_BORDA, tabuleiro(linha, coluna).celulaCor
            ELSE
                GRAPHIC BOX(celulaXSuperiorEsquerda, celulaYSuperiorEsquerda) - _
                                    (celulaXInferiorDireita, celulaYInferiorDireita), , %TABULEIRO_COR_DE_FUNDO, %TABULEIRO_COR_DE_FUNDO
            END IF

        NEXT coluna

    NEXT linha
    GRAPHIC REDRAW
END SUB
