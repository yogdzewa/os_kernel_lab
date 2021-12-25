
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int kern_init(void)
{
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	b8 08 0d 11 00       	mov    $0x110d08,%eax
  10000b:	2d 16 fa 10 00       	sub    $0x10fa16,%eax
  100010:	89 44 24 08          	mov    %eax,0x8(%esp)
  100014:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001b:	00 
  10001c:	c7 04 24 16 fa 10 00 	movl   $0x10fa16,(%esp)
  100023:	e8 4d 34 00 00       	call   103475 <memset>

    cons_init(); // init the console
  100028:	e8 d1 15 00 00       	call   1015fe <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002d:	c7 45 f4 20 36 10 00 	movl   $0x103620,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100037:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003b:	c7 04 24 3c 36 10 00 	movl   $0x10363c,(%esp)
  100042:	e8 0b 03 00 00       	call   100352 <cprintf>

    print_kerninfo();
  100047:	e8 29 08 00 00       	call   100875 <print_kerninfo>

    grade_backtrace();
  10004c:	e8 95 00 00 00       	call   1000e6 <grade_backtrace>

    pmm_init(); // init physical memory management
  100051:	e8 76 2a 00 00       	call   102acc <pmm_init>

    pic_init(); // init interrupt controller
  100056:	e8 fe 16 00 00       	call   101759 <pic_init>
    idt_init(); // init interrupt descriptor table
  10005b:	e8 85 18 00 00       	call   1018e5 <idt_init>

    clock_init();  // init clock interrupt
  100060:	e8 3a 0d 00 00       	call   100d9f <clock_init>
    intr_enable(); // enable irq interrupt
  100065:	e8 4d 16 00 00       	call   1016b7 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006a:	e8 98 01 00 00       	call   100207 <lab1_switch_test>

    /* do nothing */
    while (1)
  10006f:	eb fe                	jmp    10006f <kern_init+0x6f>

00100071 <grade_backtrace2>:
        ;
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3)
{
  100071:	55                   	push   %ebp
  100072:	89 e5                	mov    %esp,%ebp
  100074:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  100077:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10007e:	00 
  10007f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100086:	00 
  100087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10008e:	e8 27 0c 00 00       	call   100cba <mon_backtrace>
}
  100093:	90                   	nop
  100094:	89 ec                	mov    %ebp,%esp
  100096:	5d                   	pop    %ebp
  100097:	c3                   	ret    

00100098 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1)
{
  100098:	55                   	push   %ebp
  100099:	89 e5                	mov    %esp,%ebp
  10009b:	83 ec 18             	sub    $0x18,%esp
  10009e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a7:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b9:	89 04 24             	mov    %eax,(%esp)
  1000bc:	e8 b0 ff ff ff       	call   100071 <grade_backtrace2>
}
  1000c1:	90                   	nop
  1000c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2)
{
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1000d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d9:	89 04 24             	mov    %eax,(%esp)
  1000dc:	e8 b7 ff ff ff       	call   100098 <grade_backtrace1>
}
  1000e1:	90                   	nop
  1000e2:	89 ec                	mov    %ebp,%esp
  1000e4:	5d                   	pop    %ebp
  1000e5:	c3                   	ret    

001000e6 <grade_backtrace>:

void grade_backtrace(void)
{
  1000e6:	55                   	push   %ebp
  1000e7:	89 e5                	mov    %esp,%ebp
  1000e9:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000ec:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000f1:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f8:	ff 
  1000f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100104:	e8 c0 ff ff ff       	call   1000c9 <grade_backtrace0>
}
  100109:	90                   	nop
  10010a:	89 ec                	mov    %ebp,%esp
  10010c:	5d                   	pop    %ebp
  10010d:	c3                   	ret    

0010010e <lab1_print_cur_status>:

static void
lab1_print_cur_status(void)
{
  10010e:	55                   	push   %ebp
  10010f:	89 e5                	mov    %esp,%ebp
  100111:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile(
  100114:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100117:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10011a:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10011d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
        "mov %%ds, %1;"
        "mov %%es, %2;"
        "mov %%ss, %3;"
        : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    //"
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100120:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100124:	83 e0 03             	and    $0x3,%eax
  100127:	89 c2                	mov    %eax,%edx
  100129:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10012e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100132:	89 44 24 04          	mov    %eax,0x4(%esp)
  100136:	c7 04 24 41 36 10 00 	movl   $0x103641,(%esp)
  10013d:	e8 10 02 00 00       	call   100352 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100142:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100146:	89 c2                	mov    %eax,%edx
  100148:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10014d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100151:	89 44 24 04          	mov    %eax,0x4(%esp)
  100155:	c7 04 24 4f 36 10 00 	movl   $0x10364f,(%esp)
  10015c:	e8 f1 01 00 00       	call   100352 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100161:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100165:	89 c2                	mov    %eax,%edx
  100167:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10016c:	89 54 24 08          	mov    %edx,0x8(%esp)
  100170:	89 44 24 04          	mov    %eax,0x4(%esp)
  100174:	c7 04 24 5d 36 10 00 	movl   $0x10365d,(%esp)
  10017b:	e8 d2 01 00 00       	call   100352 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  100180:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100184:	89 c2                	mov    %eax,%edx
  100186:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10018b:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100193:	c7 04 24 6b 36 10 00 	movl   $0x10366b,(%esp)
  10019a:	e8 b3 01 00 00       	call   100352 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001a3:	89 c2                	mov    %eax,%edx
  1001a5:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b2:	c7 04 24 79 36 10 00 	movl   $0x103679,(%esp)
  1001b9:	e8 94 01 00 00       	call   100352 <cprintf>
    round++;
  1001be:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001c3:	40                   	inc    %eax
  1001c4:	a3 20 fa 10 00       	mov    %eax,0x10fa20
}
  1001c9:	90                   	nop
  1001ca:	89 ec                	mov    %ebp,%esp
  1001cc:	5d                   	pop    %ebp
  1001cd:	c3                   	ret    

001001ce <lab1_switch_to_user>:

static void
lab1_switch_to_user(void)
{
  1001ce:	55                   	push   %ebp
  1001cf:	89 e5                	mov    %esp,%ebp
  1001d1:	83 ec 14             	sub    $0x14,%esp
  1001d4:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    //LAB1 CHALLENGE 1 : TODO
    int16_t ss;
    int32_t esp;
    asm volatile(
  1001d7:	66 8c d0             	mov    %ss,%ax
  1001da:	89 e3                	mov    %esp,%ebx
  1001dc:	89 da                	mov    %ebx,%edx
  1001de:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  1001e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
        "movw %%ss, %0\n\t"
        "movl %%esp, %1"
        : "=a"(ss), "=b"(esp));
    asm volatile(
  1001e5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1001e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1001ec:	89 d3                	mov    %edx,%ebx
  1001ee:	66 6a 00             	pushw  $0x0
  1001f1:	66 50                	push   %ax
  1001f3:	53                   	push   %ebx
  1001f4:	cd 78                	int    $0x78
        "pushw %0;"
        "pushl %1;"
        "int %2"
        :
        : "a"(ss), "b"(esp), "i"(T_SWITCH_TOU));
}
  1001f6:	90                   	nop
  1001f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1001fa:	89 ec                	mov    %ebp,%esp
  1001fc:	5d                   	pop    %ebp
  1001fd:	c3                   	ret    

001001fe <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void)
{
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile(
  100201:	cd 79                	int    $0x79
  100203:	5c                   	pop    %esp
        "int %0\n\t" // 使用int指令产生软中断
        "popl %%esp;" // 恢复esp
        :
        : "i"(T_SWITCH_TOK));
}
  100204:	90                   	nop
  100205:	5d                   	pop    %ebp
  100206:	c3                   	ret    

00100207 <lab1_switch_test>:

static void
lab1_switch_test(void)
{
  100207:	55                   	push   %ebp
  100208:	89 e5                	mov    %esp,%ebp
  10020a:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020d:	e8 fc fe ff ff       	call   10010e <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100212:	c7 04 24 88 36 10 00 	movl   $0x103688,(%esp)
  100219:	e8 34 01 00 00       	call   100352 <cprintf>
    lab1_switch_to_user();
  10021e:	e8 ab ff ff ff       	call   1001ce <lab1_switch_to_user>
    lab1_print_cur_status();
  100223:	e8 e6 fe ff ff       	call   10010e <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100228:	c7 04 24 a8 36 10 00 	movl   $0x1036a8,(%esp)
  10022f:	e8 1e 01 00 00       	call   100352 <cprintf>
    lab1_switch_to_kernel();
  100234:	e8 c5 ff ff ff       	call   1001fe <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100239:	e8 d0 fe ff ff       	call   10010e <lab1_print_cur_status>
}
  10023e:	90                   	nop
  10023f:	89 ec                	mov    %ebp,%esp
  100241:	5d                   	pop    %ebp
  100242:	c3                   	ret    

00100243 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100243:	55                   	push   %ebp
  100244:	89 e5                	mov    %esp,%ebp
  100246:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100249:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10024d:	74 13                	je     100262 <readline+0x1f>
        cprintf("%s", prompt);
  10024f:	8b 45 08             	mov    0x8(%ebp),%eax
  100252:	89 44 24 04          	mov    %eax,0x4(%esp)
  100256:	c7 04 24 c7 36 10 00 	movl   $0x1036c7,(%esp)
  10025d:	e8 f0 00 00 00       	call   100352 <cprintf>
    }
    int i = 0, c;
  100262:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100269:	e8 73 01 00 00       	call   1003e1 <getchar>
  10026e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100271:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100275:	79 07                	jns    10027e <readline+0x3b>
            return NULL;
  100277:	b8 00 00 00 00       	mov    $0x0,%eax
  10027c:	eb 78                	jmp    1002f6 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10027e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100282:	7e 28                	jle    1002ac <readline+0x69>
  100284:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028b:	7f 1f                	jg     1002ac <readline+0x69>
            cputchar(c);
  10028d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100290:	89 04 24             	mov    %eax,(%esp)
  100293:	e8 e2 00 00 00       	call   10037a <cputchar>
            buf[i ++] = c;
  100298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029b:	8d 50 01             	lea    0x1(%eax),%edx
  10029e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a4:	88 90 40 fa 10 00    	mov    %dl,0x10fa40(%eax)
  1002aa:	eb 45                	jmp    1002f1 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002ac:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b0:	75 16                	jne    1002c8 <readline+0x85>
  1002b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002b6:	7e 10                	jle    1002c8 <readline+0x85>
            cputchar(c);
  1002b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bb:	89 04 24             	mov    %eax,(%esp)
  1002be:	e8 b7 00 00 00       	call   10037a <cputchar>
            i --;
  1002c3:	ff 4d f4             	decl   -0xc(%ebp)
  1002c6:	eb 29                	jmp    1002f1 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002c8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002cc:	74 06                	je     1002d4 <readline+0x91>
  1002ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d2:	75 95                	jne    100269 <readline+0x26>
            cputchar(c);
  1002d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002d7:	89 04 24             	mov    %eax,(%esp)
  1002da:	e8 9b 00 00 00       	call   10037a <cputchar>
            buf[i] = '\0';
  1002df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e2:	05 40 fa 10 00       	add    $0x10fa40,%eax
  1002e7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ea:	b8 40 fa 10 00       	mov    $0x10fa40,%eax
  1002ef:	eb 05                	jmp    1002f6 <readline+0xb3>
        c = getchar();
  1002f1:	e9 73 ff ff ff       	jmp    100269 <readline+0x26>
        }
    }
}
  1002f6:	89 ec                	mov    %ebp,%esp
  1002f8:	5d                   	pop    %ebp
  1002f9:	c3                   	ret    

001002fa <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fa:	55                   	push   %ebp
  1002fb:	89 e5                	mov    %esp,%ebp
  1002fd:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100300:	8b 45 08             	mov    0x8(%ebp),%eax
  100303:	89 04 24             	mov    %eax,(%esp)
  100306:	e8 22 13 00 00       	call   10162d <cons_putc>
    (*cnt) ++;
  10030b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10030e:	8b 00                	mov    (%eax),%eax
  100310:	8d 50 01             	lea    0x1(%eax),%edx
  100313:	8b 45 0c             	mov    0xc(%ebp),%eax
  100316:	89 10                	mov    %edx,(%eax)
}
  100318:	90                   	nop
  100319:	89 ec                	mov    %ebp,%esp
  10031b:	5d                   	pop    %ebp
  10031c:	c3                   	ret    

0010031d <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10031d:	55                   	push   %ebp
  10031e:	89 e5                	mov    %esp,%ebp
  100320:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100323:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10032d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100331:	8b 45 08             	mov    0x8(%ebp),%eax
  100334:	89 44 24 08          	mov    %eax,0x8(%esp)
  100338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10033f:	c7 04 24 fa 02 10 00 	movl   $0x1002fa,(%esp)
  100346:	e8 55 29 00 00       	call   102ca0 <vprintfmt>
    return cnt;
  10034b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10034e:	89 ec                	mov    %ebp,%esp
  100350:	5d                   	pop    %ebp
  100351:	c3                   	ret    

00100352 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100352:	55                   	push   %ebp
  100353:	89 e5                	mov    %esp,%ebp
  100355:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100358:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10035e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100361:	89 44 24 04          	mov    %eax,0x4(%esp)
  100365:	8b 45 08             	mov    0x8(%ebp),%eax
  100368:	89 04 24             	mov    %eax,(%esp)
  10036b:	e8 ad ff ff ff       	call   10031d <vcprintf>
  100370:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100373:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100376:	89 ec                	mov    %ebp,%esp
  100378:	5d                   	pop    %ebp
  100379:	c3                   	ret    

0010037a <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037a:	55                   	push   %ebp
  10037b:	89 e5                	mov    %esp,%ebp
  10037d:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100380:	8b 45 08             	mov    0x8(%ebp),%eax
  100383:	89 04 24             	mov    %eax,(%esp)
  100386:	e8 a2 12 00 00       	call   10162d <cons_putc>
}
  10038b:	90                   	nop
  10038c:	89 ec                	mov    %ebp,%esp
  10038e:	5d                   	pop    %ebp
  10038f:	c3                   	ret    

00100390 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100390:	55                   	push   %ebp
  100391:	89 e5                	mov    %esp,%ebp
  100393:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10039d:	eb 13                	jmp    1003b2 <cputs+0x22>
        cputch(c, &cnt);
  10039f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a3:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003aa:	89 04 24             	mov    %eax,(%esp)
  1003ad:	e8 48 ff ff ff       	call   1002fa <cputch>
    while ((c = *str ++) != '\0') {
  1003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b5:	8d 50 01             	lea    0x1(%eax),%edx
  1003b8:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bb:	0f b6 00             	movzbl (%eax),%eax
  1003be:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c5:	75 d8                	jne    10039f <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003ce:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d5:	e8 20 ff ff ff       	call   1002fa <cputch>
    return cnt;
  1003da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003dd:	89 ec                	mov    %ebp,%esp
  1003df:	5d                   	pop    %ebp
  1003e0:	c3                   	ret    

001003e1 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e1:	55                   	push   %ebp
  1003e2:	89 e5                	mov    %esp,%ebp
  1003e4:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003e7:	90                   	nop
  1003e8:	e8 6c 12 00 00       	call   101659 <cons_getc>
  1003ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f4:	74 f2                	je     1003e8 <getchar+0x7>
        /* do nothing */;
    return c;
  1003f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003f9:	89 ec                	mov    %ebp,%esp
  1003fb:	5d                   	pop    %ebp
  1003fc:	c3                   	ret    

001003fd <stab_binsearch>:
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
               int type, uintptr_t addr)
{
  1003fd:	55                   	push   %ebp
  1003fe:	89 e5                	mov    %esp,%ebp
  100400:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100403:	8b 45 0c             	mov    0xc(%ebp),%eax
  100406:	8b 00                	mov    (%eax),%eax
  100408:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040b:	8b 45 10             	mov    0x10(%ebp),%eax
  10040e:	8b 00                	mov    (%eax),%eax
  100410:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100413:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r)
  10041a:	e9 ca 00 00 00       	jmp    1004e9 <stab_binsearch+0xec>
    {
        int true_m = (l + r) / 2, m = true_m;
  10041f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100422:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100425:	01 d0                	add    %edx,%eax
  100427:	89 c2                	mov    %eax,%edx
  100429:	c1 ea 1f             	shr    $0x1f,%edx
  10042c:	01 d0                	add    %edx,%eax
  10042e:	d1 f8                	sar    %eax
  100430:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100433:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100436:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type)
  100439:	eb 03                	jmp    10043e <stab_binsearch+0x41>
        {
            m--;
  10043b:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type)
  10043e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100441:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100444:	7c 1f                	jl     100465 <stab_binsearch+0x68>
  100446:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100449:	89 d0                	mov    %edx,%eax
  10044b:	01 c0                	add    %eax,%eax
  10044d:	01 d0                	add    %edx,%eax
  10044f:	c1 e0 02             	shl    $0x2,%eax
  100452:	89 c2                	mov    %eax,%edx
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	01 d0                	add    %edx,%eax
  100459:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10045d:	0f b6 c0             	movzbl %al,%eax
  100460:	39 45 14             	cmp    %eax,0x14(%ebp)
  100463:	75 d6                	jne    10043b <stab_binsearch+0x3e>
        }
        if (m < l)
  100465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100468:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046b:	7d 09                	jge    100476 <stab_binsearch+0x79>
        { // no match in [l, m]
            l = true_m + 1;
  10046d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100470:	40                   	inc    %eax
  100471:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100474:	eb 73                	jmp    1004e9 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100476:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr)
  10047d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100480:	89 d0                	mov    %edx,%eax
  100482:	01 c0                	add    %eax,%eax
  100484:	01 d0                	add    %edx,%eax
  100486:	c1 e0 02             	shl    $0x2,%eax
  100489:	89 c2                	mov    %eax,%edx
  10048b:	8b 45 08             	mov    0x8(%ebp),%eax
  10048e:	01 d0                	add    %edx,%eax
  100490:	8b 40 08             	mov    0x8(%eax),%eax
  100493:	39 45 18             	cmp    %eax,0x18(%ebp)
  100496:	76 11                	jbe    1004a9 <stab_binsearch+0xac>
        {
            *region_left = m;
  100498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10049e:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a3:	40                   	inc    %eax
  1004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a7:	eb 40                	jmp    1004e9 <stab_binsearch+0xec>
        }
        else if (stabs[m].n_value > addr)
  1004a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ac:	89 d0                	mov    %edx,%eax
  1004ae:	01 c0                	add    %eax,%eax
  1004b0:	01 d0                	add    %edx,%eax
  1004b2:	c1 e0 02             	shl    $0x2,%eax
  1004b5:	89 c2                	mov    %eax,%edx
  1004b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ba:	01 d0                	add    %edx,%eax
  1004bc:	8b 40 08             	mov    0x8(%eax),%eax
  1004bf:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c2:	73 14                	jae    1004d8 <stab_binsearch+0xdb>
        {
            *region_right = m - 1;
  1004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ca:	8b 45 10             	mov    0x10(%ebp),%eax
  1004cd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d2:	48                   	dec    %eax
  1004d3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d6:	eb 11                	jmp    1004e9 <stab_binsearch+0xec>
        }
        else
        {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004de:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr++;
  1004e6:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r)
  1004e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004ef:	0f 8e 2a ff ff ff    	jle    10041f <stab_binsearch+0x22>
        }
    }

    if (!any_matches)
  1004f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004f9:	75 0f                	jne    10050a <stab_binsearch+0x10d>
    {
        *region_right = *region_left - 1;
  1004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004fe:	8b 00                	mov    (%eax),%eax
  100500:	8d 50 ff             	lea    -0x1(%eax),%edx
  100503:	8b 45 10             	mov    0x10(%ebp),%eax
  100506:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l--)
            /* do nothing */;
        *region_left = l;
    }
}
  100508:	eb 3e                	jmp    100548 <stab_binsearch+0x14b>
        l = *region_right;
  10050a:	8b 45 10             	mov    0x10(%ebp),%eax
  10050d:	8b 00                	mov    (%eax),%eax
  10050f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l--)
  100512:	eb 03                	jmp    100517 <stab_binsearch+0x11a>
  100514:	ff 4d fc             	decl   -0x4(%ebp)
  100517:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051a:	8b 00                	mov    (%eax),%eax
  10051c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  10051f:	7e 1f                	jle    100540 <stab_binsearch+0x143>
  100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100524:	89 d0                	mov    %edx,%eax
  100526:	01 c0                	add    %eax,%eax
  100528:	01 d0                	add    %edx,%eax
  10052a:	c1 e0 02             	shl    $0x2,%eax
  10052d:	89 c2                	mov    %eax,%edx
  10052f:	8b 45 08             	mov    0x8(%ebp),%eax
  100532:	01 d0                	add    %edx,%eax
  100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100538:	0f b6 c0             	movzbl %al,%eax
  10053b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10053e:	75 d4                	jne    100514 <stab_binsearch+0x117>
        *region_left = l;
  100540:	8b 45 0c             	mov    0xc(%ebp),%eax
  100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100546:	89 10                	mov    %edx,(%eax)
}
  100548:	90                   	nop
  100549:	89 ec                	mov    %ebp,%esp
  10054b:	5d                   	pop    %ebp
  10054c:	c3                   	ret    

