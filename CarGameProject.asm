ORG    100h
jmp start
left_key    equ     4bh
right_key   equ     4dh
up_key      equ     48h
down_key    equ     50h
pressed_key db ?
wait_time dw 1
coordinates dw 20,3
seconds db 0

print_car PROC
mov dh,b.coordinates[0]
mov dl,b.coordinates[2]
mov bh,0
mov ah,2
int 10h

mov ah,08h
int 10h
cmp al,'*'
jne continue
mov al,'X'
push cx
mov cx,1
mov ah,0Ah
int 10h
pop cx
CALL game_over
HLT            
continue:
mov al,'A'
push cx
mov cx,1
mov ah,0Ah
int 10h
pop cx

RET
print_car ENDP

game_over PROC
    mov al, 0
	mov bh, 0
	mov cx, msg1end - offset msg1 
	mov dl, 0
	mov dh, 20
	push cs
	pop es
	mov bp, offset msg1
	mov ah, 13h
	int 10h
	jmp msg1end
	msg1 db "  GAME OVER!"
	msg1end:

RET
game_over ENDP

game_win PROC
    mov al, 0
	mov bh, 0
	mov cx, msg2end - offset msg2 
	mov dl, 0
	mov dh, 20
	push cs
	pop es
	mov bp, offset msg2
	mov ah, 13h
	int 10h
	jmp msg2end
	msg2 db "   YOU WIN! "
	msg2end:

RET
game_win ENDP

delete_car PROC
mov dh,b.coordinates[0]
mov dl,b.coordinates[2]
mov bh,0
mov ah,2
int 10h
mov al,' '
push cx
mov cx,1
mov ah,0Ah
int 10h
pop cx

RET
delete_car ENDP

print_road PROC    
mov cx,20
print_lane:
    mov dh,cl
    dec dh
    mov dl,0
    mov bh,0
    mov ah,2
    int 10h
    mov al,'|'
    push cx
    mov cx,1
    mov ah,0Ah
    int 10h
    pop cx 
    mov dh,cl
    dec dh
    mov dl,6
    mov bh,0
    mov ah,2
    int 10h
    mov al,'|'
    push cx
    mov cx,1
    mov ah,0Ah
    int 10h
    pop cx
    mov dh,cl
    dec dh
    mov dl,12
    mov bh,0
    mov ah,2
    int 10h
    mov al,'|'
    push cx
    mov cx,1
    mov ah,0Ah
    int 10h
    pop cx
    CALL print_obstacle
    loop print_lane
    

    
RET
print_road ENDP

print_obstacle PROC  
    mov ax,cx
    mov bl,2
    div bl
    cmp ah,0
    je back 
    
    push cx
    mov ah,0h
    int 1ah
    mov al,dl
    mov bl,2
    div bl
    pop cx
    cmp ah,0
    jz left
    cmp ah,1
    jz right
    
    jmp back
    left:
    CALL obstacle_left
    jmp back
    right:
    CALL obstacle_right
    back:
           
RET
print_obstacle ENDP

obstacle_left PROC 
    mov dh,cl
    dec dh
    mov dl,3
    mov bh,0
    mov ah,2
    int 10h
    mov al,'*'
    push cx
    mov cx,1
    mov ah,0Ah
    int 10h
    pop cx
    
RET
obstacle_left ENDP

obstacle_right PROC 
    mov dh,cl
    dec dh
    mov dl,9
    mov bh,0
    mov ah,2
    int 10h
    mov al,'*'
    push cx
    mov cx,1
    mov ah,0Ah
    int 10h
    pop cx
    
RET
obstacle_right ENDP

check_key PROC
       
    mov ah,00h
    int 16h
    
    cmp al,1bh
    je stop_game
    
    mov pressed_key,ah
    CALL move_car
    jmp return
    stop_game:
    HLT
    
    return:       
RET
check_key ENDP

move_car PROC
    cmp pressed_key,left_key
    je move_left
    cmp pressed_key,right_key
    je move_right   
    jmp stop_move
    
    move_left:
        cmp b.coordinates[2],3
        je stop_move
        CALL delete_car
        add b.coordinates[2],-6
        CALL print_car
        jmp stop_move
    move_right:
        cmp b.coordinates[2],9
        je stop_move
        CALL delete_car
        add b.coordinates[2],6
        CALL print_car
        jmp stop_move       
    stop_move:    
RET
move_car ENDP

delay PROC  
delaying:   
  mov  ah, 2ch
  int  21h       
  cmp  dh, seconds  
  je   delaying     
  mov  seconds, dh  
RET
delay ENDP

delay2 PROC
    mov cx,0003h
    mov dx,000fh
    mov ah,86h
    int 15h
    
RET
delay2 ENDP
start:

CALL print_road
CALL print_car

mov ah, 00h
int 16h
jmp move_loop

win:
    CALL game_win
    HLT

no_key:
    CALL delay2
    cmp b.coordinates[0],0
    je win 
    CALL delete_car
    add b.coordinates[0],-1
    CALL print_car
    CALL delay2
move_loop:
    mov ah,01h
    int 16h
    jnz check_for_key
    jmp no_key
    check_for_key:
    CALL check_key
jmp move_loop
   

RET 

END