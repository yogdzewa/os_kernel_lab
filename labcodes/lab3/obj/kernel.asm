
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 40 12 00       	mov    $0x124000,%eax
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
c0100020:	a3 00 40 12 c0       	mov    %eax,0xc0124000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 30 12 c0       	mov    $0xc0123000,%esp
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
c010003c:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c0100041:	2d 00 60 12 c0       	sub    $0xc0126000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 60 12 c0 	movl   $0xc0126000,(%esp)
c0100059:	e8 c4 8d 00 00       	call   c0108e22 <memset>

    cons_init();                // init the console
c010005e:	e8 fc 15 00 00       	call   c010165f <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 c0 8f 10 c0 	movl   $0xc0108fc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 dc 8f 10 c0 	movl   $0xc0108fdc,(%esp)
c0100078:	e8 e8 02 00 00       	call   c0100365 <cprintf>

    print_kerninfo();
c010007d:	e8 06 08 00 00       	call   c0100888 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 9f 00 00 00       	call   c0100126 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 3f 4e 00 00       	call   c0104ecb <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 ac 1f 00 00       	call   c010203d <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 10 21 00 00       	call   c01021a6 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 ee 77 00 00       	call   c0107889 <vmm_init>

    ide_init();                 // init ide devices
c010009b:	e8 f9 16 00 00       	call   c0101799 <ide_init>
    swap_init();                // init swap
c01000a0:	e8 ab 61 00 00       	call   c0106250 <swap_init>

    clock_init();               // init clock interrupt
c01000a5:	e8 14 0d 00 00       	call   c0100dbe <clock_init>
    intr_enable();              // enable irq interrupt
c01000aa:	e8 ec 1e 00 00       	call   c0101f9b <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000af:	eb fe                	jmp    c01000af <kern_init+0x79>

c01000b1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b1:	55                   	push   %ebp
c01000b2:	89 e5                	mov    %esp,%ebp
c01000b4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000be:	00 
c01000bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c6:	00 
c01000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000ce:	e8 06 0c 00 00       	call   c0100cd9 <mon_backtrace>
}
c01000d3:	90                   	nop
c01000d4:	89 ec                	mov    %ebp,%esp
c01000d6:	5d                   	pop    %ebp
c01000d7:	c3                   	ret    

c01000d8 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d8:	55                   	push   %ebp
c01000d9:	89 e5                	mov    %esp,%ebp
c01000db:	83 ec 18             	sub    $0x18,%esp
c01000de:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b0 ff ff ff       	call   c01000b1 <grade_backtrace2>
}
c0100101:	90                   	nop
c0100102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100105:	89 ec                	mov    %ebp,%esp
c0100107:	5d                   	pop    %ebp
c0100108:	c3                   	ret    

c0100109 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100109:	55                   	push   %ebp
c010010a:	89 e5                	mov    %esp,%ebp
c010010c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100112:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100116:	8b 45 08             	mov    0x8(%ebp),%eax
c0100119:	89 04 24             	mov    %eax,(%esp)
c010011c:	e8 b7 ff ff ff       	call   c01000d8 <grade_backtrace1>
}
c0100121:	90                   	nop
c0100122:	89 ec                	mov    %ebp,%esp
c0100124:	5d                   	pop    %ebp
c0100125:	c3                   	ret    

c0100126 <grade_backtrace>:

void
grade_backtrace(void) {
c0100126:	55                   	push   %ebp
c0100127:	89 e5                	mov    %esp,%ebp
c0100129:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012c:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100131:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100138:	ff 
c0100139:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100144:	e8 c0 ff ff ff       	call   c0100109 <grade_backtrace0>
}
c0100149:	90                   	nop
c010014a:	89 ec                	mov    %ebp,%esp
c010014c:	5d                   	pop    %ebp
c010014d:	c3                   	ret    

c010014e <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014e:	55                   	push   %ebp
c010014f:	89 e5                	mov    %esp,%ebp
c0100151:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100154:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100157:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015a:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100160:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100164:	83 e0 03             	and    $0x3,%eax
c0100167:	89 c2                	mov    %eax,%edx
c0100169:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010016e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100172:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100176:	c7 04 24 e1 8f 10 c0 	movl   $0xc0108fe1,(%esp)
c010017d:	e8 e3 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100182:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100186:	89 c2                	mov    %eax,%edx
c0100188:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c010018d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100191:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100195:	c7 04 24 ef 8f 10 c0 	movl   $0xc0108fef,(%esp)
c010019c:	e8 c4 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a1:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a5:	89 c2                	mov    %eax,%edx
c01001a7:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ac:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b4:	c7 04 24 fd 8f 10 c0 	movl   $0xc0108ffd,(%esp)
c01001bb:	e8 a5 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c4:	89 c2                	mov    %eax,%edx
c01001c6:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001cb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d3:	c7 04 24 0b 90 10 c0 	movl   $0xc010900b,(%esp)
c01001da:	e8 86 01 00 00       	call   c0100365 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001df:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e3:	89 c2                	mov    %eax,%edx
c01001e5:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c01001ea:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f2:	c7 04 24 19 90 10 c0 	movl   $0xc0109019,(%esp)
c01001f9:	e8 67 01 00 00       	call   c0100365 <cprintf>
    round ++;
c01001fe:	a1 00 60 12 c0       	mov    0xc0126000,%eax
c0100203:	40                   	inc    %eax
c0100204:	a3 00 60 12 c0       	mov    %eax,0xc0126000
}
c0100209:	90                   	nop
c010020a:	89 ec                	mov    %ebp,%esp
c010020c:	5d                   	pop    %ebp
c010020d:	c3                   	ret    

c010020e <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020e:	55                   	push   %ebp
c010020f:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100211:	90                   	nop
c0100212:	5d                   	pop    %ebp
c0100213:	c3                   	ret    

c0100214 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100217:	90                   	nop
c0100218:	5d                   	pop    %ebp
c0100219:	c3                   	ret    

c010021a <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021a:	55                   	push   %ebp
c010021b:	89 e5                	mov    %esp,%ebp
c010021d:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100220:	e8 29 ff ff ff       	call   c010014e <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100225:	c7 04 24 28 90 10 c0 	movl   $0xc0109028,(%esp)
c010022c:	e8 34 01 00 00       	call   c0100365 <cprintf>
    lab1_switch_to_user();
c0100231:	e8 d8 ff ff ff       	call   c010020e <lab1_switch_to_user>
    lab1_print_cur_status();
c0100236:	e8 13 ff ff ff       	call   c010014e <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023b:	c7 04 24 48 90 10 c0 	movl   $0xc0109048,(%esp)
c0100242:	e8 1e 01 00 00       	call   c0100365 <cprintf>
    lab1_switch_to_kernel();
c0100247:	e8 c8 ff ff ff       	call   c0100214 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024c:	e8 fd fe ff ff       	call   c010014e <lab1_print_cur_status>
}
c0100251:	90                   	nop
c0100252:	89 ec                	mov    %ebp,%esp
c0100254:	5d                   	pop    %ebp
c0100255:	c3                   	ret    

c0100256 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100256:	55                   	push   %ebp
c0100257:	89 e5                	mov    %esp,%ebp
c0100259:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010025c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100260:	74 13                	je     c0100275 <readline+0x1f>
        cprintf("%s", prompt);
c0100262:	8b 45 08             	mov    0x8(%ebp),%eax
c0100265:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100269:	c7 04 24 67 90 10 c0 	movl   $0xc0109067,(%esp)
c0100270:	e8 f0 00 00 00       	call   c0100365 <cprintf>
    }
    int i = 0, c;
c0100275:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010027c:	e8 73 01 00 00       	call   c01003f4 <getchar>
c0100281:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100284:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100288:	79 07                	jns    c0100291 <readline+0x3b>
            return NULL;
c010028a:	b8 00 00 00 00       	mov    $0x0,%eax
c010028f:	eb 78                	jmp    c0100309 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100291:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100295:	7e 28                	jle    c01002bf <readline+0x69>
c0100297:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010029e:	7f 1f                	jg     c01002bf <readline+0x69>
            cputchar(c);
c01002a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a3:	89 04 24             	mov    %eax,(%esp)
c01002a6:	e8 e2 00 00 00       	call   c010038d <cputchar>
            buf[i ++] = c;
c01002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ae:	8d 50 01             	lea    0x1(%eax),%edx
c01002b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002b7:	88 90 20 60 12 c0    	mov    %dl,-0x3fed9fe0(%eax)
c01002bd:	eb 45                	jmp    c0100304 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002bf:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002c3:	75 16                	jne    c01002db <readline+0x85>
c01002c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c9:	7e 10                	jle    c01002db <readline+0x85>
            cputchar(c);
c01002cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ce:	89 04 24             	mov    %eax,(%esp)
c01002d1:	e8 b7 00 00 00       	call   c010038d <cputchar>
            i --;
c01002d6:	ff 4d f4             	decl   -0xc(%ebp)
c01002d9:	eb 29                	jmp    c0100304 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002db:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002df:	74 06                	je     c01002e7 <readline+0x91>
c01002e1:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002e5:	75 95                	jne    c010027c <readline+0x26>
            cputchar(c);
c01002e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ea:	89 04 24             	mov    %eax,(%esp)
c01002ed:	e8 9b 00 00 00       	call   c010038d <cputchar>
            buf[i] = '\0';
c01002f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002f5:	05 20 60 12 c0       	add    $0xc0126020,%eax
c01002fa:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002fd:	b8 20 60 12 c0       	mov    $0xc0126020,%eax
c0100302:	eb 05                	jmp    c0100309 <readline+0xb3>
        c = getchar();
c0100304:	e9 73 ff ff ff       	jmp    c010027c <readline+0x26>
        }
    }
}
c0100309:	89 ec                	mov    %ebp,%esp
c010030b:	5d                   	pop    %ebp
c010030c:	c3                   	ret    

c010030d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010030d:	55                   	push   %ebp
c010030e:	89 e5                	mov    %esp,%ebp
c0100310:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100313:	8b 45 08             	mov    0x8(%ebp),%eax
c0100316:	89 04 24             	mov    %eax,(%esp)
c0100319:	e8 70 13 00 00       	call   c010168e <cons_putc>
    (*cnt) ++;
c010031e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100321:	8b 00                	mov    (%eax),%eax
c0100323:	8d 50 01             	lea    0x1(%eax),%edx
c0100326:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100329:	89 10                	mov    %edx,(%eax)
}
c010032b:	90                   	nop
c010032c:	89 ec                	mov    %ebp,%esp
c010032e:	5d                   	pop    %ebp
c010032f:	c3                   	ret    

c0100330 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100330:	55                   	push   %ebp
c0100331:	89 e5                	mov    %esp,%ebp
c0100333:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100336:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010033d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100340:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100344:	8b 45 08             	mov    0x8(%ebp),%eax
c0100347:	89 44 24 08          	mov    %eax,0x8(%esp)
c010034b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010034e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100352:	c7 04 24 0d 03 10 c0 	movl   $0xc010030d,(%esp)
c0100359:	e8 17 82 00 00       	call   c0108575 <vprintfmt>
    return cnt;
c010035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100361:	89 ec                	mov    %ebp,%esp
c0100363:	5d                   	pop    %ebp
c0100364:	c3                   	ret    

c0100365 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100365:	55                   	push   %ebp
c0100366:	89 e5                	mov    %esp,%ebp
c0100368:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010036b:	8d 45 0c             	lea    0xc(%ebp),%eax
c010036e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100374:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100378:	8b 45 08             	mov    0x8(%ebp),%eax
c010037b:	89 04 24             	mov    %eax,(%esp)
c010037e:	e8 ad ff ff ff       	call   c0100330 <vcprintf>
c0100383:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100386:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100389:	89 ec                	mov    %ebp,%esp
c010038b:	5d                   	pop    %ebp
c010038c:	c3                   	ret    

c010038d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010038d:	55                   	push   %ebp
c010038e:	89 e5                	mov    %esp,%ebp
c0100390:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100393:	8b 45 08             	mov    0x8(%ebp),%eax
c0100396:	89 04 24             	mov    %eax,(%esp)
c0100399:	e8 f0 12 00 00       	call   c010168e <cons_putc>
}
c010039e:	90                   	nop
c010039f:	89 ec                	mov    %ebp,%esp
c01003a1:	5d                   	pop    %ebp
c01003a2:	c3                   	ret    

c01003a3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003a3:	55                   	push   %ebp
c01003a4:	89 e5                	mov    %esp,%ebp
c01003a6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003b0:	eb 13                	jmp    c01003c5 <cputs+0x22>
        cputch(c, &cnt);
c01003b2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003b6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003bd:	89 04 24             	mov    %eax,(%esp)
c01003c0:	e8 48 ff ff ff       	call   c010030d <cputch>
    while ((c = *str ++) != '\0') {
c01003c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01003c8:	8d 50 01             	lea    0x1(%eax),%edx
c01003cb:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ce:	0f b6 00             	movzbl (%eax),%eax
c01003d1:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003d4:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003d8:	75 d8                	jne    c01003b2 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003da:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003e1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003e8:	e8 20 ff ff ff       	call   c010030d <cputch>
    return cnt;
c01003ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003f0:	89 ec                	mov    %ebp,%esp
c01003f2:	5d                   	pop    %ebp
c01003f3:	c3                   	ret    

c01003f4 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003fa:	90                   	nop
c01003fb:	e8 cd 12 00 00       	call   c01016cd <cons_getc>
c0100400:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100403:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100407:	74 f2                	je     c01003fb <getchar+0x7>
        /* do nothing */;
    return c;
c0100409:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010040c:	89 ec                	mov    %ebp,%esp
c010040e:	5d                   	pop    %ebp
c010040f:	c3                   	ret    

c0100410 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100410:	55                   	push   %ebp
c0100411:	89 e5                	mov    %esp,%ebp
c0100413:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100416:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100419:	8b 00                	mov    (%eax),%eax
c010041b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010041e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100421:	8b 00                	mov    (%eax),%eax
c0100423:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100426:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010042d:	e9 ca 00 00 00       	jmp    c01004fc <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100432:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100435:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100438:	01 d0                	add    %edx,%eax
c010043a:	89 c2                	mov    %eax,%edx
c010043c:	c1 ea 1f             	shr    $0x1f,%edx
c010043f:	01 d0                	add    %edx,%eax
c0100441:	d1 f8                	sar    %eax
c0100443:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100446:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100449:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010044c:	eb 03                	jmp    c0100451 <stab_binsearch+0x41>
            m --;
c010044e:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100451:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100454:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100457:	7c 1f                	jl     c0100478 <stab_binsearch+0x68>
c0100459:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010045c:	89 d0                	mov    %edx,%eax
c010045e:	01 c0                	add    %eax,%eax
c0100460:	01 d0                	add    %edx,%eax
c0100462:	c1 e0 02             	shl    $0x2,%eax
c0100465:	89 c2                	mov    %eax,%edx
c0100467:	8b 45 08             	mov    0x8(%ebp),%eax
c010046a:	01 d0                	add    %edx,%eax
c010046c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100470:	0f b6 c0             	movzbl %al,%eax
c0100473:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100476:	75 d6                	jne    c010044e <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100478:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010047b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010047e:	7d 09                	jge    c0100489 <stab_binsearch+0x79>
            l = true_m + 1;
c0100480:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100483:	40                   	inc    %eax
c0100484:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100487:	eb 73                	jmp    c01004fc <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100489:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100490:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100493:	89 d0                	mov    %edx,%eax
c0100495:	01 c0                	add    %eax,%eax
c0100497:	01 d0                	add    %edx,%eax
c0100499:	c1 e0 02             	shl    $0x2,%eax
c010049c:	89 c2                	mov    %eax,%edx
c010049e:	8b 45 08             	mov    0x8(%ebp),%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	8b 40 08             	mov    0x8(%eax),%eax
c01004a6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004a9:	76 11                	jbe    c01004bc <stab_binsearch+0xac>
            *region_left = m;
c01004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b1:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004b6:	40                   	inc    %eax
c01004b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ba:	eb 40                	jmp    c01004fc <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004bf:	89 d0                	mov    %edx,%eax
c01004c1:	01 c0                	add    %eax,%eax
c01004c3:	01 d0                	add    %edx,%eax
c01004c5:	c1 e0 02             	shl    $0x2,%eax
c01004c8:	89 c2                	mov    %eax,%edx
c01004ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01004cd:	01 d0                	add    %edx,%eax
c01004cf:	8b 40 08             	mov    0x8(%eax),%eax
c01004d2:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004d5:	73 14                	jae    c01004eb <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e0:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	48                   	dec    %eax
c01004e6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e9:	eb 11                	jmp    c01004fc <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ee:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004f9:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004ff:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100502:	0f 8e 2a ff ff ff    	jle    c0100432 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c0100508:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010050c:	75 0f                	jne    c010051d <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c010050e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100516:	8b 45 10             	mov    0x10(%ebp),%eax
c0100519:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010051b:	eb 3e                	jmp    c010055b <stab_binsearch+0x14b>
        l = *region_right;
c010051d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100520:	8b 00                	mov    (%eax),%eax
c0100522:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100525:	eb 03                	jmp    c010052a <stab_binsearch+0x11a>
c0100527:	ff 4d fc             	decl   -0x4(%ebp)
c010052a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052d:	8b 00                	mov    (%eax),%eax
c010052f:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100532:	7e 1f                	jle    c0100553 <stab_binsearch+0x143>
c0100534:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100537:	89 d0                	mov    %edx,%eax
c0100539:	01 c0                	add    %eax,%eax
c010053b:	01 d0                	add    %edx,%eax
c010053d:	c1 e0 02             	shl    $0x2,%eax
c0100540:	89 c2                	mov    %eax,%edx
c0100542:	8b 45 08             	mov    0x8(%ebp),%eax
c0100545:	01 d0                	add    %edx,%eax
c0100547:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010054b:	0f b6 c0             	movzbl %al,%eax
c010054e:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100551:	75 d4                	jne    c0100527 <stab_binsearch+0x117>
        *region_left = l;
c0100553:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100556:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100559:	89 10                	mov    %edx,(%eax)
}
c010055b:	90                   	nop
c010055c:	89 ec                	mov    %ebp,%esp
c010055e:	5d                   	pop    %ebp
c010055f:	c3                   	ret    

c0100560 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100560:	55                   	push   %ebp
c0100561:	89 e5                	mov    %esp,%ebp
c0100563:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100566:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100569:	c7 00 6c 90 10 c0    	movl   $0xc010906c,(%eax)
    info->eip_line = 0;
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	c7 40 08 6c 90 10 c0 	movl   $0xc010906c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100583:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100586:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010058d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100590:	8b 55 08             	mov    0x8(%ebp),%edx
c0100593:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100596:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100599:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005a0:	c7 45 f4 50 b0 10 c0 	movl   $0xc010b050,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005a7:	c7 45 f0 70 b6 11 c0 	movl   $0xc011b670,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005ae:	c7 45 ec 71 b6 11 c0 	movl   $0xc011b671,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005b5:	c7 45 e8 ab 05 12 c0 	movl   $0xc01205ab,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005c2:	76 0b                	jbe    c01005cf <debuginfo_eip+0x6f>
c01005c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005c7:	48                   	dec    %eax
c01005c8:	0f b6 00             	movzbl (%eax),%eax
c01005cb:	84 c0                	test   %al,%al
c01005cd:	74 0a                	je     c01005d9 <debuginfo_eip+0x79>
        return -1;
c01005cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005d4:	e9 ab 02 00 00       	jmp    c0100884 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e3:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005e6:	c1 f8 02             	sar    $0x2,%eax
c01005e9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005ef:	48                   	dec    %eax
c01005f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f6:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005fa:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100601:	00 
c0100602:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100605:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100609:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010060c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100613:	89 04 24             	mov    %eax,(%esp)
c0100616:	e8 f5 fd ff ff       	call   c0100410 <stab_binsearch>
    if (lfile == 0)
c010061b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061e:	85 c0                	test   %eax,%eax
c0100620:	75 0a                	jne    c010062c <debuginfo_eip+0xcc>
        return -1;
c0100622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100627:	e9 58 02 00 00       	jmp    c0100884 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010062c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100632:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100635:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100638:	8b 45 08             	mov    0x8(%ebp),%eax
c010063b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010063f:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100646:	00 
c0100647:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010064a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010064e:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100651:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100655:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100658:	89 04 24             	mov    %eax,(%esp)
c010065b:	e8 b0 fd ff ff       	call   c0100410 <stab_binsearch>

    if (lfun <= rfun) {
c0100660:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100663:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100666:	39 c2                	cmp    %eax,%edx
c0100668:	7f 78                	jg     c01006e2 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010066a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010066d:	89 c2                	mov    %eax,%edx
c010066f:	89 d0                	mov    %edx,%eax
c0100671:	01 c0                	add    %eax,%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	c1 e0 02             	shl    $0x2,%eax
c0100678:	89 c2                	mov    %eax,%edx
c010067a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010067d:	01 d0                	add    %edx,%eax
c010067f:	8b 10                	mov    (%eax),%edx
c0100681:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100684:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100687:	39 c2                	cmp    %eax,%edx
c0100689:	73 22                	jae    c01006ad <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010068b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010068e:	89 c2                	mov    %eax,%edx
c0100690:	89 d0                	mov    %edx,%eax
c0100692:	01 c0                	add    %eax,%eax
c0100694:	01 d0                	add    %edx,%eax
c0100696:	c1 e0 02             	shl    $0x2,%eax
c0100699:	89 c2                	mov    %eax,%edx
c010069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069e:	01 d0                	add    %edx,%eax
c01006a0:	8b 10                	mov    (%eax),%edx
c01006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006a5:	01 c2                	add    %eax,%edx
c01006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006aa:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006b0:	89 c2                	mov    %eax,%edx
c01006b2:	89 d0                	mov    %edx,%eax
c01006b4:	01 c0                	add    %eax,%eax
c01006b6:	01 d0                	add    %edx,%eax
c01006b8:	c1 e0 02             	shl    $0x2,%eax
c01006bb:	89 c2                	mov    %eax,%edx
c01006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c0:	01 d0                	add    %edx,%eax
c01006c2:	8b 50 08             	mov    0x8(%eax),%edx
c01006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c8:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006ce:	8b 40 10             	mov    0x10(%eax),%eax
c01006d1:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006da:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006e0:	eb 15                	jmp    c01006f7 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e8:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fa:	8b 40 08             	mov    0x8(%eax),%eax
c01006fd:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100704:	00 
c0100705:	89 04 24             	mov    %eax,(%esp)
c0100708:	e8 8d 85 00 00       	call   c0108c9a <strfind>
c010070d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100710:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100713:	29 c8                	sub    %ecx,%eax
c0100715:	89 c2                	mov    %eax,%edx
c0100717:	8b 45 0c             	mov    0xc(%ebp),%eax
c010071a:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010071d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100720:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100724:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010072b:	00 
c010072c:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010072f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100733:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100736:	89 44 24 04          	mov    %eax,0x4(%esp)
c010073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073d:	89 04 24             	mov    %eax,(%esp)
c0100740:	e8 cb fc ff ff       	call   c0100410 <stab_binsearch>
    if (lline <= rline) {
c0100745:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100748:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074b:	39 c2                	cmp    %eax,%edx
c010074d:	7f 23                	jg     c0100772 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c010074f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100752:	89 c2                	mov    %eax,%edx
c0100754:	89 d0                	mov    %edx,%eax
c0100756:	01 c0                	add    %eax,%eax
c0100758:	01 d0                	add    %edx,%eax
c010075a:	c1 e0 02             	shl    $0x2,%eax
c010075d:	89 c2                	mov    %eax,%edx
c010075f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100762:	01 d0                	add    %edx,%eax
c0100764:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100768:	89 c2                	mov    %eax,%edx
c010076a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100770:	eb 11                	jmp    c0100783 <debuginfo_eip+0x223>
        return -1;
c0100772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100777:	e9 08 01 00 00       	jmp    c0100884 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010077c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077f:	48                   	dec    %eax
c0100780:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100783:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100789:	39 c2                	cmp    %eax,%edx
c010078b:	7c 56                	jl     c01007e3 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010078d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100790:	89 c2                	mov    %eax,%edx
c0100792:	89 d0                	mov    %edx,%eax
c0100794:	01 c0                	add    %eax,%eax
c0100796:	01 d0                	add    %edx,%eax
c0100798:	c1 e0 02             	shl    $0x2,%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a0:	01 d0                	add    %edx,%eax
c01007a2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a6:	3c 84                	cmp    $0x84,%al
c01007a8:	74 39                	je     c01007e3 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ad:	89 c2                	mov    %eax,%edx
c01007af:	89 d0                	mov    %edx,%eax
c01007b1:	01 c0                	add    %eax,%eax
c01007b3:	01 d0                	add    %edx,%eax
c01007b5:	c1 e0 02             	shl    $0x2,%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bd:	01 d0                	add    %edx,%eax
c01007bf:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c3:	3c 64                	cmp    $0x64,%al
c01007c5:	75 b5                	jne    c010077c <debuginfo_eip+0x21c>
c01007c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ca:	89 c2                	mov    %eax,%edx
c01007cc:	89 d0                	mov    %edx,%eax
c01007ce:	01 c0                	add    %eax,%eax
c01007d0:	01 d0                	add    %edx,%eax
c01007d2:	c1 e0 02             	shl    $0x2,%eax
c01007d5:	89 c2                	mov    %eax,%edx
c01007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007da:	01 d0                	add    %edx,%eax
c01007dc:	8b 40 08             	mov    0x8(%eax),%eax
c01007df:	85 c0                	test   %eax,%eax
c01007e1:	74 99                	je     c010077c <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e9:	39 c2                	cmp    %eax,%edx
c01007eb:	7c 42                	jl     c010082f <debuginfo_eip+0x2cf>
c01007ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007f0:	89 c2                	mov    %eax,%edx
c01007f2:	89 d0                	mov    %edx,%eax
c01007f4:	01 c0                	add    %eax,%eax
c01007f6:	01 d0                	add    %edx,%eax
c01007f8:	c1 e0 02             	shl    $0x2,%eax
c01007fb:	89 c2                	mov    %eax,%edx
c01007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100800:	01 d0                	add    %edx,%eax
c0100802:	8b 10                	mov    (%eax),%edx
c0100804:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100807:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010080a:	39 c2                	cmp    %eax,%edx
c010080c:	73 21                	jae    c010082f <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100811:	89 c2                	mov    %eax,%edx
c0100813:	89 d0                	mov    %edx,%eax
c0100815:	01 c0                	add    %eax,%eax
c0100817:	01 d0                	add    %edx,%eax
c0100819:	c1 e0 02             	shl    $0x2,%eax
c010081c:	89 c2                	mov    %eax,%edx
c010081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100821:	01 d0                	add    %edx,%eax
c0100823:	8b 10                	mov    (%eax),%edx
c0100825:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100828:	01 c2                	add    %eax,%edx
c010082a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082d:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010082f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100832:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100835:	39 c2                	cmp    %eax,%edx
c0100837:	7d 46                	jge    c010087f <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c0100839:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083c:	40                   	inc    %eax
c010083d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100840:	eb 16                	jmp    c0100858 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100845:	8b 40 14             	mov    0x14(%eax),%eax
c0100848:	8d 50 01             	lea    0x1(%eax),%edx
c010084b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010084e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100854:	40                   	inc    %eax
c0100855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010085b:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c010085e:	39 c2                	cmp    %eax,%edx
c0100860:	7d 1d                	jge    c010087f <debuginfo_eip+0x31f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100862:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100865:	89 c2                	mov    %eax,%edx
c0100867:	89 d0                	mov    %edx,%eax
c0100869:	01 c0                	add    %eax,%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	c1 e0 02             	shl    $0x2,%eax
c0100870:	89 c2                	mov    %eax,%edx
c0100872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100875:	01 d0                	add    %edx,%eax
c0100877:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087b:	3c a0                	cmp    $0xa0,%al
c010087d:	74 c3                	je     c0100842 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c010087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100884:	89 ec                	mov    %ebp,%esp
c0100886:	5d                   	pop    %ebp
c0100887:	c3                   	ret    

c0100888 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100888:	55                   	push   %ebp
c0100889:	89 e5                	mov    %esp,%ebp
c010088b:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010088e:	c7 04 24 76 90 10 c0 	movl   $0xc0109076,(%esp)
c0100895:	e8 cb fa ff ff       	call   c0100365 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089a:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a1:	c0 
c01008a2:	c7 04 24 8f 90 10 c0 	movl   $0xc010908f,(%esp)
c01008a9:	e8 b7 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ae:	c7 44 24 04 ae 8f 10 	movl   $0xc0108fae,0x4(%esp)
c01008b5:	c0 
c01008b6:	c7 04 24 a7 90 10 c0 	movl   $0xc01090a7,(%esp)
c01008bd:	e8 a3 fa ff ff       	call   c0100365 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c2:	c7 44 24 04 00 60 12 	movl   $0xc0126000,0x4(%esp)
c01008c9:	c0 
c01008ca:	c7 04 24 bf 90 10 c0 	movl   $0xc01090bf,(%esp)
c01008d1:	e8 8f fa ff ff       	call   c0100365 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d6:	c7 44 24 04 14 71 12 	movl   $0xc0127114,0x4(%esp)
c01008dd:	c0 
c01008de:	c7 04 24 d7 90 10 c0 	movl   $0xc01090d7,(%esp)
c01008e5:	e8 7b fa ff ff       	call   c0100365 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ea:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c01008ef:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008f4:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008f9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008ff:	85 c0                	test   %eax,%eax
c0100901:	0f 48 c2             	cmovs  %edx,%eax
c0100904:	c1 f8 0a             	sar    $0xa,%eax
c0100907:	89 44 24 04          	mov    %eax,0x4(%esp)
c010090b:	c7 04 24 f0 90 10 c0 	movl   $0xc01090f0,(%esp)
c0100912:	e8 4e fa ff ff       	call   c0100365 <cprintf>
}
c0100917:	90                   	nop
c0100918:	89 ec                	mov    %ebp,%esp
c010091a:	5d                   	pop    %ebp
c010091b:	c3                   	ret    

c010091c <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010091c:	55                   	push   %ebp
c010091d:	89 e5                	mov    %esp,%ebp
c010091f:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100925:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100928:	89 44 24 04          	mov    %eax,0x4(%esp)
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 04 24             	mov    %eax,(%esp)
c0100932:	e8 29 fc ff ff       	call   c0100560 <debuginfo_eip>
c0100937:	85 c0                	test   %eax,%eax
c0100939:	74 15                	je     c0100950 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010093b:	8b 45 08             	mov    0x8(%ebp),%eax
c010093e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100942:	c7 04 24 1a 91 10 c0 	movl   $0xc010911a,(%esp)
c0100949:	e8 17 fa ff ff       	call   c0100365 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010094e:	eb 6c                	jmp    c01009bc <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100957:	eb 1b                	jmp    c0100974 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095f:	01 d0                	add    %edx,%eax
c0100961:	0f b6 10             	movzbl (%eax),%edx
c0100964:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096d:	01 c8                	add    %ecx,%eax
c010096f:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100971:	ff 45 f4             	incl   -0xc(%ebp)
c0100974:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100977:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010097a:	7c dd                	jl     c0100959 <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010097c:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100985:	01 d0                	add    %edx,%eax
c0100987:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010098a:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010098d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100990:	29 d0                	sub    %edx,%eax
c0100992:	89 c1                	mov    %eax,%ecx
c0100994:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100997:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010099a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010099e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009a4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b0:	c7 04 24 36 91 10 c0 	movl   $0xc0109136,(%esp)
c01009b7:	e8 a9 f9 ff ff       	call   c0100365 <cprintf>
}
c01009bc:	90                   	nop
c01009bd:	89 ec                	mov    %ebp,%esp
c01009bf:	5d                   	pop    %ebp
c01009c0:	c3                   	ret    

c01009c1 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c1:	55                   	push   %ebp
c01009c2:	89 e5                	mov    %esp,%ebp
c01009c4:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009c7:	8b 45 04             	mov    0x4(%ebp),%eax
c01009ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d0:	89 ec                	mov    %ebp,%esp
c01009d2:	5d                   	pop    %ebp
c01009d3:	c3                   	ret    

c01009d4 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d4:	55                   	push   %ebp
c01009d5:	89 e5                	mov    %esp,%ebp
c01009d7:	83 ec 38             	sub    $0x38,%esp
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t eip, ebp;
    eip = read_eip();
c01009da:	e8 e2 ff ff ff       	call   c01009c1 <read_eip>
c01009df:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009e2:	89 e8                	mov    %ebp,%eax
c01009e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    ebp = read_ebp();
c01009ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c01009ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f4:	eb 7e                	jmp    c0100a74 <print_stackframe+0xa0>
    {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a04:	c7 04 24 48 91 10 c0 	movl   $0xc0109148,(%esp)
c0100a0b:	e8 55 f9 ff ff       	call   c0100365 <cprintf>
        for (j = 0; j < 4; j++)
c0100a10:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a17:	eb 27                	jmp    c0100a40 <print_stackframe+0x6c>
        {
            cprintf("0x%08x ", ((uint32_t *)ebp + 2)[j]);
c0100a19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a26:	01 d0                	add    %edx,%eax
c0100a28:	83 c0 08             	add    $0x8,%eax
c0100a2b:	8b 00                	mov    (%eax),%eax
c0100a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a31:	c7 04 24 64 91 10 c0 	movl   $0xc0109164,(%esp)
c0100a38:	e8 28 f9 ff ff       	call   c0100365 <cprintf>
        for (j = 0; j < 4; j++)
c0100a3d:	ff 45 e8             	incl   -0x18(%ebp)
c0100a40:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a44:	7e d3                	jle    c0100a19 <print_stackframe+0x45>
        }
        cprintf("\n");
c0100a46:	c7 04 24 6c 91 10 c0 	movl   $0xc010916c,(%esp)
c0100a4d:	e8 13 f9 ff ff       	call   c0100365 <cprintf>
        print_debuginfo(eip - 1);
c0100a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a55:	48                   	dec    %eax
c0100a56:	89 04 24             	mov    %eax,(%esp)
c0100a59:	e8 be fe ff ff       	call   c010091c <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a61:	83 c0 04             	add    $0x4,%eax
c0100a64:	8b 00                	mov    (%eax),%eax
c0100a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a6c:	8b 00                	mov    (%eax),%eax
c0100a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++)
c0100a71:	ff 45 ec             	incl   -0x14(%ebp)
c0100a74:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100a78:	74 0a                	je     c0100a84 <print_stackframe+0xb0>
c0100a7a:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a7e:	0f 8e 72 ff ff ff    	jle    c01009f6 <print_stackframe+0x22>
    }
	cprintf("What the fuck?");
c0100a84:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c0100a8b:	e8 d5 f8 ff ff       	call   c0100365 <cprintf>
}
c0100a90:	90                   	nop
c0100a91:	89 ec                	mov    %ebp,%esp
c0100a93:	5d                   	pop    %ebp
c0100a94:	c3                   	ret    

c0100a95 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a95:	55                   	push   %ebp
c0100a96:	89 e5                	mov    %esp,%ebp
c0100a98:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa2:	eb 0c                	jmp    c0100ab0 <parse+0x1b>
            *buf ++ = '\0';
c0100aa4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa7:	8d 50 01             	lea    0x1(%eax),%edx
c0100aaa:	89 55 08             	mov    %edx,0x8(%ebp)
c0100aad:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ab0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab3:	0f b6 00             	movzbl (%eax),%eax
c0100ab6:	84 c0                	test   %al,%al
c0100ab8:	74 1d                	je     c0100ad7 <parse+0x42>
c0100aba:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abd:	0f b6 00             	movzbl (%eax),%eax
c0100ac0:	0f be c0             	movsbl %al,%eax
c0100ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac7:	c7 04 24 00 92 10 c0 	movl   $0xc0109200,(%esp)
c0100ace:	e8 93 81 00 00       	call   c0108c66 <strchr>
c0100ad3:	85 c0                	test   %eax,%eax
c0100ad5:	75 cd                	jne    c0100aa4 <parse+0xf>
        }
        if (*buf == '\0') {
c0100ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ada:	0f b6 00             	movzbl (%eax),%eax
c0100add:	84 c0                	test   %al,%al
c0100adf:	74 65                	je     c0100b46 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ae1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ae5:	75 14                	jne    c0100afb <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ae7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100aee:	00 
c0100aef:	c7 04 24 05 92 10 c0 	movl   $0xc0109205,(%esp)
c0100af6:	e8 6a f8 ff ff       	call   c0100365 <cprintf>
        }
        argv[argc ++] = buf;
c0100afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afe:	8d 50 01             	lea    0x1(%eax),%edx
c0100b01:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b0e:	01 c2                	add    %eax,%edx
c0100b10:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b13:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b15:	eb 03                	jmp    c0100b1a <parse+0x85>
            buf ++;
c0100b17:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1d:	0f b6 00             	movzbl (%eax),%eax
c0100b20:	84 c0                	test   %al,%al
c0100b22:	74 8c                	je     c0100ab0 <parse+0x1b>
c0100b24:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b27:	0f b6 00             	movzbl (%eax),%eax
c0100b2a:	0f be c0             	movsbl %al,%eax
c0100b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b31:	c7 04 24 00 92 10 c0 	movl   $0xc0109200,(%esp)
c0100b38:	e8 29 81 00 00       	call   c0108c66 <strchr>
c0100b3d:	85 c0                	test   %eax,%eax
c0100b3f:	74 d6                	je     c0100b17 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b41:	e9 6a ff ff ff       	jmp    c0100ab0 <parse+0x1b>
            break;
c0100b46:	90                   	nop
        }
    }
    return argc;
c0100b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b4a:	89 ec                	mov    %ebp,%esp
c0100b4c:	5d                   	pop    %ebp
c0100b4d:	c3                   	ret    

c0100b4e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b4e:	55                   	push   %ebp
c0100b4f:	89 e5                	mov    %esp,%ebp
c0100b51:	83 ec 68             	sub    $0x68,%esp
c0100b54:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b57:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b61:	89 04 24             	mov    %eax,(%esp)
c0100b64:	e8 2c ff ff ff       	call   c0100a95 <parse>
c0100b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b70:	75 0a                	jne    c0100b7c <runcmd+0x2e>
        return 0;
c0100b72:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b77:	e9 83 00 00 00       	jmp    c0100bff <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b7c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b83:	eb 5a                	jmp    c0100bdf <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b85:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b88:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b8b:	89 c8                	mov    %ecx,%eax
c0100b8d:	01 c0                	add    %eax,%eax
c0100b8f:	01 c8                	add    %ecx,%eax
c0100b91:	c1 e0 02             	shl    $0x2,%eax
c0100b94:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100b99:	8b 00                	mov    (%eax),%eax
c0100b9b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b9f:	89 04 24             	mov    %eax,(%esp)
c0100ba2:	e8 23 80 00 00       	call   c0108bca <strcmp>
c0100ba7:	85 c0                	test   %eax,%eax
c0100ba9:	75 31                	jne    c0100bdc <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100bab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bae:	89 d0                	mov    %edx,%eax
c0100bb0:	01 c0                	add    %eax,%eax
c0100bb2:	01 d0                	add    %edx,%eax
c0100bb4:	c1 e0 02             	shl    $0x2,%eax
c0100bb7:	05 08 30 12 c0       	add    $0xc0123008,%eax
c0100bbc:	8b 10                	mov    (%eax),%edx
c0100bbe:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bc1:	83 c0 04             	add    $0x4,%eax
c0100bc4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bc7:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd5:	89 1c 24             	mov    %ebx,(%esp)
c0100bd8:	ff d2                	call   *%edx
c0100bda:	eb 23                	jmp    c0100bff <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bdc:	ff 45 f4             	incl   -0xc(%ebp)
c0100bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be2:	83 f8 02             	cmp    $0x2,%eax
c0100be5:	76 9e                	jbe    c0100b85 <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100be7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bee:	c7 04 24 23 92 10 c0 	movl   $0xc0109223,(%esp)
c0100bf5:	e8 6b f7 ff ff       	call   c0100365 <cprintf>
    return 0;
c0100bfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c02:	89 ec                	mov    %ebp,%esp
c0100c04:	5d                   	pop    %ebp
c0100c05:	c3                   	ret    

c0100c06 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c06:	55                   	push   %ebp
c0100c07:	89 e5                	mov    %esp,%ebp
c0100c09:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c0c:	c7 04 24 3c 92 10 c0 	movl   $0xc010923c,(%esp)
c0100c13:	e8 4d f7 ff ff       	call   c0100365 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c18:	c7 04 24 64 92 10 c0 	movl   $0xc0109264,(%esp)
c0100c1f:	e8 41 f7 ff ff       	call   c0100365 <cprintf>

    if (tf != NULL) {
c0100c24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c28:	74 0b                	je     c0100c35 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2d:	89 04 24             	mov    %eax,(%esp)
c0100c30:	e8 2c 17 00 00       	call   c0102361 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c35:	c7 04 24 89 92 10 c0 	movl   $0xc0109289,(%esp)
c0100c3c:	e8 15 f6 ff ff       	call   c0100256 <readline>
c0100c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c48:	74 eb                	je     c0100c35 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c54:	89 04 24             	mov    %eax,(%esp)
c0100c57:	e8 f2 fe ff ff       	call   c0100b4e <runcmd>
c0100c5c:	85 c0                	test   %eax,%eax
c0100c5e:	78 02                	js     c0100c62 <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c60:	eb d3                	jmp    c0100c35 <kmonitor+0x2f>
                break;
c0100c62:	90                   	nop
            }
        }
    }
}
c0100c63:	90                   	nop
c0100c64:	89 ec                	mov    %ebp,%esp
c0100c66:	5d                   	pop    %ebp
c0100c67:	c3                   	ret    

c0100c68 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c68:	55                   	push   %ebp
c0100c69:	89 e5                	mov    %esp,%ebp
c0100c6b:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c75:	eb 3d                	jmp    c0100cb4 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c7a:	89 d0                	mov    %edx,%eax
c0100c7c:	01 c0                	add    %eax,%eax
c0100c7e:	01 d0                	add    %edx,%eax
c0100c80:	c1 e0 02             	shl    $0x2,%eax
c0100c83:	05 04 30 12 c0       	add    $0xc0123004,%eax
c0100c88:	8b 10                	mov    (%eax),%edx
c0100c8a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c8d:	89 c8                	mov    %ecx,%eax
c0100c8f:	01 c0                	add    %eax,%eax
c0100c91:	01 c8                	add    %ecx,%eax
c0100c93:	c1 e0 02             	shl    $0x2,%eax
c0100c96:	05 00 30 12 c0       	add    $0xc0123000,%eax
c0100c9b:	8b 00                	mov    (%eax),%eax
c0100c9d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca5:	c7 04 24 8d 92 10 c0 	movl   $0xc010928d,(%esp)
c0100cac:	e8 b4 f6 ff ff       	call   c0100365 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cb1:	ff 45 f4             	incl   -0xc(%ebp)
c0100cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb7:	83 f8 02             	cmp    $0x2,%eax
c0100cba:	76 bb                	jbe    c0100c77 <mon_help+0xf>
    }
    return 0;
c0100cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc1:	89 ec                	mov    %ebp,%esp
c0100cc3:	5d                   	pop    %ebp
c0100cc4:	c3                   	ret    

c0100cc5 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cc5:	55                   	push   %ebp
c0100cc6:	89 e5                	mov    %esp,%ebp
c0100cc8:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100ccb:	e8 b8 fb ff ff       	call   c0100888 <print_kerninfo>
    return 0;
c0100cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd5:	89 ec                	mov    %ebp,%esp
c0100cd7:	5d                   	pop    %ebp
c0100cd8:	c3                   	ret    

c0100cd9 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cd9:	55                   	push   %ebp
c0100cda:	89 e5                	mov    %esp,%ebp
c0100cdc:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cdf:	e8 f0 fc ff ff       	call   c01009d4 <print_stackframe>
    return 0;
c0100ce4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce9:	89 ec                	mov    %ebp,%esp
c0100ceb:	5d                   	pop    %ebp
c0100cec:	c3                   	ret    

c0100ced <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100ced:	55                   	push   %ebp
c0100cee:	89 e5                	mov    %esp,%ebp
c0100cf0:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cf3:	a1 20 64 12 c0       	mov    0xc0126420,%eax
c0100cf8:	85 c0                	test   %eax,%eax
c0100cfa:	75 5b                	jne    c0100d57 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100cfc:	c7 05 20 64 12 c0 01 	movl   $0x1,0xc0126420
c0100d03:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d06:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1a:	c7 04 24 96 92 10 c0 	movl   $0xc0109296,(%esp)
c0100d21:	e8 3f f6 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d2d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d30:	89 04 24             	mov    %eax,(%esp)
c0100d33:	e8 f8 f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100d38:	c7 04 24 b2 92 10 c0 	movl   $0xc01092b2,(%esp)
c0100d3f:	e8 21 f6 ff ff       	call   c0100365 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d44:	c7 04 24 b4 92 10 c0 	movl   $0xc01092b4,(%esp)
c0100d4b:	e8 15 f6 ff ff       	call   c0100365 <cprintf>
    print_stackframe();
c0100d50:	e8 7f fc ff ff       	call   c01009d4 <print_stackframe>
c0100d55:	eb 01                	jmp    c0100d58 <__panic+0x6b>
        goto panic_dead;
c0100d57:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d58:	e8 46 12 00 00       	call   c0101fa3 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d64:	e8 9d fe ff ff       	call   c0100c06 <kmonitor>
c0100d69:	eb f2                	jmp    c0100d5d <__panic+0x70>

c0100d6b <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d6b:	55                   	push   %ebp
c0100d6c:	89 e5                	mov    %esp,%ebp
c0100d6e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d71:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d7a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d85:	c7 04 24 c6 92 10 c0 	movl   $0xc01092c6,(%esp)
c0100d8c:	e8 d4 f5 ff ff       	call   c0100365 <cprintf>
    vcprintf(fmt, ap);
c0100d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d98:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d9b:	89 04 24             	mov    %eax,(%esp)
c0100d9e:	e8 8d f5 ff ff       	call   c0100330 <vcprintf>
    cprintf("\n");
c0100da3:	c7 04 24 b2 92 10 c0 	movl   $0xc01092b2,(%esp)
c0100daa:	e8 b6 f5 ff ff       	call   c0100365 <cprintf>
    va_end(ap);
}
c0100daf:	90                   	nop
c0100db0:	89 ec                	mov    %ebp,%esp
c0100db2:	5d                   	pop    %ebp
c0100db3:	c3                   	ret    

c0100db4 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100db4:	55                   	push   %ebp
c0100db5:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100db7:	a1 20 64 12 c0       	mov    0xc0126420,%eax
}
c0100dbc:	5d                   	pop    %ebp
c0100dbd:	c3                   	ret    

c0100dbe <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dbe:	55                   	push   %ebp
c0100dbf:	89 e5                	mov    %esp,%ebp
c0100dc1:	83 ec 28             	sub    $0x28,%esp
c0100dc4:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100dca:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dce:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dd6:	ee                   	out    %al,(%dx)
}
c0100dd7:	90                   	nop
c0100dd8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dde:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100de2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100de6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dea:	ee                   	out    %al,(%dx)
}
c0100deb:	90                   	nop
c0100dec:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100df2:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100df6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dfa:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dfe:	ee                   	out    %al,(%dx)
}
c0100dff:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e00:	c7 05 24 64 12 c0 00 	movl   $0x0,0xc0126424
c0100e07:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e0a:	c7 04 24 e4 92 10 c0 	movl   $0xc01092e4,(%esp)
c0100e11:	e8 4f f5 ff ff       	call   c0100365 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e1d:	e8 e6 11 00 00       	call   c0102008 <pic_enable>
}
c0100e22:	90                   	nop
c0100e23:	89 ec                	mov    %ebp,%esp
c0100e25:	5d                   	pop    %ebp
c0100e26:	c3                   	ret    

c0100e27 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e27:	55                   	push   %ebp
c0100e28:	89 e5                	mov    %esp,%ebp
c0100e2a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e2d:	9c                   	pushf  
c0100e2e:	58                   	pop    %eax
c0100e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e35:	25 00 02 00 00       	and    $0x200,%eax
c0100e3a:	85 c0                	test   %eax,%eax
c0100e3c:	74 0c                	je     c0100e4a <__intr_save+0x23>
        intr_disable();
c0100e3e:	e8 60 11 00 00       	call   c0101fa3 <intr_disable>
        return 1;
c0100e43:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e48:	eb 05                	jmp    c0100e4f <__intr_save+0x28>
    }
    return 0;
c0100e4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e4f:	89 ec                	mov    %ebp,%esp
c0100e51:	5d                   	pop    %ebp
c0100e52:	c3                   	ret    

c0100e53 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e53:	55                   	push   %ebp
c0100e54:	89 e5                	mov    %esp,%ebp
c0100e56:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e59:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e5d:	74 05                	je     c0100e64 <__intr_restore+0x11>
        intr_enable();
c0100e5f:	e8 37 11 00 00       	call   c0101f9b <intr_enable>
    }
}
c0100e64:	90                   	nop
c0100e65:	89 ec                	mov    %ebp,%esp
c0100e67:	5d                   	pop    %ebp
c0100e68:	c3                   	ret    

c0100e69 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e69:	55                   	push   %ebp
c0100e6a:	89 e5                	mov    %esp,%ebp
c0100e6c:	83 ec 10             	sub    $0x10,%esp
c0100e6f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e75:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e79:	89 c2                	mov    %eax,%edx
c0100e7b:	ec                   	in     (%dx),%al
c0100e7c:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e7f:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e85:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e89:	89 c2                	mov    %eax,%edx
c0100e8b:	ec                   	in     (%dx),%al
c0100e8c:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e8f:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e95:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e99:	89 c2                	mov    %eax,%edx
c0100e9b:	ec                   	in     (%dx),%al
c0100e9c:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e9f:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ea5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ea9:	89 c2                	mov    %eax,%edx
c0100eab:	ec                   	in     (%dx),%al
c0100eac:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100eaf:	90                   	nop
c0100eb0:	89 ec                	mov    %ebp,%esp
c0100eb2:	5d                   	pop    %ebp
c0100eb3:	c3                   	ret    

c0100eb4 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100eb4:	55                   	push   %ebp
c0100eb5:	89 e5                	mov    %esp,%ebp
c0100eb7:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100eba:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec4:	0f b7 00             	movzwl (%eax),%eax
c0100ec7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ecb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ece:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed6:	0f b7 00             	movzwl (%eax),%eax
c0100ed9:	0f b7 c0             	movzwl %ax,%eax
c0100edc:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ee1:	74 12                	je     c0100ef5 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ee3:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eea:	66 c7 05 46 64 12 c0 	movw   $0x3b4,0xc0126446
c0100ef1:	b4 03 
c0100ef3:	eb 13                	jmp    c0100f08 <cga_init+0x54>
    } else {
        *cp = was;
c0100ef5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100efc:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100eff:	66 c7 05 46 64 12 c0 	movw   $0x3d4,0xc0126446
c0100f06:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f08:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f0f:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f13:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f17:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f1b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f1f:	ee                   	out    %al,(%dx)
}
c0100f20:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f21:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f28:	40                   	inc    %eax
c0100f29:	0f b7 c0             	movzwl %ax,%eax
c0100f2c:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f30:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f34:	89 c2                	mov    %eax,%edx
c0100f36:	ec                   	in     (%dx),%al
c0100f37:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f3a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f3e:	0f b6 c0             	movzbl %al,%eax
c0100f41:	c1 e0 08             	shl    $0x8,%eax
c0100f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f47:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f4e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f52:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f56:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f5a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f5e:	ee                   	out    %al,(%dx)
}
c0100f5f:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f60:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c0100f67:	40                   	inc    %eax
c0100f68:	0f b7 c0             	movzwl %ax,%eax
c0100f6b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f6f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f73:	89 c2                	mov    %eax,%edx
c0100f75:	ec                   	in     (%dx),%al
c0100f76:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f79:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f7d:	0f b6 c0             	movzbl %al,%eax
c0100f80:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f86:	a3 40 64 12 c0       	mov    %eax,0xc0126440
    crt_pos = pos;
c0100f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f8e:	0f b7 c0             	movzwl %ax,%eax
c0100f91:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
}
c0100f97:	90                   	nop
c0100f98:	89 ec                	mov    %ebp,%esp
c0100f9a:	5d                   	pop    %ebp
c0100f9b:	c3                   	ret    

c0100f9c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f9c:	55                   	push   %ebp
c0100f9d:	89 e5                	mov    %esp,%ebp
c0100f9f:	83 ec 48             	sub    $0x48,%esp
c0100fa2:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fa8:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fac:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fb0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fb4:	ee                   	out    %al,(%dx)
}
c0100fb5:	90                   	nop
c0100fb6:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fbc:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fc0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fc4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fc8:	ee                   	out    %al,(%dx)
}
c0100fc9:	90                   	nop
c0100fca:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fd0:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fd4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fd8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fdc:	ee                   	out    %al,(%dx)
}
c0100fdd:	90                   	nop
c0100fde:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fe4:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fec:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff0:	ee                   	out    %al,(%dx)
}
c0100ff1:	90                   	nop
c0100ff2:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100ff8:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ffc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101000:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101004:	ee                   	out    %al,(%dx)
}
c0101005:	90                   	nop
c0101006:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c010100c:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101010:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101014:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101018:	ee                   	out    %al,(%dx)
}
c0101019:	90                   	nop
c010101a:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101020:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101024:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101028:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010102c:	ee                   	out    %al,(%dx)
}
c010102d:	90                   	nop
c010102e:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101034:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101038:	89 c2                	mov    %eax,%edx
c010103a:	ec                   	in     (%dx),%al
c010103b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010103e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101042:	3c ff                	cmp    $0xff,%al
c0101044:	0f 95 c0             	setne  %al
c0101047:	0f b6 c0             	movzbl %al,%eax
c010104a:	a3 48 64 12 c0       	mov    %eax,0xc0126448
c010104f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101055:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101059:	89 c2                	mov    %eax,%edx
c010105b:	ec                   	in     (%dx),%al
c010105c:	88 45 f1             	mov    %al,-0xf(%ebp)
c010105f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101065:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101069:	89 c2                	mov    %eax,%edx
c010106b:	ec                   	in     (%dx),%al
c010106c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010106f:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c0101074:	85 c0                	test   %eax,%eax
c0101076:	74 0c                	je     c0101084 <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101078:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010107f:	e8 84 0f 00 00       	call   c0102008 <pic_enable>
    }
}
c0101084:	90                   	nop
c0101085:	89 ec                	mov    %ebp,%esp
c0101087:	5d                   	pop    %ebp
c0101088:	c3                   	ret    

c0101089 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101089:	55                   	push   %ebp
c010108a:	89 e5                	mov    %esp,%ebp
c010108c:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010108f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101096:	eb 08                	jmp    c01010a0 <lpt_putc_sub+0x17>
        delay();
c0101098:	e8 cc fd ff ff       	call   c0100e69 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010109d:	ff 45 fc             	incl   -0x4(%ebp)
c01010a0:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010a6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010aa:	89 c2                	mov    %eax,%edx
c01010ac:	ec                   	in     (%dx),%al
c01010ad:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010b0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010b4:	84 c0                	test   %al,%al
c01010b6:	78 09                	js     c01010c1 <lpt_putc_sub+0x38>
c01010b8:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010bf:	7e d7                	jle    c0101098 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c4:	0f b6 c0             	movzbl %al,%eax
c01010c7:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010cd:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010d0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010d4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d8:	ee                   	out    %al,(%dx)
}
c01010d9:	90                   	nop
c01010da:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010e0:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010e4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010e8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010ec:	ee                   	out    %al,(%dx)
}
c01010ed:	90                   	nop
c01010ee:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010f4:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010f8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010fc:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101100:	ee                   	out    %al,(%dx)
}
c0101101:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101102:	90                   	nop
c0101103:	89 ec                	mov    %ebp,%esp
c0101105:	5d                   	pop    %ebp
c0101106:	c3                   	ret    

c0101107 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101107:	55                   	push   %ebp
c0101108:	89 e5                	mov    %esp,%ebp
c010110a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010110d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101111:	74 0d                	je     c0101120 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101113:	8b 45 08             	mov    0x8(%ebp),%eax
c0101116:	89 04 24             	mov    %eax,(%esp)
c0101119:	e8 6b ff ff ff       	call   c0101089 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010111e:	eb 24                	jmp    c0101144 <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101120:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101127:	e8 5d ff ff ff       	call   c0101089 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010112c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101133:	e8 51 ff ff ff       	call   c0101089 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101138:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010113f:	e8 45 ff ff ff       	call   c0101089 <lpt_putc_sub>
}
c0101144:	90                   	nop
c0101145:	89 ec                	mov    %ebp,%esp
c0101147:	5d                   	pop    %ebp
c0101148:	c3                   	ret    

c0101149 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101149:	55                   	push   %ebp
c010114a:	89 e5                	mov    %esp,%ebp
c010114c:	83 ec 38             	sub    $0x38,%esp
c010114f:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c0101152:	8b 45 08             	mov    0x8(%ebp),%eax
c0101155:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010115a:	85 c0                	test   %eax,%eax
c010115c:	75 07                	jne    c0101165 <cga_putc+0x1c>
        c |= 0x0700;
c010115e:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101165:	8b 45 08             	mov    0x8(%ebp),%eax
c0101168:	0f b6 c0             	movzbl %al,%eax
c010116b:	83 f8 0d             	cmp    $0xd,%eax
c010116e:	74 72                	je     c01011e2 <cga_putc+0x99>
c0101170:	83 f8 0d             	cmp    $0xd,%eax
c0101173:	0f 8f a3 00 00 00    	jg     c010121c <cga_putc+0xd3>
c0101179:	83 f8 08             	cmp    $0x8,%eax
c010117c:	74 0a                	je     c0101188 <cga_putc+0x3f>
c010117e:	83 f8 0a             	cmp    $0xa,%eax
c0101181:	74 4c                	je     c01011cf <cga_putc+0x86>
c0101183:	e9 94 00 00 00       	jmp    c010121c <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c0101188:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010118f:	85 c0                	test   %eax,%eax
c0101191:	0f 84 af 00 00 00    	je     c0101246 <cga_putc+0xfd>
            crt_pos --;
c0101197:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010119e:	48                   	dec    %eax
c010119f:	0f b7 c0             	movzwl %ax,%eax
c01011a2:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ab:	98                   	cwtl   
c01011ac:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011b1:	98                   	cwtl   
c01011b2:	83 c8 20             	or     $0x20,%eax
c01011b5:	98                   	cwtl   
c01011b6:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c01011bc:	0f b7 15 44 64 12 c0 	movzwl 0xc0126444,%edx
c01011c3:	01 d2                	add    %edx,%edx
c01011c5:	01 ca                	add    %ecx,%edx
c01011c7:	0f b7 c0             	movzwl %ax,%eax
c01011ca:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011cd:	eb 77                	jmp    c0101246 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011cf:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01011d6:	83 c0 50             	add    $0x50,%eax
c01011d9:	0f b7 c0             	movzwl %ax,%eax
c01011dc:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011e2:	0f b7 1d 44 64 12 c0 	movzwl 0xc0126444,%ebx
c01011e9:	0f b7 0d 44 64 12 c0 	movzwl 0xc0126444,%ecx
c01011f0:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011f5:	89 c8                	mov    %ecx,%eax
c01011f7:	f7 e2                	mul    %edx
c01011f9:	c1 ea 06             	shr    $0x6,%edx
c01011fc:	89 d0                	mov    %edx,%eax
c01011fe:	c1 e0 02             	shl    $0x2,%eax
c0101201:	01 d0                	add    %edx,%eax
c0101203:	c1 e0 04             	shl    $0x4,%eax
c0101206:	29 c1                	sub    %eax,%ecx
c0101208:	89 ca                	mov    %ecx,%edx
c010120a:	0f b7 d2             	movzwl %dx,%edx
c010120d:	89 d8                	mov    %ebx,%eax
c010120f:	29 d0                	sub    %edx,%eax
c0101211:	0f b7 c0             	movzwl %ax,%eax
c0101214:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
        break;
c010121a:	eb 2b                	jmp    c0101247 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010121c:	8b 0d 40 64 12 c0    	mov    0xc0126440,%ecx
c0101222:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101229:	8d 50 01             	lea    0x1(%eax),%edx
c010122c:	0f b7 d2             	movzwl %dx,%edx
c010122f:	66 89 15 44 64 12 c0 	mov    %dx,0xc0126444
c0101236:	01 c0                	add    %eax,%eax
c0101238:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010123b:	8b 45 08             	mov    0x8(%ebp),%eax
c010123e:	0f b7 c0             	movzwl %ax,%eax
c0101241:	66 89 02             	mov    %ax,(%edx)
        break;
c0101244:	eb 01                	jmp    c0101247 <cga_putc+0xfe>
        break;
c0101246:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101247:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c010124e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101253:	76 5e                	jbe    c01012b3 <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101255:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c010125a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101260:	a1 40 64 12 c0       	mov    0xc0126440,%eax
c0101265:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010126c:	00 
c010126d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101271:	89 04 24             	mov    %eax,(%esp)
c0101274:	e8 eb 7b 00 00       	call   c0108e64 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101279:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101280:	eb 15                	jmp    c0101297 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c0101282:	8b 15 40 64 12 c0    	mov    0xc0126440,%edx
c0101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010128b:	01 c0                	add    %eax,%eax
c010128d:	01 d0                	add    %edx,%eax
c010128f:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101294:	ff 45 f4             	incl   -0xc(%ebp)
c0101297:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010129e:	7e e2                	jle    c0101282 <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012a0:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01012a7:	83 e8 50             	sub    $0x50,%eax
c01012aa:	0f b7 c0             	movzwl %ax,%eax
c01012ad:	66 a3 44 64 12 c0    	mov    %ax,0xc0126444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012b3:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c01012ba:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012be:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012c2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012c6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ca:	ee                   	out    %al,(%dx)
}
c01012cb:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012cc:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c01012d3:	c1 e8 08             	shr    $0x8,%eax
c01012d6:	0f b7 c0             	movzwl %ax,%eax
c01012d9:	0f b6 c0             	movzbl %al,%eax
c01012dc:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c01012e3:	42                   	inc    %edx
c01012e4:	0f b7 d2             	movzwl %dx,%edx
c01012e7:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012eb:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012ee:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012f2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012f6:	ee                   	out    %al,(%dx)
}
c01012f7:	90                   	nop
    outb(addr_6845, 15);
c01012f8:	0f b7 05 46 64 12 c0 	movzwl 0xc0126446,%eax
c01012ff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101303:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101307:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010130b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010130f:	ee                   	out    %al,(%dx)
}
c0101310:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101311:	0f b7 05 44 64 12 c0 	movzwl 0xc0126444,%eax
c0101318:	0f b6 c0             	movzbl %al,%eax
c010131b:	0f b7 15 46 64 12 c0 	movzwl 0xc0126446,%edx
c0101322:	42                   	inc    %edx
c0101323:	0f b7 d2             	movzwl %dx,%edx
c0101326:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c010132a:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101331:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101335:	ee                   	out    %al,(%dx)
}
c0101336:	90                   	nop
}
c0101337:	90                   	nop
c0101338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010133b:	89 ec                	mov    %ebp,%esp
c010133d:	5d                   	pop    %ebp
c010133e:	c3                   	ret    

c010133f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010133f:	55                   	push   %ebp
c0101340:	89 e5                	mov    %esp,%ebp
c0101342:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101345:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010134c:	eb 08                	jmp    c0101356 <serial_putc_sub+0x17>
        delay();
c010134e:	e8 16 fb ff ff       	call   c0100e69 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101353:	ff 45 fc             	incl   -0x4(%ebp)
c0101356:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010135c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101360:	89 c2                	mov    %eax,%edx
c0101362:	ec                   	in     (%dx),%al
c0101363:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101366:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010136a:	0f b6 c0             	movzbl %al,%eax
c010136d:	83 e0 20             	and    $0x20,%eax
c0101370:	85 c0                	test   %eax,%eax
c0101372:	75 09                	jne    c010137d <serial_putc_sub+0x3e>
c0101374:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010137b:	7e d1                	jle    c010134e <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c010137d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101380:	0f b6 c0             	movzbl %al,%eax
c0101383:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101389:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010138c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101390:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101394:	ee                   	out    %al,(%dx)
}
c0101395:	90                   	nop
}
c0101396:	90                   	nop
c0101397:	89 ec                	mov    %ebp,%esp
c0101399:	5d                   	pop    %ebp
c010139a:	c3                   	ret    

c010139b <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010139b:	55                   	push   %ebp
c010139c:	89 e5                	mov    %esp,%ebp
c010139e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013a1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013a5:	74 0d                	je     c01013b4 <serial_putc+0x19>
        serial_putc_sub(c);
c01013a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01013aa:	89 04 24             	mov    %eax,(%esp)
c01013ad:	e8 8d ff ff ff       	call   c010133f <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013b2:	eb 24                	jmp    c01013d8 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013b4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013bb:	e8 7f ff ff ff       	call   c010133f <serial_putc_sub>
        serial_putc_sub(' ');
c01013c0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013c7:	e8 73 ff ff ff       	call   c010133f <serial_putc_sub>
        serial_putc_sub('\b');
c01013cc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013d3:	e8 67 ff ff ff       	call   c010133f <serial_putc_sub>
}
c01013d8:	90                   	nop
c01013d9:	89 ec                	mov    %ebp,%esp
c01013db:	5d                   	pop    %ebp
c01013dc:	c3                   	ret    

c01013dd <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013dd:	55                   	push   %ebp
c01013de:	89 e5                	mov    %esp,%ebp
c01013e0:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013e3:	eb 33                	jmp    c0101418 <cons_intr+0x3b>
        if (c != 0) {
c01013e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013e9:	74 2d                	je     c0101418 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013eb:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c01013f0:	8d 50 01             	lea    0x1(%eax),%edx
c01013f3:	89 15 64 66 12 c0    	mov    %edx,0xc0126664
c01013f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013fc:	88 90 60 64 12 c0    	mov    %dl,-0x3fed9ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101402:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c0101407:	3d 00 02 00 00       	cmp    $0x200,%eax
c010140c:	75 0a                	jne    c0101418 <cons_intr+0x3b>
                cons.wpos = 0;
c010140e:	c7 05 64 66 12 c0 00 	movl   $0x0,0xc0126664
c0101415:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101418:	8b 45 08             	mov    0x8(%ebp),%eax
c010141b:	ff d0                	call   *%eax
c010141d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101420:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101424:	75 bf                	jne    c01013e5 <cons_intr+0x8>
            }
        }
    }
}
c0101426:	90                   	nop
c0101427:	90                   	nop
c0101428:	89 ec                	mov    %ebp,%esp
c010142a:	5d                   	pop    %ebp
c010142b:	c3                   	ret    

c010142c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010142c:	55                   	push   %ebp
c010142d:	89 e5                	mov    %esp,%ebp
c010142f:	83 ec 10             	sub    $0x10,%esp
c0101432:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101438:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010143c:	89 c2                	mov    %eax,%edx
c010143e:	ec                   	in     (%dx),%al
c010143f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101442:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101446:	0f b6 c0             	movzbl %al,%eax
c0101449:	83 e0 01             	and    $0x1,%eax
c010144c:	85 c0                	test   %eax,%eax
c010144e:	75 07                	jne    c0101457 <serial_proc_data+0x2b>
        return -1;
c0101450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101455:	eb 2a                	jmp    c0101481 <serial_proc_data+0x55>
c0101457:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101461:	89 c2                	mov    %eax,%edx
c0101463:	ec                   	in     (%dx),%al
c0101464:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101467:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010146b:	0f b6 c0             	movzbl %al,%eax
c010146e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101471:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101475:	75 07                	jne    c010147e <serial_proc_data+0x52>
        c = '\b';
c0101477:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010147e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101481:	89 ec                	mov    %ebp,%esp
c0101483:	5d                   	pop    %ebp
c0101484:	c3                   	ret    

c0101485 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101485:	55                   	push   %ebp
c0101486:	89 e5                	mov    %esp,%ebp
c0101488:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010148b:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c0101490:	85 c0                	test   %eax,%eax
c0101492:	74 0c                	je     c01014a0 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101494:	c7 04 24 2c 14 10 c0 	movl   $0xc010142c,(%esp)
c010149b:	e8 3d ff ff ff       	call   c01013dd <cons_intr>
    }
}
c01014a0:	90                   	nop
c01014a1:	89 ec                	mov    %ebp,%esp
c01014a3:	5d                   	pop    %ebp
c01014a4:	c3                   	ret    

c01014a5 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014a5:	55                   	push   %ebp
c01014a6:	89 e5                	mov    %esp,%ebp
c01014a8:	83 ec 38             	sub    $0x38,%esp
c01014ab:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014b4:	89 c2                	mov    %eax,%edx
c01014b6:	ec                   	in     (%dx),%al
c01014b7:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014be:	0f b6 c0             	movzbl %al,%eax
c01014c1:	83 e0 01             	and    $0x1,%eax
c01014c4:	85 c0                	test   %eax,%eax
c01014c6:	75 0a                	jne    c01014d2 <kbd_proc_data+0x2d>
        return -1;
c01014c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014cd:	e9 56 01 00 00       	jmp    c0101628 <kbd_proc_data+0x183>
c01014d2:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014db:	89 c2                	mov    %eax,%edx
c01014dd:	ec                   	in     (%dx),%al
c01014de:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014e1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014e5:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014e8:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014ec:	75 17                	jne    c0101505 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014ee:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01014f3:	83 c8 40             	or     $0x40,%eax
c01014f6:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c01014fb:	b8 00 00 00 00       	mov    $0x0,%eax
c0101500:	e9 23 01 00 00       	jmp    c0101628 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101505:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101509:	84 c0                	test   %al,%al
c010150b:	79 45                	jns    c0101552 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010150d:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101512:	83 e0 40             	and    $0x40,%eax
c0101515:	85 c0                	test   %eax,%eax
c0101517:	75 08                	jne    c0101521 <kbd_proc_data+0x7c>
c0101519:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151d:	24 7f                	and    $0x7f,%al
c010151f:	eb 04                	jmp    c0101525 <kbd_proc_data+0x80>
c0101521:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101525:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101528:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152c:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c0101533:	0c 40                	or     $0x40,%al
c0101535:	0f b6 c0             	movzbl %al,%eax
c0101538:	f7 d0                	not    %eax
c010153a:	89 c2                	mov    %eax,%edx
c010153c:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101541:	21 d0                	and    %edx,%eax
c0101543:	a3 68 66 12 c0       	mov    %eax,0xc0126668
        return 0;
c0101548:	b8 00 00 00 00       	mov    $0x0,%eax
c010154d:	e9 d6 00 00 00       	jmp    c0101628 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101552:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101557:	83 e0 40             	and    $0x40,%eax
c010155a:	85 c0                	test   %eax,%eax
c010155c:	74 11                	je     c010156f <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010155e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101562:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101567:	83 e0 bf             	and    $0xffffffbf,%eax
c010156a:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    }

    shift |= shiftcode[data];
c010156f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101573:	0f b6 80 40 30 12 c0 	movzbl -0x3fedcfc0(%eax),%eax
c010157a:	0f b6 d0             	movzbl %al,%edx
c010157d:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c0101582:	09 d0                	or     %edx,%eax
c0101584:	a3 68 66 12 c0       	mov    %eax,0xc0126668
    shift ^= togglecode[data];
c0101589:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010158d:	0f b6 80 40 31 12 c0 	movzbl -0x3fedcec0(%eax),%eax
c0101594:	0f b6 d0             	movzbl %al,%edx
c0101597:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c010159c:	31 d0                	xor    %edx,%eax
c010159e:	a3 68 66 12 c0       	mov    %eax,0xc0126668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015a3:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015a8:	83 e0 03             	and    $0x3,%eax
c01015ab:	8b 14 85 40 35 12 c0 	mov    -0x3fedcac0(,%eax,4),%edx
c01015b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b6:	01 d0                	add    %edx,%eax
c01015b8:	0f b6 00             	movzbl (%eax),%eax
c01015bb:	0f b6 c0             	movzbl %al,%eax
c01015be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015c1:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015c6:	83 e0 08             	and    $0x8,%eax
c01015c9:	85 c0                	test   %eax,%eax
c01015cb:	74 22                	je     c01015ef <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015cd:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015d1:	7e 0c                	jle    c01015df <kbd_proc_data+0x13a>
c01015d3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015d7:	7f 06                	jg     c01015df <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015d9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015dd:	eb 10                	jmp    c01015ef <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015df:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015e3:	7e 0a                	jle    c01015ef <kbd_proc_data+0x14a>
c01015e5:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015e9:	7f 04                	jg     c01015ef <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015eb:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015ef:	a1 68 66 12 c0       	mov    0xc0126668,%eax
c01015f4:	f7 d0                	not    %eax
c01015f6:	83 e0 06             	and    $0x6,%eax
c01015f9:	85 c0                	test   %eax,%eax
c01015fb:	75 28                	jne    c0101625 <kbd_proc_data+0x180>
c01015fd:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101604:	75 1f                	jne    c0101625 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101606:	c7 04 24 ff 92 10 c0 	movl   $0xc01092ff,(%esp)
c010160d:	e8 53 ed ff ff       	call   c0100365 <cprintf>
c0101612:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101618:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010161c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101620:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101623:	ee                   	out    %al,(%dx)
}
c0101624:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101628:	89 ec                	mov    %ebp,%esp
c010162a:	5d                   	pop    %ebp
c010162b:	c3                   	ret    

c010162c <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010162c:	55                   	push   %ebp
c010162d:	89 e5                	mov    %esp,%ebp
c010162f:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101632:	c7 04 24 a5 14 10 c0 	movl   $0xc01014a5,(%esp)
c0101639:	e8 9f fd ff ff       	call   c01013dd <cons_intr>
}
c010163e:	90                   	nop
c010163f:	89 ec                	mov    %ebp,%esp
c0101641:	5d                   	pop    %ebp
c0101642:	c3                   	ret    

c0101643 <kbd_init>:

static void
kbd_init(void) {
c0101643:	55                   	push   %ebp
c0101644:	89 e5                	mov    %esp,%ebp
c0101646:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101649:	e8 de ff ff ff       	call   c010162c <kbd_intr>
    pic_enable(IRQ_KBD);
c010164e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101655:	e8 ae 09 00 00       	call   c0102008 <pic_enable>
}
c010165a:	90                   	nop
c010165b:	89 ec                	mov    %ebp,%esp
c010165d:	5d                   	pop    %ebp
c010165e:	c3                   	ret    

c010165f <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010165f:	55                   	push   %ebp
c0101660:	89 e5                	mov    %esp,%ebp
c0101662:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101665:	e8 4a f8 ff ff       	call   c0100eb4 <cga_init>
    serial_init();
c010166a:	e8 2d f9 ff ff       	call   c0100f9c <serial_init>
    kbd_init();
c010166f:	e8 cf ff ff ff       	call   c0101643 <kbd_init>
    if (!serial_exists) {
c0101674:	a1 48 64 12 c0       	mov    0xc0126448,%eax
c0101679:	85 c0                	test   %eax,%eax
c010167b:	75 0c                	jne    c0101689 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010167d:	c7 04 24 0b 93 10 c0 	movl   $0xc010930b,(%esp)
c0101684:	e8 dc ec ff ff       	call   c0100365 <cprintf>
    }
}
c0101689:	90                   	nop
c010168a:	89 ec                	mov    %ebp,%esp
c010168c:	5d                   	pop    %ebp
c010168d:	c3                   	ret    

c010168e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010168e:	55                   	push   %ebp
c010168f:	89 e5                	mov    %esp,%ebp
c0101691:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101694:	e8 8e f7 ff ff       	call   c0100e27 <__intr_save>
c0101699:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010169c:	8b 45 08             	mov    0x8(%ebp),%eax
c010169f:	89 04 24             	mov    %eax,(%esp)
c01016a2:	e8 60 fa ff ff       	call   c0101107 <lpt_putc>
        cga_putc(c);
c01016a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01016aa:	89 04 24             	mov    %eax,(%esp)
c01016ad:	e8 97 fa ff ff       	call   c0101149 <cga_putc>
        serial_putc(c);
c01016b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016b5:	89 04 24             	mov    %eax,(%esp)
c01016b8:	e8 de fc ff ff       	call   c010139b <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016c0:	89 04 24             	mov    %eax,(%esp)
c01016c3:	e8 8b f7 ff ff       	call   c0100e53 <__intr_restore>
}
c01016c8:	90                   	nop
c01016c9:	89 ec                	mov    %ebp,%esp
c01016cb:	5d                   	pop    %ebp
c01016cc:	c3                   	ret    

c01016cd <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016cd:	55                   	push   %ebp
c01016ce:	89 e5                	mov    %esp,%ebp
c01016d0:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016da:	e8 48 f7 ff ff       	call   c0100e27 <__intr_save>
c01016df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016e2:	e8 9e fd ff ff       	call   c0101485 <serial_intr>
        kbd_intr();
c01016e7:	e8 40 ff ff ff       	call   c010162c <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016ec:	8b 15 60 66 12 c0    	mov    0xc0126660,%edx
c01016f2:	a1 64 66 12 c0       	mov    0xc0126664,%eax
c01016f7:	39 c2                	cmp    %eax,%edx
c01016f9:	74 31                	je     c010172c <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016fb:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c0101700:	8d 50 01             	lea    0x1(%eax),%edx
c0101703:	89 15 60 66 12 c0    	mov    %edx,0xc0126660
c0101709:	0f b6 80 60 64 12 c0 	movzbl -0x3fed9ba0(%eax),%eax
c0101710:	0f b6 c0             	movzbl %al,%eax
c0101713:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101716:	a1 60 66 12 c0       	mov    0xc0126660,%eax
c010171b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101720:	75 0a                	jne    c010172c <cons_getc+0x5f>
                cons.rpos = 0;
c0101722:	c7 05 60 66 12 c0 00 	movl   $0x0,0xc0126660
c0101729:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010172f:	89 04 24             	mov    %eax,(%esp)
c0101732:	e8 1c f7 ff ff       	call   c0100e53 <__intr_restore>
    return c;
c0101737:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010173a:	89 ec                	mov    %ebp,%esp
c010173c:	5d                   	pop    %ebp
c010173d:	c3                   	ret    

c010173e <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c010173e:	55                   	push   %ebp
c010173f:	89 e5                	mov    %esp,%ebp
c0101741:	83 ec 14             	sub    $0x14,%esp
c0101744:	8b 45 08             	mov    0x8(%ebp),%eax
c0101747:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c010174b:	90                   	nop
c010174c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010174f:	83 c0 07             	add    $0x7,%eax
c0101752:	0f b7 c0             	movzwl %ax,%eax
c0101755:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101759:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010175d:	89 c2                	mov    %eax,%edx
c010175f:	ec                   	in     (%dx),%al
c0101760:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101763:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101767:	0f b6 c0             	movzbl %al,%eax
c010176a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010176d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101770:	25 80 00 00 00       	and    $0x80,%eax
c0101775:	85 c0                	test   %eax,%eax
c0101777:	75 d3                	jne    c010174c <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101779:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010177d:	74 11                	je     c0101790 <ide_wait_ready+0x52>
c010177f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101782:	83 e0 21             	and    $0x21,%eax
c0101785:	85 c0                	test   %eax,%eax
c0101787:	74 07                	je     c0101790 <ide_wait_ready+0x52>
        return -1;
c0101789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010178e:	eb 05                	jmp    c0101795 <ide_wait_ready+0x57>
    }
    return 0;
c0101790:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101795:	89 ec                	mov    %ebp,%esp
c0101797:	5d                   	pop    %ebp
c0101798:	c3                   	ret    

c0101799 <ide_init>:

void
ide_init(void) {
c0101799:	55                   	push   %ebp
c010179a:	89 e5                	mov    %esp,%ebp
c010179c:	57                   	push   %edi
c010179d:	53                   	push   %ebx
c010179e:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01017a4:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01017aa:	e9 bd 02 00 00       	jmp    c0101a6c <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01017af:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b3:	89 d0                	mov    %edx,%eax
c01017b5:	c1 e0 03             	shl    $0x3,%eax
c01017b8:	29 d0                	sub    %edx,%eax
c01017ba:	c1 e0 03             	shl    $0x3,%eax
c01017bd:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01017c2:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01017c5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017c9:	d1 e8                	shr    %eax
c01017cb:	0f b7 c0             	movzwl %ax,%eax
c01017ce:	8b 04 85 2c 93 10 c0 	mov    -0x3fef6cd4(,%eax,4),%eax
c01017d5:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01017d9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017e4:	00 
c01017e5:	89 04 24             	mov    %eax,(%esp)
c01017e8:	e8 51 ff ff ff       	call   c010173e <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01017ed:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01017f1:	c1 e0 04             	shl    $0x4,%eax
c01017f4:	24 10                	and    $0x10,%al
c01017f6:	0c e0                	or     $0xe0,%al
c01017f8:	0f b6 c0             	movzbl %al,%eax
c01017fb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017ff:	83 c2 06             	add    $0x6,%edx
c0101802:	0f b7 d2             	movzwl %dx,%edx
c0101805:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101809:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010180c:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101810:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101814:	ee                   	out    %al,(%dx)
}
c0101815:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101816:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010181a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101821:	00 
c0101822:	89 04 24             	mov    %eax,(%esp)
c0101825:	e8 14 ff ff ff       	call   c010173e <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c010182a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010182e:	83 c0 07             	add    $0x7,%eax
c0101831:	0f b7 c0             	movzwl %ax,%eax
c0101834:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101838:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010183c:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101840:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101844:	ee                   	out    %al,(%dx)
}
c0101845:	90                   	nop
        ide_wait_ready(iobase, 0);
c0101846:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010184a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101851:	00 
c0101852:	89 04 24             	mov    %eax,(%esp)
c0101855:	e8 e4 fe ff ff       	call   c010173e <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c010185a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010185e:	83 c0 07             	add    $0x7,%eax
c0101861:	0f b7 c0             	movzwl %ax,%eax
c0101864:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101868:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010186c:	89 c2                	mov    %eax,%edx
c010186e:	ec                   	in     (%dx),%al
c010186f:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c0101872:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101876:	84 c0                	test   %al,%al
c0101878:	0f 84 e4 01 00 00    	je     c0101a62 <ide_init+0x2c9>
c010187e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101882:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101889:	00 
c010188a:	89 04 24             	mov    %eax,(%esp)
c010188d:	e8 ac fe ff ff       	call   c010173e <ide_wait_ready>
c0101892:	85 c0                	test   %eax,%eax
c0101894:	0f 85 c8 01 00 00    	jne    c0101a62 <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010189a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010189e:	89 d0                	mov    %edx,%eax
c01018a0:	c1 e0 03             	shl    $0x3,%eax
c01018a3:	29 d0                	sub    %edx,%eax
c01018a5:	c1 e0 03             	shl    $0x3,%eax
c01018a8:	05 80 66 12 c0       	add    $0xc0126680,%eax
c01018ad:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01018b0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01018b7:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018bd:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01018c0:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c01018c7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01018ca:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01018cd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01018d0:	89 cb                	mov    %ecx,%ebx
c01018d2:	89 df                	mov    %ebx,%edi
c01018d4:	89 c1                	mov    %eax,%ecx
c01018d6:	fc                   	cld    
c01018d7:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01018d9:	89 c8                	mov    %ecx,%eax
c01018db:	89 fb                	mov    %edi,%ebx
c01018dd:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c01018e0:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c01018e3:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c01018e4:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01018ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018f0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01018f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01018f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01018fc:	25 00 00 00 04       	and    $0x4000000,%eax
c0101901:	85 c0                	test   %eax,%eax
c0101903:	74 0e                	je     c0101913 <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0101905:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101908:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c010190e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101911:	eb 09                	jmp    c010191c <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0101913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101916:	8b 40 78             	mov    0x78(%eax),%eax
c0101919:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c010191c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101920:	89 d0                	mov    %edx,%eax
c0101922:	c1 e0 03             	shl    $0x3,%eax
c0101925:	29 d0                	sub    %edx,%eax
c0101927:	c1 e0 03             	shl    $0x3,%eax
c010192a:	8d 90 84 66 12 c0    	lea    -0x3fed997c(%eax),%edx
c0101930:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101933:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0101935:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101939:	89 d0                	mov    %edx,%eax
c010193b:	c1 e0 03             	shl    $0x3,%eax
c010193e:	29 d0                	sub    %edx,%eax
c0101940:	c1 e0 03             	shl    $0x3,%eax
c0101943:	8d 90 88 66 12 c0    	lea    -0x3fed9978(%eax),%edx
c0101949:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010194c:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010194e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101951:	83 c0 62             	add    $0x62,%eax
c0101954:	0f b7 00             	movzwl (%eax),%eax
c0101957:	25 00 02 00 00       	and    $0x200,%eax
c010195c:	85 c0                	test   %eax,%eax
c010195e:	75 24                	jne    c0101984 <ide_init+0x1eb>
c0101960:	c7 44 24 0c 34 93 10 	movl   $0xc0109334,0xc(%esp)
c0101967:	c0 
c0101968:	c7 44 24 08 77 93 10 	movl   $0xc0109377,0x8(%esp)
c010196f:	c0 
c0101970:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101977:	00 
c0101978:	c7 04 24 8c 93 10 c0 	movl   $0xc010938c,(%esp)
c010197f:	e8 69 f3 ff ff       	call   c0100ced <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101984:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101988:	89 d0                	mov    %edx,%eax
c010198a:	c1 e0 03             	shl    $0x3,%eax
c010198d:	29 d0                	sub    %edx,%eax
c010198f:	c1 e0 03             	shl    $0x3,%eax
c0101992:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101997:	83 c0 0c             	add    $0xc,%eax
c010199a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010199d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019a0:	83 c0 36             	add    $0x36,%eax
c01019a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019a6:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019b4:	eb 34                	jmp    c01019ea <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019b9:	8d 50 01             	lea    0x1(%eax),%edx
c01019bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01019bf:	01 c2                	add    %eax,%edx
c01019c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01019c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019c7:	01 c8                	add    %ecx,%eax
c01019c9:	0f b6 12             	movzbl (%edx),%edx
c01019cc:	88 10                	mov    %dl,(%eax)
c01019ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01019d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019d4:	01 c2                	add    %eax,%edx
c01019d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019d9:	8d 48 01             	lea    0x1(%eax),%ecx
c01019dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01019df:	01 c8                	add    %ecx,%eax
c01019e1:	0f b6 12             	movzbl (%edx),%edx
c01019e4:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c01019e6:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c01019ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019ed:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c01019f0:	72 c4                	jb     c01019b6 <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c01019f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019f8:	01 d0                	add    %edx,%eax
c01019fa:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01019fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a00:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a03:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a06:	85 c0                	test   %eax,%eax
c0101a08:	74 0f                	je     c0101a19 <ide_init+0x280>
c0101a0a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a10:	01 d0                	add    %edx,%eax
c0101a12:	0f b6 00             	movzbl (%eax),%eax
c0101a15:	3c 20                	cmp    $0x20,%al
c0101a17:	74 d9                	je     c01019f2 <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a19:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a1d:	89 d0                	mov    %edx,%eax
c0101a1f:	c1 e0 03             	shl    $0x3,%eax
c0101a22:	29 d0                	sub    %edx,%eax
c0101a24:	c1 e0 03             	shl    $0x3,%eax
c0101a27:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101a2c:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a2f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a33:	89 d0                	mov    %edx,%eax
c0101a35:	c1 e0 03             	shl    $0x3,%eax
c0101a38:	29 d0                	sub    %edx,%eax
c0101a3a:	c1 e0 03             	shl    $0x3,%eax
c0101a3d:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101a42:	8b 10                	mov    (%eax),%edx
c0101a44:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a48:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a4c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a54:	c7 04 24 9e 93 10 c0 	movl   $0xc010939e,(%esp)
c0101a5b:	e8 05 e9 ff ff       	call   c0100365 <cprintf>
c0101a60:	eb 01                	jmp    c0101a63 <ide_init+0x2ca>
            continue ;
c0101a62:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a63:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a67:	40                   	inc    %eax
c0101a68:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a6c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a70:	83 f8 03             	cmp    $0x3,%eax
c0101a73:	0f 86 36 fd ff ff    	jbe    c01017af <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101a79:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101a80:	e8 83 05 00 00       	call   c0102008 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101a85:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101a8c:	e8 77 05 00 00       	call   c0102008 <pic_enable>
}
c0101a91:	90                   	nop
c0101a92:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101a98:	5b                   	pop    %ebx
c0101a99:	5f                   	pop    %edi
c0101a9a:	5d                   	pop    %ebp
c0101a9b:	c3                   	ret    

c0101a9c <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101a9c:	55                   	push   %ebp
c0101a9d:	89 e5                	mov    %esp,%ebp
c0101a9f:	83 ec 04             	sub    $0x4,%esp
c0101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101aa9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aad:	83 f8 03             	cmp    $0x3,%eax
c0101ab0:	77 21                	ja     c0101ad3 <ide_device_valid+0x37>
c0101ab2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101ab6:	89 d0                	mov    %edx,%eax
c0101ab8:	c1 e0 03             	shl    $0x3,%eax
c0101abb:	29 d0                	sub    %edx,%eax
c0101abd:	c1 e0 03             	shl    $0x3,%eax
c0101ac0:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101ac5:	0f b6 00             	movzbl (%eax),%eax
c0101ac8:	84 c0                	test   %al,%al
c0101aca:	74 07                	je     c0101ad3 <ide_device_valid+0x37>
c0101acc:	b8 01 00 00 00       	mov    $0x1,%eax
c0101ad1:	eb 05                	jmp    c0101ad8 <ide_device_valid+0x3c>
c0101ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ad8:	89 ec                	mov    %ebp,%esp
c0101ada:	5d                   	pop    %ebp
c0101adb:	c3                   	ret    

c0101adc <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101adc:	55                   	push   %ebp
c0101add:	89 e5                	mov    %esp,%ebp
c0101adf:	83 ec 08             	sub    $0x8,%esp
c0101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101ae9:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aed:	89 04 24             	mov    %eax,(%esp)
c0101af0:	e8 a7 ff ff ff       	call   c0101a9c <ide_device_valid>
c0101af5:	85 c0                	test   %eax,%eax
c0101af7:	74 17                	je     c0101b10 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101af9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101afd:	89 d0                	mov    %edx,%eax
c0101aff:	c1 e0 03             	shl    $0x3,%eax
c0101b02:	29 d0                	sub    %edx,%eax
c0101b04:	c1 e0 03             	shl    $0x3,%eax
c0101b07:	05 88 66 12 c0       	add    $0xc0126688,%eax
c0101b0c:	8b 00                	mov    (%eax),%eax
c0101b0e:	eb 05                	jmp    c0101b15 <ide_device_size+0x39>
    }
    return 0;
c0101b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b15:	89 ec                	mov    %ebp,%esp
c0101b17:	5d                   	pop    %ebp
c0101b18:	c3                   	ret    

c0101b19 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b19:	55                   	push   %ebp
c0101b1a:	89 e5                	mov    %esp,%ebp
c0101b1c:	57                   	push   %edi
c0101b1d:	53                   	push   %ebx
c0101b1e:	83 ec 50             	sub    $0x50,%esp
c0101b21:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b24:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b28:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b2f:	77 23                	ja     c0101b54 <ide_read_secs+0x3b>
c0101b31:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b35:	83 f8 03             	cmp    $0x3,%eax
c0101b38:	77 1a                	ja     c0101b54 <ide_read_secs+0x3b>
c0101b3a:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101b3e:	89 d0                	mov    %edx,%eax
c0101b40:	c1 e0 03             	shl    $0x3,%eax
c0101b43:	29 d0                	sub    %edx,%eax
c0101b45:	c1 e0 03             	shl    $0x3,%eax
c0101b48:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101b4d:	0f b6 00             	movzbl (%eax),%eax
c0101b50:	84 c0                	test   %al,%al
c0101b52:	75 24                	jne    c0101b78 <ide_read_secs+0x5f>
c0101b54:	c7 44 24 0c bc 93 10 	movl   $0xc01093bc,0xc(%esp)
c0101b5b:	c0 
c0101b5c:	c7 44 24 08 77 93 10 	movl   $0xc0109377,0x8(%esp)
c0101b63:	c0 
c0101b64:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b6b:	00 
c0101b6c:	c7 04 24 8c 93 10 c0 	movl   $0xc010938c,(%esp)
c0101b73:	e8 75 f1 ff ff       	call   c0100ced <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b78:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101b7f:	77 0f                	ja     c0101b90 <ide_read_secs+0x77>
c0101b81:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101b84:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b87:	01 d0                	add    %edx,%eax
c0101b89:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101b8e:	76 24                	jbe    c0101bb4 <ide_read_secs+0x9b>
c0101b90:	c7 44 24 0c e4 93 10 	movl   $0xc01093e4,0xc(%esp)
c0101b97:	c0 
c0101b98:	c7 44 24 08 77 93 10 	movl   $0xc0109377,0x8(%esp)
c0101b9f:	c0 
c0101ba0:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101ba7:	00 
c0101ba8:	c7 04 24 8c 93 10 c0 	movl   $0xc010938c,(%esp)
c0101baf:	e8 39 f1 ff ff       	call   c0100ced <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bb4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bb8:	d1 e8                	shr    %eax
c0101bba:	0f b7 c0             	movzwl %ax,%eax
c0101bbd:	8b 04 85 2c 93 10 c0 	mov    -0x3fef6cd4(,%eax,4),%eax
c0101bc4:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bc8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bcc:	d1 e8                	shr    %eax
c0101bce:	0f b7 c0             	movzwl %ax,%eax
c0101bd1:	0f b7 04 85 2e 93 10 	movzwl -0x3fef6cd2(,%eax,4),%eax
c0101bd8:	c0 
c0101bd9:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101bdd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101be1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101be8:	00 
c0101be9:	89 04 24             	mov    %eax,(%esp)
c0101bec:	e8 4d fb ff ff       	call   c010173e <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101bf4:	83 c0 02             	add    $0x2,%eax
c0101bf7:	0f b7 c0             	movzwl %ax,%eax
c0101bfa:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101bfe:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c02:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c06:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c0a:	ee                   	out    %al,(%dx)
}
c0101c0b:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c0c:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c0f:	0f b6 c0             	movzbl %al,%eax
c0101c12:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c16:	83 c2 02             	add    $0x2,%edx
c0101c19:	0f b7 d2             	movzwl %dx,%edx
c0101c1c:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c20:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c23:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c27:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c2b:	ee                   	out    %al,(%dx)
}
c0101c2c:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c30:	0f b6 c0             	movzbl %al,%eax
c0101c33:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c37:	83 c2 03             	add    $0x3,%edx
c0101c3a:	0f b7 d2             	movzwl %dx,%edx
c0101c3d:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c41:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c44:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c48:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c4c:	ee                   	out    %al,(%dx)
}
c0101c4d:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c51:	c1 e8 08             	shr    $0x8,%eax
c0101c54:	0f b6 c0             	movzbl %al,%eax
c0101c57:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c5b:	83 c2 04             	add    $0x4,%edx
c0101c5e:	0f b7 d2             	movzwl %dx,%edx
c0101c61:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c65:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c68:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c6c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c70:	ee                   	out    %al,(%dx)
}
c0101c71:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c72:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c75:	c1 e8 10             	shr    $0x10,%eax
c0101c78:	0f b6 c0             	movzbl %al,%eax
c0101c7b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c7f:	83 c2 05             	add    $0x5,%edx
c0101c82:	0f b7 d2             	movzwl %dx,%edx
c0101c85:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101c89:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c8c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101c90:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101c94:	ee                   	out    %al,(%dx)
}
c0101c95:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101c96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101c99:	c0 e0 04             	shl    $0x4,%al
c0101c9c:	24 10                	and    $0x10,%al
c0101c9e:	88 c2                	mov    %al,%dl
c0101ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ca3:	c1 e8 18             	shr    $0x18,%eax
c0101ca6:	24 0f                	and    $0xf,%al
c0101ca8:	08 d0                	or     %dl,%al
c0101caa:	0c e0                	or     $0xe0,%al
c0101cac:	0f b6 c0             	movzbl %al,%eax
c0101caf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cb3:	83 c2 06             	add    $0x6,%edx
c0101cb6:	0f b7 d2             	movzwl %dx,%edx
c0101cb9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cbd:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cc0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cc4:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cc8:	ee                   	out    %al,(%dx)
}
c0101cc9:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101cca:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cce:	83 c0 07             	add    $0x7,%eax
c0101cd1:	0f b7 c0             	movzwl %ax,%eax
c0101cd4:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101cd8:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cdc:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101ce0:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101ce4:	ee                   	out    %al,(%dx)
}
c0101ce5:	90                   	nop

    int ret = 0;
c0101ce6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101ced:	eb 58                	jmp    c0101d47 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101cef:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cf3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101cfa:	00 
c0101cfb:	89 04 24             	mov    %eax,(%esp)
c0101cfe:	e8 3b fa ff ff       	call   c010173e <ide_wait_ready>
c0101d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d0a:	75 43                	jne    c0101d4f <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d0c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d10:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d13:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d16:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d19:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d20:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d23:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d26:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d29:	89 cb                	mov    %ecx,%ebx
c0101d2b:	89 df                	mov    %ebx,%edi
c0101d2d:	89 c1                	mov    %eax,%ecx
c0101d2f:	fc                   	cld    
c0101d30:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d32:	89 c8                	mov    %ecx,%eax
c0101d34:	89 fb                	mov    %edi,%ebx
c0101d36:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d39:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d3c:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d3d:	ff 4d 14             	decl   0x14(%ebp)
c0101d40:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d47:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d4b:	75 a2                	jne    c0101cef <ide_read_secs+0x1d6>
    }

out:
c0101d4d:	eb 01                	jmp    c0101d50 <ide_read_secs+0x237>
            goto out;
c0101d4f:	90                   	nop
    return ret;
c0101d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d53:	83 c4 50             	add    $0x50,%esp
c0101d56:	5b                   	pop    %ebx
c0101d57:	5f                   	pop    %edi
c0101d58:	5d                   	pop    %ebp
c0101d59:	c3                   	ret    

c0101d5a <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d5a:	55                   	push   %ebp
c0101d5b:	89 e5                	mov    %esp,%ebp
c0101d5d:	56                   	push   %esi
c0101d5e:	53                   	push   %ebx
c0101d5f:	83 ec 50             	sub    $0x50,%esp
c0101d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d65:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d69:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d70:	77 23                	ja     c0101d95 <ide_write_secs+0x3b>
c0101d72:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d76:	83 f8 03             	cmp    $0x3,%eax
c0101d79:	77 1a                	ja     c0101d95 <ide_write_secs+0x3b>
c0101d7b:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101d7f:	89 d0                	mov    %edx,%eax
c0101d81:	c1 e0 03             	shl    $0x3,%eax
c0101d84:	29 d0                	sub    %edx,%eax
c0101d86:	c1 e0 03             	shl    $0x3,%eax
c0101d89:	05 80 66 12 c0       	add    $0xc0126680,%eax
c0101d8e:	0f b6 00             	movzbl (%eax),%eax
c0101d91:	84 c0                	test   %al,%al
c0101d93:	75 24                	jne    c0101db9 <ide_write_secs+0x5f>
c0101d95:	c7 44 24 0c bc 93 10 	movl   $0xc01093bc,0xc(%esp)
c0101d9c:	c0 
c0101d9d:	c7 44 24 08 77 93 10 	movl   $0xc0109377,0x8(%esp)
c0101da4:	c0 
c0101da5:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101dac:	00 
c0101dad:	c7 04 24 8c 93 10 c0 	movl   $0xc010938c,(%esp)
c0101db4:	e8 34 ef ff ff       	call   c0100ced <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101db9:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101dc0:	77 0f                	ja     c0101dd1 <ide_write_secs+0x77>
c0101dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101dc5:	8b 45 14             	mov    0x14(%ebp),%eax
c0101dc8:	01 d0                	add    %edx,%eax
c0101dca:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101dcf:	76 24                	jbe    c0101df5 <ide_write_secs+0x9b>
c0101dd1:	c7 44 24 0c e4 93 10 	movl   $0xc01093e4,0xc(%esp)
c0101dd8:	c0 
c0101dd9:	c7 44 24 08 77 93 10 	movl   $0xc0109377,0x8(%esp)
c0101de0:	c0 
c0101de1:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101de8:	00 
c0101de9:	c7 04 24 8c 93 10 c0 	movl   $0xc010938c,(%esp)
c0101df0:	e8 f8 ee ff ff       	call   c0100ced <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101df5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101df9:	d1 e8                	shr    %eax
c0101dfb:	0f b7 c0             	movzwl %ax,%eax
c0101dfe:	8b 04 85 2c 93 10 c0 	mov    -0x3fef6cd4(,%eax,4),%eax
c0101e05:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e09:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e0d:	d1 e8                	shr    %eax
c0101e0f:	0f b7 c0             	movzwl %ax,%eax
c0101e12:	0f b7 04 85 2e 93 10 	movzwl -0x3fef6cd2(,%eax,4),%eax
c0101e19:	c0 
c0101e1a:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e1e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101e29:	00 
c0101e2a:	89 04 24             	mov    %eax,(%esp)
c0101e2d:	e8 0c f9 ff ff       	call   c010173e <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e35:	83 c0 02             	add    $0x2,%eax
c0101e38:	0f b7 c0             	movzwl %ax,%eax
c0101e3b:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e3f:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e43:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e47:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e4b:	ee                   	out    %al,(%dx)
}
c0101e4c:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e4d:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e50:	0f b6 c0             	movzbl %al,%eax
c0101e53:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e57:	83 c2 02             	add    $0x2,%edx
c0101e5a:	0f b7 d2             	movzwl %dx,%edx
c0101e5d:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e61:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e64:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101e68:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101e6c:	ee                   	out    %al,(%dx)
}
c0101e6d:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e71:	0f b6 c0             	movzbl %al,%eax
c0101e74:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e78:	83 c2 03             	add    $0x3,%edx
c0101e7b:	0f b7 d2             	movzwl %dx,%edx
c0101e7e:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101e82:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e85:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101e89:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101e8d:	ee                   	out    %al,(%dx)
}
c0101e8e:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e92:	c1 e8 08             	shr    $0x8,%eax
c0101e95:	0f b6 c0             	movzbl %al,%eax
c0101e98:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e9c:	83 c2 04             	add    $0x4,%edx
c0101e9f:	0f b7 d2             	movzwl %dx,%edx
c0101ea2:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101ea6:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ea9:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ead:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101eb1:	ee                   	out    %al,(%dx)
}
c0101eb2:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eb6:	c1 e8 10             	shr    $0x10,%eax
c0101eb9:	0f b6 c0             	movzbl %al,%eax
c0101ebc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ec0:	83 c2 05             	add    $0x5,%edx
c0101ec3:	0f b7 d2             	movzwl %dx,%edx
c0101ec6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101eca:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ecd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101ed1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101ed5:	ee                   	out    %al,(%dx)
}
c0101ed6:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101ed7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101eda:	c0 e0 04             	shl    $0x4,%al
c0101edd:	24 10                	and    $0x10,%al
c0101edf:	88 c2                	mov    %al,%dl
c0101ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ee4:	c1 e8 18             	shr    $0x18,%eax
c0101ee7:	24 0f                	and    $0xf,%al
c0101ee9:	08 d0                	or     %dl,%al
c0101eeb:	0c e0                	or     $0xe0,%al
c0101eed:	0f b6 c0             	movzbl %al,%eax
c0101ef0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ef4:	83 c2 06             	add    $0x6,%edx
c0101ef7:	0f b7 d2             	movzwl %dx,%edx
c0101efa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101efe:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f01:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f05:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f09:	ee                   	out    %al,(%dx)
}
c0101f0a:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f0b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f0f:	83 c0 07             	add    $0x7,%eax
c0101f12:	0f b7 c0             	movzwl %ax,%eax
c0101f15:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f19:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f1d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f21:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f25:	ee                   	out    %al,(%dx)
}
c0101f26:	90                   	nop

    int ret = 0;
c0101f27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f2e:	eb 58                	jmp    c0101f88 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f30:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101f3b:	00 
c0101f3c:	89 04 24             	mov    %eax,(%esp)
c0101f3f:	e8 fa f7 ff ff       	call   c010173e <ide_wait_ready>
c0101f44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f4b:	75 43                	jne    c0101f90 <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f4d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f51:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f54:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f57:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f5a:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f61:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f64:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f67:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f6a:	89 cb                	mov    %ecx,%ebx
c0101f6c:	89 de                	mov    %ebx,%esi
c0101f6e:	89 c1                	mov    %eax,%ecx
c0101f70:	fc                   	cld    
c0101f71:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f73:	89 c8                	mov    %ecx,%eax
c0101f75:	89 f3                	mov    %esi,%ebx
c0101f77:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f7a:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101f7d:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f7e:	ff 4d 14             	decl   0x14(%ebp)
c0101f81:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101f88:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101f8c:	75 a2                	jne    c0101f30 <ide_write_secs+0x1d6>
    }

out:
c0101f8e:	eb 01                	jmp    c0101f91 <ide_write_secs+0x237>
            goto out;
c0101f90:	90                   	nop
    return ret;
c0101f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f94:	83 c4 50             	add    $0x50,%esp
c0101f97:	5b                   	pop    %ebx
c0101f98:	5e                   	pop    %esi
c0101f99:	5d                   	pop    %ebp
c0101f9a:	c3                   	ret    

c0101f9b <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101f9b:	55                   	push   %ebp
c0101f9c:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101f9e:	fb                   	sti    
}
c0101f9f:	90                   	nop
    sti();
}
c0101fa0:	90                   	nop
c0101fa1:	5d                   	pop    %ebp
c0101fa2:	c3                   	ret    

c0101fa3 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101fa3:	55                   	push   %ebp
c0101fa4:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101fa6:	fa                   	cli    
}
c0101fa7:	90                   	nop
    cli();
}
c0101fa8:	90                   	nop
c0101fa9:	5d                   	pop    %ebp
c0101faa:	c3                   	ret    

c0101fab <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101fab:	55                   	push   %ebp
c0101fac:	89 e5                	mov    %esp,%ebp
c0101fae:	83 ec 14             	sub    $0x14,%esp
c0101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101fb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101fbb:	66 a3 50 35 12 c0    	mov    %ax,0xc0123550
    if (did_init) {
c0101fc1:	a1 60 67 12 c0       	mov    0xc0126760,%eax
c0101fc6:	85 c0                	test   %eax,%eax
c0101fc8:	74 39                	je     c0102003 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101fcd:	0f b6 c0             	movzbl %al,%eax
c0101fd0:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101fd6:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101fd9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fdd:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fe1:	ee                   	out    %al,(%dx)
}
c0101fe2:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101fe3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101fe7:	c1 e8 08             	shr    $0x8,%eax
c0101fea:	0f b7 c0             	movzwl %ax,%eax
c0101fed:	0f b6 c0             	movzbl %al,%eax
c0101ff0:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101ff6:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ff9:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ffd:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102001:	ee                   	out    %al,(%dx)
}
c0102002:	90                   	nop
    }
}
c0102003:	90                   	nop
c0102004:	89 ec                	mov    %ebp,%esp
c0102006:	5d                   	pop    %ebp
c0102007:	c3                   	ret    

c0102008 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102008:	55                   	push   %ebp
c0102009:	89 e5                	mov    %esp,%ebp
c010200b:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010200e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102011:	ba 01 00 00 00       	mov    $0x1,%edx
c0102016:	88 c1                	mov    %al,%cl
c0102018:	d3 e2                	shl    %cl,%edx
c010201a:	89 d0                	mov    %edx,%eax
c010201c:	98                   	cwtl   
c010201d:	f7 d0                	not    %eax
c010201f:	0f bf d0             	movswl %ax,%edx
c0102022:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c0102029:	98                   	cwtl   
c010202a:	21 d0                	and    %edx,%eax
c010202c:	98                   	cwtl   
c010202d:	0f b7 c0             	movzwl %ax,%eax
c0102030:	89 04 24             	mov    %eax,(%esp)
c0102033:	e8 73 ff ff ff       	call   c0101fab <pic_setmask>
}
c0102038:	90                   	nop
c0102039:	89 ec                	mov    %ebp,%esp
c010203b:	5d                   	pop    %ebp
c010203c:	c3                   	ret    

c010203d <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010203d:	55                   	push   %ebp
c010203e:	89 e5                	mov    %esp,%ebp
c0102040:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0102043:	c7 05 60 67 12 c0 01 	movl   $0x1,0xc0126760
c010204a:	00 00 00 
c010204d:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0102053:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102057:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010205b:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010205f:	ee                   	out    %al,(%dx)
}
c0102060:	90                   	nop
c0102061:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0102067:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010206b:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010206f:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102073:	ee                   	out    %al,(%dx)
}
c0102074:	90                   	nop
c0102075:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010207b:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010207f:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102083:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102087:	ee                   	out    %al,(%dx)
}
c0102088:	90                   	nop
c0102089:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010208f:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102093:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0102097:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010209b:	ee                   	out    %al,(%dx)
}
c010209c:	90                   	nop
c010209d:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01020a3:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020ab:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020af:	ee                   	out    %al,(%dx)
}
c01020b0:	90                   	nop
c01020b1:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01020b7:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020bb:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01020bf:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020c3:	ee                   	out    %al,(%dx)
}
c01020c4:	90                   	nop
c01020c5:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01020cb:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020cf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020d3:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01020d7:	ee                   	out    %al,(%dx)
}
c01020d8:	90                   	nop
c01020d9:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01020df:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e3:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01020e7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020eb:	ee                   	out    %al,(%dx)
}
c01020ec:	90                   	nop
c01020ed:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01020f3:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01020fb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01020ff:	ee                   	out    %al,(%dx)
}
c0102100:	90                   	nop
c0102101:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102107:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010210b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010210f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102113:	ee                   	out    %al,(%dx)
}
c0102114:	90                   	nop
c0102115:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c010211b:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010211f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102123:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102127:	ee                   	out    %al,(%dx)
}
c0102128:	90                   	nop
c0102129:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010212f:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102133:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102137:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010213b:	ee                   	out    %al,(%dx)
}
c010213c:	90                   	nop
c010213d:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0102143:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102147:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010214b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010214f:	ee                   	out    %al,(%dx)
}
c0102150:	90                   	nop
c0102151:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102157:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010215b:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010215f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102163:	ee                   	out    %al,(%dx)
}
c0102164:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102165:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c010216c:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0102171:	74 0f                	je     c0102182 <pic_init+0x145>
        pic_setmask(irq_mask);
c0102173:	0f b7 05 50 35 12 c0 	movzwl 0xc0123550,%eax
c010217a:	89 04 24             	mov    %eax,(%esp)
c010217d:	e8 29 fe ff ff       	call   c0101fab <pic_setmask>
    }
}
c0102182:	90                   	nop
c0102183:	89 ec                	mov    %ebp,%esp
c0102185:	5d                   	pop    %ebp
c0102186:	c3                   	ret    

c0102187 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102187:	55                   	push   %ebp
c0102188:	89 e5                	mov    %esp,%ebp
c010218a:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010218d:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102194:	00 
c0102195:	c7 04 24 20 94 10 c0 	movl   $0xc0109420,(%esp)
c010219c:	e8 c4 e1 ff ff       	call   c0100365 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01021a1:	90                   	nop
c01021a2:	89 ec                	mov    %ebp,%esp
c01021a4:	5d                   	pop    %ebp
c01021a5:	c3                   	ret    

c01021a6 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01021a6:	55                   	push   %ebp
c01021a7:	89 e5                	mov    %esp,%ebp
c01021a9:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c01021ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01021b3:	e9 c4 00 00 00       	jmp    c010227c <idt_init+0xd6>
    {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01021b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021bb:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c01021c2:	0f b7 d0             	movzwl %ax,%edx
c01021c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021c8:	66 89 14 c5 80 67 12 	mov    %dx,-0x3fed9880(,%eax,8)
c01021cf:	c0 
c01021d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021d3:	66 c7 04 c5 82 67 12 	movw   $0x8,-0x3fed987e(,%eax,8)
c01021da:	c0 08 00 
c01021dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e0:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c01021e7:	c0 
c01021e8:	80 e2 e0             	and    $0xe0,%dl
c01021eb:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c01021f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f5:	0f b6 14 c5 84 67 12 	movzbl -0x3fed987c(,%eax,8),%edx
c01021fc:	c0 
c01021fd:	80 e2 1f             	and    $0x1f,%dl
c0102200:	88 14 c5 84 67 12 c0 	mov    %dl,-0x3fed987c(,%eax,8)
c0102207:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010220a:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102211:	c0 
c0102212:	80 e2 f0             	and    $0xf0,%dl
c0102215:	80 ca 0e             	or     $0xe,%dl
c0102218:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c010221f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102222:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102229:	c0 
c010222a:	80 e2 ef             	and    $0xef,%dl
c010222d:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102234:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102237:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c010223e:	c0 
c010223f:	80 e2 9f             	and    $0x9f,%dl
c0102242:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c0102249:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010224c:	0f b6 14 c5 85 67 12 	movzbl -0x3fed987b(,%eax,8),%edx
c0102253:	c0 
c0102254:	80 ca 80             	or     $0x80,%dl
c0102257:	88 14 c5 85 67 12 c0 	mov    %dl,-0x3fed987b(,%eax,8)
c010225e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102261:	8b 04 85 e0 35 12 c0 	mov    -0x3fedca20(,%eax,4),%eax
c0102268:	c1 e8 10             	shr    $0x10,%eax
c010226b:	0f b7 d0             	movzwl %ax,%edx
c010226e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102271:	66 89 14 c5 86 67 12 	mov    %dx,-0x3fed987a(,%eax,8)
c0102278:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
c0102279:	ff 45 fc             	incl   -0x4(%ebp)
c010227c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227f:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102284:	0f 86 2e ff ff ff    	jbe    c01021b8 <idt_init+0x12>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010228a:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c010228f:	0f b7 c0             	movzwl %ax,%eax
c0102292:	66 a3 48 6b 12 c0    	mov    %ax,0xc0126b48
c0102298:	66 c7 05 4a 6b 12 c0 	movw   $0x8,0xc0126b4a
c010229f:	08 00 
c01022a1:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022a8:	24 e0                	and    $0xe0,%al
c01022aa:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c01022af:	0f b6 05 4c 6b 12 c0 	movzbl 0xc0126b4c,%eax
c01022b6:	24 1f                	and    $0x1f,%al
c01022b8:	a2 4c 6b 12 c0       	mov    %al,0xc0126b4c
c01022bd:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022c4:	24 f0                	and    $0xf0,%al
c01022c6:	0c 0e                	or     $0xe,%al
c01022c8:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022cd:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022d4:	24 ef                	and    $0xef,%al
c01022d6:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022db:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022e2:	0c 60                	or     $0x60,%al
c01022e4:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022e9:	0f b6 05 4d 6b 12 c0 	movzbl 0xc0126b4d,%eax
c01022f0:	0c 80                	or     $0x80,%al
c01022f2:	a2 4d 6b 12 c0       	mov    %al,0xc0126b4d
c01022f7:	a1 c4 37 12 c0       	mov    0xc01237c4,%eax
c01022fc:	c1 e8 10             	shr    $0x10,%eax
c01022ff:	0f b7 c0             	movzwl %ax,%eax
c0102302:	66 a3 4e 6b 12 c0    	mov    %ax,0xc0126b4e
c0102308:	c7 45 f8 60 35 12 c0 	movl   $0xc0123560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010230f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102312:	0f 01 18             	lidtl  (%eax)
}
c0102315:	90                   	nop
    lidt(&idt_pd);
}
c0102316:	90                   	nop
c0102317:	89 ec                	mov    %ebp,%esp
c0102319:	5d                   	pop    %ebp
c010231a:	c3                   	ret    

c010231b <trapname>:

static const char *
trapname(int trapno) {
c010231b:	55                   	push   %ebp
c010231c:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010231e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102321:	83 f8 13             	cmp    $0x13,%eax
c0102324:	77 0c                	ja     c0102332 <trapname+0x17>
        return excnames[trapno];
c0102326:	8b 45 08             	mov    0x8(%ebp),%eax
c0102329:	8b 04 85 80 98 10 c0 	mov    -0x3fef6780(,%eax,4),%eax
c0102330:	eb 18                	jmp    c010234a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0102332:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102336:	7e 0d                	jle    c0102345 <trapname+0x2a>
c0102338:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010233c:	7f 07                	jg     c0102345 <trapname+0x2a>
        return "Hardware Interrupt";
c010233e:	b8 2a 94 10 c0       	mov    $0xc010942a,%eax
c0102343:	eb 05                	jmp    c010234a <trapname+0x2f>
    }
    return "(unknown trap)";
c0102345:	b8 3d 94 10 c0       	mov    $0xc010943d,%eax
}
c010234a:	5d                   	pop    %ebp
c010234b:	c3                   	ret    

c010234c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010234c:	55                   	push   %ebp
c010234d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010234f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102352:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102356:	83 f8 08             	cmp    $0x8,%eax
c0102359:	0f 94 c0             	sete   %al
c010235c:	0f b6 c0             	movzbl %al,%eax
}
c010235f:	5d                   	pop    %ebp
c0102360:	c3                   	ret    

c0102361 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102361:	55                   	push   %ebp
c0102362:	89 e5                	mov    %esp,%ebp
c0102364:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102367:	8b 45 08             	mov    0x8(%ebp),%eax
c010236a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010236e:	c7 04 24 7e 94 10 c0 	movl   $0xc010947e,(%esp)
c0102375:	e8 eb df ff ff       	call   c0100365 <cprintf>
    print_regs(&tf->tf_regs);
c010237a:	8b 45 08             	mov    0x8(%ebp),%eax
c010237d:	89 04 24             	mov    %eax,(%esp)
c0102380:	e8 8f 01 00 00       	call   c0102514 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102385:	8b 45 08             	mov    0x8(%ebp),%eax
c0102388:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010238c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102390:	c7 04 24 8f 94 10 c0 	movl   $0xc010948f,(%esp)
c0102397:	e8 c9 df ff ff       	call   c0100365 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010239c:	8b 45 08             	mov    0x8(%ebp),%eax
c010239f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023a7:	c7 04 24 a2 94 10 c0 	movl   $0xc01094a2,(%esp)
c01023ae:	e8 b2 df ff ff       	call   c0100365 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01023b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b6:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01023ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023be:	c7 04 24 b5 94 10 c0 	movl   $0xc01094b5,(%esp)
c01023c5:	e8 9b df ff ff       	call   c0100365 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01023ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cd:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01023d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d5:	c7 04 24 c8 94 10 c0 	movl   $0xc01094c8,(%esp)
c01023dc:	e8 84 df ff ff       	call   c0100365 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01023e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e4:	8b 40 30             	mov    0x30(%eax),%eax
c01023e7:	89 04 24             	mov    %eax,(%esp)
c01023ea:	e8 2c ff ff ff       	call   c010231b <trapname>
c01023ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01023f2:	8b 52 30             	mov    0x30(%edx),%edx
c01023f5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01023f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01023fd:	c7 04 24 db 94 10 c0 	movl   $0xc01094db,(%esp)
c0102404:	e8 5c df ff ff       	call   c0100365 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102409:	8b 45 08             	mov    0x8(%ebp),%eax
c010240c:	8b 40 34             	mov    0x34(%eax),%eax
c010240f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102413:	c7 04 24 ed 94 10 c0 	movl   $0xc01094ed,(%esp)
c010241a:	e8 46 df ff ff       	call   c0100365 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010241f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102422:	8b 40 38             	mov    0x38(%eax),%eax
c0102425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102429:	c7 04 24 fc 94 10 c0 	movl   $0xc01094fc,(%esp)
c0102430:	e8 30 df ff ff       	call   c0100365 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102435:	8b 45 08             	mov    0x8(%ebp),%eax
c0102438:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010243c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102440:	c7 04 24 0b 95 10 c0 	movl   $0xc010950b,(%esp)
c0102447:	e8 19 df ff ff       	call   c0100365 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010244c:	8b 45 08             	mov    0x8(%ebp),%eax
c010244f:	8b 40 40             	mov    0x40(%eax),%eax
c0102452:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102456:	c7 04 24 1e 95 10 c0 	movl   $0xc010951e,(%esp)
c010245d:	e8 03 df ff ff       	call   c0100365 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102462:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102469:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102470:	eb 3d                	jmp    c01024af <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102472:	8b 45 08             	mov    0x8(%ebp),%eax
c0102475:	8b 50 40             	mov    0x40(%eax),%edx
c0102478:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010247b:	21 d0                	and    %edx,%eax
c010247d:	85 c0                	test   %eax,%eax
c010247f:	74 28                	je     c01024a9 <print_trapframe+0x148>
c0102481:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102484:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c010248b:	85 c0                	test   %eax,%eax
c010248d:	74 1a                	je     c01024a9 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c010248f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102492:	8b 04 85 80 35 12 c0 	mov    -0x3fedca80(,%eax,4),%eax
c0102499:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249d:	c7 04 24 2d 95 10 c0 	movl   $0xc010952d,(%esp)
c01024a4:	e8 bc de ff ff       	call   c0100365 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024a9:	ff 45 f4             	incl   -0xc(%ebp)
c01024ac:	d1 65 f0             	shll   -0x10(%ebp)
c01024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024b2:	83 f8 17             	cmp    $0x17,%eax
c01024b5:	76 bb                	jbe    c0102472 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01024b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ba:	8b 40 40             	mov    0x40(%eax),%eax
c01024bd:	c1 e8 0c             	shr    $0xc,%eax
c01024c0:	83 e0 03             	and    $0x3,%eax
c01024c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c7:	c7 04 24 31 95 10 c0 	movl   $0xc0109531,(%esp)
c01024ce:	e8 92 de ff ff       	call   c0100365 <cprintf>

    if (!trap_in_kernel(tf)) {
c01024d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d6:	89 04 24             	mov    %eax,(%esp)
c01024d9:	e8 6e fe ff ff       	call   c010234c <trap_in_kernel>
c01024de:	85 c0                	test   %eax,%eax
c01024e0:	75 2d                	jne    c010250f <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01024e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e5:	8b 40 44             	mov    0x44(%eax),%eax
c01024e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ec:	c7 04 24 3a 95 10 c0 	movl   $0xc010953a,(%esp)
c01024f3:	e8 6d de ff ff       	call   c0100365 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01024f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024fb:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01024ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102503:	c7 04 24 49 95 10 c0 	movl   $0xc0109549,(%esp)
c010250a:	e8 56 de ff ff       	call   c0100365 <cprintf>
    }
}
c010250f:	90                   	nop
c0102510:	89 ec                	mov    %ebp,%esp
c0102512:	5d                   	pop    %ebp
c0102513:	c3                   	ret    

c0102514 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102514:	55                   	push   %ebp
c0102515:	89 e5                	mov    %esp,%ebp
c0102517:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010251a:	8b 45 08             	mov    0x8(%ebp),%eax
c010251d:	8b 00                	mov    (%eax),%eax
c010251f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102523:	c7 04 24 5c 95 10 c0 	movl   $0xc010955c,(%esp)
c010252a:	e8 36 de ff ff       	call   c0100365 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010252f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102532:	8b 40 04             	mov    0x4(%eax),%eax
c0102535:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102539:	c7 04 24 6b 95 10 c0 	movl   $0xc010956b,(%esp)
c0102540:	e8 20 de ff ff       	call   c0100365 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102545:	8b 45 08             	mov    0x8(%ebp),%eax
c0102548:	8b 40 08             	mov    0x8(%eax),%eax
c010254b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010254f:	c7 04 24 7a 95 10 c0 	movl   $0xc010957a,(%esp)
c0102556:	e8 0a de ff ff       	call   c0100365 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010255b:	8b 45 08             	mov    0x8(%ebp),%eax
c010255e:	8b 40 0c             	mov    0xc(%eax),%eax
c0102561:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102565:	c7 04 24 89 95 10 c0 	movl   $0xc0109589,(%esp)
c010256c:	e8 f4 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102571:	8b 45 08             	mov    0x8(%ebp),%eax
c0102574:	8b 40 10             	mov    0x10(%eax),%eax
c0102577:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257b:	c7 04 24 98 95 10 c0 	movl   $0xc0109598,(%esp)
c0102582:	e8 de dd ff ff       	call   c0100365 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102587:	8b 45 08             	mov    0x8(%ebp),%eax
c010258a:	8b 40 14             	mov    0x14(%eax),%eax
c010258d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102591:	c7 04 24 a7 95 10 c0 	movl   $0xc01095a7,(%esp)
c0102598:	e8 c8 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010259d:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a0:	8b 40 18             	mov    0x18(%eax),%eax
c01025a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a7:	c7 04 24 b6 95 10 c0 	movl   $0xc01095b6,(%esp)
c01025ae:	e8 b2 dd ff ff       	call   c0100365 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01025b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b6:	8b 40 1c             	mov    0x1c(%eax),%eax
c01025b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025bd:	c7 04 24 c5 95 10 c0 	movl   $0xc01095c5,(%esp)
c01025c4:	e8 9c dd ff ff       	call   c0100365 <cprintf>
}
c01025c9:	90                   	nop
c01025ca:	89 ec                	mov    %ebp,%esp
c01025cc:	5d                   	pop    %ebp
c01025cd:	c3                   	ret    

c01025ce <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c01025ce:	55                   	push   %ebp
c01025cf:	89 e5                	mov    %esp,%ebp
c01025d1:	83 ec 38             	sub    $0x38,%esp
c01025d4:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01025d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025da:	8b 40 34             	mov    0x34(%eax),%eax
c01025dd:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025e0:	85 c0                	test   %eax,%eax
c01025e2:	74 07                	je     c01025eb <print_pgfault+0x1d>
c01025e4:	bb d4 95 10 c0       	mov    $0xc01095d4,%ebx
c01025e9:	eb 05                	jmp    c01025f0 <print_pgfault+0x22>
c01025eb:	bb e5 95 10 c0       	mov    $0xc01095e5,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c01025f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025f3:	8b 40 34             	mov    0x34(%eax),%eax
c01025f6:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01025f9:	85 c0                	test   %eax,%eax
c01025fb:	74 07                	je     c0102604 <print_pgfault+0x36>
c01025fd:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102602:	eb 05                	jmp    c0102609 <print_pgfault+0x3b>
c0102604:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102609:	8b 45 08             	mov    0x8(%ebp),%eax
c010260c:	8b 40 34             	mov    0x34(%eax),%eax
c010260f:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102612:	85 c0                	test   %eax,%eax
c0102614:	74 07                	je     c010261d <print_pgfault+0x4f>
c0102616:	ba 55 00 00 00       	mov    $0x55,%edx
c010261b:	eb 05                	jmp    c0102622 <print_pgfault+0x54>
c010261d:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102622:	0f 20 d0             	mov    %cr2,%eax
c0102625:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010262b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010262f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102633:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010263b:	c7 04 24 f4 95 10 c0 	movl   $0xc01095f4,(%esp)
c0102642:	e8 1e dd ff ff       	call   c0100365 <cprintf>
}
c0102647:	90                   	nop
c0102648:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010264b:	89 ec                	mov    %ebp,%esp
c010264d:	5d                   	pop    %ebp
c010264e:	c3                   	ret    

c010264f <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c010264f:	55                   	push   %ebp
c0102650:	89 e5                	mov    %esp,%ebp
c0102652:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0102655:	8b 45 08             	mov    0x8(%ebp),%eax
c0102658:	89 04 24             	mov    %eax,(%esp)
c010265b:	e8 6e ff ff ff       	call   c01025ce <print_pgfault>
    if (check_mm_struct != NULL) {
c0102660:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0102665:	85 c0                	test   %eax,%eax
c0102667:	74 26                	je     c010268f <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102669:	0f 20 d0             	mov    %cr2,%eax
c010266c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010266f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0102672:	8b 45 08             	mov    0x8(%ebp),%eax
c0102675:	8b 50 34             	mov    0x34(%eax),%edx
c0102678:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c010267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102681:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102685:	89 04 24             	mov    %eax,(%esp)
c0102688:	e8 6b 59 00 00       	call   c0107ff8 <do_pgfault>
c010268d:	eb 1c                	jmp    c01026ab <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c010268f:	c7 44 24 08 17 96 10 	movl   $0xc0109617,0x8(%esp)
c0102696:	c0 
c0102697:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c010269e:	00 
c010269f:	c7 04 24 2e 96 10 c0 	movl   $0xc010962e,(%esp)
c01026a6:	e8 42 e6 ff ff       	call   c0100ced <__panic>
}
c01026ab:	89 ec                	mov    %ebp,%esp
c01026ad:	5d                   	pop    %ebp
c01026ae:	c3                   	ret    

c01026af <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01026af:	55                   	push   %ebp
c01026b0:	89 e5                	mov    %esp,%ebp
c01026b2:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01026b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b8:	8b 40 30             	mov    0x30(%eax),%eax
c01026bb:	83 f8 2f             	cmp    $0x2f,%eax
c01026be:	77 1e                	ja     c01026de <trap_dispatch+0x2f>
c01026c0:	83 f8 0e             	cmp    $0xe,%eax
c01026c3:	0f 82 1a 01 00 00    	jb     c01027e3 <trap_dispatch+0x134>
c01026c9:	83 e8 0e             	sub    $0xe,%eax
c01026cc:	83 f8 21             	cmp    $0x21,%eax
c01026cf:	0f 87 0e 01 00 00    	ja     c01027e3 <trap_dispatch+0x134>
c01026d5:	8b 04 85 a8 96 10 c0 	mov    -0x3fef6958(,%eax,4),%eax
c01026dc:	ff e0                	jmp    *%eax
c01026de:	83 e8 78             	sub    $0x78,%eax
c01026e1:	83 f8 01             	cmp    $0x1,%eax
c01026e4:	0f 87 f9 00 00 00    	ja     c01027e3 <trap_dispatch+0x134>
c01026ea:	e9 d8 00 00 00       	jmp    c01027c7 <trap_dispatch+0x118>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01026ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f2:	89 04 24             	mov    %eax,(%esp)
c01026f5:	e8 55 ff ff ff       	call   c010264f <pgfault_handler>
c01026fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01026fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102701:	0f 84 14 01 00 00    	je     c010281b <trap_dispatch+0x16c>
            print_trapframe(tf);
c0102707:	8b 45 08             	mov    0x8(%ebp),%eax
c010270a:	89 04 24             	mov    %eax,(%esp)
c010270d:	e8 4f fc ff ff       	call   c0102361 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102712:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102715:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102719:	c7 44 24 08 3f 96 10 	movl   $0xc010963f,0x8(%esp)
c0102720:	c0 
c0102721:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102728:	00 
c0102729:	c7 04 24 2e 96 10 c0 	movl   $0xc010962e,(%esp)
c0102730:	e8 b8 e5 ff ff       	call   c0100ced <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks++;
c0102735:	a1 24 64 12 c0       	mov    0xc0126424,%eax
c010273a:	40                   	inc    %eax
c010273b:	a3 24 64 12 c0       	mov    %eax,0xc0126424
        if (ticks % TICK_NUM == 0)
c0102740:	8b 0d 24 64 12 c0    	mov    0xc0126424,%ecx
c0102746:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010274b:	89 c8                	mov    %ecx,%eax
c010274d:	f7 e2                	mul    %edx
c010274f:	c1 ea 05             	shr    $0x5,%edx
c0102752:	89 d0                	mov    %edx,%eax
c0102754:	c1 e0 02             	shl    $0x2,%eax
c0102757:	01 d0                	add    %edx,%eax
c0102759:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0102760:	01 d0                	add    %edx,%eax
c0102762:	c1 e0 02             	shl    $0x2,%eax
c0102765:	29 c1                	sub    %eax,%ecx
c0102767:	89 ca                	mov    %ecx,%edx
c0102769:	85 d2                	test   %edx,%edx
c010276b:	0f 85 ad 00 00 00    	jne    c010281e <trap_dispatch+0x16f>
        {
            print_ticks();
c0102771:	e8 11 fa ff ff       	call   c0102187 <print_ticks>
        }
        break;
c0102776:	e9 a3 00 00 00       	jmp    c010281e <trap_dispatch+0x16f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010277b:	e8 4d ef ff ff       	call   c01016cd <cons_getc>
c0102780:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102783:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102787:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010278b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010278f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102793:	c7 04 24 5a 96 10 c0 	movl   $0xc010965a,(%esp)
c010279a:	e8 c6 db ff ff       	call   c0100365 <cprintf>
        break;
c010279f:	eb 7e                	jmp    c010281f <trap_dispatch+0x170>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01027a1:	e8 27 ef ff ff       	call   c01016cd <cons_getc>
c01027a6:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01027a9:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027ad:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027b1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027b9:	c7 04 24 6c 96 10 c0 	movl   $0xc010966c,(%esp)
c01027c0:	e8 a0 db ff ff       	call   c0100365 <cprintf>
        break;
c01027c5:	eb 58                	jmp    c010281f <trap_dispatch+0x170>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01027c7:	c7 44 24 08 7b 96 10 	movl   $0xc010967b,0x8(%esp)
c01027ce:	c0 
c01027cf:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01027d6:	00 
c01027d7:	c7 04 24 2e 96 10 c0 	movl   $0xc010962e,(%esp)
c01027de:	e8 0a e5 ff ff       	call   c0100ced <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01027e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01027e6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01027ea:	83 e0 03             	and    $0x3,%eax
c01027ed:	85 c0                	test   %eax,%eax
c01027ef:	75 2e                	jne    c010281f <trap_dispatch+0x170>
            print_trapframe(tf);
c01027f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01027f4:	89 04 24             	mov    %eax,(%esp)
c01027f7:	e8 65 fb ff ff       	call   c0102361 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01027fc:	c7 44 24 08 8b 96 10 	movl   $0xc010968b,0x8(%esp)
c0102803:	c0 
c0102804:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010280b:	00 
c010280c:	c7 04 24 2e 96 10 c0 	movl   $0xc010962e,(%esp)
c0102813:	e8 d5 e4 ff ff       	call   c0100ced <__panic>
        break;
c0102818:	90                   	nop
c0102819:	eb 04                	jmp    c010281f <trap_dispatch+0x170>
        break;
c010281b:	90                   	nop
c010281c:	eb 01                	jmp    c010281f <trap_dispatch+0x170>
        break;
c010281e:	90                   	nop
        }
    }
}
c010281f:	90                   	nop
c0102820:	89 ec                	mov    %ebp,%esp
c0102822:	5d                   	pop    %ebp
c0102823:	c3                   	ret    

c0102824 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102824:	55                   	push   %ebp
c0102825:	89 e5                	mov    %esp,%ebp
c0102827:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010282a:	8b 45 08             	mov    0x8(%ebp),%eax
c010282d:	89 04 24             	mov    %eax,(%esp)
c0102830:	e8 7a fe ff ff       	call   c01026af <trap_dispatch>
}
c0102835:	90                   	nop
c0102836:	89 ec                	mov    %ebp,%esp
c0102838:	5d                   	pop    %ebp
c0102839:	c3                   	ret    

c010283a <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010283a:	1e                   	push   %ds
    pushl %es
c010283b:	06                   	push   %es
    pushl %fs
c010283c:	0f a0                	push   %fs
    pushl %gs
c010283e:	0f a8                	push   %gs
    pushal
c0102840:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102841:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102846:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102848:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010284a:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c010284b:	e8 d4 ff ff ff       	call   c0102824 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102850:	5c                   	pop    %esp

c0102851 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102851:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102852:	0f a9                	pop    %gs
    popl %fs
c0102854:	0f a1                	pop    %fs
    popl %es
c0102856:	07                   	pop    %es
    popl %ds
c0102857:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102858:	83 c4 08             	add    $0x8,%esp
    iret
c010285b:	cf                   	iret   

c010285c <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $0
c010285e:	6a 00                	push   $0x0
  jmp __alltraps
c0102860:	e9 d5 ff ff ff       	jmp    c010283a <__alltraps>

c0102865 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $1
c0102867:	6a 01                	push   $0x1
  jmp __alltraps
c0102869:	e9 cc ff ff ff       	jmp    c010283a <__alltraps>

c010286e <vector2>:
.globl vector2
vector2:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $2
c0102870:	6a 02                	push   $0x2
  jmp __alltraps
c0102872:	e9 c3 ff ff ff       	jmp    c010283a <__alltraps>

c0102877 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $3
c0102879:	6a 03                	push   $0x3
  jmp __alltraps
c010287b:	e9 ba ff ff ff       	jmp    c010283a <__alltraps>

c0102880 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $4
c0102882:	6a 04                	push   $0x4
  jmp __alltraps
c0102884:	e9 b1 ff ff ff       	jmp    c010283a <__alltraps>

c0102889 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $5
c010288b:	6a 05                	push   $0x5
  jmp __alltraps
c010288d:	e9 a8 ff ff ff       	jmp    c010283a <__alltraps>

c0102892 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $6
c0102894:	6a 06                	push   $0x6
  jmp __alltraps
c0102896:	e9 9f ff ff ff       	jmp    c010283a <__alltraps>

c010289b <vector7>:
.globl vector7
vector7:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $7
c010289d:	6a 07                	push   $0x7
  jmp __alltraps
c010289f:	e9 96 ff ff ff       	jmp    c010283a <__alltraps>

c01028a4 <vector8>:
.globl vector8
vector8:
  pushl $8
c01028a4:	6a 08                	push   $0x8
  jmp __alltraps
c01028a6:	e9 8f ff ff ff       	jmp    c010283a <__alltraps>

c01028ab <vector9>:
.globl vector9
vector9:
  pushl $0
c01028ab:	6a 00                	push   $0x0
  pushl $9
c01028ad:	6a 09                	push   $0x9
  jmp __alltraps
c01028af:	e9 86 ff ff ff       	jmp    c010283a <__alltraps>

c01028b4 <vector10>:
.globl vector10
vector10:
  pushl $10
c01028b4:	6a 0a                	push   $0xa
  jmp __alltraps
c01028b6:	e9 7f ff ff ff       	jmp    c010283a <__alltraps>

c01028bb <vector11>:
.globl vector11
vector11:
  pushl $11
c01028bb:	6a 0b                	push   $0xb
  jmp __alltraps
c01028bd:	e9 78 ff ff ff       	jmp    c010283a <__alltraps>

c01028c2 <vector12>:
.globl vector12
vector12:
  pushl $12
c01028c2:	6a 0c                	push   $0xc
  jmp __alltraps
c01028c4:	e9 71 ff ff ff       	jmp    c010283a <__alltraps>

c01028c9 <vector13>:
.globl vector13
vector13:
  pushl $13
c01028c9:	6a 0d                	push   $0xd
  jmp __alltraps
c01028cb:	e9 6a ff ff ff       	jmp    c010283a <__alltraps>

c01028d0 <vector14>:
.globl vector14
vector14:
  pushl $14
c01028d0:	6a 0e                	push   $0xe
  jmp __alltraps
c01028d2:	e9 63 ff ff ff       	jmp    c010283a <__alltraps>

c01028d7 <vector15>:
.globl vector15
vector15:
  pushl $0
c01028d7:	6a 00                	push   $0x0
  pushl $15
c01028d9:	6a 0f                	push   $0xf
  jmp __alltraps
c01028db:	e9 5a ff ff ff       	jmp    c010283a <__alltraps>

c01028e0 <vector16>:
.globl vector16
vector16:
  pushl $0
c01028e0:	6a 00                	push   $0x0
  pushl $16
c01028e2:	6a 10                	push   $0x10
  jmp __alltraps
c01028e4:	e9 51 ff ff ff       	jmp    c010283a <__alltraps>

c01028e9 <vector17>:
.globl vector17
vector17:
  pushl $17
c01028e9:	6a 11                	push   $0x11
  jmp __alltraps
c01028eb:	e9 4a ff ff ff       	jmp    c010283a <__alltraps>

c01028f0 <vector18>:
.globl vector18
vector18:
  pushl $0
c01028f0:	6a 00                	push   $0x0
  pushl $18
c01028f2:	6a 12                	push   $0x12
  jmp __alltraps
c01028f4:	e9 41 ff ff ff       	jmp    c010283a <__alltraps>

c01028f9 <vector19>:
.globl vector19
vector19:
  pushl $0
c01028f9:	6a 00                	push   $0x0
  pushl $19
c01028fb:	6a 13                	push   $0x13
  jmp __alltraps
c01028fd:	e9 38 ff ff ff       	jmp    c010283a <__alltraps>

c0102902 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102902:	6a 00                	push   $0x0
  pushl $20
c0102904:	6a 14                	push   $0x14
  jmp __alltraps
c0102906:	e9 2f ff ff ff       	jmp    c010283a <__alltraps>

c010290b <vector21>:
.globl vector21
vector21:
  pushl $0
c010290b:	6a 00                	push   $0x0
  pushl $21
c010290d:	6a 15                	push   $0x15
  jmp __alltraps
c010290f:	e9 26 ff ff ff       	jmp    c010283a <__alltraps>

c0102914 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102914:	6a 00                	push   $0x0
  pushl $22
c0102916:	6a 16                	push   $0x16
  jmp __alltraps
c0102918:	e9 1d ff ff ff       	jmp    c010283a <__alltraps>

c010291d <vector23>:
.globl vector23
vector23:
  pushl $0
c010291d:	6a 00                	push   $0x0
  pushl $23
c010291f:	6a 17                	push   $0x17
  jmp __alltraps
c0102921:	e9 14 ff ff ff       	jmp    c010283a <__alltraps>

c0102926 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102926:	6a 00                	push   $0x0
  pushl $24
c0102928:	6a 18                	push   $0x18
  jmp __alltraps
c010292a:	e9 0b ff ff ff       	jmp    c010283a <__alltraps>

c010292f <vector25>:
.globl vector25
vector25:
  pushl $0
c010292f:	6a 00                	push   $0x0
  pushl $25
c0102931:	6a 19                	push   $0x19
  jmp __alltraps
c0102933:	e9 02 ff ff ff       	jmp    c010283a <__alltraps>

c0102938 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102938:	6a 00                	push   $0x0
  pushl $26
c010293a:	6a 1a                	push   $0x1a
  jmp __alltraps
c010293c:	e9 f9 fe ff ff       	jmp    c010283a <__alltraps>

c0102941 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102941:	6a 00                	push   $0x0
  pushl $27
c0102943:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102945:	e9 f0 fe ff ff       	jmp    c010283a <__alltraps>

c010294a <vector28>:
.globl vector28
vector28:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $28
c010294c:	6a 1c                	push   $0x1c
  jmp __alltraps
c010294e:	e9 e7 fe ff ff       	jmp    c010283a <__alltraps>

c0102953 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102953:	6a 00                	push   $0x0
  pushl $29
c0102955:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102957:	e9 de fe ff ff       	jmp    c010283a <__alltraps>

c010295c <vector30>:
.globl vector30
vector30:
  pushl $0
c010295c:	6a 00                	push   $0x0
  pushl $30
c010295e:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102960:	e9 d5 fe ff ff       	jmp    c010283a <__alltraps>

c0102965 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102965:	6a 00                	push   $0x0
  pushl $31
c0102967:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102969:	e9 cc fe ff ff       	jmp    c010283a <__alltraps>

c010296e <vector32>:
.globl vector32
vector32:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $32
c0102970:	6a 20                	push   $0x20
  jmp __alltraps
c0102972:	e9 c3 fe ff ff       	jmp    c010283a <__alltraps>

c0102977 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102977:	6a 00                	push   $0x0
  pushl $33
c0102979:	6a 21                	push   $0x21
  jmp __alltraps
c010297b:	e9 ba fe ff ff       	jmp    c010283a <__alltraps>

c0102980 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $34
c0102982:	6a 22                	push   $0x22
  jmp __alltraps
c0102984:	e9 b1 fe ff ff       	jmp    c010283a <__alltraps>

c0102989 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102989:	6a 00                	push   $0x0
  pushl $35
c010298b:	6a 23                	push   $0x23
  jmp __alltraps
c010298d:	e9 a8 fe ff ff       	jmp    c010283a <__alltraps>

c0102992 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $36
c0102994:	6a 24                	push   $0x24
  jmp __alltraps
c0102996:	e9 9f fe ff ff       	jmp    c010283a <__alltraps>

c010299b <vector37>:
.globl vector37
vector37:
  pushl $0
c010299b:	6a 00                	push   $0x0
  pushl $37
c010299d:	6a 25                	push   $0x25
  jmp __alltraps
c010299f:	e9 96 fe ff ff       	jmp    c010283a <__alltraps>

c01029a4 <vector38>:
.globl vector38
vector38:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $38
c01029a6:	6a 26                	push   $0x26
  jmp __alltraps
c01029a8:	e9 8d fe ff ff       	jmp    c010283a <__alltraps>

c01029ad <vector39>:
.globl vector39
vector39:
  pushl $0
c01029ad:	6a 00                	push   $0x0
  pushl $39
c01029af:	6a 27                	push   $0x27
  jmp __alltraps
c01029b1:	e9 84 fe ff ff       	jmp    c010283a <__alltraps>

c01029b6 <vector40>:
.globl vector40
vector40:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $40
c01029b8:	6a 28                	push   $0x28
  jmp __alltraps
c01029ba:	e9 7b fe ff ff       	jmp    c010283a <__alltraps>

c01029bf <vector41>:
.globl vector41
vector41:
  pushl $0
c01029bf:	6a 00                	push   $0x0
  pushl $41
c01029c1:	6a 29                	push   $0x29
  jmp __alltraps
c01029c3:	e9 72 fe ff ff       	jmp    c010283a <__alltraps>

c01029c8 <vector42>:
.globl vector42
vector42:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $42
c01029ca:	6a 2a                	push   $0x2a
  jmp __alltraps
c01029cc:	e9 69 fe ff ff       	jmp    c010283a <__alltraps>

c01029d1 <vector43>:
.globl vector43
vector43:
  pushl $0
c01029d1:	6a 00                	push   $0x0
  pushl $43
c01029d3:	6a 2b                	push   $0x2b
  jmp __alltraps
c01029d5:	e9 60 fe ff ff       	jmp    c010283a <__alltraps>

c01029da <vector44>:
.globl vector44
vector44:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $44
c01029dc:	6a 2c                	push   $0x2c
  jmp __alltraps
c01029de:	e9 57 fe ff ff       	jmp    c010283a <__alltraps>

c01029e3 <vector45>:
.globl vector45
vector45:
  pushl $0
c01029e3:	6a 00                	push   $0x0
  pushl $45
c01029e5:	6a 2d                	push   $0x2d
  jmp __alltraps
c01029e7:	e9 4e fe ff ff       	jmp    c010283a <__alltraps>

c01029ec <vector46>:
.globl vector46
vector46:
  pushl $0
c01029ec:	6a 00                	push   $0x0
  pushl $46
c01029ee:	6a 2e                	push   $0x2e
  jmp __alltraps
c01029f0:	e9 45 fe ff ff       	jmp    c010283a <__alltraps>

c01029f5 <vector47>:
.globl vector47
vector47:
  pushl $0
c01029f5:	6a 00                	push   $0x0
  pushl $47
c01029f7:	6a 2f                	push   $0x2f
  jmp __alltraps
c01029f9:	e9 3c fe ff ff       	jmp    c010283a <__alltraps>

c01029fe <vector48>:
.globl vector48
vector48:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $48
c0102a00:	6a 30                	push   $0x30
  jmp __alltraps
c0102a02:	e9 33 fe ff ff       	jmp    c010283a <__alltraps>

c0102a07 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102a07:	6a 00                	push   $0x0
  pushl $49
c0102a09:	6a 31                	push   $0x31
  jmp __alltraps
c0102a0b:	e9 2a fe ff ff       	jmp    c010283a <__alltraps>

c0102a10 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102a10:	6a 00                	push   $0x0
  pushl $50
c0102a12:	6a 32                	push   $0x32
  jmp __alltraps
c0102a14:	e9 21 fe ff ff       	jmp    c010283a <__alltraps>

c0102a19 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102a19:	6a 00                	push   $0x0
  pushl $51
c0102a1b:	6a 33                	push   $0x33
  jmp __alltraps
c0102a1d:	e9 18 fe ff ff       	jmp    c010283a <__alltraps>

c0102a22 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102a22:	6a 00                	push   $0x0
  pushl $52
c0102a24:	6a 34                	push   $0x34
  jmp __alltraps
c0102a26:	e9 0f fe ff ff       	jmp    c010283a <__alltraps>

c0102a2b <vector53>:
.globl vector53
vector53:
  pushl $0
c0102a2b:	6a 00                	push   $0x0
  pushl $53
c0102a2d:	6a 35                	push   $0x35
  jmp __alltraps
c0102a2f:	e9 06 fe ff ff       	jmp    c010283a <__alltraps>

c0102a34 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102a34:	6a 00                	push   $0x0
  pushl $54
c0102a36:	6a 36                	push   $0x36
  jmp __alltraps
c0102a38:	e9 fd fd ff ff       	jmp    c010283a <__alltraps>

c0102a3d <vector55>:
.globl vector55
vector55:
  pushl $0
c0102a3d:	6a 00                	push   $0x0
  pushl $55
c0102a3f:	6a 37                	push   $0x37
  jmp __alltraps
c0102a41:	e9 f4 fd ff ff       	jmp    c010283a <__alltraps>

c0102a46 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102a46:	6a 00                	push   $0x0
  pushl $56
c0102a48:	6a 38                	push   $0x38
  jmp __alltraps
c0102a4a:	e9 eb fd ff ff       	jmp    c010283a <__alltraps>

c0102a4f <vector57>:
.globl vector57
vector57:
  pushl $0
c0102a4f:	6a 00                	push   $0x0
  pushl $57
c0102a51:	6a 39                	push   $0x39
  jmp __alltraps
c0102a53:	e9 e2 fd ff ff       	jmp    c010283a <__alltraps>

c0102a58 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102a58:	6a 00                	push   $0x0
  pushl $58
c0102a5a:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102a5c:	e9 d9 fd ff ff       	jmp    c010283a <__alltraps>

c0102a61 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102a61:	6a 00                	push   $0x0
  pushl $59
c0102a63:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102a65:	e9 d0 fd ff ff       	jmp    c010283a <__alltraps>

c0102a6a <vector60>:
.globl vector60
vector60:
  pushl $0
c0102a6a:	6a 00                	push   $0x0
  pushl $60
c0102a6c:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102a6e:	e9 c7 fd ff ff       	jmp    c010283a <__alltraps>

c0102a73 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102a73:	6a 00                	push   $0x0
  pushl $61
c0102a75:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102a77:	e9 be fd ff ff       	jmp    c010283a <__alltraps>

c0102a7c <vector62>:
.globl vector62
vector62:
  pushl $0
c0102a7c:	6a 00                	push   $0x0
  pushl $62
c0102a7e:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102a80:	e9 b5 fd ff ff       	jmp    c010283a <__alltraps>

c0102a85 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102a85:	6a 00                	push   $0x0
  pushl $63
c0102a87:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102a89:	e9 ac fd ff ff       	jmp    c010283a <__alltraps>

c0102a8e <vector64>:
.globl vector64
vector64:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $64
c0102a90:	6a 40                	push   $0x40
  jmp __alltraps
c0102a92:	e9 a3 fd ff ff       	jmp    c010283a <__alltraps>

c0102a97 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102a97:	6a 00                	push   $0x0
  pushl $65
c0102a99:	6a 41                	push   $0x41
  jmp __alltraps
c0102a9b:	e9 9a fd ff ff       	jmp    c010283a <__alltraps>

c0102aa0 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102aa0:	6a 00                	push   $0x0
  pushl $66
c0102aa2:	6a 42                	push   $0x42
  jmp __alltraps
c0102aa4:	e9 91 fd ff ff       	jmp    c010283a <__alltraps>

c0102aa9 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  pushl $67
c0102aab:	6a 43                	push   $0x43
  jmp __alltraps
c0102aad:	e9 88 fd ff ff       	jmp    c010283a <__alltraps>

c0102ab2 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102ab2:	6a 00                	push   $0x0
  pushl $68
c0102ab4:	6a 44                	push   $0x44
  jmp __alltraps
c0102ab6:	e9 7f fd ff ff       	jmp    c010283a <__alltraps>

c0102abb <vector69>:
.globl vector69
vector69:
  pushl $0
c0102abb:	6a 00                	push   $0x0
  pushl $69
c0102abd:	6a 45                	push   $0x45
  jmp __alltraps
c0102abf:	e9 76 fd ff ff       	jmp    c010283a <__alltraps>

c0102ac4 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102ac4:	6a 00                	push   $0x0
  pushl $70
c0102ac6:	6a 46                	push   $0x46
  jmp __alltraps
c0102ac8:	e9 6d fd ff ff       	jmp    c010283a <__alltraps>

c0102acd <vector71>:
.globl vector71
vector71:
  pushl $0
c0102acd:	6a 00                	push   $0x0
  pushl $71
c0102acf:	6a 47                	push   $0x47
  jmp __alltraps
c0102ad1:	e9 64 fd ff ff       	jmp    c010283a <__alltraps>

c0102ad6 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $72
c0102ad8:	6a 48                	push   $0x48
  jmp __alltraps
c0102ada:	e9 5b fd ff ff       	jmp    c010283a <__alltraps>

c0102adf <vector73>:
.globl vector73
vector73:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $73
c0102ae1:	6a 49                	push   $0x49
  jmp __alltraps
c0102ae3:	e9 52 fd ff ff       	jmp    c010283a <__alltraps>

c0102ae8 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $74
c0102aea:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102aec:	e9 49 fd ff ff       	jmp    c010283a <__alltraps>

c0102af1 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $75
c0102af3:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102af5:	e9 40 fd ff ff       	jmp    c010283a <__alltraps>

c0102afa <vector76>:
.globl vector76
vector76:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $76
c0102afc:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102afe:	e9 37 fd ff ff       	jmp    c010283a <__alltraps>

c0102b03 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102b03:	6a 00                	push   $0x0
  pushl $77
c0102b05:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102b07:	e9 2e fd ff ff       	jmp    c010283a <__alltraps>

c0102b0c <vector78>:
.globl vector78
vector78:
  pushl $0
c0102b0c:	6a 00                	push   $0x0
  pushl $78
c0102b0e:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102b10:	e9 25 fd ff ff       	jmp    c010283a <__alltraps>

c0102b15 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102b15:	6a 00                	push   $0x0
  pushl $79
c0102b17:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102b19:	e9 1c fd ff ff       	jmp    c010283a <__alltraps>

c0102b1e <vector80>:
.globl vector80
vector80:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $80
c0102b20:	6a 50                	push   $0x50
  jmp __alltraps
c0102b22:	e9 13 fd ff ff       	jmp    c010283a <__alltraps>

c0102b27 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102b27:	6a 00                	push   $0x0
  pushl $81
c0102b29:	6a 51                	push   $0x51
  jmp __alltraps
c0102b2b:	e9 0a fd ff ff       	jmp    c010283a <__alltraps>

c0102b30 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102b30:	6a 00                	push   $0x0
  pushl $82
c0102b32:	6a 52                	push   $0x52
  jmp __alltraps
c0102b34:	e9 01 fd ff ff       	jmp    c010283a <__alltraps>

c0102b39 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $83
c0102b3b:	6a 53                	push   $0x53
  jmp __alltraps
c0102b3d:	e9 f8 fc ff ff       	jmp    c010283a <__alltraps>

c0102b42 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $84
c0102b44:	6a 54                	push   $0x54
  jmp __alltraps
c0102b46:	e9 ef fc ff ff       	jmp    c010283a <__alltraps>

c0102b4b <vector85>:
.globl vector85
vector85:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $85
c0102b4d:	6a 55                	push   $0x55
  jmp __alltraps
c0102b4f:	e9 e6 fc ff ff       	jmp    c010283a <__alltraps>

c0102b54 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $86
c0102b56:	6a 56                	push   $0x56
  jmp __alltraps
c0102b58:	e9 dd fc ff ff       	jmp    c010283a <__alltraps>

c0102b5d <vector87>:
.globl vector87
vector87:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $87
c0102b5f:	6a 57                	push   $0x57
  jmp __alltraps
c0102b61:	e9 d4 fc ff ff       	jmp    c010283a <__alltraps>

c0102b66 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $88
c0102b68:	6a 58                	push   $0x58
  jmp __alltraps
c0102b6a:	e9 cb fc ff ff       	jmp    c010283a <__alltraps>

c0102b6f <vector89>:
.globl vector89
vector89:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $89
c0102b71:	6a 59                	push   $0x59
  jmp __alltraps
c0102b73:	e9 c2 fc ff ff       	jmp    c010283a <__alltraps>

c0102b78 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $90
c0102b7a:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102b7c:	e9 b9 fc ff ff       	jmp    c010283a <__alltraps>

c0102b81 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $91
c0102b83:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102b85:	e9 b0 fc ff ff       	jmp    c010283a <__alltraps>

c0102b8a <vector92>:
.globl vector92
vector92:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $92
c0102b8c:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102b8e:	e9 a7 fc ff ff       	jmp    c010283a <__alltraps>

c0102b93 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $93
c0102b95:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102b97:	e9 9e fc ff ff       	jmp    c010283a <__alltraps>

c0102b9c <vector94>:
.globl vector94
vector94:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $94
c0102b9e:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102ba0:	e9 95 fc ff ff       	jmp    c010283a <__alltraps>

c0102ba5 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $95
c0102ba7:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102ba9:	e9 8c fc ff ff       	jmp    c010283a <__alltraps>

c0102bae <vector96>:
.globl vector96
vector96:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $96
c0102bb0:	6a 60                	push   $0x60
  jmp __alltraps
c0102bb2:	e9 83 fc ff ff       	jmp    c010283a <__alltraps>

c0102bb7 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $97
c0102bb9:	6a 61                	push   $0x61
  jmp __alltraps
c0102bbb:	e9 7a fc ff ff       	jmp    c010283a <__alltraps>

c0102bc0 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $98
c0102bc2:	6a 62                	push   $0x62
  jmp __alltraps
c0102bc4:	e9 71 fc ff ff       	jmp    c010283a <__alltraps>

c0102bc9 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $99
c0102bcb:	6a 63                	push   $0x63
  jmp __alltraps
c0102bcd:	e9 68 fc ff ff       	jmp    c010283a <__alltraps>

c0102bd2 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $100
c0102bd4:	6a 64                	push   $0x64
  jmp __alltraps
c0102bd6:	e9 5f fc ff ff       	jmp    c010283a <__alltraps>

c0102bdb <vector101>:
.globl vector101
vector101:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $101
c0102bdd:	6a 65                	push   $0x65
  jmp __alltraps
c0102bdf:	e9 56 fc ff ff       	jmp    c010283a <__alltraps>

c0102be4 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $102
c0102be6:	6a 66                	push   $0x66
  jmp __alltraps
c0102be8:	e9 4d fc ff ff       	jmp    c010283a <__alltraps>

c0102bed <vector103>:
.globl vector103
vector103:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $103
c0102bef:	6a 67                	push   $0x67
  jmp __alltraps
c0102bf1:	e9 44 fc ff ff       	jmp    c010283a <__alltraps>

c0102bf6 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $104
c0102bf8:	6a 68                	push   $0x68
  jmp __alltraps
c0102bfa:	e9 3b fc ff ff       	jmp    c010283a <__alltraps>

c0102bff <vector105>:
.globl vector105
vector105:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $105
c0102c01:	6a 69                	push   $0x69
  jmp __alltraps
c0102c03:	e9 32 fc ff ff       	jmp    c010283a <__alltraps>

c0102c08 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $106
c0102c0a:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102c0c:	e9 29 fc ff ff       	jmp    c010283a <__alltraps>

c0102c11 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $107
c0102c13:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102c15:	e9 20 fc ff ff       	jmp    c010283a <__alltraps>

c0102c1a <vector108>:
.globl vector108
vector108:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $108
c0102c1c:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102c1e:	e9 17 fc ff ff       	jmp    c010283a <__alltraps>

c0102c23 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $109
c0102c25:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102c27:	e9 0e fc ff ff       	jmp    c010283a <__alltraps>

c0102c2c <vector110>:
.globl vector110
vector110:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $110
c0102c2e:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102c30:	e9 05 fc ff ff       	jmp    c010283a <__alltraps>

c0102c35 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $111
c0102c37:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102c39:	e9 fc fb ff ff       	jmp    c010283a <__alltraps>

c0102c3e <vector112>:
.globl vector112
vector112:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $112
c0102c40:	6a 70                	push   $0x70
  jmp __alltraps
c0102c42:	e9 f3 fb ff ff       	jmp    c010283a <__alltraps>

c0102c47 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $113
c0102c49:	6a 71                	push   $0x71
  jmp __alltraps
c0102c4b:	e9 ea fb ff ff       	jmp    c010283a <__alltraps>

c0102c50 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $114
c0102c52:	6a 72                	push   $0x72
  jmp __alltraps
c0102c54:	e9 e1 fb ff ff       	jmp    c010283a <__alltraps>

c0102c59 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $115
c0102c5b:	6a 73                	push   $0x73
  jmp __alltraps
c0102c5d:	e9 d8 fb ff ff       	jmp    c010283a <__alltraps>

c0102c62 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $116
c0102c64:	6a 74                	push   $0x74
  jmp __alltraps
c0102c66:	e9 cf fb ff ff       	jmp    c010283a <__alltraps>

c0102c6b <vector117>:
.globl vector117
vector117:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $117
c0102c6d:	6a 75                	push   $0x75
  jmp __alltraps
c0102c6f:	e9 c6 fb ff ff       	jmp    c010283a <__alltraps>

c0102c74 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $118
c0102c76:	6a 76                	push   $0x76
  jmp __alltraps
c0102c78:	e9 bd fb ff ff       	jmp    c010283a <__alltraps>

c0102c7d <vector119>:
.globl vector119
vector119:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $119
c0102c7f:	6a 77                	push   $0x77
  jmp __alltraps
c0102c81:	e9 b4 fb ff ff       	jmp    c010283a <__alltraps>

c0102c86 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $120
c0102c88:	6a 78                	push   $0x78
  jmp __alltraps
c0102c8a:	e9 ab fb ff ff       	jmp    c010283a <__alltraps>

c0102c8f <vector121>:
.globl vector121
vector121:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $121
c0102c91:	6a 79                	push   $0x79
  jmp __alltraps
c0102c93:	e9 a2 fb ff ff       	jmp    c010283a <__alltraps>

c0102c98 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $122
c0102c9a:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102c9c:	e9 99 fb ff ff       	jmp    c010283a <__alltraps>

c0102ca1 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $123
c0102ca3:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102ca5:	e9 90 fb ff ff       	jmp    c010283a <__alltraps>

c0102caa <vector124>:
.globl vector124
vector124:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $124
c0102cac:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102cae:	e9 87 fb ff ff       	jmp    c010283a <__alltraps>

c0102cb3 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $125
c0102cb5:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102cb7:	e9 7e fb ff ff       	jmp    c010283a <__alltraps>

c0102cbc <vector126>:
.globl vector126
vector126:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $126
c0102cbe:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102cc0:	e9 75 fb ff ff       	jmp    c010283a <__alltraps>

c0102cc5 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $127
c0102cc7:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102cc9:	e9 6c fb ff ff       	jmp    c010283a <__alltraps>

c0102cce <vector128>:
.globl vector128
vector128:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $128
c0102cd0:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102cd5:	e9 60 fb ff ff       	jmp    c010283a <__alltraps>

c0102cda <vector129>:
.globl vector129
vector129:
  pushl $0
c0102cda:	6a 00                	push   $0x0
  pushl $129
c0102cdc:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ce1:	e9 54 fb ff ff       	jmp    c010283a <__alltraps>

c0102ce6 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ce6:	6a 00                	push   $0x0
  pushl $130
c0102ce8:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102ced:	e9 48 fb ff ff       	jmp    c010283a <__alltraps>

c0102cf2 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $131
c0102cf4:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102cf9:	e9 3c fb ff ff       	jmp    c010283a <__alltraps>

c0102cfe <vector132>:
.globl vector132
vector132:
  pushl $0
c0102cfe:	6a 00                	push   $0x0
  pushl $132
c0102d00:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102d05:	e9 30 fb ff ff       	jmp    c010283a <__alltraps>

c0102d0a <vector133>:
.globl vector133
vector133:
  pushl $0
c0102d0a:	6a 00                	push   $0x0
  pushl $133
c0102d0c:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102d11:	e9 24 fb ff ff       	jmp    c010283a <__alltraps>

c0102d16 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $134
c0102d18:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102d1d:	e9 18 fb ff ff       	jmp    c010283a <__alltraps>

c0102d22 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102d22:	6a 00                	push   $0x0
  pushl $135
c0102d24:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102d29:	e9 0c fb ff ff       	jmp    c010283a <__alltraps>

c0102d2e <vector136>:
.globl vector136
vector136:
  pushl $0
c0102d2e:	6a 00                	push   $0x0
  pushl $136
c0102d30:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102d35:	e9 00 fb ff ff       	jmp    c010283a <__alltraps>

c0102d3a <vector137>:
.globl vector137
vector137:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $137
c0102d3c:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102d41:	e9 f4 fa ff ff       	jmp    c010283a <__alltraps>

c0102d46 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102d46:	6a 00                	push   $0x0
  pushl $138
c0102d48:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102d4d:	e9 e8 fa ff ff       	jmp    c010283a <__alltraps>

c0102d52 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102d52:	6a 00                	push   $0x0
  pushl $139
c0102d54:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102d59:	e9 dc fa ff ff       	jmp    c010283a <__alltraps>

c0102d5e <vector140>:
.globl vector140
vector140:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $140
c0102d60:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102d65:	e9 d0 fa ff ff       	jmp    c010283a <__alltraps>

c0102d6a <vector141>:
.globl vector141
vector141:
  pushl $0
c0102d6a:	6a 00                	push   $0x0
  pushl $141
c0102d6c:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102d71:	e9 c4 fa ff ff       	jmp    c010283a <__alltraps>

c0102d76 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102d76:	6a 00                	push   $0x0
  pushl $142
c0102d78:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102d7d:	e9 b8 fa ff ff       	jmp    c010283a <__alltraps>

c0102d82 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $143
c0102d84:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102d89:	e9 ac fa ff ff       	jmp    c010283a <__alltraps>

c0102d8e <vector144>:
.globl vector144
vector144:
  pushl $0
c0102d8e:	6a 00                	push   $0x0
  pushl $144
c0102d90:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102d95:	e9 a0 fa ff ff       	jmp    c010283a <__alltraps>

c0102d9a <vector145>:
.globl vector145
vector145:
  pushl $0
c0102d9a:	6a 00                	push   $0x0
  pushl $145
c0102d9c:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102da1:	e9 94 fa ff ff       	jmp    c010283a <__alltraps>

c0102da6 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $146
c0102da8:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102dad:	e9 88 fa ff ff       	jmp    c010283a <__alltraps>

c0102db2 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102db2:	6a 00                	push   $0x0
  pushl $147
c0102db4:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102db9:	e9 7c fa ff ff       	jmp    c010283a <__alltraps>

c0102dbe <vector148>:
.globl vector148
vector148:
  pushl $0
c0102dbe:	6a 00                	push   $0x0
  pushl $148
c0102dc0:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102dc5:	e9 70 fa ff ff       	jmp    c010283a <__alltraps>

c0102dca <vector149>:
.globl vector149
vector149:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $149
c0102dcc:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102dd1:	e9 64 fa ff ff       	jmp    c010283a <__alltraps>

c0102dd6 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102dd6:	6a 00                	push   $0x0
  pushl $150
c0102dd8:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102ddd:	e9 58 fa ff ff       	jmp    c010283a <__alltraps>

c0102de2 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102de2:	6a 00                	push   $0x0
  pushl $151
c0102de4:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102de9:	e9 4c fa ff ff       	jmp    c010283a <__alltraps>

c0102dee <vector152>:
.globl vector152
vector152:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $152
c0102df0:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102df5:	e9 40 fa ff ff       	jmp    c010283a <__alltraps>

c0102dfa <vector153>:
.globl vector153
vector153:
  pushl $0
c0102dfa:	6a 00                	push   $0x0
  pushl $153
c0102dfc:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102e01:	e9 34 fa ff ff       	jmp    c010283a <__alltraps>

c0102e06 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102e06:	6a 00                	push   $0x0
  pushl $154
c0102e08:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102e0d:	e9 28 fa ff ff       	jmp    c010283a <__alltraps>

c0102e12 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $155
c0102e14:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102e19:	e9 1c fa ff ff       	jmp    c010283a <__alltraps>

c0102e1e <vector156>:
.globl vector156
vector156:
  pushl $0
c0102e1e:	6a 00                	push   $0x0
  pushl $156
c0102e20:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102e25:	e9 10 fa ff ff       	jmp    c010283a <__alltraps>

c0102e2a <vector157>:
.globl vector157
vector157:
  pushl $0
c0102e2a:	6a 00                	push   $0x0
  pushl $157
c0102e2c:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102e31:	e9 04 fa ff ff       	jmp    c010283a <__alltraps>

c0102e36 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $158
c0102e38:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102e3d:	e9 f8 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e42 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102e42:	6a 00                	push   $0x0
  pushl $159
c0102e44:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102e49:	e9 ec f9 ff ff       	jmp    c010283a <__alltraps>

c0102e4e <vector160>:
.globl vector160
vector160:
  pushl $0
c0102e4e:	6a 00                	push   $0x0
  pushl $160
c0102e50:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102e55:	e9 e0 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e5a <vector161>:
.globl vector161
vector161:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $161
c0102e5c:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102e61:	e9 d4 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e66 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102e66:	6a 00                	push   $0x0
  pushl $162
c0102e68:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102e6d:	e9 c8 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e72 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102e72:	6a 00                	push   $0x0
  pushl $163
c0102e74:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102e79:	e9 bc f9 ff ff       	jmp    c010283a <__alltraps>

c0102e7e <vector164>:
.globl vector164
vector164:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $164
c0102e80:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102e85:	e9 b0 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e8a <vector165>:
.globl vector165
vector165:
  pushl $0
c0102e8a:	6a 00                	push   $0x0
  pushl $165
c0102e8c:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102e91:	e9 a4 f9 ff ff       	jmp    c010283a <__alltraps>

c0102e96 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102e96:	6a 00                	push   $0x0
  pushl $166
c0102e98:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102e9d:	e9 98 f9 ff ff       	jmp    c010283a <__alltraps>

c0102ea2 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $167
c0102ea4:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102ea9:	e9 8c f9 ff ff       	jmp    c010283a <__alltraps>

c0102eae <vector168>:
.globl vector168
vector168:
  pushl $0
c0102eae:	6a 00                	push   $0x0
  pushl $168
c0102eb0:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102eb5:	e9 80 f9 ff ff       	jmp    c010283a <__alltraps>

c0102eba <vector169>:
.globl vector169
vector169:
  pushl $0
c0102eba:	6a 00                	push   $0x0
  pushl $169
c0102ebc:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102ec1:	e9 74 f9 ff ff       	jmp    c010283a <__alltraps>

c0102ec6 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $170
c0102ec8:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102ecd:	e9 68 f9 ff ff       	jmp    c010283a <__alltraps>

c0102ed2 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102ed2:	6a 00                	push   $0x0
  pushl $171
c0102ed4:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102ed9:	e9 5c f9 ff ff       	jmp    c010283a <__alltraps>

c0102ede <vector172>:
.globl vector172
vector172:
  pushl $0
c0102ede:	6a 00                	push   $0x0
  pushl $172
c0102ee0:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102ee5:	e9 50 f9 ff ff       	jmp    c010283a <__alltraps>

c0102eea <vector173>:
.globl vector173
vector173:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $173
c0102eec:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102ef1:	e9 44 f9 ff ff       	jmp    c010283a <__alltraps>

c0102ef6 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102ef6:	6a 00                	push   $0x0
  pushl $174
c0102ef8:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102efd:	e9 38 f9 ff ff       	jmp    c010283a <__alltraps>

c0102f02 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102f02:	6a 00                	push   $0x0
  pushl $175
c0102f04:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102f09:	e9 2c f9 ff ff       	jmp    c010283a <__alltraps>

c0102f0e <vector176>:
.globl vector176
vector176:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $176
c0102f10:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102f15:	e9 20 f9 ff ff       	jmp    c010283a <__alltraps>

c0102f1a <vector177>:
.globl vector177
vector177:
  pushl $0
c0102f1a:	6a 00                	push   $0x0
  pushl $177
c0102f1c:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102f21:	e9 14 f9 ff ff       	jmp    c010283a <__alltraps>

c0102f26 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102f26:	6a 00                	push   $0x0
  pushl $178
c0102f28:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102f2d:	e9 08 f9 ff ff       	jmp    c010283a <__alltraps>

c0102f32 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102f32:	6a 00                	push   $0x0
  pushl $179
c0102f34:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102f39:	e9 fc f8 ff ff       	jmp    c010283a <__alltraps>

c0102f3e <vector180>:
.globl vector180
vector180:
  pushl $0
c0102f3e:	6a 00                	push   $0x0
  pushl $180
c0102f40:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102f45:	e9 f0 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f4a <vector181>:
.globl vector181
vector181:
  pushl $0
c0102f4a:	6a 00                	push   $0x0
  pushl $181
c0102f4c:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102f51:	e9 e4 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f56 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102f56:	6a 00                	push   $0x0
  pushl $182
c0102f58:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102f5d:	e9 d8 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f62 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102f62:	6a 00                	push   $0x0
  pushl $183
c0102f64:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102f69:	e9 cc f8 ff ff       	jmp    c010283a <__alltraps>

c0102f6e <vector184>:
.globl vector184
vector184:
  pushl $0
c0102f6e:	6a 00                	push   $0x0
  pushl $184
c0102f70:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102f75:	e9 c0 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f7a <vector185>:
.globl vector185
vector185:
  pushl $0
c0102f7a:	6a 00                	push   $0x0
  pushl $185
c0102f7c:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102f81:	e9 b4 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f86 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102f86:	6a 00                	push   $0x0
  pushl $186
c0102f88:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102f8d:	e9 a8 f8 ff ff       	jmp    c010283a <__alltraps>

c0102f92 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102f92:	6a 00                	push   $0x0
  pushl $187
c0102f94:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102f99:	e9 9c f8 ff ff       	jmp    c010283a <__alltraps>

c0102f9e <vector188>:
.globl vector188
vector188:
  pushl $0
c0102f9e:	6a 00                	push   $0x0
  pushl $188
c0102fa0:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102fa5:	e9 90 f8 ff ff       	jmp    c010283a <__alltraps>

c0102faa <vector189>:
.globl vector189
vector189:
  pushl $0
c0102faa:	6a 00                	push   $0x0
  pushl $189
c0102fac:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102fb1:	e9 84 f8 ff ff       	jmp    c010283a <__alltraps>

c0102fb6 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102fb6:	6a 00                	push   $0x0
  pushl $190
c0102fb8:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102fbd:	e9 78 f8 ff ff       	jmp    c010283a <__alltraps>

c0102fc2 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102fc2:	6a 00                	push   $0x0
  pushl $191
c0102fc4:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102fc9:	e9 6c f8 ff ff       	jmp    c010283a <__alltraps>

c0102fce <vector192>:
.globl vector192
vector192:
  pushl $0
c0102fce:	6a 00                	push   $0x0
  pushl $192
c0102fd0:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102fd5:	e9 60 f8 ff ff       	jmp    c010283a <__alltraps>

c0102fda <vector193>:
.globl vector193
vector193:
  pushl $0
c0102fda:	6a 00                	push   $0x0
  pushl $193
c0102fdc:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102fe1:	e9 54 f8 ff ff       	jmp    c010283a <__alltraps>

c0102fe6 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102fe6:	6a 00                	push   $0x0
  pushl $194
c0102fe8:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102fed:	e9 48 f8 ff ff       	jmp    c010283a <__alltraps>

c0102ff2 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102ff2:	6a 00                	push   $0x0
  pushl $195
c0102ff4:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102ff9:	e9 3c f8 ff ff       	jmp    c010283a <__alltraps>

c0102ffe <vector196>:
.globl vector196
vector196:
  pushl $0
c0102ffe:	6a 00                	push   $0x0
  pushl $196
c0103000:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0103005:	e9 30 f8 ff ff       	jmp    c010283a <__alltraps>

c010300a <vector197>:
.globl vector197
vector197:
  pushl $0
c010300a:	6a 00                	push   $0x0
  pushl $197
c010300c:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0103011:	e9 24 f8 ff ff       	jmp    c010283a <__alltraps>

c0103016 <vector198>:
.globl vector198
vector198:
  pushl $0
c0103016:	6a 00                	push   $0x0
  pushl $198
c0103018:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010301d:	e9 18 f8 ff ff       	jmp    c010283a <__alltraps>

c0103022 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103022:	6a 00                	push   $0x0
  pushl $199
c0103024:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103029:	e9 0c f8 ff ff       	jmp    c010283a <__alltraps>

c010302e <vector200>:
.globl vector200
vector200:
  pushl $0
c010302e:	6a 00                	push   $0x0
  pushl $200
c0103030:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103035:	e9 00 f8 ff ff       	jmp    c010283a <__alltraps>

c010303a <vector201>:
.globl vector201
vector201:
  pushl $0
c010303a:	6a 00                	push   $0x0
  pushl $201
c010303c:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103041:	e9 f4 f7 ff ff       	jmp    c010283a <__alltraps>

c0103046 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103046:	6a 00                	push   $0x0
  pushl $202
c0103048:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010304d:	e9 e8 f7 ff ff       	jmp    c010283a <__alltraps>

c0103052 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103052:	6a 00                	push   $0x0
  pushl $203
c0103054:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103059:	e9 dc f7 ff ff       	jmp    c010283a <__alltraps>

c010305e <vector204>:
.globl vector204
vector204:
  pushl $0
c010305e:	6a 00                	push   $0x0
  pushl $204
c0103060:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103065:	e9 d0 f7 ff ff       	jmp    c010283a <__alltraps>

c010306a <vector205>:
.globl vector205
vector205:
  pushl $0
c010306a:	6a 00                	push   $0x0
  pushl $205
c010306c:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103071:	e9 c4 f7 ff ff       	jmp    c010283a <__alltraps>

c0103076 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103076:	6a 00                	push   $0x0
  pushl $206
c0103078:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010307d:	e9 b8 f7 ff ff       	jmp    c010283a <__alltraps>

c0103082 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103082:	6a 00                	push   $0x0
  pushl $207
c0103084:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103089:	e9 ac f7 ff ff       	jmp    c010283a <__alltraps>

c010308e <vector208>:
.globl vector208
vector208:
  pushl $0
c010308e:	6a 00                	push   $0x0
  pushl $208
c0103090:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103095:	e9 a0 f7 ff ff       	jmp    c010283a <__alltraps>

c010309a <vector209>:
.globl vector209
vector209:
  pushl $0
c010309a:	6a 00                	push   $0x0
  pushl $209
c010309c:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01030a1:	e9 94 f7 ff ff       	jmp    c010283a <__alltraps>

c01030a6 <vector210>:
.globl vector210
vector210:
  pushl $0
c01030a6:	6a 00                	push   $0x0
  pushl $210
c01030a8:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01030ad:	e9 88 f7 ff ff       	jmp    c010283a <__alltraps>

c01030b2 <vector211>:
.globl vector211
vector211:
  pushl $0
c01030b2:	6a 00                	push   $0x0
  pushl $211
c01030b4:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01030b9:	e9 7c f7 ff ff       	jmp    c010283a <__alltraps>

c01030be <vector212>:
.globl vector212
vector212:
  pushl $0
c01030be:	6a 00                	push   $0x0
  pushl $212
c01030c0:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01030c5:	e9 70 f7 ff ff       	jmp    c010283a <__alltraps>

c01030ca <vector213>:
.globl vector213
vector213:
  pushl $0
c01030ca:	6a 00                	push   $0x0
  pushl $213
c01030cc:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01030d1:	e9 64 f7 ff ff       	jmp    c010283a <__alltraps>

c01030d6 <vector214>:
.globl vector214
vector214:
  pushl $0
c01030d6:	6a 00                	push   $0x0
  pushl $214
c01030d8:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01030dd:	e9 58 f7 ff ff       	jmp    c010283a <__alltraps>

c01030e2 <vector215>:
.globl vector215
vector215:
  pushl $0
c01030e2:	6a 00                	push   $0x0
  pushl $215
c01030e4:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01030e9:	e9 4c f7 ff ff       	jmp    c010283a <__alltraps>

c01030ee <vector216>:
.globl vector216
vector216:
  pushl $0
c01030ee:	6a 00                	push   $0x0
  pushl $216
c01030f0:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01030f5:	e9 40 f7 ff ff       	jmp    c010283a <__alltraps>

c01030fa <vector217>:
.globl vector217
vector217:
  pushl $0
c01030fa:	6a 00                	push   $0x0
  pushl $217
c01030fc:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103101:	e9 34 f7 ff ff       	jmp    c010283a <__alltraps>

c0103106 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103106:	6a 00                	push   $0x0
  pushl $218
c0103108:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010310d:	e9 28 f7 ff ff       	jmp    c010283a <__alltraps>

c0103112 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103112:	6a 00                	push   $0x0
  pushl $219
c0103114:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103119:	e9 1c f7 ff ff       	jmp    c010283a <__alltraps>

c010311e <vector220>:
.globl vector220
vector220:
  pushl $0
c010311e:	6a 00                	push   $0x0
  pushl $220
c0103120:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103125:	e9 10 f7 ff ff       	jmp    c010283a <__alltraps>

c010312a <vector221>:
.globl vector221
vector221:
  pushl $0
c010312a:	6a 00                	push   $0x0
  pushl $221
c010312c:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103131:	e9 04 f7 ff ff       	jmp    c010283a <__alltraps>

c0103136 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103136:	6a 00                	push   $0x0
  pushl $222
c0103138:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010313d:	e9 f8 f6 ff ff       	jmp    c010283a <__alltraps>

c0103142 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103142:	6a 00                	push   $0x0
  pushl $223
c0103144:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103149:	e9 ec f6 ff ff       	jmp    c010283a <__alltraps>

c010314e <vector224>:
.globl vector224
vector224:
  pushl $0
c010314e:	6a 00                	push   $0x0
  pushl $224
c0103150:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103155:	e9 e0 f6 ff ff       	jmp    c010283a <__alltraps>

c010315a <vector225>:
.globl vector225
vector225:
  pushl $0
c010315a:	6a 00                	push   $0x0
  pushl $225
c010315c:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103161:	e9 d4 f6 ff ff       	jmp    c010283a <__alltraps>

c0103166 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103166:	6a 00                	push   $0x0
  pushl $226
c0103168:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010316d:	e9 c8 f6 ff ff       	jmp    c010283a <__alltraps>

c0103172 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103172:	6a 00                	push   $0x0
  pushl $227
c0103174:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103179:	e9 bc f6 ff ff       	jmp    c010283a <__alltraps>

c010317e <vector228>:
.globl vector228
vector228:
  pushl $0
c010317e:	6a 00                	push   $0x0
  pushl $228
c0103180:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103185:	e9 b0 f6 ff ff       	jmp    c010283a <__alltraps>

c010318a <vector229>:
.globl vector229
vector229:
  pushl $0
c010318a:	6a 00                	push   $0x0
  pushl $229
c010318c:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103191:	e9 a4 f6 ff ff       	jmp    c010283a <__alltraps>

c0103196 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103196:	6a 00                	push   $0x0
  pushl $230
c0103198:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010319d:	e9 98 f6 ff ff       	jmp    c010283a <__alltraps>

c01031a2 <vector231>:
.globl vector231
vector231:
  pushl $0
c01031a2:	6a 00                	push   $0x0
  pushl $231
c01031a4:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01031a9:	e9 8c f6 ff ff       	jmp    c010283a <__alltraps>

c01031ae <vector232>:
.globl vector232
vector232:
  pushl $0
c01031ae:	6a 00                	push   $0x0
  pushl $232
c01031b0:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01031b5:	e9 80 f6 ff ff       	jmp    c010283a <__alltraps>

c01031ba <vector233>:
.globl vector233
vector233:
  pushl $0
c01031ba:	6a 00                	push   $0x0
  pushl $233
c01031bc:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01031c1:	e9 74 f6 ff ff       	jmp    c010283a <__alltraps>

c01031c6 <vector234>:
.globl vector234
vector234:
  pushl $0
c01031c6:	6a 00                	push   $0x0
  pushl $234
c01031c8:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01031cd:	e9 68 f6 ff ff       	jmp    c010283a <__alltraps>

c01031d2 <vector235>:
.globl vector235
vector235:
  pushl $0
c01031d2:	6a 00                	push   $0x0
  pushl $235
c01031d4:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01031d9:	e9 5c f6 ff ff       	jmp    c010283a <__alltraps>

c01031de <vector236>:
.globl vector236
vector236:
  pushl $0
c01031de:	6a 00                	push   $0x0
  pushl $236
c01031e0:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01031e5:	e9 50 f6 ff ff       	jmp    c010283a <__alltraps>

c01031ea <vector237>:
.globl vector237
vector237:
  pushl $0
c01031ea:	6a 00                	push   $0x0
  pushl $237
c01031ec:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01031f1:	e9 44 f6 ff ff       	jmp    c010283a <__alltraps>

c01031f6 <vector238>:
.globl vector238
vector238:
  pushl $0
c01031f6:	6a 00                	push   $0x0
  pushl $238
c01031f8:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01031fd:	e9 38 f6 ff ff       	jmp    c010283a <__alltraps>

c0103202 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103202:	6a 00                	push   $0x0
  pushl $239
c0103204:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103209:	e9 2c f6 ff ff       	jmp    c010283a <__alltraps>

c010320e <vector240>:
.globl vector240
vector240:
  pushl $0
c010320e:	6a 00                	push   $0x0
  pushl $240
c0103210:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103215:	e9 20 f6 ff ff       	jmp    c010283a <__alltraps>

c010321a <vector241>:
.globl vector241
vector241:
  pushl $0
c010321a:	6a 00                	push   $0x0
  pushl $241
c010321c:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103221:	e9 14 f6 ff ff       	jmp    c010283a <__alltraps>

c0103226 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103226:	6a 00                	push   $0x0
  pushl $242
c0103228:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c010322d:	e9 08 f6 ff ff       	jmp    c010283a <__alltraps>

c0103232 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103232:	6a 00                	push   $0x0
  pushl $243
c0103234:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103239:	e9 fc f5 ff ff       	jmp    c010283a <__alltraps>

c010323e <vector244>:
.globl vector244
vector244:
  pushl $0
c010323e:	6a 00                	push   $0x0
  pushl $244
c0103240:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103245:	e9 f0 f5 ff ff       	jmp    c010283a <__alltraps>

c010324a <vector245>:
.globl vector245
vector245:
  pushl $0
c010324a:	6a 00                	push   $0x0
  pushl $245
c010324c:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103251:	e9 e4 f5 ff ff       	jmp    c010283a <__alltraps>

c0103256 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103256:	6a 00                	push   $0x0
  pushl $246
c0103258:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010325d:	e9 d8 f5 ff ff       	jmp    c010283a <__alltraps>

c0103262 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103262:	6a 00                	push   $0x0
  pushl $247
c0103264:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103269:	e9 cc f5 ff ff       	jmp    c010283a <__alltraps>

c010326e <vector248>:
.globl vector248
vector248:
  pushl $0
c010326e:	6a 00                	push   $0x0
  pushl $248
c0103270:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103275:	e9 c0 f5 ff ff       	jmp    c010283a <__alltraps>

c010327a <vector249>:
.globl vector249
vector249:
  pushl $0
c010327a:	6a 00                	push   $0x0
  pushl $249
c010327c:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103281:	e9 b4 f5 ff ff       	jmp    c010283a <__alltraps>

c0103286 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103286:	6a 00                	push   $0x0
  pushl $250
c0103288:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010328d:	e9 a8 f5 ff ff       	jmp    c010283a <__alltraps>

c0103292 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103292:	6a 00                	push   $0x0
  pushl $251
c0103294:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103299:	e9 9c f5 ff ff       	jmp    c010283a <__alltraps>

c010329e <vector252>:
.globl vector252
vector252:
  pushl $0
c010329e:	6a 00                	push   $0x0
  pushl $252
c01032a0:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01032a5:	e9 90 f5 ff ff       	jmp    c010283a <__alltraps>

c01032aa <vector253>:
.globl vector253
vector253:
  pushl $0
c01032aa:	6a 00                	push   $0x0
  pushl $253
c01032ac:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01032b1:	e9 84 f5 ff ff       	jmp    c010283a <__alltraps>

c01032b6 <vector254>:
.globl vector254
vector254:
  pushl $0
c01032b6:	6a 00                	push   $0x0
  pushl $254
c01032b8:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01032bd:	e9 78 f5 ff ff       	jmp    c010283a <__alltraps>

c01032c2 <vector255>:
.globl vector255
vector255:
  pushl $0
c01032c2:	6a 00                	push   $0x0
  pushl $255
c01032c4:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01032c9:	e9 6c f5 ff ff       	jmp    c010283a <__alltraps>

c01032ce <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01032ce:	55                   	push   %ebp
c01032cf:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01032d1:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01032d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032da:	29 d0                	sub    %edx,%eax
c01032dc:	c1 f8 05             	sar    $0x5,%eax
}
c01032df:	5d                   	pop    %ebp
c01032e0:	c3                   	ret    

c01032e1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01032e1:	55                   	push   %ebp
c01032e2:	89 e5                	mov    %esp,%ebp
c01032e4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01032e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ea:	89 04 24             	mov    %eax,(%esp)
c01032ed:	e8 dc ff ff ff       	call   c01032ce <page2ppn>
c01032f2:	c1 e0 0c             	shl    $0xc,%eax
}
c01032f5:	89 ec                	mov    %ebp,%esp
c01032f7:	5d                   	pop    %ebp
c01032f8:	c3                   	ret    

c01032f9 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01032f9:	55                   	push   %ebp
c01032fa:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01032fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01032ff:	8b 00                	mov    (%eax),%eax
}
c0103301:	5d                   	pop    %ebp
c0103302:	c3                   	ret    

c0103303 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103303:	55                   	push   %ebp
c0103304:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103306:	8b 45 08             	mov    0x8(%ebp),%eax
c0103309:	8b 55 0c             	mov    0xc(%ebp),%edx
c010330c:	89 10                	mov    %edx,(%eax)
}
c010330e:	90                   	nop
c010330f:	5d                   	pop    %ebp
c0103310:	c3                   	ret    

c0103311 <default_init>:
#define free_list (free_area.free_list) //
#define nr_free (free_area.nr_free)
static void test(void);

static void default_init(void)
{
c0103311:	55                   	push   %ebp
c0103312:	89 e5                	mov    %esp,%ebp
c0103314:	83 ec 10             	sub    $0x10,%esp
c0103317:	c7 45 fc 84 6f 12 c0 	movl   $0xc0126f84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010331e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103321:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103324:	89 50 04             	mov    %edx,0x4(%eax)
c0103327:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010332a:	8b 50 04             	mov    0x4(%eax),%edx
c010332d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103330:	89 10                	mov    %edx,(%eax)
}
c0103332:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0103333:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c010333a:	00 00 00 
}
c010333d:	90                   	nop
c010333e:	89 ec                	mov    %ebp,%esp
c0103340:	5d                   	pop    %ebp
c0103341:	c3                   	ret    

c0103342 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n)
{
c0103342:	55                   	push   %ebp
c0103343:	89 e5                	mov    %esp,%ebp
c0103345:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103348:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010334c:	75 24                	jne    c0103372 <default_init_memmap+0x30>
c010334e:	c7 44 24 0c d0 98 10 	movl   $0xc01098d0,0xc(%esp)
c0103355:	c0 
c0103356:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c010335d:	c0 
c010335e:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0103365:	00 
c0103366:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c010336d:	e8 7b d9 ff ff       	call   c0100ced <__panic>
    struct Page *p = base;
c0103372:	8b 45 08             	mov    0x8(%ebp),%eax
c0103375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c0103378:	eb 7d                	jmp    c01033f7 <default_init_memmap+0xb5>
    {
        assert(PageReserved(p));
c010337a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010337d:	83 c0 04             	add    $0x4,%eax
c0103380:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103387:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010338a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010338d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103390:	0f a3 10             	bt     %edx,(%eax)
c0103393:	19 c0                	sbb    %eax,%eax
c0103395:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103398:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010339c:	0f 95 c0             	setne  %al
c010339f:	0f b6 c0             	movzbl %al,%eax
c01033a2:	85 c0                	test   %eax,%eax
c01033a4:	75 24                	jne    c01033ca <default_init_memmap+0x88>
c01033a6:	c7 44 24 0c 01 99 10 	movl   $0xc0109901,0xc(%esp)
c01033ad:	c0 
c01033ae:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01033b5:	c0 
c01033b6:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c01033bd:	00 
c01033be:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01033c5:	e8 23 d9 ff ff       	call   c0100ced <__panic>
        p->flags = p->property = 0;
c01033ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033cd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01033d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d7:	8b 50 08             	mov    0x8(%eax),%edx
c01033da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033dd:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01033e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01033e7:	00 
c01033e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033eb:	89 04 24             	mov    %eax,(%esp)
c01033ee:	e8 10 ff ff ff       	call   c0103303 <set_page_ref>
    for (; p != base + n; p++)
c01033f3:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01033f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033fa:	c1 e0 05             	shl    $0x5,%eax
c01033fd:	89 c2                	mov    %eax,%edx
c01033ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103402:	01 d0                	add    %edx,%eax
c0103404:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103407:	0f 85 6d ff ff ff    	jne    c010337a <default_init_memmap+0x38>
    }
    base->property = n;
c010340d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103410:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103413:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103416:	8b 45 08             	mov    0x8(%ebp),%eax
c0103419:	83 c0 04             	add    $0x4,%eax
c010341c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103423:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103426:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103429:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010342c:	0f ab 10             	bts    %edx,(%eax)
}
c010342f:	90                   	nop
    nr_free += n;
c0103430:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c0103436:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103439:	01 d0                	add    %edx,%eax
c010343b:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    list_add_before(&free_list, &(base->page_link));
c0103440:	8b 45 08             	mov    0x8(%ebp),%eax
c0103443:	83 c0 0c             	add    $0xc,%eax
c0103446:	c7 45 e4 84 6f 12 c0 	movl   $0xc0126f84,-0x1c(%ebp)
c010344d:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103450:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103453:	8b 00                	mov    (%eax),%eax
c0103455:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103458:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010345b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010345e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103464:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103467:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010346a:	89 10                	mov    %edx,(%eax)
c010346c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010346f:	8b 10                	mov    (%eax),%edx
c0103471:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103474:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103477:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010347a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010347d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103480:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103483:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103486:	89 10                	mov    %edx,(%eax)
}
c0103488:	90                   	nop
}
c0103489:	90                   	nop
}
c010348a:	90                   	nop
c010348b:	89 ec                	mov    %ebp,%esp
c010348d:	5d                   	pop    %ebp
c010348e:	c3                   	ret    

c010348f <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n)
{
c010348f:	55                   	push   %ebp
c0103490:	89 e5                	mov    %esp,%ebp
c0103492:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0103495:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103499:	75 24                	jne    c01034bf <default_alloc_pages+0x30>
c010349b:	c7 44 24 0c d0 98 10 	movl   $0xc01098d0,0xc(%esp)
c01034a2:	c0 
c01034a3:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01034aa:	c0 
c01034ab:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c01034b2:	00 
c01034b3:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01034ba:	e8 2e d8 ff ff       	call   c0100ced <__panic>
    if (n > nr_free)
c01034bf:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c01034c4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01034c7:	76 0a                	jbe    c01034d3 <default_alloc_pages+0x44>
    {
        return NULL;
c01034c9:	b8 00 00 00 00       	mov    $0x0,%eax
c01034ce:	e9 5e 01 00 00       	jmp    c0103631 <default_alloc_pages+0x1a2>
    }
    struct Page *page = NULL;
c01034d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01034da:	c7 45 f0 84 6f 12 c0 	movl   $0xc0126f84,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list)
c01034e1:	eb 1c                	jmp    c01034ff <default_alloc_pages+0x70>
    {
        struct Page *p = le2page(le, page_link);
c01034e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034e6:	83 e8 0c             	sub    $0xc,%eax
c01034e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n)
c01034ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034ef:	8b 40 08             	mov    0x8(%eax),%eax
c01034f2:	39 45 08             	cmp    %eax,0x8(%ebp)
c01034f5:	77 08                	ja     c01034ff <default_alloc_pages+0x70>
        {
            page = p;
c01034f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01034fd:	eb 18                	jmp    c0103517 <default_alloc_pages+0x88>
c01034ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0103505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103508:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c010350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010350e:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c0103515:	75 cc                	jne    c01034e3 <default_alloc_pages+0x54>
        }
    }
    if (page != NULL)
c0103517:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010351b:	0f 84 0d 01 00 00    	je     c010362e <default_alloc_pages+0x19f>
    {
        if (page->property > n)
c0103521:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103524:	8b 40 08             	mov    0x8(%eax),%eax
c0103527:	39 45 08             	cmp    %eax,0x8(%ebp)
c010352a:	0f 83 aa 00 00 00    	jae    c01035da <default_alloc_pages+0x14b>
        {
            struct Page *p = page + n;
c0103530:	8b 45 08             	mov    0x8(%ebp),%eax
c0103533:	c1 e0 05             	shl    $0x5,%eax
c0103536:	89 c2                	mov    %eax,%edx
c0103538:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010353b:	01 d0                	add    %edx,%eax
c010353d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0103540:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103543:	8b 40 08             	mov    0x8(%eax),%eax
c0103546:	2b 45 08             	sub    0x8(%ebp),%eax
c0103549:	89 c2                	mov    %eax,%edx
c010354b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010354e:	89 50 08             	mov    %edx,0x8(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103551:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103554:	83 c0 0c             	add    $0xc,%eax
c0103557:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010355a:	83 c2 0c             	add    $0xc,%edx
c010355d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103560:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103563:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103566:	8b 40 04             	mov    0x4(%eax),%eax
c0103569:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010356c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c010356f:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103572:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103575:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c0103578:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010357b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010357e:	89 10                	mov    %edx,(%eax)
c0103580:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103583:	8b 10                	mov    (%eax),%edx
c0103585:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103588:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010358b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010358e:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103591:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103594:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103597:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010359a:	89 10                	mov    %edx,(%eax)
}
c010359c:	90                   	nop
}
c010359d:	90                   	nop
            //---------------------------------
            PageReserved(page);
c010359e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a1:	83 c0 04             	add    $0x4,%eax
c01035a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
c01035ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01035b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01035b4:	0f a3 10             	bt     %edx,(%eax)
c01035b7:	19 c0                	sbb    %eax,%eax
c01035b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c01035bc:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
            SetPageProperty(p);
c01035c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035c3:	83 c0 04             	add    $0x4,%eax
c01035c6:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01035cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01035d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01035d3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035d6:	0f ab 10             	bts    %edx,(%eax)
}
c01035d9:	90                   	nop
            //---------------------------------
        }
        list_del(&(page->page_link));
c01035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035dd:	83 c0 0c             	add    $0xc,%eax
c01035e0:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c01035e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035e6:	8b 40 04             	mov    0x4(%eax),%eax
c01035e9:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01035ec:	8b 12                	mov    (%edx),%edx
c01035ee:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01035f1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01035f4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01035f7:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01035fa:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01035fd:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103600:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103603:	89 10                	mov    %edx,(%eax)
}
c0103605:	90                   	nop
}
c0103606:	90                   	nop
        nr_free -= n;
c0103607:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c010360c:	2b 45 08             	sub    0x8(%ebp),%eax
c010360f:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
        ClearPageProperty(page);
c0103614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103617:	83 c0 04             	add    $0x4,%eax
c010361a:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103621:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103624:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103627:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010362a:	0f b3 10             	btr    %edx,(%eax)
}
c010362d:	90                   	nop
    }
    return page;
c010362e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103631:	89 ec                	mov    %ebp,%esp
c0103633:	5d                   	pop    %ebp
c0103634:	c3                   	ret    

c0103635 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n)
{
c0103635:	55                   	push   %ebp
c0103636:	89 e5                	mov    %esp,%ebp
c0103638:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010363e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103642:	75 24                	jne    c0103668 <default_free_pages+0x33>
c0103644:	c7 44 24 0c d0 98 10 	movl   $0xc01098d0,0xc(%esp)
c010364b:	c0 
c010364c:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103653:	c0 
c0103654:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
c010365b:	00 
c010365c:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103663:	e8 85 d6 ff ff       	call   c0100ced <__panic>
    struct Page *p = base;
c0103668:	8b 45 08             	mov    0x8(%ebp),%eax
c010366b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p++)
c010366e:	e9 9d 00 00 00       	jmp    c0103710 <default_free_pages+0xdb>
    {
        assert(!PageReserved(p) && !PageProperty(p));
c0103673:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103676:	83 c0 04             	add    $0x4,%eax
c0103679:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0103680:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103683:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103686:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103689:	0f a3 10             	bt     %edx,(%eax)
c010368c:	19 c0                	sbb    %eax,%eax
c010368e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c0103691:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103695:	0f 95 c0             	setne  %al
c0103698:	0f b6 c0             	movzbl %al,%eax
c010369b:	85 c0                	test   %eax,%eax
c010369d:	75 2c                	jne    c01036cb <default_free_pages+0x96>
c010369f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a2:	83 c0 04             	add    $0x4,%eax
c01036a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c01036ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01036b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01036b5:	0f a3 10             	bt     %edx,(%eax)
c01036b8:	19 c0                	sbb    %eax,%eax
c01036ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
    return oldbit != 0;
c01036bd:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01036c1:	0f 95 c0             	setne  %al
c01036c4:	0f b6 c0             	movzbl %al,%eax
c01036c7:	85 c0                	test   %eax,%eax
c01036c9:	74 24                	je     c01036ef <default_free_pages+0xba>
c01036cb:	c7 44 24 0c 14 99 10 	movl   $0xc0109914,0xc(%esp)
c01036d2:	c0 
c01036d3:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01036da:	c0 
c01036db:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
c01036e2:	00 
c01036e3:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01036ea:	e8 fe d5 ff ff       	call   c0100ced <__panic>
        p->flags = 0;
c01036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01036f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103700:	00 
c0103701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103704:	89 04 24             	mov    %eax,(%esp)
c0103707:	e8 f7 fb ff ff       	call   c0103303 <set_page_ref>
    for (; p != base + n; p++)
c010370c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103710:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103713:	c1 e0 05             	shl    $0x5,%eax
c0103716:	89 c2                	mov    %eax,%edx
c0103718:	8b 45 08             	mov    0x8(%ebp),%eax
c010371b:	01 d0                	add    %edx,%eax
c010371d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103720:	0f 85 4d ff ff ff    	jne    c0103673 <default_free_pages+0x3e>
    }
    base->property = n;
c0103726:	8b 45 08             	mov    0x8(%ebp),%eax
c0103729:	8b 55 0c             	mov    0xc(%ebp),%edx
c010372c:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010372f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103732:	83 c0 04             	add    $0x4,%eax
c0103735:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c010373c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010373f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103742:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103745:	0f ab 10             	bts    %edx,(%eax)
}
c0103748:	90                   	nop
c0103749:	c7 45 cc 84 6f 12 c0 	movl   $0xc0126f84,-0x34(%ebp)
    return listelm->next;
c0103750:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103753:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list), *sp = NULL;
c0103756:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103759:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    bool flag = 0;
c0103760:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != &free_list)
c0103767:	e9 39 01 00 00       	jmp    c01038a5 <default_free_pages+0x270>
    {
        // sp = le;
        p = le2page(le, page_link);
c010376c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010376f:	83 e8 0c             	sub    $0xc,%eax
c0103772:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property == p)
c0103775:	8b 45 08             	mov    0x8(%ebp),%eax
c0103778:	8b 40 08             	mov    0x8(%eax),%eax
c010377b:	c1 e0 05             	shl    $0x5,%eax
c010377e:	89 c2                	mov    %eax,%edx
c0103780:	8b 45 08             	mov    0x8(%ebp),%eax
c0103783:	01 d0                	add    %edx,%eax
c0103785:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103788:	75 5f                	jne    c01037e9 <default_free_pages+0x1b4>
        {
            base->property += p->property;
c010378a:	8b 45 08             	mov    0x8(%ebp),%eax
c010378d:	8b 50 08             	mov    0x8(%eax),%edx
c0103790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103793:	8b 40 08             	mov    0x8(%eax),%eax
c0103796:	01 c2                	add    %eax,%edx
c0103798:	8b 45 08             	mov    0x8(%ebp),%eax
c010379b:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010379e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037a1:	83 c0 04             	add    $0x4,%eax
c01037a4:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01037ab:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037ae:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01037b1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01037b4:	0f b3 10             	btr    %edx,(%eax)
}
c01037b7:	90                   	nop
            list_del(&(p->page_link));
c01037b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037bb:	83 c0 0c             	add    $0xc,%eax
c01037be:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c01037c1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01037c4:	8b 40 04             	mov    0x4(%eax),%eax
c01037c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01037ca:	8b 12                	mov    (%edx),%edx
c01037cc:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01037cf:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c01037d2:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01037d5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01037d8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01037db:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01037de:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01037e1:	89 10                	mov    %edx,(%eax)
}
c01037e3:	90                   	nop
}
c01037e4:	e9 8b 00 00 00       	jmp    c0103874 <default_free_pages+0x23f>
        }
        else if (p + p->property == base)
c01037e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037ec:	8b 40 08             	mov    0x8(%eax),%eax
c01037ef:	c1 e0 05             	shl    $0x5,%eax
c01037f2:	89 c2                	mov    %eax,%edx
c01037f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037f7:	01 d0                	add    %edx,%eax
c01037f9:	39 45 08             	cmp    %eax,0x8(%ebp)
c01037fc:	75 76                	jne    c0103874 <default_free_pages+0x23f>
        {
            p->property += base->property;
c01037fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103801:	8b 50 08             	mov    0x8(%eax),%edx
c0103804:	8b 45 08             	mov    0x8(%ebp),%eax
c0103807:	8b 40 08             	mov    0x8(%eax),%eax
c010380a:	01 c2                	add    %eax,%edx
c010380c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010380f:	89 50 08             	mov    %edx,0x8(%eax)
c0103812:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103815:	89 45 98             	mov    %eax,-0x68(%ebp)
    return listelm->prev;
c0103818:	8b 45 98             	mov    -0x68(%ebp),%eax
c010381b:	8b 00                	mov    (%eax),%eax
            sp = list_prev(le);
c010381d:	89 45 ec             	mov    %eax,-0x14(%ebp)
            flag = 1;
c0103820:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
            ClearPageProperty(base);
c0103827:	8b 45 08             	mov    0x8(%ebp),%eax
c010382a:	83 c0 04             	add    $0x4,%eax
c010382d:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103834:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103837:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010383a:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010383d:	0f b3 10             	btr    %edx,(%eax)
}
c0103840:	90                   	nop
            base = p;
c0103841:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103844:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103847:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010384a:	83 c0 0c             	add    $0xc,%eax
c010384d:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103850:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103853:	8b 40 04             	mov    0x4(%eax),%eax
c0103856:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103859:	8b 12                	mov    (%edx),%edx
c010385b:	89 55 a8             	mov    %edx,-0x58(%ebp)
c010385e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c0103861:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103864:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103867:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010386a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010386d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103870:	89 10                	mov    %edx,(%eax)
}
c0103872:	90                   	nop
}
c0103873:	90                   	nop
        }
        if (p + p->property < base)
c0103874:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103877:	8b 40 08             	mov    0x8(%eax),%eax
c010387a:	c1 e0 05             	shl    $0x5,%eax
c010387d:	89 c2                	mov    %eax,%edx
c010387f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103882:	01 d0                	add    %edx,%eax
c0103884:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103887:	76 0d                	jbe    c0103896 <default_free_pages+0x261>
            sp = le, flag = 1;
c0103889:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010388c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010388f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0103896:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103899:	89 45 94             	mov    %eax,-0x6c(%ebp)
    return listelm->next;
c010389c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010389f:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01038a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list)
c01038a5:	81 7d f0 84 6f 12 c0 	cmpl   $0xc0126f84,-0x10(%ebp)
c01038ac:	0f 85 ba fe ff ff    	jne    c010376c <default_free_pages+0x137>
    }
    nr_free += n;
c01038b2:	8b 15 8c 6f 12 c0    	mov    0xc0126f8c,%edx
c01038b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038bb:	01 d0                	add    %edx,%eax
c01038bd:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
    //cprintf("%x %x\n", sp, &free_list);
    list_add((flag ? sp : &free_list), &(base->page_link));
c01038c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c5:	8d 50 0c             	lea    0xc(%eax),%edx
c01038c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01038cc:	74 05                	je     c01038d3 <default_free_pages+0x29e>
c01038ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038d1:	eb 05                	jmp    c01038d8 <default_free_pages+0x2a3>
c01038d3:	b8 84 6f 12 c0       	mov    $0xc0126f84,%eax
c01038d8:	89 45 90             	mov    %eax,-0x70(%ebp)
c01038db:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01038de:	8b 45 90             	mov    -0x70(%ebp),%eax
c01038e1:	89 45 88             	mov    %eax,-0x78(%ebp)
c01038e4:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01038e7:	89 45 84             	mov    %eax,-0x7c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01038ea:	8b 45 88             	mov    -0x78(%ebp),%eax
c01038ed:	8b 40 04             	mov    0x4(%eax),%eax
c01038f0:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01038f3:	89 55 80             	mov    %edx,-0x80(%ebp)
c01038f6:	8b 55 88             	mov    -0x78(%ebp),%edx
c01038f9:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c01038ff:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
    prev->next = next->prev = elm;
c0103905:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c010390b:	8b 55 80             	mov    -0x80(%ebp),%edx
c010390e:	89 10                	mov    %edx,(%eax)
c0103910:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103916:	8b 10                	mov    (%eax),%edx
c0103918:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c010391e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103921:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103924:	8b 95 78 ff ff ff    	mov    -0x88(%ebp),%edx
c010392a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010392d:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103930:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103936:	89 10                	mov    %edx,(%eax)
}
c0103938:	90                   	nop
}
c0103939:	90                   	nop
}
c010393a:	90                   	nop
}
c010393b:	90                   	nop
c010393c:	89 ec                	mov    %ebp,%esp
c010393e:	5d                   	pop    %ebp
c010393f:	c3                   	ret    

c0103940 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
c0103940:	55                   	push   %ebp
c0103941:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103943:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
}
c0103948:	5d                   	pop    %ebp
c0103949:	c3                   	ret    

c010394a <basic_check>:

static void
basic_check(void)
{
c010394a:	55                   	push   %ebp
c010394b:	89 e5                	mov    %esp,%ebp
c010394d:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103957:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010395a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103960:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103963:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010396a:	e8 8e 0f 00 00       	call   c01048fd <alloc_pages>
c010396f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103972:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103976:	75 24                	jne    c010399c <basic_check+0x52>
c0103978:	c7 44 24 0c 39 99 10 	movl   $0xc0109939,0xc(%esp)
c010397f:	c0 
c0103980:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103987:	c0 
c0103988:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010398f:	00 
c0103990:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103997:	e8 51 d3 ff ff       	call   c0100ced <__panic>
    assert((p1 = alloc_page()) != NULL);
c010399c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039a3:	e8 55 0f 00 00       	call   c01048fd <alloc_pages>
c01039a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01039af:	75 24                	jne    c01039d5 <basic_check+0x8b>
c01039b1:	c7 44 24 0c 55 99 10 	movl   $0xc0109955,0xc(%esp)
c01039b8:	c0 
c01039b9:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01039c0:	c0 
c01039c1:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01039c8:	00 
c01039c9:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01039d0:	e8 18 d3 ff ff       	call   c0100ced <__panic>
    assert((p2 = alloc_page()) != NULL);
c01039d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039dc:	e8 1c 0f 00 00       	call   c01048fd <alloc_pages>
c01039e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01039e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01039e8:	75 24                	jne    c0103a0e <basic_check+0xc4>
c01039ea:	c7 44 24 0c 71 99 10 	movl   $0xc0109971,0xc(%esp)
c01039f1:	c0 
c01039f2:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01039f9:	c0 
c01039fa:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103a01:	00 
c0103a02:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103a09:	e8 df d2 ff ff       	call   c0100ced <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103a0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a11:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103a14:	74 10                	je     c0103a26 <basic_check+0xdc>
c0103a16:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a1c:	74 08                	je     c0103a26 <basic_check+0xdc>
c0103a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a24:	75 24                	jne    c0103a4a <basic_check+0x100>
c0103a26:	c7 44 24 0c 90 99 10 	movl   $0xc0109990,0xc(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103a35:	c0 
c0103a36:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103a3d:	00 
c0103a3e:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103a45:	e8 a3 d2 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103a4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a4d:	89 04 24             	mov    %eax,(%esp)
c0103a50:	e8 a4 f8 ff ff       	call   c01032f9 <page_ref>
c0103a55:	85 c0                	test   %eax,%eax
c0103a57:	75 1e                	jne    c0103a77 <basic_check+0x12d>
c0103a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a5c:	89 04 24             	mov    %eax,(%esp)
c0103a5f:	e8 95 f8 ff ff       	call   c01032f9 <page_ref>
c0103a64:	85 c0                	test   %eax,%eax
c0103a66:	75 0f                	jne    c0103a77 <basic_check+0x12d>
c0103a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a6b:	89 04 24             	mov    %eax,(%esp)
c0103a6e:	e8 86 f8 ff ff       	call   c01032f9 <page_ref>
c0103a73:	85 c0                	test   %eax,%eax
c0103a75:	74 24                	je     c0103a9b <basic_check+0x151>
c0103a77:	c7 44 24 0c b4 99 10 	movl   $0xc01099b4,0xc(%esp)
c0103a7e:	c0 
c0103a7f:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103a86:	c0 
c0103a87:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0103a8e:	00 
c0103a8f:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103a96:	e8 52 d2 ff ff       	call   c0100ced <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103a9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a9e:	89 04 24             	mov    %eax,(%esp)
c0103aa1:	e8 3b f8 ff ff       	call   c01032e1 <page2pa>
c0103aa6:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103aac:	c1 e2 0c             	shl    $0xc,%edx
c0103aaf:	39 d0                	cmp    %edx,%eax
c0103ab1:	72 24                	jb     c0103ad7 <basic_check+0x18d>
c0103ab3:	c7 44 24 0c f0 99 10 	movl   $0xc01099f0,0xc(%esp)
c0103aba:	c0 
c0103abb:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103ac2:	c0 
c0103ac3:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103aca:	00 
c0103acb:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103ad2:	e8 16 d2 ff ff       	call   c0100ced <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ada:	89 04 24             	mov    %eax,(%esp)
c0103add:	e8 ff f7 ff ff       	call   c01032e1 <page2pa>
c0103ae2:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103ae8:	c1 e2 0c             	shl    $0xc,%edx
c0103aeb:	39 d0                	cmp    %edx,%eax
c0103aed:	72 24                	jb     c0103b13 <basic_check+0x1c9>
c0103aef:	c7 44 24 0c 0d 9a 10 	movl   $0xc0109a0d,0xc(%esp)
c0103af6:	c0 
c0103af7:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103afe:	c0 
c0103aff:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103b06:	00 
c0103b07:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103b0e:	e8 da d1 ff ff       	call   c0100ced <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b16:	89 04 24             	mov    %eax,(%esp)
c0103b19:	e8 c3 f7 ff ff       	call   c01032e1 <page2pa>
c0103b1e:	8b 15 a4 6f 12 c0    	mov    0xc0126fa4,%edx
c0103b24:	c1 e2 0c             	shl    $0xc,%edx
c0103b27:	39 d0                	cmp    %edx,%eax
c0103b29:	72 24                	jb     c0103b4f <basic_check+0x205>
c0103b2b:	c7 44 24 0c 2a 9a 10 	movl   $0xc0109a2a,0xc(%esp)
c0103b32:	c0 
c0103b33:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103b3a:	c0 
c0103b3b:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0103b42:	00 
c0103b43:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103b4a:	e8 9e d1 ff ff       	call   c0100ced <__panic>

    list_entry_t free_list_store = free_list;
c0103b4f:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0103b54:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0103b5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103b5d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103b60:	c7 45 dc 84 6f 12 c0 	movl   $0xc0126f84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103b67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103b6d:	89 50 04             	mov    %edx,0x4(%eax)
c0103b70:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b73:	8b 50 04             	mov    0x4(%eax),%edx
c0103b76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b79:	89 10                	mov    %edx,(%eax)
}
c0103b7b:	90                   	nop
c0103b7c:	c7 45 e0 84 6f 12 c0 	movl   $0xc0126f84,-0x20(%ebp)
    return list->next == list;
c0103b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b86:	8b 40 04             	mov    0x4(%eax),%eax
c0103b89:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103b8c:	0f 94 c0             	sete   %al
c0103b8f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103b92:	85 c0                	test   %eax,%eax
c0103b94:	75 24                	jne    c0103bba <basic_check+0x270>
c0103b96:	c7 44 24 0c 47 9a 10 	movl   $0xc0109a47,0xc(%esp)
c0103b9d:	c0 
c0103b9e:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103ba5:	c0 
c0103ba6:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c0103bad:	00 
c0103bae:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103bb5:	e8 33 d1 ff ff       	call   c0100ced <__panic>

    unsigned int nr_free_store = nr_free;
c0103bba:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103bbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103bc2:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0103bc9:	00 00 00 

    assert(alloc_page() == NULL);
c0103bcc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103bd3:	e8 25 0d 00 00       	call   c01048fd <alloc_pages>
c0103bd8:	85 c0                	test   %eax,%eax
c0103bda:	74 24                	je     c0103c00 <basic_check+0x2b6>
c0103bdc:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c0103be3:	c0 
c0103be4:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103beb:	c0 
c0103bec:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0103bf3:	00 
c0103bf4:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103bfb:	e8 ed d0 ff ff       	call   c0100ced <__panic>

    free_page(p0);
c0103c00:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c07:	00 
c0103c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c0b:	89 04 24             	mov    %eax,(%esp)
c0103c0e:	e8 57 0d 00 00       	call   c010496a <free_pages>
    free_page(p1);
c0103c13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c1a:	00 
c0103c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c1e:	89 04 24             	mov    %eax,(%esp)
c0103c21:	e8 44 0d 00 00       	call   c010496a <free_pages>
    free_page(p2);
c0103c26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c2d:	00 
c0103c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c31:	89 04 24             	mov    %eax,(%esp)
c0103c34:	e8 31 0d 00 00       	call   c010496a <free_pages>
    assert(nr_free == 3);
c0103c39:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103c3e:	83 f8 03             	cmp    $0x3,%eax
c0103c41:	74 24                	je     c0103c67 <basic_check+0x31d>
c0103c43:	c7 44 24 0c 73 9a 10 	movl   $0xc0109a73,0xc(%esp)
c0103c4a:	c0 
c0103c4b:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0103c5a:	00 
c0103c5b:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103c62:	e8 86 d0 ff ff       	call   c0100ced <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103c67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c6e:	e8 8a 0c 00 00       	call   c01048fd <alloc_pages>
c0103c73:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103c7a:	75 24                	jne    c0103ca0 <basic_check+0x356>
c0103c7c:	c7 44 24 0c 39 99 10 	movl   $0xc0109939,0xc(%esp)
c0103c83:	c0 
c0103c84:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103c8b:	c0 
c0103c8c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0103c93:	00 
c0103c94:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103c9b:	e8 4d d0 ff ff       	call   c0100ced <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103ca0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ca7:	e8 51 0c 00 00       	call   c01048fd <alloc_pages>
c0103cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103caf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cb3:	75 24                	jne    c0103cd9 <basic_check+0x38f>
c0103cb5:	c7 44 24 0c 55 99 10 	movl   $0xc0109955,0xc(%esp)
c0103cbc:	c0 
c0103cbd:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103cc4:	c0 
c0103cc5:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0103ccc:	00 
c0103ccd:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103cd4:	e8 14 d0 ff ff       	call   c0100ced <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ce0:	e8 18 0c 00 00       	call   c01048fd <alloc_pages>
c0103ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ce8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103cec:	75 24                	jne    c0103d12 <basic_check+0x3c8>
c0103cee:	c7 44 24 0c 71 99 10 	movl   $0xc0109971,0xc(%esp)
c0103cf5:	c0 
c0103cf6:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103cfd:	c0 
c0103cfe:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0103d05:	00 
c0103d06:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103d0d:	e8 db cf ff ff       	call   c0100ced <__panic>

    assert(alloc_page() == NULL);
c0103d12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d19:	e8 df 0b 00 00       	call   c01048fd <alloc_pages>
c0103d1e:	85 c0                	test   %eax,%eax
c0103d20:	74 24                	je     c0103d46 <basic_check+0x3fc>
c0103d22:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c0103d29:	c0 
c0103d2a:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103d31:	c0 
c0103d32:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0103d39:	00 
c0103d3a:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103d41:	e8 a7 cf ff ff       	call   c0100ced <__panic>

    free_page(p0);
c0103d46:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d4d:	00 
c0103d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103d51:	89 04 24             	mov    %eax,(%esp)
c0103d54:	e8 11 0c 00 00       	call   c010496a <free_pages>
c0103d59:	c7 45 d8 84 6f 12 c0 	movl   $0xc0126f84,-0x28(%ebp)
c0103d60:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103d63:	8b 40 04             	mov    0x4(%eax),%eax
c0103d66:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103d69:	0f 94 c0             	sete   %al
c0103d6c:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103d6f:	85 c0                	test   %eax,%eax
c0103d71:	74 24                	je     c0103d97 <basic_check+0x44d>
c0103d73:	c7 44 24 0c 80 9a 10 	movl   $0xc0109a80,0xc(%esp)
c0103d7a:	c0 
c0103d7b:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103d82:	c0 
c0103d83:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0103d8a:	00 
c0103d8b:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103d92:	e8 56 cf ff ff       	call   c0100ced <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103d97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d9e:	e8 5a 0b 00 00       	call   c01048fd <alloc_pages>
c0103da3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103da9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103dac:	74 24                	je     c0103dd2 <basic_check+0x488>
c0103dae:	c7 44 24 0c 98 9a 10 	movl   $0xc0109a98,0xc(%esp)
c0103db5:	c0 
c0103db6:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103dbd:	c0 
c0103dbe:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0103dc5:	00 
c0103dc6:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103dcd:	e8 1b cf ff ff       	call   c0100ced <__panic>
    assert(alloc_page() == NULL);
c0103dd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dd9:	e8 1f 0b 00 00       	call   c01048fd <alloc_pages>
c0103dde:	85 c0                	test   %eax,%eax
c0103de0:	74 24                	je     c0103e06 <basic_check+0x4bc>
c0103de2:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c0103de9:	c0 
c0103dea:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103df1:	c0 
c0103df2:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0103df9:	00 
c0103dfa:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103e01:	e8 e7 ce ff ff       	call   c0100ced <__panic>

    assert(nr_free == 0);
c0103e06:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0103e0b:	85 c0                	test   %eax,%eax
c0103e0d:	74 24                	je     c0103e33 <basic_check+0x4e9>
c0103e0f:	c7 44 24 0c b1 9a 10 	movl   $0xc0109ab1,0xc(%esp)
c0103e16:	c0 
c0103e17:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103e1e:	c0 
c0103e1f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0103e26:	00 
c0103e27:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103e2e:	e8 ba ce ff ff       	call   c0100ced <__panic>
    free_list = free_list_store;
c0103e33:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103e36:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103e39:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0103e3e:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    nr_free = nr_free_store;
c0103e44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e47:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_page(p);
c0103e4c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e53:	00 
c0103e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e57:	89 04 24             	mov    %eax,(%esp)
c0103e5a:	e8 0b 0b 00 00       	call   c010496a <free_pages>
    free_page(p1);
c0103e5f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e66:	00 
c0103e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e6a:	89 04 24             	mov    %eax,(%esp)
c0103e6d:	e8 f8 0a 00 00       	call   c010496a <free_pages>
    free_page(p2);
c0103e72:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e79:	00 
c0103e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e7d:	89 04 24             	mov    %eax,(%esp)
c0103e80:	e8 e5 0a 00 00       	call   c010496a <free_pages>
}
c0103e85:	90                   	nop
c0103e86:	89 ec                	mov    %ebp,%esp
c0103e88:	5d                   	pop    %ebp
c0103e89:	c3                   	ret    

c0103e8a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
c0103e8a:	55                   	push   %ebp
c0103e8b:	89 e5                	mov    %esp,%ebp
c0103e8d:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103e93:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103e9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103ea1:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c0103ea8:	eb 6a                	jmp    c0103f14 <default_check+0x8a>
    {
        struct Page *p = le2page(le, page_link);
c0103eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ead:	83 e8 0c             	sub    $0xc,%eax
c0103eb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103eb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103eb6:	83 c0 04             	add    $0x4,%eax
c0103eb9:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103ec0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103ec3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103ec6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103ec9:	0f a3 10             	bt     %edx,(%eax)
c0103ecc:	19 c0                	sbb    %eax,%eax
c0103ece:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103ed1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103ed5:	0f 95 c0             	setne  %al
c0103ed8:	0f b6 c0             	movzbl %al,%eax
c0103edb:	85 c0                	test   %eax,%eax
c0103edd:	75 24                	jne    c0103f03 <default_check+0x79>
c0103edf:	c7 44 24 0c be 9a 10 	movl   $0xc0109abe,0xc(%esp)
c0103ee6:	c0 
c0103ee7:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103eee:	c0 
c0103eef:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0103ef6:	00 
c0103ef7:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103efe:	e8 ea cd ff ff       	call   c0100ced <__panic>
        count++, total += p->property;
c0103f03:	ff 45 f4             	incl   -0xc(%ebp)
c0103f06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f09:	8b 50 08             	mov    0x8(%eax),%edx
c0103f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f0f:	01 d0                	add    %edx,%eax
c0103f11:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f14:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f17:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103f1a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f1d:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c0103f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103f23:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c0103f2a:	0f 85 7a ff ff ff    	jne    c0103eaa <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103f30:	e8 6a 0a 00 00       	call   c010499f <nr_free_pages>
c0103f35:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103f38:	39 d0                	cmp    %edx,%eax
c0103f3a:	74 24                	je     c0103f60 <default_check+0xd6>
c0103f3c:	c7 44 24 0c ce 9a 10 	movl   $0xc0109ace,0xc(%esp)
c0103f43:	c0 
c0103f44:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103f4b:	c0 
c0103f4c:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0103f53:	00 
c0103f54:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103f5b:	e8 8d cd ff ff       	call   c0100ced <__panic>

    basic_check();
c0103f60:	e8 e5 f9 ff ff       	call   c010394a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103f65:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103f6c:	e8 8c 09 00 00       	call   c01048fd <alloc_pages>
c0103f71:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0103f74:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103f78:	75 24                	jne    c0103f9e <default_check+0x114>
c0103f7a:	c7 44 24 0c e7 9a 10 	movl   $0xc0109ae7,0xc(%esp)
c0103f81:	c0 
c0103f82:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103f89:	c0 
c0103f8a:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103f91:	00 
c0103f92:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103f99:	e8 4f cd ff ff       	call   c0100ced <__panic>
    assert(!PageProperty(p0));
c0103f9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fa1:	83 c0 04             	add    $0x4,%eax
c0103fa4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103fab:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103fae:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103fb1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103fb4:	0f a3 10             	bt     %edx,(%eax)
c0103fb7:	19 c0                	sbb    %eax,%eax
c0103fb9:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103fbc:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103fc0:	0f 95 c0             	setne  %al
c0103fc3:	0f b6 c0             	movzbl %al,%eax
c0103fc6:	85 c0                	test   %eax,%eax
c0103fc8:	74 24                	je     c0103fee <default_check+0x164>
c0103fca:	c7 44 24 0c f2 9a 10 	movl   $0xc0109af2,0xc(%esp)
c0103fd1:	c0 
c0103fd2:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0103fd9:	c0 
c0103fda:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0103fe1:	00 
c0103fe2:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0103fe9:	e8 ff cc ff ff       	call   c0100ced <__panic>

    // simualte the situation that all memory is used
    list_entry_t free_list_store = free_list;
c0103fee:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0103ff3:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0103ff9:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103ffc:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103fff:	c7 45 b0 84 6f 12 c0 	movl   $0xc0126f84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0104006:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104009:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010400c:	89 50 04             	mov    %edx,0x4(%eax)
c010400f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104012:	8b 50 04             	mov    0x4(%eax),%edx
c0104015:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104018:	89 10                	mov    %edx,(%eax)
}
c010401a:	90                   	nop
c010401b:	c7 45 b4 84 6f 12 c0 	movl   $0xc0126f84,-0x4c(%ebp)
    return list->next == list;
c0104022:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104025:	8b 40 04             	mov    0x4(%eax),%eax
c0104028:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010402b:	0f 94 c0             	sete   %al
c010402e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104031:	85 c0                	test   %eax,%eax
c0104033:	75 24                	jne    c0104059 <default_check+0x1cf>
c0104035:	c7 44 24 0c 47 9a 10 	movl   $0xc0109a47,0xc(%esp)
c010403c:	c0 
c010403d:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104044:	c0 
c0104045:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c010404c:	00 
c010404d:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104054:	e8 94 cc ff ff       	call   c0100ced <__panic>
    assert(alloc_page() == NULL);
c0104059:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104060:	e8 98 08 00 00       	call   c01048fd <alloc_pages>
c0104065:	85 c0                	test   %eax,%eax
c0104067:	74 24                	je     c010408d <default_check+0x203>
c0104069:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c0104070:	c0 
c0104071:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104078:	c0 
c0104079:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0104080:	00 
c0104081:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104088:	e8 60 cc ff ff       	call   c0100ced <__panic>

    unsigned int nr_free_store = nr_free;
c010408d:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0104092:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0104095:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c010409c:	00 00 00 
    //--------------------------------------

    free_pages(p0 + 2, 3);
c010409f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040a2:	83 c0 40             	add    $0x40,%eax
c01040a5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01040ac:	00 
c01040ad:	89 04 24             	mov    %eax,(%esp)
c01040b0:	e8 b5 08 00 00       	call   c010496a <free_pages>
    assert(alloc_pages(4) == NULL);
c01040b5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01040bc:	e8 3c 08 00 00       	call   c01048fd <alloc_pages>
c01040c1:	85 c0                	test   %eax,%eax
c01040c3:	74 24                	je     c01040e9 <default_check+0x25f>
c01040c5:	c7 44 24 0c 04 9b 10 	movl   $0xc0109b04,0xc(%esp)
c01040cc:	c0 
c01040cd:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01040d4:	c0 
c01040d5:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01040dc:	00 
c01040dd:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01040e4:	e8 04 cc ff ff       	call   c0100ced <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01040e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040ec:	83 c0 40             	add    $0x40,%eax
c01040ef:	83 c0 04             	add    $0x4,%eax
c01040f2:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01040f9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01040fc:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01040ff:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104102:	0f a3 10             	bt     %edx,(%eax)
c0104105:	19 c0                	sbb    %eax,%eax
c0104107:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c010410a:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010410e:	0f 95 c0             	setne  %al
c0104111:	0f b6 c0             	movzbl %al,%eax
c0104114:	85 c0                	test   %eax,%eax
c0104116:	74 0e                	je     c0104126 <default_check+0x29c>
c0104118:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010411b:	83 c0 40             	add    $0x40,%eax
c010411e:	8b 40 08             	mov    0x8(%eax),%eax
c0104121:	83 f8 03             	cmp    $0x3,%eax
c0104124:	74 24                	je     c010414a <default_check+0x2c0>
c0104126:	c7 44 24 0c 1c 9b 10 	movl   $0xc0109b1c,0xc(%esp)
c010412d:	c0 
c010412e:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104135:	c0 
c0104136:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c010413d:	00 
c010413e:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104145:	e8 a3 cb ff ff       	call   c0100ced <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010414a:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104151:	e8 a7 07 00 00       	call   c01048fd <alloc_pages>
c0104156:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104159:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010415d:	75 24                	jne    c0104183 <default_check+0x2f9>
c010415f:	c7 44 24 0c 48 9b 10 	movl   $0xc0109b48,0xc(%esp)
c0104166:	c0 
c0104167:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c010416e:	c0 
c010416f:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0104176:	00 
c0104177:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c010417e:	e8 6a cb ff ff       	call   c0100ced <__panic>
    assert(alloc_page() == NULL);
c0104183:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010418a:	e8 6e 07 00 00       	call   c01048fd <alloc_pages>
c010418f:	85 c0                	test   %eax,%eax
c0104191:	74 24                	je     c01041b7 <default_check+0x32d>
c0104193:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c010419a:	c0 
c010419b:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01041a2:	c0 
c01041a3:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01041aa:	00 
c01041ab:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01041b2:	e8 36 cb ff ff       	call   c0100ced <__panic>
    assert(p0 + 2 == p1);
c01041b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041ba:	83 c0 40             	add    $0x40,%eax
c01041bd:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01041c0:	74 24                	je     c01041e6 <default_check+0x35c>
c01041c2:	c7 44 24 0c 66 9b 10 	movl   $0xc0109b66,0xc(%esp)
c01041c9:	c0 
c01041ca:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01041d1:	c0 
c01041d2:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01041d9:	00 
c01041da:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01041e1:	e8 07 cb ff ff       	call   c0100ced <__panic>

    p2 = p0 + 1;
c01041e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041e9:	83 c0 20             	add    $0x20,%eax
c01041ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01041ef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041f6:	00 
c01041f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041fa:	89 04 24             	mov    %eax,(%esp)
c01041fd:	e8 68 07 00 00       	call   c010496a <free_pages>
    free_pages(p1, 3);
c0104202:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104209:	00 
c010420a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010420d:	89 04 24             	mov    %eax,(%esp)
c0104210:	e8 55 07 00 00       	call   c010496a <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104215:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104218:	83 c0 04             	add    $0x4,%eax
c010421b:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104222:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104225:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104228:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010422b:	0f a3 10             	bt     %edx,(%eax)
c010422e:	19 c0                	sbb    %eax,%eax
c0104230:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104233:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104237:	0f 95 c0             	setne  %al
c010423a:	0f b6 c0             	movzbl %al,%eax
c010423d:	85 c0                	test   %eax,%eax
c010423f:	74 0b                	je     c010424c <default_check+0x3c2>
c0104241:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104244:	8b 40 08             	mov    0x8(%eax),%eax
c0104247:	83 f8 01             	cmp    $0x1,%eax
c010424a:	74 24                	je     c0104270 <default_check+0x3e6>
c010424c:	c7 44 24 0c 74 9b 10 	movl   $0xc0109b74,0xc(%esp)
c0104253:	c0 
c0104254:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c010425b:	c0 
c010425c:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c0104263:	00 
c0104264:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c010426b:	e8 7d ca ff ff       	call   c0100ced <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104270:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104273:	83 c0 04             	add    $0x4,%eax
c0104276:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010427d:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104280:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104283:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104286:	0f a3 10             	bt     %edx,(%eax)
c0104289:	19 c0                	sbb    %eax,%eax
c010428b:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010428e:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104292:	0f 95 c0             	setne  %al
c0104295:	0f b6 c0             	movzbl %al,%eax
c0104298:	85 c0                	test   %eax,%eax
c010429a:	74 0b                	je     c01042a7 <default_check+0x41d>
c010429c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010429f:	8b 40 08             	mov    0x8(%eax),%eax
c01042a2:	83 f8 03             	cmp    $0x3,%eax
c01042a5:	74 24                	je     c01042cb <default_check+0x441>
c01042a7:	c7 44 24 0c 9c 9b 10 	movl   $0xc0109b9c,0xc(%esp)
c01042ae:	c0 
c01042af:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01042b6:	c0 
c01042b7:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01042be:	00 
c01042bf:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01042c6:	e8 22 ca ff ff       	call   c0100ced <__panic>

    assert((p0 = alloc_page()) == p2 - 1); //!
c01042cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042d2:	e8 26 06 00 00       	call   c01048fd <alloc_pages>
c01042d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01042da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042dd:	83 e8 20             	sub    $0x20,%eax
c01042e0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01042e3:	74 24                	je     c0104309 <default_check+0x47f>
c01042e5:	c7 44 24 0c c2 9b 10 	movl   $0xc0109bc2,0xc(%esp)
c01042ec:	c0 
c01042ed:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01042f4:	c0 
c01042f5:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c01042fc:	00 
c01042fd:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104304:	e8 e4 c9 ff ff       	call   c0100ced <__panic>
    free_page(p0);
c0104309:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104310:	00 
c0104311:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104314:	89 04 24             	mov    %eax,(%esp)
c0104317:	e8 4e 06 00 00       	call   c010496a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010431c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104323:	e8 d5 05 00 00       	call   c01048fd <alloc_pages>
c0104328:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010432b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010432e:	83 c0 20             	add    $0x20,%eax
c0104331:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104334:	74 24                	je     c010435a <default_check+0x4d0>
c0104336:	c7 44 24 0c e0 9b 10 	movl   $0xc0109be0,0xc(%esp)
c010433d:	c0 
c010433e:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104345:	c0 
c0104346:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c010434d:	00 
c010434e:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104355:	e8 93 c9 ff ff       	call   c0100ced <__panic>

    free_pages(p0, 2);
c010435a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104361:	00 
c0104362:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104365:	89 04 24             	mov    %eax,(%esp)
c0104368:	e8 fd 05 00 00       	call   c010496a <free_pages>
    //test();
    free_page(p2);
c010436d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104374:	00 
c0104375:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104378:	89 04 24             	mov    %eax,(%esp)
c010437b:	e8 ea 05 00 00       	call   c010496a <free_pages>
    //test();

    assert((p0 = alloc_pages(5)) != NULL); //!
c0104380:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104387:	e8 71 05 00 00       	call   c01048fd <alloc_pages>
c010438c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010438f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104393:	75 24                	jne    c01043b9 <default_check+0x52f>
c0104395:	c7 44 24 0c 00 9c 10 	movl   $0xc0109c00,0xc(%esp)
c010439c:	c0 
c010439d:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01043a4:	c0 
c01043a5:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01043ac:	00 
c01043ad:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01043b4:	e8 34 c9 ff ff       	call   c0100ced <__panic>
    assert(alloc_page() == NULL);
c01043b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01043c0:	e8 38 05 00 00       	call   c01048fd <alloc_pages>
c01043c5:	85 c0                	test   %eax,%eax
c01043c7:	74 24                	je     c01043ed <default_check+0x563>
c01043c9:	c7 44 24 0c 5e 9a 10 	movl   $0xc0109a5e,0xc(%esp)
c01043d0:	c0 
c01043d1:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01043d8:	c0 
c01043d9:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01043e0:	00 
c01043e1:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01043e8:	e8 00 c9 ff ff       	call   c0100ced <__panic>

    assert(nr_free == 0);
c01043ed:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c01043f2:	85 c0                	test   %eax,%eax
c01043f4:	74 24                	je     c010441a <default_check+0x590>
c01043f6:	c7 44 24 0c b1 9a 10 	movl   $0xc0109ab1,0xc(%esp)
c01043fd:	c0 
c01043fe:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104405:	c0 
c0104406:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c010440d:	00 
c010440e:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104415:	e8 d3 c8 ff ff       	call   c0100ced <__panic>
    nr_free = nr_free_store;
c010441a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010441d:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c

    free_list = free_list_store;
c0104422:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104425:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104428:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c010442d:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88
    free_pages(p0, 5);
c0104433:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010443a:	00 
c010443b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010443e:	89 04 24             	mov    %eax,(%esp)
c0104441:	e8 24 05 00 00       	call   c010496a <free_pages>

    le = &free_list;
c0104446:	c7 45 ec 84 6f 12 c0 	movl   $0xc0126f84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list)
c010444d:	eb 5a                	jmp    c01044a9 <default_check+0x61f>
    {
        assert(le->next->prev == le && le->prev->next == le);
c010444f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104452:	8b 40 04             	mov    0x4(%eax),%eax
c0104455:	8b 00                	mov    (%eax),%eax
c0104457:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010445a:	75 0d                	jne    c0104469 <default_check+0x5df>
c010445c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010445f:	8b 00                	mov    (%eax),%eax
c0104461:	8b 40 04             	mov    0x4(%eax),%eax
c0104464:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104467:	74 24                	je     c010448d <default_check+0x603>
c0104469:	c7 44 24 0c 20 9c 10 	movl   $0xc0109c20,0xc(%esp)
c0104470:	c0 
c0104471:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104478:	c0 
c0104479:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
c0104480:	00 
c0104481:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104488:	e8 60 c8 ff ff       	call   c0100ced <__panic>
        struct Page *p = le2page(le, page_link);
c010448d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104490:	83 e8 0c             	sub    $0xc,%eax
c0104493:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count--, total -= p->property;
c0104496:	ff 4d f4             	decl   -0xc(%ebp)
c0104499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010449c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010449f:	8b 48 08             	mov    0x8(%eax),%ecx
c01044a2:	89 d0                	mov    %edx,%eax
c01044a4:	29 c8                	sub    %ecx,%eax
c01044a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044ac:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c01044af:	8b 45 88             	mov    -0x78(%ebp),%eax
c01044b2:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list)
c01044b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044b8:	81 7d ec 84 6f 12 c0 	cmpl   $0xc0126f84,-0x14(%ebp)
c01044bf:	75 8e                	jne    c010444f <default_check+0x5c5>
    }
    assert(count == 0);
c01044c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044c5:	74 24                	je     c01044eb <default_check+0x661>
c01044c7:	c7 44 24 0c 4d 9c 10 	movl   $0xc0109c4d,0xc(%esp)
c01044ce:	c0 
c01044cf:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c01044d6:	c0 
c01044d7:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c01044de:	00 
c01044df:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c01044e6:	e8 02 c8 ff ff       	call   c0100ced <__panic>
    assert(total == 0);
c01044eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044ef:	74 24                	je     c0104515 <default_check+0x68b>
c01044f1:	c7 44 24 0c 58 9c 10 	movl   $0xc0109c58,0xc(%esp)
c01044f8:	c0 
c01044f9:	c7 44 24 08 d6 98 10 	movl   $0xc01098d6,0x8(%esp)
c0104500:	c0 
c0104501:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0104508:	00 
c0104509:	c7 04 24 eb 98 10 c0 	movl   $0xc01098eb,(%esp)
c0104510:	e8 d8 c7 ff ff       	call   c0100ced <__panic>
}
c0104515:	90                   	nop
c0104516:	89 ec                	mov    %ebp,%esp
c0104518:	5d                   	pop    %ebp
c0104519:	c3                   	ret    

c010451a <test>:
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

static void test(void)
{   //我自己写的
c010451a:	55                   	push   %ebp
c010451b:	89 e5                	mov    %esp,%ebp
c010451d:	83 ec 28             	sub    $0x28,%esp
c0104520:	c7 45 f0 84 6f 12 c0 	movl   $0xc0126f84,-0x10(%ebp)
c0104527:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010452a:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010452d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c0104530:	eb 32                	jmp    c0104564 <test+0x4a>
    {
        cprintf("%x %d  ", le2page(le, page_link), le2page(le, page_link)->property);
c0104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104535:	83 e8 0c             	sub    $0xc,%eax
c0104538:	8b 40 08             	mov    0x8(%eax),%eax
c010453b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010453e:	83 ea 0c             	sub    $0xc,%edx
c0104541:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104545:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104549:	c7 04 24 94 9c 10 c0 	movl   $0xc0109c94,(%esp)
c0104550:	e8 10 be ff ff       	call   c0100365 <cprintf>
c0104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104558:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010455b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010455e:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104561:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != &free_list)
c0104564:	81 7d f4 84 6f 12 c0 	cmpl   $0xc0126f84,-0xc(%ebp)
c010456b:	75 c5                	jne    c0104532 <test+0x18>
    }
    cprintf("\n");
c010456d:	c7 04 24 9c 9c 10 c0 	movl   $0xc0109c9c,(%esp)
c0104574:	e8 ec bd ff ff       	call   c0100365 <cprintf>
}
c0104579:	90                   	nop
c010457a:	89 ec                	mov    %ebp,%esp
c010457c:	5d                   	pop    %ebp
c010457d:	c3                   	ret    

c010457e <page2ppn>:
page2ppn(struct Page *page) {
c010457e:	55                   	push   %ebp
c010457f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104581:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104587:	8b 45 08             	mov    0x8(%ebp),%eax
c010458a:	29 d0                	sub    %edx,%eax
c010458c:	c1 f8 05             	sar    $0x5,%eax
}
c010458f:	5d                   	pop    %ebp
c0104590:	c3                   	ret    

c0104591 <page2pa>:
page2pa(struct Page *page) {
c0104591:	55                   	push   %ebp
c0104592:	89 e5                	mov    %esp,%ebp
c0104594:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104597:	8b 45 08             	mov    0x8(%ebp),%eax
c010459a:	89 04 24             	mov    %eax,(%esp)
c010459d:	e8 dc ff ff ff       	call   c010457e <page2ppn>
c01045a2:	c1 e0 0c             	shl    $0xc,%eax
}
c01045a5:	89 ec                	mov    %ebp,%esp
c01045a7:	5d                   	pop    %ebp
c01045a8:	c3                   	ret    

c01045a9 <pa2page>:
pa2page(uintptr_t pa) {
c01045a9:	55                   	push   %ebp
c01045aa:	89 e5                	mov    %esp,%ebp
c01045ac:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01045af:	8b 45 08             	mov    0x8(%ebp),%eax
c01045b2:	c1 e8 0c             	shr    $0xc,%eax
c01045b5:	89 c2                	mov    %eax,%edx
c01045b7:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01045bc:	39 c2                	cmp    %eax,%edx
c01045be:	72 1c                	jb     c01045dc <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01045c0:	c7 44 24 08 a0 9c 10 	movl   $0xc0109ca0,0x8(%esp)
c01045c7:	c0 
c01045c8:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01045cf:	00 
c01045d0:	c7 04 24 bf 9c 10 c0 	movl   $0xc0109cbf,(%esp)
c01045d7:	e8 11 c7 ff ff       	call   c0100ced <__panic>
    return &pages[PPN(pa)];
c01045dc:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c01045e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01045e5:	c1 e8 0c             	shr    $0xc,%eax
c01045e8:	c1 e0 05             	shl    $0x5,%eax
c01045eb:	01 d0                	add    %edx,%eax
}
c01045ed:	89 ec                	mov    %ebp,%esp
c01045ef:	5d                   	pop    %ebp
c01045f0:	c3                   	ret    

c01045f1 <page2kva>:
page2kva(struct Page *page) {
c01045f1:	55                   	push   %ebp
c01045f2:	89 e5                	mov    %esp,%ebp
c01045f4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01045f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01045fa:	89 04 24             	mov    %eax,(%esp)
c01045fd:	e8 8f ff ff ff       	call   c0104591 <page2pa>
c0104602:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104608:	c1 e8 0c             	shr    $0xc,%eax
c010460b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010460e:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104613:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104616:	72 23                	jb     c010463b <page2kva+0x4a>
c0104618:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010461f:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c0104626:	c0 
c0104627:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010462e:	00 
c010462f:	c7 04 24 bf 9c 10 c0 	movl   $0xc0109cbf,(%esp)
c0104636:	e8 b2 c6 ff ff       	call   c0100ced <__panic>
c010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010463e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104643:	89 ec                	mov    %ebp,%esp
c0104645:	5d                   	pop    %ebp
c0104646:	c3                   	ret    

c0104647 <kva2page>:
kva2page(void *kva) {
c0104647:	55                   	push   %ebp
c0104648:	89 e5                	mov    %esp,%ebp
c010464a:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010464d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104650:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104653:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010465a:	77 23                	ja     c010467f <kva2page+0x38>
c010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010465f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104663:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c010466a:	c0 
c010466b:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104672:	00 
c0104673:	c7 04 24 bf 9c 10 c0 	movl   $0xc0109cbf,(%esp)
c010467a:	e8 6e c6 ff ff       	call   c0100ced <__panic>
c010467f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104682:	05 00 00 00 40       	add    $0x40000000,%eax
c0104687:	89 04 24             	mov    %eax,(%esp)
c010468a:	e8 1a ff ff ff       	call   c01045a9 <pa2page>
}
c010468f:	89 ec                	mov    %ebp,%esp
c0104691:	5d                   	pop    %ebp
c0104692:	c3                   	ret    

c0104693 <pte2page>:
pte2page(pte_t pte) {
c0104693:	55                   	push   %ebp
c0104694:	89 e5                	mov    %esp,%ebp
c0104696:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104699:	8b 45 08             	mov    0x8(%ebp),%eax
c010469c:	83 e0 01             	and    $0x1,%eax
c010469f:	85 c0                	test   %eax,%eax
c01046a1:	75 1c                	jne    c01046bf <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01046a3:	c7 44 24 08 18 9d 10 	movl   $0xc0109d18,0x8(%esp)
c01046aa:	c0 
c01046ab:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01046b2:	00 
c01046b3:	c7 04 24 bf 9c 10 c0 	movl   $0xc0109cbf,(%esp)
c01046ba:	e8 2e c6 ff ff       	call   c0100ced <__panic>
    return pa2page(PTE_ADDR(pte));
c01046bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01046c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01046c7:	89 04 24             	mov    %eax,(%esp)
c01046ca:	e8 da fe ff ff       	call   c01045a9 <pa2page>
}
c01046cf:	89 ec                	mov    %ebp,%esp
c01046d1:	5d                   	pop    %ebp
c01046d2:	c3                   	ret    

c01046d3 <pde2page>:
pde2page(pde_t pde) {
c01046d3:	55                   	push   %ebp
c01046d4:	89 e5                	mov    %esp,%ebp
c01046d6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01046d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01046e1:	89 04 24             	mov    %eax,(%esp)
c01046e4:	e8 c0 fe ff ff       	call   c01045a9 <pa2page>
}
c01046e9:	89 ec                	mov    %ebp,%esp
c01046eb:	5d                   	pop    %ebp
c01046ec:	c3                   	ret    

c01046ed <page_ref>:
page_ref(struct Page *page) {
c01046ed:	55                   	push   %ebp
c01046ee:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01046f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01046f3:	8b 00                	mov    (%eax),%eax
}
c01046f5:	5d                   	pop    %ebp
c01046f6:	c3                   	ret    

c01046f7 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01046f7:	55                   	push   %ebp
c01046f8:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01046fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01046fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104700:	89 10                	mov    %edx,(%eax)
}
c0104702:	90                   	nop
c0104703:	5d                   	pop    %ebp
c0104704:	c3                   	ret    

c0104705 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104705:	55                   	push   %ebp
c0104706:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104708:	8b 45 08             	mov    0x8(%ebp),%eax
c010470b:	8b 00                	mov    (%eax),%eax
c010470d:	8d 50 01             	lea    0x1(%eax),%edx
c0104710:	8b 45 08             	mov    0x8(%ebp),%eax
c0104713:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104715:	8b 45 08             	mov    0x8(%ebp),%eax
c0104718:	8b 00                	mov    (%eax),%eax
}
c010471a:	5d                   	pop    %ebp
c010471b:	c3                   	ret    

c010471c <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010471c:	55                   	push   %ebp
c010471d:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010471f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104722:	8b 00                	mov    (%eax),%eax
c0104724:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104727:	8b 45 08             	mov    0x8(%ebp),%eax
c010472a:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010472c:	8b 45 08             	mov    0x8(%ebp),%eax
c010472f:	8b 00                	mov    (%eax),%eax
}
c0104731:	5d                   	pop    %ebp
c0104732:	c3                   	ret    

c0104733 <__intr_save>:
__intr_save(void) {
c0104733:	55                   	push   %ebp
c0104734:	89 e5                	mov    %esp,%ebp
c0104736:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104739:	9c                   	pushf  
c010473a:	58                   	pop    %eax
c010473b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010473e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104741:	25 00 02 00 00       	and    $0x200,%eax
c0104746:	85 c0                	test   %eax,%eax
c0104748:	74 0c                	je     c0104756 <__intr_save+0x23>
        intr_disable();
c010474a:	e8 54 d8 ff ff       	call   c0101fa3 <intr_disable>
        return 1;
c010474f:	b8 01 00 00 00       	mov    $0x1,%eax
c0104754:	eb 05                	jmp    c010475b <__intr_save+0x28>
    return 0;
c0104756:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010475b:	89 ec                	mov    %ebp,%esp
c010475d:	5d                   	pop    %ebp
c010475e:	c3                   	ret    

c010475f <__intr_restore>:
__intr_restore(bool flag) {
c010475f:	55                   	push   %ebp
c0104760:	89 e5                	mov    %esp,%ebp
c0104762:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104765:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104769:	74 05                	je     c0104770 <__intr_restore+0x11>
        intr_enable();
c010476b:	e8 2b d8 ff ff       	call   c0101f9b <intr_enable>
}
c0104770:	90                   	nop
c0104771:	89 ec                	mov    %ebp,%esp
c0104773:	5d                   	pop    %ebp
c0104774:	c3                   	ret    

c0104775 <lgdt>:
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd)
{
c0104775:	55                   	push   %ebp
c0104776:	89 e5                	mov    %esp,%ebp
    asm volatile("lgdt (%0)" ::"r"(pd));
c0104778:	8b 45 08             	mov    0x8(%ebp),%eax
c010477b:	0f 01 10             	lgdtl  (%eax)
    asm volatile("movw %%ax, %%gs" ::"a"(USER_DS));
c010477e:	b8 23 00 00 00       	mov    $0x23,%eax
c0104783:	8e e8                	mov    %eax,%gs
    asm volatile("movw %%ax, %%fs" ::"a"(USER_DS));
c0104785:	b8 23 00 00 00       	mov    $0x23,%eax
c010478a:	8e e0                	mov    %eax,%fs
    asm volatile("movw %%ax, %%es" ::"a"(KERNEL_DS));
c010478c:	b8 10 00 00 00       	mov    $0x10,%eax
c0104791:	8e c0                	mov    %eax,%es
    asm volatile("movw %%ax, %%ds" ::"a"(KERNEL_DS));
c0104793:	b8 10 00 00 00       	mov    $0x10,%eax
c0104798:	8e d8                	mov    %eax,%ds
    asm volatile("movw %%ax, %%ss" ::"a"(KERNEL_DS));
c010479a:	b8 10 00 00 00       	mov    $0x10,%eax
c010479f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile("ljmp %0, $1f\n 1:\n" ::"i"(KERNEL_CS));
c01047a1:	ea a8 47 10 c0 08 00 	ljmp   $0x8,$0xc01047a8
}
c01047a8:	90                   	nop
c01047a9:	5d                   	pop    %ebp
c01047aa:	c3                   	ret    

c01047ab <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void load_esp0(uintptr_t esp0)
{
c01047ab:	55                   	push   %ebp
c01047ac:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01047ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01047b1:	a3 c4 6f 12 c0       	mov    %eax,0xc0126fc4
}
c01047b6:	90                   	nop
c01047b7:	5d                   	pop    %ebp
c01047b8:	c3                   	ret    

c01047b9 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void)
{
c01047b9:	55                   	push   %ebp
c01047ba:	89 e5                	mov    %esp,%ebp
c01047bc:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01047bf:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c01047c4:	89 04 24             	mov    %eax,(%esp)
c01047c7:	e8 df ff ff ff       	call   c01047ab <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01047cc:	66 c7 05 c8 6f 12 c0 	movw   $0x10,0xc0126fc8
c01047d3:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01047d5:	66 c7 05 28 3a 12 c0 	movw   $0x68,0xc0123a28
c01047dc:	68 00 
c01047de:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c01047e3:	0f b7 c0             	movzwl %ax,%eax
c01047e6:	66 a3 2a 3a 12 c0    	mov    %ax,0xc0123a2a
c01047ec:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c01047f1:	c1 e8 10             	shr    $0x10,%eax
c01047f4:	a2 2c 3a 12 c0       	mov    %al,0xc0123a2c
c01047f9:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104800:	24 f0                	and    $0xf0,%al
c0104802:	0c 09                	or     $0x9,%al
c0104804:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104809:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c0104810:	24 ef                	and    $0xef,%al
c0104812:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104817:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c010481e:	24 9f                	and    $0x9f,%al
c0104820:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104825:	0f b6 05 2d 3a 12 c0 	movzbl 0xc0123a2d,%eax
c010482c:	0c 80                	or     $0x80,%al
c010482e:	a2 2d 3a 12 c0       	mov    %al,0xc0123a2d
c0104833:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c010483a:	24 f0                	and    $0xf0,%al
c010483c:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104841:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104848:	24 ef                	and    $0xef,%al
c010484a:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c010484f:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104856:	24 df                	and    $0xdf,%al
c0104858:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c010485d:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104864:	0c 40                	or     $0x40,%al
c0104866:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c010486b:	0f b6 05 2e 3a 12 c0 	movzbl 0xc0123a2e,%eax
c0104872:	24 7f                	and    $0x7f,%al
c0104874:	a2 2e 3a 12 c0       	mov    %al,0xc0123a2e
c0104879:	b8 c0 6f 12 c0       	mov    $0xc0126fc0,%eax
c010487e:	c1 e8 18             	shr    $0x18,%eax
c0104881:	a2 2f 3a 12 c0       	mov    %al,0xc0123a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104886:	c7 04 24 30 3a 12 c0 	movl   $0xc0123a30,(%esp)
c010488d:	e8 e3 fe ff ff       	call   c0104775 <lgdt>
c0104892:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104898:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c010489c:	0f 00 d8             	ltr    %ax
}
c010489f:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c01048a0:	90                   	nop
c01048a1:	89 ec                	mov    %ebp,%esp
c01048a3:	5d                   	pop    %ebp
c01048a4:	c3                   	ret    

c01048a5 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void)
{
c01048a5:	55                   	push   %ebp
c01048a6:	89 e5                	mov    %esp,%ebp
c01048a8:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01048ab:	c7 05 ac 6f 12 c0 78 	movl   $0xc0109c78,0xc0126fac
c01048b2:	9c 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01048b5:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01048ba:	8b 00                	mov    (%eax),%eax
c01048bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048c0:	c7 04 24 44 9d 10 c0 	movl   $0xc0109d44,(%esp)
c01048c7:	e8 99 ba ff ff       	call   c0100365 <cprintf>
    pmm_manager->init();
c01048cc:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01048d1:	8b 40 04             	mov    0x4(%eax),%eax
c01048d4:	ff d0                	call   *%eax
}
c01048d6:	90                   	nop
c01048d7:	89 ec                	mov    %ebp,%esp
c01048d9:	5d                   	pop    %ebp
c01048da:	c3                   	ret    

c01048db <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n)
{
c01048db:	55                   	push   %ebp
c01048dc:	89 e5                	mov    %esp,%ebp
c01048de:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01048e1:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01048e6:	8b 40 08             	mov    0x8(%eax),%eax
c01048e9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01048ec:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01048f3:	89 14 24             	mov    %edx,(%esp)
c01048f6:	ff d0                	call   *%eax
}
c01048f8:	90                   	nop
c01048f9:	89 ec                	mov    %ebp,%esp
c01048fb:	5d                   	pop    %ebp
c01048fc:	c3                   	ret    

c01048fd <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n)
{
c01048fd:	55                   	push   %ebp
c01048fe:	89 e5                	mov    %esp,%ebp
c0104900:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = NULL;
c0104903:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1)
    {
        local_intr_save(intr_flag);
c010490a:	e8 24 fe ff ff       	call   c0104733 <__intr_save>
c010490f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        {
            page = pmm_manager->alloc_pages(n);
c0104912:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c0104917:	8b 40 0c             	mov    0xc(%eax),%eax
c010491a:	8b 55 08             	mov    0x8(%ebp),%edx
c010491d:	89 14 24             	mov    %edx,(%esp)
c0104920:	ff d0                	call   *%eax
c0104922:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        local_intr_restore(intr_flag);
c0104925:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104928:	89 04 24             	mov    %eax,(%esp)
c010492b:	e8 2f fe ff ff       	call   c010475f <__intr_restore>

        if (page != NULL || n > 1 || swap_init_ok == 0)
c0104930:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104934:	75 2d                	jne    c0104963 <alloc_pages+0x66>
c0104936:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010493a:	77 27                	ja     c0104963 <alloc_pages+0x66>
c010493c:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0104941:	85 c0                	test   %eax,%eax
c0104943:	74 1e                	je     c0104963 <alloc_pages+0x66>
            break;

        extern struct mm_struct *check_mm_struct;
        //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
c0104945:	8b 55 08             	mov    0x8(%ebp),%edx
c0104948:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c010494d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104954:	00 
c0104955:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104959:	89 04 24             	mov    %eax,(%esp)
c010495c:	e8 05 1a 00 00       	call   c0106366 <swap_out>
    {
c0104961:	eb a7                	jmp    c010490a <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104966:	89 ec                	mov    %ebp,%esp
c0104968:	5d                   	pop    %ebp
c0104969:	c3                   	ret    

c010496a <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n)
{
c010496a:	55                   	push   %ebp
c010496b:	89 e5                	mov    %esp,%ebp
c010496d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0104970:	e8 be fd ff ff       	call   c0104733 <__intr_save>
c0104975:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104978:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c010497d:	8b 40 10             	mov    0x10(%eax),%eax
c0104980:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104983:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104987:	8b 55 08             	mov    0x8(%ebp),%edx
c010498a:	89 14 24             	mov    %edx,(%esp)
c010498d:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104992:	89 04 24             	mov    %eax,(%esp)
c0104995:	e8 c5 fd ff ff       	call   c010475f <__intr_restore>
}
c010499a:	90                   	nop
c010499b:	89 ec                	mov    %ebp,%esp
c010499d:	5d                   	pop    %ebp
c010499e:	c3                   	ret    

c010499f <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void)
{
c010499f:	55                   	push   %ebp
c01049a0:	89 e5                	mov    %esp,%ebp
c01049a2:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01049a5:	e8 89 fd ff ff       	call   c0104733 <__intr_save>
c01049aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01049ad:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01049b2:	8b 40 14             	mov    0x14(%eax),%eax
c01049b5:	ff d0                	call   *%eax
c01049b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01049ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049bd:	89 04 24             	mov    %eax,(%esp)
c01049c0:	e8 9a fd ff ff       	call   c010475f <__intr_restore>
    return ret;
c01049c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01049c8:	89 ec                	mov    %ebp,%esp
c01049ca:	5d                   	pop    %ebp
c01049cb:	c3                   	ret    

c01049cc <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void)
{
c01049cc:	55                   	push   %ebp
c01049cd:	89 e5                	mov    %esp,%ebp
c01049cf:	57                   	push   %edi
c01049d0:	56                   	push   %esi
c01049d1:	53                   	push   %ebx
c01049d2:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01049d8:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01049df:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01049e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01049ed:	c7 04 24 5b 9d 10 c0 	movl   $0xc0109d5b,(%esp)
c01049f4:	e8 6c b9 ff ff       	call   c0100365 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i++)
c01049f9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104a00:	e9 0c 01 00 00       	jmp    c0104b11 <page_init+0x145>
    {
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104a05:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a08:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a0b:	89 d0                	mov    %edx,%eax
c0104a0d:	c1 e0 02             	shl    $0x2,%eax
c0104a10:	01 d0                	add    %edx,%eax
c0104a12:	c1 e0 02             	shl    $0x2,%eax
c0104a15:	01 c8                	add    %ecx,%eax
c0104a17:	8b 50 08             	mov    0x8(%eax),%edx
c0104a1a:	8b 40 04             	mov    0x4(%eax),%eax
c0104a1d:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104a20:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104a23:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a26:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a29:	89 d0                	mov    %edx,%eax
c0104a2b:	c1 e0 02             	shl    $0x2,%eax
c0104a2e:	01 d0                	add    %edx,%eax
c0104a30:	c1 e0 02             	shl    $0x2,%eax
c0104a33:	01 c8                	add    %ecx,%eax
c0104a35:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a38:	8b 58 10             	mov    0x10(%eax),%ebx
c0104a3b:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104a3e:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104a41:	01 c8                	add    %ecx,%eax
c0104a43:	11 da                	adc    %ebx,%edx
c0104a45:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104a48:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104a4b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a51:	89 d0                	mov    %edx,%eax
c0104a53:	c1 e0 02             	shl    $0x2,%eax
c0104a56:	01 d0                	add    %edx,%eax
c0104a58:	c1 e0 02             	shl    $0x2,%eax
c0104a5b:	01 c8                	add    %ecx,%eax
c0104a5d:	83 c0 14             	add    $0x14,%eax
c0104a60:	8b 00                	mov    (%eax),%eax
c0104a62:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104a68:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104a6b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104a6e:	83 c0 ff             	add    $0xffffffff,%eax
c0104a71:	83 d2 ff             	adc    $0xffffffff,%edx
c0104a74:	89 c6                	mov    %eax,%esi
c0104a76:	89 d7                	mov    %edx,%edi
c0104a78:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a7e:	89 d0                	mov    %edx,%eax
c0104a80:	c1 e0 02             	shl    $0x2,%eax
c0104a83:	01 d0                	add    %edx,%eax
c0104a85:	c1 e0 02             	shl    $0x2,%eax
c0104a88:	01 c8                	add    %ecx,%eax
c0104a8a:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a8d:	8b 58 10             	mov    0x10(%eax),%ebx
c0104a90:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0104a96:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0104a9a:	89 74 24 14          	mov    %esi,0x14(%esp)
c0104a9e:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0104aa2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104aa5:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104aa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104aac:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104ab0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0104ab4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0104ab8:	c7 04 24 68 9d 10 c0 	movl   $0xc0109d68,(%esp)
c0104abf:	e8 a1 b8 ff ff       	call   c0100365 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM)
c0104ac4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104ac7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104aca:	89 d0                	mov    %edx,%eax
c0104acc:	c1 e0 02             	shl    $0x2,%eax
c0104acf:	01 d0                	add    %edx,%eax
c0104ad1:	c1 e0 02             	shl    $0x2,%eax
c0104ad4:	01 c8                	add    %ecx,%eax
c0104ad6:	83 c0 14             	add    $0x14,%eax
c0104ad9:	8b 00                	mov    (%eax),%eax
c0104adb:	83 f8 01             	cmp    $0x1,%eax
c0104ade:	75 2e                	jne    c0104b0e <page_init+0x142>
        {
            if (maxpa < end && begin < KMEMSIZE)
c0104ae0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ae3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104ae6:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0104ae9:	89 d0                	mov    %edx,%eax
c0104aeb:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0104aee:	73 1e                	jae    c0104b0e <page_init+0x142>
c0104af0:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104af5:	b8 00 00 00 00       	mov    $0x0,%eax
c0104afa:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0104afd:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0104b00:	72 0c                	jb     c0104b0e <page_init+0x142>
            {
                maxpa = end;
c0104b02:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b05:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b08:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104b0b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i++)
c0104b0e:	ff 45 dc             	incl   -0x24(%ebp)
c0104b11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b14:	8b 00                	mov    (%eax),%eax
c0104b16:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104b19:	0f 8c e6 fe ff ff    	jl     c0104a05 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE)
c0104b1f:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104b24:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b29:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0104b2c:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0104b2f:	73 0e                	jae    c0104b3f <page_init+0x173>
    {
        maxpa = KMEMSIZE;
c0104b31:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104b38:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }
    // generated by ld file
    extern char end[];

    npage = maxpa / PGSIZE;
c0104b3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104b45:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104b49:	c1 ea 0c             	shr    $0xc,%edx
c0104b4c:	a3 a4 6f 12 c0       	mov    %eax,0xc0126fa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0104b51:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104b58:	b8 14 71 12 c0       	mov    $0xc0127114,%eax
c0104b5d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104b60:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104b63:	01 d0                	add    %edx,%eax
c0104b65:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104b68:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b6b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b70:	f7 75 c0             	divl   -0x40(%ebp)
c0104b73:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b76:	29 d0                	sub    %edx,%eax
c0104b78:	a3 a0 6f 12 c0       	mov    %eax,0xc0126fa0

    for (i = 0; i < npage; i++)
c0104b7d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104b84:	eb 28                	jmp    c0104bae <page_init+0x1e2>
    {
        SetPageReserved(pages + i);
c0104b86:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0104b8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104b8f:	c1 e0 05             	shl    $0x5,%eax
c0104b92:	01 d0                	add    %edx,%eax
c0104b94:	83 c0 04             	add    $0x4,%eax
c0104b97:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0104b9e:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104ba1:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104ba4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104ba7:	0f ab 10             	bts    %edx,(%eax)
}
c0104baa:	90                   	nop
    for (i = 0; i < npage; i++)
c0104bab:	ff 45 dc             	incl   -0x24(%ebp)
c0104bae:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bb1:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104bb6:	39 c2                	cmp    %eax,%edx
c0104bb8:	72 cc                	jb     c0104b86 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104bba:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0104bbf:	c1 e0 05             	shl    $0x5,%eax
c0104bc2:	89 c2                	mov    %eax,%edx
c0104bc4:	a1 a0 6f 12 c0       	mov    0xc0126fa0,%eax
c0104bc9:	01 d0                	add    %edx,%eax
c0104bcb:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104bce:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0104bd5:	77 23                	ja     c0104bfa <page_init+0x22e>
c0104bd7:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104bda:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104bde:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c0104be5:	c0 
c0104be6:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0104bed:	00 
c0104bee:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104bf5:	e8 f3 c0 ff ff       	call   c0100ced <__panic>
c0104bfa:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104bfd:	05 00 00 00 40       	add    $0x40000000,%eax
c0104c02:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i++)
c0104c05:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104c0c:	e9 53 01 00 00       	jmp    c0104d64 <page_init+0x398>
    {
        // memmap is the already existing memory layout given by BIOS
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104c11:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c14:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c17:	89 d0                	mov    %edx,%eax
c0104c19:	c1 e0 02             	shl    $0x2,%eax
c0104c1c:	01 d0                	add    %edx,%eax
c0104c1e:	c1 e0 02             	shl    $0x2,%eax
c0104c21:	01 c8                	add    %ecx,%eax
c0104c23:	8b 50 08             	mov    0x8(%eax),%edx
c0104c26:	8b 40 04             	mov    0x4(%eax),%eax
c0104c29:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c2c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104c2f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c32:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c35:	89 d0                	mov    %edx,%eax
c0104c37:	c1 e0 02             	shl    $0x2,%eax
c0104c3a:	01 d0                	add    %edx,%eax
c0104c3c:	c1 e0 02             	shl    $0x2,%eax
c0104c3f:	01 c8                	add    %ecx,%eax
c0104c41:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104c44:	8b 58 10             	mov    0x10(%eax),%ebx
c0104c47:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104c4a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104c4d:	01 c8                	add    %ecx,%eax
c0104c4f:	11 da                	adc    %ebx,%edx
c0104c51:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104c54:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM)
c0104c57:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104c5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c5d:	89 d0                	mov    %edx,%eax
c0104c5f:	c1 e0 02             	shl    $0x2,%eax
c0104c62:	01 d0                	add    %edx,%eax
c0104c64:	c1 e0 02             	shl    $0x2,%eax
c0104c67:	01 c8                	add    %ecx,%eax
c0104c69:	83 c0 14             	add    $0x14,%eax
c0104c6c:	8b 00                	mov    (%eax),%eax
c0104c6e:	83 f8 01             	cmp    $0x1,%eax
c0104c71:	0f 85 ea 00 00 00    	jne    c0104d61 <page_init+0x395>
        {
            // these two ifs are correct the boundary
            if (begin < freemem)
c0104c77:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104c7a:	ba 00 00 00 00       	mov    $0x0,%edx
c0104c7f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104c82:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0104c85:	19 d1                	sbb    %edx,%ecx
c0104c87:	73 0d                	jae    c0104c96 <page_init+0x2ca>
            {
                begin = freemem;
c0104c89:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104c8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104c8f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE)
c0104c96:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104c9b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ca0:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0104ca3:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104ca6:	73 0e                	jae    c0104cb6 <page_init+0x2ea>
            {
                end = KMEMSIZE;
c0104ca8:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104caf:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            // correct the boundary and call init_memmap(), that is to say,
            // the default_init_memmap(), whose args are block_size and PageNum
            // only the blocks over the freemem can be init
            if (begin < end)
c0104cb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104cbc:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104cbf:	89 d0                	mov    %edx,%eax
c0104cc1:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104cc4:	0f 83 97 00 00 00    	jae    c0104d61 <page_init+0x395>
            {
                begin = ROUNDUP(begin, PGSIZE);
c0104cca:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c0104cd1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104cd4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104cd7:	01 d0                	add    %edx,%eax
c0104cd9:	48                   	dec    %eax
c0104cda:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104cdd:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104ce0:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ce5:	f7 75 b0             	divl   -0x50(%ebp)
c0104ce8:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104ceb:	29 d0                	sub    %edx,%eax
c0104ced:	ba 00 00 00 00       	mov    $0x0,%edx
c0104cf2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104cf5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104cf8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104cfb:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0104cfe:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104d01:	ba 00 00 00 00       	mov    $0x0,%edx
c0104d06:	89 c7                	mov    %eax,%edi
c0104d08:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104d0e:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104d11:	89 d0                	mov    %edx,%eax
c0104d13:	83 e0 00             	and    $0x0,%eax
c0104d16:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104d19:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104d1c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104d1f:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104d22:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end)
c0104d25:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d28:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104d2b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104d2e:	89 d0                	mov    %edx,%eax
c0104d30:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104d33:	73 2c                	jae    c0104d61 <page_init+0x395>
                {
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104d35:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d38:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104d3b:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0104d3e:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0104d41:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104d45:	c1 ea 0c             	shr    $0xc,%edx
c0104d48:	89 c3                	mov    %eax,%ebx
c0104d4a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104d4d:	89 04 24             	mov    %eax,(%esp)
c0104d50:	e8 54 f8 ff ff       	call   c01045a9 <pa2page>
c0104d55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104d59:	89 04 24             	mov    %eax,(%esp)
c0104d5c:	e8 7a fb ff ff       	call   c01048db <init_memmap>
    for (i = 0; i < memmap->nr_map; i++)
c0104d61:	ff 45 dc             	incl   -0x24(%ebp)
c0104d64:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d67:	8b 00                	mov    (%eax),%eax
c0104d69:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104d6c:	0f 8c 9f fe ff ff    	jl     c0104c11 <page_init+0x245>
                }
            }
        }
    }
}
c0104d72:	90                   	nop
c0104d73:	90                   	nop
c0104d74:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104d7a:	5b                   	pop    %ebx
c0104d7b:	5e                   	pop    %esi
c0104d7c:	5f                   	pop    %edi
c0104d7d:	5d                   	pop    %ebp
c0104d7e:	c3                   	ret    

c0104d7f <boot_map_segment>:
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm)
{
c0104d7f:	55                   	push   %ebp
c0104d80:	89 e5                	mov    %esp,%ebp
c0104d82:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104d85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d88:	33 45 14             	xor    0x14(%ebp),%eax
c0104d8b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104d90:	85 c0                	test   %eax,%eax
c0104d92:	74 24                	je     c0104db8 <boot_map_segment+0x39>
c0104d94:	c7 44 24 0c a6 9d 10 	movl   $0xc0109da6,0xc(%esp)
c0104d9b:	c0 
c0104d9c:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0104da3:	c0 
c0104da4:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0104dab:	00 
c0104dac:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104db3:	e8 35 bf ff ff       	call   c0100ced <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104db8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dc2:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104dc7:	89 c2                	mov    %eax,%edx
c0104dc9:	8b 45 10             	mov    0x10(%ebp),%eax
c0104dcc:	01 c2                	add    %eax,%edx
c0104dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd1:	01 d0                	add    %edx,%eax
c0104dd3:	48                   	dec    %eax
c0104dd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104dda:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ddf:	f7 75 f0             	divl   -0x10(%ebp)
c0104de2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104de5:	29 d0                	sub    %edx,%eax
c0104de7:	c1 e8 0c             	shr    $0xc,%eax
c0104dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104ded:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104df3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104df6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104dfb:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104dfe:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e0c:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0104e0f:	eb 68                	jmp    c0104e79 <boot_map_segment+0xfa>
    {
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104e11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104e18:	00 
c0104e19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e20:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e23:	89 04 24             	mov    %eax,(%esp)
c0104e26:	e8 88 01 00 00       	call   c0104fb3 <get_pte>
c0104e2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104e2e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104e32:	75 24                	jne    c0104e58 <boot_map_segment+0xd9>
c0104e34:	c7 44 24 0c d2 9d 10 	movl   $0xc0109dd2,0xc(%esp)
c0104e3b:	c0 
c0104e3c:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0104e43:	c0 
c0104e44:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0104e4b:	00 
c0104e4c:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104e53:	e8 95 be ff ff       	call   c0100ced <__panic>
        *ptep = pa | PTE_P | perm;
c0104e58:	8b 45 14             	mov    0x14(%ebp),%eax
c0104e5b:	0b 45 18             	or     0x18(%ebp),%eax
c0104e5e:	83 c8 01             	or     $0x1,%eax
c0104e61:	89 c2                	mov    %eax,%edx
c0104e63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e66:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
c0104e68:	ff 4d f4             	decl   -0xc(%ebp)
c0104e6b:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104e72:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104e79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e7d:	75 92                	jne    c0104e11 <boot_map_segment+0x92>
    }
}
c0104e7f:	90                   	nop
c0104e80:	90                   	nop
c0104e81:	89 ec                	mov    %ebp,%esp
c0104e83:	5d                   	pop    %ebp
c0104e84:	c3                   	ret    

c0104e85 <boot_alloc_page>:
//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void)
{
c0104e85:	55                   	push   %ebp
c0104e86:	89 e5                	mov    %esp,%ebp
c0104e88:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104e8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e92:	e8 66 fa ff ff       	call   c01048fd <alloc_pages>
c0104e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL)
c0104e9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e9e:	75 1c                	jne    c0104ebc <boot_alloc_page+0x37>
    {
        panic("boot_alloc_page failed.\n");
c0104ea0:	c7 44 24 08 df 9d 10 	movl   $0xc0109ddf,0x8(%esp)
c0104ea7:	c0 
c0104ea8:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0104eaf:	00 
c0104eb0:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104eb7:	e8 31 be ff ff       	call   c0100ced <__panic>
    }
    return page2kva(p);
c0104ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ebf:	89 04 24             	mov    %eax,(%esp)
c0104ec2:	e8 2a f7 ff ff       	call   c01045f1 <page2kva>
}
c0104ec7:	89 ec                	mov    %ebp,%esp
c0104ec9:	5d                   	pop    %ebp
c0104eca:	c3                   	ret    

c0104ecb <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
c0104ecb:	55                   	push   %ebp
c0104ecc:	89 e5                	mov    %esp,%ebp
c0104ece:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104ed1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104ed6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ed9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104ee0:	77 23                	ja     c0104f05 <pmm_init+0x3a>
c0104ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ee5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ee9:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c0104ef0:	c0 
c0104ef1:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0104ef8:	00 
c0104ef9:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104f00:	e8 e8 bd ff ff       	call   c0100ced <__panic>
c0104f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f08:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f0d:	a3 a8 6f 12 c0       	mov    %eax,0xc0126fa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104f12:	e8 8e f9 ff ff       	call   c01048a5 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104f17:	e8 b0 fa ff ff       	call   c01049cc <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104f1c:	e8 c0 04 00 00       	call   c01053e1 <check_alloc_page>

    check_pgdir();
c0104f21:	e8 dc 04 00 00       	call   c0105402 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104f26:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f2e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104f35:	77 23                	ja     c0104f5a <pmm_init+0x8f>
c0104f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f3e:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c0104f45:	c0 
c0104f46:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
c0104f4d:	00 
c0104f4e:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0104f55:	e8 93 bd ff ff       	call   c0100ced <__panic>
c0104f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f5d:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0104f63:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f68:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104f6d:	83 ca 03             	or     $0x3,%edx
c0104f70:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104f72:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0104f77:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104f7e:	00 
c0104f7f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104f86:	00 
c0104f87:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104f8e:	38 
c0104f8f:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104f96:	c0 
c0104f97:	89 04 24             	mov    %eax,(%esp)
c0104f9a:	e8 e0 fd ff ff       	call   c0104d7f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104f9f:	e8 15 f8 ff ff       	call   c01047b9 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104fa4:	e8 f7 0a 00 00       	call   c0105aa0 <check_boot_pgdir>

    print_pgdir();
c0104fa9:	e8 74 0f 00 00       	call   c0105f22 <print_pgdir>
}
c0104fae:	90                   	nop
c0104faf:	89 ec                	mov    %ebp,%esp
c0104fb1:	5d                   	pop    %ebp
c0104fb2:	c3                   	ret    

c0104fb3 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
c0104fb3:	55                   	push   %ebp
c0104fb4:	89 e5                	mov    %esp,%ebp
c0104fb6:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = PDX(la) + pgdir; // (1) find page directory entry
c0104fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fbc:	c1 e8 16             	shr    $0x16,%eax
c0104fbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104fc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fc9:	01 d0                	add    %edx,%eax
c0104fcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P))
c0104fce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd1:	8b 00                	mov    (%eax),%eax
c0104fd3:	83 e0 01             	and    $0x1,%eax
c0104fd6:	85 c0                	test   %eax,%eax
c0104fd8:	0f 85 af 00 00 00    	jne    c010508d <get_pte+0xda>
        // (4) set page reference
        // (5) get linear address of page
        // (6) clear page content using memset
        // (7) set page directory entry's permission
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
c0104fde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104fe2:	74 15                	je     c0104ff9 <get_pte+0x46>
c0104fe4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104feb:	e8 0d f9 ff ff       	call   c01048fd <alloc_pages>
c0104ff0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ff3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ff7:	75 0a                	jne    c0105003 <get_pte+0x50>
        {
            return NULL;
c0104ff9:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ffe:	e9 ed 00 00 00       	jmp    c01050f0 <get_pte+0x13d>
        }
        set_page_ref(page, 1);
c0105003:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010500a:	00 
c010500b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010500e:	89 04 24             	mov    %eax,(%esp)
c0105011:	e8 e1 f6 ff ff       	call   c01046f7 <set_page_ref>
        uintptr_t pa = page2pa(page); // the physical address of page table
c0105016:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105019:	89 04 24             	mov    %eax,(%esp)
c010501c:	e8 70 f5 ff ff       	call   c0104591 <page2pa>
c0105021:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0105024:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105027:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010502a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010502d:	c1 e8 0c             	shr    $0xc,%eax
c0105030:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105033:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105038:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010503b:	72 23                	jb     c0105060 <get_pte+0xad>
c010503d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105040:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105044:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c010504b:	c0 
c010504c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0105053:	00 
c0105054:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010505b:	e8 8d bc ff ff       	call   c0100ced <__panic>
c0105060:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105063:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105068:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010506f:	00 
c0105070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105077:	00 
c0105078:	89 04 24             	mov    %eax,(%esp)
c010507b:	e8 a2 3d 00 00       	call   c0108e22 <memset>
        *pdep = pa | PTE_P | PTE_W | PTE_U;
c0105080:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105083:	83 c8 07             	or     $0x7,%eax
c0105086:	89 c2                	mov    %eax,%edx
c0105088:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010508b:	89 10                	mov    %edx,(%eax)
    }

    pte_t *ptep = (pte_t *)KADDR(PDE_ADDR(*pdep)) + PTX(la);
c010508d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105090:	8b 00                	mov    (%eax),%eax
c0105092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105097:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010509a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010509d:	c1 e8 0c             	shr    $0xc,%eax
c01050a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01050a3:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01050a8:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01050ab:	72 23                	jb     c01050d0 <get_pte+0x11d>
c01050ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01050b4:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c01050bb:	c0 
c01050bc:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c01050c3:	00 
c01050c4:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01050cb:	e8 1d bc ff ff       	call   c0100ced <__panic>
c01050d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050d3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01050d8:	89 c2                	mov    %eax,%edx
c01050da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050dd:	c1 e8 0c             	shr    $0xc,%eax
c01050e0:	25 ff 03 00 00       	and    $0x3ff,%eax
c01050e5:	c1 e0 02             	shl    $0x2,%eax
c01050e8:	01 d0                	add    %edx,%eax
c01050ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ptep; // (8) return page table entry
c01050ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
#endif
}
c01050f0:	89 ec                	mov    %ebp,%esp
c01050f2:	5d                   	pop    %ebp
c01050f3:	c3                   	ret    

c01050f4 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
c01050f4:	55                   	push   %ebp
c01050f5:	89 e5                	mov    %esp,%ebp
c01050f7:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01050fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105101:	00 
c0105102:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105105:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105109:	8b 45 08             	mov    0x8(%ebp),%eax
c010510c:	89 04 24             	mov    %eax,(%esp)
c010510f:	e8 9f fe ff ff       	call   c0104fb3 <get_pte>
c0105114:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL)
c0105117:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010511b:	74 08                	je     c0105125 <get_page+0x31>
    {
        *ptep_store = ptep;
c010511d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105120:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105123:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P)
c0105125:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105129:	74 1b                	je     c0105146 <get_page+0x52>
c010512b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010512e:	8b 00                	mov    (%eax),%eax
c0105130:	83 e0 01             	and    $0x1,%eax
c0105133:	85 c0                	test   %eax,%eax
c0105135:	74 0f                	je     c0105146 <get_page+0x52>
    {
        return pte2page(*ptep);
c0105137:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010513a:	8b 00                	mov    (%eax),%eax
c010513c:	89 04 24             	mov    %eax,(%esp)
c010513f:	e8 4f f5 ff ff       	call   c0104693 <pte2page>
c0105144:	eb 05                	jmp    c010514b <get_page+0x57>
    }
    return NULL;
c0105146:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010514b:	89 ec                	mov    %ebp,%esp
c010514d:	5d                   	pop    %ebp
c010514e:	c3                   	ret    

c010514f <page_remove_pte>:
//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
c010514f:	55                   	push   %ebp
c0105150:	89 e5                	mov    %esp,%ebp
c0105152:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep & PTE_P) //(1) check if this page table entry is present
c0105155:	8b 45 10             	mov    0x10(%ebp),%eax
c0105158:	8b 00                	mov    (%eax),%eax
c010515a:	83 e0 01             	and    $0x1,%eax
c010515d:	85 c0                	test   %eax,%eax
c010515f:	74 4d                	je     c01051ae <page_remove_pte+0x5f>
    {
        struct Page *page = pte2page(*ptep); //(2) find corresponding page to pte
c0105161:	8b 45 10             	mov    0x10(%ebp),%eax
c0105164:	8b 00                	mov    (%eax),%eax
c0105166:	89 04 24             	mov    %eax,(%esp)
c0105169:	e8 25 f5 ff ff       	call   c0104693 <pte2page>
c010516e:	89 45 f4             	mov    %eax,-0xc(%ebp)

        if (page_ref_dec(page) == 0) //(3) decrease page reference
c0105171:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105174:	89 04 24             	mov    %eax,(%esp)
c0105177:	e8 a0 f5 ff ff       	call   c010471c <page_ref_dec>
c010517c:	85 c0                	test   %eax,%eax
c010517e:	75 13                	jne    c0105193 <page_remove_pte+0x44>
        {
            free_page(page); //(4) and free this page when page reference reachs 0
c0105180:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105187:	00 
c0105188:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010518b:	89 04 24             	mov    %eax,(%esp)
c010518e:	e8 d7 f7 ff ff       	call   c010496a <free_pages>
        }
        *ptep = 0;                 //(5) clear second page table entry
c0105193:	8b 45 10             	mov    0x10(%ebp),%eax
c0105196:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la); //(6) flush tlb
c010519c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010519f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a6:	89 04 24             	mov    %eax,(%esp)
c01051a9:	e8 07 01 00 00       	call   c01052b5 <tlb_invalidate>
    }
#endif
}
c01051ae:	90                   	nop
c01051af:	89 ec                	mov    %ebp,%esp
c01051b1:	5d                   	pop    %ebp
c01051b2:	c3                   	ret    

c01051b3 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
c01051b3:	55                   	push   %ebp
c01051b4:	89 e5                	mov    %esp,%ebp
c01051b6:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01051b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01051c0:	00 
c01051c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01051cb:	89 04 24             	mov    %eax,(%esp)
c01051ce:	e8 e0 fd ff ff       	call   c0104fb3 <get_pte>
c01051d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL)
c01051d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01051da:	74 19                	je     c01051f5 <page_remove+0x42>
    {
        page_remove_pte(pgdir, la, ptep);
c01051dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051df:	89 44 24 08          	mov    %eax,0x8(%esp)
c01051e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01051e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01051ed:	89 04 24             	mov    %eax,(%esp)
c01051f0:	e8 5a ff ff ff       	call   c010514f <page_remove_pte>
    }
}
c01051f5:	90                   	nop
c01051f6:	89 ec                	mov    %ebp,%esp
c01051f8:	5d                   	pop    %ebp
c01051f9:	c3                   	ret    

c01051fa <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
c01051fa:	55                   	push   %ebp
c01051fb:	89 e5                	mov    %esp,%ebp
c01051fd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105200:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105207:	00 
c0105208:	8b 45 10             	mov    0x10(%ebp),%eax
c010520b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010520f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105212:	89 04 24             	mov    %eax,(%esp)
c0105215:	e8 99 fd ff ff       	call   c0104fb3 <get_pte>
c010521a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL)
c010521d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105221:	75 0a                	jne    c010522d <page_insert+0x33>
    {
        return -E_NO_MEM;
c0105223:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105228:	e9 84 00 00 00       	jmp    c01052b1 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010522d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105230:	89 04 24             	mov    %eax,(%esp)
c0105233:	e8 cd f4 ff ff       	call   c0104705 <page_ref_inc>
    if (*ptep & PTE_P)
c0105238:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010523b:	8b 00                	mov    (%eax),%eax
c010523d:	83 e0 01             	and    $0x1,%eax
c0105240:	85 c0                	test   %eax,%eax
c0105242:	74 3e                	je     c0105282 <page_insert+0x88>
    {
        struct Page *p = pte2page(*ptep);
c0105244:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105247:	8b 00                	mov    (%eax),%eax
c0105249:	89 04 24             	mov    %eax,(%esp)
c010524c:	e8 42 f4 ff ff       	call   c0104693 <pte2page>
c0105251:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page)
c0105254:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105257:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010525a:	75 0d                	jne    c0105269 <page_insert+0x6f>
        {
            page_ref_dec(page); // used to modify the pages permission(?)
c010525c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010525f:	89 04 24             	mov    %eax,(%esp)
c0105262:	e8 b5 f4 ff ff       	call   c010471c <page_ref_dec>
c0105267:	eb 19                	jmp    c0105282 <page_insert+0x88>
        }
        else
        {
            page_remove_pte(pgdir, la, ptep);
c0105269:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010526c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105270:	8b 45 10             	mov    0x10(%ebp),%eax
c0105273:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105277:	8b 45 08             	mov    0x8(%ebp),%eax
c010527a:	89 04 24             	mov    %eax,(%esp)
c010527d:	e8 cd fe ff ff       	call   c010514f <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105282:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105285:	89 04 24             	mov    %eax,(%esp)
c0105288:	e8 04 f3 ff ff       	call   c0104591 <page2pa>
c010528d:	0b 45 14             	or     0x14(%ebp),%eax
c0105290:	83 c8 01             	or     $0x1,%eax
c0105293:	89 c2                	mov    %eax,%edx
c0105295:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105298:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010529a:	8b 45 10             	mov    0x10(%ebp),%eax
c010529d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01052a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01052a4:	89 04 24             	mov    %eax,(%esp)
c01052a7:	e8 09 00 00 00       	call   c01052b5 <tlb_invalidate>
    return 0;
c01052ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052b1:	89 ec                	mov    %ebp,%esp
c01052b3:	5d                   	pop    %ebp
c01052b4:	c3                   	ret    

c01052b5 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
c01052b5:	55                   	push   %ebp
c01052b6:	89 e5                	mov    %esp,%ebp
c01052b8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01052bb:	0f 20 d8             	mov    %cr3,%eax
c01052be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01052c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir))
c01052c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01052c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052ca:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01052d1:	77 23                	ja     c01052f6 <tlb_invalidate+0x41>
c01052d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01052da:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c01052e1:	c0 
c01052e2:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c01052e9:	00 
c01052ea:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01052f1:	e8 f7 b9 ff ff       	call   c0100ced <__panic>
c01052f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052f9:	05 00 00 00 40       	add    $0x40000000,%eax
c01052fe:	39 d0                	cmp    %edx,%eax
c0105300:	75 0d                	jne    c010530f <tlb_invalidate+0x5a>
    {
        invlpg((void *)la);
c0105302:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105305:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105308:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010530b:	0f 01 38             	invlpg (%eax)
}
c010530e:	90                   	nop
    }
}
c010530f:	90                   	nop
c0105310:	89 ec                	mov    %ebp,%esp
c0105312:	5d                   	pop    %ebp
c0105313:	c3                   	ret    

c0105314 <pgdir_alloc_page>:
// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
c0105314:	55                   	push   %ebp
c0105315:	89 e5                	mov    %esp,%ebp
c0105317:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c010531a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105321:	e8 d7 f5 ff ff       	call   c01048fd <alloc_pages>
c0105326:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)
c0105329:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010532d:	0f 84 a7 00 00 00    	je     c01053da <pgdir_alloc_page+0xc6>
    {
        if (page_insert(pgdir, page, la, perm) != 0)
c0105333:	8b 45 10             	mov    0x10(%ebp),%eax
c0105336:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010533a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010533d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105341:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105344:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105348:	8b 45 08             	mov    0x8(%ebp),%eax
c010534b:	89 04 24             	mov    %eax,(%esp)
c010534e:	e8 a7 fe ff ff       	call   c01051fa <page_insert>
c0105353:	85 c0                	test   %eax,%eax
c0105355:	74 1a                	je     c0105371 <pgdir_alloc_page+0x5d>
        {
            free_page(page);
c0105357:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010535e:	00 
c010535f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105362:	89 04 24             	mov    %eax,(%esp)
c0105365:	e8 00 f6 ff ff       	call   c010496a <free_pages>
            return NULL;
c010536a:	b8 00 00 00 00       	mov    $0x0,%eax
c010536f:	eb 6c                	jmp    c01053dd <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok)
c0105371:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0105376:	85 c0                	test   %eax,%eax
c0105378:	74 60                	je     c01053da <pgdir_alloc_page+0xc6>
        {
            swap_map_swappable(check_mm_struct, la, page, 0);
c010537a:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c010537f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105386:	00 
c0105387:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010538a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010538e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105391:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105395:	89 04 24             	mov    %eax,(%esp)
c0105398:	e8 79 0f 00 00       	call   c0106316 <swap_map_swappable>
            page->pra_vaddr = la;
c010539d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01053a3:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c01053a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a9:	89 04 24             	mov    %eax,(%esp)
c01053ac:	e8 3c f3 ff ff       	call   c01046ed <page_ref>
c01053b1:	83 f8 01             	cmp    $0x1,%eax
c01053b4:	74 24                	je     c01053da <pgdir_alloc_page+0xc6>
c01053b6:	c7 44 24 0c f8 9d 10 	movl   $0xc0109df8,0xc(%esp)
c01053bd:	c0 
c01053be:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01053c5:	c0 
c01053c6:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c01053cd:	00 
c01053ce:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01053d5:	e8 13 b9 ff ff       	call   c0100ced <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }
    }

    return page;
c01053da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01053dd:	89 ec                	mov    %ebp,%esp
c01053df:	5d                   	pop    %ebp
c01053e0:	c3                   	ret    

c01053e1 <check_alloc_page>:

static void
check_alloc_page(void)
{
c01053e1:	55                   	push   %ebp
c01053e2:	89 e5                	mov    %esp,%ebp
c01053e4:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01053e7:	a1 ac 6f 12 c0       	mov    0xc0126fac,%eax
c01053ec:	8b 40 18             	mov    0x18(%eax),%eax
c01053ef:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01053f1:	c7 04 24 0c 9e 10 c0 	movl   $0xc0109e0c,(%esp)
c01053f8:	e8 68 af ff ff       	call   c0100365 <cprintf>
}
c01053fd:	90                   	nop
c01053fe:	89 ec                	mov    %ebp,%esp
c0105400:	5d                   	pop    %ebp
c0105401:	c3                   	ret    

c0105402 <check_pgdir>:

static void
check_pgdir(void)
{
c0105402:	55                   	push   %ebp
c0105403:	89 e5                	mov    %esp,%ebp
c0105405:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105408:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010540d:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105412:	76 24                	jbe    c0105438 <check_pgdir+0x36>
c0105414:	c7 44 24 0c 2b 9e 10 	movl   $0xc0109e2b,0xc(%esp)
c010541b:	c0 
c010541c:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105423:	c0 
c0105424:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c010542b:	00 
c010542c:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105433:	e8 b5 b8 ff ff       	call   c0100ced <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105438:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010543d:	85 c0                	test   %eax,%eax
c010543f:	74 0e                	je     c010544f <check_pgdir+0x4d>
c0105441:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105446:	25 ff 0f 00 00       	and    $0xfff,%eax
c010544b:	85 c0                	test   %eax,%eax
c010544d:	74 24                	je     c0105473 <check_pgdir+0x71>
c010544f:	c7 44 24 0c 48 9e 10 	movl   $0xc0109e48,0xc(%esp)
c0105456:	c0 
c0105457:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c010545e:	c0 
c010545f:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0105466:	00 
c0105467:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010546e:	e8 7a b8 ff ff       	call   c0100ced <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105473:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105478:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010547f:	00 
c0105480:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105487:	00 
c0105488:	89 04 24             	mov    %eax,(%esp)
c010548b:	e8 64 fc ff ff       	call   c01050f4 <get_page>
c0105490:	85 c0                	test   %eax,%eax
c0105492:	74 24                	je     c01054b8 <check_pgdir+0xb6>
c0105494:	c7 44 24 0c 80 9e 10 	movl   $0xc0109e80,0xc(%esp)
c010549b:	c0 
c010549c:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01054a3:	c0 
c01054a4:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c01054ab:	00 
c01054ac:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01054b3:	e8 35 b8 ff ff       	call   c0100ced <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01054b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054bf:	e8 39 f4 ff ff       	call   c01048fd <alloc_pages>
c01054c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01054c7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01054cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01054d3:	00 
c01054d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01054db:	00 
c01054dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054df:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054e3:	89 04 24             	mov    %eax,(%esp)
c01054e6:	e8 0f fd ff ff       	call   c01051fa <page_insert>
c01054eb:	85 c0                	test   %eax,%eax
c01054ed:	74 24                	je     c0105513 <check_pgdir+0x111>
c01054ef:	c7 44 24 0c a8 9e 10 	movl   $0xc0109ea8,0xc(%esp)
c01054f6:	c0 
c01054f7:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01054fe:	c0 
c01054ff:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0105506:	00 
c0105507:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010550e:	e8 da b7 ff ff       	call   c0100ced <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105513:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105518:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010551f:	00 
c0105520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105527:	00 
c0105528:	89 04 24             	mov    %eax,(%esp)
c010552b:	e8 83 fa ff ff       	call   c0104fb3 <get_pte>
c0105530:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105533:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105537:	75 24                	jne    c010555d <check_pgdir+0x15b>
c0105539:	c7 44 24 0c d4 9e 10 	movl   $0xc0109ed4,0xc(%esp)
c0105540:	c0 
c0105541:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105548:	c0 
c0105549:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0105550:	00 
c0105551:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105558:	e8 90 b7 ff ff       	call   c0100ced <__panic>
    assert(pte2page(*ptep) == p1);
c010555d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105560:	8b 00                	mov    (%eax),%eax
c0105562:	89 04 24             	mov    %eax,(%esp)
c0105565:	e8 29 f1 ff ff       	call   c0104693 <pte2page>
c010556a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010556d:	74 24                	je     c0105593 <check_pgdir+0x191>
c010556f:	c7 44 24 0c 01 9f 10 	movl   $0xc0109f01,0xc(%esp)
c0105576:	c0 
c0105577:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c010557e:	c0 
c010557f:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0105586:	00 
c0105587:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010558e:	e8 5a b7 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p1) == 1);
c0105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105596:	89 04 24             	mov    %eax,(%esp)
c0105599:	e8 4f f1 ff ff       	call   c01046ed <page_ref>
c010559e:	83 f8 01             	cmp    $0x1,%eax
c01055a1:	74 24                	je     c01055c7 <check_pgdir+0x1c5>
c01055a3:	c7 44 24 0c 17 9f 10 	movl   $0xc0109f17,0xc(%esp)
c01055aa:	c0 
c01055ab:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01055b2:	c0 
c01055b3:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c01055ba:	00 
c01055bb:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01055c2:	e8 26 b7 ff ff       	call   c0100ced <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01055c7:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01055cc:	8b 00                	mov    (%eax),%eax
c01055ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01055d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01055d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055d9:	c1 e8 0c             	shr    $0xc,%eax
c01055dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01055df:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01055e4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01055e7:	72 23                	jb     c010560c <check_pgdir+0x20a>
c01055e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01055ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01055f0:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c01055f7:	c0 
c01055f8:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01055ff:	00 
c0105600:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105607:	e8 e1 b6 ff ff       	call   c0100ced <__panic>
c010560c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010560f:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105614:	83 c0 04             	add    $0x4,%eax
c0105617:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010561a:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010561f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105626:	00 
c0105627:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010562e:	00 
c010562f:	89 04 24             	mov    %eax,(%esp)
c0105632:	e8 7c f9 ff ff       	call   c0104fb3 <get_pte>
c0105637:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010563a:	74 24                	je     c0105660 <check_pgdir+0x25e>
c010563c:	c7 44 24 0c 2c 9f 10 	movl   $0xc0109f2c,0xc(%esp)
c0105643:	c0 
c0105644:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c010564b:	c0 
c010564c:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c0105653:	00 
c0105654:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010565b:	e8 8d b6 ff ff       	call   c0100ced <__panic>

    p2 = alloc_page();
c0105660:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105667:	e8 91 f2 ff ff       	call   c01048fd <alloc_pages>
c010566c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010566f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105674:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010567b:	00 
c010567c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105683:	00 
c0105684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105687:	89 54 24 04          	mov    %edx,0x4(%esp)
c010568b:	89 04 24             	mov    %eax,(%esp)
c010568e:	e8 67 fb ff ff       	call   c01051fa <page_insert>
c0105693:	85 c0                	test   %eax,%eax
c0105695:	74 24                	je     c01056bb <check_pgdir+0x2b9>
c0105697:	c7 44 24 0c 54 9f 10 	movl   $0xc0109f54,0xc(%esp)
c010569e:	c0 
c010569f:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01056a6:	c0 
c01056a7:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01056ae:	00 
c01056af:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01056b6:	e8 32 b6 ff ff       	call   c0100ced <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01056bb:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01056c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056c7:	00 
c01056c8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056cf:	00 
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 db f8 ff ff       	call   c0104fb3 <get_pte>
c01056d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056df:	75 24                	jne    c0105705 <check_pgdir+0x303>
c01056e1:	c7 44 24 0c 8c 9f 10 	movl   $0xc0109f8c,0xc(%esp)
c01056e8:	c0 
c01056e9:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01056f0:	c0 
c01056f1:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c01056f8:	00 
c01056f9:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105700:	e8 e8 b5 ff ff       	call   c0100ced <__panic>
    assert(*ptep & PTE_U);
c0105705:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105708:	8b 00                	mov    (%eax),%eax
c010570a:	83 e0 04             	and    $0x4,%eax
c010570d:	85 c0                	test   %eax,%eax
c010570f:	75 24                	jne    c0105735 <check_pgdir+0x333>
c0105711:	c7 44 24 0c bc 9f 10 	movl   $0xc0109fbc,0xc(%esp)
c0105718:	c0 
c0105719:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105720:	c0 
c0105721:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0105728:	00 
c0105729:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105730:	e8 b8 b5 ff ff       	call   c0100ced <__panic>
    assert(*ptep & PTE_W);
c0105735:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105738:	8b 00                	mov    (%eax),%eax
c010573a:	83 e0 02             	and    $0x2,%eax
c010573d:	85 c0                	test   %eax,%eax
c010573f:	75 24                	jne    c0105765 <check_pgdir+0x363>
c0105741:	c7 44 24 0c ca 9f 10 	movl   $0xc0109fca,0xc(%esp)
c0105748:	c0 
c0105749:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105750:	c0 
c0105751:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0105758:	00 
c0105759:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105760:	e8 88 b5 ff ff       	call   c0100ced <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105765:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c010576a:	8b 00                	mov    (%eax),%eax
c010576c:	83 e0 04             	and    $0x4,%eax
c010576f:	85 c0                	test   %eax,%eax
c0105771:	75 24                	jne    c0105797 <check_pgdir+0x395>
c0105773:	c7 44 24 0c d8 9f 10 	movl   $0xc0109fd8,0xc(%esp)
c010577a:	c0 
c010577b:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105782:	c0 
c0105783:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010578a:	00 
c010578b:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105792:	e8 56 b5 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p2) == 1);
c0105797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010579a:	89 04 24             	mov    %eax,(%esp)
c010579d:	e8 4b ef ff ff       	call   c01046ed <page_ref>
c01057a2:	83 f8 01             	cmp    $0x1,%eax
c01057a5:	74 24                	je     c01057cb <check_pgdir+0x3c9>
c01057a7:	c7 44 24 0c ee 9f 10 	movl   $0xc0109fee,0xc(%esp)
c01057ae:	c0 
c01057af:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01057b6:	c0 
c01057b7:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c01057be:	00 
c01057bf:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01057c6:	e8 22 b5 ff ff       	call   c0100ced <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01057cb:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01057d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01057d7:	00 
c01057d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01057df:	00 
c01057e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057e7:	89 04 24             	mov    %eax,(%esp)
c01057ea:	e8 0b fa ff ff       	call   c01051fa <page_insert>
c01057ef:	85 c0                	test   %eax,%eax
c01057f1:	74 24                	je     c0105817 <check_pgdir+0x415>
c01057f3:	c7 44 24 0c 00 a0 10 	movl   $0xc010a000,0xc(%esp)
c01057fa:	c0 
c01057fb:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105802:	c0 
c0105803:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c010580a:	00 
c010580b:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105812:	e8 d6 b4 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p1) == 2);
c0105817:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010581a:	89 04 24             	mov    %eax,(%esp)
c010581d:	e8 cb ee ff ff       	call   c01046ed <page_ref>
c0105822:	83 f8 02             	cmp    $0x2,%eax
c0105825:	74 24                	je     c010584b <check_pgdir+0x449>
c0105827:	c7 44 24 0c 2c a0 10 	movl   $0xc010a02c,0xc(%esp)
c010582e:	c0 
c010582f:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105836:	c0 
c0105837:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c010583e:	00 
c010583f:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105846:	e8 a2 b4 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p2) == 0);
c010584b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010584e:	89 04 24             	mov    %eax,(%esp)
c0105851:	e8 97 ee ff ff       	call   c01046ed <page_ref>
c0105856:	85 c0                	test   %eax,%eax
c0105858:	74 24                	je     c010587e <check_pgdir+0x47c>
c010585a:	c7 44 24 0c 3e a0 10 	movl   $0xc010a03e,0xc(%esp)
c0105861:	c0 
c0105862:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105869:	c0 
c010586a:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105871:	00 
c0105872:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105879:	e8 6f b4 ff ff       	call   c0100ced <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010587e:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105883:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010588a:	00 
c010588b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105892:	00 
c0105893:	89 04 24             	mov    %eax,(%esp)
c0105896:	e8 18 f7 ff ff       	call   c0104fb3 <get_pte>
c010589b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010589e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058a2:	75 24                	jne    c01058c8 <check_pgdir+0x4c6>
c01058a4:	c7 44 24 0c 8c 9f 10 	movl   $0xc0109f8c,0xc(%esp)
c01058ab:	c0 
c01058ac:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01058b3:	c0 
c01058b4:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c01058bb:	00 
c01058bc:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01058c3:	e8 25 b4 ff ff       	call   c0100ced <__panic>
    assert(pte2page(*ptep) == p1);
c01058c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058cb:	8b 00                	mov    (%eax),%eax
c01058cd:	89 04 24             	mov    %eax,(%esp)
c01058d0:	e8 be ed ff ff       	call   c0104693 <pte2page>
c01058d5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01058d8:	74 24                	je     c01058fe <check_pgdir+0x4fc>
c01058da:	c7 44 24 0c 01 9f 10 	movl   $0xc0109f01,0xc(%esp)
c01058e1:	c0 
c01058e2:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01058e9:	c0 
c01058ea:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c01058f1:	00 
c01058f2:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01058f9:	e8 ef b3 ff ff       	call   c0100ced <__panic>
    assert((*ptep & PTE_U) == 0);
c01058fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105901:	8b 00                	mov    (%eax),%eax
c0105903:	83 e0 04             	and    $0x4,%eax
c0105906:	85 c0                	test   %eax,%eax
c0105908:	74 24                	je     c010592e <check_pgdir+0x52c>
c010590a:	c7 44 24 0c 50 a0 10 	movl   $0xc010a050,0xc(%esp)
c0105911:	c0 
c0105912:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105919:	c0 
c010591a:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c0105921:	00 
c0105922:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105929:	e8 bf b3 ff ff       	call   c0100ced <__panic>

    page_remove(boot_pgdir, 0x0);
c010592e:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105933:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010593a:	00 
c010593b:	89 04 24             	mov    %eax,(%esp)
c010593e:	e8 70 f8 ff ff       	call   c01051b3 <page_remove>
    assert(page_ref(p1) == 1);
c0105943:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105946:	89 04 24             	mov    %eax,(%esp)
c0105949:	e8 9f ed ff ff       	call   c01046ed <page_ref>
c010594e:	83 f8 01             	cmp    $0x1,%eax
c0105951:	74 24                	je     c0105977 <check_pgdir+0x575>
c0105953:	c7 44 24 0c 17 9f 10 	movl   $0xc0109f17,0xc(%esp)
c010595a:	c0 
c010595b:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105962:	c0 
c0105963:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c010596a:	00 
c010596b:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105972:	e8 76 b3 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p2) == 0);
c0105977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010597a:	89 04 24             	mov    %eax,(%esp)
c010597d:	e8 6b ed ff ff       	call   c01046ed <page_ref>
c0105982:	85 c0                	test   %eax,%eax
c0105984:	74 24                	je     c01059aa <check_pgdir+0x5a8>
c0105986:	c7 44 24 0c 3e a0 10 	movl   $0xc010a03e,0xc(%esp)
c010598d:	c0 
c010598e:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105995:	c0 
c0105996:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c010599d:	00 
c010599e:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01059a5:	e8 43 b3 ff ff       	call   c0100ced <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01059aa:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c01059af:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01059b6:	00 
c01059b7:	89 04 24             	mov    %eax,(%esp)
c01059ba:	e8 f4 f7 ff ff       	call   c01051b3 <page_remove>
    assert(page_ref(p1) == 0);
c01059bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059c2:	89 04 24             	mov    %eax,(%esp)
c01059c5:	e8 23 ed ff ff       	call   c01046ed <page_ref>
c01059ca:	85 c0                	test   %eax,%eax
c01059cc:	74 24                	je     c01059f2 <check_pgdir+0x5f0>
c01059ce:	c7 44 24 0c 65 a0 10 	movl   $0xc010a065,0xc(%esp)
c01059d5:	c0 
c01059d6:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01059dd:	c0 
c01059de:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c01059e5:	00 
c01059e6:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01059ed:	e8 fb b2 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p2) == 0);
c01059f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01059f5:	89 04 24             	mov    %eax,(%esp)
c01059f8:	e8 f0 ec ff ff       	call   c01046ed <page_ref>
c01059fd:	85 c0                	test   %eax,%eax
c01059ff:	74 24                	je     c0105a25 <check_pgdir+0x623>
c0105a01:	c7 44 24 0c 3e a0 10 	movl   $0xc010a03e,0xc(%esp)
c0105a08:	c0 
c0105a09:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105a10:	c0 
c0105a11:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0105a18:	00 
c0105a19:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105a20:	e8 c8 b2 ff ff       	call   c0100ced <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0105a25:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a2a:	8b 00                	mov    (%eax),%eax
c0105a2c:	89 04 24             	mov    %eax,(%esp)
c0105a2f:	e8 9f ec ff ff       	call   c01046d3 <pde2page>
c0105a34:	89 04 24             	mov    %eax,(%esp)
c0105a37:	e8 b1 ec ff ff       	call   c01046ed <page_ref>
c0105a3c:	83 f8 01             	cmp    $0x1,%eax
c0105a3f:	74 24                	je     c0105a65 <check_pgdir+0x663>
c0105a41:	c7 44 24 0c 78 a0 10 	movl   $0xc010a078,0xc(%esp)
c0105a48:	c0 
c0105a49:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105a50:	c0 
c0105a51:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0105a58:	00 
c0105a59:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105a60:	e8 88 b2 ff ff       	call   c0100ced <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0105a65:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a6a:	8b 00                	mov    (%eax),%eax
c0105a6c:	89 04 24             	mov    %eax,(%esp)
c0105a6f:	e8 5f ec ff ff       	call   c01046d3 <pde2page>
c0105a74:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a7b:	00 
c0105a7c:	89 04 24             	mov    %eax,(%esp)
c0105a7f:	e8 e6 ee ff ff       	call   c010496a <free_pages>
    boot_pgdir[0] = 0;
c0105a84:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0105a8f:	c7 04 24 9f a0 10 c0 	movl   $0xc010a09f,(%esp)
c0105a96:	e8 ca a8 ff ff       	call   c0100365 <cprintf>
}
c0105a9b:	90                   	nop
c0105a9c:	89 ec                	mov    %ebp,%esp
c0105a9e:	5d                   	pop    %ebp
c0105a9f:	c3                   	ret    

c0105aa0 <check_boot_pgdir>:

static void
check_boot_pgdir(void)
{
c0105aa0:	55                   	push   %ebp
c0105aa1:	89 e5                	mov    %esp,%ebp
c0105aa3:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE)
c0105aa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105aad:	e9 ca 00 00 00       	jmp    c0105b7c <check_boot_pgdir+0xdc>
    {
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ab8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105abb:	c1 e8 0c             	shr    $0xc,%eax
c0105abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105ac1:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105ac6:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105ac9:	72 23                	jb     c0105aee <check_boot_pgdir+0x4e>
c0105acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ace:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105ad2:	c7 44 24 08 d0 9c 10 	movl   $0xc0109cd0,0x8(%esp)
c0105ad9:	c0 
c0105ada:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
c0105ae1:	00 
c0105ae2:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105ae9:	e8 ff b1 ff ff       	call   c0100ced <__panic>
c0105aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105af1:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105af6:	89 c2                	mov    %eax,%edx
c0105af8:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105afd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b04:	00 
c0105b05:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b09:	89 04 24             	mov    %eax,(%esp)
c0105b0c:	e8 a2 f4 ff ff       	call   c0104fb3 <get_pte>
c0105b11:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105b14:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105b18:	75 24                	jne    c0105b3e <check_boot_pgdir+0x9e>
c0105b1a:	c7 44 24 0c bc a0 10 	movl   $0xc010a0bc,0xc(%esp)
c0105b21:	c0 
c0105b22:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105b29:	c0 
c0105b2a:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
c0105b31:	00 
c0105b32:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105b39:	e8 af b1 ff ff       	call   c0100ced <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105b3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b41:	8b 00                	mov    (%eax),%eax
c0105b43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105b48:	89 c2                	mov    %eax,%edx
c0105b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b4d:	39 c2                	cmp    %eax,%edx
c0105b4f:	74 24                	je     c0105b75 <check_boot_pgdir+0xd5>
c0105b51:	c7 44 24 0c f9 a0 10 	movl   $0xc010a0f9,0xc(%esp)
c0105b58:	c0 
c0105b59:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105b60:	c0 
c0105b61:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
c0105b68:	00 
c0105b69:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105b70:	e8 78 b1 ff ff       	call   c0100ced <__panic>
    for (i = 0; i < npage; i += PGSIZE)
c0105b75:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0105b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b7f:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0105b84:	39 c2                	cmp    %eax,%edx
c0105b86:	0f 82 26 ff ff ff    	jb     c0105ab2 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0105b8c:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105b91:	05 ac 0f 00 00       	add    $0xfac,%eax
c0105b96:	8b 00                	mov    (%eax),%eax
c0105b98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105b9d:	89 c2                	mov    %eax,%edx
c0105b9f:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105ba4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ba7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105bae:	77 23                	ja     c0105bd3 <check_boot_pgdir+0x133>
c0105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105bb7:	c7 44 24 08 f4 9c 10 	movl   $0xc0109cf4,0x8(%esp)
c0105bbe:	c0 
c0105bbf:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0105bc6:	00 
c0105bc7:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105bce:	e8 1a b1 ff ff       	call   c0100ced <__panic>
c0105bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bd6:	05 00 00 00 40       	add    $0x40000000,%eax
c0105bdb:	39 d0                	cmp    %edx,%eax
c0105bdd:	74 24                	je     c0105c03 <check_boot_pgdir+0x163>
c0105bdf:	c7 44 24 0c 10 a1 10 	movl   $0xc010a110,0xc(%esp)
c0105be6:	c0 
c0105be7:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105bee:	c0 
c0105bef:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0105bf6:	00 
c0105bf7:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105bfe:	e8 ea b0 ff ff       	call   c0100ced <__panic>

    assert(boot_pgdir[0] == 0);
c0105c03:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c08:	8b 00                	mov    (%eax),%eax
c0105c0a:	85 c0                	test   %eax,%eax
c0105c0c:	74 24                	je     c0105c32 <check_boot_pgdir+0x192>
c0105c0e:	c7 44 24 0c 44 a1 10 	movl   $0xc010a144,0xc(%esp)
c0105c15:	c0 
c0105c16:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105c1d:	c0 
c0105c1e:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
c0105c25:	00 
c0105c26:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105c2d:	e8 bb b0 ff ff       	call   c0100ced <__panic>

    struct Page *p;
    p = alloc_page();
c0105c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c39:	e8 bf ec ff ff       	call   c01048fd <alloc_pages>
c0105c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105c41:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105c46:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105c4d:	00 
c0105c4e:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105c55:	00 
c0105c56:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c59:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c5d:	89 04 24             	mov    %eax,(%esp)
c0105c60:	e8 95 f5 ff ff       	call   c01051fa <page_insert>
c0105c65:	85 c0                	test   %eax,%eax
c0105c67:	74 24                	je     c0105c8d <check_boot_pgdir+0x1ed>
c0105c69:	c7 44 24 0c 58 a1 10 	movl   $0xc010a158,0xc(%esp)
c0105c70:	c0 
c0105c71:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105c78:	c0 
c0105c79:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0105c80:	00 
c0105c81:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105c88:	e8 60 b0 ff ff       	call   c0100ced <__panic>
    assert(page_ref(p) == 1);
c0105c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c90:	89 04 24             	mov    %eax,(%esp)
c0105c93:	e8 55 ea ff ff       	call   c01046ed <page_ref>
c0105c98:	83 f8 01             	cmp    $0x1,%eax
c0105c9b:	74 24                	je     c0105cc1 <check_boot_pgdir+0x221>
c0105c9d:	c7 44 24 0c 86 a1 10 	movl   $0xc010a186,0xc(%esp)
c0105ca4:	c0 
c0105ca5:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105cac:	c0 
c0105cad:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0105cb4:	00 
c0105cb5:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105cbc:	e8 2c b0 ff ff       	call   c0100ced <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105cc1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105cc6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105ccd:	00 
c0105cce:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105cd5:	00 
c0105cd6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105cd9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105cdd:	89 04 24             	mov    %eax,(%esp)
c0105ce0:	e8 15 f5 ff ff       	call   c01051fa <page_insert>
c0105ce5:	85 c0                	test   %eax,%eax
c0105ce7:	74 24                	je     c0105d0d <check_boot_pgdir+0x26d>
c0105ce9:	c7 44 24 0c 98 a1 10 	movl   $0xc010a198,0xc(%esp)
c0105cf0:	c0 
c0105cf1:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105cf8:	c0 
c0105cf9:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
c0105d00:	00 
c0105d01:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105d08:	e8 e0 af ff ff       	call   c0100ced <__panic>
    assert(page_ref(p) == 2);
c0105d0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d10:	89 04 24             	mov    %eax,(%esp)
c0105d13:	e8 d5 e9 ff ff       	call   c01046ed <page_ref>
c0105d18:	83 f8 02             	cmp    $0x2,%eax
c0105d1b:	74 24                	je     c0105d41 <check_boot_pgdir+0x2a1>
c0105d1d:	c7 44 24 0c cf a1 10 	movl   $0xc010a1cf,0xc(%esp)
c0105d24:	c0 
c0105d25:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105d2c:	c0 
c0105d2d:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
c0105d34:	00 
c0105d35:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105d3c:	e8 ac af ff ff       	call   c0100ced <__panic>

    const char *str = "ucore: Hello world!!";
c0105d41:	c7 45 e8 e0 a1 10 c0 	movl   $0xc010a1e0,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105d48:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d4f:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d56:	e8 f7 2d 00 00       	call   c0108b52 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105d5b:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105d62:	00 
c0105d63:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105d6a:	e8 5b 2e 00 00       	call   c0108bca <strcmp>
c0105d6f:	85 c0                	test   %eax,%eax
c0105d71:	74 24                	je     c0105d97 <check_boot_pgdir+0x2f7>
c0105d73:	c7 44 24 0c f8 a1 10 	movl   $0xc010a1f8,0xc(%esp)
c0105d7a:	c0 
c0105d7b:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105d82:	c0 
c0105d83:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
c0105d8a:	00 
c0105d8b:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105d92:	e8 56 af ff ff       	call   c0100ced <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d9a:	89 04 24             	mov    %eax,(%esp)
c0105d9d:	e8 4f e8 ff ff       	call   c01045f1 <page2kva>
c0105da2:	05 00 01 00 00       	add    $0x100,%eax
c0105da7:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105daa:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105db1:	e8 42 2d 00 00       	call   c0108af8 <strlen>
c0105db6:	85 c0                	test   %eax,%eax
c0105db8:	74 24                	je     c0105dde <check_boot_pgdir+0x33e>
c0105dba:	c7 44 24 0c 30 a2 10 	movl   $0xc010a230,0xc(%esp)
c0105dc1:	c0 
c0105dc2:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0105dc9:	c0 
c0105dca:	c7 44 24 04 77 02 00 	movl   $0x277,0x4(%esp)
c0105dd1:	00 
c0105dd2:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0105dd9:	e8 0f af ff ff       	call   c0100ced <__panic>

    free_page(p);
c0105dde:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105de5:	00 
c0105de6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105de9:	89 04 24             	mov    %eax,(%esp)
c0105dec:	e8 79 eb ff ff       	call   c010496a <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105df1:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105df6:	8b 00                	mov    (%eax),%eax
c0105df8:	89 04 24             	mov    %eax,(%esp)
c0105dfb:	e8 d3 e8 ff ff       	call   c01046d3 <pde2page>
c0105e00:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e07:	00 
c0105e08:	89 04 24             	mov    %eax,(%esp)
c0105e0b:	e8 5a eb ff ff       	call   c010496a <free_pages>
    boot_pgdir[0] = 0;
c0105e10:	a1 e0 39 12 c0       	mov    0xc01239e0,%eax
c0105e15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105e1b:	c7 04 24 54 a2 10 c0 	movl   $0xc010a254,(%esp)
c0105e22:	e8 3e a5 ff ff       	call   c0100365 <cprintf>
}
c0105e27:	90                   	nop
c0105e28:	89 ec                	mov    %ebp,%esp
c0105e2a:	5d                   	pop    %ebp
c0105e2b:	c3                   	ret    

c0105e2c <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm)
{
c0105e2c:	55                   	push   %ebp
c0105e2d:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105e2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e32:	83 e0 04             	and    $0x4,%eax
c0105e35:	85 c0                	test   %eax,%eax
c0105e37:	74 04                	je     c0105e3d <perm2str+0x11>
c0105e39:	b0 75                	mov    $0x75,%al
c0105e3b:	eb 02                	jmp    c0105e3f <perm2str+0x13>
c0105e3d:	b0 2d                	mov    $0x2d,%al
c0105e3f:	a2 28 70 12 c0       	mov    %al,0xc0127028
    str[1] = 'r';
c0105e44:	c6 05 29 70 12 c0 72 	movb   $0x72,0xc0127029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4e:	83 e0 02             	and    $0x2,%eax
c0105e51:	85 c0                	test   %eax,%eax
c0105e53:	74 04                	je     c0105e59 <perm2str+0x2d>
c0105e55:	b0 77                	mov    $0x77,%al
c0105e57:	eb 02                	jmp    c0105e5b <perm2str+0x2f>
c0105e59:	b0 2d                	mov    $0x2d,%al
c0105e5b:	a2 2a 70 12 c0       	mov    %al,0xc012702a
    str[3] = '\0';
c0105e60:	c6 05 2b 70 12 c0 00 	movb   $0x0,0xc012702b
    return str;
c0105e67:	b8 28 70 12 c0       	mov    $0xc0127028,%eax
}
c0105e6c:	5d                   	pop    %ebp
c0105e6d:	c3                   	ret    

c0105e6e <get_pgtable_items>:
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store)
{
c0105e6e:	55                   	push   %ebp
c0105e6f:	89 e5                	mov    %esp,%ebp
c0105e71:	83 ec 10             	sub    $0x10,%esp
    if (start >= right)
c0105e74:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e77:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e7a:	72 0d                	jb     c0105e89 <get_pgtable_items+0x1b>
    {
        return 0;
c0105e7c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105e81:	e9 98 00 00 00       	jmp    c0105f1e <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P))
    {
        start++;
c0105e86:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P))
c0105e89:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e8c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e8f:	73 18                	jae    c0105ea9 <get_pgtable_items+0x3b>
c0105e91:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105e9b:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e9e:	01 d0                	add    %edx,%eax
c0105ea0:	8b 00                	mov    (%eax),%eax
c0105ea2:	83 e0 01             	and    $0x1,%eax
c0105ea5:	85 c0                	test   %eax,%eax
c0105ea7:	74 dd                	je     c0105e86 <get_pgtable_items+0x18>
    }
    if (start < right)
c0105ea9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105eac:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105eaf:	73 68                	jae    c0105f19 <get_pgtable_items+0xab>
    {
        if (left_store != NULL)
c0105eb1:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105eb5:	74 08                	je     c0105ebf <get_pgtable_items+0x51>
        {
            *left_store = start;
c0105eb7:	8b 45 18             	mov    0x18(%ebp),%eax
c0105eba:	8b 55 10             	mov    0x10(%ebp),%edx
c0105ebd:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start++] & PTE_USER);
c0105ebf:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ec2:	8d 50 01             	lea    0x1(%eax),%edx
c0105ec5:	89 55 10             	mov    %edx,0x10(%ebp)
c0105ec8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105ecf:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ed2:	01 d0                	add    %edx,%eax
c0105ed4:	8b 00                	mov    (%eax),%eax
c0105ed6:	83 e0 07             	and    $0x7,%eax
c0105ed9:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c0105edc:	eb 03                	jmp    c0105ee1 <get_pgtable_items+0x73>
        {
            start++;
c0105ede:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm)
c0105ee1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ee4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105ee7:	73 1d                	jae    c0105f06 <get_pgtable_items+0x98>
c0105ee9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105eec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105ef3:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ef6:	01 d0                	add    %edx,%eax
c0105ef8:	8b 00                	mov    (%eax),%eax
c0105efa:	83 e0 07             	and    $0x7,%eax
c0105efd:	89 c2                	mov    %eax,%edx
c0105eff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f02:	39 c2                	cmp    %eax,%edx
c0105f04:	74 d8                	je     c0105ede <get_pgtable_items+0x70>
        }
        if (right_store != NULL)
c0105f06:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105f0a:	74 08                	je     c0105f14 <get_pgtable_items+0xa6>
        {
            *right_store = start;
c0105f0c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105f0f:	8b 55 10             	mov    0x10(%ebp),%edx
c0105f12:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f17:	eb 05                	jmp    c0105f1e <get_pgtable_items+0xb0>
    }
    return 0;
c0105f19:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f1e:	89 ec                	mov    %ebp,%esp
c0105f20:	5d                   	pop    %ebp
c0105f21:	c3                   	ret    

c0105f22 <print_pgdir>:

//print_pgdir - print the PDT&PT
void print_pgdir(void)
{
c0105f22:	55                   	push   %ebp
c0105f23:	89 e5                	mov    %esp,%ebp
c0105f25:	57                   	push   %edi
c0105f26:	56                   	push   %esi
c0105f27:	53                   	push   %ebx
c0105f28:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105f2b:	c7 04 24 74 a2 10 c0 	movl   $0xc010a274,(%esp)
c0105f32:	e8 2e a4 ff ff       	call   c0100365 <cprintf>
    size_t left, right = 0, perm;
c0105f37:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0105f3e:	e9 f2 00 00 00       	jmp    c0106035 <print_pgdir+0x113>
    {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f46:	89 04 24             	mov    %eax,(%esp)
c0105f49:	e8 de fe ff ff       	call   c0105e2c <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105f4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f51:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105f54:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105f56:	89 d6                	mov    %edx,%esi
c0105f58:	c1 e6 16             	shl    $0x16,%esi
c0105f5b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f5e:	89 d3                	mov    %edx,%ebx
c0105f60:	c1 e3 16             	shl    $0x16,%ebx
c0105f63:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105f66:	89 d1                	mov    %edx,%ecx
c0105f68:	c1 e1 16             	shl    $0x16,%ecx
c0105f6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105f6e:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0105f71:	29 fa                	sub    %edi,%edx
c0105f73:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105f77:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105f7f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105f83:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f87:	c7 04 24 a5 a2 10 c0 	movl   $0xc010a2a5,(%esp)
c0105f8e:	e8 d2 a3 ff ff       	call   c0100365 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0105f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105f96:	c1 e0 0a             	shl    $0xa,%eax
c0105f99:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c0105f9c:	eb 50                	jmp    c0105fee <print_pgdir+0xcc>
        {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fa1:	89 04 24             	mov    %eax,(%esp)
c0105fa4:	e8 83 fe ff ff       	call   c0105e2c <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105fa9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105fac:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0105faf:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105fb1:	89 d6                	mov    %edx,%esi
c0105fb3:	c1 e6 0c             	shl    $0xc,%esi
c0105fb6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105fb9:	89 d3                	mov    %edx,%ebx
c0105fbb:	c1 e3 0c             	shl    $0xc,%ebx
c0105fbe:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105fc1:	89 d1                	mov    %edx,%ecx
c0105fc3:	c1 e1 0c             	shl    $0xc,%ecx
c0105fc6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105fc9:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0105fcc:	29 fa                	sub    %edi,%edx
c0105fce:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105fd2:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105fd6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105fda:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105fde:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105fe2:	c7 04 24 c4 a2 10 c0 	movl   $0xc010a2c4,(%esp)
c0105fe9:	e8 77 a3 ff ff       	call   c0100365 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0)
c0105fee:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0105ff3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ff6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105ff9:	89 d3                	mov    %edx,%ebx
c0105ffb:	c1 e3 0a             	shl    $0xa,%ebx
c0105ffe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106001:	89 d1                	mov    %edx,%ecx
c0106003:	c1 e1 0a             	shl    $0xa,%ecx
c0106006:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0106009:	89 54 24 14          	mov    %edx,0x14(%esp)
c010600d:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0106010:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106014:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106018:	89 44 24 08          	mov    %eax,0x8(%esp)
c010601c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106020:	89 0c 24             	mov    %ecx,(%esp)
c0106023:	e8 46 fe ff ff       	call   c0105e6e <get_pgtable_items>
c0106028:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010602b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010602f:	0f 85 69 ff ff ff    	jne    c0105f9e <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0)
c0106035:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010603a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010603d:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106040:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106044:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0106047:	89 54 24 10          	mov    %edx,0x10(%esp)
c010604b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010604f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106053:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010605a:	00 
c010605b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106062:	e8 07 fe ff ff       	call   c0105e6e <get_pgtable_items>
c0106067:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010606a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010606e:	0f 85 cf fe ff ff    	jne    c0105f43 <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106074:	c7 04 24 e8 a2 10 c0 	movl   $0xc010a2e8,(%esp)
c010607b:	e8 e5 a2 ff ff       	call   c0100365 <cprintf>
}
c0106080:	90                   	nop
c0106081:	83 c4 4c             	add    $0x4c,%esp
c0106084:	5b                   	pop    %ebx
c0106085:	5e                   	pop    %esi
c0106086:	5f                   	pop    %edi
c0106087:	5d                   	pop    %ebp
c0106088:	c3                   	ret    

c0106089 <kmalloc>:

void *
kmalloc(size_t n)
{
c0106089:	55                   	push   %ebp
c010608a:	89 e5                	mov    %esp,%ebp
c010608c:	83 ec 28             	sub    $0x28,%esp
    void *ptr = NULL;
c010608f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base = NULL;
c0106096:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024 * 0124);
c010609d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01060a1:	74 09                	je     c01060ac <kmalloc+0x23>
c01060a3:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c01060aa:	76 24                	jbe    c01060d0 <kmalloc+0x47>
c01060ac:	c7 44 24 0c 19 a3 10 	movl   $0xc010a319,0xc(%esp)
c01060b3:	c0 
c01060b4:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c01060bb:	c0 
c01060bc:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
c01060c3:	00 
c01060c4:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c01060cb:	e8 1d ac ff ff       	call   c0100ced <__panic>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
c01060d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01060d3:	05 ff 0f 00 00       	add    $0xfff,%eax
c01060d8:	c1 e8 0c             	shr    $0xc,%eax
c01060db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c01060de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060e1:	89 04 24             	mov    %eax,(%esp)
c01060e4:	e8 14 e8 ff ff       	call   c01048fd <alloc_pages>
c01060e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c01060ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01060f0:	75 24                	jne    c0106116 <kmalloc+0x8d>
c01060f2:	c7 44 24 0c 32 a3 10 	movl   $0xc010a332,0xc(%esp)
c01060f9:	c0 
c01060fa:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0106101:	c0 
c0106102:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
c0106109:	00 
c010610a:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0106111:	e8 d7 ab ff ff       	call   c0100ced <__panic>
    ptr = page2kva(base);
c0106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106119:	89 04 24             	mov    %eax,(%esp)
c010611c:	e8 d0 e4 ff ff       	call   c01045f1 <page2kva>
c0106121:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0106124:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106127:	89 ec                	mov    %ebp,%esp
c0106129:	5d                   	pop    %ebp
c010612a:	c3                   	ret    

c010612b <kfree>:

void kfree(void *ptr, size_t n)
{
c010612b:	55                   	push   %ebp
c010612c:	89 e5                	mov    %esp,%ebp
c010612e:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024 * 0124);
c0106131:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106135:	74 09                	je     c0106140 <kfree+0x15>
c0106137:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c010613e:	76 24                	jbe    c0106164 <kfree+0x39>
c0106140:	c7 44 24 0c 19 a3 10 	movl   $0xc010a319,0xc(%esp)
c0106147:	c0 
c0106148:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c010614f:	c0 
c0106150:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
c0106157:	00 
c0106158:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c010615f:	e8 89 ab ff ff       	call   c0100ced <__panic>
    assert(ptr != NULL);
c0106164:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106168:	75 24                	jne    c010618e <kfree+0x63>
c010616a:	c7 44 24 0c 3f a3 10 	movl   $0xc010a33f,0xc(%esp)
c0106171:	c0 
c0106172:	c7 44 24 08 bd 9d 10 	movl   $0xc0109dbd,0x8(%esp)
c0106179:	c0 
c010617a:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
c0106181:	00 
c0106182:	c7 04 24 98 9d 10 c0 	movl   $0xc0109d98,(%esp)
c0106189:	e8 5f ab ff ff       	call   c0100ced <__panic>
    struct Page *base = NULL;
c010618e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
c0106195:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106198:	05 ff 0f 00 00       	add    $0xfff,%eax
c010619d:	c1 e8 0c             	shr    $0xc,%eax
c01061a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c01061a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a6:	89 04 24             	mov    %eax,(%esp)
c01061a9:	e8 99 e4 ff ff       	call   c0104647 <kva2page>
c01061ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c01061b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061bb:	89 04 24             	mov    %eax,(%esp)
c01061be:	e8 a7 e7 ff ff       	call   c010496a <free_pages>
}
c01061c3:	90                   	nop
c01061c4:	89 ec                	mov    %ebp,%esp
c01061c6:	5d                   	pop    %ebp
c01061c7:	c3                   	ret    

c01061c8 <pa2page>:
pa2page(uintptr_t pa) {
c01061c8:	55                   	push   %ebp
c01061c9:	89 e5                	mov    %esp,%ebp
c01061cb:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01061ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01061d1:	c1 e8 0c             	shr    $0xc,%eax
c01061d4:	89 c2                	mov    %eax,%edx
c01061d6:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c01061db:	39 c2                	cmp    %eax,%edx
c01061dd:	72 1c                	jb     c01061fb <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01061df:	c7 44 24 08 4c a3 10 	movl   $0xc010a34c,0x8(%esp)
c01061e6:	c0 
c01061e7:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01061ee:	00 
c01061ef:	c7 04 24 6b a3 10 c0 	movl   $0xc010a36b,(%esp)
c01061f6:	e8 f2 aa ff ff       	call   c0100ced <__panic>
    return &pages[PPN(pa)];
c01061fb:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0106201:	8b 45 08             	mov    0x8(%ebp),%eax
c0106204:	c1 e8 0c             	shr    $0xc,%eax
c0106207:	c1 e0 05             	shl    $0x5,%eax
c010620a:	01 d0                	add    %edx,%eax
}
c010620c:	89 ec                	mov    %ebp,%esp
c010620e:	5d                   	pop    %ebp
c010620f:	c3                   	ret    

c0106210 <pte2page>:
pte2page(pte_t pte) {
c0106210:	55                   	push   %ebp
c0106211:	89 e5                	mov    %esp,%ebp
c0106213:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106216:	8b 45 08             	mov    0x8(%ebp),%eax
c0106219:	83 e0 01             	and    $0x1,%eax
c010621c:	85 c0                	test   %eax,%eax
c010621e:	75 1c                	jne    c010623c <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106220:	c7 44 24 08 7c a3 10 	movl   $0xc010a37c,0x8(%esp)
c0106227:	c0 
c0106228:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010622f:	00 
c0106230:	c7 04 24 6b a3 10 c0 	movl   $0xc010a36b,(%esp)
c0106237:	e8 b1 aa ff ff       	call   c0100ced <__panic>
    return pa2page(PTE_ADDR(pte));
c010623c:	8b 45 08             	mov    0x8(%ebp),%eax
c010623f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106244:	89 04 24             	mov    %eax,(%esp)
c0106247:	e8 7c ff ff ff       	call   c01061c8 <pa2page>
}
c010624c:	89 ec                	mov    %ebp,%esp
c010624e:	5d                   	pop    %ebp
c010624f:	c3                   	ret    

c0106250 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106250:	55                   	push   %ebp
c0106251:	89 e5                	mov    %esp,%ebp
c0106253:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106256:	e8 1e 20 00 00       	call   c0108279 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010625b:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106260:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106265:	76 0c                	jbe    c0106273 <swap_init+0x23>
c0106267:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c010626c:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106271:	76 25                	jbe    c0106298 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106273:	a1 40 70 12 c0       	mov    0xc0127040,%eax
c0106278:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010627c:	c7 44 24 08 9d a3 10 	movl   $0xc010a39d,0x8(%esp)
c0106283:	c0 
c0106284:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c010628b:	00 
c010628c:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106293:	e8 55 aa ff ff       	call   c0100ced <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106298:	c7 05 00 71 12 c0 40 	movl   $0xc0123a40,0xc0127100
c010629f:	3a 12 c0 
     int r = sm->init();
c01062a2:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01062a7:	8b 40 04             	mov    0x4(%eax),%eax
c01062aa:	ff d0                	call   *%eax
c01062ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01062af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01062b3:	75 26                	jne    c01062db <swap_init+0x8b>
     {
          swap_init_ok = 1;
c01062b5:	c7 05 44 70 12 c0 01 	movl   $0x1,0xc0127044
c01062bc:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01062bf:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01062c4:	8b 00                	mov    (%eax),%eax
c01062c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062ca:	c7 04 24 c7 a3 10 c0 	movl   $0xc010a3c7,(%esp)
c01062d1:	e8 8f a0 ff ff       	call   c0100365 <cprintf>
          check_swap();
c01062d6:	e8 b0 04 00 00       	call   c010678b <check_swap>
     }

     return r;
c01062db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01062de:	89 ec                	mov    %ebp,%esp
c01062e0:	5d                   	pop    %ebp
c01062e1:	c3                   	ret    

c01062e2 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01062e2:	55                   	push   %ebp
c01062e3:	89 e5                	mov    %esp,%ebp
c01062e5:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01062e8:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c01062ed:	8b 40 08             	mov    0x8(%eax),%eax
c01062f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01062f3:	89 14 24             	mov    %edx,(%esp)
c01062f6:	ff d0                	call   *%eax
}
c01062f8:	89 ec                	mov    %ebp,%esp
c01062fa:	5d                   	pop    %ebp
c01062fb:	c3                   	ret    

c01062fc <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01062fc:	55                   	push   %ebp
c01062fd:	89 e5                	mov    %esp,%ebp
c01062ff:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106302:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106307:	8b 40 0c             	mov    0xc(%eax),%eax
c010630a:	8b 55 08             	mov    0x8(%ebp),%edx
c010630d:	89 14 24             	mov    %edx,(%esp)
c0106310:	ff d0                	call   *%eax
}
c0106312:	89 ec                	mov    %ebp,%esp
c0106314:	5d                   	pop    %ebp
c0106315:	c3                   	ret    

c0106316 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106316:	55                   	push   %ebp
c0106317:	89 e5                	mov    %esp,%ebp
c0106319:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010631c:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106321:	8b 40 10             	mov    0x10(%eax),%eax
c0106324:	8b 55 14             	mov    0x14(%ebp),%edx
c0106327:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010632b:	8b 55 10             	mov    0x10(%ebp),%edx
c010632e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106332:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106335:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106339:	8b 55 08             	mov    0x8(%ebp),%edx
c010633c:	89 14 24             	mov    %edx,(%esp)
c010633f:	ff d0                	call   *%eax
}
c0106341:	89 ec                	mov    %ebp,%esp
c0106343:	5d                   	pop    %ebp
c0106344:	c3                   	ret    

c0106345 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106345:	55                   	push   %ebp
c0106346:	89 e5                	mov    %esp,%ebp
c0106348:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c010634b:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106350:	8b 40 14             	mov    0x14(%eax),%eax
c0106353:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106356:	89 54 24 04          	mov    %edx,0x4(%esp)
c010635a:	8b 55 08             	mov    0x8(%ebp),%edx
c010635d:	89 14 24             	mov    %edx,(%esp)
c0106360:	ff d0                	call   *%eax
}
c0106362:	89 ec                	mov    %ebp,%esp
c0106364:	5d                   	pop    %ebp
c0106365:	c3                   	ret    

c0106366 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106366:	55                   	push   %ebp
c0106367:	89 e5                	mov    %esp,%ebp
c0106369:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c010636c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106373:	e9 53 01 00 00       	jmp    c01064cb <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106378:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010637d:	8b 40 18             	mov    0x18(%eax),%eax
c0106380:	8b 55 10             	mov    0x10(%ebp),%edx
c0106383:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106387:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c010638a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010638e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106391:	89 14 24             	mov    %edx,(%esp)
c0106394:	ff d0                	call   *%eax
c0106396:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106399:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010639d:	74 18                	je     c01063b7 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c010639f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063a6:	c7 04 24 dc a3 10 c0 	movl   $0xc010a3dc,(%esp)
c01063ad:	e8 b3 9f ff ff       	call   c0100365 <cprintf>
c01063b2:	e9 20 01 00 00       	jmp    c01064d7 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01063b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063ba:	8b 40 1c             	mov    0x1c(%eax),%eax
c01063bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01063c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c3:	8b 40 0c             	mov    0xc(%eax),%eax
c01063c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01063cd:	00 
c01063ce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01063d1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063d5:	89 04 24             	mov    %eax,(%esp)
c01063d8:	e8 d6 eb ff ff       	call   c0104fb3 <get_pte>
c01063dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01063e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063e3:	8b 00                	mov    (%eax),%eax
c01063e5:	83 e0 01             	and    $0x1,%eax
c01063e8:	85 c0                	test   %eax,%eax
c01063ea:	75 24                	jne    c0106410 <swap_out+0xaa>
c01063ec:	c7 44 24 0c 09 a4 10 	movl   $0xc010a409,0xc(%esp)
c01063f3:	c0 
c01063f4:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01063fb:	c0 
c01063fc:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0106403:	00 
c0106404:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c010640b:	e8 dd a8 ff ff       	call   c0100ced <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106416:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106419:	c1 ea 0c             	shr    $0xc,%edx
c010641c:	42                   	inc    %edx
c010641d:	c1 e2 08             	shl    $0x8,%edx
c0106420:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106424:	89 14 24             	mov    %edx,(%esp)
c0106427:	e8 0c 1f 00 00       	call   c0108338 <swapfs_write>
c010642c:	85 c0                	test   %eax,%eax
c010642e:	74 34                	je     c0106464 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0106430:	c7 04 24 33 a4 10 c0 	movl   $0xc010a433,(%esp)
c0106437:	e8 29 9f ff ff       	call   c0100365 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c010643c:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c0106441:	8b 40 10             	mov    0x10(%eax),%eax
c0106444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106447:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010644e:	00 
c010644f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106453:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106456:	89 54 24 04          	mov    %edx,0x4(%esp)
c010645a:	8b 55 08             	mov    0x8(%ebp),%edx
c010645d:	89 14 24             	mov    %edx,(%esp)
c0106460:	ff d0                	call   *%eax
c0106462:	eb 64                	jmp    c01064c8 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106467:	8b 40 1c             	mov    0x1c(%eax),%eax
c010646a:	c1 e8 0c             	shr    $0xc,%eax
c010646d:	40                   	inc    %eax
c010646e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106472:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106475:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106479:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010647c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106480:	c7 04 24 4c a4 10 c0 	movl   $0xc010a44c,(%esp)
c0106487:	e8 d9 9e ff ff       	call   c0100365 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c010648c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010648f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106492:	c1 e8 0c             	shr    $0xc,%eax
c0106495:	40                   	inc    %eax
c0106496:	c1 e0 08             	shl    $0x8,%eax
c0106499:	89 c2                	mov    %eax,%edx
c010649b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010649e:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01064a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01064aa:	00 
c01064ab:	89 04 24             	mov    %eax,(%esp)
c01064ae:	e8 b7 e4 ff ff       	call   c010496a <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c01064b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b6:	8b 40 0c             	mov    0xc(%eax),%eax
c01064b9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01064bc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064c0:	89 04 24             	mov    %eax,(%esp)
c01064c3:	e8 ed ed ff ff       	call   c01052b5 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c01064c8:	ff 45 f4             	incl   -0xc(%ebp)
c01064cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01064ce:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01064d1:	0f 85 a1 fe ff ff    	jne    c0106378 <swap_out+0x12>
     }
     return i;
c01064d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01064da:	89 ec                	mov    %ebp,%esp
c01064dc:	5d                   	pop    %ebp
c01064dd:	c3                   	ret    

c01064de <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01064de:	55                   	push   %ebp
c01064df:	89 e5                	mov    %esp,%ebp
c01064e1:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01064e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01064eb:	e8 0d e4 ff ff       	call   c01048fd <alloc_pages>
c01064f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01064f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01064f7:	75 24                	jne    c010651d <swap_in+0x3f>
c01064f9:	c7 44 24 0c 8c a4 10 	movl   $0xc010a48c,0xc(%esp)
c0106500:	c0 
c0106501:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106508:	c0 
c0106509:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0106510:	00 
c0106511:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106518:	e8 d0 a7 ff ff       	call   c0100ced <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c010651d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106520:	8b 40 0c             	mov    0xc(%eax),%eax
c0106523:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010652a:	00 
c010652b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010652e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106532:	89 04 24             	mov    %eax,(%esp)
c0106535:	e8 79 ea ff ff       	call   c0104fb3 <get_pte>
c010653a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c010653d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106540:	8b 00                	mov    (%eax),%eax
c0106542:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106545:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106549:	89 04 24             	mov    %eax,(%esp)
c010654c:	e8 73 1d 00 00       	call   c01082c4 <swapfs_read>
c0106551:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106554:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106558:	74 2a                	je     c0106584 <swap_in+0xa6>
     {
        assert(r!=0);
c010655a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010655e:	75 24                	jne    c0106584 <swap_in+0xa6>
c0106560:	c7 44 24 0c 99 a4 10 	movl   $0xc010a499,0xc(%esp)
c0106567:	c0 
c0106568:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c010656f:	c0 
c0106570:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106577:	00 
c0106578:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c010657f:	e8 69 a7 ff ff       	call   c0100ced <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106587:	8b 00                	mov    (%eax),%eax
c0106589:	c1 e8 08             	shr    $0x8,%eax
c010658c:	89 c2                	mov    %eax,%edx
c010658e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106591:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106595:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106599:	c7 04 24 a0 a4 10 c0 	movl   $0xc010a4a0,(%esp)
c01065a0:	e8 c0 9d ff ff       	call   c0100365 <cprintf>
     *ptr_result=result;
c01065a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01065a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01065ab:	89 10                	mov    %edx,(%eax)
     return 0;
c01065ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01065b2:	89 ec                	mov    %ebp,%esp
c01065b4:	5d                   	pop    %ebp
c01065b5:	c3                   	ret    

c01065b6 <check_content_set>:



static inline void
check_content_set(void)
{
c01065b6:	55                   	push   %ebp
c01065b7:	89 e5                	mov    %esp,%ebp
c01065b9:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01065bc:	b8 00 10 00 00       	mov    $0x1000,%eax
c01065c1:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01065c4:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01065c9:	83 f8 01             	cmp    $0x1,%eax
c01065cc:	74 24                	je     c01065f2 <check_content_set+0x3c>
c01065ce:	c7 44 24 0c de a4 10 	movl   $0xc010a4de,0xc(%esp)
c01065d5:	c0 
c01065d6:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01065dd:	c0 
c01065de:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c01065e5:	00 
c01065e6:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01065ed:	e8 fb a6 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01065f2:	b8 10 10 00 00       	mov    $0x1010,%eax
c01065f7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01065fa:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01065ff:	83 f8 01             	cmp    $0x1,%eax
c0106602:	74 24                	je     c0106628 <check_content_set+0x72>
c0106604:	c7 44 24 0c de a4 10 	movl   $0xc010a4de,0xc(%esp)
c010660b:	c0 
c010660c:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106613:	c0 
c0106614:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c010661b:	00 
c010661c:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106623:	e8 c5 a6 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106628:	b8 00 20 00 00       	mov    $0x2000,%eax
c010662d:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106630:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106635:	83 f8 02             	cmp    $0x2,%eax
c0106638:	74 24                	je     c010665e <check_content_set+0xa8>
c010663a:	c7 44 24 0c ed a4 10 	movl   $0xc010a4ed,0xc(%esp)
c0106641:	c0 
c0106642:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106649:	c0 
c010664a:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106651:	00 
c0106652:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106659:	e8 8f a6 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010665e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106663:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106666:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010666b:	83 f8 02             	cmp    $0x2,%eax
c010666e:	74 24                	je     c0106694 <check_content_set+0xde>
c0106670:	c7 44 24 0c ed a4 10 	movl   $0xc010a4ed,0xc(%esp)
c0106677:	c0 
c0106678:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c010667f:	c0 
c0106680:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106687:	00 
c0106688:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c010668f:	e8 59 a6 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106694:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106699:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010669c:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01066a1:	83 f8 03             	cmp    $0x3,%eax
c01066a4:	74 24                	je     c01066ca <check_content_set+0x114>
c01066a6:	c7 44 24 0c fc a4 10 	movl   $0xc010a4fc,0xc(%esp)
c01066ad:	c0 
c01066ae:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01066b5:	c0 
c01066b6:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c01066bd:	00 
c01066be:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01066c5:	e8 23 a6 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01066ca:	b8 10 30 00 00       	mov    $0x3010,%eax
c01066cf:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01066d2:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01066d7:	83 f8 03             	cmp    $0x3,%eax
c01066da:	74 24                	je     c0106700 <check_content_set+0x14a>
c01066dc:	c7 44 24 0c fc a4 10 	movl   $0xc010a4fc,0xc(%esp)
c01066e3:	c0 
c01066e4:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01066eb:	c0 
c01066ec:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c01066f3:	00 
c01066f4:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01066fb:	e8 ed a5 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106700:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106705:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106708:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010670d:	83 f8 04             	cmp    $0x4,%eax
c0106710:	74 24                	je     c0106736 <check_content_set+0x180>
c0106712:	c7 44 24 0c 0b a5 10 	movl   $0xc010a50b,0xc(%esp)
c0106719:	c0 
c010671a:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106721:	c0 
c0106722:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106729:	00 
c010672a:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106731:	e8 b7 a5 ff ff       	call   c0100ced <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106736:	b8 10 40 00 00       	mov    $0x4010,%eax
c010673b:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010673e:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0106743:	83 f8 04             	cmp    $0x4,%eax
c0106746:	74 24                	je     c010676c <check_content_set+0x1b6>
c0106748:	c7 44 24 0c 0b a5 10 	movl   $0xc010a50b,0xc(%esp)
c010674f:	c0 
c0106750:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106757:	c0 
c0106758:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c010675f:	00 
c0106760:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106767:	e8 81 a5 ff ff       	call   c0100ced <__panic>
}
c010676c:	90                   	nop
c010676d:	89 ec                	mov    %ebp,%esp
c010676f:	5d                   	pop    %ebp
c0106770:	c3                   	ret    

c0106771 <check_content_access>:

static inline int
check_content_access(void)
{
c0106771:	55                   	push   %ebp
c0106772:	89 e5                	mov    %esp,%ebp
c0106774:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106777:	a1 00 71 12 c0       	mov    0xc0127100,%eax
c010677c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010677f:	ff d0                	call   *%eax
c0106781:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106784:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106787:	89 ec                	mov    %ebp,%esp
c0106789:	5d                   	pop    %ebp
c010678a:	c3                   	ret    

c010678b <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010678b:	55                   	push   %ebp
c010678c:	89 e5                	mov    %esp,%ebp
c010678e:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106791:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106798:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010679f:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01067a6:	eb 6a                	jmp    c0106812 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c01067a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01067ab:	83 e8 0c             	sub    $0xc,%eax
c01067ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c01067b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01067b4:	83 c0 04             	add    $0x4,%eax
c01067b7:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01067be:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01067c1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01067c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01067c7:	0f a3 10             	bt     %edx,(%eax)
c01067ca:	19 c0                	sbb    %eax,%eax
c01067cc:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c01067cf:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01067d3:	0f 95 c0             	setne  %al
c01067d6:	0f b6 c0             	movzbl %al,%eax
c01067d9:	85 c0                	test   %eax,%eax
c01067db:	75 24                	jne    c0106801 <check_swap+0x76>
c01067dd:	c7 44 24 0c 1a a5 10 	movl   $0xc010a51a,0xc(%esp)
c01067e4:	c0 
c01067e5:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01067ec:	c0 
c01067ed:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01067f4:	00 
c01067f5:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01067fc:	e8 ec a4 ff ff       	call   c0100ced <__panic>
        count ++, total += p->property;
c0106801:	ff 45 f4             	incl   -0xc(%ebp)
c0106804:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106807:	8b 50 08             	mov    0x8(%eax),%edx
c010680a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010680d:	01 d0                	add    %edx,%eax
c010680f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106812:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106815:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106818:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010681b:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c010681e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106821:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c0106828:	0f 85 7a ff ff ff    	jne    c01067a8 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c010682e:	e8 6c e1 ff ff       	call   c010499f <nr_free_pages>
c0106833:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106836:	39 d0                	cmp    %edx,%eax
c0106838:	74 24                	je     c010685e <check_swap+0xd3>
c010683a:	c7 44 24 0c 2a a5 10 	movl   $0xc010a52a,0xc(%esp)
c0106841:	c0 
c0106842:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106849:	c0 
c010684a:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0106851:	00 
c0106852:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106859:	e8 8f a4 ff ff       	call   c0100ced <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010685e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106861:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106865:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106868:	89 44 24 04          	mov    %eax,0x4(%esp)
c010686c:	c7 04 24 44 a5 10 c0 	movl   $0xc010a544,(%esp)
c0106873:	e8 ed 9a ff ff       	call   c0100365 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106878:	e8 40 0c 00 00       	call   c01074bd <mm_create>
c010687d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106880:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106884:	75 24                	jne    c01068aa <check_swap+0x11f>
c0106886:	c7 44 24 0c 6a a5 10 	movl   $0xc010a56a,0xc(%esp)
c010688d:	c0 
c010688e:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106895:	c0 
c0106896:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010689d:	00 
c010689e:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01068a5:	e8 43 a4 ff ff       	call   c0100ced <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01068aa:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c01068af:	85 c0                	test   %eax,%eax
c01068b1:	74 24                	je     c01068d7 <check_swap+0x14c>
c01068b3:	c7 44 24 0c 75 a5 10 	movl   $0xc010a575,0xc(%esp)
c01068ba:	c0 
c01068bb:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01068c2:	c0 
c01068c3:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c01068ca:	00 
c01068cb:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01068d2:	e8 16 a4 ff ff       	call   c0100ced <__panic>

     check_mm_struct = mm;
c01068d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068da:	a3 0c 71 12 c0       	mov    %eax,0xc012710c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c01068df:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c01068e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068e8:	89 50 0c             	mov    %edx,0xc(%eax)
c01068eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068ee:	8b 40 0c             	mov    0xc(%eax),%eax
c01068f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c01068f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068f7:	8b 00                	mov    (%eax),%eax
c01068f9:	85 c0                	test   %eax,%eax
c01068fb:	74 24                	je     c0106921 <check_swap+0x196>
c01068fd:	c7 44 24 0c 8d a5 10 	movl   $0xc010a58d,0xc(%esp)
c0106904:	c0 
c0106905:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c010690c:	c0 
c010690d:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106914:	00 
c0106915:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c010691c:	e8 cc a3 ff ff       	call   c0100ced <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106921:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106928:	00 
c0106929:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106930:	00 
c0106931:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106938:	e8 fb 0b 00 00       	call   c0107538 <vma_create>
c010693d:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106940:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106944:	75 24                	jne    c010696a <check_swap+0x1df>
c0106946:	c7 44 24 0c 9b a5 10 	movl   $0xc010a59b,0xc(%esp)
c010694d:	c0 
c010694e:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106955:	c0 
c0106956:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010695d:	00 
c010695e:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106965:	e8 83 a3 ff ff       	call   c0100ced <__panic>

     insert_vma_struct(mm, vma);
c010696a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010696d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106974:	89 04 24             	mov    %eax,(%esp)
c0106977:	e8 53 0d 00 00       	call   c01076cf <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010697c:	c7 04 24 a8 a5 10 c0 	movl   $0xc010a5a8,(%esp)
c0106983:	e8 dd 99 ff ff       	call   c0100365 <cprintf>
     pte_t *temp_ptep=NULL;
c0106988:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010698f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106992:	8b 40 0c             	mov    0xc(%eax),%eax
c0106995:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010699c:	00 
c010699d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01069a4:	00 
c01069a5:	89 04 24             	mov    %eax,(%esp)
c01069a8:	e8 06 e6 ff ff       	call   c0104fb3 <get_pte>
c01069ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c01069b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01069b4:	75 24                	jne    c01069da <check_swap+0x24f>
c01069b6:	c7 44 24 0c dc a5 10 	movl   $0xc010a5dc,0xc(%esp)
c01069bd:	c0 
c01069be:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c01069c5:	c0 
c01069c6:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01069cd:	00 
c01069ce:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c01069d5:	e8 13 a3 ff ff       	call   c0100ced <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c01069da:	c7 04 24 f0 a5 10 c0 	movl   $0xc010a5f0,(%esp)
c01069e1:	e8 7f 99 ff ff       	call   c0100365 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01069e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01069ed:	e9 a2 00 00 00       	jmp    c0106a94 <check_swap+0x309>
          check_rp[i] = alloc_page();
c01069f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069f9:	e8 ff de ff ff       	call   c01048fd <alloc_pages>
c01069fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a01:	89 04 95 cc 70 12 c0 	mov    %eax,-0x3fed8f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0106a08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a0b:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106a12:	85 c0                	test   %eax,%eax
c0106a14:	75 24                	jne    c0106a3a <check_swap+0x2af>
c0106a16:	c7 44 24 0c 14 a6 10 	movl   $0xc010a614,0xc(%esp)
c0106a1d:	c0 
c0106a1e:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106a25:	c0 
c0106a26:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0106a2d:	00 
c0106a2e:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106a35:	e8 b3 a2 ff ff       	call   c0100ced <__panic>
          assert(!PageProperty(check_rp[i]));
c0106a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a3d:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106a44:	83 c0 04             	add    $0x4,%eax
c0106a47:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0106a4e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106a51:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106a54:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106a57:	0f a3 10             	bt     %edx,(%eax)
c0106a5a:	19 c0                	sbb    %eax,%eax
c0106a5c:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0106a5f:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0106a63:	0f 95 c0             	setne  %al
c0106a66:	0f b6 c0             	movzbl %al,%eax
c0106a69:	85 c0                	test   %eax,%eax
c0106a6b:	74 24                	je     c0106a91 <check_swap+0x306>
c0106a6d:	c7 44 24 0c 28 a6 10 	movl   $0xc010a628,0xc(%esp)
c0106a74:	c0 
c0106a75:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106a7c:	c0 
c0106a7d:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106a84:	00 
c0106a85:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106a8c:	e8 5c a2 ff ff       	call   c0100ced <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106a91:	ff 45 ec             	incl   -0x14(%ebp)
c0106a94:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106a98:	0f 8e 54 ff ff ff    	jle    c01069f2 <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c0106a9e:	a1 84 6f 12 c0       	mov    0xc0126f84,%eax
c0106aa3:	8b 15 88 6f 12 c0    	mov    0xc0126f88,%edx
c0106aa9:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106aac:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106aaf:	c7 45 a4 84 6f 12 c0 	movl   $0xc0126f84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c0106ab6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106ab9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106abc:	89 50 04             	mov    %edx,0x4(%eax)
c0106abf:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106ac2:	8b 50 04             	mov    0x4(%eax),%edx
c0106ac5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106ac8:	89 10                	mov    %edx,(%eax)
}
c0106aca:	90                   	nop
c0106acb:	c7 45 a8 84 6f 12 c0 	movl   $0xc0126f84,-0x58(%ebp)
    return list->next == list;
c0106ad2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106ad5:	8b 40 04             	mov    0x4(%eax),%eax
c0106ad8:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c0106adb:	0f 94 c0             	sete   %al
c0106ade:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106ae1:	85 c0                	test   %eax,%eax
c0106ae3:	75 24                	jne    c0106b09 <check_swap+0x37e>
c0106ae5:	c7 44 24 0c 43 a6 10 	movl   $0xc010a643,0xc(%esp)
c0106aec:	c0 
c0106aed:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106af4:	c0 
c0106af5:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0106afc:	00 
c0106afd:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106b04:	e8 e4 a1 ff ff       	call   c0100ced <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0106b09:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106b0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0106b11:	c7 05 8c 6f 12 c0 00 	movl   $0x0,0xc0126f8c
c0106b18:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b1b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106b22:	eb 1d                	jmp    c0106b41 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c0106b24:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b27:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106b2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b35:	00 
c0106b36:	89 04 24             	mov    %eax,(%esp)
c0106b39:	e8 2c de ff ff       	call   c010496a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b3e:	ff 45 ec             	incl   -0x14(%ebp)
c0106b41:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106b45:	7e dd                	jle    c0106b24 <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0106b47:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106b4c:	83 f8 04             	cmp    $0x4,%eax
c0106b4f:	74 24                	je     c0106b75 <check_swap+0x3ea>
c0106b51:	c7 44 24 0c 5c a6 10 	movl   $0xc010a65c,0xc(%esp)
c0106b58:	c0 
c0106b59:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106b60:	c0 
c0106b61:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0106b68:	00 
c0106b69:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106b70:	e8 78 a1 ff ff       	call   c0100ced <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106b75:	c7 04 24 80 a6 10 c0 	movl   $0xc010a680,(%esp)
c0106b7c:	e8 e4 97 ff ff       	call   c0100365 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106b81:	c7 05 10 71 12 c0 00 	movl   $0x0,0xc0127110
c0106b88:	00 00 00 
     
     check_content_set();
c0106b8b:	e8 26 fa ff ff       	call   c01065b6 <check_content_set>
     assert( nr_free == 0);         
c0106b90:	a1 8c 6f 12 c0       	mov    0xc0126f8c,%eax
c0106b95:	85 c0                	test   %eax,%eax
c0106b97:	74 24                	je     c0106bbd <check_swap+0x432>
c0106b99:	c7 44 24 0c a7 a6 10 	movl   $0xc010a6a7,0xc(%esp)
c0106ba0:	c0 
c0106ba1:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106ba8:	c0 
c0106ba9:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106bb0:	00 
c0106bb1:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106bb8:	e8 30 a1 ff ff       	call   c0100ced <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106bbd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106bc4:	eb 25                	jmp    c0106beb <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106bc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bc9:	c7 04 85 60 70 12 c0 	movl   $0xffffffff,-0x3fed8fa0(,%eax,4)
c0106bd0:	ff ff ff ff 
c0106bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106bd7:	8b 14 85 60 70 12 c0 	mov    -0x3fed8fa0(,%eax,4),%edx
c0106bde:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106be1:	89 14 85 a0 70 12 c0 	mov    %edx,-0x3fed8f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106be8:	ff 45 ec             	incl   -0x14(%ebp)
c0106beb:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106bef:	7e d5                	jle    c0106bc6 <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106bf1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106bf8:	e9 e8 00 00 00       	jmp    c0106ce5 <check_swap+0x55a>
         check_ptep[i]=0;
c0106bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c00:	c7 04 85 dc 70 12 c0 	movl   $0x0,-0x3fed8f24(,%eax,4)
c0106c07:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c0e:	40                   	inc    %eax
c0106c0f:	c1 e0 0c             	shl    $0xc,%eax
c0106c12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106c19:	00 
c0106c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c21:	89 04 24             	mov    %eax,(%esp)
c0106c24:	e8 8a e3 ff ff       	call   c0104fb3 <get_pte>
c0106c29:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106c2c:	89 04 95 dc 70 12 c0 	mov    %eax,-0x3fed8f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c36:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106c3d:	85 c0                	test   %eax,%eax
c0106c3f:	75 24                	jne    c0106c65 <check_swap+0x4da>
c0106c41:	c7 44 24 0c b4 a6 10 	movl   $0xc010a6b4,0xc(%esp)
c0106c48:	c0 
c0106c49:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106c50:	c0 
c0106c51:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0106c58:	00 
c0106c59:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106c60:	e8 88 a0 ff ff       	call   c0100ced <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106c65:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c68:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106c6f:	8b 00                	mov    (%eax),%eax
c0106c71:	89 04 24             	mov    %eax,(%esp)
c0106c74:	e8 97 f5 ff ff       	call   c0106210 <pte2page>
c0106c79:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106c7c:	8b 14 95 cc 70 12 c0 	mov    -0x3fed8f34(,%edx,4),%edx
c0106c83:	39 d0                	cmp    %edx,%eax
c0106c85:	74 24                	je     c0106cab <check_swap+0x520>
c0106c87:	c7 44 24 0c cc a6 10 	movl   $0xc010a6cc,0xc(%esp)
c0106c8e:	c0 
c0106c8f:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106c96:	c0 
c0106c97:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106c9e:	00 
c0106c9f:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106ca6:	e8 42 a0 ff ff       	call   c0100ced <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106cab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cae:	8b 04 85 dc 70 12 c0 	mov    -0x3fed8f24(,%eax,4),%eax
c0106cb5:	8b 00                	mov    (%eax),%eax
c0106cb7:	83 e0 01             	and    $0x1,%eax
c0106cba:	85 c0                	test   %eax,%eax
c0106cbc:	75 24                	jne    c0106ce2 <check_swap+0x557>
c0106cbe:	c7 44 24 0c f4 a6 10 	movl   $0xc010a6f4,0xc(%esp)
c0106cc5:	c0 
c0106cc6:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106ccd:	c0 
c0106cce:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106cd5:	00 
c0106cd6:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106cdd:	e8 0b a0 ff ff       	call   c0100ced <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ce2:	ff 45 ec             	incl   -0x14(%ebp)
c0106ce5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106ce9:	0f 8e 0e ff ff ff    	jle    c0106bfd <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c0106cef:	c7 04 24 10 a7 10 c0 	movl   $0xc010a710,(%esp)
c0106cf6:	e8 6a 96 ff ff       	call   c0100365 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106cfb:	e8 71 fa ff ff       	call   c0106771 <check_content_access>
c0106d00:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c0106d03:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0106d07:	74 24                	je     c0106d2d <check_swap+0x5a2>
c0106d09:	c7 44 24 0c 36 a7 10 	movl   $0xc010a736,0xc(%esp)
c0106d10:	c0 
c0106d11:	c7 44 24 08 1e a4 10 	movl   $0xc010a41e,0x8(%esp)
c0106d18:	c0 
c0106d19:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106d20:	00 
c0106d21:	c7 04 24 b8 a3 10 c0 	movl   $0xc010a3b8,(%esp)
c0106d28:	e8 c0 9f ff ff       	call   c0100ced <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d2d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106d34:	eb 1d                	jmp    c0106d53 <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c0106d36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d39:	8b 04 85 cc 70 12 c0 	mov    -0x3fed8f34(,%eax,4),%eax
c0106d40:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d47:	00 
c0106d48:	89 04 24             	mov    %eax,(%esp)
c0106d4b:	e8 1a dc ff ff       	call   c010496a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106d50:	ff 45 ec             	incl   -0x14(%ebp)
c0106d53:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106d57:	7e dd                	jle    c0106d36 <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d5c:	89 04 24             	mov    %eax,(%esp)
c0106d5f:	e8 a1 0a 00 00       	call   c0107805 <mm_destroy>
         
     nr_free = nr_free_store;
c0106d64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106d67:	a3 8c 6f 12 c0       	mov    %eax,0xc0126f8c
     free_list = free_list_store;
c0106d6c:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106d6f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106d72:	a3 84 6f 12 c0       	mov    %eax,0xc0126f84
c0106d77:	89 15 88 6f 12 c0    	mov    %edx,0xc0126f88

     
     le = &free_list;
c0106d7d:	c7 45 e8 84 6f 12 c0 	movl   $0xc0126f84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106d84:	eb 1c                	jmp    c0106da2 <check_swap+0x617>
         struct Page *p = le2page(le, page_link);
c0106d86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106d89:	83 e8 0c             	sub    $0xc,%eax
c0106d8c:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0106d8f:	ff 4d f4             	decl   -0xc(%ebp)
c0106d92:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106d95:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106d98:	8b 48 08             	mov    0x8(%eax),%ecx
c0106d9b:	89 d0                	mov    %edx,%eax
c0106d9d:	29 c8                	sub    %ecx,%eax
c0106d9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106da2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106da5:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c0106da8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106dab:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106dae:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106db1:	81 7d e8 84 6f 12 c0 	cmpl   $0xc0126f84,-0x18(%ebp)
c0106db8:	75 cc                	jne    c0106d86 <check_swap+0x5fb>
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dbd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dc8:	c7 04 24 3d a7 10 c0 	movl   $0xc010a73d,(%esp)
c0106dcf:	e8 91 95 ff ff       	call   c0100365 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106dd4:	c7 04 24 57 a7 10 c0 	movl   $0xc010a757,(%esp)
c0106ddb:	e8 85 95 ff ff       	call   c0100365 <cprintf>
}
c0106de0:	90                   	nop
c0106de1:	89 ec                	mov    %ebp,%esp
c0106de3:	5d                   	pop    %ebp
c0106de4:	c3                   	ret    

c0106de5 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0106de5:	55                   	push   %ebp
c0106de6:	89 e5                	mov    %esp,%ebp
c0106de8:	83 ec 10             	sub    $0x10,%esp
c0106deb:	c7 45 fc 04 71 12 c0 	movl   $0xc0127104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c0106df2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106df5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106df8:	89 50 04             	mov    %edx,0x4(%eax)
c0106dfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106dfe:	8b 50 04             	mov    0x4(%eax),%edx
c0106e01:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106e04:	89 10                	mov    %edx,(%eax)
}
c0106e06:	90                   	nop
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
c0106e07:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e0a:	c7 40 14 04 71 12 c0 	movl   $0xc0127104,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c0106e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e16:	89 ec                	mov    %ebp,%esp
c0106e18:	5d                   	pop    %ebp
c0106e19:	c3                   	ret    

c0106e1a <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106e1a:	55                   	push   %ebp
c0106e1b:	89 e5                	mov    %esp,%ebp
c0106e1d:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0106e20:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e23:	8b 40 14             	mov    0x14(%eax),%eax
c0106e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry = &(page->pra_page_link);
c0106e29:	8b 45 10             	mov    0x10(%ebp),%eax
c0106e2c:	83 c0 14             	add    $0x14,%eax
c0106e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c0106e32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106e36:	74 06                	je     c0106e3e <_fifo_map_swappable+0x24>
c0106e38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106e3c:	75 24                	jne    c0106e62 <_fifo_map_swappable+0x48>
c0106e3e:	c7 44 24 0c 70 a7 10 	movl   $0xc010a770,0xc(%esp)
c0106e45:	c0 
c0106e46:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0106e4d:	c0 
c0106e4e:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106e55:	00 
c0106e56:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0106e5d:	e8 8b 9e ff ff       	call   c0100ced <__panic>
c0106e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e65:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0106e6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e71:	8b 00                	mov    (%eax),%eax
c0106e73:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106e76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106e79:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106e7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e7f:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0106e82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e88:	89 10                	mov    %edx,(%eax)
c0106e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e8d:	8b 10                	mov    (%eax),%edx
c0106e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e92:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106e98:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e9b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ea1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106ea4:	89 10                	mov    %edx,(%eax)
}
c0106ea6:	90                   	nop
}
c0106ea7:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add_before(head, entry);
    return 0;
c0106ea8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106ead:	89 ec                	mov    %ebp,%esp
c0106eaf:	5d                   	pop    %ebp
c0106eb0:	c3                   	ret    

c0106eb1 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0106eb1:	55                   	push   %ebp
c0106eb2:	89 e5                	mov    %esp,%ebp
c0106eb4:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0106eb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0106eba:	8b 40 14             	mov    0x14(%eax),%eax
c0106ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0106ec0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ec4:	75 24                	jne    c0106eea <_fifo_swap_out_victim+0x39>
c0106ec6:	c7 44 24 0c b7 a7 10 	movl   $0xc010a7b7,0xc(%esp)
c0106ecd:	c0 
c0106ece:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0106ed5:	c0 
c0106ed6:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106edd:	00 
c0106ede:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0106ee5:	e8 03 9e ff ff       	call   c0100ced <__panic>
    assert(in_tick == 0);
c0106eea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106eee:	74 24                	je     c0106f14 <_fifo_swap_out_victim+0x63>
c0106ef0:	c7 44 24 0c c4 a7 10 	movl   $0xc010a7c4,0xc(%esp)
c0106ef7:	c0 
c0106ef8:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0106eff:	c0 
c0106f00:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0106f07:	00 
c0106f08:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0106f0f:	e8 d9 9d ff ff       	call   c0100ced <__panic>
c0106f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f17:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0106f1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106f1d:	8b 40 04             	mov    0x4(%eax),%eax
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  assign the value of *ptr_page to the addr of this page
    list_entry_t *le = list_next(head);
c0106f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0106f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f2c:	8b 40 04             	mov    0x4(%eax),%eax
c0106f2f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f32:	8b 12                	mov    (%edx),%edx
c0106f34:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0106f37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0106f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106f3d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106f40:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f46:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106f49:	89 10                	mov    %edx,(%eax)
}
c0106f4b:	90                   	nop
}
c0106f4c:	90                   	nop
    list_del(le); //victim
    *ptr_page = le2page(le, pra_page_link);
c0106f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f50:	8d 50 ec             	lea    -0x14(%eax),%edx
c0106f53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106f56:	89 10                	mov    %edx,(%eax)
    return 0;
c0106f58:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106f5d:	89 ec                	mov    %ebp,%esp
c0106f5f:	5d                   	pop    %ebp
c0106f60:	c3                   	ret    

c0106f61 <_extend_clock_swap_out_victim>:

static int
_extend_clock_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
c0106f61:	55                   	push   %ebp
c0106f62:	89 e5                	mov    %esp,%ebp
c0106f64:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
c0106f67:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f6a:	8b 40 14             	mov    0x14(%eax),%eax
c0106f6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(head != NULL);
c0106f70:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106f74:	75 24                	jne    c0106f9a <_extend_clock_swap_out_victim+0x39>
c0106f76:	c7 44 24 0c b7 a7 10 	movl   $0xc010a7b7,0xc(%esp)
c0106f7d:	c0 
c0106f7e:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0106f85:	c0 
c0106f86:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
c0106f8d:	00 
c0106f8e:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0106f95:	e8 53 9d ff ff       	call   c0100ced <__panic>
    assert(in_tick == 0);
c0106f9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106f9e:	74 24                	je     c0106fc4 <_extend_clock_swap_out_victim+0x63>
c0106fa0:	c7 44 24 0c c4 a7 10 	movl   $0xc010a7c4,0xc(%esp)
c0106fa7:	c0 
c0106fa8:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0106faf:	c0 
c0106fb0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
c0106fb7:	00 
c0106fb8:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0106fbf:	e8 29 9d ff ff       	call   c0100ced <__panic>
    //在head双向链表中从头开始遍历, 用三个指针取三个第一次遍历到的page
    list_entry_t *le = head->next, *_00 = NULL, *_10 = NULL, *_11 = NULL;
c0106fc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fc7:	8b 40 04             	mov    0x4(%eax),%eax
c0106fca:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106fcd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0106fd4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106fdb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while (le != head)
c0106fe2:	e9 99 00 00 00       	jmp    c0107080 <_extend_clock_swap_out_victim+0x11f>
    {
        struct Page *page = le2page(le, pra_page_link);
c0106fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fea:	83 e8 14             	sub    $0x14,%eax
c0106fed:	89 45 e0             	mov    %eax,-0x20(%ebp)

        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
c0106ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ff3:	8b 50 1c             	mov    0x1c(%eax),%edx
c0106ff6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ff9:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ffc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107003:	00 
c0107004:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107008:	89 04 24             	mov    %eax,(%esp)
c010700b:	e8 a3 df ff ff       	call   c0104fb3 <get_pte>
c0107010:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(ptep != NULL);
c0107013:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107017:	75 24                	jne    c010703d <_extend_clock_swap_out_victim+0xdc>
c0107019:	c7 44 24 0c d1 a7 10 	movl   $0xc010a7d1,0xc(%esp)
c0107020:	c0 
c0107021:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0107028:	c0 
c0107029:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0107030:	00 
c0107031:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0107038:	e8 b0 9c ff ff       	call   c0100ced <__panic>
        if (!(*ptep & PTE_A))
c010703d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107040:	8b 00                	mov    (%eax),%eax
c0107042:	83 e0 20             	and    $0x20,%eax
c0107045:	85 c0                	test   %eax,%eax
c0107047:	75 08                	jne    c0107051 <_extend_clock_swap_out_victim+0xf0>
        {
            _00 = le;
c0107049:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010704c:	89 45 f0             	mov    %eax,-0x10(%ebp)
            break;
c010704f:	eb 3b                	jmp    c010708c <_extend_clock_swap_out_victim+0x12b>
        }
        else if (!(*ptep & PTE_D) && _10 == NULL)
c0107051:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107054:	8b 00                	mov    (%eax),%eax
c0107056:	83 e0 40             	and    $0x40,%eax
c0107059:	85 c0                	test   %eax,%eax
c010705b:	75 0e                	jne    c010706b <_extend_clock_swap_out_victim+0x10a>
c010705d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107061:	75 08                	jne    c010706b <_extend_clock_swap_out_victim+0x10a>
            _10 = le;
c0107063:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107066:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107069:	eb 0c                	jmp    c0107077 <_extend_clock_swap_out_victim+0x116>
        else if (_11 == NULL)
c010706b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010706f:	75 06                	jne    c0107077 <_extend_clock_swap_out_victim+0x116>
            _11 = le;
c0107071:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107074:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = le->next;
c0107077:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010707a:	8b 40 04             	mov    0x4(%eax),%eax
c010707d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (le != head)
c0107080:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107083:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0107086:	0f 85 5b ff ff ff    	jne    c0106fe7 <_extend_clock_swap_out_victim+0x86>
    }
    le = _00 != NULL ? _00 : (_10 != NULL ? _10 : _11);
c010708c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107090:	75 10                	jne    c01070a2 <_extend_clock_swap_out_victim+0x141>
c0107092:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107096:	74 05                	je     c010709d <_extend_clock_swap_out_victim+0x13c>
c0107098:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010709b:	eb 08                	jmp    c01070a5 <_extend_clock_swap_out_victim+0x144>
c010709d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01070a0:	eb 03                	jmp    c01070a5 <_extend_clock_swap_out_victim+0x144>
c01070a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    *ptr_page = le2page(le, pra_page_link);
c01070a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070ab:	8d 50 ec             	lea    -0x14(%eax),%edx
c01070ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070b1:	89 10                	mov    %edx,(%eax)
c01070b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    __list_del(listelm->prev, listelm->next);
c01070b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01070bc:	8b 40 04             	mov    0x4(%eax),%eax
c01070bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01070c2:	8b 12                	mov    (%edx),%edx
c01070c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01070c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next;
c01070ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01070cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01070d0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01070d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01070d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01070d9:	89 10                	mov    %edx,(%eax)
}
c01070db:	90                   	nop
}
c01070dc:	90                   	nop
    list_del(le);
    return 0;
c01070dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01070e2:	89 ec                	mov    %ebp,%esp
c01070e4:	5d                   	pop    %ebp
c01070e5:	c3                   	ret    

c01070e6 <_fifo_check_swap>:

static int
_fifo_check_swap(void)
{
c01070e6:	55                   	push   %ebp
c01070e7:	89 e5                	mov    %esp,%ebp
c01070e9:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01070ec:	c7 04 24 e0 a7 10 c0 	movl   $0xc010a7e0,(%esp)
c01070f3:	e8 6d 92 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01070f8:	b8 00 30 00 00       	mov    $0x3000,%eax
c01070fd:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 4);
c0107100:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107105:	83 f8 04             	cmp    $0x4,%eax
c0107108:	74 24                	je     c010712e <_fifo_check_swap+0x48>
c010710a:	c7 44 24 0c 06 a8 10 	movl   $0xc010a806,0xc(%esp)
c0107111:	c0 
c0107112:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0107119:	c0 
c010711a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107121:	00 
c0107122:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0107129:	e8 bf 9b ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010712e:	c7 04 24 18 a8 10 c0 	movl   $0xc010a818,(%esp)
c0107135:	e8 2b 92 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010713a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010713f:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 4);
c0107142:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107147:	83 f8 04             	cmp    $0x4,%eax
c010714a:	74 24                	je     c0107170 <_fifo_check_swap+0x8a>
c010714c:	c7 44 24 0c 06 a8 10 	movl   $0xc010a806,0xc(%esp)
c0107153:	c0 
c0107154:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c010715b:	c0 
c010715c:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107163:	00 
c0107164:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c010716b:	e8 7d 9b ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107170:	c7 04 24 40 a8 10 c0 	movl   $0xc010a840,(%esp)
c0107177:	e8 e9 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010717c:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107181:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 4);
c0107184:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107189:	83 f8 04             	cmp    $0x4,%eax
c010718c:	74 24                	je     c01071b2 <_fifo_check_swap+0xcc>
c010718e:	c7 44 24 0c 06 a8 10 	movl   $0xc010a806,0xc(%esp)
c0107195:	c0 
c0107196:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c010719d:	c0 
c010719e:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c01071a5:	00 
c01071a6:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01071ad:	e8 3b 9b ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01071b2:	c7 04 24 68 a8 10 c0 	movl   $0xc010a868,(%esp)
c01071b9:	e8 a7 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01071be:	b8 00 20 00 00       	mov    $0x2000,%eax
c01071c3:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 4);
c01071c6:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01071cb:	83 f8 04             	cmp    $0x4,%eax
c01071ce:	74 24                	je     c01071f4 <_fifo_check_swap+0x10e>
c01071d0:	c7 44 24 0c 06 a8 10 	movl   $0xc010a806,0xc(%esp)
c01071d7:	c0 
c01071d8:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c01071df:	c0 
c01071e0:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
c01071e7:	00 
c01071e8:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01071ef:	e8 f9 9a ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01071f4:	c7 04 24 90 a8 10 c0 	movl   $0xc010a890,(%esp)
c01071fb:	e8 65 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107200:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107205:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 5);
c0107208:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010720d:	83 f8 05             	cmp    $0x5,%eax
c0107210:	74 24                	je     c0107236 <_fifo_check_swap+0x150>
c0107212:	c7 44 24 0c b6 a8 10 	movl   $0xc010a8b6,0xc(%esp)
c0107219:	c0 
c010721a:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0107221:	c0 
c0107222:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0107229:	00 
c010722a:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0107231:	e8 b7 9a ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107236:	c7 04 24 68 a8 10 c0 	movl   $0xc010a868,(%esp)
c010723d:	e8 23 91 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107242:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107247:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 5);
c010724a:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010724f:	83 f8 05             	cmp    $0x5,%eax
c0107252:	74 24                	je     c0107278 <_fifo_check_swap+0x192>
c0107254:	c7 44 24 0c b6 a8 10 	movl   $0xc010a8b6,0xc(%esp)
c010725b:	c0 
c010725c:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0107263:	c0 
c0107264:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c010726b:	00 
c010726c:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0107273:	e8 75 9a ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107278:	c7 04 24 18 a8 10 c0 	movl   $0xc010a818,(%esp)
c010727f:	e8 e1 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107284:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107289:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 6);
c010728c:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107291:	83 f8 06             	cmp    $0x6,%eax
c0107294:	74 24                	je     c01072ba <_fifo_check_swap+0x1d4>
c0107296:	c7 44 24 0c c7 a8 10 	movl   $0xc010a8c7,0xc(%esp)
c010729d:	c0 
c010729e:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c01072a5:	c0 
c01072a6:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c01072ad:	00 
c01072ae:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01072b5:	e8 33 9a ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01072ba:	c7 04 24 68 a8 10 c0 	movl   $0xc010a868,(%esp)
c01072c1:	e8 9f 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01072c6:	b8 00 20 00 00       	mov    $0x2000,%eax
c01072cb:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num == 7);
c01072ce:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c01072d3:	83 f8 07             	cmp    $0x7,%eax
c01072d6:	74 24                	je     c01072fc <_fifo_check_swap+0x216>
c01072d8:	c7 44 24 0c d8 a8 10 	movl   $0xc010a8d8,0xc(%esp)
c01072df:	c0 
c01072e0:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c01072e7:	c0 
c01072e8:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
c01072ef:	00 
c01072f0:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01072f7:	e8 f1 99 ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01072fc:	c7 04 24 e0 a7 10 c0 	movl   $0xc010a7e0,(%esp)
c0107303:	e8 5d 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107308:	b8 00 30 00 00       	mov    $0x3000,%eax
c010730d:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num == 8);
c0107310:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107315:	83 f8 08             	cmp    $0x8,%eax
c0107318:	74 24                	je     c010733e <_fifo_check_swap+0x258>
c010731a:	c7 44 24 0c e9 a8 10 	movl   $0xc010a8e9,0xc(%esp)
c0107321:	c0 
c0107322:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c0107329:	c0 
c010732a:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
c0107331:	00 
c0107332:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c0107339:	e8 af 99 ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010733e:	c7 04 24 40 a8 10 c0 	movl   $0xc010a840,(%esp)
c0107345:	e8 1b 90 ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010734a:	b8 00 40 00 00       	mov    $0x4000,%eax
c010734f:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num == 9);
c0107352:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107357:	83 f8 09             	cmp    $0x9,%eax
c010735a:	74 24                	je     c0107380 <_fifo_check_swap+0x29a>
c010735c:	c7 44 24 0c fa a8 10 	movl   $0xc010a8fa,0xc(%esp)
c0107363:	c0 
c0107364:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c010736b:	c0 
c010736c:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
c0107373:	00 
c0107374:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c010737b:	e8 6d 99 ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107380:	c7 04 24 90 a8 10 c0 	movl   $0xc010a890,(%esp)
c0107387:	e8 d9 8f ff ff       	call   c0100365 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c010738c:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107391:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num == 10);
c0107394:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c0107399:	83 f8 0a             	cmp    $0xa,%eax
c010739c:	74 24                	je     c01073c2 <_fifo_check_swap+0x2dc>
c010739e:	c7 44 24 0c 0b a9 10 	movl   $0xc010a90b,0xc(%esp)
c01073a5:	c0 
c01073a6:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c01073ad:	c0 
c01073ae:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
c01073b5:	00 
c01073b6:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01073bd:	e8 2b 99 ff ff       	call   c0100ced <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01073c2:	c7 04 24 18 a8 10 c0 	movl   $0xc010a818,(%esp)
c01073c9:	e8 97 8f ff ff       	call   c0100365 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01073ce:	b8 00 10 00 00       	mov    $0x1000,%eax
c01073d3:	0f b6 00             	movzbl (%eax),%eax
c01073d6:	3c 0a                	cmp    $0xa,%al
c01073d8:	74 24                	je     c01073fe <_fifo_check_swap+0x318>
c01073da:	c7 44 24 0c 20 a9 10 	movl   $0xc010a920,0xc(%esp)
c01073e1:	c0 
c01073e2:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c01073e9:	c0 
c01073ea:	c7 44 24 04 91 00 00 	movl   $0x91,0x4(%esp)
c01073f1:	00 
c01073f2:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c01073f9:	e8 ef 98 ff ff       	call   c0100ced <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01073fe:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107403:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num == 11);
c0107406:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010740b:	83 f8 0b             	cmp    $0xb,%eax
c010740e:	74 24                	je     c0107434 <_fifo_check_swap+0x34e>
c0107410:	c7 44 24 0c 41 a9 10 	movl   $0xc010a941,0xc(%esp)
c0107417:	c0 
c0107418:	c7 44 24 08 8e a7 10 	movl   $0xc010a78e,0x8(%esp)
c010741f:	c0 
c0107420:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
c0107427:	00 
c0107428:	c7 04 24 a3 a7 10 c0 	movl   $0xc010a7a3,(%esp)
c010742f:	e8 b9 98 ff ff       	call   c0100ced <__panic>
    return 0;
c0107434:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107439:	89 ec                	mov    %ebp,%esp
c010743b:	5d                   	pop    %ebp
c010743c:	c3                   	ret    

c010743d <_fifo_init>:

static int
_fifo_init(void)
{
c010743d:	55                   	push   %ebp
c010743e:	89 e5                	mov    %esp,%ebp
    return 0;
c0107440:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107445:	5d                   	pop    %ebp
c0107446:	c3                   	ret    

c0107447 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107447:	55                   	push   %ebp
c0107448:	89 e5                	mov    %esp,%ebp
    return 0;
c010744a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010744f:	5d                   	pop    %ebp
c0107450:	c3                   	ret    

c0107451 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
c0107451:	55                   	push   %ebp
c0107452:	89 e5                	mov    %esp,%ebp
    return 0;
c0107454:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107459:	5d                   	pop    %ebp
c010745a:	c3                   	ret    

c010745b <pa2page>:
pa2page(uintptr_t pa) {
c010745b:	55                   	push   %ebp
c010745c:	89 e5                	mov    %esp,%ebp
c010745e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107461:	8b 45 08             	mov    0x8(%ebp),%eax
c0107464:	c1 e8 0c             	shr    $0xc,%eax
c0107467:	89 c2                	mov    %eax,%edx
c0107469:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c010746e:	39 c2                	cmp    %eax,%edx
c0107470:	72 1c                	jb     c010748e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107472:	c7 44 24 08 68 a9 10 	movl   $0xc010a968,0x8(%esp)
c0107479:	c0 
c010747a:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107481:	00 
c0107482:	c7 04 24 87 a9 10 c0 	movl   $0xc010a987,(%esp)
c0107489:	e8 5f 98 ff ff       	call   c0100ced <__panic>
    return &pages[PPN(pa)];
c010748e:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0107494:	8b 45 08             	mov    0x8(%ebp),%eax
c0107497:	c1 e8 0c             	shr    $0xc,%eax
c010749a:	c1 e0 05             	shl    $0x5,%eax
c010749d:	01 d0                	add    %edx,%eax
}
c010749f:	89 ec                	mov    %ebp,%esp
c01074a1:	5d                   	pop    %ebp
c01074a2:	c3                   	ret    

c01074a3 <pde2page>:
pde2page(pde_t pde) {
c01074a3:	55                   	push   %ebp
c01074a4:	89 e5                	mov    %esp,%ebp
c01074a6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01074a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01074ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01074b1:	89 04 24             	mov    %eax,(%esp)
c01074b4:	e8 a2 ff ff ff       	call   c010745b <pa2page>
}
c01074b9:	89 ec                	mov    %ebp,%esp
c01074bb:	5d                   	pop    %ebp
c01074bc:	c3                   	ret    

c01074bd <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01074bd:	55                   	push   %ebp
c01074be:	89 e5                	mov    %esp,%ebp
c01074c0:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01074c3:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01074ca:	e8 ba eb ff ff       	call   c0106089 <kmalloc>
c01074cf:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01074d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01074d6:	74 59                	je     c0107531 <mm_create+0x74>
        list_init(&(mm->mmap_list));
c01074d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c01074de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01074e4:	89 50 04             	mov    %edx,0x4(%eax)
c01074e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074ea:	8b 50 04             	mov    0x4(%eax),%edx
c01074ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074f0:	89 10                	mov    %edx,(%eax)
}
c01074f2:	90                   	nop
        mm->mmap_cache = NULL;
c01074f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01074fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107500:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107507:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010750a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107511:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0107516:	85 c0                	test   %eax,%eax
c0107518:	74 0d                	je     c0107527 <mm_create+0x6a>
c010751a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010751d:	89 04 24             	mov    %eax,(%esp)
c0107520:	e8 bd ed ff ff       	call   c01062e2 <swap_init_mm>
c0107525:	eb 0a                	jmp    c0107531 <mm_create+0x74>
        else mm->sm_priv = NULL;
c0107527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010752a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107534:	89 ec                	mov    %ebp,%esp
c0107536:	5d                   	pop    %ebp
c0107537:	c3                   	ret    

c0107538 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107538:	55                   	push   %ebp
c0107539:	89 e5                	mov    %esp,%ebp
c010753b:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c010753e:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107545:	e8 3f eb ff ff       	call   c0106089 <kmalloc>
c010754a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c010754d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107551:	74 1b                	je     c010756e <vma_create+0x36>
        vma->vm_start = vm_start;
c0107553:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107556:	8b 55 08             	mov    0x8(%ebp),%edx
c0107559:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010755c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010755f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107562:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107565:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107568:	8b 55 10             	mov    0x10(%ebp),%edx
c010756b:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010756e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107571:	89 ec                	mov    %ebp,%esp
c0107573:	5d                   	pop    %ebp
c0107574:	c3                   	ret    

c0107575 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107575:	55                   	push   %ebp
c0107576:	89 e5                	mov    %esp,%ebp
c0107578:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010757b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107582:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107586:	0f 84 95 00 00 00    	je     c0107621 <find_vma+0xac>
        vma = mm->mmap_cache;
c010758c:	8b 45 08             	mov    0x8(%ebp),%eax
c010758f:	8b 40 08             	mov    0x8(%eax),%eax
c0107592:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107595:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107599:	74 16                	je     c01075b1 <find_vma+0x3c>
c010759b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010759e:	8b 40 04             	mov    0x4(%eax),%eax
c01075a1:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01075a4:	72 0b                	jb     c01075b1 <find_vma+0x3c>
c01075a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01075a9:	8b 40 08             	mov    0x8(%eax),%eax
c01075ac:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01075af:	72 61                	jb     c0107612 <find_vma+0x9d>
                bool found = 0;
c01075b1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01075b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01075bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01075be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01075c4:	eb 28                	jmp    c01075ee <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01075c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075c9:	83 e8 10             	sub    $0x10,%eax
c01075cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01075cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01075d2:	8b 40 04             	mov    0x4(%eax),%eax
c01075d5:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01075d8:	72 14                	jb     c01075ee <find_vma+0x79>
c01075da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01075dd:	8b 40 08             	mov    0x8(%eax),%eax
c01075e0:	39 45 0c             	cmp    %eax,0xc(%ebp)
c01075e3:	73 09                	jae    c01075ee <find_vma+0x79>
                        found = 1;
c01075e5:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01075ec:	eb 17                	jmp    c0107605 <find_vma+0x90>
c01075ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c01075f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075f7:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c01075fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01075fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107600:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107603:	75 c1                	jne    c01075c6 <find_vma+0x51>
                    }
                }
                if (!found) {
c0107605:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107609:	75 07                	jne    c0107612 <find_vma+0x9d>
                    vma = NULL;
c010760b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0107612:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107616:	74 09                	je     c0107621 <find_vma+0xac>
            mm->mmap_cache = vma;
c0107618:	8b 45 08             	mov    0x8(%ebp),%eax
c010761b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010761e:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107621:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107624:	89 ec                	mov    %ebp,%esp
c0107626:	5d                   	pop    %ebp
c0107627:	c3                   	ret    

c0107628 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107628:	55                   	push   %ebp
c0107629:	89 e5                	mov    %esp,%ebp
c010762b:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010762e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107631:	8b 50 04             	mov    0x4(%eax),%edx
c0107634:	8b 45 08             	mov    0x8(%ebp),%eax
c0107637:	8b 40 08             	mov    0x8(%eax),%eax
c010763a:	39 c2                	cmp    %eax,%edx
c010763c:	72 24                	jb     c0107662 <check_vma_overlap+0x3a>
c010763e:	c7 44 24 0c 95 a9 10 	movl   $0xc010a995,0xc(%esp)
c0107645:	c0 
c0107646:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c010764d:	c0 
c010764e:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0107655:	00 
c0107656:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c010765d:	e8 8b 96 ff ff       	call   c0100ced <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107662:	8b 45 08             	mov    0x8(%ebp),%eax
c0107665:	8b 50 08             	mov    0x8(%eax),%edx
c0107668:	8b 45 0c             	mov    0xc(%ebp),%eax
c010766b:	8b 40 04             	mov    0x4(%eax),%eax
c010766e:	39 c2                	cmp    %eax,%edx
c0107670:	76 24                	jbe    c0107696 <check_vma_overlap+0x6e>
c0107672:	c7 44 24 0c d8 a9 10 	movl   $0xc010a9d8,0xc(%esp)
c0107679:	c0 
c010767a:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107681:	c0 
c0107682:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107689:	00 
c010768a:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107691:	e8 57 96 ff ff       	call   c0100ced <__panic>
    assert(next->vm_start < next->vm_end);
c0107696:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107699:	8b 50 04             	mov    0x4(%eax),%edx
c010769c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010769f:	8b 40 08             	mov    0x8(%eax),%eax
c01076a2:	39 c2                	cmp    %eax,%edx
c01076a4:	72 24                	jb     c01076ca <check_vma_overlap+0xa2>
c01076a6:	c7 44 24 0c f7 a9 10 	movl   $0xc010a9f7,0xc(%esp)
c01076ad:	c0 
c01076ae:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c01076b5:	c0 
c01076b6:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01076bd:	00 
c01076be:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c01076c5:	e8 23 96 ff ff       	call   c0100ced <__panic>
}
c01076ca:	90                   	nop
c01076cb:	89 ec                	mov    %ebp,%esp
c01076cd:	5d                   	pop    %ebp
c01076ce:	c3                   	ret    

c01076cf <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01076cf:	55                   	push   %ebp
c01076d0:	89 e5                	mov    %esp,%ebp
c01076d2:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01076d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01076d8:	8b 50 04             	mov    0x4(%eax),%edx
c01076db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01076de:	8b 40 08             	mov    0x8(%eax),%eax
c01076e1:	39 c2                	cmp    %eax,%edx
c01076e3:	72 24                	jb     c0107709 <insert_vma_struct+0x3a>
c01076e5:	c7 44 24 0c 15 aa 10 	movl   $0xc010aa15,0xc(%esp)
c01076ec:	c0 
c01076ed:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c01076f4:	c0 
c01076f5:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01076fc:	00 
c01076fd:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107704:	e8 e4 95 ff ff       	call   c0100ced <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107709:	8b 45 08             	mov    0x8(%ebp),%eax
c010770c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010770f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107712:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107715:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107718:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010771b:	eb 1f                	jmp    c010773c <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010771d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107720:	83 e8 10             	sub    $0x10,%eax
c0107723:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0107726:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107729:	8b 50 04             	mov    0x4(%eax),%edx
c010772c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010772f:	8b 40 04             	mov    0x4(%eax),%eax
c0107732:	39 c2                	cmp    %eax,%edx
c0107734:	77 1f                	ja     c0107755 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0107736:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107739:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010773c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010773f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107742:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107745:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0107748:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010774b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010774e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107751:	75 ca                	jne    c010771d <insert_vma_struct+0x4e>
c0107753:	eb 01                	jmp    c0107756 <insert_vma_struct+0x87>
                break;
c0107755:	90                   	nop
c0107756:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107759:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010775c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010775f:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0107762:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107765:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107768:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010776b:	74 15                	je     c0107782 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107770:	8d 50 f0             	lea    -0x10(%eax),%edx
c0107773:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107776:	89 44 24 04          	mov    %eax,0x4(%esp)
c010777a:	89 14 24             	mov    %edx,(%esp)
c010777d:	e8 a6 fe ff ff       	call   c0107628 <check_vma_overlap>
    }
    if (le_next != list) {
c0107782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107785:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107788:	74 15                	je     c010779f <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010778a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010778d:	83 e8 10             	sub    $0x10,%eax
c0107790:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107794:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107797:	89 04 24             	mov    %eax,(%esp)
c010779a:	e8 89 fe ff ff       	call   c0107628 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010779f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01077a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01077a5:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01077a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01077aa:	8d 50 10             	lea    0x10(%eax),%edx
c01077ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01077b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01077b3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c01077b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01077b9:	8b 40 04             	mov    0x4(%eax),%eax
c01077bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01077bf:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01077c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01077c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01077c8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c01077cb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01077ce:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01077d1:	89 10                	mov    %edx,(%eax)
c01077d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01077d6:	8b 10                	mov    (%eax),%edx
c01077d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01077db:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01077de:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01077e1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01077e4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01077e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01077ea:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01077ed:	89 10                	mov    %edx,(%eax)
}
c01077ef:	90                   	nop
}
c01077f0:	90                   	nop

    mm->map_count ++;
c01077f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01077f4:	8b 40 10             	mov    0x10(%eax),%eax
c01077f7:	8d 50 01             	lea    0x1(%eax),%edx
c01077fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01077fd:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107800:	90                   	nop
c0107801:	89 ec                	mov    %ebp,%esp
c0107803:	5d                   	pop    %ebp
c0107804:	c3                   	ret    

c0107805 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107805:	55                   	push   %ebp
c0107806:	89 e5                	mov    %esp,%ebp
c0107808:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010780b:	8b 45 08             	mov    0x8(%ebp),%eax
c010780e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107811:	eb 40                	jmp    c0107853 <mm_destroy+0x4e>
c0107813:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107816:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107819:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010781c:	8b 40 04             	mov    0x4(%eax),%eax
c010781f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107822:	8b 12                	mov    (%edx),%edx
c0107824:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107827:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c010782a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010782d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107830:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107833:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107836:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107839:	89 10                	mov    %edx,(%eax)
}
c010783b:	90                   	nop
}
c010783c:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c010783d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107840:	83 e8 10             	sub    $0x10,%eax
c0107843:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c010784a:	00 
c010784b:	89 04 24             	mov    %eax,(%esp)
c010784e:	e8 d8 e8 ff ff       	call   c010612b <kfree>
c0107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107856:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107859:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010785c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c010785f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107862:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107865:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107868:	75 a9                	jne    c0107813 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c010786a:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107871:	00 
c0107872:	8b 45 08             	mov    0x8(%ebp),%eax
c0107875:	89 04 24             	mov    %eax,(%esp)
c0107878:	e8 ae e8 ff ff       	call   c010612b <kfree>
    mm=NULL;
c010787d:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107884:	90                   	nop
c0107885:	89 ec                	mov    %ebp,%esp
c0107887:	5d                   	pop    %ebp
c0107888:	c3                   	ret    

c0107889 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107889:	55                   	push   %ebp
c010788a:	89 e5                	mov    %esp,%ebp
c010788c:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c010788f:	e8 05 00 00 00       	call   c0107899 <check_vmm>
}
c0107894:	90                   	nop
c0107895:	89 ec                	mov    %ebp,%esp
c0107897:	5d                   	pop    %ebp
c0107898:	c3                   	ret    

c0107899 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107899:	55                   	push   %ebp
c010789a:	89 e5                	mov    %esp,%ebp
c010789c:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010789f:	e8 fb d0 ff ff       	call   c010499f <nr_free_pages>
c01078a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01078a7:	e8 44 00 00 00       	call   c01078f0 <check_vma_struct>
    check_pgfault();
c01078ac:	e8 01 05 00 00       	call   c0107db2 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c01078b1:	e8 e9 d0 ff ff       	call   c010499f <nr_free_pages>
c01078b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01078b9:	74 24                	je     c01078df <check_vmm+0x46>
c01078bb:	c7 44 24 0c 34 aa 10 	movl   $0xc010aa34,0xc(%esp)
c01078c2:	c0 
c01078c3:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c01078ca:	c0 
c01078cb:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c01078d2:	00 
c01078d3:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c01078da:	e8 0e 94 ff ff       	call   c0100ced <__panic>

    cprintf("check_vmm() succeeded.\n");
c01078df:	c7 04 24 5b aa 10 c0 	movl   $0xc010aa5b,(%esp)
c01078e6:	e8 7a 8a ff ff       	call   c0100365 <cprintf>
}
c01078eb:	90                   	nop
c01078ec:	89 ec                	mov    %ebp,%esp
c01078ee:	5d                   	pop    %ebp
c01078ef:	c3                   	ret    

c01078f0 <check_vma_struct>:

static void
check_vma_struct(void) {
c01078f0:	55                   	push   %ebp
c01078f1:	89 e5                	mov    %esp,%ebp
c01078f3:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01078f6:	e8 a4 d0 ff ff       	call   c010499f <nr_free_pages>
c01078fb:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01078fe:	e8 ba fb ff ff       	call   c01074bd <mm_create>
c0107903:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107906:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010790a:	75 24                	jne    c0107930 <check_vma_struct+0x40>
c010790c:	c7 44 24 0c 73 aa 10 	movl   $0xc010aa73,0xc(%esp)
c0107913:	c0 
c0107914:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c010791b:	c0 
c010791c:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0107923:	00 
c0107924:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c010792b:	e8 bd 93 ff ff       	call   c0100ced <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107930:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107937:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010793a:	89 d0                	mov    %edx,%eax
c010793c:	c1 e0 02             	shl    $0x2,%eax
c010793f:	01 d0                	add    %edx,%eax
c0107941:	01 c0                	add    %eax,%eax
c0107943:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107946:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107949:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010794c:	eb 6f                	jmp    c01079bd <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010794e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107951:	89 d0                	mov    %edx,%eax
c0107953:	c1 e0 02             	shl    $0x2,%eax
c0107956:	01 d0                	add    %edx,%eax
c0107958:	83 c0 02             	add    $0x2,%eax
c010795b:	89 c1                	mov    %eax,%ecx
c010795d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107960:	89 d0                	mov    %edx,%eax
c0107962:	c1 e0 02             	shl    $0x2,%eax
c0107965:	01 d0                	add    %edx,%eax
c0107967:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010796e:	00 
c010796f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107973:	89 04 24             	mov    %eax,(%esp)
c0107976:	e8 bd fb ff ff       	call   c0107538 <vma_create>
c010797b:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c010797e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107982:	75 24                	jne    c01079a8 <check_vma_struct+0xb8>
c0107984:	c7 44 24 0c 7e aa 10 	movl   $0xc010aa7e,0xc(%esp)
c010798b:	c0 
c010798c:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107993:	c0 
c0107994:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c010799b:	00 
c010799c:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c01079a3:	e8 45 93 ff ff       	call   c0100ced <__panic>
        insert_vma_struct(mm, vma);
c01079a8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01079ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01079af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079b2:	89 04 24             	mov    %eax,(%esp)
c01079b5:	e8 15 fd ff ff       	call   c01076cf <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c01079ba:	ff 4d f4             	decl   -0xc(%ebp)
c01079bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01079c1:	7f 8b                	jg     c010794e <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01079c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079c6:	40                   	inc    %eax
c01079c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01079ca:	eb 6f                	jmp    c0107a3b <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01079cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01079cf:	89 d0                	mov    %edx,%eax
c01079d1:	c1 e0 02             	shl    $0x2,%eax
c01079d4:	01 d0                	add    %edx,%eax
c01079d6:	83 c0 02             	add    $0x2,%eax
c01079d9:	89 c1                	mov    %eax,%ecx
c01079db:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01079de:	89 d0                	mov    %edx,%eax
c01079e0:	c1 e0 02             	shl    $0x2,%eax
c01079e3:	01 d0                	add    %edx,%eax
c01079e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01079ec:	00 
c01079ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01079f1:	89 04 24             	mov    %eax,(%esp)
c01079f4:	e8 3f fb ff ff       	call   c0107538 <vma_create>
c01079f9:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c01079fc:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107a00:	75 24                	jne    c0107a26 <check_vma_struct+0x136>
c0107a02:	c7 44 24 0c 7e aa 10 	movl   $0xc010aa7e,0xc(%esp)
c0107a09:	c0 
c0107a0a:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107a11:	c0 
c0107a12:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0107a19:	00 
c0107a1a:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107a21:	e8 c7 92 ff ff       	call   c0100ced <__panic>
        insert_vma_struct(mm, vma);
c0107a26:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107a29:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a30:	89 04 24             	mov    %eax,(%esp)
c0107a33:	e8 97 fc ff ff       	call   c01076cf <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0107a38:	ff 45 f4             	incl   -0xc(%ebp)
c0107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a3e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107a41:	7e 89                	jle    c01079cc <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107a43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a46:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107a49:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107a4c:	8b 40 04             	mov    0x4(%eax),%eax
c0107a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107a52:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107a59:	e9 96 00 00 00       	jmp    c0107af4 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107a5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a61:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107a64:	75 24                	jne    c0107a8a <check_vma_struct+0x19a>
c0107a66:	c7 44 24 0c 8a aa 10 	movl   $0xc010aa8a,0xc(%esp)
c0107a6d:	c0 
c0107a6e:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107a75:	c0 
c0107a76:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0107a7d:	00 
c0107a7e:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107a85:	e8 63 92 ff ff       	call   c0100ced <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a8d:	83 e8 10             	sub    $0x10,%eax
c0107a90:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107a93:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107a96:	8b 48 04             	mov    0x4(%eax),%ecx
c0107a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107a9c:	89 d0                	mov    %edx,%eax
c0107a9e:	c1 e0 02             	shl    $0x2,%eax
c0107aa1:	01 d0                	add    %edx,%eax
c0107aa3:	39 c1                	cmp    %eax,%ecx
c0107aa5:	75 17                	jne    c0107abe <check_vma_struct+0x1ce>
c0107aa7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107aaa:	8b 48 08             	mov    0x8(%eax),%ecx
c0107aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ab0:	89 d0                	mov    %edx,%eax
c0107ab2:	c1 e0 02             	shl    $0x2,%eax
c0107ab5:	01 d0                	add    %edx,%eax
c0107ab7:	83 c0 02             	add    $0x2,%eax
c0107aba:	39 c1                	cmp    %eax,%ecx
c0107abc:	74 24                	je     c0107ae2 <check_vma_struct+0x1f2>
c0107abe:	c7 44 24 0c a4 aa 10 	movl   $0xc010aaa4,0xc(%esp)
c0107ac5:	c0 
c0107ac6:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107acd:	c0 
c0107ace:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0107ad5:	00 
c0107ad6:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107add:	e8 0b 92 ff ff       	call   c0100ced <__panic>
c0107ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ae5:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107ae8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107aeb:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107af1:	ff 45 f4             	incl   -0xc(%ebp)
c0107af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107af7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107afa:	0f 8e 5e ff ff ff    	jle    c0107a5e <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107b00:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107b07:	e9 cb 01 00 00       	jmp    c0107cd7 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b16:	89 04 24             	mov    %eax,(%esp)
c0107b19:	e8 57 fa ff ff       	call   c0107575 <find_vma>
c0107b1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0107b21:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107b25:	75 24                	jne    c0107b4b <check_vma_struct+0x25b>
c0107b27:	c7 44 24 0c d9 aa 10 	movl   $0xc010aad9,0xc(%esp)
c0107b2e:	c0 
c0107b2f:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107b36:	c0 
c0107b37:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0107b3e:	00 
c0107b3f:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107b46:	e8 a2 91 ff ff       	call   c0100ced <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b4e:	40                   	inc    %eax
c0107b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b53:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b56:	89 04 24             	mov    %eax,(%esp)
c0107b59:	e8 17 fa ff ff       	call   c0107575 <find_vma>
c0107b5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0107b61:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0107b65:	75 24                	jne    c0107b8b <check_vma_struct+0x29b>
c0107b67:	c7 44 24 0c e6 aa 10 	movl   $0xc010aae6,0xc(%esp)
c0107b6e:	c0 
c0107b6f:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107b76:	c0 
c0107b77:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0107b7e:	00 
c0107b7f:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107b86:	e8 62 91 ff ff       	call   c0100ced <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b8e:	83 c0 02             	add    $0x2,%eax
c0107b91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b98:	89 04 24             	mov    %eax,(%esp)
c0107b9b:	e8 d5 f9 ff ff       	call   c0107575 <find_vma>
c0107ba0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c0107ba3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107ba7:	74 24                	je     c0107bcd <check_vma_struct+0x2dd>
c0107ba9:	c7 44 24 0c f3 aa 10 	movl   $0xc010aaf3,0xc(%esp)
c0107bb0:	c0 
c0107bb1:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107bb8:	c0 
c0107bb9:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0107bc0:	00 
c0107bc1:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107bc8:	e8 20 91 ff ff       	call   c0100ced <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107bd0:	83 c0 03             	add    $0x3,%eax
c0107bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bda:	89 04 24             	mov    %eax,(%esp)
c0107bdd:	e8 93 f9 ff ff       	call   c0107575 <find_vma>
c0107be2:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c0107be5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107be9:	74 24                	je     c0107c0f <check_vma_struct+0x31f>
c0107beb:	c7 44 24 0c 00 ab 10 	movl   $0xc010ab00,0xc(%esp)
c0107bf2:	c0 
c0107bf3:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107bfa:	c0 
c0107bfb:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0107c02:	00 
c0107c03:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107c0a:	e8 de 90 ff ff       	call   c0100ced <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c12:	83 c0 04             	add    $0x4,%eax
c0107c15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c1c:	89 04 24             	mov    %eax,(%esp)
c0107c1f:	e8 51 f9 ff ff       	call   c0107575 <find_vma>
c0107c24:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c0107c27:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0107c2b:	74 24                	je     c0107c51 <check_vma_struct+0x361>
c0107c2d:	c7 44 24 0c 0d ab 10 	movl   $0xc010ab0d,0xc(%esp)
c0107c34:	c0 
c0107c35:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107c3c:	c0 
c0107c3d:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107c44:	00 
c0107c45:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107c4c:	e8 9c 90 ff ff       	call   c0100ced <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107c51:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c54:	8b 50 04             	mov    0x4(%eax),%edx
c0107c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c5a:	39 c2                	cmp    %eax,%edx
c0107c5c:	75 10                	jne    c0107c6e <check_vma_struct+0x37e>
c0107c5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c61:	8b 40 08             	mov    0x8(%eax),%eax
c0107c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c67:	83 c2 02             	add    $0x2,%edx
c0107c6a:	39 d0                	cmp    %edx,%eax
c0107c6c:	74 24                	je     c0107c92 <check_vma_struct+0x3a2>
c0107c6e:	c7 44 24 0c 1c ab 10 	movl   $0xc010ab1c,0xc(%esp)
c0107c75:	c0 
c0107c76:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107c7d:	c0 
c0107c7e:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0107c85:	00 
c0107c86:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107c8d:	e8 5b 90 ff ff       	call   c0100ced <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0107c92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107c95:	8b 50 04             	mov    0x4(%eax),%edx
c0107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c9b:	39 c2                	cmp    %eax,%edx
c0107c9d:	75 10                	jne    c0107caf <check_vma_struct+0x3bf>
c0107c9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107ca2:	8b 40 08             	mov    0x8(%eax),%eax
c0107ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ca8:	83 c2 02             	add    $0x2,%edx
c0107cab:	39 d0                	cmp    %edx,%eax
c0107cad:	74 24                	je     c0107cd3 <check_vma_struct+0x3e3>
c0107caf:	c7 44 24 0c 4c ab 10 	movl   $0xc010ab4c,0xc(%esp)
c0107cb6:	c0 
c0107cb7:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107cbe:	c0 
c0107cbf:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0107cc6:	00 
c0107cc7:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107cce:	e8 1a 90 ff ff       	call   c0100ced <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c0107cd3:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0107cd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107cda:	89 d0                	mov    %edx,%eax
c0107cdc:	c1 e0 02             	shl    $0x2,%eax
c0107cdf:	01 d0                	add    %edx,%eax
c0107ce1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0107ce4:	0f 8e 22 fe ff ff    	jle    c0107b0c <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0107cea:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107cf1:	eb 6f                	jmp    c0107d62 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107cfa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cfd:	89 04 24             	mov    %eax,(%esp)
c0107d00:	e8 70 f8 ff ff       	call   c0107575 <find_vma>
c0107d05:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c0107d08:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107d0c:	74 27                	je     c0107d35 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107d0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d11:	8b 50 08             	mov    0x8(%eax),%edx
c0107d14:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d17:	8b 40 04             	mov    0x4(%eax),%eax
c0107d1a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107d1e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d29:	c7 04 24 7c ab 10 c0 	movl   $0xc010ab7c,(%esp)
c0107d30:	e8 30 86 ff ff       	call   c0100365 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107d35:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107d39:	74 24                	je     c0107d5f <check_vma_struct+0x46f>
c0107d3b:	c7 44 24 0c a1 ab 10 	movl   $0xc010aba1,0xc(%esp)
c0107d42:	c0 
c0107d43:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107d4a:	c0 
c0107d4b:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0107d52:	00 
c0107d53:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107d5a:	e8 8e 8f ff ff       	call   c0100ced <__panic>
    for (i =4; i>=0; i--) {
c0107d5f:	ff 4d f4             	decl   -0xc(%ebp)
c0107d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107d66:	79 8b                	jns    c0107cf3 <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0107d68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d6b:	89 04 24             	mov    %eax,(%esp)
c0107d6e:	e8 92 fa ff ff       	call   c0107805 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107d73:	e8 27 cc ff ff       	call   c010499f <nr_free_pages>
c0107d78:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107d7b:	74 24                	je     c0107da1 <check_vma_struct+0x4b1>
c0107d7d:	c7 44 24 0c 34 aa 10 	movl   $0xc010aa34,0xc(%esp)
c0107d84:	c0 
c0107d85:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107d8c:	c0 
c0107d8d:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107d94:	00 
c0107d95:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107d9c:	e8 4c 8f ff ff       	call   c0100ced <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107da1:	c7 04 24 b8 ab 10 c0 	movl   $0xc010abb8,(%esp)
c0107da8:	e8 b8 85 ff ff       	call   c0100365 <cprintf>
}
c0107dad:	90                   	nop
c0107dae:	89 ec                	mov    %ebp,%esp
c0107db0:	5d                   	pop    %ebp
c0107db1:	c3                   	ret    

c0107db2 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107db2:	55                   	push   %ebp
c0107db3:	89 e5                	mov    %esp,%ebp
c0107db5:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107db8:	e8 e2 cb ff ff       	call   c010499f <nr_free_pages>
c0107dbd:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107dc0:	e8 f8 f6 ff ff       	call   c01074bd <mm_create>
c0107dc5:	a3 0c 71 12 c0       	mov    %eax,0xc012710c
    assert(check_mm_struct != NULL);
c0107dca:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107dcf:	85 c0                	test   %eax,%eax
c0107dd1:	75 24                	jne    c0107df7 <check_pgfault+0x45>
c0107dd3:	c7 44 24 0c d7 ab 10 	movl   $0xc010abd7,0xc(%esp)
c0107dda:	c0 
c0107ddb:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107de2:	c0 
c0107de3:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0107dea:	00 
c0107deb:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107df2:	e8 f6 8e ff ff       	call   c0100ced <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107df7:	a1 0c 71 12 c0       	mov    0xc012710c,%eax
c0107dfc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107dff:	8b 15 e0 39 12 c0    	mov    0xc01239e0,%edx
c0107e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e08:	89 50 0c             	mov    %edx,0xc(%eax)
c0107e0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e0e:	8b 40 0c             	mov    0xc(%eax),%eax
c0107e11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e17:	8b 00                	mov    (%eax),%eax
c0107e19:	85 c0                	test   %eax,%eax
c0107e1b:	74 24                	je     c0107e41 <check_pgfault+0x8f>
c0107e1d:	c7 44 24 0c ef ab 10 	movl   $0xc010abef,0xc(%esp)
c0107e24:	c0 
c0107e25:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107e2c:	c0 
c0107e2d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107e34:	00 
c0107e35:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107e3c:	e8 ac 8e ff ff       	call   c0100ced <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107e41:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107e48:	00 
c0107e49:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107e50:	00 
c0107e51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107e58:	e8 db f6 ff ff       	call   c0107538 <vma_create>
c0107e5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107e60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107e64:	75 24                	jne    c0107e8a <check_pgfault+0xd8>
c0107e66:	c7 44 24 0c 7e aa 10 	movl   $0xc010aa7e,0xc(%esp)
c0107e6d:	c0 
c0107e6e:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107e75:	c0 
c0107e76:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0107e7d:	00 
c0107e7e:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107e85:	e8 63 8e ff ff       	call   c0100ced <__panic>

    insert_vma_struct(mm, vma);
c0107e8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e94:	89 04 24             	mov    %eax,(%esp)
c0107e97:	e8 33 f8 ff ff       	call   c01076cf <insert_vma_struct>

    uintptr_t addr = 0x100;
c0107e9c:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0107ea3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107eaa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ead:	89 04 24             	mov    %eax,(%esp)
c0107eb0:	e8 c0 f6 ff ff       	call   c0107575 <find_vma>
c0107eb5:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0107eb8:	74 24                	je     c0107ede <check_pgfault+0x12c>
c0107eba:	c7 44 24 0c fd ab 10 	movl   $0xc010abfd,0xc(%esp)
c0107ec1:	c0 
c0107ec2:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107ec9:	c0 
c0107eca:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0107ed1:	00 
c0107ed2:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107ed9:	e8 0f 8e ff ff       	call   c0100ced <__panic>

    int i, sum = 0;
c0107ede:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107ee5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107eec:	eb 16                	jmp    c0107f04 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0107eee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ef1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ef4:	01 d0                	add    %edx,%eax
c0107ef6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ef9:	88 10                	mov    %dl,(%eax)
        sum += i;
c0107efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107efe:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107f01:	ff 45 f4             	incl   -0xc(%ebp)
c0107f04:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107f08:	7e e4                	jle    c0107eee <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0107f0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107f11:	eb 14                	jmp    c0107f27 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0107f13:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f16:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f19:	01 d0                	add    %edx,%eax
c0107f1b:	0f b6 00             	movzbl (%eax),%eax
c0107f1e:	0f be c0             	movsbl %al,%eax
c0107f21:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107f24:	ff 45 f4             	incl   -0xc(%ebp)
c0107f27:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107f2b:	7e e6                	jle    c0107f13 <check_pgfault+0x161>
    }
    assert(sum == 0);
c0107f2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107f31:	74 24                	je     c0107f57 <check_pgfault+0x1a5>
c0107f33:	c7 44 24 0c 17 ac 10 	movl   $0xc010ac17,0xc(%esp)
c0107f3a:	c0 
c0107f3b:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107f42:	c0 
c0107f43:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0107f4a:	00 
c0107f4b:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107f52:	e8 96 8d ff ff       	call   c0100ced <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0107f57:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f5a:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107f5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107f60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f6c:	89 04 24             	mov    %eax,(%esp)
c0107f6f:	e8 3f d2 ff ff       	call   c01051b3 <page_remove>
    free_page(pde2page(pgdir[0]));
c0107f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f77:	8b 00                	mov    (%eax),%eax
c0107f79:	89 04 24             	mov    %eax,(%esp)
c0107f7c:	e8 22 f5 ff ff       	call   c01074a3 <pde2page>
c0107f81:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107f88:	00 
c0107f89:	89 04 24             	mov    %eax,(%esp)
c0107f8c:	e8 d9 c9 ff ff       	call   c010496a <free_pages>
    pgdir[0] = 0;
c0107f91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f94:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0107f9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0107fa4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fa7:	89 04 24             	mov    %eax,(%esp)
c0107faa:	e8 56 f8 ff ff       	call   c0107805 <mm_destroy>
    check_mm_struct = NULL;
c0107faf:	c7 05 0c 71 12 c0 00 	movl   $0x0,0xc012710c
c0107fb6:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0107fb9:	e8 e1 c9 ff ff       	call   c010499f <nr_free_pages>
c0107fbe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107fc1:	74 24                	je     c0107fe7 <check_pgfault+0x235>
c0107fc3:	c7 44 24 0c 34 aa 10 	movl   $0xc010aa34,0xc(%esp)
c0107fca:	c0 
c0107fcb:	c7 44 24 08 b3 a9 10 	movl   $0xc010a9b3,0x8(%esp)
c0107fd2:	c0 
c0107fd3:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0107fda:	00 
c0107fdb:	c7 04 24 c8 a9 10 c0 	movl   $0xc010a9c8,(%esp)
c0107fe2:	e8 06 8d ff ff       	call   c0100ced <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0107fe7:	c7 04 24 20 ac 10 c0 	movl   $0xc010ac20,(%esp)
c0107fee:	e8 72 83 ff ff       	call   c0100365 <cprintf>
}
c0107ff3:	90                   	nop
c0107ff4:	89 ec                	mov    %ebp,%esp
c0107ff6:	5d                   	pop    %ebp
c0107ff7:	c3                   	ret    

c0107ff8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0107ff8:	55                   	push   %ebp
c0107ff9:	89 e5                	mov    %esp,%ebp
c0107ffb:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0107ffe:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108005:	8b 45 10             	mov    0x10(%ebp),%eax
c0108008:	89 44 24 04          	mov    %eax,0x4(%esp)
c010800c:	8b 45 08             	mov    0x8(%ebp),%eax
c010800f:	89 04 24             	mov    %eax,(%esp)
c0108012:	e8 5e f5 ff ff       	call   c0107575 <find_vma>
c0108017:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pgfault_num++;
c010801a:	a1 10 71 12 c0       	mov    0xc0127110,%eax
c010801f:	40                   	inc    %eax
c0108020:	a3 10 71 12 c0       	mov    %eax,0xc0127110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108025:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108029:	74 0b                	je     c0108036 <do_pgfault+0x3e>
c010802b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010802e:	8b 40 04             	mov    0x4(%eax),%eax
c0108031:	39 45 10             	cmp    %eax,0x10(%ebp)
c0108034:	73 18                	jae    c010804e <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108036:	8b 45 10             	mov    0x10(%ebp),%eax
c0108039:	89 44 24 04          	mov    %eax,0x4(%esp)
c010803d:	c7 04 24 3c ac 10 c0 	movl   $0xc010ac3c,(%esp)
c0108044:	e8 1c 83 ff ff       	call   c0100365 <cprintf>
        goto failed;
c0108049:	e9 a3 01 00 00       	jmp    c01081f1 <do_pgfault+0x1f9>
    }
    //check the error_code
    switch (error_code & 3) {
c010804e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108051:	83 e0 03             	and    $0x3,%eax
c0108054:	85 c0                	test   %eax,%eax
c0108056:	74 34                	je     c010808c <do_pgfault+0x94>
c0108058:	83 f8 01             	cmp    $0x1,%eax
c010805b:	74 1e                	je     c010807b <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c010805d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108060:	8b 40 0c             	mov    0xc(%eax),%eax
c0108063:	83 e0 02             	and    $0x2,%eax
c0108066:	85 c0                	test   %eax,%eax
c0108068:	75 40                	jne    c01080aa <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c010806a:	c7 04 24 6c ac 10 c0 	movl   $0xc010ac6c,(%esp)
c0108071:	e8 ef 82 ff ff       	call   c0100365 <cprintf>
            goto failed;
c0108076:	e9 76 01 00 00       	jmp    c01081f1 <do_pgfault+0x1f9>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010807b:	c7 04 24 cc ac 10 c0 	movl   $0xc010accc,(%esp)
c0108082:	e8 de 82 ff ff       	call   c0100365 <cprintf>
        goto failed;
c0108087:	e9 65 01 00 00       	jmp    c01081f1 <do_pgfault+0x1f9>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010808c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010808f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108092:	83 e0 05             	and    $0x5,%eax
c0108095:	85 c0                	test   %eax,%eax
c0108097:	75 12                	jne    c01080ab <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108099:	c7 04 24 04 ad 10 c0 	movl   $0xc010ad04,(%esp)
c01080a0:	e8 c0 82 ff ff       	call   c0100365 <cprintf>
            goto failed;
c01080a5:	e9 47 01 00 00       	jmp    c01081f1 <do_pgfault+0x1f9>
        break;
c01080aa:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01080ab:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c01080b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01080b5:	8b 40 0c             	mov    0xc(%eax),%eax
c01080b8:	83 e0 02             	and    $0x2,%eax
c01080bb:	85 c0                	test   %eax,%eax
c01080bd:	74 04                	je     c01080c3 <do_pgfault+0xcb>
        perm |= PTE_W;
c01080bf:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01080c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01080c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01080c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01080d1:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01080d4:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01080db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    *   mm->pgdir : the PDT of these vma
    *
    */
#if 1
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
c01080e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01080e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01080e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01080ef:	00 
c01080f0:	8b 55 10             	mov    0x10(%ebp),%edx
c01080f3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01080f7:	89 04 24             	mov    %eax,(%esp)
c01080fa:	e8 b4 ce ff ff       	call   c0104fb3 <get_pte>
c01080ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (*ptep == 0) {
c0108102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108105:	8b 00                	mov    (%eax),%eax
c0108107:	85 c0                	test   %eax,%eax
c0108109:	75 35                	jne    c0108140 <do_pgfault+0x148>
                            //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
c010810b:	8b 45 08             	mov    0x8(%ebp),%eax
c010810e:	8b 40 0c             	mov    0xc(%eax),%eax
c0108111:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108114:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108118:	8b 55 10             	mov    0x10(%ebp),%edx
c010811b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010811f:	89 04 24             	mov    %eax,(%esp)
c0108122:	e8 ed d1 ff ff       	call   c0105314 <pgdir_alloc_page>
c0108127:	85 c0                	test   %eax,%eax
c0108129:	0f 85 bb 00 00 00    	jne    c01081ea <do_pgfault+0x1f2>
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010812f:	c7 04 24 68 ad 10 c0 	movl   $0xc010ad68,(%esp)
c0108136:	e8 2a 82 ff ff       	call   c0100365 <cprintf>
            goto failed;
c010813b:	e9 b1 00 00 00       	jmp    c01081f1 <do_pgfault+0x1f9>
    *    swap_in(mm, addr, &page) : alloc a memory page, then according to the swap entry in PTE for addr,
    *                               find the addr of disk page, read the content of disk page into this memroy page
    *    page_insert ： build the map of phy addr of an Page with the linear addr la
    *    swap_map_swappable ： set the page swappable
    */
        if(swap_init_ok) {
c0108140:	a1 44 70 12 c0       	mov    0xc0127044,%eax
c0108145:	85 c0                	test   %eax,%eax
c0108147:	0f 84 86 00 00 00    	je     c01081d3 <do_pgfault+0x1db>
            struct Page *page=NULL;
c010814d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
                                    //(1）According to the mm AND addr, try to load the content of right disk page
                                    //    into the memory which page managed.
                                    //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
                                    //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0)
c0108154:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0108157:	89 44 24 08          	mov    %eax,0x8(%esp)
c010815b:	8b 45 10             	mov    0x10(%ebp),%eax
c010815e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108162:	8b 45 08             	mov    0x8(%ebp),%eax
c0108165:	89 04 24             	mov    %eax,(%esp)
c0108168:	e8 71 e3 ff ff       	call   c01064de <swap_in>
c010816d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108170:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108174:	74 0e                	je     c0108184 <do_pgfault+0x18c>
            {
                cprintf("swap_in in do_pgfault failed\n");
c0108176:	c7 04 24 8f ad 10 c0 	movl   $0xc010ad8f,(%esp)
c010817d:	e8 e3 81 ff ff       	call   c0100365 <cprintf>
c0108182:	eb 6d                	jmp    c01081f1 <do_pgfault+0x1f9>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c0108184:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108187:	8b 45 08             	mov    0x8(%ebp),%eax
c010818a:	8b 40 0c             	mov    0xc(%eax),%eax
c010818d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108190:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108194:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108197:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010819b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010819f:	89 04 24             	mov    %eax,(%esp)
c01081a2:	e8 53 d0 ff ff       	call   c01051fa <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01081a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081aa:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01081b1:	00 
c01081b2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01081b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01081c0:	89 04 24             	mov    %eax,(%esp)
c01081c3:	e8 4e e1 ff ff       	call   c0106316 <swap_map_swappable>
            page->pra_vaddr = addr;
c01081c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081cb:	8b 55 10             	mov    0x10(%ebp),%edx
c01081ce:	89 50 1c             	mov    %edx,0x1c(%eax)
c01081d1:	eb 17                	jmp    c01081ea <do_pgfault+0x1f2>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c01081d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081d6:	8b 00                	mov    (%eax),%eax
c01081d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081dc:	c7 04 24 b0 ad 10 c0 	movl   $0xc010adb0,(%esp)
c01081e3:	e8 7d 81 ff ff       	call   c0100365 <cprintf>
            goto failed;
c01081e8:	eb 07                	jmp    c01081f1 <do_pgfault+0x1f9>
        }
   }
#endif
   ret = 0;
c01081ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01081f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01081f4:	89 ec                	mov    %ebp,%esp
c01081f6:	5d                   	pop    %ebp
c01081f7:	c3                   	ret    

c01081f8 <page2ppn>:
page2ppn(struct Page *page) {
c01081f8:	55                   	push   %ebp
c01081f9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01081fb:	8b 15 a0 6f 12 c0    	mov    0xc0126fa0,%edx
c0108201:	8b 45 08             	mov    0x8(%ebp),%eax
c0108204:	29 d0                	sub    %edx,%eax
c0108206:	c1 f8 05             	sar    $0x5,%eax
}
c0108209:	5d                   	pop    %ebp
c010820a:	c3                   	ret    

c010820b <page2pa>:
page2pa(struct Page *page) {
c010820b:	55                   	push   %ebp
c010820c:	89 e5                	mov    %esp,%ebp
c010820e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108211:	8b 45 08             	mov    0x8(%ebp),%eax
c0108214:	89 04 24             	mov    %eax,(%esp)
c0108217:	e8 dc ff ff ff       	call   c01081f8 <page2ppn>
c010821c:	c1 e0 0c             	shl    $0xc,%eax
}
c010821f:	89 ec                	mov    %ebp,%esp
c0108221:	5d                   	pop    %ebp
c0108222:	c3                   	ret    

c0108223 <page2kva>:
page2kva(struct Page *page) {
c0108223:	55                   	push   %ebp
c0108224:	89 e5                	mov    %esp,%ebp
c0108226:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108229:	8b 45 08             	mov    0x8(%ebp),%eax
c010822c:	89 04 24             	mov    %eax,(%esp)
c010822f:	e8 d7 ff ff ff       	call   c010820b <page2pa>
c0108234:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108237:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010823a:	c1 e8 0c             	shr    $0xc,%eax
c010823d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108240:	a1 a4 6f 12 c0       	mov    0xc0126fa4,%eax
c0108245:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108248:	72 23                	jb     c010826d <page2kva+0x4a>
c010824a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010824d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108251:	c7 44 24 08 d8 ad 10 	movl   $0xc010add8,0x8(%esp)
c0108258:	c0 
c0108259:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108260:	00 
c0108261:	c7 04 24 fb ad 10 c0 	movl   $0xc010adfb,(%esp)
c0108268:	e8 80 8a ff ff       	call   c0100ced <__panic>
c010826d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108270:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108275:	89 ec                	mov    %ebp,%esp
c0108277:	5d                   	pop    %ebp
c0108278:	c3                   	ret    

c0108279 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108279:	55                   	push   %ebp
c010827a:	89 e5                	mov    %esp,%ebp
c010827c:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010827f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108286:	e8 11 98 ff ff       	call   c0101a9c <ide_device_valid>
c010828b:	85 c0                	test   %eax,%eax
c010828d:	75 1c                	jne    c01082ab <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010828f:	c7 44 24 08 09 ae 10 	movl   $0xc010ae09,0x8(%esp)
c0108296:	c0 
c0108297:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010829e:	00 
c010829f:	c7 04 24 23 ae 10 c0 	movl   $0xc010ae23,(%esp)
c01082a6:	e8 42 8a ff ff       	call   c0100ced <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01082ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01082b2:	e8 25 98 ff ff       	call   c0101adc <ide_device_size>
c01082b7:	c1 e8 03             	shr    $0x3,%eax
c01082ba:	a3 40 70 12 c0       	mov    %eax,0xc0127040
}
c01082bf:	90                   	nop
c01082c0:	89 ec                	mov    %ebp,%esp
c01082c2:	5d                   	pop    %ebp
c01082c3:	c3                   	ret    

c01082c4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01082c4:	55                   	push   %ebp
c01082c5:	89 e5                	mov    %esp,%ebp
c01082c7:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01082ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082cd:	89 04 24             	mov    %eax,(%esp)
c01082d0:	e8 4e ff ff ff       	call   c0108223 <page2kva>
c01082d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01082d8:	c1 ea 08             	shr    $0x8,%edx
c01082db:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01082de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082e2:	74 0b                	je     c01082ef <swapfs_read+0x2b>
c01082e4:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c01082ea:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01082ed:	72 23                	jb     c0108312 <swapfs_read+0x4e>
c01082ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01082f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01082f6:	c7 44 24 08 34 ae 10 	movl   $0xc010ae34,0x8(%esp)
c01082fd:	c0 
c01082fe:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0108305:	00 
c0108306:	c7 04 24 23 ae 10 c0 	movl   $0xc010ae23,(%esp)
c010830d:	e8 db 89 ff ff       	call   c0100ced <__panic>
c0108312:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108315:	c1 e2 03             	shl    $0x3,%edx
c0108318:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010831f:	00 
c0108320:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108324:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108328:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010832f:	e8 e5 97 ff ff       	call   c0101b19 <ide_read_secs>
}
c0108334:	89 ec                	mov    %ebp,%esp
c0108336:	5d                   	pop    %ebp
c0108337:	c3                   	ret    

c0108338 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108338:	55                   	push   %ebp
c0108339:	89 e5                	mov    %esp,%ebp
c010833b:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010833e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108341:	89 04 24             	mov    %eax,(%esp)
c0108344:	e8 da fe ff ff       	call   c0108223 <page2kva>
c0108349:	8b 55 08             	mov    0x8(%ebp),%edx
c010834c:	c1 ea 08             	shr    $0x8,%edx
c010834f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108352:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108356:	74 0b                	je     c0108363 <swapfs_write+0x2b>
c0108358:	8b 15 40 70 12 c0    	mov    0xc0127040,%edx
c010835e:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108361:	72 23                	jb     c0108386 <swapfs_write+0x4e>
c0108363:	8b 45 08             	mov    0x8(%ebp),%eax
c0108366:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010836a:	c7 44 24 08 34 ae 10 	movl   $0xc010ae34,0x8(%esp)
c0108371:	c0 
c0108372:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108379:	00 
c010837a:	c7 04 24 23 ae 10 c0 	movl   $0xc010ae23,(%esp)
c0108381:	e8 67 89 ff ff       	call   c0100ced <__panic>
c0108386:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108389:	c1 e2 03             	shl    $0x3,%edx
c010838c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108393:	00 
c0108394:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108398:	89 54 24 04          	mov    %edx,0x4(%esp)
c010839c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01083a3:	e8 b2 99 ff ff       	call   c0101d5a <ide_write_secs>
}
c01083a8:	89 ec                	mov    %ebp,%esp
c01083aa:	5d                   	pop    %ebp
c01083ab:	c3                   	ret    

c01083ac <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01083ac:	55                   	push   %ebp
c01083ad:	89 e5                	mov    %esp,%ebp
c01083af:	83 ec 58             	sub    $0x58,%esp
c01083b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01083b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01083b8:	8b 45 14             	mov    0x14(%ebp),%eax
c01083bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01083be:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01083c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01083c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01083c7:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01083ca:	8b 45 18             	mov    0x18(%ebp),%eax
c01083cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01083d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01083d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01083d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01083d9:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01083dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01083e6:	74 1c                	je     c0108404 <printnum+0x58>
c01083e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083eb:	ba 00 00 00 00       	mov    $0x0,%edx
c01083f0:	f7 75 e4             	divl   -0x1c(%ebp)
c01083f3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01083f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083f9:	ba 00 00 00 00       	mov    $0x0,%edx
c01083fe:	f7 75 e4             	divl   -0x1c(%ebp)
c0108401:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108404:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108407:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010840a:	f7 75 e4             	divl   -0x1c(%ebp)
c010840d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108410:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108413:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108416:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108419:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010841c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010841f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108422:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108425:	8b 45 18             	mov    0x18(%ebp),%eax
c0108428:	ba 00 00 00 00       	mov    $0x0,%edx
c010842d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0108430:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0108433:	19 d1                	sbb    %edx,%ecx
c0108435:	72 4c                	jb     c0108483 <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0108437:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010843a:	8d 50 ff             	lea    -0x1(%eax),%edx
c010843d:	8b 45 20             	mov    0x20(%ebp),%eax
c0108440:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108444:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108448:	8b 45 18             	mov    0x18(%ebp),%eax
c010844b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010844f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108452:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108455:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108459:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010845d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108460:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108464:	8b 45 08             	mov    0x8(%ebp),%eax
c0108467:	89 04 24             	mov    %eax,(%esp)
c010846a:	e8 3d ff ff ff       	call   c01083ac <printnum>
c010846f:	eb 1b                	jmp    c010848c <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108471:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108474:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108478:	8b 45 20             	mov    0x20(%ebp),%eax
c010847b:	89 04 24             	mov    %eax,(%esp)
c010847e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108481:	ff d0                	call   *%eax
        while (-- width > 0)
c0108483:	ff 4d 1c             	decl   0x1c(%ebp)
c0108486:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010848a:	7f e5                	jg     c0108471 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010848c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010848f:	05 d4 ae 10 c0       	add    $0xc010aed4,%eax
c0108494:	0f b6 00             	movzbl (%eax),%eax
c0108497:	0f be c0             	movsbl %al,%eax
c010849a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010849d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084a1:	89 04 24             	mov    %eax,(%esp)
c01084a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01084a7:	ff d0                	call   *%eax
}
c01084a9:	90                   	nop
c01084aa:	89 ec                	mov    %ebp,%esp
c01084ac:	5d                   	pop    %ebp
c01084ad:	c3                   	ret    

c01084ae <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01084ae:	55                   	push   %ebp
c01084af:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01084b1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01084b5:	7e 14                	jle    c01084cb <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01084b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ba:	8b 00                	mov    (%eax),%eax
c01084bc:	8d 48 08             	lea    0x8(%eax),%ecx
c01084bf:	8b 55 08             	mov    0x8(%ebp),%edx
c01084c2:	89 0a                	mov    %ecx,(%edx)
c01084c4:	8b 50 04             	mov    0x4(%eax),%edx
c01084c7:	8b 00                	mov    (%eax),%eax
c01084c9:	eb 30                	jmp    c01084fb <getuint+0x4d>
    }
    else if (lflag) {
c01084cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01084cf:	74 16                	je     c01084e7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01084d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01084d4:	8b 00                	mov    (%eax),%eax
c01084d6:	8d 48 04             	lea    0x4(%eax),%ecx
c01084d9:	8b 55 08             	mov    0x8(%ebp),%edx
c01084dc:	89 0a                	mov    %ecx,(%edx)
c01084de:	8b 00                	mov    (%eax),%eax
c01084e0:	ba 00 00 00 00       	mov    $0x0,%edx
c01084e5:	eb 14                	jmp    c01084fb <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01084e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ea:	8b 00                	mov    (%eax),%eax
c01084ec:	8d 48 04             	lea    0x4(%eax),%ecx
c01084ef:	8b 55 08             	mov    0x8(%ebp),%edx
c01084f2:	89 0a                	mov    %ecx,(%edx)
c01084f4:	8b 00                	mov    (%eax),%eax
c01084f6:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01084fb:	5d                   	pop    %ebp
c01084fc:	c3                   	ret    

c01084fd <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01084fd:	55                   	push   %ebp
c01084fe:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108500:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108504:	7e 14                	jle    c010851a <getint+0x1d>
        return va_arg(*ap, long long);
c0108506:	8b 45 08             	mov    0x8(%ebp),%eax
c0108509:	8b 00                	mov    (%eax),%eax
c010850b:	8d 48 08             	lea    0x8(%eax),%ecx
c010850e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108511:	89 0a                	mov    %ecx,(%edx)
c0108513:	8b 50 04             	mov    0x4(%eax),%edx
c0108516:	8b 00                	mov    (%eax),%eax
c0108518:	eb 28                	jmp    c0108542 <getint+0x45>
    }
    else if (lflag) {
c010851a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010851e:	74 12                	je     c0108532 <getint+0x35>
        return va_arg(*ap, long);
c0108520:	8b 45 08             	mov    0x8(%ebp),%eax
c0108523:	8b 00                	mov    (%eax),%eax
c0108525:	8d 48 04             	lea    0x4(%eax),%ecx
c0108528:	8b 55 08             	mov    0x8(%ebp),%edx
c010852b:	89 0a                	mov    %ecx,(%edx)
c010852d:	8b 00                	mov    (%eax),%eax
c010852f:	99                   	cltd   
c0108530:	eb 10                	jmp    c0108542 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108532:	8b 45 08             	mov    0x8(%ebp),%eax
c0108535:	8b 00                	mov    (%eax),%eax
c0108537:	8d 48 04             	lea    0x4(%eax),%ecx
c010853a:	8b 55 08             	mov    0x8(%ebp),%edx
c010853d:	89 0a                	mov    %ecx,(%edx)
c010853f:	8b 00                	mov    (%eax),%eax
c0108541:	99                   	cltd   
    }
}
c0108542:	5d                   	pop    %ebp
c0108543:	c3                   	ret    

c0108544 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108544:	55                   	push   %ebp
c0108545:	89 e5                	mov    %esp,%ebp
c0108547:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010854a:	8d 45 14             	lea    0x14(%ebp),%eax
c010854d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108553:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108557:	8b 45 10             	mov    0x10(%ebp),%eax
c010855a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010855e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108561:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108565:	8b 45 08             	mov    0x8(%ebp),%eax
c0108568:	89 04 24             	mov    %eax,(%esp)
c010856b:	e8 05 00 00 00       	call   c0108575 <vprintfmt>
    va_end(ap);
}
c0108570:	90                   	nop
c0108571:	89 ec                	mov    %ebp,%esp
c0108573:	5d                   	pop    %ebp
c0108574:	c3                   	ret    

c0108575 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108575:	55                   	push   %ebp
c0108576:	89 e5                	mov    %esp,%ebp
c0108578:	56                   	push   %esi
c0108579:	53                   	push   %ebx
c010857a:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010857d:	eb 17                	jmp    c0108596 <vprintfmt+0x21>
            if (ch == '\0') {
c010857f:	85 db                	test   %ebx,%ebx
c0108581:	0f 84 bf 03 00 00    	je     c0108946 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0108587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010858a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010858e:	89 1c 24             	mov    %ebx,(%esp)
c0108591:	8b 45 08             	mov    0x8(%ebp),%eax
c0108594:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108596:	8b 45 10             	mov    0x10(%ebp),%eax
c0108599:	8d 50 01             	lea    0x1(%eax),%edx
c010859c:	89 55 10             	mov    %edx,0x10(%ebp)
c010859f:	0f b6 00             	movzbl (%eax),%eax
c01085a2:	0f b6 d8             	movzbl %al,%ebx
c01085a5:	83 fb 25             	cmp    $0x25,%ebx
c01085a8:	75 d5                	jne    c010857f <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01085aa:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01085ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01085b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01085b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01085bb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01085c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01085c5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01085c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01085cb:	8d 50 01             	lea    0x1(%eax),%edx
c01085ce:	89 55 10             	mov    %edx,0x10(%ebp)
c01085d1:	0f b6 00             	movzbl (%eax),%eax
c01085d4:	0f b6 d8             	movzbl %al,%ebx
c01085d7:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01085da:	83 f8 55             	cmp    $0x55,%eax
c01085dd:	0f 87 37 03 00 00    	ja     c010891a <vprintfmt+0x3a5>
c01085e3:	8b 04 85 f8 ae 10 c0 	mov    -0x3fef5108(,%eax,4),%eax
c01085ea:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c01085ec:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c01085f0:	eb d6                	jmp    c01085c8 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01085f2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01085f6:	eb d0                	jmp    c01085c8 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01085f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01085ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108602:	89 d0                	mov    %edx,%eax
c0108604:	c1 e0 02             	shl    $0x2,%eax
c0108607:	01 d0                	add    %edx,%eax
c0108609:	01 c0                	add    %eax,%eax
c010860b:	01 d8                	add    %ebx,%eax
c010860d:	83 e8 30             	sub    $0x30,%eax
c0108610:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0108613:	8b 45 10             	mov    0x10(%ebp),%eax
c0108616:	0f b6 00             	movzbl (%eax),%eax
c0108619:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010861c:	83 fb 2f             	cmp    $0x2f,%ebx
c010861f:	7e 38                	jle    c0108659 <vprintfmt+0xe4>
c0108621:	83 fb 39             	cmp    $0x39,%ebx
c0108624:	7f 33                	jg     c0108659 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c0108626:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0108629:	eb d4                	jmp    c01085ff <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010862b:	8b 45 14             	mov    0x14(%ebp),%eax
c010862e:	8d 50 04             	lea    0x4(%eax),%edx
c0108631:	89 55 14             	mov    %edx,0x14(%ebp)
c0108634:	8b 00                	mov    (%eax),%eax
c0108636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0108639:	eb 1f                	jmp    c010865a <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010863b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010863f:	79 87                	jns    c01085c8 <vprintfmt+0x53>
                width = 0;
c0108641:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0108648:	e9 7b ff ff ff       	jmp    c01085c8 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010864d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108654:	e9 6f ff ff ff       	jmp    c01085c8 <vprintfmt+0x53>
            goto process_precision;
c0108659:	90                   	nop

        process_precision:
            if (width < 0)
c010865a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010865e:	0f 89 64 ff ff ff    	jns    c01085c8 <vprintfmt+0x53>
                width = precision, precision = -1;
c0108664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108667:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010866a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108671:	e9 52 ff ff ff       	jmp    c01085c8 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108676:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0108679:	e9 4a ff ff ff       	jmp    c01085c8 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010867e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108681:	8d 50 04             	lea    0x4(%eax),%edx
c0108684:	89 55 14             	mov    %edx,0x14(%ebp)
c0108687:	8b 00                	mov    (%eax),%eax
c0108689:	8b 55 0c             	mov    0xc(%ebp),%edx
c010868c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108690:	89 04 24             	mov    %eax,(%esp)
c0108693:	8b 45 08             	mov    0x8(%ebp),%eax
c0108696:	ff d0                	call   *%eax
            break;
c0108698:	e9 a4 02 00 00       	jmp    c0108941 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010869d:	8b 45 14             	mov    0x14(%ebp),%eax
c01086a0:	8d 50 04             	lea    0x4(%eax),%edx
c01086a3:	89 55 14             	mov    %edx,0x14(%ebp)
c01086a6:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01086a8:	85 db                	test   %ebx,%ebx
c01086aa:	79 02                	jns    c01086ae <vprintfmt+0x139>
                err = -err;
c01086ac:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01086ae:	83 fb 06             	cmp    $0x6,%ebx
c01086b1:	7f 0b                	jg     c01086be <vprintfmt+0x149>
c01086b3:	8b 34 9d b8 ae 10 c0 	mov    -0x3fef5148(,%ebx,4),%esi
c01086ba:	85 f6                	test   %esi,%esi
c01086bc:	75 23                	jne    c01086e1 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01086be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01086c2:	c7 44 24 08 e5 ae 10 	movl   $0xc010aee5,0x8(%esp)
c01086c9:	c0 
c01086ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01086d4:	89 04 24             	mov    %eax,(%esp)
c01086d7:	e8 68 fe ff ff       	call   c0108544 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01086dc:	e9 60 02 00 00       	jmp    c0108941 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01086e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01086e5:	c7 44 24 08 ee ae 10 	movl   $0xc010aeee,0x8(%esp)
c01086ec:	c0 
c01086ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01086f7:	89 04 24             	mov    %eax,(%esp)
c01086fa:	e8 45 fe ff ff       	call   c0108544 <printfmt>
            break;
c01086ff:	e9 3d 02 00 00       	jmp    c0108941 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0108704:	8b 45 14             	mov    0x14(%ebp),%eax
c0108707:	8d 50 04             	lea    0x4(%eax),%edx
c010870a:	89 55 14             	mov    %edx,0x14(%ebp)
c010870d:	8b 30                	mov    (%eax),%esi
c010870f:	85 f6                	test   %esi,%esi
c0108711:	75 05                	jne    c0108718 <vprintfmt+0x1a3>
                p = "(null)";
c0108713:	be f1 ae 10 c0       	mov    $0xc010aef1,%esi
            }
            if (width > 0 && padc != '-') {
c0108718:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010871c:	7e 76                	jle    c0108794 <vprintfmt+0x21f>
c010871e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108722:	74 70                	je     c0108794 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010872b:	89 34 24             	mov    %esi,(%esp)
c010872e:	e8 ee 03 00 00       	call   c0108b21 <strnlen>
c0108733:	89 c2                	mov    %eax,%edx
c0108735:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108738:	29 d0                	sub    %edx,%eax
c010873a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010873d:	eb 16                	jmp    c0108755 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c010873f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0108743:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108746:	89 54 24 04          	mov    %edx,0x4(%esp)
c010874a:	89 04 24             	mov    %eax,(%esp)
c010874d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108750:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108752:	ff 4d e8             	decl   -0x18(%ebp)
c0108755:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108759:	7f e4                	jg     c010873f <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010875b:	eb 37                	jmp    c0108794 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010875d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108761:	74 1f                	je     c0108782 <vprintfmt+0x20d>
c0108763:	83 fb 1f             	cmp    $0x1f,%ebx
c0108766:	7e 05                	jle    c010876d <vprintfmt+0x1f8>
c0108768:	83 fb 7e             	cmp    $0x7e,%ebx
c010876b:	7e 15                	jle    c0108782 <vprintfmt+0x20d>
                    putch('?', putdat);
c010876d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108770:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108774:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010877b:	8b 45 08             	mov    0x8(%ebp),%eax
c010877e:	ff d0                	call   *%eax
c0108780:	eb 0f                	jmp    c0108791 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0108782:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108785:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108789:	89 1c 24             	mov    %ebx,(%esp)
c010878c:	8b 45 08             	mov    0x8(%ebp),%eax
c010878f:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108791:	ff 4d e8             	decl   -0x18(%ebp)
c0108794:	89 f0                	mov    %esi,%eax
c0108796:	8d 70 01             	lea    0x1(%eax),%esi
c0108799:	0f b6 00             	movzbl (%eax),%eax
c010879c:	0f be d8             	movsbl %al,%ebx
c010879f:	85 db                	test   %ebx,%ebx
c01087a1:	74 27                	je     c01087ca <vprintfmt+0x255>
c01087a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01087a7:	78 b4                	js     c010875d <vprintfmt+0x1e8>
c01087a9:	ff 4d e4             	decl   -0x1c(%ebp)
c01087ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01087b0:	79 ab                	jns    c010875d <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c01087b2:	eb 16                	jmp    c01087ca <vprintfmt+0x255>
                putch(' ', putdat);
c01087b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01087c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01087c5:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c01087c7:	ff 4d e8             	decl   -0x18(%ebp)
c01087ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087ce:	7f e4                	jg     c01087b4 <vprintfmt+0x23f>
            }
            break;
c01087d0:	e9 6c 01 00 00       	jmp    c0108941 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01087d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01087d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087dc:	8d 45 14             	lea    0x14(%ebp),%eax
c01087df:	89 04 24             	mov    %eax,(%esp)
c01087e2:	e8 16 fd ff ff       	call   c01084fd <getint>
c01087e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01087ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087f3:	85 d2                	test   %edx,%edx
c01087f5:	79 26                	jns    c010881d <vprintfmt+0x2a8>
                putch('-', putdat);
c01087f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087fe:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0108805:	8b 45 08             	mov    0x8(%ebp),%eax
c0108808:	ff d0                	call   *%eax
                num = -(long long)num;
c010880a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010880d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108810:	f7 d8                	neg    %eax
c0108812:	83 d2 00             	adc    $0x0,%edx
c0108815:	f7 da                	neg    %edx
c0108817:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010881a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010881d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108824:	e9 a8 00 00 00       	jmp    c01088d1 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0108829:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010882c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108830:	8d 45 14             	lea    0x14(%ebp),%eax
c0108833:	89 04 24             	mov    %eax,(%esp)
c0108836:	e8 73 fc ff ff       	call   c01084ae <getuint>
c010883b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010883e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0108841:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108848:	e9 84 00 00 00       	jmp    c01088d1 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010884d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108850:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108854:	8d 45 14             	lea    0x14(%ebp),%eax
c0108857:	89 04 24             	mov    %eax,(%esp)
c010885a:	e8 4f fc ff ff       	call   c01084ae <getuint>
c010885f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108862:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108865:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010886c:	eb 63                	jmp    c01088d1 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010886e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108871:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108875:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010887c:	8b 45 08             	mov    0x8(%ebp),%eax
c010887f:	ff d0                	call   *%eax
            putch('x', putdat);
c0108881:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108884:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108888:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010888f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108892:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108894:	8b 45 14             	mov    0x14(%ebp),%eax
c0108897:	8d 50 04             	lea    0x4(%eax),%edx
c010889a:	89 55 14             	mov    %edx,0x14(%ebp)
c010889d:	8b 00                	mov    (%eax),%eax
c010889f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01088a9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01088b0:	eb 1f                	jmp    c01088d1 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01088b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01088b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088b9:	8d 45 14             	lea    0x14(%ebp),%eax
c01088bc:	89 04 24             	mov    %eax,(%esp)
c01088bf:	e8 ea fb ff ff       	call   c01084ae <getuint>
c01088c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088c7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01088ca:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01088d1:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01088d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01088d8:	89 54 24 18          	mov    %edx,0x18(%esp)
c01088dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01088df:	89 54 24 14          	mov    %edx,0x14(%esp)
c01088e3:	89 44 24 10          	mov    %eax,0x10(%esp)
c01088e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01088f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01088f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01088fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ff:	89 04 24             	mov    %eax,(%esp)
c0108902:	e8 a5 fa ff ff       	call   c01083ac <printnum>
            break;
c0108907:	eb 38                	jmp    c0108941 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108909:	8b 45 0c             	mov    0xc(%ebp),%eax
c010890c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108910:	89 1c 24             	mov    %ebx,(%esp)
c0108913:	8b 45 08             	mov    0x8(%ebp),%eax
c0108916:	ff d0                	call   *%eax
            break;
c0108918:	eb 27                	jmp    c0108941 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010891a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010891d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108921:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108928:	8b 45 08             	mov    0x8(%ebp),%eax
c010892b:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010892d:	ff 4d 10             	decl   0x10(%ebp)
c0108930:	eb 03                	jmp    c0108935 <vprintfmt+0x3c0>
c0108932:	ff 4d 10             	decl   0x10(%ebp)
c0108935:	8b 45 10             	mov    0x10(%ebp),%eax
c0108938:	48                   	dec    %eax
c0108939:	0f b6 00             	movzbl (%eax),%eax
c010893c:	3c 25                	cmp    $0x25,%al
c010893e:	75 f2                	jne    c0108932 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0108940:	90                   	nop
    while (1) {
c0108941:	e9 37 fc ff ff       	jmp    c010857d <vprintfmt+0x8>
                return;
c0108946:	90                   	nop
        }
    }
}
c0108947:	83 c4 40             	add    $0x40,%esp
c010894a:	5b                   	pop    %ebx
c010894b:	5e                   	pop    %esi
c010894c:	5d                   	pop    %ebp
c010894d:	c3                   	ret    

c010894e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010894e:	55                   	push   %ebp
c010894f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108951:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108954:	8b 40 08             	mov    0x8(%eax),%eax
c0108957:	8d 50 01             	lea    0x1(%eax),%edx
c010895a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010895d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0108960:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108963:	8b 10                	mov    (%eax),%edx
c0108965:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108968:	8b 40 04             	mov    0x4(%eax),%eax
c010896b:	39 c2                	cmp    %eax,%edx
c010896d:	73 12                	jae    c0108981 <sprintputch+0x33>
        *b->buf ++ = ch;
c010896f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108972:	8b 00                	mov    (%eax),%eax
c0108974:	8d 48 01             	lea    0x1(%eax),%ecx
c0108977:	8b 55 0c             	mov    0xc(%ebp),%edx
c010897a:	89 0a                	mov    %ecx,(%edx)
c010897c:	8b 55 08             	mov    0x8(%ebp),%edx
c010897f:	88 10                	mov    %dl,(%eax)
    }
}
c0108981:	90                   	nop
c0108982:	5d                   	pop    %ebp
c0108983:	c3                   	ret    

c0108984 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0108984:	55                   	push   %ebp
c0108985:	89 e5                	mov    %esp,%ebp
c0108987:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010898a:	8d 45 14             	lea    0x14(%ebp),%eax
c010898d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0108990:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108993:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108997:	8b 45 10             	mov    0x10(%ebp),%eax
c010899a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010899e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01089a8:	89 04 24             	mov    %eax,(%esp)
c01089ab:	e8 0a 00 00 00       	call   c01089ba <vsnprintf>
c01089b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01089b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01089b6:	89 ec                	mov    %ebp,%esp
c01089b8:	5d                   	pop    %ebp
c01089b9:	c3                   	ret    

c01089ba <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01089ba:	55                   	push   %ebp
c01089bb:	89 e5                	mov    %esp,%ebp
c01089bd:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01089c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01089c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01089c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089c9:	8d 50 ff             	lea    -0x1(%eax),%edx
c01089cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01089cf:	01 d0                	add    %edx,%eax
c01089d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01089db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01089df:	74 0a                	je     c01089eb <vsnprintf+0x31>
c01089e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01089e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089e7:	39 c2                	cmp    %eax,%edx
c01089e9:	76 07                	jbe    c01089f2 <vsnprintf+0x38>
        return -E_INVAL;
c01089eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01089f0:	eb 2a                	jmp    c0108a1c <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01089f2:	8b 45 14             	mov    0x14(%ebp),%eax
c01089f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01089f9:	8b 45 10             	mov    0x10(%ebp),%eax
c01089fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108a00:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0108a03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a07:	c7 04 24 4e 89 10 c0 	movl   $0xc010894e,(%esp)
c0108a0e:	e8 62 fb ff ff       	call   c0108575 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0108a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a16:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108a1c:	89 ec                	mov    %ebp,%esp
c0108a1e:	5d                   	pop    %ebp
c0108a1f:	c3                   	ret    

c0108a20 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0108a20:	55                   	push   %ebp
c0108a21:	89 e5                	mov    %esp,%ebp
c0108a23:	57                   	push   %edi
c0108a24:	56                   	push   %esi
c0108a25:	53                   	push   %ebx
c0108a26:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108a29:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108a2e:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108a34:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108a3a:	6b f0 05             	imul   $0x5,%eax,%esi
c0108a3d:	01 fe                	add    %edi,%esi
c0108a3f:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0108a44:	f7 e7                	mul    %edi
c0108a46:	01 d6                	add    %edx,%esi
c0108a48:	89 f2                	mov    %esi,%edx
c0108a4a:	83 c0 0b             	add    $0xb,%eax
c0108a4d:	83 d2 00             	adc    $0x0,%edx
c0108a50:	89 c7                	mov    %eax,%edi
c0108a52:	83 e7 ff             	and    $0xffffffff,%edi
c0108a55:	89 f9                	mov    %edi,%ecx
c0108a57:	0f b7 da             	movzwl %dx,%ebx
c0108a5a:	89 0d 60 3a 12 c0    	mov    %ecx,0xc0123a60
c0108a60:	89 1d 64 3a 12 c0    	mov    %ebx,0xc0123a64
    unsigned long long result = (next >> 12);
c0108a66:	a1 60 3a 12 c0       	mov    0xc0123a60,%eax
c0108a6b:	8b 15 64 3a 12 c0    	mov    0xc0123a64,%edx
c0108a71:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0108a75:	c1 ea 0c             	shr    $0xc,%edx
c0108a78:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108a7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0108a7e:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0108a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108a8e:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108a91:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108a97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108a9b:	74 1c                	je     c0108ab9 <rand+0x99>
c0108a9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108aa0:	ba 00 00 00 00       	mov    $0x0,%edx
c0108aa5:	f7 75 dc             	divl   -0x24(%ebp)
c0108aa8:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108aab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108aae:	ba 00 00 00 00       	mov    $0x0,%edx
c0108ab3:	f7 75 dc             	divl   -0x24(%ebp)
c0108ab6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108ab9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108abc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108abf:	f7 75 dc             	divl   -0x24(%ebp)
c0108ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108ac5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108ac8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108acb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108ace:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108ad1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108ad4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108ad7:	83 c4 24             	add    $0x24,%esp
c0108ada:	5b                   	pop    %ebx
c0108adb:	5e                   	pop    %esi
c0108adc:	5f                   	pop    %edi
c0108add:	5d                   	pop    %ebp
c0108ade:	c3                   	ret    

c0108adf <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0108adf:	55                   	push   %ebp
c0108ae0:	89 e5                	mov    %esp,%ebp
    next = seed;
c0108ae2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ae5:	ba 00 00 00 00       	mov    $0x0,%edx
c0108aea:	a3 60 3a 12 c0       	mov    %eax,0xc0123a60
c0108aef:	89 15 64 3a 12 c0    	mov    %edx,0xc0123a64
}
c0108af5:	90                   	nop
c0108af6:	5d                   	pop    %ebp
c0108af7:	c3                   	ret    

c0108af8 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108af8:	55                   	push   %ebp
c0108af9:	89 e5                	mov    %esp,%ebp
c0108afb:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108afe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0108b05:	eb 03                	jmp    c0108b0a <strlen+0x12>
        cnt ++;
c0108b07:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0108b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b0d:	8d 50 01             	lea    0x1(%eax),%edx
c0108b10:	89 55 08             	mov    %edx,0x8(%ebp)
c0108b13:	0f b6 00             	movzbl (%eax),%eax
c0108b16:	84 c0                	test   %al,%al
c0108b18:	75 ed                	jne    c0108b07 <strlen+0xf>
    }
    return cnt;
c0108b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108b1d:	89 ec                	mov    %ebp,%esp
c0108b1f:	5d                   	pop    %ebp
c0108b20:	c3                   	ret    

c0108b21 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108b21:	55                   	push   %ebp
c0108b22:	89 e5                	mov    %esp,%ebp
c0108b24:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108b27:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108b2e:	eb 03                	jmp    c0108b33 <strnlen+0x12>
        cnt ++;
c0108b30:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108b33:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b36:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108b39:	73 10                	jae    c0108b4b <strnlen+0x2a>
c0108b3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b3e:	8d 50 01             	lea    0x1(%eax),%edx
c0108b41:	89 55 08             	mov    %edx,0x8(%ebp)
c0108b44:	0f b6 00             	movzbl (%eax),%eax
c0108b47:	84 c0                	test   %al,%al
c0108b49:	75 e5                	jne    c0108b30 <strnlen+0xf>
    }
    return cnt;
c0108b4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108b4e:	89 ec                	mov    %ebp,%esp
c0108b50:	5d                   	pop    %ebp
c0108b51:	c3                   	ret    

c0108b52 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108b52:	55                   	push   %ebp
c0108b53:	89 e5                	mov    %esp,%ebp
c0108b55:	57                   	push   %edi
c0108b56:	56                   	push   %esi
c0108b57:	83 ec 20             	sub    $0x20,%esp
c0108b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108b60:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108b66:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b6c:	89 d1                	mov    %edx,%ecx
c0108b6e:	89 c2                	mov    %eax,%edx
c0108b70:	89 ce                	mov    %ecx,%esi
c0108b72:	89 d7                	mov    %edx,%edi
c0108b74:	ac                   	lods   %ds:(%esi),%al
c0108b75:	aa                   	stos   %al,%es:(%edi)
c0108b76:	84 c0                	test   %al,%al
c0108b78:	75 fa                	jne    c0108b74 <strcpy+0x22>
c0108b7a:	89 fa                	mov    %edi,%edx
c0108b7c:	89 f1                	mov    %esi,%ecx
c0108b7e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108b81:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108b84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108b8a:	83 c4 20             	add    $0x20,%esp
c0108b8d:	5e                   	pop    %esi
c0108b8e:	5f                   	pop    %edi
c0108b8f:	5d                   	pop    %ebp
c0108b90:	c3                   	ret    

c0108b91 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108b91:	55                   	push   %ebp
c0108b92:	89 e5                	mov    %esp,%ebp
c0108b94:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0108b9d:	eb 1e                	jmp    c0108bbd <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0108b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ba2:	0f b6 10             	movzbl (%eax),%edx
c0108ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ba8:	88 10                	mov    %dl,(%eax)
c0108baa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108bad:	0f b6 00             	movzbl (%eax),%eax
c0108bb0:	84 c0                	test   %al,%al
c0108bb2:	74 03                	je     c0108bb7 <strncpy+0x26>
            src ++;
c0108bb4:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108bb7:	ff 45 fc             	incl   -0x4(%ebp)
c0108bba:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0108bbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108bc1:	75 dc                	jne    c0108b9f <strncpy+0xe>
    }
    return dst;
c0108bc3:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108bc6:	89 ec                	mov    %ebp,%esp
c0108bc8:	5d                   	pop    %ebp
c0108bc9:	c3                   	ret    

c0108bca <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0108bca:	55                   	push   %ebp
c0108bcb:	89 e5                	mov    %esp,%ebp
c0108bcd:	57                   	push   %edi
c0108bce:	56                   	push   %esi
c0108bcf:	83 ec 20             	sub    $0x20,%esp
c0108bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108bdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0108bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108be4:	89 d1                	mov    %edx,%ecx
c0108be6:	89 c2                	mov    %eax,%edx
c0108be8:	89 ce                	mov    %ecx,%esi
c0108bea:	89 d7                	mov    %edx,%edi
c0108bec:	ac                   	lods   %ds:(%esi),%al
c0108bed:	ae                   	scas   %es:(%edi),%al
c0108bee:	75 08                	jne    c0108bf8 <strcmp+0x2e>
c0108bf0:	84 c0                	test   %al,%al
c0108bf2:	75 f8                	jne    c0108bec <strcmp+0x22>
c0108bf4:	31 c0                	xor    %eax,%eax
c0108bf6:	eb 04                	jmp    c0108bfc <strcmp+0x32>
c0108bf8:	19 c0                	sbb    %eax,%eax
c0108bfa:	0c 01                	or     $0x1,%al
c0108bfc:	89 fa                	mov    %edi,%edx
c0108bfe:	89 f1                	mov    %esi,%ecx
c0108c00:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c03:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108c06:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0108c09:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108c0c:	83 c4 20             	add    $0x20,%esp
c0108c0f:	5e                   	pop    %esi
c0108c10:	5f                   	pop    %edi
c0108c11:	5d                   	pop    %ebp
c0108c12:	c3                   	ret    

c0108c13 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0108c13:	55                   	push   %ebp
c0108c14:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108c16:	eb 09                	jmp    c0108c21 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0108c18:	ff 4d 10             	decl   0x10(%ebp)
c0108c1b:	ff 45 08             	incl   0x8(%ebp)
c0108c1e:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0108c21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108c25:	74 1a                	je     c0108c41 <strncmp+0x2e>
c0108c27:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c2a:	0f b6 00             	movzbl (%eax),%eax
c0108c2d:	84 c0                	test   %al,%al
c0108c2f:	74 10                	je     c0108c41 <strncmp+0x2e>
c0108c31:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c34:	0f b6 10             	movzbl (%eax),%edx
c0108c37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c3a:	0f b6 00             	movzbl (%eax),%eax
c0108c3d:	38 c2                	cmp    %al,%dl
c0108c3f:	74 d7                	je     c0108c18 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108c41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108c45:	74 18                	je     c0108c5f <strncmp+0x4c>
c0108c47:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c4a:	0f b6 00             	movzbl (%eax),%eax
c0108c4d:	0f b6 d0             	movzbl %al,%edx
c0108c50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c53:	0f b6 00             	movzbl (%eax),%eax
c0108c56:	0f b6 c8             	movzbl %al,%ecx
c0108c59:	89 d0                	mov    %edx,%eax
c0108c5b:	29 c8                	sub    %ecx,%eax
c0108c5d:	eb 05                	jmp    c0108c64 <strncmp+0x51>
c0108c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c64:	5d                   	pop    %ebp
c0108c65:	c3                   	ret    

c0108c66 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108c66:	55                   	push   %ebp
c0108c67:	89 e5                	mov    %esp,%ebp
c0108c69:	83 ec 04             	sub    $0x4,%esp
c0108c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c6f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108c72:	eb 13                	jmp    c0108c87 <strchr+0x21>
        if (*s == c) {
c0108c74:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c77:	0f b6 00             	movzbl (%eax),%eax
c0108c7a:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108c7d:	75 05                	jne    c0108c84 <strchr+0x1e>
            return (char *)s;
c0108c7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c82:	eb 12                	jmp    c0108c96 <strchr+0x30>
        }
        s ++;
c0108c84:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8a:	0f b6 00             	movzbl (%eax),%eax
c0108c8d:	84 c0                	test   %al,%al
c0108c8f:	75 e3                	jne    c0108c74 <strchr+0xe>
    }
    return NULL;
c0108c91:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c96:	89 ec                	mov    %ebp,%esp
c0108c98:	5d                   	pop    %ebp
c0108c99:	c3                   	ret    

c0108c9a <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108c9a:	55                   	push   %ebp
c0108c9b:	89 e5                	mov    %esp,%ebp
c0108c9d:	83 ec 04             	sub    $0x4,%esp
c0108ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ca3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108ca6:	eb 0e                	jmp    c0108cb6 <strfind+0x1c>
        if (*s == c) {
c0108ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cab:	0f b6 00             	movzbl (%eax),%eax
c0108cae:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0108cb1:	74 0f                	je     c0108cc2 <strfind+0x28>
            break;
        }
        s ++;
c0108cb3:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0108cb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cb9:	0f b6 00             	movzbl (%eax),%eax
c0108cbc:	84 c0                	test   %al,%al
c0108cbe:	75 e8                	jne    c0108ca8 <strfind+0xe>
c0108cc0:	eb 01                	jmp    c0108cc3 <strfind+0x29>
            break;
c0108cc2:	90                   	nop
    }
    return (char *)s;
c0108cc3:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0108cc6:	89 ec                	mov    %ebp,%esp
c0108cc8:	5d                   	pop    %ebp
c0108cc9:	c3                   	ret    

c0108cca <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0108cca:	55                   	push   %ebp
c0108ccb:	89 e5                	mov    %esp,%ebp
c0108ccd:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0108cd0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108cd7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108cde:	eb 03                	jmp    c0108ce3 <strtol+0x19>
        s ++;
c0108ce0:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0108ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce6:	0f b6 00             	movzbl (%eax),%eax
c0108ce9:	3c 20                	cmp    $0x20,%al
c0108ceb:	74 f3                	je     c0108ce0 <strtol+0x16>
c0108ced:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cf0:	0f b6 00             	movzbl (%eax),%eax
c0108cf3:	3c 09                	cmp    $0x9,%al
c0108cf5:	74 e9                	je     c0108ce0 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0108cf7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cfa:	0f b6 00             	movzbl (%eax),%eax
c0108cfd:	3c 2b                	cmp    $0x2b,%al
c0108cff:	75 05                	jne    c0108d06 <strtol+0x3c>
        s ++;
c0108d01:	ff 45 08             	incl   0x8(%ebp)
c0108d04:	eb 14                	jmp    c0108d1a <strtol+0x50>
    }
    else if (*s == '-') {
c0108d06:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d09:	0f b6 00             	movzbl (%eax),%eax
c0108d0c:	3c 2d                	cmp    $0x2d,%al
c0108d0e:	75 0a                	jne    c0108d1a <strtol+0x50>
        s ++, neg = 1;
c0108d10:	ff 45 08             	incl   0x8(%ebp)
c0108d13:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108d1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d1e:	74 06                	je     c0108d26 <strtol+0x5c>
c0108d20:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108d24:	75 22                	jne    c0108d48 <strtol+0x7e>
c0108d26:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d29:	0f b6 00             	movzbl (%eax),%eax
c0108d2c:	3c 30                	cmp    $0x30,%al
c0108d2e:	75 18                	jne    c0108d48 <strtol+0x7e>
c0108d30:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d33:	40                   	inc    %eax
c0108d34:	0f b6 00             	movzbl (%eax),%eax
c0108d37:	3c 78                	cmp    $0x78,%al
c0108d39:	75 0d                	jne    c0108d48 <strtol+0x7e>
        s += 2, base = 16;
c0108d3b:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108d3f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108d46:	eb 29                	jmp    c0108d71 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108d48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d4c:	75 16                	jne    c0108d64 <strtol+0x9a>
c0108d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d51:	0f b6 00             	movzbl (%eax),%eax
c0108d54:	3c 30                	cmp    $0x30,%al
c0108d56:	75 0c                	jne    c0108d64 <strtol+0x9a>
        s ++, base = 8;
c0108d58:	ff 45 08             	incl   0x8(%ebp)
c0108d5b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108d62:	eb 0d                	jmp    c0108d71 <strtol+0xa7>
    }
    else if (base == 0) {
c0108d64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108d68:	75 07                	jne    c0108d71 <strtol+0xa7>
        base = 10;
c0108d6a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d74:	0f b6 00             	movzbl (%eax),%eax
c0108d77:	3c 2f                	cmp    $0x2f,%al
c0108d79:	7e 1b                	jle    c0108d96 <strtol+0xcc>
c0108d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d7e:	0f b6 00             	movzbl (%eax),%eax
c0108d81:	3c 39                	cmp    $0x39,%al
c0108d83:	7f 11                	jg     c0108d96 <strtol+0xcc>
            dig = *s - '0';
c0108d85:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d88:	0f b6 00             	movzbl (%eax),%eax
c0108d8b:	0f be c0             	movsbl %al,%eax
c0108d8e:	83 e8 30             	sub    $0x30,%eax
c0108d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d94:	eb 48                	jmp    c0108dde <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d99:	0f b6 00             	movzbl (%eax),%eax
c0108d9c:	3c 60                	cmp    $0x60,%al
c0108d9e:	7e 1b                	jle    c0108dbb <strtol+0xf1>
c0108da0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108da3:	0f b6 00             	movzbl (%eax),%eax
c0108da6:	3c 7a                	cmp    $0x7a,%al
c0108da8:	7f 11                	jg     c0108dbb <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dad:	0f b6 00             	movzbl (%eax),%eax
c0108db0:	0f be c0             	movsbl %al,%eax
c0108db3:	83 e8 57             	sub    $0x57,%eax
c0108db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108db9:	eb 23                	jmp    c0108dde <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dbe:	0f b6 00             	movzbl (%eax),%eax
c0108dc1:	3c 40                	cmp    $0x40,%al
c0108dc3:	7e 3b                	jle    c0108e00 <strtol+0x136>
c0108dc5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dc8:	0f b6 00             	movzbl (%eax),%eax
c0108dcb:	3c 5a                	cmp    $0x5a,%al
c0108dcd:	7f 31                	jg     c0108e00 <strtol+0x136>
            dig = *s - 'A' + 10;
c0108dcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dd2:	0f b6 00             	movzbl (%eax),%eax
c0108dd5:	0f be c0             	movsbl %al,%eax
c0108dd8:	83 e8 37             	sub    $0x37,%eax
c0108ddb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108de1:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108de4:	7d 19                	jge    c0108dff <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0108de6:	ff 45 08             	incl   0x8(%ebp)
c0108de9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108dec:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108df0:	89 c2                	mov    %eax,%edx
c0108df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108df5:	01 d0                	add    %edx,%eax
c0108df7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0108dfa:	e9 72 ff ff ff       	jmp    c0108d71 <strtol+0xa7>
            break;
c0108dff:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0108e00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108e04:	74 08                	je     c0108e0e <strtol+0x144>
        *endptr = (char *) s;
c0108e06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e09:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e0c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108e0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108e12:	74 07                	je     c0108e1b <strtol+0x151>
c0108e14:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108e17:	f7 d8                	neg    %eax
c0108e19:	eb 03                	jmp    c0108e1e <strtol+0x154>
c0108e1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108e1e:	89 ec                	mov    %ebp,%esp
c0108e20:	5d                   	pop    %ebp
c0108e21:	c3                   	ret    

c0108e22 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108e22:	55                   	push   %ebp
c0108e23:	89 e5                	mov    %esp,%ebp
c0108e25:	83 ec 28             	sub    $0x28,%esp
c0108e28:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0108e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e2e:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108e31:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0108e35:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e38:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0108e3b:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0108e3e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e41:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108e44:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108e47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108e4b:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108e4e:	89 d7                	mov    %edx,%edi
c0108e50:	f3 aa                	rep stos %al,%es:(%edi)
c0108e52:	89 fa                	mov    %edi,%edx
c0108e54:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108e57:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108e5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0108e60:	89 ec                	mov    %ebp,%esp
c0108e62:	5d                   	pop    %ebp
c0108e63:	c3                   	ret    

c0108e64 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108e64:	55                   	push   %ebp
c0108e65:	89 e5                	mov    %esp,%ebp
c0108e67:	57                   	push   %edi
c0108e68:	56                   	push   %esi
c0108e69:	53                   	push   %ebx
c0108e6a:	83 ec 30             	sub    $0x30,%esp
c0108e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108e73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e76:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108e79:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e7c:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e82:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108e85:	73 42                	jae    c0108ec9 <memmove+0x65>
c0108e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108e8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e90:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108e93:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e96:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108e99:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e9c:	c1 e8 02             	shr    $0x2,%eax
c0108e9f:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108ea1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108ea4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108ea7:	89 d7                	mov    %edx,%edi
c0108ea9:	89 c6                	mov    %eax,%esi
c0108eab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108ead:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108eb0:	83 e1 03             	and    $0x3,%ecx
c0108eb3:	74 02                	je     c0108eb7 <memmove+0x53>
c0108eb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108eb7:	89 f0                	mov    %esi,%eax
c0108eb9:	89 fa                	mov    %edi,%edx
c0108ebb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108ebe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108ec1:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0108ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0108ec7:	eb 36                	jmp    c0108eff <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108ec9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ecc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ed2:	01 c2                	add    %eax,%edx
c0108ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ed7:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108edd:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0108ee0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ee3:	89 c1                	mov    %eax,%ecx
c0108ee5:	89 d8                	mov    %ebx,%eax
c0108ee7:	89 d6                	mov    %edx,%esi
c0108ee9:	89 c7                	mov    %eax,%edi
c0108eeb:	fd                   	std    
c0108eec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108eee:	fc                   	cld    
c0108eef:	89 f8                	mov    %edi,%eax
c0108ef1:	89 f2                	mov    %esi,%edx
c0108ef3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108ef6:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108ef9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0108efc:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108eff:	83 c4 30             	add    $0x30,%esp
c0108f02:	5b                   	pop    %ebx
c0108f03:	5e                   	pop    %esi
c0108f04:	5f                   	pop    %edi
c0108f05:	5d                   	pop    %ebp
c0108f06:	c3                   	ret    

c0108f07 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108f07:	55                   	push   %ebp
c0108f08:	89 e5                	mov    %esp,%ebp
c0108f0a:	57                   	push   %edi
c0108f0b:	56                   	push   %esi
c0108f0c:	83 ec 20             	sub    $0x20,%esp
c0108f0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f15:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f24:	c1 e8 02             	shr    $0x2,%eax
c0108f27:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0108f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f2f:	89 d7                	mov    %edx,%edi
c0108f31:	89 c6                	mov    %eax,%esi
c0108f33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108f35:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108f38:	83 e1 03             	and    $0x3,%ecx
c0108f3b:	74 02                	je     c0108f3f <memcpy+0x38>
c0108f3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108f3f:	89 f0                	mov    %esi,%eax
c0108f41:	89 fa                	mov    %edi,%edx
c0108f43:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108f46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0108f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108f4f:	83 c4 20             	add    $0x20,%esp
c0108f52:	5e                   	pop    %esi
c0108f53:	5f                   	pop    %edi
c0108f54:	5d                   	pop    %ebp
c0108f55:	c3                   	ret    

c0108f56 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108f56:	55                   	push   %ebp
c0108f57:	89 e5                	mov    %esp,%ebp
c0108f59:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108f5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108f62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f65:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108f68:	eb 2e                	jmp    c0108f98 <memcmp+0x42>
        if (*s1 != *s2) {
c0108f6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f6d:	0f b6 10             	movzbl (%eax),%edx
c0108f70:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f73:	0f b6 00             	movzbl (%eax),%eax
c0108f76:	38 c2                	cmp    %al,%dl
c0108f78:	74 18                	je     c0108f92 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108f7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f7d:	0f b6 00             	movzbl (%eax),%eax
c0108f80:	0f b6 d0             	movzbl %al,%edx
c0108f83:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108f86:	0f b6 00             	movzbl (%eax),%eax
c0108f89:	0f b6 c8             	movzbl %al,%ecx
c0108f8c:	89 d0                	mov    %edx,%eax
c0108f8e:	29 c8                	sub    %ecx,%eax
c0108f90:	eb 18                	jmp    c0108faa <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0108f92:	ff 45 fc             	incl   -0x4(%ebp)
c0108f95:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0108f98:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f9b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108f9e:	89 55 10             	mov    %edx,0x10(%ebp)
c0108fa1:	85 c0                	test   %eax,%eax
c0108fa3:	75 c5                	jne    c0108f6a <memcmp+0x14>
    }
    return 0;
c0108fa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108faa:	89 ec                	mov    %ebp,%esp
c0108fac:	5d                   	pop    %ebp
c0108fad:	c3                   	ret    
