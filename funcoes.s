# =================================================================
# funcoes.s - Todas as subrotinas do jogo reunidas
# =================================================================
.text
# =================================================================
# SISTEMA DE TECLADO E ENTRADA (JOGADOR)
# =================================================================
WAIT_SPACE:	li t1, 0xFF200000        

WAIT_SPACE_LOOP:
	        lw t0, 0(t1)              # Le o bit de controle
	        andi t0, t0, 0x0001     
	        beq t0, zero, WAIT_SPACE_LOOP # Se nao ha tecla, trava a tela
	        
	        lw t2, 4(t1)              # Le o valor da tecla pressionada
	        li t0, 32                 # Codigo ASCII da barra de Espa�o
	        bne t2, t0, WAIT_SPACE_LOOP # Se pressionou outra tecla, ignora e continua esperando
	        
	        ret                       # Se for Espaco
	    	ret

KEY2:		li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw t0,0(t1)			# Le bit de Controle Teclado
		andi t0,t0,0x0001		
		beq t0,zero,FIM_KEY		# Se nao ha tecla pressionada entao vai para FIM_KEY
		lw t2,4(t1) 			# le o valor da tecla tecla
		
		li t0,'w'
		beq t2,t0,CHAR_CIMA		# se 'w', sobe
		
		li t0,'a'
		beq t2,t0,CHAR_ESQ		# se 'a', esquerda
		
		li t0,'s'
		beq t2,t0,CHAR_BAIXO		# se 's', desce
		
		li t0,'d'
		beq t2,t0,CHAR_DIR		# se 'd', direita
		
		li t0, 'l'			#se 'l', atira
		beq t2, t0, ATIRA
	
FIM_KEY:	ret				# retorna para o main

ATIRA:		
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		bne t1, zero, FIM_KEY		# Se ja tem um tiro na tela, nao faz nada
		
		# Ativa o tiro
		li t1, 1
		sw t1, 0(t0)			# BULLET_ACTIVE = 1
		
		# Copia a direcao atual do personagem para o tiro
		la t0, CHAR_LOOK_DIR
		lw t1, 0(t0)
		la t2, BULLET_DIR
		sw t1, 0(t2)			# BULLET_DIR = CHAR_DIR
		
		# Faz o tiro nascer exatamente onde o personagem esta
		la t0, CHAR_POS
		lw t1, 0(t0)			# Carrega X e Y do player juntos
		la t2, BULLET_POS
		sw t1, 0(t2)			# Define a posicaoo inicial do tiro
		
		j FIM_KEY

# =================================================================
# MOVIMENTACAO E COLISAO DO JOGADOR
# =================================================================
CHAR_ESQ:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t1,t1,-16			
		
		srli t3,t2,4			# Y / 16
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			# Proximo X / 16
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le A matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_ESQ	
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t1,0(t0)			
		addi t1,t1,-16			
		sh t1,0(t0)
		
		li t1, 3
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_ESQ:	ret

CHAR_DIR:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t1,t1,16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_DIR		
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t1,0(t0)			
		addi t1,t1,16			
		sh t1,0(t0)
		
		li t1, 4
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_DIR:	ret

CHAR_CIMA:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t2,t2,-16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_CIMA		
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t2,2(t0)			
		addi t2,t2,-16			
		sh t2,2(t0)
		
		li t1, 1
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_CIMA:	ret

CHAR_BAIXO:	la t0,CHAR_POS			
		lh t1,0(t0)			
		lh t2,2(t0)			
		addi t2,t2,16			
		
		srli t3,t2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,t1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX		
		lw t4, 0(t4)			# Le a matriz da fase ativa
		add t4, t4, t3			
		lbu t5, 0(t4)			# t5 = Bloco atual
		
		beq t5, zero, FIM_MOVE_BAIXO	
		
		la t1,OLD_CHAR_POS		
		lw t2,0(t0)			
		sw t2,0(t1)			
		
		lh t2,2(t0)			
		addi t2,t2,16			
		sh t2,2(t0)
		
		li t1, 2
		la t2, CHAR_LOOK_DIR
		sw t1, 0(t2)			
FIM_MOVE_BAIXO:	ret

# =================================================================
# MOVIMENTA��O DOs INIMIGOS
# =================================================================
ATUALIZA_INIMIGO:
		# Verifica se o inimigo esta ativo
		lw t1, 0(a2)
		li t2, 1
		bne t1, t2, FIM_ATUALIZA_INIMIGO
		
		# Carrega, incrementa e salva o contador espec�fico passado em a4
		lw t1, 0(a4)
		addi t1, t1, 1
		sw t1, 0(a4)			

		la t2, ENEMY_SPEED
		lw t2, 0(t2)
		blt t1, t2, EXECUTA_DESENHO_ENEMY # Se nao deu tempo, pula o movimento
		
		# Se chegou aqui, deu tempo de fazer o movimento
		sw zero, 0(a4)			

CONTINUA_IA:
		# Salva os argumentos na pilha antes do processamento
		addi sp, sp, -24
		sw ra, 0(sp)
		sw a0, 4(sp)
		sw a1, 8(sp)
		sw a2, 12(sp)
		sw a3, 16(sp)
		sw a4, 20(sp)

		lh t3, 0(a0)			# t3 = Inimigo X
		lh t4, 2(a0)			# t4 = Inimigo Y
		
		lw t2, 0(a0)			
		sw t2, 0(a1)			
		
		la t1, CHAR_POS
		lh t5, 0(t1)			# t5 = Player X
		lh t6, 2(t1)			# t6 = Player Y
		
		beq t3, t5, IA_Y		
		blt t3, t5, IA_DIR		
IA_ESQ:		addi t3, t3, -16
		j CHK_COLISAO_ENEMY
IA_DIR:		addi t3, t3, 16
		j CHK_COLISAO_ENEMY

IA_Y:		beq t4, t6, RESTAURA_PILHA_ENEMY	
		blt t4, t6, IA_BAIXO
IA_CIMA:	addi t4, t4, -16
		j CHK_COLISAO_ENEMY
IA_BAIXO:	addi t4, t4, 16

CHK_COLISAO_ENEMY:
		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, RESTAURA_PILHA_ENEMY

SUCESSO_MOVE_ENEMY:
		lw a0, 4(sp)
		sh t3, 0(a0)
		sh t4, 2(a0)

RESTAURA_PILHA_ENEMY:
		lw ra, 0(sp)
		lw a0, 4(sp)
		lw a1, 8(sp)
		lw a2, 12(sp)
		lw a3, 16(sp)
		lw a4, 20(sp)
		addi sp, sp, 24

EXECUTA_DESENHO_ENEMY:
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la t1, ENEMY_A_POS
		beq a0, t1, USA_SPRITE_A

