
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 1a 00       	mov    $0x1a1000,%eax
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
c0100020:	a3 00 10 1a c0       	mov    %eax,0xc01a1000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 f0 12 c0       	mov    $0xc012f000,%esp
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
c010003c:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c0100041:	2d 00 30 1a c0       	sub    $0xc01a3000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 30 1a c0 	movl   $0xc01a3000,(%esp)
c0100059:	e8 80 bf 00 00       	call   c010bfde <memset>

    cons_init();                // init the console
c010005e:	e8 fa 16 00 00       	call   c010175d <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 80 c1 10 c0 	movl   $0xc010c180,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 9c c1 10 c0 	movl   $0xc010c19c,(%esp)
c0100078:	e8 f0 02 00 00       	call   c010036d <cprintf>

    print_kerninfo();
c010007d:	e8 04 09 00 00       	call   c0100986 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 a7 00 00 00       	call   c010012e <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 82 58 00 00       	call   c010590e <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 aa 20 00 00       	call   c010213b <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 0e 22 00 00       	call   c01022a4 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 2c 89 00 00       	call   c01089c7 <vmm_init>
    proc_init();                // init process table
c010009b:	e8 ef ae 00 00       	call   c010af8f <proc_init>
    
    ide_init();                 // init ide devices
c01000a0:	e8 f2 17 00 00       	call   c0101897 <ide_init>
    swap_init();                // init swap
c01000a5:	e8 9f 6e 00 00       	call   c0106f49 <swap_init>

    clock_init();               // init clock interrupt
c01000aa:	e8 0d 0e 00 00       	call   c0100ebc <clock_init>
    intr_enable();              // enable irq interrupt
c01000af:	e8 e5 1f 00 00       	call   c0102099 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b4:	e8 97 b0 00 00       	call   c010b150 <cpu_idle>

c01000b9 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b9:	55                   	push   %ebp
c01000ba:	89 e5                	mov    %esp,%ebp
c01000bc:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c6:	00 
c01000c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ce:	00 
c01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d6:	e8 fc 0c 00 00       	call   c0100dd7 <mon_backtrace>
}
c01000db:	90                   	nop
c01000dc:	89 ec                	mov    %ebp,%esp
c01000de:	5d                   	pop    %ebp
c01000df:	c3                   	ret    

c01000e0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e0:	55                   	push   %ebp
c01000e1:	89 e5                	mov    %esp,%ebp
c01000e3:	83 ec 18             	sub    $0x18,%esp
c01000e6:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 b0 ff ff ff       	call   c01000b9 <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010010d:	89 ec                	mov    %ebp,%esp
c010010f:	5d                   	pop    %ebp
c0100110:	c3                   	ret    

c0100111 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100117:	8b 45 10             	mov    0x10(%ebp),%eax
c010011a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100121:	89 04 24             	mov    %eax,(%esp)
c0100124:	e8 b7 ff ff ff       	call   c01000e0 <grade_backtrace1>
}
c0100129:	90                   	nop
c010012a:	89 ec                	mov    %ebp,%esp
c010012c:	5d                   	pop    %ebp
c010012d:	c3                   	ret    

c010012e <grade_backtrace>:

void
grade_backtrace(void) {
c010012e:	55                   	push   %ebp
c010012f:	89 e5                	mov    %esp,%ebp
c0100131:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100134:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100139:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100140:	ff 
c0100141:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014c:	e8 c0 ff ff ff       	call   c0100111 <grade_backtrace0>
}
c0100151:	90                   	nop
c0100152:	89 ec                	mov    %ebp,%esp
c0100154:	5d                   	pop    %ebp
c0100155:	c3                   	ret    

c0100156 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100156:	55                   	push   %ebp
c0100157:	89 e5                	mov    %esp,%ebp
c0100159:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010015c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100162:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100165:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100168:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016c:	83 e0 03             	and    $0x3,%eax
c010016f:	89 c2                	mov    %eax,%edx
c0100171:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c0100176:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017e:	c7 04 24 a1 c1 10 c0 	movl   $0xc010c1a1,(%esp)
c0100185:	e8 e3 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010018a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018e:	89 c2                	mov    %eax,%edx
c0100190:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 af c1 10 c0 	movl   $0xc010c1af,(%esp)
c01001a4:	e8 c4 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	89 c2                	mov    %eax,%edx
c01001af:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bc:	c7 04 24 bd c1 10 c0 	movl   $0xc010c1bd,(%esp)
c01001c3:	e8 a5 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cc:	89 c2                	mov    %eax,%edx
c01001ce:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001d3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001db:	c7 04 24 cb c1 10 c0 	movl   $0xc010c1cb,(%esp)
c01001e2:	e8 86 01 00 00       	call   c010036d <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001eb:	89 c2                	mov    %eax,%edx
c01001ed:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c01001f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fa:	c7 04 24 d9 c1 10 c0 	movl   $0xc010c1d9,(%esp)
c0100201:	e8 67 01 00 00       	call   c010036d <cprintf>
    round ++;
c0100206:	a1 00 30 1a c0       	mov    0xc01a3000,%eax
c010020b:	40                   	inc    %eax
c010020c:	a3 00 30 1a c0       	mov    %eax,0xc01a3000
}
c0100211:	90                   	nop
c0100212:	89 ec                	mov    %ebp,%esp
c0100214:	5d                   	pop    %ebp
c0100215:	c3                   	ret    

c0100216 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100216:	55                   	push   %ebp
c0100217:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100219:	90                   	nop
c010021a:	5d                   	pop    %ebp
c010021b:	c3                   	ret    

c010021c <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021c:	55                   	push   %ebp
c010021d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021f:	90                   	nop
c0100220:	5d                   	pop    %ebp
c0100221:	c3                   	ret    

c0100222 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100222:	55                   	push   %ebp
c0100223:	89 e5                	mov    %esp,%ebp
c0100225:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100228:	e8 29 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010022d:	c7 04 24 e8 c1 10 c0 	movl   $0xc010c1e8,(%esp)
c0100234:	e8 34 01 00 00       	call   c010036d <cprintf>
    lab1_switch_to_user();
c0100239:	e8 d8 ff ff ff       	call   c0100216 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023e:	e8 13 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100243:	c7 04 24 08 c2 10 c0 	movl   $0xc010c208,(%esp)
c010024a:	e8 1e 01 00 00       	call   c010036d <cprintf>
    lab1_switch_to_kernel();
c010024f:	e8 c8 ff ff ff       	call   c010021c <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100254:	e8 fd fe ff ff       	call   c0100156 <lab1_print_cur_status>
}
c0100259:	90                   	nop
c010025a:	89 ec                	mov    %ebp,%esp
c010025c:	5d                   	pop    %ebp
c010025d:	c3                   	ret    

c010025e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010025e:	55                   	push   %ebp
c010025f:	89 e5                	mov    %esp,%ebp
c0100261:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100264:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100268:	74 13                	je     c010027d <readline+0x1f>
        cprintf("%s", prompt);
c010026a:	8b 45 08             	mov    0x8(%ebp),%eax
c010026d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100271:	c7 04 24 27 c2 10 c0 	movl   $0xc010c227,(%esp)
c0100278:	e8 f0 00 00 00       	call   c010036d <cprintf>
    }
    int i = 0, c;
c010027d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100284:	e8 73 01 00 00       	call   c01003fc <getchar>
c0100289:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010028c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100290:	79 07                	jns    c0100299 <readline+0x3b>
            return NULL;
c0100292:	b8 00 00 00 00       	mov    $0x0,%eax
c0100297:	eb 78                	jmp    c0100311 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100299:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010029d:	7e 28                	jle    c01002c7 <readline+0x69>
c010029f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002a6:	7f 1f                	jg     c01002c7 <readline+0x69>
            cputchar(c);
c01002a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ab:	89 04 24             	mov    %eax,(%esp)
c01002ae:	e8 e2 00 00 00       	call   c0100395 <cputchar>
            buf[i ++] = c;
c01002b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002b6:	8d 50 01             	lea    0x1(%eax),%edx
c01002b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002bf:	88 90 20 30 1a c0    	mov    %dl,-0x3fe5cfe0(%eax)
c01002c5:	eb 45                	jmp    c010030c <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002c7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002cb:	75 16                	jne    c01002e3 <readline+0x85>
c01002cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002d1:	7e 10                	jle    c01002e3 <readline+0x85>
            cputchar(c);
c01002d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d6:	89 04 24             	mov    %eax,(%esp)
c01002d9:	e8 b7 00 00 00       	call   c0100395 <cputchar>
            i --;
c01002de:	ff 4d f4             	decl   -0xc(%ebp)
c01002e1:	eb 29                	jmp    c010030c <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002e3:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002e7:	74 06                	je     c01002ef <readline+0x91>
c01002e9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002ed:	75 95                	jne    c0100284 <readline+0x26>
            cputchar(c);
c01002ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002f2:	89 04 24             	mov    %eax,(%esp)
c01002f5:	e8 9b 00 00 00       	call   c0100395 <cputchar>
            buf[i] = '\0';
c01002fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002fd:	05 20 30 1a c0       	add    $0xc01a3020,%eax
c0100302:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100305:	b8 20 30 1a c0       	mov    $0xc01a3020,%eax
c010030a:	eb 05                	jmp    c0100311 <readline+0xb3>
        c = getchar();
c010030c:	e9 73 ff ff ff       	jmp    c0100284 <readline+0x26>
        }
    }
}
c0100311:	89 ec                	mov    %ebp,%esp
c0100313:	5d                   	pop    %ebp
c0100314:	c3                   	ret    

c0100315 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010031b:	8b 45 08             	mov    0x8(%ebp),%eax
c010031e:	89 04 24             	mov    %eax,(%esp)
c0100321:	e8 66 14 00 00       	call   c010178c <cons_putc>
    (*cnt) ++;
c0100326:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100329:	8b 00                	mov    (%eax),%eax
c010032b:	8d 50 01             	lea    0x1(%eax),%edx
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 10                	mov    %edx,(%eax)
}
c0100333:	90                   	nop
c0100334:	89 ec                	mov    %ebp,%esp
c0100336:	5d                   	pop    %ebp
c0100337:	c3                   	ret    

c0100338 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100338:	55                   	push   %ebp
c0100339:	89 e5                	mov    %esp,%ebp
c010033b:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010033e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100345:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100348:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010034c:	8b 45 08             	mov    0x8(%ebp),%eax
c010034f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100353:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100356:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035a:	c7 04 24 15 03 10 c0 	movl   $0xc0100315,(%esp)
c0100361:	e8 cb b3 00 00       	call   c010b731 <vprintfmt>
    return cnt;
c0100366:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100369:	89 ec                	mov    %ebp,%esp
c010036b:	5d                   	pop    %ebp
c010036c:	c3                   	ret    

c010036d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010036d:	55                   	push   %ebp
c010036e:	89 e5                	mov    %esp,%ebp
c0100370:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100373:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100376:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100379:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010037c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100380:	8b 45 08             	mov    0x8(%ebp),%eax
c0100383:	89 04 24             	mov    %eax,(%esp)
c0100386:	e8 ad ff ff ff       	call   c0100338 <vcprintf>
c010038b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100391:	89 ec                	mov    %ebp,%esp
c0100393:	5d                   	pop    %ebp
c0100394:	c3                   	ret    

c0100395 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100395:	55                   	push   %ebp
c0100396:	89 e5                	mov    %esp,%ebp
c0100398:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010039b:	8b 45 08             	mov    0x8(%ebp),%eax
c010039e:	89 04 24             	mov    %eax,(%esp)
c01003a1:	e8 e6 13 00 00       	call   c010178c <cons_putc>
}
c01003a6:	90                   	nop
c01003a7:	89 ec                	mov    %ebp,%esp
c01003a9:	5d                   	pop    %ebp
c01003aa:	c3                   	ret    

c01003ab <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003ab:	55                   	push   %ebp
c01003ac:	89 e5                	mov    %esp,%ebp
c01003ae:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003b1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003b8:	eb 13                	jmp    c01003cd <cputs+0x22>
        cputch(c, &cnt);
c01003ba:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003be:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003c5:	89 04 24             	mov    %eax,(%esp)
c01003c8:	e8 48 ff ff ff       	call   c0100315 <cputch>
    while ((c = *str ++) != '\0') {
c01003cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01003d0:	8d 50 01             	lea    0x1(%eax),%edx
c01003d3:	89 55 08             	mov    %edx,0x8(%ebp)
c01003d6:	0f b6 00             	movzbl (%eax),%eax
c01003d9:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003dc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003e0:	75 d8                	jne    c01003ba <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003e9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003f0:	e8 20 ff ff ff       	call   c0100315 <cputch>
    return cnt;
c01003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003f8:	89 ec                	mov    %ebp,%esp
c01003fa:	5d                   	pop    %ebp
c01003fb:	c3                   	ret    

c01003fc <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003fc:	55                   	push   %ebp
c01003fd:	89 e5                	mov    %esp,%ebp
c01003ff:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100402:	90                   	nop
c0100403:	e8 c3 13 00 00       	call   c01017cb <cons_getc>
c0100408:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010040b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010040f:	74 f2                	je     c0100403 <getchar+0x7>
        /* do nothing */;
    return c;
c0100411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100414:	89 ec                	mov    %ebp,%esp
c0100416:	5d                   	pop    %ebp
c0100417:	c3                   	ret    

c0100418 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100418:	55                   	push   %ebp
c0100419:	89 e5                	mov    %esp,%ebp
c010041b:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010041e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100421:	8b 00                	mov    (%eax),%eax
c0100423:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100426:	8b 45 10             	mov    0x10(%ebp),%eax
c0100429:	8b 00                	mov    (%eax),%eax
c010042b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010042e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100435:	e9 ca 00 00 00       	jmp    c0100504 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c010043a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010043d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100440:	01 d0                	add    %edx,%eax
c0100442:	89 c2                	mov    %eax,%edx
c0100444:	c1 ea 1f             	shr    $0x1f,%edx
c0100447:	01 d0                	add    %edx,%eax
c0100449:	d1 f8                	sar    %eax
c010044b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010044e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100451:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100454:	eb 03                	jmp    c0100459 <stab_binsearch+0x41>
            m --;
c0100456:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100459:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010045c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010045f:	7c 1f                	jl     c0100480 <stab_binsearch+0x68>
c0100461:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100464:	89 d0                	mov    %edx,%eax
c0100466:	01 c0                	add    %eax,%eax
c0100468:	01 d0                	add    %edx,%eax
c010046a:	c1 e0 02             	shl    $0x2,%eax
c010046d:	89 c2                	mov    %eax,%edx
c010046f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100472:	01 d0                	add    %edx,%eax
c0100474:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100478:	0f b6 c0             	movzbl %al,%eax
c010047b:	39 45 14             	cmp    %eax,0x14(%ebp)
c010047e:	75 d6                	jne    c0100456 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100480:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100483:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100486:	7d 09                	jge    c0100491 <stab_binsearch+0x79>
            l = true_m + 1;
c0100488:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010048b:	40                   	inc    %eax
c010048c:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010048f:	eb 73                	jmp    c0100504 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100491:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100498:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049b:	89 d0                	mov    %edx,%eax
c010049d:	01 c0                	add    %eax,%eax
c010049f:	01 d0                	add    %edx,%eax
c01004a1:	c1 e0 02             	shl    $0x2,%eax
c01004a4:	89 c2                	mov    %eax,%edx
c01004a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a9:	01 d0                	add    %edx,%eax
c01004ab:	8b 40 08             	mov    0x8(%eax),%eax
c01004ae:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004b1:	76 11                	jbe    c01004c4 <stab_binsearch+0xac>
            *region_left = m;
c01004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b9:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004be:	40                   	inc    %eax
c01004bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004c2:	eb 40                	jmp    c0100504 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004c7:	89 d0                	mov    %edx,%eax
c01004c9:	01 c0                	add    %eax,%eax
c01004cb:	01 d0                	add    %edx,%eax
c01004cd:	c1 e0 02             	shl    $0x2,%eax
c01004d0:	89 c2                	mov    %eax,%edx
c01004d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d5:	01 d0                	add    %edx,%eax
c01004d7:	8b 40 08             	mov    0x8(%eax),%eax
c01004da:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004dd:	73 14                	jae    c01004f3 <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004e5:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e8:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ed:	48                   	dec    %eax
c01004ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004f1:	eb 11                	jmp    c0100504 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f9:	89 10                	mov    %edx,(%eax)
            l = m;
c01004fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100501:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100504:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100507:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010050a:	0f 8e 2a ff ff ff    	jle    c010043a <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100514:	75 0f                	jne    c0100525 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c0100516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100519:	8b 00                	mov    (%eax),%eax
c010051b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010051e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100521:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100523:	eb 3e                	jmp    c0100563 <stab_binsearch+0x14b>
        l = *region_right;
c0100525:	8b 45 10             	mov    0x10(%ebp),%eax
c0100528:	8b 00                	mov    (%eax),%eax
c010052a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010052d:	eb 03                	jmp    c0100532 <stab_binsearch+0x11a>
c010052f:	ff 4d fc             	decl   -0x4(%ebp)
c0100532:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100535:	8b 00                	mov    (%eax),%eax
c0100537:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c010053a:	7e 1f                	jle    c010055b <stab_binsearch+0x143>
c010053c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053f:	89 d0                	mov    %edx,%eax
c0100541:	01 c0                	add    %eax,%eax
c0100543:	01 d0                	add    %edx,%eax
c0100545:	c1 e0 02             	shl    $0x2,%eax
c0100548:	89 c2                	mov    %eax,%edx
c010054a:	8b 45 08             	mov    0x8(%ebp),%eax
c010054d:	01 d0                	add    %edx,%eax
c010054f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100553:	0f b6 c0             	movzbl %al,%eax
c0100556:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100559:	75 d4                	jne    c010052f <stab_binsearch+0x117>
        *region_left = l;
c010055b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100561:	89 10                	mov    %edx,(%eax)
}
c0100563:	90                   	nop
c0100564:	89 ec                	mov    %ebp,%esp
c0100566:	5d                   	pop    %ebp
c0100567:	c3                   	ret    

c0100568 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100568:	55                   	push   %ebp
c0100569:	89 e5                	mov    %esp,%ebp
c010056b:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010056e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100571:	c7 00 2c c2 10 c0    	movl   $0xc010c22c,(%eax)
    info->eip_line = 0;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100581:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100584:	c7 40 08 2c c2 10 c0 	movl   $0xc010c22c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010058b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058e:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100595:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100598:	8b 55 08             	mov    0x8(%ebp),%edx
c010059b:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010059e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c01005a8:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c01005af:	76 21                	jbe    c01005d2 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c01005b1:	c7 45 f4 40 ea 10 c0 	movl   $0xc010ea40,-0xc(%ebp)
        stab_end = __STAB_END__;
c01005b8:	c7 45 f0 84 53 12 c0 	movl   $0xc0125384,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005bf:	c7 45 ec 85 53 12 c0 	movl   $0xc0125385,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005c6:	c7 45 e8 46 cf 12 c0 	movl   $0xc012cf46,-0x18(%ebp)
c01005cd:	e9 e8 00 00 00       	jmp    c01006ba <debuginfo_eip+0x152>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005d2:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005d9:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01005de:	85 c0                	test   %eax,%eax
c01005e0:	74 11                	je     c01005f3 <debuginfo_eip+0x8b>
c01005e2:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01005e7:	8b 40 18             	mov    0x18(%eax),%eax
c01005ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005f1:	75 0a                	jne    c01005fd <debuginfo_eip+0x95>
            return -1;
c01005f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005f8:	e9 85 03 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100600:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100607:	00 
c0100608:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010060f:	00 
c0100610:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100614:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100617:	89 04 24             	mov    %eax,(%esp)
c010061a:	e8 bb 8c 00 00       	call   c01092da <user_mem_check>
c010061f:	85 c0                	test   %eax,%eax
c0100621:	75 0a                	jne    c010062d <debuginfo_eip+0xc5>
            return -1;
c0100623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100628:	e9 55 03 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
        }

        stabs = usd->stabs;
c010062d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100630:	8b 00                	mov    (%eax),%eax
c0100632:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100638:	8b 40 04             	mov    0x4(%eax),%eax
c010063b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c010063e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100641:	8b 40 08             	mov    0x8(%eax),%eax
c0100644:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010064a:	8b 40 0c             	mov    0xc(%eax),%eax
c010064d:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100650:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100653:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100656:	29 c8                	sub    %ecx,%eax
c0100658:	89 c2                	mov    %eax,%edx
c010065a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010065d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100664:	00 
c0100665:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100669:	89 44 24 04          	mov    %eax,0x4(%esp)
c010066d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100670:	89 04 24             	mov    %eax,(%esp)
c0100673:	e8 62 8c 00 00       	call   c01092da <user_mem_check>
c0100678:	85 c0                	test   %eax,%eax
c010067a:	75 0a                	jne    c0100686 <debuginfo_eip+0x11e>
            return -1;
c010067c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100681:	e9 fc 02 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100686:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100689:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010068c:	89 c2                	mov    %eax,%edx
c010068e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100691:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100698:	00 
c0100699:	89 54 24 08          	mov    %edx,0x8(%esp)
c010069d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006a4:	89 04 24             	mov    %eax,(%esp)
c01006a7:	e8 2e 8c 00 00       	call   c01092da <user_mem_check>
c01006ac:	85 c0                	test   %eax,%eax
c01006ae:	75 0a                	jne    c01006ba <debuginfo_eip+0x152>
            return -1;
c01006b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b5:	e9 c8 02 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006bd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c0:	76 0b                	jbe    c01006cd <debuginfo_eip+0x165>
c01006c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c5:	48                   	dec    %eax
c01006c6:	0f b6 00             	movzbl (%eax),%eax
c01006c9:	84 c0                	test   %al,%al
c01006cb:	74 0a                	je     c01006d7 <debuginfo_eip+0x16f>
        return -1;
c01006cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d2:	e9 ab 02 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006d7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006e1:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006e4:	c1 f8 02             	sar    $0x2,%eax
c01006e7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006ed:	48                   	dec    %eax
c01006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f8:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ff:	00 
c0100700:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100703:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100707:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100711:	89 04 24             	mov    %eax,(%esp)
c0100714:	e8 ff fc ff ff       	call   c0100418 <stab_binsearch>
    if (lfile == 0)
c0100719:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010071c:	85 c0                	test   %eax,%eax
c010071e:	75 0a                	jne    c010072a <debuginfo_eip+0x1c2>
        return -1;
c0100720:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100725:	e9 58 02 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010072a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100730:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100733:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100736:	8b 45 08             	mov    0x8(%ebp),%eax
c0100739:	89 44 24 10          	mov    %eax,0x10(%esp)
c010073d:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100744:	00 
c0100745:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100748:	89 44 24 08          	mov    %eax,0x8(%esp)
c010074c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010074f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100753:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100756:	89 04 24             	mov    %eax,(%esp)
c0100759:	e8 ba fc ff ff       	call   c0100418 <stab_binsearch>

    if (lfun <= rfun) {
c010075e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100761:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100764:	39 c2                	cmp    %eax,%edx
c0100766:	7f 78                	jg     c01007e0 <debuginfo_eip+0x278>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	89 c2                	mov    %eax,%edx
c010076d:	89 d0                	mov    %edx,%eax
c010076f:	01 c0                	add    %eax,%eax
c0100771:	01 d0                	add    %edx,%eax
c0100773:	c1 e0 02             	shl    $0x2,%eax
c0100776:	89 c2                	mov    %eax,%edx
c0100778:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077b:	01 d0                	add    %edx,%eax
c010077d:	8b 10                	mov    (%eax),%edx
c010077f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100782:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100785:	39 c2                	cmp    %eax,%edx
c0100787:	73 22                	jae    c01007ab <debuginfo_eip+0x243>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100789:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	89 d0                	mov    %edx,%eax
c0100790:	01 c0                	add    %eax,%eax
c0100792:	01 d0                	add    %edx,%eax
c0100794:	c1 e0 02             	shl    $0x2,%eax
c0100797:	89 c2                	mov    %eax,%edx
c0100799:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079c:	01 d0                	add    %edx,%eax
c010079e:	8b 10                	mov    (%eax),%edx
c01007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007a3:	01 c2                	add    %eax,%edx
c01007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a8:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ae:	89 c2                	mov    %eax,%edx
c01007b0:	89 d0                	mov    %edx,%eax
c01007b2:	01 c0                	add    %eax,%eax
c01007b4:	01 d0                	add    %edx,%eax
c01007b6:	c1 e0 02             	shl    $0x2,%eax
c01007b9:	89 c2                	mov    %eax,%edx
c01007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	8b 50 08             	mov    0x8(%eax),%edx
c01007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c6:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cc:	8b 40 10             	mov    0x10(%eax),%eax
c01007cf:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007db:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007de:	eb 15                	jmp    c01007f5 <debuginfo_eip+0x28d>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007e6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007f8:	8b 40 08             	mov    0x8(%eax),%eax
c01007fb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100802:	00 
c0100803:	89 04 24             	mov    %eax,(%esp)
c0100806:	e8 4b b6 00 00       	call   c010be56 <strfind>
c010080b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010080e:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100811:	29 c8                	sub    %ecx,%eax
c0100813:	89 c2                	mov    %eax,%edx
c0100815:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100818:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010081b:	8b 45 08             	mov    0x8(%ebp),%eax
c010081e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100822:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100829:	00 
c010082a:	8d 45 c8             	lea    -0x38(%ebp),%eax
c010082d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100831:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100834:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100838:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083b:	89 04 24             	mov    %eax,(%esp)
c010083e:	e8 d5 fb ff ff       	call   c0100418 <stab_binsearch>
    if (lline <= rline) {
c0100843:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100846:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100849:	39 c2                	cmp    %eax,%edx
c010084b:	7f 23                	jg     c0100870 <debuginfo_eip+0x308>
        info->eip_line = stabs[rline].n_desc;
c010084d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100850:	89 c2                	mov    %eax,%edx
c0100852:	89 d0                	mov    %edx,%eax
c0100854:	01 c0                	add    %eax,%eax
c0100856:	01 d0                	add    %edx,%eax
c0100858:	c1 e0 02             	shl    $0x2,%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100860:	01 d0                	add    %edx,%eax
c0100862:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 0c             	mov    0xc(%ebp),%eax
c010086b:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010086e:	eb 11                	jmp    c0100881 <debuginfo_eip+0x319>
        return -1;
c0100870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100875:	e9 08 01 00 00       	jmp    c0100982 <debuginfo_eip+0x41a>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010087a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010087d:	48                   	dec    %eax
c010087e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    while (lline >= lfile
c0100881:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100884:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100887:	39 c2                	cmp    %eax,%edx
c0100889:	7c 56                	jl     c01008e1 <debuginfo_eip+0x379>
           && stabs[lline].n_type != N_SOL
c010088b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010088e:	89 c2                	mov    %eax,%edx
c0100890:	89 d0                	mov    %edx,%eax
c0100892:	01 c0                	add    %eax,%eax
c0100894:	01 d0                	add    %edx,%eax
c0100896:	c1 e0 02             	shl    $0x2,%eax
c0100899:	89 c2                	mov    %eax,%edx
c010089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089e:	01 d0                	add    %edx,%eax
c01008a0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008a4:	3c 84                	cmp    $0x84,%al
c01008a6:	74 39                	je     c01008e1 <debuginfo_eip+0x379>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008ab:	89 c2                	mov    %eax,%edx
c01008ad:	89 d0                	mov    %edx,%eax
c01008af:	01 c0                	add    %eax,%eax
c01008b1:	01 d0                	add    %edx,%eax
c01008b3:	c1 e0 02             	shl    $0x2,%eax
c01008b6:	89 c2                	mov    %eax,%edx
c01008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bb:	01 d0                	add    %edx,%eax
c01008bd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c1:	3c 64                	cmp    $0x64,%al
c01008c3:	75 b5                	jne    c010087a <debuginfo_eip+0x312>
c01008c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008c8:	89 c2                	mov    %eax,%edx
c01008ca:	89 d0                	mov    %edx,%eax
c01008cc:	01 c0                	add    %eax,%eax
c01008ce:	01 d0                	add    %edx,%eax
c01008d0:	c1 e0 02             	shl    $0x2,%eax
c01008d3:	89 c2                	mov    %eax,%edx
c01008d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d8:	01 d0                	add    %edx,%eax
c01008da:	8b 40 08             	mov    0x8(%eax),%eax
c01008dd:	85 c0                	test   %eax,%eax
c01008df:	74 99                	je     c010087a <debuginfo_eip+0x312>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008e7:	39 c2                	cmp    %eax,%edx
c01008e9:	7c 42                	jl     c010092d <debuginfo_eip+0x3c5>
c01008eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008ee:	89 c2                	mov    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	01 c0                	add    %eax,%eax
c01008f4:	01 d0                	add    %edx,%eax
c01008f6:	c1 e0 02             	shl    $0x2,%eax
c01008f9:	89 c2                	mov    %eax,%edx
c01008fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008fe:	01 d0                	add    %edx,%eax
c0100900:	8b 10                	mov    (%eax),%edx
c0100902:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100905:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100908:	39 c2                	cmp    %eax,%edx
c010090a:	73 21                	jae    c010092d <debuginfo_eip+0x3c5>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010090c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010090f:	89 c2                	mov    %eax,%edx
c0100911:	89 d0                	mov    %edx,%eax
c0100913:	01 c0                	add    %eax,%eax
c0100915:	01 d0                	add    %edx,%eax
c0100917:	c1 e0 02             	shl    $0x2,%eax
c010091a:	89 c2                	mov    %eax,%edx
c010091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010091f:	01 d0                	add    %edx,%eax
c0100921:	8b 10                	mov    (%eax),%edx
c0100923:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100926:	01 c2                	add    %eax,%edx
c0100928:	8b 45 0c             	mov    0xc(%ebp),%eax
c010092b:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010092d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100930:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100933:	39 c2                	cmp    %eax,%edx
c0100935:	7d 46                	jge    c010097d <debuginfo_eip+0x415>
        for (lline = lfun + 1;
c0100937:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010093a:	40                   	inc    %eax
c010093b:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010093e:	eb 16                	jmp    c0100956 <debuginfo_eip+0x3ee>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100940:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100943:	8b 40 14             	mov    0x14(%eax),%eax
c0100946:	8d 50 01             	lea    0x1(%eax),%edx
c0100949:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094c:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c010094f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100952:	40                   	inc    %eax
c0100953:	89 45 cc             	mov    %eax,-0x34(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100956:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100959:	8b 45 d0             	mov    -0x30(%ebp),%eax
        for (lline = lfun + 1;
c010095c:	39 c2                	cmp    %eax,%edx
c010095e:	7d 1d                	jge    c010097d <debuginfo_eip+0x415>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100960:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100963:	89 c2                	mov    %eax,%edx
c0100965:	89 d0                	mov    %edx,%eax
c0100967:	01 c0                	add    %eax,%eax
c0100969:	01 d0                	add    %edx,%eax
c010096b:	c1 e0 02             	shl    $0x2,%eax
c010096e:	89 c2                	mov    %eax,%edx
c0100970:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100973:	01 d0                	add    %edx,%eax
c0100975:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100979:	3c a0                	cmp    $0xa0,%al
c010097b:	74 c3                	je     c0100940 <debuginfo_eip+0x3d8>
        }
    }
    return 0;
c010097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100982:	89 ec                	mov    %ebp,%esp
c0100984:	5d                   	pop    %ebp
c0100985:	c3                   	ret    

c0100986 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100986:	55                   	push   %ebp
c0100987:	89 e5                	mov    %esp,%ebp
c0100989:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010098c:	c7 04 24 36 c2 10 c0 	movl   $0xc010c236,(%esp)
c0100993:	e8 d5 f9 ff ff       	call   c010036d <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100998:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c010099f:	c0 
c01009a0:	c7 04 24 4f c2 10 c0 	movl   $0xc010c24f,(%esp)
c01009a7:	e8 c1 f9 ff ff       	call   c010036d <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009ac:	c7 44 24 04 6a c1 10 	movl   $0xc010c16a,0x4(%esp)
c01009b3:	c0 
c01009b4:	c7 04 24 67 c2 10 c0 	movl   $0xc010c267,(%esp)
c01009bb:	e8 ad f9 ff ff       	call   c010036d <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009c0:	c7 44 24 04 00 30 1a 	movl   $0xc01a3000,0x4(%esp)
c01009c7:	c0 
c01009c8:	c7 04 24 7f c2 10 c0 	movl   $0xc010c27f,(%esp)
c01009cf:	e8 99 f9 ff ff       	call   c010036d <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009d4:	c7 44 24 04 54 61 1a 	movl   $0xc01a6154,0x4(%esp)
c01009db:	c0 
c01009dc:	c7 04 24 97 c2 10 c0 	movl   $0xc010c297,(%esp)
c01009e3:	e8 85 f9 ff ff       	call   c010036d <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009e8:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c01009ed:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009f2:	05 ff 03 00 00       	add    $0x3ff,%eax
c01009f7:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009fd:	85 c0                	test   %eax,%eax
c01009ff:	0f 48 c2             	cmovs  %edx,%eax
c0100a02:	c1 f8 0a             	sar    $0xa,%eax
c0100a05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a09:	c7 04 24 b0 c2 10 c0 	movl   $0xc010c2b0,(%esp)
c0100a10:	e8 58 f9 ff ff       	call   c010036d <cprintf>
}
c0100a15:	90                   	nop
c0100a16:	89 ec                	mov    %ebp,%esp
c0100a18:	5d                   	pop    %ebp
c0100a19:	c3                   	ret    

c0100a1a <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a1a:	55                   	push   %ebp
c0100a1b:	89 e5                	mov    %esp,%ebp
c0100a1d:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a23:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a2d:	89 04 24             	mov    %eax,(%esp)
c0100a30:	e8 33 fb ff ff       	call   c0100568 <debuginfo_eip>
c0100a35:	85 c0                	test   %eax,%eax
c0100a37:	74 15                	je     c0100a4e <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a39:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a40:	c7 04 24 da c2 10 c0 	movl   $0xc010c2da,(%esp)
c0100a47:	e8 21 f9 ff ff       	call   c010036d <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a4c:	eb 6c                	jmp    c0100aba <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a55:	eb 1b                	jmp    c0100a72 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5d:	01 d0                	add    %edx,%eax
c0100a5f:	0f b6 10             	movzbl (%eax),%edx
c0100a62:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6b:	01 c8                	add    %ecx,%eax
c0100a6d:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a6f:	ff 45 f4             	incl   -0xc(%ebp)
c0100a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a75:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a78:	7c dd                	jl     c0100a57 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c0100a7a:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a83:	01 d0                	add    %edx,%eax
c0100a85:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a88:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8e:	29 d0                	sub    %edx,%eax
c0100a90:	89 c1                	mov    %eax,%ecx
c0100a92:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a95:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a98:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a9c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aa2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aa6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aae:	c7 04 24 f6 c2 10 c0 	movl   $0xc010c2f6,(%esp)
c0100ab5:	e8 b3 f8 ff ff       	call   c010036d <cprintf>
}
c0100aba:	90                   	nop
c0100abb:	89 ec                	mov    %ebp,%esp
c0100abd:	5d                   	pop    %ebp
c0100abe:	c3                   	ret    

c0100abf <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100abf:	55                   	push   %ebp
c0100ac0:	89 e5                	mov    %esp,%ebp
c0100ac2:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100ac5:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ac8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100acb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ace:	89 ec                	mov    %ebp,%esp
c0100ad0:	5d                   	pop    %ebp
c0100ad1:	c3                   	ret    

c0100ad2 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ad2:	55                   	push   %ebp
c0100ad3:	89 e5                	mov    %esp,%ebp
c0100ad5:	83 ec 38             	sub    $0x38,%esp
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t eip, ebp;
    eip = read_eip();
c0100ad8:	e8 e2 ff ff ff       	call   c0100abf <read_eip>
c0100add:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae0:	89 e8                	mov    %ebp,%eax
c0100ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100ae5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    ebp = read_ebp();
c0100ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100aeb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100af2:	eb 7e                	jmp    c0100b72 <print_stackframe+0xa0>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b02:	c7 04 24 08 c3 10 c0 	movl   $0xc010c308,(%esp)
c0100b09:	e8 5f f8 ff ff       	call   c010036d <cprintf>
        for (j = 0; j < 4; j++)
c0100b0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b15:	eb 27                	jmp    c0100b3e <print_stackframe+0x6c>
        {
            cprintf("0x%08x ", ((uint32_t *)ebp + 2)[j]);
c0100b17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b24:	01 d0                	add    %edx,%eax
c0100b26:	83 c0 08             	add    $0x8,%eax
c0100b29:	8b 00                	mov    (%eax),%eax
c0100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b2f:	c7 04 24 24 c3 10 c0 	movl   $0xc010c324,(%esp)
c0100b36:	e8 32 f8 ff ff       	call   c010036d <cprintf>
        for (j = 0; j < 4; j++)
c0100b3b:	ff 45 e8             	incl   -0x18(%ebp)
c0100b3e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b42:	7e d3                	jle    c0100b17 <print_stackframe+0x45>
        }
        cprintf("\n");
c0100b44:	c7 04 24 2c c3 10 c0 	movl   $0xc010c32c,(%esp)
c0100b4b:	e8 1d f8 ff ff       	call   c010036d <cprintf>
        print_debuginfo(eip - 1);
c0100b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b53:	48                   	dec    %eax
c0100b54:	89 04 24             	mov    %eax,(%esp)
c0100b57:	e8 be fe ff ff       	call   c0100a1a <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b5f:	83 c0 04             	add    $0x4,%eax
c0100b62:	8b 00                	mov    (%eax),%eax
c0100b64:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b6a:	8b 00                	mov    (%eax),%eax
c0100b6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100b6f:	ff 45 ec             	incl   -0x14(%ebp)
c0100b72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b76:	74 0a                	je     c0100b82 <print_stackframe+0xb0>
c0100b78:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b7c:	0f 8e 72 ff ff ff    	jle    c0100af4 <print_stackframe+0x22>
    }
	cprintf("What the fuck?");
c0100b82:	c7 04 24 2e c3 10 c0 	movl   $0xc010c32e,(%esp)
c0100b89:	e8 df f7 ff ff       	call   c010036d <cprintf>
}
c0100b8e:	90                   	nop
c0100b8f:	89 ec                	mov    %ebp,%esp
c0100b91:	5d                   	pop    %ebp
c0100b92:	c3                   	ret    

c0100b93 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b93:	55                   	push   %ebp
c0100b94:	89 e5                	mov    %esp,%ebp
c0100b96:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ba0:	eb 0c                	jmp    c0100bae <parse+0x1b>
            *buf ++ = '\0';
c0100ba2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba5:	8d 50 01             	lea    0x1(%eax),%edx
c0100ba8:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bab:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb1:	0f b6 00             	movzbl (%eax),%eax
c0100bb4:	84 c0                	test   %al,%al
c0100bb6:	74 1d                	je     c0100bd5 <parse+0x42>
c0100bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbb:	0f b6 00             	movzbl (%eax),%eax
c0100bbe:	0f be c0             	movsbl %al,%eax
c0100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bc5:	c7 04 24 c0 c3 10 c0 	movl   $0xc010c3c0,(%esp)
c0100bcc:	e8 51 b2 00 00       	call   c010be22 <strchr>
c0100bd1:	85 c0                	test   %eax,%eax
c0100bd3:	75 cd                	jne    c0100ba2 <parse+0xf>
        }
        if (*buf == '\0') {
c0100bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd8:	0f b6 00             	movzbl (%eax),%eax
c0100bdb:	84 c0                	test   %al,%al
c0100bdd:	74 65                	je     c0100c44 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bdf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100be3:	75 14                	jne    c0100bf9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100be5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bec:	00 
c0100bed:	c7 04 24 c5 c3 10 c0 	movl   $0xc010c3c5,(%esp)
c0100bf4:	e8 74 f7 ff ff       	call   c010036d <cprintf>
        }
        argv[argc ++] = buf;
c0100bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bfc:	8d 50 01             	lea    0x1(%eax),%edx
c0100bff:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c0c:	01 c2                	add    %eax,%edx
c0100c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c11:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c13:	eb 03                	jmp    c0100c18 <parse+0x85>
            buf ++;
c0100c15:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1b:	0f b6 00             	movzbl (%eax),%eax
c0100c1e:	84 c0                	test   %al,%al
c0100c20:	74 8c                	je     c0100bae <parse+0x1b>
c0100c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c25:	0f b6 00             	movzbl (%eax),%eax
c0100c28:	0f be c0             	movsbl %al,%eax
c0100c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c2f:	c7 04 24 c0 c3 10 c0 	movl   $0xc010c3c0,(%esp)
c0100c36:	e8 e7 b1 00 00       	call   c010be22 <strchr>
c0100c3b:	85 c0                	test   %eax,%eax
c0100c3d:	74 d6                	je     c0100c15 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c3f:	e9 6a ff ff ff       	jmp    c0100bae <parse+0x1b>
            break;
c0100c44:	90                   	nop
        }
    }
    return argc;
c0100c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c48:	89 ec                	mov    %ebp,%esp
c0100c4a:	5d                   	pop    %ebp
c0100c4b:	c3                   	ret    

c0100c4c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c4c:	55                   	push   %ebp
c0100c4d:	89 e5                	mov    %esp,%ebp
c0100c4f:	83 ec 68             	sub    $0x68,%esp
c0100c52:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c55:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c5f:	89 04 24             	mov    %eax,(%esp)
c0100c62:	e8 2c ff ff ff       	call   c0100b93 <parse>
c0100c67:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c6e:	75 0a                	jne    c0100c7a <runcmd+0x2e>
        return 0;
c0100c70:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c75:	e9 83 00 00 00       	jmp    c0100cfd <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c81:	eb 5a                	jmp    c0100cdd <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c83:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100c86:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c89:	89 c8                	mov    %ecx,%eax
c0100c8b:	01 c0                	add    %eax,%eax
c0100c8d:	01 c8                	add    %ecx,%eax
c0100c8f:	c1 e0 02             	shl    $0x2,%eax
c0100c92:	05 00 f0 12 c0       	add    $0xc012f000,%eax
c0100c97:	8b 00                	mov    (%eax),%eax
c0100c99:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100c9d:	89 04 24             	mov    %eax,(%esp)
c0100ca0:	e8 e1 b0 00 00       	call   c010bd86 <strcmp>
c0100ca5:	85 c0                	test   %eax,%eax
c0100ca7:	75 31                	jne    c0100cda <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cac:	89 d0                	mov    %edx,%eax
c0100cae:	01 c0                	add    %eax,%eax
c0100cb0:	01 d0                	add    %edx,%eax
c0100cb2:	c1 e0 02             	shl    $0x2,%eax
c0100cb5:	05 08 f0 12 c0       	add    $0xc012f008,%eax
c0100cba:	8b 10                	mov    (%eax),%edx
c0100cbc:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100cbf:	83 c0 04             	add    $0x4,%eax
c0100cc2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100cc5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100ccb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cd3:	89 1c 24             	mov    %ebx,(%esp)
c0100cd6:	ff d2                	call   *%edx
c0100cd8:	eb 23                	jmp    c0100cfd <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cda:	ff 45 f4             	incl   -0xc(%ebp)
c0100cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ce0:	83 f8 02             	cmp    $0x2,%eax
c0100ce3:	76 9e                	jbe    c0100c83 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ce5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cec:	c7 04 24 e3 c3 10 c0 	movl   $0xc010c3e3,(%esp)
c0100cf3:	e8 75 f6 ff ff       	call   c010036d <cprintf>
    return 0;
c0100cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100d00:	89 ec                	mov    %ebp,%esp
c0100d02:	5d                   	pop    %ebp
c0100d03:	c3                   	ret    

c0100d04 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d04:	55                   	push   %ebp
c0100d05:	89 e5                	mov    %esp,%ebp
c0100d07:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d0a:	c7 04 24 fc c3 10 c0 	movl   $0xc010c3fc,(%esp)
c0100d11:	e8 57 f6 ff ff       	call   c010036d <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d16:	c7 04 24 24 c4 10 c0 	movl   $0xc010c424,(%esp)
c0100d1d:	e8 4b f6 ff ff       	call   c010036d <cprintf>

    if (tf != NULL) {
c0100d22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d26:	74 0b                	je     c0100d33 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d28:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d2b:	89 04 24             	mov    %eax,(%esp)
c0100d2e:	e8 aa 17 00 00       	call   c01024dd <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d33:	c7 04 24 49 c4 10 c0 	movl   $0xc010c449,(%esp)
c0100d3a:	e8 1f f5 ff ff       	call   c010025e <readline>
c0100d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d46:	74 eb                	je     c0100d33 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d52:	89 04 24             	mov    %eax,(%esp)
c0100d55:	e8 f2 fe ff ff       	call   c0100c4c <runcmd>
c0100d5a:	85 c0                	test   %eax,%eax
c0100d5c:	78 02                	js     c0100d60 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100d5e:	eb d3                	jmp    c0100d33 <kmonitor+0x2f>
                break;
c0100d60:	90                   	nop
            }
        }
    }
}
c0100d61:	90                   	nop
c0100d62:	89 ec                	mov    %ebp,%esp
c0100d64:	5d                   	pop    %ebp
c0100d65:	c3                   	ret    

c0100d66 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d66:	55                   	push   %ebp
c0100d67:	89 e5                	mov    %esp,%ebp
c0100d69:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d73:	eb 3d                	jmp    c0100db2 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d75:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d78:	89 d0                	mov    %edx,%eax
c0100d7a:	01 c0                	add    %eax,%eax
c0100d7c:	01 d0                	add    %edx,%eax
c0100d7e:	c1 e0 02             	shl    $0x2,%eax
c0100d81:	05 04 f0 12 c0       	add    $0xc012f004,%eax
c0100d86:	8b 10                	mov    (%eax),%edx
c0100d88:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100d8b:	89 c8                	mov    %ecx,%eax
c0100d8d:	01 c0                	add    %eax,%eax
c0100d8f:	01 c8                	add    %ecx,%eax
c0100d91:	c1 e0 02             	shl    $0x2,%eax
c0100d94:	05 00 f0 12 c0       	add    $0xc012f000,%eax
c0100d99:	8b 00                	mov    (%eax),%eax
c0100d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100da3:	c7 04 24 4d c4 10 c0 	movl   $0xc010c44d,(%esp)
c0100daa:	e8 be f5 ff ff       	call   c010036d <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100daf:	ff 45 f4             	incl   -0xc(%ebp)
c0100db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100db5:	83 f8 02             	cmp    $0x2,%eax
c0100db8:	76 bb                	jbe    c0100d75 <mon_help+0xf>
    }
    return 0;
c0100dba:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dbf:	89 ec                	mov    %ebp,%esp
c0100dc1:	5d                   	pop    %ebp
c0100dc2:	c3                   	ret    

c0100dc3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dc3:	55                   	push   %ebp
c0100dc4:	89 e5                	mov    %esp,%ebp
c0100dc6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dc9:	e8 b8 fb ff ff       	call   c0100986 <print_kerninfo>
    return 0;
c0100dce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd3:	89 ec                	mov    %ebp,%esp
c0100dd5:	5d                   	pop    %ebp
c0100dd6:	c3                   	ret    

c0100dd7 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dd7:	55                   	push   %ebp
c0100dd8:	89 e5                	mov    %esp,%ebp
c0100dda:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100ddd:	e8 f0 fc ff ff       	call   c0100ad2 <print_stackframe>
    return 0;
c0100de2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100de7:	89 ec                	mov    %ebp,%esp
c0100de9:	5d                   	pop    %ebp
c0100dea:	c3                   	ret    

c0100deb <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100deb:	55                   	push   %ebp
c0100dec:	89 e5                	mov    %esp,%ebp
c0100dee:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100df1:	a1 20 34 1a c0       	mov    0xc01a3420,%eax
c0100df6:	85 c0                	test   %eax,%eax
c0100df8:	75 5b                	jne    c0100e55 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100dfa:	c7 05 20 34 1a c0 01 	movl   $0x1,0xc01a3420
c0100e01:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100e04:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e11:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e18:	c7 04 24 56 c4 10 c0 	movl   $0xc010c456,(%esp)
c0100e1f:	e8 49 f5 ff ff       	call   c010036d <cprintf>
    vcprintf(fmt, ap);
c0100e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e2b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e2e:	89 04 24             	mov    %eax,(%esp)
c0100e31:	e8 02 f5 ff ff       	call   c0100338 <vcprintf>
    cprintf("\n");
c0100e36:	c7 04 24 72 c4 10 c0 	movl   $0xc010c472,(%esp)
c0100e3d:	e8 2b f5 ff ff       	call   c010036d <cprintf>
    
    cprintf("stack trackback:\n");
c0100e42:	c7 04 24 74 c4 10 c0 	movl   $0xc010c474,(%esp)
c0100e49:	e8 1f f5 ff ff       	call   c010036d <cprintf>
    print_stackframe();
c0100e4e:	e8 7f fc ff ff       	call   c0100ad2 <print_stackframe>
c0100e53:	eb 01                	jmp    c0100e56 <__panic+0x6b>
        goto panic_dead;
c0100e55:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100e56:	e8 46 12 00 00       	call   c01020a1 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e62:	e8 9d fe ff ff       	call   c0100d04 <kmonitor>
c0100e67:	eb f2                	jmp    c0100e5b <__panic+0x70>

c0100e69 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e69:	55                   	push   %ebp
c0100e6a:	89 e5                	mov    %esp,%ebp
c0100e6c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e6f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e72:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e75:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e78:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e83:	c7 04 24 86 c4 10 c0 	movl   $0xc010c486,(%esp)
c0100e8a:	e8 de f4 ff ff       	call   c010036d <cprintf>
    vcprintf(fmt, ap);
c0100e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e96:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e99:	89 04 24             	mov    %eax,(%esp)
c0100e9c:	e8 97 f4 ff ff       	call   c0100338 <vcprintf>
    cprintf("\n");
c0100ea1:	c7 04 24 72 c4 10 c0 	movl   $0xc010c472,(%esp)
c0100ea8:	e8 c0 f4 ff ff       	call   c010036d <cprintf>
    va_end(ap);
}
c0100ead:	90                   	nop
c0100eae:	89 ec                	mov    %ebp,%esp
c0100eb0:	5d                   	pop    %ebp
c0100eb1:	c3                   	ret    

c0100eb2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100eb2:	55                   	push   %ebp
c0100eb3:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100eb5:	a1 20 34 1a c0       	mov    0xc01a3420,%eax
}
c0100eba:	5d                   	pop    %ebp
c0100ebb:	c3                   	ret    

c0100ebc <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ebc:	55                   	push   %ebp
c0100ebd:	89 e5                	mov    %esp,%ebp
c0100ebf:	83 ec 28             	sub    $0x28,%esp
c0100ec2:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100ec8:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ecc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100ed0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ed4:	ee                   	out    %al,(%dx)
}
c0100ed5:	90                   	nop
c0100ed6:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100edc:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ee4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ee8:	ee                   	out    %al,(%dx)
}
c0100ee9:	90                   	nop
c0100eea:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100ef0:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ef4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ef8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100efc:	ee                   	out    %al,(%dx)
}
c0100efd:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100efe:	c7 05 24 34 1a c0 00 	movl   $0x0,0xc01a3424
c0100f05:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100f08:	c7 04 24 a4 c4 10 c0 	movl   $0xc010c4a4,(%esp)
c0100f0f:	e8 59 f4 ff ff       	call   c010036d <cprintf>
    pic_enable(IRQ_TIMER);
c0100f14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100f1b:	e8 e6 11 00 00       	call   c0102106 <pic_enable>
}
c0100f20:	90                   	nop
c0100f21:	89 ec                	mov    %ebp,%esp
c0100f23:	5d                   	pop    %ebp
c0100f24:	c3                   	ret    

c0100f25 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100f25:	55                   	push   %ebp
c0100f26:	89 e5                	mov    %esp,%ebp
c0100f28:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100f2b:	9c                   	pushf  
c0100f2c:	58                   	pop    %eax
c0100f2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f33:	25 00 02 00 00       	and    $0x200,%eax
c0100f38:	85 c0                	test   %eax,%eax
c0100f3a:	74 0c                	je     c0100f48 <__intr_save+0x23>
        intr_disable();
c0100f3c:	e8 60 11 00 00       	call   c01020a1 <intr_disable>
        return 1;
c0100f41:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f46:	eb 05                	jmp    c0100f4d <__intr_save+0x28>
    }
    return 0;
c0100f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f4d:	89 ec                	mov    %ebp,%esp
c0100f4f:	5d                   	pop    %ebp
c0100f50:	c3                   	ret    

c0100f51 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f51:	55                   	push   %ebp
c0100f52:	89 e5                	mov    %esp,%ebp
c0100f54:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f57:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f5b:	74 05                	je     c0100f62 <__intr_restore+0x11>
        intr_enable();
c0100f5d:	e8 37 11 00 00       	call   c0102099 <intr_enable>
    }
}
c0100f62:	90                   	nop
c0100f63:	89 ec                	mov    %ebp,%esp
c0100f65:	5d                   	pop    %ebp
c0100f66:	c3                   	ret    

c0100f67 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f67:	55                   	push   %ebp
c0100f68:	89 e5                	mov    %esp,%ebp
c0100f6a:	83 ec 10             	sub    $0x10,%esp
c0100f6d:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f73:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f77:	89 c2                	mov    %eax,%edx
c0100f79:	ec                   	in     (%dx),%al
c0100f7a:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100f7d:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f83:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f87:	89 c2                	mov    %eax,%edx
c0100f89:	ec                   	in     (%dx),%al
c0100f8a:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100f8d:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f93:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f97:	89 c2                	mov    %eax,%edx
c0100f99:	ec                   	in     (%dx),%al
c0100f9a:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f9d:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100fa3:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100fa7:	89 c2                	mov    %eax,%edx
c0100fa9:	ec                   	in     (%dx),%al
c0100faa:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100fad:	90                   	nop
c0100fae:	89 ec                	mov    %ebp,%esp
c0100fb0:	5d                   	pop    %ebp
c0100fb1:	c3                   	ret    

c0100fb2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100fb2:	55                   	push   %ebp
c0100fb3:	89 e5                	mov    %esp,%ebp
c0100fb5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100fb8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100fbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc2:	0f b7 00             	movzwl (%eax),%eax
c0100fc5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100fc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fcc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100fd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fd4:	0f b7 00             	movzwl (%eax),%eax
c0100fd7:	0f b7 c0             	movzwl %ax,%eax
c0100fda:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100fdf:	74 12                	je     c0100ff3 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fe1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100fe8:	66 c7 05 46 34 1a c0 	movw   $0x3b4,0xc01a3446
c0100fef:	b4 03 
c0100ff1:	eb 13                	jmp    c0101006 <cga_init+0x54>
    } else {
        *cp = was;
c0100ff3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ff6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ffa:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ffd:	66 c7 05 46 34 1a c0 	movw   $0x3d4,0xc01a3446
c0101004:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101006:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c010100d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101011:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101015:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101019:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010101d:	ee                   	out    %al,(%dx)
}
c010101e:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c010101f:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0101026:	40                   	inc    %eax
c0101027:	0f b7 c0             	movzwl %ax,%eax
c010102a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101032:	89 c2                	mov    %eax,%edx
c0101034:	ec                   	in     (%dx),%al
c0101035:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0101038:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010103c:	0f b6 c0             	movzbl %al,%eax
c010103f:	c1 e0 08             	shl    $0x8,%eax
c0101042:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101045:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c010104c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101050:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101054:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101058:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010105c:	ee                   	out    %al,(%dx)
}
c010105d:	90                   	nop
    pos |= inb(addr_6845 + 1);
c010105e:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c0101065:	40                   	inc    %eax
c0101066:	0f b7 c0             	movzwl %ax,%eax
c0101069:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010106d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101071:	89 c2                	mov    %eax,%edx
c0101073:	ec                   	in     (%dx),%al
c0101074:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0101077:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010107b:	0f b6 c0             	movzbl %al,%eax
c010107e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0101081:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101084:	a3 40 34 1a c0       	mov    %eax,0xc01a3440
    crt_pos = pos;
c0101089:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010108c:	0f b7 c0             	movzwl %ax,%eax
c010108f:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
}
c0101095:	90                   	nop
c0101096:	89 ec                	mov    %ebp,%esp
c0101098:	5d                   	pop    %ebp
c0101099:	c3                   	ret    

c010109a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010109a:	55                   	push   %ebp
c010109b:	89 e5                	mov    %esp,%ebp
c010109d:	83 ec 48             	sub    $0x48,%esp
c01010a0:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c01010a6:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010aa:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01010ae:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01010b2:	ee                   	out    %al,(%dx)
}
c01010b3:	90                   	nop
c01010b4:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c01010ba:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010be:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01010c2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
}
c01010c7:	90                   	nop
c01010c8:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c01010ce:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010d2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01010d6:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01010da:	ee                   	out    %al,(%dx)
}
c01010db:	90                   	nop
c01010dc:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c01010e2:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010e6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01010ea:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01010ee:	ee                   	out    %al,(%dx)
}
c01010ef:	90                   	nop
c01010f0:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c01010f6:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010fa:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01010fe:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101102:	ee                   	out    %al,(%dx)
}
c0101103:	90                   	nop
c0101104:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010110a:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010110e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101112:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101116:	ee                   	out    %al,(%dx)
}
c0101117:	90                   	nop
c0101118:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010111e:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101122:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101126:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010112a:	ee                   	out    %al,(%dx)
}
c010112b:	90                   	nop
c010112c:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101132:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101136:	89 c2                	mov    %eax,%edx
c0101138:	ec                   	in     (%dx),%al
c0101139:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010113c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101140:	3c ff                	cmp    $0xff,%al
c0101142:	0f 95 c0             	setne  %al
c0101145:	0f b6 c0             	movzbl %al,%eax
c0101148:	a3 48 34 1a c0       	mov    %eax,0xc01a3448
c010114d:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101153:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101157:	89 c2                	mov    %eax,%edx
c0101159:	ec                   	in     (%dx),%al
c010115a:	88 45 f1             	mov    %al,-0xf(%ebp)
c010115d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101163:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101167:	89 c2                	mov    %eax,%edx
c0101169:	ec                   	in     (%dx),%al
c010116a:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010116d:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c0101172:	85 c0                	test   %eax,%eax
c0101174:	74 0c                	je     c0101182 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101176:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010117d:	e8 84 0f 00 00       	call   c0102106 <pic_enable>
    }
}
c0101182:	90                   	nop
c0101183:	89 ec                	mov    %ebp,%esp
c0101185:	5d                   	pop    %ebp
c0101186:	c3                   	ret    

c0101187 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101187:	55                   	push   %ebp
c0101188:	89 e5                	mov    %esp,%ebp
c010118a:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010118d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101194:	eb 08                	jmp    c010119e <lpt_putc_sub+0x17>
        delay();
c0101196:	e8 cc fd ff ff       	call   c0100f67 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010119b:	ff 45 fc             	incl   -0x4(%ebp)
c010119e:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01011a4:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01011a8:	89 c2                	mov    %eax,%edx
c01011aa:	ec                   	in     (%dx),%al
c01011ab:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01011ae:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01011b2:	84 c0                	test   %al,%al
c01011b4:	78 09                	js     c01011bf <lpt_putc_sub+0x38>
c01011b6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01011bd:	7e d7                	jle    c0101196 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01011bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01011c2:	0f b6 c0             	movzbl %al,%eax
c01011c5:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01011cb:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011ce:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011d2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011d6:	ee                   	out    %al,(%dx)
}
c01011d7:	90                   	nop
c01011d8:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01011de:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011e2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011e6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011ea:	ee                   	out    %al,(%dx)
}
c01011eb:	90                   	nop
c01011ec:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01011f2:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011f6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011fa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011fe:	ee                   	out    %al,(%dx)
}
c01011ff:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101200:	90                   	nop
c0101201:	89 ec                	mov    %ebp,%esp
c0101203:	5d                   	pop    %ebp
c0101204:	c3                   	ret    

c0101205 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101205:	55                   	push   %ebp
c0101206:	89 e5                	mov    %esp,%ebp
c0101208:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010120b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010120f:	74 0d                	je     c010121e <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101211:	8b 45 08             	mov    0x8(%ebp),%eax
c0101214:	89 04 24             	mov    %eax,(%esp)
c0101217:	e8 6b ff ff ff       	call   c0101187 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010121c:	eb 24                	jmp    c0101242 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010121e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101225:	e8 5d ff ff ff       	call   c0101187 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010122a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101231:	e8 51 ff ff ff       	call   c0101187 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101236:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010123d:	e8 45 ff ff ff       	call   c0101187 <lpt_putc_sub>
}
c0101242:	90                   	nop
c0101243:	89 ec                	mov    %ebp,%esp
c0101245:	5d                   	pop    %ebp
c0101246:	c3                   	ret    

c0101247 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101247:	55                   	push   %ebp
c0101248:	89 e5                	mov    %esp,%ebp
c010124a:	83 ec 38             	sub    $0x38,%esp
c010124d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101250:	8b 45 08             	mov    0x8(%ebp),%eax
c0101253:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101258:	85 c0                	test   %eax,%eax
c010125a:	75 07                	jne    c0101263 <cga_putc+0x1c>
        c |= 0x0700;
c010125c:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101263:	8b 45 08             	mov    0x8(%ebp),%eax
c0101266:	0f b6 c0             	movzbl %al,%eax
c0101269:	83 f8 0d             	cmp    $0xd,%eax
c010126c:	74 72                	je     c01012e0 <cga_putc+0x99>
c010126e:	83 f8 0d             	cmp    $0xd,%eax
c0101271:	0f 8f a3 00 00 00    	jg     c010131a <cga_putc+0xd3>
c0101277:	83 f8 08             	cmp    $0x8,%eax
c010127a:	74 0a                	je     c0101286 <cga_putc+0x3f>
c010127c:	83 f8 0a             	cmp    $0xa,%eax
c010127f:	74 4c                	je     c01012cd <cga_putc+0x86>
c0101281:	e9 94 00 00 00       	jmp    c010131a <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c0101286:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c010128d:	85 c0                	test   %eax,%eax
c010128f:	0f 84 af 00 00 00    	je     c0101344 <cga_putc+0xfd>
            crt_pos --;
c0101295:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c010129c:	48                   	dec    %eax
c010129d:	0f b7 c0             	movzwl %ax,%eax
c01012a0:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01012a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01012a9:	98                   	cwtl   
c01012aa:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01012af:	98                   	cwtl   
c01012b0:	83 c8 20             	or     $0x20,%eax
c01012b3:	98                   	cwtl   
c01012b4:	8b 0d 40 34 1a c0    	mov    0xc01a3440,%ecx
c01012ba:	0f b7 15 44 34 1a c0 	movzwl 0xc01a3444,%edx
c01012c1:	01 d2                	add    %edx,%edx
c01012c3:	01 ca                	add    %ecx,%edx
c01012c5:	0f b7 c0             	movzwl %ax,%eax
c01012c8:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01012cb:	eb 77                	jmp    c0101344 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01012cd:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c01012d4:	83 c0 50             	add    $0x50,%eax
c01012d7:	0f b7 c0             	movzwl %ax,%eax
c01012da:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01012e0:	0f b7 1d 44 34 1a c0 	movzwl 0xc01a3444,%ebx
c01012e7:	0f b7 0d 44 34 1a c0 	movzwl 0xc01a3444,%ecx
c01012ee:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01012f3:	89 c8                	mov    %ecx,%eax
c01012f5:	f7 e2                	mul    %edx
c01012f7:	c1 ea 06             	shr    $0x6,%edx
c01012fa:	89 d0                	mov    %edx,%eax
c01012fc:	c1 e0 02             	shl    $0x2,%eax
c01012ff:	01 d0                	add    %edx,%eax
c0101301:	c1 e0 04             	shl    $0x4,%eax
c0101304:	29 c1                	sub    %eax,%ecx
c0101306:	89 ca                	mov    %ecx,%edx
c0101308:	0f b7 d2             	movzwl %dx,%edx
c010130b:	89 d8                	mov    %ebx,%eax
c010130d:	29 d0                	sub    %edx,%eax
c010130f:	0f b7 c0             	movzwl %ax,%eax
c0101312:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
        break;
c0101318:	eb 2b                	jmp    c0101345 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010131a:	8b 0d 40 34 1a c0    	mov    0xc01a3440,%ecx
c0101320:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101327:	8d 50 01             	lea    0x1(%eax),%edx
c010132a:	0f b7 d2             	movzwl %dx,%edx
c010132d:	66 89 15 44 34 1a c0 	mov    %dx,0xc01a3444
c0101334:	01 c0                	add    %eax,%eax
c0101336:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101339:	8b 45 08             	mov    0x8(%ebp),%eax
c010133c:	0f b7 c0             	movzwl %ax,%eax
c010133f:	66 89 02             	mov    %ax,(%edx)
        break;
c0101342:	eb 01                	jmp    c0101345 <cga_putc+0xfe>
        break;
c0101344:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101345:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c010134c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101351:	76 5e                	jbe    c01013b1 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101353:	a1 40 34 1a c0       	mov    0xc01a3440,%eax
c0101358:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010135e:	a1 40 34 1a c0       	mov    0xc01a3440,%eax
c0101363:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010136a:	00 
c010136b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010136f:	89 04 24             	mov    %eax,(%esp)
c0101372:	e8 a9 ac 00 00       	call   c010c020 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101377:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010137e:	eb 15                	jmp    c0101395 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101380:	8b 15 40 34 1a c0    	mov    0xc01a3440,%edx
c0101386:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101389:	01 c0                	add    %eax,%eax
c010138b:	01 d0                	add    %edx,%eax
c010138d:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101392:	ff 45 f4             	incl   -0xc(%ebp)
c0101395:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010139c:	7e e2                	jle    c0101380 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c010139e:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c01013a5:	83 e8 50             	sub    $0x50,%eax
c01013a8:	0f b7 c0             	movzwl %ax,%eax
c01013ab:	66 a3 44 34 1a c0    	mov    %ax,0xc01a3444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01013b1:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c01013b8:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01013bc:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013c0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01013c4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013c8:	ee                   	out    %al,(%dx)
}
c01013c9:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01013ca:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c01013d1:	c1 e8 08             	shr    $0x8,%eax
c01013d4:	0f b7 c0             	movzwl %ax,%eax
c01013d7:	0f b6 c0             	movzbl %al,%eax
c01013da:	0f b7 15 46 34 1a c0 	movzwl 0xc01a3446,%edx
c01013e1:	42                   	inc    %edx
c01013e2:	0f b7 d2             	movzwl %dx,%edx
c01013e5:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01013e9:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013ec:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013f0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013f4:	ee                   	out    %al,(%dx)
}
c01013f5:	90                   	nop
    outb(addr_6845, 15);
c01013f6:	0f b7 05 46 34 1a c0 	movzwl 0xc01a3446,%eax
c01013fd:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101401:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101405:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101409:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010140d:	ee                   	out    %al,(%dx)
}
c010140e:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010140f:	0f b7 05 44 34 1a c0 	movzwl 0xc01a3444,%eax
c0101416:	0f b6 c0             	movzbl %al,%eax
c0101419:	0f b7 15 46 34 1a c0 	movzwl 0xc01a3446,%edx
c0101420:	42                   	inc    %edx
c0101421:	0f b7 d2             	movzwl %dx,%edx
c0101424:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101428:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010142b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010142f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101433:	ee                   	out    %al,(%dx)
}
c0101434:	90                   	nop
}
c0101435:	90                   	nop
c0101436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101439:	89 ec                	mov    %ebp,%esp
c010143b:	5d                   	pop    %ebp
c010143c:	c3                   	ret    

c010143d <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010143d:	55                   	push   %ebp
c010143e:	89 e5                	mov    %esp,%ebp
c0101440:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101443:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010144a:	eb 08                	jmp    c0101454 <serial_putc_sub+0x17>
        delay();
c010144c:	e8 16 fb ff ff       	call   c0100f67 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101451:	ff 45 fc             	incl   -0x4(%ebp)
c0101454:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010145e:	89 c2                	mov    %eax,%edx
c0101460:	ec                   	in     (%dx),%al
c0101461:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101464:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101468:	0f b6 c0             	movzbl %al,%eax
c010146b:	83 e0 20             	and    $0x20,%eax
c010146e:	85 c0                	test   %eax,%eax
c0101470:	75 09                	jne    c010147b <serial_putc_sub+0x3e>
c0101472:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101479:	7e d1                	jle    c010144c <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010147b:	8b 45 08             	mov    0x8(%ebp),%eax
c010147e:	0f b6 c0             	movzbl %al,%eax
c0101481:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101487:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010148a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010148e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101492:	ee                   	out    %al,(%dx)
}
c0101493:	90                   	nop
}
c0101494:	90                   	nop
c0101495:	89 ec                	mov    %ebp,%esp
c0101497:	5d                   	pop    %ebp
c0101498:	c3                   	ret    

c0101499 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101499:	55                   	push   %ebp
c010149a:	89 e5                	mov    %esp,%ebp
c010149c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010149f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01014a3:	74 0d                	je     c01014b2 <serial_putc+0x19>
        serial_putc_sub(c);
c01014a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01014a8:	89 04 24             	mov    %eax,(%esp)
c01014ab:	e8 8d ff ff ff       	call   c010143d <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01014b0:	eb 24                	jmp    c01014d6 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01014b2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01014b9:	e8 7f ff ff ff       	call   c010143d <serial_putc_sub>
        serial_putc_sub(' ');
c01014be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01014c5:	e8 73 ff ff ff       	call   c010143d <serial_putc_sub>
        serial_putc_sub('\b');
c01014ca:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01014d1:	e8 67 ff ff ff       	call   c010143d <serial_putc_sub>
}
c01014d6:	90                   	nop
c01014d7:	89 ec                	mov    %ebp,%esp
c01014d9:	5d                   	pop    %ebp
c01014da:	c3                   	ret    

c01014db <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01014db:	55                   	push   %ebp
c01014dc:	89 e5                	mov    %esp,%ebp
c01014de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01014e1:	eb 33                	jmp    c0101516 <cons_intr+0x3b>
        if (c != 0) {
c01014e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014e7:	74 2d                	je     c0101516 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01014e9:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c01014ee:	8d 50 01             	lea    0x1(%eax),%edx
c01014f1:	89 15 64 36 1a c0    	mov    %edx,0xc01a3664
c01014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01014fa:	88 90 60 34 1a c0    	mov    %dl,-0x3fe5cba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101500:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c0101505:	3d 00 02 00 00       	cmp    $0x200,%eax
c010150a:	75 0a                	jne    c0101516 <cons_intr+0x3b>
                cons.wpos = 0;
c010150c:	c7 05 64 36 1a c0 00 	movl   $0x0,0xc01a3664
c0101513:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101516:	8b 45 08             	mov    0x8(%ebp),%eax
c0101519:	ff d0                	call   *%eax
c010151b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010151e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101522:	75 bf                	jne    c01014e3 <cons_intr+0x8>
            }
        }
    }
}
c0101524:	90                   	nop
c0101525:	90                   	nop
c0101526:	89 ec                	mov    %ebp,%esp
c0101528:	5d                   	pop    %ebp
c0101529:	c3                   	ret    

c010152a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010152a:	55                   	push   %ebp
c010152b:	89 e5                	mov    %esp,%ebp
c010152d:	83 ec 10             	sub    $0x10,%esp
c0101530:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101536:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010153a:	89 c2                	mov    %eax,%edx
c010153c:	ec                   	in     (%dx),%al
c010153d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101540:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101544:	0f b6 c0             	movzbl %al,%eax
c0101547:	83 e0 01             	and    $0x1,%eax
c010154a:	85 c0                	test   %eax,%eax
c010154c:	75 07                	jne    c0101555 <serial_proc_data+0x2b>
        return -1;
c010154e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101553:	eb 2a                	jmp    c010157f <serial_proc_data+0x55>
c0101555:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010155b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010155f:	89 c2                	mov    %eax,%edx
c0101561:	ec                   	in     (%dx),%al
c0101562:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101565:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101569:	0f b6 c0             	movzbl %al,%eax
c010156c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010156f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101573:	75 07                	jne    c010157c <serial_proc_data+0x52>
        c = '\b';
c0101575:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010157c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010157f:	89 ec                	mov    %ebp,%esp
c0101581:	5d                   	pop    %ebp
c0101582:	c3                   	ret    

c0101583 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101583:	55                   	push   %ebp
c0101584:	89 e5                	mov    %esp,%ebp
c0101586:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101589:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c010158e:	85 c0                	test   %eax,%eax
c0101590:	74 0c                	je     c010159e <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101592:	c7 04 24 2a 15 10 c0 	movl   $0xc010152a,(%esp)
c0101599:	e8 3d ff ff ff       	call   c01014db <cons_intr>
    }
}
c010159e:	90                   	nop
c010159f:	89 ec                	mov    %ebp,%esp
c01015a1:	5d                   	pop    %ebp
c01015a2:	c3                   	ret    

c01015a3 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01015a3:	55                   	push   %ebp
c01015a4:	89 e5                	mov    %esp,%ebp
c01015a6:	83 ec 38             	sub    $0x38,%esp
c01015a9:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015b2:	89 c2                	mov    %eax,%edx
c01015b4:	ec                   	in     (%dx),%al
c01015b5:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01015b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01015bc:	0f b6 c0             	movzbl %al,%eax
c01015bf:	83 e0 01             	and    $0x1,%eax
c01015c2:	85 c0                	test   %eax,%eax
c01015c4:	75 0a                	jne    c01015d0 <kbd_proc_data+0x2d>
        return -1;
c01015c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01015cb:	e9 56 01 00 00       	jmp    c0101726 <kbd_proc_data+0x183>
c01015d0:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01015d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015d9:	89 c2                	mov    %eax,%edx
c01015db:	ec                   	in     (%dx),%al
c01015dc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01015df:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01015e3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01015e6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01015ea:	75 17                	jne    c0101603 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01015ec:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01015f1:	83 c8 40             	or     $0x40,%eax
c01015f4:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
        return 0;
c01015f9:	b8 00 00 00 00       	mov    $0x0,%eax
c01015fe:	e9 23 01 00 00       	jmp    c0101726 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101603:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101607:	84 c0                	test   %al,%al
c0101609:	79 45                	jns    c0101650 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010160b:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101610:	83 e0 40             	and    $0x40,%eax
c0101613:	85 c0                	test   %eax,%eax
c0101615:	75 08                	jne    c010161f <kbd_proc_data+0x7c>
c0101617:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010161b:	24 7f                	and    $0x7f,%al
c010161d:	eb 04                	jmp    c0101623 <kbd_proc_data+0x80>
c010161f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101623:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101626:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010162a:	0f b6 80 40 f0 12 c0 	movzbl -0x3fed0fc0(%eax),%eax
c0101631:	0c 40                	or     $0x40,%al
c0101633:	0f b6 c0             	movzbl %al,%eax
c0101636:	f7 d0                	not    %eax
c0101638:	89 c2                	mov    %eax,%edx
c010163a:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c010163f:	21 d0                	and    %edx,%eax
c0101641:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
        return 0;
c0101646:	b8 00 00 00 00       	mov    $0x0,%eax
c010164b:	e9 d6 00 00 00       	jmp    c0101726 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101650:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101655:	83 e0 40             	and    $0x40,%eax
c0101658:	85 c0                	test   %eax,%eax
c010165a:	74 11                	je     c010166d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010165c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101660:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101665:	83 e0 bf             	and    $0xffffffbf,%eax
c0101668:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
    }

    shift |= shiftcode[data];
c010166d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101671:	0f b6 80 40 f0 12 c0 	movzbl -0x3fed0fc0(%eax),%eax
c0101678:	0f b6 d0             	movzbl %al,%edx
c010167b:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c0101680:	09 d0                	or     %edx,%eax
c0101682:	a3 68 36 1a c0       	mov    %eax,0xc01a3668
    shift ^= togglecode[data];
c0101687:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010168b:	0f b6 80 40 f1 12 c0 	movzbl -0x3fed0ec0(%eax),%eax
c0101692:	0f b6 d0             	movzbl %al,%edx
c0101695:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c010169a:	31 d0                	xor    %edx,%eax
c010169c:	a3 68 36 1a c0       	mov    %eax,0xc01a3668

    c = charcode[shift & (CTL | SHIFT)][data];
c01016a1:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01016a6:	83 e0 03             	and    $0x3,%eax
c01016a9:	8b 14 85 40 f5 12 c0 	mov    -0x3fed0ac0(,%eax,4),%edx
c01016b0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01016b4:	01 d0                	add    %edx,%eax
c01016b6:	0f b6 00             	movzbl (%eax),%eax
c01016b9:	0f b6 c0             	movzbl %al,%eax
c01016bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01016bf:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01016c4:	83 e0 08             	and    $0x8,%eax
c01016c7:	85 c0                	test   %eax,%eax
c01016c9:	74 22                	je     c01016ed <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01016cb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01016cf:	7e 0c                	jle    c01016dd <kbd_proc_data+0x13a>
c01016d1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01016d5:	7f 06                	jg     c01016dd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01016d7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01016db:	eb 10                	jmp    c01016ed <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01016dd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01016e1:	7e 0a                	jle    c01016ed <kbd_proc_data+0x14a>
c01016e3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01016e7:	7f 04                	jg     c01016ed <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01016e9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01016ed:	a1 68 36 1a c0       	mov    0xc01a3668,%eax
c01016f2:	f7 d0                	not    %eax
c01016f4:	83 e0 06             	and    $0x6,%eax
c01016f7:	85 c0                	test   %eax,%eax
c01016f9:	75 28                	jne    c0101723 <kbd_proc_data+0x180>
c01016fb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101702:	75 1f                	jne    c0101723 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101704:	c7 04 24 bf c4 10 c0 	movl   $0xc010c4bf,(%esp)
c010170b:	e8 5d ec ff ff       	call   c010036d <cprintf>
c0101710:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101716:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010171a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010171e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101721:	ee                   	out    %al,(%dx)
}
c0101722:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101723:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101726:	89 ec                	mov    %ebp,%esp
c0101728:	5d                   	pop    %ebp
c0101729:	c3                   	ret    

c010172a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010172a:	55                   	push   %ebp
c010172b:	89 e5                	mov    %esp,%ebp
c010172d:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101730:	c7 04 24 a3 15 10 c0 	movl   $0xc01015a3,(%esp)
c0101737:	e8 9f fd ff ff       	call   c01014db <cons_intr>
}
c010173c:	90                   	nop
c010173d:	89 ec                	mov    %ebp,%esp
c010173f:	5d                   	pop    %ebp
c0101740:	c3                   	ret    

c0101741 <kbd_init>:

static void
kbd_init(void) {
c0101741:	55                   	push   %ebp
c0101742:	89 e5                	mov    %esp,%ebp
c0101744:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101747:	e8 de ff ff ff       	call   c010172a <kbd_intr>
    pic_enable(IRQ_KBD);
c010174c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101753:	e8 ae 09 00 00       	call   c0102106 <pic_enable>
}
c0101758:	90                   	nop
c0101759:	89 ec                	mov    %ebp,%esp
c010175b:	5d                   	pop    %ebp
c010175c:	c3                   	ret    

c010175d <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010175d:	55                   	push   %ebp
c010175e:	89 e5                	mov    %esp,%ebp
c0101760:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101763:	e8 4a f8 ff ff       	call   c0100fb2 <cga_init>
    serial_init();
c0101768:	e8 2d f9 ff ff       	call   c010109a <serial_init>
    kbd_init();
c010176d:	e8 cf ff ff ff       	call   c0101741 <kbd_init>
    if (!serial_exists) {
c0101772:	a1 48 34 1a c0       	mov    0xc01a3448,%eax
c0101777:	85 c0                	test   %eax,%eax
c0101779:	75 0c                	jne    c0101787 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010177b:	c7 04 24 cb c4 10 c0 	movl   $0xc010c4cb,(%esp)
c0101782:	e8 e6 eb ff ff       	call   c010036d <cprintf>
    }
}
c0101787:	90                   	nop
c0101788:	89 ec                	mov    %ebp,%esp
c010178a:	5d                   	pop    %ebp
c010178b:	c3                   	ret    

c010178c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010178c:	55                   	push   %ebp
c010178d:	89 e5                	mov    %esp,%ebp
c010178f:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101792:	e8 8e f7 ff ff       	call   c0100f25 <__intr_save>
c0101797:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010179a:	8b 45 08             	mov    0x8(%ebp),%eax
c010179d:	89 04 24             	mov    %eax,(%esp)
c01017a0:	e8 60 fa ff ff       	call   c0101205 <lpt_putc>
        cga_putc(c);
c01017a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a8:	89 04 24             	mov    %eax,(%esp)
c01017ab:	e8 97 fa ff ff       	call   c0101247 <cga_putc>
        serial_putc(c);
c01017b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01017b3:	89 04 24             	mov    %eax,(%esp)
c01017b6:	e8 de fc ff ff       	call   c0101499 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017be:	89 04 24             	mov    %eax,(%esp)
c01017c1:	e8 8b f7 ff ff       	call   c0100f51 <__intr_restore>
}
c01017c6:	90                   	nop
c01017c7:	89 ec                	mov    %ebp,%esp
c01017c9:	5d                   	pop    %ebp
c01017ca:	c3                   	ret    

c01017cb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01017cb:	55                   	push   %ebp
c01017cc:	89 e5                	mov    %esp,%ebp
c01017ce:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01017d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01017d8:	e8 48 f7 ff ff       	call   c0100f25 <__intr_save>
c01017dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01017e0:	e8 9e fd ff ff       	call   c0101583 <serial_intr>
        kbd_intr();
c01017e5:	e8 40 ff ff ff       	call   c010172a <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01017ea:	8b 15 60 36 1a c0    	mov    0xc01a3660,%edx
c01017f0:	a1 64 36 1a c0       	mov    0xc01a3664,%eax
c01017f5:	39 c2                	cmp    %eax,%edx
c01017f7:	74 31                	je     c010182a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01017f9:	a1 60 36 1a c0       	mov    0xc01a3660,%eax
c01017fe:	8d 50 01             	lea    0x1(%eax),%edx
c0101801:	89 15 60 36 1a c0    	mov    %edx,0xc01a3660
c0101807:	0f b6 80 60 34 1a c0 	movzbl -0x3fe5cba0(%eax),%eax
c010180e:	0f b6 c0             	movzbl %al,%eax
c0101811:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101814:	a1 60 36 1a c0       	mov    0xc01a3660,%eax
c0101819:	3d 00 02 00 00       	cmp    $0x200,%eax
c010181e:	75 0a                	jne    c010182a <cons_getc+0x5f>
                cons.rpos = 0;
c0101820:	c7 05 60 36 1a c0 00 	movl   $0x0,0xc01a3660
c0101827:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010182a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010182d:	89 04 24             	mov    %eax,(%esp)
c0101830:	e8 1c f7 ff ff       	call   c0100f51 <__intr_restore>
    return c;
c0101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101838:	89 ec                	mov    %ebp,%esp
c010183a:	5d                   	pop    %ebp
c010183b:	c3                   	ret    

c010183c <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c010183c:	55                   	push   %ebp
c010183d:	89 e5                	mov    %esp,%ebp
c010183f:	83 ec 14             	sub    $0x14,%esp
c0101842:	8b 45 08             	mov    0x8(%ebp),%eax
c0101845:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101849:	90                   	nop
c010184a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010184d:	83 c0 07             	add    $0x7,%eax
c0101850:	0f b7 c0             	movzwl %ax,%eax
c0101853:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101857:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010185b:	89 c2                	mov    %eax,%edx
c010185d:	ec                   	in     (%dx),%al
c010185e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101861:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101865:	0f b6 c0             	movzbl %al,%eax
c0101868:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010186b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010186e:	25 80 00 00 00       	and    $0x80,%eax
c0101873:	85 c0                	test   %eax,%eax
c0101875:	75 d3                	jne    c010184a <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101877:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010187b:	74 11                	je     c010188e <ide_wait_ready+0x52>
c010187d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101880:	83 e0 21             	and    $0x21,%eax
c0101883:	85 c0                	test   %eax,%eax
c0101885:	74 07                	je     c010188e <ide_wait_ready+0x52>
        return -1;
c0101887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010188c:	eb 05                	jmp    c0101893 <ide_wait_ready+0x57>
    }
    return 0;
c010188e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101893:	89 ec                	mov    %ebp,%esp
c0101895:	5d                   	pop    %ebp
c0101896:	c3                   	ret    

c0101897 <ide_init>:

void
ide_init(void) {
c0101897:	55                   	push   %ebp
c0101898:	89 e5                	mov    %esp,%ebp
c010189a:	57                   	push   %edi
c010189b:	53                   	push   %ebx
c010189c:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01018a2:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01018a8:	e9 bd 02 00 00       	jmp    c0101b6a <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01018ad:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018b1:	89 d0                	mov    %edx,%eax
c01018b3:	c1 e0 03             	shl    $0x3,%eax
c01018b6:	29 d0                	sub    %edx,%eax
c01018b8:	c1 e0 03             	shl    $0x3,%eax
c01018bb:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c01018c0:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01018c3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018c7:	d1 e8                	shr    %eax
c01018c9:	0f b7 c0             	movzwl %ax,%eax
c01018cc:	8b 04 85 ec c4 10 c0 	mov    -0x3fef3b14(,%eax,4),%eax
c01018d3:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01018d7:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018e2:	00 
c01018e3:	89 04 24             	mov    %eax,(%esp)
c01018e6:	e8 51 ff ff ff       	call   c010183c <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01018eb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018ef:	c1 e0 04             	shl    $0x4,%eax
c01018f2:	24 10                	and    $0x10,%al
c01018f4:	0c e0                	or     $0xe0,%al
c01018f6:	0f b6 c0             	movzbl %al,%eax
c01018f9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018fd:	83 c2 06             	add    $0x6,%edx
c0101900:	0f b7 d2             	movzwl %dx,%edx
c0101903:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101907:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010190a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010190e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101912:	ee                   	out    %al,(%dx)
}
c0101913:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101914:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010191f:	00 
c0101920:	89 04 24             	mov    %eax,(%esp)
c0101923:	e8 14 ff ff ff       	call   c010183c <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0101928:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010192c:	83 c0 07             	add    $0x7,%eax
c010192f:	0f b7 c0             	movzwl %ax,%eax
c0101932:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101936:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010193a:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010193e:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101942:	ee                   	out    %al,(%dx)
}
c0101943:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101944:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101948:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010194f:	00 
c0101950:	89 04 24             	mov    %eax,(%esp)
c0101953:	e8 e4 fe ff ff       	call   c010183c <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101958:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010195c:	83 c0 07             	add    $0x7,%eax
c010195f:	0f b7 c0             	movzwl %ax,%eax
c0101962:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101966:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010196a:	89 c2                	mov    %eax,%edx
c010196c:	ec                   	in     (%dx),%al
c010196d:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0101970:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101974:	84 c0                	test   %al,%al
c0101976:	0f 84 e4 01 00 00    	je     c0101b60 <ide_init+0x2c9>
c010197c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101980:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101987:	00 
c0101988:	89 04 24             	mov    %eax,(%esp)
c010198b:	e8 ac fe ff ff       	call   c010183c <ide_wait_ready>
c0101990:	85 c0                	test   %eax,%eax
c0101992:	0f 85 c8 01 00 00    	jne    c0101b60 <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101998:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010199c:	89 d0                	mov    %edx,%eax
c010199e:	c1 e0 03             	shl    $0x3,%eax
c01019a1:	29 d0                	sub    %edx,%eax
c01019a3:	c1 e0 03             	shl    $0x3,%eax
c01019a6:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c01019ab:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01019ae:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01019b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01019b5:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01019bb:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01019be:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c01019c5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01019c8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01019cb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01019ce:	89 cb                	mov    %ecx,%ebx
c01019d0:	89 df                	mov    %ebx,%edi
c01019d2:	89 c1                	mov    %eax,%ecx
c01019d4:	fc                   	cld    
c01019d5:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01019d7:	89 c8                	mov    %ecx,%eax
c01019d9:	89 fb                	mov    %edi,%ebx
c01019db:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c01019de:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c01019e1:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c01019e2:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01019e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01019eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01019f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01019f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019fa:	25 00 00 00 04       	and    $0x4000000,%eax
c01019ff:	85 c0                	test   %eax,%eax
c0101a01:	74 0e                	je     c0101a11 <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101a03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a06:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101a0f:	eb 09                	jmp    c0101a1a <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a14:	8b 40 78             	mov    0x78(%eax),%eax
c0101a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101a1a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a1e:	89 d0                	mov    %edx,%eax
c0101a20:	c1 e0 03             	shl    $0x3,%eax
c0101a23:	29 d0                	sub    %edx,%eax
c0101a25:	c1 e0 03             	shl    $0x3,%eax
c0101a28:	8d 90 84 36 1a c0    	lea    -0x3fe5c97c(%eax),%edx
c0101a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101a31:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101a33:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a37:	89 d0                	mov    %edx,%eax
c0101a39:	c1 e0 03             	shl    $0x3,%eax
c0101a3c:	29 d0                	sub    %edx,%eax
c0101a3e:	c1 e0 03             	shl    $0x3,%eax
c0101a41:	8d 90 88 36 1a c0    	lea    -0x3fe5c978(%eax),%edx
c0101a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101a4a:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101a4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a4f:	83 c0 62             	add    $0x62,%eax
c0101a52:	0f b7 00             	movzwl (%eax),%eax
c0101a55:	25 00 02 00 00       	and    $0x200,%eax
c0101a5a:	85 c0                	test   %eax,%eax
c0101a5c:	75 24                	jne    c0101a82 <ide_init+0x1eb>
c0101a5e:	c7 44 24 0c f4 c4 10 	movl   $0xc010c4f4,0xc(%esp)
c0101a65:	c0 
c0101a66:	c7 44 24 08 37 c5 10 	movl   $0xc010c537,0x8(%esp)
c0101a6d:	c0 
c0101a6e:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101a75:	00 
c0101a76:	c7 04 24 4c c5 10 c0 	movl   $0xc010c54c,(%esp)
c0101a7d:	e8 69 f3 ff ff       	call   c0100deb <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a82:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a86:	89 d0                	mov    %edx,%eax
c0101a88:	c1 e0 03             	shl    $0x3,%eax
c0101a8b:	29 d0                	sub    %edx,%eax
c0101a8d:	c1 e0 03             	shl    $0x3,%eax
c0101a90:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101a95:	83 c0 0c             	add    $0xc,%eax
c0101a98:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a9e:	83 c0 36             	add    $0x36,%eax
c0101aa1:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101aa4:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101aab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101ab2:	eb 34                	jmp    c0101ae8 <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ab7:	8d 50 01             	lea    0x1(%eax),%edx
c0101aba:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101abd:	01 c2                	add    %eax,%edx
c0101abf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0101ac2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ac5:	01 c8                	add    %ecx,%eax
c0101ac7:	0f b6 12             	movzbl (%edx),%edx
c0101aca:	88 10                	mov    %dl,(%eax)
c0101acc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ad2:	01 c2                	add    %eax,%edx
c0101ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ad7:	8d 48 01             	lea    0x1(%eax),%ecx
c0101ada:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101add:	01 c8                	add    %ecx,%eax
c0101adf:	0f b6 12             	movzbl (%edx),%edx
c0101ae2:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101ae4:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101ae8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aeb:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101aee:	72 c4                	jb     c0101ab4 <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101af0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101af3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101af6:	01 d0                	add    %edx,%eax
c0101af8:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101afe:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101b01:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101b04:	85 c0                	test   %eax,%eax
c0101b06:	74 0f                	je     c0101b17 <ide_init+0x280>
c0101b08:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101b0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b0e:	01 d0                	add    %edx,%eax
c0101b10:	0f b6 00             	movzbl (%eax),%eax
c0101b13:	3c 20                	cmp    $0x20,%al
c0101b15:	74 d9                	je     c0101af0 <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101b17:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b1b:	89 d0                	mov    %edx,%eax
c0101b1d:	c1 e0 03             	shl    $0x3,%eax
c0101b20:	29 d0                	sub    %edx,%eax
c0101b22:	c1 e0 03             	shl    $0x3,%eax
c0101b25:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101b2a:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101b2d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101b31:	89 d0                	mov    %edx,%eax
c0101b33:	c1 e0 03             	shl    $0x3,%eax
c0101b36:	29 d0                	sub    %edx,%eax
c0101b38:	c1 e0 03             	shl    $0x3,%eax
c0101b3b:	05 88 36 1a c0       	add    $0xc01a3688,%eax
c0101b40:	8b 10                	mov    (%eax),%edx
c0101b42:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b46:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101b4a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b52:	c7 04 24 5e c5 10 c0 	movl   $0xc010c55e,(%esp)
c0101b59:	e8 0f e8 ff ff       	call   c010036d <cprintf>
c0101b5e:	eb 01                	jmp    c0101b61 <ide_init+0x2ca>
            continue ;
c0101b60:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101b61:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b65:	40                   	inc    %eax
c0101b66:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b6a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b6e:	83 f8 03             	cmp    $0x3,%eax
c0101b71:	0f 86 36 fd ff ff    	jbe    c01018ad <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b77:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b7e:	e8 83 05 00 00       	call   c0102106 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b83:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b8a:	e8 77 05 00 00       	call   c0102106 <pic_enable>
}
c0101b8f:	90                   	nop
c0101b90:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b96:	5b                   	pop    %ebx
c0101b97:	5f                   	pop    %edi
c0101b98:	5d                   	pop    %ebp
c0101b99:	c3                   	ret    

c0101b9a <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b9a:	55                   	push   %ebp
c0101b9b:	89 e5                	mov    %esp,%ebp
c0101b9d:	83 ec 04             	sub    $0x4,%esp
c0101ba0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101ba7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bab:	83 f8 03             	cmp    $0x3,%eax
c0101bae:	77 21                	ja     c0101bd1 <ide_device_valid+0x37>
c0101bb0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101bb4:	89 d0                	mov    %edx,%eax
c0101bb6:	c1 e0 03             	shl    $0x3,%eax
c0101bb9:	29 d0                	sub    %edx,%eax
c0101bbb:	c1 e0 03             	shl    $0x3,%eax
c0101bbe:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101bc3:	0f b6 00             	movzbl (%eax),%eax
c0101bc6:	84 c0                	test   %al,%al
c0101bc8:	74 07                	je     c0101bd1 <ide_device_valid+0x37>
c0101bca:	b8 01 00 00 00       	mov    $0x1,%eax
c0101bcf:	eb 05                	jmp    c0101bd6 <ide_device_valid+0x3c>
c0101bd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101bd6:	89 ec                	mov    %ebp,%esp
c0101bd8:	5d                   	pop    %ebp
c0101bd9:	c3                   	ret    

c0101bda <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101bda:	55                   	push   %ebp
c0101bdb:	89 e5                	mov    %esp,%ebp
c0101bdd:	83 ec 08             	sub    $0x8,%esp
c0101be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101be7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101beb:	89 04 24             	mov    %eax,(%esp)
c0101bee:	e8 a7 ff ff ff       	call   c0101b9a <ide_device_valid>
c0101bf3:	85 c0                	test   %eax,%eax
c0101bf5:	74 17                	je     c0101c0e <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101bf7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101bfb:	89 d0                	mov    %edx,%eax
c0101bfd:	c1 e0 03             	shl    $0x3,%eax
c0101c00:	29 d0                	sub    %edx,%eax
c0101c02:	c1 e0 03             	shl    $0x3,%eax
c0101c05:	05 88 36 1a c0       	add    $0xc01a3688,%eax
c0101c0a:	8b 00                	mov    (%eax),%eax
c0101c0c:	eb 05                	jmp    c0101c13 <ide_device_size+0x39>
    }
    return 0;
c0101c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101c13:	89 ec                	mov    %ebp,%esp
c0101c15:	5d                   	pop    %ebp
c0101c16:	c3                   	ret    

c0101c17 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101c17:	55                   	push   %ebp
c0101c18:	89 e5                	mov    %esp,%ebp
c0101c1a:	57                   	push   %edi
c0101c1b:	53                   	push   %ebx
c0101c1c:	83 ec 50             	sub    $0x50,%esp
c0101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c22:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101c26:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101c2d:	77 23                	ja     c0101c52 <ide_read_secs+0x3b>
c0101c2f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c33:	83 f8 03             	cmp    $0x3,%eax
c0101c36:	77 1a                	ja     c0101c52 <ide_read_secs+0x3b>
c0101c38:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101c3c:	89 d0                	mov    %edx,%eax
c0101c3e:	c1 e0 03             	shl    $0x3,%eax
c0101c41:	29 d0                	sub    %edx,%eax
c0101c43:	c1 e0 03             	shl    $0x3,%eax
c0101c46:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101c4b:	0f b6 00             	movzbl (%eax),%eax
c0101c4e:	84 c0                	test   %al,%al
c0101c50:	75 24                	jne    c0101c76 <ide_read_secs+0x5f>
c0101c52:	c7 44 24 0c 7c c5 10 	movl   $0xc010c57c,0xc(%esp)
c0101c59:	c0 
c0101c5a:	c7 44 24 08 37 c5 10 	movl   $0xc010c537,0x8(%esp)
c0101c61:	c0 
c0101c62:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101c69:	00 
c0101c6a:	c7 04 24 4c c5 10 c0 	movl   $0xc010c54c,(%esp)
c0101c71:	e8 75 f1 ff ff       	call   c0100deb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c76:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c7d:	77 0f                	ja     c0101c8e <ide_read_secs+0x77>
c0101c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c82:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c85:	01 d0                	add    %edx,%eax
c0101c87:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c8c:	76 24                	jbe    c0101cb2 <ide_read_secs+0x9b>
c0101c8e:	c7 44 24 0c a4 c5 10 	movl   $0xc010c5a4,0xc(%esp)
c0101c95:	c0 
c0101c96:	c7 44 24 08 37 c5 10 	movl   $0xc010c537,0x8(%esp)
c0101c9d:	c0 
c0101c9e:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101ca5:	00 
c0101ca6:	c7 04 24 4c c5 10 c0 	movl   $0xc010c54c,(%esp)
c0101cad:	e8 39 f1 ff ff       	call   c0100deb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101cb2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101cb6:	d1 e8                	shr    %eax
c0101cb8:	0f b7 c0             	movzwl %ax,%eax
c0101cbb:	8b 04 85 ec c4 10 c0 	mov    -0x3fef3b14(,%eax,4),%eax
c0101cc2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101cc6:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101cca:	d1 e8                	shr    %eax
c0101ccc:	0f b7 c0             	movzwl %ax,%eax
c0101ccf:	0f b7 04 85 ee c4 10 	movzwl -0x3fef3b12(,%eax,4),%eax
c0101cd6:	c0 
c0101cd7:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101cdb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ce6:	00 
c0101ce7:	89 04 24             	mov    %eax,(%esp)
c0101cea:	e8 4d fb ff ff       	call   c010183c <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cf2:	83 c0 02             	add    $0x2,%eax
c0101cf5:	0f b7 c0             	movzwl %ax,%eax
c0101cf8:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101cfc:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d00:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101d04:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101d08:	ee                   	out    %al,(%dx)
}
c0101d09:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101d0a:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d0d:	0f b6 c0             	movzbl %al,%eax
c0101d10:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d14:	83 c2 02             	add    $0x2,%edx
c0101d17:	0f b7 d2             	movzwl %dx,%edx
c0101d1a:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d1e:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d21:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d25:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d29:	ee                   	out    %al,(%dx)
}
c0101d2a:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d2e:	0f b6 c0             	movzbl %al,%eax
c0101d31:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d35:	83 c2 03             	add    $0x3,%edx
c0101d38:	0f b7 d2             	movzwl %dx,%edx
c0101d3b:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d3f:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d42:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d46:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d4a:	ee                   	out    %al,(%dx)
}
c0101d4b:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d4f:	c1 e8 08             	shr    $0x8,%eax
c0101d52:	0f b6 c0             	movzbl %al,%eax
c0101d55:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d59:	83 c2 04             	add    $0x4,%edx
c0101d5c:	0f b7 d2             	movzwl %dx,%edx
c0101d5f:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d63:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d66:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d6a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d6e:	ee                   	out    %al,(%dx)
}
c0101d6f:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d73:	c1 e8 10             	shr    $0x10,%eax
c0101d76:	0f b6 c0             	movzbl %al,%eax
c0101d79:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d7d:	83 c2 05             	add    $0x5,%edx
c0101d80:	0f b7 d2             	movzwl %dx,%edx
c0101d83:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101d87:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d8a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101d8e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d92:	ee                   	out    %al,(%dx)
}
c0101d93:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101d97:	c0 e0 04             	shl    $0x4,%al
c0101d9a:	24 10                	and    $0x10,%al
c0101d9c:	88 c2                	mov    %al,%dl
c0101d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101da1:	c1 e8 18             	shr    $0x18,%eax
c0101da4:	24 0f                	and    $0xf,%al
c0101da6:	08 d0                	or     %dl,%al
c0101da8:	0c e0                	or     $0xe0,%al
c0101daa:	0f b6 c0             	movzbl %al,%eax
c0101dad:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101db1:	83 c2 06             	add    $0x6,%edx
c0101db4:	0f b7 d2             	movzwl %dx,%edx
c0101db7:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101dbb:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101dbe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101dc2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101dc6:	ee                   	out    %al,(%dx)
}
c0101dc7:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101dc8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dcc:	83 c0 07             	add    $0x7,%eax
c0101dcf:	0f b7 c0             	movzwl %ax,%eax
c0101dd2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101dd6:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101dda:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101dde:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101de2:	ee                   	out    %al,(%dx)
}
c0101de3:	90                   	nop

    int ret = 0;
c0101de4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101deb:	eb 58                	jmp    c0101e45 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101ded:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101df1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101df8:	00 
c0101df9:	89 04 24             	mov    %eax,(%esp)
c0101dfc:	e8 3b fa ff ff       	call   c010183c <ide_wait_ready>
c0101e01:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101e08:	75 43                	jne    c0101e4d <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101e0a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101e11:	8b 45 10             	mov    0x10(%ebp),%eax
c0101e14:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101e17:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101e1e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101e21:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101e24:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101e27:	89 cb                	mov    %ecx,%ebx
c0101e29:	89 df                	mov    %ebx,%edi
c0101e2b:	89 c1                	mov    %eax,%ecx
c0101e2d:	fc                   	cld    
c0101e2e:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101e30:	89 c8                	mov    %ecx,%eax
c0101e32:	89 fb                	mov    %edi,%ebx
c0101e34:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101e37:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101e3a:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101e3b:	ff 4d 14             	decl   0x14(%ebp)
c0101e3e:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101e45:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e49:	75 a2                	jne    c0101ded <ide_read_secs+0x1d6>
    }

out:
c0101e4b:	eb 01                	jmp    c0101e4e <ide_read_secs+0x237>
            goto out;
c0101e4d:	90                   	nop
    return ret;
c0101e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e51:	83 c4 50             	add    $0x50,%esp
c0101e54:	5b                   	pop    %ebx
c0101e55:	5f                   	pop    %edi
c0101e56:	5d                   	pop    %ebp
c0101e57:	c3                   	ret    

c0101e58 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101e58:	55                   	push   %ebp
c0101e59:	89 e5                	mov    %esp,%ebp
c0101e5b:	56                   	push   %esi
c0101e5c:	53                   	push   %ebx
c0101e5d:	83 ec 50             	sub    $0x50,%esp
c0101e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e63:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101e67:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e6e:	77 23                	ja     c0101e93 <ide_write_secs+0x3b>
c0101e70:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e74:	83 f8 03             	cmp    $0x3,%eax
c0101e77:	77 1a                	ja     c0101e93 <ide_write_secs+0x3b>
c0101e79:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101e7d:	89 d0                	mov    %edx,%eax
c0101e7f:	c1 e0 03             	shl    $0x3,%eax
c0101e82:	29 d0                	sub    %edx,%eax
c0101e84:	c1 e0 03             	shl    $0x3,%eax
c0101e87:	05 80 36 1a c0       	add    $0xc01a3680,%eax
c0101e8c:	0f b6 00             	movzbl (%eax),%eax
c0101e8f:	84 c0                	test   %al,%al
c0101e91:	75 24                	jne    c0101eb7 <ide_write_secs+0x5f>
c0101e93:	c7 44 24 0c 7c c5 10 	movl   $0xc010c57c,0xc(%esp)
c0101e9a:	c0 
c0101e9b:	c7 44 24 08 37 c5 10 	movl   $0xc010c537,0x8(%esp)
c0101ea2:	c0 
c0101ea3:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101eaa:	00 
c0101eab:	c7 04 24 4c c5 10 c0 	movl   $0xc010c54c,(%esp)
c0101eb2:	e8 34 ef ff ff       	call   c0100deb <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101eb7:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101ebe:	77 0f                	ja     c0101ecf <ide_write_secs+0x77>
c0101ec0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101ec3:	8b 45 14             	mov    0x14(%ebp),%eax
c0101ec6:	01 d0                	add    %edx,%eax
c0101ec8:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101ecd:	76 24                	jbe    c0101ef3 <ide_write_secs+0x9b>
c0101ecf:	c7 44 24 0c a4 c5 10 	movl   $0xc010c5a4,0xc(%esp)
c0101ed6:	c0 
c0101ed7:	c7 44 24 08 37 c5 10 	movl   $0xc010c537,0x8(%esp)
c0101ede:	c0 
c0101edf:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101ee6:	00 
c0101ee7:	c7 04 24 4c c5 10 c0 	movl   $0xc010c54c,(%esp)
c0101eee:	e8 f8 ee ff ff       	call   c0100deb <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ef3:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ef7:	d1 e8                	shr    %eax
c0101ef9:	0f b7 c0             	movzwl %ax,%eax
c0101efc:	8b 04 85 ec c4 10 c0 	mov    -0x3fef3b14(,%eax,4),%eax
c0101f03:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101f07:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101f0b:	d1 e8                	shr    %eax
c0101f0d:	0f b7 c0             	movzwl %ax,%eax
c0101f10:	0f b7 04 85 ee c4 10 	movzwl -0x3fef3b12(,%eax,4),%eax
c0101f17:	c0 
c0101f18:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101f1c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101f27:	00 
c0101f28:	89 04 24             	mov    %eax,(%esp)
c0101f2b:	e8 0c f9 ff ff       	call   c010183c <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f33:	83 c0 02             	add    $0x2,%eax
c0101f36:	0f b7 c0             	movzwl %ax,%eax
c0101f39:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101f3d:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f41:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101f45:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101f49:	ee                   	out    %al,(%dx)
}
c0101f4a:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101f4b:	8b 45 14             	mov    0x14(%ebp),%eax
c0101f4e:	0f b6 c0             	movzbl %al,%eax
c0101f51:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f55:	83 c2 02             	add    $0x2,%edx
c0101f58:	0f b7 d2             	movzwl %dx,%edx
c0101f5b:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101f5f:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f62:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101f66:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101f6a:	ee                   	out    %al,(%dx)
}
c0101f6b:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f6f:	0f b6 c0             	movzbl %al,%eax
c0101f72:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f76:	83 c2 03             	add    $0x3,%edx
c0101f79:	0f b7 d2             	movzwl %dx,%edx
c0101f7c:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f80:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f83:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f87:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101f8b:	ee                   	out    %al,(%dx)
}
c0101f8c:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f90:	c1 e8 08             	shr    $0x8,%eax
c0101f93:	0f b6 c0             	movzbl %al,%eax
c0101f96:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f9a:	83 c2 04             	add    $0x4,%edx
c0101f9d:	0f b7 d2             	movzwl %dx,%edx
c0101fa0:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101fa4:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fa7:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101fab:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101faf:	ee                   	out    %al,(%dx)
}
c0101fb0:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fb4:	c1 e8 10             	shr    $0x10,%eax
c0101fb7:	0f b6 c0             	movzbl %al,%eax
c0101fba:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101fbe:	83 c2 05             	add    $0x5,%edx
c0101fc1:	0f b7 d2             	movzwl %dx,%edx
c0101fc4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101fc8:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fcb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101fcf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101fd3:	ee                   	out    %al,(%dx)
}
c0101fd4:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101fd5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101fd8:	c0 e0 04             	shl    $0x4,%al
c0101fdb:	24 10                	and    $0x10,%al
c0101fdd:	88 c2                	mov    %al,%dl
c0101fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fe2:	c1 e8 18             	shr    $0x18,%eax
c0101fe5:	24 0f                	and    $0xf,%al
c0101fe7:	08 d0                	or     %dl,%al
c0101fe9:	0c e0                	or     $0xe0,%al
c0101feb:	0f b6 c0             	movzbl %al,%eax
c0101fee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ff2:	83 c2 06             	add    $0x6,%edx
c0101ff5:	0f b7 d2             	movzwl %dx,%edx
c0101ff8:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101ffc:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fff:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102003:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102007:	ee                   	out    %al,(%dx)
}
c0102008:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0102009:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010200d:	83 c0 07             	add    $0x7,%eax
c0102010:	0f b7 c0             	movzwl %ax,%eax
c0102013:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102017:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010201b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010201f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102023:	ee                   	out    %al,(%dx)
}
c0102024:	90                   	nop

    int ret = 0;
c0102025:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010202c:	eb 58                	jmp    c0102086 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010202e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102032:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0102039:	00 
c010203a:	89 04 24             	mov    %eax,(%esp)
c010203d:	e8 fa f7 ff ff       	call   c010183c <ide_wait_ready>
c0102042:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102045:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102049:	75 43                	jne    c010208e <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010204b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010204f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102052:	8b 45 10             	mov    0x10(%ebp),%eax
c0102055:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102058:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c010205f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102062:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102065:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102068:	89 cb                	mov    %ecx,%ebx
c010206a:	89 de                	mov    %ebx,%esi
c010206c:	89 c1                	mov    %eax,%ecx
c010206e:	fc                   	cld    
c010206f:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102071:	89 c8                	mov    %ecx,%eax
c0102073:	89 f3                	mov    %esi,%ebx
c0102075:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102078:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c010207b:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010207c:	ff 4d 14             	decl   0x14(%ebp)
c010207f:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102086:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010208a:	75 a2                	jne    c010202e <ide_write_secs+0x1d6>
    }

out:
c010208c:	eb 01                	jmp    c010208f <ide_write_secs+0x237>
            goto out;
c010208e:	90                   	nop
    return ret;
c010208f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102092:	83 c4 50             	add    $0x50,%esp
c0102095:	5b                   	pop    %ebx
c0102096:	5e                   	pop    %esi
c0102097:	5d                   	pop    %ebp
c0102098:	c3                   	ret    

c0102099 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102099:	55                   	push   %ebp
c010209a:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010209c:	fb                   	sti    
}
c010209d:	90                   	nop
    sti();
}
c010209e:	90                   	nop
c010209f:	5d                   	pop    %ebp
c01020a0:	c3                   	ret    

c01020a1 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020a1:	55                   	push   %ebp
c01020a2:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c01020a4:	fa                   	cli    
}
c01020a5:	90                   	nop
    cli();
}
c01020a6:	90                   	nop
c01020a7:	5d                   	pop    %ebp
c01020a8:	c3                   	ret    

c01020a9 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01020a9:	55                   	push   %ebp
c01020aa:	89 e5                	mov    %esp,%ebp
c01020ac:	83 ec 14             	sub    $0x14,%esp
c01020af:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01020b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01020b9:	66 a3 50 f5 12 c0    	mov    %ax,0xc012f550
    if (did_init) {
c01020bf:	a1 60 37 1a c0       	mov    0xc01a3760,%eax
c01020c4:	85 c0                	test   %eax,%eax
c01020c6:	74 39                	je     c0102101 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c01020c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01020cb:	0f b6 c0             	movzbl %al,%eax
c01020ce:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01020d4:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020d7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020db:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020df:	ee                   	out    %al,(%dx)
}
c01020e0:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01020e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01020e5:	c1 e8 08             	shr    $0x8,%eax
c01020e8:	0f b7 c0             	movzwl %ax,%eax
c01020eb:	0f b6 c0             	movzbl %al,%eax
c01020ee:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01020f4:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f7:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020fb:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020ff:	ee                   	out    %al,(%dx)
}
c0102100:	90                   	nop
    }
}
c0102101:	90                   	nop
c0102102:	89 ec                	mov    %ebp,%esp
c0102104:	5d                   	pop    %ebp
c0102105:	c3                   	ret    

c0102106 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102106:	55                   	push   %ebp
c0102107:	89 e5                	mov    %esp,%ebp
c0102109:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010210c:	8b 45 08             	mov    0x8(%ebp),%eax
c010210f:	ba 01 00 00 00       	mov    $0x1,%edx
c0102114:	88 c1                	mov    %al,%cl
c0102116:	d3 e2                	shl    %cl,%edx
c0102118:	89 d0                	mov    %edx,%eax
c010211a:	98                   	cwtl   
c010211b:	f7 d0                	not    %eax
c010211d:	0f bf d0             	movswl %ax,%edx
c0102120:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c0102127:	98                   	cwtl   
c0102128:	21 d0                	and    %edx,%eax
c010212a:	98                   	cwtl   
c010212b:	0f b7 c0             	movzwl %ax,%eax
c010212e:	89 04 24             	mov    %eax,(%esp)
c0102131:	e8 73 ff ff ff       	call   c01020a9 <pic_setmask>
}
c0102136:	90                   	nop
c0102137:	89 ec                	mov    %ebp,%esp
c0102139:	5d                   	pop    %ebp
c010213a:	c3                   	ret    

c010213b <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010213b:	55                   	push   %ebp
c010213c:	89 e5                	mov    %esp,%ebp
c010213e:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0102141:	c7 05 60 37 1a c0 01 	movl   $0x1,0xc01a3760
c0102148:	00 00 00 
c010214b:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102151:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102155:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102159:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010215d:	ee                   	out    %al,(%dx)
}
c010215e:	90                   	nop
c010215f:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0102165:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102169:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010216d:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102171:	ee                   	out    %al,(%dx)
}
c0102172:	90                   	nop
c0102173:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0102179:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010217d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102181:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102185:	ee                   	out    %al,(%dx)
}
c0102186:	90                   	nop
c0102187:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010218d:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102191:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102195:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0102199:	ee                   	out    %al,(%dx)
}
c010219a:	90                   	nop
c010219b:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01021a1:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021a5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021a9:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021ad:	ee                   	out    %al,(%dx)
}
c01021ae:	90                   	nop
c01021af:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01021b5:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021b9:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01021bd:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01021c1:	ee                   	out    %al,(%dx)
}
c01021c2:	90                   	nop
c01021c3:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01021c9:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021cd:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01021d1:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01021d5:	ee                   	out    %al,(%dx)
}
c01021d6:	90                   	nop
c01021d7:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01021dd:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021e1:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01021e5:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01021e9:	ee                   	out    %al,(%dx)
}
c01021ea:	90                   	nop
c01021eb:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01021f1:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021f5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01021f9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01021fd:	ee                   	out    %al,(%dx)
}
c01021fe:	90                   	nop
c01021ff:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102205:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102209:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010220d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102211:	ee                   	out    %al,(%dx)
}
c0102212:	90                   	nop
c0102213:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102219:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010221d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102221:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102225:	ee                   	out    %al,(%dx)
}
c0102226:	90                   	nop
c0102227:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010222d:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102231:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102235:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102239:	ee                   	out    %al,(%dx)
}
c010223a:	90                   	nop
c010223b:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102241:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102245:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102249:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010224d:	ee                   	out    %al,(%dx)
}
c010224e:	90                   	nop
c010224f:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102255:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102259:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010225d:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102261:	ee                   	out    %al,(%dx)
}
c0102262:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102263:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c010226a:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010226f:	74 0f                	je     c0102280 <pic_init+0x145>
        pic_setmask(irq_mask);
c0102271:	0f b7 05 50 f5 12 c0 	movzwl 0xc012f550,%eax
c0102278:	89 04 24             	mov    %eax,(%esp)
c010227b:	e8 29 fe ff ff       	call   c01020a9 <pic_setmask>
    }
}
c0102280:	90                   	nop
c0102281:	89 ec                	mov    %ebp,%esp
c0102283:	5d                   	pop    %ebp
c0102284:	c3                   	ret    

c0102285 <print_ticks>:
#include <x86.h>

#define TICK_NUM 100

static void
print_ticks() {
c0102285:	55                   	push   %ebp
c0102286:	89 e5                	mov    %esp,%ebp
c0102288:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n", TICK_NUM);
c010228b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102292:	00 
c0102293:	c7 04 24 e0 c5 10 c0 	movl   $0xc010c5e0,(%esp)
c010229a:	e8 ce e0 ff ff       	call   c010036d <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010229f:	90                   	nop
c01022a0:	89 ec                	mov    %ebp,%esp
c01022a2:	5d                   	pop    %ebp
c01022a3:	c3                   	ret    

c01022a4 <idt_init>:
static struct pseudodesc idt_pd = {
    sizeof(idt) - 1, (uintptr_t)idt};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01022a4:	55                   	push   %ebp
c01022a5:	89 e5                	mov    %esp,%ebp
c01022a7:	83 ec 10             	sub    $0x10,%esp
    /* LAB5 YOUR CODE */
    //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
    //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++) {
c01022aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01022b1:	e9 c4 00 00 00       	jmp    c010237a <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01022b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b9:	8b 04 85 e0 f5 12 c0 	mov    -0x3fed0a20(,%eax,4),%eax
c01022c0:	0f b7 d0             	movzwl %ax,%edx
c01022c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022c6:	66 89 14 c5 80 37 1a 	mov    %dx,-0x3fe5c880(,%eax,8)
c01022cd:	c0 
c01022ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d1:	66 c7 04 c5 82 37 1a 	movw   $0x8,-0x3fe5c87e(,%eax,8)
c01022d8:	c0 08 00 
c01022db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022de:	0f b6 14 c5 84 37 1a 	movzbl -0x3fe5c87c(,%eax,8),%edx
c01022e5:	c0 
c01022e6:	80 e2 e0             	and    $0xe0,%dl
c01022e9:	88 14 c5 84 37 1a c0 	mov    %dl,-0x3fe5c87c(,%eax,8)
c01022f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f3:	0f b6 14 c5 84 37 1a 	movzbl -0x3fe5c87c(,%eax,8),%edx
c01022fa:	c0 
c01022fb:	80 e2 1f             	and    $0x1f,%dl
c01022fe:	88 14 c5 84 37 1a c0 	mov    %dl,-0x3fe5c87c(,%eax,8)
c0102305:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102308:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c010230f:	c0 
c0102310:	80 e2 f0             	and    $0xf0,%dl
c0102313:	80 ca 0e             	or     $0xe,%dl
c0102316:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c010231d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102320:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c0102327:	c0 
c0102328:	80 e2 ef             	and    $0xef,%dl
c010232b:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c0102332:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102335:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c010233c:	c0 
c010233d:	80 e2 9f             	and    $0x9f,%dl
c0102340:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c0102347:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010234a:	0f b6 14 c5 85 37 1a 	movzbl -0x3fe5c87b(,%eax,8),%edx
c0102351:	c0 
c0102352:	80 ca 80             	or     $0x80,%dl
c0102355:	88 14 c5 85 37 1a c0 	mov    %dl,-0x3fe5c87b(,%eax,8)
c010235c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010235f:	8b 04 85 e0 f5 12 c0 	mov    -0x3fed0a20(,%eax,4),%eax
c0102366:	c1 e8 10             	shr    $0x10,%eax
c0102369:	0f b7 d0             	movzwl %ax,%edx
c010236c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010236f:	66 89 14 c5 86 37 1a 	mov    %dx,-0x3fe5c87a(,%eax,8)
c0102376:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++) {
c0102377:	ff 45 fc             	incl   -0x4(%ebp)
c010237a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010237d:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102382:	0f 86 2e ff ff ff    	jbe    c01022b6 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0102388:	a1 c4 f7 12 c0       	mov    0xc012f7c4,%eax
c010238d:	0f b7 c0             	movzwl %ax,%eax
c0102390:	66 a3 48 3b 1a c0    	mov    %ax,0xc01a3b48
c0102396:	66 c7 05 4a 3b 1a c0 	movw   $0x8,0xc01a3b4a
c010239d:	08 00 
c010239f:	0f b6 05 4c 3b 1a c0 	movzbl 0xc01a3b4c,%eax
c01023a6:	24 e0                	and    $0xe0,%al
c01023a8:	a2 4c 3b 1a c0       	mov    %al,0xc01a3b4c
c01023ad:	0f b6 05 4c 3b 1a c0 	movzbl 0xc01a3b4c,%eax
c01023b4:	24 1f                	and    $0x1f,%al
c01023b6:	a2 4c 3b 1a c0       	mov    %al,0xc01a3b4c
c01023bb:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01023c2:	24 f0                	and    $0xf0,%al
c01023c4:	0c 0e                	or     $0xe,%al
c01023c6:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01023cb:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01023d2:	24 ef                	and    $0xef,%al
c01023d4:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01023d9:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01023e0:	0c 60                	or     $0x60,%al
c01023e2:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01023e7:	0f b6 05 4d 3b 1a c0 	movzbl 0xc01a3b4d,%eax
c01023ee:	0c 80                	or     $0x80,%al
c01023f0:	a2 4d 3b 1a c0       	mov    %al,0xc01a3b4d
c01023f5:	a1 c4 f7 12 c0       	mov    0xc012f7c4,%eax
c01023fa:	c1 e8 10             	shr    $0x10,%eax
c01023fd:	0f b7 c0             	movzwl %ax,%eax
c0102400:	66 a3 4e 3b 1a c0    	mov    %ax,0xc01a3b4e
    SETGATE(idt[SYS_CALL], 0, GD_KTEXT, __vectors[SYS_CALL], DPL_USER);
c0102406:	a1 e0 f7 12 c0       	mov    0xc012f7e0,%eax
c010240b:	0f b7 c0             	movzwl %ax,%eax
c010240e:	66 a3 80 3b 1a c0    	mov    %ax,0xc01a3b80
c0102414:	66 c7 05 82 3b 1a c0 	movw   $0x8,0xc01a3b82
c010241b:	08 00 
c010241d:	0f b6 05 84 3b 1a c0 	movzbl 0xc01a3b84,%eax
c0102424:	24 e0                	and    $0xe0,%al
c0102426:	a2 84 3b 1a c0       	mov    %al,0xc01a3b84
c010242b:	0f b6 05 84 3b 1a c0 	movzbl 0xc01a3b84,%eax
c0102432:	24 1f                	and    $0x1f,%al
c0102434:	a2 84 3b 1a c0       	mov    %al,0xc01a3b84
c0102439:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c0102440:	24 f0                	and    $0xf0,%al
c0102442:	0c 0e                	or     $0xe,%al
c0102444:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102449:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c0102450:	24 ef                	and    $0xef,%al
c0102452:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102457:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010245e:	0c 60                	or     $0x60,%al
c0102460:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102465:	0f b6 05 85 3b 1a c0 	movzbl 0xc01a3b85,%eax
c010246c:	0c 80                	or     $0x80,%al
c010246e:	a2 85 3b 1a c0       	mov    %al,0xc01a3b85
c0102473:	a1 e0 f7 12 c0       	mov    0xc012f7e0,%eax
c0102478:	c1 e8 10             	shr    $0x10,%eax
c010247b:	0f b7 c0             	movzwl %ax,%eax
c010247e:	66 a3 86 3b 1a c0    	mov    %ax,0xc01a3b86
c0102484:	c7 45 f8 60 f5 12 c0 	movl   $0xc012f560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010248b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010248e:	0f 01 18             	lidtl  (%eax)
}
c0102491:	90                   	nop
    lidt(&idt_pd);
}
c0102492:	90                   	nop
c0102493:	89 ec                	mov    %ebp,%esp
c0102495:	5d                   	pop    %ebp
c0102496:	c3                   	ret    

c0102497 <trapname>:

static const char *
trapname(int trapno) {
c0102497:	55                   	push   %ebp
c0102498:	89 e5                	mov    %esp,%ebp
        "x87 FPU Floating-Point Error",
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"};

    if (trapno < sizeof(excnames) / sizeof(const char *const)) {
c010249a:	8b 45 08             	mov    0x8(%ebp),%eax
c010249d:	83 f8 13             	cmp    $0x13,%eax
c01024a0:	77 0c                	ja     c01024ae <trapname+0x17>
        return excnames[trapno];
c01024a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a5:	8b 04 85 e0 ca 10 c0 	mov    -0x3fef3520(,%eax,4),%eax
c01024ac:	eb 18                	jmp    c01024c6 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01024ae:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01024b2:	7e 0d                	jle    c01024c1 <trapname+0x2a>
c01024b4:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01024b8:	7f 07                	jg     c01024c1 <trapname+0x2a>
        return "Hardware Interrupt";
c01024ba:	b8 ea c5 10 c0       	mov    $0xc010c5ea,%eax
c01024bf:	eb 05                	jmp    c01024c6 <trapname+0x2f>
    }
    return "(unknown trap)";
c01024c1:	b8 fd c5 10 c0       	mov    $0xc010c5fd,%eax
}
c01024c6:	5d                   	pop    %ebp
c01024c7:	c3                   	ret    

c01024c8 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01024c8:	55                   	push   %ebp
c01024c9:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01024cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024d2:	83 f8 08             	cmp    $0x8,%eax
c01024d5:	0f 94 c0             	sete   %al
c01024d8:	0f b6 c0             	movzbl %al,%eax
}
c01024db:	5d                   	pop    %ebp
c01024dc:	c3                   	ret    

c01024dd <print_trapframe>:
    NULL,
    NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01024dd:	55                   	push   %ebp
c01024de:	89 e5                	mov    %esp,%ebp
c01024e0:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01024e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ea:	c7 04 24 3e c6 10 c0 	movl   $0xc010c63e,(%esp)
c01024f1:	e8 77 de ff ff       	call   c010036d <cprintf>
    print_regs(&tf->tf_regs);
c01024f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f9:	89 04 24             	mov    %eax,(%esp)
c01024fc:	e8 8f 01 00 00       	call   c0102690 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102501:	8b 45 08             	mov    0x8(%ebp),%eax
c0102504:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102508:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250c:	c7 04 24 4f c6 10 c0 	movl   $0xc010c64f,(%esp)
c0102513:	e8 55 de ff ff       	call   c010036d <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102518:	8b 45 08             	mov    0x8(%ebp),%eax
c010251b:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010251f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102523:	c7 04 24 62 c6 10 c0 	movl   $0xc010c662,(%esp)
c010252a:	e8 3e de ff ff       	call   c010036d <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010252f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102532:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102536:	89 44 24 04          	mov    %eax,0x4(%esp)
c010253a:	c7 04 24 75 c6 10 c0 	movl   $0xc010c675,(%esp)
c0102541:	e8 27 de ff ff       	call   c010036d <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102546:	8b 45 08             	mov    0x8(%ebp),%eax
c0102549:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010254d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102551:	c7 04 24 88 c6 10 c0 	movl   $0xc010c688,(%esp)
c0102558:	e8 10 de ff ff       	call   c010036d <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010255d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102560:	8b 40 30             	mov    0x30(%eax),%eax
c0102563:	89 04 24             	mov    %eax,(%esp)
c0102566:	e8 2c ff ff ff       	call   c0102497 <trapname>
c010256b:	8b 55 08             	mov    0x8(%ebp),%edx
c010256e:	8b 52 30             	mov    0x30(%edx),%edx
c0102571:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102575:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102579:	c7 04 24 9b c6 10 c0 	movl   $0xc010c69b,(%esp)
c0102580:	e8 e8 dd ff ff       	call   c010036d <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102585:	8b 45 08             	mov    0x8(%ebp),%eax
c0102588:	8b 40 34             	mov    0x34(%eax),%eax
c010258b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010258f:	c7 04 24 ad c6 10 c0 	movl   $0xc010c6ad,(%esp)
c0102596:	e8 d2 dd ff ff       	call   c010036d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010259b:	8b 45 08             	mov    0x8(%ebp),%eax
c010259e:	8b 40 38             	mov    0x38(%eax),%eax
c01025a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a5:	c7 04 24 bc c6 10 c0 	movl   $0xc010c6bc,(%esp)
c01025ac:	e8 bc dd ff ff       	call   c010036d <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01025b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01025b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025bc:	c7 04 24 cb c6 10 c0 	movl   $0xc010c6cb,(%esp)
c01025c3:	e8 a5 dd ff ff       	call   c010036d <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01025c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cb:	8b 40 40             	mov    0x40(%eax),%eax
c01025ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d2:	c7 04 24 de c6 10 c0 	movl   $0xc010c6de,(%esp)
c01025d9:	e8 8f dd ff ff       	call   c010036d <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1) {
c01025de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01025e5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01025ec:	eb 3d                	jmp    c010262b <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01025ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f1:	8b 50 40             	mov    0x40(%eax),%edx
c01025f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01025f7:	21 d0                	and    %edx,%eax
c01025f9:	85 c0                	test   %eax,%eax
c01025fb:	74 28                	je     c0102625 <print_trapframe+0x148>
c01025fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102600:	8b 04 85 80 f5 12 c0 	mov    -0x3fed0a80(,%eax,4),%eax
c0102607:	85 c0                	test   %eax,%eax
c0102609:	74 1a                	je     c0102625 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c010260b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010260e:	8b 04 85 80 f5 12 c0 	mov    -0x3fed0a80(,%eax,4),%eax
c0102615:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102619:	c7 04 24 ed c6 10 c0 	movl   $0xc010c6ed,(%esp)
c0102620:	e8 48 dd ff ff       	call   c010036d <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i++, j <<= 1) {
c0102625:	ff 45 f4             	incl   -0xc(%ebp)
c0102628:	d1 65 f0             	shll   -0x10(%ebp)
c010262b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010262e:	83 f8 17             	cmp    $0x17,%eax
c0102631:	76 bb                	jbe    c01025ee <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102633:	8b 45 08             	mov    0x8(%ebp),%eax
c0102636:	8b 40 40             	mov    0x40(%eax),%eax
c0102639:	c1 e8 0c             	shr    $0xc,%eax
c010263c:	83 e0 03             	and    $0x3,%eax
c010263f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102643:	c7 04 24 f1 c6 10 c0 	movl   $0xc010c6f1,(%esp)
c010264a:	e8 1e dd ff ff       	call   c010036d <cprintf>

    if (!trap_in_kernel(tf)) {
c010264f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102652:	89 04 24             	mov    %eax,(%esp)
c0102655:	e8 6e fe ff ff       	call   c01024c8 <trap_in_kernel>
c010265a:	85 c0                	test   %eax,%eax
c010265c:	75 2d                	jne    c010268b <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010265e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102661:	8b 40 44             	mov    0x44(%eax),%eax
c0102664:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102668:	c7 04 24 fa c6 10 c0 	movl   $0xc010c6fa,(%esp)
c010266f:	e8 f9 dc ff ff       	call   c010036d <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102674:	8b 45 08             	mov    0x8(%ebp),%eax
c0102677:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010267b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010267f:	c7 04 24 09 c7 10 c0 	movl   $0xc010c709,(%esp)
c0102686:	e8 e2 dc ff ff       	call   c010036d <cprintf>
    }
}
c010268b:	90                   	nop
c010268c:	89 ec                	mov    %ebp,%esp
c010268e:	5d                   	pop    %ebp
c010268f:	c3                   	ret    

c0102690 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102690:	55                   	push   %ebp
c0102691:	89 e5                	mov    %esp,%ebp
c0102693:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102696:	8b 45 08             	mov    0x8(%ebp),%eax
c0102699:	8b 00                	mov    (%eax),%eax
c010269b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010269f:	c7 04 24 1c c7 10 c0 	movl   $0xc010c71c,(%esp)
c01026a6:	e8 c2 dc ff ff       	call   c010036d <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01026ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01026ae:	8b 40 04             	mov    0x4(%eax),%eax
c01026b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026b5:	c7 04 24 2b c7 10 c0 	movl   $0xc010c72b,(%esp)
c01026bc:	e8 ac dc ff ff       	call   c010036d <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01026c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01026c4:	8b 40 08             	mov    0x8(%eax),%eax
c01026c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026cb:	c7 04 24 3a c7 10 c0 	movl   $0xc010c73a,(%esp)
c01026d2:	e8 96 dc ff ff       	call   c010036d <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01026d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026da:	8b 40 0c             	mov    0xc(%eax),%eax
c01026dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026e1:	c7 04 24 49 c7 10 c0 	movl   $0xc010c749,(%esp)
c01026e8:	e8 80 dc ff ff       	call   c010036d <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01026ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f0:	8b 40 10             	mov    0x10(%eax),%eax
c01026f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026f7:	c7 04 24 58 c7 10 c0 	movl   $0xc010c758,(%esp)
c01026fe:	e8 6a dc ff ff       	call   c010036d <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102703:	8b 45 08             	mov    0x8(%ebp),%eax
c0102706:	8b 40 14             	mov    0x14(%eax),%eax
c0102709:	89 44 24 04          	mov    %eax,0x4(%esp)
c010270d:	c7 04 24 67 c7 10 c0 	movl   $0xc010c767,(%esp)
c0102714:	e8 54 dc ff ff       	call   c010036d <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102719:	8b 45 08             	mov    0x8(%ebp),%eax
c010271c:	8b 40 18             	mov    0x18(%eax),%eax
c010271f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102723:	c7 04 24 76 c7 10 c0 	movl   $0xc010c776,(%esp)
c010272a:	e8 3e dc ff ff       	call   c010036d <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010272f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102732:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102735:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102739:	c7 04 24 85 c7 10 c0 	movl   $0xc010c785,(%esp)
c0102740:	e8 28 dc ff ff       	call   c010036d <cprintf>
}
c0102745:	90                   	nop
c0102746:	89 ec                	mov    %ebp,%esp
c0102748:	5d                   	pop    %ebp
c0102749:	c3                   	ret    

c010274a <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010274a:	55                   	push   %ebp
c010274b:	89 e5                	mov    %esp,%ebp
c010274d:	83 ec 38             	sub    $0x38,%esp
c0102750:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102753:	8b 45 08             	mov    0x8(%ebp),%eax
c0102756:	8b 40 34             	mov    0x34(%eax),%eax
c0102759:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010275c:	85 c0                	test   %eax,%eax
c010275e:	74 07                	je     c0102767 <print_pgfault+0x1d>
c0102760:	bb 94 c7 10 c0       	mov    $0xc010c794,%ebx
c0102765:	eb 05                	jmp    c010276c <print_pgfault+0x22>
c0102767:	bb a5 c7 10 c0       	mov    $0xc010c7a5,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010276c:	8b 45 08             	mov    0x8(%ebp),%eax
c010276f:	8b 40 34             	mov    0x34(%eax),%eax
c0102772:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102775:	85 c0                	test   %eax,%eax
c0102777:	74 07                	je     c0102780 <print_pgfault+0x36>
c0102779:	b9 57 00 00 00       	mov    $0x57,%ecx
c010277e:	eb 05                	jmp    c0102785 <print_pgfault+0x3b>
c0102780:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102785:	8b 45 08             	mov    0x8(%ebp),%eax
c0102788:	8b 40 34             	mov    0x34(%eax),%eax
c010278b:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010278e:	85 c0                	test   %eax,%eax
c0102790:	74 07                	je     c0102799 <print_pgfault+0x4f>
c0102792:	ba 55 00 00 00       	mov    $0x55,%edx
c0102797:	eb 05                	jmp    c010279e <print_pgfault+0x54>
c0102799:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010279e:	0f 20 d0             	mov    %cr2,%eax
c01027a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01027a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027a7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c01027ab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01027af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027b7:	c7 04 24 b4 c7 10 c0 	movl   $0xc010c7b4,(%esp)
c01027be:	e8 aa db ff ff       	call   c010036d <cprintf>
}
c01027c3:	90                   	nop
c01027c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01027c7:	89 ec                	mov    %ebp,%esp
c01027c9:	5d                   	pop    %ebp
c01027ca:	c3                   	ret    

c01027cb <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01027cb:	55                   	push   %ebp
c01027cc:	89 e5                	mov    %esp,%ebp
c01027ce:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if (check_mm_struct != NULL) {  //used for test check_swap
c01027d1:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01027d6:	85 c0                	test   %eax,%eax
c01027d8:	74 0b                	je     c01027e5 <pgfault_handler+0x1a>
        print_pgfault(tf);
c01027da:	8b 45 08             	mov    0x8(%ebp),%eax
c01027dd:	89 04 24             	mov    %eax,(%esp)
c01027e0:	e8 65 ff ff ff       	call   c010274a <print_pgfault>
    }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01027e5:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01027ea:	85 c0                	test   %eax,%eax
c01027ec:	74 3d                	je     c010282b <pgfault_handler+0x60>
        assert(current == idleproc);
c01027ee:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c01027f4:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c01027f9:	39 c2                	cmp    %eax,%edx
c01027fb:	74 24                	je     c0102821 <pgfault_handler+0x56>
c01027fd:	c7 44 24 0c d7 c7 10 	movl   $0xc010c7d7,0xc(%esp)
c0102804:	c0 
c0102805:	c7 44 24 08 eb c7 10 	movl   $0xc010c7eb,0x8(%esp)
c010280c:	c0 
c010280d:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0102814:	00 
c0102815:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c010281c:	e8 ca e5 ff ff       	call   c0100deb <__panic>
        mm = check_mm_struct;
c0102821:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0102826:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102829:	eb 46                	jmp    c0102871 <pgfault_handler+0xa6>
    } else {
        if (current == NULL) {
c010282b:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102830:	85 c0                	test   %eax,%eax
c0102832:	75 32                	jne    c0102866 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102834:	8b 45 08             	mov    0x8(%ebp),%eax
c0102837:	89 04 24             	mov    %eax,(%esp)
c010283a:	e8 9e fc ff ff       	call   c01024dd <print_trapframe>
            print_pgfault(tf);
c010283f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102842:	89 04 24             	mov    %eax,(%esp)
c0102845:	e8 00 ff ff ff       	call   c010274a <print_pgfault>
            panic("unhandled page fault.\n");
c010284a:	c7 44 24 08 11 c8 10 	movl   $0xc010c811,0x8(%esp)
c0102851:	c0 
c0102852:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0102859:	00 
c010285a:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c0102861:	e8 85 e5 ff ff       	call   c0100deb <__panic>
        }
        mm = current->mm;
c0102866:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010286b:	8b 40 18             	mov    0x18(%eax),%eax
c010286e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102871:	0f 20 d0             	mov    %cr2,%eax
c0102874:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c0102877:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c010287a:	8b 45 08             	mov    0x8(%ebp),%eax
c010287d:	8b 40 34             	mov    0x34(%eax),%eax
c0102880:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102884:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102888:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010288b:	89 04 24             	mov    %eax,(%esp)
c010288e:	e8 47 68 00 00       	call   c01090da <do_pgfault>
}
c0102893:	89 ec                	mov    %ebp,%esp
c0102895:	5d                   	pop    %ebp
c0102896:	c3                   	ret    

c0102897 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102897:	55                   	push   %ebp
c0102898:	89 e5                	mov    %esp,%ebp
c010289a:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret = 0;
c010289d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01028a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a7:	8b 40 30             	mov    0x30(%eax),%eax
c01028aa:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028af:	0f 84 ef 00 00 00    	je     c01029a4 <trap_dispatch+0x10d>
c01028b5:	3d 80 00 00 00       	cmp    $0x80,%eax
c01028ba:	0f 87 ab 01 00 00    	ja     c0102a6b <trap_dispatch+0x1d4>
c01028c0:	83 f8 2f             	cmp    $0x2f,%eax
c01028c3:	77 1e                	ja     c01028e3 <trap_dispatch+0x4c>
c01028c5:	83 f8 0e             	cmp    $0xe,%eax
c01028c8:	0f 82 9d 01 00 00    	jb     c0102a6b <trap_dispatch+0x1d4>
c01028ce:	83 e8 0e             	sub    $0xe,%eax
c01028d1:	83 f8 21             	cmp    $0x21,%eax
c01028d4:	0f 87 91 01 00 00    	ja     c0102a6b <trap_dispatch+0x1d4>
c01028da:	8b 04 85 14 c9 10 c0 	mov    -0x3fef36ec(,%eax,4),%eax
c01028e1:	ff e0                	jmp    *%eax
c01028e3:	83 e8 78             	sub    $0x78,%eax
c01028e6:	83 f8 01             	cmp    $0x1,%eax
c01028e9:	0f 87 7c 01 00 00    	ja     c0102a6b <trap_dispatch+0x1d4>
c01028ef:	e9 5b 01 00 00       	jmp    c0102a4f <trap_dispatch+0x1b8>
        case T_PGFLT:  //page fault
            if ((ret = pgfault_handler(tf)) != 0) {
c01028f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f7:	89 04 24             	mov    %eax,(%esp)
c01028fa:	e8 cc fe ff ff       	call   c01027cb <pgfault_handler>
c01028ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102902:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102906:	0f 84 aa 01 00 00    	je     c0102ab6 <trap_dispatch+0x21f>
                print_trapframe(tf);
c010290c:	8b 45 08             	mov    0x8(%ebp),%eax
c010290f:	89 04 24             	mov    %eax,(%esp)
c0102912:	e8 c6 fb ff ff       	call   c01024dd <print_trapframe>
                if (current == NULL) {
c0102917:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010291c:	85 c0                	test   %eax,%eax
c010291e:	75 23                	jne    c0102943 <trap_dispatch+0xac>
                    panic("handle pgfault failed. ret=%d\n", ret);
c0102920:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102923:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102927:	c7 44 24 08 28 c8 10 	movl   $0xc010c828,0x8(%esp)
c010292e:	c0 
c010292f:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c0102936:	00 
c0102937:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c010293e:	e8 a8 e4 ff ff       	call   c0100deb <__panic>
                } else {
                    if (trap_in_kernel(tf)) {
c0102943:	8b 45 08             	mov    0x8(%ebp),%eax
c0102946:	89 04 24             	mov    %eax,(%esp)
c0102949:	e8 7a fb ff ff       	call   c01024c8 <trap_in_kernel>
c010294e:	85 c0                	test   %eax,%eax
c0102950:	74 23                	je     c0102975 <trap_dispatch+0xde>
                        panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102955:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102959:	c7 44 24 08 48 c8 10 	movl   $0xc010c848,0x8(%esp)
c0102960:	c0 
c0102961:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0102968:	00 
c0102969:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c0102970:	e8 76 e4 ff ff       	call   c0100deb <__panic>
                    }
                    cprintf("killed by kernel.\n");
c0102975:	c7 04 24 76 c8 10 c0 	movl   $0xc010c876,(%esp)
c010297c:	e8 ec d9 ff ff       	call   c010036d <cprintf>
                    panic("handle user mode pgfault failed. ret=%d\n", ret);
c0102981:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102984:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102988:	c7 44 24 08 8c c8 10 	movl   $0xc010c88c,0x8(%esp)
c010298f:	c0 
c0102990:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0102997:	00 
c0102998:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c010299f:	e8 47 e4 ff ff       	call   c0100deb <__panic>
                    do_exit(-E_KILLED);
                }
            }
            break;
        case T_SYSCALL:
            syscall();
c01029a4:	e8 d0 8a 00 00       	call   c010b479 <syscall>
            break;
c01029a9:	e9 0c 01 00 00       	jmp    c0102aba <trap_dispatch+0x223>
         */
            /* LAB5 YOUR CODE */
            /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
            ticks++;
c01029ae:	a1 24 34 1a c0       	mov    0xc01a3424,%eax
c01029b3:	40                   	inc    %eax
c01029b4:	a3 24 34 1a c0       	mov    %eax,0xc01a3424
            if (ticks % TICK_NUM == 0) {
c01029b9:	8b 0d 24 34 1a c0    	mov    0xc01a3424,%ecx
c01029bf:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01029c4:	89 c8                	mov    %ecx,%eax
c01029c6:	f7 e2                	mul    %edx
c01029c8:	c1 ea 05             	shr    $0x5,%edx
c01029cb:	89 d0                	mov    %edx,%eax
c01029cd:	c1 e0 02             	shl    $0x2,%eax
c01029d0:	01 d0                	add    %edx,%eax
c01029d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01029d9:	01 d0                	add    %edx,%eax
c01029db:	c1 e0 02             	shl    $0x2,%eax
c01029de:	29 c1                	sub    %eax,%ecx
c01029e0:	89 ca                	mov    %ecx,%edx
c01029e2:	85 d2                	test   %edx,%edx
c01029e4:	0f 85 cf 00 00 00    	jne    c0102ab9 <trap_dispatch+0x222>
                print_ticks();
c01029ea:	e8 96 f8 ff ff       	call   c0102285 <print_ticks>
                current->need_resched = 1;
c01029ef:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c01029f4:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
            }
            break;
c01029fb:	e9 b9 00 00 00       	jmp    c0102ab9 <trap_dispatch+0x222>
        case IRQ_OFFSET + IRQ_COM1:
            c = cons_getc();
c0102a00:	e8 c6 ed ff ff       	call   c01017cb <cons_getc>
c0102a05:	88 45 f3             	mov    %al,-0xd(%ebp)
            cprintf("serial [%03d] %c\n", c, c);
c0102a08:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a0c:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a10:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a14:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a18:	c7 04 24 b5 c8 10 c0 	movl   $0xc010c8b5,(%esp)
c0102a1f:	e8 49 d9 ff ff       	call   c010036d <cprintf>
            break;
c0102a24:	e9 91 00 00 00       	jmp    c0102aba <trap_dispatch+0x223>
        case IRQ_OFFSET + IRQ_KBD:
            c = cons_getc();
c0102a29:	e8 9d ed ff ff       	call   c01017cb <cons_getc>
c0102a2e:	88 45 f3             	mov    %al,-0xd(%ebp)
            cprintf("kbd [%03d] %c\n", c, c);
c0102a31:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102a35:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102a39:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102a41:	c7 04 24 c7 c8 10 c0 	movl   $0xc010c8c7,(%esp)
c0102a48:	e8 20 d9 ff ff       	call   c010036d <cprintf>
            break;
c0102a4d:	eb 6b                	jmp    c0102aba <trap_dispatch+0x223>
        //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
        case T_SWITCH_TOU:
        case T_SWITCH_TOK:
            panic("T_SWITCH_** ??\n");
c0102a4f:	c7 44 24 08 d6 c8 10 	movl   $0xc010c8d6,0x8(%esp)
c0102a56:	c0 
c0102a57:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0102a5e:	00 
c0102a5f:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c0102a66:	e8 80 e3 ff ff       	call   c0100deb <__panic>
        case IRQ_OFFSET + IRQ_IDE1:
        case IRQ_OFFSET + IRQ_IDE2:
            /* do nothing */
            break;
        default:
            print_trapframe(tf);
c0102a6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a6e:	89 04 24             	mov    %eax,(%esp)
c0102a71:	e8 67 fa ff ff       	call   c01024dd <print_trapframe>
            if (current != NULL) {
c0102a76:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102a7b:	85 c0                	test   %eax,%eax
c0102a7d:	74 18                	je     c0102a97 <trap_dispatch+0x200>
                cprintf("unhandled trap.\n");
c0102a7f:	c7 04 24 e6 c8 10 c0 	movl   $0xc010c8e6,(%esp)
c0102a86:	e8 e2 d8 ff ff       	call   c010036d <cprintf>
                do_exit(-E_KILLED);
c0102a8b:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a92:	e8 b4 77 00 00       	call   c010a24b <do_exit>
            }
            // in kernel, it must be a mistake
            panic("unexpected trap in kernel.\n");
c0102a97:	c7 44 24 08 f7 c8 10 	movl   $0xc010c8f7,0x8(%esp)
c0102a9e:	c0 
c0102a9f:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0102aa6:	00 
c0102aa7:	c7 04 24 00 c8 10 c0 	movl   $0xc010c800,(%esp)
c0102aae:	e8 38 e3 ff ff       	call   c0100deb <__panic>
            break;
c0102ab3:	90                   	nop
c0102ab4:	eb 04                	jmp    c0102aba <trap_dispatch+0x223>
            break;
c0102ab6:	90                   	nop
c0102ab7:	eb 01                	jmp    c0102aba <trap_dispatch+0x223>
            break;
c0102ab9:	90                   	nop
    }
}
c0102aba:	90                   	nop
c0102abb:	89 ec                	mov    %ebp,%esp
c0102abd:	5d                   	pop    %ebp
c0102abe:	c3                   	ret    

c0102abf <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102abf:	55                   	push   %ebp
c0102ac0:	89 e5                	mov    %esp,%ebp
c0102ac2:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c0102ac5:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102aca:	85 c0                	test   %eax,%eax
c0102acc:	75 0d                	jne    c0102adb <trap+0x1c>
        trap_dispatch(tf);
c0102ace:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ad1:	89 04 24             	mov    %eax,(%esp)
c0102ad4:	e8 be fd ff ff       	call   c0102897 <trap_dispatch>
            if (current->need_resched) {
                schedule();
            }
        }
    }
}
c0102ad9:	eb 6c                	jmp    c0102b47 <trap+0x88>
        struct trapframe *otf = current->tf;
c0102adb:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102ae0:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102ae3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102ae6:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102aeb:	8b 55 08             	mov    0x8(%ebp),%edx
c0102aee:	89 50 3c             	mov    %edx,0x3c(%eax)
        bool in_kernel = trap_in_kernel(tf);
c0102af1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102af4:	89 04 24             	mov    %eax,(%esp)
c0102af7:	e8 cc f9 ff ff       	call   c01024c8 <trap_in_kernel>
c0102afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        trap_dispatch(tf);
c0102aff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b02:	89 04 24             	mov    %eax,(%esp)
c0102b05:	e8 8d fd ff ff       	call   c0102897 <trap_dispatch>
        current->tf = otf;
c0102b0a:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b12:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102b15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102b19:	75 2c                	jne    c0102b47 <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102b1b:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102b20:	8b 40 44             	mov    0x44(%eax),%eax
c0102b23:	83 e0 01             	and    $0x1,%eax
c0102b26:	85 c0                	test   %eax,%eax
c0102b28:	74 0c                	je     c0102b36 <trap+0x77>
                do_exit(-E_KILLED);
c0102b2a:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102b31:	e8 15 77 00 00       	call   c010a24b <do_exit>
            if (current->need_resched) {
c0102b36:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0102b3b:	8b 40 10             	mov    0x10(%eax),%eax
c0102b3e:	85 c0                	test   %eax,%eax
c0102b40:	74 05                	je     c0102b47 <trap+0x88>
                schedule();
c0102b42:	e8 22 87 00 00       	call   c010b269 <schedule>
}
c0102b47:	90                   	nop
c0102b48:	89 ec                	mov    %ebp,%esp
c0102b4a:	5d                   	pop    %ebp
c0102b4b:	c3                   	ret    

c0102b4c <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b4c:	1e                   	push   %ds
    pushl %es
c0102b4d:	06                   	push   %es
    pushl %fs
c0102b4e:	0f a0                	push   %fs
    pushl %gs
c0102b50:	0f a8                	push   %gs
    pushal
c0102b52:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102b53:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102b58:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102b5a:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102b5c:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102b5d:	e8 5d ff ff ff       	call   c0102abf <trap>

    # pop the pushed stack pointer
    popl %esp
c0102b62:	5c                   	pop    %esp

c0102b63 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102b63:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102b64:	0f a9                	pop    %gs
    popl %fs
c0102b66:	0f a1                	pop    %fs
    popl %es
c0102b68:	07                   	pop    %es
    popl %ds
c0102b69:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102b6a:	83 c4 08             	add    $0x8,%esp
    iret
c0102b6d:	cf                   	iret   

c0102b6e <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102b6e:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102b72:	eb ef                	jmp    c0102b63 <__trapret>

c0102b74 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $0
c0102b76:	6a 00                	push   $0x0
  jmp __alltraps
c0102b78:	e9 cf ff ff ff       	jmp    c0102b4c <__alltraps>

c0102b7d <vector1>:
.globl vector1
vector1:
  pushl $0
c0102b7d:	6a 00                	push   $0x0
  pushl $1
c0102b7f:	6a 01                	push   $0x1
  jmp __alltraps
c0102b81:	e9 c6 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102b86 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $2
c0102b88:	6a 02                	push   $0x2
  jmp __alltraps
c0102b8a:	e9 bd ff ff ff       	jmp    c0102b4c <__alltraps>

c0102b8f <vector3>:
.globl vector3
vector3:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $3
c0102b91:	6a 03                	push   $0x3
  jmp __alltraps
c0102b93:	e9 b4 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102b98 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $4
c0102b9a:	6a 04                	push   $0x4
  jmp __alltraps
c0102b9c:	e9 ab ff ff ff       	jmp    c0102b4c <__alltraps>

c0102ba1 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102ba1:	6a 00                	push   $0x0
  pushl $5
c0102ba3:	6a 05                	push   $0x5
  jmp __alltraps
c0102ba5:	e9 a2 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102baa <vector6>:
.globl vector6
vector6:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $6
c0102bac:	6a 06                	push   $0x6
  jmp __alltraps
c0102bae:	e9 99 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bb3 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $7
c0102bb5:	6a 07                	push   $0x7
  jmp __alltraps
c0102bb7:	e9 90 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bbc <vector8>:
.globl vector8
vector8:
  pushl $8
c0102bbc:	6a 08                	push   $0x8
  jmp __alltraps
c0102bbe:	e9 89 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bc3 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102bc3:	6a 00                	push   $0x0
  pushl $9
c0102bc5:	6a 09                	push   $0x9
  jmp __alltraps
c0102bc7:	e9 80 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bcc <vector10>:
.globl vector10
vector10:
  pushl $10
c0102bcc:	6a 0a                	push   $0xa
  jmp __alltraps
c0102bce:	e9 79 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bd3 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102bd3:	6a 0b                	push   $0xb
  jmp __alltraps
c0102bd5:	e9 72 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bda <vector12>:
.globl vector12
vector12:
  pushl $12
c0102bda:	6a 0c                	push   $0xc
  jmp __alltraps
c0102bdc:	e9 6b ff ff ff       	jmp    c0102b4c <__alltraps>

c0102be1 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102be1:	6a 0d                	push   $0xd
  jmp __alltraps
c0102be3:	e9 64 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102be8 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102be8:	6a 0e                	push   $0xe
  jmp __alltraps
c0102bea:	e9 5d ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bef <vector15>:
.globl vector15
vector15:
  pushl $0
c0102bef:	6a 00                	push   $0x0
  pushl $15
c0102bf1:	6a 0f                	push   $0xf
  jmp __alltraps
c0102bf3:	e9 54 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102bf8 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102bf8:	6a 00                	push   $0x0
  pushl $16
c0102bfa:	6a 10                	push   $0x10
  jmp __alltraps
c0102bfc:	e9 4b ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c01 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102c01:	6a 11                	push   $0x11
  jmp __alltraps
c0102c03:	e9 44 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c08 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $18
c0102c0a:	6a 12                	push   $0x12
  jmp __alltraps
c0102c0c:	e9 3b ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c11 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $19
c0102c13:	6a 13                	push   $0x13
  jmp __alltraps
c0102c15:	e9 32 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c1a <vector20>:
.globl vector20
vector20:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $20
c0102c1c:	6a 14                	push   $0x14
  jmp __alltraps
c0102c1e:	e9 29 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c23 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $21
c0102c25:	6a 15                	push   $0x15
  jmp __alltraps
c0102c27:	e9 20 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c2c <vector22>:
.globl vector22
vector22:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $22
c0102c2e:	6a 16                	push   $0x16
  jmp __alltraps
c0102c30:	e9 17 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c35 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $23
c0102c37:	6a 17                	push   $0x17
  jmp __alltraps
c0102c39:	e9 0e ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c3e <vector24>:
.globl vector24
vector24:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $24
c0102c40:	6a 18                	push   $0x18
  jmp __alltraps
c0102c42:	e9 05 ff ff ff       	jmp    c0102b4c <__alltraps>

c0102c47 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $25
c0102c49:	6a 19                	push   $0x19
  jmp __alltraps
c0102c4b:	e9 fc fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c50 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $26
c0102c52:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102c54:	e9 f3 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c59 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $27
c0102c5b:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102c5d:	e9 ea fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c62 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $28
c0102c64:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102c66:	e9 e1 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c6b <vector29>:
.globl vector29
vector29:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $29
c0102c6d:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102c6f:	e9 d8 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c74 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $30
c0102c76:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102c78:	e9 cf fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c7d <vector31>:
.globl vector31
vector31:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $31
c0102c7f:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102c81:	e9 c6 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c86 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $32
c0102c88:	6a 20                	push   $0x20
  jmp __alltraps
c0102c8a:	e9 bd fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c8f <vector33>:
.globl vector33
vector33:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $33
c0102c91:	6a 21                	push   $0x21
  jmp __alltraps
c0102c93:	e9 b4 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102c98 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $34
c0102c9a:	6a 22                	push   $0x22
  jmp __alltraps
c0102c9c:	e9 ab fe ff ff       	jmp    c0102b4c <__alltraps>

c0102ca1 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $35
c0102ca3:	6a 23                	push   $0x23
  jmp __alltraps
c0102ca5:	e9 a2 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102caa <vector36>:
.globl vector36
vector36:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $36
c0102cac:	6a 24                	push   $0x24
  jmp __alltraps
c0102cae:	e9 99 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cb3 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $37
c0102cb5:	6a 25                	push   $0x25
  jmp __alltraps
c0102cb7:	e9 90 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cbc <vector38>:
.globl vector38
vector38:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $38
c0102cbe:	6a 26                	push   $0x26
  jmp __alltraps
c0102cc0:	e9 87 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cc5 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $39
c0102cc7:	6a 27                	push   $0x27
  jmp __alltraps
c0102cc9:	e9 7e fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cce <vector40>:
.globl vector40
vector40:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $40
c0102cd0:	6a 28                	push   $0x28
  jmp __alltraps
c0102cd2:	e9 75 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cd7 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $41
c0102cd9:	6a 29                	push   $0x29
  jmp __alltraps
c0102cdb:	e9 6c fe ff ff       	jmp    c0102b4c <__alltraps>

c0102ce0 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $42
c0102ce2:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102ce4:	e9 63 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102ce9 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $43
c0102ceb:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102ced:	e9 5a fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cf2 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $44
c0102cf4:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102cf6:	e9 51 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102cfb <vector45>:
.globl vector45
vector45:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $45
c0102cfd:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102cff:	e9 48 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d04 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $46
c0102d06:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102d08:	e9 3f fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d0d <vector47>:
.globl vector47
vector47:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $47
c0102d0f:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102d11:	e9 36 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d16 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $48
c0102d18:	6a 30                	push   $0x30
  jmp __alltraps
c0102d1a:	e9 2d fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d1f <vector49>:
.globl vector49
vector49:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $49
c0102d21:	6a 31                	push   $0x31
  jmp __alltraps
c0102d23:	e9 24 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d28 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $50
c0102d2a:	6a 32                	push   $0x32
  jmp __alltraps
c0102d2c:	e9 1b fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d31 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $51
c0102d33:	6a 33                	push   $0x33
  jmp __alltraps
c0102d35:	e9 12 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d3a <vector52>:
.globl vector52
vector52:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $52
c0102d3c:	6a 34                	push   $0x34
  jmp __alltraps
c0102d3e:	e9 09 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d43 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $53
c0102d45:	6a 35                	push   $0x35
  jmp __alltraps
c0102d47:	e9 00 fe ff ff       	jmp    c0102b4c <__alltraps>

c0102d4c <vector54>:
.globl vector54
vector54:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $54
c0102d4e:	6a 36                	push   $0x36
  jmp __alltraps
c0102d50:	e9 f7 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d55 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $55
c0102d57:	6a 37                	push   $0x37
  jmp __alltraps
c0102d59:	e9 ee fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d5e <vector56>:
.globl vector56
vector56:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $56
c0102d60:	6a 38                	push   $0x38
  jmp __alltraps
c0102d62:	e9 e5 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d67 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $57
c0102d69:	6a 39                	push   $0x39
  jmp __alltraps
c0102d6b:	e9 dc fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d70 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102d70:	6a 00                	push   $0x0
  pushl $58
c0102d72:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102d74:	e9 d3 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d79 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $59
c0102d7b:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102d7d:	e9 ca fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d82 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $60
c0102d84:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102d86:	e9 c1 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d8b <vector61>:
.globl vector61
vector61:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $61
c0102d8d:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102d8f:	e9 b8 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d94 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102d94:	6a 00                	push   $0x0
  pushl $62
c0102d96:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102d98:	e9 af fd ff ff       	jmp    c0102b4c <__alltraps>

c0102d9d <vector63>:
.globl vector63
vector63:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $63
c0102d9f:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102da1:	e9 a6 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102da6 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $64
c0102da8:	6a 40                	push   $0x40
  jmp __alltraps
c0102daa:	e9 9d fd ff ff       	jmp    c0102b4c <__alltraps>

c0102daf <vector65>:
.globl vector65
vector65:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $65
c0102db1:	6a 41                	push   $0x41
  jmp __alltraps
c0102db3:	e9 94 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102db8 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102db8:	6a 00                	push   $0x0
  pushl $66
c0102dba:	6a 42                	push   $0x42
  jmp __alltraps
c0102dbc:	e9 8b fd ff ff       	jmp    c0102b4c <__alltraps>

c0102dc1 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $67
c0102dc3:	6a 43                	push   $0x43
  jmp __alltraps
c0102dc5:	e9 82 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102dca <vector68>:
.globl vector68
vector68:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $68
c0102dcc:	6a 44                	push   $0x44
  jmp __alltraps
c0102dce:	e9 79 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102dd3 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $69
c0102dd5:	6a 45                	push   $0x45
  jmp __alltraps
c0102dd7:	e9 70 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102ddc <vector70>:
.globl vector70
vector70:
  pushl $0
c0102ddc:	6a 00                	push   $0x0
  pushl $70
c0102dde:	6a 46                	push   $0x46
  jmp __alltraps
c0102de0:	e9 67 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102de5 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $71
c0102de7:	6a 47                	push   $0x47
  jmp __alltraps
c0102de9:	e9 5e fd ff ff       	jmp    c0102b4c <__alltraps>

c0102dee <vector72>:
.globl vector72
vector72:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $72
c0102df0:	6a 48                	push   $0x48
  jmp __alltraps
c0102df2:	e9 55 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102df7 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $73
c0102df9:	6a 49                	push   $0x49
  jmp __alltraps
c0102dfb:	e9 4c fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e00 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102e00:	6a 00                	push   $0x0
  pushl $74
c0102e02:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102e04:	e9 43 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e09 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $75
c0102e0b:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102e0d:	e9 3a fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e12 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $76
c0102e14:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102e16:	e9 31 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e1b <vector77>:
.globl vector77
vector77:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $77
c0102e1d:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102e1f:	e9 28 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e24 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102e24:	6a 00                	push   $0x0
  pushl $78
c0102e26:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102e28:	e9 1f fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e2d <vector79>:
.globl vector79
vector79:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $79
c0102e2f:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102e31:	e9 16 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e36 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $80
c0102e38:	6a 50                	push   $0x50
  jmp __alltraps
c0102e3a:	e9 0d fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e3f <vector81>:
.globl vector81
vector81:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $81
c0102e41:	6a 51                	push   $0x51
  jmp __alltraps
c0102e43:	e9 04 fd ff ff       	jmp    c0102b4c <__alltraps>

c0102e48 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $82
c0102e4a:	6a 52                	push   $0x52
  jmp __alltraps
c0102e4c:	e9 fb fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e51 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $83
c0102e53:	6a 53                	push   $0x53
  jmp __alltraps
c0102e55:	e9 f2 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e5a <vector84>:
.globl vector84
vector84:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $84
c0102e5c:	6a 54                	push   $0x54
  jmp __alltraps
c0102e5e:	e9 e9 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e63 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $85
c0102e65:	6a 55                	push   $0x55
  jmp __alltraps
c0102e67:	e9 e0 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e6c <vector86>:
.globl vector86
vector86:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $86
c0102e6e:	6a 56                	push   $0x56
  jmp __alltraps
c0102e70:	e9 d7 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e75 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $87
c0102e77:	6a 57                	push   $0x57
  jmp __alltraps
c0102e79:	e9 ce fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e7e <vector88>:
.globl vector88
vector88:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $88
c0102e80:	6a 58                	push   $0x58
  jmp __alltraps
c0102e82:	e9 c5 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e87 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $89
c0102e89:	6a 59                	push   $0x59
  jmp __alltraps
c0102e8b:	e9 bc fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e90 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $90
c0102e92:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102e94:	e9 b3 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102e99 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $91
c0102e9b:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102e9d:	e9 aa fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ea2 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $92
c0102ea4:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102ea6:	e9 a1 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102eab <vector93>:
.globl vector93
vector93:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $93
c0102ead:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102eaf:	e9 98 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102eb4 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $94
c0102eb6:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102eb8:	e9 8f fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ebd <vector95>:
.globl vector95
vector95:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $95
c0102ebf:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102ec1:	e9 86 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ec6 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $96
c0102ec8:	6a 60                	push   $0x60
  jmp __alltraps
c0102eca:	e9 7d fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ecf <vector97>:
.globl vector97
vector97:
  pushl $0
c0102ecf:	6a 00                	push   $0x0
  pushl $97
c0102ed1:	6a 61                	push   $0x61
  jmp __alltraps
c0102ed3:	e9 74 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ed8 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $98
c0102eda:	6a 62                	push   $0x62
  jmp __alltraps
c0102edc:	e9 6b fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ee1 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $99
c0102ee3:	6a 63                	push   $0x63
  jmp __alltraps
c0102ee5:	e9 62 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102eea <vector100>:
.globl vector100
vector100:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $100
c0102eec:	6a 64                	push   $0x64
  jmp __alltraps
c0102eee:	e9 59 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102ef3 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102ef3:	6a 00                	push   $0x0
  pushl $101
c0102ef5:	6a 65                	push   $0x65
  jmp __alltraps
c0102ef7:	e9 50 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102efc <vector102>:
.globl vector102
vector102:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $102
c0102efe:	6a 66                	push   $0x66
  jmp __alltraps
c0102f00:	e9 47 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f05 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $103
c0102f07:	6a 67                	push   $0x67
  jmp __alltraps
c0102f09:	e9 3e fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f0e <vector104>:
.globl vector104
vector104:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $104
c0102f10:	6a 68                	push   $0x68
  jmp __alltraps
c0102f12:	e9 35 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f17 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $105
c0102f19:	6a 69                	push   $0x69
  jmp __alltraps
c0102f1b:	e9 2c fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f20 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102f20:	6a 00                	push   $0x0
  pushl $106
c0102f22:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102f24:	e9 23 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f29 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $107
c0102f2b:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102f2d:	e9 1a fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f32 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102f32:	6a 00                	push   $0x0
  pushl $108
c0102f34:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102f36:	e9 11 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f3b <vector109>:
.globl vector109
vector109:
  pushl $0
c0102f3b:	6a 00                	push   $0x0
  pushl $109
c0102f3d:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102f3f:	e9 08 fc ff ff       	jmp    c0102b4c <__alltraps>

c0102f44 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102f44:	6a 00                	push   $0x0
  pushl $110
c0102f46:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102f48:	e9 ff fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f4d <vector111>:
.globl vector111
vector111:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $111
c0102f4f:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102f51:	e9 f6 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f56 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102f56:	6a 00                	push   $0x0
  pushl $112
c0102f58:	6a 70                	push   $0x70
  jmp __alltraps
c0102f5a:	e9 ed fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f5f <vector113>:
.globl vector113
vector113:
  pushl $0
c0102f5f:	6a 00                	push   $0x0
  pushl $113
c0102f61:	6a 71                	push   $0x71
  jmp __alltraps
c0102f63:	e9 e4 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f68 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102f68:	6a 00                	push   $0x0
  pushl $114
c0102f6a:	6a 72                	push   $0x72
  jmp __alltraps
c0102f6c:	e9 db fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f71 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $115
c0102f73:	6a 73                	push   $0x73
  jmp __alltraps
c0102f75:	e9 d2 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f7a <vector116>:
.globl vector116
vector116:
  pushl $0
c0102f7a:	6a 00                	push   $0x0
  pushl $116
c0102f7c:	6a 74                	push   $0x74
  jmp __alltraps
c0102f7e:	e9 c9 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f83 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102f83:	6a 00                	push   $0x0
  pushl $117
c0102f85:	6a 75                	push   $0x75
  jmp __alltraps
c0102f87:	e9 c0 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f8c <vector118>:
.globl vector118
vector118:
  pushl $0
c0102f8c:	6a 00                	push   $0x0
  pushl $118
c0102f8e:	6a 76                	push   $0x76
  jmp __alltraps
c0102f90:	e9 b7 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f95 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $119
c0102f97:	6a 77                	push   $0x77
  jmp __alltraps
c0102f99:	e9 ae fb ff ff       	jmp    c0102b4c <__alltraps>

c0102f9e <vector120>:
.globl vector120
vector120:
  pushl $0
c0102f9e:	6a 00                	push   $0x0
  pushl $120
c0102fa0:	6a 78                	push   $0x78
  jmp __alltraps
c0102fa2:	e9 a5 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fa7 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102fa7:	6a 00                	push   $0x0
  pushl $121
c0102fa9:	6a 79                	push   $0x79
  jmp __alltraps
c0102fab:	e9 9c fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fb0 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102fb0:	6a 00                	push   $0x0
  pushl $122
c0102fb2:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102fb4:	e9 93 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fb9 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $123
c0102fbb:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102fbd:	e9 8a fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fc2 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102fc2:	6a 00                	push   $0x0
  pushl $124
c0102fc4:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102fc6:	e9 81 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fcb <vector125>:
.globl vector125
vector125:
  pushl $0
c0102fcb:	6a 00                	push   $0x0
  pushl $125
c0102fcd:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102fcf:	e9 78 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fd4 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102fd4:	6a 00                	push   $0x0
  pushl $126
c0102fd6:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102fd8:	e9 6f fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fdd <vector127>:
.globl vector127
vector127:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $127
c0102fdf:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102fe1:	e9 66 fb ff ff       	jmp    c0102b4c <__alltraps>

c0102fe6 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102fe6:	6a 00                	push   $0x0
  pushl $128
c0102fe8:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102fed:	e9 5a fb ff ff       	jmp    c0102b4c <__alltraps>

c0102ff2 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102ff2:	6a 00                	push   $0x0
  pushl $129
c0102ff4:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ff9:	e9 4e fb ff ff       	jmp    c0102b4c <__alltraps>

c0102ffe <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ffe:	6a 00                	push   $0x0
  pushl $130
c0103000:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0103005:	e9 42 fb ff ff       	jmp    c0102b4c <__alltraps>

c010300a <vector131>:
.globl vector131
vector131:
  pushl $0
c010300a:	6a 00                	push   $0x0
  pushl $131
c010300c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103011:	e9 36 fb ff ff       	jmp    c0102b4c <__alltraps>

c0103016 <vector132>:
.globl vector132
vector132:
  pushl $0
c0103016:	6a 00                	push   $0x0
  pushl $132
c0103018:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010301d:	e9 2a fb ff ff       	jmp    c0102b4c <__alltraps>

c0103022 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103022:	6a 00                	push   $0x0
  pushl $133
c0103024:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103029:	e9 1e fb ff ff       	jmp    c0102b4c <__alltraps>

c010302e <vector134>:
.globl vector134
vector134:
  pushl $0
c010302e:	6a 00                	push   $0x0
  pushl $134
c0103030:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0103035:	e9 12 fb ff ff       	jmp    c0102b4c <__alltraps>

c010303a <vector135>:
.globl vector135
vector135:
  pushl $0
c010303a:	6a 00                	push   $0x0
  pushl $135
c010303c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103041:	e9 06 fb ff ff       	jmp    c0102b4c <__alltraps>

c0103046 <vector136>:
.globl vector136
vector136:
  pushl $0
c0103046:	6a 00                	push   $0x0
  pushl $136
c0103048:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010304d:	e9 fa fa ff ff       	jmp    c0102b4c <__alltraps>

c0103052 <vector137>:
.globl vector137
vector137:
  pushl $0
c0103052:	6a 00                	push   $0x0
  pushl $137
c0103054:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103059:	e9 ee fa ff ff       	jmp    c0102b4c <__alltraps>

c010305e <vector138>:
.globl vector138
vector138:
  pushl $0
c010305e:	6a 00                	push   $0x0
  pushl $138
c0103060:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0103065:	e9 e2 fa ff ff       	jmp    c0102b4c <__alltraps>

c010306a <vector139>:
.globl vector139
vector139:
  pushl $0
c010306a:	6a 00                	push   $0x0
  pushl $139
c010306c:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0103071:	e9 d6 fa ff ff       	jmp    c0102b4c <__alltraps>

c0103076 <vector140>:
.globl vector140
vector140:
  pushl $0
c0103076:	6a 00                	push   $0x0
  pushl $140
c0103078:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010307d:	e9 ca fa ff ff       	jmp    c0102b4c <__alltraps>

c0103082 <vector141>:
.globl vector141
vector141:
  pushl $0
c0103082:	6a 00                	push   $0x0
  pushl $141
c0103084:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0103089:	e9 be fa ff ff       	jmp    c0102b4c <__alltraps>

c010308e <vector142>:
.globl vector142
vector142:
  pushl $0
c010308e:	6a 00                	push   $0x0
  pushl $142
c0103090:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0103095:	e9 b2 fa ff ff       	jmp    c0102b4c <__alltraps>

c010309a <vector143>:
.globl vector143
vector143:
  pushl $0
c010309a:	6a 00                	push   $0x0
  pushl $143
c010309c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01030a1:	e9 a6 fa ff ff       	jmp    c0102b4c <__alltraps>

c01030a6 <vector144>:
.globl vector144
vector144:
  pushl $0
c01030a6:	6a 00                	push   $0x0
  pushl $144
c01030a8:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01030ad:	e9 9a fa ff ff       	jmp    c0102b4c <__alltraps>

c01030b2 <vector145>:
.globl vector145
vector145:
  pushl $0
c01030b2:	6a 00                	push   $0x0
  pushl $145
c01030b4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01030b9:	e9 8e fa ff ff       	jmp    c0102b4c <__alltraps>

c01030be <vector146>:
.globl vector146
vector146:
  pushl $0
c01030be:	6a 00                	push   $0x0
  pushl $146
c01030c0:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01030c5:	e9 82 fa ff ff       	jmp    c0102b4c <__alltraps>

c01030ca <vector147>:
.globl vector147
vector147:
  pushl $0
c01030ca:	6a 00                	push   $0x0
  pushl $147
c01030cc:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01030d1:	e9 76 fa ff ff       	jmp    c0102b4c <__alltraps>

c01030d6 <vector148>:
.globl vector148
vector148:
  pushl $0
c01030d6:	6a 00                	push   $0x0
  pushl $148
c01030d8:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01030dd:	e9 6a fa ff ff       	jmp    c0102b4c <__alltraps>

c01030e2 <vector149>:
.globl vector149
vector149:
  pushl $0
c01030e2:	6a 00                	push   $0x0
  pushl $149
c01030e4:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01030e9:	e9 5e fa ff ff       	jmp    c0102b4c <__alltraps>

c01030ee <vector150>:
.globl vector150
vector150:
  pushl $0
c01030ee:	6a 00                	push   $0x0
  pushl $150
c01030f0:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01030f5:	e9 52 fa ff ff       	jmp    c0102b4c <__alltraps>

c01030fa <vector151>:
.globl vector151
vector151:
  pushl $0
c01030fa:	6a 00                	push   $0x0
  pushl $151
c01030fc:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103101:	e9 46 fa ff ff       	jmp    c0102b4c <__alltraps>

c0103106 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103106:	6a 00                	push   $0x0
  pushl $152
c0103108:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010310d:	e9 3a fa ff ff       	jmp    c0102b4c <__alltraps>

c0103112 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103112:	6a 00                	push   $0x0
  pushl $153
c0103114:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0103119:	e9 2e fa ff ff       	jmp    c0102b4c <__alltraps>

c010311e <vector154>:
.globl vector154
vector154:
  pushl $0
c010311e:	6a 00                	push   $0x0
  pushl $154
c0103120:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103125:	e9 22 fa ff ff       	jmp    c0102b4c <__alltraps>

c010312a <vector155>:
.globl vector155
vector155:
  pushl $0
c010312a:	6a 00                	push   $0x0
  pushl $155
c010312c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103131:	e9 16 fa ff ff       	jmp    c0102b4c <__alltraps>

c0103136 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103136:	6a 00                	push   $0x0
  pushl $156
c0103138:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010313d:	e9 0a fa ff ff       	jmp    c0102b4c <__alltraps>

c0103142 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103142:	6a 00                	push   $0x0
  pushl $157
c0103144:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103149:	e9 fe f9 ff ff       	jmp    c0102b4c <__alltraps>

c010314e <vector158>:
.globl vector158
vector158:
  pushl $0
c010314e:	6a 00                	push   $0x0
  pushl $158
c0103150:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103155:	e9 f2 f9 ff ff       	jmp    c0102b4c <__alltraps>

c010315a <vector159>:
.globl vector159
vector159:
  pushl $0
c010315a:	6a 00                	push   $0x0
  pushl $159
c010315c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103161:	e9 e6 f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103166 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103166:	6a 00                	push   $0x0
  pushl $160
c0103168:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010316d:	e9 da f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103172 <vector161>:
.globl vector161
vector161:
  pushl $0
c0103172:	6a 00                	push   $0x0
  pushl $161
c0103174:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103179:	e9 ce f9 ff ff       	jmp    c0102b4c <__alltraps>

c010317e <vector162>:
.globl vector162
vector162:
  pushl $0
c010317e:	6a 00                	push   $0x0
  pushl $162
c0103180:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0103185:	e9 c2 f9 ff ff       	jmp    c0102b4c <__alltraps>

c010318a <vector163>:
.globl vector163
vector163:
  pushl $0
c010318a:	6a 00                	push   $0x0
  pushl $163
c010318c:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0103191:	e9 b6 f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103196 <vector164>:
.globl vector164
vector164:
  pushl $0
c0103196:	6a 00                	push   $0x0
  pushl $164
c0103198:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010319d:	e9 aa f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031a2 <vector165>:
.globl vector165
vector165:
  pushl $0
c01031a2:	6a 00                	push   $0x0
  pushl $165
c01031a4:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01031a9:	e9 9e f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031ae <vector166>:
.globl vector166
vector166:
  pushl $0
c01031ae:	6a 00                	push   $0x0
  pushl $166
c01031b0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01031b5:	e9 92 f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031ba <vector167>:
.globl vector167
vector167:
  pushl $0
c01031ba:	6a 00                	push   $0x0
  pushl $167
c01031bc:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01031c1:	e9 86 f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031c6 <vector168>:
.globl vector168
vector168:
  pushl $0
c01031c6:	6a 00                	push   $0x0
  pushl $168
c01031c8:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01031cd:	e9 7a f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031d2 <vector169>:
.globl vector169
vector169:
  pushl $0
c01031d2:	6a 00                	push   $0x0
  pushl $169
c01031d4:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01031d9:	e9 6e f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031de <vector170>:
.globl vector170
vector170:
  pushl $0
c01031de:	6a 00                	push   $0x0
  pushl $170
c01031e0:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01031e5:	e9 62 f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031ea <vector171>:
.globl vector171
vector171:
  pushl $0
c01031ea:	6a 00                	push   $0x0
  pushl $171
c01031ec:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01031f1:	e9 56 f9 ff ff       	jmp    c0102b4c <__alltraps>

c01031f6 <vector172>:
.globl vector172
vector172:
  pushl $0
c01031f6:	6a 00                	push   $0x0
  pushl $172
c01031f8:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01031fd:	e9 4a f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103202 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103202:	6a 00                	push   $0x0
  pushl $173
c0103204:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0103209:	e9 3e f9 ff ff       	jmp    c0102b4c <__alltraps>

c010320e <vector174>:
.globl vector174
vector174:
  pushl $0
c010320e:	6a 00                	push   $0x0
  pushl $174
c0103210:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103215:	e9 32 f9 ff ff       	jmp    c0102b4c <__alltraps>

c010321a <vector175>:
.globl vector175
vector175:
  pushl $0
c010321a:	6a 00                	push   $0x0
  pushl $175
c010321c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103221:	e9 26 f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103226 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103226:	6a 00                	push   $0x0
  pushl $176
c0103228:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010322d:	e9 1a f9 ff ff       	jmp    c0102b4c <__alltraps>

c0103232 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103232:	6a 00                	push   $0x0
  pushl $177
c0103234:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103239:	e9 0e f9 ff ff       	jmp    c0102b4c <__alltraps>

c010323e <vector178>:
.globl vector178
vector178:
  pushl $0
c010323e:	6a 00                	push   $0x0
  pushl $178
c0103240:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103245:	e9 02 f9 ff ff       	jmp    c0102b4c <__alltraps>

c010324a <vector179>:
.globl vector179
vector179:
  pushl $0
c010324a:	6a 00                	push   $0x0
  pushl $179
c010324c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103251:	e9 f6 f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103256 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103256:	6a 00                	push   $0x0
  pushl $180
c0103258:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010325d:	e9 ea f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103262 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103262:	6a 00                	push   $0x0
  pushl $181
c0103264:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103269:	e9 de f8 ff ff       	jmp    c0102b4c <__alltraps>

c010326e <vector182>:
.globl vector182
vector182:
  pushl $0
c010326e:	6a 00                	push   $0x0
  pushl $182
c0103270:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103275:	e9 d2 f8 ff ff       	jmp    c0102b4c <__alltraps>

c010327a <vector183>:
.globl vector183
vector183:
  pushl $0
c010327a:	6a 00                	push   $0x0
  pushl $183
c010327c:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0103281:	e9 c6 f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103286 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103286:	6a 00                	push   $0x0
  pushl $184
c0103288:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010328d:	e9 ba f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103292 <vector185>:
.globl vector185
vector185:
  pushl $0
c0103292:	6a 00                	push   $0x0
  pushl $185
c0103294:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103299:	e9 ae f8 ff ff       	jmp    c0102b4c <__alltraps>

c010329e <vector186>:
.globl vector186
vector186:
  pushl $0
c010329e:	6a 00                	push   $0x0
  pushl $186
c01032a0:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01032a5:	e9 a2 f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032aa <vector187>:
.globl vector187
vector187:
  pushl $0
c01032aa:	6a 00                	push   $0x0
  pushl $187
c01032ac:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01032b1:	e9 96 f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032b6 <vector188>:
.globl vector188
vector188:
  pushl $0
c01032b6:	6a 00                	push   $0x0
  pushl $188
c01032b8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01032bd:	e9 8a f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032c2 <vector189>:
.globl vector189
vector189:
  pushl $0
c01032c2:	6a 00                	push   $0x0
  pushl $189
c01032c4:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01032c9:	e9 7e f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032ce <vector190>:
.globl vector190
vector190:
  pushl $0
c01032ce:	6a 00                	push   $0x0
  pushl $190
c01032d0:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01032d5:	e9 72 f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032da <vector191>:
.globl vector191
vector191:
  pushl $0
c01032da:	6a 00                	push   $0x0
  pushl $191
c01032dc:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01032e1:	e9 66 f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032e6 <vector192>:
.globl vector192
vector192:
  pushl $0
c01032e6:	6a 00                	push   $0x0
  pushl $192
c01032e8:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01032ed:	e9 5a f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032f2 <vector193>:
.globl vector193
vector193:
  pushl $0
c01032f2:	6a 00                	push   $0x0
  pushl $193
c01032f4:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01032f9:	e9 4e f8 ff ff       	jmp    c0102b4c <__alltraps>

c01032fe <vector194>:
.globl vector194
vector194:
  pushl $0
c01032fe:	6a 00                	push   $0x0
  pushl $194
c0103300:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103305:	e9 42 f8 ff ff       	jmp    c0102b4c <__alltraps>

c010330a <vector195>:
.globl vector195
vector195:
  pushl $0
c010330a:	6a 00                	push   $0x0
  pushl $195
c010330c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103311:	e9 36 f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103316 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103316:	6a 00                	push   $0x0
  pushl $196
c0103318:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010331d:	e9 2a f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103322 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103322:	6a 00                	push   $0x0
  pushl $197
c0103324:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103329:	e9 1e f8 ff ff       	jmp    c0102b4c <__alltraps>

c010332e <vector198>:
.globl vector198
vector198:
  pushl $0
c010332e:	6a 00                	push   $0x0
  pushl $198
c0103330:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103335:	e9 12 f8 ff ff       	jmp    c0102b4c <__alltraps>

c010333a <vector199>:
.globl vector199
vector199:
  pushl $0
c010333a:	6a 00                	push   $0x0
  pushl $199
c010333c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103341:	e9 06 f8 ff ff       	jmp    c0102b4c <__alltraps>

c0103346 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103346:	6a 00                	push   $0x0
  pushl $200
c0103348:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010334d:	e9 fa f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103352 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103352:	6a 00                	push   $0x0
  pushl $201
c0103354:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103359:	e9 ee f7 ff ff       	jmp    c0102b4c <__alltraps>

c010335e <vector202>:
.globl vector202
vector202:
  pushl $0
c010335e:	6a 00                	push   $0x0
  pushl $202
c0103360:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103365:	e9 e2 f7 ff ff       	jmp    c0102b4c <__alltraps>

c010336a <vector203>:
.globl vector203
vector203:
  pushl $0
c010336a:	6a 00                	push   $0x0
  pushl $203
c010336c:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103371:	e9 d6 f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103376 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103376:	6a 00                	push   $0x0
  pushl $204
c0103378:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010337d:	e9 ca f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103382 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103382:	6a 00                	push   $0x0
  pushl $205
c0103384:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103389:	e9 be f7 ff ff       	jmp    c0102b4c <__alltraps>

c010338e <vector206>:
.globl vector206
vector206:
  pushl $0
c010338e:	6a 00                	push   $0x0
  pushl $206
c0103390:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0103395:	e9 b2 f7 ff ff       	jmp    c0102b4c <__alltraps>

c010339a <vector207>:
.globl vector207
vector207:
  pushl $0
c010339a:	6a 00                	push   $0x0
  pushl $207
c010339c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01033a1:	e9 a6 f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033a6 <vector208>:
.globl vector208
vector208:
  pushl $0
c01033a6:	6a 00                	push   $0x0
  pushl $208
c01033a8:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01033ad:	e9 9a f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033b2 <vector209>:
.globl vector209
vector209:
  pushl $0
c01033b2:	6a 00                	push   $0x0
  pushl $209
c01033b4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01033b9:	e9 8e f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033be <vector210>:
.globl vector210
vector210:
  pushl $0
c01033be:	6a 00                	push   $0x0
  pushl $210
c01033c0:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01033c5:	e9 82 f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033ca <vector211>:
.globl vector211
vector211:
  pushl $0
c01033ca:	6a 00                	push   $0x0
  pushl $211
c01033cc:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01033d1:	e9 76 f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033d6 <vector212>:
.globl vector212
vector212:
  pushl $0
c01033d6:	6a 00                	push   $0x0
  pushl $212
c01033d8:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01033dd:	e9 6a f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033e2 <vector213>:
.globl vector213
vector213:
  pushl $0
c01033e2:	6a 00                	push   $0x0
  pushl $213
c01033e4:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01033e9:	e9 5e f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033ee <vector214>:
.globl vector214
vector214:
  pushl $0
c01033ee:	6a 00                	push   $0x0
  pushl $214
c01033f0:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01033f5:	e9 52 f7 ff ff       	jmp    c0102b4c <__alltraps>

c01033fa <vector215>:
.globl vector215
vector215:
  pushl $0
c01033fa:	6a 00                	push   $0x0
  pushl $215
c01033fc:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103401:	e9 46 f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103406 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103406:	6a 00                	push   $0x0
  pushl $216
c0103408:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010340d:	e9 3a f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103412 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103412:	6a 00                	push   $0x0
  pushl $217
c0103414:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103419:	e9 2e f7 ff ff       	jmp    c0102b4c <__alltraps>

c010341e <vector218>:
.globl vector218
vector218:
  pushl $0
c010341e:	6a 00                	push   $0x0
  pushl $218
c0103420:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103425:	e9 22 f7 ff ff       	jmp    c0102b4c <__alltraps>

c010342a <vector219>:
.globl vector219
vector219:
  pushl $0
c010342a:	6a 00                	push   $0x0
  pushl $219
c010342c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103431:	e9 16 f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103436 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103436:	6a 00                	push   $0x0
  pushl $220
c0103438:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010343d:	e9 0a f7 ff ff       	jmp    c0102b4c <__alltraps>

c0103442 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103442:	6a 00                	push   $0x0
  pushl $221
c0103444:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103449:	e9 fe f6 ff ff       	jmp    c0102b4c <__alltraps>

c010344e <vector222>:
.globl vector222
vector222:
  pushl $0
c010344e:	6a 00                	push   $0x0
  pushl $222
c0103450:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103455:	e9 f2 f6 ff ff       	jmp    c0102b4c <__alltraps>

c010345a <vector223>:
.globl vector223
vector223:
  pushl $0
c010345a:	6a 00                	push   $0x0
  pushl $223
c010345c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103461:	e9 e6 f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103466 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103466:	6a 00                	push   $0x0
  pushl $224
c0103468:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010346d:	e9 da f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103472 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103472:	6a 00                	push   $0x0
  pushl $225
c0103474:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103479:	e9 ce f6 ff ff       	jmp    c0102b4c <__alltraps>

c010347e <vector226>:
.globl vector226
vector226:
  pushl $0
c010347e:	6a 00                	push   $0x0
  pushl $226
c0103480:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103485:	e9 c2 f6 ff ff       	jmp    c0102b4c <__alltraps>

c010348a <vector227>:
.globl vector227
vector227:
  pushl $0
c010348a:	6a 00                	push   $0x0
  pushl $227
c010348c:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103491:	e9 b6 f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103496 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103496:	6a 00                	push   $0x0
  pushl $228
c0103498:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010349d:	e9 aa f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034a2 <vector229>:
.globl vector229
vector229:
  pushl $0
c01034a2:	6a 00                	push   $0x0
  pushl $229
c01034a4:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01034a9:	e9 9e f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034ae <vector230>:
.globl vector230
vector230:
  pushl $0
c01034ae:	6a 00                	push   $0x0
  pushl $230
c01034b0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01034b5:	e9 92 f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034ba <vector231>:
.globl vector231
vector231:
  pushl $0
c01034ba:	6a 00                	push   $0x0
  pushl $231
c01034bc:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01034c1:	e9 86 f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034c6 <vector232>:
.globl vector232
vector232:
  pushl $0
c01034c6:	6a 00                	push   $0x0
  pushl $232
c01034c8:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01034cd:	e9 7a f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034d2 <vector233>:
.globl vector233
vector233:
  pushl $0
c01034d2:	6a 00                	push   $0x0
  pushl $233
c01034d4:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01034d9:	e9 6e f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034de <vector234>:
.globl vector234
vector234:
  pushl $0
c01034de:	6a 00                	push   $0x0
  pushl $234
c01034e0:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01034e5:	e9 62 f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034ea <vector235>:
.globl vector235
vector235:
  pushl $0
c01034ea:	6a 00                	push   $0x0
  pushl $235
c01034ec:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01034f1:	e9 56 f6 ff ff       	jmp    c0102b4c <__alltraps>

c01034f6 <vector236>:
.globl vector236
vector236:
  pushl $0
c01034f6:	6a 00                	push   $0x0
  pushl $236
c01034f8:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01034fd:	e9 4a f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103502 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103502:	6a 00                	push   $0x0
  pushl $237
c0103504:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103509:	e9 3e f6 ff ff       	jmp    c0102b4c <__alltraps>

c010350e <vector238>:
.globl vector238
vector238:
  pushl $0
c010350e:	6a 00                	push   $0x0
  pushl $238
c0103510:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103515:	e9 32 f6 ff ff       	jmp    c0102b4c <__alltraps>

c010351a <vector239>:
.globl vector239
vector239:
  pushl $0
c010351a:	6a 00                	push   $0x0
  pushl $239
c010351c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103521:	e9 26 f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103526 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103526:	6a 00                	push   $0x0
  pushl $240
c0103528:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010352d:	e9 1a f6 ff ff       	jmp    c0102b4c <__alltraps>

c0103532 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103532:	6a 00                	push   $0x0
  pushl $241
c0103534:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103539:	e9 0e f6 ff ff       	jmp    c0102b4c <__alltraps>

c010353e <vector242>:
.globl vector242
vector242:
  pushl $0
c010353e:	6a 00                	push   $0x0
  pushl $242
c0103540:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103545:	e9 02 f6 ff ff       	jmp    c0102b4c <__alltraps>

c010354a <vector243>:
.globl vector243
vector243:
  pushl $0
c010354a:	6a 00                	push   $0x0
  pushl $243
c010354c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103551:	e9 f6 f5 ff ff       	jmp    c0102b4c <__alltraps>

c0103556 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103556:	6a 00                	push   $0x0
  pushl $244
c0103558:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010355d:	e9 ea f5 ff ff       	jmp    c0102b4c <__alltraps>

c0103562 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103562:	6a 00                	push   $0x0
  pushl $245
c0103564:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103569:	e9 de f5 ff ff       	jmp    c0102b4c <__alltraps>

c010356e <vector246>:
.globl vector246
vector246:
  pushl $0
c010356e:	6a 00                	push   $0x0
  pushl $246
c0103570:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103575:	e9 d2 f5 ff ff       	jmp    c0102b4c <__alltraps>

c010357a <vector247>:
.globl vector247
vector247:
  pushl $0
c010357a:	6a 00                	push   $0x0
  pushl $247
c010357c:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103581:	e9 c6 f5 ff ff       	jmp    c0102b4c <__alltraps>

c0103586 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103586:	6a 00                	push   $0x0
  pushl $248
c0103588:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010358d:	e9 ba f5 ff ff       	jmp    c0102b4c <__alltraps>

c0103592 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103592:	6a 00                	push   $0x0
  pushl $249
c0103594:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103599:	e9 ae f5 ff ff       	jmp    c0102b4c <__alltraps>

c010359e <vector250>:
.globl vector250
vector250:
  pushl $0
c010359e:	6a 00                	push   $0x0
  pushl $250
c01035a0:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01035a5:	e9 a2 f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035aa <vector251>:
.globl vector251
vector251:
  pushl $0
c01035aa:	6a 00                	push   $0x0
  pushl $251
c01035ac:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01035b1:	e9 96 f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035b6 <vector252>:
.globl vector252
vector252:
  pushl $0
c01035b6:	6a 00                	push   $0x0
  pushl $252
c01035b8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01035bd:	e9 8a f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035c2 <vector253>:
.globl vector253
vector253:
  pushl $0
c01035c2:	6a 00                	push   $0x0
  pushl $253
c01035c4:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01035c9:	e9 7e f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035ce <vector254>:
.globl vector254
vector254:
  pushl $0
c01035ce:	6a 00                	push   $0x0
  pushl $254
c01035d0:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01035d5:	e9 72 f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035da <vector255>:
.globl vector255
vector255:
  pushl $0
c01035da:	6a 00                	push   $0x0
  pushl $255
c01035dc:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01035e1:	e9 66 f5 ff ff       	jmp    c0102b4c <__alltraps>

c01035e6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01035e6:	55                   	push   %ebp
c01035e7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01035e9:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01035ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01035f2:	29 d0                	sub    %edx,%eax
c01035f4:	c1 f8 05             	sar    $0x5,%eax
}
c01035f7:	5d                   	pop    %ebp
c01035f8:	c3                   	ret    

c01035f9 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01035f9:	55                   	push   %ebp
c01035fa:	89 e5                	mov    %esp,%ebp
c01035fc:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01035ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103602:	89 04 24             	mov    %eax,(%esp)
c0103605:	e8 dc ff ff ff       	call   c01035e6 <page2ppn>
c010360a:	c1 e0 0c             	shl    $0xc,%eax
}
c010360d:	89 ec                	mov    %ebp,%esp
c010360f:	5d                   	pop    %ebp
c0103610:	c3                   	ret    

c0103611 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103611:	55                   	push   %ebp
c0103612:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103614:	8b 45 08             	mov    0x8(%ebp),%eax
c0103617:	8b 00                	mov    (%eax),%eax
}
c0103619:	5d                   	pop    %ebp
c010361a:	c3                   	ret    

c010361b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010361b:	55                   	push   %ebp
c010361c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010361e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103621:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103624:	89 10                	mov    %edx,(%eax)
}
c0103626:	90                   	nop
c0103627:	5d                   	pop    %ebp
c0103628:	c3                   	ret    

c0103629 <default_init>:
#define free_list (free_area.free_list) //
#define nr_free (free_area.nr_free)
static void test(void);

static void default_init(void)
{
c0103629:	55                   	push   %ebp
c010362a:	89 e5                	mov    %esp,%ebp
c010362c:	83 ec 10             	sub    $0x10,%esp
c010362f:	c7 45 fc 84 3f 1a c0 	movl   $0xc01a3f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103636:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103639:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010363c:	89 50 04             	mov    %edx,0x4(%eax)
c010363f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103642:	8b 50 04             	mov    0x4(%eax),%edx
c0103645:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103648:	89 10                	mov    %edx,(%eax)
}
c010364a:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c010364b:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c0103652:	00 00 00 
}
c0103655:	90                   	nop
c0103656:	89 ec                	mov    %ebp,%esp
c0103658:	5d                   	pop    %ebp
c0103659:	c3                   	ret    

c010365a <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n)
{
c010365a:	55                   	push   %ebp
c010365b:	89 e5                	mov    %esp,%ebp
c010365d:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103660:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103664:	75 24                	jne    c010368a <default_init_memmap+0x30>
c0103666:	c7 44 24 0c 30 cb 10 	movl   $0xc010cb30,0xc(%esp)
c010366d:	c0 
c010366e:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103675:	c0 
c0103676:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c010367d:	00 
c010367e:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103685:	e8 61 d7 ff ff       	call   c0100deb <__panic>
    struct Page *p = base;
c010368a:	8b 45 08             	mov    0x8(%ebp),%eax
c010368d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0103690:	eb 7d                	jmp    c010370f <default_init_memmap+0xb5>
    {
        assert(PageReserved(p));
c0103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103695:	83 c0 04             	add    $0x4,%eax
c0103698:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010369f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036a8:	0f a3 10             	bt     %edx,(%eax)
c01036ab:	19 c0                	sbb    %eax,%eax
c01036ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01036b0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036b4:	0f 95 c0             	setne  %al
c01036b7:	0f b6 c0             	movzbl %al,%eax
c01036ba:	85 c0                	test   %eax,%eax
c01036bc:	75 24                	jne    c01036e2 <default_init_memmap+0x88>
c01036be:	c7 44 24 0c 61 cb 10 	movl   $0xc010cb61,0xc(%esp)
c01036c5:	c0 
c01036c6:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01036cd:	c0 
c01036ce:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c01036d5:	00 
c01036d6:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01036dd:	e8 09 d7 ff ff       	call   c0100deb <__panic>
        p->flags = p->property = 0;
c01036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01036ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036ef:	8b 50 08             	mov    0x8(%eax),%edx
c01036f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f5:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01036f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036ff:	00 
c0103700:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103703:	89 04 24             	mov    %eax,(%esp)
c0103706:	e8 10 ff ff ff       	call   c010361b <set_page_ref>
    for (; p != base + n; p++)
c010370b:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010370f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103712:	c1 e0 05             	shl    $0x5,%eax
c0103715:	89 c2                	mov    %eax,%edx
c0103717:	8b 45 08             	mov    0x8(%ebp),%eax
c010371a:	01 d0                	add    %edx,%eax
c010371c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010371f:	0f 85 6d ff ff ff    	jne    c0103692 <default_init_memmap+0x38>
    }
    base->property = n;
c0103725:	8b 45 08             	mov    0x8(%ebp),%eax
c0103728:	8b 55 0c             	mov    0xc(%ebp),%edx
c010372b:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010372e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103731:	83 c0 04             	add    $0x4,%eax
c0103734:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010373b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010373e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103741:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103744:	0f ab 10             	bts    %edx,(%eax)
}
c0103747:	90                   	nop
    nr_free += n;
c0103748:	8b 15 8c 3f 1a c0    	mov    0xc01a3f8c,%edx
c010374e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103751:	01 d0                	add    %edx,%eax
c0103753:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
    list_add_before(&free_list, &(base->page_link));
c0103758:	8b 45 08             	mov    0x8(%ebp),%eax
c010375b:	83 c0 0c             	add    $0xc,%eax
c010375e:	c7 45 e4 84 3f 1a c0 	movl   $0xc01a3f84,-0x1c(%ebp)
c0103765:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010376b:	8b 00                	mov    (%eax),%eax
c010376d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103770:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103773:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103779:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010377c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010377f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103782:	89 10                	mov    %edx,(%eax)
c0103784:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103787:	8b 10                	mov    (%eax),%edx
c0103789:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010378c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010378f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103792:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103795:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103798:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010379b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010379e:	89 10                	mov    %edx,(%eax)
}
c01037a0:	90                   	nop
}
c01037a1:	90                   	nop
}
c01037a2:	90                   	nop
c01037a3:	89 ec                	mov    %ebp,%esp
c01037a5:	5d                   	pop    %ebp
c01037a6:	c3                   	ret    

c01037a7 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n)
{
c01037a7:	55                   	push   %ebp
c01037a8:	89 e5                	mov    %esp,%ebp
c01037aa:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01037ad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01037b1:	75 24                	jne    c01037d7 <default_alloc_pages+0x30>
c01037b3:	c7 44 24 0c 30 cb 10 	movl   $0xc010cb30,0xc(%esp)
c01037ba:	c0 
c01037bb:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01037c2:	c0 
c01037c3:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c01037ca:	00 
c01037cb:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01037d2:	e8 14 d6 ff ff       	call   c0100deb <__panic>
    if (n > nr_free)
c01037d7:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c01037dc:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037df:	76 0a                	jbe    c01037eb <default_alloc_pages+0x44>
    {
        return NULL;
c01037e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01037e6:	e9 5e 01 00 00       	jmp    c0103949 <default_alloc_pages+0x1a2>
    }
    struct Page *page = NULL;
c01037eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01037f2:	c7 45 f0 84 3f 1a c0 	movl   $0xc01a3f84,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list)
c01037f9:	eb 1c                	jmp    c0103817 <default_alloc_pages+0x70>
    {
        struct Page *p = le2page(le, page_link);
c01037fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037fe:	83 e8 0c             	sub    $0xc,%eax
c0103801:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n)
c0103804:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103807:	8b 40 08             	mov    0x8(%eax),%eax
c010380a:	39 45 08             	cmp    %eax,0x8(%ebp)
c010380d:	77 08                	ja     c0103817 <default_alloc_pages+0x70>
        {
            page = p;
c010380f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103812:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103815:	eb 18                	jmp    c010382f <default_alloc_pages+0x88>
c0103817:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010381a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010381d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103820:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0103823:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103826:	81 7d f0 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x10(%ebp)
c010382d:	75 cc                	jne    c01037fb <default_alloc_pages+0x54>
        }
    }
    if (page != NULL)
c010382f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103833:	0f 84 0d 01 00 00    	je     c0103946 <default_alloc_pages+0x19f>
    {
        if (page->property > n)
c0103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383c:	8b 40 08             	mov    0x8(%eax),%eax
c010383f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103842:	0f 83 aa 00 00 00    	jae    c01038f2 <default_alloc_pages+0x14b>
        {
            struct Page *p = page + n;
c0103848:	8b 45 08             	mov    0x8(%ebp),%eax
c010384b:	c1 e0 05             	shl    $0x5,%eax
c010384e:	89 c2                	mov    %eax,%edx
c0103850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103853:	01 d0                	add    %edx,%eax
c0103855:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010385b:	8b 40 08             	mov    0x8(%eax),%eax
c010385e:	2b 45 08             	sub    0x8(%ebp),%eax
c0103861:	89 c2                	mov    %eax,%edx
c0103863:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103866:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103869:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010386c:	83 c0 0c             	add    $0xc,%eax
c010386f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103872:	83 c2 0c             	add    $0xc,%edx
c0103875:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103878:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c010387b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010387e:	8b 40 04             	mov    0x4(%eax),%eax
c0103881:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103884:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0103887:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010388a:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010388d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0103890:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103893:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103896:	89 10                	mov    %edx,(%eax)
c0103898:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010389b:	8b 10                	mov    (%eax),%edx
c010389d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01038a0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01038a3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038a6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01038a9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038ac:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038af:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01038b2:	89 10                	mov    %edx,(%eax)
}
c01038b4:	90                   	nop
}
c01038b5:	90                   	nop
            //---------------------------------
            PageReserved(page);
c01038b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b9:	83 c0 04             	add    $0x4,%eax
c01038bc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
c01038c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01038cc:	0f a3 10             	bt     %edx,(%eax)
c01038cf:	19 c0                	sbb    %eax,%eax
c01038d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c01038d4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
            SetPageProperty(p);
c01038d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038db:	83 c0 04             	add    $0x4,%eax
c01038de:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01038e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01038e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01038eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01038ee:	0f ab 10             	bts    %edx,(%eax)
}
c01038f1:	90                   	nop
            //---------------------------------
        }
        list_del(&(page->page_link));
c01038f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038f5:	83 c0 0c             	add    $0xc,%eax
c01038f8:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c01038fb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01038fe:	8b 40 04             	mov    0x4(%eax),%eax
c0103901:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103904:	8b 12                	mov    (%edx),%edx
c0103906:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0103909:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010390c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010390f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103912:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103915:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103918:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010391b:	89 10                	mov    %edx,(%eax)
}
c010391d:	90                   	nop
}
c010391e:	90                   	nop
        nr_free -= n;
c010391f:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103924:	2b 45 08             	sub    0x8(%ebp),%eax
c0103927:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
        ClearPageProperty(page);
c010392c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392f:	83 c0 04             	add    $0x4,%eax
c0103932:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103939:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010393c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010393f:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103942:	0f b3 10             	btr    %edx,(%eax)
}
c0103945:	90                   	nop
    }
    return page;
c0103946:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103949:	89 ec                	mov    %ebp,%esp
c010394b:	5d                   	pop    %ebp
c010394c:	c3                   	ret    

c010394d <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n)
{
c010394d:	55                   	push   %ebp
c010394e:	89 e5                	mov    %esp,%ebp
c0103950:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103956:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010395a:	75 24                	jne    c0103980 <default_free_pages+0x33>
c010395c:	c7 44 24 0c 30 cb 10 	movl   $0xc010cb30,0xc(%esp)
c0103963:	c0 
c0103964:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010396b:	c0 
c010396c:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c0103973:	00 
c0103974:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010397b:	e8 6b d4 ff ff       	call   c0100deb <__panic>
    struct Page *p = base;
c0103980:	8b 45 08             	mov    0x8(%ebp),%eax
c0103983:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0103986:	e9 9d 00 00 00       	jmp    c0103a28 <default_free_pages+0xdb>
    {
        assert(!PageReserved(p) && !PageProperty(p));
c010398b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010398e:	83 c0 04             	add    $0x4,%eax
c0103991:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0103998:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010399b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010399e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039a1:	0f a3 10             	bt     %edx,(%eax)
c01039a4:	19 c0                	sbb    %eax,%eax
c01039a6:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c01039a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01039ad:	0f 95 c0             	setne  %al
c01039b0:	0f b6 c0             	movzbl %al,%eax
c01039b3:	85 c0                	test   %eax,%eax
c01039b5:	75 2c                	jne    c01039e3 <default_free_pages+0x96>
c01039b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039ba:	83 c0 04             	add    $0x4,%eax
c01039bd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c01039c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01039c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01039cd:	0f a3 10             	bt     %edx,(%eax)
c01039d0:	19 c0                	sbb    %eax,%eax
c01039d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c01039d5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01039d9:	0f 95 c0             	setne  %al
c01039dc:	0f b6 c0             	movzbl %al,%eax
c01039df:	85 c0                	test   %eax,%eax
c01039e1:	74 24                	je     c0103a07 <default_free_pages+0xba>
c01039e3:	c7 44 24 0c 74 cb 10 	movl   $0xc010cb74,0xc(%esp)
c01039ea:	c0 
c01039eb:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01039f2:	c0 
c01039f3:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
c01039fa:	00 
c01039fb:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103a02:	e8 e4 d3 ff ff       	call   c0100deb <__panic>
        p->flags = 0;
c0103a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a0a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103a11:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103a18:	00 
c0103a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a1c:	89 04 24             	mov    %eax,(%esp)
c0103a1f:	e8 f7 fb ff ff       	call   c010361b <set_page_ref>
    for (; p != base + n; p++)
c0103a24:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103a28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a2b:	c1 e0 05             	shl    $0x5,%eax
c0103a2e:	89 c2                	mov    %eax,%edx
c0103a30:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a33:	01 d0                	add    %edx,%eax
c0103a35:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103a38:	0f 85 4d ff ff ff    	jne    c010398b <default_free_pages+0x3e>
    }
    base->property = n;
c0103a3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a41:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103a44:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103a47:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a4a:	83 c0 04             	add    $0x4,%eax
c0103a4d:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0103a54:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103a57:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103a5a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103a5d:	0f ab 10             	bts    %edx,(%eax)
}
c0103a60:	90                   	nop
c0103a61:	c7 45 cc 84 3f 1a c0 	movl   $0xc01a3f84,-0x34(%ebp)
    return listelm->next;
c0103a68:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a6b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list), *sp = NULL;
c0103a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a71:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    bool flag = 0;
c0103a78:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != &free_list)
c0103a7f:	e9 39 01 00 00       	jmp    c0103bbd <default_free_pages+0x270>
    {
        // sp = le;
        p = le2page(le, page_link);
c0103a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a87:	83 e8 0c             	sub    $0xc,%eax
c0103a8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property == p)
c0103a8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a90:	8b 40 08             	mov    0x8(%eax),%eax
c0103a93:	c1 e0 05             	shl    $0x5,%eax
c0103a96:	89 c2                	mov    %eax,%edx
c0103a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a9b:	01 d0                	add    %edx,%eax
c0103a9d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103aa0:	75 5f                	jne    c0103b01 <default_free_pages+0x1b4>
        {
            base->property += p->property;
c0103aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aa5:	8b 50 08             	mov    0x8(%eax),%edx
c0103aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aab:	8b 40 08             	mov    0x8(%eax),%eax
c0103aae:	01 c2                	add    %eax,%edx
c0103ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab3:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0103ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ab9:	83 c0 04             	add    $0x4,%eax
c0103abc:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0103ac3:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103ac6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103ac9:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103acc:	0f b3 10             	btr    %edx,(%eax)
}
c0103acf:	90                   	nop
            list_del(&(p->page_link));
c0103ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ad3:	83 c0 0c             	add    $0xc,%eax
c0103ad6:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103ad9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103adc:	8b 40 04             	mov    0x4(%eax),%eax
c0103adf:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103ae2:	8b 12                	mov    (%edx),%edx
c0103ae4:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103ae7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c0103aea:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103aed:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103af0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103af3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103af6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103af9:	89 10                	mov    %edx,(%eax)
}
c0103afb:	90                   	nop
}
c0103afc:	e9 8b 00 00 00       	jmp    c0103b8c <default_free_pages+0x23f>
        }
        else if (p + p->property == base)
c0103b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b04:	8b 40 08             	mov    0x8(%eax),%eax
c0103b07:	c1 e0 05             	shl    $0x5,%eax
c0103b0a:	89 c2                	mov    %eax,%edx
c0103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0f:	01 d0                	add    %edx,%eax
c0103b11:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103b14:	75 76                	jne    c0103b8c <default_free_pages+0x23f>
        {
            p->property += base->property;
c0103b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b19:	8b 50 08             	mov    0x8(%eax),%edx
c0103b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b1f:	8b 40 08             	mov    0x8(%eax),%eax
c0103b22:	01 c2                	add    %eax,%edx
c0103b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b27:	89 50 08             	mov    %edx,0x8(%eax)
c0103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b2d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return listelm->prev;
c0103b30:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103b33:	8b 00                	mov    (%eax),%eax
            sp = list_prev(le);
c0103b35:	89 45 ec             	mov    %eax,-0x14(%ebp)
            flag = 1;
c0103b38:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
            ClearPageProperty(base);
c0103b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b42:	83 c0 04             	add    $0x4,%eax
c0103b45:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103b4c:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103b4f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103b52:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103b55:	0f b3 10             	btr    %edx,(%eax)
}
c0103b58:	90                   	nop
            base = p;
c0103b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b5c:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b62:	83 c0 0c             	add    $0xc,%eax
c0103b65:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103b68:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103b6b:	8b 40 04             	mov    0x4(%eax),%eax
c0103b6e:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103b71:	8b 12                	mov    (%edx),%edx
c0103b73:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0103b76:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c0103b79:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103b7c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103b7f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103b82:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103b85:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103b88:	89 10                	mov    %edx,(%eax)
}
c0103b8a:	90                   	nop
}
c0103b8b:	90                   	nop
        }
        if (p + p->property < base)
c0103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b8f:	8b 40 08             	mov    0x8(%eax),%eax
c0103b92:	c1 e0 05             	shl    $0x5,%eax
c0103b95:	89 c2                	mov    %eax,%edx
c0103b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b9a:	01 d0                	add    %edx,%eax
c0103b9c:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103b9f:	76 0d                	jbe    c0103bae <default_free_pages+0x261>
            sp = le, flag = 1;
c0103ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ba4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103ba7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0103bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bb1:	89 45 94             	mov    %eax,-0x6c(%ebp)
    return listelm->next;
c0103bb4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103bb7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103bba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c0103bbd:	81 7d f0 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x10(%ebp)
c0103bc4:	0f 85 ba fe ff ff    	jne    c0103a84 <default_free_pages+0x137>
    }
    nr_free += n;
c0103bca:	8b 15 8c 3f 1a c0    	mov    0xc01a3f8c,%edx
c0103bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103bd3:	01 d0                	add    %edx,%eax
c0103bd5:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
    //cprintf("%x %x\n", sp, &free_list);
    list_add((flag ? sp : &free_list), &(base->page_link));
c0103bda:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bdd:	8d 50 0c             	lea    0xc(%eax),%edx
c0103be0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103be4:	74 05                	je     c0103beb <default_free_pages+0x29e>
c0103be6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103be9:	eb 05                	jmp    c0103bf0 <default_free_pages+0x2a3>
c0103beb:	b8 84 3f 1a c0       	mov    $0xc01a3f84,%eax
c0103bf0:	89 45 90             	mov    %eax,-0x70(%ebp)
c0103bf3:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103bf6:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103bf9:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103bfc:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103bff:	89 45 84             	mov    %eax,-0x7c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103c02:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c05:	8b 40 04             	mov    0x4(%eax),%eax
c0103c08:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103c0b:	89 55 80             	mov    %edx,-0x80(%ebp)
c0103c0e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103c11:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103c17:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    prev->next = next->prev = elm;
c0103c1d:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103c23:	8b 55 80             	mov    -0x80(%ebp),%edx
c0103c26:	89 10                	mov    %edx,(%eax)
c0103c28:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103c2e:	8b 10                	mov    (%eax),%edx
c0103c30:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103c36:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103c39:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103c3c:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
c0103c42:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103c45:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103c48:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103c4e:	89 10                	mov    %edx,(%eax)
}
c0103c50:	90                   	nop
}
c0103c51:	90                   	nop
}
c0103c52:	90                   	nop
}
c0103c53:	90                   	nop
c0103c54:	89 ec                	mov    %ebp,%esp
c0103c56:	5d                   	pop    %ebp
c0103c57:	c3                   	ret    

c0103c58 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
c0103c58:	55                   	push   %ebp
c0103c59:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103c5b:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
}
c0103c60:	5d                   	pop    %ebp
c0103c61:	c3                   	ret    

c0103c62 <basic_check>:

static void
basic_check(void)
{
c0103c62:	55                   	push   %ebp
c0103c63:	89 e5                	mov    %esp,%ebp
c0103c65:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c72:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c78:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103c7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c82:	e8 b9 16 00 00       	call   c0105340 <alloc_pages>
c0103c87:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103c8e:	75 24                	jne    c0103cb4 <basic_check+0x52>
c0103c90:	c7 44 24 0c 99 cb 10 	movl   $0xc010cb99,0xc(%esp)
c0103c97:	c0 
c0103c98:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103c9f:	c0 
c0103ca0:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103ca7:	00 
c0103ca8:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103caf:	e8 37 d1 ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103cb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cbb:	e8 80 16 00 00       	call   c0105340 <alloc_pages>
c0103cc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103cc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cc7:	75 24                	jne    c0103ced <basic_check+0x8b>
c0103cc9:	c7 44 24 0c b5 cb 10 	movl   $0xc010cbb5,0xc(%esp)
c0103cd0:	c0 
c0103cd1:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103cd8:	c0 
c0103cd9:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0103ce0:	00 
c0103ce1:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103ce8:	e8 fe d0 ff ff       	call   c0100deb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103ced:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cf4:	e8 47 16 00 00       	call   c0105340 <alloc_pages>
c0103cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d00:	75 24                	jne    c0103d26 <basic_check+0xc4>
c0103d02:	c7 44 24 0c d1 cb 10 	movl   $0xc010cbd1,0xc(%esp)
c0103d09:	c0 
c0103d0a:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103d11:	c0 
c0103d12:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103d19:	00 
c0103d1a:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103d21:	e8 c5 d0 ff ff       	call   c0100deb <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d29:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103d2c:	74 10                	je     c0103d3e <basic_check+0xdc>
c0103d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d34:	74 08                	je     c0103d3e <basic_check+0xdc>
c0103d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103d3c:	75 24                	jne    c0103d62 <basic_check+0x100>
c0103d3e:	c7 44 24 0c f0 cb 10 	movl   $0xc010cbf0,0xc(%esp)
c0103d45:	c0 
c0103d46:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103d4d:	c0 
c0103d4e:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103d55:	00 
c0103d56:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103d5d:	e8 89 d0 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103d62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d65:	89 04 24             	mov    %eax,(%esp)
c0103d68:	e8 a4 f8 ff ff       	call   c0103611 <page_ref>
c0103d6d:	85 c0                	test   %eax,%eax
c0103d6f:	75 1e                	jne    c0103d8f <basic_check+0x12d>
c0103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d74:	89 04 24             	mov    %eax,(%esp)
c0103d77:	e8 95 f8 ff ff       	call   c0103611 <page_ref>
c0103d7c:	85 c0                	test   %eax,%eax
c0103d7e:	75 0f                	jne    c0103d8f <basic_check+0x12d>
c0103d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d83:	89 04 24             	mov    %eax,(%esp)
c0103d86:	e8 86 f8 ff ff       	call   c0103611 <page_ref>
c0103d8b:	85 c0                	test   %eax,%eax
c0103d8d:	74 24                	je     c0103db3 <basic_check+0x151>
c0103d8f:	c7 44 24 0c 14 cc 10 	movl   $0xc010cc14,0xc(%esp)
c0103d96:	c0 
c0103d97:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103d9e:	c0 
c0103d9f:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103da6:	00 
c0103da7:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103dae:	e8 38 d0 ff ff       	call   c0100deb <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103db3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103db6:	89 04 24             	mov    %eax,(%esp)
c0103db9:	e8 3b f8 ff ff       	call   c01035f9 <page2pa>
c0103dbe:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103dc4:	c1 e2 0c             	shl    $0xc,%edx
c0103dc7:	39 d0                	cmp    %edx,%eax
c0103dc9:	72 24                	jb     c0103def <basic_check+0x18d>
c0103dcb:	c7 44 24 0c 50 cc 10 	movl   $0xc010cc50,0xc(%esp)
c0103dd2:	c0 
c0103dd3:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103dda:	c0 
c0103ddb:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103de2:	00 
c0103de3:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103dea:	e8 fc cf ff ff       	call   c0100deb <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103df2:	89 04 24             	mov    %eax,(%esp)
c0103df5:	e8 ff f7 ff ff       	call   c01035f9 <page2pa>
c0103dfa:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103e00:	c1 e2 0c             	shl    $0xc,%edx
c0103e03:	39 d0                	cmp    %edx,%eax
c0103e05:	72 24                	jb     c0103e2b <basic_check+0x1c9>
c0103e07:	c7 44 24 0c 6d cc 10 	movl   $0xc010cc6d,0xc(%esp)
c0103e0e:	c0 
c0103e0f:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103e16:	c0 
c0103e17:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103e1e:	00 
c0103e1f:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103e26:	e8 c0 cf ff ff       	call   c0100deb <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e2e:	89 04 24             	mov    %eax,(%esp)
c0103e31:	e8 c3 f7 ff ff       	call   c01035f9 <page2pa>
c0103e36:	8b 15 a4 3f 1a c0    	mov    0xc01a3fa4,%edx
c0103e3c:	c1 e2 0c             	shl    $0xc,%edx
c0103e3f:	39 d0                	cmp    %edx,%eax
c0103e41:	72 24                	jb     c0103e67 <basic_check+0x205>
c0103e43:	c7 44 24 0c 8a cc 10 	movl   $0xc010cc8a,0xc(%esp)
c0103e4a:	c0 
c0103e4b:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103e52:	c0 
c0103e53:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103e5a:	00 
c0103e5b:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103e62:	e8 84 cf ff ff       	call   c0100deb <__panic>

    list_entry_t free_list_store = free_list;
c0103e67:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c0103e6c:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c0103e72:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103e75:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103e78:	c7 45 dc 84 3f 1a c0 	movl   $0xc01a3f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103e7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e82:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e85:	89 50 04             	mov    %edx,0x4(%eax)
c0103e88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e8b:	8b 50 04             	mov    0x4(%eax),%edx
c0103e8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103e91:	89 10                	mov    %edx,(%eax)
}
c0103e93:	90                   	nop
c0103e94:	c7 45 e0 84 3f 1a c0 	movl   $0xc01a3f84,-0x20(%ebp)
    return list->next == list;
c0103e9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e9e:	8b 40 04             	mov    0x4(%eax),%eax
c0103ea1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103ea4:	0f 94 c0             	sete   %al
c0103ea7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103eaa:	85 c0                	test   %eax,%eax
c0103eac:	75 24                	jne    c0103ed2 <basic_check+0x270>
c0103eae:	c7 44 24 0c a7 cc 10 	movl   $0xc010cca7,0xc(%esp)
c0103eb5:	c0 
c0103eb6:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103ebd:	c0 
c0103ebe:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103ec5:	00 
c0103ec6:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103ecd:	e8 19 cf ff ff       	call   c0100deb <__panic>

    unsigned int nr_free_store = nr_free;
c0103ed2:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103ed7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103eda:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c0103ee1:	00 00 00 

    assert(alloc_page() == NULL);
c0103ee4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103eeb:	e8 50 14 00 00       	call   c0105340 <alloc_pages>
c0103ef0:	85 c0                	test   %eax,%eax
c0103ef2:	74 24                	je     c0103f18 <basic_check+0x2b6>
c0103ef4:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c0103efb:	c0 
c0103efc:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103f03:	c0 
c0103f04:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0103f0b:	00 
c0103f0c:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103f13:	e8 d3 ce ff ff       	call   c0100deb <__panic>

    free_page(p0);
c0103f18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f1f:	00 
c0103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f23:	89 04 24             	mov    %eax,(%esp)
c0103f26:	e8 82 14 00 00       	call   c01053ad <free_pages>
    free_page(p1);
c0103f2b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f32:	00 
c0103f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f36:	89 04 24             	mov    %eax,(%esp)
c0103f39:	e8 6f 14 00 00       	call   c01053ad <free_pages>
    free_page(p2);
c0103f3e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f45:	00 
c0103f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f49:	89 04 24             	mov    %eax,(%esp)
c0103f4c:	e8 5c 14 00 00       	call   c01053ad <free_pages>
    assert(nr_free == 3);
c0103f51:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0103f56:	83 f8 03             	cmp    $0x3,%eax
c0103f59:	74 24                	je     c0103f7f <basic_check+0x31d>
c0103f5b:	c7 44 24 0c d3 cc 10 	movl   $0xc010ccd3,0xc(%esp)
c0103f62:	c0 
c0103f63:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103f6a:	c0 
c0103f6b:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0103f72:	00 
c0103f73:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103f7a:	e8 6c ce ff ff       	call   c0100deb <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103f7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f86:	e8 b5 13 00 00       	call   c0105340 <alloc_pages>
c0103f8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103f92:	75 24                	jne    c0103fb8 <basic_check+0x356>
c0103f94:	c7 44 24 0c 99 cb 10 	movl   $0xc010cb99,0xc(%esp)
c0103f9b:	c0 
c0103f9c:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103fa3:	c0 
c0103fa4:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0103fab:	00 
c0103fac:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103fb3:	e8 33 ce ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103fb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fbf:	e8 7c 13 00 00       	call   c0105340 <alloc_pages>
c0103fc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103fcb:	75 24                	jne    c0103ff1 <basic_check+0x38f>
c0103fcd:	c7 44 24 0c b5 cb 10 	movl   $0xc010cbb5,0xc(%esp)
c0103fd4:	c0 
c0103fd5:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0103fdc:	c0 
c0103fdd:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0103fe4:	00 
c0103fe5:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0103fec:	e8 fa cd ff ff       	call   c0100deb <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103ff1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ff8:	e8 43 13 00 00       	call   c0105340 <alloc_pages>
c0103ffd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104000:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104004:	75 24                	jne    c010402a <basic_check+0x3c8>
c0104006:	c7 44 24 0c d1 cb 10 	movl   $0xc010cbd1,0xc(%esp)
c010400d:	c0 
c010400e:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104015:	c0 
c0104016:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010401d:	00 
c010401e:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104025:	e8 c1 cd ff ff       	call   c0100deb <__panic>

    assert(alloc_page() == NULL);
c010402a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104031:	e8 0a 13 00 00       	call   c0105340 <alloc_pages>
c0104036:	85 c0                	test   %eax,%eax
c0104038:	74 24                	je     c010405e <basic_check+0x3fc>
c010403a:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c0104041:	c0 
c0104042:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104049:	c0 
c010404a:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0104051:	00 
c0104052:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104059:	e8 8d cd ff ff       	call   c0100deb <__panic>

    free_page(p0);
c010405e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104065:	00 
c0104066:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104069:	89 04 24             	mov    %eax,(%esp)
c010406c:	e8 3c 13 00 00       	call   c01053ad <free_pages>
c0104071:	c7 45 d8 84 3f 1a c0 	movl   $0xc01a3f84,-0x28(%ebp)
c0104078:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010407b:	8b 40 04             	mov    0x4(%eax),%eax
c010407e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104081:	0f 94 c0             	sete   %al
c0104084:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104087:	85 c0                	test   %eax,%eax
c0104089:	74 24                	je     c01040af <basic_check+0x44d>
c010408b:	c7 44 24 0c e0 cc 10 	movl   $0xc010cce0,0xc(%esp)
c0104092:	c0 
c0104093:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010409a:	c0 
c010409b:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01040a2:	00 
c01040a3:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01040aa:	e8 3c cd ff ff       	call   c0100deb <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01040af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040b6:	e8 85 12 00 00       	call   c0105340 <alloc_pages>
c01040bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01040be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01040c4:	74 24                	je     c01040ea <basic_check+0x488>
c01040c6:	c7 44 24 0c f8 cc 10 	movl   $0xc010ccf8,0xc(%esp)
c01040cd:	c0 
c01040ce:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01040d5:	c0 
c01040d6:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01040dd:	00 
c01040de:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01040e5:	e8 01 cd ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c01040ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040f1:	e8 4a 12 00 00       	call   c0105340 <alloc_pages>
c01040f6:	85 c0                	test   %eax,%eax
c01040f8:	74 24                	je     c010411e <basic_check+0x4bc>
c01040fa:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c0104101:	c0 
c0104102:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104109:	c0 
c010410a:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0104111:	00 
c0104112:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104119:	e8 cd cc ff ff       	call   c0100deb <__panic>

    assert(nr_free == 0);
c010411e:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0104123:	85 c0                	test   %eax,%eax
c0104125:	74 24                	je     c010414b <basic_check+0x4e9>
c0104127:	c7 44 24 0c 11 cd 10 	movl   $0xc010cd11,0xc(%esp)
c010412e:	c0 
c010412f:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104136:	c0 
c0104137:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c010413e:	00 
c010413f:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104146:	e8 a0 cc ff ff       	call   c0100deb <__panic>
    free_list = free_list_store;
c010414b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010414e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104151:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c0104156:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88
    nr_free = nr_free_store;
c010415c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010415f:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c

    free_page(p);
c0104164:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010416b:	00 
c010416c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010416f:	89 04 24             	mov    %eax,(%esp)
c0104172:	e8 36 12 00 00       	call   c01053ad <free_pages>
    free_page(p1);
c0104177:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010417e:	00 
c010417f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104182:	89 04 24             	mov    %eax,(%esp)
c0104185:	e8 23 12 00 00       	call   c01053ad <free_pages>
    free_page(p2);
c010418a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104191:	00 
c0104192:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104195:	89 04 24             	mov    %eax,(%esp)
c0104198:	e8 10 12 00 00       	call   c01053ad <free_pages>
}
c010419d:	90                   	nop
c010419e:	89 ec                	mov    %ebp,%esp
c01041a0:	5d                   	pop    %ebp
c01041a1:	c3                   	ret    

c01041a2 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
c01041a2:	55                   	push   %ebp
c01041a3:	89 e5                	mov    %esp,%ebp
c01041a5:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01041ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01041b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01041b9:	c7 45 ec 84 3f 1a c0 	movl   $0xc01a3f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c01041c0:	eb 6a                	jmp    c010422c <default_check+0x8a>
    {
        struct Page *p = le2page(le, page_link);
c01041c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041c5:	83 e8 0c             	sub    $0xc,%eax
c01041c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01041cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01041ce:	83 c0 04             	add    $0x4,%eax
c01041d1:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01041d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041db:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01041de:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01041e1:	0f a3 10             	bt     %edx,(%eax)
c01041e4:	19 c0                	sbb    %eax,%eax
c01041e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01041e9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01041ed:	0f 95 c0             	setne  %al
c01041f0:	0f b6 c0             	movzbl %al,%eax
c01041f3:	85 c0                	test   %eax,%eax
c01041f5:	75 24                	jne    c010421b <default_check+0x79>
c01041f7:	c7 44 24 0c 1e cd 10 	movl   $0xc010cd1e,0xc(%esp)
c01041fe:	c0 
c01041ff:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104206:	c0 
c0104207:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010420e:	00 
c010420f:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104216:	e8 d0 cb ff ff       	call   c0100deb <__panic>
        count++, total += p->property;
c010421b:	ff 45 f4             	incl   -0xc(%ebp)
c010421e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104221:	8b 50 08             	mov    0x8(%eax),%edx
c0104224:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104227:	01 d0                	add    %edx,%eax
c0104229:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010422c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010422f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0104232:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104235:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0104238:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010423b:	81 7d ec 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x14(%ebp)
c0104242:	0f 85 7a ff ff ff    	jne    c01041c2 <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0104248:	e8 95 11 00 00       	call   c01053e2 <nr_free_pages>
c010424d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104250:	39 d0                	cmp    %edx,%eax
c0104252:	74 24                	je     c0104278 <default_check+0xd6>
c0104254:	c7 44 24 0c 2e cd 10 	movl   $0xc010cd2e,0xc(%esp)
c010425b:	c0 
c010425c:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104263:	c0 
c0104264:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010426b:	00 
c010426c:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104273:	e8 73 cb ff ff       	call   c0100deb <__panic>

    basic_check();
c0104278:	e8 e5 f9 ff ff       	call   c0103c62 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010427d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104284:	e8 b7 10 00 00       	call   c0105340 <alloc_pages>
c0104289:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010428c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104290:	75 24                	jne    c01042b6 <default_check+0x114>
c0104292:	c7 44 24 0c 47 cd 10 	movl   $0xc010cd47,0xc(%esp)
c0104299:	c0 
c010429a:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01042a1:	c0 
c01042a2:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01042a9:	00 
c01042aa:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01042b1:	e8 35 cb ff ff       	call   c0100deb <__panic>
    assert(!PageProperty(p0));
c01042b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042b9:	83 c0 04             	add    $0x4,%eax
c01042bc:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01042c3:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042c6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01042c9:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01042cc:	0f a3 10             	bt     %edx,(%eax)
c01042cf:	19 c0                	sbb    %eax,%eax
c01042d1:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01042d4:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01042d8:	0f 95 c0             	setne  %al
c01042db:	0f b6 c0             	movzbl %al,%eax
c01042de:	85 c0                	test   %eax,%eax
c01042e0:	74 24                	je     c0104306 <default_check+0x164>
c01042e2:	c7 44 24 0c 52 cd 10 	movl   $0xc010cd52,0xc(%esp)
c01042e9:	c0 
c01042ea:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01042f1:	c0 
c01042f2:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01042f9:	00 
c01042fa:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104301:	e8 e5 ca ff ff       	call   c0100deb <__panic>

    // simualte the situation that all memory is used
    list_entry_t free_list_store = free_list;
c0104306:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c010430b:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c0104311:	89 45 80             	mov    %eax,-0x80(%ebp)
c0104314:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0104317:	c7 45 b0 84 3f 1a c0 	movl   $0xc01a3f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c010431e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104321:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104324:	89 50 04             	mov    %edx,0x4(%eax)
c0104327:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010432a:	8b 50 04             	mov    0x4(%eax),%edx
c010432d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104330:	89 10                	mov    %edx,(%eax)
}
c0104332:	90                   	nop
c0104333:	c7 45 b4 84 3f 1a c0 	movl   $0xc01a3f84,-0x4c(%ebp)
    return list->next == list;
c010433a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010433d:	8b 40 04             	mov    0x4(%eax),%eax
c0104340:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0104343:	0f 94 c0             	sete   %al
c0104346:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104349:	85 c0                	test   %eax,%eax
c010434b:	75 24                	jne    c0104371 <default_check+0x1cf>
c010434d:	c7 44 24 0c a7 cc 10 	movl   $0xc010cca7,0xc(%esp)
c0104354:	c0 
c0104355:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010435c:	c0 
c010435d:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0104364:	00 
c0104365:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010436c:	e8 7a ca ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c0104371:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104378:	e8 c3 0f 00 00       	call   c0105340 <alloc_pages>
c010437d:	85 c0                	test   %eax,%eax
c010437f:	74 24                	je     c01043a5 <default_check+0x203>
c0104381:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c0104388:	c0 
c0104389:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104390:	c0 
c0104391:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0104398:	00 
c0104399:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01043a0:	e8 46 ca ff ff       	call   c0100deb <__panic>

    unsigned int nr_free_store = nr_free;
c01043a5:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c01043aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c01043ad:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c01043b4:	00 00 00 
    //--------------------------------------

    free_pages(p0 + 2, 3);
c01043b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043ba:	83 c0 40             	add    $0x40,%eax
c01043bd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01043c4:	00 
c01043c5:	89 04 24             	mov    %eax,(%esp)
c01043c8:	e8 e0 0f 00 00       	call   c01053ad <free_pages>
    assert(alloc_pages(4) == NULL);
c01043cd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01043d4:	e8 67 0f 00 00       	call   c0105340 <alloc_pages>
c01043d9:	85 c0                	test   %eax,%eax
c01043db:	74 24                	je     c0104401 <default_check+0x25f>
c01043dd:	c7 44 24 0c 64 cd 10 	movl   $0xc010cd64,0xc(%esp)
c01043e4:	c0 
c01043e5:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01043ec:	c0 
c01043ed:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01043f4:	00 
c01043f5:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01043fc:	e8 ea c9 ff ff       	call   c0100deb <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0104401:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104404:	83 c0 40             	add    $0x40,%eax
c0104407:	83 c0 04             	add    $0x4,%eax
c010440a:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0104411:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104414:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104417:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010441a:	0f a3 10             	bt     %edx,(%eax)
c010441d:	19 c0                	sbb    %eax,%eax
c010441f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104422:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0104426:	0f 95 c0             	setne  %al
c0104429:	0f b6 c0             	movzbl %al,%eax
c010442c:	85 c0                	test   %eax,%eax
c010442e:	74 0e                	je     c010443e <default_check+0x29c>
c0104430:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104433:	83 c0 40             	add    $0x40,%eax
c0104436:	8b 40 08             	mov    0x8(%eax),%eax
c0104439:	83 f8 03             	cmp    $0x3,%eax
c010443c:	74 24                	je     c0104462 <default_check+0x2c0>
c010443e:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c0104445:	c0 
c0104446:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010444d:	c0 
c010444e:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0104455:	00 
c0104456:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010445d:	e8 89 c9 ff ff       	call   c0100deb <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104462:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104469:	e8 d2 0e 00 00       	call   c0105340 <alloc_pages>
c010446e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104475:	75 24                	jne    c010449b <default_check+0x2f9>
c0104477:	c7 44 24 0c a8 cd 10 	movl   $0xc010cda8,0xc(%esp)
c010447e:	c0 
c010447f:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104486:	c0 
c0104487:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c010448e:	00 
c010448f:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104496:	e8 50 c9 ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c010449b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01044a2:	e8 99 0e 00 00       	call   c0105340 <alloc_pages>
c01044a7:	85 c0                	test   %eax,%eax
c01044a9:	74 24                	je     c01044cf <default_check+0x32d>
c01044ab:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c01044b2:	c0 
c01044b3:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01044ba:	c0 
c01044bb:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01044c2:	00 
c01044c3:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01044ca:	e8 1c c9 ff ff       	call   c0100deb <__panic>
    assert(p0 + 2 == p1);
c01044cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044d2:	83 c0 40             	add    $0x40,%eax
c01044d5:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01044d8:	74 24                	je     c01044fe <default_check+0x35c>
c01044da:	c7 44 24 0c c6 cd 10 	movl   $0xc010cdc6,0xc(%esp)
c01044e1:	c0 
c01044e2:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01044e9:	c0 
c01044ea:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01044f1:	00 
c01044f2:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01044f9:	e8 ed c8 ff ff       	call   c0100deb <__panic>

    p2 = p0 + 1;
c01044fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104501:	83 c0 20             	add    $0x20,%eax
c0104504:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0104507:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010450e:	00 
c010450f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104512:	89 04 24             	mov    %eax,(%esp)
c0104515:	e8 93 0e 00 00       	call   c01053ad <free_pages>
    free_pages(p1, 3);
c010451a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104521:	00 
c0104522:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104525:	89 04 24             	mov    %eax,(%esp)
c0104528:	e8 80 0e 00 00       	call   c01053ad <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010452d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104530:	83 c0 04             	add    $0x4,%eax
c0104533:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010453a:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010453d:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104540:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104543:	0f a3 10             	bt     %edx,(%eax)
c0104546:	19 c0                	sbb    %eax,%eax
c0104548:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010454b:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010454f:	0f 95 c0             	setne  %al
c0104552:	0f b6 c0             	movzbl %al,%eax
c0104555:	85 c0                	test   %eax,%eax
c0104557:	74 0b                	je     c0104564 <default_check+0x3c2>
c0104559:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010455c:	8b 40 08             	mov    0x8(%eax),%eax
c010455f:	83 f8 01             	cmp    $0x1,%eax
c0104562:	74 24                	je     c0104588 <default_check+0x3e6>
c0104564:	c7 44 24 0c d4 cd 10 	movl   $0xc010cdd4,0xc(%esp)
c010456b:	c0 
c010456c:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104573:	c0 
c0104574:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c010457b:	00 
c010457c:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104583:	e8 63 c8 ff ff       	call   c0100deb <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104588:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010458b:	83 c0 04             	add    $0x4,%eax
c010458e:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104595:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104598:	8b 45 90             	mov    -0x70(%ebp),%eax
c010459b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010459e:	0f a3 10             	bt     %edx,(%eax)
c01045a1:	19 c0                	sbb    %eax,%eax
c01045a3:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01045a6:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01045aa:	0f 95 c0             	setne  %al
c01045ad:	0f b6 c0             	movzbl %al,%eax
c01045b0:	85 c0                	test   %eax,%eax
c01045b2:	74 0b                	je     c01045bf <default_check+0x41d>
c01045b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045b7:	8b 40 08             	mov    0x8(%eax),%eax
c01045ba:	83 f8 03             	cmp    $0x3,%eax
c01045bd:	74 24                	je     c01045e3 <default_check+0x441>
c01045bf:	c7 44 24 0c fc cd 10 	movl   $0xc010cdfc,0xc(%esp)
c01045c6:	c0 
c01045c7:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01045ce:	c0 
c01045cf:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01045d6:	00 
c01045d7:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01045de:	e8 08 c8 ff ff       	call   c0100deb <__panic>

    assert((p0 = alloc_page()) == p2 - 1); //!
c01045e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01045ea:	e8 51 0d 00 00       	call   c0105340 <alloc_pages>
c01045ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01045f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045f5:	83 e8 20             	sub    $0x20,%eax
c01045f8:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01045fb:	74 24                	je     c0104621 <default_check+0x47f>
c01045fd:	c7 44 24 0c 22 ce 10 	movl   $0xc010ce22,0xc(%esp)
c0104604:	c0 
c0104605:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010460c:	c0 
c010460d:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104614:	00 
c0104615:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010461c:	e8 ca c7 ff ff       	call   c0100deb <__panic>
    free_page(p0);
c0104621:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104628:	00 
c0104629:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010462c:	89 04 24             	mov    %eax,(%esp)
c010462f:	e8 79 0d 00 00       	call   c01053ad <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104634:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010463b:	e8 00 0d 00 00       	call   c0105340 <alloc_pages>
c0104640:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104643:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104646:	83 c0 20             	add    $0x20,%eax
c0104649:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010464c:	74 24                	je     c0104672 <default_check+0x4d0>
c010464e:	c7 44 24 0c 40 ce 10 	movl   $0xc010ce40,0xc(%esp)
c0104655:	c0 
c0104656:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010465d:	c0 
c010465e:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0104665:	00 
c0104666:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010466d:	e8 79 c7 ff ff       	call   c0100deb <__panic>

    free_pages(p0, 2);
c0104672:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104679:	00 
c010467a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010467d:	89 04 24             	mov    %eax,(%esp)
c0104680:	e8 28 0d 00 00       	call   c01053ad <free_pages>
    //test();
    free_page(p2);
c0104685:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010468c:	00 
c010468d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104690:	89 04 24             	mov    %eax,(%esp)
c0104693:	e8 15 0d 00 00       	call   c01053ad <free_pages>
    //test();

    assert((p0 = alloc_pages(5)) != NULL); //!
c0104698:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010469f:	e8 9c 0c 00 00       	call   c0105340 <alloc_pages>
c01046a4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01046a7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01046ab:	75 24                	jne    c01046d1 <default_check+0x52f>
c01046ad:	c7 44 24 0c 60 ce 10 	movl   $0xc010ce60,0xc(%esp)
c01046b4:	c0 
c01046b5:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01046bc:	c0 
c01046bd:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01046c4:	00 
c01046c5:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01046cc:	e8 1a c7 ff ff       	call   c0100deb <__panic>
    assert(alloc_page() == NULL);
c01046d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01046d8:	e8 63 0c 00 00       	call   c0105340 <alloc_pages>
c01046dd:	85 c0                	test   %eax,%eax
c01046df:	74 24                	je     c0104705 <default_check+0x563>
c01046e1:	c7 44 24 0c be cc 10 	movl   $0xc010ccbe,0xc(%esp)
c01046e8:	c0 
c01046e9:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01046f0:	c0 
c01046f1:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01046f8:	00 
c01046f9:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104700:	e8 e6 c6 ff ff       	call   c0100deb <__panic>

    assert(nr_free == 0);
c0104705:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c010470a:	85 c0                	test   %eax,%eax
c010470c:	74 24                	je     c0104732 <default_check+0x590>
c010470e:	c7 44 24 0c 11 cd 10 	movl   $0xc010cd11,0xc(%esp)
c0104715:	c0 
c0104716:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c010471d:	c0 
c010471e:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0104725:	00 
c0104726:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c010472d:	e8 b9 c6 ff ff       	call   c0100deb <__panic>
    nr_free = nr_free_store;
c0104732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104735:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c

    free_list = free_list_store;
c010473a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010473d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104740:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c0104745:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88
    free_pages(p0, 5);
c010474b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104752:	00 
c0104753:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104756:	89 04 24             	mov    %eax,(%esp)
c0104759:	e8 4f 0c 00 00       	call   c01053ad <free_pages>

    le = &free_list;
c010475e:	c7 45 ec 84 3f 1a c0 	movl   $0xc01a3f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0104765:	eb 5a                	jmp    c01047c1 <default_check+0x61f>
    {
        assert(le->next->prev == le && le->prev->next == le);
c0104767:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010476a:	8b 40 04             	mov    0x4(%eax),%eax
c010476d:	8b 00                	mov    (%eax),%eax
c010476f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104772:	75 0d                	jne    c0104781 <default_check+0x5df>
c0104774:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104777:	8b 00                	mov    (%eax),%eax
c0104779:	8b 40 04             	mov    0x4(%eax),%eax
c010477c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010477f:	74 24                	je     c01047a5 <default_check+0x603>
c0104781:	c7 44 24 0c 80 ce 10 	movl   $0xc010ce80,0xc(%esp)
c0104788:	c0 
c0104789:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104790:	c0 
c0104791:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0104798:	00 
c0104799:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01047a0:	e8 46 c6 ff ff       	call   c0100deb <__panic>
        struct Page *p = le2page(le, page_link);
c01047a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a8:	83 e8 0c             	sub    $0xc,%eax
c01047ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count--, total -= p->property;
c01047ae:	ff 4d f4             	decl   -0xc(%ebp)
c01047b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01047b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047b7:	8b 48 08             	mov    0x8(%eax),%ecx
c01047ba:	89 d0                	mov    %edx,%eax
c01047bc:	29 c8                	sub    %ecx,%eax
c01047be:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047c4:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01047c7:	8b 45 88             	mov    -0x78(%ebp),%eax
c01047ca:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c01047cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01047d0:	81 7d ec 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x14(%ebp)
c01047d7:	75 8e                	jne    c0104767 <default_check+0x5c5>
    }
    assert(count == 0);
c01047d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01047dd:	74 24                	je     c0104803 <default_check+0x661>
c01047df:	c7 44 24 0c ad ce 10 	movl   $0xc010cead,0xc(%esp)
c01047e6:	c0 
c01047e7:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c01047ee:	c0 
c01047ef:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01047f6:	00 
c01047f7:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c01047fe:	e8 e8 c5 ff ff       	call   c0100deb <__panic>
    assert(total == 0);
c0104803:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104807:	74 24                	je     c010482d <default_check+0x68b>
c0104809:	c7 44 24 0c b8 ce 10 	movl   $0xc010ceb8,0xc(%esp)
c0104810:	c0 
c0104811:	c7 44 24 08 36 cb 10 	movl   $0xc010cb36,0x8(%esp)
c0104818:	c0 
c0104819:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0104820:	00 
c0104821:	c7 04 24 4b cb 10 c0 	movl   $0xc010cb4b,(%esp)
c0104828:	e8 be c5 ff ff       	call   c0100deb <__panic>
}
c010482d:	90                   	nop
c010482e:	89 ec                	mov    %ebp,%esp
c0104830:	5d                   	pop    %ebp
c0104831:	c3                   	ret    

c0104832 <test>:
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

static void test(void)
{   //我自己写的
c0104832:	55                   	push   %ebp
c0104833:	89 e5                	mov    %esp,%ebp
c0104835:	83 ec 28             	sub    $0x28,%esp
c0104838:	c7 45 f0 84 3f 1a c0 	movl   $0xc01a3f84,-0x10(%ebp)
c010483f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104842:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104845:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c0104848:	eb 32                	jmp    c010487c <test+0x4a>
    {
        cprintf("%x %d  ", le2page(le, page_link), le2page(le, page_link)->property);
c010484a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010484d:	83 e8 0c             	sub    $0xc,%eax
c0104850:	8b 40 08             	mov    0x8(%eax),%eax
c0104853:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104856:	83 ea 0c             	sub    $0xc,%edx
c0104859:	89 44 24 08          	mov    %eax,0x8(%esp)
c010485d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104861:	c7 04 24 f4 ce 10 c0 	movl   $0xc010cef4,(%esp)
c0104868:	e8 00 bb ff ff       	call   c010036d <cprintf>
c010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104870:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104873:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104876:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104879:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c010487c:	81 7d f4 84 3f 1a c0 	cmpl   $0xc01a3f84,-0xc(%ebp)
c0104883:	75 c5                	jne    c010484a <test+0x18>
    }
    cprintf("\n");
c0104885:	c7 04 24 fc ce 10 c0 	movl   $0xc010cefc,(%esp)
c010488c:	e8 dc ba ff ff       	call   c010036d <cprintf>
}
c0104891:	90                   	nop
c0104892:	89 ec                	mov    %ebp,%esp
c0104894:	5d                   	pop    %ebp
c0104895:	c3                   	ret    

c0104896 <__intr_save>:
__intr_save(void) {
c0104896:	55                   	push   %ebp
c0104897:	89 e5                	mov    %esp,%ebp
c0104899:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010489c:	9c                   	pushf  
c010489d:	58                   	pop    %eax
c010489e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01048a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01048a4:	25 00 02 00 00       	and    $0x200,%eax
c01048a9:	85 c0                	test   %eax,%eax
c01048ab:	74 0c                	je     c01048b9 <__intr_save+0x23>
        intr_disable();
c01048ad:	e8 ef d7 ff ff       	call   c01020a1 <intr_disable>
        return 1;
c01048b2:	b8 01 00 00 00       	mov    $0x1,%eax
c01048b7:	eb 05                	jmp    c01048be <__intr_save+0x28>
    return 0;
c01048b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01048be:	89 ec                	mov    %ebp,%esp
c01048c0:	5d                   	pop    %ebp
c01048c1:	c3                   	ret    

c01048c2 <__intr_restore>:
__intr_restore(bool flag) {
c01048c2:	55                   	push   %ebp
c01048c3:	89 e5                	mov    %esp,%ebp
c01048c5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01048c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048cc:	74 05                	je     c01048d3 <__intr_restore+0x11>
        intr_enable();
c01048ce:	e8 c6 d7 ff ff       	call   c0102099 <intr_enable>
}
c01048d3:	90                   	nop
c01048d4:	89 ec                	mov    %ebp,%esp
c01048d6:	5d                   	pop    %ebp
c01048d7:	c3                   	ret    

c01048d8 <page2ppn>:
page2ppn(struct Page *page) {
c01048d8:	55                   	push   %ebp
c01048d9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01048db:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01048e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048e4:	29 d0                	sub    %edx,%eax
c01048e6:	c1 f8 05             	sar    $0x5,%eax
}
c01048e9:	5d                   	pop    %ebp
c01048ea:	c3                   	ret    

c01048eb <page2pa>:
page2pa(struct Page *page) {
c01048eb:	55                   	push   %ebp
c01048ec:	89 e5                	mov    %esp,%ebp
c01048ee:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01048f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01048f4:	89 04 24             	mov    %eax,(%esp)
c01048f7:	e8 dc ff ff ff       	call   c01048d8 <page2ppn>
c01048fc:	c1 e0 0c             	shl    $0xc,%eax
}
c01048ff:	89 ec                	mov    %ebp,%esp
c0104901:	5d                   	pop    %ebp
c0104902:	c3                   	ret    

c0104903 <pa2page>:
pa2page(uintptr_t pa) {
c0104903:	55                   	push   %ebp
c0104904:	89 e5                	mov    %esp,%ebp
c0104906:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104909:	8b 45 08             	mov    0x8(%ebp),%eax
c010490c:	c1 e8 0c             	shr    $0xc,%eax
c010490f:	89 c2                	mov    %eax,%edx
c0104911:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0104916:	39 c2                	cmp    %eax,%edx
c0104918:	72 1c                	jb     c0104936 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010491a:	c7 44 24 08 00 cf 10 	movl   $0xc010cf00,0x8(%esp)
c0104921:	c0 
c0104922:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104929:	00 
c010492a:	c7 04 24 1f cf 10 c0 	movl   $0xc010cf1f,(%esp)
c0104931:	e8 b5 c4 ff ff       	call   c0100deb <__panic>
    return &pages[PPN(pa)];
c0104936:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c010493c:	8b 45 08             	mov    0x8(%ebp),%eax
c010493f:	c1 e8 0c             	shr    $0xc,%eax
c0104942:	c1 e0 05             	shl    $0x5,%eax
c0104945:	01 d0                	add    %edx,%eax
}
c0104947:	89 ec                	mov    %ebp,%esp
c0104949:	5d                   	pop    %ebp
c010494a:	c3                   	ret    

c010494b <page2kva>:
page2kva(struct Page *page) {
c010494b:	55                   	push   %ebp
c010494c:	89 e5                	mov    %esp,%ebp
c010494e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104951:	8b 45 08             	mov    0x8(%ebp),%eax
c0104954:	89 04 24             	mov    %eax,(%esp)
c0104957:	e8 8f ff ff ff       	call   c01048eb <page2pa>
c010495c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010495f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104962:	c1 e8 0c             	shr    $0xc,%eax
c0104965:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104968:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010496d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104970:	72 23                	jb     c0104995 <page2kva+0x4a>
c0104972:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104975:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104979:	c7 44 24 08 30 cf 10 	movl   $0xc010cf30,0x8(%esp)
c0104980:	c0 
c0104981:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104988:	00 
c0104989:	c7 04 24 1f cf 10 c0 	movl   $0xc010cf1f,(%esp)
c0104990:	e8 56 c4 ff ff       	call   c0100deb <__panic>
c0104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104998:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010499d:	89 ec                	mov    %ebp,%esp
c010499f:	5d                   	pop    %ebp
c01049a0:	c3                   	ret    

c01049a1 <kva2page>:
kva2page(void *kva) {
c01049a1:	55                   	push   %ebp
c01049a2:	89 e5                	mov    %esp,%ebp
c01049a4:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01049a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01049aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049ad:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01049b4:	77 23                	ja     c01049d9 <kva2page+0x38>
c01049b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049bd:	c7 44 24 08 54 cf 10 	movl   $0xc010cf54,0x8(%esp)
c01049c4:	c0 
c01049c5:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01049cc:	00 
c01049cd:	c7 04 24 1f cf 10 c0 	movl   $0xc010cf1f,(%esp)
c01049d4:	e8 12 c4 ff ff       	call   c0100deb <__panic>
c01049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049dc:	05 00 00 00 40       	add    $0x40000000,%eax
c01049e1:	89 04 24             	mov    %eax,(%esp)
c01049e4:	e8 1a ff ff ff       	call   c0104903 <pa2page>
}
c01049e9:	89 ec                	mov    %ebp,%esp
c01049eb:	5d                   	pop    %ebp
c01049ec:	c3                   	ret    

c01049ed <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01049ed:	55                   	push   %ebp
c01049ee:	89 e5                	mov    %esp,%ebp
c01049f0:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c01049f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049f6:	ba 01 00 00 00       	mov    $0x1,%edx
c01049fb:	88 c1                	mov    %al,%cl
c01049fd:	d3 e2                	shl    %cl,%edx
c01049ff:	89 d0                	mov    %edx,%eax
c0104a01:	89 04 24             	mov    %eax,(%esp)
c0104a04:	e8 37 09 00 00       	call   c0105340 <alloc_pages>
c0104a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104a0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a10:	75 07                	jne    c0104a19 <__slob_get_free_pages+0x2c>
    return NULL;
c0104a12:	b8 00 00 00 00       	mov    $0x0,%eax
c0104a17:	eb 0b                	jmp    c0104a24 <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a1c:	89 04 24             	mov    %eax,(%esp)
c0104a1f:	e8 27 ff ff ff       	call   c010494b <page2kva>
}
c0104a24:	89 ec                	mov    %ebp,%esp
c0104a26:	5d                   	pop    %ebp
c0104a27:	c3                   	ret    

c0104a28 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104a28:	55                   	push   %ebp
c0104a29:	89 e5                	mov    %esp,%ebp
c0104a2b:	83 ec 18             	sub    $0x18,%esp
c0104a2e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
  free_pages(kva2page(kva), 1 << order);
c0104a31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a34:	ba 01 00 00 00       	mov    $0x1,%edx
c0104a39:	88 c1                	mov    %al,%cl
c0104a3b:	d3 e2                	shl    %cl,%edx
c0104a3d:	89 d0                	mov    %edx,%eax
c0104a3f:	89 c3                	mov    %eax,%ebx
c0104a41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a44:	89 04 24             	mov    %eax,(%esp)
c0104a47:	e8 55 ff ff ff       	call   c01049a1 <kva2page>
c0104a4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104a50:	89 04 24             	mov    %eax,(%esp)
c0104a53:	e8 55 09 00 00       	call   c01053ad <free_pages>
}
c0104a58:	90                   	nop
c0104a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104a5c:	89 ec                	mov    %ebp,%esp
c0104a5e:	5d                   	pop    %ebp
c0104a5f:	c3                   	ret    

c0104a60 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104a60:	55                   	push   %ebp
c0104a61:	89 e5                	mov    %esp,%ebp
c0104a63:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104a66:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a69:	83 c0 08             	add    $0x8,%eax
c0104a6c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104a71:	76 24                	jbe    c0104a97 <slob_alloc+0x37>
c0104a73:	c7 44 24 0c 78 cf 10 	movl   $0xc010cf78,0xc(%esp)
c0104a7a:	c0 
c0104a7b:	c7 44 24 08 97 cf 10 	movl   $0xc010cf97,0x8(%esp)
c0104a82:	c0 
c0104a83:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104a8a:	00 
c0104a8b:	c7 04 24 ac cf 10 c0 	movl   $0xc010cfac,(%esp)
c0104a92:	e8 54 c3 ff ff       	call   c0100deb <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104a97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104a9e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104aa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aa8:	83 c0 07             	add    $0x7,%eax
c0104aab:	c1 e8 03             	shr    $0x3,%eax
c0104aae:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104ab1:	e8 e0 fd ff ff       	call   c0104896 <__intr_save>
c0104ab6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104ab9:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c0104abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac4:	8b 40 04             	mov    0x4(%eax),%eax
c0104ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104aca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104ace:	74 21                	je     c0104af1 <slob_alloc+0x91>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104ad0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104ad3:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ad6:	01 d0                	add    %edx,%eax
c0104ad8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104adb:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ade:	f7 d8                	neg    %eax
c0104ae0:	21 d0                	and    %edx,%eax
c0104ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ae8:	2b 45 f0             	sub    -0x10(%ebp),%eax
c0104aeb:	c1 f8 03             	sar    $0x3,%eax
c0104aee:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af4:	8b 00                	mov    (%eax),%eax
c0104af6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104af9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104afc:	01 ca                	add    %ecx,%edx
c0104afe:	39 d0                	cmp    %edx,%eax
c0104b00:	0f 8c aa 00 00 00    	jl     c0104bb0 <slob_alloc+0x150>
			if (delta) { /* need to fragment head to align? */
c0104b06:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104b0a:	74 38                	je     c0104b44 <slob_alloc+0xe4>
				aligned->units = cur->units - delta;
c0104b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b0f:	8b 00                	mov    (%eax),%eax
c0104b11:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104b14:	89 c2                	mov    %eax,%edx
c0104b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b19:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b1e:	8b 50 04             	mov    0x4(%eax),%edx
c0104b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b24:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b2a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104b2d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b33:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104b36:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104b3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b47:	8b 00                	mov    (%eax),%eax
c0104b49:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104b4c:	75 0e                	jne    c0104b5c <slob_alloc+0xfc>
				prev->next = cur->next; /* unlink */
c0104b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b51:	8b 50 04             	mov    0x4(%eax),%edx
c0104b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b57:	89 50 04             	mov    %edx,0x4(%eax)
c0104b5a:	eb 3c                	jmp    c0104b98 <slob_alloc+0x138>
			else { /* fragment */
				prev->next = cur + units;
c0104b5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b5f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b69:	01 c2                	add    %eax,%edx
c0104b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b6e:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b74:	8b 10                	mov    (%eax),%edx
c0104b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b79:	8b 40 04             	mov    0x4(%eax),%eax
c0104b7c:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104b7f:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b84:	8b 40 04             	mov    0x4(%eax),%eax
c0104b87:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b8a:	8b 52 04             	mov    0x4(%edx),%edx
c0104b8d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b93:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b96:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b9b:	a3 e8 f9 12 c0       	mov    %eax,0xc012f9e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ba3:	89 04 24             	mov    %eax,(%esp)
c0104ba6:	e8 17 fd ff ff       	call   c01048c2 <__intr_restore>
			return cur;
c0104bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bae:	eb 7f                	jmp    c0104c2f <slob_alloc+0x1cf>
		}
		if (cur == slobfree) {
c0104bb0:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c0104bb5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104bb8:	75 61                	jne    c0104c1b <slob_alloc+0x1bb>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104bba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bbd:	89 04 24             	mov    %eax,(%esp)
c0104bc0:	e8 fd fc ff ff       	call   c01048c2 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104bc5:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104bcc:	75 07                	jne    c0104bd5 <slob_alloc+0x175>
				return 0;
c0104bce:	b8 00 00 00 00       	mov    $0x0,%eax
c0104bd3:	eb 5a                	jmp    c0104c2f <slob_alloc+0x1cf>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104bd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bdc:	00 
c0104bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104be0:	89 04 24             	mov    %eax,(%esp)
c0104be3:	e8 05 fe ff ff       	call   c01049ed <__slob_get_free_pages>
c0104be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104bef:	75 07                	jne    c0104bf8 <slob_alloc+0x198>
				return 0;
c0104bf1:	b8 00 00 00 00       	mov    $0x0,%eax
c0104bf6:	eb 37                	jmp    c0104c2f <slob_alloc+0x1cf>

			slob_free(cur, PAGE_SIZE);
c0104bf8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104bff:	00 
c0104c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c03:	89 04 24             	mov    %eax,(%esp)
c0104c06:	e8 28 00 00 00       	call   c0104c33 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104c0b:	e8 86 fc ff ff       	call   c0104896 <__intr_save>
c0104c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104c13:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c0104c18:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c24:	8b 40 04             	mov    0x4(%eax),%eax
c0104c27:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104c2a:	e9 9b fe ff ff       	jmp    c0104aca <slob_alloc+0x6a>
		}
	}
}
c0104c2f:	89 ec                	mov    %ebp,%esp
c0104c31:	5d                   	pop    %ebp
c0104c32:	c3                   	ret    

c0104c33 <slob_free>:

static void slob_free(void *block, int size)
{
c0104c33:	55                   	push   %ebp
c0104c34:	89 e5                	mov    %esp,%ebp
c0104c36:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104c39:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104c3f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c43:	0f 84 01 01 00 00    	je     c0104d4a <slob_free+0x117>
		return;

	if (size)
c0104c49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104c4d:	74 10                	je     c0104c5f <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c0104c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c52:	83 c0 07             	add    $0x7,%eax
c0104c55:	c1 e8 03             	shr    $0x3,%eax
c0104c58:	89 c2                	mov    %eax,%edx
c0104c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c5d:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104c5f:	e8 32 fc ff ff       	call   c0104896 <__intr_save>
c0104c64:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104c67:	a1 e8 f9 12 c0       	mov    0xc012f9e8,%eax
c0104c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c6f:	eb 27                	jmp    c0104c98 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c74:	8b 40 04             	mov    0x4(%eax),%eax
c0104c77:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104c7a:	72 13                	jb     c0104c8f <slob_free+0x5c>
c0104c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c7f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c82:	77 27                	ja     c0104cab <slob_free+0x78>
c0104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c87:	8b 40 04             	mov    0x4(%eax),%eax
c0104c8a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104c8d:	72 1c                	jb     c0104cab <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c92:	8b 40 04             	mov    0x4(%eax),%eax
c0104c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c9b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c9e:	76 d1                	jbe    c0104c71 <slob_free+0x3e>
c0104ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca3:	8b 40 04             	mov    0x4(%eax),%eax
c0104ca6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104ca9:	73 c6                	jae    c0104c71 <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c0104cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cae:	8b 00                	mov    (%eax),%eax
c0104cb0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cba:	01 c2                	add    %eax,%edx
c0104cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cbf:	8b 40 04             	mov    0x4(%eax),%eax
c0104cc2:	39 c2                	cmp    %eax,%edx
c0104cc4:	75 25                	jne    c0104ceb <slob_free+0xb8>
		b->units += cur->next->units;
c0104cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cc9:	8b 10                	mov    (%eax),%edx
c0104ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cce:	8b 40 04             	mov    0x4(%eax),%eax
c0104cd1:	8b 00                	mov    (%eax),%eax
c0104cd3:	01 c2                	add    %eax,%edx
c0104cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cd8:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cdd:	8b 40 04             	mov    0x4(%eax),%eax
c0104ce0:	8b 50 04             	mov    0x4(%eax),%edx
c0104ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ce6:	89 50 04             	mov    %edx,0x4(%eax)
c0104ce9:	eb 0c                	jmp    c0104cf7 <slob_free+0xc4>
	} else
		b->next = cur->next;
c0104ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cee:	8b 50 04             	mov    0x4(%eax),%edx
c0104cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cf4:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cfa:	8b 00                	mov    (%eax),%eax
c0104cfc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d06:	01 d0                	add    %edx,%eax
c0104d08:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104d0b:	75 1f                	jne    c0104d2c <slob_free+0xf9>
		cur->units += b->units;
c0104d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d10:	8b 10                	mov    (%eax),%edx
c0104d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d15:	8b 00                	mov    (%eax),%eax
c0104d17:	01 c2                	add    %eax,%edx
c0104d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d1c:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d21:	8b 50 04             	mov    0x4(%eax),%edx
c0104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d27:	89 50 04             	mov    %edx,0x4(%eax)
c0104d2a:	eb 09                	jmp    c0104d35 <slob_free+0x102>
	} else
		cur->next = b;
c0104d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104d32:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d38:	a3 e8 f9 12 c0       	mov    %eax,0xc012f9e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104d3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d40:	89 04 24             	mov    %eax,(%esp)
c0104d43:	e8 7a fb ff ff       	call   c01048c2 <__intr_restore>
c0104d48:	eb 01                	jmp    c0104d4b <slob_free+0x118>
		return;
c0104d4a:	90                   	nop
}
c0104d4b:	89 ec                	mov    %ebp,%esp
c0104d4d:	5d                   	pop    %ebp
c0104d4e:	c3                   	ret    

c0104d4f <slob_init>:



void
slob_init(void) {
c0104d4f:	55                   	push   %ebp
c0104d50:	89 e5                	mov    %esp,%ebp
c0104d52:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104d55:	c7 04 24 be cf 10 c0 	movl   $0xc010cfbe,(%esp)
c0104d5c:	e8 0c b6 ff ff       	call   c010036d <cprintf>
}
c0104d61:	90                   	nop
c0104d62:	89 ec                	mov    %ebp,%esp
c0104d64:	5d                   	pop    %ebp
c0104d65:	c3                   	ret    

c0104d66 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104d66:	55                   	push   %ebp
c0104d67:	89 e5                	mov    %esp,%ebp
c0104d69:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104d6c:	e8 de ff ff ff       	call   c0104d4f <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104d71:	c7 04 24 d2 cf 10 c0 	movl   $0xc010cfd2,(%esp)
c0104d78:	e8 f0 b5 ff ff       	call   c010036d <cprintf>
}
c0104d7d:	90                   	nop
c0104d7e:	89 ec                	mov    %ebp,%esp
c0104d80:	5d                   	pop    %ebp
c0104d81:	c3                   	ret    

c0104d82 <slob_allocated>:

size_t
slob_allocated(void) {
c0104d82:	55                   	push   %ebp
c0104d83:	89 e5                	mov    %esp,%ebp
  return 0;
c0104d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104d8a:	5d                   	pop    %ebp
c0104d8b:	c3                   	ret    

c0104d8c <kallocated>:

size_t
kallocated(void) {
c0104d8c:	55                   	push   %ebp
c0104d8d:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104d8f:	e8 ee ff ff ff       	call   c0104d82 <slob_allocated>
}
c0104d94:	5d                   	pop    %ebp
c0104d95:	c3                   	ret    

c0104d96 <find_order>:

static int find_order(int size)
{
c0104d96:	55                   	push   %ebp
c0104d97:	89 e5                	mov    %esp,%ebp
c0104d99:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104d9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104da3:	eb 06                	jmp    c0104dab <find_order+0x15>
		order++;
c0104da5:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104da8:	d1 7d 08             	sarl   0x8(%ebp)
c0104dab:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104db2:	7f f1                	jg     c0104da5 <find_order+0xf>
	return order;
c0104db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104db7:	89 ec                	mov    %ebp,%esp
c0104db9:	5d                   	pop    %ebp
c0104dba:	c3                   	ret    

c0104dbb <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104dbb:	55                   	push   %ebp
c0104dbc:	89 e5                	mov    %esp,%ebp
c0104dbe:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104dc1:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104dc8:	77 3b                	ja     c0104e05 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dcd:	8d 50 08             	lea    0x8(%eax),%edx
c0104dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104dd7:	00 
c0104dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ddf:	89 14 24             	mov    %edx,(%esp)
c0104de2:	e8 79 fc ff ff       	call   c0104a60 <slob_alloc>
c0104de7:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104dea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104dee:	74 0b                	je     c0104dfb <__kmalloc+0x40>
c0104df0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104df3:	83 c0 08             	add    $0x8,%eax
c0104df6:	e9 b0 00 00 00       	jmp    c0104eab <__kmalloc+0xf0>
c0104dfb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e00:	e9 a6 00 00 00       	jmp    c0104eab <__kmalloc+0xf0>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104e05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104e0c:	00 
c0104e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e14:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104e1b:	e8 40 fc ff ff       	call   c0104a60 <slob_alloc>
c0104e20:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0104e23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e27:	75 07                	jne    c0104e30 <__kmalloc+0x75>
		return 0;
c0104e29:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e2e:	eb 7b                	jmp    c0104eab <__kmalloc+0xf0>

	bb->order = find_order(size);
c0104e30:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e33:	89 04 24             	mov    %eax,(%esp)
c0104e36:	e8 5b ff ff ff       	call   c0104d96 <find_order>
c0104e3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e3e:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e43:	8b 00                	mov    (%eax),%eax
c0104e45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e4c:	89 04 24             	mov    %eax,(%esp)
c0104e4f:	e8 99 fb ff ff       	call   c01049ed <__slob_get_free_pages>
c0104e54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e57:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e5d:	8b 40 04             	mov    0x4(%eax),%eax
c0104e60:	85 c0                	test   %eax,%eax
c0104e62:	74 2f                	je     c0104e93 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c0104e64:	e8 2d fa ff ff       	call   c0104896 <__intr_save>
c0104e69:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104e6c:	8b 15 90 3f 1a c0    	mov    0xc01a3f90,%edx
c0104e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e75:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e7b:	a3 90 3f 1a c0       	mov    %eax,0xc01a3f90
		spin_unlock_irqrestore(&block_lock, flags);
c0104e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e83:	89 04 24             	mov    %eax,(%esp)
c0104e86:	e8 37 fa ff ff       	call   c01048c2 <__intr_restore>
		return bb->pages;
c0104e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e8e:	8b 40 04             	mov    0x4(%eax),%eax
c0104e91:	eb 18                	jmp    c0104eab <__kmalloc+0xf0>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104e93:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104e9a:	00 
c0104e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e9e:	89 04 24             	mov    %eax,(%esp)
c0104ea1:	e8 8d fd ff ff       	call   c0104c33 <slob_free>
	return 0;
c0104ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104eab:	89 ec                	mov    %ebp,%esp
c0104ead:	5d                   	pop    %ebp
c0104eae:	c3                   	ret    

c0104eaf <kmalloc>:

void *
kmalloc(size_t size)
{
c0104eaf:	55                   	push   %ebp
c0104eb0:	89 e5                	mov    %esp,%ebp
c0104eb2:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104eb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ebc:	00 
c0104ebd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ec0:	89 04 24             	mov    %eax,(%esp)
c0104ec3:	e8 f3 fe ff ff       	call   c0104dbb <__kmalloc>
}
c0104ec8:	89 ec                	mov    %ebp,%esp
c0104eca:	5d                   	pop    %ebp
c0104ecb:	c3                   	ret    

c0104ecc <kfree>:


void kfree(void *block)
{
c0104ecc:	55                   	push   %ebp
c0104ecd:	89 e5                	mov    %esp,%ebp
c0104ecf:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104ed2:	c7 45 f0 90 3f 1a c0 	movl   $0xc01a3f90,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104ed9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104edd:	0f 84 a3 00 00 00    	je     c0104f86 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104ee3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ee6:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104eeb:	85 c0                	test   %eax,%eax
c0104eed:	75 7f                	jne    c0104f6e <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104eef:	e8 a2 f9 ff ff       	call   c0104896 <__intr_save>
c0104ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104ef7:	a1 90 3f 1a c0       	mov    0xc01a3f90,%eax
c0104efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104eff:	eb 5c                	jmp    c0104f5d <kfree+0x91>
			if (bb->pages == block) {
c0104f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f04:	8b 40 04             	mov    0x4(%eax),%eax
c0104f07:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104f0a:	75 3f                	jne    c0104f4b <kfree+0x7f>
				*last = bb->next;
c0104f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f0f:	8b 50 08             	mov    0x8(%eax),%edx
c0104f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f15:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f1a:	89 04 24             	mov    %eax,(%esp)
c0104f1d:	e8 a0 f9 ff ff       	call   c01048c2 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f25:	8b 10                	mov    (%eax),%edx
c0104f27:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f2a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f2e:	89 04 24             	mov    %eax,(%esp)
c0104f31:	e8 f2 fa ff ff       	call   c0104a28 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104f36:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104f3d:	00 
c0104f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f41:	89 04 24             	mov    %eax,(%esp)
c0104f44:	e8 ea fc ff ff       	call   c0104c33 <slob_free>
				return;
c0104f49:	eb 3c                	jmp    c0104f87 <kfree+0xbb>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f4e:	83 c0 08             	add    $0x8,%eax
c0104f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f57:	8b 40 08             	mov    0x8(%eax),%eax
c0104f5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f61:	75 9e                	jne    c0104f01 <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f66:	89 04 24             	mov    %eax,(%esp)
c0104f69:	e8 54 f9 ff ff       	call   c01048c2 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104f6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f71:	83 e8 08             	sub    $0x8,%eax
c0104f74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104f7b:	00 
c0104f7c:	89 04 24             	mov    %eax,(%esp)
c0104f7f:	e8 af fc ff ff       	call   c0104c33 <slob_free>
	return;
c0104f84:	eb 01                	jmp    c0104f87 <kfree+0xbb>
		return;
c0104f86:	90                   	nop
}
c0104f87:	89 ec                	mov    %ebp,%esp
c0104f89:	5d                   	pop    %ebp
c0104f8a:	c3                   	ret    

c0104f8b <ksize>:


unsigned int ksize(const void *block)
{
c0104f8b:	55                   	push   %ebp
c0104f8c:	89 e5                	mov    %esp,%ebp
c0104f8e:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104f91:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f95:	75 07                	jne    c0104f9e <ksize+0x13>
		return 0;
c0104f97:	b8 00 00 00 00       	mov    $0x0,%eax
c0104f9c:	eb 6b                	jmp    c0105009 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104f9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fa1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104fa6:	85 c0                	test   %eax,%eax
c0104fa8:	75 54                	jne    c0104ffe <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104faa:	e8 e7 f8 ff ff       	call   c0104896 <__intr_save>
c0104faf:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104fb2:	a1 90 3f 1a c0       	mov    0xc01a3f90,%eax
c0104fb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fba:	eb 31                	jmp    c0104fed <ksize+0x62>
			if (bb->pages == block) {
c0104fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fbf:	8b 40 04             	mov    0x4(%eax),%eax
c0104fc2:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104fc5:	75 1d                	jne    c0104fe4 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fca:	89 04 24             	mov    %eax,(%esp)
c0104fcd:	e8 f0 f8 ff ff       	call   c01048c2 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd5:	8b 00                	mov    (%eax),%eax
c0104fd7:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104fdc:	88 c1                	mov    %al,%cl
c0104fde:	d3 e2                	shl    %cl,%edx
c0104fe0:	89 d0                	mov    %edx,%eax
c0104fe2:	eb 25                	jmp    c0105009 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0104fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fe7:	8b 40 08             	mov    0x8(%eax),%eax
c0104fea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ff1:	75 c9                	jne    c0104fbc <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ff6:	89 04 24             	mov    %eax,(%esp)
c0104ff9:	e8 c4 f8 ff ff       	call   c01048c2 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104ffe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105001:	83 e8 08             	sub    $0x8,%eax
c0105004:	8b 00                	mov    (%eax),%eax
c0105006:	c1 e0 03             	shl    $0x3,%eax
}
c0105009:	89 ec                	mov    %ebp,%esp
c010500b:	5d                   	pop    %ebp
c010500c:	c3                   	ret    

c010500d <page2ppn>:
page2ppn(struct Page *page) {
c010500d:	55                   	push   %ebp
c010500e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105010:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0105016:	8b 45 08             	mov    0x8(%ebp),%eax
c0105019:	29 d0                	sub    %edx,%eax
c010501b:	c1 f8 05             	sar    $0x5,%eax
}
c010501e:	5d                   	pop    %ebp
c010501f:	c3                   	ret    

c0105020 <page2pa>:
page2pa(struct Page *page) {
c0105020:	55                   	push   %ebp
c0105021:	89 e5                	mov    %esp,%ebp
c0105023:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105026:	8b 45 08             	mov    0x8(%ebp),%eax
c0105029:	89 04 24             	mov    %eax,(%esp)
c010502c:	e8 dc ff ff ff       	call   c010500d <page2ppn>
c0105031:	c1 e0 0c             	shl    $0xc,%eax
}
c0105034:	89 ec                	mov    %ebp,%esp
c0105036:	5d                   	pop    %ebp
c0105037:	c3                   	ret    

c0105038 <pa2page>:
pa2page(uintptr_t pa) {
c0105038:	55                   	push   %ebp
c0105039:	89 e5                	mov    %esp,%ebp
c010503b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010503e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105041:	c1 e8 0c             	shr    $0xc,%eax
c0105044:	89 c2                	mov    %eax,%edx
c0105046:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010504b:	39 c2                	cmp    %eax,%edx
c010504d:	72 1c                	jb     c010506b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010504f:	c7 44 24 08 f0 cf 10 	movl   $0xc010cff0,0x8(%esp)
c0105056:	c0 
c0105057:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010505e:	00 
c010505f:	c7 04 24 0f d0 10 c0 	movl   $0xc010d00f,(%esp)
c0105066:	e8 80 bd ff ff       	call   c0100deb <__panic>
    return &pages[PPN(pa)];
c010506b:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0105071:	8b 45 08             	mov    0x8(%ebp),%eax
c0105074:	c1 e8 0c             	shr    $0xc,%eax
c0105077:	c1 e0 05             	shl    $0x5,%eax
c010507a:	01 d0                	add    %edx,%eax
}
c010507c:	89 ec                	mov    %ebp,%esp
c010507e:	5d                   	pop    %ebp
c010507f:	c3                   	ret    

c0105080 <page2kva>:
page2kva(struct Page *page) {
c0105080:	55                   	push   %ebp
c0105081:	89 e5                	mov    %esp,%ebp
c0105083:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0105086:	8b 45 08             	mov    0x8(%ebp),%eax
c0105089:	89 04 24             	mov    %eax,(%esp)
c010508c:	e8 8f ff ff ff       	call   c0105020 <page2pa>
c0105091:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105094:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105097:	c1 e8 0c             	shr    $0xc,%eax
c010509a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010509d:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01050a2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01050a5:	72 23                	jb     c01050ca <page2kva+0x4a>
c01050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050ae:	c7 44 24 08 20 d0 10 	movl   $0xc010d020,0x8(%esp)
c01050b5:	c0 
c01050b6:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01050bd:	00 
c01050be:	c7 04 24 0f d0 10 c0 	movl   $0xc010d00f,(%esp)
c01050c5:	e8 21 bd ff ff       	call   c0100deb <__panic>
c01050ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050cd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01050d2:	89 ec                	mov    %ebp,%esp
c01050d4:	5d                   	pop    %ebp
c01050d5:	c3                   	ret    

c01050d6 <pte2page>:
pte2page(pte_t pte) {
c01050d6:	55                   	push   %ebp
c01050d7:	89 e5                	mov    %esp,%ebp
c01050d9:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01050dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01050df:	83 e0 01             	and    $0x1,%eax
c01050e2:	85 c0                	test   %eax,%eax
c01050e4:	75 1c                	jne    c0105102 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01050e6:	c7 44 24 08 44 d0 10 	movl   $0xc010d044,0x8(%esp)
c01050ed:	c0 
c01050ee:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01050f5:	00 
c01050f6:	c7 04 24 0f d0 10 c0 	movl   $0xc010d00f,(%esp)
c01050fd:	e8 e9 bc ff ff       	call   c0100deb <__panic>
    return pa2page(PTE_ADDR(pte));
c0105102:	8b 45 08             	mov    0x8(%ebp),%eax
c0105105:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010510a:	89 04 24             	mov    %eax,(%esp)
c010510d:	e8 26 ff ff ff       	call   c0105038 <pa2page>
}
c0105112:	89 ec                	mov    %ebp,%esp
c0105114:	5d                   	pop    %ebp
c0105115:	c3                   	ret    

c0105116 <pde2page>:
pde2page(pde_t pde) {
c0105116:	55                   	push   %ebp
c0105117:	89 e5                	mov    %esp,%ebp
c0105119:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010511c:	8b 45 08             	mov    0x8(%ebp),%eax
c010511f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105124:	89 04 24             	mov    %eax,(%esp)
c0105127:	e8 0c ff ff ff       	call   c0105038 <pa2page>
}
c010512c:	89 ec                	mov    %ebp,%esp
c010512e:	5d                   	pop    %ebp
c010512f:	c3                   	ret    

c0105130 <page_ref>:
page_ref(struct Page *page) {
c0105130:	55                   	push   %ebp
c0105131:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0105133:	8b 45 08             	mov    0x8(%ebp),%eax
c0105136:	8b 00                	mov    (%eax),%eax
}
c0105138:	5d                   	pop    %ebp
c0105139:	c3                   	ret    

c010513a <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010513a:	55                   	push   %ebp
c010513b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010513d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105140:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105143:	89 10                	mov    %edx,(%eax)
}
c0105145:	90                   	nop
c0105146:	5d                   	pop    %ebp
c0105147:	c3                   	ret    

c0105148 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0105148:	55                   	push   %ebp
c0105149:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010514b:	8b 45 08             	mov    0x8(%ebp),%eax
c010514e:	8b 00                	mov    (%eax),%eax
c0105150:	8d 50 01             	lea    0x1(%eax),%edx
c0105153:	8b 45 08             	mov    0x8(%ebp),%eax
c0105156:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0105158:	8b 45 08             	mov    0x8(%ebp),%eax
c010515b:	8b 00                	mov    (%eax),%eax
}
c010515d:	5d                   	pop    %ebp
c010515e:	c3                   	ret    

c010515f <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010515f:	55                   	push   %ebp
c0105160:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0105162:	8b 45 08             	mov    0x8(%ebp),%eax
c0105165:	8b 00                	mov    (%eax),%eax
c0105167:	8d 50 ff             	lea    -0x1(%eax),%edx
c010516a:	8b 45 08             	mov    0x8(%ebp),%eax
c010516d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010516f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105172:	8b 00                	mov    (%eax),%eax
}
c0105174:	5d                   	pop    %ebp
c0105175:	c3                   	ret    

c0105176 <__intr_save>:
__intr_save(void) {
c0105176:	55                   	push   %ebp
c0105177:	89 e5                	mov    %esp,%ebp
c0105179:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010517c:	9c                   	pushf  
c010517d:	58                   	pop    %eax
c010517e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0105181:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0105184:	25 00 02 00 00       	and    $0x200,%eax
c0105189:	85 c0                	test   %eax,%eax
c010518b:	74 0c                	je     c0105199 <__intr_save+0x23>
        intr_disable();
c010518d:	e8 0f cf ff ff       	call   c01020a1 <intr_disable>
        return 1;
c0105192:	b8 01 00 00 00       	mov    $0x1,%eax
c0105197:	eb 05                	jmp    c010519e <__intr_save+0x28>
    return 0;
c0105199:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010519e:	89 ec                	mov    %ebp,%esp
c01051a0:	5d                   	pop    %ebp
c01051a1:	c3                   	ret    

c01051a2 <__intr_restore>:
__intr_restore(bool flag) {
c01051a2:	55                   	push   %ebp
c01051a3:	89 e5                	mov    %esp,%ebp
c01051a5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01051a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01051ac:	74 05                	je     c01051b3 <__intr_restore+0x11>
        intr_enable();
c01051ae:	e8 e6 ce ff ff       	call   c0102099 <intr_enable>
}
c01051b3:	90                   	nop
c01051b4:	89 ec                	mov    %ebp,%esp
c01051b6:	5d                   	pop    %ebp
c01051b7:	c3                   	ret    

c01051b8 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01051b8:	55                   	push   %ebp
c01051b9:	89 e5                	mov    %esp,%ebp
    asm volatile("lgdt (%0)" ::"r"(pd));
c01051bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01051be:	0f 01 10             	lgdtl  (%eax)
    asm volatile("movw %%ax, %%gs" ::"a"(USER_DS));
c01051c1:	b8 23 00 00 00       	mov    $0x23,%eax
c01051c6:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax, %%fs" ::"a"(USER_DS));
c01051c8:	b8 23 00 00 00       	mov    $0x23,%eax
c01051cd:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax, %%es" ::"a"(KERNEL_DS));
c01051cf:	b8 10 00 00 00       	mov    $0x10,%eax
c01051d4:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax, %%ds" ::"a"(KERNEL_DS));
c01051d6:	b8 10 00 00 00       	mov    $0x10,%eax
c01051db:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax, %%ss" ::"a"(KERNEL_DS));
c01051dd:	b8 10 00 00 00       	mov    $0x10,%eax
c01051e2:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile("ljmp %0, $1f\n 1:\n" ::"i"(KERNEL_CS));
c01051e4:	ea eb 51 10 c0 08 00 	ljmp   $0x8,$0xc01051eb
}
c01051eb:	90                   	nop
c01051ec:	5d                   	pop    %ebp
c01051ed:	c3                   	ret    

c01051ee <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01051ee:	55                   	push   %ebp
c01051ef:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01051f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01051f4:	a3 c4 3f 1a c0       	mov    %eax,0xc01a3fc4
}
c01051f9:	90                   	nop
c01051fa:	5d                   	pop    %ebp
c01051fb:	c3                   	ret    

c01051fc <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01051fc:	55                   	push   %ebp
c01051fd:	89 e5                	mov    %esp,%ebp
c01051ff:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0105202:	b8 00 f0 12 c0       	mov    $0xc012f000,%eax
c0105207:	89 04 24             	mov    %eax,(%esp)
c010520a:	e8 df ff ff ff       	call   c01051ee <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c010520f:	66 c7 05 c8 3f 1a c0 	movw   $0x10,0xc01a3fc8
c0105216:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0105218:	66 c7 05 48 fa 12 c0 	movw   $0x68,0xc012fa48
c010521f:	68 00 
c0105221:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c0105226:	0f b7 c0             	movzwl %ax,%eax
c0105229:	66 a3 4a fa 12 c0    	mov    %ax,0xc012fa4a
c010522f:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c0105234:	c1 e8 10             	shr    $0x10,%eax
c0105237:	a2 4c fa 12 c0       	mov    %al,0xc012fa4c
c010523c:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0105243:	24 f0                	and    $0xf0,%al
c0105245:	0c 09                	or     $0x9,%al
c0105247:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c010524c:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0105253:	24 ef                	and    $0xef,%al
c0105255:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c010525a:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c0105261:	24 9f                	and    $0x9f,%al
c0105263:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0105268:	0f b6 05 4d fa 12 c0 	movzbl 0xc012fa4d,%eax
c010526f:	0c 80                	or     $0x80,%al
c0105271:	a2 4d fa 12 c0       	mov    %al,0xc012fa4d
c0105276:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c010527d:	24 f0                	and    $0xf0,%al
c010527f:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0105284:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c010528b:	24 ef                	and    $0xef,%al
c010528d:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c0105292:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c0105299:	24 df                	and    $0xdf,%al
c010529b:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c01052a0:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c01052a7:	0c 40                	or     $0x40,%al
c01052a9:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c01052ae:	0f b6 05 4e fa 12 c0 	movzbl 0xc012fa4e,%eax
c01052b5:	24 7f                	and    $0x7f,%al
c01052b7:	a2 4e fa 12 c0       	mov    %al,0xc012fa4e
c01052bc:	b8 c0 3f 1a c0       	mov    $0xc01a3fc0,%eax
c01052c1:	c1 e8 18             	shr    $0x18,%eax
c01052c4:	a2 4f fa 12 c0       	mov    %al,0xc012fa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01052c9:	c7 04 24 50 fa 12 c0 	movl   $0xc012fa50,(%esp)
c01052d0:	e8 e3 fe ff ff       	call   c01051b8 <lgdt>
c01052d5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01052db:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01052df:	0f 00 d8             	ltr    %ax
}
c01052e2:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01052e3:	90                   	nop
c01052e4:	89 ec                	mov    %ebp,%esp
c01052e6:	5d                   	pop    %ebp
c01052e7:	c3                   	ret    

c01052e8 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01052e8:	55                   	push   %ebp
c01052e9:	89 e5                	mov    %esp,%ebp
c01052eb:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01052ee:	c7 05 ac 3f 1a c0 d8 	movl   $0xc010ced8,0xc01a3fac
c01052f5:	ce 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01052f8:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c01052fd:	8b 00                	mov    (%eax),%eax
c01052ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105303:	c7 04 24 70 d0 10 c0 	movl   $0xc010d070,(%esp)
c010530a:	e8 5e b0 ff ff       	call   c010036d <cprintf>
    pmm_manager->init();
c010530f:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0105314:	8b 40 04             	mov    0x4(%eax),%eax
c0105317:	ff d0                	call   *%eax
}
c0105319:	90                   	nop
c010531a:	89 ec                	mov    %ebp,%esp
c010531c:	5d                   	pop    %ebp
c010531d:	c3                   	ret    

c010531e <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c010531e:	55                   	push   %ebp
c010531f:	89 e5                	mov    %esp,%ebp
c0105321:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0105324:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c0105329:	8b 40 08             	mov    0x8(%eax),%eax
c010532c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010532f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105333:	8b 55 08             	mov    0x8(%ebp),%edx
c0105336:	89 14 24             	mov    %edx,(%esp)
c0105339:	ff d0                	call   *%eax
}
c010533b:	90                   	nop
c010533c:	89 ec                	mov    %ebp,%esp
c010533e:	5d                   	pop    %ebp
c010533f:	c3                   	ret    

c0105340 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n) {
c0105340:	55                   	push   %ebp
c0105341:	89 e5                	mov    %esp,%ebp
c0105343:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = NULL;
c0105346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
c010534d:	e8 24 fe ff ff       	call   c0105176 <__intr_save>
c0105352:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c0105355:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c010535a:	8b 40 0c             	mov    0xc(%eax),%eax
c010535d:	8b 55 08             	mov    0x8(%ebp),%edx
c0105360:	89 14 24             	mov    %edx,(%esp)
c0105363:	ff d0                	call   *%eax
c0105365:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c0105368:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010536b:	89 04 24             	mov    %eax,(%esp)
c010536e:	e8 2f fe ff ff       	call   c01051a2 <__intr_restore>

        if (page != NULL || n > 1 || swap_init_ok == 0)
c0105373:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105377:	75 2d                	jne    c01053a6 <alloc_pages+0x66>
c0105379:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010537d:	77 27                	ja     c01053a6 <alloc_pages+0x66>
c010537f:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c0105384:	85 c0                	test   %eax,%eax
c0105386:	74 1e                	je     c01053a6 <alloc_pages+0x66>
            break;

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c0105388:	8b 55 08             	mov    0x8(%ebp),%edx
c010538b:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0105390:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105397:	00 
c0105398:	89 54 24 04          	mov    %edx,0x4(%esp)
c010539c:	89 04 24             	mov    %eax,(%esp)
c010539f:	e8 bb 1c 00 00       	call   c010705f <swap_out>
    while (1) {
c01053a4:	eb a7                	jmp    c010534d <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01053a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01053a9:	89 ec                	mov    %ebp,%esp
c01053ab:	5d                   	pop    %ebp
c01053ac:	c3                   	ret    

c01053ad <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void
free_pages(struct Page *base, size_t n) {
c01053ad:	55                   	push   %ebp
c01053ae:	89 e5                	mov    %esp,%ebp
c01053b0:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01053b3:	e8 be fd ff ff       	call   c0105176 <__intr_save>
c01053b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01053bb:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c01053c0:	8b 40 10             	mov    0x10(%eax),%eax
c01053c3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01053c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053ca:	8b 55 08             	mov    0x8(%ebp),%edx
c01053cd:	89 14 24             	mov    %edx,(%esp)
c01053d0:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01053d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053d5:	89 04 24             	mov    %eax,(%esp)
c01053d8:	e8 c5 fd ff ff       	call   c01051a2 <__intr_restore>
}
c01053dd:	90                   	nop
c01053de:	89 ec                	mov    %ebp,%esp
c01053e0:	5d                   	pop    %ebp
c01053e1:	c3                   	ret    

c01053e2 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void) {
c01053e2:	55                   	push   %ebp
c01053e3:	89 e5                	mov    %esp,%ebp
c01053e5:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01053e8:	e8 89 fd ff ff       	call   c0105176 <__intr_save>
c01053ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01053f0:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c01053f5:	8b 40 14             	mov    0x14(%eax),%eax
c01053f8:	ff d0                	call   *%eax
c01053fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01053fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105400:	89 04 24             	mov    %eax,(%esp)
c0105403:	e8 9a fd ff ff       	call   c01051a2 <__intr_restore>
    return ret;
c0105408:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010540b:	89 ec                	mov    %ebp,%esp
c010540d:	5d                   	pop    %ebp
c010540e:	c3                   	ret    

c010540f <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010540f:	55                   	push   %ebp
c0105410:	89 e5                	mov    %esp,%ebp
c0105412:	57                   	push   %edi
c0105413:	56                   	push   %esi
c0105414:	53                   	push   %ebx
c0105415:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010541b:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0105422:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0105430:	c7 04 24 87 d0 10 c0 	movl   $0xc010d087,(%esp)
c0105437:	e8 31 af ff ff       	call   c010036d <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i++) {
c010543c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105443:	e9 0c 01 00 00       	jmp    c0105554 <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105448:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010544b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010544e:	89 d0                	mov    %edx,%eax
c0105450:	c1 e0 02             	shl    $0x2,%eax
c0105453:	01 d0                	add    %edx,%eax
c0105455:	c1 e0 02             	shl    $0x2,%eax
c0105458:	01 c8                	add    %ecx,%eax
c010545a:	8b 50 08             	mov    0x8(%eax),%edx
c010545d:	8b 40 04             	mov    0x4(%eax),%eax
c0105460:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0105463:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0105466:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105469:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010546c:	89 d0                	mov    %edx,%eax
c010546e:	c1 e0 02             	shl    $0x2,%eax
c0105471:	01 d0                	add    %edx,%eax
c0105473:	c1 e0 02             	shl    $0x2,%eax
c0105476:	01 c8                	add    %ecx,%eax
c0105478:	8b 48 0c             	mov    0xc(%eax),%ecx
c010547b:	8b 58 10             	mov    0x10(%eax),%ebx
c010547e:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0105481:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0105484:	01 c8                	add    %ecx,%eax
c0105486:	11 da                	adc    %ebx,%edx
c0105488:	89 45 98             	mov    %eax,-0x68(%ebp)
c010548b:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010548e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105491:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105494:	89 d0                	mov    %edx,%eax
c0105496:	c1 e0 02             	shl    $0x2,%eax
c0105499:	01 d0                	add    %edx,%eax
c010549b:	c1 e0 02             	shl    $0x2,%eax
c010549e:	01 c8                	add    %ecx,%eax
c01054a0:	83 c0 14             	add    $0x14,%eax
c01054a3:	8b 00                	mov    (%eax),%eax
c01054a5:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01054ab:	8b 45 98             	mov    -0x68(%ebp),%eax
c01054ae:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01054b1:	83 c0 ff             	add    $0xffffffff,%eax
c01054b4:	83 d2 ff             	adc    $0xffffffff,%edx
c01054b7:	89 c6                	mov    %eax,%esi
c01054b9:	89 d7                	mov    %edx,%edi
c01054bb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01054be:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01054c1:	89 d0                	mov    %edx,%eax
c01054c3:	c1 e0 02             	shl    $0x2,%eax
c01054c6:	01 d0                	add    %edx,%eax
c01054c8:	c1 e0 02             	shl    $0x2,%eax
c01054cb:	01 c8                	add    %ecx,%eax
c01054cd:	8b 48 0c             	mov    0xc(%eax),%ecx
c01054d0:	8b 58 10             	mov    0x10(%eax),%ebx
c01054d3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01054d9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01054dd:	89 74 24 14          	mov    %esi,0x14(%esp)
c01054e1:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01054e5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01054e8:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01054eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01054ef:	89 54 24 10          	mov    %edx,0x10(%esp)
c01054f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01054f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01054fb:	c7 04 24 94 d0 10 c0 	movl   $0xc010d094,(%esp)
c0105502:	e8 66 ae ff ff       	call   c010036d <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105507:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010550a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010550d:	89 d0                	mov    %edx,%eax
c010550f:	c1 e0 02             	shl    $0x2,%eax
c0105512:	01 d0                	add    %edx,%eax
c0105514:	c1 e0 02             	shl    $0x2,%eax
c0105517:	01 c8                	add    %ecx,%eax
c0105519:	83 c0 14             	add    $0x14,%eax
c010551c:	8b 00                	mov    (%eax),%eax
c010551e:	83 f8 01             	cmp    $0x1,%eax
c0105521:	75 2e                	jne    c0105551 <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c0105523:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105526:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105529:	3b 45 98             	cmp    -0x68(%ebp),%eax
c010552c:	89 d0                	mov    %edx,%eax
c010552e:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0105531:	73 1e                	jae    c0105551 <page_init+0x142>
c0105533:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0105538:	b8 00 00 00 00       	mov    $0x0,%eax
c010553d:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0105540:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0105543:	72 0c                	jb     c0105551 <page_init+0x142>
                maxpa = end;
c0105545:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105548:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010554b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010554e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i++) {
c0105551:	ff 45 dc             	incl   -0x24(%ebp)
c0105554:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105557:	8b 00                	mov    (%eax),%eax
c0105559:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010555c:	0f 8c e6 fe ff ff    	jl     c0105448 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0105562:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0105567:	b8 00 00 00 00       	mov    $0x0,%eax
c010556c:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c010556f:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0105572:	73 0e                	jae    c0105582 <page_init+0x173>
        maxpa = KMEMSIZE;
c0105574:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010557b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // generated by ld file
    extern char end[];

    npage = maxpa / PGSIZE;
c0105582:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105585:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105588:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010558c:	c1 ea 0c             	shr    $0xc,%edx
c010558f:	a3 a4 3f 1a c0       	mov    %eax,0xc01a3fa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0105594:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c010559b:	b8 54 61 1a c0       	mov    $0xc01a6154,%eax
c01055a0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01055a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01055a6:	01 d0                	add    %edx,%eax
c01055a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01055ab:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01055ae:	ba 00 00 00 00       	mov    $0x0,%edx
c01055b3:	f7 75 c0             	divl   -0x40(%ebp)
c01055b6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01055b9:	29 d0                	sub    %edx,%eax
c01055bb:	a3 a0 3f 1a c0       	mov    %eax,0xc01a3fa0

    for (i = 0; i < npage; i++) {
c01055c0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01055c7:	eb 28                	jmp    c01055f1 <page_init+0x1e2>
        SetPageReserved(pages + i);
c01055c9:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01055cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055d2:	c1 e0 05             	shl    $0x5,%eax
c01055d5:	01 d0                	add    %edx,%eax
c01055d7:	83 c0 04             	add    $0x4,%eax
c01055da:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01055e1:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01055e4:	8b 45 90             	mov    -0x70(%ebp),%eax
c01055e7:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01055ea:	0f ab 10             	bts    %edx,(%eax)
}
c01055ed:	90                   	nop
    for (i = 0; i < npage; i++) {
c01055ee:	ff 45 dc             	incl   -0x24(%ebp)
c01055f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055f4:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01055f9:	39 c2                	cmp    %eax,%edx
c01055fb:	72 cc                	jb     c01055c9 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01055fd:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105602:	c1 e0 05             	shl    $0x5,%eax
c0105605:	89 c2                	mov    %eax,%edx
c0105607:	a1 a0 3f 1a c0       	mov    0xc01a3fa0,%eax
c010560c:	01 d0                	add    %edx,%eax
c010560e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105611:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0105618:	77 23                	ja     c010563d <page_init+0x22e>
c010561a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010561d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105621:	c7 44 24 08 c4 d0 10 	movl   $0xc010d0c4,0x8(%esp)
c0105628:	c0 
c0105629:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0105630:	00 
c0105631:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105638:	e8 ae b7 ff ff       	call   c0100deb <__panic>
c010563d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105640:	05 00 00 00 40       	add    $0x40000000,%eax
c0105645:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i++) {
c0105648:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010564f:	e9 53 01 00 00       	jmp    c01057a7 <page_init+0x398>
        // memmap is the already existing memory layout given by BIOS
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105654:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105657:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010565a:	89 d0                	mov    %edx,%eax
c010565c:	c1 e0 02             	shl    $0x2,%eax
c010565f:	01 d0                	add    %edx,%eax
c0105661:	c1 e0 02             	shl    $0x2,%eax
c0105664:	01 c8                	add    %ecx,%eax
c0105666:	8b 50 08             	mov    0x8(%eax),%edx
c0105669:	8b 40 04             	mov    0x4(%eax),%eax
c010566c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010566f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105672:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105675:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105678:	89 d0                	mov    %edx,%eax
c010567a:	c1 e0 02             	shl    $0x2,%eax
c010567d:	01 d0                	add    %edx,%eax
c010567f:	c1 e0 02             	shl    $0x2,%eax
c0105682:	01 c8                	add    %ecx,%eax
c0105684:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105687:	8b 58 10             	mov    0x10(%eax),%ebx
c010568a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010568d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105690:	01 c8                	add    %ecx,%eax
c0105692:	11 da                	adc    %ebx,%edx
c0105694:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105697:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010569a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010569d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01056a0:	89 d0                	mov    %edx,%eax
c01056a2:	c1 e0 02             	shl    $0x2,%eax
c01056a5:	01 d0                	add    %edx,%eax
c01056a7:	c1 e0 02             	shl    $0x2,%eax
c01056aa:	01 c8                	add    %ecx,%eax
c01056ac:	83 c0 14             	add    $0x14,%eax
c01056af:	8b 00                	mov    (%eax),%eax
c01056b1:	83 f8 01             	cmp    $0x1,%eax
c01056b4:	0f 85 ea 00 00 00    	jne    c01057a4 <page_init+0x395>
            // these two ifs are correct the boundary
            if (begin < freemem) {
c01056ba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01056bd:	ba 00 00 00 00       	mov    $0x0,%edx
c01056c2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01056c5:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01056c8:	19 d1                	sbb    %edx,%ecx
c01056ca:	73 0d                	jae    c01056d9 <page_init+0x2ca>
                begin = freemem;
c01056cc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01056cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01056d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01056d9:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01056de:	b8 00 00 00 00       	mov    $0x0,%eax
c01056e3:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01056e6:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01056e9:	73 0e                	jae    c01056f9 <page_init+0x2ea>
                end = KMEMSIZE;
c01056eb:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01056f2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            // correct the boundary and call init_memmap(), that is to say,
            // the default_init_memmap(), whose args are block_size and PageNum
            // only the blocks over the freemem can be init
            if (begin < end) {
c01056f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056fc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01056ff:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105702:	89 d0                	mov    %edx,%eax
c0105704:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105707:	0f 83 97 00 00 00    	jae    c01057a4 <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c010570d:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0105714:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105717:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010571a:	01 d0                	add    %edx,%eax
c010571c:	48                   	dec    %eax
c010571d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0105720:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105723:	ba 00 00 00 00       	mov    $0x0,%edx
c0105728:	f7 75 b0             	divl   -0x50(%ebp)
c010572b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010572e:	29 d0                	sub    %edx,%eax
c0105730:	ba 00 00 00 00       	mov    $0x0,%edx
c0105735:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105738:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010573b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010573e:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0105741:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105744:	ba 00 00 00 00       	mov    $0x0,%edx
c0105749:	89 c7                	mov    %eax,%edi
c010574b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0105751:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0105754:	89 d0                	mov    %edx,%eax
c0105756:	83 e0 00             	and    $0x0,%eax
c0105759:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010575c:	8b 45 80             	mov    -0x80(%ebp),%eax
c010575f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105762:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105765:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0105768:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010576b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010576e:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105771:	89 d0                	mov    %edx,%eax
c0105773:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105776:	73 2c                	jae    c01057a4 <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0105778:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010577b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010577e:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0105781:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0105784:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105788:	c1 ea 0c             	shr    $0xc,%edx
c010578b:	89 c3                	mov    %eax,%ebx
c010578d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105790:	89 04 24             	mov    %eax,(%esp)
c0105793:	e8 a0 f8 ff ff       	call   c0105038 <pa2page>
c0105798:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010579c:	89 04 24             	mov    %eax,(%esp)
c010579f:	e8 7a fb ff ff       	call   c010531e <init_memmap>
    for (i = 0; i < memmap->nr_map; i++) {
c01057a4:	ff 45 dc             	incl   -0x24(%ebp)
c01057a7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01057aa:	8b 00                	mov    (%eax),%eax
c01057ac:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01057af:	0f 8c 9f fe ff ff    	jl     c0105654 <page_init+0x245>
                }
            }
        }
    }
}
c01057b5:	90                   	nop
c01057b6:	90                   	nop
c01057b7:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01057bd:	5b                   	pop    %ebx
c01057be:	5e                   	pop    %esi
c01057bf:	5f                   	pop    %edi
c01057c0:	5d                   	pop    %ebp
c01057c1:	c3                   	ret    

c01057c2 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01057c2:	55                   	push   %ebp
c01057c3:	89 e5                	mov    %esp,%ebp
c01057c5:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01057c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057cb:	33 45 14             	xor    0x14(%ebp),%eax
c01057ce:	25 ff 0f 00 00       	and    $0xfff,%eax
c01057d3:	85 c0                	test   %eax,%eax
c01057d5:	74 24                	je     c01057fb <boot_map_segment+0x39>
c01057d7:	c7 44 24 0c f6 d0 10 	movl   $0xc010d0f6,0xc(%esp)
c01057de:	c0 
c01057df:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01057e6:	c0 
c01057e7:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01057ee:	00 
c01057ef:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01057f6:	e8 f0 b5 ff ff       	call   c0100deb <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01057fb:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0105802:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105805:	25 ff 0f 00 00       	and    $0xfff,%eax
c010580a:	89 c2                	mov    %eax,%edx
c010580c:	8b 45 10             	mov    0x10(%ebp),%eax
c010580f:	01 c2                	add    %eax,%edx
c0105811:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105814:	01 d0                	add    %edx,%eax
c0105816:	48                   	dec    %eax
c0105817:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010581a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010581d:	ba 00 00 00 00       	mov    $0x0,%edx
c0105822:	f7 75 f0             	divl   -0x10(%ebp)
c0105825:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105828:	29 d0                	sub    %edx,%eax
c010582a:	c1 e8 0c             	shr    $0xc,%eax
c010582d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0105830:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105833:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105836:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105839:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010583e:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0105841:	8b 45 14             	mov    0x14(%ebp),%eax
c0105844:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105847:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010584a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010584f:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {
c0105852:	eb 68                	jmp    c01058bc <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0105854:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010585b:	00 
c010585c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010585f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105863:	8b 45 08             	mov    0x8(%ebp),%eax
c0105866:	89 04 24             	mov    %eax,(%esp)
c0105869:	e8 8d 01 00 00       	call   c01059fb <get_pte>
c010586e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0105871:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105875:	75 24                	jne    c010589b <boot_map_segment+0xd9>
c0105877:	c7 44 24 0c 22 d1 10 	movl   $0xc010d122,0xc(%esp)
c010587e:	c0 
c010587f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105886:	c0 
c0105887:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c010588e:	00 
c010588f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105896:	e8 50 b5 ff ff       	call   c0100deb <__panic>
        *ptep = pa | PTE_P | perm;
c010589b:	8b 45 14             	mov    0x14(%ebp),%eax
c010589e:	0b 45 18             	or     0x18(%ebp),%eax
c01058a1:	83 c8 01             	or     $0x1,%eax
c01058a4:	89 c2                	mov    %eax,%edx
c01058a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058a9:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {
c01058ab:	ff 4d f4             	decl   -0xc(%ebp)
c01058ae:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01058b5:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01058bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058c0:	75 92                	jne    c0105854 <boot_map_segment+0x92>
    }
}
c01058c2:	90                   	nop
c01058c3:	90                   	nop
c01058c4:	89 ec                	mov    %ebp,%esp
c01058c6:	5d                   	pop    %ebp
c01058c7:	c3                   	ret    

c01058c8 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01058c8:	55                   	push   %ebp
c01058c9:	89 e5                	mov    %esp,%ebp
c01058cb:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01058ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058d5:	e8 66 fa ff ff       	call   c0105340 <alloc_pages>
c01058da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01058dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058e1:	75 1c                	jne    c01058ff <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01058e3:	c7 44 24 08 2f d1 10 	movl   $0xc010d12f,0x8(%esp)
c01058ea:	c0 
c01058eb:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c01058f2:	00 
c01058f3:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01058fa:	e8 ec b4 ff ff       	call   c0100deb <__panic>
    }
    return page2kva(p);
c01058ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105902:	89 04 24             	mov    %eax,(%esp)
c0105905:	e8 76 f7 ff ff       	call   c0105080 <page2kva>
}
c010590a:	89 ec                	mov    %ebp,%esp
c010590c:	5d                   	pop    %ebp
c010590d:	c3                   	ret    

c010590e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010590e:	55                   	push   %ebp
c010590f:	89 e5                	mov    %esp,%ebp
c0105911:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0105914:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0105919:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010591c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105923:	77 23                	ja     c0105948 <pmm_init+0x3a>
c0105925:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105928:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010592c:	c7 44 24 08 c4 d0 10 	movl   $0xc010d0c4,0x8(%esp)
c0105933:	c0 
c0105934:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c010593b:	00 
c010593c:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105943:	e8 a3 b4 ff ff       	call   c0100deb <__panic>
c0105948:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010594b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105950:	a3 a8 3f 1a c0       	mov    %eax,0xc01a3fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105955:	e8 8e f9 ff ff       	call   c01052e8 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010595a:	e8 b0 fa ff ff       	call   c010540f <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010595f:	e8 9b 08 00 00       	call   c01061ff <check_alloc_page>

    check_pgdir();
c0105964:	e8 b7 08 00 00       	call   c0106220 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0105969:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010596e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105971:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105978:	77 23                	ja     c010599d <pmm_init+0x8f>
c010597a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010597d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105981:	c7 44 24 08 c4 d0 10 	movl   $0xc010d0c4,0x8(%esp)
c0105988:	c0 
c0105989:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
c0105990:	00 
c0105991:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105998:	e8 4e b4 ff ff       	call   c0100deb <__panic>
c010599d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059a0:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01059a6:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01059ab:	05 ac 0f 00 00       	add    $0xfac,%eax
c01059b0:	83 ca 03             	or     $0x3,%edx
c01059b3:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01059b5:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01059ba:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01059c1:	00 
c01059c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01059c9:	00 
c01059ca:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01059d1:	38 
c01059d2:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01059d9:	c0 
c01059da:	89 04 24             	mov    %eax,(%esp)
c01059dd:	e8 e0 fd ff ff       	call   c01057c2 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01059e2:	e8 15 f8 ff ff       	call   c01051fc <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01059e7:	e8 d2 0e 00 00       	call   c01068be <check_boot_pgdir>

    print_pgdir();
c01059ec:	e8 4f 13 00 00       	call   c0106d40 <print_pgdir>

    kmalloc_init();
c01059f1:	e8 70 f3 ff ff       	call   c0104d66 <kmalloc_init>
}
c01059f6:	90                   	nop
c01059f7:	89 ec                	mov    %ebp,%esp
c01059f9:	5d                   	pop    %ebp
c01059fa:	c3                   	ret    

c01059fb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01059fb:	55                   	push   %ebp
c01059fc:	89 e5                	mov    %esp,%ebp
c01059fe:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = PDX(la) + pgdir;  // (1) find page directory entry
c0105a01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a04:	c1 e8 16             	shr    $0x16,%eax
c0105a07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a11:	01 d0                	add    %edx,%eax
c0105a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // (2) check if entry is not present
c0105a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a19:	8b 00                	mov    (%eax),%eax
c0105a1b:	83 e0 01             	and    $0x1,%eax
c0105a1e:	85 c0                	test   %eax,%eax
c0105a20:	0f 85 af 00 00 00    	jne    c0105ad5 <get_pte+0xda>
        // (4) set page reference
        // (5) get linear address of page
        // (6) clear page content using memset
        // (7) set page directory entry's permission
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0105a26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a2a:	74 15                	je     c0105a41 <get_pte+0x46>
c0105a2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a33:	e8 08 f9 ff ff       	call   c0105340 <alloc_pages>
c0105a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105a3f:	75 0a                	jne    c0105a4b <get_pte+0x50>
            return NULL;
c0105a41:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a46:	e9 ed 00 00 00       	jmp    c0105b38 <get_pte+0x13d>
        }
        set_page_ref(page, 1);
c0105a4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a52:	00 
c0105a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a56:	89 04 24             	mov    %eax,(%esp)
c0105a59:	e8 dc f6 ff ff       	call   c010513a <set_page_ref>
        uintptr_t pa = page2pa(page);  // the physical address of page table
c0105a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a61:	89 04 24             	mov    %eax,(%esp)
c0105a64:	e8 b7 f5 ff ff       	call   c0105020 <page2pa>
c0105a69:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105a6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a75:	c1 e8 0c             	shr    $0xc,%eax
c0105a78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a7b:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105a80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105a83:	72 23                	jb     c0105aa8 <get_pte+0xad>
c0105a85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a88:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a8c:	c7 44 24 08 20 d0 10 	movl   $0xc010d020,0x8(%esp)
c0105a93:	c0 
c0105a94:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0105a9b:	00 
c0105a9c:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105aa3:	e8 43 b3 ff ff       	call   c0100deb <__panic>
c0105aa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105aab:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105ab0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105ab7:	00 
c0105ab8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105abf:	00 
c0105ac0:	89 04 24             	mov    %eax,(%esp)
c0105ac3:	e8 16 65 00 00       	call   c010bfde <memset>
        *pdep = pa | PTE_P | PTE_W | PTE_U;
c0105ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105acb:	83 c8 07             	or     $0x7,%eax
c0105ace:	89 c2                	mov    %eax,%edx
c0105ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad3:	89 10                	mov    %edx,(%eax)
    }

    pte_t *ptep = (pte_t *)KADDR(PDE_ADDR(*pdep)) + PTX(la);
c0105ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad8:	8b 00                	mov    (%eax),%eax
c0105ada:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105adf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ae5:	c1 e8 0c             	shr    $0xc,%eax
c0105ae8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105aeb:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0105af0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105af3:	72 23                	jb     c0105b18 <get_pte+0x11d>
c0105af5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105af8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105afc:	c7 44 24 08 20 d0 10 	movl   $0xc010d020,0x8(%esp)
c0105b03:	c0 
c0105b04:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0105b0b:	00 
c0105b0c:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105b13:	e8 d3 b2 ff ff       	call   c0100deb <__panic>
c0105b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b1b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105b20:	89 c2                	mov    %eax,%edx
c0105b22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b25:	c1 e8 0c             	shr    $0xc,%eax
c0105b28:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105b2d:	c1 e0 02             	shl    $0x2,%eax
c0105b30:	01 d0                	add    %edx,%eax
c0105b32:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ptep;  // (8) return page table entry
c0105b35:	8b 45 d8             	mov    -0x28(%ebp),%eax
#endif
}
c0105b38:	89 ec                	mov    %ebp,%esp
c0105b3a:	5d                   	pop    %ebp
c0105b3b:	c3                   	ret    

c0105b3c <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0105b3c:	55                   	push   %ebp
c0105b3d:	89 e5                	mov    %esp,%ebp
c0105b3f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105b42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b49:	00 
c0105b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b54:	89 04 24             	mov    %eax,(%esp)
c0105b57:	e8 9f fe ff ff       	call   c01059fb <get_pte>
c0105b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0105b5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b63:	74 08                	je     c0105b6d <get_page+0x31>
        *ptep_store = ptep;
c0105b65:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b68:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b6b:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0105b6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b71:	74 1b                	je     c0105b8e <get_page+0x52>
c0105b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b76:	8b 00                	mov    (%eax),%eax
c0105b78:	83 e0 01             	and    $0x1,%eax
c0105b7b:	85 c0                	test   %eax,%eax
c0105b7d:	74 0f                	je     c0105b8e <get_page+0x52>
        return pte2page(*ptep);
c0105b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b82:	8b 00                	mov    (%eax),%eax
c0105b84:	89 04 24             	mov    %eax,(%esp)
c0105b87:	e8 4a f5 ff ff       	call   c01050d6 <pte2page>
c0105b8c:	eb 05                	jmp    c0105b93 <get_page+0x57>
    }
    return NULL;
c0105b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b93:	89 ec                	mov    %ebp,%esp
c0105b95:	5d                   	pop    %ebp
c0105b96:	c3                   	ret    

c0105b97 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105b97:	55                   	push   %ebp
c0105b98:	89 e5                	mov    %esp,%ebp
c0105b9a:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep & PTE_P)  //(1) check if this page table entry is present
c0105b9d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ba0:	8b 00                	mov    (%eax),%eax
c0105ba2:	83 e0 01             	and    $0x1,%eax
c0105ba5:	85 c0                	test   %eax,%eax
c0105ba7:	74 4d                	je     c0105bf6 <page_remove_pte+0x5f>
    {
        struct Page *page = pte2page(*ptep);  //(2) find corresponding page to pte
c0105ba9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bac:	8b 00                	mov    (%eax),%eax
c0105bae:	89 04 24             	mov    %eax,(%esp)
c0105bb1:	e8 20 f5 ff ff       	call   c01050d6 <pte2page>
c0105bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)

        if (page_ref_dec(page) == 0)  //(3) decrease page reference
c0105bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bbc:	89 04 24             	mov    %eax,(%esp)
c0105bbf:	e8 9b f5 ff ff       	call   c010515f <page_ref_dec>
c0105bc4:	85 c0                	test   %eax,%eax
c0105bc6:	75 13                	jne    c0105bdb <page_remove_pte+0x44>
        {                             //free_page means add this page to freeList in FIFO
            free_page(page);          //(4) and free this page when page reference reachs 0
c0105bc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105bcf:	00 
c0105bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bd3:	89 04 24             	mov    %eax,(%esp)
c0105bd6:	e8 d2 f7 ff ff       	call   c01053ad <free_pages>
        }
        *ptep = 0;                  //(5) clear second page table entry
c0105bdb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105bde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);  //(6) flush tlb
c0105be4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105be7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bee:	89 04 24             	mov    %eax,(%esp)
c0105bf1:	e8 d4 04 00 00       	call   c01060ca <tlb_invalidate>
    }
#endif
}
c0105bf6:	90                   	nop
c0105bf7:	89 ec                	mov    %ebp,%esp
c0105bf9:	5d                   	pop    %ebp
c0105bfa:	c3                   	ret    

c0105bfb <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105bfb:	55                   	push   %ebp
c0105bfc:	89 e5                	mov    %esp,%ebp
c0105bfe:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c04:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c09:	85 c0                	test   %eax,%eax
c0105c0b:	75 0c                	jne    c0105c19 <unmap_range+0x1e>
c0105c0d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c10:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c15:	85 c0                	test   %eax,%eax
c0105c17:	74 24                	je     c0105c3d <unmap_range+0x42>
c0105c19:	c7 44 24 0c 48 d1 10 	movl   $0xc010d148,0xc(%esp)
c0105c20:	c0 
c0105c21:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105c28:	c0 
c0105c29:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c0105c30:	00 
c0105c31:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105c38:	e8 ae b1 ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105c3d:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105c44:	76 11                	jbe    c0105c57 <unmap_range+0x5c>
c0105c46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c49:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c4c:	73 09                	jae    c0105c57 <unmap_range+0x5c>
c0105c4e:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105c55:	76 24                	jbe    c0105c7b <unmap_range+0x80>
c0105c57:	c7 44 24 0c 71 d1 10 	movl   $0xc010d171,0xc(%esp)
c0105c5e:	c0 
c0105c5f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105c66:	c0 
c0105c67:	c7 44 24 04 c0 01 00 	movl   $0x1c0,0x4(%esp)
c0105c6e:	00 
c0105c6f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105c76:	e8 70 b1 ff ff       	call   c0100deb <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105c7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c82:	00 
c0105c83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8d:	89 04 24             	mov    %eax,(%esp)
c0105c90:	e8 66 fd ff ff       	call   c01059fb <get_pte>
c0105c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105c98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105c9c:	75 18                	jne    c0105cb6 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ca1:	05 00 00 40 00       	add    $0x400000,%eax
c0105ca6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cac:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105cb1:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue;
c0105cb4:	eb 29                	jmp    c0105cdf <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cb9:	8b 00                	mov    (%eax),%eax
c0105cbb:	85 c0                	test   %eax,%eax
c0105cbd:	74 19                	je     c0105cd8 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cc2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd0:	89 04 24             	mov    %eax,(%esp)
c0105cd3:	e8 bf fe ff ff       	call   c0105b97 <page_remove_pte>
        }
        start += PGSIZE;
c0105cd8:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ce3:	74 08                	je     c0105ced <unmap_range+0xf2>
c0105ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ce8:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105ceb:	72 8e                	jb     c0105c7b <unmap_range+0x80>
}
c0105ced:	90                   	nop
c0105cee:	89 ec                	mov    %ebp,%esp
c0105cf0:	5d                   	pop    %ebp
c0105cf1:	c3                   	ret    

c0105cf2 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105cf2:	55                   	push   %ebp
c0105cf3:	89 e5                	mov    %esp,%ebp
c0105cf5:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cfb:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d00:	85 c0                	test   %eax,%eax
c0105d02:	75 0c                	jne    c0105d10 <exit_range+0x1e>
c0105d04:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d07:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105d0c:	85 c0                	test   %eax,%eax
c0105d0e:	74 24                	je     c0105d34 <exit_range+0x42>
c0105d10:	c7 44 24 0c 48 d1 10 	movl   $0xc010d148,0xc(%esp)
c0105d17:	c0 
c0105d18:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105d1f:	c0 
c0105d20:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0105d27:	00 
c0105d28:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105d2f:	e8 b7 b0 ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105d34:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105d3b:	76 11                	jbe    c0105d4e <exit_range+0x5c>
c0105d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d40:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105d43:	73 09                	jae    c0105d4e <exit_range+0x5c>
c0105d45:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105d4c:	76 24                	jbe    c0105d72 <exit_range+0x80>
c0105d4e:	c7 44 24 0c 71 d1 10 	movl   $0xc010d171,0xc(%esp)
c0105d55:	c0 
c0105d56:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105d5d:	c0 
c0105d5e:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
c0105d65:	00 
c0105d66:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105d6d:	e8 79 b0 ff ff       	call   c0100deb <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105d72:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d75:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d7b:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105d80:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {  //exit_range by page unit
        int pde_idx = PDX(start);
c0105d83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d86:	c1 e8 16             	shr    $0x16,%eax
c0105d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d99:	01 d0                	add    %edx,%eax
c0105d9b:	8b 00                	mov    (%eax),%eax
c0105d9d:	83 e0 01             	and    $0x1,%eax
c0105da0:	85 c0                	test   %eax,%eax
c0105da2:	74 3e                	je     c0105de2 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105dae:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db1:	01 d0                	add    %edx,%eax
c0105db3:	8b 00                	mov    (%eax),%eax
c0105db5:	89 04 24             	mov    %eax,(%esp)
c0105db8:	e8 59 f3 ff ff       	call   c0105116 <pde2page>
c0105dbd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105dc4:	00 
c0105dc5:	89 04 24             	mov    %eax,(%esp)
c0105dc8:	e8 e0 f5 ff ff       	call   c01053ad <free_pages>
            pgdir[pde_idx] = 0;
c0105dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dda:	01 d0                	add    %edx,%eax
c0105ddc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105de2:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105de9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ded:	74 08                	je     c0105df7 <exit_range+0x105>
c0105def:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105df2:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105df5:	72 8c                	jb     c0105d83 <exit_range+0x91>
}
c0105df7:	90                   	nop
c0105df8:	89 ec                	mov    %ebp,%esp
c0105dfa:	5d                   	pop    %ebp
c0105dfb:	c3                   	ret    

c0105dfc <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105dfc:	55                   	push   %ebp
c0105dfd:	89 e5                	mov    %esp,%ebp
c0105dff:	83 ec 38             	sub    $0x38,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105e02:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e05:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105e0a:	85 c0                	test   %eax,%eax
c0105e0c:	75 0c                	jne    c0105e1a <copy_range+0x1e>
c0105e0e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e11:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105e16:	85 c0                	test   %eax,%eax
c0105e18:	74 24                	je     c0105e3e <copy_range+0x42>
c0105e1a:	c7 44 24 0c 48 d1 10 	movl   $0xc010d148,0xc(%esp)
c0105e21:	c0 
c0105e22:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105e29:	c0 
c0105e2a:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0105e31:	00 
c0105e32:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105e39:	e8 ad af ff ff       	call   c0100deb <__panic>
    assert(USER_ACCESS(start, end));
c0105e3e:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105e45:	76 11                	jbe    c0105e58 <copy_range+0x5c>
c0105e47:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e4a:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105e4d:	73 09                	jae    c0105e58 <copy_range+0x5c>
c0105e4f:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105e56:	76 24                	jbe    c0105e7c <copy_range+0x80>
c0105e58:	c7 44 24 0c 71 d1 10 	movl   $0xc010d171,0xc(%esp)
c0105e5f:	c0 
c0105e60:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105e67:	c0 
c0105e68:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0105e6f:	00 
c0105e70:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105e77:	e8 6f af ff ff       	call   c0100deb <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105e7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e83:	00 
c0105e84:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e8e:	89 04 24             	mov    %eax,(%esp)
c0105e91:	e8 65 fb ff ff       	call   c01059fb <get_pte>
c0105e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e9d:	75 1b                	jne    c0105eba <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105e9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ea2:	05 00 00 40 00       	add    $0x400000,%eax
c0105ea7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105eaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ead:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105eb2:	89 45 10             	mov    %eax,0x10(%ebp)
            continue;
c0105eb5:	e9 f3 00 00 00       	jmp    c0105fad <copy_range+0x1b1>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ebd:	8b 00                	mov    (%eax),%eax
c0105ebf:	83 e0 01             	and    $0x1,%eax
c0105ec2:	85 c0                	test   %eax,%eax
c0105ec4:	0f 84 dc 00 00 00    	je     c0105fa6 <copy_range+0x1aa>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105eca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105ed1:	00 
c0105ed2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ed9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105edc:	89 04 24             	mov    %eax,(%esp)
c0105edf:	e8 17 fb ff ff       	call   c01059fb <get_pte>
c0105ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ee7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105eeb:	75 0a                	jne    c0105ef7 <copy_range+0xfb>
                return -E_NO_MEM;
c0105eed:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105ef2:	e9 cd 00 00 00       	jmp    c0105fc4 <copy_range+0x1c8>
            }
            uint32_t perm = (*ptep & PTE_USER);
c0105ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105efa:	8b 00                	mov    (%eax),%eax
c0105efc:	83 e0 07             	and    $0x7,%eax
c0105eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
            //get page from ptep
            struct Page *page = pte2page(*ptep);
c0105f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f05:	8b 00                	mov    (%eax),%eax
c0105f07:	89 04 24             	mov    %eax,(%esp)
c0105f0a:	e8 c7 f1 ff ff       	call   c01050d6 <pte2page>
c0105f0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // alloc a page for process B
            struct Page *npage = alloc_page();
c0105f12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105f19:	e8 22 f4 ff ff       	call   c0105340 <alloc_pages>
c0105f1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            assert(page != NULL);
c0105f21:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105f25:	75 24                	jne    c0105f4b <copy_range+0x14f>
c0105f27:	c7 44 24 0c 89 d1 10 	movl   $0xc010d189,0xc(%esp)
c0105f2e:	c0 
c0105f2f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105f36:	c0 
c0105f37:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105f3e:	00 
c0105f3f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105f46:	e8 a0 ae ff ff       	call   c0100deb <__panic>
            assert(npage != NULL);
c0105f4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105f4f:	75 24                	jne    c0105f75 <copy_range+0x179>
c0105f51:	c7 44 24 0c 96 d1 10 	movl   $0xc010d196,0xc(%esp)
c0105f58:	c0 
c0105f59:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105f60:	c0 
c0105f61:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0105f68:	00 
c0105f69:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105f70:	e8 76 ae ff ff       	call   c0100deb <__panic>
            int ret = 0;
c0105f75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
         * (1) find src_kvaddr: the kernel virtual address of page
         * (2) find dst_kvaddr: the kernel virtual address of npage
         * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
         * (4) build the map of phy addr of  nage with the linear addr start
         */
            assert(ret == 0);
c0105f7c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105f80:	74 24                	je     c0105fa6 <copy_range+0x1aa>
c0105f82:	c7 44 24 0c a4 d1 10 	movl   $0xc010d1a4,0xc(%esp)
c0105f89:	c0 
c0105f8a:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0105f91:	c0 
c0105f92:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0105f99:	00 
c0105f9a:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0105fa1:	e8 45 ae ff ff       	call   c0100deb <__panic>
        }
        start += PGSIZE;
c0105fa6:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105fad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105fb1:	74 0c                	je     c0105fbf <copy_range+0x1c3>
c0105fb3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fb6:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105fb9:	0f 82 bd fe ff ff    	jb     c0105e7c <copy_range+0x80>
    return 0;
c0105fbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105fc4:	89 ec                	mov    %ebp,%esp
c0105fc6:	5d                   	pop    %ebp
c0105fc7:	c3                   	ret    

c0105fc8 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105fc8:	55                   	push   %ebp
c0105fc9:	89 e5                	mov    %esp,%ebp
c0105fcb:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105fce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105fd5:	00 
c0105fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fdd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe0:	89 04 24             	mov    %eax,(%esp)
c0105fe3:	e8 13 fa ff ff       	call   c01059fb <get_pte>
c0105fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105feb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105fef:	74 19                	je     c010600a <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ff4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106002:	89 04 24             	mov    %eax,(%esp)
c0106005:	e8 8d fb ff ff       	call   c0105b97 <page_remove_pte>
    }
}
c010600a:	90                   	nop
c010600b:	89 ec                	mov    %ebp,%esp
c010600d:	5d                   	pop    %ebp
c010600e:	c3                   	ret    

c010600f <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010600f:	55                   	push   %ebp
c0106010:	89 e5                	mov    %esp,%ebp
c0106012:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106015:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010601c:	00 
c010601d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106020:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106024:	8b 45 08             	mov    0x8(%ebp),%eax
c0106027:	89 04 24             	mov    %eax,(%esp)
c010602a:	e8 cc f9 ff ff       	call   c01059fb <get_pte>
c010602f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106032:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106036:	75 0a                	jne    c0106042 <page_insert+0x33>
        return -E_NO_MEM;
c0106038:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010603d:	e9 84 00 00 00       	jmp    c01060c6 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106042:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106045:	89 04 24             	mov    %eax,(%esp)
c0106048:	e8 fb f0 ff ff       	call   c0105148 <page_ref_inc>
    if (*ptep & PTE_P) {
c010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106050:	8b 00                	mov    (%eax),%eax
c0106052:	83 e0 01             	and    $0x1,%eax
c0106055:	85 c0                	test   %eax,%eax
c0106057:	74 3e                	je     c0106097 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010605c:	8b 00                	mov    (%eax),%eax
c010605e:	89 04 24             	mov    %eax,(%esp)
c0106061:	e8 70 f0 ff ff       	call   c01050d6 <pte2page>
c0106066:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106069:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010606c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010606f:	75 0d                	jne    c010607e <page_insert+0x6f>
            page_ref_dec(page);  // used to modify the pages permission(?)
c0106071:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106074:	89 04 24             	mov    %eax,(%esp)
c0106077:	e8 e3 f0 ff ff       	call   c010515f <page_ref_dec>
c010607c:	eb 19                	jmp    c0106097 <page_insert+0x88>
        } else {
            page_remove_pte(pgdir, la, ptep);
c010607e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106081:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106085:	8b 45 10             	mov    0x10(%ebp),%eax
c0106088:	89 44 24 04          	mov    %eax,0x4(%esp)
c010608c:	8b 45 08             	mov    0x8(%ebp),%eax
c010608f:	89 04 24             	mov    %eax,(%esp)
c0106092:	e8 00 fb ff ff       	call   c0105b97 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106097:	8b 45 0c             	mov    0xc(%ebp),%eax
c010609a:	89 04 24             	mov    %eax,(%esp)
c010609d:	e8 7e ef ff ff       	call   c0105020 <page2pa>
c01060a2:	0b 45 14             	or     0x14(%ebp),%eax
c01060a5:	83 c8 01             	or     $0x1,%eax
c01060a8:	89 c2                	mov    %eax,%edx
c01060aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ad:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01060af:	8b 45 10             	mov    0x10(%ebp),%eax
c01060b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01060b9:	89 04 24             	mov    %eax,(%esp)
c01060bc:	e8 09 00 00 00       	call   c01060ca <tlb_invalidate>
    return 0;
c01060c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01060c6:	89 ec                	mov    %ebp,%esp
c01060c8:	5d                   	pop    %ebp
c01060c9:	c3                   	ret    

c01060ca <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01060ca:	55                   	push   %ebp
c01060cb:	89 e5                	mov    %esp,%ebp
c01060cd:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01060d0:	0f 20 d8             	mov    %cr3,%eax
c01060d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01060d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01060d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01060dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01060df:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01060e6:	77 23                	ja     c010610b <tlb_invalidate+0x41>
c01060e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060ef:	c7 44 24 08 c4 d0 10 	movl   $0xc010d0c4,0x8(%esp)
c01060f6:	c0 
c01060f7:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c01060fe:	00 
c01060ff:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106106:	e8 e0 ac ff ff       	call   c0100deb <__panic>
c010610b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010610e:	05 00 00 00 40       	add    $0x40000000,%eax
c0106113:	39 d0                	cmp    %edx,%eax
c0106115:	75 0d                	jne    c0106124 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0106117:	8b 45 0c             	mov    0xc(%ebp),%eax
c010611a:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010611d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106120:	0f 01 38             	invlpg (%eax)
}
c0106123:	90                   	nop
    }
}
c0106124:	90                   	nop
c0106125:	89 ec                	mov    %ebp,%esp
c0106127:	5d                   	pop    %ebp
c0106128:	c3                   	ret    

c0106129 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106129:	55                   	push   %ebp
c010612a:	89 e5                	mov    %esp,%ebp
c010612c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c010612f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106136:	e8 05 f2 ff ff       	call   c0105340 <alloc_pages>
c010613b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010613e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106142:	0f 84 b0 00 00 00    	je     c01061f8 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106148:	8b 45 10             	mov    0x10(%ebp),%eax
c010614b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010614f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106152:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106156:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106159:	89 44 24 04          	mov    %eax,0x4(%esp)
c010615d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106160:	89 04 24             	mov    %eax,(%esp)
c0106163:	e8 a7 fe ff ff       	call   c010600f <page_insert>
c0106168:	85 c0                	test   %eax,%eax
c010616a:	74 1a                	je     c0106186 <pgdir_alloc_page+0x5d>
            free_page(page);
c010616c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106173:	00 
c0106174:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106177:	89 04 24             	mov    %eax,(%esp)
c010617a:	e8 2e f2 ff ff       	call   c01053ad <free_pages>
            return NULL;
c010617f:	b8 00 00 00 00       	mov    $0x0,%eax
c0106184:	eb 75                	jmp    c01061fb <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok) {
c0106186:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c010618b:	85 c0                	test   %eax,%eax
c010618d:	74 69                	je     c01061f8 <pgdir_alloc_page+0xcf>
            if (check_mm_struct != NULL) {//这个really has been modified? only add this condition judgement
c010618f:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0106194:	85 c0                	test   %eax,%eax
c0106196:	74 60                	je     c01061f8 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0106198:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c010619d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01061a4:	00 
c01061a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01061ac:	8b 55 0c             	mov    0xc(%ebp),%edx
c01061af:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061b3:	89 04 24             	mov    %eax,(%esp)
c01061b6:	e8 54 0e 00 00       	call   c010700f <swap_map_swappable>
                page->pra_vaddr = la;
c01061bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01061c1:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c01061c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061c7:	89 04 24             	mov    %eax,(%esp)
c01061ca:	e8 61 ef ff ff       	call   c0105130 <page_ref>
c01061cf:	83 f8 01             	cmp    $0x1,%eax
c01061d2:	74 24                	je     c01061f8 <pgdir_alloc_page+0xcf>
c01061d4:	c7 44 24 0c ad d1 10 	movl   $0xc010d1ad,0xc(%esp)
c01061db:	c0 
c01061dc:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01061e3:	c0 
c01061e4:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
c01061eb:	00 
c01061ec:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01061f3:	e8 f3 ab ff ff       	call   c0100deb <__panic>
                //panic("pgdir_alloc_page: no pages. now current is existed, should fix it in the future\n");
            }
        }
    }

    return page;
c01061f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061fb:	89 ec                	mov    %ebp,%esp
c01061fd:	5d                   	pop    %ebp
c01061fe:	c3                   	ret    

c01061ff <check_alloc_page>:

static void
check_alloc_page(void) {
c01061ff:	55                   	push   %ebp
c0106200:	89 e5                	mov    %esp,%ebp
c0106202:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106205:	a1 ac 3f 1a c0       	mov    0xc01a3fac,%eax
c010620a:	8b 40 18             	mov    0x18(%eax),%eax
c010620d:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010620f:	c7 04 24 c4 d1 10 c0 	movl   $0xc010d1c4,(%esp)
c0106216:	e8 52 a1 ff ff       	call   c010036d <cprintf>
}
c010621b:	90                   	nop
c010621c:	89 ec                	mov    %ebp,%esp
c010621e:	5d                   	pop    %ebp
c010621f:	c3                   	ret    

c0106220 <check_pgdir>:

static void
check_pgdir(void) {
c0106220:	55                   	push   %ebp
c0106221:	89 e5                	mov    %esp,%ebp
c0106223:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106226:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010622b:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106230:	76 24                	jbe    c0106256 <check_pgdir+0x36>
c0106232:	c7 44 24 0c e3 d1 10 	movl   $0xc010d1e3,0xc(%esp)
c0106239:	c0 
c010623a:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106241:	c0 
c0106242:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
c0106249:	00 
c010624a:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106251:	e8 95 ab ff ff       	call   c0100deb <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106256:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010625b:	85 c0                	test   %eax,%eax
c010625d:	74 0e                	je     c010626d <check_pgdir+0x4d>
c010625f:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106264:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106269:	85 c0                	test   %eax,%eax
c010626b:	74 24                	je     c0106291 <check_pgdir+0x71>
c010626d:	c7 44 24 0c 00 d2 10 	movl   $0xc010d200,0xc(%esp)
c0106274:	c0 
c0106275:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010627c:	c0 
c010627d:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0106284:	00 
c0106285:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010628c:	e8 5a ab ff ff       	call   c0100deb <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106291:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106296:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010629d:	00 
c010629e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01062a5:	00 
c01062a6:	89 04 24             	mov    %eax,(%esp)
c01062a9:	e8 8e f8 ff ff       	call   c0105b3c <get_page>
c01062ae:	85 c0                	test   %eax,%eax
c01062b0:	74 24                	je     c01062d6 <check_pgdir+0xb6>
c01062b2:	c7 44 24 0c 38 d2 10 	movl   $0xc010d238,0xc(%esp)
c01062b9:	c0 
c01062ba:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01062c1:	c0 
c01062c2:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
c01062c9:	00 
c01062ca:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01062d1:	e8 15 ab ff ff       	call   c0100deb <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01062d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01062dd:	e8 5e f0 ff ff       	call   c0105340 <alloc_pages>
c01062e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01062e5:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01062ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01062f1:	00 
c01062f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01062f9:	00 
c01062fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106301:	89 04 24             	mov    %eax,(%esp)
c0106304:	e8 06 fd ff ff       	call   c010600f <page_insert>
c0106309:	85 c0                	test   %eax,%eax
c010630b:	74 24                	je     c0106331 <check_pgdir+0x111>
c010630d:	c7 44 24 0c 60 d2 10 	movl   $0xc010d260,0xc(%esp)
c0106314:	c0 
c0106315:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010631c:	c0 
c010631d:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0106324:	00 
c0106325:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010632c:	e8 ba aa ff ff       	call   c0100deb <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106331:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106336:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010633d:	00 
c010633e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106345:	00 
c0106346:	89 04 24             	mov    %eax,(%esp)
c0106349:	e8 ad f6 ff ff       	call   c01059fb <get_pte>
c010634e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106351:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106355:	75 24                	jne    c010637b <check_pgdir+0x15b>
c0106357:	c7 44 24 0c 8c d2 10 	movl   $0xc010d28c,0xc(%esp)
c010635e:	c0 
c010635f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106366:	c0 
c0106367:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c010636e:	00 
c010636f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106376:	e8 70 aa ff ff       	call   c0100deb <__panic>
    assert(pte2page(*ptep) == p1);
c010637b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010637e:	8b 00                	mov    (%eax),%eax
c0106380:	89 04 24             	mov    %eax,(%esp)
c0106383:	e8 4e ed ff ff       	call   c01050d6 <pte2page>
c0106388:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010638b:	74 24                	je     c01063b1 <check_pgdir+0x191>
c010638d:	c7 44 24 0c b9 d2 10 	movl   $0xc010d2b9,0xc(%esp)
c0106394:	c0 
c0106395:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010639c:	c0 
c010639d:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c01063a4:	00 
c01063a5:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01063ac:	e8 3a aa ff ff       	call   c0100deb <__panic>
    assert(page_ref(p1) == 1);
c01063b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063b4:	89 04 24             	mov    %eax,(%esp)
c01063b7:	e8 74 ed ff ff       	call   c0105130 <page_ref>
c01063bc:	83 f8 01             	cmp    $0x1,%eax
c01063bf:	74 24                	je     c01063e5 <check_pgdir+0x1c5>
c01063c1:	c7 44 24 0c cf d2 10 	movl   $0xc010d2cf,0xc(%esp)
c01063c8:	c0 
c01063c9:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01063d0:	c0 
c01063d1:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c01063d8:	00 
c01063d9:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01063e0:	e8 06 aa ff ff       	call   c0100deb <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01063e5:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01063ea:	8b 00                	mov    (%eax),%eax
c01063ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01063f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01063f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063f7:	c1 e8 0c             	shr    $0xc,%eax
c01063fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01063fd:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0106402:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106405:	72 23                	jb     c010642a <check_pgdir+0x20a>
c0106407:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010640a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010640e:	c7 44 24 08 20 d0 10 	movl   $0xc010d020,0x8(%esp)
c0106415:	c0 
c0106416:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
c010641d:	00 
c010641e:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106425:	e8 c1 a9 ff ff       	call   c0100deb <__panic>
c010642a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010642d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106432:	83 c0 04             	add    $0x4,%eax
c0106435:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106438:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010643d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106444:	00 
c0106445:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010644c:	00 
c010644d:	89 04 24             	mov    %eax,(%esp)
c0106450:	e8 a6 f5 ff ff       	call   c01059fb <get_pte>
c0106455:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0106458:	74 24                	je     c010647e <check_pgdir+0x25e>
c010645a:	c7 44 24 0c e4 d2 10 	movl   $0xc010d2e4,0xc(%esp)
c0106461:	c0 
c0106462:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106469:	c0 
c010646a:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
c0106471:	00 
c0106472:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106479:	e8 6d a9 ff ff       	call   c0100deb <__panic>

    p2 = alloc_page();
c010647e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106485:	e8 b6 ee ff ff       	call   c0105340 <alloc_pages>
c010648a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010648d:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106492:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0106499:	00 
c010649a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01064a1:	00 
c01064a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064a5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064a9:	89 04 24             	mov    %eax,(%esp)
c01064ac:	e8 5e fb ff ff       	call   c010600f <page_insert>
c01064b1:	85 c0                	test   %eax,%eax
c01064b3:	74 24                	je     c01064d9 <check_pgdir+0x2b9>
c01064b5:	c7 44 24 0c 0c d3 10 	movl   $0xc010d30c,0xc(%esp)
c01064bc:	c0 
c01064bd:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01064c4:	c0 
c01064c5:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c01064cc:	00 
c01064cd:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01064d4:	e8 12 a9 ff ff       	call   c0100deb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01064d9:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01064de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01064e5:	00 
c01064e6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01064ed:	00 
c01064ee:	89 04 24             	mov    %eax,(%esp)
c01064f1:	e8 05 f5 ff ff       	call   c01059fb <get_pte>
c01064f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01064f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01064fd:	75 24                	jne    c0106523 <check_pgdir+0x303>
c01064ff:	c7 44 24 0c 44 d3 10 	movl   $0xc010d344,0xc(%esp)
c0106506:	c0 
c0106507:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010650e:	c0 
c010650f:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c0106516:	00 
c0106517:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010651e:	e8 c8 a8 ff ff       	call   c0100deb <__panic>
    assert(*ptep & PTE_U);
c0106523:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106526:	8b 00                	mov    (%eax),%eax
c0106528:	83 e0 04             	and    $0x4,%eax
c010652b:	85 c0                	test   %eax,%eax
c010652d:	75 24                	jne    c0106553 <check_pgdir+0x333>
c010652f:	c7 44 24 0c 74 d3 10 	movl   $0xc010d374,0xc(%esp)
c0106536:	c0 
c0106537:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010653e:	c0 
c010653f:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
c0106546:	00 
c0106547:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010654e:	e8 98 a8 ff ff       	call   c0100deb <__panic>
    assert(*ptep & PTE_W);
c0106553:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106556:	8b 00                	mov    (%eax),%eax
c0106558:	83 e0 02             	and    $0x2,%eax
c010655b:	85 c0                	test   %eax,%eax
c010655d:	75 24                	jne    c0106583 <check_pgdir+0x363>
c010655f:	c7 44 24 0c 82 d3 10 	movl   $0xc010d382,0xc(%esp)
c0106566:	c0 
c0106567:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010656e:	c0 
c010656f:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
c0106576:	00 
c0106577:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010657e:	e8 68 a8 ff ff       	call   c0100deb <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0106583:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106588:	8b 00                	mov    (%eax),%eax
c010658a:	83 e0 04             	and    $0x4,%eax
c010658d:	85 c0                	test   %eax,%eax
c010658f:	75 24                	jne    c01065b5 <check_pgdir+0x395>
c0106591:	c7 44 24 0c 90 d3 10 	movl   $0xc010d390,0xc(%esp)
c0106598:	c0 
c0106599:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01065a0:	c0 
c01065a1:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
c01065a8:	00 
c01065a9:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01065b0:	e8 36 a8 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 1);
c01065b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01065b8:	89 04 24             	mov    %eax,(%esp)
c01065bb:	e8 70 eb ff ff       	call   c0105130 <page_ref>
c01065c0:	83 f8 01             	cmp    $0x1,%eax
c01065c3:	74 24                	je     c01065e9 <check_pgdir+0x3c9>
c01065c5:	c7 44 24 0c a6 d3 10 	movl   $0xc010d3a6,0xc(%esp)
c01065cc:	c0 
c01065cd:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01065d4:	c0 
c01065d5:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
c01065dc:	00 
c01065dd:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01065e4:	e8 02 a8 ff ff       	call   c0100deb <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01065e9:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01065ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01065f5:	00 
c01065f6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01065fd:	00 
c01065fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106601:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106605:	89 04 24             	mov    %eax,(%esp)
c0106608:	e8 02 fa ff ff       	call   c010600f <page_insert>
c010660d:	85 c0                	test   %eax,%eax
c010660f:	74 24                	je     c0106635 <check_pgdir+0x415>
c0106611:	c7 44 24 0c b8 d3 10 	movl   $0xc010d3b8,0xc(%esp)
c0106618:	c0 
c0106619:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106620:	c0 
c0106621:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
c0106628:	00 
c0106629:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106630:	e8 b6 a7 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p1) == 2);
c0106635:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106638:	89 04 24             	mov    %eax,(%esp)
c010663b:	e8 f0 ea ff ff       	call   c0105130 <page_ref>
c0106640:	83 f8 02             	cmp    $0x2,%eax
c0106643:	74 24                	je     c0106669 <check_pgdir+0x449>
c0106645:	c7 44 24 0c e4 d3 10 	movl   $0xc010d3e4,0xc(%esp)
c010664c:	c0 
c010664d:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106654:	c0 
c0106655:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
c010665c:	00 
c010665d:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106664:	e8 82 a7 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c0106669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010666c:	89 04 24             	mov    %eax,(%esp)
c010666f:	e8 bc ea ff ff       	call   c0105130 <page_ref>
c0106674:	85 c0                	test   %eax,%eax
c0106676:	74 24                	je     c010669c <check_pgdir+0x47c>
c0106678:	c7 44 24 0c f6 d3 10 	movl   $0xc010d3f6,0xc(%esp)
c010667f:	c0 
c0106680:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106687:	c0 
c0106688:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
c010668f:	00 
c0106690:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106697:	e8 4f a7 ff ff       	call   c0100deb <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010669c:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01066a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01066a8:	00 
c01066a9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01066b0:	00 
c01066b1:	89 04 24             	mov    %eax,(%esp)
c01066b4:	e8 42 f3 ff ff       	call   c01059fb <get_pte>
c01066b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01066c0:	75 24                	jne    c01066e6 <check_pgdir+0x4c6>
c01066c2:	c7 44 24 0c 44 d3 10 	movl   $0xc010d344,0xc(%esp)
c01066c9:	c0 
c01066ca:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01066d1:	c0 
c01066d2:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
c01066d9:	00 
c01066da:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01066e1:	e8 05 a7 ff ff       	call   c0100deb <__panic>
    assert(pte2page(*ptep) == p1);
c01066e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066e9:	8b 00                	mov    (%eax),%eax
c01066eb:	89 04 24             	mov    %eax,(%esp)
c01066ee:	e8 e3 e9 ff ff       	call   c01050d6 <pte2page>
c01066f3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01066f6:	74 24                	je     c010671c <check_pgdir+0x4fc>
c01066f8:	c7 44 24 0c b9 d2 10 	movl   $0xc010d2b9,0xc(%esp)
c01066ff:	c0 
c0106700:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106707:	c0 
c0106708:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c010670f:	00 
c0106710:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106717:	e8 cf a6 ff ff       	call   c0100deb <__panic>
    assert((*ptep & PTE_U) == 0);
c010671c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010671f:	8b 00                	mov    (%eax),%eax
c0106721:	83 e0 04             	and    $0x4,%eax
c0106724:	85 c0                	test   %eax,%eax
c0106726:	74 24                	je     c010674c <check_pgdir+0x52c>
c0106728:	c7 44 24 0c 08 d4 10 	movl   $0xc010d408,0xc(%esp)
c010672f:	c0 
c0106730:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106737:	c0 
c0106738:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
c010673f:	00 
c0106740:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106747:	e8 9f a6 ff ff       	call   c0100deb <__panic>

    page_remove(boot_pgdir, 0x0);
c010674c:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106751:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106758:	00 
c0106759:	89 04 24             	mov    %eax,(%esp)
c010675c:	e8 67 f8 ff ff       	call   c0105fc8 <page_remove>
    assert(page_ref(p1) == 1);
c0106761:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106764:	89 04 24             	mov    %eax,(%esp)
c0106767:	e8 c4 e9 ff ff       	call   c0105130 <page_ref>
c010676c:	83 f8 01             	cmp    $0x1,%eax
c010676f:	74 24                	je     c0106795 <check_pgdir+0x575>
c0106771:	c7 44 24 0c cf d2 10 	movl   $0xc010d2cf,0xc(%esp)
c0106778:	c0 
c0106779:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106780:	c0 
c0106781:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c0106788:	00 
c0106789:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106790:	e8 56 a6 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c0106795:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106798:	89 04 24             	mov    %eax,(%esp)
c010679b:	e8 90 e9 ff ff       	call   c0105130 <page_ref>
c01067a0:	85 c0                	test   %eax,%eax
c01067a2:	74 24                	je     c01067c8 <check_pgdir+0x5a8>
c01067a4:	c7 44 24 0c f6 d3 10 	movl   $0xc010d3f6,0xc(%esp)
c01067ab:	c0 
c01067ac:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01067b3:	c0 
c01067b4:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c01067bb:	00 
c01067bc:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01067c3:	e8 23 a6 ff ff       	call   c0100deb <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01067c8:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01067cd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01067d4:	00 
c01067d5:	89 04 24             	mov    %eax,(%esp)
c01067d8:	e8 eb f7 ff ff       	call   c0105fc8 <page_remove>
    assert(page_ref(p1) == 0);
c01067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067e0:	89 04 24             	mov    %eax,(%esp)
c01067e3:	e8 48 e9 ff ff       	call   c0105130 <page_ref>
c01067e8:	85 c0                	test   %eax,%eax
c01067ea:	74 24                	je     c0106810 <check_pgdir+0x5f0>
c01067ec:	c7 44 24 0c 1d d4 10 	movl   $0xc010d41d,0xc(%esp)
c01067f3:	c0 
c01067f4:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c01067fb:	c0 
c01067fc:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
c0106803:	00 
c0106804:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010680b:	e8 db a5 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p2) == 0);
c0106810:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106813:	89 04 24             	mov    %eax,(%esp)
c0106816:	e8 15 e9 ff ff       	call   c0105130 <page_ref>
c010681b:	85 c0                	test   %eax,%eax
c010681d:	74 24                	je     c0106843 <check_pgdir+0x623>
c010681f:	c7 44 24 0c f6 d3 10 	movl   $0xc010d3f6,0xc(%esp)
c0106826:	c0 
c0106827:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010682e:	c0 
c010682f:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
c0106836:	00 
c0106837:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010683e:	e8 a8 a5 ff ff       	call   c0100deb <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0106843:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106848:	8b 00                	mov    (%eax),%eax
c010684a:	89 04 24             	mov    %eax,(%esp)
c010684d:	e8 c4 e8 ff ff       	call   c0105116 <pde2page>
c0106852:	89 04 24             	mov    %eax,(%esp)
c0106855:	e8 d6 e8 ff ff       	call   c0105130 <page_ref>
c010685a:	83 f8 01             	cmp    $0x1,%eax
c010685d:	74 24                	je     c0106883 <check_pgdir+0x663>
c010685f:	c7 44 24 0c 30 d4 10 	movl   $0xc010d430,0xc(%esp)
c0106866:	c0 
c0106867:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010686e:	c0 
c010686f:	c7 44 24 04 8d 02 00 	movl   $0x28d,0x4(%esp)
c0106876:	00 
c0106877:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010687e:	e8 68 a5 ff ff       	call   c0100deb <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0106883:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106888:	8b 00                	mov    (%eax),%eax
c010688a:	89 04 24             	mov    %eax,(%esp)
c010688d:	e8 84 e8 ff ff       	call   c0105116 <pde2page>
c0106892:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106899:	00 
c010689a:	89 04 24             	mov    %eax,(%esp)
c010689d:	e8 0b eb ff ff       	call   c01053ad <free_pages>
    boot_pgdir[0] = 0;
c01068a2:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01068a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01068ad:	c7 04 24 57 d4 10 c0 	movl   $0xc010d457,(%esp)
c01068b4:	e8 b4 9a ff ff       	call   c010036d <cprintf>
}
c01068b9:	90                   	nop
c01068ba:	89 ec                	mov    %ebp,%esp
c01068bc:	5d                   	pop    %ebp
c01068bd:	c3                   	ret    

c01068be <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01068be:	55                   	push   %ebp
c01068bf:	89 e5                	mov    %esp,%ebp
c01068c1:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01068c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01068cb:	e9 ca 00 00 00       	jmp    c010699a <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01068d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01068d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068d9:	c1 e8 0c             	shr    $0xc,%eax
c01068dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01068df:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01068e4:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01068e7:	72 23                	jb     c010690c <check_boot_pgdir+0x4e>
c01068e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01068f0:	c7 44 24 08 20 d0 10 	movl   $0xc010d020,0x8(%esp)
c01068f7:	c0 
c01068f8:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
c01068ff:	00 
c0106900:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106907:	e8 df a4 ff ff       	call   c0100deb <__panic>
c010690c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010690f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106914:	89 c2                	mov    %eax,%edx
c0106916:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c010691b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106922:	00 
c0106923:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106927:	89 04 24             	mov    %eax,(%esp)
c010692a:	e8 cc f0 ff ff       	call   c01059fb <get_pte>
c010692f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106932:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106936:	75 24                	jne    c010695c <check_boot_pgdir+0x9e>
c0106938:	c7 44 24 0c 74 d4 10 	movl   $0xc010d474,0xc(%esp)
c010693f:	c0 
c0106940:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106947:	c0 
c0106948:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
c010694f:	00 
c0106950:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106957:	e8 8f a4 ff ff       	call   c0100deb <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010695c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010695f:	8b 00                	mov    (%eax),%eax
c0106961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106966:	89 c2                	mov    %eax,%edx
c0106968:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010696b:	39 c2                	cmp    %eax,%edx
c010696d:	74 24                	je     c0106993 <check_boot_pgdir+0xd5>
c010696f:	c7 44 24 0c b1 d4 10 	movl   $0xc010d4b1,0xc(%esp)
c0106976:	c0 
c0106977:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c010697e:	c0 
c010697f:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
c0106986:	00 
c0106987:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c010698e:	e8 58 a4 ff ff       	call   c0100deb <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0106993:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010699a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010699d:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01069a2:	39 c2                	cmp    %eax,%edx
c01069a4:	0f 82 26 ff ff ff    	jb     c01068d0 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01069aa:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01069af:	05 ac 0f 00 00       	add    $0xfac,%eax
c01069b4:	8b 00                	mov    (%eax),%eax
c01069b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01069bb:	89 c2                	mov    %eax,%edx
c01069bd:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c01069c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069c5:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01069cc:	77 23                	ja     c01069f1 <check_boot_pgdir+0x133>
c01069ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01069d5:	c7 44 24 08 c4 d0 10 	movl   $0xc010d0c4,0x8(%esp)
c01069dc:	c0 
c01069dd:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c01069e4:	00 
c01069e5:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c01069ec:	e8 fa a3 ff ff       	call   c0100deb <__panic>
c01069f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069f4:	05 00 00 00 40       	add    $0x40000000,%eax
c01069f9:	39 d0                	cmp    %edx,%eax
c01069fb:	74 24                	je     c0106a21 <check_boot_pgdir+0x163>
c01069fd:	c7 44 24 0c c8 d4 10 	movl   $0xc010d4c8,0xc(%esp)
c0106a04:	c0 
c0106a05:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106a0c:	c0 
c0106a0d:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c0106a14:	00 
c0106a15:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106a1c:	e8 ca a3 ff ff       	call   c0100deb <__panic>

    assert(boot_pgdir[0] == 0);
c0106a21:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106a26:	8b 00                	mov    (%eax),%eax
c0106a28:	85 c0                	test   %eax,%eax
c0106a2a:	74 24                	je     c0106a50 <check_boot_pgdir+0x192>
c0106a2c:	c7 44 24 0c fc d4 10 	movl   $0xc010d4fc,0xc(%esp)
c0106a33:	c0 
c0106a34:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106a3b:	c0 
c0106a3c:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c0106a43:	00 
c0106a44:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106a4b:	e8 9b a3 ff ff       	call   c0100deb <__panic>

    struct Page *p;
    p = alloc_page();
c0106a50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a57:	e8 e4 e8 ff ff       	call   c0105340 <alloc_pages>
c0106a5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106a5f:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106a64:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106a6b:	00 
c0106a6c:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0106a73:	00 
c0106a74:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a77:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a7b:	89 04 24             	mov    %eax,(%esp)
c0106a7e:	e8 8c f5 ff ff       	call   c010600f <page_insert>
c0106a83:	85 c0                	test   %eax,%eax
c0106a85:	74 24                	je     c0106aab <check_boot_pgdir+0x1ed>
c0106a87:	c7 44 24 0c 10 d5 10 	movl   $0xc010d510,0xc(%esp)
c0106a8e:	c0 
c0106a8f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106a96:	c0 
c0106a97:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c0106a9e:	00 
c0106a9f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106aa6:	e8 40 a3 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p) == 1);
c0106aab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106aae:	89 04 24             	mov    %eax,(%esp)
c0106ab1:	e8 7a e6 ff ff       	call   c0105130 <page_ref>
c0106ab6:	83 f8 01             	cmp    $0x1,%eax
c0106ab9:	74 24                	je     c0106adf <check_boot_pgdir+0x221>
c0106abb:	c7 44 24 0c 3e d5 10 	movl   $0xc010d53e,0xc(%esp)
c0106ac2:	c0 
c0106ac3:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106aca:	c0 
c0106acb:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
c0106ad2:	00 
c0106ad3:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106ada:	e8 0c a3 ff ff       	call   c0100deb <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106adf:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106ae4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106aeb:	00 
c0106aec:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0106af3:	00 
c0106af4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106af7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106afb:	89 04 24             	mov    %eax,(%esp)
c0106afe:	e8 0c f5 ff ff       	call   c010600f <page_insert>
c0106b03:	85 c0                	test   %eax,%eax
c0106b05:	74 24                	je     c0106b2b <check_boot_pgdir+0x26d>
c0106b07:	c7 44 24 0c 50 d5 10 	movl   $0xc010d550,0xc(%esp)
c0106b0e:	c0 
c0106b0f:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106b16:	c0 
c0106b17:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c0106b1e:	00 
c0106b1f:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106b26:	e8 c0 a2 ff ff       	call   c0100deb <__panic>
    assert(page_ref(p) == 2);
c0106b2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b2e:	89 04 24             	mov    %eax,(%esp)
c0106b31:	e8 fa e5 ff ff       	call   c0105130 <page_ref>
c0106b36:	83 f8 02             	cmp    $0x2,%eax
c0106b39:	74 24                	je     c0106b5f <check_boot_pgdir+0x2a1>
c0106b3b:	c7 44 24 0c 87 d5 10 	movl   $0xc010d587,0xc(%esp)
c0106b42:	c0 
c0106b43:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106b4a:	c0 
c0106b4b:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106b52:	00 
c0106b53:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106b5a:	e8 8c a2 ff ff       	call   c0100deb <__panic>

    const char *str = "ucore: Hello world!!";
c0106b5f:	c7 45 e8 98 d5 10 c0 	movl   $0xc010d598,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0106b66:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106b69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b6d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b74:	e8 95 51 00 00       	call   c010bd0e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106b79:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106b80:	00 
c0106b81:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106b88:	e8 f9 51 00 00       	call   c010bd86 <strcmp>
c0106b8d:	85 c0                	test   %eax,%eax
c0106b8f:	74 24                	je     c0106bb5 <check_boot_pgdir+0x2f7>
c0106b91:	c7 44 24 0c b0 d5 10 	movl   $0xc010d5b0,0xc(%esp)
c0106b98:	c0 
c0106b99:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106ba0:	c0 
c0106ba1:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
c0106ba8:	00 
c0106ba9:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106bb0:	e8 36 a2 ff ff       	call   c0100deb <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106bb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bb8:	89 04 24             	mov    %eax,(%esp)
c0106bbb:	e8 c0 e4 ff ff       	call   c0105080 <page2kva>
c0106bc0:	05 00 01 00 00       	add    $0x100,%eax
c0106bc5:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106bc8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106bcf:	e8 e0 50 00 00       	call   c010bcb4 <strlen>
c0106bd4:	85 c0                	test   %eax,%eax
c0106bd6:	74 24                	je     c0106bfc <check_boot_pgdir+0x33e>
c0106bd8:	c7 44 24 0c e8 d5 10 	movl   $0xc010d5e8,0xc(%esp)
c0106bdf:	c0 
c0106be0:	c7 44 24 08 0d d1 10 	movl   $0xc010d10d,0x8(%esp)
c0106be7:	c0 
c0106be8:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c0106bef:	00 
c0106bf0:	c7 04 24 e8 d0 10 c0 	movl   $0xc010d0e8,(%esp)
c0106bf7:	e8 ef a1 ff ff       	call   c0100deb <__panic>

    free_page(p);
c0106bfc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c03:	00 
c0106c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c07:	89 04 24             	mov    %eax,(%esp)
c0106c0a:	e8 9e e7 ff ff       	call   c01053ad <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106c0f:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106c14:	8b 00                	mov    (%eax),%eax
c0106c16:	89 04 24             	mov    %eax,(%esp)
c0106c19:	e8 f8 e4 ff ff       	call   c0105116 <pde2page>
c0106c1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c25:	00 
c0106c26:	89 04 24             	mov    %eax,(%esp)
c0106c29:	e8 7f e7 ff ff       	call   c01053ad <free_pages>
    boot_pgdir[0] = 0;
c0106c2e:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0106c33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106c39:	c7 04 24 0c d6 10 c0 	movl   $0xc010d60c,(%esp)
c0106c40:	e8 28 97 ff ff       	call   c010036d <cprintf>
}
c0106c45:	90                   	nop
c0106c46:	89 ec                	mov    %ebp,%esp
c0106c48:	5d                   	pop    %ebp
c0106c49:	c3                   	ret    

c0106c4a <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106c4a:	55                   	push   %ebp
c0106c4b:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106c4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c50:	83 e0 04             	and    $0x4,%eax
c0106c53:	85 c0                	test   %eax,%eax
c0106c55:	74 04                	je     c0106c5b <perm2str+0x11>
c0106c57:	b0 75                	mov    $0x75,%al
c0106c59:	eb 02                	jmp    c0106c5d <perm2str+0x13>
c0106c5b:	b0 2d                	mov    $0x2d,%al
c0106c5d:	a2 28 40 1a c0       	mov    %al,0xc01a4028
    str[1] = 'r';
c0106c62:	c6 05 29 40 1a c0 72 	movb   $0x72,0xc01a4029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106c69:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c6c:	83 e0 02             	and    $0x2,%eax
c0106c6f:	85 c0                	test   %eax,%eax
c0106c71:	74 04                	je     c0106c77 <perm2str+0x2d>
c0106c73:	b0 77                	mov    $0x77,%al
c0106c75:	eb 02                	jmp    c0106c79 <perm2str+0x2f>
c0106c77:	b0 2d                	mov    $0x2d,%al
c0106c79:	a2 2a 40 1a c0       	mov    %al,0xc01a402a
    str[3] = '\0';
c0106c7e:	c6 05 2b 40 1a c0 00 	movb   $0x0,0xc01a402b
    return str;
c0106c85:	b8 28 40 1a c0       	mov    $0xc01a4028,%eax
}
c0106c8a:	5d                   	pop    %ebp
c0106c8b:	c3                   	ret    

c0106c8c <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106c8c:	55                   	push   %ebp
c0106c8d:	89 e5                	mov    %esp,%ebp
c0106c8f:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106c92:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c95:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c98:	72 0d                	jb     c0106ca7 <get_pgtable_items+0x1b>
        return 0;
c0106c9a:	b8 00 00 00 00       	mov    $0x0,%eax
c0106c9f:	e9 98 00 00 00       	jmp    c0106d3c <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start++;
c0106ca4:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0106ca7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106caa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106cad:	73 18                	jae    c0106cc7 <get_pgtable_items+0x3b>
c0106caf:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106cb9:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cbc:	01 d0                	add    %edx,%eax
c0106cbe:	8b 00                	mov    (%eax),%eax
c0106cc0:	83 e0 01             	and    $0x1,%eax
c0106cc3:	85 c0                	test   %eax,%eax
c0106cc5:	74 dd                	je     c0106ca4 <get_pgtable_items+0x18>
    }
    if (start < right) {
c0106cc7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cca:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ccd:	73 68                	jae    c0106d37 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0106ccf:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106cd3:	74 08                	je     c0106cdd <get_pgtable_items+0x51>
            *left_store = start;
c0106cd5:	8b 45 18             	mov    0x18(%ebp),%eax
c0106cd8:	8b 55 10             	mov    0x10(%ebp),%edx
c0106cdb:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start++] & PTE_USER);
c0106cdd:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ce0:	8d 50 01             	lea    0x1(%eax),%edx
c0106ce3:	89 55 10             	mov    %edx,0x10(%ebp)
c0106ce6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106ced:	8b 45 14             	mov    0x14(%ebp),%eax
c0106cf0:	01 d0                	add    %edx,%eax
c0106cf2:	8b 00                	mov    (%eax),%eax
c0106cf4:	83 e0 07             	and    $0x7,%eax
c0106cf7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106cfa:	eb 03                	jmp    c0106cff <get_pgtable_items+0x73>
            start++;
c0106cfc:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106cff:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d02:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106d05:	73 1d                	jae    c0106d24 <get_pgtable_items+0x98>
c0106d07:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d0a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106d11:	8b 45 14             	mov    0x14(%ebp),%eax
c0106d14:	01 d0                	add    %edx,%eax
c0106d16:	8b 00                	mov    (%eax),%eax
c0106d18:	83 e0 07             	and    $0x7,%eax
c0106d1b:	89 c2                	mov    %eax,%edx
c0106d1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d20:	39 c2                	cmp    %eax,%edx
c0106d22:	74 d8                	je     c0106cfc <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0106d24:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106d28:	74 08                	je     c0106d32 <get_pgtable_items+0xa6>
            *right_store = start;
c0106d2a:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106d2d:	8b 55 10             	mov    0x10(%ebp),%edx
c0106d30:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106d32:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d35:	eb 05                	jmp    c0106d3c <get_pgtable_items+0xb0>
    }
    return 0;
c0106d37:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106d3c:	89 ec                	mov    %ebp,%esp
c0106d3e:	5d                   	pop    %ebp
c0106d3f:	c3                   	ret    

c0106d40 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106d40:	55                   	push   %ebp
c0106d41:	89 e5                	mov    %esp,%ebp
c0106d43:	57                   	push   %edi
c0106d44:	56                   	push   %esi
c0106d45:	53                   	push   %ebx
c0106d46:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106d49:	c7 04 24 2c d6 10 c0 	movl   $0xc010d62c,(%esp)
c0106d50:	e8 18 96 ff ff       	call   c010036d <cprintf>
    size_t left, right = 0, perm;
c0106d55:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106d5c:	e9 f2 00 00 00       	jmp    c0106e53 <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106d61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d64:	89 04 24             	mov    %eax,(%esp)
c0106d67:	e8 de fe ff ff       	call   c0106c4a <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106d6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106d72:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106d74:	89 d6                	mov    %edx,%esi
c0106d76:	c1 e6 16             	shl    $0x16,%esi
c0106d79:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d7c:	89 d3                	mov    %edx,%ebx
c0106d7e:	c1 e3 16             	shl    $0x16,%ebx
c0106d81:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106d84:	89 d1                	mov    %edx,%ecx
c0106d86:	c1 e1 16             	shl    $0x16,%ecx
c0106d89:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d8c:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0106d8f:	29 fa                	sub    %edi,%edx
c0106d91:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106d95:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106d99:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106da1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106da5:	c7 04 24 5d d6 10 c0 	movl   $0xc010d65d,(%esp)
c0106dac:	e8 bc 95 ff ff       	call   c010036d <cprintf>
        size_t l, r = left * NPTEENTRY;
c0106db1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106db4:	c1 e0 0a             	shl    $0xa,%eax
c0106db7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106dba:	eb 50                	jmp    c0106e0c <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106dbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106dbf:	89 04 24             	mov    %eax,(%esp)
c0106dc2:	e8 83 fe ff ff       	call   c0106c4a <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106dc7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106dca:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0106dcd:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106dcf:	89 d6                	mov    %edx,%esi
c0106dd1:	c1 e6 0c             	shl    $0xc,%esi
c0106dd4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106dd7:	89 d3                	mov    %edx,%ebx
c0106dd9:	c1 e3 0c             	shl    $0xc,%ebx
c0106ddc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106ddf:	89 d1                	mov    %edx,%ecx
c0106de1:	c1 e1 0c             	shl    $0xc,%ecx
c0106de4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106de7:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106dea:	29 fa                	sub    %edi,%edx
c0106dec:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106df0:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106df4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106dfc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e00:	c7 04 24 7c d6 10 c0 	movl   $0xc010d67c,(%esp)
c0106e07:	e8 61 95 ff ff       	call   c010036d <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106e0c:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0106e11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e17:	89 d3                	mov    %edx,%ebx
c0106e19:	c1 e3 0a             	shl    $0xa,%ebx
c0106e1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106e1f:	89 d1                	mov    %edx,%ecx
c0106e21:	c1 e1 0a             	shl    $0xa,%ecx
c0106e24:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0106e27:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106e2b:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0106e2e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106e32:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106e36:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106e3e:	89 0c 24             	mov    %ecx,(%esp)
c0106e41:	e8 46 fe ff ff       	call   c0106c8c <get_pgtable_items>
c0106e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e4d:	0f 85 69 ff ff ff    	jne    c0106dbc <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106e53:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0106e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e5b:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106e5e:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106e62:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0106e65:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106e6d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e71:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106e78:	00 
c0106e79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106e80:	e8 07 fe ff ff       	call   c0106c8c <get_pgtable_items>
c0106e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106e88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e8c:	0f 85 cf fe ff ff    	jne    c0106d61 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106e92:	c7 04 24 a0 d6 10 c0 	movl   $0xc010d6a0,(%esp)
c0106e99:	e8 cf 94 ff ff       	call   c010036d <cprintf>
}
c0106e9e:	90                   	nop
c0106e9f:	83 c4 4c             	add    $0x4c,%esp
c0106ea2:	5b                   	pop    %ebx
c0106ea3:	5e                   	pop    %esi
c0106ea4:	5f                   	pop    %edi
c0106ea5:	5d                   	pop    %ebp
c0106ea6:	c3                   	ret    

c0106ea7 <pa2page>:
pa2page(uintptr_t pa) {
c0106ea7:	55                   	push   %ebp
c0106ea8:	89 e5                	mov    %esp,%ebp
c0106eaa:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106ead:	8b 45 08             	mov    0x8(%ebp),%eax
c0106eb0:	c1 e8 0c             	shr    $0xc,%eax
c0106eb3:	89 c2                	mov    %eax,%edx
c0106eb5:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0106eba:	39 c2                	cmp    %eax,%edx
c0106ebc:	72 1c                	jb     c0106eda <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106ebe:	c7 44 24 08 d4 d6 10 	movl   $0xc010d6d4,0x8(%esp)
c0106ec5:	c0 
c0106ec6:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106ecd:	00 
c0106ece:	c7 04 24 f3 d6 10 c0 	movl   $0xc010d6f3,(%esp)
c0106ed5:	e8 11 9f ff ff       	call   c0100deb <__panic>
    return &pages[PPN(pa)];
c0106eda:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0106ee0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ee3:	c1 e8 0c             	shr    $0xc,%eax
c0106ee6:	c1 e0 05             	shl    $0x5,%eax
c0106ee9:	01 d0                	add    %edx,%eax
}
c0106eeb:	89 ec                	mov    %ebp,%esp
c0106eed:	5d                   	pop    %ebp
c0106eee:	c3                   	ret    

c0106eef <pte2page>:
pte2page(pte_t pte) {
c0106eef:	55                   	push   %ebp
c0106ef0:	89 e5                	mov    %esp,%ebp
c0106ef2:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106ef5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ef8:	83 e0 01             	and    $0x1,%eax
c0106efb:	85 c0                	test   %eax,%eax
c0106efd:	75 1c                	jne    c0106f1b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106eff:	c7 44 24 08 04 d7 10 	movl   $0xc010d704,0x8(%esp)
c0106f06:	c0 
c0106f07:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106f0e:	00 
c0106f0f:	c7 04 24 f3 d6 10 c0 	movl   $0xc010d6f3,(%esp)
c0106f16:	e8 d0 9e ff ff       	call   c0100deb <__panic>
    return pa2page(PTE_ADDR(pte));
c0106f1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f23:	89 04 24             	mov    %eax,(%esp)
c0106f26:	e8 7c ff ff ff       	call   c0106ea7 <pa2page>
}
c0106f2b:	89 ec                	mov    %ebp,%esp
c0106f2d:	5d                   	pop    %ebp
c0106f2e:	c3                   	ret    

c0106f2f <pde2page>:
pde2page(pde_t pde) {
c0106f2f:	55                   	push   %ebp
c0106f30:	89 e5                	mov    %esp,%ebp
c0106f32:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106f3d:	89 04 24             	mov    %eax,(%esp)
c0106f40:	e8 62 ff ff ff       	call   c0106ea7 <pa2page>
}
c0106f45:	89 ec                	mov    %ebp,%esp
c0106f47:	5d                   	pop    %ebp
c0106f48:	c3                   	ret    

c0106f49 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106f49:	55                   	push   %ebp
c0106f4a:	89 e5                	mov    %esp,%ebp
c0106f4c:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106f4f:	e8 2c 25 00 00       	call   c0109480 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106f54:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c0106f59:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106f5e:	76 0c                	jbe    c0106f6c <swap_init+0x23>
c0106f60:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c0106f65:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106f6a:	76 25                	jbe    c0106f91 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106f6c:	a1 40 40 1a c0       	mov    0xc01a4040,%eax
c0106f71:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f75:	c7 44 24 08 25 d7 10 	movl   $0xc010d725,0x8(%esp)
c0106f7c:	c0 
c0106f7d:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106f84:	00 
c0106f85:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0106f8c:	e8 5a 9e ff ff       	call   c0100deb <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106f91:	c7 05 00 41 1a c0 60 	movl   $0xc012fa60,0xc01a4100
c0106f98:	fa 12 c0 
     int r = sm->init();
c0106f9b:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106fa0:	8b 40 04             	mov    0x4(%eax),%eax
c0106fa3:	ff d0                	call   *%eax
c0106fa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106fa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106fac:	75 26                	jne    c0106fd4 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106fae:	c7 05 44 40 1a c0 01 	movl   $0x1,0xc01a4044
c0106fb5:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106fb8:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106fbd:	8b 00                	mov    (%eax),%eax
c0106fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fc3:	c7 04 24 4f d7 10 c0 	movl   $0xc010d74f,(%esp)
c0106fca:	e8 9e 93 ff ff       	call   c010036d <cprintf>
          check_swap();
c0106fcf:	e8 b0 04 00 00       	call   c0107484 <check_swap>
     }

     return r;
c0106fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106fd7:	89 ec                	mov    %ebp,%esp
c0106fd9:	5d                   	pop    %ebp
c0106fda:	c3                   	ret    

c0106fdb <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106fdb:	55                   	push   %ebp
c0106fdc:	89 e5                	mov    %esp,%ebp
c0106fde:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106fe1:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0106fe6:	8b 40 08             	mov    0x8(%eax),%eax
c0106fe9:	8b 55 08             	mov    0x8(%ebp),%edx
c0106fec:	89 14 24             	mov    %edx,(%esp)
c0106fef:	ff d0                	call   *%eax
}
c0106ff1:	89 ec                	mov    %ebp,%esp
c0106ff3:	5d                   	pop    %ebp
c0106ff4:	c3                   	ret    

c0106ff5 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106ff5:	55                   	push   %ebp
c0106ff6:	89 e5                	mov    %esp,%ebp
c0106ff8:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106ffb:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0107000:	8b 40 0c             	mov    0xc(%eax),%eax
c0107003:	8b 55 08             	mov    0x8(%ebp),%edx
c0107006:	89 14 24             	mov    %edx,(%esp)
c0107009:	ff d0                	call   *%eax
}
c010700b:	89 ec                	mov    %ebp,%esp
c010700d:	5d                   	pop    %ebp
c010700e:	c3                   	ret    

c010700f <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010700f:	55                   	push   %ebp
c0107010:	89 e5                	mov    %esp,%ebp
c0107012:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0107015:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010701a:	8b 40 10             	mov    0x10(%eax),%eax
c010701d:	8b 55 14             	mov    0x14(%ebp),%edx
c0107020:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107024:	8b 55 10             	mov    0x10(%ebp),%edx
c0107027:	89 54 24 08          	mov    %edx,0x8(%esp)
c010702b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010702e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107032:	8b 55 08             	mov    0x8(%ebp),%edx
c0107035:	89 14 24             	mov    %edx,(%esp)
c0107038:	ff d0                	call   *%eax
}
c010703a:	89 ec                	mov    %ebp,%esp
c010703c:	5d                   	pop    %ebp
c010703d:	c3                   	ret    

c010703e <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010703e:	55                   	push   %ebp
c010703f:	89 e5                	mov    %esp,%ebp
c0107041:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0107044:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0107049:	8b 40 14             	mov    0x14(%eax),%eax
c010704c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010704f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107053:	8b 55 08             	mov    0x8(%ebp),%edx
c0107056:	89 14 24             	mov    %edx,(%esp)
c0107059:	ff d0                	call   *%eax
}
c010705b:	89 ec                	mov    %ebp,%esp
c010705d:	5d                   	pop    %ebp
c010705e:	c3                   	ret    

c010705f <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c010705f:	55                   	push   %ebp
c0107060:	89 e5                	mov    %esp,%ebp
c0107062:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0107065:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010706c:	e9 53 01 00 00       	jmp    c01071c4 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0107071:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0107076:	8b 40 18             	mov    0x18(%eax),%eax
c0107079:	8b 55 10             	mov    0x10(%ebp),%edx
c010707c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107080:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0107083:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107087:	8b 55 08             	mov    0x8(%ebp),%edx
c010708a:	89 14 24             	mov    %edx,(%esp)
c010708d:	ff d0                	call   *%eax
c010708f:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0107092:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107096:	74 18                	je     c01070b0 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0107098:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010709b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010709f:	c7 04 24 64 d7 10 c0 	movl   $0xc010d764,(%esp)
c01070a6:	e8 c2 92 ff ff       	call   c010036d <cprintf>
c01070ab:	e9 20 01 00 00       	jmp    c01071d0 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01070b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01070b3:	8b 40 1c             	mov    0x1c(%eax),%eax
c01070b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01070b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01070bc:	8b 40 0c             	mov    0xc(%eax),%eax
c01070bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01070c6:	00 
c01070c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01070ca:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070ce:	89 04 24             	mov    %eax,(%esp)
c01070d1:	e8 25 e9 ff ff       	call   c01059fb <get_pte>
c01070d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01070d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070dc:	8b 00                	mov    (%eax),%eax
c01070de:	83 e0 01             	and    $0x1,%eax
c01070e1:	85 c0                	test   %eax,%eax
c01070e3:	75 24                	jne    c0107109 <swap_out+0xaa>
c01070e5:	c7 44 24 0c 91 d7 10 	movl   $0xc010d791,0xc(%esp)
c01070ec:	c0 
c01070ed:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01070f4:	c0 
c01070f5:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01070fc:	00 
c01070fd:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107104:	e8 e2 9c ff ff       	call   c0100deb <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0107109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010710c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010710f:	8b 52 1c             	mov    0x1c(%edx),%edx
c0107112:	c1 ea 0c             	shr    $0xc,%edx
c0107115:	42                   	inc    %edx
c0107116:	c1 e2 08             	shl    $0x8,%edx
c0107119:	89 44 24 04          	mov    %eax,0x4(%esp)
c010711d:	89 14 24             	mov    %edx,(%esp)
c0107120:	e8 1a 24 00 00       	call   c010953f <swapfs_write>
c0107125:	85 c0                	test   %eax,%eax
c0107127:	74 34                	je     c010715d <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0107129:	c7 04 24 bb d7 10 c0 	movl   $0xc010d7bb,(%esp)
c0107130:	e8 38 92 ff ff       	call   c010036d <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0107135:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c010713a:	8b 40 10             	mov    0x10(%eax),%eax
c010713d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107140:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107147:	00 
c0107148:	89 54 24 08          	mov    %edx,0x8(%esp)
c010714c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010714f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107153:	8b 55 08             	mov    0x8(%ebp),%edx
c0107156:	89 14 24             	mov    %edx,(%esp)
c0107159:	ff d0                	call   *%eax
c010715b:	eb 64                	jmp    c01071c1 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c010715d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107160:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107163:	c1 e8 0c             	shr    $0xc,%eax
c0107166:	40                   	inc    %eax
c0107167:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010716b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010716e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107172:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107179:	c7 04 24 d4 d7 10 c0 	movl   $0xc010d7d4,(%esp)
c0107180:	e8 e8 91 ff ff       	call   c010036d <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0107185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107188:	8b 40 1c             	mov    0x1c(%eax),%eax
c010718b:	c1 e8 0c             	shr    $0xc,%eax
c010718e:	40                   	inc    %eax
c010718f:	c1 e0 08             	shl    $0x8,%eax
c0107192:	89 c2                	mov    %eax,%edx
c0107194:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107197:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0107199:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010719c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01071a3:	00 
c01071a4:	89 04 24             	mov    %eax,(%esp)
c01071a7:	e8 01 e2 ff ff       	call   c01053ad <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c01071ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01071af:	8b 40 0c             	mov    0xc(%eax),%eax
c01071b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01071b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071b9:	89 04 24             	mov    %eax,(%esp)
c01071bc:	e8 09 ef ff ff       	call   c01060ca <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c01071c1:	ff 45 f4             	incl   -0xc(%ebp)
c01071c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01071ca:	0f 85 a1 fe ff ff    	jne    c0107071 <swap_out+0x12>
     }
     return i;
c01071d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01071d3:	89 ec                	mov    %ebp,%esp
c01071d5:	5d                   	pop    %ebp
c01071d6:	c3                   	ret    

c01071d7 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01071d7:	55                   	push   %ebp
c01071d8:	89 e5                	mov    %esp,%ebp
c01071da:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01071dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01071e4:	e8 57 e1 ff ff       	call   c0105340 <alloc_pages>
c01071e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01071ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071f0:	75 24                	jne    c0107216 <swap_in+0x3f>
c01071f2:	c7 44 24 0c 14 d8 10 	movl   $0xc010d814,0xc(%esp)
c01071f9:	c0 
c01071fa:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107201:	c0 
c0107202:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107209:	00 
c010720a:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107211:	e8 d5 9b ff ff       	call   c0100deb <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107216:	8b 45 08             	mov    0x8(%ebp),%eax
c0107219:	8b 40 0c             	mov    0xc(%eax),%eax
c010721c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107223:	00 
c0107224:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107227:	89 54 24 04          	mov    %edx,0x4(%esp)
c010722b:	89 04 24             	mov    %eax,(%esp)
c010722e:	e8 c8 e7 ff ff       	call   c01059fb <get_pte>
c0107233:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107236:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107239:	8b 00                	mov    (%eax),%eax
c010723b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010723e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107242:	89 04 24             	mov    %eax,(%esp)
c0107245:	e8 81 22 00 00       	call   c01094cb <swapfs_read>
c010724a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010724d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107251:	74 2a                	je     c010727d <swap_in+0xa6>
     {
        assert(r!=0);
c0107253:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107257:	75 24                	jne    c010727d <swap_in+0xa6>
c0107259:	c7 44 24 0c 21 d8 10 	movl   $0xc010d821,0xc(%esp)
c0107260:	c0 
c0107261:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107268:	c0 
c0107269:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0107270:	00 
c0107271:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107278:	e8 6e 9b ff ff       	call   c0100deb <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c010727d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107280:	8b 00                	mov    (%eax),%eax
c0107282:	c1 e8 08             	shr    $0x8,%eax
c0107285:	89 c2                	mov    %eax,%edx
c0107287:	8b 45 0c             	mov    0xc(%ebp),%eax
c010728a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010728e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107292:	c7 04 24 28 d8 10 c0 	movl   $0xc010d828,(%esp)
c0107299:	e8 cf 90 ff ff       	call   c010036d <cprintf>
     *ptr_result=result;
c010729e:	8b 45 10             	mov    0x10(%ebp),%eax
c01072a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01072a4:	89 10                	mov    %edx,(%eax)
     return 0;
c01072a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01072ab:	89 ec                	mov    %ebp,%esp
c01072ad:	5d                   	pop    %ebp
c01072ae:	c3                   	ret    

c01072af <check_content_set>:



static inline void
check_content_set(void)
{
c01072af:	55                   	push   %ebp
c01072b0:	89 e5                	mov    %esp,%ebp
c01072b2:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01072b5:	b8 00 10 00 00       	mov    $0x1000,%eax
c01072ba:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01072bd:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01072c2:	83 f8 01             	cmp    $0x1,%eax
c01072c5:	74 24                	je     c01072eb <check_content_set+0x3c>
c01072c7:	c7 44 24 0c 66 d8 10 	movl   $0xc010d866,0xc(%esp)
c01072ce:	c0 
c01072cf:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01072d6:	c0 
c01072d7:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01072de:	00 
c01072df:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01072e6:	e8 00 9b ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01072eb:	b8 10 10 00 00       	mov    $0x1010,%eax
c01072f0:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01072f3:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01072f8:	83 f8 01             	cmp    $0x1,%eax
c01072fb:	74 24                	je     c0107321 <check_content_set+0x72>
c01072fd:	c7 44 24 0c 66 d8 10 	movl   $0xc010d866,0xc(%esp)
c0107304:	c0 
c0107305:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010730c:	c0 
c010730d:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107314:	00 
c0107315:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010731c:	e8 ca 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107321:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107326:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107329:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010732e:	83 f8 02             	cmp    $0x2,%eax
c0107331:	74 24                	je     c0107357 <check_content_set+0xa8>
c0107333:	c7 44 24 0c 75 d8 10 	movl   $0xc010d875,0xc(%esp)
c010733a:	c0 
c010733b:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107342:	c0 
c0107343:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c010734a:	00 
c010734b:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107352:	e8 94 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0107357:	b8 10 20 00 00       	mov    $0x2010,%eax
c010735c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010735f:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107364:	83 f8 02             	cmp    $0x2,%eax
c0107367:	74 24                	je     c010738d <check_content_set+0xde>
c0107369:	c7 44 24 0c 75 d8 10 	movl   $0xc010d875,0xc(%esp)
c0107370:	c0 
c0107371:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107378:	c0 
c0107379:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0107380:	00 
c0107381:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107388:	e8 5e 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c010738d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107392:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107395:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010739a:	83 f8 03             	cmp    $0x3,%eax
c010739d:	74 24                	je     c01073c3 <check_content_set+0x114>
c010739f:	c7 44 24 0c 84 d8 10 	movl   $0xc010d884,0xc(%esp)
c01073a6:	c0 
c01073a7:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01073ae:	c0 
c01073af:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01073b6:	00 
c01073b7:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01073be:	e8 28 9a ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01073c3:	b8 10 30 00 00       	mov    $0x3010,%eax
c01073c8:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01073cb:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01073d0:	83 f8 03             	cmp    $0x3,%eax
c01073d3:	74 24                	je     c01073f9 <check_content_set+0x14a>
c01073d5:	c7 44 24 0c 84 d8 10 	movl   $0xc010d884,0xc(%esp)
c01073dc:	c0 
c01073dd:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01073e4:	c0 
c01073e5:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01073ec:	00 
c01073ed:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01073f4:	e8 f2 99 ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01073f9:	b8 00 40 00 00       	mov    $0x4000,%eax
c01073fe:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107401:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107406:	83 f8 04             	cmp    $0x4,%eax
c0107409:	74 24                	je     c010742f <check_content_set+0x180>
c010740b:	c7 44 24 0c 93 d8 10 	movl   $0xc010d893,0xc(%esp)
c0107412:	c0 
c0107413:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010741a:	c0 
c010741b:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0107422:	00 
c0107423:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010742a:	e8 bc 99 ff ff       	call   c0100deb <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010742f:	b8 10 40 00 00       	mov    $0x4010,%eax
c0107434:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107437:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010743c:	83 f8 04             	cmp    $0x4,%eax
c010743f:	74 24                	je     c0107465 <check_content_set+0x1b6>
c0107441:	c7 44 24 0c 93 d8 10 	movl   $0xc010d893,0xc(%esp)
c0107448:	c0 
c0107449:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107450:	c0 
c0107451:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0107458:	00 
c0107459:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107460:	e8 86 99 ff ff       	call   c0100deb <__panic>
}
c0107465:	90                   	nop
c0107466:	89 ec                	mov    %ebp,%esp
c0107468:	5d                   	pop    %ebp
c0107469:	c3                   	ret    

c010746a <check_content_access>:

static inline int
check_content_access(void)
{
c010746a:	55                   	push   %ebp
c010746b:	89 e5                	mov    %esp,%ebp
c010746d:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0107470:	a1 00 41 1a c0       	mov    0xc01a4100,%eax
c0107475:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107478:	ff d0                	call   *%eax
c010747a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010747d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107480:	89 ec                	mov    %ebp,%esp
c0107482:	5d                   	pop    %ebp
c0107483:	c3                   	ret    

c0107484 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0107484:	55                   	push   %ebp
c0107485:	89 e5                	mov    %esp,%ebp
c0107487:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010748a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107491:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0107498:	c7 45 e8 84 3f 1a c0 	movl   $0xc01a3f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010749f:	eb 6a                	jmp    c010750b <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c01074a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01074a4:	83 e8 0c             	sub    $0xc,%eax
c01074a7:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c01074aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01074ad:	83 c0 04             	add    $0x4,%eax
c01074b0:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01074b7:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01074ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01074bd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01074c0:	0f a3 10             	bt     %edx,(%eax)
c01074c3:	19 c0                	sbb    %eax,%eax
c01074c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01074c8:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01074cc:	0f 95 c0             	setne  %al
c01074cf:	0f b6 c0             	movzbl %al,%eax
c01074d2:	85 c0                	test   %eax,%eax
c01074d4:	75 24                	jne    c01074fa <check_swap+0x76>
c01074d6:	c7 44 24 0c a2 d8 10 	movl   $0xc010d8a2,0xc(%esp)
c01074dd:	c0 
c01074de:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01074e5:	c0 
c01074e6:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01074ed:	00 
c01074ee:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01074f5:	e8 f1 98 ff ff       	call   c0100deb <__panic>
        count ++, total += p->property;
c01074fa:	ff 45 f4             	incl   -0xc(%ebp)
c01074fd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107500:	8b 50 08             	mov    0x8(%eax),%edx
c0107503:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107506:	01 d0                	add    %edx,%eax
c0107508:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010750b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010750e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107511:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107514:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0107517:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010751a:	81 7d e8 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x18(%ebp)
c0107521:	0f 85 7a ff ff ff    	jne    c01074a1 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0107527:	e8 b6 de ff ff       	call   c01053e2 <nr_free_pages>
c010752c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010752f:	39 d0                	cmp    %edx,%eax
c0107531:	74 24                	je     c0107557 <check_swap+0xd3>
c0107533:	c7 44 24 0c b2 d8 10 	movl   $0xc010d8b2,0xc(%esp)
c010753a:	c0 
c010753b:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107542:	c0 
c0107543:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c010754a:	00 
c010754b:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107552:	e8 94 98 ff ff       	call   c0100deb <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0107557:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010755a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010755e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107561:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107565:	c7 04 24 cc d8 10 c0 	movl   $0xc010d8cc,(%esp)
c010756c:	e8 fc 8d ff ff       	call   c010036d <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0107571:	e8 a3 0c 00 00       	call   c0108219 <mm_create>
c0107576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0107579:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010757d:	75 24                	jne    c01075a3 <check_swap+0x11f>
c010757f:	c7 44 24 0c f2 d8 10 	movl   $0xc010d8f2,0xc(%esp)
c0107586:	c0 
c0107587:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010758e:	c0 
c010758f:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0107596:	00 
c0107597:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010759e:	e8 48 98 ff ff       	call   c0100deb <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01075a3:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c01075a8:	85 c0                	test   %eax,%eax
c01075aa:	74 24                	je     c01075d0 <check_swap+0x14c>
c01075ac:	c7 44 24 0c fd d8 10 	movl   $0xc010d8fd,0xc(%esp)
c01075b3:	c0 
c01075b4:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01075bb:	c0 
c01075bc:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c01075c3:	00 
c01075c4:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01075cb:	e8 1b 98 ff ff       	call   c0100deb <__panic>

     check_mm_struct = mm;
c01075d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075d3:	a3 0c 41 1a c0       	mov    %eax,0xc01a410c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c01075d8:	8b 15 00 fa 12 c0    	mov    0xc012fa00,%edx
c01075de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075e1:	89 50 0c             	mov    %edx,0xc(%eax)
c01075e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075e7:	8b 40 0c             	mov    0xc(%eax),%eax
c01075ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c01075ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01075f0:	8b 00                	mov    (%eax),%eax
c01075f2:	85 c0                	test   %eax,%eax
c01075f4:	74 24                	je     c010761a <check_swap+0x196>
c01075f6:	c7 44 24 0c 15 d9 10 	movl   $0xc010d915,0xc(%esp)
c01075fd:	c0 
c01075fe:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107605:	c0 
c0107606:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c010760d:	00 
c010760e:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107615:	e8 d1 97 ff ff       	call   c0100deb <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010761a:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0107621:	00 
c0107622:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0107629:	00 
c010762a:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0107631:	e8 7f 0c 00 00       	call   c01082b5 <vma_create>
c0107636:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0107639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010763d:	75 24                	jne    c0107663 <check_swap+0x1df>
c010763f:	c7 44 24 0c 23 d9 10 	movl   $0xc010d923,0xc(%esp)
c0107646:	c0 
c0107647:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010764e:	c0 
c010764f:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107656:	00 
c0107657:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010765e:	e8 88 97 ff ff       	call   c0100deb <__panic>

     insert_vma_struct(mm, vma);
c0107663:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107666:	89 44 24 04          	mov    %eax,0x4(%esp)
c010766a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010766d:	89 04 24             	mov    %eax,(%esp)
c0107670:	e8 d7 0d 00 00       	call   c010844c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0107675:	c7 04 24 30 d9 10 c0 	movl   $0xc010d930,(%esp)
c010767c:	e8 ec 8c ff ff       	call   c010036d <cprintf>
     pte_t *temp_ptep=NULL;
c0107681:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0107688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010768b:	8b 40 0c             	mov    0xc(%eax),%eax
c010768e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107695:	00 
c0107696:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010769d:	00 
c010769e:	89 04 24             	mov    %eax,(%esp)
c01076a1:	e8 55 e3 ff ff       	call   c01059fb <get_pte>
c01076a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c01076a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01076ad:	75 24                	jne    c01076d3 <check_swap+0x24f>
c01076af:	c7 44 24 0c 64 d9 10 	movl   $0xc010d964,0xc(%esp)
c01076b6:	c0 
c01076b7:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01076be:	c0 
c01076bf:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01076c6:	00 
c01076c7:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01076ce:	e8 18 97 ff ff       	call   c0100deb <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01076d3:	c7 04 24 78 d9 10 c0 	movl   $0xc010d978,(%esp)
c01076da:	e8 8e 8c ff ff       	call   c010036d <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01076df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076e6:	e9 a2 00 00 00       	jmp    c010778d <check_swap+0x309>
          check_rp[i] = alloc_page();
c01076eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01076f2:	e8 49 dc ff ff       	call   c0105340 <alloc_pages>
c01076f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01076fa:	89 04 95 cc 40 1a c0 	mov    %eax,-0x3fe5bf34(,%edx,4)
          assert(check_rp[i] != NULL );
c0107701:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107704:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c010770b:	85 c0                	test   %eax,%eax
c010770d:	75 24                	jne    c0107733 <check_swap+0x2af>
c010770f:	c7 44 24 0c 9c d9 10 	movl   $0xc010d99c,0xc(%esp)
c0107716:	c0 
c0107717:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010771e:	c0 
c010771f:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0107726:	00 
c0107727:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010772e:	e8 b8 96 ff ff       	call   c0100deb <__panic>
          assert(!PageProperty(check_rp[i]));
c0107733:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107736:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c010773d:	83 c0 04             	add    $0x4,%eax
c0107740:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0107747:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010774a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010774d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107750:	0f a3 10             	bt     %edx,(%eax)
c0107753:	19 c0                	sbb    %eax,%eax
c0107755:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0107758:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c010775c:	0f 95 c0             	setne  %al
c010775f:	0f b6 c0             	movzbl %al,%eax
c0107762:	85 c0                	test   %eax,%eax
c0107764:	74 24                	je     c010778a <check_swap+0x306>
c0107766:	c7 44 24 0c b0 d9 10 	movl   $0xc010d9b0,0xc(%esp)
c010776d:	c0 
c010776e:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107775:	c0 
c0107776:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010777d:	00 
c010777e:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107785:	e8 61 96 ff ff       	call   c0100deb <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010778a:	ff 45 ec             	incl   -0x14(%ebp)
c010778d:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107791:	0f 8e 54 ff ff ff    	jle    c01076eb <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c0107797:	a1 84 3f 1a c0       	mov    0xc01a3f84,%eax
c010779c:	8b 15 88 3f 1a c0    	mov    0xc01a3f88,%edx
c01077a2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01077a5:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01077a8:	c7 45 a4 84 3f 1a c0 	movl   $0xc01a3f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c01077af:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077b2:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01077b5:	89 50 04             	mov    %edx,0x4(%eax)
c01077b8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077bb:	8b 50 04             	mov    0x4(%eax),%edx
c01077be:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01077c1:	89 10                	mov    %edx,(%eax)
}
c01077c3:	90                   	nop
c01077c4:	c7 45 a8 84 3f 1a c0 	movl   $0xc01a3f84,-0x58(%ebp)
    return list->next == list;
c01077cb:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01077ce:	8b 40 04             	mov    0x4(%eax),%eax
c01077d1:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01077d4:	0f 94 c0             	sete   %al
c01077d7:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01077da:	85 c0                	test   %eax,%eax
c01077dc:	75 24                	jne    c0107802 <check_swap+0x37e>
c01077de:	c7 44 24 0c cb d9 10 	movl   $0xc010d9cb,0xc(%esp)
c01077e5:	c0 
c01077e6:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01077ed:	c0 
c01077ee:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c01077f5:	00 
c01077f6:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01077fd:	e8 e9 95 ff ff       	call   c0100deb <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107802:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0107807:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c010780a:	c7 05 8c 3f 1a c0 00 	movl   $0x0,0xc01a3f8c
c0107811:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107814:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010781b:	eb 1d                	jmp    c010783a <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c010781d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107820:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0107827:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010782e:	00 
c010782f:	89 04 24             	mov    %eax,(%esp)
c0107832:	e8 76 db ff ff       	call   c01053ad <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107837:	ff 45 ec             	incl   -0x14(%ebp)
c010783a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010783e:	7e dd                	jle    c010781d <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107840:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c0107845:	83 f8 04             	cmp    $0x4,%eax
c0107848:	74 24                	je     c010786e <check_swap+0x3ea>
c010784a:	c7 44 24 0c e4 d9 10 	movl   $0xc010d9e4,0xc(%esp)
c0107851:	c0 
c0107852:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107859:	c0 
c010785a:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107861:	00 
c0107862:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107869:	e8 7d 95 ff ff       	call   c0100deb <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010786e:	c7 04 24 08 da 10 c0 	movl   $0xc010da08,(%esp)
c0107875:	e8 f3 8a ff ff       	call   c010036d <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010787a:	c7 05 10 41 1a c0 00 	movl   $0x0,0xc01a4110
c0107881:	00 00 00 
     
     check_content_set();
c0107884:	e8 26 fa ff ff       	call   c01072af <check_content_set>
     assert( nr_free == 0);         
c0107889:	a1 8c 3f 1a c0       	mov    0xc01a3f8c,%eax
c010788e:	85 c0                	test   %eax,%eax
c0107890:	74 24                	je     c01078b6 <check_swap+0x432>
c0107892:	c7 44 24 0c 2f da 10 	movl   $0xc010da2f,0xc(%esp)
c0107899:	c0 
c010789a:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01078a1:	c0 
c01078a2:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c01078a9:	00 
c01078aa:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01078b1:	e8 35 95 ff ff       	call   c0100deb <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01078b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01078bd:	eb 25                	jmp    c01078e4 <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01078bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078c2:	c7 04 85 60 40 1a c0 	movl   $0xffffffff,-0x3fe5bfa0(,%eax,4)
c01078c9:	ff ff ff ff 
c01078cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078d0:	8b 14 85 60 40 1a c0 	mov    -0x3fe5bfa0(,%eax,4),%edx
c01078d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078da:	89 14 85 a0 40 1a c0 	mov    %edx,-0x3fe5bf60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01078e1:	ff 45 ec             	incl   -0x14(%ebp)
c01078e4:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01078e8:	7e d5                	jle    c01078bf <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01078ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01078f1:	e9 e8 00 00 00       	jmp    c01079de <check_swap+0x55a>
         check_ptep[i]=0;
c01078f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078f9:	c7 04 85 dc 40 1a c0 	movl   $0x0,-0x3fe5bf24(,%eax,4)
c0107900:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107904:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107907:	40                   	inc    %eax
c0107908:	c1 e0 0c             	shl    $0xc,%eax
c010790b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107912:	00 
c0107913:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107917:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010791a:	89 04 24             	mov    %eax,(%esp)
c010791d:	e8 d9 e0 ff ff       	call   c01059fb <get_pte>
c0107922:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107925:	89 04 95 dc 40 1a c0 	mov    %eax,-0x3fe5bf24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010792c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010792f:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c0107936:	85 c0                	test   %eax,%eax
c0107938:	75 24                	jne    c010795e <check_swap+0x4da>
c010793a:	c7 44 24 0c 3c da 10 	movl   $0xc010da3c,0xc(%esp)
c0107941:	c0 
c0107942:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107949:	c0 
c010794a:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0107951:	00 
c0107952:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107959:	e8 8d 94 ff ff       	call   c0100deb <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010795e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107961:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c0107968:	8b 00                	mov    (%eax),%eax
c010796a:	89 04 24             	mov    %eax,(%esp)
c010796d:	e8 7d f5 ff ff       	call   c0106eef <pte2page>
c0107972:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107975:	8b 14 95 cc 40 1a c0 	mov    -0x3fe5bf34(,%edx,4),%edx
c010797c:	39 d0                	cmp    %edx,%eax
c010797e:	74 24                	je     c01079a4 <check_swap+0x520>
c0107980:	c7 44 24 0c 54 da 10 	movl   $0xc010da54,0xc(%esp)
c0107987:	c0 
c0107988:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c010798f:	c0 
c0107990:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0107997:	00 
c0107998:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c010799f:	e8 47 94 ff ff       	call   c0100deb <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01079a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01079a7:	8b 04 85 dc 40 1a c0 	mov    -0x3fe5bf24(,%eax,4),%eax
c01079ae:	8b 00                	mov    (%eax),%eax
c01079b0:	83 e0 01             	and    $0x1,%eax
c01079b3:	85 c0                	test   %eax,%eax
c01079b5:	75 24                	jne    c01079db <check_swap+0x557>
c01079b7:	c7 44 24 0c 7c da 10 	movl   $0xc010da7c,0xc(%esp)
c01079be:	c0 
c01079bf:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c01079c6:	c0 
c01079c7:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01079ce:	00 
c01079cf:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c01079d6:	e8 10 94 ff ff       	call   c0100deb <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01079db:	ff 45 ec             	incl   -0x14(%ebp)
c01079de:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01079e2:	0f 8e 0e ff ff ff    	jle    c01078f6 <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c01079e8:	c7 04 24 98 da 10 c0 	movl   $0xc010da98,(%esp)
c01079ef:	e8 79 89 ff ff       	call   c010036d <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01079f4:	e8 71 fa ff ff       	call   c010746a <check_content_access>
c01079f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c01079fc:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107a00:	74 24                	je     c0107a26 <check_swap+0x5a2>
c0107a02:	c7 44 24 0c be da 10 	movl   $0xc010dabe,0xc(%esp)
c0107a09:	c0 
c0107a0a:	c7 44 24 08 a6 d7 10 	movl   $0xc010d7a6,0x8(%esp)
c0107a11:	c0 
c0107a12:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0107a19:	00 
c0107a1a:	c7 04 24 40 d7 10 c0 	movl   $0xc010d740,(%esp)
c0107a21:	e8 c5 93 ff ff       	call   c0100deb <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107a26:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107a2d:	eb 1d                	jmp    c0107a4c <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0107a2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a32:	8b 04 85 cc 40 1a c0 	mov    -0x3fe5bf34(,%eax,4),%eax
c0107a39:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a40:	00 
c0107a41:	89 04 24             	mov    %eax,(%esp)
c0107a44:	e8 64 d9 ff ff       	call   c01053ad <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107a49:	ff 45 ec             	incl   -0x14(%ebp)
c0107a4c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107a50:	7e dd                	jle    c0107a2f <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c0107a52:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a55:	8b 00                	mov    (%eax),%eax
c0107a57:	89 04 24             	mov    %eax,(%esp)
c0107a5a:	e8 d0 f4 ff ff       	call   c0106f2f <pde2page>
c0107a5f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107a66:	00 
c0107a67:	89 04 24             	mov    %eax,(%esp)
c0107a6a:	e8 3e d9 ff ff       	call   c01053ad <free_pages>
     pgdir[0] = 0;
c0107a6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a72:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0107a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a7b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0107a82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a85:	89 04 24             	mov    %eax,(%esp)
c0107a88:	e8 f5 0a 00 00       	call   c0108582 <mm_destroy>
     check_mm_struct = NULL;
c0107a8d:	c7 05 0c 41 1a c0 00 	movl   $0x0,0xc01a410c
c0107a94:	00 00 00 
     
     nr_free = nr_free_store;
c0107a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107a9a:	a3 8c 3f 1a c0       	mov    %eax,0xc01a3f8c
     free_list = free_list_store;
c0107a9f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107aa2:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107aa5:	a3 84 3f 1a c0       	mov    %eax,0xc01a3f84
c0107aaa:	89 15 88 3f 1a c0    	mov    %edx,0xc01a3f88

     
     le = &free_list;
c0107ab0:	c7 45 e8 84 3f 1a c0 	movl   $0xc01a3f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107ab7:	eb 1c                	jmp    c0107ad5 <check_swap+0x651>
         struct Page *p = le2page(le, page_link);
c0107ab9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107abc:	83 e8 0c             	sub    $0xc,%eax
c0107abf:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0107ac2:	ff 4d f4             	decl   -0xc(%ebp)
c0107ac5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107ac8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107acb:	8b 48 08             	mov    0x8(%eax),%ecx
c0107ace:	89 d0                	mov    %edx,%eax
c0107ad0:	29 c8                	sub    %ecx,%eax
c0107ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ad5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ad8:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0107adb:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107ade:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0107ae1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107ae4:	81 7d e8 84 3f 1a c0 	cmpl   $0xc01a3f84,-0x18(%ebp)
c0107aeb:	75 cc                	jne    c0107ab9 <check_swap+0x635>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0107aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107af0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107af7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107afb:	c7 04 24 c5 da 10 c0 	movl   $0xc010dac5,(%esp)
c0107b02:	e8 66 88 ff ff       	call   c010036d <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0107b07:	c7 04 24 df da 10 c0 	movl   $0xc010dadf,(%esp)
c0107b0e:	e8 5a 88 ff ff       	call   c010036d <cprintf>
}
c0107b13:	90                   	nop
c0107b14:	89 ec                	mov    %ebp,%esp
c0107b16:	5d                   	pop    %ebp
c0107b17:	c3                   	ret    

c0107b18 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0107b18:	55                   	push   %ebp
c0107b19:	89 e5                	mov    %esp,%ebp
c0107b1b:	83 ec 10             	sub    $0x10,%esp
c0107b1e:	c7 45 fc 04 41 1a c0 	movl   $0xc01a4104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0107b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b28:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107b2b:	89 50 04             	mov    %edx,0x4(%eax)
c0107b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b31:	8b 50 04             	mov    0x4(%eax),%edx
c0107b34:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107b37:	89 10                	mov    %edx,(%eax)
}
c0107b39:	90                   	nop
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
c0107b3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b3d:	c7 40 14 04 41 1a c0 	movl   $0xc01a4104,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c0107b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b49:	89 ec                	mov    %ebp,%esp
c0107b4b:	5d                   	pop    %ebp
c0107b4c:	c3                   	ret    

c0107b4d <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107b4d:	55                   	push   %ebp
c0107b4e:	89 e5                	mov    %esp,%ebp
c0107b50:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b56:	8b 40 14             	mov    0x14(%eax),%eax
c0107b59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry = &(page->pra_page_link);
c0107b5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0107b5f:	83 c0 14             	add    $0x14,%eax
c0107b62:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c0107b65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107b69:	74 06                	je     c0107b71 <_fifo_map_swappable+0x24>
c0107b6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b6f:	75 24                	jne    c0107b95 <_fifo_map_swappable+0x48>
c0107b71:	c7 44 24 0c f8 da 10 	movl   $0xc010daf8,0xc(%esp)
c0107b78:	c0 
c0107b79:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107b80:	c0 
c0107b81:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107b88:	00 
c0107b89:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107b90:	e8 56 92 ff ff       	call   c0100deb <__panic>
c0107b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b98:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0107ba1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ba4:	8b 00                	mov    (%eax),%eax
c0107ba6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107ba9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107bac:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107baf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107bb2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0107bb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107bbb:	89 10                	mov    %edx,(%eax)
c0107bbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bc0:	8b 10                	mov    (%eax),%edx
c0107bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107bc5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107bc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bcb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107bce:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107bd4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107bd7:	89 10                	mov    %edx,(%eax)
}
c0107bd9:	90                   	nop
}
c0107bda:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add_before(head, entry);
    return 0;
c0107bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107be0:	89 ec                	mov    %ebp,%esp
c0107be2:	5d                   	pop    %ebp
c0107be3:	c3                   	ret    

c0107be4 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0107be4:	55                   	push   %ebp
c0107be5:	89 e5                	mov    %esp,%ebp
c0107be7:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107bea:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bed:	8b 40 14             	mov    0x14(%eax),%eax
c0107bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0107bf3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107bf7:	75 24                	jne    c0107c1d <_fifo_swap_out_victim+0x39>
c0107bf9:	c7 44 24 0c 3f db 10 	movl   $0xc010db3f,0xc(%esp)
c0107c00:	c0 
c0107c01:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107c08:	c0 
c0107c09:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107c10:	00 
c0107c11:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107c18:	e8 ce 91 ff ff       	call   c0100deb <__panic>
    assert(in_tick == 0);
c0107c1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107c21:	74 24                	je     c0107c47 <_fifo_swap_out_victim+0x63>
c0107c23:	c7 44 24 0c 4c db 10 	movl   $0xc010db4c,0xc(%esp)
c0107c2a:	c0 
c0107c2b:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107c32:	c0 
c0107c33:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107c3a:	00 
c0107c3b:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107c42:	e8 a4 91 ff ff       	call   c0100deb <__panic>
c0107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107c4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c50:	8b 40 04             	mov    0x4(%eax),%eax
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    list_entry_t *le = list_next(head);
c0107c53:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c59:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107c5f:	8b 40 04             	mov    0x4(%eax),%eax
c0107c62:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c65:	8b 12                	mov    (%edx),%edx
c0107c67:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0107c6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107c73:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107c76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c79:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107c7c:	89 10                	mov    %edx,(%eax)
}
c0107c7e:	90                   	nop
}
c0107c7f:	90                   	nop
    list_del(le); //victim
    *ptr_page = le2page(le, pra_page_link);
c0107c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c83:	8d 50 ec             	lea    -0x14(%eax),%edx
c0107c86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c89:	89 10                	mov    %edx,(%eax)
    return 0;
c0107c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107c90:	89 ec                	mov    %ebp,%esp
c0107c92:	5d                   	pop    %ebp
c0107c93:	c3                   	ret    

c0107c94 <_extend_clock_swap_out_victim>:

static int
_extend_clock_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0107c94:	55                   	push   %ebp
c0107c95:	89 e5                	mov    %esp,%ebp
c0107c97:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0107c9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c9d:	8b 40 14             	mov    0x14(%eax),%eax
c0107ca0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(head != NULL);
c0107ca3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107ca7:	75 24                	jne    c0107ccd <_extend_clock_swap_out_victim+0x39>
c0107ca9:	c7 44 24 0c 3f db 10 	movl   $0xc010db3f,0xc(%esp)
c0107cb0:	c0 
c0107cb1:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107cb8:	c0 
c0107cb9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
c0107cc0:	00 
c0107cc1:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107cc8:	e8 1e 91 ff ff       	call   c0100deb <__panic>
    assert(in_tick == 0);
c0107ccd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107cd1:	74 24                	je     c0107cf7 <_extend_clock_swap_out_victim+0x63>
c0107cd3:	c7 44 24 0c 4c db 10 	movl   $0xc010db4c,0xc(%esp)
c0107cda:	c0 
c0107cdb:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107ce2:	c0 
c0107ce3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
c0107cea:	00 
c0107ceb:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107cf2:	e8 f4 90 ff ff       	call   c0100deb <__panic>
    //在head双向链表中从头开始遍历, 用三个指针取三个第一次遍历到的page
    list_entry_t *le = head->next, *_00 = NULL, *_10 = NULL, *_11 = NULL;
c0107cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cfa:	8b 40 04             	mov    0x4(%eax),%eax
c0107cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107d00:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0107d07:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107d0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != head)
c0107d15:	e9 99 00 00 00       	jmp    c0107db3 <_extend_clock_swap_out_victim+0x11f>
    {
        struct Page *page = le2page(le, pra_page_link);
c0107d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d1d:	83 e8 14             	sub    $0x14,%eax
c0107d20:	89 45 e0             	mov    %eax,-0x20(%ebp)

        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
c0107d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d26:	8b 50 1c             	mov    0x1c(%eax),%edx
c0107d29:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d2c:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107d36:	00 
c0107d37:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d3b:	89 04 24             	mov    %eax,(%esp)
c0107d3e:	e8 b8 dc ff ff       	call   c01059fb <get_pte>
c0107d43:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ptep != NULL);
c0107d46:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107d4a:	75 24                	jne    c0107d70 <_extend_clock_swap_out_victim+0xdc>
c0107d4c:	c7 44 24 0c 59 db 10 	movl   $0xc010db59,0xc(%esp)
c0107d53:	c0 
c0107d54:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107d5b:	c0 
c0107d5c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107d63:	00 
c0107d64:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107d6b:	e8 7b 90 ff ff       	call   c0100deb <__panic>
        if (!(*ptep & PTE_A))
c0107d70:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d73:	8b 00                	mov    (%eax),%eax
c0107d75:	83 e0 20             	and    $0x20,%eax
c0107d78:	85 c0                	test   %eax,%eax
c0107d7a:	75 08                	jne    c0107d84 <_extend_clock_swap_out_victim+0xf0>
        {
            _00 = le;
c0107d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
            break;
c0107d82:	eb 3b                	jmp    c0107dbf <_extend_clock_swap_out_victim+0x12b>
        }
        else if (!(*ptep & PTE_D) && _10 == NULL)
c0107d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d87:	8b 00                	mov    (%eax),%eax
c0107d89:	83 e0 40             	and    $0x40,%eax
c0107d8c:	85 c0                	test   %eax,%eax
c0107d8e:	75 0e                	jne    c0107d9e <_extend_clock_swap_out_victim+0x10a>
c0107d90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107d94:	75 08                	jne    c0107d9e <_extend_clock_swap_out_victim+0x10a>
            _10 = le;
c0107d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d99:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107d9c:	eb 0c                	jmp    c0107daa <_extend_clock_swap_out_victim+0x116>
        else if (_11 == NULL)
c0107d9e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107da2:	75 06                	jne    c0107daa <_extend_clock_swap_out_victim+0x116>
            _11 = le;
c0107da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107da7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = le->next;
c0107daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dad:	8b 40 04             	mov    0x4(%eax),%eax
c0107db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != head)
c0107db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107db6:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0107db9:	0f 85 5b ff ff ff    	jne    c0107d1a <_extend_clock_swap_out_victim+0x86>
    }
    le = _00 != NULL ? _00 : (_10 != NULL ? _10 : _11);
c0107dbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107dc3:	75 10                	jne    c0107dd5 <_extend_clock_swap_out_victim+0x141>
c0107dc5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107dc9:	74 05                	je     c0107dd0 <_extend_clock_swap_out_victim+0x13c>
c0107dcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107dce:	eb 08                	jmp    c0107dd8 <_extend_clock_swap_out_victim+0x144>
c0107dd0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107dd3:	eb 03                	jmp    c0107dd8 <_extend_clock_swap_out_victim+0x144>
c0107dd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    *ptr_page = le2page(le, pra_page_link);
c0107ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dde:	8d 50 ec             	lea    -0x14(%eax),%edx
c0107de1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107de4:	89 10                	mov    %edx,(%eax)
c0107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107de9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107dec:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107def:	8b 40 04             	mov    0x4(%eax),%eax
c0107df2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107df5:	8b 12                	mov    (%edx),%edx
c0107df7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107dfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next;
c0107dfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107e00:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107e03:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107e06:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107e09:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107e0c:	89 10                	mov    %edx,(%eax)
}
c0107e0e:	90                   	nop
}
c0107e0f:	90                   	nop
    list_del(le);
    return 0;
c0107e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e15:	89 ec                	mov    %ebp,%esp
c0107e17:	5d                   	pop    %ebp
c0107e18:	c3                   	ret    

c0107e19 <_fifo_check_swap>:

static int
_fifo_check_swap(void)
{
c0107e19:	55                   	push   %ebp
c0107e1a:	89 e5                	mov    %esp,%ebp
c0107e1c:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107e1f:	c7 04 24 68 db 10 c0 	movl   $0xc010db68,(%esp)
c0107e26:	e8 42 85 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107e2b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107e30:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 4);
c0107e33:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107e38:	83 f8 04             	cmp    $0x4,%eax
c0107e3b:	74 24                	je     c0107e61 <_fifo_check_swap+0x48>
c0107e3d:	c7 44 24 0c 8e db 10 	movl   $0xc010db8e,0xc(%esp)
c0107e44:	c0 
c0107e45:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107e4c:	c0 
c0107e4d:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107e54:	00 
c0107e55:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107e5c:	e8 8a 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107e61:	c7 04 24 a0 db 10 c0 	movl   $0xc010dba0,(%esp)
c0107e68:	e8 00 85 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107e6d:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e72:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 4);
c0107e75:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107e7a:	83 f8 04             	cmp    $0x4,%eax
c0107e7d:	74 24                	je     c0107ea3 <_fifo_check_swap+0x8a>
c0107e7f:	c7 44 24 0c 8e db 10 	movl   $0xc010db8e,0xc(%esp)
c0107e86:	c0 
c0107e87:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107e8e:	c0 
c0107e8f:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107e96:	00 
c0107e97:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107e9e:	e8 48 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107ea3:	c7 04 24 c8 db 10 c0 	movl   $0xc010dbc8,(%esp)
c0107eaa:	e8 be 84 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107eaf:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107eb4:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 4);
c0107eb7:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107ebc:	83 f8 04             	cmp    $0x4,%eax
c0107ebf:	74 24                	je     c0107ee5 <_fifo_check_swap+0xcc>
c0107ec1:	c7 44 24 0c 8e db 10 	movl   $0xc010db8e,0xc(%esp)
c0107ec8:	c0 
c0107ec9:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107ed0:	c0 
c0107ed1:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c0107ed8:	00 
c0107ed9:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107ee0:	e8 06 8f ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107ee5:	c7 04 24 f0 db 10 c0 	movl   $0xc010dbf0,(%esp)
c0107eec:	e8 7c 84 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107ef1:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107ef6:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 4);
c0107ef9:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107efe:	83 f8 04             	cmp    $0x4,%eax
c0107f01:	74 24                	je     c0107f27 <_fifo_check_swap+0x10e>
c0107f03:	c7 44 24 0c 8e db 10 	movl   $0xc010db8e,0xc(%esp)
c0107f0a:	c0 
c0107f0b:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107f12:	c0 
c0107f13:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c0107f1a:	00 
c0107f1b:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107f22:	e8 c4 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107f27:	c7 04 24 18 dc 10 c0 	movl   $0xc010dc18,(%esp)
c0107f2e:	e8 3a 84 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107f33:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107f38:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 5);
c0107f3b:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107f40:	83 f8 05             	cmp    $0x5,%eax
c0107f43:	74 24                	je     c0107f69 <_fifo_check_swap+0x150>
c0107f45:	c7 44 24 0c 3e dc 10 	movl   $0xc010dc3e,0xc(%esp)
c0107f4c:	c0 
c0107f4d:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107f54:	c0 
c0107f55:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107f5c:	00 
c0107f5d:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107f64:	e8 82 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107f69:	c7 04 24 f0 db 10 c0 	movl   $0xc010dbf0,(%esp)
c0107f70:	e8 f8 83 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107f75:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107f7a:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 5);
c0107f7d:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107f82:	83 f8 05             	cmp    $0x5,%eax
c0107f85:	74 24                	je     c0107fab <_fifo_check_swap+0x192>
c0107f87:	c7 44 24 0c 3e dc 10 	movl   $0xc010dc3e,0xc(%esp)
c0107f8e:	c0 
c0107f8f:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107f96:	c0 
c0107f97:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c0107f9e:	00 
c0107f9f:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107fa6:	e8 40 8e ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107fab:	c7 04 24 a0 db 10 c0 	movl   $0xc010dba0,(%esp)
c0107fb2:	e8 b6 83 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107fb7:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107fbc:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 6);
c0107fbf:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0107fc4:	83 f8 06             	cmp    $0x6,%eax
c0107fc7:	74 24                	je     c0107fed <_fifo_check_swap+0x1d4>
c0107fc9:	c7 44 24 0c 4f dc 10 	movl   $0xc010dc4f,0xc(%esp)
c0107fd0:	c0 
c0107fd1:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0107fd8:	c0 
c0107fd9:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0107fe0:	00 
c0107fe1:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0107fe8:	e8 fe 8d ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107fed:	c7 04 24 f0 db 10 c0 	movl   $0xc010dbf0,(%esp)
c0107ff4:	e8 74 83 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107ff9:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107ffe:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 7);
c0108001:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0108006:	83 f8 07             	cmp    $0x7,%eax
c0108009:	74 24                	je     c010802f <_fifo_check_swap+0x216>
c010800b:	c7 44 24 0c 60 dc 10 	movl   $0xc010dc60,0xc(%esp)
c0108012:	c0 
c0108013:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c010801a:	c0 
c010801b:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
c0108022:	00 
c0108023:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c010802a:	e8 bc 8d ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c010802f:	c7 04 24 68 db 10 c0 	movl   $0xc010db68,(%esp)
c0108036:	e8 32 83 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010803b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0108040:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 8);
c0108043:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0108048:	83 f8 08             	cmp    $0x8,%eax
c010804b:	74 24                	je     c0108071 <_fifo_check_swap+0x258>
c010804d:	c7 44 24 0c 71 dc 10 	movl   $0xc010dc71,0xc(%esp)
c0108054:	c0 
c0108055:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c010805c:	c0 
c010805d:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
c0108064:	00 
c0108065:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c010806c:	e8 7a 8d ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0108071:	c7 04 24 c8 db 10 c0 	movl   $0xc010dbc8,(%esp)
c0108078:	e8 f0 82 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010807d:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108082:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 9);
c0108085:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010808a:	83 f8 09             	cmp    $0x9,%eax
c010808d:	74 24                	je     c01080b3 <_fifo_check_swap+0x29a>
c010808f:	c7 44 24 0c 82 dc 10 	movl   $0xc010dc82,0xc(%esp)
c0108096:	c0 
c0108097:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c010809e:	c0 
c010809f:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
c01080a6:	00 
c01080a7:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c01080ae:	e8 38 8d ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01080b3:	c7 04 24 18 dc 10 c0 	movl   $0xc010dc18,(%esp)
c01080ba:	e8 ae 82 ff ff       	call   c010036d <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01080bf:	b8 00 50 00 00       	mov    $0x5000,%eax
c01080c4:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 10);
c01080c7:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c01080cc:	83 f8 0a             	cmp    $0xa,%eax
c01080cf:	74 24                	je     c01080f5 <_fifo_check_swap+0x2dc>
c01080d1:	c7 44 24 0c 93 dc 10 	movl   $0xc010dc93,0xc(%esp)
c01080d8:	c0 
c01080d9:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c01080e0:	c0 
c01080e1:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
c01080e8:	00 
c01080e9:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c01080f0:	e8 f6 8c ff ff       	call   c0100deb <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01080f5:	c7 04 24 a0 db 10 c0 	movl   $0xc010dba0,(%esp)
c01080fc:	e8 6c 82 ff ff       	call   c010036d <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0108101:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108106:	0f b6 00             	movzbl (%eax),%eax
c0108109:	3c 0a                	cmp    $0xa,%al
c010810b:	74 24                	je     c0108131 <_fifo_check_swap+0x318>
c010810d:	c7 44 24 0c a8 dc 10 	movl   $0xc010dca8,0xc(%esp)
c0108114:	c0 
c0108115:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c010811c:	c0 
c010811d:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
c0108124:	00 
c0108125:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c010812c:	e8 ba 8c ff ff       	call   c0100deb <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0108131:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108136:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 11);
c0108139:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c010813e:	83 f8 0b             	cmp    $0xb,%eax
c0108141:	74 24                	je     c0108167 <_fifo_check_swap+0x34e>
c0108143:	c7 44 24 0c c9 dc 10 	movl   $0xc010dcc9,0xc(%esp)
c010814a:	c0 
c010814b:	c7 44 24 08 16 db 10 	movl   $0xc010db16,0x8(%esp)
c0108152:	c0 
c0108153:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
c010815a:	00 
c010815b:	c7 04 24 2b db 10 c0 	movl   $0xc010db2b,(%esp)
c0108162:	e8 84 8c ff ff       	call   c0100deb <__panic>
    return 0;
c0108167:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010816c:	89 ec                	mov    %ebp,%esp
c010816e:	5d                   	pop    %ebp
c010816f:	c3                   	ret    

c0108170 <_fifo_init>:

static int
_fifo_init(void)
{
c0108170:	55                   	push   %ebp
c0108171:	89 e5                	mov    %esp,%ebp
    return 0;
c0108173:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108178:	5d                   	pop    %ebp
c0108179:	c3                   	ret    

c010817a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010817a:	55                   	push   %ebp
c010817b:	89 e5                	mov    %esp,%ebp
    return 0;
c010817d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108182:	5d                   	pop    %ebp
c0108183:	c3                   	ret    

c0108184 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
c0108184:	55                   	push   %ebp
c0108185:	89 e5                	mov    %esp,%ebp
    return 0;
c0108187:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010818c:	5d                   	pop    %ebp
c010818d:	c3                   	ret    

c010818e <pa2page>:
pa2page(uintptr_t pa) {
c010818e:	55                   	push   %ebp
c010818f:	89 e5                	mov    %esp,%ebp
c0108191:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108194:	8b 45 08             	mov    0x8(%ebp),%eax
c0108197:	c1 e8 0c             	shr    $0xc,%eax
c010819a:	89 c2                	mov    %eax,%edx
c010819c:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c01081a1:	39 c2                	cmp    %eax,%edx
c01081a3:	72 1c                	jb     c01081c1 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01081a5:	c7 44 24 08 f0 dc 10 	movl   $0xc010dcf0,0x8(%esp)
c01081ac:	c0 
c01081ad:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01081b4:	00 
c01081b5:	c7 04 24 0f dd 10 c0 	movl   $0xc010dd0f,(%esp)
c01081bc:	e8 2a 8c ff ff       	call   c0100deb <__panic>
    return &pages[PPN(pa)];
c01081c1:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c01081c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ca:	c1 e8 0c             	shr    $0xc,%eax
c01081cd:	c1 e0 05             	shl    $0x5,%eax
c01081d0:	01 d0                	add    %edx,%eax
}
c01081d2:	89 ec                	mov    %ebp,%esp
c01081d4:	5d                   	pop    %ebp
c01081d5:	c3                   	ret    

c01081d6 <pde2page>:
pde2page(pde_t pde) {
c01081d6:	55                   	push   %ebp
c01081d7:	89 e5                	mov    %esp,%ebp
c01081d9:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01081dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01081df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01081e4:	89 04 24             	mov    %eax,(%esp)
c01081e7:	e8 a2 ff ff ff       	call   c010818e <pa2page>
}
c01081ec:	89 ec                	mov    %ebp,%esp
c01081ee:	5d                   	pop    %ebp
c01081ef:	c3                   	ret    

c01081f0 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c01081f0:	55                   	push   %ebp
c01081f1:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c01081f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01081f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c01081fc:	90                   	nop
c01081fd:	5d                   	pop    %ebp
c01081fe:	c3                   	ret    

c01081ff <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c01081ff:	55                   	push   %ebp
c0108200:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0108202:	8b 45 08             	mov    0x8(%ebp),%eax
c0108205:	8b 40 18             	mov    0x18(%eax),%eax
}
c0108208:	5d                   	pop    %ebp
c0108209:	c3                   	ret    

c010820a <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c010820a:	55                   	push   %ebp
c010820b:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c010820d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108210:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108213:	89 50 18             	mov    %edx,0x18(%eax)
}
c0108216:	90                   	nop
c0108217:	5d                   	pop    %ebp
c0108218:	c3                   	ret    

c0108219 <mm_create>:
static void
check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0108219:	55                   	push   %ebp
c010821a:	89 e5                	mov    %esp,%ebp
c010821c:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c010821f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108226:	e8 84 cc ff ff       	call   c0104eaf <kmalloc>
c010822b:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c010822e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108232:	74 7a                	je     c01082ae <mm_create+0x95>
        list_init(&(mm->mmap_list));
c0108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108237:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c010823a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010823d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108240:	89 50 04             	mov    %edx,0x4(%eax)
c0108243:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108246:	8b 50 04             	mov    0x4(%eax),%edx
c0108249:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010824c:	89 10                	mov    %edx,(%eax)
}
c010824e:	90                   	nop
        mm->mmap_cache = NULL;
c010824f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108252:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0108259:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010825c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0108263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108266:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok)
c010826d:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c0108272:	85 c0                	test   %eax,%eax
c0108274:	74 0d                	je     c0108283 <mm_create+0x6a>
            swap_init_mm(mm);
c0108276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108279:	89 04 24             	mov    %eax,(%esp)
c010827c:	e8 5a ed ff ff       	call   c0106fdb <swap_init_mm>
c0108281:	eb 0a                	jmp    c010828d <mm_create+0x74>
        else
            mm->sm_priv = NULL;
c0108283:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108286:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

        set_mm_count(mm, 0);
c010828d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108294:	00 
c0108295:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108298:	89 04 24             	mov    %eax,(%esp)
c010829b:	e8 6a ff ff ff       	call   c010820a <set_mm_count>
        lock_init(&(mm->mm_lock));
c01082a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082a3:	83 c0 1c             	add    $0x1c,%eax
c01082a6:	89 04 24             	mov    %eax,(%esp)
c01082a9:	e8 42 ff ff ff       	call   c01081f0 <lock_init>
    }
    return mm;
c01082ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01082b1:	89 ec                	mov    %ebp,%esp
c01082b3:	5d                   	pop    %ebp
c01082b4:	c3                   	ret    

c01082b5 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01082b5:	55                   	push   %ebp
c01082b6:	89 e5                	mov    %esp,%ebp
c01082b8:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01082bb:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01082c2:	e8 e8 cb ff ff       	call   c0104eaf <kmalloc>
c01082c7:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c01082ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082ce:	74 1b                	je     c01082eb <vma_create+0x36>
        vma->vm_start = vm_start;
c01082d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01082d6:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c01082d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01082df:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c01082e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082e5:	8b 55 10             	mov    0x10(%ebp),%edx
c01082e8:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c01082eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01082ee:	89 ec                	mov    %ebp,%esp
c01082f0:	5d                   	pop    %ebp
c01082f1:	c3                   	ret    

c01082f2 <find_vma>:

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c01082f2:	55                   	push   %ebp
c01082f3:	89 e5                	mov    %esp,%ebp
c01082f5:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c01082f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01082ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108303:	0f 84 95 00 00 00    	je     c010839e <find_vma+0xac>
        vma = mm->mmap_cache;
c0108309:	8b 45 08             	mov    0x8(%ebp),%eax
c010830c:	8b 40 08             	mov    0x8(%eax),%eax
c010830f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0108312:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108316:	74 16                	je     c010832e <find_vma+0x3c>
c0108318:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010831b:	8b 40 04             	mov    0x4(%eax),%eax
c010831e:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108321:	72 0b                	jb     c010832e <find_vma+0x3c>
c0108323:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108326:	8b 40 08             	mov    0x8(%eax),%eax
c0108329:	39 45 0c             	cmp    %eax,0xc(%ebp)
c010832c:	72 61                	jb     c010838f <find_vma+0x9d>
            bool found = 0;
c010832e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
            list_entry_t *list = &(mm->mmap_list), *le = list;
c0108335:	8b 45 08             	mov    0x8(%ebp),%eax
c0108338:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010833b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010833e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            while ((le = list_next(le)) != list) {
c0108341:	eb 28                	jmp    c010836b <find_vma+0x79>
                vma = le2vma(le, list_link);
c0108343:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108346:	83 e8 10             	sub    $0x10,%eax
c0108349:	89 45 fc             	mov    %eax,-0x4(%ebp)
                if (vma->vm_start <= addr && addr < vma->vm_end) {
c010834c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010834f:	8b 40 04             	mov    0x4(%eax),%eax
c0108352:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108355:	72 14                	jb     c010836b <find_vma+0x79>
c0108357:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010835a:	8b 40 08             	mov    0x8(%eax),%eax
c010835d:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0108360:	73 09                	jae    c010836b <find_vma+0x79>
                    found = 1;
c0108362:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                    break;
c0108369:	eb 17                	jmp    c0108382 <find_vma+0x90>
c010836b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010836e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0108371:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108374:	8b 40 04             	mov    0x4(%eax),%eax
            while ((le = list_next(le)) != list) {
c0108377:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010837a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010837d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108380:	75 c1                	jne    c0108343 <find_vma+0x51>
                }
            }
            if (!found) {
c0108382:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0108386:	75 07                	jne    c010838f <find_vma+0x9d>
                vma = NULL;
c0108388:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
            }
        }
        if (vma != NULL) {
c010838f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108393:	74 09                	je     c010839e <find_vma+0xac>
            mm->mmap_cache = vma;
c0108395:	8b 45 08             	mov    0x8(%ebp),%eax
c0108398:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010839b:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c010839e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01083a1:	89 ec                	mov    %ebp,%esp
c01083a3:	5d                   	pop    %ebp
c01083a4:	c3                   	ret    

c01083a5 <check_vma_overlap>:

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01083a5:	55                   	push   %ebp
c01083a6:	89 e5                	mov    %esp,%ebp
c01083a8:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01083ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ae:	8b 50 04             	mov    0x4(%eax),%edx
c01083b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01083b4:	8b 40 08             	mov    0x8(%eax),%eax
c01083b7:	39 c2                	cmp    %eax,%edx
c01083b9:	72 24                	jb     c01083df <check_vma_overlap+0x3a>
c01083bb:	c7 44 24 0c 1d dd 10 	movl   $0xc010dd1d,0xc(%esp)
c01083c2:	c0 
c01083c3:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c01083ca:	c0 
c01083cb:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
c01083d2:	00 
c01083d3:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c01083da:	e8 0c 8a ff ff       	call   c0100deb <__panic>
    assert(prev->vm_end <= next->vm_start);
c01083df:	8b 45 08             	mov    0x8(%ebp),%eax
c01083e2:	8b 50 08             	mov    0x8(%eax),%edx
c01083e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083e8:	8b 40 04             	mov    0x4(%eax),%eax
c01083eb:	39 c2                	cmp    %eax,%edx
c01083ed:	76 24                	jbe    c0108413 <check_vma_overlap+0x6e>
c01083ef:	c7 44 24 0c 60 dd 10 	movl   $0xc010dd60,0xc(%esp)
c01083f6:	c0 
c01083f7:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c01083fe:	c0 
c01083ff:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0108406:	00 
c0108407:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c010840e:	e8 d8 89 ff ff       	call   c0100deb <__panic>
    assert(next->vm_start < next->vm_end);
c0108413:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108416:	8b 50 04             	mov    0x4(%eax),%edx
c0108419:	8b 45 0c             	mov    0xc(%ebp),%eax
c010841c:	8b 40 08             	mov    0x8(%eax),%eax
c010841f:	39 c2                	cmp    %eax,%edx
c0108421:	72 24                	jb     c0108447 <check_vma_overlap+0xa2>
c0108423:	c7 44 24 0c 7f dd 10 	movl   $0xc010dd7f,0xc(%esp)
c010842a:	c0 
c010842b:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108432:	c0 
c0108433:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010843a:	00 
c010843b:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108442:	e8 a4 89 ff ff       	call   c0100deb <__panic>
}
c0108447:	90                   	nop
c0108448:	89 ec                	mov    %ebp,%esp
c010844a:	5d                   	pop    %ebp
c010844b:	c3                   	ret    

c010844c <insert_vma_struct>:

// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010844c:	55                   	push   %ebp
c010844d:	89 e5                	mov    %esp,%ebp
c010844f:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108452:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108455:	8b 50 04             	mov    0x4(%eax),%edx
c0108458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010845b:	8b 40 08             	mov    0x8(%eax),%eax
c010845e:	39 c2                	cmp    %eax,%edx
c0108460:	72 24                	jb     c0108486 <insert_vma_struct+0x3a>
c0108462:	c7 44 24 0c 9d dd 10 	movl   $0xc010dd9d,0xc(%esp)
c0108469:	c0 
c010846a:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108471:	c0 
c0108472:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0108479:	00 
c010847a:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108481:	e8 65 89 ff ff       	call   c0100deb <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0108486:	8b 45 08             	mov    0x8(%ebp),%eax
c0108489:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010848c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010848f:	89 45 f4             	mov    %eax,-0xc(%ebp)

    list_entry_t *le = list;
c0108492:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108495:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while ((le = list_next(le)) != list) {
c0108498:	eb 1f                	jmp    c01084b9 <insert_vma_struct+0x6d>
        struct vma_struct *mmap_prev = le2vma(le, list_link);
c010849a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010849d:	83 e8 10             	sub    $0x10,%eax
c01084a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (mmap_prev->vm_start > vma->vm_start) {
c01084a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084a6:	8b 50 04             	mov    0x4(%eax),%edx
c01084a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084ac:	8b 40 04             	mov    0x4(%eax),%eax
c01084af:	39 c2                	cmp    %eax,%edx
c01084b1:	77 1f                	ja     c01084d2 <insert_vma_struct+0x86>
            break;
        }
        le_prev = le;
c01084b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01084b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01084bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01084c2:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c01084c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01084ce:	75 ca                	jne    c010849a <insert_vma_struct+0x4e>
c01084d0:	eb 01                	jmp    c01084d3 <insert_vma_struct+0x87>
            break;
c01084d2:	90                   	nop
c01084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084d6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01084d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01084dc:	8b 40 04             	mov    0x4(%eax),%eax
    }

    le_next = list_next(le_prev);
c01084df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01084e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084e5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01084e8:	74 15                	je     c01084ff <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01084ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084ed:	8d 50 f0             	lea    -0x10(%eax),%edx
c01084f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084f7:	89 14 24             	mov    %edx,(%esp)
c01084fa:	e8 a6 fe ff ff       	call   c01083a5 <check_vma_overlap>
    }
    if (le_next != list) {
c01084ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108502:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108505:	74 15                	je     c010851c <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0108507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010850a:	83 e8 10             	sub    $0x10,%eax
c010850d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108511:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108514:	89 04 24             	mov    %eax,(%esp)
c0108517:	e8 89 fe ff ff       	call   c01083a5 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010851c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010851f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108522:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108524:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108527:	8d 50 10             	lea    0x10(%eax),%edx
c010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010852d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108530:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108533:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108536:	8b 40 04             	mov    0x4(%eax),%eax
c0108539:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010853c:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010853f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108542:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108545:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0108548:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010854b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010854e:	89 10                	mov    %edx,(%eax)
c0108550:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108553:	8b 10                	mov    (%eax),%edx
c0108555:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108558:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010855b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010855e:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108561:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108564:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108567:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010856a:	89 10                	mov    %edx,(%eax)
}
c010856c:	90                   	nop
}
c010856d:	90                   	nop

    mm->map_count++;
c010856e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108571:	8b 40 10             	mov    0x10(%eax),%eax
c0108574:	8d 50 01             	lea    0x1(%eax),%edx
c0108577:	8b 45 08             	mov    0x8(%ebp),%eax
c010857a:	89 50 10             	mov    %edx,0x10(%eax)
}
c010857d:	90                   	nop
c010857e:	89 ec                	mov    %ebp,%esp
c0108580:	5d                   	pop    %ebp
c0108581:	c3                   	ret    

c0108582 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0108582:	55                   	push   %ebp
c0108583:	89 e5                	mov    %esp,%ebp
c0108585:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c0108588:	8b 45 08             	mov    0x8(%ebp),%eax
c010858b:	89 04 24             	mov    %eax,(%esp)
c010858e:	e8 6c fc ff ff       	call   c01081ff <mm_count>
c0108593:	85 c0                	test   %eax,%eax
c0108595:	74 24                	je     c01085bb <mm_destroy+0x39>
c0108597:	c7 44 24 0c b9 dd 10 	movl   $0xc010ddb9,0xc(%esp)
c010859e:	c0 
c010859f:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c01085a6:	c0 
c01085a7:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01085ae:	00 
c01085af:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c01085b6:	e8 30 88 ff ff       	call   c0100deb <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c01085bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01085be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01085c1:	eb 38                	jmp    c01085fb <mm_destroy+0x79>
c01085c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c01085c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085cc:	8b 40 04             	mov    0x4(%eax),%eax
c01085cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01085d2:	8b 12                	mov    (%edx),%edx
c01085d4:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01085d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c01085da:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01085e0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01085e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01085e9:	89 10                	mov    %edx,(%eax)
}
c01085eb:	90                   	nop
}
c01085ec:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma
c01085ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085f0:	83 e8 10             	sub    $0x10,%eax
c01085f3:	89 04 24             	mov    %eax,(%esp)
c01085f6:	e8 d1 c8 ff ff       	call   c0104ecc <kfree>
c01085fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0108601:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108604:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0108607:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010860a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010860d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108610:	75 b1                	jne    c01085c3 <mm_destroy+0x41>
    }
    kfree(mm);  //kfree mm
c0108612:	8b 45 08             	mov    0x8(%ebp),%eax
c0108615:	89 04 24             	mov    %eax,(%esp)
c0108618:	e8 af c8 ff ff       	call   c0104ecc <kfree>
    mm = NULL;
c010861d:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108624:	90                   	nop
c0108625:	89 ec                	mov    %ebp,%esp
c0108627:	5d                   	pop    %ebp
c0108628:	c3                   	ret    

c0108629 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags, struct vma_struct **vma_store) {
c0108629:	55                   	push   %ebp
c010862a:	89 e5                	mov    %esp,%ebp
c010862c:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c010862f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108632:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108635:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108638:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010863d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108640:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0108647:	8b 55 0c             	mov    0xc(%ebp),%edx
c010864a:	8b 45 10             	mov    0x10(%ebp),%eax
c010864d:	01 c2                	add    %eax,%edx
c010864f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108652:	01 d0                	add    %edx,%eax
c0108654:	48                   	dec    %eax
c0108655:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010865b:	ba 00 00 00 00       	mov    $0x0,%edx
c0108660:	f7 75 e8             	divl   -0x18(%ebp)
c0108663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108666:	29 d0                	sub    %edx,%eax
c0108668:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c010866b:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c0108672:	76 11                	jbe    c0108685 <mm_map+0x5c>
c0108674:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108677:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010867a:	73 09                	jae    c0108685 <mm_map+0x5c>
c010867c:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c0108683:	76 0a                	jbe    c010868f <mm_map+0x66>
        return -E_INVAL;
c0108685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010868a:	e9 b0 00 00 00       	jmp    c010873f <mm_map+0x116>
    }

    assert(mm != NULL);
c010868f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108693:	75 24                	jne    c01086b9 <mm_map+0x90>
c0108695:	c7 44 24 0c cb dd 10 	movl   $0xc010ddcb,0xc(%esp)
c010869c:	c0 
c010869d:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c01086a4:	c0 
c01086a5:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
c01086ac:	00 
c01086ad:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c01086b4:	e8 32 87 ff ff       	call   c0100deb <__panic>

    int ret = -E_INVAL;
c01086b9:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c01086c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ca:	89 04 24             	mov    %eax,(%esp)
c01086cd:	e8 20 fc ff ff       	call   c01082f2 <find_vma>
c01086d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01086d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01086d9:	74 0b                	je     c01086e6 <mm_map+0xbd>
c01086db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01086de:	8b 40 04             	mov    0x4(%eax),%eax
c01086e1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01086e4:	77 52                	ja     c0108738 <mm_map+0x10f>
        goto out;
    }
    ret = -E_NO_MEM;
c01086e6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c01086ed:	8b 45 14             	mov    0x14(%ebp),%eax
c01086f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01086f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086fe:	89 04 24             	mov    %eax,(%esp)
c0108701:	e8 af fb ff ff       	call   c01082b5 <vma_create>
c0108706:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108709:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010870d:	74 2c                	je     c010873b <mm_map+0x112>
        goto out;
    }
    insert_vma_struct(mm, vma);
c010870f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108716:	8b 45 08             	mov    0x8(%ebp),%eax
c0108719:	89 04 24             	mov    %eax,(%esp)
c010871c:	e8 2b fd ff ff       	call   c010844c <insert_vma_struct>
    if (vma_store != NULL) {
c0108721:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108725:	74 08                	je     c010872f <mm_map+0x106>
        *vma_store = vma;
c0108727:	8b 45 18             	mov    0x18(%ebp),%eax
c010872a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010872d:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c010872f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108736:	eb 04                	jmp    c010873c <mm_map+0x113>
        goto out;
c0108738:	90                   	nop
c0108739:	eb 01                	jmp    c010873c <mm_map+0x113>
        goto out;
c010873b:	90                   	nop

out:
    return ret;
c010873c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010873f:	89 ec                	mov    %ebp,%esp
c0108741:	5d                   	pop    %ebp
c0108742:	c3                   	ret    

c0108743 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0108743:	55                   	push   %ebp
c0108744:	89 e5                	mov    %esp,%ebp
c0108746:	56                   	push   %esi
c0108747:	53                   	push   %ebx
c0108748:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c010874b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010874f:	74 06                	je     c0108757 <dup_mmap+0x14>
c0108751:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108755:	75 24                	jne    c010877b <dup_mmap+0x38>
c0108757:	c7 44 24 0c d6 dd 10 	movl   $0xc010ddd6,0xc(%esp)
c010875e:	c0 
c010875f:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108766:	c0 
c0108767:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010876e:	00 
c010876f:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108776:	e8 70 86 ff ff       	call   c0100deb <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c010877b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010877e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108781:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0108787:	e9 92 00 00 00       	jmp    c010881e <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c010878c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010878f:	83 e8 10             	sub    $0x10,%eax
c0108792:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0108795:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108798:	8b 48 0c             	mov    0xc(%eax),%ecx
c010879b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010879e:	8b 50 08             	mov    0x8(%eax),%edx
c01087a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087a4:	8b 40 04             	mov    0x4(%eax),%eax
c01087a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01087ab:	89 54 24 04          	mov    %edx,0x4(%esp)
c01087af:	89 04 24             	mov    %eax,(%esp)
c01087b2:	e8 fe fa ff ff       	call   c01082b5 <vma_create>
c01087b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c01087ba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087be:	75 07                	jne    c01087c7 <dup_mmap+0x84>
            return -E_NO_MEM;
c01087c0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01087c5:	eb 76                	jmp    c010883d <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01087c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01087d1:	89 04 24             	mov    %eax,(%esp)
c01087d4:	e8 73 fc ff ff       	call   c010844c <insert_vma_struct>

        bool share = 0;
c01087d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c01087e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087e3:	8b 58 08             	mov    0x8(%eax),%ebx
c01087e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087e9:	8b 48 04             	mov    0x4(%eax),%ecx
c01087ec:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087ef:	8b 50 0c             	mov    0xc(%eax),%edx
c01087f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087f5:	8b 40 0c             	mov    0xc(%eax),%eax
c01087f8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c01087fb:	89 74 24 10          	mov    %esi,0x10(%esp)
c01087ff:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108803:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108807:	89 54 24 04          	mov    %edx,0x4(%esp)
c010880b:	89 04 24             	mov    %eax,(%esp)
c010880e:	e8 e9 d5 ff ff       	call   c0105dfc <copy_range>
c0108813:	85 c0                	test   %eax,%eax
c0108815:	74 07                	je     c010881e <dup_mmap+0xdb>
            return -E_NO_MEM;
c0108817:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010881c:	eb 1f                	jmp    c010883d <dup_mmap+0xfa>
c010881e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108821:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->prev;
c0108824:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108827:	8b 00                	mov    (%eax),%eax
    while ((le = list_prev(le)) != list) {
c0108829:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010882f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108832:	0f 85 54 ff ff ff    	jne    c010878c <dup_mmap+0x49>
        }
    }
    return 0;
c0108838:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010883d:	83 c4 40             	add    $0x40,%esp
c0108840:	5b                   	pop    %ebx
c0108841:	5e                   	pop    %esi
c0108842:	5d                   	pop    %ebp
c0108843:	c3                   	ret    

c0108844 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0108844:	55                   	push   %ebp
c0108845:	89 e5                	mov    %esp,%ebp
c0108847:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c010884a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010884e:	74 0f                	je     c010885f <exit_mmap+0x1b>
c0108850:	8b 45 08             	mov    0x8(%ebp),%eax
c0108853:	89 04 24             	mov    %eax,(%esp)
c0108856:	e8 a4 f9 ff ff       	call   c01081ff <mm_count>
c010885b:	85 c0                	test   %eax,%eax
c010885d:	74 24                	je     c0108883 <exit_mmap+0x3f>
c010885f:	c7 44 24 0c f4 dd 10 	movl   $0xc010ddf4,0xc(%esp)
c0108866:	c0 
c0108867:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c010886e:	c0 
c010886f:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0108876:	00 
c0108877:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c010887e:	e8 68 85 ff ff       	call   c0100deb <__panic>
    pde_t *pgdir = mm->pgdir;
c0108883:	8b 45 08             	mov    0x8(%ebp),%eax
c0108886:	8b 40 0c             	mov    0xc(%eax),%eax
c0108889:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c010888c:	8b 45 08             	mov    0x8(%ebp),%eax
c010888f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108892:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108895:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0108898:	eb 28                	jmp    c01088c2 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c010889a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010889d:	83 e8 10             	sub    $0x10,%eax
c01088a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c01088a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088a6:	8b 50 08             	mov    0x8(%eax),%edx
c01088a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088ac:	8b 40 04             	mov    0x4(%eax),%eax
c01088af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01088b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088ba:	89 04 24             	mov    %eax,(%esp)
c01088bd:	e8 39 d3 ff ff       	call   c0105bfb <unmap_range>
c01088c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c01088c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01088cb:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c01088ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01088d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088d4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01088d7:	75 c1                	jne    c010889a <exit_mmap+0x56>
    }
    while ((le = list_next(le)) != list) {
c01088d9:	eb 28                	jmp    c0108903 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c01088db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088de:	83 e8 10             	sub    $0x10,%eax
c01088e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c01088e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088e7:	8b 50 08             	mov    0x8(%eax),%edx
c01088ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088ed:	8b 40 04             	mov    0x4(%eax),%eax
c01088f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01088f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088fb:	89 04 24             	mov    %eax,(%esp)
c01088fe:	e8 ef d3 ff ff       	call   c0105cf2 <exit_range>
c0108903:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108906:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108909:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010890c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != list) {
c010890f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108912:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108915:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108918:	75 c1                	jne    c01088db <exit_mmap+0x97>
    }
}
c010891a:	90                   	nop
c010891b:	90                   	nop
c010891c:	89 ec                	mov    %ebp,%esp
c010891e:	5d                   	pop    %ebp
c010891f:	c3                   	ret    

c0108920 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0108920:	55                   	push   %ebp
c0108921:	89 e5                	mov    %esp,%ebp
c0108923:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0108926:	8b 45 10             	mov    0x10(%ebp),%eax
c0108929:	8b 55 18             	mov    0x18(%ebp),%edx
c010892c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108930:	8b 55 14             	mov    0x14(%ebp),%edx
c0108933:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108937:	89 44 24 04          	mov    %eax,0x4(%esp)
c010893b:	8b 45 08             	mov    0x8(%ebp),%eax
c010893e:	89 04 24             	mov    %eax,(%esp)
c0108941:	e8 94 09 00 00       	call   c01092da <user_mem_check>
c0108946:	85 c0                	test   %eax,%eax
c0108948:	75 07                	jne    c0108951 <copy_from_user+0x31>
        return 0;
c010894a:	b8 00 00 00 00       	mov    $0x0,%eax
c010894f:	eb 1e                	jmp    c010896f <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0108951:	8b 45 14             	mov    0x14(%ebp),%eax
c0108954:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108958:	8b 45 10             	mov    0x10(%ebp),%eax
c010895b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010895f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108962:	89 04 24             	mov    %eax,(%esp)
c0108965:	e8 59 37 00 00       	call   c010c0c3 <memcpy>
    return 1;
c010896a:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010896f:	89 ec                	mov    %ebp,%esp
c0108971:	5d                   	pop    %ebp
c0108972:	c3                   	ret    

c0108973 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0108973:	55                   	push   %ebp
c0108974:	89 e5                	mov    %esp,%ebp
c0108976:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0108979:	8b 45 0c             	mov    0xc(%ebp),%eax
c010897c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108983:	00 
c0108984:	8b 55 14             	mov    0x14(%ebp),%edx
c0108987:	89 54 24 08          	mov    %edx,0x8(%esp)
c010898b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010898f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108992:	89 04 24             	mov    %eax,(%esp)
c0108995:	e8 40 09 00 00       	call   c01092da <user_mem_check>
c010899a:	85 c0                	test   %eax,%eax
c010899c:	75 07                	jne    c01089a5 <copy_to_user+0x32>
        return 0;
c010899e:	b8 00 00 00 00       	mov    $0x0,%eax
c01089a3:	eb 1e                	jmp    c01089c3 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c01089a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01089a8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01089ac:	8b 45 10             	mov    0x10(%ebp),%eax
c01089af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089b6:	89 04 24             	mov    %eax,(%esp)
c01089b9:	e8 05 37 00 00       	call   c010c0c3 <memcpy>
    return 1;
c01089be:	b8 01 00 00 00       	mov    $0x1,%eax
}
c01089c3:	89 ec                	mov    %ebp,%esp
c01089c5:	5d                   	pop    %ebp
c01089c6:	c3                   	ret    

c01089c7 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01089c7:	55                   	push   %ebp
c01089c8:	89 e5                	mov    %esp,%ebp
c01089ca:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01089cd:	e8 05 00 00 00       	call   c01089d7 <check_vmm>
}
c01089d2:	90                   	nop
c01089d3:	89 ec                	mov    %ebp,%esp
c01089d5:	5d                   	pop    %ebp
c01089d6:	c3                   	ret    

c01089d7 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01089d7:	55                   	push   %ebp
c01089d8:	89 e5                	mov    %esp,%ebp
c01089da:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01089dd:	e8 00 ca ff ff       	call   c01053e2 <nr_free_pages>
c01089e2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    check_vma_struct();
c01089e5:	e8 16 00 00 00       	call   c0108a00 <check_vma_struct>
    check_pgfault();
c01089ea:	e8 a5 04 00 00       	call   c0108e94 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c01089ef:	c7 04 24 14 de 10 c0 	movl   $0xc010de14,(%esp)
c01089f6:	e8 72 79 ff ff       	call   c010036d <cprintf>
}
c01089fb:	90                   	nop
c01089fc:	89 ec                	mov    %ebp,%esp
c01089fe:	5d                   	pop    %ebp
c01089ff:	c3                   	ret    

c0108a00 <check_vma_struct>:

static void
check_vma_struct(void) {
c0108a00:	55                   	push   %ebp
c0108a01:	89 e5                	mov    %esp,%ebp
c0108a03:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108a06:	e8 d7 c9 ff ff       	call   c01053e2 <nr_free_pages>
c0108a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0108a0e:	e8 06 f8 ff ff       	call   c0108219 <mm_create>
c0108a13:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0108a16:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108a1a:	75 24                	jne    c0108a40 <check_vma_struct+0x40>
c0108a1c:	c7 44 24 0c cb dd 10 	movl   $0xc010ddcb,0xc(%esp)
c0108a23:	c0 
c0108a24:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108a2b:	c0 
c0108a2c:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0108a33:	00 
c0108a34:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108a3b:	e8 ab 83 ff ff       	call   c0100deb <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108a40:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108a47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a4a:	89 d0                	mov    %edx,%eax
c0108a4c:	c1 e0 02             	shl    $0x2,%eax
c0108a4f:	01 d0                	add    %edx,%eax
c0108a51:	01 c0                	add    %eax,%eax
c0108a53:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i--) {
c0108a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a5c:	eb 6f                	jmp    c0108acd <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a61:	89 d0                	mov    %edx,%eax
c0108a63:	c1 e0 02             	shl    $0x2,%eax
c0108a66:	01 d0                	add    %edx,%eax
c0108a68:	83 c0 02             	add    $0x2,%eax
c0108a6b:	89 c1                	mov    %eax,%ecx
c0108a6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a70:	89 d0                	mov    %edx,%eax
c0108a72:	c1 e0 02             	shl    $0x2,%eax
c0108a75:	01 d0                	add    %edx,%eax
c0108a77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108a7e:	00 
c0108a7f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108a83:	89 04 24             	mov    %eax,(%esp)
c0108a86:	e8 2a f8 ff ff       	call   c01082b5 <vma_create>
c0108a8b:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0108a8e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108a92:	75 24                	jne    c0108ab8 <check_vma_struct+0xb8>
c0108a94:	c7 44 24 0c 2c de 10 	movl   $0xc010de2c,0xc(%esp)
c0108a9b:	c0 
c0108a9c:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108aa3:	c0 
c0108aa4:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0108aab:	00 
c0108aac:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108ab3:	e8 33 83 ff ff       	call   c0100deb <__panic>
        insert_vma_struct(mm, vma);
c0108ab8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108abb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108abf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ac2:	89 04 24             	mov    %eax,(%esp)
c0108ac5:	e8 82 f9 ff ff       	call   c010844c <insert_vma_struct>
    for (i = step1; i >= 1; i--) {
c0108aca:	ff 4d f4             	decl   -0xc(%ebp)
c0108acd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108ad1:	7f 8b                	jg     c0108a5e <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i++) {
c0108ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ad6:	40                   	inc    %eax
c0108ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ada:	eb 6f                	jmp    c0108b4b <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108adf:	89 d0                	mov    %edx,%eax
c0108ae1:	c1 e0 02             	shl    $0x2,%eax
c0108ae4:	01 d0                	add    %edx,%eax
c0108ae6:	83 c0 02             	add    $0x2,%eax
c0108ae9:	89 c1                	mov    %eax,%ecx
c0108aeb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108aee:	89 d0                	mov    %edx,%eax
c0108af0:	c1 e0 02             	shl    $0x2,%eax
c0108af3:	01 d0                	add    %edx,%eax
c0108af5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108afc:	00 
c0108afd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108b01:	89 04 24             	mov    %eax,(%esp)
c0108b04:	e8 ac f7 ff ff       	call   c01082b5 <vma_create>
c0108b09:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0108b0c:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108b10:	75 24                	jne    c0108b36 <check_vma_struct+0x136>
c0108b12:	c7 44 24 0c 2c de 10 	movl   $0xc010de2c,0xc(%esp)
c0108b19:	c0 
c0108b1a:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108b21:	c0 
c0108b22:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0108b29:	00 
c0108b2a:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108b31:	e8 b5 82 ff ff       	call   c0100deb <__panic>
        insert_vma_struct(mm, vma);
c0108b36:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108b39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b40:	89 04 24             	mov    %eax,(%esp)
c0108b43:	e8 04 f9 ff ff       	call   c010844c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++) {
c0108b48:	ff 45 f4             	incl   -0xc(%ebp)
c0108b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b4e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108b51:	7e 89                	jle    c0108adc <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108b53:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b56:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0108b59:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0108b5c:	8b 40 04             	mov    0x4(%eax),%eax
c0108b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i++) {
c0108b62:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0108b69:	e9 96 00 00 00       	jmp    c0108c04 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0108b6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b71:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108b74:	75 24                	jne    c0108b9a <check_vma_struct+0x19a>
c0108b76:	c7 44 24 0c 38 de 10 	movl   $0xc010de38,0xc(%esp)
c0108b7d:	c0 
c0108b7e:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108b85:	c0 
c0108b86:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0108b8d:	00 
c0108b8e:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108b95:	e8 51 82 ff ff       	call   c0100deb <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0108b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b9d:	83 e8 10             	sub    $0x10,%eax
c0108ba0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0108ba3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108ba6:	8b 48 04             	mov    0x4(%eax),%ecx
c0108ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108bac:	89 d0                	mov    %edx,%eax
c0108bae:	c1 e0 02             	shl    $0x2,%eax
c0108bb1:	01 d0                	add    %edx,%eax
c0108bb3:	39 c1                	cmp    %eax,%ecx
c0108bb5:	75 17                	jne    c0108bce <check_vma_struct+0x1ce>
c0108bb7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0108bba:	8b 48 08             	mov    0x8(%eax),%ecx
c0108bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108bc0:	89 d0                	mov    %edx,%eax
c0108bc2:	c1 e0 02             	shl    $0x2,%eax
c0108bc5:	01 d0                	add    %edx,%eax
c0108bc7:	83 c0 02             	add    $0x2,%eax
c0108bca:	39 c1                	cmp    %eax,%ecx
c0108bcc:	74 24                	je     c0108bf2 <check_vma_struct+0x1f2>
c0108bce:	c7 44 24 0c 50 de 10 	movl   $0xc010de50,0xc(%esp)
c0108bd5:	c0 
c0108bd6:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108bdd:	c0 
c0108bde:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0108be5:	00 
c0108be6:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108bed:	e8 f9 81 ff ff       	call   c0100deb <__panic>
c0108bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bf5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0108bf8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108bfb:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i++) {
c0108c01:	ff 45 f4             	incl   -0xc(%ebp)
c0108c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c07:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108c0a:	0f 8e 5e ff ff ff    	jle    c0108b6e <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i += 5) {
c0108c10:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0108c17:	e9 cb 01 00 00       	jmp    c0108de7 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c26:	89 04 24             	mov    %eax,(%esp)
c0108c29:	e8 c4 f6 ff ff       	call   c01082f2 <find_vma>
c0108c2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0108c31:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108c35:	75 24                	jne    c0108c5b <check_vma_struct+0x25b>
c0108c37:	c7 44 24 0c 85 de 10 	movl   $0xc010de85,0xc(%esp)
c0108c3e:	c0 
c0108c3f:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108c46:	c0 
c0108c47:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0108c4e:	00 
c0108c4f:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108c56:	e8 90 81 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
c0108c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c5e:	40                   	inc    %eax
c0108c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c63:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c66:	89 04 24             	mov    %eax,(%esp)
c0108c69:	e8 84 f6 ff ff       	call   c01082f2 <find_vma>
c0108c6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0108c71:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0108c75:	75 24                	jne    c0108c9b <check_vma_struct+0x29b>
c0108c77:	c7 44 24 0c 92 de 10 	movl   $0xc010de92,0xc(%esp)
c0108c7e:	c0 
c0108c7f:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108c86:	c0 
c0108c87:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0108c8e:	00 
c0108c8f:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108c96:	e8 50 81 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
c0108c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c9e:	83 c0 02             	add    $0x2,%eax
c0108ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ca8:	89 04 24             	mov    %eax,(%esp)
c0108cab:	e8 42 f6 ff ff       	call   c01082f2 <find_vma>
c0108cb0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0108cb3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0108cb7:	74 24                	je     c0108cdd <check_vma_struct+0x2dd>
c0108cb9:	c7 44 24 0c 9f de 10 	movl   $0xc010de9f,0xc(%esp)
c0108cc0:	c0 
c0108cc1:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108cc8:	c0 
c0108cc9:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0108cd0:	00 
c0108cd1:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108cd8:	e8 0e 81 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
c0108cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ce0:	83 c0 03             	add    $0x3,%eax
c0108ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cea:	89 04 24             	mov    %eax,(%esp)
c0108ced:	e8 00 f6 ff ff       	call   c01082f2 <find_vma>
c0108cf2:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0108cf5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108cf9:	74 24                	je     c0108d1f <check_vma_struct+0x31f>
c0108cfb:	c7 44 24 0c ac de 10 	movl   $0xc010deac,0xc(%esp)
c0108d02:	c0 
c0108d03:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108d0a:	c0 
c0108d0b:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0108d12:	00 
c0108d13:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108d1a:	e8 cc 80 ff ff       	call   c0100deb <__panic>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
c0108d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d22:	83 c0 04             	add    $0x4,%eax
c0108d25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d29:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d2c:	89 04 24             	mov    %eax,(%esp)
c0108d2f:	e8 be f5 ff ff       	call   c01082f2 <find_vma>
c0108d34:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0108d37:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0108d3b:	74 24                	je     c0108d61 <check_vma_struct+0x361>
c0108d3d:	c7 44 24 0c b9 de 10 	movl   $0xc010deb9,0xc(%esp)
c0108d44:	c0 
c0108d45:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108d4c:	c0 
c0108d4d:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c0108d54:	00 
c0108d55:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108d5c:	e8 8a 80 ff ff       	call   c0100deb <__panic>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
c0108d61:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d64:	8b 50 04             	mov    0x4(%eax),%edx
c0108d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d6a:	39 c2                	cmp    %eax,%edx
c0108d6c:	75 10                	jne    c0108d7e <check_vma_struct+0x37e>
c0108d6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d71:	8b 40 08             	mov    0x8(%eax),%eax
c0108d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d77:	83 c2 02             	add    $0x2,%edx
c0108d7a:	39 d0                	cmp    %edx,%eax
c0108d7c:	74 24                	je     c0108da2 <check_vma_struct+0x3a2>
c0108d7e:	c7 44 24 0c c8 de 10 	movl   $0xc010dec8,0xc(%esp)
c0108d85:	c0 
c0108d86:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108d8d:	c0 
c0108d8e:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108d95:	00 
c0108d96:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108d9d:	e8 49 80 ff ff       	call   c0100deb <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
c0108da2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108da5:	8b 50 04             	mov    0x4(%eax),%edx
c0108da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108dab:	39 c2                	cmp    %eax,%edx
c0108dad:	75 10                	jne    c0108dbf <check_vma_struct+0x3bf>
c0108daf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108db2:	8b 40 08             	mov    0x8(%eax),%eax
c0108db5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108db8:	83 c2 02             	add    $0x2,%edx
c0108dbb:	39 d0                	cmp    %edx,%eax
c0108dbd:	74 24                	je     c0108de3 <check_vma_struct+0x3e3>
c0108dbf:	c7 44 24 0c f8 de 10 	movl   $0xc010def8,0xc(%esp)
c0108dc6:	c0 
c0108dc7:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108dce:	c0 
c0108dcf:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0108dd6:	00 
c0108dd7:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108dde:	e8 08 80 ff ff       	call   c0100deb <__panic>
    for (i = 5; i <= 5 * step2; i += 5) {
c0108de3:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108de7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108dea:	89 d0                	mov    %edx,%eax
c0108dec:	c1 e0 02             	shl    $0x2,%eax
c0108def:	01 d0                	add    %edx,%eax
c0108df1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0108df4:	0f 8e 22 fe ff ff    	jle    c0108c1c <check_vma_struct+0x21c>
    }

    for (i = 4; i >= 0; i--) {
c0108dfa:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108e01:	eb 6f                	jmp    c0108e72 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5 = find_vma(mm, i);
c0108e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e06:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e0d:	89 04 24             	mov    %eax,(%esp)
c0108e10:	e8 dd f4 ff ff       	call   c01082f2 <find_vma>
c0108e15:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL) {
c0108e18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108e1c:	74 27                	je     c0108e45 <check_vma_struct+0x445>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
c0108e1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e21:	8b 50 08             	mov    0x8(%eax),%edx
c0108e24:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e27:	8b 40 04             	mov    0x4(%eax),%eax
c0108e2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108e2e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e39:	c7 04 24 28 df 10 c0 	movl   $0xc010df28,(%esp)
c0108e40:	e8 28 75 ff ff       	call   c010036d <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108e45:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108e49:	74 24                	je     c0108e6f <check_vma_struct+0x46f>
c0108e4b:	c7 44 24 0c 4d df 10 	movl   $0xc010df4d,0xc(%esp)
c0108e52:	c0 
c0108e53:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108e5a:	c0 
c0108e5b:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0108e62:	00 
c0108e63:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108e6a:	e8 7c 7f ff ff       	call   c0100deb <__panic>
    for (i = 4; i >= 0; i--) {
c0108e6f:	ff 4d f4             	decl   -0xc(%ebp)
c0108e72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108e76:	79 8b                	jns    c0108e03 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0108e78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e7b:	89 04 24             	mov    %eax,(%esp)
c0108e7e:	e8 ff f6 ff ff       	call   c0108582 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108e83:	c7 04 24 64 df 10 c0 	movl   $0xc010df64,(%esp)
c0108e8a:	e8 de 74 ff ff       	call   c010036d <cprintf>
}
c0108e8f:	90                   	nop
c0108e90:	89 ec                	mov    %ebp,%esp
c0108e92:	5d                   	pop    %ebp
c0108e93:	c3                   	ret    

c0108e94 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108e94:	55                   	push   %ebp
c0108e95:	89 e5                	mov    %esp,%ebp
c0108e97:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108e9a:	e8 43 c5 ff ff       	call   c01053e2 <nr_free_pages>
c0108e9f:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108ea2:	e8 72 f3 ff ff       	call   c0108219 <mm_create>
c0108ea7:	a3 0c 41 1a c0       	mov    %eax,0xc01a410c
    assert(check_mm_struct != NULL);
c0108eac:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0108eb1:	85 c0                	test   %eax,%eax
c0108eb3:	75 24                	jne    c0108ed9 <check_pgfault+0x45>
c0108eb5:	c7 44 24 0c 83 df 10 	movl   $0xc010df83,0xc(%esp)
c0108ebc:	c0 
c0108ebd:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108ec4:	c0 
c0108ec5:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
c0108ecc:	00 
c0108ecd:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108ed4:	e8 12 7f ff ff       	call   c0100deb <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108ed9:	a1 0c 41 1a c0       	mov    0xc01a410c,%eax
c0108ede:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108ee1:	8b 15 00 fa 12 c0    	mov    0xc012fa00,%edx
c0108ee7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108eea:	89 50 0c             	mov    %edx,0xc(%eax)
c0108eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ef0:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ef3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108ef6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ef9:	8b 00                	mov    (%eax),%eax
c0108efb:	85 c0                	test   %eax,%eax
c0108efd:	74 24                	je     c0108f23 <check_pgfault+0x8f>
c0108eff:	c7 44 24 0c 9b df 10 	movl   $0xc010df9b,0xc(%esp)
c0108f06:	c0 
c0108f07:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108f0e:	c0 
c0108f0f:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0108f16:	00 
c0108f17:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108f1e:	e8 c8 7e ff ff       	call   c0100deb <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108f23:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108f2a:	00 
c0108f2b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108f32:	00 
c0108f33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108f3a:	e8 76 f3 ff ff       	call   c01082b5 <vma_create>
c0108f3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108f42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108f46:	75 24                	jne    c0108f6c <check_pgfault+0xd8>
c0108f48:	c7 44 24 0c 2c de 10 	movl   $0xc010de2c,0xc(%esp)
c0108f4f:	c0 
c0108f50:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108f57:	c0 
c0108f58:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0108f5f:	00 
c0108f60:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108f67:	e8 7f 7e ff ff       	call   c0100deb <__panic>

    insert_vma_struct(mm, vma);
c0108f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f76:	89 04 24             	mov    %eax,(%esp)
c0108f79:	e8 ce f4 ff ff       	call   c010844c <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108f7e:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108f85:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f8f:	89 04 24             	mov    %eax,(%esp)
c0108f92:	e8 5b f3 ff ff       	call   c01082f2 <find_vma>
c0108f97:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108f9a:	74 24                	je     c0108fc0 <check_pgfault+0x12c>
c0108f9c:	c7 44 24 0c a9 df 10 	movl   $0xc010dfa9,0xc(%esp)
c0108fa3:	c0 
c0108fa4:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0108fab:	c0 
c0108fac:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0108fb3:	00 
c0108fb4:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0108fbb:	e8 2b 7e ff ff       	call   c0100deb <__panic>

    int i, sum = 0;
c0108fc0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c0108fc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108fce:	eb 16                	jmp    c0108fe6 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0108fd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fd6:	01 d0                	add    %edx,%eax
c0108fd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fdb:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fe0:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c0108fe3:	ff 45 f4             	incl   -0xc(%ebp)
c0108fe6:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108fea:	7e e4                	jle    c0108fd0 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i++) {
c0108fec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ff3:	eb 14                	jmp    c0109009 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0108ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ff8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108ffb:	01 d0                	add    %edx,%eax
c0108ffd:	0f b6 00             	movzbl (%eax),%eax
c0109000:	0f be c0             	movsbl %al,%eax
c0109003:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i++) {
c0109006:	ff 45 f4             	incl   -0xc(%ebp)
c0109009:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010900d:	7e e6                	jle    c0108ff5 <check_pgfault+0x161>
    }
    assert(sum == 0);
c010900f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109013:	74 24                	je     c0109039 <check_pgfault+0x1a5>
c0109015:	c7 44 24 0c c3 df 10 	movl   $0xc010dfc3,0xc(%esp)
c010901c:	c0 
c010901d:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c0109024:	c0 
c0109025:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c010902c:	00 
c010902d:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c0109034:	e8 b2 7d ff ff       	call   c0100deb <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0109039:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010903c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010903f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109042:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109047:	89 44 24 04          	mov    %eax,0x4(%esp)
c010904b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010904e:	89 04 24             	mov    %eax,(%esp)
c0109051:	e8 72 cf ff ff       	call   c0105fc8 <page_remove>
    free_page(pde2page(pgdir[0]));
c0109056:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109059:	8b 00                	mov    (%eax),%eax
c010905b:	89 04 24             	mov    %eax,(%esp)
c010905e:	e8 73 f1 ff ff       	call   c01081d6 <pde2page>
c0109063:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010906a:	00 
c010906b:	89 04 24             	mov    %eax,(%esp)
c010906e:	e8 3a c3 ff ff       	call   c01053ad <free_pages>
    pgdir[0] = 0;
c0109073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109076:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010907c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010907f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0109086:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109089:	89 04 24             	mov    %eax,(%esp)
c010908c:	e8 f1 f4 ff ff       	call   c0108582 <mm_destroy>
    check_mm_struct = NULL;
c0109091:	c7 05 0c 41 1a c0 00 	movl   $0x0,0xc01a410c
c0109098:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c010909b:	e8 42 c3 ff ff       	call   c01053e2 <nr_free_pages>
c01090a0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01090a3:	74 24                	je     c01090c9 <check_pgfault+0x235>
c01090a5:	c7 44 24 0c cc df 10 	movl   $0xc010dfcc,0xc(%esp)
c01090ac:	c0 
c01090ad:	c7 44 24 08 3b dd 10 	movl   $0xc010dd3b,0x8(%esp)
c01090b4:	c0 
c01090b5:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c01090bc:	00 
c01090bd:	c7 04 24 50 dd 10 c0 	movl   $0xc010dd50,(%esp)
c01090c4:	e8 22 7d ff ff       	call   c0100deb <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01090c9:	c7 04 24 f3 df 10 c0 	movl   $0xc010dff3,(%esp)
c01090d0:	e8 98 72 ff ff       	call   c010036d <cprintf>
}
c01090d5:	90                   	nop
c01090d6:	89 ec                	mov    %ebp,%esp
c01090d8:	5d                   	pop    %ebp
c01090d9:	c3                   	ret    

c01090da <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01090da:	55                   	push   %ebp
c01090db:	89 e5                	mov    %esp,%ebp
c01090dd:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c01090e0:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01090e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01090ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01090f1:	89 04 24             	mov    %eax,(%esp)
c01090f4:	e8 f9 f1 ff ff       	call   c01082f2 <find_vma>
c01090f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pgfault_num++;
c01090fc:	a1 10 41 1a c0       	mov    0xc01a4110,%eax
c0109101:	40                   	inc    %eax
c0109102:	a3 10 41 1a c0       	mov    %eax,0xc01a4110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0109107:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010910b:	74 0b                	je     c0109118 <do_pgfault+0x3e>
c010910d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109110:	8b 40 04             	mov    0x4(%eax),%eax
c0109113:	39 45 10             	cmp    %eax,0x10(%ebp)
c0109116:	73 18                	jae    c0109130 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0109118:	8b 45 10             	mov    0x10(%ebp),%eax
c010911b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010911f:	c7 04 24 10 e0 10 c0 	movl   $0xc010e010,(%esp)
c0109126:	e8 42 72 ff ff       	call   c010036d <cprintf>
        goto failed;
c010912b:	e9 a3 01 00 00       	jmp    c01092d3 <do_pgfault+0x1f9>
    }
    //check the error_code
    switch (error_code & 3) {
c0109130:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109133:	83 e0 03             	and    $0x3,%eax
c0109136:	85 c0                	test   %eax,%eax
c0109138:	74 34                	je     c010916e <do_pgfault+0x94>
c010913a:	83 f8 01             	cmp    $0x1,%eax
c010913d:	74 1e                	je     c010915d <do_pgfault+0x83>
        default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
        case 2: /* error code flag : (W/R=1, P=0): write, not present */
            if (!(vma->vm_flags & VM_WRITE)) {
c010913f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109142:	8b 40 0c             	mov    0xc(%eax),%eax
c0109145:	83 e0 02             	and    $0x2,%eax
c0109148:	85 c0                	test   %eax,%eax
c010914a:	75 40                	jne    c010918c <do_pgfault+0xb2>
                cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010914c:	c7 04 24 40 e0 10 c0 	movl   $0xc010e040,(%esp)
c0109153:	e8 15 72 ff ff       	call   c010036d <cprintf>
                goto failed;
c0109158:	e9 76 01 00 00       	jmp    c01092d3 <do_pgfault+0x1f9>
            }
            break;
        case 1: /* error code flag : (W/R=0, P=1): read, present */
            cprintf("do_pgfault failed: error code flag = read AND present\n");
c010915d:	c7 04 24 a0 e0 10 c0 	movl   $0xc010e0a0,(%esp)
c0109164:	e8 04 72 ff ff       	call   c010036d <cprintf>
            goto failed;
c0109169:	e9 65 01 00 00       	jmp    c01092d3 <do_pgfault+0x1f9>
        case 0: /* error code flag : (W/R=0, P=0): read, not present */
            if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010916e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109171:	8b 40 0c             	mov    0xc(%eax),%eax
c0109174:	83 e0 05             	and    $0x5,%eax
c0109177:	85 c0                	test   %eax,%eax
c0109179:	75 12                	jne    c010918d <do_pgfault+0xb3>
                cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010917b:	c7 04 24 d8 e0 10 c0 	movl   $0xc010e0d8,(%esp)
c0109182:	e8 e6 71 ff ff       	call   c010036d <cprintf>
                goto failed;
c0109187:	e9 47 01 00 00       	jmp    c01092d3 <do_pgfault+0x1f9>
            break;
c010918c:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c010918d:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0109194:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109197:	8b 40 0c             	mov    0xc(%eax),%eax
c010919a:	83 e0 02             	and    $0x2,%eax
c010919d:	85 c0                	test   %eax,%eax
c010919f:	74 04                	je     c01091a5 <do_pgfault+0xcb>
        perm |= PTE_W;
c01091a1:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01091a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01091a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01091ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01091b3:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01091b6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep = NULL;
c01091bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
#if 1
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
c01091c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01091c7:	8b 40 0c             	mov    0xc(%eax),%eax
c01091ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01091d1:	00 
c01091d2:	8b 55 10             	mov    0x10(%ebp),%edx
c01091d5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01091d9:	89 04 24             	mov    %eax,(%esp)
c01091dc:	e8 1a c8 ff ff       	call   c01059fb <get_pte>
c01091e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (*ptep == 0) {
c01091e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01091e7:	8b 00                	mov    (%eax),%eax
c01091e9:	85 c0                	test   %eax,%eax
c01091eb:	75 35                	jne    c0109222 <do_pgfault+0x148>
        //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01091ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01091f0:	8b 40 0c             	mov    0xc(%eax),%eax
c01091f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01091f6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01091fa:	8b 55 10             	mov    0x10(%ebp),%edx
c01091fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109201:	89 04 24             	mov    %eax,(%esp)
c0109204:	e8 20 cf ff ff       	call   c0106129 <pgdir_alloc_page>
c0109209:	85 c0                	test   %eax,%eax
c010920b:	0f 85 bb 00 00 00    	jne    c01092cc <do_pgfault+0x1f2>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0109211:	c7 04 24 3c e1 10 c0 	movl   $0xc010e13c,(%esp)
c0109218:	e8 50 71 ff ff       	call   c010036d <cprintf>
            goto failed;
c010921d:	e9 b1 00 00 00       	jmp    c01092d3 <do_pgfault+0x1f9>
		     If the vma includes this addr is writable, then we can set the page writable by rewrite the *ptep.
		     This method could be used to implement the Copy on Write (COW) thchnology(a fast fork process method).
		  2) *ptep & PTE_P == 0 & but *ptep!=0, it means this pte is a  swap entry.
		     We should add the LAB3's results here.
     */
        if (swap_init_ok) {
c0109222:	a1 44 40 1a c0       	mov    0xc01a4044,%eax
c0109227:	85 c0                	test   %eax,%eax
c0109229:	0f 84 86 00 00 00    	je     c01092b5 <do_pgfault+0x1db>
            struct Page *page = NULL;
c010922f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            //(1）According to the mm AND addr, try to load the content of right disk page
            //    into the memory which page managed.
            //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            //(3) make the page swappable.
            //(4) [NOTICE]: you myabe need to update your lab3's implementation for LAB5's normal execution.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0109236:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0109239:	89 44 24 08          	mov    %eax,0x8(%esp)
c010923d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109240:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109244:	8b 45 08             	mov    0x8(%ebp),%eax
c0109247:	89 04 24             	mov    %eax,(%esp)
c010924a:	e8 88 df ff ff       	call   c01071d7 <swap_in>
c010924f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109252:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109256:	74 0e                	je     c0109266 <do_pgfault+0x18c>
                cprintf("swap_in in do_pgfault failed\n");
c0109258:	c7 04 24 63 e1 10 c0 	movl   $0xc010e163,(%esp)
c010925f:	e8 09 71 ff ff       	call   c010036d <cprintf>
c0109264:	eb 6d                	jmp    c01092d3 <do_pgfault+0x1f9>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c0109266:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109269:	8b 45 08             	mov    0x8(%ebp),%eax
c010926c:	8b 40 0c             	mov    0xc(%eax),%eax
c010926f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109272:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0109276:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0109279:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010927d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109281:	89 04 24             	mov    %eax,(%esp)
c0109284:	e8 86 cd ff ff       	call   c010600f <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0109289:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010928c:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0109293:	00 
c0109294:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109298:	8b 45 10             	mov    0x10(%ebp),%eax
c010929b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010929f:	8b 45 08             	mov    0x8(%ebp),%eax
c01092a2:	89 04 24             	mov    %eax,(%esp)
c01092a5:	e8 65 dd ff ff       	call   c010700f <swap_map_swappable>
            page->pra_vaddr = addr;
c01092aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01092ad:	8b 55 10             	mov    0x10(%ebp),%edx
c01092b0:	89 50 1c             	mov    %edx,0x1c(%eax)
c01092b3:	eb 17                	jmp    c01092cc <do_pgfault+0x1f2>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
c01092b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01092b8:	8b 00                	mov    (%eax),%eax
c01092ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01092be:	c7 04 24 84 e1 10 c0 	movl   $0xc010e184,(%esp)
c01092c5:	e8 a3 70 ff ff       	call   c010036d <cprintf>
            goto failed;
c01092ca:	eb 07                	jmp    c01092d3 <do_pgfault+0x1f9>
        }
    }
#endif
    ret = 0;
c01092cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01092d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01092d6:	89 ec                	mov    %ebp,%esp
c01092d8:	5d                   	pop    %ebp
c01092d9:	c3                   	ret    

c01092da <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c01092da:	55                   	push   %ebp
c01092db:	89 e5                	mov    %esp,%ebp
c01092dd:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c01092e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01092e4:	0f 84 e0 00 00 00    	je     c01093ca <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c01092ea:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c01092f1:	76 1c                	jbe    c010930f <user_mem_check+0x35>
c01092f3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092f6:	8b 45 10             	mov    0x10(%ebp),%eax
c01092f9:	01 d0                	add    %edx,%eax
c01092fb:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01092fe:	73 0f                	jae    c010930f <user_mem_check+0x35>
c0109300:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109303:	8b 45 10             	mov    0x10(%ebp),%eax
c0109306:	01 d0                	add    %edx,%eax
c0109308:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c010930d:	76 0a                	jbe    c0109319 <user_mem_check+0x3f>
            return 0;
c010930f:	b8 00 00 00 00       	mov    $0x0,%eax
c0109314:	e9 e2 00 00 00       	jmp    c01093fb <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0109319:	8b 45 0c             	mov    0xc(%ebp),%eax
c010931c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010931f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109322:	8b 45 10             	mov    0x10(%ebp),%eax
c0109325:	01 d0                	add    %edx,%eax
c0109327:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c010932a:	e9 88 00 00 00       	jmp    c01093b7 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c010932f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109332:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109336:	8b 45 08             	mov    0x8(%ebp),%eax
c0109339:	89 04 24             	mov    %eax,(%esp)
c010933c:	e8 b1 ef ff ff       	call   c01082f2 <find_vma>
c0109341:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109344:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109348:	74 0b                	je     c0109355 <user_mem_check+0x7b>
c010934a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010934d:	8b 40 04             	mov    0x4(%eax),%eax
c0109350:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0109353:	73 0a                	jae    c010935f <user_mem_check+0x85>
                return 0;
c0109355:	b8 00 00 00 00       	mov    $0x0,%eax
c010935a:	e9 9c 00 00 00       	jmp    c01093fb <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c010935f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109362:	8b 40 0c             	mov    0xc(%eax),%eax
c0109365:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109369:	74 07                	je     c0109372 <user_mem_check+0x98>
c010936b:	ba 02 00 00 00       	mov    $0x2,%edx
c0109370:	eb 05                	jmp    c0109377 <user_mem_check+0x9d>
c0109372:	ba 01 00 00 00       	mov    $0x1,%edx
c0109377:	21 d0                	and    %edx,%eax
c0109379:	85 c0                	test   %eax,%eax
c010937b:	75 07                	jne    c0109384 <user_mem_check+0xaa>
                return 0;
c010937d:	b8 00 00 00 00       	mov    $0x0,%eax
c0109382:	eb 77                	jmp    c01093fb <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c0109384:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0109388:	74 24                	je     c01093ae <user_mem_check+0xd4>
c010938a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010938d:	8b 40 0c             	mov    0xc(%eax),%eax
c0109390:	83 e0 08             	and    $0x8,%eax
c0109393:	85 c0                	test   %eax,%eax
c0109395:	74 17                	je     c01093ae <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) {  //check stack start & size
c0109397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010939a:	8b 40 04             	mov    0x4(%eax),%eax
c010939d:	05 00 10 00 00       	add    $0x1000,%eax
c01093a2:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c01093a5:	73 07                	jae    c01093ae <user_mem_check+0xd4>
                    return 0;
c01093a7:	b8 00 00 00 00       	mov    $0x0,%eax
c01093ac:	eb 4d                	jmp    c01093fb <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c01093ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093b1:	8b 40 08             	mov    0x8(%eax),%eax
c01093b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < end) {
c01093b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01093ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01093bd:	0f 82 6c ff ff ff    	jb     c010932f <user_mem_check+0x55>
        }
        return 1;
c01093c3:	b8 01 00 00 00       	mov    $0x1,%eax
c01093c8:	eb 31                	jmp    c01093fb <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c01093ca:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c01093d1:	76 23                	jbe    c01093f6 <user_mem_check+0x11c>
c01093d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01093d9:	01 d0                	add    %edx,%eax
c01093db:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01093de:	73 16                	jae    c01093f6 <user_mem_check+0x11c>
c01093e0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01093e3:	8b 45 10             	mov    0x10(%ebp),%eax
c01093e6:	01 d0                	add    %edx,%eax
c01093e8:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c01093ed:	77 07                	ja     c01093f6 <user_mem_check+0x11c>
c01093ef:	b8 01 00 00 00       	mov    $0x1,%eax
c01093f4:	eb 05                	jmp    c01093fb <user_mem_check+0x121>
c01093f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01093fb:	89 ec                	mov    %ebp,%esp
c01093fd:	5d                   	pop    %ebp
c01093fe:	c3                   	ret    

c01093ff <page2ppn>:
page2ppn(struct Page *page) {
c01093ff:	55                   	push   %ebp
c0109400:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109402:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0109408:	8b 45 08             	mov    0x8(%ebp),%eax
c010940b:	29 d0                	sub    %edx,%eax
c010940d:	c1 f8 05             	sar    $0x5,%eax
}
c0109410:	5d                   	pop    %ebp
c0109411:	c3                   	ret    

c0109412 <page2pa>:
page2pa(struct Page *page) {
c0109412:	55                   	push   %ebp
c0109413:	89 e5                	mov    %esp,%ebp
c0109415:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109418:	8b 45 08             	mov    0x8(%ebp),%eax
c010941b:	89 04 24             	mov    %eax,(%esp)
c010941e:	e8 dc ff ff ff       	call   c01093ff <page2ppn>
c0109423:	c1 e0 0c             	shl    $0xc,%eax
}
c0109426:	89 ec                	mov    %ebp,%esp
c0109428:	5d                   	pop    %ebp
c0109429:	c3                   	ret    

c010942a <page2kva>:
page2kva(struct Page *page) {
c010942a:	55                   	push   %ebp
c010942b:	89 e5                	mov    %esp,%ebp
c010942d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109430:	8b 45 08             	mov    0x8(%ebp),%eax
c0109433:	89 04 24             	mov    %eax,(%esp)
c0109436:	e8 d7 ff ff ff       	call   c0109412 <page2pa>
c010943b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010943e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109441:	c1 e8 0c             	shr    $0xc,%eax
c0109444:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109447:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010944c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010944f:	72 23                	jb     c0109474 <page2kva+0x4a>
c0109451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109454:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109458:	c7 44 24 08 ac e1 10 	movl   $0xc010e1ac,0x8(%esp)
c010945f:	c0 
c0109460:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109467:	00 
c0109468:	c7 04 24 cf e1 10 c0 	movl   $0xc010e1cf,(%esp)
c010946f:	e8 77 79 ff ff       	call   c0100deb <__panic>
c0109474:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109477:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010947c:	89 ec                	mov    %ebp,%esp
c010947e:	5d                   	pop    %ebp
c010947f:	c3                   	ret    

c0109480 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109480:	55                   	push   %ebp
c0109481:	89 e5                	mov    %esp,%ebp
c0109483:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109486:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010948d:	e8 08 87 ff ff       	call   c0101b9a <ide_device_valid>
c0109492:	85 c0                	test   %eax,%eax
c0109494:	75 1c                	jne    c01094b2 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109496:	c7 44 24 08 dd e1 10 	movl   $0xc010e1dd,0x8(%esp)
c010949d:	c0 
c010949e:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01094a5:	00 
c01094a6:	c7 04 24 f7 e1 10 c0 	movl   $0xc010e1f7,(%esp)
c01094ad:	e8 39 79 ff ff       	call   c0100deb <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01094b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01094b9:	e8 1c 87 ff ff       	call   c0101bda <ide_device_size>
c01094be:	c1 e8 03             	shr    $0x3,%eax
c01094c1:	a3 40 40 1a c0       	mov    %eax,0xc01a4040
}
c01094c6:	90                   	nop
c01094c7:	89 ec                	mov    %ebp,%esp
c01094c9:	5d                   	pop    %ebp
c01094ca:	c3                   	ret    

c01094cb <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01094cb:	55                   	push   %ebp
c01094cc:	89 e5                	mov    %esp,%ebp
c01094ce:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01094d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094d4:	89 04 24             	mov    %eax,(%esp)
c01094d7:	e8 4e ff ff ff       	call   c010942a <page2kva>
c01094dc:	8b 55 08             	mov    0x8(%ebp),%edx
c01094df:	c1 ea 08             	shr    $0x8,%edx
c01094e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01094e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01094e9:	74 0b                	je     c01094f6 <swapfs_read+0x2b>
c01094eb:	8b 15 40 40 1a c0    	mov    0xc01a4040,%edx
c01094f1:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01094f4:	72 23                	jb     c0109519 <swapfs_read+0x4e>
c01094f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01094f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094fd:	c7 44 24 08 08 e2 10 	movl   $0xc010e208,0x8(%esp)
c0109504:	c0 
c0109505:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c010950c:	00 
c010950d:	c7 04 24 f7 e1 10 c0 	movl   $0xc010e1f7,(%esp)
c0109514:	e8 d2 78 ff ff       	call   c0100deb <__panic>
c0109519:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010951c:	c1 e2 03             	shl    $0x3,%edx
c010951f:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109526:	00 
c0109527:	89 44 24 08          	mov    %eax,0x8(%esp)
c010952b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010952f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109536:	e8 dc 86 ff ff       	call   c0101c17 <ide_read_secs>
}
c010953b:	89 ec                	mov    %ebp,%esp
c010953d:	5d                   	pop    %ebp
c010953e:	c3                   	ret    

c010953f <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c010953f:	55                   	push   %ebp
c0109540:	89 e5                	mov    %esp,%ebp
c0109542:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109548:	89 04 24             	mov    %eax,(%esp)
c010954b:	e8 da fe ff ff       	call   c010942a <page2kva>
c0109550:	8b 55 08             	mov    0x8(%ebp),%edx
c0109553:	c1 ea 08             	shr    $0x8,%edx
c0109556:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109559:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010955d:	74 0b                	je     c010956a <swapfs_write+0x2b>
c010955f:	8b 15 40 40 1a c0    	mov    0xc01a4040,%edx
c0109565:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109568:	72 23                	jb     c010958d <swapfs_write+0x4e>
c010956a:	8b 45 08             	mov    0x8(%ebp),%eax
c010956d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109571:	c7 44 24 08 08 e2 10 	movl   $0xc010e208,0x8(%esp)
c0109578:	c0 
c0109579:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0109580:	00 
c0109581:	c7 04 24 f7 e1 10 c0 	movl   $0xc010e1f7,(%esp)
c0109588:	e8 5e 78 ff ff       	call   c0100deb <__panic>
c010958d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109590:	c1 e2 03             	shl    $0x3,%edx
c0109593:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010959a:	00 
c010959b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010959f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01095a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01095aa:	e8 a9 88 ff ff       	call   c0101e58 <ide_write_secs>
}
c01095af:	89 ec                	mov    %ebp,%esp
c01095b1:	5d                   	pop    %ebp
c01095b2:	c3                   	ret    

c01095b3 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	# just like the preparation before the execution of int main(arg)
	# and save the return value of main on stack (by `return 0;` statement)	
    pushl %edx              # push arg
c01095b3:	52                   	push   %edx
    call *%ebx              # call fn
c01095b4:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01095b6:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01095b7:	e8 8f 0c 00 00       	call   c010a24b <do_exit>

c01095bc <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01095bc:	55                   	push   %ebp
c01095bd:	89 e5                	mov    %esp,%ebp
c01095bf:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01095c2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01095c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c8:	0f ab 02             	bts    %eax,(%edx)
c01095cb:	19 c0                	sbb    %eax,%eax
c01095cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01095d0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01095d4:	0f 95 c0             	setne  %al
c01095d7:	0f b6 c0             	movzbl %al,%eax
}
c01095da:	89 ec                	mov    %ebp,%esp
c01095dc:	5d                   	pop    %ebp
c01095dd:	c3                   	ret    

c01095de <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01095de:	55                   	push   %ebp
c01095df:	89 e5                	mov    %esp,%ebp
c01095e1:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01095e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01095e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01095ea:	0f b3 02             	btr    %eax,(%edx)
c01095ed:	19 c0                	sbb    %eax,%eax
c01095ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01095f2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01095f6:	0f 95 c0             	setne  %al
c01095f9:	0f b6 c0             	movzbl %al,%eax
}
c01095fc:	89 ec                	mov    %ebp,%esp
c01095fe:	5d                   	pop    %ebp
c01095ff:	c3                   	ret    

c0109600 <page2ppn>:
page2ppn(struct Page *page) {
c0109600:	55                   	push   %ebp
c0109601:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109603:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0109609:	8b 45 08             	mov    0x8(%ebp),%eax
c010960c:	29 d0                	sub    %edx,%eax
c010960e:	c1 f8 05             	sar    $0x5,%eax
}
c0109611:	5d                   	pop    %ebp
c0109612:	c3                   	ret    

c0109613 <page2pa>:
page2pa(struct Page *page) {
c0109613:	55                   	push   %ebp
c0109614:	89 e5                	mov    %esp,%ebp
c0109616:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109619:	8b 45 08             	mov    0x8(%ebp),%eax
c010961c:	89 04 24             	mov    %eax,(%esp)
c010961f:	e8 dc ff ff ff       	call   c0109600 <page2ppn>
c0109624:	c1 e0 0c             	shl    $0xc,%eax
}
c0109627:	89 ec                	mov    %ebp,%esp
c0109629:	5d                   	pop    %ebp
c010962a:	c3                   	ret    

c010962b <pa2page>:
pa2page(uintptr_t pa) {
c010962b:	55                   	push   %ebp
c010962c:	89 e5                	mov    %esp,%ebp
c010962e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109631:	8b 45 08             	mov    0x8(%ebp),%eax
c0109634:	c1 e8 0c             	shr    $0xc,%eax
c0109637:	89 c2                	mov    %eax,%edx
c0109639:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c010963e:	39 c2                	cmp    %eax,%edx
c0109640:	72 1c                	jb     c010965e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109642:	c7 44 24 08 28 e2 10 	movl   $0xc010e228,0x8(%esp)
c0109649:	c0 
c010964a:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109651:	00 
c0109652:	c7 04 24 47 e2 10 c0 	movl   $0xc010e247,(%esp)
c0109659:	e8 8d 77 ff ff       	call   c0100deb <__panic>
    return &pages[PPN(pa)];
c010965e:	8b 15 a0 3f 1a c0    	mov    0xc01a3fa0,%edx
c0109664:	8b 45 08             	mov    0x8(%ebp),%eax
c0109667:	c1 e8 0c             	shr    $0xc,%eax
c010966a:	c1 e0 05             	shl    $0x5,%eax
c010966d:	01 d0                	add    %edx,%eax
}
c010966f:	89 ec                	mov    %ebp,%esp
c0109671:	5d                   	pop    %ebp
c0109672:	c3                   	ret    

c0109673 <page2kva>:
page2kva(struct Page *page) {
c0109673:	55                   	push   %ebp
c0109674:	89 e5                	mov    %esp,%ebp
c0109676:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109679:	8b 45 08             	mov    0x8(%ebp),%eax
c010967c:	89 04 24             	mov    %eax,(%esp)
c010967f:	e8 8f ff ff ff       	call   c0109613 <page2pa>
c0109684:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109687:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010968a:	c1 e8 0c             	shr    $0xc,%eax
c010968d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109690:	a1 a4 3f 1a c0       	mov    0xc01a3fa4,%eax
c0109695:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109698:	72 23                	jb     c01096bd <page2kva+0x4a>
c010969a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010969d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01096a1:	c7 44 24 08 58 e2 10 	movl   $0xc010e258,0x8(%esp)
c01096a8:	c0 
c01096a9:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01096b0:	00 
c01096b1:	c7 04 24 47 e2 10 c0 	movl   $0xc010e247,(%esp)
c01096b8:	e8 2e 77 ff ff       	call   c0100deb <__panic>
c01096bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01096c5:	89 ec                	mov    %ebp,%esp
c01096c7:	5d                   	pop    %ebp
c01096c8:	c3                   	ret    

c01096c9 <kva2page>:
kva2page(void *kva) {
c01096c9:	55                   	push   %ebp
c01096ca:	89 e5                	mov    %esp,%ebp
c01096cc:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01096cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01096d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01096d5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01096dc:	77 23                	ja     c0109701 <kva2page+0x38>
c01096de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01096e5:	c7 44 24 08 7c e2 10 	movl   $0xc010e27c,0x8(%esp)
c01096ec:	c0 
c01096ed:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01096f4:	00 
c01096f5:	c7 04 24 47 e2 10 c0 	movl   $0xc010e247,(%esp)
c01096fc:	e8 ea 76 ff ff       	call   c0100deb <__panic>
c0109701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109704:	05 00 00 00 40       	add    $0x40000000,%eax
c0109709:	89 04 24             	mov    %eax,(%esp)
c010970c:	e8 1a ff ff ff       	call   c010962b <pa2page>
}
c0109711:	89 ec                	mov    %ebp,%esp
c0109713:	5d                   	pop    %ebp
c0109714:	c3                   	ret    

c0109715 <__intr_save>:
__intr_save(void) {
c0109715:	55                   	push   %ebp
c0109716:	89 e5                	mov    %esp,%ebp
c0109718:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010971b:	9c                   	pushf  
c010971c:	58                   	pop    %eax
c010971d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109720:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109723:	25 00 02 00 00       	and    $0x200,%eax
c0109728:	85 c0                	test   %eax,%eax
c010972a:	74 0c                	je     c0109738 <__intr_save+0x23>
        intr_disable();
c010972c:	e8 70 89 ff ff       	call   c01020a1 <intr_disable>
        return 1;
c0109731:	b8 01 00 00 00       	mov    $0x1,%eax
c0109736:	eb 05                	jmp    c010973d <__intr_save+0x28>
    return 0;
c0109738:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010973d:	89 ec                	mov    %ebp,%esp
c010973f:	5d                   	pop    %ebp
c0109740:	c3                   	ret    

c0109741 <__intr_restore>:
__intr_restore(bool flag) {
c0109741:	55                   	push   %ebp
c0109742:	89 e5                	mov    %esp,%ebp
c0109744:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109747:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010974b:	74 05                	je     c0109752 <__intr_restore+0x11>
        intr_enable();
c010974d:	e8 47 89 ff ff       	call   c0102099 <intr_enable>
}
c0109752:	90                   	nop
c0109753:	89 ec                	mov    %ebp,%esp
c0109755:	5d                   	pop    %ebp
c0109756:	c3                   	ret    

c0109757 <try_lock>:

static inline bool
try_lock(lock_t *lock) {
c0109757:	55                   	push   %ebp
c0109758:	89 e5                	mov    %esp,%ebp
c010975a:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c010975d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109760:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109764:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010976b:	e8 4c fe ff ff       	call   c01095bc <test_and_set_bit>
c0109770:	85 c0                	test   %eax,%eax
c0109772:	0f 94 c0             	sete   %al
c0109775:	0f b6 c0             	movzbl %al,%eax
}
c0109778:	89 ec                	mov    %ebp,%esp
c010977a:	5d                   	pop    %ebp
c010977b:	c3                   	ret    

c010977c <lock>:

static inline void
lock(lock_t *lock) {
c010977c:	55                   	push   %ebp
c010977d:	89 e5                	mov    %esp,%ebp
c010977f:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c0109782:	eb 05                	jmp    c0109789 <lock+0xd>
        schedule();
c0109784:	e8 e0 1a 00 00       	call   c010b269 <schedule>
    while (!try_lock(lock)) {
c0109789:	8b 45 08             	mov    0x8(%ebp),%eax
c010978c:	89 04 24             	mov    %eax,(%esp)
c010978f:	e8 c3 ff ff ff       	call   c0109757 <try_lock>
c0109794:	85 c0                	test   %eax,%eax
c0109796:	74 ec                	je     c0109784 <lock+0x8>
    }
}
c0109798:	90                   	nop
c0109799:	90                   	nop
c010979a:	89 ec                	mov    %ebp,%esp
c010979c:	5d                   	pop    %ebp
c010979d:	c3                   	ret    

c010979e <unlock>:

static inline void
unlock(lock_t *lock) {
c010979e:	55                   	push   %ebp
c010979f:	89 e5                	mov    %esp,%ebp
c01097a1:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c01097a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01097a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01097b2:	e8 27 fe ff ff       	call   c01095de <test_and_clear_bit>
c01097b7:	85 c0                	test   %eax,%eax
c01097b9:	75 1c                	jne    c01097d7 <unlock+0x39>
        panic("Unlock failed.\n");
c01097bb:	c7 44 24 08 a0 e2 10 	movl   $0xc010e2a0,0x8(%esp)
c01097c2:	c0 
c01097c3:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01097ca:	00 
c01097cb:	c7 04 24 b0 e2 10 c0 	movl   $0xc010e2b0,(%esp)
c01097d2:	e8 14 76 ff ff       	call   c0100deb <__panic>
    }
}
c01097d7:	90                   	nop
c01097d8:	89 ec                	mov    %ebp,%esp
c01097da:	5d                   	pop    %ebp
c01097db:	c3                   	ret    

c01097dc <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01097dc:	55                   	push   %ebp
c01097dd:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01097df:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e2:	8b 40 18             	mov    0x18(%eax),%eax
c01097e5:	8d 50 01             	lea    0x1(%eax),%edx
c01097e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01097eb:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01097ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f1:	8b 40 18             	mov    0x18(%eax),%eax
}
c01097f4:	5d                   	pop    %ebp
c01097f5:	c3                   	ret    

c01097f6 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01097f6:	55                   	push   %ebp
c01097f7:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01097f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01097fc:	8b 40 18             	mov    0x18(%eax),%eax
c01097ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109802:	8b 45 08             	mov    0x8(%ebp),%eax
c0109805:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0109808:	8b 45 08             	mov    0x8(%ebp),%eax
c010980b:	8b 40 18             	mov    0x18(%eax),%eax
}
c010980e:	5d                   	pop    %ebp
c010980f:	c3                   	ret    

c0109810 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0109810:	55                   	push   %ebp
c0109811:	89 e5                	mov    %esp,%ebp
c0109813:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109816:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010981a:	74 0e                	je     c010982a <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c010981c:	8b 45 08             	mov    0x8(%ebp),%eax
c010981f:	83 c0 1c             	add    $0x1c,%eax
c0109822:	89 04 24             	mov    %eax,(%esp)
c0109825:	e8 52 ff ff ff       	call   c010977c <lock>
    }
}
c010982a:	90                   	nop
c010982b:	89 ec                	mov    %ebp,%esp
c010982d:	5d                   	pop    %ebp
c010982e:	c3                   	ret    

c010982f <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c010982f:	55                   	push   %ebp
c0109830:	89 e5                	mov    %esp,%ebp
c0109832:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109835:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109839:	74 0e                	je     c0109849 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010983b:	8b 45 08             	mov    0x8(%ebp),%eax
c010983e:	83 c0 1c             	add    $0x1c,%eax
c0109841:	89 04 24             	mov    %eax,(%esp)
c0109844:	e8 55 ff ff ff       	call   c010979e <unlock>
    }
}
c0109849:	90                   	nop
c010984a:	89 ec                	mov    %ebp,%esp
c010984c:	5d                   	pop    %ebp
c010984d:	c3                   	ret    

c010984e <alloc_proc>:
void
switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010984e:	55                   	push   %ebp
c010984f:	89 e5                	mov    %esp,%ebp
c0109851:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109854:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c010985b:	e8 4f b6 ff ff       	call   c0104eaf <kmalloc>
c0109860:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109863:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109867:	74 3a                	je     c01098a3 <alloc_proc+0x55>
        /*
     * below fields(add in LAB5) in proc_struct need to be initialized	
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
	 */
        memset(proc, 0, sizeof(struct proc_struct));
c0109869:	c7 44 24 08 7c 00 00 	movl   $0x7c,0x8(%esp)
c0109870:	00 
c0109871:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109878:	00 
c0109879:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010987c:	89 04 24             	mov    %eax,(%esp)
c010987f:	e8 5a 27 00 00       	call   c010bfde <memset>
        proc->state = PROC_UNINIT;
c0109884:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109887:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c010988d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109890:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->cr3 = boot_cr3;
c0109897:	8b 15 a8 3f 1a c0    	mov    0xc01a3fa8,%edx
c010989d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098a0:	89 50 40             	mov    %edx,0x40(%eax)
        //proc->wait_state =
    }
    return proc;
c01098a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01098a6:	89 ec                	mov    %ebp,%esp
c01098a8:	5d                   	pop    %ebp
c01098a9:	c3                   	ret    

c01098aa <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01098aa:	55                   	push   %ebp
c01098ab:	89 e5                	mov    %esp,%ebp
c01098ad:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01098b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01098b3:	83 c0 48             	add    $0x48,%eax
c01098b6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01098bd:	00 
c01098be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01098c5:	00 
c01098c6:	89 04 24             	mov    %eax,(%esp)
c01098c9:	e8 10 27 00 00       	call   c010bfde <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01098ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01098d1:	8d 50 48             	lea    0x48(%eax),%edx
c01098d4:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01098db:	00 
c01098dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098e3:	89 14 24             	mov    %edx,(%esp)
c01098e6:	e8 d8 27 00 00       	call   c010c0c3 <memcpy>
}
c01098eb:	89 ec                	mov    %ebp,%esp
c01098ed:	5d                   	pop    %ebp
c01098ee:	c3                   	ret    

c01098ef <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01098ef:	55                   	push   %ebp
c01098f0:	89 e5                	mov    %esp,%ebp
c01098f2:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01098f5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01098fc:	00 
c01098fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109904:	00 
c0109905:	c7 04 24 44 61 1a c0 	movl   $0xc01a6144,(%esp)
c010990c:	e8 cd 26 00 00       	call   c010bfde <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109911:	8b 45 08             	mov    0x8(%ebp),%eax
c0109914:	83 c0 48             	add    $0x48,%eax
c0109917:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010991e:	00 
c010991f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109923:	c7 04 24 44 61 1a c0 	movl   $0xc01a6144,(%esp)
c010992a:	e8 94 27 00 00       	call   c010c0c3 <memcpy>
}
c010992f:	89 ec                	mov    %ebp,%esp
c0109931:	5d                   	pop    %ebp
c0109932:	c3                   	ret    

c0109933 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109933:	55                   	push   %ebp
c0109934:	89 e5                	mov    %esp,%ebp
c0109936:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c0109939:	8b 45 08             	mov    0x8(%ebp),%eax
c010993c:	83 c0 58             	add    $0x58,%eax
c010993f:	c7 45 fc 20 41 1a c0 	movl   $0xc01a4120,-0x4(%ebp)
c0109946:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109949:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010994c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010994f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109952:	89 45 f0             	mov    %eax,-0x10(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109955:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109958:	8b 40 04             	mov    0x4(%eax),%eax
c010995b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010995e:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109961:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109964:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109967:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next->prev = elm;
c010996a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010996d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109970:	89 10                	mov    %edx,(%eax)
c0109972:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109975:	8b 10                	mov    (%eax),%edx
c0109977:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010997a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010997d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109983:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109986:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109989:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010998c:	89 10                	mov    %edx,(%eax)
}
c010998e:	90                   	nop
}
c010998f:	90                   	nop
}
c0109990:	90                   	nop
    proc->yptr = NULL;
c0109991:	8b 45 08             	mov    0x8(%ebp),%eax
c0109994:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c010999b:	8b 45 08             	mov    0x8(%ebp),%eax
c010999e:	8b 40 14             	mov    0x14(%eax),%eax
c01099a1:	8b 50 70             	mov    0x70(%eax),%edx
c01099a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a7:	89 50 78             	mov    %edx,0x78(%eax)
c01099aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01099ad:	8b 40 78             	mov    0x78(%eax),%eax
c01099b0:	85 c0                	test   %eax,%eax
c01099b2:	74 0c                	je     c01099c0 <set_links+0x8d>
        proc->optr->yptr = proc;
c01099b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01099b7:	8b 40 78             	mov    0x78(%eax),%eax
c01099ba:	8b 55 08             	mov    0x8(%ebp),%edx
c01099bd:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c01099c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099c3:	8b 40 14             	mov    0x14(%eax),%eax
c01099c6:	8b 55 08             	mov    0x8(%ebp),%edx
c01099c9:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process++;
c01099cc:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c01099d1:	40                   	inc    %eax
c01099d2:	a3 40 61 1a c0       	mov    %eax,0xc01a6140
}
c01099d7:	90                   	nop
c01099d8:	89 ec                	mov    %ebp,%esp
c01099da:	5d                   	pop    %ebp
c01099db:	c3                   	ret    

c01099dc <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c01099dc:	55                   	push   %ebp
c01099dd:	89 e5                	mov    %esp,%ebp
c01099df:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c01099e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e5:	83 c0 58             	add    $0x58,%eax
c01099e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c01099eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099ee:	8b 40 04             	mov    0x4(%eax),%eax
c01099f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01099f4:	8b 12                	mov    (%edx),%edx
c01099f6:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01099f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c01099fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01099ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a02:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a08:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109a0b:	89 10                	mov    %edx,(%eax)
}
c0109a0d:	90                   	nop
}
c0109a0e:	90                   	nop
    if (proc->optr != NULL) {
c0109a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a12:	8b 40 78             	mov    0x78(%eax),%eax
c0109a15:	85 c0                	test   %eax,%eax
c0109a17:	74 0f                	je     c0109a28 <remove_links+0x4c>
        proc->optr->yptr = proc->yptr;
c0109a19:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a1c:	8b 40 78             	mov    0x78(%eax),%eax
c0109a1f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a22:	8b 52 74             	mov    0x74(%edx),%edx
c0109a25:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c0109a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a2b:	8b 40 74             	mov    0x74(%eax),%eax
c0109a2e:	85 c0                	test   %eax,%eax
c0109a30:	74 11                	je     c0109a43 <remove_links+0x67>
        proc->yptr->optr = proc->optr;
c0109a32:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a35:	8b 40 74             	mov    0x74(%eax),%eax
c0109a38:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a3b:	8b 52 78             	mov    0x78(%edx),%edx
c0109a3e:	89 50 78             	mov    %edx,0x78(%eax)
c0109a41:	eb 0f                	jmp    c0109a52 <remove_links+0x76>
    } else {
        proc->parent->cptr = proc->optr;
c0109a43:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a46:	8b 40 14             	mov    0x14(%eax),%eax
c0109a49:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a4c:	8b 52 78             	mov    0x78(%edx),%edx
c0109a4f:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process--;
c0109a52:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c0109a57:	48                   	dec    %eax
c0109a58:	a3 40 61 1a c0       	mov    %eax,0xc01a6140
}
c0109a5d:	90                   	nop
c0109a5e:	89 ec                	mov    %ebp,%esp
c0109a60:	5d                   	pop    %ebp
c0109a61:	c3                   	ret    

c0109a62 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109a62:	55                   	push   %ebp
c0109a63:	89 e5                	mov    %esp,%ebp
c0109a65:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109a68:	c7 45 f8 20 41 1a c0 	movl   $0xc01a4120,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID) {
c0109a6f:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109a74:	40                   	inc    %eax
c0109a75:	a3 80 fa 12 c0       	mov    %eax,0xc012fa80
c0109a7a:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109a7f:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109a84:	7e 0c                	jle    c0109a92 <get_pid+0x30>
        last_pid = 1;
c0109a86:	c7 05 80 fa 12 c0 01 	movl   $0x1,0xc012fa80
c0109a8d:	00 00 00 
        goto inside;
c0109a90:	eb 14                	jmp    c0109aa6 <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c0109a92:	8b 15 80 fa 12 c0    	mov    0xc012fa80,%edx
c0109a98:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0109a9d:	39 c2                	cmp    %eax,%edx
c0109a9f:	0f 8c ab 00 00 00    	jl     c0109b50 <get_pid+0xee>
    inside:
c0109aa5:	90                   	nop
        next_safe = MAX_PID;
c0109aa6:	c7 05 84 fa 12 c0 00 	movl   $0x2000,0xc012fa84
c0109aad:	20 00 00 
    repeat:
        le = list;
c0109ab0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109ab3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109ab6:	eb 7d                	jmp    c0109b35 <get_pid+0xd3>
            proc = le2proc(le, list_link);
c0109ab8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109abb:	83 e8 58             	sub    $0x58,%eax
c0109abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ac4:	8b 50 04             	mov    0x4(%eax),%edx
c0109ac7:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109acc:	39 c2                	cmp    %eax,%edx
c0109ace:	75 3c                	jne    c0109b0c <get_pid+0xaa>
                if (++last_pid >= next_safe) {
c0109ad0:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109ad5:	40                   	inc    %eax
c0109ad6:	a3 80 fa 12 c0       	mov    %eax,0xc012fa80
c0109adb:	8b 15 80 fa 12 c0    	mov    0xc012fa80,%edx
c0109ae1:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0109ae6:	39 c2                	cmp    %eax,%edx
c0109ae8:	7c 4b                	jl     c0109b35 <get_pid+0xd3>
                    if (last_pid >= MAX_PID) {
c0109aea:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109aef:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109af4:	7e 0a                	jle    c0109b00 <get_pid+0x9e>
                        last_pid = 1;
c0109af6:	c7 05 80 fa 12 c0 01 	movl   $0x1,0xc012fa80
c0109afd:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109b00:	c7 05 84 fa 12 c0 00 	movl   $0x2000,0xc012fa84
c0109b07:	20 00 00 
                    goto repeat;
c0109b0a:	eb a4                	jmp    c0109ab0 <get_pid+0x4e>
                }
            } else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b0f:	8b 50 04             	mov    0x4(%eax),%edx
c0109b12:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
c0109b17:	39 c2                	cmp    %eax,%edx
c0109b19:	7e 1a                	jle    c0109b35 <get_pid+0xd3>
c0109b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b1e:	8b 50 04             	mov    0x4(%eax),%edx
c0109b21:	a1 84 fa 12 c0       	mov    0xc012fa84,%eax
c0109b26:	39 c2                	cmp    %eax,%edx
c0109b28:	7d 0b                	jge    c0109b35 <get_pid+0xd3>
                next_safe = proc->pid;
c0109b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b2d:	8b 40 04             	mov    0x4(%eax),%eax
c0109b30:	a3 84 fa 12 c0       	mov    %eax,0xc012fa84
c0109b35:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return listelm->next;
c0109b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b3e:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109b41:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109b44:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109b47:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109b4a:	0f 85 68 ff ff ff    	jne    c0109ab8 <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0109b50:	a1 80 fa 12 c0       	mov    0xc012fa80,%eax
}
c0109b55:	89 ec                	mov    %ebp,%esp
c0109b57:	5d                   	pop    %ebp
c0109b58:	c3                   	ret    

c0109b59 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109b59:	55                   	push   %ebp
c0109b5a:	89 e5                	mov    %esp,%ebp
c0109b5c:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109b5f:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109b64:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109b67:	74 64                	je     c0109bcd <proc_run+0x74>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109b69:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109b6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b71:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b74:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109b77:	e8 99 fb ff ff       	call   c0109715 <__intr_save>
c0109b7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109b7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b82:	a3 30 41 1a c0       	mov    %eax,0xc01a4130
            load_esp0(next->kstack + KSTACKSIZE);
c0109b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b8a:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b8d:	05 00 20 00 00       	add    $0x2000,%eax
c0109b92:	89 04 24             	mov    %eax,(%esp)
c0109b95:	e8 54 b6 ff ff       	call   c01051ee <load_esp0>
            lcr3(next->cr3);
c0109b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b9d:	8b 40 40             	mov    0x40(%eax),%eax
c0109ba0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109ba3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ba6:	0f 22 d8             	mov    %eax,%cr3
}
c0109ba9:	90                   	nop
            switch_to(&(prev->context), &(next->context));
c0109baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bad:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bb3:	83 c0 1c             	add    $0x1c,%eax
c0109bb6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109bba:	89 04 24             	mov    %eax,(%esp)
c0109bbd:	e8 a7 15 00 00       	call   c010b169 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109bc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bc5:	89 04 24             	mov    %eax,(%esp)
c0109bc8:	e8 74 fb ff ff       	call   c0109741 <__intr_restore>
    }
}
c0109bcd:	90                   	nop
c0109bce:	89 ec                	mov    %ebp,%esp
c0109bd0:	5d                   	pop    %ebp
c0109bd1:	c3                   	ret    

c0109bd2 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109bd2:	55                   	push   %ebp
c0109bd3:	89 e5                	mov    %esp,%ebp
c0109bd5:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109bd8:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109bdd:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109be0:	89 04 24             	mov    %eax,(%esp)
c0109be3:	e8 86 8f ff ff       	call   c0102b6e <forkrets>
}
c0109be8:	90                   	nop
c0109be9:	89 ec                	mov    %ebp,%esp
c0109beb:	5d                   	pop    %ebp
c0109bec:	c3                   	ret    

c0109bed <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109bed:	55                   	push   %ebp
c0109bee:	89 e5                	mov    %esp,%ebp
c0109bf0:	83 ec 38             	sub    $0x38,%esp
c0109bf3:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109bf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bf9:	8d 58 60             	lea    0x60(%eax),%ebx
c0109bfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bff:	8b 40 04             	mov    0x4(%eax),%eax
c0109c02:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109c09:	00 
c0109c0a:	89 04 24             	mov    %eax,(%esp)
c0109c0d:	e8 2f 19 00 00       	call   c010b541 <hash32>
c0109c12:	c1 e0 03             	shl    $0x3,%eax
c0109c15:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c0109c1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c1d:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c29:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c2f:	8b 40 04             	mov    0x4(%eax),%eax
c0109c32:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109c35:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109c38:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109c3b:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109c3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0109c41:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109c44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109c47:	89 10                	mov    %edx,(%eax)
c0109c49:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109c4c:	8b 10                	mov    (%eax),%edx
c0109c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109c51:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109c54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109c57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109c5a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109c60:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109c63:	89 10                	mov    %edx,(%eax)
}
c0109c65:	90                   	nop
}
c0109c66:	90                   	nop
}
c0109c67:	90                   	nop
}
c0109c68:	90                   	nop
c0109c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109c6c:	89 ec                	mov    %ebp,%esp
c0109c6e:	5d                   	pop    %ebp
c0109c6f:	c3                   	ret    

c0109c70 <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109c70:	55                   	push   %ebp
c0109c71:	89 e5                	mov    %esp,%ebp
c0109c73:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109c76:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c79:	83 c0 60             	add    $0x60,%eax
c0109c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    __list_del(listelm->prev, listelm->next);
c0109c7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109c82:	8b 40 04             	mov    0x4(%eax),%eax
c0109c85:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109c88:	8b 12                	mov    (%edx),%edx
c0109c8a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    prev->next = next;
c0109c90:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109c93:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109c96:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c9c:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109c9f:	89 10                	mov    %edx,(%eax)
}
c0109ca1:	90                   	nop
}
c0109ca2:	90                   	nop
}
c0109ca3:	90                   	nop
c0109ca4:	89 ec                	mov    %ebp,%esp
c0109ca6:	5d                   	pop    %ebp
c0109ca7:	c3                   	ret    

c0109ca8 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109ca8:	55                   	push   %ebp
c0109ca9:	89 e5                	mov    %esp,%ebp
c0109cab:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109cae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109cb2:	7e 5f                	jle    c0109d13 <find_proc+0x6b>
c0109cb4:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109cbb:	7f 56                	jg     c0109d13 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109cbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cc0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109cc7:	00 
c0109cc8:	89 04 24             	mov    %eax,(%esp)
c0109ccb:	e8 71 18 00 00       	call   c010b541 <hash32>
c0109cd0:	c1 e0 03             	shl    $0x3,%eax
c0109cd3:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c0109cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cde:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109ce1:	eb 19                	jmp    c0109cfc <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ce6:	83 e8 60             	sub    $0x60,%eax
c0109ce9:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109cec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cef:	8b 40 04             	mov    0x4(%eax),%eax
c0109cf2:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109cf5:	75 05                	jne    c0109cfc <find_proc+0x54>
                return proc;
c0109cf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cfa:	eb 1c                	jmp    c0109d18 <find_proc+0x70>
c0109cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0109d02:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d05:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0109d08:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d0e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109d11:	75 d0                	jne    c0109ce3 <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0109d13:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109d18:	89 ec                	mov    %ebp,%esp
c0109d1a:	5d                   	pop    %ebp
c0109d1b:	c3                   	ret    

c0109d1c <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109d1c:	55                   	push   %ebp
c0109d1d:	89 e5                	mov    %esp,%ebp
c0109d1f:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109d22:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109d29:	00 
c0109d2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109d31:	00 
c0109d32:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109d35:	89 04 24             	mov    %eax,(%esp)
c0109d38:	e8 a1 22 00 00       	call   c010bfde <memset>
    tf.tf_cs = KERNEL_CS;
c0109d3d:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109d43:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109d49:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109d4d:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109d51:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109d55:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d5c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d62:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109d65:	b8 b3 95 10 c0       	mov    $0xc01095b3,%eax
c0109d6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109d6d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109d70:	0d 00 01 00 00       	or     $0x100,%eax
c0109d75:	89 c2                	mov    %eax,%edx
c0109d77:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109d7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109d85:	00 
c0109d86:	89 14 24             	mov    %edx,(%esp)
c0109d89:	e8 44 03 00 00       	call   c010a0d2 <do_fork>
}
c0109d8e:	89 ec                	mov    %ebp,%esp
c0109d90:	5d                   	pop    %ebp
c0109d91:	c3                   	ret    

c0109d92 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109d92:	55                   	push   %ebp
c0109d93:	89 e5                	mov    %esp,%ebp
c0109d95:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109d98:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109d9f:	e8 9c b5 ff ff       	call   c0105340 <alloc_pages>
c0109da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109da7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109dab:	74 1a                	je     c0109dc7 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109db0:	89 04 24             	mov    %eax,(%esp)
c0109db3:	e8 bb f8 ff ff       	call   c0109673 <page2kva>
c0109db8:	89 c2                	mov    %eax,%edx
c0109dba:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dbd:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109dc0:	b8 00 00 00 00       	mov    $0x0,%eax
c0109dc5:	eb 05                	jmp    c0109dcc <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109dc7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109dcc:	89 ec                	mov    %ebp,%esp
c0109dce:	5d                   	pop    %ebp
c0109dcf:	c3                   	ret    

c0109dd0 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109dd0:	55                   	push   %ebp
c0109dd1:	89 e5                	mov    %esp,%ebp
c0109dd3:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109dd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd9:	8b 40 0c             	mov    0xc(%eax),%eax
c0109ddc:	89 04 24             	mov    %eax,(%esp)
c0109ddf:	e8 e5 f8 ff ff       	call   c01096c9 <kva2page>
c0109de4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109deb:	00 
c0109dec:	89 04 24             	mov    %eax,(%esp)
c0109def:	e8 b9 b5 ff ff       	call   c01053ad <free_pages>
}
c0109df4:	90                   	nop
c0109df5:	89 ec                	mov    %ebp,%esp
c0109df7:	5d                   	pop    %ebp
c0109df8:	c3                   	ret    

c0109df9 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109df9:	55                   	push   %ebp
c0109dfa:	89 e5                	mov    %esp,%ebp
c0109dfc:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109e06:	e8 35 b5 ff ff       	call   c0105340 <alloc_pages>
c0109e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109e0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109e12:	75 0a                	jne    c0109e1e <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109e14:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109e19:	e9 80 00 00 00       	jmp    c0109e9e <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e21:	89 04 24             	mov    %eax,(%esp)
c0109e24:	e8 4a f8 ff ff       	call   c0109673 <page2kva>
c0109e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109e2c:	a1 00 fa 12 c0       	mov    0xc012fa00,%eax
c0109e31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109e38:	00 
c0109e39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e40:	89 04 24             	mov    %eax,(%esp)
c0109e43:	e8 7b 22 00 00       	call   c010c0c3 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109e48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109e4e:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109e55:	77 23                	ja     c0109e7a <setup_pgdir+0x81>
c0109e57:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109e5e:	c7 44 24 08 7c e2 10 	movl   $0xc010e27c,0x8(%esp)
c0109e65:	c0 
c0109e66:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0109e6d:	00 
c0109e6e:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c0109e75:	e8 71 6f ff ff       	call   c0100deb <__panic>
c0109e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e7d:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e86:	05 ac 0f 00 00       	add    $0xfac,%eax
c0109e8b:	83 ca 03             	or     $0x3,%edx
c0109e8e:	89 10                	mov    %edx,(%eax)
    mm->pgdir = pgdir;
c0109e90:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e93:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109e96:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109e9e:	89 ec                	mov    %ebp,%esp
c0109ea0:	5d                   	pop    %ebp
c0109ea1:	c3                   	ret    

c0109ea2 <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109ea2:	55                   	push   %ebp
c0109ea3:	89 e5                	mov    %esp,%ebp
c0109ea5:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109ea8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eab:	8b 40 0c             	mov    0xc(%eax),%eax
c0109eae:	89 04 24             	mov    %eax,(%esp)
c0109eb1:	e8 13 f8 ff ff       	call   c01096c9 <kva2page>
c0109eb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109ebd:	00 
c0109ebe:	89 04 24             	mov    %eax,(%esp)
c0109ec1:	e8 e7 b4 ff ff       	call   c01053ad <free_pages>
}
c0109ec6:	90                   	nop
c0109ec7:	89 ec                	mov    %ebp,%esp
c0109ec9:	5d                   	pop    %ebp
c0109eca:	c3                   	ret    

c0109ecb <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109ecb:	55                   	push   %ebp
c0109ecc:	89 e5                	mov    %esp,%ebp
c0109ece:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109ed1:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c0109ed6:	8b 40 18             	mov    0x18(%eax),%eax
c0109ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109edc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109ee0:	75 0a                	jne    c0109eec <copy_mm+0x21>
        return 0;
c0109ee2:	b8 00 00 00 00       	mov    $0x0,%eax
c0109ee7:	e9 fc 00 00 00       	jmp    c0109fe8 <copy_mm+0x11d>
    }
    if (clone_flags & CLONE_VM) {
c0109eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eef:	25 00 01 00 00       	and    $0x100,%eax
c0109ef4:	85 c0                	test   %eax,%eax
c0109ef6:	74 08                	je     c0109f00 <copy_mm+0x35>
        mm = oldmm;
c0109ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109efe:	eb 5e                	jmp    c0109f5e <copy_mm+0x93>
    }

    int ret = -E_NO_MEM;
c0109f00:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109f07:	e8 0d e3 ff ff       	call   c0108219 <mm_create>
c0109f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f13:	0f 84 cb 00 00 00    	je     c0109fe4 <copy_mm+0x119>
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
c0109f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f1c:	89 04 24             	mov    %eax,(%esp)
c0109f1f:	e8 d5 fe ff ff       	call   c0109df9 <setup_pgdir>
c0109f24:	85 c0                	test   %eax,%eax
c0109f26:	0f 85 aa 00 00 00    	jne    c0109fd6 <copy_mm+0x10b>
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c0109f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f2f:	89 04 24             	mov    %eax,(%esp)
c0109f32:	e8 d9 f8 ff ff       	call   c0109810 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f41:	89 04 24             	mov    %eax,(%esp)
c0109f44:	e8 fa e7 ff ff       	call   c0108743 <dup_mmap>
c0109f49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f4f:	89 04 24             	mov    %eax,(%esp)
c0109f52:	e8 d8 f8 ff ff       	call   c010982f <unlock_mm>

    if (ret != 0) {
c0109f57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109f5b:	75 60                	jne    c0109fbd <copy_mm+0xf2>
        goto bad_dup_cleanup_mmap;
    }

good_mm:
c0109f5d:	90                   	nop
    mm_count_inc(mm);
c0109f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f61:	89 04 24             	mov    %eax,(%esp)
c0109f64:	e8 73 f8 ff ff       	call   c01097dc <mm_count_inc>
    proc->mm = mm;
c0109f69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109f6f:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f75:	8b 40 0c             	mov    0xc(%eax),%eax
c0109f78:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109f7b:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109f82:	77 23                	ja     c0109fa7 <copy_mm+0xdc>
c0109f84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109f8b:	c7 44 24 08 7c e2 10 	movl   $0xc010e27c,0x8(%esp)
c0109f92:	c0 
c0109f93:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c0109f9a:	00 
c0109f9b:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c0109fa2:	e8 44 6e ff ff       	call   c0100deb <__panic>
c0109fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109faa:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109fb3:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109fb6:	b8 00 00 00 00       	mov    $0x0,%eax
c0109fbb:	eb 2b                	jmp    c0109fe8 <copy_mm+0x11d>
        goto bad_dup_cleanup_mmap;
c0109fbd:	90                   	nop
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fc1:	89 04 24             	mov    %eax,(%esp)
c0109fc4:	e8 7b e8 ff ff       	call   c0108844 <exit_mmap>
    put_pgdir(mm);
c0109fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fcc:	89 04 24             	mov    %eax,(%esp)
c0109fcf:	e8 ce fe ff ff       	call   c0109ea2 <put_pgdir>
c0109fd4:	eb 01                	jmp    c0109fd7 <copy_mm+0x10c>
        goto bad_pgdir_cleanup_mm;
c0109fd6:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fda:	89 04 24             	mov    %eax,(%esp)
c0109fdd:	e8 a0 e5 ff ff       	call   c0108582 <mm_destroy>
c0109fe2:	eb 01                	jmp    c0109fe5 <copy_mm+0x11a>
        goto bad_mm;
c0109fe4:	90                   	nop
bad_mm:
    return ret;
c0109fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109fe8:	89 ec                	mov    %ebp,%esp
c0109fea:	5d                   	pop    %ebp
c0109feb:	c3                   	ret    

c0109fec <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109fec:	55                   	push   %ebp
c0109fed:	89 e5                	mov    %esp,%ebp
c0109fef:	57                   	push   %edi
c0109ff0:	56                   	push   %esi
c0109ff1:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109ff2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ff5:	8b 40 0c             	mov    0xc(%eax),%eax
c0109ff8:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109ffd:	89 c2                	mov    %eax,%edx
c0109fff:	8b 45 08             	mov    0x8(%ebp),%eax
c010a002:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a005:	8b 45 08             	mov    0x8(%ebp),%eax
c010a008:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a00b:	8b 55 10             	mov    0x10(%ebp),%edx
c010a00e:	b9 4c 00 00 00       	mov    $0x4c,%ecx
c010a013:	89 c3                	mov    %eax,%ebx
c010a015:	83 e3 01             	and    $0x1,%ebx
c010a018:	85 db                	test   %ebx,%ebx
c010a01a:	74 0c                	je     c010a028 <copy_thread+0x3c>
c010a01c:	0f b6 1a             	movzbl (%edx),%ebx
c010a01f:	88 18                	mov    %bl,(%eax)
c010a021:	8d 40 01             	lea    0x1(%eax),%eax
c010a024:	8d 52 01             	lea    0x1(%edx),%edx
c010a027:	49                   	dec    %ecx
c010a028:	89 c3                	mov    %eax,%ebx
c010a02a:	83 e3 02             	and    $0x2,%ebx
c010a02d:	85 db                	test   %ebx,%ebx
c010a02f:	74 0f                	je     c010a040 <copy_thread+0x54>
c010a031:	0f b7 1a             	movzwl (%edx),%ebx
c010a034:	66 89 18             	mov    %bx,(%eax)
c010a037:	8d 40 02             	lea    0x2(%eax),%eax
c010a03a:	8d 52 02             	lea    0x2(%edx),%edx
c010a03d:	83 e9 02             	sub    $0x2,%ecx
c010a040:	89 cf                	mov    %ecx,%edi
c010a042:	83 e7 fc             	and    $0xfffffffc,%edi
c010a045:	bb 00 00 00 00       	mov    $0x0,%ebx
c010a04a:	8b 34 1a             	mov    (%edx,%ebx,1),%esi
c010a04d:	89 34 18             	mov    %esi,(%eax,%ebx,1)
c010a050:	83 c3 04             	add    $0x4,%ebx
c010a053:	39 fb                	cmp    %edi,%ebx
c010a055:	72 f3                	jb     c010a04a <copy_thread+0x5e>
c010a057:	01 d8                	add    %ebx,%eax
c010a059:	01 da                	add    %ebx,%edx
c010a05b:	bb 00 00 00 00       	mov    $0x0,%ebx
c010a060:	89 ce                	mov    %ecx,%esi
c010a062:	83 e6 02             	and    $0x2,%esi
c010a065:	85 f6                	test   %esi,%esi
c010a067:	74 0b                	je     c010a074 <copy_thread+0x88>
c010a069:	0f b7 34 1a          	movzwl (%edx,%ebx,1),%esi
c010a06d:	66 89 34 18          	mov    %si,(%eax,%ebx,1)
c010a071:	83 c3 02             	add    $0x2,%ebx
c010a074:	83 e1 01             	and    $0x1,%ecx
c010a077:	85 c9                	test   %ecx,%ecx
c010a079:	74 07                	je     c010a082 <copy_thread+0x96>
c010a07b:	0f b6 14 1a          	movzbl (%edx,%ebx,1),%edx
c010a07f:	88 14 18             	mov    %dl,(%eax,%ebx,1)
    proc->tf->tf_regs.reg_eax = 0;
c010a082:	8b 45 08             	mov    0x8(%ebp),%eax
c010a085:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a088:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010a08f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a092:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a095:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a098:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010a09b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a09e:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0a1:	8b 50 40             	mov    0x40(%eax),%edx
c010a0a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0a7:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0aa:	81 ca 00 02 00 00    	or     $0x200,%edx
c010a0b0:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010a0b3:	ba d2 9b 10 c0       	mov    $0xc0109bd2,%edx
c010a0b8:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0bb:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010a0be:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0c1:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0c4:	89 c2                	mov    %eax,%edx
c010a0c6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0c9:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a0cc:	90                   	nop
c010a0cd:	5b                   	pop    %ebx
c010a0ce:	5e                   	pop    %esi
c010a0cf:	5f                   	pop    %edi
c010a0d0:	5d                   	pop    %ebp
c010a0d1:	c3                   	ret    

c010a0d2 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010a0d2:	55                   	push   %ebp
c010a0d3:	89 e5                	mov    %esp,%ebp
c010a0d5:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c010a0d8:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010a0df:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010a0e4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a0e9:	0f 8f 45 01 00 00    	jg     c010a234 <do_fork+0x162>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010a0ef:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
	*    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
	*    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */
    if ((proc = alloc_proc()) == NULL) {
c010a0f6:	e8 53 f7 ff ff       	call   c010984e <alloc_proc>
c010a0fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a0fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a102:	75 11                	jne    c010a115 <do_fork+0x43>
        cprintf("alloc_proc() failed!");
c010a104:	c7 04 24 d5 e2 10 c0 	movl   $0xc010e2d5,(%esp)
c010a10b:	e8 5d 62 ff ff       	call   c010036d <cprintf>
        goto fork_out;
c010a110:	e9 20 01 00 00       	jmp    c010a235 <do_fork+0x163>
    }

    proc->parent = current;
c010a115:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010a11b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a11e:	89 50 14             	mov    %edx,0x14(%eax)

    if ((ret = setup_kstack(proc)) != 0) {  //call the alloc_pages to alloc kstack space
c010a121:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a124:	89 04 24             	mov    %eax,(%esp)
c010a127:	e8 66 fc ff ff       	call   c0109d92 <setup_kstack>
c010a12c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a12f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a133:	74 11                	je     c010a146 <do_fork+0x74>
        cprintf("set_kstack() failed!");
c010a135:	c7 04 24 ea e2 10 c0 	movl   $0xc010e2ea,(%esp)
c010a13c:	e8 2c 62 ff ff       	call   c010036d <cprintf>
        goto bad_fork_cleanup_proc;
c010a141:	e9 f4 00 00 00       	jmp    c010a23a <do_fork+0x168>
    }

    if (copy_mm(clone_flags, proc) != 0) {
c010a146:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a149:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a14d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a150:	89 04 24             	mov    %eax,(%esp)
c010a153:	e8 73 fd ff ff       	call   c0109ecb <copy_mm>
c010a158:	85 c0                	test   %eax,%eax
c010a15a:	74 1d                	je     c010a179 <do_fork+0xa7>
        cprintf("copy_mm() failed!");
c010a15c:	c7 04 24 ff e2 10 c0 	movl   $0xc010e2ff,(%esp)
c010a163:	e8 05 62 ff ff       	call   c010036d <cprintf>
        goto bad_fork_cleanup_kstack;
c010a168:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a169:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a16c:	89 04 24             	mov    %eax,(%esp)
c010a16f:	e8 5c fc ff ff       	call   c0109dd0 <put_kstack>
c010a174:	e9 c1 00 00 00       	jmp    c010a23a <do_fork+0x168>
    copy_thread(proc, stack, tf);
c010a179:	8b 45 10             	mov    0x10(%ebp),%eax
c010a17c:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a180:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a183:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a187:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a18a:	89 04 24             	mov    %eax,(%esp)
c010a18d:	e8 5a fe ff ff       	call   c0109fec <copy_thread>
    local_intr_save(intr_flag);
c010a192:	e8 7e f5 ff ff       	call   c0109715 <__intr_save>
c010a197:	89 45 ec             	mov    %eax,-0x14(%ebp)
        proc->pid = get_pid();
c010a19a:	e8 c3 f8 ff ff       	call   c0109a62 <get_pid>
c010a19f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a1a2:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a1a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1a8:	89 04 24             	mov    %eax,(%esp)
c010a1ab:	e8 3d fa ff ff       	call   c0109bed <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c010a1b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1b3:	83 c0 58             	add    $0x58,%eax
c010a1b6:	c7 45 e8 20 41 1a c0 	movl   $0xc01a4120,-0x18(%ebp)
c010a1bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a1c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a1c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a1c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c010a1cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a1cf:	8b 40 04             	mov    0x4(%eax),%eax
c010a1d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010a1d5:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010a1d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010a1db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a1de:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c010a1e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a1e7:	89 10                	mov    %edx,(%eax)
c010a1e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1ec:	8b 10                	mov    (%eax),%edx
c010a1ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a1f1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010a1f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a1f7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a1fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010a1fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a200:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a203:	89 10                	mov    %edx,(%eax)
}
c010a205:	90                   	nop
}
c010a206:	90                   	nop
}
c010a207:	90                   	nop
        nr_process++;
c010a208:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010a20d:	40                   	inc    %eax
c010a20e:	a3 40 61 1a c0       	mov    %eax,0xc01a6140
    local_intr_restore(intr_flag);
c010a213:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a216:	89 04 24             	mov    %eax,(%esp)
c010a219:	e8 23 f5 ff ff       	call   c0109741 <__intr_restore>
    wakeup_proc(proc);
c010a21e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a221:	89 04 24             	mov    %eax,(%esp)
c010a224:	e8 b9 0f 00 00       	call   c010b1e2 <wakeup_proc>
    ret = proc->pid;
c010a229:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a22c:	8b 40 04             	mov    0x4(%eax),%eax
c010a22f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a232:	eb 01                	jmp    c010a235 <do_fork+0x163>
        goto fork_out;
c010a234:	90                   	nop
    return ret;
c010a235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a238:	eb 0d                	jmp    c010a247 <do_fork+0x175>
bad_fork_cleanup_proc:
    kfree(proc);
c010a23a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a23d:	89 04 24             	mov    %eax,(%esp)
c010a240:	e8 87 ac ff ff       	call   c0104ecc <kfree>
    goto fork_out;
c010a245:	eb ee                	jmp    c010a235 <do_fork+0x163>
}
c010a247:	89 ec                	mov    %ebp,%esp
c010a249:	5d                   	pop    %ebp
c010a24a:	c3                   	ret    

c010a24b <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a24b:	55                   	push   %ebp
c010a24c:	89 e5                	mov    %esp,%ebp
c010a24e:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a251:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010a257:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010a25c:	39 c2                	cmp    %eax,%edx
c010a25e:	75 1c                	jne    c010a27c <do_exit+0x31>
        panic("idleproc exit.\n");
c010a260:	c7 44 24 08 11 e3 10 	movl   $0xc010e311,0x8(%esp)
c010a267:	c0 
c010a268:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
c010a26f:	00 
c010a270:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a277:	e8 6f 6b ff ff       	call   c0100deb <__panic>
    }
    if (current == initproc) {
c010a27c:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010a282:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a287:	39 c2                	cmp    %eax,%edx
c010a289:	75 1c                	jne    c010a2a7 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a28b:	c7 44 24 08 21 e3 10 	movl   $0xc010e321,0x8(%esp)
c010a292:	c0 
c010a293:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c010a29a:	00 
c010a29b:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a2a2:	e8 44 6b ff ff       	call   c0100deb <__panic>
    }

    struct mm_struct *mm = current->mm;
c010a2a7:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a2ac:	8b 40 18             	mov    0x18(%eax),%eax
c010a2af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a2b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a2b6:	74 4b                	je     c010a303 <do_exit+0xb8>
        lcr3(boot_cr3);
c010a2b8:	a1 a8 3f 1a c0       	mov    0xc01a3fa8,%eax
c010a2bd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010a2c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2c3:	0f 22 d8             	mov    %eax,%cr3
}
c010a2c6:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c010a2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2ca:	89 04 24             	mov    %eax,(%esp)
c010a2cd:	e8 24 f5 ff ff       	call   c01097f6 <mm_count_dec>
c010a2d2:	85 c0                	test   %eax,%eax
c010a2d4:	75 21                	jne    c010a2f7 <do_exit+0xac>
            exit_mmap(mm);
c010a2d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2d9:	89 04 24             	mov    %eax,(%esp)
c010a2dc:	e8 63 e5 ff ff       	call   c0108844 <exit_mmap>
            put_pgdir(mm);
c010a2e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2e4:	89 04 24             	mov    %eax,(%esp)
c010a2e7:	e8 b6 fb ff ff       	call   c0109ea2 <put_pgdir>
            mm_destroy(mm);
c010a2ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2ef:	89 04 24             	mov    %eax,(%esp)
c010a2f2:	e8 8b e2 ff ff       	call   c0108582 <mm_destroy>
        }
        current->mm = NULL;
c010a2f7:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a2fc:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a303:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a308:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a30e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a313:	8b 55 08             	mov    0x8(%ebp),%edx
c010a316:	89 50 68             	mov    %edx,0x68(%eax)

    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a319:	e8 f7 f3 ff ff       	call   c0109715 <__intr_save>
c010a31e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a321:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a326:	8b 40 14             	mov    0x14(%eax),%eax
c010a329:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a32c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a32f:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a332:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a337:	0f 85 96 00 00 00    	jne    c010a3d3 <do_exit+0x188>
            wakeup_proc(proc);
c010a33d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a340:	89 04 24             	mov    %eax,(%esp)
c010a343:	e8 9a 0e 00 00       	call   c010b1e2 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a348:	e9 86 00 00 00       	jmp    c010a3d3 <do_exit+0x188>
            proc = current->cptr;
c010a34d:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a352:	8b 40 70             	mov    0x70(%eax),%eax
c010a355:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a358:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a35d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a360:	8b 52 78             	mov    0x78(%edx),%edx
c010a363:	89 50 70             	mov    %edx,0x70(%eax)

            proc->yptr = NULL;
c010a366:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a369:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a370:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a375:	8b 50 70             	mov    0x70(%eax),%edx
c010a378:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a37b:	89 50 78             	mov    %edx,0x78(%eax)
c010a37e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a381:	8b 40 78             	mov    0x78(%eax),%eax
c010a384:	85 c0                	test   %eax,%eax
c010a386:	74 0e                	je     c010a396 <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a388:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a38d:	8b 40 70             	mov    0x70(%eax),%eax
c010a390:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a393:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a396:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c010a39c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a39f:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a3a2:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a3a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a3aa:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a3ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a3b0:	8b 00                	mov    (%eax),%eax
c010a3b2:	83 f8 03             	cmp    $0x3,%eax
c010a3b5:	75 1c                	jne    c010a3d3 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a3b7:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a3bc:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a3bf:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a3c4:	75 0d                	jne    c010a3d3 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a3c6:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010a3cb:	89 04 24             	mov    %eax,(%esp)
c010a3ce:	e8 0f 0e 00 00       	call   c010b1e2 <wakeup_proc>
        while (current->cptr != NULL) {
c010a3d3:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a3d8:	8b 40 70             	mov    0x70(%eax),%eax
c010a3db:	85 c0                	test   %eax,%eax
c010a3dd:	0f 85 6a ff ff ff    	jne    c010a34d <do_exit+0x102>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a3e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3e6:	89 04 24             	mov    %eax,(%esp)
c010a3e9:	e8 53 f3 ff ff       	call   c0109741 <__intr_restore>

    schedule();
c010a3ee:	e8 76 0e 00 00       	call   c010b269 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a3f3:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a3f8:	8b 40 04             	mov    0x4(%eax),%eax
c010a3fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a3ff:	c7 44 24 08 34 e3 10 	movl   $0xc010e334,0x8(%esp)
c010a406:	c0 
c010a407:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c010a40e:	00 
c010a40f:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a416:	e8 d0 69 ff ff       	call   c0100deb <__panic>

c010a41b <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a41b:	55                   	push   %ebp
c010a41c:	89 e5                	mov    %esp,%ebp
c010a41e:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a421:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a426:	8b 40 18             	mov    0x18(%eax),%eax
c010a429:	85 c0                	test   %eax,%eax
c010a42b:	74 1c                	je     c010a449 <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a42d:	c7 44 24 08 54 e3 10 	movl   $0xc010e354,0x8(%esp)
c010a434:	c0 
c010a435:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c010a43c:	00 
c010a43d:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a444:	e8 a2 69 ff ff       	call   c0100deb <__panic>
    }

    int ret = -E_NO_MEM;
c010a449:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a450:	e8 c4 dd ff ff       	call   c0108219 <mm_create>
c010a455:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a458:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a45c:	0f 84 c0 05 00 00    	je     c010aa22 <load_icode+0x607>
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a462:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a465:	89 04 24             	mov    %eax,(%esp)
c010a468:	e8 8c f9 ff ff       	call   c0109df9 <setup_pgdir>
c010a46d:	85 c0                	test   %eax,%eax
c010a46f:	0f 85 9f 05 00 00    	jne    c010aa14 <load_icode+0x5f9>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a475:	8b 45 08             	mov    0x8(%ebp),%eax
c010a478:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a47b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a47e:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a481:	8b 45 08             	mov    0x8(%ebp),%eax
c010a484:	01 d0                	add    %edx,%eax
c010a486:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a489:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a48c:	8b 00                	mov    (%eax),%eax
c010a48e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a493:	74 0c                	je     c010a4a1 <load_icode+0x86>
        ret = -E_INVAL_ELF;
c010a495:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a49c:	e9 66 05 00 00       	jmp    c010aa07 <load_icode+0x5ec>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a4a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a4a4:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a4a8:	c1 e0 05             	shl    $0x5,%eax
c010a4ab:	89 c2                	mov    %eax,%edx
c010a4ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4b0:	01 d0                	add    %edx,%eax
c010a4b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph++) {
c010a4b5:	e9 01 03 00 00       	jmp    c010a7bb <load_icode+0x3a0>
        //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a4ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4bd:	8b 00                	mov    (%eax),%eax
c010a4bf:	83 f8 01             	cmp    $0x1,%eax
c010a4c2:	0f 85 e8 02 00 00    	jne    c010a7b0 <load_icode+0x395>
            continue;
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a4c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4cb:	8b 50 10             	mov    0x10(%eax),%edx
c010a4ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4d1:	8b 40 14             	mov    0x14(%eax),%eax
c010a4d4:	39 c2                	cmp    %eax,%edx
c010a4d6:	76 0c                	jbe    c010a4e4 <load_icode+0xc9>
            ret = -E_INVAL_ELF;
c010a4d8:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a4df:	e9 18 05 00 00       	jmp    c010a9fc <load_icode+0x5e1>
        }
        if (ph->p_filesz == 0) {
c010a4e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a4e7:	8b 40 10             	mov    0x10(%eax),%eax
c010a4ea:	85 c0                	test   %eax,%eax
c010a4ec:	0f 84 c1 02 00 00    	je     c010a7b3 <load_icode+0x398>
            continue;
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a4f2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a4f9:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X)
c010a500:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a503:	8b 40 18             	mov    0x18(%eax),%eax
c010a506:	83 e0 01             	and    $0x1,%eax
c010a509:	85 c0                	test   %eax,%eax
c010a50b:	74 04                	je     c010a511 <load_icode+0xf6>
            vm_flags |= VM_EXEC;
c010a50d:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W)
c010a511:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a514:	8b 40 18             	mov    0x18(%eax),%eax
c010a517:	83 e0 02             	and    $0x2,%eax
c010a51a:	85 c0                	test   %eax,%eax
c010a51c:	74 04                	je     c010a522 <load_icode+0x107>
            vm_flags |= VM_WRITE;
c010a51e:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R)
c010a522:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a525:	8b 40 18             	mov    0x18(%eax),%eax
c010a528:	83 e0 04             	and    $0x4,%eax
c010a52b:	85 c0                	test   %eax,%eax
c010a52d:	74 04                	je     c010a533 <load_icode+0x118>
            vm_flags |= VM_READ;
c010a52f:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE)
c010a533:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a536:	83 e0 02             	and    $0x2,%eax
c010a539:	85 c0                	test   %eax,%eax
c010a53b:	74 04                	je     c010a541 <load_icode+0x126>
            perm |= PTE_W;
c010a53d:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a541:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a544:	8b 50 14             	mov    0x14(%eax),%edx
c010a547:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a54a:	8b 40 08             	mov    0x8(%eax),%eax
c010a54d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a554:	00 
c010a555:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a558:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a55c:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a560:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a564:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a567:	89 04 24             	mov    %eax,(%esp)
c010a56a:	e8 ba e0 ff ff       	call   c0108629 <mm_map>
c010a56f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a572:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a576:	0f 85 76 04 00 00    	jne    c010a9f2 <load_icode+0x5d7>
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c010a57c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a57f:	8b 50 04             	mov    0x4(%eax),%edx
c010a582:	8b 45 08             	mov    0x8(%ebp),%eax
c010a585:	01 d0                	add    %edx,%eax
c010a587:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a58a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a58d:	8b 40 08             	mov    0x8(%eax),%eax
c010a590:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a593:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a596:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010a599:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a59c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a5a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a5a4:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a5ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5ae:	8b 50 08             	mov    0x8(%eax),%edx
c010a5b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a5b4:	8b 40 10             	mov    0x10(%eax),%eax
c010a5b7:	01 d0                	add    %edx,%eax
c010a5b9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a5bc:	e9 87 00 00 00       	jmp    c010a648 <load_icode+0x22d>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a5c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5c4:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a5ca:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a5ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a5d1:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a5d5:	89 04 24             	mov    %eax,(%esp)
c010a5d8:	e8 4c bb ff ff       	call   c0106129 <pgdir_alloc_page>
c010a5dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a5e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a5e4:	0f 84 0b 04 00 00    	je     c010a9f5 <load_icode+0x5da>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a5ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a5ed:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a5f0:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a5f3:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a5f8:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a5fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a5fe:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a605:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a608:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a60b:	73 09                	jae    c010a616 <load_icode+0x1fb>
                size -= la - end;
c010a60d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a610:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a613:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a616:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a619:	89 04 24             	mov    %eax,(%esp)
c010a61c:	e8 52 f0 ff ff       	call   c0109673 <page2kva>
c010a621:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a624:	01 c2                	add    %eax,%edx
c010a626:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a629:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a62d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a630:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a634:	89 14 24             	mov    %edx,(%esp)
c010a637:	e8 87 1a 00 00       	call   c010c0c3 <memcpy>
            start += size, from += size;
c010a63c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a63f:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a642:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a645:	01 45 e0             	add    %eax,-0x20(%ebp)
        while (start < end) {
c010a648:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a64b:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a64e:	0f 82 6d ff ff ff    	jb     c010a5c1 <load_icode+0x1a6>
        }

        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a654:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a657:	8b 50 08             	mov    0x8(%eax),%edx
c010a65a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a65d:	8b 40 14             	mov    0x14(%eax),%eax
c010a660:	01 d0                	add    %edx,%eax
c010a662:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        if (start < la) {
c010a665:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a668:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a66b:	0f 83 31 01 00 00    	jae    c010a7a2 <load_icode+0x387>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a671:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a674:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a677:	0f 84 39 01 00 00    	je     c010a7b6 <load_icode+0x39b>
                continue;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a67d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a680:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a683:	05 00 10 00 00       	add    $0x1000,%eax
c010a688:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a68b:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a690:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a693:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a696:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a699:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a69c:	73 09                	jae    c010a6a7 <load_icode+0x28c>
                size -= la - end;
c010a69e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6a1:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a6a4:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a6a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6aa:	89 04 24             	mov    %eax,(%esp)
c010a6ad:	e8 c1 ef ff ff       	call   c0109673 <page2kva>
c010a6b2:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a6b5:	01 c2                	add    %eax,%edx
c010a6b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a6be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a6c5:	00 
c010a6c6:	89 14 24             	mov    %edx,(%esp)
c010a6c9:	e8 10 19 00 00       	call   c010bfde <memset>
            start += size;
c010a6ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6d1:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a6d4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6d7:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a6da:	73 0c                	jae    c010a6e8 <load_icode+0x2cd>
c010a6dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6df:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a6e2:	0f 84 ba 00 00 00    	je     c010a7a2 <load_icode+0x387>
c010a6e8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a6eb:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a6ee:	72 0c                	jb     c010a6fc <load_icode+0x2e1>
c010a6f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a6f3:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a6f6:	0f 84 a6 00 00 00    	je     c010a7a2 <load_icode+0x387>
c010a6fc:	c7 44 24 0c 7c e3 10 	movl   $0xc010e37c,0xc(%esp)
c010a703:	c0 
c010a704:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010a70b:	c0 
c010a70c:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c010a713:	00 
c010a714:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a71b:	e8 cb 66 ff ff       	call   c0100deb <__panic>
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a720:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a723:	8b 40 0c             	mov    0xc(%eax),%eax
c010a726:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a729:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a72d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a730:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a734:	89 04 24             	mov    %eax,(%esp)
c010a737:	e8 ed b9 ff ff       	call   c0106129 <pgdir_alloc_page>
c010a73c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a73f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a743:	0f 84 af 02 00 00    	je     c010a9f8 <load_icode+0x5dd>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a749:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a74c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a74f:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010a752:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a757:	2b 45 b0             	sub    -0x50(%ebp),%eax
c010a75a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a75d:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a764:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a767:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a76a:	73 09                	jae    c010a775 <load_icode+0x35a>
                size -= la - end;
c010a76c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a76f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a772:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a775:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a778:	89 04 24             	mov    %eax,(%esp)
c010a77b:	e8 f3 ee ff ff       	call   c0109673 <page2kva>
c010a780:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010a783:	01 c2                	add    %eax,%edx
c010a785:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a788:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a78c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a793:	00 
c010a794:	89 14 24             	mov    %edx,(%esp)
c010a797:	e8 42 18 00 00       	call   c010bfde <memset>
            start += size;
c010a79c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a79f:	01 45 d8             	add    %eax,-0x28(%ebp)
        while (start < end) {
c010a7a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a7a5:	3b 45 b4             	cmp    -0x4c(%ebp),%eax
c010a7a8:	0f 82 72 ff ff ff    	jb     c010a720 <load_icode+0x305>
c010a7ae:	eb 07                	jmp    c010a7b7 <load_icode+0x39c>
            continue;
c010a7b0:	90                   	nop
c010a7b1:	eb 04                	jmp    c010a7b7 <load_icode+0x39c>
            continue;
c010a7b3:	90                   	nop
c010a7b4:	eb 01                	jmp    c010a7b7 <load_icode+0x39c>
                continue;
c010a7b6:	90                   	nop
    for (; ph < ph_end; ph++) {
c010a7b7:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a7bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7be:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a7c1:	0f 82 f3 fc ff ff    	jb     c010a4ba <load_icode+0x9f>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a7c7:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a7ce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a7d5:	00 
c010a7d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a7d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a7dd:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a7e4:	00 
c010a7e5:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a7ec:	af 
c010a7ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7f0:	89 04 24             	mov    %eax,(%esp)
c010a7f3:	e8 31 de ff ff       	call   c0108629 <mm_map>
c010a7f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a7fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a7ff:	0f 85 f6 01 00 00    	jne    c010a9fb <load_icode+0x5e0>
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
c010a805:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a808:	8b 40 0c             	mov    0xc(%eax),%eax
c010a80b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a812:	00 
c010a813:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a81a:	af 
c010a81b:	89 04 24             	mov    %eax,(%esp)
c010a81e:	e8 06 b9 ff ff       	call   c0106129 <pgdir_alloc_page>
c010a823:	85 c0                	test   %eax,%eax
c010a825:	75 24                	jne    c010a84b <load_icode+0x430>
c010a827:	c7 44 24 0c cc e3 10 	movl   $0xc010e3cc,0xc(%esp)
c010a82e:	c0 
c010a82f:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010a836:	c0 
c010a837:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c010a83e:	00 
c010a83f:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a846:	e8 a0 65 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
c010a84b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a84e:	8b 40 0c             	mov    0xc(%eax),%eax
c010a851:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a858:	00 
c010a859:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a860:	af 
c010a861:	89 04 24             	mov    %eax,(%esp)
c010a864:	e8 c0 b8 ff ff       	call   c0106129 <pgdir_alloc_page>
c010a869:	85 c0                	test   %eax,%eax
c010a86b:	75 24                	jne    c010a891 <load_icode+0x476>
c010a86d:	c7 44 24 0c 10 e4 10 	movl   $0xc010e410,0xc(%esp)
c010a874:	c0 
c010a875:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010a87c:	c0 
c010a87d:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c010a884:	00 
c010a885:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a88c:	e8 5a 65 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
c010a891:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a894:	8b 40 0c             	mov    0xc(%eax),%eax
c010a897:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a89e:	00 
c010a89f:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a8a6:	af 
c010a8a7:	89 04 24             	mov    %eax,(%esp)
c010a8aa:	e8 7a b8 ff ff       	call   c0106129 <pgdir_alloc_page>
c010a8af:	85 c0                	test   %eax,%eax
c010a8b1:	75 24                	jne    c010a8d7 <load_icode+0x4bc>
c010a8b3:	c7 44 24 0c 58 e4 10 	movl   $0xc010e458,0xc(%esp)
c010a8ba:	c0 
c010a8bb:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010a8c2:	c0 
c010a8c3:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
c010a8ca:	00 
c010a8cb:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a8d2:	e8 14 65 ff ff       	call   c0100deb <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
c010a8d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a8da:	8b 40 0c             	mov    0xc(%eax),%eax
c010a8dd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a8e4:	00 
c010a8e5:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a8ec:	af 
c010a8ed:	89 04 24             	mov    %eax,(%esp)
c010a8f0:	e8 34 b8 ff ff       	call   c0106129 <pgdir_alloc_page>
c010a8f5:	85 c0                	test   %eax,%eax
c010a8f7:	75 24                	jne    c010a91d <load_icode+0x502>
c010a8f9:	c7 44 24 0c a0 e4 10 	movl   $0xc010e4a0,0xc(%esp)
c010a900:	c0 
c010a901:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010a908:	c0 
c010a909:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c010a910:	00 
c010a911:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a918:	e8 ce 64 ff ff       	call   c0100deb <__panic>

    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a91d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a920:	89 04 24             	mov    %eax,(%esp)
c010a923:	e8 b4 ee ff ff       	call   c01097dc <mm_count_inc>
    current->mm = mm;
c010a928:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a92d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a930:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a933:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a936:	8b 40 0c             	mov    0xc(%eax),%eax
c010a939:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a93c:	81 7d c4 ff ff ff bf 	cmpl   $0xbfffffff,-0x3c(%ebp)
c010a943:	77 23                	ja     c010a968 <load_icode+0x54d>
c010a945:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a948:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a94c:	c7 44 24 08 7c e2 10 	movl   $0xc010e27c,0x8(%esp)
c010a953:	c0 
c010a954:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c010a95b:	00 
c010a95c:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a963:	e8 83 64 ff ff       	call   c0100deb <__panic>
c010a968:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a96b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c010a971:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a976:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a979:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a97c:	8b 40 0c             	mov    0xc(%eax),%eax
c010a97f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010a982:	81 7d c0 ff ff ff bf 	cmpl   $0xbfffffff,-0x40(%ebp)
c010a989:	77 23                	ja     c010a9ae <load_icode+0x593>
c010a98b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a98e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a992:	c7 44 24 08 7c e2 10 	movl   $0xc010e27c,0x8(%esp)
c010a999:	c0 
c010a99a:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
c010a9a1:	00 
c010a9a2:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010a9a9:	e8 3d 64 ff ff       	call   c0100deb <__panic>
c010a9ae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a9b1:	05 00 00 00 40       	add    $0x40000000,%eax
c010a9b6:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010a9b9:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a9bc:	0f 22 d8             	mov    %eax,%cr3
}
c010a9bf:	90                   	nop

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a9c0:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010a9c5:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a9c8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a9cb:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a9d2:	00 
c010a9d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a9da:	00 
c010a9db:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a9de:	89 04 24             	mov    %eax,(%esp)
c010a9e1:	e8 f8 15 00 00       	call   c010bfde <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    ret = 0;
c010a9e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a9ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9f0:	eb 33                	jmp    c010aa25 <load_icode+0x60a>
            goto bad_cleanup_mmap;
c010a9f2:	90                   	nop
c010a9f3:	eb 07                	jmp    c010a9fc <load_icode+0x5e1>
                goto bad_cleanup_mmap;
c010a9f5:	90                   	nop
c010a9f6:	eb 04                	jmp    c010a9fc <load_icode+0x5e1>
                goto bad_cleanup_mmap;
c010a9f8:	90                   	nop
c010a9f9:	eb 01                	jmp    c010a9fc <load_icode+0x5e1>
        goto bad_cleanup_mmap;
c010a9fb:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
c010a9fc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a9ff:	89 04 24             	mov    %eax,(%esp)
c010aa02:	e8 3d de ff ff       	call   c0108844 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010aa07:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aa0a:	89 04 24             	mov    %eax,(%esp)
c010aa0d:	e8 90 f4 ff ff       	call   c0109ea2 <put_pgdir>
c010aa12:	eb 01                	jmp    c010aa15 <load_icode+0x5fa>
        goto bad_pgdir_cleanup_mm;
c010aa14:	90                   	nop
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010aa15:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010aa18:	89 04 24             	mov    %eax,(%esp)
c010aa1b:	e8 62 db ff ff       	call   c0108582 <mm_destroy>
bad_mm:
    goto out;
c010aa20:	eb cb                	jmp    c010a9ed <load_icode+0x5d2>
        goto bad_mm;
c010aa22:	90                   	nop
    goto out;
c010aa23:	eb c8                	jmp    c010a9ed <load_icode+0x5d2>
}
c010aa25:	89 ec                	mov    %ebp,%esp
c010aa27:	5d                   	pop    %ebp
c010aa28:	c3                   	ret    

c010aa29 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010aa29:	55                   	push   %ebp
c010aa2a:	89 e5                	mov    %esp,%ebp
c010aa2c:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010aa2f:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010aa34:	8b 40 18             	mov    0x18(%eax),%eax
c010aa37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010aa3a:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa3d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010aa44:	00 
c010aa45:	8b 55 0c             	mov    0xc(%ebp),%edx
c010aa48:	89 54 24 08          	mov    %edx,0x8(%esp)
c010aa4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa53:	89 04 24             	mov    %eax,(%esp)
c010aa56:	e8 7f e8 ff ff       	call   c01092da <user_mem_check>
c010aa5b:	85 c0                	test   %eax,%eax
c010aa5d:	75 0a                	jne    c010aa69 <do_execve+0x40>
        return -E_INVAL;
c010aa5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010aa64:	e9 f7 00 00 00       	jmp    c010ab60 <do_execve+0x137>
    }
    if (len > PROC_NAME_LEN) {
c010aa69:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010aa6d:	76 07                	jbe    c010aa76 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010aa6f:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010aa76:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010aa7d:	00 
c010aa7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010aa85:	00 
c010aa86:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010aa89:	89 04 24             	mov    %eax,(%esp)
c010aa8c:	e8 4d 15 00 00       	call   c010bfde <memset>
    memcpy(local_name, name, len);
c010aa91:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa94:	89 44 24 08          	mov    %eax,0x8(%esp)
c010aa98:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa9f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010aaa2:	89 04 24             	mov    %eax,(%esp)
c010aaa5:	e8 19 16 00 00       	call   c010c0c3 <memcpy>

    if (mm != NULL) {
c010aaaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aaae:	74 4b                	je     c010aafb <do_execve+0xd2>
        lcr3(boot_cr3);
c010aab0:	a1 a8 3f 1a c0       	mov    0xc01a3fa8,%eax
c010aab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010aab8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aabb:	0f 22 d8             	mov    %eax,%cr3
}
c010aabe:	90                   	nop
        if (mm_count_dec(mm) == 0) {
c010aabf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aac2:	89 04 24             	mov    %eax,(%esp)
c010aac5:	e8 2c ed ff ff       	call   c01097f6 <mm_count_dec>
c010aaca:	85 c0                	test   %eax,%eax
c010aacc:	75 21                	jne    c010aaef <do_execve+0xc6>
            exit_mmap(mm);
c010aace:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aad1:	89 04 24             	mov    %eax,(%esp)
c010aad4:	e8 6b dd ff ff       	call   c0108844 <exit_mmap>
            put_pgdir(mm);
c010aad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aadc:	89 04 24             	mov    %eax,(%esp)
c010aadf:	e8 be f3 ff ff       	call   c0109ea2 <put_pgdir>
            mm_destroy(mm);
c010aae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aae7:	89 04 24             	mov    %eax,(%esp)
c010aaea:	e8 93 da ff ff       	call   c0108582 <mm_destroy>
        }
        current->mm = NULL;
c010aaef:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010aaf4:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010aafb:	8b 45 14             	mov    0x14(%ebp),%eax
c010aafe:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab02:	8b 45 10             	mov    0x10(%ebp),%eax
c010ab05:	89 04 24             	mov    %eax,(%esp)
c010ab08:	e8 0e f9 ff ff       	call   c010a41b <load_icode>
c010ab0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ab10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ab14:	75 1b                	jne    c010ab31 <do_execve+0x108>
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010ab16:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ab1b:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010ab1e:	89 54 24 04          	mov    %edx,0x4(%esp)
c010ab22:	89 04 24             	mov    %eax,(%esp)
c010ab25:	e8 80 ed ff ff       	call   c01098aa <set_proc_name>
    return 0;
c010ab2a:	b8 00 00 00 00       	mov    $0x0,%eax
c010ab2f:	eb 2f                	jmp    c010ab60 <do_execve+0x137>
        goto execve_exit;
c010ab31:	90                   	nop

execve_exit:
    do_exit(ret);
c010ab32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab35:	89 04 24             	mov    %eax,(%esp)
c010ab38:	e8 0e f7 ff ff       	call   c010a24b <do_exit>
    panic("already exit: %e.\n", ret);
c010ab3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab40:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ab44:	c7 44 24 08 e6 e4 10 	movl   $0xc010e4e6,0x8(%esp)
c010ab4b:	c0 
c010ab4c:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
c010ab53:	00 
c010ab54:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010ab5b:	e8 8b 62 ff ff       	call   c0100deb <__panic>
}
c010ab60:	89 ec                	mov    %ebp,%esp
c010ab62:	5d                   	pop    %ebp
c010ab63:	c3                   	ret    

c010ab64 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010ab64:	55                   	push   %ebp
c010ab65:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010ab67:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ab6c:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010ab73:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ab78:	5d                   	pop    %ebp
c010ab79:	c3                   	ret    

c010ab7a <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010ab7a:	55                   	push   %ebp
c010ab7b:	89 e5                	mov    %esp,%ebp
c010ab7d:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010ab80:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ab85:	8b 40 18             	mov    0x18(%eax),%eax
c010ab88:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010ab8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010ab8f:	74 30                	je     c010abc1 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010ab91:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab94:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010ab9b:	00 
c010ab9c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010aba3:	00 
c010aba4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010abab:	89 04 24             	mov    %eax,(%esp)
c010abae:	e8 27 e7 ff ff       	call   c01092da <user_mem_check>
c010abb3:	85 c0                	test   %eax,%eax
c010abb5:	75 0a                	jne    c010abc1 <do_wait+0x47>
            return -E_INVAL;
c010abb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010abbc:	e9 47 01 00 00       	jmp    c010ad08 <do_wait+0x18e>
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
c010abc1:	90                   	nop
    haskid = 0;
c010abc2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010abc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010abcd:	74 36                	je     c010ac05 <do_wait+0x8b>
        proc = find_proc(pid);
c010abcf:	8b 45 08             	mov    0x8(%ebp),%eax
c010abd2:	89 04 24             	mov    %eax,(%esp)
c010abd5:	e8 ce f0 ff ff       	call   c0109ca8 <find_proc>
c010abda:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010abdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010abe1:	74 4f                	je     c010ac32 <do_wait+0xb8>
c010abe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abe6:	8b 50 14             	mov    0x14(%eax),%edx
c010abe9:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010abee:	39 c2                	cmp    %eax,%edx
c010abf0:	75 40                	jne    c010ac32 <do_wait+0xb8>
            haskid = 1;
c010abf2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010abf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010abfc:	8b 00                	mov    (%eax),%eax
c010abfe:	83 f8 03             	cmp    $0x3,%eax
c010ac01:	75 2f                	jne    c010ac32 <do_wait+0xb8>
                goto found;
c010ac03:	eb 7e                	jmp    c010ac83 <do_wait+0x109>
            }
        }
    } else {
        proc = current->cptr;
c010ac05:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ac0a:	8b 40 70             	mov    0x70(%eax),%eax
c010ac0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010ac10:	eb 1a                	jmp    c010ac2c <do_wait+0xb2>
            haskid = 1;
c010ac12:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010ac19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac1c:	8b 00                	mov    (%eax),%eax
c010ac1e:	83 f8 03             	cmp    $0x3,%eax
c010ac21:	74 5f                	je     c010ac82 <do_wait+0x108>
        for (; proc != NULL; proc = proc->optr) {
c010ac23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ac26:	8b 40 78             	mov    0x78(%eax),%eax
c010ac29:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ac2c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ac30:	75 e0                	jne    c010ac12 <do_wait+0x98>
                goto found;
            }
        }
    }
    if (haskid) {
c010ac32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010ac36:	74 40                	je     c010ac78 <do_wait+0xfe>
        current->state = PROC_SLEEPING;
c010ac38:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ac3d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010ac43:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ac48:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010ac4f:	e8 15 06 00 00       	call   c010b269 <schedule>
        if (current->flags & PF_EXITING) {
c010ac54:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010ac59:	8b 40 44             	mov    0x44(%eax),%eax
c010ac5c:	83 e0 01             	and    $0x1,%eax
c010ac5f:	85 c0                	test   %eax,%eax
c010ac61:	0f 84 5b ff ff ff    	je     c010abc2 <do_wait+0x48>
            do_exit(-E_KILLED);
c010ac67:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010ac6e:	e8 d8 f5 ff ff       	call   c010a24b <do_exit>
        }
        goto repeat;
c010ac73:	e9 4a ff ff ff       	jmp    c010abc2 <do_wait+0x48>
    }
    return -E_BAD_PROC;
c010ac78:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010ac7d:	e9 86 00 00 00       	jmp    c010ad08 <do_wait+0x18e>
                goto found;
c010ac82:	90                   	nop

found:
    if (proc == idleproc || proc == initproc) {
c010ac83:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010ac88:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ac8b:	74 0a                	je     c010ac97 <do_wait+0x11d>
c010ac8d:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010ac92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010ac95:	75 1c                	jne    c010acb3 <do_wait+0x139>
        panic("wait idleproc or initproc.\n");
c010ac97:	c7 44 24 08 f9 e4 10 	movl   $0xc010e4f9,0x8(%esp)
c010ac9e:	c0 
c010ac9f:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
c010aca6:	00 
c010aca7:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010acae:	e8 38 61 ff ff       	call   c0100deb <__panic>
    }
    if (code_store != NULL) {
c010acb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010acb7:	74 0b                	je     c010acc4 <do_wait+0x14a>
        *code_store = proc->exit_code;
c010acb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acbc:	8b 50 68             	mov    0x68(%eax),%edx
c010acbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010acc2:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010acc4:	e8 4c ea ff ff       	call   c0109715 <__intr_save>
c010acc9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010accc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010accf:	89 04 24             	mov    %eax,(%esp)
c010acd2:	e8 99 ef ff ff       	call   c0109c70 <unhash_proc>
        remove_links(proc);
c010acd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acda:	89 04 24             	mov    %eax,(%esp)
c010acdd:	e8 fa ec ff ff       	call   c01099dc <remove_links>
    }
    local_intr_restore(intr_flag);
c010ace2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ace5:	89 04 24             	mov    %eax,(%esp)
c010ace8:	e8 54 ea ff ff       	call   c0109741 <__intr_restore>
    put_kstack(proc);
c010aced:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acf0:	89 04 24             	mov    %eax,(%esp)
c010acf3:	e8 d8 f0 ff ff       	call   c0109dd0 <put_kstack>
    kfree(proc);
c010acf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acfb:	89 04 24             	mov    %eax,(%esp)
c010acfe:	e8 c9 a1 ff ff       	call   c0104ecc <kfree>
    return 0;
c010ad03:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ad08:	89 ec                	mov    %ebp,%esp
c010ad0a:	5d                   	pop    %ebp
c010ad0b:	c3                   	ret    

c010ad0c <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010ad0c:	55                   	push   %ebp
c010ad0d:	89 e5                	mov    %esp,%ebp
c010ad0f:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010ad12:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad15:	89 04 24             	mov    %eax,(%esp)
c010ad18:	e8 8b ef ff ff       	call   c0109ca8 <find_proc>
c010ad1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ad20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ad24:	74 41                	je     c010ad67 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010ad26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad29:	8b 40 44             	mov    0x44(%eax),%eax
c010ad2c:	83 e0 01             	and    $0x1,%eax
c010ad2f:	85 c0                	test   %eax,%eax
c010ad31:	75 2d                	jne    c010ad60 <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010ad33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad36:	8b 40 44             	mov    0x44(%eax),%eax
c010ad39:	83 c8 01             	or     $0x1,%eax
c010ad3c:	89 c2                	mov    %eax,%edx
c010ad3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad41:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ad44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad47:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ad4a:	85 c0                	test   %eax,%eax
c010ad4c:	79 0b                	jns    c010ad59 <do_kill+0x4d>
                wakeup_proc(proc);
c010ad4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ad51:	89 04 24             	mov    %eax,(%esp)
c010ad54:	e8 89 04 00 00       	call   c010b1e2 <wakeup_proc>
            }
            return 0;
c010ad59:	b8 00 00 00 00       	mov    $0x0,%eax
c010ad5e:	eb 0c                	jmp    c010ad6c <do_kill+0x60>
        }
        return -E_KILLED;
c010ad60:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ad65:	eb 05                	jmp    c010ad6c <do_kill+0x60>
    }
    return -E_INVAL;
c010ad67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010ad6c:	89 ec                	mov    %ebp,%esp
c010ad6e:	5d                   	pop    %ebp
c010ad6f:	c3                   	ret    

c010ad70 <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010ad70:	55                   	push   %ebp
c010ad71:	89 e5                	mov    %esp,%ebp
c010ad73:	57                   	push   %edi
c010ad74:	56                   	push   %esi
c010ad75:	53                   	push   %ebx
c010ad76:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ad79:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad7c:	89 04 24             	mov    %eax,(%esp)
c010ad7f:	e8 30 0f 00 00       	call   c010bcb4 <strlen>
c010ad84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile(
c010ad87:	b8 04 00 00 00       	mov    $0x4,%eax
c010ad8c:	8b 55 08             	mov    0x8(%ebp),%edx
c010ad8f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010ad92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010ad95:	8b 75 10             	mov    0x10(%ebp),%esi
c010ad98:	89 f7                	mov    %esi,%edi
c010ad9a:	cd 80                	int    $0x80
c010ad9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a"(ret)
        : "i"(T_SYSCALL), "0"(SYS_exec), "d"(name), "c"(len), "b"(binary), "D"(size)
        : "memory");
    return ret;
c010ad9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010ada2:	83 c4 2c             	add    $0x2c,%esp
c010ada5:	5b                   	pop    %ebx
c010ada6:	5e                   	pop    %esi
c010ada7:	5f                   	pop    %edi
c010ada8:	5d                   	pop    %ebp
c010ada9:	c3                   	ret    

c010adaa <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010adaa:	55                   	push   %ebp
c010adab:	89 e5                	mov    %esp,%ebp
c010adad:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
c010adb0:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010adb5:	8b 40 04             	mov    0x4(%eax),%eax
c010adb8:	c7 44 24 08 15 e5 10 	movl   $0xc010e515,0x8(%esp)
c010adbf:	c0 
c010adc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010adc4:	c7 04 24 1c e5 10 c0 	movl   $0xc010e51c,(%esp)
c010adcb:	e8 9d 55 ff ff       	call   c010036d <cprintf>
c010add0:	b8 70 78 00 00       	mov    $0x7870,%eax
c010add5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010add9:	c7 44 24 04 84 64 14 	movl   $0xc0146484,0x4(%esp)
c010ade0:	c0 
c010ade1:	c7 04 24 15 e5 10 c0 	movl   $0xc010e515,(%esp)
c010ade8:	e8 83 ff ff ff       	call   c010ad70 <kernel_execve>
#endif
    panic("user_main execve failed.\n");
c010aded:	c7 44 24 08 43 e5 10 	movl   $0xc010e543,0x8(%esp)
c010adf4:	c0 
c010adf5:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
c010adfc:	00 
c010adfd:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010ae04:	e8 e2 5f ff ff       	call   c0100deb <__panic>

c010ae09 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ae09:	55                   	push   %ebp
c010ae0a:	89 e5                	mov    %esp,%ebp
c010ae0c:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ae0f:	e8 ce a5 ff ff       	call   c01053e2 <nr_free_pages>
c010ae14:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ae17:	e8 70 9f ff ff       	call   c0104d8c <kallocated>
c010ae1c:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ae1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ae26:	00 
c010ae27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ae2e:	00 
c010ae2f:	c7 04 24 aa ad 10 c0 	movl   $0xc010adaa,(%esp)
c010ae36:	e8 e1 ee ff ff       	call   c0109d1c <kernel_thread>
c010ae3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ae3e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ae42:	7f 21                	jg     c010ae65 <init_main+0x5c>
        panic("create user_main failed.\n");
c010ae44:	c7 44 24 08 5d e5 10 	movl   $0xc010e55d,0x8(%esp)
c010ae4b:	c0 
c010ae4c:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
c010ae53:	00 
c010ae54:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010ae5b:	e8 8b 5f ff ff       	call   c0100deb <__panic>
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
c010ae60:	e8 04 04 00 00       	call   c010b269 <schedule>
    while (do_wait(0, NULL) == 0) {
c010ae65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ae6c:	00 
c010ae6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ae74:	e8 01 fd ff ff       	call   c010ab7a <do_wait>
c010ae79:	85 c0                	test   %eax,%eax
c010ae7b:	74 e3                	je     c010ae60 <init_main+0x57>
    }

    cprintf("all user-mode processes have quit.\n");
c010ae7d:	c7 04 24 78 e5 10 c0 	movl   $0xc010e578,(%esp)
c010ae84:	e8 e4 54 ff ff       	call   c010036d <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010ae89:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010ae8e:	8b 40 70             	mov    0x70(%eax),%eax
c010ae91:	85 c0                	test   %eax,%eax
c010ae93:	75 18                	jne    c010aead <init_main+0xa4>
c010ae95:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010ae9a:	8b 40 74             	mov    0x74(%eax),%eax
c010ae9d:	85 c0                	test   %eax,%eax
c010ae9f:	75 0c                	jne    c010aead <init_main+0xa4>
c010aea1:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010aea6:	8b 40 78             	mov    0x78(%eax),%eax
c010aea9:	85 c0                	test   %eax,%eax
c010aeab:	74 24                	je     c010aed1 <init_main+0xc8>
c010aead:	c7 44 24 0c 9c e5 10 	movl   $0xc010e59c,0xc(%esp)
c010aeb4:	c0 
c010aeb5:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010aebc:	c0 
c010aebd:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
c010aec4:	00 
c010aec5:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010aecc:	e8 1a 5f ff ff       	call   c0100deb <__panic>
    assert(nr_process == 2);
c010aed1:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010aed6:	83 f8 02             	cmp    $0x2,%eax
c010aed9:	74 24                	je     c010aeff <init_main+0xf6>
c010aedb:	c7 44 24 0c e7 e5 10 	movl   $0xc010e5e7,0xc(%esp)
c010aee2:	c0 
c010aee3:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010aeea:	c0 
c010aeeb:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
c010aef2:	00 
c010aef3:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010aefa:	e8 ec 5e ff ff       	call   c0100deb <__panic>
c010aeff:	c7 45 e8 20 41 1a c0 	movl   $0xc01a4120,-0x18(%ebp)
    return listelm->next;
c010af06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010af09:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010af0c:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c010af12:	83 c2 58             	add    $0x58,%edx
c010af15:	39 d0                	cmp    %edx,%eax
c010af17:	74 24                	je     c010af3d <init_main+0x134>
c010af19:	c7 44 24 0c f8 e5 10 	movl   $0xc010e5f8,0xc(%esp)
c010af20:	c0 
c010af21:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010af28:	c0 
c010af29:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
c010af30:	00 
c010af31:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010af38:	e8 ae 5e ff ff       	call   c0100deb <__panic>
c010af3d:	c7 45 e4 20 41 1a c0 	movl   $0xc01a4120,-0x1c(%ebp)
    return listelm->prev;
c010af44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010af47:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010af49:	8b 15 2c 41 1a c0    	mov    0xc01a412c,%edx
c010af4f:	83 c2 58             	add    $0x58,%edx
c010af52:	39 d0                	cmp    %edx,%eax
c010af54:	74 24                	je     c010af7a <init_main+0x171>
c010af56:	c7 44 24 0c 28 e6 10 	movl   $0xc010e628,0xc(%esp)
c010af5d:	c0 
c010af5e:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010af65:	c0 
c010af66:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
c010af6d:	00 
c010af6e:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010af75:	e8 71 5e ff ff       	call   c0100deb <__panic>

    cprintf("init check memory pass.\n");
c010af7a:	c7 04 24 58 e6 10 c0 	movl   $0xc010e658,(%esp)
c010af81:	e8 e7 53 ff ff       	call   c010036d <cprintf>
    return 0;
c010af86:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010af8b:	89 ec                	mov    %ebp,%esp
c010af8d:	5d                   	pop    %ebp
c010af8e:	c3                   	ret    

c010af8f <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void
proc_init(void) {
c010af8f:	55                   	push   %ebp
c010af90:	89 e5                	mov    %esp,%ebp
c010af92:	83 ec 28             	sub    $0x28,%esp
c010af95:	c7 45 ec 20 41 1a c0 	movl   $0xc01a4120,-0x14(%ebp)
    elm->prev = elm->next = elm;
c010af9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010af9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010afa2:	89 50 04             	mov    %edx,0x4(%eax)
c010afa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010afa8:	8b 50 04             	mov    0x4(%eax),%edx
c010afab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010afae:	89 10                	mov    %edx,(%eax)
}
c010afb0:	90                   	nop
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++) {
c010afb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010afb8:	eb 26                	jmp    c010afe0 <proc_init+0x51>
        list_init(hash_list + i);
c010afba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afbd:	c1 e0 03             	shl    $0x3,%eax
c010afc0:	05 40 41 1a c0       	add    $0xc01a4140,%eax
c010afc5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c010afc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afcb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010afce:	89 50 04             	mov    %edx,0x4(%eax)
c010afd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afd4:	8b 50 04             	mov    0x4(%eax),%edx
c010afd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afda:	89 10                	mov    %edx,(%eax)
}
c010afdc:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i++) {
c010afdd:	ff 45 f4             	incl   -0xc(%ebp)
c010afe0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010afe7:	7e d1                	jle    c010afba <proc_init+0x2b>
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010afe9:	e8 60 e8 ff ff       	call   c010984e <alloc_proc>
c010afee:	a3 28 41 1a c0       	mov    %eax,0xc01a4128
c010aff3:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010aff8:	85 c0                	test   %eax,%eax
c010affa:	75 1c                	jne    c010b018 <proc_init+0x89>
        panic("cannot alloc idleproc.\n");
c010affc:	c7 44 24 08 71 e6 10 	movl   $0xc010e671,0x8(%esp)
c010b003:	c0 
c010b004:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
c010b00b:	00 
c010b00c:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010b013:	e8 d3 5d ff ff       	call   c0100deb <__panic>
    }

    idleproc->pid = 0;
c010b018:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b01d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010b024:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b029:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010b02f:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b034:	ba 00 d0 12 c0       	mov    $0xc012d000,%edx
c010b039:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010b03c:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b041:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010b048:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b04d:	c7 44 24 04 89 e6 10 	movl   $0xc010e689,0x4(%esp)
c010b054:	c0 
c010b055:	89 04 24             	mov    %eax,(%esp)
c010b058:	e8 4d e8 ff ff       	call   c01098aa <set_proc_name>
    nr_process++;
c010b05d:	a1 40 61 1a c0       	mov    0xc01a6140,%eax
c010b062:	40                   	inc    %eax
c010b063:	a3 40 61 1a c0       	mov    %eax,0xc01a6140

    current = idleproc;
c010b068:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b06d:	a3 30 41 1a c0       	mov    %eax,0xc01a4130

    int pid = kernel_thread(init_main, NULL, 0);
c010b072:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010b079:	00 
c010b07a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010b081:	00 
c010b082:	c7 04 24 09 ae 10 c0 	movl   $0xc010ae09,(%esp)
c010b089:	e8 8e ec ff ff       	call   c0109d1c <kernel_thread>
c010b08e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010b091:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b095:	7f 1c                	jg     c010b0b3 <proc_init+0x124>
        panic("create init_main failed.\n");
c010b097:	c7 44 24 08 8e e6 10 	movl   $0xc010e68e,0x8(%esp)
c010b09e:	c0 
c010b09f:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
c010b0a6:	00 
c010b0a7:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010b0ae:	e8 38 5d ff ff       	call   c0100deb <__panic>
    }

    initproc = find_proc(pid);
c010b0b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b0b6:	89 04 24             	mov    %eax,(%esp)
c010b0b9:	e8 ea eb ff ff       	call   c0109ca8 <find_proc>
c010b0be:	a3 2c 41 1a c0       	mov    %eax,0xc01a412c
    set_proc_name(initproc, "init");
c010b0c3:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010b0c8:	c7 44 24 04 a8 e6 10 	movl   $0xc010e6a8,0x4(%esp)
c010b0cf:	c0 
c010b0d0:	89 04 24             	mov    %eax,(%esp)
c010b0d3:	e8 d2 e7 ff ff       	call   c01098aa <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010b0d8:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b0dd:	85 c0                	test   %eax,%eax
c010b0df:	74 0c                	je     c010b0ed <proc_init+0x15e>
c010b0e1:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b0e6:	8b 40 04             	mov    0x4(%eax),%eax
c010b0e9:	85 c0                	test   %eax,%eax
c010b0eb:	74 24                	je     c010b111 <proc_init+0x182>
c010b0ed:	c7 44 24 0c b0 e6 10 	movl   $0xc010e6b0,0xc(%esp)
c010b0f4:	c0 
c010b0f5:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010b0fc:	c0 
c010b0fd:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
c010b104:	00 
c010b105:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010b10c:	e8 da 5c ff ff       	call   c0100deb <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010b111:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010b116:	85 c0                	test   %eax,%eax
c010b118:	74 0d                	je     c010b127 <proc_init+0x198>
c010b11a:	a1 2c 41 1a c0       	mov    0xc01a412c,%eax
c010b11f:	8b 40 04             	mov    0x4(%eax),%eax
c010b122:	83 f8 01             	cmp    $0x1,%eax
c010b125:	74 24                	je     c010b14b <proc_init+0x1bc>
c010b127:	c7 44 24 0c d8 e6 10 	movl   $0xc010e6d8,0xc(%esp)
c010b12e:	c0 
c010b12f:	c7 44 24 08 b5 e3 10 	movl   $0xc010e3b5,0x8(%esp)
c010b136:	c0 
c010b137:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
c010b13e:	00 
c010b13f:	c7 04 24 c1 e2 10 c0 	movl   $0xc010e2c1,(%esp)
c010b146:	e8 a0 5c ff ff       	call   c0100deb <__panic>
}
c010b14b:	90                   	nop
c010b14c:	89 ec                	mov    %ebp,%esp
c010b14e:	5d                   	pop    %ebp
c010b14f:	c3                   	ret    

c010b150 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010b150:	55                   	push   %ebp
c010b151:	89 e5                	mov    %esp,%ebp
c010b153:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010b156:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b15b:	8b 40 10             	mov    0x10(%eax),%eax
c010b15e:	85 c0                	test   %eax,%eax
c010b160:	74 f4                	je     c010b156 <cpu_idle+0x6>
            schedule();
c010b162:	e8 02 01 00 00       	call   c010b269 <schedule>
        if (current->need_resched) {
c010b167:	eb ed                	jmp    c010b156 <cpu_idle+0x6>

c010b169 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010b169:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010b16d:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010b16f:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010b172:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010b175:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010b178:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010b17b:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010b17e:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010b181:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010b184:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010b188:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010b18b:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010b18e:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010b191:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010b194:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010b197:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010b19a:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010b19d:	ff 30                	pushl  (%eax)

    ret
c010b19f:	c3                   	ret    

c010b1a0 <__intr_save>:
__intr_save(void) {
c010b1a0:	55                   	push   %ebp
c010b1a1:	89 e5                	mov    %esp,%ebp
c010b1a3:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010b1a6:	9c                   	pushf  
c010b1a7:	58                   	pop    %eax
c010b1a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010b1ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010b1ae:	25 00 02 00 00       	and    $0x200,%eax
c010b1b3:	85 c0                	test   %eax,%eax
c010b1b5:	74 0c                	je     c010b1c3 <__intr_save+0x23>
        intr_disable();
c010b1b7:	e8 e5 6e ff ff       	call   c01020a1 <intr_disable>
        return 1;
c010b1bc:	b8 01 00 00 00       	mov    $0x1,%eax
c010b1c1:	eb 05                	jmp    c010b1c8 <__intr_save+0x28>
    return 0;
c010b1c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b1c8:	89 ec                	mov    %ebp,%esp
c010b1ca:	5d                   	pop    %ebp
c010b1cb:	c3                   	ret    

c010b1cc <__intr_restore>:
__intr_restore(bool flag) {
c010b1cc:	55                   	push   %ebp
c010b1cd:	89 e5                	mov    %esp,%ebp
c010b1cf:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010b1d2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b1d6:	74 05                	je     c010b1dd <__intr_restore+0x11>
        intr_enable();
c010b1d8:	e8 bc 6e ff ff       	call   c0102099 <intr_enable>
}
c010b1dd:	90                   	nop
c010b1de:	89 ec                	mov    %ebp,%esp
c010b1e0:	5d                   	pop    %ebp
c010b1e1:	c3                   	ret    

c010b1e2 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010b1e2:	55                   	push   %ebp
c010b1e3:	89 e5                	mov    %esp,%ebp
c010b1e5:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b1e8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1eb:	8b 00                	mov    (%eax),%eax
c010b1ed:	83 f8 03             	cmp    $0x3,%eax
c010b1f0:	75 24                	jne    c010b216 <wakeup_proc+0x34>
c010b1f2:	c7 44 24 0c ff e6 10 	movl   $0xc010e6ff,0xc(%esp)
c010b1f9:	c0 
c010b1fa:	c7 44 24 08 1a e7 10 	movl   $0xc010e71a,0x8(%esp)
c010b201:	c0 
c010b202:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010b209:	00 
c010b20a:	c7 04 24 2f e7 10 c0 	movl   $0xc010e72f,(%esp)
c010b211:	e8 d5 5b ff ff       	call   c0100deb <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b216:	e8 85 ff ff ff       	call   c010b1a0 <__intr_save>
c010b21b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b21e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b221:	8b 00                	mov    (%eax),%eax
c010b223:	83 f8 02             	cmp    $0x2,%eax
c010b226:	74 15                	je     c010b23d <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010b228:	8b 45 08             	mov    0x8(%ebp),%eax
c010b22b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b231:	8b 45 08             	mov    0x8(%ebp),%eax
c010b234:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010b23b:	eb 1c                	jmp    c010b259 <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010b23d:	c7 44 24 08 45 e7 10 	movl   $0xc010e745,0x8(%esp)
c010b244:	c0 
c010b245:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010b24c:	00 
c010b24d:	c7 04 24 2f e7 10 c0 	movl   $0xc010e72f,(%esp)
c010b254:	e8 10 5c ff ff       	call   c0100e69 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b259:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b25c:	89 04 24             	mov    %eax,(%esp)
c010b25f:	e8 68 ff ff ff       	call   c010b1cc <__intr_restore>
}
c010b264:	90                   	nop
c010b265:	89 ec                	mov    %ebp,%esp
c010b267:	5d                   	pop    %ebp
c010b268:	c3                   	ret    

c010b269 <schedule>:

void
schedule(void) {
c010b269:	55                   	push   %ebp
c010b26a:	89 e5                	mov    %esp,%ebp
c010b26c:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010b26f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);	//inhibit interrupt
c010b276:	e8 25 ff ff ff       	call   c010b1a0 <__intr_save>
c010b27b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010b27e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b283:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010b28a:	8b 15 30 41 1a c0    	mov    0xc01a4130,%edx
c010b290:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b295:	39 c2                	cmp    %eax,%edx
c010b297:	74 0a                	je     c010b2a3 <schedule+0x3a>
c010b299:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b29e:	83 c0 58             	add    $0x58,%eax
c010b2a1:	eb 05                	jmp    c010b2a8 <schedule+0x3f>
c010b2a3:	b8 20 41 1a c0       	mov    $0xc01a4120,%eax
c010b2a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010b2ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c010b2b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b2ba:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010b2bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2c0:	81 7d f4 20 41 1a c0 	cmpl   $0xc01a4120,-0xc(%ebp)
c010b2c7:	74 13                	je     c010b2dc <schedule+0x73>
                next = le2proc(le, list_link);
c010b2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2cc:	83 e8 58             	sub    $0x58,%eax
c010b2cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010b2d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2d5:	8b 00                	mov    (%eax),%eax
c010b2d7:	83 f8 02             	cmp    $0x2,%eax
c010b2da:	74 0a                	je     c010b2e6 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010b2dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2df:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010b2e2:	75 cd                	jne    c010b2b1 <schedule+0x48>
c010b2e4:	eb 01                	jmp    c010b2e7 <schedule+0x7e>
                    break;
c010b2e6:	90                   	nop
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010b2e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b2eb:	74 0a                	je     c010b2f7 <schedule+0x8e>
c010b2ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2f0:	8b 00                	mov    (%eax),%eax
c010b2f2:	83 f8 02             	cmp    $0x2,%eax
c010b2f5:	74 08                	je     c010b2ff <schedule+0x96>
            next = idleproc;
c010b2f7:	a1 28 41 1a c0       	mov    0xc01a4128,%eax
c010b2fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b2ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b302:	8b 40 08             	mov    0x8(%eax),%eax
c010b305:	8d 50 01             	lea    0x1(%eax),%edx
c010b308:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b30b:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b30e:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b313:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b316:	74 0b                	je     c010b323 <schedule+0xba>
            proc_run(next);
c010b318:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b31b:	89 04 24             	mov    %eax,(%esp)
c010b31e:	e8 36 e8 ff ff       	call   c0109b59 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b323:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b326:	89 04 24             	mov    %eax,(%esp)
c010b329:	e8 9e fe ff ff       	call   c010b1cc <__intr_restore>
}
c010b32e:	90                   	nop
c010b32f:	89 ec                	mov    %ebp,%esp
c010b331:	5d                   	pop    %ebp
c010b332:	c3                   	ret    

c010b333 <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b333:	55                   	push   %ebp
c010b334:	89 e5                	mov    %esp,%ebp
c010b336:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b339:	8b 45 08             	mov    0x8(%ebp),%eax
c010b33c:	8b 00                	mov    (%eax),%eax
c010b33e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b341:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b344:	89 04 24             	mov    %eax,(%esp)
c010b347:	e8 ff ee ff ff       	call   c010a24b <do_exit>
}
c010b34c:	89 ec                	mov    %ebp,%esp
c010b34e:	5d                   	pop    %ebp
c010b34f:	c3                   	ret    

c010b350 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b350:	55                   	push   %ebp
c010b351:	89 e5                	mov    %esp,%ebp
c010b353:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b356:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b35b:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b35e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b361:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b364:	8b 40 44             	mov    0x44(%eax),%eax
c010b367:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b36a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b36d:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b374:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b378:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b37f:	e8 4e ed ff ff       	call   c010a0d2 <do_fork>
}
c010b384:	89 ec                	mov    %ebp,%esp
c010b386:	5d                   	pop    %ebp
c010b387:	c3                   	ret    

c010b388 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b388:	55                   	push   %ebp
c010b389:	89 e5                	mov    %esp,%ebp
c010b38b:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b38e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b391:	8b 00                	mov    (%eax),%eax
c010b393:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b396:	8b 45 08             	mov    0x8(%ebp),%eax
c010b399:	83 c0 04             	add    $0x4,%eax
c010b39c:	8b 00                	mov    (%eax),%eax
c010b39e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b3a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3a4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b3a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3ab:	89 04 24             	mov    %eax,(%esp)
c010b3ae:	e8 c7 f7 ff ff       	call   c010ab7a <do_wait>
}
c010b3b3:	89 ec                	mov    %ebp,%esp
c010b3b5:	5d                   	pop    %ebp
c010b3b6:	c3                   	ret    

c010b3b7 <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b3b7:	55                   	push   %ebp
c010b3b8:	89 e5                	mov    %esp,%ebp
c010b3ba:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b3bd:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3c0:	8b 00                	mov    (%eax),%eax
c010b3c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b3c5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3c8:	83 c0 04             	add    $0x4,%eax
c010b3cb:	8b 00                	mov    (%eax),%eax
c010b3cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b3d0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3d3:	83 c0 08             	add    $0x8,%eax
c010b3d6:	8b 00                	mov    (%eax),%eax
c010b3d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b3db:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3de:	83 c0 0c             	add    $0xc,%eax
c010b3e1:	8b 00                	mov    (%eax),%eax
c010b3e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b3e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b3e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b3ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b3f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b3f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b3f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b3fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3fe:	89 04 24             	mov    %eax,(%esp)
c010b401:	e8 23 f6 ff ff       	call   c010aa29 <do_execve>
}
c010b406:	89 ec                	mov    %ebp,%esp
c010b408:	5d                   	pop    %ebp
c010b409:	c3                   	ret    

c010b40a <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b40a:	55                   	push   %ebp
c010b40b:	89 e5                	mov    %esp,%ebp
c010b40d:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b410:	e8 4f f7 ff ff       	call   c010ab64 <do_yield>
}
c010b415:	89 ec                	mov    %ebp,%esp
c010b417:	5d                   	pop    %ebp
c010b418:	c3                   	ret    

c010b419 <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b419:	55                   	push   %ebp
c010b41a:	89 e5                	mov    %esp,%ebp
c010b41c:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b41f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b422:	8b 00                	mov    (%eax),%eax
c010b424:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b427:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b42a:	89 04 24             	mov    %eax,(%esp)
c010b42d:	e8 da f8 ff ff       	call   c010ad0c <do_kill>
}
c010b432:	89 ec                	mov    %ebp,%esp
c010b434:	5d                   	pop    %ebp
c010b435:	c3                   	ret    

c010b436 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b436:	55                   	push   %ebp
c010b437:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b439:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b43e:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b441:	5d                   	pop    %ebp
c010b442:	c3                   	ret    

c010b443 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b443:	55                   	push   %ebp
c010b444:	89 e5                	mov    %esp,%ebp
c010b446:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b449:	8b 45 08             	mov    0x8(%ebp),%eax
c010b44c:	8b 00                	mov    (%eax),%eax
c010b44e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b454:	89 04 24             	mov    %eax,(%esp)
c010b457:	e8 39 4f ff ff       	call   c0100395 <cputchar>
    return 0;
c010b45c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b461:	89 ec                	mov    %ebp,%esp
c010b463:	5d                   	pop    %ebp
c010b464:	c3                   	ret    

c010b465 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b465:	55                   	push   %ebp
c010b466:	89 e5                	mov    %esp,%ebp
c010b468:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b46b:	e8 d0 b8 ff ff       	call   c0106d40 <print_pgdir>
    return 0;
c010b470:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b475:	89 ec                	mov    %ebp,%esp
c010b477:	5d                   	pop    %ebp
c010b478:	c3                   	ret    

c010b479 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b479:	55                   	push   %ebp
c010b47a:	89 e5                	mov    %esp,%ebp
c010b47c:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b47f:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b484:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b487:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b48d:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b490:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b497:	78 5e                	js     c010b4f7 <syscall+0x7e>
c010b499:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b49c:	83 f8 1f             	cmp    $0x1f,%eax
c010b49f:	77 56                	ja     c010b4f7 <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b4a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4a4:	8b 04 85 a0 fa 12 c0 	mov    -0x3fed0560(,%eax,4),%eax
c010b4ab:	85 c0                	test   %eax,%eax
c010b4ad:	74 48                	je     c010b4f7 <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4b2:	8b 40 14             	mov    0x14(%eax),%eax
c010b4b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b4b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4bb:	8b 40 18             	mov    0x18(%eax),%eax
c010b4be:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4c4:	8b 40 10             	mov    0x10(%eax),%eax
c010b4c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b4ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4cd:	8b 00                	mov    (%eax),%eax
c010b4cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b4d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4d5:	8b 40 04             	mov    0x4(%eax),%eax
c010b4d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);	//`syscalls[num]` is function ptr, and `(arg)` is argument
c010b4db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4de:	8b 04 85 a0 fa 12 c0 	mov    -0x3fed0560(,%eax,4),%eax
c010b4e5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b4e8:	89 14 24             	mov    %edx,(%esp)
c010b4eb:	ff d0                	call   *%eax
c010b4ed:	89 c2                	mov    %eax,%edx
c010b4ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4f2:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b4f5:	eb 46                	jmp    c010b53d <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b4f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4fa:	89 04 24             	mov    %eax,(%esp)
c010b4fd:	e8 db 6f ff ff       	call   c01024dd <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b502:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b507:	8d 50 48             	lea    0x48(%eax),%edx
c010b50a:	a1 30 41 1a c0       	mov    0xc01a4130,%eax
c010b50f:	8b 40 04             	mov    0x4(%eax),%eax
c010b512:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b516:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b51a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b51d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b521:	c7 44 24 08 60 e7 10 	movl   $0xc010e760,0x8(%esp)
c010b528:	c0 
c010b529:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010b530:	00 
c010b531:	c7 04 24 8c e7 10 c0 	movl   $0xc010e78c,(%esp)
c010b538:	e8 ae 58 ff ff       	call   c0100deb <__panic>
            num, current->pid, current->name);
}
c010b53d:	89 ec                	mov    %ebp,%esp
c010b53f:	5d                   	pop    %ebp
c010b540:	c3                   	ret    

c010b541 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b541:	55                   	push   %ebp
c010b542:	89 e5                	mov    %esp,%ebp
c010b544:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b547:	8b 45 08             	mov    0x8(%ebp),%eax
c010b54a:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b550:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b553:	b8 20 00 00 00       	mov    $0x20,%eax
c010b558:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b55b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b55e:	88 c1                	mov    %al,%cl
c010b560:	d3 ea                	shr    %cl,%edx
c010b562:	89 d0                	mov    %edx,%eax
}
c010b564:	89 ec                	mov    %ebp,%esp
c010b566:	5d                   	pop    %ebp
c010b567:	c3                   	ret    

c010b568 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b568:	55                   	push   %ebp
c010b569:	89 e5                	mov    %esp,%ebp
c010b56b:	83 ec 58             	sub    $0x58,%esp
c010b56e:	8b 45 10             	mov    0x10(%ebp),%eax
c010b571:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b574:	8b 45 14             	mov    0x14(%ebp),%eax
c010b577:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b57a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b57d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b580:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b583:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b586:	8b 45 18             	mov    0x18(%ebp),%eax
c010b589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b58f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b592:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b595:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b598:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b59b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b59e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5a2:	74 1c                	je     c010b5c0 <printnum+0x58>
c010b5a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5a7:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5ac:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5af:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b5b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5b5:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5ba:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b5c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b5c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b5c6:	f7 75 e4             	divl   -0x1c(%ebp)
c010b5c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b5cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b5cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b5d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b5d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b5d8:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b5db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b5de:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b5e1:	8b 45 18             	mov    0x18(%ebp),%eax
c010b5e4:	ba 00 00 00 00       	mov    $0x0,%edx
c010b5e9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010b5ec:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010b5ef:	19 d1                	sbb    %edx,%ecx
c010b5f1:	72 4c                	jb     c010b63f <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b5f3:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b5f6:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b5f9:	8b 45 20             	mov    0x20(%ebp),%eax
c010b5fc:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b600:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b604:	8b 45 18             	mov    0x18(%ebp),%eax
c010b607:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b60b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b60e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b611:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b615:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b619:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b61c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b620:	8b 45 08             	mov    0x8(%ebp),%eax
c010b623:	89 04 24             	mov    %eax,(%esp)
c010b626:	e8 3d ff ff ff       	call   c010b568 <printnum>
c010b62b:	eb 1b                	jmp    c010b648 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b62d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b630:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b634:	8b 45 20             	mov    0x20(%ebp),%eax
c010b637:	89 04 24             	mov    %eax,(%esp)
c010b63a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b63d:	ff d0                	call   *%eax
        while (-- width > 0)
c010b63f:	ff 4d 1c             	decl   0x1c(%ebp)
c010b642:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b646:	7f e5                	jg     c010b62d <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b648:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b64b:	05 c4 e8 10 c0       	add    $0xc010e8c4,%eax
c010b650:	0f b6 00             	movzbl (%eax),%eax
c010b653:	0f be c0             	movsbl %al,%eax
c010b656:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b659:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b65d:	89 04 24             	mov    %eax,(%esp)
c010b660:	8b 45 08             	mov    0x8(%ebp),%eax
c010b663:	ff d0                	call   *%eax
}
c010b665:	90                   	nop
c010b666:	89 ec                	mov    %ebp,%esp
c010b668:	5d                   	pop    %ebp
c010b669:	c3                   	ret    

c010b66a <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b66a:	55                   	push   %ebp
c010b66b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b66d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b671:	7e 14                	jle    c010b687 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b673:	8b 45 08             	mov    0x8(%ebp),%eax
c010b676:	8b 00                	mov    (%eax),%eax
c010b678:	8d 48 08             	lea    0x8(%eax),%ecx
c010b67b:	8b 55 08             	mov    0x8(%ebp),%edx
c010b67e:	89 0a                	mov    %ecx,(%edx)
c010b680:	8b 50 04             	mov    0x4(%eax),%edx
c010b683:	8b 00                	mov    (%eax),%eax
c010b685:	eb 30                	jmp    c010b6b7 <getuint+0x4d>
    }
    else if (lflag) {
c010b687:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b68b:	74 16                	je     c010b6a3 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b68d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b690:	8b 00                	mov    (%eax),%eax
c010b692:	8d 48 04             	lea    0x4(%eax),%ecx
c010b695:	8b 55 08             	mov    0x8(%ebp),%edx
c010b698:	89 0a                	mov    %ecx,(%edx)
c010b69a:	8b 00                	mov    (%eax),%eax
c010b69c:	ba 00 00 00 00       	mov    $0x0,%edx
c010b6a1:	eb 14                	jmp    c010b6b7 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b6a3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6a6:	8b 00                	mov    (%eax),%eax
c010b6a8:	8d 48 04             	lea    0x4(%eax),%ecx
c010b6ab:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6ae:	89 0a                	mov    %ecx,(%edx)
c010b6b0:	8b 00                	mov    (%eax),%eax
c010b6b2:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b6b7:	5d                   	pop    %ebp
c010b6b8:	c3                   	ret    

c010b6b9 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b6b9:	55                   	push   %ebp
c010b6ba:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b6bc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b6c0:	7e 14                	jle    c010b6d6 <getint+0x1d>
        return va_arg(*ap, long long);
c010b6c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6c5:	8b 00                	mov    (%eax),%eax
c010b6c7:	8d 48 08             	lea    0x8(%eax),%ecx
c010b6ca:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6cd:	89 0a                	mov    %ecx,(%edx)
c010b6cf:	8b 50 04             	mov    0x4(%eax),%edx
c010b6d2:	8b 00                	mov    (%eax),%eax
c010b6d4:	eb 28                	jmp    c010b6fe <getint+0x45>
    }
    else if (lflag) {
c010b6d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b6da:	74 12                	je     c010b6ee <getint+0x35>
        return va_arg(*ap, long);
c010b6dc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6df:	8b 00                	mov    (%eax),%eax
c010b6e1:	8d 48 04             	lea    0x4(%eax),%ecx
c010b6e4:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6e7:	89 0a                	mov    %ecx,(%edx)
c010b6e9:	8b 00                	mov    (%eax),%eax
c010b6eb:	99                   	cltd   
c010b6ec:	eb 10                	jmp    c010b6fe <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b6ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6f1:	8b 00                	mov    (%eax),%eax
c010b6f3:	8d 48 04             	lea    0x4(%eax),%ecx
c010b6f6:	8b 55 08             	mov    0x8(%ebp),%edx
c010b6f9:	89 0a                	mov    %ecx,(%edx)
c010b6fb:	8b 00                	mov    (%eax),%eax
c010b6fd:	99                   	cltd   
    }
}
c010b6fe:	5d                   	pop    %ebp
c010b6ff:	c3                   	ret    

c010b700 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b700:	55                   	push   %ebp
c010b701:	89 e5                	mov    %esp,%ebp
c010b703:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b706:	8d 45 14             	lea    0x14(%ebp),%eax
c010b709:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b70c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b70f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b713:	8b 45 10             	mov    0x10(%ebp),%eax
c010b716:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b71a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b71d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b721:	8b 45 08             	mov    0x8(%ebp),%eax
c010b724:	89 04 24             	mov    %eax,(%esp)
c010b727:	e8 05 00 00 00       	call   c010b731 <vprintfmt>
    va_end(ap);
}
c010b72c:	90                   	nop
c010b72d:	89 ec                	mov    %ebp,%esp
c010b72f:	5d                   	pop    %ebp
c010b730:	c3                   	ret    

c010b731 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b731:	55                   	push   %ebp
c010b732:	89 e5                	mov    %esp,%ebp
c010b734:	56                   	push   %esi
c010b735:	53                   	push   %ebx
c010b736:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b739:	eb 17                	jmp    c010b752 <vprintfmt+0x21>
            if (ch == '\0') {
c010b73b:	85 db                	test   %ebx,%ebx
c010b73d:	0f 84 bf 03 00 00    	je     c010bb02 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010b743:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b746:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b74a:	89 1c 24             	mov    %ebx,(%esp)
c010b74d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b750:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b752:	8b 45 10             	mov    0x10(%ebp),%eax
c010b755:	8d 50 01             	lea    0x1(%eax),%edx
c010b758:	89 55 10             	mov    %edx,0x10(%ebp)
c010b75b:	0f b6 00             	movzbl (%eax),%eax
c010b75e:	0f b6 d8             	movzbl %al,%ebx
c010b761:	83 fb 25             	cmp    $0x25,%ebx
c010b764:	75 d5                	jne    c010b73b <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b766:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b76a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b771:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b774:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b777:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b77e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b781:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b784:	8b 45 10             	mov    0x10(%ebp),%eax
c010b787:	8d 50 01             	lea    0x1(%eax),%edx
c010b78a:	89 55 10             	mov    %edx,0x10(%ebp)
c010b78d:	0f b6 00             	movzbl (%eax),%eax
c010b790:	0f b6 d8             	movzbl %al,%ebx
c010b793:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b796:	83 f8 55             	cmp    $0x55,%eax
c010b799:	0f 87 37 03 00 00    	ja     c010bad6 <vprintfmt+0x3a5>
c010b79f:	8b 04 85 e8 e8 10 c0 	mov    -0x3fef1718(,%eax,4),%eax
c010b7a6:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b7a8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b7ac:	eb d6                	jmp    c010b784 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b7ae:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b7b2:	eb d0                	jmp    c010b784 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b7b4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b7bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b7be:	89 d0                	mov    %edx,%eax
c010b7c0:	c1 e0 02             	shl    $0x2,%eax
c010b7c3:	01 d0                	add    %edx,%eax
c010b7c5:	01 c0                	add    %eax,%eax
c010b7c7:	01 d8                	add    %ebx,%eax
c010b7c9:	83 e8 30             	sub    $0x30,%eax
c010b7cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b7cf:	8b 45 10             	mov    0x10(%ebp),%eax
c010b7d2:	0f b6 00             	movzbl (%eax),%eax
c010b7d5:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b7d8:	83 fb 2f             	cmp    $0x2f,%ebx
c010b7db:	7e 38                	jle    c010b815 <vprintfmt+0xe4>
c010b7dd:	83 fb 39             	cmp    $0x39,%ebx
c010b7e0:	7f 33                	jg     c010b815 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010b7e2:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010b7e5:	eb d4                	jmp    c010b7bb <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010b7e7:	8b 45 14             	mov    0x14(%ebp),%eax
c010b7ea:	8d 50 04             	lea    0x4(%eax),%edx
c010b7ed:	89 55 14             	mov    %edx,0x14(%ebp)
c010b7f0:	8b 00                	mov    (%eax),%eax
c010b7f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010b7f5:	eb 1f                	jmp    c010b816 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010b7f7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b7fb:	79 87                	jns    c010b784 <vprintfmt+0x53>
                width = 0;
c010b7fd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010b804:	e9 7b ff ff ff       	jmp    c010b784 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010b809:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010b810:	e9 6f ff ff ff       	jmp    c010b784 <vprintfmt+0x53>
            goto process_precision;
c010b815:	90                   	nop

        process_precision:
            if (width < 0)
c010b816:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b81a:	0f 89 64 ff ff ff    	jns    c010b784 <vprintfmt+0x53>
                width = precision, precision = -1;
c010b820:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b823:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b826:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010b82d:	e9 52 ff ff ff       	jmp    c010b784 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b832:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010b835:	e9 4a ff ff ff       	jmp    c010b784 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b83a:	8b 45 14             	mov    0x14(%ebp),%eax
c010b83d:	8d 50 04             	lea    0x4(%eax),%edx
c010b840:	89 55 14             	mov    %edx,0x14(%ebp)
c010b843:	8b 00                	mov    (%eax),%eax
c010b845:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b848:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b84c:	89 04 24             	mov    %eax,(%esp)
c010b84f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b852:	ff d0                	call   *%eax
            break;
c010b854:	e9 a4 02 00 00       	jmp    c010bafd <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b859:	8b 45 14             	mov    0x14(%ebp),%eax
c010b85c:	8d 50 04             	lea    0x4(%eax),%edx
c010b85f:	89 55 14             	mov    %edx,0x14(%ebp)
c010b862:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b864:	85 db                	test   %ebx,%ebx
c010b866:	79 02                	jns    c010b86a <vprintfmt+0x139>
                err = -err;
c010b868:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b86a:	83 fb 18             	cmp    $0x18,%ebx
c010b86d:	7f 0b                	jg     c010b87a <vprintfmt+0x149>
c010b86f:	8b 34 9d 60 e8 10 c0 	mov    -0x3fef17a0(,%ebx,4),%esi
c010b876:	85 f6                	test   %esi,%esi
c010b878:	75 23                	jne    c010b89d <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010b87a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010b87e:	c7 44 24 08 d5 e8 10 	movl   $0xc010e8d5,0x8(%esp)
c010b885:	c0 
c010b886:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b889:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b88d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b890:	89 04 24             	mov    %eax,(%esp)
c010b893:	e8 68 fe ff ff       	call   c010b700 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010b898:	e9 60 02 00 00       	jmp    c010bafd <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c010b89d:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010b8a1:	c7 44 24 08 de e8 10 	movl   $0xc010e8de,0x8(%esp)
c010b8a8:	c0 
c010b8a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b8ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8b0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8b3:	89 04 24             	mov    %eax,(%esp)
c010b8b6:	e8 45 fe ff ff       	call   c010b700 <printfmt>
            break;
c010b8bb:	e9 3d 02 00 00       	jmp    c010bafd <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010b8c0:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8c3:	8d 50 04             	lea    0x4(%eax),%edx
c010b8c6:	89 55 14             	mov    %edx,0x14(%ebp)
c010b8c9:	8b 30                	mov    (%eax),%esi
c010b8cb:	85 f6                	test   %esi,%esi
c010b8cd:	75 05                	jne    c010b8d4 <vprintfmt+0x1a3>
                p = "(null)";
c010b8cf:	be e1 e8 10 c0       	mov    $0xc010e8e1,%esi
            }
            if (width > 0 && padc != '-') {
c010b8d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b8d8:	7e 76                	jle    c010b950 <vprintfmt+0x21f>
c010b8da:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010b8de:	74 70                	je     c010b950 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b8e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b8e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8e7:	89 34 24             	mov    %esi,(%esp)
c010b8ea:	e8 ee 03 00 00       	call   c010bcdd <strnlen>
c010b8ef:	89 c2                	mov    %eax,%edx
c010b8f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b8f4:	29 d0                	sub    %edx,%eax
c010b8f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b8f9:	eb 16                	jmp    c010b911 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c010b8fb:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010b8ff:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b902:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b906:	89 04 24             	mov    %eax,(%esp)
c010b909:	8b 45 08             	mov    0x8(%ebp),%eax
c010b90c:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b90e:	ff 4d e8             	decl   -0x18(%ebp)
c010b911:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b915:	7f e4                	jg     c010b8fb <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b917:	eb 37                	jmp    c010b950 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010b919:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010b91d:	74 1f                	je     c010b93e <vprintfmt+0x20d>
c010b91f:	83 fb 1f             	cmp    $0x1f,%ebx
c010b922:	7e 05                	jle    c010b929 <vprintfmt+0x1f8>
c010b924:	83 fb 7e             	cmp    $0x7e,%ebx
c010b927:	7e 15                	jle    c010b93e <vprintfmt+0x20d>
                    putch('?', putdat);
c010b929:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b92c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b930:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010b937:	8b 45 08             	mov    0x8(%ebp),%eax
c010b93a:	ff d0                	call   *%eax
c010b93c:	eb 0f                	jmp    c010b94d <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010b93e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b941:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b945:	89 1c 24             	mov    %ebx,(%esp)
c010b948:	8b 45 08             	mov    0x8(%ebp),%eax
c010b94b:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b94d:	ff 4d e8             	decl   -0x18(%ebp)
c010b950:	89 f0                	mov    %esi,%eax
c010b952:	8d 70 01             	lea    0x1(%eax),%esi
c010b955:	0f b6 00             	movzbl (%eax),%eax
c010b958:	0f be d8             	movsbl %al,%ebx
c010b95b:	85 db                	test   %ebx,%ebx
c010b95d:	74 27                	je     c010b986 <vprintfmt+0x255>
c010b95f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b963:	78 b4                	js     c010b919 <vprintfmt+0x1e8>
c010b965:	ff 4d e4             	decl   -0x1c(%ebp)
c010b968:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b96c:	79 ab                	jns    c010b919 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c010b96e:	eb 16                	jmp    c010b986 <vprintfmt+0x255>
                putch(' ', putdat);
c010b970:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b973:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b977:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010b97e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b981:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c010b983:	ff 4d e8             	decl   -0x18(%ebp)
c010b986:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b98a:	7f e4                	jg     c010b970 <vprintfmt+0x23f>
            }
            break;
c010b98c:	e9 6c 01 00 00       	jmp    c010bafd <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010b991:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b994:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b998:	8d 45 14             	lea    0x14(%ebp),%eax
c010b99b:	89 04 24             	mov    %eax,(%esp)
c010b99e:	e8 16 fd ff ff       	call   c010b6b9 <getint>
c010b9a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b9a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010b9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b9ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b9af:	85 d2                	test   %edx,%edx
c010b9b1:	79 26                	jns    c010b9d9 <vprintfmt+0x2a8>
                putch('-', putdat);
c010b9b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b9ba:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010b9c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9c4:	ff d0                	call   *%eax
                num = -(long long)num;
c010b9c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b9c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b9cc:	f7 d8                	neg    %eax
c010b9ce:	83 d2 00             	adc    $0x0,%edx
c010b9d1:	f7 da                	neg    %edx
c010b9d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b9d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010b9d9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b9e0:	e9 a8 00 00 00       	jmp    c010ba8d <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010b9e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b9e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b9ec:	8d 45 14             	lea    0x14(%ebp),%eax
c010b9ef:	89 04 24             	mov    %eax,(%esp)
c010b9f2:	e8 73 fc ff ff       	call   c010b66a <getuint>
c010b9f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b9fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010b9fd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010ba04:	e9 84 00 00 00       	jmp    c010ba8d <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010ba09:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ba0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba10:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba13:	89 04 24             	mov    %eax,(%esp)
c010ba16:	e8 4f fc ff ff       	call   c010b66a <getuint>
c010ba1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba1e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010ba21:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010ba28:	eb 63                	jmp    c010ba8d <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010ba2a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba31:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010ba38:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba3b:	ff d0                	call   *%eax
            putch('x', putdat);
c010ba3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba40:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba44:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010ba4b:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba4e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010ba50:	8b 45 14             	mov    0x14(%ebp),%eax
c010ba53:	8d 50 04             	lea    0x4(%eax),%edx
c010ba56:	89 55 14             	mov    %edx,0x14(%ebp)
c010ba59:	8b 00                	mov    (%eax),%eax
c010ba5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010ba65:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010ba6c:	eb 1f                	jmp    c010ba8d <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010ba6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ba71:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ba75:	8d 45 14             	lea    0x14(%ebp),%eax
c010ba78:	89 04 24             	mov    %eax,(%esp)
c010ba7b:	e8 ea fb ff ff       	call   c010b66a <getuint>
c010ba80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba83:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010ba86:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010ba8d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010ba91:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba94:	89 54 24 18          	mov    %edx,0x18(%esp)
c010ba98:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ba9b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010ba9f:	89 44 24 10          	mov    %eax,0x10(%esp)
c010baa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010baa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010baa9:	89 44 24 08          	mov    %eax,0x8(%esp)
c010baad:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bab1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bab4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bab8:	8b 45 08             	mov    0x8(%ebp),%eax
c010babb:	89 04 24             	mov    %eax,(%esp)
c010babe:	e8 a5 fa ff ff       	call   c010b568 <printnum>
            break;
c010bac3:	eb 38                	jmp    c010bafd <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010bac5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bac8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bacc:	89 1c 24             	mov    %ebx,(%esp)
c010bacf:	8b 45 08             	mov    0x8(%ebp),%eax
c010bad2:	ff d0                	call   *%eax
            break;
c010bad4:	eb 27                	jmp    c010bafd <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010bad6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010badd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010bae4:	8b 45 08             	mov    0x8(%ebp),%eax
c010bae7:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010bae9:	ff 4d 10             	decl   0x10(%ebp)
c010baec:	eb 03                	jmp    c010baf1 <vprintfmt+0x3c0>
c010baee:	ff 4d 10             	decl   0x10(%ebp)
c010baf1:	8b 45 10             	mov    0x10(%ebp),%eax
c010baf4:	48                   	dec    %eax
c010baf5:	0f b6 00             	movzbl (%eax),%eax
c010baf8:	3c 25                	cmp    $0x25,%al
c010bafa:	75 f2                	jne    c010baee <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c010bafc:	90                   	nop
    while (1) {
c010bafd:	e9 37 fc ff ff       	jmp    c010b739 <vprintfmt+0x8>
                return;
c010bb02:	90                   	nop
        }
    }
}
c010bb03:	83 c4 40             	add    $0x40,%esp
c010bb06:	5b                   	pop    %ebx
c010bb07:	5e                   	pop    %esi
c010bb08:	5d                   	pop    %ebp
c010bb09:	c3                   	ret    

c010bb0a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010bb0a:	55                   	push   %ebp
c010bb0b:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010bb0d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb10:	8b 40 08             	mov    0x8(%eax),%eax
c010bb13:	8d 50 01             	lea    0x1(%eax),%edx
c010bb16:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb19:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010bb1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb1f:	8b 10                	mov    (%eax),%edx
c010bb21:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb24:	8b 40 04             	mov    0x4(%eax),%eax
c010bb27:	39 c2                	cmp    %eax,%edx
c010bb29:	73 12                	jae    c010bb3d <sprintputch+0x33>
        *b->buf ++ = ch;
c010bb2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb2e:	8b 00                	mov    (%eax),%eax
c010bb30:	8d 48 01             	lea    0x1(%eax),%ecx
c010bb33:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bb36:	89 0a                	mov    %ecx,(%edx)
c010bb38:	8b 55 08             	mov    0x8(%ebp),%edx
c010bb3b:	88 10                	mov    %dl,(%eax)
    }
}
c010bb3d:	90                   	nop
c010bb3e:	5d                   	pop    %ebp
c010bb3f:	c3                   	ret    

c010bb40 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010bb40:	55                   	push   %ebp
c010bb41:	89 e5                	mov    %esp,%ebp
c010bb43:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010bb46:	8d 45 14             	lea    0x14(%ebp),%eax
c010bb49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010bb4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bb53:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb56:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bb5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bb61:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb64:	89 04 24             	mov    %eax,(%esp)
c010bb67:	e8 0a 00 00 00       	call   c010bb76 <vsnprintf>
c010bb6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010bb6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bb72:	89 ec                	mov    %ebp,%esp
c010bb74:	5d                   	pop    %ebp
c010bb75:	c3                   	ret    

c010bb76 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010bb76:	55                   	push   %ebp
c010bb77:	89 e5                	mov    %esp,%ebp
c010bb79:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010bb7c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bb82:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb85:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bb88:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb8b:	01 d0                	add    %edx,%eax
c010bb8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010bb97:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010bb9b:	74 0a                	je     c010bba7 <vsnprintf+0x31>
c010bb9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bba3:	39 c2                	cmp    %eax,%edx
c010bba5:	76 07                	jbe    c010bbae <vsnprintf+0x38>
        return -E_INVAL;
c010bba7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010bbac:	eb 2a                	jmp    c010bbd8 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010bbae:	8b 45 14             	mov    0x14(%ebp),%eax
c010bbb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bbb5:	8b 45 10             	mov    0x10(%ebp),%eax
c010bbb8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bbbc:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010bbbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbc3:	c7 04 24 0a bb 10 c0 	movl   $0xc010bb0a,(%esp)
c010bbca:	e8 62 fb ff ff       	call   c010b731 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010bbcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bbd2:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010bbd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010bbd8:	89 ec                	mov    %ebp,%esp
c010bbda:	5d                   	pop    %ebp
c010bbdb:	c3                   	ret    

c010bbdc <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010bbdc:	55                   	push   %ebp
c010bbdd:	89 e5                	mov    %esp,%ebp
c010bbdf:	57                   	push   %edi
c010bbe0:	56                   	push   %esi
c010bbe1:	53                   	push   %ebx
c010bbe2:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010bbe5:	a1 20 fb 12 c0       	mov    0xc012fb20,%eax
c010bbea:	8b 15 24 fb 12 c0    	mov    0xc012fb24,%edx
c010bbf0:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010bbf6:	6b f0 05             	imul   $0x5,%eax,%esi
c010bbf9:	01 fe                	add    %edi,%esi
c010bbfb:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010bc00:	f7 e7                	mul    %edi
c010bc02:	01 d6                	add    %edx,%esi
c010bc04:	89 f2                	mov    %esi,%edx
c010bc06:	83 c0 0b             	add    $0xb,%eax
c010bc09:	83 d2 00             	adc    $0x0,%edx
c010bc0c:	89 c7                	mov    %eax,%edi
c010bc0e:	83 e7 ff             	and    $0xffffffff,%edi
c010bc11:	89 f9                	mov    %edi,%ecx
c010bc13:	0f b7 da             	movzwl %dx,%ebx
c010bc16:	89 0d 20 fb 12 c0    	mov    %ecx,0xc012fb20
c010bc1c:	89 1d 24 fb 12 c0    	mov    %ebx,0xc012fb24
    unsigned long long result = (next >> 12);
c010bc22:	a1 20 fb 12 c0       	mov    0xc012fb20,%eax
c010bc27:	8b 15 24 fb 12 c0    	mov    0xc012fb24,%edx
c010bc2d:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010bc31:	c1 ea 0c             	shr    $0xc,%edx
c010bc34:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bc37:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010bc3a:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010bc41:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bc44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bc47:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bc4a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bc4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc50:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bc53:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bc57:	74 1c                	je     c010bc75 <rand+0x99>
c010bc59:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc5c:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc61:	f7 75 dc             	divl   -0x24(%ebp)
c010bc64:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bc67:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bc6a:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc6f:	f7 75 dc             	divl   -0x24(%ebp)
c010bc72:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bc75:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bc78:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bc7b:	f7 75 dc             	divl   -0x24(%ebp)
c010bc7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010bc81:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bc84:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bc87:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010bc8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bc8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010bc90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010bc93:	83 c4 24             	add    $0x24,%esp
c010bc96:	5b                   	pop    %ebx
c010bc97:	5e                   	pop    %esi
c010bc98:	5f                   	pop    %edi
c010bc99:	5d                   	pop    %ebp
c010bc9a:	c3                   	ret    

c010bc9b <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010bc9b:	55                   	push   %ebp
c010bc9c:	89 e5                	mov    %esp,%ebp
    next = seed;
c010bc9e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bca1:	ba 00 00 00 00       	mov    $0x0,%edx
c010bca6:	a3 20 fb 12 c0       	mov    %eax,0xc012fb20
c010bcab:	89 15 24 fb 12 c0    	mov    %edx,0xc012fb24
}
c010bcb1:	90                   	nop
c010bcb2:	5d                   	pop    %ebp
c010bcb3:	c3                   	ret    

c010bcb4 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010bcb4:	55                   	push   %ebp
c010bcb5:	89 e5                	mov    %esp,%ebp
c010bcb7:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bcba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010bcc1:	eb 03                	jmp    c010bcc6 <strlen+0x12>
        cnt ++;
c010bcc3:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010bcc6:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcc9:	8d 50 01             	lea    0x1(%eax),%edx
c010bccc:	89 55 08             	mov    %edx,0x8(%ebp)
c010bccf:	0f b6 00             	movzbl (%eax),%eax
c010bcd2:	84 c0                	test   %al,%al
c010bcd4:	75 ed                	jne    c010bcc3 <strlen+0xf>
    }
    return cnt;
c010bcd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bcd9:	89 ec                	mov    %ebp,%esp
c010bcdb:	5d                   	pop    %ebp
c010bcdc:	c3                   	ret    

c010bcdd <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010bcdd:	55                   	push   %ebp
c010bcde:	89 e5                	mov    %esp,%ebp
c010bce0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010bce3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010bcea:	eb 03                	jmp    c010bcef <strnlen+0x12>
        cnt ++;
c010bcec:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010bcef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bcf2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010bcf5:	73 10                	jae    c010bd07 <strnlen+0x2a>
c010bcf7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcfa:	8d 50 01             	lea    0x1(%eax),%edx
c010bcfd:	89 55 08             	mov    %edx,0x8(%ebp)
c010bd00:	0f b6 00             	movzbl (%eax),%eax
c010bd03:	84 c0                	test   %al,%al
c010bd05:	75 e5                	jne    c010bcec <strnlen+0xf>
    }
    return cnt;
c010bd07:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010bd0a:	89 ec                	mov    %ebp,%esp
c010bd0c:	5d                   	pop    %ebp
c010bd0d:	c3                   	ret    

c010bd0e <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010bd0e:	55                   	push   %ebp
c010bd0f:	89 e5                	mov    %esp,%ebp
c010bd11:	57                   	push   %edi
c010bd12:	56                   	push   %esi
c010bd13:	83 ec 20             	sub    $0x20,%esp
c010bd16:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bd1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010bd22:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bd25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bd28:	89 d1                	mov    %edx,%ecx
c010bd2a:	89 c2                	mov    %eax,%edx
c010bd2c:	89 ce                	mov    %ecx,%esi
c010bd2e:	89 d7                	mov    %edx,%edi
c010bd30:	ac                   	lods   %ds:(%esi),%al
c010bd31:	aa                   	stos   %al,%es:(%edi)
c010bd32:	84 c0                	test   %al,%al
c010bd34:	75 fa                	jne    c010bd30 <strcpy+0x22>
c010bd36:	89 fa                	mov    %edi,%edx
c010bd38:	89 f1                	mov    %esi,%ecx
c010bd3a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010bd3d:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010bd40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010bd43:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010bd46:	83 c4 20             	add    $0x20,%esp
c010bd49:	5e                   	pop    %esi
c010bd4a:	5f                   	pop    %edi
c010bd4b:	5d                   	pop    %ebp
c010bd4c:	c3                   	ret    

c010bd4d <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010bd4d:	55                   	push   %ebp
c010bd4e:	89 e5                	mov    %esp,%ebp
c010bd50:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010bd53:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd56:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010bd59:	eb 1e                	jmp    c010bd79 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010bd5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd5e:	0f b6 10             	movzbl (%eax),%edx
c010bd61:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bd64:	88 10                	mov    %dl,(%eax)
c010bd66:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bd69:	0f b6 00             	movzbl (%eax),%eax
c010bd6c:	84 c0                	test   %al,%al
c010bd6e:	74 03                	je     c010bd73 <strncpy+0x26>
            src ++;
c010bd70:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010bd73:	ff 45 fc             	incl   -0x4(%ebp)
c010bd76:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010bd79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bd7d:	75 dc                	jne    c010bd5b <strncpy+0xe>
    }
    return dst;
c010bd7f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bd82:	89 ec                	mov    %ebp,%esp
c010bd84:	5d                   	pop    %ebp
c010bd85:	c3                   	ret    

c010bd86 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010bd86:	55                   	push   %ebp
c010bd87:	89 e5                	mov    %esp,%ebp
c010bd89:	57                   	push   %edi
c010bd8a:	56                   	push   %esi
c010bd8b:	83 ec 20             	sub    $0x20,%esp
c010bd8e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bd94:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c010bd9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bd9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bda0:	89 d1                	mov    %edx,%ecx
c010bda2:	89 c2                	mov    %eax,%edx
c010bda4:	89 ce                	mov    %ecx,%esi
c010bda6:	89 d7                	mov    %edx,%edi
c010bda8:	ac                   	lods   %ds:(%esi),%al
c010bda9:	ae                   	scas   %es:(%edi),%al
c010bdaa:	75 08                	jne    c010bdb4 <strcmp+0x2e>
c010bdac:	84 c0                	test   %al,%al
c010bdae:	75 f8                	jne    c010bda8 <strcmp+0x22>
c010bdb0:	31 c0                	xor    %eax,%eax
c010bdb2:	eb 04                	jmp    c010bdb8 <strcmp+0x32>
c010bdb4:	19 c0                	sbb    %eax,%eax
c010bdb6:	0c 01                	or     $0x1,%al
c010bdb8:	89 fa                	mov    %edi,%edx
c010bdba:	89 f1                	mov    %esi,%ecx
c010bdbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bdbf:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010bdc2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c010bdc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010bdc8:	83 c4 20             	add    $0x20,%esp
c010bdcb:	5e                   	pop    %esi
c010bdcc:	5f                   	pop    %edi
c010bdcd:	5d                   	pop    %ebp
c010bdce:	c3                   	ret    

c010bdcf <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010bdcf:	55                   	push   %ebp
c010bdd0:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bdd2:	eb 09                	jmp    c010bddd <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010bdd4:	ff 4d 10             	decl   0x10(%ebp)
c010bdd7:	ff 45 08             	incl   0x8(%ebp)
c010bdda:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bddd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bde1:	74 1a                	je     c010bdfd <strncmp+0x2e>
c010bde3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bde6:	0f b6 00             	movzbl (%eax),%eax
c010bde9:	84 c0                	test   %al,%al
c010bdeb:	74 10                	je     c010bdfd <strncmp+0x2e>
c010bded:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdf0:	0f b6 10             	movzbl (%eax),%edx
c010bdf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bdf6:	0f b6 00             	movzbl (%eax),%eax
c010bdf9:	38 c2                	cmp    %al,%dl
c010bdfb:	74 d7                	je     c010bdd4 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bdfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010be01:	74 18                	je     c010be1b <strncmp+0x4c>
c010be03:	8b 45 08             	mov    0x8(%ebp),%eax
c010be06:	0f b6 00             	movzbl (%eax),%eax
c010be09:	0f b6 d0             	movzbl %al,%edx
c010be0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be0f:	0f b6 00             	movzbl (%eax),%eax
c010be12:	0f b6 c8             	movzbl %al,%ecx
c010be15:	89 d0                	mov    %edx,%eax
c010be17:	29 c8                	sub    %ecx,%eax
c010be19:	eb 05                	jmp    c010be20 <strncmp+0x51>
c010be1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010be20:	5d                   	pop    %ebp
c010be21:	c3                   	ret    

c010be22 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010be22:	55                   	push   %ebp
c010be23:	89 e5                	mov    %esp,%ebp
c010be25:	83 ec 04             	sub    $0x4,%esp
c010be28:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be2b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010be2e:	eb 13                	jmp    c010be43 <strchr+0x21>
        if (*s == c) {
c010be30:	8b 45 08             	mov    0x8(%ebp),%eax
c010be33:	0f b6 00             	movzbl (%eax),%eax
c010be36:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010be39:	75 05                	jne    c010be40 <strchr+0x1e>
            return (char *)s;
c010be3b:	8b 45 08             	mov    0x8(%ebp),%eax
c010be3e:	eb 12                	jmp    c010be52 <strchr+0x30>
        }
        s ++;
c010be40:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010be43:	8b 45 08             	mov    0x8(%ebp),%eax
c010be46:	0f b6 00             	movzbl (%eax),%eax
c010be49:	84 c0                	test   %al,%al
c010be4b:	75 e3                	jne    c010be30 <strchr+0xe>
    }
    return NULL;
c010be4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010be52:	89 ec                	mov    %ebp,%esp
c010be54:	5d                   	pop    %ebp
c010be55:	c3                   	ret    

c010be56 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010be56:	55                   	push   %ebp
c010be57:	89 e5                	mov    %esp,%ebp
c010be59:	83 ec 04             	sub    $0x4,%esp
c010be5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be5f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010be62:	eb 0e                	jmp    c010be72 <strfind+0x1c>
        if (*s == c) {
c010be64:	8b 45 08             	mov    0x8(%ebp),%eax
c010be67:	0f b6 00             	movzbl (%eax),%eax
c010be6a:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010be6d:	74 0f                	je     c010be7e <strfind+0x28>
            break;
        }
        s ++;
c010be6f:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c010be72:	8b 45 08             	mov    0x8(%ebp),%eax
c010be75:	0f b6 00             	movzbl (%eax),%eax
c010be78:	84 c0                	test   %al,%al
c010be7a:	75 e8                	jne    c010be64 <strfind+0xe>
c010be7c:	eb 01                	jmp    c010be7f <strfind+0x29>
            break;
c010be7e:	90                   	nop
    }
    return (char *)s;
c010be7f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010be82:	89 ec                	mov    %ebp,%esp
c010be84:	5d                   	pop    %ebp
c010be85:	c3                   	ret    

c010be86 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010be86:	55                   	push   %ebp
c010be87:	89 e5                	mov    %esp,%ebp
c010be89:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010be8c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010be93:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010be9a:	eb 03                	jmp    c010be9f <strtol+0x19>
        s ++;
c010be9c:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c010be9f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bea2:	0f b6 00             	movzbl (%eax),%eax
c010bea5:	3c 20                	cmp    $0x20,%al
c010bea7:	74 f3                	je     c010be9c <strtol+0x16>
c010bea9:	8b 45 08             	mov    0x8(%ebp),%eax
c010beac:	0f b6 00             	movzbl (%eax),%eax
c010beaf:	3c 09                	cmp    $0x9,%al
c010beb1:	74 e9                	je     c010be9c <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c010beb3:	8b 45 08             	mov    0x8(%ebp),%eax
c010beb6:	0f b6 00             	movzbl (%eax),%eax
c010beb9:	3c 2b                	cmp    $0x2b,%al
c010bebb:	75 05                	jne    c010bec2 <strtol+0x3c>
        s ++;
c010bebd:	ff 45 08             	incl   0x8(%ebp)
c010bec0:	eb 14                	jmp    c010bed6 <strtol+0x50>
    }
    else if (*s == '-') {
c010bec2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bec5:	0f b6 00             	movzbl (%eax),%eax
c010bec8:	3c 2d                	cmp    $0x2d,%al
c010beca:	75 0a                	jne    c010bed6 <strtol+0x50>
        s ++, neg = 1;
c010becc:	ff 45 08             	incl   0x8(%ebp)
c010becf:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010bed6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010beda:	74 06                	je     c010bee2 <strtol+0x5c>
c010bedc:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010bee0:	75 22                	jne    c010bf04 <strtol+0x7e>
c010bee2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bee5:	0f b6 00             	movzbl (%eax),%eax
c010bee8:	3c 30                	cmp    $0x30,%al
c010beea:	75 18                	jne    c010bf04 <strtol+0x7e>
c010beec:	8b 45 08             	mov    0x8(%ebp),%eax
c010beef:	40                   	inc    %eax
c010bef0:	0f b6 00             	movzbl (%eax),%eax
c010bef3:	3c 78                	cmp    $0x78,%al
c010bef5:	75 0d                	jne    c010bf04 <strtol+0x7e>
        s += 2, base = 16;
c010bef7:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010befb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010bf02:	eb 29                	jmp    c010bf2d <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010bf04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bf08:	75 16                	jne    c010bf20 <strtol+0x9a>
c010bf0a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf0d:	0f b6 00             	movzbl (%eax),%eax
c010bf10:	3c 30                	cmp    $0x30,%al
c010bf12:	75 0c                	jne    c010bf20 <strtol+0x9a>
        s ++, base = 8;
c010bf14:	ff 45 08             	incl   0x8(%ebp)
c010bf17:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010bf1e:	eb 0d                	jmp    c010bf2d <strtol+0xa7>
    }
    else if (base == 0) {
c010bf20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bf24:	75 07                	jne    c010bf2d <strtol+0xa7>
        base = 10;
c010bf26:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010bf2d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf30:	0f b6 00             	movzbl (%eax),%eax
c010bf33:	3c 2f                	cmp    $0x2f,%al
c010bf35:	7e 1b                	jle    c010bf52 <strtol+0xcc>
c010bf37:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf3a:	0f b6 00             	movzbl (%eax),%eax
c010bf3d:	3c 39                	cmp    $0x39,%al
c010bf3f:	7f 11                	jg     c010bf52 <strtol+0xcc>
            dig = *s - '0';
c010bf41:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf44:	0f b6 00             	movzbl (%eax),%eax
c010bf47:	0f be c0             	movsbl %al,%eax
c010bf4a:	83 e8 30             	sub    $0x30,%eax
c010bf4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bf50:	eb 48                	jmp    c010bf9a <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010bf52:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf55:	0f b6 00             	movzbl (%eax),%eax
c010bf58:	3c 60                	cmp    $0x60,%al
c010bf5a:	7e 1b                	jle    c010bf77 <strtol+0xf1>
c010bf5c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf5f:	0f b6 00             	movzbl (%eax),%eax
c010bf62:	3c 7a                	cmp    $0x7a,%al
c010bf64:	7f 11                	jg     c010bf77 <strtol+0xf1>
            dig = *s - 'a' + 10;
c010bf66:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf69:	0f b6 00             	movzbl (%eax),%eax
c010bf6c:	0f be c0             	movsbl %al,%eax
c010bf6f:	83 e8 57             	sub    $0x57,%eax
c010bf72:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bf75:	eb 23                	jmp    c010bf9a <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010bf77:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf7a:	0f b6 00             	movzbl (%eax),%eax
c010bf7d:	3c 40                	cmp    $0x40,%al
c010bf7f:	7e 3b                	jle    c010bfbc <strtol+0x136>
c010bf81:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf84:	0f b6 00             	movzbl (%eax),%eax
c010bf87:	3c 5a                	cmp    $0x5a,%al
c010bf89:	7f 31                	jg     c010bfbc <strtol+0x136>
            dig = *s - 'A' + 10;
c010bf8b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf8e:	0f b6 00             	movzbl (%eax),%eax
c010bf91:	0f be c0             	movsbl %al,%eax
c010bf94:	83 e8 37             	sub    $0x37,%eax
c010bf97:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010bf9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bf9d:	3b 45 10             	cmp    0x10(%ebp),%eax
c010bfa0:	7d 19                	jge    c010bfbb <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c010bfa2:	ff 45 08             	incl   0x8(%ebp)
c010bfa5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bfa8:	0f af 45 10          	imul   0x10(%ebp),%eax
c010bfac:	89 c2                	mov    %eax,%edx
c010bfae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bfb1:	01 d0                	add    %edx,%eax
c010bfb3:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c010bfb6:	e9 72 ff ff ff       	jmp    c010bf2d <strtol+0xa7>
            break;
c010bfbb:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010bfbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bfc0:	74 08                	je     c010bfca <strtol+0x144>
        *endptr = (char *) s;
c010bfc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfc5:	8b 55 08             	mov    0x8(%ebp),%edx
c010bfc8:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010bfca:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010bfce:	74 07                	je     c010bfd7 <strtol+0x151>
c010bfd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bfd3:	f7 d8                	neg    %eax
c010bfd5:	eb 03                	jmp    c010bfda <strtol+0x154>
c010bfd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010bfda:	89 ec                	mov    %ebp,%esp
c010bfdc:	5d                   	pop    %ebp
c010bfdd:	c3                   	ret    

c010bfde <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010bfde:	55                   	push   %ebp
c010bfdf:	89 e5                	mov    %esp,%ebp
c010bfe1:	83 ec 28             	sub    $0x28,%esp
c010bfe4:	89 7d fc             	mov    %edi,-0x4(%ebp)
c010bfe7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfea:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010bfed:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c010bff1:	8b 45 08             	mov    0x8(%ebp),%eax
c010bff4:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010bff7:	88 55 f7             	mov    %dl,-0x9(%ebp)
c010bffa:	8b 45 10             	mov    0x10(%ebp),%eax
c010bffd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010c000:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010c003:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010c007:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010c00a:	89 d7                	mov    %edx,%edi
c010c00c:	f3 aa                	rep stos %al,%es:(%edi)
c010c00e:	89 fa                	mov    %edi,%edx
c010c010:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010c013:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010c016:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010c019:	8b 7d fc             	mov    -0x4(%ebp),%edi
c010c01c:	89 ec                	mov    %ebp,%esp
c010c01e:	5d                   	pop    %ebp
c010c01f:	c3                   	ret    

c010c020 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010c020:	55                   	push   %ebp
c010c021:	89 e5                	mov    %esp,%ebp
c010c023:	57                   	push   %edi
c010c024:	56                   	push   %esi
c010c025:	53                   	push   %ebx
c010c026:	83 ec 30             	sub    $0x30,%esp
c010c029:	8b 45 08             	mov    0x8(%ebp),%eax
c010c02c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c02f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c032:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c035:	8b 45 10             	mov    0x10(%ebp),%eax
c010c038:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010c03b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c03e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010c041:	73 42                	jae    c010c085 <memmove+0x65>
c010c043:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c046:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010c049:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c04c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c04f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c052:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c055:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010c058:	c1 e8 02             	shr    $0x2,%eax
c010c05b:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010c05d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c060:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c063:	89 d7                	mov    %edx,%edi
c010c065:	89 c6                	mov    %eax,%esi
c010c067:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c069:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010c06c:	83 e1 03             	and    $0x3,%ecx
c010c06f:	74 02                	je     c010c073 <memmove+0x53>
c010c071:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c073:	89 f0                	mov    %esi,%eax
c010c075:	89 fa                	mov    %edi,%edx
c010c077:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010c07a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c07d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c010c080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c010c083:	eb 36                	jmp    c010c0bb <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010c085:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c088:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c08b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c08e:	01 c2                	add    %eax,%edx
c010c090:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c093:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010c096:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c099:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010c09c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c09f:	89 c1                	mov    %eax,%ecx
c010c0a1:	89 d8                	mov    %ebx,%eax
c010c0a3:	89 d6                	mov    %edx,%esi
c010c0a5:	89 c7                	mov    %eax,%edi
c010c0a7:	fd                   	std    
c010c0a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c0aa:	fc                   	cld    
c010c0ab:	89 f8                	mov    %edi,%eax
c010c0ad:	89 f2                	mov    %esi,%edx
c010c0af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010c0b2:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010c0b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010c0b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010c0bb:	83 c4 30             	add    $0x30,%esp
c010c0be:	5b                   	pop    %ebx
c010c0bf:	5e                   	pop    %esi
c010c0c0:	5f                   	pop    %edi
c010c0c1:	5d                   	pop    %ebp
c010c0c2:	c3                   	ret    

c010c0c3 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010c0c3:	55                   	push   %ebp
c010c0c4:	89 e5                	mov    %esp,%ebp
c010c0c6:	57                   	push   %edi
c010c0c7:	56                   	push   %esi
c010c0c8:	83 ec 20             	sub    $0x20,%esp
c010c0cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010c0ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010c0d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c0d7:	8b 45 10             	mov    0x10(%ebp),%eax
c010c0da:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010c0dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c0e0:	c1 e8 02             	shr    $0x2,%eax
c010c0e3:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010c0e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c0e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c0eb:	89 d7                	mov    %edx,%edi
c010c0ed:	89 c6                	mov    %eax,%esi
c010c0ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010c0f1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010c0f4:	83 e1 03             	and    $0x3,%ecx
c010c0f7:	74 02                	je     c010c0fb <memcpy+0x38>
c010c0f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010c0fb:	89 f0                	mov    %esi,%eax
c010c0fd:	89 fa                	mov    %edi,%edx
c010c0ff:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010c102:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c105:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010c108:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010c10b:	83 c4 20             	add    $0x20,%esp
c010c10e:	5e                   	pop    %esi
c010c10f:	5f                   	pop    %edi
c010c110:	5d                   	pop    %ebp
c010c111:	c3                   	ret    

c010c112 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010c112:	55                   	push   %ebp
c010c113:	89 e5                	mov    %esp,%ebp
c010c115:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010c118:	8b 45 08             	mov    0x8(%ebp),%eax
c010c11b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010c11e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c121:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010c124:	eb 2e                	jmp    c010c154 <memcmp+0x42>
        if (*s1 != *s2) {
c010c126:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c129:	0f b6 10             	movzbl (%eax),%edx
c010c12c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c12f:	0f b6 00             	movzbl (%eax),%eax
c010c132:	38 c2                	cmp    %al,%dl
c010c134:	74 18                	je     c010c14e <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010c136:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010c139:	0f b6 00             	movzbl (%eax),%eax
c010c13c:	0f b6 d0             	movzbl %al,%edx
c010c13f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010c142:	0f b6 00             	movzbl (%eax),%eax
c010c145:	0f b6 c8             	movzbl %al,%ecx
c010c148:	89 d0                	mov    %edx,%eax
c010c14a:	29 c8                	sub    %ecx,%eax
c010c14c:	eb 18                	jmp    c010c166 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010c14e:	ff 45 fc             	incl   -0x4(%ebp)
c010c151:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010c154:	8b 45 10             	mov    0x10(%ebp),%eax
c010c157:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c15a:	89 55 10             	mov    %edx,0x10(%ebp)
c010c15d:	85 c0                	test   %eax,%eax
c010c15f:	75 c5                	jne    c010c126 <memcmp+0x14>
    }
    return 0;
c010c161:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010c166:	89 ec                	mov    %ebp,%esp
c010c168:	5d                   	pop    %ebp
c010c169:	c3                   	ret    
