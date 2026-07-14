.data
#INTRO
MUSICA_INTRO:
	.word 60, 400   # Dó
	.word 64, 400   # Mi
	.word 67, 400   # Sol
	.word 64, 400   # Mi
	.word 69, 400   # Lá
	.word 67, 800   # Sol (mais longa)
	.word -1, 0     # Fim da melodia (reinicia)
#FASE
CURRENT_LEVEL:       .word 1       # Comeca na sase 1
CURRENT_MAP_MATRIX:  .word 0       # Ponteiro para a matriz logica ativa
CURRENT_MAP_BG:      .word 0       # Ponteiro para a textura de fundo ativa

#VIDA
BASE_ADDRESS: .word 268697600
HEART_POS:    .half 0, 0		 # X, Y

#POSICAO DO PLAYER/JOGADOR
CHAR_POS:	.half 144,144			# x, y iniciais do personagem
OLD_CHAR_POS:	.half 144,144			# x, y do personagem

#POSICAO E DADOS SOBRE OS INIMIGOS DA FASE 2
ENEMY_A_COUNT:          .word 0
ENEMY_B_COUNT:          .word 0       
ENEMY_SPEED:          .word 80    #EDITAVEL!! Velocidade dos inimigos!

TOTAL_DEFEATED:       .word 0       # Quantas vezes os inimigos morreram no total
SPAWN_INDEX:          .word 0       # Proximo ponto de nascimento usado

SPAWN_POINTS:
    .half 32, 48                   
    .half 160, 48                   
    .half 128, 112           
    .half 224, 192              

# inimigo A
ENEMY_A_POS:          .half 0, 0    # Coordenadas atuais
ENEMY_A_OLD_POS:      .half 0, 0    # Coordenadas do ultimo frame
ENEMY_A_ACTIVE:       .word 0       # Ativo ou inativo
ENEMY_A_LIVES:        .word 4       # Quantidade de vidas restantes

# inimigo B
ENEMY_B_POS:          .half 0, 0    # Coordenadas atuais
ENEMY_B_OLD_POS:      .half 0, 0    # Coordenadas do ultimo frame
ENEMY_B_ACTIVE:       .word 0       # Ativo ou inativo
ENEMY_B_LIVES:        .word 4       # Quantidade de vidas restantes

# VARIAVEIS DO CHEFAO
BOSS_POS:             .half 144, 48    # Coordenadas iniciais
BOSS_OLD_POS:         .half 144, 48    # Coordenadas para limpeza de rastro
BOSS_ACTIVE:          .word 0          # Ativo ou inativo
BOSS_LIVES:           .word 2         # EDITAVEL!! Vidas do chefao
BOSS_COUNT:           .word 0          
BOSS_SPEED:           .word 40         #EDITAVEL!! Velocidade do chefao
BOSS_DEATH_TIMER:     .word 0

#TIRO DO CHEFAO
BOSS_BULLET_POS:      .half 0, 0       # Coordenadas do chefao
OLD_BOSS_BULLET_POS:  .half 0, 0       # Rastro do tiro do chefao
BOSS_BULLET_ACTIVE:   .word 0          # Ativo ou inativo
BOSS_BULLET_DIR:      .word 0          # Direcao 1=Cima, 2=Baixo, 3=Esquerda, 4=Direita
BOSS_FIRE_COUNT:      .word 0          
BOSS_FIRE_RATE:       .word 300        # EDITAVEL!! Intervalo de frames entre os tiros

#VIDAS DO PLAYER
PLAYER_LIVES:	.word 3				# EDITAVEL!! Vidas do jogador
PLAYER_DEATH_POS:     .half 0, 0    		# Guarda as coordenadas de onde o player morreu
PLAYER_RESPAWN_COUNT: .word 0    		# Limpa os frames das coordenadas de onde o player morreu

#ATAQUE DOS INIMIGOS
ENEMY_DEATH_POS:      .half 0, 0    		# Guarda onde o inimigo bateu no player
ENEMY_PENULTIMA_POS:  .half 0, 0		# Guarda a ultima posicao antes do inimigo bater no player
ENEMY_RESPAWN_COUNT:  .word 0    		# Contador de 2 frames para limpar o fantasma do inimigo

#ULTIMA DIRECAO DO JOGADO (define a direcao do tiro)
CHAR_LOOK_DIR:   .word 4               # 1=Cima, 2=Baixo, 3=Esquerda, 4=Direita (Padr�o: Direita)

#SISTEMA DE TIRO
BULLET_POS:	.half 0, 0			#X e Y do tiro
OLD_BULLET_POS:	.half 0, 0			# Rastro
BULLET_ACTIVE:	.word 0				# Ativo ou inativo
BULLET_DIR:	.word 0				# Direcao

.text

HISTORIA:	
	        la a0, comecotxt        # Endereço da imagem
	        li a1, 0                # X = 0
	        li a2, 0                # Y = 0
	        li a3, 0                
	        call PRINT
	        li a3, 1                
	        call PRINT
	        
	        call WAIT_SPACE_WITH_MUSIC #Espera e toca música
	        
	        la a0, ajudatxt         # Endereço da imagem/texto da história 2
	        li a1, 0
	        li a2, 0
	        li a3, 0
	        call PRINT
	        li a3, 1
	        call PRINT
	        
	        call WAIT_SPACE_WITH_MUSIC #Espera e toca música na tela 2

	        j SETUP


# Esse setup serve pra desenhar o mapa 1 nos dois frames antes do jogo comecar
SETUP:		la t0, MATRIZ_MAPA1
		la t1, CURRENT_MAP_MATRIX
		sw t0, 0(t1)
		
		la t0, MAPA1
		la t1, CURRENT_MAP_BG
		sw t0, 0(t1)

		# Desenha o fundo inicial (o mapa 1)
		lw a0, 0(t1)
		li a1,0				
		li a2,0				
		li a3,0				
		call PRINT			
		li a3,1				
		call PRINT