0010054d <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info)
{
  10054d:	55                   	push   %ebp
  10054e:	89 e5                	mov    %esp,%ebp
  100550:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100553:	8b 45 0c             	mov    0xc(%ebp),%eax
  100556:	c7 00 cc 36 10 00    	movl   $0x1036cc,(%eax)
    info->eip_line = 0;
  10055c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100566:	8b 45 0c             	mov    0xc(%ebp),%eax
  100569:	c7 40 08 cc 36 10 00 	movl   $0x1036cc,0x8(%eax)
    info->eip_fn_namelen = 9;
  100570:	8b 45 0c             	mov    0xc(%ebp),%eax
  100573:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057d:	8b 55 08             	mov    0x8(%ebp),%edx
  100580:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100583:	8b 45 0c             	mov    0xc(%ebp),%eax
  100586:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10058d:	c7 45 f4 4c 3f 10 00 	movl   $0x103f4c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100594:	c7 45 f0 d0 bd 10 00 	movl   $0x10bdd0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059b:	c7 45 ec d1 bd 10 00 	movl   $0x10bdd1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a2:	c7 45 e8 93 e7 10 00 	movl   $0x10e793,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
  1005a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005ac:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005af:	76 0b                	jbe    1005bc <debuginfo_eip+0x6f>
  1005b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b4:	48                   	dec    %eax
  1005b5:	0f b6 00             	movzbl (%eax),%eax
  1005b8:	84 c0                	test   %al,%al
  1005ba:	74 0a                	je     1005c6 <debuginfo_eip+0x79>
    {
        return -1;
  1005bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c1:	e9 ab 02 00 00       	jmp    100871 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d0:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d3:	c1 f8 02             	sar    $0x2,%eax
  1005d6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005dc:	48                   	dec    %eax
  1005dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005e7:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005ee:	00 
  1005ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100600:	89 04 24             	mov    %eax,(%esp)
  100603:	e8 f5 fd ff ff       	call   1003fd <stab_binsearch>
    if (lfile == 0)
  100608:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060b:	85 c0                	test   %eax,%eax
  10060d:	75 0a                	jne    100619 <debuginfo_eip+0xcc>
        return -1;
  10060f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100614:	e9 58 02 00 00       	jmp    100871 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10061c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10061f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100622:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100625:	8b 45 08             	mov    0x8(%ebp),%eax
  100628:	89 44 24 10          	mov    %eax,0x10(%esp)
  10062c:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100633:	00 
  100634:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100637:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  10063e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100645:	89 04 24             	mov    %eax,(%esp)
  100648:	e8 b0 fd ff ff       	call   1003fd <stab_binsearch>

    if (lfun <= rfun)
  10064d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100653:	39 c2                	cmp    %eax,%edx
  100655:	7f 78                	jg     1006cf <debuginfo_eip+0x182>
    {
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr)
  100657:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065a:	89 c2                	mov    %eax,%edx
  10065c:	89 d0                	mov    %edx,%eax
  10065e:	01 c0                	add    %eax,%eax
  100660:	01 d0                	add    %edx,%eax
  100662:	c1 e0 02             	shl    $0x2,%eax
  100665:	89 c2                	mov    %eax,%edx
  100667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066a:	01 d0                	add    %edx,%eax
  10066c:	8b 10                	mov    (%eax),%edx
  10066e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100671:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100674:	39 c2                	cmp    %eax,%edx
  100676:	73 22                	jae    10069a <debuginfo_eip+0x14d>
        {
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100678:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067b:	89 c2                	mov    %eax,%edx
  10067d:	89 d0                	mov    %edx,%eax
  10067f:	01 c0                	add    %eax,%eax
  100681:	01 d0                	add    %edx,%eax
  100683:	c1 e0 02             	shl    $0x2,%eax
  100686:	89 c2                	mov    %eax,%edx
  100688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068b:	01 d0                	add    %edx,%eax
  10068d:	8b 10                	mov    (%eax),%edx
  10068f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100692:	01 c2                	add    %eax,%edx
  100694:	8b 45 0c             	mov    0xc(%ebp),%eax
  100697:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069d:	89 c2                	mov    %eax,%edx
  10069f:	89 d0                	mov    %edx,%eax
  1006a1:	01 c0                	add    %eax,%eax
  1006a3:	01 d0                	add    %edx,%eax
  1006a5:	c1 e0 02             	shl    $0x2,%eax
  1006a8:	89 c2                	mov    %eax,%edx
  1006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006ad:	01 d0                	add    %edx,%eax
  1006af:	8b 50 08             	mov    0x8(%eax),%edx
  1006b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b5:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bb:	8b 40 10             	mov    0x10(%eax),%eax
  1006be:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006cd:	eb 15                	jmp    1006e4 <debuginfo_eip+0x197>
    }
    else
    {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d2:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d5:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006e7:	8b 40 08             	mov    0x8(%eax),%eax
  1006ea:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f1:	00 
  1006f2:	89 04 24             	mov    %eax,(%esp)
  1006f5:	e8 f3 2b 00 00       	call   1032ed <strfind>
  1006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  1006fd:	8b 4a 08             	mov    0x8(%edx),%ecx
  100700:	29 c8                	sub    %ecx,%eax
  100702:	89 c2                	mov    %eax,%edx
  100704:	8b 45 0c             	mov    0xc(%ebp),%eax
  100707:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070a:	8b 45 08             	mov    0x8(%ebp),%eax
  10070d:	89 44 24 10          	mov    %eax,0x10(%esp)
  100711:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100718:	00 
  100719:	8d 45 d0             	lea    -0x30(%ebp),%eax
  10071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100720:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100723:	89 44 24 04          	mov    %eax,0x4(%esp)
  100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072a:	89 04 24             	mov    %eax,(%esp)
  10072d:	e8 cb fc ff ff       	call   1003fd <stab_binsearch>
    if (lline <= rline)
  100732:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100735:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100738:	39 c2                	cmp    %eax,%edx
  10073a:	7f 23                	jg     10075f <debuginfo_eip+0x212>
    {
        info->eip_line = stabs[rline].n_desc;
  10073c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073f:	89 c2                	mov    %eax,%edx
  100741:	89 d0                	mov    %edx,%eax
  100743:	01 c0                	add    %eax,%eax
  100745:	01 d0                	add    %edx,%eax
  100747:	c1 e0 02             	shl    $0x2,%eax
  10074a:	89 c2                	mov    %eax,%edx
  10074c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074f:	01 d0                	add    %edx,%eax
  100751:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100755:	89 c2                	mov    %eax,%edx
  100757:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075a:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
  10075d:	eb 11                	jmp    100770 <debuginfo_eip+0x223>
        return -1;
  10075f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100764:	e9 08 01 00 00       	jmp    100871 <debuginfo_eip+0x324>
    {
        lline--;
  100769:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10076c:	48                   	dec    %eax
  10076d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
  100770:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100776:	39 c2                	cmp    %eax,%edx
  100778:	7c 56                	jl     1007d0 <debuginfo_eip+0x283>
  10077a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10077d:	89 c2                	mov    %eax,%edx
  10077f:	89 d0                	mov    %edx,%eax
  100781:	01 c0                	add    %eax,%eax
  100783:	01 d0                	add    %edx,%eax
  100785:	c1 e0 02             	shl    $0x2,%eax
  100788:	89 c2                	mov    %eax,%edx
  10078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10078d:	01 d0                	add    %edx,%eax
  10078f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100793:	3c 84                	cmp    $0x84,%al
  100795:	74 39                	je     1007d0 <debuginfo_eip+0x283>
  100797:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079a:	89 c2                	mov    %eax,%edx
  10079c:	89 d0                	mov    %edx,%eax
  10079e:	01 c0                	add    %eax,%eax
  1007a0:	01 d0                	add    %edx,%eax
  1007a2:	c1 e0 02             	shl    $0x2,%eax
  1007a5:	89 c2                	mov    %eax,%edx
  1007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007aa:	01 d0                	add    %edx,%eax
  1007ac:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b0:	3c 64                	cmp    $0x64,%al
  1007b2:	75 b5                	jne    100769 <debuginfo_eip+0x21c>
  1007b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b7:	89 c2                	mov    %eax,%edx
  1007b9:	89 d0                	mov    %edx,%eax
  1007bb:	01 c0                	add    %eax,%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	c1 e0 02             	shl    $0x2,%eax
  1007c2:	89 c2                	mov    %eax,%edx
  1007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c7:	01 d0                	add    %edx,%eax
  1007c9:	8b 40 08             	mov    0x8(%eax),%eax
  1007cc:	85 c0                	test   %eax,%eax
  1007ce:	74 99                	je     100769 <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
  1007d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007d6:	39 c2                	cmp    %eax,%edx
  1007d8:	7c 42                	jl     10081c <debuginfo_eip+0x2cf>
  1007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007dd:	89 c2                	mov    %eax,%edx
  1007df:	89 d0                	mov    %edx,%eax
  1007e1:	01 c0                	add    %eax,%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	c1 e0 02             	shl    $0x2,%eax
  1007e8:	89 c2                	mov    %eax,%edx
  1007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ed:	01 d0                	add    %edx,%eax
  1007ef:	8b 10                	mov    (%eax),%edx
  1007f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f4:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007f7:	39 c2                	cmp    %eax,%edx
  1007f9:	73 21                	jae    10081c <debuginfo_eip+0x2cf>
    {
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007fe:	89 c2                	mov    %eax,%edx
  100800:	89 d0                	mov    %edx,%eax
  100802:	01 c0                	add    %eax,%eax
  100804:	01 d0                	add    %edx,%eax
  100806:	c1 e0 02             	shl    $0x2,%eax
  100809:	89 c2                	mov    %eax,%edx
  10080b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10080e:	01 d0                	add    %edx,%eax
  100810:	8b 10                	mov    (%eax),%edx
  100812:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100815:	01 c2                	add    %eax,%edx
  100817:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun)
  10081c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10081f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100822:	39 c2                	cmp    %eax,%edx
  100824:	7d 46                	jge    10086c <debuginfo_eip+0x31f>
    {
        for (lline = lfun + 1;
  100826:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100829:	40                   	inc    %eax
  10082a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10082d:	eb 16                	jmp    100845 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline++)
        {
            info->eip_fn_narg++;
  10082f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100832:	8b 40 14             	mov    0x14(%eax),%eax
  100835:	8d 50 01             	lea    0x1(%eax),%edx
  100838:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083b:	89 50 14             	mov    %edx,0x14(%eax)
             lline++)
  10083e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100841:	40                   	inc    %eax
  100842:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100845:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100848:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  10084b:	39 c2                	cmp    %eax,%edx
  10084d:	7d 1d                	jge    10086c <debuginfo_eip+0x31f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10084f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100852:	89 c2                	mov    %eax,%edx
  100854:	89 d0                	mov    %edx,%eax
  100856:	01 c0                	add    %eax,%eax
  100858:	01 d0                	add    %edx,%eax
  10085a:	c1 e0 02             	shl    $0x2,%eax
  10085d:	89 c2                	mov    %eax,%edx
  10085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100862:	01 d0                	add    %edx,%eax
  100864:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100868:	3c a0                	cmp    $0xa0,%al
  10086a:	74 c3                	je     10082f <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  10086c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100871:	89 ec                	mov    %ebp,%esp
  100873:	5d                   	pop    %ebp
  100874:	c3                   	ret    

00100875 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
  100875:	55                   	push   %ebp
  100876:	89 e5                	mov    %esp,%ebp
  100878:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087b:	c7 04 24 d6 36 10 00 	movl   $0x1036d6,(%esp)
  100882:	e8 cb fa ff ff       	call   100352 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100887:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10088e:	00 
  10088f:	c7 04 24 ef 36 10 00 	movl   $0x1036ef,(%esp)
  100896:	e8 b7 fa ff ff       	call   100352 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089b:	c7 44 24 04 01 36 10 	movl   $0x103601,0x4(%esp)
  1008a2:	00 
  1008a3:	c7 04 24 07 37 10 00 	movl   $0x103707,(%esp)
  1008aa:	e8 a3 fa ff ff       	call   100352 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008af:	c7 44 24 04 16 fa 10 	movl   $0x10fa16,0x4(%esp)
  1008b6:	00 
  1008b7:	c7 04 24 1f 37 10 00 	movl   $0x10371f,(%esp)
  1008be:	e8 8f fa ff ff       	call   100352 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c3:	c7 44 24 04 08 0d 11 	movl   $0x110d08,0x4(%esp)
  1008ca:	00 
  1008cb:	c7 04 24 37 37 10 00 	movl   $0x103737,(%esp)
  1008d2:	e8 7b fa ff ff       	call   100352 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023) / 1024);
  1008d7:	b8 08 0d 11 00       	mov    $0x110d08,%eax
  1008dc:	2d 00 00 10 00       	sub    $0x100000,%eax
  1008e1:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008e6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008ec:	85 c0                	test   %eax,%eax
  1008ee:	0f 48 c2             	cmovs  %edx,%eax
  1008f1:	c1 f8 0a             	sar    $0xa,%eax
  1008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008f8:	c7 04 24 50 37 10 00 	movl   $0x103750,(%esp)
  1008ff:	e8 4e fa ff ff       	call   100352 <cprintf>
}
  100904:	90                   	nop
  100905:	89 ec                	mov    %ebp,%esp
  100907:	5d                   	pop    %ebp
  100908:	c3                   	ret    

00100909 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void print_debuginfo(uintptr_t eip)
{
  100909:	55                   	push   %ebp
  10090a:	89 e5                	mov    %esp,%ebp
  10090c:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0)
  100912:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100915:	89 44 24 04          	mov    %eax,0x4(%esp)
  100919:	8b 45 08             	mov    0x8(%ebp),%eax
  10091c:	89 04 24             	mov    %eax,(%esp)
  10091f:	e8 29 fc ff ff       	call   10054d <debuginfo_eip>
  100924:	85 c0                	test   %eax,%eax
  100926:	74 15                	je     10093d <print_debuginfo+0x34>
    {
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100928:	8b 45 08             	mov    0x8(%ebp),%eax
  10092b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10092f:	c7 04 24 7a 37 10 00 	movl   $0x10377a,(%esp)
  100936:	e8 17 fa ff ff       	call   100352 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093b:	eb 6c                	jmp    1009a9 <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j++)
  10093d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100944:	eb 1b                	jmp    100961 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100946:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10094c:	01 d0                	add    %edx,%eax
  10094e:	0f b6 10             	movzbl (%eax),%edx
  100951:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095a:	01 c8                	add    %ecx,%eax
  10095c:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j++)
  10095e:	ff 45 f4             	incl   -0xc(%ebp)
  100961:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100964:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100967:	7c dd                	jl     100946 <print_debuginfo+0x3d>
        fnname[j] = '\0';
  100969:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  10096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100972:	01 d0                	add    %edx,%eax
  100974:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100977:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097a:	8b 45 08             	mov    0x8(%ebp),%eax
  10097d:	29 d0                	sub    %edx,%eax
  10097f:	89 c1                	mov    %eax,%ecx
  100981:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100984:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100987:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100991:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100995:	89 54 24 08          	mov    %edx,0x8(%esp)
  100999:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099d:	c7 04 24 96 37 10 00 	movl   $0x103796,(%esp)
  1009a4:	e8 a9 f9 ff ff       	call   100352 <cprintf>
}
  1009a9:	90                   	nop
  1009aa:	89 ec                	mov    %ebp,%esp
  1009ac:	5d                   	pop    %ebp
  1009ad:	c3                   	ret    

001009ae <read_eip>:

static __noinline uint32_t
read_eip(void)
{
  1009ae:	55                   	push   %ebp
  1009af:	89 e5                	mov    %esp,%ebp
  1009b1:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0"
  1009b4:	8b 45 04             	mov    0x4(%ebp),%eax
  1009b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
                 : "=r"(eip));
    return eip;
  1009ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009bd:	89 ec                	mov    %ebp,%esp
  1009bf:	5d                   	pop    %ebp
  1009c0:	c3                   	ret    

001009c1 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void print_stackframe(void)
{
  1009c1:	55                   	push   %ebp
  1009c2:	89 e5                	mov    %esp,%ebp
  1009c4:	83 ec 38             	sub    $0x38,%esp
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t eip, ebp;
    eip = read_eip();
  1009c7:	e8 e2 ff ff ff       	call   1009ae <read_eip>
  1009cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009cf:	89 e8                	mov    %ebp,%eax
  1009d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    ebp = read_ebp();
  1009d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  1009da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e1:	eb 7e                	jmp    100a61 <print_stackframe+0xa0>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009f1:	c7 04 24 a8 37 10 00 	movl   $0x1037a8,(%esp)
  1009f8:	e8 55 f9 ff ff       	call   100352 <cprintf>
        for (j = 0; j < 4; j++)
  1009fd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a04:	eb 27                	jmp    100a2d <print_stackframe+0x6c>
        {
            cprintf("0x%08x ", ((uint32_t *)ebp + 2)[j]);
  100a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a13:	01 d0                	add    %edx,%eax
  100a15:	83 c0 08             	add    $0x8,%eax
  100a18:	8b 00                	mov    (%eax),%eax
  100a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a1e:	c7 04 24 c4 37 10 00 	movl   $0x1037c4,(%esp)
  100a25:	e8 28 f9 ff ff       	call   100352 <cprintf>
        for (j = 0; j < 4; j++)
  100a2a:	ff 45 e8             	incl   -0x18(%ebp)
  100a2d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a31:	7e d3                	jle    100a06 <print_stackframe+0x45>
        }
        cprintf("\n");
  100a33:	c7 04 24 cc 37 10 00 	movl   $0x1037cc,(%esp)
  100a3a:	e8 13 f9 ff ff       	call   100352 <cprintf>
        print_debuginfo(eip - 1);
  100a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a42:	48                   	dec    %eax
  100a43:	89 04 24             	mov    %eax,(%esp)
  100a46:	e8 be fe ff ff       	call   100909 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a4e:	83 c0 04             	add    $0x4,%eax
  100a51:	8b 00                	mov    (%eax),%eax
  100a53:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100a56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a59:	8b 00                	mov    (%eax),%eax
  100a5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
  100a5e:	ff 45 ec             	incl   -0x14(%ebp)
  100a61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100a65:	74 0a                	je     100a71 <print_stackframe+0xb0>
  100a67:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a6b:	0f 8e 72 ff ff ff    	jle    1009e3 <print_stackframe+0x22>
        // what the fuck ?
    }
}
  100a71:	90                   	nop
  100a72:	89 ec                	mov    %ebp,%esp
  100a74:	5d                   	pop    %ebp
  100a75:	c3                   	ret    

00100a76 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a76:	55                   	push   %ebp
  100a77:	89 e5                	mov    %esp,%ebp
  100a79:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a83:	eb 0c                	jmp    100a91 <parse+0x1b>
            *buf ++ = '\0';
  100a85:	8b 45 08             	mov    0x8(%ebp),%eax
  100a88:	8d 50 01             	lea    0x1(%eax),%edx
  100a8b:	89 55 08             	mov    %edx,0x8(%ebp)
  100a8e:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a91:	8b 45 08             	mov    0x8(%ebp),%eax
  100a94:	0f b6 00             	movzbl (%eax),%eax
  100a97:	84 c0                	test   %al,%al
  100a99:	74 1d                	je     100ab8 <parse+0x42>
  100a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  100a9e:	0f b6 00             	movzbl (%eax),%eax
  100aa1:	0f be c0             	movsbl %al,%eax
  100aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aa8:	c7 04 24 50 38 10 00 	movl   $0x103850,(%esp)
  100aaf:	e8 05 28 00 00       	call   1032b9 <strchr>
  100ab4:	85 c0                	test   %eax,%eax
  100ab6:	75 cd                	jne    100a85 <parse+0xf>
        }
        if (*buf == '\0') {
  100ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  100abb:	0f b6 00             	movzbl (%eax),%eax
  100abe:	84 c0                	test   %al,%al
  100ac0:	74 65                	je     100b27 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ac2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ac6:	75 14                	jne    100adc <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ac8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100acf:	00 
  100ad0:	c7 04 24 55 38 10 00 	movl   $0x103855,(%esp)
  100ad7:	e8 76 f8 ff ff       	call   100352 <cprintf>
        }
        argv[argc ++] = buf;
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	8d 50 01             	lea    0x1(%eax),%edx
  100ae2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ae5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  100aef:	01 c2                	add    %eax,%edx
  100af1:	8b 45 08             	mov    0x8(%ebp),%eax
  100af4:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100af6:	eb 03                	jmp    100afb <parse+0x85>
            buf ++;
  100af8:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100afb:	8b 45 08             	mov    0x8(%ebp),%eax
  100afe:	0f b6 00             	movzbl (%eax),%eax
  100b01:	84 c0                	test   %al,%al
  100b03:	74 8c                	je     100a91 <parse+0x1b>
  100b05:	8b 45 08             	mov    0x8(%ebp),%eax
  100b08:	0f b6 00             	movzbl (%eax),%eax
  100b0b:	0f be c0             	movsbl %al,%eax
  100b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b12:	c7 04 24 50 38 10 00 	movl   $0x103850,(%esp)
  100b19:	e8 9b 27 00 00       	call   1032b9 <strchr>
  100b1e:	85 c0                	test   %eax,%eax
  100b20:	74 d6                	je     100af8 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b22:	e9 6a ff ff ff       	jmp    100a91 <parse+0x1b>
            break;
  100b27:	90                   	nop
        }
    }
    return argc;
  100b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b2b:	89 ec                	mov    %ebp,%esp
  100b2d:	5d                   	pop    %ebp
  100b2e:	c3                   	ret    

00100b2f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b2f:	55                   	push   %ebp
  100b30:	89 e5                	mov    %esp,%ebp
  100b32:	83 ec 68             	sub    $0x68,%esp
  100b35:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b38:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  100b42:	89 04 24             	mov    %eax,(%esp)
  100b45:	e8 2c ff ff ff       	call   100a76 <parse>
  100b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b51:	75 0a                	jne    100b5d <runcmd+0x2e>
        return 0;
  100b53:	b8 00 00 00 00       	mov    $0x0,%eax
  100b58:	e9 83 00 00 00       	jmp    100be0 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b64:	eb 5a                	jmp    100bc0 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b66:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b69:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b6c:	89 c8                	mov    %ecx,%eax
  100b6e:	01 c0                	add    %eax,%eax
  100b70:	01 c8                	add    %ecx,%eax
  100b72:	c1 e0 02             	shl    $0x2,%eax
  100b75:	05 00 f0 10 00       	add    $0x10f000,%eax
  100b7a:	8b 00                	mov    (%eax),%eax
  100b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b80:	89 04 24             	mov    %eax,(%esp)
  100b83:	e8 95 26 00 00       	call   10321d <strcmp>
  100b88:	85 c0                	test   %eax,%eax
  100b8a:	75 31                	jne    100bbd <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b8f:	89 d0                	mov    %edx,%eax
  100b91:	01 c0                	add    %eax,%eax
  100b93:	01 d0                	add    %edx,%eax
  100b95:	c1 e0 02             	shl    $0x2,%eax
  100b98:	05 08 f0 10 00       	add    $0x10f008,%eax
  100b9d:	8b 10                	mov    (%eax),%edx
  100b9f:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100ba2:	83 c0 04             	add    $0x4,%eax
  100ba5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100ba8:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb6:	89 1c 24             	mov    %ebx,(%esp)
  100bb9:	ff d2                	call   *%edx
  100bbb:	eb 23                	jmp    100be0 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bbd:	ff 45 f4             	incl   -0xc(%ebp)
  100bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bc3:	83 f8 02             	cmp    $0x2,%eax
  100bc6:	76 9e                	jbe    100b66 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bc8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bcf:	c7 04 24 73 38 10 00 	movl   $0x103873,(%esp)
  100bd6:	e8 77 f7 ff ff       	call   100352 <cprintf>
    return 0;
  100bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100be3:	89 ec                	mov    %ebp,%esp
  100be5:	5d                   	pop    %ebp
  100be6:	c3                   	ret    

00100be7 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100be7:	55                   	push   %ebp
  100be8:	89 e5                	mov    %esp,%ebp
  100bea:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bed:	c7 04 24 8c 38 10 00 	movl   $0x10388c,(%esp)
  100bf4:	e8 59 f7 ff ff       	call   100352 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100bf9:	c7 04 24 b4 38 10 00 	movl   $0x1038b4,(%esp)
  100c00:	e8 4d f7 ff ff       	call   100352 <cprintf>

    if (tf != NULL) {
  100c05:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c09:	74 0b                	je     100c16 <kmonitor+0x2f>
        print_trapframe(tf);
  100c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  100c0e:	89 04 24             	mov    %eax,(%esp)
  100c11:	e8 8a 0e 00 00       	call   101aa0 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c16:	c7 04 24 d9 38 10 00 	movl   $0x1038d9,(%esp)
  100c1d:	e8 21 f6 ff ff       	call   100243 <readline>
  100c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c29:	74 eb                	je     100c16 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c35:	89 04 24             	mov    %eax,(%esp)
  100c38:	e8 f2 fe ff ff       	call   100b2f <runcmd>
  100c3d:	85 c0                	test   %eax,%eax
  100c3f:	78 02                	js     100c43 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c41:	eb d3                	jmp    100c16 <kmonitor+0x2f>
                break;
  100c43:	90                   	nop
            }
        }
    }
}
  100c44:	90                   	nop
  100c45:	89 ec                	mov    %ebp,%esp
  100c47:	5d                   	pop    %ebp
  100c48:	c3                   	ret    

00100c49 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c49:	55                   	push   %ebp
  100c4a:	89 e5                	mov    %esp,%ebp
  100c4c:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c56:	eb 3d                	jmp    100c95 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c5b:	89 d0                	mov    %edx,%eax
  100c5d:	01 c0                	add    %eax,%eax
  100c5f:	01 d0                	add    %edx,%eax
  100c61:	c1 e0 02             	shl    $0x2,%eax
  100c64:	05 04 f0 10 00       	add    $0x10f004,%eax
  100c69:	8b 10                	mov    (%eax),%edx
  100c6b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c6e:	89 c8                	mov    %ecx,%eax
  100c70:	01 c0                	add    %eax,%eax
  100c72:	01 c8                	add    %ecx,%eax
  100c74:	c1 e0 02             	shl    $0x2,%eax
  100c77:	05 00 f0 10 00       	add    $0x10f000,%eax
  100c7c:	8b 00                	mov    (%eax),%eax
  100c7e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c86:	c7 04 24 dd 38 10 00 	movl   $0x1038dd,(%esp)
  100c8d:	e8 c0 f6 ff ff       	call   100352 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100c92:	ff 45 f4             	incl   -0xc(%ebp)
  100c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c98:	83 f8 02             	cmp    $0x2,%eax
  100c9b:	76 bb                	jbe    100c58 <mon_help+0xf>
    }
    return 0;
  100c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ca2:	89 ec                	mov    %ebp,%esp
  100ca4:	5d                   	pop    %ebp
  100ca5:	c3                   	ret    

00100ca6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100ca6:	55                   	push   %ebp
  100ca7:	89 e5                	mov    %esp,%ebp
  100ca9:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cac:	e8 c4 fb ff ff       	call   100875 <print_kerninfo>
    return 0;
  100cb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb6:	89 ec                	mov    %ebp,%esp
  100cb8:	5d                   	pop    %ebp
  100cb9:	c3                   	ret    

00100cba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cba:	55                   	push   %ebp
  100cbb:	89 e5                	mov    %esp,%ebp
  100cbd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cc0:	e8 fc fc ff ff       	call   1009c1 <print_stackframe>
    return 0;
  100cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cca:	89 ec                	mov    %ebp,%esp
  100ccc:	5d                   	pop    %ebp
  100ccd:	c3                   	ret    

00100cce <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cce:	55                   	push   %ebp
  100ccf:	89 e5                	mov    %esp,%ebp
  100cd1:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cd4:	a1 40 fe 10 00       	mov    0x10fe40,%eax
  100cd9:	85 c0                	test   %eax,%eax
  100cdb:	75 5b                	jne    100d38 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cdd:	c7 05 40 fe 10 00 01 	movl   $0x1,0x10fe40
  100ce4:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ce7:	8d 45 14             	lea    0x14(%ebp),%eax
  100cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cf0:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cfb:	c7 04 24 e6 38 10 00 	movl   $0x1038e6,(%esp)
  100d02:	e8 4b f6 ff ff       	call   100352 <cprintf>
    vcprintf(fmt, ap);
  100d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d0e:	8b 45 10             	mov    0x10(%ebp),%eax
  100d11:	89 04 24             	mov    %eax,(%esp)
  100d14:	e8 04 f6 ff ff       	call   10031d <vcprintf>
    cprintf("\n");
  100d19:	c7 04 24 02 39 10 00 	movl   $0x103902,(%esp)
  100d20:	e8 2d f6 ff ff       	call   100352 <cprintf>
    
    cprintf("stack trackback:\n");
  100d25:	c7 04 24 04 39 10 00 	movl   $0x103904,(%esp)
  100d2c:	e8 21 f6 ff ff       	call   100352 <cprintf>
    print_stackframe();
  100d31:	e8 8b fc ff ff       	call   1009c1 <print_stackframe>
  100d36:	eb 01                	jmp    100d39 <__panic+0x6b>
        goto panic_dead;
  100d38:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d39:	e8 81 09 00 00       	call   1016bf <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d45:	e8 9d fe ff ff       	call   100be7 <kmonitor>
  100d4a:	eb f2                	jmp    100d3e <__panic+0x70>

00100d4c <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d4c:	55                   	push   %ebp
  100d4d:	89 e5                	mov    %esp,%ebp
  100d4f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d52:	8d 45 14             	lea    0x14(%ebp),%eax
  100d55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d66:	c7 04 24 16 39 10 00 	movl   $0x103916,(%esp)
  100d6d:	e8 e0 f5 ff ff       	call   100352 <cprintf>
    vcprintf(fmt, ap);
  100d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d75:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d79:	8b 45 10             	mov    0x10(%ebp),%eax
  100d7c:	89 04 24             	mov    %eax,(%esp)
  100d7f:	e8 99 f5 ff ff       	call   10031d <vcprintf>
    cprintf("\n");
  100d84:	c7 04 24 02 39 10 00 	movl   $0x103902,(%esp)
  100d8b:	e8 c2 f5 ff ff       	call   100352 <cprintf>
    va_end(ap);
}
  100d90:	90                   	nop
  100d91:	89 ec                	mov    %ebp,%esp
  100d93:	5d                   	pop    %ebp
  100d94:	c3                   	ret    

00100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d95:	55                   	push   %ebp
  100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d98:	a1 40 fe 10 00       	mov    0x10fe40,%eax
}
  100d9d:	5d                   	pop    %ebp
  100d9e:	c3                   	ret    

00100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d9f:	55                   	push   %ebp
  100da0:	89 e5                	mov    %esp,%ebp
  100da2:	83 ec 28             	sub    $0x28,%esp
  100da5:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dab:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100daf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100db3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
}
  100db8:	90                   	nop
  100db9:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dbf:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dc3:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dc7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dcb:	ee                   	out    %al,(%dx)
}
  100dcc:	90                   	nop
  100dcd:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dd3:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dd7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100ddb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100ddf:	ee                   	out    %al,(%dx)
}
  100de0:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100de1:	c7 05 44 fe 10 00 00 	movl   $0x0,0x10fe44
  100de8:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100deb:	c7 04 24 34 39 10 00 	movl   $0x103934,(%esp)
  100df2:	e8 5b f5 ff ff       	call   100352 <cprintf>
    pic_enable(IRQ_TIMER);
  100df7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dfe:	e8 21 09 00 00       	call   101724 <pic_enable>
}
  100e03:	90                   	nop
  100e04:	89 ec                	mov    %ebp,%esp
  100e06:	5d                   	pop    %ebp
  100e07:	c3                   	ret    

00100e08 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e08:	55                   	push   %ebp
  100e09:	89 e5                	mov    %esp,%ebp
  100e0b:	83 ec 10             	sub    $0x10,%esp
  100e0e:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e14:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e18:	89 c2                	mov    %eax,%edx
  100e1a:	ec                   	in     (%dx),%al
  100e1b:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e1e:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e24:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e28:	89 c2                	mov    %eax,%edx
  100e2a:	ec                   	in     (%dx),%al
  100e2b:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e2e:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e34:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e38:	89 c2                	mov    %eax,%edx
  100e3a:	ec                   	in     (%dx),%al
  100e3b:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e3e:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e44:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e48:	89 c2                	mov    %eax,%edx
  100e4a:	ec                   	in     (%dx),%al
  100e4b:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e4e:	90                   	nop
  100e4f:	89 ec                	mov    %ebp,%esp
  100e51:	5d                   	pop    %ebp
  100e52:	c3                   	ret    

00100e53 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e53:	55                   	push   %ebp
  100e54:	89 e5                	mov    %esp,%ebp
  100e56:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e59:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e60:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e63:	0f b7 00             	movzwl (%eax),%eax
  100e66:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e6d:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e72:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e75:	0f b7 00             	movzwl (%eax),%eax
  100e78:	0f b7 c0             	movzwl %ax,%eax
  100e7b:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e80:	74 12                	je     100e94 <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e82:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e89:	66 c7 05 66 fe 10 00 	movw   $0x3b4,0x10fe66
  100e90:	b4 03 
  100e92:	eb 13                	jmp    100ea7 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e97:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e9b:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e9e:	66 c7 05 66 fe 10 00 	movw   $0x3d4,0x10fe66
  100ea5:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100ea7:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100eae:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100eb2:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eb6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100eba:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ebe:	ee                   	out    %al,(%dx)
}
  100ebf:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100ec0:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ec7:	40                   	inc    %eax
  100ec8:	0f b7 c0             	movzwl %ax,%eax
  100ecb:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ecf:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100ed3:	89 c2                	mov    %eax,%edx
  100ed5:	ec                   	in     (%dx),%al
  100ed6:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100ed9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100edd:	0f b6 c0             	movzbl %al,%eax
  100ee0:	c1 e0 08             	shl    $0x8,%eax
  100ee3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ee6:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100eed:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100ef1:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ef5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ef9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100efd:	ee                   	out    %al,(%dx)
}
  100efe:	90                   	nop
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100eff:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f06:	40                   	inc    %eax
  100f07:	0f b7 c0             	movzwl %ax,%eax
  100f0a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f0e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f12:	89 c2                	mov    %eax,%edx
  100f14:	ec                   	in     (%dx),%al
  100f15:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f18:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f1c:	0f b6 c0             	movzbl %al,%eax
  100f1f:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f25:	a3 60 fe 10 00       	mov    %eax,0x10fe60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f2d:	0f b7 c0             	movzwl %ax,%eax
  100f30:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
}
  100f36:	90                   	nop
  100f37:	89 ec                	mov    %ebp,%esp
  100f39:	5d                   	pop    %ebp
  100f3a:	c3                   	ret    

