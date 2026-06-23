.data
CHAR_POS:	.half 160,209			# x, y
OLD_CHAR_POS:	.half 160,209			# x, y

.text
# esse setup serve pra desenhar o mapa 1 nos dois frames antes do "jogo" comecar
SETUP:		la a0,map			# carrega o endereco do sprite 'map' em a0
		li a1,0				# x = 0
		li a2,0				# y = 0
		li a3,0				# frame = 0
		call PRINT			# imprime o sprite
		li a3,1				# frame = 1
		call PRINT			# imprime o sprite

GAME_LOOP:	call KEY2			# chama o procedimento de entrada do teclado
		
		xori s0,s0,1			# inverte o valor frame atual (somente o registrador)
		
		la t0,CHAR_POS			# carrega em t0 o endereco de CHAR_POS
		
		la a0,char			# carrega o endereco do sprite 'char' em a0
		lh a1,0(t0)			# carrega a posicao x do personagem em a1
		lh a2,2(t0)			# carrega a posicao y do personagem em a2
		mv a3,s0			# carrega o valor do frame em a3
		call PRINT			# imprime o sprite
		
		li t0,0xFF200604		# carrega em t0 o endereco de troca de frame
		sw s0,0(t0)			# mostra o sprite pronto para o usuario
		
		#####################################
		# Limpeza do "rastro" do personagem #
		#####################################
		la t0,OLD_CHAR_POS		# Carrega endereço de OLD_CHAR_POS
		lh a1,0(t0)			# a1 = X antigo
		lh a2,2(t0)			# a2 = Y antigo
		
		# Descobrir qual tile estava nessa posição antiga para recuperar a textura certa
		srli t3,a2,4			# Y / 16
		li t4,20
		mul t3,t3,t4			# (Y / 16) * 20
		srli t4,a1,4			# X / 16
		add t3,t3,t4			# Índice na matriz
		
		la t4,MATRIZ_MAPA1
		add t4,t4,t3
		lbu t5,0(t4)			# t5 = ID da textura antiga
		
		# --- SELEÇÃO DO SPRITE CONFORME O ID ---
		li t6,0
		beq t5,t6,TXT_PISO1		# Se for 0, desenha o Piso 1
		li t6,2
		beq t5,t6,TXT_ESCADA		# Se for 2, desenha a Escada
		li t6,3
		beq t5,t6,TXT_PISO2		# Se for 3, desenha o Piso 2
		
		# Default caso dê algo errado (Garante que não quebre)
		la a0,marrom			
		j DESENHA_RASTRO

TXT_PISO1:	la a0,marrom			# Seu sprite atual de piso
		j DESENHA_RASTRO

TXT_ESCADA:	la a0,vermelhoescuro		# Troque pelo nome do label do sprite da escada
		j DESENHA_RASTRO

TXT_PISO2:	la a0,vermelhoclaro		# Troque pelo nome do label do sprite do piso 2
		j DESENHA_RASTRO

DESENHA_RASTRO:
		mv a3,s0			# Carrega o frame atual
		xori a3,a3,1			# Inverte a3
		call PRINT			# Desenha a textura correta no rastro

		j GAME_LOOP			# continua o loop

KEY2:		li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		# mascara o bit menos significativo
   		beq t0,zero,FIM   	   	# Se nao ha tecla pressionada entao vai para FIM
  		lw t2,4(t1)  			# le o valor da tecla tecla
		
		li t0,'w'
		beq t2,t0,CHAR_CIMA		# se tecla pressionada for 'w', chama CHAR_CIMA
		
		li t0,'a'
		beq t2,t0,CHAR_ESQ		# se tecla pressionada for 'a', chama CHAR_CIMA
		
		li t0,'s'
		beq t2,t0,CHAR_BAIXO		# se tecla pressionada for 's', chama CHAR_CIMA
		
		li t0,'d'
		beq t2,t0,CHAR_DIR		# se tecla pressionada for 'd', chama CHAR_CIMA
	
