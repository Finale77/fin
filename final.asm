#Trabalho Final Arquitetura e Organização de Computadores
#Edvaldo Pereira da Silva Júnior - 112.317
#Lucy Braga dos Santos - 112.227
#Thiago da Silva Rosário - 112.261

.data
	#Alguns exemplos de cores
	yellow:   .word 0xF5F62E
	white:	  .word 0xFFFFFF
	blue: 	  .word 0x2E8CF6
	orange:   .word 0xF67F2E
	black:	  .word 0x00000

.text
	j main
	#No caso de teclado, funciona da mesma forma que na linha 15
	set_tela: #Inicia todos os valores para a tela
		addi $t0, $zero, 16384 #65536 = (512*512)/16 pixels
		add $t1, $t0, $zero #Adicionar a distribuição de pixels ao endereco
		lui $t1, 0x1004 #Endereco base da tela no heap, pode mudar se quiser
		jr $ra

	set_cores: #Salva as cores em registradores
		lw $s4, white
		lw $s5, orange
		lw $s6, blue
		lw $s7, black
		jr $ra
		
	#Desenha a tela inicial (fundo branco), de acordo com as especificações
	desenha:
		add $t0, $zero, $t1 #Adiciona o endereço inicial do bitmap Heap
		addi $t2, $zero, 0
		loop_1: #Loop de linha branca no canto superior esquerdo
			sw $s4, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, 1024, exit_2 #vai até o final da tela
			j loop_1
	exit_2:
		jr $ra
	#desenha o caminho gerado aleatoriamente em X positivo
	desenhaX:
		addi $t2, $zero, 0 #contador
		loop_1desenhaX: #Loop de linha branca no canto superior esquerdo
			sw $s7, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 4 #Pulo +4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, $t3, exit_2
			j loop_1desenhaX
			
	desenhaXmenos:
		addi $t2, $zero, 0
		loop_1desenhaXmenos: #Loop de linha branca no canto superior esquerdo
			sw $s7, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			subi $t0, $t0, 4 #Pulo -4 no pixel
			addi $t2, $t2, 1 #Contador +1
			beq $t2, $t3, exit_2
			j loop_1desenhaXmenos


	desenhaY:
		addi $t2, $zero, 0
		loop_1desenhaY: #Loop de linha branca no canto superior esquerdo
			sw $s7, ($t0) #Pinto o pixel na posicao $t0 com a cor de $s4
			addi $t0, $t0, 128 #Pula uma linha (cada linha tem 256 pixels)
			addi $t2, $t2, 1 #Contador +1
			beq $t2, $t4, exit_2
			j loop_1desenhaY
			
	#Sorteia a quantidade que sera andado em X		
	sorteiaX:
		#sorteia um numero aleatorio
		li $v0, 42 # 42 is system call code to generate random int 
		li $a1,8 # $a1 is where you set the upper bound
		syscall # your generated number will be at $a0
		add $a0,$a0,1 #adiciona o menor a ser sorteado ao numero sorteado (para evitar que o numero sorteado seja 0 )
		move $t3,$a0
		
		#j desenhaX
		li $v0, 42 # 42 is system call code to generate random int 
		li $a1, 2 # $a1 is where you set the upper bound
		syscall # your generated number will be at $a0
		add $a0,$a0,1 #adiciona o menor a ser sorteado ao numero sorteado (para evitar que o numero sorteado seja 0 )
		move $t6,$a0
		
		#desenha X positivo ou negativo de acordo com o numero gerado em t6 (1 ou 2)
		beq $t6,1,desenhaX #desenha X positivo
		beq $t6,2,desenhaXmenos #desenha X negativo
	
	#Sorteia a quantidade que sera andado em Y		
	sorteiaY:
		#sorteia um numero aleatorio
		li $v0, 42 # 42 is system call code to generate random int 
		li $a1, 6 # $a1 is where you set the upper bound
		syscall # your generated number will be at $a0
		add $a0,$a0,2 #adiciona o menor a ser sorteado ao numero sorteado (para evitar que o numero sorteado seja 0 )
		move $t4,$a0
		j desenhaY
		
	#Loop pra montar o caminho
	montaCaminho:
		addi $t5, $zero, 0
		loopmontaCaminho:
			jal sorteiaX
			jal sorteiaY
			addi $t5,$t5,1
			beq $t5,6,insereCarro
			j loopmontaCaminho
	
	#sorteia uma posição inicial para o carrinho
	insereCarro:
		li $v0, 42 # 42 is system call code to generate random int 
		li $a1, 256 # $a1 is where you set the upper bound
		syscall # your generated number will be at $a0
		add $a0,$a0,1 #adiciona o menor a ser sorteado ao numero sorteado (para evitar que o numero sorteado seja 0 )
		#gera um valor aleatório até 512
		move $t7,$a0
		#coloca 4 em t2
		li $t2,4
		#multiplica t2 pelo numero sorteado
		mul $t2,$t2,$t7
		add $t8,$t8,$t2 #adiciona t2 a t8
		sw $s6, ($t8) #Pinto o pixel na posicao $t0 com a cor de $s4
		j calculaLinha
		
	calculaLinha:
		#t4 recebe a posição com relação a Y
		addi $t4,$zero,1
		move $t5,$t8 #t5 recebe a posição sorteada do carrinho
		addi $t2,$zero,128 #t2 recebe 128
		#Nesse loop é calculado quantas linhas serao puladas e 
		#em qual posição de X no bitmap o carrinho se encontra
		loopmontaCalculaLinha:
			sle $t3,$t5,$t2 #caso t5<t2
			beq $t3,0,andaCarrinhoX #se a condição de cima for valida
			sub $t5,$t5,128 #t5 - 128 (diminui 1 linha)
			addi $t4,$t4,1 # adiciona 1 ao numero total de linhas
			j loopmontaCalculaLinha
	
	#anda com o carrinho no sentido de X positivo	
	andaCarrinhoX:
		#Temos a base da linha em t5, que é a sua distancia com relação a X
		#Temos a base da linha em t4, que é a sua distancia com relação a Y
		#t7 é a proxima posição
		#t9 é o Y
		#t6 é o limite em X
		#t2 é para resetar 
		mul $t6,$t4,128
		loopandaCarrinhoX:
			move $t7,$t8 #guarda a posição do carrinho em t7
			addi $t7,$t7,4 #anda 1 "casa" em X positivo
			lw $s0,($t7) #s0 guarda o valor do endereço da proxima posição de X
			
			move $t9,$t8 #guarda a posição do carrinho em t9
			subi $t9,$t9,128 #anda 1 "casa" em Y positivo
			lw $s1,($t9) #s1 guarda a proxima posição em Y
			
			slt $t2,$t6,$t7 #compara se t6 é menor que t7
			beq $t2,0,andaCarrinhoY #anda com o carrinho em Y caso o mesmo tenha chegado no limite de X
			beq $s0,0x000000,percorreinicialX #encontrou uma posição valida em X começando em X
			beq $s1,0x000000,percorreinicialY #encontrou uma posição valida em X começando em Y
			
			li $v0, 32  # MARS service delay(ms)
    			li $a0, 40 # 40ms = ~25 FPS if the draw would be instant
    			syscall
    			
			sw $s4,($t8) #Pinta a posição anterior de branco
			move $t8,$t7
			sw $s6,($t8) #Pinta a posição nova de azul
			j loopandaCarrinhoX
			
	andaCarrinhoXmenos:
		#Temos a base da linha em t5, que é a sua distancia com relação a X
		#Temos a base da linha em t4, que é a sua distancia com relação a Y
		#t7 é a proxima posição
		#t9 é o Y
		#t6 é o limite em X
		#t2 é para resetar 
		mul $t6,$t4,128
		loopandaCarrinhoXmenos:
			move $t7,$t8
			subi $t7,$t7,4
			lw $s0,($t7) #s0 guarda a proxima posição de X
			
			move $t9,$t8
			subi $t9,$t9,128
			lw $s1,($t9) #s1 guarda a proxima posição em Y
			
			slt $t2,$t6,$t7 #compara se t6 é menor que t7
			beq $t2,0,andaCarrinhoYmais
			beq $s0,0x000000,percorreinicialX #encontrou uma posição valida em X
			beq $s1,0x000000,percorreinicialY
			
			li $v0,32 # MARS service delay(ms)
    			li $a0,400 # 40ms = ~25 FPS if the draw would be instant
    			syscall
    			
			sw $s4,($t8) #Pinta a posição anterior de branco
			move $t8,$t7
			sw $s6,($t8) #Pinta a posição nova de azul
			j loopandaCarrinhoXmenos
	
	#Move o carrinho na direção de Y positivo
	andaCarrinhoY:
		subi $t4,$t4,1
		subi $t8,$t8,128
		
		li      $v0, 32 # MARS service delay(ms)
    		li      $a0, 200 # 40ms = ~25 FPS if the draw would be instant
    		syscall
		sw $s4,($t8) #Pinta a posição anterior de branco
		move $t8,$t7
		sw $s6,($t8) #Pinta a posição nova de azul
			
		j andaCarrinhoXmenos
	
	#anda com o carrinho em Y positivo
	andaCarrinhoYmais:
		subi $t4,$t4,1
		subi $t8,$t8,128
		
		subi $t4,$t4,1
		subi $t8,$t8,128
		
		li $v0, 32 # MARS service delay(ms)
    		li $a0, 200 # 40ms = ~25 FPS if the draw would be instant
    		syscall
		sw $s4,($t8) #Pinta a posição anterior de branco
		move $t8,$t7
		sw $s6,($t8) #Pinta a posição nova de azul
		
		j andaCarrinhoX
	
	#Percorre a trilha começando por X
	percorreinicialX:
		sw $s4,($t8) #Pinta a posição anterior de branco
		move $t8,$t7
		sw $s6,($t8) #Pinta a posição nova de azul
		j percorre
	#Percorre a trilha começando por Y
	percorreinicialY:
		sw $s4,($t8) #Pinta a posição anterior de branco
		move $t8,$t9
		sw $s6,($t8) #Pinta a posição nova de azul
		j percorre
	
	#Percorre a trilha 
	percorre:	
		move $t7,$t8
		addi $t7,$t7,4
		lw $s0,($t7) #s0 guarda a proxima posição de X
		
		move $t6,$t8
		subi $t6,$t6,4
		lw $s2,($t6) #s2 guarda a proxima posição em X negativo
			
		move $t9,$t8
		addi $t9,$t9,128
		lw $s1,($t9) #s1 guarda a proxima posição em Y
		
		beq $s1,0x000000,percorreY #encontrou uma posição valida em Y	
		beq $s0,0x000000,percorreX #encontrou uma posição valida em X
		beq $s2,0x000000,percorreXmenos #encontrou uma posição valida em X menos
		
		j fim
		
		#percorre em X
		percorreX:
			li $v0, 32 # MARS service delay(ms)
    			li $a0, 200 # 40ms = ~25 FPS if the draw would be instant
    			syscall
			sw $s7,($t8) #Pinta a posição anterior de branco
			move $t8,$t7
			sw $s6,($t8) #Pinta a posição nova de azul
			move $t7,$t8
			addi $t7,$t7,4
			lw $s0,($t7) #s0 guarda a proxima posição de X
			beq $s0,0x000000,percorreX #encontrou uma posição valida em X
			j percorre
			
		#percorre em X negativo
		percorreXmenos:
			li $v0, 32 # MARS service delay(ms)
    			li $a0, 200 # 40ms = ~25 FPS if the draw would be instant
    			syscall
			sw $s7,($t8) #Pinta a posição anterior de branco
			move $t8,$t6
			sw $s6,($t8) #Pinta a posição nova de azul
			move $t6,$t8
			subi $t6,$t6,4
			lw $s2,($t6) #s2 guarda a proxima posição em X negativo
			beq $s2,0x000000,percorreXmenos #encontrou uma posição valida em X menos
			j percorre
			
		percorreY:
			li $v0, 32 # MARS service delay(ms)
    			li $a0, 200 # 40ms = ~25 FPS if the draw would be instant
    			syscall
			sw $s7,($t8) #Pinta a posição anterior de branco
			move $t8,$t9
			sw $s6,($t8) #Pinta a posição nova de azul
			j percorre
		
	#registradores t:
	#t1 possui endere�o do inicio da tela
	#t0 utlizado para controlar a posi��o onde o pixel sera pintado
	#t2 utilizado como contador para sair de condi��es 
	#t3 numero sorteado para X
	#t4 numero sorteado para Y
	#t5 outro contador
	#t6 condi��o para menos ou mais
	#t7 auxiliar para o carrinho
	#t8 posição real do carrinho
	
	#Encerra o programa
	fim:	
		li $v0,10 #This is to terminate the program
		syscall
	
	main:
		# zera alguns registradores 
		move $t3,$zero
		move $t4,$zero
		move $t5,$zero
		move $t0,$zero
		
		jal set_tela #coloca a tela
		jal set_cores #coloca as cores em seus registradores
		jal desenha #desenha o fundo
		
		add $t0,$zero,$t1
		add $t8,$zero,$t1
		add $t0,$t0,64 #8064
		
		
		j montaCaminho