GAME_LOOP:	
		call KEY2			# Tecla do jogador para mover o player

		call MOVE_BULLET		
		call MOVE_BOSS_BULLET
		call VERIFICA_DANO_PLAYER		
		call VERIFICA_MUDANCA_FASE   	
		call VERIFICA_DANO_BOSS
		
		xori s0, s0, 1			# Inverte o frame atual
		
		#PROCESSA INIMIGO A
		la a0, ENEMY_A_POS          
		la a1, ENEMY_A_OLD_POS      
		la a2, ENEMY_A_ACTIVE       
		mv a3, s0     
		la a4, ENEMY_A_COUNT              
		call ATUALIZA_INIMIGO
		
		#PROCESSA INIMIGO B
		la a0, ENEMY_B_POS          
		la a1, ENEMY_B_OLD_POS      
		la a2, ENEMY_B_ACTIVE       
		mv a3, s0        
		la a4, ENEMY_B_COUNT           
		call ATUALIZA_INIMIGO
		
		#CHEFAO DO MAPA 3
		call ATUALIZA_BOSS
		
		#DESENHA PERSONAGEM
		la t0, CHAR_POS			
		la a0, padre1			
		lh a1, 0(t0)			
		lh a2, 2(t0)			
		mv a3, s0			
		call PRINT
		
		#DESENHA VIDA
            	la t0, HEART_POS            
	        lh a1, 0(t0)
	        lh a2, 2(t0)    
	        li t1, 3                
        	LOOP_LIMPA_CORACOES:
          
            	addi sp, sp, -12
            	sw t1, 8(sp)
            	sw a2, 4(sp)
            	sw a1, 0(sp)
            	# Carrega a textura de fundo ou grama para cobrir o cora��o antigo
            	la a0, preto   
            	mv a3, s0                 
            	call PRINT

            	lw a1, 0(sp)
            	lw a2, 4(sp)
            	lw t1, 8(sp)
            	addi sp, sp, 12
            	addi a1, a1, 16           
            	addi t1, t1, -1           
            	bnez t1, LOOP_LIMPA_CORACOES
        	# --- AGORA DESENHA OS CORA��ES ATIVOS ---
            	lw t1, PLAYER_LIVES          # t1 = Quantidade de vidas atuais
            	blez t1, FIM_DESENHO_VIDA    # Se vida <= 0, nao desenha nada
            	la t0, HEART_POS            
            	lh a1, 0(t0)                 # Reseta X para 0
            	lh a2, 2(t0)                 # Reseta Y para 0
        	LOOP_CORACOES:
            	addi sp, sp, -12
            	sw t1, 8(sp)
            	sw a2, 4(sp)
            	sw a1, 0(sp)

            	la a0, plumbbob              
            	mv a3, s0                    
            	call PRINT

            	lw a1, 0(sp)
            	lw a2, 4(sp)
            	lw t1, 8(sp)
            	addi sp, sp, 12
            	addi a1, a1, 16              
            	addi t1, t1, -1              
            	bnez t1, LOOP_CORACOES       
		FIM_DESENHO_VIDA:			
		
		#DESENHA TIRO
		call DESENHA_BULLET
		call DESENHA_BOSS_BULLET		
		
		#EXIBE O FRAME NO DISPLAY
		li t0, 0xFF200604		
		sw s0, 0(t0)			
		
		# LIMPEZA DE RASTROS NO FRAME INVERSO
		call LIMPA_RASTRO_PLAYER	
		
		#LIMPA RASTRO DOS DOIS INIMIGOS
		la a0, ENEMY_A_OLD_POS
		la a1, ENEMY_A_ACTIVE
		call LIMPA_RASTRO_INIMIGO
		
		la a0, ENEMY_B_OLD_POS
		la a1, ENEMY_B_ACTIVE
		call LIMPA_RASTRO_INIMIGO
		
		call LIMPA_RASTRO_BOSS
		
		# LIMPA RASTRO DOS TIROS
		call LIMPA_RASTRO_BULLET
		call LIMPA_RASTRO_BOSS_BULLET	

		call VERIFICA_DEATH_TIMER

		j GAME_LOOP

FIM: 		li a0, 10
		ecall
		
.data
#Anexo de arquivos
.include "funcoes.s"

.include "mapas_e_matrizes/mapa1.s"
.include "mapas_e_matrizes/matriz_mapa1.s"

.include "mapas_e_matrizes/mapa2.s"
.include "mapas_e_matrizes/matriz_mapa2.s"

.include "mapas_e_matrizes/mapa3.s"
.include "mapas_e_matrizes/matriz_mapa3.s"

#Anexo da historia
.include "historia/comecotxt.s"
.include "historia/ajudatxt.s"
.include "historia/vitoriatxt.s"
.include "historia/derrotatxt.s"

#Anexo de texturas
.include "sprites/padre1.s"

.include "sprites/ghost1.s"
.include "sprites/alien1.s"
.include "sprites/chefao1.s"

.include "texturas/plumbbob.s"
.include "texturas/preto.s"

.include "texturas/cenario1_pedra_esquerda.s"
.include "texturas/cenario1_pedra_direita.s"
.include "texturas/cenario1_escada_esquerda.s"
.include "texturas/cenario1_escada_direita.s"


.include "armas/terco_padre.s"
.include "texturas/cenario2_piso.s"


.include "texturas/cenario3_piso.s"
.include "armas/cajado_chefao.s"