00100f3b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f3b:	55                   	push   %ebp
  100f3c:	89 e5                	mov    %esp,%ebp
  100f3e:	83 ec 48             	sub    $0x48,%esp
  100f41:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f47:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f4b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f4f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f53:	ee                   	out    %al,(%dx)
}
  100f54:	90                   	nop
  100f55:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f5b:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f5f:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100f63:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100f67:	ee                   	out    %al,(%dx)
}
  100f68:	90                   	nop
  100f69:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100f6f:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f73:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100f77:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100f7b:	ee                   	out    %al,(%dx)
}
  100f7c:	90                   	nop
  100f7d:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f83:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f87:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f8b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f8f:	ee                   	out    %al,(%dx)
}
  100f90:	90                   	nop
  100f91:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100f97:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f9b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f9f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fa3:	ee                   	out    %al,(%dx)
}
  100fa4:	90                   	nop
  100fa5:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fab:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100faf:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fb3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fb7:	ee                   	out    %al,(%dx)
}
  100fb8:	90                   	nop
  100fb9:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fbf:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fc3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fc7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fcb:	ee                   	out    %al,(%dx)
}
  100fcc:	90                   	nop
  100fcd:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fd3:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100fd7:	89 c2                	mov    %eax,%edx
  100fd9:	ec                   	in     (%dx),%al
  100fda:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100fdd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fe1:	3c ff                	cmp    $0xff,%al
  100fe3:	0f 95 c0             	setne  %al
  100fe6:	0f b6 c0             	movzbl %al,%eax
  100fe9:	a3 68 fe 10 00       	mov    %eax,0x10fe68
  100fee:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ff4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ff8:	89 c2                	mov    %eax,%edx
  100ffa:	ec                   	in     (%dx),%al
  100ffb:	88 45 f1             	mov    %al,-0xf(%ebp)
  100ffe:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101004:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101008:	89 c2                	mov    %eax,%edx
  10100a:	ec                   	in     (%dx),%al
  10100b:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10100e:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101013:	85 c0                	test   %eax,%eax
  101015:	74 0c                	je     101023 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101017:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10101e:	e8 01 07 00 00       	call   101724 <pic_enable>
    }
}
  101023:	90                   	nop
  101024:	89 ec                	mov    %ebp,%esp
  101026:	5d                   	pop    %ebp
  101027:	c3                   	ret    

00101028 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101028:	55                   	push   %ebp
  101029:	89 e5                	mov    %esp,%ebp
  10102b:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10102e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101035:	eb 08                	jmp    10103f <lpt_putc_sub+0x17>
        delay();
  101037:	e8 cc fd ff ff       	call   100e08 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10103c:	ff 45 fc             	incl   -0x4(%ebp)
  10103f:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101045:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101049:	89 c2                	mov    %eax,%edx
  10104b:	ec                   	in     (%dx),%al
  10104c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10104f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101053:	84 c0                	test   %al,%al
  101055:	78 09                	js     101060 <lpt_putc_sub+0x38>
  101057:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10105e:	7e d7                	jle    101037 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  101060:	8b 45 08             	mov    0x8(%ebp),%eax
  101063:	0f b6 c0             	movzbl %al,%eax
  101066:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  10106c:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10106f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101073:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101077:	ee                   	out    %al,(%dx)
}
  101078:	90                   	nop
  101079:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10107f:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101083:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101087:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10108b:	ee                   	out    %al,(%dx)
}
  10108c:	90                   	nop
  10108d:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101093:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101097:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10109b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10109f:	ee                   	out    %al,(%dx)
}
  1010a0:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010a1:	90                   	nop
  1010a2:	89 ec                	mov    %ebp,%esp
  1010a4:	5d                   	pop    %ebp
  1010a5:	c3                   	ret    

001010a6 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010a6:	55                   	push   %ebp
  1010a7:	89 e5                	mov    %esp,%ebp
  1010a9:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010ac:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010b0:	74 0d                	je     1010bf <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b5:	89 04 24             	mov    %eax,(%esp)
  1010b8:	e8 6b ff ff ff       	call   101028 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010bd:	eb 24                	jmp    1010e3 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  1010bf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010c6:	e8 5d ff ff ff       	call   101028 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010cb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010d2:	e8 51 ff ff ff       	call   101028 <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010d7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010de:	e8 45 ff ff ff       	call   101028 <lpt_putc_sub>
}
  1010e3:	90                   	nop
  1010e4:	89 ec                	mov    %ebp,%esp
  1010e6:	5d                   	pop    %ebp
  1010e7:	c3                   	ret    

001010e8 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010e8:	55                   	push   %ebp
  1010e9:	89 e5                	mov    %esp,%ebp
  1010eb:	83 ec 38             	sub    $0x38,%esp
  1010ee:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  1010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010f4:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010f9:	85 c0                	test   %eax,%eax
  1010fb:	75 07                	jne    101104 <cga_putc+0x1c>
        c |= 0x0700;
  1010fd:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101104:	8b 45 08             	mov    0x8(%ebp),%eax
  101107:	0f b6 c0             	movzbl %al,%eax
  10110a:	83 f8 0d             	cmp    $0xd,%eax
  10110d:	74 72                	je     101181 <cga_putc+0x99>
  10110f:	83 f8 0d             	cmp    $0xd,%eax
  101112:	0f 8f a3 00 00 00    	jg     1011bb <cga_putc+0xd3>
  101118:	83 f8 08             	cmp    $0x8,%eax
  10111b:	74 0a                	je     101127 <cga_putc+0x3f>
  10111d:	83 f8 0a             	cmp    $0xa,%eax
  101120:	74 4c                	je     10116e <cga_putc+0x86>
  101122:	e9 94 00 00 00       	jmp    1011bb <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101127:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10112e:	85 c0                	test   %eax,%eax
  101130:	0f 84 af 00 00 00    	je     1011e5 <cga_putc+0xfd>
            crt_pos --;
  101136:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10113d:	48                   	dec    %eax
  10113e:	0f b7 c0             	movzwl %ax,%eax
  101141:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101147:	8b 45 08             	mov    0x8(%ebp),%eax
  10114a:	98                   	cwtl   
  10114b:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101150:	98                   	cwtl   
  101151:	83 c8 20             	or     $0x20,%eax
  101154:	98                   	cwtl   
  101155:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  10115b:	0f b7 15 64 fe 10 00 	movzwl 0x10fe64,%edx
  101162:	01 d2                	add    %edx,%edx
  101164:	01 ca                	add    %ecx,%edx
  101166:	0f b7 c0             	movzwl %ax,%eax
  101169:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10116c:	eb 77                	jmp    1011e5 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  10116e:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101175:	83 c0 50             	add    $0x50,%eax
  101178:	0f b7 c0             	movzwl %ax,%eax
  10117b:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101181:	0f b7 1d 64 fe 10 00 	movzwl 0x10fe64,%ebx
  101188:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  10118f:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101194:	89 c8                	mov    %ecx,%eax
  101196:	f7 e2                	mul    %edx
  101198:	c1 ea 06             	shr    $0x6,%edx
  10119b:	89 d0                	mov    %edx,%eax
  10119d:	c1 e0 02             	shl    $0x2,%eax
  1011a0:	01 d0                	add    %edx,%eax
  1011a2:	c1 e0 04             	shl    $0x4,%eax
  1011a5:	29 c1                	sub    %eax,%ecx
  1011a7:	89 ca                	mov    %ecx,%edx
  1011a9:	0f b7 d2             	movzwl %dx,%edx
  1011ac:	89 d8                	mov    %ebx,%eax
  1011ae:	29 d0                	sub    %edx,%eax
  1011b0:	0f b7 c0             	movzwl %ax,%eax
  1011b3:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
        break;
  1011b9:	eb 2b                	jmp    1011e6 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011bb:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  1011c1:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011c8:	8d 50 01             	lea    0x1(%eax),%edx
  1011cb:	0f b7 d2             	movzwl %dx,%edx
  1011ce:	66 89 15 64 fe 10 00 	mov    %dx,0x10fe64
  1011d5:	01 c0                	add    %eax,%eax
  1011d7:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011da:	8b 45 08             	mov    0x8(%ebp),%eax
  1011dd:	0f b7 c0             	movzwl %ax,%eax
  1011e0:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e3:	eb 01                	jmp    1011e6 <cga_putc+0xfe>
        break;
  1011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e6:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011ed:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011f2:	76 5e                	jbe    101252 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f4:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011f9:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011ff:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  101204:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10120b:	00 
  10120c:	89 54 24 04          	mov    %edx,0x4(%esp)
  101210:	89 04 24             	mov    %eax,(%esp)
  101213:	e8 9f 22 00 00       	call   1034b7 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101218:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121f:	eb 15                	jmp    101236 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  101221:	8b 15 60 fe 10 00    	mov    0x10fe60,%edx
  101227:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10122a:	01 c0                	add    %eax,%eax
  10122c:	01 d0                	add    %edx,%eax
  10122e:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101233:	ff 45 f4             	incl   -0xc(%ebp)
  101236:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123d:	7e e2                	jle    101221 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  10123f:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101246:	83 e8 50             	sub    $0x50,%eax
  101249:	0f b7 c0             	movzwl %ax,%eax
  10124c:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101252:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101259:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10125d:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101261:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101265:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101269:	ee                   	out    %al,(%dx)
}
  10126a:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  10126b:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101272:	c1 e8 08             	shr    $0x8,%eax
  101275:	0f b7 c0             	movzwl %ax,%eax
  101278:	0f b6 c0             	movzbl %al,%eax
  10127b:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  101282:	42                   	inc    %edx
  101283:	0f b7 d2             	movzwl %dx,%edx
  101286:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  10128a:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10128d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101291:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101295:	ee                   	out    %al,(%dx)
}
  101296:	90                   	nop
    outb(addr_6845, 15);
  101297:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  10129e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012a2:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a6:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012aa:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012ae:	ee                   	out    %al,(%dx)
}
  1012af:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012b0:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1012b7:	0f b6 c0             	movzbl %al,%eax
  1012ba:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  1012c1:	42                   	inc    %edx
  1012c2:	0f b7 d2             	movzwl %dx,%edx
  1012c5:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  1012c9:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012cc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1012d0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1012d4:	ee                   	out    %al,(%dx)
}
  1012d5:	90                   	nop
}
  1012d6:	90                   	nop
  1012d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1012da:	89 ec                	mov    %ebp,%esp
  1012dc:	5d                   	pop    %ebp
  1012dd:	c3                   	ret    

001012de <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012de:	55                   	push   %ebp
  1012df:	89 e5                	mov    %esp,%ebp
  1012e1:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012eb:	eb 08                	jmp    1012f5 <serial_putc_sub+0x17>
        delay();
  1012ed:	e8 16 fb ff ff       	call   100e08 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f2:	ff 45 fc             	incl   -0x4(%ebp)
  1012f5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1012fb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012ff:	89 c2                	mov    %eax,%edx
  101301:	ec                   	in     (%dx),%al
  101302:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101305:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101309:	0f b6 c0             	movzbl %al,%eax
  10130c:	83 e0 20             	and    $0x20,%eax
  10130f:	85 c0                	test   %eax,%eax
  101311:	75 09                	jne    10131c <serial_putc_sub+0x3e>
  101313:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10131a:	7e d1                	jle    1012ed <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  10131c:	8b 45 08             	mov    0x8(%ebp),%eax
  10131f:	0f b6 c0             	movzbl %al,%eax
  101322:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101328:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10132b:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10132f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101333:	ee                   	out    %al,(%dx)
}
  101334:	90                   	nop
}
  101335:	90                   	nop
  101336:	89 ec                	mov    %ebp,%esp
  101338:	5d                   	pop    %ebp
  101339:	c3                   	ret    

0010133a <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10133a:	55                   	push   %ebp
  10133b:	89 e5                	mov    %esp,%ebp
  10133d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101340:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101344:	74 0d                	je     101353 <serial_putc+0x19>
        serial_putc_sub(c);
  101346:	8b 45 08             	mov    0x8(%ebp),%eax
  101349:	89 04 24             	mov    %eax,(%esp)
  10134c:	e8 8d ff ff ff       	call   1012de <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101351:	eb 24                	jmp    101377 <serial_putc+0x3d>
        serial_putc_sub('\b');
  101353:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10135a:	e8 7f ff ff ff       	call   1012de <serial_putc_sub>
        serial_putc_sub(' ');
  10135f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101366:	e8 73 ff ff ff       	call   1012de <serial_putc_sub>
        serial_putc_sub('\b');
  10136b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101372:	e8 67 ff ff ff       	call   1012de <serial_putc_sub>
}
  101377:	90                   	nop
  101378:	89 ec                	mov    %ebp,%esp
  10137a:	5d                   	pop    %ebp
  10137b:	c3                   	ret    

0010137c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10137c:	55                   	push   %ebp
  10137d:	89 e5                	mov    %esp,%ebp
  10137f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101382:	eb 33                	jmp    1013b7 <cons_intr+0x3b>
        if (c != 0) {
  101384:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101388:	74 2d                	je     1013b7 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10138a:	a1 84 00 11 00       	mov    0x110084,%eax
  10138f:	8d 50 01             	lea    0x1(%eax),%edx
  101392:	89 15 84 00 11 00    	mov    %edx,0x110084
  101398:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10139b:	88 90 80 fe 10 00    	mov    %dl,0x10fe80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013a1:	a1 84 00 11 00       	mov    0x110084,%eax
  1013a6:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013ab:	75 0a                	jne    1013b7 <cons_intr+0x3b>
                cons.wpos = 0;
  1013ad:	c7 05 84 00 11 00 00 	movl   $0x0,0x110084
  1013b4:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1013ba:	ff d0                	call   *%eax
  1013bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013bf:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013c3:	75 bf                	jne    101384 <cons_intr+0x8>
            }
        }
    }
}
  1013c5:	90                   	nop
  1013c6:	90                   	nop
  1013c7:	89 ec                	mov    %ebp,%esp
  1013c9:	5d                   	pop    %ebp
  1013ca:	c3                   	ret    

001013cb <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013cb:	55                   	push   %ebp
  1013cc:	89 e5                	mov    %esp,%ebp
  1013ce:	83 ec 10             	sub    $0x10,%esp
  1013d1:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013d7:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013db:	89 c2                	mov    %eax,%edx
  1013dd:	ec                   	in     (%dx),%al
  1013de:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013e1:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013e5:	0f b6 c0             	movzbl %al,%eax
  1013e8:	83 e0 01             	and    $0x1,%eax
  1013eb:	85 c0                	test   %eax,%eax
  1013ed:	75 07                	jne    1013f6 <serial_proc_data+0x2b>
        return -1;
  1013ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f4:	eb 2a                	jmp    101420 <serial_proc_data+0x55>
  1013f6:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013fc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101400:	89 c2                	mov    %eax,%edx
  101402:	ec                   	in     (%dx),%al
  101403:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101406:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10140a:	0f b6 c0             	movzbl %al,%eax
  10140d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101410:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101414:	75 07                	jne    10141d <serial_proc_data+0x52>
        c = '\b';
  101416:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10141d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101420:	89 ec                	mov    %ebp,%esp
  101422:	5d                   	pop    %ebp
  101423:	c3                   	ret    

00101424 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101424:	55                   	push   %ebp
  101425:	89 e5                	mov    %esp,%ebp
  101427:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  10142a:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10142f:	85 c0                	test   %eax,%eax
  101431:	74 0c                	je     10143f <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101433:	c7 04 24 cb 13 10 00 	movl   $0x1013cb,(%esp)
  10143a:	e8 3d ff ff ff       	call   10137c <cons_intr>
    }
}
  10143f:	90                   	nop
  101440:	89 ec                	mov    %ebp,%esp
  101442:	5d                   	pop    %ebp
  101443:	c3                   	ret    

00101444 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101444:	55                   	push   %ebp
  101445:	89 e5                	mov    %esp,%ebp
  101447:	83 ec 38             	sub    $0x38,%esp
  10144a:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101453:	89 c2                	mov    %eax,%edx
  101455:	ec                   	in     (%dx),%al
  101456:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101459:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  10145d:	0f b6 c0             	movzbl %al,%eax
  101460:	83 e0 01             	and    $0x1,%eax
  101463:	85 c0                	test   %eax,%eax
  101465:	75 0a                	jne    101471 <kbd_proc_data+0x2d>
        return -1;
  101467:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10146c:	e9 56 01 00 00       	jmp    1015c7 <kbd_proc_data+0x183>
  101471:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101477:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10147a:	89 c2                	mov    %eax,%edx
  10147c:	ec                   	in     (%dx),%al
  10147d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101480:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101484:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101487:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10148b:	75 17                	jne    1014a4 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  10148d:	a1 88 00 11 00       	mov    0x110088,%eax
  101492:	83 c8 40             	or     $0x40,%eax
  101495:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  10149a:	b8 00 00 00 00       	mov    $0x0,%eax
  10149f:	e9 23 01 00 00       	jmp    1015c7 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a8:	84 c0                	test   %al,%al
  1014aa:	79 45                	jns    1014f1 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014ac:	a1 88 00 11 00       	mov    0x110088,%eax
  1014b1:	83 e0 40             	and    $0x40,%eax
  1014b4:	85 c0                	test   %eax,%eax
  1014b6:	75 08                	jne    1014c0 <kbd_proc_data+0x7c>
  1014b8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bc:	24 7f                	and    $0x7f,%al
  1014be:	eb 04                	jmp    1014c4 <kbd_proc_data+0x80>
  1014c0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c4:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014cb:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  1014d2:	0c 40                	or     $0x40,%al
  1014d4:	0f b6 c0             	movzbl %al,%eax
  1014d7:	f7 d0                	not    %eax
  1014d9:	89 c2                	mov    %eax,%edx
  1014db:	a1 88 00 11 00       	mov    0x110088,%eax
  1014e0:	21 d0                	and    %edx,%eax
  1014e2:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  1014e7:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ec:	e9 d6 00 00 00       	jmp    1015c7 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014f1:	a1 88 00 11 00       	mov    0x110088,%eax
  1014f6:	83 e0 40             	and    $0x40,%eax
  1014f9:	85 c0                	test   %eax,%eax
  1014fb:	74 11                	je     10150e <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014fd:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101501:	a1 88 00 11 00       	mov    0x110088,%eax
  101506:	83 e0 bf             	and    $0xffffffbf,%eax
  101509:	a3 88 00 11 00       	mov    %eax,0x110088
    }

    shift |= shiftcode[data];
  10150e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101512:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  101519:	0f b6 d0             	movzbl %al,%edx
  10151c:	a1 88 00 11 00       	mov    0x110088,%eax
  101521:	09 d0                	or     %edx,%eax
  101523:	a3 88 00 11 00       	mov    %eax,0x110088
    shift ^= togglecode[data];
  101528:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10152c:	0f b6 80 40 f1 10 00 	movzbl 0x10f140(%eax),%eax
  101533:	0f b6 d0             	movzbl %al,%edx
  101536:	a1 88 00 11 00       	mov    0x110088,%eax
  10153b:	31 d0                	xor    %edx,%eax
  10153d:	a3 88 00 11 00       	mov    %eax,0x110088

    c = charcode[shift & (CTL | SHIFT)][data];
  101542:	a1 88 00 11 00       	mov    0x110088,%eax
  101547:	83 e0 03             	and    $0x3,%eax
  10154a:	8b 14 85 40 f5 10 00 	mov    0x10f540(,%eax,4),%edx
  101551:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101555:	01 d0                	add    %edx,%eax
  101557:	0f b6 00             	movzbl (%eax),%eax
  10155a:	0f b6 c0             	movzbl %al,%eax
  10155d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101560:	a1 88 00 11 00       	mov    0x110088,%eax
  101565:	83 e0 08             	and    $0x8,%eax
  101568:	85 c0                	test   %eax,%eax
  10156a:	74 22                	je     10158e <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  10156c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101570:	7e 0c                	jle    10157e <kbd_proc_data+0x13a>
  101572:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101576:	7f 06                	jg     10157e <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101578:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10157c:	eb 10                	jmp    10158e <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  10157e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101582:	7e 0a                	jle    10158e <kbd_proc_data+0x14a>
  101584:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101588:	7f 04                	jg     10158e <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10158a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10158e:	a1 88 00 11 00       	mov    0x110088,%eax
  101593:	f7 d0                	not    %eax
  101595:	83 e0 06             	and    $0x6,%eax
  101598:	85 c0                	test   %eax,%eax
  10159a:	75 28                	jne    1015c4 <kbd_proc_data+0x180>
  10159c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015a3:	75 1f                	jne    1015c4 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015a5:	c7 04 24 4f 39 10 00 	movl   $0x10394f,(%esp)
  1015ac:	e8 a1 ed ff ff       	call   100352 <cprintf>
  1015b1:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015b7:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1015bb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015bf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1015c2:	ee                   	out    %al,(%dx)
}
  1015c3:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015c7:	89 ec                	mov    %ebp,%esp
  1015c9:	5d                   	pop    %ebp
  1015ca:	c3                   	ret    

001015cb <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015cb:	55                   	push   %ebp
  1015cc:	89 e5                	mov    %esp,%ebp
  1015ce:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015d1:	c7 04 24 44 14 10 00 	movl   $0x101444,(%esp)
  1015d8:	e8 9f fd ff ff       	call   10137c <cons_intr>
}
  1015dd:	90                   	nop
  1015de:	89 ec                	mov    %ebp,%esp
  1015e0:	5d                   	pop    %ebp
  1015e1:	c3                   	ret    

001015e2 <kbd_init>:

static void
kbd_init(void) {
  1015e2:	55                   	push   %ebp
  1015e3:	89 e5                	mov    %esp,%ebp
  1015e5:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e8:	e8 de ff ff ff       	call   1015cb <kbd_intr>
    pic_enable(IRQ_KBD);
  1015ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015f4:	e8 2b 01 00 00       	call   101724 <pic_enable>
}
  1015f9:	90                   	nop
  1015fa:	89 ec                	mov    %ebp,%esp
  1015fc:	5d                   	pop    %ebp
  1015fd:	c3                   	ret    

001015fe <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015fe:	55                   	push   %ebp
  1015ff:	89 e5                	mov    %esp,%ebp
  101601:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101604:	e8 4a f8 ff ff       	call   100e53 <cga_init>
    serial_init();
  101609:	e8 2d f9 ff ff       	call   100f3b <serial_init>
    kbd_init();
  10160e:	e8 cf ff ff ff       	call   1015e2 <kbd_init>
    if (!serial_exists) {
  101613:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101618:	85 c0                	test   %eax,%eax
  10161a:	75 0c                	jne    101628 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10161c:	c7 04 24 5b 39 10 00 	movl   $0x10395b,(%esp)
  101623:	e8 2a ed ff ff       	call   100352 <cprintf>
    }
}
  101628:	90                   	nop
  101629:	89 ec                	mov    %ebp,%esp
  10162b:	5d                   	pop    %ebp
  10162c:	c3                   	ret    

0010162d <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10162d:	55                   	push   %ebp
  10162e:	89 e5                	mov    %esp,%ebp
  101630:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  101633:	8b 45 08             	mov    0x8(%ebp),%eax
  101636:	89 04 24             	mov    %eax,(%esp)
  101639:	e8 68 fa ff ff       	call   1010a6 <lpt_putc>
    cga_putc(c);
  10163e:	8b 45 08             	mov    0x8(%ebp),%eax
  101641:	89 04 24             	mov    %eax,(%esp)
  101644:	e8 9f fa ff ff       	call   1010e8 <cga_putc>
    serial_putc(c);
  101649:	8b 45 08             	mov    0x8(%ebp),%eax
  10164c:	89 04 24             	mov    %eax,(%esp)
  10164f:	e8 e6 fc ff ff       	call   10133a <serial_putc>
}
  101654:	90                   	nop
  101655:	89 ec                	mov    %ebp,%esp
  101657:	5d                   	pop    %ebp
  101658:	c3                   	ret    

00101659 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101659:	55                   	push   %ebp
  10165a:	89 e5                	mov    %esp,%ebp
  10165c:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  10165f:	e8 c0 fd ff ff       	call   101424 <serial_intr>
    kbd_intr();
  101664:	e8 62 ff ff ff       	call   1015cb <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  101669:	8b 15 80 00 11 00    	mov    0x110080,%edx
  10166f:	a1 84 00 11 00       	mov    0x110084,%eax
  101674:	39 c2                	cmp    %eax,%edx
  101676:	74 36                	je     1016ae <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101678:	a1 80 00 11 00       	mov    0x110080,%eax
  10167d:	8d 50 01             	lea    0x1(%eax),%edx
  101680:	89 15 80 00 11 00    	mov    %edx,0x110080
  101686:	0f b6 80 80 fe 10 00 	movzbl 0x10fe80(%eax),%eax
  10168d:	0f b6 c0             	movzbl %al,%eax
  101690:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101693:	a1 80 00 11 00       	mov    0x110080,%eax
  101698:	3d 00 02 00 00       	cmp    $0x200,%eax
  10169d:	75 0a                	jne    1016a9 <cons_getc+0x50>
            cons.rpos = 0;
  10169f:	c7 05 80 00 11 00 00 	movl   $0x0,0x110080
  1016a6:	00 00 00 
        }
        return c;
  1016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016ac:	eb 05                	jmp    1016b3 <cons_getc+0x5a>
    }
    return 0;
  1016ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1016b3:	89 ec                	mov    %ebp,%esp
  1016b5:	5d                   	pop    %ebp
  1016b6:	c3                   	ret    

001016b7 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016b7:	55                   	push   %ebp
  1016b8:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016ba:	fb                   	sti    
}
  1016bb:	90                   	nop
    sti();
}
  1016bc:	90                   	nop
  1016bd:	5d                   	pop    %ebp
  1016be:	c3                   	ret    

001016bf <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016bf:	55                   	push   %ebp
  1016c0:	89 e5                	mov    %esp,%ebp

static inline void
cli(void) {
    asm volatile ("cli");
  1016c2:	fa                   	cli    
}
  1016c3:	90                   	nop
    cli();
}
  1016c4:	90                   	nop
  1016c5:	5d                   	pop    %ebp
  1016c6:	c3                   	ret    

001016c7 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016c7:	55                   	push   %ebp
  1016c8:	89 e5                	mov    %esp,%ebp
  1016ca:	83 ec 14             	sub    $0x14,%esp
  1016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1016d0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016d7:	66 a3 50 f5 10 00    	mov    %ax,0x10f550
    if (did_init) {
  1016dd:	a1 8c 00 11 00       	mov    0x11008c,%eax
  1016e2:	85 c0                	test   %eax,%eax
  1016e4:	74 39                	je     10171f <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  1016e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e9:	0f b6 c0             	movzbl %al,%eax
  1016ec:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1016f2:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1016f5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016f9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016fd:	ee                   	out    %al,(%dx)
}
  1016fe:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  1016ff:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101703:	c1 e8 08             	shr    $0x8,%eax
  101706:	0f b7 c0             	movzwl %ax,%eax
  101709:	0f b6 c0             	movzbl %al,%eax
  10170c:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101712:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101715:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101719:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10171d:	ee                   	out    %al,(%dx)
}
  10171e:	90                   	nop
    }
}
  10171f:	90                   	nop
  101720:	89 ec                	mov    %ebp,%esp
  101722:	5d                   	pop    %ebp
  101723:	c3                   	ret    

