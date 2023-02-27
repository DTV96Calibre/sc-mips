li $t0, 1           # 1
li $t1, 2

li $v0, 1		    # 
add $a0, $t1, $t0	# 
syscall

li $v0, 10 		    # 
syscall             # 1