FIM:		ret				# retorna

CHAR_ESQ:	la t0,CHAR_POS			# t0 = endereço de CHAR_POS
		lh t1,0(t0)			# t1 = X atual
		lh t2,2(t0)			# t2 = Y atual
		
		addi t1,t1,-16			# t1 = Próximo X (tentativa de mover para a esquerda)
		
		# --- CÁLCULO DO ÍNDICE DA MATRIZ ---
		# formula: index = (y / 16) * 20 + (x / 16)
		srli t3,t2,4			# t3 = Y / 16
		li t4,20
		mul t3,t3,t4			# t3 = (Y / 16) * 20
		srli t4,t1,4			# t4 = Próximo X / 16
		add t3,t3,t4			# t3 = índice final na matriz
		
		la t4,MATRIZ_MAPA1		# t4 = endereço base da matriz
		add t4,t4,t3			# t4 = endereço do byte específico
		lbu t5,0(t4)			# t5 = valor do tile na matriz
		
		# --- VERIFICAÇÃO DE COLISÃO ---
		li t6,10			# Nosso limite de colisão
		bge t5,t6,FIM_MOVE_ESQ		# Se for >= 10, é parede! Cancela o movimento.
		
		# --- SE NÃO COLISEU, EXECUTA O MOVIMENTO ---
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			# Salva a posição antiga (X e Y juntos)
		
		lh t1,0(t0)			# Carrega X atual novamente
		addi t1,t1,-16			# Aplica o movimento
		sh t1,0(t0)			# Salva no CHAR_POS
		
FIM_MOVE_ESQ:	ret

CHAR_DIR:	la t0,CHAR_POS			# t0 = endereço de CHAR_POS
		lh t1,0(t0)			# t1 = X atual
		lh t2,2(t0)			# t2 = Y atual
		
		addi t1,t1,16			# t1 = Próximo X (tentativa de ir para a direita)
		
		# --- CÁLCULO DO ÍNDICE DA MATRIZ ---
		srli t3,t2,4			# t3 = Y / 16
		li t4,20
		mul t3,t3,t4			# t3 = (Y / 16) * 20
		srli t4,t1,4			# t4 = Próximo X / 16
		add t3,t3,t4			# t3 = índice final na matriz
		
		la t4,MATRIZ_MAPA1		# t4 = endereço base da matriz
		add t4,t4,t3			# t4 = endereço do byte específico
		lbu t5,0(t4)			# t5 = valor do tile na matriz
		
		# --- VERIFICAÇÃO DE COLISÃO ---
		li t6,10			
		bge t5,t6,FIM_MOVE_DIR		# Se for >= 10 (parede/cerca), cancela.
		
		# --- EXECUTA O MOVIMENTO SE VÁLIDO ---
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			# Salva a posição antiga
		
		lh t1,0(t0)			
		addi t1,t1,16			
		sh t1,0(t0)			# Atualiza o X para a nova posição
		
FIM_MOVE_DIR:	ret

CHAR_CIMA:	la t0,CHAR_POS			# t0 = endereço de CHAR_POS
		lh t1,0(t0)			# t1 = X atual
		lh t2,2(t0)			# t2 = Y atual
		
		addi t2,t2,-16			# t2 = Próximo Y (tentativa de subir)
		
		# --- CÁLCULO DO ÍNDICE DA MATRIZ ---
		srli t3,t2,4			# t3 = Próximo Y / 16
		li t4,20
		mul t3,t3,t4			# t3 = (Próximo Y / 16) * 20
		srli t4,t1,4			# t4 = X / 16
		add t3,t3,t4			# t3 = índice final na matriz
		
		la t4,MATRIZ_MAPA1		
		add t4,t4,t3			
		lbu t5,0(t4)			
		
		# --- VERIFICAÇÃO DE COLISÃO ---
		li t6,10			
		bge t5,t6,FIM_MOVE_CIMA		# Se for >= 10, cancela.
		
		# --- EXECUTA O MOVIMENTO SE VÁLIDO ---
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			# Salva a posição antiga
		
		lh t2,2(t0)			# Carrega o Y atual novamente
		addi t2,t2,-16			
		sh t2,2(t0)			# Atualiza o Y para a nova posição
		