00101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101724:	55                   	push   %ebp
  101725:	89 e5                	mov    %esp,%ebp
  101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10172a:	8b 45 08             	mov    0x8(%ebp),%eax
  10172d:	ba 01 00 00 00       	mov    $0x1,%edx
  101732:	88 c1                	mov    %al,%cl
  101734:	d3 e2                	shl    %cl,%edx
  101736:	89 d0                	mov    %edx,%eax
  101738:	98                   	cwtl   
  101739:	f7 d0                	not    %eax
  10173b:	0f bf d0             	movswl %ax,%edx
  10173e:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101745:	98                   	cwtl   
  101746:	21 d0                	and    %edx,%eax
  101748:	98                   	cwtl   
  101749:	0f b7 c0             	movzwl %ax,%eax
  10174c:	89 04 24             	mov    %eax,(%esp)
  10174f:	e8 73 ff ff ff       	call   1016c7 <pic_setmask>
}
  101754:	90                   	nop
  101755:	89 ec                	mov    %ebp,%esp
  101757:	5d                   	pop    %ebp
  101758:	c3                   	ret    

00101759 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101759:	55                   	push   %ebp
  10175a:	89 e5                	mov    %esp,%ebp
  10175c:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10175f:	c7 05 8c 00 11 00 01 	movl   $0x1,0x11008c
  101766:	00 00 00 
  101769:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  10176f:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101773:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101777:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10177b:	ee                   	out    %al,(%dx)
}
  10177c:	90                   	nop
  10177d:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101783:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101787:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10178b:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10178f:	ee                   	out    %al,(%dx)
}
  101790:	90                   	nop
  101791:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101797:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10179b:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10179f:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017a3:	ee                   	out    %al,(%dx)
}
  1017a4:	90                   	nop
  1017a5:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017ab:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017af:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017b3:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017b7:	ee                   	out    %al,(%dx)
}
  1017b8:	90                   	nop
  1017b9:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1017bf:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017c3:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017c7:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1017cb:	ee                   	out    %al,(%dx)
}
  1017cc:	90                   	nop
  1017cd:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1017d3:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017d7:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017db:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1017df:	ee                   	out    %al,(%dx)
}
  1017e0:	90                   	nop
  1017e1:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1017e7:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017eb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017ef:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1017f3:	ee                   	out    %al,(%dx)
}
  1017f4:	90                   	nop
  1017f5:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1017fb:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017ff:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101803:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101807:	ee                   	out    %al,(%dx)
}
  101808:	90                   	nop
  101809:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  10180f:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101813:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101817:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10181b:	ee                   	out    %al,(%dx)
}
  10181c:	90                   	nop
  10181d:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101823:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101827:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10182b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10182f:	ee                   	out    %al,(%dx)
}
  101830:	90                   	nop
  101831:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101837:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10183b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10183f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101843:	ee                   	out    %al,(%dx)
}
  101844:	90                   	nop
  101845:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10184b:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10184f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101853:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101857:	ee                   	out    %al,(%dx)
}
  101858:	90                   	nop
  101859:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  10185f:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101863:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101867:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10186b:	ee                   	out    %al,(%dx)
}
  10186c:	90                   	nop
  10186d:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101873:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101877:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10187b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10187f:	ee                   	out    %al,(%dx)
}
  101880:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101881:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101888:	3d ff ff 00 00       	cmp    $0xffff,%eax
  10188d:	74 0f                	je     10189e <pic_init+0x145>
        pic_setmask(irq_mask);
  10188f:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101896:	89 04 24             	mov    %eax,(%esp)
  101899:	e8 29 fe ff ff       	call   1016c7 <pic_setmask>
    }
}
  10189e:	90                   	nop
  10189f:	89 ec                	mov    %ebp,%esp
  1018a1:	5d                   	pop    %ebp
  1018a2:	c3                   	ret    

001018a3 <print_ticks>:
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks()
{
  1018a3:	55                   	push   %ebp
  1018a4:	89 e5                	mov    %esp,%ebp
  1018a6:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n", TICK_NUM);
  1018a9:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018b0:	00 
  1018b1:	c7 04 24 80 39 10 00 	movl   $0x103980,(%esp)
  1018b8:	e8 95 ea ff ff       	call   100352 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018bd:	c7 04 24 8a 39 10 00 	movl   $0x10398a,(%esp)
  1018c4:	e8 89 ea ff ff       	call   100352 <cprintf>
    panic("EOT: kernel seems ok.");
  1018c9:	c7 44 24 08 98 39 10 	movl   $0x103998,0x8(%esp)
  1018d0:	00 
  1018d1:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  1018d8:	00 
  1018d9:	c7 04 24 ae 39 10 00 	movl   $0x1039ae,(%esp)
  1018e0:	e8 e9 f3 ff ff       	call   100cce <__panic>

001018e5 <idt_init>:
static struct pseudodesc idt_pd = {
    sizeof(idt) - 1, (uintptr_t)idt};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void)
{
  1018e5:	55                   	push   %ebp
  1018e6:	89 e5                	mov    %esp,%ebp
  1018e8:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  1018eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018f2:	e9 c4 00 00 00       	jmp    1019bb <idt_init+0xd6>
    {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fa:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101901:	0f b7 d0             	movzwl %ax,%edx
  101904:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101907:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  10190e:	00 
  10190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101912:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  101919:	00 08 00 
  10191c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191f:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101926:	00 
  101927:	80 e2 e0             	and    $0xe0,%dl
  10192a:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101931:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101934:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  10193b:	00 
  10193c:	80 e2 1f             	and    $0x1f,%dl
  10193f:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101946:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101949:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101950:	00 
  101951:	80 e2 f0             	and    $0xf0,%dl
  101954:	80 ca 0e             	or     $0xe,%dl
  101957:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  10195e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101961:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101968:	00 
  101969:	80 e2 ef             	and    $0xef,%dl
  10196c:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101973:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101976:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  10197d:	00 
  10197e:	80 e2 9f             	and    $0x9f,%dl
  101981:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101988:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10198b:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101992:	00 
  101993:	80 ca 80             	or     $0x80,%dl
  101996:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  10199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a0:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1019a7:	c1 e8 10             	shr    $0x10,%eax
  1019aa:	0f b7 d0             	movzwl %ax,%edx
  1019ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b0:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  1019b7:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
  1019b8:	ff 45 fc             	incl   -0x4(%ebp)
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019c3:	0f 86 2e ff ff ff    	jbe    1018f7 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1019c9:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  1019ce:	0f b7 c0             	movzwl %ax,%eax
  1019d1:	66 a3 68 04 11 00    	mov    %ax,0x110468
  1019d7:	66 c7 05 6a 04 11 00 	movw   $0x8,0x11046a
  1019de:	08 00 
  1019e0:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  1019e7:	24 e0                	and    $0xe0,%al
  1019e9:	a2 6c 04 11 00       	mov    %al,0x11046c
  1019ee:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  1019f5:	24 1f                	and    $0x1f,%al
  1019f7:	a2 6c 04 11 00       	mov    %al,0x11046c
  1019fc:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a03:	24 f0                	and    $0xf0,%al
  101a05:	0c 0e                	or     $0xe,%al
  101a07:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a0c:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a13:	24 ef                	and    $0xef,%al
  101a15:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a1a:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a21:	0c 60                	or     $0x60,%al
  101a23:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a28:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a2f:	0c 80                	or     $0x80,%al
  101a31:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a36:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101a3b:	c1 e8 10             	shr    $0x10,%eax
  101a3e:	0f b7 c0             	movzwl %ax,%eax
  101a41:	66 a3 6e 04 11 00    	mov    %ax,0x11046e
  101a47:	c7 45 f8 60 f5 10 00 	movl   $0x10f560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101a51:	0f 01 18             	lidtl  (%eax)
}
  101a54:	90                   	nop
    lidt(&idt_pd);
}
  101a55:	90                   	nop
  101a56:	89 ec                	mov    %ebp,%esp
  101a58:	5d                   	pop    %ebp
  101a59:	c3                   	ret    

00101a5a <trapname>:

static const char *
trapname(int trapno)
{
  101a5a:	55                   	push   %ebp
  101a5b:	89 e5                	mov    %esp,%ebp
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"};

    if (trapno < sizeof(excnames) / sizeof(const char *const))
  101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101a60:	83 f8 13             	cmp    $0x13,%eax
  101a63:	77 0c                	ja     101a71 <trapname+0x17>
    {
        return excnames[trapno];
  101a65:	8b 45 08             	mov    0x8(%ebp),%eax
  101a68:	8b 04 85 00 3d 10 00 	mov    0x103d00(,%eax,4),%eax
  101a6f:	eb 18                	jmp    101a89 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  101a71:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101a75:	7e 0d                	jle    101a84 <trapname+0x2a>
  101a77:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101a7b:	7f 07                	jg     101a84 <trapname+0x2a>
    {
        return "Hardware Interrupt";
  101a7d:	b8 bf 39 10 00       	mov    $0x1039bf,%eax
  101a82:	eb 05                	jmp    101a89 <trapname+0x2f>
    }
    return "(unknown trap)";
  101a84:	b8 d2 39 10 00       	mov    $0x1039d2,%eax
}
  101a89:	5d                   	pop    %ebp
  101a8a:	c3                   	ret    

00101a8b <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf)
{
  101a8b:	55                   	push   %ebp
  101a8c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a91:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a95:	83 f8 08             	cmp    $0x8,%eax
  101a98:	0f 94 c0             	sete   %al
  101a9b:	0f b6 c0             	movzbl %al,%eax
}
  101a9e:	5d                   	pop    %ebp
  101a9f:	c3                   	ret    

00101aa0 <print_trapframe>:
    NULL,
    NULL,
};

void print_trapframe(struct trapframe *tf)
{
  101aa0:	55                   	push   %ebp
  101aa1:	89 e5                	mov    %esp,%ebp
  101aa3:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aad:	c7 04 24 13 3a 10 00 	movl   $0x103a13,(%esp)
  101ab4:	e8 99 e8 ff ff       	call   100352 <cprintf>
    print_regs(&tf->tf_regs);
  101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  101abc:	89 04 24             	mov    %eax,(%esp)
  101abf:	e8 8f 01 00 00       	call   101c53 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac7:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101acb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acf:	c7 04 24 24 3a 10 00 	movl   $0x103a24,(%esp)
  101ad6:	e8 77 e8 ff ff       	call   100352 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101adb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ade:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae6:	c7 04 24 37 3a 10 00 	movl   $0x103a37,(%esp)
  101aed:	e8 60 e8 ff ff       	call   100352 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101af2:	8b 45 08             	mov    0x8(%ebp),%eax
  101af5:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101afd:	c7 04 24 4a 3a 10 00 	movl   $0x103a4a,(%esp)
  101b04:	e8 49 e8 ff ff       	call   100352 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b09:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b10:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b14:	c7 04 24 5d 3a 10 00 	movl   $0x103a5d,(%esp)
  101b1b:	e8 32 e8 ff ff       	call   100352 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b20:	8b 45 08             	mov    0x8(%ebp),%eax
  101b23:	8b 40 30             	mov    0x30(%eax),%eax
  101b26:	89 04 24             	mov    %eax,(%esp)
  101b29:	e8 2c ff ff ff       	call   101a5a <trapname>
  101b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  101b31:	8b 52 30             	mov    0x30(%edx),%edx
  101b34:	89 44 24 08          	mov    %eax,0x8(%esp)
  101b38:	89 54 24 04          	mov    %edx,0x4(%esp)
  101b3c:	c7 04 24 70 3a 10 00 	movl   $0x103a70,(%esp)
  101b43:	e8 0a e8 ff ff       	call   100352 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101b48:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4b:	8b 40 34             	mov    0x34(%eax),%eax
  101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b52:	c7 04 24 82 3a 10 00 	movl   $0x103a82,(%esp)
  101b59:	e8 f4 e7 ff ff       	call   100352 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b61:	8b 40 38             	mov    0x38(%eax),%eax
  101b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b68:	c7 04 24 91 3a 10 00 	movl   $0x103a91,(%esp)
  101b6f:	e8 de e7 ff ff       	call   100352 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101b74:	8b 45 08             	mov    0x8(%ebp),%eax
  101b77:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7f:	c7 04 24 a0 3a 10 00 	movl   $0x103aa0,(%esp)
  101b86:	e8 c7 e7 ff ff       	call   100352 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8e:	8b 40 40             	mov    0x40(%eax),%eax
  101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b95:	c7 04 24 b3 3a 10 00 	movl   $0x103ab3,(%esp)
  101b9c:	e8 b1 e7 ff ff       	call   100352 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1)
  101ba1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ba8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101baf:	eb 3d                	jmp    101bee <print_trapframe+0x14e>
    {
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL)
  101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb4:	8b 50 40             	mov    0x40(%eax),%edx
  101bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101bba:	21 d0                	and    %edx,%eax
  101bbc:	85 c0                	test   %eax,%eax
  101bbe:	74 28                	je     101be8 <print_trapframe+0x148>
  101bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bc3:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101bca:	85 c0                	test   %eax,%eax
  101bcc:	74 1a                	je     101be8 <print_trapframe+0x148>
        {
            cprintf("%s,", IA32flags[i]);
  101bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bd1:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdc:	c7 04 24 c2 3a 10 00 	movl   $0x103ac2,(%esp)
  101be3:	e8 6a e7 ff ff       	call   100352 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1)
  101be8:	ff 45 f4             	incl   -0xc(%ebp)
  101beb:	d1 65 f0             	shll   -0x10(%ebp)
  101bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101bf1:	83 f8 17             	cmp    $0x17,%eax
  101bf4:	76 bb                	jbe    101bb1 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf9:	8b 40 40             	mov    0x40(%eax),%eax
  101bfc:	c1 e8 0c             	shr    $0xc,%eax
  101bff:	83 e0 03             	and    $0x3,%eax
  101c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c06:	c7 04 24 c6 3a 10 00 	movl   $0x103ac6,(%esp)
  101c0d:	e8 40 e7 ff ff       	call   100352 <cprintf>

    if (!trap_in_kernel(tf))
  101c12:	8b 45 08             	mov    0x8(%ebp),%eax
  101c15:	89 04 24             	mov    %eax,(%esp)
  101c18:	e8 6e fe ff ff       	call   101a8b <trap_in_kernel>
  101c1d:	85 c0                	test   %eax,%eax
  101c1f:	75 2d                	jne    101c4e <print_trapframe+0x1ae>
    {
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c21:	8b 45 08             	mov    0x8(%ebp),%eax
  101c24:	8b 40 44             	mov    0x44(%eax),%eax
  101c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2b:	c7 04 24 cf 3a 10 00 	movl   $0x103acf,(%esp)
  101c32:	e8 1b e7 ff ff       	call   100352 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101c37:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3a:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c42:	c7 04 24 de 3a 10 00 	movl   $0x103ade,(%esp)
  101c49:	e8 04 e7 ff ff       	call   100352 <cprintf>
    }
}
  101c4e:	90                   	nop
  101c4f:	89 ec                	mov    %ebp,%esp
  101c51:	5d                   	pop    %ebp
  101c52:	c3                   	ret    

00101c53 <print_regs>:

void print_regs(struct pushregs *regs)
{
  101c53:	55                   	push   %ebp
  101c54:	89 e5                	mov    %esp,%ebp
  101c56:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101c59:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5c:	8b 00                	mov    (%eax),%eax
  101c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c62:	c7 04 24 f1 3a 10 00 	movl   $0x103af1,(%esp)
  101c69:	e8 e4 e6 ff ff       	call   100352 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c71:	8b 40 04             	mov    0x4(%eax),%eax
  101c74:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c78:	c7 04 24 00 3b 10 00 	movl   $0x103b00,(%esp)
  101c7f:	e8 ce e6 ff ff       	call   100352 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c84:	8b 45 08             	mov    0x8(%ebp),%eax
  101c87:	8b 40 08             	mov    0x8(%eax),%eax
  101c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c8e:	c7 04 24 0f 3b 10 00 	movl   $0x103b0f,(%esp)
  101c95:	e8 b8 e6 ff ff       	call   100352 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c9d:	8b 40 0c             	mov    0xc(%eax),%eax
  101ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca4:	c7 04 24 1e 3b 10 00 	movl   $0x103b1e,(%esp)
  101cab:	e8 a2 e6 ff ff       	call   100352 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb3:	8b 40 10             	mov    0x10(%eax),%eax
  101cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cba:	c7 04 24 2d 3b 10 00 	movl   $0x103b2d,(%esp)
  101cc1:	e8 8c e6 ff ff       	call   100352 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc9:	8b 40 14             	mov    0x14(%eax),%eax
  101ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd0:	c7 04 24 3c 3b 10 00 	movl   $0x103b3c,(%esp)
  101cd7:	e8 76 e6 ff ff       	call   100352 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdf:	8b 40 18             	mov    0x18(%eax),%eax
  101ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce6:	c7 04 24 4b 3b 10 00 	movl   $0x103b4b,(%esp)
  101ced:	e8 60 e6 ff ff       	call   100352 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf5:	8b 40 1c             	mov    0x1c(%eax),%eax
  101cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cfc:	c7 04 24 5a 3b 10 00 	movl   $0x103b5a,(%esp)
  101d03:	e8 4a e6 ff ff       	call   100352 <cprintf>
}
  101d08:	90                   	nop
  101d09:	89 ec                	mov    %ebp,%esp
  101d0b:	5d                   	pop    %ebp
  101d0c:	c3                   	ret    

00101d0d <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf)
{
  101d0d:	55                   	push   %ebp
  101d0e:	89 e5                	mov    %esp,%ebp
  101d10:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno)
  101d13:	8b 45 08             	mov    0x8(%ebp),%eax
  101d16:	8b 40 30             	mov    0x30(%eax),%eax
  101d19:	83 f8 79             	cmp    $0x79,%eax
  101d1c:	0f 84 44 01 00 00    	je     101e66 <trap_dispatch+0x159>
  101d22:	83 f8 79             	cmp    $0x79,%eax
  101d25:	0f 87 87 01 00 00    	ja     101eb2 <trap_dispatch+0x1a5>
  101d2b:	83 f8 78             	cmp    $0x78,%eax
  101d2e:	0f 84 d0 00 00 00    	je     101e04 <trap_dispatch+0xf7>
  101d34:	83 f8 78             	cmp    $0x78,%eax
  101d37:	0f 87 75 01 00 00    	ja     101eb2 <trap_dispatch+0x1a5>
  101d3d:	83 f8 2f             	cmp    $0x2f,%eax
  101d40:	0f 87 6c 01 00 00    	ja     101eb2 <trap_dispatch+0x1a5>
  101d46:	83 f8 2e             	cmp    $0x2e,%eax
  101d49:	0f 83 98 01 00 00    	jae    101ee7 <trap_dispatch+0x1da>
  101d4f:	83 f8 24             	cmp    $0x24,%eax
  101d52:	74 5e                	je     101db2 <trap_dispatch+0xa5>
  101d54:	83 f8 24             	cmp    $0x24,%eax
  101d57:	0f 87 55 01 00 00    	ja     101eb2 <trap_dispatch+0x1a5>
  101d5d:	83 f8 20             	cmp    $0x20,%eax
  101d60:	74 0a                	je     101d6c <trap_dispatch+0x5f>
  101d62:	83 f8 21             	cmp    $0x21,%eax
  101d65:	74 74                	je     101ddb <trap_dispatch+0xce>
  101d67:	e9 46 01 00 00       	jmp    101eb2 <trap_dispatch+0x1a5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
  101d6c:	a1 44 fe 10 00       	mov    0x10fe44,%eax
  101d71:	40                   	inc    %eax
  101d72:	a3 44 fe 10 00       	mov    %eax,0x10fe44
        if (ticks % TICK_NUM == 0)
  101d77:	8b 0d 44 fe 10 00    	mov    0x10fe44,%ecx
  101d7d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101d82:	89 c8                	mov    %ecx,%eax
  101d84:	f7 e2                	mul    %edx
  101d86:	c1 ea 05             	shr    $0x5,%edx
  101d89:	89 d0                	mov    %edx,%eax
  101d8b:	c1 e0 02             	shl    $0x2,%eax
  101d8e:	01 d0                	add    %edx,%eax
  101d90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101d97:	01 d0                	add    %edx,%eax
  101d99:	c1 e0 02             	shl    $0x2,%eax
  101d9c:	29 c1                	sub    %eax,%ecx
  101d9e:	89 ca                	mov    %ecx,%edx
  101da0:	85 d2                	test   %edx,%edx
  101da2:	0f 85 42 01 00 00    	jne    101eea <trap_dispatch+0x1dd>
        {
            print_ticks();
  101da8:	e8 f6 fa ff ff       	call   1018a3 <print_ticks>
        }
        break;
  101dad:	e9 38 01 00 00       	jmp    101eea <trap_dispatch+0x1dd>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101db2:	e8 a2 f8 ff ff       	call   101659 <cons_getc>
  101db7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101dba:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101dbe:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
  101dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dca:	c7 04 24 69 3b 10 00 	movl   $0x103b69,(%esp)
  101dd1:	e8 7c e5 ff ff       	call   100352 <cprintf>
        break;
  101dd6:	e9 10 01 00 00       	jmp    101eeb <trap_dispatch+0x1de>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101ddb:	e8 79 f8 ff ff       	call   101659 <cons_getc>
  101de0:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101de3:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101de7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101deb:	89 54 24 08          	mov    %edx,0x8(%esp)
  101def:	89 44 24 04          	mov    %eax,0x4(%esp)
  101df3:	c7 04 24 7b 3b 10 00 	movl   $0x103b7b,(%esp)
  101dfa:	e8 53 e5 ff ff       	call   100352 <cprintf>
        break;
  101dff:	e9 e7 00 00 00       	jmp    101eeb <trap_dispatch+0x1de>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        tf->tf_eflags |= FL_IOPL_MASK;
  101e04:	8b 45 08             	mov    0x8(%ebp),%eax
  101e07:	8b 40 40             	mov    0x40(%eax),%eax
  101e0a:	0d 00 30 00 00       	or     $0x3000,%eax
  101e0f:	89 c2                	mov    %eax,%edx
  101e11:	8b 45 08             	mov    0x8(%ebp),%eax
  101e14:	89 50 40             	mov    %edx,0x40(%eax)
        tf->tf_cs = USER_CS;
  101e17:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1a:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = USER_DS;
  101e20:	8b 45 08             	mov    0x8(%ebp),%eax
  101e23:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
  101e29:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2c:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  101e30:	8b 45 08             	mov    0x8(%ebp),%eax
  101e33:	66 89 50 48          	mov    %dx,0x48(%eax)
  101e37:	8b 45 08             	mov    0x8(%ebp),%eax
  101e3a:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e41:	66 89 50 20          	mov    %dx,0x20(%eax)
  101e45:	8b 45 08             	mov    0x8(%ebp),%eax
  101e48:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  101e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e4f:	66 89 50 28          	mov    %dx,0x28(%eax)
  101e53:	8b 45 08             	mov    0x8(%ebp),%eax
  101e56:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5d:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        break;
  101e61:	e9 85 00 00 00       	jmp    101eeb <trap_dispatch+0x1de>
    case T_SWITCH_TOK:
        tf->tf_cs = KERNEL_CS;
  101e66:	8b 45 08             	mov    0x8(%ebp),%eax
  101e69:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = KERNEL_DS;
  101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e72:	66 c7 40 24 10 00    	movw   $0x10,0x24(%eax)
  101e78:	8b 45 08             	mov    0x8(%ebp),%eax
  101e7b:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e82:	66 89 50 48          	mov    %dx,0x48(%eax)
  101e86:	8b 45 08             	mov    0x8(%ebp),%eax
  101e89:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  101e90:	66 89 50 20          	mov    %dx,0x20(%eax)
  101e94:	8b 45 08             	mov    0x8(%ebp),%eax
  101e97:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9e:	66 89 50 28          	mov    %dx,0x28(%eax)
  101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea5:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  101eac:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        break;
  101eb0:	eb 39                	jmp    101eeb <trap_dispatch+0x1de>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0)
  101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101eb9:	83 e0 03             	and    $0x3,%eax
  101ebc:	85 c0                	test   %eax,%eax
  101ebe:	75 2b                	jne    101eeb <trap_dispatch+0x1de>
        {
            print_trapframe(tf);
  101ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec3:	89 04 24             	mov    %eax,(%esp)
  101ec6:	e8 d5 fb ff ff       	call   101aa0 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101ecb:	c7 44 24 08 8a 3b 10 	movl   $0x103b8a,0x8(%esp)
  101ed2:	00 
  101ed3:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
  101eda:	00 
  101edb:	c7 04 24 ae 39 10 00 	movl   $0x1039ae,(%esp)
  101ee2:	e8 e7 ed ff ff       	call   100cce <__panic>
        break;
  101ee7:	90                   	nop
  101ee8:	eb 01                	jmp    101eeb <trap_dispatch+0x1de>
        break;
  101eea:	90                   	nop
        }
    }
}
  101eeb:	90                   	nop
  101eec:	89 ec                	mov    %ebp,%esp
  101eee:	5d                   	pop    %ebp
  101eef:	c3                   	ret    

00101ef0 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
  101ef0:	55                   	push   %ebp
  101ef1:	89 e5                	mov    %esp,%ebp
  101ef3:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef9:	89 04 24             	mov    %eax,(%esp)
  101efc:	e8 0c fe ff ff       	call   101d0d <trap_dispatch>
}
  101f01:	90                   	nop
  101f02:	89 ec                	mov    %ebp,%esp
  101f04:	5d                   	pop    %ebp
  101f05:	c3                   	ret    

00101f06 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101f06:	1e                   	push   %ds
    pushl %es
  101f07:	06                   	push   %es
    pushl %fs
  101f08:	0f a0                	push   %fs
    pushl %gs
  101f0a:	0f a8                	push   %gs
    pushal
  101f0c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101f0d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101f12:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101f14:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101f16:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101f17:	e8 d4 ff ff ff       	call   101ef0 <trap>

    # pop the pushed stack pointer
    popl %esp
  101f1c:	5c                   	pop    %esp

00101f1d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101f1d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101f1e:	0f a9                	pop    %gs
    popl %fs
  101f20:	0f a1                	pop    %fs
    popl %es
  101f22:	07                   	pop    %es
    popl %ds
  101f23:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101f24:	83 c4 08             	add    $0x8,%esp
    iret
  101f27:	cf                   	iret   

00101f28 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f28:	6a 00                	push   $0x0
  pushl $0
  101f2a:	6a 00                	push   $0x0
  jmp __alltraps
  101f2c:	e9 d5 ff ff ff       	jmp    101f06 <__alltraps>

00101f31 <vector1>:
.globl vector1
vector1:
  pushl $0
  101f31:	6a 00                	push   $0x0
  pushl $1
  101f33:	6a 01                	push   $0x1
  jmp __alltraps
  101f35:	e9 cc ff ff ff       	jmp    101f06 <__alltraps>

00101f3a <vector2>:
.globl vector2
vector2:
  pushl $0
  101f3a:	6a 00                	push   $0x0
  pushl $2
  101f3c:	6a 02                	push   $0x2
  jmp __alltraps
  101f3e:	e9 c3 ff ff ff       	jmp    101f06 <__alltraps>

00101f43 <vector3>:
.globl vector3
vector3:
  pushl $0
  101f43:	6a 00                	push   $0x0
  pushl $3
  101f45:	6a 03                	push   $0x3
  jmp __alltraps
  101f47:	e9 ba ff ff ff       	jmp    101f06 <__alltraps>

00101f4c <vector4>:
.globl vector4
vector4:
  pushl $0
  101f4c:	6a 00                	push   $0x0
  pushl $4
  101f4e:	6a 04                	push   $0x4
  jmp __alltraps
  101f50:	e9 b1 ff ff ff       	jmp    101f06 <__alltraps>

