
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 50 1b 00       	mov    $0x1b5000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 50 1b c0       	mov    %eax,0xc01b5000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 30 13 c0       	mov    $0xc0133000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 78 a1 1b c0       	mov    $0xc01ba178,%eax
c0100041:	2d 00 70 1b c0       	sub    $0xc01b7000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 70 1b c0 	movl   $0xc01b7000,(%esp)
c0100059:	e8 93 c7 00 00       	call   c010c7f1 <memset>

    cons_init();                // init the console
c010005e:	e8 ff 16 00 00       	call   c0101762 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 80 c9 10 c0 	movl   $0xc010c980,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 9c c9 10 c0 	movl   $0xc010c99c,(%esp)
c0100078:	e8 f5 02 00 00       	call   c0100372 <cprintf>

    print_kerninfo();
c010007d:	e8 09 09 00 00       	call   c010098b <print_kerninfo>

    grade_backtrace();
c0100082:	e8 ac 00 00 00       	call   c0100133 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 b6 57 00 00       	call   c0105842 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 af 20 00 00       	call   c0102140 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 13 22 00 00       	call   c01022a9 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 0b 89 00 00       	call   c01089a6 <vmm_init>
    sched_init();               // init scheduler
c010009b:	e8 dd b8 00 00       	call   c010b97d <sched_init>
    proc_init();                // init process table
c01000a0:	e8 26 b0 00 00       	call   c010b0cb <proc_init>
    
    ide_init();                 // init ide devices
c01000a5:	e8 f2 17 00 00       	call   c010189c <ide_init>
    swap_init();                // init swap
c01000aa:	e8 ea 6e 00 00       	call   c0106f99 <swap_init>

    clock_init();               // init clock interrupt
c01000af:	e8 0d 0e 00 00       	call   c0100ec1 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b4:	e8 e5 1f 00 00       	call   c010209e <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b9:	e8 ce b1 00 00       	call   c010b28c <cpu_idle>

c01000be <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000be:	55                   	push   %ebp
c01000bf:	89 e5                	mov    %esp,%ebp
c01000c1:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000cb:	00 
c01000cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d3:	00 
c01000d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000db:	e8 fc 0c 00 00       	call   c0100ddc <mon_backtrace>
}
c01000e0:	90                   	nop
c01000e1:	89 ec                	mov    %ebp,%esp
c01000e3:	5d                   	pop    %ebp
c01000e4:	c3                   	ret    

c01000e5 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e5:	55                   	push   %ebp
c01000e6:	89 e5                	mov    %esp,%ebp
c01000e8:	83 ec 18             	sub    $0x18,%esp
c01000eb:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000ee:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000f4:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000fe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100102:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100106:	89 04 24             	mov    %eax,(%esp)
c0100109:	e8 b0 ff ff ff       	call   c01000be <grade_backtrace2>
}
c010010e:	90                   	nop
c010010f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100112:	89 ec                	mov    %ebp,%esp
c0100114:	5d                   	pop    %ebp
c0100115:	c3                   	ret    

c0100116 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100116:	55                   	push   %ebp
c0100117:	89 e5                	mov    %esp,%ebp
c0100119:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010011c:	8b 45 10             	mov    0x10(%ebp),%eax
c010011f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100123:	8b 45 08             	mov    0x8(%ebp),%eax
c0100126:	89 04 24             	mov    %eax,(%esp)
c0100129:	e8 b7 ff ff ff       	call   c01000e5 <grade_backtrace1>
}
c010012e:	90                   	nop
c010012f:	89 ec                	mov    %ebp,%esp
c0100131:	5d                   	pop    %ebp
c0100132:	c3                   	ret    

c0100133 <grade_backtrace>:

void
grade_backtrace(void) {
c0100133:	55                   	push   %ebp
c0100134:	89 e5                	mov    %esp,%ebp
c0100136:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100139:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010013e:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100145:	ff 
c0100146:	89 44 24 04          	mov    %eax,0x4(%esp)
c010014a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100151:	e8 c0 ff ff ff       	call   c0100116 <grade_backtrace0>
}
c0100156:	90                   	nop
c0100157:	89 ec                	mov    %ebp,%esp
c0100159:	5d                   	pop    %ebp
c010015a:	c3                   	ret    

c010015b <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010015b:	55                   	push   %ebp
c010015c:	89 e5                	mov    %esp,%ebp
c010015e:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100161:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100164:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100167:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010016a:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	83 e0 03             	and    $0x3,%eax
c0100174:	89 c2                	mov    %eax,%edx
c0100176:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c010017b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100183:	c7 04 24 a1 c9 10 c0 	movl   $0xc010c9a1,(%esp)
c010018a:	e8 e3 01 00 00       	call   c0100372 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010018f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100193:	89 c2                	mov    %eax,%edx
c0100195:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c010019a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a2:	c7 04 24 af c9 10 c0 	movl   $0xc010c9af,(%esp)
c01001a9:	e8 c4 01 00 00       	call   c0100372 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001ae:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001b2:	89 c2                	mov    %eax,%edx
c01001b4:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 bd c9 10 c0 	movl   $0xc010c9bd,(%esp)
c01001c8:	e8 a5 01 00 00       	call   c0100372 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001cd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001d1:	89 c2                	mov    %eax,%edx
c01001d3:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c01001d8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e0:	c7 04 24 cb c9 10 c0 	movl   $0xc010c9cb,(%esp)
c01001e7:	e8 86 01 00 00       	call   c0100372 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001ec:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001f0:	89 c2                	mov    %eax,%edx
c01001f2:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c01001f7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ff:	c7 04 24 d9 c9 10 c0 	movl   $0xc010c9d9,(%esp)
c0100206:	e8 67 01 00 00       	call   c0100372 <cprintf>
    round ++;
c010020b:	a1 00 70 1b c0       	mov    0xc01b7000,%eax
c0100210:	40                   	inc    %eax
c0100211:	a3 00 70 1b c0       	mov    %eax,0xc01b7000
}
c0100216:	90                   	nop
c0100217:	89 ec                	mov    %ebp,%esp
c0100219:	5d                   	pop    %ebp
c010021a:	c3                   	ret    

c010021b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010021b:	55                   	push   %ebp
c010021c:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010021e:	90                   	nop
c010021f:	5d                   	pop    %ebp
c0100220:	c3                   	ret    

c0100221 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100221:	55                   	push   %ebp
c0100222:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100224:	90                   	nop
c0100225:	5d                   	pop    %ebp
c0100226:	c3                   	ret    

c0100227 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100227:	55                   	push   %ebp
c0100228:	89 e5                	mov    %esp,%ebp
c010022a:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010022d:	e8 29 ff ff ff       	call   c010015b <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100232:	c7 04 24 e8 c9 10 c0 	movl   $0xc010c9e8,(%esp)
c0100239:	e8 34 01 00 00       	call   c0100372 <cprintf>
    lab1_switch_to_user();
c010023e:	e8 d8 ff ff ff       	call   c010021b <lab1_switch_to_user>
    lab1_print_cur_status();
c0100243:	e8 13 ff ff ff       	call   c010015b <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100248:	c7 04 24 08 ca 10 c0 	movl   $0xc010ca08,(%esp)
c010024f:	e8 1e 01 00 00       	call   c0100372 <cprintf>
    lab1_switch_to_kernel();
c0100254:	e8 c8 ff ff ff       	call   c0100221 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100259:	e8 fd fe ff ff       	call   c010015b <lab1_print_cur_status>
}
c010025e:	90                   	nop
c010025f:	89 ec                	mov    %ebp,%esp
c0100261:	5d                   	pop    %ebp
c0100262:	c3                   	ret    

c0100263 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100263:	55                   	push   %ebp
c0100264:	89 e5                	mov    %esp,%ebp
c0100266:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100269:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010026d:	74 13                	je     c0100282 <readline+0x1f>
        cprintf("%s", prompt);
c010026f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100272:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100276:	c7 04 24 27 ca 10 c0 	movl   $0xc010ca27,(%esp)
c010027d:	e8 f0 00 00 00       	call   c0100372 <cprintf>
    }
    int i = 0, c;
c0100282:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100289:	e8 73 01 00 00       	call   c0100401 <getchar>
c010028e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100291:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100295:	79 07                	jns    c010029e <readline+0x3b>
            return NULL;
c0100297:	b8 00 00 00 00       	mov    $0x0,%eax
c010029c:	eb 78                	jmp    c0100316 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010029e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01002a2:	7e 28                	jle    c01002cc <readline+0x69>
c01002a4:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002ab:	7f 1f                	jg     c01002cc <readline+0x69>
            cputchar(c);
c01002ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b0:	89 04 24             	mov    %eax,(%esp)
c01002b3:	e8 e2 00 00 00       	call   c010039a <cputchar>
            buf[i ++] = c;
c01002b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002bb:	8d 50 01             	lea    0x1(%eax),%edx
c01002be:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002c4:	88 90 20 70 1b c0    	mov    %dl,-0x3fe48fe0(%eax)
c01002ca:	eb 45                	jmp    c0100311 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002cc:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002d0:	75 16                	jne    c01002e8 <readline+0x85>
c01002d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002d6:	7e 10                	jle    c01002e8 <readline+0x85>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 b7 00 00 00       	call   c010039a <cputchar>
            i --;
c01002e3:	ff 4d f4             	decl   -0xc(%ebp)
c01002e6:	eb 29                	jmp    c0100311 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002e8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002ec:	74 06                	je     c01002f4 <readline+0x91>
c01002ee:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002f2:	75 95                	jne    c0100289 <readline+0x26>
            cputchar(c);
c01002f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002f7:	89 04 24             	mov    %eax,(%esp)
c01002fa:	e8 9b 00 00 00       	call   c010039a <cputchar>
            buf[i] = '\0';
c01002ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100302:	05 20 70 1b c0       	add    $0xc01b7020,%eax
c0100307:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010030a:	b8 20 70 1b c0       	mov    $0xc01b7020,%eax
c010030f:	eb 05                	jmp    c0100316 <readline+0xb3>
        c = getchar();
c0100311:	e9 73 ff ff ff       	jmp    c0100289 <readline+0x26>
        }
    }
}
c0100316:	89 ec                	mov    %ebp,%esp
c0100318:	5d                   	pop    %ebp
c0100319:	c3                   	ret    

c010031a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010031a:	55                   	push   %ebp
c010031b:	89 e5                	mov    %esp,%ebp
c010031d:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100320:	8b 45 08             	mov    0x8(%ebp),%eax
c0100323:	89 04 24             	mov    %eax,(%esp)
c0100326:	e8 66 14 00 00       	call   c0101791 <cons_putc>
    (*cnt) ++;
c010032b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010032e:	8b 00                	mov    (%eax),%eax
c0100330:	8d 50 01             	lea    0x1(%eax),%edx
c0100333:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100336:	89 10                	mov    %edx,(%eax)
}
c0100338:	90                   	nop
c0100339:	89 ec                	mov    %ebp,%esp
c010033b:	5d                   	pop    %ebp
c010033c:	c3                   	ret    

c010033d <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010033d:	55                   	push   %ebp
c010033e:	89 e5                	mov    %esp,%ebp
c0100340:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100343:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010034a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010034d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100351:	8b 45 08             	mov    0x8(%ebp),%eax
c0100354:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100358:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010035b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035f:	c7 04 24 1a 03 10 c0 	movl   $0xc010031a,(%esp)
c0100366:	e8 d9 bb 00 00       	call   c010bf44 <vprintfmt>
    return cnt;
c010036b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036e:	89 ec                	mov    %ebp,%esp
c0100370:	5d                   	pop    %ebp
c0100371:	c3                   	ret    

c0100372 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100372:	55                   	push   %ebp
c0100373:	89 e5                	mov    %esp,%ebp
c0100375:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100378:	8d 45 0c             	lea    0xc(%ebp),%eax
c010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100381:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100385:	8b 45 08             	mov    0x8(%ebp),%eax
c0100388:	89 04 24             	mov    %eax,(%esp)
c010038b:	e8 ad ff ff ff       	call   c010033d <vcprintf>
c0100390:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100393:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100396:	89 ec                	mov    %ebp,%esp
c0100398:	5d                   	pop    %ebp
c0100399:	c3                   	ret    

c010039a <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010039a:	55                   	push   %ebp
c010039b:	89 e5                	mov    %esp,%ebp
c010039d:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01003a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a3:	89 04 24             	mov    %eax,(%esp)
c01003a6:	e8 e6 13 00 00       	call   c0101791 <cons_putc>
}
c01003ab:	90                   	nop
c01003ac:	89 ec                	mov    %ebp,%esp
c01003ae:	5d                   	pop    %ebp
c01003af:	c3                   	ret    

c01003b0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003b0:	55                   	push   %ebp
c01003b1:	89 e5                	mov    %esp,%ebp
c01003b3:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003b6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003bd:	eb 13                	jmp    c01003d2 <cputs+0x22>
        cputch(c, &cnt);
c01003bf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003c3:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ca:	89 04 24             	mov    %eax,(%esp)
c01003cd:	e8 48 ff ff ff       	call   c010031a <cputch>
    while ((c = *str ++) != '\0') {
c01003d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01003d5:	8d 50 01             	lea    0x1(%eax),%edx
c01003d8:	89 55 08             	mov    %edx,0x8(%ebp)
c01003db:	0f b6 00             	movzbl (%eax),%eax
c01003de:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003e1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003e5:	75 d8                	jne    c01003bf <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ee:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003f5:	e8 20 ff ff ff       	call   c010031a <cputch>
    return cnt;
c01003fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100407:	90                   	nop
c0100408:	e8 c3 13 00 00       	call   c01017d0 <cons_getc>
c010040d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100410:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100414:	74 f2                	je     c0100408 <getchar+0x7>
        /* do nothing */;
    return c;
c0100416:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100419:	89 ec                	mov    %ebp,%esp
c010041b:	5d                   	pop    %ebp
c010041c:	c3                   	ret    

c010041d <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c010041d:	55                   	push   %ebp
c010041e:	89 e5                	mov    %esp,%ebp
c0100420:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100423:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100426:	8b 00                	mov    (%eax),%eax
c0100428:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010042b:	8b 45 10             	mov    0x10(%ebp),%eax
c010042e:	8b 00                	mov    (%eax),%eax
c0100430:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100433:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010043a:	e9 ca 00 00 00       	jmp    c0100509 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c010043f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100442:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100445:	01 d0                	add    %edx,%eax
c0100447:	89 c2                	mov    %eax,%edx
c0100449:	c1 ea 1f             	shr    $0x1f,%edx
c010044c:	01 d0                	add    %edx,%eax
c010044e:	d1 f8                	sar    %eax
c0100450:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100453:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100456:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100459:	eb 03                	jmp    c010045e <stab_binsearch+0x41>
            m --;
c010045b:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c010045e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100461:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100464:	7c 1f                	jl     c0100485 <stab_binsearch+0x68>
c0100466:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100469:	89 d0                	mov    %edx,%eax
c010046b:	01 c0                	add    %eax,%eax
c010046d:	01 d0                	add    %edx,%eax
c010046f:	c1 e0 02             	shl    $0x2,%eax
c0100472:	89 c2                	mov    %eax,%edx
c0100474:	8b 45 08             	mov    0x8(%ebp),%eax
c0100477:	01 d0                	add    %edx,%eax
c0100479:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010047d:	0f b6 c0             	movzbl %al,%eax
c0100480:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100483:	75 d6                	jne    c010045b <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100485:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100488:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010048b:	7d 09                	jge    c0100496 <stab_binsearch+0x79>
            l = true_m + 1;
c010048d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100490:	40                   	inc    %eax
c0100491:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100494:	eb 73                	jmp    c0100509 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100496:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010049d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a0:	89 d0                	mov    %edx,%eax
c01004a2:	01 c0                	add    %eax,%eax
c01004a4:	01 d0                	add    %edx,%eax
c01004a6:	c1 e0 02             	shl    $0x2,%eax
c01004a9:	89 c2                	mov    %eax,%edx
c01004ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ae:	01 d0                	add    %edx,%eax
c01004b0:	8b 40 08             	mov    0x8(%eax),%eax
c01004b3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004b6:	76 11                	jbe    c01004c9 <stab_binsearch+0xac>
            *region_left = m;
c01004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004be:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004c3:	40                   	inc    %eax
c01004c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c7:	eb 40                	jmp    c0100509 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004cc:	89 d0                	mov    %edx,%eax
c01004ce:	01 c0                	add    %eax,%eax
c01004d0:	01 d0                	add    %edx,%eax
c01004d2:	c1 e0 02             	shl    $0x2,%eax
c01004d5:	89 c2                	mov    %eax,%edx
c01004d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004da:	01 d0                	add    %edx,%eax
c01004dc:	8b 40 08             	mov    0x8(%eax),%eax
c01004df:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004e2:	73 14                	jae    c01004f8 <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ed:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f2:	48                   	dec    %eax
c01004f3:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004f6:	eb 11                	jmp    c0100509 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004fe:	89 10                	mov    %edx,(%eax)
            l = m;
c0100500:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100506:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100509:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010050c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010050f:	0f 8e 2a ff ff ff    	jle    c010043f <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100515:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100519:	75 0f                	jne    c010052a <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100523:	8b 45 10             	mov    0x10(%ebp),%eax
c0100526:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100528:	eb 3e                	jmp    c0100568 <stab_binsearch+0x14b>
        l = *region_right;
c010052a:	8b 45 10             	mov    0x10(%ebp),%eax
c010052d:	8b 00                	mov    (%eax),%eax
c010052f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100532:	eb 03                	jmp    c0100537 <stab_binsearch+0x11a>
c0100534:	ff 4d fc             	decl   -0x4(%ebp)
c0100537:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053a:	8b 00                	mov    (%eax),%eax
c010053c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010053f:	7e 1f                	jle    c0100560 <stab_binsearch+0x143>
c0100541:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100544:	89 d0                	mov    %edx,%eax
c0100546:	01 c0                	add    %eax,%eax
c0100548:	01 d0                	add    %edx,%eax
c010054a:	c1 e0 02             	shl    $0x2,%eax
c010054d:	89 c2                	mov    %eax,%edx
c010054f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100552:	01 d0                	add    %edx,%eax
c0100554:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100558:	0f b6 c0             	movzbl %al,%eax
c010055b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010055e:	75 d4                	jne    c0100534 <stab_binsearch+0x117>
        *region_left = l;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100566:	89 10                	mov    %edx,(%eax)
}
c0100568:	90                   	nop
c0100569:	89 ec                	mov    %ebp,%esp
c010056b:	5d                   	pop    %ebp
c010056c:	c3                   	ret    

c010056d <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010056d:	55                   	push   %ebp
c010056e:	89 e5                	mov    %esp,%ebp
c0100570:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100573:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100576:	c7 00 2c ca 10 c0    	movl   $0xc010ca2c,(%eax)
    info->eip_line = 0;
c010057c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100586:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100589:	c7 40 08 2c ca 10 c0 	movl   $0xc010ca2c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100590:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100593:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010059a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010059d:	8b 55 08             	mov    0x8(%ebp),%edx
c01005a0:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c01005ad:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c01005b4:	76 21                	jbe    c01005d7 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c01005b6:	c7 45 f4 60 f3 10 c0 	movl   $0xc010f360,-0xc(%ebp)
        stab_end = __STAB_END__;
c01005bd:	c7 45 f0 9c 6d 12 c0 	movl   $0xc0126d9c,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005c4:	c7 45 ec 9d 6d 12 c0 	movl   $0xc0126d9d,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005cb:	c7 45 e8 64 06 13 c0 	movl   $0xc0130664,-0x18(%ebp)
c01005d2:	e9 e8 00 00 00       	jmp    c01006bf <debuginfo_eip+0x152>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005d7:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005de:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c01005e3:	85 c0                	test   %eax,%eax
c01005e5:	74 11                	je     c01005f8 <debuginfo_eip+0x8b>
c01005e7:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c01005ec:	8b 40 18             	mov    0x18(%eax),%eax
c01005ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005f6:	75 0a                	jne    c0100602 <debuginfo_eip+0x95>
            return -1;
c01005f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005fd:	e9 85 03 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010060c:	00 
c010060d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0100614:	00 
c0100615:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 04 24             	mov    %eax,(%esp)
c010061f:	e8 56 8d 00 00       	call   c010937a <user_mem_check>
c0100624:	85 c0                	test   %eax,%eax
c0100626:	75 0a                	jne    c0100632 <debuginfo_eip+0xc5>
            return -1;
c0100628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010062d:	e9 55 03 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
        }

        stabs = usd->stabs;
c0100632:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100635:	8b 00                	mov    (%eax),%eax
c0100637:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c010063a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010063d:	8b 40 04             	mov    0x4(%eax),%eax
c0100640:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100643:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100646:	8b 40 08             	mov    0x8(%eax),%eax
c0100649:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c010064c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010064f:	8b 40 0c             	mov    0xc(%eax),%eax
c0100652:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100655:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100658:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c010065b:	29 c8                	sub    %ecx,%eax
c010065d:	89 c2                	mov    %eax,%edx
c010065f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100662:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100669:	00 
c010066a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010066e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100672:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100675:	89 04 24             	mov    %eax,(%esp)
c0100678:	e8 fd 8c 00 00       	call   c010937a <user_mem_check>
c010067d:	85 c0                	test   %eax,%eax
c010067f:	75 0a                	jne    c010068b <debuginfo_eip+0x11e>
            return -1;
c0100681:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100686:	e9 fc 02 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c010068b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010068e:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100691:	89 c2                	mov    %eax,%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010069d:	00 
c010069e:	89 54 24 08          	mov    %edx,0x8(%esp)
c01006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006a9:	89 04 24             	mov    %eax,(%esp)
c01006ac:	e8 c9 8c 00 00       	call   c010937a <user_mem_check>
c01006b1:	85 c0                	test   %eax,%eax
c01006b3:	75 0a                	jne    c01006bf <debuginfo_eip+0x152>
            return -1;
c01006b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006ba:	e9 c8 02 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c5:	76 0b                	jbe    c01006d2 <debuginfo_eip+0x165>
c01006c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ca:	48                   	dec    %eax
c01006cb:	0f b6 00             	movzbl (%eax),%eax
c01006ce:	84 c0                	test   %al,%al
c01006d0:	74 0a                	je     c01006dc <debuginfo_eip+0x16f>
        return -1;
c01006d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d7:	e9 ab 02 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006dc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006e6:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006e9:	c1 f8 02             	sar    $0x2,%eax
c01006ec:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006f2:	48                   	dec    %eax
c01006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006fd:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100704:	00 
c0100705:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100708:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100716:	89 04 24             	mov    %eax,(%esp)
c0100719:	e8 ff fc ff ff       	call   c010041d <stab_binsearch>
    if (lfile == 0)
c010071e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100721:	85 c0                	test   %eax,%eax
c0100723:	75 0a                	jne    c010072f <debuginfo_eip+0x1c2>
        return -1;
c0100725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010072a:	e9 58 02 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010072f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100732:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100735:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100738:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010073b:	8b 45 08             	mov    0x8(%ebp),%eax
c010073e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100742:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100749:	00 
c010074a:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010074d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100751:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100754:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075b:	89 04 24             	mov    %eax,(%esp)
c010075e:	e8 ba fc ff ff       	call   c010041d <stab_binsearch>

    if (lfun <= rfun) {
c0100763:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100766:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100769:	39 c2                	cmp    %eax,%edx
c010076b:	7f 78                	jg     c01007e5 <debuginfo_eip+0x278>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	89 c2                	mov    %eax,%edx
c0100772:	89 d0                	mov    %edx,%eax
c0100774:	01 c0                	add    %eax,%eax
c0100776:	01 d0                	add    %edx,%eax
c0100778:	c1 e0 02             	shl    $0x2,%eax
c010077b:	89 c2                	mov    %eax,%edx
c010077d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100780:	01 d0                	add    %edx,%eax
c0100782:	8b 10                	mov    (%eax),%edx
c0100784:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100787:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010078a:	39 c2                	cmp    %eax,%edx
c010078c:	73 22                	jae    c01007b0 <debuginfo_eip+0x243>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010078e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100791:	89 c2                	mov    %eax,%edx
c0100793:	89 d0                	mov    %edx,%eax
c0100795:	01 c0                	add    %eax,%eax
c0100797:	01 d0                	add    %edx,%eax
c0100799:	c1 e0 02             	shl    $0x2,%eax
c010079c:	89 c2                	mov    %eax,%edx
c010079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	8b 10                	mov    (%eax),%edx
c01007a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007a8:	01 c2                	add    %eax,%edx
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b3:	89 c2                	mov    %eax,%edx
c01007b5:	89 d0                	mov    %edx,%eax
c01007b7:	01 c0                	add    %eax,%eax
c01007b9:	01 d0                	add    %edx,%eax
c01007bb:	c1 e0 02             	shl    $0x2,%eax
c01007be:	89 c2                	mov    %eax,%edx
c01007c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c3:	01 d0                	add    %edx,%eax
c01007c5:	8b 50 08             	mov    0x8(%eax),%edx
c01007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cb:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d1:	8b 40 10             	mov    0x10(%eax),%eax
c01007d4:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007da:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007e3:	eb 15                	jmp    c01007fa <debuginfo_eip+0x28d>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e8:	8b 55 08             	mov    0x8(%ebp),%edx
c01007eb:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100800:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100807:	00 
c0100808:	89 04 24             	mov    %eax,(%esp)
c010080b:	e8 59 be 00 00       	call   c010c669 <strfind>
c0100810:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100813:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100816:	29 c8                	sub    %ecx,%eax
c0100818:	89 c2                	mov    %eax,%edx
c010081a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100820:	8b 45 08             	mov    0x8(%ebp),%eax
c0100823:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100827:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010082e:	00 
c010082f:	8d 45 c8             	lea    -0x38(%ebp),%eax
c0100832:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100836:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100839:	89 44 24 04          	mov    %eax,0x4(%esp)
c010083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100840:	89 04 24             	mov    %eax,(%esp)
c0100843:	e8 d5 fb ff ff       	call   c010041d <stab_binsearch>
    if (lline <= rline) {
c0100848:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010084b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010084e:	39 c2                	cmp    %eax,%edx
c0100850:	7f 23                	jg     c0100875 <debuginfo_eip+0x308>
        info->eip_line = stabs[rline].n_desc;
c0100852:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100855:	89 c2                	mov    %eax,%edx
c0100857:	89 d0                	mov    %edx,%eax
c0100859:	01 c0                	add    %eax,%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	c1 e0 02             	shl    $0x2,%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100865:	01 d0                	add    %edx,%eax
c0100867:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100870:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100873:	eb 11                	jmp    c0100886 <debuginfo_eip+0x319>
        return -1;
c0100875:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010087a:	e9 08 01 00 00       	jmp    c0100987 <debuginfo_eip+0x41a>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010087f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100882:	48                   	dec    %eax
c0100883:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c0100886:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100889:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010088c:	39 c2                	cmp    %eax,%edx
c010088e:	7c 56                	jl     c01008e6 <debuginfo_eip+0x379>
           && stabs[lline].n_type != N_SOL
c0100890:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100893:	89 c2                	mov    %eax,%edx
c0100895:	89 d0                	mov    %edx,%eax
c0100897:	01 c0                	add    %eax,%eax
c0100899:	01 d0                	add    %edx,%eax
c010089b:	c1 e0 02             	shl    $0x2,%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a3:	01 d0                	add    %edx,%eax
c01008a5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008a9:	3c 84                	cmp    $0x84,%al
c01008ab:	74 39                	je     c01008e6 <debuginfo_eip+0x379>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008b0:	89 c2                	mov    %eax,%edx
c01008b2:	89 d0                	mov    %edx,%eax
c01008b4:	01 c0                	add    %eax,%eax
c01008b6:	01 d0                	add    %edx,%eax
c01008b8:	c1 e0 02             	shl    $0x2,%eax
c01008bb:	89 c2                	mov    %eax,%edx
c01008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c0:	01 d0                	add    %edx,%eax
c01008c2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c6:	3c 64                	cmp    $0x64,%al
c01008c8:	75 b5                	jne    c010087f <debuginfo_eip+0x312>
c01008ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008cd:	89 c2                	mov    %eax,%edx
c01008cf:	89 d0                	mov    %edx,%eax
c01008d1:	01 c0                	add    %eax,%eax
c01008d3:	01 d0                	add    %edx,%eax
c01008d5:	c1 e0 02             	shl    $0x2,%eax
c01008d8:	89 c2                	mov    %eax,%edx
c01008da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008dd:	01 d0                	add    %edx,%eax
c01008df:	8b 40 08             	mov    0x8(%eax),%eax
c01008e2:	85 c0                	test   %eax,%eax
c01008e4:	74 99                	je     c010087f <debuginfo_eip+0x312>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008ec:	39 c2                	cmp    %eax,%edx
c01008ee:	7c 42                	jl     c0100932 <debuginfo_eip+0x3c5>
c01008f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008f3:	89 c2                	mov    %eax,%edx
c01008f5:	89 d0                	mov    %edx,%eax
c01008f7:	01 c0                	add    %eax,%eax
c01008f9:	01 d0                	add    %edx,%eax
c01008fb:	c1 e0 02             	shl    $0x2,%eax
c01008fe:	89 c2                	mov    %eax,%edx
c0100900:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100903:	01 d0                	add    %edx,%eax
c0100905:	8b 10                	mov    (%eax),%edx
c0100907:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010090a:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010090d:	39 c2                	cmp    %eax,%edx
c010090f:	73 21                	jae    c0100932 <debuginfo_eip+0x3c5>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100911:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100914:	89 c2                	mov    %eax,%edx
c0100916:	89 d0                	mov    %edx,%eax
c0100918:	01 c0                	add    %eax,%eax
c010091a:	01 d0                	add    %edx,%eax
c010091c:	c1 e0 02             	shl    $0x2,%eax
c010091f:	89 c2                	mov    %eax,%edx
c0100921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100924:	01 d0                	add    %edx,%eax
c0100926:	8b 10                	mov    (%eax),%edx
c0100928:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092b:	01 c2                	add    %eax,%edx
c010092d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100930:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100932:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100935:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100938:	39 c2                	cmp    %eax,%edx
c010093a:	7d 46                	jge    c0100982 <debuginfo_eip+0x415>
        for (lline = lfun + 1;
c010093c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010093f:	40                   	inc    %eax
c0100940:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100943:	eb 16                	jmp    c010095b <debuginfo_eip+0x3ee>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100945:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100948:	8b 40 14             	mov    0x14(%eax),%eax
c010094b:	8d 50 01             	lea    0x1(%eax),%edx
c010094e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100951:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100954:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100957:	40                   	inc    %eax
c0100958:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010095e:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c0100961:	39 c2                	cmp    %eax,%edx
c0100963:	7d 1d                	jge    c0100982 <debuginfo_eip+0x415>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100965:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100968:	89 c2                	mov    %eax,%edx
c010096a:	89 d0                	mov    %edx,%eax
c010096c:	01 c0                	add    %eax,%eax
c010096e:	01 d0                	add    %edx,%eax
c0100970:	c1 e0 02             	shl    $0x2,%eax
c0100973:	89 c2                	mov    %eax,%edx
c0100975:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100978:	01 d0                	add    %edx,%eax
c010097a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010097e:	3c a0                	cmp    $0xa0,%al
c0100980:	74 c3                	je     c0100945 <debuginfo_eip+0x3d8>
        }
    }
    return 0;
c0100982:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100987:	89 ec                	mov    %ebp,%esp
c0100989:	5d                   	pop    %ebp
c010098a:	c3                   	ret    

c010098b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010098b:	55                   	push   %ebp
c010098c:	89 e5                	mov    %esp,%ebp
c010098e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100991:	c7 04 24 36 ca 10 c0 	movl   $0xc010ca36,(%esp)
c0100998:	e8 d5 f9 ff ff       	call   c0100372 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010099d:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a4:	c0 
c01009a5:	c7 04 24 4f ca 10 c0 	movl   $0xc010ca4f,(%esp)
c01009ac:	e8 c1 f9 ff ff       	call   c0100372 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b1:	c7 44 24 04 7d c9 10 	movl   $0xc010c97d,0x4(%esp)
c01009b8:	c0 
c01009b9:	c7 04 24 67 ca 10 c0 	movl   $0xc010ca67,(%esp)
c01009c0:	e8 ad f9 ff ff       	call   c0100372 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009c5:	c7 44 24 04 00 70 1b 	movl   $0xc01b7000,0x4(%esp)
c01009cc:	c0 
c01009cd:	c7 04 24 7f ca 10 c0 	movl   $0xc010ca7f,(%esp)
c01009d4:	e8 99 f9 ff ff       	call   c0100372 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009d9:	c7 44 24 04 78 a1 1b 	movl   $0xc01ba178,0x4(%esp)
c01009e0:	c0 
c01009e1:	c7 04 24 97 ca 10 c0 	movl   $0xc010ca97,(%esp)
c01009e8:	e8 85 f9 ff ff       	call   c0100372 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009ed:	b8 78 a1 1b c0       	mov    $0xc01ba178,%eax
c01009f2:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009f7:	05 ff 03 00 00       	add    $0x3ff,%eax
c01009fc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a02:	85 c0                	test   %eax,%eax
c0100a04:	0f 48 c2             	cmovs  %edx,%eax
c0100a07:	c1 f8 0a             	sar    $0xa,%eax
c0100a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0e:	c7 04 24 b0 ca 10 c0 	movl   $0xc010cab0,(%esp)
c0100a15:	e8 58 f9 ff ff       	call   c0100372 <cprintf>
}
c0100a1a:	90                   	nop
c0100a1b:	89 ec                	mov    %ebp,%esp
c0100a1d:	5d                   	pop    %ebp
c0100a1e:	c3                   	ret    

c0100a1f <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a1f:	55                   	push   %ebp
c0100a20:	89 e5                	mov    %esp,%ebp
c0100a22:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a28:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a32:	89 04 24             	mov    %eax,(%esp)
c0100a35:	e8 33 fb ff ff       	call   c010056d <debuginfo_eip>
c0100a3a:	85 c0                	test   %eax,%eax
c0100a3c:	74 15                	je     c0100a53 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a45:	c7 04 24 da ca 10 c0 	movl   $0xc010cada,(%esp)
c0100a4c:	e8 21 f9 ff ff       	call   c0100372 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a51:	eb 6c                	jmp    c0100abf <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a5a:	eb 1b                	jmp    c0100a77 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a62:	01 d0                	add    %edx,%eax
c0100a64:	0f b6 10             	movzbl (%eax),%edx
c0100a67:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a70:	01 c8                	add    %ecx,%eax
c0100a72:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a74:	ff 45 f4             	incl   -0xc(%ebp)
c0100a77:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a7a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a7d:	7c dd                	jl     c0100a5c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a7f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a88:	01 d0                	add    %edx,%eax
c0100a8a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a93:	29 d0                	sub    %edx,%eax
c0100a95:	89 c1                	mov    %eax,%ecx
c0100a97:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a9d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aa7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aab:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab3:	c7 04 24 f6 ca 10 c0 	movl   $0xc010caf6,(%esp)
c0100aba:	e8 b3 f8 ff ff       	call   c0100372 <cprintf>
}
c0100abf:	90                   	nop
c0100ac0:	89 ec                	mov    %ebp,%esp
c0100ac2:	5d                   	pop    %ebp
c0100ac3:	c3                   	ret    

c0100ac4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac4:	55                   	push   %ebp
c0100ac5:	89 e5                	mov    %esp,%ebp
c0100ac7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100aca:	8b 45 04             	mov    0x4(%ebp),%eax
c0100acd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ad3:	89 ec                	mov    %ebp,%esp
c0100ad5:	5d                   	pop    %ebp
c0100ad6:	c3                   	ret    

c0100ad7 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ad7:	55                   	push   %ebp
c0100ad8:	89 e5                	mov    %esp,%ebp
c0100ada:	83 ec 38             	sub    $0x38,%esp
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    // 读取当前栈帧的ebp和eip
    uint32_t eip, ebp;
    eip = read_eip();
c0100add:	e8 e2 ff ff ff       	call   c0100ac4 <read_eip>
c0100ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae5:	89 e8                	mov    %ebp,%eax
c0100ae7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100aea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    ebp = read_ebp();
c0100aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100af0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100af7:	eb 7e                	jmp    c0100b77 <print_stackframe+0xa0>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b07:	c7 04 24 08 cb 10 c0 	movl   $0xc010cb08,(%esp)
c0100b0e:	e8 5f f8 ff ff       	call   c0100372 <cprintf>
        for (j = 0; j < 4; j++) {
c0100b13:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b1a:	eb 27                	jmp    c0100b43 <print_stackframe+0x6c>
            cprintf("0x%08x ", ((uint32_t *)ebp + 2)[j]);
c0100b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b1f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b29:	01 d0                	add    %edx,%eax
c0100b2b:	83 c0 08             	add    $0x8,%eax
c0100b2e:	8b 00                	mov    (%eax),%eax
c0100b30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b34:	c7 04 24 24 cb 10 c0 	movl   $0xc010cb24,(%esp)
c0100b3b:	e8 32 f8 ff ff       	call   c0100372 <cprintf>
        for (j = 0; j < 4; j++) {
c0100b40:	ff 45 e8             	incl   -0x18(%ebp)
c0100b43:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b47:	7e d3                	jle    c0100b1c <print_stackframe+0x45>
        }
        cprintf("\n");
c0100b49:	c7 04 24 2c cb 10 c0 	movl   $0xc010cb2c,(%esp)
c0100b50:	e8 1d f8 ff ff       	call   c0100372 <cprintf>
        print_debuginfo(eip - 1);
c0100b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b58:	48                   	dec    %eax
c0100b59:	89 04 24             	mov    %eax,(%esp)
c0100b5c:	e8 be fe ff ff       	call   c0100a1f <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b64:	83 c0 04             	add    $0x4,%eax
c0100b67:	8b 00                	mov    (%eax),%eax
c0100b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b6f:	8b 00                	mov    (%eax),%eax
c0100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100b74:	ff 45 ec             	incl   -0x14(%ebp)
c0100b77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b7b:	74 0a                	je     c0100b87 <print_stackframe+0xb0>
c0100b7d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b81:	0f 8e 72 ff ff ff    	jle    c0100af9 <print_stackframe+0x22>
    }
    cprintf("What the fuck?");
c0100b87:	c7 04 24 2e cb 10 c0 	movl   $0xc010cb2e,(%esp)
c0100b8e:	e8 df f7 ff ff       	call   c0100372 <cprintf>
}
c0100b93:	90                   	nop
c0100b94:	89 ec                	mov    %ebp,%esp
c0100b96:	5d                   	pop    %ebp
c0100b97:	c3                   	ret    

c0100b98 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b98:	55                   	push   %ebp
c0100b99:	89 e5                	mov    %esp,%ebp
c0100b9b:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ba5:	eb 0c                	jmp    c0100bb3 <parse+0x1b>
            *buf ++ = '\0';
c0100ba7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100baa:	8d 50 01             	lea    0x1(%eax),%edx
c0100bad:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bb0:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb6:	0f b6 00             	movzbl (%eax),%eax
c0100bb9:	84 c0                	test   %al,%al
c0100bbb:	74 1d                	je     c0100bda <parse+0x42>
c0100bbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc0:	0f b6 00             	movzbl (%eax),%eax
c0100bc3:	0f be c0             	movsbl %al,%eax
c0100bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bca:	c7 04 24 c0 cb 10 c0 	movl   $0xc010cbc0,(%esp)
c0100bd1:	e8 5f ba 00 00       	call   c010c635 <strchr>
c0100bd6:	85 c0                	test   %eax,%eax
c0100bd8:	75 cd                	jne    c0100ba7 <parse+0xf>
        }
        if (*buf == '\0') {
c0100bda:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdd:	0f b6 00             	movzbl (%eax),%eax
c0100be0:	84 c0                	test   %al,%al
c0100be2:	74 65                	je     c0100c49 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100be4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100be8:	75 14                	jne    c0100bfe <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bea:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bf1:	00 
c0100bf2:	c7 04 24 c5 cb 10 c0 	movl   $0xc010cbc5,(%esp)
c0100bf9:	e8 74 f7 ff ff       	call   c0100372 <cprintf>
        }
        argv[argc ++] = buf;
c0100bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c01:	8d 50 01             	lea    0x1(%eax),%edx
c0100c04:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c11:	01 c2                	add    %eax,%edx
c0100c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c16:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c18:	eb 03                	jmp    c0100c1d <parse+0x85>
            buf ++;
c0100c1a:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c20:	0f b6 00             	movzbl (%eax),%eax
c0100c23:	84 c0                	test   %al,%al
c0100c25:	74 8c                	je     c0100bb3 <parse+0x1b>
c0100c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2a:	0f b6 00             	movzbl (%eax),%eax
c0100c2d:	0f be c0             	movsbl %al,%eax
c0100c30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c34:	c7 04 24 c0 cb 10 c0 	movl   $0xc010cbc0,(%esp)
c0100c3b:	e8 f5 b9 00 00       	call   c010c635 <strchr>
c0100c40:	85 c0                	test   %eax,%eax
c0100c42:	74 d6                	je     c0100c1a <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c44:	e9 6a ff ff ff       	jmp    c0100bb3 <parse+0x1b>
            break;
c0100c49:	90                   	nop
        }
    }
    return argc;
c0100c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c4d:	89 ec                	mov    %ebp,%esp
c0100c4f:	5d                   	pop    %ebp
c0100c50:	c3                   	ret    

c0100c51 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c51:	55                   	push   %ebp
c0100c52:	89 e5                	mov    %esp,%ebp
c0100c54:	83 ec 68             	sub    $0x68,%esp
c0100c57:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c5a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c64:	89 04 24             	mov    %eax,(%esp)
c0100c67:	e8 2c ff ff ff       	call   c0100b98 <parse>
c0100c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c73:	75 0a                	jne    c0100c7f <runcmd+0x2e>
        return 0;
c0100c75:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c7a:	e9 83 00 00 00       	jmp    c0100d02 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c86:	eb 5a                	jmp    c0100ce2 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c88:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100c8b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c8e:	89 c8                	mov    %ecx,%eax
c0100c90:	01 c0                	add    %eax,%eax
c0100c92:	01 c8                	add    %ecx,%eax
c0100c94:	c1 e0 02             	shl    $0x2,%eax
c0100c97:	05 00 30 13 c0       	add    $0xc0133000,%eax
c0100c9c:	8b 00                	mov    (%eax),%eax
c0100c9e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100ca2:	89 04 24             	mov    %eax,(%esp)
c0100ca5:	e8 ef b8 00 00       	call   c010c599 <strcmp>
c0100caa:	85 c0                	test   %eax,%eax
c0100cac:	75 31                	jne    c0100cdf <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cae:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cb1:	89 d0                	mov    %edx,%eax
c0100cb3:	01 c0                	add    %eax,%eax
c0100cb5:	01 d0                	add    %edx,%eax
c0100cb7:	c1 e0 02             	shl    $0x2,%eax
c0100cba:	05 08 30 13 c0       	add    $0xc0133008,%eax
c0100cbf:	8b 10                	mov    (%eax),%edx
c0100cc1:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100cc4:	83 c0 04             	add    $0x4,%eax
c0100cc7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100cca:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100cd0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cd8:	89 1c 24             	mov    %ebx,(%esp)
c0100cdb:	ff d2                	call   *%edx
c0100cdd:	eb 23                	jmp    c0100d02 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cdf:	ff 45 f4             	incl   -0xc(%ebp)
c0100ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ce5:	83 f8 02             	cmp    $0x2,%eax
c0100ce8:	76 9e                	jbe    c0100c88 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ced:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf1:	c7 04 24 e3 cb 10 c0 	movl   $0xc010cbe3,(%esp)
c0100cf8:	e8 75 f6 ff ff       	call   c0100372 <cprintf>
    return 0;
c0100cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100d05:	89 ec                	mov    %ebp,%esp
c0100d07:	5d                   	pop    %ebp
c0100d08:	c3                   	ret    

c0100d09 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d09:	55                   	push   %ebp
c0100d0a:	89 e5                	mov    %esp,%ebp
c0100d0c:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d0f:	c7 04 24 fc cb 10 c0 	movl   $0xc010cbfc,(%esp)
c0100d16:	e8 57 f6 ff ff       	call   c0100372 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d1b:	c7 04 24 24 cc 10 c0 	movl   $0xc010cc24,(%esp)
c0100d22:	e8 4b f6 ff ff       	call   c0100372 <cprintf>

    if (tf != NULL) {
c0100d27:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d2b:	74 0b                	je     c0100d38 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d30:	89 04 24             	mov    %eax,(%esp)
c0100d33:	e8 a8 17 00 00       	call   c01024e0 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d38:	c7 04 24 49 cc 10 c0 	movl   $0xc010cc49,(%esp)
c0100d3f:	e8 1f f5 ff ff       	call   c0100263 <readline>
c0100d44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d4b:	74 eb                	je     c0100d38 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d57:	89 04 24             	mov    %eax,(%esp)
c0100d5a:	e8 f2 fe ff ff       	call   c0100c51 <runcmd>
c0100d5f:	85 c0                	test   %eax,%eax
c0100d61:	78 02                	js     c0100d65 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d63:	eb d3                	jmp    c0100d38 <kmonitor+0x2f>
                break;
c0100d65:	90                   	nop
            }
        }
    }
}
c0100d66:	90                   	nop
c0100d67:	89 ec                	mov    %ebp,%esp
c0100d69:	5d                   	pop    %ebp
c0100d6a:	c3                   	ret    

c0100d6b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d6b:	55                   	push   %ebp
c0100d6c:	89 e5                	mov    %esp,%ebp
c0100d6e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d78:	eb 3d                	jmp    c0100db7 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d7d:	89 d0                	mov    %edx,%eax
c0100d7f:	01 c0                	add    %eax,%eax
c0100d81:	01 d0                	add    %edx,%eax
c0100d83:	c1 e0 02             	shl    $0x2,%eax
c0100d86:	05 04 30 13 c0       	add    $0xc0133004,%eax
c0100d8b:	8b 10                	mov    (%eax),%edx
c0100d8d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100d90:	89 c8                	mov    %ecx,%eax
c0100d92:	01 c0                	add    %eax,%eax
c0100d94:	01 c8                	add    %ecx,%eax
c0100d96:	c1 e0 02             	shl    $0x2,%eax
c0100d99:	05 00 30 13 c0       	add    $0xc0133000,%eax
c0100d9e:	8b 00                	mov    (%eax),%eax
c0100da0:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100da4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100da8:	c7 04 24 4d cc 10 c0 	movl   $0xc010cc4d,(%esp)
c0100daf:	e8 be f5 ff ff       	call   c0100372 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100db4:	ff 45 f4             	incl   -0xc(%ebp)
c0100db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dba:	83 f8 02             	cmp    $0x2,%eax
c0100dbd:	76 bb                	jbe    c0100d7a <mon_help+0xf>
    }
    return 0;
c0100dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dc4:	89 ec                	mov    %ebp,%esp
c0100dc6:	5d                   	pop    %ebp
c0100dc7:	c3                   	ret    

c0100dc8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dc8:	55                   	push   %ebp
c0100dc9:	89 e5                	mov    %esp,%ebp
c0100dcb:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dce:	e8 b8 fb ff ff       	call   c010098b <print_kerninfo>
    return 0;
c0100dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd8:	89 ec                	mov    %ebp,%esp
c0100dda:	5d                   	pop    %ebp
c0100ddb:	c3                   	ret    

c0100ddc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ddc:	55                   	push   %ebp
c0100ddd:	89 e5                	mov    %esp,%ebp
c0100ddf:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100de2:	e8 f0 fc ff ff       	call   c0100ad7 <print_stackframe>
    return 0;
c0100de7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dec:	89 ec                	mov    %ebp,%esp
c0100dee:	5d                   	pop    %ebp
c0100def:	c3                   	ret    

c0100df0 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100df0:	55                   	push   %ebp
c0100df1:	89 e5                	mov    %esp,%ebp
c0100df3:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100df6:	a1 20 74 1b c0       	mov    0xc01b7420,%eax
c0100dfb:	85 c0                	test   %eax,%eax
c0100dfd:	75 5b                	jne    c0100e5a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100dff:	c7 05 20 74 1b c0 01 	movl   $0x1,0xc01b7420
c0100e06:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100e09:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e12:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e1d:	c7 04 24 56 cc 10 c0 	movl   $0xc010cc56,(%esp)
c0100e24:	e8 49 f5 ff ff       	call   c0100372 <cprintf>
    vcprintf(fmt, ap);
c0100e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e30:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e33:	89 04 24             	mov    %eax,(%esp)
c0100e36:	e8 02 f5 ff ff       	call   c010033d <vcprintf>
    cprintf("\n");
c0100e3b:	c7 04 24 72 cc 10 c0 	movl   $0xc010cc72,(%esp)
c0100e42:	e8 2b f5 ff ff       	call   c0100372 <cprintf>
    
    cprintf("stack trackback:\n");
c0100e47:	c7 04 24 74 cc 10 c0 	movl   $0xc010cc74,(%esp)
c0100e4e:	e8 1f f5 ff ff       	call   c0100372 <cprintf>
    print_stackframe();
c0100e53:	e8 7f fc ff ff       	call   c0100ad7 <print_stackframe>
c0100e58:	eb 01                	jmp    c0100e5b <__panic+0x6b>
        goto panic_dead;
c0100e5a:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100e5b:	e8 46 12 00 00       	call   c01020a6 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e67:	e8 9d fe ff ff       	call   c0100d09 <kmonitor>
c0100e6c:	eb f2                	jmp    c0100e60 <__panic+0x70>

c0100e6e <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e6e:	55                   	push   %ebp
c0100e6f:	89 e5                	mov    %esp,%ebp
c0100e71:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e74:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e77:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e7d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e81:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e88:	c7 04 24 86 cc 10 c0 	movl   $0xc010cc86,(%esp)
c0100e8f:	e8 de f4 ff ff       	call   c0100372 <cprintf>
    vcprintf(fmt, ap);
c0100e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e9b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e9e:	89 04 24             	mov    %eax,(%esp)
c0100ea1:	e8 97 f4 ff ff       	call   c010033d <vcprintf>
    cprintf("\n");
c0100ea6:	c7 04 24 72 cc 10 c0 	movl   $0xc010cc72,(%esp)
c0100ead:	e8 c0 f4 ff ff       	call   c0100372 <cprintf>
    va_end(ap);
}
c0100eb2:	90                   	nop
c0100eb3:	89 ec                	mov    %ebp,%esp
c0100eb5:	5d                   	pop    %ebp
c0100eb6:	c3                   	ret    

c0100eb7 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100eb7:	55                   	push   %ebp
c0100eb8:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100eba:	a1 20 74 1b c0       	mov    0xc01b7420,%eax
}
c0100ebf:	5d                   	pop    %ebp
c0100ec0:	c3                   	ret    

c0100ec1 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ec1:	55                   	push   %ebp
c0100ec2:	89 e5                	mov    %esp,%ebp
c0100ec4:	83 ec 28             	sub    $0x28,%esp
c0100ec7:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100ecd:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ed5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ed9:	ee                   	out    %al,(%dx)
}
c0100eda:	90                   	nop
c0100edb:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100ee1:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ee9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100eed:	ee                   	out    %al,(%dx)
}
c0100eee:	90                   	nop
c0100eef:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100ef5:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ef9:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100efd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f01:	ee                   	out    %al,(%dx)
}
c0100f02:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100f03:	c7 05 24 74 1b c0 00 	movl   $0x0,0xc01b7424
c0100f0a:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100f0d:	c7 04 24 a4 cc 10 c0 	movl   $0xc010cca4,(%esp)
c0100f14:	e8 59 f4 ff ff       	call   c0100372 <cprintf>
    pic_enable(IRQ_TIMER);
c0100f19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100f20:	e8 e6 11 00 00       	call   c010210b <pic_enable>
}
c0100f25:	90                   	nop
c0100f26:	89 ec                	mov    %ebp,%esp
c0100f28:	5d                   	pop    %ebp
c0100f29:	c3                   	ret    

c0100f2a <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100f2a:	55                   	push   %ebp
c0100f2b:	89 e5                	mov    %esp,%ebp
c0100f2d:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100f30:	9c                   	pushf  
c0100f31:	58                   	pop    %eax
c0100f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f38:	25 00 02 00 00       	and    $0x200,%eax
c0100f3d:	85 c0                	test   %eax,%eax
c0100f3f:	74 0c                	je     c0100f4d <__intr_save+0x23>
        intr_disable();
c0100f41:	e8 60 11 00 00       	call   c01020a6 <intr_disable>
        return 1;
c0100f46:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f4b:	eb 05                	jmp    c0100f52 <__intr_save+0x28>
    }
    return 0;
c0100f4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f52:	89 ec                	mov    %ebp,%esp
c0100f54:	5d                   	pop    %ebp
c0100f55:	c3                   	ret    

c0100f56 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f56:	55                   	push   %ebp
c0100f57:	89 e5                	mov    %esp,%ebp
c0100f59:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f5c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f60:	74 05                	je     c0100f67 <__intr_restore+0x11>
        intr_enable();
c0100f62:	e8 37 11 00 00       	call   c010209e <intr_enable>
    }
}
c0100f67:	90                   	nop
c0100f68:	89 ec                	mov    %ebp,%esp
c0100f6a:	5d                   	pop    %ebp
c0100f6b:	c3                   	ret    

c0100f6c <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f6c:	55                   	push   %ebp
c0100f6d:	89 e5                	mov    %esp,%ebp
c0100f6f:	83 ec 10             	sub    $0x10,%esp
c0100f72:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f78:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f7c:	89 c2                	mov    %eax,%edx
c0100f7e:	ec                   	in     (%dx),%al
c0100f7f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100f82:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f88:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f8c:	89 c2                	mov    %eax,%edx
c0100f8e:	ec                   	in     (%dx),%al
c0100f8f:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f92:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f98:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f9c:	89 c2                	mov    %eax,%edx
c0100f9e:	ec                   	in     (%dx),%al
c0100f9f:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100fa2:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100fa8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100fac:	89 c2                	mov    %eax,%edx
c0100fae:	ec                   	in     (%dx),%al
c0100faf:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100fb2:	90                   	nop
c0100fb3:	89 ec                	mov    %ebp,%esp
c0100fb5:	5d                   	pop    %ebp
c0100fb6:	c3                   	ret    

c0100fb7 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100fb7:	55                   	push   %ebp
c0100fb8:	89 e5                	mov    %esp,%ebp
c0100fba:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100fbd:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100fc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc7:	0f b7 00             	movzwl (%eax),%eax
c0100fca:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100fce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fd1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100fd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fd9:	0f b7 00             	movzwl (%eax),%eax
c0100fdc:	0f b7 c0             	movzwl %ax,%eax
c0100fdf:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100fe4:	74 12                	je     c0100ff8 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fe6:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fed:	66 c7 05 46 74 1b c0 	movw   $0x3b4,0xc01b7446
c0100ff4:	b4 03 
c0100ff6:	eb 13                	jmp    c010100b <cga_init+0x54>
    } else {
        *cp = was;
c0100ff8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ffb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100fff:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101002:	66 c7 05 46 74 1b c0 	movw   $0x3d4,0xc01b7446
c0101009:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c010100b:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c0101012:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101016:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010101e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101022:	ee                   	out    %al,(%dx)
}
c0101023:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0101024:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c010102b:	40                   	inc    %eax
c010102c:	0f b7 c0             	movzwl %ax,%eax
c010102f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101033:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101037:	89 c2                	mov    %eax,%edx
c0101039:	ec                   	in     (%dx),%al
c010103a:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c010103d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101041:	0f b6 c0             	movzbl %al,%eax
c0101044:	c1 e0 08             	shl    $0x8,%eax
c0101047:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010104a:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c0101051:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101055:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101059:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010105d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101061:	ee                   	out    %al,(%dx)
}
c0101062:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0101063:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c010106a:	40                   	inc    %eax
c010106b:	0f b7 c0             	movzwl %ax,%eax
c010106e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101072:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101076:	89 c2                	mov    %eax,%edx
c0101078:	ec                   	in     (%dx),%al
c0101079:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c010107c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101080:	0f b6 c0             	movzbl %al,%eax
c0101083:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101086:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101089:	a3 40 74 1b c0       	mov    %eax,0xc01b7440
    crt_pos = pos;
c010108e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101091:	0f b7 c0             	movzwl %ax,%eax
c0101094:	66 a3 44 74 1b c0    	mov    %ax,0xc01b7444
}
c010109a:	90                   	nop
c010109b:	89 ec                	mov    %ebp,%esp
c010109d:	5d                   	pop    %ebp
c010109e:	c3                   	ret    

c010109f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010109f:	55                   	push   %ebp
c01010a0:	89 e5                	mov    %esp,%ebp
c01010a2:	83 ec 48             	sub    $0x48,%esp
c01010a5:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01010ab:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010af:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01010b3:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01010b7:	ee                   	out    %al,(%dx)
}
c01010b8:	90                   	nop
c01010b9:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01010bf:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010c3:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01010c7:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01010cb:	ee                   	out    %al,(%dx)
}
c01010cc:	90                   	nop
c01010cd:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01010d3:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010d7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01010db:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01010df:	ee                   	out    %al,(%dx)
}
c01010e0:	90                   	nop
c01010e1:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01010e7:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010eb:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01010ef:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01010f3:	ee                   	out    %al,(%dx)
}
c01010f4:	90                   	nop
c01010f5:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c01010fb:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010ff:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101103:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101107:	ee                   	out    %al,(%dx)
}
c0101108:	90                   	nop
c0101109:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010110f:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101113:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101117:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010111b:	ee                   	out    %al,(%dx)
}
c010111c:	90                   	nop
c010111d:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101123:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101127:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010112b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010112f:	ee                   	out    %al,(%dx)
}
c0101130:	90                   	nop
c0101131:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101137:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010113b:	89 c2                	mov    %eax,%edx
c010113d:	ec                   	in     (%dx),%al
c010113e:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101141:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101145:	3c ff                	cmp    $0xff,%al
c0101147:	0f 95 c0             	setne  %al
c010114a:	0f b6 c0             	movzbl %al,%eax
c010114d:	a3 48 74 1b c0       	mov    %eax,0xc01b7448
c0101152:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101158:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010115c:	89 c2                	mov    %eax,%edx
c010115e:	ec                   	in     (%dx),%al
c010115f:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101162:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101168:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010116c:	89 c2                	mov    %eax,%edx
c010116e:	ec                   	in     (%dx),%al
c010116f:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101172:	a1 48 74 1b c0       	mov    0xc01b7448,%eax
c0101177:	85 c0                	test   %eax,%eax
c0101179:	74 0c                	je     c0101187 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c010117b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101182:	e8 84 0f 00 00       	call   c010210b <pic_enable>
    }
}
c0101187:	90                   	nop
c0101188:	89 ec                	mov    %ebp,%esp
c010118a:	5d                   	pop    %ebp
c010118b:	c3                   	ret    

c010118c <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010118c:	55                   	push   %ebp
c010118d:	89 e5                	mov    %esp,%ebp
c010118f:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101192:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101199:	eb 08                	jmp    c01011a3 <lpt_putc_sub+0x17>
        delay();
c010119b:	e8 cc fd ff ff       	call   c0100f6c <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01011a0:	ff 45 fc             	incl   -0x4(%ebp)
c01011a3:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01011a9:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01011ad:	89 c2                	mov    %eax,%edx
c01011af:	ec                   	in     (%dx),%al
c01011b0:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01011b3:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01011b7:	84 c0                	test   %al,%al
c01011b9:	78 09                	js     c01011c4 <lpt_putc_sub+0x38>
c01011bb:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01011c2:	7e d7                	jle    c010119b <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01011c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01011c7:	0f b6 c0             	movzbl %al,%eax
c01011ca:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01011d0:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011d3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011d7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011db:	ee                   	out    %al,(%dx)
}
c01011dc:	90                   	nop
c01011dd:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01011e3:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011e7:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011eb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011ef:	ee                   	out    %al,(%dx)
}
c01011f0:	90                   	nop
c01011f1:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01011f7:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011fb:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011ff:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101203:	ee                   	out    %al,(%dx)
}
c0101204:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101205:	90                   	nop
c0101206:	89 ec                	mov    %ebp,%esp
c0101208:	5d                   	pop    %ebp
c0101209:	c3                   	ret    

c010120a <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010120a:	55                   	push   %ebp
c010120b:	89 e5                	mov    %esp,%ebp
c010120d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101210:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101214:	74 0d                	je     c0101223 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101216:	8b 45 08             	mov    0x8(%ebp),%eax
c0101219:	89 04 24             	mov    %eax,(%esp)
c010121c:	e8 6b ff ff ff       	call   c010118c <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101221:	eb 24                	jmp    c0101247 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101223:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010122a:	e8 5d ff ff ff       	call   c010118c <lpt_putc_sub>
        lpt_putc_sub(' ');
c010122f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101236:	e8 51 ff ff ff       	call   c010118c <lpt_putc_sub>
        lpt_putc_sub('\b');
c010123b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101242:	e8 45 ff ff ff       	call   c010118c <lpt_putc_sub>
}
c0101247:	90                   	nop
c0101248:	89 ec                	mov    %ebp,%esp
c010124a:	5d                   	pop    %ebp
c010124b:	c3                   	ret    

c010124c <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010124c:	55                   	push   %ebp
c010124d:	89 e5                	mov    %esp,%ebp
c010124f:	83 ec 38             	sub    $0x38,%esp
c0101252:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101255:	8b 45 08             	mov    0x8(%ebp),%eax
c0101258:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010125d:	85 c0                	test   %eax,%eax
c010125f:	75 07                	jne    c0101268 <cga_putc+0x1c>
        c |= 0x0700;
c0101261:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101268:	8b 45 08             	mov    0x8(%ebp),%eax
c010126b:	0f b6 c0             	movzbl %al,%eax
c010126e:	83 f8 0d             	cmp    $0xd,%eax
c0101271:	74 72                	je     c01012e5 <cga_putc+0x99>
c0101273:	83 f8 0d             	cmp    $0xd,%eax
c0101276:	0f 8f a3 00 00 00    	jg     c010131f <cga_putc+0xd3>
c010127c:	83 f8 08             	cmp    $0x8,%eax
c010127f:	74 0a                	je     c010128b <cga_putc+0x3f>
c0101281:	83 f8 0a             	cmp    $0xa,%eax
c0101284:	74 4c                	je     c01012d2 <cga_putc+0x86>
c0101286:	e9 94 00 00 00       	jmp    c010131f <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c010128b:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c0101292:	85 c0                	test   %eax,%eax
c0101294:	0f 84 af 00 00 00    	je     c0101349 <cga_putc+0xfd>
            crt_pos --;
c010129a:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c01012a1:	48                   	dec    %eax
c01012a2:	0f b7 c0             	movzwl %ax,%eax
c01012a5:	66 a3 44 74 1b c0    	mov    %ax,0xc01b7444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01012ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01012ae:	98                   	cwtl   
c01012af:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01012b4:	98                   	cwtl   
c01012b5:	83 c8 20             	or     $0x20,%eax
c01012b8:	98                   	cwtl   
c01012b9:	8b 0d 40 74 1b c0    	mov    0xc01b7440,%ecx
c01012bf:	0f b7 15 44 74 1b c0 	movzwl 0xc01b7444,%edx
c01012c6:	01 d2                	add    %edx,%edx
c01012c8:	01 ca                	add    %ecx,%edx
c01012ca:	0f b7 c0             	movzwl %ax,%eax
c01012cd:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01012d0:	eb 77                	jmp    c0101349 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01012d2:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c01012d9:	83 c0 50             	add    $0x50,%eax
c01012dc:	0f b7 c0             	movzwl %ax,%eax
c01012df:	66 a3 44 74 1b c0    	mov    %ax,0xc01b7444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01012e5:	0f b7 1d 44 74 1b c0 	movzwl 0xc01b7444,%ebx
c01012ec:	0f b7 0d 44 74 1b c0 	movzwl 0xc01b7444,%ecx
c01012f3:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01012f8:	89 c8                	mov    %ecx,%eax
c01012fa:	f7 e2                	mul    %edx
c01012fc:	c1 ea 06             	shr    $0x6,%edx
c01012ff:	89 d0                	mov    %edx,%eax
c0101301:	c1 e0 02             	shl    $0x2,%eax
c0101304:	01 d0                	add    %edx,%eax
c0101306:	c1 e0 04             	shl    $0x4,%eax
c0101309:	29 c1                	sub    %eax,%ecx
c010130b:	89 ca                	mov    %ecx,%edx
c010130d:	0f b7 d2             	movzwl %dx,%edx
c0101310:	89 d8                	mov    %ebx,%eax
c0101312:	29 d0                	sub    %edx,%eax
c0101314:	0f b7 c0             	movzwl %ax,%eax
c0101317:	66 a3 44 74 1b c0    	mov    %ax,0xc01b7444
        break;
c010131d:	eb 2b                	jmp    c010134a <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010131f:	8b 0d 40 74 1b c0    	mov    0xc01b7440,%ecx
c0101325:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c010132c:	8d 50 01             	lea    0x1(%eax),%edx
c010132f:	0f b7 d2             	movzwl %dx,%edx
c0101332:	66 89 15 44 74 1b c0 	mov    %dx,0xc01b7444
c0101339:	01 c0                	add    %eax,%eax
c010133b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010133e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101341:	0f b7 c0             	movzwl %ax,%eax
c0101344:	66 89 02             	mov    %ax,(%edx)
        break;
c0101347:	eb 01                	jmp    c010134a <cga_putc+0xfe>
        break;
c0101349:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010134a:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c0101351:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101356:	76 5e                	jbe    c01013b6 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101358:	a1 40 74 1b c0       	mov    0xc01b7440,%eax
c010135d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101363:	a1 40 74 1b c0       	mov    0xc01b7440,%eax
c0101368:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010136f:	00 
c0101370:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101374:	89 04 24             	mov    %eax,(%esp)
c0101377:	e8 b7 b4 00 00       	call   c010c833 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010137c:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101383:	eb 15                	jmp    c010139a <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101385:	8b 15 40 74 1b c0    	mov    0xc01b7440,%edx
c010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010138e:	01 c0                	add    %eax,%eax
c0101390:	01 d0                	add    %edx,%eax
c0101392:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101397:	ff 45 f4             	incl   -0xc(%ebp)
c010139a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01013a1:	7e e2                	jle    c0101385 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01013a3:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c01013aa:	83 e8 50             	sub    $0x50,%eax
c01013ad:	0f b7 c0             	movzwl %ax,%eax
c01013b0:	66 a3 44 74 1b c0    	mov    %ax,0xc01b7444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01013b6:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c01013bd:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01013c1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013c5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013c9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013cd:	ee                   	out    %al,(%dx)
}
c01013ce:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01013cf:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c01013d6:	c1 e8 08             	shr    $0x8,%eax
c01013d9:	0f b7 c0             	movzwl %ax,%eax
c01013dc:	0f b6 c0             	movzbl %al,%eax
c01013df:	0f b7 15 46 74 1b c0 	movzwl 0xc01b7446,%edx
c01013e6:	42                   	inc    %edx
c01013e7:	0f b7 d2             	movzwl %dx,%edx
c01013ea:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01013ee:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013f1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013f5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013f9:	ee                   	out    %al,(%dx)
}
c01013fa:	90                   	nop
    outb(addr_6845, 15);
c01013fb:	0f b7 05 46 74 1b c0 	movzwl 0xc01b7446,%eax
c0101402:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101406:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010140a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010140e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101412:	ee                   	out    %al,(%dx)
}
c0101413:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101414:	0f b7 05 44 74 1b c0 	movzwl 0xc01b7444,%eax
c010141b:	0f b6 c0             	movzbl %al,%eax
c010141e:	0f b7 15 46 74 1b c0 	movzwl 0xc01b7446,%edx
c0101425:	42                   	inc    %edx
c0101426:	0f b7 d2             	movzwl %dx,%edx
c0101429:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010142d:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101430:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101434:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101438:	ee                   	out    %al,(%dx)
}
c0101439:	90                   	nop
}
c010143a:	90                   	nop
c010143b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010143e:	89 ec                	mov    %ebp,%esp
c0101440:	5d                   	pop    %ebp
c0101441:	c3                   	ret    

c0101442 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101442:	55                   	push   %ebp
c0101443:	89 e5                	mov    %esp,%ebp
c0101445:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101448:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010144f:	eb 08                	jmp    c0101459 <serial_putc_sub+0x17>
        delay();
c0101451:	e8 16 fb ff ff       	call   c0100f6c <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101456:	ff 45 fc             	incl   -0x4(%ebp)
c0101459:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101463:	89 c2                	mov    %eax,%edx
c0101465:	ec                   	in     (%dx),%al
c0101466:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101469:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010146d:	0f b6 c0             	movzbl %al,%eax
c0101470:	83 e0 20             	and    $0x20,%eax
c0101473:	85 c0                	test   %eax,%eax
c0101475:	75 09                	jne    c0101480 <serial_putc_sub+0x3e>
c0101477:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010147e:	7e d1                	jle    c0101451 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101480:	8b 45 08             	mov    0x8(%ebp),%eax
c0101483:	0f b6 c0             	movzbl %al,%eax
c0101486:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010148c:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010148f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101493:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101497:	ee                   	out    %al,(%dx)
}
c0101498:	90                   	nop
}
c0101499:	90                   	nop
c010149a:	89 ec                	mov    %ebp,%esp
c010149c:	5d                   	pop    %ebp
c010149d:	c3                   	ret    

c010149e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010149e:	55                   	push   %ebp
c010149f:	89 e5                	mov    %esp,%ebp
c01014a1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01014a4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01014a8:	74 0d                	je     c01014b7 <serial_putc+0x19>
        serial_putc_sub(c);
c01014aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01014ad:	89 04 24             	mov    %eax,(%esp)
c01014b0:	e8 8d ff ff ff       	call   c0101442 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01014b5:	eb 24                	jmp    c01014db <serial_putc+0x3d>
        serial_putc_sub('\b');
c01014b7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01014be:	e8 7f ff ff ff       	call   c0101442 <serial_putc_sub>
        serial_putc_sub(' ');
c01014c3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01014ca:	e8 73 ff ff ff       	call   c0101442 <serial_putc_sub>
        serial_putc_sub('\b');
c01014cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01014d6:	e8 67 ff ff ff       	call   c0101442 <serial_putc_sub>
}
c01014db:	90                   	nop
c01014dc:	89 ec                	mov    %ebp,%esp
c01014de:	5d                   	pop    %ebp
c01014df:	c3                   	ret    

c01014e0 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01014e0:	55                   	push   %ebp
c01014e1:	89 e5                	mov    %esp,%ebp
c01014e3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01014e6:	eb 33                	jmp    c010151b <cons_intr+0x3b>
        if (c != 0) {
c01014e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014ec:	74 2d                	je     c010151b <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01014ee:	a1 64 76 1b c0       	mov    0xc01b7664,%eax
c01014f3:	8d 50 01             	lea    0x1(%eax),%edx
c01014f6:	89 15 64 76 1b c0    	mov    %edx,0xc01b7664
c01014fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01014ff:	88 90 60 74 1b c0    	mov    %dl,-0x3fe48ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101505:	a1 64 76 1b c0       	mov    0xc01b7664,%eax
c010150a:	3d 00 02 00 00       	cmp    $0x200,%eax
c010150f:	75 0a                	jne    c010151b <cons_intr+0x3b>
                cons.wpos = 0;
c0101511:	c7 05 64 76 1b c0 00 	movl   $0x0,0xc01b7664
c0101518:	00 00 00 
    while ((c = (*proc)()) != -1) {
c010151b:	8b 45 08             	mov    0x8(%ebp),%eax
c010151e:	ff d0                	call   *%eax
c0101520:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101523:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101527:	75 bf                	jne    c01014e8 <cons_intr+0x8>
            }
        }
    }
}
c0101529:	90                   	nop
c010152a:	90                   	nop
c010152b:	89 ec                	mov    %ebp,%esp
c010152d:	5d                   	pop    %ebp
c010152e:	c3                   	ret    

c010152f <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010152f:	55                   	push   %ebp
c0101530:	89 e5                	mov    %esp,%ebp
c0101532:	83 ec 10             	sub    $0x10,%esp
c0101535:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010153b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010153f:	89 c2                	mov    %eax,%edx
c0101541:	ec                   	in     (%dx),%al
c0101542:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101545:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101549:	0f b6 c0             	movzbl %al,%eax
c010154c:	83 e0 01             	and    $0x1,%eax
c010154f:	85 c0                	test   %eax,%eax
c0101551:	75 07                	jne    c010155a <serial_proc_data+0x2b>
        return -1;
c0101553:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101558:	eb 2a                	jmp    c0101584 <serial_proc_data+0x55>
c010155a:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101560:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101564:	89 c2                	mov    %eax,%edx
c0101566:	ec                   	in     (%dx),%al
c0101567:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010156a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010156e:	0f b6 c0             	movzbl %al,%eax
c0101571:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101574:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101578:	75 07                	jne    c0101581 <serial_proc_data+0x52>
        c = '\b';
c010157a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101581:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101584:	89 ec                	mov    %ebp,%esp
c0101586:	5d                   	pop    %ebp
c0101587:	c3                   	ret    

c0101588 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101588:	55                   	push   %ebp
c0101589:	89 e5                	mov    %esp,%ebp
c010158b:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010158e:	a1 48 74 1b c0       	mov    0xc01b7448,%eax
c0101593:	85 c0                	test   %eax,%eax
c0101595:	74 0c                	je     c01015a3 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101597:	c7 04 24 2f 15 10 c0 	movl   $0xc010152f,(%esp)
c010159e:	e8 3d ff ff ff       	call   c01014e0 <cons_intr>
    }
}
c01015a3:	90                   	nop
c01015a4:	89 ec                	mov    %ebp,%esp
c01015a6:	5d                   	pop    %ebp
c01015a7:	c3                   	ret    

c01015a8 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01015a8:	55                   	push   %ebp
c01015a9:	89 e5                	mov    %esp,%ebp
c01015ab:	83 ec 38             	sub    $0x38,%esp
c01015ae:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015b7:	89 c2                	mov    %eax,%edx
c01015b9:	ec                   	in     (%dx),%al
c01015ba:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01015bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01015c1:	0f b6 c0             	movzbl %al,%eax
c01015c4:	83 e0 01             	and    $0x1,%eax
c01015c7:	85 c0                	test   %eax,%eax
c01015c9:	75 0a                	jne    c01015d5 <kbd_proc_data+0x2d>
        return -1;
c01015cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01015d0:	e9 56 01 00 00       	jmp    c010172b <kbd_proc_data+0x183>
c01015d5:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015de:	89 c2                	mov    %eax,%edx
c01015e0:	ec                   	in     (%dx),%al
c01015e1:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01015e4:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01015e8:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01015eb:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01015ef:	75 17                	jne    c0101608 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01015f1:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c01015f6:	83 c8 40             	or     $0x40,%eax
c01015f9:	a3 68 76 1b c0       	mov    %eax,0xc01b7668
        return 0;
c01015fe:	b8 00 00 00 00       	mov    $0x0,%eax
c0101603:	e9 23 01 00 00       	jmp    c010172b <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101608:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010160c:	84 c0                	test   %al,%al
c010160e:	79 45                	jns    c0101655 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101610:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c0101615:	83 e0 40             	and    $0x40,%eax
c0101618:	85 c0                	test   %eax,%eax
c010161a:	75 08                	jne    c0101624 <kbd_proc_data+0x7c>
c010161c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101620:	24 7f                	and    $0x7f,%al
c0101622:	eb 04                	jmp    c0101628 <kbd_proc_data+0x80>
c0101624:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101628:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010162b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010162f:	0f b6 80 40 30 13 c0 	movzbl -0x3feccfc0(%eax),%eax
c0101636:	0c 40                	or     $0x40,%al
c0101638:	0f b6 c0             	movzbl %al,%eax
c010163b:	f7 d0                	not    %eax
c010163d:	89 c2                	mov    %eax,%edx
c010163f:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c0101644:	21 d0                	and    %edx,%eax
c0101646:	a3 68 76 1b c0       	mov    %eax,0xc01b7668
        return 0;
c010164b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101650:	e9 d6 00 00 00       	jmp    c010172b <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101655:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c010165a:	83 e0 40             	and    $0x40,%eax
c010165d:	85 c0                	test   %eax,%eax
c010165f:	74 11                	je     c0101672 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101661:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101665:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c010166a:	83 e0 bf             	and    $0xffffffbf,%eax
c010166d:	a3 68 76 1b c0       	mov    %eax,0xc01b7668
    }

    shift |= shiftcode[data];
c0101672:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101676:	0f b6 80 40 30 13 c0 	movzbl -0x3feccfc0(%eax),%eax
c010167d:	0f b6 d0             	movzbl %al,%edx
c0101680:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c0101685:	09 d0                	or     %edx,%eax
c0101687:	a3 68 76 1b c0       	mov    %eax,0xc01b7668
    shift ^= togglecode[data];
c010168c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101690:	0f b6 80 40 31 13 c0 	movzbl -0x3feccec0(%eax),%eax
c0101697:	0f b6 d0             	movzbl %al,%edx
c010169a:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c010169f:	31 d0                	xor    %edx,%eax
c01016a1:	a3 68 76 1b c0       	mov    %eax,0xc01b7668

    c = charcode[shift & (CTL | SHIFT)][data];
c01016a6:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c01016ab:	83 e0 03             	and    $0x3,%eax
c01016ae:	8b 14 85 40 35 13 c0 	mov    -0x3feccac0(,%eax,4),%edx
c01016b5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01016b9:	01 d0                	add    %edx,%eax
c01016bb:	0f b6 00             	movzbl (%eax),%eax
c01016be:	0f b6 c0             	movzbl %al,%eax
c01016c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01016c4:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c01016c9:	83 e0 08             	and    $0x8,%eax
c01016cc:	85 c0                	test   %eax,%eax
c01016ce:	74 22                	je     c01016f2 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01016d0:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01016d4:	7e 0c                	jle    c01016e2 <kbd_proc_data+0x13a>
c01016d6:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01016da:	7f 06                	jg     c01016e2 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01016dc:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01016e0:	eb 10                	jmp    c01016f2 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01016e2:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01016e6:	7e 0a                	jle    c01016f2 <kbd_proc_data+0x14a>
c01016e8:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01016ec:	7f 04                	jg     c01016f2 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01016ee:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01016f2:	a1 68 76 1b c0       	mov    0xc01b7668,%eax
c01016f7:	f7 d0                	not    %eax
c01016f9:	83 e0 06             	and    $0x6,%eax
c01016fc:	85 c0                	test   %eax,%eax
c01016fe:	75 28                	jne    c0101728 <kbd_proc_data+0x180>
c0101700:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101707:	75 1f                	jne    c0101728 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101709:	c7 04 24 bf cc 10 c0 	movl   $0xc010ccbf,(%esp)
c0101710:	e8 5d ec ff ff       	call   c0100372 <cprintf>
c0101715:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c010171b:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010171f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101723:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101726:	ee                   	out    %al,(%dx)
}
c0101727:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101728:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010172b:	89 ec                	mov    %ebp,%esp
c010172d:	5d                   	pop    %ebp
c010172e:	c3                   	ret    

c010172f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010172f:	55                   	push   %ebp
c0101730:	89 e5                	mov    %esp,%ebp
c0101732:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101735:	c7 04 24 a8 15 10 c0 	movl   $0xc01015a8,(%esp)
c010173c:	e8 9f fd ff ff       	call   c01014e0 <cons_intr>
}
c0101741:	90                   	nop
c0101742:	89 ec                	mov    %ebp,%esp
c0101744:	5d                   	pop    %ebp
c0101745:	c3                   	ret    

c0101746 <kbd_init>:

static void
kbd_init(void) {
c0101746:	55                   	push   %ebp
c0101747:	89 e5                	mov    %esp,%ebp
c0101749:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c010174c:	e8 de ff ff ff       	call   c010172f <kbd_intr>
    pic_enable(IRQ_KBD);
c0101751:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101758:	e8 ae 09 00 00       	call   c010210b <pic_enable>
}
c010175d:	90                   	nop
c010175e:	89 ec                	mov    %ebp,%esp
c0101760:	5d                   	pop    %ebp
c0101761:	c3                   	ret    

c0101762 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101762:	55                   	push   %ebp
c0101763:	89 e5                	mov    %esp,%ebp
c0101765:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101768:	e8 4a f8 ff ff       	call   c0100fb7 <cga_init>
    serial_init();
c010176d:	e8 2d f9 ff ff       	call   c010109f <serial_init>
    kbd_init();
c0101772:	e8 cf ff ff ff       	call   c0101746 <kbd_init>
    if (!serial_exists) {
c0101777:	a1 48 74 1b c0       	mov    0xc01b7448,%eax
c010177c:	85 c0                	test   %eax,%eax
c010177e:	75 0c                	jne    c010178c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101780:	c7 04 24 cb cc 10 c0 	movl   $0xc010cccb,(%esp)
c0101787:	e8 e6 eb ff ff       	call   c0100372 <cprintf>
    }
}
c010178c:	90                   	nop
c010178d:	89 ec                	mov    %ebp,%esp
c010178f:	5d                   	pop    %ebp
c0101790:	c3                   	ret    

c0101791 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101791:	55                   	push   %ebp
c0101792:	89 e5                	mov    %esp,%ebp
c0101794:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101797:	e8 8e f7 ff ff       	call   c0100f2a <__intr_save>
c010179c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010179f:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a2:	89 04 24             	mov    %eax,(%esp)
c01017a5:	e8 60 fa ff ff       	call   c010120a <lpt_putc>
        cga_putc(c);
c01017aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01017ad:	89 04 24             	mov    %eax,(%esp)
c01017b0:	e8 97 fa ff ff       	call   c010124c <cga_putc>
        serial_putc(c);
c01017b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01017b8:	89 04 24             	mov    %eax,(%esp)
c01017bb:	e8 de fc ff ff       	call   c010149e <serial_putc>
    }
    local_intr_restore(intr_flag);
c01017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017c3:	89 04 24             	mov    %eax,(%esp)
c01017c6:	e8 8b f7 ff ff       	call   c0100f56 <__intr_restore>
}
c01017cb:	90                   	nop
c01017cc:	89 ec                	mov    %ebp,%esp
c01017ce:	5d                   	pop    %ebp
c01017cf:	c3                   	ret    

c01017d0 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01017d0:	55                   	push   %ebp
c01017d1:	89 e5                	mov    %esp,%ebp
c01017d3:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01017d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01017dd:	e8 48 f7 ff ff       	call   c0100f2a <__intr_save>
c01017e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01017e5:	e8 9e fd ff ff       	call   c0101588 <serial_intr>
        kbd_intr();
c01017ea:	e8 40 ff ff ff       	call   c010172f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01017ef:	8b 15 60 76 1b c0    	mov    0xc01b7660,%edx
c01017f5:	a1 64 76 1b c0       	mov    0xc01b7664,%eax
c01017fa:	39 c2                	cmp    %eax,%edx
c01017fc:	74 31                	je     c010182f <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01017fe:	a1 60 76 1b c0       	mov    0xc01b7660,%eax
c0101803:	8d 50 01             	lea    0x1(%eax),%edx
c0101806:	89 15 60 76 1b c0    	mov    %edx,0xc01b7660
c010180c:	0f b6 80 60 74 1b c0 	movzbl -0x3fe48ba0(%eax),%eax
c0101813:	0f b6 c0             	movzbl %al,%eax
c0101816:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101819:	a1 60 76 1b c0       	mov    0xc01b7660,%eax
c010181e:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101823:	75 0a                	jne    c010182f <cons_getc+0x5f>
                cons.rpos = 0;
c0101825:	c7 05 60 76 1b c0 00 	movl   $0x0,0xc01b7660
c010182c:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101832:	89 04 24             	mov    %eax,(%esp)
c0101835:	e8 1c f7 ff ff       	call   c0100f56 <__intr_restore>
    return c;
c010183a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010183d:	89 ec                	mov    %ebp,%esp
c010183f:	5d                   	pop    %ebp
c0101840:	c3                   	ret    

c0101841 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0101841:	55                   	push   %ebp
c0101842:	89 e5                	mov    %esp,%ebp
c0101844:	83 ec 14             	sub    $0x14,%esp
c0101847:	8b 45 08             	mov    0x8(%ebp),%eax
c010184a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c010184e:	90                   	nop
c010184f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101852:	83 c0 07             	add    $0x7,%eax
c0101855:	0f b7 c0             	movzwl %ax,%eax
c0101858:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010185c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101860:	89 c2                	mov    %eax,%edx
c0101862:	ec                   	in     (%dx),%al
c0101863:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101866:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010186a:	0f b6 c0             	movzbl %al,%eax
c010186d:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101870:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101873:	25 80 00 00 00       	and    $0x80,%eax
c0101878:	85 c0                	test   %eax,%eax
c010187a:	75 d3                	jne    c010184f <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010187c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101880:	74 11                	je     c0101893 <ide_wait_ready+0x52>
c0101882:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101885:	83 e0 21             	and    $0x21,%eax
c0101888:	85 c0                	test   %eax,%eax
c010188a:	74 07                	je     c0101893 <ide_wait_ready+0x52>
        return -1;
c010188c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101891:	eb 05                	jmp    c0101898 <ide_wait_ready+0x57>
    }
    return 0;
c0101893:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101898:	89 ec                	mov    %ebp,%esp
c010189a:	5d                   	pop    %ebp
c010189b:	c3                   	ret    

c010189c <ide_init>:

void
ide_init(void) {
c010189c:	55                   	push   %ebp
c010189d:	89 e5                	mov    %esp,%ebp
c010189f:	57                   	push   %edi
c01018a0:	53                   	push   %ebx
c01018a1:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01018a7:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01018ad:	e9 bd 02 00 00       	jmp    c0101b6f <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01018b2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018b6:	89 d0                	mov    %edx,%eax
c01018b8:	c1 e0 03             	shl    $0x3,%eax
c01018bb:	29 d0                	sub    %edx,%eax
c01018bd:	c1 e0 03             	shl    $0x3,%eax
c01018c0:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c01018c5:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01018c8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018cc:	d1 e8                	shr    %eax
c01018ce:	0f b7 c0             	movzwl %ax,%eax
c01018d1:	8b 04 85 ec cc 10 c0 	mov    -0x3fef3314(,%eax,4),%eax
c01018d8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01018dc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018e7:	00 
c01018e8:	89 04 24             	mov    %eax,(%esp)
c01018eb:	e8 51 ff ff ff       	call   c0101841 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01018f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018f4:	c1 e0 04             	shl    $0x4,%eax
c01018f7:	24 10                	and    $0x10,%al
c01018f9:	0c e0                	or     $0xe0,%al
c01018fb:	0f b6 c0             	movzbl %al,%eax
c01018fe:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101902:	83 c2 06             	add    $0x6,%edx
c0101905:	0f b7 d2             	movzwl %dx,%edx
c0101908:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c010190c:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010190f:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101913:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101917:	ee                   	out    %al,(%dx)
}
c0101918:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101919:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010191d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101924:	00 
c0101925:	89 04 24             	mov    %eax,(%esp)
c0101928:	e8 14 ff ff ff       	call   c0101841 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c010192d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101931:	83 c0 07             	add    $0x7,%eax
c0101934:	0f b7 c0             	movzwl %ax,%eax
c0101937:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c010193b:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010193f:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101943:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101947:	ee                   	out    %al,(%dx)
}
c0101948:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101949:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010194d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101954:	00 
c0101955:	89 04 24             	mov    %eax,(%esp)
c0101958:	e8 e4 fe ff ff       	call   c0101841 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c010195d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101961:	83 c0 07             	add    $0x7,%eax
c0101964:	0f b7 c0             	movzwl %ax,%eax
c0101967:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010196b:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010196f:	89 c2                	mov    %eax,%edx
c0101971:	ec                   	in     (%dx),%al
c0101972:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0101975:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101979:	84 c0                	test   %al,%al
c010197b:	0f 84 e4 01 00 00    	je     c0101b65 <ide_init+0x2c9>
c0101981:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101985:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010198c:	00 
c010198d:	89 04 24             	mov    %eax,(%esp)
c0101990:	e8 ac fe ff ff       	call   c0101841 <ide_wait_ready>
c0101995:	85 c0                	test   %eax,%eax
c0101997:	0f 85 c8 01 00 00    	jne    c0101b65 <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010199d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019a1:	89 d0                	mov    %edx,%eax
c01019a3:	c1 e0 03             	shl    $0x3,%eax
c01019a6:	29 d0                	sub    %edx,%eax
c01019a8:	c1 e0 03             	shl    $0x3,%eax
c01019ab:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c01019b0:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01019b3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01019b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01019ba:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01019c0:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01019c3:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c01019ca:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01019cd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01019d0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01019d3:	89 cb                	mov    %ecx,%ebx
c01019d5:	89 df                	mov    %ebx,%edi
c01019d7:	89 c1                	mov    %eax,%ecx
c01019d9:	fc                   	cld    
c01019da:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01019dc:	89 c8                	mov    %ecx,%eax
c01019de:	89 fb                	mov    %edi,%ebx
c01019e0:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c01019e3:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c01019e6:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c01019e7:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01019ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01019f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019f3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01019f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01019fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019ff:	25 00 00 00 04       	and    $0x4000000,%eax
c0101a04:	85 c0                	test   %eax,%eax
c0101a06:	74 0e                	je     c0101a16 <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101a08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a0b:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101a14:	eb 09                	jmp    c0101a1f <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101a16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a19:	8b 40 78             	mov    0x78(%eax),%eax
c0101a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101a1f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a23:	89 d0                	mov    %edx,%eax
c0101a25:	c1 e0 03             	shl    $0x3,%eax
c0101a28:	29 d0                	sub    %edx,%eax
c0101a2a:	c1 e0 03             	shl    $0x3,%eax
c0101a2d:	8d 90 84 76 1b c0    	lea    -0x3fe4897c(%eax),%edx
c0101a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101a36:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101a38:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a3c:	89 d0                	mov    %edx,%eax
c0101a3e:	c1 e0 03             	shl    $0x3,%eax
c0101a41:	29 d0                	sub    %edx,%eax
c0101a43:	c1 e0 03             	shl    $0x3,%eax
c0101a46:	8d 90 88 76 1b c0    	lea    -0x3fe48978(%eax),%edx
c0101a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101a4f:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101a51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a54:	83 c0 62             	add    $0x62,%eax
c0101a57:	0f b7 00             	movzwl (%eax),%eax
c0101a5a:	25 00 02 00 00       	and    $0x200,%eax
c0101a5f:	85 c0                	test   %eax,%eax
c0101a61:	75 24                	jne    c0101a87 <ide_init+0x1eb>
c0101a63:	c7 44 24 0c f4 cc 10 	movl   $0xc010ccf4,0xc(%esp)
c0101a6a:	c0 
c0101a6b:	c7 44 24 08 37 cd 10 	movl   $0xc010cd37,0x8(%esp)
c0101a72:	c0 
c0101a73:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101a7a:	00 
c0101a7b:	c7 04 24 4c cd 10 c0 	movl   $0xc010cd4c,(%esp)
c0101a82:	e8 69 f3 ff ff       	call   c0100df0 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a87:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a8b:	89 d0                	mov    %edx,%eax
c0101a8d:	c1 e0 03             	shl    $0x3,%eax
c0101a90:	29 d0                	sub    %edx,%eax
c0101a92:	c1 e0 03             	shl    $0x3,%eax
c0101a95:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c0101a9a:	83 c0 0c             	add    $0xc,%eax
c0101a9d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101aa3:	83 c0 36             	add    $0x36,%eax
c0101aa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101aa9:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101ab0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101ab7:	eb 34                	jmp    c0101aed <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101ab9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101abc:	8d 50 01             	lea    0x1(%eax),%edx
c0101abf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101ac2:	01 c2                	add    %eax,%edx
c0101ac4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101ac7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aca:	01 c8                	add    %ecx,%eax
c0101acc:	0f b6 12             	movzbl (%edx),%edx
c0101acf:	88 10                	mov    %dl,(%eax)
c0101ad1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ad7:	01 c2                	add    %eax,%edx
c0101ad9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101adc:	8d 48 01             	lea    0x1(%eax),%ecx
c0101adf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101ae2:	01 c8                	add    %ecx,%eax
c0101ae4:	0f b6 12             	movzbl (%edx),%edx
c0101ae7:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101ae9:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101af0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101af3:	72 c4                	jb     c0101ab9 <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101af5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101afb:	01 d0                	add    %edx,%eax
c0101afd:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101b00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b03:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101b06:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101b09:	85 c0                	test   %eax,%eax
c0101b0b:	74 0f                	je     c0101b1c <ide_init+0x280>
c0101b0d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101b10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b13:	01 d0                	add    %edx,%eax
c0101b15:	0f b6 00             	movzbl (%eax),%eax
c0101b18:	3c 20                	cmp    $0x20,%al
c0101b1a:	74 d9                	je     c0101af5 <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101b1c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b20:	89 d0                	mov    %edx,%eax
c0101b22:	c1 e0 03             	shl    $0x3,%eax
c0101b25:	29 d0                	sub    %edx,%eax
c0101b27:	c1 e0 03             	shl    $0x3,%eax
c0101b2a:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c0101b2f:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101b32:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b36:	89 d0                	mov    %edx,%eax
c0101b38:	c1 e0 03             	shl    $0x3,%eax
c0101b3b:	29 d0                	sub    %edx,%eax
c0101b3d:	c1 e0 03             	shl    $0x3,%eax
c0101b40:	05 88 76 1b c0       	add    $0xc01b7688,%eax
c0101b45:	8b 10                	mov    (%eax),%edx
c0101b47:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b4b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101b4f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b57:	c7 04 24 5e cd 10 c0 	movl   $0xc010cd5e,(%esp)
c0101b5e:	e8 0f e8 ff ff       	call   c0100372 <cprintf>
c0101b63:	eb 01                	jmp    c0101b66 <ide_init+0x2ca>
            continue ;
c0101b65:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101b66:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b6a:	40                   	inc    %eax
c0101b6b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b6f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b73:	83 f8 03             	cmp    $0x3,%eax
c0101b76:	0f 86 36 fd ff ff    	jbe    c01018b2 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b7c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b83:	e8 83 05 00 00       	call   c010210b <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b88:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b8f:	e8 77 05 00 00       	call   c010210b <pic_enable>
}
c0101b94:	90                   	nop
c0101b95:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b9b:	5b                   	pop    %ebx
c0101b9c:	5f                   	pop    %edi
c0101b9d:	5d                   	pop    %ebp
c0101b9e:	c3                   	ret    

c0101b9f <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b9f:	55                   	push   %ebp
c0101ba0:	89 e5                	mov    %esp,%ebp
c0101ba2:	83 ec 04             	sub    $0x4,%esp
c0101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101bac:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bb0:	83 f8 03             	cmp    $0x3,%eax
c0101bb3:	77 21                	ja     c0101bd6 <ide_device_valid+0x37>
c0101bb5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101bb9:	89 d0                	mov    %edx,%eax
c0101bbb:	c1 e0 03             	shl    $0x3,%eax
c0101bbe:	29 d0                	sub    %edx,%eax
c0101bc0:	c1 e0 03             	shl    $0x3,%eax
c0101bc3:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c0101bc8:	0f b6 00             	movzbl (%eax),%eax
c0101bcb:	84 c0                	test   %al,%al
c0101bcd:	74 07                	je     c0101bd6 <ide_device_valid+0x37>
c0101bcf:	b8 01 00 00 00       	mov    $0x1,%eax
c0101bd4:	eb 05                	jmp    c0101bdb <ide_device_valid+0x3c>
c0101bd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101bdb:	89 ec                	mov    %ebp,%esp
c0101bdd:	5d                   	pop    %ebp
c0101bde:	c3                   	ret    

c0101bdf <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101bdf:	55                   	push   %ebp
c0101be0:	89 e5                	mov    %esp,%ebp
c0101be2:	83 ec 08             	sub    $0x8,%esp
c0101be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101bec:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bf0:	89 04 24             	mov    %eax,(%esp)
c0101bf3:	e8 a7 ff ff ff       	call   c0101b9f <ide_device_valid>
c0101bf8:	85 c0                	test   %eax,%eax
c0101bfa:	74 17                	je     c0101c13 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101bfc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101c00:	89 d0                	mov    %edx,%eax
c0101c02:	c1 e0 03             	shl    $0x3,%eax
c0101c05:	29 d0                	sub    %edx,%eax
c0101c07:	c1 e0 03             	shl    $0x3,%eax
c0101c0a:	05 88 76 1b c0       	add    $0xc01b7688,%eax
c0101c0f:	8b 00                	mov    (%eax),%eax
c0101c11:	eb 05                	jmp    c0101c18 <ide_device_size+0x39>
    }
    return 0;
c0101c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101c18:	89 ec                	mov    %ebp,%esp
c0101c1a:	5d                   	pop    %ebp
c0101c1b:	c3                   	ret    

c0101c1c <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101c1c:	55                   	push   %ebp
c0101c1d:	89 e5                	mov    %esp,%ebp
c0101c1f:	57                   	push   %edi
c0101c20:	53                   	push   %ebx
c0101c21:	83 ec 50             	sub    $0x50,%esp
c0101c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c27:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101c2b:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101c32:	77 23                	ja     c0101c57 <ide_read_secs+0x3b>
c0101c34:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c38:	83 f8 03             	cmp    $0x3,%eax
c0101c3b:	77 1a                	ja     c0101c57 <ide_read_secs+0x3b>
c0101c3d:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101c41:	89 d0                	mov    %edx,%eax
c0101c43:	c1 e0 03             	shl    $0x3,%eax
c0101c46:	29 d0                	sub    %edx,%eax
c0101c48:	c1 e0 03             	shl    $0x3,%eax
c0101c4b:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c0101c50:	0f b6 00             	movzbl (%eax),%eax
c0101c53:	84 c0                	test   %al,%al
c0101c55:	75 24                	jne    c0101c7b <ide_read_secs+0x5f>
c0101c57:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c0101c5e:	c0 
c0101c5f:	c7 44 24 08 37 cd 10 	movl   $0xc010cd37,0x8(%esp)
c0101c66:	c0 
c0101c67:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101c6e:	00 
c0101c6f:	c7 04 24 4c cd 10 c0 	movl   $0xc010cd4c,(%esp)
c0101c76:	e8 75 f1 ff ff       	call   c0100df0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c7b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c82:	77 0f                	ja     c0101c93 <ide_read_secs+0x77>
c0101c84:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c87:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c8a:	01 d0                	add    %edx,%eax
c0101c8c:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c91:	76 24                	jbe    c0101cb7 <ide_read_secs+0x9b>
c0101c93:	c7 44 24 0c a4 cd 10 	movl   $0xc010cda4,0xc(%esp)
c0101c9a:	c0 
c0101c9b:	c7 44 24 08 37 cd 10 	movl   $0xc010cd37,0x8(%esp)
c0101ca2:	c0 
c0101ca3:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101caa:	00 
c0101cab:	c7 04 24 4c cd 10 c0 	movl   $0xc010cd4c,(%esp)
c0101cb2:	e8 39 f1 ff ff       	call   c0100df0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101cb7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101cbb:	d1 e8                	shr    %eax
c0101cbd:	0f b7 c0             	movzwl %ax,%eax
c0101cc0:	8b 04 85 ec cc 10 c0 	mov    -0x3fef3314(,%eax,4),%eax
c0101cc7:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ccb:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ccf:	d1 e8                	shr    %eax
c0101cd1:	0f b7 c0             	movzwl %ax,%eax
c0101cd4:	0f b7 04 85 ee cc 10 	movzwl -0x3fef3312(,%eax,4),%eax
c0101cdb:	c0 
c0101cdc:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101ce0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ce4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ceb:	00 
c0101cec:	89 04 24             	mov    %eax,(%esp)
c0101cef:	e8 4d fb ff ff       	call   c0101841 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cf7:	83 c0 02             	add    $0x2,%eax
c0101cfa:	0f b7 c0             	movzwl %ax,%eax
c0101cfd:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101d01:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d05:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d09:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d0d:	ee                   	out    %al,(%dx)
}
c0101d0e:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101d0f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d12:	0f b6 c0             	movzbl %al,%eax
c0101d15:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d19:	83 c2 02             	add    $0x2,%edx
c0101d1c:	0f b7 d2             	movzwl %dx,%edx
c0101d1f:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d23:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d26:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d2a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d2e:	ee                   	out    %al,(%dx)
}
c0101d2f:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101d30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d33:	0f b6 c0             	movzbl %al,%eax
c0101d36:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d3a:	83 c2 03             	add    $0x3,%edx
c0101d3d:	0f b7 d2             	movzwl %dx,%edx
c0101d40:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d44:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d47:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d4b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d4f:	ee                   	out    %al,(%dx)
}
c0101d50:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d54:	c1 e8 08             	shr    $0x8,%eax
c0101d57:	0f b6 c0             	movzbl %al,%eax
c0101d5a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d5e:	83 c2 04             	add    $0x4,%edx
c0101d61:	0f b7 d2             	movzwl %dx,%edx
c0101d64:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d68:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d6b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d6f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d73:	ee                   	out    %al,(%dx)
}
c0101d74:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d78:	c1 e8 10             	shr    $0x10,%eax
c0101d7b:	0f b6 c0             	movzbl %al,%eax
c0101d7e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d82:	83 c2 05             	add    $0x5,%edx
c0101d85:	0f b7 d2             	movzwl %dx,%edx
c0101d88:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101d8c:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d8f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101d93:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d97:	ee                   	out    %al,(%dx)
}
c0101d98:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d99:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101d9c:	c0 e0 04             	shl    $0x4,%al
c0101d9f:	24 10                	and    $0x10,%al
c0101da1:	88 c2                	mov    %al,%dl
c0101da3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101da6:	c1 e8 18             	shr    $0x18,%eax
c0101da9:	24 0f                	and    $0xf,%al
c0101dab:	08 d0                	or     %dl,%al
c0101dad:	0c e0                	or     $0xe0,%al
c0101daf:	0f b6 c0             	movzbl %al,%eax
c0101db2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101db6:	83 c2 06             	add    $0x6,%edx
c0101db9:	0f b7 d2             	movzwl %dx,%edx
c0101dbc:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101dc0:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101dc3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101dc7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101dcb:	ee                   	out    %al,(%dx)
}
c0101dcc:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101dcd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dd1:	83 c0 07             	add    $0x7,%eax
c0101dd4:	0f b7 c0             	movzwl %ax,%eax
c0101dd7:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ddb:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ddf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101de3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101de7:	ee                   	out    %al,(%dx)
}
c0101de8:	90                   	nop

    int ret = 0;
c0101de9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101df0:	eb 58                	jmp    c0101e4a <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101df2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101dfd:	00 
c0101dfe:	89 04 24             	mov    %eax,(%esp)
c0101e01:	e8 3b fa ff ff       	call   c0101841 <ide_wait_ready>
c0101e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101e0d:	75 43                	jne    c0101e52 <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101e0f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e13:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101e16:	8b 45 10             	mov    0x10(%ebp),%eax
c0101e19:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101e1c:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101e23:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101e26:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101e29:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101e2c:	89 cb                	mov    %ecx,%ebx
c0101e2e:	89 df                	mov    %ebx,%edi
c0101e30:	89 c1                	mov    %eax,%ecx
c0101e32:	fc                   	cld    
c0101e33:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101e35:	89 c8                	mov    %ecx,%eax
c0101e37:	89 fb                	mov    %edi,%ebx
c0101e39:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101e3c:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101e3f:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101e40:	ff 4d 14             	decl   0x14(%ebp)
c0101e43:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101e4a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e4e:	75 a2                	jne    c0101df2 <ide_read_secs+0x1d6>
    }

out:
c0101e50:	eb 01                	jmp    c0101e53 <ide_read_secs+0x237>
            goto out;
c0101e52:	90                   	nop
    return ret;
c0101e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e56:	83 c4 50             	add    $0x50,%esp
c0101e59:	5b                   	pop    %ebx
c0101e5a:	5f                   	pop    %edi
c0101e5b:	5d                   	pop    %ebp
c0101e5c:	c3                   	ret    

c0101e5d <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101e5d:	55                   	push   %ebp
c0101e5e:	89 e5                	mov    %esp,%ebp
c0101e60:	56                   	push   %esi
c0101e61:	53                   	push   %ebx
c0101e62:	83 ec 50             	sub    $0x50,%esp
c0101e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e68:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101e6c:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e73:	77 23                	ja     c0101e98 <ide_write_secs+0x3b>
c0101e75:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e79:	83 f8 03             	cmp    $0x3,%eax
c0101e7c:	77 1a                	ja     c0101e98 <ide_write_secs+0x3b>
c0101e7e:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101e82:	89 d0                	mov    %edx,%eax
c0101e84:	c1 e0 03             	shl    $0x3,%eax
c0101e87:	29 d0                	sub    %edx,%eax
c0101e89:	c1 e0 03             	shl    $0x3,%eax
c0101e8c:	05 80 76 1b c0       	add    $0xc01b7680,%eax
c0101e91:	0f b6 00             	movzbl (%eax),%eax
c0101e94:	84 c0                	test   %al,%al
c0101e96:	75 24                	jne    c0101ebc <ide_write_secs+0x5f>
c0101e98:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c0101e9f:	c0 
c0101ea0:	c7 44 24 08 37 cd 10 	movl   $0xc010cd37,0x8(%esp)
c0101ea7:	c0 
c0101ea8:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101eaf:	00 
c0101eb0:	c7 04 24 4c cd 10 c0 	movl   $0xc010cd4c,(%esp)
c0101eb7:	e8 34 ef ff ff       	call   c0100df0 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101ebc:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101ec3:	77 0f                	ja     c0101ed4 <ide_write_secs+0x77>
c0101ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101ec8:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ecb:	01 d0                	add    %edx,%eax
c0101ecd:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101ed2:	76 24                	jbe    c0101ef8 <ide_write_secs+0x9b>
c0101ed4:	c7 44 24 0c a4 cd 10 	movl   $0xc010cda4,0xc(%esp)
c0101edb:	c0 
c0101edc:	c7 44 24 08 37 cd 10 	movl   $0xc010cd37,0x8(%esp)
c0101ee3:	c0 
c0101ee4:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101eeb:	00 
c0101eec:	c7 04 24 4c cd 10 c0 	movl   $0xc010cd4c,(%esp)
c0101ef3:	e8 f8 ee ff ff       	call   c0100df0 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ef8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101efc:	d1 e8                	shr    %eax
c0101efe:	0f b7 c0             	movzwl %ax,%eax
c0101f01:	8b 04 85 ec cc 10 c0 	mov    -0x3fef3314(,%eax,4),%eax
c0101f08:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101f0c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f10:	d1 e8                	shr    %eax
c0101f12:	0f b7 c0             	movzwl %ax,%eax
c0101f15:	0f b7 04 85 ee cc 10 	movzwl -0x3fef3312(,%eax,4),%eax
c0101f1c:	c0 
c0101f1d:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101f21:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f25:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101f2c:	00 
c0101f2d:	89 04 24             	mov    %eax,(%esp)
c0101f30:	e8 0c f9 ff ff       	call   c0101841 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f38:	83 c0 02             	add    $0x2,%eax
c0101f3b:	0f b7 c0             	movzwl %ax,%eax
c0101f3e:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101f42:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f46:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101f4a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101f4e:	ee                   	out    %al,(%dx)
}
c0101f4f:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101f50:	8b 45 14             	mov    0x14(%ebp),%eax
c0101f53:	0f b6 c0             	movzbl %al,%eax
c0101f56:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f5a:	83 c2 02             	add    $0x2,%edx
c0101f5d:	0f b7 d2             	movzwl %dx,%edx
c0101f60:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101f64:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f67:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f6b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101f6f:	ee                   	out    %al,(%dx)
}
c0101f70:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f74:	0f b6 c0             	movzbl %al,%eax
c0101f77:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f7b:	83 c2 03             	add    $0x3,%edx
c0101f7e:	0f b7 d2             	movzwl %dx,%edx
c0101f81:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f85:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f88:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f8c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f90:	ee                   	out    %al,(%dx)
}
c0101f91:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f92:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f95:	c1 e8 08             	shr    $0x8,%eax
c0101f98:	0f b6 c0             	movzbl %al,%eax
c0101f9b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f9f:	83 c2 04             	add    $0x4,%edx
c0101fa2:	0f b7 d2             	movzwl %dx,%edx
c0101fa5:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101fa9:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fac:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101fb0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101fb4:	ee                   	out    %al,(%dx)
}
c0101fb5:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fb9:	c1 e8 10             	shr    $0x10,%eax
c0101fbc:	0f b6 c0             	movzbl %al,%eax
c0101fbf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101fc3:	83 c2 05             	add    $0x5,%edx
c0101fc6:	0f b7 d2             	movzwl %dx,%edx
c0101fc9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101fcd:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fd0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101fd4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101fd8:	ee                   	out    %al,(%dx)
}
c0101fd9:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101fda:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101fdd:	c0 e0 04             	shl    $0x4,%al
c0101fe0:	24 10                	and    $0x10,%al
c0101fe2:	88 c2                	mov    %al,%dl
c0101fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fe7:	c1 e8 18             	shr    $0x18,%eax
c0101fea:	24 0f                	and    $0xf,%al
c0101fec:	08 d0                	or     %dl,%al
c0101fee:	0c e0                	or     $0xe0,%al
c0101ff0:	0f b6 c0             	movzbl %al,%eax
c0101ff3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ff7:	83 c2 06             	add    $0x6,%edx
c0101ffa:	0f b7 d2             	movzwl %dx,%edx
c0101ffd:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0102001:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102004:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102008:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010200c:	ee                   	out    %al,(%dx)
}
c010200d:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010200e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102012:	83 c0 07             	add    $0x7,%eax
c0102015:	0f b7 c0             	movzwl %ax,%eax
c0102018:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010201c:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102020:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102024:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102028:	ee                   	out    %al,(%dx)
}
c0102029:	90                   	nop

    int ret = 0;
c010202a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102031:	eb 58                	jmp    c010208b <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0102033:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102037:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010203e:	00 
c010203f:	89 04 24             	mov    %eax,(%esp)
c0102042:	e8 fa f7 ff ff       	call   c0101841 <ide_wait_ready>
c0102047:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010204a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010204e:	75 43                	jne    c0102093 <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0102050:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102054:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102057:	8b 45 10             	mov    0x10(%ebp),%eax
c010205a:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010205d:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0102064:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102067:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010206a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010206d:	89 cb                	mov    %ecx,%ebx
c010206f:	89 de                	mov    %ebx,%esi
c0102071:	89 c1                	mov    %eax,%ecx
c0102073:	fc                   	cld    
c0102074:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102076:	89 c8                	mov    %ecx,%eax
c0102078:	89 f3                	mov    %esi,%ebx
c010207a:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010207d:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0102080:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0102081:	ff 4d 14             	decl   0x14(%ebp)
c0102084:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010208b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010208f:	75 a2                	jne    c0102033 <ide_write_secs+0x1d6>
    }

out:
c0102091:	eb 01                	jmp    c0102094 <ide_write_secs+0x237>
            goto out;
c0102093:	90                   	nop
    return ret;
c0102094:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102097:	83 c4 50             	add    $0x50,%esp
c010209a:	5b                   	pop    %ebx
c010209b:	5e                   	pop    %esi
c010209c:	5d                   	pop    %ebp
c010209d:	c3                   	ret    

c010209e <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010209e:	55                   	push   %ebp
c010209f:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c01020a1:	fb                   	sti    
}
c01020a2:	90                   	nop
    sti();
}
c01020a3:	90                   	nop
c01020a4:	5d                   	pop    %ebp
c01020a5:	c3                   	ret    

c01020a6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020a6:	55                   	push   %ebp
c01020a7:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01020a9:	fa                   	cli    
}
c01020aa:	90                   	nop
    cli();
}
c01020ab:	90                   	nop
c01020ac:	5d                   	pop    %ebp
c01020ad:	c3                   	ret    

c01020ae <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01020ae:	55                   	push   %ebp
c01020af:	89 e5                	mov    %esp,%ebp
c01020b1:	83 ec 14             	sub    $0x14,%esp
c01020b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01020bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01020be:	66 a3 50 35 13 c0    	mov    %ax,0xc0133550
    if (did_init) {
c01020c4:	a1 60 77 1b c0       	mov    0xc01b7760,%eax
c01020c9:	85 c0                	test   %eax,%eax
c01020cb:	74 39                	je     c0102106 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c01020cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01020d0:	0f b6 c0             	movzbl %al,%eax
c01020d3:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01020d9:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020dc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020e0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020e4:	ee                   	out    %al,(%dx)
}
c01020e5:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01020e6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01020ea:	c1 e8 08             	shr    $0x8,%eax
c01020ed:	0f b7 c0             	movzwl %ax,%eax
c01020f0:	0f b6 c0             	movzbl %al,%eax
c01020f3:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01020f9:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102100:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102104:	ee                   	out    %al,(%dx)
}
c0102105:	90                   	nop
    }
}
c0102106:	90                   	nop
c0102107:	89 ec                	mov    %ebp,%esp
c0102109:	5d                   	pop    %ebp
c010210a:	c3                   	ret    

c010210b <pic_enable>:

void
pic_enable(unsigned int irq) {
c010210b:	55                   	push   %ebp
c010210c:	89 e5                	mov    %esp,%ebp
c010210e:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102111:	8b 45 08             	mov    0x8(%ebp),%eax
c0102114:	ba 01 00 00 00       	mov    $0x1,%edx
c0102119:	88 c1                	mov    %al,%cl
c010211b:	d3 e2                	shl    %cl,%edx
c010211d:	89 d0                	mov    %edx,%eax
c010211f:	98                   	cwtl   
c0102120:	f7 d0                	not    %eax
c0102122:	0f bf d0             	movswl %ax,%edx
c0102125:	0f b7 05 50 35 13 c0 	movzwl 0xc0133550,%eax
c010212c:	98                   	cwtl   
c010212d:	21 d0                	and    %edx,%eax
c010212f:	98                   	cwtl   
c0102130:	0f b7 c0             	movzwl %ax,%eax
c0102133:	89 04 24             	mov    %eax,(%esp)
c0102136:	e8 73 ff ff ff       	call   c01020ae <pic_setmask>
}
c010213b:	90                   	nop
c010213c:	89 ec                	mov    %ebp,%esp
c010213e:	5d                   	pop    %ebp
c010213f:	c3                   	ret    

c0102140 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0102140:	55                   	push   %ebp
c0102141:	89 e5                	mov    %esp,%ebp
c0102143:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0102146:	c7 05 60 77 1b c0 01 	movl   $0x1,0xc01b7760
c010214d:	00 00 00 
c0102150:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102156:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010215a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010215e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102162:	ee                   	out    %al,(%dx)
}
c0102163:	90                   	nop
c0102164:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010216a:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010216e:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102172:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102176:	ee                   	out    %al,(%dx)
}
c0102177:	90                   	nop
c0102178:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010217e:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102182:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102186:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010218a:	ee                   	out    %al,(%dx)
}
c010218b:	90                   	nop
c010218c:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0102192:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102196:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010219a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010219e:	ee                   	out    %al,(%dx)
}
c010219f:	90                   	nop
c01021a0:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01021a6:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021aa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021ae:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021b2:	ee                   	out    %al,(%dx)
}
c01021b3:	90                   	nop
c01021b4:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01021ba:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021be:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01021c2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01021c6:	ee                   	out    %al,(%dx)
}
c01021c7:	90                   	nop
c01021c8:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01021ce:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021d2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01021d6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01021da:	ee                   	out    %al,(%dx)
}
c01021db:	90                   	nop
c01021dc:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01021e2:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021e6:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01021ea:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01021ee:	ee                   	out    %al,(%dx)
}
c01021ef:	90                   	nop
c01021f0:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01021f6:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021fa:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01021fe:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102202:	ee                   	out    %al,(%dx)
}
c0102203:	90                   	nop
c0102204:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010220a:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010220e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102212:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102216:	ee                   	out    %al,(%dx)
}
c0102217:	90                   	nop
c0102218:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010221e:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102222:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102226:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010222a:	ee                   	out    %al,(%dx)
}
c010222b:	90                   	nop
c010222c:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102232:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102236:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010223a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010223e:	ee                   	out    %al,(%dx)
}
c010223f:	90                   	nop
c0102240:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102246:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010224a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010224e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102252:	ee                   	out    %al,(%dx)
}
c0102253:	90                   	nop
c0102254:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010225a:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010225e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102262:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102266:	ee                   	out    %al,(%dx)
}
c0102267:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102268:	0f b7 05 50 35 13 c0 	movzwl 0xc0133550,%eax
c010226f:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0102274:	74 0f                	je     c0102285 <pic_init+0x145>
        pic_setmask(irq_mask);
c0102276:	0f b7 05 50 35 13 c0 	movzwl 0xc0133550,%eax
c010227d:	89 04 24             	mov    %eax,(%esp)
c0102280:	e8 29 fe ff ff       	call   c01020ae <pic_setmask>
    }
}
c0102285:	90                   	nop
c0102286:	89 ec                	mov    %ebp,%esp
c0102288:	5d                   	pop    %ebp
c0102289:	c3                   	ret    

c010228a <print_ticks>:
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
c010228a:	55                   	push   %ebp
c010228b:	89 e5                	mov    %esp,%ebp
c010228d:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102290:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102297:	00 
c0102298:	c7 04 24 e0 cd 10 c0 	movl   $0xc010cde0,(%esp)
c010229f:	e8 ce e0 ff ff       	call   c0100372 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01022a4:	90                   	nop
c01022a5:	89 ec                	mov    %ebp,%esp
c01022a7:	5d                   	pop    %ebp
c01022a8:	c3                   	ret    

c01022a9 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01022a9:	55                   	push   %ebp
c01022aa:	89 e5                	mov    %esp,%ebp
c01022ac:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
     extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++)
c01022af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01022b6:	e9 c4 00 00 00       	jmp    c010237f <idt_init+0xd6>
        // 目标idt项为idt[i]
        // 该idt项为内核代码，所以使用GD_KTEXT段选择子
        // 中断处理程序的入口地址存放于__vectors[i]
        // 特权级为DPL_KERNEL
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01022bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022be:	8b 04 85 e0 35 13 c0 	mov    -0x3fecca20(,%eax,4),%eax
c01022c5:	0f b7 d0             	movzwl %ax,%edx
c01022c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cb:	66 89 14 c5 80 77 1b 	mov    %dx,-0x3fe48880(,%eax,8)
c01022d2:	c0 
c01022d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d6:	66 c7 04 c5 82 77 1b 	movw   $0x8,-0x3fe4887e(,%eax,8)
c01022dd:	c0 08 00 
c01022e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022e3:	0f b6 14 c5 84 77 1b 	movzbl -0x3fe4887c(,%eax,8),%edx
c01022ea:	c0 
c01022eb:	80 e2 e0             	and    $0xe0,%dl
c01022ee:	88 14 c5 84 77 1b c0 	mov    %dl,-0x3fe4887c(,%eax,8)
c01022f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f8:	0f b6 14 c5 84 77 1b 	movzbl -0x3fe4887c(,%eax,8),%edx
c01022ff:	c0 
c0102300:	80 e2 1f             	and    $0x1f,%dl
c0102303:	88 14 c5 84 77 1b c0 	mov    %dl,-0x3fe4887c(,%eax,8)
c010230a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010230d:	0f b6 14 c5 85 77 1b 	movzbl -0x3fe4887b(,%eax,8),%edx
c0102314:	c0 
c0102315:	80 e2 f0             	and    $0xf0,%dl
c0102318:	80 ca 0e             	or     $0xe,%dl
c010231b:	88 14 c5 85 77 1b c0 	mov    %dl,-0x3fe4887b(,%eax,8)
c0102322:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102325:	0f b6 14 c5 85 77 1b 	movzbl -0x3fe4887b(,%eax,8),%edx
c010232c:	c0 
c010232d:	80 e2 ef             	and    $0xef,%dl
c0102330:	88 14 c5 85 77 1b c0 	mov    %dl,-0x3fe4887b(,%eax,8)
c0102337:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010233a:	0f b6 14 c5 85 77 1b 	movzbl -0x3fe4887b(,%eax,8),%edx
c0102341:	c0 
c0102342:	80 e2 9f             	and    $0x9f,%dl
c0102345:	88 14 c5 85 77 1b c0 	mov    %dl,-0x3fe4887b(,%eax,8)
c010234c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010234f:	0f b6 14 c5 85 77 1b 	movzbl -0x3fe4887b(,%eax,8),%edx
c0102356:	c0 
c0102357:	80 ca 80             	or     $0x80,%dl
c010235a:	88 14 c5 85 77 1b c0 	mov    %dl,-0x3fe4887b(,%eax,8)
c0102361:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102364:	8b 04 85 e0 35 13 c0 	mov    -0x3fecca20(,%eax,4),%eax
c010236b:	c1 e8 10             	shr    $0x10,%eax
c010236e:	0f b7 d0             	movzwl %ax,%edx
c0102371:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102374:	66 89 14 c5 86 77 1b 	mov    %dx,-0x3fe4887a(,%eax,8)
c010237b:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++)
c010237c:	ff 45 fc             	incl   -0x4(%ebp)
c010237f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102382:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102387:	0f 86 2e ff ff ff    	jbe    c01022bb <idt_init+0x12>
	// 设置从用户态转为内核态的中断的特权级为DPL_USER
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010238d:	a1 c4 37 13 c0       	mov    0xc01337c4,%eax
c0102392:	0f b7 c0             	movzwl %ax,%eax
c0102395:	66 a3 48 7b 1b c0    	mov    %ax,0xc01b7b48
c010239b:	66 c7 05 4a 7b 1b c0 	movw   $0x8,0xc01b7b4a
c01023a2:	08 00 
c01023a4:	0f b6 05 4c 7b 1b c0 	movzbl 0xc01b7b4c,%eax
c01023ab:	24 e0                	and    $0xe0,%al
c01023ad:	a2 4c 7b 1b c0       	mov    %al,0xc01b7b4c
c01023b2:	0f b6 05 4c 7b 1b c0 	movzbl 0xc01b7b4c,%eax
c01023b9:	24 1f                	and    $0x1f,%al
c01023bb:	a2 4c 7b 1b c0       	mov    %al,0xc01b7b4c
c01023c0:	0f b6 05 4d 7b 1b c0 	movzbl 0xc01b7b4d,%eax
c01023c7:	24 f0                	and    $0xf0,%al
c01023c9:	0c 0e                	or     $0xe,%al
c01023cb:	a2 4d 7b 1b c0       	mov    %al,0xc01b7b4d
c01023d0:	0f b6 05 4d 7b 1b c0 	movzbl 0xc01b7b4d,%eax
c01023d7:	24 ef                	and    $0xef,%al
c01023d9:	a2 4d 7b 1b c0       	mov    %al,0xc01b7b4d
c01023de:	0f b6 05 4d 7b 1b c0 	movzbl 0xc01b7b4d,%eax
c01023e5:	0c 60                	or     $0x60,%al
c01023e7:	a2 4d 7b 1b c0       	mov    %al,0xc01b7b4d
c01023ec:	0f b6 05 4d 7b 1b c0 	movzbl 0xc01b7b4d,%eax
c01023f3:	0c 80                	or     $0x80,%al
c01023f5:	a2 4d 7b 1b c0       	mov    %al,0xc01b7b4d
c01023fa:	a1 c4 37 13 c0       	mov    0xc01337c4,%eax
c01023ff:	c1 e8 10             	shr    $0x10,%eax
c0102402:	0f b7 c0             	movzwl %ax,%eax
c0102405:	66 a3 4e 7b 1b c0    	mov    %ax,0xc01b7b4e
    // Lab5 code
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c010240b:	a1 e0 37 13 c0       	mov    0xc01337e0,%eax
c0102410:	0f b7 c0             	movzwl %ax,%eax
c0102413:	66 a3 80 7b 1b c0    	mov    %ax,0xc01b7b80
c0102419:	66 c7 05 82 7b 1b c0 	movw   $0x8,0xc01b7b82
c0102420:	08 00 
c0102422:	0f b6 05 84 7b 1b c0 	movzbl 0xc01b7b84,%eax
c0102429:	24 e0                	and    $0xe0,%al
c010242b:	a2 84 7b 1b c0       	mov    %al,0xc01b7b84
c0102430:	0f b6 05 84 7b 1b c0 	movzbl 0xc01b7b84,%eax
c0102437:	24 1f                	and    $0x1f,%al
c0102439:	a2 84 7b 1b c0       	mov    %al,0xc01b7b84
c010243e:	0f b6 05 85 7b 1b c0 	movzbl 0xc01b7b85,%eax
c0102445:	0c 0f                	or     $0xf,%al
c0102447:	a2 85 7b 1b c0       	mov    %al,0xc01b7b85
c010244c:	0f b6 05 85 7b 1b c0 	movzbl 0xc01b7b85,%eax
c0102453:	24 ef                	and    $0xef,%al
c0102455:	a2 85 7b 1b c0       	mov    %al,0xc01b7b85
c010245a:	0f b6 05 85 7b 1b c0 	movzbl 0xc01b7b85,%eax
c0102461:	0c 60                	or     $0x60,%al
c0102463:	a2 85 7b 1b c0       	mov    %al,0xc01b7b85
c0102468:	0f b6 05 85 7b 1b c0 	movzbl 0xc01b7b85,%eax
c010246f:	0c 80                	or     $0x80,%al
c0102471:	a2 85 7b 1b c0       	mov    %al,0xc01b7b85
c0102476:	a1 e0 37 13 c0       	mov    0xc01337e0,%eax
c010247b:	c1 e8 10             	shr    $0x10,%eax
c010247e:	0f b7 c0             	movzwl %ax,%eax
c0102481:	66 a3 86 7b 1b c0    	mov    %ax,0xc01b7b86
c0102487:	c7 45 f8 60 35 13 c0 	movl   $0xc0133560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010248e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102491:	0f 01 18             	lidtl  (%eax)
}
c0102494:	90                   	nop
    // 加载该IDT
    lidt(&idt_pd); 
}
c0102495:	90                   	nop
c0102496:	89 ec                	mov    %ebp,%esp
c0102498:	5d                   	pop    %ebp
c0102499:	c3                   	ret    

c010249a <trapname>:

static const char *
trapname(int trapno) {
c010249a:	55                   	push   %ebp
c010249b:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010249d:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a0:	83 f8 13             	cmp    $0x13,%eax
c01024a3:	77 0c                	ja     c01024b1 <trapname+0x17>
        return excnames[trapno];
c01024a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a8:	8b 04 85 00 d3 10 c0 	mov    -0x3fef2d00(,%eax,4),%eax
c01024af:	eb 18                	jmp    c01024c9 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01024b1:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01024b5:	7e 0d                	jle    c01024c4 <trapname+0x2a>
c01024b7:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01024bb:	7f 07                	jg     c01024c4 <trapname+0x2a>
        return "Hardware Interrupt";
c01024bd:	b8 ea cd 10 c0       	mov    $0xc010cdea,%eax
c01024c2:	eb 05                	jmp    c01024c9 <trapname+0x2f>
    }
    return "(unknown trap)";
c01024c4:	b8 fd cd 10 c0       	mov    $0xc010cdfd,%eax
}
c01024c9:	5d                   	pop    %ebp
c01024ca:	c3                   	ret    

c01024cb <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01024cb:	55                   	push   %ebp
c01024cc:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01024ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024d5:	83 f8 08             	cmp    $0x8,%eax
c01024d8:	0f 94 c0             	sete   %al
c01024db:	0f b6 c0             	movzbl %al,%eax
}
c01024de:	5d                   	pop    %ebp
c01024df:	c3                   	ret    

c01024e0 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01024e0:	55                   	push   %ebp
c01024e1:	89 e5                	mov    %esp,%ebp
c01024e3:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01024e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ed:	c7 04 24 3e ce 10 c0 	movl   $0xc010ce3e,(%esp)
c01024f4:	e8 79 de ff ff       	call   c0100372 <cprintf>
    print_regs(&tf->tf_regs);
c01024f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fc:	89 04 24             	mov    %eax,(%esp)
c01024ff:	e8 8f 01 00 00       	call   c0102693 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102504:	8b 45 08             	mov    0x8(%ebp),%eax
c0102507:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010250b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250f:	c7 04 24 4f ce 10 c0 	movl   $0xc010ce4f,(%esp)
c0102516:	e8 57 de ff ff       	call   c0100372 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010251b:	8b 45 08             	mov    0x8(%ebp),%eax
c010251e:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102522:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102526:	c7 04 24 62 ce 10 c0 	movl   $0xc010ce62,(%esp)
c010252d:	e8 40 de ff ff       	call   c0100372 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102532:	8b 45 08             	mov    0x8(%ebp),%eax
c0102535:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102539:	89 44 24 04          	mov    %eax,0x4(%esp)
c010253d:	c7 04 24 75 ce 10 c0 	movl   $0xc010ce75,(%esp)
c0102544:	e8 29 de ff ff       	call   c0100372 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102549:	8b 45 08             	mov    0x8(%ebp),%eax
c010254c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102550:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102554:	c7 04 24 88 ce 10 c0 	movl   $0xc010ce88,(%esp)
c010255b:	e8 12 de ff ff       	call   c0100372 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102560:	8b 45 08             	mov    0x8(%ebp),%eax
c0102563:	8b 40 30             	mov    0x30(%eax),%eax
c0102566:	89 04 24             	mov    %eax,(%esp)
c0102569:	e8 2c ff ff ff       	call   c010249a <trapname>
c010256e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102571:	8b 52 30             	mov    0x30(%edx),%edx
c0102574:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102578:	89 54 24 04          	mov    %edx,0x4(%esp)
c010257c:	c7 04 24 9b ce 10 c0 	movl   $0xc010ce9b,(%esp)
c0102583:	e8 ea dd ff ff       	call   c0100372 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102588:	8b 45 08             	mov    0x8(%ebp),%eax
c010258b:	8b 40 34             	mov    0x34(%eax),%eax
c010258e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102592:	c7 04 24 ad ce 10 c0 	movl   $0xc010cead,(%esp)
c0102599:	e8 d4 dd ff ff       	call   c0100372 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010259e:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a1:	8b 40 38             	mov    0x38(%eax),%eax
c01025a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a8:	c7 04 24 bc ce 10 c0 	movl   $0xc010cebc,(%esp)
c01025af:	e8 be dd ff ff       	call   c0100372 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01025b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01025bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025bf:	c7 04 24 cb ce 10 c0 	movl   $0xc010cecb,(%esp)
c01025c6:	e8 a7 dd ff ff       	call   c0100372 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01025cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ce:	8b 40 40             	mov    0x40(%eax),%eax
c01025d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d5:	c7 04 24 de ce 10 c0 	movl   $0xc010cede,(%esp)
c01025dc:	e8 91 dd ff ff       	call   c0100372 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01025e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01025e8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01025ef:	eb 3d                	jmp    c010262e <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01025f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f4:	8b 50 40             	mov    0x40(%eax),%edx
c01025f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01025fa:	21 d0                	and    %edx,%eax
c01025fc:	85 c0                	test   %eax,%eax
c01025fe:	74 28                	je     c0102628 <print_trapframe+0x148>
c0102600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102603:	8b 04 85 80 35 13 c0 	mov    -0x3fecca80(,%eax,4),%eax
c010260a:	85 c0                	test   %eax,%eax
c010260c:	74 1a                	je     c0102628 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c010260e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102611:	8b 04 85 80 35 13 c0 	mov    -0x3fecca80(,%eax,4),%eax
c0102618:	89 44 24 04          	mov    %eax,0x4(%esp)
c010261c:	c7 04 24 ed ce 10 c0 	movl   $0xc010ceed,(%esp)
c0102623:	e8 4a dd ff ff       	call   c0100372 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102628:	ff 45 f4             	incl   -0xc(%ebp)
c010262b:	d1 65 f0             	shll   -0x10(%ebp)
c010262e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102631:	83 f8 17             	cmp    $0x17,%eax
c0102634:	76 bb                	jbe    c01025f1 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102636:	8b 45 08             	mov    0x8(%ebp),%eax
c0102639:	8b 40 40             	mov    0x40(%eax),%eax
c010263c:	c1 e8 0c             	shr    $0xc,%eax
c010263f:	83 e0 03             	and    $0x3,%eax
c0102642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102646:	c7 04 24 f1 ce 10 c0 	movl   $0xc010cef1,(%esp)
c010264d:	e8 20 dd ff ff       	call   c0100372 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102652:	8b 45 08             	mov    0x8(%ebp),%eax
c0102655:	89 04 24             	mov    %eax,(%esp)
c0102658:	e8 6e fe ff ff       	call   c01024cb <trap_in_kernel>
c010265d:	85 c0                	test   %eax,%eax
c010265f:	75 2d                	jne    c010268e <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102661:	8b 45 08             	mov    0x8(%ebp),%eax
c0102664:	8b 40 44             	mov    0x44(%eax),%eax
c0102667:	89 44 24 04          	mov    %eax,0x4(%esp)
c010266b:	c7 04 24 fa ce 10 c0 	movl   $0xc010cefa,(%esp)
c0102672:	e8 fb dc ff ff       	call   c0100372 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102677:	8b 45 08             	mov    0x8(%ebp),%eax
c010267a:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010267e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102682:	c7 04 24 09 cf 10 c0 	movl   $0xc010cf09,(%esp)
c0102689:	e8 e4 dc ff ff       	call   c0100372 <cprintf>
    }
}
c010268e:	90                   	nop
c010268f:	89 ec                	mov    %ebp,%esp
c0102691:	5d                   	pop    %ebp
c0102692:	c3                   	ret    

c0102693 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102693:	55                   	push   %ebp
c0102694:	89 e5                	mov    %esp,%ebp
c0102696:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102699:	8b 45 08             	mov    0x8(%ebp),%eax
c010269c:	8b 00                	mov    (%eax),%eax
c010269e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026a2:	c7 04 24 1c cf 10 c0 	movl   $0xc010cf1c,(%esp)
c01026a9:	e8 c4 dc ff ff       	call   c0100372 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01026ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b1:	8b 40 04             	mov    0x4(%eax),%eax
c01026b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026b8:	c7 04 24 2b cf 10 c0 	movl   $0xc010cf2b,(%esp)
c01026bf:	e8 ae dc ff ff       	call   c0100372 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01026c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c7:	8b 40 08             	mov    0x8(%eax),%eax
c01026ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026ce:	c7 04 24 3a cf 10 c0 	movl   $0xc010cf3a,(%esp)
c01026d5:	e8 98 dc ff ff       	call   c0100372 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01026da:	8b 45 08             	mov    0x8(%ebp),%eax
c01026dd:	8b 40 0c             	mov    0xc(%eax),%eax
c01026e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026e4:	c7 04 24 49 cf 10 c0 	movl   $0xc010cf49,(%esp)
c01026eb:	e8 82 dc ff ff       	call   c0100372 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01026f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f3:	8b 40 10             	mov    0x10(%eax),%eax
c01026f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026fa:	c7 04 24 58 cf 10 c0 	movl   $0xc010cf58,(%esp)
c0102701:	e8 6c dc ff ff       	call   c0100372 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102706:	8b 45 08             	mov    0x8(%ebp),%eax
c0102709:	8b 40 14             	mov    0x14(%eax),%eax
c010270c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102710:	c7 04 24 67 cf 10 c0 	movl   $0xc010cf67,(%esp)
c0102717:	e8 56 dc ff ff       	call   c0100372 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010271c:	8b 45 08             	mov    0x8(%ebp),%eax
c010271f:	8b 40 18             	mov    0x18(%eax),%eax
c0102722:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102726:	c7 04 24 76 cf 10 c0 	movl   $0xc010cf76,(%esp)
c010272d:	e8 40 dc ff ff       	call   c0100372 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102732:	8b 45 08             	mov    0x8(%ebp),%eax
c0102735:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102738:	89 44 24 04          	mov    %eax,0x4(%esp)
c010273c:	c7 04 24 85 cf 10 c0 	movl   $0xc010cf85,(%esp)
c0102743:	e8 2a dc ff ff       	call   c0100372 <cprintf>
}
c0102748:	90                   	nop
c0102749:	89 ec                	mov    %ebp,%esp
c010274b:	5d                   	pop    %ebp
c010274c:	c3                   	ret    

c010274d <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010274d:	55                   	push   %ebp
c010274e:	89 e5                	mov    %esp,%ebp
c0102750:	83 ec 38             	sub    $0x38,%esp
c0102753:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102756:	8b 45 08             	mov    0x8(%ebp),%eax
c0102759:	8b 40 34             	mov    0x34(%eax),%eax
c010275c:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010275f:	85 c0                	test   %eax,%eax
c0102761:	74 07                	je     c010276a <print_pgfault+0x1d>
c0102763:	bb 94 cf 10 c0       	mov    $0xc010cf94,%ebx
c0102768:	eb 05                	jmp    c010276f <print_pgfault+0x22>
c010276a:	bb a5 cf 10 c0       	mov    $0xc010cfa5,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010276f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102772:	8b 40 34             	mov    0x34(%eax),%eax
c0102775:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102778:	85 c0                	test   %eax,%eax
c010277a:	74 07                	je     c0102783 <print_pgfault+0x36>
c010277c:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102781:	eb 05                	jmp    c0102788 <print_pgfault+0x3b>
c0102783:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102788:	8b 45 08             	mov    0x8(%ebp),%eax
c010278b:	8b 40 34             	mov    0x34(%eax),%eax
c010278e:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102791:	85 c0                	test   %eax,%eax
c0102793:	74 07                	je     c010279c <print_pgfault+0x4f>
c0102795:	ba 55 00 00 00       	mov    $0x55,%edx
c010279a:	eb 05                	jmp    c01027a1 <print_pgfault+0x54>
c010279c:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027a1:	0f 20 d0             	mov    %cr2,%eax
c01027a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01027a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027aa:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c01027ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01027b2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027ba:	c7 04 24 b4 cf 10 c0 	movl   $0xc010cfb4,(%esp)
c01027c1:	e8 ac db ff ff       	call   c0100372 <cprintf>
}
c01027c6:	90                   	nop
c01027c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01027ca:	89 ec                	mov    %ebp,%esp
c01027cc:	5d                   	pop    %ebp
c01027cd:	c3                   	ret    

c01027ce <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01027ce:	55                   	push   %ebp
c01027cf:	89 e5                	mov    %esp,%ebp
c01027d1:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01027d4:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01027d9:	85 c0                	test   %eax,%eax
c01027db:	74 0b                	je     c01027e8 <pgfault_handler+0x1a>
            print_pgfault(tf);
c01027dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e0:	89 04 24             	mov    %eax,(%esp)
c01027e3:	e8 65 ff ff ff       	call   c010274d <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01027e8:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01027ed:	85 c0                	test   %eax,%eax
c01027ef:	74 3d                	je     c010282e <pgfault_handler+0x60>
        assert(current == idleproc);
c01027f1:	8b 15 30 81 1b c0    	mov    0xc01b8130,%edx
c01027f7:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c01027fc:	39 c2                	cmp    %eax,%edx
c01027fe:	74 24                	je     c0102824 <pgfault_handler+0x56>
c0102800:	c7 44 24 0c d7 cf 10 	movl   $0xc010cfd7,0xc(%esp)
c0102807:	c0 
c0102808:	c7 44 24 08 eb cf 10 	movl   $0xc010cfeb,0x8(%esp)
c010280f:	c0 
c0102810:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102817:	00 
c0102818:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c010281f:	e8 cc e5 ff ff       	call   c0100df0 <__panic>
        mm = check_mm_struct;
c0102824:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c0102829:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010282c:	eb 46                	jmp    c0102874 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010282e:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102833:	85 c0                	test   %eax,%eax
c0102835:	75 32                	jne    c0102869 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102837:	8b 45 08             	mov    0x8(%ebp),%eax
c010283a:	89 04 24             	mov    %eax,(%esp)
c010283d:	e8 9e fc ff ff       	call   c01024e0 <print_trapframe>
            print_pgfault(tf);
c0102842:	8b 45 08             	mov    0x8(%ebp),%eax
c0102845:	89 04 24             	mov    %eax,(%esp)
c0102848:	e8 00 ff ff ff       	call   c010274d <print_pgfault>
            panic("unhandled page fault.\n");
c010284d:	c7 44 24 08 11 d0 10 	movl   $0xc010d011,0x8(%esp)
c0102854:	c0 
c0102855:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c010285c:	00 
c010285d:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c0102864:	e8 87 e5 ff ff       	call   c0100df0 <__panic>
        }
        mm = current->mm;
c0102869:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010286e:	8b 40 18             	mov    0x18(%eax),%eax
c0102871:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102874:	0f 20 d0             	mov    %cr2,%eax
c0102877:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c010287a:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c010287d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102880:	8b 40 34             	mov    0x34(%eax),%eax
c0102883:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102887:	89 44 24 04          	mov    %eax,0x4(%esp)
c010288b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010288e:	89 04 24             	mov    %eax,(%esp)
c0102891:	e8 06 68 00 00       	call   c010909c <do_pgfault>
}
c0102896:	89 ec                	mov    %ebp,%esp
c0102898:	5d                   	pop    %ebp
c0102899:	c3                   	ret    

c010289a <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010289a:	55                   	push   %ebp
c010289b:	89 e5                	mov    %esp,%ebp
c010289d:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01028a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01028a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01028aa:	8b 40 30             	mov    0x30(%eax),%eax
c01028ad:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028b2:	0f 84 ef 00 00 00    	je     c01029a7 <trap_dispatch+0x10d>
c01028b8:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028bd:	0f 87 a3 01 00 00    	ja     c0102a66 <trap_dispatch+0x1cc>
c01028c3:	83 f8 2f             	cmp    $0x2f,%eax
c01028c6:	77 1e                	ja     c01028e6 <trap_dispatch+0x4c>
c01028c8:	83 f8 0e             	cmp    $0xe,%eax
c01028cb:	0f 82 95 01 00 00    	jb     c0102a66 <trap_dispatch+0x1cc>
c01028d1:	83 e8 0e             	sub    $0xe,%eax
c01028d4:	83 f8 21             	cmp    $0x21,%eax
c01028d7:	0f 87 89 01 00 00    	ja     c0102a66 <trap_dispatch+0x1cc>
c01028dd:	8b 04 85 24 d1 10 c0 	mov    -0x3fef2edc(,%eax,4),%eax
c01028e4:	ff e0                	jmp    *%eax
c01028e6:	83 e8 78             	sub    $0x78,%eax
c01028e9:	83 f8 01             	cmp    $0x1,%eax
c01028ec:	0f 87 74 01 00 00    	ja     c0102a66 <trap_dispatch+0x1cc>
c01028f2:	e9 53 01 00 00       	jmp    c0102a4a <trap_dispatch+0x1b0>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01028f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01028fa:	89 04 24             	mov    %eax,(%esp)
c01028fd:	e8 cc fe ff ff       	call   c01027ce <pgfault_handler>
c0102902:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102905:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102909:	0f 84 a2 01 00 00    	je     c0102ab1 <trap_dispatch+0x217>
            print_trapframe(tf);
c010290f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102912:	89 04 24             	mov    %eax,(%esp)
c0102915:	e8 c6 fb ff ff       	call   c01024e0 <print_trapframe>
            if (current == NULL) {
c010291a:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010291f:	85 c0                	test   %eax,%eax
c0102921:	75 23                	jne    c0102946 <trap_dispatch+0xac>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102923:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102926:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010292a:	c7 44 24 08 28 d0 10 	movl   $0xc010d028,0x8(%esp)
c0102931:	c0 
c0102932:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102939:	00 
c010293a:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c0102941:	e8 aa e4 ff ff       	call   c0100df0 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c0102946:	8b 45 08             	mov    0x8(%ebp),%eax
c0102949:	89 04 24             	mov    %eax,(%esp)
c010294c:	e8 7a fb ff ff       	call   c01024cb <trap_in_kernel>
c0102951:	85 c0                	test   %eax,%eax
c0102953:	74 23                	je     c0102978 <trap_dispatch+0xde>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102955:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102958:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010295c:	c7 44 24 08 48 d0 10 	movl   $0xc010d048,0x8(%esp)
c0102963:	c0 
c0102964:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c010296b:	00 
c010296c:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c0102973:	e8 78 e4 ff ff       	call   c0100df0 <__panic>
                }
                cprintf("killed by kernel.\n");
c0102978:	c7 04 24 76 d0 10 c0 	movl   $0xc010d076,(%esp)
c010297f:	e8 ee d9 ff ff       	call   c0100372 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c0102984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102987:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010298b:	c7 44 24 08 8c d0 10 	movl   $0xc010d08c,0x8(%esp)
c0102992:	c0 
c0102993:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010299a:	00 
c010299b:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c01029a2:	e8 49 e4 ff ff       	call   c0100df0 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
    case T_SYSCALL:
        syscall();
c01029a7:	e8 de 92 00 00       	call   c010bc8a <syscall>
        break;
c01029ac:	e9 01 01 00 00       	jmp    c0102ab2 <trap_dispatch+0x218>
        /* LAB6 YOUR CODE */
        /* you should upate you lab5 code
         * IMPORTANT FUNCTIONS:
	     * sched_class_proc_tick
         */
        ticks++;
c01029b1:	a1 24 74 1b c0       	mov    0xc01b7424,%eax
c01029b6:	40                   	inc    %eax
c01029b7:	a3 24 74 1b c0       	mov    %eax,0xc01b7424
        assert(current != NULL);
c01029bc:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c01029c1:	85 c0                	test   %eax,%eax
c01029c3:	75 24                	jne    c01029e9 <trap_dispatch+0x14f>
c01029c5:	c7 44 24 0c b5 d0 10 	movl   $0xc010d0b5,0xc(%esp)
c01029cc:	c0 
c01029cd:	c7 44 24 08 eb cf 10 	movl   $0xc010cfeb,0x8(%esp)
c01029d4:	c0 
c01029d5:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c01029dc:	00 
c01029dd:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c01029e4:	e8 07 e4 ff ff       	call   c0100df0 <__panic>
        sched_class_proc_tick(current);
c01029e9:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c01029ee:	89 04 24             	mov    %eax,(%esp)
c01029f1:	e8 4c 8f 00 00       	call   c010b942 <sched_class_proc_tick>
        break;
c01029f6:	e9 b7 00 00 00       	jmp    c0102ab2 <trap_dispatch+0x218>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01029fb:	e8 d0 ed ff ff       	call   c01017d0 <cons_getc>
c0102a00:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102a03:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a07:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a0b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a13:	c7 04 24 c5 d0 10 c0 	movl   $0xc010d0c5,(%esp)
c0102a1a:	e8 53 d9 ff ff       	call   c0100372 <cprintf>
        break;
c0102a1f:	e9 8e 00 00 00       	jmp    c0102ab2 <trap_dispatch+0x218>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102a24:	e8 a7 ed ff ff       	call   c01017d0 <cons_getc>
c0102a29:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102a2c:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a30:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a34:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a3c:	c7 04 24 d7 d0 10 c0 	movl   $0xc010d0d7,(%esp)
c0102a43:	e8 2a d9 ff ff       	call   c0100372 <cprintf>
        break;
c0102a48:	eb 68                	jmp    c0102ab2 <trap_dispatch+0x218>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102a4a:	c7 44 24 08 e6 d0 10 	movl   $0xc010d0e6,0x8(%esp)
c0102a51:	c0 
c0102a52:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0102a59:	00 
c0102a5a:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c0102a61:	e8 8a e3 ff ff       	call   c0100df0 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a69:	89 04 24             	mov    %eax,(%esp)
c0102a6c:	e8 6f fa ff ff       	call   c01024e0 <print_trapframe>
        if (current != NULL) {
c0102a71:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102a76:	85 c0                	test   %eax,%eax
c0102a78:	74 18                	je     c0102a92 <trap_dispatch+0x1f8>
            cprintf("unhandled trap.\n");
c0102a7a:	c7 04 24 f6 d0 10 c0 	movl   $0xc010d0f6,(%esp)
c0102a81:	e8 ec d8 ff ff       	call   c0100372 <cprintf>
            do_exit(-E_KILLED);
c0102a86:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a8d:	e8 99 78 00 00       	call   c010a32b <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102a92:	c7 44 24 08 07 d1 10 	movl   $0xc010d107,0x8(%esp)
c0102a99:	c0 
c0102a9a:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0102aa1:	00 
c0102aa2:	c7 04 24 00 d0 10 c0 	movl   $0xc010d000,(%esp)
c0102aa9:	e8 42 e3 ff ff       	call   c0100df0 <__panic>
        break;
c0102aae:	90                   	nop
c0102aaf:	eb 01                	jmp    c0102ab2 <trap_dispatch+0x218>
        break;
c0102ab1:	90                   	nop

    }
}
c0102ab2:	90                   	nop
c0102ab3:	89 ec                	mov    %ebp,%esp
c0102ab5:	5d                   	pop    %ebp
c0102ab6:	c3                   	ret    

c0102ab7 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102ab7:	55                   	push   %ebp
c0102ab8:	89 e5                	mov    %esp,%ebp
c0102aba:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102abd:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102ac2:	85 c0                	test   %eax,%eax
c0102ac4:	75 0d                	jne    c0102ad3 <trap+0x1c>
        trap_dispatch(tf);
c0102ac6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac9:	89 04 24             	mov    %eax,(%esp)
c0102acc:	e8 c9 fd ff ff       	call   c010289a <trap_dispatch>
            if (current->need_resched) {
                schedule();
            }
        }
    }
}
c0102ad1:	eb 6c                	jmp    c0102b3f <trap+0x88>
        struct trapframe *otf = current->tf;
c0102ad3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102ad8:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102ade:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102ae3:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ae6:	89 50 3c             	mov    %edx,0x3c(%eax)
        bool in_kernel = trap_in_kernel(tf);
c0102ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aec:	89 04 24             	mov    %eax,(%esp)
c0102aef:	e8 d7 f9 ff ff       	call   c01024cb <trap_in_kernel>
c0102af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        trap_dispatch(tf);
c0102af7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102afa:	89 04 24             	mov    %eax,(%esp)
c0102afd:	e8 98 fd ff ff       	call   c010289a <trap_dispatch>
        current->tf = otf;
c0102b02:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b0a:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102b0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102b11:	75 2c                	jne    c0102b3f <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102b13:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102b18:	8b 40 44             	mov    0x44(%eax),%eax
c0102b1b:	83 e0 01             	and    $0x1,%eax
c0102b1e:	85 c0                	test   %eax,%eax
c0102b20:	74 0c                	je     c0102b2e <trap+0x77>
                do_exit(-E_KILLED);
c0102b22:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102b29:	e8 fd 77 00 00       	call   c010a32b <do_exit>
            if (current->need_resched) {
c0102b2e:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0102b33:	8b 40 10             	mov    0x10(%eax),%eax
c0102b36:	85 c0                	test   %eax,%eax
c0102b38:	74 05                	je     c0102b3f <trap+0x88>
                schedule();
c0102b3a:	e8 4b 8f 00 00       	call   c010ba8a <schedule>
}
c0102b3f:	90                   	nop
c0102b40:	89 ec                	mov    %ebp,%esp
c0102b42:	5d                   	pop    %ebp
c0102b43:	c3                   	ret    

c0102b44 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b44:	1e                   	push   %ds
    pushl %es
c0102b45:	06                   	push   %es
    pushl %fs
c0102b46:	0f a0                	push   %fs
    pushl %gs
c0102b48:	0f a8                	push   %gs
    pushal
c0102b4a:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102b4b:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102b50:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102b52:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102b54:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102b55:	e8 5d ff ff ff       	call   c0102ab7 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102b5a:	5c                   	pop    %esp

c0102b5b <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102b5b:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102b5c:	0f a9                	pop    %gs
    popl %fs
c0102b5e:	0f a1                	pop    %fs
    popl %es
c0102b60:	07                   	pop    %es
    popl %ds
c0102b61:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102b62:	83 c4 08             	add    $0x8,%esp
    iret
c0102b65:	cf                   	iret   

c0102b66 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102b66:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102b6a:	eb ef                	jmp    c0102b5b <__trapret>

c0102b6c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102b6c:	6a 00                	push   $0x0
  pushl $0
c0102b6e:	6a 00                	push   $0x0
  jmp __alltraps
c0102b70:	e9 cf ff ff ff       	jmp    c0102b44 <__alltraps>

c0102b75 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102b75:	6a 00                	push   $0x0
  pushl $1
c0102b77:	6a 01                	push   $0x1
  jmp __alltraps
c0102b79:	e9 c6 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102b7e <vector2>:
.globl vector2
vector2:
  pushl $0
c0102b7e:	6a 00                	push   $0x0
  pushl $2
c0102b80:	6a 02                	push   $0x2
  jmp __alltraps
c0102b82:	e9 bd ff ff ff       	jmp    c0102b44 <__alltraps>

c0102b87 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102b87:	6a 00                	push   $0x0
  pushl $3
c0102b89:	6a 03                	push   $0x3
  jmp __alltraps
c0102b8b:	e9 b4 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102b90 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102b90:	6a 00                	push   $0x0
  pushl $4
c0102b92:	6a 04                	push   $0x4
  jmp __alltraps
c0102b94:	e9 ab ff ff ff       	jmp    c0102b44 <__alltraps>

c0102b99 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102b99:	6a 00                	push   $0x0
  pushl $5
c0102b9b:	6a 05                	push   $0x5
  jmp __alltraps
c0102b9d:	e9 a2 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102ba2 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $6
c0102ba4:	6a 06                	push   $0x6
  jmp __alltraps
c0102ba6:	e9 99 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bab <vector7>:
.globl vector7
vector7:
  pushl $0
c0102bab:	6a 00                	push   $0x0
  pushl $7
c0102bad:	6a 07                	push   $0x7
  jmp __alltraps
c0102baf:	e9 90 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bb4 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102bb4:	6a 08                	push   $0x8
  jmp __alltraps
c0102bb6:	e9 89 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bbb <vector9>:
.globl vector9
vector9:
  pushl $0
c0102bbb:	6a 00                	push   $0x0
  pushl $9
c0102bbd:	6a 09                	push   $0x9
  jmp __alltraps
c0102bbf:	e9 80 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bc4 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102bc4:	6a 0a                	push   $0xa
  jmp __alltraps
c0102bc6:	e9 79 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bcb <vector11>:
.globl vector11
vector11:
  pushl $11
c0102bcb:	6a 0b                	push   $0xb
  jmp __alltraps
c0102bcd:	e9 72 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bd2 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102bd2:	6a 0c                	push   $0xc
  jmp __alltraps
c0102bd4:	e9 6b ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bd9 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102bd9:	6a 0d                	push   $0xd
  jmp __alltraps
c0102bdb:	e9 64 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102be0 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102be0:	6a 0e                	push   $0xe
  jmp __alltraps
c0102be2:	e9 5d ff ff ff       	jmp    c0102b44 <__alltraps>

c0102be7 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102be7:	6a 00                	push   $0x0
  pushl $15
c0102be9:	6a 0f                	push   $0xf
  jmp __alltraps
c0102beb:	e9 54 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bf0 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102bf0:	6a 00                	push   $0x0
  pushl $16
c0102bf2:	6a 10                	push   $0x10
  jmp __alltraps
c0102bf4:	e9 4b ff ff ff       	jmp    c0102b44 <__alltraps>

c0102bf9 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102bf9:	6a 11                	push   $0x11
  jmp __alltraps
c0102bfb:	e9 44 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c00 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c00:	6a 00                	push   $0x0
  pushl $18
c0102c02:	6a 12                	push   $0x12
  jmp __alltraps
c0102c04:	e9 3b ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c09 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c09:	6a 00                	push   $0x0
  pushl $19
c0102c0b:	6a 13                	push   $0x13
  jmp __alltraps
c0102c0d:	e9 32 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c12 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c12:	6a 00                	push   $0x0
  pushl $20
c0102c14:	6a 14                	push   $0x14
  jmp __alltraps
c0102c16:	e9 29 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c1b <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c1b:	6a 00                	push   $0x0
  pushl $21
c0102c1d:	6a 15                	push   $0x15
  jmp __alltraps
c0102c1f:	e9 20 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c24 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c24:	6a 00                	push   $0x0
  pushl $22
c0102c26:	6a 16                	push   $0x16
  jmp __alltraps
c0102c28:	e9 17 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c2d <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c2d:	6a 00                	push   $0x0
  pushl $23
c0102c2f:	6a 17                	push   $0x17
  jmp __alltraps
c0102c31:	e9 0e ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c36 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c36:	6a 00                	push   $0x0
  pushl $24
c0102c38:	6a 18                	push   $0x18
  jmp __alltraps
c0102c3a:	e9 05 ff ff ff       	jmp    c0102b44 <__alltraps>

c0102c3f <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c3f:	6a 00                	push   $0x0
  pushl $25
c0102c41:	6a 19                	push   $0x19
  jmp __alltraps
c0102c43:	e9 fc fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c48 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102c48:	6a 00                	push   $0x0
  pushl $26
c0102c4a:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102c4c:	e9 f3 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c51 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102c51:	6a 00                	push   $0x0
  pushl $27
c0102c53:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102c55:	e9 ea fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c5a <vector28>:
.globl vector28
vector28:
  pushl $0
c0102c5a:	6a 00                	push   $0x0
  pushl $28
c0102c5c:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102c5e:	e9 e1 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c63 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102c63:	6a 00                	push   $0x0
  pushl $29
c0102c65:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102c67:	e9 d8 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c6c <vector30>:
.globl vector30
vector30:
  pushl $0
c0102c6c:	6a 00                	push   $0x0
  pushl $30
c0102c6e:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102c70:	e9 cf fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c75 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102c75:	6a 00                	push   $0x0
  pushl $31
c0102c77:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102c79:	e9 c6 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c7e <vector32>:
.globl vector32
vector32:
  pushl $0
c0102c7e:	6a 00                	push   $0x0
  pushl $32
c0102c80:	6a 20                	push   $0x20
  jmp __alltraps
c0102c82:	e9 bd fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c87 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102c87:	6a 00                	push   $0x0
  pushl $33
c0102c89:	6a 21                	push   $0x21
  jmp __alltraps
c0102c8b:	e9 b4 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c90 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102c90:	6a 00                	push   $0x0
  pushl $34
c0102c92:	6a 22                	push   $0x22
  jmp __alltraps
c0102c94:	e9 ab fe ff ff       	jmp    c0102b44 <__alltraps>

c0102c99 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102c99:	6a 00                	push   $0x0
  pushl $35
c0102c9b:	6a 23                	push   $0x23
  jmp __alltraps
c0102c9d:	e9 a2 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102ca2 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102ca2:	6a 00                	push   $0x0
  pushl $36
c0102ca4:	6a 24                	push   $0x24
  jmp __alltraps
c0102ca6:	e9 99 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cab <vector37>:
.globl vector37
vector37:
  pushl $0
c0102cab:	6a 00                	push   $0x0
  pushl $37
c0102cad:	6a 25                	push   $0x25
  jmp __alltraps
c0102caf:	e9 90 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cb4 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102cb4:	6a 00                	push   $0x0
  pushl $38
c0102cb6:	6a 26                	push   $0x26
  jmp __alltraps
c0102cb8:	e9 87 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cbd <vector39>:
.globl vector39
vector39:
  pushl $0
c0102cbd:	6a 00                	push   $0x0
  pushl $39
c0102cbf:	6a 27                	push   $0x27
  jmp __alltraps
c0102cc1:	e9 7e fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cc6 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102cc6:	6a 00                	push   $0x0
  pushl $40
c0102cc8:	6a 28                	push   $0x28
  jmp __alltraps
c0102cca:	e9 75 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102ccf <vector41>:
.globl vector41
vector41:
  pushl $0
c0102ccf:	6a 00                	push   $0x0
  pushl $41
c0102cd1:	6a 29                	push   $0x29
  jmp __alltraps
c0102cd3:	e9 6c fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cd8 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102cd8:	6a 00                	push   $0x0
  pushl $42
c0102cda:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102cdc:	e9 63 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102ce1 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102ce1:	6a 00                	push   $0x0
  pushl $43
c0102ce3:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102ce5:	e9 5a fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cea <vector44>:
.globl vector44
vector44:
  pushl $0
c0102cea:	6a 00                	push   $0x0
  pushl $44
c0102cec:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102cee:	e9 51 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cf3 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102cf3:	6a 00                	push   $0x0
  pushl $45
c0102cf5:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102cf7:	e9 48 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102cfc <vector46>:
.globl vector46
vector46:
  pushl $0
c0102cfc:	6a 00                	push   $0x0
  pushl $46
c0102cfe:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d00:	e9 3f fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d05 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d05:	6a 00                	push   $0x0
  pushl $47
c0102d07:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d09:	e9 36 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d0e <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d0e:	6a 00                	push   $0x0
  pushl $48
c0102d10:	6a 30                	push   $0x30
  jmp __alltraps
c0102d12:	e9 2d fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d17 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d17:	6a 00                	push   $0x0
  pushl $49
c0102d19:	6a 31                	push   $0x31
  jmp __alltraps
c0102d1b:	e9 24 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d20 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d20:	6a 00                	push   $0x0
  pushl $50
c0102d22:	6a 32                	push   $0x32
  jmp __alltraps
c0102d24:	e9 1b fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d29 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d29:	6a 00                	push   $0x0
  pushl $51
c0102d2b:	6a 33                	push   $0x33
  jmp __alltraps
c0102d2d:	e9 12 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d32 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d32:	6a 00                	push   $0x0
  pushl $52
c0102d34:	6a 34                	push   $0x34
  jmp __alltraps
c0102d36:	e9 09 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d3b <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d3b:	6a 00                	push   $0x0
  pushl $53
c0102d3d:	6a 35                	push   $0x35
  jmp __alltraps
c0102d3f:	e9 00 fe ff ff       	jmp    c0102b44 <__alltraps>

c0102d44 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102d44:	6a 00                	push   $0x0
  pushl $54
c0102d46:	6a 36                	push   $0x36
  jmp __alltraps
c0102d48:	e9 f7 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d4d <vector55>:
.globl vector55
vector55:
  pushl $0
c0102d4d:	6a 00                	push   $0x0
  pushl $55
c0102d4f:	6a 37                	push   $0x37
  jmp __alltraps
c0102d51:	e9 ee fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d56 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102d56:	6a 00                	push   $0x0
  pushl $56
c0102d58:	6a 38                	push   $0x38
  jmp __alltraps
c0102d5a:	e9 e5 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d5f <vector57>:
.globl vector57
vector57:
  pushl $0
c0102d5f:	6a 00                	push   $0x0
  pushl $57
c0102d61:	6a 39                	push   $0x39
  jmp __alltraps
c0102d63:	e9 dc fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d68 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102d68:	6a 00                	push   $0x0
  pushl $58
c0102d6a:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102d6c:	e9 d3 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d71 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102d71:	6a 00                	push   $0x0
  pushl $59
c0102d73:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102d75:	e9 ca fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d7a <vector60>:
.globl vector60
vector60:
  pushl $0
c0102d7a:	6a 00                	push   $0x0
  pushl $60
c0102d7c:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102d7e:	e9 c1 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d83 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102d83:	6a 00                	push   $0x0
  pushl $61
c0102d85:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102d87:	e9 b8 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d8c <vector62>:
.globl vector62
vector62:
  pushl $0
c0102d8c:	6a 00                	push   $0x0
  pushl $62
c0102d8e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102d90:	e9 af fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d95 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102d95:	6a 00                	push   $0x0
  pushl $63
c0102d97:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102d99:	e9 a6 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102d9e <vector64>:
.globl vector64
vector64:
  pushl $0
c0102d9e:	6a 00                	push   $0x0
  pushl $64
c0102da0:	6a 40                	push   $0x40
  jmp __alltraps
c0102da2:	e9 9d fd ff ff       	jmp    c0102b44 <__alltraps>

c0102da7 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102da7:	6a 00                	push   $0x0
  pushl $65
c0102da9:	6a 41                	push   $0x41
  jmp __alltraps
c0102dab:	e9 94 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102db0 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102db0:	6a 00                	push   $0x0
  pushl $66
c0102db2:	6a 42                	push   $0x42
  jmp __alltraps
c0102db4:	e9 8b fd ff ff       	jmp    c0102b44 <__alltraps>

c0102db9 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102db9:	6a 00                	push   $0x0
  pushl $67
c0102dbb:	6a 43                	push   $0x43
  jmp __alltraps
c0102dbd:	e9 82 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102dc2 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102dc2:	6a 00                	push   $0x0
  pushl $68
c0102dc4:	6a 44                	push   $0x44
  jmp __alltraps
c0102dc6:	e9 79 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102dcb <vector69>:
.globl vector69
vector69:
  pushl $0
c0102dcb:	6a 00                	push   $0x0
  pushl $69
c0102dcd:	6a 45                	push   $0x45
  jmp __alltraps
c0102dcf:	e9 70 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102dd4 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102dd4:	6a 00                	push   $0x0
  pushl $70
c0102dd6:	6a 46                	push   $0x46
  jmp __alltraps
c0102dd8:	e9 67 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102ddd <vector71>:
.globl vector71
vector71:
  pushl $0
c0102ddd:	6a 00                	push   $0x0
  pushl $71
c0102ddf:	6a 47                	push   $0x47
  jmp __alltraps
c0102de1:	e9 5e fd ff ff       	jmp    c0102b44 <__alltraps>

c0102de6 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102de6:	6a 00                	push   $0x0
  pushl $72
c0102de8:	6a 48                	push   $0x48
  jmp __alltraps
c0102dea:	e9 55 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102def <vector73>:
.globl vector73
vector73:
  pushl $0
c0102def:	6a 00                	push   $0x0
  pushl $73
c0102df1:	6a 49                	push   $0x49
  jmp __alltraps
c0102df3:	e9 4c fd ff ff       	jmp    c0102b44 <__alltraps>

c0102df8 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102df8:	6a 00                	push   $0x0
  pushl $74
c0102dfa:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102dfc:	e9 43 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e01 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e01:	6a 00                	push   $0x0
  pushl $75
c0102e03:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e05:	e9 3a fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e0a <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e0a:	6a 00                	push   $0x0
  pushl $76
c0102e0c:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e0e:	e9 31 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e13 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e13:	6a 00                	push   $0x0
  pushl $77
c0102e15:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e17:	e9 28 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e1c <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e1c:	6a 00                	push   $0x0
  pushl $78
c0102e1e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e20:	e9 1f fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e25 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e25:	6a 00                	push   $0x0
  pushl $79
c0102e27:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e29:	e9 16 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e2e <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e2e:	6a 00                	push   $0x0
  pushl $80
c0102e30:	6a 50                	push   $0x50
  jmp __alltraps
c0102e32:	e9 0d fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e37 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e37:	6a 00                	push   $0x0
  pushl $81
c0102e39:	6a 51                	push   $0x51
  jmp __alltraps
c0102e3b:	e9 04 fd ff ff       	jmp    c0102b44 <__alltraps>

c0102e40 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e40:	6a 00                	push   $0x0
  pushl $82
c0102e42:	6a 52                	push   $0x52
  jmp __alltraps
c0102e44:	e9 fb fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e49 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102e49:	6a 00                	push   $0x0
  pushl $83
c0102e4b:	6a 53                	push   $0x53
  jmp __alltraps
c0102e4d:	e9 f2 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e52 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102e52:	6a 00                	push   $0x0
  pushl $84
c0102e54:	6a 54                	push   $0x54
  jmp __alltraps
c0102e56:	e9 e9 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e5b <vector85>:
.globl vector85
vector85:
  pushl $0
c0102e5b:	6a 00                	push   $0x0
  pushl $85
c0102e5d:	6a 55                	push   $0x55
  jmp __alltraps
c0102e5f:	e9 e0 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e64 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102e64:	6a 00                	push   $0x0
  pushl $86
c0102e66:	6a 56                	push   $0x56
  jmp __alltraps
c0102e68:	e9 d7 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e6d <vector87>:
.globl vector87
vector87:
  pushl $0
c0102e6d:	6a 00                	push   $0x0
  pushl $87
c0102e6f:	6a 57                	push   $0x57
  jmp __alltraps
c0102e71:	e9 ce fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e76 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102e76:	6a 00                	push   $0x0
  pushl $88
c0102e78:	6a 58                	push   $0x58
  jmp __alltraps
c0102e7a:	e9 c5 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e7f <vector89>:
.globl vector89
vector89:
  pushl $0
c0102e7f:	6a 00                	push   $0x0
  pushl $89
c0102e81:	6a 59                	push   $0x59
  jmp __alltraps
c0102e83:	e9 bc fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e88 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102e88:	6a 00                	push   $0x0
  pushl $90
c0102e8a:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102e8c:	e9 b3 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e91 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102e91:	6a 00                	push   $0x0
  pushl $91
c0102e93:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102e95:	e9 aa fc ff ff       	jmp    c0102b44 <__alltraps>

c0102e9a <vector92>:
.globl vector92
vector92:
  pushl $0
c0102e9a:	6a 00                	push   $0x0
  pushl $92
c0102e9c:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102e9e:	e9 a1 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ea3 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ea3:	6a 00                	push   $0x0
  pushl $93
c0102ea5:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102ea7:	e9 98 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102eac <vector94>:
.globl vector94
vector94:
  pushl $0
c0102eac:	6a 00                	push   $0x0
  pushl $94
c0102eae:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102eb0:	e9 8f fc ff ff       	jmp    c0102b44 <__alltraps>

c0102eb5 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102eb5:	6a 00                	push   $0x0
  pushl $95
c0102eb7:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102eb9:	e9 86 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ebe <vector96>:
.globl vector96
vector96:
  pushl $0
c0102ebe:	6a 00                	push   $0x0
  pushl $96
c0102ec0:	6a 60                	push   $0x60
  jmp __alltraps
c0102ec2:	e9 7d fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ec7 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102ec7:	6a 00                	push   $0x0
  pushl $97
c0102ec9:	6a 61                	push   $0x61
  jmp __alltraps
c0102ecb:	e9 74 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ed0 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102ed0:	6a 00                	push   $0x0
  pushl $98
c0102ed2:	6a 62                	push   $0x62
  jmp __alltraps
c0102ed4:	e9 6b fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ed9 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ed9:	6a 00                	push   $0x0
  pushl $99
c0102edb:	6a 63                	push   $0x63
  jmp __alltraps
c0102edd:	e9 62 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ee2 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102ee2:	6a 00                	push   $0x0
  pushl $100
c0102ee4:	6a 64                	push   $0x64
  jmp __alltraps
c0102ee6:	e9 59 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102eeb <vector101>:
.globl vector101
vector101:
  pushl $0
c0102eeb:	6a 00                	push   $0x0
  pushl $101
c0102eed:	6a 65                	push   $0x65
  jmp __alltraps
c0102eef:	e9 50 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102ef4 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102ef4:	6a 00                	push   $0x0
  pushl $102
c0102ef6:	6a 66                	push   $0x66
  jmp __alltraps
c0102ef8:	e9 47 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102efd <vector103>:
.globl vector103
vector103:
  pushl $0
c0102efd:	6a 00                	push   $0x0
  pushl $103
c0102eff:	6a 67                	push   $0x67
  jmp __alltraps
c0102f01:	e9 3e fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f06 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f06:	6a 00                	push   $0x0
  pushl $104
c0102f08:	6a 68                	push   $0x68
  jmp __alltraps
c0102f0a:	e9 35 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f0f <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f0f:	6a 00                	push   $0x0
  pushl $105
c0102f11:	6a 69                	push   $0x69
  jmp __alltraps
c0102f13:	e9 2c fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f18 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f18:	6a 00                	push   $0x0
  pushl $106
c0102f1a:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f1c:	e9 23 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f21 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f21:	6a 00                	push   $0x0
  pushl $107
c0102f23:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f25:	e9 1a fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f2a <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f2a:	6a 00                	push   $0x0
  pushl $108
c0102f2c:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f2e:	e9 11 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f33 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f33:	6a 00                	push   $0x0
  pushl $109
c0102f35:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f37:	e9 08 fc ff ff       	jmp    c0102b44 <__alltraps>

c0102f3c <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f3c:	6a 00                	push   $0x0
  pushl $110
c0102f3e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f40:	e9 ff fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f45 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102f45:	6a 00                	push   $0x0
  pushl $111
c0102f47:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102f49:	e9 f6 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f4e <vector112>:
.globl vector112
vector112:
  pushl $0
c0102f4e:	6a 00                	push   $0x0
  pushl $112
c0102f50:	6a 70                	push   $0x70
  jmp __alltraps
c0102f52:	e9 ed fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f57 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102f57:	6a 00                	push   $0x0
  pushl $113
c0102f59:	6a 71                	push   $0x71
  jmp __alltraps
c0102f5b:	e9 e4 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f60 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102f60:	6a 00                	push   $0x0
  pushl $114
c0102f62:	6a 72                	push   $0x72
  jmp __alltraps
c0102f64:	e9 db fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f69 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102f69:	6a 00                	push   $0x0
  pushl $115
c0102f6b:	6a 73                	push   $0x73
  jmp __alltraps
c0102f6d:	e9 d2 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f72 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102f72:	6a 00                	push   $0x0
  pushl $116
c0102f74:	6a 74                	push   $0x74
  jmp __alltraps
c0102f76:	e9 c9 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f7b <vector117>:
.globl vector117
vector117:
  pushl $0
c0102f7b:	6a 00                	push   $0x0
  pushl $117
c0102f7d:	6a 75                	push   $0x75
  jmp __alltraps
c0102f7f:	e9 c0 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f84 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102f84:	6a 00                	push   $0x0
  pushl $118
c0102f86:	6a 76                	push   $0x76
  jmp __alltraps
c0102f88:	e9 b7 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f8d <vector119>:
.globl vector119
vector119:
  pushl $0
c0102f8d:	6a 00                	push   $0x0
  pushl $119
c0102f8f:	6a 77                	push   $0x77
  jmp __alltraps
c0102f91:	e9 ae fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f96 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102f96:	6a 00                	push   $0x0
  pushl $120
c0102f98:	6a 78                	push   $0x78
  jmp __alltraps
c0102f9a:	e9 a5 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102f9f <vector121>:
.globl vector121
vector121:
  pushl $0
c0102f9f:	6a 00                	push   $0x0
  pushl $121
c0102fa1:	6a 79                	push   $0x79
  jmp __alltraps
c0102fa3:	e9 9c fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fa8 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102fa8:	6a 00                	push   $0x0
  pushl $122
c0102faa:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102fac:	e9 93 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fb1 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102fb1:	6a 00                	push   $0x0
  pushl $123
c0102fb3:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102fb5:	e9 8a fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fba <vector124>:
.globl vector124
vector124:
  pushl $0
c0102fba:	6a 00                	push   $0x0
  pushl $124
c0102fbc:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102fbe:	e9 81 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fc3 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102fc3:	6a 00                	push   $0x0
  pushl $125
c0102fc5:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102fc7:	e9 78 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fcc <vector126>:
.globl vector126
vector126:
  pushl $0
c0102fcc:	6a 00                	push   $0x0
  pushl $126
c0102fce:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102fd0:	e9 6f fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fd5 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102fd5:	6a 00                	push   $0x0
  pushl $127
c0102fd7:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102fd9:	e9 66 fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fde <vector128>:
.globl vector128
vector128:
  pushl $0
c0102fde:	6a 00                	push   $0x0
  pushl $128
c0102fe0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102fe5:	e9 5a fb ff ff       	jmp    c0102b44 <__alltraps>

c0102fea <vector129>:
.globl vector129
vector129:
  pushl $0
c0102fea:	6a 00                	push   $0x0
  pushl $129
c0102fec:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ff1:	e9 4e fb ff ff       	jmp    c0102b44 <__alltraps>

c0102ff6 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ff6:	6a 00                	push   $0x0
  pushl $130
c0102ff8:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102ffd:	e9 42 fb ff ff       	jmp    c0102b44 <__alltraps>

c0103002 <vector131>:
.globl vector131
vector131:
  pushl $0
c0103002:	6a 00                	push   $0x0
  pushl $131
c0103004:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103009:	e9 36 fb ff ff       	jmp    c0102b44 <__alltraps>

c010300e <vector132>:
.globl vector132
vector132:
  pushl $0
c010300e:	6a 00                	push   $0x0
  pushl $132
c0103010:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0103015:	e9 2a fb ff ff       	jmp    c0102b44 <__alltraps>

c010301a <vector133>:
.globl vector133
vector133:
  pushl $0
c010301a:	6a 00                	push   $0x0
  pushl $133
c010301c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103021:	e9 1e fb ff ff       	jmp    c0102b44 <__alltraps>

c0103026 <vector134>:
.globl vector134
vector134:
  pushl $0
c0103026:	6a 00                	push   $0x0
  pushl $134
c0103028:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010302d:	e9 12 fb ff ff       	jmp    c0102b44 <__alltraps>

c0103032 <vector135>:
.globl vector135
vector135:
  pushl $0
c0103032:	6a 00                	push   $0x0
  pushl $135
c0103034:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103039:	e9 06 fb ff ff       	jmp    c0102b44 <__alltraps>

c010303e <vector136>:
.globl vector136
vector136:
  pushl $0
c010303e:	6a 00                	push   $0x0
  pushl $136
c0103040:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0103045:	e9 fa fa ff ff       	jmp    c0102b44 <__alltraps>

c010304a <vector137>:
.globl vector137
vector137:
  pushl $0
c010304a:	6a 00                	push   $0x0
  pushl $137
c010304c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103051:	e9 ee fa ff ff       	jmp    c0102b44 <__alltraps>

c0103056 <vector138>:
.globl vector138
vector138:
  pushl $0
c0103056:	6a 00                	push   $0x0
  pushl $138
c0103058:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010305d:	e9 e2 fa ff ff       	jmp    c0102b44 <__alltraps>

c0103062 <vector139>:
.globl vector139
vector139:
  pushl $0
c0103062:	6a 00                	push   $0x0
  pushl $139
c0103064:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0103069:	e9 d6 fa ff ff       	jmp    c0102b44 <__alltraps>

c010306e <vector140>:
.globl vector140
vector140:
  pushl $0
c010306e:	6a 00                	push   $0x0
  pushl $140
c0103070:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0103075:	e9 ca fa ff ff       	jmp    c0102b44 <__alltraps>

c010307a <vector141>:
.globl vector141
vector141:
  pushl $0
c010307a:	6a 00                	push   $0x0
  pushl $141
c010307c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0103081:	e9 be fa ff ff       	jmp    c0102b44 <__alltraps>

c0103086 <vector142>:
.globl vector142
vector142:
  pushl $0
c0103086:	6a 00                	push   $0x0
  pushl $142
c0103088:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010308d:	e9 b2 fa ff ff       	jmp    c0102b44 <__alltraps>

c0103092 <vector143>:
.globl vector143
vector143:
  pushl $0
c0103092:	6a 00                	push   $0x0
  pushl $143
c0103094:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0103099:	e9 a6 fa ff ff       	jmp    c0102b44 <__alltraps>

c010309e <vector144>:
.globl vector144
vector144:
  pushl $0
c010309e:	6a 00                	push   $0x0
  pushl $144
c01030a0:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01030a5:	e9 9a fa ff ff       	jmp    c0102b44 <__alltraps>

c01030aa <vector145>:
.globl vector145
vector145:
  pushl $0
c01030aa:	6a 00                	push   $0x0
  pushl $145
c01030ac:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01030b1:	e9 8e fa ff ff       	jmp    c0102b44 <__alltraps>

c01030b6 <vector146>:
.globl vector146
vector146:
  pushl $0
c01030b6:	6a 00                	push   $0x0
  pushl $146
c01030b8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01030bd:	e9 82 fa ff ff       	jmp    c0102b44 <__alltraps>

c01030c2 <vector147>:
.globl vector147
vector147:
  pushl $0
c01030c2:	6a 00                	push   $0x0
  pushl $147
c01030c4:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01030c9:	e9 76 fa ff ff       	jmp    c0102b44 <__alltraps>

c01030ce <vector148>:
.globl vector148
vector148:
  pushl $0
c01030ce:	6a 00                	push   $0x0
  pushl $148
c01030d0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01030d5:	e9 6a fa ff ff       	jmp    c0102b44 <__alltraps>

c01030da <vector149>:
.globl vector149
vector149:
  pushl $0
c01030da:	6a 00                	push   $0x0
  pushl $149
c01030dc:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01030e1:	e9 5e fa ff ff       	jmp    c0102b44 <__alltraps>

c01030e6 <vector150>:
.globl vector150
vector150:
  pushl $0
c01030e6:	6a 00                	push   $0x0
  pushl $150
c01030e8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01030ed:	e9 52 fa ff ff       	jmp    c0102b44 <__alltraps>

c01030f2 <vector151>:
.globl vector151
vector151:
  pushl $0
c01030f2:	6a 00                	push   $0x0
  pushl $151
c01030f4:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01030f9:	e9 46 fa ff ff       	jmp    c0102b44 <__alltraps>

c01030fe <vector152>:
.globl vector152
vector152:
  pushl $0
c01030fe:	6a 00                	push   $0x0
  pushl $152
c0103100:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0103105:	e9 3a fa ff ff       	jmp    c0102b44 <__alltraps>

c010310a <vector153>:
.globl vector153
vector153:
  pushl $0
c010310a:	6a 00                	push   $0x0
  pushl $153
c010310c:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103111:	e9 2e fa ff ff       	jmp    c0102b44 <__alltraps>

c0103116 <vector154>:
.globl vector154
vector154:
  pushl $0
c0103116:	6a 00                	push   $0x0
  pushl $154
c0103118:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010311d:	e9 22 fa ff ff       	jmp    c0102b44 <__alltraps>

c0103122 <vector155>:
.globl vector155
vector155:
  pushl $0
c0103122:	6a 00                	push   $0x0
  pushl $155
c0103124:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103129:	e9 16 fa ff ff       	jmp    c0102b44 <__alltraps>

c010312e <vector156>:
.globl vector156
vector156:
  pushl $0
c010312e:	6a 00                	push   $0x0
  pushl $156
c0103130:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103135:	e9 0a fa ff ff       	jmp    c0102b44 <__alltraps>

c010313a <vector157>:
.globl vector157
vector157:
  pushl $0
c010313a:	6a 00                	push   $0x0
  pushl $157
c010313c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103141:	e9 fe f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103146 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103146:	6a 00                	push   $0x0
  pushl $158
c0103148:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010314d:	e9 f2 f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103152 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103152:	6a 00                	push   $0x0
  pushl $159
c0103154:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103159:	e9 e6 f9 ff ff       	jmp    c0102b44 <__alltraps>

c010315e <vector160>:
.globl vector160
vector160:
  pushl $0
c010315e:	6a 00                	push   $0x0
  pushl $160
c0103160:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103165:	e9 da f9 ff ff       	jmp    c0102b44 <__alltraps>

c010316a <vector161>:
.globl vector161
vector161:
  pushl $0
c010316a:	6a 00                	push   $0x0
  pushl $161
c010316c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103171:	e9 ce f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103176 <vector162>:
.globl vector162
vector162:
  pushl $0
c0103176:	6a 00                	push   $0x0
  pushl $162
c0103178:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010317d:	e9 c2 f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103182 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103182:	6a 00                	push   $0x0
  pushl $163
c0103184:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0103189:	e9 b6 f9 ff ff       	jmp    c0102b44 <__alltraps>

c010318e <vector164>:
.globl vector164
vector164:
  pushl $0
c010318e:	6a 00                	push   $0x0
  pushl $164
c0103190:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0103195:	e9 aa f9 ff ff       	jmp    c0102b44 <__alltraps>

c010319a <vector165>:
.globl vector165
vector165:
  pushl $0
c010319a:	6a 00                	push   $0x0
  pushl $165
c010319c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031a1:	e9 9e f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031a6 <vector166>:
.globl vector166
vector166:
  pushl $0
c01031a6:	6a 00                	push   $0x0
  pushl $166
c01031a8:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01031ad:	e9 92 f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031b2 <vector167>:
.globl vector167
vector167:
  pushl $0
c01031b2:	6a 00                	push   $0x0
  pushl $167
c01031b4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01031b9:	e9 86 f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031be <vector168>:
.globl vector168
vector168:
  pushl $0
c01031be:	6a 00                	push   $0x0
  pushl $168
c01031c0:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01031c5:	e9 7a f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031ca <vector169>:
.globl vector169
vector169:
  pushl $0
c01031ca:	6a 00                	push   $0x0
  pushl $169
c01031cc:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01031d1:	e9 6e f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031d6 <vector170>:
.globl vector170
vector170:
  pushl $0
c01031d6:	6a 00                	push   $0x0
  pushl $170
c01031d8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01031dd:	e9 62 f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031e2 <vector171>:
.globl vector171
vector171:
  pushl $0
c01031e2:	6a 00                	push   $0x0
  pushl $171
c01031e4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01031e9:	e9 56 f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031ee <vector172>:
.globl vector172
vector172:
  pushl $0
c01031ee:	6a 00                	push   $0x0
  pushl $172
c01031f0:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01031f5:	e9 4a f9 ff ff       	jmp    c0102b44 <__alltraps>

c01031fa <vector173>:
.globl vector173
vector173:
  pushl $0
c01031fa:	6a 00                	push   $0x0
  pushl $173
c01031fc:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103201:	e9 3e f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103206 <vector174>:
.globl vector174
vector174:
  pushl $0
c0103206:	6a 00                	push   $0x0
  pushl $174
c0103208:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010320d:	e9 32 f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103212 <vector175>:
.globl vector175
vector175:
  pushl $0
c0103212:	6a 00                	push   $0x0
  pushl $175
c0103214:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103219:	e9 26 f9 ff ff       	jmp    c0102b44 <__alltraps>

c010321e <vector176>:
.globl vector176
vector176:
  pushl $0
c010321e:	6a 00                	push   $0x0
  pushl $176
c0103220:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0103225:	e9 1a f9 ff ff       	jmp    c0102b44 <__alltraps>

c010322a <vector177>:
.globl vector177
vector177:
  pushl $0
c010322a:	6a 00                	push   $0x0
  pushl $177
c010322c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103231:	e9 0e f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103236 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103236:	6a 00                	push   $0x0
  pushl $178
c0103238:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010323d:	e9 02 f9 ff ff       	jmp    c0102b44 <__alltraps>

c0103242 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103242:	6a 00                	push   $0x0
  pushl $179
c0103244:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103249:	e9 f6 f8 ff ff       	jmp    c0102b44 <__alltraps>

c010324e <vector180>:
.globl vector180
vector180:
  pushl $0
c010324e:	6a 00                	push   $0x0
  pushl $180
c0103250:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103255:	e9 ea f8 ff ff       	jmp    c0102b44 <__alltraps>

c010325a <vector181>:
.globl vector181
vector181:
  pushl $0
c010325a:	6a 00                	push   $0x0
  pushl $181
c010325c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103261:	e9 de f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103266 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103266:	6a 00                	push   $0x0
  pushl $182
c0103268:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010326d:	e9 d2 f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103272 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103272:	6a 00                	push   $0x0
  pushl $183
c0103274:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0103279:	e9 c6 f8 ff ff       	jmp    c0102b44 <__alltraps>

c010327e <vector184>:
.globl vector184
vector184:
  pushl $0
c010327e:	6a 00                	push   $0x0
  pushl $184
c0103280:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103285:	e9 ba f8 ff ff       	jmp    c0102b44 <__alltraps>

c010328a <vector185>:
.globl vector185
vector185:
  pushl $0
c010328a:	6a 00                	push   $0x0
  pushl $185
c010328c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103291:	e9 ae f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103296 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103296:	6a 00                	push   $0x0
  pushl $186
c0103298:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010329d:	e9 a2 f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032a2 <vector187>:
.globl vector187
vector187:
  pushl $0
c01032a2:	6a 00                	push   $0x0
  pushl $187
c01032a4:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01032a9:	e9 96 f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032ae <vector188>:
.globl vector188
vector188:
  pushl $0
c01032ae:	6a 00                	push   $0x0
  pushl $188
c01032b0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01032b5:	e9 8a f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032ba <vector189>:
.globl vector189
vector189:
  pushl $0
c01032ba:	6a 00                	push   $0x0
  pushl $189
c01032bc:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01032c1:	e9 7e f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032c6 <vector190>:
.globl vector190
vector190:
  pushl $0
c01032c6:	6a 00                	push   $0x0
  pushl $190
c01032c8:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01032cd:	e9 72 f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032d2 <vector191>:
.globl vector191
vector191:
  pushl $0
c01032d2:	6a 00                	push   $0x0
  pushl $191
c01032d4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01032d9:	e9 66 f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032de <vector192>:
.globl vector192
vector192:
  pushl $0
c01032de:	6a 00                	push   $0x0
  pushl $192
c01032e0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01032e5:	e9 5a f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032ea <vector193>:
.globl vector193
vector193:
  pushl $0
c01032ea:	6a 00                	push   $0x0
  pushl $193
c01032ec:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01032f1:	e9 4e f8 ff ff       	jmp    c0102b44 <__alltraps>

c01032f6 <vector194>:
.globl vector194
vector194:
  pushl $0
c01032f6:	6a 00                	push   $0x0
  pushl $194
c01032f8:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01032fd:	e9 42 f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103302 <vector195>:
.globl vector195
vector195:
  pushl $0
c0103302:	6a 00                	push   $0x0
  pushl $195
c0103304:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103309:	e9 36 f8 ff ff       	jmp    c0102b44 <__alltraps>

c010330e <vector196>:
.globl vector196
vector196:
  pushl $0
c010330e:	6a 00                	push   $0x0
  pushl $196
c0103310:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103315:	e9 2a f8 ff ff       	jmp    c0102b44 <__alltraps>

c010331a <vector197>:
.globl vector197
vector197:
  pushl $0
c010331a:	6a 00                	push   $0x0
  pushl $197
c010331c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103321:	e9 1e f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103326 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103326:	6a 00                	push   $0x0
  pushl $198
c0103328:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010332d:	e9 12 f8 ff ff       	jmp    c0102b44 <__alltraps>

c0103332 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103332:	6a 00                	push   $0x0
  pushl $199
c0103334:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103339:	e9 06 f8 ff ff       	jmp    c0102b44 <__alltraps>

c010333e <vector200>:
.globl vector200
vector200:
  pushl $0
c010333e:	6a 00                	push   $0x0
  pushl $200
c0103340:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103345:	e9 fa f7 ff ff       	jmp    c0102b44 <__alltraps>

c010334a <vector201>:
.globl vector201
vector201:
  pushl $0
c010334a:	6a 00                	push   $0x0
  pushl $201
c010334c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103351:	e9 ee f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103356 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103356:	6a 00                	push   $0x0
  pushl $202
c0103358:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010335d:	e9 e2 f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103362 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103362:	6a 00                	push   $0x0
  pushl $203
c0103364:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103369:	e9 d6 f7 ff ff       	jmp    c0102b44 <__alltraps>

c010336e <vector204>:
.globl vector204
vector204:
  pushl $0
c010336e:	6a 00                	push   $0x0
  pushl $204
c0103370:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103375:	e9 ca f7 ff ff       	jmp    c0102b44 <__alltraps>

c010337a <vector205>:
.globl vector205
vector205:
  pushl $0
c010337a:	6a 00                	push   $0x0
  pushl $205
c010337c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103381:	e9 be f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103386 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103386:	6a 00                	push   $0x0
  pushl $206
c0103388:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010338d:	e9 b2 f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103392 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103392:	6a 00                	push   $0x0
  pushl $207
c0103394:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103399:	e9 a6 f7 ff ff       	jmp    c0102b44 <__alltraps>

c010339e <vector208>:
.globl vector208
vector208:
  pushl $0
c010339e:	6a 00                	push   $0x0
  pushl $208
c01033a0:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01033a5:	e9 9a f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033aa <vector209>:
.globl vector209
vector209:
  pushl $0
c01033aa:	6a 00                	push   $0x0
  pushl $209
c01033ac:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01033b1:	e9 8e f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033b6 <vector210>:
.globl vector210
vector210:
  pushl $0
c01033b6:	6a 00                	push   $0x0
  pushl $210
c01033b8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01033bd:	e9 82 f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033c2 <vector211>:
.globl vector211
vector211:
  pushl $0
c01033c2:	6a 00                	push   $0x0
  pushl $211
c01033c4:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01033c9:	e9 76 f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033ce <vector212>:
.globl vector212
vector212:
  pushl $0
c01033ce:	6a 00                	push   $0x0
  pushl $212
c01033d0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01033d5:	e9 6a f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033da <vector213>:
.globl vector213
vector213:
  pushl $0
c01033da:	6a 00                	push   $0x0
  pushl $213
c01033dc:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01033e1:	e9 5e f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033e6 <vector214>:
.globl vector214
vector214:
  pushl $0
c01033e6:	6a 00                	push   $0x0
  pushl $214
c01033e8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01033ed:	e9 52 f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033f2 <vector215>:
.globl vector215
vector215:
  pushl $0
c01033f2:	6a 00                	push   $0x0
  pushl $215
c01033f4:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01033f9:	e9 46 f7 ff ff       	jmp    c0102b44 <__alltraps>

c01033fe <vector216>:
.globl vector216
vector216:
  pushl $0
c01033fe:	6a 00                	push   $0x0
  pushl $216
c0103400:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103405:	e9 3a f7 ff ff       	jmp    c0102b44 <__alltraps>

c010340a <vector217>:
.globl vector217
vector217:
  pushl $0
c010340a:	6a 00                	push   $0x0
  pushl $217
c010340c:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103411:	e9 2e f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103416 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103416:	6a 00                	push   $0x0
  pushl $218
c0103418:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010341d:	e9 22 f7 ff ff       	jmp    c0102b44 <__alltraps>

c0103422 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103422:	6a 00                	push   $0x0
  pushl $219
c0103424:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103429:	e9 16 f7 ff ff       	jmp    c0102b44 <__alltraps>

c010342e <vector220>:
.globl vector220
vector220:
  pushl $0
c010342e:	6a 00                	push   $0x0
  pushl $220
c0103430:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103435:	e9 0a f7 ff ff       	jmp    c0102b44 <__alltraps>

c010343a <vector221>:
.globl vector221
vector221:
  pushl $0
c010343a:	6a 00                	push   $0x0
  pushl $221
c010343c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103441:	e9 fe f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103446 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103446:	6a 00                	push   $0x0
  pushl $222
c0103448:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010344d:	e9 f2 f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103452 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103452:	6a 00                	push   $0x0
  pushl $223
c0103454:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103459:	e9 e6 f6 ff ff       	jmp    c0102b44 <__alltraps>

c010345e <vector224>:
.globl vector224
vector224:
  pushl $0
c010345e:	6a 00                	push   $0x0
  pushl $224
c0103460:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103465:	e9 da f6 ff ff       	jmp    c0102b44 <__alltraps>

c010346a <vector225>:
.globl vector225
vector225:
  pushl $0
c010346a:	6a 00                	push   $0x0
  pushl $225
c010346c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103471:	e9 ce f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103476 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103476:	6a 00                	push   $0x0
  pushl $226
c0103478:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010347d:	e9 c2 f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103482 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103482:	6a 00                	push   $0x0
  pushl $227
c0103484:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103489:	e9 b6 f6 ff ff       	jmp    c0102b44 <__alltraps>

c010348e <vector228>:
.globl vector228
vector228:
  pushl $0
c010348e:	6a 00                	push   $0x0
  pushl $228
c0103490:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103495:	e9 aa f6 ff ff       	jmp    c0102b44 <__alltraps>

c010349a <vector229>:
.globl vector229
vector229:
  pushl $0
c010349a:	6a 00                	push   $0x0
  pushl $229
c010349c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034a1:	e9 9e f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034a6 <vector230>:
.globl vector230
vector230:
  pushl $0
c01034a6:	6a 00                	push   $0x0
  pushl $230
c01034a8:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01034ad:	e9 92 f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034b2 <vector231>:
.globl vector231
vector231:
  pushl $0
c01034b2:	6a 00                	push   $0x0
  pushl $231
c01034b4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01034b9:	e9 86 f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034be <vector232>:
.globl vector232
vector232:
  pushl $0
c01034be:	6a 00                	push   $0x0
  pushl $232
c01034c0:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01034c5:	e9 7a f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034ca <vector233>:
.globl vector233
vector233:
  pushl $0
c01034ca:	6a 00                	push   $0x0
  pushl $233
c01034cc:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01034d1:	e9 6e f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034d6 <vector234>:
.globl vector234
vector234:
  pushl $0
c01034d6:	6a 00                	push   $0x0
  pushl $234
c01034d8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01034dd:	e9 62 f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034e2 <vector235>:
.globl vector235
vector235:
  pushl $0
c01034e2:	6a 00                	push   $0x0
  pushl $235
c01034e4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01034e9:	e9 56 f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034ee <vector236>:
.globl vector236
vector236:
  pushl $0
c01034ee:	6a 00                	push   $0x0
  pushl $236
c01034f0:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01034f5:	e9 4a f6 ff ff       	jmp    c0102b44 <__alltraps>

c01034fa <vector237>:
.globl vector237
vector237:
  pushl $0
c01034fa:	6a 00                	push   $0x0
  pushl $237
c01034fc:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103501:	e9 3e f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103506 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103506:	6a 00                	push   $0x0
  pushl $238
c0103508:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c010350d:	e9 32 f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103512 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103512:	6a 00                	push   $0x0
  pushl $239
c0103514:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103519:	e9 26 f6 ff ff       	jmp    c0102b44 <__alltraps>

c010351e <vector240>:
.globl vector240
vector240:
  pushl $0
c010351e:	6a 00                	push   $0x0
  pushl $240
c0103520:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103525:	e9 1a f6 ff ff       	jmp    c0102b44 <__alltraps>

c010352a <vector241>:
.globl vector241
vector241:
  pushl $0
c010352a:	6a 00                	push   $0x0
  pushl $241
c010352c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103531:	e9 0e f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103536 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103536:	6a 00                	push   $0x0
  pushl $242
c0103538:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010353d:	e9 02 f6 ff ff       	jmp    c0102b44 <__alltraps>

c0103542 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103542:	6a 00                	push   $0x0
  pushl $243
c0103544:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103549:	e9 f6 f5 ff ff       	jmp    c0102b44 <__alltraps>

c010354e <vector244>:
.globl vector244
vector244:
  pushl $0
c010354e:	6a 00                	push   $0x0
  pushl $244
c0103550:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103555:	e9 ea f5 ff ff       	jmp    c0102b44 <__alltraps>

c010355a <vector245>:
.globl vector245
vector245:
  pushl $0
c010355a:	6a 00                	push   $0x0
  pushl $245
c010355c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103561:	e9 de f5 ff ff       	jmp    c0102b44 <__alltraps>

c0103566 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103566:	6a 00                	push   $0x0
  pushl $246
c0103568:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010356d:	e9 d2 f5 ff ff       	jmp    c0102b44 <__alltraps>

c0103572 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103572:	6a 00                	push   $0x0
  pushl $247
c0103574:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103579:	e9 c6 f5 ff ff       	jmp    c0102b44 <__alltraps>

c010357e <vector248>:
.globl vector248
vector248:
  pushl $0
c010357e:	6a 00                	push   $0x0
  pushl $248
c0103580:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103585:	e9 ba f5 ff ff       	jmp    c0102b44 <__alltraps>

c010358a <vector249>:
.globl vector249
vector249:
  pushl $0
c010358a:	6a 00                	push   $0x0
  pushl $249
c010358c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103591:	e9 ae f5 ff ff       	jmp    c0102b44 <__alltraps>

c0103596 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103596:	6a 00                	push   $0x0
  pushl $250
c0103598:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010359d:	e9 a2 f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035a2 <vector251>:
.globl vector251
vector251:
  pushl $0
c01035a2:	6a 00                	push   $0x0
  pushl $251
c01035a4:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01035a9:	e9 96 f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035ae <vector252>:
.globl vector252
vector252:
  pushl $0
c01035ae:	6a 00                	push   $0x0
  pushl $252
c01035b0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01035b5:	e9 8a f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035ba <vector253>:
.globl vector253
vector253:
  pushl $0
c01035ba:	6a 00                	push   $0x0
  pushl $253
c01035bc:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01035c1:	e9 7e f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035c6 <vector254>:
.globl vector254
vector254:
  pushl $0
c01035c6:	6a 00                	push   $0x0
  pushl $254
c01035c8:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01035cd:	e9 72 f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035d2 <vector255>:
.globl vector255
vector255:
  pushl $0
c01035d2:	6a 00                	push   $0x0
  pushl $255
c01035d4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01035d9:	e9 66 f5 ff ff       	jmp    c0102b44 <__alltraps>

c01035de <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01035de:	55                   	push   %ebp
c01035df:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01035e1:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c01035e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ea:	29 d0                	sub    %edx,%eax
c01035ec:	c1 f8 05             	sar    $0x5,%eax
}
c01035ef:	5d                   	pop    %ebp
c01035f0:	c3                   	ret    

c01035f1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01035f1:	55                   	push   %ebp
c01035f2:	89 e5                	mov    %esp,%ebp
c01035f4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01035f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035fa:	89 04 24             	mov    %eax,(%esp)
c01035fd:	e8 dc ff ff ff       	call   c01035de <page2ppn>
c0103602:	c1 e0 0c             	shl    $0xc,%eax
}
c0103605:	89 ec                	mov    %ebp,%esp
c0103607:	5d                   	pop    %ebp
c0103608:	c3                   	ret    

c0103609 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103609:	55                   	push   %ebp
c010360a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010360c:	8b 45 08             	mov    0x8(%ebp),%eax
c010360f:	8b 00                	mov    (%eax),%eax
}
c0103611:	5d                   	pop    %ebp
c0103612:	c3                   	ret    

c0103613 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103613:	55                   	push   %ebp
c0103614:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103616:	8b 45 08             	mov    0x8(%ebp),%eax
c0103619:	8b 55 0c             	mov    0xc(%ebp),%edx
c010361c:	89 10                	mov    %edx,(%eax)
}
c010361e:	90                   	nop
c010361f:	5d                   	pop    %ebp
c0103620:	c3                   	ret    

c0103621 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103621:	55                   	push   %ebp
c0103622:	89 e5                	mov    %esp,%ebp
c0103624:	83 ec 10             	sub    $0x10,%esp
c0103627:	c7 45 fc 84 7f 1b c0 	movl   $0xc01b7f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010362e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103631:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103634:	89 50 04             	mov    %edx,0x4(%eax)
c0103637:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010363a:	8b 50 04             	mov    0x4(%eax),%edx
c010363d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103640:	89 10                	mov    %edx,(%eax)
}
c0103642:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103643:	c7 05 8c 7f 1b c0 00 	movl   $0x0,0xc01b7f8c
c010364a:	00 00 00 
}
c010364d:	90                   	nop
c010364e:	89 ec                	mov    %ebp,%esp
c0103650:	5d                   	pop    %ebp
c0103651:	c3                   	ret    

c0103652 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103652:	55                   	push   %ebp
c0103653:	89 e5                	mov    %esp,%ebp
c0103655:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103658:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010365c:	75 24                	jne    c0103682 <default_init_memmap+0x30>
c010365e:	c7 44 24 0c 50 d3 10 	movl   $0xc010d350,0xc(%esp)
c0103665:	c0 
c0103666:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c010366d:	c0 
c010366e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103675:	00 
c0103676:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c010367d:	e8 6e d7 ff ff       	call   c0100df0 <__panic>
    struct Page *p = base;
c0103682:	8b 45 08             	mov    0x8(%ebp),%eax
c0103685:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103688:	eb 7d                	jmp    c0103707 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c010368a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010368d:	83 c0 04             	add    $0x4,%eax
c0103690:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103697:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010369a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010369d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036a0:	0f a3 10             	bt     %edx,(%eax)
c01036a3:	19 c0                	sbb    %eax,%eax
c01036a5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036ac:	0f 95 c0             	setne  %al
c01036af:	0f b6 c0             	movzbl %al,%eax
c01036b2:	85 c0                	test   %eax,%eax
c01036b4:	75 24                	jne    c01036da <default_init_memmap+0x88>
c01036b6:	c7 44 24 0c 81 d3 10 	movl   $0xc010d381,0xc(%esp)
c01036bd:	c0 
c01036be:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01036c5:	c0 
c01036c6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01036cd:	00 
c01036ce:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01036d5:	e8 16 d7 ff ff       	call   c0100df0 <__panic>
        p->flags = p->property = 0;
c01036da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036dd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01036e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e7:	8b 50 08             	mov    0x8(%eax),%edx
c01036ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036ed:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01036f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036f7:	00 
c01036f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fb:	89 04 24             	mov    %eax,(%esp)
c01036fe:	e8 10 ff ff ff       	call   c0103613 <set_page_ref>
    for (; p != base + n; p ++) {
c0103703:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103707:	8b 45 0c             	mov    0xc(%ebp),%eax
c010370a:	c1 e0 05             	shl    $0x5,%eax
c010370d:	89 c2                	mov    %eax,%edx
c010370f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103712:	01 d0                	add    %edx,%eax
c0103714:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103717:	0f 85 6d ff ff ff    	jne    c010368a <default_init_memmap+0x38>
    }
    base->property = n;
c010371d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103720:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103723:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103726:	8b 45 08             	mov    0x8(%ebp),%eax
c0103729:	83 c0 04             	add    $0x4,%eax
c010372c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103733:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103736:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103739:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010373c:	0f ab 10             	bts    %edx,(%eax)
}
c010373f:	90                   	nop
    nr_free += n;
c0103740:	8b 15 8c 7f 1b c0    	mov    0xc01b7f8c,%edx
c0103746:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103749:	01 d0                	add    %edx,%eax
c010374b:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c
    list_add_before(&free_list, &(base->page_link));
c0103750:	8b 45 08             	mov    0x8(%ebp),%eax
c0103753:	83 c0 0c             	add    $0xc,%eax
c0103756:	c7 45 e4 84 7f 1b c0 	movl   $0xc01b7f84,-0x1c(%ebp)
c010375d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103763:	8b 00                	mov    (%eax),%eax
c0103765:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103768:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010376b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010376e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103774:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103777:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010377a:	89 10                	mov    %edx,(%eax)
c010377c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010377f:	8b 10                	mov    (%eax),%edx
c0103781:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103784:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103787:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010378a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010378d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103790:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103793:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103796:	89 10                	mov    %edx,(%eax)
}
c0103798:	90                   	nop
}
c0103799:	90                   	nop
    // list_add(&free_list, &(base->page_link));
}
c010379a:	90                   	nop
c010379b:	89 ec                	mov    %ebp,%esp
c010379d:	5d                   	pop    %ebp
c010379e:	c3                   	ret    

c010379f <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010379f:	55                   	push   %ebp
c01037a0:	89 e5                	mov    %esp,%ebp
c01037a2:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01037a5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037a9:	75 24                	jne    c01037cf <default_alloc_pages+0x30>
c01037ab:	c7 44 24 0c 50 d3 10 	movl   $0xc010d350,0xc(%esp)
c01037b2:	c0 
c01037b3:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01037ba:	c0 
c01037bb:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01037c2:	00 
c01037c3:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01037ca:	e8 21 d6 ff ff       	call   c0100df0 <__panic>
    if (n > nr_free) {
c01037cf:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c01037d4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037d7:	76 0a                	jbe    c01037e3 <default_alloc_pages+0x44>
        return NULL;
c01037d9:	b8 00 00 00 00       	mov    $0x0,%eax
c01037de:	e9 3c 01 00 00       	jmp    c010391f <default_alloc_pages+0x180>
    }
    struct Page *page = NULL;
c01037e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01037ea:	c7 45 f0 84 7f 1b c0 	movl   $0xc01b7f84,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01037f1:	eb 1c                	jmp    c010380f <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01037f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037f6:	83 e8 0c             	sub    $0xc,%eax
c01037f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01037fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037ff:	8b 40 08             	mov    0x8(%eax),%eax
c0103802:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103805:	77 08                	ja     c010380f <default_alloc_pages+0x70>
            page = p;
c0103807:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010380a:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c010380d:	eb 18                	jmp    c0103827 <default_alloc_pages+0x88>
c010380f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103812:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0103815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103818:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010381b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010381e:	81 7d f0 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x10(%ebp)
c0103825:	75 cc                	jne    c01037f3 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {
c0103827:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010382b:	0f 84 eb 00 00 00    	je     c010391c <default_alloc_pages+0x17d>
        if (page->property > n) {
c0103831:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103834:	8b 40 08             	mov    0x8(%eax),%eax
c0103837:	39 45 08             	cmp    %eax,0x8(%ebp)
c010383a:	0f 83 88 00 00 00    	jae    c01038c8 <default_alloc_pages+0x129>
            struct Page *p = page + n;
c0103840:	8b 45 08             	mov    0x8(%ebp),%eax
c0103843:	c1 e0 05             	shl    $0x5,%eax
c0103846:	89 c2                	mov    %eax,%edx
c0103848:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010384b:	01 d0                	add    %edx,%eax
c010384d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103853:	8b 40 08             	mov    0x8(%eax),%eax
c0103856:	2b 45 08             	sub    0x8(%ebp),%eax
c0103859:	89 c2                	mov    %eax,%edx
c010385b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010385e:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103861:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103864:	83 c0 0c             	add    $0xc,%eax
c0103867:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010386a:	83 c2 0c             	add    $0xc,%edx
c010386d:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0103870:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103873:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103876:	8b 40 04             	mov    0x4(%eax),%eax
c0103879:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010387c:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010387f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103882:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103885:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0103888:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010388b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010388e:	89 10                	mov    %edx,(%eax)
c0103890:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103893:	8b 10                	mov    (%eax),%edx
c0103895:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103898:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010389b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010389e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01038a1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038a7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038aa:	89 10                	mov    %edx,(%eax)
}
c01038ac:	90                   	nop
}
c01038ad:	90                   	nop
            //---------------------------------
            SetPageProperty(p);
c01038ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038b1:	83 c0 04             	add    $0x4,%eax
c01038b4:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038be:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038c4:	0f ab 10             	bts    %edx,(%eax)
}
c01038c7:	90                   	nop
            //---------------------------------
        }
        list_del(&(page->page_link));
c01038c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038cb:	83 c0 0c             	add    $0xc,%eax
c01038ce:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c01038d1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01038d4:	8b 40 04             	mov    0x4(%eax),%eax
c01038d7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01038da:	8b 12                	mov    (%edx),%edx
c01038dc:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01038df:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01038e2:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01038e5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01038e8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01038eb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01038ee:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01038f1:	89 10                	mov    %edx,(%eax)
}
c01038f3:	90                   	nop
}
c01038f4:	90                   	nop
        nr_free -= n;
c01038f5:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c01038fa:	2b 45 08             	sub    0x8(%ebp),%eax
c01038fd:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c
        ClearPageProperty(page);
c0103902:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103905:	83 c0 04             	add    $0x4,%eax
c0103908:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010390f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103912:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103915:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103918:	0f b3 10             	btr    %edx,(%eax)
}
c010391b:	90                   	nop
    }
    return page;
c010391c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010391f:	89 ec                	mov    %ebp,%esp
c0103921:	5d                   	pop    %ebp
c0103922:	c3                   	ret    

c0103923 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103923:	55                   	push   %ebp
c0103924:	89 e5                	mov    %esp,%ebp
c0103926:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010392c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103930:	75 24                	jne    c0103956 <default_free_pages+0x33>
c0103932:	c7 44 24 0c 50 d3 10 	movl   $0xc010d350,0xc(%esp)
c0103939:	c0 
c010393a:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103941:	c0 
c0103942:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0103949:	00 
c010394a:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103951:	e8 9a d4 ff ff       	call   c0100df0 <__panic>
    struct Page *p = base;
c0103956:	8b 45 08             	mov    0x8(%ebp),%eax
c0103959:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++) {
c010395c:	e9 9d 00 00 00       	jmp    c01039fe <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0103961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103964:	83 c0 04             	add    $0x4,%eax
c0103967:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010396e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103971:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103974:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103977:	0f a3 10             	bt     %edx,(%eax)
c010397a:	19 c0                	sbb    %eax,%eax
c010397c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c010397f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103983:	0f 95 c0             	setne  %al
c0103986:	0f b6 c0             	movzbl %al,%eax
c0103989:	85 c0                	test   %eax,%eax
c010398b:	75 2c                	jne    c01039b9 <default_free_pages+0x96>
c010398d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103990:	83 c0 04             	add    $0x4,%eax
c0103993:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c010399a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010399d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01039a3:	0f a3 10             	bt     %edx,(%eax)
c01039a6:	19 c0                	sbb    %eax,%eax
c01039a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c01039ab:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01039af:	0f 95 c0             	setne  %al
c01039b2:	0f b6 c0             	movzbl %al,%eax
c01039b5:	85 c0                	test   %eax,%eax
c01039b7:	74 24                	je     c01039dd <default_free_pages+0xba>
c01039b9:	c7 44 24 0c 94 d3 10 	movl   $0xc010d394,0xc(%esp)
c01039c0:	c0 
c01039c1:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01039c8:	c0 
c01039c9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01039d0:	00 
c01039d1:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01039d8:	e8 13 d4 ff ff       	call   c0100df0 <__panic>
        p->flags = 0;
c01039dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039e0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01039e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01039ee:	00 
c01039ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039f2:	89 04 24             	mov    %eax,(%esp)
c01039f5:	e8 19 fc ff ff       	call   c0103613 <set_page_ref>
    for (; p != base + n; p++) {
c01039fa:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01039fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a01:	c1 e0 05             	shl    $0x5,%eax
c0103a04:	89 c2                	mov    %eax,%edx
c0103a06:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a09:	01 d0                	add    %edx,%eax
c0103a0b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a0e:	0f 85 4d ff ff ff    	jne    c0103961 <default_free_pages+0x3e>
    }
    base->property = n;
c0103a14:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a17:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a1a:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a20:	83 c0 04             	add    $0x4,%eax
c0103a23:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103a2a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a2d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103a30:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103a33:	0f ab 10             	bts    %edx,(%eax)
}
c0103a36:	90                   	nop
c0103a37:	c7 45 cc 84 7f 1b c0 	movl   $0xc01b7f84,-0x34(%ebp)
    return listelm->next;
c0103a3e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a41:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list), *sp = NULL;
c0103a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a47:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    bool flag = 0;
c0103a4e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != &free_list) {
c0103a55:	e9 39 01 00 00       	jmp    c0103b93 <default_free_pages+0x270>
        // sp = le;
        p = le2page(le, page_link);
c0103a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a5d:	83 e8 0c             	sub    $0xc,%eax
c0103a60:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property == p) {
c0103a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a66:	8b 40 08             	mov    0x8(%eax),%eax
c0103a69:	c1 e0 05             	shl    $0x5,%eax
c0103a6c:	89 c2                	mov    %eax,%edx
c0103a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a71:	01 d0                	add    %edx,%eax
c0103a73:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a76:	75 5f                	jne    c0103ad7 <default_free_pages+0x1b4>
            base->property += p->property;
c0103a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a7b:	8b 50 08             	mov    0x8(%eax),%edx
c0103a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a81:	8b 40 08             	mov    0x8(%eax),%eax
c0103a84:	01 c2                	add    %eax,%edx
c0103a86:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a89:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8f:	83 c0 04             	add    $0x4,%eax
c0103a92:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0103a99:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a9c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103a9f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103aa2:	0f b3 10             	btr    %edx,(%eax)
}
c0103aa5:	90                   	nop
            list_del(&(p->page_link));
c0103aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aa9:	83 c0 0c             	add    $0xc,%eax
c0103aac:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103aaf:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103ab2:	8b 40 04             	mov    0x4(%eax),%eax
c0103ab5:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103ab8:	8b 12                	mov    (%edx),%edx
c0103aba:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103abd:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c0103ac0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103ac3:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103ac6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103ac9:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103acc:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103acf:	89 10                	mov    %edx,(%eax)
}
c0103ad1:	90                   	nop
}
c0103ad2:	e9 8b 00 00 00       	jmp    c0103b62 <default_free_pages+0x23f>
        } else if (p + p->property == base) {
c0103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ada:	8b 40 08             	mov    0x8(%eax),%eax
c0103add:	c1 e0 05             	shl    $0x5,%eax
c0103ae0:	89 c2                	mov    %eax,%edx
c0103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae5:	01 d0                	add    %edx,%eax
c0103ae7:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103aea:	75 76                	jne    c0103b62 <default_free_pages+0x23f>
            p->property += base->property;
c0103aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aef:	8b 50 08             	mov    0x8(%eax),%edx
c0103af2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af5:	8b 40 08             	mov    0x8(%eax),%eax
c0103af8:	01 c2                	add    %eax,%edx
c0103afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103afd:	89 50 08             	mov    %edx,0x8(%eax)
c0103b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b03:	89 45 98             	mov    %eax,-0x68(%ebp)
    return listelm->prev;
c0103b06:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103b09:	8b 00                	mov    (%eax),%eax
            sp = list_prev(le);
c0103b0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
            flag = 1;
c0103b0e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
            ClearPageProperty(base);
c0103b15:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b18:	83 c0 04             	add    $0x4,%eax
c0103b1b:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103b22:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103b25:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103b28:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103b2b:	0f b3 10             	btr    %edx,(%eax)
}
c0103b2e:	90                   	nop
            base = p;
c0103b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b32:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b38:	83 c0 0c             	add    $0xc,%eax
c0103b3b:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103b3e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b41:	8b 40 04             	mov    0x4(%eax),%eax
c0103b44:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103b47:	8b 12                	mov    (%edx),%edx
c0103b49:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0103b4c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c0103b4f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103b52:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b55:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b58:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103b5b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103b5e:	89 10                	mov    %edx,(%eax)
}
c0103b60:	90                   	nop
}
c0103b61:	90                   	nop
        }
        if (p + p->property < base)
c0103b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b65:	8b 40 08             	mov    0x8(%eax),%eax
c0103b68:	c1 e0 05             	shl    $0x5,%eax
c0103b6b:	89 c2                	mov    %eax,%edx
c0103b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b70:	01 d0                	add    %edx,%eax
c0103b72:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103b75:	76 0d                	jbe    c0103b84 <default_free_pages+0x261>
            sp = le, flag = 1;
c0103b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b7d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0103b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b87:	89 45 94             	mov    %eax,-0x6c(%ebp)
    return listelm->next;
c0103b8a:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103b8d:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103b90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103b93:	81 7d f0 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x10(%ebp)
c0103b9a:	0f 85 ba fe ff ff    	jne    c0103a5a <default_free_pages+0x137>
    }
    nr_free += n;
c0103ba0:	8b 15 8c 7f 1b c0    	mov    0xc01b7f8c,%edx
c0103ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ba9:	01 d0                	add    %edx,%eax
c0103bab:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c
    //cprintf("%x %x\n", sp, &free_list);
    list_add((flag ? sp : &free_list), &(base->page_link));
c0103bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb3:	8d 50 0c             	lea    0xc(%eax),%edx
c0103bb6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103bba:	74 05                	je     c0103bc1 <default_free_pages+0x29e>
c0103bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bbf:	eb 05                	jmp    c0103bc6 <default_free_pages+0x2a3>
c0103bc1:	b8 84 7f 1b c0       	mov    $0xc01b7f84,%eax
c0103bc6:	89 45 90             	mov    %eax,-0x70(%ebp)
c0103bc9:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103bcc:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103bcf:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103bd2:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103bd5:	89 45 84             	mov    %eax,-0x7c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103bd8:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103bdb:	8b 40 04             	mov    0x4(%eax),%eax
c0103bde:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103be1:	89 55 80             	mov    %edx,-0x80(%ebp)
c0103be4:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103be7:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103bed:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    prev->next = next->prev = elm;
c0103bf3:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103bf9:	8b 55 80             	mov    -0x80(%ebp),%edx
c0103bfc:	89 10                	mov    %edx,(%eax)
c0103bfe:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103c04:	8b 10                	mov    (%eax),%edx
c0103c06:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103c0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103c0f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103c12:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
c0103c18:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103c1b:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103c1e:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103c24:	89 10                	mov    %edx,(%eax)
}
c0103c26:	90                   	nop
}
c0103c27:	90                   	nop
}
c0103c28:	90                   	nop
}
c0103c29:	90                   	nop
c0103c2a:	89 ec                	mov    %ebp,%esp
c0103c2c:	5d                   	pop    %ebp
c0103c2d:	c3                   	ret    

c0103c2e <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103c2e:	55                   	push   %ebp
c0103c2f:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103c31:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
}
c0103c36:	5d                   	pop    %ebp
c0103c37:	c3                   	ret    

c0103c38 <basic_check>:

static void
basic_check(void) {
c0103c38:	55                   	push   %ebp
c0103c39:	89 e5                	mov    %esp,%ebp
c0103c3b:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103c3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103c51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c58:	e8 17 16 00 00       	call   c0105274 <alloc_pages>
c0103c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103c64:	75 24                	jne    c0103c8a <basic_check+0x52>
c0103c66:	c7 44 24 0c b9 d3 10 	movl   $0xc010d3b9,0xc(%esp)
c0103c6d:	c0 
c0103c6e:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103c75:	c0 
c0103c76:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0103c7d:	00 
c0103c7e:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103c85:	e8 66 d1 ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103c8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c91:	e8 de 15 00 00       	call   c0105274 <alloc_pages>
c0103c96:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c99:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c9d:	75 24                	jne    c0103cc3 <basic_check+0x8b>
c0103c9f:	c7 44 24 0c d5 d3 10 	movl   $0xc010d3d5,0xc(%esp)
c0103ca6:	c0 
c0103ca7:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103cae:	c0 
c0103caf:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0103cb6:	00 
c0103cb7:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103cbe:	e8 2d d1 ff ff       	call   c0100df0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103cc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cca:	e8 a5 15 00 00       	call   c0105274 <alloc_pages>
c0103ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103cd6:	75 24                	jne    c0103cfc <basic_check+0xc4>
c0103cd8:	c7 44 24 0c f1 d3 10 	movl   $0xc010d3f1,0xc(%esp)
c0103cdf:	c0 
c0103ce0:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103ce7:	c0 
c0103ce8:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0103cef:	00 
c0103cf0:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103cf7:	e8 f4 d0 ff ff       	call   c0100df0 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103cfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103d02:	74 10                	je     c0103d14 <basic_check+0xdc>
c0103d04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d07:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d0a:	74 08                	je     c0103d14 <basic_check+0xdc>
c0103d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d0f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d12:	75 24                	jne    c0103d38 <basic_check+0x100>
c0103d14:	c7 44 24 0c 10 d4 10 	movl   $0xc010d410,0xc(%esp)
c0103d1b:	c0 
c0103d1c:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103d23:	c0 
c0103d24:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0103d2b:	00 
c0103d2c:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103d33:	e8 b8 d0 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103d38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d3b:	89 04 24             	mov    %eax,(%esp)
c0103d3e:	e8 c6 f8 ff ff       	call   c0103609 <page_ref>
c0103d43:	85 c0                	test   %eax,%eax
c0103d45:	75 1e                	jne    c0103d65 <basic_check+0x12d>
c0103d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d4a:	89 04 24             	mov    %eax,(%esp)
c0103d4d:	e8 b7 f8 ff ff       	call   c0103609 <page_ref>
c0103d52:	85 c0                	test   %eax,%eax
c0103d54:	75 0f                	jne    c0103d65 <basic_check+0x12d>
c0103d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d59:	89 04 24             	mov    %eax,(%esp)
c0103d5c:	e8 a8 f8 ff ff       	call   c0103609 <page_ref>
c0103d61:	85 c0                	test   %eax,%eax
c0103d63:	74 24                	je     c0103d89 <basic_check+0x151>
c0103d65:	c7 44 24 0c 34 d4 10 	movl   $0xc010d434,0xc(%esp)
c0103d6c:	c0 
c0103d6d:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103d74:	c0 
c0103d75:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0103d7c:	00 
c0103d7d:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103d84:	e8 67 d0 ff ff       	call   c0100df0 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103d89:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d8c:	89 04 24             	mov    %eax,(%esp)
c0103d8f:	e8 5d f8 ff ff       	call   c01035f1 <page2pa>
c0103d94:	8b 15 a4 7f 1b c0    	mov    0xc01b7fa4,%edx
c0103d9a:	c1 e2 0c             	shl    $0xc,%edx
c0103d9d:	39 d0                	cmp    %edx,%eax
c0103d9f:	72 24                	jb     c0103dc5 <basic_check+0x18d>
c0103da1:	c7 44 24 0c 70 d4 10 	movl   $0xc010d470,0xc(%esp)
c0103da8:	c0 
c0103da9:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103db0:	c0 
c0103db1:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0103db8:	00 
c0103db9:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103dc0:	e8 2b d0 ff ff       	call   c0100df0 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dc8:	89 04 24             	mov    %eax,(%esp)
c0103dcb:	e8 21 f8 ff ff       	call   c01035f1 <page2pa>
c0103dd0:	8b 15 a4 7f 1b c0    	mov    0xc01b7fa4,%edx
c0103dd6:	c1 e2 0c             	shl    $0xc,%edx
c0103dd9:	39 d0                	cmp    %edx,%eax
c0103ddb:	72 24                	jb     c0103e01 <basic_check+0x1c9>
c0103ddd:	c7 44 24 0c 8d d4 10 	movl   $0xc010d48d,0xc(%esp)
c0103de4:	c0 
c0103de5:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103dec:	c0 
c0103ded:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103df4:	00 
c0103df5:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103dfc:	e8 ef cf ff ff       	call   c0100df0 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e04:	89 04 24             	mov    %eax,(%esp)
c0103e07:	e8 e5 f7 ff ff       	call   c01035f1 <page2pa>
c0103e0c:	8b 15 a4 7f 1b c0    	mov    0xc01b7fa4,%edx
c0103e12:	c1 e2 0c             	shl    $0xc,%edx
c0103e15:	39 d0                	cmp    %edx,%eax
c0103e17:	72 24                	jb     c0103e3d <basic_check+0x205>
c0103e19:	c7 44 24 0c aa d4 10 	movl   $0xc010d4aa,0xc(%esp)
c0103e20:	c0 
c0103e21:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103e28:	c0 
c0103e29:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0103e30:	00 
c0103e31:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103e38:	e8 b3 cf ff ff       	call   c0100df0 <__panic>

    list_entry_t free_list_store = free_list;
c0103e3d:	a1 84 7f 1b c0       	mov    0xc01b7f84,%eax
c0103e42:	8b 15 88 7f 1b c0    	mov    0xc01b7f88,%edx
c0103e48:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103e4b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103e4e:	c7 45 dc 84 7f 1b c0 	movl   $0xc01b7f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e58:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e5b:	89 50 04             	mov    %edx,0x4(%eax)
c0103e5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e61:	8b 50 04             	mov    0x4(%eax),%edx
c0103e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e67:	89 10                	mov    %edx,(%eax)
}
c0103e69:	90                   	nop
c0103e6a:	c7 45 e0 84 7f 1b c0 	movl   $0xc01b7f84,-0x20(%ebp)
    return list->next == list;
c0103e71:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e74:	8b 40 04             	mov    0x4(%eax),%eax
c0103e77:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103e7a:	0f 94 c0             	sete   %al
c0103e7d:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103e80:	85 c0                	test   %eax,%eax
c0103e82:	75 24                	jne    c0103ea8 <basic_check+0x270>
c0103e84:	c7 44 24 0c c7 d4 10 	movl   $0xc010d4c7,0xc(%esp)
c0103e8b:	c0 
c0103e8c:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103e93:	c0 
c0103e94:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0103e9b:	00 
c0103e9c:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103ea3:	e8 48 cf ff ff       	call   c0100df0 <__panic>

    unsigned int nr_free_store = nr_free;
c0103ea8:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c0103ead:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103eb0:	c7 05 8c 7f 1b c0 00 	movl   $0x0,0xc01b7f8c
c0103eb7:	00 00 00 

    assert(alloc_page() == NULL);
c0103eba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ec1:	e8 ae 13 00 00       	call   c0105274 <alloc_pages>
c0103ec6:	85 c0                	test   %eax,%eax
c0103ec8:	74 24                	je     c0103eee <basic_check+0x2b6>
c0103eca:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c0103ed1:	c0 
c0103ed2:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103ed9:	c0 
c0103eda:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103ee1:	00 
c0103ee2:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103ee9:	e8 02 cf ff ff       	call   c0100df0 <__panic>

    free_page(p0);
c0103eee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ef5:	00 
c0103ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ef9:	89 04 24             	mov    %eax,(%esp)
c0103efc:	e8 e0 13 00 00       	call   c01052e1 <free_pages>
    free_page(p1);
c0103f01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f08:	00 
c0103f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f0c:	89 04 24             	mov    %eax,(%esp)
c0103f0f:	e8 cd 13 00 00       	call   c01052e1 <free_pages>
    free_page(p2);
c0103f14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f1b:	00 
c0103f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f1f:	89 04 24             	mov    %eax,(%esp)
c0103f22:	e8 ba 13 00 00       	call   c01052e1 <free_pages>
    assert(nr_free == 3);
c0103f27:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c0103f2c:	83 f8 03             	cmp    $0x3,%eax
c0103f2f:	74 24                	je     c0103f55 <basic_check+0x31d>
c0103f31:	c7 44 24 0c f3 d4 10 	movl   $0xc010d4f3,0xc(%esp)
c0103f38:	c0 
c0103f39:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103f40:	c0 
c0103f41:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0103f48:	00 
c0103f49:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103f50:	e8 9b ce ff ff       	call   c0100df0 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103f55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f5c:	e8 13 13 00 00       	call   c0105274 <alloc_pages>
c0103f61:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f64:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f68:	75 24                	jne    c0103f8e <basic_check+0x356>
c0103f6a:	c7 44 24 0c b9 d3 10 	movl   $0xc010d3b9,0xc(%esp)
c0103f71:	c0 
c0103f72:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103f79:	c0 
c0103f7a:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103f81:	00 
c0103f82:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103f89:	e8 62 ce ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103f8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f95:	e8 da 12 00 00       	call   c0105274 <alloc_pages>
c0103f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103fa1:	75 24                	jne    c0103fc7 <basic_check+0x38f>
c0103fa3:	c7 44 24 0c d5 d3 10 	movl   $0xc010d3d5,0xc(%esp)
c0103faa:	c0 
c0103fab:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103fb2:	c0 
c0103fb3:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103fba:	00 
c0103fbb:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103fc2:	e8 29 ce ff ff       	call   c0100df0 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103fc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fce:	e8 a1 12 00 00       	call   c0105274 <alloc_pages>
c0103fd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103fd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103fda:	75 24                	jne    c0104000 <basic_check+0x3c8>
c0103fdc:	c7 44 24 0c f1 d3 10 	movl   $0xc010d3f1,0xc(%esp)
c0103fe3:	c0 
c0103fe4:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0103feb:	c0 
c0103fec:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103ff3:	00 
c0103ff4:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0103ffb:	e8 f0 cd ff ff       	call   c0100df0 <__panic>

    assert(alloc_page() == NULL);
c0104000:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104007:	e8 68 12 00 00       	call   c0105274 <alloc_pages>
c010400c:	85 c0                	test   %eax,%eax
c010400e:	74 24                	je     c0104034 <basic_check+0x3fc>
c0104010:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c0104017:	c0 
c0104018:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c010401f:	c0 
c0104020:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0104027:	00 
c0104028:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c010402f:	e8 bc cd ff ff       	call   c0100df0 <__panic>

    free_page(p0);
c0104034:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010403b:	00 
c010403c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010403f:	89 04 24             	mov    %eax,(%esp)
c0104042:	e8 9a 12 00 00       	call   c01052e1 <free_pages>
c0104047:	c7 45 d8 84 7f 1b c0 	movl   $0xc01b7f84,-0x28(%ebp)
c010404e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104051:	8b 40 04             	mov    0x4(%eax),%eax
c0104054:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104057:	0f 94 c0             	sete   %al
c010405a:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010405d:	85 c0                	test   %eax,%eax
c010405f:	74 24                	je     c0104085 <basic_check+0x44d>
c0104061:	c7 44 24 0c 00 d5 10 	movl   $0xc010d500,0xc(%esp)
c0104068:	c0 
c0104069:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104070:	c0 
c0104071:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104078:	00 
c0104079:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104080:	e8 6b cd ff ff       	call   c0100df0 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104085:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010408c:	e8 e3 11 00 00       	call   c0105274 <alloc_pages>
c0104091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104097:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010409a:	74 24                	je     c01040c0 <basic_check+0x488>
c010409c:	c7 44 24 0c 18 d5 10 	movl   $0xc010d518,0xc(%esp)
c01040a3:	c0 
c01040a4:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01040ab:	c0 
c01040ac:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01040b3:	00 
c01040b4:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01040bb:	e8 30 cd ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c01040c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040c7:	e8 a8 11 00 00       	call   c0105274 <alloc_pages>
c01040cc:	85 c0                	test   %eax,%eax
c01040ce:	74 24                	je     c01040f4 <basic_check+0x4bc>
c01040d0:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c01040d7:	c0 
c01040d8:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01040df:	c0 
c01040e0:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01040e7:	00 
c01040e8:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01040ef:	e8 fc cc ff ff       	call   c0100df0 <__panic>

    assert(nr_free == 0);
c01040f4:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c01040f9:	85 c0                	test   %eax,%eax
c01040fb:	74 24                	je     c0104121 <basic_check+0x4e9>
c01040fd:	c7 44 24 0c 31 d5 10 	movl   $0xc010d531,0xc(%esp)
c0104104:	c0 
c0104105:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c010410c:	c0 
c010410d:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0104114:	00 
c0104115:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c010411c:	e8 cf cc ff ff       	call   c0100df0 <__panic>
    free_list = free_list_store;
c0104121:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104124:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104127:	a3 84 7f 1b c0       	mov    %eax,0xc01b7f84
c010412c:	89 15 88 7f 1b c0    	mov    %edx,0xc01b7f88
    nr_free = nr_free_store;
c0104132:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104135:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c

    free_page(p);
c010413a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104141:	00 
c0104142:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104145:	89 04 24             	mov    %eax,(%esp)
c0104148:	e8 94 11 00 00       	call   c01052e1 <free_pages>
    free_page(p1);
c010414d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104154:	00 
c0104155:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104158:	89 04 24             	mov    %eax,(%esp)
c010415b:	e8 81 11 00 00       	call   c01052e1 <free_pages>
    free_page(p2);
c0104160:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104167:	00 
c0104168:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010416b:	89 04 24             	mov    %eax,(%esp)
c010416e:	e8 6e 11 00 00       	call   c01052e1 <free_pages>
}
c0104173:	90                   	nop
c0104174:	89 ec                	mov    %ebp,%esp
c0104176:	5d                   	pop    %ebp
c0104177:	c3                   	ret    

c0104178 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104178:	55                   	push   %ebp
c0104179:	89 e5                	mov    %esp,%ebp
c010417b:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0104181:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104188:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010418f:	c7 45 ec 84 7f 1b c0 	movl   $0xc01b7f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104196:	eb 6a                	jmp    c0104202 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0104198:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010419b:	83 e8 0c             	sub    $0xc,%eax
c010419e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01041a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041a4:	83 c0 04             	add    $0x4,%eax
c01041a7:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01041ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01041b4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041b7:	0f a3 10             	bt     %edx,(%eax)
c01041ba:	19 c0                	sbb    %eax,%eax
c01041bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01041bf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01041c3:	0f 95 c0             	setne  %al
c01041c6:	0f b6 c0             	movzbl %al,%eax
c01041c9:	85 c0                	test   %eax,%eax
c01041cb:	75 24                	jne    c01041f1 <default_check+0x79>
c01041cd:	c7 44 24 0c 3e d5 10 	movl   $0xc010d53e,0xc(%esp)
c01041d4:	c0 
c01041d5:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01041dc:	c0 
c01041dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01041e4:	00 
c01041e5:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01041ec:	e8 ff cb ff ff       	call   c0100df0 <__panic>
        count ++, total += p->property;
c01041f1:	ff 45 f4             	incl   -0xc(%ebp)
c01041f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041f7:	8b 50 08             	mov    0x8(%eax),%edx
c01041fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01041fd:	01 d0                	add    %edx,%eax
c01041ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104202:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104205:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104208:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010420b:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010420e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104211:	81 7d ec 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x14(%ebp)
c0104218:	0f 85 7a ff ff ff    	jne    c0104198 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c010421e:	e8 f3 10 00 00       	call   c0105316 <nr_free_pages>
c0104223:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104226:	39 d0                	cmp    %edx,%eax
c0104228:	74 24                	je     c010424e <default_check+0xd6>
c010422a:	c7 44 24 0c 4e d5 10 	movl   $0xc010d54e,0xc(%esp)
c0104231:	c0 
c0104232:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104239:	c0 
c010423a:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0104241:	00 
c0104242:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104249:	e8 a2 cb ff ff       	call   c0100df0 <__panic>

    basic_check();
c010424e:	e8 e5 f9 ff ff       	call   c0103c38 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0104253:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010425a:	e8 15 10 00 00       	call   c0105274 <alloc_pages>
c010425f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104262:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104266:	75 24                	jne    c010428c <default_check+0x114>
c0104268:	c7 44 24 0c 67 d5 10 	movl   $0xc010d567,0xc(%esp)
c010426f:	c0 
c0104270:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104277:	c0 
c0104278:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c010427f:	00 
c0104280:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104287:	e8 64 cb ff ff       	call   c0100df0 <__panic>
    assert(!PageProperty(p0));
c010428c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010428f:	83 c0 04             	add    $0x4,%eax
c0104292:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104299:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010429c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010429f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042a2:	0f a3 10             	bt     %edx,(%eax)
c01042a5:	19 c0                	sbb    %eax,%eax
c01042a7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01042aa:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01042ae:	0f 95 c0             	setne  %al
c01042b1:	0f b6 c0             	movzbl %al,%eax
c01042b4:	85 c0                	test   %eax,%eax
c01042b6:	74 24                	je     c01042dc <default_check+0x164>
c01042b8:	c7 44 24 0c 72 d5 10 	movl   $0xc010d572,0xc(%esp)
c01042bf:	c0 
c01042c0:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01042c7:	c0 
c01042c8:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01042cf:	00 
c01042d0:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01042d7:	e8 14 cb ff ff       	call   c0100df0 <__panic>

    list_entry_t free_list_store = free_list;
c01042dc:	a1 84 7f 1b c0       	mov    0xc01b7f84,%eax
c01042e1:	8b 15 88 7f 1b c0    	mov    0xc01b7f88,%edx
c01042e7:	89 45 80             	mov    %eax,-0x80(%ebp)
c01042ea:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01042ed:	c7 45 b0 84 7f 1b c0 	movl   $0xc01b7f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01042f4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01042f7:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01042fa:	89 50 04             	mov    %edx,0x4(%eax)
c01042fd:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104300:	8b 50 04             	mov    0x4(%eax),%edx
c0104303:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104306:	89 10                	mov    %edx,(%eax)
}
c0104308:	90                   	nop
c0104309:	c7 45 b4 84 7f 1b c0 	movl   $0xc01b7f84,-0x4c(%ebp)
    return list->next == list;
c0104310:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104313:	8b 40 04             	mov    0x4(%eax),%eax
c0104316:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104319:	0f 94 c0             	sete   %al
c010431c:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010431f:	85 c0                	test   %eax,%eax
c0104321:	75 24                	jne    c0104347 <default_check+0x1cf>
c0104323:	c7 44 24 0c c7 d4 10 	movl   $0xc010d4c7,0xc(%esp)
c010432a:	c0 
c010432b:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104332:	c0 
c0104333:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010433a:	00 
c010433b:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104342:	e8 a9 ca ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c0104347:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010434e:	e8 21 0f 00 00       	call   c0105274 <alloc_pages>
c0104353:	85 c0                	test   %eax,%eax
c0104355:	74 24                	je     c010437b <default_check+0x203>
c0104357:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c010435e:	c0 
c010435f:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104366:	c0 
c0104367:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c010436e:	00 
c010436f:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104376:	e8 75 ca ff ff       	call   c0100df0 <__panic>

    unsigned int nr_free_store = nr_free;
c010437b:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c0104380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104383:	c7 05 8c 7f 1b c0 00 	movl   $0x0,0xc01b7f8c
c010438a:	00 00 00 

    free_pages(p0 + 2, 3);
c010438d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104390:	83 c0 40             	add    $0x40,%eax
c0104393:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010439a:	00 
c010439b:	89 04 24             	mov    %eax,(%esp)
c010439e:	e8 3e 0f 00 00       	call   c01052e1 <free_pages>
    assert(alloc_pages(4) == NULL);
c01043a3:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01043aa:	e8 c5 0e 00 00       	call   c0105274 <alloc_pages>
c01043af:	85 c0                	test   %eax,%eax
c01043b1:	74 24                	je     c01043d7 <default_check+0x25f>
c01043b3:	c7 44 24 0c 84 d5 10 	movl   $0xc010d584,0xc(%esp)
c01043ba:	c0 
c01043bb:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01043c2:	c0 
c01043c3:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01043ca:	00 
c01043cb:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01043d2:	e8 19 ca ff ff       	call   c0100df0 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01043d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043da:	83 c0 40             	add    $0x40,%eax
c01043dd:	83 c0 04             	add    $0x4,%eax
c01043e0:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01043e7:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01043ea:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01043ed:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01043f0:	0f a3 10             	bt     %edx,(%eax)
c01043f3:	19 c0                	sbb    %eax,%eax
c01043f5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01043f8:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01043fc:	0f 95 c0             	setne  %al
c01043ff:	0f b6 c0             	movzbl %al,%eax
c0104402:	85 c0                	test   %eax,%eax
c0104404:	74 0e                	je     c0104414 <default_check+0x29c>
c0104406:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104409:	83 c0 40             	add    $0x40,%eax
c010440c:	8b 40 08             	mov    0x8(%eax),%eax
c010440f:	83 f8 03             	cmp    $0x3,%eax
c0104412:	74 24                	je     c0104438 <default_check+0x2c0>
c0104414:	c7 44 24 0c 9c d5 10 	movl   $0xc010d59c,0xc(%esp)
c010441b:	c0 
c010441c:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104423:	c0 
c0104424:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c010442b:	00 
c010442c:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104433:	e8 b8 c9 ff ff       	call   c0100df0 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104438:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010443f:	e8 30 0e 00 00       	call   c0105274 <alloc_pages>
c0104444:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010444b:	75 24                	jne    c0104471 <default_check+0x2f9>
c010444d:	c7 44 24 0c c8 d5 10 	movl   $0xc010d5c8,0xc(%esp)
c0104454:	c0 
c0104455:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c010445c:	c0 
c010445d:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0104464:	00 
c0104465:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c010446c:	e8 7f c9 ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c0104471:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104478:	e8 f7 0d 00 00       	call   c0105274 <alloc_pages>
c010447d:	85 c0                	test   %eax,%eax
c010447f:	74 24                	je     c01044a5 <default_check+0x32d>
c0104481:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c0104488:	c0 
c0104489:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104490:	c0 
c0104491:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104498:	00 
c0104499:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01044a0:	e8 4b c9 ff ff       	call   c0100df0 <__panic>
    assert(p0 + 2 == p1);
c01044a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044a8:	83 c0 40             	add    $0x40,%eax
c01044ab:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01044ae:	74 24                	je     c01044d4 <default_check+0x35c>
c01044b0:	c7 44 24 0c e6 d5 10 	movl   $0xc010d5e6,0xc(%esp)
c01044b7:	c0 
c01044b8:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01044bf:	c0 
c01044c0:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c01044c7:	00 
c01044c8:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01044cf:	e8 1c c9 ff ff       	call   c0100df0 <__panic>

    p2 = p0 + 1;
c01044d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044d7:	83 c0 20             	add    $0x20,%eax
c01044da:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01044dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044e4:	00 
c01044e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044e8:	89 04 24             	mov    %eax,(%esp)
c01044eb:	e8 f1 0d 00 00       	call   c01052e1 <free_pages>
    free_pages(p1, 3);
c01044f0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01044f7:	00 
c01044f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044fb:	89 04 24             	mov    %eax,(%esp)
c01044fe:	e8 de 0d 00 00       	call   c01052e1 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104503:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104506:	83 c0 04             	add    $0x4,%eax
c0104509:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104510:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104513:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104516:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104519:	0f a3 10             	bt     %edx,(%eax)
c010451c:	19 c0                	sbb    %eax,%eax
c010451e:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104521:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104525:	0f 95 c0             	setne  %al
c0104528:	0f b6 c0             	movzbl %al,%eax
c010452b:	85 c0                	test   %eax,%eax
c010452d:	74 0b                	je     c010453a <default_check+0x3c2>
c010452f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104532:	8b 40 08             	mov    0x8(%eax),%eax
c0104535:	83 f8 01             	cmp    $0x1,%eax
c0104538:	74 24                	je     c010455e <default_check+0x3e6>
c010453a:	c7 44 24 0c f4 d5 10 	movl   $0xc010d5f4,0xc(%esp)
c0104541:	c0 
c0104542:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104549:	c0 
c010454a:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0104551:	00 
c0104552:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104559:	e8 92 c8 ff ff       	call   c0100df0 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010455e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104561:	83 c0 04             	add    $0x4,%eax
c0104564:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010456b:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010456e:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104571:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104574:	0f a3 10             	bt     %edx,(%eax)
c0104577:	19 c0                	sbb    %eax,%eax
c0104579:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010457c:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104580:	0f 95 c0             	setne  %al
c0104583:	0f b6 c0             	movzbl %al,%eax
c0104586:	85 c0                	test   %eax,%eax
c0104588:	74 0b                	je     c0104595 <default_check+0x41d>
c010458a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010458d:	8b 40 08             	mov    0x8(%eax),%eax
c0104590:	83 f8 03             	cmp    $0x3,%eax
c0104593:	74 24                	je     c01045b9 <default_check+0x441>
c0104595:	c7 44 24 0c 1c d6 10 	movl   $0xc010d61c,0xc(%esp)
c010459c:	c0 
c010459d:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01045a4:	c0 
c01045a5:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01045ac:	00 
c01045ad:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01045b4:	e8 37 c8 ff ff       	call   c0100df0 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01045b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01045c0:	e8 af 0c 00 00       	call   c0105274 <alloc_pages>
c01045c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01045c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045cb:	83 e8 20             	sub    $0x20,%eax
c01045ce:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01045d1:	74 24                	je     c01045f7 <default_check+0x47f>
c01045d3:	c7 44 24 0c 42 d6 10 	movl   $0xc010d642,0xc(%esp)
c01045da:	c0 
c01045db:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01045e2:	c0 
c01045e3:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01045ea:	00 
c01045eb:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01045f2:	e8 f9 c7 ff ff       	call   c0100df0 <__panic>
    free_page(p0);
c01045f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01045fe:	00 
c01045ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104602:	89 04 24             	mov    %eax,(%esp)
c0104605:	e8 d7 0c 00 00       	call   c01052e1 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010460a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104611:	e8 5e 0c 00 00       	call   c0105274 <alloc_pages>
c0104616:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104619:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010461c:	83 c0 20             	add    $0x20,%eax
c010461f:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104622:	74 24                	je     c0104648 <default_check+0x4d0>
c0104624:	c7 44 24 0c 60 d6 10 	movl   $0xc010d660,0xc(%esp)
c010462b:	c0 
c010462c:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104633:	c0 
c0104634:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c010463b:	00 
c010463c:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104643:	e8 a8 c7 ff ff       	call   c0100df0 <__panic>

    free_pages(p0, 2);
c0104648:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010464f:	00 
c0104650:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104653:	89 04 24             	mov    %eax,(%esp)
c0104656:	e8 86 0c 00 00       	call   c01052e1 <free_pages>
    free_page(p2);
c010465b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104662:	00 
c0104663:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104666:	89 04 24             	mov    %eax,(%esp)
c0104669:	e8 73 0c 00 00       	call   c01052e1 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010466e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104675:	e8 fa 0b 00 00       	call   c0105274 <alloc_pages>
c010467a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010467d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104681:	75 24                	jne    c01046a7 <default_check+0x52f>
c0104683:	c7 44 24 0c 80 d6 10 	movl   $0xc010d680,0xc(%esp)
c010468a:	c0 
c010468b:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104692:	c0 
c0104693:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c010469a:	00 
c010469b:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01046a2:	e8 49 c7 ff ff       	call   c0100df0 <__panic>
    assert(alloc_page() == NULL);
c01046a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046ae:	e8 c1 0b 00 00       	call   c0105274 <alloc_pages>
c01046b3:	85 c0                	test   %eax,%eax
c01046b5:	74 24                	je     c01046db <default_check+0x563>
c01046b7:	c7 44 24 0c de d4 10 	movl   $0xc010d4de,0xc(%esp)
c01046be:	c0 
c01046bf:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01046c6:	c0 
c01046c7:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c01046ce:	00 
c01046cf:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01046d6:	e8 15 c7 ff ff       	call   c0100df0 <__panic>

    assert(nr_free == 0);
c01046db:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c01046e0:	85 c0                	test   %eax,%eax
c01046e2:	74 24                	je     c0104708 <default_check+0x590>
c01046e4:	c7 44 24 0c 31 d5 10 	movl   $0xc010d531,0xc(%esp)
c01046eb:	c0 
c01046ec:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01046f3:	c0 
c01046f4:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01046fb:	00 
c01046fc:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104703:	e8 e8 c6 ff ff       	call   c0100df0 <__panic>
    nr_free = nr_free_store;
c0104708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010470b:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c

    free_list = free_list_store;
c0104710:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104713:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104716:	a3 84 7f 1b c0       	mov    %eax,0xc01b7f84
c010471b:	89 15 88 7f 1b c0    	mov    %edx,0xc01b7f88
    free_pages(p0, 5);
c0104721:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104728:	00 
c0104729:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010472c:	89 04 24             	mov    %eax,(%esp)
c010472f:	e8 ad 0b 00 00       	call   c01052e1 <free_pages>

    le = &free_list;
c0104734:	c7 45 ec 84 7f 1b c0 	movl   $0xc01b7f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010473b:	eb 1c                	jmp    c0104759 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
c010473d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104740:	83 e8 0c             	sub    $0xc,%eax
c0104743:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0104746:	ff 4d f4             	decl   -0xc(%ebp)
c0104749:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010474c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010474f:	8b 48 08             	mov    0x8(%eax),%ecx
c0104752:	89 d0                	mov    %edx,%eax
c0104754:	29 c8                	sub    %ecx,%eax
c0104756:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104759:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010475c:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010475f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104762:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104765:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104768:	81 7d ec 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x14(%ebp)
c010476f:	75 cc                	jne    c010473d <default_check+0x5c5>
    }
    assert(count == 0);
c0104771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104775:	74 24                	je     c010479b <default_check+0x623>
c0104777:	c7 44 24 0c 9e d6 10 	movl   $0xc010d69e,0xc(%esp)
c010477e:	c0 
c010477f:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c0104786:	c0 
c0104787:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c010478e:	00 
c010478f:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c0104796:	e8 55 c6 ff ff       	call   c0100df0 <__panic>
    assert(total == 0);
c010479b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010479f:	74 24                	je     c01047c5 <default_check+0x64d>
c01047a1:	c7 44 24 0c a9 d6 10 	movl   $0xc010d6a9,0xc(%esp)
c01047a8:	c0 
c01047a9:	c7 44 24 08 56 d3 10 	movl   $0xc010d356,0x8(%esp)
c01047b0:	c0 
c01047b1:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c01047b8:	00 
c01047b9:	c7 04 24 6b d3 10 c0 	movl   $0xc010d36b,(%esp)
c01047c0:	e8 2b c6 ff ff       	call   c0100df0 <__panic>
}
c01047c5:	90                   	nop
c01047c6:	89 ec                	mov    %ebp,%esp
c01047c8:	5d                   	pop    %ebp
c01047c9:	c3                   	ret    

c01047ca <__intr_save>:
__intr_save(void) {
c01047ca:	55                   	push   %ebp
c01047cb:	89 e5                	mov    %esp,%ebp
c01047cd:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01047d0:	9c                   	pushf  
c01047d1:	58                   	pop    %eax
c01047d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01047d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01047d8:	25 00 02 00 00       	and    $0x200,%eax
c01047dd:	85 c0                	test   %eax,%eax
c01047df:	74 0c                	je     c01047ed <__intr_save+0x23>
        intr_disable();
c01047e1:	e8 c0 d8 ff ff       	call   c01020a6 <intr_disable>
        return 1;
c01047e6:	b8 01 00 00 00       	mov    $0x1,%eax
c01047eb:	eb 05                	jmp    c01047f2 <__intr_save+0x28>
    return 0;
c01047ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01047f2:	89 ec                	mov    %ebp,%esp
c01047f4:	5d                   	pop    %ebp
c01047f5:	c3                   	ret    

c01047f6 <__intr_restore>:
__intr_restore(bool flag) {
c01047f6:	55                   	push   %ebp
c01047f7:	89 e5                	mov    %esp,%ebp
c01047f9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01047fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104800:	74 05                	je     c0104807 <__intr_restore+0x11>
        intr_enable();
c0104802:	e8 97 d8 ff ff       	call   c010209e <intr_enable>
}
c0104807:	90                   	nop
c0104808:	89 ec                	mov    %ebp,%esp
c010480a:	5d                   	pop    %ebp
c010480b:	c3                   	ret    

c010480c <page2ppn>:
page2ppn(struct Page *page) {
c010480c:	55                   	push   %ebp
c010480d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010480f:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0104815:	8b 45 08             	mov    0x8(%ebp),%eax
c0104818:	29 d0                	sub    %edx,%eax
c010481a:	c1 f8 05             	sar    $0x5,%eax
}
c010481d:	5d                   	pop    %ebp
c010481e:	c3                   	ret    

c010481f <page2pa>:
page2pa(struct Page *page) {
c010481f:	55                   	push   %ebp
c0104820:	89 e5                	mov    %esp,%ebp
c0104822:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104825:	8b 45 08             	mov    0x8(%ebp),%eax
c0104828:	89 04 24             	mov    %eax,(%esp)
c010482b:	e8 dc ff ff ff       	call   c010480c <page2ppn>
c0104830:	c1 e0 0c             	shl    $0xc,%eax
}
c0104833:	89 ec                	mov    %ebp,%esp
c0104835:	5d                   	pop    %ebp
c0104836:	c3                   	ret    

c0104837 <pa2page>:
pa2page(uintptr_t pa) {
c0104837:	55                   	push   %ebp
c0104838:	89 e5                	mov    %esp,%ebp
c010483a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010483d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104840:	c1 e8 0c             	shr    $0xc,%eax
c0104843:	89 c2                	mov    %eax,%edx
c0104845:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c010484a:	39 c2                	cmp    %eax,%edx
c010484c:	72 1c                	jb     c010486a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010484e:	c7 44 24 08 e4 d6 10 	movl   $0xc010d6e4,0x8(%esp)
c0104855:	c0 
c0104856:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010485d:	00 
c010485e:	c7 04 24 03 d7 10 c0 	movl   $0xc010d703,(%esp)
c0104865:	e8 86 c5 ff ff       	call   c0100df0 <__panic>
    return &pages[PPN(pa)];
c010486a:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0104870:	8b 45 08             	mov    0x8(%ebp),%eax
c0104873:	c1 e8 0c             	shr    $0xc,%eax
c0104876:	c1 e0 05             	shl    $0x5,%eax
c0104879:	01 d0                	add    %edx,%eax
}
c010487b:	89 ec                	mov    %ebp,%esp
c010487d:	5d                   	pop    %ebp
c010487e:	c3                   	ret    

c010487f <page2kva>:
page2kva(struct Page *page) {
c010487f:	55                   	push   %ebp
c0104880:	89 e5                	mov    %esp,%ebp
c0104882:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104885:	8b 45 08             	mov    0x8(%ebp),%eax
c0104888:	89 04 24             	mov    %eax,(%esp)
c010488b:	e8 8f ff ff ff       	call   c010481f <page2pa>
c0104890:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104896:	c1 e8 0c             	shr    $0xc,%eax
c0104899:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010489c:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01048a1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048a4:	72 23                	jb     c01048c9 <page2kva+0x4a>
c01048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048ad:	c7 44 24 08 14 d7 10 	movl   $0xc010d714,0x8(%esp)
c01048b4:	c0 
c01048b5:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01048bc:	00 
c01048bd:	c7 04 24 03 d7 10 c0 	movl   $0xc010d703,(%esp)
c01048c4:	e8 27 c5 ff ff       	call   c0100df0 <__panic>
c01048c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048cc:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01048d1:	89 ec                	mov    %ebp,%esp
c01048d3:	5d                   	pop    %ebp
c01048d4:	c3                   	ret    

c01048d5 <kva2page>:
kva2page(void *kva) {
c01048d5:	55                   	push   %ebp
c01048d6:	89 e5                	mov    %esp,%ebp
c01048d8:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01048db:	8b 45 08             	mov    0x8(%ebp),%eax
c01048de:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01048e1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01048e8:	77 23                	ja     c010490d <kva2page+0x38>
c01048ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048f1:	c7 44 24 08 38 d7 10 	movl   $0xc010d738,0x8(%esp)
c01048f8:	c0 
c01048f9:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0104900:	00 
c0104901:	c7 04 24 03 d7 10 c0 	movl   $0xc010d703,(%esp)
c0104908:	e8 e3 c4 ff ff       	call   c0100df0 <__panic>
c010490d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104910:	05 00 00 00 40       	add    $0x40000000,%eax
c0104915:	89 04 24             	mov    %eax,(%esp)
c0104918:	e8 1a ff ff ff       	call   c0104837 <pa2page>
}
c010491d:	89 ec                	mov    %ebp,%esp
c010491f:	5d                   	pop    %ebp
c0104920:	c3                   	ret    

c0104921 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104921:	55                   	push   %ebp
c0104922:	89 e5                	mov    %esp,%ebp
c0104924:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104927:	8b 45 0c             	mov    0xc(%ebp),%eax
c010492a:	ba 01 00 00 00       	mov    $0x1,%edx
c010492f:	88 c1                	mov    %al,%cl
c0104931:	d3 e2                	shl    %cl,%edx
c0104933:	89 d0                	mov    %edx,%eax
c0104935:	89 04 24             	mov    %eax,(%esp)
c0104938:	e8 37 09 00 00       	call   c0105274 <alloc_pages>
c010493d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104940:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104944:	75 07                	jne    c010494d <__slob_get_free_pages+0x2c>
    return NULL;
c0104946:	b8 00 00 00 00       	mov    $0x0,%eax
c010494b:	eb 0b                	jmp    c0104958 <__slob_get_free_pages+0x37>
  return page2kva(page);
c010494d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104950:	89 04 24             	mov    %eax,(%esp)
c0104953:	e8 27 ff ff ff       	call   c010487f <page2kva>
}
c0104958:	89 ec                	mov    %ebp,%esp
c010495a:	5d                   	pop    %ebp
c010495b:	c3                   	ret    

c010495c <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c010495c:	55                   	push   %ebp
c010495d:	89 e5                	mov    %esp,%ebp
c010495f:	83 ec 18             	sub    $0x18,%esp
c0104962:	89 5d fc             	mov    %ebx,-0x4(%ebp)
  free_pages(kva2page(kva), 1 << order);
c0104965:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104968:	ba 01 00 00 00       	mov    $0x1,%edx
c010496d:	88 c1                	mov    %al,%cl
c010496f:	d3 e2                	shl    %cl,%edx
c0104971:	89 d0                	mov    %edx,%eax
c0104973:	89 c3                	mov    %eax,%ebx
c0104975:	8b 45 08             	mov    0x8(%ebp),%eax
c0104978:	89 04 24             	mov    %eax,(%esp)
c010497b:	e8 55 ff ff ff       	call   c01048d5 <kva2page>
c0104980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104984:	89 04 24             	mov    %eax,(%esp)
c0104987:	e8 55 09 00 00       	call   c01052e1 <free_pages>
}
c010498c:	90                   	nop
c010498d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104990:	89 ec                	mov    %ebp,%esp
c0104992:	5d                   	pop    %ebp
c0104993:	c3                   	ret    

c0104994 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104994:	55                   	push   %ebp
c0104995:	89 e5                	mov    %esp,%ebp
c0104997:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010499a:	8b 45 08             	mov    0x8(%ebp),%eax
c010499d:	83 c0 08             	add    $0x8,%eax
c01049a0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c01049a5:	76 24                	jbe    c01049cb <slob_alloc+0x37>
c01049a7:	c7 44 24 0c 5c d7 10 	movl   $0xc010d75c,0xc(%esp)
c01049ae:	c0 
c01049af:	c7 44 24 08 7b d7 10 	movl   $0xc010d77b,0x8(%esp)
c01049b6:	c0 
c01049b7:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01049be:	00 
c01049bf:	c7 04 24 90 d7 10 c0 	movl   $0xc010d790,(%esp)
c01049c6:	e8 25 c4 ff ff       	call   c0100df0 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c01049cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01049d2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01049d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01049dc:	83 c0 07             	add    $0x7,%eax
c01049df:	c1 e8 03             	shr    $0x3,%eax
c01049e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01049e5:	e8 e0 fd ff ff       	call   c01047ca <__intr_save>
c01049ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01049ed:	a1 e8 39 13 c0       	mov    0xc01339e8,%eax
c01049f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01049f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f8:	8b 40 04             	mov    0x4(%eax),%eax
c01049fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01049fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104a02:	74 21                	je     c0104a25 <slob_alloc+0x91>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104a04:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a07:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a0a:	01 d0                	add    %edx,%eax
c0104a0c:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104a0f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104a12:	f7 d8                	neg    %eax
c0104a14:	21 d0                	and    %edx,%eax
c0104a16:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104a19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a1c:	2b 45 f0             	sub    -0x10(%ebp),%eax
c0104a1f:	c1 f8 03             	sar    $0x3,%eax
c0104a22:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a28:	8b 00                	mov    (%eax),%eax
c0104a2a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104a2d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a30:	01 ca                	add    %ecx,%edx
c0104a32:	39 d0                	cmp    %edx,%eax
c0104a34:	0f 8c aa 00 00 00    	jl     c0104ae4 <slob_alloc+0x150>
			if (delta) { /* need to fragment head to align? */
c0104a3a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104a3e:	74 38                	je     c0104a78 <slob_alloc+0xe4>
				aligned->units = cur->units - delta;
c0104a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a43:	8b 00                	mov    (%eax),%eax
c0104a45:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104a48:	89 c2                	mov    %eax,%edx
c0104a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a4d:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a52:	8b 50 04             	mov    0x4(%eax),%edx
c0104a55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a58:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a5e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a61:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a67:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a6a:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104a72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a75:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a7b:	8b 00                	mov    (%eax),%eax
c0104a7d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104a80:	75 0e                	jne    c0104a90 <slob_alloc+0xfc>
				prev->next = cur->next; /* unlink */
c0104a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a85:	8b 50 04             	mov    0x4(%eax),%edx
c0104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a8b:	89 50 04             	mov    %edx,0x4(%eax)
c0104a8e:	eb 3c                	jmp    c0104acc <slob_alloc+0x138>
			else { /* fragment */
				prev->next = cur + units;
c0104a90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a93:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a9d:	01 c2                	add    %eax,%edx
c0104a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aa2:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104aa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa8:	8b 10                	mov    (%eax),%edx
c0104aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aad:	8b 40 04             	mov    0x4(%eax),%eax
c0104ab0:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104ab3:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ab8:	8b 40 04             	mov    0x4(%eax),%eax
c0104abb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104abe:	8b 52 04             	mov    0x4(%edx),%edx
c0104ac1:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ac7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104aca:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104acf:	a3 e8 39 13 c0       	mov    %eax,0xc01339e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ad4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ad7:	89 04 24             	mov    %eax,(%esp)
c0104ada:	e8 17 fd ff ff       	call   c01047f6 <__intr_restore>
			return cur;
c0104adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ae2:	eb 7f                	jmp    c0104b63 <slob_alloc+0x1cf>
		}
		if (cur == slobfree) {
c0104ae4:	a1 e8 39 13 c0       	mov    0xc01339e8,%eax
c0104ae9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104aec:	75 61                	jne    c0104b4f <slob_alloc+0x1bb>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104af1:	89 04 24             	mov    %eax,(%esp)
c0104af4:	e8 fd fc ff ff       	call   c01047f6 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104af9:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104b00:	75 07                	jne    c0104b09 <slob_alloc+0x175>
				return 0;
c0104b02:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b07:	eb 5a                	jmp    c0104b63 <slob_alloc+0x1cf>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104b09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b10:	00 
c0104b11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b14:	89 04 24             	mov    %eax,(%esp)
c0104b17:	e8 05 fe ff ff       	call   c0104921 <__slob_get_free_pages>
c0104b1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104b1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b23:	75 07                	jne    c0104b2c <slob_alloc+0x198>
				return 0;
c0104b25:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b2a:	eb 37                	jmp    c0104b63 <slob_alloc+0x1cf>

			slob_free(cur, PAGE_SIZE);
c0104b2c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b33:	00 
c0104b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b37:	89 04 24             	mov    %eax,(%esp)
c0104b3a:	e8 28 00 00 00       	call   c0104b67 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104b3f:	e8 86 fc ff ff       	call   c01047ca <__intr_save>
c0104b44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104b47:	a1 e8 39 13 c0       	mov    0xc01339e8,%eax
c0104b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104b4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b58:	8b 40 04             	mov    0x4(%eax),%eax
c0104b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104b5e:	e9 9b fe ff ff       	jmp    c01049fe <slob_alloc+0x6a>
		}
	}
}
c0104b63:	89 ec                	mov    %ebp,%esp
c0104b65:	5d                   	pop    %ebp
c0104b66:	c3                   	ret    

c0104b67 <slob_free>:

static void slob_free(void *block, int size)
{
c0104b67:	55                   	push   %ebp
c0104b68:	89 e5                	mov    %esp,%ebp
c0104b6a:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104b73:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104b77:	0f 84 01 01 00 00    	je     c0104c7e <slob_free+0x117>
		return;

	if (size)
c0104b7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104b81:	74 10                	je     c0104b93 <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c0104b83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b86:	83 c0 07             	add    $0x7,%eax
c0104b89:	c1 e8 03             	shr    $0x3,%eax
c0104b8c:	89 c2                	mov    %eax,%edx
c0104b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b91:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104b93:	e8 32 fc ff ff       	call   c01047ca <__intr_save>
c0104b98:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104b9b:	a1 e8 39 13 c0       	mov    0xc01339e8,%eax
c0104ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ba3:	eb 27                	jmp    c0104bcc <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ba8:	8b 40 04             	mov    0x4(%eax),%eax
c0104bab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104bae:	72 13                	jb     c0104bc3 <slob_free+0x5c>
c0104bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bb3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bb6:	77 27                	ja     c0104bdf <slob_free+0x78>
c0104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bbb:	8b 40 04             	mov    0x4(%eax),%eax
c0104bbe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104bc1:	72 1c                	jb     c0104bdf <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bc6:	8b 40 04             	mov    0x4(%eax),%eax
c0104bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bcf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bd2:	76 d1                	jbe    c0104ba5 <slob_free+0x3e>
c0104bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd7:	8b 40 04             	mov    0x4(%eax),%eax
c0104bda:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104bdd:	73 c6                	jae    c0104ba5 <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0104bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104be2:	8b 00                	mov    (%eax),%eax
c0104be4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bee:	01 c2                	add    %eax,%edx
c0104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bf3:	8b 40 04             	mov    0x4(%eax),%eax
c0104bf6:	39 c2                	cmp    %eax,%edx
c0104bf8:	75 25                	jne    c0104c1f <slob_free+0xb8>
		b->units += cur->next->units;
c0104bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bfd:	8b 10                	mov    (%eax),%edx
c0104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c02:	8b 40 04             	mov    0x4(%eax),%eax
c0104c05:	8b 00                	mov    (%eax),%eax
c0104c07:	01 c2                	add    %eax,%edx
c0104c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c0c:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c11:	8b 40 04             	mov    0x4(%eax),%eax
c0104c14:	8b 50 04             	mov    0x4(%eax),%edx
c0104c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c1a:	89 50 04             	mov    %edx,0x4(%eax)
c0104c1d:	eb 0c                	jmp    c0104c2b <slob_free+0xc4>
	} else
		b->next = cur->next;
c0104c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c22:	8b 50 04             	mov    0x4(%eax),%edx
c0104c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c28:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c2e:	8b 00                	mov    (%eax),%eax
c0104c30:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3a:	01 d0                	add    %edx,%eax
c0104c3c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104c3f:	75 1f                	jne    c0104c60 <slob_free+0xf9>
		cur->units += b->units;
c0104c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c44:	8b 10                	mov    (%eax),%edx
c0104c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c49:	8b 00                	mov    (%eax),%eax
c0104c4b:	01 c2                	add    %eax,%edx
c0104c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c50:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c55:	8b 50 04             	mov    0x4(%eax),%edx
c0104c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5b:	89 50 04             	mov    %edx,0x4(%eax)
c0104c5e:	eb 09                	jmp    c0104c69 <slob_free+0x102>
	} else
		cur->next = b;
c0104c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c63:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104c66:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c6c:	a3 e8 39 13 c0       	mov    %eax,0xc01339e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c74:	89 04 24             	mov    %eax,(%esp)
c0104c77:	e8 7a fb ff ff       	call   c01047f6 <__intr_restore>
c0104c7c:	eb 01                	jmp    c0104c7f <slob_free+0x118>
		return;
c0104c7e:	90                   	nop
}
c0104c7f:	89 ec                	mov    %ebp,%esp
c0104c81:	5d                   	pop    %ebp
c0104c82:	c3                   	ret    

c0104c83 <slob_init>:



void
slob_init(void) {
c0104c83:	55                   	push   %ebp
c0104c84:	89 e5                	mov    %esp,%ebp
c0104c86:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104c89:	c7 04 24 a2 d7 10 c0 	movl   $0xc010d7a2,(%esp)
c0104c90:	e8 dd b6 ff ff       	call   c0100372 <cprintf>
}
c0104c95:	90                   	nop
c0104c96:	89 ec                	mov    %ebp,%esp
c0104c98:	5d                   	pop    %ebp
c0104c99:	c3                   	ret    

c0104c9a <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104c9a:	55                   	push   %ebp
c0104c9b:	89 e5                	mov    %esp,%ebp
c0104c9d:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104ca0:	e8 de ff ff ff       	call   c0104c83 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104ca5:	c7 04 24 b6 d7 10 c0 	movl   $0xc010d7b6,(%esp)
c0104cac:	e8 c1 b6 ff ff       	call   c0100372 <cprintf>
}
c0104cb1:	90                   	nop
c0104cb2:	89 ec                	mov    %ebp,%esp
c0104cb4:	5d                   	pop    %ebp
c0104cb5:	c3                   	ret    

c0104cb6 <slob_allocated>:

size_t
slob_allocated(void) {
c0104cb6:	55                   	push   %ebp
c0104cb7:	89 e5                	mov    %esp,%ebp
  return 0;
c0104cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104cbe:	5d                   	pop    %ebp
c0104cbf:	c3                   	ret    

c0104cc0 <kallocated>:

size_t
kallocated(void) {
c0104cc0:	55                   	push   %ebp
c0104cc1:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104cc3:	e8 ee ff ff ff       	call   c0104cb6 <slob_allocated>
}
c0104cc8:	5d                   	pop    %ebp
c0104cc9:	c3                   	ret    

c0104cca <find_order>:

static int find_order(int size)
{
c0104cca:	55                   	push   %ebp
c0104ccb:	89 e5                	mov    %esp,%ebp
c0104ccd:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104cd0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104cd7:	eb 06                	jmp    c0104cdf <find_order+0x15>
		order++;
c0104cd9:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104cdc:	d1 7d 08             	sarl   0x8(%ebp)
c0104cdf:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104ce6:	7f f1                	jg     c0104cd9 <find_order+0xf>
	return order;
c0104ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104ceb:	89 ec                	mov    %ebp,%esp
c0104ced:	5d                   	pop    %ebp
c0104cee:	c3                   	ret    

c0104cef <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104cef:	55                   	push   %ebp
c0104cf0:	89 e5                	mov    %esp,%ebp
c0104cf2:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104cf5:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104cfc:	77 3b                	ja     c0104d39 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104cfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d01:	8d 50 08             	lea    0x8(%eax),%edx
c0104d04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d0b:	00 
c0104d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d13:	89 14 24             	mov    %edx,(%esp)
c0104d16:	e8 79 fc ff ff       	call   c0104994 <slob_alloc>
c0104d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104d1e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d22:	74 0b                	je     c0104d2f <__kmalloc+0x40>
c0104d24:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d27:	83 c0 08             	add    $0x8,%eax
c0104d2a:	e9 b0 00 00 00       	jmp    c0104ddf <__kmalloc+0xf0>
c0104d2f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d34:	e9 a6 00 00 00       	jmp    c0104ddf <__kmalloc+0xf0>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104d39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d40:	00 
c0104d41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d48:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104d4f:	e8 40 fc ff ff       	call   c0104994 <slob_alloc>
c0104d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0104d57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d5b:	75 07                	jne    c0104d64 <__kmalloc+0x75>
		return 0;
c0104d5d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d62:	eb 7b                	jmp    c0104ddf <__kmalloc+0xf0>

	bb->order = find_order(size);
c0104d64:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d67:	89 04 24             	mov    %eax,(%esp)
c0104d6a:	e8 5b ff ff ff       	call   c0104cca <find_order>
c0104d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104d72:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d77:	8b 00                	mov    (%eax),%eax
c0104d79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d80:	89 04 24             	mov    %eax,(%esp)
c0104d83:	e8 99 fb ff ff       	call   c0104921 <__slob_get_free_pages>
c0104d88:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104d8b:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d91:	8b 40 04             	mov    0x4(%eax),%eax
c0104d94:	85 c0                	test   %eax,%eax
c0104d96:	74 2f                	je     c0104dc7 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c0104d98:	e8 2d fa ff ff       	call   c01047ca <__intr_save>
c0104d9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104da0:	8b 15 90 7f 1b c0    	mov    0xc01b7f90,%edx
c0104da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104da9:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104daf:	a3 90 7f 1b c0       	mov    %eax,0xc01b7f90
		spin_unlock_irqrestore(&block_lock, flags);
c0104db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104db7:	89 04 24             	mov    %eax,(%esp)
c0104dba:	e8 37 fa ff ff       	call   c01047f6 <__intr_restore>
		return bb->pages;
c0104dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dc2:	8b 40 04             	mov    0x4(%eax),%eax
c0104dc5:	eb 18                	jmp    c0104ddf <__kmalloc+0xf0>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104dc7:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104dce:	00 
c0104dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd2:	89 04 24             	mov    %eax,(%esp)
c0104dd5:	e8 8d fd ff ff       	call   c0104b67 <slob_free>
	return 0;
c0104dda:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ddf:	89 ec                	mov    %ebp,%esp
c0104de1:	5d                   	pop    %ebp
c0104de2:	c3                   	ret    

c0104de3 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104de3:	55                   	push   %ebp
c0104de4:	89 e5                	mov    %esp,%ebp
c0104de6:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104de9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104df0:	00 
c0104df1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104df4:	89 04 24             	mov    %eax,(%esp)
c0104df7:	e8 f3 fe ff ff       	call   c0104cef <__kmalloc>
}
c0104dfc:	89 ec                	mov    %ebp,%esp
c0104dfe:	5d                   	pop    %ebp
c0104dff:	c3                   	ret    

c0104e00 <kfree>:


void kfree(void *block)
{
c0104e00:	55                   	push   %ebp
c0104e01:	89 e5                	mov    %esp,%ebp
c0104e03:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104e06:	c7 45 f0 90 7f 1b c0 	movl   $0xc01b7f90,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104e0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104e11:	0f 84 a3 00 00 00    	je     c0104eba <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e1a:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104e1f:	85 c0                	test   %eax,%eax
c0104e21:	75 7f                	jne    c0104ea2 <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104e23:	e8 a2 f9 ff ff       	call   c01047ca <__intr_save>
c0104e28:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104e2b:	a1 90 7f 1b c0       	mov    0xc01b7f90,%eax
c0104e30:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e33:	eb 5c                	jmp    c0104e91 <kfree+0x91>
			if (bb->pages == block) {
c0104e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e38:	8b 40 04             	mov    0x4(%eax),%eax
c0104e3b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104e3e:	75 3f                	jne    c0104e7f <kfree+0x7f>
				*last = bb->next;
c0104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e43:	8b 50 08             	mov    0x8(%eax),%edx
c0104e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e49:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e4e:	89 04 24             	mov    %eax,(%esp)
c0104e51:	e8 a0 f9 ff ff       	call   c01047f6 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e59:	8b 10                	mov    (%eax),%edx
c0104e5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e5e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e62:	89 04 24             	mov    %eax,(%esp)
c0104e65:	e8 f2 fa ff ff       	call   c010495c <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104e6a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104e71:	00 
c0104e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e75:	89 04 24             	mov    %eax,(%esp)
c0104e78:	e8 ea fc ff ff       	call   c0104b67 <slob_free>
				return;
c0104e7d:	eb 3c                	jmp    c0104ebb <kfree+0xbb>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e82:	83 c0 08             	add    $0x8,%eax
c0104e85:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e8b:	8b 40 08             	mov    0x8(%eax),%eax
c0104e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e95:	75 9e                	jne    c0104e35 <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104e97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e9a:	89 04 24             	mov    %eax,(%esp)
c0104e9d:	e8 54 f9 ff ff       	call   c01047f6 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104ea2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ea5:	83 e8 08             	sub    $0x8,%eax
c0104ea8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104eaf:	00 
c0104eb0:	89 04 24             	mov    %eax,(%esp)
c0104eb3:	e8 af fc ff ff       	call   c0104b67 <slob_free>
	return;
c0104eb8:	eb 01                	jmp    c0104ebb <kfree+0xbb>
		return;
c0104eba:	90                   	nop
}
c0104ebb:	89 ec                	mov    %ebp,%esp
c0104ebd:	5d                   	pop    %ebp
c0104ebe:	c3                   	ret    

c0104ebf <ksize>:


unsigned int ksize(const void *block)
{
c0104ebf:	55                   	push   %ebp
c0104ec0:	89 e5                	mov    %esp,%ebp
c0104ec2:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104ec5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ec9:	75 07                	jne    c0104ed2 <ksize+0x13>
		return 0;
c0104ecb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ed0:	eb 6b                	jmp    c0104f3d <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104ed2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ed5:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104eda:	85 c0                	test   %eax,%eax
c0104edc:	75 54                	jne    c0104f32 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104ede:	e8 e7 f8 ff ff       	call   c01047ca <__intr_save>
c0104ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104ee6:	a1 90 7f 1b c0       	mov    0xc01b7f90,%eax
c0104eeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104eee:	eb 31                	jmp    c0104f21 <ksize+0x62>
			if (bb->pages == block) {
c0104ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef3:	8b 40 04             	mov    0x4(%eax),%eax
c0104ef6:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104ef9:	75 1d                	jne    c0104f18 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104efe:	89 04 24             	mov    %eax,(%esp)
c0104f01:	e8 f0 f8 ff ff       	call   c01047f6 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f09:	8b 00                	mov    (%eax),%eax
c0104f0b:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104f10:	88 c1                	mov    %al,%cl
c0104f12:	d3 e2                	shl    %cl,%edx
c0104f14:	89 d0                	mov    %edx,%eax
c0104f16:	eb 25                	jmp    c0104f3d <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0104f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f1b:	8b 40 08             	mov    0x8(%eax),%eax
c0104f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f25:	75 c9                	jne    c0104ef0 <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f2a:	89 04 24             	mov    %eax,(%esp)
c0104f2d:	e8 c4 f8 ff ff       	call   c01047f6 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104f32:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f35:	83 e8 08             	sub    $0x8,%eax
c0104f38:	8b 00                	mov    (%eax),%eax
c0104f3a:	c1 e0 03             	shl    $0x3,%eax
}
c0104f3d:	89 ec                	mov    %ebp,%esp
c0104f3f:	5d                   	pop    %ebp
c0104f40:	c3                   	ret    

c0104f41 <page2ppn>:
page2ppn(struct Page *page) {
c0104f41:	55                   	push   %ebp
c0104f42:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104f44:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f4d:	29 d0                	sub    %edx,%eax
c0104f4f:	c1 f8 05             	sar    $0x5,%eax
}
c0104f52:	5d                   	pop    %ebp
c0104f53:	c3                   	ret    

c0104f54 <page2pa>:
page2pa(struct Page *page) {
c0104f54:	55                   	push   %ebp
c0104f55:	89 e5                	mov    %esp,%ebp
c0104f57:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104f5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f5d:	89 04 24             	mov    %eax,(%esp)
c0104f60:	e8 dc ff ff ff       	call   c0104f41 <page2ppn>
c0104f65:	c1 e0 0c             	shl    $0xc,%eax
}
c0104f68:	89 ec                	mov    %ebp,%esp
c0104f6a:	5d                   	pop    %ebp
c0104f6b:	c3                   	ret    

c0104f6c <pa2page>:
pa2page(uintptr_t pa) {
c0104f6c:	55                   	push   %ebp
c0104f6d:	89 e5                	mov    %esp,%ebp
c0104f6f:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104f72:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f75:	c1 e8 0c             	shr    $0xc,%eax
c0104f78:	89 c2                	mov    %eax,%edx
c0104f7a:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0104f7f:	39 c2                	cmp    %eax,%edx
c0104f81:	72 1c                	jb     c0104f9f <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104f83:	c7 44 24 08 d4 d7 10 	movl   $0xc010d7d4,0x8(%esp)
c0104f8a:	c0 
c0104f8b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104f92:	00 
c0104f93:	c7 04 24 f3 d7 10 c0 	movl   $0xc010d7f3,(%esp)
c0104f9a:	e8 51 be ff ff       	call   c0100df0 <__panic>
    return &pages[PPN(pa)];
c0104f9f:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0104fa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fa8:	c1 e8 0c             	shr    $0xc,%eax
c0104fab:	c1 e0 05             	shl    $0x5,%eax
c0104fae:	01 d0                	add    %edx,%eax
}
c0104fb0:	89 ec                	mov    %ebp,%esp
c0104fb2:	5d                   	pop    %ebp
c0104fb3:	c3                   	ret    

c0104fb4 <page2kva>:
page2kva(struct Page *page) {
c0104fb4:	55                   	push   %ebp
c0104fb5:	89 e5                	mov    %esp,%ebp
c0104fb7:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104fba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fbd:	89 04 24             	mov    %eax,(%esp)
c0104fc0:	e8 8f ff ff ff       	call   c0104f54 <page2pa>
c0104fc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fcb:	c1 e8 0c             	shr    $0xc,%eax
c0104fce:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104fd1:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0104fd6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104fd9:	72 23                	jb     c0104ffe <page2kva+0x4a>
c0104fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fde:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104fe2:	c7 44 24 08 04 d8 10 	movl   $0xc010d804,0x8(%esp)
c0104fe9:	c0 
c0104fea:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104ff1:	00 
c0104ff2:	c7 04 24 f3 d7 10 c0 	movl   $0xc010d7f3,(%esp)
c0104ff9:	e8 f2 bd ff ff       	call   c0100df0 <__panic>
c0104ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105001:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105006:	89 ec                	mov    %ebp,%esp
c0105008:	5d                   	pop    %ebp
c0105009:	c3                   	ret    

c010500a <pte2page>:
pte2page(pte_t pte) {
c010500a:	55                   	push   %ebp
c010500b:	89 e5                	mov    %esp,%ebp
c010500d:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105010:	8b 45 08             	mov    0x8(%ebp),%eax
c0105013:	83 e0 01             	and    $0x1,%eax
c0105016:	85 c0                	test   %eax,%eax
c0105018:	75 1c                	jne    c0105036 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010501a:	c7 44 24 08 28 d8 10 	movl   $0xc010d828,0x8(%esp)
c0105021:	c0 
c0105022:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0105029:	00 
c010502a:	c7 04 24 f3 d7 10 c0 	movl   $0xc010d7f3,(%esp)
c0105031:	e8 ba bd ff ff       	call   c0100df0 <__panic>
    return pa2page(PTE_ADDR(pte));
c0105036:	8b 45 08             	mov    0x8(%ebp),%eax
c0105039:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010503e:	89 04 24             	mov    %eax,(%esp)
c0105041:	e8 26 ff ff ff       	call   c0104f6c <pa2page>
}
c0105046:	89 ec                	mov    %ebp,%esp
c0105048:	5d                   	pop    %ebp
c0105049:	c3                   	ret    

c010504a <pde2page>:
pde2page(pde_t pde) {
c010504a:	55                   	push   %ebp
c010504b:	89 e5                	mov    %esp,%ebp
c010504d:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0105050:	8b 45 08             	mov    0x8(%ebp),%eax
c0105053:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105058:	89 04 24             	mov    %eax,(%esp)
c010505b:	e8 0c ff ff ff       	call   c0104f6c <pa2page>
}
c0105060:	89 ec                	mov    %ebp,%esp
c0105062:	5d                   	pop    %ebp
c0105063:	c3                   	ret    

c0105064 <page_ref>:
page_ref(struct Page *page) {
c0105064:	55                   	push   %ebp
c0105065:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105067:	8b 45 08             	mov    0x8(%ebp),%eax
c010506a:	8b 00                	mov    (%eax),%eax
}
c010506c:	5d                   	pop    %ebp
c010506d:	c3                   	ret    

c010506e <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010506e:	55                   	push   %ebp
c010506f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105071:	8b 45 08             	mov    0x8(%ebp),%eax
c0105074:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105077:	89 10                	mov    %edx,(%eax)
}
c0105079:	90                   	nop
c010507a:	5d                   	pop    %ebp
c010507b:	c3                   	ret    

c010507c <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010507c:	55                   	push   %ebp
c010507d:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010507f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105082:	8b 00                	mov    (%eax),%eax
c0105084:	8d 50 01             	lea    0x1(%eax),%edx
c0105087:	8b 45 08             	mov    0x8(%ebp),%eax
c010508a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010508c:	8b 45 08             	mov    0x8(%ebp),%eax
c010508f:	8b 00                	mov    (%eax),%eax
}
c0105091:	5d                   	pop    %ebp
c0105092:	c3                   	ret    

c0105093 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0105093:	55                   	push   %ebp
c0105094:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0105096:	8b 45 08             	mov    0x8(%ebp),%eax
c0105099:	8b 00                	mov    (%eax),%eax
c010509b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010509e:	8b 45 08             	mov    0x8(%ebp),%eax
c01050a1:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01050a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01050a6:	8b 00                	mov    (%eax),%eax
}
c01050a8:	5d                   	pop    %ebp
c01050a9:	c3                   	ret    

c01050aa <__intr_save>:
__intr_save(void) {
c01050aa:	55                   	push   %ebp
c01050ab:	89 e5                	mov    %esp,%ebp
c01050ad:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01050b0:	9c                   	pushf  
c01050b1:	58                   	pop    %eax
c01050b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01050b8:	25 00 02 00 00       	and    $0x200,%eax
c01050bd:	85 c0                	test   %eax,%eax
c01050bf:	74 0c                	je     c01050cd <__intr_save+0x23>
        intr_disable();
c01050c1:	e8 e0 cf ff ff       	call   c01020a6 <intr_disable>
        return 1;
c01050c6:	b8 01 00 00 00       	mov    $0x1,%eax
c01050cb:	eb 05                	jmp    c01050d2 <__intr_save+0x28>
    return 0;
c01050cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01050d2:	89 ec                	mov    %ebp,%esp
c01050d4:	5d                   	pop    %ebp
c01050d5:	c3                   	ret    

c01050d6 <__intr_restore>:
__intr_restore(bool flag) {
c01050d6:	55                   	push   %ebp
c01050d7:	89 e5                	mov    %esp,%ebp
c01050d9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01050dc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01050e0:	74 05                	je     c01050e7 <__intr_restore+0x11>
        intr_enable();
c01050e2:	e8 b7 cf ff ff       	call   c010209e <intr_enable>
}
c01050e7:	90                   	nop
c01050e8:	89 ec                	mov    %ebp,%esp
c01050ea:	5d                   	pop    %ebp
c01050eb:	c3                   	ret    

c01050ec <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01050ec:	55                   	push   %ebp
c01050ed:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01050ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01050f5:	b8 23 00 00 00       	mov    $0x23,%eax
c01050fa:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01050fc:	b8 23 00 00 00       	mov    $0x23,%eax
c0105101:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0105103:	b8 10 00 00 00       	mov    $0x10,%eax
c0105108:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c010510a:	b8 10 00 00 00       	mov    $0x10,%eax
c010510f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0105111:	b8 10 00 00 00       	mov    $0x10,%eax
c0105116:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0105118:	ea 1f 51 10 c0 08 00 	ljmp   $0x8,$0xc010511f
}
c010511f:	90                   	nop
c0105120:	5d                   	pop    %ebp
c0105121:	c3                   	ret    

c0105122 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0105122:	55                   	push   %ebp
c0105123:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0105125:	8b 45 08             	mov    0x8(%ebp),%eax
c0105128:	a3 c4 7f 1b c0       	mov    %eax,0xc01b7fc4
}
c010512d:	90                   	nop
c010512e:	5d                   	pop    %ebp
c010512f:	c3                   	ret    

c0105130 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0105130:	55                   	push   %ebp
c0105131:	89 e5                	mov    %esp,%ebp
c0105133:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0105136:	b8 00 30 13 c0       	mov    $0xc0133000,%eax
c010513b:	89 04 24             	mov    %eax,(%esp)
c010513e:	e8 df ff ff ff       	call   c0105122 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0105143:	66 c7 05 c8 7f 1b c0 	movw   $0x10,0xc01b7fc8
c010514a:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010514c:	66 c7 05 48 3a 13 c0 	movw   $0x68,0xc0133a48
c0105153:	68 00 
c0105155:	b8 c0 7f 1b c0       	mov    $0xc01b7fc0,%eax
c010515a:	0f b7 c0             	movzwl %ax,%eax
c010515d:	66 a3 4a 3a 13 c0    	mov    %ax,0xc0133a4a
c0105163:	b8 c0 7f 1b c0       	mov    $0xc01b7fc0,%eax
c0105168:	c1 e8 10             	shr    $0x10,%eax
c010516b:	a2 4c 3a 13 c0       	mov    %al,0xc0133a4c
c0105170:	0f b6 05 4d 3a 13 c0 	movzbl 0xc0133a4d,%eax
c0105177:	24 f0                	and    $0xf0,%al
c0105179:	0c 09                	or     $0x9,%al
c010517b:	a2 4d 3a 13 c0       	mov    %al,0xc0133a4d
c0105180:	0f b6 05 4d 3a 13 c0 	movzbl 0xc0133a4d,%eax
c0105187:	24 ef                	and    $0xef,%al
c0105189:	a2 4d 3a 13 c0       	mov    %al,0xc0133a4d
c010518e:	0f b6 05 4d 3a 13 c0 	movzbl 0xc0133a4d,%eax
c0105195:	24 9f                	and    $0x9f,%al
c0105197:	a2 4d 3a 13 c0       	mov    %al,0xc0133a4d
c010519c:	0f b6 05 4d 3a 13 c0 	movzbl 0xc0133a4d,%eax
c01051a3:	0c 80                	or     $0x80,%al
c01051a5:	a2 4d 3a 13 c0       	mov    %al,0xc0133a4d
c01051aa:	0f b6 05 4e 3a 13 c0 	movzbl 0xc0133a4e,%eax
c01051b1:	24 f0                	and    $0xf0,%al
c01051b3:	a2 4e 3a 13 c0       	mov    %al,0xc0133a4e
c01051b8:	0f b6 05 4e 3a 13 c0 	movzbl 0xc0133a4e,%eax
c01051bf:	24 ef                	and    $0xef,%al
c01051c1:	a2 4e 3a 13 c0       	mov    %al,0xc0133a4e
c01051c6:	0f b6 05 4e 3a 13 c0 	movzbl 0xc0133a4e,%eax
c01051cd:	24 df                	and    $0xdf,%al
c01051cf:	a2 4e 3a 13 c0       	mov    %al,0xc0133a4e
c01051d4:	0f b6 05 4e 3a 13 c0 	movzbl 0xc0133a4e,%eax
c01051db:	0c 40                	or     $0x40,%al
c01051dd:	a2 4e 3a 13 c0       	mov    %al,0xc0133a4e
c01051e2:	0f b6 05 4e 3a 13 c0 	movzbl 0xc0133a4e,%eax
c01051e9:	24 7f                	and    $0x7f,%al
c01051eb:	a2 4e 3a 13 c0       	mov    %al,0xc0133a4e
c01051f0:	b8 c0 7f 1b c0       	mov    $0xc01b7fc0,%eax
c01051f5:	c1 e8 18             	shr    $0x18,%eax
c01051f8:	a2 4f 3a 13 c0       	mov    %al,0xc0133a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01051fd:	c7 04 24 50 3a 13 c0 	movl   $0xc0133a50,(%esp)
c0105204:	e8 e3 fe ff ff       	call   c01050ec <lgdt>
c0105209:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010520f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0105213:	0f 00 d8             	ltr    %ax
}
c0105216:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0105217:	90                   	nop
c0105218:	89 ec                	mov    %ebp,%esp
c010521a:	5d                   	pop    %ebp
c010521b:	c3                   	ret    

c010521c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010521c:	55                   	push   %ebp
c010521d:	89 e5                	mov    %esp,%ebp
c010521f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0105222:	c7 05 ac 7f 1b c0 c8 	movl   $0xc010d6c8,0xc01b7fac
c0105229:	d6 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010522c:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c0105231:	8b 00                	mov    (%eax),%eax
c0105233:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105237:	c7 04 24 54 d8 10 c0 	movl   $0xc010d854,(%esp)
c010523e:	e8 2f b1 ff ff       	call   c0100372 <cprintf>
    pmm_manager->init();
c0105243:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c0105248:	8b 40 04             	mov    0x4(%eax),%eax
c010524b:	ff d0                	call   *%eax
}
c010524d:	90                   	nop
c010524e:	89 ec                	mov    %ebp,%esp
c0105250:	5d                   	pop    %ebp
c0105251:	c3                   	ret    

c0105252 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0105252:	55                   	push   %ebp
c0105253:	89 e5                	mov    %esp,%ebp
c0105255:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0105258:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c010525d:	8b 40 08             	mov    0x8(%eax),%eax
c0105260:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105263:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105267:	8b 55 08             	mov    0x8(%ebp),%edx
c010526a:	89 14 24             	mov    %edx,(%esp)
c010526d:	ff d0                	call   *%eax
}
c010526f:	90                   	nop
c0105270:	89 ec                	mov    %ebp,%esp
c0105272:	5d                   	pop    %ebp
c0105273:	c3                   	ret    

c0105274 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0105274:	55                   	push   %ebp
c0105275:	89 e5                	mov    %esp,%ebp
c0105277:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c010527a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0105281:	e8 24 fe ff ff       	call   c01050aa <__intr_save>
c0105286:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0105289:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c010528e:	8b 40 0c             	mov    0xc(%eax),%eax
c0105291:	8b 55 08             	mov    0x8(%ebp),%edx
c0105294:	89 14 24             	mov    %edx,(%esp)
c0105297:	ff d0                	call   *%eax
c0105299:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010529c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010529f:	89 04 24             	mov    %eax,(%esp)
c01052a2:	e8 2f fe ff ff       	call   c01050d6 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01052a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052ab:	75 2d                	jne    c01052da <alloc_pages+0x66>
c01052ad:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01052b1:	77 27                	ja     c01052da <alloc_pages+0x66>
c01052b3:	a1 44 80 1b c0       	mov    0xc01b8044,%eax
c01052b8:	85 c0                	test   %eax,%eax
c01052ba:	74 1e                	je     c01052da <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01052bc:	8b 55 08             	mov    0x8(%ebp),%edx
c01052bf:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01052c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052cb:	00 
c01052cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052d0:	89 04 24             	mov    %eax,(%esp)
c01052d3:	e8 d7 1d 00 00       	call   c01070af <swap_out>
    {
c01052d8:	eb a7                	jmp    c0105281 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01052da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01052dd:	89 ec                	mov    %ebp,%esp
c01052df:	5d                   	pop    %ebp
c01052e0:	c3                   	ret    

c01052e1 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01052e1:	55                   	push   %ebp
c01052e2:	89 e5                	mov    %esp,%ebp
c01052e4:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01052e7:	e8 be fd ff ff       	call   c01050aa <__intr_save>
c01052ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01052ef:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c01052f4:	8b 40 10             	mov    0x10(%eax),%eax
c01052f7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01052fa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052fe:	8b 55 08             	mov    0x8(%ebp),%edx
c0105301:	89 14 24             	mov    %edx,(%esp)
c0105304:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0105306:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105309:	89 04 24             	mov    %eax,(%esp)
c010530c:	e8 c5 fd ff ff       	call   c01050d6 <__intr_restore>
}
c0105311:	90                   	nop
c0105312:	89 ec                	mov    %ebp,%esp
c0105314:	5d                   	pop    %ebp
c0105315:	c3                   	ret    

c0105316 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0105316:	55                   	push   %ebp
c0105317:	89 e5                	mov    %esp,%ebp
c0105319:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010531c:	e8 89 fd ff ff       	call   c01050aa <__intr_save>
c0105321:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0105324:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c0105329:	8b 40 14             	mov    0x14(%eax),%eax
c010532c:	ff d0                	call   *%eax
c010532e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105334:	89 04 24             	mov    %eax,(%esp)
c0105337:	e8 9a fd ff ff       	call   c01050d6 <__intr_restore>
    return ret;
c010533c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010533f:	89 ec                	mov    %ebp,%esp
c0105341:	5d                   	pop    %ebp
c0105342:	c3                   	ret    

c0105343 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0105343:	55                   	push   %ebp
c0105344:	89 e5                	mov    %esp,%ebp
c0105346:	57                   	push   %edi
c0105347:	56                   	push   %esi
c0105348:	53                   	push   %ebx
c0105349:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010534f:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105356:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010535d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105364:	c7 04 24 6b d8 10 c0 	movl   $0xc010d86b,(%esp)
c010536b:	e8 02 b0 ff ff       	call   c0100372 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105370:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105377:	e9 0c 01 00 00       	jmp    c0105488 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010537c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010537f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105382:	89 d0                	mov    %edx,%eax
c0105384:	c1 e0 02             	shl    $0x2,%eax
c0105387:	01 d0                	add    %edx,%eax
c0105389:	c1 e0 02             	shl    $0x2,%eax
c010538c:	01 c8                	add    %ecx,%eax
c010538e:	8b 50 08             	mov    0x8(%eax),%edx
c0105391:	8b 40 04             	mov    0x4(%eax),%eax
c0105394:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0105397:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010539a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010539d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053a0:	89 d0                	mov    %edx,%eax
c01053a2:	c1 e0 02             	shl    $0x2,%eax
c01053a5:	01 d0                	add    %edx,%eax
c01053a7:	c1 e0 02             	shl    $0x2,%eax
c01053aa:	01 c8                	add    %ecx,%eax
c01053ac:	8b 48 0c             	mov    0xc(%eax),%ecx
c01053af:	8b 58 10             	mov    0x10(%eax),%ebx
c01053b2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01053b5:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01053b8:	01 c8                	add    %ecx,%eax
c01053ba:	11 da                	adc    %ebx,%edx
c01053bc:	89 45 98             	mov    %eax,-0x68(%ebp)
c01053bf:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01053c2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053c8:	89 d0                	mov    %edx,%eax
c01053ca:	c1 e0 02             	shl    $0x2,%eax
c01053cd:	01 d0                	add    %edx,%eax
c01053cf:	c1 e0 02             	shl    $0x2,%eax
c01053d2:	01 c8                	add    %ecx,%eax
c01053d4:	83 c0 14             	add    $0x14,%eax
c01053d7:	8b 00                	mov    (%eax),%eax
c01053d9:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01053df:	8b 45 98             	mov    -0x68(%ebp),%eax
c01053e2:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01053e5:	83 c0 ff             	add    $0xffffffff,%eax
c01053e8:	83 d2 ff             	adc    $0xffffffff,%edx
c01053eb:	89 c6                	mov    %eax,%esi
c01053ed:	89 d7                	mov    %edx,%edi
c01053ef:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01053f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053f5:	89 d0                	mov    %edx,%eax
c01053f7:	c1 e0 02             	shl    $0x2,%eax
c01053fa:	01 d0                	add    %edx,%eax
c01053fc:	c1 e0 02             	shl    $0x2,%eax
c01053ff:	01 c8                	add    %ecx,%eax
c0105401:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105404:	8b 58 10             	mov    0x10(%eax),%ebx
c0105407:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c010540d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0105411:	89 74 24 14          	mov    %esi,0x14(%esp)
c0105415:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0105419:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010541c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010541f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105423:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105427:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010542b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010542f:	c7 04 24 78 d8 10 c0 	movl   $0xc010d878,(%esp)
c0105436:	e8 37 af ff ff       	call   c0100372 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010543b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010543e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105441:	89 d0                	mov    %edx,%eax
c0105443:	c1 e0 02             	shl    $0x2,%eax
c0105446:	01 d0                	add    %edx,%eax
c0105448:	c1 e0 02             	shl    $0x2,%eax
c010544b:	01 c8                	add    %ecx,%eax
c010544d:	83 c0 14             	add    $0x14,%eax
c0105450:	8b 00                	mov    (%eax),%eax
c0105452:	83 f8 01             	cmp    $0x1,%eax
c0105455:	75 2e                	jne    c0105485 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0105457:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010545a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010545d:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0105460:	89 d0                	mov    %edx,%eax
c0105462:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0105465:	73 1e                	jae    c0105485 <page_init+0x142>
c0105467:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c010546c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105471:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0105474:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0105477:	72 0c                	jb     c0105485 <page_init+0x142>
                maxpa = end;
c0105479:	8b 45 98             	mov    -0x68(%ebp),%eax
c010547c:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010547f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105482:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0105485:	ff 45 dc             	incl   -0x24(%ebp)
c0105488:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010548b:	8b 00                	mov    (%eax),%eax
c010548d:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105490:	0f 8c e6 fe ff ff    	jl     c010537c <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0105496:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010549b:	b8 00 00 00 00       	mov    $0x0,%eax
c01054a0:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c01054a3:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c01054a6:	73 0e                	jae    c01054b6 <page_init+0x173>
        maxpa = KMEMSIZE;
c01054a8:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01054af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01054b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01054bc:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01054c0:	c1 ea 0c             	shr    $0xc,%edx
c01054c3:	a3 a4 7f 1b c0       	mov    %eax,0xc01b7fa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01054c8:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01054cf:	b8 78 a1 1b c0       	mov    $0xc01ba178,%eax
c01054d4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054d7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01054da:	01 d0                	add    %edx,%eax
c01054dc:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01054df:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01054e2:	ba 00 00 00 00       	mov    $0x0,%edx
c01054e7:	f7 75 c0             	divl   -0x40(%ebp)
c01054ea:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01054ed:	29 d0                	sub    %edx,%eax
c01054ef:	a3 a0 7f 1b c0       	mov    %eax,0xc01b7fa0

    for (i = 0; i < npage; i ++) {
c01054f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01054fb:	eb 28                	jmp    c0105525 <page_init+0x1e2>
        SetPageReserved(pages + i);
c01054fd:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0105503:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105506:	c1 e0 05             	shl    $0x5,%eax
c0105509:	01 d0                	add    %edx,%eax
c010550b:	83 c0 04             	add    $0x4,%eax
c010550e:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0105515:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105518:	8b 45 90             	mov    -0x70(%ebp),%eax
c010551b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010551e:	0f ab 10             	bts    %edx,(%eax)
}
c0105521:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0105522:	ff 45 dc             	incl   -0x24(%ebp)
c0105525:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105528:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c010552d:	39 c2                	cmp    %eax,%edx
c010552f:	72 cc                	jb     c01054fd <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0105531:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0105536:	c1 e0 05             	shl    $0x5,%eax
c0105539:	89 c2                	mov    %eax,%edx
c010553b:	a1 a0 7f 1b c0       	mov    0xc01b7fa0,%eax
c0105540:	01 d0                	add    %edx,%eax
c0105542:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105545:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010554c:	77 23                	ja     c0105571 <page_init+0x22e>
c010554e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105551:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105555:	c7 44 24 08 a8 d8 10 	movl   $0xc010d8a8,0x8(%esp)
c010555c:	c0 
c010555d:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0105564:	00 
c0105565:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010556c:	e8 7f b8 ff ff       	call   c0100df0 <__panic>
c0105571:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105574:	05 00 00 00 40       	add    $0x40000000,%eax
c0105579:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010557c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105583:	e9 53 01 00 00       	jmp    c01056db <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105588:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010558b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010558e:	89 d0                	mov    %edx,%eax
c0105590:	c1 e0 02             	shl    $0x2,%eax
c0105593:	01 d0                	add    %edx,%eax
c0105595:	c1 e0 02             	shl    $0x2,%eax
c0105598:	01 c8                	add    %ecx,%eax
c010559a:	8b 50 08             	mov    0x8(%eax),%edx
c010559d:	8b 40 04             	mov    0x4(%eax),%eax
c01055a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01055a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01055a6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055ac:	89 d0                	mov    %edx,%eax
c01055ae:	c1 e0 02             	shl    $0x2,%eax
c01055b1:	01 d0                	add    %edx,%eax
c01055b3:	c1 e0 02             	shl    $0x2,%eax
c01055b6:	01 c8                	add    %ecx,%eax
c01055b8:	8b 48 0c             	mov    0xc(%eax),%ecx
c01055bb:	8b 58 10             	mov    0x10(%eax),%ebx
c01055be:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01055c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055c4:	01 c8                	add    %ecx,%eax
c01055c6:	11 da                	adc    %ebx,%edx
c01055c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01055cb:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01055ce:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01055d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055d4:	89 d0                	mov    %edx,%eax
c01055d6:	c1 e0 02             	shl    $0x2,%eax
c01055d9:	01 d0                	add    %edx,%eax
c01055db:	c1 e0 02             	shl    $0x2,%eax
c01055de:	01 c8                	add    %ecx,%eax
c01055e0:	83 c0 14             	add    $0x14,%eax
c01055e3:	8b 00                	mov    (%eax),%eax
c01055e5:	83 f8 01             	cmp    $0x1,%eax
c01055e8:	0f 85 ea 00 00 00    	jne    c01056d8 <page_init+0x395>
            if (begin < freemem) {
c01055ee:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01055f1:	ba 00 00 00 00       	mov    $0x0,%edx
c01055f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01055f9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01055fc:	19 d1                	sbb    %edx,%ecx
c01055fe:	73 0d                	jae    c010560d <page_init+0x2ca>
                begin = freemem;
c0105600:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105603:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105606:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010560d:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0105612:	b8 00 00 00 00       	mov    $0x0,%eax
c0105617:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c010561a:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010561d:	73 0e                	jae    c010562d <page_init+0x2ea>
                end = KMEMSIZE;
c010561f:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0105626:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010562d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105630:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105633:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105636:	89 d0                	mov    %edx,%eax
c0105638:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010563b:	0f 83 97 00 00 00    	jae    c01056d8 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0105641:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0105648:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010564b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010564e:	01 d0                	add    %edx,%eax
c0105650:	48                   	dec    %eax
c0105651:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0105654:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105657:	ba 00 00 00 00       	mov    $0x0,%edx
c010565c:	f7 75 b0             	divl   -0x50(%ebp)
c010565f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105662:	29 d0                	sub    %edx,%eax
c0105664:	ba 00 00 00 00       	mov    $0x0,%edx
c0105669:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010566c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010566f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105672:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0105675:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105678:	ba 00 00 00 00       	mov    $0x0,%edx
c010567d:	89 c7                	mov    %eax,%edi
c010567f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0105685:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0105688:	89 d0                	mov    %edx,%eax
c010568a:	83 e0 00             	and    $0x0,%eax
c010568d:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0105690:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105693:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105696:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105699:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010569c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010569f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01056a2:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01056a5:	89 d0                	mov    %edx,%eax
c01056a7:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01056aa:	73 2c                	jae    c01056d8 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01056ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01056af:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01056b2:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01056b5:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01056b8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01056bc:	c1 ea 0c             	shr    $0xc,%edx
c01056bf:	89 c3                	mov    %eax,%ebx
c01056c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056c4:	89 04 24             	mov    %eax,(%esp)
c01056c7:	e8 a0 f8 ff ff       	call   c0104f6c <pa2page>
c01056cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 7a fb ff ff       	call   c0105252 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01056d8:	ff 45 dc             	incl   -0x24(%ebp)
c01056db:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01056de:	8b 00                	mov    (%eax),%eax
c01056e0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01056e3:	0f 8c 9f fe ff ff    	jl     c0105588 <page_init+0x245>
                }
            }
        }
    }
}
c01056e9:	90                   	nop
c01056ea:	90                   	nop
c01056eb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01056f1:	5b                   	pop    %ebx
c01056f2:	5e                   	pop    %esi
c01056f3:	5f                   	pop    %edi
c01056f4:	5d                   	pop    %ebp
c01056f5:	c3                   	ret    

c01056f6 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01056f6:	55                   	push   %ebp
c01056f7:	89 e5                	mov    %esp,%ebp
c01056f9:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01056fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ff:	33 45 14             	xor    0x14(%ebp),%eax
c0105702:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105707:	85 c0                	test   %eax,%eax
c0105709:	74 24                	je     c010572f <boot_map_segment+0x39>
c010570b:	c7 44 24 0c da d8 10 	movl   $0xc010d8da,0xc(%esp)
c0105712:	c0 
c0105713:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010571a:	c0 
c010571b:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0105722:	00 
c0105723:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010572a:	e8 c1 b6 ff ff       	call   c0100df0 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010572f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0105736:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105739:	25 ff 0f 00 00       	and    $0xfff,%eax
c010573e:	89 c2                	mov    %eax,%edx
c0105740:	8b 45 10             	mov    0x10(%ebp),%eax
c0105743:	01 c2                	add    %eax,%edx
c0105745:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105748:	01 d0                	add    %edx,%eax
c010574a:	48                   	dec    %eax
c010574b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010574e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105751:	ba 00 00 00 00       	mov    $0x0,%edx
c0105756:	f7 75 f0             	divl   -0x10(%ebp)
c0105759:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010575c:	29 d0                	sub    %edx,%eax
c010575e:	c1 e8 0c             	shr    $0xc,%eax
c0105761:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0105764:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105767:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010576a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010576d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105772:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0105775:	8b 45 14             	mov    0x14(%ebp),%eax
c0105778:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010577b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010577e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105783:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105786:	eb 68                	jmp    c01057f0 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0105788:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010578f:	00 
c0105790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105793:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105797:	8b 45 08             	mov    0x8(%ebp),%eax
c010579a:	89 04 24             	mov    %eax,(%esp)
c010579d:	e8 8d 01 00 00       	call   c010592f <get_pte>
c01057a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01057a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01057a9:	75 24                	jne    c01057cf <boot_map_segment+0xd9>
c01057ab:	c7 44 24 0c 06 d9 10 	movl   $0xc010d906,0xc(%esp)
c01057b2:	c0 
c01057b3:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01057ba:	c0 
c01057bb:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01057c2:	00 
c01057c3:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01057ca:	e8 21 b6 ff ff       	call   c0100df0 <__panic>
        *ptep = pa | PTE_P | perm;
c01057cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01057d2:	0b 45 18             	or     0x18(%ebp),%eax
c01057d5:	83 c8 01             	or     $0x1,%eax
c01057d8:	89 c2                	mov    %eax,%edx
c01057da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057dd:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01057df:	ff 4d f4             	decl   -0xc(%ebp)
c01057e2:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01057e9:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01057f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01057f4:	75 92                	jne    c0105788 <boot_map_segment+0x92>
    }
}
c01057f6:	90                   	nop
c01057f7:	90                   	nop
c01057f8:	89 ec                	mov    %ebp,%esp
c01057fa:	5d                   	pop    %ebp
c01057fb:	c3                   	ret    

c01057fc <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01057fc:	55                   	push   %ebp
c01057fd:	89 e5                	mov    %esp,%ebp
c01057ff:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0105802:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105809:	e8 66 fa ff ff       	call   c0105274 <alloc_pages>
c010580e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0105811:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105815:	75 1c                	jne    c0105833 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105817:	c7 44 24 08 13 d9 10 	movl   $0xc010d913,0x8(%esp)
c010581e:	c0 
c010581f:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105826:	00 
c0105827:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010582e:	e8 bd b5 ff ff       	call   c0100df0 <__panic>
    }
    return page2kva(p);
c0105833:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105836:	89 04 24             	mov    %eax,(%esp)
c0105839:	e8 76 f7 ff ff       	call   c0104fb4 <page2kva>
}
c010583e:	89 ec                	mov    %ebp,%esp
c0105840:	5d                   	pop    %ebp
c0105841:	c3                   	ret    

c0105842 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0105842:	55                   	push   %ebp
c0105843:	89 e5                	mov    %esp,%ebp
c0105845:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105848:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010584d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105850:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105857:	77 23                	ja     c010587c <pmm_init+0x3a>
c0105859:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010585c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105860:	c7 44 24 08 a8 d8 10 	movl   $0xc010d8a8,0x8(%esp)
c0105867:	c0 
c0105868:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010586f:	00 
c0105870:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105877:	e8 74 b5 ff ff       	call   c0100df0 <__panic>
c010587c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010587f:	05 00 00 00 40       	add    $0x40000000,%eax
c0105884:	a3 a8 7f 1b c0       	mov    %eax,0xc01b7fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105889:	e8 8e f9 ff ff       	call   c010521c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010588e:	e8 b0 fa ff ff       	call   c0105343 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0105893:	e8 b7 09 00 00       	call   c010624f <check_alloc_page>

    check_pgdir();
c0105898:	e8 d3 09 00 00       	call   c0106270 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010589d:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01058a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058a5:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01058ac:	77 23                	ja     c01058d1 <pmm_init+0x8f>
c01058ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058b5:	c7 44 24 08 a8 d8 10 	movl   $0xc010d8a8,0x8(%esp)
c01058bc:	c0 
c01058bd:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01058c4:	00 
c01058c5:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01058cc:	e8 1f b5 ff ff       	call   c0100df0 <__panic>
c01058d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058d4:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01058da:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01058df:	05 ac 0f 00 00       	add    $0xfac,%eax
c01058e4:	83 ca 03             	or     $0x3,%edx
c01058e7:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01058e9:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01058ee:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01058f5:	00 
c01058f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01058fd:	00 
c01058fe:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105905:	38 
c0105906:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010590d:	c0 
c010590e:	89 04 24             	mov    %eax,(%esp)
c0105911:	e8 e0 fd ff ff       	call   c01056f6 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0105916:	e8 15 f8 ff ff       	call   c0105130 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010591b:	e8 ee 0f 00 00       	call   c010690e <check_boot_pgdir>

    print_pgdir();
c0105920:	e8 6b 14 00 00       	call   c0106d90 <print_pgdir>
    
    kmalloc_init();
c0105925:	e8 70 f3 ff ff       	call   c0104c9a <kmalloc_init>

}
c010592a:	90                   	nop
c010592b:	89 ec                	mov    %ebp,%esp
c010592d:	5d                   	pop    %ebp
c010592e:	c3                   	ret    

c010592f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010592f:	55                   	push   %ebp
c0105930:	89 e5                	mov    %esp,%ebp
c0105932:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = PDX(la) + pgdir;  // (1) find page directory entry
c0105935:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105938:	c1 e8 16             	shr    $0x16,%eax
c010593b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105942:	8b 45 08             	mov    0x8(%ebp),%eax
c0105945:	01 d0                	add    %edx,%eax
c0105947:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // (2) check if entry is not present
c010594a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010594d:	8b 00                	mov    (%eax),%eax
c010594f:	83 e0 01             	and    $0x1,%eax
c0105952:	85 c0                	test   %eax,%eax
c0105954:	0f 85 af 00 00 00    	jne    c0105a09 <get_pte+0xda>
        // (4) set page reference
        // (5) get linear address of page
        // (6) clear page content using memset
        // (7) set page directory entry's permission
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010595a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010595e:	74 15                	je     c0105975 <get_pte+0x46>
c0105960:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105967:	e8 08 f9 ff ff       	call   c0105274 <alloc_pages>
c010596c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010596f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105973:	75 0a                	jne    c010597f <get_pte+0x50>
            return NULL;
c0105975:	b8 00 00 00 00       	mov    $0x0,%eax
c010597a:	e9 ed 00 00 00       	jmp    c0105a6c <get_pte+0x13d>
        }
        set_page_ref(page, 1);
c010597f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105986:	00 
c0105987:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010598a:	89 04 24             	mov    %eax,(%esp)
c010598d:	e8 dc f6 ff ff       	call   c010506e <set_page_ref>
        uintptr_t pa = page2pa(page);  // the physical address of page table
c0105992:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105995:	89 04 24             	mov    %eax,(%esp)
c0105998:	e8 b7 f5 ff ff       	call   c0104f54 <page2pa>
c010599d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01059a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01059a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059a9:	c1 e8 0c             	shr    $0xc,%eax
c01059ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01059af:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01059b4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01059b7:	72 23                	jb     c01059dc <get_pte+0xad>
c01059b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059c0:	c7 44 24 08 04 d8 10 	movl   $0xc010d804,0x8(%esp)
c01059c7:	c0 
c01059c8:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c01059cf:	00 
c01059d0:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01059d7:	e8 14 b4 ff ff       	call   c0100df0 <__panic>
c01059dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01059df:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01059e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01059eb:	00 
c01059ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059f3:	00 
c01059f4:	89 04 24             	mov    %eax,(%esp)
c01059f7:	e8 f5 6d 00 00       	call   c010c7f1 <memset>
        *pdep = pa | PTE_P | PTE_W | PTE_U;
c01059fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059ff:	83 c8 07             	or     $0x7,%eax
c0105a02:	89 c2                	mov    %eax,%edx
c0105a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a07:	89 10                	mov    %edx,(%eax)
    }

    pte_t *ptep = (pte_t *)KADDR(PDE_ADDR(*pdep)) + PTX(la);
c0105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0c:	8b 00                	mov    (%eax),%eax
c0105a0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105a16:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a19:	c1 e8 0c             	shr    $0xc,%eax
c0105a1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105a1f:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0105a24:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105a27:	72 23                	jb     c0105a4c <get_pte+0x11d>
c0105a29:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a30:	c7 44 24 08 04 d8 10 	movl   $0xc010d804,0x8(%esp)
c0105a37:	c0 
c0105a38:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
c0105a3f:	00 
c0105a40:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105a47:	e8 a4 b3 ff ff       	call   c0100df0 <__panic>
c0105a4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a4f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105a54:	89 c2                	mov    %eax,%edx
c0105a56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a59:	c1 e8 0c             	shr    $0xc,%eax
c0105a5c:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105a61:	c1 e0 02             	shl    $0x2,%eax
c0105a64:	01 d0                	add    %edx,%eax
c0105a66:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ptep;  // (8) return page table entry
c0105a69:	8b 45 d8             	mov    -0x28(%ebp),%eax
#endif
}
c0105a6c:	89 ec                	mov    %ebp,%esp
c0105a6e:	5d                   	pop    %ebp
c0105a6f:	c3                   	ret    

c0105a70 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105a70:	55                   	push   %ebp
c0105a71:	89 e5                	mov    %esp,%ebp
c0105a73:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105a76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105a7d:	00 
c0105a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a85:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a88:	89 04 24             	mov    %eax,(%esp)
c0105a8b:	e8 9f fe ff ff       	call   c010592f <get_pte>
c0105a90:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105a93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a97:	74 08                	je     c0105aa1 <get_page+0x31>
        *ptep_store = ptep;
c0105a99:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a9f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105aa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105aa5:	74 1b                	je     c0105ac2 <get_page+0x52>
c0105aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aaa:	8b 00                	mov    (%eax),%eax
c0105aac:	83 e0 01             	and    $0x1,%eax
c0105aaf:	85 c0                	test   %eax,%eax
c0105ab1:	74 0f                	je     c0105ac2 <get_page+0x52>
        return pte2page(*ptep);
c0105ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ab6:	8b 00                	mov    (%eax),%eax
c0105ab8:	89 04 24             	mov    %eax,(%esp)
c0105abb:	e8 4a f5 ff ff       	call   c010500a <pte2page>
c0105ac0:	eb 05                	jmp    c0105ac7 <get_page+0x57>
    }
    return NULL;
c0105ac2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ac7:	89 ec                	mov    %ebp,%esp
c0105ac9:	5d                   	pop    %ebp
c0105aca:	c3                   	ret    

c0105acb <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105acb:	55                   	push   %ebp
c0105acc:	89 e5                	mov    %esp,%ebp
c0105ace:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep & PTE_P)  //(1) check if this page table entry is present
c0105ad1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ad4:	8b 00                	mov    (%eax),%eax
c0105ad6:	83 e0 01             	and    $0x1,%eax
c0105ad9:	85 c0                	test   %eax,%eax
c0105adb:	74 4d                	je     c0105b2a <page_remove_pte+0x5f>
    {
        struct Page *page = pte2page(*ptep);  //(2) find corresponding page to pte
c0105add:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ae0:	8b 00                	mov    (%eax),%eax
c0105ae2:	89 04 24             	mov    %eax,(%esp)
c0105ae5:	e8 20 f5 ff ff       	call   c010500a <pte2page>
c0105aea:	89 45 f4             	mov    %eax,-0xc(%ebp)

        if (page_ref_dec(page) == 0)  //(3) decrease page reference
c0105aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105af0:	89 04 24             	mov    %eax,(%esp)
c0105af3:	e8 9b f5 ff ff       	call   c0105093 <page_ref_dec>
c0105af8:	85 c0                	test   %eax,%eax
c0105afa:	75 13                	jne    c0105b0f <page_remove_pte+0x44>
        {                             //free_page means add this page to freeList in FIFO
            free_page(page);          //(4) and free this page when page reference reachs 0
c0105afc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b03:	00 
c0105b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b07:	89 04 24             	mov    %eax,(%esp)
c0105b0a:	e8 d2 f7 ff ff       	call   c01052e1 <free_pages>
        }
        *ptep = 0;                  //(5) clear second page table entry
c0105b0f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
c0105b18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b22:	89 04 24             	mov    %eax,(%esp)
c0105b25:	e8 f0 05 00 00       	call   c010611a <tlb_invalidate>
    }
#endif
}
c0105b2a:	90                   	nop
c0105b2b:	89 ec                	mov    %ebp,%esp
c0105b2d:	5d                   	pop    %ebp
c0105b2e:	c3                   	ret    

c0105b2f <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105b2f:	55                   	push   %ebp
c0105b30:	89 e5                	mov    %esp,%ebp
c0105b32:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105b35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b38:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b3d:	85 c0                	test   %eax,%eax
c0105b3f:	75 0c                	jne    c0105b4d <unmap_range+0x1e>
c0105b41:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b44:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b49:	85 c0                	test   %eax,%eax
c0105b4b:	74 24                	je     c0105b71 <unmap_range+0x42>
c0105b4d:	c7 44 24 0c 2c d9 10 	movl   $0xc010d92c,0xc(%esp)
c0105b54:	c0 
c0105b55:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105b5c:	c0 
c0105b5d:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c0105b64:	00 
c0105b65:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105b6c:	e8 7f b2 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105b71:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105b78:	76 11                	jbe    c0105b8b <unmap_range+0x5c>
c0105b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b7d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105b80:	73 09                	jae    c0105b8b <unmap_range+0x5c>
c0105b82:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105b89:	76 24                	jbe    c0105baf <unmap_range+0x80>
c0105b8b:	c7 44 24 0c 55 d9 10 	movl   $0xc010d955,0xc(%esp)
c0105b92:	c0 
c0105b93:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105b9a:	c0 
c0105b9b:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
c0105ba2:	00 
c0105ba3:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105baa:	e8 41 b2 ff ff       	call   c0100df0 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105baf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bb6:	00 
c0105bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc1:	89 04 24             	mov    %eax,(%esp)
c0105bc4:	e8 66 fd ff ff       	call   c010592f <get_pte>
c0105bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105bcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bd0:	75 18                	jne    c0105bea <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bd5:	05 00 00 40 00       	add    $0x400000,%eax
c0105bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105be0:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105be5:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105be8:	eb 29                	jmp    c0105c13 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bed:	8b 00                	mov    (%eax),%eax
c0105bef:	85 c0                	test   %eax,%eax
c0105bf1:	74 19                	je     c0105c0c <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c01:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c04:	89 04 24             	mov    %eax,(%esp)
c0105c07:	e8 bf fe ff ff       	call   c0105acb <page_remove_pte>
        }
        start += PGSIZE;
c0105c0c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105c13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c17:	74 08                	je     c0105c21 <unmap_range+0xf2>
c0105c19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c1f:	72 8e                	jb     c0105baf <unmap_range+0x80>
}
c0105c21:	90                   	nop
c0105c22:	89 ec                	mov    %ebp,%esp
c0105c24:	5d                   	pop    %ebp
c0105c25:	c3                   	ret    

c0105c26 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105c26:	55                   	push   %ebp
c0105c27:	89 e5                	mov    %esp,%ebp
c0105c29:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c2f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c34:	85 c0                	test   %eax,%eax
c0105c36:	75 0c                	jne    c0105c44 <exit_range+0x1e>
c0105c38:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c3b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c40:	85 c0                	test   %eax,%eax
c0105c42:	74 24                	je     c0105c68 <exit_range+0x42>
c0105c44:	c7 44 24 0c 2c d9 10 	movl   $0xc010d92c,0xc(%esp)
c0105c4b:	c0 
c0105c4c:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105c53:	c0 
c0105c54:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
c0105c5b:	00 
c0105c5c:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105c63:	e8 88 b1 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105c68:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105c6f:	76 11                	jbe    c0105c82 <exit_range+0x5c>
c0105c71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c74:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c77:	73 09                	jae    c0105c82 <exit_range+0x5c>
c0105c79:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105c80:	76 24                	jbe    c0105ca6 <exit_range+0x80>
c0105c82:	c7 44 24 0c 55 d9 10 	movl   $0xc010d955,0xc(%esp)
c0105c89:	c0 
c0105c8a:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105c91:	c0 
c0105c92:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
c0105c99:	00 
c0105c9a:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105ca1:	e8 4a b1 ff ff       	call   c0100df0 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ca9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105caf:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105cb4:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cba:	c1 e8 16             	shr    $0x16,%eax
c0105cbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cc3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cca:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccd:	01 d0                	add    %edx,%eax
c0105ccf:	8b 00                	mov    (%eax),%eax
c0105cd1:	83 e0 01             	and    $0x1,%eax
c0105cd4:	85 c0                	test   %eax,%eax
c0105cd6:	74 3e                	je     c0105d16 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cdb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce5:	01 d0                	add    %edx,%eax
c0105ce7:	8b 00                	mov    (%eax),%eax
c0105ce9:	89 04 24             	mov    %eax,(%esp)
c0105cec:	e8 59 f3 ff ff       	call   c010504a <pde2page>
c0105cf1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105cf8:	00 
c0105cf9:	89 04 24             	mov    %eax,(%esp)
c0105cfc:	e8 e0 f5 ff ff       	call   c01052e1 <free_pages>
            pgdir[pde_idx] = 0;
c0105d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d0e:	01 d0                	add    %edx,%eax
c0105d10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105d16:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105d1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105d21:	74 08                	je     c0105d2b <exit_range+0x105>
c0105d23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d26:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105d29:	72 8c                	jb     c0105cb7 <exit_range+0x91>
}
c0105d2b:	90                   	nop
c0105d2c:	89 ec                	mov    %ebp,%esp
c0105d2e:	5d                   	pop    %ebp
c0105d2f:	c3                   	ret    

c0105d30 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105d30:	55                   	push   %ebp
c0105d31:	89 e5                	mov    %esp,%ebp
c0105d33:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105d36:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d39:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d3e:	85 c0                	test   %eax,%eax
c0105d40:	75 0c                	jne    c0105d4e <copy_range+0x1e>
c0105d42:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d45:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d4a:	85 c0                	test   %eax,%eax
c0105d4c:	74 24                	je     c0105d72 <copy_range+0x42>
c0105d4e:	c7 44 24 0c 2c d9 10 	movl   $0xc010d92c,0xc(%esp)
c0105d55:	c0 
c0105d56:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105d5d:	c0 
c0105d5e:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0105d65:	00 
c0105d66:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105d6d:	e8 7e b0 ff ff       	call   c0100df0 <__panic>
    assert(USER_ACCESS(start, end));
c0105d72:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105d79:	76 11                	jbe    c0105d8c <copy_range+0x5c>
c0105d7b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d7e:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105d81:	73 09                	jae    c0105d8c <copy_range+0x5c>
c0105d83:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105d8a:	76 24                	jbe    c0105db0 <copy_range+0x80>
c0105d8c:	c7 44 24 0c 55 d9 10 	movl   $0xc010d955,0xc(%esp)
c0105d93:	c0 
c0105d94:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105d9b:	c0 
c0105d9c:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0105da3:	00 
c0105da4:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105dab:	e8 40 b0 ff ff       	call   c0100df0 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105db0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105db7:	00 
c0105db8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dc2:	89 04 24             	mov    %eax,(%esp)
c0105dc5:	e8 65 fb ff ff       	call   c010592f <get_pte>
c0105dca:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (ptep == NULL) {
c0105dcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105dd1:	75 1b                	jne    c0105dee <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105dd3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dd6:	05 00 00 40 00       	add    $0x400000,%eax
c0105ddb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105dde:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105de1:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105de6:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105de9:	e9 0f 02 00 00       	jmp    c0105ffd <copy_range+0x2cd>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105df1:	8b 00                	mov    (%eax),%eax
c0105df3:	83 e0 01             	and    $0x1,%eax
c0105df6:	85 c0                	test   %eax,%eax
c0105df8:	0f 84 f8 01 00 00    	je     c0105ff6 <copy_range+0x2c6>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105dfe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105e05:	00 
c0105e06:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e10:	89 04 24             	mov    %eax,(%esp)
c0105e13:	e8 17 fb ff ff       	call   c010592f <get_pte>
c0105e18:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105e1f:	75 0a                	jne    c0105e2b <copy_range+0xfb>
                return -E_NO_MEM;
c0105e21:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105e26:	e9 e9 01 00 00       	jmp    c0106014 <copy_range+0x2e4>
            }
            uint32_t perm = (*ptep & PTE_USER);
c0105e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e2e:	8b 00                	mov    (%eax),%eax
c0105e30:	83 e0 07             	and    $0x7,%eax
c0105e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
            //get page from ptep
            struct Page *page = pte2page(*ptep);
c0105e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e39:	8b 00                	mov    (%eax),%eax
c0105e3b:	89 04 24             	mov    %eax,(%esp)
c0105e3e:	e8 c7 f1 ff ff       	call   c010500a <pte2page>
c0105e43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            // alloc a page for process B
            //struct Page *npage=alloc_page();
            assert(page!=NULL);
c0105e46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e4a:	75 24                	jne    c0105e70 <copy_range+0x140>
c0105e4c:	c7 44 24 0c 6d d9 10 	movl   $0xc010d96d,0xc(%esp)
c0105e53:	c0 
c0105e54:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105e5b:	c0 
c0105e5c:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0105e63:	00 
c0105e64:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105e6b:	e8 80 af ff ff       	call   c0100df0 <__panic>
            //assert(npage!=NULL);
            int ret=0;
c0105e70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            * (2) find dst_kvaddr: the kernel virtual address of npage
            * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
            * (4) build the map of phy addr of  nage with the linear addr start
            */
            // 如果启用写时复制
            if(share)
c0105e77:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105e7b:	74 69                	je     c0105ee6 <copy_range+0x1b6>
            {
                cprintf("Sharing the page 0x%x\n", page2kva(page));
c0105e7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e80:	89 04 24             	mov    %eax,(%esp)
c0105e83:	e8 2c f1 ff ff       	call   c0104fb4 <page2kva>
c0105e88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e8c:	c7 04 24 78 d9 10 c0 	movl   $0xc010d978,(%esp)
c0105e93:	e8 da a4 ff ff       	call   c0100372 <cprintf>
                // 在两个PTE上均设置为只读
                page_insert(from, page, start, perm & ~PTE_W);
c0105e98:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e9b:	83 e0 fd             	and    $0xfffffffd,%eax
c0105e9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ea2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eb3:	89 04 24             	mov    %eax,(%esp)
c0105eb6:	e8 a4 01 00 00       	call   c010605f <page_insert>
                ret = page_insert(to, page, start, perm & ~PTE_W);
c0105ebb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ebe:	83 e0 fd             	and    $0xfffffffd,%eax
c0105ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ec5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ec8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ed3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed6:	89 04 24             	mov    %eax,(%esp)
c0105ed9:	e8 81 01 00 00       	call   c010605f <page_insert>
c0105ede:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ee1:	e9 e6 00 00 00       	jmp    c0105fcc <copy_range+0x29c>
            // 完整拷贝内存
            else
            {
                // alloc a page for process B
                // 目标页面地址
                struct Page *npage = alloc_page();
c0105ee6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105eed:	e8 82 f3 ff ff       	call   c0105274 <alloc_pages>
c0105ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
                assert(page!=NULL);
c0105ef5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ef9:	75 24                	jne    c0105f1f <copy_range+0x1ef>
c0105efb:	c7 44 24 0c 6d d9 10 	movl   $0xc010d96d,0xc(%esp)
c0105f02:	c0 
c0105f03:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105f0a:	c0 
c0105f0b:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0105f12:	00 
c0105f13:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105f1a:	e8 d1 ae ff ff       	call   c0100df0 <__panic>
                assert(npage!=NULL);
c0105f1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105f23:	75 24                	jne    c0105f49 <copy_range+0x219>
c0105f25:	c7 44 24 0c 8f d9 10 	movl   $0xc010d98f,0xc(%esp)
c0105f2c:	c0 
c0105f2d:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105f34:	c0 
c0105f35:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0105f3c:	00 
c0105f3d:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105f44:	e8 a7 ae ff ff       	call   c0100df0 <__panic>
                * (2) find dst_kvaddr: the kernel virtual address of npage
                * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
                * (4) build the map of phy addr of  nage with the linear addr start
                */
                uintptr_t src_kvaddr, dst_kvaddr;
                src_kvaddr = page2kva(page);
c0105f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f4c:	89 04 24             	mov    %eax,(%esp)
c0105f4f:	e8 60 f0 ff ff       	call   c0104fb4 <page2kva>
c0105f54:	89 45 dc             	mov    %eax,-0x24(%ebp)
                dst_kvaddr = page2kva(npage);
c0105f57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f5a:	89 04 24             	mov    %eax,(%esp)
c0105f5d:	e8 52 f0 ff ff       	call   c0104fb4 <page2kva>
c0105f62:	89 45 d8             	mov    %eax,-0x28(%ebp)
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
c0105f65:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f68:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105f6b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105f72:	00 
c0105f73:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f77:	89 04 24             	mov    %eax,(%esp)
c0105f7a:	e8 57 69 00 00       	call   c010c8d6 <memcpy>
                ret = page_insert(to, npage, start, perm);
c0105f7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105f82:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f86:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f89:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f94:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f97:	89 04 24             	mov    %eax,(%esp)
c0105f9a:	e8 c0 00 00 00       	call   c010605f <page_insert>
c0105f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
                assert(ret == 0);
c0105fa2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105fa6:	74 24                	je     c0105fcc <copy_range+0x29c>
c0105fa8:	c7 44 24 0c 9b d9 10 	movl   $0xc010d99b,0xc(%esp)
c0105faf:	c0 
c0105fb0:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105fb7:	c0 
c0105fb8:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0105fbf:	00 
c0105fc0:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105fc7:	e8 24 ae ff ff       	call   c0100df0 <__panic>
            }
            assert(ret == 0);
c0105fcc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105fd0:	74 24                	je     c0105ff6 <copy_range+0x2c6>
c0105fd2:	c7 44 24 0c 9b d9 10 	movl   $0xc010d99b,0xc(%esp)
c0105fd9:	c0 
c0105fda:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0105fe1:	c0 
c0105fe2:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0105fe9:	00 
c0105fea:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0105ff1:	e8 fa ad ff ff       	call   c0100df0 <__panic>
        }
        start += PGSIZE;
c0105ff6:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105ffd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106001:	74 0c                	je     c010600f <copy_range+0x2df>
c0106003:	8b 45 10             	mov    0x10(%ebp),%eax
c0106006:	3b 45 14             	cmp    0x14(%ebp),%eax
c0106009:	0f 82 a1 fd ff ff    	jb     c0105db0 <copy_range+0x80>
    return 0;
c010600f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106014:	89 ec                	mov    %ebp,%esp
c0106016:	5d                   	pop    %ebp
c0106017:	c3                   	ret    

c0106018 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106018:	55                   	push   %ebp
c0106019:	89 e5                	mov    %esp,%ebp
c010601b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010601e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106025:	00 
c0106026:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106029:	89 44 24 04          	mov    %eax,0x4(%esp)
c010602d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106030:	89 04 24             	mov    %eax,(%esp)
c0106033:	e8 f7 f8 ff ff       	call   c010592f <get_pte>
c0106038:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010603b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010603f:	74 19                	je     c010605a <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106044:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106048:	8b 45 0c             	mov    0xc(%ebp),%eax
c010604b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010604f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106052:	89 04 24             	mov    %eax,(%esp)
c0106055:	e8 71 fa ff ff       	call   c0105acb <page_remove_pte>
    }
}
c010605a:	90                   	nop
c010605b:	89 ec                	mov    %ebp,%esp
c010605d:	5d                   	pop    %ebp
c010605e:	c3                   	ret    

c010605f <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010605f:	55                   	push   %ebp
c0106060:	89 e5                	mov    %esp,%ebp
c0106062:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106065:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010606c:	00 
c010606d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106070:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106074:	8b 45 08             	mov    0x8(%ebp),%eax
c0106077:	89 04 24             	mov    %eax,(%esp)
c010607a:	e8 b0 f8 ff ff       	call   c010592f <get_pte>
c010607f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106082:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106086:	75 0a                	jne    c0106092 <page_insert+0x33>
        return -E_NO_MEM;
c0106088:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010608d:	e9 84 00 00 00       	jmp    c0106116 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106092:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106095:	89 04 24             	mov    %eax,(%esp)
c0106098:	e8 df ef ff ff       	call   c010507c <page_ref_inc>
    if (*ptep & PTE_P) {
c010609d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060a0:	8b 00                	mov    (%eax),%eax
c01060a2:	83 e0 01             	and    $0x1,%eax
c01060a5:	85 c0                	test   %eax,%eax
c01060a7:	74 3e                	je     c01060e7 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01060a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ac:	8b 00                	mov    (%eax),%eax
c01060ae:	89 04 24             	mov    %eax,(%esp)
c01060b1:	e8 54 ef ff ff       	call   c010500a <pte2page>
c01060b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01060b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01060bf:	75 0d                	jne    c01060ce <page_insert+0x6f>
            page_ref_dec(page);
c01060c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060c4:	89 04 24             	mov    %eax,(%esp)
c01060c7:	e8 c7 ef ff ff       	call   c0105093 <page_ref_dec>
c01060cc:	eb 19                	jmp    c01060e7 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01060ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060d1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01060d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01060df:	89 04 24             	mov    %eax,(%esp)
c01060e2:	e8 e4 f9 ff ff       	call   c0105acb <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01060e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060ea:	89 04 24             	mov    %eax,(%esp)
c01060ed:	e8 62 ee ff ff       	call   c0104f54 <page2pa>
c01060f2:	0b 45 14             	or     0x14(%ebp),%eax
c01060f5:	83 c8 01             	or     $0x1,%eax
c01060f8:	89 c2                	mov    %eax,%edx
c01060fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060fd:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01060ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0106102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106106:	8b 45 08             	mov    0x8(%ebp),%eax
c0106109:	89 04 24             	mov    %eax,(%esp)
c010610c:	e8 09 00 00 00       	call   c010611a <tlb_invalidate>
    return 0;
c0106111:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106116:	89 ec                	mov    %ebp,%esp
c0106118:	5d                   	pop    %ebp
c0106119:	c3                   	ret    

c010611a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010611a:	55                   	push   %ebp
c010611b:	89 e5                	mov    %esp,%ebp
c010611d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106120:	0f 20 d8             	mov    %cr3,%eax
c0106123:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106126:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0106129:	8b 45 08             	mov    0x8(%ebp),%eax
c010612c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010612f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106136:	77 23                	ja     c010615b <tlb_invalidate+0x41>
c0106138:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010613b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010613f:	c7 44 24 08 a8 d8 10 	movl   $0xc010d8a8,0x8(%esp)
c0106146:	c0 
c0106147:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c010614e:	00 
c010614f:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106156:	e8 95 ac ff ff       	call   c0100df0 <__panic>
c010615b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010615e:	05 00 00 00 40       	add    $0x40000000,%eax
c0106163:	39 d0                	cmp    %edx,%eax
c0106165:	75 0d                	jne    c0106174 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0106167:	8b 45 0c             	mov    0xc(%ebp),%eax
c010616a:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010616d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106170:	0f 01 38             	invlpg (%eax)
}
c0106173:	90                   	nop
    }
}
c0106174:	90                   	nop
c0106175:	89 ec                	mov    %ebp,%esp
c0106177:	5d                   	pop    %ebp
c0106178:	c3                   	ret    

c0106179 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106179:	55                   	push   %ebp
c010617a:	89 e5                	mov    %esp,%ebp
c010617c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c010617f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106186:	e8 e9 f0 ff ff       	call   c0105274 <alloc_pages>
c010618b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010618e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106192:	0f 84 b0 00 00 00    	je     c0106248 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106198:	8b 45 10             	mov    0x10(%ebp),%eax
c010619b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010619f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061a2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01061a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01061b0:	89 04 24             	mov    %eax,(%esp)
c01061b3:	e8 a7 fe ff ff       	call   c010605f <page_insert>
c01061b8:	85 c0                	test   %eax,%eax
c01061ba:	74 1a                	je     c01061d6 <pgdir_alloc_page+0x5d>
            free_page(page);
c01061bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01061c3:	00 
c01061c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061c7:	89 04 24             	mov    %eax,(%esp)
c01061ca:	e8 12 f1 ff ff       	call   c01052e1 <free_pages>
            return NULL;
c01061cf:	b8 00 00 00 00       	mov    $0x0,%eax
c01061d4:	eb 75                	jmp    c010624b <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c01061d6:	a1 44 80 1b c0       	mov    0xc01b8044,%eax
c01061db:	85 c0                	test   %eax,%eax
c01061dd:	74 69                	je     c0106248 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c01061df:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01061e4:	85 c0                	test   %eax,%eax
c01061e6:	74 60                	je     c0106248 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c01061e8:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01061ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01061f4:	00 
c01061f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061f8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01061fc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01061ff:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106203:	89 04 24             	mov    %eax,(%esp)
c0106206:	e8 54 0e 00 00       	call   c010705f <swap_map_swappable>
                page->pra_vaddr=la;
c010620b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010620e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106211:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0106214:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106217:	89 04 24             	mov    %eax,(%esp)
c010621a:	e8 45 ee ff ff       	call   c0105064 <page_ref>
c010621f:	83 f8 01             	cmp    $0x1,%eax
c0106222:	74 24                	je     c0106248 <pgdir_alloc_page+0xcf>
c0106224:	c7 44 24 0c a4 d9 10 	movl   $0xc010d9a4,0xc(%esp)
c010622b:	c0 
c010622c:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106233:	c0 
c0106234:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010623b:	00 
c010623c:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106243:	e8 a8 ab ff ff       	call   c0100df0 <__panic>
            }
        }

    }

    return page;
c0106248:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010624b:	89 ec                	mov    %ebp,%esp
c010624d:	5d                   	pop    %ebp
c010624e:	c3                   	ret    

c010624f <check_alloc_page>:

static void
check_alloc_page(void) {
c010624f:	55                   	push   %ebp
c0106250:	89 e5                	mov    %esp,%ebp
c0106252:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106255:	a1 ac 7f 1b c0       	mov    0xc01b7fac,%eax
c010625a:	8b 40 18             	mov    0x18(%eax),%eax
c010625d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010625f:	c7 04 24 b8 d9 10 c0 	movl   $0xc010d9b8,(%esp)
c0106266:	e8 07 a1 ff ff       	call   c0100372 <cprintf>
}
c010626b:	90                   	nop
c010626c:	89 ec                	mov    %ebp,%esp
c010626e:	5d                   	pop    %ebp
c010626f:	c3                   	ret    

c0106270 <check_pgdir>:

static void
check_pgdir(void) {
c0106270:	55                   	push   %ebp
c0106271:	89 e5                	mov    %esp,%ebp
c0106273:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106276:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c010627b:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106280:	76 24                	jbe    c01062a6 <check_pgdir+0x36>
c0106282:	c7 44 24 0c d7 d9 10 	movl   $0xc010d9d7,0xc(%esp)
c0106289:	c0 
c010628a:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106291:	c0 
c0106292:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
c0106299:	00 
c010629a:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01062a1:	e8 4a ab ff ff       	call   c0100df0 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01062a6:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01062ab:	85 c0                	test   %eax,%eax
c01062ad:	74 0e                	je     c01062bd <check_pgdir+0x4d>
c01062af:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01062b4:	25 ff 0f 00 00       	and    $0xfff,%eax
c01062b9:	85 c0                	test   %eax,%eax
c01062bb:	74 24                	je     c01062e1 <check_pgdir+0x71>
c01062bd:	c7 44 24 0c f4 d9 10 	movl   $0xc010d9f4,0xc(%esp)
c01062c4:	c0 
c01062c5:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01062cc:	c0 
c01062cd:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c01062d4:	00 
c01062d5:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01062dc:	e8 0f ab ff ff       	call   c0100df0 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01062e1:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01062e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062ed:	00 
c01062ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01062f5:	00 
c01062f6:	89 04 24             	mov    %eax,(%esp)
c01062f9:	e8 72 f7 ff ff       	call   c0105a70 <get_page>
c01062fe:	85 c0                	test   %eax,%eax
c0106300:	74 24                	je     c0106326 <check_pgdir+0xb6>
c0106302:	c7 44 24 0c 2c da 10 	movl   $0xc010da2c,0xc(%esp)
c0106309:	c0 
c010630a:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106311:	c0 
c0106312:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
c0106319:	00 
c010631a:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106321:	e8 ca aa ff ff       	call   c0100df0 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106326:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010632d:	e8 42 ef ff ff       	call   c0105274 <alloc_pages>
c0106332:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106335:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010633a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106341:	00 
c0106342:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106349:	00 
c010634a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010634d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106351:	89 04 24             	mov    %eax,(%esp)
c0106354:	e8 06 fd ff ff       	call   c010605f <page_insert>
c0106359:	85 c0                	test   %eax,%eax
c010635b:	74 24                	je     c0106381 <check_pgdir+0x111>
c010635d:	c7 44 24 0c 54 da 10 	movl   $0xc010da54,0xc(%esp)
c0106364:	c0 
c0106365:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010636c:	c0 
c010636d:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c0106374:	00 
c0106375:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010637c:	e8 6f aa ff ff       	call   c0100df0 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106381:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106386:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010638d:	00 
c010638e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106395:	00 
c0106396:	89 04 24             	mov    %eax,(%esp)
c0106399:	e8 91 f5 ff ff       	call   c010592f <get_pte>
c010639e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01063a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063a5:	75 24                	jne    c01063cb <check_pgdir+0x15b>
c01063a7:	c7 44 24 0c 80 da 10 	movl   $0xc010da80,0xc(%esp)
c01063ae:	c0 
c01063af:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01063b6:	c0 
c01063b7:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
c01063be:	00 
c01063bf:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01063c6:	e8 25 aa ff ff       	call   c0100df0 <__panic>
    assert(pte2page(*ptep) == p1);
c01063cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063ce:	8b 00                	mov    (%eax),%eax
c01063d0:	89 04 24             	mov    %eax,(%esp)
c01063d3:	e8 32 ec ff ff       	call   c010500a <pte2page>
c01063d8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01063db:	74 24                	je     c0106401 <check_pgdir+0x191>
c01063dd:	c7 44 24 0c ad da 10 	movl   $0xc010daad,0xc(%esp)
c01063e4:	c0 
c01063e5:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01063ec:	c0 
c01063ed:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
c01063f4:	00 
c01063f5:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01063fc:	e8 ef a9 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p1) == 1);
c0106401:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106404:	89 04 24             	mov    %eax,(%esp)
c0106407:	e8 58 ec ff ff       	call   c0105064 <page_ref>
c010640c:	83 f8 01             	cmp    $0x1,%eax
c010640f:	74 24                	je     c0106435 <check_pgdir+0x1c5>
c0106411:	c7 44 24 0c c3 da 10 	movl   $0xc010dac3,0xc(%esp)
c0106418:	c0 
c0106419:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106420:	c0 
c0106421:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
c0106428:	00 
c0106429:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106430:	e8 bb a9 ff ff       	call   c0100df0 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106435:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010643a:	8b 00                	mov    (%eax),%eax
c010643c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106441:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106444:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106447:	c1 e8 0c             	shr    $0xc,%eax
c010644a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010644d:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0106452:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106455:	72 23                	jb     c010647a <check_pgdir+0x20a>
c0106457:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010645a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010645e:	c7 44 24 08 04 d8 10 	movl   $0xc010d804,0x8(%esp)
c0106465:	c0 
c0106466:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
c010646d:	00 
c010646e:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106475:	e8 76 a9 ff ff       	call   c0100df0 <__panic>
c010647a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010647d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106482:	83 c0 04             	add    $0x4,%eax
c0106485:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106488:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010648d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106494:	00 
c0106495:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010649c:	00 
c010649d:	89 04 24             	mov    %eax,(%esp)
c01064a0:	e8 8a f4 ff ff       	call   c010592f <get_pte>
c01064a5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01064a8:	74 24                	je     c01064ce <check_pgdir+0x25e>
c01064aa:	c7 44 24 0c d8 da 10 	movl   $0xc010dad8,0xc(%esp)
c01064b1:	c0 
c01064b2:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01064b9:	c0 
c01064ba:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
c01064c1:	00 
c01064c2:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01064c9:	e8 22 a9 ff ff       	call   c0100df0 <__panic>

    p2 = alloc_page();
c01064ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01064d5:	e8 9a ed ff ff       	call   c0105274 <alloc_pages>
c01064da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01064dd:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01064e2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01064e9:	00 
c01064ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01064f1:	00 
c01064f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064f5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064f9:	89 04 24             	mov    %eax,(%esp)
c01064fc:	e8 5e fb ff ff       	call   c010605f <page_insert>
c0106501:	85 c0                	test   %eax,%eax
c0106503:	74 24                	je     c0106529 <check_pgdir+0x2b9>
c0106505:	c7 44 24 0c 00 db 10 	movl   $0xc010db00,0xc(%esp)
c010650c:	c0 
c010650d:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106514:	c0 
c0106515:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
c010651c:	00 
c010651d:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106524:	e8 c7 a8 ff ff       	call   c0100df0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106529:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010652e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106535:	00 
c0106536:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010653d:	00 
c010653e:	89 04 24             	mov    %eax,(%esp)
c0106541:	e8 e9 f3 ff ff       	call   c010592f <get_pte>
c0106546:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106549:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010654d:	75 24                	jne    c0106573 <check_pgdir+0x303>
c010654f:	c7 44 24 0c 38 db 10 	movl   $0xc010db38,0xc(%esp)
c0106556:	c0 
c0106557:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010655e:	c0 
c010655f:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
c0106566:	00 
c0106567:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010656e:	e8 7d a8 ff ff       	call   c0100df0 <__panic>
    assert(*ptep & PTE_U);
c0106573:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106576:	8b 00                	mov    (%eax),%eax
c0106578:	83 e0 04             	and    $0x4,%eax
c010657b:	85 c0                	test   %eax,%eax
c010657d:	75 24                	jne    c01065a3 <check_pgdir+0x333>
c010657f:	c7 44 24 0c 68 db 10 	movl   $0xc010db68,0xc(%esp)
c0106586:	c0 
c0106587:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010658e:	c0 
c010658f:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
c0106596:	00 
c0106597:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010659e:	e8 4d a8 ff ff       	call   c0100df0 <__panic>
    assert(*ptep & PTE_W);
c01065a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065a6:	8b 00                	mov    (%eax),%eax
c01065a8:	83 e0 02             	and    $0x2,%eax
c01065ab:	85 c0                	test   %eax,%eax
c01065ad:	75 24                	jne    c01065d3 <check_pgdir+0x363>
c01065af:	c7 44 24 0c 76 db 10 	movl   $0xc010db76,0xc(%esp)
c01065b6:	c0 
c01065b7:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01065be:	c0 
c01065bf:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c01065c6:	00 
c01065c7:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01065ce:	e8 1d a8 ff ff       	call   c0100df0 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01065d3:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01065d8:	8b 00                	mov    (%eax),%eax
c01065da:	83 e0 04             	and    $0x4,%eax
c01065dd:	85 c0                	test   %eax,%eax
c01065df:	75 24                	jne    c0106605 <check_pgdir+0x395>
c01065e1:	c7 44 24 0c 84 db 10 	movl   $0xc010db84,0xc(%esp)
c01065e8:	c0 
c01065e9:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01065f0:	c0 
c01065f1:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c01065f8:	00 
c01065f9:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106600:	e8 eb a7 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 1);
c0106605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106608:	89 04 24             	mov    %eax,(%esp)
c010660b:	e8 54 ea ff ff       	call   c0105064 <page_ref>
c0106610:	83 f8 01             	cmp    $0x1,%eax
c0106613:	74 24                	je     c0106639 <check_pgdir+0x3c9>
c0106615:	c7 44 24 0c 9a db 10 	movl   $0xc010db9a,0xc(%esp)
c010661c:	c0 
c010661d:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106624:	c0 
c0106625:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c010662c:	00 
c010662d:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106634:	e8 b7 a7 ff ff       	call   c0100df0 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0106639:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010663e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106645:	00 
c0106646:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010664d:	00 
c010664e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106651:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106655:	89 04 24             	mov    %eax,(%esp)
c0106658:	e8 02 fa ff ff       	call   c010605f <page_insert>
c010665d:	85 c0                	test   %eax,%eax
c010665f:	74 24                	je     c0106685 <check_pgdir+0x415>
c0106661:	c7 44 24 0c ac db 10 	movl   $0xc010dbac,0xc(%esp)
c0106668:	c0 
c0106669:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106670:	c0 
c0106671:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
c0106678:	00 
c0106679:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106680:	e8 6b a7 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p1) == 2);
c0106685:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106688:	89 04 24             	mov    %eax,(%esp)
c010668b:	e8 d4 e9 ff ff       	call   c0105064 <page_ref>
c0106690:	83 f8 02             	cmp    $0x2,%eax
c0106693:	74 24                	je     c01066b9 <check_pgdir+0x449>
c0106695:	c7 44 24 0c d8 db 10 	movl   $0xc010dbd8,0xc(%esp)
c010669c:	c0 
c010669d:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01066a4:	c0 
c01066a5:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c01066ac:	00 
c01066ad:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01066b4:	e8 37 a7 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c01066b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066bc:	89 04 24             	mov    %eax,(%esp)
c01066bf:	e8 a0 e9 ff ff       	call   c0105064 <page_ref>
c01066c4:	85 c0                	test   %eax,%eax
c01066c6:	74 24                	je     c01066ec <check_pgdir+0x47c>
c01066c8:	c7 44 24 0c ea db 10 	movl   $0xc010dbea,0xc(%esp)
c01066cf:	c0 
c01066d0:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01066d7:	c0 
c01066d8:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c01066df:	00 
c01066e0:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01066e7:	e8 04 a7 ff ff       	call   c0100df0 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01066ec:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01066f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01066f8:	00 
c01066f9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106700:	00 
c0106701:	89 04 24             	mov    %eax,(%esp)
c0106704:	e8 26 f2 ff ff       	call   c010592f <get_pte>
c0106709:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010670c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106710:	75 24                	jne    c0106736 <check_pgdir+0x4c6>
c0106712:	c7 44 24 0c 38 db 10 	movl   $0xc010db38,0xc(%esp)
c0106719:	c0 
c010671a:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106721:	c0 
c0106722:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c0106729:	00 
c010672a:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106731:	e8 ba a6 ff ff       	call   c0100df0 <__panic>
    assert(pte2page(*ptep) == p1);
c0106736:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106739:	8b 00                	mov    (%eax),%eax
c010673b:	89 04 24             	mov    %eax,(%esp)
c010673e:	e8 c7 e8 ff ff       	call   c010500a <pte2page>
c0106743:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0106746:	74 24                	je     c010676c <check_pgdir+0x4fc>
c0106748:	c7 44 24 0c ad da 10 	movl   $0xc010daad,0xc(%esp)
c010674f:	c0 
c0106750:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106757:	c0 
c0106758:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c010675f:	00 
c0106760:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106767:	e8 84 a6 ff ff       	call   c0100df0 <__panic>
    assert((*ptep & PTE_U) == 0);
c010676c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010676f:	8b 00                	mov    (%eax),%eax
c0106771:	83 e0 04             	and    $0x4,%eax
c0106774:	85 c0                	test   %eax,%eax
c0106776:	74 24                	je     c010679c <check_pgdir+0x52c>
c0106778:	c7 44 24 0c fc db 10 	movl   $0xc010dbfc,0xc(%esp)
c010677f:	c0 
c0106780:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106787:	c0 
c0106788:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c010678f:	00 
c0106790:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106797:	e8 54 a6 ff ff       	call   c0100df0 <__panic>

    page_remove(boot_pgdir, 0x0);
c010679c:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01067a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01067a8:	00 
c01067a9:	89 04 24             	mov    %eax,(%esp)
c01067ac:	e8 67 f8 ff ff       	call   c0106018 <page_remove>
    assert(page_ref(p1) == 1);
c01067b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067b4:	89 04 24             	mov    %eax,(%esp)
c01067b7:	e8 a8 e8 ff ff       	call   c0105064 <page_ref>
c01067bc:	83 f8 01             	cmp    $0x1,%eax
c01067bf:	74 24                	je     c01067e5 <check_pgdir+0x575>
c01067c1:	c7 44 24 0c c3 da 10 	movl   $0xc010dac3,0xc(%esp)
c01067c8:	c0 
c01067c9:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01067d0:	c0 
c01067d1:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
c01067d8:	00 
c01067d9:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01067e0:	e8 0b a6 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c01067e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067e8:	89 04 24             	mov    %eax,(%esp)
c01067eb:	e8 74 e8 ff ff       	call   c0105064 <page_ref>
c01067f0:	85 c0                	test   %eax,%eax
c01067f2:	74 24                	je     c0106818 <check_pgdir+0x5a8>
c01067f4:	c7 44 24 0c ea db 10 	movl   $0xc010dbea,0xc(%esp)
c01067fb:	c0 
c01067fc:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106803:	c0 
c0106804:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
c010680b:	00 
c010680c:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106813:	e8 d8 a5 ff ff       	call   c0100df0 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106818:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010681d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106824:	00 
c0106825:	89 04 24             	mov    %eax,(%esp)
c0106828:	e8 eb f7 ff ff       	call   c0106018 <page_remove>
    assert(page_ref(p1) == 0);
c010682d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106830:	89 04 24             	mov    %eax,(%esp)
c0106833:	e8 2c e8 ff ff       	call   c0105064 <page_ref>
c0106838:	85 c0                	test   %eax,%eax
c010683a:	74 24                	je     c0106860 <check_pgdir+0x5f0>
c010683c:	c7 44 24 0c 11 dc 10 	movl   $0xc010dc11,0xc(%esp)
c0106843:	c0 
c0106844:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010684b:	c0 
c010684c:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0106853:	00 
c0106854:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010685b:	e8 90 a5 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p2) == 0);
c0106860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106863:	89 04 24             	mov    %eax,(%esp)
c0106866:	e8 f9 e7 ff ff       	call   c0105064 <page_ref>
c010686b:	85 c0                	test   %eax,%eax
c010686d:	74 24                	je     c0106893 <check_pgdir+0x623>
c010686f:	c7 44 24 0c ea db 10 	movl   $0xc010dbea,0xc(%esp)
c0106876:	c0 
c0106877:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c010687e:	c0 
c010687f:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
c0106886:	00 
c0106887:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010688e:	e8 5d a5 ff ff       	call   c0100df0 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0106893:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106898:	8b 00                	mov    (%eax),%eax
c010689a:	89 04 24             	mov    %eax,(%esp)
c010689d:	e8 a8 e7 ff ff       	call   c010504a <pde2page>
c01068a2:	89 04 24             	mov    %eax,(%esp)
c01068a5:	e8 ba e7 ff ff       	call   c0105064 <page_ref>
c01068aa:	83 f8 01             	cmp    $0x1,%eax
c01068ad:	74 24                	je     c01068d3 <check_pgdir+0x663>
c01068af:	c7 44 24 0c 24 dc 10 	movl   $0xc010dc24,0xc(%esp)
c01068b6:	c0 
c01068b7:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01068be:	c0 
c01068bf:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
c01068c6:	00 
c01068c7:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01068ce:	e8 1d a5 ff ff       	call   c0100df0 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01068d3:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01068d8:	8b 00                	mov    (%eax),%eax
c01068da:	89 04 24             	mov    %eax,(%esp)
c01068dd:	e8 68 e7 ff ff       	call   c010504a <pde2page>
c01068e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01068e9:	00 
c01068ea:	89 04 24             	mov    %eax,(%esp)
c01068ed:	e8 ef e9 ff ff       	call   c01052e1 <free_pages>
    boot_pgdir[0] = 0;
c01068f2:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01068f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01068fd:	c7 04 24 4b dc 10 c0 	movl   $0xc010dc4b,(%esp)
c0106904:	e8 69 9a ff ff       	call   c0100372 <cprintf>
}
c0106909:	90                   	nop
c010690a:	89 ec                	mov    %ebp,%esp
c010690c:	5d                   	pop    %ebp
c010690d:	c3                   	ret    

c010690e <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c010690e:	55                   	push   %ebp
c010690f:	89 e5                	mov    %esp,%ebp
c0106911:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106914:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010691b:	e9 ca 00 00 00       	jmp    c01069ea <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0106920:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106923:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106929:	c1 e8 0c             	shr    $0xc,%eax
c010692c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010692f:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0106934:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106937:	72 23                	jb     c010695c <check_boot_pgdir+0x4e>
c0106939:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010693c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106940:	c7 44 24 08 04 d8 10 	movl   $0xc010d804,0x8(%esp)
c0106947:	c0 
c0106948:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
c010694f:	00 
c0106950:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106957:	e8 94 a4 ff ff       	call   c0100df0 <__panic>
c010695c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010695f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106964:	89 c2                	mov    %eax,%edx
c0106966:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c010696b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106972:	00 
c0106973:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106977:	89 04 24             	mov    %eax,(%esp)
c010697a:	e8 b0 ef ff ff       	call   c010592f <get_pte>
c010697f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106982:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106986:	75 24                	jne    c01069ac <check_boot_pgdir+0x9e>
c0106988:	c7 44 24 0c 68 dc 10 	movl   $0xc010dc68,0xc(%esp)
c010698f:	c0 
c0106990:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106997:	c0 
c0106998:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
c010699f:	00 
c01069a0:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01069a7:	e8 44 a4 ff ff       	call   c0100df0 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01069ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01069af:	8b 00                	mov    (%eax),%eax
c01069b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01069b6:	89 c2                	mov    %eax,%edx
c01069b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069bb:	39 c2                	cmp    %eax,%edx
c01069bd:	74 24                	je     c01069e3 <check_boot_pgdir+0xd5>
c01069bf:	c7 44 24 0c a5 dc 10 	movl   $0xc010dca5,0xc(%esp)
c01069c6:	c0 
c01069c7:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c01069ce:	c0 
c01069cf:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c01069d6:	00 
c01069d7:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c01069de:	e8 0d a4 ff ff       	call   c0100df0 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01069e3:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01069ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01069ed:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01069f2:	39 c2                	cmp    %eax,%edx
c01069f4:	0f 82 26 ff ff ff    	jb     c0106920 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01069fa:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c01069ff:	05 ac 0f 00 00       	add    $0xfac,%eax
c0106a04:	8b 00                	mov    (%eax),%eax
c0106a06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a0b:	89 c2                	mov    %eax,%edx
c0106a0d:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a15:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0106a1c:	77 23                	ja     c0106a41 <check_boot_pgdir+0x133>
c0106a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a21:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106a25:	c7 44 24 08 a8 d8 10 	movl   $0xc010d8a8,0x8(%esp)
c0106a2c:	c0 
c0106a2d:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
c0106a34:	00 
c0106a35:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106a3c:	e8 af a3 ff ff       	call   c0100df0 <__panic>
c0106a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a44:	05 00 00 00 40       	add    $0x40000000,%eax
c0106a49:	39 d0                	cmp    %edx,%eax
c0106a4b:	74 24                	je     c0106a71 <check_boot_pgdir+0x163>
c0106a4d:	c7 44 24 0c bc dc 10 	movl   $0xc010dcbc,0xc(%esp)
c0106a54:	c0 
c0106a55:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106a5c:	c0 
c0106a5d:	c7 44 24 04 c0 02 00 	movl   $0x2c0,0x4(%esp)
c0106a64:	00 
c0106a65:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106a6c:	e8 7f a3 ff ff       	call   c0100df0 <__panic>

    assert(boot_pgdir[0] == 0);
c0106a71:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106a76:	8b 00                	mov    (%eax),%eax
c0106a78:	85 c0                	test   %eax,%eax
c0106a7a:	74 24                	je     c0106aa0 <check_boot_pgdir+0x192>
c0106a7c:	c7 44 24 0c f0 dc 10 	movl   $0xc010dcf0,0xc(%esp)
c0106a83:	c0 
c0106a84:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106a8b:	c0 
c0106a8c:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
c0106a93:	00 
c0106a94:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106a9b:	e8 50 a3 ff ff       	call   c0100df0 <__panic>

    struct Page *p;
    p = alloc_page();
c0106aa0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106aa7:	e8 c8 e7 ff ff       	call   c0105274 <alloc_pages>
c0106aac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106aaf:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106ab4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106abb:	00 
c0106abc:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0106ac3:	00 
c0106ac4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ac7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106acb:	89 04 24             	mov    %eax,(%esp)
c0106ace:	e8 8c f5 ff ff       	call   c010605f <page_insert>
c0106ad3:	85 c0                	test   %eax,%eax
c0106ad5:	74 24                	je     c0106afb <check_boot_pgdir+0x1ed>
c0106ad7:	c7 44 24 0c 04 dd 10 	movl   $0xc010dd04,0xc(%esp)
c0106ade:	c0 
c0106adf:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106ae6:	c0 
c0106ae7:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
c0106aee:	00 
c0106aef:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106af6:	e8 f5 a2 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p) == 1);
c0106afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106afe:	89 04 24             	mov    %eax,(%esp)
c0106b01:	e8 5e e5 ff ff       	call   c0105064 <page_ref>
c0106b06:	83 f8 01             	cmp    $0x1,%eax
c0106b09:	74 24                	je     c0106b2f <check_boot_pgdir+0x221>
c0106b0b:	c7 44 24 0c 32 dd 10 	movl   $0xc010dd32,0xc(%esp)
c0106b12:	c0 
c0106b13:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106b1a:	c0 
c0106b1b:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
c0106b22:	00 
c0106b23:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106b2a:	e8 c1 a2 ff ff       	call   c0100df0 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106b2f:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106b34:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106b3b:	00 
c0106b3c:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106b43:	00 
c0106b44:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b47:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b4b:	89 04 24             	mov    %eax,(%esp)
c0106b4e:	e8 0c f5 ff ff       	call   c010605f <page_insert>
c0106b53:	85 c0                	test   %eax,%eax
c0106b55:	74 24                	je     c0106b7b <check_boot_pgdir+0x26d>
c0106b57:	c7 44 24 0c 44 dd 10 	movl   $0xc010dd44,0xc(%esp)
c0106b5e:	c0 
c0106b5f:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106b66:	c0 
c0106b67:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
c0106b6e:	00 
c0106b6f:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106b76:	e8 75 a2 ff ff       	call   c0100df0 <__panic>
    assert(page_ref(p) == 2);
c0106b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b7e:	89 04 24             	mov    %eax,(%esp)
c0106b81:	e8 de e4 ff ff       	call   c0105064 <page_ref>
c0106b86:	83 f8 02             	cmp    $0x2,%eax
c0106b89:	74 24                	je     c0106baf <check_boot_pgdir+0x2a1>
c0106b8b:	c7 44 24 0c 7b dd 10 	movl   $0xc010dd7b,0xc(%esp)
c0106b92:	c0 
c0106b93:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106b9a:	c0 
c0106b9b:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
c0106ba2:	00 
c0106ba3:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106baa:	e8 41 a2 ff ff       	call   c0100df0 <__panic>

    const char *str = "ucore: Hello world!!";
c0106baf:	c7 45 e8 8c dd 10 c0 	movl   $0xc010dd8c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0106bb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bbd:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106bc4:	e8 58 59 00 00       	call   c010c521 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106bc9:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106bd0:	00 
c0106bd1:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106bd8:	e8 bc 59 00 00       	call   c010c599 <strcmp>
c0106bdd:	85 c0                	test   %eax,%eax
c0106bdf:	74 24                	je     c0106c05 <check_boot_pgdir+0x2f7>
c0106be1:	c7 44 24 0c a4 dd 10 	movl   $0xc010dda4,0xc(%esp)
c0106be8:	c0 
c0106be9:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106bf0:	c0 
c0106bf1:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
c0106bf8:	00 
c0106bf9:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106c00:	e8 eb a1 ff ff       	call   c0100df0 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106c05:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c08:	89 04 24             	mov    %eax,(%esp)
c0106c0b:	e8 a4 e3 ff ff       	call   c0104fb4 <page2kva>
c0106c10:	05 00 01 00 00       	add    $0x100,%eax
c0106c15:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106c18:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106c1f:	e8 a3 58 00 00       	call   c010c4c7 <strlen>
c0106c24:	85 c0                	test   %eax,%eax
c0106c26:	74 24                	je     c0106c4c <check_boot_pgdir+0x33e>
c0106c28:	c7 44 24 0c dc dd 10 	movl   $0xc010dddc,0xc(%esp)
c0106c2f:	c0 
c0106c30:	c7 44 24 08 f1 d8 10 	movl   $0xc010d8f1,0x8(%esp)
c0106c37:	c0 
c0106c38:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
c0106c3f:	00 
c0106c40:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c0106c47:	e8 a4 a1 ff ff       	call   c0100df0 <__panic>

    free_page(p);
c0106c4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c53:	00 
c0106c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c57:	89 04 24             	mov    %eax,(%esp)
c0106c5a:	e8 82 e6 ff ff       	call   c01052e1 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106c5f:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106c64:	8b 00                	mov    (%eax),%eax
c0106c66:	89 04 24             	mov    %eax,(%esp)
c0106c69:	e8 dc e3 ff ff       	call   c010504a <pde2page>
c0106c6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c75:	00 
c0106c76:	89 04 24             	mov    %eax,(%esp)
c0106c79:	e8 63 e6 ff ff       	call   c01052e1 <free_pages>
    boot_pgdir[0] = 0;
c0106c7e:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0106c83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106c89:	c7 04 24 00 de 10 c0 	movl   $0xc010de00,(%esp)
c0106c90:	e8 dd 96 ff ff       	call   c0100372 <cprintf>
}
c0106c95:	90                   	nop
c0106c96:	89 ec                	mov    %ebp,%esp
c0106c98:	5d                   	pop    %ebp
c0106c99:	c3                   	ret    

c0106c9a <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106c9a:	55                   	push   %ebp
c0106c9b:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ca0:	83 e0 04             	and    $0x4,%eax
c0106ca3:	85 c0                	test   %eax,%eax
c0106ca5:	74 04                	je     c0106cab <perm2str+0x11>
c0106ca7:	b0 75                	mov    $0x75,%al
c0106ca9:	eb 02                	jmp    c0106cad <perm2str+0x13>
c0106cab:	b0 2d                	mov    $0x2d,%al
c0106cad:	a2 28 80 1b c0       	mov    %al,0xc01b8028
    str[1] = 'r';
c0106cb2:	c6 05 29 80 1b c0 72 	movb   $0x72,0xc01b8029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106cb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cbc:	83 e0 02             	and    $0x2,%eax
c0106cbf:	85 c0                	test   %eax,%eax
c0106cc1:	74 04                	je     c0106cc7 <perm2str+0x2d>
c0106cc3:	b0 77                	mov    $0x77,%al
c0106cc5:	eb 02                	jmp    c0106cc9 <perm2str+0x2f>
c0106cc7:	b0 2d                	mov    $0x2d,%al
c0106cc9:	a2 2a 80 1b c0       	mov    %al,0xc01b802a
    str[3] = '\0';
c0106cce:	c6 05 2b 80 1b c0 00 	movb   $0x0,0xc01b802b
    return str;
c0106cd5:	b8 28 80 1b c0       	mov    $0xc01b8028,%eax
}
c0106cda:	5d                   	pop    %ebp
c0106cdb:	c3                   	ret    

c0106cdc <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106cdc:	55                   	push   %ebp
c0106cdd:	89 e5                	mov    %esp,%ebp
c0106cdf:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106ce2:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ce5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ce8:	72 0d                	jb     c0106cf7 <get_pgtable_items+0x1b>
        return 0;
c0106cea:	b8 00 00 00 00       	mov    $0x0,%eax
c0106cef:	e9 98 00 00 00       	jmp    c0106d8c <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0106cf4:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0106cf7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cfa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106cfd:	73 18                	jae    c0106d17 <get_pgtable_items+0x3b>
c0106cff:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106d09:	8b 45 14             	mov    0x14(%ebp),%eax
c0106d0c:	01 d0                	add    %edx,%eax
c0106d0e:	8b 00                	mov    (%eax),%eax
c0106d10:	83 e0 01             	and    $0x1,%eax
c0106d13:	85 c0                	test   %eax,%eax
c0106d15:	74 dd                	je     c0106cf4 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106d17:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d1a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106d1d:	73 68                	jae    c0106d87 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0106d1f:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106d23:	74 08                	je     c0106d2d <get_pgtable_items+0x51>
            *left_store = start;
c0106d25:	8b 45 18             	mov    0x18(%ebp),%eax
c0106d28:	8b 55 10             	mov    0x10(%ebp),%edx
c0106d2b:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106d2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d30:	8d 50 01             	lea    0x1(%eax),%edx
c0106d33:	89 55 10             	mov    %edx,0x10(%ebp)
c0106d36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106d3d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106d40:	01 d0                	add    %edx,%eax
c0106d42:	8b 00                	mov    (%eax),%eax
c0106d44:	83 e0 07             	and    $0x7,%eax
c0106d47:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106d4a:	eb 03                	jmp    c0106d4f <get_pgtable_items+0x73>
            start ++;
c0106d4c:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106d4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d52:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106d55:	73 1d                	jae    c0106d74 <get_pgtable_items+0x98>
c0106d57:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106d61:	8b 45 14             	mov    0x14(%ebp),%eax
c0106d64:	01 d0                	add    %edx,%eax
c0106d66:	8b 00                	mov    (%eax),%eax
c0106d68:	83 e0 07             	and    $0x7,%eax
c0106d6b:	89 c2                	mov    %eax,%edx
c0106d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d70:	39 c2                	cmp    %eax,%edx
c0106d72:	74 d8                	je     c0106d4c <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0106d74:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106d78:	74 08                	je     c0106d82 <get_pgtable_items+0xa6>
            *right_store = start;
c0106d7a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106d7d:	8b 55 10             	mov    0x10(%ebp),%edx
c0106d80:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106d82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d85:	eb 05                	jmp    c0106d8c <get_pgtable_items+0xb0>
    }
    return 0;
c0106d87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106d8c:	89 ec                	mov    %ebp,%esp
c0106d8e:	5d                   	pop    %ebp
c0106d8f:	c3                   	ret    

c0106d90 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106d90:	55                   	push   %ebp
c0106d91:	89 e5                	mov    %esp,%ebp
c0106d93:	57                   	push   %edi
c0106d94:	56                   	push   %esi
c0106d95:	53                   	push   %ebx
c0106d96:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106d99:	c7 04 24 20 de 10 c0 	movl   $0xc010de20,(%esp)
c0106da0:	e8 cd 95 ff ff       	call   c0100372 <cprintf>
    size_t left, right = 0, perm;
c0106da5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106dac:	e9 f2 00 00 00       	jmp    c0106ea3 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106db4:	89 04 24             	mov    %eax,(%esp)
c0106db7:	e8 de fe ff ff       	call   c0106c9a <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106dbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106dbf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106dc2:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106dc4:	89 d6                	mov    %edx,%esi
c0106dc6:	c1 e6 16             	shl    $0x16,%esi
c0106dc9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106dcc:	89 d3                	mov    %edx,%ebx
c0106dce:	c1 e3 16             	shl    $0x16,%ebx
c0106dd1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106dd4:	89 d1                	mov    %edx,%ecx
c0106dd6:	c1 e1 16             	shl    $0x16,%ecx
c0106dd9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106ddc:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106ddf:	29 fa                	sub    %edi,%edx
c0106de1:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106de5:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106de9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106ded:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106df1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106df5:	c7 04 24 51 de 10 c0 	movl   $0xc010de51,(%esp)
c0106dfc:	e8 71 95 ff ff       	call   c0100372 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106e01:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e04:	c1 e0 0a             	shl    $0xa,%eax
c0106e07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106e0a:	eb 50                	jmp    c0106e5c <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106e0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e0f:	89 04 24             	mov    %eax,(%esp)
c0106e12:	e8 83 fe ff ff       	call   c0106c9a <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106e17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e1a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0106e1d:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106e1f:	89 d6                	mov    %edx,%esi
c0106e21:	c1 e6 0c             	shl    $0xc,%esi
c0106e24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e27:	89 d3                	mov    %edx,%ebx
c0106e29:	c1 e3 0c             	shl    $0xc,%ebx
c0106e2c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106e2f:	89 d1                	mov    %edx,%ecx
c0106e31:	c1 e1 0c             	shl    $0xc,%ecx
c0106e34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e37:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106e3a:	29 fa                	sub    %edi,%edx
c0106e3c:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106e40:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106e44:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106e4c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e50:	c7 04 24 70 de 10 c0 	movl   $0xc010de70,(%esp)
c0106e57:	e8 16 95 ff ff       	call   c0100372 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106e5c:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0106e61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e64:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e67:	89 d3                	mov    %edx,%ebx
c0106e69:	c1 e3 0a             	shl    $0xa,%ebx
c0106e6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106e6f:	89 d1                	mov    %edx,%ecx
c0106e71:	c1 e1 0a             	shl    $0xa,%ecx
c0106e74:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0106e77:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106e7b:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0106e7e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106e82:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106e86:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106e8e:	89 0c 24             	mov    %ecx,(%esp)
c0106e91:	e8 46 fe ff ff       	call   c0106cdc <get_pgtable_items>
c0106e96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e99:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e9d:	0f 85 69 ff ff ff    	jne    c0106e0c <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106ea3:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0106ea8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106eab:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106eae:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106eb2:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0106eb5:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106ebd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106ec1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106ec8:	00 
c0106ec9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106ed0:	e8 07 fe ff ff       	call   c0106cdc <get_pgtable_items>
c0106ed5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106ed8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106edc:	0f 85 cf fe ff ff    	jne    c0106db1 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106ee2:	c7 04 24 94 de 10 c0 	movl   $0xc010de94,(%esp)
c0106ee9:	e8 84 94 ff ff       	call   c0100372 <cprintf>
}
c0106eee:	90                   	nop
c0106eef:	83 c4 4c             	add    $0x4c,%esp
c0106ef2:	5b                   	pop    %ebx
c0106ef3:	5e                   	pop    %esi
c0106ef4:	5f                   	pop    %edi
c0106ef5:	5d                   	pop    %ebp
c0106ef6:	c3                   	ret    

c0106ef7 <pa2page>:
pa2page(uintptr_t pa) {
c0106ef7:	55                   	push   %ebp
c0106ef8:	89 e5                	mov    %esp,%ebp
c0106efa:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106efd:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f00:	c1 e8 0c             	shr    $0xc,%eax
c0106f03:	89 c2                	mov    %eax,%edx
c0106f05:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0106f0a:	39 c2                	cmp    %eax,%edx
c0106f0c:	72 1c                	jb     c0106f2a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106f0e:	c7 44 24 08 c8 de 10 	movl   $0xc010dec8,0x8(%esp)
c0106f15:	c0 
c0106f16:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106f1d:	00 
c0106f1e:	c7 04 24 e7 de 10 c0 	movl   $0xc010dee7,(%esp)
c0106f25:	e8 c6 9e ff ff       	call   c0100df0 <__panic>
    return &pages[PPN(pa)];
c0106f2a:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0106f30:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f33:	c1 e8 0c             	shr    $0xc,%eax
c0106f36:	c1 e0 05             	shl    $0x5,%eax
c0106f39:	01 d0                	add    %edx,%eax
}
c0106f3b:	89 ec                	mov    %ebp,%esp
c0106f3d:	5d                   	pop    %ebp
c0106f3e:	c3                   	ret    

c0106f3f <pte2page>:
pte2page(pte_t pte) {
c0106f3f:	55                   	push   %ebp
c0106f40:	89 e5                	mov    %esp,%ebp
c0106f42:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106f45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f48:	83 e0 01             	and    $0x1,%eax
c0106f4b:	85 c0                	test   %eax,%eax
c0106f4d:	75 1c                	jne    c0106f6b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106f4f:	c7 44 24 08 f8 de 10 	movl   $0xc010def8,0x8(%esp)
c0106f56:	c0 
c0106f57:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106f5e:	00 
c0106f5f:	c7 04 24 e7 de 10 c0 	movl   $0xc010dee7,(%esp)
c0106f66:	e8 85 9e ff ff       	call   c0100df0 <__panic>
    return pa2page(PTE_ADDR(pte));
c0106f6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f73:	89 04 24             	mov    %eax,(%esp)
c0106f76:	e8 7c ff ff ff       	call   c0106ef7 <pa2page>
}
c0106f7b:	89 ec                	mov    %ebp,%esp
c0106f7d:	5d                   	pop    %ebp
c0106f7e:	c3                   	ret    

c0106f7f <pde2page>:
pde2page(pde_t pde) {
c0106f7f:	55                   	push   %ebp
c0106f80:	89 e5                	mov    %esp,%ebp
c0106f82:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106f85:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f8d:	89 04 24             	mov    %eax,(%esp)
c0106f90:	e8 62 ff ff ff       	call   c0106ef7 <pa2page>
}
c0106f95:	89 ec                	mov    %ebp,%esp
c0106f97:	5d                   	pop    %ebp
c0106f98:	c3                   	ret    

c0106f99 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106f99:	55                   	push   %ebp
c0106f9a:	89 e5                	mov    %esp,%ebp
c0106f9c:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106f9f:	e8 7c 25 00 00       	call   c0109520 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106fa4:	a1 40 80 1b c0       	mov    0xc01b8040,%eax
c0106fa9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106fae:	76 0c                	jbe    c0106fbc <swap_init+0x23>
c0106fb0:	a1 40 80 1b c0       	mov    0xc01b8040,%eax
c0106fb5:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106fba:	76 25                	jbe    c0106fe1 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106fbc:	a1 40 80 1b c0       	mov    0xc01b8040,%eax
c0106fc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106fc5:	c7 44 24 08 19 df 10 	movl   $0xc010df19,0x8(%esp)
c0106fcc:	c0 
c0106fcd:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106fd4:	00 
c0106fd5:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0106fdc:	e8 0f 9e ff ff       	call   c0100df0 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106fe1:	c7 05 00 81 1b c0 60 	movl   $0xc0133a60,0xc01b8100
c0106fe8:	3a 13 c0 
     int r = sm->init();
c0106feb:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c0106ff0:	8b 40 04             	mov    0x4(%eax),%eax
c0106ff3:	ff d0                	call   *%eax
c0106ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106ff8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ffc:	75 26                	jne    c0107024 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106ffe:	c7 05 44 80 1b c0 01 	movl   $0x1,0xc01b8044
c0107005:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0107008:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c010700d:	8b 00                	mov    (%eax),%eax
c010700f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107013:	c7 04 24 43 df 10 c0 	movl   $0xc010df43,(%esp)
c010701a:	e8 53 93 ff ff       	call   c0100372 <cprintf>
          check_swap();
c010701f:	e8 b0 04 00 00       	call   c01074d4 <check_swap>
     }

     return r;
c0107024:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107027:	89 ec                	mov    %ebp,%esp
c0107029:	5d                   	pop    %ebp
c010702a:	c3                   	ret    

c010702b <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c010702b:	55                   	push   %ebp
c010702c:	89 e5                	mov    %esp,%ebp
c010702e:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0107031:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c0107036:	8b 40 08             	mov    0x8(%eax),%eax
c0107039:	8b 55 08             	mov    0x8(%ebp),%edx
c010703c:	89 14 24             	mov    %edx,(%esp)
c010703f:	ff d0                	call   *%eax
}
c0107041:	89 ec                	mov    %ebp,%esp
c0107043:	5d                   	pop    %ebp
c0107044:	c3                   	ret    

c0107045 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0107045:	55                   	push   %ebp
c0107046:	89 e5                	mov    %esp,%ebp
c0107048:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c010704b:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c0107050:	8b 40 0c             	mov    0xc(%eax),%eax
c0107053:	8b 55 08             	mov    0x8(%ebp),%edx
c0107056:	89 14 24             	mov    %edx,(%esp)
c0107059:	ff d0                	call   *%eax
}
c010705b:	89 ec                	mov    %ebp,%esp
c010705d:	5d                   	pop    %ebp
c010705e:	c3                   	ret    

c010705f <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010705f:	55                   	push   %ebp
c0107060:	89 e5                	mov    %esp,%ebp
c0107062:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0107065:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c010706a:	8b 40 10             	mov    0x10(%eax),%eax
c010706d:	8b 55 14             	mov    0x14(%ebp),%edx
c0107070:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107074:	8b 55 10             	mov    0x10(%ebp),%edx
c0107077:	89 54 24 08          	mov    %edx,0x8(%esp)
c010707b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010707e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107082:	8b 55 08             	mov    0x8(%ebp),%edx
c0107085:	89 14 24             	mov    %edx,(%esp)
c0107088:	ff d0                	call   *%eax
}
c010708a:	89 ec                	mov    %ebp,%esp
c010708c:	5d                   	pop    %ebp
c010708d:	c3                   	ret    

c010708e <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010708e:	55                   	push   %ebp
c010708f:	89 e5                	mov    %esp,%ebp
c0107091:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0107094:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c0107099:	8b 40 14             	mov    0x14(%eax),%eax
c010709c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010709f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01070a6:	89 14 24             	mov    %edx,(%esp)
c01070a9:	ff d0                	call   *%eax
}
c01070ab:	89 ec                	mov    %ebp,%esp
c01070ad:	5d                   	pop    %ebp
c01070ae:	c3                   	ret    

c01070af <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01070af:	55                   	push   %ebp
c01070b0:	89 e5                	mov    %esp,%ebp
c01070b2:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01070b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01070bc:	e9 53 01 00 00       	jmp    c0107214 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01070c1:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c01070c6:	8b 40 18             	mov    0x18(%eax),%eax
c01070c9:	8b 55 10             	mov    0x10(%ebp),%edx
c01070cc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01070d0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01070d3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070d7:	8b 55 08             	mov    0x8(%ebp),%edx
c01070da:	89 14 24             	mov    %edx,(%esp)
c01070dd:	ff d0                	call   *%eax
c01070df:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01070e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01070e6:	74 18                	je     c0107100 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01070e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01070ef:	c7 04 24 58 df 10 c0 	movl   $0xc010df58,(%esp)
c01070f6:	e8 77 92 ff ff       	call   c0100372 <cprintf>
c01070fb:	e9 20 01 00 00       	jmp    c0107220 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0107100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107103:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107106:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0107109:	8b 45 08             	mov    0x8(%ebp),%eax
c010710c:	8b 40 0c             	mov    0xc(%eax),%eax
c010710f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107116:	00 
c0107117:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010711a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010711e:	89 04 24             	mov    %eax,(%esp)
c0107121:	e8 09 e8 ff ff       	call   c010592f <get_pte>
c0107126:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0107129:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010712c:	8b 00                	mov    (%eax),%eax
c010712e:	83 e0 01             	and    $0x1,%eax
c0107131:	85 c0                	test   %eax,%eax
c0107133:	75 24                	jne    c0107159 <swap_out+0xaa>
c0107135:	c7 44 24 0c 85 df 10 	movl   $0xc010df85,0xc(%esp)
c010713c:	c0 
c010713d:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107144:	c0 
c0107145:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010714c:	00 
c010714d:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107154:	e8 97 9c ff ff       	call   c0100df0 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0107159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010715c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010715f:	8b 52 1c             	mov    0x1c(%edx),%edx
c0107162:	c1 ea 0c             	shr    $0xc,%edx
c0107165:	42                   	inc    %edx
c0107166:	c1 e2 08             	shl    $0x8,%edx
c0107169:	89 44 24 04          	mov    %eax,0x4(%esp)
c010716d:	89 14 24             	mov    %edx,(%esp)
c0107170:	e8 6a 24 00 00       	call   c01095df <swapfs_write>
c0107175:	85 c0                	test   %eax,%eax
c0107177:	74 34                	je     c01071ad <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0107179:	c7 04 24 af df 10 c0 	movl   $0xc010dfaf,(%esp)
c0107180:	e8 ed 91 ff ff       	call   c0100372 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0107185:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c010718a:	8b 40 10             	mov    0x10(%eax),%eax
c010718d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107190:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107197:	00 
c0107198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010719c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010719f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01071a6:	89 14 24             	mov    %edx,(%esp)
c01071a9:	ff d0                	call   *%eax
c01071ab:	eb 64                	jmp    c0107211 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01071ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071b0:	8b 40 1c             	mov    0x1c(%eax),%eax
c01071b3:	c1 e8 0c             	shr    $0xc,%eax
c01071b6:	40                   	inc    %eax
c01071b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01071bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071be:	89 44 24 08          	mov    %eax,0x8(%esp)
c01071c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01071c9:	c7 04 24 c8 df 10 c0 	movl   $0xc010dfc8,(%esp)
c01071d0:	e8 9d 91 ff ff       	call   c0100372 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01071d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071d8:	8b 40 1c             	mov    0x1c(%eax),%eax
c01071db:	c1 e8 0c             	shr    $0xc,%eax
c01071de:	40                   	inc    %eax
c01071df:	c1 e0 08             	shl    $0x8,%eax
c01071e2:	89 c2                	mov    %eax,%edx
c01071e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01071e7:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01071e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01071ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01071f3:	00 
c01071f4:	89 04 24             	mov    %eax,(%esp)
c01071f7:	e8 e5 e0 ff ff       	call   c01052e1 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c01071fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01071ff:	8b 40 0c             	mov    0xc(%eax),%eax
c0107202:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107205:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107209:	89 04 24             	mov    %eax,(%esp)
c010720c:	e8 09 ef ff ff       	call   c010611a <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0107211:	ff 45 f4             	incl   -0xc(%ebp)
c0107214:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107217:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010721a:	0f 85 a1 fe ff ff    	jne    c01070c1 <swap_out+0x12>
     }
     return i;
c0107220:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107223:	89 ec                	mov    %ebp,%esp
c0107225:	5d                   	pop    %ebp
c0107226:	c3                   	ret    

c0107227 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0107227:	55                   	push   %ebp
c0107228:	89 e5                	mov    %esp,%ebp
c010722a:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c010722d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107234:	e8 3b e0 ff ff       	call   c0105274 <alloc_pages>
c0107239:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010723c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107240:	75 24                	jne    c0107266 <swap_in+0x3f>
c0107242:	c7 44 24 0c 08 e0 10 	movl   $0xc010e008,0xc(%esp)
c0107249:	c0 
c010724a:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107251:	c0 
c0107252:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107259:	00 
c010725a:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107261:	e8 8a 9b ff ff       	call   c0100df0 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107266:	8b 45 08             	mov    0x8(%ebp),%eax
c0107269:	8b 40 0c             	mov    0xc(%eax),%eax
c010726c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107273:	00 
c0107274:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107277:	89 54 24 04          	mov    %edx,0x4(%esp)
c010727b:	89 04 24             	mov    %eax,(%esp)
c010727e:	e8 ac e6 ff ff       	call   c010592f <get_pte>
c0107283:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107286:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107289:	8b 00                	mov    (%eax),%eax
c010728b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010728e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107292:	89 04 24             	mov    %eax,(%esp)
c0107295:	e8 d1 22 00 00       	call   c010956b <swapfs_read>
c010729a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010729d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01072a1:	74 2a                	je     c01072cd <swap_in+0xa6>
     {
        assert(r!=0);
c01072a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01072a7:	75 24                	jne    c01072cd <swap_in+0xa6>
c01072a9:	c7 44 24 0c 15 e0 10 	movl   $0xc010e015,0xc(%esp)
c01072b0:	c0 
c01072b1:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01072b8:	c0 
c01072b9:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c01072c0:	00 
c01072c1:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01072c8:	e8 23 9b ff ff       	call   c0100df0 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01072cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072d0:	8b 00                	mov    (%eax),%eax
c01072d2:	c1 e8 08             	shr    $0x8,%eax
c01072d5:	89 c2                	mov    %eax,%edx
c01072d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01072da:	89 44 24 08          	mov    %eax,0x8(%esp)
c01072de:	89 54 24 04          	mov    %edx,0x4(%esp)
c01072e2:	c7 04 24 1c e0 10 c0 	movl   $0xc010e01c,(%esp)
c01072e9:	e8 84 90 ff ff       	call   c0100372 <cprintf>
     *ptr_result=result;
c01072ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01072f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01072f4:	89 10                	mov    %edx,(%eax)
     return 0;
c01072f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01072fb:	89 ec                	mov    %ebp,%esp
c01072fd:	5d                   	pop    %ebp
c01072fe:	c3                   	ret    

c01072ff <check_content_set>:



static inline void
check_content_set(void)
{
c01072ff:	55                   	push   %ebp
c0107300:	89 e5                	mov    %esp,%ebp
c0107302:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0107305:	b8 00 10 00 00       	mov    $0x1000,%eax
c010730a:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010730d:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107312:	83 f8 01             	cmp    $0x1,%eax
c0107315:	74 24                	je     c010733b <check_content_set+0x3c>
c0107317:	c7 44 24 0c 5a e0 10 	movl   $0xc010e05a,0xc(%esp)
c010731e:	c0 
c010731f:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107326:	c0 
c0107327:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c010732e:	00 
c010732f:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107336:	e8 b5 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c010733b:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107340:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107343:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107348:	83 f8 01             	cmp    $0x1,%eax
c010734b:	74 24                	je     c0107371 <check_content_set+0x72>
c010734d:	c7 44 24 0c 5a e0 10 	movl   $0xc010e05a,0xc(%esp)
c0107354:	c0 
c0107355:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010735c:	c0 
c010735d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107364:	00 
c0107365:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010736c:	e8 7f 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107371:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107376:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107379:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c010737e:	83 f8 02             	cmp    $0x2,%eax
c0107381:	74 24                	je     c01073a7 <check_content_set+0xa8>
c0107383:	c7 44 24 0c 69 e0 10 	movl   $0xc010e069,0xc(%esp)
c010738a:	c0 
c010738b:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107392:	c0 
c0107393:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c010739a:	00 
c010739b:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01073a2:	e8 49 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01073a7:	b8 10 20 00 00       	mov    $0x2010,%eax
c01073ac:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01073af:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c01073b4:	83 f8 02             	cmp    $0x2,%eax
c01073b7:	74 24                	je     c01073dd <check_content_set+0xde>
c01073b9:	c7 44 24 0c 69 e0 10 	movl   $0xc010e069,0xc(%esp)
c01073c0:	c0 
c01073c1:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01073c8:	c0 
c01073c9:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01073d0:	00 
c01073d1:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01073d8:	e8 13 9a ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01073dd:	b8 00 30 00 00       	mov    $0x3000,%eax
c01073e2:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01073e5:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c01073ea:	83 f8 03             	cmp    $0x3,%eax
c01073ed:	74 24                	je     c0107413 <check_content_set+0x114>
c01073ef:	c7 44 24 0c 78 e0 10 	movl   $0xc010e078,0xc(%esp)
c01073f6:	c0 
c01073f7:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01073fe:	c0 
c01073ff:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0107406:	00 
c0107407:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010740e:	e8 dd 99 ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0107413:	b8 10 30 00 00       	mov    $0x3010,%eax
c0107418:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010741b:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107420:	83 f8 03             	cmp    $0x3,%eax
c0107423:	74 24                	je     c0107449 <check_content_set+0x14a>
c0107425:	c7 44 24 0c 78 e0 10 	movl   $0xc010e078,0xc(%esp)
c010742c:	c0 
c010742d:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107434:	c0 
c0107435:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010743c:	00 
c010743d:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107444:	e8 a7 99 ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0107449:	b8 00 40 00 00       	mov    $0x4000,%eax
c010744e:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107451:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107456:	83 f8 04             	cmp    $0x4,%eax
c0107459:	74 24                	je     c010747f <check_content_set+0x180>
c010745b:	c7 44 24 0c 87 e0 10 	movl   $0xc010e087,0xc(%esp)
c0107462:	c0 
c0107463:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010746a:	c0 
c010746b:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0107472:	00 
c0107473:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010747a:	e8 71 99 ff ff       	call   c0100df0 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010747f:	b8 10 40 00 00       	mov    $0x4010,%eax
c0107484:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107487:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c010748c:	83 f8 04             	cmp    $0x4,%eax
c010748f:	74 24                	je     c01074b5 <check_content_set+0x1b6>
c0107491:	c7 44 24 0c 87 e0 10 	movl   $0xc010e087,0xc(%esp)
c0107498:	c0 
c0107499:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01074a0:	c0 
c01074a1:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01074a8:	00 
c01074a9:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01074b0:	e8 3b 99 ff ff       	call   c0100df0 <__panic>
}
c01074b5:	90                   	nop
c01074b6:	89 ec                	mov    %ebp,%esp
c01074b8:	5d                   	pop    %ebp
c01074b9:	c3                   	ret    

c01074ba <check_content_access>:

static inline int
check_content_access(void)
{
c01074ba:	55                   	push   %ebp
c01074bb:	89 e5                	mov    %esp,%ebp
c01074bd:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c01074c0:	a1 00 81 1b c0       	mov    0xc01b8100,%eax
c01074c5:	8b 40 1c             	mov    0x1c(%eax),%eax
c01074c8:	ff d0                	call   *%eax
c01074ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01074cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01074d0:	89 ec                	mov    %ebp,%esp
c01074d2:	5d                   	pop    %ebp
c01074d3:	c3                   	ret    

c01074d4 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01074d4:	55                   	push   %ebp
c01074d5:	89 e5                	mov    %esp,%ebp
c01074d7:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01074da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01074e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01074e8:	c7 45 e8 84 7f 1b c0 	movl   $0xc01b7f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01074ef:	eb 6a                	jmp    c010755b <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c01074f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074f4:	83 e8 0c             	sub    $0xc,%eax
c01074f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c01074fa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01074fd:	83 c0 04             	add    $0x4,%eax
c0107500:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0107507:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010750a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010750d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107510:	0f a3 10             	bt     %edx,(%eax)
c0107513:	19 c0                	sbb    %eax,%eax
c0107515:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0107518:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010751c:	0f 95 c0             	setne  %al
c010751f:	0f b6 c0             	movzbl %al,%eax
c0107522:	85 c0                	test   %eax,%eax
c0107524:	75 24                	jne    c010754a <check_swap+0x76>
c0107526:	c7 44 24 0c 96 e0 10 	movl   $0xc010e096,0xc(%esp)
c010752d:	c0 
c010752e:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107535:	c0 
c0107536:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c010753d:	00 
c010753e:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107545:	e8 a6 98 ff ff       	call   c0100df0 <__panic>
        count ++, total += p->property;
c010754a:	ff 45 f4             	incl   -0xc(%ebp)
c010754d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107550:	8b 50 08             	mov    0x8(%eax),%edx
c0107553:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107556:	01 d0                	add    %edx,%eax
c0107558:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010755b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010755e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107561:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107564:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0107567:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010756a:	81 7d e8 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x18(%ebp)
c0107571:	0f 85 7a ff ff ff    	jne    c01074f1 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0107577:	e8 9a dd ff ff       	call   c0105316 <nr_free_pages>
c010757c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010757f:	39 d0                	cmp    %edx,%eax
c0107581:	74 24                	je     c01075a7 <check_swap+0xd3>
c0107583:	c7 44 24 0c a6 e0 10 	movl   $0xc010e0a6,0xc(%esp)
c010758a:	c0 
c010758b:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107592:	c0 
c0107593:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c010759a:	00 
c010759b:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01075a2:	e8 49 98 ff ff       	call   c0100df0 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01075a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075aa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01075ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075b5:	c7 04 24 c0 e0 10 c0 	movl   $0xc010e0c0,(%esp)
c01075bc:	e8 b1 8d ff ff       	call   c0100372 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01075c1:	e8 32 0c 00 00       	call   c01081f8 <mm_create>
c01075c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c01075c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01075cd:	75 24                	jne    c01075f3 <check_swap+0x11f>
c01075cf:	c7 44 24 0c e6 e0 10 	movl   $0xc010e0e6,0xc(%esp)
c01075d6:	c0 
c01075d7:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01075de:	c0 
c01075df:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c01075e6:	00 
c01075e7:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01075ee:	e8 fd 97 ff ff       	call   c0100df0 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01075f3:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c01075f8:	85 c0                	test   %eax,%eax
c01075fa:	74 24                	je     c0107620 <check_swap+0x14c>
c01075fc:	c7 44 24 0c f1 e0 10 	movl   $0xc010e0f1,0xc(%esp)
c0107603:	c0 
c0107604:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010760b:	c0 
c010760c:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107613:	00 
c0107614:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010761b:	e8 d0 97 ff ff       	call   c0100df0 <__panic>

     check_mm_struct = mm;
c0107620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107623:	a3 0c 81 1b c0       	mov    %eax,0xc01b810c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107628:	8b 15 00 3a 13 c0    	mov    0xc0133a00,%edx
c010762e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107631:	89 50 0c             	mov    %edx,0xc(%eax)
c0107634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107637:	8b 40 0c             	mov    0xc(%eax),%eax
c010763a:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c010763d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107640:	8b 00                	mov    (%eax),%eax
c0107642:	85 c0                	test   %eax,%eax
c0107644:	74 24                	je     c010766a <check_swap+0x196>
c0107646:	c7 44 24 0c 09 e1 10 	movl   $0xc010e109,0xc(%esp)
c010764d:	c0 
c010764e:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107655:	c0 
c0107656:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010765d:	00 
c010765e:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107665:	e8 86 97 ff ff       	call   c0100df0 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010766a:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0107671:	00 
c0107672:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0107679:	00 
c010767a:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0107681:	e8 0e 0c 00 00       	call   c0108294 <vma_create>
c0107686:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0107689:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010768d:	75 24                	jne    c01076b3 <check_swap+0x1df>
c010768f:	c7 44 24 0c 17 e1 10 	movl   $0xc010e117,0xc(%esp)
c0107696:	c0 
c0107697:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010769e:	c0 
c010769f:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01076a6:	00 
c01076a7:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01076ae:	e8 3d 97 ff ff       	call   c0100df0 <__panic>

     insert_vma_struct(mm, vma);
c01076b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01076b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01076ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01076bd:	89 04 24             	mov    %eax,(%esp)
c01076c0:	e8 66 0d 00 00       	call   c010842b <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01076c5:	c7 04 24 24 e1 10 c0 	movl   $0xc010e124,(%esp)
c01076cc:	e8 a1 8c ff ff       	call   c0100372 <cprintf>
     pte_t *temp_ptep=NULL;
c01076d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01076d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01076db:	8b 40 0c             	mov    0xc(%eax),%eax
c01076de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01076e5:	00 
c01076e6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01076ed:	00 
c01076ee:	89 04 24             	mov    %eax,(%esp)
c01076f1:	e8 39 e2 ff ff       	call   c010592f <get_pte>
c01076f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c01076f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01076fd:	75 24                	jne    c0107723 <check_swap+0x24f>
c01076ff:	c7 44 24 0c 58 e1 10 	movl   $0xc010e158,0xc(%esp)
c0107706:	c0 
c0107707:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010770e:	c0 
c010770f:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0107716:	00 
c0107717:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010771e:	e8 cd 96 ff ff       	call   c0100df0 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0107723:	c7 04 24 6c e1 10 c0 	movl   $0xc010e16c,(%esp)
c010772a:	e8 43 8c ff ff       	call   c0100372 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010772f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107736:	e9 a2 00 00 00       	jmp    c01077dd <check_swap+0x309>
          check_rp[i] = alloc_page();
c010773b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107742:	e8 2d db ff ff       	call   c0105274 <alloc_pages>
c0107747:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010774a:	89 04 95 cc 80 1b c0 	mov    %eax,-0x3fe47f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0107751:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107754:	8b 04 85 cc 80 1b c0 	mov    -0x3fe47f34(,%eax,4),%eax
c010775b:	85 c0                	test   %eax,%eax
c010775d:	75 24                	jne    c0107783 <check_swap+0x2af>
c010775f:	c7 44 24 0c 90 e1 10 	movl   $0xc010e190,0xc(%esp)
c0107766:	c0 
c0107767:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010776e:	c0 
c010776f:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0107776:	00 
c0107777:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010777e:	e8 6d 96 ff ff       	call   c0100df0 <__panic>
          assert(!PageProperty(check_rp[i]));
c0107783:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107786:	8b 04 85 cc 80 1b c0 	mov    -0x3fe47f34(,%eax,4),%eax
c010778d:	83 c0 04             	add    $0x4,%eax
c0107790:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0107797:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010779a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010779d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01077a0:	0f a3 10             	bt     %edx,(%eax)
c01077a3:	19 c0                	sbb    %eax,%eax
c01077a5:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01077a8:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01077ac:	0f 95 c0             	setne  %al
c01077af:	0f b6 c0             	movzbl %al,%eax
c01077b2:	85 c0                	test   %eax,%eax
c01077b4:	74 24                	je     c01077da <check_swap+0x306>
c01077b6:	c7 44 24 0c a4 e1 10 	movl   $0xc010e1a4,0xc(%esp)
c01077bd:	c0 
c01077be:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01077c5:	c0 
c01077c6:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01077cd:	00 
c01077ce:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01077d5:	e8 16 96 ff ff       	call   c0100df0 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01077da:	ff 45 ec             	incl   -0x14(%ebp)
c01077dd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01077e1:	0f 8e 54 ff ff ff    	jle    c010773b <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c01077e7:	a1 84 7f 1b c0       	mov    0xc01b7f84,%eax
c01077ec:	8b 15 88 7f 1b c0    	mov    0xc01b7f88,%edx
c01077f2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01077f5:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01077f8:	c7 45 a4 84 7f 1b c0 	movl   $0xc01b7f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c01077ff:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107802:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0107805:	89 50 04             	mov    %edx,0x4(%eax)
c0107808:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010780b:	8b 50 04             	mov    0x4(%eax),%edx
c010780e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107811:	89 10                	mov    %edx,(%eax)
}
c0107813:	90                   	nop
c0107814:	c7 45 a8 84 7f 1b c0 	movl   $0xc01b7f84,-0x58(%ebp)
    return list->next == list;
c010781b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010781e:	8b 40 04             	mov    0x4(%eax),%eax
c0107821:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0107824:	0f 94 c0             	sete   %al
c0107827:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c010782a:	85 c0                	test   %eax,%eax
c010782c:	75 24                	jne    c0107852 <check_swap+0x37e>
c010782e:	c7 44 24 0c bf e1 10 	movl   $0xc010e1bf,0xc(%esp)
c0107835:	c0 
c0107836:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c010783d:	c0 
c010783e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0107845:	00 
c0107846:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c010784d:	e8 9e 95 ff ff       	call   c0100df0 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107852:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c0107857:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c010785a:	c7 05 8c 7f 1b c0 00 	movl   $0x0,0xc01b7f8c
c0107861:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107864:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010786b:	eb 1d                	jmp    c010788a <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c010786d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107870:	8b 04 85 cc 80 1b c0 	mov    -0x3fe47f34(,%eax,4),%eax
c0107877:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010787e:	00 
c010787f:	89 04 24             	mov    %eax,(%esp)
c0107882:	e8 5a da ff ff       	call   c01052e1 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107887:	ff 45 ec             	incl   -0x14(%ebp)
c010788a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010788e:	7e dd                	jle    c010786d <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107890:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c0107895:	83 f8 04             	cmp    $0x4,%eax
c0107898:	74 24                	je     c01078be <check_swap+0x3ea>
c010789a:	c7 44 24 0c d8 e1 10 	movl   $0xc010e1d8,0xc(%esp)
c01078a1:	c0 
c01078a2:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01078a9:	c0 
c01078aa:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01078b1:	00 
c01078b2:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01078b9:	e8 32 95 ff ff       	call   c0100df0 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01078be:	c7 04 24 fc e1 10 c0 	movl   $0xc010e1fc,(%esp)
c01078c5:	e8 a8 8a ff ff       	call   c0100372 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01078ca:	c7 05 10 81 1b c0 00 	movl   $0x0,0xc01b8110
c01078d1:	00 00 00 
     
     check_content_set();
c01078d4:	e8 26 fa ff ff       	call   c01072ff <check_content_set>
     assert( nr_free == 0);         
c01078d9:	a1 8c 7f 1b c0       	mov    0xc01b7f8c,%eax
c01078de:	85 c0                	test   %eax,%eax
c01078e0:	74 24                	je     c0107906 <check_swap+0x432>
c01078e2:	c7 44 24 0c 23 e2 10 	movl   $0xc010e223,0xc(%esp)
c01078e9:	c0 
c01078ea:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01078f1:	c0 
c01078f2:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01078f9:	00 
c01078fa:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107901:	e8 ea 94 ff ff       	call   c0100df0 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107906:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010790d:	eb 25                	jmp    c0107934 <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c010790f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107912:	c7 04 85 60 80 1b c0 	movl   $0xffffffff,-0x3fe47fa0(,%eax,4)
c0107919:	ff ff ff ff 
c010791d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107920:	8b 14 85 60 80 1b c0 	mov    -0x3fe47fa0(,%eax,4),%edx
c0107927:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010792a:	89 14 85 a0 80 1b c0 	mov    %edx,-0x3fe47f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0107931:	ff 45 ec             	incl   -0x14(%ebp)
c0107934:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0107938:	7e d5                	jle    c010790f <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010793a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107941:	e9 e8 00 00 00       	jmp    c0107a2e <check_swap+0x55a>
         check_ptep[i]=0;
c0107946:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107949:	c7 04 85 dc 80 1b c0 	movl   $0x0,-0x3fe47f24(,%eax,4)
c0107950:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107954:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107957:	40                   	inc    %eax
c0107958:	c1 e0 0c             	shl    $0xc,%eax
c010795b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107962:	00 
c0107963:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107967:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010796a:	89 04 24             	mov    %eax,(%esp)
c010796d:	e8 bd df ff ff       	call   c010592f <get_pte>
c0107972:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107975:	89 04 95 dc 80 1b c0 	mov    %eax,-0x3fe47f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010797c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010797f:	8b 04 85 dc 80 1b c0 	mov    -0x3fe47f24(,%eax,4),%eax
c0107986:	85 c0                	test   %eax,%eax
c0107988:	75 24                	jne    c01079ae <check_swap+0x4da>
c010798a:	c7 44 24 0c 30 e2 10 	movl   $0xc010e230,0xc(%esp)
c0107991:	c0 
c0107992:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107999:	c0 
c010799a:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01079a1:	00 
c01079a2:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01079a9:	e8 42 94 ff ff       	call   c0100df0 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01079ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079b1:	8b 04 85 dc 80 1b c0 	mov    -0x3fe47f24(,%eax,4),%eax
c01079b8:	8b 00                	mov    (%eax),%eax
c01079ba:	89 04 24             	mov    %eax,(%esp)
c01079bd:	e8 7d f5 ff ff       	call   c0106f3f <pte2page>
c01079c2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01079c5:	8b 14 95 cc 80 1b c0 	mov    -0x3fe47f34(,%edx,4),%edx
c01079cc:	39 d0                	cmp    %edx,%eax
c01079ce:	74 24                	je     c01079f4 <check_swap+0x520>
c01079d0:	c7 44 24 0c 48 e2 10 	movl   $0xc010e248,0xc(%esp)
c01079d7:	c0 
c01079d8:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c01079df:	c0 
c01079e0:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01079e7:	00 
c01079e8:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c01079ef:	e8 fc 93 ff ff       	call   c0100df0 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01079f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079f7:	8b 04 85 dc 80 1b c0 	mov    -0x3fe47f24(,%eax,4),%eax
c01079fe:	8b 00                	mov    (%eax),%eax
c0107a00:	83 e0 01             	and    $0x1,%eax
c0107a03:	85 c0                	test   %eax,%eax
c0107a05:	75 24                	jne    c0107a2b <check_swap+0x557>
c0107a07:	c7 44 24 0c 70 e2 10 	movl   $0xc010e270,0xc(%esp)
c0107a0e:	c0 
c0107a0f:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107a16:	c0 
c0107a17:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0107a1e:	00 
c0107a1f:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107a26:	e8 c5 93 ff ff       	call   c0100df0 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107a2b:	ff 45 ec             	incl   -0x14(%ebp)
c0107a2e:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107a32:	0f 8e 0e ff ff ff    	jle    c0107946 <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c0107a38:	c7 04 24 8c e2 10 c0 	movl   $0xc010e28c,(%esp)
c0107a3f:	e8 2e 89 ff ff       	call   c0100372 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0107a44:	e8 71 fa ff ff       	call   c01074ba <check_content_access>
c0107a49:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0107a4c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107a50:	74 24                	je     c0107a76 <check_swap+0x5a2>
c0107a52:	c7 44 24 0c b2 e2 10 	movl   $0xc010e2b2,0xc(%esp)
c0107a59:	c0 
c0107a5a:	c7 44 24 08 9a df 10 	movl   $0xc010df9a,0x8(%esp)
c0107a61:	c0 
c0107a62:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0107a69:	00 
c0107a6a:	c7 04 24 34 df 10 c0 	movl   $0xc010df34,(%esp)
c0107a71:	e8 7a 93 ff ff       	call   c0100df0 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107a7d:	eb 1d                	jmp    c0107a9c <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0107a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a82:	8b 04 85 cc 80 1b c0 	mov    -0x3fe47f34(,%eax,4),%eax
c0107a89:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a90:	00 
c0107a91:	89 04 24             	mov    %eax,(%esp)
c0107a94:	e8 48 d8 ff ff       	call   c01052e1 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107a99:	ff 45 ec             	incl   -0x14(%ebp)
c0107a9c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107aa0:	7e dd                	jle    c0107a7f <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0107aa2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107aa5:	8b 00                	mov    (%eax),%eax
c0107aa7:	89 04 24             	mov    %eax,(%esp)
c0107aaa:	e8 d0 f4 ff ff       	call   c0106f7f <pde2page>
c0107aaf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107ab6:	00 
c0107ab7:	89 04 24             	mov    %eax,(%esp)
c0107aba:	e8 22 d8 ff ff       	call   c01052e1 <free_pages>
     pgdir[0] = 0;
c0107abf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ac2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0107ac8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107acb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0107ad2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ad5:	89 04 24             	mov    %eax,(%esp)
c0107ad8:	e8 84 0a 00 00       	call   c0108561 <mm_destroy>
     check_mm_struct = NULL;
c0107add:	c7 05 0c 81 1b c0 00 	movl   $0x0,0xc01b810c
c0107ae4:	00 00 00 
     
     nr_free = nr_free_store;
c0107ae7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107aea:	a3 8c 7f 1b c0       	mov    %eax,0xc01b7f8c
     free_list = free_list_store;
c0107aef:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107af2:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107af5:	a3 84 7f 1b c0       	mov    %eax,0xc01b7f84
c0107afa:	89 15 88 7f 1b c0    	mov    %edx,0xc01b7f88

     
     le = &free_list;
c0107b00:	c7 45 e8 84 7f 1b c0 	movl   $0xc01b7f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107b07:	eb 1c                	jmp    c0107b25 <check_swap+0x651>
         struct Page *p = le2page(le, page_link);
c0107b09:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b0c:	83 e8 0c             	sub    $0xc,%eax
c0107b0f:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0107b12:	ff 4d f4             	decl   -0xc(%ebp)
c0107b15:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107b18:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107b1b:	8b 48 08             	mov    0x8(%eax),%ecx
c0107b1e:	89 d0                	mov    %edx,%eax
c0107b20:	29 c8                	sub    %ecx,%eax
c0107b22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107b25:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b28:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0107b2b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107b2e:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0107b31:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107b34:	81 7d e8 84 7f 1b c0 	cmpl   $0xc01b7f84,-0x18(%ebp)
c0107b3b:	75 cc                	jne    c0107b09 <check_swap+0x635>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b40:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b4b:	c7 04 24 b9 e2 10 c0 	movl   $0xc010e2b9,(%esp)
c0107b52:	e8 1b 88 ff ff       	call   c0100372 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107b57:	c7 04 24 d3 e2 10 c0 	movl   $0xc010e2d3,(%esp)
c0107b5e:	e8 0f 88 ff ff       	call   c0100372 <cprintf>
}
c0107b63:	90                   	nop
c0107b64:	89 ec                	mov    %ebp,%esp
c0107b66:	5d                   	pop    %ebp
c0107b67:	c3                   	ret    

c0107b68 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0107b68:	55                   	push   %ebp
c0107b69:	89 e5                	mov    %esp,%ebp
c0107b6b:	83 ec 10             	sub    $0x10,%esp
c0107b6e:	c7 45 fc 04 81 1b c0 	movl   $0xc01b8104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107b75:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b78:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107b7b:	89 50 04             	mov    %edx,0x4(%eax)
c0107b7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b81:	8b 50 04             	mov    0x4(%eax),%edx
c0107b84:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b87:	89 10                	mov    %edx,(%eax)
}
c0107b89:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b8d:	c7 40 14 04 81 1b c0 	movl   $0xc01b8104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b99:	89 ec                	mov    %ebp,%esp
c0107b9b:	5d                   	pop    %ebp
c0107b9c:	c3                   	ret    

c0107b9d <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107b9d:	55                   	push   %ebp
c0107b9e:	89 e5                	mov    %esp,%ebp
c0107ba0:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ba6:	8b 40 14             	mov    0x14(%eax),%eax
c0107ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107bac:	8b 45 10             	mov    0x10(%ebp),%eax
c0107baf:	83 c0 14             	add    $0x14,%eax
c0107bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107bb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107bb9:	74 06                	je     c0107bc1 <_fifo_map_swappable+0x24>
c0107bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107bbf:	75 24                	jne    c0107be5 <_fifo_map_swappable+0x48>
c0107bc1:	c7 44 24 0c ec e2 10 	movl   $0xc010e2ec,0xc(%esp)
c0107bc8:	c0 
c0107bc9:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107bd0:	c0 
c0107bd1:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107bd8:	00 
c0107bd9:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107be0:	e8 0b 92 ff ff       	call   c0100df0 <__panic>
c0107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bee:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107bf7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107bfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c00:	8b 40 04             	mov    0x4(%eax),%eax
c0107c03:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107c06:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107c09:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c0c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107c0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0107c12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c15:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c18:	89 10                	mov    %edx,(%eax)
c0107c1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c1d:	8b 10                	mov    (%eax),%edx
c0107c1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c22:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107c25:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107c2b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107c2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c31:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107c34:	89 10                	mov    %edx,(%eax)
}
c0107c36:	90                   	nop
}
c0107c37:	90                   	nop
}
c0107c38:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0107c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107c3e:	89 ec                	mov    %ebp,%esp
c0107c40:	5d                   	pop    %ebp
c0107c41:	c3                   	ret    

c0107c42 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107c42:	55                   	push   %ebp
c0107c43:	89 e5                	mov    %esp,%ebp
c0107c45:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107c48:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c4b:	8b 40 14             	mov    0x14(%eax),%eax
c0107c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107c51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107c55:	75 24                	jne    c0107c7b <_fifo_swap_out_victim+0x39>
c0107c57:	c7 44 24 0c 33 e3 10 	movl   $0xc010e333,0xc(%esp)
c0107c5e:	c0 
c0107c5f:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107c66:	c0 
c0107c67:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107c6e:	00 
c0107c6f:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107c76:	e8 75 91 ff ff       	call   c0100df0 <__panic>
     assert(in_tick==0);
c0107c7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107c7f:	74 24                	je     c0107ca5 <_fifo_swap_out_victim+0x63>
c0107c81:	c7 44 24 0c 40 e3 10 	movl   $0xc010e340,0xc(%esp)
c0107c88:	c0 
c0107c89:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107c90:	c0 
c0107c91:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107c98:	00 
c0107c99:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107ca0:	e8 4b 91 ff ff       	call   c0100df0 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     list_entry_t *le = head->prev;
c0107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ca8:	8b 00                	mov    (%eax),%eax
c0107caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cb0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107cb3:	75 24                	jne    c0107cd9 <_fifo_swap_out_victim+0x97>
c0107cb5:	c7 44 24 0c 4b e3 10 	movl   $0xc010e34b,0xc(%esp)
c0107cbc:	c0 
c0107cbd:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107cc4:	c0 
c0107cc5:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107ccc:	00 
c0107ccd:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107cd4:	e8 17 91 ff ff       	call   c0100df0 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0107cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cdc:	83 e8 14             	sub    $0x14,%eax
c0107cdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ce5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107ce8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ceb:	8b 40 04             	mov    0x4(%eax),%eax
c0107cee:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107cf1:	8b 12                	mov    (%edx),%edx
c0107cf3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c0107cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cfc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107cff:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107d02:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d05:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d08:	89 10                	mov    %edx,(%eax)
}
c0107d0a:	90                   	nop
}
c0107d0b:	90                   	nop
     list_del(le);
     assert(p !=NULL);
c0107d0c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107d10:	75 24                	jne    c0107d36 <_fifo_swap_out_victim+0xf4>
c0107d12:	c7 44 24 0c 54 e3 10 	movl   $0xc010e354,0xc(%esp)
c0107d19:	c0 
c0107d1a:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107d21:	c0 
c0107d22:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c0107d29:	00 
c0107d2a:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107d31:	e8 ba 90 ff ff       	call   c0100df0 <__panic>
     *ptr_page = p;
c0107d36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d39:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d3c:	89 10                	mov    %edx,(%eax)
     return 0;
c0107d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107d43:	89 ec                	mov    %ebp,%esp
c0107d45:	5d                   	pop    %ebp
c0107d46:	c3                   	ret    

c0107d47 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107d47:	55                   	push   %ebp
c0107d48:	89 e5                	mov    %esp,%ebp
c0107d4a:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107d4d:	c7 04 24 60 e3 10 c0 	movl   $0xc010e360,(%esp)
c0107d54:	e8 19 86 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107d59:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107d5e:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107d61:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107d66:	83 f8 04             	cmp    $0x4,%eax
c0107d69:	74 24                	je     c0107d8f <_fifo_check_swap+0x48>
c0107d6b:	c7 44 24 0c 86 e3 10 	movl   $0xc010e386,0xc(%esp)
c0107d72:	c0 
c0107d73:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107d7a:	c0 
c0107d7b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107d82:	00 
c0107d83:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107d8a:	e8 61 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107d8f:	c7 04 24 98 e3 10 c0 	movl   $0xc010e398,(%esp)
c0107d96:	e8 d7 85 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107d9b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107da0:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107da3:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107da8:	83 f8 04             	cmp    $0x4,%eax
c0107dab:	74 24                	je     c0107dd1 <_fifo_check_swap+0x8a>
c0107dad:	c7 44 24 0c 86 e3 10 	movl   $0xc010e386,0xc(%esp)
c0107db4:	c0 
c0107db5:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107dbc:	c0 
c0107dbd:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0107dc4:	00 
c0107dc5:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107dcc:	e8 1f 90 ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107dd1:	c7 04 24 c0 e3 10 c0 	movl   $0xc010e3c0,(%esp)
c0107dd8:	e8 95 85 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107ddd:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107de2:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107de5:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107dea:	83 f8 04             	cmp    $0x4,%eax
c0107ded:	74 24                	je     c0107e13 <_fifo_check_swap+0xcc>
c0107def:	c7 44 24 0c 86 e3 10 	movl   $0xc010e386,0xc(%esp)
c0107df6:	c0 
c0107df7:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107dfe:	c0 
c0107dff:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107e06:	00 
c0107e07:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107e0e:	e8 dd 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107e13:	c7 04 24 e8 e3 10 c0 	movl   $0xc010e3e8,(%esp)
c0107e1a:	e8 53 85 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107e1f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107e24:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107e27:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107e2c:	83 f8 04             	cmp    $0x4,%eax
c0107e2f:	74 24                	je     c0107e55 <_fifo_check_swap+0x10e>
c0107e31:	c7 44 24 0c 86 e3 10 	movl   $0xc010e386,0xc(%esp)
c0107e38:	c0 
c0107e39:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107e40:	c0 
c0107e41:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c0107e48:	00 
c0107e49:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107e50:	e8 9b 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107e55:	c7 04 24 10 e4 10 c0 	movl   $0xc010e410,(%esp)
c0107e5c:	e8 11 85 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107e61:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107e66:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107e69:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107e6e:	83 f8 05             	cmp    $0x5,%eax
c0107e71:	74 24                	je     c0107e97 <_fifo_check_swap+0x150>
c0107e73:	c7 44 24 0c 36 e4 10 	movl   $0xc010e436,0xc(%esp)
c0107e7a:	c0 
c0107e7b:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107e82:	c0 
c0107e83:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0107e8a:	00 
c0107e8b:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107e92:	e8 59 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107e97:	c7 04 24 e8 e3 10 c0 	movl   $0xc010e3e8,(%esp)
c0107e9e:	e8 cf 84 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107ea3:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107ea8:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107eab:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107eb0:	83 f8 05             	cmp    $0x5,%eax
c0107eb3:	74 24                	je     c0107ed9 <_fifo_check_swap+0x192>
c0107eb5:	c7 44 24 0c 36 e4 10 	movl   $0xc010e436,0xc(%esp)
c0107ebc:	c0 
c0107ebd:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107ec4:	c0 
c0107ec5:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107ecc:	00 
c0107ecd:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107ed4:	e8 17 8f ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107ed9:	c7 04 24 98 e3 10 c0 	movl   $0xc010e398,(%esp)
c0107ee0:	e8 8d 84 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107ee5:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107eea:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107eed:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107ef2:	83 f8 06             	cmp    $0x6,%eax
c0107ef5:	74 24                	je     c0107f1b <_fifo_check_swap+0x1d4>
c0107ef7:	c7 44 24 0c 45 e4 10 	movl   $0xc010e445,0xc(%esp)
c0107efe:	c0 
c0107eff:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107f06:	c0 
c0107f07:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107f0e:	00 
c0107f0f:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107f16:	e8 d5 8e ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107f1b:	c7 04 24 e8 e3 10 c0 	movl   $0xc010e3e8,(%esp)
c0107f22:	e8 4b 84 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107f27:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107f2c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107f2f:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107f34:	83 f8 07             	cmp    $0x7,%eax
c0107f37:	74 24                	je     c0107f5d <_fifo_check_swap+0x216>
c0107f39:	c7 44 24 0c 54 e4 10 	movl   $0xc010e454,0xc(%esp)
c0107f40:	c0 
c0107f41:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107f48:	c0 
c0107f49:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107f50:	00 
c0107f51:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107f58:	e8 93 8e ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107f5d:	c7 04 24 60 e3 10 c0 	movl   $0xc010e360,(%esp)
c0107f64:	e8 09 84 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107f69:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107f6e:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107f71:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107f76:	83 f8 08             	cmp    $0x8,%eax
c0107f79:	74 24                	je     c0107f9f <_fifo_check_swap+0x258>
c0107f7b:	c7 44 24 0c 63 e4 10 	movl   $0xc010e463,0xc(%esp)
c0107f82:	c0 
c0107f83:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107f8a:	c0 
c0107f8b:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107f92:	00 
c0107f93:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107f9a:	e8 51 8e ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107f9f:	c7 04 24 c0 e3 10 c0 	movl   $0xc010e3c0,(%esp)
c0107fa6:	e8 c7 83 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107fab:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107fb0:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107fb3:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107fb8:	83 f8 09             	cmp    $0x9,%eax
c0107fbb:	74 24                	je     c0107fe1 <_fifo_check_swap+0x29a>
c0107fbd:	c7 44 24 0c 72 e4 10 	movl   $0xc010e472,0xc(%esp)
c0107fc4:	c0 
c0107fc5:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0107fcc:	c0 
c0107fcd:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0107fd4:	00 
c0107fd5:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0107fdc:	e8 0f 8e ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107fe1:	c7 04 24 10 e4 10 c0 	movl   $0xc010e410,(%esp)
c0107fe8:	e8 85 83 ff ff       	call   c0100372 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107fed:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107ff2:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107ff5:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c0107ffa:	83 f8 0a             	cmp    $0xa,%eax
c0107ffd:	74 24                	je     c0108023 <_fifo_check_swap+0x2dc>
c0107fff:	c7 44 24 0c 81 e4 10 	movl   $0xc010e481,0xc(%esp)
c0108006:	c0 
c0108007:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c010800e:	c0 
c010800f:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0108016:	00 
c0108017:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c010801e:	e8 cd 8d ff ff       	call   c0100df0 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108023:	c7 04 24 98 e3 10 c0 	movl   $0xc010e398,(%esp)
c010802a:	e8 43 83 ff ff       	call   c0100372 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c010802f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108034:	0f b6 00             	movzbl (%eax),%eax
c0108037:	3c 0a                	cmp    $0xa,%al
c0108039:	74 24                	je     c010805f <_fifo_check_swap+0x318>
c010803b:	c7 44 24 0c 94 e4 10 	movl   $0xc010e494,0xc(%esp)
c0108042:	c0 
c0108043:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c010804a:	c0 
c010804b:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0108052:	00 
c0108053:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c010805a:	e8 91 8d ff ff       	call   c0100df0 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c010805f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108064:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0108067:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c010806c:	83 f8 0b             	cmp    $0xb,%eax
c010806f:	74 24                	je     c0108095 <_fifo_check_swap+0x34e>
c0108071:	c7 44 24 0c b5 e4 10 	movl   $0xc010e4b5,0xc(%esp)
c0108078:	c0 
c0108079:	c7 44 24 08 0a e3 10 	movl   $0xc010e30a,0x8(%esp)
c0108080:	c0 
c0108081:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0108088:	00 
c0108089:	c7 04 24 1f e3 10 c0 	movl   $0xc010e31f,(%esp)
c0108090:	e8 5b 8d ff ff       	call   c0100df0 <__panic>
    return 0;
c0108095:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010809a:	89 ec                	mov    %ebp,%esp
c010809c:	5d                   	pop    %ebp
c010809d:	c3                   	ret    

c010809e <_fifo_init>:


static int
_fifo_init(void)
{
c010809e:	55                   	push   %ebp
c010809f:	89 e5                	mov    %esp,%ebp
    return 0;
c01080a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01080a6:	5d                   	pop    %ebp
c01080a7:	c3                   	ret    

c01080a8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01080a8:	55                   	push   %ebp
c01080a9:	89 e5                	mov    %esp,%ebp
    return 0;
c01080ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01080b0:	5d                   	pop    %ebp
c01080b1:	c3                   	ret    

c01080b2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01080b2:	55                   	push   %ebp
c01080b3:	89 e5                	mov    %esp,%ebp
c01080b5:	b8 00 00 00 00       	mov    $0x0,%eax
c01080ba:	5d                   	pop    %ebp
c01080bb:	c3                   	ret    

c01080bc <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c01080bc:	55                   	push   %ebp
c01080bd:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c01080bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01080c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c01080c8:	90                   	nop
c01080c9:	5d                   	pop    %ebp
c01080ca:	c3                   	ret    

c01080cb <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c01080cb:	55                   	push   %ebp
c01080cc:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c01080ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01080d1:	8b 40 18             	mov    0x18(%eax),%eax
}
c01080d4:	5d                   	pop    %ebp
c01080d5:	c3                   	ret    

c01080d6 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c01080d6:	55                   	push   %ebp
c01080d7:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c01080d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01080dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01080df:	89 50 18             	mov    %edx,0x18(%eax)
}
c01080e2:	90                   	nop
c01080e3:	5d                   	pop    %ebp
c01080e4:	c3                   	ret    

c01080e5 <page2ppn>:
page2ppn(struct Page *page) {
c01080e5:	55                   	push   %ebp
c01080e6:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01080e8:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c01080ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01080f1:	29 d0                	sub    %edx,%eax
c01080f3:	c1 f8 05             	sar    $0x5,%eax
}
c01080f6:	5d                   	pop    %ebp
c01080f7:	c3                   	ret    

c01080f8 <page2pa>:
page2pa(struct Page *page) {
c01080f8:	55                   	push   %ebp
c01080f9:	89 e5                	mov    %esp,%ebp
c01080fb:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01080fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108101:	89 04 24             	mov    %eax,(%esp)
c0108104:	e8 dc ff ff ff       	call   c01080e5 <page2ppn>
c0108109:	c1 e0 0c             	shl    $0xc,%eax
}
c010810c:	89 ec                	mov    %ebp,%esp
c010810e:	5d                   	pop    %ebp
c010810f:	c3                   	ret    

c0108110 <pa2page>:
pa2page(uintptr_t pa) {
c0108110:	55                   	push   %ebp
c0108111:	89 e5                	mov    %esp,%ebp
c0108113:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108116:	8b 45 08             	mov    0x8(%ebp),%eax
c0108119:	c1 e8 0c             	shr    $0xc,%eax
c010811c:	89 c2                	mov    %eax,%edx
c010811e:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c0108123:	39 c2                	cmp    %eax,%edx
c0108125:	72 1c                	jb     c0108143 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108127:	c7 44 24 08 d8 e4 10 	movl   $0xc010e4d8,0x8(%esp)
c010812e:	c0 
c010812f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0108136:	00 
c0108137:	c7 04 24 f7 e4 10 c0 	movl   $0xc010e4f7,(%esp)
c010813e:	e8 ad 8c ff ff       	call   c0100df0 <__panic>
    return &pages[PPN(pa)];
c0108143:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0108149:	8b 45 08             	mov    0x8(%ebp),%eax
c010814c:	c1 e8 0c             	shr    $0xc,%eax
c010814f:	c1 e0 05             	shl    $0x5,%eax
c0108152:	01 d0                	add    %edx,%eax
}
c0108154:	89 ec                	mov    %ebp,%esp
c0108156:	5d                   	pop    %ebp
c0108157:	c3                   	ret    

c0108158 <page2kva>:
page2kva(struct Page *page) {
c0108158:	55                   	push   %ebp
c0108159:	89 e5                	mov    %esp,%ebp
c010815b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010815e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108161:	89 04 24             	mov    %eax,(%esp)
c0108164:	e8 8f ff ff ff       	call   c01080f8 <page2pa>
c0108169:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010816f:	c1 e8 0c             	shr    $0xc,%eax
c0108172:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108175:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c010817a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010817d:	72 23                	jb     c01081a2 <page2kva+0x4a>
c010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108182:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108186:	c7 44 24 08 08 e5 10 	movl   $0xc010e508,0x8(%esp)
c010818d:	c0 
c010818e:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0108195:	00 
c0108196:	c7 04 24 f7 e4 10 c0 	movl   $0xc010e4f7,(%esp)
c010819d:	e8 4e 8c ff ff       	call   c0100df0 <__panic>
c01081a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081a5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01081aa:	89 ec                	mov    %ebp,%esp
c01081ac:	5d                   	pop    %ebp
c01081ad:	c3                   	ret    

c01081ae <pte2page>:
pte2page(pte_t pte) {
c01081ae:	55                   	push   %ebp
c01081af:	89 e5                	mov    %esp,%ebp
c01081b1:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01081b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01081b7:	83 e0 01             	and    $0x1,%eax
c01081ba:	85 c0                	test   %eax,%eax
c01081bc:	75 1c                	jne    c01081da <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01081be:	c7 44 24 08 2c e5 10 	movl   $0xc010e52c,0x8(%esp)
c01081c5:	c0 
c01081c6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01081cd:	00 
c01081ce:	c7 04 24 f7 e4 10 c0 	movl   $0xc010e4f7,(%esp)
c01081d5:	e8 16 8c ff ff       	call   c0100df0 <__panic>
    return pa2page(PTE_ADDR(pte));
c01081da:	8b 45 08             	mov    0x8(%ebp),%eax
c01081dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01081e2:	89 04 24             	mov    %eax,(%esp)
c01081e5:	e8 26 ff ff ff       	call   c0108110 <pa2page>
}
c01081ea:	89 ec                	mov    %ebp,%esp
c01081ec:	5d                   	pop    %ebp
c01081ed:	c3                   	ret    

c01081ee <page_ref>:
page_ref(struct Page *page) {
c01081ee:	55                   	push   %ebp
c01081ef:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01081f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01081f4:	8b 00                	mov    (%eax),%eax
}
c01081f6:	5d                   	pop    %ebp
c01081f7:	c3                   	ret    

c01081f8 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01081f8:	55                   	push   %ebp
c01081f9:	89 e5                	mov    %esp,%ebp
c01081fb:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01081fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108205:	e8 d9 cb ff ff       	call   c0104de3 <kmalloc>
c010820a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c010820d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108211:	74 7a                	je     c010828d <mm_create+0x95>
        list_init(&(mm->mmap_list));
c0108213:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108216:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0108219:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010821c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010821f:	89 50 04             	mov    %edx,0x4(%eax)
c0108222:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108225:	8b 50 04             	mov    0x4(%eax),%edx
c0108228:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010822b:	89 10                	mov    %edx,(%eax)
}
c010822d:	90                   	nop
        mm->mmap_cache = NULL;
c010822e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108231:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0108238:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010823b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0108242:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108245:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c010824c:	a1 44 80 1b c0       	mov    0xc01b8044,%eax
c0108251:	85 c0                	test   %eax,%eax
c0108253:	74 0d                	je     c0108262 <mm_create+0x6a>
c0108255:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108258:	89 04 24             	mov    %eax,(%esp)
c010825b:	e8 cb ed ff ff       	call   c010702b <swap_init_mm>
c0108260:	eb 0a                	jmp    c010826c <mm_create+0x74>
        else mm->sm_priv = NULL;
c0108262:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108265:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c010826c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108273:	00 
c0108274:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108277:	89 04 24             	mov    %eax,(%esp)
c010827a:	e8 57 fe ff ff       	call   c01080d6 <set_mm_count>
        lock_init(&(mm->mm_lock));
c010827f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108282:	83 c0 1c             	add    $0x1c,%eax
c0108285:	89 04 24             	mov    %eax,(%esp)
c0108288:	e8 2f fe ff ff       	call   c01080bc <lock_init>
    }    
    return mm;
c010828d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108290:	89 ec                	mov    %ebp,%esp
c0108292:	5d                   	pop    %ebp
c0108293:	c3                   	ret    

c0108294 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0108294:	55                   	push   %ebp
c0108295:	89 e5                	mov    %esp,%ebp
c0108297:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010829a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01082a1:	e8 3d cb ff ff       	call   c0104de3 <kmalloc>
c01082a6:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01082a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082ad:	74 1b                	je     c01082ca <vma_create+0x36>
        vma->vm_start = vm_start;
c01082af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01082b5:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01082b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082bb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01082be:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01082c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082c4:	8b 55 10             	mov    0x10(%ebp),%edx
c01082c7:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01082ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01082cd:	89 ec                	mov    %ebp,%esp
c01082cf:	5d                   	pop    %ebp
c01082d0:	c3                   	ret    

c01082d1 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01082d1:	55                   	push   %ebp
c01082d2:	89 e5                	mov    %esp,%ebp
c01082d4:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01082d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01082de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01082e2:	0f 84 95 00 00 00    	je     c010837d <find_vma+0xac>
        vma = mm->mmap_cache;
c01082e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01082eb:	8b 40 08             	mov    0x8(%eax),%eax
c01082ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01082f1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01082f5:	74 16                	je     c010830d <find_vma+0x3c>
c01082f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01082fa:	8b 40 04             	mov    0x4(%eax),%eax
c01082fd:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108300:	72 0b                	jb     c010830d <find_vma+0x3c>
c0108302:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108305:	8b 40 08             	mov    0x8(%eax),%eax
c0108308:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010830b:	72 61                	jb     c010836e <find_vma+0x9d>
                bool found = 0;
c010830d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0108314:	8b 45 08             	mov    0x8(%ebp),%eax
c0108317:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010831a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010831d:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0108320:	eb 28                	jmp    c010834a <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0108322:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108325:	83 e8 10             	sub    $0x10,%eax
c0108328:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010832b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010832e:	8b 40 04             	mov    0x4(%eax),%eax
c0108331:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108334:	72 14                	jb     c010834a <find_vma+0x79>
c0108336:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108339:	8b 40 08             	mov    0x8(%eax),%eax
c010833c:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010833f:	73 09                	jae    c010834a <find_vma+0x79>
                        found = 1;
c0108341:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108348:	eb 17                	jmp    c0108361 <find_vma+0x90>
c010834a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010834d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0108350:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108353:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0108356:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108359:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010835c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010835f:	75 c1                	jne    c0108322 <find_vma+0x51>
                    }
                }
                if (!found) {
c0108361:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0108365:	75 07                	jne    c010836e <find_vma+0x9d>
                    vma = NULL;
c0108367:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c010836e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108372:	74 09                	je     c010837d <find_vma+0xac>
            mm->mmap_cache = vma;
c0108374:	8b 45 08             	mov    0x8(%ebp),%eax
c0108377:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010837a:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010837d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108380:	89 ec                	mov    %ebp,%esp
c0108382:	5d                   	pop    %ebp
c0108383:	c3                   	ret    

c0108384 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0108384:	55                   	push   %ebp
c0108385:	89 e5                	mov    %esp,%ebp
c0108387:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010838a:	8b 45 08             	mov    0x8(%ebp),%eax
c010838d:	8b 50 04             	mov    0x4(%eax),%edx
c0108390:	8b 45 08             	mov    0x8(%ebp),%eax
c0108393:	8b 40 08             	mov    0x8(%eax),%eax
c0108396:	39 c2                	cmp    %eax,%edx
c0108398:	72 24                	jb     c01083be <check_vma_overlap+0x3a>
c010839a:	c7 44 24 0c 4d e5 10 	movl   $0xc010e54d,0xc(%esp)
c01083a1:	c0 
c01083a2:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c01083a9:	c0 
c01083aa:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01083b1:	00 
c01083b2:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c01083b9:	e8 32 8a ff ff       	call   c0100df0 <__panic>
    assert(prev->vm_end <= next->vm_start);
c01083be:	8b 45 08             	mov    0x8(%ebp),%eax
c01083c1:	8b 50 08             	mov    0x8(%eax),%edx
c01083c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083c7:	8b 40 04             	mov    0x4(%eax),%eax
c01083ca:	39 c2                	cmp    %eax,%edx
c01083cc:	76 24                	jbe    c01083f2 <check_vma_overlap+0x6e>
c01083ce:	c7 44 24 0c 90 e5 10 	movl   $0xc010e590,0xc(%esp)
c01083d5:	c0 
c01083d6:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c01083dd:	c0 
c01083de:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c01083e5:	00 
c01083e6:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c01083ed:	e8 fe 89 ff ff       	call   c0100df0 <__panic>
    assert(next->vm_start < next->vm_end);
c01083f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083f5:	8b 50 04             	mov    0x4(%eax),%edx
c01083f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083fb:	8b 40 08             	mov    0x8(%eax),%eax
c01083fe:	39 c2                	cmp    %eax,%edx
c0108400:	72 24                	jb     c0108426 <check_vma_overlap+0xa2>
c0108402:	c7 44 24 0c af e5 10 	movl   $0xc010e5af,0xc(%esp)
c0108409:	c0 
c010840a:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108411:	c0 
c0108412:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108419:	00 
c010841a:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108421:	e8 ca 89 ff ff       	call   c0100df0 <__panic>
}
c0108426:	90                   	nop
c0108427:	89 ec                	mov    %ebp,%esp
c0108429:	5d                   	pop    %ebp
c010842a:	c3                   	ret    

c010842b <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010842b:	55                   	push   %ebp
c010842c:	89 e5                	mov    %esp,%ebp
c010842e:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108431:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108434:	8b 50 04             	mov    0x4(%eax),%edx
c0108437:	8b 45 0c             	mov    0xc(%ebp),%eax
c010843a:	8b 40 08             	mov    0x8(%eax),%eax
c010843d:	39 c2                	cmp    %eax,%edx
c010843f:	72 24                	jb     c0108465 <insert_vma_struct+0x3a>
c0108441:	c7 44 24 0c cd e5 10 	movl   $0xc010e5cd,0xc(%esp)
c0108448:	c0 
c0108449:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108450:	c0 
c0108451:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0108458:	00 
c0108459:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108460:	e8 8b 89 ff ff       	call   c0100df0 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0108465:	8b 45 08             	mov    0x8(%ebp),%eax
c0108468:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010846b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010846e:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0108471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108474:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0108477:	eb 1f                	jmp    c0108498 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0108479:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010847c:	83 e8 10             	sub    $0x10,%eax
c010847f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0108482:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108485:	8b 50 04             	mov    0x4(%eax),%edx
c0108488:	8b 45 0c             	mov    0xc(%ebp),%eax
c010848b:	8b 40 04             	mov    0x4(%eax),%eax
c010848e:	39 c2                	cmp    %eax,%edx
c0108490:	77 1f                	ja     c01084b1 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0108492:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108495:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108498:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010849b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010849e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084a1:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c01084a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084aa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01084ad:	75 ca                	jne    c0108479 <insert_vma_struct+0x4e>
c01084af:	eb 01                	jmp    c01084b2 <insert_vma_struct+0x87>
                break;
c01084b1:	90                   	nop
c01084b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01084b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01084bb:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c01084be:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01084c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01084c7:	74 15                	je     c01084de <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01084c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084cc:	8d 50 f0             	lea    -0x10(%eax),%edx
c01084cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084d6:	89 14 24             	mov    %edx,(%esp)
c01084d9:	e8 a6 fe ff ff       	call   c0108384 <check_vma_overlap>
    }
    if (le_next != list) {
c01084de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084e1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01084e4:	74 15                	je     c01084fb <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01084e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01084e9:	83 e8 10             	sub    $0x10,%eax
c01084ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084f3:	89 04 24             	mov    %eax,(%esp)
c01084f6:	e8 89 fe ff ff       	call   c0108384 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01084fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084fe:	8b 55 08             	mov    0x8(%ebp),%edx
c0108501:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108503:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108506:	8d 50 10             	lea    0x10(%eax),%edx
c0108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010850c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010850f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108512:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108515:	8b 40 04             	mov    0x4(%eax),%eax
c0108518:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010851b:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010851e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108521:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108524:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0108527:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010852a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010852d:	89 10                	mov    %edx,(%eax)
c010852f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108532:	8b 10                	mov    (%eax),%edx
c0108534:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108537:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010853a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010853d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108540:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108543:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108546:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108549:	89 10                	mov    %edx,(%eax)
}
c010854b:	90                   	nop
}
c010854c:	90                   	nop

    mm->map_count ++;
c010854d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108550:	8b 40 10             	mov    0x10(%eax),%eax
c0108553:	8d 50 01             	lea    0x1(%eax),%edx
c0108556:	8b 45 08             	mov    0x8(%ebp),%eax
c0108559:	89 50 10             	mov    %edx,0x10(%eax)
}
c010855c:	90                   	nop
c010855d:	89 ec                	mov    %ebp,%esp
c010855f:	5d                   	pop    %ebp
c0108560:	c3                   	ret    

c0108561 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0108561:	55                   	push   %ebp
c0108562:	89 e5                	mov    %esp,%ebp
c0108564:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0108567:	8b 45 08             	mov    0x8(%ebp),%eax
c010856a:	89 04 24             	mov    %eax,(%esp)
c010856d:	e8 59 fb ff ff       	call   c01080cb <mm_count>
c0108572:	85 c0                	test   %eax,%eax
c0108574:	74 24                	je     c010859a <mm_destroy+0x39>
c0108576:	c7 44 24 0c e9 e5 10 	movl   $0xc010e5e9,0xc(%esp)
c010857d:	c0 
c010857e:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108585:	c0 
c0108586:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c010858d:	00 
c010858e:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108595:	e8 56 88 ff ff       	call   c0100df0 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c010859a:	8b 45 08             	mov    0x8(%ebp),%eax
c010859d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01085a0:	eb 38                	jmp    c01085da <mm_destroy+0x79>
c01085a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01085a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085ab:	8b 40 04             	mov    0x4(%eax),%eax
c01085ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01085b1:	8b 12                	mov    (%edx),%edx
c01085b3:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01085b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c01085b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01085bf:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01085c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085c5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01085c8:	89 10                	mov    %edx,(%eax)
}
c01085ca:	90                   	nop
}
c01085cb:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01085cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085cf:	83 e8 10             	sub    $0x10,%eax
c01085d2:	89 04 24             	mov    %eax,(%esp)
c01085d5:	e8 26 c8 ff ff       	call   c0104e00 <kfree>
c01085da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01085e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085e3:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c01085e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01085ef:	75 b1                	jne    c01085a2 <mm_destroy+0x41>
    }
    kfree(mm); //kfree mm
c01085f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01085f4:	89 04 24             	mov    %eax,(%esp)
c01085f7:	e8 04 c8 ff ff       	call   c0104e00 <kfree>
    mm=NULL;
c01085fc:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108603:	90                   	nop
c0108604:	89 ec                	mov    %ebp,%esp
c0108606:	5d                   	pop    %ebp
c0108607:	c3                   	ret    

c0108608 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108608:	55                   	push   %ebp
c0108609:	89 e5                	mov    %esp,%ebp
c010860b:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c010860e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108611:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108614:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108617:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010861c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010861f:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0108626:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108629:	8b 45 10             	mov    0x10(%ebp),%eax
c010862c:	01 c2                	add    %eax,%edx
c010862e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108631:	01 d0                	add    %edx,%eax
c0108633:	48                   	dec    %eax
c0108634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108637:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010863a:	ba 00 00 00 00       	mov    $0x0,%edx
c010863f:	f7 75 e8             	divl   -0x18(%ebp)
c0108642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108645:	29 d0                	sub    %edx,%eax
c0108647:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c010864a:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0108651:	76 11                	jbe    c0108664 <mm_map+0x5c>
c0108653:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108656:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108659:	73 09                	jae    c0108664 <mm_map+0x5c>
c010865b:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0108662:	76 0a                	jbe    c010866e <mm_map+0x66>
        return -E_INVAL;
c0108664:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0108669:	e9 b0 00 00 00       	jmp    c010871e <mm_map+0x116>
    }

    assert(mm != NULL);
c010866e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108672:	75 24                	jne    c0108698 <mm_map+0x90>
c0108674:	c7 44 24 0c fb e5 10 	movl   $0xc010e5fb,0xc(%esp)
c010867b:	c0 
c010867c:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108683:	c0 
c0108684:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c010868b:	00 
c010868c:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108693:	e8 58 87 ff ff       	call   c0100df0 <__panic>

    int ret = -E_INVAL;
c0108698:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c010869f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a9:	89 04 24             	mov    %eax,(%esp)
c01086ac:	e8 20 fc ff ff       	call   c01082d1 <find_vma>
c01086b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01086b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01086b8:	74 0b                	je     c01086c5 <mm_map+0xbd>
c01086ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01086bd:	8b 40 04             	mov    0x4(%eax),%eax
c01086c0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01086c3:	77 52                	ja     c0108717 <mm_map+0x10f>
        goto out;
    }
    ret = -E_NO_MEM;
c01086c5:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c01086cc:	8b 45 14             	mov    0x14(%ebp),%eax
c01086cf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01086d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086dd:	89 04 24             	mov    %eax,(%esp)
c01086e0:	e8 af fb ff ff       	call   c0108294 <vma_create>
c01086e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01086e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01086ec:	74 2c                	je     c010871a <mm_map+0x112>
        goto out;
    }
    insert_vma_struct(mm, vma);
c01086ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01086f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f8:	89 04 24             	mov    %eax,(%esp)
c01086fb:	e8 2b fd ff ff       	call   c010842b <insert_vma_struct>
    if (vma_store != NULL) {
c0108700:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108704:	74 08                	je     c010870e <mm_map+0x106>
        *vma_store = vma;
c0108706:	8b 45 18             	mov    0x18(%ebp),%eax
c0108709:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010870c:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c010870e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108715:	eb 04                	jmp    c010871b <mm_map+0x113>
        goto out;
c0108717:	90                   	nop
c0108718:	eb 01                	jmp    c010871b <mm_map+0x113>
        goto out;
c010871a:	90                   	nop

out:
    return ret;
c010871b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010871e:	89 ec                	mov    %ebp,%esp
c0108720:	5d                   	pop    %ebp
c0108721:	c3                   	ret    

c0108722 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0108722:	55                   	push   %ebp
c0108723:	89 e5                	mov    %esp,%ebp
c0108725:	56                   	push   %esi
c0108726:	53                   	push   %ebx
c0108727:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c010872a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010872e:	74 06                	je     c0108736 <dup_mmap+0x14>
c0108730:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108734:	75 24                	jne    c010875a <dup_mmap+0x38>
c0108736:	c7 44 24 0c 06 e6 10 	movl   $0xc010e606,0xc(%esp)
c010873d:	c0 
c010873e:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108745:	c0 
c0108746:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010874d:	00 
c010874e:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108755:	e8 96 86 ff ff       	call   c0100df0 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c010875a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010875d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108760:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108763:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0108766:	e9 92 00 00 00       	jmp    c01087fd <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c010876b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010876e:	83 e8 10             	sub    $0x10,%eax
c0108771:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0108774:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108777:	8b 48 0c             	mov    0xc(%eax),%ecx
c010877a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010877d:	8b 50 08             	mov    0x8(%eax),%edx
c0108780:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108783:	8b 40 04             	mov    0x4(%eax),%eax
c0108786:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010878a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010878e:	89 04 24             	mov    %eax,(%esp)
c0108791:	e8 fe fa ff ff       	call   c0108294 <vma_create>
c0108796:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0108799:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010879d:	75 07                	jne    c01087a6 <dup_mmap+0x84>
            return -E_NO_MEM;
c010879f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01087a4:	eb 76                	jmp    c010881c <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01087a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01087b0:	89 04 24             	mov    %eax,(%esp)
c01087b3:	e8 73 fc ff ff       	call   c010842b <insert_vma_struct>

        bool share = 1;
c01087b8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c01087bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087c2:	8b 58 08             	mov    0x8(%eax),%ebx
c01087c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087c8:	8b 48 04             	mov    0x4(%eax),%ecx
c01087cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087ce:	8b 50 0c             	mov    0xc(%eax),%edx
c01087d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01087d4:	8b 40 0c             	mov    0xc(%eax),%eax
c01087d7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c01087da:	89 74 24 10          	mov    %esi,0x10(%esp)
c01087de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01087e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01087e6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01087ea:	89 04 24             	mov    %eax,(%esp)
c01087ed:	e8 3e d5 ff ff       	call   c0105d30 <copy_range>
c01087f2:	85 c0                	test   %eax,%eax
c01087f4:	74 07                	je     c01087fd <dup_mmap+0xdb>
            return -E_NO_MEM;
c01087f6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01087fb:	eb 1f                	jmp    c010881c <dup_mmap+0xfa>
c01087fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108800:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0108803:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108806:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0108808:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010880b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010880e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108811:	0f 85 54 ff ff ff    	jne    c010876b <dup_mmap+0x49>
        }
    }
    return 0;
c0108817:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010881c:	83 c4 40             	add    $0x40,%esp
c010881f:	5b                   	pop    %ebx
c0108820:	5e                   	pop    %esi
c0108821:	5d                   	pop    %ebp
c0108822:	c3                   	ret    

c0108823 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0108823:	55                   	push   %ebp
c0108824:	89 e5                	mov    %esp,%ebp
c0108826:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0108829:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010882d:	74 0f                	je     c010883e <exit_mmap+0x1b>
c010882f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108832:	89 04 24             	mov    %eax,(%esp)
c0108835:	e8 91 f8 ff ff       	call   c01080cb <mm_count>
c010883a:	85 c0                	test   %eax,%eax
c010883c:	74 24                	je     c0108862 <exit_mmap+0x3f>
c010883e:	c7 44 24 0c 24 e6 10 	movl   $0xc010e624,0xc(%esp)
c0108845:	c0 
c0108846:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c010884d:	c0 
c010884e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0108855:	00 
c0108856:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c010885d:	e8 8e 85 ff ff       	call   c0100df0 <__panic>
    pde_t *pgdir = mm->pgdir;
c0108862:	8b 45 08             	mov    0x8(%ebp),%eax
c0108865:	8b 40 0c             	mov    0xc(%eax),%eax
c0108868:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c010886b:	8b 45 08             	mov    0x8(%ebp),%eax
c010886e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108871:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108874:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0108877:	eb 28                	jmp    c01088a1 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0108879:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010887c:	83 e8 10             	sub    $0x10,%eax
c010887f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0108882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108885:	8b 50 08             	mov    0x8(%eax),%edx
c0108888:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010888b:	8b 40 04             	mov    0x4(%eax),%eax
c010888e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108892:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108896:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108899:	89 04 24             	mov    %eax,(%esp)
c010889c:	e8 8e d2 ff ff       	call   c0105b2f <unmap_range>
c01088a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01088a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01088aa:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c01088ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01088b6:	75 c1                	jne    c0108879 <exit_mmap+0x56>
    }
    while ((le = list_next(le)) != list) {
c01088b8:	eb 28                	jmp    c01088e2 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c01088ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088bd:	83 e8 10             	sub    $0x10,%eax
c01088c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c01088c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088c6:	8b 50 08             	mov    0x8(%eax),%edx
c01088c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088cc:	8b 40 04             	mov    0x4(%eax),%eax
c01088cf:	89 54 24 08          	mov    %edx,0x8(%esp)
c01088d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088da:	89 04 24             	mov    %eax,(%esp)
c01088dd:	e8 44 d3 ff ff       	call   c0105c26 <exit_range>
c01088e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01088e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01088eb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c01088ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088f4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01088f7:	75 c1                	jne    c01088ba <exit_mmap+0x97>
    }
}
c01088f9:	90                   	nop
c01088fa:	90                   	nop
c01088fb:	89 ec                	mov    %ebp,%esp
c01088fd:	5d                   	pop    %ebp
c01088fe:	c3                   	ret    

c01088ff <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c01088ff:	55                   	push   %ebp
c0108900:	89 e5                	mov    %esp,%ebp
c0108902:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0108905:	8b 45 10             	mov    0x10(%ebp),%eax
c0108908:	8b 55 18             	mov    0x18(%ebp),%edx
c010890b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010890f:	8b 55 14             	mov    0x14(%ebp),%edx
c0108912:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108916:	89 44 24 04          	mov    %eax,0x4(%esp)
c010891a:	8b 45 08             	mov    0x8(%ebp),%eax
c010891d:	89 04 24             	mov    %eax,(%esp)
c0108920:	e8 55 0a 00 00       	call   c010937a <user_mem_check>
c0108925:	85 c0                	test   %eax,%eax
c0108927:	75 07                	jne    c0108930 <copy_from_user+0x31>
        return 0;
c0108929:	b8 00 00 00 00       	mov    $0x0,%eax
c010892e:	eb 1e                	jmp    c010894e <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0108930:	8b 45 14             	mov    0x14(%ebp),%eax
c0108933:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108937:	8b 45 10             	mov    0x10(%ebp),%eax
c010893a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010893e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108941:	89 04 24             	mov    %eax,(%esp)
c0108944:	e8 8d 3f 00 00       	call   c010c8d6 <memcpy>
    return 1;
c0108949:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010894e:	89 ec                	mov    %ebp,%esp
c0108950:	5d                   	pop    %ebp
c0108951:	c3                   	ret    

c0108952 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0108952:	55                   	push   %ebp
c0108953:	89 e5                	mov    %esp,%ebp
c0108955:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0108958:	8b 45 0c             	mov    0xc(%ebp),%eax
c010895b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108962:	00 
c0108963:	8b 55 14             	mov    0x14(%ebp),%edx
c0108966:	89 54 24 08          	mov    %edx,0x8(%esp)
c010896a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010896e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108971:	89 04 24             	mov    %eax,(%esp)
c0108974:	e8 01 0a 00 00       	call   c010937a <user_mem_check>
c0108979:	85 c0                	test   %eax,%eax
c010897b:	75 07                	jne    c0108984 <copy_to_user+0x32>
        return 0;
c010897d:	b8 00 00 00 00       	mov    $0x0,%eax
c0108982:	eb 1e                	jmp    c01089a2 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0108984:	8b 45 14             	mov    0x14(%ebp),%eax
c0108987:	89 44 24 08          	mov    %eax,0x8(%esp)
c010898b:	8b 45 10             	mov    0x10(%ebp),%eax
c010898e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108992:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108995:	89 04 24             	mov    %eax,(%esp)
c0108998:	e8 39 3f 00 00       	call   c010c8d6 <memcpy>
    return 1;
c010899d:	b8 01 00 00 00       	mov    $0x1,%eax
}
c01089a2:	89 ec                	mov    %ebp,%esp
c01089a4:	5d                   	pop    %ebp
c01089a5:	c3                   	ret    

c01089a6 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01089a6:	55                   	push   %ebp
c01089a7:	89 e5                	mov    %esp,%ebp
c01089a9:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01089ac:	e8 05 00 00 00       	call   c01089b6 <check_vmm>
}
c01089b1:	90                   	nop
c01089b2:	89 ec                	mov    %ebp,%esp
c01089b4:	5d                   	pop    %ebp
c01089b5:	c3                   	ret    

c01089b6 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01089b6:	55                   	push   %ebp
c01089b7:	89 e5                	mov    %esp,%ebp
c01089b9:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01089bc:	e8 55 c9 ff ff       	call   c0105316 <nr_free_pages>
c01089c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01089c4:	e8 16 00 00 00       	call   c01089df <check_vma_struct>
    check_pgfault();
c01089c9:	e8 a5 04 00 00       	call   c0108e73 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01089ce:	c7 04 24 44 e6 10 c0 	movl   $0xc010e644,(%esp)
c01089d5:	e8 98 79 ff ff       	call   c0100372 <cprintf>
}
c01089da:	90                   	nop
c01089db:	89 ec                	mov    %ebp,%esp
c01089dd:	5d                   	pop    %ebp
c01089de:	c3                   	ret    

c01089df <check_vma_struct>:

static void
check_vma_struct(void) {
c01089df:	55                   	push   %ebp
c01089e0:	89 e5                	mov    %esp,%ebp
c01089e2:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01089e5:	e8 2c c9 ff ff       	call   c0105316 <nr_free_pages>
c01089ea:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01089ed:	e8 06 f8 ff ff       	call   c01081f8 <mm_create>
c01089f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01089f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01089f9:	75 24                	jne    c0108a1f <check_vma_struct+0x40>
c01089fb:	c7 44 24 0c fb e5 10 	movl   $0xc010e5fb,0xc(%esp)
c0108a02:	c0 
c0108a03:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108a0a:	c0 
c0108a0b:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0108a12:	00 
c0108a13:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108a1a:	e8 d1 83 ff ff       	call   c0100df0 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108a1f:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108a26:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a29:	89 d0                	mov    %edx,%eax
c0108a2b:	c1 e0 02             	shl    $0x2,%eax
c0108a2e:	01 d0                	add    %edx,%eax
c0108a30:	01 c0                	add    %eax,%eax
c0108a32:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108a35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a3b:	eb 6f                	jmp    c0108aac <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108a3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a40:	89 d0                	mov    %edx,%eax
c0108a42:	c1 e0 02             	shl    $0x2,%eax
c0108a45:	01 d0                	add    %edx,%eax
c0108a47:	83 c0 02             	add    $0x2,%eax
c0108a4a:	89 c1                	mov    %eax,%ecx
c0108a4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a4f:	89 d0                	mov    %edx,%eax
c0108a51:	c1 e0 02             	shl    $0x2,%eax
c0108a54:	01 d0                	add    %edx,%eax
c0108a56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108a5d:	00 
c0108a5e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108a62:	89 04 24             	mov    %eax,(%esp)
c0108a65:	e8 2a f8 ff ff       	call   c0108294 <vma_create>
c0108a6a:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0108a6d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108a71:	75 24                	jne    c0108a97 <check_vma_struct+0xb8>
c0108a73:	c7 44 24 0c 5c e6 10 	movl   $0xc010e65c,0xc(%esp)
c0108a7a:	c0 
c0108a7b:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108a82:	c0 
c0108a83:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0108a8a:	00 
c0108a8b:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108a92:	e8 59 83 ff ff       	call   c0100df0 <__panic>
        insert_vma_struct(mm, vma);
c0108a97:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108aa1:	89 04 24             	mov    %eax,(%esp)
c0108aa4:	e8 82 f9 ff ff       	call   c010842b <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0108aa9:	ff 4d f4             	decl   -0xc(%ebp)
c0108aac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108ab0:	7f 8b                	jg     c0108a3d <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0108ab2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ab5:	40                   	inc    %eax
c0108ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ab9:	eb 6f                	jmp    c0108b2a <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108abe:	89 d0                	mov    %edx,%eax
c0108ac0:	c1 e0 02             	shl    $0x2,%eax
c0108ac3:	01 d0                	add    %edx,%eax
c0108ac5:	83 c0 02             	add    $0x2,%eax
c0108ac8:	89 c1                	mov    %eax,%ecx
c0108aca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108acd:	89 d0                	mov    %edx,%eax
c0108acf:	c1 e0 02             	shl    $0x2,%eax
c0108ad2:	01 d0                	add    %edx,%eax
c0108ad4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108adb:	00 
c0108adc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108ae0:	89 04 24             	mov    %eax,(%esp)
c0108ae3:	e8 ac f7 ff ff       	call   c0108294 <vma_create>
c0108ae8:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0108aeb:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108aef:	75 24                	jne    c0108b15 <check_vma_struct+0x136>
c0108af1:	c7 44 24 0c 5c e6 10 	movl   $0xc010e65c,0xc(%esp)
c0108af8:	c0 
c0108af9:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108b00:	c0 
c0108b01:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0108b08:	00 
c0108b09:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108b10:	e8 db 82 ff ff       	call   c0100df0 <__panic>
        insert_vma_struct(mm, vma);
c0108b15:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108b18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b1f:	89 04 24             	mov    %eax,(%esp)
c0108b22:	e8 04 f9 ff ff       	call   c010842b <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0108b27:	ff 45 f4             	incl   -0xc(%ebp)
c0108b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b2d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108b30:	7e 89                	jle    c0108abb <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b35:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0108b38:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0108b3b:	8b 40 04             	mov    0x4(%eax),%eax
c0108b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0108b41:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0108b48:	e9 96 00 00 00       	jmp    c0108be3 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0108b4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b50:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108b53:	75 24                	jne    c0108b79 <check_vma_struct+0x19a>
c0108b55:	c7 44 24 0c 68 e6 10 	movl   $0xc010e668,0xc(%esp)
c0108b5c:	c0 
c0108b5d:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108b64:	c0 
c0108b65:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0108b6c:	00 
c0108b6d:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108b74:	e8 77 82 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0108b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b7c:	83 e8 10             	sub    $0x10,%eax
c0108b7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0108b82:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108b85:	8b 48 04             	mov    0x4(%eax),%ecx
c0108b88:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108b8b:	89 d0                	mov    %edx,%eax
c0108b8d:	c1 e0 02             	shl    $0x2,%eax
c0108b90:	01 d0                	add    %edx,%eax
c0108b92:	39 c1                	cmp    %eax,%ecx
c0108b94:	75 17                	jne    c0108bad <check_vma_struct+0x1ce>
c0108b96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108b99:	8b 48 08             	mov    0x8(%eax),%ecx
c0108b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108b9f:	89 d0                	mov    %edx,%eax
c0108ba1:	c1 e0 02             	shl    $0x2,%eax
c0108ba4:	01 d0                	add    %edx,%eax
c0108ba6:	83 c0 02             	add    $0x2,%eax
c0108ba9:	39 c1                	cmp    %eax,%ecx
c0108bab:	74 24                	je     c0108bd1 <check_vma_struct+0x1f2>
c0108bad:	c7 44 24 0c 80 e6 10 	movl   $0xc010e680,0xc(%esp)
c0108bb4:	c0 
c0108bb5:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108bbc:	c0 
c0108bbd:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0108bc4:	00 
c0108bc5:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108bcc:	e8 1f 82 ff ff       	call   c0100df0 <__panic>
c0108bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bd4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0108bd7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108bda:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0108be0:	ff 45 f4             	incl   -0xc(%ebp)
c0108be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108be6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108be9:	0f 8e 5e ff ff ff    	jle    c0108b4d <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108bef:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0108bf6:	e9 cb 01 00 00       	jmp    c0108dc6 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c05:	89 04 24             	mov    %eax,(%esp)
c0108c08:	e8 c4 f6 ff ff       	call   c01082d1 <find_vma>
c0108c0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0108c10:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108c14:	75 24                	jne    c0108c3a <check_vma_struct+0x25b>
c0108c16:	c7 44 24 0c b5 e6 10 	movl   $0xc010e6b5,0xc(%esp)
c0108c1d:	c0 
c0108c1e:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108c25:	c0 
c0108c26:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0108c2d:	00 
c0108c2e:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108c35:	e8 b6 81 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c3d:	40                   	inc    %eax
c0108c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c45:	89 04 24             	mov    %eax,(%esp)
c0108c48:	e8 84 f6 ff ff       	call   c01082d1 <find_vma>
c0108c4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0108c50:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0108c54:	75 24                	jne    c0108c7a <check_vma_struct+0x29b>
c0108c56:	c7 44 24 0c c2 e6 10 	movl   $0xc010e6c2,0xc(%esp)
c0108c5d:	c0 
c0108c5e:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108c65:	c0 
c0108c66:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0108c6d:	00 
c0108c6e:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108c75:	e8 76 81 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c7d:	83 c0 02             	add    $0x2,%eax
c0108c80:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c87:	89 04 24             	mov    %eax,(%esp)
c0108c8a:	e8 42 f6 ff ff       	call   c01082d1 <find_vma>
c0108c8f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0108c92:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0108c96:	74 24                	je     c0108cbc <check_vma_struct+0x2dd>
c0108c98:	c7 44 24 0c cf e6 10 	movl   $0xc010e6cf,0xc(%esp)
c0108c9f:	c0 
c0108ca0:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108ca7:	c0 
c0108ca8:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0108caf:	00 
c0108cb0:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108cb7:	e8 34 81 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0108cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cbf:	83 c0 03             	add    $0x3,%eax
c0108cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108cc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cc9:	89 04 24             	mov    %eax,(%esp)
c0108ccc:	e8 00 f6 ff ff       	call   c01082d1 <find_vma>
c0108cd1:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0108cd4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108cd8:	74 24                	je     c0108cfe <check_vma_struct+0x31f>
c0108cda:	c7 44 24 0c dc e6 10 	movl   $0xc010e6dc,0xc(%esp)
c0108ce1:	c0 
c0108ce2:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108ce9:	c0 
c0108cea:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0108cf1:	00 
c0108cf2:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108cf9:	e8 f2 80 ff ff       	call   c0100df0 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0108cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d01:	83 c0 04             	add    $0x4,%eax
c0108d04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d08:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d0b:	89 04 24             	mov    %eax,(%esp)
c0108d0e:	e8 be f5 ff ff       	call   c01082d1 <find_vma>
c0108d13:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0108d16:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108d1a:	74 24                	je     c0108d40 <check_vma_struct+0x361>
c0108d1c:	c7 44 24 0c e9 e6 10 	movl   $0xc010e6e9,0xc(%esp)
c0108d23:	c0 
c0108d24:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108d2b:	c0 
c0108d2c:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108d33:	00 
c0108d34:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108d3b:	e8 b0 80 ff ff       	call   c0100df0 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108d40:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d43:	8b 50 04             	mov    0x4(%eax),%edx
c0108d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d49:	39 c2                	cmp    %eax,%edx
c0108d4b:	75 10                	jne    c0108d5d <check_vma_struct+0x37e>
c0108d4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d50:	8b 40 08             	mov    0x8(%eax),%eax
c0108d53:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d56:	83 c2 02             	add    $0x2,%edx
c0108d59:	39 d0                	cmp    %edx,%eax
c0108d5b:	74 24                	je     c0108d81 <check_vma_struct+0x3a2>
c0108d5d:	c7 44 24 0c f8 e6 10 	movl   $0xc010e6f8,0xc(%esp)
c0108d64:	c0 
c0108d65:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108d6c:	c0 
c0108d6d:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108d74:	00 
c0108d75:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108d7c:	e8 6f 80 ff ff       	call   c0100df0 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108d81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108d84:	8b 50 04             	mov    0x4(%eax),%edx
c0108d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d8a:	39 c2                	cmp    %eax,%edx
c0108d8c:	75 10                	jne    c0108d9e <check_vma_struct+0x3bf>
c0108d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108d91:	8b 40 08             	mov    0x8(%eax),%eax
c0108d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d97:	83 c2 02             	add    $0x2,%edx
c0108d9a:	39 d0                	cmp    %edx,%eax
c0108d9c:	74 24                	je     c0108dc2 <check_vma_struct+0x3e3>
c0108d9e:	c7 44 24 0c 28 e7 10 	movl   $0xc010e728,0xc(%esp)
c0108da5:	c0 
c0108da6:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108dad:	c0 
c0108dae:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108db5:	00 
c0108db6:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108dbd:	e8 2e 80 ff ff       	call   c0100df0 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0108dc2:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108dc6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108dc9:	89 d0                	mov    %edx,%eax
c0108dcb:	c1 e0 02             	shl    $0x2,%eax
c0108dce:	01 d0                	add    %edx,%eax
c0108dd0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108dd3:	0f 8e 22 fe ff ff    	jle    c0108bfb <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0108dd9:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108de0:	eb 6f                	jmp    c0108e51 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108de5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108de9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108dec:	89 04 24             	mov    %eax,(%esp)
c0108def:	e8 dd f4 ff ff       	call   c01082d1 <find_vma>
c0108df4:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0108df7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108dfb:	74 27                	je     c0108e24 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0108dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e00:	8b 50 08             	mov    0x8(%eax),%edx
c0108e03:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e06:	8b 40 04             	mov    0x4(%eax),%eax
c0108e09:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e18:	c7 04 24 58 e7 10 c0 	movl   $0xc010e758,(%esp)
c0108e1f:	e8 4e 75 ff ff       	call   c0100372 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108e24:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108e28:	74 24                	je     c0108e4e <check_vma_struct+0x46f>
c0108e2a:	c7 44 24 0c 7d e7 10 	movl   $0xc010e77d,0xc(%esp)
c0108e31:	c0 
c0108e32:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108e39:	c0 
c0108e3a:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108e41:	00 
c0108e42:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108e49:	e8 a2 7f ff ff       	call   c0100df0 <__panic>
    for (i =4; i>=0; i--) {
c0108e4e:	ff 4d f4             	decl   -0xc(%ebp)
c0108e51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108e55:	79 8b                	jns    c0108de2 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0108e57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e5a:	89 04 24             	mov    %eax,(%esp)
c0108e5d:	e8 ff f6 ff ff       	call   c0108561 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108e62:	c7 04 24 94 e7 10 c0 	movl   $0xc010e794,(%esp)
c0108e69:	e8 04 75 ff ff       	call   c0100372 <cprintf>
}
c0108e6e:	90                   	nop
c0108e6f:	89 ec                	mov    %ebp,%esp
c0108e71:	5d                   	pop    %ebp
c0108e72:	c3                   	ret    

c0108e73 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108e73:	55                   	push   %ebp
c0108e74:	89 e5                	mov    %esp,%ebp
c0108e76:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108e79:	e8 98 c4 ff ff       	call   c0105316 <nr_free_pages>
c0108e7e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108e81:	e8 72 f3 ff ff       	call   c01081f8 <mm_create>
c0108e86:	a3 0c 81 1b c0       	mov    %eax,0xc01b810c
    assert(check_mm_struct != NULL);
c0108e8b:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c0108e90:	85 c0                	test   %eax,%eax
c0108e92:	75 24                	jne    c0108eb8 <check_pgfault+0x45>
c0108e94:	c7 44 24 0c b3 e7 10 	movl   $0xc010e7b3,0xc(%esp)
c0108e9b:	c0 
c0108e9c:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108ea3:	c0 
c0108ea4:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108eab:	00 
c0108eac:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108eb3:	e8 38 7f ff ff       	call   c0100df0 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108eb8:	a1 0c 81 1b c0       	mov    0xc01b810c,%eax
c0108ebd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108ec0:	8b 15 00 3a 13 c0    	mov    0xc0133a00,%edx
c0108ec6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ec9:	89 50 0c             	mov    %edx,0xc(%eax)
c0108ecc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ecf:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ed2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ed8:	8b 00                	mov    (%eax),%eax
c0108eda:	85 c0                	test   %eax,%eax
c0108edc:	74 24                	je     c0108f02 <check_pgfault+0x8f>
c0108ede:	c7 44 24 0c cb e7 10 	movl   $0xc010e7cb,0xc(%esp)
c0108ee5:	c0 
c0108ee6:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108eed:	c0 
c0108eee:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108ef5:	00 
c0108ef6:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108efd:	e8 ee 7e ff ff       	call   c0100df0 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108f02:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108f09:	00 
c0108f0a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108f11:	00 
c0108f12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108f19:	e8 76 f3 ff ff       	call   c0108294 <vma_create>
c0108f1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108f21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108f25:	75 24                	jne    c0108f4b <check_pgfault+0xd8>
c0108f27:	c7 44 24 0c 5c e6 10 	movl   $0xc010e65c,0xc(%esp)
c0108f2e:	c0 
c0108f2f:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108f36:	c0 
c0108f37:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108f3e:	00 
c0108f3f:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108f46:	e8 a5 7e ff ff       	call   c0100df0 <__panic>

    insert_vma_struct(mm, vma);
c0108f4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f55:	89 04 24             	mov    %eax,(%esp)
c0108f58:	e8 ce f4 ff ff       	call   c010842b <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108f5d:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108f64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f6e:	89 04 24             	mov    %eax,(%esp)
c0108f71:	e8 5b f3 ff ff       	call   c01082d1 <find_vma>
c0108f76:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108f79:	74 24                	je     c0108f9f <check_pgfault+0x12c>
c0108f7b:	c7 44 24 0c d9 e7 10 	movl   $0xc010e7d9,0xc(%esp)
c0108f82:	c0 
c0108f83:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0108f8a:	c0 
c0108f8b:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108f92:	00 
c0108f93:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0108f9a:	e8 51 7e ff ff       	call   c0100df0 <__panic>

    int i, sum = 0;
c0108f9f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108fa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108fad:	eb 16                	jmp    c0108fc5 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0108faf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fb5:	01 d0                	add    %edx,%eax
c0108fb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fba:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fbf:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108fc2:	ff 45 f4             	incl   -0xc(%ebp)
c0108fc5:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108fc9:	7e e4                	jle    c0108faf <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0108fcb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108fd2:	eb 14                	jmp    c0108fe8 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0108fd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fda:	01 d0                	add    %edx,%eax
c0108fdc:	0f b6 00             	movzbl (%eax),%eax
c0108fdf:	0f be c0             	movsbl %al,%eax
c0108fe2:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108fe5:	ff 45 f4             	incl   -0xc(%ebp)
c0108fe8:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108fec:	7e e6                	jle    c0108fd4 <check_pgfault+0x161>
    }
    assert(sum == 0);
c0108fee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108ff2:	74 24                	je     c0109018 <check_pgfault+0x1a5>
c0108ff4:	c7 44 24 0c f3 e7 10 	movl   $0xc010e7f3,0xc(%esp)
c0108ffb:	c0 
c0108ffc:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0109003:	c0 
c0109004:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c010900b:	00 
c010900c:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0109013:	e8 d8 7d ff ff       	call   c0100df0 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0109018:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010901b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010901e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109021:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109026:	89 44 24 04          	mov    %eax,0x4(%esp)
c010902a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010902d:	89 04 24             	mov    %eax,(%esp)
c0109030:	e8 e3 cf ff ff       	call   c0106018 <page_remove>
    //free_page(pde2page(pgdir[0]));
    pgdir[0] = 0;
c0109035:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109038:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010903e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109041:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0109048:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010904b:	89 04 24             	mov    %eax,(%esp)
c010904e:	e8 0e f5 ff ff       	call   c0108561 <mm_destroy>
    check_mm_struct = NULL;
c0109053:	c7 05 0c 81 1b c0 00 	movl   $0x0,0xc01b810c
c010905a:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010905d:	e8 b4 c2 ff ff       	call   c0105316 <nr_free_pages>
c0109062:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0109065:	74 24                	je     c010908b <check_pgfault+0x218>
c0109067:	c7 44 24 0c fc e7 10 	movl   $0xc010e7fc,0xc(%esp)
c010906e:	c0 
c010906f:	c7 44 24 08 6b e5 10 	movl   $0xc010e56b,0x8(%esp)
c0109076:	c0 
c0109077:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c010907e:	00 
c010907f:	c7 04 24 80 e5 10 c0 	movl   $0xc010e580,(%esp)
c0109086:	e8 65 7d ff ff       	call   c0100df0 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010908b:	c7 04 24 23 e8 10 c0 	movl   $0xc010e823,(%esp)
c0109092:	e8 db 72 ff ff       	call   c0100372 <cprintf>
}
c0109097:	90                   	nop
c0109098:	89 ec                	mov    %ebp,%esp
c010909a:	5d                   	pop    %ebp
c010909b:	c3                   	ret    

c010909c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010909c:	55                   	push   %ebp
c010909d:	89 e5                	mov    %esp,%ebp
c010909f:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_INVAL;
c01090a2:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01090a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01090ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01090b3:	89 04 24             	mov    %eax,(%esp)
c01090b6:	e8 16 f2 ff ff       	call   c01082d1 <find_vma>
c01090bb:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01090be:	a1 10 81 1b c0       	mov    0xc01b8110,%eax
c01090c3:	40                   	inc    %eax
c01090c4:	a3 10 81 1b c0       	mov    %eax,0xc01b8110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01090c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01090cd:	74 0b                	je     c01090da <do_pgfault+0x3e>
c01090cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090d2:	8b 40 04             	mov    0x4(%eax),%eax
c01090d5:	39 45 10             	cmp    %eax,0x10(%ebp)
c01090d8:	73 18                	jae    c01090f2 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01090da:	8b 45 10             	mov    0x10(%ebp),%eax
c01090dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090e1:	c7 04 24 40 e8 10 c0 	movl   $0xc010e840,(%esp)
c01090e8:	e8 85 72 ff ff       	call   c0100372 <cprintf>
        goto failed;
c01090ed:	e9 81 02 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
    }
    //check the error_code
    switch (error_code & 3) {
c01090f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01090f5:	83 e0 03             	and    $0x3,%eax
c01090f8:	85 c0                	test   %eax,%eax
c01090fa:	74 34                	je     c0109130 <do_pgfault+0x94>
c01090fc:	83 f8 01             	cmp    $0x1,%eax
c01090ff:	74 1e                	je     c010911f <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0109101:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109104:	8b 40 0c             	mov    0xc(%eax),%eax
c0109107:	83 e0 02             	and    $0x2,%eax
c010910a:	85 c0                	test   %eax,%eax
c010910c:	75 40                	jne    c010914e <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010910e:	c7 04 24 70 e8 10 c0 	movl   $0xc010e870,(%esp)
c0109115:	e8 58 72 ff ff       	call   c0100372 <cprintf>
            goto failed;
c010911a:	e9 54 02 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010911f:	c7 04 24 d0 e8 10 c0 	movl   $0xc010e8d0,(%esp)
c0109126:	e8 47 72 ff ff       	call   c0100372 <cprintf>
        goto failed;
c010912b:	e9 43 02 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0109130:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109133:	8b 40 0c             	mov    0xc(%eax),%eax
c0109136:	83 e0 05             	and    $0x5,%eax
c0109139:	85 c0                	test   %eax,%eax
c010913b:	75 12                	jne    c010914f <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010913d:	c7 04 24 08 e9 10 c0 	movl   $0xc010e908,(%esp)
c0109144:	e8 29 72 ff ff       	call   c0100372 <cprintf>
            goto failed;
c0109149:	e9 25 02 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
        break;
c010914e:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010914f:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0109156:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109159:	8b 40 0c             	mov    0xc(%eax),%eax
c010915c:	83 e0 02             	and    $0x2,%eax
c010915f:	85 c0                	test   %eax,%eax
c0109161:	74 04                	je     c0109167 <do_pgfault+0xcb>
        perm |= PTE_W;
c0109163:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0109167:	8b 45 10             	mov    0x10(%ebp),%eax
c010916a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010916d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109170:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109175:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0109178:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c010917f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */
   // 查找当前虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0109186:	8b 45 08             	mov    0x8(%ebp),%eax
c0109189:	8b 40 0c             	mov    0xc(%eax),%eax
c010918c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0109193:	00 
c0109194:	8b 55 10             	mov    0x10(%ebp),%edx
c0109197:	89 54 24 04          	mov    %edx,0x4(%esp)
c010919b:	89 04 24             	mov    %eax,(%esp)
c010919e:	e8 8c c7 ff ff       	call   c010592f <get_pte>
c01091a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01091a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01091aa:	75 11                	jne    c01091bd <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c01091ac:	c7 04 24 6b e9 10 c0 	movl   $0xc010e96b,(%esp)
c01091b3:	e8 ba 71 ff ff       	call   c0100372 <cprintf>
        goto failed;
c01091b8:	e9 b6 01 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
    }
    // 如果这个页表项所对应的物理页不存在，则
    if (*ptep == 0) {
c01091bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01091c0:	8b 00                	mov    (%eax),%eax
c01091c2:	85 c0                	test   %eax,%eax
c01091c4:	75 35                	jne    c01091fb <do_pgfault+0x15f>
        // 分配一块物理页，并设置页表项
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01091c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01091c9:	8b 40 0c             	mov    0xc(%eax),%eax
c01091cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01091cf:	89 54 24 08          	mov    %edx,0x8(%esp)
c01091d3:	8b 55 10             	mov    0x10(%ebp),%edx
c01091d6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01091da:	89 04 24             	mov    %eax,(%esp)
c01091dd:	e8 97 cf ff ff       	call   c0106179 <pgdir_alloc_page>
c01091e2:	85 c0                	test   %eax,%eax
c01091e4:	0f 85 82 01 00 00    	jne    c010936c <do_pgfault+0x2d0>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01091ea:	c7 04 24 8c e9 10 c0 	movl   $0xc010e98c,(%esp)
c01091f1:	e8 7c 71 ff ff       	call   c0100372 <cprintf>
            goto failed;
c01091f6:	e9 78 01 00 00       	jmp    c0109373 <do_pgfault+0x2d7>
        }
    }
    else {
        struct Page *page=NULL;
c01091fb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
        // -------------------------------------------------------/
        if (*ptep & PTE_P) {
c0109202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109205:	8b 00                	mov    (%eax),%eax
c0109207:	83 e0 01             	and    $0x1,%eax
c010920a:	85 c0                	test   %eax,%eax
c010920c:	0f 84 bb 00 00 00    	je     c01092cd <do_pgfault+0x231>
            //panic("error write a non-writable pte");
            cprintf("\n\nCOW: ptep 0x%x, pte 0x%x\n",ptep, *ptep);
c0109212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109215:	8b 00                	mov    (%eax),%eax
c0109217:	89 44 24 08          	mov    %eax,0x8(%esp)
c010921b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010921e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109222:	c7 04 24 b3 e9 10 c0 	movl   $0xc010e9b3,(%esp)
c0109229:	e8 44 71 ff ff       	call   c0100372 <cprintf>
            // 原先所使用的只读物理页
            page = pte2page(*ptep);
c010922e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109231:	8b 00                	mov    (%eax),%eax
c0109233:	89 04 24             	mov    %eax,(%esp)
c0109236:	e8 73 ef ff ff       	call   c01081ae <pte2page>
c010923b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            // 如果该物理页面被多个进程引用
            if(page_ref(page) > 1)
c010923e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109241:	89 04 24             	mov    %eax,(%esp)
c0109244:	e8 a5 ef ff ff       	call   c01081ee <page_ref>
c0109249:	83 f8 01             	cmp    $0x1,%eax
c010924c:	7e 5a                	jle    c01092a8 <do_pgfault+0x20c>
            {
                // 释放当前PTE的引用并分配一个新物理页
                struct Page* newPage = pgdir_alloc_page(mm->pgdir, addr, perm);
c010924e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109251:	8b 40 0c             	mov    0xc(%eax),%eax
c0109254:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109257:	89 54 24 08          	mov    %edx,0x8(%esp)
c010925b:	8b 55 10             	mov    0x10(%ebp),%edx
c010925e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109262:	89 04 24             	mov    %eax,(%esp)
c0109265:	e8 0f cf ff ff       	call   c0106179 <pgdir_alloc_page>
c010926a:	89 45 e0             	mov    %eax,-0x20(%ebp)
                void * kva_src = page2kva(page);
c010926d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109270:	89 04 24             	mov    %eax,(%esp)
c0109273:	e8 e0 ee ff ff       	call   c0108158 <page2kva>
c0109278:	89 45 dc             	mov    %eax,-0x24(%ebp)
                void * kva_dst = page2kva(newPage);
c010927b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010927e:	89 04 24             	mov    %eax,(%esp)
c0109281:	e8 d2 ee ff ff       	call   c0108158 <page2kva>
c0109286:	89 45 d8             	mov    %eax,-0x28(%ebp)
                // 拷贝数据
                memcpy(kva_dst, kva_src, PGSIZE);
c0109289:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109290:	00 
c0109291:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109294:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109298:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010929b:	89 04 24             	mov    %eax,(%esp)
c010929e:	e8 33 36 00 00       	call   c010c8d6 <memcpy>
c01092a3:	e9 9a 00 00 00       	jmp    c0109342 <do_pgfault+0x2a6>
            }
            // 如果该物理页面只被当前进程所引用,即page_ref等1
            else
                // 则可以直接执行page_insert。该函数会重设其PTE权限。
                page_insert(mm->pgdir, page, addr, perm);
c01092a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01092ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01092ae:	8b 40 0c             	mov    0xc(%eax),%eax
c01092b1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01092b4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01092b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01092bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01092bf:	89 54 24 04          	mov    %edx,0x4(%esp)
c01092c3:	89 04 24             	mov    %eax,(%esp)
c01092c6:	e8 94 cd ff ff       	call   c010605f <page_insert>
c01092cb:	eb 75                	jmp    c0109342 <do_pgfault+0x2a6>
        } 
        else
        // ------------------------------------------------------/
        {
            // 如果swap已经初始化完成
            if(swap_init_ok) {
c01092cd:	a1 44 80 1b c0       	mov    0xc01b8044,%eax
c01092d2:	85 c0                	test   %eax,%eax
c01092d4:	74 55                	je     c010932b <do_pgfault+0x28f>
                // 将目标数据加载到某块新的物理页中。
                // 该物理页可能是尚未分配的物理页，也可能是从别的已分配物理页中取的
                if ((ret = swap_in(mm, addr, &page)) != 0) {
c01092d6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01092d9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01092dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01092e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01092e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e7:	89 04 24             	mov    %eax,(%esp)
c01092ea:	e8 38 df ff ff       	call   c0107227 <swap_in>
c01092ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01092f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01092f6:	74 0e                	je     c0109306 <do_pgfault+0x26a>
                    cprintf("swap_in in do_pgfault failed\n");
c01092f8:	c7 04 24 cf e9 10 c0 	movl   $0xc010e9cf,(%esp)
c01092ff:	e8 6e 70 ff ff       	call   c0100372 <cprintf>
                    goto failed;
c0109304:	eb 6d                	jmp    c0109373 <do_pgfault+0x2d7>
                }    
                // 将该物理页与对应的虚拟地址关联，同时设置页表。
                page_insert(mm->pgdir, page, addr, perm);
c0109306:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109309:	8b 45 08             	mov    0x8(%ebp),%eax
c010930c:	8b 40 0c             	mov    0xc(%eax),%eax
c010930f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109312:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0109316:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0109319:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010931d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109321:	89 04 24             	mov    %eax,(%esp)
c0109324:	e8 36 cd ff ff       	call   c010605f <page_insert>
c0109329:	eb 17                	jmp    c0109342 <do_pgfault+0x2a6>
            }
            else {
                cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010932b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010932e:	8b 00                	mov    (%eax),%eax
c0109330:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109334:	c7 04 24 f0 e9 10 c0 	movl   $0xc010e9f0,(%esp)
c010933b:	e8 32 70 ff ff       	call   c0100372 <cprintf>
                goto failed;
c0109340:	eb 31                	jmp    c0109373 <do_pgfault+0x2d7>
            }
        }
        // 当前缺失的页已经加载回内存中，所以设置当前页为可swap。
        swap_map_swappable(mm, addr, page, 1);
c0109342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109345:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010934c:	00 
c010934d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109351:	8b 45 10             	mov    0x10(%ebp),%eax
c0109354:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109358:	8b 45 08             	mov    0x8(%ebp),%eax
c010935b:	89 04 24             	mov    %eax,(%esp)
c010935e:	e8 fc dc ff ff       	call   c010705f <swap_map_swappable>
        page->pra_vaddr = addr;
c0109363:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109366:	8b 55 10             	mov    0x10(%ebp),%edx
c0109369:	89 50 1c             	mov    %edx,0x1c(%eax)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
   ret = 0;
c010936c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0109373:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109376:	89 ec                	mov    %ebp,%esp
c0109378:	5d                   	pop    %ebp
c0109379:	c3                   	ret    

c010937a <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c010937a:	55                   	push   %ebp
c010937b:	89 e5                	mov    %esp,%ebp
c010937d:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109380:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109384:	0f 84 e0 00 00 00    	je     c010946a <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c010938a:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0109391:	76 1c                	jbe    c01093af <user_mem_check+0x35>
c0109393:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109396:	8b 45 10             	mov    0x10(%ebp),%eax
c0109399:	01 d0                	add    %edx,%eax
c010939b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010939e:	73 0f                	jae    c01093af <user_mem_check+0x35>
c01093a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01093a6:	01 d0                	add    %edx,%eax
c01093a8:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c01093ad:	76 0a                	jbe    c01093b9 <user_mem_check+0x3f>
            return 0;
c01093af:	b8 00 00 00 00       	mov    $0x0,%eax
c01093b4:	e9 e2 00 00 00       	jmp    c010949b <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c01093b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01093bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01093bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01093c5:	01 d0                	add    %edx,%eax
c01093c7:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c01093ca:	e9 88 00 00 00       	jmp    c0109457 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c01093cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01093d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01093d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01093d9:	89 04 24             	mov    %eax,(%esp)
c01093dc:	e8 f0 ee ff ff       	call   c01082d1 <find_vma>
c01093e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01093e8:	74 0b                	je     c01093f5 <user_mem_check+0x7b>
c01093ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093ed:	8b 40 04             	mov    0x4(%eax),%eax
c01093f0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01093f3:	73 0a                	jae    c01093ff <user_mem_check+0x85>
                return 0;
c01093f5:	b8 00 00 00 00       	mov    $0x0,%eax
c01093fa:	e9 9c 00 00 00       	jmp    c010949b <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c01093ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109402:	8b 40 0c             	mov    0xc(%eax),%eax
c0109405:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109409:	74 07                	je     c0109412 <user_mem_check+0x98>
c010940b:	ba 02 00 00 00       	mov    $0x2,%edx
c0109410:	eb 05                	jmp    c0109417 <user_mem_check+0x9d>
c0109412:	ba 01 00 00 00       	mov    $0x1,%edx
c0109417:	21 d0                	and    %edx,%eax
c0109419:	85 c0                	test   %eax,%eax
c010941b:	75 07                	jne    c0109424 <user_mem_check+0xaa>
                return 0;
c010941d:	b8 00 00 00 00       	mov    $0x0,%eax
c0109422:	eb 77                	jmp    c010949b <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c0109424:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109428:	74 24                	je     c010944e <user_mem_check+0xd4>
c010942a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010942d:	8b 40 0c             	mov    0xc(%eax),%eax
c0109430:	83 e0 08             	and    $0x8,%eax
c0109433:	85 c0                	test   %eax,%eax
c0109435:	74 17                	je     c010944e <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c0109437:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010943a:	8b 40 04             	mov    0x4(%eax),%eax
c010943d:	05 00 10 00 00       	add    $0x1000,%eax
c0109442:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0109445:	73 07                	jae    c010944e <user_mem_check+0xd4>
                    return 0;
c0109447:	b8 00 00 00 00       	mov    $0x0,%eax
c010944c:	eb 4d                	jmp    c010949b <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c010944e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109451:	8b 40 08             	mov    0x8(%eax),%eax
c0109454:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c0109457:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010945a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010945d:	0f 82 6c ff ff ff    	jb     c01093cf <user_mem_check+0x55>
        }
        return 1;
c0109463:	b8 01 00 00 00       	mov    $0x1,%eax
c0109468:	eb 31                	jmp    c010949b <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c010946a:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c0109471:	76 23                	jbe    c0109496 <user_mem_check+0x11c>
c0109473:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109476:	8b 45 10             	mov    0x10(%ebp),%eax
c0109479:	01 d0                	add    %edx,%eax
c010947b:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010947e:	73 16                	jae    c0109496 <user_mem_check+0x11c>
c0109480:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109483:	8b 45 10             	mov    0x10(%ebp),%eax
c0109486:	01 d0                	add    %edx,%eax
c0109488:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c010948d:	77 07                	ja     c0109496 <user_mem_check+0x11c>
c010948f:	b8 01 00 00 00       	mov    $0x1,%eax
c0109494:	eb 05                	jmp    c010949b <user_mem_check+0x121>
c0109496:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010949b:	89 ec                	mov    %ebp,%esp
c010949d:	5d                   	pop    %ebp
c010949e:	c3                   	ret    

c010949f <page2ppn>:
page2ppn(struct Page *page) {
c010949f:	55                   	push   %ebp
c01094a0:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01094a2:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c01094a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ab:	29 d0                	sub    %edx,%eax
c01094ad:	c1 f8 05             	sar    $0x5,%eax
}
c01094b0:	5d                   	pop    %ebp
c01094b1:	c3                   	ret    

c01094b2 <page2pa>:
page2pa(struct Page *page) {
c01094b2:	55                   	push   %ebp
c01094b3:	89 e5                	mov    %esp,%ebp
c01094b5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01094b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01094bb:	89 04 24             	mov    %eax,(%esp)
c01094be:	e8 dc ff ff ff       	call   c010949f <page2ppn>
c01094c3:	c1 e0 0c             	shl    $0xc,%eax
}
c01094c6:	89 ec                	mov    %ebp,%esp
c01094c8:	5d                   	pop    %ebp
c01094c9:	c3                   	ret    

c01094ca <page2kva>:
page2kva(struct Page *page) {
c01094ca:	55                   	push   %ebp
c01094cb:	89 e5                	mov    %esp,%ebp
c01094cd:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01094d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d3:	89 04 24             	mov    %eax,(%esp)
c01094d6:	e8 d7 ff ff ff       	call   c01094b2 <page2pa>
c01094db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094e1:	c1 e8 0c             	shr    $0xc,%eax
c01094e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01094e7:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01094ec:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01094ef:	72 23                	jb     c0109514 <page2kva+0x4a>
c01094f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094f8:	c7 44 24 08 18 ea 10 	movl   $0xc010ea18,0x8(%esp)
c01094ff:	c0 
c0109500:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109507:	00 
c0109508:	c7 04 24 3b ea 10 c0 	movl   $0xc010ea3b,(%esp)
c010950f:	e8 dc 78 ff ff       	call   c0100df0 <__panic>
c0109514:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109517:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010951c:	89 ec                	mov    %ebp,%esp
c010951e:	5d                   	pop    %ebp
c010951f:	c3                   	ret    

c0109520 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109520:	55                   	push   %ebp
c0109521:	89 e5                	mov    %esp,%ebp
c0109523:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109526:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010952d:	e8 6d 86 ff ff       	call   c0101b9f <ide_device_valid>
c0109532:	85 c0                	test   %eax,%eax
c0109534:	75 1c                	jne    c0109552 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109536:	c7 44 24 08 49 ea 10 	movl   $0xc010ea49,0x8(%esp)
c010953d:	c0 
c010953e:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109545:	00 
c0109546:	c7 04 24 63 ea 10 c0 	movl   $0xc010ea63,(%esp)
c010954d:	e8 9e 78 ff ff       	call   c0100df0 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109552:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109559:	e8 81 86 ff ff       	call   c0101bdf <ide_device_size>
c010955e:	c1 e8 03             	shr    $0x3,%eax
c0109561:	a3 40 80 1b c0       	mov    %eax,0xc01b8040
}
c0109566:	90                   	nop
c0109567:	89 ec                	mov    %ebp,%esp
c0109569:	5d                   	pop    %ebp
c010956a:	c3                   	ret    

c010956b <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c010956b:	55                   	push   %ebp
c010956c:	89 e5                	mov    %esp,%ebp
c010956e:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109574:	89 04 24             	mov    %eax,(%esp)
c0109577:	e8 4e ff ff ff       	call   c01094ca <page2kva>
c010957c:	8b 55 08             	mov    0x8(%ebp),%edx
c010957f:	c1 ea 08             	shr    $0x8,%edx
c0109582:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109589:	74 0b                	je     c0109596 <swapfs_read+0x2b>
c010958b:	8b 15 40 80 1b c0    	mov    0xc01b8040,%edx
c0109591:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109594:	72 23                	jb     c01095b9 <swapfs_read+0x4e>
c0109596:	8b 45 08             	mov    0x8(%ebp),%eax
c0109599:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010959d:	c7 44 24 08 74 ea 10 	movl   $0xc010ea74,0x8(%esp)
c01095a4:	c0 
c01095a5:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01095ac:	00 
c01095ad:	c7 04 24 63 ea 10 c0 	movl   $0xc010ea63,(%esp)
c01095b4:	e8 37 78 ff ff       	call   c0100df0 <__panic>
c01095b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01095bc:	c1 e2 03             	shl    $0x3,%edx
c01095bf:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01095c6:	00 
c01095c7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01095cb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01095cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01095d6:	e8 41 86 ff ff       	call   c0101c1c <ide_read_secs>
}
c01095db:	89 ec                	mov    %ebp,%esp
c01095dd:	5d                   	pop    %ebp
c01095de:	c3                   	ret    

c01095df <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01095df:	55                   	push   %ebp
c01095e0:	89 e5                	mov    %esp,%ebp
c01095e2:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01095e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095e8:	89 04 24             	mov    %eax,(%esp)
c01095eb:	e8 da fe ff ff       	call   c01094ca <page2kva>
c01095f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01095f3:	c1 ea 08             	shr    $0x8,%edx
c01095f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01095f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01095fd:	74 0b                	je     c010960a <swapfs_write+0x2b>
c01095ff:	8b 15 40 80 1b c0    	mov    0xc01b8040,%edx
c0109605:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109608:	72 23                	jb     c010962d <swapfs_write+0x4e>
c010960a:	8b 45 08             	mov    0x8(%ebp),%eax
c010960d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109611:	c7 44 24 08 74 ea 10 	movl   $0xc010ea74,0x8(%esp)
c0109618:	c0 
c0109619:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0109620:	00 
c0109621:	c7 04 24 63 ea 10 c0 	movl   $0xc010ea63,(%esp)
c0109628:	e8 c3 77 ff ff       	call   c0100df0 <__panic>
c010962d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109630:	c1 e2 03             	shl    $0x3,%edx
c0109633:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010963a:	00 
c010963b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010963f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109643:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010964a:	e8 0e 88 ff ff       	call   c0101e5d <ide_write_secs>
}
c010964f:	89 ec                	mov    %ebp,%esp
c0109651:	5d                   	pop    %ebp
c0109652:	c3                   	ret    

c0109653 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0109653:	52                   	push   %edx
    call *%ebx              # call fn
c0109654:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109656:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109657:	e8 cf 0c 00 00       	call   c010a32b <do_exit>

c010965c <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c010965c:	55                   	push   %ebp
c010965d:	89 e5                	mov    %esp,%ebp
c010965f:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0109662:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109665:	8b 45 08             	mov    0x8(%ebp),%eax
c0109668:	0f ab 02             	bts    %eax,(%edx)
c010966b:	19 c0                	sbb    %eax,%eax
c010966d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109670:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109674:	0f 95 c0             	setne  %al
c0109677:	0f b6 c0             	movzbl %al,%eax
}
c010967a:	89 ec                	mov    %ebp,%esp
c010967c:	5d                   	pop    %ebp
c010967d:	c3                   	ret    

c010967e <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c010967e:	55                   	push   %ebp
c010967f:	89 e5                	mov    %esp,%ebp
c0109681:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c0109684:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109687:	8b 45 08             	mov    0x8(%ebp),%eax
c010968a:	0f b3 02             	btr    %eax,(%edx)
c010968d:	19 c0                	sbb    %eax,%eax
c010968f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109692:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109696:	0f 95 c0             	setne  %al
c0109699:	0f b6 c0             	movzbl %al,%eax
}
c010969c:	89 ec                	mov    %ebp,%esp
c010969e:	5d                   	pop    %ebp
c010969f:	c3                   	ret    

c01096a0 <__intr_save>:
__intr_save(void) {
c01096a0:	55                   	push   %ebp
c01096a1:	89 e5                	mov    %esp,%ebp
c01096a3:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01096a6:	9c                   	pushf  
c01096a7:	58                   	pop    %eax
c01096a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01096ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01096ae:	25 00 02 00 00       	and    $0x200,%eax
c01096b3:	85 c0                	test   %eax,%eax
c01096b5:	74 0c                	je     c01096c3 <__intr_save+0x23>
        intr_disable();
c01096b7:	e8 ea 89 ff ff       	call   c01020a6 <intr_disable>
        return 1;
c01096bc:	b8 01 00 00 00       	mov    $0x1,%eax
c01096c1:	eb 05                	jmp    c01096c8 <__intr_save+0x28>
    return 0;
c01096c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01096c8:	89 ec                	mov    %ebp,%esp
c01096ca:	5d                   	pop    %ebp
c01096cb:	c3                   	ret    

c01096cc <__intr_restore>:
__intr_restore(bool flag) {
c01096cc:	55                   	push   %ebp
c01096cd:	89 e5                	mov    %esp,%ebp
c01096cf:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01096d2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01096d6:	74 05                	je     c01096dd <__intr_restore+0x11>
        intr_enable();
c01096d8:	e8 c1 89 ff ff       	call   c010209e <intr_enable>
}
c01096dd:	90                   	nop
c01096de:	89 ec                	mov    %ebp,%esp
c01096e0:	5d                   	pop    %ebp
c01096e1:	c3                   	ret    

c01096e2 <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c01096e2:	55                   	push   %ebp
c01096e3:	89 e5                	mov    %esp,%ebp
c01096e5:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c01096e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01096eb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01096f6:	e8 61 ff ff ff       	call   c010965c <test_and_set_bit>
c01096fb:	85 c0                	test   %eax,%eax
c01096fd:	0f 94 c0             	sete   %al
c0109700:	0f b6 c0             	movzbl %al,%eax
}
c0109703:	89 ec                	mov    %ebp,%esp
c0109705:	5d                   	pop    %ebp
c0109706:	c3                   	ret    

c0109707 <lock>:

static inline void
lock(lock_t *lock) {
c0109707:	55                   	push   %ebp
c0109708:	89 e5                	mov    %esp,%ebp
c010970a:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c010970d:	eb 05                	jmp    c0109714 <lock+0xd>
        schedule();
c010970f:	e8 76 23 00 00       	call   c010ba8a <schedule>
    while (!try_lock(lock)) {
c0109714:	8b 45 08             	mov    0x8(%ebp),%eax
c0109717:	89 04 24             	mov    %eax,(%esp)
c010971a:	e8 c3 ff ff ff       	call   c01096e2 <try_lock>
c010971f:	85 c0                	test   %eax,%eax
c0109721:	74 ec                	je     c010970f <lock+0x8>
    }
}
c0109723:	90                   	nop
c0109724:	90                   	nop
c0109725:	89 ec                	mov    %ebp,%esp
c0109727:	5d                   	pop    %ebp
c0109728:	c3                   	ret    

c0109729 <unlock>:

static inline void
unlock(lock_t *lock) {
c0109729:	55                   	push   %ebp
c010972a:	89 e5                	mov    %esp,%ebp
c010972c:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c010972f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109732:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109736:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010973d:	e8 3c ff ff ff       	call   c010967e <test_and_clear_bit>
c0109742:	85 c0                	test   %eax,%eax
c0109744:	75 1c                	jne    c0109762 <unlock+0x39>
        panic("Unlock failed.\n");
c0109746:	c7 44 24 08 94 ea 10 	movl   $0xc010ea94,0x8(%esp)
c010974d:	c0 
c010974e:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c0109755:	00 
c0109756:	c7 04 24 a4 ea 10 c0 	movl   $0xc010eaa4,(%esp)
c010975d:	e8 8e 76 ff ff       	call   c0100df0 <__panic>
    }
}
c0109762:	90                   	nop
c0109763:	89 ec                	mov    %ebp,%esp
c0109765:	5d                   	pop    %ebp
c0109766:	c3                   	ret    

c0109767 <page2ppn>:
page2ppn(struct Page *page) {
c0109767:	55                   	push   %ebp
c0109768:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010976a:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c0109770:	8b 45 08             	mov    0x8(%ebp),%eax
c0109773:	29 d0                	sub    %edx,%eax
c0109775:	c1 f8 05             	sar    $0x5,%eax
}
c0109778:	5d                   	pop    %ebp
c0109779:	c3                   	ret    

c010977a <page2pa>:
page2pa(struct Page *page) {
c010977a:	55                   	push   %ebp
c010977b:	89 e5                	mov    %esp,%ebp
c010977d:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109780:	8b 45 08             	mov    0x8(%ebp),%eax
c0109783:	89 04 24             	mov    %eax,(%esp)
c0109786:	e8 dc ff ff ff       	call   c0109767 <page2ppn>
c010978b:	c1 e0 0c             	shl    $0xc,%eax
}
c010978e:	89 ec                	mov    %ebp,%esp
c0109790:	5d                   	pop    %ebp
c0109791:	c3                   	ret    

c0109792 <pa2page>:
pa2page(uintptr_t pa) {
c0109792:	55                   	push   %ebp
c0109793:	89 e5                	mov    %esp,%ebp
c0109795:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109798:	8b 45 08             	mov    0x8(%ebp),%eax
c010979b:	c1 e8 0c             	shr    $0xc,%eax
c010979e:	89 c2                	mov    %eax,%edx
c01097a0:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01097a5:	39 c2                	cmp    %eax,%edx
c01097a7:	72 1c                	jb     c01097c5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01097a9:	c7 44 24 08 b8 ea 10 	movl   $0xc010eab8,0x8(%esp)
c01097b0:	c0 
c01097b1:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01097b8:	00 
c01097b9:	c7 04 24 d7 ea 10 c0 	movl   $0xc010ead7,(%esp)
c01097c0:	e8 2b 76 ff ff       	call   c0100df0 <__panic>
    return &pages[PPN(pa)];
c01097c5:	8b 15 a0 7f 1b c0    	mov    0xc01b7fa0,%edx
c01097cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ce:	c1 e8 0c             	shr    $0xc,%eax
c01097d1:	c1 e0 05             	shl    $0x5,%eax
c01097d4:	01 d0                	add    %edx,%eax
}
c01097d6:	89 ec                	mov    %ebp,%esp
c01097d8:	5d                   	pop    %ebp
c01097d9:	c3                   	ret    

c01097da <page2kva>:
page2kva(struct Page *page) {
c01097da:	55                   	push   %ebp
c01097db:	89 e5                	mov    %esp,%ebp
c01097dd:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01097e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e3:	89 04 24             	mov    %eax,(%esp)
c01097e6:	e8 8f ff ff ff       	call   c010977a <page2pa>
c01097eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01097ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097f1:	c1 e8 0c             	shr    $0xc,%eax
c01097f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01097f7:	a1 a4 7f 1b c0       	mov    0xc01b7fa4,%eax
c01097fc:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01097ff:	72 23                	jb     c0109824 <page2kva+0x4a>
c0109801:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109804:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109808:	c7 44 24 08 e8 ea 10 	movl   $0xc010eae8,0x8(%esp)
c010980f:	c0 
c0109810:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109817:	00 
c0109818:	c7 04 24 d7 ea 10 c0 	movl   $0xc010ead7,(%esp)
c010981f:	e8 cc 75 ff ff       	call   c0100df0 <__panic>
c0109824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109827:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010982c:	89 ec                	mov    %ebp,%esp
c010982e:	5d                   	pop    %ebp
c010982f:	c3                   	ret    

c0109830 <kva2page>:
kva2page(void *kva) {
c0109830:	55                   	push   %ebp
c0109831:	89 e5                	mov    %esp,%ebp
c0109833:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109836:	8b 45 08             	mov    0x8(%ebp),%eax
c0109839:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010983c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109843:	77 23                	ja     c0109868 <kva2page+0x38>
c0109845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109848:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010984c:	c7 44 24 08 0c eb 10 	movl   $0xc010eb0c,0x8(%esp)
c0109853:	c0 
c0109854:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c010985b:	00 
c010985c:	c7 04 24 d7 ea 10 c0 	movl   $0xc010ead7,(%esp)
c0109863:	e8 88 75 ff ff       	call   c0100df0 <__panic>
c0109868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010986b:	05 00 00 00 40       	add    $0x40000000,%eax
c0109870:	89 04 24             	mov    %eax,(%esp)
c0109873:	e8 1a ff ff ff       	call   c0109792 <pa2page>
}
c0109878:	89 ec                	mov    %ebp,%esp
c010987a:	5d                   	pop    %ebp
c010987b:	c3                   	ret    

c010987c <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c010987c:	55                   	push   %ebp
c010987d:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c010987f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109882:	8b 40 18             	mov    0x18(%eax),%eax
c0109885:	8d 50 01             	lea    0x1(%eax),%edx
c0109888:	8b 45 08             	mov    0x8(%ebp),%eax
c010988b:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c010988e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109891:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109894:	5d                   	pop    %ebp
c0109895:	c3                   	ret    

c0109896 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c0109896:	55                   	push   %ebp
c0109897:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c0109899:	8b 45 08             	mov    0x8(%ebp),%eax
c010989c:	8b 40 18             	mov    0x18(%eax),%eax
c010989f:	8d 50 ff             	lea    -0x1(%eax),%edx
c01098a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01098a5:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01098a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ab:	8b 40 18             	mov    0x18(%eax),%eax
}
c01098ae:	5d                   	pop    %ebp
c01098af:	c3                   	ret    

c01098b0 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c01098b0:	55                   	push   %ebp
c01098b1:	89 e5                	mov    %esp,%ebp
c01098b3:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01098b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01098ba:	74 0e                	je     c01098ca <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c01098bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01098bf:	83 c0 1c             	add    $0x1c,%eax
c01098c2:	89 04 24             	mov    %eax,(%esp)
c01098c5:	e8 3d fe ff ff       	call   c0109707 <lock>
    }
}
c01098ca:	90                   	nop
c01098cb:	89 ec                	mov    %ebp,%esp
c01098cd:	5d                   	pop    %ebp
c01098ce:	c3                   	ret    

c01098cf <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c01098cf:	55                   	push   %ebp
c01098d0:	89 e5                	mov    %esp,%ebp
c01098d2:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01098d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01098d9:	74 0e                	je     c01098e9 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c01098db:	8b 45 08             	mov    0x8(%ebp),%eax
c01098de:	83 c0 1c             	add    $0x1c,%eax
c01098e1:	89 04 24             	mov    %eax,(%esp)
c01098e4:	e8 40 fe ff ff       	call   c0109729 <unlock>
    }
}
c01098e9:	90                   	nop
c01098ea:	89 ec                	mov    %ebp,%esp
c01098ec:	5d                   	pop    %ebp
c01098ed:	c3                   	ret    

c01098ee <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01098ee:	55                   	push   %ebp
c01098ef:	89 e5                	mov    %esp,%ebp
c01098f1:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c01098f4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
c01098fb:	e8 e3 b4 ff ff       	call   c0104de3 <kmalloc>
c0109900:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109907:	0f 84 a1 00 00 00    	je     c01099ae <alloc_proc+0xc0>
        memset(proc, 0, sizeof(struct proc_struct));
c010990d:	c7 44 24 08 a0 00 00 	movl   $0xa0,0x8(%esp)
c0109914:	00 
c0109915:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010991c:	00 
c010991d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109920:	89 04 24             	mov    %eax,(%esp)
c0109923:	e8 c9 2e 00 00       	call   c010c7f1 <memset>
        proc->state = PROC_UNINIT;
c0109928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010992b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109931:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109934:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->cr3 = boot_cr3;
c010993b:	8b 15 a8 7f 1b c0    	mov    0xc01b7fa8,%edx
c0109941:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109944:	89 50 40             	mov    %edx,0x40(%eax)
        proc->lab6_priority = 1;
c0109947:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010994a:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c0109951:	00 00 00 
        memset(&(proc->context), 0, sizeof(struct context));
c0109954:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109957:	83 c0 1c             	add    $0x1c,%eax
c010995a:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109961:	00 
c0109962:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109969:	00 
c010996a:	89 04 24             	mov    %eax,(%esp)
c010996d:	e8 7f 2e 00 00       	call   c010c7f1 <memset>
        memset(proc->name, 0, PROC_NAME_LEN);
c0109972:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109975:	83 c0 48             	add    $0x48,%eax
c0109978:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010997f:	00 
c0109980:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109987:	00 
c0109988:	89 04 24             	mov    %eax,(%esp)
c010998b:	e8 61 2e 00 00       	call   c010c7f1 <memset>
        list_init(&(proc->run_link));
c0109990:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109993:	83 e8 80             	sub    $0xffffff80,%eax
c0109996:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c0109999:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010999c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010999f:	89 50 04             	mov    %edx,0x4(%eax)
c01099a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099a5:	8b 50 04             	mov    0x4(%eax),%edx
c01099a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099ab:	89 10                	mov    %edx,(%eax)
}
c01099ad:	90                   	nop
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
    }
    return proc;
c01099ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01099b1:	89 ec                	mov    %ebp,%esp
c01099b3:	5d                   	pop    %ebp
c01099b4:	c3                   	ret    

c01099b5 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01099b5:	55                   	push   %ebp
c01099b6:	89 e5                	mov    %esp,%ebp
c01099b8:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01099bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01099be:	83 c0 48             	add    $0x48,%eax
c01099c1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01099c8:	00 
c01099c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01099d0:	00 
c01099d1:	89 04 24             	mov    %eax,(%esp)
c01099d4:	e8 18 2e 00 00       	call   c010c7f1 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01099d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01099dc:	8d 50 48             	lea    0x48(%eax),%edx
c01099df:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01099e6:	00 
c01099e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01099ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099ee:	89 14 24             	mov    %edx,(%esp)
c01099f1:	e8 e0 2e 00 00       	call   c010c8d6 <memcpy>
}
c01099f6:	89 ec                	mov    %ebp,%esp
c01099f8:	5d                   	pop    %ebp
c01099f9:	c3                   	ret    

c01099fa <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01099fa:	55                   	push   %ebp
c01099fb:	89 e5                	mov    %esp,%ebp
c01099fd:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109a00:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109a07:	00 
c0109a08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109a0f:	00 
c0109a10:	c7 04 24 44 a1 1b c0 	movl   $0xc01ba144,(%esp)
c0109a17:	e8 d5 2d 00 00       	call   c010c7f1 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a1f:	83 c0 48             	add    $0x48,%eax
c0109a22:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109a29:	00 
c0109a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a2e:	c7 04 24 44 a1 1b c0 	movl   $0xc01ba144,(%esp)
c0109a35:	e8 9c 2e 00 00       	call   c010c8d6 <memcpy>
}
c0109a3a:	89 ec                	mov    %ebp,%esp
c0109a3c:	5d                   	pop    %ebp
c0109a3d:	c3                   	ret    

c0109a3e <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109a3e:	55                   	push   %ebp
c0109a3f:	89 e5                	mov    %esp,%ebp
c0109a41:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c0109a44:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a47:	83 c0 58             	add    $0x58,%eax
c0109a4a:	c7 45 fc 20 81 1b c0 	movl   $0xc01b8120,-0x4(%ebp)
c0109a51:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a63:	8b 40 04             	mov    0x4(%eax),%eax
c0109a66:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109a69:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109a6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a6f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c0109a75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a78:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109a7b:	89 10                	mov    %edx,(%eax)
c0109a7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a80:	8b 10                	mov    (%eax),%edx
c0109a82:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a85:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109a8e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a94:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a97:	89 10                	mov    %edx,(%eax)
}
c0109a99:	90                   	nop
}
c0109a9a:	90                   	nop
}
c0109a9b:	90                   	nop
    proc->yptr = NULL;
c0109a9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a9f:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c0109aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109aa9:	8b 40 14             	mov    0x14(%eax),%eax
c0109aac:	8b 50 70             	mov    0x70(%eax),%edx
c0109aaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ab2:	89 50 78             	mov    %edx,0x78(%eax)
c0109ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ab8:	8b 40 78             	mov    0x78(%eax),%eax
c0109abb:	85 c0                	test   %eax,%eax
c0109abd:	74 0c                	je     c0109acb <set_links+0x8d>
        proc->optr->yptr = proc;
c0109abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ac2:	8b 40 78             	mov    0x78(%eax),%eax
c0109ac5:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ac8:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0109acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ace:	8b 40 14             	mov    0x14(%eax),%eax
c0109ad1:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ad4:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c0109ad7:	a1 40 a1 1b c0       	mov    0xc01ba140,%eax
c0109adc:	40                   	inc    %eax
c0109add:	a3 40 a1 1b c0       	mov    %eax,0xc01ba140
}
c0109ae2:	90                   	nop
c0109ae3:	89 ec                	mov    %ebp,%esp
c0109ae5:	5d                   	pop    %ebp
c0109ae6:	c3                   	ret    

c0109ae7 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0109ae7:	55                   	push   %ebp
c0109ae8:	89 e5                	mov    %esp,%ebp
c0109aea:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0109af0:	83 c0 58             	add    $0x58,%eax
c0109af3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109af9:	8b 40 04             	mov    0x4(%eax),%eax
c0109afc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109aff:	8b 12                	mov    (%edx),%edx
c0109b01:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109b07:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b0d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b13:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109b16:	89 10                	mov    %edx,(%eax)
}
c0109b18:	90                   	nop
}
c0109b19:	90                   	nop
    if (proc->optr != NULL) {
c0109b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b1d:	8b 40 78             	mov    0x78(%eax),%eax
c0109b20:	85 c0                	test   %eax,%eax
c0109b22:	74 0f                	je     c0109b33 <remove_links+0x4c>
        proc->optr->yptr = proc->yptr;
c0109b24:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b27:	8b 40 78             	mov    0x78(%eax),%eax
c0109b2a:	8b 55 08             	mov    0x8(%ebp),%edx
c0109b2d:	8b 52 74             	mov    0x74(%edx),%edx
c0109b30:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109b33:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b36:	8b 40 74             	mov    0x74(%eax),%eax
c0109b39:	85 c0                	test   %eax,%eax
c0109b3b:	74 11                	je     c0109b4e <remove_links+0x67>
        proc->yptr->optr = proc->optr;
c0109b3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b40:	8b 40 74             	mov    0x74(%eax),%eax
c0109b43:	8b 55 08             	mov    0x8(%ebp),%edx
c0109b46:	8b 52 78             	mov    0x78(%edx),%edx
c0109b49:	89 50 78             	mov    %edx,0x78(%eax)
c0109b4c:	eb 0f                	jmp    c0109b5d <remove_links+0x76>
    }
    else {
       proc->parent->cptr = proc->optr;
c0109b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b51:	8b 40 14             	mov    0x14(%eax),%eax
c0109b54:	8b 55 08             	mov    0x8(%ebp),%edx
c0109b57:	8b 52 78             	mov    0x78(%edx),%edx
c0109b5a:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c0109b5d:	a1 40 a1 1b c0       	mov    0xc01ba140,%eax
c0109b62:	48                   	dec    %eax
c0109b63:	a3 40 a1 1b c0       	mov    %eax,0xc01ba140
}
c0109b68:	90                   	nop
c0109b69:	89 ec                	mov    %ebp,%esp
c0109b6b:	5d                   	pop    %ebp
c0109b6c:	c3                   	ret    

c0109b6d <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109b6d:	55                   	push   %ebp
c0109b6e:	89 e5                	mov    %esp,%ebp
c0109b70:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109b73:	c7 45 f8 20 81 1b c0 	movl   $0xc01b8120,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109b7a:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109b7f:	40                   	inc    %eax
c0109b80:	a3 80 3a 13 c0       	mov    %eax,0xc0133a80
c0109b85:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109b8a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109b8f:	7e 0c                	jle    c0109b9d <get_pid+0x30>
        last_pid = 1;
c0109b91:	c7 05 80 3a 13 c0 01 	movl   $0x1,0xc0133a80
c0109b98:	00 00 00 
        goto inside;
c0109b9b:	eb 14                	jmp    c0109bb1 <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c0109b9d:	8b 15 80 3a 13 c0    	mov    0xc0133a80,%edx
c0109ba3:	a1 84 3a 13 c0       	mov    0xc0133a84,%eax
c0109ba8:	39 c2                	cmp    %eax,%edx
c0109baa:	0f 8c ab 00 00 00    	jl     c0109c5b <get_pid+0xee>
    inside:
c0109bb0:	90                   	nop
        next_safe = MAX_PID;
c0109bb1:	c7 05 84 3a 13 c0 00 	movl   $0x2000,0xc0133a84
c0109bb8:	20 00 00 
    repeat:
        le = list;
c0109bbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109bbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109bc1:	eb 7d                	jmp    c0109c40 <get_pid+0xd3>
            proc = le2proc(le, list_link);
c0109bc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109bc6:	83 e8 58             	sub    $0x58,%eax
c0109bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bcf:	8b 50 04             	mov    0x4(%eax),%edx
c0109bd2:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109bd7:	39 c2                	cmp    %eax,%edx
c0109bd9:	75 3c                	jne    c0109c17 <get_pid+0xaa>
                if (++ last_pid >= next_safe) {
c0109bdb:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109be0:	40                   	inc    %eax
c0109be1:	a3 80 3a 13 c0       	mov    %eax,0xc0133a80
c0109be6:	8b 15 80 3a 13 c0    	mov    0xc0133a80,%edx
c0109bec:	a1 84 3a 13 c0       	mov    0xc0133a84,%eax
c0109bf1:	39 c2                	cmp    %eax,%edx
c0109bf3:	7c 4b                	jl     c0109c40 <get_pid+0xd3>
                    if (last_pid >= MAX_PID) {
c0109bf5:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109bfa:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109bff:	7e 0a                	jle    c0109c0b <get_pid+0x9e>
                        last_pid = 1;
c0109c01:	c7 05 80 3a 13 c0 01 	movl   $0x1,0xc0133a80
c0109c08:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109c0b:	c7 05 84 3a 13 c0 00 	movl   $0x2000,0xc0133a84
c0109c12:	20 00 00 
                    goto repeat;
c0109c15:	eb a4                	jmp    c0109bbb <get_pid+0x4e>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c1a:	8b 50 04             	mov    0x4(%eax),%edx
c0109c1d:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
c0109c22:	39 c2                	cmp    %eax,%edx
c0109c24:	7e 1a                	jle    c0109c40 <get_pid+0xd3>
c0109c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c29:	8b 50 04             	mov    0x4(%eax),%edx
c0109c2c:	a1 84 3a 13 c0       	mov    0xc0133a84,%eax
c0109c31:	39 c2                	cmp    %eax,%edx
c0109c33:	7d 0b                	jge    c0109c40 <get_pid+0xd3>
                next_safe = proc->pid;
c0109c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c38:	8b 40 04             	mov    0x4(%eax),%eax
c0109c3b:	a3 84 3a 13 c0       	mov    %eax,0xc0133a84
c0109c40:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109c43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c49:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109c52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109c55:	0f 85 68 ff ff ff    	jne    c0109bc3 <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0109c5b:	a1 80 3a 13 c0       	mov    0xc0133a80,%eax
}
c0109c60:	89 ec                	mov    %ebp,%esp
c0109c62:	5d                   	pop    %ebp
c0109c63:	c3                   	ret    

c0109c64 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109c64:	55                   	push   %ebp
c0109c65:	89 e5                	mov    %esp,%ebp
c0109c67:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109c6a:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0109c6f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109c72:	74 64                	je     c0109cd8 <proc_run+0x74>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109c74:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0109c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109c82:	e8 19 fa ff ff       	call   c01096a0 <__intr_save>
c0109c87:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109c8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c8d:	a3 30 81 1b c0       	mov    %eax,0xc01b8130
            load_esp0(next->kstack + KSTACKSIZE);
c0109c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c95:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c98:	05 00 20 00 00       	add    $0x2000,%eax
c0109c9d:	89 04 24             	mov    %eax,(%esp)
c0109ca0:	e8 7d b4 ff ff       	call   c0105122 <load_esp0>
            lcr3(next->cr3);
c0109ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ca8:	8b 40 40             	mov    0x40(%eax),%eax
c0109cab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109cae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109cb1:	0f 22 d8             	mov    %eax,%cr3
}
c0109cb4:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0109cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cb8:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cbe:	83 c0 1c             	add    $0x1c,%eax
c0109cc1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109cc5:	89 04 24             	mov    %eax,(%esp)
c0109cc8:	e8 03 16 00 00       	call   c010b2d0 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cd0:	89 04 24             	mov    %eax,(%esp)
c0109cd3:	e8 f4 f9 ff ff       	call   c01096cc <__intr_restore>
    }
}
c0109cd8:	90                   	nop
c0109cd9:	89 ec                	mov    %ebp,%esp
c0109cdb:	5d                   	pop    %ebp
c0109cdc:	c3                   	ret    

c0109cdd <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109cdd:	55                   	push   %ebp
c0109cde:	89 e5                	mov    %esp,%ebp
c0109ce0:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109ce3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0109ce8:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109ceb:	89 04 24             	mov    %eax,(%esp)
c0109cee:	e8 73 8e ff ff       	call   c0102b66 <forkrets>
}
c0109cf3:	90                   	nop
c0109cf4:	89 ec                	mov    %ebp,%esp
c0109cf6:	5d                   	pop    %ebp
c0109cf7:	c3                   	ret    

c0109cf8 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109cf8:	55                   	push   %ebp
c0109cf9:	89 e5                	mov    %esp,%ebp
c0109cfb:	83 ec 38             	sub    $0x38,%esp
c0109cfe:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d04:	8d 58 60             	lea    0x60(%eax),%ebx
c0109d07:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d0a:	8b 40 04             	mov    0x4(%eax),%eax
c0109d0d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109d14:	00 
c0109d15:	89 04 24             	mov    %eax,(%esp)
c0109d18:	e8 37 20 00 00       	call   c010bd54 <hash32>
c0109d1d:	c1 e0 03             	shl    $0x3,%eax
c0109d20:	05 40 81 1b c0       	add    $0xc01b8140,%eax
c0109d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d28:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d34:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109d37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d3a:	8b 40 04             	mov    0x4(%eax),%eax
c0109d3d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109d40:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109d43:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109d46:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109d49:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109d4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109d52:	89 10                	mov    %edx,(%eax)
c0109d54:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109d57:	8b 10                	mov    (%eax),%edx
c0109d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109d5c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109d5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109d62:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109d65:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109d6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109d6e:	89 10                	mov    %edx,(%eax)
}
c0109d70:	90                   	nop
}
c0109d71:	90                   	nop
}
c0109d72:	90                   	nop
}
c0109d73:	90                   	nop
c0109d74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109d77:	89 ec                	mov    %ebp,%esp
c0109d79:	5d                   	pop    %ebp
c0109d7a:	c3                   	ret    

c0109d7b <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109d7b:	55                   	push   %ebp
c0109d7c:	89 e5                	mov    %esp,%ebp
c0109d7e:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109d81:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d84:	83 c0 60             	add    $0x60,%eax
c0109d87:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109d8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d8d:	8b 40 04             	mov    0x4(%eax),%eax
c0109d90:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109d93:	8b 12                	mov    (%edx),%edx
c0109d95:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109d98:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109d9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109da1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109da7:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109daa:	89 10                	mov    %edx,(%eax)
}
c0109dac:	90                   	nop
}
c0109dad:	90                   	nop
}
c0109dae:	90                   	nop
c0109daf:	89 ec                	mov    %ebp,%esp
c0109db1:	5d                   	pop    %ebp
c0109db2:	c3                   	ret    

c0109db3 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109db3:	55                   	push   %ebp
c0109db4:	89 e5                	mov    %esp,%ebp
c0109db6:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109db9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109dbd:	7e 5f                	jle    c0109e1e <find_proc+0x6b>
c0109dbf:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109dc6:	7f 56                	jg     c0109e1e <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109dc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dcb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109dd2:	00 
c0109dd3:	89 04 24             	mov    %eax,(%esp)
c0109dd6:	e8 79 1f 00 00       	call   c010bd54 <hash32>
c0109ddb:	c1 e0 03             	shl    $0x3,%eax
c0109dde:	05 40 81 1b c0       	add    $0xc01b8140,%eax
c0109de3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109de9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109dec:	eb 19                	jmp    c0109e07 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109df1:	83 e8 60             	sub    $0x60,%eax
c0109df4:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109dfa:	8b 40 04             	mov    0x4(%eax),%eax
c0109dfd:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109e00:	75 05                	jne    c0109e07 <find_proc+0x54>
                return proc;
c0109e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e05:	eb 1c                	jmp    c0109e23 <find_proc+0x70>
c0109e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109e10:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e19:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109e1c:	75 d0                	jne    c0109dee <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0109e1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109e23:	89 ec                	mov    %ebp,%esp
c0109e25:	5d                   	pop    %ebp
c0109e26:	c3                   	ret    

c0109e27 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109e27:	55                   	push   %ebp
c0109e28:	89 e5                	mov    %esp,%ebp
c0109e2a:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109e2d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109e34:	00 
c0109e35:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109e3c:	00 
c0109e3d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109e40:	89 04 24             	mov    %eax,(%esp)
c0109e43:	e8 a9 29 00 00       	call   c010c7f1 <memset>
    tf.tf_cs = KERNEL_CS;
c0109e48:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109e4e:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109e54:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109e58:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109e5c:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109e60:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109e64:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e67:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e6d:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109e70:	b8 53 96 10 c0       	mov    $0xc0109653,%eax
c0109e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109e78:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e7b:	0d 00 01 00 00       	or     $0x100,%eax
c0109e80:	89 c2                	mov    %eax,%edx
c0109e82:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109e85:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109e89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109e90:	00 
c0109e91:	89 14 24             	mov    %edx,(%esp)
c0109e94:	e8 44 03 00 00       	call   c010a1dd <do_fork>
}
c0109e99:	89 ec                	mov    %ebp,%esp
c0109e9b:	5d                   	pop    %ebp
c0109e9c:	c3                   	ret    

c0109e9d <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109e9d:	55                   	push   %ebp
c0109e9e:	89 e5                	mov    %esp,%ebp
c0109ea0:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109ea3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109eaa:	e8 c5 b3 ff ff       	call   c0105274 <alloc_pages>
c0109eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109eb6:	74 1a                	je     c0109ed2 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ebb:	89 04 24             	mov    %eax,(%esp)
c0109ebe:	e8 17 f9 ff ff       	call   c01097da <page2kva>
c0109ec3:	89 c2                	mov    %eax,%edx
c0109ec5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ec8:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109ecb:	b8 00 00 00 00       	mov    $0x0,%eax
c0109ed0:	eb 05                	jmp    c0109ed7 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109ed2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109ed7:	89 ec                	mov    %ebp,%esp
c0109ed9:	5d                   	pop    %ebp
c0109eda:	c3                   	ret    

c0109edb <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109edb:	55                   	push   %ebp
c0109edc:	89 e5                	mov    %esp,%ebp
c0109ede:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109ee1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee4:	8b 40 0c             	mov    0xc(%eax),%eax
c0109ee7:	89 04 24             	mov    %eax,(%esp)
c0109eea:	e8 41 f9 ff ff       	call   c0109830 <kva2page>
c0109eef:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109ef6:	00 
c0109ef7:	89 04 24             	mov    %eax,(%esp)
c0109efa:	e8 e2 b3 ff ff       	call   c01052e1 <free_pages>
}
c0109eff:	90                   	nop
c0109f00:	89 ec                	mov    %ebp,%esp
c0109f02:	5d                   	pop    %ebp
c0109f03:	c3                   	ret    

c0109f04 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109f04:	55                   	push   %ebp
c0109f05:	89 e5                	mov    %esp,%ebp
c0109f07:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109f0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109f11:	e8 5e b3 ff ff       	call   c0105274 <alloc_pages>
c0109f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f1d:	75 0a                	jne    c0109f29 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109f1f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109f24:	e9 80 00 00 00       	jmp    c0109fa9 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f2c:	89 04 24             	mov    %eax,(%esp)
c0109f2f:	e8 a6 f8 ff ff       	call   c01097da <page2kva>
c0109f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109f37:	a1 00 3a 13 c0       	mov    0xc0133a00,%eax
c0109f3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109f43:	00 
c0109f44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f4b:	89 04 24             	mov    %eax,(%esp)
c0109f4e:	e8 83 29 00 00       	call   c010c8d6 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f56:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109f59:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109f60:	77 23                	ja     c0109f85 <setup_pgdir+0x81>
c0109f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109f69:	c7 44 24 08 0c eb 10 	movl   $0xc010eb0c,0x8(%esp)
c0109f70:	c0 
c0109f71:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0109f78:	00 
c0109f79:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c0109f80:	e8 6b 6e ff ff       	call   c0100df0 <__panic>
c0109f85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f88:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f91:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109f96:	83 ca 03             	or     $0x3,%edx
c0109f99:	89 10                	mov    %edx,(%eax)
    mm->pgdir = pgdir;
c0109f9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109fa1:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109fa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109fa9:	89 ec                	mov    %ebp,%esp
c0109fab:	5d                   	pop    %ebp
c0109fac:	c3                   	ret    

c0109fad <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109fad:	55                   	push   %ebp
c0109fae:	89 e5                	mov    %esp,%ebp
c0109fb0:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109fb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fb6:	8b 40 0c             	mov    0xc(%eax),%eax
c0109fb9:	89 04 24             	mov    %eax,(%esp)
c0109fbc:	e8 6f f8 ff ff       	call   c0109830 <kva2page>
c0109fc1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109fc8:	00 
c0109fc9:	89 04 24             	mov    %eax,(%esp)
c0109fcc:	e8 10 b3 ff ff       	call   c01052e1 <free_pages>
}
c0109fd1:	90                   	nop
c0109fd2:	89 ec                	mov    %ebp,%esp
c0109fd4:	5d                   	pop    %ebp
c0109fd5:	c3                   	ret    

c0109fd6 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109fd6:	55                   	push   %ebp
c0109fd7:	89 e5                	mov    %esp,%ebp
c0109fd9:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109fdc:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c0109fe1:	8b 40 18             	mov    0x18(%eax),%eax
c0109fe4:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109fe7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109feb:	75 0a                	jne    c0109ff7 <copy_mm+0x21>
        return 0;
c0109fed:	b8 00 00 00 00       	mov    $0x0,%eax
c0109ff2:	e9 fc 00 00 00       	jmp    c010a0f3 <copy_mm+0x11d>
    }
    if (clone_flags & CLONE_VM) {
c0109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ffa:	25 00 01 00 00       	and    $0x100,%eax
c0109fff:	85 c0                	test   %eax,%eax
c010a001:	74 08                	je     c010a00b <copy_mm+0x35>
        mm = oldmm;
c010a003:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a006:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c010a009:	eb 5e                	jmp    c010a069 <copy_mm+0x93>
    }

    int ret = -E_NO_MEM;
c010a00b:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c010a012:	e8 e1 e1 ff ff       	call   c01081f8 <mm_create>
c010a017:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a01a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a01e:	0f 84 cb 00 00 00    	je     c010a0ef <copy_mm+0x119>
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
c010a024:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a027:	89 04 24             	mov    %eax,(%esp)
c010a02a:	e8 d5 fe ff ff       	call   c0109f04 <setup_pgdir>
c010a02f:	85 c0                	test   %eax,%eax
c010a031:	0f 85 aa 00 00 00    	jne    c010a0e1 <copy_mm+0x10b>
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c010a037:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a03a:	89 04 24             	mov    %eax,(%esp)
c010a03d:	e8 6e f8 ff ff       	call   c01098b0 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c010a042:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a045:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a049:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a04c:	89 04 24             	mov    %eax,(%esp)
c010a04f:	e8 ce e6 ff ff       	call   c0108722 <dup_mmap>
c010a054:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c010a057:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a05a:	89 04 24             	mov    %eax,(%esp)
c010a05d:	e8 6d f8 ff ff       	call   c01098cf <unlock_mm>

    if (ret != 0) {
c010a062:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a066:	75 60                	jne    c010a0c8 <copy_mm+0xf2>
        goto bad_dup_cleanup_mmap;
    }

good_mm:
c010a068:	90                   	nop
    mm_count_inc(mm);
c010a069:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a06c:	89 04 24             	mov    %eax,(%esp)
c010a06f:	e8 08 f8 ff ff       	call   c010987c <mm_count_inc>
    proc->mm = mm;
c010a074:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a077:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a07a:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c010a07d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a080:	8b 40 0c             	mov    0xc(%eax),%eax
c010a083:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a086:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c010a08d:	77 23                	ja     c010a0b2 <copy_mm+0xdc>
c010a08f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a092:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a096:	c7 44 24 08 0c eb 10 	movl   $0xc010eb0c,0x8(%esp)
c010a09d:	c0 
c010a09e:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c010a0a5:	00 
c010a0a6:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a0ad:	e8 3e 6d ff ff       	call   c0100df0 <__panic>
c010a0b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a0b5:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010a0bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0be:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c010a0c1:	b8 00 00 00 00       	mov    $0x0,%eax
c010a0c6:	eb 2b                	jmp    c010a0f3 <copy_mm+0x11d>
        goto bad_dup_cleanup_mmap;
c010a0c8:	90                   	nop
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c010a0c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0cc:	89 04 24             	mov    %eax,(%esp)
c010a0cf:	e8 4f e7 ff ff       	call   c0108823 <exit_mmap>
    put_pgdir(mm);
c010a0d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0d7:	89 04 24             	mov    %eax,(%esp)
c010a0da:	e8 ce fe ff ff       	call   c0109fad <put_pgdir>
c010a0df:	eb 01                	jmp    c010a0e2 <copy_mm+0x10c>
        goto bad_pgdir_cleanup_mm;
c010a0e1:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a0e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0e5:	89 04 24             	mov    %eax,(%esp)
c010a0e8:	e8 74 e4 ff ff       	call   c0108561 <mm_destroy>
c010a0ed:	eb 01                	jmp    c010a0f0 <copy_mm+0x11a>
        goto bad_mm;
c010a0ef:	90                   	nop
bad_mm:
    return ret;
c010a0f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010a0f3:	89 ec                	mov    %ebp,%esp
c010a0f5:	5d                   	pop    %ebp
c010a0f6:	c3                   	ret    

c010a0f7 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010a0f7:	55                   	push   %ebp
c010a0f8:	89 e5                	mov    %esp,%ebp
c010a0fa:	57                   	push   %edi
c010a0fb:	56                   	push   %esi
c010a0fc:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c010a0fd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a100:	8b 40 0c             	mov    0xc(%eax),%eax
c010a103:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010a108:	89 c2                	mov    %eax,%edx
c010a10a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a10d:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a110:	8b 45 08             	mov    0x8(%ebp),%eax
c010a113:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a116:	8b 55 10             	mov    0x10(%ebp),%edx
c010a119:	b9 4c 00 00 00       	mov    $0x4c,%ecx
c010a11e:	89 c3                	mov    %eax,%ebx
c010a120:	83 e3 01             	and    $0x1,%ebx
c010a123:	85 db                	test   %ebx,%ebx
c010a125:	74 0c                	je     c010a133 <copy_thread+0x3c>
c010a127:	0f b6 1a             	movzbl (%edx),%ebx
c010a12a:	88 18                	mov    %bl,(%eax)
c010a12c:	8d 40 01             	lea    0x1(%eax),%eax
c010a12f:	8d 52 01             	lea    0x1(%edx),%edx
c010a132:	49                   	dec    %ecx
c010a133:	89 c3                	mov    %eax,%ebx
c010a135:	83 e3 02             	and    $0x2,%ebx
c010a138:	85 db                	test   %ebx,%ebx
c010a13a:	74 0f                	je     c010a14b <copy_thread+0x54>
c010a13c:	0f b7 1a             	movzwl (%edx),%ebx
c010a13f:	66 89 18             	mov    %bx,(%eax)
c010a142:	8d 40 02             	lea    0x2(%eax),%eax
c010a145:	8d 52 02             	lea    0x2(%edx),%edx
c010a148:	83 e9 02             	sub    $0x2,%ecx
c010a14b:	89 cf                	mov    %ecx,%edi
c010a14d:	83 e7 fc             	and    $0xfffffffc,%edi
c010a150:	bb 00 00 00 00       	mov    $0x0,%ebx
c010a155:	8b 34 1a             	mov    (%edx,%ebx,1),%esi
c010a158:	89 34 18             	mov    %esi,(%eax,%ebx,1)
c010a15b:	83 c3 04             	add    $0x4,%ebx
c010a15e:	39 fb                	cmp    %edi,%ebx
c010a160:	72 f3                	jb     c010a155 <copy_thread+0x5e>
c010a162:	01 d8                	add    %ebx,%eax
c010a164:	01 da                	add    %ebx,%edx
c010a166:	bb 00 00 00 00       	mov    $0x0,%ebx
c010a16b:	89 ce                	mov    %ecx,%esi
c010a16d:	83 e6 02             	and    $0x2,%esi
c010a170:	85 f6                	test   %esi,%esi
c010a172:	74 0b                	je     c010a17f <copy_thread+0x88>
c010a174:	0f b7 34 1a          	movzwl (%edx,%ebx,1),%esi
c010a178:	66 89 34 18          	mov    %si,(%eax,%ebx,1)
c010a17c:	83 c3 02             	add    $0x2,%ebx
c010a17f:	83 e1 01             	and    $0x1,%ecx
c010a182:	85 c9                	test   %ecx,%ecx
c010a184:	74 07                	je     c010a18d <copy_thread+0x96>
c010a186:	0f b6 14 1a          	movzbl (%edx,%ebx,1),%edx
c010a18a:	88 14 18             	mov    %dl,(%eax,%ebx,1)
    proc->tf->tf_regs.reg_eax = 0;
c010a18d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a190:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a193:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010a19a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a19d:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a1a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a1a3:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010a1a6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a9:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a1ac:	8b 50 40             	mov    0x40(%eax),%edx
c010a1af:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1b2:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a1b5:	81 ca 00 02 00 00    	or     $0x200,%edx
c010a1bb:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010a1be:	ba dd 9c 10 c0       	mov    $0xc0109cdd,%edx
c010a1c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1c6:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010a1c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1cc:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a1cf:	89 c2                	mov    %eax,%edx
c010a1d1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1d4:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a1d7:	90                   	nop
c010a1d8:	5b                   	pop    %ebx
c010a1d9:	5e                   	pop    %esi
c010a1da:	5f                   	pop    %edi
c010a1db:	5d                   	pop    %ebp
c010a1dc:	c3                   	ret    

c010a1dd <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010a1dd:	55                   	push   %ebp
c010a1de:	89 e5                	mov    %esp,%ebp
c010a1e0:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c010a1e3:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010a1ea:	a1 40 a1 1b c0       	mov    0xc01ba140,%eax
c010a1ef:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a1f4:	0f 8f 1a 01 00 00    	jg     c010a314 <do_fork+0x137>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010a1fa:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    if ((proc = alloc_proc()) == NULL) {
c010a201:	e8 e8 f6 ff ff       	call   c01098ee <alloc_proc>
c010a206:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a20d:	75 11                	jne    c010a220 <do_fork+0x43>
        cprintf("alloc_proc() failed!");
c010a20f:	c7 04 24 44 eb 10 c0 	movl   $0xc010eb44,(%esp)
c010a216:	e8 57 61 ff ff       	call   c0100372 <cprintf>
        goto fork_out;
c010a21b:	e9 f5 00 00 00       	jmp    c010a315 <do_fork+0x138>
    }

    proc->parent = current;
c010a220:	8b 15 30 81 1b c0    	mov    0xc01b8130,%edx
c010a226:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a229:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0);
c010a22c:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a231:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a234:	85 c0                	test   %eax,%eax
c010a236:	74 24                	je     c010a25c <do_fork+0x7f>
c010a238:	c7 44 24 0c 59 eb 10 	movl   $0xc010eb59,0xc(%esp)
c010a23f:	c0 
c010a240:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a247:	c0 
c010a248:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
c010a24f:	00 
c010a250:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a257:	e8 94 6b ff ff       	call   c0100df0 <__panic>

    if ((ret = setup_kstack(proc)) != 0) {  //call the alloc_pages to alloc kstack space
c010a25c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a25f:	89 04 24             	mov    %eax,(%esp)
c010a262:	e8 36 fc ff ff       	call   c0109e9d <setup_kstack>
c010a267:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a26a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a26e:	74 11                	je     c010a281 <do_fork+0xa4>
        cprintf("set_kstack() failed!");
c010a270:	c7 04 24 87 eb 10 c0 	movl   $0xc010eb87,(%esp)
c010a277:	e8 f6 60 ff ff       	call   c0100372 <cprintf>
        goto bad_fork_cleanup_proc;
c010a27c:	e9 99 00 00 00       	jmp    c010a31a <do_fork+0x13d>
    }

    if (copy_mm(clone_flags, proc) != 0) {
c010a281:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a284:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a288:	8b 45 08             	mov    0x8(%ebp),%eax
c010a28b:	89 04 24             	mov    %eax,(%esp)
c010a28e:	e8 43 fd ff ff       	call   c0109fd6 <copy_mm>
c010a293:	85 c0                	test   %eax,%eax
c010a295:	74 1a                	je     c010a2b1 <do_fork+0xd4>
        cprintf("copy_mm() failed!");
c010a297:	c7 04 24 9c eb 10 c0 	movl   $0xc010eb9c,(%esp)
c010a29e:	e8 cf 60 ff ff       	call   c0100372 <cprintf>
        goto bad_fork_cleanup_kstack;
c010a2a3:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a2a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2a7:	89 04 24             	mov    %eax,(%esp)
c010a2aa:	e8 2c fc ff ff       	call   c0109edb <put_kstack>
c010a2af:	eb 69                	jmp    c010a31a <do_fork+0x13d>
    copy_thread(proc, stack, tf);
c010a2b1:	8b 45 10             	mov    0x10(%ebp),%eax
c010a2b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a2bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a2bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2c2:	89 04 24             	mov    %eax,(%esp)
c010a2c5:	e8 2d fe ff ff       	call   c010a0f7 <copy_thread>
    local_intr_save(intr_flag);
c010a2ca:	e8 d1 f3 ff ff       	call   c01096a0 <__intr_save>
c010a2cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        proc->pid = get_pid();
c010a2d2:	e8 96 f8 ff ff       	call   c0109b6d <get_pid>
c010a2d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a2da:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a2dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2e0:	89 04 24             	mov    %eax,(%esp)
c010a2e3:	e8 10 fa ff ff       	call   c0109cf8 <hash_proc>
        set_links(proc);
c010a2e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2eb:	89 04 24             	mov    %eax,(%esp)
c010a2ee:	e8 4b f7 ff ff       	call   c0109a3e <set_links>
    local_intr_restore(intr_flag);
c010a2f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2f6:	89 04 24             	mov    %eax,(%esp)
c010a2f9:	e8 ce f3 ff ff       	call   c01096cc <__intr_restore>
    wakeup_proc(proc);
c010a2fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a301:	89 04 24             	mov    %eax,(%esp)
c010a304:	e8 e5 16 00 00       	call   c010b9ee <wakeup_proc>
    ret = proc->pid;
c010a309:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a30c:	8b 40 04             	mov    0x4(%eax),%eax
c010a30f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a312:	eb 01                	jmp    c010a315 <do_fork+0x138>
        goto fork_out;
c010a314:	90                   	nop
    return ret;
c010a315:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a318:	eb 0d                	jmp    c010a327 <do_fork+0x14a>
bad_fork_cleanup_proc:
    kfree(proc);
c010a31a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a31d:	89 04 24             	mov    %eax,(%esp)
c010a320:	e8 db aa ff ff       	call   c0104e00 <kfree>
    goto fork_out;
c010a325:	eb ee                	jmp    c010a315 <do_fork+0x138>
}
c010a327:	89 ec                	mov    %ebp,%esp
c010a329:	5d                   	pop    %ebp
c010a32a:	c3                   	ret    

c010a32b <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a32b:	55                   	push   %ebp
c010a32c:	89 e5                	mov    %esp,%ebp
c010a32e:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a331:	8b 15 30 81 1b c0    	mov    0xc01b8130,%edx
c010a337:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010a33c:	39 c2                	cmp    %eax,%edx
c010a33e:	75 1c                	jne    c010a35c <do_exit+0x31>
        panic("idleproc exit.\n");
c010a340:	c7 44 24 08 ae eb 10 	movl   $0xc010ebae,0x8(%esp)
c010a347:	c0 
c010a348:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c010a34f:	00 
c010a350:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a357:	e8 94 6a ff ff       	call   c0100df0 <__panic>
    }
    if (current == initproc) {
c010a35c:	8b 15 30 81 1b c0    	mov    0xc01b8130,%edx
c010a362:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a367:	39 c2                	cmp    %eax,%edx
c010a369:	75 1c                	jne    c010a387 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a36b:	c7 44 24 08 be eb 10 	movl   $0xc010ebbe,0x8(%esp)
c010a372:	c0 
c010a373:	c7 44 24 04 dc 01 00 	movl   $0x1dc,0x4(%esp)
c010a37a:	00 
c010a37b:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a382:	e8 69 6a ff ff       	call   c0100df0 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a387:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a38c:	8b 40 18             	mov    0x18(%eax),%eax
c010a38f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a392:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a396:	74 4b                	je     c010a3e3 <do_exit+0xb8>
        lcr3(boot_cr3);
c010a398:	a1 a8 7f 1b c0       	mov    0xc01b7fa8,%eax
c010a39d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010a3a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a3a3:	0f 22 d8             	mov    %eax,%cr3
}
c010a3a6:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c010a3a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a3aa:	89 04 24             	mov    %eax,(%esp)
c010a3ad:	e8 e4 f4 ff ff       	call   c0109896 <mm_count_dec>
c010a3b2:	85 c0                	test   %eax,%eax
c010a3b4:	75 21                	jne    c010a3d7 <do_exit+0xac>
            exit_mmap(mm);
c010a3b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a3b9:	89 04 24             	mov    %eax,(%esp)
c010a3bc:	e8 62 e4 ff ff       	call   c0108823 <exit_mmap>
            put_pgdir(mm);
c010a3c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a3c4:	89 04 24             	mov    %eax,(%esp)
c010a3c7:	e8 e1 fb ff ff       	call   c0109fad <put_pgdir>
            mm_destroy(mm);
c010a3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a3cf:	89 04 24             	mov    %eax,(%esp)
c010a3d2:	e8 8a e1 ff ff       	call   c0108561 <mm_destroy>
        }
        current->mm = NULL;
c010a3d7:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a3dc:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a3e3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a3e8:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a3ee:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a3f3:	8b 55 08             	mov    0x8(%ebp),%edx
c010a3f6:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a3f9:	e8 a2 f2 ff ff       	call   c01096a0 <__intr_save>
c010a3fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a401:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a406:	8b 40 14             	mov    0x14(%eax),%eax
c010a409:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a40c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a40f:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a412:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a417:	0f 85 96 00 00 00    	jne    c010a4b3 <do_exit+0x188>
            wakeup_proc(proc);
c010a41d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a420:	89 04 24             	mov    %eax,(%esp)
c010a423:	e8 c6 15 00 00       	call   c010b9ee <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a428:	e9 86 00 00 00       	jmp    c010a4b3 <do_exit+0x188>
            proc = current->cptr;
c010a42d:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a432:	8b 40 70             	mov    0x70(%eax),%eax
c010a435:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a438:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a43d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a440:	8b 52 78             	mov    0x78(%edx),%edx
c010a443:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a446:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a449:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a450:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a455:	8b 50 70             	mov    0x70(%eax),%edx
c010a458:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a45b:	89 50 78             	mov    %edx,0x78(%eax)
c010a45e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a461:	8b 40 78             	mov    0x78(%eax),%eax
c010a464:	85 c0                	test   %eax,%eax
c010a466:	74 0e                	je     c010a476 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a468:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a46d:	8b 40 70             	mov    0x70(%eax),%eax
c010a470:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a473:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a476:	8b 15 2c 81 1b c0    	mov    0xc01b812c,%edx
c010a47c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a47f:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a482:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a487:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a48a:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a48d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a490:	8b 00                	mov    (%eax),%eax
c010a492:	83 f8 03             	cmp    $0x3,%eax
c010a495:	75 1c                	jne    c010a4b3 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a497:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a49c:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a49f:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a4a4:	75 0d                	jne    c010a4b3 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a4a6:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010a4ab:	89 04 24             	mov    %eax,(%esp)
c010a4ae:	e8 3b 15 00 00       	call   c010b9ee <wakeup_proc>
        while (current->cptr != NULL) {
c010a4b3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a4b8:	8b 40 70             	mov    0x70(%eax),%eax
c010a4bb:	85 c0                	test   %eax,%eax
c010a4bd:	0f 85 6a ff ff ff    	jne    c010a42d <do_exit+0x102>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a4c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a4c6:	89 04 24             	mov    %eax,(%esp)
c010a4c9:	e8 fe f1 ff ff       	call   c01096cc <__intr_restore>
    
    schedule();
c010a4ce:	e8 b7 15 00 00       	call   c010ba8a <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a4d3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a4d8:	8b 40 04             	mov    0x4(%eax),%eax
c010a4db:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a4df:	c7 44 24 08 d0 eb 10 	movl   $0xc010ebd0,0x8(%esp)
c010a4e6:	c0 
c010a4e7:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c010a4ee:	00 
c010a4ef:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a4f6:	e8 f5 68 ff ff       	call   c0100df0 <__panic>

c010a4fb <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a4fb:	55                   	push   %ebp
c010a4fc:	89 e5                	mov    %esp,%ebp
c010a4fe:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a501:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010a506:	8b 40 18             	mov    0x18(%eax),%eax
c010a509:	85 c0                	test   %eax,%eax
c010a50b:	74 1c                	je     c010a529 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a50d:	c7 44 24 08 f0 eb 10 	movl   $0xc010ebf0,0x8(%esp)
c010a514:	c0 
c010a515:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c010a51c:	00 
c010a51d:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a524:	e8 c7 68 ff ff       	call   c0100df0 <__panic>
    }

    int ret = -E_NO_MEM;
c010a529:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a530:	e8 c3 dc ff ff       	call   c01081f8 <mm_create>
c010a535:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a538:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a53c:	0f 84 1c 06 00 00    	je     c010ab5e <load_icode+0x663>
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a542:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a545:	89 04 24             	mov    %eax,(%esp)
c010a548:	e8 b7 f9 ff ff       	call   c0109f04 <setup_pgdir>
c010a54d:	85 c0                	test   %eax,%eax
c010a54f:	0f 85 fb 05 00 00    	jne    c010ab50 <load_icode+0x655>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a555:	8b 45 08             	mov    0x8(%ebp),%eax
c010a558:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a55b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a55e:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a561:	8b 45 08             	mov    0x8(%ebp),%eax
c010a564:	01 d0                	add    %edx,%eax
c010a566:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a569:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a56c:	8b 00                	mov    (%eax),%eax
c010a56e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a573:	74 0c                	je     c010a581 <load_icode+0x86>
        ret = -E_INVAL_ELF;
c010a575:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a57c:	e9 c2 05 00 00       	jmp    c010ab43 <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a581:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a584:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a588:	c1 e0 05             	shl    $0x5,%eax
c010a58b:	89 c2                	mov    %eax,%edx
c010a58d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a590:	01 d0                	add    %edx,%eax
c010a592:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a595:	e9 01 03 00 00       	jmp    c010a89b <load_icode+0x3a0>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a59a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a59d:	8b 00                	mov    (%eax),%eax
c010a59f:	83 f8 01             	cmp    $0x1,%eax
c010a5a2:	0f 85 e8 02 00 00    	jne    c010a890 <load_icode+0x395>
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a5a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5ab:	8b 50 10             	mov    0x10(%eax),%edx
c010a5ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5b1:	8b 40 14             	mov    0x14(%eax),%eax
c010a5b4:	39 c2                	cmp    %eax,%edx
c010a5b6:	76 0c                	jbe    c010a5c4 <load_icode+0xc9>
            ret = -E_INVAL_ELF;
c010a5b8:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a5bf:	e9 74 05 00 00       	jmp    c010ab38 <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a5c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5c7:	8b 40 10             	mov    0x10(%eax),%eax
c010a5ca:	85 c0                	test   %eax,%eax
c010a5cc:	0f 84 c1 02 00 00    	je     c010a893 <load_icode+0x398>
            continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a5d2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a5d9:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a5e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5e3:	8b 40 18             	mov    0x18(%eax),%eax
c010a5e6:	83 e0 01             	and    $0x1,%eax
c010a5e9:	85 c0                	test   %eax,%eax
c010a5eb:	74 04                	je     c010a5f1 <load_icode+0xf6>
c010a5ed:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a5f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5f4:	8b 40 18             	mov    0x18(%eax),%eax
c010a5f7:	83 e0 02             	and    $0x2,%eax
c010a5fa:	85 c0                	test   %eax,%eax
c010a5fc:	74 04                	je     c010a602 <load_icode+0x107>
c010a5fe:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a602:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a605:	8b 40 18             	mov    0x18(%eax),%eax
c010a608:	83 e0 04             	and    $0x4,%eax
c010a60b:	85 c0                	test   %eax,%eax
c010a60d:	74 04                	je     c010a613 <load_icode+0x118>
c010a60f:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a613:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a616:	83 e0 02             	and    $0x2,%eax
c010a619:	85 c0                	test   %eax,%eax
c010a61b:	74 04                	je     c010a621 <load_icode+0x126>
c010a61d:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a621:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a624:	8b 50 14             	mov    0x14(%eax),%edx
c010a627:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a62a:	8b 40 08             	mov    0x8(%eax),%eax
c010a62d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a634:	00 
c010a635:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a638:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a63c:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a640:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a644:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a647:	89 04 24             	mov    %eax,(%esp)
c010a64a:	e8 b9 df ff ff       	call   c0108608 <mm_map>
c010a64f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a652:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a656:	0f 85 d2 04 00 00    	jne    c010ab2e <load_icode+0x633>
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c010a65c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a65f:	8b 50 04             	mov    0x4(%eax),%edx
c010a662:	8b 45 08             	mov    0x8(%ebp),%eax
c010a665:	01 d0                	add    %edx,%eax
c010a667:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a66a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a66d:	8b 40 08             	mov    0x8(%eax),%eax
c010a670:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a673:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a676:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010a679:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a67c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a681:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a684:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a68b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a68e:	8b 50 08             	mov    0x8(%eax),%edx
c010a691:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a694:	8b 40 10             	mov    0x10(%eax),%eax
c010a697:	01 d0                	add    %edx,%eax
c010a699:	89 45 b4             	mov    %eax,-0x4c(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a69c:	e9 87 00 00 00       	jmp    c010a728 <load_icode+0x22d>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a6a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6a4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a6aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a6ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a6b1:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a6b5:	89 04 24             	mov    %eax,(%esp)
c010a6b8:	e8 bc ba ff ff       	call   c0106179 <pgdir_alloc_page>
c010a6bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a6c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a6c4:	0f 84 67 04 00 00    	je     c010ab31 <load_icode+0x636>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a6ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6cd:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a6d0:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a6d3:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a6d8:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a6db:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a6de:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a6e5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6e8:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a6eb:	73 09                	jae    c010a6f6 <load_icode+0x1fb>
                size -= la - end;
c010a6ed:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6f0:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a6f3:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a6f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6f9:	89 04 24             	mov    %eax,(%esp)
c010a6fc:	e8 d9 f0 ff ff       	call   c01097da <page2kva>
c010a701:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a704:	01 c2                	add    %eax,%edx
c010a706:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a709:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a70d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a710:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a714:	89 14 24             	mov    %edx,(%esp)
c010a717:	e8 ba 21 00 00       	call   c010c8d6 <memcpy>
            start += size, from += size;
c010a71c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a71f:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a722:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a725:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c010a728:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a72b:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a72e:	0f 82 6d ff ff ff    	jb     c010a6a1 <load_icode+0x1a6>
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a734:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a737:	8b 50 08             	mov    0x8(%eax),%edx
c010a73a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a73d:	8b 40 14             	mov    0x14(%eax),%eax
c010a740:	01 d0                	add    %edx,%eax
c010a742:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        if (start < la) {
c010a745:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a748:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a74b:	0f 83 31 01 00 00    	jae    c010a882 <load_icode+0x387>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a751:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a754:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a757:	0f 84 39 01 00 00    	je     c010a896 <load_icode+0x39b>
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a75d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a760:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a763:	05 00 10 00 00       	add    $0x1000,%eax
c010a768:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a76b:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a770:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a773:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a776:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a779:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a77c:	73 09                	jae    c010a787 <load_icode+0x28c>
                size -= la - end;
c010a77e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a781:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a784:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a787:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a78a:	89 04 24             	mov    %eax,(%esp)
c010a78d:	e8 48 f0 ff ff       	call   c01097da <page2kva>
c010a792:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a795:	01 c2                	add    %eax,%edx
c010a797:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a79a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a79e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a7a5:	00 
c010a7a6:	89 14 24             	mov    %edx,(%esp)
c010a7a9:	e8 43 20 00 00       	call   c010c7f1 <memset>
            start += size;
c010a7ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a7b1:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a7b4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a7b7:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a7ba:	73 0c                	jae    c010a7c8 <load_icode+0x2cd>
c010a7bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a7bf:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a7c2:	0f 84 ba 00 00 00    	je     c010a882 <load_icode+0x387>
c010a7c8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a7cb:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a7ce:	72 0c                	jb     c010a7dc <load_icode+0x2e1>
c010a7d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a7d3:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a7d6:	0f 84 a6 00 00 00    	je     c010a882 <load_icode+0x387>
c010a7dc:	c7 44 24 0c 18 ec 10 	movl   $0xc010ec18,0xc(%esp)
c010a7e3:	c0 
c010a7e4:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a7eb:	c0 
c010a7ec:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
c010a7f3:	00 
c010a7f4:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a7fb:	e8 f0 65 ff ff       	call   c0100df0 <__panic>
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a800:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a803:	8b 40 0c             	mov    0xc(%eax),%eax
c010a806:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a809:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a80d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a810:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a814:	89 04 24             	mov    %eax,(%esp)
c010a817:	e8 5d b9 ff ff       	call   c0106179 <pgdir_alloc_page>
c010a81c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a81f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a823:	0f 84 0b 03 00 00    	je     c010ab34 <load_icode+0x639>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a829:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a82c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a82f:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a832:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a837:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a83a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a83d:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a844:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a847:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a84a:	73 09                	jae    c010a855 <load_icode+0x35a>
                size -= la - end;
c010a84c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a84f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a852:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a855:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a858:	89 04 24             	mov    %eax,(%esp)
c010a85b:	e8 7a ef ff ff       	call   c01097da <page2kva>
c010a860:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a863:	01 c2                	add    %eax,%edx
c010a865:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a868:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a86c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a873:	00 
c010a874:	89 14 24             	mov    %edx,(%esp)
c010a877:	e8 75 1f 00 00       	call   c010c7f1 <memset>
            start += size;
c010a87c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a87f:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c010a882:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a885:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a888:	0f 82 72 ff ff ff    	jb     c010a800 <load_icode+0x305>
c010a88e:	eb 07                	jmp    c010a897 <load_icode+0x39c>
            continue ;
c010a890:	90                   	nop
c010a891:	eb 04                	jmp    c010a897 <load_icode+0x39c>
            continue ;
c010a893:	90                   	nop
c010a894:	eb 01                	jmp    c010a897 <load_icode+0x39c>
                continue ;
c010a896:	90                   	nop
    for (; ph < ph_end; ph ++) {
c010a897:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a89b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a89e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a8a1:	0f 82 f3 fc ff ff    	jb     c010a59a <load_icode+0x9f>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a8a7:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a8ae:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a8b5:	00 
c010a8b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a8b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a8bd:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a8c4:	00 
c010a8c5:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a8cc:	af 
c010a8cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8d0:	89 04 24             	mov    %eax,(%esp)
c010a8d3:	e8 30 dd ff ff       	call   c0108608 <mm_map>
c010a8d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a8db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a8df:	0f 85 52 02 00 00    	jne    c010ab37 <load_icode+0x63c>
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a8e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8e8:	8b 40 0c             	mov    0xc(%eax),%eax
c010a8eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a8f2:	00 
c010a8f3:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a8fa:	af 
c010a8fb:	89 04 24             	mov    %eax,(%esp)
c010a8fe:	e8 76 b8 ff ff       	call   c0106179 <pgdir_alloc_page>
c010a903:	85 c0                	test   %eax,%eax
c010a905:	75 24                	jne    c010a92b <load_icode+0x430>
c010a907:	c7 44 24 0c 54 ec 10 	movl   $0xc010ec54,0xc(%esp)
c010a90e:	c0 
c010a90f:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a916:	c0 
c010a917:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c010a91e:	00 
c010a91f:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a926:	e8 c5 64 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a92b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a92e:	8b 40 0c             	mov    0xc(%eax),%eax
c010a931:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a938:	00 
c010a939:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a940:	af 
c010a941:	89 04 24             	mov    %eax,(%esp)
c010a944:	e8 30 b8 ff ff       	call   c0106179 <pgdir_alloc_page>
c010a949:	85 c0                	test   %eax,%eax
c010a94b:	75 24                	jne    c010a971 <load_icode+0x476>
c010a94d:	c7 44 24 0c 98 ec 10 	movl   $0xc010ec98,0xc(%esp)
c010a954:	c0 
c010a955:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a95c:	c0 
c010a95d:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c010a964:	00 
c010a965:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a96c:	e8 7f 64 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a971:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a974:	8b 40 0c             	mov    0xc(%eax),%eax
c010a977:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a97e:	00 
c010a97f:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a986:	af 
c010a987:	89 04 24             	mov    %eax,(%esp)
c010a98a:	e8 ea b7 ff ff       	call   c0106179 <pgdir_alloc_page>
c010a98f:	85 c0                	test   %eax,%eax
c010a991:	75 24                	jne    c010a9b7 <load_icode+0x4bc>
c010a993:	c7 44 24 0c dc ec 10 	movl   $0xc010ecdc,0xc(%esp)
c010a99a:	c0 
c010a99b:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a9a2:	c0 
c010a9a3:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c010a9aa:	00 
c010a9ab:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a9b2:	e8 39 64 ff ff       	call   c0100df0 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a9b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a9ba:	8b 40 0c             	mov    0xc(%eax),%eax
c010a9bd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a9c4:	00 
c010a9c5:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a9cc:	af 
c010a9cd:	89 04 24             	mov    %eax,(%esp)
c010a9d0:	e8 a4 b7 ff ff       	call   c0106179 <pgdir_alloc_page>
c010a9d5:	85 c0                	test   %eax,%eax
c010a9d7:	75 24                	jne    c010a9fd <load_icode+0x502>
c010a9d9:	c7 44 24 0c 20 ed 10 	movl   $0xc010ed20,0xc(%esp)
c010a9e0:	c0 
c010a9e1:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010a9e8:	c0 
c010a9e9:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c010a9f0:	00 
c010a9f1:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010a9f8:	e8 f3 63 ff ff       	call   c0100df0 <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a9fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aa00:	89 04 24             	mov    %eax,(%esp)
c010aa03:	e8 74 ee ff ff       	call   c010987c <mm_count_inc>
    current->mm = mm;
c010aa08:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010aa0d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010aa10:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010aa13:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aa16:	8b 40 0c             	mov    0xc(%eax),%eax
c010aa19:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010aa1c:	81 7d c4 ff ff ff bf 	cmpl   $0xbfffffff,-0x3c(%ebp)
c010aa23:	77 23                	ja     c010aa48 <load_icode+0x54d>
c010aa25:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010aa28:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010aa2c:	c7 44 24 08 0c eb 10 	movl   $0xc010eb0c,0x8(%esp)
c010aa33:	c0 
c010aa34:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c010aa3b:	00 
c010aa3c:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010aa43:	e8 a8 63 ff ff       	call   c0100df0 <__panic>
c010aa48:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010aa4b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010aa51:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010aa56:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010aa59:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aa5c:	8b 40 0c             	mov    0xc(%eax),%eax
c010aa5f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010aa62:	81 7d c0 ff ff ff bf 	cmpl   $0xbfffffff,-0x40(%ebp)
c010aa69:	77 23                	ja     c010aa8e <load_icode+0x593>
c010aa6b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010aa6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010aa72:	c7 44 24 08 0c eb 10 	movl   $0xc010eb0c,0x8(%esp)
c010aa79:	c0 
c010aa7a:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c010aa81:	00 
c010aa82:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010aa89:	e8 62 63 ff ff       	call   c0100df0 <__panic>
c010aa8e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010aa91:	05 00 00 00 40       	add    $0x40000000,%eax
c010aa96:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010aa99:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010aa9c:	0f 22 d8             	mov    %eax,%cr3
}
c010aa9f:	90                   	nop

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010aaa0:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010aaa5:	8b 40 3c             	mov    0x3c(%eax),%eax
c010aaa8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010aaab:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010aab2:	00 
c010aab3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010aaba:	00 
c010aabb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aabe:	89 04 24             	mov    %eax,(%esp)
c010aac1:	e8 2b 1d 00 00       	call   c010c7f1 <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010aac6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aac9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = tf->tf_fs = USER_DS;
c010aacf:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aad2:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
c010aad8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aadb:	0f b7 50 24          	movzwl 0x24(%eax),%edx
c010aadf:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aae2:	66 89 50 48          	mov    %dx,0x48(%eax)
c010aae6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aae9:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010aaed:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aaf0:	66 89 50 28          	mov    %dx,0x28(%eax)
c010aaf4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aaf7:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010aafb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010aafe:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010ab02:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010ab05:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010ab0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010ab0f:	8b 50 18             	mov    0x18(%eax),%edx
c010ab12:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010ab15:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010ab18:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010ab1b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010ab22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010ab29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab2c:	eb 33                	jmp    c010ab61 <load_icode+0x666>
            goto bad_cleanup_mmap;
c010ab2e:	90                   	nop
c010ab2f:	eb 07                	jmp    c010ab38 <load_icode+0x63d>
                goto bad_cleanup_mmap;
c010ab31:	90                   	nop
c010ab32:	eb 04                	jmp    c010ab38 <load_icode+0x63d>
                goto bad_cleanup_mmap;
c010ab34:	90                   	nop
c010ab35:	eb 01                	jmp    c010ab38 <load_icode+0x63d>
        goto bad_cleanup_mmap;
c010ab37:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
c010ab38:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010ab3b:	89 04 24             	mov    %eax,(%esp)
c010ab3e:	e8 e0 dc ff ff       	call   c0108823 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010ab43:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010ab46:	89 04 24             	mov    %eax,(%esp)
c010ab49:	e8 5f f4 ff ff       	call   c0109fad <put_pgdir>
c010ab4e:	eb 01                	jmp    c010ab51 <load_icode+0x656>
        goto bad_pgdir_cleanup_mm;
c010ab50:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010ab51:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010ab54:	89 04 24             	mov    %eax,(%esp)
c010ab57:	e8 05 da ff ff       	call   c0108561 <mm_destroy>
bad_mm:
    goto out;
c010ab5c:	eb cb                	jmp    c010ab29 <load_icode+0x62e>
        goto bad_mm;
c010ab5e:	90                   	nop
    goto out;
c010ab5f:	eb c8                	jmp    c010ab29 <load_icode+0x62e>
}
c010ab61:	89 ec                	mov    %ebp,%esp
c010ab63:	5d                   	pop    %ebp
c010ab64:	c3                   	ret    

c010ab65 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010ab65:	55                   	push   %ebp
c010ab66:	89 e5                	mov    %esp,%ebp
c010ab68:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010ab6b:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ab70:	8b 40 18             	mov    0x18(%eax),%eax
c010ab73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010ab76:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010ab80:	00 
c010ab81:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ab84:	89 54 24 08          	mov    %edx,0x8(%esp)
c010ab88:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab8f:	89 04 24             	mov    %eax,(%esp)
c010ab92:	e8 e3 e7 ff ff       	call   c010937a <user_mem_check>
c010ab97:	85 c0                	test   %eax,%eax
c010ab99:	75 0a                	jne    c010aba5 <do_execve+0x40>
        return -E_INVAL;
c010ab9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aba0:	e9 f7 00 00 00       	jmp    c010ac9c <do_execve+0x137>
    }
    if (len > PROC_NAME_LEN) {
c010aba5:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010aba9:	76 07                	jbe    c010abb2 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010abab:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010abb2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010abb9:	00 
c010abba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010abc1:	00 
c010abc2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010abc5:	89 04 24             	mov    %eax,(%esp)
c010abc8:	e8 24 1c 00 00       	call   c010c7f1 <memset>
    memcpy(local_name, name, len);
c010abcd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abd0:	89 44 24 08          	mov    %eax,0x8(%esp)
c010abd4:	8b 45 08             	mov    0x8(%ebp),%eax
c010abd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abdb:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010abde:	89 04 24             	mov    %eax,(%esp)
c010abe1:	e8 f0 1c 00 00       	call   c010c8d6 <memcpy>

    if (mm != NULL) {
c010abe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010abea:	74 4b                	je     c010ac37 <do_execve+0xd2>
        lcr3(boot_cr3);
c010abec:	a1 a8 7f 1b c0       	mov    0xc01b7fa8,%eax
c010abf1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010abf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010abf7:	0f 22 d8             	mov    %eax,%cr3
}
c010abfa:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c010abfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abfe:	89 04 24             	mov    %eax,(%esp)
c010ac01:	e8 90 ec ff ff       	call   c0109896 <mm_count_dec>
c010ac06:	85 c0                	test   %eax,%eax
c010ac08:	75 21                	jne    c010ac2b <do_execve+0xc6>
            exit_mmap(mm);
c010ac0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac0d:	89 04 24             	mov    %eax,(%esp)
c010ac10:	e8 0e dc ff ff       	call   c0108823 <exit_mmap>
            put_pgdir(mm);
c010ac15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac18:	89 04 24             	mov    %eax,(%esp)
c010ac1b:	e8 8d f3 ff ff       	call   c0109fad <put_pgdir>
            mm_destroy(mm);
c010ac20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac23:	89 04 24             	mov    %eax,(%esp)
c010ac26:	e8 36 d9 ff ff       	call   c0108561 <mm_destroy>
        }
        current->mm = NULL;
c010ac2b:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ac30:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010ac37:	8b 45 14             	mov    0x14(%ebp),%eax
c010ac3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac3e:	8b 45 10             	mov    0x10(%ebp),%eax
c010ac41:	89 04 24             	mov    %eax,(%esp)
c010ac44:	e8 b2 f8 ff ff       	call   c010a4fb <load_icode>
c010ac49:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ac4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ac50:	75 1b                	jne    c010ac6d <do_execve+0x108>
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010ac52:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ac57:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010ac5a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010ac5e:	89 04 24             	mov    %eax,(%esp)
c010ac61:	e8 4f ed ff ff       	call   c01099b5 <set_proc_name>
    return 0;
c010ac66:	b8 00 00 00 00       	mov    $0x0,%eax
c010ac6b:	eb 2f                	jmp    c010ac9c <do_execve+0x137>
        goto execve_exit;
c010ac6d:	90                   	nop

execve_exit:
    do_exit(ret);
c010ac6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac71:	89 04 24             	mov    %eax,(%esp)
c010ac74:	e8 b2 f6 ff ff       	call   c010a32b <do_exit>
    panic("already exit: %e.\n", ret);
c010ac79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ac80:	c7 44 24 08 63 ed 10 	movl   $0xc010ed63,0x8(%esp)
c010ac87:	c0 
c010ac88:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
c010ac8f:	00 
c010ac90:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010ac97:	e8 54 61 ff ff       	call   c0100df0 <__panic>
}
c010ac9c:	89 ec                	mov    %ebp,%esp
c010ac9e:	5d                   	pop    %ebp
c010ac9f:	c3                   	ret    

c010aca0 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010aca0:	55                   	push   %ebp
c010aca1:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010aca3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010aca8:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010acaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010acb4:	5d                   	pop    %ebp
c010acb5:	c3                   	ret    

c010acb6 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010acb6:	55                   	push   %ebp
c010acb7:	89 e5                	mov    %esp,%ebp
c010acb9:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010acbc:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010acc1:	8b 40 18             	mov    0x18(%eax),%eax
c010acc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010acc7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010accb:	74 30                	je     c010acfd <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010accd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010acd0:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010acd7:	00 
c010acd8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010acdf:	00 
c010ace0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ace4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ace7:	89 04 24             	mov    %eax,(%esp)
c010acea:	e8 8b e6 ff ff       	call   c010937a <user_mem_check>
c010acef:	85 c0                	test   %eax,%eax
c010acf1:	75 0a                	jne    c010acfd <do_wait+0x47>
            return -E_INVAL;
c010acf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010acf8:	e9 47 01 00 00       	jmp    c010ae44 <do_wait+0x18e>
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
c010acfd:	90                   	nop
    haskid = 0;
c010acfe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010ad05:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010ad09:	74 36                	je     c010ad41 <do_wait+0x8b>
        proc = find_proc(pid);
c010ad0b:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad0e:	89 04 24             	mov    %eax,(%esp)
c010ad11:	e8 9d f0 ff ff       	call   c0109db3 <find_proc>
c010ad16:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010ad19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ad1d:	74 4f                	je     c010ad6e <do_wait+0xb8>
c010ad1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad22:	8b 50 14             	mov    0x14(%eax),%edx
c010ad25:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ad2a:	39 c2                	cmp    %eax,%edx
c010ad2c:	75 40                	jne    c010ad6e <do_wait+0xb8>
            haskid = 1;
c010ad2e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010ad35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad38:	8b 00                	mov    (%eax),%eax
c010ad3a:	83 f8 03             	cmp    $0x3,%eax
c010ad3d:	75 2f                	jne    c010ad6e <do_wait+0xb8>
                goto found;
c010ad3f:	eb 7e                	jmp    c010adbf <do_wait+0x109>
            }
        }
    }
    else {
        proc = current->cptr;
c010ad41:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ad46:	8b 40 70             	mov    0x70(%eax),%eax
c010ad49:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010ad4c:	eb 1a                	jmp    c010ad68 <do_wait+0xb2>
            haskid = 1;
c010ad4e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010ad55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad58:	8b 00                	mov    (%eax),%eax
c010ad5a:	83 f8 03             	cmp    $0x3,%eax
c010ad5d:	74 5f                	je     c010adbe <do_wait+0x108>
        for (; proc != NULL; proc = proc->optr) {
c010ad5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad62:	8b 40 78             	mov    0x78(%eax),%eax
c010ad65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ad68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ad6c:	75 e0                	jne    c010ad4e <do_wait+0x98>
                goto found;
            }
        }
    }
    if (haskid) {
c010ad6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ad72:	74 40                	je     c010adb4 <do_wait+0xfe>
        current->state = PROC_SLEEPING;
c010ad74:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ad79:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010ad7f:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ad84:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010ad8b:	e8 fa 0c 00 00       	call   c010ba8a <schedule>
        if (current->flags & PF_EXITING) {
c010ad90:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ad95:	8b 40 44             	mov    0x44(%eax),%eax
c010ad98:	83 e0 01             	and    $0x1,%eax
c010ad9b:	85 c0                	test   %eax,%eax
c010ad9d:	0f 84 5b ff ff ff    	je     c010acfe <do_wait+0x48>
            do_exit(-E_KILLED);
c010ada3:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010adaa:	e8 7c f5 ff ff       	call   c010a32b <do_exit>
        }
        goto repeat;
c010adaf:	e9 4a ff ff ff       	jmp    c010acfe <do_wait+0x48>
    }
    return -E_BAD_PROC;
c010adb4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010adb9:	e9 86 00 00 00       	jmp    c010ae44 <do_wait+0x18e>
                goto found;
c010adbe:	90                   	nop

found:
    if (proc == idleproc || proc == initproc) {
c010adbf:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010adc4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010adc7:	74 0a                	je     c010add3 <do_wait+0x11d>
c010adc9:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010adce:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010add1:	75 1c                	jne    c010adef <do_wait+0x139>
        panic("wait idleproc or initproc.\n");
c010add3:	c7 44 24 08 76 ed 10 	movl   $0xc010ed76,0x8(%esp)
c010adda:	c0 
c010addb:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
c010ade2:	00 
c010ade3:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010adea:	e8 01 60 ff ff       	call   c0100df0 <__panic>
    }
    if (code_store != NULL) {
c010adef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010adf3:	74 0b                	je     c010ae00 <do_wait+0x14a>
        *code_store = proc->exit_code;
c010adf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010adf8:	8b 50 68             	mov    0x68(%eax),%edx
c010adfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010adfe:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010ae00:	e8 9b e8 ff ff       	call   c01096a0 <__intr_save>
c010ae05:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010ae08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae0b:	89 04 24             	mov    %eax,(%esp)
c010ae0e:	e8 68 ef ff ff       	call   c0109d7b <unhash_proc>
        remove_links(proc);
c010ae13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae16:	89 04 24             	mov    %eax,(%esp)
c010ae19:	e8 c9 ec ff ff       	call   c0109ae7 <remove_links>
    }
    local_intr_restore(intr_flag);
c010ae1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae21:	89 04 24             	mov    %eax,(%esp)
c010ae24:	e8 a3 e8 ff ff       	call   c01096cc <__intr_restore>
    put_kstack(proc);
c010ae29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae2c:	89 04 24             	mov    %eax,(%esp)
c010ae2f:	e8 a7 f0 ff ff       	call   c0109edb <put_kstack>
    kfree(proc);
c010ae34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae37:	89 04 24             	mov    %eax,(%esp)
c010ae3a:	e8 c1 9f ff ff       	call   c0104e00 <kfree>
    return 0;
c010ae3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ae44:	89 ec                	mov    %ebp,%esp
c010ae46:	5d                   	pop    %ebp
c010ae47:	c3                   	ret    

c010ae48 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010ae48:	55                   	push   %ebp
c010ae49:	89 e5                	mov    %esp,%ebp
c010ae4b:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010ae4e:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae51:	89 04 24             	mov    %eax,(%esp)
c010ae54:	e8 5a ef ff ff       	call   c0109db3 <find_proc>
c010ae59:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ae5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ae60:	74 41                	je     c010aea3 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010ae62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae65:	8b 40 44             	mov    0x44(%eax),%eax
c010ae68:	83 e0 01             	and    $0x1,%eax
c010ae6b:	85 c0                	test   %eax,%eax
c010ae6d:	75 2d                	jne    c010ae9c <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010ae6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae72:	8b 40 44             	mov    0x44(%eax),%eax
c010ae75:	83 c8 01             	or     $0x1,%eax
c010ae78:	89 c2                	mov    %eax,%edx
c010ae7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae7d:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ae80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae83:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ae86:	85 c0                	test   %eax,%eax
c010ae88:	79 0b                	jns    c010ae95 <do_kill+0x4d>
                wakeup_proc(proc);
c010ae8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae8d:	89 04 24             	mov    %eax,(%esp)
c010ae90:	e8 59 0b 00 00       	call   c010b9ee <wakeup_proc>
            }
            return 0;
c010ae95:	b8 00 00 00 00       	mov    $0x0,%eax
c010ae9a:	eb 0c                	jmp    c010aea8 <do_kill+0x60>
        }
        return -E_KILLED;
c010ae9c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010aea1:	eb 05                	jmp    c010aea8 <do_kill+0x60>
    }
    return -E_INVAL;
c010aea3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aea8:	89 ec                	mov    %ebp,%esp
c010aeaa:	5d                   	pop    %ebp
c010aeab:	c3                   	ret    

c010aeac <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aeac:	55                   	push   %ebp
c010aead:	89 e5                	mov    %esp,%ebp
c010aeaf:	57                   	push   %edi
c010aeb0:	56                   	push   %esi
c010aeb1:	53                   	push   %ebx
c010aeb2:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010aeb5:	8b 45 08             	mov    0x8(%ebp),%eax
c010aeb8:	89 04 24             	mov    %eax,(%esp)
c010aebb:	e8 07 16 00 00       	call   c010c4c7 <strlen>
c010aec0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aec3:	b8 04 00 00 00       	mov    $0x4,%eax
c010aec8:	8b 55 08             	mov    0x8(%ebp),%edx
c010aecb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010aece:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010aed1:	8b 75 10             	mov    0x10(%ebp),%esi
c010aed4:	89 f7                	mov    %esi,%edi
c010aed6:	cd 80                	int    $0x80
c010aed8:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010aedb:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010aede:	83 c4 2c             	add    $0x2c,%esp
c010aee1:	5b                   	pop    %ebx
c010aee2:	5e                   	pop    %esi
c010aee3:	5f                   	pop    %edi
c010aee4:	5d                   	pop    %ebp
c010aee5:	c3                   	ret    

c010aee6 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010aee6:	55                   	push   %ebp
c010aee7:	89 e5                	mov    %esp,%ebp
c010aee9:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
c010aeec:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010aef1:	8b 40 04             	mov    0x4(%eax),%eax
c010aef4:	c7 44 24 08 92 ed 10 	movl   $0xc010ed92,0x8(%esp)
c010aefb:	c0 
c010aefc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010af00:	c7 04 24 98 ed 10 c0 	movl   $0xc010ed98,(%esp)
c010af07:	e8 66 54 ff ff       	call   c0100372 <cprintf>
c010af0c:	b8 dc 78 00 00       	mov    $0x78dc,%eax
c010af11:	89 44 24 08          	mov    %eax,0x8(%esp)
c010af15:	c7 44 24 04 6c a9 14 	movl   $0xc014a96c,0x4(%esp)
c010af1c:	c0 
c010af1d:	c7 04 24 92 ed 10 c0 	movl   $0xc010ed92,(%esp)
c010af24:	e8 83 ff ff ff       	call   c010aeac <kernel_execve>
#endif
    panic("user_main execve failed.\n");
c010af29:	c7 44 24 08 bf ed 10 	movl   $0xc010edbf,0x8(%esp)
c010af30:	c0 
c010af31:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
c010af38:	00 
c010af39:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010af40:	e8 ab 5e ff ff       	call   c0100df0 <__panic>

c010af45 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010af45:	55                   	push   %ebp
c010af46:	89 e5                	mov    %esp,%ebp
c010af48:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010af4b:	e8 c6 a3 ff ff       	call   c0105316 <nr_free_pages>
c010af50:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010af53:	e8 68 9d ff ff       	call   c0104cc0 <kallocated>
c010af58:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010af5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010af62:	00 
c010af63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010af6a:	00 
c010af6b:	c7 04 24 e6 ae 10 c0 	movl   $0xc010aee6,(%esp)
c010af72:	e8 b0 ee ff ff       	call   c0109e27 <kernel_thread>
c010af77:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010af7a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010af7e:	7f 21                	jg     c010afa1 <init_main+0x5c>
        panic("create user_main failed.\n");
c010af80:	c7 44 24 08 d9 ed 10 	movl   $0xc010edd9,0x8(%esp)
c010af87:	c0 
c010af88:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
c010af8f:	00 
c010af90:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010af97:	e8 54 5e ff ff       	call   c0100df0 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
c010af9c:	e8 e9 0a 00 00       	call   c010ba8a <schedule>
    while (do_wait(0, NULL) == 0) {
c010afa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010afa8:	00 
c010afa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010afb0:	e8 01 fd ff ff       	call   c010acb6 <do_wait>
c010afb5:	85 c0                	test   %eax,%eax
c010afb7:	74 e3                	je     c010af9c <init_main+0x57>
    }

    cprintf("all user-mode processes have quit.\n");
c010afb9:	c7 04 24 f4 ed 10 c0 	movl   $0xc010edf4,(%esp)
c010afc0:	e8 ad 53 ff ff       	call   c0100372 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010afc5:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010afca:	8b 40 70             	mov    0x70(%eax),%eax
c010afcd:	85 c0                	test   %eax,%eax
c010afcf:	75 18                	jne    c010afe9 <init_main+0xa4>
c010afd1:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010afd6:	8b 40 74             	mov    0x74(%eax),%eax
c010afd9:	85 c0                	test   %eax,%eax
c010afdb:	75 0c                	jne    c010afe9 <init_main+0xa4>
c010afdd:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010afe2:	8b 40 78             	mov    0x78(%eax),%eax
c010afe5:	85 c0                	test   %eax,%eax
c010afe7:	74 24                	je     c010b00d <init_main+0xc8>
c010afe9:	c7 44 24 0c 18 ee 10 	movl   $0xc010ee18,0xc(%esp)
c010aff0:	c0 
c010aff1:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010aff8:	c0 
c010aff9:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
c010b000:	00 
c010b001:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b008:	e8 e3 5d ff ff       	call   c0100df0 <__panic>
    assert(nr_process == 2);
c010b00d:	a1 40 a1 1b c0       	mov    0xc01ba140,%eax
c010b012:	83 f8 02             	cmp    $0x2,%eax
c010b015:	74 24                	je     c010b03b <init_main+0xf6>
c010b017:	c7 44 24 0c 63 ee 10 	movl   $0xc010ee63,0xc(%esp)
c010b01e:	c0 
c010b01f:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010b026:	c0 
c010b027:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
c010b02e:	00 
c010b02f:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b036:	e8 b5 5d ff ff       	call   c0100df0 <__panic>
c010b03b:	c7 45 e8 20 81 1b c0 	movl   $0xc01b8120,-0x18(%ebp)
c010b042:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b045:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010b048:	8b 15 2c 81 1b c0    	mov    0xc01b812c,%edx
c010b04e:	83 c2 58             	add    $0x58,%edx
c010b051:	39 d0                	cmp    %edx,%eax
c010b053:	74 24                	je     c010b079 <init_main+0x134>
c010b055:	c7 44 24 0c 74 ee 10 	movl   $0xc010ee74,0xc(%esp)
c010b05c:	c0 
c010b05d:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010b064:	c0 
c010b065:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
c010b06c:	00 
c010b06d:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b074:	e8 77 5d ff ff       	call   c0100df0 <__panic>
c010b079:	c7 45 e4 20 81 1b c0 	movl   $0xc01b8120,-0x1c(%ebp)
    return listelm->prev;
c010b080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b083:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010b085:	8b 15 2c 81 1b c0    	mov    0xc01b812c,%edx
c010b08b:	83 c2 58             	add    $0x58,%edx
c010b08e:	39 d0                	cmp    %edx,%eax
c010b090:	74 24                	je     c010b0b6 <init_main+0x171>
c010b092:	c7 44 24 0c a4 ee 10 	movl   $0xc010eea4,0xc(%esp)
c010b099:	c0 
c010b09a:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010b0a1:	c0 
c010b0a2:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
c010b0a9:	00 
c010b0aa:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b0b1:	e8 3a 5d ff ff       	call   c0100df0 <__panic>

    cprintf("init check memory pass.\n");
c010b0b6:	c7 04 24 d4 ee 10 c0 	movl   $0xc010eed4,(%esp)
c010b0bd:	e8 b0 52 ff ff       	call   c0100372 <cprintf>
    return 0;
c010b0c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b0c7:	89 ec                	mov    %ebp,%esp
c010b0c9:	5d                   	pop    %ebp
c010b0ca:	c3                   	ret    

c010b0cb <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010b0cb:	55                   	push   %ebp
c010b0cc:	89 e5                	mov    %esp,%ebp
c010b0ce:	83 ec 28             	sub    $0x28,%esp
c010b0d1:	c7 45 ec 20 81 1b c0 	movl   $0xc01b8120,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010b0d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0db:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b0de:	89 50 04             	mov    %edx,0x4(%eax)
c010b0e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0e4:	8b 50 04             	mov    0x4(%eax),%edx
c010b0e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0ea:	89 10                	mov    %edx,(%eax)
}
c010b0ec:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010b0ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010b0f4:	eb 26                	jmp    c010b11c <proc_init+0x51>
        list_init(hash_list + i);
c010b0f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0f9:	c1 e0 03             	shl    $0x3,%eax
c010b0fc:	05 40 81 1b c0       	add    $0xc01b8140,%eax
c010b101:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c010b104:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b107:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b10a:	89 50 04             	mov    %edx,0x4(%eax)
c010b10d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b110:	8b 50 04             	mov    0x4(%eax),%edx
c010b113:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b116:	89 10                	mov    %edx,(%eax)
}
c010b118:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010b119:	ff 45 f4             	incl   -0xc(%ebp)
c010b11c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010b123:	7e d1                	jle    c010b0f6 <proc_init+0x2b>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010b125:	e8 c4 e7 ff ff       	call   c01098ee <alloc_proc>
c010b12a:	a3 28 81 1b c0       	mov    %eax,0xc01b8128
c010b12f:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b134:	85 c0                	test   %eax,%eax
c010b136:	75 1c                	jne    c010b154 <proc_init+0x89>
        panic("cannot alloc idleproc.\n");
c010b138:	c7 44 24 08 ed ee 10 	movl   $0xc010eeed,0x8(%esp)
c010b13f:	c0 
c010b140:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
c010b147:	00 
c010b148:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b14f:	e8 9c 5c ff ff       	call   c0100df0 <__panic>
    }

    idleproc->pid = 0;
c010b154:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b159:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010b160:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b165:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010b16b:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b170:	ba 00 10 13 c0       	mov    $0xc0131000,%edx
c010b175:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010b178:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b17d:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010b184:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b189:	c7 44 24 04 05 ef 10 	movl   $0xc010ef05,0x4(%esp)
c010b190:	c0 
c010b191:	89 04 24             	mov    %eax,(%esp)
c010b194:	e8 1c e8 ff ff       	call   c01099b5 <set_proc_name>
    nr_process ++;
c010b199:	a1 40 a1 1b c0       	mov    0xc01ba140,%eax
c010b19e:	40                   	inc    %eax
c010b19f:	a3 40 a1 1b c0       	mov    %eax,0xc01ba140

    current = idleproc;
c010b1a4:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b1a9:	a3 30 81 1b c0       	mov    %eax,0xc01b8130

    int pid = kernel_thread(init_main, NULL, 0);
c010b1ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010b1b5:	00 
c010b1b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010b1bd:	00 
c010b1be:	c7 04 24 45 af 10 c0 	movl   $0xc010af45,(%esp)
c010b1c5:	e8 5d ec ff ff       	call   c0109e27 <kernel_thread>
c010b1ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010b1cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b1d1:	7f 1c                	jg     c010b1ef <proc_init+0x124>
        panic("create init_main failed.\n");
c010b1d3:	c7 44 24 08 0a ef 10 	movl   $0xc010ef0a,0x8(%esp)
c010b1da:	c0 
c010b1db:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
c010b1e2:	00 
c010b1e3:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b1ea:	e8 01 5c ff ff       	call   c0100df0 <__panic>
    }

    initproc = find_proc(pid);
c010b1ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1f2:	89 04 24             	mov    %eax,(%esp)
c010b1f5:	e8 b9 eb ff ff       	call   c0109db3 <find_proc>
c010b1fa:	a3 2c 81 1b c0       	mov    %eax,0xc01b812c
    set_proc_name(initproc, "init");
c010b1ff:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010b204:	c7 44 24 04 24 ef 10 	movl   $0xc010ef24,0x4(%esp)
c010b20b:	c0 
c010b20c:	89 04 24             	mov    %eax,(%esp)
c010b20f:	e8 a1 e7 ff ff       	call   c01099b5 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010b214:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b219:	85 c0                	test   %eax,%eax
c010b21b:	74 0c                	je     c010b229 <proc_init+0x15e>
c010b21d:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b222:	8b 40 04             	mov    0x4(%eax),%eax
c010b225:	85 c0                	test   %eax,%eax
c010b227:	74 24                	je     c010b24d <proc_init+0x182>
c010b229:	c7 44 24 0c 2c ef 10 	movl   $0xc010ef2c,0xc(%esp)
c010b230:	c0 
c010b231:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010b238:	c0 
c010b239:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
c010b240:	00 
c010b241:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b248:	e8 a3 5b ff ff       	call   c0100df0 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010b24d:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010b252:	85 c0                	test   %eax,%eax
c010b254:	74 0d                	je     c010b263 <proc_init+0x198>
c010b256:	a1 2c 81 1b c0       	mov    0xc01b812c,%eax
c010b25b:	8b 40 04             	mov    0x4(%eax),%eax
c010b25e:	83 f8 01             	cmp    $0x1,%eax
c010b261:	74 24                	je     c010b287 <proc_init+0x1bc>
c010b263:	c7 44 24 0c 54 ef 10 	movl   $0xc010ef54,0xc(%esp)
c010b26a:	c0 
c010b26b:	c7 44 24 08 72 eb 10 	movl   $0xc010eb72,0x8(%esp)
c010b272:	c0 
c010b273:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
c010b27a:	00 
c010b27b:	c7 04 24 30 eb 10 c0 	movl   $0xc010eb30,(%esp)
c010b282:	e8 69 5b ff ff       	call   c0100df0 <__panic>
}
c010b287:	90                   	nop
c010b288:	89 ec                	mov    %ebp,%esp
c010b28a:	5d                   	pop    %ebp
c010b28b:	c3                   	ret    

c010b28c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010b28c:	55                   	push   %ebp
c010b28d:	89 e5                	mov    %esp,%ebp
c010b28f:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010b292:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010b297:	8b 40 10             	mov    0x10(%eax),%eax
c010b29a:	85 c0                	test   %eax,%eax
c010b29c:	74 f4                	je     c010b292 <cpu_idle+0x6>
            schedule();
c010b29e:	e8 e7 07 00 00       	call   c010ba8a <schedule>
        if (current->need_resched) {
c010b2a3:	eb ed                	jmp    c010b292 <cpu_idle+0x6>

c010b2a5 <lab6_set_priority>:
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
void
lab6_set_priority(uint32_t priority)
{
c010b2a5:	55                   	push   %ebp
c010b2a6:	89 e5                	mov    %esp,%ebp
    if (priority == 0)
c010b2a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b2ac:	75 11                	jne    c010b2bf <lab6_set_priority+0x1a>
        current->lab6_priority = 1;
c010b2ae:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010b2b3:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c010b2ba:	00 00 00 
    else current->lab6_priority = priority;
}
c010b2bd:	eb 0e                	jmp    c010b2cd <lab6_set_priority+0x28>
    else current->lab6_priority = priority;
c010b2bf:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010b2c4:	8b 55 08             	mov    0x8(%ebp),%edx
c010b2c7:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
}
c010b2cd:	90                   	nop
c010b2ce:	5d                   	pop    %ebp
c010b2cf:	c3                   	ret    

c010b2d0 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010b2d0:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010b2d4:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010b2d6:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010b2d9:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010b2dc:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010b2df:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010b2e2:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010b2e5:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010b2e8:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010b2eb:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010b2ef:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010b2f2:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010b2f5:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010b2f8:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010b2fb:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010b2fe:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010b301:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010b304:	ff 30                	pushl  (%eax)

    ret
c010b306:	c3                   	ret    

c010b307 <RR_init>:
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

static void
RR_init(struct run_queue *rq) {
c010b307:	55                   	push   %ebp
c010b308:	89 e5                	mov    %esp,%ebp
c010b30a:	83 ec 10             	sub    $0x10,%esp
    list_init(&(rq->run_list));
c010b30d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b310:	89 45 fc             	mov    %eax,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010b313:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b316:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b319:	89 50 04             	mov    %edx,0x4(%eax)
c010b31c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b31f:	8b 50 04             	mov    0x4(%eax),%edx
c010b322:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b325:	89 10                	mov    %edx,(%eax)
}
c010b327:	90                   	nop
    rq->proc_num = 0;
c010b328:	8b 45 08             	mov    0x8(%ebp),%eax
c010b32b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
c010b332:	90                   	nop
c010b333:	89 ec                	mov    %ebp,%esp
c010b335:	5d                   	pop    %ebp
c010b336:	c3                   	ret    

c010b337 <RR_enqueue>:

static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b337:	55                   	push   %ebp
c010b338:	89 e5                	mov    %esp,%ebp
c010b33a:	83 ec 38             	sub    $0x38,%esp
    assert(list_empty(&(proc->run_link)));
c010b33d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b340:	83 e8 80             	sub    $0xffffff80,%eax
c010b343:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return list->next == list;
c010b346:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b349:	8b 40 04             	mov    0x4(%eax),%eax
c010b34c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b34f:	0f 94 c0             	sete   %al
c010b352:	0f b6 c0             	movzbl %al,%eax
c010b355:	85 c0                	test   %eax,%eax
c010b357:	75 24                	jne    c010b37d <RR_enqueue+0x46>
c010b359:	c7 44 24 0c 7c ef 10 	movl   $0xc010ef7c,0xc(%esp)
c010b360:	c0 
c010b361:	c7 44 24 08 9a ef 10 	movl   $0xc010ef9a,0x8(%esp)
c010b368:	c0 
c010b369:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
c010b370:	00 
c010b371:	c7 04 24 af ef 10 c0 	movl   $0xc010efaf,(%esp)
c010b378:	e8 73 5a ff ff       	call   c0100df0 <__panic>
    list_add_before(&(rq->run_list), &(proc->run_link));
c010b37d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b380:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
c010b386:	8b 45 08             	mov    0x8(%ebp),%eax
c010b389:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b38c:	89 55 ec             	mov    %edx,-0x14(%ebp)
    __list_add(elm, listelm->prev, listelm);
c010b38f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b392:	8b 00                	mov    (%eax),%eax
c010b394:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b397:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b39a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b39d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next->prev = elm;
c010b3a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b3a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b3a9:	89 10                	mov    %edx,(%eax)
c010b3ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b3ae:	8b 10                	mov    (%eax),%edx
c010b3b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b3b3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010b3b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010b3bc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010b3bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b3c5:	89 10                	mov    %edx,(%eax)
}
c010b3c7:	90                   	nop
}
c010b3c8:	90                   	nop
    //correct the enqueue proc's time slice
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
c010b3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3cc:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b3d2:	85 c0                	test   %eax,%eax
c010b3d4:	74 13                	je     c010b3e9 <RR_enqueue+0xb2>
c010b3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3d9:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
c010b3df:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3e2:	8b 40 0c             	mov    0xc(%eax),%eax
c010b3e5:	39 c2                	cmp    %eax,%edx
c010b3e7:	7e 0f                	jle    c010b3f8 <RR_enqueue+0xc1>
        proc->time_slice = rq->max_time_slice;
c010b3e9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3ec:	8b 50 0c             	mov    0xc(%eax),%edx
c010b3ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3f2:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    proc->rq = rq;
c010b3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b3fb:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3fe:	89 50 7c             	mov    %edx,0x7c(%eax)
    rq->proc_num ++;
c010b401:	8b 45 08             	mov    0x8(%ebp),%eax
c010b404:	8b 40 08             	mov    0x8(%eax),%eax
c010b407:	8d 50 01             	lea    0x1(%eax),%edx
c010b40a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b40d:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b410:	90                   	nop
c010b411:	89 ec                	mov    %ebp,%esp
c010b413:	5d                   	pop    %ebp
c010b414:	c3                   	ret    

c010b415 <RR_dequeue>:

static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b415:	55                   	push   %ebp
c010b416:	89 e5                	mov    %esp,%ebp
c010b418:	83 ec 38             	sub    $0x38,%esp
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
c010b41b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b41e:	83 e8 80             	sub    $0xffffff80,%eax
c010b421:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return list->next == list;
c010b424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b427:	8b 40 04             	mov    0x4(%eax),%eax
c010b42a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b42d:	0f 94 c0             	sete   %al
c010b430:	0f b6 c0             	movzbl %al,%eax
c010b433:	85 c0                	test   %eax,%eax
c010b435:	75 0b                	jne    c010b442 <RR_dequeue+0x2d>
c010b437:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b43a:	8b 40 7c             	mov    0x7c(%eax),%eax
c010b43d:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b440:	74 24                	je     c010b466 <RR_dequeue+0x51>
c010b442:	c7 44 24 0c d0 ef 10 	movl   $0xc010efd0,0xc(%esp)
c010b449:	c0 
c010b44a:	c7 44 24 08 9a ef 10 	movl   $0xc010ef9a,0x8(%esp)
c010b451:	c0 
c010b452:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c010b459:	00 
c010b45a:	c7 04 24 af ef 10 c0 	movl   $0xc010efaf,(%esp)
c010b461:	e8 8a 59 ff ff       	call   c0100df0 <__panic>
    list_del_init(&(proc->run_link));
c010b466:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b469:	83 e8 80             	sub    $0xffffff80,%eax
c010b46c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b46f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b472:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c010b475:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b478:	8b 40 04             	mov    0x4(%eax),%eax
c010b47b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b47e:	8b 12                	mov    (%edx),%edx
c010b480:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b483:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c010b486:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b489:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b48c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010b48f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b492:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b495:	89 10                	mov    %edx,(%eax)
}
c010b497:	90                   	nop
}
c010b498:	90                   	nop
c010b499:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b49c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    elm->prev = elm->next = elm;
c010b49f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b4a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010b4a5:	89 50 04             	mov    %edx,0x4(%eax)
c010b4a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b4ab:	8b 50 04             	mov    0x4(%eax),%edx
c010b4ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b4b1:	89 10                	mov    %edx,(%eax)
}
c010b4b3:	90                   	nop
}
c010b4b4:	90                   	nop
    rq->proc_num --;
c010b4b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4b8:	8b 40 08             	mov    0x8(%eax),%eax
c010b4bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b4be:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4c1:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b4c4:	90                   	nop
c010b4c5:	89 ec                	mov    %ebp,%esp
c010b4c7:	5d                   	pop    %ebp
c010b4c8:	c3                   	ret    

c010b4c9 <RR_pick_next>:

static struct proc_struct *
RR_pick_next(struct run_queue *rq) {
c010b4c9:	55                   	push   %ebp
c010b4ca:	89 e5                	mov    %esp,%ebp
c010b4cc:	83 ec 10             	sub    $0x10,%esp
    list_entry_t *le = list_next(&(rq->run_list));
c010b4cf:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return listelm->next;
c010b4d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b4d8:	8b 40 04             	mov    0x4(%eax),%eax
c010b4db:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le != &(rq->run_list)) {
c010b4de:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4e1:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010b4e4:	74 08                	je     c010b4ee <RR_pick_next+0x25>
        return le2proc(le, run_link);
c010b4e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b4e9:	83 c0 80             	add    $0xffffff80,%eax
c010b4ec:	eb 05                	jmp    c010b4f3 <RR_pick_next+0x2a>
    }
    return NULL;
c010b4ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b4f3:	89 ec                	mov    %ebp,%esp
c010b4f5:	5d                   	pop    %ebp
c010b4f6:	c3                   	ret    

c010b4f7 <RR_proc_tick>:

static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b4f7:	55                   	push   %ebp
c010b4f8:	89 e5                	mov    %esp,%ebp
    if (proc->time_slice > 0) {
c010b4fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b4fd:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b503:	85 c0                	test   %eax,%eax
c010b505:	7e 15                	jle    c010b51c <RR_proc_tick+0x25>
        proc->time_slice --;
c010b507:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b50a:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b510:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b513:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b516:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    if (proc->time_slice == 0) {
c010b51c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b51f:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b525:	85 c0                	test   %eax,%eax
c010b527:	75 0a                	jne    c010b533 <RR_proc_tick+0x3c>
        proc->need_resched = 1;
c010b529:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b52c:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b533:	90                   	nop
c010b534:	5d                   	pop    %ebp
c010b535:	c3                   	ret    

c010b536 <skew_heap_merge>:

// 将堆a与堆b合并
static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
                compare_f comp)
{
c010b536:	55                   	push   %ebp
c010b537:	89 e5                	mov    %esp,%ebp
c010b539:	83 ec 28             	sub    $0x28,%esp
     if (a == NULL) return b;
c010b53c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b540:	75 08                	jne    c010b54a <skew_heap_merge+0x14>
c010b542:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b545:	e9 bd 00 00 00       	jmp    c010b607 <skew_heap_merge+0xd1>
     else if (b == NULL) return a;
c010b54a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b54e:	75 08                	jne    c010b558 <skew_heap_merge+0x22>
c010b550:	8b 45 08             	mov    0x8(%ebp),%eax
c010b553:	e9 af 00 00 00       	jmp    c010b607 <skew_heap_merge+0xd1>
     
     skew_heap_entry_t *l, *r;
     // 如果 a < b
     if (comp(a, b) == -1)
c010b558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b55b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b55f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b562:	89 04 24             	mov    %eax,(%esp)
c010b565:	8b 45 10             	mov    0x10(%ebp),%eax
c010b568:	ff d0                	call   *%eax
c010b56a:	83 f8 ff             	cmp    $0xffffffff,%eax
c010b56d:	75 4d                	jne    c010b5bc <skew_heap_merge+0x86>
     {
          r = a->left;
c010b56f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b572:	8b 40 04             	mov    0x4(%eax),%eax
c010b575:	89 45 f4             	mov    %eax,-0xc(%ebp)
          // 将a的右子树与较大的b合并
          l = skew_heap_merge(a->right, b, comp);
c010b578:	8b 45 08             	mov    0x8(%ebp),%eax
c010b57b:	8b 40 08             	mov    0x8(%eax),%eax
c010b57e:	8b 55 10             	mov    0x10(%ebp),%edx
c010b581:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b585:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b588:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b58c:	89 04 24             	mov    %eax,(%esp)
c010b58f:	e8 a2 ff ff ff       	call   c010b536 <skew_heap_merge>
c010b594:	89 45 f0             	mov    %eax,-0x10(%ebp)
          // 并将合并后的结果设置为左子树
          a->left = l;
c010b597:	8b 45 08             	mov    0x8(%ebp),%eax
c010b59a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b59d:	89 50 04             	mov    %edx,0x4(%eax)
          // 右子树设置为原先的左子树
          a->right = r;
c010b5a0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b5a6:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = a;
c010b5a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5ad:	74 08                	je     c010b5b7 <skew_heap_merge+0x81>
c010b5af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5b2:	8b 55 08             	mov    0x8(%ebp),%edx
c010b5b5:	89 10                	mov    %edx,(%eax)

          return a;
c010b5b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5ba:	eb 4b                	jmp    c010b607 <skew_heap_merge+0xd1>
     }
     else
     {
          r = b->left;
c010b5bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5bf:	8b 40 04             	mov    0x4(%eax),%eax
c010b5c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
          // 将较大的a与b的右子树合并
          l = skew_heap_merge(a, b->right, comp);
c010b5c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5c8:	8b 40 08             	mov    0x8(%eax),%eax
c010b5cb:	8b 55 10             	mov    0x10(%ebp),%edx
c010b5ce:	89 54 24 08          	mov    %edx,0x8(%esp)
c010b5d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5d6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5d9:	89 04 24             	mov    %eax,(%esp)
c010b5dc:	e8 55 ff ff ff       	call   c010b536 <skew_heap_merge>
c010b5e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
          // 设置合并后的结果为较小的b的左子树
          b->left = l;
c010b5e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b5ea:	89 50 04             	mov    %edx,0x4(%eax)
          // 左子树设置为原先的右子树
          b->right = r;
c010b5ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b5f3:	89 50 08             	mov    %edx,0x8(%eax)
          if (l) l->parent = b;
c010b5f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5fa:	74 08                	je     c010b604 <skew_heap_merge+0xce>
c010b5fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5ff:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b602:	89 10                	mov    %edx,(%eax)

          return b;
c010b604:	8b 45 0c             	mov    0xc(%ebp),%eax
     }
}
c010b607:	89 ec                	mov    %ebp,%esp
c010b609:	5d                   	pop    %ebp
c010b60a:	c3                   	ret    

c010b60b <proc_stride_comp_f>:

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
c010b60b:	55                   	push   %ebp
c010b60c:	89 e5                	mov    %esp,%ebp
c010b60e:	83 ec 10             	sub    $0x10,%esp
     struct proc_struct *p = le2proc(a, lab6_run_pool);
c010b611:	8b 45 08             	mov    0x8(%ebp),%eax
c010b614:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b619:	89 45 fc             	mov    %eax,-0x4(%ebp)
     struct proc_struct *q = le2proc(b, lab6_run_pool);
c010b61c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b61f:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b624:	89 45 f8             	mov    %eax,-0x8(%ebp)
     int32_t c = p->lab6_stride - q->lab6_stride;
c010b627:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b62a:	8b 90 98 00 00 00    	mov    0x98(%eax),%edx
c010b630:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b633:	8b 88 98 00 00 00    	mov    0x98(%eax),%ecx
c010b639:	89 d0                	mov    %edx,%eax
c010b63b:	29 c8                	sub    %ecx,%eax
c010b63d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     if (c > 0) return 1;
c010b640:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b644:	7e 07                	jle    c010b64d <proc_stride_comp_f+0x42>
c010b646:	b8 01 00 00 00       	mov    $0x1,%eax
c010b64b:	eb 12                	jmp    c010b65f <proc_stride_comp_f+0x54>
     else if (c == 0) return 0;
c010b64d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b651:	75 07                	jne    c010b65a <proc_stride_comp_f+0x4f>
c010b653:	b8 00 00 00 00       	mov    $0x0,%eax
c010b658:	eb 05                	jmp    c010b65f <proc_stride_comp_f+0x54>
     else return -1;
c010b65a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
c010b65f:	89 ec                	mov    %ebp,%esp
c010b661:	5d                   	pop    %ebp
c010b662:	c3                   	ret    

c010b663 <stride_init>:
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq) {
c010b663:	55                   	push   %ebp
c010b664:	89 e5                	mov    %esp,%ebp
c010b666:	83 ec 10             	sub    $0x10,%esp
    list_init(&(rq->run_list));
c010b669:	8b 45 08             	mov    0x8(%ebp),%eax
c010b66c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    elm->prev = elm->next = elm;
c010b66f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b672:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b675:	89 50 04             	mov    %edx,0x4(%eax)
c010b678:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b67b:	8b 50 04             	mov    0x4(%eax),%edx
c010b67e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b681:	89 10                	mov    %edx,(%eax)
}
c010b683:	90                   	nop
    // 注意这里不要使用skew_heap_init(rq->lab6_run_pool)
    /* 因为lab6_run_pool是一个指针, 初始默认不指向任何东西, 而上面这个函数会对未初始化的地址
     * 解引用设置left right和parent为NULL
     */
    rq->lab6_run_pool = NULL;
c010b684:	8b 45 08             	mov    0x8(%ebp),%eax
c010b687:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    rq->proc_num = 0;
c010b68e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b691:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
     /* LAB6: YOUR CODE 
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
}
c010b698:	90                   	nop
c010b699:	89 ec                	mov    %ebp,%esp
c010b69b:	5d                   	pop    %ebp
c010b69c:	c3                   	ret    

c010b69d <stride_enqueue>:
 * 
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b69d:	55                   	push   %ebp
c010b69e:	89 e5                	mov    %esp,%ebp
c010b6a0:	83 ec 28             	sub    $0x28,%esp
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b6a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6a6:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b6ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6af:	8b 40 10             	mov    0x10(%eax),%eax
c010b6b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b6b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b6b8:	c7 45 ec 0b b6 10 c0 	movl   $0xc010b60b,-0x14(%ebp)
c010b6bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
     a->left = a->right = a->parent = NULL;
c010b6c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b6c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010b6ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b6d1:	8b 10                	mov    (%eax),%edx
c010b6d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b6d6:	89 50 08             	mov    %edx,0x8(%eax)
c010b6d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b6dc:	8b 50 08             	mov    0x8(%eax),%edx
c010b6df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b6e2:	89 50 04             	mov    %edx,0x4(%eax)
}
c010b6e5:	90                   	nop
skew_heap_insert(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_init(b);
     // 添加某个堆进入另一个堆
     return skew_heap_merge(a, b, comp);
c010b6e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b6e9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b6ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6f7:	89 04 24             	mov    %eax,(%esp)
c010b6fa:	e8 37 fe ff ff       	call   c010b536 <skew_heap_merge>
c010b6ff:	8b 55 08             	mov    0x8(%ebp),%edx
c010b702:	89 42 10             	mov    %eax,0x10(%edx)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
c010b705:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b708:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b70e:	85 c0                	test   %eax,%eax
c010b710:	74 13                	je     c010b725 <stride_enqueue+0x88>
c010b712:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b715:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
c010b71b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b71e:	8b 40 0c             	mov    0xc(%eax),%eax
c010b721:	39 c2                	cmp    %eax,%edx
c010b723:	7e 0f                	jle    c010b734 <stride_enqueue+0x97>
        proc->time_slice = rq->max_time_slice;
c010b725:	8b 45 08             	mov    0x8(%ebp),%eax
c010b728:	8b 50 0c             	mov    0xc(%eax),%edx
c010b72b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b72e:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    proc->rq = rq;
c010b734:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b737:	8b 55 08             	mov    0x8(%ebp),%edx
c010b73a:	89 50 7c             	mov    %edx,0x7c(%eax)
    rq->proc_num ++;
c010b73d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b740:	8b 40 08             	mov    0x8(%eax),%eax
c010b743:	8d 50 01             	lea    0x1(%eax),%edx
c010b746:	8b 45 08             	mov    0x8(%ebp),%eax
c010b749:	89 50 08             	mov    %edx,0x8(%eax)
      *         list_add_before: insert  a entry into the last of list   
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
}
c010b74c:	90                   	nop
c010b74d:	89 ec                	mov    %ebp,%esp
c010b74f:	5d                   	pop    %ebp
c010b750:	c3                   	ret    

c010b751 <stride_dequeue>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b751:	55                   	push   %ebp
c010b752:	89 e5                	mov    %esp,%ebp
c010b754:	83 ec 38             	sub    $0x38,%esp
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
c010b757:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b75a:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
c010b760:	8b 45 08             	mov    0x8(%ebp),%eax
c010b763:	8b 40 10             	mov    0x10(%eax),%eax
c010b766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b769:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b76c:	c7 45 ec 0b b6 10 c0 	movl   $0xc010b60b,-0x14(%ebp)

static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
c010b773:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b776:	8b 00                	mov    (%eax),%eax
c010b778:	89 45 e8             	mov    %eax,-0x18(%ebp)
     // 将当前节点的所有节点结成一个新的堆，并添加至父节点中
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
c010b77b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b77e:	8b 50 08             	mov    0x8(%eax),%edx
c010b781:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b784:	8b 40 04             	mov    0x4(%eax),%eax
c010b787:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b78a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010b78e:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b792:	89 04 24             	mov    %eax,(%esp)
c010b795:	e8 9c fd ff ff       	call   c010b536 <skew_heap_merge>
c010b79a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     if (rep) rep->parent = p;
c010b79d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b7a1:	74 08                	je     c010b7ab <stride_dequeue+0x5a>
c010b7a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b7a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b7a9:	89 10                	mov    %edx,(%eax)
     // 设置当前被删除节点的父节点，所对应的左/右节点为其对应的子节点
     if (p)
c010b7ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b7af:	74 24                	je     c010b7d5 <stride_dequeue+0x84>
     {
          if (p->left == b)
c010b7b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7b4:	8b 40 04             	mov    0x4(%eax),%eax
c010b7b7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b7ba:	75 0b                	jne    c010b7c7 <stride_dequeue+0x76>
               p->left = rep;
c010b7bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b7c2:	89 50 04             	mov    %edx,0x4(%eax)
c010b7c5:	eb 09                	jmp    c010b7d0 <stride_dequeue+0x7f>
          else p->right = rep;
c010b7c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b7ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b7cd:	89 50 08             	mov    %edx,0x8(%eax)
          return a;
c010b7d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b7d3:	eb 03                	jmp    c010b7d8 <stride_dequeue+0x87>
     }
     else return rep;
c010b7d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b7d8:	8b 55 08             	mov    0x8(%ebp),%edx
c010b7db:	89 42 10             	mov    %eax,0x10(%edx)
    rq->proc_num --;
c010b7de:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7e1:	8b 40 08             	mov    0x8(%eax),%eax
c010b7e4:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b7e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7ea:	89 50 08             	mov    %edx,0x8(%eax)
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
}
c010b7ed:	90                   	nop
c010b7ee:	89 ec                	mov    %ebp,%esp
c010b7f0:	5d                   	pop    %ebp
c010b7f1:	c3                   	ret    

c010b7f2 <stride_pick_next>:
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
c010b7f2:	55                   	push   %ebp
c010b7f3:	89 e5                	mov    %esp,%ebp
c010b7f5:	83 ec 14             	sub    $0x14,%esp
c010b7f8:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    skew_heap_entry_t* min = rq->lab6_run_pool;
c010b7fb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7fe:	8b 40 10             	mov    0x10(%eax),%eax
c010b801:	89 45 f8             	mov    %eax,-0x8(%ebp)
    if (min != NULL) {
c010b804:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010b808:	74 3a                	je     c010b844 <stride_pick_next+0x52>
        struct proc_struct* p = le2proc(min, lab6_run_pool);
c010b80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b80d:	2d 8c 00 00 00       	sub    $0x8c,%eax
c010b812:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p->lab6_stride += BIG_STRIDE / p->lab6_priority;
c010b815:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b818:	8b 88 98 00 00 00    	mov    0x98(%eax),%ecx
c010b81e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b821:	8b 98 9c 00 00 00    	mov    0x9c(%eax),%ebx
c010b827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010b82c:	ba 00 00 00 00       	mov    $0x0,%edx
c010b831:	f7 f3                	div    %ebx
c010b833:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010b836:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b839:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
        return p;
c010b83f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b842:	eb 05                	jmp    c010b849 <stride_pick_next+0x57>
    }
    return NULL;
c010b844:	b8 00 00 00 00       	mov    $0x0,%eax
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_poll
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
}
c010b849:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010b84c:	89 ec                	mov    %ebp,%esp
c010b84e:	5d                   	pop    %ebp
c010b84f:	c3                   	ret    

c010b850 <stride_proc_tick>:
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b850:	55                   	push   %ebp
c010b851:	89 e5                	mov    %esp,%ebp
     /* LAB6: YOUR CODE */
     if (proc->time_slice > 0) {
c010b853:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b856:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b85c:	85 c0                	test   %eax,%eax
c010b85e:	7e 15                	jle    c010b875 <stride_proc_tick+0x25>
        proc->time_slice --;
c010b860:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b863:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b869:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b86c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b86f:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    if (proc->time_slice == 0) {
c010b875:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b878:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b87e:	85 c0                	test   %eax,%eax
c010b880:	75 0a                	jne    c010b88c <stride_proc_tick+0x3c>
        proc->need_resched = 1;
c010b882:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b885:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b88c:	90                   	nop
c010b88d:	5d                   	pop    %ebp
c010b88e:	c3                   	ret    

c010b88f <__intr_save>:
__intr_save(void) {
c010b88f:	55                   	push   %ebp
c010b890:	89 e5                	mov    %esp,%ebp
c010b892:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b895:	9c                   	pushf  
c010b896:	58                   	pop    %eax
c010b897:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b89a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b89d:	25 00 02 00 00       	and    $0x200,%eax
c010b8a2:	85 c0                	test   %eax,%eax
c010b8a4:	74 0c                	je     c010b8b2 <__intr_save+0x23>
        intr_disable();
c010b8a6:	e8 fb 67 ff ff       	call   c01020a6 <intr_disable>
        return 1;
c010b8ab:	b8 01 00 00 00       	mov    $0x1,%eax
c010b8b0:	eb 05                	jmp    c010b8b7 <__intr_save+0x28>
    return 0;
c010b8b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b8b7:	89 ec                	mov    %ebp,%esp
c010b8b9:	5d                   	pop    %ebp
c010b8ba:	c3                   	ret    

c010b8bb <__intr_restore>:
__intr_restore(bool flag) {
c010b8bb:	55                   	push   %ebp
c010b8bc:	89 e5                	mov    %esp,%ebp
c010b8be:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b8c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b8c5:	74 05                	je     c010b8cc <__intr_restore+0x11>
        intr_enable();
c010b8c7:	e8 d2 67 ff ff       	call   c010209e <intr_enable>
}
c010b8cc:	90                   	nop
c010b8cd:	89 ec                	mov    %ebp,%esp
c010b8cf:	5d                   	pop    %ebp
c010b8d0:	c3                   	ret    

c010b8d1 <sched_class_enqueue>:
static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc) {
c010b8d1:	55                   	push   %ebp
c010b8d2:	89 e5                	mov    %esp,%ebp
c010b8d4:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b8d7:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b8dc:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b8df:	74 1a                	je     c010b8fb <sched_class_enqueue+0x2a>
        sched_class->enqueue(rq, proc);
c010b8e1:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b8e6:	8b 40 08             	mov    0x8(%eax),%eax
c010b8e9:	8b 15 60 a1 1b c0    	mov    0xc01ba160,%edx
c010b8ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b8f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b8f6:	89 14 24             	mov    %edx,(%esp)
c010b8f9:	ff d0                	call   *%eax
    }
}
c010b8fb:	90                   	nop
c010b8fc:	89 ec                	mov    %ebp,%esp
c010b8fe:	5d                   	pop    %ebp
c010b8ff:	c3                   	ret    

c010b900 <sched_class_dequeue>:

static inline void
sched_class_dequeue(struct proc_struct *proc) {
c010b900:	55                   	push   %ebp
c010b901:	89 e5                	mov    %esp,%ebp
c010b903:	83 ec 18             	sub    $0x18,%esp
    sched_class->dequeue(rq, proc);
c010b906:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b90b:	8b 40 0c             	mov    0xc(%eax),%eax
c010b90e:	8b 15 60 a1 1b c0    	mov    0xc01ba160,%edx
c010b914:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b917:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b91b:	89 14 24             	mov    %edx,(%esp)
c010b91e:	ff d0                	call   *%eax
}
c010b920:	90                   	nop
c010b921:	89 ec                	mov    %ebp,%esp
c010b923:	5d                   	pop    %ebp
c010b924:	c3                   	ret    

c010b925 <sched_class_pick_next>:

static inline struct proc_struct *
sched_class_pick_next(void) {
c010b925:	55                   	push   %ebp
c010b926:	89 e5                	mov    %esp,%ebp
c010b928:	83 ec 18             	sub    $0x18,%esp
    return sched_class->pick_next(rq);
c010b92b:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b930:	8b 40 10             	mov    0x10(%eax),%eax
c010b933:	8b 15 60 a1 1b c0    	mov    0xc01ba160,%edx
c010b939:	89 14 24             	mov    %edx,(%esp)
c010b93c:	ff d0                	call   *%eax
}
c010b93e:	89 ec                	mov    %ebp,%esp
c010b940:	5d                   	pop    %ebp
c010b941:	c3                   	ret    

c010b942 <sched_class_proc_tick>:

void
sched_class_proc_tick(struct proc_struct *proc) {
c010b942:	55                   	push   %ebp
c010b943:	89 e5                	mov    %esp,%ebp
c010b945:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b948:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010b94d:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b950:	74 1c                	je     c010b96e <sched_class_proc_tick+0x2c>
        sched_class->proc_tick(rq, proc);
c010b952:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b957:	8b 40 14             	mov    0x14(%eax),%eax
c010b95a:	8b 15 60 a1 1b c0    	mov    0xc01ba160,%edx
c010b960:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b963:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b967:	89 14 24             	mov    %edx,(%esp)
c010b96a:	ff d0                	call   *%eax
    }
    else {
        proc->need_resched = 1;
    }
}
c010b96c:	eb 0a                	jmp    c010b978 <sched_class_proc_tick+0x36>
        proc->need_resched = 1;
c010b96e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b971:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
}
c010b978:	90                   	nop
c010b979:	89 ec                	mov    %ebp,%esp
c010b97b:	5d                   	pop    %ebp
c010b97c:	c3                   	ret    

c010b97d <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
c010b97d:	55                   	push   %ebp
c010b97e:	89 e5                	mov    %esp,%ebp
c010b980:	83 ec 28             	sub    $0x28,%esp
c010b983:	c7 45 f4 54 a1 1b c0 	movl   $0xc01ba154,-0xc(%ebp)
    elm->prev = elm->next = elm;
c010b98a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b98d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b990:	89 50 04             	mov    %edx,0x4(%eax)
c010b993:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b996:	8b 50 04             	mov    0x4(%eax),%edx
c010b999:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b99c:	89 10                	mov    %edx,(%eax)
}
c010b99e:	90                   	nop
    list_init(&timer_list);
    extern struct sched_class default_sched_class1;
    sched_class = &default_sched_class;
c010b99f:	c7 05 5c a1 1b c0 a0 	movl   $0xc0133aa0,0xc01ba15c
c010b9a6:	3a 13 c0 

    rq = &__rq;
c010b9a9:	c7 05 60 a1 1b c0 64 	movl   $0xc01ba164,0xc01ba160
c010b9b0:	a1 1b c0 
    rq->max_time_slice = MAX_TIME_SLICE;
c010b9b3:	a1 60 a1 1b c0       	mov    0xc01ba160,%eax
c010b9b8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
    sched_class->init(rq);
c010b9bf:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b9c4:	8b 40 04             	mov    0x4(%eax),%eax
c010b9c7:	8b 15 60 a1 1b c0    	mov    0xc01ba160,%edx
c010b9cd:	89 14 24             	mov    %edx,(%esp)
c010b9d0:	ff d0                	call   *%eax

    cprintf("sched class: %s\n", sched_class->name);
c010b9d2:	a1 5c a1 1b c0       	mov    0xc01ba15c,%eax
c010b9d7:	8b 00                	mov    (%eax),%eax
c010b9d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b9dd:	c7 04 24 1f f0 10 c0 	movl   $0xc010f01f,(%esp)
c010b9e4:	e8 89 49 ff ff       	call   c0100372 <cprintf>
}
c010b9e9:	90                   	nop
c010b9ea:	89 ec                	mov    %ebp,%esp
c010b9ec:	5d                   	pop    %ebp
c010b9ed:	c3                   	ret    

c010b9ee <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
c010b9ee:	55                   	push   %ebp
c010b9ef:	89 e5                	mov    %esp,%ebp
c010b9f1:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b9f4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9f7:	8b 00                	mov    (%eax),%eax
c010b9f9:	83 f8 03             	cmp    $0x3,%eax
c010b9fc:	75 24                	jne    c010ba22 <wakeup_proc+0x34>
c010b9fe:	c7 44 24 0c 30 f0 10 	movl   $0xc010f030,0xc(%esp)
c010ba05:	c0 
c010ba06:	c7 44 24 08 4b f0 10 	movl   $0xc010f04b,0x8(%esp)
c010ba0d:	c0 
c010ba0e:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c010ba15:	00 
c010ba16:	c7 04 24 60 f0 10 c0 	movl   $0xc010f060,(%esp)
c010ba1d:	e8 ce 53 ff ff       	call   c0100df0 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010ba22:	e8 68 fe ff ff       	call   c010b88f <__intr_save>
c010ba27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010ba2a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba2d:	8b 00                	mov    (%eax),%eax
c010ba2f:	83 f8 02             	cmp    $0x2,%eax
c010ba32:	74 2a                	je     c010ba5e <wakeup_proc+0x70>
            proc->state = PROC_RUNNABLE;
c010ba34:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba37:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010ba3d:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba40:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
            if (proc != current) {
c010ba47:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ba4c:	39 45 08             	cmp    %eax,0x8(%ebp)
c010ba4f:	74 29                	je     c010ba7a <wakeup_proc+0x8c>
                sched_class_enqueue(proc);
c010ba51:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba54:	89 04 24             	mov    %eax,(%esp)
c010ba57:	e8 75 fe ff ff       	call   c010b8d1 <sched_class_enqueue>
c010ba5c:	eb 1c                	jmp    c010ba7a <wakeup_proc+0x8c>
            }
        }
        else {
            warn("wakeup runnable process.\n");
c010ba5e:	c7 44 24 08 76 f0 10 	movl   $0xc010f076,0x8(%esp)
c010ba65:	c0 
c010ba66:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c010ba6d:	00 
c010ba6e:	c7 04 24 60 f0 10 c0 	movl   $0xc010f060,(%esp)
c010ba75:	e8 f4 53 ff ff       	call   c0100e6e <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010ba7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba7d:	89 04 24             	mov    %eax,(%esp)
c010ba80:	e8 36 fe ff ff       	call   c010b8bb <__intr_restore>
}
c010ba85:	90                   	nop
c010ba86:	89 ec                	mov    %ebp,%esp
c010ba88:	5d                   	pop    %ebp
c010ba89:	c3                   	ret    

c010ba8a <schedule>:

void
schedule(void) {
c010ba8a:	55                   	push   %ebp
c010ba8b:	89 e5                	mov    %esp,%ebp
c010ba8d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);  //inhibit interrupt
c010ba90:	e8 fa fd ff ff       	call   c010b88f <__intr_save>
c010ba95:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        current->need_resched = 0;
c010ba98:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010ba9d:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        if (current->state == PROC_RUNNABLE) {
c010baa4:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010baa9:	8b 00                	mov    (%eax),%eax
c010baab:	83 f8 02             	cmp    $0x2,%eax
c010baae:	75 0d                	jne    c010babd <schedule+0x33>
            //change from list search to function
            sched_class_enqueue(current);
c010bab0:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bab5:	89 04 24             	mov    %eax,(%esp)
c010bab8:	e8 14 fe ff ff       	call   c010b8d1 <sched_class_enqueue>
        }
        if ((next = sched_class_pick_next()) != NULL) {
c010babd:	e8 63 fe ff ff       	call   c010b925 <sched_class_pick_next>
c010bac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bac5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010bac9:	74 0b                	je     c010bad6 <schedule+0x4c>
            sched_class_dequeue(next);
c010bacb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bace:	89 04 24             	mov    %eax,(%esp)
c010bad1:	e8 2a fe ff ff       	call   c010b900 <sched_class_dequeue>
        }
        if (next == NULL) {
c010bad6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010bada:	75 08                	jne    c010bae4 <schedule+0x5a>
            next = idleproc;
c010badc:	a1 28 81 1b c0       	mov    0xc01b8128,%eax
c010bae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        next->runs ++;
c010bae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bae7:	8b 40 08             	mov    0x8(%eax),%eax
c010baea:	8d 50 01             	lea    0x1(%eax),%edx
c010baed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010baf0:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010baf3:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010baf8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010bafb:	74 0b                	je     c010bb08 <schedule+0x7e>
            proc_run(next);
c010bafd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb00:	89 04 24             	mov    %eax,(%esp)
c010bb03:	e8 5c e1 ff ff       	call   c0109c64 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010bb08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb0b:	89 04 24             	mov    %eax,(%esp)
c010bb0e:	e8 a8 fd ff ff       	call   c010b8bb <__intr_restore>
}
c010bb13:	90                   	nop
c010bb14:	89 ec                	mov    %ebp,%esp
c010bb16:	5d                   	pop    %ebp
c010bb17:	c3                   	ret    

c010bb18 <sys_exit>:
#include <pmm.h>
#include <assert.h>
#include <clock.h>

static int
sys_exit(uint32_t arg[]) {
c010bb18:	55                   	push   %ebp
c010bb19:	89 e5                	mov    %esp,%ebp
c010bb1b:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010bb1e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb21:	8b 00                	mov    (%eax),%eax
c010bb23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010bb26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb29:	89 04 24             	mov    %eax,(%esp)
c010bb2c:	e8 fa e7 ff ff       	call   c010a32b <do_exit>
}
c010bb31:	89 ec                	mov    %ebp,%esp
c010bb33:	5d                   	pop    %ebp
c010bb34:	c3                   	ret    

c010bb35 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010bb35:	55                   	push   %ebp
c010bb36:	89 e5                	mov    %esp,%ebp
c010bb38:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010bb3b:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bb40:	8b 40 3c             	mov    0x3c(%eax),%eax
c010bb43:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010bb46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb49:	8b 40 44             	mov    0x44(%eax),%eax
c010bb4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010bb4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb52:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bb56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb59:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010bb64:	e8 74 e6 ff ff       	call   c010a1dd <do_fork>
}
c010bb69:	89 ec                	mov    %ebp,%esp
c010bb6b:	5d                   	pop    %ebp
c010bb6c:	c3                   	ret    

c010bb6d <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010bb6d:	55                   	push   %ebp
c010bb6e:	89 e5                	mov    %esp,%ebp
c010bb70:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010bb73:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb76:	8b 00                	mov    (%eax),%eax
c010bb78:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010bb7b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb7e:	83 c0 04             	add    $0x4,%eax
c010bb81:	8b 00                	mov    (%eax),%eax
c010bb83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010bb86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb89:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bb90:	89 04 24             	mov    %eax,(%esp)
c010bb93:	e8 1e f1 ff ff       	call   c010acb6 <do_wait>
}
c010bb98:	89 ec                	mov    %ebp,%esp
c010bb9a:	5d                   	pop    %ebp
c010bb9b:	c3                   	ret    

c010bb9c <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010bb9c:	55                   	push   %ebp
c010bb9d:	89 e5                	mov    %esp,%ebp
c010bb9f:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010bba2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bba5:	8b 00                	mov    (%eax),%eax
c010bba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010bbaa:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbad:	83 c0 04             	add    $0x4,%eax
c010bbb0:	8b 00                	mov    (%eax),%eax
c010bbb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010bbb5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbb8:	83 c0 08             	add    $0x8,%eax
c010bbbb:	8b 00                	mov    (%eax),%eax
c010bbbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010bbc0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbc3:	83 c0 0c             	add    $0xc,%eax
c010bbc6:	8b 00                	mov    (%eax),%eax
c010bbc8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010bbcb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bbce:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bbd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bbd5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bbd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bbdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bbe3:	89 04 24             	mov    %eax,(%esp)
c010bbe6:	e8 7a ef ff ff       	call   c010ab65 <do_execve>
}
c010bbeb:	89 ec                	mov    %ebp,%esp
c010bbed:	5d                   	pop    %ebp
c010bbee:	c3                   	ret    

c010bbef <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010bbef:	55                   	push   %ebp
c010bbf0:	89 e5                	mov    %esp,%ebp
c010bbf2:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010bbf5:	e8 a6 f0 ff ff       	call   c010aca0 <do_yield>
}
c010bbfa:	89 ec                	mov    %ebp,%esp
c010bbfc:	5d                   	pop    %ebp
c010bbfd:	c3                   	ret    

c010bbfe <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010bbfe:	55                   	push   %ebp
c010bbff:	89 e5                	mov    %esp,%ebp
c010bc01:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010bc04:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc07:	8b 00                	mov    (%eax),%eax
c010bc09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010bc0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bc0f:	89 04 24             	mov    %eax,(%esp)
c010bc12:	e8 31 f2 ff ff       	call   c010ae48 <do_kill>
}
c010bc17:	89 ec                	mov    %ebp,%esp
c010bc19:	5d                   	pop    %ebp
c010bc1a:	c3                   	ret    

c010bc1b <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010bc1b:	55                   	push   %ebp
c010bc1c:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010bc1e:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bc23:	8b 40 04             	mov    0x4(%eax),%eax
}
c010bc26:	5d                   	pop    %ebp
c010bc27:	c3                   	ret    

c010bc28 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010bc28:	55                   	push   %ebp
c010bc29:	89 e5                	mov    %esp,%ebp
c010bc2b:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010bc2e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc31:	8b 00                	mov    (%eax),%eax
c010bc33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010bc36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bc39:	89 04 24             	mov    %eax,(%esp)
c010bc3c:	e8 59 47 ff ff       	call   c010039a <cputchar>
    return 0;
c010bc41:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bc46:	89 ec                	mov    %ebp,%esp
c010bc48:	5d                   	pop    %ebp
c010bc49:	c3                   	ret    

c010bc4a <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010bc4a:	55                   	push   %ebp
c010bc4b:	89 e5                	mov    %esp,%ebp
c010bc4d:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010bc50:	e8 3b b1 ff ff       	call   c0106d90 <print_pgdir>
    return 0;
c010bc55:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bc5a:	89 ec                	mov    %ebp,%esp
c010bc5c:	5d                   	pop    %ebp
c010bc5d:	c3                   	ret    

c010bc5e <sys_gettime>:

static int
sys_gettime(uint32_t arg[]) {
c010bc5e:	55                   	push   %ebp
c010bc5f:	89 e5                	mov    %esp,%ebp
    return (int)ticks;
c010bc61:	a1 24 74 1b c0       	mov    0xc01b7424,%eax
}
c010bc66:	5d                   	pop    %ebp
c010bc67:	c3                   	ret    

c010bc68 <sys_lab6_set_priority>:
static int
sys_lab6_set_priority(uint32_t arg[])
{
c010bc68:	55                   	push   %ebp
c010bc69:	89 e5                	mov    %esp,%ebp
c010bc6b:	83 ec 28             	sub    $0x28,%esp
    uint32_t priority = (uint32_t)arg[0];
c010bc6e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc71:	8b 00                	mov    (%eax),%eax
c010bc73:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lab6_set_priority(priority);
c010bc76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bc79:	89 04 24             	mov    %eax,(%esp)
c010bc7c:	e8 24 f6 ff ff       	call   c010b2a5 <lab6_set_priority>
    return 0;
c010bc81:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bc86:	89 ec                	mov    %ebp,%esp
c010bc88:	5d                   	pop    %ebp
c010bc89:	c3                   	ret    

c010bc8a <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010bc8a:	55                   	push   %ebp
c010bc8b:	89 e5                	mov    %esp,%ebp
c010bc8d:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010bc90:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bc95:	8b 40 3c             	mov    0x3c(%eax),%eax
c010bc98:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010bc9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bc9e:	8b 40 1c             	mov    0x1c(%eax),%eax
c010bca1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010bca4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010bca8:	78 60                	js     c010bd0a <syscall+0x80>
c010bcaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bcad:	3d ff 00 00 00       	cmp    $0xff,%eax
c010bcb2:	77 56                	ja     c010bd0a <syscall+0x80>
        if (syscalls[num] != NULL) {
c010bcb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bcb7:	8b 04 85 c0 3a 13 c0 	mov    -0x3fecc540(,%eax,4),%eax
c010bcbe:	85 c0                	test   %eax,%eax
c010bcc0:	74 48                	je     c010bd0a <syscall+0x80>
            arg[0] = tf->tf_regs.reg_edx;
c010bcc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcc5:	8b 40 14             	mov    0x14(%eax),%eax
c010bcc8:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010bccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcce:	8b 40 18             	mov    0x18(%eax),%eax
c010bcd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010bcd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcd7:	8b 40 10             	mov    0x10(%eax),%eax
c010bcda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010bcdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bce0:	8b 00                	mov    (%eax),%eax
c010bce2:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010bce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bce8:	8b 40 04             	mov    0x4(%eax),%eax
c010bceb:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010bcee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bcf1:	8b 04 85 c0 3a 13 c0 	mov    -0x3fecc540(,%eax,4),%eax
c010bcf8:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010bcfb:	89 14 24             	mov    %edx,(%esp)
c010bcfe:	ff d0                	call   *%eax
c010bd00:	89 c2                	mov    %eax,%edx
c010bd02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bd05:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010bd08:	eb 46                	jmp    c010bd50 <syscall+0xc6>
        }
    }
    print_trapframe(tf);
c010bd0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bd0d:	89 04 24             	mov    %eax,(%esp)
c010bd10:	e8 cb 67 ff ff       	call   c01024e0 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010bd15:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bd1a:	8d 50 48             	lea    0x48(%eax),%edx
c010bd1d:	a1 30 81 1b c0       	mov    0xc01b8130,%eax
c010bd22:	8b 40 04             	mov    0x4(%eax),%eax
c010bd25:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bd29:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bd2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd30:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bd34:	c7 44 24 08 90 f0 10 	movl   $0xc010f090,0x8(%esp)
c010bd3b:	c0 
c010bd3c:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c010bd43:	00 
c010bd44:	c7 04 24 bc f0 10 c0 	movl   $0xc010f0bc,(%esp)
c010bd4b:	e8 a0 50 ff ff       	call   c0100df0 <__panic>
            num, current->pid, current->name);
}
c010bd50:	89 ec                	mov    %ebp,%esp
c010bd52:	5d                   	pop    %ebp
c010bd53:	c3                   	ret    

c010bd54 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010bd54:	55                   	push   %ebp
c010bd55:	89 e5                	mov    %esp,%ebp
c010bd57:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010bd5a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd5d:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010bd63:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010bd66:	b8 20 00 00 00       	mov    $0x20,%eax
c010bd6b:	2b 45 0c             	sub    0xc(%ebp),%eax
c010bd6e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010bd71:	88 c1                	mov    %al,%cl
c010bd73:	d3 ea                	shr    %cl,%edx
c010bd75:	89 d0                	mov    %edx,%eax
}
c010bd77:	89 ec                	mov    %ebp,%esp
c010bd79:	5d                   	pop    %ebp
c010bd7a:	c3                   	ret    

c010bd7b <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010bd7b:	55                   	push   %ebp
c010bd7c:	89 e5                	mov    %esp,%ebp
c010bd7e:	83 ec 58             	sub    $0x58,%esp
c010bd81:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd84:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010bd87:	8b 45 14             	mov    0x14(%ebp),%eax
c010bd8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010bd8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010bd90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010bd93:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bd96:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010bd99:	8b 45 18             	mov    0x18(%ebp),%eax
c010bd9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bd9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bda2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bda5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bda8:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010bdab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bdae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bdb1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010bdb5:	74 1c                	je     c010bdd3 <printnum+0x58>
c010bdb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bdba:	ba 00 00 00 00       	mov    $0x0,%edx
c010bdbf:	f7 75 e4             	divl   -0x1c(%ebp)
c010bdc2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010bdc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bdc8:	ba 00 00 00 00       	mov    $0x0,%edx
c010bdcd:	f7 75 e4             	divl   -0x1c(%ebp)
c010bdd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bdd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bdd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bdd9:	f7 75 e4             	divl   -0x1c(%ebp)
c010bddc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bddf:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010bde2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bde5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bde8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bdeb:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bdee:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bdf1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010bdf4:	8b 45 18             	mov    0x18(%ebp),%eax
c010bdf7:	ba 00 00 00 00       	mov    $0x0,%edx
c010bdfc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010bdff:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010be02:	19 d1                	sbb    %edx,%ecx
c010be04:	72 4c                	jb     c010be52 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010be06:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010be09:	8d 50 ff             	lea    -0x1(%eax),%edx
c010be0c:	8b 45 20             	mov    0x20(%ebp),%eax
c010be0f:	89 44 24 18          	mov    %eax,0x18(%esp)
c010be13:	89 54 24 14          	mov    %edx,0x14(%esp)
c010be17:	8b 45 18             	mov    0x18(%ebp),%eax
c010be1a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010be1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010be21:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010be24:	89 44 24 08          	mov    %eax,0x8(%esp)
c010be28:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010be2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be33:	8b 45 08             	mov    0x8(%ebp),%eax
c010be36:	89 04 24             	mov    %eax,(%esp)
c010be39:	e8 3d ff ff ff       	call   c010bd7b <printnum>
c010be3e:	eb 1b                	jmp    c010be5b <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010be40:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be43:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be47:	8b 45 20             	mov    0x20(%ebp),%eax
c010be4a:	89 04 24             	mov    %eax,(%esp)
c010be4d:	8b 45 08             	mov    0x8(%ebp),%eax
c010be50:	ff d0                	call   *%eax
        while (-- width > 0)
c010be52:	ff 4d 1c             	decl   0x1c(%ebp)
c010be55:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010be59:	7f e5                	jg     c010be40 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010be5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010be5e:	05 e4 f1 10 c0       	add    $0xc010f1e4,%eax
c010be63:	0f b6 00             	movzbl (%eax),%eax
c010be66:	0f be c0             	movsbl %al,%eax
c010be69:	8b 55 0c             	mov    0xc(%ebp),%edx
c010be6c:	89 54 24 04          	mov    %edx,0x4(%esp)
c010be70:	89 04 24             	mov    %eax,(%esp)
c010be73:	8b 45 08             	mov    0x8(%ebp),%eax
c010be76:	ff d0                	call   *%eax
}
c010be78:	90                   	nop
c010be79:	89 ec                	mov    %ebp,%esp
c010be7b:	5d                   	pop    %ebp
c010be7c:	c3                   	ret    

c010be7d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010be7d:	55                   	push   %ebp
c010be7e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010be80:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010be84:	7e 14                	jle    c010be9a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010be86:	8b 45 08             	mov    0x8(%ebp),%eax
c010be89:	8b 00                	mov    (%eax),%eax
c010be8b:	8d 48 08             	lea    0x8(%eax),%ecx
c010be8e:	8b 55 08             	mov    0x8(%ebp),%edx
c010be91:	89 0a                	mov    %ecx,(%edx)
c010be93:	8b 50 04             	mov    0x4(%eax),%edx
c010be96:	8b 00                	mov    (%eax),%eax
c010be98:	eb 30                	jmp    c010beca <getuint+0x4d>
    }
    else if (lflag) {
c010be9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010be9e:	74 16                	je     c010beb6 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010bea0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bea3:	8b 00                	mov    (%eax),%eax
c010bea5:	8d 48 04             	lea    0x4(%eax),%ecx
c010bea8:	8b 55 08             	mov    0x8(%ebp),%edx
c010beab:	89 0a                	mov    %ecx,(%edx)
c010bead:	8b 00                	mov    (%eax),%eax
c010beaf:	ba 00 00 00 00       	mov    $0x0,%edx
c010beb4:	eb 14                	jmp    c010beca <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010beb6:	8b 45 08             	mov    0x8(%ebp),%eax
c010beb9:	8b 00                	mov    (%eax),%eax
c010bebb:	8d 48 04             	lea    0x4(%eax),%ecx
c010bebe:	8b 55 08             	mov    0x8(%ebp),%edx
c010bec1:	89 0a                	mov    %ecx,(%edx)
c010bec3:	8b 00                	mov    (%eax),%eax
c010bec5:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010beca:	5d                   	pop    %ebp
c010becb:	c3                   	ret    

c010becc <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010becc:	55                   	push   %ebp
c010becd:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010becf:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bed3:	7e 14                	jle    c010bee9 <getint+0x1d>
        return va_arg(*ap, long long);
c010bed5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bed8:	8b 00                	mov    (%eax),%eax
c010beda:	8d 48 08             	lea    0x8(%eax),%ecx
c010bedd:	8b 55 08             	mov    0x8(%ebp),%edx
c010bee0:	89 0a                	mov    %ecx,(%edx)
c010bee2:	8b 50 04             	mov    0x4(%eax),%edx
c010bee5:	8b 00                	mov    (%eax),%eax
c010bee7:	eb 28                	jmp    c010bf11 <getint+0x45>
    }
    else if (lflag) {
c010bee9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010beed:	74 12                	je     c010bf01 <getint+0x35>
        return va_arg(*ap, long);
c010beef:	8b 45 08             	mov    0x8(%ebp),%eax
c010bef2:	8b 00                	mov    (%eax),%eax
c010bef4:	8d 48 04             	lea    0x4(%eax),%ecx
c010bef7:	8b 55 08             	mov    0x8(%ebp),%edx
c010befa:	89 0a                	mov    %ecx,(%edx)
c010befc:	8b 00                	mov    (%eax),%eax
c010befe:	99                   	cltd   
c010beff:	eb 10                	jmp    c010bf11 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010bf01:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf04:	8b 00                	mov    (%eax),%eax
c010bf06:	8d 48 04             	lea    0x4(%eax),%ecx
c010bf09:	8b 55 08             	mov    0x8(%ebp),%edx
c010bf0c:	89 0a                	mov    %ecx,(%edx)
c010bf0e:	8b 00                	mov    (%eax),%eax
c010bf10:	99                   	cltd   
    }
}
c010bf11:	5d                   	pop    %ebp
c010bf12:	c3                   	ret    

c010bf13 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010bf13:	55                   	push   %ebp
c010bf14:	89 e5                	mov    %esp,%ebp
c010bf16:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010bf19:	8d 45 14             	lea    0x14(%ebp),%eax
c010bf1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010bf1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bf22:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bf26:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf29:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bf2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf30:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf34:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf37:	89 04 24             	mov    %eax,(%esp)
c010bf3a:	e8 05 00 00 00       	call   c010bf44 <vprintfmt>
    va_end(ap);
}
c010bf3f:	90                   	nop
c010bf40:	89 ec                	mov    %ebp,%esp
c010bf42:	5d                   	pop    %ebp
c010bf43:	c3                   	ret    

c010bf44 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010bf44:	55                   	push   %ebp
c010bf45:	89 e5                	mov    %esp,%ebp
c010bf47:	56                   	push   %esi
c010bf48:	53                   	push   %ebx
c010bf49:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bf4c:	eb 17                	jmp    c010bf65 <vprintfmt+0x21>
            if (ch == '\0') {
c010bf4e:	85 db                	test   %ebx,%ebx
c010bf50:	0f 84 bf 03 00 00    	je     c010c315 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010bf56:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf59:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf5d:	89 1c 24             	mov    %ebx,(%esp)
c010bf60:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf63:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bf65:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf68:	8d 50 01             	lea    0x1(%eax),%edx
c010bf6b:	89 55 10             	mov    %edx,0x10(%ebp)
c010bf6e:	0f b6 00             	movzbl (%eax),%eax
c010bf71:	0f b6 d8             	movzbl %al,%ebx
c010bf74:	83 fb 25             	cmp    $0x25,%ebx
c010bf77:	75 d5                	jne    c010bf4e <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bf79:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010bf7d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bf84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bf87:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bf8a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010bf91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bf94:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bf97:	8b 45 10             	mov    0x10(%ebp),%eax
c010bf9a:	8d 50 01             	lea    0x1(%eax),%edx
c010bf9d:	89 55 10             	mov    %edx,0x10(%ebp)
c010bfa0:	0f b6 00             	movzbl (%eax),%eax
c010bfa3:	0f b6 d8             	movzbl %al,%ebx
c010bfa6:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010bfa9:	83 f8 55             	cmp    $0x55,%eax
c010bfac:	0f 87 37 03 00 00    	ja     c010c2e9 <vprintfmt+0x3a5>
c010bfb2:	8b 04 85 08 f2 10 c0 	mov    -0x3fef0df8(,%eax,4),%eax
c010bfb9:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bfbb:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010bfbf:	eb d6                	jmp    c010bf97 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010bfc1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010bfc5:	eb d0                	jmp    c010bf97 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bfc7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010bfce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bfd1:	89 d0                	mov    %edx,%eax
c010bfd3:	c1 e0 02             	shl    $0x2,%eax
c010bfd6:	01 d0                	add    %edx,%eax
c010bfd8:	01 c0                	add    %eax,%eax
c010bfda:	01 d8                	add    %ebx,%eax
c010bfdc:	83 e8 30             	sub    $0x30,%eax
c010bfdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010bfe2:	8b 45 10             	mov    0x10(%ebp),%eax
c010bfe5:	0f b6 00             	movzbl (%eax),%eax
c010bfe8:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010bfeb:	83 fb 2f             	cmp    $0x2f,%ebx
c010bfee:	7e 38                	jle    c010c028 <vprintfmt+0xe4>
c010bff0:	83 fb 39             	cmp    $0x39,%ebx
c010bff3:	7f 33                	jg     c010c028 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010bff5:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010bff8:	eb d4                	jmp    c010bfce <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010bffa:	8b 45 14             	mov    0x14(%ebp),%eax
c010bffd:	8d 50 04             	lea    0x4(%eax),%edx
c010c000:	89 55 14             	mov    %edx,0x14(%ebp)
c010c003:	8b 00                	mov    (%eax),%eax
c010c005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010c008:	eb 1f                	jmp    c010c029 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010c00a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c00e:	79 87                	jns    c010bf97 <vprintfmt+0x53>
                width = 0;
c010c010:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010c017:	e9 7b ff ff ff       	jmp    c010bf97 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010c01c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010c023:	e9 6f ff ff ff       	jmp    c010bf97 <vprintfmt+0x53>
            goto process_precision;
c010c028:	90                   	nop

        process_precision:
            if (width < 0)
c010c029:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c02d:	0f 89 64 ff ff ff    	jns    c010bf97 <vprintfmt+0x53>
                width = precision, precision = -1;
c010c033:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010c036:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c039:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010c040:	e9 52 ff ff ff       	jmp    c010bf97 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010c045:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010c048:	e9 4a ff ff ff       	jmp    c010bf97 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010c04d:	8b 45 14             	mov    0x14(%ebp),%eax
c010c050:	8d 50 04             	lea    0x4(%eax),%edx
c010c053:	89 55 14             	mov    %edx,0x14(%ebp)
c010c056:	8b 00                	mov    (%eax),%eax
c010c058:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c05b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010c05f:	89 04 24             	mov    %eax,(%esp)
c010c062:	8b 45 08             	mov    0x8(%ebp),%eax
c010c065:	ff d0                	call   *%eax
            break;
c010c067:	e9 a4 02 00 00       	jmp    c010c310 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010c06c:	8b 45 14             	mov    0x14(%ebp),%eax
c010c06f:	8d 50 04             	lea    0x4(%eax),%edx
c010c072:	89 55 14             	mov    %edx,0x14(%ebp)
c010c075:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010c077:	85 db                	test   %ebx,%ebx
c010c079:	79 02                	jns    c010c07d <vprintfmt+0x139>
                err = -err;
c010c07b:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010c07d:	83 fb 18             	cmp    $0x18,%ebx
c010c080:	7f 0b                	jg     c010c08d <vprintfmt+0x149>
c010c082:	8b 34 9d 80 f1 10 c0 	mov    -0x3fef0e80(,%ebx,4),%esi
c010c089:	85 f6                	test   %esi,%esi
c010c08b:	75 23                	jne    c010c0b0 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010c08d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010c091:	c7 44 24 08 f5 f1 10 	movl   $0xc010f1f5,0x8(%esp)
c010c098:	c0 
c010c099:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c09c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0a0:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0a3:	89 04 24             	mov    %eax,(%esp)
c010c0a6:	e8 68 fe ff ff       	call   c010bf13 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010c0ab:	e9 60 02 00 00       	jmp    c010c310 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010c0b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010c0b4:	c7 44 24 08 fe f1 10 	movl   $0xc010f1fe,0x8(%esp)
c010c0bb:	c0 
c010c0bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0c6:	89 04 24             	mov    %eax,(%esp)
c010c0c9:	e8 45 fe ff ff       	call   c010bf13 <printfmt>
            break;
c010c0ce:	e9 3d 02 00 00       	jmp    c010c310 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010c0d3:	8b 45 14             	mov    0x14(%ebp),%eax
c010c0d6:	8d 50 04             	lea    0x4(%eax),%edx
c010c0d9:	89 55 14             	mov    %edx,0x14(%ebp)
c010c0dc:	8b 30                	mov    (%eax),%esi
c010c0de:	85 f6                	test   %esi,%esi
c010c0e0:	75 05                	jne    c010c0e7 <vprintfmt+0x1a3>
                p = "(null)";
c010c0e2:	be 01 f2 10 c0       	mov    $0xc010f201,%esi
            }
            if (width > 0 && padc != '-') {
c010c0e7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c0eb:	7e 76                	jle    c010c163 <vprintfmt+0x21f>
c010c0ed:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010c0f1:	74 70                	je     c010c163 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010c0f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010c0f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c0fa:	89 34 24             	mov    %esi,(%esp)
c010c0fd:	e8 ee 03 00 00       	call   c010c4f0 <strnlen>
c010c102:	89 c2                	mov    %eax,%edx
c010c104:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c107:	29 d0                	sub    %edx,%eax
c010c109:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c10c:	eb 16                	jmp    c010c124 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c010c10e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010c112:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c115:	89 54 24 04          	mov    %edx,0x4(%esp)
c010c119:	89 04 24             	mov    %eax,(%esp)
c010c11c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c11f:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010c121:	ff 4d e8             	decl   -0x18(%ebp)
c010c124:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c128:	7f e4                	jg     c010c10e <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010c12a:	eb 37                	jmp    c010c163 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010c12c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010c130:	74 1f                	je     c010c151 <vprintfmt+0x20d>
c010c132:	83 fb 1f             	cmp    $0x1f,%ebx
c010c135:	7e 05                	jle    c010c13c <vprintfmt+0x1f8>
c010c137:	83 fb 7e             	cmp    $0x7e,%ebx
c010c13a:	7e 15                	jle    c010c151 <vprintfmt+0x20d>
                    putch('?', putdat);
c010c13c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c13f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c143:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010c14a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c14d:	ff d0                	call   *%eax
c010c14f:	eb 0f                	jmp    c010c160 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010c151:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c154:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c158:	89 1c 24             	mov    %ebx,(%esp)
c010c15b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c15e:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010c160:	ff 4d e8             	decl   -0x18(%ebp)
c010c163:	89 f0                	mov    %esi,%eax
c010c165:	8d 70 01             	lea    0x1(%eax),%esi
c010c168:	0f b6 00             	movzbl (%eax),%eax
c010c16b:	0f be d8             	movsbl %al,%ebx
c010c16e:	85 db                	test   %ebx,%ebx
c010c170:	74 27                	je     c010c199 <vprintfmt+0x255>
c010c172:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010c176:	78 b4                	js     c010c12c <vprintfmt+0x1e8>
c010c178:	ff 4d e4             	decl   -0x1c(%ebp)
c010c17b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010c17f:	79 ab                	jns    c010c12c <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010c181:	eb 16                	jmp    c010c199 <vprintfmt+0x255>
                putch(' ', putdat);
c010c183:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c186:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c18a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010c191:	8b 45 08             	mov    0x8(%ebp),%eax
c010c194:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010c196:	ff 4d e8             	decl   -0x18(%ebp)
c010c199:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c19d:	7f e4                	jg     c010c183 <vprintfmt+0x23f>
            }
            break;
c010c19f:	e9 6c 01 00 00       	jmp    c010c310 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010c1a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c1a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c1ab:	8d 45 14             	lea    0x14(%ebp),%eax
c010c1ae:	89 04 24             	mov    %eax,(%esp)
c010c1b1:	e8 16 fd ff ff       	call   c010becc <getint>
c010c1b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c1b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010c1bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c1bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c1c2:	85 d2                	test   %edx,%edx
c010c1c4:	79 26                	jns    c010c1ec <vprintfmt+0x2a8>
                putch('-', putdat);
c010c1c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c1c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c1cd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010c1d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010c1d7:	ff d0                	call   *%eax
                num = -(long long)num;
c010c1d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c1dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c1df:	f7 d8                	neg    %eax
c010c1e1:	83 d2 00             	adc    $0x0,%edx
c010c1e4:	f7 da                	neg    %edx
c010c1e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c1e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010c1ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010c1f3:	e9 a8 00 00 00       	jmp    c010c2a0 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010c1f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c1fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c1ff:	8d 45 14             	lea    0x14(%ebp),%eax
c010c202:	89 04 24             	mov    %eax,(%esp)
c010c205:	e8 73 fc ff ff       	call   c010be7d <getuint>
c010c20a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c20d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010c210:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010c217:	e9 84 00 00 00       	jmp    c010c2a0 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010c21c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c21f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c223:	8d 45 14             	lea    0x14(%ebp),%eax
c010c226:	89 04 24             	mov    %eax,(%esp)
c010c229:	e8 4f fc ff ff       	call   c010be7d <getuint>
c010c22e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c231:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010c234:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010c23b:	eb 63                	jmp    c010c2a0 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010c23d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c240:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c244:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010c24b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c24e:	ff d0                	call   *%eax
            putch('x', putdat);
c010c250:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c253:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c257:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010c25e:	8b 45 08             	mov    0x8(%ebp),%eax
c010c261:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010c263:	8b 45 14             	mov    0x14(%ebp),%eax
c010c266:	8d 50 04             	lea    0x4(%eax),%edx
c010c269:	89 55 14             	mov    %edx,0x14(%ebp)
c010c26c:	8b 00                	mov    (%eax),%eax
c010c26e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010c278:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010c27f:	eb 1f                	jmp    c010c2a0 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010c281:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c284:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c288:	8d 45 14             	lea    0x14(%ebp),%eax
c010c28b:	89 04 24             	mov    %eax,(%esp)
c010c28e:	e8 ea fb ff ff       	call   c010be7d <getuint>
c010c293:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c296:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010c299:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010c2a0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010c2a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c2a7:	89 54 24 18          	mov    %edx,0x18(%esp)
c010c2ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c2ae:	89 54 24 14          	mov    %edx,0x14(%esp)
c010c2b2:	89 44 24 10          	mov    %eax,0x10(%esp)
c010c2b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c2b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c2bc:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c2c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010c2c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c2c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c2cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2ce:	89 04 24             	mov    %eax,(%esp)
c010c2d1:	e8 a5 fa ff ff       	call   c010bd7b <printnum>
            break;
c010c2d6:	eb 38                	jmp    c010c310 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010c2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c2db:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c2df:	89 1c 24             	mov    %ebx,(%esp)
c010c2e2:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2e5:	ff d0                	call   *%eax
            break;
c010c2e7:	eb 27                	jmp    c010c310 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010c2e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c2ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c2f0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010c2f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010c2fa:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010c2fc:	ff 4d 10             	decl   0x10(%ebp)
c010c2ff:	eb 03                	jmp    c010c304 <vprintfmt+0x3c0>
c010c301:	ff 4d 10             	decl   0x10(%ebp)
c010c304:	8b 45 10             	mov    0x10(%ebp),%eax
c010c307:	48                   	dec    %eax
c010c308:	0f b6 00             	movzbl (%eax),%eax
c010c30b:	3c 25                	cmp    $0x25,%al
c010c30d:	75 f2                	jne    c010c301 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c010c30f:	90                   	nop
    while (1) {
c010c310:	e9 37 fc ff ff       	jmp    c010bf4c <vprintfmt+0x8>
                return;
c010c315:	90                   	nop
        }
    }
}
c010c316:	83 c4 40             	add    $0x40,%esp
c010c319:	5b                   	pop    %ebx
c010c31a:	5e                   	pop    %esi
c010c31b:	5d                   	pop    %ebp
c010c31c:	c3                   	ret    

c010c31d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010c31d:	55                   	push   %ebp
c010c31e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010c320:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c323:	8b 40 08             	mov    0x8(%eax),%eax
c010c326:	8d 50 01             	lea    0x1(%eax),%edx
c010c329:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c32c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010c32f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c332:	8b 10                	mov    (%eax),%edx
c010c334:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c337:	8b 40 04             	mov    0x4(%eax),%eax
c010c33a:	39 c2                	cmp    %eax,%edx
c010c33c:	73 12                	jae    c010c350 <sprintputch+0x33>
        *b->buf ++ = ch;
c010c33e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c341:	8b 00                	mov    (%eax),%eax
c010c343:	8d 48 01             	lea    0x1(%eax),%ecx
c010c346:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c349:	89 0a                	mov    %ecx,(%edx)
c010c34b:	8b 55 08             	mov    0x8(%ebp),%edx
c010c34e:	88 10                	mov    %dl,(%eax)
    }
}
c010c350:	90                   	nop
c010c351:	5d                   	pop    %ebp
c010c352:	c3                   	ret    

c010c353 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010c353:	55                   	push   %ebp
c010c354:	89 e5                	mov    %esp,%ebp
c010c356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010c359:	8d 45 14             	lea    0x14(%ebp),%eax
c010c35c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010c35f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c362:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c366:	8b 45 10             	mov    0x10(%ebp),%eax
c010c369:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c36d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c370:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c374:	8b 45 08             	mov    0x8(%ebp),%eax
c010c377:	89 04 24             	mov    %eax,(%esp)
c010c37a:	e8 0a 00 00 00       	call   c010c389 <vsnprintf>
c010c37f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010c382:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c385:	89 ec                	mov    %ebp,%esp
c010c387:	5d                   	pop    %ebp
c010c388:	c3                   	ret    

c010c389 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010c389:	55                   	push   %ebp
c010c38a:	89 e5                	mov    %esp,%ebp
c010c38c:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010c38f:	8b 45 08             	mov    0x8(%ebp),%eax
c010c392:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c395:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c398:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c39b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c39e:	01 d0                	add    %edx,%eax
c010c3a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c3a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010c3aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010c3ae:	74 0a                	je     c010c3ba <vsnprintf+0x31>
c010c3b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c3b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c3b6:	39 c2                	cmp    %eax,%edx
c010c3b8:	76 07                	jbe    c010c3c1 <vsnprintf+0x38>
        return -E_INVAL;
c010c3ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010c3bf:	eb 2a                	jmp    c010c3eb <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010c3c1:	8b 45 14             	mov    0x14(%ebp),%eax
c010c3c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c3c8:	8b 45 10             	mov    0x10(%ebp),%eax
c010c3cb:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c3cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010c3d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c3d6:	c7 04 24 1d c3 10 c0 	movl   $0xc010c31d,(%esp)
c010c3dd:	e8 62 fb ff ff       	call   c010bf44 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010c3e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c3e5:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010c3e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c3eb:	89 ec                	mov    %ebp,%esp
c010c3ed:	5d                   	pop    %ebp
c010c3ee:	c3                   	ret    

c010c3ef <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010c3ef:	55                   	push   %ebp
c010c3f0:	89 e5                	mov    %esp,%ebp
c010c3f2:	57                   	push   %edi
c010c3f3:	56                   	push   %esi
c010c3f4:	53                   	push   %ebx
c010c3f5:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010c3f8:	a1 c0 3e 13 c0       	mov    0xc0133ec0,%eax
c010c3fd:	8b 15 c4 3e 13 c0    	mov    0xc0133ec4,%edx
c010c403:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010c409:	6b f0 05             	imul   $0x5,%eax,%esi
c010c40c:	01 fe                	add    %edi,%esi
c010c40e:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010c413:	f7 e7                	mul    %edi
c010c415:	01 d6                	add    %edx,%esi
c010c417:	89 f2                	mov    %esi,%edx
c010c419:	83 c0 0b             	add    $0xb,%eax
c010c41c:	83 d2 00             	adc    $0x0,%edx
c010c41f:	89 c7                	mov    %eax,%edi
c010c421:	83 e7 ff             	and    $0xffffffff,%edi
c010c424:	89 f9                	mov    %edi,%ecx
c010c426:	0f b7 da             	movzwl %dx,%ebx
c010c429:	89 0d c0 3e 13 c0    	mov    %ecx,0xc0133ec0
c010c42f:	89 1d c4 3e 13 c0    	mov    %ebx,0xc0133ec4
    unsigned long long result = (next >> 12);
c010c435:	a1 c0 3e 13 c0       	mov    0xc0133ec0,%eax
c010c43a:	8b 15 c4 3e 13 c0    	mov    0xc0133ec4,%edx
c010c440:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010c444:	c1 ea 0c             	shr    $0xc,%edx
c010c447:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c44a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010c44d:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010c454:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c457:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c45a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c45d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c460:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c463:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c466:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c46a:	74 1c                	je     c010c488 <rand+0x99>
c010c46c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c46f:	ba 00 00 00 00       	mov    $0x0,%edx
c010c474:	f7 75 dc             	divl   -0x24(%ebp)
c010c477:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010c47a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c47d:	ba 00 00 00 00       	mov    $0x0,%edx
c010c482:	f7 75 dc             	divl   -0x24(%ebp)
c010c485:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c488:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c48b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c48e:	f7 75 dc             	divl   -0x24(%ebp)
c010c491:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c494:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c497:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c49a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c49d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c4a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c4a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010c4a6:	83 c4 24             	add    $0x24,%esp
c010c4a9:	5b                   	pop    %ebx
c010c4aa:	5e                   	pop    %esi
c010c4ab:	5f                   	pop    %edi
c010c4ac:	5d                   	pop    %ebp
c010c4ad:	c3                   	ret    

c010c4ae <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010c4ae:	55                   	push   %ebp
c010c4af:	89 e5                	mov    %esp,%ebp
    next = seed;
c010c4b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010c4b4:	ba 00 00 00 00       	mov    $0x0,%edx
c010c4b9:	a3 c0 3e 13 c0       	mov    %eax,0xc0133ec0
c010c4be:	89 15 c4 3e 13 c0    	mov    %edx,0xc0133ec4
}
c010c4c4:	90                   	nop
c010c4c5:	5d                   	pop    %ebp
c010c4c6:	c3                   	ret    

c010c4c7 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010c4c7:	55                   	push   %ebp
c010c4c8:	89 e5                	mov    %esp,%ebp
c010c4ca:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010c4cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010c4d4:	eb 03                	jmp    c010c4d9 <strlen+0x12>
        cnt ++;
c010c4d6:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010c4d9:	8b 45 08             	mov    0x8(%ebp),%eax
c010c4dc:	8d 50 01             	lea    0x1(%eax),%edx
c010c4df:	89 55 08             	mov    %edx,0x8(%ebp)
c010c4e2:	0f b6 00             	movzbl (%eax),%eax
c010c4e5:	84 c0                	test   %al,%al
c010c4e7:	75 ed                	jne    c010c4d6 <strlen+0xf>
    }
    return cnt;
c010c4e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010c4ec:	89 ec                	mov    %ebp,%esp
c010c4ee:	5d                   	pop    %ebp
c010c4ef:	c3                   	ret    

c010c4f0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010c4f0:	55                   	push   %ebp
c010c4f1:	89 e5                	mov    %esp,%ebp
c010c4f3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010c4f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010c4fd:	eb 03                	jmp    c010c502 <strnlen+0x12>
        cnt ++;
c010c4ff:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010c502:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c505:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010c508:	73 10                	jae    c010c51a <strnlen+0x2a>
c010c50a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c50d:	8d 50 01             	lea    0x1(%eax),%edx
c010c510:	89 55 08             	mov    %edx,0x8(%ebp)
c010c513:	0f b6 00             	movzbl (%eax),%eax
c010c516:	84 c0                	test   %al,%al
c010c518:	75 e5                	jne    c010c4ff <strnlen+0xf>
    }
    return cnt;
c010c51a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010c51d:	89 ec                	mov    %ebp,%esp
c010c51f:	5d                   	pop    %ebp
c010c520:	c3                   	ret    

c010c521 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010c521:	55                   	push   %ebp
c010c522:	89 e5                	mov    %esp,%ebp
c010c524:	57                   	push   %edi
c010c525:	56                   	push   %esi
c010c526:	83 ec 20             	sub    $0x20,%esp
c010c529:	8b 45 08             	mov    0x8(%ebp),%eax
c010c52c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c52f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c532:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010c535:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010c538:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c53b:	89 d1                	mov    %edx,%ecx
c010c53d:	89 c2                	mov    %eax,%edx
c010c53f:	89 ce                	mov    %ecx,%esi
c010c541:	89 d7                	mov    %edx,%edi
c010c543:	ac                   	lods   %ds:(%esi),%al
c010c544:	aa                   	stos   %al,%es:(%edi)
c010c545:	84 c0                	test   %al,%al
c010c547:	75 fa                	jne    c010c543 <strcpy+0x22>
c010c549:	89 fa                	mov    %edi,%edx
c010c54b:	89 f1                	mov    %esi,%ecx
c010c54d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c550:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c553:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010c556:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010c559:	83 c4 20             	add    $0x20,%esp
c010c55c:	5e                   	pop    %esi
c010c55d:	5f                   	pop    %edi
c010c55e:	5d                   	pop    %ebp
c010c55f:	c3                   	ret    

c010c560 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010c560:	55                   	push   %ebp
c010c561:	89 e5                	mov    %esp,%ebp
c010c563:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010c566:	8b 45 08             	mov    0x8(%ebp),%eax
c010c569:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010c56c:	eb 1e                	jmp    c010c58c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010c56e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c571:	0f b6 10             	movzbl (%eax),%edx
c010c574:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c577:	88 10                	mov    %dl,(%eax)
c010c579:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c57c:	0f b6 00             	movzbl (%eax),%eax
c010c57f:	84 c0                	test   %al,%al
c010c581:	74 03                	je     c010c586 <strncpy+0x26>
            src ++;
c010c583:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010c586:	ff 45 fc             	incl   -0x4(%ebp)
c010c589:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010c58c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c590:	75 dc                	jne    c010c56e <strncpy+0xe>
    }
    return dst;
c010c592:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010c595:	89 ec                	mov    %ebp,%esp
c010c597:	5d                   	pop    %ebp
c010c598:	c3                   	ret    

c010c599 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010c599:	55                   	push   %ebp
c010c59a:	89 e5                	mov    %esp,%ebp
c010c59c:	57                   	push   %edi
c010c59d:	56                   	push   %esi
c010c59e:	83 ec 20             	sub    $0x20,%esp
c010c5a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010c5a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c5a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c5aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010c5ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c5b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c5b3:	89 d1                	mov    %edx,%ecx
c010c5b5:	89 c2                	mov    %eax,%edx
c010c5b7:	89 ce                	mov    %ecx,%esi
c010c5b9:	89 d7                	mov    %edx,%edi
c010c5bb:	ac                   	lods   %ds:(%esi),%al
c010c5bc:	ae                   	scas   %es:(%edi),%al
c010c5bd:	75 08                	jne    c010c5c7 <strcmp+0x2e>
c010c5bf:	84 c0                	test   %al,%al
c010c5c1:	75 f8                	jne    c010c5bb <strcmp+0x22>
c010c5c3:	31 c0                	xor    %eax,%eax
c010c5c5:	eb 04                	jmp    c010c5cb <strcmp+0x32>
c010c5c7:	19 c0                	sbb    %eax,%eax
c010c5c9:	0c 01                	or     $0x1,%al
c010c5cb:	89 fa                	mov    %edi,%edx
c010c5cd:	89 f1                	mov    %esi,%ecx
c010c5cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c5d2:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c5d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010c5d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010c5db:	83 c4 20             	add    $0x20,%esp
c010c5de:	5e                   	pop    %esi
c010c5df:	5f                   	pop    %edi
c010c5e0:	5d                   	pop    %ebp
c010c5e1:	c3                   	ret    

c010c5e2 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010c5e2:	55                   	push   %ebp
c010c5e3:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c5e5:	eb 09                	jmp    c010c5f0 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010c5e7:	ff 4d 10             	decl   0x10(%ebp)
c010c5ea:	ff 45 08             	incl   0x8(%ebp)
c010c5ed:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010c5f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c5f4:	74 1a                	je     c010c610 <strncmp+0x2e>
c010c5f6:	8b 45 08             	mov    0x8(%ebp),%eax
c010c5f9:	0f b6 00             	movzbl (%eax),%eax
c010c5fc:	84 c0                	test   %al,%al
c010c5fe:	74 10                	je     c010c610 <strncmp+0x2e>
c010c600:	8b 45 08             	mov    0x8(%ebp),%eax
c010c603:	0f b6 10             	movzbl (%eax),%edx
c010c606:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c609:	0f b6 00             	movzbl (%eax),%eax
c010c60c:	38 c2                	cmp    %al,%dl
c010c60e:	74 d7                	je     c010c5e7 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c610:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c614:	74 18                	je     c010c62e <strncmp+0x4c>
c010c616:	8b 45 08             	mov    0x8(%ebp),%eax
c010c619:	0f b6 00             	movzbl (%eax),%eax
c010c61c:	0f b6 d0             	movzbl %al,%edx
c010c61f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c622:	0f b6 00             	movzbl (%eax),%eax
c010c625:	0f b6 c8             	movzbl %al,%ecx
c010c628:	89 d0                	mov    %edx,%eax
c010c62a:	29 c8                	sub    %ecx,%eax
c010c62c:	eb 05                	jmp    c010c633 <strncmp+0x51>
c010c62e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c633:	5d                   	pop    %ebp
c010c634:	c3                   	ret    

c010c635 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010c635:	55                   	push   %ebp
c010c636:	89 e5                	mov    %esp,%ebp
c010c638:	83 ec 04             	sub    $0x4,%esp
c010c63b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c63e:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c641:	eb 13                	jmp    c010c656 <strchr+0x21>
        if (*s == c) {
c010c643:	8b 45 08             	mov    0x8(%ebp),%eax
c010c646:	0f b6 00             	movzbl (%eax),%eax
c010c649:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010c64c:	75 05                	jne    c010c653 <strchr+0x1e>
            return (char *)s;
c010c64e:	8b 45 08             	mov    0x8(%ebp),%eax
c010c651:	eb 12                	jmp    c010c665 <strchr+0x30>
        }
        s ++;
c010c653:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010c656:	8b 45 08             	mov    0x8(%ebp),%eax
c010c659:	0f b6 00             	movzbl (%eax),%eax
c010c65c:	84 c0                	test   %al,%al
c010c65e:	75 e3                	jne    c010c643 <strchr+0xe>
    }
    return NULL;
c010c660:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c665:	89 ec                	mov    %ebp,%esp
c010c667:	5d                   	pop    %ebp
c010c668:	c3                   	ret    

c010c669 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010c669:	55                   	push   %ebp
c010c66a:	89 e5                	mov    %esp,%ebp
c010c66c:	83 ec 04             	sub    $0x4,%esp
c010c66f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c672:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010c675:	eb 0e                	jmp    c010c685 <strfind+0x1c>
        if (*s == c) {
c010c677:	8b 45 08             	mov    0x8(%ebp),%eax
c010c67a:	0f b6 00             	movzbl (%eax),%eax
c010c67d:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010c680:	74 0f                	je     c010c691 <strfind+0x28>
            break;
        }
        s ++;
c010c682:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010c685:	8b 45 08             	mov    0x8(%ebp),%eax
c010c688:	0f b6 00             	movzbl (%eax),%eax
c010c68b:	84 c0                	test   %al,%al
c010c68d:	75 e8                	jne    c010c677 <strfind+0xe>
c010c68f:	eb 01                	jmp    c010c692 <strfind+0x29>
            break;
c010c691:	90                   	nop
    }
    return (char *)s;
c010c692:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010c695:	89 ec                	mov    %ebp,%esp
c010c697:	5d                   	pop    %ebp
c010c698:	c3                   	ret    

c010c699 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010c699:	55                   	push   %ebp
c010c69a:	89 e5                	mov    %esp,%ebp
c010c69c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010c69f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010c6a6:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010c6ad:	eb 03                	jmp    c010c6b2 <strtol+0x19>
        s ++;
c010c6af:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010c6b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010c6b5:	0f b6 00             	movzbl (%eax),%eax
c010c6b8:	3c 20                	cmp    $0x20,%al
c010c6ba:	74 f3                	je     c010c6af <strtol+0x16>
c010c6bc:	8b 45 08             	mov    0x8(%ebp),%eax
c010c6bf:	0f b6 00             	movzbl (%eax),%eax
c010c6c2:	3c 09                	cmp    $0x9,%al
c010c6c4:	74 e9                	je     c010c6af <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010c6c6:	8b 45 08             	mov    0x8(%ebp),%eax
c010c6c9:	0f b6 00             	movzbl (%eax),%eax
c010c6cc:	3c 2b                	cmp    $0x2b,%al
c010c6ce:	75 05                	jne    c010c6d5 <strtol+0x3c>
        s ++;
c010c6d0:	ff 45 08             	incl   0x8(%ebp)
c010c6d3:	eb 14                	jmp    c010c6e9 <strtol+0x50>
    }
    else if (*s == '-') {
c010c6d5:	8b 45 08             	mov    0x8(%ebp),%eax
c010c6d8:	0f b6 00             	movzbl (%eax),%eax
c010c6db:	3c 2d                	cmp    $0x2d,%al
c010c6dd:	75 0a                	jne    c010c6e9 <strtol+0x50>
        s ++, neg = 1;
c010c6df:	ff 45 08             	incl   0x8(%ebp)
c010c6e2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010c6e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c6ed:	74 06                	je     c010c6f5 <strtol+0x5c>
c010c6ef:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010c6f3:	75 22                	jne    c010c717 <strtol+0x7e>
c010c6f5:	8b 45 08             	mov    0x8(%ebp),%eax
c010c6f8:	0f b6 00             	movzbl (%eax),%eax
c010c6fb:	3c 30                	cmp    $0x30,%al
c010c6fd:	75 18                	jne    c010c717 <strtol+0x7e>
c010c6ff:	8b 45 08             	mov    0x8(%ebp),%eax
c010c702:	40                   	inc    %eax
c010c703:	0f b6 00             	movzbl (%eax),%eax
c010c706:	3c 78                	cmp    $0x78,%al
c010c708:	75 0d                	jne    c010c717 <strtol+0x7e>
        s += 2, base = 16;
c010c70a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010c70e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010c715:	eb 29                	jmp    c010c740 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010c717:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c71b:	75 16                	jne    c010c733 <strtol+0x9a>
c010c71d:	8b 45 08             	mov    0x8(%ebp),%eax
c010c720:	0f b6 00             	movzbl (%eax),%eax
c010c723:	3c 30                	cmp    $0x30,%al
c010c725:	75 0c                	jne    c010c733 <strtol+0x9a>
        s ++, base = 8;
c010c727:	ff 45 08             	incl   0x8(%ebp)
c010c72a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010c731:	eb 0d                	jmp    c010c740 <strtol+0xa7>
    }
    else if (base == 0) {
c010c733:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010c737:	75 07                	jne    c010c740 <strtol+0xa7>
        base = 10;
c010c739:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010c740:	8b 45 08             	mov    0x8(%ebp),%eax
c010c743:	0f b6 00             	movzbl (%eax),%eax
c010c746:	3c 2f                	cmp    $0x2f,%al
c010c748:	7e 1b                	jle    c010c765 <strtol+0xcc>
c010c74a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c74d:	0f b6 00             	movzbl (%eax),%eax
c010c750:	3c 39                	cmp    $0x39,%al
c010c752:	7f 11                	jg     c010c765 <strtol+0xcc>
            dig = *s - '0';
c010c754:	8b 45 08             	mov    0x8(%ebp),%eax
c010c757:	0f b6 00             	movzbl (%eax),%eax
c010c75a:	0f be c0             	movsbl %al,%eax
c010c75d:	83 e8 30             	sub    $0x30,%eax
c010c760:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c763:	eb 48                	jmp    c010c7ad <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010c765:	8b 45 08             	mov    0x8(%ebp),%eax
c010c768:	0f b6 00             	movzbl (%eax),%eax
c010c76b:	3c 60                	cmp    $0x60,%al
c010c76d:	7e 1b                	jle    c010c78a <strtol+0xf1>
c010c76f:	8b 45 08             	mov    0x8(%ebp),%eax
c010c772:	0f b6 00             	movzbl (%eax),%eax
c010c775:	3c 7a                	cmp    $0x7a,%al
c010c777:	7f 11                	jg     c010c78a <strtol+0xf1>
            dig = *s - 'a' + 10;
c010c779:	8b 45 08             	mov    0x8(%ebp),%eax
c010c77c:	0f b6 00             	movzbl (%eax),%eax
c010c77f:	0f be c0             	movsbl %al,%eax
c010c782:	83 e8 57             	sub    $0x57,%eax
c010c785:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c788:	eb 23                	jmp    c010c7ad <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010c78a:	8b 45 08             	mov    0x8(%ebp),%eax
c010c78d:	0f b6 00             	movzbl (%eax),%eax
c010c790:	3c 40                	cmp    $0x40,%al
c010c792:	7e 3b                	jle    c010c7cf <strtol+0x136>
c010c794:	8b 45 08             	mov    0x8(%ebp),%eax
c010c797:	0f b6 00             	movzbl (%eax),%eax
c010c79a:	3c 5a                	cmp    $0x5a,%al
c010c79c:	7f 31                	jg     c010c7cf <strtol+0x136>
            dig = *s - 'A' + 10;
c010c79e:	8b 45 08             	mov    0x8(%ebp),%eax
c010c7a1:	0f b6 00             	movzbl (%eax),%eax
c010c7a4:	0f be c0             	movsbl %al,%eax
c010c7a7:	83 e8 37             	sub    $0x37,%eax
c010c7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010c7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c7b0:	3b 45 10             	cmp    0x10(%ebp),%eax
c010c7b3:	7d 19                	jge    c010c7ce <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c010c7b5:	ff 45 08             	incl   0x8(%ebp)
c010c7b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c7bb:	0f af 45 10          	imul   0x10(%ebp),%eax
c010c7bf:	89 c2                	mov    %eax,%edx
c010c7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010c7c4:	01 d0                	add    %edx,%eax
c010c7c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010c7c9:	e9 72 ff ff ff       	jmp    c010c740 <strtol+0xa7>
            break;
c010c7ce:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010c7cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010c7d3:	74 08                	je     c010c7dd <strtol+0x144>
        *endptr = (char *) s;
c010c7d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c7d8:	8b 55 08             	mov    0x8(%ebp),%edx
c010c7db:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010c7dd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010c7e1:	74 07                	je     c010c7ea <strtol+0x151>
c010c7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c7e6:	f7 d8                	neg    %eax
c010c7e8:	eb 03                	jmp    c010c7ed <strtol+0x154>
c010c7ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010c7ed:	89 ec                	mov    %ebp,%esp
c010c7ef:	5d                   	pop    %ebp
c010c7f0:	c3                   	ret    

c010c7f1 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010c7f1:	55                   	push   %ebp
c010c7f2:	89 e5                	mov    %esp,%ebp
c010c7f4:	83 ec 28             	sub    $0x28,%esp
c010c7f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
c010c7fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c7fd:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010c800:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c010c804:	8b 45 08             	mov    0x8(%ebp),%eax
c010c807:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010c80a:	88 55 f7             	mov    %dl,-0x9(%ebp)
c010c80d:	8b 45 10             	mov    0x10(%ebp),%eax
c010c810:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010c813:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010c816:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010c81a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010c81d:	89 d7                	mov    %edx,%edi
c010c81f:	f3 aa                	rep stos %al,%es:(%edi)
c010c821:	89 fa                	mov    %edi,%edx
c010c823:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c826:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010c829:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010c82c:	8b 7d fc             	mov    -0x4(%ebp),%edi
c010c82f:	89 ec                	mov    %ebp,%esp
c010c831:	5d                   	pop    %ebp
c010c832:	c3                   	ret    

c010c833 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010c833:	55                   	push   %ebp
c010c834:	89 e5                	mov    %esp,%ebp
c010c836:	57                   	push   %edi
c010c837:	56                   	push   %esi
c010c838:	53                   	push   %ebx
c010c839:	83 ec 30             	sub    $0x30,%esp
c010c83c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c83f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c842:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c845:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c848:	8b 45 10             	mov    0x10(%ebp),%eax
c010c84b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010c84e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c851:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010c854:	73 42                	jae    c010c898 <memmove+0x65>
c010c856:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c859:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010c85c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c85f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c862:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c865:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c868:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010c86b:	c1 e8 02             	shr    $0x2,%eax
c010c86e:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010c870:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c873:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c876:	89 d7                	mov    %edx,%edi
c010c878:	89 c6                	mov    %eax,%esi
c010c87a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c87c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010c87f:	83 e1 03             	and    $0x3,%ecx
c010c882:	74 02                	je     c010c886 <memmove+0x53>
c010c884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c886:	89 f0                	mov    %esi,%eax
c010c888:	89 fa                	mov    %edi,%edx
c010c88a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010c88d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c890:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010c893:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010c896:	eb 36                	jmp    c010c8ce <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010c898:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c89b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c89e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c8a1:	01 c2                	add    %eax,%edx
c010c8a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c8a6:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010c8a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c8ac:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010c8af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c8b2:	89 c1                	mov    %eax,%ecx
c010c8b4:	89 d8                	mov    %ebx,%eax
c010c8b6:	89 d6                	mov    %edx,%esi
c010c8b8:	89 c7                	mov    %eax,%edi
c010c8ba:	fd                   	std    
c010c8bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c8bd:	fc                   	cld    
c010c8be:	89 f8                	mov    %edi,%eax
c010c8c0:	89 f2                	mov    %esi,%edx
c010c8c2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010c8c5:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010c8c8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010c8cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010c8ce:	83 c4 30             	add    $0x30,%esp
c010c8d1:	5b                   	pop    %ebx
c010c8d2:	5e                   	pop    %esi
c010c8d3:	5f                   	pop    %edi
c010c8d4:	5d                   	pop    %ebp
c010c8d5:	c3                   	ret    

c010c8d6 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010c8d6:	55                   	push   %ebp
c010c8d7:	89 e5                	mov    %esp,%ebp
c010c8d9:	57                   	push   %edi
c010c8da:	56                   	push   %esi
c010c8db:	83 ec 20             	sub    $0x20,%esp
c010c8de:	8b 45 08             	mov    0x8(%ebp),%eax
c010c8e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c8e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c8e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c8ea:	8b 45 10             	mov    0x10(%ebp),%eax
c010c8ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c8f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c8f3:	c1 e8 02             	shr    $0x2,%eax
c010c8f6:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010c8f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c8fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c8fe:	89 d7                	mov    %edx,%edi
c010c900:	89 c6                	mov    %eax,%esi
c010c902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c904:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010c907:	83 e1 03             	and    $0x3,%ecx
c010c90a:	74 02                	je     c010c90e <memcpy+0x38>
c010c90c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c90e:	89 f0                	mov    %esi,%eax
c010c910:	89 fa                	mov    %edi,%edx
c010c912:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c915:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c918:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010c91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010c91e:	83 c4 20             	add    $0x20,%esp
c010c921:	5e                   	pop    %esi
c010c922:	5f                   	pop    %edi
c010c923:	5d                   	pop    %ebp
c010c924:	c3                   	ret    

c010c925 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010c925:	55                   	push   %ebp
c010c926:	89 e5                	mov    %esp,%ebp
c010c928:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010c92b:	8b 45 08             	mov    0x8(%ebp),%eax
c010c92e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010c931:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c934:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010c937:	eb 2e                	jmp    c010c967 <memcmp+0x42>
        if (*s1 != *s2) {
c010c939:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c93c:	0f b6 10             	movzbl (%eax),%edx
c010c93f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c942:	0f b6 00             	movzbl (%eax),%eax
c010c945:	38 c2                	cmp    %al,%dl
c010c947:	74 18                	je     c010c961 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c949:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c94c:	0f b6 00             	movzbl (%eax),%eax
c010c94f:	0f b6 d0             	movzbl %al,%edx
c010c952:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c955:	0f b6 00             	movzbl (%eax),%eax
c010c958:	0f b6 c8             	movzbl %al,%ecx
c010c95b:	89 d0                	mov    %edx,%eax
c010c95d:	29 c8                	sub    %ecx,%eax
c010c95f:	eb 18                	jmp    c010c979 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010c961:	ff 45 fc             	incl   -0x4(%ebp)
c010c964:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010c967:	8b 45 10             	mov    0x10(%ebp),%eax
c010c96a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c96d:	89 55 10             	mov    %edx,0x10(%ebp)
c010c970:	85 c0                	test   %eax,%eax
c010c972:	75 c5                	jne    c010c939 <memcmp+0x14>
    }
    return 0;
c010c974:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c979:	89 ec                	mov    %ebp,%esp
c010c97b:	5d                   	pop    %ebp
c010c97c:	c3                   	ret    
