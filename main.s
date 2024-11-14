# 337762421 Nikita Grebenchuk

.extern printf
.extern scanf
.extern srand
.extern rand


.section .data
# Reserve 4 bytes for a input seed integer
config_integer:
    .long 0

# Reserve 4 bytes for a random generated integer
random_integer:
    .long 0

# Reserve 4 bytes for a guessed integer
guess_integer:
    .long 0

# Reserve byte for a mode selection
mode_char:
    .byte 0

# Reserve byte for a double or nothing selection
don_char:
    .byte 0

# Define a value for M
max_m:
    .long 5

# Define a value for N
max_n:
    .long 10

# Define round won counter
rounds_won:
    .long 0


.section .rodata
user_conf_msg:
    .string "Enter configuration seed: "
    
scanf_integer:
    .string "%d"

scanf_char:
    .string " %c"
    
printf_conf:
    .string "%d\n"

user_mode_msg:
    .string "Would you like to play in easy mode? (y/n) "

user_guess_msg:
    .string "What is your guess? "
    
user_incorrect_msg:
    .string "Incorrect. "

user_clue_above_msg:
    .string "Your guess was above the actual number ...\n"

user_clue_below_msg:
    .string "Your guess was below the actual number ...\n"

user_correct_msg:
    .string "Double or nothing! Would you like to continue to another round? (y/n) "

user_win_msg:
    .string "Congratz! You won %d rounds!\n"

user_lost_msg:
    .string "\nGame over, you lost :(. The correct answer was %d"


.section .text
.globl main
.type	main, @function 
main:
    # Enter
    pushq %rbp
    movq %rsp, %rbp
    
    # Print config prompt
    movq $user_conf_msg, %rdi
    xorq %rax, %rax
    call printf
    
    # Read the config integer
    movq $scanf_integer, %rdi
    movq $config_integer, %rsi
    xorq %rax, %rax
    call scanf
    
    # Print mode prompt
    movq $user_mode_msg, %rdi
    xorq %rax, %rax
    call printf
    
    # Read the mode char
    movq $scanf_char, %rdi
    movq $mode_char, %rsi
    xorq %rax, %rax
    call scanf
    
.play:
    # Envoke rand with seed
    movq config_integer(%rip), %rdi
    xorq %rax, %rax
    call srand
    xorq %rax, %rax
    call rand
    
    # Divide the contents of eax by N and store remainder
    movl max_n(%rip), %ebx
    xorl %edx, %edx
    idiv %ebx
    movl %edx, random_integer(%rip)
    incl random_integer(%rip)
    
    # We use %r15 register as it guranteed to perserve its value
    movl max_m(%rip), %r15d
.guess_loop:
    # If iterator == 0 -> Exit
    cmp $0, %r15
    je .lost
    
    # Print guess prompt
    movq $user_guess_msg, %rdi
    xorq %rax, %rax
    call printf
    
    # Read the guess
    movq $scanf_integer, %rdi
    movq $guess_integer, %rsi
    xorq %rax, %rax
    call scanf
    
    # Compare guess and magic number
    movl random_integer(%rip), %eax
    cmpl guess_integer(%rip), %eax
    je .guessed_right
    
    # Print guess is incorrect prompt
    movq $user_incorrect_msg, %rdi
    xorq %rax, %rax
    call printf
    
    # Check if easy mode and give clue
    movb $'y', %al
    cmpb mode_char(%rip), %al
    jne .skip_clue
    
    # Compare guess and magic number 
    movl guess_integer(%rip), %eax
    cmpl random_integer(%rip), %eax
    ja .above

# If number below print clue
.below:
    movq $user_clue_below_msg, %rdi
    xorq %rax, %rax
    call printf
    jmp .skip_clue

# If number above print clue
.above:
    movq $user_clue_above_msg, %rdi
    xorq %rax, %rax
    call printf
    
.skip_clue:
    # Increment the pointer and continue to next iteration
    decl %r15d
    jmp .guess_loop

    
    # User guessed right
.guessed_right:
    # Increment rounds won counter
    incl rounds_won(%rip)
    
    # Print double or nothing prompt
    movq $user_correct_msg, %rdi
    xorq %rax, %rax
    call printf
    
    # Read the char
    movq $scanf_char, %rdi
    movq $don_char, %rsi
    xorq %rax, %rax
    call scanf
    
    # Check selection
    movb $'y', %al
    cmpb don_char(%rip), %al
    jne .win
    
    # Multiply seed and N by 2
    movl $2, %eax
    movl max_n(%rip), %ebx
    imul %eax, %ebx
    movl %ebx, max_n(%rip)
    movl config_integer(%rip), %ebx
    imul %eax, %ebx
    movl %ebx, config_integer(%rip)
    jmp .play
    
    
    # User finished and won
.win:
    movq $user_win_msg, %rdi
    movl rounds_won(%rip), %esi
    xorq %rax, %rax
    call printf
    jmp .exit

    
    # User lost
.lost:
    movq $user_lost_msg, %rdi
    movl random_integer(%rip), %esi
    xorq %rax, %rax
    call printf
    jmp .exit
    
    

    # Exit
.exit:
    xorq %rax, %rax
    movq %rbp, %rsp
    popq %rbp
    ret