00101f55 <vector5>:
.globl vector5
vector5:
  pushl $0
  101f55:	6a 00                	push   $0x0
  pushl $5
  101f57:	6a 05                	push   $0x5
  jmp __alltraps
  101f59:	e9 a8 ff ff ff       	jmp    101f06 <__alltraps>

00101f5e <vector6>:
.globl vector6
vector6:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $6
  101f60:	6a 06                	push   $0x6
  jmp __alltraps
  101f62:	e9 9f ff ff ff       	jmp    101f06 <__alltraps>

00101f67 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $7
  101f69:	6a 07                	push   $0x7
  jmp __alltraps
  101f6b:	e9 96 ff ff ff       	jmp    101f06 <__alltraps>

00101f70 <vector8>:
.globl vector8
vector8:
  pushl $8
  101f70:	6a 08                	push   $0x8
  jmp __alltraps
  101f72:	e9 8f ff ff ff       	jmp    101f06 <__alltraps>

00101f77 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $9
  101f79:	6a 09                	push   $0x9
  jmp __alltraps
  101f7b:	e9 86 ff ff ff       	jmp    101f06 <__alltraps>

00101f80 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f80:	6a 0a                	push   $0xa
  jmp __alltraps
  101f82:	e9 7f ff ff ff       	jmp    101f06 <__alltraps>

00101f87 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f87:	6a 0b                	push   $0xb
  jmp __alltraps
  101f89:	e9 78 ff ff ff       	jmp    101f06 <__alltraps>

00101f8e <vector12>:
.globl vector12
vector12:
  pushl $12
  101f8e:	6a 0c                	push   $0xc
  jmp __alltraps
  101f90:	e9 71 ff ff ff       	jmp    101f06 <__alltraps>

00101f95 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f95:	6a 0d                	push   $0xd
  jmp __alltraps
  101f97:	e9 6a ff ff ff       	jmp    101f06 <__alltraps>

00101f9c <vector14>:
.globl vector14
vector14:
  pushl $14
  101f9c:	6a 0e                	push   $0xe
  jmp __alltraps
  101f9e:	e9 63 ff ff ff       	jmp    101f06 <__alltraps>

00101fa3 <vector15>:
.globl vector15
vector15:
  pushl $0
  101fa3:	6a 00                	push   $0x0
  pushl $15
  101fa5:	6a 0f                	push   $0xf
  jmp __alltraps
  101fa7:	e9 5a ff ff ff       	jmp    101f06 <__alltraps>

00101fac <vector16>:
.globl vector16
vector16:
  pushl $0
  101fac:	6a 00                	push   $0x0
  pushl $16
  101fae:	6a 10                	push   $0x10
  jmp __alltraps
  101fb0:	e9 51 ff ff ff       	jmp    101f06 <__alltraps>

00101fb5 <vector17>:
.globl vector17
vector17:
  pushl $17
  101fb5:	6a 11                	push   $0x11
  jmp __alltraps
  101fb7:	e9 4a ff ff ff       	jmp    101f06 <__alltraps>

00101fbc <vector18>:
.globl vector18
vector18:
  pushl $0
  101fbc:	6a 00                	push   $0x0
  pushl $18
  101fbe:	6a 12                	push   $0x12
  jmp __alltraps
  101fc0:	e9 41 ff ff ff       	jmp    101f06 <__alltraps>

00101fc5 <vector19>:
.globl vector19
vector19:
  pushl $0
  101fc5:	6a 00                	push   $0x0
  pushl $19
  101fc7:	6a 13                	push   $0x13
  jmp __alltraps
  101fc9:	e9 38 ff ff ff       	jmp    101f06 <__alltraps>

00101fce <vector20>:
.globl vector20
vector20:
  pushl $0
  101fce:	6a 00                	push   $0x0
  pushl $20
  101fd0:	6a 14                	push   $0x14
  jmp __alltraps
  101fd2:	e9 2f ff ff ff       	jmp    101f06 <__alltraps>

00101fd7 <vector21>:
.globl vector21
vector21:
  pushl $0
  101fd7:	6a 00                	push   $0x0
  pushl $21
  101fd9:	6a 15                	push   $0x15
  jmp __alltraps
  101fdb:	e9 26 ff ff ff       	jmp    101f06 <__alltraps>

00101fe0 <vector22>:
.globl vector22
vector22:
  pushl $0
  101fe0:	6a 00                	push   $0x0
  pushl $22
  101fe2:	6a 16                	push   $0x16
  jmp __alltraps
  101fe4:	e9 1d ff ff ff       	jmp    101f06 <__alltraps>

00101fe9 <vector23>:
.globl vector23
vector23:
  pushl $0
  101fe9:	6a 00                	push   $0x0
  pushl $23
  101feb:	6a 17                	push   $0x17
  jmp __alltraps
  101fed:	e9 14 ff ff ff       	jmp    101f06 <__alltraps>

00101ff2 <vector24>:
.globl vector24
vector24:
  pushl $0
  101ff2:	6a 00                	push   $0x0
  pushl $24
  101ff4:	6a 18                	push   $0x18
  jmp __alltraps
  101ff6:	e9 0b ff ff ff       	jmp    101f06 <__alltraps>

00101ffb <vector25>:
.globl vector25
vector25:
  pushl $0
  101ffb:	6a 00                	push   $0x0
  pushl $25
  101ffd:	6a 19                	push   $0x19
  jmp __alltraps
  101fff:	e9 02 ff ff ff       	jmp    101f06 <__alltraps>

00102004 <vector26>:
.globl vector26
vector26:
  pushl $0
  102004:	6a 00                	push   $0x0
  pushl $26
  102006:	6a 1a                	push   $0x1a
  jmp __alltraps
  102008:	e9 f9 fe ff ff       	jmp    101f06 <__alltraps>

0010200d <vector27>:
.globl vector27
vector27:
  pushl $0
  10200d:	6a 00                	push   $0x0
  pushl $27
  10200f:	6a 1b                	push   $0x1b
  jmp __alltraps
  102011:	e9 f0 fe ff ff       	jmp    101f06 <__alltraps>

00102016 <vector28>:
.globl vector28
vector28:
  pushl $0
  102016:	6a 00                	push   $0x0
  pushl $28
  102018:	6a 1c                	push   $0x1c
  jmp __alltraps
  10201a:	e9 e7 fe ff ff       	jmp    101f06 <__alltraps>

0010201f <vector29>:
.globl vector29
vector29:
  pushl $0
  10201f:	6a 00                	push   $0x0
  pushl $29
  102021:	6a 1d                	push   $0x1d
  jmp __alltraps
  102023:	e9 de fe ff ff       	jmp    101f06 <__alltraps>

00102028 <vector30>:
.globl vector30
vector30:
  pushl $0
  102028:	6a 00                	push   $0x0
  pushl $30
  10202a:	6a 1e                	push   $0x1e
  jmp __alltraps
  10202c:	e9 d5 fe ff ff       	jmp    101f06 <__alltraps>

00102031 <vector31>:
.globl vector31
vector31:
  pushl $0
  102031:	6a 00                	push   $0x0
  pushl $31
  102033:	6a 1f                	push   $0x1f
  jmp __alltraps
  102035:	e9 cc fe ff ff       	jmp    101f06 <__alltraps>

0010203a <vector32>:
.globl vector32
vector32:
  pushl $0
  10203a:	6a 00                	push   $0x0
  pushl $32
  10203c:	6a 20                	push   $0x20
  jmp __alltraps
  10203e:	e9 c3 fe ff ff       	jmp    101f06 <__alltraps>

00102043 <vector33>:
.globl vector33
vector33:
  pushl $0
  102043:	6a 00                	push   $0x0
  pushl $33
  102045:	6a 21                	push   $0x21
  jmp __alltraps
  102047:	e9 ba fe ff ff       	jmp    101f06 <__alltraps>

0010204c <vector34>:
.globl vector34
vector34:
  pushl $0
  10204c:	6a 00                	push   $0x0
  pushl $34
  10204e:	6a 22                	push   $0x22
  jmp __alltraps
  102050:	e9 b1 fe ff ff       	jmp    101f06 <__alltraps>

00102055 <vector35>:
.globl vector35
vector35:
  pushl $0
  102055:	6a 00                	push   $0x0
  pushl $35
  102057:	6a 23                	push   $0x23
  jmp __alltraps
  102059:	e9 a8 fe ff ff       	jmp    101f06 <__alltraps>

0010205e <vector36>:
.globl vector36
vector36:
  pushl $0
  10205e:	6a 00                	push   $0x0
  pushl $36
  102060:	6a 24                	push   $0x24
  jmp __alltraps
  102062:	e9 9f fe ff ff       	jmp    101f06 <__alltraps>

00102067 <vector37>:
.globl vector37
vector37:
  pushl $0
  102067:	6a 00                	push   $0x0
  pushl $37
  102069:	6a 25                	push   $0x25
  jmp __alltraps
  10206b:	e9 96 fe ff ff       	jmp    101f06 <__alltraps>

00102070 <vector38>:
.globl vector38
vector38:
  pushl $0
  102070:	6a 00                	push   $0x0
  pushl $38
  102072:	6a 26                	push   $0x26
  jmp __alltraps
  102074:	e9 8d fe ff ff       	jmp    101f06 <__alltraps>

00102079 <vector39>:
.globl vector39
vector39:
  pushl $0
  102079:	6a 00                	push   $0x0
  pushl $39
  10207b:	6a 27                	push   $0x27
  jmp __alltraps
  10207d:	e9 84 fe ff ff       	jmp    101f06 <__alltraps>

00102082 <vector40>:
.globl vector40
vector40:
  pushl $0
  102082:	6a 00                	push   $0x0
  pushl $40
  102084:	6a 28                	push   $0x28
  jmp __alltraps
  102086:	e9 7b fe ff ff       	jmp    101f06 <__alltraps>

0010208b <vector41>:
.globl vector41
vector41:
  pushl $0
  10208b:	6a 00                	push   $0x0
  pushl $41
  10208d:	6a 29                	push   $0x29
  jmp __alltraps
  10208f:	e9 72 fe ff ff       	jmp    101f06 <__alltraps>

00102094 <vector42>:
.globl vector42
vector42:
  pushl $0
  102094:	6a 00                	push   $0x0
  pushl $42
  102096:	6a 2a                	push   $0x2a
  jmp __alltraps
  102098:	e9 69 fe ff ff       	jmp    101f06 <__alltraps>

0010209d <vector43>:
.globl vector43
vector43:
  pushl $0
  10209d:	6a 00                	push   $0x0
  pushl $43
  10209f:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020a1:	e9 60 fe ff ff       	jmp    101f06 <__alltraps>

001020a6 <vector44>:
.globl vector44
vector44:
  pushl $0
  1020a6:	6a 00                	push   $0x0
  pushl $44
  1020a8:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020aa:	e9 57 fe ff ff       	jmp    101f06 <__alltraps>

001020af <vector45>:
.globl vector45
vector45:
  pushl $0
  1020af:	6a 00                	push   $0x0
  pushl $45
  1020b1:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020b3:	e9 4e fe ff ff       	jmp    101f06 <__alltraps>

001020b8 <vector46>:
.globl vector46
vector46:
  pushl $0
  1020b8:	6a 00                	push   $0x0
  pushl $46
  1020ba:	6a 2e                	push   $0x2e
  jmp __alltraps
  1020bc:	e9 45 fe ff ff       	jmp    101f06 <__alltraps>

001020c1 <vector47>:
.globl vector47
vector47:
  pushl $0
  1020c1:	6a 00                	push   $0x0
  pushl $47
  1020c3:	6a 2f                	push   $0x2f
  jmp __alltraps
  1020c5:	e9 3c fe ff ff       	jmp    101f06 <__alltraps>

001020ca <vector48>:
.globl vector48
vector48:
  pushl $0
  1020ca:	6a 00                	push   $0x0
  pushl $48
  1020cc:	6a 30                	push   $0x30
  jmp __alltraps
  1020ce:	e9 33 fe ff ff       	jmp    101f06 <__alltraps>

001020d3 <vector49>:
.globl vector49
vector49:
  pushl $0
  1020d3:	6a 00                	push   $0x0
  pushl $49
  1020d5:	6a 31                	push   $0x31
  jmp __alltraps
  1020d7:	e9 2a fe ff ff       	jmp    101f06 <__alltraps>

001020dc <vector50>:
.globl vector50
vector50:
  pushl $0
  1020dc:	6a 00                	push   $0x0
  pushl $50
  1020de:	6a 32                	push   $0x32
  jmp __alltraps
  1020e0:	e9 21 fe ff ff       	jmp    101f06 <__alltraps>

001020e5 <vector51>:
.globl vector51
vector51:
  pushl $0
  1020e5:	6a 00                	push   $0x0
  pushl $51
  1020e7:	6a 33                	push   $0x33
  jmp __alltraps
  1020e9:	e9 18 fe ff ff       	jmp    101f06 <__alltraps>

001020ee <vector52>:
.globl vector52
vector52:
  pushl $0
  1020ee:	6a 00                	push   $0x0
  pushl $52
  1020f0:	6a 34                	push   $0x34
  jmp __alltraps
  1020f2:	e9 0f fe ff ff       	jmp    101f06 <__alltraps>

001020f7 <vector53>:
.globl vector53
vector53:
  pushl $0
  1020f7:	6a 00                	push   $0x0
  pushl $53
  1020f9:	6a 35                	push   $0x35
  jmp __alltraps
  1020fb:	e9 06 fe ff ff       	jmp    101f06 <__alltraps>

00102100 <vector54>:
.globl vector54
vector54:
  pushl $0
  102100:	6a 00                	push   $0x0
  pushl $54
  102102:	6a 36                	push   $0x36
  jmp __alltraps
  102104:	e9 fd fd ff ff       	jmp    101f06 <__alltraps>

00102109 <vector55>:
.globl vector55
vector55:
  pushl $0
  102109:	6a 00                	push   $0x0
  pushl $55
  10210b:	6a 37                	push   $0x37
  jmp __alltraps
  10210d:	e9 f4 fd ff ff       	jmp    101f06 <__alltraps>

00102112 <vector56>:
.globl vector56
vector56:
  pushl $0
  102112:	6a 00                	push   $0x0
  pushl $56
  102114:	6a 38                	push   $0x38
  jmp __alltraps
  102116:	e9 eb fd ff ff       	jmp    101f06 <__alltraps>

0010211b <vector57>:
.globl vector57
vector57:
  pushl $0
  10211b:	6a 00                	push   $0x0
  pushl $57
  10211d:	6a 39                	push   $0x39
  jmp __alltraps
  10211f:	e9 e2 fd ff ff       	jmp    101f06 <__alltraps>

00102124 <vector58>:
.globl vector58
vector58:
  pushl $0
  102124:	6a 00                	push   $0x0
  pushl $58
  102126:	6a 3a                	push   $0x3a
  jmp __alltraps
  102128:	e9 d9 fd ff ff       	jmp    101f06 <__alltraps>

0010212d <vector59>:
.globl vector59
vector59:
  pushl $0
  10212d:	6a 00                	push   $0x0
  pushl $59
  10212f:	6a 3b                	push   $0x3b
  jmp __alltraps
  102131:	e9 d0 fd ff ff       	jmp    101f06 <__alltraps>

00102136 <vector60>:
.globl vector60
vector60:
  pushl $0
  102136:	6a 00                	push   $0x0
  pushl $60
  102138:	6a 3c                	push   $0x3c
  jmp __alltraps
  10213a:	e9 c7 fd ff ff       	jmp    101f06 <__alltraps>

0010213f <vector61>:
.globl vector61
vector61:
  pushl $0
  10213f:	6a 00                	push   $0x0
  pushl $61
  102141:	6a 3d                	push   $0x3d
  jmp __alltraps
  102143:	e9 be fd ff ff       	jmp    101f06 <__alltraps>

00102148 <vector62>:
.globl vector62
vector62:
  pushl $0
  102148:	6a 00                	push   $0x0
  pushl $62
  10214a:	6a 3e                	push   $0x3e
  jmp __alltraps
  10214c:	e9 b5 fd ff ff       	jmp    101f06 <__alltraps>

00102151 <vector63>:
.globl vector63
vector63:
  pushl $0
  102151:	6a 00                	push   $0x0
  pushl $63
  102153:	6a 3f                	push   $0x3f
  jmp __alltraps
  102155:	e9 ac fd ff ff       	jmp    101f06 <__alltraps>

0010215a <vector64>:
.globl vector64
vector64:
  pushl $0
  10215a:	6a 00                	push   $0x0
  pushl $64
  10215c:	6a 40                	push   $0x40
  jmp __alltraps
  10215e:	e9 a3 fd ff ff       	jmp    101f06 <__alltraps>

00102163 <vector65>:
.globl vector65
vector65:
  pushl $0
  102163:	6a 00                	push   $0x0
  pushl $65
  102165:	6a 41                	push   $0x41
  jmp __alltraps
  102167:	e9 9a fd ff ff       	jmp    101f06 <__alltraps>

0010216c <vector66>:
.globl vector66
vector66:
  pushl $0
  10216c:	6a 00                	push   $0x0
  pushl $66
  10216e:	6a 42                	push   $0x42
  jmp __alltraps
  102170:	e9 91 fd ff ff       	jmp    101f06 <__alltraps>

00102175 <vector67>:
.globl vector67
vector67:
  pushl $0
  102175:	6a 00                	push   $0x0
  pushl $67
  102177:	6a 43                	push   $0x43
  jmp __alltraps
  102179:	e9 88 fd ff ff       	jmp    101f06 <__alltraps>

0010217e <vector68>:
.globl vector68
vector68:
  pushl $0
  10217e:	6a 00                	push   $0x0
  pushl $68
  102180:	6a 44                	push   $0x44
  jmp __alltraps
  102182:	e9 7f fd ff ff       	jmp    101f06 <__alltraps>

00102187 <vector69>:
.globl vector69
vector69:
  pushl $0
  102187:	6a 00                	push   $0x0
  pushl $69
  102189:	6a 45                	push   $0x45
  jmp __alltraps
  10218b:	e9 76 fd ff ff       	jmp    101f06 <__alltraps>

00102190 <vector70>:
.globl vector70
vector70:
  pushl $0
  102190:	6a 00                	push   $0x0
  pushl $70
  102192:	6a 46                	push   $0x46
  jmp __alltraps
  102194:	e9 6d fd ff ff       	jmp    101f06 <__alltraps>

00102199 <vector71>:
.globl vector71
vector71:
  pushl $0
  102199:	6a 00                	push   $0x0
  pushl $71
  10219b:	6a 47                	push   $0x47
  jmp __alltraps
  10219d:	e9 64 fd ff ff       	jmp    101f06 <__alltraps>

001021a2 <vector72>:
.globl vector72
vector72:
  pushl $0
  1021a2:	6a 00                	push   $0x0
  pushl $72
  1021a4:	6a 48                	push   $0x48
  jmp __alltraps
  1021a6:	e9 5b fd ff ff       	jmp    101f06 <__alltraps>

001021ab <vector73>:
.globl vector73
vector73:
  pushl $0
  1021ab:	6a 00                	push   $0x0
  pushl $73
  1021ad:	6a 49                	push   $0x49
  jmp __alltraps
  1021af:	e9 52 fd ff ff       	jmp    101f06 <__alltraps>

001021b4 <vector74>:
.globl vector74
vector74:
  pushl $0
  1021b4:	6a 00                	push   $0x0
  pushl $74
  1021b6:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021b8:	e9 49 fd ff ff       	jmp    101f06 <__alltraps>

001021bd <vector75>:
.globl vector75
vector75:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $75
  1021bf:	6a 4b                	push   $0x4b
  jmp __alltraps
  1021c1:	e9 40 fd ff ff       	jmp    101f06 <__alltraps>

001021c6 <vector76>:
.globl vector76
vector76:
  pushl $0
  1021c6:	6a 00                	push   $0x0
  pushl $76
  1021c8:	6a 4c                	push   $0x4c
  jmp __alltraps
  1021ca:	e9 37 fd ff ff       	jmp    101f06 <__alltraps>

001021cf <vector77>:
.globl vector77
vector77:
  pushl $0
  1021cf:	6a 00                	push   $0x0
  pushl $77
  1021d1:	6a 4d                	push   $0x4d
  jmp __alltraps
  1021d3:	e9 2e fd ff ff       	jmp    101f06 <__alltraps>

001021d8 <vector78>:
.globl vector78
vector78:
  pushl $0
  1021d8:	6a 00                	push   $0x0
  pushl $78
  1021da:	6a 4e                	push   $0x4e
  jmp __alltraps
  1021dc:	e9 25 fd ff ff       	jmp    101f06 <__alltraps>

001021e1 <vector79>:
.globl vector79
vector79:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $79
  1021e3:	6a 4f                	push   $0x4f
  jmp __alltraps
  1021e5:	e9 1c fd ff ff       	jmp    101f06 <__alltraps>

001021ea <vector80>:
.globl vector80
vector80:
  pushl $0
  1021ea:	6a 00                	push   $0x0
  pushl $80
  1021ec:	6a 50                	push   $0x50
  jmp __alltraps
  1021ee:	e9 13 fd ff ff       	jmp    101f06 <__alltraps>

001021f3 <vector81>:
.globl vector81
vector81:
  pushl $0
  1021f3:	6a 00                	push   $0x0
  pushl $81
  1021f5:	6a 51                	push   $0x51
  jmp __alltraps
  1021f7:	e9 0a fd ff ff       	jmp    101f06 <__alltraps>

001021fc <vector82>:
.globl vector82
vector82:
  pushl $0
  1021fc:	6a 00                	push   $0x0
  pushl $82
  1021fe:	6a 52                	push   $0x52
  jmp __alltraps
  102200:	e9 01 fd ff ff       	jmp    101f06 <__alltraps>

00102205 <vector83>:
.globl vector83
vector83:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $83
  102207:	6a 53                	push   $0x53
  jmp __alltraps
  102209:	e9 f8 fc ff ff       	jmp    101f06 <__alltraps>

0010220e <vector84>:
.globl vector84
vector84:
  pushl $0
  10220e:	6a 00                	push   $0x0
  pushl $84
  102210:	6a 54                	push   $0x54
  jmp __alltraps
  102212:	e9 ef fc ff ff       	jmp    101f06 <__alltraps>

00102217 <vector85>:
.globl vector85
vector85:
  pushl $0
  102217:	6a 00                	push   $0x0
  pushl $85
  102219:	6a 55                	push   $0x55
  jmp __alltraps
  10221b:	e9 e6 fc ff ff       	jmp    101f06 <__alltraps>

00102220 <vector86>:
.globl vector86
vector86:
  pushl $0
  102220:	6a 00                	push   $0x0
  pushl $86
  102222:	6a 56                	push   $0x56
  jmp __alltraps
  102224:	e9 dd fc ff ff       	jmp    101f06 <__alltraps>

00102229 <vector87>:
.globl vector87
vector87:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $87
  10222b:	6a 57                	push   $0x57
  jmp __alltraps
  10222d:	e9 d4 fc ff ff       	jmp    101f06 <__alltraps>

00102232 <vector88>:
.globl vector88
vector88:
  pushl $0
  102232:	6a 00                	push   $0x0
  pushl $88
  102234:	6a 58                	push   $0x58
  jmp __alltraps
  102236:	e9 cb fc ff ff       	jmp    101f06 <__alltraps>

0010223b <vector89>:
.globl vector89
vector89:
  pushl $0
  10223b:	6a 00                	push   $0x0
  pushl $89
  10223d:	6a 59                	push   $0x59
  jmp __alltraps
  10223f:	e9 c2 fc ff ff       	jmp    101f06 <__alltraps>

00102244 <vector90>:
.globl vector90
vector90:
  pushl $0
  102244:	6a 00                	push   $0x0
  pushl $90
  102246:	6a 5a                	push   $0x5a
  jmp __alltraps
  102248:	e9 b9 fc ff ff       	jmp    101f06 <__alltraps>

0010224d <vector91>:
.globl vector91
vector91:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $91
  10224f:	6a 5b                	push   $0x5b
  jmp __alltraps
  102251:	e9 b0 fc ff ff       	jmp    101f06 <__alltraps>

00102256 <vector92>:
.globl vector92
vector92:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $92
  102258:	6a 5c                	push   $0x5c
  jmp __alltraps
  10225a:	e9 a7 fc ff ff       	jmp    101f06 <__alltraps>

0010225f <vector93>:
.globl vector93
vector93:
  pushl $0
  10225f:	6a 00                	push   $0x0
  pushl $93
  102261:	6a 5d                	push   $0x5d
  jmp __alltraps
  102263:	e9 9e fc ff ff       	jmp    101f06 <__alltraps>

00102268 <vector94>:
.globl vector94
vector94:
  pushl $0
  102268:	6a 00                	push   $0x0
  pushl $94
  10226a:	6a 5e                	push   $0x5e
  jmp __alltraps
  10226c:	e9 95 fc ff ff       	jmp    101f06 <__alltraps>

00102271 <vector95>:
.globl vector95
vector95:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $95
  102273:	6a 5f                	push   $0x5f
  jmp __alltraps
  102275:	e9 8c fc ff ff       	jmp    101f06 <__alltraps>

0010227a <vector96>:
.globl vector96
vector96:
  pushl $0
  10227a:	6a 00                	push   $0x0
  pushl $96
  10227c:	6a 60                	push   $0x60
  jmp __alltraps
  10227e:	e9 83 fc ff ff       	jmp    101f06 <__alltraps>

00102283 <vector97>:
.globl vector97
vector97:
  pushl $0
  102283:	6a 00                	push   $0x0
  pushl $97
  102285:	6a 61                	push   $0x61
  jmp __alltraps
  102287:	e9 7a fc ff ff       	jmp    101f06 <__alltraps>

0010228c <vector98>:
.globl vector98
vector98:
  pushl $0
  10228c:	6a 00                	push   $0x0
  pushl $98
  10228e:	6a 62                	push   $0x62
  jmp __alltraps
  102290:	e9 71 fc ff ff       	jmp    101f06 <__alltraps>

00102295 <vector99>:
.globl vector99
vector99:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $99
  102297:	6a 63                	push   $0x63
  jmp __alltraps
  102299:	e9 68 fc ff ff       	jmp    101f06 <__alltraps>

0010229e <vector100>:
.globl vector100
vector100:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $100
  1022a0:	6a 64                	push   $0x64
  jmp __alltraps
  1022a2:	e9 5f fc ff ff       	jmp    101f06 <__alltraps>

001022a7 <vector101>:
.globl vector101
vector101:
  pushl $0
  1022a7:	6a 00                	push   $0x0
  pushl $101
  1022a9:	6a 65                	push   $0x65
  jmp __alltraps
  1022ab:	e9 56 fc ff ff       	jmp    101f06 <__alltraps>

001022b0 <vector102>:
.globl vector102
vector102:
  pushl $0
  1022b0:	6a 00                	push   $0x0
  pushl $102
  1022b2:	6a 66                	push   $0x66
  jmp __alltraps
  1022b4:	e9 4d fc ff ff       	jmp    101f06 <__alltraps>

001022b9 <vector103>:
.globl vector103
vector103:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $103
  1022bb:	6a 67                	push   $0x67
  jmp __alltraps
  1022bd:	e9 44 fc ff ff       	jmp    101f06 <__alltraps>

001022c2 <vector104>:
.globl vector104
vector104:
  pushl $0
  1022c2:	6a 00                	push   $0x0
  pushl $104
  1022c4:	6a 68                	push   $0x68
  jmp __alltraps
  1022c6:	e9 3b fc ff ff       	jmp    101f06 <__alltraps>

001022cb <vector105>:
.globl vector105
vector105:
  pushl $0
  1022cb:	6a 00                	push   $0x0
  pushl $105
  1022cd:	6a 69                	push   $0x69
  jmp __alltraps
  1022cf:	e9 32 fc ff ff       	jmp    101f06 <__alltraps>