USA_SPRITE_B:
		mv t0, a0 
		la a0, ghost1
		j PRONTO_PARA_DESENHAR

USA_SPRITE_A:
		mv t0, a0
		la a0, alien1		

PRONTO_PARA_DESENHAR:
		lh a1, 0(t0)			
		lh a2, 2(t0)			
		call PRINT	
		
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_ATUALIZA_INIMIGO:
		ret

# =================================================================
# LIMPEZA DE RASTRO (PLAYER E INIMIGOS)
# =================================================================
LIMPA_RASTRO_PLAYER:
		# Verifica se o player acabou de renascer (necessita de limpeza dupla da morte)
		la t0, PLAYER_RESPAWN_COUNT
		lw t1, 0(t0)
		blez t1, LIMPA_RASTRO_NORMAL_PLAYER	# Se for 0, segue o rastro normal de movimento
		
		#CASO ESPECIAL: LIMPANDO O "FANTASMA" DA MORTE
		addi t1, t1, -1
		sw t1, 0(t0)				# Decrementa o contador (2 -> 1 -> 0)
		
		la t0, PLAYER_DEATH_POS			# Forca a limpeza na coordenada da morte
		lh a1, 0(t0)
		lh a2, 2(t0)
		j EXECUTA_LIMPEZA_PLAYER

LIMPA_RASTRO_NORMAL_PLAYER:
		# Limpeza padrao usada durante o jogo caminhando normal
		la t0, OLD_CHAR_POS		
		lh a1, 0(t0)			
		lh a2, 2(t0)			

EXECUTA_LIMPEZA_PLAYER:
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA			# Redesenha o chao do mapa
		lw ra, 0(sp)
		addi sp, sp, 4
		ret		

# =================================================================
# LIMPA RASTRO INIMIGO
# Inputs:
#   a0 = Endere�o de ENEMY_X_OLD_POS (ex: la a0, ENEMY_A_OLD_POS)
#   a1 = Endere�o de ENEMY_X_ACTIVE  (ex: la a1, ENEMY_A_ACTIVE)
# =================================================================
LIMPA_RASTRO_INIMIGO:
		# Verifica se o inimigo acabou de atacar o player
		la t0, ENEMY_RESPAWN_COUNT
		lw t1, 0(t0)
		blez t1, LOGICA_PADRAO_ENEMY	# Se for 0, segue o jogo normal
		
		# CASO ESPECIAL DE ATAQUE
		addi t1, t1, -1
		sw t1, 0(t0)				
		
		addi sp, sp, -4
		sw ra, 0(sp)		
		
		la t0, ENEMY_DEATH_POS			
		lh a1, 0(t0)
		lh a2, 2(t0)
		call ENCONTRA_TEXTURA			
		
		la t0, ENEMY_PENULTIMA_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		call ENCONTRA_TEXTURA			
		
		lw ra, 0(sp)			
		addi sp, sp, 4			
		ret					

LOGICA_PADRAO_ENEMY:
		# Le o estado de atividade DESTE inimigo espec�fico
		lw t1, 0(a1)
		beq t1, zero, FIM_RASTRO_ENEMY	# Se for 0, nao limpa nada
		
		# Salva na pilha os registradores de argumento que vamos precisar depois
		addi sp, sp, -12
		sw ra, 0(sp)
		sw a1, 4(sp)        # Guarda o endere�o do ACTIVE
		sw t1, 8(sp)        # Guarda o valor atual do ACTIVE

		# Carrega a coordenada antiga DESTE inimigo espec�fico (usando a0)
		lh a1, 0(a0)			
		lh a2, 2(a0)			

		call ENCONTRA_TEXTURA		# Redesenha o chao na posicao antiga
		
		# Recupera os dados da pilha
		lw ra, 0(sp)
		lw a1, 4(sp)        # Endereco do ACTIVE deste inimigo
		lw t1, 8(sp)        # Valor do ACTIVE deste inimigo
		addi sp, sp, 12

		#MAQUINA DE ESTADOS DO RASTRO DE MORTE DESTE INIMIGO
		li t2, 2
		beq t1, t2, ENEMY_VA_PARA_3	
		li t2, 3
		beq t1, t2, ENEMY_VA_PARA_0	
		
		j FIM_RASTRO_ENEMY

ENEMY_VA_PARA_3:
		li t3, 3
		sw t3, 0(a1)			# Atualiza o ACTIVE deste inimigo para 3
		j FIM_RASTRO_ENEMY

ENEMY_VA_PARA_0:
		sw zero, 0(a1)			# Desativa este inimigo de vez (0) apos limpar todos os frames

FIM_RASTRO_ENEMY:
		ret
		
# =================================================================
# FUNCAO QUE DEFINE A TEXTURA A SUBSTITUIR APOS O PLAYER SE MOVER
# =================================================================	
ENCONTRA_TEXTURA:
		srli t3,a2,4			
		li t4,20
		mul t3,t3,t4			
		srli t4,a1,4			
		add t3,t3,t4			
		
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)
		add t4, t4, t3
		lbu t5, 0(t4)			# t5 = Codigo do bloco na matriz
		
		# Checa qual fase esta ativa para escolher o grupo de texturas
		la t4, CURRENT_LEVEL
		lw t4, 0(t4)
		li t6, 2
		beq t4, t6, TEXTURAS_FASE2
		li t6, 3
		beq t4, t6, TEXTURAS_FASE3
		
TEXTURAS_FASE1:
		# Aponta para as rotinas de desenho
		li t6, 12
		beq t5, t6, TXT_M1_CAMINHO_ESQ
		li t6, 13
		beq t5, t6, TXT_M1_CAMINHO_DIR
		li t6, 14
		beq t5, t6, TXT_M1_ESCADA_ESQ
		li t6, 15
		beq t5, t6, TXT_M1_ESCADA_DIR

		la a0, MAPA1
		j DESENHA_RASTRO

TXT_M1_CAMINHO_ESQ:
		la a0, cenario1_pedra_esquerda    # Sprite metade pedra (Esquerda)
		j DESENHA_RASTRO
TXT_M1_CAMINHO_DIR:
		la a0, cenario1_pedra_direita     # Sprite metade pedra (Direita)
		j DESENHA_RASTRO
TXT_M1_ESCADA_ESQ:
		la a0, cenario1_escada_esquerda   # Sprite do degrau esquerdo
		j DESENHA_RASTRO
TXT_M1_ESCADA_DIR:
		la a0, cenario1_escada_direita    # Sprite do degrau direito
		j DESENHA_RASTRO
		
TEXTURAS_FASE2:
		li t6, 21
		beq t5, t6, TXT_M2_PISO
		
		la a0, cenario2_piso
		j DESENHA_RASTRO