FIM_MOVE_CIMA:	ret

CHAR_BAIXO:	la t0,CHAR_POS			# t0 = endereço de CHAR_POS
		lh t1,0(t0)			# t1 = X atual
		lh t2,2(t0)			# t2 = Y atual
		
		addi t2,t2,16			# t2 = Próximo Y (tentativa de descer)
		
		# --- CÁLCULO DO ÍNDICE DA MATRIZ ---
		srli t3,t2,4			# t3 = Próximo Y / 16
		li t4,20
		mul t3,t3,t4			# t3 = (Próximo Y / 16) * 20
		srli t4,t1,4			# t4 = X / 16
		add t3,t3,t4			# t3 = índice final na matriz
		
		la t4,MATRIZ_MAPA1		
		add t4,t4,t3			
		lbu t5,0(t4)			
		
		# --- VERIFICAÇÃO DE COLISÃO ---
		li t6,10			
		bge t5,t6,FIM_MOVE_BAIXO	# Se for >= 10, cancela.
		
		# --- EXECUTA O MOVIMENTO SE VÁLIDO ---
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			# Salva a posição antiga
		
		lh t2,2(t0)			# Carrega o Y atual novamente
		addi t2,t2,16			
		sh t2,2(t0)			# Atualiza o Y para a nova posição
		
FIM_MOVE_BAIXO:	ret

#################################################
#	a0 = endereÃ§o imagem			#
#	a1 = x					#
#	a2 = y					#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereco do bitmap display		#
#	t1 = endereco da imagem			#
#	t2 = contador de linha			#
# 	t3 = contador de coluna			#
#	t4 = largura				#
#	t5 = altura				#
#################################################

PRINT:		li t0,0xFF0			# carrega 0xFF0 em t0
		add t0,t0,a3			# adiciona o frame ao FF0 (se o frame for 1 vira FF1, se for 0 fica FF0)
		slli t0,t0,20			# shift de 20 bits pra esquerda (0xFF0 vira 0xFF000000, 0xFF1 vira 0xFF100000)
		
		add t0,t0,a1			# adiciona x ao t0
		
		li t1,320			# t1 = 320
		mul t1,t1,a2			# t1 = 320 * y
		add t0,t0,t1			# adiciona t1 ao t0
		
		addi t1,a0,8			# t1 = a0 + 8
		
		mv t2,zero			# zera t2
		mv t3,zero			# zera t3
		
		lw t4,0(a0)			# carrega a largura em t4
		lw t5,4(a0)			# carrega a altura em t5
		
PRINT_LINHA:	lw t6,0(t1)			# carrega em t6 uma word (4 pixeis) da imagem
		sw t6,0(t0)			# imprime no bitmap a word (4 pixeis) da imagem
		
		addi t0,t0,4			# incrementa endereco do bitmap
		addi t1,t1,4			# incrementa endereco da imagem
		
		addi t3,t3,4			# incrementa contador de coluna
		blt t3,t4,PRINT_LINHA		# se contador da coluna < largura, continue imprimindo

		addi t0,t0,320			# t0 += 320
		sub t0,t0,t4			# t0 -= largura da imagem
		# ^ isso serve pra "pular" de linha no bitmap display
		
		mv t3,zero			# zera t3 (contador de coluna)
		addi t2,t2,1			# incrementa contador de linha
		bgt t5,t2,PRINT_LINHA		# se altura > contador de linha, continue imprimindo
		
		ret				# retorna

.data
.include "mapas_e_matrizes/matriz_mapa1.s"
.include "mapas_e_matrizes/mapa1.s"
.include "sprites/char.s"
.include "texturas/marrom.s"
.include "texturas/vermelhoescuro.s"
.include "texturas/vermelhoclaro.s"