001022d4 <vector106>:
.globl vector106
vector106:
  pushl $0
  1022d4:	6a 00                	push   $0x0
  pushl $106
  1022d6:	6a 6a                	push   $0x6a
  jmp __alltraps
  1022d8:	e9 29 fc ff ff       	jmp    101f06 <__alltraps>

001022dd <vector107>:
.globl vector107
vector107:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $107
  1022df:	6a 6b                	push   $0x6b
  jmp __alltraps
  1022e1:	e9 20 fc ff ff       	jmp    101f06 <__alltraps>

001022e6 <vector108>:
.globl vector108
vector108:
  pushl $0
  1022e6:	6a 00                	push   $0x0
  pushl $108
  1022e8:	6a 6c                	push   $0x6c
  jmp __alltraps
  1022ea:	e9 17 fc ff ff       	jmp    101f06 <__alltraps>

001022ef <vector109>:
.globl vector109
vector109:
  pushl $0
  1022ef:	6a 00                	push   $0x0
  pushl $109
  1022f1:	6a 6d                	push   $0x6d
  jmp __alltraps
  1022f3:	e9 0e fc ff ff       	jmp    101f06 <__alltraps>

001022f8 <vector110>:
.globl vector110
vector110:
  pushl $0
  1022f8:	6a 00                	push   $0x0
  pushl $110
  1022fa:	6a 6e                	push   $0x6e
  jmp __alltraps
  1022fc:	e9 05 fc ff ff       	jmp    101f06 <__alltraps>

00102301 <vector111>:
.globl vector111
vector111:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $111
  102303:	6a 6f                	push   $0x6f
  jmp __alltraps
  102305:	e9 fc fb ff ff       	jmp    101f06 <__alltraps>

0010230a <vector112>:
.globl vector112
vector112:
  pushl $0
  10230a:	6a 00                	push   $0x0
  pushl $112
  10230c:	6a 70                	push   $0x70
  jmp __alltraps
  10230e:	e9 f3 fb ff ff       	jmp    101f06 <__alltraps>

00102313 <vector113>:
.globl vector113
vector113:
  pushl $0
  102313:	6a 00                	push   $0x0
  pushl $113
  102315:	6a 71                	push   $0x71
  jmp __alltraps
  102317:	e9 ea fb ff ff       	jmp    101f06 <__alltraps>

0010231c <vector114>:
.globl vector114
vector114:
  pushl $0
  10231c:	6a 00                	push   $0x0
  pushl $114
  10231e:	6a 72                	push   $0x72
  jmp __alltraps
  102320:	e9 e1 fb ff ff       	jmp    101f06 <__alltraps>

00102325 <vector115>:
.globl vector115
vector115:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $115
  102327:	6a 73                	push   $0x73
  jmp __alltraps
  102329:	e9 d8 fb ff ff       	jmp    101f06 <__alltraps>

0010232e <vector116>:
.globl vector116
vector116:
  pushl $0
  10232e:	6a 00                	push   $0x0
  pushl $116
  102330:	6a 74                	push   $0x74
  jmp __alltraps
  102332:	e9 cf fb ff ff       	jmp    101f06 <__alltraps>

00102337 <vector117>:
.globl vector117
vector117:
  pushl $0
  102337:	6a 00                	push   $0x0
  pushl $117
  102339:	6a 75                	push   $0x75
  jmp __alltraps
  10233b:	e9 c6 fb ff ff       	jmp    101f06 <__alltraps>

00102340 <vector118>:
.globl vector118
vector118:
  pushl $0
  102340:	6a 00                	push   $0x0
  pushl $118
  102342:	6a 76                	push   $0x76
  jmp __alltraps
  102344:	e9 bd fb ff ff       	jmp    101f06 <__alltraps>

00102349 <vector119>:
.globl vector119
vector119:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $119
  10234b:	6a 77                	push   $0x77
  jmp __alltraps
  10234d:	e9 b4 fb ff ff       	jmp    101f06 <__alltraps>

00102352 <vector120>:
.globl vector120
vector120:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $120
  102354:	6a 78                	push   $0x78
  jmp __alltraps
  102356:	e9 ab fb ff ff       	jmp    101f06 <__alltraps>

0010235b <vector121>:
.globl vector121
vector121:
  pushl $0
  10235b:	6a 00                	push   $0x0
  pushl $121
  10235d:	6a 79                	push   $0x79
  jmp __alltraps
  10235f:	e9 a2 fb ff ff       	jmp    101f06 <__alltraps>

00102364 <vector122>:
.globl vector122
vector122:
  pushl $0
  102364:	6a 00                	push   $0x0
  pushl $122
  102366:	6a 7a                	push   $0x7a
  jmp __alltraps
  102368:	e9 99 fb ff ff       	jmp    101f06 <__alltraps>

0010236d <vector123>:
.globl vector123
vector123:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $123
  10236f:	6a 7b                	push   $0x7b
  jmp __alltraps
  102371:	e9 90 fb ff ff       	jmp    101f06 <__alltraps>

00102376 <vector124>:
.globl vector124
vector124:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $124
  102378:	6a 7c                	push   $0x7c
  jmp __alltraps
  10237a:	e9 87 fb ff ff       	jmp    101f06 <__alltraps>

0010237f <vector125>:
.globl vector125
vector125:
  pushl $0
  10237f:	6a 00                	push   $0x0
  pushl $125
  102381:	6a 7d                	push   $0x7d
  jmp __alltraps
  102383:	e9 7e fb ff ff       	jmp    101f06 <__alltraps>

00102388 <vector126>:
.globl vector126
vector126:
  pushl $0
  102388:	6a 00                	push   $0x0
  pushl $126
  10238a:	6a 7e                	push   $0x7e
  jmp __alltraps
  10238c:	e9 75 fb ff ff       	jmp    101f06 <__alltraps>

00102391 <vector127>:
.globl vector127
vector127:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $127
  102393:	6a 7f                	push   $0x7f
  jmp __alltraps
  102395:	e9 6c fb ff ff       	jmp    101f06 <__alltraps>

0010239a <vector128>:
.globl vector128
vector128:
  pushl $0
  10239a:	6a 00                	push   $0x0
  pushl $128
  10239c:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023a1:	e9 60 fb ff ff       	jmp    101f06 <__alltraps>

001023a6 <vector129>:
.globl vector129
vector129:
  pushl $0
  1023a6:	6a 00                	push   $0x0
  pushl $129
  1023a8:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023ad:	e9 54 fb ff ff       	jmp    101f06 <__alltraps>

001023b2 <vector130>:
.globl vector130
vector130:
  pushl $0
  1023b2:	6a 00                	push   $0x0
  pushl $130
  1023b4:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1023b9:	e9 48 fb ff ff       	jmp    101f06 <__alltraps>

001023be <vector131>:
.globl vector131
vector131:
  pushl $0
  1023be:	6a 00                	push   $0x0
  pushl $131
  1023c0:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1023c5:	e9 3c fb ff ff       	jmp    101f06 <__alltraps>

001023ca <vector132>:
.globl vector132
vector132:
  pushl $0
  1023ca:	6a 00                	push   $0x0
  pushl $132
  1023cc:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1023d1:	e9 30 fb ff ff       	jmp    101f06 <__alltraps>

001023d6 <vector133>:
.globl vector133
vector133:
  pushl $0
  1023d6:	6a 00                	push   $0x0
  pushl $133
  1023d8:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1023dd:	e9 24 fb ff ff       	jmp    101f06 <__alltraps>

001023e2 <vector134>:
.globl vector134
vector134:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $134
  1023e4:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1023e9:	e9 18 fb ff ff       	jmp    101f06 <__alltraps>

001023ee <vector135>:
.globl vector135
vector135:
  pushl $0
  1023ee:	6a 00                	push   $0x0
  pushl $135
  1023f0:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1023f5:	e9 0c fb ff ff       	jmp    101f06 <__alltraps>

001023fa <vector136>:
.globl vector136
vector136:
  pushl $0
  1023fa:	6a 00                	push   $0x0
  pushl $136
  1023fc:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102401:	e9 00 fb ff ff       	jmp    101f06 <__alltraps>

00102406 <vector137>:
.globl vector137
vector137:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $137
  102408:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10240d:	e9 f4 fa ff ff       	jmp    101f06 <__alltraps>

00102412 <vector138>:
.globl vector138
vector138:
  pushl $0
  102412:	6a 00                	push   $0x0
  pushl $138
  102414:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102419:	e9 e8 fa ff ff       	jmp    101f06 <__alltraps>

0010241e <vector139>:
.globl vector139
vector139:
  pushl $0
  10241e:	6a 00                	push   $0x0
  pushl $139
  102420:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102425:	e9 dc fa ff ff       	jmp    101f06 <__alltraps>

0010242a <vector140>:
.globl vector140
vector140:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $140
  10242c:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102431:	e9 d0 fa ff ff       	jmp    101f06 <__alltraps>

00102436 <vector141>:
.globl vector141
vector141:
  pushl $0
  102436:	6a 00                	push   $0x0
  pushl $141
  102438:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10243d:	e9 c4 fa ff ff       	jmp    101f06 <__alltraps>

00102442 <vector142>:
.globl vector142
vector142:
  pushl $0
  102442:	6a 00                	push   $0x0
  pushl $142
  102444:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102449:	e9 b8 fa ff ff       	jmp    101f06 <__alltraps>

0010244e <vector143>:
.globl vector143
vector143:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $143
  102450:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102455:	e9 ac fa ff ff       	jmp    101f06 <__alltraps>

0010245a <vector144>:
.globl vector144
vector144:
  pushl $0
  10245a:	6a 00                	push   $0x0
  pushl $144
  10245c:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102461:	e9 a0 fa ff ff       	jmp    101f06 <__alltraps>

00102466 <vector145>:
.globl vector145
vector145:
  pushl $0
  102466:	6a 00                	push   $0x0
  pushl $145
  102468:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10246d:	e9 94 fa ff ff       	jmp    101f06 <__alltraps>

00102472 <vector146>:
.globl vector146
vector146:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $146
  102474:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102479:	e9 88 fa ff ff       	jmp    101f06 <__alltraps>

0010247e <vector147>:
.globl vector147
vector147:
  pushl $0
  10247e:	6a 00                	push   $0x0
  pushl $147
  102480:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102485:	e9 7c fa ff ff       	jmp    101f06 <__alltraps>

0010248a <vector148>:
.globl vector148
vector148:
  pushl $0
  10248a:	6a 00                	push   $0x0
  pushl $148
  10248c:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102491:	e9 70 fa ff ff       	jmp    101f06 <__alltraps>

00102496 <vector149>:
.globl vector149
vector149:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $149
  102498:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10249d:	e9 64 fa ff ff       	jmp    101f06 <__alltraps>

001024a2 <vector150>:
.globl vector150
vector150:
  pushl $0
  1024a2:	6a 00                	push   $0x0
  pushl $150
  1024a4:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024a9:	e9 58 fa ff ff       	jmp    101f06 <__alltraps>

001024ae <vector151>:
.globl vector151
vector151:
  pushl $0
  1024ae:	6a 00                	push   $0x0
  pushl $151
  1024b0:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024b5:	e9 4c fa ff ff       	jmp    101f06 <__alltraps>

001024ba <vector152>:
.globl vector152
vector152:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $152
  1024bc:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1024c1:	e9 40 fa ff ff       	jmp    101f06 <__alltraps>

001024c6 <vector153>:
.globl vector153
vector153:
  pushl $0
  1024c6:	6a 00                	push   $0x0
  pushl $153
  1024c8:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1024cd:	e9 34 fa ff ff       	jmp    101f06 <__alltraps>

001024d2 <vector154>:
.globl vector154
vector154:
  pushl $0
  1024d2:	6a 00                	push   $0x0
  pushl $154
  1024d4:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1024d9:	e9 28 fa ff ff       	jmp    101f06 <__alltraps>

001024de <vector155>:
.globl vector155
vector155:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $155
  1024e0:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1024e5:	e9 1c fa ff ff       	jmp    101f06 <__alltraps>

001024ea <vector156>:
.globl vector156
vector156:
  pushl $0
  1024ea:	6a 00                	push   $0x0
  pushl $156
  1024ec:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1024f1:	e9 10 fa ff ff       	jmp    101f06 <__alltraps>

001024f6 <vector157>:
.globl vector157
vector157:
  pushl $0
  1024f6:	6a 00                	push   $0x0
  pushl $157
  1024f8:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1024fd:	e9 04 fa ff ff       	jmp    101f06 <__alltraps>

00102502 <vector158>:
.globl vector158
vector158:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $158
  102504:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102509:	e9 f8 f9 ff ff       	jmp    101f06 <__alltraps>

0010250e <vector159>:
.globl vector159
vector159:
  pushl $0
  10250e:	6a 00                	push   $0x0
  pushl $159
  102510:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102515:	e9 ec f9 ff ff       	jmp    101f06 <__alltraps>

0010251a <vector160>:
.globl vector160
vector160:
  pushl $0
  10251a:	6a 00                	push   $0x0
  pushl $160
  10251c:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102521:	e9 e0 f9 ff ff       	jmp    101f06 <__alltraps>

00102526 <vector161>:
.globl vector161
vector161:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $161
  102528:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10252d:	e9 d4 f9 ff ff       	jmp    101f06 <__alltraps>

00102532 <vector162>:
.globl vector162
vector162:
  pushl $0
  102532:	6a 00                	push   $0x0
  pushl $162
  102534:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102539:	e9 c8 f9 ff ff       	jmp    101f06 <__alltraps>

0010253e <vector163>:
.globl vector163
vector163:
  pushl $0
  10253e:	6a 00                	push   $0x0
  pushl $163
  102540:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102545:	e9 bc f9 ff ff       	jmp    101f06 <__alltraps>

0010254a <vector164>:
.globl vector164
vector164:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $164
  10254c:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102551:	e9 b0 f9 ff ff       	jmp    101f06 <__alltraps>

00102556 <vector165>:
.globl vector165
vector165:
  pushl $0
  102556:	6a 00                	push   $0x0
  pushl $165
  102558:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10255d:	e9 a4 f9 ff ff       	jmp    101f06 <__alltraps>

00102562 <vector166>:
.globl vector166
vector166:
  pushl $0
  102562:	6a 00                	push   $0x0
  pushl $166
  102564:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102569:	e9 98 f9 ff ff       	jmp    101f06 <__alltraps>

0010256e <vector167>:
.globl vector167
vector167:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $167
  102570:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102575:	e9 8c f9 ff ff       	jmp    101f06 <__alltraps>

0010257a <vector168>:
.globl vector168
vector168:
  pushl $0
  10257a:	6a 00                	push   $0x0
  pushl $168
  10257c:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102581:	e9 80 f9 ff ff       	jmp    101f06 <__alltraps>

00102586 <vector169>:
.globl vector169
vector169:
  pushl $0
  102586:	6a 00                	push   $0x0
  pushl $169
  102588:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10258d:	e9 74 f9 ff ff       	jmp    101f06 <__alltraps>

00102592 <vector170>:
.globl vector170
vector170:
  pushl $0
  102592:	6a 00                	push   $0x0
  pushl $170
  102594:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102599:	e9 68 f9 ff ff       	jmp    101f06 <__alltraps>

0010259e <vector171>:
.globl vector171
vector171:
  pushl $0
  10259e:	6a 00                	push   $0x0
  pushl $171
  1025a0:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025a5:	e9 5c f9 ff ff       	jmp    101f06 <__alltraps>

001025aa <vector172>:
.globl vector172
vector172:
  pushl $0
  1025aa:	6a 00                	push   $0x0
  pushl $172
  1025ac:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025b1:	e9 50 f9 ff ff       	jmp    101f06 <__alltraps>

001025b6 <vector173>:
.globl vector173
vector173:
  pushl $0
  1025b6:	6a 00                	push   $0x0
  pushl $173
  1025b8:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1025bd:	e9 44 f9 ff ff       	jmp    101f06 <__alltraps>

001025c2 <vector174>:
.globl vector174
vector174:
  pushl $0
  1025c2:	6a 00                	push   $0x0
  pushl $174
  1025c4:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1025c9:	e9 38 f9 ff ff       	jmp    101f06 <__alltraps>

001025ce <vector175>:
.globl vector175
vector175:
  pushl $0
  1025ce:	6a 00                	push   $0x0
  pushl $175
  1025d0:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1025d5:	e9 2c f9 ff ff       	jmp    101f06 <__alltraps>

001025da <vector176>:
.globl vector176
vector176:
  pushl $0
  1025da:	6a 00                	push   $0x0
  pushl $176
  1025dc:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1025e1:	e9 20 f9 ff ff       	jmp    101f06 <__alltraps>

001025e6 <vector177>:
.globl vector177
vector177:
  pushl $0
  1025e6:	6a 00                	push   $0x0
  pushl $177
  1025e8:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1025ed:	e9 14 f9 ff ff       	jmp    101f06 <__alltraps>

001025f2 <vector178>:
.globl vector178
vector178:
  pushl $0
  1025f2:	6a 00                	push   $0x0
  pushl $178
  1025f4:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1025f9:	e9 08 f9 ff ff       	jmp    101f06 <__alltraps>

001025fe <vector179>:
.globl vector179
vector179:
  pushl $0
  1025fe:	6a 00                	push   $0x0
  pushl $179
  102600:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102605:	e9 fc f8 ff ff       	jmp    101f06 <__alltraps>

0010260a <vector180>:
.globl vector180
vector180:
  pushl $0
  10260a:	6a 00                	push   $0x0
  pushl $180
  10260c:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102611:	e9 f0 f8 ff ff       	jmp    101f06 <__alltraps>

00102616 <vector181>:
.globl vector181
vector181:
  pushl $0
  102616:	6a 00                	push   $0x0
  pushl $181
  102618:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10261d:	e9 e4 f8 ff ff       	jmp    101f06 <__alltraps>

00102622 <vector182>:
.globl vector182
vector182:
  pushl $0
  102622:	6a 00                	push   $0x0
  pushl $182
  102624:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102629:	e9 d8 f8 ff ff       	jmp    101f06 <__alltraps>

0010262e <vector183>:
.globl vector183
vector183:
  pushl $0
  10262e:	6a 00                	push   $0x0
  pushl $183
  102630:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102635:	e9 cc f8 ff ff       	jmp    101f06 <__alltraps>

0010263a <vector184>:
.globl vector184
vector184:
  pushl $0
  10263a:	6a 00                	push   $0x0
  pushl $184
  10263c:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102641:	e9 c0 f8 ff ff       	jmp    101f06 <__alltraps>

00102646 <vector185>:
.globl vector185
vector185:
  pushl $0
  102646:	6a 00                	push   $0x0
  pushl $185
  102648:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10264d:	e9 b4 f8 ff ff       	jmp    101f06 <__alltraps>

00102652 <vector186>:
.globl vector186
vector186:
  pushl $0
  102652:	6a 00                	push   $0x0
  pushl $186
  102654:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102659:	e9 a8 f8 ff ff       	jmp    101f06 <__alltraps>

0010265e <vector187>:
.globl vector187
vector187:
  pushl $0
  10265e:	6a 00                	push   $0x0
  pushl $187
  102660:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102665:	e9 9c f8 ff ff       	jmp    101f06 <__alltraps>

0010266a <vector188>:
.globl vector188
vector188:
  pushl $0
  10266a:	6a 00                	push   $0x0
  pushl $188
  10266c:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102671:	e9 90 f8 ff ff       	jmp    101f06 <__alltraps>

00102676 <vector189>:
.globl vector189
vector189:
  pushl $0
  102676:	6a 00                	push   $0x0
  pushl $189
  102678:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10267d:	e9 84 f8 ff ff       	jmp    101f06 <__alltraps>

00102682 <vector190>:
.globl vector190
vector190:
  pushl $0
  102682:	6a 00                	push   $0x0
  pushl $190
  102684:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102689:	e9 78 f8 ff ff       	jmp    101f06 <__alltraps>

0010268e <vector191>:
.globl vector191
vector191:
  pushl $0
  10268e:	6a 00                	push   $0x0
  pushl $191
  102690:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102695:	e9 6c f8 ff ff       	jmp    101f06 <__alltraps>

0010269a <vector192>:
.globl vector192
vector192:
  pushl $0
  10269a:	6a 00                	push   $0x0
  pushl $192
  10269c:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026a1:	e9 60 f8 ff ff       	jmp    101f06 <__alltraps>

001026a6 <vector193>:
.globl vector193
vector193:
  pushl $0
  1026a6:	6a 00                	push   $0x0
  pushl $193
  1026a8:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026ad:	e9 54 f8 ff ff       	jmp    101f06 <__alltraps>

001026b2 <vector194>:
.globl vector194
vector194:
  pushl $0
  1026b2:	6a 00                	push   $0x0
  pushl $194
  1026b4:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1026b9:	e9 48 f8 ff ff       	jmp    101f06 <__alltraps>

001026be <vector195>:
.globl vector195
vector195:
  pushl $0
  1026be:	6a 00                	push   $0x0
  pushl $195
  1026c0:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1026c5:	e9 3c f8 ff ff       	jmp    101f06 <__alltraps>

001026ca <vector196>:
.globl vector196
vector196:
  pushl $0
  1026ca:	6a 00                	push   $0x0
  pushl $196
  1026cc:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1026d1:	e9 30 f8 ff ff       	jmp    101f06 <__alltraps>

001026d6 <vector197>:
.globl vector197
vector197:
  pushl $0
  1026d6:	6a 00                	push   $0x0
  pushl $197
  1026d8:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1026dd:	e9 24 f8 ff ff       	jmp    101f06 <__alltraps>

001026e2 <vector198>:
.globl vector198
vector198:
  pushl $0
  1026e2:	6a 00                	push   $0x0
  pushl $198
  1026e4:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1026e9:	e9 18 f8 ff ff       	jmp    101f06 <__alltraps>

001026ee <vector199>:
.globl vector199
vector199:
  pushl $0
  1026ee:	6a 00                	push   $0x0
  pushl $199
  1026f0:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1026f5:	e9 0c f8 ff ff       	jmp    101f06 <__alltraps>

001026fa <vector200>:
.globl vector200
vector200:
  pushl $0
  1026fa:	6a 00                	push   $0x0
  pushl $200
  1026fc:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102701:	e9 00 f8 ff ff       	jmp    101f06 <__alltraps>

00102706 <vector201>:
.globl vector201
vector201:
  pushl $0
  102706:	6a 00                	push   $0x0
  pushl $201
  102708:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10270d:	e9 f4 f7 ff ff       	jmp    101f06 <__alltraps>

00102712 <vector202>:
.globl vector202
vector202:
  pushl $0
  102712:	6a 00                	push   $0x0
  pushl $202
  102714:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102719:	e9 e8 f7 ff ff       	jmp    101f06 <__alltraps>

0010271e <vector203>:
.globl vector203
vector203:
  pushl $0
  10271e:	6a 00                	push   $0x0
  pushl $203
  102720:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102725:	e9 dc f7 ff ff       	jmp    101f06 <__alltraps>

0010272a <vector204>:
.globl vector204
vector204:
  pushl $0
  10272a:	6a 00                	push   $0x0
  pushl $204
  10272c:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102731:	e9 d0 f7 ff ff       	jmp    101f06 <__alltraps>

00102736 <vector205>:
.globl vector205
vector205:
  pushl $0
  102736:	6a 00                	push   $0x0
  pushl $205
  102738:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10273d:	e9 c4 f7 ff ff       	jmp    101f06 <__alltraps>

00102742 <vector206>:
.globl vector206
vector206:
  pushl $0
  102742:	6a 00                	push   $0x0
  pushl $206
  102744:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102749:	e9 b8 f7 ff ff       	jmp    101f06 <__alltraps>

0010274e <vector207>:
.globl vector207
vector207:
  pushl $0
  10274e:	6a 00                	push   $0x0
  pushl $207
  102750:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102755:	e9 ac f7 ff ff       	jmp    101f06 <__alltraps>

0010275a <vector208>:
.globl vector208
vector208:
  pushl $0
  10275a:	6a 00                	push   $0x0
  pushl $208
  10275c:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102761:	e9 a0 f7 ff ff       	jmp    101f06 <__alltraps>

00102766 <vector209>:
.globl vector209
vector209:
  pushl $0
  102766:	6a 00                	push   $0x0
  pushl $209
  102768:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10276d:	e9 94 f7 ff ff       	jmp    101f06 <__alltraps>

00102772 <vector210>:
.globl vector210
vector210:
  pushl $0
  102772:	6a 00                	push   $0x0
  pushl $210
  102774:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102779:	e9 88 f7 ff ff       	jmp    101f06 <__alltraps>

0010277e <vector211>:
.globl vector211
vector211:
  pushl $0
  10277e:	6a 00                	push   $0x0
  pushl $211
  102780:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102785:	e9 7c f7 ff ff       	jmp    101f06 <__alltraps>

0010278a <vector212>:
.globl vector212
vector212:
  pushl $0
  10278a:	6a 00                	push   $0x0
  pushl $212
  10278c:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102791:	e9 70 f7 ff ff       	jmp    101f06 <__alltraps>

00102796 <vector213>:
.globl vector213
vector213:
  pushl $0
  102796:	6a 00                	push   $0x0
  pushl $213
  102798:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10279d:	e9 64 f7 ff ff       	jmp    101f06 <__alltraps>

001027a2 <vector214>:
.globl vector214
vector214:
  pushl $0
  1027a2:	6a 00                	push   $0x0
  pushl $214
  1027a4:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027a9:	e9 58 f7 ff ff       	jmp    101f06 <__alltraps>

001027ae <vector215>:
.globl vector215
vector215:
  pushl $0
  1027ae:	6a 00                	push   $0x0
  pushl $215
  1027b0:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027b5:	e9 4c f7 ff ff       	jmp    101f06 <__alltraps>

001027ba <vector216>:
.globl vector216
vector216:
  pushl $0
  1027ba:	6a 00                	push   $0x0
  pushl $216
  1027bc:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1027c1:	e9 40 f7 ff ff       	jmp    101f06 <__alltraps>

001027c6 <vector217>:
.globl vector217
vector217:
  pushl $0
  1027c6:	6a 00                	push   $0x0
  pushl $217
  1027c8:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1027cd:	e9 34 f7 ff ff       	jmp    101f06 <__alltraps>

001027d2 <vector218>:
.globl vector218
vector218:
  pushl $0
  1027d2:	6a 00                	push   $0x0
  pushl $218
  1027d4:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1027d9:	e9 28 f7 ff ff       	jmp    101f06 <__alltraps>

001027de <vector219>:
.globl vector219
vector219:
  pushl $0
  1027de:	6a 00                	push   $0x0
  pushl $219
  1027e0:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1027e5:	e9 1c f7 ff ff       	jmp    101f06 <__alltraps>

001027ea <vector220>:
.globl vector220
vector220:
  pushl $0
  1027ea:	6a 00                	push   $0x0
  pushl $220
  1027ec:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1027f1:	e9 10 f7 ff ff       	jmp    101f06 <__alltraps>

001027f6 <vector221>:
.globl vector221
vector221:
  pushl $0
  1027f6:	6a 00                	push   $0x0
  pushl $221
  1027f8:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1027fd:	e9 04 f7 ff ff       	jmp    101f06 <__alltraps>

00102802 <vector222>:
.globl vector222
vector222:
  pushl $0
  102802:	6a 00                	push   $0x0
  pushl $222
  102804:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102809:	e9 f8 f6 ff ff       	jmp    101f06 <__alltraps>

0010280e <vector223>:
.globl vector223
vector223:
  pushl $0
  10280e:	6a 00                	push   $0x0
  pushl $223
  102810:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102815:	e9 ec f6 ff ff       	jmp    101f06 <__alltraps>

0010281a <vector224>:
.globl vector224
vector224:
  pushl $0
  10281a:	6a 00                	push   $0x0
  pushl $224
  10281c:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102821:	e9 e0 f6 ff ff       	jmp    101f06 <__alltraps>