TXT_M2_PISO:        la a0, cenario2_piso		
                      j DESENHA_RASTRO

TEXTURAS_FASE3:
		la a0, cenario3_piso    
		j DESENHA_RASTRO

DESENHA_RASTRO:
		addi sp, sp, -4
		sw ra, 0(sp)
		
		mv a3,s0			
		xori a3,a3,1			
		call PRINT			

		lw ra, 0(sp)
		addi sp, sp, 4
		ret	

# =================================================================
# MECANICA DO TIRO
# =================================================================
MOVE_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_MOVE_BULLET	# So calcula movimento se o tiro estiver ativo (1)
		
		# Salva a posi��o atual como ANTIGA antes de aplicar a velocidade
		la t0, BULLET_POS
		lw t1, 0(t0)
		la t2, OLD_BULLET_POS
		sw t1, 0(t2)

		lh t3, 0(t0)			# t3 = Projetil X
		lh t4, 2(t0)			# t4 = Projetil Y

		# Direcao do tiro
		la t0, BULLET_DIR
		lw t1, 0(t0)

		li t2, 1
		beq t1, t2, B_CIMA
		li t2, 2
		beq t1, t2, B_BAIXO
		li t2, 3
		beq t1, t2, B_ESQ
		li t2, 4
		beq t1, t2, B_DIR
		j FIM_MOVE_BULLET

B_CIMA:		addi t4, t4, -16
		j CHK_B_COLISAO
B_BAIXO:	addi t4, t4, 16
		j CHK_B_COLISAO
B_ESQ:		addi t3, t3, -16
		j CHK_B_COLISAO
B_DIR:		addi t3, t3, 16

# -----------------------------------------------------------------
#  DETECCAO DE IMPACTO
# -----------------------------------------------------------------
CHK_B_COLISAO: 					
		#TESTA COLIS�O COM INIMIGO A
		la t0, ENEMY_A_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, CHK_BULLET_INIMIGO_B # Se o A n�o esta ativo, testa o B
		
		la t0, ENEMY_A_POS
		lh t1, 0(t0)			# t1 = Inimigo A X
		lh t2, 2(t0)			# t2 = Inimigo A Y
		
		bne t3, t1, CHK_BULLET_INIMIGO_B # Se X n�o bateu, testa o B
		bne t4, t2, CHK_BULLET_INIMIGO_B # Se Y n�o bateu, testa o B
		
		# HOUVE IMPACTO NO INIMIGO A
		la a0, ENEMY_A_POS
		la a1, ENEMY_A_OLD_POS
		la a2, ENEMY_A_ACTIVE
		la a3, ENEMY_A_LIVES
		j EXECUTA_DANO_INIMIGO

CHK_BULLET_INIMIGO_B:
		# TESTA COLIS�O COM INIMIGO B
		la t0, ENEMY_B_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, CHK_PAREDE_BULLET	# Se o B tamb�m n�o esta ativo, pula pro cenario
		
		la t0, ENEMY_B_POS
		lh t1, 0(t0)			# t1 = Inimigo B X
		lh t2, 2(t0)			# t2 = Inimigo B Y
		
		bne t3, t1, CHK_PAREDE_BULLET	
		bne t4, t2, CHK_PAREDE_BULLET	
		
		# HOUVE IMPACTO NO INIMIGO B!
		la a0, ENEMY_B_POS
		la a1, ENEMY_B_OLD_POS
		la a2, ENEMY_B_ACTIVE
		la a3, ENEMY_B_LIVES

EXECUTA_DANO_INIMIGO:
		# Desativa o tiro
		la t0, BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)
		
		#EFEITO SONORO DO INIMIGO TOMANDO DANO
		addi sp, sp, -20
		sw ra, 0(sp)
		sw a0, 4(sp)
		sw a1, 8(sp)
		sw a2, 12(sp)
		sw a3, 16(sp)
		
		li a0, 45         # Nota grave (impacto)
		li a1, 250        # Duração de 250ms
		li a2, 114        # Instrumento 114 (Steel Drum, bom para impacto)
		li a3, 127        # Volume no máximo
		call TOCA_EFEITO
		
		lw ra, 0(sp)
		lw a0, 4(sp)
		lw a1, 8(sp)
		lw a2, 12(sp)
		lw a3, 16(sp)
		addi sp, sp, 20
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call RESPAWN_INIMIGO
		lw ra, 0(sp)
		addi sp, sp, 4
		
		j FIM_MOVE_BULLET		# Encerra o frame do tiro
# -----------------------------------------------------------------
#  COLISAO COM CENARIO E PAREDES
# -----------------------------------------------------------------
CHK_PAREDE_BULLET:
		blt t3, zero, B_MORRE
		li t1, 320
		bge t3, t1, B_MORRE
		blt t4, zero, B_MORRE
		li t1, 240
		bge t4, t1, B_MORRE

		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, B_MORRE
		li t6, 19
		beq t1, t6, B_MORRE

SUCESSO_BULLET:
		la t0, BULLET_POS
		sh t3, 0(t0)
		sh t4, 2(t0)
		j FIM_MOVE_BULLET

B_MORRE:
		la t0, BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)

FIM_MOVE_BULLET:
		ret
		
		
# =================================================================
# RESPAWN_INIMIGO
# Entradas passadas pelo impacto do tiro:
#   a0 = Endere�o de ENEMY_X_POS
#   a1 = Endere�o de ENEMY_X_OLD_POS
#   a2 = Endere�o de ENEMY_X_ACTIVE
#   a3 = Endere�o de ENEMY_X_LIVES
# =================================================================
RESPAWN_INIMIGO:
		# 1. Soma +1 no contador de mortes da Fase 2
		la t0, TOTAL_DEFEATED
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)

		# 2. Reduz 1 vida deste inimigo especifico
		lw t1, 0(a3)			# t1 = vidas restantes
		addi t1, t1, -1
		sw t1, 0(a3)			# Atualiza na memoria
		
		# Forca o rastro antigo a ser onde ele acabou de ser baleado (para limpar frame)
		lw t2, 0(a0)
		sw t2, 0(a1)

		# Se as vidas DESTE inimigo zeraram, ele morre em definitivo
		bnez t1, FAZ_TELETRANSPORTE_RESPAWN
		
		# MORTE DEFINITIVA
		li t2, 2
		sw t2, 0(a2)			# Joga ACTIVE para estado 2
		ret

		# RENASCIMENTO EM NOVO PONTO
FAZ_TELETRANSPORTE_RESPAWN:
		# Descobre qual e o pr�ximo ponto de spawn da lista (0, 1, 2 ou 3)
		la t0, SPAWN_INDEX
		lw t1, 0(t0)			# t1 = �ndice atual (0 a 3)
		
		# Calcula o deslocamento na tabela SPAWN_POINTS (Cada ponto tem 4 bytes: .half X, Y)
		slli t2, t1, 2			# t2 = �ndice * 4
		la t3, SPAWN_POINTS
		add t3, t3, t2			# t3 = Endereco exato do par X,Y escolhido
		
		# Carrega as novas coordenadas de spawn
		lh t4, 0(t3)			# Novo X
		lh t5, 2(t3)			# Novo Y
		
		# Aplica o teletransporte instant�neo no inimigo!
		sh t4, 0(a0)
		sh t5, 2(a0)
		
		# Atualiza o SPAWN_INDEX para que o PR�XIMO inimigo que morrer nas�a em outro lugar
		addi t1, t1, 1			# Pr�ximo �ndice
		li t2, 4
		blt t1, t2, SALVA_INDEX
		li t1, 0			# Se passou de 3, volta para o ponto 0 (Loop circular)
SALVA_INDEX:
		sw t1, 0(t0)
		ret	

# DESENHO DO TIRO
DESENHA_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DRAW_BULLET	# S� desenha se estiver puramente ativo (1)

		la t0, BULLET_POS
		la a0, terco			
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0			# Passa o frame atual
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call PRINT			
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_DRAW_BULLET:
		ret

# LIMPEZA DE RASTRO DO TIRO
LIMPA_RASTRO_BULLET:
		la t0, BULLET_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_RASTRO_BULLET	# Se for 0 (Totalmente inativo), n�o faz nada
		
		addi sp, sp, -4
		sw t1, 0(sp)

		# Prepara os par�metros usando a posi��o antiga do tiro
		la t0, OLD_BULLET_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA		# Executa o mapeador do cen�rio compartilhado
		lw ra, 0(sp)
		addi sp, sp, 4

		lw t1, 0(sp)
		addi sp, sp, 4

		# SISTEMA DE LIMPEZA DUPLA
		li t2, 2
		beq t1, t2, BULLET_VA_PARA_3
		li t2, 3
		beq t1, t2, BULLET_VA_PARA_0
		
		j FIM_RASTRO_BULLET

BULLET_VA_PARA_3:
		la t0, BULLET_ACTIVE
		li t1, 3
		sw t1, 0(t0)			# Configura para limpar o segundo frame do tiro
		j FIM_RASTRO_BULLET

BULLET_VA_PARA_0:
		la t0, BULLET_ACTIVE
		sw zero, 0(t0)			# Tiro completamente limpo e pronto para novo disparo

FIM_RASTRO_BULLET:
		ret

# =================================================================
# RENDERIZADOR DE SPRITES (PRINT)
# =================================================================
PRINT:		li t0,0xFF0			
		add t0,t0,a3			
		slli t0,t0,20			
		add t0,t0,a1			
		
		li t1,320			
		mul t1,t1,a2			
		add t0,t0,t1			
		addi t1,a0,8			
		
		mv t2,zero			
		mv t3,zero			
		lw t4,0(a0)			
		lw t5,4(a0)			
		
PRINT_LINHA:	lw t6,0(t1)			
		sw t6,0(t0)			
		
		addi t0,t0,4			
		addi t1,t1,4			
		addi t3,t3,4			
		blt t3,t4,PRINT_LINHA		

		addi t0,t0,320			
		sub t0,t0,t4			
		
		mv t3,zero			
		addi t2,t2,1			
		bgt t5,t2,PRINT_LINHA		
		
		ret
		
# =================================================================
# SISTEMA DE DANO E VIDAS (PLAYER VS INIMIGO DUPLO)
# =================================================================
VERIFICA_DANO_PLAYER:
		# Coordenadas atuais do player
		la t0, CHAR_POS
		lh t1, 0(t0)			
		lh t2, 2(t0)			

		# TESTA COLIS�O COM INIMIGO A
		la t3, ENEMY_A_ACTIVE
		lw t4, 0(t3)
		li t5, 1
		bne t4, t5, TESTA_INIMIGO_B	# Se o A n�o est� ativo, pula para testar o B
		
		la t3, ENEMY_A_POS
		lh t4, 0(t3)			
		lh t5, 2(t3)			
		
		bne t1, t4, TESTA_INIMIGO_B	# Se X n�o bateu, testa o B
		bne t2, t5, TESTA_INIMIGO_B	# Se Y n�o bateu, testa o B
		
		# SE CHEGOU AQUI, O INIMIGO A ALCAN�OU O PLAYER
		la a0, ENEMY_A_POS		# Passa dados do A por argumento
		la a1, ENEMY_A_OLD_POS
		li a2, 288			# X de reset do A (Ponto 0)
		li a3, 128			# Y de reset do A
		j APLICA_DANO_LOGICA
		
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_BOSS # Se o boss n�o estiver ativo, pula
		
		la t0, CHAR_POS
		lh t1, 0(t0)			# Player X
		lh t2, 2(t0)			# Player Y
		
		la t3, BOSS_POS
		lh t4, 0(t3)			# Boss X
		lh t5, 2(t3)			# Boss Y
		
		bne t1, t4, FIM_DANO_BOSS
		bne t2, t5, FIM_DANO_BOSS
		
		# Se as coordenadas forem iguais, o Boss te acertou!
		la a0, BOSS_POS
		la a1, BOSS_OLD_POS
		li a2, 144
		li a3, 48
		j APLICA_DANO_LOGICA	# Tira vida e te teleporta pro in�cio da fase
		
FIM_DANO_BOSS:

TESTA_INIMIGO_B:
		#TESTA COLIS�O COM INIMIGO B
		la t3, ENEMY_B_ACTIVE
		lw t4, 0(t3)
		li t5, 1
		bne t4, t5, FIM_VERIFICA_DANO	# Se o B tamb�m n�o est� ativo, encerra
		
		la t3, ENEMY_B_POS
		lh t4, 0(t3)			
		lh t5, 2(t3)			
		
		bne t1, t4, FIM_VERIFICA_DANO	
		bne t2, t5, FIM_VERIFICA_DANO	
		
		# SE CHEGOU AQUI, O INIMIGO B ALCAN�OU O PLAYER
		la a0, ENEMY_B_POS		# Passa dados do B por argumento
		la a1, ENEMY_B_OLD_POS
		li a2, 128			# X de reset do B (Ponto 1)
		li a3, 112			# Y de reset do B