00102826 <vector225>:
.globl vector225
vector225:
  pushl $0
  102826:	6a 00                	push   $0x0
  pushl $225
  102828:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10282d:	e9 d4 f6 ff ff       	jmp    101f06 <__alltraps>

00102832 <vector226>:
.globl vector226
vector226:
  pushl $0
  102832:	6a 00                	push   $0x0
  pushl $226
  102834:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102839:	e9 c8 f6 ff ff       	jmp    101f06 <__alltraps>

0010283e <vector227>:
.globl vector227
vector227:
  pushl $0
  10283e:	6a 00                	push   $0x0
  pushl $227
  102840:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102845:	e9 bc f6 ff ff       	jmp    101f06 <__alltraps>

0010284a <vector228>:
.globl vector228
vector228:
  pushl $0
  10284a:	6a 00                	push   $0x0
  pushl $228
  10284c:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102851:	e9 b0 f6 ff ff       	jmp    101f06 <__alltraps>

00102856 <vector229>:
.globl vector229
vector229:
  pushl $0
  102856:	6a 00                	push   $0x0
  pushl $229
  102858:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10285d:	e9 a4 f6 ff ff       	jmp    101f06 <__alltraps>

00102862 <vector230>:
.globl vector230
vector230:
  pushl $0
  102862:	6a 00                	push   $0x0
  pushl $230
  102864:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102869:	e9 98 f6 ff ff       	jmp    101f06 <__alltraps>

0010286e <vector231>:
.globl vector231
vector231:
  pushl $0
  10286e:	6a 00                	push   $0x0
  pushl $231
  102870:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102875:	e9 8c f6 ff ff       	jmp    101f06 <__alltraps>

0010287a <vector232>:
.globl vector232
vector232:
  pushl $0
  10287a:	6a 00                	push   $0x0
  pushl $232
  10287c:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102881:	e9 80 f6 ff ff       	jmp    101f06 <__alltraps>

00102886 <vector233>:
.globl vector233
vector233:
  pushl $0
  102886:	6a 00                	push   $0x0
  pushl $233
  102888:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10288d:	e9 74 f6 ff ff       	jmp    101f06 <__alltraps>

00102892 <vector234>:
.globl vector234
vector234:
  pushl $0
  102892:	6a 00                	push   $0x0
  pushl $234
  102894:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102899:	e9 68 f6 ff ff       	jmp    101f06 <__alltraps>

0010289e <vector235>:
.globl vector235
vector235:
  pushl $0
  10289e:	6a 00                	push   $0x0
  pushl $235
  1028a0:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028a5:	e9 5c f6 ff ff       	jmp    101f06 <__alltraps>

001028aa <vector236>:
.globl vector236
vector236:
  pushl $0
  1028aa:	6a 00                	push   $0x0
  pushl $236
  1028ac:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028b1:	e9 50 f6 ff ff       	jmp    101f06 <__alltraps>

001028b6 <vector237>:
.globl vector237
vector237:
  pushl $0
  1028b6:	6a 00                	push   $0x0
  pushl $237
  1028b8:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1028bd:	e9 44 f6 ff ff       	jmp    101f06 <__alltraps>

001028c2 <vector238>:
.globl vector238
vector238:
  pushl $0
  1028c2:	6a 00                	push   $0x0
  pushl $238
  1028c4:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1028c9:	e9 38 f6 ff ff       	jmp    101f06 <__alltraps>

001028ce <vector239>:
.globl vector239
vector239:
  pushl $0
  1028ce:	6a 00                	push   $0x0
  pushl $239
  1028d0:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1028d5:	e9 2c f6 ff ff       	jmp    101f06 <__alltraps>

001028da <vector240>:
.globl vector240
vector240:
  pushl $0
  1028da:	6a 00                	push   $0x0
  pushl $240
  1028dc:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1028e1:	e9 20 f6 ff ff       	jmp    101f06 <__alltraps>

001028e6 <vector241>:
.globl vector241
vector241:
  pushl $0
  1028e6:	6a 00                	push   $0x0
  pushl $241
  1028e8:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1028ed:	e9 14 f6 ff ff       	jmp    101f06 <__alltraps>

001028f2 <vector242>:
.globl vector242
vector242:
  pushl $0
  1028f2:	6a 00                	push   $0x0
  pushl $242
  1028f4:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1028f9:	e9 08 f6 ff ff       	jmp    101f06 <__alltraps>

001028fe <vector243>:
.globl vector243
vector243:
  pushl $0
  1028fe:	6a 00                	push   $0x0
  pushl $243
  102900:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102905:	e9 fc f5 ff ff       	jmp    101f06 <__alltraps>

0010290a <vector244>:
.globl vector244
vector244:
  pushl $0
  10290a:	6a 00                	push   $0x0
  pushl $244
  10290c:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102911:	e9 f0 f5 ff ff       	jmp    101f06 <__alltraps>

00102916 <vector245>:
.globl vector245
vector245:
  pushl $0
  102916:	6a 00                	push   $0x0
  pushl $245
  102918:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10291d:	e9 e4 f5 ff ff       	jmp    101f06 <__alltraps>

00102922 <vector246>:
.globl vector246
vector246:
  pushl $0
  102922:	6a 00                	push   $0x0
  pushl $246
  102924:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102929:	e9 d8 f5 ff ff       	jmp    101f06 <__alltraps>

0010292e <vector247>:
.globl vector247
vector247:
  pushl $0
  10292e:	6a 00                	push   $0x0
  pushl $247
  102930:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102935:	e9 cc f5 ff ff       	jmp    101f06 <__alltraps>

0010293a <vector248>:
.globl vector248
vector248:
  pushl $0
  10293a:	6a 00                	push   $0x0
  pushl $248
  10293c:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102941:	e9 c0 f5 ff ff       	jmp    101f06 <__alltraps>

00102946 <vector249>:
.globl vector249
vector249:
  pushl $0
  102946:	6a 00                	push   $0x0
  pushl $249
  102948:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10294d:	e9 b4 f5 ff ff       	jmp    101f06 <__alltraps>

00102952 <vector250>:
.globl vector250
vector250:
  pushl $0
  102952:	6a 00                	push   $0x0
  pushl $250
  102954:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102959:	e9 a8 f5 ff ff       	jmp    101f06 <__alltraps>

0010295e <vector251>:
.globl vector251
vector251:
  pushl $0
  10295e:	6a 00                	push   $0x0
  pushl $251
  102960:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102965:	e9 9c f5 ff ff       	jmp    101f06 <__alltraps>

0010296a <vector252>:
.globl vector252
vector252:
  pushl $0
  10296a:	6a 00                	push   $0x0
  pushl $252
  10296c:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102971:	e9 90 f5 ff ff       	jmp    101f06 <__alltraps>

00102976 <vector253>:
.globl vector253
vector253:
  pushl $0
  102976:	6a 00                	push   $0x0
  pushl $253
  102978:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10297d:	e9 84 f5 ff ff       	jmp    101f06 <__alltraps>

00102982 <vector254>:
.globl vector254
vector254:
  pushl $0
  102982:	6a 00                	push   $0x0
  pushl $254
  102984:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102989:	e9 78 f5 ff ff       	jmp    101f06 <__alltraps>

0010298e <vector255>:
.globl vector255
vector255:
  pushl $0
  10298e:	6a 00                	push   $0x0
  pushl $255
  102990:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102995:	e9 6c f5 ff ff       	jmp    101f06 <__alltraps>

0010299a <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10299a:	55                   	push   %ebp
  10299b:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  10299d:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a0:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1029a3:	b8 23 00 00 00       	mov    $0x23,%eax
  1029a8:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1029aa:	b8 23 00 00 00       	mov    $0x23,%eax
  1029af:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1029b1:	b8 10 00 00 00       	mov    $0x10,%eax
  1029b6:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1029b8:	b8 10 00 00 00       	mov    $0x10,%eax
  1029bd:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1029bf:	b8 10 00 00 00       	mov    $0x10,%eax
  1029c4:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  1029c6:	ea cd 29 10 00 08 00 	ljmp   $0x8,$0x1029cd
}
  1029cd:	90                   	nop
  1029ce:	5d                   	pop    %ebp
  1029cf:	c3                   	ret    

001029d0 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  1029d0:	55                   	push   %ebp
  1029d1:	89 e5                	mov    %esp,%ebp
  1029d3:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  1029d6:	b8 a0 08 11 00       	mov    $0x1108a0,%eax
  1029db:	05 00 04 00 00       	add    $0x400,%eax
  1029e0:	a3 a4 0c 11 00       	mov    %eax,0x110ca4
    ts.ts_ss0 = KERNEL_DS;
  1029e5:	66 c7 05 a8 0c 11 00 	movw   $0x10,0x110ca8
  1029ec:	10 00 

    // initialize the TSS file of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  1029ee:	66 c7 05 08 fa 10 00 	movw   $0x68,0x10fa08
  1029f5:	68 00 
  1029f7:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  1029fc:	0f b7 c0             	movzwl %ax,%eax
  1029ff:	66 a3 0a fa 10 00    	mov    %ax,0x10fa0a
  102a05:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  102a0a:	c1 e8 10             	shr    $0x10,%eax
  102a0d:	a2 0c fa 10 00       	mov    %al,0x10fa0c
  102a12:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a19:	24 f0                	and    $0xf0,%al
  102a1b:	0c 09                	or     $0x9,%al
  102a1d:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a22:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a29:	0c 10                	or     $0x10,%al
  102a2b:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a30:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a37:	24 9f                	and    $0x9f,%al
  102a39:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a3e:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a45:	0c 80                	or     $0x80,%al
  102a47:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a4c:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102a53:	24 f0                	and    $0xf0,%al
  102a55:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102a5a:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102a61:	24 ef                	and    $0xef,%al
  102a63:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102a68:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102a6f:	24 df                	and    $0xdf,%al
  102a71:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102a76:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102a7d:	0c 40                	or     $0x40,%al
  102a7f:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102a84:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102a8b:	24 7f                	and    $0x7f,%al
  102a8d:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102a92:	b8 a0 0c 11 00       	mov    $0x110ca0,%eax
  102a97:	c1 e8 18             	shr    $0x18,%eax
  102a9a:	a2 0f fa 10 00       	mov    %al,0x10fa0f
    gdt[SEG_TSS].sd_s = 0;
  102a9f:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102aa6:	24 ef                	and    $0xef,%al
  102aa8:	a2 0d fa 10 00       	mov    %al,0x10fa0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102aad:	c7 04 24 10 fa 10 00 	movl   $0x10fa10,(%esp)
  102ab4:	e8 e1 fe ff ff       	call   10299a <lgdt>
  102ab9:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102abf:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102ac3:	0f 00 d8             	ltr    %ax
}
  102ac6:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102ac7:	90                   	nop
  102ac8:	89 ec                	mov    %ebp,%esp
  102aca:	5d                   	pop    %ebp
  102acb:	c3                   	ret    

00102acc <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102acc:	55                   	push   %ebp
  102acd:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102acf:	e8 fc fe ff ff       	call   1029d0 <gdt_init>
}
  102ad4:	90                   	nop
  102ad5:	5d                   	pop    %ebp
  102ad6:	c3                   	ret    

00102ad7 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102ad7:	55                   	push   %ebp
  102ad8:	89 e5                	mov    %esp,%ebp
  102ada:	83 ec 58             	sub    $0x58,%esp
  102add:	8b 45 10             	mov    0x10(%ebp),%eax
  102ae0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ae3:	8b 45 14             	mov    0x14(%ebp),%eax
  102ae6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102ae9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102aec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102aef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102af2:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102af5:	8b 45 18             	mov    0x18(%ebp),%eax
  102af8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102afe:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102b01:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102b04:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102b11:	74 1c                	je     102b2f <printnum+0x58>
  102b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b16:	ba 00 00 00 00       	mov    $0x0,%edx
  102b1b:	f7 75 e4             	divl   -0x1c(%ebp)
  102b1e:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b24:	ba 00 00 00 00       	mov    $0x0,%edx
  102b29:	f7 75 e4             	divl   -0x1c(%ebp)
  102b2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b35:	f7 75 e4             	divl   -0x1c(%ebp)
  102b38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102b3b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102b3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102b44:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102b47:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102b4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102b4d:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102b50:	8b 45 18             	mov    0x18(%ebp),%eax
  102b53:	ba 00 00 00 00       	mov    $0x0,%edx
  102b58:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  102b5b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  102b5e:	19 d1                	sbb    %edx,%ecx
  102b60:	72 4c                	jb     102bae <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102b62:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102b65:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b68:	8b 45 20             	mov    0x20(%ebp),%eax
  102b6b:	89 44 24 18          	mov    %eax,0x18(%esp)
  102b6f:	89 54 24 14          	mov    %edx,0x14(%esp)
  102b73:	8b 45 18             	mov    0x18(%ebp),%eax
  102b76:	89 44 24 10          	mov    %eax,0x10(%esp)
  102b7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b7d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102b80:	89 44 24 08          	mov    %eax,0x8(%esp)
  102b84:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b92:	89 04 24             	mov    %eax,(%esp)
  102b95:	e8 3d ff ff ff       	call   102ad7 <printnum>
  102b9a:	eb 1b                	jmp    102bb7 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ba3:	8b 45 20             	mov    0x20(%ebp),%eax
  102ba6:	89 04 24             	mov    %eax,(%esp)
  102ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bac:	ff d0                	call   *%eax
        while (-- width > 0)
  102bae:	ff 4d 1c             	decl   0x1c(%ebp)
  102bb1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102bb5:	7f e5                	jg     102b9c <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102bb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102bba:	05 d0 3d 10 00       	add    $0x103dd0,%eax
  102bbf:	0f b6 00             	movzbl (%eax),%eax
  102bc2:	0f be c0             	movsbl %al,%eax
  102bc5:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bc8:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bcc:	89 04 24             	mov    %eax,(%esp)
  102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd2:	ff d0                	call   *%eax
}
  102bd4:	90                   	nop
  102bd5:	89 ec                	mov    %ebp,%esp
  102bd7:	5d                   	pop    %ebp
  102bd8:	c3                   	ret    

00102bd9 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102bd9:	55                   	push   %ebp
  102bda:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102bdc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102be0:	7e 14                	jle    102bf6 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102be2:	8b 45 08             	mov    0x8(%ebp),%eax
  102be5:	8b 00                	mov    (%eax),%eax
  102be7:	8d 48 08             	lea    0x8(%eax),%ecx
  102bea:	8b 55 08             	mov    0x8(%ebp),%edx
  102bed:	89 0a                	mov    %ecx,(%edx)
  102bef:	8b 50 04             	mov    0x4(%eax),%edx
  102bf2:	8b 00                	mov    (%eax),%eax
  102bf4:	eb 30                	jmp    102c26 <getuint+0x4d>
    }
    else if (lflag) {
  102bf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102bfa:	74 16                	je     102c12 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  102bff:	8b 00                	mov    (%eax),%eax
  102c01:	8d 48 04             	lea    0x4(%eax),%ecx
  102c04:	8b 55 08             	mov    0x8(%ebp),%edx
  102c07:	89 0a                	mov    %ecx,(%edx)
  102c09:	8b 00                	mov    (%eax),%eax
  102c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  102c10:	eb 14                	jmp    102c26 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102c12:	8b 45 08             	mov    0x8(%ebp),%eax
  102c15:	8b 00                	mov    (%eax),%eax
  102c17:	8d 48 04             	lea    0x4(%eax),%ecx
  102c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  102c1d:	89 0a                	mov    %ecx,(%edx)
  102c1f:	8b 00                	mov    (%eax),%eax
  102c21:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102c26:	5d                   	pop    %ebp
  102c27:	c3                   	ret    

00102c28 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102c28:	55                   	push   %ebp
  102c29:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102c2b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102c2f:	7e 14                	jle    102c45 <getint+0x1d>
        return va_arg(*ap, long long);
  102c31:	8b 45 08             	mov    0x8(%ebp),%eax
  102c34:	8b 00                	mov    (%eax),%eax
  102c36:	8d 48 08             	lea    0x8(%eax),%ecx
  102c39:	8b 55 08             	mov    0x8(%ebp),%edx
  102c3c:	89 0a                	mov    %ecx,(%edx)
  102c3e:	8b 50 04             	mov    0x4(%eax),%edx
  102c41:	8b 00                	mov    (%eax),%eax
  102c43:	eb 28                	jmp    102c6d <getint+0x45>
    }
    else if (lflag) {
  102c45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c49:	74 12                	je     102c5d <getint+0x35>
        return va_arg(*ap, long);
  102c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  102c4e:	8b 00                	mov    (%eax),%eax
  102c50:	8d 48 04             	lea    0x4(%eax),%ecx
  102c53:	8b 55 08             	mov    0x8(%ebp),%edx
  102c56:	89 0a                	mov    %ecx,(%edx)
  102c58:	8b 00                	mov    (%eax),%eax
  102c5a:	99                   	cltd   
  102c5b:	eb 10                	jmp    102c6d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c60:	8b 00                	mov    (%eax),%eax
  102c62:	8d 48 04             	lea    0x4(%eax),%ecx
  102c65:	8b 55 08             	mov    0x8(%ebp),%edx
  102c68:	89 0a                	mov    %ecx,(%edx)
  102c6a:	8b 00                	mov    (%eax),%eax
  102c6c:	99                   	cltd   
    }
}
  102c6d:	5d                   	pop    %ebp
  102c6e:	c3                   	ret    

00102c6f <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102c6f:	55                   	push   %ebp
  102c70:	89 e5                	mov    %esp,%ebp
  102c72:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102c75:	8d 45 14             	lea    0x14(%ebp),%eax
  102c78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102c82:	8b 45 10             	mov    0x10(%ebp),%eax
  102c85:	89 44 24 08          	mov    %eax,0x8(%esp)
  102c89:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c90:	8b 45 08             	mov    0x8(%ebp),%eax
  102c93:	89 04 24             	mov    %eax,(%esp)
  102c96:	e8 05 00 00 00       	call   102ca0 <vprintfmt>
    va_end(ap);
}
  102c9b:	90                   	nop
  102c9c:	89 ec                	mov    %ebp,%esp
  102c9e:	5d                   	pop    %ebp
  102c9f:	c3                   	ret    

00102ca0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102ca0:	55                   	push   %ebp
  102ca1:	89 e5                	mov    %esp,%ebp
  102ca3:	56                   	push   %esi
  102ca4:	53                   	push   %ebx
  102ca5:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102ca8:	eb 17                	jmp    102cc1 <vprintfmt+0x21>
            if (ch == '\0') {
  102caa:	85 db                	test   %ebx,%ebx
  102cac:	0f 84 bf 03 00 00    	je     103071 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  102cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102cb9:	89 1c 24             	mov    %ebx,(%esp)
  102cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  102cbf:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102cc1:	8b 45 10             	mov    0x10(%ebp),%eax
  102cc4:	8d 50 01             	lea    0x1(%eax),%edx
  102cc7:	89 55 10             	mov    %edx,0x10(%ebp)
  102cca:	0f b6 00             	movzbl (%eax),%eax
  102ccd:	0f b6 d8             	movzbl %al,%ebx
  102cd0:	83 fb 25             	cmp    $0x25,%ebx
  102cd3:	75 d5                	jne    102caa <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  102cd5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102cd9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102ce0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ce3:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102ce6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102ced:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102cf0:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  102cf6:	8d 50 01             	lea    0x1(%eax),%edx
  102cf9:	89 55 10             	mov    %edx,0x10(%ebp)
  102cfc:	0f b6 00             	movzbl (%eax),%eax
  102cff:	0f b6 d8             	movzbl %al,%ebx
  102d02:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102d05:	83 f8 55             	cmp    $0x55,%eax
  102d08:	0f 87 37 03 00 00    	ja     103045 <vprintfmt+0x3a5>
  102d0e:	8b 04 85 f4 3d 10 00 	mov    0x103df4(,%eax,4),%eax
  102d15:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102d17:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102d1b:	eb d6                	jmp    102cf3 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102d1d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102d21:	eb d0                	jmp    102cf3 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102d23:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102d2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d2d:	89 d0                	mov    %edx,%eax
  102d2f:	c1 e0 02             	shl    $0x2,%eax
  102d32:	01 d0                	add    %edx,%eax
  102d34:	01 c0                	add    %eax,%eax
  102d36:	01 d8                	add    %ebx,%eax
  102d38:	83 e8 30             	sub    $0x30,%eax
  102d3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102d3e:	8b 45 10             	mov    0x10(%ebp),%eax
  102d41:	0f b6 00             	movzbl (%eax),%eax
  102d44:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102d47:	83 fb 2f             	cmp    $0x2f,%ebx
  102d4a:	7e 38                	jle    102d84 <vprintfmt+0xe4>
  102d4c:	83 fb 39             	cmp    $0x39,%ebx
  102d4f:	7f 33                	jg     102d84 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  102d51:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  102d54:	eb d4                	jmp    102d2a <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  102d56:	8b 45 14             	mov    0x14(%ebp),%eax
  102d59:	8d 50 04             	lea    0x4(%eax),%edx
  102d5c:	89 55 14             	mov    %edx,0x14(%ebp)
  102d5f:	8b 00                	mov    (%eax),%eax
  102d61:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102d64:	eb 1f                	jmp    102d85 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  102d66:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d6a:	79 87                	jns    102cf3 <vprintfmt+0x53>
                width = 0;
  102d6c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102d73:	e9 7b ff ff ff       	jmp    102cf3 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  102d78:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102d7f:	e9 6f ff ff ff       	jmp    102cf3 <vprintfmt+0x53>
            goto process_precision;
  102d84:	90                   	nop

        process_precision:
            if (width < 0)
  102d85:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d89:	0f 89 64 ff ff ff    	jns    102cf3 <vprintfmt+0x53>
                width = precision, precision = -1;
  102d8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d92:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d95:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102d9c:	e9 52 ff ff ff       	jmp    102cf3 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102da1:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  102da4:	e9 4a ff ff ff       	jmp    102cf3 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102da9:	8b 45 14             	mov    0x14(%ebp),%eax
  102dac:	8d 50 04             	lea    0x4(%eax),%edx
  102daf:	89 55 14             	mov    %edx,0x14(%ebp)
  102db2:	8b 00                	mov    (%eax),%eax
  102db4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102db7:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dbb:	89 04 24             	mov    %eax,(%esp)
  102dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102dc1:	ff d0                	call   *%eax
            break;
  102dc3:	e9 a4 02 00 00       	jmp    10306c <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102dc8:	8b 45 14             	mov    0x14(%ebp),%eax
  102dcb:	8d 50 04             	lea    0x4(%eax),%edx
  102dce:	89 55 14             	mov    %edx,0x14(%ebp)
  102dd1:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102dd3:	85 db                	test   %ebx,%ebx
  102dd5:	79 02                	jns    102dd9 <vprintfmt+0x139>
                err = -err;
  102dd7:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102dd9:	83 fb 06             	cmp    $0x6,%ebx
  102ddc:	7f 0b                	jg     102de9 <vprintfmt+0x149>
  102dde:	8b 34 9d b4 3d 10 00 	mov    0x103db4(,%ebx,4),%esi
  102de5:	85 f6                	test   %esi,%esi
  102de7:	75 23                	jne    102e0c <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  102de9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102ded:	c7 44 24 08 e1 3d 10 	movl   $0x103de1,0x8(%esp)
  102df4:	00 
  102df5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102df8:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  102dff:	89 04 24             	mov    %eax,(%esp)
  102e02:	e8 68 fe ff ff       	call   102c6f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102e07:	e9 60 02 00 00       	jmp    10306c <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  102e0c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102e10:	c7 44 24 08 ea 3d 10 	movl   $0x103dea,0x8(%esp)
  102e17:	00 
  102e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  102e22:	89 04 24             	mov    %eax,(%esp)
  102e25:	e8 45 fe ff ff       	call   102c6f <printfmt>
            break;
  102e2a:	e9 3d 02 00 00       	jmp    10306c <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102e2f:	8b 45 14             	mov    0x14(%ebp),%eax
  102e32:	8d 50 04             	lea    0x4(%eax),%edx
  102e35:	89 55 14             	mov    %edx,0x14(%ebp)
  102e38:	8b 30                	mov    (%eax),%esi
  102e3a:	85 f6                	test   %esi,%esi
  102e3c:	75 05                	jne    102e43 <vprintfmt+0x1a3>
                p = "(null)";
  102e3e:	be ed 3d 10 00       	mov    $0x103ded,%esi
            }
            if (width > 0 && padc != '-') {
  102e43:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e47:	7e 76                	jle    102ebf <vprintfmt+0x21f>
  102e49:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102e4d:	74 70                	je     102ebf <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e56:	89 34 24             	mov    %esi,(%esp)
  102e59:	e8 16 03 00 00       	call   103174 <strnlen>
  102e5e:	89 c2                	mov    %eax,%edx
  102e60:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e63:	29 d0                	sub    %edx,%eax
  102e65:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e68:	eb 16                	jmp    102e80 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  102e6a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e71:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e75:	89 04 24             	mov    %eax,(%esp)
  102e78:	8b 45 08             	mov    0x8(%ebp),%eax
  102e7b:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  102e7d:	ff 4d e8             	decl   -0x18(%ebp)
  102e80:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e84:	7f e4                	jg     102e6a <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e86:	eb 37                	jmp    102ebf <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  102e88:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102e8c:	74 1f                	je     102ead <vprintfmt+0x20d>
  102e8e:	83 fb 1f             	cmp    $0x1f,%ebx
  102e91:	7e 05                	jle    102e98 <vprintfmt+0x1f8>
  102e93:	83 fb 7e             	cmp    $0x7e,%ebx
  102e96:	7e 15                	jle    102ead <vprintfmt+0x20d>
                    putch('?', putdat);
  102e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e9f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea9:	ff d0                	call   *%eax
  102eab:	eb 0f                	jmp    102ebc <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eb4:	89 1c 24             	mov    %ebx,(%esp)
  102eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  102eba:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102ebc:	ff 4d e8             	decl   -0x18(%ebp)
  102ebf:	89 f0                	mov    %esi,%eax
  102ec1:	8d 70 01             	lea    0x1(%eax),%esi
  102ec4:	0f b6 00             	movzbl (%eax),%eax
  102ec7:	0f be d8             	movsbl %al,%ebx
  102eca:	85 db                	test   %ebx,%ebx
  102ecc:	74 27                	je     102ef5 <vprintfmt+0x255>
  102ece:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102ed2:	78 b4                	js     102e88 <vprintfmt+0x1e8>
  102ed4:	ff 4d e4             	decl   -0x1c(%ebp)
  102ed7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102edb:	79 ab                	jns    102e88 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  102edd:	eb 16                	jmp    102ef5 <vprintfmt+0x255>
                putch(' ', putdat);
  102edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ee6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102eed:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef0:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  102ef2:	ff 4d e8             	decl   -0x18(%ebp)
  102ef5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102ef9:	7f e4                	jg     102edf <vprintfmt+0x23f>
            }
            break;
  102efb:	e9 6c 01 00 00       	jmp    10306c <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f07:	8d 45 14             	lea    0x14(%ebp),%eax
  102f0a:	89 04 24             	mov    %eax,(%esp)
  102f0d:	e8 16 fd ff ff       	call   102c28 <getint>
  102f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f15:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f1e:	85 d2                	test   %edx,%edx
  102f20:	79 26                	jns    102f48 <vprintfmt+0x2a8>
                putch('-', putdat);
  102f22:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f29:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102f30:	8b 45 08             	mov    0x8(%ebp),%eax
  102f33:	ff d0                	call   *%eax
                num = -(long long)num;
  102f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f3b:	f7 d8                	neg    %eax
  102f3d:	83 d2 00             	adc    $0x0,%edx
  102f40:	f7 da                	neg    %edx
  102f42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f45:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102f48:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102f4f:	e9 a8 00 00 00       	jmp    102ffc <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102f54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f5b:	8d 45 14             	lea    0x14(%ebp),%eax
  102f5e:	89 04 24             	mov    %eax,(%esp)
  102f61:	e8 73 fc ff ff       	call   102bd9 <getuint>
  102f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f69:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102f6c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102f73:	e9 84 00 00 00       	jmp    102ffc <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f7f:	8d 45 14             	lea    0x14(%ebp),%eax
  102f82:	89 04 24             	mov    %eax,(%esp)
  102f85:	e8 4f fc ff ff       	call   102bd9 <getuint>
  102f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f8d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102f90:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102f97:	eb 63                	jmp    102ffc <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  102f99:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fa0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  102faa:	ff d0                	call   *%eax
            putch('x', putdat);
  102fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  102faf:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fb3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102fba:	8b 45 08             	mov    0x8(%ebp),%eax
  102fbd:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  102fc2:	8d 50 04             	lea    0x4(%eax),%edx
  102fc5:	89 55 14             	mov    %edx,0x14(%ebp)
  102fc8:	8b 00                	mov    (%eax),%eax
  102fca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fcd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102fd4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102fdb:	eb 1f                	jmp    102ffc <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fe4:	8d 45 14             	lea    0x14(%ebp),%eax
  102fe7:	89 04 24             	mov    %eax,(%esp)
  102fea:	e8 ea fb ff ff       	call   102bd9 <getuint>
  102fef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ff2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102ff5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102ffc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103000:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103003:	89 54 24 18          	mov    %edx,0x18(%esp)
  103007:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10300a:	89 54 24 14          	mov    %edx,0x14(%esp)
  10300e:	89 44 24 10          	mov    %eax,0x10(%esp)
  103012:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103015:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103018:	89 44 24 08          	mov    %eax,0x8(%esp)
  10301c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103020:	8b 45 0c             	mov    0xc(%ebp),%eax
  103023:	89 44 24 04          	mov    %eax,0x4(%esp)
  103027:	8b 45 08             	mov    0x8(%ebp),%eax
  10302a:	89 04 24             	mov    %eax,(%esp)
  10302d:	e8 a5 fa ff ff       	call   102ad7 <printnum>
            break;
  103032:	eb 38                	jmp    10306c <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  103034:	8b 45 0c             	mov    0xc(%ebp),%eax
  103037:	89 44 24 04          	mov    %eax,0x4(%esp)
  10303b:	89 1c 24             	mov    %ebx,(%esp)
  10303e:	8b 45 08             	mov    0x8(%ebp),%eax
  103041:	ff d0                	call   *%eax
            break;
  103043:	eb 27                	jmp    10306c <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103045:	8b 45 0c             	mov    0xc(%ebp),%eax
  103048:	89 44 24 04          	mov    %eax,0x4(%esp)
  10304c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103053:	8b 45 08             	mov    0x8(%ebp),%eax
  103056:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  103058:	ff 4d 10             	decl   0x10(%ebp)
  10305b:	eb 03                	jmp    103060 <vprintfmt+0x3c0>
  10305d:	ff 4d 10             	decl   0x10(%ebp)
  103060:	8b 45 10             	mov    0x10(%ebp),%eax
  103063:	48                   	dec    %eax
  103064:	0f b6 00             	movzbl (%eax),%eax
  103067:	3c 25                	cmp    $0x25,%al
  103069:	75 f2                	jne    10305d <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  10306b:	90                   	nop
    while (1) {
  10306c:	e9 37 fc ff ff       	jmp    102ca8 <vprintfmt+0x8>
                return;
  103071:	90                   	nop
        }
    }
}
  103072:	83 c4 40             	add    $0x40,%esp
  103075:	5b                   	pop    %ebx
  103076:	5e                   	pop    %esi
  103077:	5d                   	pop    %ebp
  103078:	c3                   	ret    