# ------
# DANO
# ------
APLICA_DANO_LOGICA:
		# EFEITO SONORO DO PLAYER TOMANDO DANO
		addi sp, sp, -20
		sw ra, 0(sp)
		sw a0, 4(sp)
		sw a1, 8(sp)
		sw a2, 12(sp)
		sw a3, 16(sp)
		
		li a0, 45         # Nota grave
		li a1, 150        # Duração bem curta (150ms)
		li a2, 81         # Instrumento 81
		li a3, 127        # Volume máximo
		call TOCA_EFEITO
		
		lw ra, 0(sp)
		lw a0, 4(sp)
		lw a1, 8(sp)
		lw a2, 12(sp)
		lw a3, 16(sp)
		addi sp, sp, 20
	
		# Subtrai uma vida do jogador
		la t0, PLAYER_LIVES
		lw t1, 0(t0)
		addi t1, t1, -1
		sw t1, 0(t0)
		
		# Se as vidas ainda forem maiores que zero, continua o jogo (reposiciona)
		bgtz t1, CONTINUA_VIVO 
		
		# GAME OVER
		addi sp, sp, -4
		sw ra, 0(sp)
		li a0, 60                
		call ESPERA_FRAMES
		lw ra, 0(sp)
		addi sp, sp, 4
		
		j TELA_GAME_OVER         # Vai para o fim do jogo definitivo
CONTINUA_VIVO:
		# Configura limpeza do fantasma da morte do Player
		la t0, CHAR_POS
		lw t1, 0(t0)			
		la t2, PLAYER_DEATH_POS
		sw t1, 0(t2)			
		
		la t0, PLAYER_RESPAWN_COUNT
		li t1, 2
		sw t1, 0(t0)			

		# Configura limpeza do fantasma do inimigo que atacou (usando a0 e a1)
		lw t1, 0(a0)			
		la t2, ENEMY_DEATH_POS
		sw t1, 0(t2)			

		lw t1, 0(a1)			
		la t2, ENEMY_PENULTIMA_POS
		sw t1, 0(t2)			

		la t0, ENEMY_RESPAWN_COUNT
		li t1, 2
		sw t1, 0(t0)			

		# Player volta para a base inferior (160, 208)
		li t1, 160
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		# Salva X (a2) e Y (a3) do inimigo corretamente sem misturar os dados
		sh a2, 0(a0)	# Define o novo X na posi��o atual
		sh a3, 2(a0)	# Define o novo Y na posi��o atual
		sh a2, 0(a1)	# Define o novo X na posi��o antiga
		sh a3, 2(a1)	# Define o novo Y na posi��o antiga

FIM_VERIFICA_DANO:
		ret
		
#TELA DE GAME OVER E REIN�CIO
TELA_GAME_OVER:
        	# Desenha a imagem/texto de derrota nos dois buffers
	        la a0, derrotatxt        # Label do include da sua tela de game over
	        li a1, 0                 # X = 0
	        li a2, 0                 # Y = 0
	        li a3, 0                 # Buffer 0
	        call PRINT
	        li a3, 1                 # Buffer 1
	        call PRINT
	        # Trava a tela esperando o jogador apertar Espa�o
	        j FIM
	        # =========================================================
	        # REINICIALIZA��O DO JOGO
	        # =========================================================
	        # Reseta as vidas do player para 3
	        la t0, PLAYER_LIVES
	        li t1, 3
	        sw t1, 0(t0)
	        # Reseta o n�vel atual para 1
	        la t0, CURRENT_LEVEL
	        li t1, 1
	        sw t1, 0(t0)
	        # Reseta os contadores de respawn/fantasma para evitar lixo visual
	        la t0, PLAYER_RESPAWN_COUNT
	        sw zero, 0(t0)
	        la t0, ENEMY_RESPAWN_COUNT
	        sw zero, 0(t0)
	        # Reseta os inimigos para inativos (recome�ar da fase 1 limpo)
	        la t0, ENEMY_A_ACTIVE
	        sw zero, 0(t0)
	        la t0, ENEMY_B_ACTIVE
	        sw zero, 0(t0)
	        la t0, BULLET_ACTIVE
	        sw zero, 0(t0)
	        # Reseta a posi��o do Personagem para o local inicial (160, 208)
	        li t1, 144
	        li t2, 144
	        la t0, CHAR_POS
	        sh t1, 0(t0)
	        sh t2, 2(t0)
	        la t0, OLD_CHAR_POS
	        sh t1, 0(t0)
	        sh t2, 2(t0)
	        # For�a o redesenho do mapa inicial para limpar a imagem de derrota
	        la t0, MATRIZ_MAPA1
	        la t1, CURRENT_MAP_MATRIX
	        sw t0, 0(t1)
	        la t0, MAPA1
	        la t1, CURRENT_MAP_BG
	        sw t0, 0(t1)
	        lw a0, 0(t1)             # Recarrega o MAPA1
	        li a1, 0                
	        li a2, 0                
	        li a3, 0                
	        call PRINT               # Limpa Buffer 0
	        li a3, 1                
	        call PRINT               # Limpa Buffer 1
	        li s0, 0                 # Reinicia o sincronizador de frame (Double Buffering)
	        # Salta de volta para o in�cio do jogo (Game Loop)
	        j GAME_LOOP
	        
TELA_VITORIA:
		# Desenha a imagem/texto de vitoria nos dois buffers
	        la a0, vitoriatxt        # Label do include da sua tela de game over
	        li a1, 0                 # X = 0
	        li a2, 0                 # Y = 0
	        li a3, 0                 # Buffer 0
	        call PRINT
	        li a3, 1                 # Buffer 1
	        call PRINT
	        j FIM
		
# =================================================================
# VERIFICA SE O TIRO DO JOGADOR ACERTOU O CHEFAO
# =================================================================
VERIFICA_DANO_BOSS:
		# S� checa se o Boss estiver totalmente ativo (1) e tiro ativo (1)
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_DO_CHEFAO

		la t0, BULLET_ACTIVE    
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DANO_DO_CHEFAO

		# Carrega a posi��o do Tiro do Player
		la t0, BULLET_POS       
		lh t1, 0(t0)            # Tiro X
		lh t2, 2(t0)            # Tiro Y

		# Carrega a posi��o do Boss
		la t3, BOSS_POS
		lh t4, 0(t3)            # Boss X
		lh t5, 2(t3)            # Boss Y

		# Compara as coordenadas X e Y
		bne t1, t4, FIM_DANO_DO_CHEFAO
		bne t2, t5, FIM_DANO_DO_CHEFAO
		
		# Desativa o tiro do jogador
		la t0, BULLET_ACTIVE
		li t1, 2                
		sw t1, 0(t0)

		# Subtrai vida do Boss
		la t0, BOSS_LIVES
		lw t1, 0(t0)
		addi t1, t1, -1         
		sw t1, 0(t0)

		# Verifica se o Boss morreu
		bgtz t1, FIM_DANO_DO_CHEFAO  

		# --- O BOSS MORREU! ---
		la t0, BOSS_ACTIVE
		li t1, 2             
		sw t1, 0(t0)