00103079 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  103079:	55                   	push   %ebp
  10307a:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10307c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10307f:	8b 40 08             	mov    0x8(%eax),%eax
  103082:	8d 50 01             	lea    0x1(%eax),%edx
  103085:	8b 45 0c             	mov    0xc(%ebp),%eax
  103088:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  10308b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10308e:	8b 10                	mov    (%eax),%edx
  103090:	8b 45 0c             	mov    0xc(%ebp),%eax
  103093:	8b 40 04             	mov    0x4(%eax),%eax
  103096:	39 c2                	cmp    %eax,%edx
  103098:	73 12                	jae    1030ac <sprintputch+0x33>
        *b->buf ++ = ch;
  10309a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10309d:	8b 00                	mov    (%eax),%eax
  10309f:	8d 48 01             	lea    0x1(%eax),%ecx
  1030a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030a5:	89 0a                	mov    %ecx,(%edx)
  1030a7:	8b 55 08             	mov    0x8(%ebp),%edx
  1030aa:	88 10                	mov    %dl,(%eax)
    }
}
  1030ac:	90                   	nop
  1030ad:	5d                   	pop    %ebp
  1030ae:	c3                   	ret    

001030af <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1030af:	55                   	push   %ebp
  1030b0:	89 e5                	mov    %esp,%ebp
  1030b2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1030b5:	8d 45 14             	lea    0x14(%ebp),%eax
  1030b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1030bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1030c2:	8b 45 10             	mov    0x10(%ebp),%eax
  1030c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1030d3:	89 04 24             	mov    %eax,(%esp)
  1030d6:	e8 0a 00 00 00       	call   1030e5 <vsnprintf>
  1030db:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1030de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1030e1:	89 ec                	mov    %ebp,%esp
  1030e3:	5d                   	pop    %ebp
  1030e4:	c3                   	ret    

001030e5 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1030e5:	55                   	push   %ebp
  1030e6:	89 e5                	mov    %esp,%ebp
  1030e8:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1030eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030f4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1030fa:	01 d0                	add    %edx,%eax
  1030fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103106:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10310a:	74 0a                	je     103116 <vsnprintf+0x31>
  10310c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10310f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103112:	39 c2                	cmp    %eax,%edx
  103114:	76 07                	jbe    10311d <vsnprintf+0x38>
        return -E_INVAL;
  103116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10311b:	eb 2a                	jmp    103147 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  10311d:	8b 45 14             	mov    0x14(%ebp),%eax
  103120:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103124:	8b 45 10             	mov    0x10(%ebp),%eax
  103127:	89 44 24 08          	mov    %eax,0x8(%esp)
  10312b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  10312e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103132:	c7 04 24 79 30 10 00 	movl   $0x103079,(%esp)
  103139:	e8 62 fb ff ff       	call   102ca0 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  10313e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103141:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103144:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103147:	89 ec                	mov    %ebp,%esp
  103149:	5d                   	pop    %ebp
  10314a:	c3                   	ret    

0010314b <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10314b:	55                   	push   %ebp
  10314c:	89 e5                	mov    %esp,%ebp
  10314e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  103151:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  103158:	eb 03                	jmp    10315d <strlen+0x12>
        cnt ++;
  10315a:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  10315d:	8b 45 08             	mov    0x8(%ebp),%eax
  103160:	8d 50 01             	lea    0x1(%eax),%edx
  103163:	89 55 08             	mov    %edx,0x8(%ebp)
  103166:	0f b6 00             	movzbl (%eax),%eax
  103169:	84 c0                	test   %al,%al
  10316b:	75 ed                	jne    10315a <strlen+0xf>
    }
    return cnt;
  10316d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103170:	89 ec                	mov    %ebp,%esp
  103172:	5d                   	pop    %ebp
  103173:	c3                   	ret    

00103174 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  103174:	55                   	push   %ebp
  103175:	89 e5                	mov    %esp,%ebp
  103177:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10317a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  103181:	eb 03                	jmp    103186 <strnlen+0x12>
        cnt ++;
  103183:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  103186:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103189:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10318c:	73 10                	jae    10319e <strnlen+0x2a>
  10318e:	8b 45 08             	mov    0x8(%ebp),%eax
  103191:	8d 50 01             	lea    0x1(%eax),%edx
  103194:	89 55 08             	mov    %edx,0x8(%ebp)
  103197:	0f b6 00             	movzbl (%eax),%eax
  10319a:	84 c0                	test   %al,%al
  10319c:	75 e5                	jne    103183 <strnlen+0xf>
    }
    return cnt;
  10319e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1031a1:	89 ec                	mov    %ebp,%esp
  1031a3:	5d                   	pop    %ebp
  1031a4:	c3                   	ret    

001031a5 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1031a5:	55                   	push   %ebp
  1031a6:	89 e5                	mov    %esp,%ebp
  1031a8:	57                   	push   %edi
  1031a9:	56                   	push   %esi
  1031aa:	83 ec 20             	sub    $0x20,%esp
  1031ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1031b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1031b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1031bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031bf:	89 d1                	mov    %edx,%ecx
  1031c1:	89 c2                	mov    %eax,%edx
  1031c3:	89 ce                	mov    %ecx,%esi
  1031c5:	89 d7                	mov    %edx,%edi
  1031c7:	ac                   	lods   %ds:(%esi),%al
  1031c8:	aa                   	stos   %al,%es:(%edi)
  1031c9:	84 c0                	test   %al,%al
  1031cb:	75 fa                	jne    1031c7 <strcpy+0x22>
  1031cd:	89 fa                	mov    %edi,%edx
  1031cf:	89 f1                	mov    %esi,%ecx
  1031d1:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1031d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1031d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  1031da:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1031dd:	83 c4 20             	add    $0x20,%esp
  1031e0:	5e                   	pop    %esi
  1031e1:	5f                   	pop    %edi
  1031e2:	5d                   	pop    %ebp
  1031e3:	c3                   	ret    

001031e4 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1031e4:	55                   	push   %ebp
  1031e5:	89 e5                	mov    %esp,%ebp
  1031e7:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1031ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1031f0:	eb 1e                	jmp    103210 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1031f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031f5:	0f b6 10             	movzbl (%eax),%edx
  1031f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031fb:	88 10                	mov    %dl,(%eax)
  1031fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103200:	0f b6 00             	movzbl (%eax),%eax
  103203:	84 c0                	test   %al,%al
  103205:	74 03                	je     10320a <strncpy+0x26>
            src ++;
  103207:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  10320a:	ff 45 fc             	incl   -0x4(%ebp)
  10320d:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  103210:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103214:	75 dc                	jne    1031f2 <strncpy+0xe>
    }
    return dst;
  103216:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103219:	89 ec                	mov    %ebp,%esp
  10321b:	5d                   	pop    %ebp
  10321c:	c3                   	ret    

0010321d <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10321d:	55                   	push   %ebp
  10321e:	89 e5                	mov    %esp,%ebp
  103220:	57                   	push   %edi
  103221:	56                   	push   %esi
  103222:	83 ec 20             	sub    $0x20,%esp
  103225:	8b 45 08             	mov    0x8(%ebp),%eax
  103228:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10322b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10322e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  103231:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103234:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103237:	89 d1                	mov    %edx,%ecx
  103239:	89 c2                	mov    %eax,%edx
  10323b:	89 ce                	mov    %ecx,%esi
  10323d:	89 d7                	mov    %edx,%edi
  10323f:	ac                   	lods   %ds:(%esi),%al
  103240:	ae                   	scas   %es:(%edi),%al
  103241:	75 08                	jne    10324b <strcmp+0x2e>
  103243:	84 c0                	test   %al,%al
  103245:	75 f8                	jne    10323f <strcmp+0x22>
  103247:	31 c0                	xor    %eax,%eax
  103249:	eb 04                	jmp    10324f <strcmp+0x32>
  10324b:	19 c0                	sbb    %eax,%eax
  10324d:	0c 01                	or     $0x1,%al
  10324f:	89 fa                	mov    %edi,%edx
  103251:	89 f1                	mov    %esi,%ecx
  103253:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103256:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  103259:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  10325c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10325f:	83 c4 20             	add    $0x20,%esp
  103262:	5e                   	pop    %esi
  103263:	5f                   	pop    %edi
  103264:	5d                   	pop    %ebp
  103265:	c3                   	ret    

00103266 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  103266:	55                   	push   %ebp
  103267:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103269:	eb 09                	jmp    103274 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  10326b:	ff 4d 10             	decl   0x10(%ebp)
  10326e:	ff 45 08             	incl   0x8(%ebp)
  103271:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103274:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103278:	74 1a                	je     103294 <strncmp+0x2e>
  10327a:	8b 45 08             	mov    0x8(%ebp),%eax
  10327d:	0f b6 00             	movzbl (%eax),%eax
  103280:	84 c0                	test   %al,%al
  103282:	74 10                	je     103294 <strncmp+0x2e>
  103284:	8b 45 08             	mov    0x8(%ebp),%eax
  103287:	0f b6 10             	movzbl (%eax),%edx
  10328a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10328d:	0f b6 00             	movzbl (%eax),%eax
  103290:	38 c2                	cmp    %al,%dl
  103292:	74 d7                	je     10326b <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  103294:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103298:	74 18                	je     1032b2 <strncmp+0x4c>
  10329a:	8b 45 08             	mov    0x8(%ebp),%eax
  10329d:	0f b6 00             	movzbl (%eax),%eax
  1032a0:	0f b6 d0             	movzbl %al,%edx
  1032a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a6:	0f b6 00             	movzbl (%eax),%eax
  1032a9:	0f b6 c8             	movzbl %al,%ecx
  1032ac:	89 d0                	mov    %edx,%eax
  1032ae:	29 c8                	sub    %ecx,%eax
  1032b0:	eb 05                	jmp    1032b7 <strncmp+0x51>
  1032b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1032b7:	5d                   	pop    %ebp
  1032b8:	c3                   	ret    

001032b9 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1032b9:	55                   	push   %ebp
  1032ba:	89 e5                	mov    %esp,%ebp
  1032bc:	83 ec 04             	sub    $0x4,%esp
  1032bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032c2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1032c5:	eb 13                	jmp    1032da <strchr+0x21>
        if (*s == c) {
  1032c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ca:	0f b6 00             	movzbl (%eax),%eax
  1032cd:	38 45 fc             	cmp    %al,-0x4(%ebp)
  1032d0:	75 05                	jne    1032d7 <strchr+0x1e>
            return (char *)s;
  1032d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1032d5:	eb 12                	jmp    1032e9 <strchr+0x30>
        }
        s ++;
  1032d7:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  1032da:	8b 45 08             	mov    0x8(%ebp),%eax
  1032dd:	0f b6 00             	movzbl (%eax),%eax
  1032e0:	84 c0                	test   %al,%al
  1032e2:	75 e3                	jne    1032c7 <strchr+0xe>
    }
    return NULL;
  1032e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1032e9:	89 ec                	mov    %ebp,%esp
  1032eb:	5d                   	pop    %ebp
  1032ec:	c3                   	ret    

001032ed <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1032ed:	55                   	push   %ebp
  1032ee:	89 e5                	mov    %esp,%ebp
  1032f0:	83 ec 04             	sub    $0x4,%esp
  1032f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032f6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1032f9:	eb 0e                	jmp    103309 <strfind+0x1c>
        if (*s == c) {
  1032fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1032fe:	0f b6 00             	movzbl (%eax),%eax
  103301:	38 45 fc             	cmp    %al,-0x4(%ebp)
  103304:	74 0f                	je     103315 <strfind+0x28>
            break;
        }
        s ++;
  103306:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  103309:	8b 45 08             	mov    0x8(%ebp),%eax
  10330c:	0f b6 00             	movzbl (%eax),%eax
  10330f:	84 c0                	test   %al,%al
  103311:	75 e8                	jne    1032fb <strfind+0xe>
  103313:	eb 01                	jmp    103316 <strfind+0x29>
            break;
  103315:	90                   	nop
    }
    return (char *)s;
  103316:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103319:	89 ec                	mov    %ebp,%esp
  10331b:	5d                   	pop    %ebp
  10331c:	c3                   	ret    

0010331d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  10331d:	55                   	push   %ebp
  10331e:	89 e5                	mov    %esp,%ebp
  103320:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  103323:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  10332a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  103331:	eb 03                	jmp    103336 <strtol+0x19>
        s ++;
  103333:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  103336:	8b 45 08             	mov    0x8(%ebp),%eax
  103339:	0f b6 00             	movzbl (%eax),%eax
  10333c:	3c 20                	cmp    $0x20,%al
  10333e:	74 f3                	je     103333 <strtol+0x16>
  103340:	8b 45 08             	mov    0x8(%ebp),%eax
  103343:	0f b6 00             	movzbl (%eax),%eax
  103346:	3c 09                	cmp    $0x9,%al
  103348:	74 e9                	je     103333 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  10334a:	8b 45 08             	mov    0x8(%ebp),%eax
  10334d:	0f b6 00             	movzbl (%eax),%eax
  103350:	3c 2b                	cmp    $0x2b,%al
  103352:	75 05                	jne    103359 <strtol+0x3c>
        s ++;
  103354:	ff 45 08             	incl   0x8(%ebp)
  103357:	eb 14                	jmp    10336d <strtol+0x50>
    }
    else if (*s == '-') {
  103359:	8b 45 08             	mov    0x8(%ebp),%eax
  10335c:	0f b6 00             	movzbl (%eax),%eax
  10335f:	3c 2d                	cmp    $0x2d,%al
  103361:	75 0a                	jne    10336d <strtol+0x50>
        s ++, neg = 1;
  103363:	ff 45 08             	incl   0x8(%ebp)
  103366:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  10336d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103371:	74 06                	je     103379 <strtol+0x5c>
  103373:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  103377:	75 22                	jne    10339b <strtol+0x7e>
  103379:	8b 45 08             	mov    0x8(%ebp),%eax
  10337c:	0f b6 00             	movzbl (%eax),%eax
  10337f:	3c 30                	cmp    $0x30,%al
  103381:	75 18                	jne    10339b <strtol+0x7e>
  103383:	8b 45 08             	mov    0x8(%ebp),%eax
  103386:	40                   	inc    %eax
  103387:	0f b6 00             	movzbl (%eax),%eax
  10338a:	3c 78                	cmp    $0x78,%al
  10338c:	75 0d                	jne    10339b <strtol+0x7e>
        s += 2, base = 16;
  10338e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  103392:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  103399:	eb 29                	jmp    1033c4 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  10339b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10339f:	75 16                	jne    1033b7 <strtol+0x9a>
  1033a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1033a4:	0f b6 00             	movzbl (%eax),%eax
  1033a7:	3c 30                	cmp    $0x30,%al
  1033a9:	75 0c                	jne    1033b7 <strtol+0x9a>
        s ++, base = 8;
  1033ab:	ff 45 08             	incl   0x8(%ebp)
  1033ae:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1033b5:	eb 0d                	jmp    1033c4 <strtol+0xa7>
    }
    else if (base == 0) {
  1033b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1033bb:	75 07                	jne    1033c4 <strtol+0xa7>
        base = 10;
  1033bd:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1033c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1033c7:	0f b6 00             	movzbl (%eax),%eax
  1033ca:	3c 2f                	cmp    $0x2f,%al
  1033cc:	7e 1b                	jle    1033e9 <strtol+0xcc>
  1033ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d1:	0f b6 00             	movzbl (%eax),%eax
  1033d4:	3c 39                	cmp    $0x39,%al
  1033d6:	7f 11                	jg     1033e9 <strtol+0xcc>
            dig = *s - '0';
  1033d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033db:	0f b6 00             	movzbl (%eax),%eax
  1033de:	0f be c0             	movsbl %al,%eax
  1033e1:	83 e8 30             	sub    $0x30,%eax
  1033e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033e7:	eb 48                	jmp    103431 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1033e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ec:	0f b6 00             	movzbl (%eax),%eax
  1033ef:	3c 60                	cmp    $0x60,%al
  1033f1:	7e 1b                	jle    10340e <strtol+0xf1>
  1033f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1033f6:	0f b6 00             	movzbl (%eax),%eax
  1033f9:	3c 7a                	cmp    $0x7a,%al
  1033fb:	7f 11                	jg     10340e <strtol+0xf1>
            dig = *s - 'a' + 10;
  1033fd:	8b 45 08             	mov    0x8(%ebp),%eax
  103400:	0f b6 00             	movzbl (%eax),%eax
  103403:	0f be c0             	movsbl %al,%eax
  103406:	83 e8 57             	sub    $0x57,%eax
  103409:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10340c:	eb 23                	jmp    103431 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10340e:	8b 45 08             	mov    0x8(%ebp),%eax
  103411:	0f b6 00             	movzbl (%eax),%eax
  103414:	3c 40                	cmp    $0x40,%al
  103416:	7e 3b                	jle    103453 <strtol+0x136>
  103418:	8b 45 08             	mov    0x8(%ebp),%eax
  10341b:	0f b6 00             	movzbl (%eax),%eax
  10341e:	3c 5a                	cmp    $0x5a,%al
  103420:	7f 31                	jg     103453 <strtol+0x136>
            dig = *s - 'A' + 10;
  103422:	8b 45 08             	mov    0x8(%ebp),%eax
  103425:	0f b6 00             	movzbl (%eax),%eax
  103428:	0f be c0             	movsbl %al,%eax
  10342b:	83 e8 37             	sub    $0x37,%eax
  10342e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  103431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103434:	3b 45 10             	cmp    0x10(%ebp),%eax
  103437:	7d 19                	jge    103452 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  103439:	ff 45 08             	incl   0x8(%ebp)
  10343c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10343f:	0f af 45 10          	imul   0x10(%ebp),%eax
  103443:	89 c2                	mov    %eax,%edx
  103445:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103448:	01 d0                	add    %edx,%eax
  10344a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  10344d:	e9 72 ff ff ff       	jmp    1033c4 <strtol+0xa7>
            break;
  103452:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  103453:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103457:	74 08                	je     103461 <strtol+0x144>
        *endptr = (char *) s;
  103459:	8b 45 0c             	mov    0xc(%ebp),%eax
  10345c:	8b 55 08             	mov    0x8(%ebp),%edx
  10345f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  103461:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103465:	74 07                	je     10346e <strtol+0x151>
  103467:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10346a:	f7 d8                	neg    %eax
  10346c:	eb 03                	jmp    103471 <strtol+0x154>
  10346e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  103471:	89 ec                	mov    %ebp,%esp
  103473:	5d                   	pop    %ebp
  103474:	c3                   	ret    

00103475 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103475:	55                   	push   %ebp
  103476:	89 e5                	mov    %esp,%ebp
  103478:	83 ec 28             	sub    $0x28,%esp
  10347b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10347e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103481:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103484:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  103488:	8b 45 08             	mov    0x8(%ebp),%eax
  10348b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10348e:	88 55 f7             	mov    %dl,-0x9(%ebp)
  103491:	8b 45 10             	mov    0x10(%ebp),%eax
  103494:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  103497:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10349a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10349e:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1034a1:	89 d7                	mov    %edx,%edi
  1034a3:	f3 aa                	rep stos %al,%es:(%edi)
  1034a5:	89 fa                	mov    %edi,%edx
  1034a7:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1034aa:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  1034ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1034b0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1034b3:	89 ec                	mov    %ebp,%esp
  1034b5:	5d                   	pop    %ebp
  1034b6:	c3                   	ret    

001034b7 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1034b7:	55                   	push   %ebp
  1034b8:	89 e5                	mov    %esp,%ebp
  1034ba:	57                   	push   %edi
  1034bb:	56                   	push   %esi
  1034bc:	53                   	push   %ebx
  1034bd:	83 ec 30             	sub    $0x30,%esp
  1034c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1034cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1034cf:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1034d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1034d8:	73 42                	jae    10351c <memmove+0x65>
  1034da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1034e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1034e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1034ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1034ef:	c1 e8 02             	shr    $0x2,%eax
  1034f2:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1034f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1034f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034fa:	89 d7                	mov    %edx,%edi
  1034fc:	89 c6                	mov    %eax,%esi
  1034fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103500:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  103503:	83 e1 03             	and    $0x3,%ecx
  103506:	74 02                	je     10350a <memmove+0x53>
  103508:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10350a:	89 f0                	mov    %esi,%eax
  10350c:	89 fa                	mov    %edi,%edx
  10350e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  103511:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103514:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  103517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  10351a:	eb 36                	jmp    103552 <memmove+0x9b>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  10351c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10351f:	8d 50 ff             	lea    -0x1(%eax),%edx
  103522:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103525:	01 c2                	add    %eax,%edx
  103527:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10352a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  10352d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103530:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  103533:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103536:	89 c1                	mov    %eax,%ecx
  103538:	89 d8                	mov    %ebx,%eax
  10353a:	89 d6                	mov    %edx,%esi
  10353c:	89 c7                	mov    %eax,%edi
  10353e:	fd                   	std    
  10353f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103541:	fc                   	cld    
  103542:	89 f8                	mov    %edi,%eax
  103544:	89 f2                	mov    %esi,%edx
  103546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  103549:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10354c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10354f:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  103552:	83 c4 30             	add    $0x30,%esp
  103555:	5b                   	pop    %ebx
  103556:	5e                   	pop    %esi
  103557:	5f                   	pop    %edi
  103558:	5d                   	pop    %ebp
  103559:	c3                   	ret    

0010355a <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10355a:	55                   	push   %ebp
  10355b:	89 e5                	mov    %esp,%ebp
  10355d:	57                   	push   %edi
  10355e:	56                   	push   %esi
  10355f:	83 ec 20             	sub    $0x20,%esp
  103562:	8b 45 08             	mov    0x8(%ebp),%eax
  103565:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103568:	8b 45 0c             	mov    0xc(%ebp),%eax
  10356b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10356e:	8b 45 10             	mov    0x10(%ebp),%eax
  103571:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103574:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103577:	c1 e8 02             	shr    $0x2,%eax
  10357a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  10357c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10357f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103582:	89 d7                	mov    %edx,%edi
  103584:	89 c6                	mov    %eax,%esi
  103586:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103588:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10358b:	83 e1 03             	and    $0x3,%ecx
  10358e:	74 02                	je     103592 <memcpy+0x38>
  103590:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103592:	89 f0                	mov    %esi,%eax
  103594:	89 fa                	mov    %edi,%edx
  103596:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  103599:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10359c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10359f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1035a2:	83 c4 20             	add    $0x20,%esp
  1035a5:	5e                   	pop    %esi
  1035a6:	5f                   	pop    %edi
  1035a7:	5d                   	pop    %ebp
  1035a8:	c3                   	ret    

001035a9 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1035a9:	55                   	push   %ebp
  1035aa:	89 e5                	mov    %esp,%ebp
  1035ac:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1035af:	8b 45 08             	mov    0x8(%ebp),%eax
  1035b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1035b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1035bb:	eb 2e                	jmp    1035eb <memcmp+0x42>
        if (*s1 != *s2) {
  1035bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1035c0:	0f b6 10             	movzbl (%eax),%edx
  1035c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1035c6:	0f b6 00             	movzbl (%eax),%eax
  1035c9:	38 c2                	cmp    %al,%dl
  1035cb:	74 18                	je     1035e5 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1035cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1035d0:	0f b6 00             	movzbl (%eax),%eax
  1035d3:	0f b6 d0             	movzbl %al,%edx
  1035d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1035d9:	0f b6 00             	movzbl (%eax),%eax
  1035dc:	0f b6 c8             	movzbl %al,%ecx
  1035df:	89 d0                	mov    %edx,%eax
  1035e1:	29 c8                	sub    %ecx,%eax
  1035e3:	eb 18                	jmp    1035fd <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1035e5:	ff 45 fc             	incl   -0x4(%ebp)
  1035e8:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1035eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1035ee:	8d 50 ff             	lea    -0x1(%eax),%edx
  1035f1:	89 55 10             	mov    %edx,0x10(%ebp)
  1035f4:	85 c0                	test   %eax,%eax
  1035f6:	75 c5                	jne    1035bd <memcmp+0x14>
    }
    return 0;
  1035f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1035fd:	89 ec                	mov    %ebp,%esp
  1035ff:	5d                   	pop    %ebp
  103600:	c3                   	ret    