FIM_DANO_DO_CHEFAO:
		ret
		
		VERIFICA_DEATH_TIMER:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		
		# Se o boss est� vivo (1) ou totalmente limpo (0), n�o faz nada
		beq t1, zero, FIM_DEATH_TIMER
		li t2, 1
		beq t1, t2, FIM_DEATH_TIMER
		
		# Se est� no estado 2, muda para o estado 3
		li t2, 2
		bne t1, t2, BOSS_EM_ESPERA
		
		la t0, BOSS_ACTIVE
		li t1, 3
		sw t1, 0(t0)
		ret

BOSS_EM_ESPERA:
		# Se chegou aqui, BOSS_ACTIVE == 3 (Os dois frames de rastro j� foram limpos)
		# Incrementa o temporizador que criamos na mem�ria
		la t0, BOSS_DEATH_TIMER
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		li t2, 60               # ~60 frames de espera (aprox. 1 segundo)
		blt t1, t2, FIM_DEATH_TIMER
		
		# O tempo acabou! Vai para a tela de Vit�ria
		j TELA_VITORIA

FIM_DEATH_TIMER:
		ret

		
		
# =================================================================
# MUDANCA DE FASE
# =================================================================
VERIFICA_MUDANCA_FASE:
		la t0, CURRENT_LEVEL
		lw t1, 0(t0)
		
		li t2, 1
		beq t1, t2, CHECKA_FASE_1	
		li t2, 2
		beq t1, t2, CHECKA_FASE_2	
		j FIM_MUDANCA			

# -----------------------------------------------------------------
# LOGICA DA PORTA DO MAPA 1 -> MAPA 2
# -----------------------------------------------------------------
CHECKA_FASE_1:
		la t0, CHAR_POS
		lh t1, 0(t0)			
		lh t2, 2(t0)			
		srli t3, t2, 4			
		li t4, 20				
		mul t3, t3, t4			
		srli t4, t1, 4			
		add t3, t3, t4			
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)			
		add t4, t4, t3			
		lbu t5, 0(t4)			
		
		li t6, 19			
		bne t5, t6, FIM_MUDANCA	
		
		# ENTROU NO MAPA 2
		la t0, CURRENT_LEVEL
		li t1, 2
		sw t1, 0(t0)
		
		la t0, MATRIZ_MAPA2
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)			
		la t0, MAPA2
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)			
		
		li t1, 32
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS		
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		li t1, 288
		li t2, 112
		la t0, ENEMY_A_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_A_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_A_ACTIVE
		li t1, 1
		sw t1, 0(t0)                

		li t1, 96               
		li t2, 112
		la t0, ENEMY_B_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_B_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, ENEMY_B_ACTIVE
		li t1, 1
		sw t1, 0(t0)

		addi sp, sp, -4
		sw ra, 0(sp)			
		la a0, MAPA2			
		li a1, 0				
		li a2, 0				
		li a3, 0				
		call PRINT			
		li a3, 1				
		call PRINT			
		lw ra, 0(sp)			
		addi sp, sp, 4			
		j FIM_MUDANCA

CHECKA_FASE_2:
		# Verifica se os inimigos ainda est�o vivos
		la t0, ENEMY_A_ACTIVE
		lw t1, 0(t0)
		bnez t1, FIM_MUDANCA		# Se Inimigo A n�o � 0, sala n�o est� limpa. Sai.
		
		la t0, ENEMY_B_ACTIVE
		lw t1, 0(t0)
		bnez t1, FIM_MUDANCA		# Se Inimigo B n�o � 0, sala n�o est� limpa. Sai.

		# Calcula o bloco atual do Player para ver se tocou na porta
		la t0, CHAR_POS
		lh t1, 0(t0)			# Player X
		lh t2, 2(t0)			# Player Y
		
		srli t3, t2, 4			# Y / 16
		li t4, 20
		mul t3, t3, t4			# Linha * 20
		srli t4, t1, 4			# X / 16
		add t3, t3, t4			# �ndice na matriz
		
		la t4, CURRENT_MAP_MATRIX
		lw t4, 0(t4)			# Aponta para Matriz do Mapa 2
		add t4, t4, t3
		lbu t5, 0(t4)			# L� o ID do Bloco
		
		li t6, 29			# ID da porta do Mapa 2
		bne t5, t6, FIM_MUDANCA	# Se n�o pisou no bloco 29, ignora
		
		# =========================================================
		# GATILHO ATIVADO: PORTA ENCONTRADA E INIMIGOS MORTOS!
		# =========================================================
		
		# Atualiza n�vel para Fase 3
		la t0, CURRENT_LEVEL
		li t1, 3
		sw t1, 0(t0)
		
		la t0, MATRIZ_MAPA3
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)
		
		la t0, MAPA3
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)
		
		# Posi��o inicial do Player ao entrar na sala do Chef�o
		li t1, 144
		li t2, 208
		la t0, CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, OLD_CHAR_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		# NICIALIZA��O DO CHEF�O
		li t1, 144                      # X inicial do Boss (Meio da tela)
		li t2, 48                       # Y inicial do Boss (Parte superior)
		la t0, BOSS_POS
		sh t1, 0(t0)
		sh t2, 2(t0)
		la t0, BOSS_OLD_POS	
		sh t1, 0(t0)
		sh t2, 2(t0)
		
		la t0, BOSS_ACTIVE
		li t1, 1
		sw t1, 0(t0)                    # Ativa o Chef�o
		
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la a0, MAPA3
		li a1, 0
		li a2, 0
		
		li a3, 0
		call PRINT			# Roda frame 0
		
		li a3, 1
		call PRINT			# Roda frame 1
		
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_MUDANCA:
		ret
		
# =================================================================
# IA DO CHEF�O: MOVIMENTO E GATILHO DE DISPARO
# =================================================================
ATUALIZA_BOSS:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_ATUALIZA_BOSS	# S� processa se o Boss estiver ativo (1)
		
		# CONTROLE DE VELOCIDADE DO PASSO
		la t0, BOSS_COUNT
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		la t2, BOSS_SPEED
		lw t2, 0(t2)
		blt t1, t2, CHECK_BOSS_FIRE	# Se n�o deu o tempo de andar, pula direto pro tiro
		
		sw zero, 0(t0)			# Reseta cron�metro do passo
		
		#  MOVIMENTO
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la t0, BOSS_POS
		lh t3, 0(t0)			# t3 = Boss X
		lh t4, 2(t0)			# t4 = Boss Y
		
		# Carimba a posi��o atual no rastro antigo antes de andar
		la t1, BOSS_OLD_POS
		lw t2, 0(t0)
		sw t2, 0(t1)
		
		la t1, CHAR_POS
		lh t5, 0(t1)			# t5 = Player X
		lh t6, 2(t1)			# t6 = Player Y
		
		beq t3, t5, BOSS_IA_Y		
		blt t3, t5, BOSS_IA_DIR		
BOSS_IA_ESQ:	addi t3, t3, -16
		j CHK_COLISAO_BOSS
BOSS_IA_DIR:	addi t3, t3, 16
		j CHK_COLISAO_BOSS

BOSS_IA_Y:	beq t4, t6, RESTAURA_PILHA_BOSS
		blt t4, t6, BOSS_IA_BAIXO
BOSS_IA_CIMA:	addi t4, t4, -16
		j CHK_COLISAO_BOSS
BOSS_IA_BAIXO:	addi t4, t4, 16

CHK_COLISAO_BOSS:
		srli t1, t4, 4			
		li t2, 20
		mul t1, t1, t2			
		srli t2, t3, 4			
		add t1, t1, t2			
		
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)			
		
		beq t1, zero, RESTAURA_PILHA_BOSS
		
		# Grava a nova posi��o v�lida
		la t0, BOSS_POS
		sh t3, 0(t0)
		sh t4, 2(t0)

RESTAURA_PILHA_BOSS:
		lw ra, 0(sp)
		addi sp, sp, 4
		j CHECK_BOSS_FIRE

# L�GICA DE RECARGA E MIRA AUTOM�TICA DO TIRO
CHECK_BOSS_FIRE:
		la t0, BOSS_FIRE_COUNT
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		la t2, BOSS_FIRE_RATE
		lw t2, 0(t2)
		blt t1, t2, DESENHA_BOSS	# Ainda recarregando...
		
		la t2, BOSS_BULLET_ACTIVE
		lw t3, 0(t2)
		bnez t3, DESENHA_BOSS		# Se j� tem um tiro verde na tela, espera
		
		sw zero, 0(t0)			# Reseta o tempo de recarga
		li t3, 1
		sw t3, 0(t2)			# Ativa o tiro
		
		la t2, BOSS_POS
		lw t3, 0(t2)
		la t4, BOSS_BULLET_POS
		sw t3, 0(t4)			# Proj�til nasce na coordenada central do Boss
		
		lh t3, 0(t2)			# BX
		lh t4, 2(t2)			# BY
		la t1, CHAR_POS
		lh t5, 0(t1)			# PX
		lh t6, 2(t1)			# PY
		
		sub t1, t5, t3			# t1 = dx (PX - BX)
		sub t2, t6, t4			# t2 = dy (PY - BY)
		bgez t1, BX_POS
		sub t1, zero, t1		# t1 = |dx|
BX_POS:		bgez t2, BY_POS
		sub t2, zero, t2		# t2 = |dy|
BY_POS:		blt t1, t2, BMIRA_Y
BMIRA_X:	blt t3, t5, BDISP_DIR
BDISP_ESQ:	li t1, 3			# Atira para a Esquerda
		j BGRAVA_DIR
BDISP_DIR:	li t1, 4			# Atira para a Direita
		j BGRAVA_DIR
BMIRA_Y:	blt t4, t6, BDISP_BAIXO
BDISP_CIMA:	li t1, 1			# Atira para Cima
		j BGRAVA_DIR
BDISP_BAIXO:	li t1, 2			# Atira para Baixo
BGRAVA_DIR:	la t0, BOSS_BULLET_DIR
		sw t1, 0(t0)

# ENDERIZA��O DO SPRITE DO BOSS
DESENHA_BOSS:
		addi sp, sp, -4
		sw ra, 0(sp)
		la a0, chefao1			
		la t0, BOSS_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0
		call PRINT
		lw ra, 0(sp)
		addi sp, sp, 4

FIM_ATUALIZA_BOSS:
		ret

# =================================================================
# F�SICA E COLIS�O DO PROJ�TIL VERDE DO CHEF�O
# =================================================================
MOVE_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_MOVE_BOSS_BULLET # S� move se estiver ativo (1)
		
		la t0, BOSS_BULLET_POS
		lw t1, 0(t0)
		la t2, OLD_BOSS_BULLET_POS
		sw t1, 0(t2)			# Copia posi��o para hist�rico de rastro
		
		lh t3, 0(t0)			# Tiro X
		lh t4, 2(t0)			# Tiro Y
		
		la t0, BOSS_BULLET_DIR
		lw t1, 0(t0)
		
		li t2, 1
		beq t1, t2, BB_CIMA
		li t2, 2
		beq t1, t2, BB_BAIXO
		li t2, 3
		beq t1, t2, BB_ESQ
		li t2, 4
		beq t1, t2, BB_DIR
		j FIM_MOVE_BOSS_BULLET

BB_CIMA:	addi t4, t4, -16
		j CHK_BB_COLISAO
BB_BAIXO:	addi t4, t4, 16
		j CHK_BB_COLISAO
BB_ESQ:		addi t3, t3, -16
		j CHK_BB_COLISAO
BB_DIR:		addi t3, t3, 16

CHK_BB_COLISAO:
		blt t3, zero, BB_MORRE
		li t1, 320
		bge t3, t1, BB_MORRE
		blt t4, zero, BB_MORRE
		li t1, 240
		bge t4, t1, BB_MORRE
		
		srli t1, t4, 4
		li t2, 20
		mul t1, t1, t2
		srli t2, t3, 4
		add t1, t1, t2
		la t2, CURRENT_MAP_MATRIX
		lw t2, 0(t2)
		add t2, t2, t1
		lbu t1, 0(t2)
		beq t1, zero, BB_MORRE		# Bateu em parede l�gica, apaga o tiro
		
		la t0, CHAR_POS
		lh t1, 0(t0)
		lh t2, 2(t0)
		bne t3, t1, BB_SUCESSO		
		bne t4, t2, BB_SUCESSO		
		
		# IMPACTO
		la t0, BOSS_BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)			# Coloca o tiro para sumir no pr�ximo frame
		
		addi sp, sp, -4
		sw ra, 0(sp)
		
		la a0, CHAR_POS			# Alvo do reset � o Player
		la a1, OLD_CHAR_POS
		li a2, 144				# X inicial do player no mapa 3
		li a3, 208				# Y inicial do player no mapa 3
		call APLICA_DANO_LOGICA		
		
		lw ra, 0(sp)
		addi sp, sp, 4
		j FIM_MOVE_BOSS_BULLET

BB_SUCESSO:
		la t0, BOSS_BULLET_POS
		sh t3, 0(t0)
		sh t4, 2(t0)
		j FIM_MOVE_BOSS_BULLET

BB_MORRE:	la t0, BOSS_BULLET_ACTIVE
		li t1, 2
		sw t1, 0(t0)			# Inicia protocolo de sumi�o do tiro

FIM_MOVE_BOSS_BULLET:
		ret

# =================================================================
# RENDERS E LIMPADORES DE RASTRO ADICIONAIS DO BOSS
# =================================================================
DESENHA_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		li t2, 1
		bne t1, t2, FIM_DRAW_BB
		
		la t0, BOSS_BULLET_POS
		la a0, cajado	
		lh a1, 0(t0)
		lh a2, 2(t0)
		mv a3, s0
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call PRINT
		lw ra, 0(sp)
		addi sp, sp, 4
FIM_DRAW_BB:	ret

LIMPA_RASTRO_BOSS:
		la t0, BOSS_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_L_BOSS
		
		la t0, BOSS_OLD_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA
		lw ra, 0(sp)
		addi sp, sp, 4
FIM_L_BOSS:	ret

# =================================================================
# LIMPEZA DO RASTRO DO TIRO VERDE DO CHEF�O
# =================================================================
LIMPA_RASTRO_BOSS_BULLET:
		la t0, BOSS_BULLET_ACTIVE
		lw t1, 0(t0)
		beq t1, zero, FIM_L_BB		# Se inativo (0), n�o faz nada
		
		# Salva estado atual na pilha
		addi sp, sp, -4
		sw t1, 0(sp)
		
		# Prepara coordenadas antigas para o restaurador de texturas
		la t0, OLD_BOSS_BULLET_POS
		lh a1, 0(t0)
		lh a2, 2(t0)
		
		addi sp, sp, -4
		sw ra, 0(sp)
		call ENCONTRA_TEXTURA		# Restaura o piso correspondente
		lw ra, 0(sp)
		addi sp, sp, 4
		
		lw t1, 0(sp)
		addi sp, sp, 4

		li t2, 2
		beq t1, t2, BB_VA_PARA_3
		li t2, 3
		beq t1, t2, BB_VA_PARA_0
		j FIM_L_BB

BB_VA_PARA_3:
		la t0, BOSS_BULLET_ACTIVE
		li t1, 3
		sw t1, 0(t0)			# Configura para limpar o segundo frame no pr�ximo ciclo
		j FIM_L_BB

BB_VA_PARA_0:
		la t0, BOSS_BULLET_ACTIVE
		sw zero, 0(t0)			# Com os dois frames limpos, zera o status para novo disparo

FIM_L_BB:	ret


# =================================================================
# ESPERA UM DETERMINADO N�MERO DE FRAMES (DELAY L�GICO)
# Entrada: a0 = quantidade de frames para esperar
# =================================================================
ESPERA_FRAMES:
		li t0, 0
LOOP_DELAY_OUTER:
		beq t0, a0, FIM_DELAY
		
		li t1, 0
		li t2, 6000             
LOOP_DELAY_INNER:
		addi t1, t1, 1
		blt t1, t2, LOOP_DELAY_INNER
		
		addi t0, t0, 1
		j LOOP_DELAY_OUTER
FIM_DELAY:
		ret
# =================================================================
# WAIT_SPACE_WITH_MUSIC
# Espera o espaço ser teclado enquanto toca a melodia de forma assíncrona
# =================================================================
WAIT_SPACE_WITH_MUSIC:
        # Salva o contexto na pilha (Stack)
        addi sp, sp, -24
        sw ra, 0(sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)

        la s0, MUSICA_INTRO       # s0 = Ponteiro para a nota atual da música
        li s1, 0                  # s1 = Timestamp de quando tocar a próxima nota (0 = toca imediatamente)

LOOP_ESPERA_E_MUSICA:
        # --- PARTE 1: VERIFICAÇÃO DO TECLADO (Igual ao seu WAIT_SPACE original) ---
        li t1, 0xFF200000        
        lw t0, 0(t1)              # Lê o bit de controle do teclado
        andi t0, t0, 0x0001     
        beqz t0, CHECA_TEMPO_MUSICA # Se nenhuma tecla foi pressionada, vai direto gerenciar a música
        
        lw t2, 4(t1)              # Lê a tecla pressionada
        li t0, 32                 # Código ASCII da barra de espaço
        beq t2, t0, FIM_WAIT_MUSIC # Se foi Espaço, sai da função e avança no jogo

CHECA_TEMPO_MUSICA:
        # --- PARTE 2: CONTROLE DO TEMPO DA MÚSICA ---
        li a7, 30                 # ecall 30: Pega o tempo do sistema (System Time)
        ecall                     # Retorna os 32 bits inferiores do tempo em a0
        mv t3, a0                 # t3 = Tempo atual em milissegundos

        # Se o tempo atual for menor que o target (s1), ainda não é hora da próxima nota
        blt t3, s1, LOOP_ESPERA_E_MUSICA 

        # --- PARTE 3: EMISSÃO DA NOTA ---
        lw t4, 0(s0)              # Carrega a nota (Pitch) do array
        li t5, -1
        bne t4, t5, EMITE_SOM     # Se não for -1, toca a nota

        # Se for -1, a música acabou. Reseta o ponteiro s0 para o início (Looping)
        la s0, MUSICA_INTRO
        lw t4, 0(s0)              # Recarrega a primeira nota

EMITE_SOM:
        lw t6, 4(s0)              # t6 = Duração da nota em milissegundos

        # Configura os argumentos para a ecall 31 (MIDI Assíncrono)
        mv a0, t4                 # Nota/Pitch
        mv a1, t6                 # Duração
        li a2, 19                 # Instrumento (19 = Órgão de Igreja / Church Organ)
        li a3, 75                 # Volume (0 a 127)
        li a7, 31                 # Chamada MIDI Assíncrona
        ecall

        # Define quando será a próxima nota: Tempo Atual + Duração da nota
        add s1, t3, t6            
        addi s0, s0, 8            # Avança o ponteiro do array em 8 bytes (2 palavras de 4 bytes)

        j LOOP_ESPERA_E_MUSICA    # Continua no loop

FIM_WAIT_MUSIC:
        # Restaura os registradores salvos
        lw ra, 0(sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        addi sp, sp, 24
        ret

# =================================================================
# TOCA EFEITO SONORO (Assíncrono, não trava o jogo)
# a0 = Nota (Pitch)
# a1 = Duração (ms)
# a2 = Instrumento (0 a 127)
# a3 = Volume (0 a 127)
# =================================================================
TOCA_EFEITO:
        addi sp, sp, -4
        sw a7, 0(sp)     # Salva a7 para não alterar as syscalls do resto do código
        
        li a7, 31        # Chamada MIDI Assíncrona
        ecall
        
        lw a7, 0(sp)
        addi sp, sp, 4
        ret
